describe 'Varity', ->
  Given -> @standardOpts =
    stuff: 'thingy'
  Given -> @subject = sandbox 'lib/varity2',
    './opts': @standardOpts

  describe '#new', ->
    When -> @varity = new @subject.Varity()
    Then -> expect(@varity.expectations).to.eql([])

  describe '#wrap', ->
    Given -> @fn = sinon.stub().returns('foo')
    #context 'with no args', ->
      #When -> @varity = new @subject.Varity()
      #Then -> expect(@varity.wrap).to.throwError()

  describe '#configure', ->
    Given -> @opts =
      foo: 'bar'
    Given -> @subject.Varity.configure(@opts)
    When -> @varity = new @subject.Varity()
    Then -> expect(@varity.options).to.eql
      stuff: 'thingy'
      foo: 'bar'

  describe '#reset', ->
    Given -> @subject.Varity._globalOptions =
      foo: 'bar'
    When -> @subject.Varity.reset()
    Then -> expect(@subject.Varity._globalOptions).to.eql {}
