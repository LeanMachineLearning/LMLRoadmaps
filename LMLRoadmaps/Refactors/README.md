# Roadmap: Refactors toward the generality of later layers

This roadmap restates material that LMLExplore already contains, in the generality and the place
that the later layers of the other roadmaps build on. Its targets are refactors of merged code:
each one replaces a development by a more general one, or moves it to the topic where its users
are, and keeps every result it replaces. New declarations appear only where the general statement
needs them.

The targets of Layer 0 come before the items they unblock, which each target lists. A worker
choosing between a Layer 0 target and an item it unblocks takes the Layer 0 target first.

## Scope and dependencies

In scope:

- online linear optimization: the FTRL development of `LMLExplore/OnlineLearning/FTRL.lean`;
- exponential families: `LMLExplore/Probability/Distributions/ExponentialFamily/`;
- Chernoff bounds: `LMLExplore/Probability/Moments/KLChernoff.lean` and
  `LMLExplore/Probability/Distributions/ExponentialFamily/Chernoff.lean`;
- the transfer from runs of a bandit algorithm to LML's reward stream:
  `LMLExplore/Bandits/SumRewards.lean`;
- Wald's identities, probability vectors on finite types, and the generic parts of
  `LMLExplore/Bandits/Concentration.lean`.

Relation to the other roadmaps. The [Bandits](../Bandits/README.md) and
[Identification](../Identification/README.md) roadmaps specify the mathematics these developments
contain, in the generality of the targets here (Bandits Layer 6 for online linear optimization,
Identification Layer 1.2 for exponential families); this roadmap restates the merged code in that
generality and moves it where its users are. It adds no target of those roadmaps.

## Conventions

- **A refactor keeps every result.** Each declaration it replaces is either derived from the new
  general statement (when it is the form users call) or deleted with every use migrated to the
  general statement. Deleted names leave no alias, wrapper or deprecated shim, as everywhere in
  LMLExplore.
- **One target, one pull request**, attributed `Roadmap: Refactors`, citing the target number.
  Moves and generalizations of the same development are one target; unrelated developments are
  never bundled. Target 0.3 comes after target 0.2.
- **Names.** A generalized declaration keeps the name of the declaration it generalizes when the
  name still describes it.
- **Losses are minimized** in online learning, as in the Bandits roadmap's Layer 6.

## Layers and dependencies

| Layer | Content | Prerequisites | Unblocks |
| --- | --- | --- | --- |
| 0 | Generalizations later layers build on | merged LMLExplore code | Bandits 3.2, 6.3, 6.4, 7, 10; Identification 1.2, 3.4, 4, 5, 7 |
| 1 | Consolidation | merged LMLExplore code | Identification 4, 7; Bandits 2.3, 7 |

## Layer 0: Generalizations that later layers build on

