- [Background](#org8ec0dee)
  - [Bootstrapping through resampling](#org870b009)
- [Initial Sample and Configuration](#org030ef81)
- [Statistical Algorithms](#orgb22024b)
- [Bootstrapping Confidence](#org4433656)
  - [Standard Interval](#org3731cd9)
  - [Percentile Interval](#orge8879d7)
  - [Bias-corrected Percentile Interval](#org96c6090)
  - [Accelerated Bias-corrected Percentile Interval](#orgbf9ea9a)

This is a **`J`** program which does some statistical analysis of computer benchmark results. This is also a collection of notes so that I may recall what I learned while writing this script.

I mostly wanted a way to know which changes I was making to `J` programs were actually effective ones. The built in time function `x 6!:2 y` which averages the time taken to run `y` `x` times was unsatisfactory for this purpose due to the performance characteristics of `J` programs which typically run slower on the first few trials and warm up a as they go. The consequence is for light programs `y` a large `x` is needed before the results converge. This averaging also hides variability and range of the performance of `y`.

The main method used is bootstrapping, which enables the estimation of statistical parameters on nonparametric samples. I got the sense of what to look for from haskell's [criterion](https://hackage.haskell.org/package/criterion) package, and learned the material for how to implement it through Efron and Hastie's textbook [Computer Age Statistical Inference](https://web.stanford.edu/~hastie/CASI/). See chapters 10 and 11 from there to get the original material.


<a id="org8ec0dee"></a>

# Background

We have a sample \(x = (x_i)\) of benchmark results, which we (slightly dubiously) assume iid from some unknown distribution. From that we compute various statistics on that sample from corresponding algorithms \(\hat\theta = s(x)\) in order to get an understanding of the results.

Some of these benchmarks will be expensive to run and in general it won't be possible to gather a large sample. To that end, the process of statistical bootsrapping allows us to extrapolate better estimates on the statistics through resampling uniformly from \(x\). Moreover, this process allows us to calculate standard errors on the statics as well as to attach confidence intervals to these computed statistics. And for our purposes, perhpas the most crucial aspect is that nothing need be assumed or known about the underlying distrubiton and that the computations are automatic.


<a id="org870b009"></a>

## Bootstrapping through resampling

A bootstrap resample of the original sample \(x\) is \(x^* = (x_i^*)\) where the \(x_i*\) are drawn uniformly from \(x\) and \(n=|x|=|x^*|\). This resampling is carried out \(B\) times, comprising the bootstrapped resample, allowing us to get a sample on the statistics \(\hat\theta^{*b}\) themselves on which we can compute errors and confidence intervals. To start, letting \(\hat\theta^{*\cdot}=\frac{\sum_b\hat\theta^{*b}}{B}\) be the man of the bootstrap resample, the bootstrap standard error can be calculated

\[\hat {\text{se}} = \sqrt{\frac {\sum_b \big(\hat\theta^{*b} - \hat\theta^{*\cdot}\big)^2}{B-1}}\]

Basically, the process is getting a sample \(x\) from some unknown distribution \(F\), and computing a statistic \(\hat\theta\) from it. Estimating \(\hat\theta\) by resampling \(x^*\) from the emperical distribution \(\hat F\) which assigns probability \(\frac{1}{n}\) to each \(x_i\) from \(x\) and calculating \(\hat\theta^*\). The key to this process is that \(\hat F \rightarrow F\) as \(n \rightarrow \infty\), and that for any \(n\), \(\hat F\) maximizes the probability of having observed \(x\) from \(F\), whatever \(F\) may actually be. In other words, \(\hat F\) is the nonparametric maximum likelihood estimator for \(F\).

The final step in the above process is akin to running another algorithm \(\text{Sd}(\hat F) = \hat{\text{se}}\) on the bootstrap resample and is called the <span class="underline">ideal bootstrap estimate</span> of the standard error. We can, however, do better inference and construct confidence intervals on the \(\hat\theta^*\).


<a id="org030ef81"></a>

# Initial Sample and Configuration

The basic configuration is the amount of time alloted for the initial benchmarks, the minimum number of runs, and the maximum number runs. Additional configuration includes the target coverage for confidence intervals and the number of bootstrap trials.

```j
bs_1rn  =: 1      NB. time alloted (upper bound on)
bs_n_lo =: 5      NB. minimum sample
bs_n_hi =: 1000   NB. maximum sample
bs_a    =: 0.1    NB. coverage
bs_B    =: 2000   NB. bootstrap resample
```

We gather an initial sample by first running the program once and estimate then estimate how many more times to sample it based on how long it took (`bs_1rn % 6!:2`):

```j
NB. monad taking prgram y to run a number of times based on configuration
dobench=: 6!:2"1@(# ,:)~ (bs_n_lo >. bs_n_hi <. [: <. bs_1rn % 6!:2)
NB. u is parameter, n is bootstrap B, y is sample
dobootstrap=: 2 : 'u"1 y {~ ? n # ,: $~ #y'
```


<a id="orgb22024b"></a>

# Statistical Algorithms

Many of these come from J's `stats/base` addon, but are included for fun and for completeness.

```j
mean   =: +/ % #         NB. is what it is
dev    =: -"_1 _ mean    NB. deviation from mean (of possibly vector valued sample)
ssdev  =: +/@:*:@:dev    NB. sum of squares of devation
var    =: ssdev % <:@#   NB. unbiased variance
stddev =: %:@var         NB. corrected sample standard deviation
```

These correspond in normal math notation to

\[\bar x = \sum_i \frac{x_i}{n}\] \[\text{Var} (x) = \frac{\sum_i (x_i - \bar x)^2}{n-1}\] \[s = \sqrt \frac{\sum_i (x_i - \bar x)^2}{n-1}\]

Percentils and quantiles on our samples can be computed as follows:

```j
discrete_cdf=: 4 : 0
ws=. (%+/)"1 -. | xs -"0 1 is=. (<.,>.)"0 xs=. x * <:#y
ws (+/"1 @: *) is { /:~ y
)

quantile =: discrete_cdf :. (+/ @: (<:/~) % #@])

meadian =: 0.5 & quantile
```

The local variables `is` and `ws` are used to interpolate between values at neighboring indices so that for example `0.5 discrete_cdf 0 3` and `median 0 3` agree and are both `1.5`. Declaring quantile as a function with obverse is cute but technically not valid. The delcared obverse counts how many elements of `y` are less than or equal to `x`.


<a id="org4433656"></a>

# Bootstrapping Confidence

Corresponds to Chapter 11 of casi textbook. Throughout, goal is to estimate the unseen statistic \(\theta\) from the bootstrap resample \(\hat\theta^*\)


<a id="org3731cd9"></a>

## Standard Interval

The simplest but least accurate way of stamping a condience interval on the resampled statistics \(\hat\theta^*\) is by taking the bootstrapped standard error and asking for coverage based on the normal distribution cdf.

```j
NB. monad producing adverb where u is statistic and y is sample.
bssi=: 1 : 0
  samp=. (u dobootstrap bs_B) y
  (mean samp) -`+`:0 (stddev samp) * qnorm -. -: bs_a
)
```

In other words for 95% coverage the estimate for \(\theta\) is inside interval \(\hat \theta \pm 1.96 \cdot \hat {\text{se}}\). 1.96 comes from cdf of standard normal distribution \(\Phi^{-1}(0.975)\). The 0.975 comes from \(1 - \frac{\alpha}{2}\) and our \(\alpha\) is configured through the variable `bs_a`.


<a id="orge8879d7"></a>

## Percentile Interval

The next best way to go is to use percentiles on the emperical resamples to find our confidence.

```j
NB. monad producing adverb where u is statistic and y is sample.
bspi=: 1 : 0
  ((,-.) -: bs_a) quantile (u dobootstrap bs_B) y
)
```

In other words, we estimate \(\theta\) from the bootstrap cdf \(\hat F\), and get the interval \(\hat F^{-1}[\frac{\alpha}{2},1 - \frac{\alpha}{2}]\). In J the base interval is cutely calculated by hooking `(,-.) -: bs_a`.


<a id="org96c6090"></a>

## Bias-corrected Percentile Interval

The resamples may skew more heavily to one side or the other of \(\hat \theta\). To correct for this, we look at the percentile of the it in the resample then derive the bounds on the confidence interval by mapping through the standard normal cdf \(\Phi\) getting the desired coverage and then calculatin percentiles.

```j
NB. monad producing adverb where u is statistic and y is sample.
bsbc=: 1 : 0
  that=. u y
  samp=. u dobootstrap bs_B y
  z0=. qnorm p0=. that quantile^:_1 samp
  I=. ({.,0.5,{:) pnorm (+: z0) + (qnorm (,-.) -: bs_a)
  I quantile samp
)
```

The above corresponds to \[p_0=\frac{\#\{\hat\theta^{*b} \le \hat \theta\}}{B}\] \[z_0=\Phi^{-1} (p_0)\] \[\hat\theta_{\text{BC}}[\alpha] = \hat F^{-1} [\Phi (2\cdot z_0 + z^{(\alpha)})]\]

When the bootstrap resamples are median unbiased (ie \(p_0 = 0.5\)) then \(z_0=0\) and this agrees with the simple percentile interval.


<a id="orgbf9ea9a"></a>

## Accelerated Bias-corrected Percentile Interval

todo