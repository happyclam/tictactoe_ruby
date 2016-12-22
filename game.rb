#-*- coding: utf-8 -*-
#require "pry"
require "pp"
require "pathname"

class Tree
  @@total = 0
  @@pebbles = 0
  @@counter = 0

  attr_reader :value, :child, :score
  def initialize(v, pebbles=PEBBLES, c=[])
    @value = v
    @child = c
    #盤面が指定されている時は、すでに駒が置かれているところは
    #選べないようにあらかじめ 0 をセットしておく
    @score = v.clone
    @score.map!{|v|
      unless v
        v = pebbles
      else
        v = nil
      end
    }
    @@counter = 0
    @@total = 0
  end

  def init
    @child = []
  end

  def total
    return @@total
  end

  #動作確認用
  def show
    p @@total
    @value.display
    @@total += 1
    @child.each{|c|
      c.show
    }
  end

  #動作確認用
  #一つ目のパラメータで指定された局面データ（親）を探して、その子ノードとしてオブジェクトを追加する
  def add(target, obj)
 #   return if @value == target
    ret = nil
    @child.each_with_index { |c, i|
      if c.value == target
        ret = c.child.push(obj)
      else
        ret = c.add(target, obj)
      end
      break if ret
    }
    return ret
  end
  #（その手に対するscore／局面にあるscoreの総数）の確率で手を選択する
  def apply(v)
    #初期盤面のときはすぐにreturn
    return idx(@score) if @value == v
    ret = nil
    @child.each { |c|
      if c.value == v
        ret = idx(c.score)
      else
        ret = c.apply(v)
      end
      break if ret
    }
    return ret
  end
  #指定された局面のノードを返す
  def search(v)
    return self if @value == v
    ret = nil
    @child.each { |c|
      if c.value == v
        ret = c
      else
        ret = c.search(v)
      end
      break if ret
    }
    return ret
  end
  #リーチ状態の局面を探してscoreを集計する
  def statistics_prevent
    @child.each { |c|
      locate = nil
      ret, locate = reach(c.value)
      if ret == CROSS || ret == NOUGHT
        # c.value.display()
        # p c.value.teban
        # p c.score
        @@total = @@total + c.score.inject(0){|sum, n| (n) ? sum + n : sum}
        # @@total = @@total + c.score.inject(0){|sum, n| (n) ? sum + n : sum} / c.score.compact.length
        @@pebbles = @@pebbles + c.score[locate]
        # @@counter += 1
      else
        @@total, @@pebbles = c.statistics_prevent
      end
    }
    return @@total, @@pebbles
  end
  #全検索して指定局面の数を返す
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
  #動作確認用
  def parent(v)
    ret = nil
    @child.each { |c|
#      p "v=" + v.to_s + ":c.value=" + c.value.to_s + ":@value=" + @value.to_s
      if c.value == v
        ret = self
      else
        ret = c.parent(v)
      end
      break if ret
    }
    return ret
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
  def idx(score)
    ret = nil
    index = rand(score.inject(0){|sum, n| (n) ? sum + n : sum} * 10) / 10.0
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
  #リーチ局面の判定（リーチかどうかを知りたいだけなので、ゲーム終了していてもONGOINGを返している）
  def reach(board)
    cross_reach = false
    nought_reach = false
    locate = nil
    board.line.each {|l|
      piece = board[l[0]]
      if (piece && piece == board[l[1]] && piece == board[l[2]])
        cross_reach = false
        nought_reach = false
        locate = nil
        break
      else
        case board.teban
        when NOUGHT
          if (board[l[0]] == CROSS && board[l[1]] == CROSS && board[l[2]] == nil)
            cross_reach = true
            locate = l[2]
          elsif (board[l[0]] == nil && board[l[1]] == CROSS && board[l[2]] == CROSS)
            cross_reach = true
            locate = l[0]
          elsif (board[l[0]] == CROSS && board[l[1]] == nil && board[l[2]] == CROSS)
            cross_reach = true
            locate = l[1]
          end
        when CROSS
          if (board[l[0]] == NOUGHT && board[l[1]] == NOUGHT && board[l[2]] == nil)
            nought_reach = true
            locate = l[2]
          elsif (board[l[0]] == nil && board[l[1]] == NOUGHT && board[l[2]] == NOUGHT)
            nought_reach = true
            locate = l[0]
          elsif (board[l[0]] == NOUGHT && board[l[1]] == nil && board[l[2]] == NOUGHT)
            nought_reach = true
            locate = l[1]
          end
        else
          p "error ======================"
        end
      end
    }
    if cross_reach
      return CROSS, locate
    elsif nought_reach
      return NOUGHT, locate
    else
      return ONGOING, locate
    end
  end

end

