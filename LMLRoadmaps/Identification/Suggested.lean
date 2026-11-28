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
import Statlib.EValues.DPI

/-!
# Bandit identification: suggested target signatures

**This file is not the roadmap and is not exhaustive.** The definitive document is `README.md`.
The statements here suggest Lean forms for particular milestones, so that contributors and
reviewers converge on names and signatures; discharging all of them finishes neither a milestone
nor the roadmap. The admitted proofs are targets, not claimed implementations. The algorithms and
the helper `armObs` are admitted definitions: constructing them, with their run lemmas, is a
target, and their docstrings and the README specify them.

The names of the LML framework (`IdentAlg`, `Environment.bandit`, `stoppedHistMeasure`, ...) are
those of the LML version pinned by LMLExplore. The designs of the EValues roadmap's Layer 6.4
(`designLaw`, `designValue`, `designRate`, `designGrowth`) are restated in the present form of
LMLExplore's, with Statlib's `maxUtility` and `logUtility`, so that this file imports only Mathlib,
LML (with Statlib) and Tau Ceti.
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
  ∫⁻ ω, ENat.toENNReal (A.stoppingTime IT.obs IT.action IT.feedback ω) ∂(trajMeasure A.alg env)

/-- **Wald's identity for the feedback**, for every environment (README Layer 0.3): for a stopping
time `τ` of the filtration of the actions with `E[τ] < ∞`, and conditional absolute means of the
feedback bounded by `C`, `E[∑_{t < τ} Y t] = E[∑_{t < τ} m_t(A t)]` with LML's conditional means
`env.means`. -/
theorem integral_sum_feedback_eq_integral_sum_means {Ω 𝓞 𝓐 : Type*} [MeasurableSpace Ω]
    [MeasurableSpace 𝓞] [MeasurableSpace 𝓐] {P : Measure Ω} [IsProbabilityMeasure P]
    {O : ℕ → Ω → 𝓞} {A : ℕ → Ω → 𝓐} {Y : ℕ → Ω → ℝ} {alg : Algorithm 𝓞 𝓐 ℝ}
    {env : Environment 𝓞 𝓐 ℝ} (h : IsAlgEnvSeq O A Y alg env P) {τ : Ω → ℕ∞}
    (hτ : IsStoppingTime h.filtrationAction τ) (hτ_int : ∫⁻ ω, (τ ω : ℝ≥0∞) ∂P ≠ ∞) {C : ℝ}
    (hC : ∀ n, ∀ᵐ ω ∂P, ∫ y, |y| ∂(env.feedbackKernel O A Y n ω (A n ω)) ≤ C) :
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
  ∀ θ ∈ task.M, (histOutputMeasure A (Environment.bandit (task.ν θ))).real
    {p | p.1 ∉ A.stopSet ∨ p.2 ∉ task.correct θ} ≤ δ

