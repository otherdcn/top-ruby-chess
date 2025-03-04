class Player
  attr_reader :name, :colour

  def initialize(name, colour)
    @name = name.downcase
    @colour = colour.downcase
    @score = 0
  end
end

class Human < Player
  def initialize(name = "Human Hugh", colour = "white")
    super
  end
end

class Computer < Player
  attr_reader :name

  def initialize(name = "Computer Carl", colour = "black")
    super
  end
end
