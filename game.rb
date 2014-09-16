#-*- coding: utf-8 -*-

NOUGHT = -1
CROSS = 1
DRAW = 0
MAX_VALUE = 9
MIN_VALUE = -9
SIZE = 9
LIMIT = 9

class Game
  attr_accessor :board
  attr_accessor :counter

  def initialize
    @board = Board.new([nil, nil, nil, nil, nil, nil, nil, nil, nil])
    @counter = 0
  end

  def command(player)
    threshold = (player.sengo == CROSS) ? MAX_VALUE : MIN_VALUE
    temp_v, locate = player.lookahead(@board, player.sengo, @counter, threshold)    
#p "temp_v="+temp_v.to_s+":locate="+locate.to_s
    if locate
      @board[locate] = player.sengo
      return true
    else
      return false
    end

  end

  def start(player)
    (0..(SIZE - 1)).each{|n|
      @board.init
      @board[n] = CROSS
      threshold = (player.sengo == CROSS) ? MAX_VALUE : MIN_VALUE
      temp_v, locate = player.lookahead(@board, NOUGHT, 1, threshold)
      printf("初手 %d: 評価値: %d\n", n, temp_v)
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
    return (self.select{|b| !b}.size != 0)
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

  def evaluation(board)
    board.line.each {|l|
      piece = board[l[0]]
      if (piece && piece == board[l[1]] && piece == board[l[2]])
        return (piece == NOUGHT) ? MIN_VALUE : MAX_VALUE
#        return (piece == NOUGHT) ? MAX_VALUE : MIN_VALUE
      end
    }
    return DRAW
  end

  def evaluate(board)
    cross = 0
    nought = 0
    board.line.each {|l|
      pieces = []
      pieces << board[l[0]]
      pieces << board[l[1]]
      pieces << board[l[2]]

      case pieces.select{|p| p == nil}.size
      when 2
        if pieces.index(CROSS)
          cross += 1
        elsif pieces.index(NOUGHT)
          nought += 1
        end
      when 1
        if pieces.index(CROSS)
          cross += 1
        elsif pieces.index(NOUGHT)
          nought += 1
        end
      end
    }
    return (cross - nought)
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

  def lookahead(board, turn, cnt, threshold)
    if turn == CROSS
      value = MIN_VALUE
    else
      value = MAX_VALUE
    end
    locate = nil
    board.each_with_index {|b, i|
      next if b
      board[i] = turn
      temp_v = evaluation(board)
#      temp_v = evaluate(board)
#      temp_v = byweight(board)
      teban = (turn == CROSS) ? NOUGHT : CROSS
      if (temp_v != MAX_VALUE && temp_v != MIN_VALUE && cnt < LIMIT - 1)
        temp_v, temp_locate = lookahead(board, teban, cnt + 1, temp_v)
      end
      board[i] = nil
      if (temp_v > value && turn == CROSS) 
        value = temp_v 
        locate = i
        #beta-beta-cut
        break if threshold < temp_v
      elsif (temp_v < value && turn == NOUGHT)
        value = temp_v 
        locate = i
        #alpha-beta-cut
        break if threshold > temp_v
      end

    }
#p "cross:cnt="+cnt.to_s+":value="+value.to_s+":locate="+locate.to_s
    return value, locate
  end

end

#----------------------------
# system('date')
# g = Game.new
# p = Player.new(NOUGHT, false)
# g.start(p)
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
  g.counter += 1
end


@game_end = false
while !@game_end
  print "数字を入力後Enterキーを押してください："
  input = gets
  g.board[input.to_i - 1] = @human.sengo
  g.counter += 1
  g.board.display
  unless g.command(@CPU)
    print "pass!\n"
    @game_end = true unless g.board.droppable
  else
    g.counter += 1
    unless g.board.droppable
      g.board.display
      break
    end
  end
  g.board.display
end
#-------------------------------------------------------
print "Game End!\n"

