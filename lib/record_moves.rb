module Chess
  class ChessGameError < StandardError; end

  class RecordMoves
    attr_reader :all_moves_made, :all_notation_messages

    def initialize
      @all_moves_made         = []
      @all_notation_messages  = []
    end

    def record_move(object_id:, piece_name:, from:, to:)
      new_move = {
        object_id: object_id,
        piece_name: piece_name,
        from: from,
        to: to
      }

      add_to_moves(new_move)

      new_move
    end

    def notation_message(move:, pawn: false, capture: false, special_moves: {}, end_of_game: {})
      piece_notation = pawn ? "" : move[:piece_name]
      file = pawn && capture ? move[:from].split("").first : ""
      captured = capture ? "x" : ""
      to = move[:to]

      return en_passant_message(file, captured, to) if special_moves.key? :en_passant
      return promotion_message(to, special_moves[:promotion]) if special_moves.key? :promotion
      return castling_message(special_moves[:castling]) if special_moves.key? :castling

      return check_message(piece_notation, file, captured, to) if end_of_game.key? :check
      return checkmate_message(piece_notation, file, captured, to) if end_of_game.key? :checkmate
      return win_message(end_of_game[:winner]) if end_of_game.key? :winner
      return draw_message if end_of_game.key? :draw

      # regular move -> capture empty square or capture opponent
      new_message = "#{piece_notation}#{file}#{captured}#{to}"
      add_to_messages(new_message)

      new_message
    end

    def last_move_made
      all_moves_made.last
    end

    def last_notation_message
      all_notation_messages.last
    end

    private

    def en_passant_message(file, captured, to)
      new_message = "#{file}#{captured}#{to} e.p."
      add_to_messages(new_message)

      new_message
    end

    def promotion_message(to, replacement)
      new_message = "#{to}=#{replacement}"
      add_to_messages(new_message)

      new_message
    end

    def castling_message(side)
      new_message = side == :kingside ? "0-0" : "0-0-0"
      add_to_messages(new_message)

      new_message
    end

    def check_message(piece_notation, file, captured, to)
      new_message = "#{piece_notation}#{file}#{captured}#{to}+"
      add_to_messages(new_message)

      new_message
    end

    def checkmate_message(piece_notation, file, captured, to)
      new_message = "#{piece_notation}#{file}#{captured}#{to}#"
      add_to_messages(new_message)

      new_message
    end

    def win_message(winner)
      new_message = winner == "White" ? "1-0" : "0-1"
      add_to_messages(new_message)

      new_message
    end
    
    def draw_message
      new_message = "½ – ½"
      add_to_messages(new_message)

      new_message
    end

    def add_to_messages(message)
      @all_notation_messages << message
    end

    def add_to_moves(move)
      @all_moves_made << move
    end
  end
end
