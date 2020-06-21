
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