#-*- coding: utf-8 -*-
require "pry"

class Game
  attr_accessor :board

  def initialize
    @board = Board.new([nil, nil, nil, nil, nil, nil, nil, nil, nil])
  end

  def command(player)
    threshold = (player.sengo == CROSS) ? MAX_VALUE : MIN_VALUE
    temp_v, locate = player.lookahead(@board, player.sengo, threshold)    
    if locate
      @board[locate] = player.sengo
      return true
    else
      return false
    end

  end

  def test(player)
    first = true
    moves = 0
    board.each_with_index {|b, n|
      @board.init
      # @board[4] = CROSS
      # @board[6] = NOUGHT
      # @board[4] = CROSS
      # @board[8] = NOUGHT
      if first
        @board.display
        first = false
        moves = @board.select{|b| b != nil }.size + 1
      end
      next if board[n]
      @board[n] = CROSS
#      @board[n] = NOUGHT
      player.sengo = (@board[n] == CROSS) ? NOUGHT : CROSS
      threshold = (player.sengo == CROSS) ? MAX_VALUE : MIN_VALUE
      temp_v, locate = player.lookahead(@board, NOUGHT, threshold)
#      temp_v, locate = player.lookahead(@board, CROSS, threshold)
      printf("%d手目: %d 評価値: %d\n", moves, n + 1, temp_v)
    }
  end

end

class Board < Array
  attr_reader :line
  attr_reader :weight
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
  end

  def init
    self.each_with_index {|n, i|
      self[i] = nil
    }
  end

  # def [](i)
  #   super(i)
  # end

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
#binding.pry
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

end

