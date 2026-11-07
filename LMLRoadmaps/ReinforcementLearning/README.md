# Roadmap: Markov decision processes and reinforcement learning theory

Develop the theory of Markov decision processes and of learning to control them. On the planning
side, the headline results are:
- the optimality equations for the finite-horizon, discounted and average-reward criteria, with
  ε-optimal deterministic policies for countable action sets and optimal deterministic stationary
  policies for finite and compact ones;
- the convergence of value iteration, policy iteration and their variants;
- the linear programs of discounted MDPs and their occupancy measures;
- the Laurent expansion of discounted values and the existence of Blackwell-optimal policies.

On the learning side, the headline results are the sample complexity and regret bounds that settled
the field's basic questions:
- planning with a generative model: Azar–Munos–Kappen, Agarwal–Kakade–Yang, and Li–Wei–Chi–Gu–Chen
  over the full range of accuracies;
- the tight analysis of Q-learning, and finite-time temporal-difference learning with linear
  features;
- the convergence of policy gradient, natural policy gradient and policy mirror descent, including
  linear rates and their optimality;
- the minimax regret of episodic exploration, from UCBVI and optimistic Q-learning to the
  horizon-free MVP and the settling bound of Zhang–Chen–Lee–Du, matched by the lower bounds of
  Domingues–Ménard–Kaufmann–Valko;
- reward-free exploration and best policy identification;
- adversarial MDPs;
- UCRL2 and average-reward sample complexity;
- pessimism in offline reinforcement learning;
- least-squares value iteration with linear function approximation.

Build every prerequisite as a library in its own field, at the generality other fields need:
- order-unit contractions, abstract dynamic programming without attainment of the supremum, span
  seminorms and topical maps;
- Markov processes on general measurable spaces: the Markov and strong Markov properties, kernels
  as operators and resolvents as the inverses $(1-\gamma P)^{-1}$, the Dobrushin coefficient,
  mixing, the Poisson equation and the total-variance identity;
- Yosida's mean ergodic theorem and group inverses, with finite Markov chains;
- Freedman's inequality, empirical Bernstein, $\ell^1$ and KL deviations of empirical laws,
  covering numbers;
- the Robbins–Siegmund theorem, Robbins–Monro and asynchronous stochastic approximation;
- smooth nonconvex optimization and Bregman proximal steps on products of simplices;
- the keyed-stream model of adaptively collected data and the divergence decomposition regrouped by
  keys.

`README.md` is the definitive specification; `Suggested.lean` records selected interfaces and is
not an exhaustive checklist.

Suggested homes:
- `LMLExplore/MarkovDecisionProcess/` for planning;
- `LMLExplore/ReinforcementLearning/` for learning;
- the mathematical home named in each prerequisite layer.

## Scope and dependencies

This roadmap owns Markov decision processes and reinforcement learning:
- the planning theory of MDPs (Layers 7–13);
- learning in MDPs (Layers 14–23), with a generative model, online, adversarially, offline and with
  linear function approximation;
- the prerequisites of Layers 0–6, where no other roadmap specifies them.

| Material | Owner and interface consumed here |
| --- | --- |
| Interaction protocol, runs, trajectory measure, environments, identification algorithms | LML `SequentialLearning/`: `Algorithm`, `Environment`, `IsAlgEnvSeq`, `trajMeasure`, `stationaryEnv`, `obliviousEnv`, `IdentAlg`, `pullCount`, `streamMeasure` |
| MDPs and their environment | LML's `mdp` branch, not at the pinned version: `MDP 𝓢 𝓐 𝓡` with fields `P : Kernel (𝓢 × 𝓐) 𝓢` and `R : Kernel (𝓢 × 𝓐) 𝓡`, `MDP.env`, `MDP.policyAlg`, `MDP.meanReward`. Follow its names and shapes (Layer 7.1) |
| Episodic MDPs, episodes as rounds | entropy-mdp (Existing formalizations): `EpisodicMDP`, `augmented`, `Policy`, `statesEnv`, `BPIAlg` |
| Kernels, Ionescu–Tulcea, invariant measures, total variation | Mathlib `Probability/Kernel/`, `Kernel.traj`, `condExp_traj`, `Kernel.Invariant`, `tvDist` |
| Path laws of Markov chains; countable-state classification, recurrence, period, coupling | Tau Ceti `Probability/Process/MarkovChain.lean` (`markovChainLaw`) and the MarkovChainsAndRenewal roadmap: follow its names, and cite it for the countable-state theory |
| Ville's inequality, time-uniform sub-Gaussian bounds, method of mixtures, binary relative entropy, Bretagnolle–Huber | Bandits roadmap, Layers 0–1 and 4 (in LMLExplore) |
| FTRL, mirror descent, exponential weights, Legendre functions; implicit exploration | Bandits roadmap, Layers 6–7 |
| The descent lemma for smooth functions; Gibbs mixtures and their variational formula | OnlineLearning roadmap, Layers 1.3 and 10.1 |
| Design operators, ridge regression, self-normalized bounds, elliptical potential, Kiefer–Wolfowitz | Bandits roadmap, Layer 8 |
| Chain rule for the KL divergence of stopped histories at a stopping time, for arbitrary pairs of environments [GMS19, §2], and its bandit regrouping; data processing for `klBer` | Identification roadmap, Layers 2.1–2.2 |
| Transfer of every event about the first $s$ rewards of each arm from runs to reward streams | Identification roadmap, Layer 4.1 |
| Conditional MGF domination $\mathbb E[e^{\lambda X}\mid\mathcal F]\le e^{\psi(\lambda)}$, its exponential supermartingale and its time-uniform bound through Ville's inequality | Identification roadmap, Layer 4.2 |
| Wald's identity at a stopping time, for any environment | Identification roadmap, Layer 0.3 |
| Stream model of bandits; probability vectors | LML `Online/Bandit/ArrayProbSpace.lean`; LMLExplore `Bandits/SumRewards.lean`, `Analysis/Convex/Simplex.lean` (`simplex`) |
| Independent Bernstein inequality | built here (Layer 3.1) in the statement shape of Tau Ceti's RandomMatrices roadmap, Layer 2.1; LML `HasSubexponentialMGF` |
| KL divergence, chain rule, Pinsker, Donsker–Varadhan | Mathlib, LML `ForMathlib/InformationTheory/`, Tau Ceti `InformationTheory/KullbackLeibler/` |
| Contractions, Neumann series, Cesàro means, covering numbers, stochastic matrices, suprema over compact sets | Mathlib `ContractingWith`, `geom_series_eq_inverse`, `birkhoffAverage`, `coveringNumber`, `Matrix.rowStochastic`, `Matrix.IsIrreducible`, `Matrix.IsPrimitive`, `IsCompact.continuous_sSup` |
| Measurable selection of minimizers of jointly continuous functions | Tau Ceti `Continuous.exists_measurable_isMinOn` |

Build missing material in this roadmap where it is listed as a target, and consume existing
implementations directly.

Outside this roadmap:
- general function approximation: eluder dimension, Bellman rank, Bellman–eluder dimension, the
  decision–estimation coefficient, and the algorithms built on them;
- policy optimization with function approximation (Q-NPG, log-linear policies), actor–critic
  methods, the ODE method and two-timescale stochastic approximation;
- finite-time stochastic approximation through Moreau envelopes, linear stochastic approximation
  with Markov noise beyond the TD bounds of Layer 16, rates for Robbins–Monro, asynchronous
  stochastic approximation with delays or vanishing bias, variance-reduced Q-learning;
- model-free algorithms with optimal regret (UCB-Advantage, Q-EarlySettled-Advantage), UCBVI with
  Bernstein bonuses [AOM17] (superseded by Layer 18), LSVI-UCB++, and optimal average-reward regret
  beyond UCRL2;
- instance-dependent sample complexity of PAC learning and best policy identification, and best
  policy identification algorithms other than reward-free exploration (BPI-UCBVI);
- the regret upper bound for linear mixture MDPs (UCRL-VTR+), whose source states it only up to
  logarithmic factors;
- constrained, robust and risk-sensitive MDPs, preference-based RL, imitation learning, partially
  observable MDPs, Markov games, Bayesian RL and Gittins indices;
- positive, negative and total-reward models and stochastic shortest paths [P, Chapter 7];
  unbounded rewards and the weighted sup norms on general spaces they need [P, §6.10]; admissible
  action sets $A(s)$ (every action is admissible in every state); semi-Markov and continuous-time
  models;
- average-reward linear programs and sensitive optimality equations [P, §§8.8–8.9, 9.3, 10.2–10.4];
  strongly polynomial bounds for policy iteration;
- optimal policies on general state spaces with infinite action sets beyond Layers 8.3 and 9.6
  (Kuratowski–Ryll-Nardzewski selection, [P, Theorem 6.2.12 (a), (d)]);
- general linear programming duality: the MDP linear programs are proved from the Bellman
  equations;
- Harris recurrence, geometric drift conditions, the pointwise ergodic theorem for Markov chains,
  the Markov-chain central limit theorem, general Perron–Frobenius theory, the construction of
  continuous-time Markov processes and their strong Markov property at general stopping times;
- Fano's and Assouad's methods; Maurer–Pontil's empirical Bernstein inequality (Layer 3.2 replaces
  it); Lyapunov's theorem for Hurwitz matrices.

## Conventions

**Sources and numbering.** Statements cite:
- Puterman, *Markov Decision Processes* (Wiley, 1994) as [P];
- Agarwal, Jiang, Kakade and Sun, *Reinforcement Learning: Theory and Algorithms*, version of
  31 January 2022, as [AJKS];
- Lattimore and Szepesvári, *Bandit Algorithms* (2020) as [LS];
- papers by the keys of the References, with the theorem numbers of the arXiv version listed there.

Puterman numbers decision epochs from 1 and writes λ for the discount factor. Lean rounds and steps
are numbered from 0: epoch $t$ of [P] is round $t-1$, and its λ is γ here. The first reward is
undiscounted in both. Where a source's statement contains an error, the roadmap states the corrected
statement and says so.

**Spaces.**
- States and actions live in measurable spaces `𝓢` and `𝓐`, and every definition is made in that
  generality.
- A finite action set is `[Fintype 𝓐] [Nonempty 𝓐] [MeasurableSingletonClass 𝓐]`, with
  `[DecidableEq 𝓐]` where needed. Countable and standard Borel action sets are stated with
  `[Countable 𝓐]` and `[StandardBorelSpace 𝓐]`.
- The learning layers 14–23 assume `[Fintype 𝓢] [Nonempty 𝓢] [MeasurableSingletonClass 𝓢]` as
  well, and write $S$ = `Fintype.card 𝓢` and $A$ = `Fintype.card 𝓐`.
- Never specialize to `Fin n`.

**Models.**
- An MDP is LML's `MDP 𝓢 𝓐 ℝ` from the `mdp` branch: a transition kernel `M.P : Kernel (𝓢 × 𝓐) 𝓢`
  and a reward kernel `M.R : Kernel (𝓢 × 𝓐) ℝ`, both Markov.
- The reward and the next state are drawn independently given the state and the action: the model
  has these two kernels, not a joint kernel `Kernel (𝓢 × 𝓐) (𝓡 × 𝓢)`. Planning depends on the
  rewards only through their means; learning from realized rewards uses their conditional
  independence from the next states (Layer 7.1).
- Its environment `M.env μ`, for `[Nonempty 𝓢]`, has the current state as observation and the
  reward as feedback. The next state is drawn by the observation kernel from the last state and
  action.
- Define these in LMLExplore with the branch's fields, names and namespaces (`MDP`, `Learning.MDP`).
  When LML merges its branch, the copy is deleted. The general reward space `𝓡` of `MDP 𝓢 𝓐 𝓡`
  serves the environment and the run lemmas of Layer 7.1, which are stated for every `𝓡`; the
  planning and learning theory takes `𝓡 = ℝ`.
- An episodic MDP is entropy-mdp's `EpisodicMDP 𝓢 𝓐`: transition and reward kernels indexed by
  steps $h\in\mathbb N$, with real rewards. The horizon $H$ is an argument of every quantity that
  depends on it.
- The mean reward is $r(s,a)$ = `MDP.meanReward M.R (s, a)`. That of an episodic MDP is
  entropy-mdp's curried `M.meanReward h s a`, defined as `MDP.meanReward (M.reward h) (s, a)`.
- Rewards are bounded where values are defined: $|x|\le C$ for `M.R p`-almost every $x$ and every
  $p$. Rewards in $[0,1]$ means `∀ p, ∀ᵐ x ∂(M.R p), x ∈ Set.Icc 0 1`. Deterministic rewards are
  `M.R = Kernel.deterministic r _`, or `M.HasRewardFn r` in the episodic case.
- Each learning item takes the reward model of its source:
  - rewards are stochastic, unknown and observed by the learner in Layers 16.2 (asynchronous
    Q-learning in `M.env μ`), 18.5–18.6 (in `episodeEnv`, Layer 7.7) and 21.1 (in `M.env μ`);
  - they are observed in the data in Layers 22.1–22.4 and 23.4;
  - they are deterministic in Layers 15, 16.1 (synchronous Q-learning), 16.3–16.4, 18.1–18.4, 19,
    21.2–21.3, 22.5 and 23.2–23.3, and known to the learner wherever it uses them;
  - Layer 17 uses exact values, which depend on the reward kernel only through its mean, and
    Layer 20 uses adversarial losses.

**Policies.**
- A history-dependent policy is an LML `Algorithm 𝓢 𝓐 ℝ`.
- A Markov policy is `π : ℕ → Kernel 𝓢 𝓐` with Markov kernels, run as `Algorithm.markov π`.
- A stationary policy is a Markov kernel `π : Kernel 𝓢 𝓐`.
- A deterministic stationary policy is a function `π : 𝓢 → 𝓐` with a separate measurability
  hypothesis, run as `MDP.policyAlg π hπ`.
- Episodic deterministic policies are the $H$-step policies `Fin H → 𝓢 → 𝓐` of entropy-mdp.

**Criteria.**
- The discount factor is `γ : ℝ≥0`, with `γ < 1` for the discounted criterion. The finite-horizon
  statements of Layer 8 hold for every `γ`; `γ = 1` is the undiscounted return.
- Rewards are maximized. Sources stated with costs (policy mirror descent) are translated once in
  Layer 17.
- Value functions are functions `𝓢 → ℝ`. Operator statements live on the Banach space
  `boundedMeasurable 𝓢` of Layer 0.1: kernels act on it by `Kernel.integralCLM` (Layer 1.4), and
  the Bellman operators are maps of it and of `boundedMeasurable (𝓢 × 𝓐)` (Layer 9.1).
  Contraction rates, resolvent identities and the expansions of Layers 2 and 13 are proved there,
  from the abstract results of Layers 0 and 2. Pointwise statements on `𝓢 → ℝ`, with explicit
  bounds, are corollaries.
- The sup norm is $\|v\|=\sup_s|v(s)|$: the norm of Layer 0.1 on a general space, Mathlib's sup
  norm on `𝓢 → ℝ` for finite `𝓢`.
- "Bounded measurable" means measurable with $\sup_s|v(s)|<\infty$.

**Episodes.**
- Steps $h<H$, episodes $k<K$, $V_H=0$, rewards per step in $[0,1]$ unless an item says
  otherwise.
- Transitions are stage-dependent unless a statement says *stationary transitions* (constant
  kernels).
- Counts are taken before the episode.
- Bounds stated by a source on the step clock $T=KH$ are restated with $K$.

**Theorem shapes.**
- Upper bounds hold for every run (`IsAlgEnvSeq`), with probabilities and expectations under its
  probability measure.
- Lower bounds are stated for `trajMeasure` and transferred to every run by LML's
  `IsAlgEnvSeq.map_trajectory`.
- Where a source states an explicit constant, state it. Otherwise state `∃ C > 0, ∀ …`, with `C`
  quantified before every problem parameter ($S$, $A$, $H$, $K$, $d$, γ, δ, ε and the MDP).
- Write logarithmic factors exactly as the source's proof gives them; never write Õ.
- Asymptotic statements are eventual inequalities, as in the Bandits roadmap.

**Generality.**
- Each prerequisite is stated at the generality of its own field:
  - Markov processes on measurable spaces, with a general totally ordered index where the
    statement does not need ℕ;
  - martingale inequalities for filtrations indexed by ℕ;
  - operators on ordered or Banach spaces.
- A result that a source states on finite spaces is stated on measurable spaces when its proof
  allows. Each layer says where it generalizes its sources.

**Namespaces.**
- MDP definitions and their API live in the namespaces of their upstream shapes: `Learning.MDP`
  (dot notation on `M`) and entropy-mdp's `Learning.MDP.Episodic`.
- Learning algorithms live in `LMLExplore.ReinforcementLearning`.
- General tools live in `LMLExplore` or in the namespace of the type they act on.
- LML's definitions keep their names.

## Existing library and design guidance

Consume these modules and extend their APIs rather than restating them. The pinned versions are LML
`53be244`, Mathlib `2e318fae` and Tau Ceti `cebc9b6`.

