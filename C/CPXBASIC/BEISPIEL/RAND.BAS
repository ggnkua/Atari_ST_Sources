10   REM Teste den Zufallszahlengenerator
20   a=0:b=0:c=1:i=0:j=0:p=0:t=PEEKL $4BA:u=t
30   WHILE
40     i=i+1
50     a=RAND:IF a>b THEN b=a:p=1
60     IF a<c THEN c=a:p=1
70     IF p=0 THEN 40
80     USING 8,14
90     PRINT c,1-b:z=PEEKL $4BA
100    USING 0,5:PRINT i;:USING 3,6:PRINT(z-t)*5/i,(z-u)*5/(i-j):j=i:u=z
110    PRINT:p=0
120  WEND
