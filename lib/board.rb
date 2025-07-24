class ChessBoard
  attr_reader :board, :data

  COLUMN_FILES = "a".upto("h").map(&:to_s)
  ROW_RANKS = "1".upto("8").map(&:to_s).reverse

  def initialize
    @board = []
    @data = ({})

    create_board
  end

  def create_board
    ROW_RANKS.map do |rank|
      row = []

      COLUMN_FILES.map do |file|
        square_id = file+rank

        row << square_id
        @data[square_id] = ""
      end

      @board << row
      row = []
    end
  end

  def display
    board.each do |row|
      row.each do |column|
        print "[ #{column} - #{chess_piece_name(data[column])} ]"
      end

      puts
    end
  end

  def check_square(square_id)
    raise StandardError, "No such square (#{square_id}) present" if data[square_id].nil?

    data[square_id]
  end

  def add_to_square(square_id, chess_piece)
    raise StandardError, "No such square (#{square_id}) present" if data[square_id].nil?

    @data[square_id] = chess_piece
  end

  def remove_from_square(square_id)
    raise StandardError, "No such square (#{square_id}) present" if data[square_id].nil?

    @data[square_id] = ""
  end

  def fill_rows(pieces:, pawn_row: false)
    rows_to_fill_up = { white: { for_pawns: 6, other: 7},
                        black: { for_pawns: 1, other: 0 } }

    rows = if colour_of_pieces(pieces) == 'White'
             rows_to_fill_up[:white]
           else
             rows_to_fill_up[:black]
           end

    board.each_with_index do |row, row_idx|
      if row_idx == rows[:for_pawns]
        insert_pawn_pieces(row, pieces)
      elsif row_idx == rows[:other]
        insert_other_pieces(row, pieces)
      end
    end
  end

  # Use 'method_missing' to combine 'find_all_pieces_for_*' methods
  def find_all_pieces_for_colour(colour: "White")
    square_with_pieces = data.select do |square_id, square_content|
      next unless square_content.respond_to? :colour

      square_content.colour == colour
    end

    square_with_pieces.keys
  end

  def find_all_pieces_for_type(type: "King")
    square_with_pieces = data.select do |square_id, square_content|
      next unless square_content.respond_to? :type

      square_content.type == type
    end

    square_with_pieces.keys
  end

  private

  def chess_piece_name(obj)
    obj.respond_to?(:name) ? obj.name : "".ljust(2)
  end

  def colour_of_pieces(pieces)
    pieces.flatten.first.colour
  end

  def insert_pawn_pieces(row, pieces)
    _, _, _, _, _, pawns = pieces

    row.each_with_index do |col, col_idx|
      add_to_square(col, pawns[col_idx])
    end
  end

  def insert_other_pieces(row, pieces)
    king, queen, bishops, knights, rooks, _ = pieces

    add_to_square(row[0], rooks.first)
    add_to_square(row[1], knights.first)
    add_to_square(row[2], bishops.first)
    add_to_square(row[3], queen)
    add_to_square(row[4], king)
    add_to_square(row[5], bishops.last)
    add_to_square(row[6], knights.last)
    add_to_square(row[7], rooks.last)
  end
end
