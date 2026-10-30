import Mathlib.InformationTheory.KullbackLeibler.Basic
import Mathlib.MeasureTheory.Measure.Tilted
import Mathlib.Probability.Moments.MGFAnalytic
import LeanMachineLearning.SequentialLearning.FiniteActions
import LeanMachineLearning.SequentialLearning.IdentificationAlg
import LeanMachineLearning.SequentialLearning.IonescuTulceaSpace
import LeanMachineLearning.SequentialLearning.StationaryEnv

/-!
# Bandit identification: suggested target signatures

**This file is not the roadmap and is not exhaustive.** The definitive document is `README.md`.
The statements here suggest Lean forms for particular milestones, so that contributors and
reviewers converge on names and signatures; discharging all of them finishes neither a milestone
nor the roadmap. The admitted proofs are targets, not claimed implementations. The algorithms are
admitted definitions: constructing them as identification algorithms, with their run lemmas, is a
target, and their docstrings and the README specify them.

The names of the LML framework (`IdentAlg`, `stationaryEnv`, `stoppedHistMeasure`, ...) are those
of the LML version pinned by LMLExplore.
-/

noncomputable section

open MeasureTheory ProbabilityTheory InformationTheory Learning Finset Filter Real
open scoped ENNReal NNReal Topology

namespace LMLRoadmaps.Identification

variable {α 𝓨 Θ ℐ : Type*} [Fintype α] [DecidableEq α] [MeasurableSpace α]
  [MeasurableSingletonClass α] [MeasurableSpace 𝓨] [MeasurableSpace ℐ]

/-- The allocations: nonnegative vectors on the arms summing to `1` (README Conventions). -/
def simplex (α : Type*) [Fintype α] : Set (α → ℝ) := {w | (∀ a, 0 ≤ w a) ∧ ∑ a, w a = 1}

/-! ## Layer 0: correctness and sample complexity -/

/-- The joint law of the history at the stopping time and of the output of the identification
algorithm `A` in the environment `env`. -/
def histOutputMeasure (A : IdentAlg Unit α 𝓨 ℐ) (env : Environment Unit α 𝓨) :
    Measure ((Σ n : ℕ, Hist Unit α 𝓨 n) × ℐ) :=
  stoppedHistMeasure A.alg env A.stopSet ⊗ₘ A.output

/-- The expected number of rounds played by `A` in `env` (README Layer 0.3). -/
def expectedStoppingTime (A : IdentAlg Unit α 𝓨 ℐ) (env : Environment Unit α 𝓨) : ℝ≥0∞ :=
  ∫⁻ ω, (A.stoppingTime IT.obs IT.action IT.feedback ω : ℝ≥0∞) ∂(trajMeasure A.alg env)

/-! ## Layer 1: identification tasks and natural exponential families -/

/-- An identification task (README Conventions): models `Θ` with a bandit `ν θ` each, the
admissible models `M` and the set `correct θ` of correct answers of each model. -/
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

