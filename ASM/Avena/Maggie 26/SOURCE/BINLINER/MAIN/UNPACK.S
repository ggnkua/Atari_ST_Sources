; Atomik v3.5 Depacker
try_unpack_file:
	movec	cacr,d0
	move.l	d0,-(a7)
	moveq	#9,d0
	movec	d0,cacr

	move.l	(a0)+,d0
	cmp.l	#"ATM5",d0
	bne.s	._1
	bsr	depack_atomik
._1
	cmp.l	#"FIRE",d0
	bne.s	._2
	subq.l	#4,a0		;go back!
	bsr	depack_fire
._2

	move.l	(a7)+,d0
	movec	d0,cacr
	rts


MODE:   	EQU     1
PIC_ALGO:       EQU     1
DEC_SPACE:      EQU     0      ;MAX IS $7FFE (no odd value!)
RESTORE_SPACE:  EQU     0

depack_atomik:
	movem.l	d0-a6,-(a7)
	link	a2,#-28
	move.l	(a0)+,d0

	ifne	MODE
	;move.l	d0,file_size
	lea	4(a0,d0.l),a5
	move.l	d0,-(a7)
	elseif
	move.l	a1,a5
	add.l	d0,a5
	endc
	move.l	a5,a4
	ifne	MODE
	ifne	DEC_SPACE
	lea	DEC_SPACE(a4),a5
	endc
	endc
	lea	-$c(a4),a4
	move.l	(a0)+,d0
	move.l	a0,a6
	add.l	d0,a6
	ifne	PIC_ALGO
	moveq	#0,d0
	move.b	-(a6),d0
	move	d0,-2(a2)
	ifne	RESTORE_SPACE
	lsl	#2,d0
	sub	d0,a4
	endc
	elseif
	ifne	RESTORE_SPACE
	clr	-2(a2)
	endc
	subq	#1,a6
	endc
	ifne	RESTORE_SPACE
	lea	buff_marg(pc),a3
	move	-2(a2),d0
	lsl	#2,d0
	add	#DEC_SPACE+$C,d0
	bra.s	.save
.save_m:
	move.b	(a4)+,(a3)+
	subq	#1,d0
.save:	bne.s	.save_m
	movem.l	a3-a4,-(a7)
	endc
	ifne	PIC_ALGO
	pea	(a5)
	endc
	move.b	-(a6),d7
	bra	take_type
decrunch:
	move	d3,d5
take_lenght:
	add.b	d7,d7
.cont_take:
	dbcs	d5,take_lenght
	beq.s	.empty1
	bcc.s	.next_cod
	sub	d3,d5
	neg	d5
	bra.s	.do_copy1
.next_cod:
	moveq	#3,d6
	bsr.s	get_bit2
	beq.s	.next_cod1
	bra.s	.do_copy
.next_cod1:
	moveq	#7,d6
	bsr.s	get_bit2
	beq.s	.next_cod2
	add	#15,d5
	bra.s	.do_copy
.empty1:
	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	.cont_take
.next_cod2:
	moveq	#13,d6
	bsr.s	get_bit2
	add	#255+15,d5
.do_copy:
	add	d3,d5
.do_copy1:
	lea	decrun_table(pc),a4
	move	d5,d2
	bne.s	bigger
	add.b	d7,d7
	bne.s	.not_empty
	move.b	-(a6),d7
	addx.b	d7,d7
.not_empty:
	bcs.s	.ho_kesako
	moveq	#1,d6
	bra.s	word
.ho_kesako:
	moveq	#3,d6
	bsr.s	get_bit2
	tst.b	-28(a2)
	beq.s	.ho_kesako1
	move.b	10-28(a2,d5.w),-(a5)
	bra	tst_end
.ho_kesako1:
	move.b	(a5),d0
	btst	#3,d5
	bne.s	.ho_kesako2
	bra.s	.ho_kesako3
.ho_kesako2:
	add.b	#$f0,d5
