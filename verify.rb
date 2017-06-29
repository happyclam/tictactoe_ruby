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
  buf, converted = sente_player.trees.search(target)
  p buf.score

}

# p "============================================================"
# target = Board.new([nil, nil, nil, nil, nil, nil, nil, nil, nil])
# count = 0
# (0..8).each{|first|
#   target[first] = CROSS
#   (0..8).each{|second|
#     p "#{first} - #{second}"
#     if target[second] == nil
#       count += 1
#       target[second] = NOUGHT
#       target.display
#       buf, converted = sente_player.trees.search(target)
#       p buf.score if buf
#       target[second] = nil
#     end
#   }
#   target[first] = nil
# }
# p "count = #{count}"

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
