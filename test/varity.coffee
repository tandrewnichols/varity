require('should')
global.context = global.describe
varity = require('../lib/varity')
sinon = require('sinon')

describe 'varity', ->
  describe 'wrapper', ->
    it 'should return a function', ->
      varity.should.be.a.Function

    it 'should call the passed function', ->
      callback = sinon.spy()
      varity callback
      callback.called.should.be.true

