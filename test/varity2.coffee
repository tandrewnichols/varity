describe 'Varity', ->
  Given -> @subject = sandbox 'lib/varity2',
    'underscore': _

  Given -> @standardOpts = require '../lib/opts'
  Given -> @varity = new @subject.Varity()

  describe '#new', ->
    Given -> sinon.stub(@subject.Varity.prototype, 'buildExpressions')
    Given -> @subject.Varity._globalOptions =
      foo: 'bar'
    When -> @varity = new @subject.Varity()
    Then -> expect(_.fix(@varity.expectations)).to.deep.equal []
    And -> expect(@varity.letters).to.deep.equal _(@standardOpts.letters).keys().join('')
    And -> expect(@varity.symbols).to.deep.equal _(@standardOpts.symbols).keys().join('')
    And -> expect(@varity.options.foo).to.equal 'bar'
    And -> expect(@varity.buildExpressions).to.have.been.called

  #describe '.extend', ->
    #When -> @subject.Varity.extend('letters.Q', 'Quux')
    #Then -> expect(@subject.Varity._instanceOptions).to.deep.equal
      #letters:
        #Q: 'Quxx'

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
      types: ['Array']
      wrapType: ''
    And -> expect(@varity.buildEvaluator).to.have.been.calledWith
      symbols: ['-']
      types: ['String', 'Array']
      wrapType: 'type or type'

  describe '#expandTypes', ->
    When -> @res = @varity.expandTypes '*a|s[1]'
    Then -> expect(@res).to.equal '*Array|String[Number]'

  describe '#mapSymbols', ->
    When -> @res = @varity.mapSymbols '*-Array|String'
    Then -> expect(_.fix(@res)).to.deep.equal ['*', '-']

  describe '#buildEvaluator', ->
    afterEach ->
      @varity.options.symbols['+'].restore()
      @varity.options.symbols['-'].restore()
      @varity.thingOrDefault.restore()

    Given -> sinon.stub(@varity.options.symbols, '+')
    Given -> sinon.stub(@varity.options.symbols, '-')
    Given -> sinon.stub(@varity, 'thingOrDefault')
    Given -> @context =
      symbols: ['+', '-']
      types: 'String|Function'
    When -> @varity.buildEvaluator @context
    Then -> expect(@varity.expectations.length).to.equal 1

    describe '~ evaluator', ->
      Given -> @varity.thingOrDefault.returns 'memo'
      Given -> @varity.options.symbols['-'].returns 'aha!'
      When -> @res = @varity.expectations[0]('a string', 'next')
      Then -> expect(@varity.options.symbols['+']).to.have.been.calledWith 'memo', @context
      And -> expect(@varity.thingOrDefault).to.have.been.calledWith 'a string', 'String|Function'
      And -> expect(@res).to.equal 'aha!'

  describe '#thingOrDefault', ->
    context 'matches', ->
      When -> @res = @varity.thingOrDefault 'foo', 'String'
      Then -> expect(@res).to.equal 'foo'

    context 'does not match', ->
      When -> @res = @varity.thingOrDefault 'foo', 'Number'
      Then -> expect(@res).to.not.be.defined()

  describe '#parseSpecialSymbols', ->
    context 'array', ->
      Given -> @context =
        types: '[String]'
      When -> @varity.parseSpecialSymbols @context
      Then -> expect(@context.wrapType).to.equal 'array'
      And -> expect(_.fix(@context.types)).to.deep.equal ['String']

    context 'type or type', ->
      Given -> @context =
        types: 'String|Array'
      When -> @varity.parseSpecialSymbols @context
      Then -> expect(@context.wrapType).to.equal 'type or type'
      And -> expect(_.fix(@context.types)).to.deep.equal ['String', 'Array']

    context 'type or array', ->
      Given -> @context =
        types: 'Array|[String]'
      When -> @varity.parseSpecialSymbols @context
      Then -> expect(@context.wrapType).to.equal 'type or array'
      And -> expect(_.fix(@context.types)).to.deep.equal ['Array', 'String']

    context 'array or array', ->
      Given -> @context =
        types: '[String]|[Number]'
      When -> @varity.parseSpecialSymbols @context
      Then -> expect(@context.wrapType).to.equal 'array or array'
      And -> expect(_.fix(@context.types)).to.deep.equal ['String', 'Number']

    context 'array or type', ->
      Given -> @context =
        types: '[String]|Number'
      When -> @varity.parseSpecialSymbols @context
      Then -> expect(@context.wrapType).to.equal 'array or type'
      And -> expect(_.fix(@context.types)).to.deep.equal ['String', 'Number']

    context 'or inside array', ->
      Given -> @context =
        types: '[String|Number]'
      When -> @varity.parseSpecialSymbols @context
      Then -> expect(@context.wrapType).to.equal 'or inside array'
      And -> expect(_.fix(@context.types)).to.deep.equal ['String', 'Number']
      
    context 'undefined', ->
      Given -> @context =
        types: 'String'
      When -> @varity.parseSpecialSymbols @context
      Then -> expect(@context.wrapType).to.equal ''
      And -> expect(_.fix(@context.types)).to.deep.equal ['String']

  describe '#wrapResult', ->
    context 'array or array', ->
      context 'matches first', ->
        When -> @res = @varity.wrapResult
          types: ['String', 'Number']
          wrapType: 'array or array'
        , 'foo'
        Then -> expect(_.fix(@res)).to.deep.equal ['foo']

      context 'matches second', ->
        When -> @res = @varity.wrapResult
          types: ['String', 'Number']
          wrapType: 'array or array'
        , 2
        Then -> expect(_.fix(@res)).to.deep.equal [2]

    context 'or inside array', ->
      context 'matches first', ->
        When -> @res = @varity.wrapResult
          types: ['String', 'Number']
          wrapType: 'or inside array'
        , 'foo'
        Then -> expect(_.fix(@res)).to.deep.equal ['foo']

      context 'matches second', ->
        When -> @res = @varity.wrapResult
          types: ['String', 'Number']
          wrapType: 'or inside array'
        , 2
        Then -> expect(_.fix(@res)).to.deep.equal [2]

    context 'array', ->
      When -> @res = @varity.wrapResult
        types: ['String']
        wrapType: 'array'
      , 'foo'
      Then -> expect(_.fix(@res)).to.deep.equal ['foo']

    context 'array or type', ->
      context 'matches first', ->
        When -> @res = @varity.wrapResult
          types: ['String', 'Number']
          wrapType: 'array or type'
        , 'foo'
        Then -> expect(_.fix(@res)).to.deep.equal ['foo']

      context 'matches second', ->
        When -> @res = @varity.wrapResult
          types: ['String', 'Number']
          wrapType: 'array or type'
        , 2
        Then -> expect(@res).to.equal 2

    context 'type or array', ->
      context 'matches first', ->
        When -> @res = @varity.wrapResult
          types: ['String', 'Number']
          wrapType: 'type or array'
        , 'foo'
        Then -> expect(@res).to.equal 'foo'

      context 'matches second', ->
        When -> @res = @varity.wrapResult
          types: ['String', 'Number']
          wrapType: 'type or array'
        , 2
        Then -> expect(_.fix(@res)).to.deep.equal [2]

    context 'type or type', ->
      context 'matches first', ->
        When -> @res = @varity.wrapResult
          types: ['String', 'Number']
          wrapType: 'type or type'
        , 'foo'
        Then -> expect(@res).to.equal 'foo'

      context 'matches second', ->
        When -> @res = @varity.wrapResult
          types: ['String', 'Number']
          wrapType: 'type or type'
        , 2
        Then -> expect(@res).to.equal 2

    context 'no wrapType', ->
      When -> @res = @varity.wrapResult
        types: ['String']
        wrapType: ''
      , 'foo'
      Then -> expect(@res).to.equal 'foo'

  describe '#getOperations', ->
    Given -> @varity.wrapResult = 'wrap'
    context 'with no symbols', ->
      When -> @res = @varity.getOperations
        symbols: []
      Then -> expect(_.fix(@res)).to.deep.equal(['wrap'])

    context 'with symbols', ->
      Given -> @varity.options.symbols['+'] = 'plus'
      Given -> @varity.options.symbols['-'] = 'minus'
      When -> @res = @varity.getOperations
        symbols: ['+', '-']
      Then -> expect(_.fix(@res)).to.deep.equal ['plus', 'minus', 'wrap']

    context 'with user operations', ->
      Given -> @varity.options.symbols['~'] = 'tilde'
      Given -> @varity.options.symbols['+'] = 'plus'
      Given -> @varity.options.symbols['-'] = 'minus'
      Given -> @varity.options.symbols['#'] = 'hash'
      When -> @res = @varity.getOperations
        symbols: ['~', '+', '-', '#']
      Then -> expect(_.fix(@res)).to.deep.equal ['tilde', 'plus', 'minus', 'hash', 'wrap']

    context 'with non-existent operation', ->
      Given -> @varity.options.symbols['+'] = 'plus'
      When -> @res = @varity.getOperations
        symbols: ['@', '+']
      Then -> expect(_.fix(@res)).to.deep.equal ['plus', 'wrap']
