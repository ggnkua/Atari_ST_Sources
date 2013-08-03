	MOVE.L 4(A7),A5
	MOVE.L #$100,-(SP)
	MOVE.L A5,-(SP)
	MOVE.L #$4A0000,-(SP)
	TRAP #1
	ADD.W #12,SP
	
	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)		;supervisor mode
	TRAP	#1
	ADDQ.L	#6,SP
	MOVE.L	D0,old_sp
	
	move.l	#0,$484.w		;no keyclick
	bsr	on

	bra	strt

zippy	movem.l d0-a6,-(sp)		;save registers
	bsr	(music+8)		;call playback
	movem.l	(sp)+,d0-a6		;restore registers
	move.l	oldint,-(sp)		;old vbl on sp
	rts				;call old vbl

on	move.l	$70.w,oldint		;save old vbl
	moveq	#1,d0			;music #1
	bsr	music			;call init
	move.l	#zippy,$70.w		;install new vbl
	rts

off	move.l	oldint,$70.w		;restore old vbl
	move.l	#$08080000,$ff8800	;clear vol. chan A
	move.l	#$09090000,$ff8800	;clear vol. chan B
	move.l	#$0a0a0000,$ff8800	;clear vol. chan C
	rts

oldstk	dc.l	0
oldint	dc.l	0

music	incbin	"thalion.mus"	;change this filename !!

strt	MOVE.W	#4,-(SP)		;get rez
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.W	D0,old_rez
	CMPI.W	#2,D0
	BEQ	quit

	LEA	$FFFF8240.W,A0
	LEA	def_pal,A1
	LEA	32(A1),A1		;store colours
	MOVEM.L	(A0)+,D0-D7
	MOVEM.L	D0-D7,-(A1)

	CLR.W	-(SP)
	MOVE.L	#-1,-(SP)
	MOVE.L	#-1,-(SP)
	MOVE.W	#5,-(SP)		;set screen
	TRAP	#14
	LEA	12(SP),SP

	MOVE.B	#4,def_spd		;default scroll speed
	MOVE.B	def_spd,speed

	;CLR.L	-(SP)
	;MOVE.W	#$20,-(SP)		;supervisor mode
	;TRAP	#1
	;ADDQ.L	#6,SP
	;MOVE.L	D0,old_sp
	
	DC.W    $A00A                   ;kill mouse
	
	MOVE.W	#4,-(SP)		;get rez
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.W	D0,old_rez
	CMPI.W	#2,D0
	BEQ	quit

	LEA	$FFFF8240.W,A0
	LEA	def_pal,A1
	LEA	32(A1),A1		;store colours
	MOVEM.L	(A0)+,D0-D7
	MOVEM.L	D0-D7,-(A1)

	LEA	$FFFF8260.W,A0
	LEA	new_pal,A1
	MOVEM.L	(A1)+,D0-D7
	MOVEM.L	D0-D7,-(A0)

	CLR.W	-(SP)
	MOVE.L	#-1,-(SP)
	MOVE.L	#-1,-(SP)
	MOVE.W	#5,-(SP)		;set screen
	TRAP	#14
	LEA	12(SP),SP

	MOVE.W	#8000,D0
	LEA	$44E,A0
	MOVE.L	(A0),A0
	LEA	piccy+34,A1
nextlb	MOVE.L	(A1)+,(A0)+
	DBF	D0,nextlb

	MOVE.B	#3,def_spd		;default scroll speed
	MOVE.B	def_spd,speed

******* START OF SCROLLER CODE ************************

start	LEA	text,A0
scroll	MOVEQ.L	#0,D4
	MOVE.B	(A0),D4			;next letter
 	TST.B	(A0)+			;end of text
	BNE.S	chr_val
	BRA.S	start

chr_val	SUBI.B	#32,D4			;wheres that character?
	DIVU.W	#10,D4			;divide	by number of letters per line
	MOVEQ.L	#0,D5
	MOVE.W	D4,D5
	MULU.W	#400,D5			;multiply by 160 (bytes per line) * height
	MULU.W	#10,D5
	CLR.W	D4
	SWAP	D4
	ASL	#4,D4			;multiply remainder by (width of char)
	LEA	font,A5
	ADD.W	D5,A5
	ADD.W	D4,A5
	ADD.L	#160,A5

	move.w	#0,byt	
	move.w	#15,byt1

	moveq	#1,d3
	MOVEQ.W	#21,D7
	LEA	stc_pad,A6		;copy letter to scratch pad
cpy_chr	MOVE.L	(A5),(A6)
	MOVE.L	8(A5),160(A6)
	ADDQ.L	#4,A6
	LEA	160(A5),A5
	DBF	D7,cpy_chr

sechalf	MOVE.W	byt1,D6			;pixels across
pixels	MOVE.L	$44E.W,A1		;screen address
	LEA	800(A1),A1		;some where near the bottom!
	LEA	stc_pad,A6
	adda	byt,a6

	MOVEQ.W	#21,D7			;lines to ROXL
