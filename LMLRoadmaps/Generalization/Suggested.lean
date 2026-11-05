import Mathlib.Analysis.Normed.Order.Lattice
import Mathlib.Dynamics.FixedPoints.Basic
import Mathlib.InformationTheory.KullbackLeibler.Basic
import LeanMachineLearning.SequentialLearning.FiniteActions
import LeanMachineLearning.SequentialLearning.IdentificationAlg
import LeanMachineLearning.SequentialLearning.IonescuTulceaSpace
import LeanMachineLearning.SequentialLearning.StationaryEnv

/-!
# Refactors toward the generality of the literature: suggested signatures

**This file is not the roadmap and is not exhaustive.** The definitive document is `README.md`.
The statements suggest the forms of restated LMLExplore declarations whose signature changes, so
that contributors and reviewers converge on their shapes; the admitted proofs and the admitted
definitions are targets. The LMLExplore declarations they restate are named in the README.

The general statements of several targets already have suggested forms in the Suggested.lean
files of the roadmaps that specify them, and are not repeated here:
- Identification: `integral_sum_feedback_eq_integral_sum_means` (target 0.3),
  `measure_exists_armObs_le_streamMeasure` (target 0.4, for real observations),
  `klDiv_stoppedHistMeasure_le_tsum` (target 0.5);
- Bandits: `pseudoRegret`, `randomRegret` (target 0.9), `ftrl_regret_le_of_monotone`
  (target 0.11), `designOp` with a regularizer `V₀` (target 0.12),
  `measure_exists_inner_inverse_designOp_ge_le` (target 1.18), `dInf_range_tilted` (target 1.19);
- ReinforcementLearning: `MDP.IsApproxGreedy` (target 0.15), `MDP.runReturn` with a discount and
  `MDP.stateMarginal` for a sequence of kernels (target 0.16), `MDP.bellman_optValue` for countable
  actions (target 1.23), `MDP.qValue_sub_qValue` with a reward error (target 1.24).

This file imports only Mathlib, Tau Ceti and LML, at the versions pinned by LMLRoadmaps, so it
restates the LMLExplore structures it needs (`IdentTask`, `IsBlackwell`, `IsPolicyIteration`,
`simplex`) and uses the LML names of that pin: `stationaryEnv` is `Environment.bandit` at the pin
of LMLExplore.
-/

noncomputable section

open MeasureTheory ProbabilityTheory InformationTheory Learning Finset Function
open scoped ENNReal NNReal InnerProductSpace

namespace LMLRoadmaps.Generalization

/-! ## Identification tasks with a mean functional -/

section Tasks

variable {α 𝓨 Θ ℐ : Type*} [Fintype α] [DecidableEq α] [MeasurableSpace α]
  [MeasurableSingletonClass α] [MeasurableSpace 𝓨]

/-- LMLExplore's identification tasks (`LMLExplore.Identification.IdentTask`), unchanged. -/
@[ext]
structure IdentTask (α Θ ℐ 𝓨 : Type*) [MeasurableSpace α] [MeasurableSpace 𝓨] where
  /-- The admissible models. -/
  M : Set Θ
  /-- The bandit of each model. -/
  ν : Θ → Kernel α 𝓨
  /-- The bandit of each model is a Markov kernel. -/
  isMarkovKernel_ν : ∀ θ, IsMarkovKernel (ν θ)
  /-- The correct answers of each model. -/
  correct : Θ → Set ℐ

namespace IdentTask

variable (task : IdentTask α Θ ℐ 𝓨)

instance (θ : Θ) : IsMarkovKernel (task.ν θ) := task.isMarkovKernel_ν θ

/-- The alternatives to the answer `i`. -/
def alt (i : ℐ) : Set Θ := {θ | θ ∈ task.M ∧ i ∉ task.correct θ}

/-- The pullback of a task along `f : Θ' → Θ`, an item of Identification 1.1 that is not a
target here. -/
def comap {Θ' : Type*} (f : Θ' → Θ) : IdentTask α Θ' ℐ 𝓨 where
  M := f ⁻¹' task.M
  ν := task.ν ∘ f
  isMarkovKernel_ν θ' := task.isMarkovKernel_ν (f θ')
  correct := task.correct ∘ f

end IdentTask

/-- Best arm identification for models `Θ` with bandits `ν` and the mean functional `mean`: the
restated `LMLExplore.Identification.baiTask`, whose current form is `baiTask ν` on
`Θ = α → ℝ`, now `baiTask ν id`. -/
def baiTask (ν : Θ → Kernel α 𝓨) [∀ θ, IsMarkovKernel (ν θ)] (mean : Θ → α → ℝ) :
    IdentTask α Θ α 𝓨 where
  M := {θ | ∃ a, ∀ b ≠ a, mean θ b < mean θ a}
  ν := ν
  isMarkovKernel_ν _ := inferInstance
  correct θ := {a | ∀ b ≠ a, mean θ b < mean θ a}

