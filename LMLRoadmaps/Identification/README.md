# Roadmap: Bandit identification

Develop the theory of identification in stochastic bandits (pure exploration): an algorithm samples
arms adaptively, stops, and answers a question about the unknown bandit, such as which arm has the
largest mean. In the *fixed-confidence* setting the answer must be correct with probability at
least $1-\delta$ and the expected number of samples is minimized. In the *fixed-budget* setting
the number of samples is fixed and the probability of error is minimized. The headline results
are:
- the universal lower bound $\mathbb E[\tau]\ge T^*(\theta)\,\mathrm{kl}(\delta,1-\delta)$ and the
  pure exploration game that defines $T^*$;
- $\delta$-correctness of generalized likelihood ratio stopping rules for every sampling rule;
- asymptotic optimality of Track-and-Stop and Sticky Track-and-Stop;
- non-asymptotic guarantees of game-based and Top Two sampling rules, and asymptotic optimality of
  Frank–Wolfe sampling;
- the elimination algorithms with gap-dependent guarantees;
- successive rejects and sequential halving with the fixed-budget lower bounds, including the
  non-existence of a complexity in fixed-budget best arm identification;
- the characteristic time and asymptotically optimal algorithms of linear identification.

Build the surrounding library at the generality the research literature uses, so that papers in
the area can be written on top of it:
- identification tasks with arbitrary models, answer sets and multiple correct answers;
- natural exponential families;
- the change of measure at stopping times;
- transportation costs and their continuity (Berge's maximum theorem, Sion's minimax theorem);
- generalized likelihood ratio statistics and their time-uniform deviation inequalities;
- tracking lemmas, a generic sample-complexity reduction, AdaHedge;
- large deviations of empirical means under static allocations.

`README.md` is the definitive specification; `Suggested.lean` records selected interfaces and is
not an exhaustive checklist.

Suggested homes: `LMLExplore/Identification/` for identification material (namespace
`LMLExplore.Identification`), and the mathematical home of each general tool (for example
`LMLExplore/Probability/Distributions/ExponentialFamily/` for natural exponential families,
`LMLExplore/Probability/LargeDeviations/` for Cramér-type bounds,
`LMLExplore/Topology/Semicontinuous/` for Berge's maximum theorem, `LMLExplore/OnlineLearning/` for
AdaHedge).

## Scope and dependencies

This roadmap owns identification in stochastic bandits with a finite set of arms (pure
exploration): fixed-confidence and fixed-budget identification for arbitrary identification
tasks, with single or multiple correct answers, in unstructured models and in linear models.

| Material | Owner and interface consumed here |
| --- | --- |
| Interaction protocol, runs, trajectory measure, stationary environments | LML `SequentialLearning/`: `Algorithm`, `Environment`, `IsAlgEnvSeq`, `trajMeasure`, `stationaryEnv` |
| Identification algorithms: sampling, stopping and output rules, stopping time, stopped history, law of the output, PAC property | LML `SequentialLearning/IdentificationAlg.lean` (`IdentAlg`, `IdentAlg.stoppingTime`, `IdentAlg.stoppedHist`, `IdentAlg.outputMeasure`, `IdentAlg.IsRun`, `IdentAlg.IsPAC`), `SequentialLearning/StoppedHistory.lean` (`sigmaHistory`, `stoppedHistMeasure`) |
| Pull counts, reward sums, empirical means | LML `SequentialLearning/FiniteActions.lean`, `SumRewards.lean` |
| KL divergence of histories at a fixed horizon | LML `SequentialLearning/DivergenceDecomposition.lean`; LMLExplore `Learning.IsAlgEnvSeq.klDiv_map_history_eq_sum_pullCount` |
| Binary relative entropy, Bretagnolle–Huber, Ville's inequality, mixtures of supermartingales, time-uniform sub-Gaussian bounds, Chernoff bounds in relative-entropy form | LMLExplore (Bandits roadmap, Layers 0.2, 1 and 4): `klBer`, `klBerReal`, `exp_neg_klDiv_div_two_le`, `MeasureTheory.Supermartingale.measure_exists_le_le`, `supermartingale_integral_of_integrable`, `supermartingale_exp_sum_mul_of_hasCondSubgaussianMGF`, `measureReal_sum_ge_le_exp_klBerReal` |
| Design operators, self-normalized bounds, G-optimal designs | Bandits roadmap, Layer 8 (`designOp`, the self-normalized bound, the Kiefer–Wolfowitz theorem) |
| Exponential weights, regret of online linear optimization | Bandits roadmap, Layer 6 |
| KL divergence, chain rule, data processing, exponential tilting, cumulant generating functions | Mathlib `InformationTheory/KullbackLeibler/`, `MeasureTheory/Measure/Tilted.lean`, `MeasureTheory/Measure/LogLikelihoodRatio.lean`, `Probability/Moments/` (`cgf`, `integrableExpSet`, `deriv_cgf`, `iteratedDeriv_two_cgf`) |
| Minimax theorems, continuity of suprema over compact sets | Mathlib `Topology/Sion.lean` (`Sion.minimax`, `Sion.exists_isSaddlePointOn`), Tau Ceti `Topology/Sion.lean`, Mathlib `Topology/Order/Compact.lean` (`IsCompact.continuous_sSup`, `IsCompact.continuous_sInf`) |

Build missing material in this roadmap where it is listed as a target, and consume existing
implementations directly. The Bandits roadmap and this one do not overlap: regret minimization,
the fixed-horizon divergence decomposition and the binary relative entropy belong to the Bandits
roadmap. The change of measure at stopping times, exponential families and everything specific to
identification belong here.

Outside this roadmap:
- best policy identification in Markov decision processes;
- combinatorial and semi-bandit identification beyond what the general tasks of Layer 1 express;
- dueling bandits, contextual and multi-fidelity identification;
- Bayesian (posterior-based) guarantees: Top Two algorithms are analyzed here with frequentist
  guarantees only;
- nonparametric identification with $\mathrm K_{\inf}$ or $\mathrm{KL}_{\inf}$ (bounded or
  heavy-tailed arms), including the bounded-arm Top Two results of [JDBdHK22].

## Conventions

**Sources and numbering.** Statements cite the original papers by the keys of the References
section, with their theorem numbers, and [LS, Chapter 33] for the textbook account. Rounds are
numbered from 0, as in LML: after $n$ rounds the actions $A_0,\dots,A_{n-1}$ have been played, and
the stopping time $\tau$ is the number of rounds played. A paper's round $t$ is Lean round $t-1$.

