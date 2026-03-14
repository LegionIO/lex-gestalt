# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Legion::Extensions::Gestalt::Helpers::Constants do
  describe 'COMPLETION_THRESHOLD' do
    it 'is between 0 and 1' do
      expect(described_class::COMPLETION_THRESHOLD).to be_between(0.0, 1.0).exclusive
    end
  end

  describe 'GROUPING_PRINCIPLES' do
    it 'includes all Wertheimer laws' do
      expect(described_class::GROUPING_PRINCIPLES).to include(:proximity, :similarity, :closure)
    end

    it 'is frozen' do
      expect(described_class::GROUPING_PRINCIPLES).to be_frozen
    end
  end

  describe 'reinforcement asymmetry' do
    it 'penalizes more than reinforces' do
      expect(described_class::INCORRECT_PENALTY).to be > described_class::CORRECT_REINFORCEMENT
    end
  end
end