/-- Thresholding with the mean functional `mean`: the correct answer is the set of arms with mean
above `γ`, on the models with no mean equal to `γ`. -/
def thresholdingTask (ν : Θ → Kernel α 𝓨) [∀ θ, IsMarkovKernel (ν θ)] (mean : Θ → α → ℝ)
    (γ : ℝ) : IdentTask α Θ (Finset α) 𝓨 where
  M := {θ | ∀ a, mean θ a ≠ γ}
  ν := ν
  isMarkovKernel_ν _ := inferInstance
  correct θ := {s | ∀ a, a ∈ s ↔ γ < mean θ a}

/-- When the bandit of a model depends on its means only, the task of `(ν' ∘ mean, mean)` is the
pullback along `mean` of the task on vectors of means (Identification 1.1). The same holds for
each classical task. Targets 0.1–0.2 prove these identities if `IdentTask.comap` is merged;
otherwise the pull request that adds `comap` proves them. -/
theorem baiTask_comp_eq_comap (ν' : (α → ℝ) → Kernel α 𝓨) [∀ μ, IsMarkovKernel (ν' μ)]
    (mean : Θ → α → ℝ) :
    baiTask (fun θ ↦ ν' (mean θ)) mean = (baiTask ν' id).comap mean :=
  sorry

/-! ### GLR stopping rules with thresholds depending on the round and the history -/

variable [MeasurableSpace ℐ]

/-- The joint law of the stopped history and of the output of `A` in `env`. -/
def histOutputMeasure (A : IdentAlg Unit α 𝓨 ℐ) (env : Environment Unit α 𝓨) :
    Measure ((Σ n : ℕ, Hist Unit α 𝓨 n) × ℐ) :=
  stoppedHistMeasure A.alg env A.stopSet ⊗ₘ A.output

namespace IdentTask

variable (task : IdentTask α Θ ℐ 𝓨)

/-- `A` is `δ`-correct on the task: on every admissible model, with probability at least `1 - δ`,
it stops and outputs a correct answer. -/
def IsDeltaCorrect (A : IdentAlg Unit α 𝓨 ℐ) (δ : ℝ) : Prop :=
  ∀ θ ∈ task.M, (histOutputMeasure A (stationaryEnv (task.ν θ))).real
    {p | p.1 ∉ A.stopSet ∨ p.2 ∉ task.correct θ} ≤ δ

/-- `A` is `δ`-PAC on the task: it is `δ`-correct and stops almost surely on every admissible
model. -/
def IsDeltaPAC (A : IdentAlg Unit α 𝓨 ℐ) (δ : ℝ) : Prop :=
  task.IsDeltaCorrect A δ ∧ ∀ θ ∈ task.M,
    ∀ᵐ ω ∂(trajMeasure A.alg (stationaryEnv (task.ν θ))),
      A.stoppingTime IT.obs IT.action IT.feedback ω ≠ ⊤

/-- LMLExplore's GLR statistic `inf_{λ ∈ ¬i} Z n h λ` of the evidence function `Z`
(`IdentTask.glr`), unchanged. -/
def glr (Z : (n : ℕ) → Hist Unit α 𝓨 n → Θ → ℝ≥0∞) (n : ℕ) (h : Hist Unit α 𝓨 n) (i : ℐ) :
    ℝ≥0∞ :=
  ⨅ θ' ∈ task.alt i, Z n h θ'

/-- The restated `IdentTask.glrt` (Identification 4.3): the GLRT with sampling rule `alg`, evidence
`Z`, recommendation `rec` and thresholds `β n h` depending on the round `n` and on the history
`h`. It stops after `n` rounds with history `h` when `β n h < task.glr Z n h (rec n h)`, and
answers `rec n h`. Its current thresholds `β : ℕ → ℝ≥0∞` are the case `fun n _ ↦ β n`. -/
def glrt (Z : (n : ℕ) → Hist Unit α 𝓨 n → Θ → ℝ≥0∞) (alg : Algorithm Unit α 𝓨)
    (β : (n : ℕ) → Hist Unit α 𝓨 n → ℝ≥0∞) (rec : (n : ℕ) → Hist Unit α 𝓨 n → ℐ)
    (hrec : ∀ n, Measurable (rec n))
    (hstop : ∀ n, MeasurableSet {h | β n h < task.glr Z n h (rec n h)}) :
    IdentAlg Unit α 𝓨 ℐ :=
  sorry

