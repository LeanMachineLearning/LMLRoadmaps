# Roadmap: Bandit algorithms and their regret

Develop the regret theory of multi-armed and linear bandits: stochastic bandits with finitely
many arms, their minimax and instance-dependent lower bounds, adversarial bandits with finitely
many arms and with expert advice, online linear and convex optimization, and stochastic and
adversarial linear bandits. The headline results are the regret bounds of MOSS, asymptotically
optimal UCB, KL-UCB and Thompson sampling for exponential families, Exp3, Exp3-IX and Exp4 against
adaptive adversaries, OFUL, phased elimination with G-optimal designs, and mirror descent with
bandit feedback, matched by the minimax lower bounds and the Lai–Robbins lower bound.

Build the surrounding library at the generality the proofs support: index policies and
weight-based randomized policies, Ville's inequality and time-uniform concentration, the binary
relative entropy and the upper confidence levels of exponential families, the Bretagnolle–Huber
inequality, Legendre functions and Bregman projections, follow-the-regularized-leader and mirror
descent with time-varying regularizers and local norms, regularized and unregularized least
squares with self-normalized confidence sets, the elliptical potential lemma, and the
Kiefer–Wolfowitz theorem.

`README.md` is the definitive specification; `Suggested.lean` records selected interfaces and is
not an exhaustive checklist.

Suggested homes: `LMLExplore/Bandits/` for bandit material, `LMLExplore/OnlineLearning/` for
online linear and convex optimization, and the mathematical home of each general tool (for example
`LMLExplore/Probability/Martingale/` for Ville's inequality, `LMLExplore/InformationTheory/` for
the binary relative entropy and Bretagnolle–Huber, `LMLExplore/Analysis/Convex/` for Legendre
functions, `LMLExplore/Analysis/InnerProductSpace/` for design operators and the Kiefer–Wolfowitz
theorem).

## Scope and dependencies

This roadmap owns regret minimization for: stochastic bandits with a finite set of arms;
adversarial bandits with a finite set of arms against adaptive adversaries, oblivious reward tables
included, and bandits with expert advice; online linear and convex optimization with full
information; stochastic linear bandits with possibly changing decision sets; and adversarial linear
bandits with finite action sets or the Euclidean unit ball.

| Material | Owner and interface consumed here |
| --- | --- |
| Interaction protocol, runs, trajectory measure, stochastic and oblivious environments | LML `SequentialLearning/`: `Algorithm`, `Environment`, `IsAlgEnvSeq`, `trajMeasure`, `stationaryEnv`, `obliviousEnv`, `onlineEvalEnv`, `detAlgorithm` |
| Pull counts, reward sums, empirical means, the per-arm reward stream model | LML `SequentialLearning/FiniteActions.lean`, `SumRewards.lean`, `Online/Bandit/ArrayProbSpace.lean`, `Online/Bandit/RewardByCountMeasure.lean` |
| Stochastic regret, gaps, regret decomposition; regret of explore-then-commit, UCB and Bayesian Thompson sampling | LML `Online/Bandit/Regret.lean` and `Online/Bandit/Algorithms/` |
| Means of the feedback laws along a run | LML `SequentialLearning/Means.lean` (`Environment.means`) |
| KL divergence of interaction histories (time-sum form) | LML `SequentialLearning/DivergenceDecomposition.lean` |
| KL divergence, chain rule, data processing, Pinsker, Donsker–Varadhan | Mathlib `InformationTheory/KullbackLeibler/`, LML `ForMathlib/InformationTheory/KullbackLeibler/`, Tau Ceti `InformationTheory/KullbackLeibler/` |
| Exponential families: members, means, natural parameters, divergence and Cramér–Chernoff rate function; the Cramér–Chernoff bound under domination by a member | Identification roadmap, Layer 1.2 (`expFamily`, `expFamilyMeans`, `natParam`, `expFamilyDiv`) |
| Conditional MGF domination, its supermartingale and time-uniform bound; σ²-sub-Gaussian laws are dominated by the Gaussian family | Identification roadmap, Layer 4.2 |
| Transfer of events about the first `s` rewards of each arm from runs to the reward-stream model | Identification roadmap, Layer 4.1 |
| Sub-Gaussian random variables, Hoeffding and Azuma–Hoeffding, Doob's maximal inequality | Mathlib `Probability/Moments/SubGaussian.lean`, `Probability/Martingale/` |
| Bregman divergence and subgradients | LML `ForMathlib/Analysis/Convex/Bregman/`, `ForMathlib/Analysis/Convex/Subgradient/` |
| Fenchel conjugate, strong convexity first-order bound | Tau Ceti `Analysis/Convex/Conjugate.lean`, `Analysis/Convex/Strong.lean` |
| Positive operators, Loewner order, matrix determinant lemma, Woodbury identity | Mathlib `Analysis/InnerProductSpace/Positive.lean`, `LinearAlgebra/Matrix/SchurComplement.lean`, `LinearAlgebra/Matrix/NonsingularInverse.lean` |
| Moore–Penrose inverse | Tau Ceti `Analysis/InnerProductSpace/MoorePenrose.lean` |
| Finitely supported probability measures | Mathlib `Geometry/Convex/ConvexSpace/Defs.lean` (`Convexity.StdSimplex`) |

Build missing material in this roadmap where it is listed as a target, and consume existing
implementations directly.

Outside this roadmap: pure exploration and best-arm identification (LML's `IdentAlg` framework),
sparse linear bandits, combinatorial and semi-bandits, non-stationary bandits, ranking, partial
monitoring, Markov decision processes, Bayesian-optimal policies and Gittins indices, Bayesian regret
beyond what LML proves, high-probability lower bounds, asymptotic lower bounds for linear bandits,
and bandit convex optimization (convex losses with bandit feedback). AdaHedge and its regret bounds
belong to the Identification roadmap (Layer 6.1). Scalar Bernstein, McDiarmid and matrix
concentration inequalities belong to Tau Ceti's `RandomMatrices` roadmap; nothing here needs them.

## Conventions

**Sources and numbering.** Statements follow Lattimore and Szepesvári, *Bandit Algorithms*
(Cambridge University Press, 2020), cited as [LS] with chapter and theorem numbers. The book's
rounds are numbered from 1; Lean rounds are numbered from 0, as in LML. Book round $t$ is Lean round
$t-1$: a quantity the book computes at round $t$ from $t-1$ past rounds is computed in Lean at round
$t-1$ from the history of length $t-1$, and a book horizon $n$ is the Lean horizon $n$ (rounds
$0,\dots,n-1$). For example the index $f(t)=1+t\log^2 t$ of [LS, Chapter 8] is evaluated at $t=m+1$
in Lean round $m$.

**Arms.** A finite set of arms is a type `α` with `[Fintype α] [Nonempty α] [DecidableEq α]
[MeasurableSpace α] [MeasurableSingletonClass α]`, and $k$ is `Fintype.card α`. Do not specialize
algorithms or theorems to `Fin K`. Algorithms never rely on an enumeration of the arms: an arm not
pulled yet has index $+\infty$, so "pull each arm once" is the behaviour of the index policy itself.
LML's existing algorithms (`etcAlgorithm`, `ucbAlgorithm`) are stated on `Fin K`; consume them as
they are.

**Rewards and losses.** Stochastic bandits, adversarial bandits with finitely many arms and bandits
with expert advice use rewards and maximization, as LML's `regret` and [LS, Chapters 4–18] do.
Online linear and convex optimization and adversarial linear bandits use losses and minimization,
as [LS, Chapters 26–28] and convex analysis do. Where the analysis of a reward-based algorithm passes
through a loss-based tool, state the translation $y = 1 - x$ (or $y=-x$) once as a lemma.

**Stochastic bandits.** A stochastic bandit is a Markov kernel `ν : Kernel α ℝ` and its environment
is LML's `stationaryEnv ν`. The mean of arm $a$ is `(ν a)[id]`. Noise assumptions are stated per
arm, as in LML: σ²-sub-Gaussian rewards are
`∀ a, HasSubgaussianMGF (fun x ↦ x - (ν a)[id]) σ2 (ν a)` with `σ2 : ℝ≥0` the variance proxy, and
bounded rewards are `∀ a, ∀ᵐ x ∂(ν a), x ∈ Set.Icc 0 1`. Where [LS] assumes 1-subgaussian rewards,
state the result for σ²-sub-Gaussian rewards; the constants below include $\sigma^2$.

**Regret.** The expected stochastic regret is `P[regret ν A n]` with LML's `regret`, the expectation
of $\sum_{t<n}\Delta_{A_t}$. An adversarial bandit with finitely many arms is a
run against an arbitrary environment `env : Environment 𝓞 α ℝ`, an *adaptive adversary*: the
reward law of round $t$ may depend on the history and on the observation of round $t$. Its *mean
table* $m_t(a)$ is LML's `env.means O A Y a t`, the mean reward of arm $a$ at round $t$ given the
past. The *pseudo-regret* is $\bar R_n=\max_a\mathbb E\big[\sum_{t<n}(m_t(a)-Y_t)\big]$
[BCB12, Section 3] and the *random regret* is $\hat R_n=\max_a\sum_{t<n}(m_t(a)-Y_t)$. Against an
oblivious reward table $x:\mathbb N\to\alpha\to\mathbb R$ (`onlineEvalEnv x _`), $m_t(a)=x_t(a)$ and
$\bar R_n$ is the adversarial regret
$R_n(x)=\max_a\sum_{t<n}x_t(a)-\mathbb E\big[\sum_{t<n}x_t(A_t)\big]$ [LS, (11.1)]; against
`stationaryEnv ν` it is the expected stochastic regret. Linear regrets are defined in Layer 9 and
Layer 10.

**Learning rates.** Learning rates and implicit-exploration parameters are sequences
`η γ : ℕ → ℝ` fixed in advance, nonincreasing, with $\eta_t>0$ and $\gamma_t\ge0$ used at Lean
round $t$. A rate tuned for the horizon $n$ is a constant sequence; an anytime rate does not depend
on the horizon, for example $\eta_t=c/\sqrt{t+1}$. Bounds after $n$ rounds involve $\eta_{n-1}$,
the rate of the last round played.

**Theorem shapes.** Upper bounds quantify over runs: for every `IsAlgEnvSeq O A Y alg env P`, a
bound on an expectation or a probability under `P`. Lower bounds quantify over algorithms and
assert the existence of an environment; state them for `trajMeasure alg env` and derive the
statement for every run with LML's uniqueness of the law (`IsAlgEnvSeq.map_trajectory`). Asymptotic
statements are written with eventual inequalities, never with `limsup`/`liminf` of real sequences:
"$\limsup_n R_n/\log n\le c$" is `∀ c' > c, ∀ᶠ n in atTop, R n ≤ c' * log n`, and lower bounds
quantify over `c' < c`. Where [LS] states a universal constant $C$, state an explicit numerical
constant when the proof gives one; otherwise state `∃ C > 0, ∀ …` with `C` quantified before every
problem parameter.

**Generality.** Each layer lists where its statements generalize [LS]. Do not reintroduce the
book's special cases (`Fin K`, unit variance, Gaussian or Bernoulli arms where an exponential family
works, oblivious tables, learning rates tuned to the horizon, $\mathbb R^d$ instead of an inner
product space) as the primary statements; derive them as corollaries when useful.

