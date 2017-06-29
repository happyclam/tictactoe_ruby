#-*- coding: utf-8 -*-
#require "pry"
#require "pp"
require "pathname"
require "bigdecimal"

class Tree
  @@total = 0
  @@counter = 0
  attr_reader :value, :child, :score
  def initialize(v, pebbles=PEBBLES, c=[])
    @value = v
    @child = c
    #盤面が指定されている時は、すでに駒が置かれているところは
    #選べないようにあらかじめ nil をセットしておく
    @score = v.clone
    @score.map!{|v|
      unless v
        v = pebbles
      else
        v = nil
      end
    }
    @score.distribute
    @@counter = 0
    @@total = 0
  end

  def init
    @child = []
  end

  def total
    return @@total
  end

  #一つ目のパラメータで指定された局面データ（親）を探して、その子ノードとしてオブジェクトを追加する
  def add(target, obj)
    # p "Tree.add"
    ret = nil
    @child.each_with_index { |c, i|
      if overlapped(target, c.value)
        ret = c.child.push(obj)
      else
        ret = c.add(target, obj)
      end
      break if ret
    }
    return ret
  end
  #（その手に対するscore／局面にあるscoreの総数）の確率で手を選択する
  # 指し手の数値を返す
  def apply(v)
    # p "Tree.apply"
    #初期盤面のときはすぐにreturn
    return idx(@score) if @value == v
    ret = nil
    @child.each {|c|
      converted = overlapped(v, c.value)
      if converted
        ret = idx(c.score)
        ret = c.value.rotate_sym[converted][ret]
      else
        ret = c.apply(v)
      end
      break if ret
    }
    return ret
  end
  #指定された局面のノードを返す
  def search(v)
    # p "Tree.search"
    converted = 0
    return self, converted if @value == v
    ret = nil
    @child.each { |c|
      converted = overlapped(v, c.value)
      if converted
        ret = c
      else
        ret, converted = c.search(v)
      end
      break if ret
    }
    return ret, converted
  end

  def count(v)
    @child.each { |c|
      if c.value == v
        @@counter += 1
      else
        @@counter = c.count(v)
      end
    }
    @@counter
  end

  def self.read(path)
    begin
      Pathname.new(path).open("rb") do |f|
        trees = Marshal.load(f)
      end
    rescue
      p $!
    end
  end

  def self.save(path, obj)
    begin
      Pathname.new(path).open("wb") do |f|
        Marshal.dump(obj, f)
      end
    rescue
      p $!
    end
  end

  private
  def overlapped(src, dest)
    temp = dest.clone
 #   p "rotate_sym = #{temp.rotate_sym}"
    temp.rotate_sym.each_with_index{|v, i|
      buf = Array.new(temp.length, nil)
      dest.each_with_index{|value, l|
        buf[v[l]] = value
      }
      return i if buf == src
    }
    return nil
  end
  def idx(score)
    ret = nil
    # index = rand(score.inject(0){|sum, n| (n) ? sum + n : sum} * 10) / 10.0
    # 合計1.0になるようにしたので計算をする必要がなくなった
    index = rand(10) / 10.0
    start = 0
    score.each_with_index{|v, i|
      next unless v
      start += v
      if start > index
        ret = i
        break
      end
    }
    return ret
  end
end

class Game
  attr_accessor :board, :history

  def initialize
    @board = Board.new([nil, nil, nil, nil, nil, nil, nil, nil, nil])
    @history = []
  end

  def command(player)
    # locate = player.trees.apply(@board)

    #人間役は常に機械学習ルーチンじゃない方
    #(=ソフト同志対戦させる時は常に機械学習ルーチンじゃ無い方のhumanプロパティをtrueにする)
    unless player.human
      locate = player.trees.apply(@board)
    else
      # #最強DFSと対戦
      # rest = @board.select{|b| !b}.size
      # if rest == 9
      #   locate = rand(9)
      # else
      #   threshold = (player.sengo == CROSS) ? MAX_VALUE : MIN_VALUE
      #   temp_v, locate = player.lookahead(@board, player.sengo, threshold)
      # end
      #乱数と対戦
      locate = rand(9)
      while @board[locate] != nil
        locate = rand(9)
      end
    end
    if locate
      @board[locate] = player.sengo
      @board.move = locate
      @history.push(@board.clone)
      return true
    else
      p "--- Error ---------------------"
      exit
      return false
    end

  end

  def decision
    cross_win = false
    nought_win = false
    Board.lines.each {|l|
      piece = @board[l[0]]
      if (piece && piece == @board[l[1]] && piece == @board[l[2]])
        cross_win = true if (piece == CROSS)
        nought_win = true if (piece == NOUGHT)
      end
    }
    if (cross_win && !nought_win)
      return CROSS
    elsif (nought_win && !cross_win)
      return NOUGHT
    else
      if (@board.select{|b| !b}.size == 0)
        return DRAW
      else
        return ONGOING
      end
    end
  end

