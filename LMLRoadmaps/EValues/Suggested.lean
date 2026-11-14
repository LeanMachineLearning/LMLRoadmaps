import Mathlib.Analysis.SpecialFunctions.Log.ENNRealLog
import Mathlib.Basic.Real.ENatENNReal
import Mathlib.InformationTheory.KullbackLeibler.Basic
import Mathlib.Probability.Independence.Basic
import Mathlib.Probability.Martingale.Convergence
import Mathlib.Probability.Process.HittingTime
import Mathlib.Probability.ProductMeasure

/-!
# E-values, e-processes and anytime-valid inference: suggested target signatures

**This file is not the roadmap and is not exhaustive.** The definitive document is `README.md`.
The statements here suggest Lean forms for particular milestones, so that contributors and
reviewers converge on names and signatures; discharging all of them finishes neither a milestone
nor the roadmap. The admitted proofs are targets, not claimed implementations.

The pins of this repository do not contain Statlib. `IsEVar` and `effectiveSet` below stand for
Statlib's `ProbabilityTheory.IsEVar` and `ProbabilityTheory.effectiveSet`, in the form they take
for finite measures (`IsEVar.of_lintegral_le_measure_univ`, `IsEVar.lintegral_le_measure_univ`);
LMLExplore uses Statlib's declarations and never restates them. In LMLExplore the definitions of
this file live in the namespace `ProbabilityTheory`, next to Statlib's.

Values are in `ℝ≥0∞`, nulls are sets of measures with no domination, filtrations are indexed by
`ℕ`, and conditional statements are set-integral inequalities, as the Conventions of `README.md`
pin.
-/

noncomputable section

open MeasureTheory ProbabilityTheory InformationTheory Filter Set
open scoped ENNReal NNReal Topology

namespace LMLRoadmaps.EValues

variable {Ω : Type*} {mΩ : MeasurableSpace Ω}

/-! ## Stand-ins for Statlib -/

/-- Stand-in for Statlib's `ProbabilityTheory.IsEVar`, for finite measures. -/
structure IsEVar (X : Ω → ℝ≥0∞) (S : Set (Measure Ω)) : Prop where
  measurable : Measurable X
  lintegral_le_measure_univ : ∀ P ∈ S, ∫⁻ ω, X ω ∂P ≤ P univ

/-- Stand-in for Statlib's `∫ᵉ ω, ENNReal.log (X ω) ∂Q`, the `EReal`-valued expected logarithm:
the integral of the positive part minus that of the negative part. -/
def elogIntegral (X : Ω → ℝ≥0∞) (Q : Measure Ω) : EReal :=
  ((∫⁻ ω, (ENNReal.log (X ω)).toENNReal ∂Q : ℝ≥0∞) : EReal) -
    ((∫⁻ ω, (-ENNReal.log (X ω)).toENNReal ∂Q : ℝ≥0∞) : EReal)

/-- Stand-in for Statlib's `ProbabilityTheory.effectiveSet`. -/
def effectiveSet (S : Set (Measure Ω)) : Set (Measure Ω) :=
  {μ | ∀ X, IsEVar X S → ∫⁻ ω, X ω ∂μ ≤ 1}

/-! ## Layer 0: e-variables, p-variables, calibration and post-hoc validity -/

/-- A p-variable for `S`, with values in `ℝ≥0∞` (Layer 0.1). -/
structure IsPVar (p : Ω → ℝ≥0∞) (S : Set (Measure Ω)) : Prop where
  measurable : Measurable p
  measure_le_le : ∀ P ∈ S, ∀ α : ℝ≥0∞, P {ω | p ω ≤ α} ≤ α

/-- Markov's inequality for e-variables [RW, Proposition 2.1]. -/
theorem IsEVar.measure_inv_le_le {E : Ω → ℝ≥0∞} {S : Set (Measure Ω)} (hE : IsEVar E S)
    {P : Measure Ω} (hP : P ∈ S) [IsProbabilityMeasure P] (α : ℝ≥0∞) :
    P {ω | α⁻¹ ≤ E ω} ≤ α := by
  sorry

/-- The e-to-p calibration `E ↦ E⁻¹` [RW, Proposition 2.1]. -/
theorem IsEVar.isPVar_inv {E : Ω → ℝ≥0∞} {S : Set (Measure Ω)}
    (hS : ∀ P ∈ S, IsProbabilityMeasure P) (hE : IsEVar E S) :
    IsPVar (fun ω ↦ (E ω)⁻¹) S := by
  sorry

/-- A p-to-e calibrator, defined by the characterization of [RW, Proposition 2.5]. -/
def IsPToECalibrator (f : ℝ≥0∞ → ℝ≥0∞) : Prop :=
  Antitone f ∧ (∀ x, 1 < x → f x = 0) ∧ ∫⁻ x in Icc (0 : ℝ) 1, f (ENNReal.ofReal x) ≤ 1

