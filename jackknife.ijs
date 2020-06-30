NB. jackknife

jkmean=: (-~ +/) % <:@#
jkdev=: -"_1 jkmean
jkssdev=: *:@jkdev
jm=: +/\ @ (_1&(|.!.0)) + +/\. @ (1&(|.!.0))
jsm=: jm @: *:
jkdev=: jm@:*: - *:@:jm % <:@#
jkvarp=: jkdev % <:@#
jkvar=: jkdev % # - 2:
jkstddev=: %: @ jkvar
jkstddevp=: %: @ jkvarp
stder=: %: @: (var % #)

NB. general but slow 1-jackknife
jkgen1s=: 1 : '1 u\. y'
NB. tstat2=: -&mean % %: @ +&%&#