lines	MOVE.L	(A6),D0
	LSL.L	D0
	MOVE.L	D0,(A6)+

	ROXL	152(A1)			;lotsa ROXL's
	ROXL	144(A1)
	ROXL	136(A1)
	ROXL	128(A1)
	ROXL	120(A1)
	ROXL	112(A1)
	ROXL	104(A1)
	ROXL	96(A1)
	ROXL	88(A1)
	ROXL	80(A1)
	ROXL	72(A1)
	ROXL	64(A1)
	ROXL	56(A1)
	ROXL	48(A1)
	ROXL	40(A1)
	ROXL	32(A1)
	ROXL	24(A1)
	ROXL	16(A1)
	ROXL	8(A1)
	ROXL	(A1)

	LEA	160(A1),A1		;add 160 (1 line) to screen addr
	DBF	D7,lines

	SUBQ.B	#1,speed
	BNE.S	no_wait
	MOVE.L	$462.W,D0		;vbl frame counter
vbl	CMP.L	$462.W,D0		;wait for vbl
	BEQ.S	vbl
	MOVE.B	def_spd,speed

no_wait	DBF	D6,pixels		;rest of the pixels
	move.w	#160,byt
	move.w	#10,byt1
	dbf	d3,sechalf

	MOVE.W	#$FF,-(SP)		;wait for a key press
	MOVE.W	#$06,-(SP)
	TRAP	#1
	ADDQ.L	#4,SP

	;CMPI.B	#"+",D0
	;BEQ.S	plus
	;CMPI.B	#"-",D0
	;BEQ.S	minus
	CMPI.B	#"0",D0
	BNE.S	G1
	eor.b	#2,hertz
	eor.w	#$111,$ffff8240
	bra	return
G1	CMPI.B	#"1",D0
	BNE.S	G2
	MOVE.L	#prog1,game
	BRA	loadok
G2	CMPI.B	#"2",D0
	BNE.S	G3
	MOVE.L	#prog2,game
	BRA	loadok
G3	CMPI.B	#"3",D0
	BNE.S	G4
	MOVE.L	#prog3,game
	BRA.S	loadok
G4	;CMPI.B	#"4",D0
	;BNE.S	FUNKEY
	;MOVE.L	#prog4,game
	;BRA.S	loadok
FUNKEY	SWAP	D0
	CMPI.B	#$3B,D0
	BNE.S	F2
F1	MOVEQ	#1,D0
	BSR	music
	BRA.S	return
F2	CMPI.B	#$3C,D0
	BNE.S	F3
	MOVEQ	#6,D0
	BSR	music
	BRA.S	return
F3	CMPI.B	#$3D,D0
	BNE.S	F4
	MOVEQ	#8,D0
	BSR	music
	BRA.S	return
F4	CMPI.B	#$3E,D0
	BNE.S	return
	MOVEQ	#2,D0
	BSR	music

return	BRA	scroll

******* END OF SCROLLER CODE ***************************

******** SPEED ROUTINES **************************

plus	CMPI.B	#8,def_spd
	BGT.S	return
	ADDQ.B	#1,def_spd
	BRA.S	return

minus	CMPI.B	#2,def_spd
	BLT.S	return
	SUBQ.B	#1,def_spd
	BRA.S	return

******* END SPEED ROUTINES **************************



loadok	MOVE.W	old_rez,-(SP)		;restore rez
	MOVE.L	#-1,-(SP)
	MOVE.L	#-1,-(SP)
	MOVE.W	#5,-(SP)		;set screen
	TRAP	#14
	LEA	12(SP),SP

	LEA	def_pal,A0
	LEA	$FFFF8260.W,A1		;restore colours
	MOVEM.L	(A0)+,D0-D7
	MOVEM.L	D0-D7,-(A1)

quit	JSR	off

	move.b	hertz,d4
	eor.b	d4,$FF820A

	MOVE.L	old_sp,-(SP)
	MOVE.W	#$20,-(SP)		;user mode
	TRAP	#1
	ADDQ.L	#6,SP
	
	move.l	game,d4
	CLR.L	-(SP)
	MOVE.L	#CT,-(SP)
	MOVE.L	D4,-(SP)
	CLR.W	-(SP)
	MOVE.W	#$4B,-(SP)
	TRAP	#1

	pea	error(pc)
        move.w	#9,-(a7)
        trap	#1		;display message
        addq.l	#6,a7
	

	move.w #7,-(sp)		;wait key
	trap #1			;call gemdos
	lea 2(sp),sp		;correct stack
	clr.w -(sp)		;terminate
	trap #1			;call gemdos


CT	DC.L	0
hertz	ds.b	1
game	ds.l	1
prog1	dc.b	"\frenetic.twb",0
prog2	dc.b	"\swii.spk",0
prog3	dc.b	"\mindbend.spk",0
prog4	dc.b	"\empty",0
error	dc.b	"SHIT !! Where's the fucking file !!!",0

text	dc.b	"WELCOME TO ANOTHER WILD! MENU.      "
	incbin	"19.doc"

new_pal	DC.W	$000,$665,$011,$033,$044,$043,$054,$034,$045,$365,$065,$007,$777,$227,$565,$022

	EVEN

font	incbin	"yofont.pi1"
piccy	incbin	"cd19pic.pi1"

byt	DS.W	1
byt1	DS.W	1
old_sp	DS.L	1
old_rez	DS.W	1
speed	DS.W	1
def_spd	DS.W	1
def_pal	DS.W	16
stc_pad	DS.L	16

