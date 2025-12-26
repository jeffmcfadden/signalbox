require_relative 'layout'
require_relative 'cab'
require_relative 'layout_sector'
require_relative 'proximity_sensor'
require_relative 'dcc/client'
require 'logger'

module SignalBox
  module LayoutDSL
  # Builder for cab blocks
  class CabBuilder
    attr_reader :cab_name, :cab_address, :cab_acceleration

    def name(value)
      @cab_name = value
    end

    def address(value)
      @cab_address = value
    end

    def acceleration(value)
      @cab_acceleration = value
    end

    def build(logger:)
      Cab.new(
        name: @cab_name || "",
        address: @cab_address || 0,
        acceleration: @cab_acceleration || 5,
        logger: logger
      )
    end
  end

  # Builder for sector blocks
  class SectorBuilder
    attr_reader :sector_id, :sector_name, :sector_speed_limit

    def id(value)
      @sector_id = value
    end

    def name(value)
      @sector_name = value
    end

    def speed_limit(value)
      @sector_speed_limit = value
    end

    def build
      LayoutSector.new(
        id: @sector_id,
        name: @sector_name || "",
        speed_limit: @sector_speed_limit || 10
      )
    end
  end

  # Builder for proximity_sensor blocks
  class ProximitySensorBuilder
    attr_reader :sensor_id, :sensor_sector_id

    def id(value)
      @sensor_id = value
    end

    def sector_id(value)
      @sensor_sector_id = value
    end

    def build
      ProximitySensor.new(
        id: @sensor_id,
        sector_id: @sensor_sector_id
      )
    end
  end

  # Builder for dcc blocks
  class DCCBuilder
    attr_reader :dcc_host, :dcc_port

    def host(value)
      @dcc_host = value
    end

    def port(value)
      @dcc_port = value
    end

    def build(logger:)
      DCC::Client.new(
        @dcc_host,
        @dcc_port,
        logger: logger
      )
    end
  end

  # Main layout builder
  class LayoutBuilder
    attr_reader :layout

    def initialize(name:, logger: Logger.new(STDOUT))
      @layout = Layout.new(name: name)
      @logger = logger
    end

    def cab(&block)
      builder = CabBuilder.new
      builder.instance_eval(&block)
      @layout.add_cab(builder.build(logger: @logger))
    end

    def sector(&block)
      builder = SectorBuilder.new
      builder.instance_eval(&block)
      @layout.add_sector(builder.build)
    end

    def proximity_sensor(&block)
      builder = ProximitySensorBuilder.new
      builder.instance_eval(&block)
      @layout.add_proximity_sensor(builder.build)
    end

    def dcc(&block)
      builder = DCCBuilder.new
      builder.instance_eval(&block)
      @layout.set_dcc(builder.build(logger: @logger))
    end
  end

  # Top-level DSL method
  def layout(name:, logger: Logger.new(STDOUT), &block)
    builder = LayoutBuilder.new(name: name, logger: logger)
    builder.instance_eval(&block)
    builder.layout
  end
  end
end
