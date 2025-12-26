# frozen_string_literal: true

# Add lib directory to load path
$LOAD_PATH.unshift(__dir__) unless $LOAD_PATH.include?(__dir__)

require "signalbox/version"

# Core classes
require "signalbox/cab"
require "signalbox/layout"
require "signalbox/layout_sector"
require "signalbox/proximity_sensor"

# DCC communication
require "signalbox/dcc/client"

# Controllers
require "signalbox/layout_controller"

# DSL and loaders
require "signalbox/layout_dsl"
require "signalbox/layout_loader"

# Server components
require "signalbox/sensor_client_handler"
require "signalbox/config_store"

module SignalBox
  class Error < StandardError; end
end
