coclass 'bonsai'
require 'stats/base'

budget=: 5

bench1=: 3 : 0
6!:2 y
)

benchN=: 4 : 0
bench1"1 y # ,: x
)

bonsai=: benchN [: <. budget % bench1

NB. jackknife
jkmean =: (-~ +/) % <:@#
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

quantile=: 4 : 0
ws=. (%+/)"1 -. | xs -"0 1 is =. (<.,>.)"0 xs =. x * <:#y
ws (+/"1 @: *) is { /:~ y
)

box=: (+ [: (,~ -) 1.5 * -~/) @: (0.25 0.75&quantile)

qquantile=: 1 : '(m %~ (i.&.<:)m)&quantile'
quartiles=: 4 qquantile
percentiles=: 100 qquantile

regress=: %. (1 ,.~ i.@#)
NB. tacitquantile=: ([: (% +/)"1 [: -. [: | ([ * [: <: [: # ]) -"0 1 [: (<. , >.)"0 [ * [: <: [: # ]) +/"1@:* ([: (<. , >.)"0 [ * [: <: [: # ]) { [: /:~ ]