/-- A calibrator turns every p-variable into an e-variable [VW21, Proposition 2.1]. -/
theorem IsPToECalibrator.isEVar_comp {f : ℝ≥0∞ → ℝ≥0∞} (hf : IsPToECalibrator f)
    {S : Set (Measure Ω)} (hS : ∀ P ∈ S, IsProbabilityMeasure P) {p : Ω → ℝ≥0∞}
    (hp : IsPVar p S) :
    IsEVar (f ∘ p) S := by
  sorry

/-- The randomized Markov inequality [RW, Theorem 2.9; RM26, Theorem 1.2]. -/
theorem measure_le_mul_eq_lintegral_min {P : Measure Ω} [IsProbabilityMeasure P]
    {Y : Ω → ℝ≥0∞} (hY : Measurable Y) {U : Ω → ℝ} (hU : Measurable U)
    (hU_law : P.map U = volume.restrict (Icc 0 1)) (hUY : IndepFun U Y P) (α : ℝ≥0∞) :
    P {ω | ENNReal.ofReal (U ω) ≤ α * Y ω} = ∫⁻ ω, min (α * Y ω) 1 ∂P := by
  sorry

/-- Post-hoc validity of a family of tests indexed by their levels [RW, Definition 4.1]. -/
def IsPostHocValid (φ : ℝ≥0∞ → Ω → ℝ≥0∞) (S : Set (Measure Ω)) : Prop :=
  ∀ P ∈ S, ∫⁻ ω, ⨆ α ∈ Ioo (0 : ℝ≥0∞) 1, φ α ω / α ∂P ≤ 1

/-- The tests `min (α * E) 1` of an e-variable are post-hoc valid [RW, Proposition 4.3]. -/
theorem IsEVar.isPostHocValid {E : Ω → ℝ≥0∞} {S : Set (Measure Ω)}
    (hS : ∀ P ∈ S, IsProbabilityMeasure P) (hE : IsEVar E S) :
    IsPostHocValid (fun α ω ↦ min (α * E ω) 1) S := by
  sorry

/-! ## Layer 1: log-optimal e-variables and the structure of nulls -/

/-- A powered test exists exactly outside the effective null [RW, Theorem 6.10]. -/
theorem exists_powered_test_iff {S : Set (Measure Ω)}
    (hS : ∀ P ∈ S, IsProbabilityMeasure P) (Q : Measure Ω) [IsProbabilityMeasure Q] :
    (∃ α : ℝ≥0∞, 0 < α ∧ α < 1 ∧ ∃ φ : Ω → ℝ≥0∞, Measurable φ ∧ (∀ ω, φ ω ≤ 1) ∧
        (∀ P ∈ S, ∫⁻ ω, φ ω ∂P ≤ α) ∧ α < ∫⁻ ω, φ ω ∂Q) ↔
      Q ∉ effectiveSet S := by
  sorry

/-- The null generated by a set of constraints [LRR26, Definition 2.1]. -/
def constraintNull {𝓧 : Type*} [MeasurableSpace 𝓧] (Φ : Set (𝓧 → ℝ)) : Set (Measure 𝓧) :=
  {μ | IsProbabilityMeasure μ ∧ ∀ f ∈ Φ, Integrable f μ ∧ ∫ x, f x ∂μ ≤ 0}

/-- The bets on finitely many constraints [LRR26, Corollary 3.3]. -/
def constraintBets {𝓧 : Type*} [MeasurableSpace 𝓧] {ι : Type*} [Fintype ι] (g : ι → 𝓧 → ℝ) :
    Set (ι → ℝ≥0) :=
  {π | ∀ μ ∈ constraintNull (range g), ∀ᵐ x ∂μ, 0 ≤ 1 + ∑ i, (π i : ℝ) * g i x}

/-- For finitely many constraints, every e-variable is quasi-surely dominated by a bet on the
constraints [LRR26, Theorem 3.1]. -/
theorem IsEVar.exists_le_one_add_sum_constraintNull {𝓧 : Type*} [MeasurableSpace 𝓧]
    {ι : Type*} [Fintype ι] (f : ι → 𝓧 → ℝ) (hf : ∀ i, Measurable (f i)) {E : 𝓧 → ℝ≥0∞}
    (hE : IsEVar E (constraintNull (range f))) :
    ∃ π : ι → ℝ≥0, ∀ μ ∈ constraintNull (range f),
      ∀ᵐ x ∂μ, E x ≤ ENNReal.ofReal (1 + ∑ i, (π i : ℝ) * f i x) := by
  sorry

