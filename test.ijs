load'bonsai.ijs jackknife.ijs stats/base/multivariate'

test_cases=: 0 : 0
NB. jackknife
(jkmean -: 1 mean\. ]) 1 1 3 2
(jkvar -: 1 var\. ]) 1 1 3 2
(jkvarp -: 1 varp\. ]) 1 1 3 2
(jkdev -: 1 ssdev\. ]) 1 1 3 2
(jkstddev -: 1 stddev\. ]) 1 1 3 2
(jkstddevp -: 1 stddevp\. ]) 1 1 3 2
NB. cdf
(0.5&cdf^:_1 -: median) 1 1 3 2
(0.5&cdf^:_1 -: median) 1 1 3 2 1
(0.5&cdf^:_1 -: median) 1 1 3 2 1 2
(1.8 2 2.2 cdf 1 2 3 2 1) -: 0.4 0.8 0.8
NB. printing
'8ms' -: bspp 8e_3
'89ns' -: bspp 8.9e_8
'5.32s' -: bspp 5.321
)

test_locale =: 3 : 0
 coclass 'tloc'
 func =: +/@i.
 bonsai 'func 201'
 1 assert. 1 = (bonsai :: 1:) 'func 201' [ cocurrent 'base'
)

demo3 =: {{bonsai '%. ? 50 50 $ 0'}}            NB. monad demo
demo4 =: {{'e. i. 1000' bonsai '=/ i. 1000'}}   NB. dyad  demo

table31=: 7 51 44 69 49 41 59 70 34 42 46 40 0 40 32 45 49 57 52 64 44 61
table31=: table31,36 59 42 60 5 30 22 58 18 51 41 63 48 38 31 42 42 69 46 49 63 63
table31=: |: _2 ]\ table31

NB. bspp 1e_5 1.2e_5 9e_3 7e_7 3.2
NB. bonsaipp '%. ?. 50 50 $ 0'
test=: 3 : 0
 cocurrent 'bonsai'
 0!:2 test_cases
 cocurrent 'base'
 echo '   test_locale '''''
 test_locale''
)

test''

'+/ 1 + i. 200' bonsai '+/ i. 201'

'+/ i. 201' bonsai '+/ 1 + i. 200'
demo4''
