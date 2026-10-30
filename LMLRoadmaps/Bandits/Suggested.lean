import Mathlib.Analysis.InnerProductSpace.Positive
import Mathlib.InformationTheory.KullbackLeibler.Basic
import Mathlib.Probability.Distributions.Bernoulli
import Mathlib.Probability.Distributions.Gaussian.Real
import Mathlib.Probability.Martingale.Basic
import LeanMachineLearning.ForMathlib.Analysis.Convex.Bregman.Basic
import LeanMachineLearning.ForMathlib.MeasureTheory.Order.MeasurableArg
import LeanMachineLearning.Online.Bandit.Algorithms.Regret.UCB
import LeanMachineLearning.Online.Bandit.Regret
import LeanMachineLearning.SequentialLearning.Deterministic
import LeanMachineLearning.SequentialLearning.EvaluationEnv
import LeanMachineLearning.SequentialLearning.FiniteActions
import LeanMachineLearning.SequentialLearning.IonescuTulceaSpace
import LeanMachineLearning.SequentialLearning.StationaryEnv
import LeanMachineLearning.SequentialLearning.SumRewards

/-!
# Bandit algorithms and their regret: suggested target signatures

**This file is not the roadmap and is not exhaustive.** The definitive document is `README.md`.
The statements here suggest Lean forms for particular milestones, so that contributors and
reviewers converge on names and signatures; discharging all of them finishes neither a milestone
nor the roadmap. The admitted proofs are targets, not claimed implementations. The algorithms are
admitted definitions: constructing them, with their run lemmas, is a target, and their docstrings
and the README specify them.

The names of the LML framework (`stationaryEnv`, `onlineEvalEnv`, `detAlgorithm`, ...) are those
of the LML version pinned by LMLExplore.
-/

noncomputable section

open MeasureTheory ProbabilityTheory InformationTheory Filter Real Finset Learning
open scoped ENNReal NNReal Topology InnerProductSpace

namespace LMLRoadmaps.Bandits

variable {α : Type*} [Fintype α] [Nonempty α] [DecidableEq α] [MeasurableSpace α]
  [MeasurableSingletonClass α]
  {Ω : Type*} {mΩ : MeasurableSpace Ω} {P : Measure Ω} [IsProbabilityMeasure P]

/-! ## Layer 0: instances, binary relative entropy, policies and regret notions -/

/-- The Gaussian bandit: arm `a` has law `𝒩(μ a, σ2)`. -/
def gaussianBandit (μ : α → ℝ) (σ2 : ℝ≥0) : Kernel α ℝ :=
  Kernel.ofFunOfCountable fun a ↦ gaussianReal (μ a) σ2

instance (μ : α → ℝ) (σ2 : ℝ≥0) : IsMarkovKernel (gaussianBandit μ σ2) :=
  ⟨fun a ↦ by change IsProbabilityMeasure (gaussianReal (μ a) σ2); infer_instance⟩

/-- The Bernoulli bandit: arm `a` has law `𝓑(p a)` on `{0, 1} ⊆ ℝ`. -/
def bernoulliBandit (p : α → unitInterval) : Kernel α ℝ :=
  Kernel.ofFunOfCountable fun a ↦ bernoulliMeasure (1 : ℝ) 0 (p a)

theorem hasSubgaussianMGF_gaussianBandit (μ : α → ℝ) (σ2 : ℝ≥0) (a : α) :
    HasSubgaussianMGF (fun x ↦ x - (gaussianBandit μ σ2 a)[id]) σ2 (gaussianBandit μ σ2 a) :=
  sorry

