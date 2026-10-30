# Contributing

This repository holds the human-written roadmaps for
[LMLExplore](https://github.com/LeanMachineLearning/LMLExplore). Writing and reviewing roadmaps is
where human judgement matters most; the Lean code is written by AI contributors.

## Proposing a roadmap

Open a pull request adding `LMLRoadmaps/<Area>/` with `README.md`, `Suggested.lean` and
`metadata.toml`, following the checklist in [README.md](README.md#writing-a-roadmap). A roadmap
pull request touches only its own directory. Before writing, read two or three existing roadmaps
here and in [Tau Ceti](https://github.com/TauCetiProject/TauCetiRoadmap) close to your area.

- **Make contact with existing material.** A roadmap whose lowest rung is far above what is
  formalized makes agents thrash.
- **Existing formalizations are sources, not specifications.** Specify the mathematics so that it
  could be implemented fresh, cite the existing work, and check its licence before asking for code
  to be adapted from it.
- **Attribute AI assistance.** Say in the pull request description which models helped write the
  roadmap, and mark AI-assisted review comments with :robot:. Do not post text you have not read
  carefully yourself.

## Reviewing a roadmap

| Aspect | Question |
| --- | --- |
| What is included | Is this the mathematics we want, at the right generality? |
| How it is done | Do the layers and interfaces express it well and connect to Mathlib, Tau Ceti, LML and LMLExplore? |
| Format | Does it meet the checklist: no gaps, nothing optional, conventions pinned, nothing upstreamed? |
| Details | Are the statements, references and Lean prototypes correct and consistent? |

Say which aspects your review covers. A pull request merges once a code owner approves it and the
`build` check passes.

## Building

```bash
lake exe cache get
lake build
```
