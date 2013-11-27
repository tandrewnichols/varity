require('should')
global.context = global.describe
varity = require('../lib/varity')
sinon = require('sinon')

describe 'varity', ->
  it 'should return a function', ->
    varity.should.be.a.Function

  describe 'wrapper', ->
    it 'should wrap the passed function', ->
      callback = sinon.spy()
      wrapped = varity callback
      wrapped.should.be.a.Function
      wrapped()
      callback.called.should.be.true

    it 'should throw if passed no arguments', ->
      (->
        varity()
      ).should.throw('No function passed to varity')

    it 'should throw if the last argument is not a function', ->
      (->
        varity({})
      ).should.throw('Last argument is not a function')

    context 'called with string types', ->
      it 'should accept string', ->
        callback = sinon.spy()
        wrapped = varity 'string', callback
        wrapped 'something'
        callback.calledWith('something').should.be.true

      it 'should accept String', ->
        callback = sinon.spy()
        wrapped = varity 'String', callback
        wrapped 'something'
        callback.calledWith('something').should.be.true

      it 'should accept function', ->
        callback = sinon.spy()
        fn = sinon.spy()
        wrapped = varity 'function', callback
        wrapped(fn)
        callback.calledWith(fn).should.be.true

      it 'should accept Function', ->
        callback = sinon.spy()
        fn = sinon.spy()
        wrapped = varity 'Function', callback
        wrapped(fn)
        callback.calledWith(fn).should.be.true

      it 'should accept object', ->
        callback = sinon.spy()
        obj = fake: 'data'
        wrapped = varity 'object', callback
        wrapped(obj)
        callback.calledWith(obj).should.be.true

      it 'should accept Object', ->
        callback = sinon.spy()
        obj = fake: 'data'
        wrapped = varity 'Object', callback
        wrapped(obj)
        callback.calledWith(obj).should.be.true

      it 'should accept array', ->
        callback = sinon.spy()
        arr = [ 'one', 'two' ]
        wrapped = varity 'array', callback
        wrapped(arr)
        callback.calledWith(arr).should.be.true

      it 'should accept Array', ->
        callback = sinon.spy()
        arr = [ 'one', 'two' ]
        wrapped = varity 'Array', callback
        wrapped(arr)
        callback.calledWith(arr).should.be.true

      it 'should accept number', ->
        callback = sinon.spy()
        wrapped = varity 'number', callback
        wrapped(2)
        callback.calledWith(2).should.be.true

      it 'should accept Number', ->
        callback = sinon.spy()
        wrapped = varity 'Number', callback
        wrapped(2)
        callback.calledWith(2).should.be.true

      it 'should accept boolean', ->
        callback = sinon.spy()
        wrapped = varity 'boolean', callback
        wrapped(true)
        callback.calledWith(true).should.be.true

      it 'should accept Boolean', ->
        callback = sinon.spy()
        wrapped = varity 'Boolean', callback
        wrapped(false)
        callback.calledWith(false).should.be.true

      it 'should accept date', ->
        callback = sinon.spy()
        date = new Date()
        wrapped = varity 'date', callback
        wrapped(date)
        callback.calledWith(date).should.be.true

      it 'should accept Date', ->
        callback = sinon.spy()
        date = new Date()
        wrapped = varity 'Date', callback
        wrapped(date)
        callback.calledWith(date).should.be.true

      it 'should accept regexp', ->
        callback = sinon.spy()
        reg = new RegExp('.*')
        wrapped = varity 'regexp', callback
        wrapped(reg)
        callback.calledWith(reg).should.be.true

      it 'should accept Regexp', ->
        callback = sinon.spy()
        reg = new RegExp('.*')
        wrapped = varity 'Regexp', callback
        wrapped(reg)
        callback.calledWith(reg).should.be.true

      it 'should accept RegExp', ->
        callback = sinon.spy()
        reg = new RegExp('.*')
        wrapped = varity 'RegExp', callback
        wrapped(reg)
        callback.calledWith(reg).should.be.true

      it 'should accept nan', ->
        callback = sinon.spy()
        nan = NaN
        wrapped = varity 'nan', callback
        wrapped(nan)
        # Checking truthy values of NaN is a pain
        callback.args[0][0].should.be.NaN

      it 'should accept Nan', ->
        callback = sinon.spy()
        nan = NaN
        wrapped = varity 'Nan', callback
        wrapped(nan)
        # Checking truthy values of NaN is a pain
        callback.args[0][0].should.be.NaN

      it 'should accept NaN', ->
        callback = sinon.spy()
        nan = NaN
        wrapped = varity 'NaN', callback
        wrapped(nan)
        # Checking truthy values of NaN is a pain
        callback.args[0][0].should.be.NaN

      it 'should accept null', ->
        callback = sinon.spy()
        wrapped = varity 'null', callback
        wrapped(null)
        callback.calledWith(null).should.be.true

      it 'should accept Null', ->
        callback = sinon.spy()
        wrapped = varity 'Null', callback
        wrapped(null)
        callback.calledWith(null).should.be.true

      it 'should accept undefined', ->
        callback = sinon.spy()
        wrapped = varity 'undefined', callback
        wrapped(undefined)
        callback.calledWith(undefined).should.be.true

      it 'should accept Undefined', ->
        callback = sinon.spy()
        wrapped = varity 'Undefined', callback
        wrapped(undefined)
        callback.calledWith(undefined).should.be.true

      it 'should accept arguments', ->
        args = (->
          arguments
        ) 'one', 'two'
        callback = sinon.spy()
        wrapped = varity 'arguments', callback
        wrapped(args)
        callback.calledWith(args).should.be.true

      it 'should accept Arguments', ->
        args = (->
          arguments
        ) 'one', 'two'
        callback = sinon.spy()
        wrapped = varity 'Arguments', callback
        wrapped(args)
        callback.calledWith(args).should.be.true

      it 'should accept infinity', ->
        callback = sinon.spy()
        wrapped = varity 'infinity', callback
        wrapped(Infinity)
        callback.calledWith(Infinity).should.be.true

      it 'should accept Infinity', ->
        callback = sinon.spy()
        wrapped = varity 'Infinity', callback
        wrapped(Infinity)
        callback.calledWith(Infinity).should.be.true

      it 'should accept error', ->
        callback = sinon.spy()
        wrapped = varity 'error', callback
        e = new Error()
        wrapped e
        callback.calledWith(e).should.be.true
      
      it 'should accept Error', ->
        callback = sinon.spy()
        wrapped = varity 'Error', callback
        e = new Error()
        wrapped e
        callback.calledWith(e).should.be.true

      it 'should accept multiple string parameters', ->
        callback = sinon.spy()
        obj = {}
        arr = []
        fn = ->
        wrapped = varity 'string', 'object', 'array', 'function', callback
        wrapped('something', obj, arr, fn)
        callback.calledWith('something', obj, arr, fn).should.be.true

      it 'should accept multiple string parameters with duplicates', ->
        callback = sinon.spy()
        fn1 = ->
        fn2 = ->
        wrapped = varity 'function', 'function', callback
        wrapped(fn1, fn2)
        callback.calledWith(fn1, fn2).should.be.true

    context 'called with actual types', ->
      it 'should accept String', ->
        callback = sinon.spy()
        wrapped = varity String, callback
        wrapped 'string'
        callback.calledWith('string').should.be.true

      it 'should accept Function', ->
        callback = sinon.spy()
        wrapped = varity Function, callback
        fn = ->
        wrapped fn
        callback.calledWith(fn).should.be.true

      it 'should accept Object', ->
        callback = sinon.spy()
        wrapped = varity Object, callback
        obj = {}
        wrapped obj
        callback.calledWith(obj).should.be.true

      it 'should accept Array', ->
        callback = sinon.spy()
        wrapped = varity Array, callback
        arr = []
        wrapped arr
        callback.calledWith(arr).should.be.true

      it 'should accept Number', ->
        callback = sinon.spy()
        wrapped = varity Number, callback
        wrapped 2
        callback.calledWith(2).should.be.true

      it 'should accept Boolean', ->
        callback = sinon.spy()
        wrapped = varity Boolean, callback
        wrapped true
        callback.calledWith(true).should.be.true

      it 'should accept Date', ->
        callback = sinon.spy()
        wrapped = varity Date, callback
        date = new Date()
        wrapped date
        callback.calledWith(date).should.be.true

      it 'should accept RegExp', ->
        callback = sinon.spy()
        wrapped = varity RegExp, callback
        reg = /.*/
        wrapped reg
        callback.calledWith(reg).should.be.true

      it 'should accept Error', ->
        callback = sinon.spy()
        wrapped = varity Error, callback
        e = new Error()
        wrapped e
        callback.calledWith(e).should.be.true

      it 'should accept multiple type parameters', ->
        callback = sinon.spy()
        wrapped = varity String, Function, Object, Array, RegExp, Date, callback
        fn = ->
        obj = {}
        arr = []
        reg = /.*/
        date = new Date()
        wrapped 'string', fn, obj, arr, reg, date
        callback.calledWith('string', fn, obj, arr, reg, date).should.be.true

      it 'should accept multiple type parameters with duplicates', ->
        callback = sinon.spy()
        wrapped = varity Function, Array, Function, callback
        fn1 = ->
        fn2 = ->
        arr = []
        wrapped fn1, arr, fn2
        callback.calledWith(fn1, arr, fn2).should.be.true

    context 'called with special types', ->
      it 'should accept null', ->
        callback = sinon.spy()
        wrapped = varity null, callback
        wrapped null
        callback.calledWith(null).should.be.true

      it 'should accept undefined', ->
        callback = sinon.spy()
        wrapped = varity undefined, callback
        wrapped undefined
        callback.calledWith(undefined).should.be.true

      it 'should accept multiple special parameters', ->
        callback = sinon.spy()
        wrapped = varity null, undefined, callback
        wrapped null, undefined
        callback.calledWith(null, undefined).should.be.true

      it 'should accept multiple special parameters with duplicate', ->
        callback = sinon.spy()
        wrapped = varity null, null, undefined, null, callback
        wrapped null, null, undefined, null
        callback.calledWith(null, null, undefined, null).should.be.true

    context 'called with a mix of types', ->
      it 'should accept any combination of types (part 1)', ->
        callback = sinon.spy()
        wrapped = varity 'string', Function, null, callback
        fn = ->
        wrapped 'string', fn, null
        callback.calledWith('string', fn, null).should.be.true

      it 'should accept any combination of types (part 2)', ->
        callback = sinon.spy()
        wrapped = varity 'string', Function, Function, 'object', Object, null, undefined, Date, 'regexp', callback
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
        wrapped = varity ['string', 'object'], callback
        obj = {}
        wrapped 'string', obj
        callback.calledWith('string', obj).should.be.true

      it 'should accept an array of type parameters', ->
        callback = sinon.spy()
        wrapped = varity [Date, RegExp], callback
        date = new Date()
        reg = /.*/
        wrapped date, reg
        callback.calledWith(date, reg).should.be.true

      it 'should accept an array of special parameters', ->
        callback = sinon.spy()
        wrapped = varity [null, undefined, null], callback
        wrapped null, undefined, null
        callback.calledWith(null, undefined, null).should.be.true

      it 'should accept an array of mixed parameters', ->
        callback = sinon.spy()
        wrapped = varity [null, 'string', Object, 'date', Function], callback
        obj = {}
        date = new Date()
        fn = ->
        wrapped null, 'string', obj, date, fn
        callback.calledWith(null, 'string', obj, date, fn).should.be.true

      it 'should flatten an array of arrays with parameters', ->
        callback = sinon.spy()
        wrapped = varity [['string', 'function'], ['object']], callback
        fn = ->
        obj = {}
        wrapped 'string', fn, obj
        callback.calledWith('string', fn, obj).should.be.true

    context 'called with regular parameters and an array', ->
      it 'should accept parameters with a single array', ->
        callback = sinon.spy()
        wrapped = varity 'string', [Object, Function], callback
        fn = ->
        obj = {}
        wrapped 'string', obj, fn
        callback.calledWith('string', obj, fn).should.be.true

      it 'should accept parameters with more than one array', ->
        callback = sinon.spy()
        wrapped = varity [Array, Date], 'object', [undefined, 'finite'], callback
        arr = []
        date = new Date()
        obj = {}
        inf = Infinity
        wrapped arr, date, obj, undefined, inf
        callback.calledWith(arr, date, obj, undefined, inf).should.be.true

    context 'called with string abbreviations', ->
      it 'should accept s', ->
        callback = sinon.spy()
        wrapped = varity 's', callback
        wrapped 'string'
        callback.calledWith('string').should.be.true

      it 'should accept f', ->
        callback = sinon.spy()
        wrapped = varity 'f', callback
        fn = ->
        wrapped fn
        callback.calledWith(fn).should.be.true

      it 'should accept o', ->
        callback = sinon.spy()
        wrapped = varity 'o', callback
        obj = {}
        wrapped obj
        callback.calledWith(obj).should.be.true

      it 'should accept A', ->
        callback = sinon.spy()
        wrapped = varity 'A', callback
        arr = []
        wrapped arr
        callback.calledWith(arr).should.be.true

      it 'should accept 1', ->
        callback = sinon.spy()
        wrapped = varity '1', callback
        wrapped 2
        callback.calledWith(2).should.be.true

      it 'should accept b', ->
        callback = sinon.spy()
        wrapped = varity 'b', callback
        wrapped true
        callback.calledWith(true).should.be.true

      it 'should accept d', ->
        callback = sinon.spy()
        wrapped = varity 'd', callback
        date = new Date()
        wrapped date
        callback.calledWith(date).should.be.true

      it 'should accept r', ->
        callback = sinon.spy()
        wrapped = varity 'r', callback
        reg = /.*/
        wrapped reg 
        callback.calledWith(reg).should.be.true

      it 'should accept N', ->
        callback = sinon.spy()
        wrapped = varity 'N', callback
        wrapped NaN
        callback.args[0][0].should.be.NaN

      it 'should accept n', ->
        callback = sinon.spy()
        wrapped = varity 'n', callback
        wrapped null
        callback.calledWith(null).should.be.true

      it 'should accept u', ->
        callback = sinon.spy()
        wrapped = varity 'u', callback
        wrapped undefined
        callback.calledWith(undefined).should.be.true

      it 'should accept a', ->
        callback = sinon.spy()
        wrapped = varity 'a', callback
        args = (->
          arguments
        ) 'one', 'two'
        wrapped args
        callback.calledWith(args).should.be.true

      it 'should accept i', ->
        callback = sinon.spy()
        wrapped = varity 'i', callback
        wrapped Infinity
        callback.calledWith(Infinity).should.be.true

      it 'should accept e', ->
        callback = sinon.spy()
        wrapped = varity 'e', callback
        e = new Error()
        wrapped e
        callback.calledWith(e).should.be.true

      it 'should accept a mix of letters', ->
        callback = sinon.spy()
        wrapped = varity 'sfo1ne', callback
        fn = ->
        obj = {}
        e = new Error()
        wrapped 'string', fn, obj, 2, null, e
        callback.calledWith('string', fn, obj, 2, null, e).should.be.true

