# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module Gestalt
      module Helpers
        class Pattern
          attr_reader :id, :name, :domain, :elements, :created_at
          attr_accessor :strength, :match_count

          def initialize(name:, elements:, domain: :general)
            @id          = SecureRandom.uuid
            @name        = name
            @domain      = domain
            @elements    = elements.first(Constants::MAX_PATTERN_SIZE)
            @strength    = 1.0
            @match_count = 0
            @created_at  = Time.now.utc
          end

          def match_ratio(fragment)
            return 0.0 if @elements.empty? || fragment.empty?

            matches = fragment.count { |e| @elements.include?(e) }
            matches.to_f / @elements.size
          end

          def missing_elements(fragment)
            @elements - fragment
          end

          def complete(fragment)
            ratio = match_ratio(fragment)
            return nil if ratio < Constants::COMPLETION_THRESHOLD

            confidence = compute_confidence(ratio)
            missing = missing_elements(fragment)

            @match_count += 1
            {
              pattern_id:   @id,
              pattern_name: @name,
              completed:    @elements,
              missing:      missing,
              confidence:   confidence.round(4),
              match_ratio:  ratio.round(4)
            }
          end

          def reinforce
            @strength = [@strength + Constants::CORRECT_REINFORCEMENT, 2.0].min
          end

          def penalize
            @strength = [@strength - Constants::INCORRECT_PENALTY, 0.1].max
          end

          def decay
            @strength = [@strength - Constants::PATTERN_DECAY, 0.1].max
          end

          def to_h
            {
              id:          @id,
              name:        @name,
              domain:      @domain,
              elements:    @elements,
              strength:    @strength.round(4),
              match_count: @match_count,
              size:        @elements.size
            }
          end

          private

          def compute_confidence(ratio)
            base = ratio * Constants::MATCH_CONFIDENCE_BOOST / Constants::COMPLETION_THRESHOLD
            (base * @strength).clamp(0.0, 1.0)
          end
        end
      end
    end
  end
end
