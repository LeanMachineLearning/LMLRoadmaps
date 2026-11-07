import Mathlib.Analysis.Convex.Strong
import Mathlib.Analysis.InnerProductSpace.Basic
import Mathlib.Analysis.Normed.Lp.PiLp
import Mathlib.Analysis.SpecialFunctions.Gamma.BohrMollerup
import Mathlib.InformationTheory.KullbackLeibler.Basic
import Mathlib.MeasureTheory.Measure.Tilted
import Mathlib.Order.SaddlePoint
import Mathlib.Probability.Martingale.Basic
import LeanMachineLearning.ForMathlib.Analysis.Convex.Bregman.Basic
import LeanMachineLearning.ForMathlib.Analysis.Convex.Subgradient.Basic
import TauCeti.Analysis.Convex.Conjugate

/-!
# Online learning through convex optimization: suggested target signatures

**This file is not the roadmap and is not exhaustive.** The definitive document is `README.md`.
The statements here suggest Lean forms for particular milestones, so that contributors and
reviewers converge on names and signatures; discharging all of them finishes neither a milestone
nor the roadmap. The admitted proofs are targets, not claimed implementations, and the admitted
definitions (the Lambert function) are specified by the README.

Rounds are numbered from `0`: the book's round `t` is round `t - 1` here, and the book's analysis
points `x_{T+1}` and `ψ_{T+1}` are `x n` and `ψ n`. Losses of online linear optimization live in
the dual `E →L[ℝ] ℝ` of a real normed space `E`, as in the Bandits roadmap's Layer 6.
-/

noncomputable section

open MeasureTheory ProbabilityTheory InformationTheory Filter Real Finset
open scoped ENNReal NNReal Topology

namespace LMLRoadmaps.OnlineLearning

variable {α : Type*}

/-! ## Layer 0: regret notions, online learners and the FTRL equality -/

/-- The regret of the plays `x` against the comparator `u` after `n` rounds of the losses `ℓ`. -/
def regret (ℓ : ℕ → α → ℝ) (x : ℕ → α) (u : α) (n : ℕ) : ℝ :=
  ∑ t ∈ range n, (ℓ t (x t) - ℓ t u)

/-- The dynamic regret against a sequence of comparators [Ora, Definition 14.1]. -/
def dynRegret (ℓ : ℕ → α → ℝ) (x u : ℕ → α) (n : ℕ) : ℝ :=
  ∑ t ∈ range n, (ℓ t (x t) - ℓ t (u t))

/-- The regret on the interval of rounds `[s, s + τ)`. -/
def intervalRegret (ℓ : ℕ → α → ℝ) (x : ℕ → α) (u : α) (s τ : ℕ) : ℝ :=
  ∑ t ∈ Ico s (s + τ), (ℓ t (x t) - ℓ t u)

/-- The path length of a sequence of comparators over `n` rounds. -/
def pathLength {E : Type*} [NormedAddCommGroup E] (u : ℕ → E) (n : ℕ) : ℝ :=
  ∑ t ∈ range (n - 1), ‖u (t + 1) - u t‖

/-- A causal online learner: the play of round `t`, from the contexts and feedback of the rounds
`s < t` and the context of round `t` (for example the active experts, or a hint). -/
structure OnlineLearner (C G X : Type*) where
  /-- The play of round `t`. -/
  play : (t : ℕ) → (Fin t → C × G) → C → X

namespace OnlineLearner

variable {C G X : Type*}

/-- The plays of a learner against fixed sequences of contexts and feedback. -/
def run (A : OnlineLearner C G X) (c : ℕ → C) (g : ℕ → G) (t : ℕ) : X :=
  A.play t (fun s ↦ (c s, g s)) (c t)

/-- The feedback of a closed-loop run, in which the feedback of round `t` is `φ t` applied to the
play of round `t`: surrogate losses are of this form (README Layer 0.2). -/
def closedLoopHist (A : OnlineLearner C G X) (c : ℕ → C) (φ : ℕ → X → G) :
    (t : ℕ) → Fin t → G
  | 0 => Fin.elim0
  | t + 1 => Fin.snoc (α := fun _ ↦ G) (closedLoopHist A c φ t)
      (φ t (A.play t (fun s ↦ (c s, closedLoopHist A c φ t s)) (c t)))

