require_relative "../../lib/ds/graph"

RSpec.describe Vertex do
  describe "#<=>" do
    subject { described_class.new(10) }

    it "returns 1 if the receiver object is bigger" do
      other_vertex_obj = Vertex.new(5)

      expect(subject <=> other_vertex_obj).to eq 1
    end

    it "returns -1 if the receiver object is smaller" do
      other_vertex_obj = Vertex.new(15)

      expect(subject <=> other_vertex_obj).to eq -1
    end

    it "returns 0 if the receiver object is equal" do
      other_vertex_obj = Vertex.new(10)

      expect(subject <=> other_vertex_obj).to eq 0
    end
  end

  describe "#shortest_path" do
  end
end

class GraphTest
  include Graph
end

RSpec.describe GraphTest do
  describe "#empty?" do
    subject { described_class.new }

    it "returns true when instantiated" do
      expect(subject).to be_empty
    end

    it "returns false when vertex is added" do
      subject.add_vertex(:first_vertex, 100)

      expect(subject).to_not be_empty
    end
  end

  describe "#add_vertex" do
    subject { described_class.new }

    before do
      subject.add_vertex(:first_vertex, 100)
    end

    it "adds new vertex to graph's adjencency list" do
      subject.add_vertex(:first_vertex, 100)

      expect(subject.adjacency_list.has_key? :first_vertex).to be true
    end

    it "returns vertex's key" do
      key = subject.add_vertex(:first_vertex, 100)

      expect(key).to eq :first_vertex
    end
  end

  describe "#vertex" do
    subject { described_class.new }

    context "when key is present in adjacency list hash" do
      before do
        subject.add_vertex(:key, 100)
      end

      it "returns the vertex" do
        expect(subject.vertex(:key)).to be_a(Vertex)
      end
    end

    context "when key is not present in adjacency list hash" do
      it "returns the nil" do
        expect { subject.vertex(:key) }.
          to raise_error(StandardError, "Vertex not present")
      end
    end
  end

  describe "#add_edge" do
    before do
      allow(subject).to receive(:vertices_connected?).and_return(false)
    end

    subject { described_class.new }

    context "when source vertex is not present" do
      before do
        subject.add_vertex(:target, "target vertex")
      end

      it "raises an error" do
        expect { subject.add_edge(:source, :target) }.to raise_error(StandardError,
                                                                  "Source vertex not present")
      end
    end

    context "when target vertex is not present" do
      before do
        subject.add_vertex(:source, "source vertex")
      end

      it "raises an error" do
        expect { subject.add_edge(:source, :target) }.to raise_error(StandardError,
                                                                  "Target vertex not present")
      end
    end

    context "when source and target vertex are already connected" do
      before do
        allow(subject).to receive(:vertices_connected?).and_return(true)
        subject.add_vertex(:source, "source vertex")
        subject.add_vertex(:target, "target vertex")
      end

      it "returns nil" do
        expect(subject.add_edge(:source, :target)).to be_nil
      end
    end

    context "when source and target vertex are already connected" do
      before do
        subject.add_vertex(:source, "source vertex")
        subject.add_vertex(:target, "target vertex")
      end

      it "appends the target to the source's edge list" do
        subject.add_edge(:source, :target)

        edge_added = subject.adjacency_list[:source][:edges].contains? :target

        expect(edge_added).to be true
      end
    end
  end

  describe "#vertices_connected?" do
    subject { described_class.new }
    let(:edge_list) { instance_double(LinkedList::Singly) }

    context "when source is present in the graph" do
      it "returns nil if source vertex not present" do
        expect(subject.vertices_connected?(:source, :target)).to be_nil
      end
    end

    context "when source is present in the graph" do
      let(:edge_list_2) { instance_double(LinkedList::Singly) }

      before do
        subject.add_vertex(:source, 100)
        subject.add_vertex(:target, 125)
      end

      it "sends an outgoing message: contains?" do
        # Short fix. Should use Dependency Injection at some point
        expect_any_instance_of(LinkedList::Singly)
          .to receive(:contains?)
        subject.vertices_connected?(:source, :target)
      end

      it "returns true if source has target in edges list" do
        subject.add_edge(:source, :target)

        expect(subject.vertices_connected?(:source, :target)).to be true
      end
    end
  end

  describe "#vertices" do
    subject { described_class.new }

    before do
      [:first, :second, :third].each do |element|
        subject.add_vertex(element, element.to_s)
      end
    end

    it { expect(subject.vertices).to be_a(Array)}
    it { expect(subject.vertices.size).to eq 3}
    it { expect(subject.vertices.first).to eq :first}
  end

  describe "#adjacent_vertices" do
    subject { described_class.new }

    context "when vertex is not present in the graph" do
      it "returns nil" do
        expect{ subject.adjacent_vertices(:key) }
          .to raise_error(StandardError, "Vertex not present")
      end
    end

    context "when vertex is present in the graph" do
      before do
        subject.add_vertex(:first, "first")
        [:second, :third, :fourth].each do |ele, idx|
          subject.add_vertex(ele, ele.to_s)

          subject.add_edge(:first, ele)
        end
      end

      it "sends outgoing message to LinkedList::Singly object" do
        # Short fix. Should use Dependency Injection at some point
        expect_any_instance_of(LinkedList::Singly)
          .to receive(:each)

        subject.adjacent_vertices(:first)
      end

      it "returns a list of all vertices adjacent/connected to the vertex" do
        adjacent_vertices = subject.adjacent_vertices(:first)

        expect(adjacent_vertices.size).to be > 0
      end

      it "returns nil if vertex has no adjacent/connected vertices" do
        subject.add_vertex(:lonely, "lonely")

        adjacent_vertices = subject.adjacent_vertices(:lonely)

        expect(adjacent_vertices).to be_nil
      end
    end
  end
end
