# Roadmap: Refactors toward the generality of the literature

This roadmap restates material that LMLExplore already contains, in the generality that the
[Identification](../Identification/README.md), [Bandits](../Bandits/README.md) and
[ReinforcementLearning](../ReinforcementLearning/README.md) roadmaps specify. Those roadmaps ask
for the forms of the literature: tasks on arbitrary models, stopping-time tools for every
environment, thresholds that read the history, one algorithm where the literature has one,
adaptive adversaries and anytime learning rates, suprema that need not be attained, a discount in
every finite-horizon quantity. LMLExplore contains narrower versions of many of these items. Each
target here is a refactor of one merged development: it restates the development in the general
form and keeps every result it replaces.

Each target comes before the items it unblocks, which it lists. A worker choosing between a target
and an item it unblocks takes the target first; Layer 0 comes first because new work builds on it.
A target whose prerequisites include an item of another roadmap that is not merged makes that item
its next step.

## Scope and dependencies

In scope:

- identification: the tasks of `LMLExplore/Identification/Task/`, the GLR stopping rules and
  Track-and-Stop (`Identification/GLR.lean`, `TrackAndStop.lean`, `ForcedExploration.lean`), the
  elimination and LUCB algorithms;
- the sequential-learning tools of `LMLExplore/SequentialLearning/`: Wald's identity, the
  transfer from runs to the reward stream, the divergence of stopped histories;
- adversarial bandits and online learning: `LMLExplore/Bandits/AdversarialRegret.lean`,
  `ImportanceWeighted.lean`, `Exp3/`, `Exp4.lean`, `LaiRobbins.lean`, and
  `LMLExplore/OnlineLearning/`;
- design operators and self-normalized bounds: `LMLExplore/Analysis/InnerProductSpace/` and
  `LMLExplore/Probability/Martingale/SelfNormalized.lean`;
- dynamic programming and Markov decision processes: `LMLExplore/Analysis/FixedPoint/`,
  `LMLExplore/Probability/Kernel/Resolvent.lean` and `LMLExplore/MarkovDecisionProcess/`;
- declarations of LMLExplore that Tau Ceti provides at the pinned version (Layer 2). LMLExplore's
  scan for overlaps covers Mathlib only.

**Relation to the other roadmaps.** The Identification, Bandits and ReinforcementLearning roadmaps
specify the mathematics, and each target here points to the item that specifies its general form.
This roadmap restates merged code in that generality and adds no item of those roadmaps. Where a
target needs a general statement that is not merged, it lists that item as a prerequisite.

**Restatements that the other roadmaps own.** Some items of the other roadmaps specify a general
statement that LMLExplore does not have yet, and say which merged declarations become its
corollaries. The pull request that builds such an item derives those corollaries, so they are not
targets here:

- Identification 1.2: the exponential laws and the Gaussian laws of known mean
  (`ExponentialFamily/Exponential.lean`, `expFamilyDiv_sub_sq_gaussianReal`) as cases of the gamma
  laws, and `iIndepFun.measureReal_sum_ge_le_exp_expFamilyDiv` as a case of the Cramér–Chernoff
  bound with the rate function; Identification 1.3: `klDiv_gaussianReal_gaussianReal`;
- Identification 2.1: the equality case of the chain rule at a stopping time; Identification 3.3:
  `continuousOn_altCost_baiTask_restrict`; Identification 3.4: best arm identification with
  distinct per-arm families;
- Identification 4.1: observations in any measurable space, from the real case of target 0.4;
  Identification 4.2: `supermartingale_exp_sum_mul_of_hasCondSubgaussianMGF` and
  `unionBoundThreshold`; Identification 4.4: the almost-sure reduction; Identification 5.2: the
  `δ`-PAC and limit theorems of Track-and-Stop for exponential families;
- Bandits 3.1–3.4: `klucb` and `ucbF` as instances of KL-UCB for exponential families; Bandits
  5.1: `gaussianTS` as an instance of Thompson sampling for exponential families; Bandits 8.3:
  `ridgeEstimate` as the case `λ > 0` of least squares with the Moore–Penrose inverse;
- ReinforcementLearning 8.2 and 8.4: backward induction, and `EpisodicMDP.value_le_optValue` from
  it.

## Conventions

- **A refactor keeps every result.** Each declaration it replaces is either derived from the new
  general statement (when it is the form users call) or deleted with every use migrated to the
  general statement. Deleted names leave no alias, wrapper or deprecated shim, as everywhere in
  LMLExplore.
- **A target is met only when the narrow development is restated.** Adding a general version
  beside the declarations a target names does not meet it: they must be derived from the general
  version or deleted. A merged pull request that implements the narrow version of an item of
  another roadmap does not cover the target here that restates it.
- **One target, one pull request**, attributed `Roadmap: Generalization` and citing the target
  number, for example "Generalization 0.6". A target listed as "After" another one comes after it,
  because it needs its statements or edits the same files.
- **Prerequisites in other roadmaps.** An item of another roadmap listed as a prerequisite is built
  first, in its own pull request attributed to that roadmap. The refactor then adds no mathematics
  beyond what its general statement needs.
- **The general forms are those of the other roadmaps,** with their conventions: `ℝ≥0∞`-valued
  thresholds and costs in identification, rewards maximized in bandits with finitely many arms and
  losses minimized in online learning, learning rates as nonincreasing sequences, operator
  statements on `boundedMeasurable 𝓢`.
- **Sample complexity bounds take their constant directly.** A bound
  $\mathbb E[\tau_\delta]\le c\log(1/\delta)$ for all small enough $\delta$ has one hypothesis
  $D^{-1}<c$ on its constant, for the rate $D$ that the algorithm reaches:
  `(task.altCost μ (w μ) i)⁻¹ < c` for D-tracking of the targets `w`,
  `(⨅ v ∈ C, task.altCost μ v i)⁻¹ < c` for C-tracking of targets that converge to `C`, and
  `task.charTime μ < c` at the optimal allocations. A theorem about one algorithm on one task may
  state $\limsup_{\delta\to0}\mathbb E[\tau_\delta]/\log(1/\delta)\le D^{-1}$ instead. A rate
  $\kappa<D$ is a step of the proof, not a hypothesis: only the generic reductions of
  `Identification/GLR.lean`, whose hypothesis is that the statistic grows at least like
  $\kappa T$, have one.
- **Names.** A generalized declaration keeps the name of the declaration it generalizes when the
  name still describes it. LML's names are those of LMLExplore's pin (`Environment.bandit`,
  `Environment.evalSeq`).

## Layers and dependencies

| Layer | Content | Prerequisites | Unblocks |
| --- | --- | --- | --- |
| 0 | Generalizations that new work builds on | merged LMLExplore code | Identification 1.1, 1.4, 2.1, 4.1–4.5, 5, 6, 7, 9.1; Bandits 6.3–6.6, 7, 8.2–8.5, 9, 10; ReinforcementLearning 6, 8–12, 23 |
| 1 | Consolidation of finished developments | Layer 0 targets as listed; Identification 0.5, 1.1, 3.6; ReinforcementLearning 0.6, 8.1 | Identification 3.6, 4.4, 5.2–5.3, 7, 8.1–8.2; Bandits 4.5, 6.4, 7.2–7.4, 8.4; ReinforcementLearning 1.4–1.5, 9.4, 10, 12.2 |
| 2 | Material Tau Ceti provides | merged LMLExplore code | none |

## Layer 0: Generalizations that new work builds on

### Identification and sequential learning

