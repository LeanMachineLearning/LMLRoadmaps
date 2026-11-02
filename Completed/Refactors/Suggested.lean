import Mathlib.Analysis.Calculus.FDeriv.Basic
import Mathlib.Analysis.Convex.Strong
import Mathlib.InformationTheory.KullbackLeibler.Basic
import Mathlib.MeasureTheory.Measure.Tilted
import Mathlib.Probability.Moments.MGFAnalytic
import LeanMachineLearning.ForMathlib.Analysis.Convex.Bregman.Basic
import LeanMachineLearning.Online.Bandit.ArrayProbSpace
import LeanMachineLearning.SequentialLearning.FiniteActions
import LeanMachineLearning.SequentialLearning.StationaryEnv
import LeanMachineLearning.SequentialLearning.SumRewards

/-!
# Refactors: suggested target signatures

**This file is not the roadmap and is not exhaustive.** The definitive document is `README.md`.
The statements suggest the forms of the generalized statements of Layer 0, so that contributors
and reviewers converge on their shapes; the admitted proofs are targets. The LMLExplore
declarations they generalize are named in the README. This file imports only Mathlib, Tau Ceti
and LML, so it spells out the exponential-family notions (`expFamily`, `natParam`,
`expFamilyDiv`) through Mathlib's `Measure.tilted`, `cgf` and `klDiv`.
-/

noncomputable section

open MeasureTheory ProbabilityTheory InformationTheory Learning Bandits Finset
open scoped ENNReal

namespace LMLRoadmaps.Refactors

/-! ## Layer 0.1: FTRL on normed spaces, with losses in the dual -/

section FTRL

variable {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E] {K : Set E} {n : ℕ} {u : E}

/-- `x` is a play of follow the regularized leader on `K` at round `t`, with potential `F`,
learning rate `η` and losses `y s : E →L[ℝ] ℝ`: `x ∈ K` minimizes
`b ↦ η ∑ s < t, y s b + F b` over `K`. -/
structure IsFTRLPlay (K : Set E) (F : E → ℝ) (η : ℝ) (y : ℕ → E →L[ℝ] ℝ) (t : ℕ) (x : E) :
    Prop where
  mem : x ∈ K
  isMinOn : IsMinOn (fun b ↦ η * ∑ s ∈ range t, y s b + F b) K x

