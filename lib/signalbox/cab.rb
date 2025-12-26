module SignalBox
  class Cab
    attr_reader :name, :address, :logger

    attr_accessor :current_speed, :target_speed, :acceleration, :location, :direction

    # param name [String] the name of the cab
    # param address [String] the DCC address of the cab
    # param current_speed [Integer] the current speed of the cab
    # param target_speed [Integer] the target speed of the cab
    # param acceleration [Integer] the acceleration of the cab, in units per second squared, absolute value
    # param direction [Integer] the direction of the cab (0 = reverse, 1 = forward)
    # param location [LayoutSector, nil] the current location of the cab
    # param logger [Logger] the logger to use
    def initialize(name: "", address: "", current_speed: 0, target_speed: 0, acceleration: 5, direction: 1, location: nil, logger: Logger.new(STDOUT))
      @name = name
      @address = address
      @current_speed = current_speed
      @target_speed = target_speed
      @acceleration = acceleration
      @direction = direction
      @location = location
      @logger = logger
    end

  end
end
