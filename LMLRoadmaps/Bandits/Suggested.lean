import Mathlib.Analysis.Calculus.IteratedDeriv.Defs
import Mathlib.Analysis.InnerProductSpace.Positive
import Mathlib.Geometry.Convex.ConvexSpace.Defs
import Mathlib.InformationTheory.KullbackLeibler.Basic
import Mathlib.MeasureTheory.Measure.Tilted
import Mathlib.Probability.Distributions.Bernoulli
import Mathlib.Probability.Distributions.Gaussian.Real
import Mathlib.Probability.Martingale.Basic
import Mathlib.Probability.Moments.Basic
import Mathlib.Probability.Moments.IntegrableExpMul
import LeanMachineLearning.ForMathlib.Analysis.Convex.Bregman.Basic
import LeanMachineLearning.ForMathlib.MeasureTheory.Order.MeasurableArg
import LeanMachineLearning.Online.Bandit.Algorithms.Regret.UCB
import LeanMachineLearning.Online.Bandit.Regret
import LeanMachineLearning.SequentialLearning.Deterministic
import LeanMachineLearning.SequentialLearning.EvaluationEnv
import LeanMachineLearning.SequentialLearning.FiniteActions
import LeanMachineLearning.SequentialLearning.IonescuTulceaSpace
import LeanMachineLearning.SequentialLearning.Means
import LeanMachineLearning.SequentialLearning.StationaryEnv
import LeanMachineLearning.SequentialLearning.SumRewards
import TauCeti.Analysis.InnerProductSpace.MoorePenrose

/-!
# Bandit algorithms and their regret: suggested target signatures

**This file is not the roadmap and is not exhaustive.** The definitive document is `README.md`.
The statements here suggest Lean forms for particular milestones, so that contributors and
reviewers converge on names and signatures; discharging all of them finishes neither a milestone
nor the roadmap. The admitted proofs are targets, not claimed implementations. The algorithms are
admitted definitions: constructing them, with their run lemmas, is a target, and their docstrings
and the README specify them.

The names of the LML framework (`stationaryEnv`, `onlineEvalEnv`, `detAlgorithm`, ...) are those
of the LML version pinned by LMLExplore. Exponential families are written here through their
natural parameters with Mathlib's `Measure.tilted` and `cgf`; the mean parametrization and the
rate function are the Identification roadmap's (Layer 1.2).
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

/-- The pseudo-regret of a run against an adaptive adversary `env` (README Conventions and
Layer 0.5): `max_a E[∑_{t < n} (m_t(a) - Y t)]`, with `m_t(a) = env.means O A Y a t` the mean reward
of arm `a` at round `t` given the past. -/
def pseudoRegret {𝓞 : Type*} [MeasurableSpace 𝓞] (env : Environment 𝓞 α ℝ) (O : ℕ → Ω → 𝓞)
    (A : ℕ → Ω → α) (Y : ℕ → Ω → ℝ) (P : Measure Ω) (n : ℕ) : ℝ :=
  ⨆ a, P[fun ω ↦ ∑ t ∈ range n, (env.means O A Y a t ω - Y t ω)]

/-- The random regret of a run against an adaptive adversary `env`:
`max_a ∑_{t < n} (m_t(a) - Y t)`. -/
def randomRegret {𝓞 : Type*} [MeasurableSpace 𝓞] (env : Environment 𝓞 α ℝ) (O : ℕ → Ω → 𝓞)
    (A : ℕ → Ω → α) (Y : ℕ → Ω → ℝ) (n : ℕ) (ω : Ω) : ℝ :=
  ⨆ a, ∑ t ∈ range n, (env.means O A Y a t ω - Y t ω)

