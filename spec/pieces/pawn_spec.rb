require_relative "../../lib/pieces/pawn"
require_relative "../../lib/pieces/piece"
require_relative "../../lib/board"
require_relative "./piece_spec.rb"

RSpec.describe ChessPiece::Pawn do
  context 'Base class methods' do
    include_examples "can populate a graph"

    context "when pawn is white" do
      let(:piece) { described_class.new(colour: 'White') }
      let(:chess_board) { ChessBoard.new }

      test_input = {
        "a1" => %w[a2].sort,
        "d4" => %w[d5].sort,
        "h8" => nil,
        validity: { valid: "a1", invalid: "z1" },
        legality: { from: "a1", to: "c3" }
      }

      include_examples "can check squares reachability", test_input

      include_examples "can provide next moves", test_input

      names = {
        short_format_name: "PW",
        long_format_name: "Pawn White"
      }

      include_examples 'can return name', names
    end

    context "when pawn is black" do
      let(:piece) { described_class.new(colour: 'Black') }
      let(:chess_board) { ChessBoard.new }

      test_input = {
        "a1" => nil,
        "d4" => %w[d3].sort,
        "h8" => %w[h7].sort,
        validity: { valid: "a7", invalid: "z7" },
        legality: { from: "a7", to: "c5" }
      }

      include_examples "can check squares reachability", test_input

      include_examples "can provide next moves", test_input

      names = {
        short_format_name: "PB",
        long_format_name: "Pawn Black"
      }

      include_examples 'can return name', names
    end
  end
end
