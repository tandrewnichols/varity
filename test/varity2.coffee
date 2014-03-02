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

    #TODO: stringify breaks this
    #context 'function', ->
      #When -> @varity.buildExpectations(Array)
      #Then -> expect(@varity.buildEvaluator).calledWith
        #type: ['Array']

    context 'array', ->
      When -> @varity.buildExpectations(['String', 'Object'])
      Then -> expect(@varity.buildEvaluator).to.have.been.calledWith
        type: ['String']
      And -> expect(@varity.buildEvaluator).to.have.been.calledWith
        type: ['Object']
      
    context 'string', ->
      Given -> sinon.stub(@varity, 'tokenize')
      When -> @varity.buildExpectations('abc')
      Then -> expect(@varity.tokenize).to.have.been.calledWith('abc')

    context 'other', ->
      Then -> expect(@varity.buildExpectations).with(foo: 'bar').to.throw('Arguments to varity must be of type function, array, or string')

  describe '#tokenize', ->
    afterEach ->
      @varity.parse.restore()

    Given -> sinon.stub(@varity, 'parse')

    context 'simple string', ->
      When -> @varity.tokenize('sao')
      Then -> expect(@varity.parse).to.have.been.calledWith ['s', 'a', 'o']

    context 'or', ->
      When -> @varity.tokenize('s|ao')
      Then -> expect(@varity.parse).to.have.been.calledWith ['s|a', 'o']

    context 'array', ->
      When -> @varity.tokenize('[s]o')
      Then -> expect(@varity.parse).to.have.been.calledWith ['[s]', 'o']

    context 'or inside array', ->
      When -> @varity.tokenize('[s|n]o')
      Then -> expect(@varity.parse).to.have.been.calledWith ['[s|n]', 'o']

    context 'array or letter', ->
      When -> @varity.tokenize('[s]|ao')
      Then -> expect(@varity.parse).to.have.been.calledWith ['[s]|a', 'o']

    context 'array or array', ->
      When -> @varity.tokenize('[s]|[n]a')
      Then -> expect(@varity.parse).to.have.been.calledWith ['[s]|[n]', 'a']

    context 'letter or array', ->
      When -> @varity.tokenize('a|[s]n')
      Then -> expect(@varity.parse).to.have.been.calledWith ['a|[s]', 'n']

    context 'no match', ->
      When -> @varity.tokenize('&')
      Then -> expect(@varity.parse).to.have.been.calledWith([])

  describe '#parse', ->
    afterEach ->
      @varity.buildEvaluator.restore()

    Given -> sinon.stub(@varity, 'buildEvaluator')
    When -> @varity.parse(['+a', '-s|a'])
    Then -> expect(@varity.buildEvaluator).to.have.been.calledWith
      symbols: ['+']
      types: 'Array'
      arrayType: ''
    And -> expect(@varity.buildEvaluator).to.have.been.calledWith
      symbols: ['-']
      types: 'String|Array'
      arrayType: 'type or type'

  describe '#expandTypes', ->
    When -> @res = @varity.expandTypes '*a|s[1]'
    Then -> expect(@res).to.equal '*Array|String[Number]'

  describe '#mapSymbols', ->
    When -> @res = @varity.mapSymbols '*-Array|String'
    Then -> expect(_.fix(@res)).to.deep.equal ['*', '-']

  describe '#buildEvaluator', ->
    #Given -> @varity.expectations = []
    #Given -> sinon.stub(@varity.options.symbols, '+').returnsArg(0)
    #Given -> sinon.stub(@varity.options.symbols, '-').returnsArg(0)

    #context 'single type', ->
      #When -> @varity.buildEvaluator
        #symbols: ['+', '-']
        #types: 'String'
      #Then -> expect(@varity.expectations.length).to.equal(1)

      #describe '~ evaluator', ->
        #When -> @varity.expectations[0]('a string', 'next')
        #Then -> expect(_.fix(@varity.fnArgs)).to.deep.equal ['a string']
        #And -> expect(@varity.options.symbols['+']).to.have.been.calledWith 'a string', 'next'
        #And -> expect(@varity.options.symbols['-']).to.have.been.calledWith 'a string', 'next'

    #context 'or type', ->
      #When -> @varity.buildEvaluator
        #symbols: ['+']
        #types: 'String|Array'
      #Then -> expect(@varity.expectations.length).to.equal(1)

      #describe '~ evaluator', ->
        #context 'with a string', ->
          #When -> @varity.expectations[0]('a string', 'next')
          #Then -> expect(_.fix(@varity.fnArgs)).to.deep.equal ['a string']
          #And -> expect(@varity.options.symbols['+']).to.have.been.calledWith 'a string', 'next'

        #context 'with an array', ->
          #When -> @varity.expectations[0](['an array'], 'next')
          #Then -> expect(_.fix(@varity.fnArgs)).to.deep.equal [['an array']]
          #And -> expect(@varity.options.symbols['+']).to.have.been.calledWith ['an array'], 'next'

        #context 'with something else', ->
          #When -> @varity.expectations[0](foo: 'bar', 'next')
          #Then -> expect(@varity.fnArgs[0]).to.not.be.defined()

    #context 'array type', ->
      #When -> @varity.buildEvaluator
        #symbols: []
        #types: '[String]'
      #Then -> expect(@varity.expectations.length).to.equal(1)

      #describe '~ evaluator', ->
        #When -> @varity.expectations[0]('a string', 'next')
        #Then -> expect(_.fix(@varity.fnArgs)).to.deep.equal [['a string']]

  describe '#thingOrDefault', ->
    context 'matches', ->
      When -> @res = @varity.thingOrDefault 'foo', 'String'
      Then -> expect(@res).to.equal 'foo'

    context 'does not match', ->
      When -> @res = @varity.thingOrDefault 'foo', 'Number'
      Then -> expect(@res).to.not.be.defined()

  describe '#parseSpecialSymbols', ->
    context 'array', ->
      When -> @res = @varity.parseSpecialSymbols '[String]'
      Then -> expect(@res).to.equal 'array'

    context 'type or type', ->
      When -> @res = @varity.parseSpecialSymbols 'String|Array'
      Then -> expect(@res).to.equal 'type or type'

    context 'type or array', ->
      When -> @res = @varity.parseSpecialSymbols 'Array|[String]'
      Then -> expect(@res).to.equal 'type or array'

    context 'array or array', ->
      When -> @res = @varity.parseSpecialSymbols '[String]|[Number]'
      Then -> expect(@res).to.equal 'array or array'

    context 'array or type', ->
      When -> @res = @varity.parseSpecialSymbols '[String]|Number'
      Then -> expect(@res).to.equal 'array or type'

    context 'or inside array', ->
      When -> @res = @varity.parseSpecialSymbols '[String|Number]'
      Then -> expect(@res).to.equal 'or inside array'
      
    context 'undefined', ->
      When -> @res = @varity.parseSpecialSymbols 'String'
      Then -> expect(@res).to.equal ''

  describe 'getMatch', ->
    context 'array or array', ->
      context 'matches first', ->
        When -> @res = @varity.getMatch
          types: '[String]|[Number]'
          arrayType: 'array or array'
        , 'foo'
        Then -> expect(_.fix(@res)).to.deep.equal ['foo']

      context 'matches second', ->
        When -> @res = @varity.getMatch
          types: '[String]|[Number]'
          arrayType: 'array or array'
        , 2
        Then -> expect(_.fix(@res)).to.deep.equal [2]

    context 'or inside array', ->
      context 'matches first', ->
        When -> @res = @varity.getMatch
          types: '[String|Number]'
          arrayType: 'or inside array'
        , 'foo'
        Then -> expect(_.fix(@res)).to.deep.equal ['foo']

      context 'matches second', ->
        When -> @res = @varity.getMatch
          types: '[String|Number]'
          arrayType: 'or inside array'
        , 2
        Then -> expect(_.fix(@res)).to.deep.equal [2]

    context 'array', ->
      When -> @res = @varity.getMatch
        types: '[String]'
        arrayType: 'array'
      , 'foo'
      Then -> expect(_.fix(@res)).to.deep.equal ['foo']

    context 'array or type', ->
      context 'matches first', ->
        When -> @res = @varity.getMatch
          types: '[String]|Number'
          arrayType: 'array or type'
        , 'foo'
        Then -> expect(_.fix(@res)).to.deep.equal ['foo']

      context 'matches second', ->
        When -> @res = @varity.getMatch
          types: '[String]|Number'
          arrayType: 'array or type'
        , 2
        Then -> expect(@res).to.equal 2

    context 'type or array', ->
      context 'matches first', ->
        When -> @res = @varity.getMatch
          types: 'String|[Number]'
          arrayType: 'type or array'
        , 'foo'
        Then -> expect(@res).to.equal 'foo'

      context 'matches second', ->
        When -> @res = @varity.getMatch
          types: 'String|[Number]'
          arrayType: 'type or array'
        , 2
        Then -> expect(_.fix(@res)).to.deep.equal [2]

    context 'type or type', ->
      context 'matches first', ->
        When -> @res = @varity.getMatch
          types: 'String|Number'
          arrayType: 'type or type'
        , 'foo'
        Then -> expect(@res).to.equal 'foo'

      context 'matches second', ->
        When -> @res = @varity.getMatch
          types: 'String|Number'
          arrayType: 'type or type'
        , 2
        Then -> expect(@res).to.equal 2

    context 'no arrayType', ->
      When -> @res = @varity.getMatch
        types: 'String'
        arrayType: ''
      , 'foo'
      Then -> expect(@res).to.equal 'foo'
