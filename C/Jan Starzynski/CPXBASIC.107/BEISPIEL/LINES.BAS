10   REM Just for fun: Zeichne Linien
20   USING$:CLS:PRINT CHR$(27),'f':FOR i=1 TO 25:PRINT:NEXT
30   x1=RAND 256:x2=RAND 256:y1=RAND 176:y2=RAND 176
40   xf1=1:yf1=1:xf2=1:yf2=1:t1=PEEKL $4BA:t2=t1
50   WHILE
60     t=PEEKL $4BA
70     IF t>t1 THEN t1=t+500:PRINT:y1=y1+8:y2=y2+8
80     IF t>t2 THEN t2=t+40 ELSE 200
90     LINE x1,y1,x2,y2
100    x1=x1+RAND 9*xf1:y1=y1+RAND 9*yf1
110    IF x1<0 THEN xf1=1:x1=0
120    IF y1<0 THEN yf1=1:y1=0
130    IF x1>255 THEN xf1=-1:x1=255
140    IF y1>175 THEN yf1=-1:y1=175
150    x2=x2+RAND 7*xf2:y2=y2+RAND 7*yf2
160    IF x2>255 THEN xf2=-1:x2=255
170    IF y2>175 THEN yf2=-1:y2=175
180    IF x2<0 THEN xf2=1:x2=0
190    IF y2<0 THEN yf2=1:y2=0
200  WEND INKEY$=CHR$ 27
210  CLS:PRINT CHR$(27),'e'
