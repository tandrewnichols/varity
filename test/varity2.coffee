_ = require('underscore')
_.mixin require('./../lib/mixins')

describe 'Varity', ->
  Given -> @standardOpts =
    stuff: 'thingy'
  Given -> @subject = sandbox 'lib/varity2',
    './opts': @standardOpts
    'underscore': _

  Given -> @varity = new @subject.Varity()

  describe '#new', ->
    When -> @varity = new @subject.Varity()
    Then -> expect(_.fix(@varity.expectations)).to.deep.equal([])

  describe '.configure', ->
    Given -> @opts =
      foo: 'bar'
    Given -> @subject.Varity.configure(@opts)
    When -> @varity = new @subject.Varity()
    Then -> expect(@varity.options).to.deep.equal
      stuff: 'thingy'
      foo: 'bar'

  describe '.reset', ->
    Given -> @subject.Varity._globalOptions =
      foo: 'bar'
    When -> @subject.Varity.reset()
    Then -> expect(@subject.Varity._globalOptions).to.deep.equal {}

  describe '#wrap', ->
    Given -> @fn = sinon.stub().returns('foo')

    context 'with no args', ->
      Then -> expect(@varity.wrap).to.throw('No function passed to varity')

    context 'with no function last', ->
      Then -> expect(@varity.wrap).with('string').to.throw('Last argument is not a function')

    context 'returns the function wrapped', ->
      Given -> @fn = sinon.spy()
      Given -> sinon.spy(@varity, 'buildExpectations')
      Given -> sinon.spy(@varity, 'buildParams')
      When -> @wrapper = @varity.wrap(@fn)
      And -> @wrapper()
      Then -> expect(@fn).called

  describe '#handleArray', ->
    context 'upper case type', ->
      When -> @varity.handleArray('String')
      And -> @res = @varity.expectations[0]('thing')
      Then -> expect(@res).to.equal(true)

    context 'lower case type', ->
      When -> @varity.handleArray('array')
      And -> @res = @varity.expectations[0]([1,2])
      Then -> expect(@res).to.equal(true)

    context 'does not match', ->
      When -> @varity.handleArray('object')
      And -> @res = @varity.expectations[0]([1,2])
      Then -> expect(@res).to.equal(false)

  describe '#buildExpecations', ->
    context 'function', ->
      When -> @varity.buildExpectations(Array)
      And -> @res = @varity.expectations[0]([1,2])
      Then -> expect(@res).to.equal(true)

    context 'array', ->
      Given -> sinon.spy(@varity, 'handleArray')
      When -> @varity.buildExpectations(['String', 'Object'])
      Then -> expect(@varity.handleArray).calledWith('String')
      And -> expect(@varity.handleArray).calledWith('Object')
      
    context 'string', ->
      Given -> sinon.spy(@varity, 'tokenize')
      When -> @varity.buildExpectations('abc')
      Then -> expect(@varity.tokenize).calledWith('abc')
