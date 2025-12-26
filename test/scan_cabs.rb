require_relative '../lib/dcc/client'
require 'logger'

# Test configuration
DCC_HOST = ENV.fetch("DCC_HOST")
DCC_PORT = 2560

# Scan configuration
SCAN_SHORT_ADDRESSES = true   # 1-127
SCAN_LONG_ADDRESSES = false   # 128-10293 (takes much longer)
DELAY_BETWEEN_REQUESTS = 0.1  # seconds

logger = Logger.new(STDOUT)
logger.level = Logger::WARN  # Reduce noise during scan

puts "=== DCC Cab Address Scanner ==="
puts "Connecting to #{DCC_HOST}:#{DCC_PORT}..."

dcc = DCC::Client.new(DCC_HOST, DCC_PORT, logger: logger)
dcc.connect

active_cabs = []

if SCAN_SHORT_ADDRESSES
  puts "\nScanning short addresses (1-127)..."
  (1..127).each do |addr|
    print "\rScanning address #{addr}...   "
    STDOUT.flush

    status = dcc.get_cab_status(addr)

    if status
      puts "\n✓ Found active cab at address #{addr}"
      puts "  Speed Byte: #{status[:speed_byte]}, Function Map: #{status[:funct_map]}"
      active_cabs << status
    end

    sleep DELAY_BETWEEN_REQUESTS
  end
  print "\r" + " " * 40 + "\r"  # Clear progress line
end

if SCAN_LONG_ADDRESSES
  puts "\nScanning long addresses (128-10293)..."
  puts "(This may take several minutes...)"

  (128..10293).each do |addr|
    if addr % 100 == 0
      print "\rScanning address #{addr}...   "
      STDOUT.flush
    end

    status = dcc.get_cab_status(addr)

    if status
      puts "\n✓ Found active cab at address #{addr}"
      puts "  Speed Byte: #{status[:speed_byte]}, Function Map: #{status[:funct_map]}"
      active_cabs << status
    end

    sleep DELAY_BETWEEN_REQUESTS
  end
  print "\r" + " " * 40 + "\r"  # Clear progress line
end

dcc.close

puts "\n=== Scan Results ==="
if active_cabs.empty?
  puts "No active cabs found on the layout."
else
  puts "Found #{active_cabs.length} active cab(s):"
  active_cabs.each do |cab|
    puts "  • Cab #{cab[:cab]}: Speed=#{cab[:speed_byte]}, Functions=#{cab[:funct_map]}"
  end
end

puts "\n=== Scan completed ==="
