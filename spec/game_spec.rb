require "spec_helper"
require "./constant.rb"
require "./game.rb"

describe Game do
  let(:first) { CROSS }
  let(:second) { NOUGHT }
  before do
    @game = Game.new
    @player = Player.new(NOUGHT, false)
    @threshold = 0
  end

  describe "#initialize" do
    subject {@game}
    subject {@player}
  end

  describe "test" do
    before do
      @game.board.init
      @game.board.set(0, CROSS)
      @player.sengo = (@game.board[0] == CROSS) ? NOUGHT : CROSS
      @threshold = (@player.sengo == CROSS) ? MAX_VALUE : MIN_VALUE
    end
    it "0" do
      temp_v, locate = @player.lookahead(@game.board, NOUGHT, 0, @threshold)
      expect(temp_v).to eq 0
    end
  end

  describe "初形から" do
    it "0,9,0,9,0,9,0,9,0" do
      @game.board.each_with_index do |b, n|
        @game.board.init
        @game.board.set(n, CROSS)
        @player.sengo = (@game.board[n] == CROSS) ? NOUGHT : CROSS
        @threshold = (@player.sengo == CROSS) ? MAX_VALUE : MIN_VALUE
        temp_v, locate = @player.lookahead(@game.board, NOUGHT, 0, @threshold)
        expect(temp_v).to eq 0 if [0, 2, 4, 6, 8].index(n)
        expect(temp_v).to eq 9 if [1, 3, 5, 7].index(n)
      end
    end
  end

  describe "初手4固定、以後読み切り" do
    it "0,9,0,9,9,0,9,0" do
      @game.board.each_with_index do |b, n|
        @game.board.init
        @game.board.set(4, CROSS)
        next if @game.board[n]
        @game.board.set(n, NOUGHT)
        @player.sengo = (@game.board[n] == CROSS) ? NOUGHT : CROSS
        @threshold = (@player.sengo == CROSS) ? MAX_VALUE : MIN_VALUE
        temp_v, locate = @player.lookahead(@game.board, CROSS, 0, @threshold)
        expect(temp_v).to eq(0) if [0, 2, 6, 8].index(n)
        expect(temp_v).to eq(9) if [1, 3, 5, 7].index(n)
      end
    end
  end

  describe "初手4、2手目7辺、以後読み切り" do
    it "9,-9,9,9,9,9,9" do
      @game.board.each_with_index do |b, n|
        @game.board.init
        @game.board.set(4, CROSS)
        @game.board.set(7, NOUGHT)
        next if @game.board[n]
        @game.board.set(n, CROSS)
        @player.sengo = (@game.board[n] == CROSS) ? NOUGHT : CROSS
        @threshold = (@player.sengo == CROSS) ? MAX_VALUE : MIN_VALUE
        temp_v, locate = @player.lookahead(@game.board, NOUGHT, 0, @threshold)
        expect(temp_v).to eq(-9) if [1].index(n)
        expect(temp_v).to eq(9) if [0, 2, 3, 4, 5, 6, 7].index(n)
      end
    end
  end

  describe "初手4、2手目2角、以後読み切り" do
    it "-9,0,0,0,-9,0,-9" do
      @game.board.each_with_index do |b, n|
        @game.board.init
        @game.board.set(4, CROSS)
        @game.board.set(2, NOUGHT)
        next if @game.board[n]
        @game.board.set(n, CROSS)
        @player.sengo = (@game.board[n] == CROSS) ? NOUGHT : CROSS
        @threshold = (@player.sengo == CROSS) ? MAX_VALUE : MIN_VALUE
        temp_v, locate = @player.lookahead(@game.board, NOUGHT, 0, @threshold)
        expect(temp_v).to eq(0) if [1, 3, 5, 7].index(n)
        expect(temp_v).to eq(-9) if [0, 6, 8].index(n)
      end
    end
  end

  describe "初手から4,3,7,1,2、以後読み切り" do
    it "9,-9,9,0" do
      @game.board.each_with_index do |b, n|
        @game.board.init
        @game.board.set(4, CROSS)
        @game.board.set(3, NOUGHT)
        @game.board.set(7, CROSS)
        @game.board.set(1, NOUGHT)
        @game.board.set(2, CROSS)
        next if @game.board[n]
        @game.board.set(n, NOUGHT)
        @player.sengo = (@game.board[n] == CROSS) ? NOUGHT : CROSS
        @threshold = (@player.sengo == CROSS) ? MAX_VALUE : MIN_VALUE
        temp_v, locate = @player.lookahead(@game.board, CROSS, 0, @threshold)
        expect(temp_v).to eq(0) if [8].index(n)
        expect(temp_v).to eq(9) if [0, 6].index(n)
        expect(temp_v).to eq(-9) if [5].index(n)
      end
    end
  end

  describe "初手から5,6,4、リーチを防ぐかどうか" do
    it "9,9,9,9,9,9" do
      @game.board.each_with_index do |b, n|
        @game.board.init
        @game.board.set(5, CROSS)
        @game.board.set(6, NOUGHT)
        @game.board.set(4, CROSS)
        next if @game.board[n]
        @game.board.set(n, NOUGHT)
        @player.sengo = (@game.board[n] == CROSS) ? NOUGHT : CROSS
        @threshold = (@player.sengo == CROSS) ? MAX_VALUE : MIN_VALUE
        temp_v, locate = @player.lookahead(@game.board, CROSS, 0, @threshold)
        expect(temp_v).to eq(9)
      end
    end
  end

  describe "初手から5,6,4,8、リーチを防がなかったケース" do
    it "-9,-9,-9,0,0" do
      @game.board.each_with_index do |b, n|
        @game.board.init
        @game.board.set(5, CROSS)
        @game.board.set(6, NOUGHT)
        @game.board.set(4, CROSS)
        @game.board.set(8, NOUGHT)
        next if @game.board[n]
        @game.board.set(n, CROSS)
        @player.sengo = (@game.board[n] == CROSS) ? NOUGHT : CROSS
        @threshold = (@player.sengo == CROSS) ? MAX_VALUE : MIN_VALUE
        temp_v, locate = @player.lookahead(@game.board, NOUGHT, 0, @threshold)
        expect(temp_v).to eq(0) if [3, 7].index(n)
        expect(temp_v).to eq(-9) if [0, 1, 2].index(n)
      end
    end
  end

  describe "初手から5,6,4,3、リーチを防いだケース" do
    it "9,-9,-9,-9,-9" do
      @game.board.each_with_index do |b, n|
        @game.board.init
        @game.board.set(5, CROSS)
        @game.board.set(6, NOUGHT)
        @game.board.set(4, CROSS)
        @game.board.set(3, NOUGHT)
        next if @game.board[n]
        @game.board.set(n, CROSS)
        @player.sengo = (@game.board[n] == CROSS) ? NOUGHT : CROSS
        @threshold = (@player.sengo == CROSS) ? MAX_VALUE : MIN_VALUE
        temp_v, locate = @player.lookahead(@game.board, NOUGHT, 0, @threshold)
        expect(temp_v).to eq(9) if [0].index(n)
        expect(temp_v).to eq(-9) if [1, 2, 7, 8].index(n)
      end
    end
  end
  
end
