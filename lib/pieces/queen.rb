require_relative "./piece"

module ChessPiece
  class Queen < Piece
    MOVES = {
      left: [0, -1],
      right: [0, 1],
      up: [-1, 0],
      down: [1, 0],
      up_left: [-1, -1],
      up_right: [-1, 1],
      down_right: [1, 1],
      down_left: [1, -1]
    }.freeze

    def initialize(colour: 'White', type: 'Queen')
      super(colour: colour, type: type)
    end

    private

    def generate_legal_squares(current_square)
      squares = []

      MOVES.each_value do |coord|
        (1..7).each do |shift_factor|
          new_coord = coord.map { |ele| ele * shift_factor }
          new_square = shift_squares(new_coord, current_square)

          if within_boundary?(new_square)
            squares << new_square
          else
            break
          end
        end
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
