10   REM Ein kleines VT-52 Terminal
20   USING$,-16:USING 0,1
30   WHILE
40     CLS:PRINT 'šber welche Schnittstelle':PRINT 'wollen Sie arbeiten?':PRINT
50     PRINT 'MIDI',0
60     PRINT 'AUX',1
70     PRINT 'Modem 1',2
80     PRINT 'Modem 2',3
90     PRINT 'Seriell 1',4
100    PRINT 'Seriell 2',5
110    PRINT
120    INPUT a
130  WEND a>=0 AND a<=5
140  DIM dev$(5):dev$(0)='MIDI':dev$(1)='AUX':dev$(2)='MOD1'
150  dev$(3)='MOD2':dev$(4)='SER1':dev$(5)='SER2'
160  USING$
170  WHILE
180    WHILE
190      key=ASC INKEY$:in=INBYTE dev$(a)
200    WEND key<>0 OR in>=0
210    IF key=27 OR in=27 THEN END
220    IF key=0 THEN 260
230    WHILE OUTBYTE dev$(a),key<>0:WEND
240    IF key=13 THEN key=10
250    PRINT CHR$ key;
260    IF in<=0 THEN 290
270    IF in=13 THEN in=10
280    PRINT CHR$ in;
290  WEND
