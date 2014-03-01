describe 'Varity', ->
  Given -> @subject = sandbox 'lib/varity2',
    'underscore': _

  Given -> @varity = new @subject.Varity()

  describe '#new', ->
    When -> @varity = new @subject.Varity()
    Then -> expect(_.fix(@varity.expectations)).to.deep.equal([])

  describe '.configure', ->
    Given -> @opts =
      foo: 'bar'
    When -> @subject.Varity.configure(@opts)
    Then -> expect(@subject.Varity._globalOptions).to.deep.equal
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
      Given -> sinon.stub(@varity, 'buildExpectations')
      Given -> sinon.stub(@varity, 'buildParams')
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
      Given -> sinon.stub(@varity, 'handleArray')
      When -> @varity.buildExpectations(['String', 'Object'])
      Then -> expect(@varity.handleArray).calledWith('String')
      And -> expect(@varity.handleArray).calledWith('Object')
      
    context 'string', ->
      Given -> sinon.stub(@varity, 'tokenize')
      When -> @varity.buildExpectations('abc')
      Then -> expect(@varity.tokenize).calledWith('abc')

    context 'other', ->
      Then -> expect(@varity.buildExpectations).with(foo: 'bar').to.throw('Arguments to varity must be of type function, array, or string')

  describe '#tokenize', ->
    context 'simple string', ->
      Given -> @varity.options.expressions = [/^[soa]/]
      When -> @varity.tokenize('sao')
      Then -> expect(@varity.expectations.length).to.equal(3)

      describe 'wrapped fn 1', ->
        context 'called with correct type', ->
          When -> @varity.expectations[0]('foo')
          Then -> expect(_.fix(@varity.applyArgs)).to.deep.equal [ 'foo' ]

        context 'called with wrong type', ->
          When -> @varity.expectations[0](3)
          Then -> expect(_.fix(@varity.applyArgs)).to.deep.equal []

      describe 'wrapped fn 2', ->
        When -> @varity.expectations[1]([1,2])
        Then -> expect(_.fix(@varity.applyArgs)).to.deep.equal [ [1,2] ]

      describe 'wrapped fn 3', ->
        When -> @varity.expectations[2](foo: 'bar')
        Then -> expect(_.fix(@varity.applyArgs)).to.deep.equal [ foo: 'bar' ]
