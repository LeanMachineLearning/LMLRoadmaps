# LMLRoadmaps

The human-written roadmaps for [LMLExplore](https://github.com/LeanMachineLearning/LMLExplore), a
Lean 4 library of machine learning theory built on Mathlib,
[Tau Ceti](https://github.com/TauCetiProject/TauCeti) and
[LML](https://github.com/LeanMachineLearning/LML). Humans decide here what gets built; AI
contributors write the code in LMLExplore, and AI reviewers check it against these roadmaps and
the [Tau Ceti review rubrics](https://github.com/TauCetiProject/TauCetiReview).

Each roadmap is a directory `LMLRoadmaps/<Area>/` holding:

- `README.md`: the definitive specification of the area;
- `Suggested.lean`: suggested Lean forms for the targets, with `sorry` proofs;
- `metadata.toml`: the area's arXiv topic, for example `topic = "math.ST"`.

Roadmaps declared complete move to `Completed/`. See [CONTRIBUTING.md](CONTRIBUTING.md) for how to
propose or review one.

## Roadmaps

No roadmap yet.

## Writing a roadmap

A roadmap is a specification for material we want in LMLExplore, written so that an AI contributor
and its reviewers can act on it without guessing. This checklist adapts
[Tau Ceti's](https://github.com/TauCetiProject/TauCetiRoadmap#writing-a-roadmap).

- **Build the library, don't race to the theorem.** For each object, ask for its basic theory,
  not only the lemma the headline result needs. A definition without the API that makes it usable
  is not a contribution.
- **No gaps.** Every milestone rests on material that exists in Mathlib, Tau Ceti, LML or
  LMLExplore, on earlier material in the same roadmap, or on an explicitly cited other roadmap
  here. If something needed does not exist, building it is itself a target.
- **Every item is unambiguous.** A careful agent must be able to tell exactly which definition or
  theorem is meant.
- **Clear boundaries.** Roadmaps here do not overlap each other; dependencies between them are
  stated.
- **Be definite about scope.** Nothing is "optional", "deferred" or "for later". Sequence the
  work into milestones, but every item belongs to one.
- **Pin conventions.** Decide conventions up front (for example losses versus rewards, regret
  normalisation, measurability assumptions, discrete versus general spaces), or implementors will
  decide them badly.
- **Roadmaps are timeless.** Say what we want, not how the roadmap came to say it.

### Working with the dependencies

- **Use the vocabulary of the dependencies.** Where Mathlib, Tau Ceti or LML already has a way to
  say something, use it rather than a private version.
- **Plans elsewhere never block us.** A roadmap here may specify material that a Tau Ceti roadmap,
  an open Mathlib pull request or LML also intends to build. Cite it, and follow the names and
  statement shapes it fixes, so that adopting the upstream version later is a deletion plus an
  import. Never write "blocked", "pending upstream" or "wait for".
- **Duplicates are removed here, later.** When a dependency gains material LMLExplore already has,
  LMLExplore deletes its copy. A roadmap never asks for material that already exists at the pinned
  versions.
- **Nothing is upstreamed automatically.** Do not write items "to be upstreamed". LML's
  maintainers pick by hand what they want from LMLExplore.

### Prototyping

- **Write Lean.** Prototype structures, classes, definitions and main statements in
  `Suggested.lean`, importing individual modules from Mathlib, Tau Ceti, LML and LMLExplore. Open
  it with a note saying it suggests forms and is not exhaustive; the `README.md` stays definitive.
- **Use `sorry` honestly.** A condition you cannot yet state is left out, never encoded as a
  `Prop`-valued field or a `def _ : Prop := sorry`.

### Filing a roadmap

Give each roadmap a `metadata.toml` with one key, `topic`: the arXiv `math.*` class under which a
paper proving its main results would be listed. For machine learning theory this is usually
`math.ST` (statistics theory), `math.PR` (probability), `math.OC` (optimization and control) or
`math.IT` (information theory).

## Building

```bash
lake exe cache get
lake build
```
