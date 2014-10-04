#-*- coding: utf-8 -*-
require "./constant.rb"
require "pry"

class Game
  attr_accessor :board

  def initialize
    @board = Board.new([nil, nil, nil, nil, nil, nil, nil, nil, nil])
  end

  def command(player)
    threshold = (player.sengo == CROSS) ? MAX_VALUE : MIN_VALUE
    temp_v, locate = player.lookahead(@board, player.sengo, 0, threshold)
    if locate
      @board.set(locate, player.sengo)
      return true
    else
      return false
    end

  end

  def test(player)
    first = true
    moves = 0
    total = 0
    board.each_with_index {|b, n|
      total += @board.counter
      @board.init
      @board.set(1, CROSS); @board.set_dup(CROSS)
      # @board.set(8, NOUGHT); @board.set_dup(NOUGHT)
      # @board.set(4, CROSS); @board.set_dup(CROSS)
      # @board.set(4, NOUGHT); @board.set_dup(NOUGHT)
      # @board.set(6, CROSS); @board.set_dup(CROSS)
      # @board.set(8, NOUGHT); @board.set_dup(NOUGHT)
      # @board.set(0, CROSS); @board.set_dup(CROSS)
      # @board.set(3, NOUGHT); @board.set_dup(NOUGHT)
      next if board[n]
      if first 
        @board.display
        first = false
        moves = @board.select{|b| b != nil }.size + 1
      end
#      @board.set(n, CROSS); @board.set_dup(CROSS)
      @board.set(n, NOUGHT); @board.set_dup(NOUGHT)
      player.sengo = (@board[n] == CROSS) ? NOUGHT : CROSS
      threshold = (player.sengo == CROSS) ? MAX_VALUE : MIN_VALUE
#      temp_v, locate = player.lookahead(@board, NOUGHT, 0, threshold)
      temp_v, locate = player.lookahead(@board, CROSS, 0, threshold)
      printf("%d手目: %d 評価値: %d\n", moves, n + 1, temp_v)
#p @board.counter
    }
#p total
  end

end

class Board < Array
  attr_reader :line
  attr_reader :weight
  attr_accessor :counter
  attr_accessor :hist
  def initialize(*args, &block)
    super(*args, &block)
    @line = []
    @line << [0, 1, 2]
    @line << [3, 4, 5]
    @line << [6, 7, 8]
    @line << [0, 3, 6]
    @line << [1, 4, 7]
    @line << [2, 5, 8]
    @line << [0, 4, 8]
    @line << [2, 4, 6]
    @weight = [1, 0, 1, 0, 2, 0, 1, 0, 1]
    @c_q = Array.new
    @c_bk = Array.new
    @n_q = Array.new
    @n_bk = Array.new
    @duplication = Hash.new
    @counter = 0
    @hist = Array.new
  end

  def init
    self.each_with_index {|n, i|
      self[i] = nil
    }
    @c_q.clear
    @c_bk.clear
    @n_q.clear
    @n_bk.clear
    @duplication.clear
    @counter = 0
    @hist.clear
  end

  def check_dup(sengo)
    temp = self.dup
    temp.unshift(sengo)
    return @duplication.has_key?(temp.hash)
  end

  def set_dup(sengo)
    temp = self.dup
    temp.unshift(sengo)
    @duplication[(temp).hash] = temp
  end

  def set(i, v)
    if self[i] || (i > 8) || (i < 0)
      raise "Error!"
    else
      self[i] = v
    end
    if v == CROSS
      @c_q << i
      if @c_q.size > 3
        idx = @c_q.shift
        @c_bk.push([idx, self[idx]])
        self[idx] = nil
      end
    elsif v == NOUGHT
      @n_q << i
      if @n_q.size > 3
        idx = @n_q.shift
        @n_bk.push([idx, self[idx]])
        self[idx] = nil
      end
    end
  end

  def unset(v)
    if v == CROSS
      if @c_bk.size > 0
        h = Hash[*(@c_bk.pop)]
        temp = h.each{|k, v| self[k] = v}
        @c_q.unshift(temp.keys[0])
      end
      idx = @c_q.pop
    elsif v == NOUGHT
      if @n_bk.size > 0
        h = Hash[*(@n_bk.pop)]
        temp = h.each{|k, v| self[k] = v}
        @n_q.unshift(temp.keys[0])
      end
      idx = @n_q.pop
    end
    self[idx] = nil
  end

  def droppable
    return false if (self.select{|b| !b}.size == 0)
    self.line.each {|l|
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
  attr_accessor :sengo, :human

  def initialize(sengo, human)
    @human = human
    @sengo = sengo
  end

  def byweight(board)
    cross = 0
    nought = 0
    board.each_with_index {|p, i|
      if p == CROSS
        cross += board.weight[i]
      elsif p == NOUGHT
        nought += board.weight[i]
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
    board.counter += 1
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

  def lookahead(board, turn, cnt, threshold)
    if turn == CROSS
      value = MIN_VALUE
    else
      value = MAX_VALUE
    end
    locate = nil
    board.each_with_index {|b, i|
      next if b
#      board.hist.push(i)
      board.set(i, turn)
      if !check(board) && (cnt < LIMIT)
        if board.check_dup(turn)
#          temp_v = (turn == CROSS) ? MIN_VALUE : MAX_VALUE
          temp_v = 0
        else
          teban = (turn == CROSS) ? NOUGHT : CROSS
          temp_v, temp_locate = lookahead(board, teban, cnt + 1, value) 
        end
      else
        temp_v = evaluation(board)
      end
#binding.pry if cnt == 0
      board.unset(turn)
#      board.hist.pop
      if (temp_v >= value && turn == CROSS) 
        value = temp_v 
        locate = i
        break if (threshold < temp_v)
      elsif (temp_v <= value && turn == NOUGHT)
        value = temp_v 
        locate = i
        break if (threshold > temp_v)
      end
    }
    return value, locate
  end

end
