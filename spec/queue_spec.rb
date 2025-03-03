require_relative "../lib/queue"

RSpec.describe Queue do
  describe "#empty?" do
    subject { described_class.new }

    context "when there is no node" do
      it { expect(subject.empty?).to be true }
    end

    context "when there is a node" do
      before do
        subject.head_node = Node.new(1)
      end

      it { expect(subject.empty?).to be false }
    end
  end

  describe "#peek" do
    subject { described_class.new }

    context "when queue is empty" do
      it { expect(subject.peek).to be_nil }
    end

    context "when queue is not empty" do
      before do
        subject.head_node = Node.new(1)
      end

      it { expect(subject.peek).to_not be_nil }
      it { expect(subject.peek).to eq 1 }
    end
  end

  describe "#enqueue" do
    subject { described_class.new }

    context "when first node added to the queue" do
      it "should not be empty" do
        subject.enqueue(1)

        expect(subject.empty?).to be false
      end

      it "should be the head node" do
        queue_node = subject.enqueue(1)

        expect(queue_node).to eq subject.head_node
      end

      it "should be the tail node" do
        queue_node = subject.enqueue(1)

        expect(queue_node).to eq subject.tail_node
      end
    end

    context "when second node added to the queue" do
      before do
        subject.enqueue(1)
      end

      it "should add it as tail node" do
        node = subject.enqueue(2)

        expect(node).to eq subject.tail_node
      end

      it "should set it as head node's next node" do
        node = subject.enqueue(2)

        expect(node).to eq subject.head_node.next_node
      end
    end

    context "when 3+ node(s) added to the queue" do
      before do
        [1,2].each { |data| subject.enqueue(data) }
      end

      it "should add it as tail node" do
        node = subject.enqueue(3)

        expect(node).to eq subject.tail_node
      end

      it "should make previous tail node add it as next node" do
        previous_tail_node = subject.tail_node

        node = subject.enqueue(3)

        expect(previous_tail_node.next_node).to eq node
      end
    end
  end

  describe "#dequeue" do
    subject { described_class.new }

    context "when queue is empty" do
      it "should return nil" do
        expect(subject.dequeue).to be_nil
      end
    end

    context "when queue is not empty" do
      before do
        [1,2,3].each { |data| subject.enqueue(1) }
      end

      it "should return head node's data" do
        head_node = subject.head_node
        node = subject.dequeue

        expect(node).to eq head_node.data
      end

      it "should set head node's next node as head" do
        next_node = subject.head_node.next_node
        subject.dequeue

        expect(next_node).to eq subject.head_node
      end

      it "should set tail and head as nil if last node dequeued" do
        3.times { subject.dequeue }

        subject.dequeue

        expect(subject.tail_node).to be_nil
        expect(subject.head_node).to be_nil
      end
    end
  end
end
