_ = require('underscore')
Board = require('./board')
MaskedBoard = require('./masked_board')
Player = require('./player')
Logger = require('./logger')

module.exports = class Dealer
  BOARD =
    PLAYING: 0
    COMPLETED: 1
    FAILED: 2

  constructor: ()->
    @players = [
      Player.createHuman()
      Player.createComputer()
    ]
    @setupBoard()

  setupBoard: ()->
    if @board
      items = @board.getHero().getItems()
      @board = new Board()
      @board.getHero().setItems(items)
      _.each @players, (player)=> player.completeBoard()
    else
      @board = new Board()

    @boardStatus = BOARD.PLAYING
    @players[0].assign(@board.getHero())
    @players[1].assign(@board.getEnemies())

  round: (playerCommand)->
    _.each @players, (player)=>
      @turnPlayer = player
      if player.isHuman()
        @_turn(playerCommand)
      else
        @_turn()

  boardIsCompleted: ->
    @boardStatus == BOARD.COMPLETED

  boardIsFailed: ->
    @boardStatus == BOARD.FAILED

  _turn: (playerCommand)->
    _.each @turnPlayer.characters(), (character)=>
      return unless @boardStatus == BOARD.PLAYING
      command = playerCommand || @turnPlayer.command(character, new MaskedBoard(@board, character))
      command.perform(character, @board)
      @_afterPerform(character, command)

  _afterPerform: (character, command)->
    @turnPlayer.addScore(command.getScore())
    character.waneBuffers()
    to = character.getPosition()
    if @board.isExit(to) && @turnPlayer.isHuman()
      Logger.reachExit(character)
      @boardStatus = BOARD.COMPLETED
    else if not(@board.getHero())
      Logger.gameOver(character)
      @boardStatus = BOARD.FAILED

  @test: ->
    dealer = new Dealer()

    console.log(dealer.board.to_s())
    console.log('-----------------')

    dealer._moveOrAttack(dealer.board.getHero(), "down")
    console.log(dealer.board.to_s())
    console.log('-----------------')

    dealer._moveOrAttack(dealer.board.getHero(), "right")
    console.log(dealer.board.to_s())
    console.log('-----------------')

    dealer._turn()
    console.log(dealer.board.to_s())