/-- `A` is `δ`-PAC on the task: it is `δ`-correct and stops almost surely on every admissible
model. -/
def IsDeltaPAC (A : IdentAlg Unit α 𝓨 ℐ) (δ : ℝ) : Prop :=
  task.IsDeltaCorrect A δ ∧ ∀ θ ∈ task.M,
    ∀ᵐ ω ∂(trajMeasure A.alg (Environment.bandit (task.ν θ))),
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
    (hτ : ∀ᵐ ω ∂(trajMeasure A.alg (Environment.bandit ν)),
      A.stoppingTime IT.obs IT.action IT.feedback ω ≠ ⊤)
    {E : Set ((Σ n : ℕ, Hist Unit α 𝓨 n) × ℐ)} (hE : MeasurableSet E) :
    klDiv ((histOutputMeasure A (Environment.bandit ν)).map (· ∈ E))
        ((histOutputMeasure A (Environment.bandit ν')).map (· ∈ E)) ≤
      ∑ a, (∫⁻ ω, (pullCount IT.action a
        (ENat.toNat (A.stoppingTime IT.obs IT.action IT.feedback ω)) ω : ℝ≥0∞)
          ∂(trajMeasure A.alg (Environment.bandit ν))) * klDiv (ν a) (ν' a) :=
  sorry

/-- **Lower bound on the sample complexity** [GK16, Theorem 1]: for a `δ`-correct algorithm with
`δ ≤ 1/2` and an admissible model with a single correct answer, in any task,
`E[τ] ≥ T*(θ) kl(δ, 1 - δ)`. -/
theorem charTime_mul_le_expectedStoppingTime [MeasurableSpace.CountablyGenerated 𝓨]
    [MeasurableSingletonClass ℐ] (task : IdentTask α Θ ℐ 𝓨) (A : IdentAlg Unit α 𝓨 ℐ) {δ : ℝ}
    (hδ : δ ∈ Set.Ioc 0 (1 / 2)) (hA : task.IsDeltaCorrect A δ) {θ : Θ} (hθ : θ ∈ task.M)
    {i : ℐ} (hi : task.correct θ = {i}) :
    task.charTime θ * ENNReal.ofReal ((1 - 2 * δ) * log ((1 - δ) / δ)) ≤
      expectedStoppingTime A (Environment.bandit (task.ν θ)) :=
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
    (h : IsAlgEnvSeq O A Y alg (Environment.bandit ν) P)
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
cumulant generating function of `Y` under `Q` on `Λ ∩ integrableExpSet Y Q`, this is
LMLExplore's `MGFDominatedOn X P Y Q Λ`. -/
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
the mean, for independent variables dominated by `Y` on `[0, ∞)`. -/
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
      (Environment.bandit (task.ν μ)) ≤ c * ENNReal.ofReal (log (1 / δ)) :=
  sorry

/-! ## Layer 5.4: learning the design -/

section LearningTheDesign

/-! ### The designs of the EValues roadmap's Layer 6.4, as in LMLExplore -/

/-- The law of the table `(Σ a, Fin (n a)) → 𝓨` of the design `n` under the instance `μ`
(LMLExplore's `designLaw`). -/
def designLaw (μ : α → Measure 𝓨) (n : α → ℕ) : Measure ((Σ a, Fin (n a)) → 𝓨) :=
  Measure.pi fun p ↦ μ p.1

/-- The value of the design `n`: the largest expected logarithm under `μ` of an e-variable of its
table for the instances of `Λ` (LMLExplore's `designValue`). -/
def designValue (μ : α → Measure 𝓨) (Λ : Set (α → Measure 𝓨)) (n : α → ℕ) : EReal :=
  maxUtility (designLaw μ n) ((fun ν ↦ designLaw ν n) '' Λ) logUtility

/-- The rate `D*` of the designs (LMLExplore's `designRate`). -/
def designRate (μ : α → Measure 𝓨) (Λ : Set (α → Measure 𝓨)) : EReal :=
  ⨆ n : α → ℕ, designValue μ Λ n / ((∑ a, n a : ℕ) : EReal)

/-- The design `⌈m (x + ε 𝟙_{supp x})⌉` (LMLExplore's `proportionalDesign`). -/
def proportionalDesign (x : α → ℝ≥0) (ε : ℝ≥0) (m : ℕ) : α → ℕ :=
  fun a ↦ if x a = 0 then 0 else ⌈(m : ℝ≥0) * (x a + ε)⌉₊

/-- The growth `D̄ x` of the designs proportional to `x` (LMLExplore's `designGrowth`). -/
def designGrowth (μ : α → Measure 𝓨) (Λ : Set (α → Measure 𝓨)) (x : α → ℝ≥0) : EReal :=
  ⨅ (ε : ℝ≥0) (_ : 0 < ε),
    liminf (fun m : ℕ ↦ designValue μ Λ (proportionalDesign x ε m) / (m : EReal)) atTop

/-! ### Correctness when stopping and experts -/

namespace IdentTask

/-- `A` is `δ`-correct when it stops (README Conventions) [EVR26, Notes 49 and 55]: on every
admissible model, with probability at most `δ`, it stops and outputs an answer that is not
correct. Nothing is asked when it does not stop. -/
def IsDeltaCorrectOnStop (task : IdentTask α Θ ℐ 𝓨) (A : IdentAlg Unit α 𝓨 ℐ) (δ : ℝ) : Prop :=
  ∀ θ ∈ task.M, (histOutputMeasure A (Environment.bandit (task.ν θ))).real
    {p | p.1 ∈ A.stopSet ∧ p.2 ∉ task.correct θ} ≤ δ

/-- A `δ`-correct algorithm is `δ`-correct when it stops. -/
theorem IsDeltaCorrect.isDeltaCorrectOnStop (task : IdentTask α Θ ℐ 𝓨)
    {A : IdentAlg Unit α 𝓨 ℐ} {δ : ℝ} (hA : task.IsDeltaCorrect A δ) :
    task.IsDeltaCorrectOnStop A δ :=
  sorry

/-- An algorithm is `δ`-PAC exactly when it is `δ`-correct when it stops and stops almost surely
on every admissible model (README Conventions). -/
theorem isDeltaPAC_iff_isDeltaCorrectOnStop (task : IdentTask α Θ ℐ 𝓨)
    {A : IdentAlg Unit α 𝓨 ℐ} {δ : ℝ} :
    task.IsDeltaPAC A δ ↔ task.IsDeltaCorrectOnStop A δ ∧ ∀ θ ∈ task.M,
      ∀ᵐ ω ∂(trajMeasure A.alg (Environment.bandit (task.ν θ))),
        A.stoppingTime IT.obs IT.action IT.feedback ω ≠ ⊤ :=
  sorry

/-- The laws of the arms at the alternatives to the answer `i`. -/
def altInstances (task : IdentTask α Θ ℐ 𝓨) (i : ℐ) : Set (α → Measure 𝓨) :=
  (fun θ' a ↦ task.ν θ' a) '' task.alt i

/-- **The lower bound with the rate of the designs**, for algorithms `δ`-correct when they stop
(README Layers 2.3 and 5.4) [EVR26, Notes 41 and 55]: `kl(δ, 1 - δ) ≤ D* E_θ[τ]`. LMLExplore's
`IdentTask.IsDeltaCorrect.klBer_le_designRate_mul_expectedStoppingTime` is the case of
`δ`-correct algorithms. -/
theorem IsDeltaCorrectOnStop.klBer_le_designRate_mul_expectedStoppingTime
    [MeasurableSingletonClass ℐ] (task : IdentTask α Θ ℐ 𝓨) {A : IdentAlg Unit α 𝓨 ℐ} {δ : ℝ}
    (hA : task.IsDeltaCorrectOnStop A δ) (hδ : δ ∈ Set.Ioc 0 (1 / 2)) {θ : Θ} (hθ : θ ∈ task.M)
    {i : ℐ} (hi : task.correct θ = {i}) (h_alt : (task.alt i).Nonempty)
    (hstop : ∀ᵐ ω ∂(trajMeasure A.alg (Environment.bandit (task.ν θ))),
      A.stoppingTime IT.obs IT.action IT.feedback ω ≠ ⊤) :
    ((ENNReal.ofReal ((1 - 2 * δ) * log ((1 - δ) / δ)) : ℝ≥0∞) : EReal) ≤
      designRate (fun a ↦ task.ν θ a) (task.altInstances i) *
        (expectedStoppingTime A (Environment.bandit (task.ν θ)) : EReal) :=
  sorry

/-- A sequence of experts (README Layer 5.4) [EVR26, Note 55, Definition 4]: for every `e`, the
answer `j e`, the block shape `S e ≠ 0` and the bounded measurable function `g e` on the tables of
the design `S e` form an expert: `exp (g e)` is an e-variable of one table for the laws of the
arms at every alternative to `j e`. -/
structure IsExpertSeq (task : IdentTask α Θ ℐ 𝓨) (j : ℕ → ℐ) (S : ℕ → α → ℕ)
    (g : (e : ℕ) → ((Σ a, Fin (S e a)) → 𝓨) → ℝ) : Prop where
  shape_ne_zero (e : ℕ) : S e ≠ 0
  measurable (e : ℕ) : Measurable (g e)
  bounded (e : ℕ) : ∃ c : ℝ, ∀ y, |g e y| ≤ c
  lintegral_exp_le_one (e : ℕ) : ∀ θ ∈ task.alt (j e),
    ∫⁻ y, ENNReal.ofReal (exp (g e y)) ∂(designLaw (fun a ↦ task.ν θ a) (S e)) ≤ 1

/-- The value `∫ g e dθ^(S e) / |S e|` of the expert `e` at the model `θ`. -/
def expertValue (task : IdentTask α Θ ℐ 𝓨) (S : ℕ → α → ℕ)
    (g : (e : ℕ) → ((Σ a, Fin (S e a)) → 𝓨) → ℝ) (θ : Θ) (e : ℕ) : ℝ :=
  (∫ y, g e y ∂(designLaw (fun a ↦ task.ν θ a) (S e))) / (∑ a, S e a : ℕ)

/-- The experts determine `D*` at `θ` for the answer `i`: the values at `θ` of the experts of the
answer `i` have supremum the rate of the designs of `θ` against the alternatives to `i`. -/
def DeterminesDesignRate (task : IdentTask α Θ ℐ 𝓨) (j : ℕ → ℐ) (S : ℕ → α → ℕ)
    (g : (e : ℕ) → ((Σ a, Fin (S e a)) → 𝓨) → ℝ) (θ : Θ) (i : ℐ) : Prop :=
  ⨆ (e : ℕ) (_ : j e = i), (task.expertValue S g θ e : EReal) =
    designRate (fun a ↦ task.ν θ a) (task.altInstances i)

/-- The value of an expert is at most `D*` against the alternatives to its answer, at every model,
and at most `0` at those alternatives. -/
theorem IsExpertSeq.expertValue_le (task : IdentTask α Θ ℐ 𝓨) {j : ℕ → ℐ} {S : ℕ → α → ℕ}
    {g : (e : ℕ) → ((Σ a, Fin (S e a)) → 𝓨) → ℝ} (hg : task.IsExpertSeq j S g) (θ : Θ) (e : ℕ) :
    (task.expertValue S g θ e : EReal) ≤
        designRate (fun a ↦ task.ν θ a) (task.altInstances (j e)) ∧
      (θ ∈ task.alt (j e) → task.expertValue S g θ e ≤ 0) :=
  sorry

end IdentTask

/-! ### The algorithm -/

/-- The sampling rule of the algorithm that learns the design (README Layer 5.4) [EVR26, Note 49,
Section 3], for the block shapes `S e`, the functions `g e` and the integer bounds `c e` of the
experts: round `t` occupies a window of time fixed in advance, in which every admitted expert
(`e + |S e| + c e ≤ log₂ t`) reads `t²` fresh blocks to estimate its value, then the admitted
expert of largest estimate reads `⌊2^t / |S e|⌋` fresh blocks, and a fixed arm fills the window. -/
def learnDesignAlg (S : ℕ → α → ℕ) (g : (e : ℕ) → ((Σ a, Fin (S e a)) → 𝓨) → ℝ) (c : ℕ → ℕ) :
    Algorithm Unit α 𝓨 :=
  sorry

/-- The algorithm that learns the design at level `δ` (README Layer 5.4): the sampling rule
`learnDesignAlg`, the blocks read by the selected expert `e` multiplying the product of its answer
`j e` by `exp (g e)`, and the rule that stops when the product of an answer `i` reaches
`1 / (δ w i)` and answers the first such `i` in a fixed order. -/
def learnDesign (j : ℕ → ℐ) (S : ℕ → α → ℕ) (g : (e : ℕ) → ((Σ a, Fin (S e a)) → 𝓨) → ℝ)
    (c : ℕ → ℕ) (w : ℐ → ℝ≥0) (δ : ℝ) : IdentAlg Unit α 𝓨 ℐ :=
  sorry

/-- The sampling rule of the algorithm that learns the design does not depend on the level. -/
theorem learnDesign_alg (j : ℕ → ℐ) (S : ℕ → α → ℕ)
    (g : (e : ℕ) → ((Σ a, Fin (S e a)) → 𝓨) → ℝ) (c : ℕ → ℕ) (w : ℐ → ℝ≥0) (δ : ℝ) :
    (learnDesign j S g c w δ).alg = learnDesignAlg S g c :=
  sorry

namespace IdentTask

variable [Countable ℐ] [MeasurableSingletonClass ℐ] {j : ℕ → ℐ} {S : ℕ → α → ℕ}
  {g : (e : ℕ) → ((Σ a, Fin (S e a)) → 𝓨) → ℝ} {c : ℕ → ℕ} {w : ℐ → ℝ≥0}

/-- **Validity of the algorithm that learns the design** [EVR26, Note 55, Theorem 5; Note 49,
Theorem 2]: for every sequence of experts, on every model, dominated or not, it is `δ`-correct when
it stops. -/
theorem isDeltaCorrectOnStop_learnDesign (task : IdentTask α Θ ℐ 𝓨)
    (hg : task.IsExpertSeq j S g) (hc : ∀ e y, |g e y| ≤ c e) (hw : ∀ i, 0 < w i)
    (hw1 : ∑' i, (w i : ℝ≥0∞) ≤ 1) {δ : ℝ} (hδ : δ ∈ Set.Ioo 0 1) :
    task.IsDeltaCorrectOnStop (learnDesign j S g c w δ) δ :=
  sorry

/-- **The algorithm that learns the design attains `D*` wherever its experts determine it**
[EVR26, Note 55, Theorem 5; Note 49, Theorem 3]: at every admissible model `θ` with a single
correct answer `i`, at which the experts determine `D* > 0`, it stops almost surely; almost surely,
for every `t > 1 / D*`, `τ_δ ≤ t log (1/δ)` for all small `δ`; and `E_θ[τ_δ] / log (1/δ) → 1 / D*`,
with `1 / ∞ = 0`. -/
theorem tendsto_expectedStoppingTime_learnDesign_div_log [Nonempty α]
    (task : IdentTask α Θ ℐ 𝓨) (hg : task.IsExpertSeq j S g) (hc : ∀ e y, |g e y| ≤ c e)
    (hw : ∀ i, 0 < w i) (hw1 : ∑' i, (w i : ℝ≥0∞) ≤ 1) {θ : Θ} (hθ : θ ∈ task.M) {i : ℐ}
    (hi : task.correct θ = {i}) (hpos : 0 < designRate (fun a ↦ task.ν θ a) (task.altInstances i))
    (hdet : task.DeterminesDesignRate j S g θ i) :
    (∀ δ ∈ Set.Ioo (0 : ℝ) 1,
      ∀ᵐ ω ∂(trajMeasure (learnDesignAlg S g c) (Environment.bandit (task.ν θ))),
        (learnDesign j S g c w δ).stoppingTime IT.obs IT.action IT.feedback ω ≠ ⊤) ∧
    (∀ᵐ ω ∂(trajMeasure (learnDesignAlg S g c) (Environment.bandit (task.ν θ))),
      ∀ t : ℝ≥0, (designRate (fun a ↦ task.ν θ a) (task.altInstances i)).toENNReal⁻¹ < t →
        ∀ᶠ δ in 𝓝[>] 0,
          ENat.toENNReal ((learnDesign j S g c w δ).stoppingTime IT.obs IT.action IT.feedback ω) ≤
            t * ENNReal.ofReal (log (1 / δ))) ∧
    Tendsto (fun δ ↦ expectedStoppingTime (learnDesign j S g c w δ)
        (Environment.bandit (task.ν θ)) / ENNReal.ofReal (log (1 / δ))) (𝓝[>] 0)
      (𝓝 (designRate (fun a ↦ task.ν θ a) (task.altInstances i)).toENNReal⁻¹) :=
  sorry

omit [MeasurableSingletonClass ℐ] in
/-- **Experts for the dominated models** [EVR26, Note 55, Lemma 6; Note 49, Lemma 1]: on a countably
generated observation space, with an s-finite measure `ρ a` for each arm, one sequence of experts
determines `D*` at every model whose laws are dominated by the `ρ a`, for every answer. -/
theorem exists_isExpertSeq_determinesDesignRate_of_absolutelyContinuous [Nonempty α] [Nonempty ℐ]
    [MeasurableSpace.CountablyGenerated 𝓨] (task : IdentTask α Θ ℐ 𝓨) (ρ : α → Measure 𝓨)
    [∀ a, SFinite (ρ a)] :
    ∃ (j : ℕ → ℐ) (S : ℕ → α → ℕ) (g : (e : ℕ) → ((Σ a, Fin (S e a)) → 𝓨) → ℝ),
      task.IsExpertSeq j S g ∧
        ∀ θ, (∀ a, task.ν θ a ≪ ρ a) → ∀ i, task.DeterminesDesignRate j S g θ i :=
  sorry

omit [Countable ℐ] [MeasurableSingletonClass ℐ] in
/-- **Experts for countably many models** [EVR26, Note 55, Section 2], on any spaces. -/
theorem exists_isExpertSeq_determinesDesignRate_of_countable [Nonempty α] [Nonempty ℐ]
    (task : IdentTask α Θ ℐ 𝓨) {T : Set (Θ × ℐ)} (hT : T.Countable) :
    ∃ (j : ℕ → ℐ) (S : ℕ → α → ℕ) (g : (e : ℕ) → ((Σ a, Fin (S e a)) → 𝓨) → ℝ),
      task.IsExpertSeq j S g ∧ ∀ p ∈ T, task.DeterminesDesignRate j S g p.1 p.2 :=
  sorry

/-- **The classes of models on which `D*` is attained** [EVR26, Note 55, Theorem 7]: one sequence
of experts determines `D*` on a set `M'` of admissible models exactly when some algorithms,
`δ`-correct when they stop, have `limsup_{δ → 0} E_θ[τ_δ] / log (1/δ) ≤ 1 / D*` on `M'`. -/
theorem exists_isExpertSeq_iff_exists_identAlg_limsup_le (task : IdentTask α Θ ℐ 𝓨)
    {M' : Set Θ} (hM' : M' ⊆ task.M) :
    (∃ (j : ℕ → ℐ) (S : ℕ → α → ℕ) (g : (e : ℕ) → ((Σ a, Fin (S e a)) → 𝓨) → ℝ),
        task.IsExpertSeq j S g ∧
          ∀ θ ∈ M', ∀ i, task.correct θ = {i} → task.DeterminesDesignRate j S g θ i) ↔
      ∃ A : ℝ → IdentAlg Unit α 𝓨 ℐ,
        (∀ δ ∈ Set.Ioo (0 : ℝ) (1 / 2), task.IsDeltaCorrectOnStop (A δ) δ) ∧
        ∀ θ ∈ M', ∀ i, task.correct θ = {i} →
          0 < designRate (fun a ↦ task.ν θ a) (task.altInstances i) →
          limsup (fun δ ↦ expectedStoppingTime (A δ) (Environment.bandit (task.ν θ)) /
              ENNReal.ofReal (log (1 / δ))) (𝓝[>] 0) ≤
            (designRate (fun a ↦ task.ν θ a) (task.altInstances i)).toENNReal⁻¹ :=
  sorry

end IdentTask

/-! ### Experts from test functions -/

/-- The weighted smallest relative entropy `Ψ_x(κ) = ⨅ ν ∈ Λ, ∑ a, x a * KL(κ a, ν a)`, with
`0 * ∞ = 0` (README Layer 5.4). -/
def weightedKLInf (Λ : Set (α → Measure 𝓨)) (x : α → ℝ≥0) (κ : α → Measure 𝓨) : ℝ≥0∞ :=
  ⨅ ν ∈ Λ, ∑ a, (x a : ℝ≥0∞) * klDiv (κ a) (ν a)

/-- The box of the instances of probability measures `κ` under which every test function `g` of
`F a` is integrable with `|∫ g dκ a - q a g| ≤ ε`, for every arm `a`. -/
def testBox (F : α → Finset (𝓨 → ℝ)) (q : α → (𝓨 → ℝ) → ℝ) (ε : ℝ) : Set (α → Measure 𝓨) :=
  {κ | ∀ a, IsProbabilityMeasure (κ a) ∧
    ∀ g ∈ F a, Integrable g (κ a) ∧ |∫ y, g y ∂(κ a) - q a g| ≤ ε}

/-- The box of `(F, q, ε)` is around `μ`: its inequalities are strict at `μ`. -/
def IsTestBoxAround (F : α → Finset (𝓨 → ℝ)) (q : α → (𝓨 → ℝ) → ℝ) (ε : ℝ)
    (μ : α → Measure 𝓨) : Prop :=
  0 < ε ∧ ∀ a, IsProbabilityMeasure (μ a) ∧
    ∀ g ∈ F a, Integrable g (μ a) ∧ |∫ y, g y ∂(μ a) - q a g| < ε

/-- The envelope `Ψ^G_x(μ) = ⨆ (V around μ), ⨅ κ ∈ V, Ψ_x(κ)` on the boxes of the test functions
`G a` (README Layer 5.4). -/
def testEnvelope (G : α → Set (𝓨 → ℝ)) (Λ : Set (α → Measure 𝓨)) (x : α → ℝ≥0)
    (μ : α → Measure 𝓨) : ℝ≥0∞ :=
  ⨆ (F : α → Finset (𝓨 → ℝ)) (q : α → (𝓨 → ℝ) → ℝ) (ε : ℝ) (_ : ∀ a, ↑(F a) ⊆ G a)
    (_ : IsTestBoxAround F q ε μ), ⨅ κ ∈ testBox F q ε, weightedKLInf Λ x κ

/-- **The lower bound on the growth of the designs** [EVR26, Note 55, Proposition 8; Csi84]:
`Ψ^G_x(μ) ≤ D̄(x)` for test functions integrable under the instances of `Λ`, bounded or not. -/
theorem testEnvelope_le_designGrowth {G : α → Set (𝓨 → ℝ)} {Λ : Set (α → Measure 𝓨)}
    {μ : α → Measure 𝓨} (hΛ : ∀ ν ∈ Λ, ∀ a, IsProbabilityMeasure (ν a))
    (hGm : ∀ a, ∀ g ∈ G a, Measurable g) (hGΛ : ∀ ν ∈ Λ, ∀ a, ∀ g ∈ G a, Integrable g (ν a))
    (x : α → ℝ≥0) :
    (testEnvelope G Λ x μ : EReal) ≤ designGrowth μ Λ x :=
  sorry

namespace IdentTask

/-- **Experts from countably many test functions** [EVR26, Note 55, Proposition 8]: one sequence of
experts, depending on the task and the test functions only, determines `D*` at every model and
answer at which `Ψ^G_w = Ψ_w` against the alternatives for the rational allocations; there
`D* = 1 / T*` when the answer is the only correct one. -/
theorem exists_isExpertSeq_determinesDesignRate_of_testEnvelope_eq [Nonempty α] [Countable ℐ]
    [Nonempty ℐ] (task : IdentTask α Θ ℐ 𝓨) (G : α → Set (𝓨 → ℝ)) (hGc : ∀ a, (G a).Countable)
    (hGm : ∀ a, ∀ f ∈ G a, Measurable f)
    (hGi : ∀ i, ∀ θ ∈ task.alt i, ∀ a, ∀ f ∈ G a, Integrable f (task.ν θ a)) :
    ∃ (j : ℕ → ℐ) (S : ℕ → α → ℕ) (g : (e : ℕ) → ((Σ a, Fin (S e a)) → 𝓨) → ℝ),
      task.IsExpertSeq j S g ∧ ∀ (θ : Θ) (i : ℐ),
        (∀ w ∈ simplex α, (∀ a, w a ∈ Set.range ((↑) : ℚ → ℝ)) →
          testEnvelope G (task.altInstances i) (fun a ↦ (w a).toNNReal) (fun a ↦ task.ν θ a) =
            weightedKLInf (task.altInstances i) (fun a ↦ (w a).toNNReal) (fun a ↦ task.ν θ a)) →
        task.DeterminesDesignRate j S g θ i ∧
          (task.correct θ = {i} → designRate (fun a ↦ task.ν θ a) (task.altInstances i) =
            (((task.charTime θ)⁻¹ : ℝ≥0∞) : EReal)) :=
  sorry

/-- **Alternatives in a weakly compact set** [EVR26, Note 55, Corollary 9]: on a separable
pseudo-metrizable observation space with its Borel σ-algebra, one sequence of experts determines
`D*` at every model and answer whose alternatives have their laws in a weakly compact set `K` with
the same weighted entropy infima; there `D̄(x) = Ψ_x` and `D* = 1 / T*`. -/
theorem exists_isExpertSeq_determinesDesignRate_of_isCompact [TopologicalSpace 𝓨]
    [TopologicalSpace.PseudoMetrizableSpace 𝓨] [TopologicalSpace.SeparableSpace 𝓨] [BorelSpace 𝓨]
    [Nonempty α] [Countable ℐ] [Nonempty ℐ] (task : IdentTask α Θ ℐ 𝓨) :
    ∃ (j : ℕ → ℐ) (S : ℕ → α → ℕ) (g : (e : ℕ) → ((Σ a, Fin (S e a)) → 𝓨) → ℝ),
      task.IsExpertSeq j S g ∧ ∀ (θ : Θ) (i : ℐ) (K : Set (α → ProbabilityMeasure 𝓨)),
        IsCompact K → task.altInstances i ⊆ (fun ν a ↦ (ν a : Measure 𝓨)) '' K →
        (∀ w ∈ simplex α,
          weightedKLInf ((fun ν a ↦ (ν a : Measure 𝓨)) '' K) (fun a ↦ (w a).toNNReal)
              (fun a ↦ task.ν θ a) =
            weightedKLInf (task.altInstances i) (fun a ↦ (w a).toNNReal) (fun a ↦ task.ν θ a)) →
        task.DeterminesDesignRate j S g θ i ∧
          (∀ x : α → ℝ≥0, designGrowth (fun a ↦ task.ν θ a) (task.altInstances i) x =
            weightedKLInf (task.altInstances i) x (fun a ↦ task.ν θ a)) ∧
          (task.correct θ = {i} → designRate (fun a ↦ task.ν θ a) (task.altInstances i) =
            (((task.charTime θ)⁻¹ : ℝ≥0∞) : EReal)) :=
  sorry

end IdentTask

/-- **Convergence in distribution on a separable space is second countable** (README Layer 5.4):
the laws with finitely many atoms at the points of a dense sequence and rational weights are dense
for the Lévy–Prokhorov distance. In LMLExplore, an instance. -/
theorem secondCountableTopology_probabilityMeasure {X : Type*} [TopologicalSpace X]
    [TopologicalSpace.PseudoMetrizableSpace X] [TopologicalSpace.SeparableSpace X]
    [MeasurableSpace X] [OpensMeasurableSpace X] :
    SecondCountableTopology (ProbabilityMeasure X) :=
  sorry

/-- Best arm identification among all the laws on `[0, 1]` (README Layers 1.1 and 5.4): a model is
the vector of the arm laws, carried by `[0, 1]`, and its correct answer the arm of largest mean. -/
def unitIntervalBaiTask : IdentTask α (α → ProbabilityMeasure ℝ) α ℝ where
  M := (baiTask (productBandit fun _ (P : ProbabilityMeasure ℝ) ↦ (P : Measure ℝ))
      (fun θ a ↦ ∫ x, x ∂(θ a : Measure ℝ))).M ∩
    {θ | ∀ a, ∀ᵐ x ∂(θ a : Measure ℝ), x ∈ Set.Icc 0 1}
  ν := productBandit fun _ (P : ProbabilityMeasure ℝ) ↦ (P : Measure ℝ)
  isMarkovKernel_ν _ := inferInstance
  correct θ := {a | ∀ b ≠ a, ∫ x, x ∂(θ b : Measure ℝ) < ∫ x, x ∂(θ a : Measure ℝ)}

/-- **`0 < D* = 1 / T* < ∞` for the best arm among the laws on `[0, 1]`** [EVR26, Note 55,
Corollary 9], at every model, with at least two arms. -/
theorem designRate_eq_inv_charTime_unitIntervalBaiTask [Nontrivial α]
    {θ : α → ProbabilityMeasure ℝ} (hθ : θ ∈ (unitIntervalBaiTask (α := α)).M) {i : α}
    (hi : i ∈ (unitIntervalBaiTask (α := α)).correct θ) :
    designRate (fun a ↦ (unitIntervalBaiTask (α := α)).ν θ a)
        ((unitIntervalBaiTask (α := α)).altInstances i) =
      ((((unitIntervalBaiTask (α := α)).charTime θ)⁻¹ : ℝ≥0∞) : EReal) ∧
    (unitIntervalBaiTask (α := α)).charTime θ ≠ 0 ∧ (unitIntervalBaiTask (α := α)).charTime θ ≠ ⊤ :=
  sorry

/-- **One algorithm at `T*` for the best arm among the laws on `[0, 1]`** [EVR26, Note 55,
Corollary 9]: the algorithm that learns the design, with the experts of the weakly compact
alternatives, is `δ`-PAC and has `E_θ[τ_δ] / log (1/δ) → T*(θ)` at every model. -/
theorem exists_isDeltaPAC_tendsto_charTime_unitIntervalBaiTask [Nontrivial α] :
    ∃ A : ℝ → IdentAlg Unit α ℝ α,
      (∀ δ ∈ Set.Ioo (0 : ℝ) 1, (unitIntervalBaiTask (α := α)).IsDeltaPAC (A δ) δ) ∧
      ∀ θ ∈ (unitIntervalBaiTask (α := α)).M,
        Tendsto (fun δ ↦ expectedStoppingTime (A δ)
            (Environment.bandit ((unitIntervalBaiTask (α := α)).ν θ)) /
              ENNReal.ofReal (log (1 / δ))) (𝓝[>] 0)
          (𝓝 ((unitIntervalBaiTask (α := α)).charTime θ)) :=
  sorry

/-- **Exponential families, without an algorithm** [EVR26, Note 55, Corollary 10], for any task on
vectors of means of per-arm exponential families `(ρ a, T a)` (README Layer 5.4): at a model `θ`
at which the costs `θ' ↦ D(θ', w, ¬i)` are lower semicontinuous on `∏ a, S a`,
`D̄(x) = ⨅ λ ∈ ¬i, ∑ a, x a d_a(θ a, λ a)` and `D* = 1 / T*(θ)`. Best arm identification in one
family is the case of [EVR26, Note 55, Corollary 10]. -/
theorem designRate_eq_inv_charTime_of_expFamily (task : IdentTask α (α → ℝ) ℐ 𝓨)
    (ρ : α → Measure 𝓨) [∀ a, IsProbabilityMeasure (ρ a)] (T : α → 𝓨 → ℝ)
    (hT : ∀ a, Measurable (T a)) (κ : α → ℝ → Measure 𝓨) [∀ a x, IsProbabilityMeasure (κ a x)]
    (S : α → Set ℝ) (hS : ∀ a, IsOpen (S a))
    (hκ : ∀ a, ∀ x ∈ S a, ∃ η ∈ interior (integrableExpSet (T a) (ρ a)),
      κ a x = expFamily (ρ a) (T a) η ∧ ∫ y, T a y ∂(κ a x) = x)
    (hν : task.ν = productBandit κ) (hM : task.M ⊆ Set.univ.pi S)
    {θ : α → ℝ} (hθ : θ ∈ task.M) {i : ℐ} (hi : task.correct θ = {i})
    (hlsc : ∀ w ∈ simplex α,
      LowerSemicontinuousWithinAt (fun θ' ↦ task.altCost θ' w i) (Set.univ.pi S) θ) :
    (∀ x : α → ℝ≥0, designGrowth (fun a ↦ task.ν θ a) (task.altInstances i) x =
      weightedKLInf (task.altInstances i) x (fun a ↦ task.ν θ a)) ∧
    designRate (fun a ↦ task.ν θ a) (task.altInstances i) =
      (((task.charTime θ)⁻¹ : ℝ≥0∞) : EReal) :=
  sorry

end LearningTheDesign

end LMLRoadmaps.Identification
