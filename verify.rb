#-*- coding: utf-8 -*-
require "./constant.rb"
require "./game.rb"

sente_player = Player.new(CROSS, false)
sente_player.prepare

#target = Board.new([1, 1, 1, -1, 1, -1, -1, -1, 1])
#target = Board.new([-1, 1, 1, nil, -1, 1, nil, nil, -1])
#target = Board.new([-1, 1, 1, -1, -1, -1, 1, nil, 1])
#target = Board.new([nil, nil, nil, nil, nil, nil, nil, 1, nil])
#target = Board.new([nil, nil, nil, nil, nil, nil, 1, nil, nil])
#target = Board.new([nil, nil, nil, nil, nil, nil, nil, nil, 1])
target = Board.new([nil, nil, nil, nil, nil, nil, nil, nil, nil])

target.display
buf = sente_player.trees.search(target)
p buf.score

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