end

class Board < Array
  @@restore_table = [0, 3, 2, 1, 4, 5, 6, 7]
  @@rotate_sym = [
    [0, 1, 2, 3, 4, 5, 6, 7, 8],
    [2, 5, 8, 1, 4, 7, 0, 3, 6],
    [8, 7, 6, 5, 4, 3, 2, 1, 0],
    [6, 3, 0, 7, 4, 1, 8, 5, 2],
    [2, 1, 0, 5, 4, 3, 8, 7, 6],
    [6, 7, 8, 3, 4, 5, 0, 1, 2],
    [0, 3, 6, 1, 4, 7, 2, 5, 8],
    [8, 5, 2, 7, 4, 1, 6, 3, 0]
  ]
  @@lines = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6]
  ]
  @@weights = [1, 0, 1, 0, 2, 0, 1, 0, 1]
  attr_accessor :teban
  attr_accessor :move
  def initialize(*args, &block)
    super(*args, &block)
    @teban = CROSS
  end

  def distribute
    c = self.compact.max
    exp_a = self.map{|v| Math.exp(v - c) if v}
    sum_exp_a = exp_a.inject(0){|sum, n| (n) ? sum + n : sum}
    exp_a.map!{|v| v / sum_exp_a if v}
    self.map!.with_index{|v, i| exp_a[i]}
  end

  def self.weights
    @@weights
  end

  def self.restore_table
    @@restore_table
  end

  def rotate_sym
    @@rotate_sym
  end

  def self.lines
    @@lines
  end

  def droppable
    return false if (self.select{|b| !b}.size == 0)
    @@lines.each {|l|
      piece = self[l[0]]
      if (piece && piece == self[l[1]] && piece == self[l[2]])
        return false
      end
    }
    return true
  end

  def display
    print " "
    "a".ord.step("a".ord + 3 - 1, 1){|row| print " " + " "}
    print "\n"
    self.each_with_index{|b, i|
      print " |" if (i % 3) == 0
      print n2c(i) + "|"
      print "\n" if (i % 3) == 2
    }
  end

  private
  def n2c(idx)
    case self[idx]
    when CROSS
      "X"
    when NOUGHT
      "O"
    else
      (idx + 1).to_s
    end
  end
end

