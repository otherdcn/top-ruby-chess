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

    def reachable?(from:, to:, chess_board:)
      raise ChessPiece::Error, "Start square #{from} " \
      "not present" unless graph_of_moves(from)

      raise ChessPiece::Error, "Destination square #{to} " \
      "not present" unless graph_of_moves(to)

      next_moves(from: from, chess_board: chess_board).include?(to)
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

          if piece == ""
            legal_squares << square
          elsif piece.colour == colour
            break
          else
            legal_squares << square
            break
          end
        end
      end

      legal_squares
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

    def square_group(square_id, next_square, board)
      directions = generate_moves_squares(square_id, board)

      directions.each do |direction, coords|
        return direction if coords.include? next_square
      end
    end

    def generate_moves_squares(square_id, board)
      directions_hash = {}

      current_square = find_in_2d_array(board, square_id)
      moves = get_moves

      moves.each do |directions, coord|
        squares = []

        (1..7).each do |shift_factor|
          new_coord = coord.map { |ele| ele * shift_factor }
          new_square = shift_squares(new_coord, current_square)

          if within_boundary?(new_square)
            squares << board[new_square[0]][new_square[1]]
          else
            break
          end
        end
        directions_hash[directions] = squares
      end

      directions_hash
    end

    def find_in_2d_array(array, element)
      row = nil
      col = nil

      array.each_with_index do |row_of_ele, row_idx|
        row = row_idx

        col = row_of_ele.find_index(element)
        break if col
      end

      [row, col]
    end
  end
end
