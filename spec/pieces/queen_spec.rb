require_relative "../../lib/pieces/queen"
require_relative "../../lib/pieces/piece"
require_relative "./piece_spec.rb"

RSpec.describe ChessPiece::Queen do
  context 'Base class methods' do
    include_examples "can populate a graph"

    reachable_test_input = {
      "a1" => %w[a8 h8 a7 g7 a6 f6 a5 e5 a4 d4 a3 c3 a2 b2 b1 c1 d1 e1 f1 g1 h1].sort,
      "d4" => %w[d8 h8 a7 d7 g7 b6 d6 f6 c5 d5 e5 a4 b4 c4 d3 d2 d1 e4 f4 g4 h4 c3 b2 a1 e3 f2 g1].sort,
      "h8" => %w[a8 b8 c8 d8 e8 f8 g8 h7 h6 h5 h4 h3 h2 h1 g7 f6 e5 d4 c3 b2 a1].sort,
      validity: {valid: "a1", invalid: "z1"},
      legality: { from: "a1", to: "b3" }
    }

    include_examples "can check squares reachability", reachable_test_input

    next_moves_test_input = {
      "a1" => %w[a8 h8 a7 g7 a6 f6 a5 e5 a4 d4 a3 c3 a2 b2 b1 c1 d1 e1 f1 g1 h1].sort,
      "d4" => %w[d8 h8 a7 d7 g7 b6 d6 f6 c5 d5 e5 a4 b4 c4 d3 d2 d1 e4 f4 g4 h4 c3 b2 a1 e3 f2 g1].sort,
      "h8" => %w[a8 b8 c8 d8 e8 f8 g8 h7 h6 h5 h4 h3 h2 h1 g7 f6 e5 d4 c3 b2 a1].sort
    }
    include_examples "can provide next moves", next_moves_test_input
  end
end
