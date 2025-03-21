require_relative "../../lib/pieces/knight"
require_relative "../../lib/pieces/piece"
require_relative "./piece_spec.rb"

RSpec.describe ChessPiece::Knight do
  context 'Base class methods' do
    include_examples "can populate a graph"

    reachable_test_input = {
      "a1" => %w[b3 c2].sort,
      "d4" => %w[c6 e6 b5 f5 f3 e2 c2 b3].sort,
      "h8" => %w[g6 f7].sort,
      validity: { valid: "a1", invalid: "z1" },
      legality: { from: "a1", to: "c3" }
    }

    include_examples "can check squares reachability", reachable_test_input

    next_moves_test_input = {
      "a1" => %w[b3 c2].sort,
      "d4" => %w[c6 e6 b5 f5 f3 e2 c2 b3].sort,
      "h8" => %w[g6 f7].sort
    }
    include_examples "can provide next moves", next_moves_test_input
  end
end
