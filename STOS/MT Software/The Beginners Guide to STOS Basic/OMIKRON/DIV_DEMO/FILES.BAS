100 Dir("a:\"): END
1000 DEF PROC Dir:Dir(""): RETURN
1010 DEF PROC Dir(Path$): LOCAL Att$,Tim$,Dat$,Len$,Name$:Dir(Path$,0): RETURN
1020 DEF PROC Dir(Path$,Level): LOCAL F_Nr=16-Level
1030    OPEN "F",F_Nr,Path$+"*.*",63
1040    REPEAT
1050       GET F_Nr,1: IF EOF(F_Nr) THEN EXIT
1060       FIELD F_Nr,21,1 AS Att$,2 AS Tim$,2 AS Dat$,4 AS Len$,14 AS Name$
1070       PRINT TAB (Level*2);:Name$= LEFT$(Name$, INSTR(Name$, CHR$(0))-1)
1080       IF Name$<>"." AND Name$<>".." THEN
1090          PRINT LEFT$(Name$+ SPC(12),12);
1100          PRINT USING "    ###.###.###    "; CVIL(Len$);
1110          PRINT FN Tim$( CVI(Tim$));"    ";FN Dat$( CVI(Dat$));"    ";
1120          FOR I=0 TO 5
1130             IF BIT(I, ASC(Att$)) THEN
1140                PRINT MID$("R/OHIDSYSVOLSUBCLO",I*3+1,3);" ";
1150             ENDIF
1160          NEXT I
1170          PRINT
1180          IF BIT(4, ASC(Att$)) THEN Dir(Path$+Name$+"\",Level+1)
1190       ENDIF
1200    UNTIL 0
1210    CLOSE F_Nr
1220 RETURN
1230 DEF FN Tim$(X)=FN Xx$(X SHR 11 AND 31)+":"+FN Xx$(X SHR 5 AND 63)+":"+FN Xx$(X AND 31)
1240 DEF FN Dat$(X)=FN Xx$(X AND 31)+"."+FN Xx$(X SHR 5 AND 15)+"."+ RIGHT$( STR$((X SHR 9 AND 127)+1980),4)
1250 DEF FN Xx$(X)= RIGHT$( STR$(100+X),2)
