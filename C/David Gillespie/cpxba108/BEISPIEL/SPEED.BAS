10  a=2000
20  t=PEEKL $4BA
30  FOR i=1 TO a
40    x=SIN i
50  NEXT
60  t1=PEEKL $4BA
70  PRINT t1-t
