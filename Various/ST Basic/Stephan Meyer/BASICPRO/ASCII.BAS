1     ' *****************************
2     ' *                           *
3     ' *         a s c i i         *
4     ' *                           *
5     ' * Alle Zeichen des ATARI-ST *
6     ' *     + PUBLIC DOMAIN +     *
7     ' *            by             *
8     ' *                           *
9     ' *       Stephan Meyer       *
10    '*                           *
11    '*****************************
15    closew 3
20    fullw 2:clearw 2
30    for x=0 to 139
40    f=x/20
50    gotoxy int(f)*5+2,(f-int(f))*19
60    ?x;chr$(x)
70    next x
80    e$=chr$(inp(2))
90    clearw 2
100   for x=140 to 255
110   f=(x-139)/20
120   gotoxy int(f)*5+2,(f-int(f))*19
130   ?x;chr$(x)
140   next x
150   e$=chr$(inp(2))
