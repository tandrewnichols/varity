describe 'mixins', ->
  Given -> @mixins = sandbox 'lib/mixins'

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

