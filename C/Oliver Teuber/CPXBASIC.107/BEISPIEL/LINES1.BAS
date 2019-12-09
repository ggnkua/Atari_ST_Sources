10   REM Nochmal just for fun: Zeichne Linien, aber anders
20   USING$:CLS:PRINT CHR$(27),'f':FOR i=1 TO 25:PRINT:NEXT
30   x1=RAND 256:x2=RAND 256:y1=RAND 176:y2=RAND 176
40   xf1=1:yf1=1:xf2=1:yf2=1
50   WHILE
60     PRINT
70     LINE x1,y1,x2,y2
80     x1=x1+RAND 9*xf1:y1=y1+RAND 9*yf1
90     IF x1<0 THEN xf1=1:x1=0
100    IF y1<0 THEN yf1=1:y1=0
110    IF x1>255 THEN xf1=-1:x1=255
120    IF y1>175 THEN yf1=-1:y1=175
130    x2=x2+RAND 7*xf2:y2=y2+RAND 7*yf2
140    IF x2>255 THEN xf2=-1:x2=255
150    IF y2>175 THEN yf2=-1:y2=175
160    IF x2<0 THEN xf2=1:x2=0
170    IF y2<0 THEN yf2=1:y2=0
180  WEND INKEY$=CHR$ 27
190  CLS:PRINT CHR$(27),'e'
