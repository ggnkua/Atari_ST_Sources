10   REM Ausgabe einer Ascii-Tabelle
20   USING$:CLS
30   FPRINT '  ',:FOR i=0 TO $F:FPRINT MID$(HEX$ i,2);:NEXT
40   FPRINT:FPRINT
50   FOR i=2 TO $F
60     FPRINT MID$(HEX$ i,2),' ';
70     FOR j=0 TO $F
80       FPRINT CHR$(i*16+j);
90     NEXT
100    FPRINT
110  NEXT
120  END
