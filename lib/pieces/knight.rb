require_relative "../ds/queue"
require_relative "../ds/graph"

module ChessPiece
  class Knight
    attr_accessor :graph, :board

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

    def initialize(board)
      self.graph = Graph.new
      self.board = board

      add_board_positions(board)
      add_possible_movements_per_board_positions(board)
    end

    def move_legal?(start_square, final_square)
      raise StandardError, "Start square not present" if graph.adjacency_list[start_square].nil?
      raise StandardError, "Final square not present" if graph.adjacency_list[final_square].nil?

      graph.vertices_connected?(start_square, final_square)
    end

    private

    def add_board_positions(board)
      board.each_with_index do |row, row_idx|
        row.each_with_index do |col, col_idx|
          square_id = col
          square_coord = [col_idx, row_idx]

          graph.add_vertex(square_id, square_coord)
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
            graph.add_edge(square_id, target_id)
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

    def within_boundary?(coord, size = board.size)
      coord.all? { |point| point.between?(0, size - 1) }
    end
  end
end
