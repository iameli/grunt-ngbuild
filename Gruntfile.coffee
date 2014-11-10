'use strict'

module.exports = (grunt) ->
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-mocha-test'
  grunt.loadNpmTasks 'grunt-release'
  grunt.loadTasks 'tasks'

  grunt.initConfig

    clean:
      all:
        src: ['test/output']

    ngbuild:
      testbig:
        expand: true
        src: ["test/data/**/*.js"]
        dest: "test/output/"
        apps: ["big"]
      testsmall:
        expand: true
        src: ["test/data/**/*.js"]
        dest: "test/output/"
        apps: ["small"]

    mochaTest:
      options:
        require: ['should', 'coffee-script/register']
        bail: true
      all: ['test/*.coffee']

  grunt.registerTask 'test', ['clean', 'ngbuild', 'mochaTest']
