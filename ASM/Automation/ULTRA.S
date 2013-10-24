*
* Ultraload (Uni-load II)
*
* Written by Dack of The Un-Nameables
* (Based on Uni-load by The Law)
*
* Includes depacker to/from odd addresses
*
* NOTE:-
*
* buff_len  = Max length of a PACKED file
* max_files = No. of files open at once + 6
*
* only packed files are buffered, unpacked data
* is treated as normal...
*
* gam = filename to $4b
*

		opt c+,d-

buff_len	equ	$18c0a
max_files	equ	32
	bra	main

gam		dc.b "entvap",0
		even

text	DC.B "Vapour presents . . ."
	DC.B 00,00

	EVEN

;SET TABS TO 10 FOR DISASSEMBLY

	
main	MOVEA.L	4(A7),A5
	move.l $c(a5),d0
	add.l $14(a5),d0
	add.l $1c(a5),d0
	add.l #$200,d0
	add.l #buff_len,d0	;add buffer length
	move.l d0,-(sp)
	move.l a5,-(sp)
	move.l #$4a0000,-(sp)
	trap #1
	lea $c(a7),a7

	dc.l $a000a00a
	clr.w -(sp)
	pea $ffffffff
	move.l (a7),-(sp)
	move.w #5,-(sp)
	trap #14
	lea $c(a7),a7
	dc.w $a009

	pea	text
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7

*
* buffer address
* (Can be absolute....)
* 
	move.l	#buff_start,buff_add	;set buffer start address

CHEAT	CLR.L	-(A7)
	MOVE.W	#$20,-(A7)
	TRAP	#$01
	ADDQ.L	#6,A7
	LEA	SUPERLNG(PC),A6
	MOVE.L	D0,(A6)
	MOVE.L	$84,tr1
	MOVE.L	#T1,$84
	MOVE.L	SUPERLNG(PC),-(A7)
	MOVE.W	#$20,-(A7)
	TRAP	#$01
	ADDQ.L	#6,A7
stkk	clr.w	in_use
	clr.l $60000
	pea $60000
	move.l (a7),-(sp)
	move.l #gam,-(sp)
	move.l #$4b0000,-(sp)
	trap #1
	lea $0c(a7),a7
	clr.w -(sp)
	trap #1
SUPERLNG	DC.L	0


;multi file read 1st October 1989
;fix 11th October 1989 for decode from odd address
;bastard bug to find

T1		tst.w	inside
		bne	bye
		MOVEM.L a0-a6/d0-d7,reg
		movea.l	a7,a1
		addq.l 	#6,a1
		move.w 	(a7),d0
		btst 	#$d,d0
		bne.s 	ok1
		move.l 	usp,a1
ok1		cmpi.w  #0,(a1)
		bne.s next1
		move.l	tr1(pc),$84.w
		bra.s	open
next1		cmpi.w 	#$3d,(a1)
		beq	openup
		cmpi.w	#$3f,(a1)
		beq	read
		cmpi.w	#$3e,(a1)
		beq	close
		cmpi.w	#$42,(a1)
		beq	seek
		cmpi.w	#$4e,(a1)
		beq	ffirst
		cmpi.w  #$3c,(a1)
		beq 	create
		cmpi.w	#$40,(a1)
		beq 	write
open		movem.l 	reg(pc),a0-a6/d0-d7
bye		dc.w 	$4ef9
tr1		dc.l 	$0

openup		move.w	#1,inside	;do normal traps
		lea	f_names,a0
		add.l	#300,a0
		move.l	#5,d0
s_loop		addq.l	#1,d0
		add.l	#60,a0
		tst.b	(a0)
		bne.s	s_loop		;search for empty slot

;d0=my pretend file handle

		move.l	d0,d7

****		
		move.l d0,d6

		move.l	a0,a5
		move.l	2(a1),a6	;save file name address

;open file
		clr.w	-(a7)
		move.l	a6,-(a7)
		move.w	#$3d,-(a7)
		trap	#1
		addq.l	#8,a7

		tst.l	d0
		bmi	error		;in case file not there

		move.w	d0,d4
		clr.l i_buff
		pea i_buff
		move.l #8,-(a7)
		move.w d4,-(a7)
		move.w #$3f,-(a7)
		trap #1
		lea 12(a7),a7
		clr.w -(a7)
		move.w d4,-(a7)
		clr.l -(a7)
		move.w #$42,-(a7)
		trap #1
		lea 10(a7),a7
		cmp.l #"LSD!",i_buff
		beq.s nermal	
		lea real_hand,a0
		lsl.l #2,d7
		move.l d4,(a0,d7.w)
		move.b #"0",(a5)
		bra not_good

