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

    def add_possible_movements_per_board_positions(board)
      board.each_with_index do |row, row_idx|
        row.each_with_index do |col, col_idx|
          square_id = col
          square_coord = [row_idx, col_idx]

          squares = generate_legal_squares(square_coord, row_idx)

          squares.each do |target_coord|
            target_rank, target_file = target_coord

            target_id = board[target_rank][target_file]
            add_square_to_movements(square_id, target_id)
          end
        end
      end
    end

    def generate_legal_squares(current_square, row_idx)
      squares = []

      if reverse_movements
        moves = MOVES.transform_values { |value| value.map { |x| x * -1 } }
        rank_idx = 1
      else
        moves = MOVES
        rank_idx = 6
      end
      
      two_up_square = add_two_square_advancement(moves[:_2_up],
                      current_square) if row_idx == rank_idx

      squares << two_up_square unless two_up_square.nil?

      moves.each do |direction, coord|
        next if direction == :_2_up

        new_square = shift_squares(coord, current_square)

        next unless within_boundary?(new_square)

        squares << new_square
      end

      squares
    end

    def add_two_square_advancement(coord, current_square)
      new_square = shift_squares(coord, current_square)

      return nil unless within_boundary?(new_square)

      new_square
    end

    def shift_squares(coord, current_square)
      rank = current_square[0] + coord[0]
      file = current_square[1] + coord[1]

      [rank, file]
    end

    def get_moves
      if reverse_movements
        moves = MOVES.transform_values { |value| value.map { |x| x * -1 } }
      else
        moves = MOVES
      end
    end
  end
end
