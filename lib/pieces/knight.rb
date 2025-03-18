require_relative '../ds/graph'

module ChessPiece
  class Error < StandardError; end

  class Knight
    include Graph

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

    def reachable?(from:, to:)
      raise ChessPiece::Error, "Start square #{from} " \
      "not present" unless graph_of_knight_moves(from)

      raise ChessPiece::Error, "Destination square #{to} " \
      "not present" unless graph_of_knight_moves(to)

      squares_connected?(from, to)
    end

    def next_moves(from:)
      immediate_squares(from)
    end

    def populate_graph(board:)
      add_board_positions(board)
      add_possible_movements_per_board_positions(board)
    end

    private

    def add_board_positions(board)
      board.each_with_index do |row, row_idx|
        row.each_with_index do |col, col_idx|
          square_id = col
          square_coord = [col_idx, row_idx]

          add_square_to_board(square_id, square_coord)
        end
      end
    end

    def add_possible_movements_per_board_positions(board)
      board.each_with_index do |row, row_idx|
        row.each_with_index do |col, col_idx|
          square_id = col
          square_coord = [col_idx, row_idx]
          squares = generate_legal_squares(square_coord)

          squares.each do |target_coord|
            target_file, target_rank = target_coord

            target_id = board[target_rank][target_file]
            add_square_to_movements(square_id, target_id)
          end
        end
      end
    end

    def generate_legal_squares(current_square)
      squares = []

      MOVES.each_value do |coord|
        file = current_square[0] + coord[0]
        rank = current_square[1] + coord[1]

        next unless within_boundary?([file, rank])

        squares << [file, rank]
      end

      squares
    end

    def within_boundary?(coord, size = 8)
      coord.all? { |point| point.between?(0, size - 1) }
    end

    def graph_of_knight_moves(key)
      adjacency_list[key]
    end

    def squares_connected?(start_square, destination_square)
      vertices_connected?(start_square, destination_square)
    end

    def immediate_squares(key)
      adjacent_vertices(key)
    end

    def add_square_to_board(square_id, square_coord)
      add_vertex(square_id, square_coord)
    end

    def add_square_to_movements(square_id, target_id)
      add_edge(square_id, target_id)
    end
  end
end
