# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Legion::Extensions::Gestalt::Helpers::PatternStore do
  subject(:store) { described_class.new }

  describe '#initialize' do
    it 'starts empty' do
      expect(store.patterns).to eq([])
      expect(store.size).to eq(0)
    end
  end

  describe '#add' do
    it 'adds a pattern' do
      pattern = store.add(name: :test, elements: %i[a b c])
      expect(pattern.name).to eq(:test)
      expect(store.size).to eq(1)
    end

    it 'accepts domain' do
      pattern = store.add(name: :test, elements: %i[a b c], domain: :math)
      expect(pattern.domain).to eq(:math)
    end
  end

  describe '#find' do
    it 'finds by id' do
      pattern = store.add(name: :test, elements: %i[a b c])
      found = store.find(pattern.id)
      expect(found).to eq(pattern)
    end

    it 'returns nil for unknown id' do
      expect(store.find('unknown')).to be_nil
    end
  end

  describe '#find_by_name' do
    it 'returns patterns matching name' do
      store.add(name: :test, elements: %i[a b c])
      store.add(name: :test, elements: %i[d e f])
      store.add(name: :other, elements: %i[g h i])
      expect(store.find_by_name(:test).size).to eq(2)
    end
  end

  describe '#in_domain' do
    it 'filters by domain' do
      store.add(name: :a, elements: %i[a b], domain: :math)
      store.add(name: :b, elements: %i[c d], domain: :language)
      expect(store.in_domain(:math).size).to eq(1)
    end
  end

  describe '#complete' do
    before do
      store.add(name: :alphabet, elements: %i[a b c d e])
      store.add(name: :numbers, elements: %i[one two three four five])
    end

    it 'returns completions ranked by confidence' do
      completions = store.complete(%i[a b c])
      expect(completions.size).to eq(1)
      expect(completions.first[:pattern_name]).to eq(:alphabet)
    end

    it 'returns empty for no matches' do
      expect(store.complete(%i[x y z])).to eq([])
    end

    it 'filters by domain' do
      store.add(name: :math_abc, elements: %i[a b c d e], domain: :math)
      completions = store.complete(%i[a b c], domain: :math)
      expect(completions.size).to eq(1)
      expect(completions.first[:pattern_name]).to eq(:math_abc)
    end
  end

  describe '#group_by_proximity' do
    it 'groups nearby items together' do
      groups = store.group_by_proximity([1, 2, 3, 100, 101, 102])
      expect(groups.size).to be >= 2
    end

    it 'returns single group for single item' do
      groups = store.group_by_proximity([5])
      expect(groups).to eq([[5]])
    end

    it 'returns empty for empty input' do
      groups = store.group_by_proximity([])
      expect(groups).to eq([[]])
    end
  end

  describe '#group_by_similarity' do
    it 'groups items by shared key' do
      items = [
        { type: :animal, name: :dog },
        { type: :animal, name: :cat },
        { type: :vehicle, name: :car }
      ]
      groups = store.group_by_similarity(items, key: :type)
      expect(groups.size).to eq(2)
    end
  end

  describe '#reinforce / #penalize' do
    it 'reinforces a pattern' do
      pattern = store.add(name: :test, elements: %i[a b c])
      initial = pattern.strength
      store.reinforce(pattern.id)
      expect(pattern.strength).to be > initial
    end

    it 'penalizes a pattern' do
      pattern = store.add(name: :test, elements: %i[a b c])
      initial = pattern.strength
      store.penalize(pattern.id)
      expect(pattern.strength).to be < initial
    end

    it 'returns nil for unknown id' do
      expect(store.reinforce('unknown')).to be_nil
      expect(store.penalize('unknown')).to be_nil
    end
  end

  describe '#decay_all' do
    it 'decays all patterns' do
      pattern = store.add(name: :test, elements: %i[a b c])
      initial = pattern.strength
      store.decay_all
      expect(pattern.strength).to be < initial
    end
  end

  describe '#remove' do
    it 'removes a pattern' do
      pattern = store.add(name: :test, elements: %i[a b c])
      store.remove(pattern.id)
      expect(store.size).to eq(0)
    end
  end

  describe '#to_h' do
    it 'returns stats' do
      store.add(name: :test, elements: %i[a b c])
      h = store.to_h
      expect(h).to include(:pattern_count, :by_domain, :total_matches)
    end
  end
end
