;~~~~~~~~~~~~~~~~~~~~~~~~ S ~ T ~ R ~ O ~ B ~ O ~ S [2] ~~~~~~~~~~~~~~~~~~~~~~~~

 OUTPUT STROBOS.BIN

; Permet le basculement entre 2 ‚crans
; pour ‚viter les interf‚rences avec le faisceau lors de l'affichage.
; L'appel doit se faire en Superviseur par JSR STROBOS
; ATTENTION: _v_bas_ad est inchang‚ !

; INIT: D0.L =		 Strobos(-1 , ScrAd.L , ScrLn.L )
;	Ecran de travail

; BASC: D0.L =		 Strobos( 1 )
;	Ecran de travail

; FIN:	D0.L =		 Strobos( 0 )
;	Ecran de travail

_cookie  =$5A0

	D_
ScrAd	DS.L 3 ;physique,logique,originel
ScrLn	DS.L 1 ;Longeur d'un ‚cran
STE	DC.B 0 ; 0:ST  -1:STE ou Falcon

	P_
STROBOS:
	TST 4(SP)
	BMI.S Init
	BEQ Fin
	BPL.S Basc

Init:
 ;machine ?
	LEA 	STE(PC),A2
	MOVE.L	_cookie,D0
	BEQ.S	.1
	MOVEA.L	D0,A0
.3	TST.L	(A0)
	BEQ.S	.1
	CMPI.L	#'_MCH',(A0)+
	BEQ.S	.2
	ADDQ	#4,A0
	BRA	.3
.2	CMPI	#1,(A0)
	SEQ	(A2)
	BEQ.S	.1
	CMPI	#3,(A0)
	SEQ	(A2)
.1 ;init ScrAd
	MOVEQ	#0,D0
	LEA	VID_BH,A0
	MOVEP	1(A0),D0
	LSL.L	#8,D0
	TST.B	(A2)
	BEQ.S	.4
	MOVE.B	VID_BL+1,D0
.4	LEA	ScrAd(PC),A0
	MOVE.L	D0,(A0)
	MOVE.L	D0,8(A0)
	MOVE.L	6(SP),D0
	MOVE.L	D0,4(A0)
	LEA	ScrLn(PC),A0
	MOVE.L	10(SP),(A0)
	RTS

Basc:
 ;changer VB sans ˆtre proche du START
 ;Le compteur video doit bouger !
	 MOVE	SR,D2
	 ORI	#$0700,SR
	LEA	VID_CL+1,A0
	MOVE.B	(A0),D0
.1	CMP.B	(A0),D0
	BEQ.S	.1
	MOVE.L	ScrAd+4(PC),D0
	MOVE.B	D0,D1
	LSR.L	#8,D0
	LEA	VID_BH,A1
	MOVEP	D0,1(A1)
	LEA	STE(PC),A0
	TST.B	(A0)
	BEQ.S	.2
	MOVE.B	D1,VID_BL+1
	 MOVE	D2,SR
.2 ; rotation
	LEA	ScrAd(PC),A0
	MOVE.L	(A0),D0
	MOVE.L	4(A0),(A0)
	MOVE.L	D0,4(A0)

 ; attendre pour nouvel ‚cran
 ; ‚viter parasitage d– … la coupure de VID_C
.4	LEA	VID_CH,A0
	 ORI	#$0700,SR
	MOVEP.L	1(A0),D0
	MOVEP.L	1(A0),D1
	 MOVE	D2,SR
	LSR.L	#8,D0
	LSR.L	#8,D1
	CMP.L	D1,D0
	BLS.S	.3
	EXG.L	D0,D1
.3	SUB.L	D0,D1
 ;D1=erreur constat‚e
	CMPI.L	#128,D1	; valeur critique avec un MC68000 et un VIDEL
			; … 640x480 TC , 32 kHz.
	BHI	.4
	SUB.L	ScrAd(PC),D0
	BMI	.4
	CMP.L	ScrLn(PC),D0 ;le bon ?
	BHS	.4
	MOVE.L	ScrAd+4(PC),D0
	RTS

Fin:	LEA	ScrAd+8(PC),A0
	LEA	ScrAd(PC),A1
	CMPM.L	(A0)+,(A1)+
	BEQ.S	.1
	MOVE	#1,-(SP)
	BSR	Basc
	ADDQ	#2,SP
.1	MOVE.L	ScrAd+8(PC),D0
	RTS