1. **FTRL on normed spaces, with losses in the dual.**
   - State online linear optimization on a set `K` of a real normed space `E`, with losses
     `y t : E →L[ℝ] ℝ`. The loss of a play `a t` is `y t (a t)`, and the regret against `u ∈ K`
     after `n` rounds is `∑ t < n, y t (a t - u)`.
   - Restate `IsFTRLPlay K F η y t x` with the objective `b ↦ η ∑ s < t, y s b + F b`, and the
     FTRL lemma `sum_inner_sub_le_ftrl` with the objectives `b ↦ ∑ s < t, y s b + ψ t b`.
   - Restate [LS, Theorem 28.5] (`ftrl_regret_le`) with the same hypotheses: `K` convex, `η > 0`,
     plays in `K`, and a derivative `F' t` of the potential within `K` at each play, with LML's
     `bregDiv`.
   - Restate the strongly convex case for Mathlib's `StrongConvexOn K m F`, which refers to the
     norm of `E`: the regret is at most
     $\frac{F(u)-F(a_0)}{\eta}+\frac{\eta}{2m}\sum_{t<n}\|y_t\|^2$ with $\|y_t\|$ the operator
     norm, the dual norm of the norm of `E`. This is [LS, Corollary 28.8] for every norm, by the
     choice of `E`; for example `PiLp 1 (fun _ : α ↦ ℝ)` carries the `ℓ¹` norm, whose dual norm is
     the sup norm.
   - Keep `exists_ftrl` (compact `K`, potential continuous on `K`) and
     `ftrl_regret_le_sqrt_of_closedBall` ([LS, Proposition 28.6]). The latter stays on a real
     inner product space, with the losses `InnerProductSpace.toDual ℝ E (g t)` of vectors
     `‖g t‖ ≤ 1`.
   - Why: the negative entropy on the probability simplex is `1`-strongly convex for the `ℓ¹`
     norm (Pinsker's inequality), which is how [LS, Proposition 28.7] gets
     $R_n\le\sqrt{2n\log d}$; for the Euclidean norm of an inner product space the corresponding
     bound grows with the dimension.
   - Unblocks: Bandits 6.4 ([LS, Proposition 28.7] on `PiLp 1`), Bandits 6.3 (mirror descent),
     Bandits 7 and 10.
2. **Exponential families with a sufficient statistic.**
   - Restate `LMLExplore/Probability/Distributions/ExponentialFamily/` for a measurable space
     `𝓧`, a measure `ρ` on `𝓧` and a measurable statistic `T : 𝓧 → ℝ`. The member of natural
     parameter `η` is `ρ.expFamily T η = ρ.tilted (fun x ↦ η * T x)`, the natural parameters range
     over `interior (integrableExpSet T ρ)`, the log-partition function is `ψ = cgf T ρ`, and the
     mean and the variance of `T` under the member of parameter `η` are `ψ'(η)` and `ψ''(η)`.
   - Rename accordingly: `natExpFamily ρ η` becomes `ρ.expFamily T η`, `natExpFamilyMeans ρ`
     becomes `ρ.expFamilyMeans T`, `natParam ρ μ` becomes `ρ.natParam T μ` and
     `natExpFamilyDiv ρ μ μ'` becomes `ρ.expFamilyDiv T μ μ'`, with every lemma about them. Each
     statement keeps its content with `T` in place of `id`; "`ρ` is not a Dirac mass" becomes
     "`T` is not `ρ`-almost everywhere constant", as in `ProbabilityTheory.strictMonoOn_deriv_cgf`,
     which is already stated for a general random variable. The natural exponential families of a
     measure on `ℝ` are the case `T = id`; no separate definitions for them remain.
   - The Chernoff bounds of `ExponentialFamily/Chernoff.lean` become bounds on the sums
     `∑ i ∈ s, T (Y i)` for independent observations `Y i` with law the member of mean `μ`;
     target 0.3 generalizes them further.
   - Why: identification tasks take observations in any measurable space (Identification
     Layer 1), and standard families have a statistic other than the identity or live on a space
     other than `ℝ`: Mathlib's `poissonMeasure` on `ℕ` with `T = Nat.cast`, Gaussian laws of known
     mean `m` with `T x = (x - m)²`. The exponential-family material of the later layers is built
     once, in this generality.
   - Unblocks: Identification 1.2 (the instances), 3.4, 4.2 and 5.
3. **Chernoff bounds under domination by an exponential family.**
   - For a measure `ρ` on `𝓧`, a statistic `T` and a mean `μ ∈ ρ.expFamilyMeans T`, say that a
     real random variable `X` is *dominated above* by the member of mean `μ` if, for every
     `t ≥ 0`, `exp (t X)` is integrable and `mgf X P t ≤ mgf T (ρ.expFamily T (ρ.natParam T μ)) t`;
     *dominated below* likewise for every `t ≤ 0`.
   - Prove, for independent `X i`, `i ∈ s`, dominated above by the member of mean `μ`, and a mean
     `x ≥ μ` of the family: `P(#s * x ≤ ∑ i ∈ s, X i) ≤ exp (-(#s * ρ.expFamilyDiv T x μ))`; and
     the lower tail for variables dominated below and `x ≤ μ`. The proof is the existing one
     (the Chernoff bound at the parameter `ρ.natParam T x - ρ.natParam T μ`), with the domination
     in place of the equality of the cumulant generating functions.
   - Derive the bounds of target 0.2 for `X i = T (Y i)`, with `Y i` of law the member of mean
     `μ`: such an `X i` is dominated above and below.
   - Prove that `Ber((1 : ℝ), 0, m)`, for `m ∈ (0, 1)`, is the member of mean `m` of the
     exponential family of `Ber((1 : ℝ), 0, 1/2)` with `T = id`, with
     `expFamilyDiv id p m = klBerReal p m` for `p, m ∈ (0, 1)` (the Bernoulli bullet of
     Identification 1.2; build it here if it is not merged). With
     `LMLExplore.mgf_le_one_sub_add_mul_exp`, a `[0, 1]`-valued variable of mean at most `m` is
     dominated above by `Ber((1 : ℝ), 0, m)`, and one of mean at least `m` is dominated below.
   - Derive `LMLExplore.measureReal_sum_ge_le_exp_klBerReal` and
     `LMLExplore.measureReal_sum_le_le_exp_klBerReal` from the general bounds for
     `p, m ∈ (0, 1)`, keeping their current statements; prove the boundary cases (`p = 1` for the
     upper tail, `p = 0` for the lower tail) directly. No second proof of the Chernoff argument
     remains.
   - Why: KL-UCB beyond Bernoulli rewards, the deviation inequalities for exponential families
     and the GLR stopping rules all assume reward distributions dominated by an exponential
     family member, not equal to one; and the two current files prove the same bound twice.
   - Unblocks: Bandits 3.2 ([LS, Lemmas 10.7 and 10.8] and Theorem 10.6), Identification 4.2.
4. **The transfer from runs to the reward stream, shared and joint over the arms.**
   - Move `LMLExplore/Bandits/SumRewards.lean` to `LMLExplore/SequentialLearning/SumRewards.lean`,
     in namespace `LMLExplore`, with unchanged statements: it holds for every algorithm against
     `stationaryEnv ν`, including the sampling rules of identification algorithms.
   - For finitely many arms and a measurable predicate `p` on `(α → ℕ) × (α → ℝ)`, prove the joint
     event transfer
     `P {ω | ∃ t, p (fun a ↦ pullCount A a t ω) (fun a ↦ sumRewards A R a t ω)} ≤
      streamMeasure ν {ω | ∃ s : α → ℕ, p s (fun a ↦ ∑ i ∈ range (s a), ω i a)}`,
     and its horizon form: the event at some round `t < n` is bounded by the event at some
     `s` with `∑ a, s a < n`. The proof is that of `measure_exists_pullCount_sumRewards_le` with
     `hasLaw_rewardByCount_streamMeasure`, which already gives the joint law of all arms.
   - Why: the GLR statistics and the deviation inequalities of identification are events about
     the counts and the sums of all arms at once.
   - Unblocks: Identification 4.1–4.3 and 7.

## Layer 1: Consolidation

1. **Wald's identities in one file.** Move `LMLExplore.sum_lintegral_pullCount_mul`,
   `LMLExplore.lintegral_toENNReal_eq_sum_lintegral_pullCount` and
   `LMLExplore.natCast_pullCount_toNat_le` from
   `LMLExplore/SequentialLearning/DivergenceDecomposition.lean` to
   `LMLExplore/SequentialLearning/Wald.lean`, beside Wald's identity for the rewards, and make the
   divergence decomposition import them. Update the module docstrings that point to the old
   location (`Identification/SampleComplexity.lean`).
2. **Probability vectors through `simplex`.** State `LMLExplore.Bandits.weightKernel`,
   `LMLExplore.Bandits.weightAlgorithm`, `isMarkovKernel_weightKernel` and
   `LMLExplore.isProbabilityMeasure_weightedMeasure` with the hypothesis `w x ∈ simplex α`
   (resp. `p ∈ simplex α`) in place of separate nonnegativity and sum hypotheses, and prove
   `(weightedMeasure p).real {i} = p i` for `p ∈ simplex α`.
3. **General concentration lemmas in `Probability/`.** Move the statements of
   `LMLExplore/Bandits/Concentration.lean` that mention no bandit: `sum_measureReal_mul_le_sum_add_sqrt_le`
   ([LS, Lemma 8.2] for independent σ²-sub-Gaussian variables) and
   `measureReal_sum_le_neg_mul_add_sqrt_le` to a file
   `LMLExplore/Probability/Moments/SubGaussianSum.lean`, and
   `sum_range_inv_mul_sum_range_exp_neg_le` ([LS, Exercise 8.1]) to
   `LMLExplore/Analysis/SpecialFunctions/Log/InvMulLogSq.lean`. The statements about the reward
   stream and about runs stay in `Bandits/`.

## Completion checks

- `ftrl_regret_le_sqrt_of_closedBall` holds for every real inner product space, through the
  normed-space theorems.
- No declaration named `natExpFamily…` remains; the natural exponential families are
  `ρ.expFamily id`.
- `LMLExplore.measureReal_sum_ge_le_exp_klBerReal` keeps its statement and its proof uses the
  exponential-family bound; `LMLExplore/Probability/Moments/KLChernoff.lean` contains no other
  Chernoff argument.
- No file under `LMLExplore/Bandits/` is imported by `LMLExplore/Identification/` for the reward
  stream transfer.

## References

- [LS] T. Lattimore and Cs. Szepesvári, *Bandit Algorithms*, Cambridge University Press, 2020:
  Lemma 8.2, Exercise 8.1, Lemmas 10.7–10.8, Theorems 10.6 and 28.5, Corollary 28.8,
  Propositions 28.6–28.7.
- [GK16] A. Garivier and E. Kaufmann, *Optimal best arm identification with fixed confidence*,
  COLT 2016, for exponential-family arms and their deviation bounds.
- [CGMMS13] O. Cappé, A. Garivier, O.-A. Maillard, R. Munos and G. Stoltz, *Kullback–Leibler upper
  confidence bounds for optimal sequential allocation*, Annals of Statistics 41 (2013), for
  KL-UCB beyond Bernoulli rewards.
