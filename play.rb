#-*- coding: utf-8 -*-
require "./constant.rb"
require "./game.rb"

#----------------------------
# system('date')
# g = Game.new
# p = Player.new(NOUGHT, false)
# g.test(p)
# system('date')
# exit
#----------------------------

begin
  print "First?(y/n)："
  @first = gets
end until @first[0].upcase == "Y" || @first[0].upcase == "N"
if @first[0].upcase == "Y"
  @sente_player = Player.new(CROSS, true)
  @gote_player = Player.new(NOUGHT, false)
  @human = @sente_player
  @CPU = @gote_player
else
  @sente_player = Player.new(CROSS, false)
  @gote_player = Player.new(NOUGHT, true)
  @human = @gote_player
  @CPU = @sente_player
end

g = Game.new
g.board.display
if @gote_player.human
  g.command(@sente_player)
  g.board.display
end


@game_end = false
while !@game_end
  print "数字を入力後Enterキーを押してください："
  input = gets
  g.board[input.to_i - 1] = @human.sengo
  g.board.display
  ret = g.decision
  if ret == ONGOING
    g.command(@CPU)
    ret = g.decision
    if ret != ONGOING
      g.board.display
      break
    end
  else
    @game_end = true
  end
  g.board.display
end
#-------------------------------------------------------
print "Game End!\n"
