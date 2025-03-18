require_relative "../../lib/pieces/rook"
require_relative "../../lib/ds/graph"

RSpec.describe ChessPiece::Rook do
  def create_2d_board
    column_files = "a".upto("h").map(&:to_s)
    row_ranks = "1".upto("8").map(&:to_s).reverse
    board = []
    data = ({})

    row_ranks.map do |rank|
      row = []

      column_files.map do |file|
        square_id = file+rank

        row << square_id
        data[square_id] = ""
      end

      board << row
      row = []
    end

    board
  end

  describe "#populate_graph" do
    it "fills the graph" do
      rook = described_class.new

      rook.populate_graph(board: create_2d_board)

      expect(rook.adjacency_list).to_not be_empty
    end
  end

  describe "#reachable?" do
    let(:rook) { described_class.new }

    before do
      rook.populate_graph(board: create_2d_board)
    end

    context "when input is invalid" do
      let(:valid_input) { "a1" }
      let(:invalid_input) { "z1" }

      it "raises error for 'from' argument" do
        expect { rook.reachable?(from: invalid_input, to: valid_input) }
          .to raise_error(ChessPiece::Error, "Start square #{invalid_input} not present")
      end

      it "raises error for 'to' argument" do
        expect { rook.reachable?(from: valid_input, to: invalid_input) }
          .to raise_error(ChessPiece::Error, "Destination square #{invalid_input} not present")
      end
    end

    context "when input is valid" do
      it "returns true if legal" do
        start_square = "d4"
        end_square_1 = "d6" 
        end_square_2 = "b4" 
        end_square_3 = "e4" 
        end_square_4 = "d1" 

        move_1 = rook.reachable?(from: start_square, to: end_square_1)
        move_2 = rook.reachable?(from: start_square, to: end_square_2)
        move_3 = rook.reachable?(from: start_square, to: end_square_3)
        move_4 = rook.reachable?(from: start_square, to: end_square_4)

        expect(move_1).to eq true
        expect(move_2).to eq true
        expect(move_3).to eq true
        expect(move_4).to eq true
      end

      it "returns false if illegal" do
        start_square = "a1"
        end_square = "c4" 

        move = rook.reachable?(from: start_square, to: end_square)

        expect(move).to eq false
      end
    end
  end

  describe "#next_moves" do
    let(:rook) { described_class.new }

    before do
      rook.populate_graph(board: create_2d_board)
    end

    context "when input is invalid" do
      it "returns nil" do
        expect{ rook.next_moves(from: :key) }
          .to raise_error(StandardError, "Vertex not present")
      end
    end

    context "when input is valid" do
      it "returns array" do
        moves = rook.next_moves(from: "d4")

        expect(moves).to eq ["d8", "d7", "d6", "d5", "a4", "b4", "c4", "e4", "f4", "g4", "h4", "d3", "d2", "d1"]
      end
    end
  end
end
