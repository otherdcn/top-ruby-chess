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
        print "[#{column} - #{data[column]}]"
      end

      puts
    end
  end

  def check_square(square_id)
    raise StandardError, "No such square (#{square_id}) present" if data[square_id].nil?

    data[square_id]
  end
end
