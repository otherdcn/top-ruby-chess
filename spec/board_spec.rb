require_relative "../lib/board"

RSpec.describe ChessBoard do
  describe "#create_board" do
    subject { described_class.new }

    it "creates a multi-dimensional array instance variable" do
      expect(subject.board).to be_a(Array)
      expect(subject.board.first).to be_a(Array)
    end

    it "fills a hash instance variable with 64 k-v pairs" do
      expect(subject.data).to be_a(Hash)
      expect(subject.data.size).to eq 64
    end
  end

  describe "#check_square" do
    subject { described_class.new }

    context "when square_id input is invalid" do
      let(:invalid_square_id) { "z20" }

      it { expect { subject.check_square(invalid_square_id) }
                  .to raise_error(StandardError, 
                                  "No such square (#{invalid_square_id}) present") }
    end

    context "when square_id input is valid" do
      let(:valid_square_id) { "d4" }

      before do
        subject.data[valid_square_id] = "test_data"
      end

      it { expect(subject.check_square(valid_square_id)).to_not be_nil }
      it { expect(subject.check_square(valid_square_id)).to eq "test_data" }
    end
  end

  describe "#add_to_square" do
    let(:chess_piece) { "knight_white" }

    context "when square_id input is invalid" do
      let(:invalid_square_id) { "z20" }

      it { expect { subject.add_to_square(invalid_square_id, chess_piece) }
                  .to raise_error(StandardError,
                                  "No such square (#{invalid_square_id}) present") }
    end

    context "when square_id input is valid" do
      let(:valid_square_id) { "c6" }

      it { expect { subject.add_to_square(valid_square_id, chess_piece) }.to change { subject.data[valid_square_id] }.from("").to("knight_white") }
    end
  end

  describe "#remove_from_square" do
    subject { described_class.new }

    context "when square_id input is invalid" do
      let(:invalid_square_id) { "z20" }

      it { expect { subject.remove_from_square(invalid_square_id) }
                  .to raise_error(StandardError,
                                  "No such square (#{invalid_square_id}) present") }
    end

    context "when square_id input is valid" do
      before do
        subject.data[valid_square_id] = "knight_white"
      end

      let(:valid_square_id) { "c6" }

      it { expect { subject.remove_from_square(valid_square_id) }.to change { subject.data[valid_square_id] }.from("knight_white").to("") }
    end
  end

  describe "#fill_rows" do
    # Batch process of #add_to_square
  end
end
