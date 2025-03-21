require_relative "../../lib/pieces/bishop"
require_relative "../../lib/pieces/piece"
require_relative "./piece_spec.rb"

RSpec.describe ChessPiece::Bishop do
  context 'Base class methods' do
    include_examples "can populate a graph"

    reachable_test_input = {
      "a1" => %w[h8 g7 f6 e5 d4 c3 b2].sort,
      "d4" => %w[h8 a7 g7 b6 f6 c5 e5 c3 b2 a1 e3 f2 g1].sort,
      "h8" => %w[g7 f6 e5 d4 c3 b2 a1].sort,
      validity: {valid: "a1", invalid: "z1"},
      legality: { from: "a1", to: "b1" }
    }

    include_examples "can check squares reachability", reachable_test_input

    next_moves_test_input = {
      "a1" => %w[h8 g7 f6 e5 d4 c3 b2].sort,
      "d4" => %w[h8 a7 g7 b6 f6 c5 e5 c3 b2 a1 e3 f2 g1].sort,
      "h8" => %w[g7 f6 e5 d4 c3 b2 a1].sort
    }
    include_examples "can provide next moves", next_moves_test_input
  end
end
