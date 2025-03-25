require_relative '../ds/graph'

module ChessPiece
  class Error < StandardError; end

  class Piece
    include Graph

    attr_reader :colour, :type

    def initialize(colour: 'white', type:)
      @colour = colour
      @type = type
    end

    def name(long_format: false)
      return "#{type} #{colour}" if long_format
      return "#{type[1].upcase}#{colour[0]}" if type == "Knight"

      "#{type[0]}#{colour[0]}"
    end

    def reachable?(from:, to:)
      raise ChessPiece::Error, "Start square #{from} " \
      "not present" unless graph_of_moves(from)

      raise ChessPiece::Error, "Destination square #{to} " \
      "not present" unless graph_of_moves(to)

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
          square_coord = [row_idx, col_idx]

          add_square_to_board(square_id, square_coord)
        end
      end
    end

    def add_possible_movements_per_board_positions(board)
      board.each_with_index do |row, row_idx|
        row.each_with_index do |col, col_idx|
          square_id = col
          square_coord = [row_idx, col_idx]

          squares = generate_legal_squares(square_coord)

          squares.each do |target_coord|
            target_rank, target_file = target_coord

            target_id = board[target_rank][target_file]
            add_square_to_movements(square_id, target_id)
          end
        end
      end
    end

    def within_boundary?(coord, size = 8)
      coord.all? { |point| point.between?(0, size - 1) }
    end

    def graph_of_moves(key)
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