/-- The feedback sequence of the closed-loop run. -/
def closedLoopFeedback (A : OnlineLearner C G X) (c : ℕ → C) (φ : ℕ → X → G) (t : ℕ) : G :=
  closedLoopHist A c φ (t + 1) (Fin.last t)

/-- The learner restarted at round `s`: from round `s` on, it plays as `A` on the shifted history;
before, it plays as `A` at its first round. -/
def restart (A : OnlineLearner C G X) (s : ℕ) : OnlineLearner C G X where
  play t h c :=
    if hst : s ≤ t then A.play (t - s) (fun i ↦ h ⟨s + i, by omega⟩) c else A.play 0 Fin.elim0 c

end OnlineLearner

/-- A regret guarantee for a learner of online linear optimization: every run whose feedback is
admissible has linear regret at most `B n c y u` against every comparator `u ∈ U`. -/
def HasRegretBound {C E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
    (A : OnlineLearner C (E →L[ℝ] ℝ) E) (adm : C → (E →L[ℝ] ℝ) → Prop) (U : Set E)
    (B : ℕ → (ℕ → C) → (ℕ → E →L[ℝ] ℝ) → E → ℝ) : Prop :=
  ∀ (c : ℕ → C) (y : ℕ → E →L[ℝ] ℝ) (n : ℕ), (∀ t < n, adm (c t) (y t)) →
    ∀ u ∈ U, ∑ t ∈ range n, y t (A.run c y t - u) ≤ B n c y u

/-- **The FTRL equality** [Ora, Lemma 7.1], for arbitrary losses, regularizers and points on an
arbitrary type. No convexity and no minimality is used. -/
theorem regret_eq_ftrl (ψ ℓ : ℕ → α → ℝ) (x : ℕ → α) (u : α) (n : ℕ) :
    regret ℓ x u n = ψ n u - ψ 0 (x 0) +
      ∑ t ∈ range n, ((ψ t (x t) + ∑ s ∈ range t, ℓ s (x t)) -
        (ψ (t + 1) (x (t + 1)) + ∑ s ∈ range (t + 1), ℓ s (x (t + 1))) + ℓ t (x t)) +
      ((ψ n (x n) + ∑ s ∈ range n, ℓ s (x n)) - (ψ n u + ∑ s ∈ range n, ℓ s u)) :=
  sorry

/-- **Be-the-leader** [Ora, Lemma 1.2]: playing at each round the leader including the current
loss has nonpositive regret. -/
theorem sum_le_of_isMinOn_sum (ℓ : ℕ → α → ℝ) (x : ℕ → α)
    (hx : ∀ t, IsMinOn (fun a ↦ ∑ s ∈ range (t + 1), ℓ s a) Set.univ (x (t + 1))) (u : α)
    (n : ℕ) :
    ∑ t ∈ range n, ℓ t (x (t + 1)) ≤ ∑ t ∈ range n, ℓ t u :=
  sorry

/-! ## Layer 1: convex analysis for online learning -/

section Convex

variable {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]

/-- **Strong convexity gives a quadratic minorant** at every subgradient within the set
[Ora, Lemma 4.2]. -/
theorem StrongConvexOn.add_apply_sub_add_le {V : Set E} {m : ℝ} {f : E → ℝ}
    (hf : StrongConvexOn V m f) {g : E →L[ℝ] ℝ} {x y : E}
    (hg : HasSubgradientWithinAt f g V y) (hy : y ∈ V) (hx : x ∈ V) :
    f y + g (x - y) + m / 2 * ‖x - y‖ ^ 2 ≤ f x :=
  sorry

/-- **Minimizers of strongly convex functions** [Ora, Theorem 6.9]: in finite dimension, a
strongly convex, lower semicontinuous function on a nonempty closed convex set has exactly one
minimizer there. -/
theorem StrongConvexOn.existsUnique_isMinOn [FiniteDimensional ℝ E] {V : Set E} {m : ℝ}
    {f : E → ℝ} (hf : StrongConvexOn V m f) (hm : 0 < m) (hV : IsClosed V) (hVne : V.Nonempty)
    (hlsc : LowerSemicontinuousOn f V) :
    ∃! x, x ∈ V ∧ IsMinOn f V x :=
  sorry

/-- A function is `s`-self-bounded within `V` [Ora, Definition 4.26]: it is bounded below, and
every subgradient within `V` at a point of `V` has squared norm at most `2 s (f x - inf f)`. -/
def IsSelfBoundedOn (V : Set E) (s : ℝ) (f : E → ℝ) : Prop :=
  BddBelow (Set.range f) ∧ ∀ x ∈ V, ∀ g : E →L[ℝ] ℝ, HasSubgradientWithinAt f g V x →
    ‖g‖ ^ 2 ≤ 2 * s * (f x - ⨅ z, f z)

/-- The pairing of `E` with its dual, `(x, y) ↦ y x`, as the bilinear map taken by Tau Ceti's
`fenchelConjugate`. -/
def dualPairing : E →ₗ[ℝ] (E →L[ℝ] ℝ) →ₗ[ℝ] ℝ :=
  LinearMap.mk₂ ℝ (fun x y ↦ y x) (fun x x' y ↦ by simp) (fun c x y ↦ by simp)
    (fun x y y' ↦ by simp) (fun c x y ↦ by simp)

/-- **The conjugate of a squared norm** [Ora, Example 6.19]. -/
theorem fenchelConjugate_mul_norm_sq {s : ℝ} (hs : 0 < s) (y : E →L[ℝ] ℝ) :
    TauCeti.fenchelConjugate dualPairing (fun x : E ↦ ((s / 2 * ‖x‖ ^ 2 : ℝ) : EReal)) y =
      ((1 / (2 * s) * ‖y‖ ^ 2 : ℝ) : EReal) :=
  sorry

end Convex

/-- **The `p`-norm potential is strongly convex** [Ora, Lemma 6.35]. -/
theorem strongConvexOn_norm_sq_piLp [Fintype α] {p : ℝ≥0∞} [Fact (1 ≤ p)] (hp1 : 1 < p)
    (hp2 : p ≤ 2) :
    StrongConvexOn Set.univ (p.toReal - 1) (fun x : PiLp p (fun _ : α ↦ ℝ) ↦ ‖x‖ ^ 2 / 2) :=
  sorry

/-! ## Layer 4: lower bounds and the coin-betting game -/

/-- The wealth of a bettor with initial wealth `ε`, coins `c` and bets `x`, before round `t`. -/
def wealth (ε : ℝ) (c x : ℕ → ℝ) (t : ℕ) : ℝ :=
  ε + ∑ s ∈ range t, c s * x s

/-- The Lambert function on `[0, ∞)`, the inverse of `w ↦ w * exp w` (README Layer 4.4). -/
def lambertW (x : ℝ) : ℝ :=
  sorry

theorem lambertW_mul_exp_lambertW {x : ℝ} (hx : 0 ≤ x) : lambertW x * exp (lambertW x) = x :=
  sorry

/-! ## Layer 5: FTRL for convex losses -/

section FTRL

variable {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]

/-- **Stability without derivatives** [Ora, Lemma 7.5]: if `x t` minimizes
`F_t = ψ_t + ∑_{s < t} ℓ_s` on `V`, `g` is a subgradient of `ℓ t` within `V` at `x t` and
`F_t + ℓ_t` is `λ`-strongly convex on `V`, then the one-round term of the FTRL equality at any
`z ∈ V` is at most `‖g‖² / (2 λ)` plus the increment of the regularizer at `z`. -/
theorem ftrl_stability_le {V : Set E} (hV : Convex ℝ V) (ψ ℓ : ℕ → E → ℝ) (x : ℕ → E) (t : ℕ)
    (hx : IsMinOn (fun a ↦ ψ t a + ∑ s ∈ range t, ℓ s a) V (x t)) (hxV : x t ∈ V)
    {lam : ℝ} (hlam : 0 < lam)
    (hF : StrongConvexOn V lam (fun a ↦ ψ t a + ∑ s ∈ range (t + 1), ℓ s a))
    {g : E →L[ℝ] ℝ} (hg : HasSubgradientWithinAt (ℓ t) g V (x t)) {z : E} (hz : z ∈ V) :
    (ψ t (x t) + ∑ s ∈ range t, ℓ s (x t)) + ℓ t (x t) -
        (ψ (t + 1) z + ∑ s ∈ range (t + 1), ℓ s z) ≤
      ‖g‖ ^ 2 / (2 * lam) + (ψ t z - ψ (t + 1) z) :=
  sorry

end FTRL

/-! ## Layer 8: exp-concave losses -/

/-- `f` is `α`-exp-concave on `V` [Ora, Definition 7.31]: `exp (-α f)` is concave on `V`. -/
def ExpConcaveOn {E : Type*} [AddCommGroup E] [Module ℝ E] (V : Set E) (a : ℝ) (f : E → ℝ) :
    Prop :=
  ConcaveOn ℝ V (fun x ↦ exp (-(a * f x)))

/-! ## Layer 10: Gibbs mixtures and the Aggregating Algorithm -/

section Mixtures

variable {Θ : Type*} [MeasurableSpace Θ]

/-- The mix loss of cumulative losses `L` under the prior `ν` at temperature `lam`. -/
def mixLoss (ν : Measure Θ) (L : Θ → ℝ) (lam : ℝ) : ℝ :=
  -lam * log (∫ θ, exp (-(L θ / lam)) ∂ν)

/-- The Gibbs measure of the cumulative losses `L` at temperature `lam`. -/
def gibbs (ν : Measure Θ) (L : Θ → ℝ) (lam : ℝ) : Measure Θ :=
  ν.tilted fun θ ↦ -(L θ / lam)

/-- **The variational formula of the mix loss** ([Ora, (11.5)], Donsker–Varadhan). -/
theorem mixLoss_le_integral_add_klDiv (ν : Measure Θ) [IsProbabilityMeasure ν] {L : Θ → ℝ}
    (hL : Measurable L) (hLb : BddBelow (Set.range L)) {lam : ℝ} (hlam : 0 < lam)
    (Q : Measure Θ) [IsProbabilityMeasure Q] (hQ : Q ≪ ν) (hLQ : Integrable L Q) :
    mixLoss ν L lam ≤ ∫ θ, L θ ∂Q + lam * (klDiv Q ν).toReal :=
  sorry

/-- A loss on predictions `Γ` and outcomes `Ω` is `η`-mixable [Ora, Definition 11.7; Vovk 1990]:
for every probability measure on predictions, some prediction has loss at most the mix loss on
every outcome. -/
def IsMixable {Γ Ω : Type*} [MeasurableSpace Γ] (loss : Γ → Ω → ℝ) (η : ℝ) : Prop :=
  ∀ P : Measure Γ, IsProbabilityMeasure P →
    ∃ γ₀ : Γ, ∀ ω, loss γ₀ ω ≤ -(1 / η) * log (∫ γ, exp (-(η * loss γ ω)) ∂P)

end Mixtures

/-! ## Layer 13: parameter-free learning through coin betting -/

/-- The betting fraction of the Krichevsky–Trofimov bettor at round `t`. -/
def ktFraction (c : ℕ → ℝ) (t : ℕ) : ℝ :=
  (∑ s ∈ range t, c s) / (t + 1)

/-- The wealth of the Krichevsky–Trofimov bettor with initial wealth `ε` before round `t`. -/
def ktWealth (ε : ℝ) (c : ℕ → ℝ) : ℕ → ℝ
  | 0 => ε
  | t + 1 => ktWealth ε c t * (1 + c t * ktFraction c t)

/-- **The wealth of the Krichevsky–Trofimov bettor** [Ora, Theorem 13.4]. -/
theorem le_ktWealth {ε : ℝ} (hε : 0 < ε) {c : ℕ → ℝ} (hc : ∀ t, c t ∈ Set.Icc (-1 : ℝ) 1)
    {n : ℕ} (hn : 1 ≤ n) :
    ε * exp ((∑ t ∈ range n, c t) ^ 2 / (2 * n) - log n / 2 - 1) ≤ ktWealth ε c n :=
  sorry

section Duality

variable {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]

/-- **Regret–reward duality** [Ora, Theorem 13.5], the direction that holds for every `φ`: a lower
bound on the reward by `φ` of the negated cumulative loss bounds the regret against every `u` by
the conjugate of `φ`. -/
theorem sum_apply_sub_le_fenchelConjugate (φ : (E →L[ℝ] ℝ) → EReal) (y : ℕ → E →L[ℝ] ℝ)
    (x : ℕ → E) (n : ℕ)
    (h : φ (-∑ t ∈ range n, y t) ≤ ((-∑ t ∈ range n, y t (x t) : ℝ) : EReal)) (u : E) :
    ((∑ t ∈ range n, y t (x t - u) : ℝ) : EReal) ≤
      TauCeti.fenchelConjugate (dualPairing (E := E)).flip φ u :=
  sorry

end Duality

/-! ## Layer 15: saddle points and games -/

section SaddlePoint

variable {E F : Type*} [AddCommGroup E] [Module ℝ E] [AddCommGroup F] [Module ℝ F]

/-- The duality gap of `(x', y')` for the problem `min_{x ∈ X} max_{y ∈ Y} f x y`
[Ora, Definition 15.8]. -/
def dualityGap (X : Set E) (Y : Set F) (f : E → F → ℝ) (x' : E) (y' : F) : EReal :=
  (⨆ y ∈ Y, (f x' y : EReal)) - ⨅ x ∈ X, (f x y' : EReal)

/-- **No-regret dynamics** [Ora, Theorem 15.12]: for arbitrary plays of the two players, the gap
of the averages against any `(x, y)` is at most the sum of the two regrets divided by `n`. No
property of the learners is used. -/
theorem sub_le_regret_add_regret_div {X : Set E} {Y : Set F} {f : E → F → ℝ}
    (hfx : ∀ y ∈ Y, ConvexOn ℝ X fun x ↦ f x y) (hfy : ∀ x ∈ X, ConcaveOn ℝ Y (f x))
    (xs : ℕ → E) (ys : ℕ → F) (hxs : ∀ t, xs t ∈ X) (hys : ∀ t, ys t ∈ Y) {n : ℕ} (hn : 0 < n)
    {x : E} (hx : x ∈ X) {y : F} (hy : y ∈ Y) :
    f ((n : ℝ)⁻¹ • ∑ t ∈ range n, xs t) y - f x ((n : ℝ)⁻¹ • ∑ t ∈ range n, ys t) ≤
      (regret (fun t a ↦ f a (ys t)) xs x n + regret (fun t b ↦ -f (xs t) b) ys y n) / n :=
  sorry

end SaddlePoint

/-! ## Layer 16: betting confidence sequences -/

/-- **The betting martingale** (README Layer 16.4): for data in `[0, 1]` with conditional mean
`μ` and predictable bets in `[-1 / (1 - μ), 1 / μ]`, the wealth of the bettor is a nonnegative
martingale. No moment generating function is involved. -/
theorem martingale_prod_one_add_mul_sub {Ω : Type*} {mΩ : MeasurableSpace Ω} {P : Measure Ω}
    [IsProbabilityMeasure P] {𝓕 : Filtration ℕ mΩ} {Z β : ℕ → Ω → ℝ} {μ : ℝ}
    (hμ : μ ∈ Set.Ioo 0 1) (hZ : ∀ t, StronglyMeasurable[𝓕 (t + 1)] (Z t))
    (hZ01 : ∀ t ω, Z t ω ∈ Set.Icc 0 1) (hZμ : ∀ t, P[Z t|𝓕 t] =ᵐ[P] fun _ ↦ μ)
    (hβ : ∀ t, StronglyMeasurable[𝓕 t] (β t))
    (hβb : ∀ t ω, β t ω ∈ Set.Icc (-1 / (1 - μ)) (1 / μ)) :
    Martingale (fun t ω ↦ ∏ s ∈ range t, (1 + β s ω * (Z s ω - μ)))
      𝓕 P :=
  sorry

end LMLRoadmaps.OnlineLearning
