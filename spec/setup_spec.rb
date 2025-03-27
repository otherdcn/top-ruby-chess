require_relative "../lib/setup"

RSpec.describe Chess::Setup do
  describe ".create_chess_board" do
    let(:subject) { described_class }

    it "sends an outgoing message" do
      expect(ChessBoard).to receive(:new)

      subject.create_chess_board
    end
  end

  describe ".create_palyers" do
    let(:subject) { described_class }

    context "when 'mode' input is invalid" do
      before do
        invalid_1   = 's'
        invalid_2   = '5'
        valid       = '1'
        allow(subject).to receive(:gets)
          .and_return(invalid_1, invalid_2, valid)
        allow(subject).to receive(:print)
          .with("First (white pieces) player's screen name: ")
        allow(subject).to receive(:print)
          .with("Second (black pieces) player's screen name: ")
      end

      it "calls 'puts' 5 times and 'print' 3 times" do
        expect(subject).to receive(:puts)
          .at_least(5).times
        expect(subject).to receive(:print)
          .with("Select number [1 or 2]: ")
          .exactly(3).times

        subject.create_palyers
      end
    end

    context "when 'mode' input is valid" do
      before do
        allow(subject).to receive(:puts).at_least(4).times
        allow(subject).to receive(:print).exactly(3).times
        allow(subject).to receive(:gets).and_return('1', "Joe", "Jabe")
      end

      it "returns an array" do
        expect(subject.create_palyers).to be_an(Array)
      end

      it "returns instances of Player class" do
        expect(subject.create_palyers).to all( be_a(Player) )
      end

      context "when mode is 1" do
        before do
          allow(subject).to receive(:gets).and_return('1', "Joe", "Jabe")
        end

        it "returns two instances of Human classes" do
          expect(subject.create_palyers).to all( be_a(Human) )
        end
      end

      context "when mode is 2" do
        before do
          allow(subject).to receive(:gets).and_return('2', "Joe", "Jabe")
        end

        it "returns two instance of Human and Computer classes" do
          players = subject.create_palyers

          expect(players).to include(a_kind_of(Human))
          expect(players).to include(a_kind_of(Computer))
        end
      end
    end
  end

  describe ".create_chess_pieces" do
    let(:subject) { described_class }
    let(:chess_piece_objects) { subject.create_chess_pieces }

    it "returns 16 chess piece objects overall" do
      expect(chess_piece_objects.flatten.size).to eq 16
    end

    it "returns 1 king" do
      expect(chess_piece_objects)
        .to include( a_kind_of(ChessPiece::King) )
        .once
    end

    it "returns 1 queen" do
      expect(chess_piece_objects)
        .to include( a_kind_of(ChessPiece::Queen) )
        .once
    end

    it "returns 2 bishops" do
      expect(chess_piece_objects.flatten)
        .to include( a_kind_of(ChessPiece::Bishop) )
        .twice
    end

    it "returns 2 knights" do
      expect(chess_piece_objects.flatten)
        .to include( a_kind_of(ChessPiece::Knight) )
        .twice
    end

    it "returns 2 rooks" do
      expect(chess_piece_objects.flatten)
        .to include( a_kind_of(ChessPiece::Rook) )
        .twice
    end

    it "returns 8 pawns" do
      expect(chess_piece_objects.flatten)
        .to include( a_kind_of(ChessPiece::Pawn) )
        .exactly(8).times
    end

    context "when colour argument is set to white" do
      let(:colour) { 'White' }
      let(:chess_piece_objects) { subject.create_chess_pieces(colour: colour) }

      it "returns 'white' chess pieces" do
        all_white = chess_piece_objects.flatten.all? { |obj| obj.colour == colour }

        expect(all_white).to be true
      end
    end

    context "when colour argument is set to black" do
      let(:colour) { 'Black' }
      let(:chess_piece_objects) { subject.create_chess_pieces(colour: colour) }

      it "returns 'black' chess pieces" do
        all_black = chess_piece_objects.flatten.all? { |obj| obj.colour == colour }

        expect(all_black).to be true
      end
    end
  end

  describe ".arrange_chess_board" do
    let(:subject) { described_class }
    let(:chess_board) { instance_double(ChessBoard) }
    let(:white_chess_pieces) { subject.create_chess_pieces }
    let(:black_chess_pieces) { subject.create_chess_pieces(colour: 'Black') }

    it "sends outgoing message" do
      expect(chess_board).to receive(:fill_rows).twice

      subject.arrange_chess_board(chess_board: chess_board,
                                  white: white_chess_pieces,
                                  black: black_chess_pieces)
    end
  end
end
