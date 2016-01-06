EMPTY = ' '
WIN_STATES = [
  [0, 1, 2],
  [3, 4, 5],
  [6, 7, 8],
  [0, 3, 6],
  [1, 4, 7],
  [2, 5, 8],
  [0, 4, 8],
  [2, 4, 6]
]

class Board
  attr_reader :cells

  def initialize
    @cells = Array.new(9) { EMPTY }
  end

  def allowable_moves
    (0...size).select do |cell|
      cells[cell] == EMPTY
    end
  end

  def place_token(cell, token)
    cells[cell] = token
  end

  def game_over?
    win? || cat_game?
  end

  def cat_game?
    cells.none? { |cell| cell == EMPTY }
  end

  def win?
    WIN_STATES.any? do |state|
      ['xxx', 'ooo'].include? line(state)
    end
  end

  def line(indexes)
    indexes.map { |cell| cells[cell] }.join
  end

  def size
    cells.size
  end

  def to_s
    cells.each_slice(3).map { |row| row.join(' | ') }.join("\n---------\n")
  end

  def [](index)
    cells[index]
  end
end

class Player
  attr_reader :token

  def initialize(token)
    @token = token
  end


  def move(board)
    print "#{token} > "
    gets.to_i - 1
  end

  def to_s
    token.upcase
  end
end

class RandomAI < Player
  def move(board)
    # sleep 1
    board.allowable_moves.sample
  end
end

class OffensiveAI < Player
  def move(board)
    # sleep 1
    winning_move(board) || blocking_move(board) || board.allowable_moves.sample
  end

  def winning_move(board)
    foo = WIN_STATES.find do |state|
      near_win?(state, board, token)
    end

    return nil unless foo

    foo[board.line(foo).index(EMPTY)]
  end

  def blocking_move(board)
    foo = WIN_STATES.find do |state|
      near_win?(state, board, other_player)
    end

    return nil unless foo

    foo[board.line(foo).index(EMPTY)]
  end

  def other_player
    token == 'x' ? 'o' : 'x'
  end

  def near_win?(state, board, token)
    (board.line(state).count(token) == 2) &&
      board.line(state).include?(EMPTY)
  end
end

def print_board(board)
  20.times { puts }
  puts board
end

def declare_winner(board, player)
  if board.win?
    puts "Player #{player} wins!"
  else
    puts "This game sucked..."
  end
end

def valid_move?(board, move)
  (0...board.size).include?(move) && board[move] == EMPTY
end

results = Hash.new(0)
players = [OffensiveAI.new('x'), OffensiveAI.new('o')]

10000.times do
  board = Board.new

  winner = loop do
    # print_board board
    player = players.first

    move = player.move(board)
    next unless valid_move?(board, move)

    board.place_token(move, player.token)
    break player if board.game_over?
    players.rotate!
  end

  # print_board board
  # puts 'Game OVER'
  # declare_winner(board, winner)

  if board.win?
    results[winner.token] +=1
  end
end

puts results