/-- Lagrange duality for finitely many constraints under Slater's condition [Lue69, Chapter 8]. -/
theorem iInf_eq_iSup_iInf_add_of_slater {V : Type*} [AddCommGroup V] [Module ℝ V] {C : Set V}
    (hC : Convex ℝ C) {F : V → ℝ} (hF : ConvexOn ℝ C F) {ι : Type*} [Fintype ι] {h : ι → V → ℝ}
    (hh : ∀ i, ConvexOn ℝ C (h i)) (hslater : ∃ x₀ ∈ C, ∀ i, h i x₀ < 0)
    (hbdd : BddBelow (F '' {x ∈ C | ∀ i, h i x ≤ 0})) :
    ∃ π : ι → ℝ≥0, (⨅ x : {x ∈ C | ∀ i, h i x ≤ 0}, F x) =
      ⨅ x : C, (F x + ∑ i, (π i : ℝ) * h i x) := by
  sorry

/-- The dual formula for `KL_inf` of a finitely generated null under Slater's condition
(Layer 1.4). The right side is the expected logarithm of the best bet. -/
theorem iInf_klDiv_constraintNull_eq {𝓧 : Type*} [MeasurableSpace 𝓧] {ι : Type*} [Fintype ι]
    (g : ι → 𝓧 → ℝ) (hg : ∀ i, Measurable (g i)) (Q : Measure 𝓧) [IsProbabilityMeasure Q]
    (hslater : ∃ P : Measure 𝓧, IsProbabilityMeasure P ∧ klDiv Q P ≠ ⊤ ∧
      ∀ i, Integrable (g i) P ∧ ∫ x, g i x ∂P < 0) :
    ⨅ P ∈ constraintNull (range g), (klDiv Q P : EReal) =
      ⨆ π ∈ constraintBets g,
        elogIntegral (fun x ↦ ENNReal.ofReal (1 + ∑ i, (π i : ℝ) * g i x)) Q := by
  sorry

/-! ## Layer 2: test supermartingales, optional stopping and Ville's inequality -/

/-- A conditional e-variable given `m` for `S`, in set-integral form (Layer 2.1). -/
structure IsCondEVar (X : Ω → ℝ≥0∞) (m : MeasurableSpace Ω) (S : Set (@Measure Ω mΩ)) :
    Prop where
  measurable : Measurable[mΩ] X
  setLIntegral_le : ∀ P ∈ S, ∀ s, MeasurableSet[m] s → ∫⁻ ω in s, X ω ∂P ≤ P s

/-- An `ℝ≥0∞`-valued supermartingale for every member of `S`, in set-integral form
(Layer 2.1). -/
structure IsENNSupermartingale (M : ℕ → Ω → ℝ≥0∞) (ℱ : Filtration ℕ mΩ)
    (S : Set (Measure Ω)) : Prop where
  adapted : ∀ n, Measurable[ℱ n] (M n)
  setLIntegral_succ_le : ∀ P ∈ S, ∀ n s, MeasurableSet[ℱ n] s →
    ∫⁻ ω in s, M (n + 1) ω ∂P ≤ ∫⁻ ω in s, M n ω ∂P

/-- A test supermartingale for every member of `S`, with values in `ℝ≥0∞` [RW, Definition 7.3]. -/
structure IsTestSupermartingale (M : ℕ → Ω → ℝ≥0∞) (ℱ : Filtration ℕ mΩ)
    (S : Set (Measure Ω)) : Prop extends IsENNSupermartingale M ℱ S where
  lintegral_zero_le : ∀ P ∈ S, ∫⁻ ω, M 0 ω ∂P ≤ 1

/-- A test martingale for every member of `S` [RW, Definition 7.3]. -/
structure IsTestMartingale (M : ℕ → Ω → ℝ≥0∞) (ℱ : Filtration ℕ mΩ)
    (S : Set (Measure Ω)) : Prop where
  adapted : ∀ n, Measurable[ℱ n] (M n)
  lintegral_zero_le : ∀ P ∈ S, ∫⁻ ω, M 0 ω ∂P ≤ 1
  setLIntegral_succ_eq : ∀ P ∈ S, ∀ n s, MeasurableSet[ℱ n] s →
    ∫⁻ ω in s, M (n + 1) ω ∂P = ∫⁻ ω in s, M n ω ∂P

/-- The value of a process at a possibly infinite time, `limsup` at infinity
[RRLK; RLKR23, (1.2)]. -/
def stoppedValueLimsup (E : ℕ → Ω → ℝ≥0∞) (τ : Ω → WithTop ℕ) (ω : Ω) : ℝ≥0∞ :=
  if h : τ ω = ⊤ then limsup (fun n ↦ E n ω) atTop else E ((τ ω).untop h) ω

