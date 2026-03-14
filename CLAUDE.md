# lex-gestalt

**Level 3 Documentation** — Parent: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`

## Purpose

Gestalt perception modeling for the LegionIO cognitive architecture. Implements the Gestalt principles of perceptual organization — the tendency to perceive elements as unified wholes rather than isolated parts. Groups input elements by proximity, similarity, continuity, closure, and symmetry. Computes a gestalt coherence score for grouped elements and detects emergent patterns (the "whole is more than the sum of its parts"). Supports holistic pattern recognition in structured input.

Based on Wertheimer, Köhler, and Koffka's Gestalt psychology.

## Gem Info

- **Gem name**: `lex-gestalt`
- **Version**: `0.1.0`
- **Namespace**: `Legion::Extensions::Gestalt`
- **Location**: `extensions-agentic/lex-gestalt/`

## File Structure

```
lib/legion/extensions/gestalt/
  gestalt.rb                    # Top-level requires
  version.rb                    # VERSION = '0.1.0'
  client.rb                     # Client class
  helpers/
    constants.rb                # GESTALT_PRINCIPLES, GROUP_LABELS, EMERGENCE_THRESHOLD, thresholds
    perceptual_element.rb       # PerceptualElement value object
    gestalt_group.rb            # GestaltGroup: bound elements with coherence and emergence
    gestalt_engine.rb           # Engine: element registry, grouping, emergence detection
  runners/
    gestalt.rb                  # Runner module: all public methods
```

## Key Constants

| Constant | Value | Purpose |
|---|---|---|
| `GESTALT_PRINCIPLES` | `[:proximity, :similarity, :continuity, :closure, :symmetry, :common_fate]` | Grouping laws |
| `GROUPING_THRESHOLD` | 0.4 | Minimum principle strength for elements to be grouped |
| `EMERGENCE_THRESHOLD` | 0.7 | Coherence above which emergent pattern is detected |
| `COHERENCE_DECAY` | 0.02 | Group coherence lost per maintenance cycle |
| `MAX_ELEMENTS` | 200 | Perceptual element cap |
| `MAX_GROUPS` | 100 | Gestalt group cap |
| `MAX_GROUP_HISTORY` | 300 | Archived group cap |
| `PRINCIPLE_WEIGHTS` | hash per principle | Contribution weight per Gestalt law to coherence score |
| `GROUP_LABELS` | range hash | `strongly_grouped / grouped / weakly_grouped / ungrouped` |
| `EMERGENCE_LABELS` | range hash | `strong_emergence / moderate_emergence / weak_emergence / none` |

## Runners

All methods in `Legion::Extensions::Gestalt::Runners::Gestalt`.

| Method | Key Args | Returns |
|---|---|---|
| `register_element` | `content:, properties: {}, domain: nil` | `{ success:, element_id:, content:, domain: }` |
| `apply_grouping` | `element_ids:, principle:` | `{ success:, group_id:, principle:, coherence:, emergence_detected: }` |
| `detect_emergence` | `group_id:` | `{ success:, group_id:, emergence_score:, emergence_label:, emergent_pattern: }` |
| `find_similar_elements` | `reference_id:, threshold: 0.5` | `{ success:, similar:, count: }` |
| `auto_group` | `domain: nil` | `{ success:, groups_formed:, elements_grouped:, ungrouped_count: }` |
| `group_coherence` | `group_id:` | `{ success:, group_id:, coherence:, group_label:, element_count: }` |
| `active_groups` | — | `{ success:, groups:, count: }` (sorted by coherence) |
| `ungrouped_elements` | — | `{ success:, elements:, count: }` |
| `update_gestalt` | — | `{ success:, groups_decayed:, elements_pruned: }` |
| `gestalt_stats` | — | Full stats hash |

## Helpers

### `PerceptualElement`
Input unit. Attributes: `id`, `content`, `properties` (hash), `domain`, `grouped` (boolean), `created_at`. `to_h`.

### `GestaltGroup`
Bound element set. Attributes: `id`, `element_ids` (array), `principle`, `coherence`, `emergence_score`, `emergent_pattern` (string or nil), `created_at`. Key methods: `decay!`, `coherence_label`, `emergence_label`, `to_h`.

### `GestaltEngine`
Central store: `@elements` (hash by id), `@groups` (hash by id), `@history` (array). Key methods:
- `register(content:, properties:, domain:)`: creates PerceptualElement
- `group(element_ids:, principle:)`: retrieves elements, computes principle strength from property similarity/proximity/continuity, creates GestaltGroup if strength >= `GROUPING_THRESHOLD`
- `detect_emergence(group_id:)`: computes coherence score from element count, principle strength, and inter-element relationships; returns emergent pattern description if > `EMERGENCE_THRESHOLD`
- `find_similar(reference_id:, threshold:)`: compares properties of reference element against all others, returns those with similarity > threshold
- `auto_group(domain:)`: clusters ungrouped elements by best-matching Gestalt principle automatically

## Integration Points

- `auto_group` called from lex-tick's `sensory_processing` phase on incoming perceptual elements
- `detect_emergence` output feeds lex-creativity as seed material for combinational idea generation
- `active_groups` provide structured percepts for lex-feature-binding's feature set input
- `emergence_detected` flag triggers lex-epistemic-curiosity's gap detection for novel patterns
- `group_coherence` informs lex-prediction's confidence (high coherence groups = predictable patterns)

## Development Notes

- Principle computation is property-based: proximity groups elements with similar `domain`, similarity groups those with overlapping `properties` keys
- Emergence detection is threshold-based on coherence score, not semantic pattern recognition
- `emergent_pattern` is a descriptive string derived from element content concatenation, not LLM-generated
- `auto_group` uses a greedy algorithm: each element is assigned to its best principle match, then grouped
- Elements can belong to multiple groups (grouping does not set `grouped = true` exclusively)
