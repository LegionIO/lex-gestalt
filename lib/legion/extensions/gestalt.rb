# frozen_string_literal: true

require_relative 'gestalt/version'
require_relative 'gestalt/helpers/constants'
require_relative 'gestalt/helpers/pattern'
require_relative 'gestalt/helpers/pattern_store'
require_relative 'gestalt/runners/gestalt'
require_relative 'gestalt/client'

module Legion
  module Extensions
    module Gestalt
      extend Legion::Extensions::Core if defined?(Legion::Extensions::Core)
    end
  end
end