/-- The restated `IdentTask.isDeltaPAC_glrt` [GK16, Proposition 12; DKM19, Theorem 1; DK19,
Theorem 10] (Identification 4.3): if on every admissible model `θ`, with probability at least
`1 - δ`, the evidence against `θ` never exceeds the threshold, and the GLRT stops almost surely,
then it is `δ`-PAC, for every sampling rule. -/
theorem isDeltaPAC_glrt (Z : (n : ℕ) → Hist Unit α 𝓨 n → Θ → ℝ≥0∞)
    (alg : Algorithm Unit α 𝓨) (β : (n : ℕ) → Hist Unit α 𝓨 n → ℝ≥0∞)
    (rec : (n : ℕ) → Hist Unit α 𝓨 n → ℐ) (hrec : ∀ n, Measurable (rec n))
    (hstop : ∀ n, MeasurableSet {h | β n h < task.glr Z n h (rec n h)}) {δ : ℝ}
    (hc : ∀ θ ∈ task.M, MeasurableSet (task.correct θ))
    (hdev : ∀ θ ∈ task.M, (trajMeasure alg (stationaryEnv (task.ν θ))).real
      {ω | ∃ n, β n (history IT.obs IT.action IT.feedback n ω) <
        Z n (history IT.obs IT.action IT.feedback n ω) θ} ≤ δ)
    (h_stops : ∀ θ ∈ task.M, ∀ᵐ ω ∂(trajMeasure alg (stationaryEnv (task.ν θ))),
      (task.glrt Z alg β rec hrec hstop).stoppingTime IT.obs IT.action IT.feedback ω ≠ ⊤) :
    task.IsDeltaPAC (task.glrt Z alg β rec hrec hstop) δ :=
  sorry

/-! ### Plug-in statistics -/

