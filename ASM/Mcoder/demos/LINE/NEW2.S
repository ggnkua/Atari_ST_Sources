	opt	o+,ow-
milieu		equ	160
OFFSET_GAUCHE	EQU	64
LARGE		EQU	192
;
; OFFSET=32=4*8 A GAUCHE=4*16 PIXELS A GAUCHE=OFFSET GAUCHE DE 64 PIXELS
;
; 12*8 BYTES DE LARGE=12*16 PIXELS DE LARGE=192 PIXELS DE LARGE
;
; A0=ADRESSE ECRAN
; D3=CUMUL
; D4=DX
; D5=DY
; D7=PATTERN
;
GENERE	MACRO
lab\<number>:
	ENDM
DXSUPDY	MACRO
lab\<number>:
	iif	(\1&15)=0	move	#$8000,d7
	iif	(\1&15)=1	or	#$4000,d7
	iif	(\1&15)=2	or	#$2000,d7
	iif	(\1&15)=3	or	#$1000,d7
	iif	(\1&15)=4	or	#$0800,d7
	iif	(\1&15)=5	or	#$0400,d7
	iif	(\1&15)=6	or	#$0200,d7
	iif	(\1&15)=7	or	#$0100,d7
	iif	(\1&15)=8	tas	d7
	iif	(\1&15)=9	or	#$40,d7
	iif	(\1&15)=10	or	#$20,d7
	iif	(\1&15)=11	or	#$10,d7
	iif	(\1&15)=12	addq	#8,d7
	iif	(\1&15)=13	addq	#4,d7
	iif	(\1&15)=14	addq	#2,d7
	iif	(\1&15)=15	addq	#1,d7
number	set	number+1
	ifne	~\1&15
	SUB	D5,D3
	BHS.s	\@
	ADD	D4,D3
	or	d7,(\1-milieu)&$FFF0/2(A0)
	clr	d7
	elseif
	or	d7,(\1-milieu)&$FFF0/2(A0)
	SUB	D5,D3
	BHS.s	\@
	ADD	D4,D3
	endc
	lea	y(A0),A0
\@
	endm
;
; D0=X GAUCHE
; D2=X DROITE
; A0=ECRAN+YBAS*160
;
	ADD	D0,D0
	LEA	OFFSETS+LARGE/2(PC),A3
	MOVE	(A3,D0.W),D0
	MOVEQ	#-16,D3
	AND	D2,D3
	ASR	#1,D3
	ADD	D2,D2
	MOVE	(A3,D2.W),D2
	LEA	RETOUR2(PC),A4
	LEA	CODE2-RETOUR2+4(A4,D2.W),A3
	MOVE	(A3),D1
	MOVE	#$4ED4,(A3)		;JMP (A4)
	MOVEQ	#0,D7
	JMP	CODE2-RETOUR2(A4,D0.W)

BRANCHE	MACRO
	dc.w	lab\<number>-CODE1
number	set	number+1
	ENDM

OFFSETS:
number	set	OFFSET_GAUCHE
	rept	LARGE
	BRANCHE
	endr
;
; D0=X GAUCHE
; D2=X DROITE
; A0=ECRAN+Y HAUT*160
;
	ADD	D0,D0
	LEA	OFFSETS+LARGE/2(PC),A3
	MOVE	(A3,D0.W),D0
	MOVEQ	#-16,D3
	AND	D2,D3
	ASR	#1,D3
	ADD	D2,D2
	MOVE	(A3,D2.W),D2
	LEA	RETOUR1(PC),A4
	LEA	CODE1-RETOUR1+4(A4,D2.W),A3
	MOVE	(A3),D1
	MOVE	#$4ED4,(A3)		;JMP (A4)
	MOVEQ	#0,D7
	JMP	CODE1-RETOUR1(A4,D0.W)

RETOUR1:
	OR	D7,(A0,D3.W)
	MOVE	D1,(A3)
	JMP	(A6)
CODE1:
number	set	OFFSET_GAUCHE
y	set	160
x	set	OFFSET_GAUCHE
	rept	LARGE-1
	DXSUPDY	x
x	set	x+1
	endr
	GENERE
	ADDQ	#1,D7
	NOP
	NOP			;ici est pok‚ le dernier JMP !!!!
;
; OFFSETS DE CODE2=OFFSETS DE CODE1
;
RETOUR2:
	OR	D7,(A0,D3.W)
	MOVE	D1,(A3)
	JMP	(A6)
CODE2:
number	set	1000		;PAS D'IMPORTANCE
y	set	-160
x	set	OFFSET_GAUCHE
	rept	LARGE-1
	DXSUPDY	x
x	set	x+1
	endr
	ADDQ	#1,D7
	NOP
	NOP