/-- Against an oblivious reward table, the pseudo-regret is the adversarial regret `R_n(x)`. -/
theorem pseudoRegret_onlineEvalEnv (x : ℕ → α → ℝ) {alg : Algorithm Unit α ℝ}
    {O : ℕ → Ω → Unit} {A : ℕ → Ω → α} {Y : ℕ → Ω → ℝ}
    (h : IsAlgEnvSeq O A Y alg (onlineEvalEnv x fun t ↦ measurable_of_countable (x t)) P)
    (n : ℕ) :
    pseudoRegret (onlineEvalEnv x fun t ↦ measurable_of_countable (x t)) O A Y P n =
      advRegret x A P n :=
  sorry

/-- Against a stochastic bandit, the pseudo-regret is the expected stochastic regret. -/
theorem pseudoRegret_stationaryEnv {ν : Kernel α ℝ} [IsMarkovKernel ν]
    (hν : ∀ a, Integrable id (ν a)) {alg : Algorithm Unit α ℝ}
    {O : ℕ → Ω → Unit} {A : ℕ → Ω → α} {Y : ℕ → Ω → ℝ}
    (h : IsAlgEnvSeq O A Y alg (stationaryEnv ν) P) (n : ℕ) :
    pseudoRegret (stationaryEnv ν) O A Y P n = P[Bandits.regret ν A n] :=
  sorry

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

/-- Asymptotically optimal UCB [LS, Algorithm 6]: KL-UCB for the Gaussian family of variance
`σ2` (`klucbFam_gaussianReal`). -/
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

/-! ## Layer 3: KL-UCB for exponential families -/

