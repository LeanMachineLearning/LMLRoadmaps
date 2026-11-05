import Mathlib.Analysis.InnerProductSpace.Basic
import Mathlib.InformationTheory.KullbackLeibler.Basic
import Mathlib.MeasureTheory.Measure.ProbabilityMeasure
import Mathlib.MeasureTheory.Measure.Tilted
import Mathlib.Probability.Martingale.Basic
import Mathlib.Probability.Moments.MGFAnalytic
import Mathlib.Probability.Moments.SubGaussian
import Mathlib.Probability.Process.Stopping
import TauCeti.Analysis.Convex.Conjugate
import LeanMachineLearning.ForMathlib.Analysis.Convex.Bregman.Basic
import LeanMachineLearning.Online.Bandit.ArrayProbSpace
import LeanMachineLearning.SequentialLearning.Comap
import LeanMachineLearning.SequentialLearning.FiniteActions
import LeanMachineLearning.SequentialLearning.IdentificationAlg
import LeanMachineLearning.SequentialLearning.IonescuTulceaSpace
import LeanMachineLearning.SequentialLearning.Means
import LeanMachineLearning.SequentialLearning.StationaryEnv
import LeanMachineLearning.SequentialLearning.SumRewards

/-!
# Bandit identification: suggested target signatures

**This file is not the roadmap and is not exhaustive.** The definitive document is `README.md`.
The statements here suggest Lean forms for particular milestones, so that contributors and
reviewers converge on names and signatures; discharging all of them finishes neither a milestone
nor the roadmap. The admitted proofs are targets, not claimed implementations. The algorithms and
the helper `armObs` are admitted definitions: constructing them, with their run lemmas, is a
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

/-- **Wald's identity for the feedback**, for every environment (README Layer 0.3): for a stopping
time `τ` of the filtration of the actions with `E[τ] < ∞`, and conditional absolute means of the
feedback bounded by `C`, `E[∑_{t < τ} Y t] = E[∑_{t < τ} m_t(A t)]` with LML's conditional means
`env.means`. -/
theorem integral_sum_feedback_eq_integral_sum_means {Ω 𝓞 𝓐 : Type*} [MeasurableSpace Ω]
    [MeasurableSpace 𝓞] [MeasurableSpace 𝓐] {P : Measure Ω} [IsProbabilityMeasure P]
    {O : ℕ → Ω → 𝓞} {A : ℕ → Ω → 𝓐} {Y : ℕ → Ω → ℝ} {alg : Algorithm 𝓞 𝓐 ℝ}
    {env : Environment 𝓞 𝓐 ℝ} (h : IsAlgEnvSeq O A Y alg env P) {τ : Ω → ℕ∞}
    (hτ : IsStoppingTime h.filtrationAction τ) (hτ_int : ∫⁻ ω, (τ ω : ℝ≥0∞) ∂P ≠ ∞) {C : ℝ}
    (hC : ∀ n, ∀ᵐ ω ∂P, ∫ y, |y| ∂(env.measure O A Y n ω (A n ω)) ≤ C) :
    ∫ ω, ∑ t ∈ range (τ ω).toNat, Y t ω ∂P =
      ∫ ω, ∑ t ∈ range (τ ω).toNat, env.means O A Y (A t ω) t ω ∂P :=
  sorry

/-! ## Layer 1: identification tasks, exponential families and product models -/

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

/-- The pullback of a task along `f : Θ' → Θ` (README Layer 1.1): the bandit, the admissibility
and the correct answers of `θ'` are those of `f θ'`. -/
def comap {Θ' : Type*} (f : Θ' → Θ) : IdentTask α Θ' ℐ 𝓨 where
  M := f ⁻¹' task.M
  ν := task.ν ∘ f
  isMarkovKernel_ν θ' := task.isMarkovKernel_ν (f θ')
  correct := task.correct ∘ f

