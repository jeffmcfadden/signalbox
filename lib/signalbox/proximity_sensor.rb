module SignalBox
  class ProximitySensor
    attr_reader :id, :sector_id

    def initialize(id:, sector_id:)
      @id = id
      @sector_id = sector_id
    end

    def ==(other)
      other.is_a?(ProximitySensor) && other.id == @id
    end

    def to_s
      "ProximitySensor(id: #{@id}, sector_id: #{@sector_id})"
    end
  end
end
