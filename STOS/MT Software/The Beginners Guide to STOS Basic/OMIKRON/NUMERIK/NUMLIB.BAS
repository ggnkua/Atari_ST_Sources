59000 '
59001 '                    N U M L I B
59002 '
59003 '         Numerik-Bibliothek fr OMIKRON.BASIC
59004 '
59005 '                  Programmiert von
59006 '
59007 '                     J”rn Wilms
59008 '                    Im Feldle 23
59009 '               D-7312 Kirchheim/Teck
59010 '                 Tel.: 07021/44286
59011 '
59012 '
59013 '   ½ 1988 by J”rn Wilms und OMIKRON.Software, Birkenfeld
59014 '
59015 DEF PROC Fourier_Trans(F,N,Z)
59016   LOCAL Feld1= LPEEK( VARPTR(F#(0,0)))
59017   LPOKE VARPTR(F#(0,0)), LPEEK(F)
59018   LOCAL Feld2= LPEEK( VARPTR(Z#(0,0)))
59019   LPOKE VARPTR(Z#(0,0)), LPEEK(Z)
59020   FOR K=0 TO Nn-1
59021     Z#(K,0)=0
59022     Z#(K,1)=0
59023     FOR J=0 TO Nn-1
59024       Co= COS(2* PI *J*K/Nn)
59025       Si= SIN(2* PI *J*K/Nn)
59026       Z#(K,0)=Z#(K,0)+F#(J,0)*Co+F#(J,1)*Si
59027       Z#(K,1)=Z#(K,1)+F#(J,1)*Co+F#(J,0)*Si
59028     NEXT J
59029     Z#(K,0)=Z#(K,0)/ SQR(Nn)
59030     Z#(K,1)=Z#(K,1)/ SQR(Nn)
59031   NEXT K
59032   LPOKE VARPTR(A#(0,0)),Feld1
59033   LPOKE VARPTR(Z#(0,0)),Feld2
59034 RETURN
59035 DEF PROC Mean_Approx(Index1#,Index2#,Index#,Tl#,Tr#,A,In,Coeff)
59036   LOCAL Feld1= LPEEK( VARPTR(A#(0,0)))
59037   LPOKE VARPTR(A#(0,0)), LPEEK(A)
59038   LOCAL Feld2= LPEEK( VARPTR(In#(0)))
59039   LPOKE VARPTR(In#(0)), LPEEK(In)
59040   LOCAL Feld3= LPEEK( VARPTR(Coeff#(0)))
59041   LPOKE VARPTR(Coeff#(0)), LPEEK(Coeff)
59042   LOCAL I,J
59043   IF Index#>=Index1# AND Index#<=Index2# THEN
59044     PRINT "PROC Mean_Approx: Approximation w„re sinnlos, Index berprfen!!"
59045     STOP
59046   ENDIF
59047   M#=Index2#-Index1#+1
59048   FOR I#=1 TO M#
59049     A#(I#,I#)=FN Romberg_2#(Tl#,Tr#,Index1#-1+I#,Index1#-1+I#)
59050     FOR J#=I#+1 TO M#
59051       A#(I#,J#)=FN Romberg_2#(Tl#,Tr#,Index1#-1+I#,Index1#-1+J#)
59052       A#(J#,I#)=A#(I#,J#)
59053     NEXT J#
59054   NEXT I#
59055   FOR I#=1 TO M#
59056     In#(I#)=FN Romberg_2#(Tl#,Tr#,Index#,Index1#-1+I#)
59057   NEXT I#
59058   Gauss(A#(0,0),In#(0),Index2#-Index1#+1,Coeff#(0),Dt#)
59059   LPOKE VARPTR(A#(0,0)),Feld1
59060   LPOKE VARPTR(In#(0)),Feld2
59061   LPOKE VARPTR(Coeff#(0)),Feld3
59062 RETURN
59063 DEF FN Fakul!(N)
59064   LOCAL Fakul!
59065   IF N<110 THEN
59066     Fakul!= FACT(N)
59067   ELSE
59068     Fakul!=(N/ EXP(1.))^N* SQR(2* PI *N)
59069     Fakul!=Fakul!*(1+1/(12*N)+1/(288*N*N)-139/(51850*N^3))
59070   ENDIF
59071 RETURN Fakul!
59072 DEF FN Bessel#(N#,X#)= SQR(2/( PI *X#))* COS(X#-.5*N#* PI -.25* PI )
59073 DEF FN Weber#(N#,X#)= SQR(2/( PI *X#))* SIN(X#-.5*N#* PI -.25* PI )
59074 DEF FN Macdo#(N#,X#)= SQR( PI /(2*X#))* EXP(-X#)
59075 DEF FN Mod_Bessel#(N#,X#)= EXP(X#)/ SQR(2* PI *X#)
59076 DEF FN Beta#(X#,Y#)=FN Gamma#(X#)*FN Gamma#(Y#)/FN Gamma#(X#+Y#)
59077 DEF FN Gamma#(X#)
59078   LOCAL Y#,Term#,Lggm#,S#,Z#,W#,V#,Flag#=0
59079   IF X#<=0 THEN
59080     Flag#=-1
59081     X#=-X#
59082     IF X#= INT(X#) THEN
59083       PRINT "Gamma-Funktion von negativen ganzzahligen Werten ist"
59084       PRINT "nicht definiert!!"
59085       STOP
59086     ENDIF
59087   ENDIF
59088   Y#=X#
59089   Term#=1#
59090   Lggm#=0#
59091   IF X#=1 OR X#=2 THEN RETURN 0
59092   WHILE Y#<=18
59093     Term#=Term#*Y#
59094     Y#=Y#+1
59095   WEND
59096   S#=1#/Y#^2
59097   Z#=6.41025641025641D-3
59098   W#=-1.9175269175269175D-3
59099   V#=8.4175084175084175D-4
59100   U#=-5.9523809523809524D-4
59101   T#=7.9365079365079365D-4
59102   R#=-2.7777777777777778D-3
59103   Q#=.083333333333333333#
59104   P#=.9189385332046727#
59105   Lggm#=(Y#-.5)* LN(Y#)+P#-Y#- LN(Term#)
59106   Lggm#=Lggm#+((((((Z#*S#+W#)*S#+V#)*S#+U#)*S#+T#)*S#+R#)*S#+Q#)/Y#
59107   Gamma#= EXP(Lggm#)
59108   IF Flag#=-1 THEN
59109     Gamma#=- PI /(-X#*Gamma#* SIN(- PI *X#))
59110   ENDIF
59111 RETURN Gamma#
59112 DEF FN Atn2#(X#,Y#)
59113   LOCAL At#
59114   IF SIN(90)=1 THEN
59115     IF ABS(Y#)<1D-40 THEN
59116       At#= SGN(X#)*90#
59117     ELSE
59118       At#= ATN(X#/Y#)
59119       IF Y#<0 THEN At#=At#+180#
59120     ENDIF
59121     IF At#<0 THEN At#=At#+360#
59122   ELSE
59123     IF ABS(Y#)<1D-40 THEN
59124       At#= SGN(X#)*.5* PI
59125     ELSE
59126       At#= ATN(X#/Y#)
59127       IF Y#<0 THEN At#=At#+ PI
59128     ENDIF
59129     IF At#<0 THEN At#=At#+2* PI
59130   ENDIF
59131 RETURN At#
59132 DEF PROC Fkt_Plot_1(X,Y,B,H,Xmin#,Xmax#,Ymin#,Ymax#,Index,R Flag)
59133   LOCAL Xz#,Yz#,X0#,Y0#,X#,Y#,Xi#,Yi#,Xs0#,Ys0#,St#,X1#,X2#,Y1#,Y2#,Xa#,Yh10
59134   LOCAL B20,H20,Pix_Sc,Xmami#,Ymami#
59135   CLIP X,Y,B,H
59136   BOX X,Y,B,H
59137   IF Xmax#<Xmin# THEN SWAP Xmax#,Xmin#
59138   IF Ymax#<Ymin# THEN SWAP Ymax#,Ymin#
59139   Yh10=Y+H-10
59140   B20=B-20
59141   H20=H-20
59142   Pix_Sc=150
59143   Xmami#=Xmax#-Xmin#
59144   Ymami#=Ymax#-Ymin#
59145   IF Flag=1 THEN
59146     TEXT HEIGHT =6: TEXT STYLE =0
59147     IF SGN(Xmin#*Xmax#)=-1 THEN
59148       Xi#= ABS(Xmin#)/( ABS(Xmin#)+ ABS(Xmax#))
59149       Xs0#=X+10+Xi#*B20
59150     ELSE
59151       Xs0#=X+10
59152     ENDIF
59153     IF SGN(Ymin#*Ymax#)=-1 THEN
59154       Yi#= ABS(Ymin#)/( ABS(Ymin#)+ ABS(Ymax#))
59155       Ys0#=Yh10-Yi#*H20
59156     ELSE
59157       Ys0#=Yh10
59158     ENDIF
59159     DRAW X+10,Ys0# TO X+B-10,Ys0#
59160     DRAW Xs0#,Y+H-10 TO Xs0#,Y+10
59161     St#=10^ INT( LOG(10,(Xmami#/(B20/Pix_Sc)))+.5)
59162     FOR Xa#=0 TO MAX( ABS(Xmin#), ABS(Xmax#)) STEP St#
59163       X1#=Xs0#+Xa#*B20/Xmami#
59164       X2#=Xs0#-Xa#*B20/Xmami#
59165       DRAW X1#,Ys0# TO X1#,Ys0#+10
59166       TEXT X1#+1,Ys0#+10, STR$(Xa#)
59167       DRAW X2#,Ys0# TO X2#,Ys0#+10
59168       TEXT X2#+1,Ys0#+10, STR$(-Xa#)
59169     NEXT Xa#
59170     St#=10^ INT( LOG(10,(Ymami#/(H20/Pix_Sc)))+.5)
59171     FOR Ya#=St# TO MAX( ABS(Ymin#), ABS(Ymax#)) STEP St#
59172       Y1#=Ys0#+Ya#*H20/Ymami#
59173       Y2#=Ys0#-Ya#*H20/Ymami#
59174       DRAW Xs0#,Y1# TO Xs0#-10,Y1#
59175       TEXT Xs0#+1,Y1#, STR$(-Ya#)
59176       DRAW Xs0#,Y2# TO Xs0#-10,Y2#
59177       TEXT Xs0#+1,Y2#, STR$(Ya#)
59178     NEXT Ya#
59179   ENDIF
59180   CLIP X+20,Y+10 TO X+B-10,Yh10
59181   ON ERROR GOTO Erbeh
59182   Xz#=X+10
59183   X0#=X+10
59184   Y0#=FN F#(Index,Xmin#)-Ymin#
59185   Y0#=Yh10-Y0#*H20/Ymami#
59186   FOR X#=Xmin# TO Xmax# STEP Xmami#/B20
59187     Y#=FN F#(Index,X#)-Ymin#
59188     Yz#=Yh10-Y#*H20/Ymami#
59189     Xz#=Xz#+1
59190     IF ABS(Y0#-Yz#)<H THEN
59191       DRAW X0#,Y0# TO Xz#,Yz#
59192     ELSE
59193       DRAW Xz#,Yz#
59194     ENDIF
59195     X0#=Xz#
59196     Y0#=Yz#
59197   NEXT X#
59198   CLIP
59199   ON ERROR GOTO 0
59200 RETURN
59201-Erbeh
59202  IF ERR =6 THEN
59203    RESUME NEXT
59204  ELSE
59205    PRINT "FEHLER in PROC Fkt_Plot"
59206  ENDIF
59207 STOP
59208 DEF PROC Fkt_Plot_2(X,Y,B,H,Xmin#,Xmax#,Ymin#,Ymax#,Xx,N,R Flag,Flag2)
59209   LOCAL Feld= LPEEK( VARPTR(Xx#(0,0)))
59210   LPOKE VARPTR(Xx#(0,0)), LPEEK(Xx)
59211   LOCAL Xz#,Yz#,X0#,Y0#,X#,Y#,Xi#,Yi#,Xs0#,Ys0#,St#,X1#,X2#,Y1#,Y2#,Xa#,Yh10
59212   LOCAL B20,H20,Xmami#,Ymami#,Pix_Sc
59213   CLIP X,Y,B,H
59214   BOX X,Y,B,H
59215   IF Xmax#<Xmin# THEN SWAP Xmax#,Xmin#
59216   IF Ymax#<Ymin# THEN SWAP Ymax#,Ymin#
59217   Yh10=Y+H-10
59218   B20=B-20
59219   H20=H-20
59220   Pix_Sc=150
59221   Xmami#=Xmax#-Xmin#
59222   Ymami#=Ymax#-Ymin#
59223   IF Flag=1 THEN
59224     TEXT HEIGHT =6: TEXT STYLE =0
59225     IF SGN(Xmin#*Xmax#)=-1 THEN
59226       Xi#= ABS(Xmin#)/( ABS(Xmin#)+ ABS(Xmax#))
59227       Xs0#=X+10+Xi#*B20
59228     ELSE
59229       Xs0#=X+10
59230     ENDIF
59231     IF SGN(Ymin#*Ymax#)=-1 THEN
59232       Yi#= ABS(Ymin#)/( ABS(Ymin#)+ ABS(Ymax#))
59233       Ys0#=Yh10-Yi#*H20
59234     ELSE
59235       Ys0#=Yh10
59236     ENDIF
59237     DRAW X+10,Ys0# TO X+B-10,Ys0#
59238     DRAW Xs0#,Y+H-10 TO Xs0#,Y+10
59239     St#=10^ INT( LOG(10,(Xmami#/(B20/Pix_Sc)))+.5)
59240     FOR Xa#=0 TO MAX( ABS(Xmin#), ABS(Xmax#)) STEP St#
59241       X1#=Xs0#+Xa#*B20/Xmami#
59242       X2#=Xs0#-Xa#*B20/Xmami#
59243       DRAW X1#,Ys0# TO X1#,Ys0#+10
59244       TEXT X1#+1,Ys0#+10, STR$(Xa#)
59245       DRAW X2#,Ys0# TO X2#,Ys0#+10
59246       TEXT X2#+1,Ys0#+10, STR$(-Xa#)
59247     NEXT Xa#
59248     St#=10^ INT( LOG(10,(Ymami#/(H20/Pix_Sc)))+.5)
59249     FOR Ya#=St# TO MAX( ABS(Ymin#), ABS(Ymax#)) STEP St#
59250       Y1#=Ys0#+Ya#*H20/Ymami#
59251       Y2#=Ys0#-Ya#*H20/Ymami#
59252       DRAW Xs0#,Y1# TO Xs0#-10,Y1#
59253       TEXT Xs0#+1,Y1#, STR$(-Ya#)
59254       DRAW Xs0#,Y2# TO Xs0#-10,Y2#
59255       TEXT Xs0#+1,Y2#, STR$(Ya#)
59256     NEXT Ya#
59257   ENDIF
59258   CLIP X+20,Y+10 TO X+B-10,Yh10
59259   ON ERROR GOTO Erbeh
59260   X0#=Xs0#+Xx#(1,0)*B20/Xmami#
59261   Y0#=Ys0#-Xx#(1,1)*H20/Ymami#
59262   FOR I#=2 TO N
59263     Xz#=Xs0#+Xx#(I#,0)*B20/Xmami#
59264     Yz#=Ys0#-Xx#(I#,1)*H20/Ymami#
59265     IF Flag2=1 THEN
59266       IF ABS(Y0#-Yz#)<H THEN
59267         DRAW X0#,Y0# TO Xz#,Yz#
59268       ELSE
59269         DRAW Xz#,Yz#
59270       ENDIF
59271     ELSE
59272       IF Flag2=2 THEN
59273         DRAW Xz#-2,Yz#-2 TO Xz#+2,Yz#+2
59274         DRAW Xz#-2,Yz#+2 TO Xz#+2,Yz#-2
59275       ELSE
59276         PRINT "PROC Fkt_Plot_2:Flag 2 muž den Wert 1 oder 2 annehmen"
59277         STOP
59278       ENDIF
59279     ENDIF
59280     X0#=Xz#
59281     Y0#=Yz#
59282   NEXT I#
59283   CLIP
59284   ON ERROR GOTO 0
59285   LPOKE VARPTR(X#(0,0)),Feld
59286 RETURN
59287 DEF FN Hermite#(N,X#)
59288   LOCAL H#,H1#,H2#,I
59289   IF N=0 THEN
59290     H#=1
59291   ELSE
59292     IF N=1 THEN
59293       H#=X#
59294     ELSE
59295       H2#=1
59296       H1#=X#
59297       FOR I=2 TO N
59298         H#=X#*H1#+(1-P#)*H2#
59299         H2#=H1#
59300         H1#=H#
59301       NEXT I
59302     ENDIF
59303   ENDIF
59304 RETURN H#
59305 DEF FN Tsch#(A#,B#,T#,A0#,A,N)
59306   LOCAL Feld2= LPEEK( VARPTR(A#(0)))
59307   LPOKE VARPTR(A#(0)), LPEEK(A)
59308   LOCAL X#,B1#,B2#,B#,F#
59309   X#=(2*T#-A#-B#)/(B#-A#)
59310   B2#=0
59311   B1#=0
59312   FOR I=N TO 1 STEP -1
59313     B#=2*X#*B1#-B2#+A#(I)
59314     B2#=B1#
59315     B1#=B#
59316   NEXT I
59317   B#=2*X#*B1#-B2#+2*A0#
59318   LPOKE VARPTR(A#(0)),Feld2
59319 RETURN .5*(B#-B2#)
59320 DEF PROC Tscheb_Approx(Index#,N#,A#,B#,R A0#,A,F)
59321   LOCAL Feld= LPEEK( VARPTR(F#(0)))
59322   LPOKE VARPTR(F#(0)), LPEEK(F)
59323   LOCAL Feld2= LPEEK( VARPTR(A#(0)))
59324   LPOKE VARPTR(A#(0)), LPEEK(A)
59325   LOCAL J,T#,Nu
59326   FOR J=0 TO N#
59327     T#=.5*(A#+B#)+.5*(B#-A#)* COS(J* PI /N#)
59328     F#(J)=FN F#(Index#,T#)
59329   NEXT J
59330   F#(0)=.5*F#(0)
59331   F#(N#)=.5*F#(N#)
59332   A0#=0
59333   FOR J=0 TO N#
59334     A0#=A0#+F#(J)
59335   NEXT J
59336   A0#=A0#/N#
59337   FOR Nu=1 TO N#-1
59338     FOR J=0 TO N#
59339       A#(Nu)=A#(Nu)+F#(J)* COS(Nu*J* PI /N#)
59340     NEXT J
59341     A#(Nu)=2*A#(Nu)/N#
59342   NEXT Nu
59343   FOR J=0 TO N#
59344     A#(N#)=A#(N#)+(-1)^J*F#(J)
59345   NEXT J
59346   A#(N#)=A#(N#)/N#
59347   LPOKE VARPTR(F#(0)),Feld
59348   LPOKE VARPTR(A#(0)),Feld2
59349 RETURN
59350 DEF FN Tscheby#(N,X#)
59351   LOCAL T#,I,T2#,T1#
59352   IF N=0 THEN
59353     T#=1
59354   ELSE
59355     IF N=1 THEN
59356       T#=X#
59357     ELSE
59358       T2#=1
59359       T1#=X#
59360       FOR I=2 TO N
59361         T#=2*X#*T1#-T2#
59362         T2#=T1#
59363         T1#=T#
59364       NEXT I
59365     ENDIF
59366   ENDIF
59367 RETURN T#
59368 DEF FN Newton_Cotes#(X,N)
59369   LOCAL Feld= LPEEK( VARPTR(X#(0,0)))
59370   LPOKE VARPTR(X#(0,0)), LPEEK(X)
59371   LOCAL H#,R,A,S#,In#,Mit#
59372   IF N<6 THEN
59373     PRINT "FN Newton_Cotes: Es muž ber mehr als 5 Punkte integriert werden"
59374     STOP
59375   ENDIF
59376   N=N-1
59377   H#=X#(2,0)-X#(1,0)
59378   R=N MOD 7
59379   A=N\7
59380   Mit#=1
59381   IF A>0 THEN
59382     FOR I=1 TO A
59383       S#=751*X#(Mit#,1)+3577*X#(Mit#+1,1)+1323*X#(Mit#+2,1)+2989*X#(Mit#+3,1)
59384       S#=S#+2989*X#(Mit#+4,1)+1323*X#(Mit#+5,1)+3577*X#(Mit#+6,1)+751*X#(Mit#+7,1)
59385       In#=In#+7*H#*S#/17280
59386       Mit#=Mit#+7
59387     NEXT I
59388   ENDIF
59389   IF R>0 THEN
59390     IF R=1 THEN
59391       I1#=3*H#*(X#(Mit#-2,1)+3*X#(Mit#-1,1)+3*X#(Mit#,1)+X#(Mit#+1,1))/8
59392       I2#=H#*(X#(Mit#-2,1)+4*X#(Mit#-1,1)+X#(Mit#,1))/3
59393       In#=In#+I1#-I2#
59394     ELSE
59395       IF R=2 THEN
59396         In#=In#+H#*(X#(Mit#,1)+4*X#(Mit#+1,1)+X#(Mit#+2,1))/3
59397       ELSE
59398         IF R=3 THEN
59399           In#=In#+3*H#*(X#(Mit#,1)+3*X#(Mit#+1,1)+3*X#(Mit#+2,1)+X#(Mit#+3,1))/8
59400         ELSE
59401           IF R=4 THEN
59402             In#=In#+2*H#*(7*X#(Mit#,1)+32*X#(Mit#+1,1)+12*X#(Mit#+2,1))/45
59403             In#=In#+2*H#*(32*X#(Mit#+3,1)+7*X#(Mit#+4,1))/45
59404           ELSE
59405             IF R=5 THEN
59406               S#=19*X#(Mit#,1)+75*X#(Mit#+1,1)+50*X#(Mit#+2,1)
59407               S#=S#+50*X#(Mit#+3,1)+75*X#(Mit#+4,1)+19*X#(Mit#+5,1)
59408               In#=In#+5*H#*S#/288
59409             ELSE
59410               IF R=6 THEN
59411                 S#=41*X#(Mit#,1)+216*X#(Mit#+1,1)+27*X#(Mit#+2,1)
59412                 S#=S#+272*X#(Mit#+3,1)+27*X#(Mit#+4,1)+216*X#(Mit#+5,1)
59413                 In#=In#+6*H#*(S#+41*X#(Mit#+6,1))/840
59414               ENDIF
59415             ENDIF
59416           ENDIF
59417         ENDIF
59418       ENDIF
59419     ENDIF
59420   ENDIF
59421   LPOKE VARPTR(X#(0,0)),Feld
59422 RETURN In#
59423 DEF PROC Diff(X,N)
59424   LOCAL Feld= LPEEK( VARPTR(X#(0,0)))
59425   LPOKE VARPTR(X#(0,0)), LPEEK(X)
59426   LOCAL H#=X#(2,0)-X#(1,0)
59427   IF N<7 THEN
59428     RETURN
59429   ENDIF
59430   FOR I=1 TO 3
59431     X#(I,2)=-3*X#(I+4,1)+16*X#(I+3,1)-36*X#(I+2,1)+48*X#(I+1,1)
59432     X#(I,2)=(X#(I,2)-25*X#(I,1))/(12*H#)
59433     X#(I,3)=11*X#(I+4,1)-56*X#(I+3,1)+114*X#(I+2,1)-104*X#(I+1,1)
59434     X#(I,3)=(X#(I,3)+35*X#(I,1))/(12*H#*H#)
59435     X#(I,4)=-3*X#(I+4,1)+14*X#(I+3,1)-24*X#(I+2,1)+18*X#(I+1,1)
59436     X#(I,4)=(X#(I,4)-5*X#(I,1))/(2*H#*H#*H#)
59437   NEXT I
59438   FOR I=4 TO N-3
59439     X#(I,2)=X#(I+3,1)-9*X#(I+2,1)+45*X#(I+1,1)-45*X#(I-1,1)
59440     X#(I,2)=(X#(I,2)+9*X#(I-2,1)-X#(I-3,1))/(60*H#)
59441     X#(I,3)=2*X#(I+3,1)-27*X#(I+2,1)+270*X#(I+1,1)-490*X#(I,1)
59442     X#(I,3)=(X#(I,3)+270*X#(I-1,1)-27*X#(I-2,1)+2*X#(I-3,1))/(180*H#*H#)
59443     X#(I,4)=-X#(I+3,1)+8*X#(I+2,1)-13*X#(I+1,1)+13*X#(I-1,1)
59444     X#(I,4)=(X#(I,4)-8*X#(I-2,1)+X#(I-3,1))/(8*H#*H#*H#)
59445   NEXT I
59446   FOR I=N-2 TO N
59447     X#(I,2)=3*X#(I-4,1)-16*X#(I-3,1)+36*X#(I-2,1)-48*X#(I-1,1)
59448     X#(I,2)=(X#(I,2)+25*X#(I,1))/(12*H#)
59449     X#(I,3)=11*X#(I-4,1)-56*X#(I-3,1)+114*X#(I-2,1)-104*X#(I-1,1)
59450     X#(I,3)=(X#(I,3)+35*X#(I,1))/(12*H#*H#)
59451     X#(I,4)=3*X#(I-4,1)-14*X#(I-3,1)+24*X#(I-2,1)-18*X#(I-1,1)
59452     X#(I,4)=(X#(I,4)+5*X#(I,1))/(2*H#*H#*H#)
59453   NEXT I
59454   LPOKE VARPTR(X#(0,0)),Feld
59455 RETURN
59456 DEF PROC Randwert(Index#,A#,Alp#,B#,Bet#,R S#,Eps#)
59457   H#=(B#-A#)/100
59458   REPEAT
59459     S0#=S#
59460     An#=Alp#
59461     Rk_Fehl(Index#,A#,B#,An#,S0#,Eps#,H#,Init#)
59462     F0#=An#-Bet#
59463     An#=Alp#
59464     S0#=S#
59465     Ds#=S0#* SQR(Eps#)
59466     Rk_Fehl(Index#,A#,B#,An#,S0#+Ds#,Eps#,H#,Init#)
59467     Dfs#=An#-Bet#
59468     Dd#=(Dfs#-Fs#)/Ds#
59469     S#=S0#-F0#/Dd#
59470   UNTIL ABS(F0#/Dd#)<.01#
59471 RETURN
59472 DEF PROC Rk_Fehl(Index#,T0#,Tend#,R X0#,R Xs0#,Tol#,R H#,R Init#)
59473   LOCAL Abb#,Xss0#,Xss#,Xs#,X#,T#,Tole#,Te#,Hn#
59474   IF Init#=0 THEN
59475     Fehl_Init
59476     Init#=1
59477   ENDIF
59478   Hn#=H#
59479   Xss0#=FN Fss#(Index#,T0#,X0#,Xs0#)
59480   REPEAT
59481     H#=Hn#
59482     Xss#=Xss0#
59483     T#=T0#
59484     X#=X0#
59485     Xs#=Xs0#
59486     Rk_Fehl_Step(Index#,T#,X#,Xs#,Xss#,H#,Te#)
59487     Hn#=H#*(Tol#/Te#)^(1/5)
59488   UNTIL ABS((Hn#-H#)/H#)<=1D-4
59489   H#=Hn#
59490   REPEAT
59491     Xss#=Xss0#
59492     T#=T0#
59493     X#=X0#
59494     Xs#=Xs0#
59495     Rk_Fehl_Step(Index#,T#,X#,Xs#,Xss#,H#,Te#)
59496     H#=H#*(Tol#/Te#)^(1/5)
59497     T0#=T#
59498     X0#=X#
59499     Xs0#=Xs#
59500     Xss0#=Xss#
59501   UNTIL T#>=Tend#
59502   IF T0#>Tend# THEN
59503     Rk_Fehl_Step(Index#,T0#,X0#,Xs0#,Xss0#,Tend#-T0#,Te#)
59504   ENDIF
59505 RETURN
59506 DEF PROC Rk_Fehl_Step(Index#,R T0#,R X0#,R Xs0#,R Xss0#,H#,R Te#)
59507   LOCAL Sum1#,Sum2#,Sum3#,K,T#,X#,Xs#,Xd#
59508   F#(0)=Xss0#
59509   FOR K=1 TO 8
59510     T#=T0#+Alp#(K)*H#
59511     Sum1#=0
59512     Sum2#=0
59513     FOR L=0 TO K-1
59514       Sum1#=Sum1#+Gam#(K,L)*F#(L)
59515       Sum2#=Sum2#+Bet#(K,L)*F#(L)
59516     NEXT L
59517     X#=X0#+Xs0#*Alp#(K)*H#+H#*H#*Sum1#
59518     Xs#=Xs0#+H#*Sum2#
59519     F#(K)=FN Fss#(Index#,T#,X#,Xs#)
59520   NEXT K
59521   Sum1#=0
59522   Sum2#=0
59523   Sum3#=0
59524   FOR K=0 TO 7
59525     Sum1#=Sum1#+C#(K,1)*F#(K)
59526     Sum2#=Sum2#+C#(K,2)*F#(K)
59527     Sum3#=Sum3#+C#(K,3)*F#(K)
59528   NEXT K
59529   Sum2#=Sum2#+C#(8,2)*F#(K)
59530   X0#=X0#+Xs0#*H#+H#*H#*Sum1#
59531   Xd#=X0#+Xs0#*H#+H#*H#*Sum2#
59532   Xs0#=Xs0#+H#*Sum3#
59533   T0#=T0#+H#
59534   Xss0#=F#(8)
59535   Te#= ABS(X#-Xd#)
59536 RETURN
59537 DEF PROC Fehl_Init
59538   LOCAL I,J
59539  -Fehl
59540   DATA 4#/15#,2#/5#,3#/5#,9#/10#,3#/4#,2#/7#,1#,1#
59541   DATA 4#/15#
59542   DATA 1#/10#,3#/10#
59543   DATA 3#/20#,0#,9#/20#
59544   DATA 9#/40#,0#,0#,27#/40#
59545   DATA 11#/48#,0#,0#,5#/8#,-5#/48#
59546   DATA 27112#/194481#,0#,0#,56450#/64827#,80000#/194481#,-24544#/21609#
59547   DATA -26033#/41796#,0#,0#,-236575#/38313#,-14500#/10449#,275936#/45279#
59548   DATA 228095#/73788#
59549   DATA 7#/81#,0#,0#,0#,-250#/3483#,160#/351#,2401#/5590#,1#/10#
59550   DATA 8#/225#
59551   DATA 1#/25#,1#/25#
59552   DATA 9#/160#,81#/800#,9#/400#
59553   DATA 81#/640#,0#,729#/3200#,81#/1600#
59554   DATA 11283#/88064#,0#,3159#/88064#,7275#/44032#,-33#/688#
59555   DATA 6250#/194481#,0#,0#,0#,-3400#/194481#,1696#/64827#
59556   DATA -6706#/45279#,0#,0#,0#,1047925#/1946997#,-147544#/196209#
59557   DATA 1615873#/1874886#
59558   DATA 31#/360#,0#,0#,0#,0#,64#/585#,2401#/7800#,-1#/300#
59559   RESTORE Fehl
59560   FOR I=1 TO 8
59561     READ Alp#(I)
59562   NEXT I
59563   FOR I=1 TO 8
59564     FOR J=0 TO I-1
59565       READ Bet#(I,J)
59566     NEXT J
59567   NEXT I
59568   FOR I=1 TO 8
59569     FOR J=0 TO I-1
59570       READ Gam#(I,J)
59571     NEXT J
59572   NEXT I
59573   FOR I=0 TO 7
59574     C#(I,1)=Gam#(8,I)
59575     C#(I,3)=Bet#(8,I)
59576     C#(I,2)=C#(I,1)
59577   NEXT I
59578   C#(7,2)=0
59579   C#(8,2)=C#(7,1)
59580 RETURN
59581 DEF FN Adam_Step#(Index,X#,Y#,Ys#,Ys1#,Ys2#,Ys3#,H#)
59582   LOCAL Ys#,Yn#,Ysp1#
59583   Yn#=Y#+H#*(55*Ys#-59*Ys1#+37*Ys2#-9*Ys3#)/24
59584   Ysp1#=FN Fs#(Index,X#+H#,Yn#)
59585   Y#=Y#+H#*(9*Ysp1#+19*Ys#-5*Ys1#+Ys2#)/24
59586 RETURN Y#
59587 DEF PROC Adam_Bash(Index,Xa#,Ya#,Xe#,X,N)
59588   LOCAL Feld= LPEEK( VARPTR(X#(0,0)))
59589   LPOKE VARPTR(X#(0,0)), LPEEK(X)
59590   LOCAL H#,Ys3#,Ys2#,Ys1#,Ys#
59591   H#=(Xe#-Xa#)/N
59592   Ys3#=FN Fs#(Index#,Xa#,Ya#)
59593   X#(1,1)=FN Runge_Step#(Index#,Xa#,Ya#,H#)
59594   X#(1,0)=Xa#+H#
59595   Ys2#=FN Fs#(Index#,X#(1,0),X#(1,1))
59596   X#(2,1)=FN Runge_Step#(Index#,X#(1,0),X#(1,1),H#)
59597   X#(2,0)=X#(1,0)+H#
59598   Ys1#=FN Fs#(Index#,X#(2,0),X#(2,1))
59599   X#(3,1)=FN Runge_Step#(Index#,X#(2,0),X#(2,1),H#)
59600   X#(3,0)=X#(2,0)+H#
59601   Ys#=FN Fs#(Index#,X#(3,0),X#(3,1))
59602   FOR I=4 TO N
59603     X#(I,1)=FN Adam_Step#(Index#,X#(I-1,0),X#(I-1,1),Ys#,Ys1#,Ys2#,Ys3#,H#)
59604     X#(I,0)=X#(I-1,0)+H#
59605     Ys3#=Ys2#
59606     Ys2#=Ys1#
59607     Ys1#=Ys#
59608     Ys#=FN Fs#(Index#,X#(I,0),X#(I,1))
59609   NEXT I
59610   LPOKE VARPTR(X#(0,0)),Feld
59611 RETURN
59612 DEF PROC Runge_Step_Sys(Index,Anz#,X#,Y,K,H,S,H#)
59613   LOCAL Feld= LPEEK( VARPTR(Y#(0)))
59614   LPOKE VARPTR(Y#(0)), LPEEK(Y)
59615   LOCAL Feld2= LPEEK( VARPTR(K#(0,0)))
59616   LPOKE VARPTR(K#(0,0)), LPEEK(K)
59617   LOCAL Feld3= LPEEK( VARPTR(H#(0)))
59618   LPOKE VARPTR(H#(0)), LPEEK(H)
59619   LOCAL Feld4= LPEEK( VARPTR(S#(0)))
59620   LPOKE VARPTR(S#(0)), LPEEK(S)
59621   FOR I#=1 TO Anz#
59622     S#(I#)=Y#(I#)
59623   NEXT I#
59624   Fs(Index,X#,S,H)
59625   FOR I#=1 TO Anz#
59626     K#(I#,0)=H#*H#(I#)
59627     S#(I#)=Y#(I#)+.5*K#(I#,0)
59628   NEXT I#
59629   Fs(Index,X#+.5*H#,S,H)
59630   FOR I#=1 TO Anz#
59631     K#(I#,1)=H#*H#(I#)
59632     S#(I#)=Y#(I#)+.5*K#(I#,1)
59633   NEXT I#
59634   Fs(Index,X#+.5*H#,S,H)
59635   FOR I#=1 TO Anz#
59636     K#(I#,2)=H#*H#(I#)
59637     S#(I#)=Y#(I#)+K#(I#,2)
59638   NEXT I#
59639   Fs(Index,X#+H#,S,H)
59640   FOR I#=1 TO Anz#
59641     K#(I#,3)=H#*H#(I#)
59642     Y#(I#)=Y#(I#)+(K#(I#,0)+2*K#(I#,1)+2*K#(I#,2)+K#(I#,3))/6
59643   NEXT I#
59644   LPOKE VARPTR(Y#(0)),Feld
59645   LPOKE VARPTR(K#(0,0)),Feld2
59646   LPOKE VARPTR(H#(0)),Feld3
59647   LPOKE VARPTR(S#(0)),Feld4
59648 RETURN
59649 DEF FN Runge_Step#(Index,X#,Y#,H#)
59650   LOCAL K0#,K1#,K2#,K3#
59651   K0#=H#*FN Fs#(Index,X#,Y#)
59652   K1#=H#*FN Fs#(Index,X#+.5*H#,Y#+.5*K0#)
59653   K2#=H#*FN Fs#(Index,X#+.5*H#,Y#+.5*K1#)
59654   K3#=H#*FN Fs#(Index,X#+H#,Y#+K2#)
59655 RETURN Y#+(K0#+2*K1#+2*K2#+K3#)/6
59656 DEF PROC Runge_Kutta(Index,X#,Xe#,R Y#,R H#,R Eps#)
59657   LOCAL Abb,E1#,E2#,Hh#,Ha#
59658   Eps#= ABS(Eps#)
59659   IF Eps#<1D-15 OR Eps#>1D-4 THEN
59660     Eps#=1D-9
59661   ENDIF
59662   REPEAT
59663     REPEAT
59664       Abb=0
59665       E1#=FN Runge_Step#(Index,X#,Y#,H#/2)
59666       E1#=FN Runge_Step#(Index,X#+H#/2,E1#,H#/2)
59667       E2#=FN Runge_Step#(Index,X#,Y#,H#)
59668       Hh#=( ABS(32*(E2#-E1#)/(31*Eps#)))^(1/5)
59669       IF Hh#>=3 THEN
59670         H#=2*H#/Hh#
59671       ELSE
59672         Abb=1
59673       ENDIF
59674     UNTIL Abb=1
59675     Y#=E1#
59676     X#=X#+H#
59677     H#=H#/Hh#
59678   UNTIL X#>=Xe#
59679   IF X#>Xe# THEN
59680     Ha#=X#-Xe#
59681     Y#=FN Runge_Step#(Index,X#,Y#,-Ha#)
59682   ENDIF
59683 RETURN
59684 DEF PROC Newton_Sys(X,Index1,N,Dx,A,B)
59685   LOCAL Feld= LPEEK( VARPTR(X#(0)))
59686   LPOKE VARPTR(X#(0)), LPEEK(X)
59687   LOCAL Feld2= LPEEK( VARPTR(Dx#(0)))
59688   LPOKE VARPTR(Dx#(0)), LPEEK(Dx)
59689   LOCAL Feld3= LPEEK( VARPTR(A#(0,0)))
59690   LPOKE VARPTR(A#(0,0)), LPEEK(A)
59691   LOCAL Feld4= LPEEK( VARPTR(B#(0)))
59692   LPOKE VARPTR(B#(0)), LPEEK(B)
59693   LOCAL Zahl,Kontr#,I,J,Kontr#,F2#,Hilf#
59694   Zahl=0
59695   REPEAT
59696     Kontr#=0
59697     ' Matrix der Ableitungen aufstellen
59698     FOR I=1 TO N
59699       B#(I)=FN F#(Index-1+I,X#)
59700       FOR J=1 TO N
59701         Hilf#=X#(J)
59702         X#(J)=X#(J)+5D-5
59703         F2#=FN F#(Index-1+I,X#)
59704         X#(J)=Hilf#
59705         A#(I,J)=(F2#-B#(I))/5D-5
59706       NEXT J
59707       B#(I)=-B#(I)
59708     NEXT I
59709     Gauss(A#(0,0),B#(0),N,Dx#(0),Dt#)
59710     FOR I=1 TO N
59711       Kontr#= MAX(Kontr#, ABS(Dx#(I)/X#(I)))
59712       X#(I)=X#(I)+Dx#(I)
59713     NEXT I
59714     Zahl=Zahl+1
59715   UNTIL Kontr#<1E-6 OR Zahl=51
59716   IF Zahl=51 THEN
59717   ENDIF
59718   LPOKE VARPTR(X#(0)),Feld
59719   LPOKE VARPTR(Dx#(0)),Feld2
59720   LPOKE VARPTR(A#(0,0)),Feld3
59721   LPOKE VARPTR(B#(0)),Feld4
59722 RETURN
59723 DEF PROC Gauss_Fit(X,N,M,Hilf1,Hilf2,Hilf3)
59724   LOCAL Feld= LPEEK( VARPTR(X#(0,0)))
59725   LPOKE VARPTR(X#(0,0)), LPEEK(X)
59726   LOCAL Feld2= LPEEK( VARPTR(Hilf1#(0,0)))
59727   LPOKE VARPTR(Hilf1#(0,0)), LPEEK(Hilf1)
59728   LOCAL Feld3= LPEEK( VARPTR(Hilf2#(0)))
59729   LPOKE VARPTR(Hilf2#(0)), LPEEK(Hilf2)
59730   LOCAL Feld4= LPEEK( VARPTR(Hilf3#(0,0)))
59731   LPOKE VARPTR(Hilf3#(0,0)), LPEEK(Hilf3)
59732   LOCAL D#,D1#,Zw#,Li,Lm,I,Z1#,Z#,F#,H#,Abb,K,K1,Df#,Dh#
59733   LOCAL J,J1,M,S#
59734   D#=1E-4
59735   D1#=1E-6
59736   Zw#=0
59737   Li=0
59738   Lm=20
59739   FOR I=1 TO N
59740     X#(I,2)=1/X#(I,2)^2
59741   NEXT I
59742   REPEAT
59743     Z1#=Zw#
59744     Zw#=0
59745     Li=Li+1
59746     IF Li>Lm THEN
59747       STOP
59748     ENDIF
59749     FOR I=1 TO N
59750       F#=FN F#(Index,X#(I,0))
59751       Hilf3#(0,I)=F#
59752       H#=X#(I,1)-F#
59753       Zw#=Zw#+H#^2*X#(I,2)
59754       Hilf3#(1,I)=H#
59755     NEXT I
59756     IF ABS(Z1#-Zw#)<D1# THEN
59757       Abb=1
59758     ELSE
59759       FOR K=1 TO M
59760         K1=K+1
59761         Hilf2#(K)=0
59762         Hilf1#(K,K)=0
59763         FOR L=K1 TO M
59764           Hilf1#(K,L)=0
59765         NEXT L
59766         FOR I=1 TO N
59767           P#(K)=P#(K)+D#
59768           F#=FN F#(Index,X#(I,0))
59769           P#(K)=P#(K)-D#
59770           Df#=(F#-Hilf3#(0,I))/D#
59771           Dh#=Df#*X#(I,2)
59772           Hilf2#(K)=Hilf2#(K)+Hilf3#(1,I)*Dh#
59773           Hilf1#(K,K)=Hilf1#(K,K)+Df#*Dh#
59774           FOR L=K1 TO M
59775             P#(L)=P#(L)+D#
59776             F#=FN F#(Index,X#(I,0))
59777             P#(L)=P#(L)-D#
59778             Hilf1#(K,L)=Hilf1#(K,L)+Dh#*(F#-Hilf3#(0,I))/D#
59779             Hilf1#(L,K)=Hilf1#(K,L)
59780           NEXT L
59781         NEXT I
59782       NEXT K
59783       FOR K=1 TO M
59784         FOR L=1 TO M
59785           Hilf2#(K)=Hilf2#(K)+Hilf1#(K,L)*P#(L)
59786         NEXT L
59787       NEXT K
59788       Gauss(Hilf1#(0,0),Hilf2#(0),M,P#(0),Dt#)
59789     ENDIF
59790   UNTIL Abb=1
59791   LPOKE VARPTR(X#(0,0)),Feld
59792   LPOKE VARPTR(Hilf1#(0,0)),Feld2
59793   LPOKE VARPTR(Hilf2#(0)),Feld3
59794   LPOKE VARPTR(Hilf3#(0,0)),Feld4
59795 RETURN
59796 DEF PROC Gauss_Leg_Int(A)
59797   LOCAL Feld= LPEEK( VARPTR(A#(0,0,0)))
59798   LPOKE VARPTR(A#(0,0,0)), LPEEK(A)
59799   LOCAL I,J
59800   -Gauss_Int
59801   DATA .577350269#,1
59802   DATA .774596669#,.55555555555#
59803   DATA 0#,.888888888888#
59804   DATA .86113631159#,.3478548451#
59805   DATA .3399810435848#,.65214515486#
59806   DATA .906179845938#,.23692688505618#
59807   DATA .53846931015#,.478628670499#
59808   DATA 0,.56888888888888#
59809   DATA .932469514#,.1713244923791#
59810   DATA .661209386466#,.36076157305#
59811   DATA .23861918608#,.467913934573#
59812   DATA .94910791234#,.129484966169#
59813   DATA .741531185599#,.279705391489#
59814   DATA .405845151377#,.3818300505051#
59815   DATA 0,.417959183673#
59816   DATA .960289856497#,.101228536290376#
59817   DATA .796666477414#,.22238103445337#
59818   DATA .5255324099163#,.31370664587788#
59819   DATA .18343464249564#,.36268378337836#
59820   DATA .9681602395076#,.08127438836157#
59821   DATA .8360311073266#,.18064816069486#
59822   DATA .6133714327006#,.26061069640293#
59823   DATA .32425342340381#,.31234707704#
59824   DATA 0,.33023935501259#
59825   DATA .973906528517172#,.06667134430869#
59826   DATA .86506336668898#,.14945134915058#
59827   DATA .679409568299#,.21908636251598#
59828   DATA .433395394129#,.26926671930999#
59829   DATA .1488743389816#,.29552422471475#
59830   DATA .978228658146#,.05566856711617#
59831   DATA .887062599768#,.1255803694649#
59832   DATA .73015200557405#,.18629021092773#
59833   DATA .519096129206811#,.23319376459199#
59834   DATA .2695431559#,.26280454451#
59835   DATA 0,.2729250867779#
59836   DATA .9815606342467#,.0471753363865#
59837   DATA .90411725637#,.1069393259953#
59838   DATA .76990267419#,.16007832854334#
59839   DATA .5873179542866#,.203167426723#
59840   DATA .36783149899818#,.23349253653835#
59841   DATA .125233408511469#,.2491470458134#
59842   DATA .984183054718588#,.040484004765#
59843   DATA .91759839922298#,.092121499837728#
59844   DATA .8015780907333#,.13887351021979#
59845   DATA .64234933944034#,.178145980761945#
59846   DATA .448492751036447#,.207816047536889#
59847   DATA .230458315955135#,.226283180262897#
59848   DATA 0,.232551553230874#
59849   DATA .9862838086968#,.035119460331752#
59850   DATA .92843488366357#,.08015808715976#
59851   DATA .82720131506976#,.1215185706879032#
59852   DATA .6872929048117#,.1572031671582#
59853   DATA .51524863635815#,.18553839744779#
59854   DATA .31911236892788#,.20519846372129#
59855   DATA .1080549487073#,.215263853463158#
59856   DATA .9879925180204#,.030753241996117#
59857   DATA .9372733924007#,.07036604748811#
59858   DATA .84820658341043#,.107159220467172#
59859   DATA .72441773136017#,.13957067792615#
59860   DATA .5709721726085#,.16626920581699#
59861   DATA .39415134707756#,.18616100001556#
59862   DATA .2011940939974#,.198431485327116#
59863   DATA 0,.20257824192556#
59864   RESTORE Gauss_Int
59865   FOR I=2 TO 15
59866     FOR J=1 TO I/2
59867       READ A#(I,J,0),A#(I,J,1)
59868       A#(I,I-J+1,0)=-A#(I,J,0)
59869       A#(I,I-J+1,1)=A#(I,J,1)
59870     NEXT J
59871   NEXT I
59872   LPOKE VARPTR(A#(0,0,0)),Feld
59873 RETURN
59874 DEF FN Gauss_Leg#(A#,B#,Index,N,A)
59875   LOCAL Feld= LPEEK( VARPTR(A#(0,0,0)))
59876   LPOKE VARPTR(A#(0,0,0)), LPEEK(A)
59877   LOCAL In#,X#,I
59878   FOR I=1 TO N
59879     X#=(B#-A#)/2*A#(N,I,0)+(B#+A#)/2
59880     In#=In#+A#(N,I,1)*FN F#(Index,X#)
59881   NEXT I
59882   LPOKE VARPTR(A#(0,0,0)),Feld
59883 RETURN(B#-A#)*In#/2
59884 DEF FN Gegen#(N,X#)
59885   LOCAL Y#
59886   Y#=N*(X#*FN Legendre#(N,X#)-FN Legendre#(N-1,X#))/(X#*X#-1)
59887 RETURN Y#
59888 DEF FN Legendre#(N,X#)
59889   LOCAL Y#
59890   IF N=0 THEN
59891     Y#=1
59892   ELSE
59893     IF N=1 THEN
59894       Y#=X#
59895     ELSE
59896       Y0#=1
59897       Y1#=X#
59898       FOR I=2 TO N
59899         Y#=((2*I-1)*X#*Y1#-(I-1)*Y0#)/I
59900         Y0#=Y1#
59901         Y1#=Y#
59902       NEXT I
59903     ENDIF
59904   ENDIF
59905 RETURN Y#
59906 DEF PROC Lagrange_Int(N,X,L)
59907   LOCAL Feld= LPEEK( VARPTR(L#(0)))
59908   LPOKE VARPTR(L#(0)), LPEEK(L)
59909   LOCAL Feld2= LPEEK( VARPTR(X#(0,0)))
59910   LPOKE VARPTR(X#(0,0)), LPEEK(X)
59911   LOCAL I,J
59912   FOR I=1 TO N
59913     L#(I)=1#
59914     FOR J=1 TO N
59915       IF J<>I THEN
59916         L#(I)=L#(I)*(X#(I,1)-X#(J,1))
59917       ENDIF
59918     NEXT J
59919     L#(I)=X#(I,2)/L#(I)
59920   NEXT I
59921   LPOKE VARPTR(L#(0)),Feld
59922   LPOKE VARPTR(X#(0,0)),Feld2
59923 RETURN
59924 DEF FN Lagrange#(X#,N,X,L)
59925   LOCAL Feld= LPEEK( VARPTR(L#(0)))
59926   LPOKE VARPTR(L#(0)), LPEEK(L)
59927   LOCAL Feld2= LPEEK( VARPTR(X#(0,0)))
59928   LPOKE VARPTR(X#(0,0)), LPEEK(X)
59929   LOCAL Aus#,I,Y#,T#
59930   FOR I=1 TO N
59931     IF X#=X#(I,1) THEN
59932       Y#=X#(I,2)
59933       Aus#=1
59934     ENDIF
59935   NEXT I
59936   IF Aus#<>1 THEN
59937     T#=1
59938     FOR I=1 TO N
59939       T#=T#*(X#-X#(I,1))
59940     NEXT I
59941     FOR I=1 TO N
59942       Y#=Y#+L#(I)*T#/(X#-X#(I,1))
59943     NEXT I
59944   ENDIF
59945   LPOKE VARPTR(L#(0)),Feld
59946   LPOKE VARPTR(X#(0,0)),Feld2
59947 RETURN Y#
59948 DEF PROC Spline_Int(N,X,A)
59949   LOCAL Feld= LPEEK( VARPTR(A#(0,0)))
59950   LPOKE VARPTR(A#(0,0)), LPEEK(A)
59951   LOCAL Feld2= LPEEK( VARPTR(X#(0,0)))
59952   LPOKE VARPTR(X#(0,0)), LPEEK(X)
59953   LOCAL N1,I,I1,K,X1#,X2#,X12#,A1#,A2#,B1#,B2#,C1#,C2#,H#
59954   IF N<2 THEN
59955     STOP
59956   ENDIF
59957   N1=N-1
59958   FOR I=1 TO N1
59959     A#(2,I)=1/(X#(I+1,1)-X#(I,1))
59960     A#(1,I)=X#(I+1,2)-X#(I,2)
59961   NEXT I
59962   A#(4,1)=2*A#(2,1)
59963   A#(3,1)=3*A#(1,1)*A#(2,1)^2
59964   FOR I=2 TO N1
59965     I1=I-1
59966     A#(4,I)=2*A#(2,I1)+2*A#(2,I)
59967     A#(3,I)=3*(A#(1,I)*A#(2,I)^2+A#(1,I1)*A#(2,I1)^2)
59968   NEXT I
59969   A#(4,N)=A#(2,N1)+A#(2,N1)
59970   A#(3,N)=3*A#(1,N1)*A#(2,N1)^2
59971   FOR I=2 TO N
59972     I1=I-1
59973     P#=A#(2,I1)/A#(4,I1)
59974     A#(3,I)=A#(3,I)-A#(3,I1)*P#
59975     A#(4,I)=A#(4,I)-A#(2,I1)*P#
59976   NEXT I
59977   A#(4,N)=A#(3,N)/A#(4,N)
59978   FOR I=1 TO N1
59979     K=N-I
59980     A#(4,K)=(A#(3,K)-A#(2,K)*A#(4,K+1))/A#(4,K)
59981   NEXT I
59982   FOR I=1 TO N1
59983     I1=I+1
59984     X1#=X#(I,1)
59985     X2#=X1#^2
59986     X3#=X#(I1,1)^2
59987     A1#=A#(1,I)*A#(2,I)
59988     A2#=A#(4,I1)-A1#
59989     A1#=A#(4,I)-A1#
59990     B1#=(X3#-X2#)*A#(2,I)
59991     B2#=2*X#(I1,1)-B1#
59992     B1#=X1#+X1#-B1#
59993     C1#=(X3#*X#(I1,1)-X1#*X2#)*A#(2,I)
59994     C2#=3*X3#-C1#
59995     C1#=3*X2#-C1#
59996     H#=(A2#*B1#-A1#*B2#)/(C2#*B1#-C1#*B2#)
59997     A#(3,I)=(A1#-H#*C1#)/B1#
59998     A#(2,I)=A#(4,I)-2*A#(3,I)*X1#-3*H#*X2#
59999     A#(1,I)=X#(I,2)-A#(2,I)*X1#-(A#(3,I)+H#*X1#)*X2#
60000     A#(4,I)=H#
60001   NEXT I
60002   LPOKE VARPTR(A#(0,0)),Feld
60003   LPOKE VARPTR(X#(0,0)),Feld2
60004 RETURN
60005 DEF FN Spline#(X#,N,X,A)
60006   LOCAL Feld= LPEEK( VARPTR(A#(0,0)))
60007   LPOKE VARPTR(A#(0,0)), LPEEK(A)
60008   LOCAL Feld2= LPEEK( VARPTR(X#(0,0)))
60009   LPOKE VARPTR(X#(0,0)), LPEEK(X)
60010   LOCAL N1,I,Y#
60011   FOR I=2 TO N
60012     IF X#<X#(I,1) THEN EXIT
60013   NEXT I
60014   I=I-1
60015   IF I=N THEN I=N-1
60016   Y#=A#(1,I)+X#*(A#(2,I)+X#*(A#(3,I)+X#*A#(4,I)))
60017   LPOKE VARPTR(A#(0,0)),Feld
60018   LPOKE VARPTR(X#(0,0)),Feld2
60019 RETURN Y#
60020 DEF PROC Band(A,X,N,K)
60021   LOCAL Feld= LPEEK( VARPTR(A#(0,0)))
60022   LPOKE VARPTR(A#(0,0)), LPEEK(A)
60023   LOCAL Feld2= LPEEK( VARPTR(X#(0)))
60024   LPOKE VARPTR(X#(0)), LPEEK(X)
60025   LOCAL Q#,K1,K2,K21,K22,I,Ii,Ii1,J,Jj,L,Ll,Lll
60026   IF K<=0 OR K>=N# THEN
60027     PRINT "PROC Band: Anzahl der Gleichungen nicht sinnvoll"
60028     STOP
60029   ENDIF
60030   K1=K+1
60031   K2=K+2
60032   K21=2*K+1
60033   K22=K21+1
60034   Jj=K21
60035   Ii=N#-K+1
60036   FOR I=Ii TO N#
60037     FOR J=Jj TO K21
60038       A#(J,I)=0
60039     NEXT J
60040     Jj=Jj-1
60041   NEXT I
60042   FOR I=2 TO N#
60043     Ii=I-K
60044     FOR J=1 TO K
60045       IF Ii>0 THEN
60046         Q#=A#(J,I)/A#(K1,Ii)
60047         J1=J+1
60048         Jk=J+K
60049         Lll=K2
60050         FOR L=J1 TO Jk
60051           A#(L,I)=A#(L,I)-A#(Lll,Ii)*Q#
60052           Lll=Lll+1
60053         NEXT L
60054         A#(K22,I)=A#(K22,I)-A#(K22,Ii)*Q#
60055         A#(J,I)=Q#
60056       ENDIF
60057       Ii=Ii+1
60058     NEXT J
60059   NEXT I
60060   A#(K22,N#)=A#(K22,N#)/A#(K1,N#)
60061   Ii=N#-1
60062   FOR I=2 TO N#
60063     Q#=A#(K22,Ii)
60064     Jj=Ii+K
60065     IF Jj>N# THEN Jj=N#
60066     Ii1=Ii+1
60067     Ll=K2
60068     FOR J=Ii1 TO Jj
60069       Q#=Q#-A#(Ll,Ii)*A#(K22,J)
60070       Ll=Ll+1
60071     NEXT J
60072     X#(Ii)=Q#/A#(K1,Ii)
60073     Ii=Ii-1
60074   NEXT I
60075   LPOKE VARPTR(A#(0,0)),Feld
60076   LPOKE VARPTR(X#(0)),Feld2
60077 RETURN
60078 DEF PROC Gauss_Seidel(A,B,N,X)
60079   LOCAL Feld= LPEEK( VARPTR(A#(0,0)))
60080   LPOKE VARPTR(A#(0,0)), LPEEK(A)
60081   LOCAL Feld2= LPEEK( VARPTR(X#(0)))
60082   LPOKE VARPTR(X#(0)), LPEEK(X)
60083   LOCAL Feld3= LPEEK( VARPTR(B#(0)))
60084   LPOKE VARPTR(B#(0)), LPEEK(B)
60085   Mx=40
60086   D#=1D-10
60087   R1#=1D+30
60088   L=1
60089   REPEAT
60090     R#=0
60091     Re#=0
60092     FOR I=1 TO N
60093       S#=B#(I)
60094       FOR K=1 TO N
60095         S#=S#-A#(I,K)*X#(K)
60096       NEXT K
60097       X#(I)=X#(I)+S#/A#(I,I)
60098       R#=R#+ ABS(X#(I))
60099     NEXT I
60100     IF ABS(R#-R1#)<D# THEN
60101       Abb=1
60102     ELSE
60103       IF L=Mx# THEN
60104         Abb=1
60105       ELSE
60106         R1#=R#
60107         L=L+1
60108       ENDIF
60109     ENDIF
60110   UNTIL Abb=1
60111   IF L=Mx# THEN
60112     STOP
60113   ENDIF
60114   LPOKE VARPTR(A#(0,0)),Feld
60115   LPOKE VARPTR(X#(0)),Feld2
60116   LPOKE VARPTR(B#(0)),Feld3
60117 RETURN
60118 DEF PROC Gauss(A,B,N,X,R Dt#)
60119   LOCAL Feld= LPEEK( VARPTR(A#(0,0)))
60120   LPOKE VARPTR(A#(0,0)), LPEEK(A)
60121   LOCAL Feld2= LPEEK( VARPTR(X#(0)))
60122   LPOKE VARPTR(X#(0)), LPEEK(X)
60123   LOCAL Feld3= LPEEK( VARPTR(B#(0)))
60124   LPOKE VARPTR(B#(0)), LPEEK(B)
60125   LOCAL I1,N,J,J1,Ax#,Am#,Ix,L,Eps#,I
60126   LOCAL S#,K,N1
60127   Eps#=1D-7
60128   Dt#=1
60129   IF N>1 THEN
60130     FOR J=2 TO N
60131       J1=J-1
60132       Ax#=A#(J1,J1)
60133       Am#= ABS(Ax#)
60134       Ix=J1
60135       FOR L=J1 TO N
60136         IF ABS(A#(L,J1))>Am# THEN
60137           Ax#=A#(L,J1)
60138           Am#= ABS(Ax#)
60139           Ix=L
60140         ENDIF
60141       NEXT L
60142       IF Am#<Eps# THEN
60143         PRINT "Matrix singul„r ist"
60144         STOP
60145       ENDIF
60146       IF Ix<>J1 THEN
60147         Dt#=-Dt#
60148         SWAP B#(J1),B#(Ix)
60149         FOR L=J1 TO N
60150           SWAP A#(J1,L),A#(Ix,L)
60151         NEXT L
60152       ENDIF
60153       FOR I=J TO N
60154         H#=A#(I,J1)/Ax#
60155         B#(I)=B#(I)-H#*B#(J1)
60156         FOR K=J TO N
60157           A#(I,K)=A#(I,K)-H#*A#(J1,K)
60158         NEXT K
60159       NEXT I
60160     NEXT J
60161   ENDIF
60162   IF ABS(A#(N,N))<Eps# THEN
60163     PRINT "PROC Gauss: Gleichungssystem hat keine L”sung, da"
60164     PRINT "Matrix singul„r ist"
60165     PRINT "ABBRUCH der Rechnung"
60166     STOP
60167   ENDIF
60168   X#(N)=B#(N)/A#(N,N)
60169   Dt#=Dt#*A#(N,N)
60170   FOR I=N-1 TO 1 STEP -1
60171     I1=I+1
60172     S#=0
60173     FOR K=I1 TO N
60174       S#=S#+A#(I,K)*X#(K)
60175     NEXT K
60176     X#(I)=(B#(I)-S#)/A#(I,I)
60177     Dt#=Dt#*A#(I,I)
60178   NEXT I
60179   LPOKE VARPTR(A#(0,0)),Feld
60180   LPOKE VARPTR(X#(0)),Feld2
60181   LPOKE VARPTR(B#(0)),Feld3
60182 RETURN
60183 DEF PROC Fourier_Sin(A#,B#,M)
60184   LOCAL Feld2= LPEEK( VARPTR(A#(0)))
60185   LPOKE VARPTR(A#(0)), LPEEK(A)
60186   LOCAL Feld3= LPEEK( VARPTR(B#(0)))
60187   LPOKE VARPTR(B#(0)), LPEEK(B)
60188   LOCAL I,A#,B#
60189   FOR I=1 TO M
60190     A#= SQR(A#(I)^2+B#(I)^2)
60191     B#=FN Atn2#(B#(I),A#(I))
60192     A#(I)=A#
60193     B#(I)=B#
60194   NEXT I
60195   LPOKE VARPTR(A#(0)),Feld2
60196   LPOKE VARPTR(B#(0)),Feld3
60197 RETURN
60198 DEF PROC Fourier(Y,N,M,R A0#,A,B)
60199   LOCAL Feld= LPEEK( VARPTR(Y#(0,0)))
60200   LPOKE VARPTR(Y#(0,0)), LPEEK(Y)
60201   LOCAL Feld2= LPEEK( VARPTR(A#(0)))
60202   LPOKE VARPTR(A#(0)), LPEEK(A)
60203   LOCAL Feld3= LPEEK( VARPTR(B#(0)))
60204   LPOKE VARPTR(B#(0)), LPEEK(B)
60205   LOCAL A0#,H#,N1,Ig#,C#,I,H#,H1#,W#,Degflag
60206   IF SIN(90)=1 THEN Degflag=1: RAD
60207   N1=N\2
60208   Ig#=N-2*N1
60209   C#=2/N
60210   IF M>N1 THEN M=N1
60211   IF M<0 THEN M=0
60212   FOR I=1 TO N
60213     A0#=A0#+Y#(I,1)
60214   NEXT I
60215   A0#=A0#/N
60216   H#=2* PI /N
60217   Sin_H#= SIN(H#)
60218   Cos_H#= COS(H#)
60219   FOR K=1 TO M
60220     A#(K)=0
60221     B#(K)=0
60222     H1#=H1#+H#
60223     W#=-H1#
60224     FOR I=1 TO N
60225       W#=W#+H1#
60226       A#(K)=A#(K)+Y#(I,1)* COS(W#)
60227       B#(K)=B#(K)+Y#(I,1)* SIN(W#)
60228     NEXT I
60229     A#(K)=A#(K)*C#
60230     B#(K)=B#(K)*C#
60231   NEXT K
60232   IF M=N1 AND Ig#=0 THEN B#(M)=0
60233   IF Degflag=1 THEN DEG
60234   LPOKE VARPTR(Y#(0,0)),Feld
60235   LPOKE VARPTR(A#(0)),Feld2
60236   LPOKE VARPTR(B#(0)),Feld3
60237 RETURN
60238 DEF FN Romberg#(A#,B#,Index)
60239   LOCAL Converg#=0' Flag fr Konvergenz
60240   LOCAL H#,N,K,Arg#,S#,Integral#,Q#
60241   H#=B#-A#
60242   N=1
60243   P#(0)=.5*H#*(FN F#(Index,A#)+FN F#(Index,B#))
60244   K=1
60245   REPEAT
60246     Arg#=A#+.5*H#
60247     S#=0
60248     FOR I=1 TO N
60249       S#=S#+FN F#(Index,Arg#)
60250       Arg#=Arg#+H#
60251     NEXT I
60252     N=N*2
60253     H#=H#/2
60254     P#(K)=P#(K-1)/2+S#*H#
60255     Q#=1
60256     FOR I=K-1 TO 0 STEP -1
60257       Q#=4*Q#
60258       IF I=0 THEN
60259         Integral#=P#(1)+(P#(1)-P#(0))/(Q#-1)
60260         IF ABS(Integral#-P#(0))<1D-4 THEN Converg#=1
60261         P#(0)=Integral#
60262       ELSE
60263         P#(I)=P#(I+1)+(P#(I+1)-P#(I))/(Q#-1)
60264       ENDIF
60265     NEXT I
60266     K=K+1
60267   UNTIL K=11 OR Converg#=1
60268   IF K=10 AND Converg#<>1 THEN
60269     Integral#=FN Romberg#(A#,(A#+B#)/2,Index)+FN Romberg#((A#+B#)/2,B#,Index)
60270   ENDIF
60271 RETURN Integral#
60272 DEF FN Romberg_2#(A#,B#,Nr1#,Nr2#)
60273   LOCAL A1#,A2#,I,Hi#,S#,K,Fehl#,J,In#
60274   A1#=FN F#(Nr1#,A#)*FN F#(Nr2#,A#)
60275   A2#=FN F#(Nr1#,B#)*FN F#(Nr2#,B#)
60276   H#(0,0)=.5*(B#-A#)*(A1#+A2#)
60277   I=0
60278   REPEAT
60279     I=I+1
60280     Hi#=(B#-A#)/2^I
60281     S#=0
60282     FOR J=1 TO 2^I-1
60283       S#=S#+2*FN F#(Nr1#,A#+J*Hi#)*FN F#(Nr2#,A#+J*Hi#)
60284     NEXT J
60285     H#(I,0)=Hi#*(S#+A1#+A2#)/2
60286     FOR K=1 TO I
60287       H#(I,K)=(2^(2*K)*H#(I,K-1)-H#(I-1,K-1))/(2^(2*K)-1)
60288     NEXT K
60289     Fehl#= MIN( ABS(H#(I,I)-H#(I,I-1)), ABS(H#(I,I)-H#(I-1,I-1)))
60290   UNTIL I>=7 OR Fehl#<1E-5
60291   IF I>=7 THEN
60292     In#=FN Romberg_2#(A#,B#/2,Nr1#,Nr2#)+FN Romberg_2#(B#/2,B#,Nr1#,Nr2#)
60293   ELSE
60294     In#=H#(I,I)
60295   ENDIF
60296 RETURN In#
60297 DEF FN Horner#(N,A,X#)
60298   LOCAL Feld= LPEEK( VARPTR(A#(0)))
60299   LPOKE VARPTR(A#(0)), LPEEK(A)
60300   LOCAL B#,C#,I,P#
60301   B#=A#(1)
60302   C#=0
60303   FOR I=1 TO N
60304     C#=C#*X#+B#
60305     B#=B#*X#+A#(I+1)
60306   NEXT I
60307   P#=B#
60308   LPOKE VARPTR(A#(0)),Feld
60309 RETURN P#
60310 DEF FN Hornerab#(N,A,X#)
60311   LOCAL Feld= LPEEK( VARPTR(A#(0)))
60312   LPOKE VARPTR(A#(0)), LPEEK(A)
60313   LOCAL B#,C#,I,P#
60314   B#=A#(1)
60315   C#=0
60316   FOR I=1 TO N
60317     C#=C#*X#+B#
60318     B#=B#*X#+A#(I+1)
60319   NEXT I
60320   P#=C#
60321   LPOKE VARPTR(A#(0)),Feld
60322 RETURN P#
60323 DEF PROC Zero(Index,U#,V#,R B#)
60324   LOCAL Tol#,Flag,Fu#,Fv#,Count,Nbis,Fb#
60325   Tol#=1D-10
60326   Flag=0
60327   Fu#=FN F#(Index,U#)
60328   Fv#=FN F#(Index,V#)
60329   Count=0
60330   Nbis=5
60331   IF Fu#*Fv#>0 THEN
60332     PRINT "PROC Zero:"
60333     PRINT "Startwerte lassen keine Aussage zu, ob in [U,V] eine"
60334     PRINT "Nullstelle der Funktion liegt. Bitte starten Sie mit"
60335     PRINT "neuen Startwerten!"
60336     STOP
60337   ENDIF
60338   B#=(U#*Fv#-V#*Fu#)/(Fv#-Fu#)
60339   REPEAT
60340     IF B#<=U# THEN
60341       B#=U#
60342       Flag=1
60343     ELSE
60344       IF B#>=V# THEN
60345         B#=V#
60346         Flag=1
60347       ELSE
60348         Count=Count+1
60349         Fb#=FN F#(Index,B#)
60350         IF Fb#*Fu#>0 THEN
60351           Fu#=Fb#
60352           U#=B#
60353         ELSE
60354           Fv#=Fb#
60355           V#=B#
60356         ENDIF
60357         IF(V#-U#)<=Tol# THEN
60358           Flag=1
60359         ENDIF
60360         IF Nbis* INT(Count/Nbis)<>Count THEN
60361           B#=(U#*Fv#-V#*Fu#)/(Fv#-Fu#)
60362         ELSE
60363           B#=U#+(V#-U#)/2
60364         ENDIF
60365       ENDIF
60366     ENDIF
60367   UNTIL(Flag=1) AND(Count<100)
60368 RETURN
60369 DEF PROC Minimum(Index,R B#)
60370   LOCAL St#,Ifn,A1#,A2#,Big#,P#,S1#,S0#,X1#,Bmin#,X2#
60371   St#=5'initial step lenght
60372   Ifn=0
60373   A1#=1.5
60374   A2#=-.25
60375   Big#=1000000
60376  -Step2
60377   Ifn=Ifn+1
60378   P#=FN F#(Index,B#)
60379   S1#=P#
60380   S0#=-Big#
60381   X1#=0
60382   Bmin#=B#
60383  -Step3
60384   X2#=X1#+St#
60385   B#=Bmin#+X2#
60386   IF Ifn>200 THEN
60387     PRINT "Keine Konvergenz in PROC Minimum"
60388     STOP
60389   ENDIF
60390   IF ABS(B#-Bmin#-X1#)<1D-5 THEN RETURN
60391   Ifn=Ifn+1
60392   P#=FN F#(Index,B#)
60393   IF P#<S1# THEN
60394     X0#=X1#
60395     S0#=S1#
60396     X1#=X2#
60397     S1#=P#
60398     St#=A1#*St#
60399   ELSE
60400     IF S0#>=S1# THEN
60401       X0#=X0#-X1#
60402       S0#=(S0#-S1#)*St#
60403       P#=(P#-S1#)*X0#
60404       S1#=.5*(P#*X0#-S0#*St#)/(P#-S0#)
60405       X2#=X1#-St#
60406       B#=Bmin#+X2#
60407       IF ABS(B#-Bmin#-X1#)<1D-5 THEN
60408         St#=A2#*St#
60409       ELSE
60410         Ifn=Ifn+1
60411         P#=FN F#(Index,B#)
60412         IF P#<S1# THEN
60413           X1#=X2#
60414         ELSE
60415           B#=Bmin#+X1#
60416           P#=S1#
60417           St#=A2#*St#
60418         ENDIF
60419       ENDIF
60420       GOTO Step2
60421     ELSE
60422       S0#=P#
60423       X0#=X2#
60424       St#=A2#*St#
60425     ENDIF
60426   ENDIF
60427   GOTO Step3
60428 RETURN
60429 DEF PROC Eigen(A,N,R)
60430   LOCAL Feld= LPEEK( VARPTR(A#(0,0)))
60431   LPOKE VARPTR(A#(0,0)), LPEEK(A)
60432   LOCAL Feld2= LPEEK( VARPTR(R#(0)))
60433   LPOKE VARPTR(R#(0)), LPEEK(R)
60434   LOCAL Eps#,H#,Isweep,I,V#,J,Count,K,P#,Q#,R#
60435   LOCAL V#,C#,S#
60436   Eps#=9D-19
60437   H#=100000.
60438   Isweep=0
60439   FOR I=1 TO N
60440     V#=A#(I,I)
60441     FOR J=1 TO N
60442       IF J<>I THEN V#=V#- ABS(A#(I,J))
60443     NEXT J
60444     IF V#<H# THEN H#=V#
60445   NEXT I
60446   IF H#>Eps# THEN
60447     H#=0
60448   ELSE
60449     H#=H#- SQR(Eps#)
60450     FOR I=1 TO N
60451       A#(I,I)=A#(I,I)-H#
60452     NEXT I
60453   ENDIF
60454   Count=0
60455   Isweep=Isweep+1
60456   IF Isweep>30 THEN
60457     PRINT "Eigenwertberechnung in PROC Eigen konvergiert nicht"
60458     STOP
60459   ENDIF
60460  -Iter
60461   FOR J=1 TO N-1
60462     FOR K=J+1 TO N
60463       P#=0
60464       Q#=0
60465       R#=0
60466       FOR I=1 TO N
60467         P#=P#+A#(I,J)*A#(I,K)
60468         Q#=Q#+A#(I,J)*A#(I,J)
60469         R#=R#+A#(I,K)*A#(I,K)
60470       NEXT I
60471       IF 1<1+ ABS(P#/ SQR(Q#*R#)) THEN GOTO Rotation
60472       IF Q#>=R# THEN Count=Count+1: GOTO Stp13
60473      -Rotation
60474       Q#=Q#-R#
60475       V#= SQR(4*P#*P#+Q#*Q#)
60476       IF V#=0 THEN GOTO Stp13
60477       IF Q#>0 THEN
60478         C#= SQR((V#+Q#)/(2*V#))
60479         S#=P#/(V#*C#)
60480       ELSE
60481         S#= SQR((V#-Q#)/(2*V#))
60482         IF P#<0 THEN S#=-S#
60483         C#=P#/(V#*S#)
60484       ENDIF
60485       FOR I=1 TO N
60486         V#=A#(I,J)
60487         A#(I,J)=V#*C#+A#(I,K)*S#
60488         A#(I,K)=-V#*S#+A#(I,K)*C#
60489       NEXT I
60490       -Stp13
60491     NEXT K
60492   NEXT J
60493   IF Count<N*(N-1)/2 THEN GOTO Iter
60494   FOR J=1 TO N
60495     S#=0
60496     FOR I=1 TO N
60497       S#=S#+A#(I,J)*A#(I,J)
60498     NEXT I
60499     S#= SQR(S#)
60500     FOR I=1 TO N
60501       A#(I,J)=A#(I,J)/S#
60502     NEXT I
60503     R#(J)=S#+H#
60504   NEXT J
60505   LPOKE VARPTR(A#(0,0)),Feld
60506   LPOKE VARPTR(R#(0)),Feld2
60507 RETURN
