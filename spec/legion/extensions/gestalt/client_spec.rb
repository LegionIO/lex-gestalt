# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Legion::Extensions::Gestalt::Client do
  subject(:client) { described_class.new }

  describe '#initialize' do
    it 'creates a default store' do
      expect(client.store).to be_a(Legion::Extensions::Gestalt::Helpers::PatternStore)
    end

    it 'accepts an injected store' do
      custom = Legion::Extensions::Gestalt::Helpers::PatternStore.new
      injected = described_class.new(store: custom)
      expect(injected.store).to equal(custom)
    end
  end

  describe 'gestalt pattern completion lifecycle' do
    it 'learns patterns and completes fragments' do
      # Learn some patterns
      client.learn_pattern(name: :greeting, elements: %i[hello how are you today], domain: :social)
      client.learn_pattern(name: :farewell, elements: %i[goodbye see you later], domain: :social)
      client.learn_pattern(name: :fibonacci, elements: [1, 1, 2, 3, 5, 8, 13], domain: :math)

      # Complete a partial greeting
      result = client.complete_pattern(fragment: %i[hello how are])
      expect(result[:count]).to eq(1)
      expect(result[:best][:pattern_name]).to eq(:greeting)
      expect(result[:best][:missing]).to eq(%i[you today])

      # Confirm the completion was correct -> reinforces pattern
      client.confirm_completion(pattern_id: result[:best][:pattern_id], correct: true)

      # Try completing a math pattern
      math_result = client.complete_pattern(fragment: [1, 1, 2, 3], domain: :math)
      expect(math_result[:count]).to eq(1)
      expect(math_result[:best][:missing]).to eq([5, 8, 13])

      # Group items by proximity
      groups = client.group_items(items: [1, 2, 3, 50, 51, 52], principle: :proximity)
      expect(groups[:group_count]).to be >= 2

      # Decay over time
      client.update_gestalt

      # Stats
      stats = client.gestalt_stats
      expect(stats[:stats][:pattern_count]).to eq(3)
    end
  end
end
