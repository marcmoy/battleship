class ComputerPlayer

  attr_accessor :name

  def initialize(name = "CPU")
    @name = name
  end

  #needs to be refactored to make CPU smarter
  def get_play(userboard)
    userboard.open_spots_for_computer.sample
  end

end