**Arms and observations.** A finite set of arms is a type `α` with `[Fintype α] [Nonempty α]
[DecidableEq α] [MeasurableSpace α] [MeasurableSingletonClass α]`, and $K$ is `Fintype.card α`. Do
not specialize to `Fin K`. Observations live in a measurable space `𝓨`. The framework, the lower
bounds and the pure exploration game (Layers 0–3) are stated for general `𝓨`. Exponential-family
material and the algorithms built on empirical means use `𝓨 = ℝ`. The observation type of the
sampling rule is `Unit`, as for LML's `stationaryEnv`.

**Models and tasks.** An identification task (Layer 1.1) has a type `Θ` of models with a Markov
kernel `ν θ : Kernel α 𝓨` for each model, a set `M : Set Θ` of admissible models, a type `ℐ` of
answers and a set-valued correct-answer function `correct : Θ → Set ℐ`. Single-answer tasks have
`correct θ = {answer θ}` on `M`. A model is not required to be a vector of means: means of
exponential families (Layer 1.2), parameters of linear models (Layer 9) and pairs (mean, variance)
are all models.

**Divergences and allocations.** Divergences between arm laws are Mathlib's `klDiv`, valued in
`ℝ≥0∞`. Allocations (proportions of samples) are vectors `w : α → ℝ` with nonnegative entries
summing to `1`, the set $\Delta_K$, stated directly: Mathlib's set `stdSimplex` is deprecated, and
its replacement `Convexity.StdSimplex` is a type of finitely supported distributions, not a subset
of `α → ℝ` with its topology. Transportation costs, the game value and the characteristic time are
`ℝ≥0∞`-valued:
$$\mathrm{cost}_\theta(w,\lambda)=\sum_a w_a\,\mathrm{KL}(\nu_a(\theta),\nu_a(\lambda)),\qquad
D(\theta,w,\neg i)=\inf_{\lambda\in\neg i}\mathrm{cost}_\theta(w,\lambda),$$
$$D(\theta,\neg i)=\sup_{w\in\Delta_K}D(\theta,w,\neg i),\qquad
D(\theta)=\max_{i\in i^*(\theta)}D(\theta,\neg i),\qquad T^*(\theta)=D(\theta)^{-1},$$
with $\neg i=\{\lambda\in M: i\notin i^*(\lambda)\}$ the alternatives to $i$, written with
`ENNReal.ofReal (w a) * klDiv …`. Real-valued versions are corollaries for models at finite
divergence. The fixed-confidence quantities put the true model first,
$\mathrm{KL}(\nu_a(\theta),\nu_a(\lambda))$. The fixed-budget exponents of Layer 8 put the
alternative first; they are the same costs applied to the swapped pair, not new definitions. The
two orders agree for Gaussian arms with known variance and differ in general, which is why fixed
budget can be strictly easier than fixed confidence [KCG16, Theorem 14].

**Guarantees.**
- An identification algorithm is `IdentAlg Unit α 𝓨 ℐ`.
- It is *$\delta$-correct* on a task [DK19] if on every model $\theta\in M$, with probability at
  least $1-\delta$, it stops and outputs a correct answer.
- It is *$\delta$-PAC* if moreover it stops almost surely on every model of $M$.
- Both properties are stated on the laws of the runs, which the algorithm and the environment
  determine: the joint law of the stopped history and the output, built from LML's
  `stoppedHistMeasure` and the output kernel, and the law `IdentAlg.outputMeasure`.
- The sample complexity is $\mathbb E_\theta[\tau]$, the `ℝ≥0∞`-valued lower integral of the
  stopping time under `trajMeasure A.alg (stationaryEnv (ν θ))`.
- A fixed-budget algorithm with budget $T$ stops after exactly $T$ rounds; its probability of
  error on $\theta$ is the `outputMeasure`-mass of the incorrect answers.

**Families of algorithms and asymptotics.** Fixed-confidence algorithms are families
`A : ℝ → IdentAlg …` indexed by the confidence level. Fixed-budget algorithms are families indexed
by the budget. Asymptotic statements are eventual inequalities. For example
"$\limsup_{\delta\to0}\mathbb E[\tau_\delta]/\log(1/\delta)\le T^*$" is
`∀ c > T*, ∀ᶠ δ in 𝓝[>] 0, E[τ_δ] ≤ c * log (1/δ)`, and fixed-budget rates are stated with
`∀ᶠ T in atTop`. Never use `limsup`/`liminf` of real sequences as the primary form.

**Theorem shapes.** Upper bounds quantify over runs: for every `IdentAlg.IsRun A env O X Y out P`,
a bound on an expectation or a probability under `P`. Lower bounds and correctness properties are
stated on the laws (`trajMeasure`, `stoppedHistMeasure`, `outputMeasure`) and transferred to every
run with LML's law-uniqueness lemmas. Where a paper states a universal constant, state the
explicit constant when the proof gives one.

**Generality.** Each layer says where its statements generalize the papers. Do not reintroduce
special cases (`Fin K`, Bernoulli or Gaussian arms only, unit variance, a single correct answer) as
the primary statements; derive them as corollaries.

**Namespaces.** Identification definitions live in `LMLExplore.Identification`, exponential
families in `LMLExplore` (or the namespace of the type they act on), and LML's definitions keep
their names (`Learning.IdentAlg`, `Learning.stationaryEnv`, …).

## Existing formalizations

The LMLPapers project of the same author (Apache-2.0, unpublished) contains formalizations of
[GK16], [DK19], [DKM19] and [D23] together with an identification library on top of LML's
`IdentAlg`:
- identification tasks, multiple-answer tasks and transportation costs;
- the change of measure at stopping times;
- GLRT stopping rules;
- C- and D-tracking, Track-and-Stop and Sticky Track-and-Stop;
- the pure-exploration game algorithm;
- successive elimination, median elimination, sequential halving and fixed-budget algorithms;
- one-parameter exponential families and large deviation principles.

It states tasks on `Fin K` with means in exponential families. The roadmap asks for the general
forms above, and that development may be adapted to them.

## Layers and dependencies

| Layer | Content | Prerequisites |
| --- | --- | --- |
| 0 | Identification algorithms, correctness and sample complexity | LML `IdentAlg` |
| 1 | Identification tasks and natural exponential families | Layer 0 |
| 2 | Change of measure and lower bounds | Layers 0–1; Bandits roadmap Layer 4 |
| 3 | The pure exploration game | Layer 1 |
| 4 | Deviation inequalities and GLR stopping rules | Layers 1, 3; Bandits roadmap Layer 1 |
| 5 | Tracking and asymptotically optimal sampling rules | Layers 2–4 |
| 6 | Game-based, Top Two and Frank–Wolfe sampling rules | Layers 3–5; Bandits roadmap Layer 6 |
| 7 | Elimination and confidence-bound algorithms | Layers 0–2, 4 |
| 8 | Fixed-budget identification | Layers 0–3 |
| 9 | Linear identification | Layers 2–6; Bandits roadmap Layer 8 |

