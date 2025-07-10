require_relative "./piece"

module ChessPiece
  class Pawn < Piece
    MOVES = {
      up: [-1, 0],
      up_left: [-1, -1],
      up_right: [-1, 1]
    }.freeze

    SPECIAL_MOVES = {
      _2_up: [-2, 0],
      en_passant_left: [0, -1],
      en_passant_right: [0, 1]
    }

    def initialize(colour: 'White', type: 'Pawn')
      super(colour: colour, type: type)
    end

    def next_moves(from:, chess_board: nil)
      next_squares = immediate_squares(from)

      groups = next_squares.group_by do |next_square|
        square_group(from, next_square, chess_board.board)
      end

      legal_squares = []

      groups.each do |direction, squares|
        squares.each do |square|
          piece = chess_board.check_square(square)


          if piece == "" && diagonal_movement(direction)
            break
          elsif piece == ""
            legal_squares << square
          elsif opponent_on_diagonal?(piece, direction)
            legal_squares << square
          elsif different_colour(piece)
            break
          elsif !different_colour(piece)
            break
          end
        end
      end

      legal_squares
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
        special_moves = SPECIAL_MOVES.transform_values { |value|
          value.map { |x| x * -1 } }

        rank_idx = 1
      else
        moves = MOVES
        special_moves = SPECIAL_MOVES

        rank_idx = 6
      end

      moves.each do |direction, coord|
        new_square = shift_squares(coord, current_square)

        next unless within_boundary?(new_square)

        squares << new_square
      end

      two_up_square = add_two_square_advancement(special_moves[:_2_up],
                      current_square) if row_idx == rank_idx

      squares << two_up_square unless two_up_square.nil?

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

    def opponent_on_diagonal?(piece, direction)
      opponent = different_colour(piece)
      on_diagonal = diagonal_movement(direction)

      opponent && on_diagonal
    end

    def different_colour(piece)
      piece.colour != colour
    end

    def diagonal_movement(direction)
      [:up_left, :up_right].include?(direction)
    end
  end
end
