load 'bonsai.ijs plot'

IQR =: -/ @: (0.75 0.25&qtile)

bandwidth =: 0.9 * (stddevp * 5 %: 4r3 % #) NB. <. (0.746269 * IQR)
NB. n sample, u kernel, y point
kde =: {{ (h%#n) * +/ u (y - n) * h =. % bandwidth n }}
NB. standard normal pdf
phi =: (%:%2p1) * [: ^ _0.5 * *:
epanechnikov =: 3r4 * 0 >. 1 - *:

benchplot =: 3 : 0
pd 'reset; visible 0;title ',y
pd 'xcaption time;ycaption kde & sample over time'
'a b' =. (<./,>./) samp =. (coname'') dobench_bonsai_ y
pts =. (-:a+b) + ((%~i:)1000) * 0.6*b-a
den =. (phi kde samp)"0 pts
pd 'type dot;pensize 0.3;color 80 100 200'
pd samp;(>./den)*(%~i.)#samp
pd 'type line; pensize 2;color 0 120 240'
pd pts;den
pd 'key sample density; keycolor 80 100 200,0 120 240;keypos top right'
pd'show'
)

benchplot '+/>:i.1e6'
