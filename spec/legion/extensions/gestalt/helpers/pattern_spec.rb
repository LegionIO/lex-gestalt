# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Legion::Extensions::Gestalt::Helpers::Pattern do
  subject(:pattern) { described_class.new(name: :abc_sequence, elements: %i[a b c d e]) }

  describe '#initialize' do
    it 'generates a uuid' do
      expect(pattern.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'stores name and elements' do
      expect(pattern.name).to eq(:abc_sequence)
      expect(pattern.elements).to eq(%i[a b c d e])
    end

    it 'defaults domain to general' do
      expect(pattern.domain).to eq(:general)
    end

    it 'starts with strength 1.0' do
      expect(pattern.strength).to eq(1.0)
    end

    it 'starts with zero match count' do
      expect(pattern.match_count).to eq(0)
    end

    it 'truncates elements at MAX_PATTERN_SIZE' do
      big = described_class.new(name: :big, elements: (1..100).to_a)
      expect(big.elements.size).to eq(Legion::Extensions::Gestalt::Helpers::Constants::MAX_PATTERN_SIZE)
    end
  end

  describe '#match_ratio' do
    it 'returns 1.0 for perfect match' do
      expect(pattern.match_ratio(%i[a b c d e])).to eq(1.0)
    end

    it 'returns 0.0 for no match' do
      expect(pattern.match_ratio(%i[x y z])).to eq(0.0)
    end

    it 'returns partial ratio' do
      expect(pattern.match_ratio(%i[a b c])).to eq(0.6)
    end

    it 'returns 0.0 for empty fragment' do
      expect(pattern.match_ratio([])).to eq(0.0)
    end
  end

  describe '#missing_elements' do
    it 'returns elements not in fragment' do
      expect(pattern.missing_elements(%i[a b c])).to eq(%i[d e])
    end

    it 'returns all elements for empty fragment' do
      expect(pattern.missing_elements([])).to eq(%i[a b c d e])
    end

    it 'returns empty for complete fragment' do
      expect(pattern.missing_elements(%i[a b c d e])).to eq([])
    end
  end

  describe '#complete' do
    it 'returns completion for sufficient match' do
      result = pattern.complete(%i[a b c])
      expect(result).not_to be_nil
      expect(result[:pattern_name]).to eq(:abc_sequence)
      expect(result[:missing]).to eq(%i[d e])
      expect(result[:confidence]).to be > 0
    end

    it 'returns nil for insufficient match' do
      result = pattern.complete(%i[x])
      expect(result).to be_nil
    end

    it 'increments match count' do
      pattern.complete(%i[a b c])
      expect(pattern.match_count).to eq(1)
    end
  end

  describe '#reinforce' do
    it 'increases strength' do
      initial = pattern.strength
      pattern.reinforce
      expect(pattern.strength).to be > initial
    end

    it 'caps at 2.0' do
      20.times { pattern.reinforce }
      expect(pattern.strength).to eq(2.0)
    end
  end

  describe '#penalize' do
    it 'decreases strength' do
      initial = pattern.strength
      pattern.penalize
      expect(pattern.strength).to be < initial
    end

    it 'floors at 0.1' do
      20.times { pattern.penalize }
      expect(pattern.strength).to eq(0.1)
    end
  end

  describe '#decay' do
    it 'slowly reduces strength' do
      initial = pattern.strength
      pattern.decay
      expect(pattern.strength).to be < initial
    end
  end

  describe '#to_h' do
    it 'returns all fields' do
      h = pattern.to_h
      expect(h).to include(:id, :name, :domain, :elements, :strength, :match_count, :size)
    end
  end
end
