require_relative "./piece"

module ChessPiece
  class King < Piece
    MOVES = {
      up: [-1, 0],
      right: [0, 1],
      down: [1, 0],
      left: [0, -1],
      up_left: [-1, -1],
      up_right: [-1, 1],
      down_right: [1, 1],
      down_left: [1, -1]
    }.freeze

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
      file = current_square[0] + coord[0]
      rank = current_square[1] + coord[1]

      [file, rank]
    end
  end
end
