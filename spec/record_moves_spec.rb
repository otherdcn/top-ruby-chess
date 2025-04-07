require_relative "../lib/record_moves"

RSpec.describe Chess::RecordMoves do
  def record_move_helper(piece_name: "PW", from_par: "a2,", to_par: "a4")
    subject.record_move(object_id: 1,
                        piece_name: piece_name,
                        from: from_par,
                        to: to_par)
  end

  describe "#record_moves" do
    subject { described_class.new }

    it 'returns a hash object' do
      object_id = 1
      piece_name = "PW"
      from = 'a2'
      to = 'a3'
      captured_opponent = false

      result = subject.record_move(object_id: object_id,
                                   piece_name: piece_name,
                                   from: from,
                                   to: to)

      expect(result).to be_a(Hash)
    end

    it 'adds to all_moves_made property' do
      object_id = 1
      piece_name = "PW"
      from = 'a2'
      to = 'a3'

      expect { subject.record_move(object_id: object_id,
                                   piece_name: piece_name,
                                   from: from,
                                   to: to) }
        .to change { subject.all_moves_made.size }
    end
  end

  describe "#notation_message" do
    subject { described_class.new }

    context "when made by Pawn piece" do
      context "and its a regular move" do
        it do
          move_made = record_move_helper(piece_name: "PW",
                                         from_par: "a2",
                                         to_par: "a4")

          message = subject.notation_message(move: move_made, pawn: true)

          expect(message).to eq "a4"
        end
      end

      context "when regular capture was made" do
        it do
          move_made = record_move_helper(piece_name: "PW",
                                         from_par: "a4",
                                         to_par: "b5")

          message = subject.notation_message(move: move_made,
                                             pawn: true,
                                             capture: true)
 
          expect(message).to eq "axb5"
        end
      end

      context "when en passant capture was made" do
        it do
          move_made = record_move_helper(piece_name: "PW",
                                         from_par: "a4",
                                         to_par: "b5")

          message = subject.notation_message(move: move_made,
                                             pawn: true,
                                             capture: true,
                                             special_moves: {en_passant: true})
 
          expect(message).to eq "axb5 e.p."
        end
      end

      context "when promotion was was achieved" do
        it do
          move_made = record_move_helper(piece_name: "PW",
                                         from_par: "b7",
                                         to_par: "b8")

          message = subject.notation_message(move: move_made,
                                             pawn: true,
                                             special_moves: {promotion: "QW"})
 
          expect(message).to eq "b8=QW"
        end
      end
    end

    context "when made by King piece" do
      context "and its a regular move was made" do
        it do
          move_made = record_move_helper(piece_name: "KB",
                                         from_par: "e7",
                                         to_par: "f7")

          message = subject.notation_message(move: move_made)
 
          expect(message).to eq "KBf7"
        end
      end

      context "and its a castling move" do
        it "returns 0-0-0 for queenside" do
          move_made = record_move_helper(piece_name: "KB",
                                         from_par: "e7",
                                         to_par: "f7")

          message = subject.notation_message(move: move_made,
                                             special_moves: {castling: :queenside})
 
          expect(message).to eq "0-0-0"
        end

        it "return '0-0' for kingside" do
          move_made = record_move_helper(piece_name: "KB",
                                         from_par: "e7",
                                         to_par: "f7")

          message = subject.notation_message(move: move_made,
                                             special_moves: {castling: :kingside})
 
          expect(message).to eq "0-0"
        end
      end

      context "and its a regular capture move" do
        it do
          move_made = record_move_helper(piece_name: "KB",
                                         from_par: "e7",
                                         to_par: "f7")

          message = subject.notation_message(move: move_made, capture: true)
 
          expect(message).to eq "KBxf7"
        end
      end
    end

    context "when made by all other pieces" do
      context "and its a regular move" do
        it do
          move_made = record_move_helper(piece_name: "NB",
                                         from_par: "g8",
                                         to_par: "h6")

          message = subject.notation_message(move: move_made)
 
          expect(message).to eq "NBh6"
        end
      end

      context "and its a regular capture move" do
        it do
          move_made = record_move_helper(piece_name: "NB",
                                         from_par: "g8",
                                         to_par: "h6")

          message = subject.notation_message(move: move_made, capture: true)
 
          expect(message).to eq "NBxh6"
        end
      end
    end

    it 'adds to all_notation_messages property' do
      move = record_move_helper

      expect { subject.notation_message(move: move,
                                        special_moves: {},
                                        end_of_game: {}) }
        .to change { subject.all_notation_messages }
    end

    context "when piece is in check" do
      it do
        move_made = record_move_helper(piece_name: "KB",
                                       from_par: "g4",
                                       to_par: "e3")

        message = subject.notation_message(move: move_made,
                                           end_of_game: { check: true })

        expect(message).to eq "KBe3+"
      end
    end

    context "when piece is in checkmate" do
      it do
        move_made = record_move_helper(piece_name: "KB",
                                       from_par: "g4",
                                       to_par: "e3")

        message = subject.notation_message(move: move_made,
                                           end_of_game: { checkmate: true })

        expect(message).to eq "KBe3#"
      end
    end

    context "when game is won" do
      it "returns '1-0' if white wins" do
        move_made = record_move_helper(piece_name: "KB",
                                       from_par: "g4",
                                       to_par: "e3")

        message = subject.notation_message(move: move_made,
                                           end_of_game: { winner: "White" })

        expect(message).to eq "1-0"
      end

      it "returns '0-1' if black wins" do
        move_made = record_move_helper(piece_name: "KB",
                                       from_par: "g4",
                                       to_par: "e3")

        message = subject.notation_message(move: move_made,
                                           end_of_game: { winner: "Black" })

        expect(message).to eq "0-1"
      end
    end

    context "when grame is drawn" do
      it do
        move_made = record_move_helper(piece_name: "KB",
                                       from_par: "g4",
                                       to_par: "e3")

        message = subject.notation_message(move: move_made,
                                           end_of_game: { draw: true })

        expect(message).to eq "½ – ½"
      end
    end
  end

  describe "#last_move_made" do
    it "returns latest entry to moves made" do
      subject.record_move(object_id: 1,
                          piece_name: "PW",
                          from: "a2",
                          to: "a3")

      result = subject.last_move_made[:object_id]

      expect(result).to eq 1
    end
  end

  describe "#last_notation_message" do
    it "returns latest entry to notation messages" do
      move = record_move_helper

      result = subject.notation_message(move: move)

      expect(subject.last_notation_message).to eq result
    end
  end
end
