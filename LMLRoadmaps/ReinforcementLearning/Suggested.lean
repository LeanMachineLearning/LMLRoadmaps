import Mathlib.Analysis.Normed.Lp.lpSpace
import Mathlib.LinearAlgebra.Matrix.Stochastic
import Mathlib.MeasureTheory.Function.ConditionalLExpectation
import Mathlib.MeasureTheory.Measure.TotalVariation.Defs
import Mathlib.Probability.Kernel.Composition.Prod
import Mathlib.Probability.Kernel.Invariance
import Mathlib.Probability.Moments.SubGaussian
import Mathlib.Probability.Martingale.Basic
import Mathlib.Topology.MetricSpace.Contracting
import LeanMachineLearning.ForMathlib.MeasureTheory.Order.MeasurableArg
import LeanMachineLearning.Online.Bandit.ArrayProbSpace
import LeanMachineLearning.SequentialLearning.Deterministic
import LeanMachineLearning.SequentialLearning.IonescuTulceaSpace
import LeanMachineLearning.SequentialLearning.StationaryEnv
import TauCeti.Probability.Process.MarkovChain

/-!
# Markov decision processes and reinforcement learning theory: suggested target signatures

**This file is not the roadmap and is not exhaustive.** The definitive document is `README.md`.
The statements here suggest Lean forms for particular milestones, so that contributors and
reviewers converge on names and signatures; discharging all of them finishes neither a milestone
nor the roadmap. The admitted proofs are targets, not claimed implementations. Admitted
definitions (algorithms, iterates) are targets too: their docstrings and the README specify them.

`MDP` copies the structure of LML's `mdp` branch (fields `P`, `R`, `MDP.env`), and `EpisodicMDP`
the one of entropy-mdp, so that adopting the upstream versions is a deletion. The other names of
the LML framework are those of the LML version pinned by LMLExplore.
-/

noncomputable section

open MeasureTheory ProbabilityTheory Learning Filter Finset
open scoped ENNReal NNReal Topology

namespace LMLRoadmaps.ReinforcementLearning

/-! ## Layer 0: order units, contractions and fixed points -/

section FixedPoint

variable {ι : Type*} [Fintype ι]

/-- Blackwell's sufficient conditions, on `ι → ℝ` with the sup norm (README Layer 0.2; the README
asks for the order-unit form on ordered vector spaces). -/
theorem lipschitzWith_of_monotone_of_add_const_le {T : (ι → ℝ) → ι → ℝ} {γ : ℝ≥0}
    (hT : Monotone T) (h : ∀ x (c : ℝ), 0 ≤ c → T (x + fun _ ↦ c) ≤ T x + fun _ ↦ γ * c) :
    LipschitzWith γ T :=
  sorry