variable {ℱ : Filtration ℕ mΩ} {S : Set (Measure Ω)}

/-- Products of sequential e-variables are test supermartingales [RW, Proposition 7.20]. -/
theorem isTestSupermartingale_prod (hS : ∀ P ∈ S, IsProbabilityMeasure P)
    {E : ℕ → Ω → ℝ≥0∞} (hE_meas : ∀ k, Measurable[ℱ (k + 1)] (E k))
    (hE : ∀ k, IsCondEVar (E k) (ℱ k) S) :
    IsTestSupermartingale (fun n ω ↦ ∏ k ∈ Finset.range n, E k ω) ℱ S := by
  sorry

/-- Portfolio wealth processes are test supermartingales [WSJ26; RW, Definition 7.21]. The
portfolios are the points of `LMLExplore.simplex ι`, through `ENNReal.ofReal`. -/
theorem isTestSupermartingale_portfolio (hS : ∀ P ∈ S, IsProbabilityMeasure P)
    {ι : Type*} [Fintype ι] {E : ℕ → ι → Ω → ℝ≥0∞}
    (hE_meas : ∀ k i, Measurable[ℱ (k + 1)] (E k i)) (hE : ∀ k i, IsCondEVar (E k i) (ℱ k) S)
    {w : ℕ → Ω → ι → ℝ≥0∞} (hw : ∀ k i, Measurable[ℱ k] (fun ω ↦ w k ω i))
    (hw_sum : ∀ k ω, ∑ i, w k ω i = 1) :
    IsTestSupermartingale (fun n ω ↦ ∏ k ∈ Finset.range n, ∑ i, w k ω i * E k i ω) ℱ S := by
  sorry

/-- Optional stopping at arbitrary stopping times, with the value `limsup` at infinity
[RW, Fact 7.5]. -/
theorem IsTestSupermartingale.lintegral_stoppedValueLimsup_le {M : ℕ → Ω → ℝ≥0∞}
    {P : Measure Ω} [IsProbabilityMeasure P] (hM : IsTestSupermartingale M ℱ {P})
    {τ : Ω → WithTop ℕ} (hτ : IsStoppingTime ℱ τ) :
    ∫⁻ ω, stoppedValueLimsup M τ ω ∂P ≤ ∫⁻ ω, M 0 ω ∂P := by
  sorry

/-- Ville's inequality for test supermartingales in `ℝ≥0∞` [Vil39; RW, Fact 7.6]. -/
theorem IsTestSupermartingale.measure_exists_le_le {M : ℕ → Ω → ℝ≥0∞} {P : Measure Ω}
    [IsProbabilityMeasure P] (hM : IsTestSupermartingale M ℱ {P}) {c : ℝ≥0∞} (hc : c ≠ 0) :
    P {ω | ∃ n, c ≤ M n ω} ≤ (∫⁻ ω, M 0 ω ∂P) / c := by
  sorry

/-! ## Layer 3: e-processes -/

/-- An e-process for `S`: its value at every stopping time with values in `ℕ` is an e-variable
[RW, Definition 7.3(ii)]. -/
structure IsEProcess (E : ℕ → Ω → ℝ≥0∞) (ℱ : Filtration ℕ mΩ) (S : Set (Measure Ω)) :
    Prop where
  adapted : ∀ n, Measurable[ℱ n] (E n)
  isEVar_stoppedValue : ∀ τ : Ω → ℕ, IsStoppingTime ℱ (fun ω ↦ (τ ω : WithTop ℕ)) →
    IsEVar (fun ω ↦ E (τ ω) ω) S

/-- Ville's inequality for e-processes [RW, Fact 7.6]. -/
theorem IsEProcess.measure_exists_inv_le_le {E : ℕ → Ω → ℝ≥0∞} (hE : IsEProcess E ℱ S)
    {P : Measure Ω} (hP : P ∈ S) [IsProbabilityMeasure P] (α : ℝ≥0∞) :
    P {ω | ∃ n, α⁻¹ ≤ E n ω} ≤ α := by
  sorry

/-- The essential supremum of a family of functions, attained along a countable subfamily
[RRLK, Appendix A; FS16, §A.5]. -/
theorem exists_essSup_family {μ : Measure Ω} [SigmaFinite μ] (𝒳 : Set (Ω → ℝ≥0∞))
    (h𝒳 : 𝒳.Nonempty) (h𝒳_meas : ∀ X ∈ 𝒳, Measurable X) :
    ∃ Z : Ω → ℝ≥0∞, Measurable Z ∧ (∀ X ∈ 𝒳, X ≤ᵐ[μ] Z) ∧
      (∀ Y, Measurable Y → (∀ X ∈ 𝒳, X ≤ᵐ[μ] Y) → Z ≤ᵐ[μ] Y) ∧
      ∃ s : ℕ → Ω → ℝ≥0∞, (∀ n, s n ∈ 𝒳) ∧ Z =ᵐ[μ] fun ω ↦ ⨆ n, s n ω := by
  sorry

