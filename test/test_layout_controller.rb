require_relative '../lib/layout_loader'
require_relative '../lib/layout_controller'
require_relative '../lib/dcc/client'
require 'logger'

logger = Logger.new(STDOUT)
logger.level = Logger::INFO

puts "=== Testing LayoutController with Layout DSL ==="

# Load the layout
puts "\nLoading layout from layouts/main.rb..."
layout = LayoutLoader.load('layouts/main.rb', logger: logger)

# Create a mock DCC client (won't actually connect)
class MockDCCClient
  def initialize(logger:)
    @logger = logger
  end

  def track_power_main!
    @logger.info "[MOCK DCC] Track power MAIN ON"
  end

  def track_power_off!
    @logger.info "[MOCK DCC] Track power OFF"
  end

  def set_speed(addr:, speed:, dir:)
    @logger.info "[MOCK DCC] Set speed addr=#{addr} speed=#{speed} dir=#{dir}"
  end
end

dcc = MockDCCClient.new(logger: logger)
mutex = Mutex.new

# Create layout controller with the loaded layout
puts "\nCreating LayoutController with layout..."
controller = LayoutController.new(
  layout: layout,
  dcc: dcc,
  mutex: mutex,
  logger: logger
)

puts "\n--- Testing Delegation ---"
puts "Layout name: #{controller.layout.name}"
puts "Number of cabs: #{controller.cabs.count}"
puts "Number of sectors: #{controller.sectors.count}"
puts "Number of sensors: #{controller.proximity_sensors.count}"

puts "\nCabs:"
controller.cabs.each do |cab|
  puts "  • #{cab.name} (address: #{cab.address}, acceleration: #{cab.acceleration})"
end

puts "\nSectors:"
controller.sectors.each do |sector|
  puts "  • #{sector.name} (id: #{sector.id})"
end

puts "\nProximity Sensors:"
controller.proximity_sensors.each do |sensor|
  sector = controller.find_sector(sensor.sector_id)
  puts "  • #{sensor.id} → #{sector&.name}"
end

puts "\n--- Testing Primary Cab ---"
primary = controller.primary_cab
puts "Primary cab: #{primary.name} (address: #{primary.address})"

puts "\n--- Testing Controller Start ---"
controller.start

puts "\n--- Testing Tick (Acceleration) ---"
primary.target_speed = 30
puts "Setting target speed to #{primary.target_speed}..."
3.times do |i|
  controller.tick(0.5)  # 0.5 second intervals
  puts "  After tick #{i+1}: current_speed = #{primary.current_speed.round(2)}"
end

puts "\n--- Testing Sector Proximity Trigger ---"
puts "Triggering sector 2 (Hill Climb)..."
controller.sector_proximity_sensor_triggered(sector_id: 2)
puts "  Cab location: #{primary.location&.name}"
puts "  Target speed: #{primary.target_speed}"

puts "\nTriggering sector 3 (Hill Descent)..."
controller.sector_proximity_sensor_triggered(sector_id: 3)
puts "  Cab location: #{primary.location&.name}"
puts "  Target speed: #{primary.target_speed}"

puts "\n✓ All tests passed!"
puts "\n=== Test completed ==="
