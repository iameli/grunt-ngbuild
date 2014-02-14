'use strict'

module.exports = (grunt) ->
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-mocha-test'
  grunt.loadTasks 'tasks'

  grunt.initConfig
    ngbuild:
      testbig:
        expand: true
        src: ["test/data/**/*.js"]
        dest: "test/output/big.js"
        module: "big"
      testsmall:
        expand: true
        src: ["test/data/**/*.js"]
        dest: "test/output/small.js"
        module: "small"

    mochaTest:
      options:
        require: ['should', 'coffee-script/register']
        bail: true
      all: ['test/*.coffee']