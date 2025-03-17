require_relative "../../lib/pieces/knight"
require_relative "../../lib/ds/graph"
require_relative "../../lib/board"

RSpec.describe ChessPiece::KnightGraph do
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

  def create_knight_moves_graph
    knight = described_class.new(graph: Graph.new,
                                 board: ChessBoard.new.board)
    knight
  end

  describe "#populate_graph" do
    it "fills the graph" do
      knight_graph = create_knight_moves_graph

      knight_graph.populate_graph

      # There's a coupling of the test code to the 'graph.adjacency_list'
      # dependency that could be costly down the line
      expect(knight_graph.graph.adjacency_list).to_not be_empty
    end
  end
end

RSpec.describe ChessPiece::KnightMoves do
  def create_knight_moves
    knight_graph = ChessPiece::KnightGraph.new(graph: Graph.new,
                                   board: ChessBoard.new.board)

    knight_graph.populate_graph

    knight_moves = ChessPiece::KnightMoves.new(graph: knight_graph.graph)
  end

  describe "#reachable?" do
    let(:knight) { create_knight_moves }

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

        knight = create_knight_moves

        move = knight.reachable?(from: start_square, to: end_square)

        expect(move).to eq true
      end

      it "returns false if illegal" do
        start_square = "a1"
        end_square = "c4" 

        knight = create_knight_moves

        move = knight.reachable?(from: start_square, to: end_square)

        expect(move).to eq false
      end
    end
  end

  describe "#next_moves" do
    let(:knight) { create_knight_moves }

    context "when input is invalid" do
      it "returns nil" do
        moves = knight.next_moves(from: "z1")

        expect(moves).to be_nil
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
