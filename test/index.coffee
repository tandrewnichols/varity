describe 'wrapper', ->
  Given -> @_ = spyObj(['mixin'])
  Given -> @Varity = sinon.spy()
  Given -> @Varity.configure = sinon.spy()
  Given -> @Varity.reset = sinon.spy()
  Given -> @subject = sandbox 'lib',
    './varity2': @Varity
    './mixins': 'some mixins'
    'underscore': @_

  Then -> expect(@_.mixin).calledWith('some mixins')

  describe '.configure', ->
    When -> @subject.configure
      foo: 'bar'
    Then -> expect(@Varity.configure.calledWith
      foo: 'bar'
    ).assert()
  describe '.reset', ->
    When -> @subject.reset()
    Then -> expect(@Varity.reset.calledOnce).assert()