.ho_kesako3:
	sub.b	d5,d0
	move.b	d0,-(a5)
	bra	tst_end
get_bit2:
	clr	d5
.get_bits:
	add.b	d7,d7
	beq.s	.empty
.cont:	addx	d5,d5
	dbf	d6,.get_bits
	tst	d5
	rts
.empty:	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	.cont
bigger:	moveq	#2,d6
word:	bsr.s	get_bit2
contus:	move	d5,d4
	move.b	14(a4,d4.w),d6
	ext	d6
	tst.b	1-28(a2)
	bne.s	.spe_ofcod1
	addq	#4,d6
	bra.s	.nospe_ofcod1
.spe_ofcod1:
	bsr.s	get_bit2
	move	d5,d1
	lsl	#4,d1
	moveq	#2,d6
	bsr.s	get_bit2
	cmp.b	#7,d5
	blt.s	.take_orof
	moveq	#0,d6
	bsr.s	get_bit2
	beq.s	.its_little
	moveq	#2,d6
	bsr.s	get_bit2
	add	d5,d5
	or	d1,d5
	bra.s	.spe_ofcod2
.its_little:
	or.b	2-28(a2),d1
	bra.s	.spe_ofcod3
.take_orof:
	or.b	3-28(a2,d5.w),d1
.spe_ofcod3:
	move	d1,d5
	bra.s	.spe_ofcod2
.nospe_ofcod1:
	bsr.s	get_bit2
.spe_ofcod2:
	add	d4,d4
	beq.s	.first
	add	-2(a4,d4.w),d5
.first:	lea	1(a5,d5.w),a4
	move.b	-(a4),-(a5)
.copy_same:
	move.b	-(a4),-(a5)
	dbf	d2,.copy_same
	bra.s	tst_end
make_jnk:	add.b	d7,d7
	bne.s	.not_empty
	move.b	-(a6),d7
	addx.b	d7,d7
.not_empty:
	bcs.s	string
	move.b	-(a6),-(a5)
tst_end:
	cmp.l	a5,a3
	bne.s	make_jnk
	cmp.l	a6,a0
	beq.s	work_done
take_type:
	moveq	#0,d6
	bsr	get_bit2
	beq.s	.nospe_ofcod
	move.b	-(a6),d0
	lea	2-28(a2),a1
	move.b	d0,(a1)+
	moveq	#1,d1
	moveq	#6,d2
.next:	cmp.b	d0,d1
	bne.s	.no_off_4b
	addq	#2,d1
.no_off_4b:
	move.b	d1,(a1)+
	addq	#2,d1
	dbf	d2,.next
	st	1-28(a2)
	bra.s	.spe_ofcod
.nospe_ofcod:
	sf	1-28(a2)
.spe_ofcod:
	moveq	#0,d6
	bsr	get_bit2
	beq.s	.relatif
	lea	10-28(a2),a1
	moveq	#15,d0
.next_f:
	move.b	-(a6),(a1)+
	dbf	d0,.next_f
	st	-28(a2)
	bra.s	.freq
.relatif:
	sf	-28(a2)
.freq:	clr	d3
	move.b	-(a6),d3
	move.b	-(a6),d0
	lsl	#8,d0
	move.b	-(a6),d0
	move.l	a5,a3
	sub	d0,a3
	bra.s	make_jnk
string:	bra	decrunch
work_done:
	ifne	PIC_ALGO
	move.l	(a7)+,a0
	pea	(a2)
	bsr.s	decod_picture
	move.l	(a7)+,a2
	endc
	ifne	RESTORE_SPACE
	movem.l	(a7)+,a3-a4
	endc
	ifne	MODE
	move.l	(a7)+,d0
	bsr	copy_decrun
	endc
	ifne	RESTORE_SPACE
	move	-2(a2),d0
	lsl	#2,d0
	add	#DEC_SPACE+$C,d0
	bra.s	.restore
.restore_m:
	move.b	-(a3),-(a4)
	subq	#1,d0
.restore:
	bne.s	.restore_m
	endc
	unlk	a2
