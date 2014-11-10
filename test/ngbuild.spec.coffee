
fs = require 'fs'

describe 'grunt-ngbuild', ->
  it 'should have built all the files into big.js', ->
    big = fs.readFileSync 'test/output/big/big.js', 'utf8'
    big.should.match /bigModule.js/
    big.should.match /smallModule.js/
    big.should.match /smallModule2.js/
    big.should.match /sharedDependency.js/

  it 'should have built some of the files into small.js', ->
    small = fs.readFileSync 'test/output/small/small.js', 'utf8'
    small.should.match /smallModule.js/
    small.should.match /smallModule2.js/
    small.should.match /sharedDependency.js/
