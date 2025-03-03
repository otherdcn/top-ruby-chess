require_relative "../lib/linked_list_singly"

describe LinkedList::Singly do
  describe "attributes" do
    it "can respond to head, tail, and size getter message" do
      list = LinkedList::Singly.new

      expect(list).to have_attributes(:head => nil, :tail => nil, :size => 0)
    end
  end

  describe "#append" do
    def append_to_linked_list(items: nil)
      list = LinkedList::Singly.new

      items.each { |item| list.append item } unless items.nil?

      list
    end

    context "when list is initially empty" do
      it "sets node as head" do
        list = append_to_linked_list(items: nil)

        list.append("apple")

        expect(list.head.value).to eq "apple"
      end

      it "set node as tail" do
        list = append_to_linked_list(items: nil)

        list.append("apple")

        expect(list.tail.value).to eq "apple"
      end
    end

    context "when list already has contents" do
      it "sets node as tail" do
        list = append_to_linked_list(items: %w[apple banana])

        list.append "watermelon"

        expect(list.tail.value).to eq "watermelon"
      end

      it "updates previous tail node's next pointer to new node" do
        list = append_to_linked_list(items: %w[apple banana])

        previous_tail_node = list.tail
        list.append "watermelon"
        
        expect(previous_tail_node.next_node.value).to eq "watermelon"
      end
    end
  end

  describe "#prepend" do
    def prepend_to_linked_list(items: nil)
      list = LinkedList::Singly.new

      items.each { |item| list.prepend item } unless items.nil?

      list
    end

    context "when list is initially empty" do
      it "sets node as head" do
        list = prepend_to_linked_list(items: nil)

        list.prepend("apple")

        expect(list.head.value).to eq "apple"
      end

      it "set node as tail" do
        list = prepend_to_linked_list(items: nil)

        list.prepend("apple")

        expect(list.tail.value).to eq "apple"
      end
    end

    context "when list already has contents" do
      it "sets node as head" do
        list = prepend_to_linked_list(items: %w[apple banana])

        list.prepend "watermelon"

        expect(list.head.value).to eq "watermelon"
      end

      it "sets previous head node as the new node's next pointer" do
        list = prepend_to_linked_list(items: %w[apple banana])

        previous_head_node = list.head
        list.prepend "watermelon"
        
        expect(previous_head_node.value).to eq list.head.next_node.value
      end
    end
  end

  describe "#size" do
    it "returns 0 when list is empty" do
      list = LinkedList::Singly.new
      expect(list.size).to be_zero
    end

    it "returns 3 when list contains: apple, banana, watermelon" do
      list = LinkedList::Singly.new

      %w[apple banana watermelon].each { |fruit| list.append fruit }

      expect(list.size).to eq 3
    end

    it "increments by one when appending" do
      list = LinkedList::Singly.new

      expect { list.append "apple" }.to change { list.size }.from(0).to(1)
    end

    it "increments by one when prepending" do
      list = LinkedList::Singly.new

      expect { list.prepend "apple" }.to change { list.size }.from(0).to(1)
    end
  end

  describe "#head" do
    it "returns nil if list is empty" do
      list = LinkedList::Singly.new

      expect(list.head).to be_nil
    end

    it "returns apple if its the first item" do
      list = LinkedList::Singly.new

      list.append "apple"

      expect(list.head.value).to eq "apple"
    end
  end

  describe "#tail" do
    it "returns nil if list is empty" do
      list = LinkedList::Singly.new

      expect(list.tail).to be_nil
    end

    it "returns watermelon if its the last item" do
      list = LinkedList::Singly.new

      %w[apple banana watermelon].each { |fruit| list.append fruit }

      expect(list.tail.value).to eq "watermelon"
    end

    it "returns watermelon if its the only item" do
      list = LinkedList::Singly.new

      list.append "watermelon"

      expect(list.tail.value).to eq "watermelon"
    end
  end

  describe "#at" do
    it "returns apple if index is 1" do
      list = LinkedList::Singly.new

      %w[apple orange pear date].each { |fruit| list.append fruit }
      node = list.at(1)

      expect(node.value).to eq "apple"
    end

    it "returns pear if index is 3" do
      list = LinkedList::Singly.new

      %w[apple orange pear date].each { |fruit| list.append fruit }
      node = list.at(3)

      expect(node.value).to eq "pear"
    end

    it "returns tail node if index is equal to list.size" do
      list = LinkedList::Singly.new

      %w[apple orange pear date].each { |fruit| list.append fruit }
      index = list.size
      node = list.at(index)

      expect(node).to eq list.tail
    end

    it "raises IndexError if index is out of bounds" do
      list = LinkedList::Singly.new

      %w[apple orange pear date].each { |fruit| list.append fruit }
      

      expect { list.at(10) }.to raise_error(IndexError)
    end
  end

  describe "#pop" do
    def create_dummy_linked_list(items: nil)
      list = LinkedList::Singly.new

      items.each { |item| list.append item } unless items.nil?

      list
    end

    it "returns nil if list is empty" do
      list = create_dummy_linked_list(items: nil)

      expect(list.pop).to be_nil
    end

    it "sets the tail to the previous node" do
      list = create_dummy_linked_list(items: %w[apple banana pear])

      list.pop

      expect(list.tail.value).to eq "banana"
    end

    it "sets the new tail's next pointer to nil" do
      list = create_dummy_linked_list(items: %w[apple banana pear])

      list.pop

      expect(list.tail.next_node).to be_nil
    end

    it "decrements the list size" do
      list = create_dummy_linked_list(items: %w[apple banana pear])

      expect { list.pop }.to change { list.size }.by(-1)
    end

    it "returns the popped node" do
      list = create_dummy_linked_list(items: %w[apple banana pear])

      popped_node = list.pop

      expect(popped_node.value).to eq "pear"
    end
  end

  describe "#shift" do
    def create_dummy_linked_list(items: nil)
      list = LinkedList::Singly.new

      items.each { |item| list.append item } unless items.nil?

      list
    end

    it "returns nil if list is empty" do
      list = create_dummy_linked_list(items: nil)

      expect(list.shift).to be_nil
    end

    it "sets the head to the next node" do
      list = create_dummy_linked_list(items: %w[apple banana pear])

      list.shift

      expect(list.head.value).to eq "banana"
    end

    it "decrements the list size" do
      list = create_dummy_linked_list(items: %w[apples banana pear])

      expect { list.shift }.to change { list.size }.by(-1)
    end

    it "returns the shifted node" do
      list = create_dummy_linked_list(items: %w[apple banana pear])

      shifted_node = list.shift

      expect(shifted_node.value).to eq "apple"
    end

    it "sets the shifted node's next pointer to nil" do
      list = create_dummy_linked_list(items: %w[apple banana pear])

      shifted_node = list.shift

      expect(shifted_node.next_node).to be_nil
    end
  end

  describe "#contains?" do
    it "returns false if list is  empty" do
      list = LinkedList::Singly.new

      expect(list.contains?("apple")).to be false
    end

    it "returns true for apple" do
      list = LinkedList::Singly.new

      %w[apple orange pear].each { |fruit| list.append fruit }

      expect(list.contains?("apple")).to eq true
    end

    it "returns false for sugercane" do
      list = LinkedList::Singly.new

      %w[apple orange pear].each { |fruit| list.append fruit }

      expect(list.contains?("sugercane")).to eq false
    end
  end

  describe "#find" do
    it "returns 1 for apple" do
      list = LinkedList::Singly.new

      %w[apple orange pear].each { |fruit| list.append fruit }

      expect(list.find("apple")).to eq 1
    end

    it "returns 2 for orange" do
      list = LinkedList::Singly.new

      %w[apple orange pear].each { |fruit| list.append fruit }

      expect(list.find("orange")).to eq 2
    end

    it "returns 5 for watermelon" do
      list = LinkedList::Singly.new

      %w[apple orange pear grape watermelon guava date].each do |fruit| 
        list.append fruit
      end

      expect(list.find("watermelon")).to eq 5
    end
  end

  describe "#insert_at" do
    it "returns Cautionary message if list is empty" do
      list = LinkedList::Singly.new

      expect(list.insert_at("apple", 3)).to eq "Warning: list is empty, append first."
    end

    it "Returns a SinglyLinkedNode object" do
      list = LinkedList::Singly.new

      %w[apple orange pear].each { |fruit| list.append fruit }
      node = list.insert_at("watermelon", 2)

      expect(node).to be_a(LinkedList::SinglyLinkedNode)
    end

    it "returns the newly inserted node at specified index" do
      list = LinkedList::Singly.new

      %w[apple orange pear].each { |fruit| list.append fruit }
      index = 2
      node = list.insert_at("watermelon", index)

      expect(node).to eq(list.at(index))
    end

    it "returns the previously shifted node new node's next node pointer" do
      list = LinkedList::Singly.new

      %w[apple orange pear].each { |fruit| list.append fruit }
      index = 2
      node = list.insert_at("watermelon", index)

      expect(node.next_node).to eq(list.at(index + 1))
    end

    it "increments the list size by 1" do
      list = LinkedList::Singly.new

      %w[apple orange pear].each { |fruit| list.append fruit }
      index = 2

      expect { list.insert_at("watermelon", index) }.to change { list.size }.by(1)
    end
  end

  describe "#remove_at" do
    it "returns nil if list is empty" do
      list = LinkedList::Singly.new

      expect(list.remove_at(3)).to be_nil
    end

    it "raises IndexError if index is out of bounds" do
      list = LinkedList::Singly.new

      %w[apple orange pear].each { |fruit| list.append fruit }

      expect { list.remove_at(10) }.to raise_error(IndexError)
    end

    it "decrements the list size" do
      list = LinkedList::Singly.new

      %w[apple orange pear].each { |fruit| list.append fruit }

      expect { list.remove_at(2) }.to change { list.size }.by(-1)
    end

    it "returns the removed node" do
      list = LinkedList::Singly.new

      %w[apple orange pear].each { |fruit| list.append fruit }
      index = 2
      expected = list.at(index)
      removed_node = list.remove_at(index)

      expect(removed_node).to eq expected
    end
  end

  describe "#reverse" do
    it "returns nil if list is empty" do
      list = LinkedList::Singly.new

      expect(list.reverse).to be_nil
    end

    it "creates and returns new tail node that was previously head" do
      list = LinkedList::Singly.new

      %w[apple orange pear].each { |fruit| list.append fruit }
      previous_head = list.head
      reversed_list = list.reverse

      expect(reversed_list.tail.value).to eq previous_head.value
    end

    it "creates and returns new head node that was previously tail" do
      list = LinkedList::Singly.new

      %w[apple orange pear].each { |fruit| list.append fruit }
      previous_tail = list.tail
      reversed_list = list.reverse

      expect(reversed_list.head.value).to eq previous_tail.value
    end
  end
end
