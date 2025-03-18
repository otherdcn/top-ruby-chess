require_relative "../../lib/pieces/knight"
require_relative "../../lib/ds/graph"

RSpec.describe ChessPiece::Knight do
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
      knight = described_class.new

      knight.populate_graph(board: create_2d_board)

      expect(knight.adjacency_list).to_not be_empty
    end
  end

  describe "#reachable?" do
    let(:knight) { described_class.new }

    before do
      knight.populate_graph(board: create_2d_board)
    end

    context "when input is invalid" do
      let(:valid_input) { "a1" }
      let(:invalid_input) { "z1" }

      it "raises error for 'from' argument" do
        expect { knight.reachable?(from: invalid_input, to: valid_input) }
          .to raise_error(ChessPiece::Error, "Start square #{invalid_input} not present")
      end

      it "raises error for 'to' argument" do
        expect { knight.reachable?(from: valid_input, to: invalid_input) }
          .to raise_error(ChessPiece::Error, "Destination square #{invalid_input} not present")
      end
    end

    context "when input is valid" do
      it "returns true if legal" do
        start_square = "a1"
        end_square = "c2" 

        move = knight.reachable?(from: start_square, to: end_square)

        expect(move).to eq true
      end

      it "returns false if illegal" do
        start_square = "a1"
        end_square = "c4" 

        move = knight.reachable?(from: start_square, to: end_square)

        expect(move).to eq false
      end
    end
  end

  describe "#next_moves" do
    let(:knight) { described_class.new }

    before do
      knight.populate_graph(board: create_2d_board)
    end

    context "when input is invalid" do
      it "returns nil" do
        expect{ knight.next_moves(from: :key) }
          .to raise_error(StandardError, "Vertex not present")
      end
    end

    context "when input is valid" do
      it "returns array" do
        moves = knight.next_moves(from: "a1")

        expect(moves).to eq ["b3", "c2"]
      end
    end
  end
end
