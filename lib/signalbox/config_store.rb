# frozen_string_literal: true

require "yaml"

module SignalBox
  class ConfigStore
    DEFAULT_CONFIG = {
      "trigger_delta" => 200,
      "release_delta" => 120,
      "debounce_ms"   => 80
    }.freeze

    def initialize(path)
      @path = path
      @mutex = Mutex.new
      @configs = load_file
    end

    def get(sensor_id)
      @mutex.synchronize do
        DEFAULT_CONFIG.merge(@configs.fetch(sensor_id, {}))
      end
    end

    def set(sensor_id, hash)
      @mutex.synchronize do
        @configs[sensor_id] ||= {}
        @configs[sensor_id].merge!(hash)
        save_file
      end
    end

    private

    def load_file
      return {} unless File.exist?(@path)
      YAML.load_file(@path) || {}
    rescue => e
      $logger.warn "Failed to load #{@path}: #{e}"
      {}
    end

    def save_file
      File.write(@path, YAML.dump(@configs))
    end
  end
end
