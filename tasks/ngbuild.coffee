"use strict"

Sandbox = require 'sandbox'
async   = require 'async'
_       = require 'lodash'
path    = require 'path'

# This is inserted before all the JS files so it has to define Angular and such
before = ->
  
  # Dummy module
  mod = {}
  noop = -> return mod
  mod[key] = noop for key in ["_invokeQueue", "_runBlocks", "requires", "name", "provider", "factory", "service", "value", "constant", "animation", "filter", "controller", "directive", "config", "run"]

  # Function for logging module calls
  @_calls = []
  addCall = (name, deps) =>
    @_calls.push [name, deps]

  # Dummy angular object
  this.angular = 
    module: (name, deps) ->
      addCall name, deps
      return mod

  this.window = this

after = ->
  return JSON.stringify @_calls

beforeStr = "(#{before.toString()})();"
afterStr = ";(#{after.toString()})()"

s = new Sandbox
  timeout: 100000

# This guy maintains a list of modules and does a lot of heavy lifting wrt their dependency resolution
ModuleList = class

  constructor: ({@ignore}) ->
    @ignore ?= []
    @modules = {}

  # Register a angular.module call within a file
  modCall: (file, name, deps) ->
    if not @modules[name] # First time encountering this module, create its entry
      @modules[name] = 
        files: []
        dependencies: deps
    else if deps?
      if @modules[name].deps? # Uh oh, module redefinition!
        throw new Error "Definition of #{name} encountered in both #{file} and one of #{@modules[name].files}. Bad."
      @modules[name].dependencies = deps
    @modules[name].files = @modules[name].files.concat file if not (file in @modules[name].files)

  moduleIsIgnored: (mName) ->
    return _.some(str.match(mName) for str in @ignore)

  # Resursively caclulate dependencies for a given module
  dependenciesForModule: (mName, mods = []) ->
    mod = @modules[mName]
    if not mod?
      if @moduleIsIgnored mName
        return []
      throw new Error "Angular module not found: #{mName}"
    for dep in mod.dependencies
      if not (dep in mods)
        mods.push dep
        try
          @dependenciesForModule dep, mods
        catch e
          throw new Error "#{e.message}\nWhile resolving dependencies for #{mName}"
    return mods


  # Compute the necessary files for a given module
  filesForModule: (mName) ->
    files = @modules[mName].files
    deps = @dependenciesForModule mName
    (files = _.union files, @modules[m].files) for m in deps when not @moduleIsIgnored m
    return files



module.exports = (grunt) ->
  grunt.registerMultiTask 'ngbuild', 'concatenate angular files, ignoring unused modules', ->
    mList = new ModuleList
      ignore: @data.ignore
    done = @async()
    fileData = {}
    async.each this.files,
      (fname, cb) ->
        file = grunt.file.read fname.src
        fileData[fname.src] = file
        s.run "#{beforeStr}#{file}#{afterStr};", (output) ->
          try
            # sandbox returns its strings wrapped in single quotes, oddly. strip them then parse.
            calls = JSON.parse output.result.substr(1, output.result.length - 2)
          catch e
            grunt.verbose.error e
            grunt.verbose.writeln "#{output.result}"
            grunt.log.error "Error while parsing '#{fname.src}'. Most likely it is making calls other than angular.module."
            return cb(true) # Err
          mList.modCall(fname.src, call[0], call[1]) for call in calls
          cb()
      (err) =>
        apps = this.data.apps
        if typeof apps is 'function'
          apps = apps()
        for app in apps
          try
            requiredFiles = mList.filesForModule(app)
          catch e
            grunt.log.error "Dependency resolution error: #{e.message}"
            return done(false)
          concatted = (fileData[fileName] for fileName in requiredFiles).sort().join "\n" # Sort is so the output is deterministic across machines.
          grunt.file.write path.resolve(this.data.dest, "#{app}.js"), concatted
          grunt.log.ok 'Wrote module', "#{app}".cyan, "to", path.resolve(this.data.dest, "#{app}.js").cyan
        done(not err?)
