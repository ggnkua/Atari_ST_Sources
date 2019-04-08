DIM chart(300000, 23)
DIM chart2(300000, 23)

OPEN "keno midday.dat" FOR INPUT AS #1
OPEN "kenomidday.dat" FOR OUTPUT AS #2
DO UNTIL EOF(1)
    INPUT #1, month, day, year, a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t

    chart(linecounter, 1) = month
    chart(linecounter, 2) = day
    chart(linecounter, 3) = year
    chart(linecounter, 4) = a
    chart(linecounter, 5) = b
    chart(linecounter, 6) = c
    chart(linecounter, 7) = d
    chart(linecounter, 8) = e
    chart(linecounter, 9) = f
    chart(linecounter, 10) = g
    chart(linecounter, 11) = h
    chart(linecounter, 12) = i
    chart(linecounter, 13) = j
    chart(linecounter, 14) = k
    chart(linecounter, 15) = l
    chart(linecounter, 16) = m
    chart(linecounter, 17) = n
    chart(linecounter, 18) = o
    chart(linecounter, 19) = p
    chart(linecounter, 20) = q
    chart(linecounter, 21) = r
    chart(linecounter, 22) = s
    chart(linecounter, 23) = t
    linecounter = linecounter + 1
LOOP
CLOSE #1

FOR iii = linecounter TO 1 STEP -1
    linecounter2 = linecounter2 + 1
    month = chart2(linecounter2, 1)
    day = chart2(linecounter2, 2)
    year = chart2(linecounter2, 3)
    a = chart2(linecounter2, 4)
    b = chart2(linecounter2, 5)
    c = chart2(linecounter2, 6)
    d = chart2(linecounter2, 7)
    e = chart2(linecounter2, 8)
    f = chart2(linecounter2, 9)
    g = chart2(linecounter2, 10)
    h = chart2(linecounter2, 11)
    i = chart2(linecounter2, 12)
    j = chart2(linecounter2, 13)
    k = chart2(linecounter2, 14)
    l = chart2(linecounter2, 15)
    m = chart2(linecounter2, 16)
    n = chart2(linecounter2, 17)
    o = chart2(linecounter2, 18)
    p = chart2(linecounter2, 19)
    q = chart2(linecounter2, 20)
    r = chart2(linecounter2, 21)
    s = chart2(linecounter2, 22)
    t = chart2(linecounter2, 23)
    pattern$ = "## ## #### ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##"
    PRINT #2, USING pattern$; month, day, year, a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t
    PRINT "Converting Line # "; linecounter2
NEXT iii




