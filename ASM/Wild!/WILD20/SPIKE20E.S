	;opt	o+

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
	
	move.l	#reboot,$42a
	move.l	#$31415926,$426
	
	move.l	#0,$484.w		;no keyclick
	bsr	on

	bra	strt

zippy	movem.l d0-a6,-(sp)		;save registers
	bsr	(music+8)		;call playback
	movem.l	(sp)+,d0-a6		;restore registers
	move.l	oldint,-(sp)		;old vbl on sp
	rts				;call old vbl

on	move.l	$70.w,oldint		;save old vbl
	moveq	#5,d0			;music number
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

	;move.l	#text,a0
enc	;move.b	(a0),d0
	;beq.s	fin
	;mulu.w	#2,d0
	;move.b	d0,(a0)+
	;bra.s	enc

fin	MOVE.B	#3,def_spd		;default scroll speed
	MOVE.B	def_spd,speed
	move.l	#chopsrt,choppos

******* START OF SCROLLER CODE ************************

start	LEA	text,A0
scroll	MOVEQ.L	#0,D4
	MOVE.B	(A0),D4			;next letter
 	TST.B	(A0)+			;end of text
	BNE.S	chr_val
	BRA.S	start

chr_val	divu.w	#2,d4
	SUBI.B	#32,D4			;wheres that character?
	DIVU.W	#20,D4			;divide	by number of letters per line
	MOVEQ.L	#0,D5
	MOVE.W	D4,D5
	MULU.W	#144,D5			;multiply by 160 (bytes per line) * height
	MULU.W	#10,D5
	CLR.W	D4
	SWAP	D4
	ASL	#3,D4			;multiply remainder by (width of char)
	LEA	font,A5
	ADD.W	D5,A5
	ADD.W	D4,A5
	;ADD.L	#160,A5

	;move.w	#0,byt	
	move.w	#12,byt1

	;moveq	#1,d3
	MOVEQ.W	#7,D7
	LEA	stc_pad,A6		;copy letter to scratch pad
cpy_chr	MOVE.L	(A5),(A6)
	;MOVE.L	8(A5),160(A6)
	ADDQ.L	#4,A6
	LEA	160(A5),A5
	DBF	D7,cpy_chr

sechalf	MOVE.W	byt1,D6			;pixels across
pixels	MOVE.L	$44E.W,A1		;screen address
	LEA	160(A1),A1		;some where near the bottom!
	LEA	stc_pad,A6
	adda	byt,a6

	MOVEQ.W	#7,D7			;lines to ROXL
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
	;move.w	#160,byt
	;move.w	#7,byt1
	;dbf	d3,sechalf

	bsr	chop

	MOVE.W	#$FF,-(SP)		;wait for a key press
	MOVE.W	#$06,-(SP)
	TRAP	#1
	ADDQ.L	#4,SP

	;CMPI.B	#"+",D0
	;BEQ	plus
	;CMPI.B	#"-",D0
	;BEQ	minus
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
	BRA	loadok
G4	CMPI.B	#"4",D0
	BNE.S	FUNKEY
	MOVE.L	#prog4,game
	BRA	loadok
FUNKEY	SWAP	D0
	SUB	#$3A,D0
	CMPI.B	#1,D0
	BLT	return
	cmpi.b	#10,d0
	bgt	return
	BSR	music

return	BRA	scroll

******* END OF SCROLLER CODE ***************************

reboot	lea	$70000,a7
	eor.b	#2,$ffff820a
	move.b	#$7,$ffff8201
	move.b	#$80,$ffff8203

	move.w	#8000,d0
	move.l	#$78000,a0
	;move.l	(a0),a0
	lea	rebpic+34,a1
nextlc	move.l	(a1)+,(a0)+
	dbf	d0,nextlc

	lea	$ffff8260.w,a0
	lea	reb_pal,a1
	movem.l	(a1)+,d0-d7
	movem.l	d0-d7,-(a0)

	;clr.w	-(a7)
	;move.l	#-1,-(a7)
	;move.l	#-1,-(a7)
	;move.w	#5,-(a7)		;set screen
	;trap	#14
	;lea	12(a7),a7

	clr.l	$426.w
rebloop	bra.s	rebloop

******** SPEED ROUTINES **************************

plus	;CMPI.B	#3,def_spd
	;BGT.S	return
	;ADDQ.B	#1,def_spd
	;BRA.S	return

minus	;CMPI.B	#3,def_spd
	;BLT.S	return
	;SUBQ.B	#1,def_spd
	;BRA.S	return

******* END SPEED ROUTINES **************************

chop	movem.l	d0-d1/a0-a1,stregs
	clr.l	d0
	move.l	choppos,a0
	move.b	(a0),d0
	cmpi.b	#$ff,d0
	bne	notfin
	move.l	#chopdat,choppos
	bra	chopfin
notfin	move.l	$44e,a1	
	move.l	#font,a0
	lea	4872(a1),a1
	lea	4960(a0),a0
	mulu	#16,d0
	add.l	d0,a0
	move.w	#69,d1
ch1	move.l	(a0)+,(a1)
	adda	#4,a1
	move.l	(a0)+,(a1)
	adda	#4,a1
	move.l	(a0)+,(a1)
	adda	#4,a1
	move.l	(a0),(a1)
	adda.l	#148,a0
	adda.l	#148,a1
	dbf	d1,ch1
chopfin	movem.l	stregs,d0-d1/a0-a1
	add.l	#1,choppos
	rts
	
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
	;move.l	#$000,$ffff8240

quit	JSR	off

	move.b	hertz,d4
	eor.b	d4,$FF820A

	clr.l	$426.w

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

	;pea	error(pc)
        ;move.w	#9,-(a7)
        ;trap	#1		;display message
        ;addq.l	#6,a7
	

	;move.w #7,-(sp)	;wait key
	;trap #1		;call gemdos
	;lea 2(sp),sp		;correct stack


fuck	clr.w -(sp)		;terminate
	trap #1			;call gemdos


CT	DC.L	0
hertz	ds.b	1
game	ds.l	1
choppos	ds.l	1
prog1	dc.b	"\grav.twb",0
prog2	dc.b	"\desktop",0
prog3	dc.b	"\snooker.twb",0
prog4	dc.b	"\empty",0
error	;dc.b	"SHIT !! Where's the fucking file !!!",0
chopsrt	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
chopdat	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,3,6,9
	dc.b	9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9
	dc.b	8,8,7,7,6,6,5,5,4,4,3,3,2,2,1,1,0
	dc.b	$ff

text	dc.b	32	;ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	incbin	"20.doc"

new_pal	DC.W	$000,$600,$000,$001,$002,$012,$113,$123,$224,$234,$335,$445,$446,$556,$767,$777
reb_pal	dc.w	$000,$777,$775,$763,$752,$742,$632,$522,$410,$300,$556,$223,$754,$112,$334,$700

	EVEN

font	incbin	"cd20fant.pi1"
piccy	incbin	"cd20apic.pi1"
rebpic	incbin	"reboot.pi1"

byt	DS.W	1
byt1	DS.W	1
old_sp	DS.L	1
old_rez	DS.W	1
speed	DS.W	1
def_spd	DS.W	1
def_pal	DS.W	16
stc_pad	DS.L	16
stregs	ds.l	16


    