/-- The characterization of e-processes by test martingale families [RRLK, Lemma 6]. -/
theorem isEProcess_iff_forall_exists_isTestMartingale (hS : ∀ P ∈ S, IsProbabilityMeasure P)
    {E : ℕ → Ω → ℝ≥0∞} (hE : ∀ n, Measurable[ℱ n] (E n)) :
    IsEProcess E ℱ S ↔
      ∀ P ∈ S, ∃ M, IsTestMartingale M ℱ {P} ∧ ∀ᵐ ω ∂P, ∀ n, E n ω ≤ M n ω := by
  sorry

/-- Validity at every stopping time, with the value `limsup` at infinity [RRLK, Lemma 6]. -/
theorem IsEProcess.isEVar_stoppedValueLimsup (hS : ∀ P ∈ S, IsProbabilityMeasure P)
    {E : ℕ → Ω → ℝ≥0∞} (hE : IsEProcess E ℱ S) {τ : Ω → WithTop ℕ} (hτ : IsStoppingTime ℱ τ) :
    IsEVar (stoppedValueLimsup E τ) S := by
  sorry

/-- An adjuster, monotone on `[1, ∞]` [CR26; ShSVV11, Theorem 4]. -/
def IsAdjuster (A : ℝ≥0∞ → ℝ≥0∞) : Prop :=
  MonotoneOn A (Ici 1) ∧ ∫⁻ x in Ioi (1 : ℝ), A (ENNReal.ofReal x) / ENNReal.ofReal (x ^ 2) ≤ 1

/-- Adjusting the running maximum lifts an e-process to a finer filtration [CR26, Theorem 2]. -/
theorem IsEProcess.adjust {G : Filtration ℕ mΩ} (hGℱ : G ≤ ℱ)
    (hS : ∀ P ∈ S, IsProbabilityMeasure P) {E : ℕ → Ω → ℝ≥0∞} (hE : IsEProcess E G S)
    {A : ℝ≥0∞ → ℝ≥0∞} (hA : IsAdjuster A) (hA_meas : Measurable A) :
    IsEProcess (fun n ω ↦ A (max 1 (⨆ k ∈ Finset.range (n + 1), E k ω))) ℱ S := by
  sorry

/-- The inverse capital outer measure of [RLKR23, (2.1)]. -/
def inverseCapital (ℱ : Filtration ℕ mΩ) (S : Set (Measure Ω)) (A : Set Ω) : ℝ≥0∞ :=
  ⨅ (τ : Ω → WithTop ℕ) (_ : IsStoppingTime ℱ τ) (_ : A ⊆ {ω | τ ω < ⊤}),
    ⨆ P ∈ S, P {ω | τ ω < ⊤}

/-- The composite Ville theorem [RLKR23, Theorem 3.1]. -/
theorem inverseCapital_eq_zero_iff (hℱ : mΩ = ⨆ n, ℱ n) (hS : ∀ P ∈ S, IsProbabilityMeasure P)
    (A : Set Ω) :
    inverseCapital ℱ S A = 0 ↔
      ∃ E, IsEProcess E ℱ S ∧ ∀ ω ∈ A, Tendsto (fun n ↦ E n ω) atTop (𝓝 ⊤) := by
  sorry

/-! ## Layer 4: constructions of e-processes -/

/-- Likelihood ratios of a sequential predictor, given by its density `r k ω` with respect to the
conditional law `κ k ω` of the observation `X k` given `ℱ k`, are test supermartingales
(Layer 4.2). -/
theorem isTestSupermartingale_prod_density {𝓧 : Type*} [m𝓧 : MeasurableSpace 𝓧]
    {P : Measure Ω} [IsProbabilityMeasure P] {X : ℕ → Ω → 𝓧}
    (hX : ∀ k, Measurable[ℱ (k + 1)] (X k)) {κ : ℕ → Ω → Measure 𝓧}
    (hκ : ∀ k (g : Ω → 𝓧 → ℝ≥0∞),
      Measurable[(ℱ k : MeasurableSpace Ω).prod m𝓧] (Function.uncurry g) →
      ∀ s, MeasurableSet[ℱ k] s →
        ∫⁻ ω in s, g ω (X k ω) ∂P = ∫⁻ ω in s, ∫⁻ x, g ω x ∂(κ k ω) ∂P)
    {r : ℕ → Ω → 𝓧 → ℝ≥0∞}
    (hr : ∀ k, Measurable[(ℱ k : MeasurableSpace Ω).prod m𝓧] (Function.uncurry (r k)))
    (hr_le : ∀ k ω, ∫⁻ x, r k ω x ∂(κ k ω) ≤ 1) :
    IsTestSupermartingale (fun n ω ↦ ∏ k ∈ Finset.range n, r k ω (X k ω)) ℱ {P} := by
  sorry