/-- [LS, Theorem 28.5] on a normed space: the regret `∑ t < n, y t (a t - u)` of FTRL. -/
theorem ftrl_regret_le {F : E → ℝ} (hK : Convex ℝ K) {η : ℝ} (hη : 0 < η)
    (y : ℕ → E →L[ℝ] ℝ) (a : ℕ → E) (ha : ∀ t ≤ n, IsFTRLPlay K F η y t (a t))
    (F' : ℕ → E →L[ℝ] ℝ) (hF' : ∀ t < n, HasFDerivWithinAt F (F' t) K (a t)) (hu : u ∈ K) :
    ∑ t ∈ range n, y t (a t - u) ≤ (F u - F (a 0)) / η +
      ∑ t ∈ range n, y t (a t - a (t + 1)) -
        (∑ t ∈ range n, bregDiv F (a (t + 1)) (a t) (F' t)) / η :=
  sorry

/-- [LS, Corollary 28.8] for the norm of `E`: for an `m`-strongly convex potential, the regret is
at most `(F u - F (a 0)) / η + η / (2 m) ∑ t < n, ‖y t‖ ^ 2`, with the operator norm of the
losses, which is the dual norm of the norm of `E`. -/
theorem ftrl_regret_le_of_strongConvexOn {F : E → ℝ} {m : ℝ} (hF : StrongConvexOn K m F)
    (hm : 0 < m) {η : ℝ} (hη : 0 < η) (y : ℕ → E →L[ℝ] ℝ) (a : ℕ → E)
    (ha : ∀ t ≤ n, IsFTRLPlay K F η y t (a t))
    (F' : ℕ → E →L[ℝ] ℝ) (hF' : ∀ t < n, HasFDerivWithinAt F (F' t) K (a t)) (hu : u ∈ K) :
    ∑ t ∈ range n, y t (a t - u) ≤
      (F u - F (a 0)) / η + η / (2 * m) * ∑ t ∈ range n, ‖y t‖ ^ 2 :=
  sorry

end FTRL

/-! ## Layer 0.3: Chernoff bounds under domination by an exponential family

For a measure `ρ` on `𝓧` and a statistic `T : 𝓧 → ℝ`, the member of natural parameter `η` of the
exponential family of `(ρ, T)` is `ρ.tilted (fun x ↦ η * T x)` (Layer 0.2); the mean of `T` under
it is `deriv (cgf T ρ) η`, and the divergence `d(x, μ)` between the members of means `x` and `μ`
is the relative entropy of the members of natural parameters `η'` and `η`. -/

section Chernoff

variable {Ω ι 𝓧 : Type*} {mΩ : MeasurableSpace Ω} {m𝓧 : MeasurableSpace 𝓧} {P : Measure Ω}
  [IsProbabilityMeasure P] {ρ : Measure 𝓧} [IsProbabilityMeasure ρ] {T : 𝓧 → ℝ} {η η' : ℝ}
  {X : ι → Ω → ℝ} {s : Finset ι}

/-- Upper tail: independent variables dominated above by the member of natural parameter `η`
(for `t ≥ 0`, `exp (t X i)` is integrable and
`mgf (X i) P t ≤ mgf T (ρ.tilted (fun x ↦ η * T x)) t`) exceed `#s` times the mean `x` of the
member of natural parameter `η' ≥ η` with probability at most `exp (-(#s d(x, μ)))`. -/
theorem iIndepFun.measureReal_sum_ge_le_exp_klDiv_of_mgf_le
    (hη : η ∈ interior (integrableExpSet T ρ)) (hη' : η' ∈ interior (integrableExpSet T ρ))
    (hηη' : η ≤ η') (h_indep : iIndepFun X P)
    (h_int : ∀ i ∈ s, ∀ t, 0 ≤ t → Integrable (fun ω ↦ Real.exp (t * X i ω)) P)
    (h_dom : ∀ i ∈ s, ∀ t, 0 ≤ t → mgf (X i) P t ≤ mgf T (ρ.tilted (fun x ↦ η * T x)) t) :
    P.real {ω | #s * deriv (cgf T ρ) η' ≤ ∑ i ∈ s, X i ω} ≤
      Real.exp (-(#s *
        (klDiv (ρ.tilted (fun x ↦ η' * T x)) (ρ.tilted (fun x ↦ η * T x))).toReal)) :=
  sorry

/-- Lower tail: the same for variables dominated below (for `t ≤ 0`) and `η' ≤ η`. -/
theorem iIndepFun.measureReal_sum_le_le_exp_klDiv_of_mgf_le
    (hη : η ∈ interior (integrableExpSet T ρ)) (hη' : η' ∈ interior (integrableExpSet T ρ))
    (hη'η : η' ≤ η) (h_indep : iIndepFun X P)
    (h_int : ∀ i ∈ s, ∀ t, t ≤ 0 → Integrable (fun ω ↦ Real.exp (t * X i ω)) P)
    (h_dom : ∀ i ∈ s, ∀ t, t ≤ 0 → mgf (X i) P t ≤ mgf T (ρ.tilted (fun x ↦ η * T x)) t) :
    P.real {ω | ∑ i ∈ s, X i ω ≤ #s * deriv (cgf T ρ) η'} ≤
      Real.exp (-(#s *
        (klDiv (ρ.tilted (fun x ↦ η' * T x)) (ρ.tilted (fun x ↦ η * T x))).toReal)) :=
  sorry

end Chernoff

/-! ## Layer 0.4: the joint transfer from runs to the reward stream -/

section Transfer

variable {α Ω : Type*} [Fintype α] [DecidableEq α] {mα : MeasurableSpace α}
  [MeasurableSingletonClass α] {mΩ : MeasurableSpace Ω} {O : ℕ → Ω → Unit} {A : ℕ → Ω → α}
  {R : ℕ → Ω → ℝ} {P : Measure Ω} [IsProbabilityMeasure P] {alg : Algorithm Unit α ℝ}
  {ν : Kernel α ℝ} [IsMarkovKernel ν]

/-- The probability that a measurable property of the pull counts and of the sums of rewards of
all arms holds at some round is at most the probability that it holds, for the i.i.d. rewards of
the stream model, at some vector of counts. -/
theorem measure_exists_pullCount_sumRewards_le_joint
    (h : IsAlgEnvSeq O A R alg (stationaryEnv ν) P) {p : (α → ℕ) → (α → ℝ) → Prop}
    (hp : Measurable fun q : (α → ℕ) × (α → ℝ) ↦ p q.1 q.2) :
    P {ω | ∃ t, p (fun a ↦ pullCount A a t ω) (fun a ↦ sumRewards A R a t ω)} ≤
      streamMeasure ν {ω | ∃ s : α → ℕ, p s (fun a ↦ ∑ i ∈ range (s a), ω i a)} :=
  sorry

end Transfer

end LMLRoadmaps.Refactors
