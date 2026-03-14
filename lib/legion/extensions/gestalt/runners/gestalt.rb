# frozen_string_literal: true

module Legion
  module Extensions
    module Gestalt
      module Runners
        module Gestalt
          include Legion::Extensions::Helpers::Lex

          def store
            @store ||= Helpers::PatternStore.new
          end

          def learn_pattern(name:, elements:, domain: :general, **)
            pattern = store.add(name: name, elements: elements, domain: domain)
            Legion::Logging.debug "[gestalt] learned pattern=#{name} domain=#{domain} size=#{elements.size}"
            { success: true, pattern: pattern.to_h }
          end

          def complete_pattern(fragment:, domain: nil, **)
            completions = store.complete(fragment, domain: domain)
            Legion::Logging.debug "[gestalt] complete: #{completions.size} candidates for #{fragment.size} elements"
            {
              success:     true,
              completions: completions,
              count:       completions.size,
              best:        completions.first
            }
          end

          def confirm_completion(pattern_id:, correct: true, **)
            result = if correct
                       store.reinforce(pattern_id)
                     else
                       store.penalize(pattern_id)
                     end
            return { success: false, reason: :not_found } unless result

            Legion::Logging.debug "[gestalt] #{correct ? 'reinforced' : 'penalized'} pattern=#{pattern_id}"
            { success: true, pattern: result.to_h }
          end

          def group_items(items:, principle: :proximity, **)
            groups = case principle
                     when :proximity
                       store.group_by_proximity(items)
                     when :similarity
                       store.group_by_similarity(items)
                     else
                       [items]
                     end
            { success: true, groups: groups, group_count: groups.size, principle: principle }
          end

          def update_gestalt(**)
            store.decay_all
            Legion::Logging.debug "[gestalt] tick: patterns=#{store.size}"
            { success: true, pattern_count: store.size }
          end

          def patterns_in_domain(domain:, **)
            patterns = store.in_domain(domain)
            { success: true, patterns: patterns.map(&:to_h), count: patterns.size }
          end

          def remove_pattern(id:, **)
            store.remove(id)
            { success: true }
          end

          def gestalt_stats(**)
            { success: true, stats: store.to_h }
          end
        end
      end
    end
  end
end
