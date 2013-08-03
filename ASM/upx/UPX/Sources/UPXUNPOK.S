;UPX unpack routine (NRV2B only!) (--best)
;==================
;
;Usage:		a0 = start of data
;Return:	d0 = length of unpacked data
;
;Associated files:	Make_prg.s	Make a "program" out of data-file
;					-> Data can be packed with PC UPX
;
;			Ripupx.s	Takes out "unnecessary" part out of
;					datafiles, works only with UPX v.1.24
;
;			Unp_test.s	A test program for finding out a
;					suitable decrunch space (usually $2e)
;
;Compared to other existing Atari ST packers; Atomik, Pack-Ice, Pack-Fire,
;Jam Pack, PP Packer, Automation packer, Speedpacker 3 etc., UPX v.1.24
;offers better compression and much faster decompression.
;
;UPX v.1.24 doesn't work well with the files smaller than 1024 bytes,
;usually they are left unpacked. 
;
;This source alongside the associated files can be distributed under the
;terms of GNU General Public License.
;
;And just as the UPX, this source and the associated sources and their
;binaries comes with ABSOLUTELY NO WARRANTY. So better make those backups!  
;
;More info about UPX:	http://upx.sourceforge.net
;

dec_space	EQU	$2e		;at least $2e, no odd values!

do_upx
	movem.l	d0-a6,-(sp)
	cmp.l	#"UPX!",(a0)
	bne	no_upx
	move.l	8(a0),(sp)
	sub.l	#$1c,(sp)
	move.l	$c(a0),d0

	bsr	bit_test

	lea	$20(a0,d0.l),a1
	move.l	$8(a0),d1
	moveq	#0,d4

	add.l	d1,A0
	
	lea	dec_space-$1c(a0),a0	;-extra-space for decrunch!

	bsr	set_copy

	move.l	a0,a5
copy_bit
	move.b	-(a5),-(a4)
	cmp.l	a4,a3
	bne.s	copy_bit
	move.l	a0,a2
	sub.l	d0,a2
loop_more
	move.b	-(a1),-(a0)
	cmp.l	a0,a2
	bne.s	loop_more

	LEA	-$20(A1),A1
	MOVEQ	#-1,D7
	MOVEQ	#-$80,D0
	MOVEQ	#-$68,D6
	MOVEQ	#-1,D5
	LSL.W	#5,D6
	BRA.S	L33EE8
L33EE6	MOVE.B	(A0)+,(A1)+
L33EE8	ADD.B	D0,D0
	BCC.S	L33EF4
	BNE.S	L33EE6
	MOVE.B	(A0)+,D0
	ADDX.B	D0,D0
	BCS.S	L33EE6
L33EF4	MOVEQ	#1,D1
	MOVEQ	#0,D2
L33EF8	ADD.B	D0,D0
	BNE.S	L33F00
	MOVE.B	(A0)+,D0
	ADDX.B	D0,D0
L33F00	ADDX.L	D1,D1
	ADD.B	D0,D0
	BCC.S	L33EF8
	BNE.S	L33F0E
	MOVE.B	(A0)+,D0
	ADDX.B	D0,D0
	BCC.S	L33EF8
L33F0E	SUBQ.L	#3,D1
	BCS.S	L33F1C
	LSL.L	#8,D1
	MOVE.B	(A0)+,D1
	NOT.L	D1
	BEQ.S	L33F62
	MOVE.L	D1,D5
L33F1C	ADD.B	D0,D0
	BNE.S	L33F24
	MOVE.B	(A0)+,D0
	ADDX.B	D0,D0
L33F24	ADDX.W	D2,D2
	ADD.B	D0,D0
	BNE.S	L33F2E
	MOVE.B	(A0)+,D0
	ADDX.B	D0,D0
L33F2E	ADDX.W	D2,D2
	TST.W	D2
	BNE.S	L33F4E
	ADDQ.W	#1,D2
L33F36	ADD.B	D0,D0
	BNE.S	L33F3E
	MOVE.B	(A0)+,D0
	ADDX.B	D0,D0
L33F3E	ADDX.W	D2,D2
	ADD.B	D0,D0
	BCC.S	L33F36
	BNE.S	L33F4C
	MOVE.B	(A0)+,D0
	ADDX.B	D0,D0
	BCC.S	L33F36
L33F4C	ADDQ.W	#2,D2
L33F4E	LEA	0(A1,D5.L),A3
	MOVE.L	D5,D1
	SUB.L	D6,D1
	ADDX.W	D7,D2
	MOVE.B	(A3)+,(A1)+
L33F5A	MOVE.B	(A3)+,(A1)+
	DBF	D2,L33F5A
	BRA.S	L33EE8

L33F62	
	bsr.s	set_copy

	move.l	a0,d0
	bsr.s	bit_test	
	move.l	d0,a0
loopix2
	move.b	-(a4),-(a0)
	cmp.l	a3,a4
	bne.s	loopix2

no_upx
	movem.l	(sp)+,d0-a6
	rts
set_copy	
	lea	store(pc),a3
	lea	dec_space(a3),a4
	rts

bit_test
	btst	#0,d0
	beq.s	equal
	addq.l	#1,d0
equal	rts

store
	ds.b	dec_space

