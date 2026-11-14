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
- identification tasks with arbitrary models, answer sets and multiple correct answers, asking
  about the arm means through a mean functional;
- product models and their $\mathrm K_{\inf}$ transportation costs;
- exponential families with a real or vector sufficient statistic, on any measurable space, and
  the Cramér–Chernoff rate function;
- the change of measure at stopping times, for any two algorithm-environment pairs;
- transportation costs and their continuity (Berge's maximum theorem, with non-compact
  alternatives; Sion's minimax theorem);
- conditional domination of moment generating functions, exponential supermartingales,
  generalized likelihood ratio statistics and their time-uniform deviation inequalities;
- tracking lemmas, a generic sample-complexity reduction, a phased-elimination template,
  AdaHedge;
- large deviations of empirical means under static allocations.

`README.md` is the definitive specification; `Suggested.lean` records selected interfaces and is
not an exhaustive checklist.

Suggested homes: `LMLExplore/Identification/` for identification material (namespace
`LMLExplore.Identification`), and the mathematical home of each general tool (for example
`LMLExplore/Probability/Distributions/ExponentialFamily/` for exponential families,
`LMLExplore/Probability/Moments/` for rate functions and bounds on moment generating functions,
`LMLExplore/Probability/Martingale/` for exponential supermartingales,
`LMLExplore/Probability/LargeDeviations/` for Cramér-type bounds,
`LMLExplore/SequentialLearning/` for the change of measure and the run-to-stream transfer,
`LMLExplore/Topology/Semicontinuous/` for Berge's maximum theorem, `LMLExplore/OnlineLearning/` for
AdaHedge).

## Scope and dependencies

This roadmap owns identification in stochastic bandits with a finite set of arms (pure
exploration): fixed-confidence and fixed-budget identification for arbitrary identification
tasks, with single or multiple correct answers, in unstructured models and in linear models.
It also owns three sequential-learning tools that the Bandits and ReinforcementLearning roadmaps
build on: the chain rule for the divergence of stopped histories (Layer 2.1), the transfer from
runs to the per-arm observation streams (Layer 4.1), and conditional domination of moment
generating functions with its exponential supermartingales (Layer 4.2).

| Material | Owner and interface consumed here |
| --- | --- |
| Interaction protocol, runs, trajectory measure, stationary environments | LML `SequentialLearning/`: `Algorithm`, `Environment`, `IsAlgEnvSeq`, `trajMeasure`, `stationaryEnv`, `stepKernel`, `IsAlgEnvSeq.filtrationAction` |
| Identification algorithms: sampling, stopping and output rules, stopping time, stopped history, law of the output, PAC property | LML `SequentialLearning/IdentificationAlg.lean` (`IdentAlg`, `IdentAlg.stoppingTime`, `IdentAlg.stoppedHist`, `IdentAlg.outputMeasure`, `IdentAlg.IsRun`, `IdentAlg.IsPAC`), `SequentialLearning/StoppedHistory.lean` (`sigmaHistory`, `stoppedHistMeasure`); LMLExplore `SequentialLearning/StoppedHistory.lean` (`Learning.notStoppedSet`, `Learning.stoppedHistMeasure_congr`) |
| Pull counts, reward sums, empirical means, per-arm reward streams | LML `SequentialLearning/FiniteActions.lean` (`pullCount`, `rewardByCount`), `SumRewards.lean`, `Online/Bandit/ArrayProbSpace.lean` (`streamMeasure`); LMLExplore `SequentialLearning/SumRewards.lean` |
| Conditional means of the feedback and their martingale | LML `SequentialLearning/Means.lean` (`Environment.means`, `IsAlgEnvSeq.condExp_feedback`), `FeedbackMartingale.lean` (`noiseSum`, `IsAlgEnvSeq.martingale_noiseSum`) |
| KL divergence of histories at a fixed horizon | LML `SequentialLearning/DivergenceDecomposition.lean` (`IsAlgEnvSeq.klDiv_map_history_stepKernel`, for any two algorithm-environment pairs); LMLExplore `Learning.IsAlgEnvSeq.klDiv_map_history_eq_sum_pullCount`, `Learning.klDiv_stoppedHistMeasure_le` |
| Binary relative entropy, Bretagnolle–Huber, Ville's inequality, mixtures of supermartingales, time-uniform sub-Gaussian bounds, Chernoff bounds in relative-entropy form | LMLExplore (Bandits roadmap, Layers 0.2, 1 and 4): `klBer`, `klBerReal`, `exp_neg_klDiv_div_two_le`, `MeasureTheory.Supermartingale.measure_exists_le_le`, `supermartingale_integral_of_integrable`, `supermartingale_exp_sum_mul_of_hasCondSubgaussianMGF`, `measureReal_sum_ge_le_exp_klBerReal` |
| Sub-Gaussian and sub-exponential random variables, unconditional and conditional | Mathlib `Probability/Moments/SubGaussian.lean` (`HasSubgaussianMGF`, `Kernel.HasSubgaussianMGF`, `HasCondSubgaussianMGF`), LML `ForMathlib/Probability/Moments/SubExponential.lean` (`HasSubexponentialMGF`, `HasCondSubexponentialMGF`); LMLExplore `Probability/Moments/MGF/Dominated.lean` (`MGFDominatedOn`) |
| Design operators, self-normalized bounds, G-optimal designs | Bandits roadmap, Layer 8 (`designOp`, the design operator $V(\pi)$ of a design, the self-normalized bound, the Kiefer–Wolfowitz theorem); Tau Ceti `Analysis/InnerProductSpace/Frame.lean` (`frameOperator`) |
| Exponential weights, regret of online linear optimization | Bandits roadmap, Layer 6 |
| KL divergence, chain rule, data processing, exponential tilting, cumulant generating functions | Mathlib `InformationTheory/KullbackLeibler/`, `MeasureTheory/Measure/Tilted.lean`, `MeasureTheory/Measure/LogLikelihoodRatio.lean`, `Probability/Moments/` (`cgf`, `integrableExpSet`, `deriv_cgf`, `iteratedDeriv_two_cgf`) |
| Tilts and transforms of standard laws | Tau Ceti `Probability/Distributions/Tilted.lean` (`gammaMeasure_tilted_mul`, `gaussianReal_tilted_mul`, `poissonMeasure_tilted_mul`), `Probability/Distributions/Gaussian/ChiSquared.lean` (`gaussianReal_map_sq`) |
| Fenchel conjugates, Bregman divergences | Tau Ceti `Analysis/Convex/Conjugate.lean` (`fenchelConjugate`, for a bilinear pairing), LML `ForMathlib/Analysis/Convex/Bregman/Basic.lean` (`bregDiv`) |
| Minimax theorems, continuity of suprema over compact sets | Mathlib `Topology/Sion.lean` (`Sion.minimax`, `Sion.exists_isSaddlePointOn`), Tau Ceti `Topology/Sion.lean`, Mathlib `Topology/Order/Compact.lean` (`IsCompact.continuous_sSup`, `IsCompact.continuous_sInf`) |

Build missing material in this roadmap where it is listed as a target, and consume existing
implementations directly. The Bandits roadmap and this one do not overlap: regret minimization,
the fixed-horizon divergence decomposition and the binary relative entropy belong to the Bandits
roadmap. The change of measure at stopping times, exponential families and everything specific to
identification belong here, and so do three general sequential-learning tools: the chain rule at
a stopping time for any two algorithm-environment pairs, the transfer of events about the
observations of each arm from runs to the per-arm streams (whose single-arm form for real rewards
the Bandits roadmap's Layer 1.3 uses), and conditional domination of moment generating
functions with its exponential supermartingales and Ville bounds. The ReinforcementLearning
roadmap's Layer 6 regroups the first two by the keys of key-determined environments; the Bandits
and ReinforcementLearning roadmaps derive their time-uniform concentration inequalities from the
third.

Outside this roadmap:
- best policy identification in Markov decision processes;
- combinatorial and semi-bandit identification beyond what the general tasks of Layer 1 express;
- dueling bandits, contextual and multi-fidelity identification;
- Bayesian (posterior-based) guarantees: Top Two algorithms are analyzed here with frequentist
  guarantees only;
- stopping thresholds, deviation inequalities and sampling rules built on $\mathrm K_{\inf}$ or
  $\mathrm{KL}_{\inf}$ for nonparametric classes (bounded or heavy-tailed arms), including the
  bounded-arm Top Two results of [JDBdHK22]. The $\mathrm K_{\inf}$ transportation costs of these
  classes (Layer 1.4), their lower bounds (Layer 2.3) and the elimination algorithms for
  sub-Gaussian or bounded arms (Layers 7, 8.1–8.2) are in scope.

## Conventions

**Sources and numbering.** Statements cite the original papers by the keys of the References
section, with their theorem numbers, and [LS, Chapter 33] for the textbook account. Rounds are
numbered from 0, as in LML: after $n$ rounds the actions $A_0,\dots,A_{n-1}$ have been played, and
the stopping time $\tau$ is the number of rounds played. A paper's round $t$ is Lean round $t-1$.

**Arms and observations.** A finite set of arms is a type `α` with `[Fintype α] [Nonempty α]
[DecidableEq α] [MeasurableSpace α] [MeasurableSingletonClass α]`, and $K$ is `Fintype.card α`. Do
not specialize to `Fin K`. Observations live in a measurable space `𝓨`. The framework, the lower
bounds, the pure exploration game and the run-to-stream transfer (Layers 0–3 and 4.1) are stated
for general `𝓨`. Exponential families live on any measurable space, with a real or vector
statistic; the algorithms built on empirical means use `𝓨 = ℝ`, or the statistic of an
exponential family on `𝓨`. The observation type of the sampling rule is `Unit`, as for LML's
`stationaryEnv`.

**Models and tasks.** An identification task (Layer 1.1) has a type `Θ` of models with a Markov
kernel `ν θ : Kernel α 𝓨` for each model, a set `M : Set Θ` of admissible models, a type `ℐ` of
answers and a set-valued correct-answer function `correct : Θ → Set ℐ`. Single-answer tasks have
`correct θ = {answer θ}` on `M`. A model is not required to be a vector of means: means of
exponential families (Layer 1.2), parameters of linear models (Layer 9), pairs (mean, variance)
(Layer 1.3) and the arm laws themselves (Layer 1.1) are all models. The classical tasks ask about
the arm means through a *mean functional* `mean : Θ → α → ℝ`; the tasks on vectors of means are
the case `Θ = α → ℝ`, `mean = id`. A *product model* (Layer 1.4) has models `θ : α → Θ₀`, arm `a`
of `θ` depending on `θ a` only.

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
budget can be strictly easier than fixed confidence [KCG16, Theorem 14]. The divergence from an
empirical mean outside the open interval of means of an exponential family is the value of the
Cramér rate function (Layer 1.2), also `ℝ≥0∞`-valued.

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
`∀ᶠ T in atTop`. Never use `limsup`/`liminf` of real sequences as the primary form. Stopping
thresholds are `ℝ≥0∞`-valued functions `β n h` of the round `n` and of the history
`h : Hist Unit α 𝓨 n`, for each confidence level, so that thresholds depending on the pull counts
[KK21] are covered; thresholds depending on the round only are the special case.

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
| 0 | Identification algorithms, correctness, sample complexity and phased elimination | LML `IdentAlg` |
| 1 | Identification tasks, exponential families and product models | Layer 0 |
| 2 | Change of measure and lower bounds | Layers 0–1; Bandits roadmap Layer 4 |
| 3 | The pure exploration game | Layer 1; Bandits roadmap Layer 8 (design operators) |
| 4 | Deviation inequalities and GLR stopping rules | Layers 1, 3; Bandits roadmap Layer 1 |
| 5 | Tracking and asymptotically optimal sampling rules | Layers 2–4 |
| 6 | Game-based, Top Two and Frank–Wolfe sampling rules | Layers 3–5; Bandits roadmap Layer 6 |
| 7 | Elimination and confidence-bound algorithms | Layers 0–2, 4 |
| 8 | Fixed-budget identification | Layers 0–3 |
| 9 | Linear identification | Layers 2–6; Bandits roadmap Layer 8 |

## Layer 0: Identification algorithms, correctness, sample complexity and phased elimination

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
   - For every environment, every run with real feedback and every stopping time $\tau$ of LML's
     `IsAlgEnvSeq.filtrationAction` (the event $\{t<\tau\}$ is known when $A_t$ is chosen) with
     $\mathbb E[\tau]<\infty$, prove Wald's identity for the feedback
     $\mathbb E\big[\sum_{t<\tau}Y_t\big]=\mathbb E\big[\sum_{t<\tau}m_t(A_t)\big]$, where $m_t(a)$
     is LML's conditional mean `env.means O A Y a t`, when the conditional absolute means
     $\int|y|\,d\big(\texttt{env.measure O A Y t}\big)(A_t)$ are bounded by a constant. The proof
     stops the martingale $\sum_{t<n}(Y_t-m_t(A_t))$ of LML's `IsAlgEnvSeq.condExp_feedback` (for
     finitely many actions, the sum over the actions of LML's `noiseSum`, a martingale by
     `IsAlgEnvSeq.martingale_noiseSum`).
   - For stationary environments on finite arms with integrable rewards of means $\mu_a$, deduce
     $\mathbb E\big[\sum_{t<\tau}Y_t\big]=\sum_a\mathbb E[N_a(\tau)]\,\mu_a$ by the regrouping
     above. LMLExplore's `IsAlgEnvSeq.integral_sum_feedback_eq_sum_integral_pullCount_mul` becomes
     this corollary.
4. **Fixed-budget algorithms.**
   - Define fixed-budget algorithms (stop after exactly $T$ rounds) and the fixed-budget constructor
     from a sampling rule and an output kernel on $T$-round histories.
   - Prove that their stopped history is the $T$-round history, that they stop almost surely, and
     that their output law is the output kernel composed with the law of the $T$-round history.
   - Define static (fixed-design) sampling rules, which play a fixed sequence of arms.
5. **Phased elimination.**
   - Define the phased-elimination constructor. Its data are a finite type of answers `ℐ`, an
     initial active set $S_0$ (a `Finset ℐ`), for each phase $r$ a pull schedule
     $n_r : \texttt{Finset ℐ}\to\alpha\to\mathbb N$ giving the number of pulls of each arm in phase
     $r$ as a function of the active set, played in a fixed order, measurable elimination maps
     $E_r$ sending the active set and the history at the end of phase $r$ to a subset
     $S_{r+1}\subseteq S_r$, and a measurable output rule that returns an element of the final
     active set when it is nonempty. The fixed-confidence version stops when at most one answer is
     active; the fixed-budget version stops after a given number $R$ of phases.
   - Prove its run lemmas: the start of each phase is a stopping time, and conditionally on the
     history at the start of phase $r$, the observations of phase $r$ are independent, arm $a$
     contributing $n_r(S_r)(a)$ observations of law $\nu_a$. When the total number of pulls of
     each phase depends only on $r$ along the reachable active sets, as for successive rejects,
     sequential halving and median elimination, prove that the fixed-budget version is a
     fixed-budget algorithm (item 4).
   - For a model with a single correct answer $i^*\in S_0$, and a constructor whose final active
     set has at most one element whenever it stops (the case of every instance below), prove the
     survival bound
     $P(\text{it stops with an output other than } i^*)\le\sum_rP(i^*\in S_r\setminus S_{r+1})$,
     and bound the stopping time of the fixed-confidence version by the total number of pulls of
     the phases before the active set has at most one element.
   - Successive elimination (Layer 7.1), median elimination (Layer 7.2), successive rejects
     (Layer 8.1), sequential halving (Layer 8.2) and RAGE (Layer 9.3) are instances: construct each
     of them through this constructor and prove their results through these lemmas.

## Layer 1: Identification tasks, exponential families and product models

1. **Tasks.**
   - Define identification tasks (Conventions): alternatives $\neg i$, answer sets
     $\{\theta\in M: i\in i^*(\theta)\}$, single-answer tasks, and the bandit environment
     `stationaryEnv (ν θ)` of a model.
   - Define $\delta$-correct and $\delta$-PAC algorithms for a task.
   - For a task on `Θ'` and a map `f : Θ → Θ'`, define the pullback `task.comap f`, with bandits
     `task.ν ∘ f`, admissible models `f ⁻¹' task.M` and correct answers `task.correct ∘ f`. Prove
     that its alternatives and answer sets are the preimages of those of `task`, and that a
     $\delta$-correct ($\delta$-PAC) algorithm for `task` is $\delta$-correct ($\delta$-PAC) for
     `task.comap f`.
   - Define the classical tasks for models `Θ` with bandits `ν : Θ → Kernel α 𝓨` and a mean
     functional `mean : Θ → α → ℝ`, writing $\mu=\texttt{mean }\theta$:
     - best arm identification on models with a unique best arm;
     - top-$m$ identification (the set of the $m$ largest means, on models where it is unique);
     - top-$m$ identification with tolerance $\varepsilon$ [KTAS12] (correct answers are the sets
       of $m$ arms whose means are all at least the $m$-th largest mean minus $\varepsilon$);
     - $\varepsilon$-best arm identification, additive (correct answers are the arms within
       $\varepsilon$ of the best) and multiplicative (the arms with mean at least
       $(1-\varepsilon)\max_b\mu_b$, on models with positive means) [JDK23b];
     - thresholding (the set of arms with mean above $\gamma$, on models with no mean equal to
       $\gamma$);
     - the minimum-threshold task (is the smallest mean below $\gamma$?);
     - the multiple-answer task *Any Low Arm* [DK19, Example 1] (an arm with mean below $\gamma$,
       or "none");
     - half-space identification (the sign of $\langle u,\mu\rangle$).
   - The tasks on vectors of means are the case `Θ = α → ℝ`, `mean = id`: restate LMLExplore's
     `baiTask ν`, `topMTask`, `epsTopMTask`, `epsBaiTask`, `thresholdingTask`, `minThresholdTask`,
     `anyLowArmTask` and `halfSpaceTask` (`Identification/Task/MeanVector.lean`) with the mean
     functional as a parameter, keeping every lemma about them. Prove that when `ν = ν' ∘ mean`,
     the task of `(ν, mean)` is the pullback along `mean` of the task on vectors of means for `ν'`.
   - Define the model of all bandits with real observations: `Θ = α → ProbabilityMeasure ℝ`, with
     `ν θ a = θ a` and `mean θ a = ∫ x, x ∂(θ a)`, and prove that every Markov kernel
     `κ : Kernel α ℝ` is `ν θ` for `θ a = κ a`. Classes of bandits are restrictions of its tasks
     (`IdentTask.restrict`): the σ²-sub-Gaussian bandits
     (`∀ a, HasSubgaussianMGF (fun x ↦ x - (θ a)[id]) σ2 (θ a)`, the Bandits roadmap's convention)
     and the bandits with laws on $[0,1]$. The guarantees of Layers 7 and 8.1–8.2 are stated on
     these restricted tasks, so that they hold for every bandit of the class.
   - The linear tasks of Layer 9.1 are the tasks with models in an inner product space `E` and
     mean functional $\theta\mapsto(\langle\varphi(a),\theta\rangle)_a$.
   - For best arm identification on vectors of means, prove that the alternatives to the best arm
     $a^*$ have closure $\{\lambda:\exists b\ne a^*,\ \lambda_b\ge\max_c\lambda_c\}$ within the
     models whose means lie in the families' mean sets. Prove that the transportation infimum over
     $\neg a^*$ equals the infimum over this closed set when the divergences are continuous.
2. **Exponential families.**
   - For a measurable space `𝓧`, a probability measure $\rho$ on `𝓧` and a measurable statistic
     `T : 𝓧 → ℝ` with nonempty open natural-parameter set
     $\Theta_\rho=\operatorname{interior}(\texttt{integrableExpSet T }\rho)$, define the family of
     tilts $\rho_\eta=$ `ρ.expFamily T η = ρ.tilted (fun x ↦ η * T x)`, $\eta\in\Theta_\rho$. The
     natural exponential families of measures on `ℝ` are the case `T = id`.
   - Define the log-partition function $\psi=$ `cgf T ρ`, the mean map $\psi'$ (the mean of `T`
     under $\rho_\eta$, `deriv_cgf`), and its strict monotonicity when `T` is not
     $\rho$-almost everywhere constant (variance `iteratedDeriv_two_cgf` > 0).
   - Define the open interval of means `ρ.expFamilyMeans T`, the natural parameter
     `ρ.natParam T μ` of a mean, and the mean parametrization $\mu\mapsto\rho_{\eta(\mu)}$.
   - Prove that the means and the divergence $d$ below do not change, and the natural parameters
     shift by $\eta_0$, when $\rho$ is replaced by a member $\rho_{\eta_0}$
     (`expFamily_expFamily`), and that they depend on $(\rho,T)$ only through the law
     `ρ.map T` of the statistic: the family of $(\rho,T)$ and the natural exponential family of
     `ρ.map T` have the same log-partition function, means and divergence.
   - Prove the closed form
     $\mathrm{KL}(\rho_{\eta(\mu)},\rho_{\eta(\mu')})=d(\mu,\mu')
     =\psi(\eta')-\psi(\eta)-\mu(\eta'-\eta)$ (`ρ.expFamilyDiv T μ μ'`, from `llr_tilted_left`),
     and that $d$ is nonnegative, zero exactly on the diagonal, continuous on (means)$^2$, strictly
     convex in its first argument, and monotone in each argument on each side of the other (it is
     not convex in its second argument in general: the exponential family is a counterexample).
   - **Rate function.** For a real random variable $X$ under a probability measure $P$, define
     the Cramér rate function $I_X(x)=\sup_t\big(tx-\Lambda_X(t)\big)\in[0,\infty]$
     [BLM13, Section 2.2; DZ98, Section 2.2]: Tau Ceti's `fenchelConjugate`, for the pairing
     $(t,x)\mapsto tx$, of the cumulant generating function `cgf X P` extended by $+\infty$ outside
     `integrableExpSet X P`, valued in `ℝ≥0∞`. Prove that it is
     $\sup_{t\in\texttt{integrableExpSet X P}}(tx-\texttt{cgf X P }t)$, convex and lower
     semicontinuous, zero at $\mathbb E[X]$ for integrable $X$, antitone below $\mathbb E[X]$ and
     monotone above it, infinite outside the closed interval between the essential infimum and
     supremum of $X$, and equal to $-\log P(X=x)$ at a finite essential supremum or infimum $x$.
   - For the statistic $T$ under the member of mean $\mu$, prove that $I(x)=d(x,\mu)$ on the means.
     Define $\bar d(x,\mu)$, for every real $x$ and every mean $\mu$, as this rate function at
     $x$: it is the generalized likelihood ratio extension of $d$ to empirical means outside the
     open interval of means (for Bernoulli arms, `klBer` on $[0,1]$, by the Bandits roadmap's
     Layer 1.4). Prove that $\bar d$ is continuous on (closure of the means)$\times$(means) as an
     `ℝ≥0∞`-valued function.
   - Prove the Cramér–Chernoff bound with the rate function: for independent real random variables
     $X_i$, $i\in s$, each dominated on $[0,\infty)$ by a real random variable $X$ (LMLExplore's
     `MGFDominatedOn X_i P X Q (Set.Ici 0)`), every $x\ge\mathbb E[X]$ and every real
     $r\le I_X(x)$, $P\big(\sum_{i\in s}X_i\ge\#s\,x\big)\le\exp(-\#s\,r)$; and the lower tail for
     variables dominated on $(-\infty,0]$ and $x\le\mathbb E[X]$. For $X$ the statistic under the
     member of mean $\mu$, this is the bound $\exp(-\#s\,\bar d(x,\mu))$ at every level $x\ge\mu$,
     not only at the means; it contains LMLExplore's
     `iIndepFun.measureReal_sum_ge_le_exp_expFamilyDiv` and the Bandits roadmap's Layer 1.4 bound,
     boundary levels included.
   - Deduce the two-sided bound $P\big(\#s\,\bar d(\hat\mu_s,\mu)\ge z\big)\le2e^{-z}$ for every
     $z\ge0$, for the empirical mean $\hat\mu_s$ of variables dominated on $\mathbb R$ by the
     member of mean $\mu$.
   - Prove the sub-Gaussian comparison: $d(\mu,\mu')\ge(\mu-\mu')^2/(2\sigma^2)$ when the family has
     variance at most $\sigma^2$ on the segment.
   - Prove that the following are exponential families in this sense, with their divergences:
     - the Gaussian laws of variance $\sigma^2$ (`T = id`, $d(\mu,\mu')=(\mu-\mu')^2/(2\sigma^2)$);
     - the Bernoulli laws `Ber((1 : ℝ), 0, p)` (`T = id`, $d=$ `klBer`, by the Bandits roadmap's
       `klDiv_bernoulliMeasure`);
     - the Poisson laws, as Mathlib's `poissonMeasure` on `ℕ` with `T = Nat.cast`;
     - the gamma laws of known shape $a>0$ (`gammaMeasure a r`, `T = id`, the family of
       `gammaMeasure a 1` with natural parameter $1-r$, by Tau Ceti's `gammaMeasure_tilted_mul`),
       with means $a/r$ and $d(\mu,\mu')=a\big(\tfrac\mu{\mu'}-1-\log\tfrac\mu{\mu'}\big)$;
     - the exponential laws (`expMeasure r = gammaMeasure 1 r`), the shape $a=1$;
     - the Gaussian laws of known mean $m$: $\rho=\mathcal N(m,1)$, $T(x)=(x-m)^2$, members
       $\mathcal N(m,v)$ with natural parameter $(1-1/v)/2$, means the variances $v>0$. The law of
       $T$ under $\rho$ is the gamma law of shape and rate $\tfrac12$ (Tau Ceti's
       `gaussianReal_map_sq`), so by the invariance above
       $d(v,v')=\tfrac12\big(\tfrac v{v'}-1-\log\tfrac v{v'}\big)$ is the shape-$\tfrac12$ case.
     
     LMLExplore's direct proofs for the exponential laws and the Gaussian laws of known mean
     (`ExponentialFamily/Exponential.lean`, `expFamilyDiv_sub_sq_gaussianReal`) become these
     corollaries.
   - Define the bandit of a mean vector, whose arm `a` has the law of mean $\mu_a$ in the
     exponential family $(\rho_a,T_a)$ on a common observation space `𝓨`: the product model of
     Layer 1.4 with these families.
   - The merged natural-exponential-family development of LMLExplore is restated in this
     generality by the Refactors roadmap, Layer 0.2.
3. **Exponential families with a vector statistic, and Gaussian arms with unknown variances.**
   - For a finite-dimensional real inner product space `E`, a probability measure $\rho$ on `𝓧` and
     a measurable statistic `T : 𝓧 → E` whose natural-parameter set, the interior of
     $\{\eta:\exp\langle\eta,T\rangle\text{ is }\rho\text{-integrable}\}$, is nonempty, define the
     family of tilts $\rho_\eta=$ `ρ.tilted (fun x ↦ ⟪η, T x⟫)` and the log-partition function
     $\psi(\eta)=\log\int\exp\langle\eta,T\rangle\,d\rho$ [Bro86, Chapter 1; BN78; WJ08,
     Section 3]. For `E = ℝ` these are the families of item 2.
   - Prove: the natural-parameter set and $\psi$ are convex; tilting $\rho_\eta$ by
     $\langle\eta',T\rangle$ gives $\rho_{\eta+\eta'}$; on each line,
     $t\mapsto\psi(\eta+tu)-\psi(\eta)$ is `cgf (fun x ↦ ⟪u, T x⟫) ρ_η`, so item 2 applies to
     $\langle u,T\rangle$; $\psi$ is differentiable on the natural-parameter set with gradient the
     mean of $T$ under $\rho_\eta$; the log-likelihood ratio of $\rho_\eta$ against $\rho_{\eta'}$
     is $\langle\eta-\eta',T\rangle+\psi(\eta')-\psi(\eta)$, $\rho_\eta$-almost everywhere; and
     $\mathrm{KL}(\rho_\eta,\rho_{\eta'})=\psi(\eta')-\psi(\eta)-\langle\nabla\psi(\eta),\eta'-\eta\rangle$,
     LML's `bregDiv ψ η' η (fderiv ℝ ψ η)` [BMDG05].
   - Prove that, for independent observations of law $\rho_\eta$, the likelihood ratio process
     $\exp\big(\langle\eta'-\eta,\sum_{i<n}T(Y_i)\rangle-n(\psi(\eta')-\psi(\eta))\big)$ is a
     nonnegative martingale with mean $1$ for every $\eta'$ in the natural-parameter set.
   - The mean parametrization is built here for `E = ℝ` only (item 2); for vector statistics it is
     the EValues roadmap's Layer 1.5, which contains item 2's as the case `E = ℝ`.
   - Prove that the Gaussian laws $\mathcal N(\mu,\sigma^2)$, $\sigma^2>0$, are the family of
     $\mathcal N(0,1)$ with $T(x)=(x,x^2)$ in `EuclideanSpace ℝ (Fin 2)`, with natural parameter
     $(\mu/\sigma^2,(1-1/\sigma^2)/2)$. Their divergence
     $\mathrm{KL}(\mathcal N(\mu,\sigma^2),\mathcal N(\mu',\sigma'^2))=
     \tfrac12\big(\log\tfrac{\sigma'^2}{\sigma^2}+\tfrac{\sigma^2+(\mu-\mu')^2}{\sigma'^2}-1\big)$
     is LMLExplore's `klDiv_gaussianReal_gaussianReal`.
   - The two-parameter Gaussian model $\theta=(\mu_a,\sigma_a^2)_a$ is LMLExplore's
     `gaussianMeanVarBandit`, a product model (Layer 1.4) whose mean functional is the means; the
     sufficient statistics of an arm are its sums of $Y$ and $Y^2$ (Layer 4.5).
4. **Product models and $\mathrm K_{\inf}$.**
   - A *product model* is given by a type `Θ₀` of arm parameters, arm laws
     `κ : α → Θ₀ → Measure 𝓨` (probability measures), per-arm admissible sets $S_a\subseteq$ `Θ₀`
     and per-arm means $m_a:$ `Θ₀ → ℝ`. Its models are `θ : α → Θ₀`, with
     `ν θ a = κ a (θ a)` and mean functional $\theta\mapsto(m_a(\theta_a))_a$, and its
     transportation cost is $\sum_aw_a\,\mathrm{KL}(\kappa_a(\theta_a),\kappa_a(\lambda_a))$, a
     function of the per-arm divergences only. Instances: vectors of means of per-arm exponential
     families (`Θ₀ = ℝ`, $S_a$ the means of $(\rho_a,T_a)$, $m_a=$ `id`); Gaussian arms with known
     per-arm variances; the two-parameter Gaussian model (`Θ₀ = ℝ × ℝ≥0`,
     $m_a(\mu,\sigma^2)=\mu$); and the model of all bandits with real observations of Layer 1.1
     (`Θ₀ = ProbabilityMeasure ℝ`, $\kappa_a(P)=P$, $m_a(P)=\int x\,dP$), with $S_a$ a class of
     laws such as the laws on $[0,1]$ or the σ²-sub-Gaussian laws.
   - Define, in `ℝ≥0∞`,
     $\mathrm K^-_a(x,u)=\inf\{\mathrm{KL}(\kappa_a(x),\kappa_a(y)):y\in S_a,\ m_a(y)\le u\}$ and
     $\mathrm K^+_a(x,u)=\inf\{\mathrm{KL}(\kappa_a(x),\kappa_a(y)):y\in S_a,\ m_a(y)\ge u\}$
     [AJG20; JDK23a, (1)]. Prove that $\mathrm K^-_a(x,\cdot)$ is antitone and zero from
     $m_a(x)$ on, and $\mathrm K^+_a(x,\cdot)$ monotone and zero up to $m_a(x)$ for $x\in S_a$.
     LMLExplore's `dInf` (the Bandits roadmap's Layer 4.4) is $\mathrm K^+$ with a strict
     inequality on the mean.
   - For best arm identification on a product model, a model $\theta\in\prod_cS_c$ with best arm
     $a$ and an allocation with positive entries, prove
     $\inf\{\mathrm{cost}_\theta(w,\lambda):\lambda\in\prod_cS_c,\ \exists b\ne a,\
     m_b(\lambda_b)\ge m_a(\lambda_a)\}=\min_{b\ne a}\inf_u\big(w_a\mathrm K^-_a(\theta_a,u)+
     w_b\mathrm K^+_b(\theta_b,u)\big)$ [AJG20; JDK23a, (1)], which is $D(\theta,w,\neg a)$ when the
     closure property of Layer 1.1 holds. Prove the analogous formulas for top-$m$ identification
     (pairs $a\in S$, $b\notin S$) and for thresholding
     ($\min\big(\min_{a\in S}w_a\mathrm K^-_a(\theta_a,\gamma),\min_{a\notin S}
     w_a\mathrm K^+_a(\theta_a,\gamma)\big)$ for the answer $S$).
   - Prove the instances: for exponential families in the mean parametrization,
     $\mathrm K^-_a(\mu,u)=d_a(\mu,u)$ for means $u\le\mu$ (and symmetrically for $\mathrm K^+$);
     for the two-parameter Gaussian model,
     $\mathrm K^-_a((\mu,\sigma^2),u)=\tfrac12\log\big(1+(\mu-u)^2/\sigma^2\big)$ for $u\le\mu$
     [JDK23a, Lemma 3] (from LMLExplore's `iInf_klDiv_gaussianReal_gaussianReal`); for laws on
     $[0,1]$, $\mathrm K^+(P,u)\ge$ `klBer` $(m(P), u)$ for $u\ge m(P)$ and
     $\mathrm K^-(P,u)\ge$ `klBer` $(m(P), u)$ for $u\le m(P)$, with equality for Bernoulli laws
     (data processing through the kernel $x\mapsto\mathcal B(x)$).
   - State the alternative-cost lemmas of LMLExplore's `Identification/Task/ExpFamily.lean`, and
     those of best arm identification, thresholding, minimum threshold and Any Low Arm in Layer 3,
     for product models with `Θ₀ = ℝ` whose per-arm divergences
     $(x,y)\mapsto\mathrm{KL}(\kappa_a(x),\kappa_a(y))$ are continuous on $S_a\times S_a$, zero
     exactly on the diagonal and monotone in each argument on each side of the other: their proofs
     use nothing else. Exponential families are the instance.

Generalization: arbitrary models and answer types, multiple correct answers and observations in any
measurable space, where [GK16, DK19] use vectors of means in one exponential family and finitely
many answers; questions about the means of arbitrary models through a mean functional, and
product models with $\mathrm K_{\inf}$ costs [AJG20, JDK23a].

## Layer 2: Change of measure and lower bounds

1. **Divergence decomposition at a stopping time.**
   - For any two algorithm-environment pairs `(alg, env)` and `(alg', env')`, a measurable
     stopping rule $S$ and its hitting time $\tau$, almost surely finite under the first pair,
     prove the chain rule at the stopping time [GMS19, Section 2; KCG16, Lemma 1]:
     $$\mathrm{KL}\big(\texttt{stoppedHistMeasure alg env S},\texttt{stoppedHistMeasure alg' env' S}\big)
     \le\sum_t\mathrm{KL}\big(\mu_t\otimes_m\texttt{stepKernel alg env }t,\
     \mu_t\otimes_m\texttt{stepKernel alg' env' }t\big),$$
     with $\mu_t$ the law of the $t$-round history under the first pair restricted to LMLExplore's
     `notStoppedSet S t`, that is,
     $\mathbb E\big[\sum_{t<\tau}\mathrm{KL}(\text{step}_t(H_t)\,\|\,\text{step}'_t(H_t))\big]$ when the
     spaces are countably generated (LML's `klDiv_compProd_right_eq_lintegral`), with equality
     when $\tau$ is also almost surely finite under the second pair. The fixed-horizon case is
     LML's `IsAlgEnvSeq.klDiv_map_history_stepKernel`; the proof changes both pairs after the
     stopping time (LMLExplore's `stoppedHistMeasure_congr`).
   - Prove the same bound for the joint law of the stopped history and the output when the output
     kernel is common (Mathlib's `klDiv_compProd_left`).
   - For one algorithm run in `stationaryEnv ν` and `stationaryEnv ν'` on finite arms, deduce
     $\mathrm{KL}(\text{law of the stopped history under }\nu,\text{ under }\nu')
     \le\sum_a\mathbb E_\nu[N_a(\tau)]\,\mathrm{KL}(\nu_a,\nu'_a)$, with equality when $\tau$ is also
     almost surely finite under $\nu'$. LMLExplore's `klDiv_stoppedHistMeasure_le` becomes this
     corollary; the fixed-horizon case is LML's `IsAlgEnvSeq.klDiv_map_history_stepKernel`.
   - The regrouping by the keys of key-determined environments is the ReinforcementLearning
     roadmap's Layer 6.2, built on the first bullet.
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
   - For any task, a $\delta$-correct algorithm with $\delta\in(0,1/2)$ and an admissible model
     $\theta$ with a single correct answer, prove
     $\mathbb E_\theta[\tau]\ge T^*(\theta)\,\mathrm{kl}(\delta,1-\delta)$ [GK16, Theorem 1].
   - Prove $\mathrm{kl}(\delta,1-\delta)\ge\log\frac1{2.4\delta}$ [KCG16], and the
     Bretagnolle–Huber variant $\mathbb E_\theta[\tau]\ge T^*(\theta)\log\frac1{4\delta}$
     [LS, Theorem 33.5].
   - Prove the allocation form: the normalized expected counts
     $\big(\mathbb E_\theta[N_a(\tau)]/\mathbb E_\theta[\tau]\big)_a$ satisfy
     $\mathbb E_\theta[\tau]\,D(\theta,w,\neg i^*(\theta))\ge\mathrm{kl}(\delta,1-\delta)$.
   - For tasks with finitely many answers, prove
     $\liminf_{\delta\to0}\mathbb E_\theta[\tau_\delta]/\log(1/\delta)\ge T^*(\theta)$ at every
     admissible model $\theta$, whatever its number of correct answers, for every family of
     $\delta$-correct algorithms [DK19, Theorem 1, Proposition 18, Lemma 19], in the eventual form
     of the Conventions. At a model with a single correct answer it follows from the first bullet.
4. **Fixed-budget lower bounds.**
   - For two models $\theta,\lambda$ without a common correct answer and an algorithm with budget
     $T$, prove
     $P_\theta(\text{error})+P_\lambda(\text{error})\ge\tfrac12\exp\!\big(-\sum_a\mathbb
     E_\theta[N_a(T)]\,\mathrm{KL}(\nu_a(\theta),\nu_a(\lambda))\big)$ (Bretagnolle–Huber).
   - Prove its consequence: some model of every finite family has error at least
     $\tfrac14\exp(-T\max_a\mathrm{KL})$.
   - The minimax lower bounds of Layer 8.4 build on this.

Generalization: arbitrary tasks and observation spaces, where [KCG16, GK16] treat best arm
identification in exponential families; the chain rule at a stopping time for any two
algorithm-environment pairs, where [KCG16, GMS19] treat one algorithm against two stationary
bandits.

## Layer 3: The pure exploration game

1. **Transportation costs.**
   - Define the quantities of the Conventions and the set $w^*(\theta,\neg i)$ of optimal
     allocations.
   - Prove that $w\mapsto D(\theta,w,\neg i)$ is concave and positively homogeneous on
     $[0,\infty)^\alpha$ and monotone (antitone in the alternative set), so $w^*(\theta,\neg i)$ is
     convex.
   - Prove that the value is $0$ when $\theta\in\neg i$, and that $T^*(\theta)<\infty$ iff some
     correct answer has alternatives at positive cost for some allocation.
   - Prove that $(\theta,w)\mapsto D(\theta,w,\neg i)$ is upper semicontinuous, hence measurable,
     on every topological space of models on which $\theta\mapsto\mathrm{KL}(\nu_a(\theta),
     \nu_a(\lambda))$ is real-valued and continuous for every arm and every alternative $\lambda$
     (an infimum of continuous functions).
   - For a pullback `task.comap f` (Layer 1.1), prove
     $\mathrm{cost}_\theta(w,\lambda)=\mathrm{cost}_{f\theta}(w,f\lambda)$ and
     $D(\theta,w,\neg i)\ge D(f\theta,w,\neg i)$, with equality when the range of $f$ contains the
     alternatives to $i$ of `task`; deduce $T^*_{\texttt{comap}}(\theta)\le T^*(f\theta)$, with
     equality under the same condition for every answer.
2. **Game and minimax forms.**
   - Prove $D(\theta,\neg i)=\inf_{q}\max_a\mathbb E_{\lambda\sim q}[\mathrm{KL}(\nu_a(\theta),
     \nu_a(\lambda))]$ over finitely supported distributions $q$ on $\neg i$ [DK19, Lemma 2;
     DKM19, Section 2], from Mathlib's `Sion.minimax` on the simplex.
   - Prove $T^*(\theta)^{-1}=\max_{i\in i^*(\theta)}D(\theta,\neg i)$, the characteristic-time
     identity of multiple-answer tasks.
3. **Continuity** [DK19, Appendix F].
   - Prove Berge's maximum theorem for upper hemicontinuous compact-valued correspondences
     [DK19, Theorem 22], from Mathlib's `IsCompact.continuous_sSup`/`continuous_sInf`.
   - Prove the joint continuity of $(\theta,w)\mapsto D(\theta,w,A)=\inf_{\lambda\in A}
     \mathrm{cost}_\theta(w,\lambda)$ on $\prod_aS_a\times[0,\infty)^\alpha$, for every set
     $A\subseteq\prod_aS_a$ of alternatives, compact or not, for a product model (Layer 1.4) with
     topological spaces $S_a$ such that each per-arm divergence
     $k_a(x,y)=\mathrm{KL}(\kappa_a(x),\kappa_a(y))$ is real-valued and continuous on
     $S_a\times S_a$, and every $x\in S_a$ has a neighbourhood $U$ such that
     $\{y\in S_a:\exists x'\in U,\ k_a(x',y)\le r\}$ is relatively compact in $S_a$ for every $r$:
     the non-compact setting of [FKV14; DK19, Theorem 23, Lemmas 24–27]. Upper semicontinuity is
     Layer 3.1. For lower semicontinuity at $(\theta,w)$, near-optimal alternatives at nearby points
     have their coordinates of positive weight in a compact set, on which $k_a$ is uniformly close
     to $k_a(\theta_a,\cdot)$. Prove also the joint continuity on $M\times[0,\infty)^\alpha$ for any
     topological space of models with real-valued divergences continuous on $M\times M$ when the
     closure of $\neg i$ in $M$ is compact [DK19, Theorem 22]. Prove that the per-arm hypotheses
     hold for exponential families in the mean parametrization whose divergence $d(x,y)$ tends to
     $+\infty$ as $y$ tends to an endpoint of the means (every instance of Layer 1.2), and for the
     two-parameter Gaussian model on `ℝ × (0, ∞)`.
   - Deduce, under either hypothesis, for every task with finitely many answers:
     - continuity of $\theta\mapsto D(\theta,\neg i)$ and of $D(\theta)$;
     - upper hemicontinuity with compact convex values of $\theta\mapsto w^*(\theta,\neg i)$;
     - upper hemicontinuity of the oracle answers $i_F(\theta)=\operatorname{argmax}_i
       D(\theta,\neg i)$ and of $w^*(\theta)=\bigcup_{i\in i_F(\theta)}w^*(\theta,\neg i)$
       [DK19, Theorem 4, Lemmas 28–30].
     
     LMLExplore's `Identification/Task/Continuity.lean` and `Identification/Task/Oracle.lean`
     prove these consequences from the joint continuity, which LMLExplore derives for best arm
     identification with one exponential family only (`continuousOn_altCost_baiTask_restrict`);
     the theorem above discharges it for every task on these product models.
   - Prove the convexity of $w^*(\theta,\neg i)$ and give a model where $w^*(\theta)$ is not
     convex [DK19, Proposition 5].
4. **Best arm identification in exponential families** [GK16, Section 2], with arm $a$ in its own
   exponential family $(\rho_a,T_a)$ with divergence $d_a$, all families having the same open
   interval of means.
   - Prove that $D(\mu,w,\neg a^*)=\min_{b\ne a^*}\inf_x\big(w_{a^*}d_{a^*}(\mu_{a^*},x)+
     w_bd_b(\mu_b,x)\big)$, the infimum over the means $x$ between $\mu_b$ and $\mu_{a^*}$
     (Layer 1.4), and that when $a^*$ and $b$ have the same family it is attained at the
     $w$-weighted mean of $\mu_{a^*}$ and $\mu_b$ [GK16, Lemma 3].
   - Prove that $w^*(\mu)$ is a singleton with positive entries equalizing the costs of the pairs
     $(a^*,b)$ [GK16, Lemma 4, Theorem 5, Proposition 6]. For distinct families, uniqueness comes
     from the strict concavity of each pair cost along segments that are not on a ray, the
     minimizer of the inner infimum moving with the weights. Prove the scalar equation of
     [GK16, Theorem 5] when the inner infimum has a unique minimizer for all weights, in particular
     for a common family and for Gaussian arms with arm-dependent known variances. Prove the
     continuity of $w^*$ in $\mu$ [GK16, Proposition 6].
   - Prove the Gaussian bounds $H(\mu)\le T^*(\mu)\le 2H(\mu)$ with
     $H(\mu)=\sum_a2\sigma^2/\Delta_a^2$ and $\Delta_{a^*}=\min_{b\ne a^*}\Delta_b$, for a common
     variance $\sigma^2$ [GK16, Section 2.2].
   - Prove the two-armed values for a common family: $T^*(\mu)^{-1}=d(\mu_1,z^*)=d(\mu_2,z^*)$ for
     the $z^*$ between the two means at which these divergences are equal [KCG16, Section 3,
     Theorem 6], and in particular $T^*(\mu)=8\sigma^2/\Delta^2$ with $w^*=(\tfrac12,\tfrac12)$
     for Gaussian arms with a common variance.
5. **Top Two allocations.**
   - Define the $\beta$-optimal allocations: maximize $D(\theta,w,\neg i^*)$ under $w_{a^*}=\beta$,
     with value $T^*_\beta(\theta)^{-1}$ [R16; JDBdHK22].
   - Prove $T^*_{1/2}(\theta)\le2T^*(\theta)$, and the uniqueness and the equalization property of
     the $\beta$-optimal allocation for best arm identification with the per-arm exponential
     families of item 4.
6. **Closed forms for Gaussian arms.** Let arm $a$ have Gaussian observations of known variance
   $\sigma_a^2>0$ and mean $\langle\varphi(a),\theta\rangle$, for $\theta$ in a finite-dimensional
   real inner product space `E` and features $\varphi:\alpha\to E$; the unstructured model is
   `E = EuclideanSpace ℝ α` with $\varphi(a)$ the basis vectors.
   - Prove $\mathrm{cost}_\theta(w,\lambda)=\tfrac12\|\theta-\lambda\|^2_{V_w}$ for the design
     operator $V_w=\sum_aw_a\sigma_a^{-2}\,\varphi(a)\otimes\varphi(a)$ (the operator $V(\pi)$ of
     the Bandits roadmap's Layer 8.6, Tau Ceti's `frameOperator` of the vectors
     $\sqrt{w_a}\,\sigma_a^{-1}\varphi(a)$).
   - For an affine half-space $H=\{\lambda:\langle y,\lambda\rangle\le c\}$ and
     $\langle y,\theta\rangle>c$, prove
     $\inf_{\lambda\in H}\mathrm{cost}_\theta(w,\lambda)=(\langle y,\theta\rangle-c)^2/
     (2\|y\|^2_{V_w^{-1}})$, with $\|y\|^2_{V_w^{-1}}=\sup_x\big(2\langle y,x\rangle-
     \langle x,V_wx\rangle\big)\in[0,\infty]$, which is $\langle y,V_w^+y\rangle$ for $y$ in the
     range of $V_w$ and $\infty$ otherwise (the cost is then $0$). The infimum over a finite union
     of half-spaces is the minimum of these values [FJJR19, Theorem 1].
   - The closures of the alternatives of best arm identification, top-$m$ identification,
     thresholding, half-space identification, the answer "none" of Any Low Arm and the answer
     "every mean is above $\gamma$" of the minimum-threshold task are finite unions of half-spaces.
     Deduce their costs with arm-dependent variances, among them
     $D(\mu,w,\neg a)=\min_{b\ne a}(\mu_a-\mu_b)^2/\big(2(\sigma_a^2/w_a+\sigma_b^2/w_b)\big)$, the
     characteristic time $\sum_a2\sigma_a^2/(\mu_a-\gamma)^2$ of thresholding, and for half-space
     identification the unique optimal allocation proportional to $\sigma_a|u_a|$ and
     $T^*(\mu)=2\big(\sum_a\sigma_a|u_a|\big)^2/\langle u,\mu\rangle^2$ [DK19, Lemma 36].
   - Prove the remaining closed forms of [DK19, Lemmas 37–39]: the answer "some mean is below
     $\gamma$" of the minimum-threshold task (an orthant, with arm-dependent variances) and the
     spheres (for a common variance).
   - The characteristic time of linear identification (Layer 9.2) is the case of the half-spaces
     $\{\lambda:\langle z^*-z,\lambda\rangle\le0\}$.

Generalization: arbitrary models and divergences in `ℝ≥0∞`, where [GK16] works with exponential
families and real divergences; per-arm families, continuity on product models with non-compact
alternatives, and Gaussian costs with arm-dependent variances in design-operator form.

## Layer 4: Deviation inequalities and GLR stopping rules

1. **Empirical statistics along a run and the per-arm streams.**
   - Define the per-arm sums, counts and empirical means of a run (from LML's `SumRewards`), and
     the sum-count statistic of a history.
   - For a run of any algorithm against `stationaryEnv ν`, with `ν : Kernel α 𝓨` on any measurable
     space `𝓨`, and a predicate $q$ on the numbers of pulls `s : α → ℕ` and the first $s_a$
     observations of each arm (an element of `(a : α) → Fin (s a) → 𝓨`), prove the event transfer
     to LML's per-arm stream model `streamMeasure ν` (the stack-of-rewards model
     [LS, Section 4.6]): the probability that $q$ holds at some round for the pull counts and the
     observations of each arm so far is at most the `streamMeasure ν`-probability that $q$ holds
     for some `s` and the first $s_a$ stream observations of each arm. Prove its form up to a
     horizon, its single-arm form, and the counting form: the expected number of rounds $t<n$ at
     which arm $a$ is pulled while an event $E_{N_a(t)}$ about its previous observations holds is
     at most $\sum_{s<n}P(E_s)$ under the stream (with a measurable weight $g\ge0$ in place of the
     indicator). $q$ need not be measurable: both sides are then outer measures.
   - LMLExplore's `SequentialLearning/SumRewards.lean` proves these for events about the sums of
     real rewards; restate them as the case of the sums, with their current statements. The Bandits
     roadmap's Layer 1.3 uses the single-arm counting form for real rewards. Events about the per-arm sums of
     $Y$ and $Y^2$ (item 5), of a statistic $T(Y)$, or about the empirical distribution of an arm
     are covered.
   - The regrouping by the keys of key-determined environments is the ReinforcementLearning
     roadmap's Layer 6.1, built on this item.
2. **Conditional domination and deviation inequalities.**
   - **Conditional domination of moment generating functions.** For a real random variable $X$,
     a function $\psi:\mathbb R\to\mathbb R$ and a set $\Lambda\subseteq\mathbb R$, define that $X$
     has its moment generating function bounded by $e^\psi$ on $\Lambda$: in the kernel version, for
     a kernel $\kappa$ and a measure $\nu$, $\exp(tX)$ is $\kappa\circ_m\nu$-integrable and
     $\int\exp(tX)\,d\kappa(\omega')\le\exp(\psi(t))$ for $\nu$-almost every $\omega'$, for every
     $t\in\Lambda$; the conditional version given a σ-algebra $m$ is the kernel version for
     `condExpKernel μ m` and `μ.trim hm`, and the unconditional version the kernel version on a
     point. This is the pattern of Mathlib's `Kernel.HasSubgaussianMGF` and
     `HasCondSubgaussianMGF`; prove the analogues of their basic API (the bound on
     $\mathbb E[\exp(tX)\mid m]$, measurability, monotonicity in $\psi$ and $\Lambda$, independence
     from $m$ for independent variables).
   - Prove the instances and bridges:
     - Mathlib's `HasCondSubgaussianMGF m hm X c μ` is the case $\psi(t)=ct^2/2$, $\Lambda=\mathbb R$,
       and LML's `HasCondSubexponentialMGF m hm X V b μ` the case $\psi(t)=Vt^2/2$ on
       $\{t:b|t|\le1\}$;
     - the unconditional version with $\psi$ the cumulant generating function of a real random
       variable $Y$ on $\Lambda\cap$ `integrableExpSet Y Q` is LMLExplore's
       `MGFDominatedOn X P Y Q Λ` (`mgfDominatedOn_iff_hasMGFBound`); the Chernoff bounds of
       Layer 1.2 hold under the conditional version along a filtration;
     - $\psi$ the cumulant generating function of the statistic under a member of an exponential
       family on $[0,\infty)$ or $(-\infty,0]$ (the domination of $[0,1]$-valued variables by
       Bernoulli laws is the Bandits roadmap's Layer 1.4);
     - if $X-\mu$ is conditionally σ²-sub-Gaussian, then $X$ is conditionally dominated on
       $\mathbb R$ by the member of mean $\mu$ of the Gaussian family of variance σ², so that the
       Gaussian-family inequalities below apply to σ²-sub-Gaussian rewards.
   - **Exponential supermartingales.** For a filtration $\mathcal F$, a process $(X_k)$ with $X_k$
     $\mathcal F_{k+1}$-measurable and with moment generating function conditionally bounded by
     $e^\psi$ on $\Lambda$ given $\mathcal F_k$, and an $\mathcal F$-predictable real process
     $(w_k)$, prove that for every $t$ with $tw_k\in\Lambda$ for all $k$, the process
     $\exp\big(t\sum_{k<n}w_kX_k-\sum_{k<n}\psi(tw_k)\big)$ is a nonnegative supermartingale with
     initial value $1$ [HRMS20], and with Ville's inequality (LMLExplore's
     `Supermartingale.measure_exists_le_le`) that
     $P\big(\exists n,\ t\sum_{k<n}w_kX_k-\sum_{k<n}\psi(tw_k)\ge x\big)\le e^{-x}$. For
     $w_k=\mathbb 1\{A_k=a\}$ and $\psi(0)=0$ the exponent is $tS_a(n)-N_a(n)\psi(t)$. LMLExplore's
     `supermartingale_exp_sum_mul_of_hasCondSubgaussianMGF` is the sub-Gaussian case.
   - **Self-normalized deviations** [GC11, Theorem 10]. For variables conditionally dominated
     above by the member of mean $\mu$ of an exponential family and predictable indicators
     $\varepsilon_k\in\{0,1\}$, with $N(t)=\sum_{k<t}\varepsilon_k$ and $\hat\mu(t)$ the mean of
     the selected variables, prove
     $P\big(\exists t\le n,\ N(t)\ge1,\ \hat\mu(t)>\mu,\ N(t)\,\bar d(\hat\mu(t),\mu)\ge x\big)\le
     e\lceil x\log n\rceil e^{-x}$, by peeling over a geometric grid of $N(t)$; and the lower tail.
   - Prove the per-arm time-uniform bound
     $P\big(\exists t,\ N_a(t)\,\bar d(\hat\mu_a(t),\mu_a)\ge x+c\log(1+\log N_a(t))\big)$ for the
     constants of [KK21] (from these supermartingales, their mixtures (LMLExplore's
     `supermartingale_integral_of_integrable`) and Ville's inequality).
   - Prove the joint bound for any set $S$ of arms and any sampling rule,
     $P\big(\exists t,\ \sum_{a\in S}\big[N_a(t)\,\bar d(\hat\mu_a(t),\mu_a)-3\log(1+\log N_a(t))\big]^+
     \ge|S|\,\mathcal C^{\exp}(x/|S|)\big)\le e^{-x}$ [KK21, Theorem 7]. Here
     $\mathcal C^{\exp}$ is defined through the inverse of $u\mapsto u-\log u$ on $[1,\infty)$
     (a branch of the Lambert function). Build that inverse and the estimate
     $\mathcal C^{\exp}(x)=x+O(\log(1+x))$ with explicit constants.
   - Deduce the threshold $\beta(t,\delta)=3\sum_a\log(1+\log N_a(t))+K\,\mathcal C^{\exp}
     (\log(1/\delta)/K)$ for general identification [KK21, Proposition 15], and, from the case
     $|S|=2$ and a union bound over the $K-1$ pairs containing the best arm, the pairwise thresholds
     $\beta_{a,b}(t,\delta)=3\sum_{c\in\{a,b\}}\log(1+\log N_c(t))+2\,\mathcal C^{\exp}
     \big(\log((K-1)/\delta)/2\big)$, of order $\log(K/\delta)+O(\log\log t)$, for the covers of
     item 3.
   - Prove the union-bound thresholds of [GK16, Proposition 12] ($\log(Ct^\alpha/\delta)$, $\alpha>1$,
     with an explicit $C=C(\alpha,K,\delta)$ such that
     $\log C(\alpha,K,\delta)=O(\log\log(1/\delta))$ as $\delta\to0$, from the two-sided bound of
     Layer 1.2, for arms dominated by any exponential families; no $C$ independent of $\delta$
     works, and the proof of [GK16, Proposition 12] drops the $\delta$ in
     $\log^2(Ct^\alpha/\delta)$ when it chooses $C$), of [GK16, Theorem 10] (Bernoulli arms only,
     $\log(2t(K-1)/\delta)$, through the Krichevsky–Trofimov mixture of [GK16, Lemma 11]) and of
     [LS, Lemmas 33.7–33.8, Proposition 33.9], and the uniform deviation bound of [MCP14] used by
     [DK19, Lemma 32]. LMLExplore's thresholds for Gaussian arms (`unionBoundThreshold`,
     `Identification/GaussianThreshold.lean`) are the Gaussian case.
3. **GLR statistics and stopping rules.**
   - Define the GLR statistic of an answer for an evidence function $Z_n(h,\lambda)\in[0,\infty]$,
     $\mathrm{GLR}_n(h,\neg i)=\inf_{\lambda\in\neg i}Z_n(h,\lambda)$ (LMLExplore's
     `IdentTask.glr`), and its plug-in instance for an estimator $\hat\theta_n$ from $n$-round
     histories to models: $Z_n(h,\lambda)=\sum_aN_a(h)\,\mathrm{KL}(\nu_a(\hat\theta_n(h)),
     \nu_a(\lambda))$, so that $\mathrm{GLR}_n(h,\neg i)=n\,D(\hat\theta_n(h),N(h)/n,\neg i)$. For
     exponential-family arms and the empirical means it is
     $\inf_{\lambda\in\neg i}\sum_aN_a\,\bar d(\hat\mu_a,\lambda_a)$, the generalized likelihood
     ratio, with the extension $\bar d$ of Layer 1.2 for empirical means outside the means; for
     the two-parameter Gaussian model and the empirical means and variances it is the statistic of
     [JDK23a] (item 5). Prove its measurability.
   - Define the GLRT stopping and recommendation rules on top of any sampling rule, with thresholds
     $\beta_n(h)$ depending on the round and the history (Conventions).
   - Prove that if $P_\theta\big(\exists n,\ \beta_n(H_n)<Z_n(H_n,\theta)\big)\le\delta$ for every
     $\theta\in M$, then the GLRT rules are $\delta$-correct on every task, for every sampling rule
     [GK16, Proposition 12; DKM19, Theorem 1; DK19, Theorem 10]. LMLExplore's
     `IdentTask.isDeltaPAC_glrt` is the case of thresholds depending on the round only.
   - **Covers of the alternatives.** For each answer $i$, let finitely many sets $A_{i,j}$ cover
     $\neg i$, each with its evidence function $Z^{i,j}$ and thresholds $\beta^{i,j}$, and let the
     GLRT stop with the answer $i$ when $\inf_{\lambda\in A_{i,j}}Z^{i,j}_n(h,\lambda)>\beta^{i,j}_n(h)$
     for every $j$. Prove that for every model $\theta$ and every choice of $j(i)$ with
     $\theta\in A_{i,j(i)}$ for each answer $i$ incorrect for $\theta$, the probability that it
     stops with an incorrect answer is at most
     $P_\theta\big(\exists n,\ \exists i\notin i^*(\theta),\
     \beta^{i,j(i)}_n(H_n)<Z^{i,j(i)}_n(H_n,\theta)\big)$. For best arm identification, with
     $A_{a,b}=\{\lambda:\lambda_b\ge\lambda_a\}$, the statistics
     $\sum_{c\in\{a,b\}}N_c\,\bar d(\hat\mu_c,\lambda_c)$ and $j(a)=a^*$, deduce
     $\delta$-correctness with the pairwise thresholds of item 2; the same for top-$m$
     identification with the pairs $a\in S$, $b\notin S$.
4. **Generic sample-complexity reductions.**
   - Asymptotic: let $\theta$ be a model, $i$ an answer, $W$ a compact set of allocations
     (typically $w^*(\theta,\neg i)$) such that $(\theta',w)\mapsto D(\theta',w,\neg i)$ is lower
     semicontinuous at $(\theta,w)$ for every $w\in W$, and let the GLRT use the plug-in statistic
     of an estimator $\hat\theta$ and recommend $i$ when $\hat\theta$ is close to $\theta$.
     Suppose that for all neighbourhoods $U$ of $\theta$ and $V$ of $W$ there are events $E_T$
     with $\sum_TP(E_T^c)<\infty$ on which $\hat\theta_T\in U$ and $N(T)/T\in V$ after $T$
     rounds (*convergence of the allocations*; the sampling rules obtain it on a window
     $h(T)\le t\le T$). Prove that $\mathbb E[\tau_\delta]\le c\log(1/\delta)$ for all small
     $\delta$, for every
     $c>(\inf_{w\in W}D(\theta,w,\neg i))^{-1}$, for every family of thresholds with
     $\beta_t(h,\delta)\le\log(1/\delta)+g(\delta)+f(t)$ for all histories, with
     $g(\delta)=o(\log(1/\delta))$ as $\delta\to0$ and $f(t)=o(t)$ [GK16, proof of Theorem 14]. The
     thresholds of item 2 are cases, and so are $\log(r(t)/\delta)$ with $r(t)=O(t^\alpha)$.
     LMLExplore's `IdentTask.eventually_expectedStoppingTime_glrt_le` (linear growth of the
     statistic on good events), the case $g=0$, is the step after the lower semicontinuity.
   - Almost sure: with the same statistic, recommendation and thresholds, if almost surely
     $\hat\theta_t\to\theta$ and the distance from $N(t)/t$ to $W$ tends to $0$, prove that
     almost surely, for every $c>(\inf_{w\in W}D(\theta,w,\neg i))^{-1}$,
     $\tau_\delta\le c\log(1/\delta)$ for all small $\delta$ [GK16, Proposition 13].
   - Non-asymptotic:
     $\mathbb E[\tau]\le T_0(\delta)+\sum_tP(E_t^c)$ where $T_0(\delta)$ solves the stopping
     inequality [DKM19, Lemmas 1–2; DK19, Lemma 13].
   - State them for arbitrary tasks, estimators and history-dependent thresholds, so that each
     sampling rule below (D- and C-tracking, Sticky Track-and-Stop, the game-based, Top Two and
     Frank–Wolfe rules) only proves the convergence of its allocations on such events, given the
     concentration of the estimator under sufficient exploration (Layer 5.1).
5. **Unknown variances.** For the Gaussian model with unknown variances (Layer 1.3), prove that
   the cost of the alternatives with a common mean $\lambda$ for two arms is
   $\sum_c\frac{w_c}2\log\big(1+\frac{(\mu_c-\lambda)^2}{\sigma_c^2}\big)$ (Layer 1.4), define the
   GLR statistic as the plug-in statistic of item 3 for the empirical means and variances, and
   prove the $\delta$-correctness of its stopping rule with the thresholds of [JDK23a], through the
   transfer of item 1 for events about the per-arm sums of $Y$ and $Y^2$. The lower bound of this
   model is Layer 2.3.

Generalization: arbitrary tasks with exponential-family arms, where [GK16] treats best arm
identification; plug-in statistics of any estimator, history-dependent thresholds and covers of
the alternatives, and conditional domination by any cumulant generating function.

## Layer 5: Tracking and asymptotically optimal sampling rules

1. **Tracking.**
   - Prove the guarantees of C-tracking ($|N_a(t)-\sum_{s<t}w_a(s)|\le K(1+\sqrt t)$ for the
     $\varepsilon_t$-projected targets) and D-tracking ($N_a(t)\ge(\sqrt t-K/2)_+-1$, and
     convergence of the proportions when the targets converge) [GK16, Lemmas 7, 8, 15, 17, 20,
     Proposition 9].
   - Prove cumulative tracking [DKM19, Lemma 7].
   - **Sufficient exploration in event form** [GK16, Lemma 19]. For arms dominated by exponential
     families and any sampling rule, prove: if on events $G_T$ every arm has at least $g(t)$ pulls
     at every round $t\in[h(T),T]$, for a nondecreasing $g$, then the probability of $G_T$ and of
     an empirical mean farther than $\xi$ from $\mu$ at some round $t\in[h(T),T]$ is at most
     $B\exp(-C\,g(h(T)))$, for constants $B,C>0$ depending on $\xi$ and the families (from
     LMLExplore's `measure_exists_le_pullCount_and_empMean_notMem_Ioo_le`). With $g(t)=\sqrt t-K/2$
     and $h(T)=T^{1/4}$ this is summable in $T$. The exploration is an event, not a deterministic
     property of the sampling rule, so that Top Two rules, which explore only with high
     probability, use it; D-tracking's forced exploration is the case $G_T=\Omega$.
2. **Track-and-Stop.**
   - Define Track-and-Stop for any single-answer task and an estimator $\hat\theta$ (C- or
     D-tracking of a measurable selection of $w^*(\hat\theta)$, the plug-in GLRT stopping rule of
     Layer 4.3 with history-dependent thresholds, and the answer of $\hat\theta$ as
     recommendation).
   - For per-arm exponential-family arms and the empirical means, prove that it is $\delta$-PAC
     with the thresholds of Layer 4.2 on every single-answer task [GK16, Proposition 12], and
     asymptotically optimal through Layer 4.4: with C-tracking whenever $w^*(\mu)$ is convex, in
     particular when it is unique [DK19, Lemma 6, Theorem 7]; with D-tracking when $w^*(\mu)$ is a
     singleton and continuous at $\mu$. For best arm identification this is
     $\limsup_{\delta\to0}\mathbb E_\mu[\tau_\delta]/\log(1/\delta)\le T^*(\mu)$ for
     $\beta(t,\delta)=\log(r(t)/\delta)$ and $r(t)=O(t^\alpha)$ with any $\alpha\ge1$, which
     improves the constant $\alpha T^*(\mu)$, $\alpha\in[1,e/2]$, of [GK16, Theorem 14]; also
     prove the almost-sure version [GK16, Proposition 13]. LMLExplore
     proves these for Gaussian arms (`Identification/GaussianThreshold.lean`), which become a
     corollary.
   - For the two-parameter Gaussian model, prove that Track-and-Stop with the empirical means and
     variances as estimator and the thresholds of Layer 4.5 is $\delta$-PAC and asymptotically
     optimal for the characteristic time of that model [JDK23a].
   - Prove that for multiple answers Track-and-Stop reaches only
     $\max_{w\in\mathrm{conv}\,w^*(\mu)}D(\mu,w)^{-1}$ [DK19, Theorems 7, 9].
3. **Sticky Track-and-Stop** [DK19, Algorithm 1].
   - Define the sticky answer: the least oracle answer of a model of a small confidence region,
     for a fixed linear order on $\mathcal I$.
   - Prove that Sticky Track-and-Stop is $\delta$-correct and asymptotically optimal on every
     multiple-answer task with finitely many answers whose costs satisfy either continuity
     hypothesis of Layer 3.3 [DK19, Theorems 10–11, Corollary 12, Lemmas 13–17].

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
     $\limsup_{\delta\to0}\mathbb E_\mu[\tau_\delta]/\log(1/\delta)\le T^*_\beta(\mu)$, through
     the reduction of Layer 4.4 and the sufficient exploration in event form of Layer 5.1.
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

Throughout, "σ²-sub-Gaussian arms" and "laws on $[0,1]$" are the restricted tasks on the model of
all bandits with real observations (Layer 1.1): the guarantees hold for every bandit of the class.

1. **Successive elimination** [EMM02, Theorem 3; EMM06, Theorem 8]. For σ²-sub-Gaussian arms,
   define successive elimination as a phased-elimination algorithm (Layer 0.5: each phase pulls
   every active arm once) with the time-uniform confidence intervals of the Bandits roadmap's
   Layer 1.2. Prove that it is $\delta$-PAC for best arm identification and that, with probability
   at least $1-\delta$, it stops after at most $\sum_a c\,\sigma^2\Delta_a^{-2}\log(K/(\delta\Delta_a))$
   samples, with the explicit constant of the proof.
2. **Median elimination** [EMM02, Theorem 4; EMM06, Theorem 10]. Define median elimination as a
   phased-elimination algorithm (Layer 0.5) and prove that it is $(\varepsilon,\delta)$-PAC
   (outputs an $\varepsilon$-best arm with probability at least $1-\delta$) with at most
   $c\,K\varepsilon^{-2}\log(1/\delta)$ samples for σ²-sub-Gaussian arms, with the explicit
   constant.
3. **LUCB and KL-LUCB** [KTAS12; KK13]. Define LUCB and KL-LUCB for top-$m$ identification with
   tolerance $\varepsilon$, for σ²-sub-Gaussian arms and for laws on $[0,1]$ respectively.
   - Prove that their stopping rule is correct for every sampling rule under the condition on the
     exploration rate of [KTAS12, Theorem 1].
   - Prove that the stopping rule of KL-LUCB is correct for every sampling rule with the
     exploration rate $\log(k_1Kt^\alpha/\delta)+\log\log(k_1Kt^\alpha/\delta)$ and the constants
     $\alpha,k_1$ of [KK13, Theorem 1], from the self-normalized deviations of Layer 4.2
     [GC11, Theorem 10].
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

Rewards in $[0,1]$ and σ²-sub-Gaussian rewards are the restricted tasks of Layer 1.1, as in
Layer 7.

1. **Successive rejects** [ABM10]. Define successive rejects as a phased-elimination algorithm
   (Layer 0.5) and prove
   $P(\text{error})\le\frac{K(K-1)}2\exp\!\big(-\frac{T-K}{\overline{\log}(K)H_2}\big)$ for rewards
   in $[0,1]$, with $\overline{\log}(K)=\frac12+\sum_{i=2}^K\frac1i$, $\Delta_{(1)}\le\dots\le
   \Delta_{(K)}$ the gaps in increasing order with $\Delta_{(1)}=\Delta_{(2)}$, and
   $H_2=\max_ii\,\Delta_{(i)}^{-2}$ [ABM10]. Prove $H_2\le H_1\le\overline{\log}(2K)H_2$ for
   $H_1=\sum_i\Delta_{(i)}^{-2}$.
2. **Sequential halving** [KKS13]. Define sequential halving as a phased-elimination algorithm
   (Layer 0.5) and prove
   $P(\text{error})\le3\log_2K\exp\!\big(-\frac{T}{8H_2\log_2K}\big)$ [KKS13] for rewards in
   $[0,1]$ ([LS, Theorem 33.10] proves it for 1-sub-Gaussian rewards with $16$ in place of $8$;
   state the σ²-sub-Gaussian version).
3. **Large deviations under static allocations.**
   - For independent samples with fixed proportions $w$ of arms with any laws on `ℝ` whose
     cumulant generating function is finite on a neighbourhood of $0$, prove the large deviation
     upper and lower bounds for the vector of empirical means, with the rate functions $I_a$ of
     Layer 1.2: Cramér's theorem for each arm [DZ98, Theorem 2.2.3], the upper bound from the
     Cramér–Chernoff bound and the lower bound by exponential tilting at the levels that are means
     of the exponential family generated by the law and by truncation at the other levels of
     finite rate, and independence across the arms.
   - Deduce that the static-proportions algorithm recommending $i^*(\hat\mu)$, for a task asking
     about the means (Layer 1.1), has error exponent the infimum of $\sum_aw_a\,I_a(x_a)$ over the
     vectors of means $x$ for which $i^*(\mu)$ is not correct [GJ04]. For exponential-family arms,
     $I_a(x)=d_a(x,\mu_a)$ on the means, and the exponent is
     $\inf_{\lambda\in\neg i^*(\mu)}\sum_aw_a\,d(\lambda_a,\mu_a)$ (alternative first)
     [D23, Theorems 1, 12].
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
   `φ : α → E` and noise σ²-sub-Gaussian or Gaussian, the linear model has models $\theta\in E$
   and mean functional $\theta\mapsto(\langle\varphi(a),\theta\rangle)_a$. Linear best arm
   identification, thresholding and the other tasks of Layer 1.1 are the tasks of Layer 1.1 for
   this mean functional, the pullbacks of the unstructured tasks along it when the noise law
   depends on the mean only; make no separate definitions. For a finite set `𝒵` of answers in
   `E`, define the transductive best-answer task
   $\operatorname{argmax}_{z\in\mathcal Z}\langle z,\theta\rangle$ [FJJR19]; best arm
   identification is the case $\mathcal Z=\varphi(\alpha)$.
2. **Characteristic time.** For Gaussian noise with known variances $\sigma_a^2$, prove
   $T^*(\theta)^{-1}=\max_{w\in\Delta_K}\min_{z\ne z^*}
   \frac{\langle\theta,z^*-z\rangle^2}{2\|z^*-z\|^2_{V_w^{-1}}}$ with
   $V_w=\sum_aw_a\sigma_a^{-2}\varphi(a)\otimes\varphi(a)$ and the convention of Layer 3.6 for
   $\|\cdot\|^2_{V_w^{-1}}$, equivalently
   $\max_w\inf_{\lambda\in\neg z^*}\frac12\|\theta-\lambda\|^2_{V_w}$
   [FJJR19, Theorem 1; DMSV20; JP20], as the case of the half-spaces
   $\{\lambda:\langle z^*-z,\lambda\rangle\le0\}$ of Layer 3.6; for a common variance $\sigma^2$
   this is the form $\langle\theta,z^*-z\rangle^2/(2\sigma^2\|z^*-z\|^2_{V_w^{-1}})$ with
   $V_w=\sum_aw_a\,\varphi(a)\otimes\varphi(a)$. Compare it with the G-optimal and
   $\mathcal X\mathcal Y$ allocations of [SLM14].
3. **Elimination with optimal designs.** Define RAGE (phased elimination with
   $\mathcal X\mathcal Y$-optimal designs and rounding) as a phased-elimination algorithm on the
   active answers (Layer 0.5) and prove that it is $\delta$-PAC with
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
  task-specific proofs, and the continuity theorem of Layer 3.3 discharges the continuity
  hypotheses of Sticky Track-and-Stop (Layer 5.3) for Any Low Arm with exponential-family arms.
- **Mean functionals:** with `Θ = α → ℝ` and `mean = id`, the tasks of Layer 1.1 are LMLExplore's
  tasks on vectors of means; the guarantees of successive elimination, median elimination and
  LUCB (Layer 7) quantify over every σ²-sub-Gaussian bandit, with no auxiliary bandit; best arm
  identification with unknown variances is `baiTask` for the two-parameter Gaussian model.
- **Vector families:** the Bregman form of Layer 1.3 for the two-parameter Gaussian family
  recovers `klDiv_gaussianReal_gaussianReal`.
- **Rate function:** for Bernoulli arms $\bar d(1,\mu)=\log(1/\mu)$, and for Gaussian arms
  $\bar d=d$ on $\mathbb R^2$; the Chernoff bound of Layer 1.2 at the level $1$ gives
  $P(\hat\mu_n=1)\le\mu^n$ for Bernoulli arms.
- **Stopping times:** the chain rule of Layer 2.1 applied to one algorithm and two stationary
  bandits gives `klDiv_stoppedHistMeasure_le`; Wald's identity of Layer 0.3 for a stationary
  environment gives `IsAlgEnvSeq.integral_sum_feedback_eq_sum_integral_pullCount_mul`.
- **Phased elimination:** successive elimination, median elimination, successive rejects,
  sequential halving and RAGE are all built with the constructor of Layer 0.5.
- **Fixed budget:** the fixed-budget lower bound of Layer 8.4 and the upper bounds of
  Layers 8.1–8.2 agree up to the $\log K$ factors stated.

Compilation of the suggested signatures checks their types, not the truth of their admitted
theorems or the completion of these milestones.

## References

T. Lattimore and Cs. Szepesvári, *Bandit Algorithms*, Cambridge University Press (2020),
Chapter 33, is the textbook account [LS] (Theorem 33.5 for the lower bound, Theorem 33.6 for
Track-and-Stop, Lemmas 33.7–33.8 for GLR thresholds, Theorem 33.10 for sequential halving), and
Section 4.6 describes the stack-of-rewards model.

- [ABM10] J.-Y. Audibert, S. Bubeck and R. Munos, *Best arm identification in multi-armed bandits*,
  COLT 2010.
- [AJG20] S. Agrawal, S. Juneja and P. Glynn, *Optimal δ-correct best-arm selection for
  heavy-tailed distributions*, ALT 2020.
- [BLM13] S. Boucheron, G. Lugosi and P. Massart, *Concentration Inequalities*, Oxford University
  Press (2013), Section 2.2 (the Cramér–Chernoff method).
- [BMDG05] A. Banerjee, S. Merugu, I. S. Dhillon and J. Ghosh, *Clustering with Bregman
  divergences*, JMLR 6 (2005), for the relative entropy of exponential families as a Bregman
  divergence.
- [BN78] O. Barndorff-Nielsen, *Information and Exponential Families in Statistical Theory*, Wiley
  (1978).
- [Bro86] L. D. Brown, *Fundamentals of Statistical Exponential Families*, IMS Lecture Notes 9
  (1986), Chapter 1.
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
- [DZ98] A. Dembo and O. Zeitouni, *Large Deviations Techniques and Applications*, 2nd ed.,
  Springer (1998), Section 2.2 (Cramér's theorem).
- [dRvEGK14] S. de Rooij, T. van Erven, P. D. Grünwald and W. M. Koolen, *Follow the leader if you
  can, hedge if you must*, JMLR 15 (2014).
- [EMM02] E. Even-Dar, S. Mannor and Y. Mansour, *PAC bounds for multi-armed bandit and Markov
  decision processes*, COLT 2002.
- [EMM06] E. Even-Dar, S. Mannor and Y. Mansour, *Action elimination and stopping conditions for
  the multi-armed bandit and reinforcement learning problems*, JMLR 7 (2006).
- [FJJR19] T. Fiez, L. Jain, K. Jamieson and L. Ratliff, *Sequential experimental design for
  transductive linear bandits*, NeurIPS 2019.
- [FKV14] E. A. Feinberg, P. O. Kasyanov and M. Voorneveld, *Berge's maximum theorem for
  noncompact image sets*, J. Math. Anal. Appl. 413 (2014).
- [GC11] A. Garivier and O. Cappé, *The KL-UCB algorithm for bounded stochastic bandits and
  beyond*, COLT 2011.
- [GMS19] A. Garivier, P. Ménard and G. Stoltz, *Explore first, exploit next: the true shape of
  regret in bandit problems*, Math. Oper. Res. 44 (2019).
- [GJ04] P. Glynn and S. Juneja, *A large deviations perspective on ordinal optimization*, Winter
  Simulation Conference 2004.
- [GK16] A. Garivier and E. Kaufmann, *Optimal best arm identification with fixed confidence*,
  COLT 2016.
- [HRMS20] S. R. Howard, A. Ramdas, J. McAuliffe and J. Sekhon, *Time-uniform Chernoff bounds via
  nonnegative supermartingales*, Probability Surveys 17 (2020).
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
- [WJ08] M. J. Wainwright and M. I. Jordan, *Graphical models, exponential families, and
  variational inference*, Foundations and Trends in Machine Learning 1 (2008), Section 3.
- [WTP21] P.-A. Wang, R.-C. Tzeng and A. Proutière, *Fast pure exploration via Frank–Wolfe*,
  NeurIPS 2021.