/-- The sequential null of finitely many conditional constraints (Layer 4.4). -/
def seqConstraintNull {𝓧 : Type*} [MeasurableSpace 𝓧] {ι : Type*} [Fintype ι]
    (g : ι → 𝓧 → ℝ) (X : ℕ → Ω → 𝓧) (ℱ : Filtration ℕ mΩ) : Set (Measure Ω) :=
  {P | IsProbabilityMeasure P ∧ ∀ i k, Integrable (fun ω ↦ g i (X k ω)) P ∧
    ∀ s, MeasurableSet[ℱ k] s → ∫ ω in s, g i (X k ω) ∂P ≤ 0}

/-- Betting against conditional constraints is a test supermartingale (Layer 4.4); the betting
martingale of OnlineLearning 16.4 is the case of one mean constraint on `[0, 1]`. -/
theorem isTestSupermartingale_betting {𝓧 : Type*} [MeasurableSpace 𝓧] {ι : Type*} [Fintype ι]
    {g : ι → 𝓧 → ℝ} (hg : ∀ i, Measurable (g i)) {X : ℕ → Ω → 𝓧}
    (hX : ∀ k, Measurable[ℱ (k + 1)] (X k)) {π : ℕ → Ω → ι → ℝ≥0}
    (hπ : ∀ k i, Measurable[ℱ k] (fun ω ↦ π k ω i))
    (hπ_nonneg : ∀ k ω x, 0 ≤ 1 + ∑ i, (π k ω i : ℝ) * g i x) :
    IsTestSupermartingale
      (fun n ω ↦ ∏ k ∈ Finset.range n, ENNReal.ofReal (1 + ∑ i, (π k ω i : ℝ) * g i (X k ω)))
      ℱ (seqConstraintNull g X ℱ) := by
  sorry

/-- The complete class against conditional constraints [Cle26b, Theorem 1], for inequality
constraints: every e-process is dominated by a betting wealth (Layer 4.4). The observations are the
coordinates of `ℕ → 𝓧`, and `ℱ n` is generated by the first `n` of them. -/
theorem IsEProcess.exists_betting_dominates {𝓧 : Type*} [MeasurableSpace 𝓧]
    [StandardBorelSpace 𝓧] {ι : Type*} [Fintype ι] {g : ι → 𝓧 → ℝ} (hg : ∀ i, Measurable (g i))
    {ℱ : Filtration ℕ (MeasurableSpace.pi : MeasurableSpace (ℕ → 𝓧))}
    (hℱ : ∀ n, (ℱ n : MeasurableSpace (ℕ → 𝓧)) =
      MeasurableSpace.comap (fun ω (i : Fin n) ↦ ω i) MeasurableSpace.pi)
    {E : ℕ → (ℕ → 𝓧) → ℝ≥0∞} (hE : IsEProcess E ℱ (seqConstraintNull g (fun k ω ↦ ω k) ℱ)) :
    ∃ π : ℕ → (ℕ → 𝓧) → ι → ℝ≥0, (∀ k i, Measurable[ℱ k] (fun ω ↦ π k ω i)) ∧
      ∀ P ∈ seqConstraintNull g (fun k ω ↦ ω k) ℱ, ∀ᵐ ω ∂P, ∀ n,
        E n ω ≤ ∏ k ∈ Finset.range n, ENNReal.ofReal (1 + ∑ i, (π k ω i : ℝ) * g i (ω k)) := by
  sorry

/-! ## Layer 5: confidence sequences -/

/-- A confidence sequence at level `α` for the parameters of the nulls `S` (Layer 5.1). -/
def IsConfSeq {Θ : Type*} (C : ℕ → Ω → Set Θ) (ℱ : Filtration ℕ mΩ) (S : Θ → Set (Measure Ω))
    (α : ℝ≥0∞) : Prop :=
  (∀ θ n, MeasurableSet[ℱ n] {ω | θ ∈ C n ω}) ∧
    ∀ θ, ∀ P ∈ S θ, P {ω | ∃ n, θ ∉ C n ω} ≤ α

/-- Families of e-processes give confidence sequences (Layer 5.2). -/
theorem isConfSeq_of_isEProcess {Θ : Type*} {S : Θ → Set (Measure Ω)}
    (hS : ∀ θ, ∀ P ∈ S θ, IsProbabilityMeasure P) {E : Θ → ℕ → Ω → ℝ≥0∞}
    (hE : ∀ θ, IsEProcess (E θ) ℱ (S θ)) (α : ℝ≥0∞) :
    IsConfSeq (fun n ω ↦ {θ | E θ n ω < α⁻¹}) ℱ S α := by
  sorry

