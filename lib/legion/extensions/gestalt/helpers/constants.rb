# frozen_string_literal: true

module Legion
  module Extensions
    module Gestalt
      module Helpers
        module Constants
          # Minimum pattern match ratio to attempt completion
          COMPLETION_THRESHOLD = 0.3

          # Confidence boost for each additional matching element
          MATCH_CONFIDENCE_BOOST = 0.15

          # Maximum stored patterns
          MAX_PATTERNS = 200

          # Maximum elements per pattern
          MAX_PATTERN_SIZE = 50

          # Decay rate for pattern recency (older patterns contribute less)
          PATTERN_DECAY = 0.01

          # Minimum confidence to report a completion
          MIN_COMPLETION_CONFIDENCE = 0.2

          # Maximum completion candidates to return
          MAX_COMPLETIONS = 5

          # Grouping principles (Wertheimer's laws)
          GROUPING_PRINCIPLES = %i[proximity similarity closure continuity common_fate].freeze

          # Proximity threshold for grouping (normalized distance)
          PROXIMITY_THRESHOLD = 0.3

          # Similarity threshold for grouping
          SIMILARITY_THRESHOLD = 0.6

          # Reinforcement when a completion is confirmed correct
          CORRECT_REINFORCEMENT = 0.1

          # Penalty when a completion is wrong
          INCORRECT_PENALTY = 0.15
        end
      end
    end
  end
end
