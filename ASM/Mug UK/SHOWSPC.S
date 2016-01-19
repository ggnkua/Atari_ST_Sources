;
; Spectrum 512 Picture Displayer Routine
; --------------------------------------
;
; Coded by: MDK in 1988
;
; Updated by:  MUG U.K in 1991

; Compressed (*.SPC) pictures only !!

adscreen equ $F8000		; $78000 on 512K machines

	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,oldsp

	move.w	#4,-(sp)
	trap	#14
	move.w	d0,oldrez

	clr.w	-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	
	bsr.s	store
	bsr	showspc
	bsr.s	restore

	move.w	oldrez,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	move.l	oldsp,-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp

	move.w	#$4c,-(sp)
	trap	#1

store	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,oldpal
	rts

restore	movem.l	oldpal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	rts

oldsp	ds.l	1
oldrez	ds.w	1
oldpal	ds.w	16
black	ds.w	16

;
; Spectrum 512 Show routine by MDK
;
showspc	bsr.s	dpak_spc   * decompactage
	bsr	vbl_init

	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp

	BSR     vbl_off   * vbl del
	RTS
        
L18E62	ORI.B	#0,D0

*-------------------------------------------------------------*
*             Decompactage de l'image spectrum                *
*-------------------------------------------------------------*

dpak_spc	movem.l	black,d0-d7	; palette to black
	movem.l	d0-d7,$ffff8240.w	; before displaying picture

	MOVEM.L	D0-D7/A0-A5,-(A7)
       	lea     image+12,a0
       	lea     adscreen,a1
	MOVE.W	#1,D1
	MOVE.W	#7,D7
	LEA	32000(A1),A2
	LEA	8(A2),A3
L18E86	LEA	-$7C60(A2),A1
L18E8A	MOVE.B	(A0)+,D6
	EXT.W	D6
	BMI.S	L18E9C
L18E90	MOVE.B	(A0)+,(A1)
	ADDA.W	D1,A1
	EXG	D1,D7
	DBF	D6,L18E90
	BRA.S	L18EAC
L18E9C	NEG.W	D6
	ADDQ.W	#1,D6
	MOVE.B	(A0)+,D0
L18EA2	MOVE.B	D0,(A1)
	ADDA.W	D1,A1
	EXG	D1,D7
	DBF	D6,L18EA2
L18EAC	CMPA.L	A2,A1
	BCS.S	L18E8A
	ADDQ.L	#2,A2
	CMPA.L	A3,A2
	BCS.S	L18E86

*-------------------------------------------------------------*
*             Decompactage  des couleurs de l'image           *
*-------------------------------------------------------------*

	movea.l	image+4,a0
	adda.l	#image+12,a0	
	lea	buffer,A1   * ad.palette
	move.w	#$254,D7
	clr.w	D0
L18EC4	MOVE.W	#$D,D6
	MOVE.W	(A0)+,D1
	LSR.W	#1,D1
	MOVE.W	D0,(A1)+
L18ECE	LSR.W	#1,D1
	BCC.S	L18EDA
	MOVE.W	(A0)+,(A1)+
	DBF	D6,L18ECE
	BRA.S	L18EE0
L18EDA	MOVE.W	D0,(A1)+
	DBF	D6,L18ECE
L18EE0	MOVE.W	D0,(A1)+
	DBF	D7,L18EC4
	MOVEM.L	(A7)+,D0-D7/A0-A5
	RTS

;
; New VBL routine
;	

vbl_init	MOVEM.L	D0-D7/A0-A5,-(A7)
	LEA	L190F0(PC),A5
	MOVE.L	#buffer,(A5)
;	CLR.L	-(A7)		; remove ';' if in GFA etc.
;	MOVE.W	#$20,-(A7)
;	TRAP	#1
;	ADDQ.L	#6,A7
;	MOVE.L	D0,-(A7)
	MOVE.L	$4CE.W,4(A5)
	LEA	L18F66(PC),A0
	MOVE.L	A0,$4CE.W
;	MOVE.W	#$20,-(A7)
;	TRAP	#1
;	ADDQ.L	#6,A7
	MOVEM.L	(A7)+,D0-D7/A0-A5
	RTS

;
; Delete VBL routine
;	

vbl_off	MOVEM.L	D0-D7/A0-A6,-(A7)
	LEA	L190F0(PC),A5
;	CLR.L	-(A7)
;	MOVE.W	#$20,-(A7)
;	TRAP	#1
;	ADDQ.L	#6,A7
;	MOVE.L	D0,-(A7)
	MOVE	SR,-(A7)
	ORI.W	#$700,SR
	MOVE.L	4(A5),$4CE.W
	MOVEA.W	#$8240,A1
	MOVEQ	#7,D0
L18F50	CLR.L	(A1)+
	DBF	D0,L18F50
	MOVE.W	(A7)+,SR
;	MOVE.W	#$20,-(A7)
;	TRAP	#1
;	ADDQ.L	#6,A7
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS

;
; Actual routine to display Spectrum 512 pictures
;	

L18F66	TST.W	$43E.W
	BNE	L190EE
	MOVE	SR,-(A7)
	ORI.W	#$700,SR
	LEA	$FF8240,A4
	LEA	$FF8209,A5
	LEA	(A4),A0
	LEA	(A4),A1
	LEA	(A4),A2
	LEA	L18FA2(PC),A6
	MOVEA.L	L190F0(PC),A3
	MOVE.W	#$C4,D7
	MOVEQ	#0,D0
L18F94	TST.B	(A5)
	BEQ.S	L18F94
	MOVE.B	(A5),D0
	ADDA.L	D0,A6
	ADDA.L	L18E62(PC),A6
	JMP	(A6)
L18FA2	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
L1903A	NOP
	LEA	(A4),A0
	LEA	(A4),A1
	LEA	(A4),A2
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	NOP
	DBF	D7,L1903A
	LEA	(A4),A0
	LEA	(A4),A1
	LEA	(A4),A2
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	LEA	(A4),A0
	LEA	(A4),A1
	LEA	(A4),A2
	LEA	-$4A60(A3),A4
	NOP
	NOP
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A0)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.L	(A3)+,(A2)+
	MOVE.W	(A7)+,SR
L190EE	RTS
L190F0	ds.l 2

image   incbin  a:\match_5.spc
 section bss
buffer  ds.l 19200

