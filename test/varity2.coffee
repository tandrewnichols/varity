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

  describe '#buildExpecations', ->
    afterEach ->
      @varity.buildEvaluator.restore()

    Given -> sinon.stub(@varity, 'buildEvaluator')

    context 'function', ->
      When -> @varity.buildExpectations(Array)
      Then -> expect(@varity.buildEvaluator).calledWith
        type: ['Array']

    context 'array', ->
      When -> @varity.buildExpectations(['String', 'Object'])
      Then -> expect(@varity.buildEvaluator).calledWith
        type: ['String']
      And -> expect(@varity.buildEvaluator).calledWith
        type: ['Object']
      
    context 'string', ->
      Given -> sinon.stub(@varity, 'tokenize')
      When -> @varity.buildExpectations('abc')
      Then -> expect(@varity.tokenize).calledWith('abc')

    context 'other', ->
      Then -> expect(@varity.buildExpectations).with(foo: 'bar').to.throw('Arguments to varity must be of type function, array, or string')

  describe '#tokenize', ->
    afterEach ->
      @varity.parse.restore()

    Given -> sinon.stub(@varity, 'parse')

    context 'simple string', ->
      When -> @varity.tokenize('sao')
      Then -> expect(@varity.parse).calledWith 's'
      And -> expect(@varity.parse).calledWith 'a'
      And -> expect(@varity.parse).calledWith 'o'

    context 'or', ->
      When -> @varity.tokenize('s|ao')
      Then -> expect(@varity.parse).calledWith 's|a'
      And -> expect(@varity.parse).calledWith 'o'

    context 'array', ->
      When -> @varity.tokenize('[s]o')
      Then -> expect(@varity.parse).calledWith '[s]'
      And -> expect(@varity.parse).calledWith 'o'

    context 'or inside array', ->
      When -> @varity.tokenize('[s|n]o')
      Then -> expect(@varity.parse).calledWith '[s|n]'
      And -> expect(@varity.parse).calledWith 'o'

    context 'array or letter', ->
      When -> @varity.tokenize('[s]|ao')
      Then -> expect(@varity.parse).calledWith '[s]|a'
      And -> expect(@varity.parse).calledWith 'o'

    context 'array or array', ->
      When -> @varity.tokenize('[s]|[n]a')
      Then -> expect(@varity.parse).calledWith '[s]|[n]'
      And -> expect(@varity.parse).calledWith 'a'

    context 'letter or array', ->
      When -> @varity.tokenize('a|[s]n')
      Then -> expect(@varity.parse).calledWith 'a|[s]'
      And -> expect(@varity.parse).calledWith 'n'

    context 'no match', ->
      When -> @varity.tokenize('&')
      Then -> expect(@varity.parse).getCall(0) == null