/-- The alternatives `¬i` to the answer `i`: the admissible models for which `i` is incorrect. -/
def alt (i : ℐ) : Set Θ := {θ' | θ' ∈ task.M ∧ i ∉ task.correct θ'}

/-- `A` is `δ`-correct on the task [DK19]: on every admissible model, with probability at least
`1 - δ`, it stops and outputs a correct answer. -/
def IsDeltaCorrect (A : IdentAlg Unit α 𝓨 ℐ) (δ : ℝ) : Prop :=
  ∀ θ ∈ task.M, (histOutputMeasure A (stationaryEnv (task.ν θ))).real
    {p | p.1 ∉ A.stopSet ∨ p.2 ∉ task.correct θ} ≤ δ

/-- `A` is `δ`-PAC on the task: it is `δ`-correct and stops almost surely on every admissible
model. -/
def IsDeltaPAC (A : IdentAlg Unit α 𝓨 ℐ) (δ : ℝ) : Prop :=
  task.IsDeltaCorrect A δ ∧ ∀ θ ∈ task.M,
    ∀ᵐ ω ∂(trajMeasure A.alg (stationaryEnv (task.ν θ))),
      A.stoppingTime IT.obs IT.action IT.feedback ω ≠ ⊤

/-! ### The pure exploration game (Layer 3) -/

/-- The transportation cost `∑ a, w a KL(ν_a(θ), ν_a(θ'))` from `θ` to `θ'` with allocation `w`. -/
def cost (w : α → ℝ) (θ θ' : Θ) : ℝ≥0∞ :=
  ∑ a, ENNReal.ofReal (w a) * klDiv (task.ν θ a) (task.ν θ' a)

/-- The cost `D(θ, w, ¬i)` of the alternatives to the answer `i`. -/
def altCost (θ : Θ) (w : α → ℝ) (i : ℐ) : ℝ≥0∞ :=
  ⨅ θ' ∈ task.alt i, task.cost w θ θ'

/-- The value `D(θ, ¬i)` of the pure exploration game of the answer `i`. -/
def answerValue (θ : Θ) (i : ℐ) : ℝ≥0∞ :=
  ⨆ w ∈ simplex α, task.altCost θ w i

/-- The value `D(θ) = max_{i ∈ i*(θ)} D(θ, ¬i)` of the pure exploration game. -/
def gameValue (θ : Θ) : ℝ≥0∞ :=
  ⨆ i ∈ task.correct θ, task.answerValue θ i

/-- The characteristic time `T*(θ) = D(θ)⁻¹`. -/
def charTime (θ : Θ) : ℝ≥0∞ := (task.gameValue θ)⁻¹

/-- The optimal allocations `w*(θ, ¬i)` of the answer `i`. -/
def optAlloc (θ : Θ) (i : ℐ) : Set (α → ℝ) :=
  {w | w ∈ simplex α ∧ task.altCost θ w i = task.answerValue θ i}

/-- The cost of the alternatives is concave in the allocation (README Layer 3.1). -/
theorem concaveOn_altCost (θ : Θ) (i : ℐ) :
    ConcaveOn ℝ≥0 (simplex α) (fun w ↦ task.altCost θ w i) :=
  sorry

end IdentTask

/-- Best arm identification on vectors of means with a unique best arm, for arm laws `κ a x` of
mean `x` in the set `meanSet a` (README Layer 1.1). Ties have no correct answer; the admissible
models have exactly one. -/
def baiTask (κ : α → ℝ → Measure ℝ) [∀ a x, IsProbabilityMeasure (κ a x)]
    (meanSet : α → Set ℝ) : IdentTask α (α → ℝ) α ℝ where
  M := {μ | (∀ a, μ a ∈ meanSet a) ∧ ∃ a, ∀ b ≠ a, μ b < μ a}
  ν μ := Kernel.ofFunOfCountable fun a ↦ κ a (μ a)
  isMarkovKernel_ν μ := ⟨fun a ↦ (inferInstance : IsProbabilityMeasure (κ a (μ a)))⟩
  correct μ := {a | ∀ b ≠ a, μ b < μ a}

/-- The natural exponential family of a probability measure `ρ` on `ℝ`: the tilt of `ρ` with
natural parameter `η` (README Layer 1.2). -/
def natExpFamily (ρ : Measure ℝ) (η : ℝ) : Measure ℝ := ρ.tilted (fun x ↦ η * x)

/-- The relative entropy between two members of a natural exponential family:
`ψ(η') - ψ(η) - ψ'(η) (η' - η)` with `ψ` the cumulant generating function of `ρ`. -/
theorem klDiv_natExpFamily (ρ : Measure ℝ) [IsProbabilityMeasure ρ] {η η' : ℝ}
    (hη : η ∈ interior (integrableExpSet id ρ)) (hη' : η' ∈ interior (integrableExpSet id ρ)) :
    klDiv (natExpFamily ρ η) (natExpFamily ρ η') =
      ENNReal.ofReal (cgf id ρ η' - cgf id ρ η - deriv (cgf id ρ) η * (η' - η)) :=
  sorry

/-! ## Layer 2: change of measure and lower bounds -/

/-- **Transportation lemma** [KCG16, Lemma 1], for an identification algorithm run against two
stationary bandits: for every event `E` of the stopped history and the output, the expected
transportation cost bounds the binary relative entropy of the probabilities of `E`. The binary
relative entropy is written in `ℝ≥0∞` through `klDiv` of two Bernoulli laws. -/
theorem klDiv_bernoulli_le_sum_lintegral_pullCount [MeasurableSpace.CountablyGenerated 𝓨]
    (A : IdentAlg Unit α 𝓨 ℐ) (ν ν' : Kernel α 𝓨) [IsMarkovKernel ν] [IsMarkovKernel ν']
    (hτ : ∀ᵐ ω ∂(trajMeasure A.alg (stationaryEnv ν)),
      A.stoppingTime IT.obs IT.action IT.feedback ω ≠ ⊤)
    {E : Set ((Σ n : ℕ, Hist Unit α 𝓨 n) × ℐ)} (hE : MeasurableSet E) :
    klDiv ((histOutputMeasure A (stationaryEnv ν)).map (· ∈ E))
        ((histOutputMeasure A (stationaryEnv ν')).map (· ∈ E)) ≤
      ∑ a, (∫⁻ ω, (pullCount IT.action a ((A.stoppingTime IT.obs IT.action IT.feedback ω).toNat)
        ω : ℝ≥0∞) ∂(trajMeasure A.alg (stationaryEnv ν))) * klDiv (ν a) (ν' a) :=
  sorry

/-- **Lower bound on the sample complexity** [GK16, Theorem 1]: for a `δ`-correct algorithm with
`δ ≤ 1/2` and an admissible model with a single correct answer,
`E[τ] ≥ T*(θ) kl(δ, 1 - δ)`. -/
theorem charTime_mul_le_expectedStoppingTime [MeasurableSpace.CountablyGenerated 𝓨]
    [MeasurableSingletonClass ℐ] (task : IdentTask α Θ ℐ 𝓨) (A : IdentAlg Unit α 𝓨 ℐ) {δ : ℝ}
    (hδ : δ ∈ Set.Ioc 0 (1 / 2)) (hA : task.IsDeltaCorrect A δ) {θ : Θ} (hθ : θ ∈ task.M)
    {i : ℐ} (hi : task.correct θ = {i}) :
    task.charTime θ * ENNReal.ofReal ((1 - 2 * δ) * log ((1 - δ) / δ)) ≤
      expectedStoppingTime A (stationaryEnv (task.ν θ)) :=
  sorry

/-! ## Layer 5: Track-and-Stop -/

/-- Track-and-Stop with C-tracking of the optimal allocation of best arm identification at the
empirical means and the GLRT stopping rule with threshold `β δ` (README Layer 5.2). -/
def trackAndStop (κ : α → ℝ → Measure ℝ) (meanSet : α → Set ℝ) (β : ℝ → ℕ → ℝ) (δ : ℝ) :
    IdentAlg Unit α ℝ α :=
  sorry

/-- **Asymptotic optimality of Track-and-Stop** [GK16, Theorem 14], for arms in natural
exponential families and the thresholds `β δ t = log (r t / δ)` with `r t = O(t)`. -/
theorem trackAndStop_asymptotic (ρ : α → Measure ℝ) [∀ a, IsProbabilityMeasure (ρ a)]
    (κ : α → ℝ → Measure ℝ) [∀ a x, IsProbabilityMeasure (κ a x)] (meanSet : α → Set ℝ)
    (hκ : ∀ a, ∀ x ∈ meanSet a, ∃ η ∈ interior (integrableExpSet id (ρ a)),
      κ a x = natExpFamily (ρ a) η)
    (r : ℕ → ℝ) (hr : (r · : ℕ → ℝ) =O[atTop] (fun t ↦ (t : ℝ)))
    {μ : α → ℝ} (hμ : μ ∈ (baiTask κ meanSet).M) {c : ℝ≥0}
    (hc : (baiTask κ meanSet).charTime μ < c) :
    ∀ᶠ δ in 𝓝[>] 0, expectedStoppingTime
      (trackAndStop κ meanSet (fun δ t ↦ log (r t / δ)) δ)
      (stationaryEnv ((baiTask κ meanSet).ν μ)) ≤ c * ENNReal.ofReal (log (1 / δ)) :=
  sorry

end LMLRoadmaps.Identification