class Game
  attr_accessor :board, :history

  def initialize
    @board = Board.new([nil, nil, nil, nil, nil, nil, nil, nil, nil])
    @history = []
  end

  def dynatree(player)
    parent = player.trees.search(@board)
    if parent.child == []
      layer = 9 - @board.select{|b| !b}.size
      @board.each_with_index {|b, i|
        next if b
        temp = @board.clone
        temp[i] = @board.teban
        temp.move = nil
        temp.teban = (@board.teban == CROSS) ? NOUGHT : CROSS
        next if player.check_dup(temp)
        case layer
        when 0
          player.trees.child.push(Tree.new(temp, PEBBLES))
        else
          player.trees.add(@board, Tree.new(temp, PEBBLES))
        end
        player.set_dup(temp)
      }
    end
  end

  def command(player)
    locate = player.trees.apply(@board)
    if locate
      @board[locate] = player.sengo
      @board.teban = (player.sengo == CROSS) ? NOUGHT : CROSS
      @board.move = locate
      dynatree(player)
      @history.push(@board.clone)
      return true
    else
      return false
    end

  end

  def decision
    cross_win = false
    nought_win = false
    @board.line.each {|l|
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
  @@line = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6]
  ]
  @@weight = [1, 0, 1, 0, 2, 0, 1, 0, 1]
  # attr_reader :line
  # attr_reader :weight
  attr_accessor :teban
  attr_accessor :move
  def initialize(*args, &block)
    super(*args, &block)
    @teban = CROSS
  end

  def self.weight
    @@weight
  end

  def line
    @@line
  end

  def init
    self.each_with_index {|n, i|
      self[i] = nil
    }
  end

  def droppable
    return false if (self.select{|b| !b}.size == 0)
    @@line.each {|l|
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

  def hashcount
    @duplication.length
  end

  def prepare
    if File.exist?("./trees.dump")
      @trees = Tree::read("./trees.dump")
    else
      board = Board.new([nil, nil, nil, nil, nil, nil, nil, nil, nil])
      @trees = Tree.new(board, PEBBLES)
      @trees.init
    end
    if File.exist?("./duplication.dump")
      begin
        Pathname.new("./duplication.dump").open("rb") do |f|
          @duplication = Marshal.load(f)
        end
      rescue
        p $!
        exit
      end
    else
      @duplication = Hash.new
    end
  end

  def learning(result, history)
    board = history.pop
    buf = @trees.search(board)
    pre_index = board.move
    #最後の手を取得してすぐにpopして一つ前の局面のscoreを更新する
    base = history.size.to_f
    while board
#      dose = history.size / base
#      dose = 0.029 * 1.882 ** history.size
#      dose = 0.188 * 1.588 ** history.size
      dose = (history.size <= 0) ? 0.1 : ((1.0 / base) + Math.log(history.size, base))
      case result
      when CROSS
        inc = (@sengo == CROSS) ? (3.0 * dose) : (-1.0 * dose)
      when DRAW
        inc = 1.0
      when NOUGHT
        inc = (@sengo == NOUGHT) ? (3.0 * dose) : (-1.0 * dose)
      end
      board = history.pop
      buf = @trees.search(board)
      if buf
        buf.score[pre_index] += inc if (@sengo == buf.value.teban)
        #石が０個になっていたら置ける箇所全てに追加（小数に対応するために0.1に変更）
        if buf.score[pre_index] <= 0.1
          positive = buf.score.min_by{|v| v.to_i}
          positive = positive ? (positive.abs + PEBBLES) : PEBBLES
          buf.score.map!{|v|
            v += positive if v
          }
        end
        pre_index = board.move
      else
        p "=== Not Found ========================="
      end
    end
    Tree::save("./trees.dump", @trees)
    @duplication = @duplication.invert.invert.dup
    begin
      Pathname.new("./duplication.dump").open("wb") do |f|
        Marshal.dump(@duplication, f)
      end
    rescue
      p $!
    end

  end

  def init_dup
    @duplication.clear
  end

  def check_dup(board)
    seed = board.to_s
    return @duplication.has_key?(seed)
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
        cross += Board.weight[i]
      elsif p == NOUGHT
        nought += Board.weight[i]
      end
    }
    return (cross - nought)
  end

  #勝負がついたか、置き場所が無くなったらtrueを返す
  def check(board)
    return true if (board.select{|b| !b}.size == 0)
    board.line.each {|l|
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
    board.line.each {|l|
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
#board.display
#p "cnt="+cnt.to_s+":turn="+((turn == CROSS) ? "X" : "O")+":v="+temp_v.to_s+":i="+i.to_s
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
#p "cross:cnt="+cnt.to_s+":value="+value.to_s+":locate="+locate.to_s
    return value, locate
  end

  def bfs(board)
    init_dup
    queue = Array.new

    seq = 0
#    pre = 0
    board.teban = CROSS
    set_dup(board); queue.push(board)

    locate = nil

    n_cross = 0
    n_nought = 0
    n_draw = 0
    while queue != [] do
      buf = queue.shift
      layer = 9 - buf.select{|b| !b}.size
#p "layer=" + layer.to_s + ":seq=" + seq.to_s
      buf.each_with_index {|b, i|
        next if b
        temp = buf.clone
        temp[i] = buf.teban
        #重複データを削除しているので、Treeデータ生成時のmoveは意味がない
        temp.move = nil
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
