_FULLSCREEN _STRETCH
DIM chart(3000000, 30)
DIM numbers(100)
DIM numb(50)
DIM totalnumbers(100)
DIM linecounter(30000)
Main:
CLS
PRINT
PRINT "__________________________________________________"
PRINT "| For Keno Midday  Type [A] To Set For That Draw |"
PRINT "| FOR Keno Evening Type [B] To set For That Draw |"
PRINT "| FOR LOTTO 649    Type [C] To Set For That Draw |"
PRINT "| For LottoMax     Type [D] To Set For That Draw |"
PRINT "|________________________________________________|"
PRINT "|    Type A Letter From The Boxes Above [  ]     |"
PRINT "|________________________________________________|"
PRINT
LOCATE 8, 42
INPUT " ", draw$

IF draw$ = "A" OR draw$ = "a" THEN
    numbers = 23
    totalcounter = 70
    GOTO midday
END IF
IF draw$ = "B" OR draw$ = "b" THEN
    numbers = 23
    totalcounter = 70
    GOTO evening
END IF
IF draw$ = "D" OR draw$ = "d" THEN
    numbers = 8
    totalcounter = 70
    GOTO lottomax
END IF

GOTO fini
midday:
CLS
PRINT
PRINT "Setting up for Daily Keno Midday....."
PRINT
counter = 0
PRINT
OPEN "keno_midday.dat" FOR INPUT AS #3
DO UNTIL EOF(3)
    counter = counter + 1
    LINE INPUT #3, a$
LOOP
CLOSE #3


OPEN "keno_midday.dat" FOR INPUT AS #1
OPEN "kenomidday.dat" FOR OUTPUT AS #2
FOR iii = 1 TO counter
    INPUT #1, month, day, year, a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t
    chart(iii, 1) = month
    chart(iii, 2) = day
    chart(iii, 3) = year
    chart(iii, 4) = a
    chart(iii, 5) = b
    chart(iii, 6) = c
    chart(iii, 7) = d
    chart(iii, 8) = e
    chart(iii, 9) = f
    chart(iii, 10) = g
    chart(iii, 11) = h
    chart(iii, 12) = i
    chart(iii, 13) = j
    chart(iii, 14) = k
    chart(iii, 15) = l
    chart(iii, 16) = m
    chart(iii, 17) = n
    chart(iii, 18) = o
    chart(iii, 19) = p
    chart(iii, 20) = q
    chart(iii, 21) = r
    chart(iii, 22) = s
    chart(iii, 23) = t


NEXT iii
iii = 0
PRINT "Chart Built Backwards !!!!!!!!!!!!!!!!!"

FOR iii = counter TO 1 STEP -1
    month = chart(iii, 1)
    day = chart(iii, 2)
    year = chart(iii, 3)
    a = chart(iii, 4)
    b = chart(iii, 5)
    c = chart(iii, 6)
    d = chart(iii, 7)
    e = chart(iii, 8)
    f = chart(iii, 9)
    g = chart(iii, 10)
    h = chart(iii, 11)
    i = chart(iii, 12)
    j = chart(iii, 13)
    k = chart(iii, 14)
    l = chart(iii, 15)
    m = chart(iii, 16)
    n = chart(iii, 17)
    o = chart(iii, 18)
    p = chart(iii, 19)
    q = chart(iii, 20)
    r = chart(iii, 21)
    s = chart(iii, 22)
    t = chart(iii, 23)
    PRINT USING "## ## ####  ## ## ## ## ##"; month; day; year; a; b; c; d; e
    PRINT USING "            ## ## ## ## ##"; f; g; h; i; j
    PRINT USING "            ## ## ## ## ##"; k; l; m; n; o
    PRINT USING "            ## ## ## ## ##"; p; q; r; s; t
    PRINT
    PRINT "--------------------------"
    PRINT
    pattern2$ = "## ## ####  ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##"
    PRINT #2, USING pattern2$; month; day; year; a; b; c; d; e; f; g; h; i; j; k; l; m; n; o; p; q; r; s; t

NEXT iii
CLOSE #2
CLOSE #1
GOTO Main
evening:
CLS
PRINT
PRINT "Setting up for Daily Keno Evening Draws."
PRINT

PRINT
counter = 0
OPEN "keno_evening.dat" FOR INPUT AS #4
DO UNTIL EOF(4)
    counter = counter + 1
    LINE INPUT #4, a$
LOOP
CLOSE #3


OPEN "keno_evening.dat" FOR INPUT AS #1
OPEN "kenoevening.dat" FOR OUTPUT AS #2

FOR iii = 1 TO counter
    INPUT #1, month, day, year, z, a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t
    chart(iii, 1) = month
    chart(iii, 2) = day
    chart(iii, 3) = year
    chart(iii, 4) = a
    chart(iii, 5) = b
    chart(iii, 6) = c
    chart(iii, 7) = d
    chart(iii, 8) = e
    chart(iii, 9) = f
    chart(iii, 10) = g
    chart(iii, 11) = h
    chart(iii, 12) = i
    chart(iii, 13) = j
    chart(iii, 14) = k
    chart(iii, 15) = l
    chart(iii, 16) = m
    chart(iii, 17) = n
    chart(iii, 18) = o
    chart(iii, 19) = p
    chart(iii, 20) = q
    chart(iii, 21) = r
    chart(iii, 22) = s
    chart(iii, 23) = t


NEXT iii
iii = 0
PRINT "Chart Built Backwards !!!!!!!!!!!!!!!!!"