1. **Best arm identification and ε-best arm identification with a mean functional.**
   - In `Identification/Task/MeanVector.lean`, restate `baiTask ν` and `epsBaiTask ν ε` for a type
     `Θ` of models, bandits `ν : Θ → Kernel α 𝓨` and a mean functional `mean : Θ → α → ℝ`, as
     `baiTask ν mean` and `epsBaiTask ν mean ε` (Identification 1.1). The tasks on vectors of
     means are the case `Θ = α → ℝ`, `mean = id`. Restate every lemma about them with `mean θ` in
     place of the vector of means.
   - Migrate every use: `Task/BestArm.lean`, `Task/TopTwo/BestArm.lean`, `Task/EpsBestArm.lean`,
     `EpsBestArmLowerBound.lean`, `SuccessiveElimination.lean` and `MedianElimination.lean`.
   - If `IdentTask.comap` (Identification 1.1) is merged, prove
     `baiTask (fun θ ↦ ν' (mean θ)) mean = (baiTask ν' id).comap mean` and its analogue for
     `epsBaiTask`; otherwise the pull request that adds `comap` proves them.
   - Why: best arm identification with unknown variances is
     `baiTask gaussianMeanVarBandit (fun θ a ↦ (θ a).1)`, the task whose costs
     `Task/GaussianUnknownVariance.lean` computes; linear models and the bandits with real
     observations are models of the same kind.
   - Unblocks: Identification 1.1 (the model of all bandits with real observations), 4.5, 5.2 (the
     two-parameter Gaussian model), 7, 9.1; targets 0.2, 1.1.
2. **The other classical tasks with a mean functional.** After 0.1.
   - Restate in the same way `topMTask`, `epsTopMTask`, `thresholdingTask`, `minThresholdTask`,
     `anyLowArmTask` and `halfSpaceTask` (`Task/MeanVector.lean`) and `sphereTask`
     (`Task/Sphere.lean`), with every lemma about them, and the identities with `comap` under the
     same condition as in target 0.1.
   - Migrate every use: `Task/TopM.lean`, `TopMLowerBound.lean`, `LUCB.lean`, `KLLUCB.lean`,
     `Task/Threshold.lean`, `Task/AnyLowArm.lean`, `Task/HalfSpace.lean` and `Task/Sphere.lean`.
   - Rename `Task/MeanVector.lean` to `Task/Classical.lean`, and update its importers.
   - Unblocks: Identification 3.6, 7.3, 9.1; targets 1.1, 1.6–1.9.
