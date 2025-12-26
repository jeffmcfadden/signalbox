require_relative '../lib/dcc/client'
require 'logger'

# Test configuration
DCC_HOST = ENV.fetch("DCC_HOST")
DCC_PORT = 2560
TEST_CAB = 2

logger = Logger.new(STDOUT)
logger.level = Logger::DEBUG

puts "=== Testing DCC::Client#get_cab_status ==="
puts "Connecting to #{DCC_HOST}:#{DCC_PORT}..."

dcc = DCC::Client.new(DCC_HOST, DCC_PORT, logger: logger)
dcc.connect

puts "\nRequesting status for cab #{TEST_CAB}..."
status = dcc.get_cab_status(TEST_CAB)

if status
  puts "\n✓ SUCCESS: Received cab status"
  puts "  Cab:         #{status[:cab]}"
  puts "  Reg:         #{status[:reg]}"
  puts "  Speed Byte:  #{status[:speed_byte]}"
  puts "  Function Map: #{status[:funct_map]}"
else
  puts "\n✗ FAILED: No valid response received"
  exit 1
end

dcc.close
puts "\n=== Test completed ==="
