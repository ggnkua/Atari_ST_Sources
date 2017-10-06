rem PUTGET.BAS -- Test PUT and GET statements
open "r", 1, "test.dat", 48
field 1, 20 as r1$, 20 as r2$, 8 as r3$
for l = 1 to 2
line input "name: "; n$
line input "address: "; m$
line input "phone: "; p$
lset r1$ = n$
lset r2$ = m$
lset r3$ = p$
put #1, l
next l
close #1
open "r", 1, "test.dat", 48
field 1, 20 as r1$, 20 as r2$, 8 as r3$
for l = 1 to 2
get #1, l
print r1$, r2$, r3$
next l
close #1
kill "test.dat"
end
