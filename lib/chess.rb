module Chess
  class ChessGameError < StandardError; end

  class Game
    attr_reader :chess_board, :captured_pieces, :chess_moves
    attr_accessor :player

    def initialize(chess_board:, chess_moves:)
      @original_board         = chess_board
      @chess_board            = chess_board

      @captured_pieces = []

      @player                 = nil

      @chess_moves           = chess_moves
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
      print captured_pieces.map {|e| e.name}
        .join(" ")
        .colorize(color: :yellow)
      puts

      puts "\n*** #{player.colour.upcase} KING IS IN CHECK ***".colorize(color: :yellow) if is_check?
    end

    def play(from:, to:)
      move_piece(from: from, to: to)
    end

    def check_board_square(square:)
      object = chess_board.check_square(square)

      return object.name if object.is_a? ChessPiece::Piece
    end

    def end_game?
      return false unless is_checkmate?

      true
    end

    def announce_winner
      winner = player.colour == "White" ? "Black" : "White"
      loser = player.colour

      puts "********** CHECKMATE against #{loser} **********\n"
      puts "Game over, #{winner} Wins!\n"
      puts "********** CHECKMATE against #{loser}**********\n"
    end

    private

    def move_piece(from:, to:)
      if is_check?
        check_removal_move(from, to)
      else
        normal_move(from, to)
      end
    end

    def check_removal_move(from, to)
      switch_chessboard(board: :simulation) # simulate board until no more check
      normal_move(from, to)

      raise ChessGameError, "#{player.colour.upcase} KING STILL"\
        " IN CHECK" if is_check?

      switch_chessboard(board: :original) # switch to original when no check
      normal_move(from, to)
    end

    def normal_move(from, to)
      start_piece = chess_board.check_square(from)
      end_piece = chess_board.check_square(to)

      raise ChessGameError, "#{from} is an empty square" unless start_piece
        .respond_to? :name
      raise ChessGameError, "#{start_piece.name} does not belong to "\
        "#{player.name}" unless start_piece_belongs_to_player?(start_piece)

      return castle(start_piece, from, to) if castling_possible?(start_piece,
                                                                 from, to)

      raise ChessGameError, "#{start_piece.name} cannot capture "\
        "#{end_piece.name}" unless end_piece_is_not_friendly?(start_piece, end_piece)

      return en_passant(from, to) if en_passant_possible?(start_piece, from, to)

      raise ChessGameError, "#{start_piece.name} cannot move from "\
        "#{from} to #{to}" unless start_piece_can_complete_move?(start_piece, from, to)

      return promotion(start_piece, end_piece,
                       from, to) if promotion_possible?(start_piece, to)

      capture(start_piece, end_piece, from, to, {})
    end

    def capture(start_piece, end_piece, from, to, special_moves)
      if end_piece == ""
        capture_empty_square(from, to, start_piece, false, special_moves)
      else
        capture_opponent_square(from, to, start_piece, end_piece, special_moves)
      end
    end

    def check_piece_next_moves(square:)
      piece = chess_board.check_square(square)

      raise ChessGameError, "Square #{square} is empty" if piece == ""

      print "Next moves for #{piece.name} -> "
      piece.next_moves(from: square, chess_board: chess_board).join(", ")
    end

    def en_passant_possible?(start_piece, from, to)
      adjacent_squares = check_pawn_adjacent_files(from)

      if to.split("").first.succ == from.split("").first
        square = adjacent_squares[:left_square]
        adjacent_file_piece = square.nil? ? nil : chess_board.check_square(square)
      else
        square = adjacent_squares[:right_square]
        adjacent_file_piece = square.nil? ? nil : chess_board.check_square(square)
      end

      @en_passant_attr = {
        start_piece: start_piece,
        adjacent_file_piece: adjacent_file_piece,
        square: square
      }

      both_are_pawns?(start_piece, adjacent_file_piece) &&
        last_move?(adjacent_file_piece)
    end

    def en_passant(from, to)
      remove_piece(@en_passant_attr[:square],
                   @en_passant_attr[:adjacent_file_piece])
      capture_empty_square(from, to,
                           @en_passant_attr[:start_piece],
                           true, {en_passant: true})
    end

    def promotion_possible?(start_piece, to)
      rank = to.split("").last
      final_rank = rank.to_i == 1 || rank.to_i == 8
      pawn_piece = start_piece.instance_of? ChessPiece::Pawn

      final_rank && pawn_piece
    end

    def promotion(start_piece, end_piece, from, to)
      replacement_piece = Chess::Setup.promote_pawn(player_colour: player.colour)

      notation_message = capture(start_piece, end_piece, from, to,
                                 { promotion: replacement_piece.name })

      add_piece(to, to, replacement_piece)
      notation_message
    end

    def castling_possible?(king_piece, from, to)
      if from == "e1" && to == "c1"
        add_to_castling_attr(chess_board.check_square("a1"),
                             "a1", "d1", :queenside)
      elsif from == "e8" && to == "c8"
        add_to_castling_attr(chess_board.check_square("a8"),
                             "a8", "d8", :queenside)
      elsif from == "e1" && to == "g1"
        add_to_castling_attr(chess_board.check_square("h1"),
                             "h1", "f1", :kingside)
      elsif from == "e8" && to == "g8"
        add_to_castling_attr(chess_board.check_square("h8"),
                             "h8", "f8", :kingside)
      else
        return false
      end

      raise ChessGameError, "CANNOT CASTLE: #{player.colour.upcase} "\
        "KING STILL IN CHECK" if is_check?
      raise ChessGameError, "CANNOT CASTLE: #{player.colour.upcase} "\
        "KING MOVING TO CHECK" if moving_to_check?(to, @castling_attr[:side])
      raise ChessGameError, "CANNOT CASTLE: #{player.colour.upcase} "\
        "KING MOVING THROUGH CHECK" if moving_through_check?(to,
                                                             @castling_attr[:side])

      no_movement = made_no_move_yet?(king_piece.object_id,
                                       @castling_attr[:rook].object_id)
      no_inbetween = nothing_between_king_and_rook?(king_piece.name,
                                     @castling_attr[:side])

      return true if no_movement && no_inbetween
    end

    def castle(king_piece, from, to)
      capture(@castling_attr[:rook],
              "",
              @castling_attr[:from],
              @castling_attr[:to],
              { ignore_rook_movement: true })
      capture(king_piece,
              "",
              from,
              to,
              { castling: @castling_attr[:side] })
    end

    def add_to_castling_attr(rook, from, to, side)
      @castling_attr = { rook: rook, from: from, to: to, side: side }
    end

    def made_no_move_yet?(king_piece_id, rook_piece_id)
      no_movement = chess_moves.all_moves_made.none? do |move|
        move[:object_id] == king_piece_id || move[:object_id] == rook_piece_id
      end

      raise ChessGameError, "King or Rook has already moved" unless no_movement

      no_movement
    end

    def nothing_between_king_and_rook?(name, side)
      if side == :kingside && name.include?("W")
        nothing_in_between = check_squares_by_king(%w[f1 g1])
      elsif side == :kingside && name.include?("B")
        nothing_in_between = check_squares_by_king(%w[f8 g8])
      elsif side == :queenside && name.include?("W")
        nothing_in_between = check_squares_by_king(%w[b1 c1 d1])
      elsif side == :queenside && name.include?("B")
        nothing_in_between = check_squares_by_king(%w[b8 c8 d8])
      end

      raise ChessGameError, "There are pieces between King and Rook" unless nothing_in_between

      nothing_in_between
    end

    def check_squares_by_king(squares)
      squares.map { |sq| chess_board.check_square(sq) }.all? { |sq| sq.empty? }
    end

    def switch_chessboard(board: :original)
      if board == :original
        @chess_board = @original_board
      elsif board == :simulation
        @chess_board = set_simulation_board
      end
    end

    def set_simulation_board
      @original_board.create_simulation_board
    end

    def is_check?
      current_player_king = player.colour == "White" ? "KW" : "KB"
      current_player_king_location = king_current_location(current_player_king)

      opponents_colour = player.colour == "White" ? "Black" : "White"
      check = opponents_next_moves(opponents_colour)
        .include?(current_player_king_location)

      return check
    end

    def moving_to_check?(to, castling_side = nil)
      current_player_king = player.colour == "White" ? "KW" : "KB"
      current_player_king_location = king_current_location(current_player_king)

      king_piece = chess_board.check_square(current_player_king_location)
      king_piece_next_moves = king_piece
        .next_moves(from: current_player_king_location,
                    chess_board: chess_board)

      if castling_side
        king_piece_next_moves.push(castling_endpoint(player.colour,castling_side))
      end

      opponents_colour = player.colour == "White" ? "Black" : "White"
      check = opponents_next_moves(opponents_colour).include?(to)

      king_piece_next_moves.include?(to) && check
    end

    def moving_through_check?(to, castling_side = nil)
      current_player_king = player.colour == "White" ? "KW" : "KB"
      current_player_king_location = king_current_location(current_player_king)

      king_piece = chess_board.check_square(current_player_king_location)
      king_piece_next_moves = king_piece
        .next_moves(from: current_player_king_location,
                    chess_board: chess_board)

      if castling_side
        king_piece_next_moves.push(castling_endpoint(player.colour,castling_side))
      end

      opponents_colour = player.colour == "White" ? "Black" : "White"
      all_opponents_next_moves = opponents_next_moves(opponents_colour)
      check = (all_opponents_next_moves & king_piece_next_moves).any?

      return king_piece_next_moves.include?(to) && check
    end

    def is_checkmate?
      current_player_king = player.colour == "White" ? "KW" : "KB"
      current_player_king_location = king_current_location(current_player_king)

      king_piece = chess_board.check_square(current_player_king_location)
      king_piece_next_moves_array = king_piece
        .next_moves(from: current_player_king_location,
                    chess_board: chess_board)

      opponents_colour = player.colour == "White" ? "Black" : "White"
      opponents_next_moves_array = opponents_next_moves(opponents_colour)

      is_check? && (king_piece_next_moves_array - opponents_next_moves_array).empty?
    end

    def castling_endpoint(colour, side = :kingside)
      end_points = {
        "White" => { kingside: "g1", queenside: "c1" },
        "Black" => { kingside: "g8", queenside: "c8" }
      }

      end_points[colour][side]
    end

    def king_current_location(piece_name)
      first, second = chess_board.find_all_pieces_for_type(type: "King")

      first_element_name = chess_board.check_square(first).name

      return first.strip if first_element_name == piece_name

      second.strip
    end

    def opponents_next_moves(colour)
      opponents_positions = chess_board.find_all_pieces_for_colour(colour: colour)

      all_moves = []
      opponents_positions.each do |square|
        all_moves << chess_board.check_square(square)
          .next_moves(from: square, chess_board: chess_board).flatten
      end

      all_moves.flatten
    end

    def check_pawn_adjacent_files(square)
      file, rank = square.split("")

      left_file = (file.ord - 1).chr
      right_file = (file.ord + 1).chr

      left_square = valid_file?(left_file) ? left_file + rank : nil
      right_square = valid_file?(right_file) ? right_file + rank : nil

      {left_square: left_square, right_square: right_square}
    end

    def valid_file?(file)
      file.between?("a","h")
    end

    def both_are_pawns?(start_piece, end_piece)
      return false if end_piece.nil?

      same_type = start_piece.instance_of?(ChessPiece::Pawn) &&
        end_piece.instance_of?(ChessPiece::Pawn)

      different_colour = end_piece_is_not_friendly?(start_piece,
                                                    end_piece)

      same_type && different_colour
    end

    def last_move?(piece)
      last_move_made = chess_moves.last_move_made
      start_square = last_move_made[:from]
      end_square = last_move_made[:to]
      piece_colour = last_move_made[:piece_name].split("").last

      double_forward = double_forward_movement(start_square,
                                               end_square,
                                               piece_colour)

      same_object = last_move_made[:object_id] == piece.object_id

      double_forward && same_object
    end

    def same_object_move(recorded_object_id, piece_id)
      recorded_object_id == piece_id
    end

    def double_forward_movement(start_square, end_square, colour)
      start_row = start_square.split("").last.to_i
      end_row = end_square.split("").last.to_i

      return start_row.pred.pred == end_row if colour == "B"

      start_row.next.next == end_row
    end

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

    def capture_opponent_square(from, to, start_piece, end_piece, special_moves = {})
      remove_piece(to, end_piece)

      capture_empty_square(from, to, start_piece, true, special_moves)
    end

    def remove_piece(to, end_piece)
      chess_board.remove_from_square(to)
      add_to_captured_pieces(end_piece)
    end

    def add_to_captured_pieces(piece)
      captured_pieces << piece unless chess_board.respond_to? :simulation?
    end

    def add_piece(from, to, piece)
      chess_board.remove_from_square(from)
      chess_board.add_to_square(to, piece)
    end

    def capture_empty_square(from, to, piece, captured_opponent = false, special_moves = {}, end_of_game = {})
      add_piece(from, to, piece)
      piece_is_pawn = piece.instance_of? ChessPiece::Pawn

      return if special_moves[:ignore_rook_movement]
      return if chess_board.respond_to? :simulation?

      move = chess_moves.record_move(object_id: piece.object_id,
                                     piece_name: piece.name,
                                     from: from,
                                     to: to)

      chess_moves.notation_message(move: move,
                                   pawn: piece_is_pawn,
                                   capture: captured_opponent,
                                   special_moves: special_moves,
                                   end_of_game: end_of_game)
    end
  end
end
