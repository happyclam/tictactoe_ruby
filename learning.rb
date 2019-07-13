#-*- coding: utf-8 -*-
require "./constant.rb"
require "./game.rb"

# begin
#   print "First?(y/n)："
#   @first = gets
# end until @first[0].upcase == "Y" || @first[0].upcase == "N"
@first = rand(2)
#1の時は機械学習ルーチンが先手（人間役）、0の時は後手
if @first == 0
p "0"
  @sente_player = Player.new(CROSS, true)
  @gote_player = Player.new(NOUGHT, false)
  @gote_player.prepare
  @sente_player.prepare
  @human = @sente_player
  @CPU = @gote_player
else
p "1"
  @sente_player = Player.new(CROSS, false)
  @gote_player = Player.new(NOUGHT, true)
  @sente_player.prepare
  @gote_player.prepare
  @human = @gote_player
  @CPU = @sente_player
end

g = Game.new
g.board.display
g.history.push(g.board.clone)

if @gote_player.human
p "3"
  g.command(@sente_player)
  g.board.display
end

@game_end = false
while !@game_end
#  print "数字を入力後Enterキーを押してください："
#  input = gets
#  g.board[input.to_i - 1] = @human.sengo; g.board.move = (input.to_i - 1)
  g.command(@human)
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

case ret
when CROSS
  if (@CPU.sengo == CROSS)
    print "You Lose\n"
  else
    print "You Win\n"
  end
when DRAW
  print "Draw\n"
when NOUGHT
  if (@CPU.sengo == NOUGHT)
    print "You Lose\n"
  else
    print "You Win\n"
  end
end

# @CPU.learning(ret, g.history)
