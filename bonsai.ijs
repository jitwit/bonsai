coclass 'bonsai'
load 'stats/base stats/distribs'

time  =: 1      NB. time alloted (upper bound on)
lo    =: 5      NB. minimum sample
hi    =: 2000   NB. maximum sample
alpha =: 0.05   NB. coverage
B     =: 2500   NB. bootstrap resample

dobench=:  1 : 0
NB. u dobench y: run sentence y a number of times based on the
NB. configuration. u is the locale where the sentence was called from,
NB. which is captured in the bonsai verb.
 cocurrent u
 t0 =. (hi_bonsai_ <. lo_bonsai_ >. >. time_bonsai_ % 1e_6 >. 6!:2 y)
 xs =. 6!:2"1 t0 # ,: y
 cocurrent 'bonsai' NB. apparently u would otherwise stick during
		    NB. execution of other verbs (eg summarize)
 xs
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

IQR =: -/ @: (0.75 0.25&qtile)

bandwidth =: 0.9 * (stddevp * 5 %: 4r3 % #) NB. <. (0.746269 * IQR)

kde =: 2 : 0
NB. n sample, u kernel, y point
 (h%#n) * +/ u (y - n) * h =. % bandwidth n
)
NB. standard normal pdf & epanechnikov kernels
phi =: (%:%2p1) * [: ^ _0.5 * *:
epanechnikov =: 3r4 * 0 >. 1 - *:

bssi=: 1 : 0
NB. x u bspi y: verb u is statistic, y is sample, x is resample.
 (mean s) -`[`+`:0 (stddev s=. u"1 x) * qnorm -. -: alpha
)

bspi=: 1 : 0
NB. x u bspi y: verb u is statistic, y is sample, x is resample.
 ((-:i.3) + (i:_1) * -:alpha) cdf^:_1 u"1 x
)

bsbc=: 1 : 0
NB. x u bsbc y: verb u is statistic, y is sample, x is resample.
 that =. u samp =. y
 z0=. qnorm that cdf resamp =. u"1 x
 I=. pnorm (+: z0) + qnorm (,-.) -: alpha
 ({.,that,{:) I (cdf^:_1) resamp
)

bsbca=: 1 : 0
NB. x u bsbca y: verb u is statistic, y is sample, and x is resample.
 thati=. (1 u \. y) - that =. u y
 ahat=. 1r6 * (+/thati^3) % (+/*:thati)^3r2
 z0qt=. that cdf resamp=. u"1 x
 ab =. (,-.) -: alpha
 if. 1 ~: ab I. z0qt do. x u bspi y
 else. z0=. qnorm z0qt
       zabh=. z0 + (% 1 - ahat&*) z0 + qnorm ab
       ({.,that,{:) (pnorm zabh) cdf^:_1 resamp
 end.
)

regress_bench=: +/\ %. 1 ,. i.@#
rsquare_bench=: 3 : 0
 b=. (y=.+/\y) %. v=. 1,.i.#y
 (sst-+/*:y-v +/ . * b)% sst=. +/*:y-(+/y) % n=. #y
)

se2_t=: +&%&# * +&ssdev % +&#-2:
se_t=: %:@:se2_t

bs_t=: 4 : 0
NB. x bs_t y: use bootstrap-t to compare distributions of benchmark
NB. results form sentences x and y.
 that=. x -&mean y
 sehat=. x se_t y
 sx =. B dobootstrap x
 sy =. B dobootstrap y
 xbar =. sx mean bs_est x
 ybar =. sy mean bs_est y
 dsamp=. sx ((that -~ -&mean) % se_t)"1 sy
 ths =. ({.,that,{:) that - sehat * ((,~-.) -: alpha) cdf^:_1 dsamp
 xvy =. xbar (-~%[) ybar
 ths , xbar , ybar ,: xvy
)

bs_compare=: bs_t & dobench

bsppns =: 'ns' ,~ [: ": [: <. 0.5 + 1e9&*
bsppus =: ('s',~u:16b3bc) ,~ [: ": [: <. 0.5 + 1e6&*
bsppms =: 'ms' ,~ [: ": [: <. 0.5 + 1e3&*
bspps =: 's' ,~ [: ": (100 %~ [: <. 0.5 + 100&*)
bsppa =: bsppns`bsppus`bsppms`bspps@.(_6 _3 0 I. 10&^.)
bsnump =: 1 4 8 e.~ 3!:0
bsucp =: 131072 262144 e.~ 3!:0
bspp =: bsppa ^: bsnump

bonsaipp =: 3 : 0
 NB. with monadic bonsai usage, pretty print the results
 res =. bonsai y
 (u:@":) ^: (-.@bsucp) &.> ({: res) ,~ bspp &.> }: res
)

bonsaiplot_z_ =: 3 : 0
NB. plot kde of benchmark of sentence y
 require 'plot'
 pd 'reset; visible 0;title bonsai'
 pd 'xcaption time;ycaption kde & sample over time'
 'a b' =. (<./,>./) samp =. (coname'') dobench_bonsai_ y
 den =. (epanechnikov kde samp)"0 pts =. (-:a+b) + ((%~i:)1000) * 0.6*b-a
 pd 'type dot;pensize 0.3;color 80 100 200'
 pd samp;(>./den)*(%~i.)#samp
 pd 'type line; pensize 2;color 0 120 240'
 pd pts;den
 pd 'key sample density; keycolor 80 100 200,0 120 240;keypos top right'
 pd'show'
)

NB. use bs bias corrected accelerated by default
bs_est =: bsbca

mu =: u: 16b3bc
delta =: u: 16b3c3

summarize =: 3 : 0
NB. Report some descriptive statistics about a list y of benchmark results.
 resamp=. B dobootstrap samp=. y
 xbarc=. resamp mean bs_est samp
 sdevc=. resamp stddev bs_est samp
NB. regac=. resamp ({:@regress_bench) bs_est samp
NB. rsqrc=. resamp rsquare_bench bs_est samp
NB.  skwnc=. resamp skewness bs_est samp
NB.  kurtc=. resamp kurtosis bs_est samp
 ests=. <"0 xbarc ,: sdevc NB. , regac ,: rsqrc
 ests=. (;: 'lower estimate upper') , ests

 rows=. ('N = ',":#samp);mu;delta NB. ;'ols';('R',(u:16bb2),' (ols)')
 rows ,. ests
)

bonsai3=: 1 : 'summarize u dobench_bonsai_ y'
bonsai4 =: 1 : 0
 table =. ;: 'comparison lower estimate upper'
 x =. u dobench_bonsai_ x
 y =. u dobench_bonsai_ y
 x_y =. x bs_t y
 table =. table , (('- & ',mu);(mu,'(x)');(mu,'(y)');'x (-~%[) y') ,. <"0 x_y
)

bonsai_z_ =: 3 : 0
NB. bonsai y: estimate performance of sentence y
  loc =. coname''
  loc bonsai3_bonsai_ y
:
NB. x bonsai y: compare mean execution time of two sentences. a
NB. positive estimate means sentence x takes longer to execute than
NB. sentence y.
  loc =. coname ''
  x loc bonsai4_bonsai_ y
)