not_packed:
	movem.l	(a7)+,d0-a6
	rts
decrun_table:
	dc.w	32,32+64,32+64+256,32+64+256+512,32+64+256+512+1024
	dc.w	32+64+256+512+1024+2048,32+64+256+512+1024+2048+4096
	dc.b	0,1,3,4,5,6,7,8
	ifne	PIC_ALGO
decod_picture:
	move	-2(a2),d7
.next_picture:
	dbf	d7,.decod_algo
	rts
.decod_algo:
	move.l	-(a0),d0
	lea	0(a5,d0.l),a1
.no_odd:
	lea	$7d00(a1),a2
.next_planes:
	moveq	#3,d6
.next_word:
	move	(a1)+,d0
	moveq	#3,d5
.next_bits:	add	d0,d0
	addx	d1,d1
	add	d0,d0
	addx	d2,d2
	add	d0,d0
	addx	d3,d3
	add	d0,d0
	addx	d4,d4
	dbf	d5,.next_bits
	dbf	d6,.next_word
	movem	d1-d4,-8(a1)
	cmp.l	a1,a2
	bne.s	.next_planes
	bra.s	.next_picture
	endc
	ifne	MODE
copy_decrun:
	lsr.l	#4,d0
	lea	-12(a6),a6
.copy_decrun:
	rept	4
	move.l	(a5)+,(a6)+
	endr
	dbf	d0,.copy_decrun
	rts
	endc

	ifne	RESTORE_SPACE
buff_marg:
	dcb.b	$90+DEC_SPACE+$1C
	endc


*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*
depack_fire:
	LINK	A3,#$FF88
	MOVEM.L	A0-A6/D0-D7,-(A7)
	LEA	120(A0),A4
	MOVEA.L	A4,A6
	BSR.B	.t0062
	CMPI.L	#$46495245,D0
	BNE.B	.t0061
	BSR.B	.t0062
	LEA	-8(A0,D0.L),A5
	BSR.B	.t0062
	MOVE.L	D0,(A7)
	;MOVE.L	D0,File_Length

	ADDA.L	D0,A6
	MOVEA.L	A6,A1
	MOVEQ	#$77,D0
.t005A:
	MOVE.B	-(A1),-(A3)
	DBF	D0,.t005A
	MOVEA.L	A6,A3
	MOVE.B	-(A5),D7
	LEA	.t007D(PC),A2
	MOVEQ	#1,D6
	SWAP	D6
	MOVEQ	#0,D5
.t005B:
	BSR.B	.t0064
	BCC.B	.t005E
	MOVEQ	#0,D1
	BSR.B	.t0064
	BCC.B	.t005D
	MOVEA.L	A2,A0
	MOVEQ	#3,D3
.t005C:
	MOVE.L	-(A0),D0
	BSR.B	.t0066
	SWAP	D0
	CMP.W	D0,D1
	DBNE	D3,.t005C
	ADD.L	16(A0),D1
.t005D:
	MOVE.B	-(A5),-(A6)
	DBF	D1,.t005D
.t005E:
	CMPA.L	A4,A6
	BGT.B	.t006A
	MOVEM.L	(A7),A5/A0-A2/D0-D7
.t005F:
	MOVE.B	(A4)+,(A0)+
	SUBQ.L	#1,D0
	BNE.B	.t005F
	MOVEQ	#$77,D0
.t0060:
	MOVE.B	-(A5),-(A3)
	DBF	D0,.t0060
.t0061:
	MOVEM.L	(A7)+,A0-A6/D0-D7
	UNLK	A3
	RTS
.t0062:
	MOVEQ	#3,D1
.t0063:
	ROL.L	#8,D0
	MOVE.B	(A0)+,D0
	DBF	D1,.t0063
	RTS
.t0064:
	ADD.B	D7,D7
	BEQ.B	.t0065
	RTS
.t0065:
	MOVE.B	-(A5),D7
	ADDX.B	D7,D7
	RTS
