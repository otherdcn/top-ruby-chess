#require_relative 'node'

module LinkedList
  class SinglyLinkedNode
    attr_accessor :value, :next_node

    def initialize(value)
      self.value = value
      self.next_node = nil
    end
  end
end


module LinkedList
  class Singly
    attr_accessor :head, :tail, :size

    def initialize
      self.head = nil
      self.tail = nil
      self.size = 0
    end

    def empty?
      head.nil?
    end

    def set_first_node(node)
      self.head = node
      self.tail = node
    end

    def append(value)
      node = SinglyLinkedNode.new(value)

      self.size += 1

      return set_first_node(node) if empty?

      self.tail.next_node = node
      self.tail = node

      node
    end

    def prepend(value)
      node = SinglyLinkedNode.new(value)

      self.size += 1

      return set_first_node(node) if empty?

      node.next_node = head
      self.head = node

      node
    end

    def at(index)
      return nil if empty?

      raise IndexError, "Index out of bounds (#{index} > #{size})" if index > size
      return head if index <= 1

      node = head

      for i in 1...index
        node = node.next_node
      end

      node
    end

    def pop
      return nil if empty?

      popped_node = tail
      self.tail = at(size-1)
      self.tail.next_node = nil
      self.size -= 1

      popped_node
    end

    def shift
      return nil if empty?

      shifted_node = head
      self.head = head.next_node
      shifted_node.next_node = nil
      self.tail = nil if shifted_node == tail
      self.size -= 1

      shifted_node
    end

    def search(value)
      node = head
      index = 1

      until node.nil?
        if value == node.value
          return index
        else
          node = node.next_node
          index += 1
        end
      end

      nil
    end

    def contains?(value)
      raise StandardError, "Checking empty list" if empty?

      search(value) ? true : false
    end

    def find(value)
      raise StandardError, "Checking empty list" if empty?

      search(value)
    end

    def traverse
      return "" if empty?

      node = head
      traversal = ""

      traversal << "( #{node.value} ) -> "
      while node.next_node != nil
        node = node.next_node
        traversal << "( #{node.value} ) -> "
      end
      traversal << "nil.\n"
    end

    def to_s
      return traverse
    end

    def insert_at(value, index)
      return "Warning: list is empty, append first." if empty?

      raise IndexError, "Index out of bounds (#{index} > #{size})" if index > size

      current_node = at(index)
      current_node_predecessor = at(index - 1)

      return prepend(value) if current_node == head

      new_node = SinglyLinkedNode.new(value)
      current_node_predecessor.next_node = new_node
      new_node.next_node = current_node
      self.size += 1

      new_node
    end

    def remove_at(index)
      return nil if empty?

      raise IndexError, "Index out of bounds (#{index} > #{size})" if index > size

      node_at_index = at(index)
      predecessor = at(index - 1)

      if node_at_index == head
        self.head = head.next_node
        node_at_index.next_node = nil
        self.tail = nil if node_at_index == tail # in case of deleting the only node in list

        self.size -= 1
      elsif node_at_index == tail
        self.pop
      else
        predecessor.next_node = node_at_index.next_node
        node_at_index.next_node = nil

        self.size -= 1
      end

      node_at_index
    end

    def each
      return nil if empty?

      node = head

      until node.nil?
        yield node

        node = node.next_node
      end
    end

    def reverse
      return nil if empty?

      new_linked_list = self.class.new

      self.each { |node| new_linked_list.prepend(node.value) }

      new_linked_list
    end

    def reverse!
      return nil if empty?

      list_size = size
      temp_head = shift

      self.tail = temp_head

      until empty?
        node = shift

        node.next_node = temp_head

        temp_head = node
      end

      self.size = list_size
      self.head = temp_head
    end

    def examine_node(index)
      node_at_index, _ = at(index)
      node = node_at_index.value
      next_node = node_at_index.next_node ? node_at_index.next_node.value : "null"

      "Node: #{node}\nNext: #{next_node}"
    end

    private :search, :head=, :tail=, :size=, :set_first_node
  end
end