;copy file name to storage

nermal		move.l	#59,d0
c_loop		move.b	(a6)+,(a5)+
		dbra	d0,c_loop

		move.l	i_len,d5
not_com		lea	f_lengths,a0
		lsl.l	#2,d7
		move.l	d5,(a0,d7.w)		;save file length in array
		lea	so_read,a0
		move.l #0,(a0,d7.w)
		lea real_hand,a0
		move.l #-1,(a0,d7.w)
		
;close file as finished

		move.w	d4,-(a7)
		move.w	#$3e,-(a7)
		trap	#1
		addq.l	#4,a7

not_good
		clr.w	inside		;my traps again
		move.l d6,-(a7)
		movem.l reg,a0-a6/d0-d7	
		move.l	(a7)+,d0	;give back my handle
		rte

read		clr.l	d0
		move.w	2(a1),d0	;get handle
		cmp.l	in_use,d0
		beq	all_in		;already loaded

		move.l d0,d1
		lsl.l #2,d1
		lea real_hand,a0
		move.l (a0,d1.w),d2
		cmp.l #-1,d2
		beq.s cor_blimey

		move.l 4(a1),d0
		move.l 8(a1),d1
		move.w #1,inside
		move.l d1,-(a7)
		move.l d0,-(a7)
		move.w d2,-(a7)
		move.w #$3f,-(a7)
		trap #1
		lea 12(a7),a7
		clr.w inside

		move.l d0,d4
		bra titter

cor_blimey	move.l	a1,a5
		move.w	#1,inside
		move.l	d0,in_use
		mulu 	#60,d0
		lea	f_names,a0
		add.l	d0,a0		;get correct filename
		clr.w	-(a7)
		move.l	a0,-(a7)
		move.w	#$3d,-(a7)
		trap	#1
		addq.l	#8,a7
		move.w	d0,d6
		move.l	buff_add,-(a7)
		move.l	#buff_len,-(a7)
		move.w	d0,-(a7)
		move.w	#$3f,-(a7)
		trap	#1
		lea	12(a7),a7
		move.w	d6,-(a7)
		move.w	#$3e,-(a7)
		trap	#1
		addq.l	#4,a7
		clr.w	inside
		move.l	buff_add,a0
		move.l	a0,a1
		add.l	#200,a1
		move.l	4(a0),d7	;length
		bsr	DEPACK
		move.l	buff_add,a0
		move.l	a0,a1
		add.l	#200,a1
m2_back		move.b	(a1)+,(a0)+
		subq.l	#1,d7
		bne.s	m2_back
read_in		move.l	a5,a1		;put stack back in a1
all_in		move.l	4(a1),d0	;bytes to move
		move.l	d0,d4
		move.l	8(a1),a0	;whereto
		move.l	in_use,d1
		lsl.l	#2,d1		;*4
		lea	so_read,a2
		lea	f_lengths,a3
		move.l	(a2,d1.w),d2	;current offset
		move.l	(a3,d1.w),d3	;length of this file
		move.l	buff_add,a1
		add.l	d2,a1
do_it		move.b	(a1)+,(a0)+
		addq.l	#1,d2
		cmp.l	d2,d3
		blt.s	past_end
		subq.l	#1,d0
		bne.s	do_it
		bra.s	wibble
past_end	move.l	d3,d2		;if past end then offset=end
wibble		move.l	d2,(a2,d1.w)	;save new offset
		sub.l	d0,d4		;get number of bytes read
titter		move.l	d4,-(a7)
		movem.l	reg,a0-a6/d0-d7
		move.l	(a7)+,d0	;return #bytes read
		rte

close		clr.l	d0
		move.w	2(a1),d0
		cmp.l	in_use,d0	;closing file currently loaded
		bne.s	lucky
		move.l	#-1,in_use
lucky		move.l d0,d1
		mulu	#60,d0
		lea	f_names,a0
		move.b	#0,(a0,d0.w)
		lsl.l #2,d1
		lea real_hand,a0
		move.l (a0,d1.w),d0
		cmp.l #-1,d0
		beq.s standard
		move.w #1,inside
		move.w d0,-(a7)
		move.w #$3e,-(a7)
		trap #1
		addq.w #4,a7
		clr.w inside
standard	movem.l	reg,a0-a6/d0-d7
		clr.l	d0
		rte

