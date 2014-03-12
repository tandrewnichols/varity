describe 'acceptance', ->
  Given -> @v = require '../lib'
  Given -> @cb = sinon.spy()

  describe 'type syntax', ->
    context 'all types match', ->
      Given -> @fn = sinon.spy()
      Given -> @wrapped = @v Array, Function, @cb
      When -> @wrapped [1,2], @fn
      Then -> expect(@cb).to.have.been.calledWith [1,2], @fn

    context 'first type matches', ->
      Given -> @wrapped = @v Array, Function, @cb
      When -> @wrapped [1,2]
      Then -> expect(@cb).to.have.been.calledWith [1,2], undefined

    context 'second type matches', ->
      Given -> @fn = sinon.spy()
      Given -> @wrapped = @v Array, Function, @cb
      When -> @wrapped @fn
      Then -> expect(@cb).to.have.been.calledWith undefined, @fn

    context 'with a default', ->
      Given -> @v.populate 'Array', ['foo', 'bar']
      Given -> @fn = sinon.spy()
      Given -> @wrapped = @v Array, Function, @cb
      When -> @wrapped @fn
      Then -> expect(@cb).to.have.been.calledWith ['foo', 'bar'], @fn

  describe 'array syntax', ->
    context 'all types match', ->
      Given -> @fn = sinon.spy()
      Given -> @wrapped = @v ['array', 'function'], @cb
      When -> @wrapped [1,2], @fn
      Then -> expect(@cb).to.have.been.calledWith [1,2], @fn

    context 'first type matches', ->
      Given -> @wrapped = @v ['array', 'function'], @cb
      When -> @wrapped [1,2]
      Then -> expect(@cb).to.have.been.calledWith [1,2], undefined

    context 'second type matches', ->
      Given -> @fn = sinon.spy()
      Given -> @wrapped = @v ['array', 'function'], @cb
      When -> @wrapped @fn
      Then -> expect(@cb).to.have.been.calledWith undefined, @fn

    context 'with a default', ->
      Given -> @v.populate 'Array', ['foo', 'bar']
      Given -> @fn = sinon.spy()
      Given -> @wrapped = @v ['array', 'function'], @cb
      When -> @wrapped @fn
      Then -> expect(@cb).to.have.been.calledWith ['foo', 'bar'], @fn

  describe 'letter syntax', ->
    context 'all types match', ->
      Given -> @fn = sinon.spy()
      Given -> @wrapped = @v 'af', @cb
      When -> @wrapped [1,2], @fn
      Then -> expect(@cb).to.have.been.calledWith [1,2], @fn

    context 'first type matches', ->
      Given -> @wrapped = @v 'af', @cb
      When -> @wrapped [1,2]
      Then -> expect(@cb).to.have.been.calledWith [1,2], undefined

    context 'second type matches', ->
      Given -> @fn = sinon.spy()
      Given -> @wrapped = @v 'af', @cb
      When -> @wrapped @fn
      Then -> expect(@cb).to.have.been.calledWith undefined, @fn

    context 'with -', ->
      Given -> @wrapped = @v '-oo', @cb
      When -> @wrapped {}
      Then -> expect(@cb).to.have.been.calledWith undefined, {}

    context 'with +', ->
      Given -> @wrapped = @v '+a+o', @cb
      When -> @wrapped()
      Then -> expect(@cb).to.have.been.calledWith [], {}

    context 'with _', ->
      Given -> @v.defaults 'Array', [1,2]
      Given -> @wrapped = @v '_as', @cb
      When -> @wrapped [], 'string'
      Then -> expect(@cb).to.have.been.calledWith [1,2], 'string'

    context 'with *', ->
      Given -> @wrapped = @v 'a*o', @cb
      Then -> expect(@wrapped).with([]).to.throw('A parameter of type Object is required.')

    context 'with |', ->
      Given -> @wrapped = @v 'a|so', @cb
      
      context 'called with first param', ->
        When -> @wrapped [1], {}
        Then -> expect(@cb).to.have.been.calledWith [1], {}

      context 'called with second param', ->
        When -> @wrapped 'string', {}
        Then -> expect(@cb).to.have.been.calledWith 'string', {}

      context 'called with neither', ->
        When -> @wrapped {}
        Then -> expect(@cb).to.have.been.calledWith undefined, {}

      context 'called with neither and populate', ->
        Given -> @wrapped = @v '+a|so', @cb
        When -> @wrapped {}
        Then -> expect(@cb).to.have.been.calledWith [], {}

    context 'with []', ->
      Given -> @wrapped = @v '[s]1', @cb
      When -> @wrapped 'string', 2
      Then -> expect(@cb).to.have.been.calledWith ['string'], 2

    context 'with [] and |', ->
      Given -> @wrapped = @v '[s]|ab', @cb
      
      context 'called with first param', ->
        When -> @wrapped 'string', true
        Then -> expect(@cb).to.have.been.calledWith ['string'], true

      context 'called with second param', ->
        When -> @wrapped [1], true
        Then -> expect(@cb).to.have.been.calledWith [1], true

      context 'called with neither', ->
        When -> @wrapped true
        Then -> expect(@cb).to.have.been.calledWith undefined, true

      context 'called with neither and populate', ->
        Given -> @wrapped = @v '+[s]|ab', @cb
        When -> @wrapped true
        Then -> expect(@cb).to.have.been.calledWith [''], true

    context 'with [] | []', ->
      Given -> @wrapped = @v '[s]|[1]o', @cb

      context 'called with first param', ->
        When -> @wrapped 'string', {}
        Then -> expect(@cb).to.have.been.calledWith ['string'], {}

      context 'called with second param', ->
        When -> @wrapped 2, {}
        Then -> expect(@cb).to.have.been.calledWith [2], {}

      context 'called with neither', ->
        When -> @wrapped {}
        Then -> expect(@cb).to.have.been.calledWith undefined, {}

      context 'called with neither and populate', ->
        Given -> @wrapped = @v '+[s]|[1]o', @cb
        When -> @wrapped {}
        Then -> expect(@cb).to.have.been.calledWith [''], {}

    context 'crazy combination of letters and symbols', ->
      Given -> @v.populate 'String', 'foo bar'
      Given -> @wrapped = @v '-+oo[a]+1_s*a|[b]', @cb
      When -> @wrapped {foo: 'bar'}, [1], '', true, 2
      Then -> expect(@cb).to.have.been.calledWith {}, {foo: 'bar'}, [[1]], 0, 'foo bar', [true], 2
