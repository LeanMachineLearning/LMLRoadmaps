# Roadmap: Online learning through convex optimization

Develop the theory of online learning with full information: regret minimization against
arbitrary, adaptively chosen sequences of losses, in the generality of convex analysis, following
F. Orabona, *Online Learning: A Modern Introduction Using Convex Optimization* [Ora]. The headline
results are:
- adaptive and AdaGrad-type rates, $L^\star$ bounds and logarithmic regret for strongly convex and
  exp-concave losses (the Online Newton Step, the Vovk–Azoury–Warmuth forecaster);
- online-to-batch conversions, in expectation and with high probability;
- the minimax lower bounds of online linear optimization, bounded and unconstrained;
- optimistic mirror descent and optimistic FTRL, with delayed feedback and gradual variations;
- the Perceptron and the Gaptron;
- the Aggregating Algorithm for mixable losses and Cover's universal portfolio;
- black-box reductions, and parameter-free algorithms through coin betting (Krichevsky–Trofimov);
- dynamic, strongly adaptive and tracking regret;
- no-regret dynamics for saddle points, with fast rates through optimism;
- online-learning proofs of statistical results: Rademacher complexity bounds, PAC-Bayes bounds,
  non-convex optimization, and time-uniform confidence sequences by betting.

Build the surrounding library at the generality the proofs support:
- online learners as composable objects, and regret notions;
- the FTRL equality for arbitrary losses on arbitrary sets, and a stability lemma that needs no
  derivative of the regularizer;
- strong convexity and smoothness through subgradients and conjugates;
- the distance to a convex set, $p$-norm potentials, exp-concavity and mixability;
- Gibbs mixtures over arbitrary priors;
- the coin-betting game, the Lambert function and the Gamma-function inequalities that the
  regret bounds use.

`README.md` is the definitive specification; `Suggested.lean` records selected interfaces and is
not an exhaustive checklist.

Suggested homes: `LMLExplore/OnlineLearning/` (namespace `LMLExplore.OnlineLearning`) for online
learning, and the mathematical home of each general tool:
- `LMLExplore/Analysis/Convex/` for strong convexity, smoothness, conjugates, distance functions,
  $p$-norm potentials and exp-concavity;
- `LMLExplore/Analysis/SpecialFunctions/` for the Lambert function and the Gamma-function
  inequalities;
- `LMLExplore/Probability/Martingale/` for betting martingales and the conditional Hoeffding lemma;
- `LMLExplore/Optimization/` for saddle points and stochastic optimization.

## Scope and dependencies

This roadmap owns regret minimization with full information against arbitrary loss sequences:
online linear and convex optimization, prediction with expert advice, online classification and
regression, portfolio selection and coin betting. It also owns their applications to stochastic
optimization, saddle-point problems and the statistical results of Layer 16.

**Relation to the Bandits roadmap.** The [Bandits](../Bandits/README.md) roadmap's Layer 6
specifies the core that its bandit algorithms use, and this roadmap cites it by item number and does
not restate it:
- Legendre functions (6.1) and Bregman projections (6.2);
- follow-the-regularized-leader and mirror descent with time-varying regularizers, nonincreasing
  learning rates and the first local-norm bound (6.3);
- exponential weights on a finite set, with its anytime local-norm bound (6.4);
- estimated losses (6.5);
- online convex optimization through subgradients, and projected online subgradient descent
  (6.6).

The rest of [Ora]'s full-information material is specified here, except what the list below
excludes. In particular, the items of Layers 5–7 extend Bandits 6.3 with statements it does not
contain.

| Material | Owner and interface consumed here |
| --- | --- |
| FTRL, mirror descent, exponential weights, linearization, projected OSD | Bandits roadmap, Layer 6; LMLExplore `OnlineLearning/` |
| Binary relative entropy `klBer` and Pinsker for Bernoulli laws; Bernoulli laws are $\tfrac14$-sub-Gaussian | Bandits roadmap, Layers 0.1–0.2 |
| Ville's inequality | Bandits roadmap, Layer 1.1; LMLExplore `MeasureTheory.Supermartingale.measure_exists_le_le` |
| Bounded variables are conditionally dominated by Bernoulli laws | Bandits roadmap, Layer 1.4 |
| Design operators $V_0+\sum_{s<t}x_s\otimes x_s$, weighted norms, the elliptical potential lemma | Bandits roadmap, Layers 8.1–8.2; LMLExplore `designOp` |
| Conditional MGF domination and exponential supermartingales | Identification roadmap, Layer 4.2 |
| AdaHedge | Identification roadmap, Layer 6.1; LMLExplore `adaHedge` |
| Softmax and log-sum-exp | ReinforcementLearning roadmap, Layer 5.1 |
| Gradient methods for smooth functions on inner product spaces | ReinforcementLearning roadmap, Layer 5.2 |
| Bregman proximal steps with relative strong convexity [Ora, Lemmas 6.7 and 6.10] | ReinforcementLearning roadmap, Layer 5.3 |
| Bregman divergence, subgradients within a set | LML `ForMathlib/Analysis/Convex/Bregman/`, `ForMathlib/Analysis/Convex/Subgradient/` (`bregDiv`, `HasSubgradientWithinAt`) |
| Fenchel conjugate, Fenchel–Moreau, subdifferential, existence of subgradients in the interior | Tau Ceti `Analysis/Convex/Conjugate.lean`, `FenchelMoreau.lean`, `Subdifferential.lean`, `SubgradientImage.lean` |
| Proximal operator | Tau Ceti `Analysis/GradientFlow/MoreauYosida/Basic.lean` (`moreauYosidaResolvent`) |
| Donsker–Varadhan, KL divergence of tilted measures | Tau Ceti `InformationTheory/KullbackLeibler/Variational.lean`, `Tilted.lean` |
| Dirichlet laws and their moments | Tau Ceti `Probability/Distributions/Dirichlet/` (`dirichletMeasure`, `integral_prod_pow_dirichletMeasure`) |
| Saddle points, weak duality, Sion's minimax theorem | Mathlib `Order/SaddlePoint.lean` (`IsSaddlePointOn`), `Topology/Sion.lean` (`Sion.exists_isSaddlePointOn`) |
| Gamma function, log-convexity, Bohr–Mollerup, Stirling | Mathlib `Real.Gamma`, `Real.convexOn_log_Gamma`, `Real.BohrMollerup.tendsto_logGammaSeq`, `Stirling` |
| Sub-Gaussian variables, Azuma–Hoeffding | Mathlib `Probability/Moments/SubGaussian.lean` (`HasCondSubgaussianMGF`, `measure_sum_ge_le_of_hasCondSubgaussianMGF`) |
| Tilted measures, KL divergence | Mathlib `Measure.tilted`, `InformationTheory.klDiv` |

Build missing material in this roadmap where it is listed as a target, and consume existing
implementations directly.

**Outside this roadmap:**
- **Bandit feedback** ([Ora, Chapter 9]):
  - Exp3 belongs to Bandits Layer 7; explore-then-commit and UCB to LML and Bandits Layer 2.
  - The Lai–Robbins lower bound belongs to Bandits Layer 4.4. [Ora, Theorem 9.16] misstates its
    constant as $\sum_i1/(2\Delta_i)$; the correct constant is
    $\sum_i\Delta_i/\mathrm{kl}(\mu_i,\mu^\star)$.
  - Tsallis-INF and its best-of-both-worlds guarantee ([Ora, §9.1.2, §9.3]) belong to Bandits
    Layer 7.5, which uses Layer 6.1 here.
- **AdaHedge** ([Ora, §7.6]) belongs to the Identification roadmap.
- **Statistical learning theory beyond the reductions of Layer 16:** generalization bounds from
  Rademacher complexity, the contraction lemma, VC theory, and the classical PAC-Bayes bounds proved
  through Donsker–Varadhan.
- **The rest of the book:**
  - extensive-form games and Zermelo's theorem ([Ora, §15.3.1]), and the generalization of boosting;
  - the group norms of [Ora, §7.7];
  - the scale-free FTRL and AdaFTRL of [Ora, §7.6] (Lemma 7.16);
  - the dual analysis of FTRL ([Ora, Lemma 7.10, Remark 7.11]) and the equivalence of FTRL and
    mirror descent ([Ora, §7.3.1]).

## Conventions

**Sources and numbering.** Statements follow [Ora], cited by the numbering of its tenth arXiv
version, like the Bandits roadmap. The book's rounds are numbered from 1 and Lean rounds from 0:
- book round $t$ is Lean round $t-1$;
- the book's horizon $T$ is the Lean horizon $n$ (rounds $0,\dots,n-1$);
- the book's analysis points $x_{T+1}$ and $\psi_{T+1}$ are `x n` and `ψ n`.

**Spaces and losses.** Work, as Bandits Layer 6 does, in a real normed space `E`, with losses and
subgradients in its dual `E →L[ℝ] ℝ`.
- Dual norms are operator norms, strong convexity is Mathlib's `StrongConvexOn` for the norm of
  `E`, and subgradients within a set are LML's `HasSubgradientWithinAt`.
- The regret of plays $x_t$ against a comparator $u$ is $\sum_{t<n}(\ell_t(x_t)-\ell_t(u))$ for
  losses $\ell_t:E\to\mathbb R$, and $\sum_{t<n}y_t(x_t-u)$ for linear losses $y_t$.
- Finite dimension is assumed only where a proof needs it: existence of minimizers on closed
  unbounded sets, attainment of dual norms, Hessians and determinants.
- Euclidean algorithms (projected subgradient descent, the Perceptron, the Online Newton Step,
  Vovk–Azoury–Warmuth) live in a real inner product space, with operators `E →L[ℝ] E` and the
  Loewner order instead of matrices.
- Coordinates appear only where they are intrinsic: experts, the simplex, boxes, $p$-norms and
  coordinatewise algorithms. They live on `α → ℝ` or `PiLp p (fun _ : α ↦ ℝ)` with `[Fintype α]`,
  never `Fin d`, and on a countable type where Layers 13.6 and 14.4 need countably many experts.
- The simplex is LMLExplore's `simplex α`.
- Statements whose proofs use no convexity (the FTRL equality, the Gibbs mixtures, the identities
  behind the reductions) are stated on arbitrary types.

