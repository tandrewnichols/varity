describe.only 'acceptance', ->
  Given -> @v = require '../lib'
  Given -> @cb = sinon.spy()

  describe 'type syntax', ->
    context 'all types match', ->
      Given -> @fn = sinon.spy()
      Given -> @wrapped = @v Array, Function, @cb
      When -> @wrapped [1,2], @fn
      Then -> expect(@cb).to.have.been.calledWith [1,2], @fn
