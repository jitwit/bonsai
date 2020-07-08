load'bonsai.ijs jackknife.ijs stats/base/multivariate'

test_cases=: 0 : 0
NB. jackknife
(jkmean -: 1 mean\. ]) 1 1 3 2
(jkvar -: 1 var\. ]) 1 1 3 2
(jkvarp -: 1 varp\. ]) 1 1 3 2
(jkdev -: 1 ssdev\. ]) 1 1 3 2
(jkstddev -: 1 stddev\. ]) 1 1 3 2
(jkstddevp -: 1 stddevp\. ]) 1 1 3 2
NB. quantile
(0.5&quantile -: median) 1 1 3 2
(0.5&quantile -: median) 1 1 3 2 1
(0.5&quantile -: median) 1 1 3 2 1 2
(1.8 2 2.2 (quantile^:_1) 1 2 3 2 1) -: 0.4 0.8 0.8
)

test=: 3 : 0
0!:2 test_cases
)

table31=: 7 51 44 69 49 41 59 70 34 42 46 40 0 40 32 45 49 57 52 64 44 61
table31=: table31,36 59 42 60 5 30 22 58 18 51 41 63 48 38 31 42 42 69 46 49 63 63
table31=: |: _2 ]\ table31

