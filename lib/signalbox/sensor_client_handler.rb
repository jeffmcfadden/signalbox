require 'json'

module SignalBox
  class SensorClientHandler
    DETECTION_THRESHOLD = 1500

    def initialize(layout_controller:, mutex:, logger:)
      @layout_controller = layout_controller
      @mutex = mutex
      @logger = logger
    end

    def handle_client(client)
      begin
        client.sync = true
        peer = client.peeraddr
        @logger.info "Client connected from #{peer[2]}:#{peer[1]}"

        sensor_id = nil

        while (line = client.gets)
          line = line.strip
          next if line.empty?

          @logger.debug "Raw line: #{line}"

          parts = line.split(" ")
          cmd = parts.shift

          case cmd
          when "HELLO"
            handle_hello(parts)

          when "READING"
            sensor_id = parts.shift
            handle_reading(sensor_id, parts)

          when "MANUAL_SECTOR_ADVANCE"
            handle_manual_sector_advance(client)

          when "STATUS"
            handle_status(client)

          when "SET_TARGET_SPEED"
            cab_address = parts.shift.to_i
            speed = parts.shift.to_i
            handle_set_target_speed(client, cab_address, speed)

          else
            @logger.warn "[WARN] Unknown cmd: #{line}"
          end
        end
      rescue => e
        @logger.warn "Client thread error: #{e}\n#{e.backtrace.join("\n")}"
      ensure
        client.close rescue nil
        @logger.debug "Client disconnected"
      end
    end

    private

    def handle_hello(parts)
      esp32_id = parts[0] || "unknown"
      fw = parts[1] || "?"
      @logger.info "[HELLO] ESP32 connected: id=#{esp32_id} fw=#{fw}"
    end

    def handle_reading(sensor_id, parts)
      kv = parts.reject(&:empty?).filter_map { |p| p.split("=", 2) if p.include?("=") }.to_h
      avg = kv["avg"].to_i

      @logger.info "[READING] id=#{sensor_id} avg=#{avg}"

      # Detect train passage (rising edge detection)
      @mutex.synchronize do
        if avg < DETECTION_THRESHOLD
          @layout_controller.sector_proximity_sensor_triggered(sensor_id: sensor_id)
        end
      end
    end

    def handle_manual_sector_advance(client)
      @logger.info "[MANUAL] Manual sector advance requested"
      @mutex.synchronize do
        @layout_controller.advance_sector
        client.puts "OK"
      end
    end

    def handle_status(client)
      @logger.info "[STATUS] Status request received"
      @mutex.synchronize do
        status = @layout_controller.status
        client.puts JSON.generate(status)
      end
    end

    def handle_set_target_speed(client, cab_address, speed)
      @logger.info "[SET_TARGET_SPEED] Cab #{cab_address} -> #{speed}"
      @mutex.synchronize do
        success = @layout_controller.set_target_speed(cab_address: cab_address, speed: speed)
        client.puts success ? "OK" : "ERROR"
      end
    end
  end
end
