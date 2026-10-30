# Roadmap: Bandit algorithms and their regret

Develop the regret theory of multi-armed and linear bandits: stochastic bandits with finitely
many arms, their minimax and instance-dependent lower bounds, adversarial bandits with finitely
many arms and with expert advice, online linear optimization, and stochastic and adversarial
linear bandits. The headline results are the regret bounds of MOSS, asymptotically optimal UCB,
KL-UCB, Thompson sampling, Exp3, Exp3-IX, Exp4, OFUL, phased elimination with G-optimal designs,
and mirror descent with bandit feedback, matched by the minimax lower bounds and the Lai–Robbins
lower bound.

Build the surrounding library at the generality the proofs support: index policies and
weight-based randomized policies, Ville's inequality and time-uniform concentration, the binary
relative entropy, the Bretagnolle–Huber inequality, Legendre functions and Bregman projections,
follow-the-regularized-leader and mirror descent, regularized least squares with self-normalized
confidence sets, the elliptical potential lemma, and the Kiefer–Wolfowitz theorem.

`README.md` is the definitive specification; `Suggested.lean` records selected interfaces and is
not an exhaustive checklist.

Suggested homes: `LMLExplore/Bandits/` for bandit material, `LMLExplore/OnlineLearning/` for
online linear optimization, and the mathematical home of each general tool (for example
`LMLExplore/Probability/Martingale/` for Ville's inequality, `LMLExplore/InformationTheory/` for
the binary relative entropy and Bretagnolle–Huber, `LMLExplore/Analysis/Convex/` for Legendre
functions, `LMLExplore/Analysis/InnerProductSpace/` for design operators and the Kiefer–Wolfowitz
theorem).

## Scope and dependencies

This roadmap owns regret minimization for: stochastic bandits with a finite set of arms;
adversarial bandits with a finite set of arms against an oblivious reward table, including bandits
with expert advice; online linear optimization with full information; stochastic linear bandits
with possibly changing decision sets; and adversarial linear bandits with finite action sets or the
Euclidean unit ball.

| Material | Owner and interface consumed here |
| --- | --- |
| Interaction protocol, runs, trajectory measure, stochastic and oblivious environments | LML `SequentialLearning/`: `Algorithm`, `Environment`, `IsAlgEnvSeq`, `trajMeasure`, `stationaryEnv`, `obliviousEnv`, `onlineEvalEnv`, `detAlgorithm` |
| Pull counts, reward sums, empirical means, the per-arm reward stream model | LML `SequentialLearning/FiniteActions.lean`, `SumRewards.lean`, `Online/Bandit/ArrayProbSpace.lean`, `Online/Bandit/RewardByCountMeasure.lean` |
| Stochastic regret, gaps, regret decomposition; regret of explore-then-commit, UCB and Bayesian Thompson sampling | LML `Online/Bandit/Regret.lean` and `Online/Bandit/Algorithms/` |
| KL divergence of interaction histories (time-sum form) | LML `SequentialLearning/DivergenceDecomposition.lean` |
| KL divergence, chain rule, data processing, Pinsker, Donsker–Varadhan | Mathlib `InformationTheory/KullbackLeibler/`, LML `ForMathlib/InformationTheory/KullbackLeibler/`, Tau Ceti `InformationTheory/KullbackLeibler/` |
| Sub-Gaussian random variables, Hoeffding and Azuma–Hoeffding, Doob's maximal inequality | Mathlib `Probability/Moments/SubGaussian.lean`, `Probability/Martingale/` |
| Bregman divergence and subgradients | LML `ForMathlib/Analysis/Convex/Bregman/`, `ForMathlib/Analysis/Convex/Subgradient/` |
| Fenchel conjugate, strong convexity first-order bound | Tau Ceti `Analysis/Convex/Conjugate.lean`, `Analysis/Convex/Strong.lean` |
| Positive operators, Loewner order, matrix determinant lemma, Woodbury identity | Mathlib `Analysis/InnerProductSpace/Positive.lean`, `LinearAlgebra/Matrix/SchurComplement.lean`, `LinearAlgebra/Matrix/NonsingularInverse.lean` |

