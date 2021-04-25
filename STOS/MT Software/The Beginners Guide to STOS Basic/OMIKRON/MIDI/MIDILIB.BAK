61000 END
61002 ' MIDI - Library V2.1 (Stand 12.3.1988)
61004 ' written 1986 by HAB
61006 ' (c) 1987 by OMIKRON.
61008 '
61010 ' Hardware-Definitionen
61012 '
61014 DEF FN Midi_Is
61016    LOCAL Stat
61018    BIOS (Stat,1,3)
61020 RETURN Stat
61022 '
61024 DEF PROC Wt_Midi
61026    REPEAT UNTIL FN Midi_Is
61028 RETURN
61030 '
61032 DEF FN Midi_Inp' wartet nicht
61034    IF FN Midi_Is THEN RETURN FN Midi_In ELSE RETURN -1
61036 '
61038 DEF FN Midi_In' wartet auf Zeichen
61040    LOCAL X
61042    BIOS (X,2,3)
61044 RETURN X AND $FF
61046 '
61048 DEF PROC Midi_Out(Char)
61050    BIOS (,3,3,Char)
61052 RETURN
61054 '
61056 DEF PROC Midi_Ws(S$)
61058    PRINT #16,S$;
61060 RETURN
61062 '
61064 DEF PROC Clr_In
61066    LOCAL X
61068    WHILE FN Midi_Is:X=FN Midi_In: WEND
61070 RETURN
61072 '
61074 ' MIDI-Software-Definitionen
61076 '
61078 DEF PROC Midi_Init
61080    OPEN "Midi",16
61082    DIM Ex_Data(0)' fr Compiler
61084    Clr_In
61086    Sw_On=127:Sw_Off=0
61088    'Standart Control Changes
61090    Mod_Wheel=1:Breath_Ctrl=2:Foot_Pedal=3:Porta_Time=5:Data_Entry=6:Main_Vol=7
61092    Hold_Sus=64:Portamento=65:Sustenuto=66:Soft_Pedal=67
61094    Data_Inc=96:Data_Dec=97
61096    Loc_Ctrl=122:All_Off=123:Omni_Off=124:Omni_On=125
61098    Mono_On=126:Poly_Off=126:Mono_Off=127:Poly_On=127
61100    'Neue Control Changes
61102    Vol_B=0:Glide_Speed=2:Bank_Ch0=66:Bank_Ch1=67:Bank_Ch2=68:Bank_Ch3=69:Bank_Ch4=70
61104    Vcf_Mod=2
61106    Vol_R=4:Dyn_Ctrl=4:Vol_Mod=4:Expr_Pedal=11:Pitch_Range=31:Tremolo=92:Chorus=93
61108    Cz_Tune=6:Cz_Vib=1:Pan=9
61110    'Command-Definitionen
61112    Note_Off=$80:Note_On=$90:Poly_At=$A0:Ctrl_Chge=$B0:Prog_Chge=$C0:Chan_At=$D0:Pitch=$E0
61114    Song_Pos=$F2:Song_Sel=$F3:Tune_Request=$F6:Sys_End=$F7:Clock=$F8:Rt_Start=$FA:Rt_Cont=$FB
61116    Rt_Stop=$FC:Active=$FE:System_Reset=$FF
61118    Sys_Ex=$F0
61120    'System Exclusive - Identifier
61122    Sequential=1:Big_Briar=2:Octave=3:Moog=4:Passport=5:Lexicon=6:Kurzweil=7:Cbs=8:Steinway=9
61124    Fender=8:Delta_Lab=10:Scs=11:Gem=12:Techmar=13:Ensoniq=15:Oberheim=16:Paia=17:Simmons=18
61126    Gentle=19:Fairlight=20:Jl_Cooper=21:Lowery=22:Bon_Tempi=32:Siel=33:Ircam=34:Synthaxe=35
61128    Hohner=36:Crumar=37:Jms=39:Kawai=64:Roland=65:Korg=66:Yamaha=67:Casio=68:Akai=71
61130 RETURN
61132 '
61134 DEF PROC Midi_Exit
61136    CLOSE 16
61138 RETURN
61140 '
61142 ' Channel Informations
61144 '
61146 DEF PROC Note_On(Chn,Note,Vel)
61148    BIOS (,3,3,$90+Chn-1)
61150    BIOS (,3,3,Note)
61152    BIOS (,3,3,Vel)
61154 RETURN
61156 '
61158 DEF PROC Note_On(Chn,Note)
61160    BIOS (,3,3,$90+Chn-1)
61162    BIOS (,3,3,Note)
61164    BIOS (,3,3,$40)
61166 RETURN
61168 '
61170 DEF PROC Note_Off(Chn,Note)
61172    BIOS (,3,3,$90+Chn-1)
61174    BIOS (,3,3,Note)
61176    BIOS (,3,3,0)
61178 RETURN
61180 '
61182 DEF PROC Note_Off(Chn,Note,Vel)
61184    BIOS (,3,3,$80+Chn-1)
61186    BIOS (,3,3,Note)
61188    BIOS (,3,3,Vel)
61190 RETURN
61192 '
61194 DEF PROC Poly_At(Chn,Note,Value)
61196    BIOS (,3,3,$A0+Chn-1)
61198    BIOS (,3,3,Note)
61200    BIOS (,3,3,Value)
61202 RETURN
61204 '
61206 DEF PROC Ctrl_Chge(Chn,Num,Value)
61208    BIOS (,3,3,$B0+Chn-1)
61210    BIOS (,3,3,Num)
61212    BIOS (,3,3,Value)
61214 RETURN
61216 '
61218 DEF PROC Ctrl_Chgel(Chn,Num,Value)
61220    BIOS (,3,3,$B0+Chn-1)
61222    BIOS (,3,3,Num)
61224    BIOS (,3,3,Value SHR 7)
61226    BIOS (,3,3,Num+$20)
61228    BIOS (,3,3,Value AND $7F)
61230 RETURN
61232 '
61234 DEF PROC Switch_Chge(Chn,Num,Value)
61236    BIOS (,3,3,$B0+Chn-1)
61238    BIOS (,3,3,Num+$40)
61240    BIOS (,3,3,Value)
61242 RETURN
61244 '
61246 DEF PROC Prog_Chge(Chn,Num)
61248    BIOS (,3,3,$C0+Chn-1)
61250    BIOS (,3,3,Num)
61252 RETURN
61254 '
61256 DEF PROC Prog_Chge(Chn,Bw,Bn,Sn)
61258    BIOS (,3,3,$C0+Chn-1)
61260    BIOS (,3,3,(Bn-1)*Bw+Sn-1)
61262 RETURN
61264 '
61266 DEF PROC Chan_At(Chn,Value)
61268    BIOS (,3,3,$D0+Chn-1)
61270    BIOS (,3,3,Value)
61272 RETURN
61274 '
61276 DEF PROC Pitch(Chn,Value)
61278    BIOS (,3,3,$E0+Chn-1)
61280    BIOS (,3,3,Value AND $7F)
61282    BIOS (,3,3,Value SHR 7)
61284 RETURN
61286 '
61288 DEF PROC Local_Off(Chn)
61290    BIOS (,3,3,$B0+Chn-1)
61292    BIOS (,3,3,122)
61294    BIOS (,3,3,0)
61296 RETURN
61298 '
61300 DEF PROC Local_On(Chn)
61302    BIOS (,3,3,$B0+Chn-1)
61304    BIOS (,3,3,122)
61306    BIOS (,3,3,127)
61308 RETURN
61310 '
61312 DEF PROC All_Off(Chn)
61314    BIOS (,3,3,$B0+Chn-1)
61316    BIOS (,3,3,123)
61318    BIOS (,3,3,0)
61320 RETURN
61322 '
61324 DEF PROC Notes_Off(Chn)
61326    LOCAL I
61328    FOR I=0 TO 127
61330       Note_Off(Chn,I)
61332    NEXT I
61334 RETURN
61336 '
61338 DEF PROC Omni_Off(Chn)
61340    BIOS (,3,3,$B0+Chn-1)
61342    BIOS (,3,3,124)
61344    BIOS (,3,3,0)
61346 RETURN
61348 '
61350 DEF PROC Omni_On(Chn)
61352    BIOS (,3,3,$B0+Chn-1)
61354    BIOS (,3,3,125)
61356    BIOS (,3,3,0)
61358 RETURN
61360 '
61362 DEF PROC Poly_Off(Chn): LOCAL Num=0
61364 IF 0 THEN DEF PROC Mono_On(Chn,Num)
61366    BIOS (,3,3,$B0+Chn-1)
61368    BIOS (,3,3,126)
61370    BIOS (,3,3,Num)
61372 RETURN
61374 '
61376 DEF PROC Mono_Off(Chn)
61378 IF 0 THEN DEF PROC Poly_On(Chn)
61380    BIOS (,3,3,$B0+Chn-1)
61382    BIOS (,3,3,127)
61384    BIOS (,3,3,0)
61386 RETURN
61388 '
61390 DEF PROC Mod_Wheel(Chn,Value)
61392    BIOS (,3,3,$B0+Chn-1)
61394    BIOS (,3,3,1)
61396    BIOS (,3,3,Value)
61398 RETURN
61400 '
61402 DEF PROC Breath_Ctrl(Chn,Value)
61404    BIOS (,3,3,$B0+Chn-1)
61406    BIOS (,3,3,2)
61408    BIOS (,3,3,Value)
61410 RETURN
61412 '
61414 DEF PROC Foot_Pedal(Chn,Value)
61416    BIOS (,3,3,$B0+Chn-1)
61418    BIOS (,3,3,3)
61420    BIOS (,3,3,Value)
61422 RETURN
61424 '
61426 DEF PROC Porta_Time(Chn,Value)
61428    BIOS (,3,3,$B0+Chn-1)
61430    BIOS (,3,3,5)
61432    BIOS (,3,3,Value)
61434 RETURN
61436 '
61438 DEF PROC Data_Entry(Chn,Value)
61440    BIOS (,3,3,$B0+Chn-1)
61442    BIOS (,3,3,6)
61444    BIOS (,3,3,Value)
61446 RETURN
61448 '
61450 DEF PROC Main_Vol(Chn,Vol)
61452    BIOS (,3,3,$B0+Chn-1)
61454    BIOS (,3,3,7)
61456    BIOS (,3,3,Vol)
61458 RETURN
61460 '
61462 DEF PROC Sus_On(Chn)
61464    BIOS (,3,3,$B0+Chn-1)
61466    BIOS (,3,3,64)
61468    BIOS (,3,3,127)
61470 RETURN
61472 '
61474 DEF PROC Sus_Off(Chn)
61476    BIOS (,3,3,$B0+Chn-1)
61478    BIOS (,3,3,64)
61480    BIOS (,3,3,0)
61482 RETURN
61484 '
61486 DEF PROC Porta_On(Chn)
61488    BIOS (,3,3,$B0+Chn-1)
61490    BIOS (,3,3,65)
61492    BIOS (,3,3,127)
61494 RETURN
61496 '
61498 DEF PROC Porta_Off(Chn)
61500    BIOS (,3,3,$B0+Chn-1)
61502    BIOS (,3,3,65)
61504    BIOS (,3,3,0)
61506 RETURN
61508 '
61510 DEF PROC Sust_On(Chn)
61512    BIOS (,3,3,$B0+Chn-1)
61514    BIOS (,3,3,66)
61516    BIOS (,3,3,127)
61518 RETURN
61520 '
61522 DEF PROC Sust_Off(Chn)
61524    BIOS (,3,3,$B0+Chn-1)
61526    BIOS (,3,3,66)
61528    BIOS (,3,3,0)
61530 RETURN
61532 '
61534 DEF PROC Data_Inc(Chn)
61536    BIOS (,3,3,$B0+Chn-1)
61538    BIOS (,3,3,96)
61540    BIOS (,3,3,127)
61542 RETURN
61544 '
61546 DEF PROC Data_Dec(Chn)
61548    BIOS (,3,3,$B0+Chn-1)
61550    BIOS (,3,3,97)
61552    BIOS (,3,3,127)
61554 RETURN
61556 '
61558 ' System Informations
61560 '
61562 DEF PROC Song_Pos(Value)
61564    BIOS (,3,3,$F2)
61566    BIOS (,3,3,Value AND $7F)
61568    BIOS (,3,3,Value SHR 7)
61570 RETURN
61572 '
61574 DEF PROC Song_Sel(Num)
61576    BIOS (,3,3,$F3)
61578    BIOS (,3,3,Num)
61580 RETURN
61582 '
61584 DEF PROC Tune_Request
61586    BIOS (,3,3,$F6)
61588 RETURN
61590 '
61592 DEF PROC System_Reset
61594    BIOS (,3,3,$FF)
61596 RETURN
61598 '
61600 DEF PROC Clock
61602    BIOS (,3,3,$F8)
61604 RETURN
61606 '
61608 DEF PROC Rt_Start
61610    BIOS (,3,3,$FA)
61612 RETURN
61614 '
61616 DEF PROC Rt_Cont
61618    BIOS (,3,3,$FB)
61620 RETURN
61622 '
61624 DEF PROC Rt_Stop
61626    BIOS (,3,3,$FC)
61628 RETURN
61630 '
61632 DEF PROC Active
61634    -Act_Sens: BIOS (,3,3,$FE)
61636 RETURN
61638 '
61640 DEF PROC Active_On
61642    ON TIMER .3 GOSUB Act_Sens
61644 RETURN
61646 '
61648 DEF PROC Active_Off
61650    ON TIMER .3 GOSUB 0
61652 RETURN
61654 '
61656 ' System-Exclusive-Funktionen (allgemein)
61658 '
61660 DEF PROC Sys_Ex(Id)
61662    BIOS (,3,3,$F0)
61664    BIOS (,3,3,Id)
61666 RETURN
61668 '
61670 DEF PROC Sys_End
61672    BIOS (,3,3,$F7)
61674 RETURN
61676 '
61678 DEF FN Ex_Get$(Zahl)
61680 RETURN INPUT$(Zahl,16)
61682 '
61684 DEF PROC Ex_Get(Zahl)
61686    LOCAL Ex$= INPUT$(Zahl,16)
61688    Str_To_Ex(Ex$)
61690 RETURN
61692 '
61694 DEF FN Ex_To_Str$(L)
61696    LOCAL I,X$=" "*L
61698    FOR I=0 TO L-1
61700       MID$ (X$,I+1,1)= CHR$(Ex_Data(I))
61702    NEXT I
61704 RETURN X$
61706 '
61708 DEF PROC Str_To_Ex(X$)
61710    LOCAL I
61712    FOR I=1 TO LEN(X$)
61714       Ex_Data(I-1)= ASC( MID$(X$,I,1))
61716    NEXT I
61718 RETURN
61720 '
61722 DEF PROC Midi_Buffer(New_Adr,Leng,R Ret)
61724    LOCAL Adr
61726    IF Old_Buffer_Adress>0 THEN
61728       Ret=-1
61730       RETURN
61732    ENDIF
61734    IF Leng<=$80 THEN
61736       Old_Buffer
61738       Ret=1
61740       RETURN
61742    ENDIF
61744    Ret=0
61746    XBIOS (Adr,14,2)
61748    Old_Buffer_Adress= LPEEK(Adr)
61750    LPOKE Adr+6,0
61752    IPL 3+1 SHL 31
61754    LPOKE Adr,New_Adr
61756    WPOKE Adr+4,Leng
61758 RETURN
61760 '
61762 DEF PROC Old_Buffer
61764    LOCAL Adr
61766    IF Old_Buffer_Adress>0 THEN
61768       XBIOS (Adr,14,2)
61770       LPOKE Adr+6,0
61772       WPOKE Adr+4,$80
61774       LPOKE Adr,Old_Buffer_Adress
61776       IPL 3
61778       Old_Buffer_Adress=0
61780    ENDIF
61782 RETURN
61784 '
61786 DEF PROC Ex_Read(R Zahl,R Ret)
61788    LOCAL I=0,V
61790    REPEAT
61792       FOR V=0 TO 1000
61794          IF FN Midi_Is THEN EXIT
61796       NEXT V
61798       IF FN Midi_Is THEN
61800          Ex_Data(I)=FN Midi_In
61802          I=I+1
61804       ENDIF
61806    UNTIL I=Zahl+1 OR V>1000 OR Ex_Data( MAX(I-1,0))=Sys_End
61808    Ret=0
61810    IF I>=Zahl THEN Ret=1
61812    IF V>1000 THEN Ret=-1
61814    Zahl=I-1
61816 RETURN
61818 '
61820 'Funktionen fr den MIDI-Empfang
61822 '
61824 DEF PROC Chk_Stat(Value,R Stat_Flg,R Stat,R Chn)
61826    IF Value AND $80 THEN
61828       IF(Value AND $F8)=$F8 THEN
61830          Stat_Flg=1
61832       ELSE
61834          Stat_Flg=-1
61836          Stat=Value AND $F0
61838          Chn=(Value AND 15)+1
61840       ENDIF
61842    ELSE
61844       Stat_Flg=0
61846    ENDIF
61848 RETURN
61850 '
61852 DEF FN Pitch(Value1,Value2)=Value1+Value2*128
61854 '
61856 DEF FN Snd1(Okt,X$)
61858    LOCAL X1$,X2$,X,I
61860    RESTORE Snddta
61862    IF LEN(X$)=0 OR LEN(X$)>3 THEN RETURN -1
61864    Okt=(Okt+2)*12
61866    X1$= UPPER$( LEFT$(X$,1))
61868    FOR I=1 TO 8
61870       READ X2$,X
61872       IF X1$=X2$ THEN EXIT TO Snd_Fnd
61874    NEXT I
61876    RETURN -1
61878-Snd_Fnd
61880    FOR I=2 TO LEN(X$)
61882       X1$= MID$(X$,I,1)
61884       IF X1$="#" THEN X=X+1
61886       IF X1$="b" THEN X=X-1
61888    NEXT I
61890    I=Okt+X
61892    IF I<0 THEN RETURN 0
61894    IF I>127 THEN RETURN 127 ELSE RETURN I
61896 '
61898-Snddta: DATA "C",0,"D",2,"E",4,"F",5,"G",7,"A",9,"H",11,"B",10
61900 '
61902 DEF PROC Snd1(Value,R Okt,R X$)
61904    LOCAL X1,X2
61906    RESTORE Snddta
61908    Okt= INT(Value/12)-2
61910    X1=Value MOD 12
61912    REPEAT
61914       READ X$,X2
61916    UNTIL X2>=X1
61918    IF X2>X1 THEN X$=X$+"b"
61920    IF X$="Hb" THEN X$="B"
61922 RETURN
61924 '
61926 DEF FN Snd2(Okt,X$)
61928    LOCAL X1$,X2$,X,I
61930    RESTORE Snddta
61932    IF LEN(X$)=0 OR LEN(X$)>5 THEN RETURN -1
61934    Okt=(Okt+2)*12
61936    X1$= UPPER$(X$)
61938    FOR I=1 TO 8
61940       READ X2$,X
61942       IF X1$=X2$ THEN EXIT TO Snd_Fnd2
61944    NEXT I
61946    IF X1$="AS" THEN X=8: GOTO Exsnd
61948    IF X1$="ES" THEN X=3: GOTO Exsnd
61950    RETURN -1
61952-Snd_Fnd2
61954    FOR I=2 TO LEN(X$) STEP 2
61956       X1$= MID$(X$,I,2)
61958       IF X1$="IS" THEN X=X+1
61960       IF X1$="ES" THEN X=X-1
61962    NEXT I
61964-Exsnd:I=Okt+X
61966    IF I<0 THEN RETURN 0
61968    IF I>127 THEN RETURN 127 ELSE RETURN I
61970 '
61972 DEF PROC Snd2(Value,R Okt,R X$)
61974    LOCAL X1,X2
61976    RESTORE Snddta
61978    Okt= INT(Value/12)-2
61980    X1=Value MOD 12
61982    REPEAT
61984       READ X$,X2
61986    UNTIL X2>=X1
61988    IF X2>X1 THEN X$=X$+"es"
61990    IF X$="Ees" THEN X$="Es"
61992    IF X$="Aes" THEN X$="As"
61994    IF X$="Hes" THEN X$="B"
61996 RETURN
61998 '
