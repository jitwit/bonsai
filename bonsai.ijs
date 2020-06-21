coclass 'bonsai'
require 'stats/base'

budget=: 5

egprogram=: '+/ i.&.(p:^:_1)'

egN=: program,' ',":
eg1000=: egN 1000
eg1000=: program,' 1000'

bench1=: 3 : 0
6!:2 y
)

benchN=: 4 : 0
bench1"1 x # ,:y
)

bonsai=: 3 : 0
t0=: bench1 y
(<. budget % t0) benchN y
)

