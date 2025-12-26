require_relative '../lib/dcc/client'
require 'logger'

# Test configuration
DCC_HOST = ENV.fetch("DCC_HOST")
DCC_PORT = 2560
TEST_CAB = 2
TEST_TURNOUT = 1

logger = Logger.new(STDOUT)
logger.level = Logger::DEBUG

puts "=== DCC::Client Command Test Suite ==="
puts "Connecting to #{DCC_HOST}:#{DCC_PORT}..."

dcc = DCC::Client.new(DCC_HOST, DCC_PORT, logger: logger)
dcc.connect

puts "\n--- Track Power Commands ---"
puts "Turning MAIN track power ON..."
dcc.track_power_on!("MAIN")
sleep 0.5

puts "\nTurning PROG track power ON..."
dcc.track_power_on!("PROG")
sleep 0.5

puts "\n--- Locomotive Speed Control ---"
puts "Setting cab #{TEST_CAB} to speed 30, forward..."
dcc.set_speed(addr: TEST_CAB, speed: 30, dir: 1)
sleep 1

puts "\nSetting cab #{TEST_CAB} to speed 20, reverse..."
dcc.set_speed(addr: TEST_CAB, speed: 20, dir: 0)
sleep 1

puts "\n--- Cab Status Query ---"
puts "Getting status for cab #{TEST_CAB}..."
status = dcc.get_cab_status(TEST_CAB)
if status
  puts "✓ Cab Status:"
  puts "  Cab:         #{status[:cab]}"
  puts "  Speed Byte:  #{status[:speed_byte]}"
  puts "  Function Map: #{status[:funct_map]}"
else
  puts "✗ No status received"
end
sleep 0.5

puts "\n--- Function Control (Lights) ---"
puts "Turning light ON for cab #{TEST_CAB}..."
dcc.light_on(cab: TEST_CAB)
sleep 1

puts "\nTurning light OFF for cab #{TEST_CAB}..."
dcc.light_off(cab: TEST_CAB)
sleep 1

puts "\n--- Generic Function Control ---"
puts "Setting F2 (horn/whistle) ON for cab #{TEST_CAB}..."
dcc.set_function(cab: TEST_CAB, funct: 2, state: 1)
sleep 0.5

puts "\nSetting F2 OFF for cab #{TEST_CAB}..."
dcc.set_function(cab: TEST_CAB, funct: 2, state: 0)
sleep 0.5

puts "\n--- Turnout Control ---"
puts "Throwing turnout #{TEST_TURNOUT}..."
dcc.throw_turnout(id: TEST_TURNOUT)
sleep 1

puts "\nClosing turnout #{TEST_TURNOUT}..."
dcc.close_turnout(id: TEST_TURNOUT)
sleep 1

puts "\nListing all turnouts..."
dcc.list_turnouts
sleep 0.5

puts "\n--- Accessory Decoder Control ---"
puts "Setting accessory decoder addr=10, subaddr=0, activate=1..."
dcc.set_accessory(addr: 10, subaddr: 0, activate: 1)
sleep 0.5

puts "\nSetting accessory decoder (linear) addr=100, activate=1..."
dcc.set_accessory_linear(addr: 100, activate: 1)
sleep 0.5

puts "\n--- Safety Commands ---"
puts "Stopping cab #{TEST_CAB}..."
dcc.set_speed(addr: TEST_CAB, speed: 0, dir: 1)
sleep 1

puts "\nTurning MAIN track power OFF..."
dcc.track_power_off!("MAIN")
sleep 0.5

# Uncomment to test emergency stop (use with caution!)
# puts "\nTesting EMERGENCY STOP..."
# dcc.emergency_stop!

dcc.close

puts "\n=== Test completed ==="
puts "\nNote: Emergency stop is commented out for safety."
puts "Uncomment in the test file to test it."