/-- The oscillation (span seminorm) of a function on a finite type. -/
def osc [Nonempty ι] (x : ι → ℝ) : ℝ := (Finset.univ.sup' Finset.univ_nonempty x) -
  Finset.univ.inf' Finset.univ_nonempty x

/-- Vanishing discount for topical maps (README Layer 0.5). -/
theorem exists_add_eigenvector_of_topical [Nonempty ι] {T : (ι → ℝ) → ι → ℝ} (hT : Monotone T)
    (h_top : ∀ x (c : ℝ), T (x + fun _ ↦ c) = T x + fun _ ↦ c)
    (v : ℝ≥0 → ι → ℝ) (hv : ∀ γ < 1, v γ = T ((γ : ℝ) • v γ))
    (h_bdd : BddAbove (Set.range fun γ : {γ : ℝ≥0 // γ < 1} ↦ osc (v γ))) :
    ∃ (g : ℝ) (h : ι → ℝ), T h = h + fun _ ↦ g :=
  sorry

end FixedPoint

/-! ## Layer 1: Markov processes on general measurable spaces -/

section Markov

variable {α β Ω ι : Type*} [MeasurableSpace α] [MeasurableSpace β] {mΩ : MeasurableSpace Ω}

/-- A process indexed by a preorder is Markov for the filtration `𝓕` with transition kernels
`κ s t`, `s ≤ t` (README Layer 1.1). -/
structure IsMarkovProcess [Preorder ι] (X : ι → Ω → α) (𝓕 : Filtration ι mΩ)
    (κ : ι → ι → Kernel α α) (P : Measure Ω) : Prop where
  measurable : ∀ i, Measurable[𝓕 i] (X i)
  condExp_comp : ∀ s t, s ≤ t → ∀ f : α → ℝ, Measurable f → (∃ C, ∀ x, |f x| ≤ C) →
    P[f ∘ X t | 𝓕 s] =ᵐ[P] fun ω ↦ ∫ y, f y ∂(κ s t (X s ω))

/-- The Dobrushin coefficient of a kernel (README Layer 1.6), with Mathlib's `tvDist` in
`[0, 2]`. -/
def dobrushinCoeff (κ : Kernel α β) : ℝ := ⨆ x, ⨆ y, tvDist (κ x) (κ y) / 2

theorem tvDist_bind_le_dobrushinCoeff_mul (κ : Kernel α β) [IsMarkovKernel κ]
    (μ ν : Measure α) [IsProbabilityMeasure μ] [IsProbabilityMeasure ν] :
    tvDist (μ.bind κ) (ν.bind κ) ≤ dobrushinCoeff κ * tvDist μ ν :=
  sorry

/-- Doeblin: a power with Dobrushin coefficient below one gives a unique invariant probability
and uniform geometric convergence (README Layer 1.6). -/
theorem exists_unique_invariant_of_dobrushinCoeff_pow_lt_one [Nonempty α] (κ : Kernel α α)
    [IsMarkovKernel κ]
    {m : ℕ} (hm : 0 < m) (h : dobrushinCoeff (κ ^ m) < 1) :
    ∃! π : Measure α, IsProbabilityMeasure π ∧ κ.Invariant π ∧
      ∀ n x, tvDist ((κ ^ n) x) π ≤ 2 * dobrushinCoeff (κ ^ m) ^ (n / m) :=
  sorry

/-- The resolvent of a kernel acting on a function (README Layer 1.4). -/
def resolvent (γ : ℝ≥0) (κ : Kernel α α) (f : α → ℝ) (x : α) : ℝ :=
  ∑' n, (γ : ℝ) ^ n * ∫ y, f y ∂((κ ^ n) x)

end Markov

/-! ## Layer 2: mean ergodic theory and finite Markov chains -/

section FiniteChains

variable {S : Type*} [Fintype S] [DecidableEq S]

/-- The limiting matrix `P*` of a matrix: the limit of its Cesàro means (README Layer 2.4). -/
def limitingMatrix (P : Matrix S S ℝ) : Matrix S S ℝ :=
  limUnder atTop fun n : ℕ ↦ (n : ℝ)⁻¹ • ∑ k ∈ range n, P ^ k

theorem tendsto_cesaro_limitingMatrix {P : Matrix S S ℝ} (hP : P ∈ Matrix.rowStochastic ℝ S) :
    Tendsto (fun n : ℕ ↦ (n : ℝ)⁻¹ • ∑ k ∈ range n, P ^ k) atTop (𝓝 (limitingMatrix P)) :=
  sorry

theorem mul_limitingMatrix {P : Matrix S S ℝ} (hP : P ∈ Matrix.rowStochastic ℝ S) :
    P * limitingMatrix P = limitingMatrix P ∧ limitingMatrix P * P = limitingMatrix P :=
  sorry

/-- The deviation matrix `(I - P + P*)⁻¹ - P*` (README Layer 2.2). -/
def deviationMatrix (P : Matrix S S ℝ) : Matrix S S ℝ :=
  (1 - P + limitingMatrix P)⁻¹ - limitingMatrix P

theorem isUnit_one_sub_add_limitingMatrix {P : Matrix S S ℝ} (hP : P ∈ Matrix.rowStochastic ℝ S) :
    IsUnit (1 - P + limitingMatrix P) :=
  sorry

end FiniteChains

/-! ## Layer 3: concentration -/

section Concentration

variable {Ω : Type*} {mΩ : MeasurableSpace Ω} {P : Measure Ω} [IsProbabilityMeasure P]
  {ℱ : Filtration ℕ mΩ}

/-- Freedman's inequality, fixed-`η` time-uniform form (README Layer 3.1). `X t` is
`ℱ (t + 1)`-measurable, with conditional mean at most zero given `ℱ t`, and `η X t ≤ 1`. -/
theorem measure_exists_sum_ge_le_freedman {X : ℕ → Ω → ℝ} {η δ : ℝ} (hη : 0 < η) (hδ : 0 < δ)
    (hδ₁ : δ ≤ 1)
    (h_meas : ∀ t, Measurable[ℱ (t + 1)] (X t)) (h_int : ∀ t, Integrable (fun ω ↦ X t ω ^ 2) P)
    (h_mean : ∀ t, P[X t | ℱ t] ≤ᵐ[P] 0) (h_bdd : ∀ t ω, η * X t ω ≤ 1) :
    P {ω | ∃ n, η * ∑ t ∈ range n, P[fun ω ↦ X t ω ^ 2 | ℱ t] ω + Real.log (1 / δ) / η ≤
      ∑ t ∈ range n, X t ω} ≤ ENNReal.ofReal δ :=
  sorry

/-- The `ℓ¹` deviation of the empirical law on a finite type [WOSVW03] (README Layer 3.3). -/
theorem measure_sum_abs_empirical_sub_ge_le {α : Type*} [Fintype α] [DecidableEq α]
    [MeasurableSpace α] [MeasurableSingletonClass α] (p : Measure α) [IsProbabilityMeasure p]
    {n : ℕ} (hn : 0 < n) {ε : ℝ} (hε : 0 < ε) :
    (Measure.pi fun _ : Fin n ↦ p).real
        {x | ε ≤ ∑ a, |(n : ℝ)⁻¹ * (Finset.univ.filter fun i ↦ x i = a).card - p.real {a}|} ≤
      (2 ^ Fintype.card α - 2) * Real.exp (-n * ε ^ 2 / 2) :=
  sorry

end Concentration

/-! ## Layer 4: stochastic approximation -/

/-- **Robbins–Siegmund** (README Layer 4.1), for processes with values in `ℝ≥0`. -/
theorem robbinsSiegmund {Ω : Type*} {mΩ : MeasurableSpace Ω} {P : Measure Ω}
    [IsProbabilityMeasure P] {ℱ : Filtration ℕ mΩ} {V a b c : ℕ → Ω → ℝ≥0}
    (hV : ∀ n, Measurable[ℱ n] (V n)) (ha : ∀ n, Measurable[ℱ n] (a n))
    (hb : ∀ n, Measurable[ℱ n] (b n)) (hc : ∀ n, Measurable[ℱ n] (c n))
    (h : ∀ n, P⁻[fun ω ↦ (V (n + 1) ω : ℝ≥0∞) | ℱ n] + (fun ω ↦ (c n ω : ℝ≥0∞))
      ≤ᵐ[P] fun ω ↦ (((1 + a n ω) * V n ω + b n ω : ℝ≥0) : ℝ≥0∞)) :
    ∀ᵐ ω ∂P, (Summable fun n ↦ a n ω) → (Summable fun n ↦ b n ω) →
      (∃ l : ℝ≥0, Tendsto (fun n ↦ V n ω) atTop (𝓝 l)) ∧ Summable fun n ↦ c n ω :=
  sorry

/-! ## Layer 5: optimization -/

/-- The softmax of a vector on a finite type (README Layer 5.1). -/
def softmax {α : Type*} [Fintype α] (θ : α → ℝ) (a : α) : ℝ :=
  Real.exp (θ a) / ∑ b, Real.exp (θ b)

/-! ## Layer 7: Markov decision processes, policies and values -/

/-- A Markov decision process: a transition kernel `P` and a reward kernel `R`. This copies the
structure of LML's `mdp` branch. -/
structure MDP (𝓢 𝓐 𝓡 : Type*) [MeasurableSpace 𝓢] [MeasurableSpace 𝓐] [MeasurableSpace 𝓡] where
  /-- The transition kernel. -/
  P : Kernel (𝓢 × 𝓐) 𝓢
  [hP : IsMarkovKernel P]
  /-- The reward kernel. -/
  R : Kernel (𝓢 × 𝓐) 𝓡
  [hR : IsMarkovKernel R]

variable {𝓢 𝓐 : Type*} [MeasurableSpace 𝓢] [MeasurableSpace 𝓐]

namespace MDP

instance (M : MDP 𝓢 𝓐 ℝ) : IsMarkovKernel M.P := M.hP
instance (M : MDP 𝓢 𝓐 ℝ) : IsMarkovKernel M.R := M.hR

open Classical in
/-- The environment of `M` from the initial law `μ₀`: observation = state, feedback = reward
(as on LML's `mdp` branch). -/
protected def env [h𝓢 : Nonempty 𝓢] (M : MDP 𝓢 𝓐 ℝ) (μ₀ : Measure 𝓢) : Environment 𝓢 𝓐 ℝ where
  obs
  | 0 => Kernel.const _ (if IsProbabilityMeasure μ₀ then μ₀ else Measure.dirac h𝓢.some)
  | n + 1 => M.P.comap (fun h ↦ ((h (Fin.last n)).obs, (h (Fin.last n)).action)) (by fun_prop)
  feedback := fun _ ↦ M.R.comap (fun p ↦ (p.1.2, p.2)) (by fun_prop)
  isMarkovKernel_obs n := by
    cases n
    · dsimp only
      split_ifs <;> infer_instance
    · infer_instance

/-- The mean reward `r (s, a)`. -/
def meanReward (R : Kernel (𝓢 × 𝓐) ℝ) (p : 𝓢 × 𝓐) : ℝ := ∫ x, x ∂(R p)

/-- The state kernel of a stationary policy `π`. -/
def stateKernel (M : MDP 𝓢 𝓐 ℝ) (π : Kernel 𝓢 𝓐) [IsMarkovKernel π] : Kernel 𝓢 𝓢 :=
  M.P ∘ₖ (Kernel.id ×ₖ π)

/-- The mean reward of a stationary policy. -/
def policyReward (M : MDP 𝓢 𝓐 ℝ) (π : Kernel 𝓢 𝓐) (s : 𝓢) : ℝ :=
  ∫ a, meanReward M.R (s, a) ∂(π s)

/-- The discounted value `v^π = ∑ γⁿ Pπⁿ rπ` of a stationary policy. -/
def value (M : MDP 𝓢 𝓐 ℝ) (γ : ℝ≥0) (π : Kernel 𝓢 𝓐) [IsMarkovKernel π] (s : 𝓢) : ℝ :=
  ∑' n, (γ : ℝ) ^ n * ∫ s', M.policyReward π s' ∂((M.stateKernel π ^ n) s)

/-- The action value `Q^π = r + γ P v^π`. -/
def qValue (M : MDP 𝓢 𝓐 ℝ) (γ : ℝ≥0) (π : Kernel 𝓢 𝓐) [IsMarkovKernel π] (p : 𝓢 × 𝓐) : ℝ :=
  meanReward M.R p + γ * ∫ s', M.value γ π s' ∂(M.P p)

/-- The discounted value of a run of the algorithm `alg` from the initial law `μ`. -/
def runValue [Nonempty 𝓢] (M : MDP 𝓢 𝓐 ℝ) (γ : ℝ≥0) (alg : Algorithm 𝓢 𝓐 ℝ) (μ : Measure 𝓢) :
    ℝ :=
  ∫ ω, ∑' n, (γ : ℝ) ^ n * meanReward M.R ((ω n).obs, (ω n).action) ∂(trajMeasure alg (M.env μ))

/-- The optimal discounted value. -/
def optValue [Nonempty 𝓢] (M : MDP 𝓢 𝓐 ℝ) (γ : ℝ≥0) (s : 𝓢) : ℝ :=
  ⨆ alg : Algorithm 𝓢 𝓐 ℝ, M.runValue γ alg (Measure.dirac s)

/-- The Bellman optimality operator. -/
def bellman (M : MDP 𝓢 𝓐 ℝ) (γ : ℝ≥0) (v : 𝓢 → ℝ) (s : 𝓢) : ℝ :=
  ⨆ a, (meanReward M.R (s, a) + γ * ∫ s', v s' ∂(M.P (s, a)))

/-- The greedy action for `v`, with LML's measurable `argmax`. -/
def greedy [Fintype 𝓐] [Nonempty 𝓐] (M : MDP 𝓢 𝓐 ℝ) (γ : ℝ≥0) (v : 𝓢 → ℝ) (s : 𝓢) : 𝓐 :=
  argmax fun a ↦ meanReward M.R (s, a) + γ * ∫ s', v s' ∂(M.P (s, a))

/-- The discounted state–action occupancy measure of a run (README Layer 11.1). -/
def occupancy [Nonempty 𝓢] (M : MDP 𝓢 𝓐 ℝ) (γ : ℝ≥0) (alg : Algorithm 𝓢 𝓐 ℝ)
    (μ : Measure 𝓢) : Measure (𝓢 × 𝓐) :=
  (1 - γ : ℝ≥0∞) • Measure.sum fun n ↦ ((γ : ℝ≥0∞) ^ n) •
    (trajMeasure alg (M.env μ)).map fun ω ↦ ((ω n).obs, (ω n).action)

end MDP

/-- A Markov policy as an algorithm: it plays `π n` at the current observation. -/
def _root_.Learning.Algorithm.markov {𝓞 𝓨 : Type*} [MeasurableSpace 𝓞] [MeasurableSpace 𝓨]
    (π : ℕ → Kernel 𝓞 𝓐) [∀ n, IsMarkovKernel (π n)] : Algorithm 𝓞 𝓐 𝓨 where
  policy n := (π n).comap Prod.snd measurable_snd

/-- A finite-horizon MDP with ℕ-indexed transition and reward kernels (entropy-mdp). -/
structure EpisodicMDP (𝓢 𝓐 : Type*) [MeasurableSpace 𝓢] [MeasurableSpace 𝓐] where
  /-- The transition kernel at step `h`. -/
  trans : ℕ → Kernel (𝓢 × 𝓐) 𝓢
  [isMarkovKernel_trans : ∀ h, IsMarkovKernel (trans h)]
  /-- The reward kernel at step `h`. -/
  reward : ℕ → Kernel (𝓢 × 𝓐) ℝ
  [isMarkovKernel_reward : ∀ h, IsMarkovKernel (reward h)]

namespace MDP

variable [Nonempty 𝓢] (M : MDP 𝓢 𝓐 ℝ) {γ : ℝ≥0}

/-! ## Layers 9–10: discounted optimality and algorithms -/

/-- The optimality equation (README Layer 9.4). -/
theorem bellman_optValue [Fintype 𝓐] [Nonempty 𝓐] [MeasurableSingletonClass 𝓐]
    (hγ : γ < 1) (hR : ∃ C, ∀ p, ∀ᵐ x ∂(M.R p), |x| ≤ C) :
    M.bellman γ (M.optValue γ) = M.optValue γ :=
  sorry

/-- Uniqueness of bounded measurable solutions of the optimality equation (README Layer 9.4). -/
theorem eq_optValue_of_bellman_eq [Fintype 𝓐] [Nonempty 𝓐] [MeasurableSingletonClass 𝓐]
    (hγ : γ < 1) (hR : ∃ C, ∀ p, ∀ᵐ x ∂(M.R p), |x| ≤ C) {v : 𝓢 → ℝ} (hv : Measurable v)
    (hv_bdd : ∃ C, ∀ s, |v s| ≤ C) (h : M.bellman γ v = v) :
    v = M.optValue γ :=
  sorry

/-- The greedy policy for `v*` is optimal (README Layer 9.4). -/
theorem value_greedy_optValue [Fintype 𝓐] [Nonempty 𝓐] [MeasurableSingletonClass 𝓐]
    (hγ : γ < 1) (hR : ∃ C, ∀ p, ∀ᵐ x ∂(M.R p), |x| ≤ C)
    (hg : Measurable (M.greedy γ (M.optValue γ))) :
    M.value γ (Kernel.deterministic (M.greedy γ (M.optValue γ)) hg) = M.optValue γ :=
  sorry

/-- Value iteration (README Layer 10.1, [P, Theorem 6.3.3 (d)]). -/
theorem abs_bellman_iterate_sub_optValue_le [Fintype 𝓐] [Nonempty 𝓐] [MeasurableSingletonClass 𝓐]
    (hγ : γ < 1) (hR : ∃ C, ∀ p, ∀ᵐ x ∂(M.R p), |x| ≤ C) {v : 𝓢 → ℝ} (hv : Measurable v)
    {B : ℝ} (hB : ∀ s, |M.bellman γ v s - v s| ≤ B) (n : ℕ) (s : 𝓢) :
    |(M.bellman γ)^[n] v s - M.optValue γ s| ≤ γ ^ n * B / (1 - γ) :=
  sorry

/-! ## Layers 11–12: occupancy measures and the value-difference calculus -/

/-- The value of a run is the integral of the mean reward against the occupancy measure
(README Layer 11.1). -/
theorem runValue_eq_integral_occupancy (hγ : γ < 1)
    (hR : ∃ C, ∀ p, ∀ᵐ x ∂(M.R p), |x| ≤ C) (alg : Algorithm 𝓢 𝓐 ℝ) (μ : Measure 𝓢)
    [IsProbabilityMeasure μ] :
    M.runValue γ alg μ = (1 - γ : ℝ)⁻¹ * ∫ p, meanReward M.R p ∂(M.occupancy γ alg μ) :=
  sorry

/-- The flow equation of occupancy measures (README Layer 11.1). -/
theorem occupancy_map_fst (hγ : γ < 1) (alg : Algorithm 𝓢 𝓐 ℝ) (μ : Measure 𝓢)
    [IsProbabilityMeasure μ] :
    (M.occupancy γ alg μ).map Prod.fst =
      (1 - γ : ℝ≥0∞) • μ + (γ : ℝ≥0∞) • (M.occupancy γ alg μ).bind M.P :=
  sorry

/-- The performance difference lemma (README Layer 12.2, [AJKS, Lemma 1.16]). -/
theorem runValue_sub_integral_value (hγ : γ < 1) (hR : ∃ C, ∀ p, ∀ᵐ x ∂(M.R p), |x| ≤ C)
    (alg : Algorithm 𝓢 𝓐 ℝ) (π : Kernel 𝓢 𝓐) [IsMarkovKernel π] (μ : Measure 𝓢)
    [IsProbabilityMeasure μ] :
    M.runValue γ alg μ - ∫ s, M.value γ π s ∂μ =
      (1 - γ : ℝ)⁻¹ * ∫ p, (M.qValue γ π p - M.value γ π p.1) ∂(M.occupancy γ alg μ) :=
  sorry

end MDP

/-! ## Layer 13: average reward and sensitive discount optimality -/

namespace MDP

variable [Fintype 𝓢] [Nonempty 𝓢] [MeasurableSingletonClass 𝓢] [Fintype 𝓐] [Nonempty 𝓐]
  [MeasurableSingletonClass 𝓐] (M : MDP 𝓢 𝓐 ℝ)

/-- The gain of a stationary policy: the Cesàro limit of the expected rewards
(README Layer 13.1). -/
def gain (π : Kernel 𝓢 𝓐) [IsMarkovKernel π] (s : 𝓢) : ℝ :=
  limUnder atTop fun N : ℕ ↦ (N : ℝ)⁻¹ *
    ∑ n ∈ range N, ∫ s', M.policyReward π s' ∂((M.stateKernel π ^ n) s)

/-- Existence of a deterministic stationary Blackwell-optimal policy (README Layer 13.7,
[P, Theorem 10.1.4]). -/
theorem exists_blackwell_optimal :
    ∃ d : 𝓢 → 𝓐, ∃ γ₀ : ℝ≥0, γ₀ < 1 ∧ ∀ γ : ℝ≥0, γ₀ ≤ γ → γ < 1 →
      ∀ s, M.value γ (Kernel.deterministic d (measurable_of_finite d)) s = M.optValue γ s :=
  sorry

end MDP

/-! ## Layer 15: planning with a generative model -/

section Generative

variable [Fintype 𝓢] [Nonempty 𝓢] [MeasurableSingletonClass 𝓢] [Fintype 𝓐] [Nonempty 𝓐]
  [MeasurableSingletonClass 𝓐]

/-- The empirical transition kernel of `N` samples per pair of the generative model `ω`
(README Layer 14.3). -/
def empiricalKernel (N : ℕ) (ω : ℕ → 𝓢 × 𝓐 → 𝓢) : Kernel (𝓢 × 𝓐) 𝓢 :=
  Kernel.ofFunOfCountable fun p ↦ (N : ℝ≥0∞)⁻¹ • ∑ i ∈ range N, Measure.dirac (ω i p)

/-- The empirical MDP, with the rewards of `M`. -/
def MDP.empirical (M : MDP 𝓢 𝓐 ℝ) {N : ℕ} (hN : 0 < N) (ω : ℕ → 𝓢 × 𝓐 → 𝓢) : MDP 𝓢 𝓐 ℝ where
  P := empiricalKernel N ω
  hP := sorry
  R := M.R

/-- The optimal action value `Q* = r + γ P v*`. -/
def MDP.optQValue (M : MDP 𝓢 𝓐 ℝ) (γ : ℝ≥0) (p : 𝓢 × 𝓐) : ℝ :=
  MDP.meanReward M.R p + γ * ∫ s', M.optValue γ s' ∂(M.P p)

/-- The plug-in policy is minimax optimal [AKY20, Theorem 1] (README Layer 15.3): with probability
at least `1 - δ`, every `εopt`-optimal stationary policy of the empirical MDP is
`(ε + 9 εopt / (1 - γ))`-optimal in `M`. -/
theorem exists_const_qValue_ge_of_empirical :
    ∃ C > 0, ∀ (M : MDP 𝓢 𝓐 ℝ) (r : 𝓢 × 𝓐 → ℝ) (hr : Measurable r),
      M.R = Kernel.deterministic r hr → (∀ p, r p ∈ Set.Icc 0 1) →
      ∀ (γ : ℝ≥0), 1 / 2 ≤ γ → γ < 1 → ∀ δ ε εopt : ℝ, 0 < δ → δ < 1 → 0 < ε →
      ε ≤ Real.sqrt (1 / (1 - γ)) → ∀ (N : ℕ) (hN : 0 < N),
      C * γ * Real.log (C * Fintype.card 𝓢 * Fintype.card 𝓐 / ((1 - γ) * δ)) /
        ((1 - γ) ^ 3 * ε ^ 2) ≤ N →
      1 - δ ≤ (Bandits.streamMeasure M.P).real {ω | ∀ (π : Kernel 𝓢 𝓐) [IsMarkovKernel π],
        (∀ p, |(M.empirical hN ω).qValue γ π p - (M.empirical hN ω).optQValue γ p| ≤ εopt) →
        ∀ p, M.optQValue γ p - ε - 9 * εopt / (1 - γ) ≤ M.qValue γ π p} :=
  sorry

end Generative

/-! ## Layer 17: policy optimization -/

section PolicyOptimization

variable [Fintype 𝓢] [Nonempty 𝓢] [MeasurableSingletonClass 𝓢] [Fintype 𝓐] [Nonempty 𝓐]
  [MeasurableSingletonClass 𝓐]

/-- The softmax policy of parameters `θ`. -/
def softmaxPolicy (θ : 𝓢 → 𝓐 → ℝ) : Kernel 𝓢 𝓐 :=
  Kernel.ofFunOfCountable fun s ↦ ∑ a, ENNReal.ofReal (softmax (θ s) a) • Measure.dirac a

instance (θ : 𝓢 → 𝓐 → ℝ) : IsMarkovKernel (softmaxPolicy θ) := sorry

/-- The natural policy gradient iterates with step `η` from `θ₀ = 0`: in every state, the
multiplicative-weights update on `A^{π_t} / (1 - γ)` [AKLM21, Lemma 5.1] (README Layer 17.5). -/
def npgParam (M : MDP 𝓢 𝓐 ℝ) (γ : ℝ≥0) (η : ℝ) : ℕ → 𝓢 → 𝓐 → ℝ
  | 0 => 0
  | t + 1 => fun s a ↦ npgParam M γ η t s a + η / (1 - γ) *
      (M.qValue γ (softmaxPolicy (npgParam M γ η t)) (s, a) -
        M.value γ (softmaxPolicy (npgParam M γ η t)) s)

/-- Global convergence of natural policy gradient [AKLM21, Theorem 5.3] (README Layer 17.5). -/
theorem value_npg_ge (M : MDP 𝓢 𝓐 ℝ) {γ : ℝ≥0} (hγ : γ < 1) (r : 𝓢 × 𝓐 → ℝ) (hr : Measurable r)
    (hMR : M.R = Kernel.deterministic r hr) (hr01 : ∀ p, r p ∈ Set.Icc 0 1) {η : ℝ} (hη : 0 < η)
    (ρ : Measure 𝓢) [IsProbabilityMeasure ρ] {T : ℕ} (hT : 0 < T) :
    ∫ s, M.optValue γ s ∂ρ - Real.log (Fintype.card 𝓐) / (η * T) - 1 / ((1 - γ) ^ 2 * T) ≤
      ∫ s, M.value γ (softmaxPolicy (npgParam M γ η T)) s ∂ρ :=
  sorry

end PolicyOptimization

end LMLRoadmaps.ReinforcementLearning
