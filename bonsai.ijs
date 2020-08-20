load 'plot stats/base stats/distribs'

bs_tl   =: 1      NB. time alloted (upper bound on)
bs_n_lo =: 5      NB. minimum sample
bs_n_hi =: 1000   NB. maximum sample
bs_a    =: 0.05   NB. coverage
bs_B    =: 2000   NB. bootstrap resample

NB. monad taking prgram y to run a number of times based on configuration.
NB. x runbench y measures time to execute y x times. 
dobench=:  3 : 0
  (bs_n_hi <. bs_n_lo >. >. bs_tl % 1e_6 >. 6!:2 y) dobench y
  :
  6!:2"1 x # ,: y
)

NB. resample: u is bootstrap iters B, y is original sample
dobootstrap=: 1 : 'y {~ ? u # ,: $~ #y'

discrete_cdf=: 4 : 0
  ws=. (%+/)"1 -. | xs -"0 1 is=. (<.,>.)"0 xs=. x * <:#y
  ws (+/"1 @: *) is { /:~ y
)

quantile =: discrete_cdf :. (+/ @: (<:/~) % #@])

meadian =: 0.5 & quantile

NB. dyad producing adverb where u is statistic, x is resample, y is sample
bssi=: 1 : 0
  resamp=. u"1 x
  (mean resamp) -`[`+`:0 (stddev resamp) * qnorm -. -: bs_a
)

NB. monad producing adverb where u is statistic, y is sample, and x is resample.
bspi=: 1 : 0
  that=. u y
  resamp=. u"1 x
  ({.,that,{:) ((,-.) -: bs_a) quantile resamp
)

NB. monad producing adverb where u is statistic and y is sample.
bsbc=: 1 : 0
  that =. u y
  resamp=. u"1 x
  z0=. qnorm p0=. that quantile^:_1 samp
  I=. pnorm (+: z0) + (qnorm (,-.) -: bs_a)
  ({.,that,{:) I quantile samp
)

NB. dyad producing adverb where u is statistic and y is sample and x is resample
bsbca=: 1 : 0
  thati=. (1 u \. y) - that =. u y
  ahat=. 1r6 * (+/thati^3) % (+/*:thati)^3r2
  resamp=. u"1 x NB. u dobootstrap bs_B y
  z0qt=. that quantile^:_1 resamp
  if. (z0qt <: 0) +. z0qt >: 1 do. x u bspi y
  else. z0=. qnorm z0qt
        zabh=. z0 + (% 1 - ahat&*) z0 + qnorm (,-.) -: bs_a
        ({.,that,{:) (pnorm zabh) quantile resamp
  end.
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
  samp=. x ((that -~ -&mean) % se_t)"1 & (bs_B dobootstrap) y
  ({.,that,{:) that - sehat * ((,~-.) -: bs_a) quantile samp
)

bs_compare=: bs_t & dobench

NB. bonsai_plotted =: 3 : 0
NB. resamp=. bs_B dobootstrap samp=. dobench y
NB. N =. # samp
NB. 'rlo rmi rhi'=. resamp ({:@regress_bench) bs_est samp
NB. pd 'reset;xcaption runs; ycaption time; title bonsai'
NB. pd 'subtitle ''',y,'''; subtitlecolor snow'
NB. pd 'backcolor black; labelcolor snow; captioncolor snow; titlecolor snow'
NB. pd 'axiscolor snow; labelcolor snow; captioncolor snow'
NB. pd 'color 78 233 215;type dot; pensize 0.6'
NB. pd samp ;~ 1 + i. N
NB. pd 'color 195 173 240;type line; pensize 1.4'
NB. pd (,~rlo) ;~ 1,N
NB. pd (,~rmi) ;~ 1,N
NB. pd (,~rhi) ;~ 1,N
NB. pd 'show'
NB. )

NB. use bs bias corrected accelerated by default
bs_est =: bsbca

NB. report some descriptive statistics about a single vector y of
NB. benchmark results.
bs_summarize =: 3 : 0
  samp=. y
  resamp=. bs_B dobootstrap y
  xbarc=. resamp mean bs_est samp
  sdevc=. resamp stddev bs_est samp
  regac=. resamp ({:@regress_bench) bs_est samp
  rsqrc=. resamp rsquare_bench bs_est samp
  skwnc=. resamp skewness bs_est samp
  kurtc=. resamp kurtosis bs_est samp
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