seek		lea	so_read,a2
		lea	f_lengths,a3
		clr.l	d0
		move.w	6(a1),d0	;file handle
		lsl.l	#2,d0
		clr.l	d1
		move.w	8(a1),d1	;type of seek
		move.l	2(a1),d2	;offset

		lea real_hand,a0
		move.l (a0,d0.w),d3
		cmp.l #-1,d3
		beq.s com_seek
		move.w #1,inside
		move.w d1,-(a7)
		move.w d3,-(a7)
		move.l d2,-(a7)
		move.w #$42,-(a7)
		trap #1
		lea 10(a7),a7

		move.l d0,d3
		clr.w inside
		bra com_out

com_seek	tst.w	d1		;type 0?
		bne.s	one_two

;absolute move=type 0

		move.l	d2,d3
		bra.s	same_end
one_two		cmp.w	#1,d1
		bne.s	mustbe2

;type 1=from current place

		move.l	(a2,d0.w),d3
		add.l	d2,d3
		bra.s	same_end
mustbe2		move.l	(a3,d0.w),d3
		sub.l	d2,d3

;type 2=from end

same_end	move.l	(a3,d0.w),d4	;get length
		cmp.l	d3,d4
		bgt.s	ok_so_far	;not past end
		move.l	d4,d3
ok_so_far	cmp.l	#0,d3
		bgt.s	still_ok	;not past start
		clr.l	d3
still_ok	move.l	d3,(a2,d0.w)	;save new offset
com_out		move.l	d3,-(a7)
		movem.l	reg,a0-a6/d0-d7
		move.l	(a7)+,d0	;return new offset
		rte

error		clr.w	inside
		movem.l	reg,a0-a6/d0-d7
		move.l	#-1,d0
		rte	

create		move.w #1,inside
		lea f_names,a0
		add.l #300,a0
		move.l #5,d0
fcl		addq.l #1,d0
		add.l #60,a0
		tst.b (a0)
		bne.s fcl

		move.l d0,d7
		move.l a0,a5
		move.w 6(a1),-(a7)
		move.l 2(a1),-(a7)
		move.w #$3c,-(a7)
		trap #1
		addq.l #8,a7

		tst.w d0
		bmi nwc

		move.b #'i',(a5)
		lea real_hand,a0
		move.l d7,d6
		lsl.l #2,d7
		move.l d0,(a0,d7.w)
		move.l d6,d0
nwc		clr.w inside
		move.l d0,-(a7)
		movem.l reg,a0-a6/d0-d7
		move.l (a7)+,d0
		rte

write		clr.l d0
		move.w 2(a1),d0
		lsl.l #2,d0
		lea real_hand,a0
		move.l (a0,d0.w),d1
		move.w d1,2(a1)
		bra open

ffirst		move.l	2(a1),d0
		move.l	d0,d5		;preserve fname
		move.w	6(a1),d1
		move.w	#1,inside
		move.w	d1,-(a7)
		move.l	d0,-(a7)
		move.w	#$4e,-(a7)
		trap	#1
		addq.l	#8,a7
		tst.w	d0
		bne	exit_route
		move.w	#$2f,-(a7)
		trap	#1
		addq.l	#2,a7
		move.l	d0,d7

		clr.w	-(a7)
		move.l	d5,-(a7)
		move.w	#$3d,-(a7)
		trap	#1
		addq.l	#8,a7

		move.w	d0,d6
		clr.l tmp_read
		pea	tmp_read
		move.l	#8,-(a7)
		move.w	d0,-(a7)
		move.w	#$3f,-(a7)
		trap	#1
		lea	12(a7),a7
		move.w	d6,-(a7)
		move.w	#$3e,-(a7)
		trap	#1
		addq.l	#4,a7
		lea	tmp_read,a0
		cmp.l	#"LSD!",(a0)
		bne.s	doont
		move.l	d7,a1
		move.l	4(a0),26(a1)
doont		clr.l	d0
exit_route	clr.w	inside
		move.l	d0,-(a7)
		movem.l	reg,a0-a6/d0-d7
		move.l	(a7)+,d0
		rte

reg		ds.l	16
tmp_read	ds.l	4
crunpos		dc.l 0

;should now be capable of decoding from odd to odd addresses
;11th October 1989

DEPACK		adda.l #4,a0
		move.w $ff8240,-(sp)
		lea	crunpos(pc),a6
		move.l a0,(a6)		;save crunch position
		move.b (a0)+,d5
		lsl.w 	#8,d5
		move.b	(a0)+,d5
		swap	d5
		move.b	(a0)+,d5
		lsl.w	#8,d5
		move.b	(a0)+,d5
		adda.l d5,a1
		move.b	(a0),d0
		lsl.w	#8,d0
		move.b	1(a0),d0
		swap	d0
		move.b	2(a0),d0
		lsl.w	#8,d0
		move.b	3(a0),d0
		adda.l 	d0,a0
		subq.l #4,a0
		move.b	-2(a0),d0
		lsl.w	#8,d0
		move.b	-1(a0),d0
		subq.l	#2,a0
		tst.w	d0
		bpl.s L_1
		subq.l #1,a0