class Player
  attr_accessor :sengo, :human, :trees

  def initialize(sengo, human)
    @human = human
    @sengo = sengo
    @duplication = Hash.new
    @trees = nil
  end

  # def update(x)
  #   z1 = sigmoid(x)
  #   y = softmax(z1)
  #   return x.map.with_index{|v, i| (v) ? v - (LEARNING_RATIO * y[i]) : v}
  # end

  def update(x, t)
    f = method(:loss)
    inc = numerical_gradient(f, x, t)
    return x.map!.with_index{|v, i| (v) ? v - (LEARNING_RATIO * inc[i]) : v}
  end

  def loss(x, t)
    y = softmax(x)
    return cross_entropy_error(y, t)
  end

  def differential(x)
    return x[0]**2 + x[1]**2
  end

  # def numerical_gradient(f, x)
  def numerical_gradient(f, x, t)
    h = 1e-4
    grad = Array.new(x.size, 0)
    x.each_with_index{|v, i|
      next unless v
      tmp_val = x[i]
      x[i] = tmp_val + h
      fxh1 = f.call(x, t)
      x[i] = tmp_val - h
      fxh2 = f.call(x, t)
      grad[i] = (fxh1 - fxh2) / (2 * h)
      x[i] = tmp_val
    }
    return grad
  end

  def gradient_descent(f, init_x, lr=0.01, step_num=100)
    x = init_x
    step_num.times{|i|
      grad = numerical_gradient(f, x)
      x.map!.with_index{|v, i| v - (lr * grad[i])}
    }
    return x
  end

  def sigmoid(x)
    return x.map!{|v| 1 / (1 + Math.exp(-v)) if v}
  end

  def softmax(a)
    c = a.compact.max
    exp_a = a.map{|v| Math.exp(v - c) if v}
    sum_exp_a = exp_a.inject(0){|sum, n| (n) ? sum + n : sum}
    return exp_a.map{|v| v / sum_exp_a if v}
  end

  def mean_squared_error(y, t)
    return 0.5 * y.each_with_index.inject(0){|sum, (n,i)| (n) ? sum + (n - t[i])**2 : sum}
  end

  def cross_entropy_error(y, t)
    delta = 1e-7
    return -y.each_with_index.inject(0){|sum, (n,i)| (n) ? sum + (t[i] * Math.log(n + delta)) : sum}
  end

  def prepare
    if File.exist?("./trees.dump")
      @trees = Tree::read("./trees.dump")
    else
      board = Board.new([nil, nil, nil, nil, nil, nil, nil, nil, nil])
      @trees = Tree.new(board, PEBBLES)
      @trees.init
      bfs(board)
    end
  end

  def learning(result, history)
    # p "Player.learning"
    board = history.pop
    buf, converted = @trees.search(board)
    pre_index = board.move
    #最後の手を取得してすぐにpopして一つ前の局面のscoreを更新する
    base = history.size.to_f
    while board
      board = history.pop
      buf, converted = @trees.search(board)
      restore_index = Board.restore_table[converted]
      if buf
        correct = buf.score.clone
        correct.map!{|v| 0}
        correct[buf.value.rotate_sym[restore_index][pre_index]] = 1.0
        winner = case result
                 when CROSS
                   CROSS
                 when DRAW
                   (@sengo == CROSS) ? NOUGHT : CROSS
                 when NOUGHT
                   NOUGHT
                 end
        # update(buf.score, correct) if (@sengo != buf.value.teban)
        update(buf.score, correct) if (buf.value.teban == winner)
        pre_index = board.move
      end
    end
    Tree::save("./trees.dump", @trees)

  end

  def init_dup
    @duplication.clear
  end

  def check_dup(board)
    temp = board.clone
    temp.rotate_sym.each{|v|
      buf = Array.new(temp.length, nil)
      temp.each_with_index{|value, i|
        buf[v[i]] = value
      }
      seed = buf.to_s
      return true if @duplication.has_key?(seed)
    }
    return true if check(temp)
    return false
  end

  def set_dup(board)
    seed = board.to_s
    @duplication[seed] = board
  end

  def byweight(board)
    cross = 0
    nought = 0
    board.each_with_index {|p, i|
      if p == CROSS
        cross += Board.weights[i]
      elsif p == NOUGHT
        nought += Board.weights[i]
      end
    }
    return (cross - nought)
  end

  #勝負がついたか、置き場所が無くなったらtrueを返す
  def check(board)
    return true if (board.select{|b| !b}.size == 0)
    Board.lines.each {|l|
      piece = board[l[0]]
      if (piece && piece == board[l[1]] && piece == board[l[2]])
        return true
      end
    }
    return false
  end

  def evaluation(board)
    cross_win = false
    nought_win = false
    Board.lines.each {|l|
      piece = board[l[0]]
      if (piece && piece == board[l[1]] && piece == board[l[2]])
        cross_win = true if (piece == CROSS)
        nought_win = true if (piece == NOUGHT)
      end
    }
    if (cross_win && !nought_win)
      return MAX_VALUE
    elsif (nought_win && !cross_win)
      return MIN_VALUE
    else
      return DRAW
    end
  end

  def lookahead(board, turn, threshold)
    if turn == CROSS
      value = MIN_VALUE
    else
      value = MAX_VALUE
    end
    locate = nil
    board.each_with_index {|b, i|
      next if b
      board[i] = turn
      if !check(board)
        teban = (turn == CROSS) ? NOUGHT : CROSS
        temp_v, temp_locate = lookahead(board, teban, value)
      else
        temp_v = evaluation(board)
      end
      board[i] = nil
      if (temp_v >= value && turn == CROSS)
        value = temp_v
        locate = i
        break if threshold < temp_v
      elsif (temp_v <= value && turn == NOUGHT)
        value = temp_v
        locate = i
        break if threshold > temp_v
      end
    }
    return value, locate
  end

  def bfs(board)
    init_dup
    queue = Array.new

    seq = 0
    board.teban = CROSS
    set_dup(board); queue.push(board)

    locate = nil

    n_cross = 0
    n_nought = 0
    n_draw = 0
    while queue != [] do
      buf = queue.shift
      layer = 9 - buf.select{|b| !b}.size
# p "layer=" + layer.to_s + ":seq=" + seq.to_s
      buf.each_with_index {|b, i|
        next if b
        temp = buf.clone
        temp[i] = buf.teban
        #重複データを削除しているので、Treeデータ生成時のmoveは意味がない
        temp.move = nil
        # p "temp = #{temp}"
        # p "temp.to_s = #{temp.to_s}"
        next if check_dup(temp)
        seq += 1
        case layer
        when 0
          @trees.child.push(Tree.new(temp, PEBBLES))
        else
          @trees.add(buf, Tree.new(temp, PEBBLES))
        end

        temp.teban = (buf.teban == CROSS) ? NOUGHT : CROSS
        set_dup(temp); queue.push(temp)
      }
    end
    return seq
  end

end
