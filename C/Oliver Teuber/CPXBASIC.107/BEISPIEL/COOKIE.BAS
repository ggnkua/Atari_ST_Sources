10   REM Ausgabe des Cookie-Jar
20   CLS:USING$:FPRINT:FPRINT 'The cookie-jar':FPRINT:USING$,-5:USING
30   cookie=PEEKL $5A0
40   WHILE PEEKL cookie<>0
50     k=k+1
60     a$='':FOR i=0 TO 3:a$=a$+CHR$ PEEK(cookie+i):NEXT
70     FPRINT a$,HEX$ PEEKL(cookie+4)
80     cookie=cookie+8
90   WEND
100  FPRINT:j=PEEKL(cookie+4):FPRINT 'entries: ',j,'used: ',k,'free: ',j-k
110  FPRINT:END