/-! ## Layer 6: growth rates, power and expected stopping times -/

/-- The maximal expected logarithm of an `n`-sample e-variable for the i.i.d. laws of `S₁`, under
the `n`-fold product of `Q₁` (Layer 6.1). It is Statlib's
`maxUtility (Measure.pi fun _ : Fin n ↦ Q₁) {Measure.pi fun _ ↦ P | P ∈ S₁} logUtility`; this
stand-in writes the supremum out. -/
def maxLogGrowth {𝓧 : Type*} [MeasurableSpace 𝓧] (Q₁ : Measure 𝓧) (S₁ : Set (Measure 𝓧))
    (n : ℕ) : EReal :=
  ⨆ (E : (Fin n → 𝓧) → ℝ≥0∞) (_ : IsEVar E ((fun P ↦ Measure.pi fun _ : Fin n ↦ P) '' S₁)),
    elogIntegral E (Measure.pi fun _ : Fin n ↦ Q₁)

/-- The optimal growth rate is superadditive, hence `maxLogGrowth Q₁ S₁ n / n` converges to its
supremum [RR26, Lemma 3.2, Theorem 3.5]. -/
theorem maxLogGrowth_add_le {𝓧 : Type*} [MeasurableSpace 𝓧] (Q₁ : Measure 𝓧)
    [IsProbabilityMeasure Q₁] (S₁ : Set (Measure 𝓧)) (hS₁ : ∀ P ∈ S₁, IsProbabilityMeasure P)
    (m n : ℕ) :
    maxLogGrowth Q₁ S₁ m + maxLogGrowth Q₁ S₁ n ≤ maxLogGrowth Q₁ S₁ (m + n) := by
  sorry

/-- The expected stopping time of a level-`α` sequential test for a null containing the i.i.d.
laws of `S₁` [ARR26, Theorem 3.1]. With `Filtration.piLE`, `τ + 1` observations have been made
at time `τ`; the README states it for `Filtration.naturalLT`, with `τ` observations. -/
theorem log_inv_le_lintegral_mul_iInf_klDiv {𝓧 : Type*} [MeasurableSpace 𝓧]
    (Q₁ : Measure 𝓧) [IsProbabilityMeasure Q₁] (S₁ : Set (Measure 𝓧))
    (hS₁ : ∀ P ∈ S₁, IsProbabilityMeasure P) {τ : (ℕ → 𝓧) → WithTop ℕ}
    (hτ : IsStoppingTime (Filtration.piLE (X := fun _ : ℕ ↦ 𝓧)) τ) {α : ℝ} (hα0 : 0 < α)
    (hα1 : α < 1)
    (hlevel : ∀ P ∈ S₁, Measure.infinitePi (fun _ : ℕ ↦ P) {ω | τ ω < ⊤} ≤ ENNReal.ofReal α)
    (hstop : ∀ᵐ ω ∂Measure.infinitePi (fun _ : ℕ ↦ Q₁), τ ω < ⊤) :
    ENNReal.ofReal (Real.log α⁻¹) ≤
      (∫⁻ ω, ENat.toENNReal (τ ω) + 1 ∂Measure.infinitePi (fun _ : ℕ ↦ Q₁)) *
        ⨅ P ∈ S₁, klDiv Q₁ P := by
  sorry

/-! ## Layer 7: merging e-values -/

/-- An e-merging function, defined through laws and not required to be monotone
[RW, Definition 8.1, Proposition A.3; Cle26]. -/
def IsEMerging {ι : Type*} [Fintype ι] (F : (ι → ℝ≥0∞) → ℝ≥0∞) : Prop :=
  Measurable F ∧ ∀ μ : Measure (ι → ℝ≥0∞), IsProbabilityMeasure μ →
    (∀ i, ∫⁻ e, e i ∂μ ≤ 1) → ∫⁻ e, F e ∂μ ≤ 1

/-- Every e-merging function is dominated by a weighted mean [Wan25, Theorem 1; Cle26]. -/
theorem IsEMerging.exists_le_weightedMean {ι : Type*} [Fintype ι] {F : (ι → ℝ≥0∞) → ℝ≥0∞}
    (hF : IsEMerging F) :
    ∃ (w : ι → ℝ≥0∞) (w₀ : ℝ≥0∞), w₀ + ∑ i, w i = 1 ∧
      ∀ e : ι → ℝ≥0, F (fun i ↦ e i) ≤ w₀ + ∑ i, w i * e i := by
  sorry

