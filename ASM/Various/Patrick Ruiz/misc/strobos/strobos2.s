;~~~~~~~~~~~~~~~~~~~~~~~~ S ~ T ~ R ~ O ~ B ~ O ~ S [2] ~~~~~~~~~~~~~~~~~~~~~~~~
; V1.11

 OUTPUT E:STROBOS2.B

; Permet le basculement entre 2 ‚crans
; pour ‚viter les interf‚rences avec le faisceau lors de l'affichage.
; L'appel doit se faire en Superviseur par jsr Strobos

; INIT: D0.L =           Strobos(-1 , Ecran.L )
;       Ecran de travail

; BASC: D0.L =           Strobos( 1 )
;       Ecran de travail

; FIN:  D0.L =           Strobos( 0 )
;       Ecran de travail

V_BH  =$FFFF8200
V_BM  =$FFFF8202
V_BL  =$FFFF820C
V_CH  =$FFFF8204
V_CM  =$FFFF8206
V_CL  =$FFFF8208

_v_bas_ad=$44E
_cookie  =$5A0

 SECTION DATA

E_o DS.L 1 ;originel
E_0 DS.L 1 ;physique
E_1 DS.L 1 ;logique
STE DC.B 0 ; 0:ST  -1:STE ou Falcon

 SECTION TEXT
STROBOS: tst 4(SP)
 bmi.s Init
 beq Fin
 bpl.s Basc

Init:
 ;machine ?
 lea STE(PC),A2
 move.l _cookie,D0
 beq.s .1
 movea.l D0,A0
.3 tst.l (A0)
 beq.s .1
 cmpi.l #'_MCH',(A0)+
 beq.s .2
 addq #4,A0
 bra .3
.2 cmpi #1,(A0)
 seq (A2)
 beq.s .1
 cmpi #3,(A0)
 seq (A2)
.1 ;init E_o E_0 E_1
 moveq #0,D0
 lea V_BH,A0
 movep 1(A0),D0
 lsl.l #8,D0
 tst.b (A2)
 beq.s .4
 move.b V_BL+1,D0
.4 lea E_o(PC),A0
 move.l D0,(A0)+
 move.l D0,(A0)+
 move.l  6(SP),D0
 move.l D0,(A0)
 ;‚cran travail
 move.l D0,_v_bas_ad
 rts

Basc:
 ;changer VB sans ˆtre proche du START
 ;Le compteur video doit bouger !
 lea V_CL+1,A0
 move.b (A0),D0
.1 cmp.b (A0),D0
 beq .1
 move.l E_1(PC),D0
 move.b D0,D1
 lsr.l #8,D0
 lea V_BH,A1
 movep D0,1(A1)
 lea STE(PC),A0
 tst.b (A0)
 beq.s .2
 move.b D1,V_BL+1
.2 ; rotation
 lea  E_0(PC),A0
 move.l  (A0),D0
 move.l 4(A0),(A0)
 move.l    D0,4(A0)
 move.l    D0,_v_bas_ad

 ; attendre pour nouvel ‚cran
 ; ‚viter parasitage d– … la coupure de VC
.4 lea V_CH,A0
 move SR,D2
 ori #$0700,SR
 movep.l 1(A0),D0
 movep.l 1(A0),D1
 move D2,SR
 lsr.l #8,D0
 lsr.l #8,D1
 cmp.l D1,D0
 bls.s .3
 exg.l D0,D1
.3 sub.l D0,D1
 ;D1=erreur constat‚e
 cmpi.l #128,D1 ; valeur critique avec un MC68000 et un VIDEL
                ; … 640x480 TC , 32 kHz.
 bhi .4
 sub.l E_0(PC),D0
 bmi .4
 cmpi.l #8000,D0 ;entame ‚cran maxi
 bhi .4
 move.l _v_bas_ad,D0
 rts

Fin: lea E_o(PC),A0
 lea E_0(PC),A1
 cmpm.l (A0)+,(A1)+
 beq.s .1
 move #1,-(SP)
 bsr Basc
 addq #2,SP
.1 move.l E_o(PC),D0
 move.l D0,_v_bas_ad
 rts

 END
