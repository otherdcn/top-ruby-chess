require_relative "../../../lib/pieces/rook"
require_relative "../../../lib/pieces/piece"
require_relative "../../../lib/board"
require_relative "./piece_spec.rb"

RSpec.describe ChessPiece::Rook do
  context 'Base class methods' do
    let(:piece) { described_class.new }
    let(:chess_board) { ChessBoard.new }

    include_examples "can populate a graph"

    reachable_test_input = {
      "a1" => %w[a8 a7 a6 a5 a4 a3 a2 b1 c1 d1 e1 f1 g1 h1].sort,
      "d4" => %w[d8 d7 d6 d5 a4 b4 c4 e4 f4 g4 h4 d3 d2 d1].sort,
      "h8" => %w[a8 b8 c8 d8 e8 f8 g8 h7 h6 h5 h4 h3 h2 h1].sort,
      validity: {valid: "a1", invalid: "z1"},
      legality: { from: "a1", to: "b2" }
    }

    include_examples "can check squares reachability", reachable_test_input

    next_moves_test_input = {
      "a1" => %w[a8 a7 a6 a5 a4 a3 a2 b1 c1 d1 e1 f1 g1 h1].sort,
      "d4" => %w[d8 d7 d6 d5 a4 b4 c4 e4 f4 g4 h4 d3 d2 d1].sort,
      "h8" => %w[a8 b8 c8 d8 e8 f8 g8 h7 h6 h5 h4 h3 h2 h1].sort
    }
    include_examples "can provide next moves", next_moves_test_input

    names = {
      short_format_name: "RW",
      long_format_name: "Rook White"
    }

    include_examples 'can return name', names
  end
end
