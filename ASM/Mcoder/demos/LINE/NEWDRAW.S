	opt	o+,ow-,m+

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
	add	d5,d6
	bcc.s	\@
	or	d7,\1&$FFF0/2(a6)
	clr	d7
	elseif
	or	d7,\1&$FFF0/2(a6)
	add	d5,d6
	bcc.s	\@
	endc
	lea	y(a6),a6
\@
	endm

;
; D0=X GAUCHE
; D1=X DROITE
; A6=ECRAN+YBAS*160
; D5=PENTE
;
	ADD	D0,D0
	MOVE	OFFSETS(PC,D0.W),D0
	MOVEQ	#-16,D3
	AND	D1,D3
	LSR	#1,D3
	ADD	D1,D1
	MOVE	OFFSETS(PC,D1.W),D1
	LEA	RETOUR2(PC),A0
	LEA	CODE2-RETOUR2+4(A0,D1.W),A1
	MOVE	(A1),D2
	MOVE	#$4ED0,(A1)		;JMP (A0)
	MOVEQ	#0,D7
	MOVEQ	#-1,D6			;ACCUMULATEUR BRESENHAM MODIFIE
	JMP	CODE2-RETOUR2(A0,D0.W)
;
; PREMIERE ROUTINE VALABLE POUR DX>=DY
;  ET Y0<=Y1
;
; D0=X DEPART (X0)
; D1=X ARRIVEE (X1)
; A6=ADRESSE ECRAN (Y DEPART*160)
; D5=PENTE (DY/DX*65536)
;
;
; AUTRES ASTUCES :
;	LA ROUTINE D'AFFICHAGE FAIT 16 OCTETS
;	ON PEUT DONC GAGNER UNE TABLE
;	+ LE 4eme OCTET OU JE POKE UN JMP EST CONSTANT !!!
;
;
; D0=X GAUCHE
; D1=X DROITE
; A6=ECRAN+Y HAUT*160
; D5=PENTE
;
	ADD	D0,D0
	MOVE	OFFSETS(PC,D0.W),D0
	MOVEQ	#-16,D3
	AND	D1,D3
	LSR	#1,D3
	ADD	D1,D1
	MOVE	OFFSETS(PC,D1.W),D1
	LEA	RETOUR1(PC),A0
	LEA	CODE1-RETOUR1+4(A0,D1.W),A1
	MOVE	(A1),D2
	MOVE	#$4ED0,(A1)		;JMP (A0)
	MOVEQ	#0,D7
	MOVEQ	#-1,D6			;ACCUMULATEUR BRESENHAM MODIFIE
	JMP	CODE1-RETOUR1(A0,D0.W)

BRANCHE	MACRO
	dc.w	lab\<number>-lab0
number	set	number+1
	ENDM

OFFSETS:
number	set	0
	rept	320
	BRANCHE
	endr

RETOUR1:
	OR	D7,(A6,D3.W)
	MOVE	D2,(A1)

	ILLEGAL
CODE1:
number	set	0
y	set	160
x	set	0
	rept	319
	DXSUPDY	x
x	set	x+1
	endr
lab319	ADDQ	#1,D7
	NOP
	NOP			;ici est pok‚ le dernier JMP !!!!
;
; OFFSETS DE CODE2=OFFSETS DE CODE1
;
RETOUR2:
	OR	D7,(A6,D3.W)
	MOVE	D2,(A1)

	ILLEGAL
CODE2:
number	set	320
y	set	-160
x	set	0
	rept	319
	DXSUPDY	x
x	set	x+1
	endr
	ADDQ	#1,D7
	NOP
	NOP
