require_relative '../lib/layout_loader'
require 'logger'

logger = Logger.new(STDOUT)
logger.level = Logger::INFO

puts "=== Testing Layout Loader ==="
puts "\nLoading layouts/main.rb..."

begin
  layout = LayoutLoader.load('layouts/main.rb', logger: logger)

  puts "\n--- Layout Details ---"
  puts "Name: #{layout.name}"

  puts "\nCabs (#{layout.cabs.count}):"
  layout.cabs.each do |cab|
    puts "  • #{cab.name}"
    puts "    Address: #{cab.address}"
    puts "    Acceleration: #{cab.acceleration}"
  end

  puts "\nSectors (#{layout.sectors.count}):"
  layout.sectors.each do |sector|
    puts "  • #{sector.name} (id: #{sector.id})"
  end

  puts "\nProximity Sensors (#{layout.proximity_sensors.count}):"
  layout.proximity_sensors.each do |sensor|
    sector = layout.find_sector(sensor.sector_id)
    puts "  • #{sensor.id} → Sector: #{sector&.name || 'Unknown'}"
  end

  puts "\n✓ Layout loaded successfully!"

rescue => e
  puts "\n✗ Error loading layout:"
  puts "  #{e.class}: #{e.message}"
  puts e.backtrace.first(5)
  exit 1
end

puts "\n=== Test completed ==="
