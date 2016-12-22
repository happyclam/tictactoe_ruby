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
  p "buf.value.teban = #{buf.value.teban}" if buf
  p buf.score if buf
}
p "============================================================"
target = Board.new([nil, nil, nil, nil, nil, nil, nil, nil, nil])
count = 0
(0..8).each{|first|
  #  p "first move"
  target[first] = CROSS
  (0..8).each{|second|
    p "#{first} - #{second}"
    if target[second] == nil
      count += 1
#      p "second move"
      target[second] = NOUGHT
      target.display
      buf = sente_player.trees.search(target)
      p buf.score if buf
      p "buf.value.teban = #{buf.value.teban}" if buf
      target[second] = nil
    end
  }
  target[first] = nil
}
p "count = #{count}"

#target = Board.new([nil, nil, nil, nil, nil, nil, nil, nil, nil])
#target = Board.new([1, nil, nil, nil, nil, nil, nil, nil, nil])
#target = Board.new([nil, nil, -1, nil, nil, 1,  nil, nil, nil])
target = Board.new([1, nil, nil, nil, nil, -1,  nil, nil, nil])
#target = Board.new([1, nil, -1, nil, nil, 1,  nil, nil, nil])
#target = Board.new([1, nil, -1, nil, -1, 1,  nil, nil, nil])
#target = Board.new([1, -1, 1, -1, 1, -1, nil, nil, nil])
###pp sente_player.duplication
p sente_player.trees.count(target)
buf = sente_player.trees.search(target)
p buf.score if buf

p sente_player.check_dup(target)
p "hashcount = #{sente_player.hashcount}"

# buf = target
# begin
#   buf = sente_player.trees.parent(buf)
#   buf.display
#   p buf.move if buf
# end until buf == nil

#sente_player.trees.show
p "test"
p sente_player.trees.total
#Tree::save("./temp.dump", trees)

# p "statistics_notmiss"
# flg, total, pebbles = sente_player.trees.statistics_notmiss
# p total
# p pebbles

p "statistics_prevent"
total, pebbles = sente_player.trees.statistics_prevent
p total
p pebbles
