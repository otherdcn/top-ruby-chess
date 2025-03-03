class Node
  attr_accessor :data, :next_node

  def initialize(data)
    self.data = data
  end
end

class Queue
  attr_accessor :head_node, :tail_node

  def initialize
    self.head_node = nil
    self.tail_node = nil
  end

  def empty?
    head_node.nil?
  end

  def peek
    return nil if empty?

    head_node.data
  end

  def enqueue(data)
    node = Node.new(data)

    if empty?
      self.head_node = node
      self.tail_node = node
    elsif tail_node.nil?
      self.tail_node = node
      head_node.next_node = tail_node
    else
      tail_node.next_node = node
      self.tail_node = node
    end

    node
  end

  def dequeue
    return nil if empty?

    dequeued_node = head_node.data
    self.head_node = head_node.next_node

    self.tail_node = nil if tail_node == head_node

    dequeued_node
  end

  def traverse(node = head_node, &block)
    return nil if empty?

    return if node.nil?

    block.call(node) if block_given?

    traverse(node.next_node, &block)
  end
end
