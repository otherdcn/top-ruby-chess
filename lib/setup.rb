require_relative "./player"
require_relative "./board"
require_relative "./pieces/all"

module Chess
  class Setup
    class << self
      def create_chess_board
        ChessBoard.new
      end

      def create_palyers
        puts "Would you like to play:"
        puts "1. Human vs Human"
        puts "2. Human vs Computer"

        mode = get_user_input(1..2)

        return create_human_vs_human if mode == 1

        create_human_vs_computer
      end

      def create_chess_pieces(colour: 'White', board: chess_board_grid)
        types = [
          {piece: ChessPiece::King, quantity: 1},
          {piece: ChessPiece::Queen, quantity: 1},
          {piece: ChessPiece::Bishop, quantity: 2},
          {piece: ChessPiece::Knight, quantity: 2},
          {piece: ChessPiece::Rook, quantity: 2},
          {piece: ChessPiece::Pawn, quantity: 8}
        ]
        all_pieces = []

        types.each do |type|
          all_pieces << create_piece(type[:piece], type[:quantity], colour, board)
        end

        all_pieces
      end

      def arrange_chess_board(chess_board:, white:, black:)
        chess_board.fill_rows(pieces: white)
        chess_board.fill_rows(pieces: black)
      end

      def promote_pawn(player_colour: "White")
        promotable_pieces = %w[Queen Rook Bishop Knight]

        puts "\nYour Pawn Piece has reached its last rank"
        puts "Replace with one of the following pieces:"
        promotable_pieces.each_with_index { |piece, idx| puts "#{idx + 1}> #{piece}" }
        user_input = (get_user_input(1..4) - 1) # subtract by 1 for zero-based index

        puts "Replacing with #{promotable_pieces[user_input]}\n"

        get_class_const(promotable_pieces[user_input], player_colour)
      end

      private

      def get_user_input(range)
        input_validity = false

        until input_validity
          print "Select number [#{range}]: "
          input = gets.chomp.strip.to_i
          validate_input(input, range) ? input_validity = true : puts("Wrong input;"\
            " please type between #{range}; try again")
        end

        input
      end

      def validate_input(input, range = 1..2)
        return true if range.cover? input
      end

      def chess_board_grid
        create_chess_board.board
      end

      def create_human_vs_human
        puts "\nPlaying Human vs Human..."

        print "First (white pieces) player's screen name: "
        player_1_name = gets.chomp
        player_white = Human.new(player_1_name, "White")

        print "Second (black pieces) player's screen name: "
        player_2_name = gets.chomp
        player_black = Human.new(player_2_name, "Black")

        [player_white, player_black]
      end

      def create_human_vs_computer
        puts "\nPlaying Human vs Computer..."

        print "Human (white pieces) player's screen name: "
        player_1_name = gets.chomp
        player_white = Human.new(player_1_name)

        print "Computer (black pieces) player's screen name: "
        player_2_name = gets.chomp
        player_black = Computer.new(player_2_name)

        [player_white, player_black]
      end

      def create_piece(type, quantity, colour, board)
        all_chess_pieces = []

        quantity.times do
          chess_piece = type.new(colour: colour)
          chess_piece.populate_graph(board: board)

          all_chess_pieces << chess_piece
        end

        return all_chess_pieces.first if quantity == 1

        all_chess_pieces
      end

      def get_class_const(klass_str, player_colour)
        klass = ChessPiece.const_get(klass_str)
        klass_obj = klass.new(colour: player_colour)
        klass_obj.populate_graph(board: chess_board_grid)

        klass_obj
      end
    end
  end
end
