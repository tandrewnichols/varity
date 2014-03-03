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
       When ->@res = @symbols['+'].call @this, undefined,
         types: ['String']
       Then -> expect(@res).to.equal ''

