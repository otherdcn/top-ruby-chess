class Player
  attr_reader :name, :colour

  def initialize(name, colour)
    @name = name.downcase
    @colour = colour
    @score = 0
  end
end

class Human < Player
  def initialize(name = "Human Hugh", colour = "White")
    super(name, colour)
  end
end

class Computer < Player
  def initialize(name = "Computer Carl", colour = "Black")
    super(name, colour)
  end
end