/-- The transportation cost `∑ a, w a KL(ν_a(θ), ν_a(θ'))` (LMLExplore's `IdentTask.cost`). -/
def cost (w : α → ℝ) (θ θ' : Θ) : ℝ≥0∞ :=
  ∑ a, ENNReal.ofReal (w a) * klDiv (task.ν θ a) (task.ν θ' a)

/-- The cost `D(θ, w, ¬i)` of the alternatives to `i` (LMLExplore's `IdentTask.altCost`). -/
def altCost (θ : Θ) (w : α → ℝ) (i : ℐ) : ℝ≥0∞ :=
  ⨅ θ' ∈ task.alt i, task.cost w θ θ'

/-- The plug-in statistic of the estimator `est` (Identification 4.3), replacing
`IdentTask.empCost`: the cost from the estimate `est n h` to `θ'`, with the pull counts of `h` as
weights. `IdentTask.empCost` is the case `Θ = α → ℝ`, `𝓨 = ℝ` and `est` the empirical means. -/
def plugInCost (est : (n : ℕ) → Hist Unit α 𝓨 n → Θ) (n : ℕ) (h : Hist Unit α 𝓨 n) (θ' : Θ) :
    ℝ≥0∞ :=
  task.cost (fun a ↦ (pullCount' n h a : ℝ)) (est n h) θ'

/-- The restated `IdentTask.glr_empCost_eq_mul`: the GLR statistic of the plug-in statistic is
`n D(est n h, N(h) / n, ¬i)`. -/
theorem glr_plugInCost_eq_mul (est : (n : ℕ) → Hist Unit α 𝓨 n → Θ) {n : ℕ} (hn : n ≠ 0)
    (h : Hist Unit α 𝓨 n) (i : ℐ) :
    task.glr (task.plugInCost est) n h i =
      n * task.altCost (est n h) (fun a ↦ (pullCount' n h a : ℝ) / n) i :=
  sorry

end IdentTask

end Tasks

/-! ## Abstract dynamic programming without attainment -/

section DynamicProgramming

variable {E D : Type*} [NormedAddCommGroup E] [PartialOrder E] [IsOrderedAddMonoid E]
  [Module ℝ E] {e : E} {γ : ℝ≥0} {T : D → E → E} {B : E → E}

/-- LMLExplore's order-unit norm `‖x‖_e = inf {c ≥ 0 | -c • e ≤ x ≤ c • e}` (`orderUnitNorm`). -/
def orderUnitNorm (e x : E) : ℝ := sInf {c : ℝ | 0 ≤ c ∧ x ∈ Set.Icc (-(c • e)) (c • e)}

/-- LMLExplore's Blackwell conditions (`IsBlackwell`), unchanged. -/
structure IsBlackwell (e : E) (γ : ℝ≥0) (T : E → E) : Prop where
  monotone : Monotone T
  map_add_smul_le (x : E) (c : ℝ) (hc : 0 ≤ c) : T (x + c • e) ≤ T x + ((γ : ℝ) * c) • e

/-- `B` is the uniform supremum of the maps `T d` (ReinforcementLearning 0.3): `T d ≤ B`, and for
every `x` and `ε > 0` some decision is `ε`-greedy for `x`. It replaces the hypothesis
`∀ x, IsGreatest (Set.range fun d ↦ T d x) (B x)` of `Analysis/FixedPoint/DynamicProgramming.lean`,
which is the case where every `x` has a greedy decision. -/
structure IsUniformSup (e : E) (T : D → E → E) (B : E → E) : Prop where
  le (d : D) (x : E) : T d x ≤ B x
  exists_sub_smul_le (x : E) (ε : ℝ) (hε : 0 < ε) : ∃ d, B x - ε • e ≤ T d x

/-- The restated `IsBlackwell.of_isGreatest_range`: the uniform supremum of maps satisfying
Blackwell's conditions satisfies them. -/
theorem IsBlackwell.of_isUniformSup (hT : ∀ d, IsBlackwell e γ (T d)) (hB : IsUniformSup e T B) :
    IsBlackwell e γ B :=
  sorry

/-- The restated `isGreatest_iUnion_fixedPoints`: the fixed point of `B` is the least upper bound
of the fixed points of the maps `T d`, which need not be attained. -/
theorem isLUB_iUnion_fixedPoints [CompleteSpace E] [ClosedIicTopology E] [ClosedIciTopology E]
    (hnorm : ∀ x, orderUnitNorm e x = ‖x‖) (hT : ∀ d, IsBlackwell e γ (T d)) (hγ : γ < 1)
    (hB : IsUniformSup e T B) {x : E} (hx : IsFixedPt B x) :
    IsLUB (⋃ d, fixedPoints (T d)) x :=
  sorry

/-- LMLExplore's runs of policy iteration (`IsPolicyIteration`), unchanged: the field `map_eq`
records the greedy decisions that the run uses. -/
structure IsPolicyIteration (T : D → E → E) (B : E → E) (d : ℕ → D) (v : ℕ → E) : Prop where
  isFixedPt (k : ℕ) : IsFixedPt (T (d k)) (v k)
  map_eq (k : ℕ) : T (d (k + 1)) (v k) = B (v k)

/-- The restated `IsPolicyIteration.norm_sub_le`: policy iteration converges geometrically,
assuming the greedy decisions it uses and no others. -/
theorem IsPolicyIteration.norm_sub_le [ClosedIicTopology E] [ClosedIciTopology E]
    (hnorm : ∀ x, orderUnitNorm e x = ‖x‖) (hT : ∀ d, IsBlackwell e γ (T d)) (hγ : γ < 1)
    (hB : IsUniformSup e T B) {d : ℕ → D} {v : ℕ → E} (h : IsPolicyIteration T B d v) {x : E}
    (hx : IsFixedPt B x) (k : ℕ) : ‖v k - x‖ ≤ γ ^ k * ‖v 0 - x‖ :=
  sorry

end DynamicProgramming

/-! ## Exp4-IX as the single algorithm -/

section Exp4IX

variable {α : Type*} [Fintype α] [DecidableEq α] [MeasurableSpace α] [MeasurableSingletonClass α]

/-- LMLExplore's probability vectors on `α` (`simplex`). -/
def simplex (α : Type*) [Fintype α] : Set (α → ℝ) := {w | (∀ a, 0 ≤ w a) ∧ ∑ a, w a = 1}

theorem single_mem_simplex (b : α) : Pi.single b 1 ∈ simplex α :=
  sorry

/-- Exp4-IX [Neu15] (Bandits 7.2), with the advice map `adv` from the observation of a round to
the advice of the experts `β`, learning rates `η` and implicit-exploration parameters `γ`. -/
def exp4IX {𝓞 β : Type*} [MeasurableSpace 𝓞] [Fintype β] (adv : 𝓞 → β → simplex α)
    (hadv : Measurable adv) (η γ : ℕ → ℝ) : Algorithm 𝓞 α ℝ :=
  sorry

/-- The restated `exp4`: Exp4-IX without implicit exploration, the advice being the observation. -/
def exp4 {β : Type*} [Fintype β] (η : ℕ → ℝ) : Algorithm (β → simplex α) α ℝ :=
  exp4IX id measurable_id η 0

/-- The restated `exp3IX`: Exp4-IX with the experts `α`, expert `b` advising the arm `b`. -/
def exp3IX {𝓞 : Type*} [MeasurableSpace 𝓞] (η γ : ℕ → ℝ) : Algorithm 𝓞 α ℝ :=
  exp4IX (fun _ b ↦ ⟨Pi.single b 1, single_mem_simplex b⟩) measurable_const η γ

/-- The restated `exp3`: Exp3-IX without implicit exploration. -/
def exp3 {𝓞 : Type*} [MeasurableSpace 𝓞] (η : ℕ → ℝ) : Algorithm 𝓞 α ℝ :=
  exp3IX η 0

end Exp4IX

end LMLRoadmaps.Generalization
