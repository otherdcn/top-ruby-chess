require_relative "../lib/player.rb"

RSpec.describe Player do
  describe "attributes" do
    context "with custom parameters" do
      it "creates a human player with black chess pieces" do
        joe = Human.new("Joe", "Black")

        expect(joe.name).to eq "joe"
        expect(joe.colour).to eq "black"
      end

      it "created a computer player with white chess pieces" do
        djin = Computer.new("Djin", "White")

        expect(djin.name).to eq "djin"
        expect(djin.colour).to eq "white"
      end
    end

    context "with default parameters" do
      it "creates a human player with white chess pieces" do
        hugh = Human.new

        expect(hugh.name).to eq "human hugh"
        expect(hugh.colour).to eq "white"
      end

      it "created a computer player with black chess pieces" do
        carl = Computer.new

        expect(carl.name).to eq "computer carl"
        expect(carl.colour).to eq "black"
      end
    end
  end
end