## Layer 0: Identification algorithms, correctness and sample complexity

1. **Constructions and canonical runs.**
   - Construct an identification algorithm from per-length rules: a sampling rule, measurable
     stopping predicates `stop n : Hist … n → Prop` and output kernels `output n`.
   - Prove the characterizations of its stopping time (equal to $n$ iff the first $n$-round
     history satisfying the rule is the $n$-round one; infinite iff no history does), measurability
     of the stopping time and of the stopped history, and that the stopped history belongs to the
     stopping rule iff the stopping time is finite.
   - Construct the canonical run of every identification algorithm in every environment (the
     trajectory measure times the output kernel at the stopped history), and transport runs along
     measure-preserving maps.
2. **Correctness notions.**
   - Define the joint law of the stopped history and the output, almost-sure stopping, $\delta$-PAC
     and $\delta$-correct algorithms for a family of environments and a badness predicate, with
     their task versions in Layer 1.
   - Prove $\delta$-PAC $\Rightarrow$ $\delta$-correct $\Rightarrow$ LML's `IsPAC` at level $\delta$,
     monotonicity in $\delta$ and in the badness predicate, restriction to subfamilies, and the
     run forms of each property.
3. **Sample complexity.**
   - Define $\mathbb E_{\mathrm{env}}[\tau]$ and prove it is the same along every run.
   - For stationary environments on finite arms, prove Wald's identities at the stopping time:
     $\mathbb E[\tau]=\sum_a\mathbb E[N_a(\tau)]$, and
     $\mathbb E\big[\sum_{t<\tau}f(A_t)\big]=\sum_a\mathbb E[N_a(\tau)]f(a)$ for $f\ge0$ (LMLExplore's
     `sum_lintegral_pullCount_mul` is the version for a measurable random time).
   - Prove $\mathbb E\big[\sum_{t<\tau}Y_t\big]=\sum_a\mathbb E[N_a(\tau)]\,\mu_a$ for integrable
     rewards when $\mathbb E[\tau]<\infty$.
4. **Fixed-budget algorithms.**
   - Define fixed-budget algorithms (stop after exactly $T$ rounds) and the fixed-budget constructor
     from a sampling rule and an output kernel on $T$-round histories.
   - Prove that their stopped history is the $T$-round history, that they stop almost surely, and
     that their output law is the output kernel composed with the law of the $T$-round history.
   - Define static (fixed-design) sampling rules, which play a fixed sequence of arms.

## Layer 1: Identification tasks and natural exponential families

1. **Tasks.**
   - Define identification tasks (Conventions): alternatives $\neg i$, answer sets
     $\{\theta\in M: i\in i^*(\theta)\}$, single-answer tasks, and the bandit environment
     `stationaryEnv (ν θ)` of a model.
   - Define $\delta$-correct and $\delta$-PAC algorithms for a task.
   - Define the classical tasks on vectors of means `α → ℝ`:
     - best arm identification on models with a unique best arm;
     - top-$m$ identification (the set of the $m$ largest means, on models where it is unique);
     - $\varepsilon$-best arm identification (additive: correct answers are the arms within
       $\varepsilon$ of the best);
     - thresholding (the set of arms with mean above $\gamma$, on models with no mean equal to
       $\gamma$);
     - the minimum-threshold task (is the smallest mean below $\gamma$?);
     - the multiple-answer task *Any Low Arm* [DK19, Example 1] (an arm with mean below $\gamma$,
       or "none");
     - half-space identification (the sign of $\langle u,\mu\rangle$).
   - For best arm identification, prove that the alternatives to the best arm $a^*$ have closure
     $\{\lambda:\exists b\ne a^*,\ \lambda_b\ge\max_c\lambda_c\}$ within the models whose means lie
     in the families' mean sets. Prove that the transportation infimum over $\neg a^*$ equals the
     infimum over this closed set when the divergences are continuous.
