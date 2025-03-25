require_relative "./piece"

module ChessPiece
  class Rook < Piece
    MOVES = {
      left: [:file, -1],
      right: [:file, 1],
      up: [:rank, 1],
      down: [:rank, -1]
    }.freeze

    def initialize(colour: 'White', type: 'Rook')
      super(colour: colour, type: type)
    end

    private

    def generate_legal_squares(current_square)
      squares = []

      MOVES.each_value do |coord| # first: -1
        (1..7).each do |shift_factor|
          factor = coord[1] * shift_factor
          position = coord[0]

          new_square = shift_squares(position, factor, current_square)

          if within_boundary?(new_square)
            squares << new_square
          else
            break
          end
        end
      end

      squares
    end

    def shift_squares(position, shift_factor, current_square)
      if position == :file
        rank = current_square[0] + shift_factor
        file = current_square[1]
      end

      if position == :rank
        rank = current_square[0]
        file = current_square[1] + shift_factor
      end

      [rank, file]
    end
  end
end
