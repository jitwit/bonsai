coclass 'bonsai'
require 'stats/base stats/distribs plot'

bs_1rn =: 1 NB. bs time budget based on first run
bs_a =: 0.05 NB. bs confidence
bs_B =: 2000 NB. bs iters
bs_est =: bsbca
dobench=: 6!:2"1@(# ,:)~ (5 >. 1000 <. [: <. bs_1rn % 6!:2)

NB. jackknife
jkmean=: (-~ +/) % <:@#
jkdev=: -"_1 jkmean
jkssdev=: *:@jkdev
sl=: +/\ @ (_1&(|.!.0))
sr=: +/\. @ (1&(|.!.0))
jm=: sl + sr
jsm=: jm @: *:
jkdev=: jm@:*: - *:@:jm % <:@#
jkvarp=: jkdev % <:@#
jkvar=: jkdev % # - 2:
jkstddev=: %: @ jkvar
jkstddevp=: %: @ jkvarp
stder=: %: @: (var % #)

NB. general but slow 1-jackknife
jkgen1s=: 1 : '1 u\. y'

tstat2=: -&mean % %: @ +&%&#

quantile=: 4 : 0
ws=. (%+/)"1 -. | xs -"0 1 is=. (<.,>.)"0 xs=. x * <:#y
ws (+/"1 @: *) is { /:~ y
)

quantileinv=: #@] %~ [ I.~ /:~@]

box=: (+ [: (,~ -) 1.5 * -~/) @: (0.25 0.75&quantile)

qquantile=: 1 : '(m %~ i.&.<: m)&quantile'
quartiles=: 4 qquantile
percentiles=: 100 qquantile

NB. u is parameter, n is bootstrap B, y is sample
dobootstrap=: 2 : 'u"1 y {~ ? n # ,: $~ #y'

NB. bootstrap confidence standard
NB. u is parameter to estimate
NB. y is sample
NB. x is bootstrap iterations B and confidence parameter alpha
bssi=: 1 : 0
  samp=. (u dobootstrap bs_B) y
  sig=. stddev samp
  uhat=. mean samp
  uhat -`+`:0 sig * qnorm -. -: bs_a
)

NB. bootstrap confidence percentile
NB. u is parameter to estimate
NB. y is sample
NB. x is bootstrap iterations B and confidence parameter alpha
bspi=: 1 : 0
  ((,-.) -: bs_a) quantile (u dobootstrap bs_B) y
)

NB. bootstrap confidence bias corrected percentile
NB. u is parameter to estimate
NB. y is sample
NB. x is bootstrap iterations B and confidence parameter alpha
bsbc=: 1 : 0
  that=. mean samp=. u dobootstrap bs_B y
  z0=. qnorm that quantileinv samp
  ab=. pnorm (+: z0) + (qnorm (,-.) -: bs_a)
  ({.,that,{:) ab quantile samp
)

NB. bootstrap confidence bias corrected percentile accelerated
NB. u is parameter to estimate
NB. y is sample
NB. x is bootstrap iterations B and confidence parameter alpha
bsbca=: 1 : 0
  thati=. (- mean) 1 u \. y
  ahat=. 1r6 * (+/thati^3) % (+/*:thati)^3r2
  that=. mean samp=. u dobootstrap bs_B y
  z0=. qnorm that quantileinv samp
  zb=. qnorm -. -: bs_a
  zbh=. z0 + (z0+zb) % 1 - ahat * z0+zb
  za=. qnorm -: bs_a
  zah=. z0 + (z0+za) % 1 - ahat * z0+za
  ab=. pnorm zah,zbh
  ({.,that,{:) ab quantile samp
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

bonsai=: 3 : 0
  samp=. dobench y

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

NB. export to z locale
bonsai_z_=: bonsai_bonsai_
