module SignalBox
  class Layout
    attr_reader :name, :cabs, :sectors, :proximity_sensors, :dcc

    def initialize(name:)
      @name = name
      @cabs = []
      @sectors = []
      @proximity_sensors = []
      @dcc = nil
    end

    def add_cab(cab)
      @cabs << cab
    end

    def add_sector(sector)
      @sectors << sector
    end

    def add_proximity_sensor(sensor)
      @proximity_sensors << sensor
    end

    def set_dcc(dcc)
      @dcc = dcc
    end

    def find_sector(id)
      @sectors.find { |s| s.id == id }
    end

    def find_sensor(id)
      @proximity_sensors.find { |s| s.id == id }
    end

    def to_s
      "Layout(name: #{@name}, cabs: #{@cabs.count}, sectors: #{@sectors.count}, sensors: #{@proximity_sensors.count})"
    end
  end
end
