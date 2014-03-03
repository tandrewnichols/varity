describe 'opts', ->
  Given -> @subject = sandbox 'lib/opts'
  Given -> @symbols = @subject.symbols
  Given -> @this =
    options: @subject

  describe '+', ->
    context 'defined', ->
      When -> @res = @symbols['+'].call @this, 'something', {}
      Then -> expect(@res).to.equal 'something'

    context 'not defined', ->
      When -> @res = @symbols['+'].call @this, undefined,
        types: ['String']
      Then -> expect(@res).to.equal ''

  describe '_', ->
    Given -> @this.options.defaults.Array = ['default']
    context 'not empty', ->
      When -> @res = @symbols['_'].call @this, ['not empty'], {}
      Then -> expect(@res).to.deep.equal ['not empty']

    context 'empty', ->
      When -> @res = @symbols['_'].call @this, [],
        types: ['Array']
      Then -> expect(@res).to.deep.equal ['default']

  describe '*', ->
    context 'defined', ->
      When -> @res = @symbols['*'].call @this, 'defined', {}
      Then -> expect(@res).to.equal 'defined'

    context 'not defined', ->
      Then -> expect(@symbols['*']).with(undefined,
        types: ['String']
      ).to.throw('A parameter of type String is required.')
