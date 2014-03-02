_ = require('underscore')
global.sinon = require('sinon')
boolHelpers = require('indeed')
global.expect = boolHelpers.expect
sandboxedModule = require('sandboxed-module')

global.sandbox = (path, requires, globals) ->
  sandboxedModule.require("./../#{path}", {requires, globals})

global._ = _
_.mixin require('./../lib/mixins')
_.mixin
  fix: (obj) ->
    JSON.parse(JSON.stringify(obj))

boolHelpers.indeed.mixin
  truthy: () ->
    (val) ->
      if val then true else false
  falsy: () ->
    (val) ->
      if val then false else true

global.spyObj = (fns...) ->
  _(fns).reduce (obj, fn) ->
    obj[fn] = sinon.stub()
    obj
  , {}