.t0066:
	MOVEQ	#0,D1
.t0067:
	ADD.B	D7,D7
	BEQ.B	.t0069
.t0068:
	ADDX.W	D1,D1
	DBF	D0,.t0067
	RTS
.t0069:
	MOVE.B	-(A5),D7
	ADDX.B	D7,D7
	BRA.B	.t0068
.t006A:
	MOVEQ	#1,D0
	BSR.B	.t0066
	SUBQ.W	#1,D1
	BMI.B	.t006E
	BEQ.B	.t0070
	SUBQ.W	#1,D1
	BEQ.B	.t0071
	BSR.B	.t0064
	BCC.B	.t006F
	BSR.B	.t0064
	BCC.B	.t0072
	BRA.B	.t0073
.t006B:
	MOVEQ	#1,D0
	BSR.B	.t0066
	SUBQ.W	#1,D1
	BPL.B	.t006D
	MOVEQ	#0,D0
	RTS
.t006C:
	MOVEQ	#1,D0
	BSR.B	.t0066
.t006D:
	ADD.W	D1,D1
	ADD.W	D1,D1
	MOVEM.W	16(A2,D1.W),D5/D0
	BSR.B	.t0066
	ADD.L	D5,D1
	RTS
.t006E:
	MOVEQ	#1,D0
	BSR.B	.t0066
	SUBQ.W	#1,D1
	BMI.B	.t0077
	ADD.W	D1,D1
	ADD.W	D1,D1
	MOVEM.W	32(A2,D1.W),D2/D0
	BSR.B	.t0066
	ADD.W	D1,D2
	BSR.B	.t006C
	MOVE.W	D2,D0
	BRA.B	.t0079
.t006F:
	MOVEQ	#2,D0
	BSR.B	.t0066
	MOVEQ	#0,D0
	BSET	D1,D0
	BRA.B	.t0076
.t0070:
	MOVEQ	#7,D0
	BSR.B	.t0066
	MOVEQ	#0,D0
	BRA.B	.t007A
.t0071:
	BSR.B	.t006B
	TST.W	D0
	BEQ.B	.t0076
	MOVEQ	#1,D0
	BRA.B	.t007A
.t0072:
	BSR.B	.t006B
	TST.W	D0
	BEQ.B	.t0075
	MOVEQ	#2,D0
	BRA.B	.t007A
.t0073:
	BSR.B	.t006B
	TST.W	D0
	BEQ.B	.t0074
	MOVEQ	#3,D0
	BRA.B	.t007A
.t0074:
	MOVEQ	#$FF,D0
	BRA.B	.t0076
.t0075:
	MOVE.B	(A6),D0
.t0076:
	MOVE.B	D0,-(A6)
	BRA.B	.t007C
.t0077:
	BSR.B	.t006C
	BEQ.B	.t007C
	MOVE.B	(A6),D0
.t0078:
	MOVE.B	D0,-(A6)
	DBF	D1,.t0078
	SUB.L	D6,D1
	BMI.B	.t007C
	BRA.B	.t0078
.t0079:
	SUBQ.W	#2,D0
.t007A:
	LEA	2(A6,D1.L),A0
	ADDA.W	D0,A0
	MOVE.B	-(A0),-(A6)
.t007B:
	MOVE.B	-(A0),-(A6)
	DBF	D0,.t007B
.t007C:
	BRA	.t005B
	DC.B	$03,$FF,$00,$09,$00,$07,$00,$02
	DC.B	$00,$03,$00,$01,$00,$03,$00,$01
.t007D:
	DC.B	$00,$00,$00,$0E,$00,$00,$00,$07
	DC.B	$00,$00,$00,$04,$00,$00,$00,$01
	DC.B	$00,$03,$00,$00,$00,$07,$00,$10
	DC.B	$00,$0B,$01,$10,$00,$0F,$11,$10
	DC.B	$00,$03,$00,$05,$00,$05,$00,$15
	DC.B	$00,$07,$00,'U'
	even
