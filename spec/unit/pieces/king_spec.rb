require_relative "../../../lib/pieces/king"
require_relative "../../../lib/pieces/piece"
require_relative "../../../lib/board"
require_relative "./piece_spec.rb"

RSpec.describe ChessPiece::King do
  context 'Base class methods' do
    let(:piece) { described_class.new }
    let(:chess_board) { ChessBoard.new }

    include_examples "can populate a graph"

    reachable_test_input = {
      "a1" => %w[a2 b2 b1].sort,
      "d4" => %w[c5 d5 e5 c4 d3 e4 c3 e3].sort,
      "h8" => %w[g8 h7 g7].sort,
      validity: { valid: "a1", invalid: "z1" },
      legality: { from: "a1", to: "c3" }
    }

    include_examples "can check squares reachability", reachable_test_input

    next_moves_test_input = {
      "a1" => %w[a2 b2 b1].sort,
      "d4" => %w[c5 d5 e5 c4 d3 e4 c3 e3].sort,
      "h8" => %w[g8 h7 g7].sort
    }
    include_examples "can provide next moves", next_moves_test_input

    names = {
      short_format_name: "KW",
      long_format_name: "King White"
    }

    include_examples 'can return name', names
  end
end