L_1		move.b -(a0),d0
L_2		lsl.b #1,d0
		bne.s L_3
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
L_3		BCC.S	L_10
		CLR.W	D1
		LSL.B	#1,D0
		BNE.S	L_4
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
L_4		BCC.S	L_9
		LEA	NUMS(PC),A3
		MOVEQ	#3,D3
L_5		CLR.W	D1
		MOVE.B	0(A3,D3.W),D2
		EXT.W	D2
		MOVEQ	#-1,D4
		LSL.W	D2,D4
		NOT.W	D4
		SUBQ.W	#1,D2
L_6		LSL.B	#1,D0
		BNE.S	L_7
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
L_7		ROXL.W	#1,D1
		DBF	D2,L_6
		TST.W	D3
		BEQ.S	L_8
		CMP.W	D1,D4
		DBNE	D3,L_5
L_8		MOVE.B	4(A3,D3.W),D2
		EXT.W	D2
		ADD.W	D2,D1
		BRA	L_9

NUMS		DC.B	$0A,$03,$02,$02,$0E,$07,$04,$01

L_9		MOVE.B	-(A0),-(A1)
		eor.w	#$5,$ff8240
		DBF	D1,L_9
L_10		MOVE.L	crunpos(pc),A3		;get crunch position
		ADDQ.L	#$8,A3
		CMPA.L	A3,A0
		BLE	BYENOW
		LEA	NUMS2(PC),A3
		MOVEQ	#3,D2
L_11		LSL.B	#1,D0
		BNE.S	L_12
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
L_12		BCC.S	L_13
		DBF	D2,L_11
L_13		CLR.W	D1
		ADDQ.W	#1,D2
		MOVE.B	0(A3,D2.W),D3
		BEQ.S	L_16
		EXT.W	D3
		SUBQ.W	#1,D3
L_14		LSL.B	#1,D0
		BNE.S	L_15
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
L_15		ROXL.W	#1,D1
		DBF	D3,L_14
L_16		MOVE.B	5(A3,D2.W),D3
		EXT.W	D3
		ADD.W	D3,D1
		BRA	L_161

NUMS2		DC.B	$0A,$02,$01,$00,$00,$0A,$06,$04,$03,$02

L_161		CMPI.W	#2,D1
		BEQ.S	L_22
		LEA	NUMS3(PC),A3
		MOVEQ	#1,D3
L_17		LSL.B	#1,D0
		BNE.S	L_18
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
L_18		BCC.S	L_19
		DBF	D3,L_17
L_19		ADDQ.W	#1,D3
		CLR.W	D2
		MOVE.B	0(A3,D3.W),D4
		EXT.W	D4
L_20		LSL.B	#1,D0
		BNE.S	L_21
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
L_21		ROXL.W	#1,D2
		DBF	D4,L_20
		LSL.W	#1,D3
		ADD.W	4(A3,D3.W),D2
		BRA.S	L_26

NUMS3		DC.B	$0B,$04,$07,$00,$01,$20,$00,$00
		DC.B	$00,$20,$00,$00

L_22		CLR.W	D2
		MOVEQ	#5,D3
		CLR.W	D4
		LSL.b	#1,D0
		BNE.S	L_23
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
L_23		BCC.S	L_24
		MOVEQ	#8,D3
		MOVEQ	#$40,D4
L_24		LSL.B	#1,D0
		BNE.S	L_25
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
L_25		ROXL.W	#1,D2
		DBF	D3,L_24
		ADD.W	D4,D2
L_26		LEA	0(A1,D2.W),A2
		EXT.L	D1
		ADDA.L	D1,A2
		SUBQ.W	#1,D1
L_27		MOVE.B	-(A2),-(A1)
		DBF	D1,L_27
		BRA	L_2
BYENOW		move.w (a7)+,$ff8240
		RTS
stksav		dc.l 0
in_use		ds.l	1
inside		ds.l	1
buff_add	ds.l	1
whereto		ds.l	1
so_read		dcb.l	0,max_files
f_lengths	dcb.l	0,max_files
f_names		rept	max_files
		dcb.b	0,60
		endr
real_hand	dcb.l 0,max_files
i_buff		ds.l 	1
i_len		ds.l 	1
buff_start	dc.l	0	;start of buffer space

	
