should = require('should')
global.context = global.describe
$ = require('../lib/varity')
sinon = require('sinon')
_ = require('underscore')
jsdom = require('jsdom')

describe '$', ->
  beforeEach ->
    @callback = sinon.spy()

  afterEach ->
    $.reset()

  it 'should return a function', ->
    $.should.be.a.Function

  it 'should wrap the passed function', ->
    wrapped = $ @callback
    wrapped.should.be.a.Function
    wrapped()
    @callback.called.should.be.true

  it 'should throw if passed no arguments', ->
    (->
      $()
    ).should.throw('No function passed to varity')

  it 'should throw if the last argument is not a function', ->
    (->
      $({})
    ).should.throw('Last argument is not a function')

  context 'called with string types', ->
    it 'should accept string', ->
      wrapped = $ 'string', @callback
      wrapped 'something'
      @callback.calledWith('something').should.be.true

    it 'should accept String', ->
      wrapped = $ 'String', @callback
      wrapped 'something'
      @callback.calledWith('something').should.be.true

    it 'should accept function', ->
      fn = sinon.spy()
      wrapped = $ 'function', @callback
      wrapped(fn)
      @callback.calledWith(fn).should.be.true

    it 'should accept Function', ->
      fn = sinon.spy()
      wrapped = $ 'Function', @callback
      wrapped(fn)
      @callback.calledWith(fn).should.be.true

    it 'should accept object', ->
      obj = fake: 'data'
      wrapped = $ 'object', @callback
      wrapped(obj)
      @callback.calledWith(obj).should.be.true

    it 'should accept Object', ->
      obj = fake: 'data'
      wrapped = $ 'Object', @callback
      wrapped(obj)
      @callback.calledWith(obj).should.be.true

    it 'should accept array', ->
      arr = [ 'one', 'two' ]
      wrapped = $ 'array', @callback
      wrapped(arr)
      @callback.calledWith(arr).should.be.true

    it 'should accept Array', ->
      arr = [ 'one', 'two' ]
      wrapped = $ 'Array', @callback
      wrapped(arr)
      @callback.calledWith(arr).should.be.true

    it 'should accept number', ->
      wrapped = $ 'number', @callback
      wrapped(2)
      @callback.calledWith(2).should.be.true

    it 'should accept Number', ->
      wrapped = $ 'Number', @callback
      wrapped(2)
      @callback.calledWith(2).should.be.true

    it 'should accept boolean', ->
      wrapped = $ 'boolean', @callback
      wrapped(true)
      @callback.calledWith(true).should.be.true

    it 'should accept Boolean', ->
      wrapped = $ 'Boolean', @callback
      wrapped(false)
      @callback.calledWith(false).should.be.true

    it 'should accept date', ->
      date = new Date()
      wrapped = $ 'date', @callback
      wrapped(date)
      @callback.calledWith(date).should.be.true

    it 'should accept Date', ->
      date = new Date()
      wrapped = $ 'Date', @callback
      wrapped(date)
      @callback.calledWith(date).should.be.true

    it 'should accept regexp', ->
      reg = new RegExp('.*')
      wrapped = $ 'regexp', @callback
      wrapped(reg)
      @callback.calledWith(reg).should.be.true

    it 'should accept Regexp', ->
      reg = new RegExp('.*')
      wrapped = $ 'Regexp', @callback
      wrapped(reg)
      @callback.calledWith(reg).should.be.true

    it 'should accept RegExp', ->
      reg = new RegExp('.*')
      wrapped = $ 'RegExp', @callback
      wrapped(reg)
      @callback.calledWith(reg).should.be.true

    it 'should accept nan', ->
      nan = NaN
      wrapped = $ 'nan', @callback
      wrapped(nan)
      # Checking truthy values of NaN is a pain
      @callback.args[0][0].should.be.NaN

    it 'should accept Nan', ->
      nan = NaN
      wrapped = $ 'Nan', @callback
      wrapped(nan)
      # Checking truthy values of NaN is a pain
      @callback.args[0][0].should.be.NaN

    it 'should accept NaN', ->
      nan = NaN
      wrapped = $ 'NaN', @callback
      wrapped(nan)
      # Checking truthy values of NaN is a pain
      @callback.args[0][0].should.be.NaN

    it 'should accept null', ->
      wrapped = $ 'null', @callback
      wrapped(null)
      @callback.calledWith(null).should.be.true

    it 'should accept Null', ->
      wrapped = $ 'Null', @callback
      wrapped(null)
      @callback.calledWith(null).should.be.true

    it 'should accept undefined', ->
      wrapped = $ 'undefined', @callback
      wrapped(undefined)
      @callback.calledWith(undefined).should.be.true

    it 'should accept Undefined', ->
      wrapped = $ 'Undefined', @callback
      wrapped(undefined)
      @callback.calledWith(undefined).should.be.true

    it 'should accept arguments', ->
      args = (->
        arguments
      ) 'one', 'two'
      wrapped = $ 'arguments', @callback
      wrapped(args)
      @callback.calledWith(args).should.be.true

    it 'should accept Arguments', ->
      args = (->
        arguments
      ) 'one', 'two'
      wrapped = $ 'Arguments', @callback
      wrapped(args)
      @callback.calledWith(args).should.be.true

    it 'should accept infinity', ->
      wrapped = $ 'infinity', @callback
      wrapped(Infinity)
      @callback.calledWith(Infinity).should.be.true

    it 'should accept Infinity', ->
      wrapped = $ 'Infinity', @callback
      wrapped(Infinity)
      @callback.calledWith(Infinity).should.be.true

    it 'should accept error', ->
      wrapped = $ 'error', @callback
      e = new Error()
      wrapped e
      @callback.calledWith(e).should.be.true
    
    it 'should accept Error', ->
      wrapped = $ 'Error', @callback
      e = new Error()
      wrapped e
      @callback.calledWith(e).should.be.true

    it 'should accept Element', (done) ->
      callback = @callback
      wrapped = $ 'Element', @callback
      jsdom.env '<div id="id"></div>', (e, window) ->
        el = window.document.getElementById('id')
        wrapped el
        callback.calledWith(el).should.be.true
        done()

    it 'should accept jQuery', (done) ->
      callback = @callback
      wrapped = $ 'jQuery', @callback
      jsdom.env '<div id="1"></div><div id="2"></div><div id="3"></div>', ["http://code.jquery.com/jquery.js"], (e, window) ->
        elems = window.$('div')
        wrapped elems
        callback.calledWith(elems).should.be.true
        done()

    it 'should accept multiple string parameters', ->
      obj = {}
      arr = []
      fn = ->
      wrapped = $ 'string', 'object', 'array', 'function', @callback
      wrapped('something', obj, arr, fn)
      @callback.calledWith('something', obj, arr, fn).should.be.true

    it 'should accept multiple string parameters with duplicates', ->
      fn1 = ->
      fn2 = ->
      wrapped = $ 'function', 'function', @callback
      wrapped(fn1, fn2)
      @callback.calledWith(fn1, fn2).should.be.true

  context 'called with actual types', ->
    it 'should accept String', ->
      wrapped = $ String, @callback
      wrapped 'string'
      @callback.calledWith('string').should.be.true

    it 'should accept Function', ->
      wrapped = $ Function, @callback
      fn = ->
      wrapped fn
      @callback.calledWith(fn).should.be.true

    it 'should accept Object', ->
      wrapped = $ Object, @callback
      obj = {}
      wrapped obj
      @callback.calledWith(obj).should.be.true

    it 'should accept Array', ->
      wrapped = $ Array, @callback
      arr = []
      wrapped arr
      @callback.calledWith(arr).should.be.true

    it 'should accept Number', ->
      wrapped = $ Number, @callback
      wrapped 2
      @callback.calledWith(2).should.be.true

    it 'should accept Boolean', ->
      wrapped = $ Boolean, @callback
      wrapped true
      @callback.calledWith(true).should.be.true

    it 'should accept Date', ->
      wrapped = $ Date, @callback
      date = new Date()
      wrapped date
      @callback.calledWith(date).should.be.true

    it 'should accept RegExp', ->
      wrapped = $ RegExp, @callback
      reg = /.*/
      wrapped reg
      @callback.calledWith(reg).should.be.true

    it 'should accept Error', ->
      wrapped = $ Error, @callback
      e = new Error()
      wrapped e
      @callback.calledWith(e).should.be.true

    it 'should accept multiple type parameters', ->
      wrapped = $ String, Function, Object, Array, RegExp, Date, @callback
      fn = ->
      obj = {}
      arr = []
      reg = /.*/
      date = new Date()
      wrapped 'string', fn, obj, arr, reg, date
      @callback.calledWith('string', fn, obj, arr, reg, date).should.be.true

    it 'should accept multiple type parameters with duplicates', ->
      wrapped = $ Function, Array, Function, @callback
      fn1 = ->
      fn2 = ->
      arr = []
      wrapped fn1, arr, fn2
      @callback.calledWith(fn1, arr, fn2).should.be.true

  context 'called with special types', ->
    it 'should accept null', ->
      wrapped = $ null, @callback
      wrapped null
      @callback.calledWith(null).should.be.true

    it 'should accept undefined', ->
      wrapped = $ undefined, @callback
      wrapped undefined
      @callback.calledWith(undefined).should.be.true

    it 'should accept multiple special parameters', ->
      wrapped = $ null, undefined, @callback
      wrapped null, undefined
      @callback.calledWith(null, undefined).should.be.true

    it 'should accept multiple special parameters with duplicate', ->
      wrapped = $ null, null, undefined, null, @callback
      wrapped null, null, undefined, null
      @callback.calledWith(null, null, undefined, null).should.be.true

  context 'called with mixed types', ->
    it 'should accept any combination of types (part 1)', ->
      wrapped = $ 'string', Function, null, @callback
      fn = ->
      wrapped 'string', fn, null
      @callback.calledWith('string', fn, null).should.be.true

    it 'should accept any combination of types (part 2)', ->
      wrapped = $ 'string', Function, Function, 'object', Object, null, undefined, Date, 'regexp', @callback
      fn1 = ->
      fn2 = ->
      obj1 = {}
      obj2 = {}
      date = new Date()
      reg = /.*/
      wrapped 'string', fn1, fn2, obj1, obj2, null, undefined, date, reg
      @callback.calledWith('string', fn1, fn2, obj1, obj2, null, undefined, date, reg).should.be.true

  context 'called with an array', ->
    it 'should accept an array of string parameters', ->
      wrapped = $ ['string', 'object'], @callback
      obj = {}
      wrapped 'string', obj
      @callback.calledWith('string', obj).should.be.true

    it 'should accept an array of type parameters', ->
      wrapped = $ [Date, RegExp], @callback
      date = new Date()
      reg = /.*/
      wrapped date, reg
      @callback.calledWith(date, reg).should.be.true

    it 'should accept an array of special parameters', ->
      wrapped = $ [null, undefined, null], @callback
      wrapped null, undefined, null
      @callback.calledWith(null, undefined, null).should.be.true

    it 'should accept an array of mixed parameters', ->
      wrapped = $ [null, 'string', Object, 'date', Function], @callback
      obj = {}
      date = new Date()
      fn = ->
      wrapped null, 'string', obj, date, fn
      @callback.calledWith(null, 'string', obj, date, fn).should.be.true

    it 'should flatten an array of arrays with parameters', ->
      wrapped = $ [['string', 'function'], ['object']], @callback
      fn = ->
      obj = {}
      wrapped 'string', fn, obj
      @callback.calledWith('string', fn, obj).should.be.true

  context 'called with regular parameters and an array', ->
    it 'should accept parameters with a single array', ->
      wrapped = $ 'string', [Object, Function], @callback
      fn = ->
      obj = {}
      wrapped 'string', obj, fn
      @callback.calledWith('string', obj, fn).should.be.true

    it 'should accept parameters with more than one array', ->
      wrapped = $ [Array, Date], 'object', [undefined, 'infinity'], @callback
      arr = []
      date = new Date()
      obj = {}
      inf = Infinity
      wrapped arr, date, obj, undefined, inf
      @callback.calledWith(arr, date, obj, undefined, inf).should.be.true

  context 'called with string abbreviations', ->
    it 'should accept s', ->
      wrapped = $ 's', @callback
      wrapped 'string'
      @callback.calledWith('string').should.be.true

    it 'should accept f', ->
      wrapped = $ 'f', @callback
      fn = ->
      wrapped fn
      @callback.calledWith(fn).should.be.true

    it 'should accept o', ->
      wrapped = $ 'o', @callback
      obj = {}
      wrapped obj
      @callback.calledWith(obj).should.be.true

    it 'should accept A', ->
      wrapped = $ ' A', @callback
      arr = []
      wrapped arr
      @callback.calledWith(arr).should.be.true

    it 'should accept 1', ->
      wrapped = $ '1', @callback
      wrapped 2
      @callback.calledWith(2).should.be.true

    it 'should accept b', ->
      wrapped = $ 'b', @callback
      wrapped true
      @callback.calledWith(true).should.be.true

    it 'should accept d', ->
      wrapped = $ 'd', @callback
      date = new Date()
      wrapped date
      @callback.calledWith(date).should.be.true

    it 'should accept r', ->
      wrapped = $ 'r', @callback
      reg = /.*/
      wrapped reg
      @callback.calledWith(reg).should.be.true

    it 'should accept N', ->
      wrapped = $ ' N', @callback
      wrapped NaN
      @callback.args[0][0].should.be.NaN

    it 'should accept n', ->
      wrapped = $ 'n', @callback
      wrapped null
      @callback.calledWith(null).should.be.true

    it 'should accept u', ->
      wrapped = $ 'u', @callback
      wrapped undefined
      @callback.calledWith(undefined).should.be.true

    it 'should accept a', ->
      wrapped = $ 'a', @callback
      args = (->
        arguments
      ) 'one', 'two'
      wrapped args
      @callback.calledWith(args).should.be.true

    it 'should accept i', ->
      wrapped = $ 'i', @callback
      wrapped Infinity
      @callback.calledWith(Infinity).should.be.true

    it 'should accept e', ->
      wrapped = $ 'e', @callback
      e = new Error()
      wrapped e
      @callback.calledWith(e).should.be.true

    it 'should accept E', (done) ->
      callback = @callback
      wrapped = $ ' E', @callback
      jsdom.env '<div id="id"></div>', (e, window) ->
        el = window.document.getElementById('id')
        wrapped el
        callback.calledWith(el).should.be.true
        done()
      
    it 'should accept $', (done) ->
      callback = @callback
      wrapped = $ '$', @callback
      jsdom.env '<div id="1"></div><div id="2"></div><div id="3"></div>', ["http://code.jquery.com/jquery.js"], (e, window) ->
        elems = window.$('div')
        wrapped elems
        callback.calledWith(elems).should.be.true
        done()

    it 'should accept a mix of letters', ->
      wrapped = $ 'sfo1ne', @callback
      fn = ->
      obj = {}
      e = new Error()
      wrapped 'string', fn, obj, 2, null, e
      @callback.calledWith('string', fn, obj, 2, null, e).should.be.true

    it 'should accept a string with a space at the front', ->
      wrapped = $ ' Ao', @callback
      arr = []
      obj = {}
      wrapped arr, obj
      @callback.calledWith(arr, obj).should.be.true

    it 'should not accept other letters', ->
      callback = @callback
      (->
        $ '9', callback
      ).should.throw('Unrecognized type: 9')

  context 'called with custom types', ->
    it 'should accept those types', ->
      class Foo
      wrapped = $ 'Foo', @callback
      f = new Foo()
      wrapped f
      @callback.calledWith(f).should.be.true

    it 'should accept multiple custom types', ->
      class Foo
      class Bar
      wrapped = $ 'Foo', 'Bar', @callback
      f = new Foo()
      b = new Bar()
      wrapped f, b
      @callback.calledWith(f, b).should.be.true

    it 'should accept camel case object names', ->
      class FooBaby
      wrapped = $ 'FooBaby', @callback
      fb = new FooBaby()
      wrapped fb
      @callback.calledWith(fb).should.be.true

    it 'should accept custom types with normal types', ->
      class Foo
      wrapped = $ 'oAs', 'Foo', @callback
      obj = {}
      arr = []
      f = new Foo
      wrapped obj, arr, 'string', f
      @callback.calledWith(obj, arr, 'string', f).should.be.true

  context 'called with an object', ->
    it 'should accept a string type', ->
      wrapped = $
        type: 'Array'
      , @callback
      arr = []
      wrapped arr
      @callback.calledWith(arr).should.be.true

    it 'should convert Object to AnonObject', ->
      wrapped = $
        type: 'Object'
      , @callback
      obj = {}
      wrapped obj
      @callback.calledWith(obj).should.be.true

    it 'should convert Regexp to RegExp', ->
      wrapped = $
        type: 'Regexp'
      , @callback
      reg = /.*/
      wrapped reg
      @callback.calledWith(reg).should.be.true

    it 'should convert Nan to NaN', ->
      wrapped = $
        type: 'NaN'
      , @callback
      wrapped NaN
      @callback.args[0][0].should.be.NaN

    it 'should accept a real type', ->
      wrapped = $
        type: Function
      , @callback
      fn = ->
      wrapped fn
      @callback.calledWith(fn).should.be.true

    it 'should accept optional', ->
      wrapped = $
        type: 'Object'
        optional: true
      ,
        type: 'Object'
      , @callback
      obj = {}
      wrapped obj
      @callback.calledWith(undefined, {}).should.be.true

    it 'should accept populate', ->
      wrapped = $
        type: 'Object',
        populate: true
      , @callback
      wrapped()
      @callback.calledWith({}).should.be.true

    it 'should accept populate and optional', ->
      wrapped = $
        type: 'Object'
        optional: 'true',
        populate: 'true'
      ,
        type: 'Object'
      , @callback
      obj =
        one: 1
        two: 2
      wrapped obj
      @callback.calledWith({}, obj).should.be.true

    it 'should accept default on custom string types', ->
      class Foo
      wrapped = $
        type: 'Foo'
        default: ->
          return new Foo()
      , @callback
      wrapped()
      @callback.args[0][0].should.be.an.instanceOf(Foo)

    it 'should accept default on custom real types', ->
      class Foo
      wrapped = $
        type: Foo
        default: ->
          return new Foo()
      , @callback
      wrapped()
      @callback.args[0][0].should.be.an.instanceOf(Foo)

    it 'should accept default on built in types', ->
      wrapped = $
        type: 'Object'
        default: ->
          return one: 1
      , @callback
      wrapped()
      @callback.calledWith(one: 1).should.be.true

    it 'should accept non-function defaults', ->
      wrapped = $
        type: 'Array'
        default: ['one', 'two']
      , @callback
      wrapped()
      @callback.calledWith(['one', 'two']).should.be.true

    it 'should not override populate if passed together', ->
      wrapped = $
        type: 'Array'
        populate: false
        default: ['one', 'two']
      , @callback
      wrapped()
      @callback.calledWith(undefined).should.be.true

    it 'should accept a mix of objects', ->
      wrapped = $
        type: 'Array'
      ,
        type: 'Object'
        optional: 'true'
      ,
        type: 'Object'
      ,
        type: 'String'
        populate: 'true'
      , @callback
      arr = []
      obj = one: 1
      wrapped arr, obj
      @callback.calledWith(arr, undefined, obj, '').should.be.true

    it 'should accept objects with other parameters', ->
      wrapped = $ 's-o', Object,
        type: 'Array',
        populate: true
        default: -> ['one', 'two']
      , [ '-+String', 'String']
      , @callback
      obj = one: 1
      wrapped 'string1', obj, 'string2'
      @callback.calledWith('string1', undefined, obj, ['one', 'two'], '', 'string2').should.be.true

    it 'should accept an options object after a string', ->
      wrapped = $ 's+A',
        defaults:
          'Array': ['one', 'two']
      , @callback
      wrapped 'string'
      @callback.calledWith('string', ['one', 'two']).should.be.true

    it 'should accept options after multiple strings', ->
      wrapped = $ 'String', '_Array',
        defaults:
          'Array': ['foobaby']
      , @callback
      wrapped 'string', []
      @callback.calledWith('string', ['foobaby']).should.be.true

    it 'should accept a variety of options', ->
      class Foo
      wrapped = $ 's~oA',
        populate: ['object', 'array']
        letters:
          '~': 'Foo'
        defaults:
          'Array': ['one', 'two']
      , @callback
      f = new Foo()
      wrapped 'string', f
      @callback.calledWith('string', f, {}, ['one', 'two']).should.be.true

  describe '~wrapper', ->
    context 'called with a missing param', ->
      it 'should pass undefined as the first param', ->
        wrapped = $ 'sof', @callback
        obj = {}
        fn = ->
        wrapped obj, fn
        @callback.calledWith(undefined, obj, fn).should.be.true

      it 'should pass undefined as a middle param', ->
        wrapped = $ 'sof', @callback
        fn = ->
        wrapped 'string', fn
        @callback.calledWith('string', undefined, fn).should.be.true

      it 'should pass undefined as the last param', ->
        wrapped = $ 'sof', @callback
        obj = {}
        wrapped 'string', obj
        @callback.calledWith('string', obj, undefined).should.be.true

    context 'called with multiple missing params', ->
      it 'should accept two missing params next to each other', ->
        wrapped = $ 'sof', @callback
        fn = ->
        wrapped fn
        @callback.calledWith(undefined, undefined, fn).should.be.true

      it 'should accept two missing params not next to each other', ->
        wrapped = $ 'sof', @callback
        obj = {}
        wrapped obj
        @callback.calledWith(undefined, obj, undefined).should.be.true

      it 'should accept two missing params at the end', ->
        wrapped = $ 'sof', @callback
        wrapped 'string'
        @callback.calledWith('string', undefined, undefined).should.be.true

    context 'called with multiple params of the same type in a row', ->
      it 'should pass the first instance of that type', ->
        wrapped = $ 'off', @callback
        obj = {}
        fn = ->
        wrapped obj, fn
        @callback.calledWith(obj, fn, undefined).should.be.true

      it 'should allow overriding the default behavior with - on types', ->
        wrapped = $ 'Object', '-Function', 'Function', @callback
        obj = {}
        fn = ->
        wrapped obj, fn
        @callback.calledWith(obj, undefined, fn).should.be.true

      it 'should allow overriding the default behavior with - on abbreviations', ->
        wrapped = $ 'o-ff', @callback
        obj = {}
        fn = ->
        wrapped obj, fn
        @callback.calledWith(obj, undefined, fn).should.be.true

      it 'should allow multiple -\'s not next to each other', ->
        wrapped = $ ' -oo-ff', @callback
        obj = {}
        fn = ->
        wrapped obj, fn
        @callback.calledWith(undefined, obj, undefined, fn).should.be.true

      it 'should allow multiple -\'s next to each other', ->
        wrapped = $ 'f-A-AA', @callback
        fn = ->
        arr = []
        wrapped fn, arr
        @callback.calledWith(fn, undefined, undefined, arr).should.be.true

    context 'called more than once', ->
      it 'should allow multiple functions to be wrapped', ->
        @callback1 = sinon.spy()
        @callback2 = sinon.spy()
        wrapped1 = $ 'soA', @callback1
        wrapped2 = $ 'fed', @callback2
        obj = {}
        arr = []
        fn = ->
        e = new Error()
        date = new Date()
        wrapped1 'string', obj, arr
        wrapped2 fn, e, date
        @callback1.calledWith('string', obj, arr).should.be.true
        @callback2.calledWith(fn, e, date).should.be.true

      it 'should allow the same wrapper to be called more than once', ->
        wrapped = $ 'so', @callback
        wrapped 'string'
        obj = {}
        wrapped obj
        @callback.getCall(0).args[0].should.equal('string')
        should.equal(@callback.getCall(0).args[1], undefined)
        should.equal(@callback.getCall(1).args[0], undefined)
        @callback.getCall(1).args[1].should.equal(obj)

      it 'should keep the same options when configure is used', ->
        $.configure populate: ['Object']
        @callback2 = sinon.spy()
        wrapped1 = $ 'o', @callback
        wrapped2 = $ 'so', @callback2
        wrapped1()
        wrapped2 'string'
        @callback.calledWith({}).should.be.true
        @callback2.calledWith('string', {}).should.be.true

    context 'called with object expansion', ->
      it 'should convert s to \'\'', ->
        wrapped = $ 's+s', @callback
        wrapped 'string'
        @callback.calledWith('string', '').should.be.true

      it 'should convert String to \'\'', ->
        wrapped = $ 'String', '+String', @callback
        wrapped 'string'
        @callback.calledWith('string', '').should.be.true

      it 'should convert Function to ->', ->
        wrapped = $ 'String', '+Function', @callback
        wrapped 'string'
        @callback.args[0][0].should.equal('string')
        @callback.args[0][1].toString().should.equal('function (){}')

      it 'should convert f to ->', ->
        wrapped = $ 's+f', @callback
        wrapped 'string'
        @callback.args[0][0].should.equal('string')
        @callback.args[0][1].toString().should.equal('function (){}')

      it 'should convert o to {}', ->
        wrapped = $ 's+of', @callback
        fn = ->
        wrapped 'string', fn
        @callback.calledWith('string', {}, fn).should.be.true

      it 'should convert Object to {}', ->
        wrapped = $ 'String', '+Object', @callback
        wrapped 'string'
        @callback.calledWith('string', {}).should.be.true
        
      it 'should convert A to []', ->
        wrapped = $ 's+A', @callback
        wrapped 'string'
        @callback.calledWith('string', []).should.be.true

      it 'should convert Array to []', ->
        wrapped = $ 'String', '+Array', @callback
        wrapped 'string'
        @callback.calledWith('string', []).should.be.true

      it 'should convert Number to 0', ->
        wrapped = $ 'String', '+Number', @callback
        wrapped 'string'
        @callback.calledWith('string', 0).should.be.true

      it 'should convert 1 to 0', ->
        wrapped = $ 's+1', @callback
        wrapped 'string'
        @callback.calledWith('string', 0).should.be.true

      it 'should convert Boolean to false', ->
        wrapped = $ 'String', '+Boolean', @callback
        wrapped 'string'
        @callback.calledWith('string', false).should.be.true

      it 'should convert b to false', ->
        wrapped = $ 's+b', @callback
        wrapped 'string'
        @callback.calledWith('string', false).should.be.true

      it 'should convert RegExp to /.*/', ->
        wrapped = $ 'String', '+RegExp', @callback
        wrapped 'string'
        @callback.calledWith('string', /.*/).should.be.true

      it 'should convert r to []', ->
        wrapped = $ 's+r', @callback
        wrapped 'string'
        @callback.calledWith('string', /.*/).should.be.true

      it 'should convert Date to today\'s date', ->
        wrapped = $ 'String', '+Date', @callback
        d = new Date()
        wrapped 'string'
        @callback.args[0][0].should.equal('string')
        arg = @callback.args[0][1]
        arg.getDate().should.equal(d.getDate())
        arg.getMonth().should.equal(d.getMonth())
        arg.getFullYear().should.equal(d.getFullYear())

      it 'should convert d to today\'s date', ->
        wrapped = $ 's+d', @callback
        d = new Date()
        wrapped 'string'
        @callback.args[0][0].should.equal('string')
        arg = @callback.args[0][1]
        arg.getDate().should.equal(d.getDate())
        arg.getMonth().should.equal(d.getMonth())
        arg.getFullYear().should.equal(d.getFullYear())

      it 'should convert NaN to NaN', ->
        wrapped = $ 'String', '+NaN', @callback
        wrapped 'string'
        @callback.args[0][0].should.equal('string')
        @callback.args[0][1].should.be.NaN

      it 'should convert N to NaN', ->
        wrapped = $ 's+N', @callback
        wrapped 'string'
        @callback.args[0][0].should.equal('string')
        @callback.args[0][1].should.be.NaN

      it 'should convert Null to null', ->
        wrapped = $ 'String', '+Null', @callback
        wrapped 'string'
        @callback.calledWith('string', null).should.be.true

      it 'should convert n to null', ->
        wrapped = $ 's+n', @callback
        wrapped 'string'
        @callback.calledWith('string', null).should.be.true
        
      it 'should convert Undefined to undefined', ->
        wrapped = $ 'String', '+Undefined', @callback
        wrapped 'string'
        @callback.calledWith('string', undefined).should.be.true

      it 'should convert u to undefined', ->
        wrapped = $ 's+u', @callback
        wrapped 'string'
        @callback.calledWith('string', undefined).should.be.true

      it 'should convert Arguments to arguments', ->
        wrapped = $ 'String', '+Arguments', @callback
        wrapped 'string'
        @callback.args[0][0].should.equal('string')
        @callback.args[0][1].should.have.property('length')
        @callback.args[0][1].should.not.have.property('slice')
        should.equal(@callback.args[0][1][0], undefined)

      it 'should convert a to arguments', ->
        wrapped = $ 's+a', @callback
        wrapped 'string'
        @callback.args[0][0].should.equal('string')
        @callback.args[0][1].should.have.property('length')
        @callback.args[0][1].should.not.have.property('slice')
        should.equal(@callback.args[0][1][0], undefined)

      it 'should convert Infinity to Infinity', ->
        wrapped = $ 'String', '+Infinity', @callback
        wrapped 'string'
        @callback.calledWith('string', Infinity).should.be.true

      it 'should convert i to Infinity', ->
        wrapped = $ 's+i', @callback
        wrapped 'string'
        @callback.calledWith('string', Infinity).should.be.true

      it 'should convert Error to a new error', ->
        wrapped = $ 'String', '+Error', @callback
        wrapped 'string'
        @callback.args[0][0].should.equal('string')
        @callback.args[0][1].constructor.name.should.equal('Error')
        @callback.args[0][1].message.should.equal('')

      it 'should convert e to a new error', ->
        wrapped = $ 's+e', @callback
        wrapped 'string'
        @callback.args[0][0].should.equal('string')
        @callback.args[0][1].constructor.name.should.equal('Error')
        @callback.args[0][1].message.should.equal('')

      # TODO: How to spy on window.document?
      it 'should convert E to document', ->
        wrapped = $ 's+E', @callback
        wrapped 'string'
        @callback.calledWith('string', '<div></div>').should.be.true

      it 'should convert $ to $(document)', ->
        wrapped = $ 's+$', @callback
        wrapped 'string'
        @callback.calledWith('string', []).should.be.true

      it 'should work with - on different abbreviations', ->
        wrapped = $ 's-oo+A', @callback
        obj = {}
        wrapped 'string', obj
        @callback.calledWith('string', undefined, obj, []).should.be.true

      it 'should work with - on different types', ->
        wrapped = $ 'String', '-Object', 'Object', '+Array', @callback
        obj = {}
        wrapped 'string', obj
        @callback.calledWith('string', undefined, obj, []).should.be.true

      it 'should work with - on the same abbreviation', ->
        wrapped = $ 's-+oo', @callback
        obj =
          one: 1
          two: 2
        wrapped 'string', obj
        @callback.calledWith('string', {}, obj).should.be.true

      it 'should work with - on the same type', ->
        wrapped = $ 'String', '-+Object', 'Object', @callback
        obj =
          one: 1
          two: 2
        wrapped 'string', obj
        @callback.calledWith('string', {}, obj).should.be.true

      it 'should work with - the other way around', ->
        wrapped = $ 'String', '+-Object', 'Object', @callback
        obj =
          one: 1
          two: 2
        wrapped 'string', obj
        @callback.calledWith('string', {}, obj).should.be.true

    context 'called with non-empty indicator', ->
      it 'should expand an empty object', ->
        $.configure
          defaults:
            'Object':
              'not': 'empty'
        wrapped = $ 's_o', @callback
        wrapped 'string', {}
        @callback.calledWith('string', not: 'empty').should.be.true

      it 'should expand undefined', ->
        wrapped = $ 's_A', @callback
        wrapped 'string'
        @callback.calledWith('string', []).should.be.true

    context 'called with required indicator', ->
      it 'should throw an error if the required parameter is undefined', ->
        wrapped = $ '*String', @callback
        (->
          wrapped()
        ).should.throw('A required parameter was missing from the wrapped function')

      it 'should handle a required parameter followed by a non-required one', ->
        wrapped = $ ' *ss', @callback
        wrapped('string')
        @callback.calledWith('string', undefined).should.be.true

      it 'should handle a parameter followed by a required one (different types)', ->
        wrapped = $ ' *so', @callback
        (->
          wrapped {}
        ).should.throw('A required parameter was missing from the wrapped function')

      it 'should handle a parameter followed by a required one (same type)', ->
        wrapped = $ 's*s', @callback
        (->
          wrapped 'string'
        ).should.throw('A required parameter was missing from the wrapped function')

  describe '#reset', ->
    it 'should restore the defaults', ->
      callback2 = sinon.spy()
      $.configure
        letters:
          'A': 'Apples'
      wrapped = $ ' A', @callback
      wrapped []
      @callback.calledWith(undefined).should.be.true
      $.reset()
      wrapped2 = $ ' A', callback2
      arr = []
      wrapped2 arr
      callback2.calledWith(arr).should.be.true

  describe '#configure', ->
    context 'called with letters', ->
      it 'should add new letters', ->
        $.configure
          letters:
            'X': 'XtraLg'
        wrapped = $ ' Xo', @callback
        class XtraLg
        x = new XtraLg()
        obj = {}
        wrapped x, obj

      it 'should override changed letters', ->
        $.configure
          letters:
            'a': 'Array',
            'A': 'Arguments'
        wrapped = $ 'a', @callback
        arr = []
        wrapped arr
        @callback.calledWith(arr).should.be.true

    context 'called with defaults', ->
      it 'should allow new items', ->
        class Foo
        $.configure
          defaults:
           'Foo': ->
              return new Foo()
        wrapped = $ '+Foo', @callback
        wrapped()
        @callback.args[0][0].should.be.an.instanceOf(Foo)

      it 'should allow overrides', ->
        $.configure
          defaults:
            'Array': ['one', 'two']
        wrapped = $ '+Array', @callback
        wrapped()
        @callback.calledWith(['one', 'two']).should.be.true

    context 'called with populate', ->
      it 'should expand any missing params', ->
        $.configure
          populate: true
        wrapped = $ 'so', @callback
        wrapped 'string'
        @callback.calledWith('string', {}).should.be.true

      it 'should expand passed in param types', ->
        $.configure
          populate: ['Array', 'Object']
        wrapped = $ 'oAs', @callback
        wrapped()
        @callback.calledWith({}, [], undefined).should.be.true

    context 'called with a combination of options', ->
      it 'should be configured correctly', ->
        class FooBaby
          birth: ->
            return 'FOO BABY!'
        $.configure
          populate: ['Object', 'Date']
          defaults:
            'Date': ->
              return new Date(1999, 11, 31)
            'Error': ->
              return new Error('Mischief is afoot')
            'FooBaby': ->
              return new FooBaby().birth()
          letters:
            '~': 'FooBaby'
        wrapped = $ 'Object', 'Date', 'Error', '-+Error', ' +~', @callback
        wrapped()
        args = @callback.args[0]
        args[0].should.eql({})
        args[1].should.be.an.instanceOf(Date)
        args[1].getFullYear().should.equal(1999)
        args[1].getMonth().should.equal(11)
        args[1].getDate().should.equal(31)
        should.equal(args[2], undefined)
        args[3].should.be.an.instanceOf(Error)
        args[3].message.should.equal('Mischief is afoot')
        args[4].should.equal('FOO BABY!')
 
