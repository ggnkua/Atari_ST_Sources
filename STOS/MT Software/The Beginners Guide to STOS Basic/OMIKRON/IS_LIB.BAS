63000 END ' Isam-Library. Stand 23.02.87
63001 DEF PROC Is_Open(Handle,Is_Name$,Laenge,Filenr,Anzahl)
63005 Is_Namtest: DIM Is_Such$(1):Is_Fnr(Handle)=Filenr:Is_Nam$(Handle)=Is_Name$
63010 Is_Anz(Handle)=Anzahl:Is_Rcl(Handle)=Laenge:Is_Open: RETURN
63015 '
63020 DEF PROC Is_Close(Handle)
63025 Is_Close: RETURN
63030 '
63035 DEF PROC Is_Update(Handle)
63040 Is_Close:Is_Open: RETURN
63045 '
63050 DEF PROC Is_Backup(Is_Von$,Is_Nach$,Is_Name$,Anzahl): LOCAL I
63055 Is_Namtest:Is_Von$=Is_Von$+Is_Name$:Is_Nach$=Is_Nach$+Is_Name$
63060 COPY Is_Von$+".DAT" TO Is_Nach$+".BAK"
63065 FOR I=1 TO Anzahl
63070 COPY Is_Von$+FN Is_Index$(I) TO Is_Nach$+".B"+ RIGHT$( STR$(100+I),2)
63075 NEXT : RETURN
63080 '
63085 DEF PROC Is_Kill(Is_Von$,Is_Name$,Anzahl): LOCAL I
63090 Is_Namtest:Is_Von$=Is_Von$+Is_Name$: KILL Is_Von$+".DAT"
63095 FOR I=1 TO Anzahl: KILL Is_Von$+FN Is_Index$(I): NEXT : RETURN
63100 '
63105 DEF FN Is_Index$(I)=".I"+ RIGHT$( STR$(100+I),2)
63110 '
63115 DEF PROC Is_Namtest
63120 IF INSTR(Is_Name$,".") OR INSTR(Is_Name$,"*") OR INSTR(Is_Name$,"?") THEN ERROR 64 ELSE RETURN
63125 '
63130 DEF PROC Is_Open: LOCAL I,Filenr=Is_Fnr(Handle)
63135 OPEN "R",Filenr,Is_Nam$(Handle)+".DAT",Is_Rcl(Handle): FOR I=1 TO Is_Anz(Handle)
63140 OPEN "R",Filenr+I,Is_Nam$(Handle)+FN Is_Index$(I),2+Is_Len(Handle,I): NEXT
63145 FIELD Filenr,6 AS Is_$: GET Is_Fnr(Handle),1
63150 IF EOF(Filenr) THEN LSET Is_$= MKIL$($20002)+ MKI$(0)
63155 Is_Next(Handle)= CVI(Is_$):Is_Free(Handle)= CVI( MID$(Is_$,3)):Is_Size(Handle)= CVI( MID$(Is_$,5))
63160 ON Handle GOTO Is_1,Is_2,Is_3,Is_4,Is_5,Is_6,Is_7,Is_8,Is_9,Is_10
63200-Is_0
63205 FIELD Is_Fnr(0),0
63210 '
63215 '
63220 RETURN
63225-Is_1
63230 FIELD Is_Fnr(1),0
63235 '
63240 '
63245 RETURN
63250-Is_2
63255 FIELD Is_Fnr(2),0
63260 '
63265 '
63270 RETURN
63275-Is_3
63280 FIELD Is_Fnr(3),0
63285 '
63290 '
63295 RETURN
63300-Is_4
63305 FIELD Is_Fnr(4),0
63310 '
63315 '
63320 RETURN
63325-Is_5
63330 FIELD Is_Fnr(5),0
63335 '
63340 '
63345 RETURN
63350-Is_6
63355 FIELD Is_Fnr(6),0
63360 '
63365 '
63370 RETURN
63375-Is_7
63380 FIELD Is_Fnr(7),0
63385 '
63390 '
63395 RETURN
63400-Is_8
63405 FIELD Is_Fnr(8),0
63410 '
63415 '
63420 RETURN
63425-Is_9
63430 FIELD Is_Fnr(9),0
63435 '
63440 '
63445 RETURN
63450-Is_10
63455 FIELD Is_Fnr(10),0
63460 '
63465 '
63470 RETURN
63475 '
63480 DEF PROC Is_Close: LOCAL I
63485 FOR I=0 TO Is_Anz(Handle): CLOSE Is_Fnr(Handle)+I: NEXT : RETURN
63490 '
63495 DEF PROC Is_Entry(Handle,Nr,Position,Laenge,Typ)
63500 Is_Len(Handle,Nr)=Laenge:Is_Pos(Handle,Nr)=Position:Is_Typ(Handle,Nr)=Typ: RETURN
63505 '
63510 DEF PROC Is_Insert(Handle): LOCAL Filenr=Is_Fnr(Handle),I,Von,Bis,Mitte,R
63515 FIELD Filenr,Is_Rcl(Handle) AS Is_Field$:Is_Field2$=Is_Field$
63520 R=Is_Free(Handle): IF R=Is_Next(Handle) THEN
63525 Is_Free(Handle)=R+1:Is_Next(Handle)=R+1 ELSE
63530 GET Filenr,R:Is_Free(Handle)= CVI(Is_Field$): LSET Is_Field$=Is_Field2$
63535 ENDIF PUT Filenr,R
63537 FOR I=1 TO Is_Anz(Handle):Is_Rec$= MKI$(R)+ MID$(Is_Field2$,Is_Pos(Handle,I)+1,Is_Len(Handle,I))
63540 LSET Is_Field$=Is_Field2$:Is_Search:Is_Move(Mitte,Is_Size(Handle)+1)
63550 NEXT :Is_Size(Handle)=Is_Size(Handle)+1:Is_Update_Len: RETURN
63555 '
63560 DEF PROC Is_Replace(Handle,Old): LOCAL Filenr=Is_Fnr(Handle),I,Von,Bis,Mitte,Mitte2,R
63565 FIELD Filenr,Is_Rcl(Handle) AS Is_Field$:Is_Field2$=Is_Field$
63570 GET Filenr,Old:Is_Field3$=Is_Field$
63575 FOR I=1 TO Is_Anz(Handle)
63580 LSET Is_Field$=Is_Field3$:Is_Search: WHILE CVI(Is_$)<>Old:Mitte=Mitte+1: GET Filenr+I,Mitte: WEND
63585 Mitte2=Mitte: LSET Is_Field$=Is_Field2$:Is_Search:Mitte=Mitte+(Mitte>Mitte2)
63590 IF Mitte<>Mitte2 THEN :Is_Rec$= MKI$(Old)+ MID$(Is_Field2$,Is_Pos(Handle,I)+1,Is_Len(Handle,I))
63595 Is_Move(Mitte,Mitte2) ENDIF NEXT : LSET Is_Field$=Is_Field2$: PUT Filenr,Old: RETURN
63605 '
63610 DEF PROC Is_Delete(Handle,Old): LOCAL Filenr=Is_Fnr(Handle),I,Von,Bis,Mitte,Is_Rec$,Is_T$
63615 FIELD Filenr,Is_Rcl(Handle) AS Is_Field$: GET Filenr,Old:Is_Field2$=Is_Field$
63620 FOR I=1 TO Is_Anz(Handle)
63625 LSET Is_Field$=Is_Field2$:Is_Search: WHILE CVI(Is_$)<>Old:Mitte=Mitte+1: GET Filenr+I,Mitte: WEND
63630 Is_Rec$= CHR$(0)*(Is_Len(Handle,I)+1+1):Is_Move(Is_Size(Handle),Mitte)
63640 NEXT : LSET Is_Field$= MKI$(Is_Free(Handle)): PUT Filenr,Old:Is_Free(Handle)=Old
63645 Is_Size(Handle)=Is_Size(Handle)-1:Is_Update_Len: RETURN
63650 '
63655 DEF PROC Is_Update_Len
63660 FIELD Filenr,6 AS Is_Field$
63665 LSET Is_Field$= MKI$(Is_Next(Handle))+ MKI$(Is_Free(Handle))+ MKI$(Is_Size(Handle))
63670 PUT Filenr,1: RETURN
63675 '
63680 DEF PROC Is_Search: LOCAL Flag
63685 FIELD Filenr,Is_Pos(Handle,I),Is_Len(Handle,I) AS Is_Such$:Is_Such2$=Is_Such$
63690 Von=1:Bis=Is_Size(Handle): FIELD Filenr+I,2,Is_Len(Handle,I) AS Is_$
63695 WHILE Von<=Bis:Mitte=(Von+Bis) SHR 1: GET Filenr+I,Mitte
63700 ON Is_Typ(Handle,I) GOTO Is_Search1,Is_Search2
63705 Flag=Is_Such2$>Is_$: GOTO Is_Search3
63710-Is_Search1:Is_Such$(0)=Is_Such2$:Is_Such$(1)=Is_$: SORT Is_Such$(0)
63715 Flag=Is_Such$(0)<>Is_Such2$: GOTO Is_Search3
63720-Is_Search2:Flag= VAL(Is_Such2$)> VAL(Is_$)
63725-Is_Search3: IF Flag THEN Von=Mitte+1 ELSE Bis=Mitte-1
63730 WEND :Mitte=Von: GET Filenr+I,Mitte: FIELD Filenr+I,2 AS Is_$: RETURN
63735 '
63740 DEF PROC Is_Search(Handle,I,R R): LOCAL Filenr=Is_Fnr(Handle),Von,Bis,Mitte
63745 IF I=-1 THEN Mitte=Is_Last(Handle)-1
63750 IF I=0 THEN Mitte=Is_Last(Handle)+1
63755 IF I>0 THEN Is_Lasti(Handle)=I:Is_Search
63760 R=Mitte: IF R=0 THEN Mitte=1 ELSE IF R>Is_Size(Handle) THEN Mitte=Is_Size(Handle):R=0
63765 I=Is_Lasti(Handle):Is_Last(Handle)=Mitte
63770 IF R THEN GET Filenr+I,R: FIELD Filenr+I,2 AS Is_$:R= CVI(Is_$) ENDIF RETURN
63780 '
63790 DEF PROC Is_Move(Von,Bis): LOCAL Filenr=Filenr+I,R1,R2,L=Is_Len(Handle,I)+1+1,P
63800 IF ABS(Von-Bis)>100 THEN
63810 CLOSE Filenr: OPEN "R",Filenr,Is_Nam$(Handle)+FN Is_Index$(I),L*50
63820 FIELD Filenr,L*50 AS Is_$:R1=(Von-1)\50+1:R2=(Bis-1)\50+1
63830 P=((Von-1) MOD 50)*L: GET Filenr,R1
63840 IF Von<Bis THEN
63850 Is_Such2$= LEFT$(Is_$,P)+Is_Rec$+ MID$(Is_$,P+1)
63860 WHILE R1<R2: LSET Is_$=Is_Such2$: PUT Filenr,R1:R1=R1+1: GET Filenr,R1:Is_Such2$= RIGHT$(Is_Such2$,L)+Is_$: WEND
63870 P=((Bis-1) MOD 50)*L
63880 LSET Is_$= LEFT$(Is_Such2$,P+L)+ MID$(Is_Such2$,P+L*2+1): PUT Filenr,R2
63890 ELSE
63900 Is_Such2$= LEFT$(Is_$,P+L)+Is_Rec$+ MID$(Is_$,P+L+1)
63910 WHILE R1>R2: RSET Is_$=Is_Such2$: PUT Filenr,R1:R1=R1-1: GET Filenr,R1:Is_Such2$=Is_$+ LEFT$(Is_Such2$,L): WEND
63920 P=((Bis-1) MOD 50)*L
63930 LSET Is_$= LEFT$(Is_Such2$,P)+ MID$(Is_Such2$,P+L+1): PUT Filenr,R2
63940 ENDIF
63950 CLOSE Filenr: OPEN "R",Filenr,Is_Nam$(Handle)+FN Is_Index$(I),L
63960 ELSE
63970 FIELD Filenr,L AS Is_$: FOR R1=Von TO Bis STEP SGN(Bis-Von+.1)
63980 GET Filenr,R1:Is_Such$=Is_$: LSET Is_$=Is_Rec$: PUT Filenr,R1: SWAP Is_Such$,Is_Rec$: NEXT
63990 ENDIF RETURN
