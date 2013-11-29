should = require('should')
global.context = global.describe
varity = require('../lib/varity')
sinon = require('sinon')
_ = require('underscore')

describe 'varity', ->
  it 'should return a object with functions', ->
    varity.should.be.a.Object
    varity.wrap.should.be.a.Function

  describe '#wrap', ->
    it 'should wrap the passed function', ->
      callback = sinon.spy()
      wrapped = varity.wrap callback
      wrapped.should.be.a.Function
      wrapped()
      callback.called.should.be.true

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
        callback = sinon.spy()
        wrapped = varity.wrap 'string', callback
        wrapped 'something'
        callback.calledWith('something').should.be.true

      it 'should accept String', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'String', callback
        wrapped 'something'
        callback.calledWith('something').should.be.true

      it 'should accept function', ->
        callback = sinon.spy()
        fn = sinon.spy()
        wrapped = varity.wrap 'function', callback
        wrapped(fn)
        callback.calledWith(fn).should.be.true

      it 'should accept Function', ->
        callback = sinon.spy()
        fn = sinon.spy()
        wrapped = varity.wrap 'Function', callback
        wrapped(fn)
        callback.calledWith(fn).should.be.true

      it 'should accept object', ->
        callback = sinon.spy()
        obj = fake: 'data'
        wrapped = varity.wrap 'object', callback
        wrapped(obj)
        callback.calledWith(obj).should.be.true

      it 'should accept Object', ->
        callback = sinon.spy()
        obj = fake: 'data'
        wrapped = varity.wrap 'Object', callback
        wrapped(obj)
        callback.calledWith(obj).should.be.true

      it 'should accept array', ->
        callback = sinon.spy()
        arr = [ 'one', 'two' ]
        wrapped = varity.wrap 'array', callback
        wrapped(arr)
        callback.calledWith(arr).should.be.true

      it 'should accept Array', ->
        callback = sinon.spy()
        arr = [ 'one', 'two' ]
        wrapped = varity.wrap 'Array', callback
        wrapped(arr)
        callback.calledWith(arr).should.be.true

      it 'should accept number', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'number', callback
        wrapped(2)
        callback.calledWith(2).should.be.true

      it 'should accept Number', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'Number', callback
        wrapped(2)
        callback.calledWith(2).should.be.true

      it 'should accept boolean', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'boolean', callback
        wrapped(true)
        callback.calledWith(true).should.be.true

      it 'should accept Boolean', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'Boolean', callback
        wrapped(false)
        callback.calledWith(false).should.be.true

      it 'should accept date', ->
        callback = sinon.spy()
        date = new Date()
        wrapped = varity.wrap 'date', callback
        wrapped(date)
        callback.calledWith(date).should.be.true

      it 'should accept Date', ->
        callback = sinon.spy()
        date = new Date()
        wrapped = varity.wrap 'Date', callback
        wrapped(date)
        callback.calledWith(date).should.be.true

      it 'should accept regexp', ->
        callback = sinon.spy()
        reg = new RegExp('.*')
        wrapped = varity.wrap 'regexp', callback
        wrapped(reg)
        callback.calledWith(reg).should.be.true

      it 'should accept Regexp', ->
        callback = sinon.spy()
        reg = new RegExp('.*')
        wrapped = varity.wrap 'Regexp', callback
        wrapped(reg)
        callback.calledWith(reg).should.be.true

      it 'should accept RegExp', ->
        callback = sinon.spy()
        reg = new RegExp('.*')
        wrapped = varity.wrap 'RegExp', callback
        wrapped(reg)
        callback.calledWith(reg).should.be.true

      it 'should accept nan', ->
        callback = sinon.spy()
        nan = NaN
        wrapped = varity.wrap 'nan', callback
        wrapped(nan)
        # Checking truthy values of NaN is a pain
        callback.args[0][0].should.be.NaN

      it 'should accept Nan', ->
        callback = sinon.spy()
        nan = NaN
        wrapped = varity.wrap 'Nan', callback
        wrapped(nan)
        # Checking truthy values of NaN is a pain
        callback.args[0][0].should.be.NaN

      it 'should accept NaN', ->
        callback = sinon.spy()
        nan = NaN
        wrapped = varity.wrap 'NaN', callback
        wrapped(nan)
        # Checking truthy values of NaN is a pain
        callback.args[0][0].should.be.NaN

      it 'should accept null', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'null', callback
        wrapped(null)
        callback.calledWith(null).should.be.true

      it 'should accept Null', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'Null', callback
        wrapped(null)
        callback.calledWith(null).should.be.true

      it 'should accept undefined', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'undefined', callback
        wrapped(undefined)
        callback.calledWith(undefined).should.be.true

      it 'should accept Undefined', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'Undefined', callback
        wrapped(undefined)
        callback.calledWith(undefined).should.be.true

      it 'should accept arguments', ->
        args = (->
          arguments
        ) 'one', 'two'
        callback = sinon.spy()
        wrapped = varity.wrap 'arguments', callback
        wrapped(args)
        callback.calledWith(args).should.be.true

      it 'should accept Arguments', ->
        args = (->
          arguments
        ) 'one', 'two'
        callback = sinon.spy()
        wrapped = varity.wrap 'Arguments', callback
        wrapped(args)
        callback.calledWith(args).should.be.true

      it 'should accept infinity', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'infinity', callback
        wrapped(Infinity)
        callback.calledWith(Infinity).should.be.true

      it 'should accept Infinity', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'Infinity', callback
        wrapped(Infinity)
        callback.calledWith(Infinity).should.be.true

      it 'should accept error', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'error', callback
        e = new Error()
        wrapped e
        callback.calledWith(e).should.be.true
      
      it 'should accept Error', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'Error', callback
        e = new Error()
        wrapped e
        callback.calledWith(e).should.be.true

      it 'should accept multiple string parameters', ->
        callback = sinon.spy()
        obj = {}
        arr = []
        fn = ->
        wrapped = varity.wrap 'string', 'object', 'array', 'function', callback
        wrapped('something', obj, arr, fn)
        callback.calledWith('something', obj, arr, fn).should.be.true

      it 'should accept multiple string parameters with duplicates', ->
        callback = sinon.spy()
        fn1 = ->
        fn2 = ->
        wrapped = varity.wrap 'function', 'function', callback
        wrapped(fn1, fn2)
        callback.calledWith(fn1, fn2).should.be.true

    context 'called with actual types', ->
      it 'should accept String', ->
        callback = sinon.spy()
        wrapped = varity.wrap String, callback
        wrapped 'string'
        callback.calledWith('string').should.be.true

      it 'should accept Function', ->
        callback = sinon.spy()
        wrapped = varity.wrap Function, callback
        fn = ->
        wrapped fn
        callback.calledWith(fn).should.be.true

      it 'should accept Object', ->
        callback = sinon.spy()
        wrapped = varity.wrap Object, callback
        obj = {}
        wrapped obj
        callback.calledWith(obj).should.be.true

      it 'should accept Array', ->
        callback = sinon.spy()
        wrapped = varity.wrap Array, callback
        arr = []
        wrapped arr
        callback.calledWith(arr).should.be.true

      it 'should accept Number', ->
        callback = sinon.spy()
        wrapped = varity.wrap Number, callback
        wrapped 2
        callback.calledWith(2).should.be.true

      it 'should accept Boolean', ->
        callback = sinon.spy()
        wrapped = varity.wrap Boolean, callback
        wrapped true
        callback.calledWith(true).should.be.true

      it 'should accept Date', ->
        callback = sinon.spy()
        wrapped = varity.wrap Date, callback
        date = new Date()
        wrapped date
        callback.calledWith(date).should.be.true

      it 'should accept RegExp', ->
        callback = sinon.spy()
        wrapped = varity.wrap RegExp, callback
        reg = /.*/
        wrapped reg
        callback.calledWith(reg).should.be.true

      it 'should accept Error', ->
        callback = sinon.spy()
        wrapped = varity.wrap Error, callback
        e = new Error()
        wrapped e
        callback.calledWith(e).should.be.true

      it 'should accept multiple type parameters', ->
        callback = sinon.spy()
        wrapped = varity.wrap String, Function, Object, Array, RegExp, Date, callback
        fn = ->
        obj = {}
        arr = []
        reg = /.*/
        date = new Date()
        wrapped 'string', fn, obj, arr, reg, date
        callback.calledWith('string', fn, obj, arr, reg, date).should.be.true

      it 'should accept multiple type parameters with duplicates', ->
        callback = sinon.spy()
        wrapped = varity.wrap Function, Array, Function, callback
        fn1 = ->
        fn2 = ->
        arr = []
        wrapped fn1, arr, fn2
        callback.calledWith(fn1, arr, fn2).should.be.true

    context 'called with special types', ->
      it 'should accept null', ->
        callback = sinon.spy()
        wrapped = varity.wrap null, callback
        wrapped null
        callback.calledWith(null).should.be.true

      it 'should accept undefined', ->
        callback = sinon.spy()
        wrapped = varity.wrap undefined, callback
        wrapped undefined
        callback.calledWith(undefined).should.be.true

      it 'should accept multiple special parameters', ->
        callback = sinon.spy()
        wrapped = varity.wrap null, undefined, callback
        wrapped null, undefined
        callback.calledWith(null, undefined).should.be.true

      it 'should accept multiple special parameters with duplicate', ->
        callback = sinon.spy()
        wrapped = varity.wrap null, null, undefined, null, callback
        wrapped null, null, undefined, null
        callback.calledWith(null, null, undefined, null).should.be.true

    context 'called with mixed types', ->
      it 'should accept any combination of types (part 1)', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'string', Function, null, callback
        fn = ->
        wrapped 'string', fn, null
        callback.calledWith('string', fn, null).should.be.true

      it 'should accept any combination of types (part 2)', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'string', Function, Function, 'object', Object, null, undefined, Date, 'regexp', callback
        fn1 = ->
        fn2 = ->
        obj1 = {}
        obj2 = {}
        date = new Date()
        reg = /.*/
        wrapped 'string', fn1, fn2, obj1, obj2, null, undefined, date, reg
        callback.calledWith('string', fn1, fn2, obj1, obj2, null, undefined, date, reg).should.be.true

    context 'called with an array', ->
      it 'should accept an array of string parameters', ->
        callback = sinon.spy()
        wrapped = varity.wrap ['string', 'object'], callback
        obj = {}
        wrapped 'string', obj
        callback.calledWith('string', obj).should.be.true

      it 'should accept an array of type parameters', ->
        callback = sinon.spy()
        wrapped = varity.wrap [Date, RegExp], callback
        date = new Date()
        reg = /.*/
        wrapped date, reg
        callback.calledWith(date, reg).should.be.true

      it 'should accept an array of special parameters', ->
        callback = sinon.spy()
        wrapped = varity.wrap [null, undefined, null], callback
        wrapped null, undefined, null
        callback.calledWith(null, undefined, null).should.be.true

      it 'should accept an array of mixed parameters', ->
        callback = sinon.spy()
        wrapped = varity.wrap [null, 'string', Object, 'date', Function], callback
        obj = {}
        date = new Date()
        fn = ->
        wrapped null, 'string', obj, date, fn
        callback.calledWith(null, 'string', obj, date, fn).should.be.true

      it 'should flatten an array of arrays with parameters', ->
        callback = sinon.spy()
        wrapped = varity.wrap [['string', 'function'], ['object']], callback
        fn = ->
        obj = {}
        wrapped 'string', fn, obj
        callback.calledWith('string', fn, obj).should.be.true

    context 'called with regular parameters and an array', ->
      it 'should accept parameters with a single array', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'string', [Object, Function], callback
        fn = ->
        obj = {}
        wrapped 'string', obj, fn
        callback.calledWith('string', obj, fn).should.be.true

      it 'should accept parameters with more than one array', ->
        callback = sinon.spy()
        wrapped = varity.wrap [Array, Date], 'object', [undefined, 'infinity'], callback
        arr = []
        date = new Date()
        obj = {}
        inf = Infinity
        wrapped arr, date, obj, undefined, inf
        callback.calledWith(arr, date, obj, undefined, inf).should.be.true

    context 'called with string abbreviations', ->
      it 'should accept s', ->
        callback = sinon.spy()
        wrapped = varity.wrap 's', callback
        wrapped 'string'
        callback.calledWith('string').should.be.true

      it 'should accept f', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'f', callback
        fn = ->
        wrapped fn
        callback.calledWith(fn).should.be.true

      it 'should accept o', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'o', callback
        obj = {}
        wrapped obj
        callback.calledWith(obj).should.be.true

      it 'should accept A', ->
        callback = sinon.spy()
        wrapped = varity.wrap ' A', callback
        arr = []
        wrapped arr
        callback.calledWith(arr).should.be.true

      it 'should accept 1', ->
        callback = sinon.spy()
        wrapped = varity.wrap '1', callback
        wrapped 2
        callback.calledWith(2).should.be.true

      it 'should accept b', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'b', callback
        wrapped true
        callback.calledWith(true).should.be.true

      it 'should accept d', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'd', callback
        date = new Date()
        wrapped date
        callback.calledWith(date).should.be.true

      it 'should accept r', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'r', callback
        reg = /.*/
        wrapped reg
        callback.calledWith(reg).should.be.true

      it 'should accept N', ->
        callback = sinon.spy()
        wrapped = varity.wrap ' N', callback
        wrapped NaN
        callback.args[0][0].should.be.NaN

      it 'should accept n', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'n', callback
        wrapped null
        callback.calledWith(null).should.be.true

      it 'should accept u', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'u', callback
        wrapped undefined
        callback.calledWith(undefined).should.be.true

      it 'should accept a', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'a', callback
        args = (->
          arguments
        ) 'one', 'two'
        wrapped args
        callback.calledWith(args).should.be.true

      it 'should accept i', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'i', callback
        wrapped Infinity
        callback.calledWith(Infinity).should.be.true

      it 'should accept e', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'e', callback
        e = new Error()
        wrapped e
        callback.calledWith(e).should.be.true

      it 'should accept a mix of letters', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'sfo1ne', callback
        fn = ->
        obj = {}
        e = new Error()
        wrapped 'string', fn, obj, 2, null, e
        callback.calledWith('string', fn, obj, 2, null, e).should.be.true

      it 'should accept a string with a space at the front', ->
        callback = sinon.spy()
        wrapped = varity.wrap ' Ao', callback
        arr = []
        obj = {}
        wrapped arr, obj
        callback.calledWith(arr, obj).should.be.true

      it 'should not accept other letters', ->
        callback = sinon.spy()
        (->
          varity.wrap '9', callback
        ).should.throw('Unrecognized type: 9')

    context 'called with custom types', ->
      it 'should accept those types', ->
        callback = sinon.spy()
        class Foo
        wrapped = varity.wrap 'Foo', callback
        f = new Foo()
        wrapped f
        callback.calledWith(f).should.be.true

      it 'should accept multiple custom types', ->
        callback = sinon.spy()
        class Foo
        class Bar
        wrapped = varity.wrap 'Foo', 'Bar', callback
        f = new Foo()
        b = new Bar()
        wrapped f, b
        callback.calledWith(f, b).should.be.true

      it 'should accept camel case object names', ->
        callback = sinon.spy()
        class FooBaby
        wrapped = varity.wrap 'FooBaby', callback
        fb = new FooBaby()
        wrapped fb
        callback.calledWith(fb).should.be.true

      it 'should accept custom types with normal types', ->
        callback = sinon.spy()
        class Foo
        wrapped = varity.wrap 'oAs', 'Foo', callback
        obj = {}
        arr = []
        f = new Foo
        wrapped obj, arr, 'string', f
        callback.calledWith(obj, arr, 'string', f).should.be.true

  describe '~wrapper', ->
    context 'called with a missing param', ->
      it 'should pass undefined as the first param', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'sof', callback
        obj = {}
        fn = ->
        wrapped obj, fn
        callback.calledWith(undefined, obj, fn).should.be.true

      it 'should pass undefined as a middle param', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'sof', callback
        fn = ->
        wrapped 'string', fn
        callback.calledWith('string', undefined, fn).should.be.true

      it 'should pass undefined as the last param', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'sof', callback
        obj = {}
        wrapped 'string', obj
        callback.calledWith('string', obj, undefined).should.be.true

    context 'called with multiple missing params', ->
      it 'should accept two missing params next to each other', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'sof', callback
        fn = ->
        wrapped fn
        callback.calledWith(undefined, undefined, fn).should.be.true

      it 'should accept two missing params not next to each other', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'sof', callback
        obj = {}
        wrapped obj
        callback.calledWith(undefined, obj, undefined).should.be.true

      it 'should accept two missing params at the end', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'sof', callback
        wrapped 'string'
        callback.calledWith('string', undefined, undefined).should.be.true

    context 'called with multiple params of the same type in a row', ->
      it 'should pass the first instance of that type', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'off', callback
        obj = {}
        fn = ->
        wrapped obj, fn
        callback.calledWith(obj, fn, undefined).should.be.true

      it 'should allow overriding the default behavior with - on types', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'Object', '-Function', 'Function', callback
        obj = {}
        fn = ->
        wrapped obj, fn
        callback.calledWith(obj, undefined, fn).should.be.true

      it 'should allow overriding the default behavior with - on abbreviations', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'o-ff', callback
        obj = {}
        fn = ->
        wrapped obj, fn
        callback.calledWith(obj, undefined, fn).should.be.true

      it 'should allow multiple -\'s not next to each other', ->
        callback = sinon.spy()
        wrapped = varity.wrap ' -oo-ff', callback
        obj = {}
        fn = ->
        wrapped obj, fn
        callback.calledWith(undefined, obj, undefined, fn).should.be.true

      it 'should allow multiple -\'s next to each other', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'f-A-AA', callback
        fn = ->
        arr = []
        wrapped fn, arr
        callback.calledWith(fn, undefined, undefined, arr).should.be.true

    context 'called more than once', ->
      it 'should reset expectations and work correctly', ->
        callback1 = sinon.spy()
        callback2 = sinon.spy()
        wrapped1 = varity.wrap 'soA', callback1
        wrapped2 = varity.wrap 'fed', callback2
        obj = {}
        arr = []
        fn = ->
        e = new Error()
        date = new Date()
        wrapped1 'string', obj, arr
        wrapped2 fn, e, date
        callback1.calledWith('string', obj, arr).should.be.true
        callback2.calledWith(fn, e, date).should.be.true

    context 'called with object expansion', ->
      it 'should convert s to \'\'', ->
        callback = sinon.spy()
        wrapped = varity.wrap 's+s', callback
        wrapped 'string'
        callback.calledWith('string', '').should.be.true

      it 'should convert String to \'\'', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'String', '+String', callback
        wrapped 'string'
        callback.calledWith('string', '').should.be.true

      it 'should convert Function to ->', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'String', '+Function', callback
        wrapped 'string'
        callback.args[0][0].should.equal('string')
        callback.args[0][1].toString().should.equal('function (){}')

      it 'should convert f to ->', ->
        callback = sinon.spy()
        wrapped = varity.wrap 's+f', callback
        wrapped 'string'
        callback.args[0][0].should.equal('string')
        callback.args[0][1].toString().should.equal('function (){}')

      it 'should convert o to {}', ->
        callback = sinon.spy()
        wrapped = varity.wrap 's+of', callback
        fn = ->
        wrapped 'string', fn
        callback.calledWith('string', {}, fn).should.be.true

      it 'should convert Object to {}', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'String', '+Object', callback
        wrapped 'string'
        callback.calledWith('string', {}).should.be.true
        
      it 'should convert A to []', ->
        callback = sinon.spy()
        wrapped = varity.wrap 's+A', callback
        wrapped 'string'
        callback.calledWith('string', []).should.be.true

      it 'should convert Array to []', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'String', '+Array', callback
        wrapped 'string'
        callback.calledWith('string', []).should.be.true

      it 'should convert Number to 0', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'String', '+Number', callback
        wrapped 'string'
        callback.calledWith('string', 0).should.be.true

      it 'should convert 1 to 0', ->
        callback = sinon.spy()
        wrapped = varity.wrap 's+1', callback
        wrapped 'string'
        callback.calledWith('string', 0).should.be.true

      it 'should convert Boolean to false', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'String', '+Boolean', callback
        wrapped 'string'
        callback.calledWith('string', false).should.be.true

      it 'should convert b to false', ->
        callback = sinon.spy()
        wrapped = varity.wrap 's+b', callback
        wrapped 'string'
        callback.calledWith('string', false).should.be.true

      it 'should convert RegExp to /.*/', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'String', '+RegExp', callback
        wrapped 'string'
        callback.calledWith('string', /.*/).should.be.true

      it 'should convert r to []', ->
        callback = sinon.spy()
        wrapped = varity.wrap 's+r', callback
        wrapped 'string'
        callback.calledWith('string', /.*/).should.be.true

      it 'should convert Date to today\'s date', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'String', '+Date', callback
        d = new Date()
        wrapped 'string'
        callback.args[0][0].should.equal('string')
        arg = callback.args[0][1]
        arg.getDate().should.equal(d.getDate())
        arg.getMonth().should.equal(d.getMonth())
        arg.getFullYear().should.equal(d.getFullYear())

      it 'should convert d to today\'s date', ->
        callback = sinon.spy()
        wrapped = varity.wrap 's+d', callback
        d = new Date()
        wrapped 'string'
        callback.args[0][0].should.equal('string')
        arg = callback.args[0][1]
        arg.getDate().should.equal(d.getDate())
        arg.getMonth().should.equal(d.getMonth())
        arg.getFullYear().should.equal(d.getFullYear())

      it 'should convert NaN to NaN', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'String', '+NaN', callback
        wrapped 'string'
        callback.args[0][0].should.equal('string')
        callback.args[0][1].should.be.NaN

      it 'should convert N to NaN', ->
        callback = sinon.spy()
        wrapped = varity.wrap 's+N', callback
        wrapped 'string'
        callback.args[0][0].should.equal('string')
        callback.args[0][1].should.be.NaN

      it 'should convert Null to null', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'String', '+Null', callback
        wrapped 'string'
        callback.calledWith('string', null).should.be.true

      it 'should convert n to null', ->
        callback = sinon.spy()
        wrapped = varity.wrap 's+n', callback
        wrapped 'string'
        callback.calledWith('string', null).should.be.true
        
      it 'should convert Undefined to undefined', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'String', '+Undefined', callback
        wrapped 'string'
        callback.calledWith('string', undefined).should.be.true

      it 'should convert u to undefined', ->
        callback = sinon.spy()
        wrapped = varity.wrap 's+u', callback
        wrapped 'string'
        callback.calledWith('string', undefined).should.be.true

      it 'should convert Arguments to arguments', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'String', '+Arguments', callback
        wrapped 'string'
        callback.args[0][0].should.equal('string')
        callback.args[0][1].should.have.property('length')
        callback.args[0][1].should.not.have.property('slice')
        should.equal(callback.args[0][1][0], undefined)

      it 'should convert a to arguments', ->
        callback = sinon.spy()
        wrapped = varity.wrap 's+a', callback
        wrapped 'string'
        callback.args[0][0].should.equal('string')
        callback.args[0][1].should.have.property('length')
        callback.args[0][1].should.not.have.property('slice')
        should.equal(callback.args[0][1][0], undefined)

      it 'should convert Infinity to Infinity', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'String', '+Infinity', callback
        wrapped 'string'
        callback.calledWith('string', Infinity).should.be.true

      it 'should convert i to Infinity', ->
        callback = sinon.spy()
        wrapped = varity.wrap 's+i', callback
        wrapped 'string'
        callback.calledWith('string', Infinity).should.be.true

      it 'should convert Error to a new error', ->
        callback = sinon.spy()
        wrapped = varity.wrap 'String', '+Error', callback
        wrapped 'string'
        callback.args[0][0].should.equal('string')
        callback.args[0][1].constructor.name.should.equal('Error')
        callback.args[0][1].message.should.equal('')

      it 'should convert e to a new error', ->
        callback = sinon.spy()
        wrapped = varity.wrap 's+e', callback
        wrapped 'string'
        callback.args[0][0].should.equal('string')
        callback.args[0][1].constructor.name.should.equal('Error')
        callback.args[0][1].message.should.equal('')

      #it 'should work with - on different arguments', ->
        #callback = sinon.spy()
        #wrapped = varity.wrap 's-oo+A', callback
        #obj = {}
        #wrapped 'string', obj
        #callback.calledWith('string', obj, []).should.be.true
