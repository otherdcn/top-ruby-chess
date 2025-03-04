require_relative "linked_list_singly"

class Vertex
  include Comparable
  attr_accessor :data, :colour, :distance, :predecessor

  def initialize(data)
    self.data = data
    self.colour = :white
    self.distance = nil
    self.predecessor = nil
  end

  def <=>(other)
    data <=> other.data
  end

  def shortest_path(square = self, list = [])
    return if square.nil?

    list.unshift(square)
    shortest_path(square.predecessor, list)

    list
  end
end

class Graph
  attr_accessor :adjacency_list

  def initialize
    self.adjacency_list = ({})
  end

  def add_vertex(key, data)
    vertex = Vertex.new(data)
    edges =  LinkedList::Singly.new

    adjacency_list[key] = { vertex: vertex, edges: edges }

    key
  end

  def vertex(key)
    return if adjacency_list[key].nil?

    adjacency_list[key][:vertex]
  end

  def add_edge(source, target)
    raise StandardError, "Source vertex not present" unless adjacency_list.key? source
    raise StandardError, "Target vertex not present" unless adjacency_list.key? target
    return nil if vertices_connected?(source, target)

    adjacency_list[source][:edges].append(target)
    adjacency_list[target][:edges].append(source)
  end

  def vertices_connected?(source, target)
    return nil if adjacency_list[source].nil?

    adjacency_list[source][:edges].contains?(target)
  end

  def vertices
    adjacency_list.keys
  end

  def adjacent_vertices(key)
    return if adjacency_list[key].nil?
    return if adjacency_list[key][:edges].empty?

    vertices_list = []

    adjacency_list[key][:edges].each do |edge|
      vertices_list << edge.value
    end
    
    vertices_list
  end
end
