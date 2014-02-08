_ = require('underscore')
global.sinon = require('sinon')
global.expect = require('expect.js')
sandboxedModule = require('sandboxed-module')

global.sandbox = (path, requires, globals) ->
  sandboxedModule.require("./../#{path}", {requires, globals})

global.spyObj = (fns...) ->
  _(fns).reduce (obj, fn) ->
    obj[fn] = sinon.stub()
    obj
  , {}
