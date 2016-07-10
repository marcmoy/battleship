class Board

  attr_accessor :grid, :hits

  def initialize(grid = Board.default_grid)
    @grid = grid
    @hits = []
  end

  def self.default_grid
    Array.new(10){Array.new(10)}
  end

  def display(user = false)
    render_grid(user)
  end

  def count
    grid.flatten.count(:s)
  end

  def empty?(pos = nil)
    return grid.flatten.all?{|spot| spot == nil} if pos == nil
    x, y = *pos
    grid[x][y] == nil
  end

  def full?
    !grid.flatten.any?{|spot| spot == nil}
  end

  def place_random_ship
    # require 'byebug'
    # debugger
    raise "board is full" if full?
    place_ship_at(random_empty_spot)
  end

  def populate_grid
    ships.values.each do |size|
      place_ship_at(random_empty_ship_spot(size))
    end
  end

  def setup(player)
    grab_user_input
  end

  def won?
    !grid.flatten.any?{|spot| spot == :s} || hits.size == total_ships
  end

  def [](pos)
    x, y = *pos
    grid[x][y]
  end

  def hit!(pos)
    hits << pos
  end

  def open_spots_for_computer
    spots = []
    0.upto(grid.size - 1) do |i|
      0.upto(grid.size - 1) do |j|
        next if hits.include?([i,j])
        spots << [i,j] if grid[i][j] != :x
      end
    end
    spots
  end

  private

  def ships
    { :Aircraft => 5,
      :Battleship => 4,
      :Submarine => 3,
      :Destroyer => 3,
      :PatrolBoat => 2,
      :Raft => 1}
  end

  def total_ships
    ships.values.reduce(:+)
  end

  def place_ship_at(spots)
    spots.each do |spot|
        x, y = *spot
        @grid[x][y] = :s
    end
  end

  def random_empty_spot
    empty_spots = []
      0.upto(grid.size - 1) do |i|
        0.upto(grid.size - 1) do |j|
          empty_spots << [i,j] if grid[i][j] == nil
        end
      end
    [empty_spots.sample]
  end

  def random_empty_ship_spot(ship_size)
    possibilities = []
    0.upto(grid.size - 1) do |i|
      0.upto(grid.size - 1) do |j|
        ship_placement = []
        ship_placement << ship_placed_horizontally(i,j,ship_size)
        ship_placement << ship_placed_vertically(i,j,ship_size)
        possibilities << ship_placement.compact.sample
      end
    end
    possibilities.compact.sample
  end

  def ship_placed_horizontally(i,j,size)
    return nil if j + size > grid.size - 1
    spots = []
    0.upto(size - 1) do |n|
      return nil unless grid[i][j + n] == nil
      spots << [i,j + n]
    end
    spots
  end

  def ship_placed_vertically(i,j,size)
    return nil if i + size > grid.size - 1
    spots = []
    0.upto(size - 1) do |n|
      return nil unless grid[i + n][j] == nil
      spots << [i + n,j]
    end
    spots
  end

  def render_grid(user = false)
    output = @grid.each_with_index.collect do |row, i|
      row.each_with_index.collect do |el,j|
        if @hits.include?([i,j])
          "\e[31m[s]\e[0m"
        elsif user == false
          el == nil || el == :s ? "[ ]" : "[#{el.to_s}]"
        else
          el == nil ? "[ ]" : "[#{el.to_s}]"
        end
      end.join("")
    end
    puts top_grid_numbers(@grid.size)
    puts output_with_side_grid(output)
  end

  def top_grid_numbers(size)
    top_str = ""
    bottom_str = ""
    spaces = size * 3 + 5
    spaces.times{top_str += " "; bottom_str += " "}
    m = size * 3 / 2 + 5
    top_str[m] = "Y"
    i = 6
    j = 0
    until j == size
      bottom_str[i] = "#{j}"
      i += 3
      j += 1
    end

    "\n" + top_str + "\n" + bottom_str
  end

  def output_with_side_grid(output)
    center = output.size / 2
    output.each_with_index.collect do |line,i|
      i == center ? " X #{i} " + line : "   #{i} " + line
    end.join("\n")
  end

  def display_ship_list
    puts "\n"
    puts "  | Ship type | Dimensions |"
    ships.each do |ship,length|
      puts "  | #{ship} | #{length}x1 | "
    end
  end

  def grab_user_input
    ships.each do |ship, length|
      spot, orientation, spots = nil, nil, []
      # require 'byebug'
      # debugger
      loop do
        system('cls')
        display(true)
        display_ship_list
        puts "\nWhere do you want to place the first point of the #{ship}?"
        spot = gets.chomp.split(",").map { |el| Integer(el) }
        puts "\nHow do you want to position it?"
        puts "\n   1) horizontally"
        puts "   2) vertically"
        print "\nEnter 1 or 2: "
        orientation = gets.chomp.to_i
        spots = create_spots(spot,orientation,length)
        if valid_move?(spots, orientation)
          break
        else
          puts "\nNot a valid move. Try again"
          sleep 3
        end
      end
      place_ship_at(spots)
    end
  end

  def create_spots(spot,orientation,length)
    i, j = *spot
    spots = []
    if orientation == 1
      0.upto(length - 1) do |n|
        spots << [i, j + n]
      end
    elsif orientation == 2
      0.upto(length - 1) do |n|
        spots << [i + n, j]
      end
    end
    spots
  end

  def valid_move?(spots, orientation)
    return false unless (1..2).cover?(orientation)
    spots.all? do |spot|
      i, j = *spot
      return false if i > @grid.size - 1 || j > @grid.size - 1
      @grid[i][j] == nil
    end
  end

end
