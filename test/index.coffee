describe 'wrapper', ->
  Given -> @Varity = sinon.spy()
  Given -> @Varity.configure = sinon.spy()
  Given -> @Varity.reset = sinon.spy()
  Given -> @subject = sandbox 'lib',
    './varity2': @Varity

  describe '.configure', ->
    When -> @subject.configure
      foo: 'bar'
    Then -> expect(@Varity.configure.calledWith
      foo: 'bar'
    ).assert()
  describe '.reset', ->
    When -> @subject.reset()
    Then -> expect(@Varity.reset.calledOnce).assert()
