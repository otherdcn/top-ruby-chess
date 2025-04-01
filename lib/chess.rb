module Chess
  class ChessGameError < StandardError; end

  class Game
    attr_reader :chess_board, :captured_pieces_whites, :captured_pieces_blacks
    attr_accessor :player

    def initialize(chess_board:, players:)
      @chess_board            = chess_board

      @captured_pieces_whites = []
      @captured_pieces_blacks = []

      @player                 = nil
    end

    def display
      print "\n----------------------------------------------------------------------------------------"
        .colorize(color: :black, background: :white)
      puts

      chess_board.display
      puts

      puts "Turn to play #{player.name} (#{player.colour})"
        .colorize(color: :black, background: :white)
      puts

      print "Captured pieces -> "
      print captured_pieces_whites.map {|e| e.name}
        .join(" ")
        .colorize(color: :yellow)
      puts
    end

    def move_piece(from:, to:)
      start_piece = chess_board.check_square(from)
      end_piece = chess_board.check_square(to)

      raise ChessGameError, "#{start_piece.name} does not belong to "\
        "#{player.name}" unless start_piece_belongs_to_player?(start_piece)
      raise ChessGameError, "#{start_piece.name} cannot capture "\
        "#{end_piece.name}" unless end_piece_is_not_friendly?(start_piece, end_piece)
      raise ChessGameError, "#{start_piece.name} cannot move from "\
        "#{from} to #{to}" unless start_piece_can_complete_move?(start_piece, from, to)

      if end_piece == ""
        capture_empty_square(from, to, start_piece)
      else
        capture_opponent_square(from, to, start_piece, end_piece)
      end
    end

    def check_board_square(square:)
      object = chess_board.check_square(square)

      return "Square #{square} contains: #{object.name}" if object.is_a? ChessPiece::Piece

      "Square #{square} is empty"
    end

    def check_piece_next_moves(square:)
      piece = chess_board.check_square(square)

      raise ChessGameError, "Square #{square} is empty" if piece == ""

      print "Next moves for #{piece.name} -> "
      piece.next_moves(from: square, chess_board: chess_board).join(", ")
    end

    private

    def start_piece_belongs_to_player?(piece)
      piece.colour == player.colour
    end

    def end_piece_is_not_friendly?(start_piece, end_piece)
      return true if end_piece == ""

      start_piece.colour != end_piece.colour
    end

    def start_piece_can_complete_move?(start_piece, from, to)
      start_piece.reachable?(from: from, to: to, chess_board: chess_board)
    end

    def capture_opponent_square(from, to, start_piece, end_piece)
      chess_board.remove_from_square(to)
      captured_pieces_whites << end_piece

      capture_empty_square(from, to, start_piece)
      
      file = from.split.first

      return "x#{file}#{to}" if start_piece.instance_of? ChessPiece::Pawn

      "#{start_piece.name}x#{to}"
    end

    def capture_empty_square(from, to, piece)
      chess_board.remove_from_square(from)
      chess_board.add_to_square(to, piece)

      return "#{to}" if piece.instance_of? ChessPiece::Pawn

      "#{piece.name}#{to}"
    end
  end
end
