require_relative 'layout_dsl'

module SignalBox
  class LayoutLoader
  extend LayoutDSL

  # Load a layout file and return the Layout object
  # @param file_path [String] Path to the layout definition file
  # @param logger [Logger] Logger instance to use
  # @return [Layout] The loaded layout
  def self.load(file_path, logger: Logger.new(STDOUT))
    unless File.exist?(file_path)
      raise "Layout file not found: #{file_path}"
    end

    logger.info "[LAYOUT] Loading layout from #{file_path}"

    # Read and evaluate the layout file in the context of this class
    # This makes the `layout` method available
    content = File.read(file_path)
    layout_obj = self.instance_eval(content, file_path)

    logger.info "[LAYOUT] Loaded: #{layout_obj}"
    logger.info "[LAYOUT]   Cabs: #{layout_obj.cabs.map(&:name).join(', ')}"
    logger.info "[LAYOUT]   Sectors: #{layout_obj.sectors.map(&:name).join(', ')}"
    logger.info "[LAYOUT]   Sensors: #{layout_obj.proximity_sensors.map(&:id).join(', ')}"

    layout_obj
  end
  end
end