2. **Natural exponential families.**
   - For a probability measure $\rho$ on $\mathbb R$ with nonempty open natural-parameter set
     $\Theta_\rho=\operatorname{interior}(\texttt{integrableExpSet id }\rho)$, define the family of
     tilts $\rho_\eta=$ `ρ.tilted (η * ·)`, $\eta\in\Theta_\rho$.
   - Define the log-partition function $\psi=$ `cgf id ρ`, the mean map $\psi'$ (`deriv_cgf`), and
     its strict monotonicity when $\rho$ is not a Dirac mass (variance `iteratedDeriv_two_cgf` > 0).
   - Define the open interval of means and the mean parametrization $\mu\mapsto\rho_{\eta(\mu)}$.
   - Prove the closed form
     $\mathrm{KL}(\rho_{\eta(\mu)},\rho_{\eta(\mu')})=d(\mu,\mu')
     =\psi(\eta')-\psi(\eta)-\mu(\eta'-\eta)$ (from `llr_tilted_left`), and that $d$ is
     nonnegative, zero exactly on the diagonal, continuous on (means)$^2$, strictly convex in its
     first argument, and monotone in each argument on each side of the other (it is not convex in
     its second argument in general: the exponential family is a counterexample).
   - Prove the Cramér–Chernoff bound $\rho_{\eta(\mu)}^{\otimes n}(\hat\mu_n\ge x)\le
     \exp(-n\,d(x,\mu))$ for $x\ge\mu$ (and the lower tail), generalizing the Bandits roadmap's
     Layer 1.4 bound.
   - Prove the sub-Gaussian comparison: $d(\mu,\mu')\ge(\mu-\mu')^2/(2\sigma^2)$ when the family has
     variance at most $\sigma^2$ on the segment.
   - Prove that the Gaussian family with variance $\sigma^2$
     ($d(\mu,\mu')=(\mu-\mu')^2/(2\sigma^2)$), the Bernoulli family ($d=$ `klBer`, by the Bandits
     roadmap's `klDiv_bernoulliMeasure`), the Poisson family (Mathlib's `poissonMeasure`, pushed
     forward to `ℝ`) and the exponential family (`expMeasure`) are natural exponential families in
     this sense, with their divergences.
   - Define the bandit of a mean vector, with arm laws in per-arm exponential families. Define the
     generalized log-likelihood ratio extension of $d$ to empirical means at the boundary of the
     mean interval (for Bernoulli arms, $\hat\mu\in\{0,1\}$), with its continuity.
3. **Gaussian arms with unknown variances.** Define the two-parameter Gaussian model
   $\theta=(\mu_a,\sigma_a^2)_a$ and prove
   $\mathrm{KL}(\mathcal N(\mu,\sigma^2),\mathcal N(\mu',\sigma'^2))=
   \tfrac12\big(\log\tfrac{\sigma'^2}{\sigma^2}+\tfrac{\sigma^2+(\mu-\mu')^2}{\sigma'^2}-1\big)$.

Generalization: arbitrary models and answer types, multiple correct answers and observations in any
measurable space, where [GK16, DK19] use vectors of means in one exponential family and finitely
many answers.

## Layer 2: Change of measure and lower bounds

1. **Divergence decomposition at a stopping time.**
   - For two runs of the same identification algorithm in `stationaryEnv ν` and `stationaryEnv ν'`
     on finite arms, with $\tau$ almost surely finite under the first run, prove
     $\mathrm{KL}(\text{law of the stopped history under }\nu,\text{ under }\nu')
     \le\sum_a\mathbb E_\nu[N_a(\tau)]\,\mathrm{KL}(\nu_a,\nu'_a)$, with equality when $\tau$ is also
     almost surely finite under $\nu'$.
   - Prove the same bound for the joint law of the stopped history and the output: the output
     kernel is common (Mathlib's `klDiv_compProd_left`).
   - The fixed-horizon case is LML's `IsAlgEnvSeq.klDiv_map_history`.
2. **Transportation lemma** [KCG16, Lemma 1].
   - Prove the data-processing inequality
     $\mathrm{kl}(P(E),Q(E))\le\mathrm{KL}(P,Q)$ for measurable $E$, with `klBer`, from Mathlib's
     `klDiv_map_le`.
   - Deduce
     $\sum_a\mathbb E_\nu[N_a(\tau)]\,\mathrm{KL}(\nu_a,\nu'_a)\ge
     \mathrm{kl}(P_\nu(E),P_{\nu'}(E))$ for every event $E$ of the stopped history and the output,
     by data processing from Layer 2.1 as in [GMS19]. No mutual absolute continuity is assumed: the
     inequality holds in `ℝ≥0∞`.
3. **Fixed-confidence lower bounds.**
   - For a single-answer task and a $\delta$-correct algorithm with $\delta\in(0,1/2)$, prove
     $\mathbb E_\theta[\tau]\ge T^*(\theta)\,\mathrm{kl}(\delta,1-\delta)$ for every
     $\theta\in M$ [GK16, Theorem 1].
   - Prove $\mathrm{kl}(\delta,1-\delta)\ge\log\frac1{2.4\delta}$ [KCG16], and the
     Bretagnolle–Huber variant $\mathbb E_\theta[\tau]\ge T^*(\theta)\log\frac1{4\delta}$
     [LS, Theorem 33.5].
   - Prove the allocation form: the normalized expected counts
     $\big(\mathbb E_\theta[N_a(\tau)]/\mathbb E_\theta[\tau]\big)_a$ satisfy
     $\mathbb E_\theta[\tau]\,D(\theta,w,\neg i^*(\theta))\ge\mathrm{kl}(\delta,1-\delta)$.
   - For multiple-answer tasks with finitely many answers, prove
     $\liminf_{\delta\to0}\mathbb E_\theta[\tau_\delta]/\log(1/\delta)\ge T^*(\theta)$ for every
     family of $\delta$-correct algorithms [DK19, Theorem 1, Proposition 18, Lemma 19], in the
     eventual form of the Conventions.
4. **Fixed-budget lower bounds.**
   - For two models $\theta,\lambda$ without a common correct answer and an algorithm with budget
     $T$, prove
     $P_\theta(\text{error})+P_\lambda(\text{error})\ge\tfrac12\exp\!\big(-\sum_a\mathbb
     E_\theta[N_a(T)]\,\mathrm{KL}(\nu_a(\theta),\nu_a(\lambda))\big)$ (Bretagnolle–Huber).
   - Prove its consequence: some model of every finite family has error at least
     $\tfrac14\exp(-T\max_a\mathrm{KL})$.
   - The minimax lower bounds of Layer 8.4 build on this.

Generalization: arbitrary tasks and observation spaces, where [KCG16, GK16] treat best arm
identification in exponential families.

## Layer 3: The pure exploration game

1. **Transportation costs.**
   - Define the quantities of the Conventions and the set $w^*(\theta,\neg i)$ of optimal
     allocations.
   - Prove that $w\mapsto D(\theta,w,\neg i)$ is concave and positively homogeneous on
     $[0,\infty)^\alpha$ and monotone (antitone in the alternative set), so $w^*(\theta,\neg i)$ is
     convex.
   - Prove that the value is $0$ when $\theta\in\neg i$, and that $T^*(\theta)<\infty$ iff some
     correct answer has alternatives at positive cost for some allocation.
   - Prove measurability of $(\theta,w)\mapsto D(\theta,w,\neg i)$ for vectors of means with
     continuous divergences (an infimum of continuous functions).
2. **Game and minimax forms.**
   - Prove $D(\theta,\neg i)=\inf_{q}\max_a\mathbb E_{\lambda\sim q}[\mathrm{KL}(\nu_a(\theta),
     \nu_a(\lambda))]$ over finitely supported distributions $q$ on $\neg i$ [DK19, Lemma 2;
     DKM19, Section 2], from Mathlib's `Sion.minimax` on the simplex.
   - Prove $T^*(\theta)^{-1}=\max_{i\in i^*(\theta)}D(\theta,\neg i)$, the characteristic-time
     identity of multiple-answer tasks.
3. **Continuity** [DK19, Appendix F].
   - Prove Berge's maximum theorem for upper hemicontinuous compact-valued correspondences, in the
     generality of [DK19, Theorems 22–23], from Mathlib's `IsCompact.continuous_sSup`/`continuous_sInf`.
   - For vectors of means with continuous divergences, deduce:
     - continuity of $(\theta,w)\mapsto D(\theta,w,\neg i)$ on positive allocations when
       $\neg i$ is compact or under [DK19, Lemma 25]'s conditions;
     - continuity of $\theta\mapsto D(\theta,\neg i)$ and of $D(\theta)$;
     - upper hemicontinuity with compact convex values of $\theta\mapsto w^*(\theta,\neg i)$;
     - upper hemicontinuity of the oracle answers $i_F(\theta)=\operatorname{argmax}_i
       D(\theta,\neg i)$ and of $w^*(\theta)=\bigcup_{i\in i_F(\theta)}w^*(\theta,\neg i)$
       [DK19, Theorem 4, Lemmas 24–30].
   - Prove the convexity of $w^*(\theta,\neg i)$ and give a model where $w^*(\theta)$ is not
     convex [DK19, Proposition 5].
4. **Best arm identification in exponential families** [GK16, Section 2].
   - Prove that $D(\mu,w,\neg a^*)=\min_{b\ne a^*}\big(w_{a^*}d(\mu_{a^*},m)+w_bd(\mu_b,m)\big)$
     with $m$ the $w$-weighted mean of $\mu_{a^*}$ and $\mu_b$ [GK16, Lemma 3].
   - Prove that $w^*(\mu)$ is a singleton with positive entries equalizing the transportation
     costs [GK16, Lemma 4]. Prove its characterization through the scalar equation of
     [GK16, Theorem 5], and its continuity in $\mu$ [GK16, Proposition 6].
   - Prove the Gaussian bounds $H(\mu)\le T^*(\mu)\le 2H(\mu)$ with
     $H(\mu)=\sum_a2\sigma^2/\Delta_a^2$ and $\Delta_{a^*}=\min_{b\ne a^*}\Delta_b$
     [GK16, Section 2.2].
   - Prove the two-armed values: $T^*(\mu)^{-1}=d(\mu_1,z^*)=d(\mu_2,z^*)$ for the $z^*$ between
     the two means at which these divergences are equal [KCG16, Section 3, Theorem 6], and in
     particular $T^*(\mu)=8\sigma^2/\Delta^2$ with $w^*=(\tfrac12,\tfrac12)$ for Gaussian arms
     with a common variance.
5. **Top Two allocations.**
   - Define the $\beta$-optimal allocations: maximize $D(\theta,w,\neg i^*)$ under $w_{a^*}=\beta$,
     with value $T^*_\beta(\theta)^{-1}$ [R16; JDBdHK22].
   - Prove $T^*_{1/2}(\theta)\le2T^*(\theta)$, uniqueness of the $\beta$-optimal allocation for
     best arm identification in exponential families, and its equalization property.
6. **Closed forms for Gaussian tasks.** Prove the divergences to half-spaces, to minimum-threshold
   sets and to spheres for Gaussian arms [DK19, Lemmas 36–39]. Prove the characteristic time
   $\sum_a 2\sigma^2/(\mu_a-\gamma)^2$ of Gaussian thresholding.

Generalization: arbitrary models and divergences in `ℝ≥0∞`, where [GK16] works with exponential
families and real divergences.

## Layer 4: Deviation inequalities and GLR stopping rules

1. **Empirical means along a run.**
   - Define the per-arm sums, counts and empirical means of a run (from LML's `SumRewards`), and
     the sum-count statistic of a history.
   - Transfer statements about the i.i.d. reward stream of an arm to its empirical mean after each
     number of pulls, as in the Bandits roadmap's Layer 1.3.
2. **Deviation inequalities for exponential families.**
   - Prove the per-arm time-uniform bound
     $P\big(\exists t,\ N_a(t)\,d(\hat\mu_a(t),\mu_a)\ge x+c\log(1+\log N_a(t))\big)$ for the
     constants of [KK21] (from Ville's inequality and mixtures of tilted supermartingales).
   - Prove the joint bound for any set $S$ of arms and any sampling rule,
     $P\big(\exists t,\ \sum_{a\in S}\big[N_a(t)\,d(\hat\mu_a(t),\mu_a)-3\log(1+\log N_a(t))\big]^+
     \ge|S|\,\mathcal C^{\exp}(x/|S|)\big)\le e^{-x}$ [KK21, Theorem 7]. Here
     $\mathcal C^{\exp}$ is defined through the inverse of $u\mapsto u-\log u$ on $[1,\infty)$
     (a branch of the Lambert function). Build that inverse and the estimate
     $\mathcal C^{\exp}(x)=x+O(\log(1+x))$ with explicit constants.
   - Deduce the threshold $\beta(t,\delta)=3\sum_a\log(1+\log N_a(t))+K\,\mathcal C^{\exp}
     (\log(1/\delta)/K)$ for general identification [KK21, Proposition 15].
   - Prove the union-bound thresholds of [GK16, Proposition 12] ($\log(Ct^\alpha/\delta)$, $\alpha>1$,
     with an explicit $C(\alpha,K)$), of [GK16, Theorem 10] (Bernoulli arms only,
     $\log(2t(K-1)/\delta)$, through the Krichevsky–Trofimov mixture of [GK16, Lemma 11]) and of
     [LS, Lemmas 33.7–33.8, Proposition 33.9], and the uniform deviation bound of [MCP14] used by
     [DK19, Lemma 32].
3. **GLR statistics and stopping rules.**
   - Define the GLR statistic of an answer,
     $\mathrm{GLR}_t(\neg i)=\inf_{\lambda\in\neg i}\sum_aN_a(t)\,d(\hat\mu_a(t),\lambda_a)
     =t\,D(\hat\mu(t),N(t)/t,\neg i)$, its measurability, and the GLRT stopping and recommendation
     rules with thresholds $\beta(t,\delta)$ on top of any sampling rule.
   - Prove that if $\beta$ satisfies $P_\mu(\exists t,\ \sum_aN_a(t)d(\hat\mu_a(t),\mu_a)>\beta(t,\delta))
     \le\delta$, then the GLRT rules are $\delta$-correct on every task, for every sampling rule
     [GK16, Proposition 12; DKM19, Theorem 1; DK19, Theorem 10].
4. **Generic sample-complexity reductions.**
   - Asymptotic: if, on events $E_T$ with $\sum_TP(E_T^c)<\infty$, the statistic
     $\mathrm{GLR}_t(\neg i^*)$ exceeds $t\,(T^*(\mu)^{-1}-\varepsilon)$ for $\sqrt T\le t\le T$, then
     $\limsup_{\delta\to0}\mathbb E[\tau_\delta]/\log(1/\delta)\le(T^*(\mu)^{-1}-\varepsilon)^{-1}$
     for every threshold with $\beta(t,\delta)\le\log(Ct^\alpha/\delta)$ [GK16, proof of
     Theorem 14].
   - Non-asymptotic:
     $\mathbb E[\tau]\le T_0(\delta)+\sum_tP(E_t^c)$ where $T_0(\delta)$ solves the stopping
     inequality [DKM19, Lemmas 1–2; DK19, Lemma 13].
   - State both for arbitrary tasks, so that each sampling rule below only proves the convergence
     of its allocations.
5. **Unknown variances.** For the Gaussian model with unknown variances (Layer 1.3), prove that
   the cost of the alternatives with a common mean $\lambda$ for two arms is
   $\sum_c\frac{w_c}2\log\big(1+\frac{(\mu_c-\lambda)^2}{\sigma_c^2}\big)$, define the GLR statistic,
   and prove the $\delta$-correctness of its stopping rule with the thresholds of [JDK23a]. The
   lower bound of this model is Layer 2.3.

Generalization: arbitrary tasks with exponential-family arms, where [GK16] treats best arm
identification.

## Layer 5: Tracking and asymptotically optimal sampling rules

1. **Tracking.**
   - Prove the guarantees of C-tracking ($|N_a(t)-\sum_{s<t}w_a(s)|\le K(1+\sqrt t)$ for the
     $\varepsilon_t$-projected targets) and D-tracking ($N_a(t)\ge(\sqrt t-K/2)_+-1$, and
     convergence of the proportions when the targets converge) [GK16, Lemmas 7, 8, 15, 17, 20,
     Proposition 9].
   - Prove cumulative tracking [DKM19, Lemma 7].
   - Prove the concentration of the empirical means under forced exploration
     [GK16, Lemma 19].
2. **Track-and-Stop.**
   - Define Track-and-Stop (C- or D-tracking of a measurable selection of $w^*(\hat\mu)$, GLRT
     stopping) for single-answer tasks with exponential-family arms.
   - Prove that it is $\delta$-PAC with the thresholds of Layer 4.2 and asymptotically optimal on
     every single-answer task: with C-tracking whenever $w^*(\mu)$ is convex, in particular when it
     is unique [DK19, Lemma 6, Theorem 7]; with D-tracking when $w^*(\mu)$ is a singleton and
     continuous at $\mu$. For best arm identification this is
     $\limsup_{\delta\to0}\mathbb E_\mu[\tau_\delta]/\log(1/\delta)\le\alpha T^*(\mu)$ for
     $\beta(t,\delta)=\log(r(t)/\delta)$, $r(t)=O(t^\alpha)$, $\alpha\in[1,e/2]$
     [GK16, Theorem 14]; also prove the almost-sure version [GK16, Proposition 13].
   - Prove that for multiple answers Track-and-Stop reaches only
     $\max_{w\in\mathrm{conv}\,w^*(\mu)}D(\mu,w)^{-1}$ [DK19, Theorems 7, 9].
3. **Sticky Track-and-Stop** [DK19, Algorithm 1].
   - Define the sticky answer: the least oracle answer of a model of a small confidence region,
     for a fixed linear order on $\mathcal I$.
   - Prove that Sticky Track-and-Stop is $\delta$-correct and asymptotically optimal on every
     multiple-answer task with finitely many answers and continuous divergences
     [DK19, Theorems 10–11, Corollary 12, Lemmas 13–17].

Generalization: arbitrary tasks, where [GK16] treats best arm identification.

## Layer 6: Game-based, Top Two and Frank–Wolfe sampling rules

1. **AdaHedge.**
   - Define AdaHedge (exponential weights with the learning rate tuned by the cumulative
     mixability gap) on a finite set.
   - Prove its regret bound for losses with per-round ranges
     $b_t=\max_k\ell_t^k-\min_k\ell_t^k$, with no prior knowledge of the ranges:
     $R_T\le\sqrt{\sum_{t<T}b_t^2\log K}+\max_{t<T}b_t\,\big(\tfrac43\log K+2\big)$
     [dRvEGK14; DKM19, Lemma 3].
   - Prove the regret bound of Follow-the-Perturbed-Leader with the perturbations of
     [DKM19, Theorem 3].
2. **Pure exploration by solving games** [DKM19].
   - Define the meta-algorithm: the candidate answer from a confidence region, a $w$-player and a
     $\lambda$-player fed optimistic gains, cumulative tracking, and GLRT stopping.
   - Prove the non-asymptotic bound $\mathbb E_\mu[\tau_\delta]\le T_0(\delta)+2eK/a^2$ in terms of
     the learners' regrets [DKM19, Theorem 2], its instance with AdaHedge against Best-Response
     [DKM19, Lemma 3], and Optimistic Track-and-Stop [DKM19, Lemma 4].
   - Deduce asymptotic optimality.
3. **Top Two algorithms.**
   - Define the Top Two sampling rule with a leader (empirical best, Thompson sample or UCB), a
     challenger minimizing the transportation cost, and a fixed $\beta\in(0,1)$ (or $\beta=1/2$
     with tracking) [R16; JDBdHK22].
   - Prove the generic reduction of [QKR17, Theorem 3] and [JDBdHK22]: a leader that is correct
     except with probability $o(n^{-\alpha})$ and a challenger that avoids over-sampled arms give
     convergence to the $\beta$-optimal allocation, hence, with GLR stopping,
     $\limsup_{\delta\to0}\mathbb E_\mu[\tau_\delta]/\log(1/\delta)\le T^*_\beta(\mu)$.
   - Prove asymptotic $\beta$-optimality for Gaussian arms of TTTS and T3C [SdHMKV20, Theorem 1]
     and of the empirical-best leader with the transportation-cost challenger.
   - Prove the results of TTUCB, the UCB-leader Top Two algorithm with tracking: asymptotic
     $\beta$-optimality and its non-asymptotic bound, valid for every $\delta$ and every instance
     with a unique best arm [JD23, Theorems 2.3–2.4].
4. **$\varepsilon$-best arm identification for all confidence levels.** Define EB-TC$_\varepsilon$
   (fixed $\beta$ or information-directed selection) and prove its asymptotic optimality for
   Gaussian $\varepsilon$-best arm identification, its non-asymptotic sample complexity and its
   anytime bound on the probability of error [JDK23b, Theorems 1–3].
5. **Frank–Wolfe sampling.** For tasks whose alternative sets are finite unions of convex sets,
   define Frank–Wolfe sampling (one Frank–Wolfe step on the $r$-subdifferential of
   $w\mapsto D(\hat\mu,w,\neg\hat i)$ per round, with forced exploration) and prove that it is
   $\delta$-PAC and asymptotically optimal, almost surely and in expectation [WTP21, Theorem 1].

## Layer 7: Elimination and confidence-bound algorithms

1. **Successive elimination** [EMM02, Theorem 3; EMM06, Theorem 8]. For σ²-sub-Gaussian arms, define successive elimination
   with the time-uniform confidence intervals of the Bandits roadmap's Layer 1.2. Prove that it is
   $\delta$-PAC for best arm identification and that, with probability at least $1-\delta$, it stops
   after at most $\sum_a c\,\sigma^2\Delta_a^{-2}\log(K/(\delta\Delta_a))$ samples, with the explicit
   constant of the proof.
2. **Median elimination** [EMM02, Theorem 4; EMM06, Theorem 10]. Define median elimination and prove that it is
   $(\varepsilon,\delta)$-PAC (outputs an $\varepsilon$-best arm with probability at least
   $1-\delta$) with at most $c\,K\varepsilon^{-2}\log(1/\delta)$ samples for σ²-sub-Gaussian arms,
   with the explicit constant.
3. **LUCB and KL-LUCB** [KTAS12; KK13]. Define LUCB and KL-LUCB for top-$m$ identification with
   tolerance $\varepsilon$.
   - Prove that their stopping rule is correct for every sampling rule under the condition on the
     exploration rate of [KTAS12, Theorem 1].
   - Prove $\mathbb E[\tau]<292\,H^{\varepsilon/2}\log(H^{\varepsilon/2}/\delta)+16$ for LUCB1 with
     $H^\gamma=\sum_a\max(\Delta_a,\gamma)^{-2}$ [KTAS12, Theorem 6].
   - Prove the bound of KL-LUCB in terms of the Chernoff-information complexity $H^*_\varepsilon$
     [KK13, Theorem 3].
4. **PAC lower bound** [MT04, Theorem 1]. From Layer 2.3, prove that every
   $(\varepsilon,\delta)$-PAC algorithm for Bernoulli arms has, on some model,
   $\mathbb E[\tau]\ge c_1K\varepsilon^{-2}\log(c_2/\delta)$, with the explicit constants obtained.
   Prove the top-$m$ lower bound
   $\mathbb E[\tau]\ge\big[\sum_{a\in S^*}\mathrm{KL}(\nu_a,\nu_{[m+1]})^{-1}+\sum_{a\notin S^*}
   \mathrm{KL}(\nu_a,\nu_{[m]})^{-1}\big]\log\frac1{2.4\delta}$ [KCG16, Theorem 4].

## Layer 8: Fixed-budget identification

1. **Successive rejects** [ABM10]. Prove
   $P(\text{error})\le\frac{K(K-1)}2\exp\!\big(-\frac{T-K}{\overline{\log}(K)H_2}\big)$ for rewards
   in $[0,1]$, with $\overline{\log}(K)=\frac12+\sum_{i=2}^K\frac1i$, $\Delta_{(1)}\le\dots\le
   \Delta_{(K)}$ the gaps in increasing order with $\Delta_{(1)}=\Delta_{(2)}$, and
   $H_2=\max_ii\,\Delta_{(i)}^{-2}$ [ABM10]. Prove $H_2\le H_1\le\overline{\log}(2K)H_2$ for
   $H_1=\sum_i\Delta_{(i)}^{-2}$.
2. **Sequential halving** [KKS13]. Prove
   $P(\text{error})\le3\log_2K\exp\!\big(-\frac{T}{8H_2\log_2K}\big)$ [KKS13] for rewards in
   $[0,1]$ ([LS, Theorem 33.10] proves it for 1-sub-Gaussian rewards with $16$ in place of $8$;
   state the σ²-sub-Gaussian version).
3. **Large deviations under static allocations.**
   - For independent samples of exponential-family arms with fixed proportions $w$, prove the
     large deviation upper and lower bounds for the vector of empirical means (Cramér's theorem
     for each arm, from the Cramér–Chernoff bound and an exponential tilting lower bound).
   - Deduce that the static-proportions algorithm recommending $i^*(\hat\mu)$ has error
     exponent $\inf_{\lambda\in\neg i^*(\mu)}\sum_aw_a\,d(\lambda_a,\mu_a)$ (alternative first)
     [GJ04; D23, Theorems 1, 12].
   - For two arms, deduce that the best static exponent is the Chernoff information
     $d(z,\mu_1)=d(z,\mu_2)$, and prove the matching lower bound for consistent algorithms
     [KCG16, Theorems 12–13].
4. **Lower bounds.**
   - Prove the minimax lower bound of [CL16] for best arm identification with Gaussian
     (or Bernoulli) arms: over a family of problems with complexity $H$, every algorithm with
     budget $T$ errs with probability at least $\frac16\exp\!\big(-\frac{400T}{H\log K}\big)$ on one
     of them, with the paper's constants.
   - Prove the results of [D23] on the existence of a complexity:
     - the non-asymptotic and asymptotic lower bounds on the difficulty ratio (Theorems 2–3,
       Corollary 4);
     - the ratio of static-proportions algorithms (Theorem 5, at most $K$, attained by the
       positivity task, Theorem 6);
     - tasks with a flat boundary (Theorem 7);
     - the absence of a complexity for Gaussian best arm identification with $K$ large
       (Theorem 8) and for two Bernoulli arms (Theorem 10).

## Layer 9: Linear identification

1. **Linear tasks.** For a finite-dimensional real inner product space `E`, features
   `φ : α → E`, a finite set `𝒵` of answers in `E` and noise σ²-sub-Gaussian or Gaussian, define
   the linear model $\theta\in E$ with arm means $\langle\varphi(a),\theta\rangle$ and the
   transductive best-answer task $\operatorname{argmax}_{z\in\mathcal Z}\langle z,\theta\rangle$
   [FJJR19]; best arm identification is the case $\mathcal Z=\varphi(\alpha)$.
2. **Characteristic time.** For Gaussian noise, prove
   $T^*(\theta)^{-1}=\max_{w\in\Delta_K}\min_{z\ne z^*}
   \frac{\langle\theta,z^*-z\rangle^2}{2\sigma^2\|z^*-z\|^2_{V_w^{-1}}}$ with
   $V_w=\sum_aw_a\varphi(a)\varphi(a)^\top$ (the Bandits roadmap's `designOperator`), with the
   pseudo-inverse convention when $V_w$ is singular, equivalently
   $\max_w\inf_{\lambda\in\neg z^*}\frac1{2\sigma^2}\|\theta-\lambda\|^2_{V_w}$
   [FJJR19, Theorem 1; DMSV20; JP20]. Compare it with the G-optimal and $\mathcal X\mathcal Y$
   allocations of [SLM14].
3. **Elimination with optimal designs.** Define RAGE (phased elimination with
   $\mathcal X\mathcal Y$-optimal designs and rounding) and prove that it is $\delta$-PAC with
   sample complexity $O\big(\psi^*\log(1/\Delta_{\min})\log(|\mathcal Z|^2\log^2(1/\Delta_{\min})/\delta)\big)$,
   $\psi^*=2\sigma^2T^*(\theta)$ [FJJR19, Theorem 2]. Build the rounding of designs it uses.
4. **GLRT and asymptotically optimal algorithms.**
   - Prove the $\delta$-correctness of the GLRT stopping rule of the linear model with the
     self-normalized threshold of the Bandits roadmap's Layer 8.4.
   - Prove the asymptotic optimality of LinGame [DMSV20] and of lazy Track-and-Stop
     [JP20], almost surely and in expectation.

## Completion checks

Every new definition comes with measurability, evaluation and extensionality lemmas, and every
algorithm with its run lemma and its construction as an `IdentAlg`, so that the theorems apply to
all runs. Check in particular:
- **Two-armed Gaussian best arm identification:** $T^*=8\sigma^2/\Delta^2$, $w^*=(\tfrac12,\tfrac12)$,
  and Track-and-Stop attains $T^*$ asymptotically.
- **Best arm identification with one arm:** trivial; every algorithm that stops immediately is
  $0$-correct and $T^*=0$.
- **Lower bound versus upper bounds:** the lower bound of Layer 2.3 matches Track-and-Stop
  (Layer 5.2), Sticky Track-and-Stop (Layer 5.3) and the game-based algorithm (Layer 6.2) on their
  common tasks, and $T^*_{1/2}\le2T^*$ (Layer 3.5) bounds the loss of Top Two.
- **Generality of the general statements:** the GLRT $\delta$-correctness theorem of Layer 4.3
  applies to best arm identification, top-$m$, thresholding and Any Low Arm (Layer 1.1) without
  task-specific proofs.
- **Fixed budget:** the fixed-budget lower bound of Layer 8.4 and the upper bounds of
  Layers 8.1–8.2 agree up to the $\log K$ factors stated.

Compilation of the suggested signatures checks their types, not the truth of their admitted
theorems or the completion of these milestones.

## References

T. Lattimore and Cs. Szepesvári, *Bandit Algorithms*, Cambridge University Press (2020),
Chapter 33, is the textbook account [LS] (Theorem 33.5 for the lower bound, Theorem 33.6 for
Track-and-Stop, Lemmas 33.7–33.8 for GLR thresholds, Theorem 33.10 for sequential halving).

- [ABM10] J.-Y. Audibert, S. Bubeck and R. Munos, *Best arm identification in multi-armed bandits*,
  COLT 2010.
- [C59] H. Chernoff, *Sequential design of experiments*, Ann. Math. Statist. 30 (1959), the origin
  of the GLR stopping rule and of the game that defines the characteristic time.
- [CL16] A. Carpentier and A. Locatelli, *Tight (lower) bounds for the fixed budget best arm
  identification bandit problem*, COLT 2016.
- [D23] R. Degenne, *On the existence of a complexity in fixed budget bandit identification*,
  COLT 2023.
- [DK19] R. Degenne and W. M. Koolen, *Pure exploration with multiple correct answers*,
  NeurIPS 2019.
- [DKM19] R. Degenne, W. M. Koolen and P. Ménard, *Non-asymptotic pure exploration by solving
  games*, NeurIPS 2019.
- [DMSV20] R. Degenne, P. Ménard, X. Shang and M. Valko, *Gamification of pure exploration for
  linear bandits*, ICML 2020.
- [dRvEGK14] S. de Rooij, T. van Erven, P. D. Grünwald and W. M. Koolen, *Follow the leader if you
  can, hedge if you must*, JMLR 15 (2014).
- [EMM02] E. Even-Dar, S. Mannor and Y. Mansour, *PAC bounds for multi-armed bandit and Markov
  decision processes*, COLT 2002.
- [EMM06] E. Even-Dar, S. Mannor and Y. Mansour, *Action elimination and stopping conditions for
  the multi-armed bandit and reinforcement learning problems*, JMLR 7 (2006).
- [FJJR19] T. Fiez, L. Jain, K. Jamieson and L. Ratliff, *Sequential experimental design for
  transductive linear bandits*, NeurIPS 2019.
- [GMS19] A. Garivier, P. Ménard and G. Stoltz, *Explore first, exploit next: the true shape of
  regret in bandit problems*, Math. Oper. Res. 44 (2019).
- [GJ04] P. Glynn and S. Juneja, *A large deviations perspective on ordinal optimization*, Winter
  Simulation Conference 2004.
- [GK16] A. Garivier and E. Kaufmann, *Optimal best arm identification with fixed confidence*,
  COLT 2016.
- [JD23] M. Jourdan and R. Degenne, *Non-asymptotic analysis of a UCB-based top two algorithm*,
  NeurIPS 2023.
- [JDBdHK22] M. Jourdan, R. Degenne, D. Baudry, R. de Heide and E. Kaufmann, *Top two algorithms
  revisited*, NeurIPS 2022.
- [JDK23a] M. Jourdan, R. Degenne and E. Kaufmann, *Dealing with unknown variances in best-arm
  identification*, ALT 2023.
- [JDK23b] M. Jourdan, R. Degenne and E. Kaufmann, *An ε-best-arm identification algorithm for
  fixed-confidence and beyond*, NeurIPS 2023.
- [JP20] Y. Jedra and A. Proutière, *Optimal best-arm identification in linear bandits*,
  NeurIPS 2020.
- [KCG16] E. Kaufmann, O. Cappé and A. Garivier, *On the complexity of best-arm identification in
  multi-armed bandit models*, JMLR 17 (2016).
- [KK13] E. Kaufmann and S. Kalyanakrishnan, *Information complexity in bandit subset selection*,
  COLT 2013.
- [KK21] E. Kaufmann and W. M. Koolen, *Mixture martingales revisited with applications to
  sequential tests and confidence intervals*, JMLR 22 (2021).
- [KKS13] Z. Karnin, T. Koren and O. Somekh, *Almost optimal exploration in multi-armed bandits*,
  ICML 2013.
- [KTAS12] S. Kalyanakrishnan, A. Tewari, P. Auer and P. Stone, *PAC subset selection in
  stochastic multi-armed bandits*, ICML 2012.
- [MCP14] S. Magureanu, R. Combes and A. Proutière, *Lipschitz bandits: regret lower bounds and
  optimal algorithms*, COLT 2014.
- [MT04] S. Mannor and J. N. Tsitsiklis, *The sample complexity of exploration in the multi-armed
  bandit problem*, JMLR 5 (2004).
- [QKR17] C. Qin, D. Klabjan and D. Russo, *Improving the expected improvement algorithm*,
  NeurIPS 2017.
- [R16] D. Russo, *Simple Bayesian algorithms for best arm identification*, COLT 2016; Operations
  Research 68 (2020).
- [SdHMKV20] X. Shang, R. de Heide, P. Ménard, E. Kaufmann and M. Valko, *Fixed-confidence
  guarantees for Bayesian best-arm identification*, AISTATS 2020.
- [SLM14] M. Soare, A. Lazaric and R. Munos, *Best-arm identification in linear bandits*,
  NeurIPS 2014.
- [WTP21] P.-A. Wang, R.-C. Tzeng and A. Proutière, *Fast pure exploration via Frank–Wolfe*,
  NeurIPS 2021.
