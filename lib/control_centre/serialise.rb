require "yaml"
require "json"

module Chess
  class Serialise
    class << self
      @@serializers = [JSON, YAML, Marshal]

      def dump(game_properties, format = 2)
        serialize_format = @@serializers[format]

        puts "Serializing using #{serialize_format.name} format..."

        save_dump = serialize_format.dump game_properties

        directory = "saves"

        Dir.mkdir(directory) unless Dir.exist?(directory)

        save_dump_file = "#{directory}/game-#{serialize_format.name.downcase}.save"

        puts "Saving to file #{save_dump_file}"

        File.write(save_dump_file, save_dump)
      end

      def load(format = 2)
        serialize_format = @@serializers[format]

        save_dump_file = "saves/game-#{serialize_format.name.downcase}.save"

        string = File.read(save_dump_file)

        serialize_format.load(string)
      end
    end
  end
end
