# 0006 — MIT app with bundled CC0 / Public-Domain content

**Status:** Accepted

## Context

Mantle ships and *redistributes* content: an affinity deck of 24 images, plus
hand-authored reference text (the canon), drawn SVG plates, and Spot questions.
Redistributed images carry licensing risk — a "collection is open access" claim is
not per-object clearance, and CC0 waives copyright but not trademark, publicity, or
the copyright of anything depicted inside the image. The app itself is MIT.

## Decision

- **License the app MIT**, and keep bundled hand-authored content (canon,
  through-lines, Spot questions, plates) MIT alongside the code — no CC BY-SA
  split to reason about.
- **Require CC0 or true Public Domain, verified per-object, for every deck image.**
  Sources for v1 are the Cleveland Museum of Art (CC0) and the Met (Public Domain),
  each cleared on the specific object, preferring works with no recognizable living
  people or visible logos.
- **Enforce provenance in a test.** Every deck record must carry a complete
  provenance block (`institution`, `accessionId`, `sourceUrl`, `license`,
  `creator`, `title`); the content-validation test fails the build otherwise.

## Consequences

- The deck is redistributable without a licensing landmine, and every image is
  traceable to its source object.
- Provenance is not a promise but a build gate — a new image can't ship without it.
- Expanding or rotating the deck follows a written playbook
  ([cc0-image-sourcing.md](../cc0-image-sourcing.md)); larger sources
  (Smithsonian, NGA, Rijksmuseum) need API keys and are deferred.
- Keeping content MIT (not CC BY-SA) trades some "share-alike" ideology for a
  single, simple license story across the whole repo — accepted deliberately.
