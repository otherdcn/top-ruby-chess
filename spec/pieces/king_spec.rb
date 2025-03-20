require_relative "../../lib/pieces/king"
require_relative "../../lib/pieces/piece"
require_relative "./piece_spec.rb"

RSpec.describe ChessPiece::King do
  context 'Base class methods' do
    include_examples "can populate a graph"

    reachable_test_input = {
      "a1" => %w[a2 b2 b1],
      "d4" => %w[c5 d5 e5 c4 d3 e4 c3 e3],
      "h8" => %w[g8 h7 g7],
      validity: { valid: "a1", invalid: "z1" },
      legality: { from: "a1", to: "c3" }
    }

    include_examples "can check squares reachability", reachable_test_input

    next_moves_test_input = {
      "a1" => %w[a2 b2 b1],
      "d4" => %w[c5 d5 e5 c4 d3 e4 c3 e3],
      "h8" => %w[g8 h7 g7]
    }
    include_examples "can provide next moves", next_moves_test_input
  end
end
