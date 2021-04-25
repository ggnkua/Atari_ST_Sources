61000 '
61001 '                  S T A T L I B - 1.1
61002 '
61003 '         Statistik-Bibliothek fÅr OMIKRON.BASIC
61004 '
61005 '                   Programmiert von
61006 '
61007 '                      Jîrn Wilms
61008 '                     Im Feldle 23
61009 '                D-7312 Kirchheim/Teck
61010 '                  Tel.: 07021/44286
61011 '
61012 '
61013 '   Ω 1988 by Jîrn Wilms und OMIKRON.Software, Birkenfeld
61014 '
61015 '
61016 DEFSNG "A-Z"
61017 END
61018 DEF FN Mean(X,N%L)
61019   LOCAL I%L,Xm
61020   LOCAL Feld= LPEEK( VARPTR(X(0)))
61021   LPOKE VARPTR(X(0)), LPEEK(X)
61022   FOR I%L=1 TO N%L
61023     Xm=Xm+X(I%L)
61024   NEXT I%L
61025   LPOKE VARPTR(X(0)),Feld
61026 RETURN Xm/ CSNG(N%L)
61027 DEF FN Variance(X,N%L)
61028   LOCAL I%L,X2,Sx
61029   LOCAL Feld= LPEEK( VARPTR(X(0)))
61030   LPOKE VARPTR(X(0)), LPEEK(X)
61031   FOR I%L=1 TO N%L
61032     X2=X2+X(I%L)*X(I%L)
61033     Sx=Sx+X(I%L)
61034   NEXT I%L
61035   LPOKE VARPTR(X(0)),Feld
61036 RETURN(N%L*X2-Sx*Sx)/(N%L*(N%L-1))
61037 DEF FN St_Dev(X,N%L)= SQR(FN Variance(X,N%L))
61038 DEF PROC Mean_Variance(X,N%L,R Mean,R Var)
61039   LOCAL I%L
61040   LOCAL Feld= LPEEK( VARPTR(X(0)))
61041   LPOKE VARPTR(X(0)), LPEEK(X)
61042   Var=0
61043   Mean=FN Mean(X,N%L)
61044   FOR I%L=1 TO N%L
61045     Var=Var+(X(I%L)-Mean)^2
61046   NEXT I%L
61047   Var=Var/ CSNG((N%L-1))
61048   LPOKE VARPTR(X(0)),Feld
61049 RETURN
61050 DEF FN Mean_Sample(X,N%L)
61051   LOCAL I%L,Anz,Xm
61052   LOCAL Feld= LPEEK( VARPTR(X(0,0)))
61053   LPOKE VARPTR(X(0,0)), LPEEK(X)
61054   FOR I%L=1 TO N%L
61055     Xm=Xm+X(I%L,0)*X(I%L,1)
61056     Anz=Anz+X(I%L,1)
61057   NEXT I%L
61058   LPOKE VARPTR(X(0,0)),Feld
61059 RETURN Xm/Anz
61060 DEF FN Variance_Sample(X,N%L)
61061   LOCAL I%L,X2,Sx,Anz
61062   LOCAL Feld= LPEEK( VARPTR(X(0,0)))
61063   LPOKE VARPTR(X(0,0)), LPEEK(X)
61064   FOR I%L=1 TO N%L
61065     X2=X2+X(I%L,0)*X(I%L,0)*X(I%L,1)
61066     Sx=Sx+X(I%L,0)*X(I%L,1)
61067     Anz=Anz+X(I%L,1)
61068   NEXT I%L
61069   LPOKE VARPTR(X(0,0)),Feld
61070 RETURN(X2-Sx^2/Anz)/(Anz-1)
61071 DEF FN St_Dev_Sample(X,N%L)= SQR(FN Variance_Sample(X,N%L))
61072 DEF FN Sigma_Approx(Stdev,N%L)
61073   LOCAL S
61074   IF N%L>10 THEN
61075     S=(1.+1./(4.*(N%L-1.)))*Stdev
61076   ELSE
61077     PRINT "Sigma_Approx fÅr N%L<=10 nicht anwendbar"
61078     S=Stdev
61079   ENDIF
61080 RETURN S
61081 DEF FN Variation_Coeff(S,Mean)=S/Mean
61082 DEF FN Variation_Coeff_Rel(S,Mean,N)=100*FN Variation_Coeff(S,Mean)/ SQR(N)
61083 DEF FN Mean_Geo(X,N%L)
61084   LOCAL I%L,Xg
61085   LOCAL Feld= LPEEK( VARPTR(X(0)))
61086   LPOKE VARPTR(X(0)), LPEEK(X)
61087   FOR I%L=1 TO N%L
61088     Xg=Xg+ LN(X(I%L))
61089   NEXT I%L
61090   Xg=Xg/N%L
61091   LPOKE VARPTR(X(0)),Feld
61092 RETURN EXP(Xg)
61093 DEF FN Mean_Harm(X,N%L)
61094   LOCAL I%L,Xh
61095   LOCAL Feld= LPEEK( VARPTR(X(0)))
61096   LPOKE VARPTR(X(0)), LPEEK(X)
61097   FOR I%L=1 TO N%L
61098     Xh=Xh+1/X(I%L)
61099   NEXT I%L
61100   LPOKE VARPTR(X(0)),Feld
61101 RETURN N%L/Xh
61102 DEF FN Mean_Harm_Sample(X,N%L)
61103   LOCAL I%L,Anz,Xm
61104   LOCAL Feld= LPEEK( VARPTR(X(0,0)))
61105   LPOKE VARPTR(X(0,0)), LPEEK(X)
61106   FOR I%L=1 TO N%L
61107     Xm=Xm+X(I%L,1)/X(I%L,0)
61108     Anz=Anz+X(I%L,1)
61109   NEXT I%L
61110   LPOKE VARPTR(X(0,0)),Feld
61111 RETURN Anz/Xm
61112 DEF FN Standard(Y)
61113   LOCAL Z,N,W
61114   Z= ABS(Y)
61115   IF Z<=10 THEN
61116     IF Z<=4 THEN
61117       N=(14*Z+5)+1-((14*Z+5) MOD 2)
61118     ELSE
61119       N=(21*Z-23)+1-((21*Z-23) MOD 2)
61120     ENDIF
61121     W=Z
61122     WHILE N>1
61123       W=W*Z*Z/N+Z
61124       N=N-2
61125     WEND
61126     W=.5+ EXP(-Y*Y/2)/ SQR(2* PI )*W
61127     IF Y<=0 THEN W=1-W
61128   ELSE
61129     IF SGN(Y)=-1 THEN W=0 ELSE W=1
61130   ENDIF
61131 RETURN W
61132 DEF FN Normal(Y,Mu,Sig2)=FN Standard((Y-Mu)/ SQR(Sig2))
61133 DEF FN Standard_W(X)= EXP(-.5*X^2)/ SQR(2* PI )
61134 DEF FN Normal_W(X,Mu,Var)
61135   LOCAL Z
61136   Z=(X-Mu)/ SQR(Var)
61137 RETURN FN Standard_W(Z)/ SQR(Var)
61138 DEF FN Standard_Inv(P)
61139   LOCAL A,B,C,D,X
61140   IF P<=0 OR P>=1 THEN PRINT "Wahrscheinlichkeit nicht in ]0..1[ in FN Standard_Inv": STOP
61141   A=-1
61142   B=1
61143   C=FN Standard(A)-P
61144   REPEAT
61145     D=FN Standard(B)-P
61146     X=(A*D-B*C)/(D-C)
61147     A=B:B=X:C=D
61148   UNTIL ABS(B-A)<=1E-5
61149 RETURN -X
61150 DEF FN Normal_Inv(P,Mu,Var)=FN Standard_Inv(P)* SQR(Var)+Mu
61151 DEF FN Student_W(Fg%L,X)
61152   LOCAL Phi
61153   Phi=FN Gamma(.5*(Fg%L+1))*(1+X^2/Fg%L)^(.5*(Fg%L+1))
61154 RETURN Phi/( SQR(M* PI )*FN Gamma(.5*Fg%L))
61155 DEF FN Student(N%L,Y)
61156   LOCAL A,St,C,S,N1,I,Degfl
61157   IF SIN(90)=1. THEN Degfl=1: RAD
61158   A=Y*Y/( CSNG(N%L)+Y*Y)
61159   IF N%L=1 THEN
61160     St=2* ARCSIN( SQR(A))/ PI
61161   ELSE
61162     IF N%L MOD 2=0 THEN
61163       C=1:S=1
61164       N1=N%L/2-1
61165       FOR I%L=1 TO N1
61166         C=C*(I%L-.5)*(1-A)/I%L
61167         S=S+C
61168       NEXT I%L
61169       St=S* SQR(A)
61170     ELSE
61171       C=1:S=1
61172       N1=(N%L-3)/2
61173       FOR I%L=1 TO N1
61174         C=C*(1-A)*I%L/(.5+I%L)
61175       NEXT I%L
61176       St=2*( SQR(A*(1-A))*S+ ARCSIN( SQR(A)))/ PI
61177     ENDIF
61178   ENDIF
61179   IF Degfl=1 THEN DEG
61180 RETURN St
61181 DEF FN Student_Inv(N%L,P)
61182   LOCAL Inve,Pp,Ze
61183   IF P<=0 OR P>=1 THEN PRINT "Wahrscheinlichkeit nicht in ]0..1[ in FN Student_Inv": STOP
61184   IF N%L=1 THEN
61185     Inve= TAN((P-.5)* PI )
61186   ELSE
61187     Ze=FN Standard_Inv(P)
61188     Inve=Ze+(Ze^3+Ze)/(4*N%L)
61189     Inve=Inve+(5*Ze^5+16*Ze^3+3*Ze)/(6*(4*N%L)^2)
61190     Inve=Inve+(3*Ze^7+19*Ze^5+17*Ze^3-15*Ze)/(6*(4*N%L)^3)
61191     Inve=Inve+(79*Ze^9+776*Ze^7+1482*Ze^5-1920*Ze^3-945*Ze)/(360*(4*N%L)^4)
61192   ENDIF
61193 RETURN Inve
61194 DEF FN Fisher_W(Fg1%L,Fg2%L,X)
61195   LOCAL Phi
61196   Phi=Fg1%L^(.5*Fg2%L)*Fg2%L^(.5*Fg1%L)*FN Gamma(.5*(Fg1%L+Fg2%L))
61197   Phi=Phi*X^(.5*(Fg1%L-2))
61198   Phi=Phi/(FN Gamma(.5*Fg1%L)*FN Gamma(.5*Fg2%L))
61199   Phi=Phi/(Fg2%L+Fg1%L)^(.5*(Fg1%L+Fg2%L))
61200 RETURN Phi
61201 DEF FN Fisher(N1%L,N2%L,X)
61202   LOCAL N1,N2,Gern1,Gern2,A,P,Degflag
61203   IF N1%L<1 OR N2%L<1 THEN PRINT "Freiheitsgrad <1 in FN Fisher": STOP
61204   N1= CSNG(N1%L)
61205   N2= CSNG(N2%L)
61206   Gern1%L=N1 MOD 2
61207   Gern2%L=N2 MOD 2
61208   A=N1*Y/(N2+N1*Y)
61209   IF Gern2%L=0 THEN
61210      P=A^(.5*N1)*FN Summe_Fisher(1,N1,N2,A)
61211   ELSE
61212     IF Gern2%L=1 AND Gern1%L=0 THEN
61213       P=A^(.5*N1)*FN Summe_D_Fisher(.5*(N1-2))*FN Summe_Fisher(2,N1,N2,A)
61214       P= SQR(1-A)*(P-FN Summe_Fisher(3,N1,N2,A))+1.
61215     ELSE
61216       IF SIN(90)=1. THEN Degflag=1: RAD
61217       P=A^(.5*N1)* INT((N1-1)/FN Summe_D_Fisher(.5*(N1-3)))
61218       P= INT(P*FN Summe_Fisher(2,N1,N2,A)- SQR(A)*FN Summe_Fisher(4,N1,N2,A))
61219       P=2*( SQR(1-A)*P+ ARCSIN( SQR(A)))/ PI
61220       IF Degflag=1 THEN DEG
61221     ENDIF
61222   ENDIF
61223 RETURN P
61224 DEF FN Summe_Fisher(I,N1,N2,A)
61225   LOCAL S,U,V,W,N,C
61226   IF N1=1 AND N2=1 AND(I=2 OR I=4) THEN RETURN 0
61227   IF N1=1 AND N2>1 AND I=4 THEN RETURN 0
61228   IF N1>1 AND N2=1 AND I=2 THEN RETURN 0
61229   IF I=1 THEN
61230     U=.5*N1-1:V=0:W=1-A:N=.5*N2-1
61231   ELSE
61232     IF I=2 THEN
61233       U=.5*N1-.5:V=.5:W=1-A:N=.5*N2-1.5
61234     ELSE
61235       IF I=3 THEN
61236         U=-.5:V=0:W=A:N=.5*N1-1
61237       ELSE
61238         U=0:V=.5:W=A:N=.5*N1-1.5
61239       ENDIF
61240     ENDIF
61241   ENDIF
61242   C=1
61243   S=1
61244   FOR I=1 TO N
61245     C=C*(U+I)*W/(V+I)
61246     S=S+C
61247   NEXT I
61248 RETURN S
61249 DEF FN Summe_D_Fisher(K)
61250   LOCAL D
61251   D=1
61252   FOR Dk=1 TO K
61253     D=D*(1+1/(2*Dk))
61254   NEXT Dk
61255 RETURN D
61256 DEF FN Fisher_Inv(N1%L,N2%L,P)
61257   LOCAL Pro,Inve,A,B,C,D,X,Zp
61258   IF N1%L<1 OR N2%L<1 THEN PRINT "Freiheitsgrad <1 in FN Fisher_Inv": STOP
61259   IF P<=0 OR P>=1 THEN PRINT "Wahrscheinlichkeit nicht in ]0..1[ in FN Fisher_Inv": STOP
61260    IF N1%L=1 THEN
61261      A=(FN Student_Inv(N2%L,.5*(1+P)))^2
61262    ELSE
61263      IF N2%L=1 THEN
61264        A=(FN Student_Inv(N1%L,1-.5*P))^2
61265      ELSE
61266       A=2/(1/(N1%L-1)+1/(N2%L-1))
61267       Zp=FN Standard_Inv(P)
61268       B=(Zp^2-3)/6
61269       W=Zp* SQR(A+B)/A-(.5/A)*(B+5/6+2/(3*A))
61270       A= EXP(2*W)
61271      ENDIF
61272   ENDIF
61273   B=A+1
61274   C=FN Fisher(N1%L,N2%L,A)-P
61275   REPEAT
61276     D=FN Fisher(N1%L,N2%L,B)-P
61277     X=(A*D-B*C)/(D-C)
61278     A=B:B=X:C=D
61279   UNTIL ABS(B-A)<.01
61280 RETURN X
61281 DEF FN Chi2_W(Fg%L,X)
61282   LOCAL Phi
61283   Phi=X^(.5*(Fg%L-2))* EXP(-.5*X)
61284   Phi=Phi/(2^(.5*Fg%L)*FN Gamma(.5*Fg%L))
61285 RETURN Phi
61286 DEF FN Chi2(N%L,Y)
61287   LOCAL Q,E,C
61288   IF N%L<1 THEN PRINT "Freiheitsgrad < 1 in FN Chi2": STOP
61289   IF Y<0 THEN PRINT "Y < 0 in FN Chi2": STOP
61290   IF N%L MOD 2=0 THEN
61291     Q= EXP(-Y/2)
61292     E=2
61293     C=Q*Y/2.
61294   ELSE
61295     Q=2*(1-FN Standard( SQR(Y)))
61296     E=1
61297     C= EXP(-Y/2.)* SQR((2.*Y/ PI ))
61298   ENDIF
61299   WHILE E<>N%L
61300     Q=Q+C
61301     E=E+2
61302     C=C*Y/E
61303   WEND
61304 RETURN Q
61305 DEF FN Chi2_Inv(N%L,P)
61306   LOCAL Pro,Inve,A,B,C,D,X
61307   IF N%L<1 THEN PRINT "Freiheitsgrad unzulÑssig in FN Chi2_Inv": STOP
61308   IF P<=0 OR P>=1 THEN PRINT "Wahrscheinlichkeit nicht in ]0..1[ in FN Chi2_Inv": STOP
61309   Pro=FN Standard_Inv(P)
61310   Inve=N%L*(Pro* SQR(2./(9.*N%L))+1-2/(9*N%L))^3
61311   A=Inve
61312   B=Inve+.1
61313   C=FN Chi2(N%L,A)-P
61314   REPEAT
61315     D=FN Chi2(N%L,B)-P
61316     X=(A*D-B*C)/(D-C)
61317     A=B:B=X:C=D
61318   UNTIL ABS(B-A)<=1E-5
61319 RETURN X
61320 DEF FN Expo(Y,My)=1- EXP(-Y/My)
61321 DEF FN Expo_Inv(P,My)=-My* LN(1-P)
61322 DEF FN Fakul(N%L)
61323   LOCAL Fakul
61324   IF N%L<110 THEN
61325     Fakul= FACT(N%L)
61326   ELSE
61327     Fakul=(N%L/ EXP(1.))^N%L* SQR(2* PI *N%L)
61328     Fakul=Fakul*(1+1/(12*N%L)+1/(288*N%L*N%L)-139/(51850*N%L^3))
61329   ENDIF
61330 RETURN Fakul
61331 DEF FN Binomial(N%L,K%L)
61332   LOCAL Bin
61333   IF N%L<0 OR K%L<0 THEN PRINT "Parameter falsch in FN Binomial": STOP
61334   IF N%L=K%L THEN
61335     Bin=1
61336   ELSE
61337     IF K%L=0 THEN
61338       Bin=1
61339     ELSE
61340       IF N%L<K%L THEN
61341         Bin=0
61342       ELSE
61343         Bin=FN Fakul(N%L)/(FN Fakul(K%L)*FN Fakul(N%L-K%L))
61344       ENDIF
61345     ENDIF
61346   ENDIF
61347 RETURN Bin
61348 DEF FN Binomialvert_W(X%L,N%L,P)=FN Binomial(N%L,X%L)*P^X%L*(1-P)^(N%L-X%L)
61349 DEF FN Binomialvert(X%L,N%L,P)
61350   LOCAL Binv,U%L
61351   IF X<0 THEN
61352     Binv=0
61353   ELSE
61354     FOR U%L=0 TO X%L
61355       Binv=Binv+FN Binomialvert_W(U%L,N%L,P)
61356     NEXT U%L
61357   ENDIF
61358 RETURN Binv
61359 DEF FN Hypergeo_W(X%L,N%L,M%L,Gn%L)
61360   LOCAL Hyp
61361   IF X%L>=0 AND X%L<= MIN(M%L,N%L) THEN
61362     Hyp=FN Binomial(M%L,X%L)*FN Binomial(Gn%L-M%L,N%L-X%L)
61363     Hyp=Hyp/FN Binomial(Gn%L,N%L)
61364   ELSE
61365     Hyp=0
61366   ENDIF
61367 RETURN Hyp
61368 DEF FN Hypergeo(X%L,N%L,M%L,Gn%L)
61369   IF N%L+M%L-N%L<0 THEN
61370     IF X%L<=0 THEN
61371       FOR U%L=0 TO X%L
61372         Hypv=Hypv+FN Hypergeo_W(U%L,N%L,M%L,Gn%L)
61373       NEXT U%L
61374     ENDIF
61375   ELSE
61376     IF X%L>=N%L+M%L-Gn%L THEN
61377       FOR U%L=N%L+M%L-Gn%L TO X%L
61378         Hypv=Hypv+FN Hypergeo_W(U%L,N%L,M%L,Gn%L)
61379       NEXT U%L
61380     ELSE
61381       Hypv=0
61382     ENDIF
61383   ENDIF
61384 RETURN Hypv
61385 DEF FN Poisson_W(X%L,Lambda)=Lambda^X%L* EXP(-Lambda)/FN Fakul(X%L)
61386 DEF FN Poisson(X%L,Lambda)
61387   LOCAL Binv,U%L,Poiv
61388   IF X%L<0 THEN
61389     Poiv=0
61390   ELSE
61391     FOR U%L=0 TO X%L
61392       Poiv=Poiv+FN Poisson_W(U%L,Lambda)
61393     NEXT U%L
61394   ENDIF
61395 RETURN Poiv
61396 DEF FN Rnd_Standard(Dummy)
61397   LOCAL Var1,Var2,R,Degfl%L
61398   Var1= RND(1)
61399   Var2= RND(1)
61400   IF SIN(90)=1. THEN Degfl%L=1: RAD
61401   IF Var1=0 THEN SWAP Var1,Var2
61402   R= SQR(-2.* LN(Var1))* SIN(2.* PI *Var2)
61403   IF Degfl%L=1 THEN DEG
61404 RETURN R
61405 DEF FN Rnd_Normal(Mu,S2)=FN Rnd_Standard(1)* SQR(S2)+Mu
61406 DEF FN Rnd_Chi2(N%L)
61407   LOCAL I%L,R
61408   FOR I%L=1 TO N%L
61409     R=R+FN Rnd_Standard(0)^2
61410   NEXT I%L
61411 RETURN R
61412 DEF FN Rnd_Fisher(N1%L,N2%L)=FN Rnd_Chi2(N1%L)*N2%L/(FN Rnd_Chi2(N2%L)*N1%L)
61413 DEF FN Gamma(X#)
61414   LOCAL Y#,Term#,Lggm#,S#,Z#,W#,V#
61415   Y#=X#
61416   Term#=1#
61417   IF X#<=0 THEN
61418     PRINT "GAMMA-Funktion nur fÅr Werte > 0 !!": STOP
61419   ENDIF
61420   Lggm#=0#
61421   IF X#=1 OR X#=2 THEN RETURN 0
61422   WHILE Y#<=18
61423     Term#=Term#*Y#
61424     Y#=Y#+1
61425   WEND
61426   S#=1#/Y#^2
61427   Z#=6.41025641025641D-3
61428   W#=-1.9175269175269175D-3
61429   V#=8.4175084175084175D-4
61430   U#=-5.9523809523809524D-4
61431   T#=7.9365079365079365D-4
61432   R#=-2.7777777777777778D-3
61433   Q#=.083333333333333333#
61434   P#=.9189385332046727#
61435   Lggm#=(Y#-.5)* LN(Y#)+P#-Y#- LN(Term#)
61436   Lggm#=Lggm#+((((((Z#*S#+W#)*S#+V#)*S#+U#)*S#+T#)*S#+R#)*S#+Q#)/Y#
61437 RETURN EXP(Lggm#)
61438 DEF PROC Z_Test(Mu0,Mean,Sigma,N,Alpha,R Antw)
61439   LOCAL Z,Zth
61440   Z= ABS((Mean-Mu0)* SQR(N)/Sigma)
61441   Zth=FN Standard_Inv(Alpha/2)
61442   IF Z>=Zth THEN Antw=0 ELSE Antw=1
61443 RETURN
61444 DEF PROC Konf_Mean_Normal_Zwei(Mean,Var,N,Alp,R Lg,R Rg,Flag%L)
61445   LOCAL Z,A
61446   IF Alp<.8 THEN PRINT "statistische Sicherheit nicht sinnvoll in PROC Konf_Mean_Normal_Zwei": STOP
61447   A=1-Alp
61448   IF Flag%L=1 THEN
61449     Z=FN Standard_Inv(.5*A)
61450   ELSE
61451     Z=FN Student_Inv(N-1,.5*A)
61452   ENDIF
61453     G= SQR(Var/N)*Z
61454     Lg=Mean-G
61455     Rg=Mean+G
61456 RETURN
61457 DEF PROC Konf_Mean_Normal_Eins(Mean,Var,N,Alp,R Ug,R Og,Flag%L)
61458   LOCAL Z,A
61459   IF Alp<.8 THEN PRINT "statistische Sicherheit nicht sinnvoll in PROC Konf_Mean_Normal_Eins": STOP
61460   A=1-Alp
61461   IF Flag%L=1 THEN
61462     Z=FN Standard_Inv(A)
61463   ELSE
61464     Z=FN Student_Inv(N-1,A)
61465   ENDIF
61466   G= SQR(Var/N)*Z
61467   Ug=Mean-G
61468   Og=Mean+G
61469 RETURN
61470 DEF PROC Konf_Var_Normal_Zwei(Var,N,Alp,R Lg,R Rg)
61471   LOCAL A,Ch1,Ch2
61472   IF Alp<.8 THEN PRINT "statistische Sicherheit nicht sinnvoll in PROC Konf_Var_Normal_Zwei": STOP
61473   A=1-Alp
61474   Ch1=FN Chi2_Inv(N-1,.5*A)
61475   Ch2=FN Chi2_Inv(N-1,1-.5*A)
61476   Lg=(N-1)*Var/Ch1
61477   Rg=(N-1)*Var/Ch2
61478 RETURN
61479 DEF PROC Konf_Sigma_Normal_Zwei(Sigma,N,Alp,R Lg,R Rg)
61480   IF Alp<.8 THEN PRINT "statistische Sicherheit nicht sinnvoll in PROC Konf_Sigma_Normal_Zwei": STOP
61481   Konf_Var_Normal_Zwei(Sigma^2,N,Alp,Lg,Rg)
61482   Lg= SQR(Lg)
61483   Rg= SQR(Rg)
61484 RETURN
61485 DEF PROC Konf_Var_Normal_Eins(Var,N,Alp,R Og,R Ug)
61486   LOCAL A,Ch1,Ch2
61487   IF Alp<.8 THEN PRINT "statistische Sicherheit nicht sinnvoll in PROC Konf_Var_Normal_Eins": STOP
61488   A=1-Alp
61489   Ch1=FN Chi2_Inv(N-1,1-A)
61490   Ch2=FN Chi2_Inv(N-1,A)
61491   Og=(N-1)*Var/Ch1
61492   Ug=(N-1)*Var/Ch2
61493 RETURN
61494 DEF PROC Konf_Sigma_Normal_Eins(Sigma,N,Alp,R Og,R Ug)
61495   IF Alp<.8 THEN PRINT "statistische Sicherheit nicht sinnvoll in PROC Konf_Sigma_Normal_Eins": STOP
61496   Konf_Var_Normal_Eins(Sigma^2,N,Alp,Og,Ug)
61497   Ug= SQR(Ug)
61498   Og= SQR(Og)
61499 RETURN
61500 DEF PROC Konf_Bin_P_Zwei(X,N,Alp,R Lg,R Rg)
61501   LOCAL Pd,M1,M2,M3,M4,F1,F2,A
61502   IF Alp<.8 THEN PRINT "statistische Sicherheit nicht sinnvoll in PROC Konf_Bin_P_Zwei": STOP
61503   A=1-Alp
61504   Pd=X/N
61505   M1=2*(N-X+1)
61506   M2=2*X
61507   M3=2*(X+1)
61508   M4=2*(N-X)
61509   F1=FN Fisher_Inv(M1,M2,1-.5*A)
61510   F2=FN Fisher_Inv(M3,M4,1-.5*A)
61511   Lg=X/(X+(N-X+1)*F1)
61512   Rg=(X+1)*F2/((N-X)+(X+1)*F2)
61513 RETURN
61514 DEF PROC Konf_Poisson_Lambda_Zwei(X,Alp,R Lg,R Rg)
61515   LOCAL A
61516   IF Alp<.8 THEN PRINT "statistische Sicherheit nicht sinnvoll in PROC Konf_Poisson_Lambda_Zwei": STOP
61517   A=1-Alp
61518   Lg=.5*FN Chi2_Inv(2*X,.5*A)
61519   Rg=.5*FN Chi2_Inv(2*(X+1),1-.5*A)
61520 RETURN
61521 DEF PROC Test_Bin_P0_Zwei(P0,X,N,Alp,R Antw)
61522   LOCAL A,F1,F2
61523   IF Alp<.8 THEN PRINT "statistische Sicherheit nicht sinnvoll in PROC Konf_Bin_P0_Zwei": STOP
61524   A=1-Alp
61525   F1=FN Fisher_Inv(2*(X+1),2*(N-X),1-.5*A)
61526   F2=(N-X)*P0/((X+1)*(1-P0))
61527   IF F2>F1 THEN Antw=1 ELSE Antw=0
61528 RETURN
61529 DEF PROC Test_Normal_Mu0_Zwei(Mu0,Mean,Var,N,Alp,R Antw,Flag)
61530   LOCAL A
61531   A=1-Alp
61532   Test= ABS(Mean-Mu0)* SQR(N/Var)
61533   IF Flag=1 THEN
61534     Z=FN Standard_Inv(.5*A)
61535   ELSE
61536     Z=FN Student_Inv(N-1,.5*A)
61537   ENDIF
61538   IF Z>Test THEN Antw=1 ELSE Antw=0
61539 RETURN
61540 DEF PROC Test_Normal_Mu0_Eins(Mu0,Mean,Var,N,Alp,R Antw1,R Antw2,Flag)
61541   LOCAL A,Test,Z
61542   A=1-Alp
61543   Test=(Mean-Mu0)* SQR(N/Var)
61544   IF Flag=1 THEN
61545     Z=FN Standard_Inv(A)
61546   ELSE
61547     Z=FN Student_Inv(N-1,A)
61548     PRINT Z
61549   ENDIF
61550   Antw1=-(Test>Z)
61551   Antw2=-(Test<-Z)
61552 RETURN
61553 DEF PROC Test_Normal_Var_Zwei(Var0,S2,N,Alp,R Antw)
61554   LOCAL A,Test,Ch1,Ch2
61555   A=1-Alp
61556   Test=(N-1)*S2/Var0
61557   Ch1=FN Chi2_Inv(N-1,.5*A)
61558   Ch2=FN Chi2_Inv(N-1,1-.5*A)
61559   Antw=-((Test>Ch1) OR(Test<Ch2))
61560 RETURN
61561 DEF PROC Test_Normal_Var_Eins(Var0,S2,N,Alp,R Antw1,R Antw2)
61562   LOCAL A,Test,Ch1,Ch2
61563   A=1-Alp
61564   Test=(N-1)*S2/Var0
61565   Ch1=FN Chi2_Inv(N-1,.5*A)
61566   Ch2=FN Chi2_Inv(N-1,1-.5*A)
61567   Antw1=-(Test>Ch1)
61568   Antw2=-(Test<Ch2)
61569 RETURN
61570 DEF PROC Vgl_Normal_Mean_Zwei(Mean1,Var1,N1,Mean2,Var2,N2,Alp,Flag,R Antw)
61571   LOCAL A,Sd,Sg,Z,Test,C,M
61572   A=1-Alp
61573   Sd=Var1/N1+Var2/N2
61574   IF Flag=1 THEN
61575     Test= ABS(Mean1-Mean2)/ SQR(Sd)
61576     Z=FN Standard_Inv(.5*A)
61577     Antw=-(Test>Z)
61578   ELSE
61579     IF Flag=2 THEN
61580       Sg=((N1-1)*Var1+(N2-1)*Var2)/(N1+N2-2)
61581       Test= ABS(Mean1-Mean2)* SQR((N1*N2)/(N1+N2))/Sg
61582       Z=FN Student_Inv(N1+N2-2,.5*A)
61583       Antw=-(Test>Z)
61584     ELSE
61585       C=Var1/(N1*(Var1/N1+Var2/N2))
61586       M=(N1-1)*(N2-1)/((N1-1)*(1-C)^2+(N2-1)*C*C)
61587       Test= ABS(Mean1-Mean2)/ SQR(Sd)
61588       Z=FN Student_Inv(M,.5*A)
61589       Antw=-(Test>Z)
61590     ENDIF
61591   ENDIF
61592 RETURN
61593 DEF PROC Vgl_Normal_Var(Var1,N1,Var2,N2,Alp,R Antw)
61594   LOCAL S1,S2,A,Test,Z
61595   S1= MAX(Var1,Var2)
61596   S2= MIN(Var1,Var2)
61597   IF S1=Var2 THEN SWAP N1,N2
61598   A=1-Alp
61599   Test=S1/S2
61600   Z=FN Fisher_Inv(N1-1,N2-1,1-.5*A)
61601   Antw=-(Test>Z)
61602 RETURN
61603 DEF PROC Vgl_Binomial_P(P1,N1,P2,N2,Alp,R Antw)
61604   LOCAL N,X,X1,X2,A,De1,De1,Xs1,Xs2,Test,Z
61605   X1=P1*N1
61606   X2=P2*N2
61607   N=N1+N2
61608   X=X1+X2
61609   A=1-Alp
61610   IF N<40 THEN
61611     IF N<20 OR N1*X/N<5 OR N2*X/N<5 THEN
61612       PRINT "Stichprobe in Vgl_Binomial_P zu klein": STOP
61613     ENDIF
61614   ENDIF
61615   De1=N1*X/N
61616   IF ABS(De1-X1+.5)< ABS(De1-X1-.5) THEN Xs1=X1-.5 ELSE Xs1=X1+.5
61617   De2=N2*X/N
61618   IF ABS(De2-X2+.5)< ABS(De2-X2-.5) THEN Xs2=X2-.5 ELSE Xs2=X2+.5
61619   Test= ABS(Xs1* SQR(N2/N1)-Xs2* SQR(N1/N2))/ SQR(X*(N-X)/N)
61620   Z=FN Standard_Inv(A)
61621   Antw=-(Test>Z)
61622 RETURN
61623 DEF PROC Vgl_Poisson_Lambda(X1,X2,Alp,R Antw)
61624   LOCAL A,Test,Z
61625   IF X1<X2 THEN SWAP X1,X2
61626   IF Alp<.8 THEN PRINT "statistische Sicherheit nicht sinnvoll in Vgl_Poisson_Lambda": STOP
61627   A=1-Alp
61628   Test=X1/(X2+1)
61629   Z=FN Fisher_Inv(2*(X2+1),2*X1,1-.5*A)
61630   Antw=-(Test>Z)
61631 RETURN
61632 DEF PROC Normalize(X,N,R Sum)
61633   LOCAL Feld1= LPEEK( VARPTR(X(0,0)))
61634   Sum=0
61635   LPOKE VARPTR(X(0,0)), LPEEK(X)
61636   FOR I=1 TO N
61637     Sum=Sum+X(I,1)
61638   NEXT I
61639   FOR I=1 TO N
61640     X(I,1)=X(I,1)/Sum
61641   NEXT I
61642   LPOKE VARPTR(X(0,0)),Feld1
61643 RETURN
61644 DEF PROC Anp_Equal(X,Ng,Ni,Alp,R P,R Antw)
61645   LOCAL Vgl,A,J,Test
61646   LOCAL Feld1= LPEEK( VARPTR(X(0,0)))
61647   IF Alp<.8 THEN PRINT "statistische Sicherheit nicht sinnvoll in Anp_Equal": STOP
61648   LPOKE VARPTR(X(0,0)), LPEEK(X)
61649   P=1/Ng
61650   A=1-Alp
61651   J=1:Ks=0
61652   REPEAT
61653     N=0:Anz=0
61654     REPEAT
61655       N=N+Ni*P
61656       Anz=Anz+X(J,1)
61657       J=J+1
61658     UNTIL N>=5
61659     Test=Test+(Anz-N)^2/N
61660     Ks=Ks+1
61661   UNTIL J>Ng
61662   Vgl=FN Chi2_Inv(Ng-1,A)
61663   Antw=-(Test>Vgl)
61664   LPOKE VARPTR(X(0,0)),Feld1
61665 RETURN
61666 DEF PROC Anp_Binomial(X,Ng,Ni,Nst,Mean,L,Alp,R P,R Antw)
61667   LOCAL A,J,Ks,N,Anz,Test,Z
61668   LOCAL Feld1= LPEEK( VARPTR(X(0,0)))
61669   IF Alp<.8 THEN PRINT "statistische Sicherheit nicht sinnvoll in Anp_Binomial": STOP
61670   LPOKE VARPTR(X(0,0)), LPEEK(X)
61671   A=1-Alp
61672   P=Mean/Nst
61673   J=1:Ks=0
61674   REPEAT
61675     N=0:Anz=0
61676     REPEAT
61677       N=N+Ni*FN Binomialvert_W(X(J,0),Nst,P)
61678       Anz=Anz+X(J,1)
61679       J=J+1
61680     UNTIL N>=5
61681     Ks=Ks+1
61682     Test=Test+(Anz-N)^2/N
61683   UNTIL J>Ng
61684   Z=FN Chi2_Inv(Ks-L-1,A)
61685   Antw=-(Test>Z)
61686   LPOKE VARPTR(X(0,0)),Feld1
61687 RETURN
61688 DEF PROC Anp_Allg(X,Alp,Nummer,R Antw)
61689   LOCAL A,J,Ks,N,Anz,Test,Z
61690   LOCAL Feld1= LPEEK( VARPTR(X(0,0)))
61691   IF Alp<.8 THEN PRINT "statistische Sicherheit nicht sinnvoll in Anp_Allg": STOP
61692   LPOKE VARPTR(X(0,0)), LPEEK(X)
61693   A=1-Alp
61694   J=1:Ks=0
61695   REPEAT
61696     N=0:Anz=0
61697     REPEAT
61698       N=N+Ni*FN Wahrscheinlich_D(X(J,0),Nummer)
61699       Anz=Anz+X(J,1)
61700       J=J+1
61701     UNTIL N>=5
61702     Ks=Ks+1
61703     Test=Test+(Anz-N)^2/N
61704   UNTIL J>Ng
61705   Z=FN Chi2_Inv(Ks-L-1,A)
61706   Antw=-(Test>Z)
61707   LPOKE VARPTR(X(0,0)),Feld1
61708 RETURN
61709 DEF PROC Kolmo_Smirnow_Normal(X,Mean,Var,Ng,Ni,Alp,Flag,R Antw)
61710   LOCAL Fb,Fe,Diff,A
61711   LOCAL Feld1= LPEEK( VARPTR(X(0,0)))
61712   IF Alp<.8 THEN PRINT "statistische Sicherheit nicht sinnvoll in PROC Kolmo_Smirnow_Normal": STOP
61713   LPOKE VARPTR(X(0,0)), LPEEK(X)
61714   IF Ni<33 THEN PRINT "Weniger als 33 Daten in Kolmo_Smirnow_Normal": STOP
61715   A=1-Alp
61716   IF Flag=1 THEN
61717     D= SQR(-.5* LN(.5*A))
61718   ELSE
61719     A= INT(100*A+.5)
61720     IF A=20 THEN
61721       D=.736
61722     ELSE
61723       IF A=15 THEN
61724         D=.768
61725       ELSE
61726         IF A=10 THEN
61727           D=.805
61728         ELSE
61729           IF A=5 THEN
61730             D=.886
61731           ELSE
61732             IF A=1 THEN
61733               D=1.031
61734             ELSE
61735               PRINT A*.1;": Kolmo_Smirnow_Normal kann fÅr diese Genauigkeit"
61736               PRINT " leider nicht angewandt werden": STOP
61737             ENDIF
61738           ENDIF
61739         ENDIF
61740       ENDIF
61741     ENDIF
61742   ENDIF
61743   F=D/ SQR(Ni)
61744   FOR J=1 TO Ng
61745     Fb=Fb+X(J,1)
61746     Fe=Fe+Ni*FN Normal_W(X(J,0),Mean,Var)
61747     Diff= MAX(Diff, ABS(Fe-Fb))
61748   NEXT J
61749   Test=Diff/Ni
61750   Antw=-(Test>D)
61751 RETURN
61752 DEF PROC Kolmo_Smirnow_Allg(X,Ng,Ni,Alp,Flag,Nummer,R Antw)
61753   LOCAL Fb,Fe,Diff,A
61754   LOCAL Feld1= LPEEK( VARPTR(X(0,0)))
61755   LPOKE VARPTR(X(0,0)), LPEEK(X)
61756   IF Alp<.8 THEN PRINT "statistische Sicherheit nicht sinnvoll in PROC Kolmo_Smirnow_Allg": STOP
61757   IF Ni<33 THEN PRINT "Weniger als 33 Daten in Kolmo_Smirnow_Allg": STOP
61758   A=1-Alp
61759   IF Flag=1 THEN
61760     D= SQR(-.5* LN(.5*A))
61761   ELSE
61762     A= INT(100*A+.5)
61763     IF A=20 THEN
61764       D=.736
61765     ELSE
61766       IF A=15 THEN
61767         D=.768
61768       ELSE
61769         IF A=10 THEN
61770           D=.805
61771         ELSE
61772           IF A=5 THEN
61773             D=.886
61774           ELSE
61775             IF A=1 THEN
61776               D=1.031
61777             ELSE
61778               PRINT A*.1;": Kolmo_Smirnow_Allg kann fÅr diese Genauigkeit"
61779               PRINT " leider nicht angewandt werden": STOP
61780             ENDIF
61781           ENDIF
61782         ENDIF
61783       ENDIF
61784     ENDIF
61785   ENDIF
61786   F=D/ SQR(Ni)
61787   FOR J=1 TO Ng
61788     Fb=Fb+X(J,1)
61789     Fe=Fe+Ni*FN Wahrscheinlich_W(X(J,0),Nummer)
61790     Diff= MAX(Diff, ABS(Fe-Fb))
61791   NEXT J
61792   Test=Diff/Ni
61793   Antw=-(Test>D)
61794   LPOKE VARPTR(X(0,0)),Feld1
61795 RETURN
61796 DEF PROC U_Test(X,M,Y,N,Alp,Flag,R Antw)
61797   LOCAL A,I,At,Anz,Sum,Az,Test,Test2,Test3,Z
61798   LOCAL Feld1= LPEEK( VARPTR(X(0)))
61799   LPOKE VARPTR(X(0)), LPEEK(X)
61800   LOCAL Feld2= LPEEK( VARPTR(Y(0)))
61801   LPOKE VARPTR(Y(0)), LPEEK(Y)
61802   IF Alp<.8 THEN PRINT "statistische Sicherheit nicht sinnvoll in PROC U_Test": STOP
61803   A=1-Alp
61804   IF Flag=2 THEN A=.5*A
61805   IF N<8 OR M<8 THEN PRINT "U-Test nur fÅr n,m >= 8 !! ": STOP
61806   FOR I=1 TO M
61807     Helpf(I-1)=X(I)
61808     H2(I-1)=1
61809   NEXT I
61810   FOR I=1 TO N
61811     Helpf(I+M-1)=Y(I)
61812     Helpf2(I+M-1)=2
61813   NEXT I
61814   SORT Helpf(0) TO Helpf2(0)
61815   I=0:Anz=0
61816   At=Helpf(0)
61817   REPEAT
61818     REPEAT
61819       I=I+1
61820       Anz=Anz+1
61821       Sum=Sum+I
61822     UNTIL Helpf(I)<>At
61823     At=Helpf(I)
61824     IF Anz>1 THEN
61825       FOR J=I-Anz TO I-1
61826         Helpf(J)=Sum/Anz
61827       NEXT J
61828       Korr=Korr+(Anz^3-Anz)/12
61829     ELSE
61830       Helpf(I-1)=I
61831     ENDIF
61832     Sum=0:Anz=0
61833   UNTIL I=N+M-1
61834   FOR J=0 TO N+M-1
61835     IF Helpf2(J)=2 THEN Az=Az+Helpf(J)
61836   NEXT J
61837   S=M+N
61838   U=M*N+.5*N*(N+1)-Az
61839   U= MIN(U,M*N-U)
61840   Test= ABS(U-.5*M*N)
61841   Test2=M*N/(S*(S-1))
61842   Test3=(S^3-S)/12-Korr
61843   Test=Test/ SQR(Test2*Test3)
61844   Z=FN Standard_Inv(A)
61845   Antw=-(Test>Z)
61846   LPOKE VARPTR(X(0)),Feld1
61847   LPOKE VARPTR(Y(0)),Feld2
61848 RETURN
61849 DEF PROC Vierfeld(A,B,C,D,N,Alp,Flag,R Antw)
61850   LOCAL Test,Z
61851   LOCAL A=1-Alp
61852   IF Alp<.8 THEN PRINT "statistische Sicherheit nicht sinnvoll in PROC Vierfeld": STOP
61853   IF Flag=1 THEN A=A*2
61854   Test=N*(A*D-B*C)^2/((A+B)*(C+D)*(A+C)*(B+D))
61855   Z=FN Chi2_Inv(1,A)
61856   Antw=-(Test>Z)
61857 RETURN
61858 DEF PROC Brandt_Snedecor(Ix,K,Alp,R Antw)
61859   LOCAL X,I,J,Test,Z,A,N
61860   LOCAL Feld1= LPEEK( VARPTR(X(0,0)))
61861   LPOKE VARPTR(X(0,0)), LPEEK(Ix)
61862   IF Alp<.8 THEN PRINT "statistische Sicherheit nicht sinnvoll in Brandt_Snedecor": STOP
61863   A=1-Alp
61864   FOR J=1 TO K
61865     FOR I=0 TO 1
61866       N=N+X(J,I)
61867     NEXT I
61868     X=X+X(J,0)
61869   NEXT J
61870   FOR J=1 TO K
61871     Test=Test+X(J,0)^2/(X(J,0)+X(J,1))
61872   NEXT J
61873   Test=N^2/(X*(N-X))*(Test-X^2/N)
61874   Z=FN Chi2_Inv(K-1,A)
61875   Antw=-(Test>Z)
61876   LPOKE VARPTR(X(0,0)),Feld2
61877 RETURN
61878 DEF PROC Zweiweg_R_C(X,R,C,Alp,R Antw)
61879   LOCAL I,J,N,Test,Z,A
61880   LOCAL Feld1= LPEEK( VARPTR(X(0,0)))
61881   LPOKE VARPTR(X(0,0)), LPEEK(X)
61882   IF Alp<.8 THEN PRINT "statistische Sicherheit nicht sinnvoll in PROC Zweiweg_R_C": STOP
61883   A=1-Alp
61884   FOR I=1 TO R
61885     FOR J=1 TO C
61886       Helpf(I)=Helpf(I)+X(I,J)
61887       Helpf2(J)=Helpf2(J)+X(I,J)
61888       N=N+X(I,J)
61889     NEXT J
61890   NEXT I
61891   FOR I=1 TO R
61892     FOR J=1 TO C
61893       Test=Test+X(I,J)^2/(Helpf(I)*Helpf2(J))
61894     NEXT J
61895   NEXT I
61896   Test=N*(Test-1)
61897   Z=FN Chi2_Inv((R-1)*(C-1),A)
61898   Antw=-(Test>Z)
61899   LPOKE VARPTR(X(0,0)),Feld1
61900 RETURN
61901 DEF PROC Lin_Reg(X,N%L,R R,R Ax,R Bx,R Ay,R By,R Sx,R Sy,R Sxy,R Syx2,R Sxy2)
61902   LOCAL I%L,Dx,Dy
61903   LOCAL Feld1= LPEEK( VARPTR(X(0,0)))
61904   LPOKE VARPTR(X(0,0)), LPEEK(X)
61905   Sx=0:Sy=0:Sxy=0:Ym=0:Xm=0
61906   FOR I%L=1 TO N%L
61907     Xm=Xm+X(I%L,0)
61908     Ym=Ym+X(I%L,1)
61909   NEXT I%L
61910   Xm=Xm/N%L
61911   Ym=Ym/N%L
61912   FOR I%L=1 TO N%L
61913     Dx=X(I%L,0)-Xm
61914     Dy=X(I%L,1)-Ym
61915     Sx=Sx+Dx*Dx
61916     Sy=Sy+Dy*Dy
61917     Sxy=Sxy+Dx*Dy
61918   NEXT I%L
61919   Sx=Sx/(N%L-1.)
61920   Sy=Sy/(N%L-1.)
61921   Sxy=Sxy/(N%L-1.)
61922   R=Sxy/ SQR(Sx*Sy)
61923   Ax=Sxy/Sy
61924   Bx=Xm-Ax*Ym
61925   Ay=Sxy/Sx
61926   By=Ym-Ay*Xm
61927   Syx2=(N%L-1.)*(1-R*R)/(N%L-2)
61928   Sxy2=Syx2*Sx
61929   Syx2=Syx2*Sy
61930   LPOKE VARPTR(X(0,0)),Feld1
61931 RETURN
61932 DEF PROC Mult_Reg(X,N,M,Y,Z)
61933   LOCAL I,J,K
61934   LOCAL Feld1= LPEEK( VARPTR(X(0,0)))
61935   LPOKE VARPTR(X(0,0)), LPEEK(X)
61936   LOCAL Feld2= LPEEK( VARPTR(Y(0)))
61937   LPOKE VARPTR(Y(0)), LPEEK(Y)
61938   LOCAL Feld3= LPEEK( VARPTR(Z(0,0)))
61939   LPOKE VARPTR(Z(0,0)), LPEEK(Z)
61940   FOR I=0 TO M
61941     FOR J=0 TO I
61942       FOR K=0 TO N
61943         Helpf(I,J)=Helpf(I,J)+X(K,I)*X(K,J)
61944       NEXT K
61945       Helpf(J,I)=Helpf(I,J)
61946     NEXT J
61947   NEXT I
61948   FOR I=0 TO M
61949     FOR K=0 TO N
61950       Helpf2(I,0)=Helpf2(I,0)+Y(K)*X(K,I)
61951     NEXT K
61952   NEXT I
61953   MAT Helpf3(M,M)= INV Helpf(M,M)
61954   MAT Z(M,0)=Helpf3(M,M)*Helpf2(M,0)
61955   LPOKE VARPTR(X(0,0)),Feld1
61956   LPOKE VARPTR(Y(0)),Feld2
61957   LPOKE VARPTR(Z(0,0)),Feld3
61958 RETURN
61959 DEF PROC Test_Corr(R,N,Alp,R Antw)
61960   LOCAL A=1-Alp
61961   LOCAL Test,Z
61962   Test= ABS(R)* SQR((N-2)/(1-R*R))
61963   Z=FN Student_Inv(N-2,A)
61964   Antw=-(Test>Z)
61965 RETURN
61966 DEF PROC Vgl_Rho(Rho,R,N,Alp,R Antw)
61967   LOCAL A=1-Alp
61968   Test=(R-Rho)* SQR(N-2)/ SQR((1-R*R)*(1-Rho*Rho))
61969   Z=FN Student_Inv(N-2,A)
61970   Antw=-(Test>Z)
61971 RETURN
61972 DEF PROC Correlation_Coeffs(X,N,M,R)
61973   LOCAL Sum1,Sum2,Sum3,I,J,K
61974   LOCAL Feld1= LPEEK( VARPTR(X(0,0)))
61975   LPOKE VARPTR(X(0,0)), LPEEK(X)
61976   LOCAL Feld2= LPEEK( VARPTR(R(0,0)))
61977   LPOKE VARPTR(R(0,0)), LPEEK(R)
61978   FOR I=0 TO M
61979     FOR J=I TO M
61980       FOR K=0 TO N
61981         Sum1=Sum1+X(K,I)*X(K,J)
61982         Sum2=Sum2+X(K,I)
61983         Sum3=Sum3+X(K,J)
61984       NEXT K
61985       Helpf(I,J)=((N+1)*Sum1-Sum2*Sum3)/(N+1)
61986       IF Helpf(I,J)=0 THEN Helpf(I,J)=1D-34
61987       Helpf(J,I)=Helpf(I,J)
61988       Sum1=0:Sum2=0:Sum3=0
61989     NEXT J
61990   NEXT I
61991   FOR I=0 TO M-1
61992     FOR J=I+1 TO M
61993       R(I,J)=Helpf(I,J)/ SQR(Helpf(I,I)*Helpf(J,J))
61994       IF ABS(R(I,J))<1D-15 THEN R(I,J)=0
61995       R(J,I)=R(I,J)
61996     NEXT J
61997   NEXT I
61998   LPOKE VARPTR(X(0,0)),Feld1
61999   LPOKE VARPTR(R(0,0)),Feld2
62000 RETURN
62001 DEF PROC Autocorrelation(X,N,M,R,Flag)
62002   LOCAL Feld1= LPEEK( VARPTR(X(0)))
62003   LPOKE VARPTR(X(0)), LPEEK(X)
62004   LOCAL Feld2= LPEEK( VARPTR(R(0)))
62005   LPOKE VARPTR(R(0)), LPEEK(R)
62006   IF Flag=1 THEN
62007     Mean=FN Mean( VARPTR(X(0)),N)
62008     FOR I=1 TO N
62009       X(I)=X(I)-Mean
62010       Sx=Sx+X(I)^2
62011     NEXT I
62012     Sx= SQR(Sx/N)
62013     FOR I=1 TO N
62014       X(I)=X(I)/Sx
62015     NEXT I
62016   ENDIF
62017   P=0:Helpf(0,P)=0:Helpf(1,P)=0
62018   FOR I=1 TO N
62019     Helpf(0,P)=Helpf(0,P)+X(I)
62020     Helpf(1,P)=Helpf(1,P)+X(I)*X(I)
62021   NEXT I
62022   Helpf(2,P)=Helpf(0,P)
62023   Helpf(3,P)=Helpf(1,P)
62024   FOR P=1 TO M
62025     Helpf(0,P)=Helpf(0,P-1)-X(P)
62026     Helpf(2,P)=Helpf(2,P-1)-X(N-P+1)
62027     Helpf(1,P)=Helpf(1,P-1)-X(P)*X(P)
62028     Helpf(3,P)=Helpf(3,P-1)-X(N-P+1)^2
62029   NEXT P
62030   FOR P=0 TO M
62031     Helpf(4,P)=0
62032     FOR I=1 TO N-P
62033       Helpf(4,P)=Helpf(4,P)+X(I)*X(I+P)
62034     NEXT I
62035     W(P)=Helpf(4,P)/(N-P)
62036     R(P)=((N-P)*Helpf(4,P)-Helpf(2,P)*Helpf(0,P))
62037     R(P)=R(P)/ SQR((N-P)*Helpf(3,P)-Helpf(2,P)*Helpf(2,P))
62038     R(P)=R(P)/ SQR((N-P)*Helpf(1,P)-Helpf(0,P)*Helpf(0,P))
62039   NEXT P
62040   LPOKE VARPTR(X(0)),Feld1
62041   LPOKE VARPTR(R(0)),Feld2
62042 RETURN
62043 DEF PROC Varianz_Analyse(X,Ni,Nk,Nj,Xbi,Xbj,Xbij,Q,Df,F)
62044   LOCAL Ai,Ak,Aj,Xb,I,J,K,L
62045   LOCAL Feld1= LPEEK( VARPTR(X(0,0,0)))
62046   LPOKE VARPTR(X(0,0,0)), LPEEK(X)
62047   LOCAL Feld2= LPEEK( VARPTR(Xbi(0)))
62048   LPOKE VARPTR(Xbi(0)), LPEEK(Xbi)
62049   LOCAL Feld3= LPEEK( VARPTR(Xbj(0)))
62050   LPOKE VARPTR(Xbj(0)), LPEEK(Xbj)
62051   LOCAL Feld4= LPEEK( VARPTR(Xbij(0,0)))
62052   LPOKE VARPTR(Xbij(0,0)), LPEEK(Xbij)
62053   LOCAL Feld5= LPEEK( VARPTR(Q(0)))
62054   LPOKE VARPTR(Q(0)), LPEEK(Q)
62055   LOCAL Feld6= LPEEK( VARPTR(Df(0)))
62056   LPOKE VARPTR(Df(0)), LPEEK(Df)
62057   LOCAL Feld7= LPEEK( VARPTR(F(0)))
62058   LPOKE VARPTR(F(0)), LPEEK(F)
62059   Ai=Ni
62060   Ak=Nk
62061   Aj=Nj
62062   Xb=0
62063   FOR I=1 TO Ni
62064     Xbi(I)=0
62065   NEXT I
62066   FOR J=1 TO Nj
62067     Xbj(J)=0
62068     FOR I=1 TO Ni
62069       Xbij(I,J)=0
62070     NEXT I
62071   NEXT J
62072   FOR I=1 TO Ni
62073     FOR J=1 TO Nj
62074       FOR K=1 TO Nk
62075         Xbij(I,J)=Xbij(I,J)+X(I,J,K)
62076       NEXT K
62077       Xbij(I,J)=Xbij(I,J)/Ak
62078     NEXT J
62079   NEXT I
62080   FOR I=1 TO Ni
62081     FOR J=1 TO Nj
62082       Xbi(I)=Xbi(I)+Xbij(I,J)
62083     NEXT J
62084     Xbi(I)=Xbi(I)/Aj
62085   NEXT I
62086   FOR J=1 TO Nj
62087     FOR I=1 TO Ni
62088       Xbj(J)=Xbj(J)+Xbij(I,J)
62089     NEXT I
62090     Xbj(J)=Xbj(J)/Ai
62091     Xb=Xb+Xbj(J)
62092   NEXT J
62093   Xb=Xb/Aj
62094   FOR L=1 TO 6:Q(L)=0: NEXT L
62095   FOR I=1 TO Ni
62096     Q(1)=Q(1)+(Xbi(I)-Xb)^2
62097   NEXT I
62098   Q(1)=Q(1)*Aj*Ak
62099   FOR J=1 TO Nj
62100     Q(2)=Q(2)+(Xbj(J)-Xb)^2
62101   NEXT J
62102   Q(2)=Ai*Ak*Q(2)
62103   FOR I=1 TO Ni
62104     FOR J=1 TO Nj
62105       Q(3)=Q(3)+(Xbij(I,J)+Xb-Xbi(I)-Xbj(J))^2
62106       FOR K=1 TO Nk
62107         Q(5)=Q(5)+(X(I,J,K)-Xbij(I,J))^2
62108         Q(6)=Q(6)+(X(I,J,K)-Xb)^2
62109       NEXT K
62110     NEXT J
62111   NEXT I
62112   Q(3)=Ak*Q(3)
62113   Q(4)=Q(2)+Q(3)
62114   Df(1)=Ai-1.
62115   Df(2)=Aj-1.
62116   Df(3)=Df(1)*Df(2)
62117   Df(4)=Df(2)+Df(3)
62118   Df(5)=Ai*Aj*(Ak-1.)
62119   Df(6)=Ai*Aj*Ak-1.
62120   FOR L=1 TO 6
62121     S(L)=Q(L)/Df(L)
62122   NEXT L
62123   FOR L=1 TO 4
62124     F(L)=S(L)/S(5)
62125   NEXT L
62126   LPOKE VARPTR(X(0,0,0)),Feld1
62127   LPOKE VARPTR(Xbi(0)),Feld2
62128   LPOKE VARPTR(Xbj(0)),Feld3
62129   LPOKE VARPTR(Xbij(0,0)),Feld4
62130   LPOKE VARPTR(Q(0)),Feld5
62131   LPOKE VARPTR(Df(0)),Feld6
62132   LPOKE VARPTR(F(0)),Feld7
62133 RETURN
62134 DEF PROC Blockdiagramm(X,N,Xl,Yl,B,H)
62135   LOCAL P,Binc,I,Maximum
62136   LOCAL Feld1= LPEEK( VARPTR(X(0,0)))
62137   LPOKE VARPTR(X(0,0)), LPEEK(X)
62138   FOR I=1 TO N
62139     Maximum= MAX(Maximum,X(I,1))
62140   NEXT I
62141   BOX Xl,Yl,B,H
62142   P=Yl+.9*H
62143   DRAW Xl,P TO Xl+B-1,P
62144   Binc=B/N
62145   FOR I=0 TO N-1
62146     FILL STYLE =2,I+1
62147     PBOX Xl+(I+.1)*Binc,P TO Xl+(I+.9)*Binc,P-.9*H*X(I+1,1)/Maximum
62148   NEXT I
62149   LPOKE VARPTR(X(0,0)),Feld1
62150 RETURN
62151 DEF PROC Kreisdiagramm(X,N,Xm,Ym,R)
62152   LOCAL I,Sum,Alpha
62153   LOCAL Feld1= LPEEK( VARPTR(X(0,0)))
62154   LPOKE VARPTR(X(0,0)), LPEEK(X)
62155   FOR I=1 TO N
62156     Sum=Sum+X(I,1)
62157   NEXT I
62158   FOR I=1 TO N
62159     FILL STYLE =2,I
62160     Ew=Sw+360*X(I,1)/Sum
62161     PCIRCLE Xm,Ym,R,10*Sw,10*Ew
62162     Sw=Ew
62163   NEXT I
62164   LPOKE VARPTR(X(0,0)),Feld1
62165 RETURN
62166 DEF PROC Plot_2d_1(X,N,Xl,Yl,B,H,R Maxx,R Minx,R Maxy,R Miny)
62167   LOCAL Feld1= LPEEK( VARPTR(X(0,0)))
62168   LPOKE VARPTR(X(0,0)), LPEEK(X)
62169   Maxx=X(1,0)
62170   Minx=X(1,0)
62171   Maxy=X(1,1)
62172   Miny=X(1,1)
62173   FOR I=2 TO N
62174     Maxx= MAX(Maxx,X(I,0))
62175     Minx= MIN(Minx,X(I,0))
62176     Maxy= MAX(Maxy,X(I,1))
62177     Miny= MIN(Miny,X(I,1))
62178   NEXT I
62179   Spwx=Maxx-Minx
62180   Spwy=Maxy-Miny
62181   BOX Xl,Yl,B,H
62182   FOR I=1 TO N
62183     X=Xl+.05*B+.9*B*(X(I,0)-Minx)/Spwx
62184     Y=Yl+.95*H-.9*H*(X(I,1)-Miny)/Spwy
62185     DRAW X-1,Y-1 TO X+1,Y+1
62186     DRAW X+1,Y-1 TO X-1,Y+1
62187   NEXT I
62188   LPOKE VARPTR(X(0,0)),Feld1
62189 RETURN
62190 DEF PROC Plot_2d_2(X,N%L,Xl,Yl,B,H)
62191   LOCAL Feld1= LPEEK( VARPTR(X(0,0)))
62192   LPOKE VARPTR(X(0,0)), LPEEK(X)
62193   BOX Xl,Yl,B,H
62194   Maxx=X(N%L,0)
62195   Minx=X(1,0)
62196   Maxy=X(1,1)
62197   Miny=Maxy
62198   FOR I%L=2 TO N%L
62199     Maxy= MAX(Maxy,X(I%L,1))
62200     Miny= MIN(Miny,X(I%L,1))
62201   NEXT I%L
62202   Spwx=Maxx-Minx
62203   Spwy=Maxy-Miny
62204   X0=Xl+.05*B:X1=.9*B
62205   Y0=Yl+.95*H:Y1=.9*H
62206   DRAW X0+X1*(X(1,0)-Minx)/Spwx,Y0-Y1*(X(1,1)-Miny)/Spwy
62207   FOR I%L=1 TO N%L
62208     X=X0+X1*(X(I%L,0)-Minx)/Spwx
62209     Y=Y0-Y1*(X(I%L,1)-Miny)/Spwy
62210     DRAW TO X,Y
62211   NEXT I%L
62212   LPOKE VARPTR(X(0,0)),Feld1
62213 RETURN
62214 DEF PROC Plot_2d_3(X,N,Xl,Yl,B,H,Ax,Bx)
62215   LOCAL Feld1= LPEEK( VARPTR(X(0,0)))
62216   LPOKE VARPTR(X(0,0)), LPEEK(X)
62217   CLIP Xl,Yl,B,H
62218   Plot_2d_1(X,N,Xl,Yl,B,H,Maxx,Minx,Maxy,Miny)
62219   Spwy=Maxy-Miny
62220   Y1=Ax*Minx+Bx
62221   Y2=Ax*Maxx+Bx
62222   X1=Xl+.05*B
62223   Y1=Yl+.95*H-.9*H*(Y1-Miny)/Spwy
62224   X2=Xl+.95*B
62225   Y2=Yl+.95*H-.9*H*(Y2-Miny)/Spwy
62226   DRAW X1,Y1 TO X2,Y2
62227   CLIP
62228   LPOKE VARPTR(X(0,0)),Feld1
62229 RETURN
62230 DEF PROC Plot_2d_4(X,N,Xl,Yl,B,H,Maxx,Minx,Maxy,Miny)
62231   LOCAL Feld1= LPEEK( VARPTR(X(0,0)))
62232   LPOKE VARPTR(X(0,0)), LPEEK(X)
62233   CLIP Xl,Yl,B,H
62234   Spwx=Maxx-Minx
62235   Spwy=Maxy-Miny
62236   X=Xl+.05*B+.9*B*(X(1,0)-Minx)/Spwx
62237   Y=Yl+.95*H-.9*H*(X(1,1)-Miny)/Spwy
62238   DRAW X,Y
62239   FOR I=2 TO N
62240     X=Xl+.05*B+.9*B*(X(I,0)-Minx)/Spwx
62241     Y=Yl+.95*H-.9*H*(X(I,1)-Miny)/Spwy
62242     DRAW TO X,Y
62243   NEXT I
62244   CLIP
62245   LPOKE VARPTR(X(0,0)),Feld1
62246 RETURN
62247 DEF PROC Eingabe_1(X,N,Flag)
62248   LOCAL I
62249   LOCAL Feld1= LPEEK( VARPTR(X(0)))
62250   LPOKE VARPTR(X(0)), LPEEK(X)
62251   IF Flag=1 THEN
62252     FOR I=1 TO N
62253       INPUT "X("+ STR$(I)+")  :";X(I)
62254     NEXT I
62255   ELSE
62256     FOR I=1 TO N
62257       INPUT #1,X(I)
62258     NEXT I
62259   ENDIF
62260   LPOKE VARPTR(X(0)),Feld1
62261 RETURN
62262 DEF PROC Eingabe_2(X,N,M)
62263   LOCAL Feld1= LPEEK( VARPTR(X(0,0)))
62264   LPOKE VARPTR(X(0,0)), LPEEK(X)
62265   IF Flag=1 THEN
62266     FOR I=1 TO N
62267       FOR J=1 TO M
62268         INPUT "X("+ STR$(I)+","+ STR$(J)+")  :";X(I,J)
62269       NEXT J
62270     NEXT I
62271   ELSE
62272     FOR I=1 TO N
62273       FOR J=1 TO M
62274         INPUT #1,X(I,J)
62275       NEXT J
62276     NEXT I
62277   ENDIF
62278   LPOKE VARPTR(X(0,0)),Feld1
62279 RETURN
