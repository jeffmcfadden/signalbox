require 'forwardable'

module SignalBox
  class LayoutController
  extend Forwardable

  attr_reader :dcc, :layout, :logger

  # Delegate layout-related methods to the layout object
  def_delegators :@layout, :cabs, :sectors, :proximity_sensors, :find_sector, :find_sensor

  def initialize(dcc:, layout:, mutex:, logger: Logger.new(STDOUT))
    @dcc = dcc
    @layout = layout
    @mutex = mutex
    @logger = logger
  end

  def start
    dcc.track_power_main!

    # Fetch current status for all cabs from DCC controller
    cabs.each do |cab|
      @logger.info "[LAYOUT] Fetching status for cab: #{cab.name} (address: #{cab.address})"

      status = dcc.get_cab_status(cab.address)

      if status
        cab.current_speed = status[:speed]
        cab.target_speed = status[:speed]
        cab.direction = status[:direction]

        @logger.info "[LAYOUT] Cab #{cab.name}: speed=#{status[:speed]}, direction=#{status[:direction] == 1 ? 'forward' : 'reverse'}"
      else
        @logger.warn "[LAYOUT] Could not fetch status for cab #{cab.name}, using defaults"
      end
    end
  end

  def emergency_stop
    dcc.track_power_off!
  end

  # Returns a hash with the complete system status
  # @return [Hash] Status information including cabs, sectors, sensors, and layout info
  def status
    {
      layout: {
        name: layout.name
      },
      cabs: cabs.map do |cab|
        {
          name: cab.name,
          address: cab.address,
          current_speed: cab.current_speed.round(2),
          target_speed: cab.target_speed,
          direction: cab.direction,
          direction_name: cab.direction == 1 ? "forward" : "reverse",
          acceleration: cab.acceleration,
          location: cab.location ? {
            id: cab.location.id,
            name: cab.location.name,
            speed_limit: cab.location.speed_limit
          } : nil
        }
      end,
      sectors: sectors.map do |sector|
        {
          id: sector.id,
          name: sector.name,
          speed_limit: sector.speed_limit
        }
      end,
      sensors: proximity_sensors.map do |sensor|
        {
          id: sensor.id,
          sector_id: sensor.sector_id
        }
      end
    }
  end

  # Called periodically by control loop
  # @param elapsed_time [Float] seconds since last tick
  def tick(elapsed_time)
    cabs.each do |cab|
      # Skip if already at target
      next if cab.current_speed == cab.target_speed

      # Calculate maximum speed change for this tick
      max_delta = cab.acceleration * elapsed_time

      if cab.current_speed < cab.target_speed
        # Accelerating
        new_speed = [cab.current_speed + max_delta, cab.target_speed].min
      else
        # Decelerating
        new_speed = [cab.current_speed - max_delta, cab.target_speed].max
      end

      # Update cab state
      cab.current_speed = new_speed

      # Send to DCC system (rounds to integer)
      @dcc.set_speed(addr: cab.address, speed: new_speed.round, dir: cab.direction)

      @logger.debug "[TICK] Cab #{cab.name} speed: #{cab.current_speed.round(2)} -> #{cab.target_speed}"
    end
  end

  # @return [Cab] the primary cab
  def primary_cab
    cabs.first
  end

  # Set target speed for a cab
  # @param cab_address [Integer] the DCC address of the cab
  # @param speed [Integer] the target speed (0-127)
  # @return [Boolean] true if successful, false if cab not found
  def set_target_speed(cab_address:, speed:)
    cab = cabs.find { |c| c.address == cab_address }

    unless cab
      @logger.warn "[CAB] Cannot set target speed: Cab with address #{cab_address} not found"
      return false
    end

    # Clamp speed to valid range
    speed = [[speed, 0].max, 127].min

    @logger.info "[CAB] Setting target speed for #{cab.name} (#{cab_address}): #{cab.target_speed} -> #{speed}"
    cab.target_speed = speed
    true
  end

  # @param cab [Cab] the cab to handle, defaults to primary cab
  # @param sector [LayoutSector] the sector that triggered the sensor
  def sector_proximity_sensor_triggered(cab: nil, sensor_id:)
    cab ||= primary_cab

    sensor = find_sensor(sensor_id)
    sector = find_sector(sensor.sector_id)

    @logger.debug "[CAB] Proximity sensor (#{sensor_id}) triggered for sector: #{sector}"

    unless sectors.include?(sector)
      @logger.warn "Unknown sector triggered: #{sector&.id}"
      return
    end

    if cab.location.nil?
      # First sector assignment
      cab.location = sector
      @logger.debug "Initial sector assignment: #{sector&.id}"
      return
    end

    if cab.location == sector
      # Already in this sector, no action needed
      @logger.debug "Already in sector #{sector&.id}, no action taken"
      return
    end

    sa = sector_after(cab.location)

    if sector != sa
      @logger.warn "Invalid sector transition attempted: #{cab.location&.id} -> #{sector&.id}. Expected #{sa&.id}."
      return
    end

    # Update location
    cab.location = sector

    if sector.speed_limit
      @logger.info "[CAB] Cab #{cab.name} entered sector #{sector.id}, setting target speed to #{sector.speed_limit}"
      cab.target_speed = sector.speed_limit
    end

  end

  private

  def sector_index_for(sector_id)
    @logger.debug "sector_index_for #{sector_id}"
    return nil if sector_id.nil?

    sectors.find_index { |s| s.id == sector_id }
  end

  # Returns the sector object after the given sector, wrapping around to the first sector if needed
  # @param sector [LayoutSector,nil] the sector
  # @return [LayoutSector, nil] the next sector or nil if sector_id not found
  def sector_after(sector)
    @logger.debug "sector_after #{sector}"

    index = sector_index_for(sector&.id)
    return nil if index.nil?

    next_index = (index + 1) % sectors.length
    sectors[next_index]
  end

  end
end