load 'plot stats/base stats/distribs'

bs_tl   =: 1      NB. time alloted (upper bound on)
bs_n_lo =: 5      NB. minimum sample
bs_n_hi =: 2000   NB. maximum sample
bs_a    =: 0.05   NB. coverage
bs_B    =: 3000   NB. bootstrap resample
NB. current version in stats/base slow for this use case, whence:
dev =: (- mean)`(-"_1 _ mean)@.(1 < #@$)

dobench=:  3 : 0
NB. dobench y: run sentence y a number of times based on configuration.
  (bs_n_hi <. bs_n_lo >. >. bs_tl % 1e_6 >. 6!:2 y) dobench y
  :
NB. x runbench y: measure time to execute sentence y x times.
  6!:2"1 x # ,: y
)

dobootstrap=: 1 : 0
NB. u doboostrap: redraw uniformly from sample y u times.
  y {~ ? u # ,: $~ #y
)

qtile =: 4 : 0
  ws=. (%+/)"1 -. | xs -"0 1 is=. (<.,>.)"0 xs=. x * <:#y
  ws (+/"1 @: *) is { /:~ y
)

cdf =: (+/ @: (<:/~) % #@]) :. qtile

bssi=: 1 : 0
NB. x u bspi y: verb u is statistic, y is sample, x is resample.
  (mean s) -`[`+`:0 (stddev s=. u"1 x) * qnorm -. -: bs_a
)

bspi=: 1 : 0
NB. x u bspi y: verb u is statistic, y is sample, x is resample.
  ((-:i.3) + (i:_1) * -:bs_a) cdf^:_1 u"1 x
)

bsbc=: 1 : 0
NB. x u bsbc y: verb u is statistic, y is sample, x is resample.
  z0=. qnorm p0=. (that =. u y) cdf x
  I=. pnorm (+: z0) + qnorm (,-.) -: bs_a
  ({.,that,{:) I (cdf^:_1) samp
)

bsbca=: 1 : 0
NB. x u bsbca y: verb u is statistic, y is sample, and x is resample.
  thati=. (1 u \. y) - that =. u y
  ahat=. 1r6 * (+/thati^3) % (+/*:thati)^3r2
  z0qt=. that cdf resamp=. u"1 x
  ab =. (,-.) -: bs_a
  if. 1 ~: ab I. z0qt do. x u bspi y
  else. z0=. qnorm z0qt
        zabh=. z0 + (% 1 - ahat&*) z0 + qnorm ab
        ({.,that,{:) (pnorm zabh) cdf^:_1 resamp
  end.
)

regress_bench=: +/\ %. 1 ,. i.@#
rsquare_bench=: 3 : 0
  b=. (y=.+/\y) %. v=. 1,.i.#y
  (sst-+/*:y-v +/ .* b)% sst=. +/*:y-(+/y) % n=. #y
)

se2_t=: +&%&# * +&ssdev % +&#-2:
se_t=: %:@:se2_t

bs_t=: 4 : 0
NB. x bs_t y: use bootstrap-t to compare distributions of benchmark
NB. results form sentences x and y.
  that=. x -&mean y
  sehat=. x se_t y
  samp=. x ((that -~ -&mean) % se_t)"1 & (bs_B dobootstrap) y
  ({.,that,{:) that - sehat * ((,~-.) -: bs_a) cdf^:_1 samp
)

bs_compare=: bs_t & dobench

NB. use bs bias corrected accelerated by default
bs_est =: bsbca

bs_summarize =: 3 : 0
NB. Report some descriptive statistics about a list y of benchmark results.
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
NB. the program that goes second suffers performance... figure out
NB. something better!
bonsai=: 3 : 0
NB. Benchmark senetence y
  0 bonsai y
  :
NB. Benchmark sentences x and y and compare means.sentence y suffers a bit in
NB. performance, so take that in to consideration. Positive values from
NB. comparison mean sentence x is likely slower than sentence y.
  if. x do. 'sx sy'=. x ;&dobench y
	    echo (;: 'comparison lower estimate upper') ,: '- & mean' ; <"0 sx bs_t sy
      	    echo bs_summarize sx
	    echo bs_summarize sy
  else. bs_summarize dobench y end.
)
