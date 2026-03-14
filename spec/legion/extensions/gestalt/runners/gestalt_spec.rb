# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Legion::Extensions::Gestalt::Runners::Gestalt do
  let(:runner) do
    obj = Object.new
    obj.extend(described_class)
    obj
  end

  before do
    runner.learn_pattern(name: :alphabet, elements: %i[a b c d e], domain: :language)
    runner.learn_pattern(name: :counting, elements: %i[one two three four five], domain: :math)
  end

  describe '#learn_pattern' do
    it 'stores a pattern' do
      result = runner.learn_pattern(name: :test, elements: %i[x y z])
      expect(result[:success]).to be true
      expect(result[:pattern][:name]).to eq(:test)
    end
  end

  describe '#complete_pattern' do
    it 'completes a partial pattern' do
      result = runner.complete_pattern(fragment: %i[a b c])
      expect(result[:success]).to be true
      expect(result[:count]).to eq(1)
      expect(result[:best][:pattern_name]).to eq(:alphabet)
      expect(result[:best][:missing]).to eq(%i[d e])
    end

    it 'returns empty for no match' do
      result = runner.complete_pattern(fragment: %i[x y z])
      expect(result[:count]).to eq(0)
    end

    it 'filters by domain' do
      result = runner.complete_pattern(fragment: %i[a b c], domain: :math)
      expect(result[:count]).to eq(0)
    end
  end

  describe '#confirm_completion' do
    it 'reinforces a correct completion' do
      pattern_id = runner.store.patterns.first.id
      result = runner.confirm_completion(pattern_id: pattern_id, correct: true)
      expect(result[:success]).to be true
      expect(result[:pattern][:strength]).to be > 1.0
    end

    it 'penalizes an incorrect completion' do
      pattern_id = runner.store.patterns.first.id
      result = runner.confirm_completion(pattern_id: pattern_id, correct: false)
      expect(result[:success]).to be true
      expect(result[:pattern][:strength]).to be < 1.0
    end

    it 'returns not_found for unknown pattern' do
      result = runner.confirm_completion(pattern_id: 'unknown')
      expect(result[:success]).to be false
    end
  end

  describe '#group_items' do
    it 'groups by proximity' do
      result = runner.group_items(items: [1, 2, 3, 100, 101], principle: :proximity)
      expect(result[:success]).to be true
      expect(result[:group_count]).to be >= 2
    end

    it 'groups by similarity' do
      items = [
        { type: :a, v: 1 },
        { type: :a, v: 2 },
        { type: :b, v: 3 }
      ]
      result = runner.group_items(items: items, principle: :similarity)
      expect(result[:group_count]).to eq(2)
    end
  end

  describe '#update_gestalt' do
    it 'decays patterns' do
      initial = runner.store.patterns.first.strength
      runner.update_gestalt
      expect(runner.store.patterns.first.strength).to be < initial
    end
  end

  describe '#patterns_in_domain' do
    it 'returns patterns for domain' do
      result = runner.patterns_in_domain(domain: :language)
      expect(result[:count]).to eq(1)
    end
  end

  describe '#remove_pattern' do
    it 'removes a pattern' do
      pattern_id = runner.store.patterns.first.id
      runner.remove_pattern(id: pattern_id)
      expect(runner.store.size).to eq(1)
    end
  end

  describe '#gestalt_stats' do
    it 'returns stats' do
      result = runner.gestalt_stats
      expect(result[:success]).to be true
      expect(result[:stats]).to include(:pattern_count, :by_domain, :total_matches)
    end
  end
end
