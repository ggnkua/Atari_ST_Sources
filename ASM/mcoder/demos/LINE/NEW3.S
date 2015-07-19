	opt	o+,ow-,T-
	ORG	$800		;OPTIMISATION ULTIME ???
;
; LEA RETOUR\W,A5
;
ECRAN	EQUR	A0	;ECRAN
CUMUL	EQUR	D3	;CUMUL
DX	EQUR	D4	;DELTAX
DY	EQUR	D5	;DELTAY
PAT	EQUR	D7	;PATTERN
RETOUR1	EQU	5	;A5
RETOUR2	EQUR	A6	;A6=RETOUR DE DRAW
FRE1	EQUR	D1	;LIBRE
FRE2	EQUR	D6	;LIBRE
FRE3	EQUR	A3	;LIBRE
FRE4	EQUR	A4	;LIBRE
	END
;
milieu		equ	160
OFFSET_GAUCHE	EQU	64
OFFSET_DROIT	EQU	256	;PAR EXEMPLE
LARGE		EQU	192
;
; OFFSET=32=4*8 A GAUCHE=4*16 PIXELS A GAUCHE=OFFSET GAUCHE DE 64 PIXELS
;
; 12*8 BYTES DE LARGE=12*16 PIXELS DE LARGE=192 PIXELS DE LARGE
;
; PAT=PATTERN
;
GENERE	MACRO
lab\<number>:
	ENDM

DXSUPDY	MACRO
lab\<number>:
	iif	(\1&15)=0	move	#$8000,PAT
	iif	(\1&15)=1	or	#$4000,PAT
	iif	(\1&15)=2	or	#$2000,PAT
	iif	(\1&15)=3	or	#$1000,PAT
	iif	(\1&15)=4	or	#$0800,PAT
	iif	(\1&15)=5	or	#$0400,PAT
	iif	(\1&15)=6	or	#$0200,PAT
	iif	(\1&15)=7	or	#$0100,PAT
	iif	(\1&15)=8	tas	PAT
	iif	(\1&15)=9	or	#$40,PAT
	iif	(\1&15)=10	or	#$20,PAT
	iif	(\1&15)=11	or	#$10,PAT
	iif	(\1&15)=12	addq	#8,PAT
	iif	(\1&15)=13	addq	#4,PAT
	iif	(\1&15)=14	addq	#2,PAT
	iif	(\1&15)=15	addq	#1,PAT
number	set	number+1
	ifne	~\1&15
	SUB	DY,CUMUL
	BHS.s	\@
	ADD	DX,CUMUL
	or	PAT,(\1-milieu)&-16/2(ECRAN)
	clr	PAT
	elseif
	or	PAT,(\1-milieu)&-16/2(ECRAN)
	SUB	DY,CUMUL
	BHS.s	\@
	ADD	DX,CUMUL
	endc
	lea	y(ECRAN),ECRAN
\@
	endm
;
; D0=X GAUCHE
; D2=X DROITE
; ECRAN=ECRAN+YBAS*160
;
	MOVEQ	#-16,FRE2
	AND	D2,FRE2
	MOVEQ	#0,PAT
	ADD	D0,D0
	ADD	D2,D2
	MOVE	OFFSETS1+LARGE/2(PC,D0.W),FRE4
	MOVE	OFFSETS1+LARGE/2(PC,D2.W),FRE3
	MOVE	(FRE3),FRE1
	MOVE	#$4ED0+RETOUR1,(FRE3)		;JMP (An)
	JMP	-4(FRE4)

BRANCHE	MACRO
	dc.w	lab\<number>+4
number	set	number+1
	ENDM

OFFSETS1
number	set	OFFSET_GAUCHE
	rept	LARGE
	BRANCHE
	endr
;
; D0=X GAUCHE
; D2=X DROITE
; ECRAN=ECRAN+Y HAUT*160
;
	MOVEQ	#-16,FRE2
	AND	D2,FRE2
	MOVEQ	#0,PAT
	ADD	D0,D0
	ADD	D2,D2
	MOVE	OFFSETS2+LARGE/2(PC,D0.W),FRE4
	MOVE	OFFSETS2+LARGE/2(PC,D2.W),FRE3
	MOVE	(FRE3),FRE1
	MOVE	#$4ED0+RETOUR1,(FRE3)		;JMP (An)
	JMP	-4(FRE4)
OFFSETS2
number	set	OFFSET_DROIT
	rept	LARGE
	BRANCHE
	endr

CODE1:
number	set	OFFSET_GAUCHE
y	set	160
x	set	OFFSET_GAUCHE
	rept	LARGE-1
	DXSUPDY	x
x	set	x+1
	endr
	GENERE
	ADDQ	#1,PAT
	NOP
	NOP			;ici est pok‚ le dernier JMP !!!
;
; OFFSETS DE CODE2=OFFSETS DE CODE1
;
CODE2:
number	set	OFFSET_DROIT
y	set	-160
x	set	OFFSET_GAUCHE
	rept	LARGE-1
	DXSUPDY	x
x	set	x+1
	endr
	GENERE
	ADDQ	#1,PAT
	NOP
	NOP			;ici est pok‚ le dernier JMP !!!

RETOUR:
	ASR	#1,FRE2
	OR	PAT,(ECRAN,FRE2.W)
	MOVE	FRE1,(FRE3)
	JMP	(RETOUR2)
