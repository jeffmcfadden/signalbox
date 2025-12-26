require 'socket'
require 'logger'

module SignalBox
  module DCC
    
    # DCC Client for communicating with a DCC command station over TCP
    # Canonical target is DCC-EX command station
    class Client
      def initialize(host, port, logger: Logger.new(STDOUT))
        @host = host
        @port = port
        @logger = logger
        @socket = nil
      end

      def connect
        ensure_connected!
      end

      def close
        safe_close
      rescue => e
        @logger.warn "[DCC] close failed (#{e.class}: #{e.message})"
      end

      def send(cmd)
        ensure_connected!
        @socket.puts(cmd)
      rescue => e
        @logger.warn "[DCC] send failed (#{e.class}: #{e.message}); reconnecting"
        safe_close
        ensure_connected!
        @socket.puts(cmd)
      end

      # Track power control
      def track_power_on!(track = "MAIN")
        @logger.debug "[DCC] Track power ON: #{track}"
        send("<1 #{track}>")
      end

      def track_power_off!(track = "MAIN")
        @logger.debug "[DCC] Track power OFF: #{track}"
        send("<0 #{track}>")
      end

      # Legacy aliases
      def track_power_main!
        track_power_on!("MAIN")
      end


      def set_speed(addr:, speed:, dir: 1)
        @logger.debug "[DCC] Set speed addr=#{addr} speed=#{speed} dir=#{dir}"
        speed = [[speed, 0].max, 127].min
        send("<t #{addr} #{speed} #{dir}>")
      end

      # Request cab status and parse the broadcast response
      # Returns a hash with: { cab:, reg:, speed:, direction:, speed_byte:, funct_map: }
      # speed: 0-127 (bits 0-6 of speed_byte)
      # direction: 0 (reverse) or 1 (forward) (bit 7 of speed_byte)
      # or nil if no response received
      def get_cab_status(cab)
        @logger.debug "[DCC] Getting status for cab #{cab}"
        response = send_and_receive("<t #{cab}>", timeout: 2.0)

        if response && response =~ /<l\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)>/
          speed_byte = $3.to_i

          {
            cab: $1.to_i,
            reg: $2.to_i,
            speed: speed_byte & 0x7F,
            direction: (speed_byte & 0x80) >> 7,
            speed_byte: speed_byte,
            funct_map: $4.to_i
          }
        else
          @logger.warn "[DCC] No valid response for cab #{cab} status request"
          nil
        end
      end

      # Emergency stop - halts all locomotives immediately
      def emergency_stop!
        @logger.warn "[DCC] EMERGENCY STOP"
        send("<!>")
      end

      # Function control (lights, sound, etc.)
      # funct: 0-68 (F0-F68)
      # state: 1=on, 0=off
      def set_function(cab:, funct:, state:)
        @logger.debug "[DCC] Set function cab=#{cab} F#{funct}=#{state}"
        send("<F #{cab} #{funct} #{state}>")
      end

      # Convenience methods for common functions
      def set_light(cab:, state:)
        set_function(cab: cab, funct: 0, state: state)
      end

      def light_on(cab:)
        set_light(cab: cab, state: 1)
      end

      def light_off(cab:)
        set_light(cab: cab, state: 0)
      end

      # Turnout/point control
      # id: turnout ID
      # state: 1/"T"=throw, 0/"C"=close, "X"=examine
      def set_turnout(id:, state:)
        @logger.debug "[DCC] Set turnout #{id} to #{state}"
        send("<T #{id} #{state}>")
      end

      def throw_turnout(id:)
        set_turnout(id: id, state: 1)
      end

      def close_turnout(id:)
        set_turnout(id: id, state: 0)
      end

      # List all defined turnouts
      # Returns array of responses, each formatted as <H id state>
      def list_turnouts
        @logger.debug "[DCC] Requesting turnout list"
        # This requires reading multiple responses, so we'll just send the command
        send("<T>")
        # Note: Response handling would need enhancement for multi-line responses
      end

      # Accessory decoder control
      # Using address/subaddress format (addr: 0-511, subaddr: 0-3)
      def set_accessory(addr:, subaddr:, activate:)
        @logger.debug "[DCC] Accessory addr=#{addr} subaddr=#{subaddr} activate=#{activate}"
        send("<a #{addr} #{subaddr} #{activate}>")
      end

      # Using linear address format (1-2044)
      def set_accessory_linear(addr:, activate:)
        @logger.debug "[DCC] Accessory linear addr=#{addr} activate=#{activate}"
        send("<a #{addr} #{activate}>")
      end


      private

      def send_and_receive(cmd, timeout: 2.0)
        ensure_connected!
        @socket.puts(cmd)

        # Wait for response with timeout
        if IO.select([@socket], nil, nil, timeout)
          @socket.gets&.chomp
        else
          nil
        end
      rescue => e
        @logger.warn "[DCC] send_and_receive failed (#{e.class}: #{e.message})"
        nil
      end

      def ensure_connected!
        return if @socket && !@socket.closed?
        @socket = TCPSocket.new(@host, @port)
      end

      def safe_close
        @socket&.close
      rescue
        nil
      ensure
        @socket = nil
      end

    end
  end
end
