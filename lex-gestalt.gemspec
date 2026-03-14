# frozen_string_literal: true

require_relative 'lib/legion/extensions/gestalt/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-gestalt'
  spec.version       = Legion::Extensions::Gestalt::VERSION
  spec.authors       = ['Matthew Iverson']
  spec.email         = ['matt@iverson.io']

  spec.summary       = 'Gestalt pattern completion for LegionIO'
  spec.description   = 'Models gestalt perception — completing partial patterns from context, ' \
                       'recognizing wholes from fragments, and grouping related signals.'
  spec.homepage      = 'https://github.com/LegionIO/lex-gestalt'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.files         = Dir['lib/**/*', 'LICENSE', 'README.md']
  spec.require_paths = ['lib']
  spec.metadata['rubygems_mfa_required'] = 'true'
end
