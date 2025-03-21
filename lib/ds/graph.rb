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

module Graph
  def adjacency_list
    @adjacency_list ||= ({})
  end

  def empty?
    adjacency_list.empty?
  end

  def add_vertex(key, data)
    # Bad Dependency
    # Unjustified attachment to type for the following: vertex and edges
    vertex = Vertex.new(data)
    edges =  LinkedList::Singly.new

    adjacency_list[key] = { vertex: vertex, edges: edges }

    key
  end

  def vertex(key)
    raise StandardError, "Vertex not "\
      "present" unless adjacency_list.key? key

    adjacency_list[key][:vertex]
  end

  def add_edge(source, target)
    raise StandardError, "Source vertex "\
      "not present" unless adjacency_list.key? source
    raise StandardError, "Target vertex "\
      "not present" unless adjacency_list.key? target
    return nil if vertices_connected?(source, target)

    adjacency_list[source][:edges].append(target)
  end

  def vertices_connected?(source, target)
    return nil if adjacency_list[source].nil?

    adjacency_list[source][:edges].contains?(target)
  end

  def vertices
    adjacency_list.keys
  end

  def adjacent_vertices(key)
    raise StandardError, "Vertex not "\
      "present" unless adjacency_list.key? key

    return if adjacency_list[key][:edges].empty?

    vertices_list = []

    adjacency_list[key][:edges].each do |edge|
      vertices_list << edge.value
    end
    
    vertices_list
  end
end