theorem klDiv_gaussianBandit (μ μ' : α → ℝ) {σ2 : ℝ≥0} (hσ2 : σ2 ≠ 0) (a : α) :
    klDiv (gaussianBandit μ σ2 a) (gaussianBandit μ' σ2 a) =
      ENNReal.ofReal ((μ a - μ' a) ^ 2 / (2 * σ2)) :=
  sorry

/-- The relative entropy `d(p, q)` between the Bernoulli laws of means `p` and `q`, with the
arguments clamped to `[0, 1]` (README Layer 0.2). -/
def klBer (p q : ℝ) : ℝ≥0∞ :=
  klDiv (bernoulliMeasure (1 : ℝ) 0 (Set.projIcc 0 1 zero_le_one p))
    (bernoulliMeasure (1 : ℝ) 0 (Set.projIcc 0 1 zero_le_one q))

/-- Pinsker's inequality for Bernoulli laws [LS, Lemma 10.2 (b)]. -/
theorem ofReal_two_mul_sq_le_klBer {p q : ℝ} (hp : p ∈ Set.Icc 0 1) (hq : q ∈ Set.Icc 0 1) :
    ENNReal.ofReal (2 * (p - q) ^ 2) ≤ klBer p q :=
  sorry

/-- The KL-UCB level `U(p, c)`: the largest `q ∈ [p, 1]` with `d(p, q) ≤ c`. -/
def klUpper (p : ℝ) (c : ℝ≥0∞) : ℝ := sSup {q | q ∈ Set.Icc p 1 ∧ klBer p q ≤ c}

theorem klUpper_le_min {p : ℝ} (hp : p ∈ Set.Icc 0 1) (c : ℝ≥0) :
    klUpper p c ≤ min 1 (p + √(c / 2)) :=
  sorry

/-- The algorithm that draws its action of round `n` from the weights `w n (h, o)`, a point of the
probability simplex (README Layer 0.3). Exp3, Exp3-IX and Exp4 are instances. -/
def weightAlgorithm {𝓞 𝓨 : Type*} [MeasurableSpace 𝓞] [MeasurableSpace 𝓨]
    (w : (n : ℕ) → Hist 𝓞 α 𝓨 n × 𝓞 → α → ℝ) (hw : ∀ n a, Measurable fun x ↦ w n x a)
    (hw_nonneg : ∀ n x a, 0 ≤ w n x a) (hw_sum : ∀ n x, ∑ a, w n x a = 1) :
    Algorithm 𝓞 α 𝓨 :=
  sorry

/-- The index policy playing `argmax (I n (h, o))`, ties broken by LML's `argmax`
(README Layer 0.4). -/
def indexAlgorithm {𝓞 𝓨 : Type*} [MeasurableSpace 𝓞] [MeasurableSpace 𝓨]
    (I : (n : ℕ) → Hist 𝓞 α 𝓨 n × 𝓞 → α → EReal) (hI : ∀ n, Measurable (I n)) :
    Algorithm 𝓞 α 𝓨 :=
  detAlgorithm (fun n x ↦ argmax (I n x)) (fun n ↦ sorry)

/-- The regret against the best fixed arm of a run against the oblivious reward table `x`
[LS, (11.1)]. -/
def advRegret (x : ℕ → α → ℝ) (A : ℕ → Ω → α) (P : Measure Ω) (n : ℕ) : ℝ :=
  (⨆ a, ∑ t ∈ range n, x t a) - P[fun ω ↦ ∑ t ∈ range n, x t (A t ω)]

/-! ## Layer 1: concentration and maximal inequalities -/

/-- Ville's inequality for a nonnegative supermartingale. -/
theorem measure_exists_le_le_of_supermartingale {𝓕 : Filtration ℕ mΩ} {M : ℕ → Ω → ℝ}
    (hM : Supermartingale M 𝓕 P) (hM_nonneg : ∀ n ω, 0 ≤ M n ω) {c : ℝ} (hc : 0 < c) :
    P {ω | ∃ n, c ≤ M n ω} ≤ ENNReal.ofReal (P[M 0] / c) :=
  sorry

/-! ## Layer 2: UCB-type algorithms for sub-Gaussian rewards -/

section UCB

variable {O : ℕ → Ω → Unit} {A : ℕ → Ω → α} {R : ℕ → Ω → ℝ} {ν : Kernel α ℝ} [IsMarkovKernel ν]
  {σ2 : ℝ≥0}

/-- Minimax bound for LML's UCB (README Layer 2.1, the analogue of [LS, Theorem 7.2]). -/
theorem ucb_regret_le_sqrt {K : ℕ} [NeZero K] {A : ℕ → Ω → Fin K} {ν : Kernel (Fin K) ℝ}
    [IsMarkovKernel ν] {c : ℝ}
    (h : IsAlgEnvSeq O A R (Bandits.ucbAlgorithm K c) (stationaryEnv ν) P)
    (hν : ∀ a, HasSubgaussianMGF (fun x ↦ x - (ν a)[id]) σ2 (ν a)) (hσ2 : σ2 ≠ 0)
    (hc : 2 * σ2 < c) (n : ℕ) :
    P[Bandits.regret ν A n] ≤
      2 * √(8 * c * K * n * log (n + 1)) +
        (4 + 2 * σ2 / (c - 2 * σ2)) * ∑ a, Bandits.gap ν a :=
  sorry

/-- The index of asymptotically optimal UCB [LS, Algorithm 6] at Lean round `n` (book round
`n + 1`), with `f(t) = 1 + t log² t`. -/
def ucbFIndex (σ2 : ℝ≥0) (n : ℕ) (h : Hist Unit α ℝ n) (a : α) : EReal :=
  if pullCount' n h a = 0 then ⊤ else
    ((empMean' n h a +
      √(2 * σ2 * log (1 + (n + 1) * log (n + 1) ^ 2) / pullCount' n h a) : ℝ) : EReal)

/-- Asymptotically optimal UCB [LS, Algorithm 6]. -/
def ucbF (σ2 : ℝ≥0) : Algorithm Unit α ℝ :=
  indexAlgorithm (fun n x ↦ ucbFIndex σ2 n x.1) (fun n ↦ sorry)

/-- [LS, (8.2)] for σ²-sub-Gaussian rewards, in eventual form. -/
theorem ucbF_regret_eventually_le (h : IsAlgEnvSeq O A R (ucbF σ2) (stationaryEnv ν) P)
    (hν : ∀ a, HasSubgaussianMGF (fun x ↦ x - (ν a)[id]) σ2 (ν a)) (hσ2 : σ2 ≠ 0)
    {c : ℝ} (hc : ∑ a ∈ univ.filter (fun a ↦ 0 < Bandits.gap ν a), 2 * σ2 / Bandits.gap ν a < c) :
    ∀ᶠ n : ℕ in atTop, P[Bandits.regret ν A n] ≤ c * log n :=
  sorry

/-- The MOSS index [LS, Algorithm 7] for the horizon `horizon`. -/
def mossIndex (σ2 : ℝ≥0) (horizon n : ℕ) (h : Hist Unit α ℝ n) (a : α) : EReal :=
  if pullCount' n h a = 0 then ⊤ else
    ((empMean' n h a + √(4 * σ2 / pullCount' n h a *
      log (max 1 (horizon / (Fintype.card α * pullCount' n h a))))  : ℝ) : EReal)

/-- MOSS [LS, Algorithm 7], tuned for the horizon `horizon`. -/
def moss (σ2 : ℝ≥0) (horizon : ℕ) : Algorithm Unit α ℝ :=
  indexAlgorithm (fun n x ↦ mossIndex σ2 horizon n x.1) (fun n ↦ sorry)

/-- [LS, Theorem 9.1] for σ²-sub-Gaussian rewards. -/
theorem moss_regret_le (n : ℕ) (h : IsAlgEnvSeq O A R (moss σ2 n) (stationaryEnv ν) P)
    (hν : ∀ a, HasSubgaussianMGF (fun x ↦ x - (ν a)[id]) σ2 (ν a)) :
    P[Bandits.regret ν A n] ≤ 39 * √(σ2 * Fintype.card α * n) + ∑ a, Bandits.gap ν a :=
  sorry

/-! ## Layer 3: KL-UCB -/

/-- The KL-UCB index [LS, Algorithm 8] at Lean round `n`. -/
def klucbIndex (n : ℕ) (h : Hist Unit α ℝ n) (a : α) : EReal :=
  if pullCount' n h a = 0 then ⊤ else
    ((klUpper (empMean' n h a)
      (ENNReal.ofReal (log (1 + (n + 1) * log (n + 1) ^ 2) / pullCount' n h a)) : ℝ) : EReal)

/-- KL-UCB [LS, Algorithm 8]. -/
def klucb : Algorithm Unit α ℝ :=
  indexAlgorithm (fun n x ↦ klucbIndex n x.1) (fun n ↦ sorry)

/-- The asymptotic part of [LS, Theorem 10.6], for rewards in `[0, 1]`. -/
theorem klucb_regret_eventually_le (h : IsAlgEnvSeq O A R klucb (stationaryEnv ν) P)
    (hν : ∀ a, ∀ᵐ x ∂(ν a), x ∈ Set.Icc (0 : ℝ) 1) {c : ℝ}
    (hc : ∑ a ∈ univ.filter (fun a ↦ 0 < Bandits.gap ν a),
      Bandits.gap ν a / (klBer (ν a)[id] (⨆ b, (ν b)[id])).toReal < c) :
    ∀ᶠ n : ℕ in atTop, P[Bandits.regret ν A n] ≤ c * log n :=
  sorry

end UCB

/-! ## Layer 4: lower bounds for finitely many arms -/

/-- The divergence decomposition [LS, Lemma 15.1]. -/
theorem klDiv_map_history_eq_sum_pullCount [StandardBorelSpace α]
    {Ω' : Type*} {mΩ' : MeasurableSpace Ω'} {P' : Measure Ω'} [IsProbabilityMeasure P']
    {alg : Algorithm Unit α ℝ} {ν ν' : Kernel α ℝ} [IsMarkovKernel ν] [IsMarkovKernel ν']
    {O : ℕ → Ω → Unit} {A : ℕ → Ω → α} {R : ℕ → Ω → ℝ}
    {O' : ℕ → Ω' → Unit} {A' : ℕ → Ω' → α} {R' : ℕ → Ω' → ℝ}
    (h : IsAlgEnvSeq O A R alg (stationaryEnv ν) P)
    (h' : IsAlgEnvSeq O' A' R' alg (stationaryEnv ν') P') (n : ℕ) :
    klDiv (P.map (history O A R n)) (P'.map (history O' A' R' n)) =
      ∑ a, (∫⁻ ω, (pullCount A a n ω : ℝ≥0∞) ∂P) * klDiv (ν a) (ν' a) :=
  sorry

/-- The Bretagnolle–Huber inequality [LS, Theorem 14.2]. -/
theorem exp_neg_klDiv_div_two_le {Q : Measure Ω} [IsProbabilityMeasure Q] {s : Set Ω}
    (hs : MeasurableSet s) (h : klDiv P Q ≠ ∞) :
    exp (-(klDiv P Q).toReal) / 2 ≤ P.real s + Q.real sᶜ :=
  sorry

/-- The minimax lower bound for Gaussian bandits with variance `σ2` (README Layer 4.3;
[LS, Theorem 15.2] for `σ2 = 1`). -/
theorem exists_sqrt_le_integral_regret_gaussianBandit (alg : Algorithm Unit α ℝ) (σ2 : ℝ≥0)
    (n : ℕ) (hk : 2 ≤ Fintype.card α) (hn : σ2 * (Fintype.card α - 1 : ℝ) ≤ n) :
    ∃ μ : α → ℝ, (∀ a, μ a ∈ Set.Icc 0 1) ∧
      √(σ2 * (Fintype.card α - 1) * n) / 27 ≤
        ∫ ω, Bandits.regret (gaussianBandit μ σ2) IT.action n ω
          ∂(trajMeasure alg (stationaryEnv (gaussianBandit μ σ2))) :=
  sorry

/-- `d_inf(P, m, M)`: the smallest relative entropy from `P` to a law of `M` with mean above `m`
[LS, §16.1]. -/
def dInf (M : Set (Measure ℝ)) (Pa : Measure ℝ) (m : ℝ) : ℝ≥0∞ :=
  ⨅ Q ∈ {Q ∈ M | m < Q[id]}, klDiv Pa Q

/-- An algorithm is consistent over Gaussian bandits with variance `σ2` if its regret is
`o(n ^ p)` for every `p > 0` [LS, Definition 16.1]. -/
def IsConsistentGaussian (alg : Algorithm Unit α ℝ) (σ2 : ℝ≥0) : Prop :=
  ∀ μ : α → ℝ, ∀ p : ℝ, 0 < p →
    Tendsto (fun n : ℕ ↦ (∫ ω, Bandits.regret (gaussianBandit μ σ2) IT.action n ω
      ∂(trajMeasure alg (stationaryEnv (gaussianBandit μ σ2)))) / (n : ℝ) ^ p) atTop (𝓝 0)

/-- The Lai–Robbins lower bound for Gaussian bandits ([LS, Theorem 16.2] with
[LS, Table 16.1]), in eventual form. -/
theorem lai_robbins_gaussian {alg : Algorithm Unit α ℝ} {σ2 : ℝ≥0}
    (h : IsConsistentGaussian alg σ2) (hσ2 : σ2 ≠ 0) (μ : α → ℝ) {c : ℝ}
    (hc : c < ∑ a ∈ univ.filter (fun a ↦ 0 < Bandits.gap (gaussianBandit μ σ2) a),
      2 * σ2 / Bandits.gap (gaussianBandit μ σ2) a) :
    ∀ᶠ n : ℕ in atTop, c * log n ≤ ∫ ω, Bandits.regret (gaussianBandit μ σ2) IT.action n ω
      ∂(trajMeasure alg (stationaryEnv (gaussianBandit μ σ2))) :=
  sorry

/-! ## Layer 6: online linear optimization -/

section OnlineLinear

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [FiniteDimensional ℝ E]

/-- The regret bound of follow-the-regularized-leader [LS, Theorem 28.5], for a potential that is
differentiable at the iterates; `a t` minimizes `η ⟪·, ∑_{s<t} y s⟫ + F` over `K`. -/
theorem ftrl_regret_le {F : E → ℝ} {K : Set E} (hK : Convex ℝ K) (hF : ConvexOn ℝ K F)
    {η : ℝ} (hη : 0 < η) (y a : ℕ → E)
    (ha : ∀ t, IsMinOn (fun b ↦ η * ∑ s ∈ range t, ⟪b, y s⟫_ℝ + F b) K (a t))
    (hdiff : ∀ t, DifferentiableAt ℝ F (a t)) {u : E} (hu : u ∈ K) (n : ℕ) :
    ∑ t ∈ range n, ⟪a t - u, y t⟫_ℝ ≤
      (F u - F (a 0)) / η + ∑ t ∈ range n, ⟪a t - a (t + 1), y t⟫_ℝ -
        (∑ t ∈ range n, bregDiv F (a (t + 1)) (a t) (fderiv ℝ F (a t))) / η :=
  sorry

end OnlineLinear

/-! ## Layer 7: adversarial bandits with finitely many arms -/

/-- Exp3 with learning rate `η` [LS, Algorithm 9]: a weight-based policy with the exponential
weights of the loss-based importance-weighted reward estimates. -/
def exp3 (η : ℝ) : Algorithm Unit α ℝ := sorry

/-- The regret of Exp3 for an arbitrary learning rate; `η = √(2 log k / (n k))` gives
[LS, Theorem 11.2]. -/
theorem exp3_advRegret_le (x : ℕ → α → ℝ) (hx : ∀ t a, x t a ∈ Set.Icc 0 1) {η : ℝ} (hη : 0 < η)
    {O : ℕ → Ω → Unit} {A : ℕ → Ω → α} {R : ℕ → Ω → ℝ}
    (h : IsAlgEnvSeq O A R (exp3 η) (onlineEvalEnv x fun t ↦ measurable_of_countable (x t)) P)
    (n : ℕ) :
    advRegret x A P n ≤ log (Fintype.card α) / η + η * n * Fintype.card α / 2 :=
  sorry

/-! ## Layer 8: least squares, self-normalized bounds and optimal design -/

section Linear

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [FiniteDimensional ℝ E]

/-- The design operator `V_t(λ) = λ • id + ∑_{s < t} x s ⊗ x s`. -/
def designOp (lam : ℝ) (x : ℕ → E) (t : ℕ) : E →L[ℝ] E :=
  lam • ContinuousLinearMap.id ℝ E + ∑ s ∈ range t, (innerSL ℝ (x s)).smulRight (x s)

/-- The elliptical potential lemma [LS, Lemma 19.4] for `V_0 = λ • id`. -/
theorem sum_min_one_inner_inverse_designOp_le {lam : ℝ} (hlam : 0 < lam) (x : ℕ → E) {L : ℝ}
    (hx : ∀ t, ‖x t‖ ≤ L) (n : ℕ) :
    ∑ t ∈ range n, min 1 ⟪x t, Ring.inverse (designOp lam x t) (x t)⟫_ℝ ≤
      2 * Module.finrank ℝ E * log (1 + n * L ^ 2 / (Module.finrank ℝ E * lam)) :=
  sorry

/-- The self-normalized bound for vector-valued martingales [LS, Theorem 20.4], with
conditionally σ²-sub-Gaussian noise. -/
theorem measure_exists_inner_inverse_designOp_ge_le [StandardBorelSpace Ω]
    {𝓕 : Filtration ℕ mΩ} {x : ℕ → Ω → E} {η : ℕ → Ω → ℝ} {σ2 : ℝ≥0}
    (hx : ∀ t, StronglyMeasurable[𝓕 t] (x t)) (hη : ∀ t, StronglyMeasurable[𝓕 (t + 1)] (η t))
    (hsub : ∀ t, HasCondSubgaussianMGF (𝓕 t) (𝓕.le t) (η t) σ2 P)
    {lam δ : ℝ} (hlam : 0 < lam) (hδ : δ ∈ Set.Ioo 0 1) :
    P {ω | ∃ t, 2 * σ2 * log (1 / δ) +
        σ2 * log (LinearMap.det (designOp lam (fun s ↦ x s ω) t).toLinearMap /
          lam ^ Module.finrank ℝ E) ≤
      ⟪∑ s ∈ range t, η s ω • x s ω,
        Ring.inverse (designOp lam (fun s ↦ x s ω) t) (∑ s ∈ range t, η s ω • x s ω)⟫_ℝ} ≤
      ENNReal.ofReal δ :=
  sorry

/-- The design operator `V(w) = ∑_a w a • a ⊗ a` of a finitely supported design. -/
def designOperator (w : E →₀ ℝ) : E →L[ℝ] E :=
  w.sum fun a c ↦ c • (innerSL ℝ a).smulRight a

/-- The Kiefer–Wolfowitz theorem [LS, Theorem 21.1]: a G-optimal design with small support. -/
theorem exists_design_inner_inverse_le_finrank {𝒜 : Set E} (h𝒜 : IsCompact 𝒜)
    (hspan : Submodule.span ℝ 𝒜 = ⊤) :
    ∃ w : E →₀ ℝ, (w.support : Set E) ⊆ 𝒜 ∧ (∀ a, 0 ≤ w a) ∧ (w.sum fun _ c ↦ c) = 1 ∧
      w.support.card ≤ Module.finrank ℝ E * (Module.finrank ℝ E + 1) / 2 ∧
      ∀ a ∈ 𝒜, ⟪a, Ring.inverse (designOperator w) a⟫_ℝ ≤ Module.finrank ℝ E :=
  sorry

/-! ## Layer 9: stochastic linear bandits -/

/-- A linear bandit environment with feature map `φ`, parameter `θ` and conditionally
σ²-sub-Gaussian noise (README Layer 9.1): whatever the history, the observation `o` and the
action `a`, the feedback minus `⟪θ, φ o a⟫` is σ²-sub-Gaussian. -/
def IsSubgaussianLinearEnv {𝓞 𝓐 : Type*} [MeasurableSpace 𝓞] [MeasurableSpace 𝓐]
    (φ : 𝓞 → 𝓐 → E) (θ : E) (σ2 : ℝ≥0) (env : Environment 𝓞 𝓐 ℝ) : Prop :=
  ∀ (n : ℕ) (h : Hist 𝓞 𝓐 ℝ n) (o : 𝓞) (a : 𝓐),
    HasSubgaussianMGF (fun y ↦ y - ⟪θ, φ o a⟫_ℝ) σ2 (env.feedback n ((h, o), a))

end Linear

end LMLRoadmaps.Bandits
