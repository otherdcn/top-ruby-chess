require_relative "./piece"

module ChessPiece
  class Knight < Piece
    MOVES = {
      up_left: [2, -1],
      up_right: [2, 1],
      left_up: [1, -2],
      right_up: [1, 2],
      left_down: [-1, -2],
      right_down: [-1, 2],
      down_left: [-2, -1],
      down_right: [-2, 1]
    }.freeze

    def initialize(colour: 'White', type: 'Knight')
      super(colour: colour, type: type)
    end

    private

    def generate_legal_squares(current_square)
      squares = []

      MOVES.each_value do |coord|
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

    def get_moves
      MOVES
    end
  end
end