3. **Wald's identity for every environment.**
   - In `SequentialLearning/Wald.lean`, prove Wald's identity for the feedback of
     Identification 0.3: for a run of any algorithm in any environment with real feedback, a
     stopping time of `IsAlgEnvSeq.filtrationAction` with finite expectation, and conditional
     absolute means of the feedback bounded by a constant,
     $\mathbb E[\sum_{t<\tau}Y_t]=\mathbb E[\sum_{t<\tau}m_t(A_t)]$ with LML's conditional means
     `Environment.means`. The current proof replaces $Y_t$ by its conditional mean on
     $\{t<\tau\}$ through LML's `IsAlgEnvSeq.condExp_feedback`, which holds for every environment;
     only its integrability bounds are specific to bandits, and the bound on the conditional
     absolute means replaces them.
   - Derive `IsAlgEnvSeq.integral_sum_feedback_eq_sum_integral_pullCount_mul` (stationary bandits
     with integrable arms) from it with LML's `means_bandit`, and restate its helpers
     `IsAlgEnvSeq.setLIntegral_comp_feedback_bandit`, `setIntegral_feedback_bandit` and
     `integrable_feedback_bandit` for every environment.
     `IdentAlg.integral_sum_feedback_eq_sum_integral_pullCount_mul`
     (`Identification/SampleComplexity.lean`) keeps its statement.
   - Unblocks: ReinforcementLearning 6.2 (Wald's identity by keys), 14.6.
4. **The event transfer for every event about the observations of each arm.**
   - In `SequentialLearning/SumRewards.lean`, define the observations of arm `a` before round `t`,
     `armObs A Y a t ω : Fin (pullCount A a t ω) → ℝ` in the order of the pulls, related to LML's
     `rewardByCount`. Prove the event transfer of Identification 4.1 for real observations: for
     every predicate on the pull counts `s : α → ℕ` and the observations
     `(a : α) → Fin (s a) → ℝ`, its joint form, its form up to a horizon, its single-arm form and
     its counting forms, for predicates that need not be measurable (outer measures). The proof is
     the current one: the pathwise inclusion on the product of the run's law with
     `streamMeasure ν`, and `Measure.le_map_apply`.
   - Derive with their current statements the transfers for the sums of rewards:
     `measure_exists_pullCount_sumRewards_pi_le`, `measure_exists_lt_pullCount_sumRewards_pi_le`,
     `measure_exists_pullCount_sumRewards_le`, `measure_exists_lt_pullCount_sumRewards_le`,
     `sum_setLIntegral_action_eq_pullCount_sumRewards_le`,
     `sum_measure_action_eq_and_pullCount_sumRewards_le`,
     `sum_measureReal_action_eq_and_pullCount_sumRewards_le` and
     `measureReal_pullCount_sumRewards_le_sum`. Their users do not change.
   - Observations in any measurable space `𝓨` are Identification 4.1, which then generalizes the
     statements of this target: LML's `hasLaw_rewardByCount_infinitePi`, on which the transfer
     rests, is stated for real rewards.
   - Unblocks: Identification 4.1, 4.5 (events about the sums of $Y$ and $Y^2$); Bandits 1.3;
     ReinforcementLearning 6.1.
5. **The chain rule at a stopping time for any two algorithm–environment pairs.**
   - In `SequentialLearning/DivergenceDecomposition.lean`, prove the inequality of
     Identification 2.1 for any two pairs `(alg, env)` and `(alg', env')`, by the current proof:
     both pairs are changed after the stopping time (`stoppedHistMeasure_congr`). This needs the
     algorithm that follows one algorithm before the stopping rule and another after it: define
     `Algorithm.piecewise` beside LMLExplore's `Environment.piecewise`
     (`SequentialLearning/Algorithm.lean`), with its step-kernel lemma. The per-round divergences
     with a restricted first marginal need no countably generated observation space (LML's
     `klDiv_restrict_add_restrict_compl`); the integral form needs it (LML's
     `klDiv_compProd_right_eq_lintegral`).
   - Derive `klDiv_stoppedHistMeasure_le` (one algorithm against `Environment.bandit κ` and
     `Environment.bandit κ'`) as its corollary, and delete the private `swapEnv`,
     `klDiv_compProd_stepKernel_swapEnv` and `klDiv_trajMeasure_swapEnv`.
     `Identification.klDiv_histOutputMeasure_le` (`Identification/ChangeOfMeasure.lean`) and its
     users keep their statements.
   - Unblocks: Identification 2.1 (the equality case); ReinforcementLearning 6.2, 14.6, 19.
6. **GLR stopping rules with thresholds that read the history.**
   - In `Identification/GLR.lean`, the thresholds become `β : (n : ℕ) → Hist Unit α 𝓨 n → ℝ≥0∞`,
     depending on the round and on the history, indexed by the confidence level in the asymptotic
     section (Identification Conventions and 4.3). Restate `IdentTask.glrt` and its lemmas
     (`glrt_def`, `alg_glrt`, `mem_stopSet_glrt`, `output_glrt`, `stoppingTime_glrt_le`,
     `measureReal_histOutputMeasure_glrt_le`,
     `measureReal_stoppingTime_ne_top_and_notMem_le_of_isRun_glrt`), `isDeltaPAC_glrt`, whose
     deviation event becomes $\exists n,\ \beta_n(H_n)<Z_n(H_n,\theta)$,
     `expectedStoppingTime_glrt_le_add_tsum`, `eventually_expectedStoppingTime_glrt_le`,
     `eventually_expectedStoppingTime_glrt_le_of_isBigO` and
     `stopsAS_glrt_unionBoundThreshold`. Thresholds depending on the round only are the case
     `fun n _ ↦ β n`; `unionBoundThreshold` enters in this form.
   - Migrate `Identification/TrackAndStop.lean` and `Identification/GaussianThreshold.lean`.
   - Unblocks: Identification 4.2 (the thresholds of [KK21]), 4.3 (covers of the alternatives),
     4.5, 5.2–5.3, 6; target 0.7.
7. **Plug-in GLR statistics, and Track-and-Stop for any task and estimator.** After 0.6.
   - In `Identification/TrackAndStop.lean`, replace `IdentTask.empCost` (the cost from the
     empirical means with the pull counts as weights, for `Θ = α → ℝ` and `𝓨 = ℝ`) by the plug-in
     statistic of Identification 4.3 for any `Θ`, `𝓨` and estimator
     `est : (n : ℕ) → Hist Unit α 𝓨 n → Θ`, the cost from `est n h` with the pull counts of `h`
     as weights. Restate `glr_empCost` and `glr_empCost_eq_mul`
     ($\mathrm{GLR}_n(h,\neg i)=n\,D(\hat\theta_n(h),N(h)/n,\neg i)$) for it;
     `empCost_gaussianBandit` becomes a statement about the empirical means. Delete `empCost`,
     migrating its uses in `TrackAndStop.lean` and `GaussianThreshold.lean`.
   - Define `trackAndStop` and `cTrackAndStop` for any task and estimator (Identification 5.2,
     first bullet); their theorems are stated for the empirical means.
   - Unblocks: Identification 4.4, 4.5, 5.2–5.3, 6; target 1.10.
8. **Forced exploration in event form.**
   - In `Identification/ForcedExploration.lean`, restate `measure_exists_ge_empMean_notMem_Ioo_le`
     and `tsum_measure_exists_ge_empMean_notMem_Ioo_ne_top` in the form of Identification 5.1:
     in place of the almost-sure hypothesis that every arm has `m` pulls at a round `t₀`, bound
     the probability of an event on which every arm has at least `g t` pulls at every round
     `t ∈ [h T, T]`, intersected with a deviation of an empirical mean in that window. The proof is
     the same inclusion, with the single-arm bound
     `measure_exists_le_pullCount_and_empMean_notMem_Ioo_le`
     (`SequentialLearning/ExpFamilyDeviation.lean`), which is already in event form.
   - The D- and C-tracking statements `DTracking.tsum_measure_exists_ge_empMean_notMem_Ioo_ne_top`
     and `CTracking.tsum_measure_exists_ge_empMean_notMem_Ioo_ne_top` are the case of the sure
     event.
   - Unblocks: Identification 6.3–6.4 (Top Two rules explore only with high probability).

### Bandits and online learning

9. **Pseudo-regret and random regret against any environment.**
   - In `Bandits/AdversarialRegret.lean`, define the pseudo-regret and the random regret of runs
     against any environment with integrable feedback, and their expert versions (Bandits 0.5),
     and prove that the pseudo-regret is at most the expected random regret.
   - Prove that `advRegret` is the pseudo-regret against `Environment.evalSeq`, that
     `expertRegret` is the expert pseudo-regret against LMLExplore's `Environment.ofSeq`, and that
     against `Environment.bandit ν` the pseudo-regret is LML's expected `regret`.
     `IsAlgEnvSeq.advRegret_eq_sub_integral_sum_feedback` keeps its statement.
   - Construct the environment of a deterministic adaptive adversary and the environment with
     history-dependent advice of Bandits 0.5; `Environment.evalSeq` and `Environment.ofSeq` are
     their cases with tables and advice fixed in advance. The comparison with i.i.d. reward tables
     is Bandits 0.5's.
   - Unblocks: Bandits 7.3–7.4, 10; targets 1.15–1.16.
10. **Importance-weighted estimators against any environment.**
    - In `Bandits/ImportanceWeighted.lean`, restate the statements about runs
      (`condExp_iwEstimator`, `condExp_lossIwEstimator`, `condVar_iwEstimator`,
      `condVar_lossIwEstimator` and `sum_integral_one_sub_sq_div_weights_le`), which assume that
      the feedback is a reward table fixed in advance evaluated at the action, for runs against any
      environment, with LML's conditional means `env.means` given `IsAlgEnvSeq.filtrationObs`
      (LML's `IsAlgEnvSeq.condExp_feedback_comp`). The current statements are the case of
      `Environment.evalSeq`.
    - Unblocks: Bandits 7.1, 7.3–7.4, 10.2; targets 1.15–1.16.
11. **Follow the regularized leader with time-varying regularizers.**
    - In `OnlineLearning/FTRL.lean`, prove the bound of Bandits 6.3 for regularizers $\psi_t$
      nondecreasing in $t$, with the stability terms
      $y_t(a_t-a_{t+1})-D_{\psi_t}(a_{t+1},a_t)$ [Ora, Lemma 7.1], from the merged
      `sum_apply_sub_le_ftrl`, whose stability terms are increments of the objectives. Prove its
      case $\psi_t=F/\eta_t$ with nonincreasing $\eta_t>0$ and $F\ge0$, and the strongly convex
      anytime bound [Ora, Corollary 7.6].
    - Derive `ftrl_regret_le` and `ftrl_regret_le_of_strongConvexOn` as their constant cases, with
      their current statements.
    - Unblocks: Bandits 6.3 (local norms), 6.4, 10.2; target 1.17.
12. **Design operators with a regularizer.**
    - In `Analysis/InnerProductSpace/DesignOperator.lean`, define
      `designOp (V₀ : E →L[ℝ] E) x t` $=V_0+\sum_{s<t}x_s\otimes x_s$ (Bandits 8.1); the current
      operator with parameter `lam` is `designOp (lam • 1) x t`. Restate its lemmas for `V₀`:
      positivity for a positive `V₀` (`isPositive_designOp`), invertibility for a positive definite
      `V₀` (`isUnit_designOp`), the rank-one update of the inverse (`ringInverse_designOp_succ`),
      the determinant lemmas, `trace_designOp`, `det_designOp_le` and
      `log_det_designOp_div_pow_le`. The lemmas of `EllipticalPotential.lean` about abstract
      operators (`sum_min_one_inner_inverse_le_log_det`) become lemmas about `designOp V₀`.
    - Migrate every use: `Ridge.lean`, `EllipticalPotential.lean`,
      `Probability/Martingale/SelfNormalized.lean`,
      `Probability/Martingale/ConfidenceEllipsoid.lean`, `Bandits/OFUL.lean` and
      `Bandits/LinearBandit.lean`. `ridgeEstimate` keeps its definition through `Ring.inverse`;
      every theorem about it assumes `0 < lam`.
    - Unblocks: Bandits 8.2, 8.4–8.5, 9; ReinforcementLearning 23; target 1.18.

### Dynamic programming and Markov decision processes

13. **Abstract dynamic programming without attainment.**
    - In `Analysis/FixedPoint/DynamicProgramming.lean`, replace the hypothesis
      `∀ x, IsGreatest (Set.range fun d ↦ T d x) (B x)` by the two hypotheses of
      ReinforcementLearning 0.3: `T d x ≤ B x` for every decision `d`, and for every `x` and
      `ε > 0` a decision `d` with `B x - ε • e ≤ T d x`.
    - Prove: `B` satisfies Blackwell's conditions (restating `IsBlackwell.of_isGreatest_range`);
      the fixed point of every `T d` is below the fixed point $x^*$ of `B`; a decision `ε`-greedy
      for $x^*$ has its fixed point above $x^*-\frac{\varepsilon}{1-\gamma}e$; $x^*$ is the least
      upper bound (`IsLUB`) of the fixed points of the `T d`, restating
      `isGreatest_iUnion_fixedPoints`, which becomes the case where a decision is greedy for
      $x^*$; with finitely many decisions, every `x` has a greedy decision.
    - Unblocks: ReinforcementLearning 9.3–9.4, 10; targets 0.14, 1.23.
14. **Policy iteration and modified policy iteration with the greedy decisions they use.** After
    0.13.
    - Restate under the hypotheses of target 0.13 the lemmas of
      `Analysis/FixedPoint/DynamicProgramming.lean` that assume attainment: `le_map_of_isFixedPt`,
      `IsPolicyIteration.le_map`, `map_le`, `monotone`, `iterate_le`, `le_of_isFixedPt`,
      `norm_sub_le` and `exists_le_card_eq`, and `IsModifiedPolicyIteration.le_map`, `map_le`,
      `iterate_le`, `le_of_isFixedPt` and `norm_sub_le`. The structures `IsPolicyIteration` and
      `IsModifiedPolicyIteration` already record the greedy decisions their runs use; no other
      greedy decision is assumed.
    - Migrate `MarkovDecisionProcess/PolicyIteration.lean` (`exists_le_card_value_eq_optValue`) and
      `MarkovDecisionProcess/ModifiedPolicyIteration.lean`. The lemmas that provide the attainment
      hypothesis, `MDP.isGreatest_bellmanEval` (`Bellman.lean`) and `MDP.isGreatest_bellmanEvalOp`
      (`ValueIteration/Basic.lean`), become lemmas that provide the two hypotheses of target 0.13:
      the evaluation operators of deterministic policies are below the Bellman operator, and greedy
      policies attain it. `Monotone.of_isGreatest_range` (`Order/Bounds/Basic.lean`) then has no
      user and is deleted.
    - Unblocks: ReinforcementLearning 10.2–10.3; targets 0.15, 1.22.
15. **Bellman operators for every action set.** After 0.14.
    - Restate for every action set the statements that use only that `M.bellman γ v` is a
      supremum: `lookahead_le_bellman`, `bellman_le_iff`, `bellman_sub_add_le_bellman_sub`,
      `const_le_bellman_const` and `bellmanEval_le_bellman` (`MarkovDecisionProcess/Bellman.lean`;
      ReinforcementLearning 8.1), `value_le_bellman` (`Value.lean`), `optValue_le_of_bellman_le`
      (`Comparison.lean`) and `optValue_le_bellman_iterate_add` (`ValueIteration/Bounds.lean`).
      They assume `[Finite 𝓐]` and hold for every `v`; their general forms assume that the
      lookahead is bounded above and integrable, which finitely many actions give.
    - Replace `MDP.IsGreedy` by the predicate `M.IsApproxGreedy γ ε v d` of
      ReinforcementLearning 8.1; greediness is the case `ε = 0`. Migrate its users in
      `Bellman.lean` (`isGreedy_greedy`, `isGreedy_iff_bellmanEval_eq`), `PolicyIteration.lean`
      (`KeepsGreedy`, `exists_isPolicyIteration`) and `ModifiedPolicyIteration.lean`.
    - Unblocks: ReinforcementLearning 8.1–8.3, 9.3–9.4; targets 1.21, 1.23.
16. **Discounted returns and one definition of the state marginals.**
    - In `MarkovDecisionProcess/RunValue.lean`, give `MDP.runReturn` the discount as an argument,
      `M.runReturn γ N u alg μ` (ReinforcementLearning 7.4), and restate its lemmas
      (`runReturn_def`, `abs_runReturn_le` with the bound
      $(\sum_{n<N}\gamma^n)C+\gamma^NB$, `runReturn_eq_sum`, `runReturn_eq_integral`,
      `runReturn_eq_integral_feedback`, `runReturn_markov`). The current return is the case
      `γ = 1`; `runReturn_augmented_markov` and its `dirac` form (`Episodic/Value.lean`) become
      statements about `M.augmented.runReturn 1 (H - h) 0` (ReinforcementLearning 7.6).
    - Define the state marginals once, `MDP.stateMarginal P π μ` for a sequence of transition
      kernels `P : ℕ → Kernel (𝓢 × 𝓐) 𝓢` (ReinforcementLearning 7.3). `MDP.stateMarginal M π μ`
      (`MarkovPolicy.lean`) is the case `fun _ ↦ M.P` and `EpisodicMDP.stateMarginal M π μ`
      (`Episodic/Occupancy.lean`) the case `M.trans`; delete both, migrating their uses in
      `MarkovPolicy.lean`, `Episodic/Occupancy.lean`, `RunValue.lean`,
      `Episodic/PerformanceDifference.lean`, `Occupancy.lean`, `Episodic/Pessimism.lean`,
      `Episodic/Value.lean` and `Comparison.lean`.
    - Unblocks: ReinforcementLearning 7.3–7.6, 8.2–8.4, 11.4, 12.

## Layer 1: Consolidation of finished developments

### Identification

1. **The guarantees of the elimination and LUCB algorithms on classes of bandits.** After 0.1,
   0.2. Prerequisites: Identification 1.1 (`IdentTask.comap` with its `δ`-correctness and
   `δ`-PAC lemmas; the model of all bandits with real observations and its σ²-sub-Gaussian and
   `[0, 1]` classes).
   - State `isDeltaPAC_lucbOfRate` (`LUCB.lean`), `isDeltaPAC_kllucb` (`KLLUCB.lean`),
     `isDeltaCorrect_successiveEliminationOfRate` (`SuccessiveElimination.lean`) and
     `isDeltaPAC_medianElimination` (`MedianElimination.lean`) on the restricted tasks of the
     model of all bandits with real observations (Identification 1.1, Layer 7), so that they hold
     for every bandit of the class. Each of them is stated for one family
     `ν : (α → ℝ) → Kernel α ℝ` of bandits indexed by their means (`(ν μ a)[id] = μ a`), which does
     not contain every bandit of the class; these family statements are the pullbacks along
     `μ ↦ ν μ` of the new ones, and are deleted.
   - The results about runs of LUCB and KL-LUCB (`measureReal_histOutputMeasure_lucb_le` and the
     others) lose the auxiliary family `ν`, which enters only through
     `(epsTopMTask ν m ε).correct`.
   - Unblocks: Identification 7, 8.1–8.2; targets 1.2–1.4.
2. **Successive rejects through the phased-elimination constructor.** After 1.1. Prerequisite:
   Identification 0.5.
   - Construct `successiveRejects` (`SuccessiveRejects.lean`) with the constructor of
     Identification 0.5, and prove `SuccessiveRejects.measureReal_output_ne_le_sum`,
     `SuccessiveRejects.measureReal_output_ne_le` and
     `SuccessiveRejects.measureReal_output_ne_le_of_mem_Icc` through its run lemmas and its
     survival bound. Delete the phase structure that the file builds for itself (`phaseEnd`,
     `phaseOf`, `survivors`, `armAt`, `nextArm` and their lemmas) where the constructor provides
     it.
   - Unblocks: Identification 8.1–8.2; target 1.3.
3. **Median elimination through the phased-elimination constructor.** After 1.2. Prerequisite:
   Identification 0.5.
   - Construct `medianElimination` (`MedianElimination.lean`, which builds its own `phaseEnd`,
     `phaseOf`, `numPhases`, `survivors`, `armAt` and `nextArm`) with the constructor of
     Identification 0.5, and prove `isDeltaPAC_medianElimination` and its sample budget through
     its run lemmas.
   - Unblocks: Identification 7.2.
4. **Successive elimination as a phased-elimination algorithm.** After 1.1. Prerequisite:
   Identification 0.5.
   - Define successive elimination as in Identification 7.1, a phased-elimination algorithm whose
     phases pull every active arm once, replacing the index policy of
     `SuccessiveElimination.lean`, which checks the eliminations at every round. Prove
     `isDeltaCorrect_successiveEliminationOfRate` and the bound on its number of samples for it.
   - Unblocks: Identification 7.1.
5. **Transportation costs under per-arm divergence hypotheses.**
   - In `Identification/Task/ExpFamily.lean`, state the alternative-cost lemmas
     (`cost_eq_sum_ofReal_mul_expFamilyDiv`, `cost_update_eq_ofReal_mul_expFamilyDiv`,
     `altCost_le_ofReal_mul_expFamilyDiv_of_eventually`,
     `altCost_le_sum_ofReal_mul_expFamilyDiv_of_tendsto`,
     `altCost_le_sum_ofReal_mul_expFamilyDiv_of_eventually`,
     `altCost_restrict_le_ofReal_mul_expFamilyDiv_of_tendsto` and
     `ofReal_mul_expFamilyDiv_le_cost`) for real per-arm divergences `d a` on open sets `S a` of
     `ℝ` with `klDiv (ν μ a) (ν μ' a) = ENNReal.ofReal (d a (μ a) (μ' a))` on the models with
     means in `S`, each `d a` continuous on `S a ×ˢ S a`, zero exactly on the diagonal and monotone
     in each argument on each side of the other (Identification 1.4).
   - Prove that per-arm exponential families satisfy these hypotheses with
     `d a = (ρ a).expFamilyDiv (T a)` and `S a = (ρ a).expFamilyMeans (T a)`, and derive the
     current statements, or migrate their uses (`Task/BestArm.lean`, `TopMLowerBound.lean`,
     `EpsBestArmLowerBound.lean`).
   - Unblocks: Identification 1.4, 4.5; targets 1.6–1.7.
6. **Thresholding, minimum threshold and Any Low Arm under per-arm divergence hypotheses.** After
   0.2, 1.5.
   - Restate under the hypotheses of target 1.5 the statements of `Task/Threshold.lean` about
     restricted tasks (the costs, values, optimal allocations and characteristic times of
     thresholding and of both answers of the minimum-threshold task) and of `Task/AnyLowArm.lean`
     (with the oracle answers, the oracle allocations and their non-convexity).
   - Unblocks: Identification 1.4, 3.6; target 1.8.
7. **Top-m and ε-best arm identification under per-arm divergence hypotheses.** After 0.2, 1.5.
   - Restate `altCost_topMTask_restrict_le_ofReal_mul_expFamilyDiv_of_mem` and its `_of_notMem`
     form (`Task/TopM.lean`), and `altCost_epsBaiTask_restrict_le_ofReal_mul_expFamilyDiv_add` and
     its `_sub` form (`Task/EpsBestArm.lean`), under the hypotheses of target 1.5, migrating
     `TopMLowerBound.lean` and `EpsBestArmLowerBound.lean`.
   - Unblocks: Identification 1.4, 7.4.
8. **Gaussian thresholding, minimum threshold and Any Low Arm with arm-dependent variances.**
   After 1.6.
   - Restate `IdentTask.cost_gaussianBandit` (`Task/ExpFamily.lean`),
     `altCost_thresholdingTask_gaussianBandit`, `charTime_thresholdingTask_gaussianBandit`,
     `charTime_minThresholdTask_gaussianBandit_false` and
     `charTime_minThresholdTask_gaussianBandit_true` (`Task/Threshold.lean`) and
     `oracleAlloc_anyLowArmTask_gaussianBandit` (`Task/AnyLowArm.lean`) for Gaussian arms with
     arm-dependent known variances $\sigma_a^2$ (Identification 3.6), the bandit
     `gaussianMeanVarBandit (fun a ↦ (μ a, σ2 a))`. The statements with a common variance are the
     case of a constant `σ2`, through `gaussianBandit_eq_gaussianMeanVarBandit`. The non-convexity
     example `not_convex_oracleAlloc_anyLowArmTask_gaussianBandit` keeps a common variance.
   - Unblocks: Identification 3.6.
9. **Gaussian half-spaces and best arm identification with arm-dependent variances.** After 0.2.
   Prerequisite: Identification 3.6 (the cost $\tfrac12\|\theta-\lambda\|^2_{V_w}$ and its infimum
   over an affine half-space).
   - Restate `Task/HalfSpace.lean` (`altCost_halfSpaceTask_gaussianBandit`, its `_eq_zero` form,
     `answerValue_halfSpaceTask_gaussianBandit`, `optAlloc_halfSpaceTask_gaussianBandit` with the
     allocation proportional to $\sigma_a|u_a|$, and `charTime_halfSpaceTask_gaussianBandit`) and
     `altCost_baiTask_gaussianBandit` (`Task/BestArm.lean`, with
     $D(\mu,w,\neg a)=\min_{b\ne a}(\mu_a-\mu_b)^2/(2(\sigma_a^2/w_a+\sigma_b^2/w_b))$) for
     arm-dependent known variances, from the half-space formula of Identification 3.6. The
     two-armed results and the bounds $H\le T^*\le2H$ of `Task/BestArm.lean` keep a common
     variance, as in Identification 3.4.
   - Unblocks: Identification 3.6, 9.2.
10. **One sample-complexity reduction, and Track-and-Stop with D-tracking.** After 0.7.
    - Prove the asymptotic reduction of Identification 4.4 for any topological space of models,
      estimator and thresholds with $\beta_t(h,\delta)\le\log(1/\delta)+f(t)$, $f(t)=o(t)$, from
      the merged `IdentTask.eventually_expectedStoppingTime_glrt_le` (the step after the lower
      semicontinuity) and
      `IsCompact.exists_forall_mem_thickening_lt_of_lowerSemicontinuousWithinAt`
      (`Topology/Semicontinuity/Compact.lean`).
    - Derive from it `eventually_expectedStoppingTime_trackAndStop_le` and
      `eventually_expectedStoppingTime_trackAndStop_le_of_charTime_lt`, with their constants as
      in the Conventions, and delete the private `mul_le_glr_plugInCost`.
    - Unblocks: Identification 4.4, 5.2–5.3, 6; target 1.11.
11. **Track-and-Stop with C-tracking from the reduction.** After 1.10.
    - Derive `eventually_expectedStoppingTime_cTrackAndStop_le` and
      `eventually_expectedStoppingTime_cTrackAndStop_le_of_charTime_lt` from the reduction of
      target 1.10, with their constants as in the Conventions, and delete the private
      `mul_le_glr_plugInCost_of_mem_thickening` and the argument
      over the rounds that the two proofs of `TrackAndStop.lean` share.
    - Unblocks: Identification 5.2.

### Bandits and online learning

12. **Exp4-IX as the single algorithm.**
    - Define Exp4-IX (Bandits 7.2) with an advice map `adv : 𝓞 → β → simplex α`, learning rates
      `η : ℕ → ℝ` and implicit-exploration parameters `γ : ℕ → ℝ`, and its estimated expert
      losses. Define `exp4` as the case `γ = 0` with the advice as observation, `exp3IX` and
      `exp3` as the cases with the experts `α`, expert `b` advising the arm `b`, with any `γ` and
      with `γ = 0`; their current constant rates are constant sequences.
    - Delete `exp3Sum`, `exp3Weights`, `exp3IXSum`, `exp3IXWeights`, `exp4Sum`,
      `exp4ExpertWeights` and `exp4Weights`, and the bridges between them (`exp3IX_eq_exp3`,
      `exp3IXSum_eq_sub_exp3Sum`, `exp3IXWeights_eq_exp3Weights`,
      `exp4ExpertWeights_eq_exp3Weights`, `exp4Weights_eq_exp3Weights`), restating every statement
      that mentions them with the weights of Exp4-IX.
    - Prove that the expert weights are the exponential weights (`softmax`) of the estimated
      expert losses, and the pathwise bound of Exp4-IX for constant rates from
      `softmax_regret_le`; derive from it `Exp3.sum_lossIwEstimator_sub_le`,
      `Exp3IX.sum_sub_exp3IXSum_le` and `Exp4.sum_sub_sum_le`, or migrate their uses.
    - Unblocks: Bandits 7.2; targets 1.14–1.16.
13. **Anytime exponential weights.**
    - Prove the local-norm bound of exponential weights with nonincreasing learning rates of
      Bandits 6.4, for nonnegative losses,
      $$\sum_{t<n}(\langle p_t,y_t\rangle-y_t(a))\le\frac{\log k}{\eta_{n-1}}
      +\sum_{t<n}\frac{\eta_t}2\langle p_t,y_t^2\rangle,$$
      and derive `softmax_regret_le` (`OnlineLearning/ExponentialWeights.lean`) as its constant
      case.
    - `OnlineLearning/AdaHedge.lean` proves the same telescoping of the exponential-weights
      potential a second time (`mixLoss`, `hedgePotential`, `mixLoss_softmax`,
      `hedgePotential_le_of_le` and the private `sum_adaHedgeMixLoss_le`, already for decreasing
      rates). State these potential lemmas once, in `OnlineLearning/ExponentialWeights.lean`; the
      anytime bound and AdaHedge's regret bound both use them. The stability term of Bandits 6.4,
      $\langle p,y\rangle+\frac1\eta\log\sum_ap_ae^{-\eta y_a}$, is the mixability gap that
      `mixLoss` computes.
    - Unblocks: Bandits 6.4, 7.2; target 1.14.
14. **Exp4-IX with learning-rate sequences.** After 1.12, 1.13.
    - Prove the pathwise local-norm bound of Exp4-IX for nonincreasing sequences $\eta_t$ and
      $\gamma_t$ (Bandits 7.2), from target 1.13; the constant-rate bound of target 1.12 is its
      case.
    - Unblocks: Bandits 7.3–7.4; targets 1.15–1.16.
15. **The pseudo-regret of Exp4 and Exp3 against any environment.** After 0.9, 0.10, 1.14.
    - Prove the bound $\bar R^E_n\le\frac{\log M}{\eta_{n-1}}+\frac k2\sum_{t<n}\eta_t$ of
      Bandits 7.3 for Exp4 against any environment with feedback in `[0, 1]`, and its case
      $M=k$ for Exp3.
    - Derive [LS, Theorems 11.2 and 18.1] for oblivious tables and advice: `Exp3.advRegret_le`,
      `Exp3.advRegret_le_sqrt`, `exp3_advRegret_le`, `exp3_advRegret_le_sqrt`,
      `Exp4.expertRegret_le`, `Exp4.expertRegret_le_sqrt`, `exp4_expertRegret_le`,
      `exp4_expertRegret_le_sqrt` and `Exp4.expertRegret_nonpos_of_subsingleton`. The expectation
      lemmas for a fixed table (`Exp3.sum_sub_integral_eq_integral_sum_lossIwEstimator_sub`,
      `Exp4.integral_dotProduct_lossIwEstimator`, `Exp3.integral_sq_div_exp3Weights`) are replaced
      by their forms for any environment.
    - Unblocks: Bandits 7.3 ([BCB12, Theorem 3.1]).
16. **High-probability bounds of Exp3-IX against any environment.** After 0.9, 0.10, 1.14.
    - Restate the high-probability results of `Bandits/Exp3/IX.lean` ([LS, Lemmas 12.2–12.4 and
      Theorem 12.1]: the `Exp3IX.measure_…` lemmas,
      `measure_exists_le_exp3IXSum_sub_union_le`, `Exp3IX.measure_exists_sqrt_le_sum_sub_le` and
      the `exp3IX_measure_…` corollaries) for the random regret against any environment with
      feedback in `[0, 1]` and nonincreasing $\eta_t$ and $\gamma_t$ (Bandits 7.4); the current
      statements, for constant rates and a reward table fixed in advance, are their cases.
      `Probability/Martingale/ImplicitExploration.lean` already proves [Neu15, Lemma 1] with
      adapted weights.
    - Unblocks: Bandits 7.4 ([Neu15, Theorems 1–2]).
17. **Mirror descent with nonincreasing learning rates.** After 0.11.
    - In `OnlineLearning/MirrorDescent.lean`, restate `sum_apply_sub_le_mirrorDescent`,
      `mirrorDescent_regret_le` and the other regret bounds of the file for nonincreasing learning
      rates $\eta_t$ (`IsMirrorDescentStep` already takes the rate of each round), with
      $\sum_{t<n}y_t(a_t-u)\le D/\eta_{n-1}+\sum_{t<n}\eta_t\|y_t\|^2/(2m)$ for an `m`-strongly
      convex potential [Ora, Theorem 6.11] (Bandits 6.3). Constant rates are the case of a constant
      sequence.
    - Unblocks: Bandits 6.3, 6.6, 10.2.
18. **The self-normalized bound with a regularizer.** After 0.12.
    - In `Probability/Martingale/SelfNormalized.lean`, restate
      `supermartingale_exp_inner_sum_smul_sub_designOp`,
      `supermartingale_integral_exp_inner_sum_smul_sub_designOp`,
      `measure_exists_inner_ringInverse_designOp_ge_le` and
      `le_measureReal_forall_inner_ringInverse_designOp_lt`, stated for `designOp (lam • 1)` with
      the factor `lam ^ d`, for every positive definite `V₀`, with $\det V_0$ [AYPS11, Theorem 1]
      (Bandits 8.4), by the Gaussian mixture of covariance $V_0^{-1}$. [LS, Theorem 20.4] is the
      case $V_0=\lambda\,\mathrm{id}$. The statements of `ConfidenceEllipsoid.lean` keep their
      form.
    - Unblocks: Bandits 8.4–8.5, 9.2; ReinforcementLearning 23.
19. **d_inf for exponential families.**
    - In `Bandits/LaiRobbins.lean`, prove the computation of Bandits 4.4: for a family of
      Bandits 3, a mean $\mu$ and $m\ge\mu$, `dInf` of the members at the member of mean $\mu$ is
      $d(\mu,m)$ for $m$ in the means and $\infty$ beyond them. The proof is the argument that
      `dInf_range_gaussianReal` and `dInf_range_bernoulliMeasure` share, with
      `klDiv_expFamily_natParam`, `continuousOn_expFamilyDiv` and
      `strictMonoOn_expFamilyDiv_right`.
    - Derive `dInf_range_gaussianReal`, and `dInf_range_bernoulliMeasure` for parameters in
      `(0, 1)`; its boundary cases and `dInf_range_bernoulliMeasure_of_one_le` are proved
      directly.
    - Unblocks: Bandits 4.4–4.5.

### Dynamic programming and Markov decision processes

20. **The resolvent as the inverse of $1-\gamma\kappa$.**
    - In `Probability/Kernel/Resolvent.lean`, prove that for a Markov kernel `κ` and
      $0\le\gamma<1$, `1 - γ • κ.integralCLM` is invertible in the continuous linear maps of
      `boundedMeasurable α`, with inverse the action of `Kernel.resolvent`
      (ReinforcementLearning 1.4), from the merged identities `dirac_add_resolvent_comp_apply` and
      `dirac_add_comp_resolvent_apply`.
    - Derive `Kernel.eq_integral_resolvent_of_eq_add` (uniqueness of the bounded solution) from
      it, and delete `eq_of_forall_abs_sub_le_mul` (`Analysis/FixedPoint/OrderUnit.lean`), whose
      only use it is.
    - Unblocks: ReinforcementLearning 1.4–1.5, 9.2, 12.
21. **Evaluation operators through `Kernel.integralCLM`, and Blackwell's argument once.** After
    0.15.
    - In `MarkovDecisionProcess/ValueIteration/Basic.lean`, define `MDP.bellmanEvalOp` as the
      affine map $v\mapsto r_\pi+\gamma P_\pi v$ of `boundedMeasurable 𝓢`, with $P_\pi$ acting by
      `(M.stateKernel π).integralCLM` (ReinforcementLearning 9.1), and prove
      `isBlackwell_bellmanEvalOp` from the positivity of `Kernel.integralCLM` and its value on
      constants. `coeFn_bellmanEvalOp` keeps the pointwise form.
    - Derive `MDP.abs_bellman_sub_le` and `MDP.abs_bellmanEval_sub_le` (`Bellman.lean`) from
      `isBlackwell_bellmanOp` and `isBlackwell_bellmanEvalOp` through `boundedMeasurable`, for
      bounded measurable value functions and bounded rewards (ReinforcementLearning 0.2), and
      delete `abs_sub_le_of_monotone_of_add_const` (`Analysis/FixedPoint/OrderUnit.lean`).
    - Unblocks: ReinforcementLearning 0.2, 9.1–9.2; target 1.22.
22. **The rates of policy iteration and modified policy iteration from the abstract lemmas.**
    After 0.14, 1.21.
    - Prove that the pointwise order of `lp` and of `boundedMeasurable 𝓢` has closed intervals
      (`OrderClosedTopology`, ReinforcementLearning 0.1), so that the lemmas of
      `Analysis/FixedPoint/DynamicProgramming.lean` apply on `boundedMeasurable 𝓢`.
    - Derive the rates of `MarkovDecisionProcess/PolicyIteration.lean`
      (`MDP.IsPolicyIteration.abs_value_sub_optValue_le`, and `bellman_le_value_succ`,
      `monotone_value` and `bellman_iterate_le_value`, which reprove the abstract lemmas
      pointwise) and of `ModifiedPolicyIteration.lean`
      (`MDP.IsModifiedPolicyIteration.abs_sub_optValue_le`) from `IsPolicyIteration.norm_sub_le`,
      `map_le`, `monotone` and `iterate_le` and `IsModifiedPolicyIteration.norm_sub_le` and
      `le_of_isFixedPt`, as the introduction of ReinforcementLearning Layer 10 asks.
    - Unblocks: ReinforcementLearning 10.2–10.3.
23. **Discounted optimality for countable action sets.** After 0.13, 0.15. Prerequisites:
    ReinforcementLearning 0.6 (measurable ε-maximizers over a countable type) and 8.1 (measurable
    ε-greedy policies).
    - Restate for `[Countable 𝓐]` (ReinforcementLearning 9.4) the statements of
      `MarkovDecisionProcess/Comparison.lean` (`le_optValue_of_le_bellman`,
      `eq_optValue_of_bellman_eq`), of the section of `Optimality.lean` with finitely many actions
      (`bellman_optValue`, `measurable_optValue`, `runValue_le_integral_optValue`,
      `abs_sub_optValue_le_of_bellman_le_succ`, `value_eq_optValue_iff`, `measurable_optQValue`,
      `optQValue_le_optValue`, `iSup_optQValue`, `lookahead_iSup_optQValue`,
      `eq_optQValue_of_lookahead_iSup_eq`, `qValue_le_optQValue`,
      `integral_optQValue_saKernel_le`) and the statements about the optimal value of
      `ValueIteration/Greedy.lean` (`abs_optValue_sub_le` and the bounds on
      `bellman … - optValue`). Their proofs through `M.greedy` use measurable ε-greedy policies
      instead, with the bound of ReinforcementLearning 9.3 (b) from target 0.13.
    - Derive the rate of value iteration towards the optimal value from
      `abs_bellman_iterate_sub_le` (`ValueIteration/Basic.lean`, already for countable actions).
      The statements about greedy policies keep finitely many actions (`value_greedy_optValue`,
      `runValue_policyAlg_greedy`, `isGreatest_runValue`, `isGreatest_value`).
    - Unblocks: ReinforcementLearning 9.4–9.6, 10.1, 12.
24. **The simulation lemma with a reward error.**
    - In `MarkovDecisionProcess/Simulation.lean`, drop the hypothesis
      `meanReward M'.R = meanReward M.R` from `qValue_sub_qValue`, `abs_qValue_sub_qValue_le`,
      `abs_value_sub_value_le`, `abs_qValue_sub_qValue_le_of_tvDist_le`,
      `abs_value_sub_value_le_of_tvDist_le`, `optQValue_sub_optQValue_le`,
      `le_optQValue_sub_optQValue`, `abs_optQValue_sub_optQValue_le`,
      `abs_optValue_sub_optValue_le`, `abs_optQValue_sub_optQValue_le_of_tvDist_le` and
      `abs_optValue_sub_optValue_le_of_tvDist_le`, with the reward error of
      ReinforcementLearning 12.2:
      $Q^\pi_M-Q^\pi_{M'}=R_\gamma(P'^\pi_{SA})\big((r-r')+\gamma(P-P')v^\pi_M\big)$, the bounds
      gaining the term $(1-\gamma)^{-1}\|r-r'\|$.
    - Restate `Kernel.integral_resolvent_sub_integral_resolvent` (`Resolvent.lean`) as the
      simulation identity with two rewards of ReinforcementLearning 1.5, from the merged
      `integral_resolvent_sub_eq_integral_resolvent` and `integral_resolvent_eq_add`.
    - Unblocks: ReinforcementLearning 12.2, 15.4, 21.1, 21.3.

### Identification: Track-and-Stop on best arm identification

25. **Track-and-Stop on best arm identification, with every continuity hypothesis discharged**
    [GK16, Theorem 14, Proposition 6].
    - The sample complexity theorems of `Identification/TrackAndStop.lean`
      (`eventually_expectedStoppingTime_trackAndStop_le_of_charTime_lt`,
      `eventually_expectedStoppingTime_cTrackAndStop_le_of_charTime_lt`) and the theorems of
      `Identification/GaussianThreshold.lean`
      (`isDeltaPAC_trackAndStop_unionBoundThreshold_of_mem_optAlloc`,
      `tendsto_expectedStoppingTime_trackAndStop_unionBoundThreshold_div_log`) take as hypotheses
      that the target map is continuous at the model (`hw_cont`), that the cost of the
      alternatives is lower semicontinuous or continuous there (`h_lsc`, `h_cont`), that the
      recommendation is locally constant (`hrec_eq`) and, for the limit theorem, that the
      characteristic time is finite (`h_charTime`). Discharge them on best arm identification, in
      a file of its own that imports these two files and `Identification/Task/BestArm.lean`.
    - Exponential families. For arms in one exponential family `(ρ, T)` with divergence `d` (the
      hypotheses of `continuousOn_altCost_baiTask_restrict`), the task
      `(baiTask ν id).restrict {μ | ∀ c, μ c ∈ ρ.expFamilyMeans T}`, a vector of means `μ` of the
      family with best arm `a`, measurable targets with `w μ' ∈ optAlloc μ' a` for `μ'` near `μ`
      and the recommendation of the empirical best arm: `hw_cont` is
      `continuousAt_of_mem_optAlloc_baiTask_restrict`, `h_lsc` and `h_cont` follow from
      `continuousOn_altCost_baiTask_restrict`, and `hrec_eq` from the uniqueness of the best arm
      of the admissible models. Prove, for D-tracking and for C-tracking and for thresholds
      $\beta_\delta(n,h)\le\log(r(n)/\delta)$ with $r(n)=O(n^p)$,
      $\limsup_{\delta\to0}\mathbb E_\mu[\tau_\delta]/\log(1/\delta)\le T^*(\mu)$, as a
      `Filter.limsup` along `𝓝[>] 0` in `ℝ≥0∞`.
    - Gaussian arms. For `baiTask (Bandits.gaussianBandit · σ2) id` with `σ2 ≠ 0` and targets
      that are optimal allocations at every admissible model, prove that Track-and-Stop with the
      thresholds `unionBoundThreshold` is `δ`-PAC for every `δ ∈ (0, 1]` and that
      $\mathbb E_\mu[\tau_\delta]/\log(1/\delta)\to T^*(\mu)$ at every admissible `μ`, from the
      two theorems of `GaussianThreshold.lean` above; `h_charTime` follows from
      `charTime_baiTask_gaussianBandit_le` ($T^*(\mu)\le2H(\mu)$).
    - No statement of the file assumes continuity, semicontinuity, a locally constant
      recommendation or a finite characteristic time. These statements are the best arm
      identification case of Identification 5.2: the pull request that builds Identification 5.2
      for every single-answer task on exponential-family product models derives them from it.
    - Unblocks: the Identification completion checks on Track-and-Stop.

## Layer 2: Material Tau Ceti provides

1. **Exponential tilts and generating functions of standard laws.**
   - Delete `ProbabilityTheory.mgf_tilted_mul` and `ProbabilityTheory.integrableExpSet_tilted_mul`
     (`Probability/Moments/Tilted.lean`) for `TauCeti.mgf_tilted_mul` and
     `TauCeti.integrableExpSet_tilted_mul`. `ProbabilityTheory.cgf_tilted_mul` is
     `TauCeti.cgf_tilted_mul` without the hypothesis `[NeZero μ]`: prove it from Tau Ceti's, with
     the zero measure separately.
   - Delete `tilted_mul_gaussianReal` and its private helper `gaussianPDFReal_mul_exp_div`,
     `gaussianPDFReal_zero_one` (`Probability/Distributions/Gaussian/Real.lean`) and
     `tilted_mul_natCast_poissonMeasure` (`Probability/Distributions/Poisson.lean`), for Tau
     Ceti's `TauCeti.Probability.gaussianReal_tilted_mul`, `gaussianPDFReal_zero_one` and
     `poissonMeasure_tilted_mul`. Prove `tilted_mul_expMeasure`
     (`Probability/Distributions/Exponential.lean`) from `gammaMeasure_tilted_mul` for
     parameters below the rate, keeping its case of larger parameters.
   - Derive `mgf_natCast_poissonMeasure`, `cgf_natCast_poissonMeasure` and
     `integrableExpSet_natCast_poissonMeasure` from Tau Ceti's `mgf_id_map_cast_poissonMeasure`,
     `cgf_id_map_cast_poissonMeasure` and `integrableExpSet_id_map_cast_poissonMeasure` through
     `mgf_map`.
   - Migrate the uses in `Probability/Distributions/ExponentialFamily/` and
     `Probability/Distributions/Gaussian/Tail.lean`.
2. **Powers of kernels.** Delete the instances `IsMarkovKernel (κ ^ n)` and
   `IsSFiniteKernel (κ ^ n)` and `Kernel.one_eq_id` (`Probability/Kernel/Composition/Comp.lean`)
   for Tau Ceti's `IsMarkovKernel.pow`, `IsSFiniteKernel.pow` and `Kernel.one_def`, migrating
   `Probability/Kernel/Resolvent.lean`, `MarkovDecisionProcess/MarkovPolicy.lean` and
   `MarkovDecisionProcess/Comparison.lean`.
3. **Elementary analysis.** Delete `Asymptotics.isLittleO_sub_mul_of_tendsto_div`
   (`Analysis/Asymptotics/Lemmas.lean`), one direction of Tau Ceti's
   `Asymptotics.isLittleO_sub_mul_iff_tendsto_div`, migrating `Bandits/AsymptoticOptimality.lean`;
   delete `Real.exp_neg_le_one_sub_add_sq_div_two` (`Analysis/SpecialFunctions/Exp.lean`), Tau
   Ceti's `Real.exp_le_one_add_add_sq_div_two_of_nonpos` at $-x$, migrating
   `OnlineLearning/ExponentialWeights.lean`.
4. **Total variation and the finite Pinsker inequality.** Derive
   `tvDist_le_two_mul_of_forall_measureReal_le_add` and
   `abs_measureReal_sub_measureReal_le_tvDist_div_two`
   (`MeasureTheory/Measure/TotalVariation/Basic.lean`) from Tau Ceti's
   `MeasureTheory.etvDist_le_two_mul_iff`, and `sq_sum_abs_sub_le_two_mul_sum_mul_log_div`
   (`InformationTheory/KullbackLeibler/Finite.lean`) from Tau Ceti's
   `etvDist_sq_le_two_mul_klDiv` with `klDiv_eq_ofReal_sum_log_singleton`, keeping their
   statements.

## Completion checks

- `baiTask gaussianMeanVarBandit (fun θ a ↦ (θ a).1)` is best arm identification with unknown
  variances, and the tasks on vectors of means are the case `mean = id`.
- The task-level guarantees of LUCB, KL-LUCB, successive elimination and median elimination
  quantify over every bandit of their class, and no statement about LUCB mentions an auxiliary
  family of bandits.
- `IsAlgEnvSeq.integral_sum_feedback_eq_sum_integral_pullCount_mul` and
  `klDiv_stoppedHistMeasure_le` are corollaries of statements for every environment, and the
  transfers of `SequentialLearning/SumRewards.lean` for sums are corollaries of the transfer for
  events about the observations.
- `IdentTask.glrt` takes thresholds `(n : ℕ) → Hist Unit α 𝓨 n → ℝ≥0∞`, no declaration
  `IdentTask.empCost` remains, and the D- and C-tracking sample-complexity theorems are derived from one
  reduction.
- No Track-and-Stop sample complexity theorem has a rate `κ` among its hypotheses. On best arm
  identification, the Track-and-Stop theorems assume no continuity, semicontinuity or locally
  constant recommendation; for two Gaussian arms `a`, `b` of variance `σ2` with `μ b < μ a`,
  Track-and-Stop with `unionBoundThreshold` has
  $\mathbb E_\mu[\tau_\delta]/\log(1/\delta)\to8\sigma^2/(\mu_a-\mu_b)^2$
  (`charTime_baiTask_gaussianBandit_of_forall_eq_or_eq`).
- `exp3`, `exp3IX` and `exp4` are defined as instances of Exp4-IX; `advRegret` is the pseudo-regret
  against `Environment.evalSeq`; `ftrl_regret_le` and `softmax_regret_le` are constant cases of
  anytime bounds.
- `designOp` takes a regularizer `V₀ : E →L[ℝ] E`.
- No hypothesis `IsGreatest (Set.range fun d ↦ T d x) (B x)` remains in
  `Analysis/FixedPoint/DynamicProgramming.lean`; no declaration `MDP.IsGreedy` remains;
  `MDP.stateMarginal` is the only definition of state marginals, and `MDP.runReturn` takes a
  discount.
- No statement of `MarkovDecisionProcess/Simulation.lean` assumes
  `meanReward M'.R = meanReward M.R`.
- No declaration `abs_sub_le_of_monotone_of_add_const` or `eq_of_forall_abs_sub_le_mul` remains.
- No declaration of `Probability/Moments/Tilted.lean`, `Probability/Distributions/` or
  `Probability/Kernel/Composition/Comp.lean` restates one of Tau Ceti.

## References

- [LS] T. Lattimore and Cs. Szepesvári, *Bandit Algorithms*, Cambridge University Press, 2020:
  Theorems 11.2, 12.1, 18.1 and 20.4, Lemmas 12.2–12.4.
- [AYPS11] Y. Abbasi-Yadkori, D. Pál and Cs. Szepesvári, *Improved algorithms for linear
  stochastic bandits*, NeurIPS 2011, Theorem 1.
- [BCB12] S. Bubeck and N. Cesa-Bianchi, *Regret analysis of stochastic and nonstochastic
  multi-armed bandit problems*, Foundations and Trends in Machine Learning 5(1), 2012,
  Theorem 3.1.
- [KK21] E. Kaufmann and W. M. Koolen, *Mixture martingales revisited with applications to
  sequential tests and confidence intervals*, JMLR 22 (2021).
- [Neu15] G. Neu, *Explore no more: improved high-probability regret bounds for non-stochastic
  bandits*, NeurIPS 2015, Lemma 1, Theorems 1–2.
- [Ora] F. Orabona, *Online learning: a modern introduction using convex optimization*,
  arXiv:1912.13213v10, 2026, Lemma 7.1, Corollary 7.6, Theorem 6.11.

The identification, bandit and planning results restated here are those of the references of the
three roadmaps they belong to.
