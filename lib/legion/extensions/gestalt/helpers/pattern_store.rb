# frozen_string_literal: true

module Legion
  module Extensions
    module Gestalt
      module Helpers
        class PatternStore
          attr_reader :patterns

          def initialize
            @patterns = []
          end

          def add(name:, elements:, domain: :general)
            pattern = Pattern.new(name: name, elements: elements, domain: domain)
            @patterns << pattern
            trim
            pattern
          end

          def find(id)
            @patterns.find { |p| p.id == id }
          end

          def find_by_name(name)
            @patterns.select { |p| p.name == name }
          end

          def in_domain(domain)
            @patterns.select { |p| p.domain == domain }
          end

          def complete(fragment, domain: nil)
            candidates = domain ? in_domain(domain) : @patterns
            completions = candidates.filter_map { |p| p.complete(fragment) }
            completions.sort_by { |c| -c[:confidence] }.first(Constants::MAX_COMPLETIONS)
          end

          def group_by_proximity(items, threshold: Constants::PROXIMITY_THRESHOLD)
            return [items] if items.size <= 1

            groups = []
            remaining = items.dup

            until remaining.empty?
              seed = remaining.shift
              group = [seed]
              remaining.reject! do |item|
                if proximity(seed, item) <= threshold
                  group << item
                  true
                else
                  false
                end
              end
              groups << group
            end
            groups
          end

          def group_by_similarity(items, key: :type, **)
            items.group_by { |item| item.is_a?(Hash) ? item[key] : item }.values
          end

          def reinforce(id)
            pattern = find(id)
            return nil unless pattern

            pattern.reinforce
            pattern
          end

          def penalize(id)
            pattern = find(id)
            return nil unless pattern

            pattern.penalize
            pattern
          end

          def decay_all
            @patterns.each(&:decay)
          end

          def remove(id)
            @patterns.reject! { |p| p.id == id }
          end

          def size
            @patterns.size
          end

          def to_h
            {
              pattern_count: @patterns.size,
              by_domain:     @patterns.group_by(&:domain).transform_values(&:size),
              total_matches: @patterns.sum(&:match_count)
            }
          end

          private

          def proximity(item_a, item_b)
            return 1.0 unless item_a.is_a?(Numeric) && item_b.is_a?(Numeric)

            (item_a - item_b).abs.to_f / [item_a.abs, item_b.abs, 1].max
          end

          def trim
            return unless @patterns.size > Constants::MAX_PATTERNS

            @patterns.sort_by!(&:strength)
            @patterns.shift(@patterns.size - Constants::MAX_PATTERNS)
          end
        end
      end
    end
  end
end