| Foundation | Existing source |
| --- | --- |
| Law of a run, uniqueness, filtrations | LML `IonescuTulceaSpace.lean` (`trajMeasure`, `IsAlgEnvSeq.map_trajectory`, `IT.isAlgEnvSeq_trajMeasure`), `Algorithm.lean` (`IsAlgEnvSeq.filtration`, `filtrationObs`, `filtrationAction`), `Means.lean` (`IsAlgEnvSeq.condExp_feedback_comp`) |
| Divergence of runs | LML `DivergenceDecomposition.lean` (`IsAlgEnvSeq.klDiv_map_history_stepKernel`, valid for all pairs of algorithms and environments), `StoppedHistory.lean`, `IdentificationAlg.lean`; LMLExplore `SequentialLearning/DivergenceDecomposition.lean`, `SequentialLearning/BretagnolleHuber.lean` |
| Streams of samples | LML `Online/Bandit/ArrayProbSpace.lean` (`streamMeasure`), `FiniteActions.lean` (`pullCount`, `rewardByCount`); LMLExplore `Bandits/SumRewards.lean` |
| Ionescu–Tulcea and Markov chains | Mathlib `Probability/Kernel/IonescuTulcea/Traj.lean` (`Kernel.traj`, `traj_comp_partialTraj`, `condExp_traj`, `trajMeasure`), `Kernel.Invariant`, `Kernel.IsIrreducible`; Tau Ceti `markovChainLaw`, `markovChainLaw_map_eval_succ` |
| Fixed points | Mathlib `ContractingWith` (`efixedPoint'`, `apriori_dist_iterate_fixedPoint_le`, `fixedPoint_lipschitz_in_map`), `OrderHom.lfp` |
| Operators on bounded measurable functions | Mathlib `geom_series_eq_inverse`, `isUnit_one_sub_of_norm_lt_one`; LMLExplore `Analysis/Normed/Lp/Measurable.lean` (`boundedMeasurable`), `Probability/Kernel/Operator.lean` (`Kernel.integralCLM`), `Probability/Kernel/Resolvent.lean` (`Kernel.resolvent`) |
| Measurable argmax over a finite type | LML `ForMathlib/MeasureTheory/Order/MeasurableArg.lean` (`argmax`, `measurable_argmax`, root namespace; not Mathlib's `Function.argmax`) |
| Martingales and concentration | Mathlib `measure_sum_ge_le_of_hasCondSubgaussianMGF`, martingale convergence; LML `SubExponential.lean` (`measure_sum_ge_le_of_hasCondSubexponentialMGF`); LMLExplore `Probability/Martingale/Ville.lean`, `SubGaussian.lean`, `Mixture.lean`, `SelfNormalized.lean` |
| Linear algebra for linear MDPs | LMLExplore `Analysis/InnerProductSpace/DesignOperator.lean`, `EllipticalPotential.lean`, `Ridge.lean` |
| Online learning | LMLExplore `OnlineLearning/FTRL.lean`, `Bandits/WeightAlgorithm.lean`; LML `Bregman/Basic.lean` (`bregDiv_three_point`) |

LML's history-dependent environments already give the Markov structure of runs: the observation
kernel at round $n+1$ sees the whole history. The roadmap adds the identification of state processes
with Tau Ceti's `markovChainLaw` (Layer 7.2) and the Markov property of chains (Layer 1.1).

## Existing formalizations

These are sources to adapt, not dependencies:
- **entropy-mdp** (Apache-2.0, `github.com/RemyDegenne/entropy-mdp`), a formalization of [EV26]
  that contains:
  - `EpisodicMDP`, the time-augmented MDP, $H$-step policies, `statesEnv` and `BPIAlg`;
  - values, occupancy measures and Bellman recursions;
  - the visit structure (`Visits.lean`) and concentration at visits;
  - empirical models;
  - the method of types and the time-uniform KL concentration of empirical distributions;
  - self-normalized Bernstein inequalities;
  - the change of measure for identification algorithms.
  
  Layers 3.4, 6, 7, 8, 11.4, 14 and 19 can adapt it.
- **brownian-motion** (Apache-2.0, `github.com/RemyDegenne/brownian-motion`):
  - `Continuity/CoveringNumber.lean` proves the volumetric bound `coveringNumber_closedEBall_le`
    of Layer 3.5;
  - its stopping-time API serves Layer 1.2.
  
  Its reflection principle (`IsBrownianReal.reflection`) needs the strong Markov corollary for
  independent increments of Layer 1.2.
- **rl-theory-in-lean** (MIT, `github.com/ShangtongZhang/rl-theory-in-lean`) [Zha25] proves the
  almost-sure convergence of Q-learning and of linear TD through Robbins–Siegmund on Mathlib. It is
  a source for Layers 4.1–4.3 and 16.2–16.4.

## Layers and dependencies

| Layer | Content | Prerequisites |
| --- | --- | --- |
| 0 | Order units, contractions and fixed points | Mathlib |
| 1 | Markov processes on general measurable spaces | Layer 0; Tau Ceti `markovChainLaw` |
| 2 | Mean ergodic theory and finite Markov chains | Layers 0–1 |
| 3 | Concentration | Bandits roadmap, Layer 1; Identification roadmap, Layer 4.2 |
| 4 | Stochastic approximation | Mathlib martingale convergence |
| 5 | Optimization | Bandits roadmap, Layer 6; OnlineLearning roadmap, Layers 1.3 and 10.1 |
| 6 | Sequential-learning tools: keyed streams, divergence decomposition by keys | LML; Identification roadmap, Layers 0.3, 2.1–2.2, 4.1 |
| 7 | MDPs, policies and values | Layers 0–1, 6 |
| 8 | Bellman operators and the finite horizon | Layers 0, 7 |
| 9 | Discounted optimality | Layers 0–1, 7–8; Tau Ceti selection |
| 10 | Discounted algorithms | Layers 0–1, 9 |
| 11 | Occupancy measures and linear programming | Layers 1, 9 |
| 12 | Value-difference calculus and variance identities | Layers 1, 9, 11 |
| 13 | Average reward and sensitive discount optimality | Layers 0–2, 9–10 |
| 14 | Learning infrastructure | Layers 3, 6, 7 |
| 15 | Planning with a generative model | Layers 3, 12, 14 |
| 16 | Q-learning and temporal-difference learning | Layers 1.7, 2, 4, 9, 14 |
| 17 | Policy optimization | Layers 5, 11–12 |
| 18 | Online episodic exploration | Layers 3, 6, 12, 14 |
| 19 | Reward-free exploration and best policy identification | Layers 3.4, 18 |
| 20 | Adversarial MDPs | Layers 3.2–3.3, 7.7, 11.4, 14; Bandits roadmap, Layers 6–7 |
| 21 | Average-reward learning | Layers 3.3, 6.2, 13, 14, 15 |
| 22 | Offline reinforcement learning | Layers 3, 11, 12, 14, 15 |
| 23 | Linear function approximation | Layers 3.5, 12, 14, 18, 22; Bandits roadmap, Layer 8 |

## Layer 0: Order units, contractions and fixed points

General analysis, without probability. Suggested home: `Analysis/FixedPoint/`.

1. **Bounded measurable functions.**
   - Prove that the measurable functions form a closed subalgebra `boundedMeasurable 𝓢` of
     Mathlib's `lp (fun _ : 𝓢 ↦ ℝ) ∞`, hence a Banach algebra, ordered pointwise. Its norm is
     $\sup_s|f(s)|$ (`lp.norm_eq_ciSup`).
   - It is the space of value functions of the operator statements (Conventions): kernels act on
     it (Layer 1.4), and the Bellman operators of Layers 9–10 are contractions of it. Do not
     introduce a separate bundled type.
2. **Order units and Blackwell's conditions** [Bla65], [GG04, §1].
   - Setting: an ordered real vector space $E$ with an order unit $e$: for every $x$ there is $c$ with
     $-ce\le x\le ce$. Define $\|x\|_e=\inf\{c\ge0:-ce\le x\le ce\}$.
   - If $T:E\to E$ is monotone and $T(x+ce)\le Tx+\gamma ce$ for all $x$ and $c\ge0$, prove
     $\|Tx-Ty\|_e\le\gamma\|x-y\|_e$.
   - Call $T$ *topical* if it is monotone and $T(x+ce)=Tx+ce$ for all $c\in\mathbb R$. Prove that a
     topical map is nonexpansive for $\|\cdot\|_e$ and for $\mathrm{osc}_e(x)=\inf\{b-a:ae\le x\le be\}$.
   - Instances, where $\|\cdot\|_e$ is the norm, so that Mathlib's `ContractingWith` applies:
     - `ι → ℝ` with `[Fintype ι]`, pointwise order, $e=1$;
     - the bounded measurable functions of item 1 with the pointwise order (to be defined on the
       subset of `lp`) and $e=1$.
   - The weighted sup norm $\max_i|x_i|/w_i$ is $\|\cdot\|_w$ for $e=w>0$. State the γ-Lipschitz
     bound for it; a metric instance is not needed here.
   - Blackwell's argument is proved once, in the order-unit form. The pointwise bounds on
     `𝓢 → ℝ` are its corollaries through `boundedMeasurable 𝓢`; LMLExplore's
     `abs_sub_le_of_monotone_of_add_const` repeats the argument and is replaced by them.
3. **Abstract dynamic programming** [Ber22, Chapter 2]. Let $X$ be one of the instances of item 2,
   with order unit $e$. Let $\{T_d\}_{d\in\mathcal D}$ be monotone maps of $X$ satisfying
   Blackwell's condition with a common $\gamma<1$, and let $T:X\to X$ be their uniform supremum:
   - $T_dx\le Tx$ for every $d$ and $x$;
   - for every $x$ and $\varepsilon>0$, some $d$ is *ε-greedy* for $x$: $Tx-\varepsilon e\le T_dx$.
   
   Then $Tx$ is the least upper bound of the $T_dx$ (Mathlib's `IsLUB`), and it need not be
   attained. A decision $d$ is *greedy* for $x$ when $T_dx=Tx$. Prove:
   - $T$ is monotone and satisfies Blackwell's condition, hence is a γ-contraction; write $x^*$ for
     its fixed point;
   - $x\ge Tx\Rightarrow x\ge x^*$ and $x\le Tx\Rightarrow x\le x^*$;
   - $\mathrm{fix}(T_d)\le x^*$ for every $d$, and every $d$ ε-greedy for $x^*$ has
     $x^*-\frac{\varepsilon}{1-\gamma}e\le\mathrm{fix}(T_d)$; hence $x^*$ is the least upper bound
     (`IsLUB`) of the $\mathrm{fix}(T_d)$;
   - every greedy $d$ for $x^*$ has $\mathrm{fix}(T_d)=x^*$; for finite $\mathcal D$, a greedy
     decision exists for every $x$;
   - policy iteration ($d_{k+1}$ greedy for $\mathrm{fix}(T_{d_k})$), whenever these greedy
     decisions exist, satisfies
     $\mathrm{fix}(T_{d_{k+1}})\ge T\,\mathrm{fix}(T_{d_k})\ge\mathrm{fix}(T_{d_k})$ and
     $\|\mathrm{fix}(T_{d_k})-x^*\|\le\gamma^k\|\mathrm{fix}(T_{d_0})-x^*\|$;
   - for finite $\mathcal D$, $\mathrm{fix}(T_{d_k})=x^*$ for some $k\le|\mathcal D|$;
   - modified policy iteration $x_{k+1}=T_{d_{k+1}}^{m_k+1}x_k$, with $d_{k+1}$ greedy for $x_k$
     (whenever these greedy decisions exist) and $Tx_0\ge x_0$, satisfies $T^kx_0\le x_k\le x^*$,
     hence $\|x_k-x^*\|\le\gamma^k\|x_0-x^*\|$.
   
   The hypothesis that $Tx$ is the least upper bound of the $T_dx$ does not replace the ε-greedy
   decisions (completion checks). LMLExplore's `Analysis/FixedPoint/DynamicProgramming.lean`
   assumes attainment, `IsGreatest (range fun d ↦ T d x) (B x)` for every $x$, which is the case
   where every $x$ has a greedy decision. State its results under the two hypotheses above, with
   policy iteration and modified policy iteration assuming in addition only the greedy decisions
   they use. Layers 9–10 are instances of this item: countable action sets through the
   ε-maximizers of item 6, finite ones through greedy policies.
4. **The span seminorm** [P, Theorem 6.6.2, §8.5].
   - Setting: $X$ is `ι → ℝ` with `ι` finite, or the bounded measurable functions of item 1.
     $\mathrm{osc}(x)=\sup x-\inf x$, and $T$ is topical with
     $\mathrm{osc}(T^Jx-T^Jy)\le\alpha\,\mathrm{osc}(x-y)$ for some $J\ge1$ and $\alpha<1$.
   - Prove that $T$ descends to a nonexpansive map of the quotient by constants (Mathlib's quotient
     normed spaces), by the oscillation bound of item 2 (LMLExplore's
     `IsTopical.orderUnitOsc_sub_le`), whose $J$-th iterate is an α-contraction.
   - Deduce that there are $g\in\mathbb R$ and $h$ with $Th=h+g$.
   - For relative value iteration $x_{n+1}=Tx_n-(Tx_n)(s_0)$, with $h(s_0)=0$, prove for $n\ge1$:
     - $\|x_n-h\|\le\alpha^{\lfloor n/J\rfloor}\mathrm{osc}(x_0-h)$;
     - $\|Tx_n-x_n-g\|\le2\alpha^{\lfloor n/J\rfloor}\mathrm{osc}(x_0-h)$.
5. **Vanishing discount for topical maps** [Koh80], [LS, Theorem 38.2]. Let $T$ be topical on
   `ι → ℝ` with `ι` finite, and $v_\gamma$ the fixed point of $x\mapsto T(\gamma x)$ for $\gamma<1$. If
   $\sup_\gamma\mathrm{osc}(v_\gamma)<\infty$, prove:
   - there are $g,h$ with $Th=h+g$ and $\mathrm{osc}(h)\le\sup_\gamma\mathrm{osc}(v_\gamma)$;
   - $(1-\gamma)v_\gamma\to g$ as $\gamma\uparrow1$;
   - $\|T^nx-ng\|\le\|x-h\|+\|h\|$.
6. **Measurable maximizers.**
   - For a finite index type, consume LML's `argmax`, `measurable_argmax`.
   - For `ℕ` as index type, let $f_i$ be measurable functions with $\sup_jf_j(x)<\infty$ for every
     $x$, and let $\varepsilon>0$. Prove that $x\mapsto\min\{i:f_i(x)>\sup_jf_j(x)-\varepsilon\}$ is
     measurable. Transport it to countable types through an enumeration.

Completion checks: the Bellman operator of a two-state, two-action MDP satisfies item 2 with $e=1$;
the max-plus map $x\mapsto(\max_jA_{ij}+x_j)_i$ is topical. On `Fin 2 → ℝ`, the maps
$T_a x=(1+\gamma x_2,\gamma x_1)$ and $T_b x=(\gamma x_2,1+\gamma x_1)$ satisfy Blackwell's
condition, and $Tx=\max(T_ax,T_bx)$ is their least upper bound. Its fixed point
$(1-\gamma)^{-1}(1,1)$ exceeds the least upper bound $(1-\gamma^2)^{-1}(1,1)$ of
$\mathrm{fix}(T_a)$ and $\mathrm{fix}(T_b)$: no decision is ε-greedy for it when $\varepsilon<1$,
and the conclusions of item 3 fail.

## Layer 1: Markov processes on general measurable spaces

Suggested homes: `Probability/Markov/` and `Probability/Kernel/`. These results need no countability
of the state space. Tau Ceti's MarkovChainsAndRenewal roadmap specifies the countable-state theory
(classification, recurrence, period, coupling). Follow its names and statement shapes:
- `markovChainLaw ν κ`;
- the path-law kernel $x\mapsto\mathbb P_x$;
- `WithTop ℕ` stopping times with `hittingAfter`;
- Mathlib's `tvDist` (values in $[0,2]$) and `Kernel.Invariant`.

Notation. A kernel acts on bounded measurable functions by $(\kappa f)(x)=\int f\,d\kappa(x)$ and on
measures by `μ.bind κ`. Operator products are read as operators on functions: $\kappa\eta$ is
`η ∘ₖ κ` (Mathlib's monoid product `η * κ`). For kernels, $(\kappa-\kappa')u$ means
$\kappa u-\kappa'u$ pointwise.

1. **Markov processes and the Markov property** [Kal21, Lemma 11.1, Proposition 11.2].
   - Let a process $X$ be indexed by a totally ordered type and adapted to a filtration
     $\mathcal F$. Define $X$ to be $\mathcal F$-Markov with transition kernels $\kappa_{s,t}$
     ($s\le t$), satisfying Chapman–Kolmogorov, by
     $\mathbb E[f(X_t)|\mathcal F_s]=(\kappa_{s,t}f)(X_s)$ almost surely for bounded measurable $f$.
   - Prove that the conditional law given $\mathcal F_s$ of $(X_{t_1},\dots,X_{t_n})$, for
     $s\le t_1\le\dots\le t_n$, is the iterated kernel product started at $X_s$.
   - The homogeneous case is a semigroup $\kappa_t$ indexed by ℕ or `ℝ≥0`.
   - Index ℕ:
     - $\nu$`.bind (κ ^ n)` is the time-$n$ law of `markovChainLaw ν κ`;
     - $x\mapsto\mathbb P_x$ is a Markov kernel with $\mathbb P_\nu=\nu$`.bind` $\mathbb P$;
     - the shifted path $\theta_nX$ has conditional law $\mathbb P_{X_n}$ given $\mathcal F_n$, with
       event and bounded-test-function forms;
     - a process is Markov for its natural filtration with initial law ν if and only if its law is
       `markovChainLaw ν κ`.
   - Build on Mathlib's `Kernel.traj`, `condExp_traj` and `traj_comp_partialTraj`. Construct path
     laws only for the index ℕ.
2. **Strong Markov property** [Kal21, Proposition 11.9].
   - For a homogeneous Markov process indexed by ℕ or `ℝ≥0` and a stopping time with countably
     many values, prove: on $\{\tau<\infty\}$ and conditionally on $\mathcal F_\tau$, the
     finite-dimensional laws of $(X_{\tau+t})_t$ are those of the process started at $X_\tau$. The
     values of $X_\tau$ outside that event do not matter.
   - Index ℕ: give the path-valued form.
   - For a process with independent and stationary increments in an additive group (Mathlib's
     `HasIndepIncrements`), prove that $(X_{\tau+t}-X_\tau)_t$ is independent of $\mathcal F_\tau$
     and has the law of $(X_t-X_0)_t$.
3. **First-step analysis** [Nor97, Theorems 1.3.2, 1.3.5]. Let $A$ be measurable and
   $H_A=\inf\{n\ge0:X_n\in A\}$. Prove:
   - $x\mapsto\mathbb P_x(H_A<\infty)$ is the minimal nonnegative solution of $h=1$ on $A$,
     $h=\kappa h$ off $A$;
   - $x\mapsto\mathbb E_x[H_A]\in[0,\infty]$ is the minimal solution `𝓢 → ℝ≥0∞` of $k=0$ on $A$,
     $k=1+\kappa k$ off $A$;
   - for measurable $f\ge0$ and $\gamma\in[0,1]$, $x\mapsto\mathbb E_x\sum_{t<H_A}\gamma^tf(X_t)$ is the
     minimal solution `𝓢 → ℝ≥0∞` of $u=0$ on $A$, $u=f+\gamma\kappa u$ off $A$.
4. **Kernels as operators; resolvents and occupation measures** [Rev84, Chapter 2], [P, §6.1].
   - A finite kernel acts on bounded measurable functions by the continuous linear map
     `κ.integralCLM : boundedMeasurable β →L[ℝ] boundedMeasurable α` (LMLExplore's
     `Kernel.integralCLM`). A Markov kernel acts positively, preserves constants and has operator
     norm at most $1$.
   - For $0\le\gamma<1$ define the resolvent $R_\gamma(\kappa)=\sum_n\gamma^n\kappa^n$, a finite
     kernel of mass $1/(1-\gamma)$, and the Markov kernel $G_\gamma=(1-\gamma)R_\gamma$. Prove:
     - $R_\gamma=1+\gamma\kappa R_\gamma=1+\gamma R_\gamma\kappa$ (operator products);
     - for a Markov kernel, $1-\gamma\,$`κ.integralCLM` is invertible in the Banach algebra of
       continuous linear maps of `boundedMeasurable α`, with inverse the action of $R_\gamma$,
       the Neumann series $\sum_n\gamma^n$`κ.integralCLM`$^n$ (Mathlib's
       `geom_series_eq_inverse`): $R_\gamma=(1-\gamma\kappa)^{-1}$;
     - $u=R_\gamma f$ is the unique bounded solution of $u=f+\gamma\kappa u$;
     - $R_\gamma$ is positive, $R_\gamma f\ge f$ for $f\ge0$, and $\sup|R_\gamma f|\le\sup|f|/(1-\gamma)$;
     - for a probability measure μ, $\nu=\mu$`.bind` $G_\gamma$ is the unique finite measure with
       $\nu=(1-\gamma)\mu+\gamma\,\nu$`.bind κ` (the flow equation);
     - $\mathbb E_\mu\sum_t\gamma^tf(X_t)=\int f\,d(\mu R_\gamma)$;
     - $G_\gamma(x)$ is the law of $X_T$ for an independent geometric time $T$ with
       $P(T=n)=(1-\gamma)\gamma^n$.
5. **Resolvent identities** [AKLM21, Lemma 3.2].
   - In any module: if $x=r+Ax$ and $1-A$ is invertible, then $x-y=(1-A)^{-1}(r+Ay-y)$ for every
     $y$.
   - For kernels, prove the performance-difference identity
     $R_\gamma(\kappa)r-y=R_\gamma(\kappa)(r+\gamma\kappa y-y)$ for bounded measurable $y$.
   - Prove the simulation identity with two rewards, for bounded measurable $r,r'$:
     $R_\gamma(\kappa)r-R_\gamma(\kappa')r'=R_\gamma(\kappa')\big((r-r')+\gamma(\kappa-\kappa')R_\gamma(\kappa)r\big)$.
     It is the performance-difference identity for $\kappa'$, $r'$ and $y=R_\gamma(\kappa)r$. LMLExplore's
     `Kernel.integral_resolvent_sub_integral_resolvent` is the case $r=r'$ with the roles of
     $\kappa$ and $\kappa'$ exchanged.
   
   Layer 12.2's performance difference and simulation lemmas are instances.
6. **Dobrushin coefficient and uniform ergodicity** [Dob56], [LPW17, Theorem 4.9], [P,
   Proposition 6.6.1]. Define $\delta(\kappa)=\sup_{x,y}\mathrm{tvDist}(\kappa x,\kappa y)/2$. Call a
   Markov kernel *uniformly ergodic* if it has an invariant probability π with
   $\sup_x\mathrm{tvDist}(\kappa^nx,\pi)\to0$. Prove:
   - for probability measures μ, ν, $\mathrm{tvDist}(\mu\kappa,\nu\kappa)\le\delta(\kappa)\,\mathrm{tvDist}(\mu,\nu)$;
   - $\mathrm{osc}(\kappa f)\le\delta(\kappa)\,\mathrm{osc}(f)$;
   - $\delta(\kappa\eta)\le\delta(\kappa)\delta(\eta)$;
   - the Doeblin condition $\kappa x\ge\varepsilon\varphi$ for a probability φ gives
     $\delta(\kappa)\le1-\varepsilon$;
   - for finite spaces, $\delta(P)=1-\min_{x,y}\sum_z\min(P(x,z),P(y,z))$;
   - on a nonempty space, if $\delta(\kappa^m)<1$, then κ has a unique invariant probability π, and
     $\sup_x\mathrm{tvDist}(\kappa^nx,\pi)\le2\delta(\kappa^m)^{\lfloor n/m\rfloor}$;
   - conversely, a uniformly ergodic kernel has $\delta(\kappa^m)<1$ for some $m$.
   
   Build π as the uniform setwise limit, without completeness of signed measures in total variation.
7. **Mixing times and decoupling** [LPW17, §4.5], [BRS18, Lemma 9]. For a kernel with invariant
   probability π, define $d(t)=\sup_x\mathrm{tvDist}(\kappa^tx,\pi)/2$ and
   $t_{\mathrm{mix}}(\varepsilon)=\inf\{t:d(t)\le\varepsilon\}$ in `ℕ∞`. Prove:
   - $d(t)\le\delta(\kappa^t)\le2d(t)$;
   - $t_{\mathrm{mix}}(\varepsilon)\le\lceil\log_2(1/\varepsilon)\rceil\,t_{\mathrm{mix}}(1/4)$;
   - $\sup_x\mathrm{tvDist}(\kappa^tx,\pi)\le2^{-\lfloor t/t_{\mathrm{mix}}(1/4)\rfloor}$ for
     $t\ge t_{\mathrm{mix}}(1/4)$, when $t_{\mathrm{mix}}(1/4)<\infty$ [JS21, Lemma 1], from
     $d(\ell s)\le d(s)(2d(s))^{\ell-1}$;
   - the β-mixing bound: for $X$ started anywhere, the law of (past up to $t$, future from
     $t+\tau$) is within total variation $2\delta(\kappa^\tau)$ of the product of its marginals.
8. **Poisson equation and the law of large numbers** [MT09, Chapter 17].
   - If a bounded measurable $g$ solves $g-\kappa g=f-c$, prove that
     $\sum_{k<n}(f(X_k)-c)=g(X_0)-g(X_n)+M_n$, with $M$ a martingale whose increments lie in intervals
     of length $\mathrm{osc}(g)$.
   - Deduce $\frac1n\sum_{k<n}f(X_k)\to c$ almost surely and in $L^2$, and the Hoeffding bound
     $P(|\frac1n\sum_{k<n}f(X_k)-c|\ge\varepsilon)\le2\exp(-2(n\varepsilon-\mathrm{osc}(g))_+^2/(n\,\mathrm{osc}(g)^2))$.
   - If $\delta(\kappa^m)<1$, prove that $g=\sum_n(\kappa^nf-\pi f)$ converges uniformly, with
     $\sup|g|\le m\,\mathrm{osc}(f)/(1-\delta(\kappa^m))$, and solves the equation with $c=\pi f$,
     uniquely up to constants among bounded solutions.
   
   Layer 13.1 uses it for the almost-sure average reward.
9. **The total-variance identity** [Sob82], [AMK13].
   - For bounded measurable $r$, $G=\sum_t\gamma^tr(X_t)$ and $V(x)=\mathbb E_xG$, prove
     $\mathrm{Var}_x(G)=\sum_t\gamma^{2(t+1)}(\kappa^t\sigma^2_V)(x)$ with
     $\sigma^2_V=\kappa(V^2)-(\kappa V)^2$.
   - Finite horizon, with kernels $\kappa_h$, $G=\sum_{h<H}r_h(X_h)$ and
     $V_h(x)=\mathbb E[\sum_{h'\ge h}r_{h'}(X_{h'})|X_h=x]$: prove
     $\mathrm{Var}(G)=\mathrm{Var}(V_0(X_0))+\sum_{h<H-1}\mathbb E[\sigma^2_{h}(X_h)]$, where
     $\sigma^2_h=\kappa_h(V_{h+1}^2)-(\kappa_hV_{h+1})^2$.
   
   Layer 12.3's variance identities are instances.

Completion checks: a random walk on a cycle of even length has Dobrushin coefficient one, while its
lazy version is uniformly ergodic; the Poisson solution of a two-state chain is explicit; the
increments of a Lévy process at a stopping time with countably many values satisfy item 2.

## Layer 2: Mean ergodic theory and finite Markov chains

1. **Yosida's mean ergodic decomposition** [Kre85, §2.1].
   - For a continuous linear $T$ on a real Banach space with $\sup_n\|T^n\|<\infty$, prove that
     the Cesàro means (Mathlib's `birkhoffAverage`) converge exactly on the closed subspace
     $\ker(1-T)\oplus\overline{\mathrm{range}(1-T)}$.
   - Prove that the limit Π is a bounded projection onto $\ker(1-T)$ along
     $\overline{\mathrm{range}(1-T)}$, with $\Pi T=T\Pi=\Pi^2=\Pi$.
   - In finite dimension, the decomposition is the whole space and the means converge in operator
     norm.
2. **Group inverse and Laurent expansion** [P, Theorems A.7–A.8], [LS, Exercises 38.7, 38.9].
   Assume in addition that $\mathrm{range}(1-T)$ is closed and complementary to $\ker(1-T)$ (always
   true in finite dimension). Prove:
   - $1-T+\Pi$ is invertible, and $D=(1-T+\Pi)^{-1}-\Pi$ satisfies $(1-T)D=D(1-T)=1-\Pi$ and
     $D\Pi=\Pi D=0$;
   - $D$ is the Cesàro limit of $\sum_{k<n}(T^k-\Pi)$;
   - for $0<\gamma<1$ and $u=(1-\gamma)/\gamma$ with $u\|D\|<1$:
     $(1-\gamma T)^{-1}=(1+u)\big(u^{-1}\Pi+\sum_{n\ge0}(-u)^nD^{n+1}\big)$;
   - hence $(1-\gamma)(1-\gamma T)^{-1}\to\Pi$ and
     $((1-\gamma)(1-\gamma T)^{-1}-\Pi)/(1-\gamma)\to D$ as $\gamma\uparrow1$;
   - for every $r$, $(g,h)=(\Pi r,Dr)$ is the unique solution of $(1-T)g=0$, $g+(1-T)h=r$,
     $\Pi h=0$.
3. **Finite chains.**
   - Define the adapter `Matrix.toKernel` from `Matrix.rowStochastic ℝ S` to Markov kernels on a
     finite `S` with measurable singletons, and its inverse. It is an anti-homomorphism for
     Mathlib's monoid of kernels: `toKernel (P * Q) = toKernel Q * toKernel P`. Prove that it maps
     powers to powers and `vecMul` to `bind`.
   - Define accessibility, communicating classes and closed communicating classes. For finite
     chains, the closed communicating classes are the recurrent classes, and the states outside them
     are transient.
   - Define *unichain*: exactly one closed communicating class.
   - Prove the equivalence of irreducibility with Mathlib's `Matrix.IsIrreducible`.
4. **Limiting and deviation matrices.** For a stochastic matrix $P$, specialize items 1–2 to $P^*$
   and $D_P$. Prove:
   - $P^*$ is stochastic and $PP^*=P^*P=P^*P^*=P^*$;
   - every row of $P^*$ is invariant, so every finite chain has an invariant probability;
   - $D_P=\sum_n(P^n-P^*)$ when $P^n$ converges.
5. **Unichain and primitive chains** [LPW17, Lemma 1.16, Corollary 1.17]. Prove:
   - the maximum principle: an irreducible chain has only constant harmonic functions;
   - a unichain chain has $\ker(I-P)=\mathrm{span}\,\mathbf 1$, a unique invariant law π, positive
     exactly on the closed class, and $P^*=\mathbf1\pi^\top$;
   - a primitive chain (Mathlib's `Matrix.IsPrimitive`) has $\delta(P^m)<1$ for some $m$, hence
     geometric convergence by Layer 1.6.
   
   General Perron–Frobenius theory is not needed.
6. **Rational dependence on the discount** [P, Lemma 10.1.3]. Prove that the entries of
   $(I-\gamma P)^{-1}$ are rational functions of γ with denominator $\det(I-\gamma P)$, nonzero on
   $[0,1)$, and numerators of degree at most $|S|$. A rational function on an interval vanishes
   identically or has finitely many zeros: use Mathlib's `Polynomial.eq_zero_of_infinite_isRoot`.

Completion checks: the two-state periodic chain has $P^*=\frac12\mathbf1\mathbf1^\top$ but no
limit of $P^n$; a chain with two absorbing states has two distinct invariant rows in $P^*$.

## Layer 3: Concentration

Suggested homes: `Probability/Martingale/`, `Probability/Moments/`, `InformationTheory/`,
`Topology/MetricSpace/`. Consume:
- Ville's inequality and the time-uniform sub-Gaussian bounds of the Bandits roadmap's Layer 1;
- the conditional MGF domination of the Identification roadmap's Layer 4.2, with its exponential
  supermartingale and its time-uniform bound;
- LML's `HasSubexponentialMGF` bounds.

Martingale differences are indexed as in Mathlib's Azuma–Hoeffding: $X_t$ is
$\mathcal F_{t+1}$-measurable, with conditional laws given $\mathcal F_t$.

1. **Freedman's inequality** [Fre75], [LS, Exercises 5.14–5.15], [BLM13, Theorems 2.9–2.10],
   [HRMS20]. Let $X_t$ be $\mathcal F_{t+1}$-measurable with $X_t^2$ integrable and
   $\mathbb E[X_t|\mathcal F_t]\le0$. Write $S_n=\sum_{t<n}X_t$ and
   $W_n=\sum_{t<n}\mathbb E[X_t^2|\mathcal F_t]$.
   - For $X_t\le b$ with $b>0$ and $\lambda\ge0$, prove the one-step bound
     $\mathbb E[\exp(\lambda X_t-\psi_b(\lambda)\mathbb E[X_t^2|\mathcal F_t])|\mathcal F_t]\le1$,
     with $\psi_b(\lambda)=(e^{\lambda b}-1-\lambda b)/b^2$, from
     $e^{\lambda x}\le1+\lambda x+\psi_b(\lambda)x^2$ for $x\le b$. The increments
     $\lambda X_t-\psi_b(\lambda)\mathbb E[X_t^2|\mathcal F_t]$ thereby satisfy the conditional MGF
     domination of the Identification roadmap's Layer 4.2 at parameter $1$ with $\psi=0$: $S$ is a
     sub-ψ process with variance process $W$ [HRMS20]. The supermartingale
     $\exp(\lambda S_n-\psi_b(\lambda)W_n)$ and the time-uniform bounds below come from that layer;
     do not build a separate supermartingale argument.
   - Deduce, through Ville, for $a\ge0$:
     $P(\exists n,\ S_n\ge a\wedge W_n\le\sigma^2)\le\exp(-a^2/(2(\sigma^2+ab/3)))$.
   - Fixed-η form: for $\eta>0$ with $\eta X_t\le1$ and $\delta\in(0,1]$,
     $P(\exists n,\ S_n\ge\eta W_n+\log(1/\delta)/\eta)\le\delta$. The proof is the domination of
     $\eta X_t-\eta^2\mathbb E[X_t^2|\mathcal F_t]$, from $e^x\le1+x+x^2$ for $x\le1$, and Ville.
   - Peeled form: for $|X_t|\le b$, $N\ge1$, $K=\lceil\log_4N\rceil+1$, $\delta\in(0,1)$ and
     $\ell=\max(1,\log(K/\delta))$, with probability at least $1-\delta$, for all $n\le N$:
     $S_n\le3\sqrt{W_n\ell}+2b\ell$. Prove it by applying the fixed-η form to
     $\eta_j=2^{-j}/b$, $j<K$, each with $\delta/K$.
   - Independent corollaries, built here in the statement shape of Tau Ceti's RandomMatrices
     Layer 2.1: Bennett's inequality and Bernstein's inequality $2\exp(-t^2/(2(v+bt/3)))$, with
     their inverted high-probability forms.
2. **Empirical Bernstein** [AMS09, Theorem 1].
   - For $n\ge1$ i.i.d. $X_i\in[0,b]$ with $b>0$, mean μ and biased sample variance $V_n$, and
     $x>0$, prove that with probability at least $1-3e^{-x}$,
     $|\bar X_n-\mu|\le\sqrt{2V_nx/n}+3bx/n$.
   - Derive it from item 1 applied to $X$ and $(X-\mu)^2$.
   - The variance-aware analyses of Layers 18 and 20 use this form in place of Maurer and Pontil's.
3. **$\ell^1$ deviation of empirical laws** [WOSVW03, Theorem 2.1], [LS, Exercise 5.17]. Let ν be a
   probability measure, take a measurable partition into $m$ cells, $n\ge1$ i.i.d. draws with
   empirical measure $\hat\nu_n$, and $\varepsilon>0$.
   - Prove $P\big(\sum_A|\hat\nu_n(A)-\nu(A)|\ge\varepsilon\big)\le(2^m-2)e^{-n\varepsilon^2/2}$.
   - Prove that with probability at least $1-\delta$,
     $\sum_A|\hat\nu_n(A)-\nu(A)|<\sqrt{2(\log(1/\delta)+m\log2)/n}$.
   
   The second form follows from the first; [LS, (5.12)] prints $m\log2$ without the factor 2.
4. **Types and categorical KL bounds** [CT06, Theorems 11.1.1, 11.1.3, 11.1.4], [JKMDLV20,
   Proposition 1]. On a set of size $m\ge2$:
   - there are at most $(n+1)^m$ types, and $P(\mathrm{KL}(\hat p_n,p)>\varepsilon)\le(n+1)^me^{-n\varepsilon}$;
   - the likelihood ratio of every predictable sequential predictor against $p$ is a nonnegative
     mean-one martingale. Laplace's predictor $q_t(i)=(N_i(t)+1)/(t+m)$ gives, by Ville,
     $P\big(\exists n\ge1,\ n\,\mathrm{KL}(\hat p_n,p)>\log(1/\delta)+(m-1)\log(e(1+n/(m-1)))\big)\le\delta$.
5. **Covering numbers and uniform deviations.**
   - In a real normed space of dimension $d$, for $r\ge0$ and $\varepsilon>0$, prove that the closed
     ball of radius $r$ has ε-covering number at most $(1+2r/\varepsilon)^d$, with Mathlib's
     `coveringNumber`.
   - Prove that the image of an ε/L-cover under an $L$-Lipschitz map is an ε-cover.
   - Uniform Hoeffding: let $\mathcal V$ be a class of functions with values in $[0,B]$ with an
     ε-cover of cardinality $N_\varepsilon$ in the sup norm. For $n$ i.i.d. samples, prove that with
     probability at least $1-\delta$, simultaneously for all $V\in\mathcal V$:
     $|\frac1n\sum_iV(Y_i)-\mathbb EV|\le B\sqrt{\log(2N_\varepsilon/\delta)/(2n)}+2\varepsilon$.
6. **Least squares over a finite class** [AJKS, Lemma A.11].
   - Setting: a finite class $\mathcal F$ of functions with values in $[0,B]$; $n$ i.i.d. pairs
     $(x_i,y_i)$ with $x_i\sim\nu$ and $y_i\in[0,B]$; the regression function $f^*$; and
     $\varepsilon_{\mathrm{approx}}=\min_{f\in\mathcal F}\|f-f^*\|_{2,\nu}^2$.
   - Prove that with probability at least $1-\delta$ the empirical risk minimizer satisfies
     $\|\hat f-f^*\|^2_{2,\nu}\le20B^2\log(2|\mathcal F|/\delta)/n+3\,\varepsilon_{\mathrm{approx}}$.
   - The version of 31 January 2022 states $22Y^2\log(|\mathcal F|/\delta)/n+20\varepsilon_{\mathrm{approx}}$,
     but its proof bounds a second moment with the wrong range. The constants here are those of
     the current draft of the book.

Completion checks: Freedman's bound with $W_n\le nb^2$ recovers the Azuma–Hoeffding exponent up to
the constant; the KL bound for $m=2$ is a time-uniform Bernoulli bound.

## Layer 4: Stochastic approximation

Suggested home: `Probability/StochasticApproximation/` (`Probability/Martingale/` for item 1).

1. **Robbins–Siegmund** [RS71, Theorem 1].
   - Let $V,a,b,c$ be adapted processes with values in `ℝ≥0`, and let
     $\mathbb E[V_{n+1}|\mathcal F_n]+c_n\le(1+a_n)V_n+b_n$, with Mathlib's `condLExp` of the
     coercions to `ℝ≥0∞`.
   - Prove that on $\{\sum a<\infty,\sum b<\infty\}$, $V_n$ converges almost surely to a finite
     limit and $\sum c_n<\infty$.
2. **Robbins–Monro** [RM51], [KY03, Chapter 5]. In a finite-dimensional real inner product space,
   let $x_{n+1}=x_n-\alpha_n(h(x_n)+\xi_{n+1})$, with:
   - deterministic $\alpha_n\ge0$, $\sum\alpha=\infty$ and $\sum\alpha^2<\infty$;
   - $\mathbb E\|x_0-x^*\|^2<\infty$;
   - martingale-difference noise with $\mathbb E[\|\xi_{n+1}\|^2|\mathcal F_n]\le A+B\|x_n-x^*\|^2$;
   - $\|h(x)\|\le C(1+\|x-x^*\|)$ and $\langle x-x^*,h(x)\rangle>0$ for $x\ne x^*$, uniformly on
     annuli: $\inf\{\langle x-x^*,h(x)\rangle:\varepsilon\le\|x-x^*\|\le1/\varepsilon\}>0$ for every
     $\varepsilon\in(0,1)$.
   
   Prove $x_n\to x^*$ almost surely, from item 1.
3. **Asynchronous stochastic approximation** [Tsi94, Theorems 1, 3]. On a finite index `ι`, let
   $x_i(t+1)=x_i(t)+\alpha_i(t)(F_i(x(t))-x_i(t)+w_i(t))$, with:
   - $\alpha_i(t)\in[0,1]$ adapted, $\sum_t\alpha_i(t)=\infty$ almost surely, and
     $\sum_t\alpha_i(t)^2\le C$ for a deterministic $C$;
   - $w_i(t)$ $\mathcal F(t+1)$-measurable with $\mathbb E[w_i(t)|\mathcal F(t)]=0$ and
     $\mathbb E[w_i(t)^2|\mathcal F(t)]\le A+B\max_j\max_{\tau\le t}|x_j(\tau)|^2$;
   - $F$ a pseudo-contraction for a weighted sup norm, with fixed point $x^*$:
     $\|F(x)-x^*\|_w\le\beta\|x-x^*\|_w$ with $\beta<1$.
   
   Prove that $x(t)$ is almost surely bounded and converges almost surely to $x^*$.

Completion checks: Robbins–Monro for the sample mean is the strong law; item 3 with $F$ constant is
a family of independent averaging recursions.

## Layer 5: Optimization

Suggested homes: `Optimization/`, `Analysis/SpecialFunctions/`, `OnlineLearning/`.

1. **Softmax.** On a finite type define:
   - `softmax θ` $=\exp\theta/\sum\exp\theta$, with values in LMLExplore's `simplex`;
   - `logSumExp`.
   
   Prove the Jacobian $\mathrm{diag}(\pi)-\pi\pi^\top$, the convexity of `logSumExp` and its
   gradient `softmax`. The Gibbs variational formula on a finite type is the finite case of the
   OnlineLearning roadmap's Layer 10.1.
2. **Smooth optimization** [Nes18, Lemma 1.2.3], [KNS16, Theorem 1], [AKLM21, Proposition B.1,
   Theorem E.1], [MXSS20, Lemmas 7–8]. The descent lemma for $L$-smooth functions is the
   OnlineLearning roadmap's Layer 1.3, in a normed space. In a real inner product space, prove:
   - for $L$-smooth $f$ satisfying the Polyak–Łojasiewicz inequality
     $\frac12\|\nabla f\|^2\ge\mu(f^*-f)$, gradient ascent with step $1/L$ gives
     $f^*-f(x_k)\le(1-\mu/L)^k(f^*-f(x_0))$;
   - for $a\ge0$ and $\delta_k\ge0$, the recursion $\delta_{k+1}\le\delta_k-a\delta_k^2$ gives
     $\delta_k\le\delta_0/(1+a\delta_0k)$;
   - projected gradient ascent on a closed convex set $C$, with $G_\eta(x)=(P_C(x+\eta\nabla f(x))-x)/\eta$:
     for $\eta=1/L$, $\min_{t<T}\|G_\eta(x_t)\|\le\sqrt{2L(f^*-f(x_0))/T}$;
   - the transfer: if $\|G_\eta(x)\|\le\varepsilon$, then
     $\max_{x^++\delta\in C,\|\delta\|\le1}\langle\delta,\nabla f(x^+)\rangle\le\varepsilon(1+\eta L)$.
3. **Bregman proximal steps on products of simplices** [Xiao22, Lemma 6], [Lan23, Lemma 4],
   [Ora23, Lemmas 6.7, 6.10].
   - Three-point descent with relative strong convexity. Hypotheses:
     - $C$ closed convex and $F$ a Legendre mirror map (Bandits roadmap, Layer 6);
     - $\varphi$ proper closed convex on $C$, with $\varphi-\mu F$ convex for some $\mu\ge0$;
     - $x\in\mathrm{int}\,\mathrm{dom}\,F$ and $\mathrm{int}\,\mathrm{dom}\,F\cap C\ne\emptyset$.
     
     Prove that $x^+=\arg\min_{u\in C}\varphi(u)+D_F(u,x)$ lies in $\mathrm{int}\,\mathrm{dom}\,F$
     and satisfies $\varphi(x^+)+D_F(x^+,x)\le\varphi(u)+D_F(u,x)-(1+\mu)D_F(u,x^+)$ for all $u\in C$.
   - Mirror descent on a product $\prod_sC_s$ with potential $\sum_sw_sF_s$ and losses $g_t(s)$:
     derive from the Bandits roadmap's Layer 6 the weighted bound
     $\sum_sw_s\sum_t\langle g_t(s),x_t(s)-u(s)\rangle\le\sum_sw_sD_{F_s}(u_s,x_0(s))/\eta+\frac\eta2\sum_{t,s}w_s\|g_t(s)\|_*^2$.
   - The entropic step on the simplex: $x^+\propto x\,e^{-\eta g}$. Its composite version with
     $\varphi=\tau\cdot$(negative entropy) is $x^+\propto x^{1/(1+\eta\tau)}e^{-\eta g/(1+\eta\tau)}$.

Completion checks: softmax of a constant vector is uniform; on one component, item 3 recovers the
Bandits roadmap's mirror descent bound.

## Layer 6: Sequential-learning tools

Suggested home: `SequentialLearning/`.

1. **Key-determined environments and keyed streams** [Kal21, Theorem 27.7], [LS, Exercise 38.21].
   - Let $\mathcal K$ be countable. Call an LML environment *key-determined* by measurable key maps
     $k_n$ from (history, observation, action) to $\mathcal K$ and kernels
     `ηY : Kernel 𝒦 𝓨` and `ηO : Kernel 𝒦 𝓞` when:
     - its feedback kernel at round $n$ is `ηY` composed with $k_n$;
     - its observation kernel at round $n+1$ is `ηO` composed with the key of round $n$, read from
       the last round of the history;
     - the feedback of round $n$ and the observation of round $n+1$ are conditionally independent
       given the past and the action.
     
     Bandits use the key $a$ (trivial `ηO`); `M.env μ` uses the key $(s,a)$ with
     `ηY = M.R` and `ηO = M.P`.
   - Assume the observation and feedback spaces are standard Borel, as LML's
     `Bandits.arrayMeasure` does. Prove that the law of every run equals the law obtained from:
     - an independent uniform randomization stream for the algorithm;
     - an independent array $Z_{k,j}\sim$ `ηY k ⊗ ηO k`, read at the $j$-th occurrence of key $k$.
     
     This generalizes LML's `Bandits.arrayMeasure` and `probSpace`.
   - Deduce the keyed transfer: for every event $E_j$ about the first $j$ draws of key $k$, the
     probability that $E_j$ holds for the draws seen at some $j\le$ the count of $k$ before round
     $n$ is at most the probability that $E_j$ holds for some $j\le n$ under the i.i.d. stream.
     Give the joint form over all keys.
   - For the action key, this is the transfer of events about the first $s$ rewards of each arm
     from runs to reward streams, which the Identification roadmap's Layer 4.1 owns. State the
     keyed transfer in its statement shape, so that the two agree for the action key.
2. **Divergence decomposition regrouped by keys** [GMS19, §2], [DMKV21, Lemma 5].
   - The chain rule for the KL divergence of stopped histories,
     $\mathrm{KL}\le\mathbb E\big[\sum_{t<\tau}\mathrm{KL}(\text{step}_t\,\|\,\text{step}'_t)\big]$ for
     a stopping time τ almost surely finite under the first environment, with equality when τ is
     also almost surely finite under the second, is the Identification roadmap's Layer 2.1, for
     arbitrary pairs of environments. At a fixed horizon it is LML's
     `IsAlgEnvSeq.klDiv_map_history_stepKernel`.
   - For two key-determined environments with the same key maps and the same initial observation
     law, prove that the step divergence of round $t$ is
     $\mathrm{KL}(\eta^Y_k,\eta'^Y_k)+\mathrm{KL}(\eta^O_k,\eta'^O_k)$ at the key $k$ of round $t$,
     by the conditional independence of item 1.
   - Regroup by keys, with the keyed form of Wald's identity
     $\mathbb E\big[\sum_{t<\tau}f(k_t)\big]=\sum_kf(k)\,\mathbb E[N_k(\tau)]$ for $f\ge0$ (the
     Identification roadmap's Layer 0.3): KL(histories of length $n$) equals
     $\sum_k\mathbb E[N_k(n)]\big(\mathrm{KL}(\eta^Y_k,\eta'^Y_k)+\mathrm{KL}(\eta^O_k,\eta'^O_k)\big)$,
     and at a stopping time τ, almost surely finite under the first environment, the same holds
     with $\le$ and $N_k(\tau)$, with equality when τ is also almost surely finite under the
     second.
   - Prove the transportation form: for every event $E$ of the stopped history,
     $\mathrm{kl}(P(E),P'(E))\le\sum_k\mathbb E[N_k(\tau)]\big(\mathrm{KL}(\eta^Y_k,\eta'^Y_k)+\mathrm{KL}(\eta^O_k,\eta'^O_k)\big)$,
     by the data processing for `klBer` of the Identification roadmap's Layer 2.2.
   - For the action key, these are the bandit decompositions of the Identification roadmap's
     Layer 2.1. State the keyed forms in their statement shape. Layer 14.6 gives the instance of
     MDP runs.

Completion checks: for the action key, item 1 is LML's per-arm stream model and item 2 is LML's
`IsAlgEnvSeq.klDiv_map_history`.
## Layer 7: Markov decision processes, policies and values

1. **Models and environments.**
   - Define `MDP 𝓢 𝓐 𝓡`, with a transition kernel `P : Kernel (𝓢 × 𝓐) 𝓢` and a reward kernel
     `R : Kernel (𝓢 × 𝓐) 𝓡`, both Markov.
   - For `[Nonempty 𝓢]`, define `MDP.env M μ₀ : Environment 𝓢 𝓐 𝓡`:
     - the observation of round 0 has law μ₀ (a Dirac mass when μ₀ is not a probability measure);
     - the observation of round $n+1$ has law `M.P` at the last state and action;
     - the feedback of round $n$ has law `M.R` at the current state and action.
   - Define `MDP.policyAlg`, `MDP.policyMeasure`, `MDP.stateLaw` and `MDP.meanReward`.
   - All of these copy LML's `mdp` branch in its names and namespaces. Here $P$ is `M.P` and $r$ is
     the mean reward `MDP.meanReward M.R`.
   - Define `EpisodicMDP 𝓢 𝓐`, with ℕ-indexed transition and reward kernels `trans h`, `reward h`,
     and its derived `meanReward`, `RewardsIn` and `HasRewardFn`. Define the time-augmented
     stationary MDP `M.augmented : MDP (𝓢 × ℕ) 𝓐 ℝ`. These copy entropy-mdp (Existing
     formalizations) in its names and namespace `Learning.MDP.Episodic`.
   - Prove the run lemmas for every run `IsAlgEnvSeq O A Y alg (M.env μ) P` with μ a probability
     measure:
     - `O 0` has law μ;
     - `O (n + 1)` has conditional law `M.P (O n, A n)` given the history up to round $n$;
     - `Y n` has conditional law `M.R (O n, A n)` given the history, `O n` and `A n`;
     - `Y n` and `O (n + 1)` are conditionally independent given the history, `O n` and `A n`.
2. **Markov policies.**
   - Define `Algorithm.markov π` for `π : ℕ → Kernel 𝓞 𝓐` with values in Markov kernels, for
     arbitrary observation and feedback types: its policy at round $n$ is `π n` applied to the
     current observation.
   - Prove that `MDP.policyAlg π hπ` is `Algorithm.markov` of the constant deterministic kernel.
   - Under a stationary policy π in `M.env μ`, prove that the state process is a Markov chain with
     kernel `M.stateKernel π := M.P ∘ₖ (Kernel.id ×ₖ π)`: its law is Tau Ceti's
     `markovChainLaw μ (M.stateKernel π)`.
   - Prove that the state–action process is a Markov chain with kernel
     `M.saKernel π := (Kernel.id ×ₖ π) ∘ₖ M.P` on `𝓢 × 𝓐` and initial law `μ ⊗ₘ π`.
   
   Below, $P_\pi$ is `M.stateKernel π`, acting on functions of the state, and $P^{\pi}_{SA}$ is
   `M.saKernel π`, acting on functions of the state–action pair.
3. **State–action marginals.**
   - For every run of every algorithm, prove $\mathrm{law}(S_{n+1})=P\circ_m\mathrm{law}(S_n,A_n)$.
   - Define the state marginals once, for a sequence of transition kernels
     `P : ℕ → Kernel (𝓢 × 𝓐) 𝓢`, a Markov policy π and an initial law μ: `MDP.stateMarginal P π μ`,
     with $\mu_0=\mu$ and $\mu_{n+1}=P_n\circ_m(\mu_n\otimes_m\pi_n)$. The marginals of `M` are the
     case `fun _ ↦ M.P`, those of an episodic MDP the case `M.trans` (Layer 11.4). LMLExplore
     defines them twice, as `MDP.stateMarginal M π μ` and `EpisodicMDP.stateMarginal M π μ`; both
     become this definition.
   - For a Markov policy, prove $\mathrm{law}(S_n,A_n)=\mu_n\otimes_m\pi_n$ for the marginals of
     `fun _ ↦ M.P`.
   - Every discounted, finite-horizon and Cesàro quantity of Layers 8–13 is a function of these
     marginals. Prove the marginal formula of each one where it is defined.
4. **Values.** Rewards are bounded: $|x|\le C$ for `M.R p`-almost every $x$ and every $p$. For a
   stationary policy π define:
   - `M.policyReward π s` $=\int r(s,a)\,\pi(da|s)$;
   - the value `M.value γ π`, $v^\pi=\sum_n\gamma^nP_\pi^nr_\pi$, with `M.stateKernel π ^ n`;
   - the action value `M.qValue γ π` $=r+\gamma Pv^\pi$;
   - the advantage $A^\pi(s,a)=Q^\pi(s,a)-v^\pi(s)$.
   
   For an algorithm define:
   - the discounted run value `M.runValue γ alg μ`, the expectation under `trajMeasure` of
     $\sum_n\gamma^nr(S_n,A_n)$;
   - for every `γ : ℝ≥0`, the $N$-step return with discount γ and terminal value $u$,
     `M.runReturn γ N u alg μ`, the expectation of $\sum_{n<N}\gamma^nr(S_n,A_n)+\gamma^Nu(S_N)$.
     LMLExplore's `MDP.runReturn N u` is the case $\gamma=1$; it takes the discount as an argument.
   
   Prove:
   - both are also the expectations with the realized rewards `Y n` in place of $r(S_n,A_n)$;
   - the bound $|v^\pi|\le C/(1-\gamma)$;
   - measurability of $v^\pi$ and $Q^\pi$;
   - the evaluation equations $v^\pi=r_\pi+\gamma P_\pi v^\pi$, $Q^\pi=r+\gamma Pv^\pi$ and
     $v^\pi(s)=\int Q^\pi(s,a)\,\pi(da|s)$;
   - `M.runValue γ (Algorithm.markov fun _ ↦ π) μ = ∫ s, M.value γ π s ∂μ`;
   - the value of every algorithm is $\sum_n\gamma^n\int r\,d\,\mathrm{law}(S_n,A_n)$.
   
   Define:
   - the optimal value `M.optValue γ s := ⨆ alg, M.runValue γ alg (Measure.dirac s)`;
   - the optimal action value `M.optQValue γ` $=r+\gamma P\,v^*$.
5. **Reduction to Markov policies** [P, Theorem 5.5.1, Corollary 5.5.2, Theorem 5.5.3].
   - Let `𝓐` be a standard Borel space. For every algorithm and initial law μ, prove that the Markov
     policy $\pi'_n:=$ `condDistrib` of $A_n$ given $S_n$ under the run has the same laws of
     $(S_n,A_n)$ for every $n$. The policy depends on μ.
   - Deduce equality of the discounted values, of the $N$-step returns and of the Cesàro averages of
     the expected rewards.
   - Deduce that, for every initial law, the supremum of each criterion over algorithms equals its
     supremum over Markov policies.
   - Give the example of [P, Problem 5.11]: a deterministic history-dependent policy whose
     marginals no deterministic Markov policy reproduces.
6. **Episodic values.**
   - For a Markov policy `π : ℕ → Kernel 𝓢 𝓐` of an episodic MDP with horizon $H$, define
     $V^\pi_h,Q^\pi_h$ for $h\le H$ by $V^\pi_H=0$, $Q^\pi_h=r_h+P_hV^\pi_{h+1}$ and
     $V^\pi_h(s)=\int Q^\pi_h(s,a)\,\pi_h(da|s)$.
   - Prove that $V^\pi_h(s)$ is the expected return of the $H-h$ remaining steps of the trajectory
     of π from $(s,h)$ in `M.augmented`: the return `M.augmented.runReturn 1 (H - h) 0` of the
     stationary policy of `M.augmented` playing $\pi_{h'}$ at $(s',h')$, from $\delta_{(s,h)}$.
   - Prove $0\le V^\pi_h\le H-h$ for rewards in $[0,1]$.
   - Deterministic policies are the $H$-step policies `Policy 𝓢 𝓐 H = Fin H → 𝓢 → 𝓐` of
     entropy-mdp, with measurability as a separate hypothesis, extended beyond the horizon by
     `Policy.extend`.
7. **Episodes as rounds.**
   - For finite `𝓢` and countable `𝓐`, define the episode-level environment `statesEnv M H μ`. It
     is LML's `stationaryEnv` of the kernel from $H$-step policies to the law of the state sequence of
     an episode started from μ. It generalizes entropy-mdp's `statesEnv M H s₁`, which is the case
     $\mu=\delta_{s_1}$.
   - A learner in it chooses an $H$-step policy at the start of every episode from the previous
     episodes, and observes the state sequence. Rewards are known when they are deterministic.
   - Define likewise `episodeEnv M H μ`, the `stationaryEnv` of the kernel from $H$-step policies
     to the joint law of the state sequence and the reward sequence of an episode. A learner in it
     also observes the rewards, and so learns unknown stochastic rewards. Prove that forgetting
     the rewards maps its episode laws to those of `statesEnv M H μ`.
   - For finite `𝓐`, prove that a stochastic Markov policy has the episode law (in either
     environment) of the random $H$-step policy drawn from the product over $(h,s)$ of its action
     laws. Algorithms in `statesEnv` and `episodeEnv` thereby play stochastic Markov policies.

Completion checks: a one-state MDP is a bandit, and `M.env μ` then has the law of LML's
`stationaryEnv M.R` up to the constant observation; the value of a deterministic policy in a
deterministic MDP is a geometric sum along its orbit.

## Layer 8: Bellman operators and the finite horizon

Throughout, `M : MDP 𝓢 𝓐 ℝ` has bounded rewards, `γ : ℝ≥0` is arbitrary ($\gamma=1$ gives the
undiscounted return), $N$ is a horizon and `u` a bounded measurable terminal value. Write $T$ for
`M.bellman γ`. The finite-horizon theory is built once, for MDPs; episodic MDPs are its instance
`M.augmented` (item 4).

1. **Bellman operators.**
   - Define the one-step lookahead `M.lookahead γ v` $(s,a)=r(s,a)+\gamma\int v\,dP(s,a)$, the
     evaluation operator `M.bellmanEval γ π` $v(s)=\int$ `M.lookahead γ v (s, a)` $\pi(da|s)$, that
     is $r_\pi+\gamma P_\pi v$, of a stationary policy π, the optimality operator `M.bellman γ`
     $v(s)=\sup_a$ `M.lookahead γ v (s, a)`, and, for finite `𝓐`, the greedy policy
     `M.greedy γ v` (LML `argmax`).
   - Define the predicate `M.IsApproxGreedy γ ε v d`: the deterministic policy $d$ satisfies
     `M.lookahead γ v (s, d s)` $\ge$ `M.bellman γ v s` $-\varepsilon$ for every $s$. LMLExplore's
     `MDP.IsGreedy` is the case $\varepsilon=0$. For countable `𝓐`, bounded measurable $v$ and
     $\varepsilon>0$, construct a measurable ε-greedy policy from Layer 0.6.
   - Prove that both operators are monotone and satisfy $T(v+c)=Tv+\gamma c$ for constants $c$.
   - Prove that the evaluation operators, for every `𝓐`, and the optimality operator, for countable
     `𝓐`, preserve bounded measurable functions, and that `M.greedy γ v` is measurable for
     measurable $v$.
   - Prove that randomizing does not increase the supremum: `M.bellmanEval γ π v ≤ M.bellman γ v`
     for bounded measurable $v$ and every `𝓐` [P, Proposition 6.2.1]. LMLExplore's
     `MDP.bellmanEval_le_bellman` assumes finitely many actions.
2. **Optimality of backward induction** [P, §4.2, Theorems 4.3.2–4.3.4, 4.4.2], [Ber12, Chapter
   1]. Let `𝓐` be countable. Prove:
   - for every algorithm and every probability measure μ,
     `M.runReturn γ N u alg μ` $\le\int T^Nu\,d\mu$, by telescoping
     $\mathbb E\,(T^{N-n}u)(S_n)\ge\mathbb E\,r(S_n,A_n)+\gamma\,\mathbb E\,(T^{N-n-1}u)(S_{n+1})$
     along the marginals of Layer 7.3; no reduction to Markov policies is needed;
   - for $\varepsilon_n>0$, the Markov deterministic policy playing at round $n<N$ a measurable
     $\varepsilon_n$-greedy policy for $T^{N-n-1}u$ has return at least
     $\int T^Nu\,d\mu-\sum_{n<N}\gamma^n\varepsilon_n$ from every initial law μ [P, Theorem 4.3.4];
   - hence $(T^Nu)(s)$ is the supremum of `M.runReturn γ N u alg (Measure.dirac s)` over all
     algorithms [P, Theorem 4.3.2], [Ber12, Chapter 1];
   - for finite `𝓐`, the Markov deterministic policy greedy for $T^{N-n-1}u$ at round $n$ attains
     $\int T^Nu\,d\mu$ from every initial law [P, Theorems 4.3.3, 4.4.2];
   - policy evaluation [P, §4.2]: for a Markov policy π and every `𝓐`,
     `M.runReturn γ N u (Algorithm.markov π) μ` $=\int T_{\pi_0}T_{\pi_1}\cdots T_{\pi_{N-1}}u\,d\mu$,
     with $T_{\pi_n}$ = `M.bellmanEval γ (π n)`.
3. **Compact action sets** [P, Proposition 4.4.3 (c)]. For countable `𝓢` with measurable singletons,
   compact metrizable `𝓐` with its Borel σ-algebra, $r(s,\cdot)$ upper semicontinuous and
   $a\mapsto P(s,a)\{s'\}$ lower semicontinuous for every $s,s'$, prove that the suprema defining
   $T^{N-n}u$ are attained and that an optimal Markov deterministic policy exists.
4. **Episodic MDPs.** Let `M : EpisodicMDP 𝓢 𝓐` have bounded rewards and horizon $H$.
   - Define $V^*_h,Q^*_h$ by the optimality equations, with $V^*_H=0$, and, for finite `𝓐`, the
     greedy optimal policy $\pi^*$.
   - Prove that $V^*_h(s)$ is `(M.augmented.bellman 1)^[H - h] 0 (s, h)`, by induction from
     LMLExplore's `EpisodicMDP.optValue_eq_bellman_augmented`.
   - Deduce from item 2, for countable `𝓐`: $V^*_h(s)$ is the supremum over all algorithms of
     `M.augmented.runReturn 1 (H - h) 0 alg (Measure.dirac (s, h))`, the expected reward of the
     $H-h$ remaining steps. In particular $V^\pi_h\le V^*_h$ for every Markov policy π: derive
     LMLExplore's `EpisodicMDP.value_le_optValue`, proved there by a separate induction, from it.
     For finite `𝓐`, $\pi^*$ attains $V^*_h$.

Completion checks: for $N=1$ the optimal policy is the myopic greedy one; for $\gamma=1$ and a
one-state MDP, $T^Nu=N\max_ar(a)+u$.

## Layer 9: Discounted optimality

Throughout, $0\le\gamma<1$ and `𝓐` is countable, unless an item says otherwise. This layer is the
instance of Layer 0.3 on `boundedMeasurable 𝓢`, with $T_d$ the evaluation operators of the
measurable deterministic stationary policies $d$: they satisfy $T_dv\le Tv$, and the ε-greedy
policies of Layer 8.1 are ε-greedy decisions. For finite `𝓐`, greedy policies attain the supremum.

1. **Operators on bounded measurable functions** [P, Proposition 6.2.4], [Tsi94].
   - Define the evaluation operator of a stationary policy π on `boundedMeasurable 𝓢` as the affine
     map $v\mapsto r_\pi+\gamma P_\pi v$, with $P_\pi$ acting by `(M.stateKernel π).integralCLM`
     (Layer 1.4). LMLExplore's `MDP.bellmanEvalOp` is built pointwise through
     `boundedMeasurable.mk`; define it as this affine map.
   - The optimality operator acts on `boundedMeasurable 𝓢` as LMLExplore's `MDP.bellmanOp`.
   - Define the action-value operators on `boundedMeasurable (𝓢 × 𝓐)`: the evaluation operator
     `M.qBellmanEval γ π` $Q=r+\gamma P^\pi_{SA}Q$, with `(M.saKernel π).integralCLM`, and the
     optimality operator `M.qBellman γ` $Q(s,a)=r(s,a)+\gamma\int\sup_{a'}Q(s',a')\,P(ds'|s,a)$.
     Prove `M.qBellman γ (M.lookahead γ v) = M.lookahead γ (M.bellman γ v)` and
     `M.bellman γ v s` $=\sup_a$ `M.lookahead γ v (s, a)`.
   - Prove that the four operators satisfy Blackwell's conditions with $e=1$ (Layer 0.2), hence are
     γ-contractions for the sup norm. The pointwise bounds of LMLExplore's
     `MarkovDecisionProcess/Bellman.lean` (`abs_bellman_sub_le`, `abs_bellmanEval_sub_le`) are
     corollaries.
2. **Evaluation** [P, Theorem 6.1.1]. For arbitrary `𝓐` and every stationary policy, prove:
   - $v^\pi$ is the unique bounded measurable fixed point of the evaluation operator, and
     $v^\pi=R_\gamma(P_\pi)r_\pi=(1-\gamma P_\pi)^{-1}r_\pi$ in `boundedMeasurable 𝓢` (Layer 1.4);
   - $Q^\pi=(1-\gamma P^\pi_{SA})^{-1}r$ is the unique fixed point of `M.qBellmanEval γ π`.
3. **Sub- and supersolutions** [P, Theorem 6.2.2]. For bounded measurable $v$:
   - (a) for arbitrary `𝓐`: if $r(s,a)+\gamma\int v\,dP(s,a)\le v(s)$ for all $s,a$, then
     `M.runValue γ alg μ` $\le\int v\,d\mu$ for every algorithm, hence $v\ge v^*$. Telescope
     $\mathbb E\,v(S_n)\ge\mathbb E\,r(S_n,A_n)+\gamma\,\mathbb E\,v(S_{n+1})$ along the marginals of
     Layer 7.3; no reduction to Markov policies is needed;
   - (b) if $v\le Tv$, then $v\le v^*$: an ε-greedy policy $d$ for $v$ has
     $v^d\ge v-\varepsilon/(1-\gamma)$.
4. **The optimality equation** [P, Theorems 6.2.5, 6.2.6, 6.2.11]. Prove:
   - $v^*$ is the unique bounded measurable fixed point of $T$, through items 2 and 3 (a) and
     Layer 0.3;
   - $v^*=\sup_dv^d$ over measurable deterministic stationary policies; for $\varepsilon>0$, every
     measurable policy $d$ ε-greedy for $v^*$ has $v^d\ge v^*-\varepsilon/(1-\gamma)$, so measurable
     deterministic stationary ε-optimal policies exist from every initial law;
   - a stationary policy is optimal if and only if its value solves the optimality equation;
   - $Q^*$ is the unique fixed point of `M.qBellman γ` in `boundedMeasurable (𝓢 × 𝓐)`, and
     $v^*(s)=\sup_aQ^*(s,a)$.
   
   LMLExplore's `bellman_optValue`, `eq_optValue_of_bellman_eq`, `le_optValue_of_le_bellman` and
   `eq_optQValue_of_lookahead_iSup_eq` assume finitely many actions; state them for countably
   many.
5. **Finite action sets** [P, Theorems 6.2.7, 6.2.9, 6.2.10 (a)]. For finite `𝓐`, prove:
   - the deterministic stationary policy greedy with respect to $v^*$ is optimal from every initial
     law;
   - $v^*=\max_dv^d$ over measurable deterministic stationary policies.
6. **Compact action sets.**
   - (a) [P, Theorem 6.2.10 (c)]. Prove the existence of an optimal deterministic stationary policy
     for countable `𝓢` with measurable singletons and compact metrizable `𝓐`, with $r(s,\cdot)$
     upper semicontinuous and $P(s,\cdot)\{s'\}$ lower semicontinuous.
   - (b) Prove the same for a topological `𝓢` with open sets measurable and a compact Polish `𝓐`,
     when $r$ is continuous and $P$ is weakly continuous (Feller):
     $(s,a)\mapsto\int f\,dP(s,a)$ is continuous for bounded continuous $f$.
     - $T$ maps bounded continuous functions to bounded continuous functions; for the supremum over
       a compact set use Mathlib's `IsCompact.continuous_sSup`.
     - The fixed point is continuous.
     - A measurable greedy selector exists by Tau Ceti's `Continuous.exists_measurable_isMinOn`.

Completion checks: for $\gamma=0$ the optimal policy is myopic; the example of [P, Example 6.2.2]
(one state, actions $\mathbb N_{\ge1}$, $r(a)=1-1/a$) has no optimal policy but ε-optimal ones
(item 4); in a two-state MDP
whose optimal policy depends on γ, compute $v^*$ in closed form on both sides of the threshold.

## Layer 10: Discounted algorithms

Throughout, $0\le\gamma<1$, `𝓐` is finite, $T$ is `M.bellman γ`, and $\|\cdot\|$ is the sup norm of
`boundedMeasurable 𝓢` (Layer 0.1). State the first and last bullets of item 1, and item 5, for
countable `𝓐`. Each rate is proved for the operators of Layer 9.1 on `boundedMeasurable 𝓢`, from
Mathlib's `ContractingWith` (item 1) or from Layer 0.3 (items 2–3), and its pointwise form, with
the constants shown, is a corollary. LMLExplore's `PolicyIteration.lean` and
`ModifiedPolicyIteration.lean` prove the rates pointwise; derive them from the abstract
`IsPolicyIteration.norm_sub_le` and `IsModifiedPolicyIteration.norm_sub_le`.

1. **Value iteration** [P, Theorem 6.3.1, Proposition 6.3.2, Theorem 6.3.3]. Let $v_n=T^nv_0$ and
   $B=\|v_1-v_0\|$. Prove:
   - $\|v_n-v^*\|\le\gamma^nB/(1-\gamma)$ (`ContractingWith.apriori_dist_iterate_fixedPoint_le`);
   - if $2\gamma\|v_{n+1}-v_n\|<\varepsilon(1-\gamma)$, the policy greedy for $v_{n+1}$ is
     $\varepsilon$-optimal and $\|v_{n+1}-v^*\|<\varepsilon/2$;
   - the policy greedy for $v_n$ satisfies $\|v^{d_n}-v^*\|\le2\gamma^nB/(1-\gamma)$;
   - the iterates are monotone from the first $n$ with $Tv_n\le v_n$ (resp. $\ge$).
2. **Policy iteration** [P, Proposition 6.4.1, Theorem 6.4.2, Propositions 6.4.3–6.4.4, Lemma 6.4.5,
   Theorem 6.4.6]. Derive from Layer 0.3:
   - policy iteration, with ties kept at the current action, improves monotonically;
   - $T^nv^{d_0}\le v^{d_n}\le v^*$, so $\|v^{d_n}-v^*\|\le\gamma^n\|v^{d_0}-v^*\|$;
   - for finite `𝓢`, it reaches an optimal policy after at most $|\mathcal A|^{|\mathcal S|}$
     improvements.
   
   Prove the Newton form $v_{n+1}=v_n+(I-\gamma P_{d_{n+1}})^{-1}(Tv_n-v_n)$ and the support
   inequality $Tu-u\ge Tv-v+(\gamma P_{d_v}-I)(u-v)$.
3. **Modified policy iteration** [P, §6.5, Proposition 6.5.1].
   - Derive from Layer 0.3 the convergence of $v_{n+1}=(T_{d_{n+1}})^{m_n+1}v_n$, with $d_{n+1}$
     greedy for $v_n$, from any $v_0$ with $Tv_0\ge v_0$, for example
     $v_0=(1-\gamma)^{-1}\inf_{s,a}r(s,a)$.
   - Prove the expansion $v_{n+1}=v_n+\sum_{k\le m_n}(\gamma P_{d_{n+1}})^k(Tv_n-v_n)$.
4. **Bounds and stopping** [P, Theorem 6.6.3, Corollary 6.6.4, Proposition 6.6.5]. For bounded
   measurable $v$, $d$ greedy for $v$ and $m\ge-1$, prove:
   $$v+\sum_{k=0}^m(\gamma P_d)^k(Tv-v)+\frac{\gamma^{m+1}}{1-\gamma}\inf(Tv-v)\le v^d\le v^*\le
   T^{m+1}v+\frac{\gamma^{m+1}}{1-\gamma}\sup(Tv-v).$$
   - For $m\in\{-1,0\}$ this is [P, Corollary 6.6.4].
   - For $m\ge1$, the upper bound of [P, (6.6.9)], with $\sum_k(\gamma P_d)^k$ in place of
     $T^{m+1}$, is false. A two-state counterexample with $\gamma=1/2$ and a tie in the greedy choice
     shows it; the corrected bound is stated here.
   
   Prove the stopping rule of [P, Proposition 6.6.5] in the form
   $\gamma\,\mathrm{sp}(Tv-v)<(1-\gamma)\varepsilon$.
5. **Span contraction** [P, Proposition 6.6.1, Theorem 6.6.6, Corollary 6.6.7].
   - Let $\delta_M=\sup_{(s,a),(s',a')}\mathrm{tvDist}(P(s,a),P(s',a'))/2$. Prove
     $\mathrm{sp}(Tu-Tv)\le\gamma\,\delta_M\,\mathrm{sp}(u-v)$ on general `𝓢`.
   - Prove $\mathrm{sp}(T^2v-Tv)\le\gamma\,\delta_M\,\mathrm{sp}(Tv-v)$.
6. **Action elimination** [P, Proposition 6.7.1, Corollary 6.7.2, Proposition 6.7.3].
   - If $Q^*(s,a')<v^*(s)$, prove that every deterministic stationary policy $d$ with $d(s)=a'$ has
     $v^d(s)<v^*(s)$.
   - The same holds when $r(s,a')+\gamma\int v^U\,dP(s,a')<v^L(s)$ for bounds $v^L\le v^*\le v^U$.

Completion checks: value iteration from $v_0=0$ on a one-state MDP is the partial geometric sum;
policy iteration on a two-state, two-action MDP terminates in at most two improvements.

## Layer 11: Occupancy measures and linear programming

1. **Discounted occupancy.**
   - For every algorithm define the state–action occupancy
     `M.occupancy γ alg μ` $=(1-\gamma)\sum_n\gamma^n\,\mathrm{law}(S_n,A_n)$, a probability measure
     on `𝓢 × 𝓐`. For a stationary policy, it is $\mu\otimes\pi$`.bind` $G_\gamma(P^\pi_{SA})$, with
     Layer 1.4's resolvent.
   - Prove `M.runValue γ alg μ` $=(1-\gamma)^{-1}\int r\,d\,$`occupancy`.
   - Prove the flow equation: for measurable $B$,
     $x(B\times\mathcal A)=(1-\gamma)\mu(B)+\gamma\int P(s,a)(B)\,x(ds,da)$.
2. **Characterization** [P, Theorem 6.9.1, Corollary 6.9.2], [AJKS, Proposition 1.15]. Let `𝓐` be
   standard Borel and μ a probability measure.
   - Prove that every finite measure on `𝓢 × 𝓐` satisfying the flow equation is the occupancy
     measure of the stationary policy obtained by disintegrating it (Mathlib's
     `Measure.condKernel`). For finite spaces this is $\pi(a|s)=x(s,a)/\sum_{a'}x(s,a')$ where the
     denominator is positive.
   - Deduce that every algorithm has a stationary randomized policy with the same occupancy measure,
     hence the same value.
   - Deduce that the set of occupancy measures from μ is convex.
3. **Linear programs** [P, §6.9] for finite `𝓢`, `𝓐` and weights α > 0 with $\sum\alpha=1$.
   - The primal is: minimize $\sum_s\alpha(s)v(s)$ subject to
     $v(s)\ge r(s,a)+\gamma\sum_{s'}P(s'|s,a)v(s')$.
   - The dual is: maximize $(1-\gamma)^{-1}\sum r\,x$ over the probability measures $x$ satisfying the
     flow equation of item 1 with μ = α.
   - Prove: primal feasibility is $v\ge Tv$; $v^*$ is the unique primal optimum; both optimal values
     equal $\langle\alpha,v^*\rangle$.
   - Prove that dual optima are exactly the occupancy measures of optimal stationary policies
     [P, Theorem 6.9.4].
   - Prove that the extreme points of the flow polytope (Mathlib's `Set.extremePoints`) are exactly
     the occupancy measures of deterministic stationary policies [P, Proposition 6.9.3].
   - Prove that the set of optimal deterministic policies does not depend on α [P, Proposition
     6.9.5].
   - Prove all of this from Layers 9.3–9.5 and 11.2, without a general LP duality theorem.
4. **Episodic occupancy.** For an episodic MDP and a Markov policy:
   - define $d^\pi_h=\mathrm{law}(S_h,A_h)=\mu_h\otimes_m\pi_h$, with the state marginals $\mu_h$ of
     Layer 7.3 for the kernels `M.trans`;
   - prove the flow $\sum_ad_{h+1}(\cdot,a)=P_h\circ_md_h$ with $d_0=\mu\otimes_m\pi_0$;
   - prove $\mathbb E_\pi\sum_hf_h(S_h,A_h)=\sum_h\langle d^\pi_h,f_h\rangle$.
   
   For standard Borel `𝓐`, prove that every sequence of probability measures $d_h$ on `𝓢 × 𝓐`
   satisfying the flow, with the first marginal of $d_0$ equal to μ, is realized by the Markov policy
   obtained by disintegrating $d_h$ (for finite spaces $\pi_h(a|s)=d_h(s,a)/d_h(s)$). For finite
   spaces, the occupancy polytope of an episodic MDP is the domain of Layer 20.

Completion checks: for $\gamma=0$ the occupancy measure is $\mu\otimes\pi$; in a one-state MDP the
dual LP is a bandit's simplex.

## Layer 12: Value-difference calculus and variance identities

These identities hold on measurable spaces with bounded functions. Items involving optimal or greedy
policies assume `𝓐` finite. Where the source states them for finite spaces, state them in this
generality. Here $\|\cdot\|$ is the sup norm, and an estimated model $\hat M$ has its own transition
and reward kernels $\hat P$ and $\hat R$, with mean reward $\hat r$.

1. **The extended value-difference identity** [JYW21, Lemma A.1].
   - Let $\hat Q_h$ be bounded measurable, let $\hat\pi,\pi$ be Markov policies, and set
     $\hat V_h(s)=\int\hat Q_h(s,a)\,\hat\pi_h(da|s)$ with $\hat V_H=0$. Prove
     $$\hat V_0(s)-V^\pi_0(s)=\sum_h\mathbb E^\pi_s\big[\langle\hat Q_h(S_h,\cdot),\hat\pi_h(\cdot|S_h)-\pi_h(\cdot|S_h)\rangle\big]+\sum_h\mathbb E^\pi_s\big[(\hat Q_h-r_h-P_h\hat V_{h+1})(S_h,A_h)\big].$$
   - State the discounted analogue, with $(1-\gamma)^{-1}$ and the occupancy measure of Layer 11.1.
2. **Corollaries.** The first two are instances of Layer 1.5.
   - The performance difference lemma [AJKS, Lemma 1.16], for every algorithm and stationary
     $\pi'$: `M.runValue γ alg μ` $-\int v^{\pi'}d\mu=(1-\gamma)^{-1}\int A^{\pi'}\,d\,$`occupancy`.
     Give its episodic form.
   - The simulation lemma [AJKS, Lemma 2.2], [KS02], with a reward error:
     $Q^\pi_M-Q^\pi_{\hat M}=R_\gamma(\hat P^{\pi}_{SA})\big((r-\hat r)+\gamma(P-\hat P)v^\pi_M\big)$.
     Give its episodic form and, for rewards of $M$ in $[0,1]$, the bound
     $\|Q^\pi_M-Q^\pi_{\hat M}\|\le(1-\gamma)^{-1}\|r-\hat r\|+\gamma(1-\gamma)^{-2}\sup_{s,a}\mathrm{tvDist}(P(s,a),\hat P(s,a))$.
   - The componentwise bounds [AJKS, Lemma 2.5], with a reward error:
     $R_\gamma(\hat P^{\hat\pi^*}_{SA})\big((r-\hat r)+\gamma(P-\hat P)v^*\big)\le Q^*-\hat Q^*\le R_\gamma(\hat P^{\pi^*}_{SA})\big((r-\hat r)+\gamma(P-\hat P)v^*\big)$.
   - Every statement of LMLExplore's `MarkovDecisionProcess/Simulation.lean` assumes
     `meanReward M'.R = meanReward M.R`; state them with the reward error. It serves the perturbed
     rewards of Layers 15.4 (c) and 21.3 and the estimated rewards of Layer 21.1.
   - The greedy bound [AJKS, Lemma 1.11]: the policy greedy for $Q$ has
     $v^{\pi_Q}\ge v^*-2\|Q-Q^*\|/(1-\gamma)$.
   - The episodic greedy bound [AJKS, Lemma 3.4]: if
     $\|\hat Q_h-r_h-P_h\max\hat Q_{h+1}\|\le\varepsilon$ for all $h$, then
     $\|\hat Q_h-Q^*_h\|\le(H-h)\varepsilon$ and $V^{\hat\pi}_0\ge V^*_0-2H^2\varepsilon$.
   - The optimistic decomposition: if $\hat V_H=0$, $\hat V_h(s)\le\int\hat Q_h(s,a)\,\hat\pi_h(da|s)$
     and $\hat Q_h\le r_h+b_h+\hat P_h\hat V_{h+1}$, then
     $\hat V_0-V^{\hat\pi}_0\le\sum_h\mathbb E^{\hat\pi}[(b_h+(\hat P_h-P_h)\hat V_{h+1})(S_h,A_h)]$.
   - The pessimistic decomposition [JYW21, Theorem 4.2, deterministic part]. Let pessimistic value
     iteration be $\hat Q_h=\min(\hat B_h\hat V_{h+1}-\Gamma_h,H-h)^+$ and $\hat V_h=\max_a\hat Q_h$,
     with arbitrary estimates $\hat B_h$ and greedy policy $\hat\pi$. If
     $|\hat B_h\hat V_{h+1}-B_h\hat V_{h+1}|\le\Gamma_h$ pointwise, prove
     $V^*_0-V^{\hat\pi}_0\le2\sum_h\mathbb E^{\pi^*}[\Gamma_h(S_h,A_h)]$.
   - The policy-mixture lemma [AJKS, Lemma 14.1]: for $\pi'=(1-\alpha)\pi+\alpha\pi''$, the state
     marginals of the occupancy measures from μ satisfy `tvDist` $\le2\alpha\gamma/(1-\gamma)$. The
     state–action occupancy measures satisfy `tvDist` $\le2\alpha/(1-\gamma)$.
3. **Variance identities.** These are instances of Layer 1.9.
   - [AJKS, Lemma 2.11], for a deterministic stationary π: the variance $\Sigma^\pi(s,a)$ of the
     discounted return started from $(s,a)$ satisfies
     $\Sigma^\pi=\gamma^2\mathrm{Var}_P(v^\pi)+\gamma^2P^\pi_{SA}\Sigma^\pi$. For rewards in $[0,1]$,
     $\|\Sigma^\pi\|\le\gamma^2/(1-\gamma)^2$. For randomized π, state the corollary of Layer 1.9 on
     the state–action chain, with $\mathrm{Var}_{P^\pi_{SA}}(Q^\pi)$ in place of $\mathrm{Var}_P(v^\pi)$.
   - The total-variance lemma [AJKS, Lemma 2.12]: for rewards in $[0,1]$ and every stationary π,
     $\|R_\gamma(P^\pi_{SA})\sqrt{\mathrm{Var}_P(v^\pi)}\|\le\sqrt{2/(1-\gamma)^3}$.
   - Its sharpening [LWCGC24, Lemma 11]: for $0<\gamma<1$ and $r_\pi\ge0$,
     $\|R_\gamma(P_\pi)\sqrt{\mathrm{Var}_{P_\pi}(v^\pi)}\|\le4\|v^\pi\|/(\gamma\sqrt{1-\gamma})$.
   - The episodic law of total variance: for a Markov policy, rewards in $[0,1]$ and every initial
     state $s$, $\mathbb E^\pi_s\sum_h\mathrm{Var}_{P_h(S_h,A_h)}(V^\pi_{h+1})\le\mathrm{Var}^\pi_s\big(\sum_hr_h(S_h,A_h)\big)\le H^2$,
     with equality in the first inequality for deterministic policies.

Completion checks: the performance difference of a policy with itself is zero; the simulation lemma
with $\hat P=P$ and $\hat r=r$ is trivial, and with $\hat P=P$ it reduces to
$Q^\pi_M-Q^\pi_{\hat M}=R_\gamma(P^\pi_{SA})(r-\hat r)$; the total-variance bound is attained up to constants by a two-state
chain with an absorbing rewarding state.

## Layer 13: Average reward and sensitive discount optimality

Throughout, `𝓢` and `𝓐` are finite unless an item says otherwise, and $P_\pi^*$ and $D_\pi$ are
the limiting and deviation matrices of Layer 2 of `M.stateKernel π`.

1. **Markov reward processes** [P, §8.2].
   - Define the gain `M.gain π` $=P^*_\pi r_\pi$ and the bias `M.bias π` $=D_\pi r_\pi$.
   - Prove that the gain is the Cesàro limit of $\frac1N\sum_{n<N}P_\pi^nr_\pi$, constant on each
     closed class and constant on `𝓢` for a unichain policy [P, Proposition 8.2.1].
   - For a unichain policy, prove that $\frac1N\sum_{n<N}r(S_n,A_n)$ converges almost surely to the
     gain (Layer 1.8, with the Poisson solution $D_\pi r_\pi$).
   - Prove that the bias is the Cesàro limit of the total reward when the gain is zero [P,
     Proposition 8.2.2].
   - Prove the Laurent expansion of $v^\pi_\gamma$ [P, Theorem 8.2.3] from Layer 2.2, with $T$ the
     action of $P_\pi$ on `boundedMeasurable 𝓢` and $v^\pi_\gamma=(1-\gamma P_\pi)^{-1}r_\pi$
     (Layer 9.2). Prove its corollaries $v^\pi_\gamma=(1-\gamma)^{-1}g^\pi+h^\pi+o(1)$ and
     $g^\pi=\lim_{\gamma\uparrow1}(1-\gamma)v^\pi_\gamma$ [P, Corollaries 8.2.4–8.2.5].
   - Prove the evaluation equations $(I-P_\pi)g=0$ and $g+(I-P_\pi)h=r_\pi$, the description of all
     their solutions, and the unichain form [P, Theorem 8.2.6, Corollary 8.2.7].
2. **Classification** [P, §8.3.1].
   - Define recurrent, unichain, communicating, weakly communicating and multichain MDPs through the
     chains of deterministic stationary policies and the closed communicating classes of Layer 2.3.
   - Prove the inclusions of [P, Figure 8.3.1].
   - Define the diameter
     $D(M)=\max_{s\ne s'}\min_\pi\mathbb E^\pi_s[\text{hitting time of }s']$, with the minimum over
     deterministic stationary policies [LS, Definition 38.1]. Prove that it is finite exactly for
     communicating MDPs.
3. **Criteria.**
   - For an algorithm and initial law μ, define
     $g^{\mathrm{alg}}_-(\mu)=\liminf_N\frac1N\sum_{n<N}\mathbb E\,r(S_n,A_n)$ and $g^{\mathrm{alg}}_+(\mu)$
     with limsup. Define $g^*_\pm$ as their suprema over algorithms. State the limits in the eventual
     form of the Conventions.
   - Where $g^*_-=g^*_+$ is a constant, write it $\rho^*$, and $\rho^\pi$ for the gain of a stationary
     policy with constant gain.
   - Define $n$-discount optimality [P, (10.1.1)], and Blackwell optimality: one policy optimal for
     every γ in some $[\gamma_0,1)$.
4. **Verification** [P, Theorem 8.4.1, Corollary 8.4.2, Theorem 8.4.4]. For general `𝓢`, finite `𝓐`
   and bounded measurable $h$, prove:
   - if $g+h\ge\max_a\{r+Ph\}$, then $g^*_+\le g$;
   - if $g+h\le\max_a\{r+Ph\}$, then the greedy policy for $h$ has $g_-\ge g$;
   - an $h$-greedy policy for a solution of the equation is average-optimal.
5. **Existence.**
   - Unichain models [P, Theorems 8.4.3, 8.4.5]: the optimality equation has a solution with a
     unique gain; a deterministic stationary average-optimal policy exists; $g^*_-=g^*_+$.
   - Multichain models [P, Theorems 9.1.3, 9.1.4, 9.1.6–9.1.8]: the equations
     $\max_a\{\sum_{s'}P(s'|s,a)g(s')-g(s)\}=0$ and
     $\max_{a\in B_s}\{r(s,a)-g(s)+\sum_{s'}P(s'|s,a)h(s')-h(s)\}=0$, with $B_s$ the maximizers of the
     first, have a solution; the verification theorem holds; a deterministic stationary
     average-optimal policy exists.
   - Communicating models, rewards in $[0,1]$ [LS, Theorem 38.2 (a), Lemma 38.3]: prove
     $\mathrm{osc}(v^*_\gamma)\le D(M)$; that the unichain equation has a solution through Layer 0.5;
     and that every solution has $\mathrm{sp}(h)\le D(M)$.
   - Weakly communicating models [P, §9.5]: the optimal gain is a constant $\rho^*$, and the unichain
     equation has a solution $(\rho^*,h^*)$ with $h^*$ the bias of a Blackwell-optimal policy
     (item 7). Prove $\|v^*_\gamma-\rho^*/(1-\gamma)\|\le\mathrm{sp}(h^*)$ [WJLSJ20, Lemma 2].
6. **Algorithms.**
   - Relative value iteration and value iteration, on general `𝓢`, as instances of Layer 0.4
     [P, Proposition 8.5.1, Theorem 8.5.2]. The hypothesis is the two-policy coefficient
     $\sup\mathrm{tvDist}(P^J_{\pi_1}(s),P^J_{\pi_2}(u))/2<1$, over deterministic Markov policies
     $\pi_1,\pi_2$ and states $s,u$.
   - Its sufficient conditions for finite `𝓢` [P, Theorem 8.5.3].
   - The aperiodicity transformation [P, §8.5.4]: for $0<\tau<1$, the model with kernel
     $\tau P+(1-\tau)I$ and reward $\tau r$ has gains $\tau g^d$, the same biases $h^d$ and the same
     optimal policies.
   - Action elimination [P, Proposition 8.5.10].
   - Average-reward policy iteration [P, Proposition 8.6.1, Theorem 8.6.2]: finite termination at an
     optimal policy in recurrent models. In unichain models [P, §8.6], with ties kept at the current
     action and biases normalized by $P^*h=0$, it terminates after finitely many iterations at an
     average-optimal policy.
7. **Sensitive discount optimality** [P, §10.1]. Prove:
   - an $n$-discount optimal policy is $m$-discount optimal for $-1\le m\le n$ [P, Proposition
     10.1.1];
   - $\gamma\mapsto v^d_\gamma(s)$ is rational of degree at most $|\mathcal S|$ (Layer 2.6)
     [P, Lemma 10.1.3];
   - a deterministic stationary Blackwell-optimal policy exists [P, Theorem 10.1.4];
   - Blackwell optimality implies $n$-discount optimality for all $n$ [P, Theorem 10.1.5];
   - the lexicographic characterization through the Laurent coefficients [P, (10.1.7), Theorem
     10.1.6].
8. **From discounted to average reward.** Rewards in $[0,1]$.
   - [JS21, Lemmas 2–3]. Let $t_{\mathrm{mix}}\ge1$ be the maximum over deterministic stationary π
     of $t_{\mathrm{mix}}(1/4)$ (Layer 1.7) of `M.stateKernel π`, and $0<\varepsilon<1$. Prove:
     - $\|g^\pi-(1-\gamma)v^\pi_\gamma\|\le3(1-\gamma)t_{\mathrm{mix}}$;
     - for $\gamma=1-\varepsilon/(9t_{\mathrm{mix}})$, every $\varepsilon/(3(1-\gamma))$-optimal
       discounted policy is $\varepsilon$-optimal for the gain.
   - [ZC24, Lemma 9], from [WWY22]. For a weakly communicating MDP with $\mathrm{sp}(h^*)\le\mathsf H$,
     $\mathsf H\ge1$, $\varepsilon\in(0,1]$ and $\gamma=1-\varepsilon/\mathsf H$, prove: every
     $\varepsilon_\gamma$-optimal discounted policy with $\varepsilon_\gamma\in[0,1/(1-\gamma)]$ has
     $\rho^*-\rho^\pi\le(8+3\varepsilon_\gamma/\mathsf H)\varepsilon$.
   - [ZC24, Lemma 15]. For a positive integer $\mathsf H\ge\mathrm{sp}(h^*)$ and
     $\gamma\ge1-1/\mathsf H$, prove that every deterministic stationary γ-optimal policy $\pi$ has
     $\|\mathrm{Var}^{\pi}[\sum_t\gamma^tr(S_t,A_t)]\|\le5\mathsf H/(1-\gamma)$.

Completion checks: a two-state periodic chain has a Cesàro but no ordinary limit and a well-defined
bias; the classical example of a 0-discount optimal policy that is not Blackwell optimal
[P, Example 10.1.1].
## Layer 14: Learning infrastructure

Throughout the learning layers (14–23), `𝓢` and `𝓐` are finite and rewards lie in $[0,1]$, unless
an item says otherwise.

1. **Counts and empirical kernels.**
   - In `M.env μ`, counts of state–action pairs are LML's `pullCount` of the pair process
     $n\mapsto(S_n,A_n)$.
   - In `statesEnv` and `episodeEnv`, the episodic counts
     $N^k_h(s,a)=\#\{i<k:(S^i_h,A^i_h)=(s,a)\}$ are counts before episode $k$, with $A^i_h$ the
     action of the policy of episode $i$. For stationary transitions, the pooled counts are
     $N^k(s,a)=\sum_hN^k_h(s,a)$.
   - The empirical kernel $\hat P$ is the empirical law of the next states observed after the visits
     of $(s,a)$ (at step $h$, or pooled over steps). It is the uniform law on `𝓢` when the count is
     zero. In `M.env μ` and `episodeEnv`, the empirical mean reward $\hat r(s,a)$ is the average of
     the rewards observed at these visits, and $0$ when the count is zero.
   - Prove measurability in the history, and that $\hat P(s,a)$ is a probability measure.
2. **Visits and stream models.**
   - `M.env μ` is key-determined (Layer 6.1) with the key $(s,a)$. The reward and the next state of
     the $j$-th visit of $(s,a)$ are the $j$-th draws of independent streams with laws `M.R (s, a)`
     and `M.P (s, a)`.
   - In `statesEnv`, every round contains $H$ visits. Construct the per-$(h,s,a)$ streams of law
     $P_h(s,a)$, read at the visits of $(h,s,a)$ within the observed state sequences, and prove the
     stream representation and the transfer of Layer 6.1 for them [entropy-mdp, `Visits.lean`].
     For stationary transitions, prove the same with per-$(s,a)$ streams pooled over steps.
   - In `episodeEnv`, prove the same with per-$(h,s,a)$ streams of law $R_h(s,a)\otimes P_h(s,a)$
     for the pair (reward, next state), pooled over steps for stationary transitions and rewards.
   - The confidence events of Layers 18–21 are those of their sources, with the radii given there.
     Prove each from these stream models and Layer 3.
3. **Generative sampling.**
   - A generative model of a stationary `M` is LML's `streamMeasure M.P` on `ℕ → 𝓢 × 𝓐 → 𝓢`.
     Coordinate $(i,(s,a))$ is the $i$-th sample from $P(s,a)$; $N$ samples per pair use the
     coordinates $i<N$.
   - For an `EpisodicMDP`, it is `streamMeasure` of $(h,s,a)\mapsto P_h(s,a)$ on keys
     `Fin H × 𝓢 × 𝓐`.
   - Prove that the coordinates of disjoint sets of keys are independent.
   - Define the empirical kernel and the empirical MDP `M.empirical N ω`, with the same rewards.
   - Adaptive sampling is a run of an algorithm against `stationaryEnv M.P`.
4. **Pigeonhole sums.** Here $N_k(x)=\#\{i<k:x_i=x\}$ is stated with LML's `pullCount`. For every
   sequence $(x_k)$ in a finite type with $m\ge1$ elements, prove:
   - $\sum_{k<K}(N_k(x_k)+1)^{-1/2}\le2\sqrt{mK}$;
   - $\sum_{k<K}(N_k(x_k)+1)^{-1}\le m(1+\log(1+K/m))$;
   - $\sum_{k<K}\max(1,N_k(x_k))^{-1/2}\le2\sqrt{mK}+m$;
   - $\sum_{k<K}\max(1,N_k(x_k))^{-1}\le m(2+\log K)$ for $K\ge1$.
   
   Also prove the doubling-epoch bound [JOA10, Lemma 19]: for $z_k\ge0$ with
   $Z_k=\sum_{i<k}z_i$ and $z_k\le\max(1,Z_k)$, $\sum_{k<n}z_k/\sqrt{\max(1,Z_k)}\le(\sqrt2+1)\sqrt{Z_n}$.
5. **Learning-rate weights** [JABJ18, Lemma 4.1]. Let $\alpha_t=(H+1)/(H+t)$ for $t\ge1$,
   $\alpha^0_t=\prod_{j=1}^t(1-\alpha_j)$, and $\alpha_t^i=\alpha_i\prod_{j=i+1}^t(1-\alpha_j)$ for
   $1\le i\le t$. Prove:
   - $\sum_{i=1}^t\alpha_t^i=1$ and $\alpha^0_t=0$ for $t\ge1$;
   - $t^{-1/2}\le\sum_{i=1}^t\alpha_t^i\,i^{-1/2}\le2t^{-1/2}$;
   - $\max_i\alpha_t^i\le2H/t$ and $\sum_i(\alpha_t^i)^2\le2H/t$;
   - $\sum_{t\ge i}\alpha_t^i=1+1/H$.
   
   Also prove the general identity
   $\sum_{i=1}^t\eta_i\prod_{j=i+1}^t(1-\eta_j)=1-\prod_{j=1}^t(1-\eta_j)$.
6. **Divergence decomposition for MDP runs** [OPT18], [AGP21], [DMKV21, Lemma 5].
   - For runs of one algorithm in `M.env μ` and `M'.env μ`, prove from Layer 6.2 with the key
     $(s,a)$: at a stopping time τ almost surely finite under `M`, the KL divergence between the laws
     of the stopped histories is at most
     $\sum_{s,a}\mathbb E_M[N_{s,a}(\tau)]\big(\mathrm{KL}(R(s,a),R'(s,a))+\mathrm{KL}(P(s,a),P'(s,a))\big)$,
     with equality when τ is also almost surely finite under `M'`, and with equality at a fixed
     horizon. This is the change of measure of the lower bounds of [OPT18] and [AGP21].
   - From Layer 6.2 and the chain rule within an episode, prove that the KL divergence between the
     laws of the history of $K$ episodes in `statesEnv` under two episodic MDPs with the same
     initial law is $\sum_{h,s,a}\mathbb E_M[N^K_h(s,a)]\,\mathrm{KL}(P_h(s,a),P'_h(s,a))$, and in
     `episodeEnv` the same with $\mathrm{KL}(R_h(s,a),R'_h(s,a))$ added. Prove the same at a
     stopping time with respect to the episode filtration.
7. **Regret.** For an algorithm in `statesEnv` or `episodeEnv` with initial law μ and policies
   $\pi_k$:
   - define the pseudo-regret after $K$ episodes as the random variable
     $\sum_{k<K}\big(\int V^*_0d\mu-\int V^{\pi_k}_0d\mu\big)$ (Layer 8.4), and the expected regret
     as its expectation;
   - define the regret at the realized initial states $\sum_{k<K}(V^*_0-V^{\pi_k}_0)(S^k_0)$, as in
     the sources;
   - prove that, with probability at least $1-\delta$, the two differ by at most
     $H\sqrt{2K\log(2/\delta)}$. Upper bounds below are stated for the realized form, as in the
     sources; this lemma transfers them up to the stated term.

Completion checks: for a one-state MDP the stream model of item 2 is the bandit one; the pigeonhole
bound is attained up to the constant by the round-robin sequence.

## Layer 15: Planning with a generative model

Discounted MDPs with deterministic rewards $r$ in $[0,1]$ (`M.R = Kernel.deterministic r _`), and
`M.empirical N ω` built from $N\ge1$ samples per pair. "With probability at least $1-\delta$" refers
to `streamMeasure M.P` unless an item says otherwise.

1. **Crude bounds** [AJKS, Propositions 2.1, 2.4]. Let $\eta=\sqrt{2(\log(SA/\delta)+S\log2)/N}$,
   which bounds $\max_{s,a}\mathrm{tvDist}(P(s,a),\hat P(s,a))$ with probability at least
   $1-\delta$ by Layer 3.3. Prove that on this event:
   - $\sup_\pi\|Q^\pi-\hat Q^\pi\|\le\gamma\eta/(1-\gamma)^2$;
   - $\|Q^*-\hat Q^*\|\le\gamma\eta/(1-\gamma)^2$;
   - $\|Q^{\hat\pi^*}-Q^*\|\le2\gamma\eta/(1-\gamma)^2$.
   
   Prove also that, with probability at least $1-\delta$,
   $\|Q^*-\hat Q^*\|\le\gamma(1-\gamma)^{-2}\sqrt{2\log(2SA/\delta)/N}$, by Hoeffding with $v^*$
   fixed.
2. **Value estimation** [AJKS, Theorem 2.6 (first claim)], [AMK13]. Prove: there is $C>0$ such that,
   for all MDPs and all $\delta\in(0,1)$, with probability at least $1-\delta$,
   $$\|Q^*-\hat Q^*\|\le\gamma\sqrt{\frac{C\log(CSA/\delta)}{(1-\gamma)^3N}}+\frac{C\gamma\log(CSA/\delta)}{(1-\gamma)^3N}.$$
   The proof runs through Bernstein for $(P-\hat P)v^*$, a variance comparison, and Layer 12.3 under
   the empirical MDP.
3. **The plug-in policy is minimax optimal** [AKY20, Theorem 1].
   - Statement: there is $C>0$ such that, for $\gamma\ge1/2$, $\varepsilon\in(0,(1-\gamma)^{-1/2}]$
     and $N\ge C\gamma\log(CSA/((1-\gamma)\delta))/((1-\gamma)^3\varepsilon^2)$, with probability at
     least $1-\delta$, every policy $\hat\pi$ with $\|\hat Q^{\hat\pi}-\hat Q^*\|\le\varepsilon_{\mathrm{opt}}$
     satisfies $Q^{\hat\pi}\ge Q^*-\varepsilon-9\varepsilon_{\mathrm{opt}}/(1-\gamma)$.
   - Build the absorbing-MDP API it needs: replace the row of one state by an absorbing transition
     with reward $(1-\gamma)u$, compare values, and use a finite net of values $u$. The independence
     of Layer 14.3 across keys gives the decoupling.
4. **The full range of accuracies** [LWCGC24].
   - (a) Theorem 4, finite horizon, with the episodic generative model of Layer 14.3: there is
     $C>0$ such that, for $\varepsilon\in(0,H]$ and $N\ge CH^3\log(HSA/\delta)/\varepsilon^2$
     samples per $(h,s,a)$, with probability at least $1-\delta$, the optimal policy of the
     empirical episodic MDP is $\varepsilon$-optimal at every step.
   - (b) Lemma 1, policy evaluation, for a policy π fixed independently of the data: if
     $N\ge32e^2(1-\gamma)^{-1}\log(4S\log(e/(1-\gamma))/\delta)$, then with probability at least
     $1-\delta$, $\|\hat v^\pi-v^\pi\|\le6\sqrt{2\log(4S\log(e/(1-\gamma))/\delta)/(N(1-\gamma)^3)}$.
   - (c) Theorem 1, perturbed plug-in. Let $r_p=r+\zeta$ with $\zeta(s,a)$ i.i.d. uniform on
     $[0,\xi]$ and $\xi=c_1(1-\gamma)\varepsilon/(S^5A^5)$, independent of the samples; here the
     probability is over `streamMeasure M.P` and the law of ζ. Prove: there are $c_0,c_1>0$ such
     that, for $\varepsilon\in(0,1/(1-\gamma)]$ and
     $N\ge c_0\log(SA/((1-\gamma)\varepsilon\delta))/((1-\gamma)^3\varepsilon^2)$, the optimal
     policy $\hat\pi_p$ of $(\hat P,r_p)$ satisfies $V^{\hat\pi_p}\ge V^*-\varepsilon$ and
     $Q^{\hat\pi_p}\ge Q^*-\gamma\varepsilon$ with probability at least $1-\delta$.
5. **Lower bound** [AMK13, Theorem 3], corrected.
   - [AMK13] uses a family of two MDPs with a common self-loop probability. Samples at different
     pairs then carry information about one another, and the proof's independence claim fails.
   - Use the product family instead: the self-loop probability of each hard pair is chosen
     independently in $\{p,p+\alpha\}$, with the source's $p$ and α.
   - With one action set for all states, the source's class has $K$ states with $A$ actions and
     $2KA$ states whose actions all behave alike, so $S=K(1+2A)$ and there are $KA$ hard pairs.
   - Prove: there are $C,\varepsilon_0,\delta_0>0$ such that, for $\gamma\ge2/5$,
     $\varepsilon\in(0,\varepsilon_0]$ and $\delta\in(0,\delta_0/(KA))$, every algorithm querying
     `stationaryEnv M.P` adaptively for $T$ rounds whose estimate of $Q^*$ is ε-accurate with
     probability at least $1-\delta$ on every MDP of the family has
     $T\ge KA\log(KA/(C\delta))/(C(1-\gamma)^3\varepsilon^2)$.
   - Use the change of measure of Layer 6.2 at the fixed budget $T$.

Completion check: item 4 (a) for $H=1$ is a statement about one-step rewards.

## Layer 16: Q-learning and temporal-difference learning

1. **Definitions.**
   - Synchronous Q-learning on the generative model, with deterministic rewards as in Layer 15, for
     $t\ge1$: $Q_t=(1-\eta_t)Q_{t-1}+\eta_t(r+\gamma\max_aQ_{t-1}(X_t(\cdot),a))$, with $X_t(s,a)$
     the $t$-th sample and $0\le Q_0\le1/(1-\gamma)$.
   - Asynchronous Q-learning along a run of any algorithm in `M.env μ`, with bounded stochastic
     rewards: $Q_{t+1}(S_t,A_t)=(1-\alpha_t)Q_t(S_t,A_t)+\alpha_t(Y_t+\gamma\max_aQ_t(S_{t+1},a))$
     with the observed reward $Y_t$, and $Q_{t+1}=Q_t$ elsewhere. The learning rate
     $\alpha_t(s,a)$ is measurable for LML's `filtrationAction` at round $t$ (the history through
     $(S_t,A_t)$), and vanishes off $(S_t,A_t)$.
   - Tabular TD(0) is the case of one action.
2. **Almost-sure convergence** [Tsi94, Theorem 4 (a)].
   - For asynchronous Q-learning with learning rates in $[0,1]$, $\sum_t\alpha_t(s,a)=\infty$
     almost surely and $\sum_t\alpha_t(s,a)^2\le C$ for a deterministic $C$ and every pair, prove
     that $Q_t\to Q^*$ almost surely.
   - Use Layer 4.3 with the operator `M.qBellman γ` of Layer 9.1, a γ-contraction for the sup norm
     whose fixed point is $Q^*$ (Layer 9.4). The reward noise $Y_t-r(S_t,A_t)$ is part of the
     martingale noise. The source minimizes costs; translate.
3. **The sample complexity of Q-learning** [LCCWC24]. All constants are in "∃ C" form.
   - (a) Theorem 2: there are $c_1,c_2,C>0$ such that, for $\gamma\in[1/2,1)$, $\varepsilon\in(0,1]$,
     $\delta\in(0,1)$, $T\ge2$, learning rates with
     $1/(1+c_1(1-\gamma)T/\log^3T)\le\eta_t\le1/(1+c_2(1-\gamma)t/\log^3T)$ and
     $T\ge C\log^4T\log(SAT/\delta)/((1-\gamma)^4\varepsilon^2)$, $\|Q_T-Q^*\|\le\varepsilon$ with
     probability at least $1-\delta$.
   - (b) Theorem 1, TD: the same with $\log^2T$ in the learning-rate window and
     $T\ge C\log^3T\log(ST/\delta)/((1-\gamma)^3\varepsilon^2)$.
   - (c) Theorem 3: there is $C>0$ such that, for every $\gamma\in[3/4,1)$, there is a four-state,
     two-action MDP such that, for every $T\ge C/(1-\gamma)^2$, Q-learning from $Q_0=0$ with
     $\eta_t=1/(1+c_\eta(1-\gamma)t)$, or with a constant $\eta\in(0,1)$, has
     $\max_s\mathbb E(V_T(s)-V^*(s))^2\ge1/(C(1-\gamma)^4T\log^2T)$.
4. **TD with linear function approximation.** Let $(P_\pi,r_\pi)$ be the Markov reward process of a
   stationary policy on finite `𝓢`, with invariant law ν (Layer 2) and $D=\mathrm{diag}(\nu)$. Let
   $\varphi:\mathcal S\to E$ map into a finite-dimensional inner product space, with $\|\varphi\|\le1$
   and $\sum_s\nu(s)\varphi(s)\varphi(s)^\top\succeq\omega I$, $\omega>0$.
   - Projected Bellman geometry [TVR97, Lemmas 1, 4, 6, Theorem 1 and footnote 1], [BRS18, (5)]:
     - $P_\pi$ is a nonexpansion of $\|\cdot\|_D$;
     - the projected Bellman operator is a contraction with a unique fixed point $\theta^*$;
     - $\|\Phi\theta^*-v\|_D\le(1-\gamma^2)^{-1/2}\|\Pi v-v\|_D$.
   - Mean-path TD [BRS18, Lemmas 3–4, Theorem 1]:
     - $(\theta^*-\theta)^\top\bar g(\theta)\ge(1-\gamma)\|V_{\theta^*}-V_\theta\|_D^2$;
     - $\|\bar g(\theta)\|\le2\|V_\theta-V_{\theta^*}\|_D$;
     - with step $(1-\gamma)/4$: $\|V_{\theta^*}-V_{\bar\theta_T}\|_D^2\le4\|\theta^*-\theta_0\|^2/(T(1-\gamma)^2)$
       and $\|\theta^*-\theta_T\|^2\le e^{-(1-\gamma)^2\omega T/4}\|\theta^*-\theta_0\|^2$.
   - i.i.d. observations [BRS18, Theorem 2], with $\sigma^2=\mathbb E\|g_t(\theta^*)\|^2$:
     - (a) for $T\ge64/(1-\gamma)^2$ and step $1/\sqrt T$,
       $\mathbb E\|V_{\theta^*}-V_{\bar\theta_T}\|_D^2\le(\|\theta^*-\theta_0\|^2+2\sigma^2)/(\sqrt T(1-\gamma))$;
     - (b) for a constant step $\alpha_0\le\omega(1-\gamma)/8$,
       $\mathbb E\|\theta^*-\theta_T\|^2\le e^{-\alpha_0(1-\gamma)\omega T}\|\theta^*-\theta_0\|^2+2\alpha_0\sigma^2/((1-\gamma)\omega)$;
     - (c) for steps $\beta/(\lambda+t)$ with $\beta=2/((1-\gamma)\omega)$ and
       $\lambda=16/((1-\gamma)^2\omega)$, $\mathbb E\|\theta^*-\theta_T\|^2\le\kappa/(\lambda+T)$ with
       $\kappa=\max\{8\sigma^2/((1-\gamma)^2\omega^2),16\|\theta^*-\theta_0\|^2/((1-\gamma)^2\omega)\}$.
   - Almost-sure convergence of TD(0) with i.i.d. observations and steps with $\sum\alpha=\infty$,
     $\sum\alpha^2<\infty$, from Layer 4.2 [Zha25].
   - Markovian observations [BRS18, Theorem 3]: projected TD started from the invariant law, with
     projection radius $R\ge\|\theta^*\|$, $G=r_{\max}+2R$ and the geometric mixing of Layer 1.7. Prove
     the bounds (a)–(c) of the source with $\tau_{\mathrm{mix}}(\varepsilon)=\min\{t:m\rho^t\le\varepsilon\}$.

Completion checks: with one state, Q-learning is a stochastic approximation of a scalar fixed point
and item 3 reduces to averages of i.i.d. samples; TD with tabular features has $\theta^*=v^\pi$.

## Layer 17: Policy optimization

Finite `𝓢`, `𝓐`, exact values unless stated. The reward kernel is any one with rewards in $[0,1]$:
exact values depend on it only through the mean reward $r$, and deterministic rewards are not
assumed. ρ is the evaluation law, μ the starting law of the optimization, and $d^\pi_\rho$ the
state marginal of the occupancy measure. Mismatch coefficients $\|d^{\pi^*}_\rho/\mu\|_\infty$ and
$\|1/\mu\|_\infty$ are taken in `ℝ≥0∞`, or the items assume μ of full support. Iterates are indexed from 0. Sources stated with costs are translated by
$r\mapsto1-r$, which leaves the constants unchanged.

1. **Policy gradient theorem** [AJKS, Theorem 11.4].
   - For a parametrization $\theta\mapsto\pi_\theta$ differentiable on an open set of a
     finite-dimensional real normed space, prove
     $\nabla V^{\pi_\theta}(\mu)=(1-\gamma)^{-1}\mathbb E_{s\sim d^{\pi_\theta}_\mu}\sum_a\nabla\pi_\theta(a|s)\,Q^{\pi_\theta}(s,a)$,
     from the derivative of $(I-\gamma P_\pi)^{-1}$.
   - Derive the advantage form, and for $\pi_\theta>0$ the REINFORCE form in its causal version
     $\mathbb E\sum_t\gamma^tr_t\sum_{t'\le t}\nabla\log\pi_\theta(A_{t'}|S_{t'})$.
2. **Direct parametrization** [AKLM21, Lemma 4.1, Lemma D.3, Theorem 4.1]. Values are
   differentiated within the product of simplices (`HasFDerivWithinAt`). For $0<\gamma<1$:
   - gradient domination:
     $V^*(\rho)-V^\pi(\rho)\le(1-\gamma)^{-1}\|d^{\pi^*}_\rho/\mu\|_\infty\max_{\bar\pi}(\bar\pi-\pi)^\top\nabla_\pi V^\pi(\mu)$;
   - smoothness with constant $2\gamma A/(1-\gamma)^3$;
   - projected gradient ascent with step $(1-\gamma)^3/(2\gamma A)$ has
     $\min_{t<T}V^*(\rho)-V^{(t)}(\rho)\le\varepsilon$ once
     $T>64\gamma SA\|d^{\pi^*}_\rho/\mu\|^2_\infty/((1-\gamma)^6\varepsilon^2)$.
3. **Softmax parametrization** [MXSS20], [AKLM21, Theorem 5.1]. Prove:
   - the gradient formula
     $\partial_{\theta_{s,a}}V^{\pi_\theta}(\mu)=(1-\gamma)^{-1}d^{\pi_\theta}_\mu(s)\pi_\theta(a|s)A^{\pi_\theta}(s,a)$;
   - smoothness with constant $8/(1-\gamma)^3$ [MXSS20, Lemma 7];
   - the non-uniform Łojasiewicz inequality [MXSS20, Lemma 8];
   - asymptotic convergence [AKLM21, Theorem 5.1]: for μ of full support and step at most
     $(1-\gamma)^3/8$, $V^{(t)}(s)\to V^*(s)$ for every $s$.
   
   Assume that every state has a unique optimal action $a^*(s)$. Prove:
   - $c=\inf_{t,s}\pi_t(a^*(s)|s)>0$ [MXSS20, Lemma 9];
   - with step $(1-\gamma)^3/8$, for $t\ge1$,
     $V^*(\rho)-V^{\pi_t}(\rho)\le16S\|d^{\pi^*}_\mu/\mu\|^2_\infty\|1/\mu\|_\infty/(c^2(1-\gamma)^6t)$
     [MXSS20, Theorem 4];
   - the eventual lower bound [MXSS20, Theorem 10];
   - the bandit case [MXSS20, Theorems 3, 9].
4. **Log-barrier regularization** [AKLM21, Theorem 5.2, Corollary 5.1], corrected.
   - The objective is $L_\lambda(\theta)=V^{\pi_\theta}(\mu)+\frac\lambda{SA}\sum_{s,a}\log\pi_\theta(a|s)$.
   - If $\|\nabla L_\lambda(\theta)\|\le\lambda/(2SA)$, then
     $V^*(\rho)-V^{\pi_\theta}(\rho)\le2\lambda\|d^{\pi^*}_\rho/\mu\|_\infty/(1-\gamma)$.
   - With $\theta_0=0$, $\varepsilon\le1/(1-\gamma)$,
     $\lambda=\varepsilon(1-\gamma)/(2\|d^{\pi^*}_\rho/\mu\|_\infty)$, step $1/\beta_\lambda$ and
     $\beta_\lambda=8/(1-\gamma)^3+2\lambda/S$, gradient ascent has
     $\min_{t<T}V^*(\rho)-V^{(t)}(\rho)\le\varepsilon$ once
     $T\ge320S^2A^2\|d^{\pi^*}_\rho/\mu\|^2_\infty/((1-\gamma)^6\varepsilon^2)$.
   - The source prints $\beta_\lambda=8\gamma/(1-\gamma)^3+2\lambda/S$, which its Lemma D.4
     contradicts at γ = 0.
5. **Natural policy gradient** [AKLM21, Lemma 5.1, Theorem 5.3].
   - Define NPG by its policy form: $\pi_0$ uniform and
     $\pi_{t+1}(a|s)\propto\pi_t(a|s)\exp(\eta A^{\pi_t}(s,a)/(1-\gamma))$. On the states reachable
     from ρ, it is the softmax update with the Fisher pseudo-inverse.
   - For any step $\eta>0$ and $T\ge1$:
     $V^{(T)}(\rho)\ge V^*(\rho)-\log A/(\eta T)-1/((1-\gamma)^2T)$.
6. **Policy mirror descent.**
   - [Xiao22, Theorems 8, 10]. For a Legendre mirror map on the simplex in every state (Bandits
     roadmap, Layer 6) and $D^*_0=\sum_sd_\rho(\pi^*)(s)D(\pi^*_s,\pi^{(0)}_s)$:
     - with a constant step η,
       $V^*_\rho-V_\rho(\pi^{(k)})\le\frac1{k+1}\big(\frac{D_0^*}{\eta(1-\gamma)}+\frac1{(1-\gamma)^2}\big)$;
     - if $\pi^{(0)}$ lies in the relative interior and $\eta_{k+1}\ge\eta_k\vartheta_\rho/(\vartheta_\rho-1)$
       with $\vartheta_\rho=\|d_\rho(\pi^*)/\rho\|_\infty/(1-\gamma)$, then
       $V^*_\rho-V_\rho(\pi^{(k)})\le(1-1/\vartheta_\rho)^k\big(V^*_\rho-V_\rho(\pi^{(0)})+D^*_0/(\eta_0\gamma)\big)$.
   - [JPR23, Theorems 4.1, 4.2]. With steps
     $\eta_k\ge c_k^{-1}\max_s\min_{p\in\Delta(\arg\max Q^k(s,\cdot))}D(p,\pi^k_s)$:
     $\|v^*-v^k\|\le\gamma^k\big(\|v^*-v^0\|+\sum_{i=1}^k\gamma^{-i}c_{i-1}\big)$. For every $n$ there
     are MDPs with $2n+1$ states and an initial policy on which every positive step sequence gives
     $\|v^*-v^k\|\ge\frac12\gamma^k\|v^*-v^0\|$ for $k<n$.
7. **Entropy-regularized natural policy gradient** [CCCWC22, Theorems 1, 2].
   - Let τ > 0. Define the entropy $\mathcal H(\rho,\pi)=(1-\gamma)^{-1}\mathbb E_{d^\pi_\rho}\sum_a\pi\log(1/\pi)$,
     the soft value $V^\pi_\tau=V^\pi+\tau\mathcal H(\rho,\pi)$ and the soft Bellman operator.
   - Prove that the soft Bellman operator is a γ-contraction whose fixed point $Q^*_\tau$ gives the
     soft-optimal policy $\pi^*_\tau\propto\exp(Q^*_\tau/\tau)$.
   - Define the update $\pi^{(t+1)}\propto(\pi^{(t)})^{1-\eta\tau/(1-\gamma)}\exp(\eta Q^{(t)}_\tau/(1-\gamma))$,
     from $\pi^{(0)}>0$.
   - For $0<\eta\le(1-\gamma)/\tau$ and
     $C_1=\|Q^*_\tau-Q^{(0)}_\tau\|+2\tau(1-\eta\tau/(1-\gamma))\|\log\pi^*_\tau-\log\pi^{(0)}\|$, prove
     $\|Q^*_\tau-Q^{(t+1)}_\tau\|\le C_1\gamma(1-\eta\tau)^t$ and
     $\|\log\pi^*_\tau-\log\pi^{(t+1)}\|\le2C_1\tau^{-1}(1-\eta\tau)^t$.
   - With soft Q-values estimated within δ and $C_2=(2\delta/(1-\gamma))(1+\gamma/(\eta\tau))$, prove
     the bounds $\gamma((1-\eta\tau)^tC_1+C_2)$ and $2\tau^{-1}((1-\eta\tau)^tC_1+C_2)$.
8. **Conservative policy iteration** [AJKS, §14.1, Theorems 14.2–14.4]. For $\gamma\in[1/5,1)$:
   - CPI mixes $\pi_{t+1}=(1-\alpha)\pi_t+\alpha\pi'_t$, where $\pi'_t$ is returned by an
     ε-greedy oracle over a policy class Π;
   - $\mathbb A_t=\mathbb E_{s\sim d^{\pi_t}_\mu}A^{\pi_t}(s,\pi'_t(s))$, and $\varepsilon_\Pi$ is
     the class approximation error of the source.
   
   Prove:
   - $V^{\pi_{t+1}}_\mu-V^{\pi_t}_\mu\ge\frac\alpha{1-\gamma}(\mathbb A_t-\frac{2\alpha\gamma}{(1-\gamma)^2})$
     for $\alpha\in[0,1]$;
   - $\alpha=\mathbb A_t(1-\gamma)^2/(4\gamma)$ gives improvement $\mathbb A_t^2(1-\gamma)/(8\gamma)$;
   - CPI stops ($\mathbb A_t\le\varepsilon$) within $8\gamma/(\varepsilon^2(1-\gamma)^2)$ iterations.
     The source prints $8\gamma/\varepsilon^2$;
   - the output satisfies $V^*-V^\pi\le(2\varepsilon+\varepsilon_\Pi)(1-\gamma)^{-2}\|d^{\pi^*}/\mu\|_\infty$.

Completion checks: for a one-state MDP, NPG is the exponential-weights (Hedge) update with step
$\eta/(1-\gamma)$; soft policy iteration is the case $\eta=(1-\gamma)/\tau$ of item 7.

## Layer 18: Online episodic exploration

Episodic MDPs with stage-dependent transitions, initial law μ and $K$ episodes. Regret is that of
Layer 14.7. Each item takes the reward model of its source:
- in items 1–4, rewards are deterministic in $[0,1]$ and known to the learner (`M.HasRewardFn r`),
  and algorithms are algorithms in `statesEnv` (Layer 7.7);
- in items 5–6, rewards are stochastic and unknown, and algorithms are algorithms in `episodeEnv`
  (Layer 7.7), which observe them.

1. **UCBVI** [AJKS, Theorem 7.1], corrected.
   - Define the algorithm: value iteration on the empirical kernel with bonus
     $2H\sqrt{L/\max(1,N^k_h(s,a))}$, $L=\log(SAH^2K^2)$, and values clipped at $H$.
   - Prove that its expected regret is at most $20H^2S\sqrt{AKL}+2$. The $+2$ comes from failure
     probability $1/(KH)$. The source prints the constant 10, but the last line of the proof of its
     Lemma 7.5 drops a factor 2.
2. **Refined analysis** [AJKS, Theorem 7.6], corrected. Prove the expected regret bound
   $8eH^2\sqrt{SAKL}+2eH^3S^2A(2+\log K)L+2$, with the per-entry Bernstein bound proved through the
   stream model of Layer 14.2. The source omits the $+2$ and bounds the harmonic sum by $\log K$.
3. **Optimistic Q-learning** [JABJ18, Theorem 1].
   - Define UCB-H: $Q$ initialized at $H$, learning rates $(H+1)/(H+t)$, bonuses $c\sqrt{H^3\iota/t}$,
     and $V_h=\min\{H,\max_aQ_h\}$, with $\iota=\log(SAKH/p)$.
   - Prove: there are $c,C>0$ such that, with probability at least $1-p$, the regret is at most
     $C\sqrt{H^5SAK\iota}$.
4. **Minimax lower bound** [DMKV21, Theorem 9]. Let $S\ge6$, $A\ge2$, $S=3+(A^d-1)/(A-1)$ for an
   integer $d$, $H\ge3d$ and $K\ge HSA$. Prove that every algorithm has, on some episodic MDP with
   these sizes and a Dirac initial law, expected regret at least $\sqrt{H^3SAK}/(48\sqrt6)$.
   Prove it for algorithms in `statesEnv` and in `episodeEnv`: the hard MDPs have deterministic
   rewards, so the rewards observed in `episodeEnv` are functions of the states and actions.
5. **Horizon-free regret** [ZJD21, Theorem 1].
   - Setting: stationary transitions and rewards, pooled counts, and nonnegative stochastic
     rewards whose sum over the $H$ steps of an episode is at most $1$ almost surely under every
     policy.
   - Define MVP [ZJD21, Algorithm 1]: empirical rewards and kernels updated at the source's
     triggers, bonus constants $c_1=460/9$, $c_2=2\sqrt2$ and $c_3=544/9$, and $Q$ initialized and
     clipped at 1.
   - Prove: there is $C>0$ such that, with probability at least $1-\delta$,
     $\mathrm{Regret}(K)\le C(\sqrt{SAK\ell\iota}+S^2A\ell\iota)$, with $\ell=\log_2(KH)+2$ and
     $\iota=\log(24S^2AH\ell^2/\delta)$.
   - Prove the ingredients:
     - the monotone bonus lemma [ZJD21, Lemma 14];
     - the higher-moment recursion [ZJD21, Lemma 2];
     - the bound $SA(\log_2(KH)+1)$ on the number of update epochs.
   - The empirical Bernstein inequality of Layer 3.2 replaces Maurer and Pontil's in the source's
     Lemma 12, for the transition event (8) and the reward event (9):
     $\sqrt{2\hat Vx/n}+3x/n\le2\sqrt{\hat V\iota/n}+14\iota/(3n)$ for $x=\log(3/\delta')$,
     $\iota=\log(2/\delta')$ and $\delta'\le9/10$. For the rewards, the biased sample variance is
     at most the empirical mean.
6. **Settling the minimax regret** [ZCLD24, Theorem 1].
   - Setting: nonnegative stochastic rewards whose sum over the $H$ steps of an episode is at most
     $H$ almost surely under every policy [ZCLD24, Assumption 1], which contains rewards per step
     in $[0,1]$.
   - Define [ZCLD24, Algorithm 1], with its empirical rewards and kernels, $c_1=460/9$,
     $c_2=2\sqrt2$, $c_3=544/9$ and $\delta'=\delta/(200SAH^2K^2)$.
   - Prove the profile union bound [ZCLD24, Lemma 5] for $K\ge SAH\log_2K$.
   - Prove: there is $C>0$ such that, for $K\ge2$ a power of two and $\delta\in(0,1)$, with
     probability at least $1-\delta$, $\mathrm{Regret}(K)\le C\min\{\sqrt{B\,SAH^3K},HK\}$, with
     $B=4000(\log_2K)^3\log(3SAH)\log(1/\delta')$.
   - Layer 3.2 replaces Maurer–Pontil in [ZCLD24, Lemma 19]; the constant $C$ absorbs the change.
   - Together with item 4, this settles the minimax regret up to logarithmic factors.

Completion checks: with $H=1$, items 1–3 specialize to contextual bandits with the initial law as
the context distribution; the smallest instance admitted by item 4 has $A=2$, $d=2$, $S=6$ and
$H\ge6$.

## Layer 19: Reward-free exploration and best policy identification

1. **Problems.**
   - A best policy identification algorithm is an LML identification algorithm (`IdentAlg`) in
     `statesEnv` with an $H$-step policy as output (entropy-mdp's `BPIAlg`). Its stopping time τ
     counts episodes. It is $(\varepsilon,\delta)$-PAC if the output is ε-optimal with probability
     at least $1-\delta$ on every MDP.
   - A reward-free exploration algorithm is an identification algorithm in `statesEnv` whose output
     is a stage-dependent kernel $(\hat P_h)_{h<H}$. It is $(\varepsilon,\delta)$-PAC if, with
     probability at least $1-\delta$: for every deterministic reward $r:\mathrm{Fin}\,H\to\mathcal
     S\to\mathcal A\to[0,1]$, every optimal policy of $(\hat P,r)$ is ε-optimal for $(P,r)$.
2. **RF-Express** [MDJKLV21, Theorem 1]. With a Dirac initial law, as in the source:
   - Define the algorithm with the threshold $\beta(n,\delta)=\log(3SAH/\delta)+S\log(8e(n+1))$.
   - Prove its tools:
     - counts versus pseudo-counts, $n\ge\bar n/2-\log(3SAH/\delta)$;
     - the KL-to-Bernstein transport: if $\mathrm{KL}(p,q)\le\alpha$ and $f\in[0,b]$, then
       $|pf-qf|\le\sqrt{2\mathrm{Var}_q(f)\alpha}+\frac23b\alpha$;
     - the variance transfers [MDJKLV21, Lemmas 10–12];
     - $\sum_tu_{t+1}/\max(1,U_t)\le4\log(U_{T+1}+1)$ [MDJKLV21, Lemma 9];
     - the inversion of the implicit inequality on τ [MDJKLV21, Lemma 13].
   - Prove, for $\varepsilon\in(0,1]$: it is $(\varepsilon,\delta)$-PAC, and with probability at
     least $1-\delta$ its number of episodes is at most
     $\frac{H^3SA}{\varepsilon^2}\big(\log\frac{3SAH}\delta+S\big)C_1+1$, with
     $C_1=5587e^6\log^2\big(e^{18}(\log(3SAH/\delta)+S)H^3SA/\varepsilon\big)$.
3. **Lower bounds.**
   - Best policy identification [DMKV21, Theorem 7]. Let $S\ge6$, $A\ge2$, $S=3+(A^d-1)/(A-1)$,
     $H\ge3d$, $H\ge4$, $\varepsilon\le H/24$ and $\delta\le1/16$. Every $(\varepsilon,\delta)$-PAC
     algorithm has, on some MDP with a Dirac initial law,
     $\mathbb E[\tau]\ge\frac1{3456}\frac{H^3SA}{\varepsilon^2}\log\frac1\delta$.
   - Reward-free exploration [JKSY20, Theorem 4.1]: there are $C,c>0$ such that, for $A\ge2$,
     $S\ge C\log_2A$, $H\ge C\log_2S$, $\varepsilon\le\min\{1/4,H/48\}$ and $\delta\le1/2$, every
     $(\varepsilon,\delta)$-PAC reward-free algorithm has $\mathbb E[\tau]\ge cS^2AH^2/\varepsilon^2$
     on some MDP.

Completion checks: for $H=1$ best policy identification is ε-best-arm identification for every
context; the threshold β of RF-Express follows from Layer 3.4 and a union bound.

## Layer 20: Adversarial MDPs

Episodic MDPs with known horizon and unknown fixed stage-dependent transitions. This layer uses
losses $\ell_k:\mathrm{Fin}\,H\to\mathcal S\times\mathcal A\to[0,1]$, chosen as an oblivious
sequence, as in the Bandits roadmap.

- The environment is LML's `obliviousEnv` whose round-$k$ kernel maps an $H$-step policy to the law
  of the state sequence together with $\ell_k$ (full information), or together with the losses
  $\ell_{k,h}(S_h,A_h)$ along the trajectory (bandit feedback).
- The regret against the best Markov policy is $\max_\pi\sum_{k<K}\langle q_k-q^\pi,\ell_k\rangle$.
  Here $q^\pi$ is the episodic occupancy measure of Layer 11.4, and $q_k$ the occupancy measure of
  the law of the policy played in episode $k$ given the past.

The sources state these bounds for loop-free layered MDPs with singleton first and last layers.
Translate once:
- $X_0=\{x_0\}$, with $P(\cdot|x_0,a)=\mu$ and zero loss;
- $X_{h+1}=\{h\}\times\mathcal S$ for $h<H$;
- $X_{H+1}=\{x_{\mathrm{end}}\}$;
- so $L=H+1$ and $|X|=HS+2$.

1. **Known transitions.**
   - Define online mirror descent over the occupancy polytope with the unnormalized KL, started at
     the occupancy measure of maximal entropy.
   - Prove, with step η, that its regret is at most $(H\log(SA)+\log A)/\eta+\eta HK/2$. Derive it
     from the Bandits roadmap's Layer 6 bound:
     - the starting point is the KL projection of the uniform measure, so the Bregman divergence to
       any occupancy measure is at most $\sum_{\text{layers}}\log(|X_h|A)$;
     - the local-norm term of round $k$ is at most $\frac\eta2\langle q_k,\ell_k^2\rangle\le\eta H/2$.
2. **Unknown transitions, full information** [RM19, Lemma 3.1, Theorem 5.1].
   - Define the objects:
     - occupancy measures on $X\times A\times X$;
     - the kernel $P^q$ induced by $q$;
     - the confidence polytopes $\Delta(\mathcal P_i)$.
   - Prove that UC-O-REPS has, with probability at least $1-2\delta$, regret at most
     $15L|X|\sqrt{KA\log(K|X|A/\delta)}$.
3. **Unknown transitions, bandit feedback** [JJLSY20, Theorem 3].
   - Define the upper occupancy bound $u_k=\max_{\hat P\in\mathcal P_i}q^{\hat P,\pi_k}$, its
     computation [JJLSY20, Algorithm 3], and the estimator $\ell\mathbf 1/(u_k+\gamma)$. Its
     high-probability lemma follows the Bandits roadmap's Layer 7 implicit exploration.
   - Prove: there is $C>0$ such that UOB-REPS with $\eta=\gamma=\sqrt{L\log(L|X|A/\delta)/(K|X|A)}$
     has, with probability at least $1-9\delta$, regret at most $C\,L|X|\sqrt{AK\log(K|X|A/\delta)}$.
   - Layer 3.2 replaces Maurer–Pontil in the confidence sets [JJLSY20, (5)–(6)].

Completion checks: for $H=1$ and one state, item 1 is exponential weights and item 3 is Exp3-IX.

## Layer 21: Average-reward learning

1. **UCRL2** [JOA10, Theorem 2].
   - For a communicating MDP with $S\ge2$, diameter $D$ and stochastic rewards in $[0,1]$, unknown
     to the learner, define UCRL2 [JOA10, Figure 1] in `M.env μ`, with the source's confidence
     intervals for the mean rewards and the $\ell^1$-balls for the transition kernels around the
     empirical estimates of Layer 14.1. The regret after $n$ rounds is the random variable
     $n\rho^*-\sum_{t<n}Y_t$ of the realized rewards, as in the source (Layer 13.3).
   - Extended value iteration is value iteration on the MDP whose actions at $s$ are pairs of an
     action and a kernel in the $\ell^1$-ball, with the upper confidence bound of the mean reward.
     Prove:
     - its reduction to the extreme points found by sorting [JOA10, §3.1.2];
     - its convergence and the aperiodicity of its policies [JOA10, Theorem 7];
     - the span bound $\mathrm{sp}(u_i)\le D$ for its iterates [JOA10, (11)].
   - Prove that, with probability at least $1-\delta$, for every $T>1$, the regret is at most
     $34DS\sqrt{AT\log(T/\delta)}$. The confidence events for the rewards and the transitions
     come from the stream model of Layer 14.2 with Hoeffding's inequality and Layer 3.3, and the
     deviation of $\sum_tY_t$ from $\sum_tr(S_t,A_t)$ from Azuma–Hoeffding.
2. **Lower bound** [JOA10, Theorem 5]. For $S,A\ge10$, $D\ge20\log_AS$, $D\ge12$ and $T\ge DSA$,
   prove that every algorithm has, on some MDP with diameter at most $D$, expected regret at least
   $0.015\sqrt{DSAT}$. Use the change of measure of Layer 14.6.
3. **Generative model** [ZC24, Theorems 1, 2]. For a weakly communicating MDP with
   $\mathrm{sp}(h^*)\le\mathsf H$ and deterministic rewards in $[0,1]$:
   - Theorem 1: for a γ-discounted MDP with $\mathsf H\le1/(1-\gamma)$ and $\varepsilon\le\mathsf H$,
     there is $C>0$ such that $N\ge C\mathsf H/((1-\gamma)^2\varepsilon^2)\log(SA/((1-\gamma)\delta\varepsilon))$
     samples per pair give, with probability at least $1-\delta$, $\|v^*_\gamma-v^{\hat\pi}_\gamma\|\le\varepsilon$.
     Here $\hat\pi$ is the optimal policy of the empirical MDP with rewards perturbed as in
     Layer 15.4 (c), with level $\xi=(1-\gamma)\varepsilon/6$.
   - Theorem 2: there is $C>0$ such that, for $\varepsilon,\delta\in(0,1)$ and
     $N\ge C(\mathsf H/\varepsilon^2)\log(SA\mathsf H/(\delta\varepsilon))$, the reduction with
     $\gamma=1-\varepsilon/(12\mathsf H)$ and discounted accuracy $\mathsf H$ returns, with
     probability at least $1-\delta$, a policy with $\rho^*-\rho^{\hat\pi}\le\varepsilon$.
   - The probability is over `streamMeasure M.P` and the perturbation. The proofs go through
     Layers 13.5, 13.8 and 15.

Completion check: the diameter of a deterministic cycle of length $S$ is $S-1$.

## Layer 22: Offline reinforcement learning

1. **Data.** Each item fixes one of these data measures:
   - $n$ i.i.d. tuples $(s,a,y,s')$: `Measure.pi` of $\nu\otimes_m(R\times P)$, with $(s,a)\sim\nu$,
     reward $y\sim R(s,a)$ and next state $s'\sim P(s,a)$;
   - a compliant dataset [JYW21, Definition 2.1] of $K$ episodes of the episodic MDP. For every
     step $h$ and episode τ, given the state–action pairs of step $h$ of episodes $j\le\tau$ and the
     rewards and next states of step $h$ of episodes $j<\tau$, the pair $(r^\tau_h,x^\tau_{h+1})$ has
     conditional law $R_h\otimes P_h$ at $(x^\tau_h,a^\tau_h)$.
   
   Rewards are observed in the data here; they are not known.
2. **Concentrability and fitted Q-iteration** [AJKS, Assumptions 4.1–4.2, Lemma 4.4, Theorem 4.3].
   - Define the concentrability coefficient $C_{\mathrm{conc}}$ as the supremum over nonstationary
     policies of $\|d/\nu\|_\infty$, with $d$ the occupancy measures of Layer 11.1 (in `ℝ≥0∞`).
     Define the inherent Bellman error $\varepsilon_{\mathrm{approx}}$ of a finite function class
     $\mathcal F$.
   - Prove the error propagation of [AJKS, Lemma 4.4].
   - Prove the fitted Q-iteration guarantee from Layer 3.6 with $B=1/(1-\gamma)$: there is $C>0$
     such that, with probability at least $1-\delta$,
     $V^*(\mu)-V^{\pi_K}(\mu)\le(1-\gamma)^{-2}\big(\sqrt{C\,C_{\mathrm{conc}}\log(|\mathcal F|^2K/\delta)/((1-\gamma)^2n)}+\sqrt{C\,C_{\mathrm{conc}}\,\varepsilon_{\mathrm{approx}}}\big)+\gamma^K/(1-\gamma)^2$.
3. **Pessimism** [JYW21, Definition 4.1, Theorem 4.2]. On measurable `𝓢`:
   - Define a ξ-uncertainty quantifier: functions $\Gamma_h$ such that, with probability at least
     $1-\xi$, $|\hat B_h\hat V_{h+1}-B_h\hat V_{h+1}|\le\Gamma_h$ for all $h$.
   - Define pessimistic value iteration as in Layer 12.2.
   - Prove that on the event of the quantifier,
     $V^*_0(s)-V^{\hat\pi}_0(s)\le2\sum_h\mathbb E^{\pi^*}_s[\Gamma_h(S_h,A_h)]$.
4. **Offline bandits** [RZMJR21, eq. (9), Theorem 2]. For $A\ge2$ arms and i.i.d. data
   $a_i\sim\mu$, $r_i\sim R(a_i)$ in $[0,1]$:
   - Define the lower confidence bound algorithm, with
     $b(a)=\sqrt{\log(2A/\delta)/(2N(a))}$, and $\hat r(a)=0$, $b(a)=1$ when $N(a)=0$.
   - Prove: if $N\ge8C^*\log(1/\delta)$, then with probability at least $1-2\delta$,
     $r(a^*)-r(\hat a)\le\min(1,2\sqrt{C^*\log(2A/\delta)/N})$.
   - Prove the matching lower bound for $C^*\ge2$ in "∃ c" form.
5. **Model-based offline RL** [LSCCW24, Theorems 5, 2]. Rewards are known and deterministic, and the
   data are the transitions of item 1.
   - Define the clipped concentrability
     $C^*_{\mathrm{clipped}}=\max_{s,a}\min\{d^*(s,a),1/S\}/d^b(s,a)$.
   - Define VI-LCB with the penalty
     $b(s,a;V)=\min\{\max\{\sqrt{c_b\log(N/((1-\gamma)\delta))\mathrm{Var}_{\hat P}(V)/N(s,a)},\ 2c_b\log(N/((1-\gamma)\delta))/((1-\gamma)N(s,a))\},\ 1/(1-\gamma)\}+5/N$.
     Prove that the pessimistic operator is a γ-contraction.
   - Theorem 5: for $\gamma\in[1/2,1)$, $c_b\ge144$ and any $\hat Q$ within $1/N$ of the
     pessimistic fixed point, with probability at least $1-2\delta$,
     $V^*(\rho)-V^{\hat\pi}(\rho)\le120\sqrt{\frac{c_bSC^*_{\mathrm{clipped}}L}{(1-\gamma)^3N}}+\frac{3464c_bSC^*_{\mathrm{clipped}}L}{(1-\gamma)^2N}$,
     with $L=\log(NS/((1-\gamma)\delta))$.
   - Theorem 2, the lower bound: for $\gamma\ge2/3$, $S\ge2$, $C^*_{\mathrm{clipped}}\ge8\gamma/S$ and
     $\varepsilon\le1/(42(1-\gamma))$, every estimator errs by more than ε with probability at
     least $1/8$ when $N\le SC^*_{\mathrm{clipped}}/(25088(1-\gamma)^3\varepsilon^2)$.

Completion check: with full coverage ($\nu$ uniform), $C_{\mathrm{conc}}\le SA$.

## Layer 23: Linear function approximation

Features $\varphi:\mathcal S\times\mathcal A\to E$ in a finite-dimensional real inner product space
of dimension $d$, with $\|\varphi\|\le1$.

1. **Models.**
   - Linear Bellman completeness [AJKS, Definition 3.1].
   - Linear MDPs [JYWJ20, Assumption A]: $P_h(\cdot|s,a)=\langle\varphi(s,a),\mu_h(\cdot)\rangle$
     and $r_h=\langle\varphi,\theta_h\rangle$, with $\|\theta_h\|\le\sqrt d$ and
     $\||\mu_h|(\mathcal S)\|\le\sqrt d$. The source bounds the signed masses; the total-variation
     normalization is the one its proof needs.
   - Linear mixture MDPs [ZGS21, §3]: $P_h(s'|s,a)=\langle\phi(s'|s,a),\theta_h\rangle$ with
     $\|\theta_h\|\le B$ and $\|\sum_{s'}\phi(s'|s,a)V(s')\|\le1$ for $V:\mathcal S\to[0,1]$.
2. **Least-squares value iteration with a D-optimal design** [AJKS, Theorem 3.3], corrected.
   - Setting: linear Bellman completeness with the episodic generative model, $\varepsilon\in(0,1)$,
     $N=\lceil64H^6d^2\log(H/\delta)/\varepsilon^2\rceil$, and $\lceil\rho(s,a)N\rceil$ samples at
     each support point $(s,a)$ of the Kiefer–Wolfowitz design ρ (Bandits roadmap, Layer 8.6) at
     every step.
   - Prove that with probability at least $1-\delta$ the output policy is ε-optimal from μ.
   - The source prints $\log(1/\delta)$; its union bound over steps needs $\log(H/\delta)$.
3. **LSVI-UCB** [JYWJ20, Theorem 3.1]. `𝓢` is finite here because algorithms act in `statesEnv`.
   - Prove the uniform self-normalized bound over the class of clipped linear value functions, with
     an ε-net (Layer 3.5) [JYWJ20, Lemmas D.4–D.6].
   - Prove: there are $c,C>0$ such that, with $\lambda=1$, $\beta=c\,dH\sqrt\iota$ and
     $\iota=\log(2dKH/p)$, with probability at least $1-p$,
     $\mathrm{Regret}(K)\le C\sqrt{d^3H^4K\iota^2}$.
4. **Pessimism for linear MDPs** [JYW21, Theorem 4.4]. On measurable `𝓢`, prove: there are $c>0$
   and $\zeta=\log(2dHK/\xi)$ such that, with $\beta=c\,dH\sqrt\zeta$, the penalty
   $\beta\|\varphi\|_{\Lambda_h^{-1}}$ is a ξ-uncertainty quantifier (Layer 22.3). Hence
   $V^*_0-V^{\hat\pi}_0\le2\beta\sum_h\mathbb E^{\pi^*}[\|\varphi(S_h,A_h)\|_{\Lambda_h^{-1}}]$.
5. **Linear mixture MDPs** [ZGS21].
   - Theorem 4.1, the Bernstein self-normalized bound. Hypotheses:
     - $y_t=\langle\mu^*,x_t\rangle+\eta_t$, with $x_t$ $\mathcal G_t$-measurable and $\eta_t$
       $\mathcal G_{t+1}$-measurable;
     - $|\eta_t|\le R$, $\mathbb E[\eta_t|\mathcal G_t]=0$ and $\mathbb E[\eta_t^2|\mathcal G_t]\le\sigma^2$;
     - $\|x_t\|\le L$ and $Z_t=\lambda I+\sum_{i\le t}x_ix_i^\top$.
     
     Prove that with probability at least $1-\delta$, for all $t$:
     $\|\sum_{i\le t}x_i\eta_i\|_{Z_t^{-1}}\le\beta_t=8\sigma\sqrt{d\log(1+tL^2/(d\lambda))\log(4t^2/\delta)}+4R\log(4t^2/\delta)$.
     Deduce the corollary $\|\hat\mu_t-\mu^*\|_{Z_t}\le\beta_t+\sqrt\lambda\|\mu^*\|$. Place it next to
     the Bandits roadmap's Layer 8 self-normalized bound.
   - Theorem 5.6, the lower bound: for $B>1$, $d\ge4$, $H\ge3$ and
     $K\ge\max\{(d-1)^2H/2,(d-1)/(32H(B-1))\}$, prove: there is $c>0$ such that every algorithm
     has, on some linear mixture MDP, expected regret at least $c\,dH\sqrt{KH}$.

Completion check: tabular MDPs are linear MDPs with $d=SA$ and indicator features.
## Completion checks

Every new definition comes with measurability, evaluation and extensionality lemmas. Every algorithm
comes with its run lemma, the conditional law of its action given the history, so that the
theorems apply to all runs. Check in particular:
- The optimality equations of Layers 8, 9 and 13 agree:
  - for $\gamma<1$, the finite-horizon values $T^Nu$ of Layer 8.2 converge to $v^*_\gamma$ as
    $N\to\infty$, uniformly and for every terminal value $u$;
  - $(1-\gamma)v^*_\gamma\to g^*$ for unichain models.
- The pointwise statements of Layers 9–10 are corollaries of the statements on
  `boundedMeasurable 𝓢`, and the countable-action statements of Layer 9.4 specialize to the finite
  ones of Layer 9.5.
- The lower bound of Layer 18.4, for algorithms in `episodeEnv`, matches the upper bound of
  Layer 18.6 up to logarithmic factors.
- Layer 19.3's best policy identification bound and Layer 19.2 differ by a factor $S$ and
  logarithmic factors; Layer 21.2 and Layer 21.1 differ by $\sqrt{DS}$ and logarithmic factors.
- A one-state MDP turns Layers 15, 17 and 18 into the corresponding bandit statements, and these
  agree with the Bandits roadmap.
- Layers 1 and 2 restricted to countable state spaces agree with the definitions of Tau Ceti's
  MarkovChainsAndRenewal roadmap where both exist.

Compilation of the suggested signatures checks their types, not the truth of their admitted
theorems or the completion of these milestones.

## References

Books and monographs:
- [P] M. L. Puterman, *Markov Decision Processes: Discrete Stochastic Dynamic Programming*, Wiley
  (1994).
- [AJKS] A. Agarwal, N. Jiang, S. M. Kakade and W. Sun, *Reinforcement Learning: Theory and
  Algorithms*, version of 31 January 2022, rltheorybook.github.io.
- [LS] T. Lattimore and Cs. Szepesvári, *Bandit Algorithms*, Cambridge University Press (2020).
- [Ber12] D. P. Bertsekas, *Dynamic Programming and Optimal Control*, Vol. II, 4th ed., Athena
  Scientific (2012).
- [Ber22] D. P. Bertsekas, *Abstract Dynamic Programming*, 3rd ed., Athena Scientific (2022).
- [BLM13] S. Boucheron, G. Lugosi and P. Massart, *Concentration Inequalities*, Oxford University
  Press (2013).
- [CT06] T. M. Cover and J. A. Thomas, *Elements of Information Theory*, 2nd ed., Wiley (2006).
- [Kal21] O. Kallenberg, *Foundations of Modern Probability*, 3rd ed., Springer (2021).
- [Kre85] U. Krengel, *Ergodic Theorems*, de Gruyter (1985).
- [KY03] H. J. Kushner and G. G. Yin, *Stochastic Approximation and Recursive Algorithms and
  Applications*, 2nd ed., Springer (2003).
- [LPW17] D. A. Levin, Y. Peres and E. L. Wilmer, *Markov Chains and Mixing Times*, 2nd ed., AMS
  (2017).
- [MT09] S. Meyn and R. L. Tweedie, *Markov Chains and Stochastic Stability*, 2nd ed., Cambridge
  University Press (2009).
- [Nes18] Y. Nesterov, *Lectures on Convex Optimization*, 2nd ed., Springer (2018).
- [Nor97] J. R. Norris, *Markov Chains*, Cambridge University Press (1997).
- [Ora23] F. Orabona, *A Modern Introduction to Online Learning*, arXiv:1912.13213 (version 10).
- [Rev84] D. Revuz, *Markov Chains*, 2nd ed., North-Holland (1984).

Papers:
- [AGP21] A. Al Marjani, A. Garivier and A. Proutière, Navigating to the best policy in Markov
  decision processes, NeurIPS 2021, arXiv:2106.02847.
- [AKLM21] A. Agarwal, S. M. Kakade, J. D. Lee and G. Mahajan, On the theory of policy gradient
  methods: optimality, approximation, and distribution shift, *JMLR* 22 (2021), COLT 2020,
  arXiv:1908.00261.
- [AKY20] A. Agarwal, S. Kakade and L. F. Yang, Model-based reinforcement learning with a generative
  model is minimax optimal, COLT 2020, arXiv:1906.03804.
- [AMK13] M. G. Azar, R. Munos and H. J. Kappen, Minimax PAC bounds on the sample complexity of
  reinforcement learning with a generative model, *Machine Learning* 91 (2013).
- [AMS09] J.-Y. Audibert, R. Munos and Cs. Szepesvári, Exploration–exploitation tradeoff using
  variance estimates in multi-armed bandits, *Theoretical Computer Science* 410 (2009).
- [AOM17] M. G. Azar, I. Osband and R. Munos, Minimax regret bounds for reinforcement learning,
  ICML 2017, arXiv:1703.05449.
- [Bla65] D. Blackwell, Discounted dynamic programming, *Ann. Math. Statist.* 36 (1965).
- [BRS18] J. Bhandari, D. Russo and R. Singal, A finite time analysis of temporal difference learning
  with linear function approximation, COLT 2018, arXiv:1806.02450.
- [CCCWC22] S. Cen, C. Cheng, Y. Chen, Y. Wei and Y. Chi, Fast global convergence of natural policy
  gradient methods with entropy regularization, *Operations Research* 70 (2022), arXiv:2007.06558.
- [DMKV21] O. D. Domingues, P. Ménard, E. Kaufmann and M. Valko, Episodic reinforcement learning in
  finite MDPs: minimax lower bounds revisited, ALT 2021, arXiv:2010.03531.
- [Dob56] R. L. Dobrushin, Central limit theorem for nonstationary Markov chains, *Theory Probab.
  Appl.* 1 (1956).
- [EV26] A. Essakine and C. Vernade, Tight sample complexity bounds for entropic best policy
  identification, COLT 2026, arXiv:2605.13717.
- [Fre75] D. A. Freedman, On tail probabilities for martingales, *Ann. Probab.* 3 (1975).
- [GG04] S. Gaubert and J. Gunawardena, The Perron–Frobenius theorem for homogeneous, monotone
  functions, *Trans. AMS* 356 (2004).
- [GMS19] A. Garivier, P. Ménard and G. Stoltz, Explore first, exploit next: the true shape of
  regret in bandit problems, *Math. Oper. Res.* 44 (2019), arXiv:1602.07182.
- [HRMS20] S. R. Howard, A. Ramdas, J. McAuliffe and J. Sekhon, Time-uniform Chernoff bounds via
  nonnegative supermartingales, *Probab. Surveys* 17 (2020), arXiv:1808.03204.
- [JABJ18] C. Jin, Z. Allen-Zhu, S. Bubeck and M. I. Jordan, Is Q-learning provably efficient?,
  NeurIPS 2018, arXiv:1807.03765.
- [JJLSY20] C. Jin, T. Jin, H. Luo, S. Sra and T. Yu, Learning adversarial Markov decision processes
  with bandit feedback and unknown transition, ICML 2020, arXiv:1912.01192.
- [JKMDLV20] A. Jonsson, E. Kaufmann, P. Ménard, O. D. Domingues, E. Leurent and M. Valko, Planning
  in Markov decision processes with gap-dependent sample complexity, NeurIPS 2020,
  arXiv:2006.05879.
- [JKSY20] C. Jin, A. Krishnamurthy, M. Simchowitz and T. Yu, Reward-free exploration for
  reinforcement learning, ICML 2020, arXiv:2002.02794.
- [JOA10] T. Jaksch, R. Ortner and P. Auer, Near-optimal regret bounds for reinforcement learning,
  *JMLR* 11 (2010).
- [JPR23] E. Johnson, C. Pike-Burke and P. Rebeschini, Optimal convergence rate for exact policy
  mirror descent in discounted Markov decision processes, NeurIPS 2023, arXiv:2302.11381.
- [JS21] Y. Jin and A. Sidford, Towards tight bounds on the sample complexity of average-reward
  MDPs, ICML 2021, arXiv:2106.07046.
- [JYW21] Y. Jin, Z. Yang and Z. Wang, Is pessimism provably efficient for offline RL?, ICML 2021,
  arXiv:2012.15085.
- [JYWJ20] C. Jin, Z. Yang, Z. Wang and M. I. Jordan, Provably efficient reinforcement learning with
  linear function approximation, COLT 2020, arXiv:1907.05388.
- [KNS16] H. Karimi, J. Nutini and M. Schmidt, Linear convergence of gradient and proximal-gradient
  methods under the Polyak–Łojasiewicz condition, ECML PKDD 2016, arXiv:1608.04636.
- [Koh80] E. Kohlberg, Invariant half-lines of nonexpansive piecewise-linear transformations,
  *Math. Oper. Res.* 5 (1980).
- [KS02] M. Kearns and S. Singh, Near-optimal reinforcement learning in polynomial time, *Machine
  Learning* 49 (2002).
- [Lan23] G. Lan, Policy mirror descent for reinforcement learning: linear convergence, new sampling
  complexity, and generalized problem classes, *Math. Program.* 198 (2023), arXiv:2102.00135.
- [LCCWC24] G. Li, C. Cai, Y. Chen, Y. Wei and Y. Chi, Is Q-learning minimax optimal? A tight sample
  complexity analysis, *Operations Research* (2024), arXiv:2102.06548.
- [LSCCW24] G. Li, L. Shi, Y. Chen, Y. Chi and Y. Wei, Settling the sample complexity of model-based
  offline reinforcement learning, *Ann. Statist.* (2024), arXiv:2204.05275.
- [LWCGC24] G. Li, Y. Wei, Y. Chi, Y. Gu and Y. Chen, Breaking the sample size barrier in
  model-based reinforcement learning with a generative model, *Operations Research* (2024),
  NeurIPS 2020, arXiv:2005.12900.
- [MDJKLV21] P. Ménard, O. D. Domingues, A. Jonsson, E. Kaufmann, E. Leurent and M. Valko, Fast
  active learning for pure exploration in reinforcement learning, ICML 2021, arXiv:2007.13442.
- [MXSS20] J. Mei, C. Xiao, Cs. Szepesvári and D. Schuurmans, On the global convergence rates of
  softmax policy gradient methods, ICML 2020, arXiv:2005.06392.
- [OPT18] J. Ok, A. Proutière and D. Tranos, Exploration in structured reinforcement learning,
  NeurIPS 2018, arXiv:1806.00775.
- [RM19] A. Rosenberg and Y. Mansour, Online convex optimization in adversarial Markov decision
  processes, ICML 2019, arXiv:1905.07773.
- [RM51] H. Robbins and S. Monro, A stochastic approximation method, *Ann. Math. Statist.* 22
  (1951).
- [RS71] H. Robbins and D. Siegmund, A convergence theorem for non negative almost supermartingales
  and some applications, in *Optimizing Methods in Statistics*, Academic Press (1971).
- [RZMJR21] P. Rashidinejad, B. Zhu, C. Ma, J. Jiao and S. Russell, Bridging offline reinforcement
  learning and imitation learning: a tale of pessimism, NeurIPS 2021, arXiv:2103.12021.
- [Sob82] M. J. Sobel, The variance of discounted Markov decision processes, *J. Appl. Probab.* 19
  (1982).
- [Tsi94] J. N. Tsitsiklis, Asynchronous stochastic approximation and Q-learning, *Machine Learning*
  16 (1994).
- [TVR97] J. N. Tsitsiklis and B. Van Roy, An analysis of temporal-difference learning with function
  approximation, *IEEE Trans. Automat. Control* 42 (1997).
- [WOSVW03] T. Weissman, E. Ordentlich, G. Seroussi, S. Verdú and M. J. Weinberger, Inequalities for
  the L1 deviation of the empirical distribution, HP Labs technical report HPL-2003-97 (2003).
- [WJLSJ20] C.-Y. Wei, M. Jafarnia-Jahromi, H. Luo, H. Sharma and R. Jain, Model-free reinforcement
  learning in infinite-horizon average-reward Markov decision processes, ICML 2020,
  arXiv:1910.07072.
- [WWY22] J. Wang, M. Wang and L. F. Yang, Near sample-optimal reduction-based policy learning for
  average reward MDP, arXiv:2212.00603.
- [Xiao22] L. Xiao, On the convergence rates of policy gradient methods, *JMLR* 23 (2022),
  arXiv:2201.07443.
- [ZC24] M. Zurek and Y. Chen, Span-based optimal sample complexity for weakly communicating and
  general average reward MDPs, NeurIPS 2024, arXiv:2403.11477.
- [ZCLD24] Z. Zhang, Y. Chen, J. D. Lee and S. S. Du, Settling the sample complexity of online
  reinforcement learning, COLT 2024, arXiv:2307.13586.
- [Zha25] S. Zhang, Towards formalizing reinforcement learning theory: a Robbins–Siegmund approach,
  arXiv:2511.03618.
- [ZGS21] D. Zhou, Q. Gu and Cs. Szepesvári, Nearly minimax optimal reinforcement learning for
  linear mixture Markov decision processes, COLT 2021, arXiv:2012.08507.
- [ZJD21] Z. Zhang, X. Ji and S. S. Du, Is reinforcement learning more difficult than bandits? A
  near-optimal algorithm escaping the curse of horizon, COLT 2021, arXiv:2009.13503.
