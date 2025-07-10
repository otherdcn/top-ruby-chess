require_relative "../../../lib/pieces/piece"
require_relative "../../../lib/ds/graph"

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


RSpec.shared_examples 'can populate a graph' do
  describe "#populate_graph" do
    it "fills the graph" do
      piece = described_class.new

      piece.populate_graph(board: create_2d_board)

      expect(piece.adjacency_list).to_not be_empty
    end
  end
end

RSpec.shared_examples 'can check squares reachability' do |test_input|
  describe "#reachable?" do
    before do
      piece.populate_graph(board: create_2d_board)
    end

    context "when input is invalid" do
      let(:valid_input) { test_input[:validity][:valid] }
      let(:invalid_input) { test_input[:validity][:invalid] }

      it "raises error for 'from' argument" do
        expect { piece.reachable?(from: invalid_input,
                                  to: valid_input,
                                  chess_board: chess_board) }
          .to raise_error(ChessPiece::Error,
                          "Start square #{invalid_input} not present")
      end

      it "raises error for 'to' argument" do
        expect { piece.reachable?(from: valid_input,
                                  to: invalid_input,
                                  chess_board: chess_board) }
          .to raise_error(ChessPiece::Error,
                          "Destination square #{invalid_input} not present")
      end
    end

    context "when input is valid" do
      it "returns true from 'a1' to ...(range of elements from a test array)" do
        start_square = "a1"
        end_squares = test_input[start_square]

        if end_squares.nil?
          truthy_result = true
        else
          results = end_squares.map do |end_square|
            piece.reachable?(from: start_square,
                             to: end_square,
                             chess_board: chess_board)
          end

          truthy_result = results.all? true
        end

        expect(truthy_result).to be true
      end

      it "returns true from 'd4' to ...(range of elements from a test array)" do
        start_square = "d4"
        end_squares = test_input[start_square]

        if end_squares.nil?
          truthy_result = true
        else
          results = end_squares.map do |end_square|
            piece.reachable?(from: start_square,
                             to: end_square,
                             chess_board: chess_board)
          end

          truthy_result = results.all? true
        end

        expect(truthy_result).to be true
      end

      it "returns true from 'h8' to ...(range of elements from a test array)" do
        start_square = "h8"
        end_squares = test_input[start_square]

        if end_squares.nil?
          truthy_result = true
        else
          results = end_squares.map do |end_square|
            piece.reachable?(from: start_square,
                             to: end_square,
                             chess_board: chess_board)
          end

          truthy_result = results.all? true
        end

        expect(truthy_result).to be true
      end

      it "returns false if illegal" do
        start_square = test_input[:legality][:from]
        end_square = test_input[:legality][:to]

        move = piece.reachable?(from: start_square,
                                to: end_square,
                                chess_board: chess_board)

        expect(move).to eq false
      end
    end
  end
end

RSpec.shared_examples 'can provide next moves' do |test_input|
  describe "#next_moves" do
    before do
      piece.populate_graph(board: create_2d_board)
    end

    context "when input is invalid" do
      it "raises an error" do
        expect{ piece.next_moves(from: :key, chess_board: chess_board) }
          .to raise_error(StandardError, "Vertex not present")
      end
    end

    context "when input is valid" do
      it "returns array for 'a1'" do
        square = "a1"
        moves = piece.next_moves(from: square, chess_board: chess_board)
        moves = moves.nil? ? moves : moves.sort
        results = test_input[square]

        expect(moves).to eq results
      end

      it "returns array for 'd4'" do
        square = "d4"
        moves = piece.next_moves(from: square, chess_board: chess_board)
        moves = moves.nil? ? moves : moves.sort
        results = test_input[square]

        expect(moves).to eq results
      end

      it "returns array for 'h8'" do
        square = "h8"
        moves = piece.next_moves(from: square, chess_board: chess_board)
        moves = moves.nil? ? moves : moves.sort
        results = test_input[square]

        expect(moves).to eq results
      end
    end
  end
end

RSpec.shared_examples 'can return name' do |test_input|
  describe "#name" do
    context "when no argument is given" do
      it "returns a short concatenated string of type and colour" do
        expect(piece.name).to eq test_input[:short_format_name]
      end
    end
    context "when an argument is given" do
      it "returns a long concatenated string of type and colour" do
        expect(piece.name(long_format: true)).to eq test_input[:long_format_name]
      end
    end
  end
end
