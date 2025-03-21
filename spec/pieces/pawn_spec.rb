require_relative "../../lib/pieces/pawn"
require_relative "../../lib/pieces/piece"
require_relative "./piece_spec.rb"

RSpec.describe ChessPiece::Pawn do
  xcontext 'Base class methods' do
    include_examples "can populate a graph"

    test_input = {
      "a1" => %w[a2 b2 b1].sort,
      "d4" => %w[c5 d5 e5 c4 d3 e4 c3 e3].sort,
      "h8" => %w[g8 h7 g7].sort,
      validity: { valid: "a1", invalid: "z1" },
      legality: { from: "a1", to: "c3" }
    }

    include_examples "can check squares reachability", test_input

    include_examples "can provide next moves", test_input
  end
end
