load 'plot stats/base stats/distribs'

bs_1rn  =: 1      NB. time alloted (upper bound on)
bs_n_lo =: 5      NB. minimum sample
bs_n_hi =: 1000   NB. maximum sample
bs_a    =: 0.1    NB. coverage
bs_B    =: 2000   NB. bootstrap resample

NB. monad taking prgram y to run a number of times based on configuration
dobench=: 6!:2"1@(# ,:)~ (bs_n_lo >. bs_n_hi <. [: <. bs_1rn % 6!:2)
NB. u is parameter, n is bootstrap B, y is sample
dobootstrap=: 2 : 'u"1 y {~ ? n # ,: $~ #y'

discrete_cdf=: 4 : 0
ws=. (%+/)"1 -. | xs -"0 1 is=. (<.,>.)"0 xs=. x * <:#y
ws (+/"1 @: *) is { /:~ y
)

quantile =: discrete_cdf :. (+/ @: (<:/~) % #@])

meadian =: 0.5 & quantile

NB. monad producing adverb where u is statistic and y is sample.
bssi=: 1 : 0
  samp=. (u dobootstrap bs_B) y
  (mean samp) -`[`+`:0 (stddev samp) * qnorm -. -: bs_a
)

NB. monad producing adverb where u is statistic and y is sample.
bspi=: 1 : 0
  that=. u y
  samp=. u dobootstrap bs_B y
  ({.,that,{:) ((,-.) -: bs_a) quantile samp
)

NB. monad producing adverb where u is statistic and y is sample.
bsbc=: 1 : 0
  that =. u y
  samp=. u dobootstrap bs_B y
  z0=. qnorm p0=. that quantile^:_1 samp
  I=. pnorm (+: z0) + (qnorm (,-.) -: bs_a)
  ({.,that,{:) I quantile samp
)

NB. monad producing adverb where u is statistic and y is sample.
bsbca=: 1 : 0
  thati=. (1 u \. y) - u y
  ahat=. 1r6 * (+/thati^3) % (+/*:thati)^3r2
  NB. I think that should actually be u y, but for some statistics (eg
  NB. R^2), it is out of range of bootstrap resamples, giving z0 = __
  that=. mean samp=. u dobootstrap bs_B y
  z0=. qnorm that quantile^:_1 samp
  zb=. qnorm -. -: bs_a
  zbh=. z0 + (z0+zb) % 1 - ahat * z0+zb
  za=. qnorm -: bs_a
  zah=. z0 + (z0+za) % 1 - ahat * z0+za
  ({.,that,{:) (pnorm zah,zbh) quantile samp
)

regress_bench=: +/\ %. 1 ,. i.@#
rsquare_bench=: 3 : 0
  v=. 1,.i.#y
  d=. +/\ y
  b=. d %. v
  k=. <:{:$v
  n=. $d
  sst=. +/*:d-(+/d) % #d
  sse=. +/*:d-v +/ .* b
  mse=. sse%n->:k
  seb=. %:({.mse)*(<0 1)|:%.(|:v) +/ .* v
  ssr=. sst-sse
  msr=. ssr%k
  rsq=. ssr%sst
  rsq
)

se2_t=: +&%&# * +&ssdev % +&#-2:
se_t=: %:@:se2_t

bs_t=: 4 : 0
  that=. x -&mean y
  sehat=. x se_t y
  samp=. x ((that -~ -&mean) % se_t)"1 & (] dobootstrap bs_B) y
  ({.,that,{:) that - sehat * ((,~-.) -: bs_a) quantile samp
)

bs_compare=: bs_t & dobench

NB. use bs bias corrected accelerated by default
bs_est =: bsbca

NB. report some descriptive statistics about a single vector y of
NB. benchmark results.
bs_summarize =: 3 : 0
  samp=. y

  xbarc=. mean bs_est samp
  sdevc=. stddev bs_est samp
  regac=. ({:@regress_bench) bs_est samp
  rsqrc=. rsquare_bench bs_est samp
  skwnc=. skewness bs_est samp
  kurtc=. kurtosis bs_est samp
  ests=. <"0 regac , rsqrc , xbarc , sdevc , skwnc ,: kurtc
  ests=. (;: 'lower estimate upper') , ests

  rows=. ('N = ',":#samp);'ols';('R',u:16b00b2);'mean';'stddev';'skewness';'kurtosis'
  rows ,. ests
)

NB. ambivalent benchmarks
bonsai=: 3 : 0
  0 bonsai y
  : 
  NB. the program that goes second suffers performance... figure out
  NB. something better!
  if. x do. 'sx sy'=. x ;&dobench y
	    echo (;: 'comparison lower estimate upper') ,: '- & mean' ; <"0 sx bs_t sy
      	    echo bs_summarize sx
	    echo bs_summarize sy
  else. bs_summarize dobench y end.
)
