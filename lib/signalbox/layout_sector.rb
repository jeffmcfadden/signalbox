module SignalBox
  class LayoutSector
    attr_reader :name, :id, :speed_limit

    def initialize(name: "", id: "", speed_limit: 10)
      @speed_limit = speed_limit
      @name = name
      @id = id
    end

    def == (other)
      other.is_a?(LayoutSector) && other.id == @id
    end

    def to_s
      "Sector(name: #{@name}, id: #{@id})"
    end

  end
end
