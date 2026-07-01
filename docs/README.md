# Documentation

Organized on the [Diátaxis](https://diataxis.fr/) model — four kinds of docs for
four different needs. Find what you need by *what you're trying to do*, not by
guessing a filename.

| I want to… | I need | Go to |
|---|---|---|
| **learn by doing** | a Tutorial | [Tutorials](#tutorials) |
| **accomplish a specific task** | a How-to guide | [How-to guides](#how-to-guides) |
| **look up exact details** | Reference | [Reference](#reference) |
| **understand why** | Explanation | [Explanation](#explanation) |

New here? Start with the [README](../README.md), then
[Explanation § Concepts](concepts.md), then the
[Architecture overview](architecture/OVERVIEW.md).

---

## Tutorials
*Learning-oriented — take me by the hand through my first success.*

- The **[README quickstart](../README.md#quickstart)** — install, run, and take
  a sitting from gather to Charter.

*Gap (contributions welcome):* a hand-held "your family's first Charter in 15
minutes" walkthrough with screenshots. If you write one, put it in
`docs/tutorials/`.

## How-to guides
*Task-oriented — how do I accomplish X (assumes you know the basics)?*

- **[Build & run](how-to/build-and-run.md)** — dev setup, the sibling-package
  dependencies, Drift codegen, running the suite, building for each platform.
- **[Source deck images](cc0-image-sourcing.md)** — the verified CC0/PD image
  sourcing playbook (for re-sourcing or expanding the affinity deck).
- Agent-guidance for working *in* this repo: **[AGENTS.md](../AGENTS.md)**.

## Reference
*Information-oriented — tell me exactly, precisely, completely.*

- **[Data model](reference/data-model.md)** — the Drift tables, the bundled
  content assets, and the per-version feature status.
- **[Reveal semantics (yellow paper)](spec/yellow-paper.md)** — the rigorous
  specification of the merge, the Spine/Contested partition, and the through-line
  naming predicate.

## Explanation
*Understanding-oriented — help me understand the ideas and the why.*

- **[Vision](../VISION.md)** — the one idea, the invariants, the honest scorecard.
- **[Architecture overview](architecture/OVERVIEW.md)** — the layers + a diagram.
- **[Architecture Decision Records](adr/)** — why each load-bearing choice was made.
- **[Concepts](concepts.md)** — the deck, the round, the merge, the reveal, the
  Charter, the through-lines.
- **[Privacy model](privacy-model.md)** — exactly what leaves the device (nothing)
  and how you can verify it.
- **[Limitations](limitations.md)** — read before adopting. What it does *not* do.

---

### The white paper & yellow paper

Two long-form documents complement this tree:
- **[White paper](whitepaper.md)** — the case for Mantle: why a household's
  aesthetic is worth discovering, why revealed preference beats a quiz, and why
  this belongs local-first.
- **[Yellow paper / reveal semantics](spec/yellow-paper.md)** — the precise
  specification of the reveal's decision procedure, including the one real theorem
  (why the Spine partition can't admit a mutually-disliked item).
