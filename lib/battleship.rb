require_relative "board"
require_relative "player"
require_relative "computerplayer"

class BattleshipGame

  attr_accessor :player, :board, :userboard, :computer

  def initialize(player = HumanPlayer.new, board = Board.new)
    @player = player
    @board = board
    @userboard = Board.new
    @computer = ComputerPlayer.new
  end

  def attack(pos)
    x, y = *pos
    if board.grid[x][y] == :s
      board.hit!([x,y])
      puts "Hit!"
      sleep 1
    else
      board.grid[x][y] = :x
    end
  end

  def count
    board.count
  end

  def game_over?
    board.won? || userboard.won?
  end

  def play_turn
    attack(player.get_play)
    computer_attack(computer.get_play(userboard))
  end

  def play
    board.populate_grid
    setup
    loop do
      display_boards
      play_turn
      break if game_over?
    end
    display_boards
    display_winner
  end

  private

  def user_won?
    board.won?
  end

  def setup
    userboard.setup(player)
  end

  def computer_attack(pos)
    x, y = *pos
    if userboard.grid[x][y] == :s
      userboard.hit!([x,y])
    else
      userboard.grid[x][y] = :x
    end
  end

  def display_boards
    system('cls')
    puts "\n     \e[4m\e[1mYour board\e[0m"
    userboard.display(true)
    puts "\n     \e[4m\e[1mOppenents board\e[0m"
    board.display
  end

  def display_winner
    if user_won?
      puts "\nYou win!"
    else
      puts "\nYou lost to #{computer.name}."
    end
  end

end

if __FILE__ == $PROGRAM_NAME
  BattleshipGame.new.play
end
