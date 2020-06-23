coclass 'bonsai'
require 'stats/base stats/distribs'

budget=: 1
benchN=: 6!:2"1 @ (# ,:)~
bonsai=: benchN 1000 <. [: <. budget % 6!:2

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
stder=: %:@:(var % #)

NB. general but slow 1-jackknife
jkgen1s=: 1 : '1 u\. y'

tstat2=: -&mean % %: @ +&%&#

quantile=: 4 : 0
ws=. (%+/)"1 -. | xs -"0 1 is=. (<.,>.)"0 xs=. x * <:#y
ws (+/"1 @: *) is { /:~ y
)

quantileinv=: #@] %~ [ I.~ /:~@]

NB. quantileinv=: 4 : 0
NB. y =. /:~ y
NB. is =. y I. x
NB. vs =. ((,. <:) is) { y
NB. ws =. {."1 (-/"1 vs) %~ | x -"0 1 vs
NB. (is-ws) % #y
NB. )

box=: (+ [: (,~ -) 1.5 * -~/) @: (0.25 0.75&quantile)

qquantile=: 1 : '(m %~ i.&.<: m)&quantile'
quartiles=: 4 qquantile
percentiles=: 100 qquantile

regress=: %. (1 ,. i.@#)
NB. tacitquantile=: ([: (% +/)"1 [: -. [: | ([ * [: <: [: # ]) -"0 1 [: (<. , >.)"0 [ * [: <: [: # ]) +/"1@:* ([: (<. , >.)"0 [ * [: <: [: # ]) { [: /:~ ]

NB. u is parameter, n is bootstrap B, y is sample
dobootstrap=: 2 : 0
u"1 y {~ ? n # ,: $~ #y
)

NB. bootstrap confidence standard
NB. u is parameter to estimate
NB. y is sample
NB. x is bootstrap iterations B and confidence parameter alpha
bssi=: 1 : 0
'B a'=. x
samp=. (u dobootstrap B) y
sig=. stddev samp
uhat=. mean samp
uhat -`+`:0 sig * qnorm -. -: a
)

NB. bootstrap confidence percentile
NB. u is parameter to estimate
NB. y is sample
NB. x is bootstrap iterations B and confidence parameter alpha
bspi=: 1 : 0
'B a'=. x
((,-.) -: a) quantile (u dobootstrap B) y
)

NB. bootstrap confidence bias corrected percentile
NB. u is parameter to estimate
NB. y is sample
NB. x is bootstrap iterations B and confidence parameter alpha
bsbc=: 1 : 0
'B a'=. x
that=. mean samp=. u dobootstrap B y
z0=. qnorm that quantileinv samp
ab=. pnorm (+: z0) + (qnorm (,-.) -: a)
ab quantile samp
)

NB. bootstrap confidence bias corrected percentile
NB. u is parameter to estimate
NB. y is sample
NB. x is bootstrap iterations B and confidence parameter alpha
bsca=: 1 : 0
NB. todo
'B a'=. x
that=. mean samp=. u dobootstrap B y
z0=. qnorm that quantileinv samp
ab=. pnorm (+: z0) + (qnorm (,-.) -: a)
z0 ; ab ; ab quantile samp
)

NB. most of the info comes from https://projecteuclid.org/download/pdf_1/euclid.ss/1177013815, a survey paper by efron and tibshirani