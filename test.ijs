load'bonsai.ijs jackknife.ijs'

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
(1.8 2 2.2 quantileinv 1 2 3 2 1) -: 0.4 0.8 0.8
)

test=: 3 : 0
0!:2 test_cases
)

