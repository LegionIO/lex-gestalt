# lex-gestalt

Gestalt perception modeling for the LegionIO brain-modeled cognitive architecture.

## What It Does

Implements the Gestalt principles of perceptual organization — the tendency to perceive elements as unified wholes rather than isolated parts. Groups input elements by proximity, similarity, continuity, closure, symmetry, and common fate. Computes coherence scores for groups and detects emergent patterns where the whole is more than the sum of its parts. Supports holistic pattern recognition across structured inputs.

Based on Wertheimer, Köhler, and Koffka's Gestalt psychology.

## Usage

```ruby
client = Legion::Extensions::Gestalt::Client.new

# Register perceptual elements
client.register_element(content: 'auth_service', properties: { type: :service, domain: :security })
client.register_element(content: 'session_store', properties: { type: :storage, domain: :security })
client.register_element(content: 'token_validator', properties: { type: :service, domain: :security })

# Group by a Gestalt principle
client.apply_grouping(
  element_ids: ['...', '...', '...'],
  principle: :similarity
)
# => { success: true, group_id: "...", principle: :similarity, coherence: 0.8, emergence_detected: true }

# Detect emergent patterns in the group
client.detect_emergence(group_id: '...')
# => { emergence_score: 0.85, emergence_label: :strong_emergence,
#      emergent_pattern: 'authentication_cluster' }

# Find elements similar to a reference
client.find_similar_elements(reference_id: '...', threshold: 0.6)

# Automatically group all ungrouped elements
client.auto_group(domain: :security)
# => { groups_formed: 2, elements_grouped: 5, ungrouped_count: 1 }

# View active groups by coherence
client.active_groups
# => { groups: [...sorted by coherence], count: 2 }

# Periodic maintenance
client.update_gestalt
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
