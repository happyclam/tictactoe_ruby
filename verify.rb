#-*- coding: utf-8 -*-
require "./constant.rb"
require "./game.rb"

sente_player = Player.new(CROSS, false)
sente_player.prepare

10.times {|n|
  target = Board.new([nil, nil, nil, nil, nil, nil, nil, nil, nil])
  if n < 9
    target[n] = 1
  end

  target.display
  buf = sente_player.trees.search(target)
  p buf.score

}

#p sente_player.trees.count(target)

# buf = target
# begin
#   buf = sente_player.trees.parent(buf)
#   buf.display
#   p buf.move if buf
# end until buf == nil

#trees.show
#p "test"
#p trees.total
#Tree::save("./temp.dump", trees)
