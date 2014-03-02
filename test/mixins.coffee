describe 'mixins', ->
  Given -> @stringify = sinon.stub()
  Given -> @mixins = sandbox 'lib/mixins',
    './stringify': @stringify

  describe '.capitalize', ->
    When -> @res = @mixins.capitalize('thing')
    Then -> expect(@res).to.equal('Thing')

  describe '.isError', ->
    context 'not an error', ->
      When -> @res = @mixins.isError('thing')
      Then -> expect(@res).to.equal(false)

    context 'no constructor', ->
      When -> @res = @mixins.isError(undefined)
      Then -> expect(@res).to.equal(false)

    context 'error', ->
      When -> @res = @mixins.isError(new Error('foo'))
      Then -> expect(@res).to.equal(true)

  describe '.isAnonObject', ->
    context 'not an object', ->
      When -> @res = @mixins.isAnonObject('thing')
      Then -> expect(@res).to.equal(false)

    context 'no constructor', ->
      When -> @res = @mixins.isAnonObject(undefined)
      Then -> expect(@res).to.equal(false)

    context 'object', ->
      When -> @res = @mixins.isAnonObject({})
      Then -> expect(@res).to.equal(true)

  describe '.isInfinity', ->
    context 'not infinity', ->
      When -> @res = @mixins.isInfinity(3)
      Then -> expect(@res).to.equal(false)

    context 'not a number', ->
      When -> @res = @mixins.isInfinity('s')
      Then -> expect(@res).to.equal(false)

    context 'infiniy', ->
      When -> @res = @mixins.isInfinity(2/0)
      Then -> expect(@res).to.equal(true)
      
  describe '.isjQuery', ->
    context 'not jquery', ->
      When -> @res = @mixins.isjQuery('string')
      Then -> expect(@res).to.equal(false)

    context 'undefined', ->
      When -> @res = @mixins.isjQuery(undefined)
      Then -> expect(@res).to.equal(false)

    context 'isjQuery', ->
      When -> @res = @mixins.isjQuery(jquery: '1.0')
      Then -> expect(@res).to.equal(true)

  describe '.stringify', ->
    context 'custom object', ->
      Given -> @stringify.returns '[object Foo]'
      When -> @res = @mixins.stringify(@Foo)
      Then -> expect(@res).to.equal('Foo')

    context 'build in object', ->
      Given -> @stringify.returns '[object Array]'
      When -> @res = @mixins.stringify(Array)
      Then -> expect(@res).to.equal('Array')

    context 'undefined', ->
      Given -> @stringify.returns '[object Undefined]'
      When -> @res = @mixins.stringify(undefined)
      Then -> expect(@res).to.equal('Undefined')
