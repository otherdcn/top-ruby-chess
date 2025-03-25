require_relative "./piece"

module ChessPiece
  class Pawn < Piece
    MOVES = {
      up: [-1, 0],
      _2_up: [-2, 0],
      up_left: [-1, -1],
      up_right: [-1, 1]
    }.freeze

    def initialize(colour: 'White', type: 'Pawn')
      super(colour: colour, type: type)
    end

    private
    
    def reverse_movements
      colour == "White" ? false : true
    end

    def generate_legal_squares(current_square)
      squares = []

      if reverse_movements
        moves = MOVES.transform_values { |value| value.map { |x| x * -1 } }
      else
        moves = MOVES
      end
      
      moves.each_value do |coord|
        new_square = shift_squares(coord, current_square)

        next unless within_boundary?(new_square)

        squares << new_square
      end

      squares
    end

    def shift_squares(coord, current_square)
      rank = current_square[0] + coord[0]
      file = current_square[1] + coord[1]

      [rank, file]
    end
  end
end