Build missing material in this roadmap where it is listed as a target, and consume existing
implementations directly.

Outside this roadmap: pure exploration and best-arm identification (LML's `IdentAlg` framework),
sparse linear bandits, combinatorial and semi-bandits, non-stationary bandits, ranking, partial
monitoring, Markov decision processes, Bayesian-optimal policies and Gittins indices, Bayesian regret
beyond what LML proves, high-probability lower bounds, asymptotic lower bounds for linear bandits,
and online convex optimization with nonlinear losses. Scalar Bernstein, McDiarmid and matrix
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
Online linear optimization and adversarial linear bandits use losses and minimization, as [LS,
Chapters 26–28] and convex analysis do. Where the analysis of a reward-based algorithm passes
through a loss-based tool, state the translation $y = 1 - x$ (or $y=-x$) once as a lemma.

**Stochastic bandits.** A stochastic bandit is a Markov kernel `ν : Kernel α ℝ` and its environment
is LML's `stationaryEnv ν`. The mean of arm $a$ is `(ν a)[id]`. Noise assumptions are stated per
arm, as in LML: σ²-sub-Gaussian rewards are
`∀ a, HasSubgaussianMGF (fun x ↦ x - (ν a)[id]) σ2 (ν a)` with `σ2 : ℝ≥0` the variance proxy, and
bounded rewards are `∀ a, ∀ᵐ x ∂(ν a), x ∈ Set.Icc 0 1`. Where [LS] assumes 1-subgaussian rewards,
state the result for σ²-sub-Gaussian rewards; the constants below include $\sigma^2$.

**Regret.** The expected stochastic regret is `P[regret ν A n]` with LML's `regret`, the expectation
of the pseudo-regret $\sum_{t<n}\Delta_{A_t}$. The adversarial regret against an oblivious reward
table $x:\mathbb N\to\alpha\to\mathbb R$ is
$R_n(x)=\max_a\sum_{t<n}x_t(a)-\mathbb E\big[\sum_{t<n}x_t(A_t)\big]$ [LS, (11.1)]. Linear regrets are
defined in Layer 9 and Layer 10.

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
book's special cases (`Fin K`, unit variance, $\mathbb R^d$ instead of an inner product space) as
the primary statements; derive them as corollaries when useful.

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
| Interaction protocol and law of a run | [LML `Algorithm.lean`][lml-alg] (`Algorithm`, `Environment`, `IsAlgEnvSeq`, `history`, `IsAlgEnvSeq.filtration`), [`IonescuTulceaSpace.lean`][lml-it] (`trajMeasure`, `IT.isAlgEnvSeq_trajMeasure`, `IsAlgEnvSeq.map_trajectory`) |
| Stochastic and oblivious environments | [LML `StationaryEnv.lean`][lml-env] (`stationaryEnv`, `obliviousEnv`, `IsObliviousEnv`), [`EvaluationEnv.lean`][lml-eval] (`onlineEvalEnv g hg`, the oblivious adversary with bandit feedback) |
| Deterministic algorithms and measurable argmax | [LML `Deterministic.lean`][lml-det] (`detAlgorithm`), [`MeasurableArg.lean`][lml-argmax] (`argmax`, `measurable_argmax`) |
| Counts, sums, empirical means, per-arm reward streams | [LML `FiniteActions.lean`][lml-fa] (`pullCount`, `pullCount'`, `rewardByCount`), [`SumRewards.lean`][lml-sum] (`sumRewards`, `empMean`, `empMean'`), [`Online/Bandit/SumRewards.lean`][lml-conc] (`prob_sumRewards_sub_pullCount_mul_ge_le` and the transfer to the i.i.d. stream model) |
| Stochastic regret and existing regret bounds | [LML `Regret.lean`][lml-regret] (`regret`, `gap`, `integral_regret_le_of_forall_integral_pullCount_le`), [`Regret/UCB.lean`][lml-ucb] (`UCB.expectation_pullCount_le`, `UCB.regret_le_of_gt_two'`), [`Regret/ETC.lean`][lml-etc], [`Regret/BayesRegretTS.lean`][lml-ts] |
| KL divergence of histories | [LML `DivergenceDecomposition.lean`][lml-div] (`IsAlgEnvSeq.klDiv_map_history`: the time-sum $\sum_{t<n}\int D(\nu_{A_t},\nu'_{A_t})$ for two stationary environments) |
| KL divergence | Mathlib `InformationTheory.klDiv`, `klDiv_compProd_eq_add`, `klDiv_map_le`; LML [`ChainRule.lean`][lml-chain] (`klDiv_compProd_right_eq_lintegral`); Tau Ceti [`Pinsker.lean`][tc-pinsker] (`two_mul_sq_measureReal_sub_le_klDiv`) and [`Variational.lean`][tc-dv] |
| Sub-Gaussian concentration and martingales | Mathlib [`SubGaussian.lean`][ml-subg] (`HasSubgaussianMGF`, `HasCondSubgaussianMGF`, `hasSubgaussianMGF_of_mem_Icc`, `measure_sum_ge_le_of_iIndepFun`, `measure_sum_ge_le_of_hasCondSubgaussianMGF`), [`OptionalStopping.lean`][ml-os] (`maximal_ineq`), `Supermartingale` |
| Laws | Mathlib `gaussianReal`, `bernoulliMeasure`, `multivariateGaussian`; Tau Ceti [`Gaussian/Cdf.lean`][tc-gauss] (`measureReal_Ioi_gaussianReal`) |
| Convex analysis | LML [`Bregman/Basic.lean`][lml-breg] (`bregDiv`, notation `D_[f](x, y, J)`, `bregDiv_three_point`), [`Subgradient/`][lml-subgrad]; Tau Ceti [`Conjugate.lean`][tc-conj] (`fenchelConjugate`), [`Strong.lean`][tc-strong] (`StrongConvexOn.add_add_le_of_hasFDerivWithinAt`); Mathlib `stdSimplex`, `StrongConvexOn` |
| Linear algebra | Mathlib `ContinuousLinearMap.IsPositive` and its Loewner order, `LinearMap.det`, `Matrix.det_one_add_replicateCol_mul_replicateRow`, `Matrix.add_mul_mul_inv_eq_sub`; Tau Ceti [`Frame.lean`][tc-frame] (`frameOperator`) and [`AffineNormalization.lean`][tc-affine] (`IsCompact.exists_affineBasis_abs_coord_le_one`) |

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
| 1 | Concentration and maximal inequalities | Layer 0 |
| 2 | UCB-type algorithms for sub-Gaussian rewards | Layers 0–1; LML UCB |
| 3 | KL-UCB for rewards in $[0,1]$ | Layers 0–1 |
| 4 | Lower bounds for finitely many arms | Layer 0; LML divergence decomposition |
| 5 | Thompson sampling | Layers 0–1; Layer 4 for asymptotic optimality |
| 6 | Convex analysis and online linear optimization | Layer 0 |
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
5. **Adversarial and expert regrets.** Define the adversarial regret $R_n(x)$ of the Conventions for
   runs against `onlineEvalEnv x _`, and for bandits with expert advice the regret
   $R_n=\mathbb E\big[\max_{m}\sum_{t<n}\langle E^{(t)}_m,x_t\rangle-\sum_{t<n}x_t(A_t)\big]$ of
   [LS, (18.6)], where the advice $E^{(t)}\in\Delta(\alpha)^M$ is the observation of round $t$ of an
   environment with deterministic observations and bandit feedback. Construct that environment.
   Prove that for i.i.d. reward tables the expected adversarial regret dominates the stochastic
   regret (used in Layer 4.5).

Completion examples: a one-armed bandit has zero regret for every algorithm; Gaussian and Bernoulli
instances satisfy the sub-Gaussian and boundedness hypotheses used later;
$U(p,0)=p$, $U(1,c)=1$, and $U(p,c)\to1$ as $c\to\infty$.

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
3. **Per-arm statements on runs.** For a run of any algorithm against `stationaryEnv ν`, transfer
   statements about the i.i.d. stream of rewards of one arm to statements about the empirical mean
   after its $s$-th pull, for all $s$ simultaneously, using LML's per-arm stream model. State the
   version that the lemmas below need: a bound on
   $\mathbb E\big[\sum_{s}\mathbb 1\{\text{event about the first } s \text{ rewards of arm } a\}\big]$
   in terms of the corresponding i.i.d. quantity.
4. **Chernoff bounds in relative-entropy form.** For i.i.d. $X_i\in[0,1]$ with mean $\mu$ (not only
   Bernoulli, [LS, Note 10.3.1]):
   $P(\hat\mu_n\ge\mu+\varepsilon)\le\exp(-n\,d(\mu+\varepsilon,\mu))$ for
   $\varepsilon\in[0,1-\mu]$, and the lower tail [LS, Lemma 10.3], with
   [LS, Corollary 10.4] for the confidence levels $U$ and $L$.
5. **Lemmas for the index policies.** Prove, for σ²-sub-Gaussian streams, [LS, Lemma 8.2] and
   [LS, Lemma 9.3], and the summation bound $\sum_{t\le n}\frac1{f(t)}\sum_{s\le n}
   e^{-s\varepsilon^2/(2\sigma^2)}\le 5\sigma^2/\varepsilon^2$ of [LS, Exercise 8.1]; for
   $[0,1]$-valued streams, [LS, Lemma 10.7] and [LS, Lemma 10.8]. Scale the constants with
   $\sigma^2$ as in Layer 2.
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
2. **Asymptotically optimal UCB.** Define the index policy with index
   $\hat\mu_a+\sqrt{2\sigma^2\log f(t)/T_a}$, $f(t)=1+t\log^2 t$ [LS, Algorithm 6]. Prove
   [LS, Theorem 8.1] for σ²-sub-Gaussian rewards:
   $$\mathbb E[R_n]\le\sum_{a:\Delta_a>0}\inf_{\varepsilon\in(0,\Delta_a)}\Delta_a\Big(1+\frac{5\sigma^2}{\varepsilon^2}+\frac{2\sigma^2\big(\log f(n)+\sqrt{\pi\log f(n)}+1\big)}{(\Delta_a-\varepsilon)^2}\Big),$$
   and, in eventual form, $\limsup_n\mathbb E[R_n]/\log n\le\sum_{a:\Delta_a>0}2\sigma^2/\Delta_a$.
3. **MOSS.** Define the horizon-dependent index policy with index
   $\hat\mu_a+\sqrt{\frac{4\sigma^2}{T_a}\log^+\frac{n}{kT_a}}$ [LS, Algorithm 7] and prove
   [LS, Theorem 9.1]: $\mathbb E[R_n]\le 39\sqrt{\sigma^2kn}+\sum_a\Delta_a$.

Generalization: arbitrary finite arm types and variance proxies, where [LS] has $[k]$ and
1-subgaussian rewards. Completion examples: for two Gaussian arms with gap $\Delta$, the bounds of
items 2 and 3 are finite and the asymptotic constant is $2\sigma^2/\Delta$.

## Layer 3: KL-UCB for rewards in [0,1]

1. **Algorithm.** Define KL-UCB [LS, Algorithm 8]: the index policy with index
   $U(\hat\mu_a,\log f(t)/T_a)$ for the level $U$ of Layer 0.2 and $f(t)=1+t\log^2t$.
2. **Regret.** For rewards in $[0,1]$ almost surely, prove [LS, Theorem 10.6]:
   $$\mathbb E[R_n]\le\sum_{a:\Delta_a>0}\inf_{\substack{\varepsilon_1,\varepsilon_2>0\\\varepsilon_1+\varepsilon_2<\Delta_a}}\Delta_a\Big(\frac{\log f(n)}{d(\mu_a+\varepsilon_1,\mu^*-\varepsilon_2)}+\frac1{2\varepsilon_1^2}+\frac2{\varepsilon_2^2}\Big),$$
   and, in eventual form, $\limsup_n\mathbb E[R_n]/\log n\le\sum_{a:\Delta_a>0}\Delta_a/d(\mu_a,\mu^*)$
   (the book leaves this limit to its Exercise 10.2; its proof writes $f(n)$ for $\log f(n)$ in the
   last line).

Generalization: rewards with any law on $[0,1]$, where [LS] states Bernoulli rewards. Completion
examples: arms with means $0$ or $1$ (the singular values of $d$), and a two-armed Bernoulli bandit.

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
   with the sum in `ℝ≥0∞`. Compute $d_{\inf}$ for Gaussian laws with known variance and for
   Bernoulli laws [LS, Table 16.1]. Prove [LS, Lemma 16.3] and the finite-time bound
   [LS, Theorem 16.4], for Gaussian bandits with variance $\sigma^2$.
5. **Asymptotic optimality and the adversarial lower bound.** Prove that the algorithms of Layers 2.2
   and 3 are consistent and attain the Lai–Robbins constant (Gaussian arms and Bernoulli arms
   respectively): their expected regret is $c^*\log n+o(\log n)$. Prove the adversarial minimax lower
   bound: for every algorithm and $n\ge 3(k-1)/8$ there is a table $x\in\{0,1\}^{n\times\alpha}$ with
   $R_n(x)\ge\frac1{27}\sqrt{3(k-1)n/32}$, by averaging the Bernoulli case of item 3 over i.i.d.
   tables (Layer 0.5).

Generalization: the minimax bound for a family of laws rather than unit-variance Gaussians.
Completion checks: the divergence decomposition is zero for identical environments; the Lai–Robbins
constant is $+\infty$ when some $d_{\inf}$ vanishes, and the theorem then states that the regret of
every consistent policy eventually exceeds every multiple of $\log n$.

## Layer 5: Thompson sampling

1. **Algorithm.** Define Gaussian Thompson sampling with variance proxy $\sigma^2$ and flat prior:
   at each round, sample independently $\theta_a\sim\mathcal N(\hat\mu_a,\sigma^2/T_a)$ (and
   $\theta_a=+\infty$ for unpulled arms) and play `argmax θ`. The book's update writes the variance
   $1/t$; the intended variance after $s$ samples of the arm is $1/s$ [LS, Theorem 36.3].
2. **Generic bound.** Prove [LS, Theorem 36.2] for the follow-the-perturbed-leader scheme of
   [LS, Algorithm 24]: with arm $a^*$ optimal, $a\ne a^*$, $\varepsilon\in\mathbb R$ and
   $G_{as}=1-F_{as}(\mu^*-\varepsilon)$,
   $\mathbb E[T_a(n)]\le1+\mathbb E\big[\sum_{s<n}(1/G_{a^*s}-1)\big]+\mathbb E\big[\sum_{s<n}\mathbb 1\{G_{as}>1/n\}\big]$.
3. **Frequentist regret.** For Gaussian bandits with variance $\sigma^2$, prove
   [LS, Theorem 36.3]: $\mathbb E[R_n]/\log n\to\sum_{a:\Delta_a>0}2\sigma^2/\Delta_a$ (upper bound
   in eventual form, matched by Layer 4.4), and
   $\mathbb E[R_n]\le C\sqrt{\sigma^2kn\log n}+\sum_a\Delta_a$ for an absolute constant $C$, through
   the steps of [LS, Exercise 36.6] and the Gaussian tails of Layer 1.6.

Generalization: arbitrary variance proxy and finite arm type. LML's Bayesian Thompson sampling
(`tsAlgorithm`, `TS.integral_regret_le`) is a different algorithm (it samples from the posterior of
a prior over environments); do not restate its results.

## Layer 6: Convex analysis and online linear optimization

Work in a finite-dimensional real inner product space `E`. Losses are minimized.

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
   from past actions.
4. **Two instances.** Prove [LS, Proposition 28.6] (unit ball, $F=\tfrac12\|a\|^2$,
   $\eta=n^{-1/2}$: $R_n\le\sqrt n$) and [LS, Proposition 28.7] (simplex, unnormalized negative
   entropy, $\eta=\sqrt{2\log(d)/n}$: $R_n\le\sqrt{2n\log d}$). Identify the latter with exponential
   weights over a finite set, stated on `α → ℝ` with `stdSimplex`.

Generalization: an inner product space rather than $\mathbb R^d$; the instances are corollaries.

## Layer 7: Adversarial bandits with finitely many arms and expert advice

Rewards $x_t(a)\in[0,1]$; runs against `onlineEvalEnv x _`.

1. **Importance-weighted estimators.** For a weight-based policy with weights bounded away from
   zero, define the standard and loss-based estimators [LS, (11.3), (11.6)] and prove conditional
   unbiasedness and the conditional variance formulas [LS, (11.4), (11.5)].
2. **Exp3.** Define Exp3 [LS, Algorithm 9] as a weight-based policy using the loss-based estimator.
   Prove, for every $\eta>0$, $R_n(x)\le\frac{\log k}{\eta}+\frac{\eta nk}{2}$, and
   [LS, Theorem 11.2]: with $\eta=\sqrt{2\log(k)/(nk)}$, $R_n(x)\le\sqrt{2nk\log k}$.
3. **Exp3-IX.** Define Exp3-IX [LS, Algorithm 10] and prove [LS, Lemmas 12.2–12.4] and both
   high-probability bounds of [LS, Theorem 12.1] for the random regret
   $\hat R_n=\max_a\sum_{t<n}(y_t(A_t)-y_t(a))$, $y=1-x$.
4. **Exp4.** Define Exp4 [LS, Algorithm 11] for $M$ experts and prove [LS, Lemma 18.2] and
   [LS, Theorem 18.1]: with $\gamma=0$ and $\eta=\sqrt{2\log(M)/(nk)}$, $R_n\le\sqrt{2nk\log M}$.
   Show that Exp3 is Exp4 with the $k$ experts that each recommend one arm.

Completion checks: for $k=1$ every bound is $0$; the lower bound of Layer 4.5 shows the order
$\sqrt{nk}$ of item 2 is attained up to $\sqrt{\log k}$.

## Layer 8: Least squares, self-normalized bounds and optimal design

Work in a finite-dimensional real inner product space `E` of dimension $d$, with linear operators
`E →L[ℝ] E`; give matrix corollaries on `EuclideanSpace ℝ ι`.

1. **Design operators.** For $\lambda\ge0$ and $x_0,x_1,\ldots\in E$, define
   $V_t(\lambda)=\lambda\,\mathrm{id}+\sum_{s<t}x_s\otimes x_s$ (with $x\otimes x$ the operator
   $v\mapsto\langle x,v\rangle x$, Tau Ceti's `frameOperator` for finite families), and the weighted
   norm $\|v\|^2_{V^{-1}}=\langle v,V^{-1}v\rangle$. Prove positivity, invertibility for
   $\lambda>0$, the rank-one update of the inverse (Sherman–Morrison) and of the determinant
   $\det V_{t+1}=\det V_t\,(1+\|x_t\|^2_{V_t^{-1}})$ [LS, (19.9)], and
   $\det V\le(\operatorname{trace}V/d)^d$ for positive $V$.
2. **Elliptical potential.** Prove [LS, Lemma 19.4]: for positive definite $V_0$ and $\|x_t\|\le L$,
   $\sum_{t<n}\min\{1,\|x_t\|^2_{V_t^{-1}}\}\le2\log\frac{\det V_n}{\det V_0}\le
   2d\log\frac{\operatorname{trace}V_0+nL^2}{d\det(V_0)^{1/d}}$.
3. **Regularized least squares.** Define the ridge estimator
   $\hat\theta_t=V_t(\lambda)^{-1}\sum_{s<t}x_sY_s$ and prove it minimizes the regularized squared
   loss [LS, (19.4)–(19.6)].
4. **Self-normalized bound.** On a filtered probability space, for an $E$-valued predictable
   sequence $x_t$ and real noise $\eta_t$ that is conditionally σ²-sub-Gaussian given the past and
   $x_t$, with $S_t=\sum_{s<t}\eta_sx_s$: prove that $\exp(\langle v,S_t\rangle-\frac{\sigma^2}2\|v\|^2_{V_t(0)})$
   is a supermartingale [LS, Lemma 20.2], its mixtures over probability measures are
   supermartingales [LS, Lemma 20.3], and [LS, Theorem 20.4] with σ²:
   $P\big(\exists t,\ \|S_t\|^2_{V_t(\lambda)^{-1}}\ge2\sigma^2\log\frac1\delta+\sigma^2\log\frac{\det V_t(\lambda)}{\lambda^d}\big)\le\delta$,
   by the Gaussian mixture of covariance $(\lambda\,\mathrm{id})^{-1}$ and Ville's inequality.
5. **Confidence sets.** For $Y_t=\langle\theta_*,x_t\rangle+\eta_t$, prove [LS, Theorem 20.5] with
   σ² and the bound $\det V_t(\lambda)/\lambda^d\le(1+nL^2/(\lambda d))^d$ [LS, (20.9)]; for a
   fixed design and independent noise, prove [LS, (20.2)].
6. **Kiefer–Wolfowitz.** For a design $\pi$ (a finitely supported probability on a set
   $\mathcal A\subseteq E$), define $V(\pi)=\sum_a\pi(a)\,a\otimes a$ and
   $g(\pi)=\sup_{a\in\mathcal A}\|a\|^2_{V(\pi)^{-1}}$. For compact $\mathcal A$ spanning $E$, prove
   [LS, Theorem 21.1] (minimizing $g$, maximizing $\log\det V$, and $g=d$ are equivalent, and a
   minimizer with support of size at most $d(d+1)/2$ exists) for compact sets, not only finite ones
   [LS, Exercise 21.3]; and the non-spanning version: if $\dim\operatorname{span}\mathcal A=m$,
   there is a design with support at most $m(m+1)/2$ and $\sup_{a}\|a\|^2_{V(\pi)^{+}}=m$, using
   the inverse on the span [LS, Exercise 21.6]. Prove $\|a\|^2_{V(\pi^*)^{-1}}=d$ on the support
   [LS, Exercise 21.5].

Generalization: operators on an inner product space and σ²-sub-Gaussian noise. Completion examples:
for the standard basis of $\mathbb R^d$ the uniform design is G-optimal with $g=d$; for the unit
sphere the uniform distribution on an orthonormal basis is G-optimal.

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
   $E$: use the non-spanning design of Layer 8.6 on their span.
4. **Lower bounds.** With Gaussian noise, prove [LS, Theorem 24.1] (hypercube
   $[-1,1]^d$: some $\theta\in\{\pm n^{-1/2}\}^d$ gives $R_n\ge\frac{e^{-2}}8d\sqrt n$) and
   [LS, Theorem 24.2] (unit ball, $d\le2n$: some $\theta$ with $\|\theta\|^2=d^2/(48n)$ gives
   $R_n\ge d\sqrt n/(16\sqrt3)$), using Layer 4.2 and LML's divergence decomposition for general
   action spaces.

Generalization: contextual feature maps, σ²-sub-Gaussian noise, inner product spaces. Completion
check: with one-hot features, item 1 recovers stochastic bandits with finitely many arms and the
OFUL bound applies to them.

## Layer 10: Adversarial linear bandits

Losses $y_t\in E$ are chosen obliviously; the learner observes $\langle A_t,y_t\rangle$.

1. **Exp3 with exploration.** For a finite spanning action set with
   $\sup_a|\langle a,y_t\rangle|\le1$, define [LS, Algorithm 15] and prove [LS, Theorem 27.1]:
   $R_n\le2\sqrt{(2g(\pi)+d)\,n\log k}$ for every exploration design $\pi$, hence
   $R_n\le2\sqrt{3dn\log k}$ with the Kiefer–Wolfowitz design of Layer 8.6.
2. **Mirror descent with bandit feedback.** Prove [LS, Theorem 28.10] for the scheme of
   [LS, Algorithm 16] with unbiased estimates, and [LS, Theorem 28.11] for the unit ball:
   with $\|y_t\|\le1$, $r=1-2\eta d$ and $\eta=\sqrt{\log(n)/(3dn)}$, $R_n\le2\sqrt{3nd\log n}$.
   The exploration direction $U_t$ is uniform on $\{\pm e_1,\dots,\pm e_d\}$ for an orthonormal
   basis $(e_i)$ of $E$ (the box of [LS, Algorithm 17] omits the signs).

## Completion checks

Every new definition comes with measurability, evaluation and extensionality lemmas, and every
algorithm with its run lemma (the conditional law of its action given the history), so that the
regret theorems apply to all runs. Check in particular:

* Index policies pull every arm once before comparing finite indices; the asymptotic constants of
  Layers 2.2, 3 and 5 coincide with the Lai–Robbins constants of Layer 4.4 for Gaussian and
  Bernoulli arms.
* The minimax lower bounds of Layers 4.3, 4.5 and 9.4 match the upper bounds of Layers 2.3, 7.2 and
  9.2 up to the logarithmic and constant factors stated.
* Exponential weights from Layer 6.4, Exp3 and Exp4 agree on the instances where their definitions
  coincide.
* The Kiefer–Wolfowitz theorem applies to the finite action sets of Layers 9.3 and 10.1, including
  sets that do not span $E$.

Compilation of the suggested signatures checks their types, not the truth of their admitted
theorems or the completion of these milestones.

## References

T. Lattimore and Cs. Szepesvári, [*Bandit Algorithms*][ls], Cambridge University Press (2020),
Chapters 4–22, 24, 26–28 and 36, is the main source; the layers cite its numbered results.

Original sources: P. Auer, N. Cesa-Bianchi, Y. Freund and R. Schapire, *The nonstochastic
multiarmed bandit problem* (SIAM J. Comput., 2002) for Exp3 and Exp4; J.-Y. Audibert and S. Bubeck,
*Minimax policies for adversarial and stochastic bandits* (COLT 2009) for MOSS; A. Garivier and
O. Cappé, *The KL-UCB algorithm for bounded stochastic bandits and beyond* (COLT 2011);
T. L. Lai and H. Robbins, *Asymptotically efficient adaptive allocation rules* (Adv. Appl. Math.,
1985) and A. N. Burnetas and M. N. Katehakis, *Optimal adaptive policies for sequential allocation
problems* (Adv. Appl. Math., 1996) for Layer 4.4; G. Neu, *Explore no more* (NeurIPS 2015) for
Exp3-IX; Y. Abbasi-Yadkori, D. Pál and Cs. Szepesvári, *Improved algorithms for linear stochastic
bandits* (NeurIPS 2011) for Layers 8.4–9.2; J. Kiefer and J. Wolfowitz, *The equivalence of two
extremum problems* (Canad. J. Math., 1960).

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
