class HumanPlayer

  attr_accessor :name

  def initialize(name = "Human")
    @name = name
  end

  def get_play
    prompt
    gets.chomp.split(",").map { |el| Integer(el) }
  end

  def prompt
    puts "\nPlease enter a target square in X,Y format (i.e., '3,4')"
    print "> "
  end

end
