should = require('should')
global.context = global.describe
varity = require('../lib/varity')
sinon = require('sinon')
_ = require('underscore')

describe 'varity', ->
  beforeEach ->
    @callback = sinon.spy()

  it 'should return a object with functions', ->
    varity.should.be.a.Object
    varity.wrap.should.be.a.Function

  describe '#wrap', ->
    it 'should wrap the passed function', ->
      wrapped = varity.wrap @callback
      wrapped.should.be.a.Function
      wrapped()
      @callback.called.should.be.true

    it 'should throw if passed no arguments', ->
      (->
        varity.wrap()
      ).should.throw('No function passed to varity')

    it 'should throw if the last argument is not a function', ->
      (->
        varity.wrap({})
      ).should.throw('Last argument is not a function')

    context 'called with string types', ->
      it 'should accept string', ->
        wrapped = varity.wrap 'string', @callback
        wrapped 'something'
        @callback.calledWith('something').should.be.true

      it 'should accept String', ->
        wrapped = varity.wrap 'String', @callback
        wrapped 'something'
        @callback.calledWith('something').should.be.true

      it 'should accept function', ->
        fn = sinon.spy()
        wrapped = varity.wrap 'function', @callback
        wrapped(fn)
        @callback.calledWith(fn).should.be.true

      it 'should accept Function', ->
        fn = sinon.spy()
        wrapped = varity.wrap 'Function', @callback
        wrapped(fn)
        @callback.calledWith(fn).should.be.true

      it 'should accept object', ->
        obj = fake: 'data'
        wrapped = varity.wrap 'object', @callback
        wrapped(obj)
        @callback.calledWith(obj).should.be.true

      it 'should accept Object', ->
        obj = fake: 'data'
        wrapped = varity.wrap 'Object', @callback
        wrapped(obj)
        @callback.calledWith(obj).should.be.true

      it 'should accept array', ->
        arr = [ 'one', 'two' ]
        wrapped = varity.wrap 'array', @callback
        wrapped(arr)
        @callback.calledWith(arr).should.be.true

      it 'should accept Array', ->
        arr = [ 'one', 'two' ]
        wrapped = varity.wrap 'Array', @callback
        wrapped(arr)
        @callback.calledWith(arr).should.be.true

      it 'should accept number', ->
        wrapped = varity.wrap 'number', @callback
        wrapped(2)
        @callback.calledWith(2).should.be.true

      it 'should accept Number', ->
        wrapped = varity.wrap 'Number', @callback
        wrapped(2)
        @callback.calledWith(2).should.be.true

      it 'should accept boolean', ->
        wrapped = varity.wrap 'boolean', @callback
        wrapped(true)
        @callback.calledWith(true).should.be.true

      it 'should accept Boolean', ->
        wrapped = varity.wrap 'Boolean', @callback
        wrapped(false)
        @callback.calledWith(false).should.be.true

      it 'should accept date', ->
        date = new Date()
        wrapped = varity.wrap 'date', @callback
        wrapped(date)
        @callback.calledWith(date).should.be.true

      it 'should accept Date', ->
        date = new Date()
        wrapped = varity.wrap 'Date', @callback
        wrapped(date)
        @callback.calledWith(date).should.be.true

      it 'should accept regexp', ->
        reg = new RegExp('.*')
        wrapped = varity.wrap 'regexp', @callback
        wrapped(reg)
        @callback.calledWith(reg).should.be.true

      it 'should accept Regexp', ->
        reg = new RegExp('.*')
        wrapped = varity.wrap 'Regexp', @callback
        wrapped(reg)
        @callback.calledWith(reg).should.be.true

      it 'should accept RegExp', ->
        reg = new RegExp('.*')
        wrapped = varity.wrap 'RegExp', @callback
        wrapped(reg)
        @callback.calledWith(reg).should.be.true

      it 'should accept nan', ->
        nan = NaN
        wrapped = varity.wrap 'nan', @callback
        wrapped(nan)
        # Checking truthy values of NaN is a pain
        @callback.args[0][0].should.be.NaN

      it 'should accept Nan', ->
        nan = NaN
        wrapped = varity.wrap 'Nan', @callback
        wrapped(nan)
        # Checking truthy values of NaN is a pain
        @callback.args[0][0].should.be.NaN

      it 'should accept NaN', ->
        nan = NaN
        wrapped = varity.wrap 'NaN', @callback
        wrapped(nan)
        # Checking truthy values of NaN is a pain
        @callback.args[0][0].should.be.NaN

      it 'should accept null', ->
        wrapped = varity.wrap 'null', @callback
        wrapped(null)
        @callback.calledWith(null).should.be.true

      it 'should accept Null', ->
        wrapped = varity.wrap 'Null', @callback
        wrapped(null)
        @callback.calledWith(null).should.be.true

      it 'should accept undefined', ->
        wrapped = varity.wrap 'undefined', @callback
        wrapped(undefined)
        @callback.calledWith(undefined).should.be.true

      it 'should accept Undefined', ->
        wrapped = varity.wrap 'Undefined', @callback
        wrapped(undefined)
        @callback.calledWith(undefined).should.be.true

      it 'should accept arguments', ->
        args = (->
          arguments
        ) 'one', 'two'
        wrapped = varity.wrap 'arguments', @callback
        wrapped(args)
        @callback.calledWith(args).should.be.true

      it 'should accept Arguments', ->
        args = (->
          arguments
        ) 'one', 'two'
        wrapped = varity.wrap 'Arguments', @callback
        wrapped(args)
        @callback.calledWith(args).should.be.true

      it 'should accept infinity', ->
        wrapped = varity.wrap 'infinity', @callback
        wrapped(Infinity)
        @callback.calledWith(Infinity).should.be.true

      it 'should accept Infinity', ->
        wrapped = varity.wrap 'Infinity', @callback
        wrapped(Infinity)
        @callback.calledWith(Infinity).should.be.true

      it 'should accept error', ->
        wrapped = varity.wrap 'error', @callback
        e = new Error()
        wrapped e
        @callback.calledWith(e).should.be.true
      
      it 'should accept Error', ->
        wrapped = varity.wrap 'Error', @callback
        e = new Error()
        wrapped e
        @callback.calledWith(e).should.be.true

      it 'should accept multiple string parameters', ->
        obj = {}
        arr = []
        fn = ->
        wrapped = varity.wrap 'string', 'object', 'array', 'function', @callback
        wrapped('something', obj, arr, fn)
        @callback.calledWith('something', obj, arr, fn).should.be.true

      it 'should accept multiple string parameters with duplicates', ->
        fn1 = ->
        fn2 = ->
        wrapped = varity.wrap 'function', 'function', @callback
        wrapped(fn1, fn2)
        @callback.calledWith(fn1, fn2).should.be.true

    context 'called with actual types', ->
      it 'should accept String', ->
        wrapped = varity.wrap String, @callback
        wrapped 'string'
        @callback.calledWith('string').should.be.true

      it 'should accept Function', ->
        wrapped = varity.wrap Function, @callback
        fn = ->
        wrapped fn
        @callback.calledWith(fn).should.be.true

      it 'should accept Object', ->
        wrapped = varity.wrap Object, @callback
        obj = {}
        wrapped obj
        @callback.calledWith(obj).should.be.true

      it 'should accept Array', ->
        wrapped = varity.wrap Array, @callback
        arr = []
        wrapped arr
        @callback.calledWith(arr).should.be.true

      it 'should accept Number', ->
        wrapped = varity.wrap Number, @callback
        wrapped 2
        @callback.calledWith(2).should.be.true

      it 'should accept Boolean', ->
        wrapped = varity.wrap Boolean, @callback
        wrapped true
        @callback.calledWith(true).should.be.true

      it 'should accept Date', ->
        wrapped = varity.wrap Date, @callback
        date = new Date()
        wrapped date
        @callback.calledWith(date).should.be.true

      it 'should accept RegExp', ->
        wrapped = varity.wrap RegExp, @callback
        reg = /.*/
        wrapped reg
        @callback.calledWith(reg).should.be.true

      it 'should accept Error', ->
        wrapped = varity.wrap Error, @callback
        e = new Error()
        wrapped e
        @callback.calledWith(e).should.be.true

      it 'should accept multiple type parameters', ->
        wrapped = varity.wrap String, Function, Object, Array, RegExp, Date, @callback
        fn = ->
        obj = {}
        arr = []
        reg = /.*/
        date = new Date()
        wrapped 'string', fn, obj, arr, reg, date
        @callback.calledWith('string', fn, obj, arr, reg, date).should.be.true

      it 'should accept multiple type parameters with duplicates', ->
        wrapped = varity.wrap Function, Array, Function, @callback
        fn1 = ->
        fn2 = ->
        arr = []
        wrapped fn1, arr, fn2
        @callback.calledWith(fn1, arr, fn2).should.be.true

    context 'called with special types', ->
      it 'should accept null', ->
        wrapped = varity.wrap null, @callback
        wrapped null
        @callback.calledWith(null).should.be.true

      it 'should accept undefined', ->
        wrapped = varity.wrap undefined, @callback
        wrapped undefined
        @callback.calledWith(undefined).should.be.true

      it 'should accept multiple special parameters', ->
        wrapped = varity.wrap null, undefined, @callback
        wrapped null, undefined
        @callback.calledWith(null, undefined).should.be.true

      it 'should accept multiple special parameters with duplicate', ->
        wrapped = varity.wrap null, null, undefined, null, @callback
        wrapped null, null, undefined, null
        @callback.calledWith(null, null, undefined, null).should.be.true

    context 'called with mixed types', ->
      it 'should accept any combination of types (part 1)', ->
        wrapped = varity.wrap 'string', Function, null, @callback
        fn = ->
        wrapped 'string', fn, null
        @callback.calledWith('string', fn, null).should.be.true

      it 'should accept any combination of types (part 2)', ->
        wrapped = varity.wrap 'string', Function, Function, 'object', Object, null, undefined, Date, 'regexp', @callback
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
        wrapped = varity.wrap ['string', 'object'], @callback
        obj = {}
        wrapped 'string', obj
        @callback.calledWith('string', obj).should.be.true

      it 'should accept an array of type parameters', ->
        wrapped = varity.wrap [Date, RegExp], @callback
        date = new Date()
        reg = /.*/
        wrapped date, reg
        @callback.calledWith(date, reg).should.be.true

      it 'should accept an array of special parameters', ->
        wrapped = varity.wrap [null, undefined, null], @callback
        wrapped null, undefined, null
        @callback.calledWith(null, undefined, null).should.be.true

      it 'should accept an array of mixed parameters', ->
        wrapped = varity.wrap [null, 'string', Object, 'date', Function], @callback
        obj = {}
        date = new Date()
        fn = ->
        wrapped null, 'string', obj, date, fn
        @callback.calledWith(null, 'string', obj, date, fn).should.be.true

      it 'should flatten an array of arrays with parameters', ->
        wrapped = varity.wrap [['string', 'function'], ['object']], @callback
        fn = ->
        obj = {}
        wrapped 'string', fn, obj
        @callback.calledWith('string', fn, obj).should.be.true

    context 'called with regular parameters and an array', ->
      it 'should accept parameters with a single array', ->
        wrapped = varity.wrap 'string', [Object, Function], @callback
        fn = ->
        obj = {}
        wrapped 'string', obj, fn
        @callback.calledWith('string', obj, fn).should.be.true

      it 'should accept parameters with more than one array', ->
        wrapped = varity.wrap [Array, Date], 'object', [undefined, 'infinity'], @callback
        arr = []
        date = new Date()
        obj = {}
        inf = Infinity
        wrapped arr, date, obj, undefined, inf
        @callback.calledWith(arr, date, obj, undefined, inf).should.be.true

    context 'called with string abbreviations', ->
      it 'should accept s', ->
        wrapped = varity.wrap 's', @callback
        wrapped 'string'
        @callback.calledWith('string').should.be.true

      it 'should accept f', ->
        wrapped = varity.wrap 'f', @callback
        fn = ->
        wrapped fn
        @callback.calledWith(fn).should.be.true

      it 'should accept o', ->
        wrapped = varity.wrap 'o', @callback
        obj = {}
        wrapped obj
        @callback.calledWith(obj).should.be.true

      it 'should accept A', ->
        wrapped = varity.wrap ' A', @callback
        arr = []
        wrapped arr
        @callback.calledWith(arr).should.be.true

      it 'should accept 1', ->
        wrapped = varity.wrap '1', @callback
        wrapped 2
        @callback.calledWith(2).should.be.true

      it 'should accept b', ->
        wrapped = varity.wrap 'b', @callback
        wrapped true
        @callback.calledWith(true).should.be.true

      it 'should accept d', ->
        wrapped = varity.wrap 'd', @callback
        date = new Date()
        wrapped date
        @callback.calledWith(date).should.be.true

      it 'should accept r', ->
        wrapped = varity.wrap 'r', @callback
        reg = /.*/
        wrapped reg
        @callback.calledWith(reg).should.be.true

      it 'should accept N', ->
        wrapped = varity.wrap ' N', @callback
        wrapped NaN
        @callback.args[0][0].should.be.NaN

      it 'should accept n', ->
        wrapped = varity.wrap 'n', @callback
        wrapped null
        @callback.calledWith(null).should.be.true

      it 'should accept u', ->
        wrapped = varity.wrap 'u', @callback
        wrapped undefined
        @callback.calledWith(undefined).should.be.true

      it 'should accept a', ->
        wrapped = varity.wrap 'a', @callback
        args = (->
          arguments
        ) 'one', 'two'
        wrapped args
        @callback.calledWith(args).should.be.true

      it 'should accept i', ->
        wrapped = varity.wrap 'i', @callback
        wrapped Infinity
        @callback.calledWith(Infinity).should.be.true

      it 'should accept e', ->
        wrapped = varity.wrap 'e', @callback
        e = new Error()
        wrapped e
        @callback.calledWith(e).should.be.true

      it 'should accept a mix of letters', ->
        wrapped = varity.wrap 'sfo1ne', @callback
        fn = ->
        obj = {}
        e = new Error()
        wrapped 'string', fn, obj, 2, null, e
        @callback.calledWith('string', fn, obj, 2, null, e).should.be.true

      it 'should accept a string with a space at the front', ->
        wrapped = varity.wrap ' Ao', @callback
        arr = []
        obj = {}
        wrapped arr, obj
        @callback.calledWith(arr, obj).should.be.true

      it 'should not accept other letters', ->
        callback = @callback
        (->
          varity.wrap '9', callback
        ).should.throw('Unrecognized type: 9')

    context 'called with custom types', ->
      it 'should accept those types', ->
        class Foo
        wrapped = varity.wrap 'Foo', @callback
        f = new Foo()
        wrapped f
        @callback.calledWith(f).should.be.true

      it 'should accept multiple custom types', ->
        class Foo
        class Bar
        wrapped = varity.wrap 'Foo', 'Bar', @callback
        f = new Foo()
        b = new Bar()
        wrapped f, b
        @callback.calledWith(f, b).should.be.true

      it 'should accept camel case object names', ->
        class FooBaby
        wrapped = varity.wrap 'FooBaby', @callback
        fb = new FooBaby()
        wrapped fb
        @callback.calledWith(fb).should.be.true

      it 'should accept custom types with normal types', ->
        class Foo
        wrapped = varity.wrap 'oAs', 'Foo', @callback
        obj = {}
        arr = []
        f = new Foo
        wrapped obj, arr, 'string', f
        @callback.calledWith(obj, arr, 'string', f).should.be.true

    context 'called with an object', ->
      it 'should accept a string type', ->
        wrapped = varity.wrap
          type: 'Array'
        , @callback
        arr = []
        wrapped arr
        @callback.calledWith(arr).should.be.true

      it 'should convert Object to AnonObject', ->
        wrapped = varity.wrap
          type: 'Object'
        , @callback
        obj = {}
        wrapped obj
        @callback.calledWith(obj).should.be.true

      it 'should convert Regexp to RegExp', ->
        wrapped = varity.wrap
          type: 'Regexp'
        , @callback
        reg = /.*/
        wrapped reg
        @callback.calledWith(reg).should.be.true

      it 'should convert Nan to NaN', ->
        wrapped = varity.wrap
          type: 'NaN'
        , @callback
        wrapped NaN
        @callback.args[0][0].should.be.NaN

      it 'should accept a real type', ->
        wrapped = varity.wrap
          type: Function
        , @callback
        fn = ->
        wrapped fn
        @callback.calledWith(fn).should.be.true

      it 'should accept optional', ->
        wrapped = varity.wrap
          type: 'Object'
          optional: true
        ,
          type: 'Object'
        , @callback
        obj = {}
        wrapped obj
        @callback.calledWith(undefined, {}).should.be.true

      it 'should accept expand', ->
        wrapped = varity.wrap
          type: 'Object',
          expand: true
        , @callback
        wrapped()
        @callback.calledWith({}).should.be.true

      it 'should accept expand and optional', ->
        wrapped = varity.wrap
          type: 'Object'
          optional: 'true',
          expand: 'true'
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
        wrapped = varity.wrap
          type: 'Foo'
          expand: true
          default: ->
            return new Foo()
        , @callback
        wrapped()
        @callback.args[0][0].should.be.an.instanceOf(Foo)

      it 'should accept default on custom real types', ->
        class Foo
        wrapped = varity.wrap
          type: Foo
          expand: true
          default: ->
            return new Foo()
        , @callback
        wrapped()
        @callback.args[0][0].should.be.an.instanceOf(Foo)

      it 'should accept default on built in types', ->
        wrapped = varity.wrap
          type: 'Object'
          expand: true
          default: ->
            return one: 1
        , @callback
        wrapped()
        @callback.calledWith(one: 1).should.be.true

      it 'should accept a mix of objects', ->
        wrapped = varity.wrap
          type: 'Array'
        ,
          type: 'Object'
          optional: 'true'
        ,
          type: 'Object'
        ,
          type: 'String'
          expand: 'true'
        , @callback
        arr = []
        obj = one: 1
        wrapped arr, obj
        @callback.calledWith(arr, undefined, obj, '').should.be.true

      it 'should accept objects with other parameters', ->
        wrapped = varity.wrap 's-o', Object,
          type: 'Array',
          expand: true
          default: -> ['one', 'two']
        , [ '-+String', 'String']
        , @callback
        obj = one: 1
        wrapped 'string1', obj, 'string2'
        @callback.calledWith('string1', undefined, obj, ['one', 'two'], '', 'string2').should.be.true

  describe '~wrapper', ->
    context 'called with a missing param', ->
      it 'should pass undefined as the first param', ->
        wrapped = varity.wrap 'sof', @callback
        obj = {}
        fn = ->
        wrapped obj, fn
        @callback.calledWith(undefined, obj, fn).should.be.true

      it 'should pass undefined as a middle param', ->
        wrapped = varity.wrap 'sof', @callback
        fn = ->
        wrapped 'string', fn
        @callback.calledWith('string', undefined, fn).should.be.true

      it 'should pass undefined as the last param', ->
        wrapped = varity.wrap 'sof', @callback
        obj = {}
        wrapped 'string', obj
        @callback.calledWith('string', obj, undefined).should.be.true

    context 'called with multiple missing params', ->
      it 'should accept two missing params next to each other', ->
        wrapped = varity.wrap 'sof', @callback
        fn = ->
        wrapped fn
        @callback.calledWith(undefined, undefined, fn).should.be.true

      it 'should accept two missing params not next to each other', ->
        wrapped = varity.wrap 'sof', @callback
        obj = {}
        wrapped obj
        @callback.calledWith(undefined, obj, undefined).should.be.true

      it 'should accept two missing params at the end', ->
        wrapped = varity.wrap 'sof', @callback
        wrapped 'string'
        @callback.calledWith('string', undefined, undefined).should.be.true

    context 'called with multiple params of the same type in a row', ->
      it 'should pass the first instance of that type', ->
        wrapped = varity.wrap 'off', @callback
        obj = {}
        fn = ->
        wrapped obj, fn
        @callback.calledWith(obj, fn, undefined).should.be.true

      it 'should allow overriding the default behavior with - on types', ->
        wrapped = varity.wrap 'Object', '-Function', 'Function', @callback
        obj = {}
        fn = ->
        wrapped obj, fn
        @callback.calledWith(obj, undefined, fn).should.be.true

      it 'should allow overriding the default behavior with - on abbreviations', ->
        wrapped = varity.wrap 'o-ff', @callback
        obj = {}
        fn = ->
        wrapped obj, fn
        @callback.calledWith(obj, undefined, fn).should.be.true

      it 'should allow multiple -\'s not next to each other', ->
        wrapped = varity.wrap ' -oo-ff', @callback
        obj = {}
        fn = ->
        wrapped obj, fn
        @callback.calledWith(undefined, obj, undefined, fn).should.be.true

      it 'should allow multiple -\'s next to each other', ->
        wrapped = varity.wrap 'f-A-AA', @callback
        fn = ->
        arr = []
        wrapped fn, arr
        @callback.calledWith(fn, undefined, undefined, arr).should.be.true

    context 'called more than once', ->
      it 'should reset expectations and work correctly', ->
        @callback1 = sinon.spy()
        @callback2 = sinon.spy()
        wrapped1 = varity.wrap 'soA', @callback1
        wrapped2 = varity.wrap 'fed', @callback2
        obj = {}
        arr = []
        fn = ->
        e = new Error()
        date = new Date()
        wrapped1 'string', obj, arr
        wrapped2 fn, e, date
        @callback1.calledWith('string', obj, arr).should.be.true
        @callback2.calledWith(fn, e, date).should.be.true

    context 'called with object expansion', ->
      it 'should convert s to \'\'', ->
        wrapped = varity.wrap 's+s', @callback
        wrapped 'string'
        @callback.calledWith('string', '').should.be.true

      it 'should convert String to \'\'', ->
        wrapped = varity.wrap 'String', '+String', @callback
        wrapped 'string'
        @callback.calledWith('string', '').should.be.true

      it 'should convert Function to ->', ->
        wrapped = varity.wrap 'String', '+Function', @callback
        wrapped 'string'
        @callback.args[0][0].should.equal('string')
        @callback.args[0][1].toString().should.equal('function (){}')

      it 'should convert f to ->', ->
        wrapped = varity.wrap 's+f', @callback
        wrapped 'string'
        @callback.args[0][0].should.equal('string')
        @callback.args[0][1].toString().should.equal('function (){}')

      it 'should convert o to {}', ->
        wrapped = varity.wrap 's+of', @callback
        fn = ->
        wrapped 'string', fn
        @callback.calledWith('string', {}, fn).should.be.true

      it 'should convert Object to {}', ->
        wrapped = varity.wrap 'String', '+Object', @callback
        wrapped 'string'
        @callback.calledWith('string', {}).should.be.true
        
      it 'should convert A to []', ->
        wrapped = varity.wrap 's+A', @callback
        wrapped 'string'
        @callback.calledWith('string', []).should.be.true

      it 'should convert Array to []', ->
        wrapped = varity.wrap 'String', '+Array', @callback
        wrapped 'string'
        @callback.calledWith('string', []).should.be.true

      it 'should convert Number to 0', ->
        wrapped = varity.wrap 'String', '+Number', @callback
        wrapped 'string'
        @callback.calledWith('string', 0).should.be.true

      it 'should convert 1 to 0', ->
        wrapped = varity.wrap 's+1', @callback
        wrapped 'string'
        @callback.calledWith('string', 0).should.be.true

      it 'should convert Boolean to false', ->
        wrapped = varity.wrap 'String', '+Boolean', @callback
        wrapped 'string'
        @callback.calledWith('string', false).should.be.true

      it 'should convert b to false', ->
        wrapped = varity.wrap 's+b', @callback
        wrapped 'string'
        @callback.calledWith('string', false).should.be.true

      it 'should convert RegExp to /.*/', ->
        wrapped = varity.wrap 'String', '+RegExp', @callback
        wrapped 'string'
        @callback.calledWith('string', /.*/).should.be.true

      it 'should convert r to []', ->
        wrapped = varity.wrap 's+r', @callback
        wrapped 'string'
        @callback.calledWith('string', /.*/).should.be.true

      it 'should convert Date to today\'s date', ->
        wrapped = varity.wrap 'String', '+Date', @callback
        d = new Date()
        wrapped 'string'
        @callback.args[0][0].should.equal('string')
        arg = @callback.args[0][1]
        arg.getDate().should.equal(d.getDate())
        arg.getMonth().should.equal(d.getMonth())
        arg.getFullYear().should.equal(d.getFullYear())

      it 'should convert d to today\'s date', ->
        wrapped = varity.wrap 's+d', @callback
        d = new Date()
        wrapped 'string'
        @callback.args[0][0].should.equal('string')
        arg = @callback.args[0][1]
        arg.getDate().should.equal(d.getDate())
        arg.getMonth().should.equal(d.getMonth())
        arg.getFullYear().should.equal(d.getFullYear())

      it 'should convert NaN to NaN', ->
        wrapped = varity.wrap 'String', '+NaN', @callback
        wrapped 'string'
        @callback.args[0][0].should.equal('string')
        @callback.args[0][1].should.be.NaN

      it 'should convert N to NaN', ->
        wrapped = varity.wrap 's+N', @callback
        wrapped 'string'
        @callback.args[0][0].should.equal('string')
        @callback.args[0][1].should.be.NaN

      it 'should convert Null to null', ->
        wrapped = varity.wrap 'String', '+Null', @callback
        wrapped 'string'
        @callback.calledWith('string', null).should.be.true

      it 'should convert n to null', ->
        wrapped = varity.wrap 's+n', @callback
        wrapped 'string'
        @callback.calledWith('string', null).should.be.true
        
      it 'should convert Undefined to undefined', ->
        wrapped = varity.wrap 'String', '+Undefined', @callback
        wrapped 'string'
        @callback.calledWith('string', undefined).should.be.true

      it 'should convert u to undefined', ->
        wrapped = varity.wrap 's+u', @callback
        wrapped 'string'
        @callback.calledWith('string', undefined).should.be.true

      it 'should convert Arguments to arguments', ->
        wrapped = varity.wrap 'String', '+Arguments', @callback
        wrapped 'string'
        @callback.args[0][0].should.equal('string')
        @callback.args[0][1].should.have.property('length')
        @callback.args[0][1].should.not.have.property('slice')
        should.equal(@callback.args[0][1][0], undefined)

      it 'should convert a to arguments', ->
        wrapped = varity.wrap 's+a', @callback
        wrapped 'string'
        @callback.args[0][0].should.equal('string')
        @callback.args[0][1].should.have.property('length')
        @callback.args[0][1].should.not.have.property('slice')
        should.equal(@callback.args[0][1][0], undefined)

      it 'should convert Infinity to Infinity', ->
        wrapped = varity.wrap 'String', '+Infinity', @callback
        wrapped 'string'
        @callback.calledWith('string', Infinity).should.be.true

      it 'should convert i to Infinity', ->
        wrapped = varity.wrap 's+i', @callback
        wrapped 'string'
        @callback.calledWith('string', Infinity).should.be.true

      it 'should convert Error to a new error', ->
        wrapped = varity.wrap 'String', '+Error', @callback
        wrapped 'string'
        @callback.args[0][0].should.equal('string')
        @callback.args[0][1].constructor.name.should.equal('Error')
        @callback.args[0][1].message.should.equal('')

      it 'should convert e to a new error', ->
        wrapped = varity.wrap 's+e', @callback
        wrapped 'string'
        @callback.args[0][0].should.equal('string')
        @callback.args[0][1].constructor.name.should.equal('Error')
        @callback.args[0][1].message.should.equal('')

      it 'should work with - on different abbreviations', ->
        wrapped = varity.wrap 's-oo+A', @callback
        obj = {}
        wrapped 'string', obj
        @callback.calledWith('string', undefined, obj, []).should.be.true

      it 'should work with - on different types', ->
        wrapped = varity.wrap 'String', '-Object', 'Object', '+Array', @callback
        obj = {}
        wrapped 'string', obj
        @callback.calledWith('string', undefined, obj, []).should.be.true

      it 'should work with - on the same abbreviation', ->
        wrapped = varity.wrap 's-+oo', @callback
        obj =
          one: 1
          two: 2
        wrapped 'string', obj
        @callback.calledWith('string', {}, obj).should.be.true

      it 'should work with - on the same type', ->
        wrapped = varity.wrap 'String', '-+Object', 'Object', @callback
        obj =
          one: 1
          two: 2
        wrapped 'string', obj
        @callback.calledWith('string', {}, obj).should.be.true

      it 'should work with - the other way around', ->
        wrapped = varity.wrap 'String', '+-Object', 'Object', @callback
        obj =
          one: 1
          two: 2
        wrapped 'string', obj
        @callback.calledWith('string', {}, obj).should.be.true

  describe '#reset', ->
    it 'should restore the defaults', ->
      callback2 = sinon.spy()
      varity.configure
        letters:
          'A': 'Apples'
      wrapped = varity.wrap ' A', @callback
      wrapped []
      @callback.calledWith(undefined).should.be.true
      varity.reset()
      wrapped2 = varity.wrap ' A', callback2
      arr = []
      wrapped2 arr
      callback2.calledWith(arr).should.be.true

  describe '#configure', ->
    afterEach ->
      varity.reset()

    context 'called with letters', ->
      it 'should add new letters', ->
        varity.configure
          letters:
            'X': 'XtraLg'
        wrapped = varity.wrap ' Xo', @callback
        class XtraLg
        x = new XtraLg()
        obj = {}
        wrapped x, obj

      it 'should override changed letters', ->
        varity.configure
          letters:
            'a': 'Array',
            'A': 'Arguments'
        wrapped = varity.wrap 'a', @callback
        arr = []
        wrapped arr
        @callback.calledWith(arr).should.be.true

    context 'called with populate', ->
      it 'should allow new items', ->
        class Foo
        varity.configure
          populate:
           'Foo': ->
              return new Foo()
        wrapped = varity.wrap '+Foo', @callback
        wrapped()
        @callback.args[0][0].should.be.an.instanceOf(Foo)

      it 'should allow overrides', ->
        varity.configure
          populate:
            'Array': ['one', 'two']
        wrapped = varity.wrap '+Array', @callback
        wrapped()
        @callback.calledWith(['one', 'two']).should.be.true
