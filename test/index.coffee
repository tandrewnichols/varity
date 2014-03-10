describe 'wrapper', ->
  Given -> @_ = spyObj(['mixin'])
  Given -> @Varity = sinon.spy()
  Given -> @Varity.configure = sinon.spy()
  Given -> @Varity.reset = sinon.spy()
  Given -> @Varity.extend = sinon.spy()
  Given -> @subject = sandbox 'lib',
    './varity': @Varity
    './mixins': 'some mixins'
    'underscore': @_

  Then -> expect(@_.mixin).calledWith('some mixins')

  describe '.configure', ->
    When -> @subject.configure
      foo: 'bar'
    Then -> expect(@Varity.configure).to.have.been.calledWith
      foo: 'bar'
  describe '.reset', ->
    When -> @subject.reset()
    Then -> expect(@Varity.reset).to.have.been.calledOnce
  describe '.letters', ->
    When -> @subject.letters 'Q', 'Quux'
    Then -> expect(@Varity.extend).to.have.been.calledWith 'letters.Q', 'Quux'
  describe '.symbols', ->
    When -> @subject.symbols '&', 'ampersand'
    Then -> expect(@Varity.extend).to.have.been.calledWith 'symbols.&', 'ampersand'
  describe '.defaults', ->
    When -> @subject.defaults 'Number', 2
    Then -> expect(@Varity.extend).to.have.been.calledWith 'defaults.Number', 2
  describe '.populate', ->
    afterEach ->
      @subject.defaults.restore()
      
    Given -> @Varity._instanceOptions = {}
    Given -> sinon.stub(@subject, 'defaults')
    When -> @subject.populate 'Number', 2
    Then -> expect(_.fix(@Varity._instanceOptions.populate)).to.deep.equal ['Number']
    And -> expect(@subject.defaults).to.have.been.calledWith 'Number', 2
