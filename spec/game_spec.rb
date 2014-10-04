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
  describe "初形から" do
    it "すべて0" do
      @game.board.each_with_index do |b, n|
        @game.board.init
        @game.board[n] = CROSS
        @player.sengo = (@game.board[n] == CROSS) ? NOUGHT : CROSS
        @threshold = (@player.sengo == CROSS) ? MAX_VALUE : MIN_VALUE
        temp_v, locate = @player.lookahead(@game.board, NOUGHT, @threshold)
        expect(temp_v).to eq(0)
      end
    end
  end

  describe "初手4固定、以後読み切り" do
    it "0,9,0,9,9,0,9,0" do
      @game.board.each_with_index do |b, n|
        @game.board.init
        @game.board[4] = CROSS
        next if @game.board[n]
        @game.board[n] = NOUGHT
        @player.sengo = (@game.board[n] == CROSS) ? NOUGHT : CROSS
        @threshold = (@player.sengo == CROSS) ? MAX_VALUE : MIN_VALUE
        temp_v, locate = @player.lookahead(@game.board, CROSS, @threshold)
        expect(temp_v).to eq(0) if [0, 2, 6, 8].index(n)
        expect(temp_v).to eq(9) if [1, 3, 5, 7].index(n)
      end
    end
  end

  describe "初手4、2手目7辺、以後読み切り" do
    it "9,0,9,9,9,9,9" do
      @game.board.each_with_index do |b, n|
        @game.board.init
        @game.board[4] = CROSS
        @game.board[7] = NOUGHT
        next if @game.board[n]
        @game.board[n] = CROSS
        @player.sengo = (@game.board[n] == CROSS) ? NOUGHT : CROSS
        @threshold = (@player.sengo == CROSS) ? MAX_VALUE : MIN_VALUE
        temp_v, locate = @player.lookahead(@game.board, NOUGHT, @threshold)
        expect(temp_v).to eq(0) if [1].index(n)
        expect(temp_v).to eq(9) if [0, 2, 3, 4, 5, 6, 7].index(n)
      end
    end
  end

  describe "初手4、2手目2角、以後読み切り" do
    it "0,0,0,0,0,0,0" do
      @game.board.each_with_index do |b, n|
        @game.board.init
        @game.board[4] = CROSS
        @game.board[2] = NOUGHT
        next if @game.board[n]
        @game.board[n] = CROSS
        @player.sengo = (@game.board[n] == CROSS) ? NOUGHT : CROSS
        @threshold = (@player.sengo == CROSS) ? MAX_VALUE : MIN_VALUE
        temp_v, locate = @player.lookahead(@game.board, NOUGHT, @threshold)
        expect(temp_v).to eq(0)
      end
    end
  end

  describe "初手から4,3,7,1,2、以後読み切り" do
    it "9,9,0,9" do
      @game.board.each_with_index do |b, n|
        @game.board.init
        @game.board[4] = CROSS
        @game.board[3] = NOUGHT
        @game.board[7] = CROSS
        @game.board[1] = NOUGHT
        @game.board[2] = CROSS
        next if @game.board[n]
        @game.board[n] = NOUGHT
        @player.sengo = (@game.board[n] == CROSS) ? NOUGHT : CROSS
        @threshold = (@player.sengo == CROSS) ? MAX_VALUE : MIN_VALUE
        temp_v, locate = @player.lookahead(@game.board, CROSS, @threshold)
        expect(temp_v).to eq(0) if [6].index(n)
        expect(temp_v).to eq(9) if [0, 5, 8].index(n)
      end
    end
  end

  describe "初手から5,6,4、リーチを防ぐかどうか" do
    it "9,9,9,0,9,9" do
      @game.board.each_with_index do |b, n|
        @game.board.init
        @game.board[5] = CROSS
        @game.board[6] = NOUGHT
        @game.board[4] = CROSS
        next if @game.board[n]
        @game.board[n] = NOUGHT
        @player.sengo = (@game.board[n] == CROSS) ? NOUGHT : CROSS
        @threshold = (@player.sengo == CROSS) ? MAX_VALUE : MIN_VALUE
        temp_v, locate = @player.lookahead(@game.board, CROSS, @threshold)
        expect(temp_v).to eq(0) if [3].index(n)
        expect(temp_v).to eq(9) if [0, 1, 2, 7, 8].index(n)
      end
    end
  end

  describe "初手から5,6,4,8、リーチを防がなかったケース" do
    it "-9,-9,-9,0,9" do
      @game.board.each_with_index do |b, n|
        @game.board.init
        @game.board[5] = CROSS
        @game.board[6] = NOUGHT
        @game.board[4] = CROSS
        @game.board[8] = NOUGHT
        next if @game.board[n]
        @game.board[n] = CROSS
        @player.sengo = (@game.board[n] == CROSS) ? NOUGHT : CROSS
        @threshold = (@player.sengo == CROSS) ? MAX_VALUE : MIN_VALUE
        temp_v, locate = @player.lookahead(@game.board, NOUGHT, @threshold)
        expect(temp_v).to eq(0) if [3].index(n)
        expect(temp_v).to eq(-9) if [0, 1, 2].index(n)
        expect(temp_v).to eq(9) if [8].index(n)
      end
    end
  end

  describe "初手から5,6,4,8、リーチを防いだケース" do
    it "0,-9,-9,-9,-9" do
      @game.board.each_with_index do |b, n|
        @game.board.init
        @game.board[5] = CROSS
        @game.board[6] = NOUGHT
        @game.board[4] = CROSS
        @game.board[3] = NOUGHT
        next if @game.board[n]
        @game.board[n] = CROSS
        @player.sengo = (@game.board[n] == CROSS) ? NOUGHT : CROSS
        @threshold = (@player.sengo == CROSS) ? MAX_VALUE : MIN_VALUE
        temp_v, locate = @player.lookahead(@game.board, NOUGHT, @threshold)
        expect(temp_v).to eq(0) if [0].index(n)
        expect(temp_v).to eq(-9) if [1, 2, 7, 8].index(n)
      end
    end
  end
  
end