**Namespaces.** Bandit definitions live in `LMLExplore.Bandits`, online-learning definitions in
`LMLExplore.OnlineLearning`, general tools in `LMLExplore` or in the namespace of the type they act
on (dot notation). LML's definitions keep their names (`Learning.stationaryEnv`, `Bandits.regret`,
…).

## Existing library and design guidance

Consume these modules and extend their APIs rather than restating them. The links pin the
dependency versions used to check the interfaces (LML `53be244`, Mathlib `2e318fae`, Tau Ceti
`v4.36.0-rc1`).

| Foundation | Existing source |
| --- | --- |
| Interaction protocol and law of a run | [LML `Algorithm.lean`][lml-alg] (`Algorithm`, `Environment`, `IsAlgEnvSeq`, `history`, `IsAlgEnvSeq.filtration`, `IsAlgEnvSeq.filtrationObs`: the history before round `t` and the observation of round `t`), [`IonescuTulceaSpace.lean`][lml-it] (`trajMeasure`, `IT.isAlgEnvSeq_trajMeasure`, `IsAlgEnvSeq.map_trajectory`) |
| Means of the feedback laws | [LML `Means.lean`][lml-means] (`Environment.means`, `IsAlgEnvSeq.condExp_feedback`, `means_bandit`) |
| Stochastic and oblivious environments | [LML `StationaryEnv.lean`][lml-env] (`stationaryEnv`, `obliviousEnv`, `IsObliviousEnv`), [`EvaluationEnv.lean`][lml-eval] (`onlineEvalEnv g hg`, the oblivious adversary with bandit feedback) |
| Deterministic algorithms and measurable argmax | [LML `Deterministic.lean`][lml-det] (`detAlgorithm`), [`MeasurableArg.lean`][lml-argmax] (`argmax`, `measurable_argmax`) |
| Counts, sums, empirical means, per-arm reward streams | [LML `FiniteActions.lean`][lml-fa] (`pullCount`, `pullCount'`, `rewardByCount`), [`SumRewards.lean`][lml-sum] (`sumRewards`, `empMean`, `empMean'`), [`Online/Bandit/SumRewards.lean`][lml-conc] (`prob_sumRewards_sub_pullCount_mul_ge_le` and the transfer to the i.i.d. stream model) |
| Stochastic regret and existing regret bounds | [LML `Regret.lean`][lml-regret] (`regret`, `gap`, `integral_regret_le_of_forall_integral_pullCount_le`), [`Regret/UCB.lean`][lml-ucb] (`UCB.expectation_pullCount_le`, `UCB.regret_le_of_gt_two'`), [`Regret/ETC.lean`][lml-etc], [`Regret/BayesRegretTS.lean`][lml-ts] |
| KL divergence of histories | [LML `DivergenceDecomposition.lean`][lml-div] (`IsAlgEnvSeq.klDiv_map_history`: the time-sum $\sum_{t<n}\int D(\nu_{A_t},\nu'_{A_t})$ for two stationary environments) |
| KL divergence | Mathlib `InformationTheory.klDiv`, `klDiv_compProd_eq_add`, `klDiv_map_le`; LML [`ChainRule.lean`][lml-chain] (`klDiv_compProd_right_eq_lintegral`); Tau Ceti [`Pinsker.lean`][tc-pinsker] (`two_mul_sq_measureReal_sub_le_klDiv`) and [`Variational.lean`][tc-dv] |
| Sub-Gaussian concentration and martingales | Mathlib [`SubGaussian.lean`][ml-subg] (`HasSubgaussianMGF`, `HasCondSubgaussianMGF`, `hasSubgaussianMGF_of_mem_Icc`, `measure_sum_ge_le_of_iIndepFun`, `measure_sum_ge_le_of_hasCondSubgaussianMGF`), [`OptionalStopping.lean`][ml-os] (`maximal_ineq`), `Supermartingale` |
| Laws | Mathlib `gaussianReal`, `bernoulliMeasure`, `multivariateGaussian`; Tau Ceti [`Gaussian/Cdf.lean`][tc-gauss] (`measureReal_Ioi_gaussianReal`) |
| Convex analysis | LML [`Bregman/Basic.lean`][lml-breg] (`bregDiv`, notation `D_[f](x, y, J)`, `bregDiv_three_point`), [`Subgradient/`][lml-subgrad]; Tau Ceti [`Conjugate.lean`][tc-conj] (`fenchelConjugate`, for a bilinear pairing), [`Strong.lean`][tc-strong] (`StrongConvexOn.add_add_le_of_hasFDerivWithinAt`); Mathlib `StrongConvexOn`, `PiLp`; LMLExplore `simplex` (`Analysis/Convex/Simplex.lean`) |
| Linear algebra | Mathlib `ContinuousLinearMap.IsPositive` and its Loewner order, `LinearMap.det`, `Matrix.det_one_add_replicateCol_mul_replicateRow`, `Matrix.add_mul_mul_inv_eq_sub`; Tau Ceti [`Frame.lean`][tc-frame] (`frameOperator`), [`AffineNormalization.lean`][tc-affine] (`IsCompact.exists_affineBasis_abs_coord_le_one`) and [`MoorePenrose.lean`][tc-mp] (`LinearMap.moorePenroseInverse`, `LinearMap.IsMoorePenroseInverse`, `LinearEquiv.moorePenroseInverse_eq_symm`) |
| Designs | Mathlib `Convexity.StdSimplex` (finitely supported probability weights; `StdSimplex.map`, `StdSimplex.range_toFun_comp_weights`) |
| LMLExplore material that the general forms below extend | exponential families (`Probability/Distributions/ExponentialFamily/`: `Measure.expFamily`, `expFamilyMeans`, `natParam`, `expFamilyDiv`), MGF domination (`MGFDominatedOn`, `mgfDominatedOn_Ici_bernoulliMeasure`, `mgfDominatedOn_Iic_bernoulliMeasure`), the Bandits algorithms `ucbF`, `klucb`, `gaussianTS`, `exp3`, `exp3IX`, `exp4` and the lower-bound files, follow-the-perturbed-leader policies (`perturbedLeaderAlgorithm`, `PerturbedLeader.lintegral_pullCount_le`), the FTRL lemma `sum_apply_sub_le_ftrl` (time-varying regularizers), `ConvexOn.exists_mem_segment_apply_sub_sub_bregDiv_div_le` (second-order Bregman bound), `softmax_regret_le`, `IsUnbiasedRound`, `designOp`, `ridgeEstimate` |

The [Kiefer–Wolfowitz formalization in `colt-2026-83`][kw] (Apache-2.0, no `sorry`) proves the
existence of G-optimal designs for compact spanning subsets of `EuclideanSpace ℝ ι`
(`exists_isGOptimalDesign`, `IsGOptimalDesign.gValue_eq`) with matrices. Layer 8 asks for the
statement on a finite-dimensional inner product space, with the support bound and the non-spanning
case; that development may be adapted to it.

LML's `main` branch renames the framework after the version pinned here: `stationaryEnv` becomes
`Environment.bandit`, `obliviousEnv` becomes `Environment.banditSeq`, `onlineEvalEnv` becomes
`Environment.evalSeq`, `detAlgorithm` becomes `Algorithm.deterministic`, and `IsObliviousEnv`
becomes `Environment.IsOblivious` with a stronger meaning. Use the names of the pinned version; the
dependency sync that brings the rename updates this roadmap and the code together.

## Layers and dependencies

| Layer | Content | Prerequisites |
| --- | --- | --- |
| 0 | Instances, binary relative entropy, policies, regret notions | LML framework |
| 1 | Concentration and maximal inequalities | Layer 0; Identification roadmap Layers 1.2, 4.1 and 4.2 |
| 2 | UCB-type algorithms for sub-Gaussian rewards | Layers 0–1; LML UCB |
| 3 | KL-UCB for exponential families | Layers 0–1; Identification roadmap Layer 1.2 |
| 4 | Lower bounds for finitely many arms | Layer 0; LML divergence decomposition; Layers 2–3 for item 5 |
| 5 | Thompson sampling | Layers 0–1; Identification roadmap Layer 1.2; Layer 4 for asymptotic optimality |
| 6 | Convex analysis, online linear and convex optimization | Layer 0 |
| 7 | Adversarial bandits with finitely many arms and expert advice | Layers 0, 6; Layer 4.5 for the lower bound |
| 8 | Least squares, self-normalized bounds, optimal design | Layer 1 |
| 9 | Stochastic linear bandits | Layers 0, 8; Layer 4 tools for lower bounds |
| 10 | Adversarial linear bandits | Layers 6–8 |

## Layer 0: Instances, binary relative entropy, policies and regret notions

1. **Bandit instances.** Define the Gaussian bandit `gaussianBandit μ σ2 : Kernel α ℝ` with arm laws
   $\mathcal N(\mu_a,\sigma^2)$ and the Bernoulli bandit `bernoulliBandit p : Kernel α ℝ` with arm
   laws $\mathcal B(p_a)$ on $\{0,1\}\subset\mathbb R$, for `μ : α → ℝ` and `p : α → unitInterval`.
   Prove their means, that Gaussian arms are σ²-sub-Gaussian (absent from Mathlib: derive it from
   `mgf_id_gaussianReal`), that Bernoulli arms are $\tfrac14$-sub-Gaussian, and the closed forms
   $D(\mathcal N(\mu,\sigma^2),\mathcal N(\mu',\sigma^2))=(\mu-\mu')^2/(2\sigma^2)$ and
   $D(\mathcal B(p),\mathcal B(q))=d(p,q)$ for `klDiv` [LS, Theorem 14.1].
2. **Binary relative entropy.** Define $d(p,q)$ for $p,q\in[0,1]$ with the limiting values of
   [LS, Definition 10.1], valued in `ℝ≥0∞` as `klBer p q`, the `klDiv` of the two Bernoulli laws,
   and a real-valued `klBerReal p q` agreeing with it where it is finite. Prove [LS, Lemma 10.2]:
   convexity in each argument with unique minimizers, Pinsker $d(p,q)\ge 2(p-q)^2$, and
   $d(p,q-\varepsilon)\le d(p,q)-d(q-\varepsilon,q)$ for $p\le q-\varepsilon\le q$; monotonicity
   of $q\mapsto d(p,q)$ on each side of $p$; continuity on $[0,1]\times(0,1)$; and the bound
   $d(p,q)\le (p-q)^2/(q(1-q))$ for $q\in(0,1)$. Define the upper confidence level
   $U(p,c)=\max\{q\in[p,1]:d(p,q)\le c\}$ for $c\ge0$ and prove it is well defined, measurable in
   $(p,c)$, monotone in both arguments, satisfies $d(p,U(p,c))\le c$, and
   $U(p,c)\le\min\{1,p+\sqrt{c/2}\}$ (by Pinsker, the KL-UCB index is at most the Hoeffding index).
3. **Weight-based policies.** Construct an algorithm from measurable weights
   $p_t:\mathrm{Hist}_t\times\mathcal O\to\Delta(\alpha)$ in the probability simplex: its policy
   kernel at round $t$ is $\sum_a p_t(h,o)(a)\,\delta_a$. Prove the run lemma: given the history and
   the observation, the conditional law of $A_t$ is that measure, so
   $P(A_t=a\mid\mathcal F_{t-1},O_t)=p_t(a)$. Exp3, Exp3-IX, Exp4 and exponential weights use it.
4. **Index policies.** Construct the deterministic algorithm playing `argmax` of a measurable index
   $I_t:\mathrm{Hist}_t\times\mathcal O\to\alpha\to\overline{\mathbb R}$ (in `EReal`), with ties
   broken by LML's `argmax`. Prove its run lemma and the properties every UCB-type proof uses: if
   $A_t=a$ then $I_t(a)\ge I_t(b)$ for all $b$; an arm with index $+\infty$ is pulled before any arm
   with a finite index; under an index that is $+\infty$ exactly on unpulled arms, every arm is
   pulled once during the first $k$ rounds.
5. **Adversarial and expert regrets.** Define the pseudo-regret $\bar R_n$ and the random regret
   $\hat R_n$ of the Conventions for runs against any environment `env : Environment 𝓞 α ℝ` with
   integrable feedback laws, and prove $\bar R_n\le\mathbb E[\hat R_n]$. Prove that against
   `onlineEvalEnv x _` the pseudo-regret is the adversarial regret $R_n(x)$ and the random regret
   is $\max_a\sum_{t<n}(x_t(a)-x_t(A_t))$ [LS, Chapter 12], and that against `stationaryEnv ν` with
   integrable arms the pseudo-regret is `P[regret ν A n]`. Construct the environment of a
   deterministic adaptive adversary, whose feedback at round $t$ is $x_t(h,o)(a)$ for measurable
   tables $x_t:\mathrm{Hist}_t\times\mathcal O\to(\alpha\to\mathbb R)$; `onlineEvalEnv x _` is the
   case of tables that do not depend on $(h,o)$. For bandits with expert advice, the advice
   $E_t\in\Delta(\alpha)^M$ of round $t$ is a measurable function of the observation of round $t$,
   and the expert pseudo-regret and random regret are
   $\bar R^E_n=\max_m\mathbb E\big[\sum_{t<n}(\langle E_t(m),m_t\rangle-Y_t)\big]$ and
   $\hat R^E_n=\max_m\sum_{t<n}(\langle E_t(m),m_t\rangle-Y_t)$ ([LS, (18.6)] for advice and
   tables fixed in advance); with the $k$ experts that each recommend one arm they are $\bar R_n$
   and $\hat R_n$. Construct the environment with
   deterministic observations (the advice) and bandit feedback. Prove that for i.i.d. reward tables
   the expected adversarial regret dominates the stochastic regret: the law of the first $n$ rounds
   against `stationaryEnv ν` is the mixture, over tables $x$ whose rows $x_t$ are independent with
   law $\bigotimes_a\nu_a$, of the laws against `onlineEvalEnv x _`, so that
   $\mathbb E_x[R_n(x)]\ge\mathbb E_\nu[R_n]$ (used in Layer 4.5).

Completion examples: a one-armed bandit has zero regret for every algorithm; Gaussian and Bernoulli
instances satisfy the sub-Gaussian and boundedness hypotheses used later;
$U(p,0)=p$, $U(1,c)=1$, and $U(p,c)\to1$ as $c\to\infty$; the pseudo-regret of every algorithm
against an environment with a single arm is $0$.

## Layer 1: Concentration and maximal inequalities

1. **Ville's inequality.** For a nonnegative supermartingale $(M_t)_{t\in\mathbb N}$ and $c>0$:
   $P(\exists t,\ M_t\ge c)\le \mathbb E[M_0]/c$. Derive it from Doob's maximal inequality
   (`maximal_ineq` is stated for submartingales; add the supermartingale form) by monotone
   convergence in the horizon.
2. **Time-uniform sub-Gaussian bounds.** For a process adapted to a filtration whose increments are
   conditionally σ²-sub-Gaussian (`HasCondSubgaussianMGF`), prove that
   $\exp(\lambda S_t-\lambda^2\sigma^2t/2)$ is a supermartingale, the maximal inequality
   $P(\exists t\le n,\ S_t\ge\varepsilon)\le\exp(-\varepsilon^2/(2n\sigma^2))$ [LS, Theorem 9.2],
   and its time-uniform union-bound consequences used by Layers 2 and 8.
3. **Per-arm statements on runs.** The transfer of events about the first $s$ rewards of each arm
   from a run of any algorithm against `stationaryEnv ν` to LML's reward-stream model, for all $s$
   simultaneously, is the Identification roadmap's Layer 4.1. Its single-arm counting form for real
   rewards bounds
   $\mathbb E\big[\sum_{s}\mathbb 1\{\text{event about the first } s \text{ rewards of arm } a\}\big]$
   by the corresponding i.i.d. quantity; the lemmas of item 5 and of Layer 3.2 are proved in the
   stream model and transferred to runs by it.
4. **Chernoff bounds in rate-function form.** The Cramér–Chernoff bound under domination by a member
   of an exponential family, at every level through the rate function, is the Identification
   roadmap's Layer 1.2. Its conditional, time-uniform form (conditional MGF domination, the
   supermartingale $\exp(\lambda S_t-\psi(\lambda)N_t)$ of a sum sampled along a predictable
   sequence, and Ville's inequality, as in the proof of [GC11, Theorem 10]) is that roadmap's
   Layer 4.2. Prove here the bounded instance: a random variable with values in $[0,1]$ whose
   conditional mean given a σ-algebra is at most (at least) $m$ is conditionally dominated by
   $\mathcal B(m)$ on $[0,\infty)$ (on $(-\infty,0]$) [GC11, Lemma 9; LS, Note 10.3.1], and the rate function of
   $\mathcal B(m)$ at a level $p\in[0,1]$ is `klBer p m`. Deduce for i.i.d. $X_i\in[0,1]$ with mean
   $\mu$ [LS, Lemma 10.3]: $P(\hat\mu_n\ge\mu+\varepsilon)\le\exp(-n\,d(\mu+\varepsilon,\mu))$ for
   $\varepsilon\in[0,1-\mu]$ and the lower tail, the boundary levels $0$ and $1$ included, and
   [LS, Corollary 10.4] for the confidence levels $U$ and $L$.
5. **Lemmas for the index policies.** Prove, for σ²-sub-Gaussian streams, [LS, Lemma 8.2] and
   [LS, Lemma 9.3], and the summation bound $\sum_{t\le n}\frac1{f(t)}\sum_{s\le n}
   e^{-s\varepsilon^2/(2\sigma^2)}\le 5\sigma^2/\varepsilon^2$ of [LS, Exercise 8.1]. Scale the
   constants with $\sigma^2$ as in Layer 2. The lemmas of KL-UCB, [LS, Lemmas 10.7 and 10.8], are
   Layer 3.2.
6. **Gaussian tails.** For $Z\sim\mathcal N(0,1)$ and $x>0$:
   $\frac{x}{x^2+1}\varphi(x)\le P(Z\ge x)\le\min\{\varphi(x)/x,\ \tfrac12e^{-x^2/2}\}$, with
   $\varphi$ the standard Gaussian density.

Completion checks: Ville's inequality is sharp for the martingale $M_t=1$; the per-arm transfer of
item 3 applied to LML's existing union bound recovers `prob_sumRewards_sub_pullCount_mul_ge_le`.

## Layer 2: UCB-type algorithms for sub-Gaussian rewards

Throughout, rewards are σ²-sub-Gaussian with `σ2 ≠ 0`, $\Delta_a$ is `gap ν a`, and indices of
unpulled arms are $+\infty$.

1. **Minimax bound for LML's UCB.** From `UCB.expectation_pullCount_le` and
   `integral_regret_le_of_forall_integral_pullCount_le`, prove for `ucbAlgorithm K c` with
   $c>2\sigma^2$:
   $\mathbb E[R_n]\le 2\sqrt{8cKn\log(n+1)}+\big(4+\frac{2\sigma^2}{c-2\sigma^2}\big)\sum_a\Delta_a$,
   by splitting the arms according to whether $\Delta_a$ is below $\sqrt{8cK\log(n+1)/n}$
   (the analogue of [LS, Theorem 7.2]).
2. **Asymptotically optimal UCB.** Define the index policy `ucbF σ2` with index
   $\hat\mu_a+\sqrt{2\sigma^2\log f(t)/T_a}$, $f(t)=1+t\log^2 t$ [LS, Algorithm 6]. Prove
   [LS, Theorem 8.1] for σ²-sub-Gaussian rewards:
   $$\mathbb E[R_n]\le\sum_{a:\Delta_a>0}\inf_{\varepsilon\in(0,\Delta_a)}\Delta_a\Big(1+\frac{5\sigma^2}{\varepsilon^2}+\frac{2\sigma^2\big(\log f(n)+\sqrt{\pi\log f(n)}+1\big)}{(\Delta_a-\varepsilon)^2}\Big),$$
   and, in eventual form, $\limsup_n\mathbb E[R_n]/\log n\le\sum_{a:\Delta_a>0}2\sigma^2/\Delta_a$.
   This index is the KL-UCB index of the Gaussian family of variance $\sigma^2$ (Layer 3.3), and the
   eventual form is also the Gaussian instance of Layer 3.4; the explicit constants above keep the
   proof through [LS, Lemma 8.2].
3. **MOSS.** Define the horizon-dependent index policy with index
   $\hat\mu_a+\sqrt{\frac{4\sigma^2}{T_a}\log^+\frac{n}{kT_a}}$ [LS, Algorithm 7] and prove
   [LS, Theorem 9.1]: $\mathbb E[R_n]\le 39\sqrt{\sigma^2kn}+\sum_a\Delta_a$.

Generalization: arbitrary finite arm types and variance proxies, where [LS] has $[k]$ and
1-subgaussian rewards. Completion examples: for two Gaussian arms with gap $\Delta$, the bounds of
items 2 and 3 are finite and the asymptotic constant is $2\sigma^2/\Delta$.

## Layer 3: KL-UCB for exponential families

Throughout, a *family* is an exponential family of the Identification roadmap's Layer 1.2 with the
identity statistic, since rewards are real (a family $(\rho,T)$ enters through the natural family
of `ρ.map T`, which has the same means and divergence): a probability measure $\rho$ on
$\mathbb R$, its members $\rho_\theta=$ `ρ.expFamily id θ` for $\theta$ in the interior
$\Theta_\rho$ of `integrableExpSet id ρ`, its open interval of means $M_\rho=$
`ρ.expFamilyMeans id`, the member $\rho_{(q)}$ of mean $q\in M_\rho$ (natural parameter
$\eta_\rho(q)=$ `ρ.natParam id q`), the divergence $d_\rho(x,q)=$ `ρ.expFamilyDiv id x q` on
$M_\rho\times M_\rho$, and its extension $\bar d_\rho(x,q)\in[0,\infty]$ to every level
$x\in\mathbb R$, the Cramér–Chernoff rate function of $\rho_{(q)}$ at $x$. Each arm $a$ has its
own family $\rho_a$. Arm $a$ is *dominated by its family* if its mean $\mu_a$ lies in
$M_{\rho_a}$ and its law $\nu_a$ is MGF-dominated by $\rho_{a,(\mu_a)}$ on $\mathbb R$
(LMLExplore's `MGFDominatedOn` with `Set.univ`). Laws on $[0,1]$ with mean in $(0,1)$ are
dominated by the Bernoulli family (`mgfDominatedOn_Ici_bernoulliMeasure`,
`mgfDominatedOn_Iic_bernoulliMeasure`), σ²-sub-Gaussian laws by the Gaussian family of variance
$\sigma^2$ (Identification roadmap, Layer 4.2), and the members of a family by the family itself.

1. **Upper confidence levels.** For a family $\rho$, $x\in\mathbb R$ and $c\in[0,\infty]$, define
   $U_\rho(x,c)=\sup\big(\{x\}\cup\{q\in M_\rho:x\le q,\ \bar d_\rho(x,q)\le c\}\big)$ in `EReal`.
   Prove that it is measurable in $(x,c)$, monotone in both arguments and at least $x$, and that
   $q\le U_\rho(x,c)$ iff $\bar d_\rho(x,q)\le c$ for $x\le q\in M_\rho$, since
   $q\mapsto \bar d_\rho(x,q)$ is continuous and increasing on $M_\rho\cap[x,\infty)$. Prove the
   three-point identity
   $\bar d_\rho(x,\mu)=\bar d_\rho(x,q)+d_\rho(q,\mu)+(q-x)(\eta_\rho(\mu)-\eta_\rho(q))$ for
   $x\in\mathbb R$ and $q,\mu\in M_\rho$, whose last term is nonnegative for $x\le q\le\mu$ (for
   Bernoulli laws this gives the inequality $d(p,q-\varepsilon)\le d(p,q)-d(q-\varepsilon,q)$ of
   Layer 0.2). Instances: for the Bernoulli family, $\bar d_\rho(x,q)=$ `klBer x q` for
   $x\in[0,1]$ (Layer 1.4) and $U_\rho(x,c)$ is the level $U(x,c)$ of Layer 0.2 for $x\in[0,1]$; for the Gaussian family of
   variance $\sigma^2\ne0$, $\bar d_\rho(x,q)=(x-q)^2/(2\sigma^2)$ and
   $U_\rho(x,c)=x+\sqrt{2\sigma^2c}$ for finite $c$.
2. **Concentration lemmas.** Let $X_1,X_2,\dots$ be independent and dominated by the member
   $\rho_{(\mu)}$ of a family, with empirical mean $\hat\mu_s$ after $s$ samples. Prove the
   generalization of [LS, Lemma 10.8]: for $\varepsilon>0$ and $\mu+\varepsilon<c$ with
   $\mu+\varepsilon,c\in M_\rho$, and $L\ge0$,
   $\sum_{s<n}P\big(s=0\ \lor\ c\le\hat\mu_s\ \lor\ s\,\bar d_\rho(\hat\mu_s,c)\le L\big)\le
   1+\frac{L}{d_\rho(\mu+\varepsilon,c)}+\frac1{d_\rho(\mu+\varepsilon,\mu)}$. Prove the
   generalization of [LS, Lemma 10.7]: for $\varepsilon>0$ with $\mu-\varepsilon\in M_\rho$ and
   $s\ge1$, $P\big(U_\rho(\hat\mu_s,L/s)\le\mu-\varepsilon\big)\le e^{-L}e^{-s\,d_\rho(\mu-\varepsilon,\mu)}$,
   by the three-point identity and the Chernoff bound of Layer 1.4; and in a run of any algorithm
   against `stationaryEnv ν`, with the exploration level $\log f(t+1)$ at Lean round $t$, the
   expected number of rounds at which an arm with law $\nu_a$ dominated by $\rho_{(\mu)}$ has been
   pulled and has index $U_\rho(\hat\mu_a,\log f(t+1)/T_a)\le\mu-\varepsilon$ is at most
   $3/(2\,d_\rho(\mu-\varepsilon,\mu))$. For rewards in $[0,1]$ with mean in $(0,1)$, Pinsker's
   inequality $d(p,q)\ge2(p-q)^2$ (Layer 0.2) turns these into [LS, Lemmas 10.7 and 10.8], with the
   constants $3/(4\varepsilon^2)$ and $1/(2\varepsilon^2)$.
3. **Algorithm.** Define KL-UCB for families $(\rho_a)_a$ [LS, Algorithm 8; GC11, Section 4]: the
   index policy with index $U_{\rho_a}(\hat\mu_a,\log f(t)/T_a)$, $f(t)=1+t\log^2t$, and $+\infty$
   for unpulled arms. Define `klucb`, KL-UCB for rewards in $[0,1]$, as the instance with the
   Bernoulli family on every arm, and prove that its index is the index
   $U(\hat\mu_a,\log f(t)/T_a)$ of [LS, Algorithm 8] (with $U$ of Layer 0.2) at empirical means in
   $[0,1]$. Prove that `ucbF σ2` (Layer 2.2) is the instance with the Gaussian family of variance
   $\sigma^2$ on every arm.
4. **Regret.** Let every arm be dominated by its family, let $a^*$ be an optimal arm and $a$ an
   arm with $\Delta_a>0$. For $\varepsilon_1,\varepsilon_2>0$ with
   $\varepsilon_1+\varepsilon_2<\Delta_a$, $\mu_a+\varepsilon_1,\mu^*-\varepsilon_2\in M_{\rho_a}$
   and $\mu^*-\varepsilon_2\in M_{\rho_{a^*}}$, prove
   $$\mathbb E[T_a(n)]\le1+\frac{\log f(n)}{d_{\rho_a}(\mu_a+\varepsilon_1,\mu^*-\varepsilon_2)}+\frac1{d_{\rho_a}(\mu_a+\varepsilon_1,\mu_a)}+\frac3{2\,d_{\rho_{a^*}}(\mu^*-\varepsilon_2,\mu^*)},$$
   the resulting bound on $\mathbb E[R_n]$, and, when $\mu^*\in M_{\rho_a}$ for every arm $a$ with
   $\Delta_a>0$, the eventual form
   $\limsup_n\mathbb E[R_n]/\log n\le\sum_{a:\Delta_a>0}\Delta_a/d_{\rho_a}(\mu_a,\mu^*)$
   [GC11; CGMMS13]. Deduce, as the Bernoulli instance, [LS, Theorem 10.6] for rewards in $[0,1]$
   almost surely:
   $$\mathbb E[R_n]\le\sum_{a:\Delta_a>0}\inf_{\substack{\varepsilon_1,\varepsilon_2>0\\\varepsilon_1+\varepsilon_2<\Delta_a}}\Delta_a\Big(\frac{\log f(n)}{d(\mu_a+\varepsilon_1,\mu^*-\varepsilon_2)}+\frac1{2\varepsilon_1^2}+\frac2{\varepsilon_2^2}\Big),$$
   and $\limsup_n\mathbb E[R_n]/\log n\le\sum_{a:\Delta_a>0}\Delta_a/d(\mu_a,\mu^*)$, arms with
   mean $0$ or $1$ (Dirac laws, outside the open Bernoulli family) being treated directly (the book
   leaves this limit to its Exercise 10.2; its proof writes $f(n)$ for $\log f(n)$ in the last
   line). Deduce, as the Gaussian instance, the eventual form of Layer 2.2 for σ²-sub-Gaussian
   rewards.

Generalization: one exponential family per arm and reward laws dominated by their family members,
where [LS] states Bernoulli rewards and [GC11, CGMMS13] one family whose members are the reward
laws. Completion examples: arms with means $0$ or $1$ in the $[0,1]$ instance; a two-armed Bernoulli
bandit; the boundary empirical means of the Bernoulli family, $U(0,c)=1-e^{-c}$ and $U(1,c)=1$;
exponential rewards (`expMeasure`, $d(x,q)=x/q-1-\log(x/q)$); Gaussian arms with different known
variances.

## Layer 4: Lower bounds for finitely many arms

1. **Divergence decomposition.** For an algorithm run against two stationary environments `ν`, `ν'`
   on a finite arm type, prove [LS, Lemma 15.1] in `ℝ≥0∞`:
   $D(P_{\nu}^{(n)},P_{\nu'}^{(n)})=\sum_a\mathbb E_\nu[T_a(n)]\,D(\nu_a,\nu'_a)$, where
   $P^{(n)}$ is the law of the history of length $n$, by regrouping LML's
   `IsAlgEnvSeq.klDiv_map_history` along the pulled arm.
2. **Bretagnolle–Huber.** For probability measures $P,Q$ and every measurable $A$:
   $P(A)+Q(A^c)\ge\tfrac12\exp(-D(P,Q))$ [LS, Theorem 14.2], through the stronger
   $\int\min(p,q)\ge\tfrac12\exp(-D(P,Q))$ for densities with respect to $P+Q$ [LS, (14.8)].
3. **Minimax lower bound.** Generalize [LS, Theorem 15.2] to a family $(P_x)_{x\in[b,b+h]}$ of
   reward laws with means $x$ and $D(P_x,P_y)\le(x-y)^2/(2\sigma^2)$: for $k\ge2$ and
   $n\ge\sigma^2(k-1)/h^2$, every algorithm has a mean vector $\mu\in[b,b+h]^\alpha$ with
   $\mathbb E[R_n]\ge\frac1{27}\sigma\sqrt{(k-1)n}$ on the bandit $(P_{\mu_a})_a$. Corollaries: the
   Gaussian case ($[0,1]$, variance $\sigma^2$), which is [LS, Theorem 15.2] for $\sigma=1$, and the
   Bernoulli case ($[1/4,3/4]$, $\sigma^2=3/32$, from Layer 0.2's bound on $d$).
4. **Lai–Robbins.** Define consistency of an algorithm over a class of bandits [LS, Definition 16.1]
   and, for a set $\mathcal M$ of integrable laws on $\mathbb R$,
   $d_{\inf}(P,\mu^*,\mathcal M)=\inf\{D(P,P'):P'\in\mathcal M,\ \mu(P')>\mu^*\}$ in `ℝ≥0∞`. Prove
   [LS, Theorem 16.2] for the unstructured class $\prod_a\mathcal M_a$:
   $\liminf_n\mathbb E[R_n]/\log n\ge\sum_{a:\Delta_a>0}\Delta_a/d_{\inf}(\nu_a,\mu^*,\mathcal M_a)$,
   with the sum in `ℝ≥0∞`. Compute $d_{\inf}$ for exponential families [BK96]: for a family
   $\rho$ of Layer 3 with members $\mathcal M_\rho=\{\rho_\theta:\theta\in\Theta_\rho\}$,
   $\mu\in M_\rho$ and $m\ge\mu$, $d_{\inf}(\rho_{(\mu)},m,\mathcal M_\rho)=d_\rho(\mu,m)$ if
   $m\in M_\rho$ and $\infty$ if $m\ge\sup M_\rho$. The Gaussian (known variance) and Bernoulli
   entries of [LS, Table 16.1] are instances. Prove [LS, Lemma 16.3] and the finite-time bound
   [LS, Theorem 16.4], for Gaussian bandits with variance $\sigma^2$.
5. **Asymptotic optimality and the adversarial lower bound.** For families $(\rho_a)_a$ with a
   common set of means $M$ (one family for all arms, or Gaussian families with different
   variances), prove that KL-UCB (Layer 3) is consistent over the bandits whose arm $a$ has a law in
   $\mathcal M_{\rho_a}$ and attains the Lai–Robbins constant there: its expected regret is
   $c^*\log n+o(\log n)$ with $c^*=\sum_{a:\Delta_a>0}\Delta_a/d_{\rho_a}(\mu_a,\mu^*)$. The
   algorithms of Layers 2.2 and 3 on Gaussian arms and on Bernoulli arms are instances, Bernoulli
   arms with mean $0$ or $1$ being treated directly. Prove the adversarial minimax lower bound: for
   every algorithm and $n\ge 3(k-1)/8$ there is a table $x\in\{0,1\}^{n\times\alpha}$ with
   $R_n(x)\ge\frac1{27}\sqrt{3(k-1)n/32}$, by averaging the Bernoulli case of item 3 over i.i.d.
   tables (Layer 0.5).

Generalization: the minimax bound for a family of laws rather than unit-variance Gaussians;
$d_{\inf}$ and asymptotic optimality for every exponential family rather than Gaussian and
Bernoulli arms.
Completion checks: the divergence decomposition is zero for identical environments; the Lai–Robbins
constant is $+\infty$ when some $d_{\inf}$ vanishes, and the theorem then states that the regret of
every consistent policy eventually exceeds every multiple of $\log n$.

## Layer 5: Thompson sampling

1. **Algorithm.** For families $(\rho_a)_a$ of Layer 3 with log-partition functions
   $\psi_a=$ `cgf id (ρ a)` and priors $\pi_a$, σ-finite measures on $\Theta_{\rho_a}$, define
   Thompson sampling. At each round, for each arm $a$ pulled $s\ge1$ times with reward sum $S$,
   draw independently a natural parameter $\theta_a$ from the posterior, the probability measure
   proportional to $e^{\theta S-s\psi_a(\theta)}\,\pi_a(d\theta)$, and take its mean
   $\psi_a'(\theta_a)$ as the perturbation of $a$ (the perturbation is $+\infty$ where the
   normalizing constant is $0$ or infinite, and for unpulled arms); play `argmax`. This is a
   follow-the-perturbed-leader policy whose laws depend on the history only through the number of
   pulls and the reward sum of each arm (LMLExplore's `perturbedLeaderAlgorithm`). The Jeffreys
   prior is $\pi_J(d\theta)=\sqrt{\psi''(\theta)}\,d\theta$ on $\Theta_\rho$ [KKM13, Section 2].
   Gaussian Thompson sampling with variance proxy $\sigma^2$ and flat prior (LMLExplore's
   `gaussianTS`: $\theta_a\sim\mathcal N(\hat\mu_a,\sigma^2/T_a)$) is the instance with the
   Gaussian family of variance $\sigma^2$ and its Jeffreys prior, a constant multiple of Lebesgue
   measure; define it as that instance. The book's update writes the variance $1/t$; the intended
   variance after $s$ samples of the arm is $1/s$ [LS, Theorem 36.3].
2. **Generic bound.** Prove [LS, Theorem 36.2] for the follow-the-perturbed-leader scheme of
   [LS, Algorithm 24]: with arm $a^*$ optimal, $a\ne a^*$, $\varepsilon\in\mathbb R$ and
   $G_{as}=1-F_{as}(\mu^*-\varepsilon)$,
   $\mathbb E[T_a(n)]\le1+\mathbb E\big[\sum_{s<n}(1/G_{a^*s}-1)\big]+\mathbb E\big[\sum_{s<n}\mathbb 1\{G_{as}>1/n\}\big]$.
3. **Frequentist regret.** Let one family $\rho$ serve all arms, with Jeffreys posteriors that are
   finite measures after every number $s\ge1$ of pulls, for almost every sum of $s$ independent
   draws from $\rho$. For bandits whose arm laws are members of $\rho$, prove that Thompson sampling
   with the Jeffreys prior satisfies
   $\mathbb E[R_n]/\log n\to\sum_{a:\Delta_a>0}\Delta_a/d_\rho(\mu_a,\mu^*)$ [KKM13, Theorem 1]
   (upper bound in eventual form, matched by Layer 4.4). For Gaussian bandits with variance
   $\sigma^2$ this is the asymptotic part of [LS, Theorem 36.3]; prove its minimax part
   $\mathbb E[R_n]\le C\sqrt{\sigma^2kn\log n}+\sum_a\Delta_a$ for an absolute constant $C$, through
   the steps of [LS, Exercise 36.6] and the Gaussian tails of Layer 1.6.

Generalization: exponential families and priors on the natural parameter, arbitrary variance proxy
and finite arm type, where [LS] treats Gaussian arms. LML's Bayesian Thompson sampling
(`tsAlgorithm`, `TS.integral_regret_le`) is a different algorithm (it samples from the posterior of
a prior over environments); do not restate its results. Completion example: for Bernoulli arms the
Jeffreys prior on the mean is $\mathrm{Beta}(1/2,1/2)$, with posterior
$\mathrm{Beta}(1/2+S,1/2+s-S)$ [KKM13, Figure 1].

## Layer 6: Convex analysis, online linear and convex optimization

Work in a finite-dimensional real normed space `E`, paired with its dual `E →L[ℝ] ℝ` by
`(x, y) ↦ y x`; this is the bilinear pairing that Tau Ceti's `fenchelConjugate` takes. Losses and
gradients live in the dual: the loss of a play `a` under the loss `y` is `y a`, and the regret
against `u` after `n` rounds is $\sum_{t<n}y_t(a_t-u)$. Strong convexity refers to the norm of `E`
(Mathlib's `StrongConvexOn`), and the norm of a loss is its operator norm, the dual norm. Losses
are minimized. Statements whose proofs do not use the dimension, such as the FTRL bounds of item 3,
are stated without it. The merged FTRL development of LMLExplore is restated in this generality by
the [Refactors](../../Completed/Refactors/README.md) roadmap, Layer 0.1. Learning rates follow the
Conventions; [Ora] is cited by the numbering of its tenth arXiv version.

1. **Legendre functions.** For a convex function $F$ with domain $D$ (represent it as `F : E → ℝ`
   with a convex set `D`, or as `E → EReal`; choose one representation and give conversions to
   Tau Ceti's `fenchelConjugate`), define Legendre functions [LS, §26.4]: nonempty interior of the
   domain, differentiable and strictly convex on the interior, gradient norm tending to infinity at
   the boundary. Prove [LS, Theorem 26.6] (the gradient is a bijection between interiors with
   inverse $\nabla F^*$, $D_F(x,y)=D_{F^*}(\nabla F(y),\nabla F(x))$, and $F^*$ is Legendre),
   [LS, Corollary 26.8] and [LS, Proposition 26.14].
2. **Bregman divergence and projections.** On LML's `bregDiv`, prove [LS, Theorem 26.3], the Bregman
   projection theorem [LS, Theorem 26.15], the generalized Pythagorean inequality
   $D_F(x,y)\ge D_F(x,z)+D_F(z,y)$ for $z=\Pi_{A,F}(y)$ and $x\in A$ [LS, Exercise 26.13], and the
   Hessian forms [LS, Theorems 26.12 and 26.13].
3. **FTRL and mirror descent.** Define follow-the-regularized-leader and mirror descent on a convex
   set $\mathcal A\subseteq E$ with potential $F$ and learning rate $\eta$ [LS, (28.1)–(28.3)] for
   arbitrary loss sequences, including the two-step form of mirror descent [LS, (28.7)–(28.9)].
   Prove [LS, Theorem 28.4] (both bounds and (28.11)), [LS, Theorem 28.5] for convex $F$ with
   directional derivatives, and [LS, Corollary 28.8]. The bounds hold for losses chosen adaptively
   from past actions. Then let the regularizer change over the rounds:
   - *Time-varying regularizers.* For regularizers $\psi_t$ nondecreasing in $t$ on $\mathcal A$,
     plays $a_t\in\mathcal A$ minimizing $\sum_{s<t}y_s+\psi_t$ over $\mathcal A$, and derivatives
     $\psi'_t$ of $\psi_t$ within $\mathcal A$ at $a_t$, prove
     $\sum_{t<n}y_t(a_t-u)\le\psi_n(u)-\psi_0(a_0)+\sum_{t<n}\big(y_t(a_t-a_{t+1})-D_{\psi_t}(a_{t+1},a_t)\big)$
     for $u\in\mathcal A$, from LMLExplore's FTRL lemma `sum_apply_sub_le_ftrl` [Ora, Lemma 7.1].
     For $\psi_t=F/\eta_t$ with $F\ge0$ on $\mathcal A$ and nonincreasing $\eta_t>0$ this is the
     anytime form of [LS, Theorem 28.5]; for $F$ $m$-strongly convex deduce
     $\sum_{t<n}y_t(a_t-u)\le F(u)/\eta_{n-1}+\sum_{t<n}\eta_t\|y_t\|^2/(2m)$ [Ora, Corollary 7.6].
   - *Mirror descent with nonincreasing learning rates.* For $F$ $m$-strongly convex and
     $D_F(u,a_t)\le D$ for $t<n$, prove
     $\sum_{t<n}y_t(a_t-u)\le D/\eta_{n-1}+\sum_{t<n}\eta_t\|y_t\|^2/(2m)$ [Ora, Theorem 6.11].
   - *Local norms* [LS, Theorem 26.13; Ora, Lemma 7.15]. Bound each stability term
     $y_t(a_t-a_{t+1})-D_F(a_{t+1},a_t)/\eta_t$ through the Hessian of $F$ (item 2, LMLExplore's
     `ConvexOn.exists_mem_segment_apply_sub_sub_bregDiv_div_le`): it is at most $\eta_tc_t/2$ for
     every $c_t\ge0$ with $y_t(v)^2\le c_t\,\nabla^2F(z_t)(v,v)$ for all $v$, at some
     $z_t\in[a_t,a_{t+1}]$. Deduce the FTRL and mirror descent bounds with these local norms in
     place of $\|y_t\|^2$, which is unbounded for importance-weighted estimates.
4. **Instances.** Prove [LS, Proposition 28.6] (unit ball, $F=\tfrac12\|a\|^2$,
   $\eta=n^{-1/2}$: $R_n\le\sqrt n$) on a real inner product space, with the losses
   `InnerProductSpace.toDual ℝ E g` of vectors of norm at most `1`. Prove [LS, Proposition 28.7]
   (simplex, unnormalized negative entropy, $\eta=\sqrt{2\log(d)/n}$: $R_n\le\sqrt{2n\log d}$)
   on `E = PiLp 1 (fun _ : α ↦ ℝ)`, whose dual norm is the sup norm, from the `1`-strong convexity
   of the negative entropy on the simplex for the `ℓ¹` norm (Pinsker's inequality). Identify the
   latter with exponential weights over a finite set, stated on `α → ℝ` with LMLExplore's
   `simplex α`. For nonnegative losses and nonincreasing learning rates, prove the local-norm bound
   of exponential weights $p_t=\mathrm{softmax}(-\eta_t\sum_{s<t}y_s)$ [Ora, Section 7.5;
   BCB12, proof of Theorem 3.1]: for $p\in$ `simplex α`, $y\ge0$ and $\eta\ge0$,
   $\sum_ap_a(e^{-\eta y_a}-1+\eta y_a)\le\frac{\eta^2}2\sum_ap_ay_a^2$; the stability term of FTRL
   with the negative entropy at $p$ and a nonnegative loss $y$,
   $\sup_{q}\big(\langle p-q,y\rangle-\mathrm{KL}(q,p)/\eta\big)=\langle p,y\rangle+\frac1\eta\log\sum_ap_ae^{-\eta y_a}$
   over `simplex α`, is at most $\frac1\eta\sum_ap_a(e^{-\eta y_a}-1+\eta y_a)$; hence, by item 3,
   $\sum_{t<n}(\langle p_t,y_t\rangle-y_t(a))\le\frac{\log k}{\eta_{n-1}}+\sum_{t<n}\frac{\eta_t}2\langle p_t,y_t^2\rangle$.
   LMLExplore's `softmax_regret_le` is its constant case.
5. **Estimated losses.** Prove [LS, Theorem 28.10] for losses chosen by an adaptive adversary.
   Given, for each round $t$, a σ-algebra $\mathcal G_t$ for which the play $a_t$ and the loss
   $y_t$ are measurable, an action $A_t$ with conditional mean $a_t$ given $\mathcal G_t$, and an
   estimate $\hat Y_t$ with conditional mean $y_t$ given $\mathcal G_t$:
   $\mathbb E\big[\sum_{t<n}y_t(A_t-u)\big]=\mathbb E\big[\sum_{t<n}\hat Y_t(a_t-u)\big]$ for
   $u\in E$, so that pathwise bounds of items 3–4 on the estimated losses bound the expected
   regret. Deterministic losses (LMLExplore's `IsUnbiasedRound`) are the oblivious case.
6. **Online convex optimization.** For convex losses $f_t:E\to\mathbb R$ and plays
   $a_t\in\mathcal A$ with a subgradient $g_t$ of $f_t$ within $\mathcal A$ at $a_t$ (LML's
   `HasSubgradientWithinAt`), $\sum_{t<n}(f_t(a_t)-f_t(u))\le\sum_{t<n}g_t(a_t-u)$ for
   $u\in\mathcal A$, so FTRL and mirror descent run on the linearized losses $g_t$, which are chosen
   from the past plays, inherit the bounds of items 3–4 [Ora, Section 2.3]. Prove the Euclidean
   instance, projected online subgradient descent [Zin03; Ora, Section 2.2]: on a convex set of
   diameter $D$ in a real inner product space, with $\|g_t\|\le G$ and $\eta_t=D/(G\sqrt{t+1})$,
   the regret is at most $\frac32DG\sqrt n$.

Generalization: a normed space with losses in its dual, time-varying regularizers, adaptively chosen
losses and convex losses through their subgradients, rather than $\mathbb R^d$ with the Euclidean
pairing, a fixed learning rate and linear losses; the instances are corollaries.

## Layer 7: Adversarial bandits with finitely many arms and expert advice

Runs against an environment `env : Environment 𝓞 α ℝ` whose feedback laws are supported in
$[0,1]$: an adaptive adversary (Conventions), which includes oblivious tables `onlineEvalEnv x _`
with $x_t(a)\in[0,1]$ and stochastic bandits `stationaryEnv ν` with rewards in $[0,1]$.
Expectation bounds are on the pseudo-regret $\bar R_n$, high-probability bounds on the random
regret $\hat R_n$ (Layer 0.5). Learning rates $\eta_t>0$ and implicit-exploration parameters
$\gamma_t\ge0$ are nonincreasing sequences (Conventions).

1. **Importance-weighted estimators.** For a weight-based policy (Layer 0.3) with weights $P_t$,
   define the standard and loss-based estimators [LS, (11.3), (11.6)] and the implicit-exploration
   estimator $\hat Y_t(a)=\mathbb 1\{A_t=a\}(1-Y_t)/(P_t(a)+\gamma_t)$ [LS, (12.4); Neu15, (3)].
   Conditionally on the history before round $t$ and the observation of round $t$ (LML's
   `IsAlgEnvSeq.filtrationObs`), prove unbiasedness for $\gamma_t=0$ and positive weights,
   $\mathbb E[\hat Y_t(a)\mid\cdot]=1-m_t(a)$, the bias bound
   $\mathbb E[\hat Y_t(a)\mid\cdot]\le1-m_t(a)$ for $\gamma_t\ge0$, and the conditional variance
   formulas [LS, (11.4), (11.5)].
2. **Exp4-IX.** For a finite set of $M$ experts and a measurable advice map from observations to
   advice $E_t\in\Delta(\alpha)^M$, define Exp4-IX [Neu15, Section 3.2] with learning rates $\eta_t$
   and implicit exploration $\gamma_t$: expert weights
   $Q_t=\mathrm{softmax}\big(-\eta_t\sum_{s<t}E_s\hat Y_s\big)$, where
   $(E_s\hat Y_s)(m)=\langle E_s(m),\hat Y_s\rangle$, the arm drawn from
   $P_t=\sum_mQ_t(m)E_t(m)$, and the estimates $\hat Y_t$ of item 1. Define Exp4
   [LS, Algorithm 11] as the case $\gamma=0$, and Exp3-IX [LS, Algorithm 10] and Exp3
   [LS, Algorithm 9] as the cases with the experts $\alpha$, expert $b$ advising $\delta_b$ at every
   observation, with arbitrary $\gamma$ and with $\gamma=0$ respectively; LMLExplore's `exp4`,
   `exp3IX` and `exp3` become these instances. Prove that the expert weights $Q_t$ are the
   exponential weights of Layer 6.4 on the estimated expert losses $E_s\hat Y_s$, so that its
   local-norm bound holds pathwise ([LS, Lemma 18.2] for a constant rate).
3. **Pseudo-regret.** For $\gamma=0$, prove
   $\bar R^E_n\le\frac{\log M}{\eta_{n-1}}+\frac k2\sum_{t<n}\eta_t$ for Exp4, from item 2, item 1
   and Layer 6.5, and the same bound with $M=k$ for $\bar R_n$ of Exp3. Deduce [LS, Theorem 18.1]
   ($\eta=\sqrt{2\log(M)/(nk)}$: $\bar R^E_n\le\sqrt{2nk\log M}$), [LS, Theorem 11.2]
   ($\eta=\sqrt{2\log(k)/(nk)}$: $\bar R_n\le\sqrt{2nk\log k}$) and [BCB12, Theorem 3.1]
   ($\eta_t=\sqrt{\log(k)/(k(t+1))}$: $\bar R_n\le2\sqrt{nk\log k}$).
4. **High-probability bounds.** Prove [LS, Lemmas 12.2–12.4] and both bounds of
   [LS, Theorem 12.1] for Exp3-IX. Prove the concentration of the implicit-exploration estimates
   [Neu15, Lemma 1]: for nonnegative weights $\alpha_{t,a}\le2\gamma_t$ measurable for the history
   before round $t$ and the observation of round $t$, with probability at least $1-\delta$,
   $\sum_{t<n}\sum_a\alpha_{t,a}\big(\hat Y_t(a)-(1-m_t(a))\big)\le\log(1/\delta)$. Deduce
   [Neu15, Theorem 1] for anytime rates: with $\eta_t=2\gamma_t=\sqrt{\log(k)/(k(t+1))}$, Exp3-IX
   has $\hat R_n\le4\sqrt{nk\log k}+\big(2\sqrt{nk/\log k}+1\big)\log(2/\delta)$ with probability at
   least $1-\delta$; and [Neu15, Theorem 2] for Exp4-IX: with
   $\eta_t=2\gamma_t=\sqrt{2\log(M)/(nk)}$,
   $\hat R^E_n\le2\sqrt{2nk\log M}+\big(\sqrt{2nk/\log M}+1\big)\log(2/\delta)$ with probability at
   least $1-\delta$.

Generalization: adaptive adversaries, expert advice that depends on the history, anytime learning
rates and a single algorithm for Exp3, Exp3-IX and Exp4, where [LS] fixes an oblivious table, a
known horizon and three algorithms. Completion checks: for $k=1$ every bound is $0$; the lower bound
of Layer 4.5 shows the order $\sqrt{nk}$ of item 3 is attained up to $\sqrt{\log k}$; with a single
expert the expert pseudo-regret of Exp4 is nonpositive; against `stationaryEnv ν` with rewards in
$[0,1]$, item 3 bounds the expected stochastic regret of Exp3 with anytime rates by
$2\sqrt{nk\log k}$.

## Layer 8: Least squares, self-normalized bounds and optimal design

Work in a finite-dimensional real inner product space `E` of dimension $d$, with linear operators
`E →L[ℝ] E`; give matrix corollaries on `EuclideanSpace ℝ ι`. Weighted norms use the inverse
$V^{-1}$ (`Ring.inverse`) of operators that are invertible ($\lambda>0$, positive definite $V_0$)
and the Moore–Penrose inverse $V^+$ (Tau Ceti's `LinearMap.moorePenroseInverse`) of operators that
may be singular (unregularized least squares, designs).

1. **Design operators.** For a positive operator $V_0$ and $x_0,x_1,\ldots\in E$, define
   $V_t(V_0)=V_0+\sum_{s<t}x_s\otimes x_s$ (with $x\otimes x$ the operator
   $v\mapsto\langle x,v\rangle x$, Tau Ceti's `frameOperator` for finite families), and
   $V_t(\lambda)=V_t(\lambda\,\mathrm{id})$ for $\lambda\ge0$ (LMLExplore's `designOp`). Define
   the weighted norms $\|v\|^2_{V^{-1}}=\langle v,V^{-1}v\rangle$ and
   $\|v\|^2_{V^+}=\langle v,V^+v\rangle$. Prove $V^+=V^{-1}$ for invertible $V$, and, for positive
   $V$, that $V^+$ is positive and $VV^+$ is the orthogonal projection onto the range of $V$ (for
   $V_t(0)$, the span of $x_0,\dots,x_{t-1}$). Prove positivity, invertibility for positive
   definite $V_0$ (in particular $\lambda>0$), the rank-one update of the inverse
   (Sherman–Morrison) and of the determinant
   $\det V_{t+1}=\det V_t\,(1+\|x_t\|^2_{V_t^{-1}})$ [LS, (19.9)], and
   $\det V\le(\operatorname{trace}V/d)^d$ for positive $V$.
2. **Elliptical potential.** Prove [LS, Lemma 19.4]: for positive definite $V_0$ and $\|x_t\|\le L$,
   $\sum_{t<n}\min\{1,\|x_t\|^2_{V_t^{-1}}\}\le2\log\frac{\det V_n}{\det V_0}\le
   2d\log\frac{\operatorname{trace}V_0+nL^2}{d\det(V_0)^{1/d}}$.
3. **Least squares.** For $\lambda\ge0$, define the estimator
   $\hat\theta_t=V_t(\lambda)^+\sum_{s<t}x_sY_s$ and prove that it minimizes the regularized squared
   loss [LS, (19.4)–(19.6)], and for $\lambda=0$ that it is the least-squares solution of minimal
   norm. For $\lambda>0$ it is the ridge estimator $V_t(\lambda)^{-1}\sum_{s<t}x_sY_s$
   (LMLExplore's `ridgeEstimate`).
4. **Self-normalized bound.** On a filtered probability space, for an $E$-valued predictable
   sequence $x_t$ and real noise $\eta_t$ that is conditionally σ²-sub-Gaussian given the past and
   $x_t$, with $S_t=\sum_{s<t}\eta_sx_s$: prove that $\exp(\langle v,S_t\rangle-\frac{\sigma^2}2\|v\|^2_{V_t(0)})$
   is a supermartingale [LS, Lemma 20.2], its mixtures over probability measures are
   supermartingales [LS, Lemma 20.3], and, for every positive definite $V_0$ [AYPS11, Theorem 1],
   $P\big(\exists t,\ \|S_t\|^2_{V_t(V_0)^{-1}}\ge2\sigma^2\log\frac1\delta+\sigma^2\log\frac{\det V_t(V_0)}{\det V_0}\big)\le\delta$,
   by the Gaussian mixture of covariance $V_0^{-1}$ and Ville's inequality. [LS, Theorem 20.4]
   with σ² is the case $V_0=\lambda\,\mathrm{id}$, $\det V_0=\lambda^d$.
5. **Confidence sets.** For $Y_t=\langle\theta_*,x_t\rangle+\eta_t$, prove [LS, Theorem 20.5] with
   σ² and the bound $\det V_t(\lambda)/\lambda^d\le(1+nL^2/(\lambda d))^d$ [LS, (20.9)]. For a
   fixed design $x_0,\dots,x_{t-1}$, whose operator $V=V_t(0)$ may be singular, independent
   σ²-sub-Gaussian noise and the estimator $\hat\theta=V^+\sum_{s<t}x_sY_s$ of item 3, prove [LS, (20.2)]:
   $P\big(\langle x,\hat\theta-\theta_*\rangle\ge\sqrt{2\sigma^2\|x\|^2_{V^+}\log(1/\delta)}\big)\le\delta$
   for every $x$ in the span of the design.
6. **Kiefer–Wolfowitz.** A design on a set $\mathcal A\subseteq E$ is a finitely supported
   probability measure $\pi$ on $E$ with support in $\mathcal A$, an element of Mathlib's
   `Convexity.StdSimplex ℝ E`; finite support is what compact infinite sets need
   [LS, Exercise 21.3]. Define $V(\pi)=\sum_a\pi(a)\,a\otimes a$ and
   $g(\pi)=\sup_{a\in\mathcal A}\|a\|^2_{V(\pi)^+}$. For compact $\mathcal A$ spanning $E$, prove
   [LS, Theorem 21.1] (minimizing $g$, maximizing $\log\det V$, and $g=d$ are equivalent, and a
   minimizer with support of size at most $d(d+1)/2$ exists) for compact sets, not only finite ones
   [LS, Exercise 21.3]; and the non-spanning version: if $\dim\operatorname{span}\mathcal A=m\ge1$,
   there is a design with support at most $m(m+1)/2$ and $g(\pi)=m$ [LS, Exercise 21.6]. Prove
   $\|a\|^2_{V(\pi^*)^{-1}}=d$ on the support [LS, Exercise 21.5]. For designs on finitely many
   arms with a feature map $\varphi:\alpha\to E$, prove LMLExplore's
   `simplex α = Set.range (fun q : StdSimplex ℝ α ↦ ⇑q.weights)` (from Mathlib's
   `StdSimplex.range_toFun_comp_weights`) and
   $V(\varphi_*w)=\sum_aw_a\,\varphi(a)\otimes\varphi(a)$ for the image design
   $\varphi_*w=$ `StdSimplex.map φ w`, so that allocations $w\in$ `simplex α` (Layer 10.1, the
   Identification roadmap's Layer 9) are designs.

Generalization: operators on an inner product space, any positive definite regularizer $V_0$,
singular designs through the Moore–Penrose inverse, and σ²-sub-Gaussian noise. Completion examples:
for the standard basis of $\mathbb R^d$ the uniform design is G-optimal with $g=d$; for the unit
sphere the uniform distribution on an orthonormal basis is G-optimal; for $\lambda=0$ and data
spanning a proper subspace, $\hat\theta_t$ lies in that subspace and $\|x\|^2_{V_t(0)^+}>0$ for
every nonzero $x$ in it.

## Layer 9: Stochastic linear bandits

1. **Environments.** With observations `𝓞` (contexts), actions `𝓐`, a measurable feature map
   $\varphi:\mathcal O\times\mathcal A\to E$ and a parameter $\theta_*\in E$, define the predicate
   that an environment is linear with conditionally σ²-sub-Gaussian noise: at every round, whatever
   the history, observation and action, the feedback law centered at
   $\langle\theta_*,\varphi(o,a)\rangle$ is σ²-sub-Gaussian. This covers finitely many arms
   ($\varphi$ one-hot), fixed action sets, and changing decision sets $\mathcal A_t=\varphi(O_t,\cdot)$
   [LS, §19.2]. Define the random regret
   $\hat R_n=\sum_{t<n}\big(\sup_a\langle\theta_*,\varphi(O_t,a)\rangle-\langle\theta_*,\varphi(O_t,A_t)\rangle\big)$
   and its expectation, and construct a Gaussian linear environment as an instance.
2. **OFUL.** Define the optimistic algorithm with confidence ellipsoids of Layer 8.5
   [LS, (19.13)], with a measurable maximizer of the optimistic index given as a parameter when the
   action set is infinite. Prove [LS, Theorem 19.2] under [LS, Assumption 19.1] with σ², and the
   expected bound for $\delta=1/n$ with explicit constants:
   $\mathbb E[R_n]\le1+\sqrt{8dn\beta_n\log\big(1+\frac{nL^2}{d\lambda}\big)}$ with $\beta_n$ given by
   [LS, (19.8)] (the explicit form of [LS, Corollary 19.3]).
3. **Phased elimination.** For a finite action set $\mathcal A\subseteq E$ and gaps at most $1$,
   define phased elimination with G-optimal designs [LS, Algorithm 12] and prove [LS, Theorem 22.1]
   via [LS, Exercise 22.1], with an explicit constant. Do not assume that the surviving sets span
   $E$: use the non-spanning design of Layer 8.6 on their span, and the least-squares estimator of
   Layer 8.3 with $\lambda=0$ and its fixed-design bound (Layer 8.5).
4. **Lower bounds.** With Gaussian noise, prove [LS, Theorem 24.1] (hypercube
   $[-1,1]^d$: some $\theta\in\{\pm n^{-1/2}\}^d$ gives $R_n\ge\frac{e^{-2}}8d\sqrt n$) and
   [LS, Theorem 24.2] (unit ball, $d\le2n$: some $\theta$ with $\|\theta\|^2=d^2/(48n)$ gives
   $R_n\ge d\sqrt n/(16\sqrt3)$), using Layer 4.2 and LML's divergence decomposition for general
   action spaces.

Generalization: contextual feature maps, σ²-sub-Gaussian noise, inner product spaces. Completion
check: with one-hot features, item 1 recovers stochastic bandits with finitely many arms and the
OFUL bound applies to them.

## Layer 10: Adversarial linear bandits

Losses $y_t\in E$ are chosen by an adaptive adversary: $y_t$ is a measurable function of the
history before round $t$ and of the observation of round $t$, and the learner observes
$\langle A_t,y_t\rangle$; oblivious losses are the deterministic case. The regret is the
pseudo-regret $R_n=\max_{u\in\mathcal A}\mathbb E\big[\sum_{t<n}\langle A_t-u,y_t\rangle\big]$.

1. **Exp3 with exploration.** For a finite spanning action set, given by a feature map on a finite
   type of arms, with $\sup_a|\langle a,y_t\rangle|\le1$, define [LS, Algorithm 15] and prove
   [LS, Theorem 27.1]: $R_n\le2\sqrt{(2g(\pi)+d)\,n\log k}$ for every exploration design $\pi$,
   hence $R_n\le2\sqrt{3dn\log k}$ with the Kiefer–Wolfowitz design of Layer 8.6.
2. **Mirror descent with bandit feedback.** Deduce [LS, Theorem 28.10] for the scheme of
   [LS, Algorithm 16] with unbiased estimates from Layer 6.5, and prove [LS, Theorem 28.11] for the
   unit ball: with $\|y_t\|\le1$, $r=1-2\eta d$ and $\eta=\sqrt{\log(n)/(3dn)}$,
   $R_n\le2\sqrt{3nd\log n}$.
   The exploration direction $U_t$ is uniform on $\{\pm e_1,\dots,\pm e_d\}$ for an orthonormal
   basis $(e_i)$ of $E$ (the box of [LS, Algorithm 17] omits the signs).

## Completion checks

Every new definition comes with measurability, evaluation and extensionality lemmas, and every
algorithm with its run lemma (the conditional law of its action given the history), so that the
regret theorems apply to all runs. Check in particular:

* Index policies pull every arm once before comparing finite indices; the asymptotic constants of
  Layers 3 and 5 coincide with the Lai–Robbins constants of Layer 4.4 for every exponential
  family, in particular for Gaussian and Bernoulli arms, where `ucbF` and `klucb` are the instances
  of KL-UCB.
* The minimax lower bounds of Layers 4.3, 4.5 and 9.4 match the upper bounds of Layers 2.3, 7.3 and
  9.2 up to the logarithmic and constant factors stated.
* Exp3, Exp3-IX and Exp4 are instances of Exp4-IX (Layer 7.2), whose expert weights are the
  exponential weights of Layer 6.4; their bounds hold against oblivious tables, adaptive
  adversaries and stochastic bandits alike.
* The constant-rate FTRL and mirror descent bounds of Layer 6.3 are the constant cases of the
  time-varying ones.
* The Kiefer–Wolfowitz theorem applies to the finite action sets of Layers 9.3 and 10.1, including
  sets that do not span $E$.

Compilation of the suggested signatures checks their types, not the truth of their admitted
theorems or the completion of these milestones.

## References

T. Lattimore and Cs. Szepesvári, [*Bandit Algorithms*][ls], Cambridge University Press (2020),
Chapters 4–22, 24, 26–28 and 36, is the main source; the layers cite its numbered results.

Original sources: P. Auer, N. Cesa-Bianchi, Y. Freund and R. Schapire, *The nonstochastic
multiarmed bandit problem* (SIAM J. Comput., 2002) for Exp3 and Exp4; J.-Y. Audibert and S. Bubeck,
*Minimax policies for adversarial and stochastic bandits* (COLT 2009) for MOSS;
T. L. Lai and H. Robbins, *Asymptotically efficient adaptive allocation rules* (Adv. Appl. Math.,
1985) for Layer 4.4; J. Kiefer and J. Wolfowitz, *The equivalence of two extremum problems*
(Canad. J. Math., 1960). The layers cite by key:

- [AYPS11] Y. Abbasi-Yadkori, D. Pál and Cs. Szepesvári, *Improved algorithms for linear stochastic
  bandits*, NeurIPS 2011 (Layers 8.4–9.2).
- [BCB12] S. Bubeck and N. Cesa-Bianchi, *Regret analysis of stochastic and nonstochastic
  multi-armed bandit problems*, Foundations and Trends in Machine Learning 5(1), 2012.
- [BK96] A. N. Burnetas and M. N. Katehakis, *Optimal adaptive policies for sequential allocation
  problems*, Adv. Appl. Math. 17 (1996).
- [CGMMS13] O. Cappé, A. Garivier, O.-A. Maillard, R. Munos and G. Stoltz, *Kullback–Leibler upper
  confidence bounds for optimal sequential allocation*, Ann. Statist. 41(3), 2013.
- [GC11] A. Garivier and O. Cappé, *The KL-UCB algorithm for bounded stochastic bandits and
  beyond*, COLT 2011.
- [KKM13] N. Korda, E. Kaufmann and R. Munos, *Thompson sampling for 1-dimensional exponential
  family bandits*, NeurIPS 2013.
- [Neu15] G. Neu, *Explore no more: improved high-probability regret bounds for non-stochastic
  bandits*, NeurIPS 2015.
- [Ora] F. Orabona, *Online learning: a modern introduction using convex optimization*,
  arXiv:1912.13213v10, 2026 (earlier versions are titled *A modern introduction to online
  learning*).
- [Zin03] M. Zinkevich, *Online convex programming and generalized infinitesimal gradient ascent*,
  ICML 2003.

[ls]: https://tor-lattimore.com/downloads/book/book.pdf
[kw]: https://github.com/RemyDegenne/colt-2026-83/blob/3f6c0f296a3b7e4aa8fe333225505f5b2f61f9e0/Maiti2026Power/MXJ2026/OptimalDesign.lean
[lml-alg]: https://github.com/LeanMachineLearning/LML/blob/53be244591a865c51ea10fa09403189ee060f116/LeanMachineLearning/SequentialLearning/Algorithm.lean
[lml-it]: https://github.com/LeanMachineLearning/LML/blob/53be244591a865c51ea10fa09403189ee060f116/LeanMachineLearning/SequentialLearning/IonescuTulceaSpace.lean
[lml-env]: https://github.com/LeanMachineLearning/LML/blob/53be244591a865c51ea10fa09403189ee060f116/LeanMachineLearning/SequentialLearning/StationaryEnv.lean
[lml-eval]: https://github.com/LeanMachineLearning/LML/blob/53be244591a865c51ea10fa09403189ee060f116/LeanMachineLearning/SequentialLearning/EvaluationEnv.lean
[lml-det]: https://github.com/LeanMachineLearning/LML/blob/53be244591a865c51ea10fa09403189ee060f116/LeanMachineLearning/SequentialLearning/Deterministic.lean
[lml-argmax]: https://github.com/LeanMachineLearning/LML/blob/53be244591a865c51ea10fa09403189ee060f116/LeanMachineLearning/ForMathlib/MeasureTheory/Order/MeasurableArg.lean
[lml-fa]: https://github.com/LeanMachineLearning/LML/blob/53be244591a865c51ea10fa09403189ee060f116/LeanMachineLearning/SequentialLearning/FiniteActions.lean
[lml-sum]: https://github.com/LeanMachineLearning/LML/blob/53be244591a865c51ea10fa09403189ee060f116/LeanMachineLearning/SequentialLearning/SumRewards.lean
[lml-conc]: https://github.com/LeanMachineLearning/LML/blob/53be244591a865c51ea10fa09403189ee060f116/LeanMachineLearning/Online/Bandit/SumRewards.lean
[lml-regret]: https://github.com/LeanMachineLearning/LML/blob/53be244591a865c51ea10fa09403189ee060f116/LeanMachineLearning/Online/Bandit/Regret.lean
[lml-ucb]: https://github.com/LeanMachineLearning/LML/blob/53be244591a865c51ea10fa09403189ee060f116/LeanMachineLearning/Online/Bandit/Algorithms/Regret/UCB.lean
[lml-etc]: https://github.com/LeanMachineLearning/LML/blob/53be244591a865c51ea10fa09403189ee060f116/LeanMachineLearning/Online/Bandit/Algorithms/Regret/ETC.lean
[lml-ts]: https://github.com/LeanMachineLearning/LML/blob/53be244591a865c51ea10fa09403189ee060f116/LeanMachineLearning/Online/Bandit/Algorithms/Regret/BayesRegretTS.lean
[lml-div]: https://github.com/LeanMachineLearning/LML/blob/53be244591a865c51ea10fa09403189ee060f116/LeanMachineLearning/SequentialLearning/DivergenceDecomposition.lean
[lml-means]: https://github.com/LeanMachineLearning/LML/blob/53be244591a865c51ea10fa09403189ee060f116/LeanMachineLearning/SequentialLearning/Means.lean
[lml-chain]: https://github.com/LeanMachineLearning/LML/blob/53be244591a865c51ea10fa09403189ee060f116/LeanMachineLearning/ForMathlib/InformationTheory/KullbackLeibler/ChainRule.lean
[lml-breg]: https://github.com/LeanMachineLearning/LML/blob/53be244591a865c51ea10fa09403189ee060f116/LeanMachineLearning/ForMathlib/Analysis/Convex/Bregman/Basic.lean
[lml-subgrad]: https://github.com/LeanMachineLearning/LML/tree/53be244591a865c51ea10fa09403189ee060f116/LeanMachineLearning/ForMathlib/Analysis/Convex/Subgradient
[ml-subg]: https://github.com/leanprover-community/mathlib4/blob/2e318faecff7d70d4e0cf8cc875104424a737355/Mathlib/Probability/Moments/SubGaussian.lean
[ml-os]: https://github.com/leanprover-community/mathlib4/blob/2e318faecff7d70d4e0cf8cc875104424a737355/Mathlib/Probability/Martingale/OptionalStopping.lean
[tc-pinsker]: https://github.com/TauCetiProject/TauCeti/blob/cebc9b6046b14d2bd8d1c1088707109cdbac3a77/TauCeti/InformationTheory/KullbackLeibler/Pinsker.lean
[tc-dv]: https://github.com/TauCetiProject/TauCeti/blob/cebc9b6046b14d2bd8d1c1088707109cdbac3a77/TauCeti/InformationTheory/KullbackLeibler/Variational.lean
[tc-gauss]: https://github.com/TauCetiProject/TauCeti/blob/cebc9b6046b14d2bd8d1c1088707109cdbac3a77/TauCeti/Probability/Distributions/Gaussian/Cdf.lean
[tc-conj]: https://github.com/TauCetiProject/TauCeti/blob/cebc9b6046b14d2bd8d1c1088707109cdbac3a77/TauCeti/Analysis/Convex/Conjugate.lean
[tc-strong]: https://github.com/TauCetiProject/TauCeti/blob/cebc9b6046b14d2bd8d1c1088707109cdbac3a77/TauCeti/Analysis/Convex/Strong.lean
[tc-frame]: https://github.com/TauCetiProject/TauCeti/blob/cebc9b6046b14d2bd8d1c1088707109cdbac3a77/TauCeti/Analysis/InnerProductSpace/Frame.lean
[tc-affine]: https://github.com/TauCetiProject/TauCeti/blob/cebc9b6046b14d2bd8d1c1088707109cdbac3a77/TauCeti/Analysis/Convex/AffineNormalization.lean
[tc-mp]: https://github.com/TauCetiProject/TauCeti/blob/cebc9b6046b14d2bd8d1c1088707109cdbac3a77/TauCeti/Analysis/InnerProductSpace/MoorePenrose.lean
