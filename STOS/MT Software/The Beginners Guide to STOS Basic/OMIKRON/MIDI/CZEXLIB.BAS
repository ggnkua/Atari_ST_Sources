62000 '
62002 ' System Exclusive Messages (Stand 12.10.1987)
62004 ' Casio CZ-101, CZ-1000
62006 ' written 1987 by HAB
62008 ' (c) 1987 by OMIKRON
62010 '
62012 DEF PROC Cz1000_Init
62014    DIM Pmp_Rate(8),Pmp_Dwn(8),Pmp_Lev(8),Psp_Rate(8),Psp_Dwn(8),Psp_Lev(8)
62016    DIM Pmw_Rate(8),Pmw_Dwn(8),Pmw_Lev(8),Psw_Rate(8),Psw_Dwn(8),Psw_Lev(8)
62018    DIM Pma_Rate(8),Pma_Dwn(8),Pma_Lev(8),Psa_Rate(8),Psa_Dwn(8),Psa_Lev(8)
62020 RETURN
62022 '
62024 DEF FN Midi_Int(Byte)
62026    LOCAL I
62028    FOR I=0 TO 100
62030       IF FN Midi_Is THEN EXIT TO Byte_Came
62032    NEXT I
62034 RETURN -1
62036-Byte_Came
62038 RETURN -(FN Midi_In<>Byte)
62040 '
62042 DEF FN Cz_Int
62044    LOCAL X
62046    X=FN Midi_Int(Sys_Ex): IF X THEN RETURN X
62048    X=FN Midi_Int(Casio): IF X THEN RETURN X
62050    X=FN Midi_Int(0): IF X THEN RETURN X
62052    X=FN Midi_Int(0)
62054 RETURN X
62056 '
62058 DEF PROC Cz_Ex(Chn,Type,Dat)
62060    Clr_In
62062    Sys_Ex(Casio)
62064    PRINT #16, CHR$(0); CHR$(0); CHR$($70+Chn-1); CHR$(Type); CHR$(Dat);
62066 RETURN
62068 '
62070 DEF PROC Send_Requ1(Chn,Bnk,Snd,R Msg$,R Ret)
62072    LOCAL I,Cstat=$70+Chn-1
62074    Msg$=""
62076    IF Bnk=3 THEN Snd=0
62078    Cz_Ex(Chn,$10,((Bnk-1) SHL 5)+Snd-1)
62080    Ret=FN Cz_Int: IF Ret THEN Sys_End: RETURN
62082    Ret=FN Midi_Int(Cstat): IF Ret THEN Sys_End: RETURN
62084    Ret=FN Midi_Int($30): IF Ret THEN Sys_End: RETURN
62086    PRINT #16, CHR$(Cstat); CHR$($31);
62088    Msg$=FN Ex_Get$(256)
62090    Ret=FN Midi_Int(Sys_End): IF Ret THEN Msg$=""
62092    Sys_End
62094    FOR I=1 TO LEN(Msg$)\2
62096       MID$ (Msg$,I,1)= CHR$( ASC( MID$(Msg$,(I-1)*2+1)) OR ASC( MID$(Msg$,(I-1)*2+1+1)) SHL 4)
62098    NEXT I
62100    Msg$= LEFT$(Msg$,128)
62102 RETURN
62104 '
62106 DEF PROC Rec_Requ(Chn,Bnk,Snd,Msg$,R Ret)
62108    LOCAL I,Snd$=" "*256,Cstat=$70+Chn-1
62110    Ret=-1
62112    IF LEN(Msg$)<>128 THEN RETURN
62114    FOR I=1 TO 128
62116       MID$ (Snd$,(I-1)*2+1,2)= CHR$( ASC( MID$(Msg$,I,1)) AND $F)+ CHR$( ASC( MID$(Msg$,I,1)) SHR 4)
62118    NEXT I
62120    IF Bnk=3 THEN Snd=0
62122    Cz_Ex(Chn,$20,32*(Bnk-1)+Snd-1)
62124    Ret=FN Cz_Int: IF Ret THEN Sys_End: RETURN
62126    Ret=FN Midi_Int(Cstat): IF Ret THEN Sys_End: RETURN
62128    Ret=FN Midi_Int($30): IF Ret THEN Sys_End: RETURN
62130    PRINT #16,Snd$;
62132    Sys_End
62134    Ret=FN Midi_Int(Sys_End)
62136 RETURN
62138 '
62140 DEF PROC Bend_Range(Chn,Range)
62142    Cz_Ex(Chn,$40,Range)
62144    Sys_End
62146 RETURN
62148 '
62150 DEF PROC Key_Trans(Chn,Ktd)
62152    IF Ktd<0 THEN Ktd=$40-Ktd
62154    Cz_Ex(Chn,$41,Ktd)
62156    Sys_End
62158 RETURN
62160 '
62162 DEF PROC Tone_Mix(Chn,Sw,Lev)
62164    Cz_Ex(Chn,$42,Sw*$40+Lev)
62166    Sys_End
62168 RETURN
62170 '
62172 DEF PROC Send_Requ2(Chn,R Bnk,R Snd,R Vib,R Port,R Vchn,R Ret)
62174    LOCAL I
62176    Cz_Ex(Chn,$19,1)
62178    Ret=FN Cz_Int: IF Ret THEN Sys_End: RETURN
62180    FOR I=0 TO 100
62182       IF FN Midi_Is THEN EXIT TO Vchn_Fnd
62184    NEXT I
62186    Ret=-1
62188    Sys_End: RETURN
62190-Vchn_Fnd
62192    I=FN Midi_In
62194    IF(I AND $F0)<>$70 THEN Sys_End: RETURN
62196    Ret=FN Midi_Int($30): IF Ret THEN Sys_End: RETURN
62198    Vchn=(I AND $F)+1
62200    PRINT #16, CHR$($70+Chn-1); CHR$($31);
62202    I=FN Midi_In
62204    Bnk=I SHR 5+1
62206    Snd=(I AND $F)+1
62208    I=FN Midi_In
62210    Vib=-(I SHR 4) AND 1
62212    Port=-(I SHR 5) AND 1
62214    Ret=FN Midi_Int(Sys_End)
62216    Sys_End
62218 RETURN
62220 '
62222 DEF PROC Decode(Msg$)
62224    IF LEN(Msg$)<>128 THEN RETURN
62226    LOCAL X,X1
62228    Pflag_Ls= ASC(Msg$) AND 3
62230    IF Pflag_Ls>1 THEN Pflag_Ls=Pflag_Ls XOR 1
62232    Pflag_Ls$="1   "
62234    IF Pflag_Ls=1 THEN
62236       MID$ (Pflag_Ls$,1)="2"
62238    ELSE
62240       IF Pflag_Ls=2 THEN Pflag_Ls$="1+2'"
62242       IF Pflag_Ls=3 THEN Pflag_Ls$="1+1'"
62244    ENDIF
62246    Pflag_Oct= ASC(Msg$) SHR 2 AND 3
62248    IF Pflag_Oct=2 THEN Pflag_Oct=-1
62250    IF( ASC( MID$(Msg$,2)) AND 1) THEN Pds=-1:Pds$="-" ELSE Pds=1:Pds$="+"
62252    Pdet_Fine= ASC( MID$(Msg$,3)) SHR 2
62254    Pdet_Fine=Pdet_Fine-Pdet_Fine\16
62256    X= ASC( MID$(Msg$,4)) AND 63
62258    Pdet_Note=X MOD 12
62260    Pdet_Oct=X\12
62262    X= ASC( MID$(Msg$,5)) AND %101110
62264    Pvk=(X AND 8) SHR 3+(X AND 4)/2+(X AND 32)\10+(X AND 2)*2
62266    Pvdld= ASC( MID$(Msg$,6))
62268    Pvdlv= CVI( MIRROR$( MID$(Msg$,7,2)))
62270    Pvsd= ASC( MID$(Msg$,9))
62272    Pvsv= CVI( MIRROR$( MID$(Msg$,10,2)))
62274    Pvdd= ASC( MID$(Msg$,12))
62276    Pvdv= CVI( MIRROR$( MID$(Msg$,13,2)))
62278    X= CVI( MID$(Msg$,15)) AND $FFFF
62280    X1=X SHR 6 AND 3
62282    Mfw_1st=X SHR 13
62284    IF Mfw_1st<4 THEN Mfw_1st=Mfw_1st+1
62286    IF Mfw_1st>5 THEN Mfw_1st=Mfw_1st+X1-1
62288    IF X AND 512 THEN
62290       Mfw_2nd=X SHR 10 AND 7
62292       IF Mfw_2nd<4 THEN Mfw_2nd=Mfw_2nd+1
62294       IF Mfw_2nd>5 THEN Mfw_2nd=Mfw_2nd+X1-1
62296    ELSE
62298       Mfw_2nd=0
62300    ENDIF
62302    X1=X SHR 4 AND 3
62304    Mfw_Rmod=-(X1\2)
62306    Mfw_Nmod=-(X1 AND 1)
62308    Mamd= ASC( MID$(Msg$,17))
62310    Mamv= ASC( MID$(Msg$,18))
62312    Mwmd= ASC( MID$(Msg$,19))
62314    Mwmv= ASC( MID$(Msg$,20))
62316    Pmal= ASC( MID$(Msg$,21))+1
62318    Pma_Sp=9
62320    FOR X=1 TO 8
62322       X1= ASC( MID$(Msg$,20+X*2)) AND 127
62324       IF X1=0 OR X1=$77 THEN
62326          IF X1 THEN Pma_Rate(X)=99 ELSE Pma_Rate(X)=0
62328       ELSE
62330          Pma_Rate(X)=X1*99\119+1
62332       ENDIF
62334       Pma_Dwn(X)=-( ASC( MID$(Msg$,20+X*2)) SHR 7)
62336       X1=( ASC( MID$(Msg$,21+X*2)) AND 127)-28
62338       IF X1<0 THEN X1=0
62340       Pma_Lev(X)=X1
62342       IF ASC( MID$(Msg$,21+X*2)) AND 128 THEN Pma_Sp=X
62344    NEXT X
62346    Pmwl= ASC( MID$(Msg$,38))+1
62348    Pmw_Sp=9
62350    FOR X=1 TO 8
62352       X1=( ASC( MID$(Msg$,37+X*2)) AND 127)-8
62354       IF X1=0 OR X1=$77 THEN
62356          IF X1 THEN Pmw_Rate(X)=99 ELSE Pmw_Rate(X)=0
62358       ELSE
62360          Pmw_Rate(X)=X1*99\119+1
62362       ENDIF
62364       Pmw_Dwn(X)=-( ASC( MID$(Msg$,37+X*2)) SHR 7)
62366       X1= ASC( MID$(Msg$,38+X*2)) AND 127
62368       IF X1=0 OR X1=$7F THEN
62370          IF X1 THEN Pmw_Lev(X)=99 ELSE Pmw_Lev(X)=0
62372       ELSE
62374          Pmw_Lev(X)=X1*99\127+1
62376       ENDIF
62378       IF ASC( MID$(Msg$,38+X*2)) AND 128 THEN Pmw_Sp=X
62380    NEXT X
62382    Pmpl= ASC( MID$(Msg$,55))+1
62384    Pmp_Sp=9
62386    FOR X=1 TO 8
62388       X1= ASC( MID$(Msg$,54+X*2)) AND 127
62390       IF X1=0 OR X1=$7F THEN
62392          IF X1 THEN Pmp_Rate(X)=99 ELSE Pmp_Rate(X)=0
62394       ELSE
62396          Pmp_Rate(X)=X1*99\127+1
62398       ENDIF
62400       Pmp_Dwn(X)=-( ASC( MID$(Msg$,54+X*2)) SHR 7)
62402       X1= ASC( MID$(Msg$,55+X*2)) AND 127
62404       IF X1>63 THEN X1=X1-4
62406       Pmp_Lev(X)=X1
62408       IF ASC( MID$(Msg$,55+X*2)) AND 128 THEN Pmp_Sp=X
62410    NEXT X
62412    X= CVI( MID$(Msg$,72)) AND $FFFF
62414    X1=X SHR 6 AND 3
62416    Sfw_1st=X SHR 13
62418    IF Sfw_1st<4 THEN Sfw_1st=Sfw_1st+1
62420    IF Sfw_1st>5 THEN Sfw_1st=Sfw_1st+X1-1
62422    IF X AND 512 THEN
62424       Sfw_2nd=X SHR 10 AND 7
62426       IF Sfw_2nd<4 THEN Sfw_2nd=Sfw_2nd+1
62428       IF Sfw_2nd>5 THEN Sfw_2nd=Sfw_2nd+X1-1
62430    ELSE
62432       Sfw_2nd=0
62434    ENDIF
62436    Samd= ASC( MID$(Msg$,74))
62438    Samv= ASC( MID$(Msg$,75))
62440    Swmd= ASC( MID$(Msg$,76))
62442    Swmv= ASC( MID$(Msg$,77))
62444    Psal= ASC( MID$(Msg$,78))+1
62446    Psa_Sp=9
62448    FOR X=1 TO 8
62450       X1= ASC( MID$(Msg$,77+X*2)) AND 127
62452       IF X1=0 OR X1=$77 THEN
62454          IF X1 THEN Psa_Rate(X)=99 ELSE Psa_Rate(X)=0
62456       ELSE
62458          Psa_Rate(X)=X1*99\119+1
62460       ENDIF
62462       Psa_Dwn(X)=-( ASC( MID$(Msg$,77+X*2)) SHR 7)
62464       X1=( ASC( MID$(Msg$,78+X*2)) AND 127)-28
62466       IF X1<0 THEN X1=0
62468       Psa_Lev(X)=X1
62470       IF ASC( MID$(Msg$,78+X*2)) AND 128 THEN Psa_Sp=X
62472    NEXT X
62474    Pswl= ASC( MID$(Msg$,95))+1
62476    Psw_Sp=9
62478    FOR X=1 TO 8
62480       X1=( ASC( MID$(Msg$,94+X*2)) AND 127)-8
62482       IF X1=0 OR X1=$77 THEN
62484          IF X1 THEN Psw_Rate(X)=99 ELSE Psw_Rate(X)=0
62486       ELSE
62488          Psw_Rate(X)=X1*99\119+1
62490       ENDIF
62492       Psw_Dwn(X)=-( ASC( MID$(Msg$,94+X*2)) SHR 7)
62494       X1= ASC( MID$(Msg$,95+X*2)) AND 127
62496       IF X1=0 OR X1=$7F THEN
62498          IF X1 THEN Psw_Lev(X)=99 ELSE Psw_Lev(X)=0
62500       ELSE
62502          Psw_Lev(X)=X1*99\127+1
62504       ENDIF
62506       IF ASC( MID$(Msg$,95+X*2)) AND 128 THEN Psw_Sp=X
62508    NEXT X
62510    Pspl=( ASC( MID$(Msg$,112)) AND 127)+1
62512    Psp_Sp=9
62514    FOR X=1 TO 8
62516       X1= ASC( MID$(Msg$,111+X*2)) AND 127
62518       IF X1=0 OR X1=$7F THEN
62520          IF X1 THEN Psp_Rate(X)=99 ELSE Psp_Rate(X)=0
62522       ELSE
62524          Psp_Rate(X)=X1*99\127+1
62526       ENDIF
62528       Psp_Dwn(X)=-( ASC( MID$(Msg$,111+X*2)) SHR 7)
62530       X1= ASC( MID$(Msg$,112+X*2)) AND 127
62532       IF X1>63 THEN X1=X1-4
62534       Psp_Lev(X)=X1
62536       IF ASC( MID$(Msg$,112+X*2)) AND 128 THEN Psp_Sp=X
62538    NEXT X
62540 RETURN
62542 '
62544 DEF FN Vib(Value,Typ)' Value = 0~99; Typ = 0~2
62546    IF Typ=2 AND Value=99 THEN RETURN $300
62548    LOCAL X=Value,Mul=1,Jp
62550    IF Typ<>0 THEN X=X+1
62552    FOR Jp=$20 TO $60 STEP $10
62554       IF Value<Jp THEN EXIT
62556       X=X+Mul*(Value-Jp+1)
62558       IF Typ<>0 THEN X=X+Mul
62560       Mul=Mul*2
62562    NEXT Jp
62564    IF Typ=1 THEN X=X SHL 5
62566 RETURN X
62568 '
62570 DEF FN Mxm(Value,Typ)' Value = 0~9; Typ = 0, 1
62572    IF Typ THEN
62574       ON Value GOTO Mamv1,Mamv2,Mamv3,Mamv4,Mamv5,Mamv6,Mamv7,Mamv8,Mamv9
62576      -Mamv0: RETURN 0
62578      -Mamv1: RETURN 8
62580      -Mamv2: RETURN $11
62582      -Mamv3: RETURN $1A
62584      -Mamv4: RETURN $24
62586      -Mamv5: RETURN $2F
62588      -Mamv6: RETURN $3A
62590      -Mamv7: RETURN $45
62592      -Mamv8: RETURN $52
62594      -Mamv9: RETURN $5F
62596    ELSE
62598       ON Value GOTO Mwmv1,Mwmv2,Mwmv3,Mwmv4,Mwmv5,Mwmv6,Mwmv7,Mwmv8,Mwmv9
62600      -Mwmv0: RETURN 0
62602      -Mwmv1: RETURN $1F
62604      -Mwmv2: RETURN $2C
62606      -Mwmv3: RETURN $39
62608      -Mwmv4: RETURN $46
62610      -Mwmv5: RETURN $53
62612      -Mwmv6: RETURN $60
62614      -Mwmv7: RETURN $6E
62616      -Mwmv8: RETURN $92
62618      -Mwmv9: RETURN $FF
62620    ENDIF
62622 RETURN -1
62624 '
62626 DEF FN Code$
62628    LOCAL X,X1,X2
62630    Msg$= CHR$(0)*128
62632    X=Pflag_Ls
62634    IF X>1 THEN X=X XOR 1
62636    X1=Pflag_Oct
62638    IF X1=-1 THEN X1=2
62640    MID$ (Msg$,1)= CHR$(X+X1 SHL 2)
62642    MID$ (Msg$,2)= CHR$(-(Pds<0))
62644    MID$ (Msg$,3)= CHR$((Pdet_Fine+Pdet_Fine\16) SHL 2)
62646    MID$ (Msg$,4)= CHR$(Pdet_Note+Pdet_Oct*12)
62648    MID$ (Msg$,5)= CHR$(1 SHL(4-Pvk-(Pvk=4)-4*(Pvk=3)))
62650    MID$ (Msg$,6)= CHR$(Pvdld)
62652    MID$ (Msg$,7)= MIRROR$( MKI$(FN Vib(Pvdld,0)))
62654    MID$ (Msg$,9)= CHR$(Pvsd)
62656    MID$ (Msg$,10)= MIRROR$( MKI$(FN Vib(Pvsd,1)))
62658    MID$ (Msg$,12)= CHR$(Pvdd)
62660    MID$ (Msg$,13)= MIRROR$( MKI$(FN Vib(Pvdd,2)))
62662    IF Mfw_1st>5 THEN
62664       X=6
62666       X1=Mfw_1st-5
62668    ELSE
62670       X=Mfw_1st
62672       IF X<4 THEN X=X-1
62674       X1=0
62676    ENDIF
62678    X2=X SHL 13
62680    IF Mfw_2nd>0 THEN
62682       IF Mfw_2nd>5 THEN
62684          X=6
62686          X1=Mfw_2nd-5
62688       ELSE
62690          X=Mfw_2nd
62692          IF X<4 THEN X=X-1
62694       ENDIF
62696       X2=X2 OR(X*2+1) SHL 9
62698    ENDIF
62700    X2=X2 OR X1 SHL 6
62702    IF Mfw_Rmod THEN X2=X2 OR 32
62704    IF Mfw_Nmod THEN X2=X2 OR 24
62706    MID$ (Msg$,15)= RIGHT$( MKIL$(X2),2)
62708    MID$ (Msg$,17)= CHR$(Mamd)
62710    MID$ (Msg$,18)= CHR$(FN Mxm(Mamd,1))
62712    MID$ (Msg$,19)= CHR$(Mwmd)
62714    MID$ (Msg$,20)= CHR$(FN Mxm(Mwmd,0))
62716    MID$ (Msg$,21)= CHR$(Pmal-1)
62718    FOR X=1 TO 8
62720       IF X=1
62722          THEN X1=-(X=Pmal)
62724          ELSE X1=-(Pma_Lev(X)<Pma_Lev(X-1) OR X=Pmal)
62726       ENDIF
62728       MID$ (Msg$,20+X*2)= CHR$(X1 SHL 7 OR(Pma_Rate(X)*119\99))
62730       X1=Pma_Lev(X)
62732       IF X1>0 THEN X1=X1+28
62734       MID$ (Msg$,21+X*2)= CHR$(-(Pma_Sp=X) SHL 7 OR X1)
62736    NEXT X
62738    MID$ (Msg$,38)= CHR$(Pmwl-1)
62740    FOR X=1 TO 8
62742       IF X=1
62744          THEN X1=-(X=Pmwl)
62746          ELSE X1=-(Pmw_Lev(X)<Pmw_Lev(X-1) OR X=Pmwl)
62748       ENDIF
62750       MID$ (Msg$,37+X*2)= CHR$(X1 SHL 7 OR(Pmw_Rate(X)*119\99+8))
62752       MID$ (Msg$,38+X*2)= CHR$(-(Pmw_Sp=X) SHL 7 OR(Pmw_Lev(X)*127\99))
62754    NEXT X
62756    MID$ (Msg$,55)= CHR$(Pmpl-1)
62758    FOR X=1 TO 8
62760       IF X=1
62762          THEN X1=-(X=Pmpl)
62764          ELSE X1=-(Pmp_Lev(X)<Pmp_Lev(X-1) OR X=Pmpl)
62766       ENDIF
62768       MID$ (Msg$,54+X*2)= CHR$(X1 SHL 7 OR(Pmp_Rate(X)*127\99))
62770       X1=Pmp_Lev(X)
62772       IF X1>63 THEN X1=X1+4
62774       MID$ (Msg$,55+X*2)= CHR$(-(Pmp_Sp=X) SHL 7 OR X1)
62776    NEXT X
62778    IF Sfw_1st>5 THEN
62780       X=6
62782       X1=Sfw_1st-5
62784    ELSE
62786       X=Sfw_1st
62788       IF X<4 THEN X=X-1
62790       X1=0
62792    ENDIF
62794    X2=X SHL 13
62796    IF Sfw_2nd>0 THEN
62798       IF Sfw_2nd>5 THEN
62800          X=6
62802          X1=Sfw_2nd-5
62804       ELSE
62806          X=Sfw_2nd
62808          IF X<4 THEN X=X-1
62810       ENDIF
62812       X2=X2 OR(X*2+1) SHL 9
62814    ENDIF
62816    X2=X2 OR X1 SHL 6
62818    MID$ (Msg$,72)= RIGHT$( MKIL$(X2),2)
62820    MID$ (Msg$,74)= CHR$(Samd)
62822    MID$ (Msg$,75)= CHR$(FN Mxm(Samd,1))
62824    MID$ (Msg$,76)= CHR$(Swmd)
62826    MID$ (Msg$,77)= CHR$(FN Mxm(Swmd,0))
62828    MID$ (Msg$,78)= CHR$(Psal-1)
62830    FOR X=1 TO 8
62832       IF X=1
62834          THEN X1=-(X=Psal)
62836          ELSE X1=-(Psa_Lev(X)<Psa_Lev(X-1) OR X=Psal)
62838       ENDIF
62840       MID$ (Msg$,77+X*2)= CHR$(X1 SHL 7 OR(Psa_Rate(X)*119\99))
62842       X1=Psa_Lev(X)
62844       IF X1>0 THEN X1=X1+28
62846       MID$ (Msg$,78+X*2)= CHR$(-(Psa_Sp=X) SHL 7 OR X1)
62848    NEXT X
62850    MID$ (Msg$,95)= CHR$(Pswl-1)
62852    FOR X=1 TO 8
62854       IF X=1
62856          THEN X1=-(X=Pswl)
62858          ELSE X1=-(Psw_Lev(X)<Psw_Lev(X-1) OR X=Pswl)
62860       ENDIF
62862       MID$ (Msg$,94+X*2)= CHR$(X1 SHL 7 OR(Psw_Rate(X)*119\99+8))
62864       MID$ (Msg$,95+X*2)= CHR$(-(Psw_Sp=X) SHL 7 OR(Psw_Lev(X)*127\99))
62866    NEXT X
62868    MID$ (Msg$,112)= CHR$(Pspl-1)
62870    FOR X=1 TO 8
62872       IF X=1
62874          THEN X1=-(X=Pspl)
62876          ELSE X1=-(Psp_Lev(X)<Psp_Lev(X-1) OR X=Pspl)
62878       ENDIF
62880       MID$ (Msg$,111+X*2)= CHR$(X1 SHL 7 OR(Psp_Rate(X)*127\99))
62882       X1=Psp_Lev(X)
62884       IF X1>63 THEN X1=X1+4
62886       MID$ (Msg$,112+X*2)= CHR$(-(Psp_Sp=X) SHL 7 OR X1)
62888    NEXT X
62890 RETURN Msg$
62892 '