/-- The KL-UCB upper confidence level `U_ρ(x, c)` of the natural exponential family of `ρ`
(README Layer 3.1), written through the natural parameters with `ψ = cgf id ρ`: the supremum of
`x` and of the means `ψ'(θ) ≥ x` of the members `ρ.tilted (θ * ·)` whose Cramér–Chernoff rate
function at `x`, `sup_{θ'} ((θ' - θ) x - ψ(θ') + ψ(θ))`, is at most `c`. -/
def expFamilyUpper (ρ : Measure ℝ) (x : ℝ) (c : ℝ≥0∞) : EReal :=
  sSup (insert (x : EReal) ((fun θ ↦ ((deriv (cgf id ρ) θ : ℝ) : EReal)) ''
    {θ | θ ∈ interior (integrableExpSet id ρ) ∧ x ≤ deriv (cgf id ρ) θ ∧
      (⨆ θ' ∈ integrableExpSet id ρ,
        ENNReal.ofReal ((θ' - θ) * x - cgf id ρ θ' + cgf id ρ θ)) ≤ c}))

/-- The Gaussian level: `U(x, c) = x + √(2 σ² c)`. -/
theorem expFamilyUpper_gaussianReal {σ2 : ℝ≥0} (hσ2 : σ2 ≠ 0) (x : ℝ) (c : ℝ≥0) :
    expFamilyUpper (gaussianReal 0 σ2) x c = ((x + √(2 * σ2 * c) : ℝ) : EReal) :=
  sorry

/-- The index of KL-UCB for the families `ρ a` [LS, Algorithm 8; GC11, Section 4] at Lean
round `n`. -/
def klucbFamIndex (ρ : α → Measure ℝ) (n : ℕ) (h : Hist Unit α ℝ n) (a : α) : EReal :=
  if pullCount' n h a = 0 then ⊤ else
    expFamilyUpper (ρ a) (empMean' n h a)
      (ENNReal.ofReal (log (1 + (n + 1) * log (n + 1) ^ 2) / pullCount' n h a))

/-- KL-UCB for the natural exponential families `ρ a` (README Layer 3.3). -/
def klucbFam (ρ : α → Measure ℝ) : Algorithm Unit α ℝ :=
  indexAlgorithm (fun n x ↦ klucbFamIndex ρ n x.1) (fun n ↦ sorry)

/-- Asymptotically optimal UCB is KL-UCB for the Gaussian family of variance `σ2`. -/
theorem klucbFam_gaussianReal {σ2 : ℝ≥0} (hσ2 : σ2 ≠ 0) :
    klucbFam (fun _ : α ↦ gaussianReal 0 σ2) = ucbF σ2 :=
  sorry

/-- The asymptotic regret of KL-UCB for arms dominated by members of their families
(README Layer 3.4): arm `a` has its exponential moments bounded by those of the member of natural
parameter `θ a`, and `θ' a` is the natural parameter of the largest mean in the family of `a`. -/
theorem klucbFam_regret_eventually_le (ρ : α → Measure ℝ) [∀ a, IsProbabilityMeasure (ρ a)]
    {ν : Kernel α ℝ} [IsMarkovKernel ν] {O : ℕ → Ω → Unit} {A : ℕ → Ω → α} {R : ℕ → Ω → ℝ}
    (h : IsAlgEnvSeq O A R (klucbFam ρ) (stationaryEnv ν) P)
    (θ : α → ℝ) (hθ : ∀ a, θ a ∈ interior (integrableExpSet id (ρ a)))
    (hdom : ∀ a, ∀ t ∈ integrableExpSet id ((ρ a).tilted fun x ↦ θ a * x),
      t ∈ integrableExpSet id (ν a) ∧ mgf id (ν a) t ≤ mgf id ((ρ a).tilted fun x ↦ θ a * x) t)
    (θ' : α → ℝ) (hθ' : ∀ a, θ' a ∈ interior (integrableExpSet id (ρ a)) ∧
      deriv (cgf id (ρ a)) (θ' a) = ⨆ b, (ν b)[id])
    {c : ℝ} (hc : ∑ a ∈ univ.filter (fun a ↦ 0 < Bandits.gap ν a),
      Bandits.gap ν a / (klDiv ((ρ a).tilted fun x ↦ θ a * x)
        ((ρ a).tilted fun x ↦ θ' a * x)).toReal < c) :
    ∀ᶠ n : ℕ in atTop, P[Bandits.regret ν A n] ≤ c * log n :=
  sorry

section KLUCB

variable {O : ℕ → Ω → Unit} {A : ℕ → Ω → α} {R : ℕ → Ω → ℝ} {ν : Kernel α ℝ} [IsMarkovKernel ν]

/-- The KL-UCB index for rewards in `[0, 1]` [LS, Algorithm 8] at Lean round `n`. -/
def klucbIndex (n : ℕ) (h : Hist Unit α ℝ n) (a : α) : EReal :=
  if pullCount' n h a = 0 then ⊤ else
    ((klUpper (empMean' n h a)
      (ENNReal.ofReal (log (1 + (n + 1) * log (n + 1) ^ 2) / pullCount' n h a)) : ℝ) : EReal)

/-- At empirical means in `[0, 1]`, the KL-UCB index of the Bernoulli family is the index of
[LS, Algorithm 8]. -/
theorem klucbFamIndex_bernoulli {n : ℕ} {h : Hist Unit α ℝ n} {a : α}
    (hmean : empMean' n h a ∈ Set.Icc 0 1) :
    klucbFamIndex (fun _ : α ↦ bernoulliMeasure (1 : ℝ) 0 ⟨2⁻¹, by norm_num, by norm_num⟩) n h a =
      klucbIndex n h a :=
  sorry

/-- KL-UCB for rewards in `[0, 1]` [LS, Algorithm 8]: KL-UCB for the Bernoulli family on every
arm (README Layer 3.3). -/
def klucb : Algorithm Unit α ℝ :=
  klucbFam fun _ ↦ bernoulliMeasure (1 : ℝ) 0 ⟨2⁻¹, by norm_num, by norm_num⟩

/-- The asymptotic part of [LS, Theorem 10.6], for rewards in `[0, 1]`. -/
theorem klucb_regret_eventually_le (h : IsAlgEnvSeq O A R klucb (stationaryEnv ν) P)
    (hν : ∀ a, ∀ᵐ x ∂(ν a), x ∈ Set.Icc (0 : ℝ) 1) {c : ℝ}
    (hc : ∑ a ∈ univ.filter (fun a ↦ 0 < Bandits.gap ν a),
      Bandits.gap ν a / (klBer (ν a)[id] (⨆ b, (ν b)[id])).toReal < c) :
    ∀ᶠ n : ℕ in atTop, P[Bandits.regret ν A n] ≤ c * log n :=
  sorry

end KLUCB

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

/-- `d_inf` for a natural exponential family [BK96]: for members of natural parameters `θ ≤ θ'`,
the infimum over the members with mean above the mean `ψ'(θ')` is the divergence from the member
of parameter `θ` to that of parameter `θ'`. -/
theorem dInf_range_tilted (ρ : Measure ℝ) [IsProbabilityMeasure ρ] (hρ : ∀ x, ρ ≠ Measure.dirac x)
    {θ θ' : ℝ} (hθ : θ ∈ interior (integrableExpSet id ρ))
    (hθ' : θ' ∈ interior (integrableExpSet id ρ)) (hle : θ ≤ θ') :
    dInf (Set.range fun η : interior (integrableExpSet id ρ) ↦ ρ.tilted fun x ↦ η * x)
        (ρ.tilted fun x ↦ θ * x) (deriv (cgf id ρ) θ') =
      klDiv (ρ.tilted fun x ↦ θ * x) (ρ.tilted fun x ↦ θ' * x) :=
  sorry

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

/-! ## Layer 5: Thompson sampling -/

/-- The Jeffreys prior `√ψ''(θ) dθ` of the natural exponential family of `ρ`, on the interior of
its natural-parameter set [KKM13, Section 2]. -/
def jeffreysPrior (ρ : Measure ℝ) : Measure ℝ :=
  (volume.restrict (interior (integrableExpSet id ρ))).withDensity
    fun θ ↦ ENNReal.ofReal √(iteratedDeriv 2 (cgf id ρ) θ)

/-- Thompson sampling for the natural exponential families `ρ a` with priors `prior a` on the
natural parameters (README Layer 5.1): a follow-the-perturbed-leader policy that samples the mean
of a natural parameter drawn from the posterior of each pulled arm, `+∞` for unpulled arms. -/
def expFamilyTS (ρ prior : α → Measure ℝ) : Algorithm Unit α ℝ :=
  sorry

/-! ## Layer 6: online linear optimization -/

section OnlineLinear

variable {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]

/-- The regret bound of follow-the-regularized-leader [LS, Theorem 28.5], on a normed space with
losses `y t` in the dual, for a potential with a derivative `F' t` within `K` at each play; each
play `a t ∈ K` minimizes `b ↦ η ∑_{s<t} y s b + F b` over `K`. -/
theorem ftrl_regret_le {F : E → ℝ} {K : Set E} (hK : Convex ℝ K) {η : ℝ} (hη : 0 < η)
    (y : ℕ → E →L[ℝ] ℝ) (a : ℕ → E) {n : ℕ} (ha_mem : ∀ t ≤ n, a t ∈ K)
    (ha : ∀ t ≤ n, IsMinOn (fun b ↦ η * ∑ s ∈ range t, y s b + F b) K (a t))
    (F' : ℕ → E →L[ℝ] ℝ) (hF' : ∀ t < n, HasFDerivWithinAt F (F' t) K (a t)) {u : E}
    (hu : u ∈ K) :
    ∑ t ∈ range n, y t (a t - u) ≤
      (F u - F (a 0)) / η + ∑ t ∈ range n, y t (a t - a (t + 1)) -
        (∑ t ∈ range n, bregDiv F (a (t + 1)) (a t) (F' t)) / η :=
  sorry

/-- The regret bound of follow-the-regularized-leader with regularizers `ψ t` nondecreasing in `t`
on `K` (README Layer 6.3); each play `a t ∈ K` minimizes `b ↦ ∑_{s<t} y s b + ψ t b` over `K`.
With `ψ t = F / η t` this is the anytime form of `ftrl_regret_le`. -/
theorem ftrl_regret_le_of_monotone {ψ : ℕ → E → ℝ} {K : Set E} (hK : Convex ℝ K)
    (hψ : ∀ t, ∀ b ∈ K, ψ t b ≤ ψ (t + 1) b)
    (y : ℕ → E →L[ℝ] ℝ) (a : ℕ → E) {n : ℕ} (ha_mem : ∀ t ≤ n, a t ∈ K)
    (ha : ∀ t ≤ n, IsMinOn (fun b ↦ ∑ s ∈ range t, y s b + ψ t b) K (a t))
    (ψ' : ℕ → E →L[ℝ] ℝ) (hψ' : ∀ t < n, HasFDerivWithinAt (ψ t) (ψ' t) K (a t)) {u : E}
    (hu : u ∈ K) :
    ∑ t ∈ range n, y t (a t - u) ≤
      ψ n u - ψ 0 (a 0) +
        ∑ t ∈ range n, (y t (a t - a (t + 1)) - bregDiv (ψ t) (a (t + 1)) (a t) (ψ' t)) :=
  sorry

end OnlineLinear

/-! ## Layer 7: adversarial bandits with finitely many arms -/

/-- Exp4-IX [Neu15] with the advice map `adv` from observations to the advice of the experts `β`,
learning rates `η` and implicit-exploration parameters `γ` (README Layer 7.2): exponential
weights on the experts of their estimated losses, and the arm drawn from the mixture of their
advice. -/
def exp4IX {𝓞 β : Type*} [MeasurableSpace 𝓞] [Fintype β] (adv : 𝓞 → β → α → ℝ)
    (hadv : Measurable adv) (η γ : ℕ → ℝ) : Algorithm 𝓞 α ℝ :=
  sorry

/-- Exp3 with learning rates `η` [LS, Algorithm 9]: Exp4-IX with the experts `α`, expert `b`
advising the arm `b`, and no implicit exploration. -/
def exp3 {𝓞 : Type*} [MeasurableSpace 𝓞] (η : ℕ → ℝ) : Algorithm 𝓞 α ℝ :=
  exp4IX (fun _ b ↦ Pi.single b 1) measurable_const η 0

/-- The pseudo-regret of Exp3 against an adaptive adversary with feedback in `[0, 1]`, for
nonincreasing learning rates (README Layer 7.3); a constant `η = √(2 log k / (n k))` gives
[LS, Theorem 11.2] and `η t = √(log k / (k (t + 1)))` gives [BCB12, Theorem 3.1]. -/
theorem exp3_pseudoRegret_le {𝓞 : Type*} [MeasurableSpace 𝓞] {env : Environment 𝓞 α ℝ}
    (henv : ∀ n x, ∀ᵐ y ∂(env.feedback n x), y ∈ Set.Icc (0 : ℝ) 1)
    {η : ℕ → ℝ} (hη : ∀ t, 0 < η t) (hη_anti : Antitone η)
    {O : ℕ → Ω → 𝓞} {A : ℕ → Ω → α} {Y : ℕ → Ω → ℝ}
    (h : IsAlgEnvSeq O A Y (exp3 η) env P) (n : ℕ) :
    pseudoRegret env O A Y P n ≤
      log (Fintype.card α) / η (n - 1) + Fintype.card α / 2 * ∑ t ∈ range n, η t :=
  sorry

/-! ## Layer 8: least squares, self-normalized bounds and optimal design -/

section Linear

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [FiniteDimensional ℝ E]

/-- The design operator `V_t(V₀) = V₀ + ∑_{s < t} x s ⊗ x s`; `V_t(λ)` is
`designOp (lam • ContinuousLinearMap.id ℝ E) x t`. -/
def designOp (V₀ : E →L[ℝ] E) (x : ℕ → E) (t : ℕ) : E →L[ℝ] E :=
  V₀ + ∑ s ∈ range t, (innerSL ℝ (x s)).smulRight (x s)

/-- The elliptical potential lemma [LS, Lemma 19.4] for `V_0 = λ • id`. -/
theorem sum_min_one_inner_inverse_designOp_le {lam : ℝ} (hlam : 0 < lam) (x : ℕ → E) {L : ℝ}
    (hx : ∀ t, ‖x t‖ ≤ L) (n : ℕ) :
    ∑ t ∈ range n, min 1
        ⟪x t, Ring.inverse (designOp (lam • ContinuousLinearMap.id ℝ E) x t) (x t)⟫_ℝ ≤
      2 * Module.finrank ℝ E * log (1 + n * L ^ 2 / (Module.finrank ℝ E * lam)) :=
  sorry

/-- The self-normalized bound for vector-valued martingales [AYPS11, Theorem 1], with a positive
definite regularizer `V₀` and conditionally σ²-sub-Gaussian noise; [LS, Theorem 20.4] is the case
`V₀ = λ • id`. -/
theorem measure_exists_inner_inverse_designOp_ge_le [StandardBorelSpace Ω]
    {𝓕 : Filtration ℕ mΩ} {x : ℕ → Ω → E} {η : ℕ → Ω → ℝ} {σ2 : ℝ≥0}
    (hx : ∀ t, StronglyMeasurable[𝓕 t] (x t)) (hη : ∀ t, StronglyMeasurable[𝓕 (t + 1)] (η t))
    (hsub : ∀ t, HasCondSubgaussianMGF (𝓕 t) (𝓕.le t) (η t) σ2 P)
    {V₀ : E →L[ℝ] E} (hV₀ : V₀.IsPositive) (hV₀_unit : IsUnit V₀) {δ : ℝ} (hδ : δ ∈ Set.Ioo 0 1) :
    P {ω | ∃ t, 2 * σ2 * log (1 / δ) +
        σ2 * log (LinearMap.det (designOp V₀ (fun s ↦ x s ω) t).toLinearMap /
          LinearMap.det V₀.toLinearMap) ≤
      ⟪∑ s ∈ range t, η s ω • x s ω,
        Ring.inverse (designOp V₀ (fun s ↦ x s ω) t) (∑ s ∈ range t, η s ω • x s ω)⟫_ℝ} ≤
      ENNReal.ofReal δ :=
  sorry

/-- The design operator `V(w) = ∑_a w a • a ⊗ a` of a finitely supported design `w` on `E`. -/
def designOperator (w : Convexity.StdSimplex ℝ E) : E →L[ℝ] E :=
  w.weights.sum fun a c ↦ c • (innerSL ℝ a).smulRight a

/-- The design operator of the image of a design on finitely many arms by a feature map. -/
theorem designOperator_map {ι : Type*} [Fintype ι] (φ : ι → E) (w : Convexity.StdSimplex ℝ ι) :
    designOperator (w.map φ) = ∑ i, w.weights i • (innerSL ℝ (φ i)).smulRight (φ i) :=
  sorry

/-- The Kiefer–Wolfowitz theorem on the span of a compact set [LS, Theorem 21.1, Exercises 21.3
and 21.6]: a design with small support whose G-value, computed with the Moore–Penrose inverse, is
the dimension of the span. -/
theorem exists_design_inner_moorePenroseInverse_le_finrank {𝒜 : Set E} (h𝒜 : IsCompact 𝒜)
    (h𝒜_ne : ∃ a ∈ 𝒜, a ≠ 0) :
    ∃ w : Convexity.StdSimplex ℝ E, (w.weights.support : Set E) ⊆ 𝒜 ∧
      w.weights.support.card ≤
        Module.finrank ℝ (Submodule.span ℝ 𝒜) * (Module.finrank ℝ (Submodule.span ℝ 𝒜) + 1) / 2 ∧
      ∀ a ∈ 𝒜, ⟪a, (designOperator w : E →ₗ[ℝ] E).moorePenroseInverse a⟫_ℝ ≤
        Module.finrank ℝ (Submodule.span ℝ 𝒜) :=
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