/-! ## Layer 8: multiple testing -/

section MultipleTesting

variable {ι : Type*} [Fintype ι]

/-- The true nulls under `P`. -/
def trueNulls (H : ι → Set (Measure Ω)) (P : Measure Ω) : Finset ι := by
  classical exact Finset.univ.filter fun i ↦ P ∈ H i

/-- The false discovery proportion of the rejections `R` when the true nulls are `N`. -/
def fdp [DecidableEq ι] (N R : Finset ι) : ℝ≥0∞ :=
  ((R ∩ N).card : ℝ≥0∞) / max (R.card : ℝ≥0∞) 1

/-- Compound e-variables for the nulls `H` [IWR, Definition 2.1; RW, Definition 9.1]. -/
def IsCompoundEVar (E : ι → Ω → ℝ≥0∞) (H : ι → Set (Measure Ω)) : Prop :=
  (∀ i, Measurable (E i)) ∧ ∀ P : Measure Ω, IsProbabilityMeasure P →
    ∑ i ∈ trueNulls H P, ∫⁻ ω, E i ω ∂P ≤ Fintype.card ι

/-- Self-consistent rejection sets control the false discovery rate under arbitrary dependence
[RW, Theorem 9.11; WR22, Proposition 2]. -/
theorem lintegral_fdp_le_of_selfConsistent [DecidableEq ι] {E : ι → Ω → ℝ≥0∞}
    {H : ι → Set (Measure Ω)} (hE : IsCompoundEVar E H) {α : ℝ≥0∞} {R : Ω → Finset ι}
    (hR_meas : ∀ i, MeasurableSet {ω | i ∈ R ω})
    (hR : ∀ ω, ∀ i ∈ R ω, (Fintype.card ι : ℝ≥0∞) ≤ α * (R ω).card * E i ω)
    (P : Measure Ω) [IsProbabilityMeasure P] :
    ∫⁻ ω, fdp (trueNulls H P) (R ω) ∂P ≤ α := by
  sorry

/-- An e-collection [XSF+26, Definition 5]. -/
def IsECollection (e : Finset ι → Ω → ℝ≥0∞) (H : ι → Set (Measure Ω)) : Prop :=
  (∀ S, Measurable (e S)) ∧ (∀ ω, e ∅ ω = 0) ∧
    ∀ P : Measure Ω, IsProbabilityMeasure P → ∫⁻ ω, e (trueNulls H P) ω ∂P ≤ 1

/-- The e-Closure Principle [XSF+26, Theorem 6]. -/
theorem eClosure (H : ι → Set (Measure Ω)) (f : Finset ι → Finset ι → ℝ≥0∞)
    (hf₁ : ∀ N, f N ∅ = 0) (hf₂ : ∀ R, f ∅ R = 0) (𝓡 : Ω → Set (Finset ι))
    (h𝓡 : ∀ R, MeasurableSet {ω | R ∈ 𝓡 ω}) {α : ℝ≥0∞} (hα0 : α ≠ 0) (hα : α ≠ ⊤) :
    (∀ P : Measure Ω, IsProbabilityMeasure P →
        ∫⁻ ω, ⨆ R ∈ 𝓡 ω, f (trueNulls H P) R ∂P ≤ α) ↔
      ∃ e, IsECollection e H ∧ ∀ ω, 𝓡 ω ⊆ {R | ∀ S, f S R ≤ α * e S ω} := by
  sorry

end MultipleTesting

/-! ## Layer 9: change detection -/

/-- An e-detector for a pre-change null [SRR24, Definition 2.2]. -/
def IsEDetector (M : ℕ → Ω → ℝ≥0∞) (ℱ : Filtration ℕ mΩ) (S : Set (Measure Ω)) : Prop :=
  (∀ n, Measurable[ℱ n] (M n)) ∧ ∀ P ∈ S, ∀ τ : Ω → ℕ,
    IsStoppingTime ℱ (fun ω ↦ (τ ω : WithTop ℕ)) →
      ∫⁻ ω, M (τ ω) ω ∂P ≤ ∫⁻ ω, (τ ω : ℝ≥0∞) ∂P

/-- The average run length of an e-detector is at least `α⁻¹` [SRR24, Theorem 2.4]. -/
theorem IsEDetector.inv_le_lintegral_hittingAfter {M : ℕ → Ω → ℝ≥0∞}
    (hM : IsEDetector M ℱ S) {P : Measure Ω} (hP : P ∈ S) [IsProbabilityMeasure P]
    (α : ℝ≥0∞) :
    α⁻¹ ≤ ∫⁻ ω, ENat.toENNReal (hittingAfter M (Ici α⁻¹) 0 ω) ∂P := by
  sorry

end LMLRoadmaps.EValues
