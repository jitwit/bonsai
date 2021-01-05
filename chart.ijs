load 'bonsai.ijs plot'

CLRS_z_=: 0 127 132, 136 103 176,27 240 141,0 114 255,: 88 83 176
BONSAI_PLOT_CFG=: 0 : 0
reset;
backcolor black;frame 1;
backcolor 0 0 0;labelcolor 243 240 207; captioncolor 243 240 207;
axiscolor 243 240 207; textcolor 243 240 207; titlecolor 243 240 207;
pensize 0.5;
)

plot_bonsai =: 3 : 0
n=. # y
'a b'=. ab=. regress y
pd BONSAI_PLOT_CFG
pd'title bonsai;xcaption runs;ycaption time;'
pd 'type dot; color 0 160 255'
pd (+/\ y)
pd 'textcolor 255 255 255'
pd 'text 620 350 fit:  ',(":b),'x + ',(":a)
pd 'text 620 300 corr: ',":(+/\ y) corr (ab p. i.#res)
pd 'show'
)

IQR =: -/ @: (0.75 0.25&qtile)

X =: _2.1 _1.3 _0.4 1.9 5.1 6.2

bandwidth =: 0.9 * (stddevp * 5 %: 4r3 % #) NB. <. (0.746269 * IQR)

NB. n sample, u kernel, y point
kde =: {{ (h%#n) * +/ u (y - n) * h =. % bandwidth n }}

NB. standard normal pdf
phi =: (%:%2p1) * [: ^ _0.5 * *:
epanechnikov =: 3r4 * 0 >. 1 - *:

NB. samp =: (coname'') dobench_bonsai_ '+/ i. 201'
NB. eg =: (phi kde samp)"0
NB. 'visible 0' plot (1.2*(>./samp)*(%~i.)1000);'eg'

benchplot =: 3 : 0
'a b' =. (<./,>./) samp =. (coname'') dobench_bonsai_ y
pts =. (-:a+b) + ((%~i:)1000) * 0.6*b-a
benchKDE =: (phi kde samp)"0
up =. >./ benchKDE pts
pd 'reset; visible 0'
pd 'type dot;pensize 0.8'
pd samp;(up*((%~i.)#samp))
pd 'type line'
pd pts;'benchKDE'
pd'show'

)

benchplot '+/ i.1e7'