FOR iii = counter TO 1 STEP -1
    month = chart(iii, 1)
    day = chart(iii, 2)
    year = chart(iii, 3)
    a = chart(iii, 4)
    b = chart(iii, 5)
    c = chart(iii, 6)
    d = chart(iii, 7)
    e = chart(iii, 8)
    f = chart(iii, 9)
    g = chart(iii, 10)
    h = chart(iii, 11)
    i = chart(iii, 12)
    j = chart(iii, 13)
    k = chart(iii, 14)
    l = chart(iii, 15)
    m = chart(iii, 16)
    n = chart(iii, 17)
    o = chart(iii, 18)
    p = chart(iii, 19)
    q = chart(iii, 20)
    r = chart(iii, 21)
    s = chart(iii, 22)
    t = chart(iii, 23)
    pattern2$ = "## ## ####  ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##"
    PRINT #2, USING pattern2$; month; day; year; a; b; c; d; e; f; g; h; i; j; k; l; m; n; o; p; q; r; s; t

NEXT iii
CLOSE #2
CLOSE #1
GOTO Main
lottomax:
CLS
PRINT
PRINT "Setting up for LottoMax Lottery....."
PRINT

PRINT
OPEN "lotto_max.txt" FOR INPUT AS #3
DO UNTIL EOF(3)
    counter = counter + 1
    LINE INPUT #3, a$
LOOP
CLOSE #3


OPEN "lotto_max.txt" FOR INPUT AS #1
OPEN "lottomax.dat" FOR OUTPUT AS #2
FOR iii = 1 TO counter
    INPUT #1, month, day, year, a, b, c, d, e, f, g, h
    chart(iii, 1) = month
    chart(iii, 2) = day
    chart(iii, 3) = year
    chart(iii, 4) = a
    chart(iii, 5) = b
    chart(iii, 6) = c
    chart(iii, 7) = d
    chart(iii, 8) = e
    chart(iii, 9) = f
    chart(iii, 10) = g
    chart(iii, 11) = h


NEXT iii
iii = 0
PRINT "Chart Built Backwards !!!!!!!!!!!!!!!!!"

FOR iii = counter TO 1 STEP -1
    month = chart(iii, 1)
    day = chart(iii, 2)
    year = chart(iii, 3)
    a = chart(iii, 4)
    b = chart(iii, 5)
    c = chart(iii, 6)
    d = chart(iii, 7)
    e = chart(iii, 8)
    f = chart(iii, 9)
    g = chart(iii, 10)
    h = chart(iii, 11)
    pattern2$ = "## ## ####  ## ## ## ## ## ## ## ##"
    PRINT #2, USING pattern2$; month; day; year; a; b; c; d; e; f; g; h


NEXT iii
CLOSE #2
CLOSE #1
GOTO Main
Lotto649:
CLS
PRINT
PRINT "Setting up for Lotto649 Lottery....."
PRINT

PRINT
OPEN "lotto_649.dat" FOR INPUT AS #3
DO UNTIL EOF(3)
    counter = counter + 1
    LINE INPUT #3, a$
LOOP
CLOSE #3


OPEN "lotto_649.dat" FOR INPUT AS #1
OPEN "lotto649.dat" FOR OUTPUT AS #2
FOR iii = 1 TO counter
    INPUT #1, month, day, year, a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t
    chart(iii, 1) = month
    chart(iii, 2) = day
    chart(iii, 3) = year
    chart(iii, 4) = a
    chart(iii, 5) = b
    chart(iii, 6) = c
    chart(iii, 7) = d
    chart(iii, 8) = e
    chart(iii, 9) = f
    chart(iii, 10) = g
    chart(iii, 11) = h
    chart(iii, 12) = i
    chart(iii, 13) = j
    chart(iii, 14) = k
    chart(iii, 15) = l
    chart(iii, 16) = m
    chart(iii, 17) = n
    chart(iii, 18) = o
    chart(iii, 19) = p
    chart(iii, 20) = q
    chart(iii, 21) = r
    chart(iii, 22) = s
    chart(iii, 23) = t


NEXT iii
iii = 0
PRINT "Chart Built Backwards !!!!!!!!!!!!!!!!!"

FOR iii = counter TO 1 STEP -1
    month = chart(iii, 1)
    day = chart(iii, 2)
    year = chart(iii, 3)
    a = chart(iii, 4)
    b = chart(iii, 5)
    c = chart(iii, 6)
    d = chart(iii, 7)
    e = chart(iii, 8)
    f = chart(iii, 9)
    g = chart(iii, 10)
    h = chart(iii, 11)
    i = chart(iii, 12)
    j = chart(iii, 13)
    k = chart(iii, 14)
    l = chart(iii, 15)
    m = chart(iii, 16)
    n = chart(iii, 17)
    o = chart(iii, 18)
    p = chart(iii, 19)
    q = chart(iii, 20)
    r = chart(iii, 21)
    s = chart(iii, 22)
    t = chart(iii, 23)
    PRINT USING "## ## ####  ## ## ## ## ##"; month; day; year; a; b; c; d; e
    PRINT USING "            ## ## ## ## ##"; f; g; h; i; j
    PRINT USING "            ## ## ## ## ##"; k; l; m; n; o
    PRINT USING "            ## ## ## ## ##"; p; q; r; s; t
    PRINT
    PRINT "--------------------------"
    PRINT
NEXT iii


CLOSE #2
CLOSE #1
GOTO fini
build:
RETURN
reverse:
RETURN
fini:
END



