63000 END ' Isam-Library. Stand 05.07.88
63001 DEF PROC Is_Open(Handle%L,Is_Name$,Laenge%L,Filenr%L,Anzahl%L)
63005 Is_Namtest: DIM Is_Such$(1):Is_Fnr%L(Handle%L)=Filenr%L:Is_Nam$(Handle%L)=Is_Name$
63010 Is_Anz%L(Handle%L)=Anzahl%L:Is_Rcl%L(Handle%L)=Laenge%L:Is_Open: RETURN
63015 '
63020 DEF PROC Is_Close(Handle%L)
63025 Is_Close: RETURN
63030 '
63035 DEF PROC Is_Update(Handle%L)
63040 Is_Close:Is_Open: RETURN
63045 '
63050 DEF PROC Is_Backup(Is_Von$,Is_Nach$,Is_Name$,Anzahl%L): LOCAL I%L
63055 Is_Namtest:Is_Von$=Is_Von$+Is_Name$:Is_Nach$=Is_Nach$+Is_Name$
63060 COPY Is_Von$+".DAT" TO Is_Nach$+".BAK"
63065 FOR I%L=1 TO Anzahl%L
63070 COPY Is_Von$+FN Is_Index$(I%L) TO Is_Nach$+".B"+ RIGHT$( STR$(100+I%L),2)
63075 NEXT : RETURN
63080 '
63085 DEF PROC Is_Kill(Is_Von$,Is_Name$,Anzahl%L): LOCAL I%L
63090 Is_Namtest:Is_Von$=Is_Von$+Is_Name$: KILL Is_Von$+".DAT"
63095 FOR I%L=1 TO Anzahl%L: KILL Is_Von$+FN Is_Index$(I%L): NEXT : RETURN
63100 '
63105 DEF FN Is_Index$(I%L)=".I"+ RIGHT$( STR$(100+I%L),2)
63110 '
63115 DEF PROC Is_Namtest
63120 IF INSTR(Is_Name$,".") OR INSTR(Is_Name$,"*") OR INSTR(Is_Name$,"?") THEN ERROR 64 ELSE RETURN
63125 '
63130 DEF PROC Is_Open: LOCAL I%L,Filenr%L=Is_Fnr%L(Handle%L)
63135 OPEN "R",Filenr%L,Is_Nam$(Handle%L)+".DAT",Is_Rcl%L(Handle%L): FOR I%L=1 TO Is_Anz%L(Handle%L)
63140 OPEN "R",Filenr%L+I%L,Is_Nam$(Handle%L)+FN Is_Index$(I%L),2+Is_Len%L(Handle%L,I%L): NEXT
63145 FIELD Filenr%L,6 AS Is_$: GET Is_Fnr%L(Handle%L),1
63150 IF EOF(Filenr%L) THEN LSET Is_$= MKIL$($20002)+ MKI$(0)
63155 Is_Next%L(Handle%L)= CVI(Is_$):Is_Free%L(Handle%L)= CVI( MID$(Is_$,3)):Is_Size%L(Handle%L)= CVI( MID$(Is_$,5))
63160 ON Handle%L GOTO Is_1,Is_2,Is_3,Is_4,Is_5,Is_6,Is_7,Is_8,Is_9,Is_10
63200-Is_0
63205 FIELD Is_Fnr%L(0),0
63210 '
63215 '
63220 RETURN
63225-Is_1
63230 FIELD Is_Fnr%L(1),0
63235 '
63240 '
63245 RETURN
63250-Is_2
63255 FIELD Is_Fnr%L(2),0
63260 '
63265 '
63270 RETURN
63275-Is_3
63280 FIELD Is_Fnr%L(3),0
63285 '
63290 '
63295 RETURN
63300-Is_4
63305 FIELD Is_Fnr%L(4),0
63310 '
63315 '
63320 RETURN
63325-Is_5
63330 FIELD Is_Fnr%L(5),0
63335 '
63340 '
63345 RETURN
63350-Is_6
63355 FIELD Is_Fnr%L(6),0
63360 '
63365 '
63370 RETURN
63375-Is_7
63380 FIELD Is_Fnr%L(7),0
63385 '
63390 '
63395 RETURN
63400-Is_8
63405 FIELD Is_Fnr%L(8),0
63410 '
63415 '
63420 RETURN
63425-Is_9
63430 FIELD Is_Fnr%L(9),0
63435 '
63440 '
63445 RETURN
63450-Is_10
63455 FIELD Is_Fnr%L(10),0
63460 '
63465 '
63470 RETURN
63475 '
63480 DEF PROC Is_Close: LOCAL I%L
63485 FOR I%L=0 TO Is_Anz%L(Handle%L): CLOSE Is_Fnr%L(Handle%L)+I%L: NEXT : RETURN
63490 '
63495 DEF PROC Is_Entry(Handle%L,Nr%L,Position%L,Laenge%L,Typ%L)
63500 Is_Len%L(Handle%L,Nr%L)=Laenge%L:Is_Pos%L(Handle%L,Nr%L)=Position%L:Is_Typ%L(Handle%L,Nr%L)=Typ%L: RETURN
63505 '
63510 DEF PROC Is_Insert(Handle%L): LOCAL Filenr%L=Is_Fnr%L(Handle%L),I%L,Von%L,Bis%L,Mitte%L,R%L
63515 FIELD Filenr%L,Is_Rcl%L(Handle%L) AS Is_Field$:Is_Field2$=Is_Field$
63520 R%L=Is_Free%L(Handle%L): IF R%L=Is_Next%L(Handle%L) THEN
63525 Is_Free%L(Handle%L)=R%L+1:Is_Next%L(Handle%L)=R%L+1 ELSE
63530 GET Filenr%L,R%L:Is_Free%L(Handle%L)= CVI(Is_Field$): LSET Is_Field$=Is_Field2$
63535 ENDIF PUT Filenr%L,R%L
63540 FOR I%L=1 TO Is_Anz%L(Handle%L):Is_Rec$= MKI$(R%L)+ MID$(Is_Field2$,Is_Pos%L(Handle%L,I%L)+1,Is_Len%L(Handle%L,I%L))
63545 LSET Is_Field$=Is_Field2$:Is_Search:Is_Move(Mitte%L,Is_Size%L(Handle%L)+1)
63550 NEXT :Is_Size%L(Handle%L)=Is_Size%L(Handle%L)+1:Is_Update_Len: RETURN
63555 '
63560 DEF PROC Is_Replace(Handle%L,Old%L): LOCAL Filenr%L=Is_Fnr%L(Handle%L),I%L,Von%L,Bis%L,Mitte%L,Mitte2%L,R%L
63565 FIELD Filenr%L,Is_Rcl%L(Handle%L) AS Is_Field$:Is_Field2$=Is_Field$
63570 GET Filenr%L,Old%L:Is_Field3$=Is_Field$
63575 FOR I%L=1 TO Is_Anz%L(Handle%L)
63580 LSET Is_Field$=Is_Field3$:Is_Search: WHILE CVI(Is_$)<>Old%L:Mitte%L=Mitte%L+1: GET Filenr%L+I%L,Mitte%L: WEND
63585 Mitte2%L=Mitte%L: LSET Is_Field$=Is_Field2$:Is_Search:Mitte%L=Mitte%L+(Mitte%L>Mitte2%L)
63590 Is_Rec$= MKI$(Old%L)+ MID$(Is_Field2$,Is_Pos%L(Handle%L,I%L)+1,Is_Len%L(Handle%L,I%L)):Is_Move(Mitte%L,Mitte2%L)
63595 NEXT : LSET Is_Field$=Is_Field2$: PUT Filenr%L,Old%L: RETURN
63600 '
63605 DEF PROC Is_Delete(Handle%L,Old%L): LOCAL Filenr%L=Is_Fnr%L(Handle%L),I%L,Von%L,Bis%L,Mitte%L,Is_Rec$,Is_T$
63610 FIELD Filenr%L,Is_Rcl%L(Handle%L) AS Is_Field$: GET Filenr%L,Old%L:Is_Field2$=Is_Field$
63615 FOR I%L=1 TO Is_Anz%L(Handle%L)
63620 LSET Is_Field$=Is_Field2$:Is_Search: WHILE CVI(Is_$)<>Old%L:Mitte%L=Mitte%L+1: GET Filenr%L+I%L,Mitte%L: WEND
63625 Is_Rec$= CHR$(0)*(Is_Len%L(Handle%L,I%L)+1+1):Is_Move(Is_Size%L(Handle%L),Mitte%L)
63630 NEXT : LSET Is_Field$= MKI$(Is_Free%L(Handle%L)): PUT Filenr%L,Old%L:Is_Free%L(Handle%L)=Old%L
63635 Is_Size%L(Handle%L)=Is_Size%L(Handle%L)-1:Is_Update_Len: RETURN
63640 '
63645 DEF PROC Is_Update_Len
63650 FIELD Filenr%L,6 AS Is_Field$
63655 LSET Is_Field$= MKI$(Is_Next%L(Handle%L))+ MKI$(Is_Free%L(Handle%L))+ MKI$(Is_Size%L(Handle%L))
63660 PUT Filenr%L,1: RETURN
63665 '
63670 DEF PROC Is_Search: LOCAL Flag%L
63675 FIELD Filenr%L,Is_Pos%L(Handle%L,I%L),Is_Len%L(Handle%L,I%L) AS Is_Such$:Is_Such2$=Is_Such$
63680 Von%L=1:Bis%L=Is_Size%L(Handle%L): FIELD Filenr%L+I%L,2,Is_Len%L(Handle%L,I%L) AS Is_$
63685 WHILE Von%L<=Bis%L:Mitte%L=(Von%L+Bis%L) SHR 1: GET Filenr%L+I%L,Mitte%L
63690 ON Is_Typ%L(Handle%L,I%L) GOTO Is_Search1,Is_Search2
63695 Flag%L=Is_Such2$>Is_$: GOTO Is_Search3
63700-Is_Search1:Is_Such$(0)=Is_Such2$:Is_Such$(1)=Is_$: SORT Is_Such$(0)
63705 Flag%L=Is_Such$(0)<>Is_Such2$: GOTO Is_Search3
63710-Is_Search2:Flag%L= VAL(Is_Such2$)> VAL(Is_$)
63715-Is_Search3: IF Flag%L THEN Von%L=Mitte%L+1 ELSE Bis%L=Mitte%L-1
63720 WEND :Mitte%L=Von%L: GET Filenr%L+I%L,Mitte%L: FIELD Filenr%L+I%L,2 AS Is_$: RETURN
63725 '
63730 DEF PROC Is_Search(Handle%L,I%L,R R%L): LOCAL Filenr%L=Is_Fnr%L(Handle%L),Von%L,Bis%L,Mitte%L
63735 IF I%L=-1 THEN Mitte%L=Is_Last%L(Handle%L)-1
63740 IF I%L=0 THEN Mitte%L=Is_Last%L(Handle%L)+1
63745 IF I%L>0 THEN Is_Lasti%L(Handle%L)=I%L:Is_Search
63750 R%L=Mitte%L: IF R%L=0 THEN Mitte%L=1 ELSE IF R%L>Is_Size%L(Handle%L) THEN Mitte%L=Is_Size%L(Handle%L):R%L=0
63755 I%L=Is_Lasti%L(Handle%L):Is_Last%L(Handle%L)=Mitte%L
63760 IF R%L THEN GET Filenr%L+I%L,R%L: FIELD Filenr%L+I%L,2 AS Is_$:R%L= CVI(Is_$) ENDIF RETURN
63765 '
63770 DEF PROC Is_Move(Von%L,Bis%L): LOCAL Filenr%L=Filenr%L+I%L,R1%L,R2%L,L%L=Is_Len%L(Handle%L,I%L)+1+1,P%L
63775 IF ABS(Von%L-Bis%L)>100 THEN
63780 CLOSE Filenr%L: OPEN "R",Filenr%L,Is_Nam$(Handle%L)+FN Is_Index$(I%L),L%L*50
63785 FIELD Filenr%L,L%L*50 AS Is_$:R1%L=(Von%L-1)\50+1:R2%L=(Bis%L-1)\50+1
63790 P%L=((Von%L-1) MOD 50)*L%L: GET Filenr%L,R1%L
63795 IF Von%L<Bis%L THEN
63800 Is_Such2$= LEFT$(Is_$,P%L)+Is_Rec$+ MID$(Is_$,P%L+1)
63805 WHILE R1%L<R2%L: LSET Is_$=Is_Such2$: PUT Filenr%L,R1%L:R1%L=R1%L+1: GET Filenr%L,R1%L:Is_Such2$= RIGHT$(Is_Such2$,L%L)+Is_$: WEND
63810 P%L=((Bis%L-1) MOD 50)*L%L
63815 LSET Is_$= LEFT$(Is_Such2$,P%L+L%L)+ MID$(Is_Such2$,P%L+L%L*2+1): PUT Filenr%L,R2%L
63820 ELSE
63825 Is_Such2$= LEFT$(Is_$,P%L+L%L)+Is_Rec$+ MID$(Is_$,P%L+L%L+1)
63830 WHILE R1%L>R2%L: RSET Is_$=Is_Such2$: PUT Filenr%L,R1%L:R1%L=R1%L-1: GET Filenr%L,R1%L:Is_Such2$=Is_$+ LEFT$(Is_Such2$,L%L): WEND
63835 P%L=((Bis%L-1) MOD 50)*L%L
63840 LSET Is_$= LEFT$(Is_Such2$,P%L)+ MID$(Is_Such2$,P%L+L%L+1): PUT Filenr%L,R2%L
63845 ENDIF
63850 CLOSE Filenr%L: OPEN "R",Filenr%L,Is_Nam$(Handle%L)+FN Is_Index$(I%L),L%L
63855 ELSE
63860 FIELD Filenr%L,L%L AS Is_$: FOR R1%L=Von%L TO Bis%L STEP SGN(Bis%L-Von%L+.1)
63865 GET Filenr%L,R1%L:Is_Such$=Is_$: LSET Is_$=Is_Rec$: PUT Filenr%L,R1%L: SWAP Is_Such$,Is_Rec$: NEXT
63870 ENDIF RETURN
63875 '
63880 DEF PROC Is_Reorg(Handle%L): LOCAL Filenr%L=Is_Fnr%L(Handle%L),I%L,L%L,R%L
63885    IF Is_Size%L(Handle%L)>Is_Reorg%L THEN STOP ' nach is_reorg: CLEAR!
63890    Is_Reorg%L=Is_Size%L(Handle%L):L%L=Is_Next%L(Handle%L)-1:Is_Reorgm%L= MAX(Is_Reorgm%L,L%L)
63895    DIM Is_Reorg$(Is_Reorg%L-1),Is_Reorg#(Is_Reorg%L-1),Is_Reorg%(Is_Reorg%L-1)
63900    DIM Is_Reorg%F(Is_Reorgm%L): FOR I%L=2 TO L%L:Is_Reorg%F(I%L)=1: NEXT
63905    R%L=Is_Free%L(Handle%L): FIELD Filenr%L,2 AS Is_$
63910    WHILE R%L>1 AND R%L<=L%L:Is_Reorg%(R%L)=0: GET Filenr%L,R%L:R%L= CVI(Is_$): WEND
63915    IF R%L<>L%L+1 THEN STOP ' Stammdatei ist quatsch mit Sože
63920    FOR Nr%L=1 TO Is_Anz%L(Handle%L)
63925       I%L=0: FOR R%L=2 TO L%L: IF Is_Reorg%F(R%L) THEN Is_Reorg%(I%L)=R%L:I%L=I%L+1 ENDIF NEXT
63930       IF I%L<>Is_Reorg%L THEN STOP ' Stammdatei ist quatsch mit Sože
63935       FIELD Filenr%L,Is_Pos%L(Handle%L,Nr%L),Is_Len%L(Handle%L,Nr%L) AS Is_$
63940       FOR R%L=0 TO Is_Reorg%L-1: GET Filenr%L,Is_Reorg%(R%L):Is_Reorg$(R%L)=Is_$: NEXT
63945       R%L=Is_Typ%L(Handle%L,Nr%L)
63950       IF R%L=0 THEN SORT ASC Is_Reorg$(0) TO Is_Reorg%(0)
63955       IF R%L=1 THEN SORT Is_Reorg$(0) TO Is_Reorg%(0)
63960       IF R%L=2 THEN FOR I%L=0 TO Is_Reorg%L-1:Is_Reorg#(I%L)= VAL(Is_Reorg$(I%L)+"#"): NEXT
63965       IF R%L=2 THEN SORT Is_Reorg#(0) TO Is_Reorg%(0)
63970       FIELD Filenr%L+Nr%L,Is_Len%L(Handle%L,Nr%L)+2 AS Is_$
63975       FOR R%L=0 TO Is_Reorg%L-1: LSET Is_$= MKI$(Is_Reorg%(R%L))+Is_Reorg$(R%L): PUT Filenr%L+Nr%L,R%L+1: NEXT
63980    NEXT Nr%L
63985 RETURN