/-- A `δ`-correct algorithm for a task is `δ`-correct for its pullbacks (README Layer 1.1). -/
theorem IsDeltaCorrect.comap {A : IdentAlg Unit α 𝓨 ℐ} {δ : ℝ} (h : task.IsDeltaCorrect A δ)
    {Θ' : Type*} (f : Θ' → Θ) : (task.comap f).IsDeltaCorrect A δ :=
  sorry

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

/-- Pulling a task back can only make the alternatives more expensive (README Layer 3.1). -/
theorem altCost_le_altCost_comap {Θ' : Type*} (f : Θ' → Θ) (θ' : Θ') (w : α → ℝ) (i : ℐ) :
    task.altCost (f θ') w i ≤ (task.comap f).altCost θ' w i :=
  sorry

end IdentTask

/-- Best arm identification for models `Θ` with bandits `ν` and mean functional `mean`
(README Layer 1.1): the correct answer of `θ` is the arm with the largest mean `mean θ a`, and the
admissible models are those where it is unique. The task on vectors of means is
`Θ = α → ℝ`, `mean = id`. -/
def baiTask (ν : Θ → Kernel α 𝓨) [∀ θ, IsMarkovKernel (ν θ)] (mean : Θ → α → ℝ) :
    IdentTask α Θ α 𝓨 where
  M := {θ | ∃ a, ∀ b ≠ a, mean θ b < mean θ a}
  ν := ν
  isMarkovKernel_ν _ := inferInstance
  correct θ := {a | ∀ b ≠ a, mean θ b < mean θ a}

/-- The bandit of a product model (README Layer 1.4): arm `a` of the model `θ : α → Θ₀` has law
`κ a (θ a)`. -/
def productBandit {Θ₀ : Type*} (κ : α → Θ₀ → Measure 𝓨) (θ : α → Θ₀) : Kernel α 𝓨 :=
  Kernel.ofFunOfCountable fun a ↦ κ a (θ a)

instance {Θ₀ : Type*} (κ : α → Θ₀ → Measure 𝓨) [∀ a x, IsProbabilityMeasure (κ a x)]
    (θ : α → Θ₀) : IsMarkovKernel (productBandit κ θ) :=
  ⟨fun a ↦ (inferInstance : IsProbabilityMeasure (κ a (θ a)))⟩

/-- Best arm identification on the model of all bandits with σ²-sub-Gaussian real observations
(README Layer 1.1): a model is the vector of the arm laws, and its mean functional their means.
The guarantees of the elimination algorithms (README Layer 7) are stated on this task. -/
def subgaussianBaiTask (σ2 : ℝ≥0) : IdentTask α (α → ProbabilityMeasure ℝ) α ℝ where
  M := (baiTask (productBandit fun _ (P : ProbabilityMeasure ℝ) ↦ (P : Measure ℝ))
      (fun θ a ↦ ∫ x, x ∂(θ a : Measure ℝ))).M ∩
    {θ | ∀ a, HasSubgaussianMGF (fun x ↦ x - ∫ y, y ∂(θ a : Measure ℝ)) σ2 (θ a : Measure ℝ)}
  ν := productBandit fun _ (P : ProbabilityMeasure ℝ) ↦ (P : Measure ℝ)
  isMarkovKernel_ν _ := inferInstance
  correct θ := {a | ∀ b ≠ a, ∫ x, x ∂(θ b : Measure ℝ) < ∫ x, x ∂(θ a : Measure ℝ)}

/-- `K⁻(x, u)`: the smallest divergence from `κ x` to a law `κ y`, `y ∈ S`, of mean `m y ≤ u`
(README Layer 1.4). -/
def kInfLower {Θ₀ : Type*} (κ : Θ₀ → Measure 𝓨) (S : Set Θ₀) (m : Θ₀ → ℝ) (x : Θ₀) (u : ℝ) :
    ℝ≥0∞ :=
  ⨅ y ∈ {y ∈ S | m y ≤ u}, klDiv (κ x) (κ y)

/-- `K⁺(x, u)`: the smallest divergence from `κ x` to a law `κ y`, `y ∈ S`, of mean `m y ≥ u`
(README Layer 1.4). -/
def kInfUpper {Θ₀ : Type*} (κ : Θ₀ → Measure 𝓨) (S : Set Θ₀) (m : Θ₀ → ℝ) (x : Θ₀) (u : ℝ) :
    ℝ≥0∞ :=
  ⨅ y ∈ {y ∈ S | u ≤ m y}, klDiv (κ x) (κ y)

/-- The cost of the alternatives of best arm identification on a product model, for a positive
allocation [AJG20; JDK23a, (1)] (README Layer 1.4): the infimum over the models where some arm
`b ≠ a` is at least as good as `a` is `min_{b ≠ a} inf_u (w a K⁻_a(θ a, u) + w b K⁺_b(θ b, u))`. -/
theorem iInf_cost_baiTask_productBandit {Θ₀ : Type*} (κ : α → Θ₀ → Measure 𝓨)
    [∀ a x, IsProbabilityMeasure (κ a x)] (S : α → Set Θ₀) (m : α → Θ₀ → ℝ) {θ : α → Θ₀}
    (hθ : ∀ c, θ c ∈ S c) {w : α → ℝ} (hw : ∀ c, 0 < w c) (a : α) :
    ⨅ θ' ∈ {θ' : α → Θ₀ | (∀ c, θ' c ∈ S c) ∧ ∃ b ≠ a, m a (θ' a) ≤ m b (θ' b)},
        (baiTask (productBandit κ) fun θ c ↦ m c (θ c)).cost w θ θ' =
      ⨅ (b) (_ : b ≠ a), ⨅ u : ℝ,
        (ENNReal.ofReal (w a) * kInfLower (κ a) (S a) (m a) (θ a) u +
          ENNReal.ofReal (w b) * kInfUpper (κ b) (S b) (m b) (θ b) u) :=
  sorry

/-- The exponential family of a measure `ρ` on `𝓧` with statistic `T`: the tilt of `ρ` with
natural parameter `η` (README Layer 1.2). The natural exponential families of measures on `ℝ`
are the case `T = id`. -/
def expFamily {𝓧 : Type*} [MeasurableSpace 𝓧] (ρ : Measure 𝓧) (T : 𝓧 → ℝ) (η : ℝ) :
    Measure 𝓧 :=
  ρ.tilted (fun x ↦ η * T x)

/-- The relative entropy between two members of an exponential family:
`ψ(η') - ψ(η) - ψ'(η) (η' - η)` with `ψ` the cumulant generating function of `T` under `ρ`. -/
theorem klDiv_expFamily {𝓧 : Type*} [MeasurableSpace 𝓧] (ρ : Measure 𝓧) [IsProbabilityMeasure ρ]
    {T : 𝓧 → ℝ} (hT : Measurable T) {η η' : ℝ} (hη : η ∈ interior (integrableExpSet T ρ))
    (hη' : η' ∈ interior (integrableExpSet T ρ)) :
    klDiv (expFamily ρ T η) (expFamily ρ T η') =
      ENNReal.ofReal (cgf T ρ η' - cgf T ρ η - deriv (cgf T ρ) η * (η' - η)) :=
  sorry

/-- The Cramér rate function `I_X(x) = sup_t (t x - Λ_X(t))` of a real random variable `X` under
`P`, in `ℝ≥0∞` (README Layer 1.2). For the statistic of an exponential family under its member of
mean `μ`, it is the divergence `d(x, μ)` on the means and its generalized likelihood ratio
extension `d̄(x, μ)` elsewhere. -/
def rateFunction {Ω : Type*} [MeasurableSpace Ω] (X : Ω → ℝ) (P : Measure Ω) (x : ℝ) : ℝ≥0∞ :=
  ⨆ t ∈ integrableExpSet X P, ENNReal.ofReal (t * x - cgf X P t)

open Classical in
/-- The rate function is Tau Ceti's Fenchel conjugate, for the pairing `(t, x) ↦ t * x`, of the
cumulant generating function extended by `⊤` outside `integrableExpSet X P`. -/
theorem coe_rateFunction_eq_fenchelConjugate {Ω : Type*} [MeasurableSpace Ω] (X : Ω → ℝ)
    (P : Measure Ω) [IsProbabilityMeasure P] (x : ℝ) :
    (rateFunction X P x : EReal) = TauCeti.fenchelConjugate (LinearMap.mul ℝ ℝ)
      (fun t ↦ if t ∈ integrableExpSet X P then (cgf X P t : EReal) else ⊤) x :=
  sorry

/-! ## Layer 1.3: exponential families with a vector statistic -/

section VectorStatistic

variable {𝓧 E : Type*} [MeasurableSpace 𝓧] [NormedAddCommGroup E] [InnerProductSpace ℝ E]
  [FiniteDimensional ℝ E] [MeasurableSpace E] [BorelSpace E]

/-- The member of natural parameter `η` of the exponential family of `ρ` with a statistic `T` in
a finite-dimensional inner product space (README Layer 1.3). -/
def vecExpFamily (ρ : Measure 𝓧) (T : 𝓧 → E) (η : E) : Measure 𝓧 :=
  ρ.tilted (fun x ↦ inner ℝ η (T x))

/-- The log-partition function `ψ(η) = log ∫ exp ⟪η, T⟫ dρ`. -/
def vecLogPartition (ρ : Measure 𝓧) (T : 𝓧 → E) (η : E) : ℝ :=
  log (∫ x, exp (inner ℝ η (T x)) ∂ρ)

/-- The relative entropy between two members of a vector exponential family is the Bregman
divergence of the log-partition function [BMDG05] (README Layer 1.3). -/
theorem klDiv_vecExpFamily (ρ : Measure 𝓧) [IsProbabilityMeasure ρ] {T : 𝓧 → E}
    (hT : Measurable T) {η η' : E}
    (hη : η ∈ interior {η | Integrable (fun x ↦ exp (inner ℝ η (T x))) ρ})
    (hη' : η' ∈ interior {η | Integrable (fun x ↦ exp (inner ℝ η (T x))) ρ}) :
    klDiv (vecExpFamily ρ T η) (vecExpFamily ρ T η') =
      ENNReal.ofReal (bregDiv (vecLogPartition ρ T) η' η (fderiv ℝ (vecLogPartition ρ T) η)) :=
  sorry

end VectorStatistic

/-! ## Layer 2: change of measure and lower bounds -/

/-- The `t`-round histories along which the stopping rule `S` has not stopped: none of their
prefixes belongs to `S` (LMLExplore's `notStoppedSet`). -/
def notStoppedSet {𝓞 𝓐 : Type*} (S : Set (Σ n : ℕ, Hist 𝓞 𝓐 𝓨 n)) (t : ℕ) :
    Set (Hist 𝓞 𝓐 𝓨 t) :=
  {h | ∀ m (hm : m ≤ t), (⟨m, fun i ↦ h (Fin.castLE hm i)⟩ : Σ n : ℕ, Hist 𝓞 𝓐 𝓨 n) ∉ S}

/-- **Chain rule at a stopping time** [GMS19; KCG16, Lemma 1] (README Layer 2.1), for any two
algorithm-environment pairs: the divergence between the laws of the stopped histories is at most
the sum over the rounds of the divergences of the step kernels at the histories not yet stopped.
Equality holds when the hitting time is also almost surely finite under the second pair. -/
theorem klDiv_stoppedHistMeasure_le_tsum {𝓞 𝓐 : Type*} [MeasurableSpace 𝓞] [MeasurableSpace 𝓐]
    (alg alg' : Algorithm 𝓞 𝓐 𝓨) (env env' : Environment 𝓞 𝓐 𝓨)
    {S : Set (Σ n : ℕ, Hist 𝓞 𝓐 𝓨 n)} (hS : MeasurableSet S)
    (hτ : ∀ᵐ ω ∂(trajMeasure alg env),
      hittingAfter (sigmaHistory IT.obs IT.action IT.feedback) S 0 ω ≠ ⊤) :
    klDiv (stoppedHistMeasure alg env S) (stoppedHistMeasure alg' env' S) ≤
      ∑' t, klDiv
        (((trajMeasure alg env).map (history IT.obs IT.action IT.feedback t)).restrict
          (notStoppedSet S t) ⊗ₘ stepKernel alg env t)
        (((trajMeasure alg env).map (history IT.obs IT.action IT.feedback t)).restrict
          (notStoppedSet S t) ⊗ₘ stepKernel alg' env' t) :=
  sorry

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
`δ ≤ 1/2` and an admissible model with a single correct answer, in any task,
`E[τ] ≥ T*(θ) kl(δ, 1 - δ)`. -/
theorem charTime_mul_le_expectedStoppingTime [MeasurableSpace.CountablyGenerated 𝓨]
    [MeasurableSingletonClass ℐ] (task : IdentTask α Θ ℐ 𝓨) (A : IdentAlg Unit α 𝓨 ℐ) {δ : ℝ}
    (hδ : δ ∈ Set.Ioc 0 (1 / 2)) (hA : task.IsDeltaCorrect A δ) {θ : Θ} (hθ : θ ∈ task.M)
    {i : ℐ} (hi : task.correct θ = {i}) :
    task.charTime θ * ENNReal.ofReal ((1 - 2 * δ) * log ((1 - δ) / δ)) ≤
      expectedStoppingTime A (stationaryEnv (task.ν θ)) :=
  sorry

/-! ## Layer 3: continuity on product models -/

/-- **Continuity of the cost of any set of alternatives on a product model** (README Layer 3.3,
[DK19, Theorem 23, Lemmas 24–27]): if the per-arm divergences are finite and continuous on
`S a ×ˢ S a`, and their sublevel sets in the second argument are locally uniformly contained in
compact subsets of `S a`, then `(θ, w) ↦ inf_{θ' ∈ A} cost_θ(w, θ')` is continuous on the models
of `∏ a, S a` and the nonnegative allocations, for every set `A` of alternatives. -/
theorem continuousOn_iInf_cost_productBandit {Θ₀ : Type*} [TopologicalSpace Θ₀]
    (κ : α → Θ₀ → Measure 𝓨) [∀ a x, IsProbabilityMeasure (κ a x)] (S : α → Set Θ₀)
    (hfin : ∀ a, ∀ x ∈ S a, ∀ y ∈ S a, klDiv (κ a x) (κ a y) ≠ ∞)
    (hcont : ∀ a, ContinuousOn (fun p : Θ₀ × Θ₀ ↦ klDiv (κ a p.1) (κ a p.2)) (S a ×ˢ S a))
    (hcomp : ∀ a, ∀ x ∈ S a, ∃ U ∈ 𝓝[S a] x, ∀ r : ℝ≥0∞, r ≠ ∞ →
      ∃ K, IsCompact K ∧ K ⊆ S a ∧ {y ∈ S a | ∃ x' ∈ U, klDiv (κ a x') (κ a y) ≤ r} ⊆ K)
    (A : Set (α → Θ₀)) (hA : A ⊆ Set.univ.pi S) :
    ContinuousOn (fun p : (α → Θ₀) × (α → ℝ) ↦
        ⨅ θ' ∈ A, ∑ a, ENNReal.ofReal (p.2 a) * klDiv (κ a (p.1 a)) (κ a (θ' a)))
      (Set.univ.pi S ×ˢ {w | 0 ≤ w}) :=
  sorry

/-! ## Layer 4: the per-arm streams, conditional domination and GLR stopping rules -/

/-- The observations of arm `a` before round `t`, in the order of the pulls (README Layer 4.1). -/
def armObs {Ω : Type*} (A : ℕ → Ω → α) (Y : ℕ → Ω → 𝓨) (a : α) (t : ℕ) (ω : Ω) :
    Fin (pullCount A a t ω) → 𝓨 :=
  sorry

/-- **Event transfer to the per-arm streams** (README Layer 4.1): in a run of any algorithm
against a stationary bandit with observations in any measurable space, the probability that a
property `q` of the pull counts and of the observations of each arm so far holds at some round is
at most the probability that it holds for some numbers of pulls in the stream model. -/
theorem measure_exists_armObs_le_streamMeasure {Ω : Type*} [MeasurableSpace Ω]
    {P : Measure Ω} [IsProbabilityMeasure P] {O : ℕ → Ω → Unit} {A : ℕ → Ω → α}
    {Y : ℕ → Ω → 𝓨} {alg : Algorithm Unit α 𝓨} {ν : Kernel α 𝓨} [IsMarkovKernel ν]
    (h : IsAlgEnvSeq O A Y alg (stationaryEnv ν) P)
    (q : (s : α → ℕ) → ((a : α) → Fin (s a) → 𝓨) → Prop) :
    P {ω | ∃ t, q (fun a ↦ pullCount A a t ω) (fun a ↦ armObs A Y a t ω)} ≤
      Bandits.streamMeasure ν {x | ∃ s : α → ℕ, q s (fun a i ↦ x i a)} :=
  sorry

section CondDomination

variable {Ω Ω' : Type*} {mΩ : MeasurableSpace Ω} {mΩ' : MeasurableSpace Ω'}

/-- The moment generating function of `X` under the kernel `κ` is bounded by `exp ψ` on `Λ`,
`ν`-almost everywhere (README Layer 4.2), in the pattern of Mathlib's `Kernel.HasSubgaussianMGF`. -/
structure Kernel.HasCGFBound (X : Ω → ℝ) (ψ : ℝ → ℝ) (Λ : Set ℝ) (κ : Kernel Ω' Ω)
    (ν : Measure Ω') : Prop where
  integrable_exp_mul : ∀ t ∈ Λ, Integrable (fun ω ↦ exp (t * X ω)) (κ ∘ₘ ν)
  mgf_le : ∀ᵐ ω' ∂ν, ∀ t ∈ Λ, mgf X (κ ω') t ≤ exp (ψ t)

/-- The moment generating function of `X` under `P` is bounded by `exp ψ` on `Λ`. With `ψ` the
cumulant generating function of `Y` under `Q` on `[0, ∞) ∩ integrableExpSet Y Q`, this is
LMLExplore's `MGFDominatedAbove X P Y Q`. -/
structure HasCGFBound (X : Ω → ℝ) (ψ : ℝ → ℝ) (Λ : Set ℝ) (P : Measure Ω) : Prop where
  integrable_exp_mul : ∀ t ∈ Λ, Integrable (fun ω ↦ exp (t * X ω)) P
  mgf_le : ∀ t ∈ Λ, mgf X P t ≤ exp (ψ t)

/-- The conditional moment generating function of `X` given `m` is bounded by `exp ψ` on `Λ`,
`μ`-almost surely: the kernel version for `condExpKernel μ m`, as for `HasCondSubgaussianMGF`. -/
def HasCondCGFBound {Ω₀ : Type*} (m : MeasurableSpace Ω₀) {mΩ₀ : MeasurableSpace Ω₀}
    (hm : m ≤ mΩ₀) [StandardBorelSpace Ω₀] (X : Ω₀ → ℝ) (ψ : ℝ → ℝ) (Λ : Set ℝ)
    (μ : Measure Ω₀) [IsFiniteMeasure μ] : Prop :=
  Kernel.HasCGFBound X ψ Λ (condExpKernel μ m) (μ.trim hm)

/-- Mathlib's conditionally sub-Gaussian random variables are the case `ψ t = c t² / 2`. -/
theorem hasCondCGFBound_iff_hasCondSubgaussianMGF {Ω₀ : Type*} (m : MeasurableSpace Ω₀)
    {mΩ₀ : MeasurableSpace Ω₀} (hm : m ≤ mΩ₀) [StandardBorelSpace Ω₀] (X : Ω₀ → ℝ) (c : ℝ≥0)
    (μ : Measure Ω₀) [IsFiniteMeasure μ] :
    HasCondCGFBound m hm X (fun t ↦ c * t ^ 2 / 2) Set.univ μ ↔ HasCondSubgaussianMGF m hm X c μ :=
  sorry

/-- **Exponential supermartingale** [HRMS20] (README Layer 4.2): if `X n` is conditionally
`ψ`-bounded on `Λ` given `ℱ n` and `B n ∈ ℱ n` are predictable events (for bandits,
`{A n = a}`), then `exp (∑_{k < n, B k} (t X k - ψ t))` is a supermartingale for `t ∈ Λ`. -/
theorem supermartingale_exp_sum_of_hasCondCGFBound [StandardBorelSpace Ω] {P : Measure Ω}
    [IsProbabilityMeasure P] {ℱ : Filtration ℕ mΩ} {X : ℕ → Ω → ℝ} {B : ℕ → Set Ω}
    {ψ : ℝ → ℝ} {Λ : Set ℝ} (hX : ∀ n, StronglyMeasurable[ℱ (n + 1)] (X n))
    (hcond : ∀ n, HasCondCGFBound (ℱ n) (ℱ.le n) (X n) ψ Λ P)
    (hB : ∀ n, MeasurableSet[ℱ n] (B n)) {t : ℝ} (ht : t ∈ Λ) :
    Supermartingale
      (fun n ω ↦ exp (∑ k ∈ range n, (B k).indicator (fun ω ↦ t * X k ω - ψ t) ω)) ℱ P :=
  sorry

/-- **Cramér–Chernoff bound with the rate function** (README Layer 1.2), at every level above
the mean, for independent variables dominated above by `Y`. -/
theorem measureReal_sum_ge_le_exp_of_le_rateFunction {P : Measure Ω} [IsProbabilityMeasure P]
    {Q : Measure Ω'} [IsProbabilityMeasure Q] {X : ℕ → Ω → ℝ} {Y : Ω' → ℝ} (hY : Integrable Y Q)
    (h_indep : iIndepFun X P)
    (hdom : ∀ i, HasCGFBound (X i) (cgf Y Q) (Set.Ici 0 ∩ integrableExpSet Y Q) P)
    (s : Finset ℕ) {x r : ℝ} (hx : ∫ y, Y y ∂Q ≤ x) (hr : ENNReal.ofReal r ≤ rateFunction Y Q x) :
    P.real {ω | #s * x ≤ ∑ i ∈ s, X i ω} ≤ exp (-(#s * r)) :=
  sorry

end CondDomination

/-! ## Layer 5: Track-and-Stop -/

/-- The empirical mean of the statistic `T a` over the observations of arm `a` in the history
`h` (zero if `a` was not pulled). -/
def empMeanStat (T : α → 𝓨 → ℝ) (n : ℕ) (h : Hist Unit α 𝓨 n) (a : α) : ℝ :=
  empMean' n (Hist.map id id (T a) h) a

/-- The generalized likelihood ratio evidence against the vector of means `l` for arms in per-arm
exponential families (README Layer 4.3): `∑ a, N_a d̄_a(μ̂_a, l a)`, where `d̄_a(x, l a)` is the
rate function of `T a` under the arm law `κ a (l a)` (README Layer 1.2). -/
def expFamilyEvidence (κ : α → ℝ → Measure 𝓨) (T : α → 𝓨 → ℝ) (n : ℕ) (h : Hist Unit α 𝓨 n)
    (l : α → ℝ) : ℝ≥0∞ :=
  ∑ a, (pullCount' n h a : ℝ≥0∞) * rateFunction (T a) (κ a (l a)) (empMeanStat T n h a)

/-- Track-and-Stop (README Layers 4.3 and 5.2) for a task, an estimator `est n h` of the model, a
target map `w` (a measurable selection of the optimal allocations) and a recommendation `rec`:
C-tracking of `w (est n h)`, and the GLRT that stops after `n` rounds with history `h` when
`inf_{θ' ∈ ¬rec (est n h)} Z n h θ' > β δ n h`, with thresholds depending on the round and the
history, and answers `rec (est n h)`. -/
def trackAndStop (task : IdentTask α Θ ℐ 𝓨) (est : (n : ℕ) → Hist Unit α 𝓨 n → Θ)
    (w : Θ → α → ℝ) (rec : Θ → ℐ) (Z : (n : ℕ) → Hist Unit α 𝓨 n → Θ → ℝ≥0∞)
    (β : ℝ → (n : ℕ) → Hist Unit α 𝓨 n → ℝ≥0∞) (δ : ℝ) : IdentAlg Unit α 𝓨 ℐ :=
  sorry

/-- **Asymptotic optimality of Track-and-Stop** [GK16, Theorem 14; DK19, Theorem 7], on every
single-answer task whose models are vectors of means of per-arm exponential families `(ρ a, T a)`
on `𝓨`, with the empirical means of the statistics as estimator, the generalized likelihood ratio
evidence, a target map with values in the optimal allocations and the correct answer as
recommendation, for thresholds `β δ n h ≤ log (r n / δ)` with `r n = O(n ^ p)`, whatever the
history: `E[τ_δ] ≤ c log (1 / δ)` for small `δ`, for every `c > T*(μ)`. -/
theorem trackAndStop_asymptotic (task : IdentTask α (α → ℝ) ℐ 𝓨) (ρ : α → Measure 𝓨)
    [∀ a, IsProbabilityMeasure (ρ a)] (T : α → 𝓨 → ℝ) (hT : ∀ a, Measurable (T a))
    (κ : α → ℝ → Measure 𝓨) [∀ a x, IsProbabilityMeasure (κ a x)] (S : α → Set ℝ)
    (hκ : ∀ a, ∀ x ∈ S a, ∃ η ∈ interior (integrableExpSet (T a) (ρ a)),
      κ a x = expFamily (ρ a) (T a) η ∧ ∫ y, T a y ∂(κ a x) = x)
    (hν : task.ν = productBandit κ) (hM : task.M ⊆ Set.univ.pi S)
    (hsingle : ∀ θ ∈ task.M, ∃ i, task.correct θ = {i})
    (w : (α → ℝ) → α → ℝ) (hw_meas : Measurable w) (rec : (α → ℝ) → ℐ)
    (hw : ∀ θ ∈ task.M, ∀ i ∈ task.correct θ, rec θ = i ∧ w θ ∈ task.optAlloc θ i)
    (β : ℝ → (n : ℕ) → Hist Unit α 𝓨 n → ℝ≥0∞) {p : ℝ} (r : ℕ → ℝ)
    (hr : r =O[atTop] (fun n ↦ (n : ℝ) ^ p))
    (hβ : ∀ δ n h, β δ n h ≤ ENNReal.ofReal (log (r n / δ)))
    {μ : α → ℝ} (hμ : μ ∈ task.M) {c : ℝ≥0} (hc : task.charTime μ < c) :
    ∀ᶠ δ in 𝓝[>] 0, expectedStoppingTime
      (trackAndStop task (empMeanStat T) w rec (expFamilyEvidence κ T) β δ)
      (stationaryEnv (task.ν μ)) ≤ c * ENNReal.ofReal (log (1 / δ)) :=
  sorry

end LMLRoadmaps.Identification