**Sequences and adaptivity.** A deterministic algorithm is specified either by predicates on the
sequence of its plays (as LMLExplore's `IsFTRLPlay` and `IsMirrorDescentStep`) or by an online
learner (Layer 0.2).
- Regret bounds quantify over all sequences of losses. Each play is determined by the past, so the
  bounds hold against adaptive adversaries without further statement.
- Learning rates, regularizers, hints, activity weights and comparator classes may be chosen from
  the past, and are arbitrary sequences in the statements.
- The existence of the plays (minimizers) is proved separately, from compactness (`exists_ftrl`)
  or from strong convexity (Layer 1.1), and theorems take the plays as hypotheses.

**Randomness.**
- A randomized prediction is a distribution, and its loss is the expected loss, linear in the
  distribution, as in Bandits 6.5.
- Statements about random data (Layers 3 and 16) are made on a probability space with a filtration:
  plays are predictable, and each datum has a given conditional law (or conditional mean) given the
  past. Independent and identically distributed data are the special case.

**Values.**
- Losses, regularizers and hints are real-valued on the feasible set.
- Extended values appear only in conjugates (Tau Ceti's `fenchelConjugate`, valued in `EReal`, for
  the pairing $(x,y)\mapsto y(x)$ of `E` and `E →L[ℝ] ℝ`) and in divergences (`klDiv`, valued in
  `ℝ≥0∞`).
- Wealth, likelihoods and mixture weights are nonnegative reals, so a bettor or a portfolio may lose
  everything.
- Priors are probability measures on measurable spaces (`Measure Θ` with `IsProbabilityMeasure`),
  never densities. A finite set of experts with weights in `simplex α` is the case of a finitely
  supported prior.

**Learning rates.** Learning rates are sequences `η : ℕ → ℝ`, with $\eta_t$ used at Lean round
$t$, as in the Bandits roadmap.
- A rate may use the losses up to the current round, where the book's algorithm does
  ($\eta_t=c/\sqrt{\sum_{s\le t}\|y_s\|^2}$).
- Anytime statements are the primary ones. A rate tuned to a known horizon is a constant sequence,
  and its bound is a corollary.

**Constants and theorem shapes.**
- Constants are explicit, as in [Ora]. Where [Ora] errs, the item states the corrected form and says
  so.
- Lower bounds assert the existence of a loss sequence (or a distribution over loss sequences) for
  every algorithm.
- Asymptotic statements are eventual inequalities, as in the Bandits roadmap.

**Namespaces.** Online-learning definitions live in `LMLExplore.OnlineLearning`; general tools live
in `LMLExplore` or in the namespace of the type they act on.

## Existing library and design guidance

Consume these modules and extend their APIs rather than restating them.

| Foundation | Existing source |
| --- | --- |
| FTRL | LMLExplore `OnlineLearning/FTRL.lean` (`IsFTRLPlay`, `sum_apply_sub_le_ftrl`, `ftrl_regret_le_of_monotone`, `ftrl_regret_le_of_strongConvexOn_of_antitone`, `exists_ftrl`, `ftrl_regret_le_sqrt_of_closedBall`) |
| Mirror descent | LMLExplore `OnlineLearning/MirrorDescent.lean` (`IsMirrorDescentStep`, `IsMirrorDescentStep.mul_apply_sub_le`, `mirrorDescent_regret_le_of_strongConvexOn_of_antitone`) |
| Online subgradient descent | LMLExplore `OnlineLearning/SubgradientDescent.lean` (`sum_sub_le_sum_apply_sub_of_hasSubgradientWithinAt`, `onlineSubgradientDescent_regret_le`) |
| Exponential weights and the simplex | LMLExplore `OnlineLearning/ExponentialWeights.lean`, `OnlineLearning/Simplex.lean` (`softmax`, `isFTRLPlay_negEntropy_iff`, `softmax_regret_le_of_antitone`), `Analysis/Convex/Simplex.lean` (`simplex`), `Analysis/Convex/NegEntropy.lean` (`negEntropy`, `strongConvexOn_negEntropy`) |
| Mixture potentials on finite sets | LMLExplore `OnlineLearning/AdaHedge.lean` (`mixLoss`, `hedgePotential`, `adaHedge`) |
| Euclidean potentials | LMLExplore `Analysis/Convex/Bregman/Euclidean.lean` (`strongConvexOn_norm_sq_div_two`) |
| Design operators | LMLExplore `Analysis/InnerProductSpace/DesignOperator.lean` (`designOp`, `isUnit_designOp`) |
| Finite Gibbs inequality | LMLExplore `InformationTheory/KullbackLeibler/Finite.lean` (`sum_mul_sub_sum_mul_log_div_le_log_sum_mul_exp`) |
| Martingales | LMLExplore `Probability/Martingale/Ville.lean` (`MeasureTheory.Supermartingale.measure_exists_le_le`), `Probability/Martingale/Mixture.lean` (`supermartingale_integral`); `Probability/Moments/SubGaussian/Basic.lean` (`HasCondSubgaussianMGF.of_ae_trim_condExp_le`); `Probability/Kernel/Condexp.lean` (`ae_trim_map_condExpKernel_eq_of_indep`) |
| Minimax on the simplex | LMLExplore `Topology/Sion.lean` (`iSup_simplex_iInf_ofReal_dotProduct`, with `ℝ≥0∞` payoffs) |
| Gaussian integrals of quadratic forms | LMLExplore `Analysis/SpecialFunctions/Gaussian/QuadraticForm.lean` (`integral_exp_inner_sub_inner_apply`) |
| Kernel feature maps | Tau Ceti `Analysis/PositiveDefinite/Kernel/Kolmogorov.lean` (`kolmogorovFeature`); Mathlib `Analysis/InnerProductSpace/Reproducing.lean` |

**Online learners.**
- Reductions (Layers 6.5, 12–14, 15.2, 16) compose learners: they feed one learner surrogate
  losses computed from its own play, restart copies, and combine plays.
- State each reduction first as a theorem about sequences: inner plays and losses, outer plays and
  losses, related by per-round equations. The hypothesis is the inner regret inequality, the
  conclusion the outer one.
- Then define the composite algorithm as a learner (Layer 0.2) and lift the theorem in one step.

**Restatements of merged code.** Three items generalize merged declarations, and the pull request
that builds each of them derives the old statements as corollaries or migrates their uses. The
Generalization roadmap lists them among the restatements that other roadmaps own:
- Layer 0.3: `sum_apply_sub_le_ftrl`;
- Layer 5.2: `ftrl_regret_le_of_strongConvexOn_of_antitone` and `ftrl_regret_le_of_strongConvexOn`,
  without their derivative hypothesis;
- Layer 10.1: `mixLoss` and `hedgePotential`, as the finite case of Gibbs mixtures.

## Layers and dependencies

| Layer | Content | Prerequisites |
| --- | --- | --- |
| 0 | Regret notions, online learners, the FTRL equality | — |
| 1 | Convex analysis for online learning | Layer 0 |
| 2 | Online subgradient descent beyond $\sqrt n$: strongly convex losses, adaptive rates, AdaGrad | Layers 0–1; Bandits 6.3, 6.6 |
| 3 | Online-to-batch conversions | Layers 0–2; Bandits 0.1, 1.4 |
| 4 | Lower bounds and the coin-betting game | Layers 0–1 |
| 5 | FTRL for convex losses | Layers 0–1; Bandits 6.3 |
| 6 | Mirror descent: complements, $p$-norms, experts, combining learners | Layers 0–1, 5; Bandits 6.3–6.4 |
| 7 | Optimism, delays and gradual variations | Layers 1, 5–6 |
| 8 | Exp-concave and quadratic losses: the Online Newton Step and Vovk–Azoury–Warmuth | Layers 1, 5; Bandits 8.1–8.2 |
| 9 | Online linear classification | Layers 1–2, 5 |
| 10 | Gibbs mixtures, the Weighted Average and Aggregating Algorithms | Layers 0, 8.1 |
| 11 | Universal portfolio selection and Gamma-function inequalities | Layers 6, 8, 10 |
| 12 | Black-box reductions | Layers 0–1; Bandits 6.2 |
| 13 | Parameter-free learning through coin betting | Layers 4–5, 10–12 |
| 14 | Dynamic, strongly adaptive and tracking regret | Layers 6, 12–13 |
| 15 | Saddle points and games | Layers 0, 5, 7; Mathlib Sion |
| 16 | From online learning to statistics and optimization | Layers 1–3, 10–13; Bandits 1.1 |

## Layer 0: Regret notions, online learners and the FTRL equality

1. **Regret notions.** For losses `ℓ : ℕ → α → ℝ` on a type `α` and plays `x : ℕ → α`, define:
   - the regret $\sum_{t<n}(\ell_t(x_t)-\ell_t(u))$ against $u\in\alpha$;
   - the dynamic regret $\sum_{t<n}(\ell_t(x_t)-\ell_t(u_t))$ against comparators `u : ℕ → α`
     [Ora, Definition 14.1];
   - the regret on an interval $[s,s+\tau)$ of rounds;
   - the strongly adaptive regret $\max_{s}\,\sup_u$ of the regrets on intervals of length $\tau$
     within the horizon [Ora, Definition 14.7];
   - the tracking regret against comparator sequences with at most $m$ switches
     [Ora, Definition 14.13];
   - in a normed space, the path length $\sum_{t<n-1}\|u_{t+1}-u_t\|$.

   Prove the API that later layers use:
   - the regret is additive in the losses;
   - the dynamic regret against a constant sequence is the regret;
   - the regret over consecutive intervals is the sum of the interval regrets;
   - a sequence with at most $m$ switches in a set of diameter $D$ has path length at most $mD$.
2. **Online learners.** Define a causal online learner with plays in `X`, feedback in `G` and a
   context in `C` revealed before each play (the activity set of sleeping experts, a hint): a
   function returning the play of round $t$ from the contexts and feedback of rounds $s<t$ and the
   context of round $t$.
   - Define its run against sequences of contexts and feedback.
   - Define the *closed-loop run*, in which the feedback of round $t$ is a given function of the
     play of round $t$ and of the round's data, by recursion on the round. Surrogate losses are of
     this form.
   - Define the operations the reductions use, each with its run lemma:
     - restarting a learner at round $s$;
     - running a finite (Layer 2.4) or countable (Layer 13.6) family of learners coordinatewise;
     - summing the plays of finitely many learners;
     - translating plays;
     - skipping the rounds with zero feedback (Layer 13.2).
   - Define a regret guarantee as a predicate on a learner: for an admissibility condition on the
     feedback, a comparator set and a bound depending on the horizon and on the first $n$
     feedbacks, the regret of every run with admissible feedback is at most the bound.
   - Construct learners for FTRL and mirror descent (Bandits 6.3) and projected online subgradient
     descent (Bandits 6.6) by choosing a minimizer at each round where one exists (compact sets,
     `exists_ftrl`; strongly convex objectives, Layer 1.1), and prove that their runs satisfy
     `IsFTRLPlay` and `IsMirrorDescentStep`.
3. **The FTRL equality** [Ora, Lemma 7.1, Remarks 7.3–7.4, Lemma 1.2]. For regularizers and losses
   `ψ ℓ : ℕ → α → ℝ` on a type `α`, any points `x : ℕ → α`, and
   $F_t=\psi_t+\sum_{s<t}\ell_s$, prove for every $u\in\alpha$:
   $$\sum_{t<n}(\ell_t(x_t)-\ell_t(u))=\psi_n(u)-\psi_0(x_0)+\sum_{t<n}\big(F_t(x_t)-F_{t+1}(x_{t+1})+\ell_t(x_t)\big)+F_n(x_n)-F_n(u).$$
   - Deduce the inequality when $F_n(x_n)\le F_n(u)$.
   - Deduce the be-the-leader lemma: if each $x_{t+1}$ minimizes $\sum_{s\le t}\ell_s$, then
     $\sum_{t<n}\ell_t(x_{t+1})\le\sum_{t<n}\ell_t(u)$ for every $u$ [Ora, Lemma 1.2,
     Remark 15.32].
   - Record that adding a constant to $\psi_t$ changes no play (Remark 7.3), and that the terms
     $\ell_t(x_t)$ on both sides may be replaced by the losses of any other points (Remark 7.4).
   - LMLExplore's `sum_apply_sub_le_ftrl` is the case of linear losses on a normed space; derive
     it from this item.

Completion checks: with $\psi_t=0$ and $x_t$ the leader, item 3 gives the regret of
follow-the-leader as $\sum_t(\ell_t(x_t)-\ell_t(x_{t+1}))$ plus a nonpositive term; the regret of a
learner restarted at round $s$ over $[s,s+\tau)$ is the regret of the original learner over
$[0,\tau)$ on the shifted feedback.

## Layer 1: Convex analysis for online learning

Work in a real normed space `E` with dual `E →L[ℝ] ℝ`, and with subgradients within a set.

1. **Strong convexity through subgradients** [Ora, Lemma 4.2, Theorems 4.3, 4.6 and 6.9].
   - For a convex set $V$ and $m\ge0$:
     - if $f$ is $m$-strongly convex on $V$ and $g$ is a subgradient of $f$ within $V$ at
       $y\in V$, then $f(x)\ge f(y)+g(x-y)+\frac m2\|x-y\|^2$ for $x\in V$;
     - conversely, if every point of $V$ has a subgradient within $V$ with this property, then
       $f$ is $m$-strongly convex on $V$.
   - Strong monotonicity: if every point of $V$ has a subgradient within $V$, then $f$ is
     $m$-strongly convex on $V$ iff $(g_x-g_y)(x-y)\ge m\|x-y\|^2$ for all such subgradients.
   - The second-order criterion along segments, from LMLExplore's Taylor lemma
     (`Analysis/Convex/Bregman/Taylor.lean`).
   - Sums: $f+g$ is $(m_1+m_2)$-strongly convex, from Mathlib's `UniformConvexOn.add`.
   - Quadratic growth at a minimizer: $f(x)\ge f(x^\star)+\frac m2\|x-x^\star\|^2$ on $V$.
   - Existence and uniqueness: in a finite-dimensional `E`, an $m$-strongly convex function
     ($m>0$) that is lower semicontinuous on a nonempty closed convex set $V$ has exactly one
     minimizer on $V$. The FTRL and mirror-descent steps of strongly convex objectives therefore
     exist on unbounded closed convex sets, where `exists_ftrl` needs compactness.
2. **Subgradients and Lipschitz functions** [Ora, Theorems 2.21, 2.30, 4.21, Lemma 4.20].
   - Convexity from subgradients: if every point of a convex set $V$ has a subgradient within $V$,
     then $f$ is convex on $V$.
   - Lipschitz functions: on an open convex set $U$, if $f$ is $L$-Lipschitz on $U$ then every
     subgradient within $U$ at a point of $U$ has norm at most $L$; conversely, if every point of
     $U$ has a subgradient of norm at most $L$, then $f$ is $L$-Lipschitz on $U$.
   - In finite dimension, a convex function has a subgradient at every interior point of its
     domain (Tau Ceti `nonempty_subdifferential_of_mem_interior`, transferred to subgradients
     within a set).
   - Dual norms: $\sup_{\|x\|=r}y(x)=r\|y\|$ for $r\ge0$, attained in finite dimension.
3. **Smoothness and self-bounded functions** [Ora, Definitions 4.22 and 4.26, Lemma 4.24,
   Theorem 4.25, Remark 4.27]. A function is $s$-smooth on a convex set $V$ if it is
   differentiable on an open set containing $V$ and its derivative is $s$-Lipschitz on $V$ for the
   dual norm.
   - The descent lemma: for $s$-smooth $f$ and $x,y\in V$,
     $|f(y)-f(x)-f'(x)(y-x)|\le\frac s2\|y-x\|^2$. ReinforcementLearning 5.2 uses it on inner
     product spaces.
   - If $f$ is $s$-smooth on `E` and bounded below, then $\|f'(x)\|^2\le2s(f(x)-\inf f)$.
   - Define $s$-self-bounded functions within $V$: bounded below, with
     $\|g\|^2\le2s(f(x)-\inf f)$ for every subgradient $g$ within $V$ at a point $x\in V$.
   - A convex $s$-smooth function on `E` is $s$-self-bounded.
   - A self-bounded function on a convex set is convex.
4. **Conjugates of norms and the duality of strong convexity and smoothness** [Ora, Example 6.19,
   Lemma 6.22, Theorem 6.26]. On Tau Ceti's `fenchelConjugate` for the pairing of `E` and its
   dual:
   - the conjugate of $\frac s2\|\cdot\|^2$ is $\frac1{2s}\|\cdot\|^2$ on the dual;
   - the conjugates of $af(\cdot)+b$, of $f(\cdot-x_0)$ and of $f+y_0$;
   - for `E` finite-dimensional and $f$ proper, lower semicontinuous and $m$-strongly convex
     ($m>0$) on its domain: the conjugate is differentiable on the dual, its derivative at $y$ is
     the unique maximizer of $y(x)-f(x)$ (through the canonical isomorphism of `E` with its
     bidual), and it is $\frac1m$-smooth;
   - conversely, a proper lower semicontinuous convex function whose conjugate is
     $\frac1m$-smooth is $m$-strongly convex on the domain of its subdifferential.
5. **Distance to a convex set** [Ora, Definition 12.1, Lemma 12.2, Example 12.3]. For a convex
   set $V$, the function $x\mapsto$ `Metric.infDist x V`:
   - is convex and $1$-Lipschitz, so its subgradients have norm at most $1$;
   - vanishes exactly on the closure of $V$;
   - for $x$ outside a closed $V$ with a nearest point $p$ (which exists in finite dimension), has
     a subgradient $q$ at $x$ with $q(x-p)=\|x-p\|$.

   Prove that a continuous convex function on `E` has a subgradient at every point (Hahn–Banach).
6. **$p$-norm potentials** [Ora, Lemma 6.35, §6.7]. On `PiLp p (fun _ : α ↦ ℝ)` with `[Fintype α]`
   and $1<p\le2$:
   - $\frac12\|x\|_p^2$ is $(p-1)$-strongly convex for the $p$-norm;
   - the dual of `PiLp p` is `PiLp q` isometrically, with $\frac1p+\frac1q=1$;
   - the derivative of $\frac12\|x\|_p^2$ is the duality map, and the derivative of
     $\frac12\|\cdot\|_q^2$ inverts it.

   The book's proof goes through the smooth approximations $\frac12(\sum_a(x_a^2+c)^{p/2})^{2/p}$,
   $c\downarrow0$.
7. **Numerical lemmas** [Ora, Lemmas 4.13 and 4.29].
   - For $c\ge0$, $a_t\ge0$ and $f$ nonincreasing and nonnegative on $(c,\infty)$,
     $\sum_{t<n}a_tf(c+\sum_{s\le t}a_s)\le\int_c^{c+\sum_{t<n}a_t}f$ (terms with $a_t=0$
     omitted).
   - Corollaries: $\sum_{t<n}a_t/\sqrt{\sum_{s\le t}a_s}\le2\sqrt{\sum_{t<n}a_t}$ (terms with a
     zero denominator omitted), and
     $\sum_{t<n}a_t/(c+\sum_{s\le t}a_s)\le\log\big((c+\sum_ta_t)/c\big)$ for $c>0$.
   - For $a,b,c,x\ge0$ with $x-\sqrt{ax+b}\le c$: $x\le a+c+\sqrt{b+ac}$.
   - For $|x|\le\frac12$: $\log(1+x)\ge x-x^2$. For $-1<x\le1$: $\log(1+x)\le x-\frac{x^2}4$.

Generalization: subgradients within a set, normed spaces and lower semicontinuous functions, where
[Ora] states these facts for proper closed functions on $\mathbb R^d$.

## Layer 2: Online subgradient descent beyond $\sqrt n$

Projected online subgradient descent is Bandits 6.6, on a convex set $V$ of a real inner product
space. Mirror-descent statements are in a normed space.

1. **Constant rates on unbounded sets** [Ora, Theorem 2.13, Lemma 2.31]. For projected online
   subgradient descent with a constant rate $\eta$ from $x_0\in V$, prove for every $u\in V$:
   $$\sum_{t<n}(\ell_t(x_t)-\ell_t(u))\le\frac{\|u-x_0\|^2-\|u-x_n\|^2}{2\eta}+\frac\eta2\sum_{t<n}\|g_t\|^2.$$
   Prove it from LMLExplore's mirror-descent bound with the potential $\frac12\|\cdot\|^2$; no
   diameter is needed. Also prove its form with nonincreasing rates, which keeps
   $-\|u-x_n\|^2/(2\eta_{n-1})$.
2. **Strongly convex losses** [Ora, Theorem 4.7, Corollary 4.8, Example 4.11].
   - Assume strong convexity at the plays: $\ell_t(u)\ge\ell_t(x_t)+g_t(u-x_t)+\frac{\mu_t}2\|u-x_t\|^2$
     for $u\in V$, with $\mu_t\ge0$ and $\sum_{s\le t}\mu_s>0$ (Layer 1.1 gives it for losses that
     are $\mu_t$-strongly convex on $V$).
   - Prove that the rates $\eta_t=1/\sum_{s\le t}\mu_s$ give
     $\sum_{t<n}(\ell_t(x_t)-\ell_t(u))\le\frac12\sum_{t<n}\|g_t\|^2/\sum_{s\le t}\mu_s$.
   - Deduce $\frac{L^2}{2\mu}(1+\log n)$ when $\mu_t=\mu$ and $\|g_t\|\le L$.
   - The normed-space form is follow-the-leader (Layer 5.3).
3. **Adaptive rates and $L^\star$ bounds** [Ora, Theorems 4.14 and 4.30].
   - For mirror descent (Bandits 6.3) with an $m$-strongly convex potential $F$ and
     $\sup_tD_F(u,x_t)\le B$, the rates $\eta_t=\sqrt{mB/\sum_{s\le t}\|y_s\|^2}$ (no step while
     the sum is $0$) give $\sum_{t<n}y_t(x_t-u)\le2\sqrt{B\sum_{t<n}\|y_t\|^2/m}$.
   - Theorem 4.14 is the case $F=\frac12\|\cdot\|^2$, $B=D^2/2$ on a set of diameter $D$:
     $D\sqrt{2\sum_t\|g_t\|^2}$.
   - For nonnegative convex $s$-self-bounded losses (Layer 1.3) on a set of diameter $D$, these
     rates give $\sum_{t<n}(\ell_t(x_t)-\ell_t(u))\le4sD^2+2D\sqrt{s\sum_{t<n}\ell_t(u)}$
     (Layer 1.7).
4. **AdaGrad** [Ora, Algorithm 4.1, Theorem 4.32, Definition 4.33].
   - On a box $\prod_a[l_a,r_a]$ in `α → ℝ`, with $D_a=r_a-l_a$, coordinatewise adaptive online
     subgradient descent satisfies
     $\sum_{t<n}(\ell_t(x_t)-\ell_t(u))\le\sqrt2\sum_aD_a\sqrt{\sum_{t<n}g_{t,a}^2}$.
   - Prove it from the coordinatewise product of learners (Layer 0.2), whose linear regret is the
     sum of the coordinate regrets, and item 3 in dimension one.
   - Its plays are unchanged when each coordinate of every subgradient is multiplied by a positive
     constant of that coordinate (coordinatewise scale-freeness).

Completion checks: on the guessing game $\ell_t(x)=(x-y_t)^2$ on $[0,1]$ with $y_t\in[0,1]$, item 2
with $\mu_t=2$ gives regret at most $1+\log n$; item 3 needs neither the horizon nor a bound on the
subgradients.

## Layer 3: Online-to-batch conversions

Work on a probability space with a filtration $(\mathcal F_t)$. Plays $x_t$ are
$\mathcal F_t$-measurable, and data $\xi_t$ are $\mathcal F_{t+1}$-measurable with
$\mathbb E[f(x,\xi_t)\mid\mathcal F_t]=F(x)$ for every $x$. The loss $f$ is jointly measurable and
the needed integrability is assumed.

1. **In expectation** [Ora, Theorem 3.1, Examples 3.2, 3.5 and 4.12]. For $f(\cdot,\xi)$ convex on
   a convex set $V$ and deterministic weights $\alpha_t>0$, the losses
   $\ell_t=\alpha_tf(\cdot,\xi_t)$ satisfy, for every $\mathcal F_0$-measurable $u$ in $V$:
   $$\mathbb E\Big[F\Big(\frac{\sum_{t<n}\alpha_tx_t}{\sum_{t<n}\alpha_t}\Big)\Big]\le\mathbb E[F(u)]+\frac{\mathbb E[\text{regret}_n(u)]}{\sum_{t<n}\alpha_t}.$$
   - Deduce, with Layer 2.1, the rate $(\|u-x_0\|^2/\eta+\eta nG^2)/(2n)$ of stochastic subgradient
     descent with second moments of the subgradients bounded by $G^2$, on unbounded sets.
   - Deduce, with Layer 2.2 and the weights $\alpha_t=t+1$, the rate $2G^2/(\mu(n+1))$ for
     $\mu$-strongly convex $F$.
2. **Conditional Hoeffding.** A real process with $D_t\in[a_t,b_t]$ almost surely and
   $\mathbb E[D_t\mid\mathcal F_t]=0$ has conditionally $(b_t-a_t)^2/4$-sub-Gaussian increments
   (`HasCondSubgaussianMGF`). Derive it from Bandits 1.4 (both tails) and Bandits 0.1, after an
   affine change of scale. Deduce, with Mathlib's
   `measure_sum_ge_le_of_hasCondSubgaussianMGF`, the Azuma–Hoeffding bound
   $P(\sum_{t<n}D_t\ge\varepsilon)\le\exp(-2\varepsilon^2/\sum_t(b_t-a_t)^2)$ [Ora, Theorem 3.9].
3. **With high probability** [Ora, Theorem 3.10]. Let $f$ take values in $[0,1]$.
   - For predictable plays and every $\delta\in(0,1)$, with probability at least $1-\delta$:
     $\frac1n\sum_{t<n}F(x_t)\le\frac1n\sum_{t<n}f(x_t,\xi_t)+\sqrt{\log(1/\delta)/(2n)}$. No regret
     assumption is needed [Cesa-Bianchi, Conconi and Gentile 2004].
   - For a deterministic learner with $\text{regret}_n(u)\le R(u,n)$ on every loss sequence, and
     each fixed $u\in V$, with probability at least $1-\delta$:
     $\frac1n\sum_{t<n}F(x_t)\le F(u)+\frac{R(u,n)}n+\sqrt{2\log(2/\delta)/n}$.
   - With $V$ and $F$ convex, the same bound holds for the average play.
   - [Ora] proves the constant $2\sqrt{2\log(2/\delta)/n}$ through Azuma with increments bounded by
     $1$; Hoeffding's range gives the constant stated here.
4. **Selection on a validation sample and agnostic PAC learning** [Ora, Theorem 3.17,
   Definition 3.16].
   - For a finite set $S$ of candidates, measurable for a σ-algebra independent of $m$ validation
     data, the empirical-risk minimizer $\hat x$ over $S$ satisfies, with probability at least
     $1-\delta$: $F(\hat x)\le\min_{x\in S}F(x)+\sqrt{2\log(2|S|/\delta)/m}$.
   - Define agnostic PAC learnability of $\{f(x,\cdot):x\in V\}$, with learning algorithms as
     measurable maps from samples to $V$.
   - Prove that a deterministic learner with a regret bound $R(u,n)$, run on the first half of a
     sample of even size $n$ and selected among its plays on the second half, returns $\hat x$
     with, for every $u\in V$ and with probability at least $1-2\delta$:
     $F(\hat x)\le F(u)+2R(u,n/2)/n+2\sqrt{\log(2/\delta)/n}+2\sqrt{\log(n/\delta)/n}$ (items 3
     and 4). Hence sublinear regret, uniform in $u$, gives agnostic PAC learnability.

Generalization: a filtration and a conditional law of the data given the past, and randomized
learners, where [Ora] assumes independent data and deterministic algorithms; a fixed comparator,
with the minimum over comparators as a corollary.

## Layer 4: Lower bounds and the coin-betting game

1. **Bounded online linear optimization** [Ora, Theorem 5.1, Problem 5.2, Remark 5.3,
   Problem 5.1].
   - For every deterministic learner on a set $V$ of a normed space, all $v,w\in V$, $L>0$ and
     $n\ge1$, there are losses with $\|y_t\|\le L$ and $u\in\{v,w\}$ with
     $\sum_{t<n}y_t(x_t-u)\ge\frac L2\|v-w\|\,\mathbb E|\sum_{t<n}\varepsilon_t|$, for independent
     Rademacher signs $\varepsilon_t$.
   - The same bound holds for the expected regret of a learner with internal randomness
     independent of the signs.
   - Prove $\mathbb E|\sum_{t<n}\varepsilon_t|\ge\sqrt{n/3}$ from the second and fourth moments.
     [Ora] uses Szarek's sharp Khintchine constant, $\sqrt{n/2}$.
   - The unconstrained form: for every $u$, losses with $\|y_t\|\le L$ force regret at least
     $L\|u\|\,\mathbb E|\sum_t\varepsilon_t|$ against $u$ or $-u$.
2. **Time-varying subgradient descent on unbounded sets** [Ora, Theorem 5.4]. For
   $\alpha\in(0,1)$, $\varphi(\alpha)=\frac1{2-\alpha}+\frac{2^{\alpha-1}-1}{1-\alpha}$ and
   $n\ge2/((1-\alpha)\varphi(\alpha))$, unprojected online subgradient descent on $\mathbb R$ with
   $\eta_t=(t+1)^{-\alpha}$ and $x_0=0$ has regret at least $\frac12\varphi(\alpha)n^{2-\alpha}$
   against $0$ on some sequence of convex $1$-Lipschitz losses.
3. **The coin-betting game** [Ora, §5.3, Remark 5.6, Theorems 5.5 and 5.7].
   - Define the game: initial wealth $\varepsilon>0$, coins $c_t\in[-1,1]$, bets $x_t\in\mathbb R$,
     wealth $W_t=\varepsilon+\sum_{s<t}c_sx_s$; betting fractions $\beta_t\in[-1,1]$ with
     $x_t=\beta_tW_t$. A bettor is a learner with plays in $\mathbb R$ and feedback in $[-1,1]$
     (Layer 0.2).
   - The wealth of the best constant fraction has a closed form (Remark 5.6).
   - One-dimensional online linear optimization is betting: the losses $g_t=-Lc_t$ give
     $\sum_tg_t(x_t-0)=L(\varepsilon-W_n)$.
   - Prove Theorem 5.7 in a normed space. If a learner has $\sum_{s\le t}y_s(x_s)\le\varepsilon_t$
     for every $t$ and every losses with $\|y_s\|\le L$, then
     $L\|x_t\|\le\varepsilon_t-\sum_{s<t}y_s(x_s)$. Hence it bets a fraction of its wealth.
   - Prove Theorem 5.5. For $n$ even and $0<q\le n/2$, any bettor that keeps a nonnegative wealth on
     every sequence in $\{-1,1\}^n$ has wealth at most
     $\frac{3\varepsilon}2\big(\frac{2q}{\sqrt n}+1\big)\exp\big(n\,\mathrm{kl}(\tfrac12+\tfrac qn,\tfrac12)\big)$
     on some sequence with $|\sum_tc_t|\ge2q$. Its prerequisite is the binomial tail
     $P(X\ge\frac n2+q)\ge\frac13\big(\frac{2q}{\sqrt n}+1\big)^{-1}\exp\big(-n\,\mathrm{kl}(\tfrac12+\tfrac qn,\tfrac12)\big)$
     for $X\sim\mathrm{Bin}(n,\frac12)$ [Ora, Lemmas A.15 and A.17].
4. **The Lambert function and the unconstrained lower bound** [Ora, Appendix A.2.1, Theorem A.4,
   Theorem A.6, Theorem 5.8].
   - Define $W:[0,\infty)\to[0,\infty)$ as the inverse of $w\mapsto we^w$.
   - Prove its API: $W(x)e^{W(x)}=x$; $W$ is increasing and continuous;
     $e^{W(x)/2}=\sqrt{x/W(x)}$; $W(x)\le\log(1+x)$; $W(x)/\log x\to1$.
   - Prove Theorem 5.8. Let $n$ be even, and $L$, $\varepsilon_n>0$ and $U>0$ with
     $1\le W\big(\sqrt{en}\,UL/(8\varepsilon_n)\big)\le\sqrt n/2$. For every learner on $\mathbb R$
     whose regret against $0$ is at most $\varepsilon_n$ on all $L$-Lipschitz linear losses, there
     are losses with $|g_t|\le L$ and $|u|=U$ with
     $\sum_tg_t(x_t-u)\ge UL\sqrt n\big(\sqrt{2W(\sqrt n\,UL/(5\varepsilon_n))}-1\big)-2UL+\varepsilon_n$.
   - Deduce the $\sqrt{n\log n}$ asymptotics for $\varepsilon_n$ bounded away from $0$ and $\infty$.

## Layer 5: FTRL for convex losses

Plays $x_t$ minimize $F_t=\psi_t+\sum_{s<t}\ell_s$ over a convex set $V$ of a normed space. The
regularizers and losses are real-valued on $V$, and regularizers may depend on past losses.

1. **Stability without derivatives** [Ora, Lemmas 7.5 and 7.7, Remark 7.8].
   - Hypotheses: $g_t$ is a subgradient of $\ell_t$ within $V$ at $x_t$, and $F_t+\ell_t$ is
     $\lambda_t$-strongly convex on $V$.
   - Conclusion, for every $z\in V$ (with $\lambda_t>0$ for the second form):
     $$F_t(x_t)+\ell_t(x_t)-F_{t+1}(z)\le g_t(x_t-z)-\tfrac{\lambda_t}2\|x_t-z\|^2+\psi_t(z)-\psi_{t+1}(z)\le\frac{\|g_t\|^2}{2\lambda_t}+\psi_t(z)-\psi_{t+1}(z).$$
   - No derivative of $\psi_t$ is needed, and only $F_t+\ell_t$ must be strongly convex.
   - Prove the form with a nonnegative divergence $D_t(z)$ in place of
     $\frac{\lambda_t}2\|x_t-z\|^2$ (relative strong convexity), and its quadratic case in an inner
     product space: $D_t(z)=\frac12\langle S_t(z-x_t),z-x_t\rangle$ for a positive definite operator
     $S_t$, with the bound $\frac12\langle g_t,S_t^{-1}g_t\rangle$.
   - Proximal regularizers: if $x_t$ minimizes $\psi_{t+1}-\psi_t$ on $V$ and $F_{t+1}$ is
     $\lambda_{t+1}$-strongly convex on $V$, then
     $F_t(x_t)+\ell_t(x_t)-F_{t+1}(x_{t+1})\le\frac{\|g_t\|^2}{2\lambda_{t+1}}+\psi_t(x_t)-\psi_{t+1}(x_t)$.
2. **The FTRL bound for convex losses** [Ora, Corollary 7.6, Example 7.9].
   - Sum item 1 with Layer 0.3: for every $u\in V$,
     $\sum_{t<n}(\ell_t(x_t)-\ell_t(u))\le\psi_n(u)-\psi_0(x_0)+\sum_{t<n}\frac{\|g_t\|^2}{2\lambda_t}+\sum_{t<n}\big(\psi_t(x_{t+1})-\psi_{t+1}(x_{t+1})\big)$,
     with no monotonicity in $t$ and no differentiability.
   - For $\psi_t=F/\eta_t$ with $F$ $m$-strongly convex and $\eta_t>0$, the increments are
     $\big(\frac1{\eta_t}-\frac1{\eta_{t+1}}\big)F(x_{t+1})$. Keep them: Layer 13.5 needs them.
   - Derive `ftrl_regret_le_of_strongConvexOn_of_antitone` and `ftrl_regret_le_of_strongConvexOn`
     with the derivative hypothesis `hF'` removed, migrating their uses.
   - FTRL-Proximal, in an inner product space: $\psi_t(x)=\sum_{s<t}\frac{\sigma_s}2\|x-x_s\|^2$
     with $\sigma_s\ge0$ chosen after $g_s$ gives
     $\sum_t(\ell_t(x_t)-\ell_t(u))\le\sum_t\frac{\sigma_t}2\|u-x_t\|^2+\sum_t\frac{\|g_t\|^2}{2\sum_{s\le t}\sigma_s}$.
3. **Follow-the-leader on strongly convex losses** [Ora, Corollary 7.25, Algorithm 7.5,
   Example 7.26].
   - For losses $\mu_t$-strongly convex on $V$, with $\mu_t\ge0$ and positive partial sums, and
     $\psi=0$, prove $\sum_{t<n}(\ell_t(x_t)-\ell_t(u))\le\frac12\sum_{t<n}\|g_t\|^2/\sum_{s\le t}\mu_s$
     for any $x_0\in V$.
   - Quadratized losses: in an inner product space, follow-the-leader on
     $\tilde\ell_t(x)=g_t(x)+\frac{\mu_t}2\|x-x_t\|^2$ has the same bound and its plays are
     projections of a closed form.
4. **Composite losses** [Ora, §7.8, Example 7.24].
   - For losses $\ell_t+r$ with a known convex $r$, FTRL on $\sum_{s<t}g_s+tr+\psi_t$ satisfies the
     bound of item 2 for the losses $\ell_t+r$, with $r$ never linearized.
   - On Tau Ceti's `moreauYosidaResolvent`, prove that the proximal step is the minimizer of
     $\eta r(x)+\frac12\|x-z\|^2$, and that for the indicator of a closed convex set it is the
     projection.
   - Prove that for $r=\lambda\|\cdot\|_1$ on `α → ℝ` it is soft thresholding.

Generalization: subgradients within $V$, regularizers that need not be differentiable or monotone
in $t$, and a normed space, where [Ora] assumes closed proper functions on $\mathbb R^d$.
Completion check: follow-the-leader on the guessing game of Layer 2 has regret at most
$1+\log n$ by item 3, which improves the bound $4+4\log n$ of [Ora, Theorem 1.3].

## Layer 6: Mirror descent: complements, $p$-norms, experts and combining learners

1. **Complements to Bandits 6.3** [Ora, Theorem 6.11, Lemmas 6.32, 6.39 and 6.40].
   - With a constant rate from an arbitrary $x_0$:
     $\sum_{t<n}y_t(x_t-u)\le\frac{D_F(u,x_0)}\eta+\frac\eta{2m}\sum_{t<n}\|y_t\|^2$.
   - The second local-norm bound [Ora, Lemma 6.32, second form; Lemma 7.15, second form], for
     mirror descent with nonincreasing rates and for FTRL with $\psi_t=F/\eta_t$. For $F$
     differentiable on an open convex set $X\supseteq V$, let $\tilde x_{t+1}$ be the unconstrained
     step, minimizing $\eta_ty_t(x)+D_F(x,x_t)$ over $X$. Then each stability term is at most
     $\frac{\eta_t}2c_t$ for every $c_t\ge0$ with $y_t(v)^2\le c_t\,F''(z_t)(v,v)$ for all $v$, at
     some $z_t$ on the segment $[x_t,\tilde x_{t+1}]$. Item 4 and Bandits 7.5 (Tsallis-INF) need
     this form.
   - The step bound $\|x_t-x_{t+1}\|\le\frac{\eta_t}m\|y_t\|$, and the inequality form of the
     constrained stability lemma (Lemma 6.40), which Layer 7.1 uses.
2. **Exponentiated gradient** [Ora, §6.6, (6.12), Problem 6.10].
   - On `simplex α`, the mirror-descent step with the negative entropy is the multiplicative
     update $x_{t+1}\propto x_te^{-\eta y_t}$, and its iterates stay positive.
   - From the uniform start with a constant rate, the iterates are
     $\mathrm{softmax}(-\eta\sum_{s\le t}y_s)$, so the bounds of Bandits 6.4 apply.
   - The plays are unchanged when a constant is added to every coordinate of a loss.
   - For losses of any sign with $\eta|y_{t,a}|\le1$, the local-norm bound holds with the factor
     $e$.
3. **$p$-norm algorithms** [Ora, §6.7]. With the potential $\frac12\|\cdot\|_p^2$ of Layer 1.6:
   - $\sum_{t<n}y_t(x_t-u)\le\frac{\|u\|_p^2}{2\eta}+\frac\eta{2(p-1)}\sum_{t<n}\|y_t\|_q^2$ from
     $x_0=0$ on `PiLp p`;
   - its anytime form, on any closed convex set (Layers 12.1 and 16.1 use the unit ball);
   - with $q=2\log k$, $k=$ `Fintype.card α` $\ge3$, and $\|y_t\|_\infty\le L_\infty$,
     $\sum_{t<n}y_t(x_t-u)\le\frac12\sqrt{2en\log k}\,L_\infty(\|u\|_1^2/c+c)$ for every $c>0$.
     [Ora]'s constant for the tuned rate does not follow from the stated rate; this item states the
     corrected form.
4. **Multi-scale experts** [Ora, §6.9, Algorithm 6.4, Theorem 6.36].
   - Define mirror descent on `simplex α` with the weighted negative entropy
     $\sum_a\frac{c_a}\eta x_a\log x_a$ and the shifted losses
     $\tilde y_{t,a}=y_{t,a}+\eta y_{t,a}^2/c_a$.
   - For $|y_{t,a}|\le c_a$ and $\eta\le\frac15$, prove
     $\sum_{t<n}\langle y_t,x_t-u\rangle\le\frac{B_\psi(u,x_0)}\eta+\eta\sum_{t<n}\sum_au_ay_{t,a}^2/c_a$
     for $u$ in the simplex.
   - Bound $B_\psi(u,x_0)$ for the prior $x_0$, and give the tuned corollary.
5. **Combining online learners** [Ora, §6.10, Theorem 6.37].
   - A lemma about sequences: let the base plays $x^{(i)}_t$ lie in a convex set $V$, and let a
     meta-learner play $p_t$ in the simplex with the losses $z_{t,i}=y_t(x^{(i)}_t)$. Then the
     combination $x_t=\sum_ip_{t,i}x^{(i)}_t$ satisfies, for every $i$ and $u$,
     $\sum_ty_t(x_t-u)=\sum_t\langle z_t,p_t-e_i\rangle+\sum_ty_t(x^{(i)}_t-u)$.
   - Convex losses follow through linearization (Bandits 6.6).
   - Instance (Theorem 6.37): a grid of $N=\lceil\log_2\sqrt n\rceil+1$ online subgradient descents
     with rates $\eta^{(i)}=R2^{i-1}/(L\sqrt n)$, combined by item 4, has regret at most
     $\max(2\|u\|,R)\,L\big(\sqrt n(1+2\sqrt{3+\log n})+15+5\log n\big)$ for every $u$ with
     $\|u\|\le R\sqrt n$. The book prints $\log(2N-1)$ for $\log(2^N-1)$ in the meta rate.
   - Layers 14.2 and 14.4 reuse the lemma.

## Layer 7: Optimism, delays and gradual variations

1. **Optimistic mirror descent** [Ora, §6.11, Algorithm 6.6, Theorem 6.38].
   - Hints $h_t$ are arbitrary elements of the dual, with $h_0=0$, chosen before $y_t$. Optimistic
     mirror descent is mirror descent on the losses $y_t-h_t+h_{t+1}$.
   - For nonincreasing rates, prove for every $u\in V$:
     $$\sum_{t<n}y_t(x_t-u)\le\frac{\max_{t<n}D_F(u,x_t)}{\eta_{n-1}}+\sum_{t<n}\Big((y_t-h_t)(x_t-x_{t+1})-\frac{D_F(x_{t+1},x_t)}{\eta_t}\Big),$$
     with $D_F(u,x_0)/\eta$ for a constant rate.
   - For an $m$-strongly convex $F$, each summand is at most
     $\frac{\eta_t}{2m}\|y_t-h_t\|\min\big(\|y_t-h_t\|,2\|y_t-h_t+h_{t+1}\|\big)$.
   - Treat the last hint explicitly: the bound holds with $h_n=0$, or with the boundary term
     $h_n(x_n-u)$.
2. **Optimistic FTRL** [Ora, Algorithm 7.8, Theorems 7.47 and 7.48, Lemma 7.49, Example 7.50].
   - Hint losses $\tilde\ell_t$ are real functions on $V$ chosen before $\ell_t$, with
     $\tilde\ell_n=0$. The plays minimize $F_t+\tilde\ell_t$.
   - If $\hat g_t$ is a subgradient within $V$ of $\ell_t-\tilde\ell_t$ at $x_t$ and $F_t+\ell_t$
     is $\lambda_t$-strongly convex on $V$, then
     $$\sum_{t<n}(\ell_t(x_t)-\ell_t(u))\le\psi_{n-1}(u)-\psi_0(x_0)+\sum_{t<n}\Big(\hat g_t(x_t-x_{t+1})-\frac{\lambda_t}2\|x_t-x_{t+1}\|^2\Big)+\sum_{t<n-1}\big(\psi_t(x_{t+1})-\psi_{t+1}(x_{t+1})\big),$$
     hence the bound with $\|\hat g_t\|^2/(2\lambda_t)$.
   - Prove it from Layer 0.3 and Layer 5.1. The book's proof sets the last hint at the wrong round;
     the statement is correct with $\tilde\ell_n=0$.
   - Prove the stability of linear perturbations (Lemma 7.49) and the improved bound for linear
     losses (Theorem 7.48).
3. **Delayed feedback** [Ora, §6.12, §7.13].
   - With a constant delay $\tau$, the loss of round $t$ is revealed after round $t+\tau$.
   - Delayed mirror descent is optimistic mirror descent with the hints
     $h_{t+1}=-\sum_{t-\tau<s\le t}y_s$. Prove the regret bound with nonincreasing rates and the
     tuned $O(\sqrt{\tau n})$ corollary.
   - For FTRL, prove the bound for arbitrary sets of rounds whose feedback is missing.
4. **Variance and gradual variations** [Ora, §7.14, Corollary 7.52].
   - The variance bound, in a real inner product space with $\|g_t\|\le1$: the running means
     $\bar g_t$ of the past losses ($\bar g_0=0$) are follow-the-leader on $x\mapsto\|x-g_t\|^2$, so
     Layer 5.3 gives $\sum_t\|\bar g_t-g_t\|^2\le4(1+\log n)+\min_g\sum_t\|g_t-g\|^2$. Optimistic FTRL
     with these hints and a fixed $\lambda$-strongly convex $\psi$ then has regret at most
     $\psi(u)-\psi(x_0)+\frac{4+4\log n+\min_g\sum_t\|g_t-g\|^2}{2\lambda}$.
   - Corollary 7.52, first part: for $m$-smooth losses, the hints
     $\tilde\ell_t=\ell'_{t-1}(x_{t-1})$, and $\psi_t=\lambda_t\psi$ with $\psi$ $1$-strongly
     convex and nonnegative, $\lambda_t$ nondecreasing and $\lambda_t\lambda_{t-1}\ge8m^2$:
     $$\sum_t(\ell_t(x_t)-\ell_t(u))\le\lambda_{n-1}\psi(u)-\lambda_0\psi(x_0)+\frac{\|\ell_0'(x_0)\|^2}{\lambda_0}+\sum_{1\le t<n}\frac2{\lambda_t}\|\ell'_t(x_{t-1})-\ell'_{t-1}(x_{t-1})\|^2.$$
   - Its adaptive second part, on unbounded domains. [Ora] uses $\psi\ge0$ without stating it.

## Layer 8: Exp-concave and quadratic losses

Work in a finite-dimensional real inner product space `E`, with operators `E →L[ℝ] E`, the
Loewner order, and the design operators and weighted norms of Bandits 8.1.

1. **Exp-concavity** [Ora, Definition 7.31, Propositions 7.32–7.34 and 7.38, Theorem 7.35,
   Examples 7.36–7.37 and 7.39].
   - A function is $\alpha$-exp-concave on a convex set $V$ if $e^{-\alpha f}$ is concave on $V$.
   - It is then $\beta$-exp-concave for $\beta\le\alpha$, and the class is stable under nonnegative
     sums with $\alpha$ the minimum and under affine maps.
   - Hessian criterion: for $f$ twice differentiable on an open set containing $V$, $f$ is
     $\alpha$-exp-concave on $V$ iff
     $\alpha\langle f'(x),v\rangle^2\le f''(x)(v,v)$ for $x\in V$ and $v$ in the direction space
     of the affine span of $V$. [Ora] states it for all $v$, which fails when $V$ has empty
     interior.
   - The examples: $-\log\langle w,x\rangle$ is $1$-exp-concave on $\{x:\langle w,x\rangle>0\}$, and
     the bounded squared loss.
   - The quadratic lower bound: if $f$ is $\alpha$-exp-concave on $V$, $g$ is a subgradient within
     $V$ at $x$ and $|g(y-x)|\le B$ for $y\in V$, then
     $f(y)\ge f(x)+g(y-x)+\frac\beta2g(y-x)^2$ with $\beta=\frac12\min(\alpha,1/B)$.
2. **The log-determinant potential** [Ora, Lemma 7.29]. For $V_0$ positive definite, $\mu>0$ and
   $S_t$ the design operator of the vectors $\sqrt\mu\,g_s$, $s\le t$ (current vector included),
   prove $\sum_{t<n}\langle g_t,S_t^{-1}g_t\rangle\le\frac1\mu\log\frac{\det S_{n-1}}{\det V_0}$.
   Bandits 8.2's elliptical potential lemma, which excludes the current vector, is its sibling;
   the two share the determinant update.
3. **The Online Newton Step** [Ora, (7.10)–(7.12), Algorithm 7.6, Remark 7.30, Problem 7.12].
   - Define FTRL on the quadratic surrogates
     $\tilde\ell_t(x)=g_t(x)+\frac\mu2g_t(x-x_t)^2$ with
     $\psi(x)=\frac12\langle V_0x,x\rangle$, and its two-step form: an unconstrained step, then the
     projection in the norm of $S_t$.
   - For losses satisfying the lower bound of item 1, prove
     $\sum_{t<n}(\ell_t(x_t)-\ell_t(u))\le\frac12\langle V_0u,u\rangle-\min_V\frac12\langle V_0x,x\rangle+\frac1{2\mu}\log\frac{\det S_{n-1}}{\det V_0}$
     for every $u\in V$.
   - Deduce $\frac d{2\mu}\log\big(1+\frac{\mu nL^2}{\lambda d}\big)$ for $V_0=\lambda\,\mathrm{id}$
     and $\|g_t\|\le L$.
4. **Vovk–Azoury–Warmuth** [Ora, Algorithm 7.7, Theorem 7.44].
   - For features $z_t$ revealed before the play and labels $y_t$ revealed after it, the forecaster
     $x_t=S_t^{-1}\sum_{s<t}y_sz_s$, with $S_t=V_0+\sum_{s\le t}z_s\otimes z_s$, satisfies for
     every $u$:
     $$\sum_{t<n}\tfrac12(\langle z_t,x_t\rangle-y_t)^2-\sum_{t<n}\tfrac12(\langle z_t,u\rangle-y_t)^2\le\tfrac12\langle V_0u,u\rangle+\tfrac12\sum_{t<n}y_t^2\langle z_t,S_t^{-1}z_t\rangle.$$
   - Deduce $\frac\lambda2\|u\|^2+\frac{dY^2}2\log\big(1+\frac{R^2n}{\lambda d}\big)$ for
     $V_0=\lambda\,\mathrm{id}$, $\|z_t\|\le R$ and $|y_t|\le Y$.

## Layer 9: Online linear classification

Work in a real inner product space, with features $z_t$, labels $y_t\in\{-1,1\}$ and a margin loss
$\ell(\langle z,x\rangle,y)$. Feature maps into a reproducing kernel Hilbert space (Tau Ceti's
`kolmogorovFeature`) give the kernel versions as instances.

1. **The Perceptron** [Ora, Algorithm 8.2, Theorem 8.2, Remark 8.3].
   - For $\|z_t\|\le R$, the number of mistakes $M$ satisfies, for every $u$ and every $q\ge1$
     simultaneously,
     $M-L^{(q)}\le\frac{q^2R^2\|u\|^2}2+qR\|u\|\sqrt{\frac{q^2R^2\|u\|^2}4+L^{(q)}}$, where
     $L^{(q)}=\sum_t\max(0,1-y_t\langle z_t,u\rangle)^q$.
   - Prove it from Layer 2.1, scale-invariance of the plays, and Layer 1.7.
   - Novikoff's bound $M\le R^2\|u\|^2$ in the separable case is a corollary.
2. **Randomized classifiers and the Gaptron** [Ora, Algorithm 8.1, Theorem 8.1, Algorithm 8.3,
   Theorem 8.4, Examples 8.6–8.7].
   - A randomized classifier predicts a label distribution, and its expected number of mistakes is
     linear in it.
   - Theorem 8.1, the FTRL classifier with time-varying regularizers, is a corollary of Bandits 6.3.
   - The Gaptron: let $\ell\ge0$ be $s$-self-bounded in its first argument (Layer 1.3), with
     $\ell(m,1)+\ell(m,-1)\ge2$, $\ell(m,\mathrm{sign}\,m)\in[0,1]$ for $m\ne0$ and
     $\ell(0,\pm1)\in[0,1]$. For $\|z_t\|\le R$ and $\eta\le1/(2sR^2)$, its expected number of
     mistakes is at most $\sum_t\ell(\langle z_t,u\rangle,y_t)+\|u-x_0\|^2/(2\eta)$ for every $u$,
     against adaptive sequences.
   - Instances: the hinge loss and the smoothed hinge loss.

## Layer 10: Gibbs mixtures, the Weighted Average and the Aggregating Algorithms

Priors are probability measures $\pi$ on a measurable space $\Theta$, and cumulative losses are
measurable functions $L:\Theta\to\mathbb R$ bounded below.

1. **Gibbs mixtures** [Ora, §11.1, (11.5), Problem 11.1].
   - Define the Gibbs measure $\pi$`.tilted (fun θ ↦ -L θ / λ)` and the mix loss
     $m_\lambda(L)=-\lambda\log\int e^{-L/\lambda}\,d\pi$.
   - Prove the variational formula
     $m_\lambda(L)=\inf_{Q}\big(\mathbb E_Q[L]+\lambda\,\mathrm{KL}(Q,\pi)\big)$, attained at the Gibbs
     measure, from Tau Ceti's Donsker–Varadhan and tilted-KL lemmas.
   - Prove that $m_\lambda$ is nondecreasing in $\lambda$, and the telescoping identity:
     $m_\lambda(L+\ell)-m_\lambda(L)$ is the mix loss of $\ell$ under the Gibbs measure of $L$.
   - The finite case is the Gibbs variational formula on a finite type, which ReinforcementLearning
     5.1 uses. LMLExplore's `mixLoss` and `hedgePotential` are the case of a finite $\Theta$; derive
     them from this item.
2. **The Weighted Average Algorithm** [Ora, §11.2, Lemma 11.1, Theorem 11.3, Example 11.4].
   - On a closed convex set $V$ of a finite-dimensional space, with a prior on $V$ with a finite
     first moment, the algorithm plays the mean $x_t$ of the Gibbs measure of
     $\sum_{s<t}\ell_s$ at temperature $\lambda_t$.
   - For losses $\alpha$-exp-concave and continuous on $V$, and $\frac1\alpha\le\lambda_t$
     nondecreasing, prove
     $\sum_{t<n}\ell_t(x_t)\le m_{\lambda_{n-1}}\big(\sum_{t<n}\ell_t\big)\le\mathbb E_Q\big[\sum_{t<n}\ell_t\big]+\lambda_{n-1}\mathrm{KL}(Q,\pi)$
     for every probability $Q$.
   - The proof is Jensen's inequality for $e^{-\ell_t/\lambda_t}$ plus item 1. [Ora]'s
     infinite-dimensional FTRL argument (Lemma 11.1) is not needed.
3. **Mixability and the Aggregating Algorithm** [Ora, §11.3, Definition 11.7,
   Propositions 11.8–11.10, Theorem 11.11].
   - Setting (Vovk's expert form): a measurable prediction space $\Gamma$, an outcome space, a
     loss $\ell(\gamma,\omega)\in\mathbb R$, experts $\theta\in\Theta$ with predictions
     $\gamma^\theta_t$ measurable in $\theta$, and a prior $\pi$.
   - Definition: the loss is $\eta$-mixable if for every probability measure $P$ on $\Gamma$ there
     is a prediction $\gamma_0$ with
     $\ell(\gamma_0,\omega)\le-\frac1\eta\log\int e^{-\eta\ell(\gamma,\omega)}P(d\gamma)$ for every
     $\omega$. A substitution function chooses $\gamma_0$ from $P$.
   - The Aggregating Algorithm plays the substitution of the pushforward of the Gibbs posterior by
     the experts' predictions. For nonincreasing $\eta_t\le\eta$, prove
     $\sum_{t<n}\ell(\gamma_t,\omega_t)\le-\frac1{\eta_{n-1}}\log\int e^{-\eta_{n-1}\sum_{t<n}\ell(\gamma^\theta_t,\omega_t)}\,d\pi\le\mathbb E_Q\big[\sum_{t<n}\ell(\gamma^\theta_t,\omega_t)\big]+\frac{\mathrm{KL}(Q,\pi)}{\eta_{n-1}}$
     for every probability $Q$.
   - Prove: mixability for $\eta$ implies it for every $\eta'\le\eta$; exp-concave losses on a
     convex set are mixable with the mean as substitution; the absolute loss on $\{-1,1\}$ is not
     mixable with a common substitution function.
   - Instances: the Weighted Average Algorithm (item 2); exponential weights for finitely many
     experts; Cover's portfolio (Layer 11.2); the Krichevsky–Trofimov bettor (Layer 13.2).
4. **Uniform priors on convex bodies** [Ora, Theorems 11.5 and 11.12].
   - Let $V$ be a bounded closed convex set whose affine hull has dimension $d$, and $\pi$ uniform
     on $V$ in that hull.
   - For $\alpha$-exp-concave losses, item 2 gives regret at most
     $\frac d\alpha\big(1+\log(\frac nd+1)\big)$ against every $u\in V$.
   - For $L_t$-Lipschitz $\eta$-mixable losses on a set of diameter $D$, item 3 gives regret at most
     $\frac d\eta\log\max\big(1,\frac{\eta D\sum_tL_t}d\big)+\frac d\eta$.
   - The proofs shrink $V$ toward $u$.
5. **Online multiclass logistic regression** [Ora, §11.4, Proposition 11.9, Theorem 11.13].
   - Prove the generalized mixability of the multiclass logistic loss.
   - The improper algorithm predicts with the Bayesian posterior mixture over parameter matrices
     $X=[x_1,\dots,x_K]$ with columns in a closed convex $B\subset\mathbb R^d$ of diameter $D$.
   - For $\|z_t\|\le Z$, prove regret at most $2dK\log\big(\frac{2DZn}{dK}+e\big)$ against every
     $U$ with columns in $B$.
   - It needs the dual of the $(2,\infty)$ group norm, which is the $(2,1)$ norm, for matrices of
     columns (Lemma 7.20 in this case).

## Layer 11: Universal portfolio selection and Gamma-function inequalities

1. **Portfolio selection** [Ora, §10.1–10.2].
   - Market vectors are $w_t$ in $\{w\in$ `α → ℝ` $:w\ge0\}\setminus\{0\}$, and portfolios are $u$
     in `simplex α`.
   - The wealth is $\prod_{t<n}\langle u,w_t\rangle$, and the regret is
     $\sup_u\big(\log\text{wealth}_n(u)-\log\text{wealth}_n\big)$.
   - Exponentiated gradient for portfolios, under a bound on the ratios of the market vectors, is a
     corollary of Layer 6.2.
2. **Cover's universal portfolio** [Ora, Algorithm 10.1, (10.3), Lemmas 10.5–10.6].
   - For any prior $F$ on the simplex, the portfolio
     $x_t=\int u\,\text{wealth}_t(u)\,F(du)/\int\text{wealth}_t\,dF$ has wealth
     $\int\text{wealth}_n(u)\,F(du)$, from Layer 10.3.
   - Prove the mediant inequality and Lemma 10.6, which reduce the regret to the regret against the
     vertices on Kelly markets.
3. **Gamma-function inequalities** [Ora, Appendix A.2.2, Proposition A.10, Lemmas A.11–A.13].
   - Wendel's inequality $\big(\frac x{x+s}\big)^{1-s}\le\frac{\Gamma(x+s)}{x^s\Gamma(x)}\le1$ for
     $s\in(0,1)$ and $x>0$.
   - The real digamma function $\psi=(\log\Gamma)'$: it is increasing and concave, with
     $\log x-\frac1x\le\psi(x)\le\log x-\frac1{2x}$; the series of $\psi'$; Batir's bound
     (Proposition A.10).
   - $\Gamma(n+\frac d2)/\Gamma(n+\frac12)\le(n+\frac{d-1}2)^{(d-1)/2}$ for integers $n\ge1$, $d\ge2$
     (Lemma A.11), and Lemma A.12.
   - The vertex lemma A.13: $\prod_ia_i^{a_i}/\Gamma(a_i+\frac12)$ is maximized over
     $\{a\ge0,\sum_ia_i=n\}$ at a vertex, by convexity of $x\log x-\log\Gamma(x+\frac12)$.
   - Prove the cases $d=2$ of Lemma A.12 and of the vertex lemma from Mathlib's log-convexity and
     Bohr–Mollerup sequence; Layers 13.2 and 16.4 use them.
4. **The regret of the universal portfolio** [Ora, Theorem 10.1, Definition 10.2, Lemma 10.3,
   Theorem 10.4].
   - Method of types: for a sequence in $\alpha^n$ of type $N$, $\prod_tu_{j_t}\le\prod_a(N_a/n)^{N_a}$
     for every $u$ in the simplex, and the number of sequences of a type.
   - Dirichlet moments: from Tau Ceti's `integral_prod_pow_dirichletMeasure`, transported from
     `EuclideanSpace` to `simplex α`.
   - With the Dirichlet$(\frac12,\dots,\frac12)$ prior, $k=$ `Fintype.card α`:
     $\text{regret}_n\le\log\frac{\sqrt\pi\,\Gamma(n+\frac k2)}{\Gamma(\frac k2)\Gamma(n+\frac12)}\le\frac{k-1}2\log\big(\frac n{(k-1)/2}+1\big)+\frac k2-1+\frac12\log\frac\pi2$.
   - With the uniform prior: $\text{regret}_n\le\log\binom{n+k-1}{k-1}\le(k-1)\big(\log(\frac n{k-1}+1)+1\big)$.
5. **The Online Newton Step for portfolios** [Ora, §10.4, Algorithm 10.2]: a corollary of Layer 8.3
   with the exp-concavity of Layer 8.1.

## Layer 12: Black-box reductions

State each reduction for sequences, then for learners (Layer 0.2). Work in a normed space with
losses in the dual.

1. **Constraints through projections** [Ora, Algorithm 12.1, Theorem 12.5, Remark 12.6,
   Example 12.9].
   - An inner learner plays $z_t$ in a superset $W\supseteq V$. The outer play is a nearest point
     $x_t$ of $V$ to $z_t$, and the inner learner receives a surrogate loss.
   - The four surrogates of Theorem 12.5 are built from $\|y_t\|\,d(\cdot,V)$ and a subgradient
     $q_t$ of $d(\cdot,V)$ at $z_t$ (Layer 1.5), with the indicator variants.
   - For each, prove $y_t(x_t-u)\le\tilde\ell_t(z_t)-\tilde\ell_t(u)$ for $u\in V$, and the bound
     $\|\tilde y_t\|\le2\|y_t\|$ on the surrogate's subgradients. For the third and fourth
     surrogates in an inner product space, $\|\tilde y_t\|\le\|y_t\|$ (Remark 12.6).
   - Example 12.9: clipping a one-dimensional learner to $[0,\infty)$, with the surrogate
     $\min(g_t,0)$ when $z_t<0$.
2. **Constraints through Bregman projections** [Ora, Theorem 12.11]: the same reduction with the
   Bregman projection of Bandits 6.2.
3. **Sleeping experts** [Ora, Algorithm 12.2, Theorem 12.13, (12.1), Remark 12.14].
   - Experts form a type $\iota$, possibly countable. Activity weights $a_{t,i}\in[0,1]$ are revealed
     before the play, with finitely many nonzero and at least one positive per round. The sleeping
     regret against $u\ge0$ is $\sum_t\sum_iu_ia_{t,i}(\langle y_t,x_t\rangle-y_{t,i})$.
   - An inner learner plays $z_t\ge0$. The outer play is $x_{t,i}\propto a_{t,i}z_{t,i}$ (any
     distribution on the active experts if the sum is $0$), and the inner learner receives
     $\tilde y_{t,i}=a_{t,i}(y_{t,i}-\langle y_t,x_t\rangle)$.
   - Prove $\langle\tilde y_t,z_t\rangle=0$, so the sleeping regret against $u$ is the inner
     linear regret against $u$, and the range bound on $\tilde y_t$.
   - The normalization to the simplex (12.1) is the case $a=1$.
4. **Magnitude and direction** [Ora, Algorithm 12.3, Theorems 12.16 and 14.5].
   - A one-dimensional learner plays $z_t$, a learner on the unit ball plays $\tilde x_t$, and the
     outer play is $x_t=z_t\tilde x_t$. They receive $s_t=y_t(\tilde x_t)$ and $y_t$, and
     $|s_t|\le\|y_t\|$.
   - Prove, for every $U>0$ and comparators $u_t$ with $\|u_t\|\le U$, the per-round identity
     $y_t(z_t\tilde x_t-u_t)=(z_t-U)s_t+U\,y_t(\tilde x_t-u_t/U)$.
   - Hence the dynamic regret is at most the one-dimensional regret against $U$ plus $U$ times the
     dynamic regret of the ball learner.
   - The static case $u_t=u$, $U=\|u\|$ is Theorem 12.16, and $u=0$ is the one-dimensional regret
     against $0$.

## Layer 13: Parameter-free learning through coin betting

1. **Regret–reward duality** [Ora, Theorem 13.5, Lemma 13.6].
   - On Tau Ceti's `fenchelConjugate`: for every $\phi$ on the dual, if
     $-\sum_{t<n}y_t(x_t)\ge\phi(-\sum_{t<n}y_t)$, then $\sum_{t<n}y_t(x_t-u)\le\phi^\star(u)$ for
     every $u$.
   - Conversely, for $\phi$ proper, lower semicontinuous and convex, the bounds for all $u$ imply
     the wealth bound (Tau Ceti's Fenchel–Moreau).
   - The conjugate bound: for $\alpha,\beta>0$, the conjugate of
     $\theta\mapsto\beta e^{\theta^2/(2\alpha)}$ is at most
     $|u|\sqrt{\alpha\log(1+\alpha u^2/\beta^2)}-\beta$. Prove it without the Lambert function,
     from the concavity of $x|u|-\beta e^{x^2/(2\alpha)}$ and $(1+s)\log(1+s)\ge s$.
2. **The Krichevsky–Trofimov bettor** [Ora, Algorithms 13.1–13.2, Theorems 13.2 and 13.4,
   Problems 13.1 and 13.4, §13.2.1].
   - The bettor plays the fraction $\beta_t=\sum_{s<t}c_s/(t+1)$ of its wealth.
   - With $F_t(x)=\varepsilon\frac{2^t\Gamma(\frac{t+1+x}2)\Gamma(\frac{t+1-x}2)}{\pi\Gamma(t+1)}$,
     prove the potential inequality $F_t(x+c)\le(1+\frac{cx}t)F_{t-1}(x)$ for $c\in[-1,1]$ and
     $|x|\le t-1$, by log-convexity of $\Gamma$.
   - Deduce the wealth bound
     $W_n\ge F_n(\sum_tc_t)\ge\varepsilon\exp\big(\frac{(\sum_tc_t)^2}{2n}-\frac12\log n-1\big)$ for
     coins in $[-1,1]$ and $n\ge1$ (Layer 11.3, $d=2$).
   - Deduce, by item 1, the one-dimensional bound
     $\sum_{t<n}g_t(x_t-u)\le|u|L\sqrt{2n\log(\frac{e|u|n}\varepsilon+1)}+\varepsilon L$ for
     $|g_t|\le L$ and every $u\in\mathbb R$.
   - The skip-zero wrapper of Layer 0.2 gives the same bound with $n$ replaced by the number of
     rounds with $g_t\ne0$.
   - The binary-coin bound (Theorem 13.2) is a corollary; its proof through Layer 10.3 with the
     arcsine prior is a completion check.
3. **Combining parameter-free learners** [Ora, Theorem 13.9, Proposition 13.10, Theorem 13.11,
   §13.4].
   - Product: coordinatewise Krichevsky–Trofimov on `α → ℝ` with $\|y_t\|_\infty\le L_\infty$ has
     regret at most $L_\infty\sum_a|u_a|\sqrt{2n\log(1+e|u_a|n/\varepsilon)}+k\varepsilon L_\infty$.
   - Translation: a learner translated by $x^\circ$ has the bound at $u-x^\circ$.
   - Sum: the sum of the plays of finitely many learners has regret at most
     $\inf_{u=\sum_ju_j}\sum_jB_j(u_j)$.
     [Ora, Theorem 13.11] states an equality with a minimum; the correct statement is this inequality.
   - Any norm: Layer 12.4 with item 2 and a learner on the unit ball (Bandits 6.3–6.4).
4. **Experts through betting** [Ora, §13.6, Theorem 13.14, Algorithm 13.4, Remark 13.13].
   - Setting: experts form a measurable space with a prior $\pi$, losses $g_t$ are measurable with
     values in $[-L,L]$, and each expert has a bettor fed the coins of [Ora, (13.4)], built from
     $(\langle g_t,p_t\rangle-g_t(\theta))/(2L)$ and the sign of the expert's bet.
   - Hypothesis: each bettor guarantees $W_t\ge a\exp(f_t(\sum_{s\le t}c_s))$ for every initial
     wealth $a>0$.
   - The prediction $p_t$ weights $\pi$ by the positive parts of the bets. For every probability
     $Q\ll\pi$ and every concave nondecreasing $h$ with $x\le h(f_n(x))$, prove
     $\sum_{t<n}\big(\langle g_t,p_t\rangle-\mathbb E_Q[g_t]\big)\le2L\,h(\mathrm{KL}(Q,\pi))$.
   - [Ora] requires $h$ concave on $\mathbb R$, which its own Krichevsky–Trofimov instance violates;
     $h$ need only be concave on $[0,\infty)$ with $\mathrm{KL}\ge0$.
   - Corollaries: finitely many experts; the Krichevsky–Trofimov instance; the quantile bound.
5. **The constant-fraction bettor** [Ora, §13.7, (13.8)–(13.10)].
   - FTRL on $[-\frac12,\frac12]$ with $\psi_t(\beta)=(t+a)\beta^2$ plays
     $\beta_t=\sum_{s<t}c_s/(2(t+a))$.
   - By Layer 5.2 (keeping the increments) and Layer 1.7, its wealth is at least
     $\exp\big(\frac{(\sum_tc_t)^2}{4(n+a)}-\frac n{4a}\big)$ times the initial wealth.
   - With item 4 and $a=n/4$: $\sum_{t<n}(\langle g_t,p_t\rangle-\mathbb E_Q[g_t])\le L\sqrt{20n(\mathrm{KL}(Q,\pi)+1)}$
     for measurable experts.
   - In one dimension: $|u|L\sqrt{5n\log(|u|\sqrt{19n}/\varepsilon+1)}+L\varepsilon$.
6. **Parameter-free sleeping experts** [Ora, §13.8, Algorithm 13.5, Remark 13.16].
   - Experts form a countable type, with initial wealths $\varepsilon_i$ summing to at most $1$
     and finitely many active experts per round with range at most $R$.
   - The algorithm composes the skip-zero Krichevsky–Trofimov bettor, the clipping of
     Layer 12.1, the countable product of Layer 0.2 and the sleeping reduction of Layer 12.3.
   - For finitely supported $u\ge0$, prove
     $\text{sleeping regret}(u)\le R\sum_iu_i\sqrt{2\sum_ta_{t,i}\log(1+eu_i\sum_ta_{t,i}/\varepsilon_i)}+R\sum_i\varepsilon_i$.
   - [Ora]'s intermediate display writes $L_\infty$ for the range $R$.

## Layer 14: Dynamic, strongly adaptive and tracking regret

1. **Dynamic regret of mirror descent** [Ora, Theorem 14.2, Example 14.3, Example 14.14].
   - For a constant rate and an $m$-strongly convex potential $F$, with
     $Q=\max_{t\le n}\|F'(x_t)-F'(x_0)\|$, prove for comparators in $V$:
     $$\sum_{t<n}y_t(x_t-u_t)\le\frac{D_F(u_{n-1},x_0)+Q\,P(u)}\eta+\frac\eta{2m}\sum_{t<n}\|y_t\|^2-\frac{D_F(u_{n-1},x_n)}\eta,$$
     where $P(u)$ is the path length.
   - Corollaries: projected online subgradient descent, and tracking the best expert with mirror
     descent on the truncated simplex.
2. **ADER** [Ora, Algorithm 14.1, Theorem 14.4].
   - For a set of diameter $D$ and $\|g_t\|\le L$, combine (Layer 6.5) a grid of online
     subgradient descents with rates $\eta^{(i)}=D2^{i-1}/(L\sqrt n)$, $i\le1+\lceil\log_2\sqrt{4+8n}\rceil$,
     by exponentiated gradient (or AdaHedge).
   - For losses with $\|g_t\|\le L$ at the plays, prove for all comparators in $V$:
     $\sum_t(\ell_t(x_t)-\ell_t(u_t))\le\frac32L\sqrt{n(D^2+2DP(u))}+\sqrt2LD\sqrt{n\log(2+\log_2\sqrt{4+8n})}$.
   - The magnitude–direction corollary with a parameter-free magnitude (Example 14.6) follows from
     Layer 12.4 and Layer 13.5.
3. **Geometric covering intervals** [Ora, §14.2.2, Lemma 14.10]. Define the dyadic intervals
   $[i2^k,(i+1)2^k)$, $i\ge1$. Prove that every interval of rounds is a disjoint union of covering
   intervals with at most two of each length, with lengths increasing then decreasing.
4. **Strongly adaptive regret: CBCE** [Ora, Algorithms 14.2–14.3, Theorems 14.9 and 14.11].
   - Run copies of a black-box learner $\mathcal B$, restarted at the start of each covering interval
     (or at each round), combined by the parameter-free sleeping experts of Layer 13.6 with priors
     summing to $1$.
   - Prove one theorem giving both bounds. For each interval $I=[s,s+\tau)$ and $u\in V$:
     $\text{regret}_I(u)\le\text{regret}^{\mathcal B}_\tau(u)+DL\big(\sqrt{2\tau\log(e\tau s(s+1)+1)}+1\big)$
     with copies at every round.
   - With covering intervals and $\text{regret}^{\mathcal B}_t\le cDLt^\alpha$, prove
     $\text{regret}_I(u)\le2\frac{2^\alpha-(4\tau^2)^{-\alpha}}{2^\alpha-1}cDL\tau^\alpha+DL+10DL\sqrt{\tau\log(e(s+\tau)^4+1)}$.
5. **From strongly adaptive to tracking regret** [Ora, Theorem 14.15]. If every interval regret
   satisfies $\text{regret}_I(u)\le c|I|^\alpha+d$ with $\alpha\in(0,1)$, then the regret against
   a comparator sequence that is constant on each of $K$ consecutive intervals is at most
   $cK^{1-\alpha}n^\alpha+dK$. [Ora] omits $d$, without which item 4 does not apply.

## Layer 15: Saddle points and games

Use Mathlib's `IsSaddlePointOn`, weak duality and Sion's theorem; [Ora, Theorem 15.11] is a weaker
form of `Sion.exists_isSaddlePointOn` and is not a target.

1. **Duality gap and approximate saddle points** [Ora, Definitions 15.8–15.9, Lemma 15.10,
   Theorem 15.3].
   - Define the duality gap $\sup_yf(x',y)-\inf_xf(x,y')$ in `EReal`, with
     $\text{gap}\le B\iff\forall x\,y,\ f(x',y)-f(x,y')\le B$.
   - Define $\varepsilon$-saddle points. An $\varepsilon$-saddle point has gap at most
     $2\varepsilon$, and a point with gap at most $\varepsilon$ is an $\varepsilon$-saddle point.
   - Zero gap characterizes saddle points.
2. **No-regret dynamics** [Ora, Theorem 15.12, Corollaries 15.13 and 15.15, Theorem 15.17,
   Remark 15.18].
   - For arbitrary sequences $x_t\in X$, $y_t\in Y$ and $f$ convex in $x$ and concave in $y$, the
     averages satisfy
     $f(\bar x_n,y)-f(x,\bar y_n)\le\frac1n\big(\text{regret}^X_n(x)+\text{regret}^Y_n(y)\big)$ for
     all $x,y$, where the players' losses are $f(\cdot,y_t)$ and $-f(x_t,\cdot)$.
   - Hence the gap is at most the sum of the worst-case regrets divided by $n$. No attainment is
     assumed.
   - Corollaries: two no-regret learners; a learner against best responses, approximate ones with
     slack $\sum_t\varepsilon_t$ included; alternation, from the pairs $(x_{t+1},y_t)$.
3. **Matrix games** [Ora, §15.3, Examples 15.20–15.22].
   - Prove von Neumann's theorem for bilinear payoffs on `simplex α` × `simplex β` from
     `Sion.exists_isSaddlePointOn`, and relate it to LMLExplore's `ℝ≥0∞` form.
   - An $\varepsilon$-Nash equilibrium is an $\varepsilon$-saddle point. For payoffs in $[-1,1]$,
     exponential weights for both players with tuned rates give a gap at most
     $(\sqrt{2\log k_\alpha}+\sqrt{2\log k_\beta})/\sqrt n$, where $k_\alpha$, $k_\beta$ are the
     numbers of pure strategies.
4. **Boosting as a game** [Ora, §15.4].
   - Weak learnability with edge $\gamma$ implies, by von Neumann's theorem, that some weighted
     majority vote has margin $\gamma$ on every example.
   - The boosting algorithm of [Ora, Algorithm 15.5], with any learner for the distribution
     player, has training error $0$ after a number of rounds controlled by its regret.
   - Instances: exponentiated gradient, and the parameter-free experts of Layer 13.5.
5. **Faster rates through optimism** [Ora, Theorems 15.26 and 15.28, (15.11), Example 15.29].
   - Let $f$ be convex–concave and differentiable, with $\nabla_xf$ $L_{XX}$-Lipschitz in $x$ and
     $L_{XY}$-Lipschitz in $y$, and $\nabla_yf$ $L_{XY}$-Lipschitz in $x$ and $L_{YY}$-Lipschitz in
     $y$, for the dual norms [Ora, (15.7)–(15.10)]. Let $\psi_X,\psi_Y$ be $\lambda_X$- and
     $\lambda_Y$-strongly convex with $\lambda_X\ge2\sqrt2(L_{XX}+cL_{XY})$ and
     $\lambda_Y\ge2\sqrt2(L_{YY}+L_{XY}/c)$ for some $c>0$. Optimistic FTRL (Layer 7.2) for both
     players, with the last gradients as hints, gives
     $\text{gap}(\bar x_n,\bar y_n)\le\frac1n\big(\psi_X(x')-\psi_X(x_0)+\psi_Y(y')-\psi_Y(y_0)+\frac{\|g_{X,0}\|^2}{\lambda_X}+\frac{\|g_{Y,0}\|^2}{\lambda_Y}\big)$.
   - The optimistic mirror-descent version (Layer 7.1) has $\lambda_XD_{\psi_X}(x',x_0)+\lambda_YD_{\psi_Y}(y',y_0)$
     in place of the regularizer differences. [Ora] drops the factors $\lambda_X,\lambda_Y$.
   - Prove Luo's bound (15.11) on the sum of the squared movements.
   - Bilinear games have $L_{XX}=L_{YY}=0$ and $L_{XY}=\|A\|$ for the chosen norms.
6. **Algorithms that see the current loss** [Ora, Theorems 15.30 and 15.31, Remark 15.32].
   - Implicit mirror descent plays $x_{t+1}$ minimizing $\eta_t\ell_t(x)+D_F(x,x_t)$. For convex
     losses, with no subgradient assumption and nonincreasing rates, prove
     $\sum_{t<n}(\ell_t(x_{t+1})-\ell_t(u))\le\frac{\max_tD_F(u,x_t)}{\eta_{n-1}}-\sum_t\frac{D_F(x_{t+1},x_t)}{\eta_t}$.
   - Be-the-regularized-leader, for arbitrary losses with $\psi_t+\sum_{s\le t}\ell_s$ strongly
     convex, from Layer 0.3.
   - Combined with optimistic FTRL for the other player, the regret bound of [Ora, §15.5.1].

## Layer 16: From online learning to statistics and optimization

1. **Rademacher complexity from regret** [Ora, Definition 16.1, Theorem 16.4, Corollaries 16.6 and
   16.7].
   - Define the empirical Rademacher complexity of a set $V$ of linear predictors on a sample
     $z_0,\dots,z_{n-1}$ in the dual: $\frac1n\mathbb E_\varepsilon\sup_{x\in V}\sum_t\varepsilon_tz_t(x)$.
   - If a deterministic learner on $V$ has $\sup_{u\in V}\sum_ty_t(x_t-u)\le R(n)$ on all losses in
     a symmetric set containing the $z_t$, then the complexity is at most $R(n)/n$.
   - Corollaries: through Bandits 6.3, for an $m$-strongly convex regularizer bounded by $B$ on $V$,
     $\sqrt{2B/(mn)}\max_t\|z_t\|$. Instances: the Euclidean ball, the simplex (Massart's lemma
     $\sqrt{2\log k/n}$), and the $p$-norm balls (Layer 1.6).
2. **Online-to-PAC-Bayes** [Ora, Theorem 16.8, Theorem 16.9, Corollary 16.10].
   - Setting: a measurable parameter space $\Theta$, a jointly measurable loss
     $\ell:\Theta\times\mathcal Z\to[0,1]$, and data with conditional law $\rho$ given the past.
   - For any learner whose outputs $P_t$ are predictable probability kernels, fed the losses
     $P\mapsto\mathbb E_{\theta\sim P}[\ell(\theta,\xi_t)-\mathbb E_\rho\ell(\theta,\cdot)]$:
     with probability at least $1-\delta$, simultaneously for every $Q\ll\pi$ (data-dependent
     included), the generalization gap of $Q$ is at most
     $\text{regret}_n(Q)/n+\sqrt{2\log(1/\delta)/n}$.
   - With the measurable-expert bound of Layer 13.5 this gives
     $\sqrt{20(\mathrm{KL}(Q,\pi)+1)/n}+\sqrt{2\log(1/\delta)/n}$.
3. **Online-to-non-convex conversion** [Ora, Definitions 16.13 and 16.15, Algorithm 16.1,
   Theorem 16.17, Lemma 16.18].
   - $F$ is differentiable on a real inner product space, with $t\mapsto F'(x+t(y-x))(y-x)$ interval
     integrable, so that $F(y)-F(x)=\int_0^1F'(x+t(y-x))(y-x)\,dt$.
   - Stochastic gradients $g_t$ have conditional mean $\nabla F(x'_t)$ and conditional second
     moment at most $G^2$.
   - Define the $\delta$-stationarity measure through convex combinations of gradients in a
     $\delta$-ball, and Algorithm 16.1 with its cycles of length $K$.
   - For any learner with a per-cycle regret bound, prove the bound of Theorem 16.17. Its instance
     with online subgradient descent restarted each cycle, with $\eta=D/(G\sqrt K)$, is
     $\frac{F(x_0)-\inf F}{Dn}+\frac{2G}{\sqrt K}$.
   - Deduce the rate $O\big(G^{2/3}((F(x_0)-\inf F)/(n\delta))^{1/3}\big)$.
4. **Betting confidence sequences** [Ora, §16.4, Theorems 16.20, 16.23 and 16.24,
   Proposition 16.22, Lemma 16.26].
   - The betting martingale: for $Z_t\in[0,1]$ with $\mathbb E[Z_t\mid\mathcal F_t]=\mu$ and
     predictable bets $\beta_t\in[-\frac1{1-\mu},\frac1\mu]$, the wealth $\prod_{s<t}(1+\beta_s(Z_s-\mu))$
     is a nonnegative martingale. No moment generating function is involved.
   - The reduction: if a betting algorithm has a deterministic regret bound $R_t$ against the best
     constant bet, Ville's inequality (Bandits 1.1) makes
     $\{m:\max_\beta\sum_{s<t}\log(1+\beta(Z_s-m))-R_t\le\log(1/\delta)\}$ a confidence sequence for
     $\mu$ at level $1-\delta$, uniformly in $t$.
   - Theorem 16.20: with the Dirichlet$(\frac12,\frac12)$ portfolio (Layer 11.4, $k=2$),
     $R_t=\log\frac{\sqrt\pi\,\Gamma(t+1)}{\Gamma(t+\frac12)}$. Each set is an interval.
   - The Krichevsky–Trofimov bettor of Layer 13.2 gives a second instance.
   - The analysis of the width: Proposition 16.22, Theorem 16.23, Lemma 16.26, and the empirical
     Bernstein-type width of Theorem 16.24.
   - The first interval has length $1-\delta/2$ (Theorem 16.23).
   - With a constant bet on $\{0,1\}$ data, the wealth is the Bernoulli exponential supermartingale
     of Identification 4.2. The new content here is predictable bets and the regret reduction.

## Completion checks

- Every new algorithm comes with a learner (Layer 0.2) whose runs satisfy its defining predicate,
  and every regret theorem holds for all loss sequences, hence against adaptive adversaries.
- The constant-rate and known-horizon bounds of every layer are the constant cases of the anytime
  ones.
- Exponentiated gradient, Hedge, Cover's portfolio, the Weighted Average Algorithm and the
  Krichevsky–Trofimov bettor are instances of the Gibbs mixtures of Layer 10.
- LMLExplore's `sum_apply_sub_le_ftrl`, its derivative-hypothesis FTRL bounds, `mixLoss` and
  `hedgePotential` are derived from the general statements of Layers 0.3, 5.2 and 10.1.
- The lower bounds of Layer 4 match:
  - the upper bounds of Bandits 6.4–6.6 and Layer 2 up to constants;
  - the bounds of Layers 13.2 and 13.5 up to the logarithmic factor of Layer 4.4.
- The bounds of Layers 6.4, 8.3, 8.4, 10.4, 11.4 and 13.2 are $0$ or trivial in dimension $0$ or
  with a single expert.

Compilation of the suggested signatures checks their types, not the truth of their admitted
theorems or the completion of these milestones.

## References

F. Orabona, *Online Learning: A Modern Introduction Using Convex Optimization*, arXiv:1912.13213v10
(2026), to appear at Cambridge University Press, is the main source; the layers cite its numbered
results, and its History Bits give the original sources. Earlier versions are titled *A Modern
Introduction to Online Learning*.

Original sources cited in the layers:
- [AW01] K. S. Azoury and M. K. Warmuth, *Relative loss bounds for on-line density estimation with
  the exponential family of distributions*, Machine Learning 43 (2001) (Layer 8.4).
- [CCG04] N. Cesa-Bianchi, A. Conconi and C. Gentile, *On the generalization ability of on-line
  learning algorithms*, IEEE Trans. Inform. Theory 50 (2004) (Layer 3).
- [CMO23] A. Cutkosky, H. Mehta and F. Orabona, *Optimal stochastic non-smooth non-convex
  optimization through online-to-non-convex conversion*, ICML 2023 (Layer 16.3).
- [CO18] A. Cutkosky and F. Orabona, *Black-box reductions for parameter-free online learning in
  Banach spaces*, COLT 2018 (Layers 12–13).
- [Cov91] T. M. Cover, *Universal portfolios*, Mathematical Finance 1 (1991) (Layer 11).
- [DGS15] A. Daniely, A. Gonen and S. Shalev-Shwartz, *Strongly adaptive online learning*, ICML 2015
  (Layer 14.5).
- [DHS11] J. Duchi, E. Hazan and Y. Singer, *Adaptive subgradient methods for online learning and
  stochastic optimization*, JMLR 12 (2011) (Layer 2.4).
- [HAK07] E. Hazan, A. Agarwal and S. Kale, *Logarithmic regret algorithms for online convex
  optimization*, Machine Learning 69 (2007) (Layers 2.2, 8, 10.4).
- [JC22] A. Jacobsen and A. Cutkosky, *Parameter-free mirror descent*, COLT 2022 (Layers 12.4, 14.1).
- [JO24] K.-S. Jun and F. Orabona, *Tight concentrations and confidence sequences from the regret of
  universal portfolio*, IEEE Trans. Inform. Theory 70 (2024) (Layer 16.4).
- [KT81] R. Krichevsky and V. Trofimov, *The performance of universal encoding*, IEEE Trans. Inform.
  Theory 27 (1981) (Layer 13.2).
- [KW99] J. Kivinen and M. K. Warmuth, *Averaging expert predictions*, EuroCOLT 1999 (Layer 10.2).
- [LN23] G. Lugosi and G. Neu, *Online-to-PAC conversions: generalization bounds via regret
  analysis*, arXiv:2305.19674 (Layer 16.2).
- [McM17] H. B. McMahan, *A survey of algorithms and analysis for adaptive online learning*, JMLR 18
  (2017) (Layers 0.3, 5).
- [OP16] F. Orabona and D. Pál, *Coin betting and parameter-free online learning*, NeurIPS 2016
  (Layer 13).
- [RS13] A. Rakhlin and K. Sridharan, *Optimization, learning, and games with predictable
  sequences*, NeurIPS 2013 (Layers 7, 15.5).
- [Vov90] V. Vovk, *Aggregating strategies*, COLT 1990 (Layer 10.3).
- [Zha+18] L. Zhang, S. Lu and Z.-H. Zhou, *Adaptive online learning in dynamic environments*,
  NeurIPS 2018 (Layer 14.2).
