;-------------------------------------------------------------------------
; Various Decrunch routines.

; Power packer Decrunch
;-- a0 = Pointer to longword AFTER crunched file
;-- a3 = Pointer to destination
;-- a5 = Pointer to 'efficiency' longword, which is the second
;        longword in the crunched data file.

PP_Decrunch:	LEA $FFFF8242.W,A6
		MOVE.W (A6),-(SP)
		BSR ppdec
		MOVE.W (SP)+,(A6)
		RTS

ppdec		moveq #3,d6
		moveq #7,d7
		moveq #1,d5
		move.l a3,a2			; remember start of file
		move.l -(a0),d1			; get file length and empty bits
		tst.b d1
		beq.s NoEmptyBits
		bsr.s ReadBit			; this will always get the next long (D5 = 1)
		subq.b #1,d1
		lsr.l d1,d5			; get rid of empty bits
NoEmptyBits:	lsr.l #8,d1
		add.l d1,a3			; a3 = endfile
LoopCheckCrunch: move.w d1,(A6)
		bsr.s ReadBit			; check if crunch or normal
		bcs.s CrunchedBytes
NormalBytes:	moveq #0,d2
Read2BitsRow:	moveq #1,d0
		bsr.s ReadD1
		add.w d1,d2
		cmp.w d6,d1
		beq.s Read2BitsRow
ReadNormalByte:	moveq #7,d0
		bsr.s ReadD1
		move.b d1,-(a3)
		dbf d2,ReadNormalByte
		cmp.l a3,a2
		bcs.s CrunchedBytes
		rts
ReadBit:	lsr.l #1,d5			; this will also set X if d5 becomes zero
		beq.s GetNextLong
		rts
GetNextLong:	move.l -(a0),d5
		roxr.l #1,d5			; X-bit set by lsr above
		rts
ReadD1sub:	subq.w #1,d0
ReadD1:		moveq #0,d1
ReadBits:	lsr.l #1,d5			; this will also set X if d5 becomes zero
		beq.s GetNext
RotX:		roxl.l #1,d1
		dbf d0,ReadBits
		rts
GetNext:	move.l -(a0),d5
		roxr.l #1,d5			; X-bit set by lsr above
		bra.s RotX
CrunchedBytes:	moveq #1,d0
		bsr.s ReadD1			; read code
		moveq #0,d0
		move.b 0(a5,d1.w),d0		; get number of bits of offset
		move.w d1,d2			; d2 = code = length-2
		cmp.w d6,d2			; if d2 = 3 check offset bit and read length
		bne.s ReadOffset
		bsr.s ReadBit			; read offset bit (long/short)
		bcs.s LongBlockOffset
		moveq #7,d0
LongBlockOffset: bsr.s ReadD1sub
		move.w d1,d3			; d3 = offset
Read3BitsRow:	moveq #2,d0
		bsr.s ReadD1
		add.w d1,d2			; d2 = length-1
		cmp.w d7,d1			; cmp with #7
		beq.s Read3BitsRow
		bra.s DecrunchBlock
ReadOffset:	bsr.s ReadD1sub			; read offset
		move.w d1,d3			; d3 = offset
DecrunchBlock:	addq.w #1,d2
DecrunchBlockLoop:
		move.b 0(a3,d3.w),-(a3)
		dbf d2,DecrunchBlockLoop
EndOfLoop:	cmp.l a3,a2
		bcs.s LoopCheckCrunch
		rts

; ATOMIK DECRUNCH SOURCE CODE v3.5 
; a0 -> Packed file.

MODE:		EQU	1
PIC_ALGO:	EQU	0
DEC_SPACE:	EQU	$80	 ;MAX IS $7FFE (no odd value!)
RESTORE_SPACE:	EQU	0

atom35depack	movem.l	d0-a6,-(a7)
		cmp.l	#"ATM5",(a0)+
		bne	not_packed
		link	a2,#-28
		move.l	(a0)+,d0
		ifne	MODE
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
.save_m:	move.b	(a4)+,(a3)+
		subq	#1,d0
.save:		bne.s	.save_m
		movem.l	a3-a4,-(a7)
		endc
		ifne	PIC_ALGO
		pea	(a5)
		endc
		move.b	-(a6),d7
		bra	take_type
decrunch:	move	d3,d5
take_lenght:	add.b	d7,d7
.cont_take:	dbcs	d5,take_lenght
		beq.s	.empty1
		bcc.s	.next_cod
		sub	d3,d5
		neg	d5
		bra.s	.do_copy1
.next_cod:	moveq	#3,d6
		bsr.s	get_bit2
		beq.s	.next_cod1
		bra.s	.do_copy
.next_cod1:	moveq	#7,d6
		bsr.s	get_bit2
		beq.s	.next_cod2
		add	#15,d5
		bra.s	.do_copy
.empty1:	move.b	-(a6),d7
		addx.b	d7,d7
		bra.s	.cont_take
.next_cod2:	moveq	#13,d6
		bsr.s	get_bit2
		add	#255+15,d5
.do_copy:	add	d3,d5
.do_copy1:	lea	decrun_table(pc),a4
		move	d5,d2
		bne.s	bigger
		add.b	d7,d7
		bne.s	.not_empty
		move.b	-(a6),d7
		addx.b	d7,d7
.not_empty:	bcs.s	.ho_kesako
		moveq	#1,d6
		bra.s	word
.ho_kesako:	moveq	#3,d6
		bsr.s	get_bit2
		tst.b	-28(a2)
		beq.s	.ho_kesako1
		move.b	10-28(a2,d5.w),-(a5)
		bra	tst_end
.ho_kesako1:	move.b	(a5),d0
		btst	#3,d5
		bne.s	.ho_kesako2
		bra.s	.ho_kesako3
.ho_kesako2:	add.b	#$f0,d5
.ho_kesako3:	sub.b	d5,d0
		move.b	d0,-(a5)
		bra	tst_end
get_bit2:	clr	d5
.get_bits:	add.b	d7,d7
		beq.s	.empty
.cont:		addx	d5,d5
		dbf	d6,.get_bits
		tst	d5
		rts
.empty:		move.b	-(a6),d7
		addx.b	d7,d7
		bra.s	.cont
bigger:		moveq	#2,d6
word:		bsr.s	get_bit2
contus:		move	d5,d4
		move.b	14(a4,d4.w),d6
		ext	d6
		tst.b	1-28(a2)
		bne.s	.spe_ofcod1
		addq	#4,d6
		bra.s	.nospe_ofcod1
.spe_ofcod1:	bsr.s	get_bit2
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
.its_little:	or.b	2-28(a2),d1
		bra.s	.spe_ofcod3
.take_orof:	or.b	3-28(a2,d5.w),d1
.spe_ofcod3:	move	d1,d5
		bra.s	.spe_ofcod2
.nospe_ofcod1:	bsr.s	get_bit2
.spe_ofcod2:	add	d4,d4
		beq.s	.first
		add	-2(a4,d4.w),d5
.first:		lea	1(a5,d5.w),a4
		move.b	-(a4),-(a5)
.copy_same:	move.b	-(a4),-(a5)
		dbf	d2,.copy_same
		bra.s	tst_end
make_jnk:	add.b	d7,d7
		bne.s	.not_empty
		move.b	-(a6),d7
		addx.b	d7,d7
.not_empty:	bcs.s	string
		move.b	-(a6),-(a5)
tst_end:	cmp.l	a5,a3
		bne.s	make_jnk
		cmp.l	a6,a0
		beq.s	work_done
take_type:	moveq	#0,d6
		bsr	get_bit2
		beq.s	.nospe_ofcod
		move.b	-(a6),d0
		lea	2-28(a2),a1
		move.b	d0,(a1)+
		moveq	#1,d1
		moveq	#6,d2
.next:		cmp.b	d0,d1
		bne.s	.no_off_4b
		addq	#2,d1
.no_off_4b:	move.b	d1,(a1)+
		addq	#2,d1
		dbf	d2,.next
		st	1-28(a2)
		bra.s	.spe_ofcod
.nospe_ofcod:	sf	1-28(a2)
.spe_ofcod:	moveq	#0,d6
		bsr	get_bit2
		beq.s	.relatif
		lea	10-28(a2),a1
		moveq	#15,d0
.next_f:	move.b	-(a6),(a1)+
		dbf	d0,.next_f
		st	-28(a2)
		bra.s	.freq
.relatif:	sf	-28(a2)
.freq:		clr	d3
		move.b	-(a6),d3
		move.b	-(a6),d0
		lsl	#8,d0
		move.b	-(a6),d0
		move.l	a5,a3
		sub	d0,a3
		bra.s	make_jnk
string:		bra	decrunch
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
.restore_m:	move.b	-(a3),-(a4)
		subq	#1,d0
.restore:	bne.s	.restore_m
		endc
		unlk	a2
not_packed:	movem.l	(a7)+,d0-a6
	 	rts
decrun_table:	dc.w	32,32+64,32+64+256,32+64+256+512,32+64+256+512+1024
		dc.w	32+64+256+512+1024+2048,32+64+256+512+1024+2048+4096
		dc.b	0,1,3,4,5,6,7,8
		ifne	PIC_ALGO
decod_picture:	move	-2(a2),d7
.next_picture:	dbf	d7,.decod_algo
		rts
.decod_algo:	move.l	-(a0),d0
		lea	0(a5,d0.l),a1
.no_odd:	lea	$7d00(a1),a2
.next_planes:	moveq	#3,d6
.next_word:	move	(a1)+,d0
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
copy_decrun:	lsr.l	#4,d0
		lea	-12(a6),a6
.copy_decrun:	
		rept	4
		move.l	(a5)+,(a6)+
		endr
		dbf	d0,.copy_decrun
		rts
		endc
		ifne	RESTORE_SPACE
buff_marg:	dcb.b	$90+DEC_SPACE+$C
		endc

; End of Atomik v3.5 depack

;LZW Depack routine for the JAM packer V4.0
;It is kept simple to minimise depack time.
; a0-> Start of packed file
; a1->   End of packed file

LZW_UNPACK:
	MOVE.W	$FFFF8242.W,-(A7)
	MOVE.L	A0,A4
	MOVE.L	A1,A6
	ADDA.L	8(A0),A4
	ADDA.L	4(A0),A6
	MOVE.L	A6,A5			;KEEP COPY TO CHECK AGAINST
	MOVE.L	4(A0),D4
	MOVE.B	#$20,D3

	MOVE.W	#$0FED,D5
	MOVEA.L A6,A3			;KEEP ADDR OF END OF SPACES

	MOVEQ	#$00,D7			;START UNPACK ROUTINE
TOPDEP:	DBF	D7,NOTUSED
	MOVE.B	-(A4),D6		;GET COMMAND BYTE
	MOVEQ	#$07,D7
NOTUSED:
	LSR.B	#1,D6
	BCC.S	COPY			;BIT NOT SET, COPY FROM UNPACKED AREA 
	MOVE.B	-(A4),-(A6)		;COPY BYTES FROM PACKED AREA
	ADDQ.W	#1,D5
	SUBQ.L	#1,D4
	BGT.S	TOPDEP
	BRA.S	EXITUP
COPY:	MOVE.B	-2(A4),D0
	LSL.W	#4,D0
	MOVE.B	-(A4),D0
	MOVE.W	D0,$FFFF8242.W
	SUB.W	D5,D0
	NEG.W	D0
	AND.W	#$0FFF,D0
	LEA	1(A6,D0.W),A0
	MOVEQ	#$0F,D1
	AND.B	-(A4),D1
	ADDQ.W	#2,D1
	MOVEQ	#$01,D0
	ADD.W	D1,D0
	CMPA.L	A5,A0
	BGT.S	SPACES
	
WRITE:	MOVE.B	-(A0),-(A6)
	DBF	D1,WRITE
BACK:	ADD.L	D0,D5
	SUB.L	D0,D4
	BGT.S	TOPDEP
EXITUP:	MOVE.W	(A7)+,$FFFF8242.W
	RTS

SPACES: CMPA.L	A5,A0
	BLE.S	WRITE
	MOVE.B	D3,-(A6)		;COPY OUT SPACES
	SUBQ.L	#1,A0
	DBF	D1,SPACES
	BRA.S	BACK

; end of LZW depack

; Automation 501 Depacker	
; A0 -> Packed files

AU5_decrunch_2:
	link	a3,#-120
	movem.l	d0-a6,-(sp)
	lea	120(a0),a4	
	move.l	a4,a6		
	bsr.s	.getinfo
	cmpi.l	#'AU5!',d0	
	bne	.not_packed
	bsr.s	.getinfo	
	lea.l	-8(a0,d0.l),a5	
	bsr.s	.getinfo	
	move.l	d0,(sp)		
	adda.l	d0,a6		
	move.l	a6,a1

	moveq	#119,d0		
.save:	move.b	-(a1),-(a3)	
	dbf	d0,.save
	move.l	a6,a3		
	move.b	-(a5),d7	
	bsr.s	.normal_bytes
	move.l	a3,a5		

	bsr.s	.get_1_bit	
	bcc.s	.no_picture	
	move.w	#$0f9f,d7 	
.AU5_00:
	moveq	#3,d6	
.AU5_01:
	move.w	-(a3),d4
	moveq	#3,d5		
.AU5_02:
	add.w	d4,d4	
	addx.w	d0,d0		
	add.w	d4,d4		
	addx.w	d1,d1		
	add.w	d4,d4		
	addx.w	d2,d2		
	add.w	d4,d4		
	addx.w	d3,d3		
	dbra	d5,.AU5_02	
	dbra	d6,.AU5_01	
	movem.w	d0-d3,(a3)	
	dbra	d7,.AU5_00	
.no_picture
	movem.l	(sp),d0-a3	

.move	move.b	(a4)+,(a0)+
	subq.l	#1,d0
	bne.s	.move
	moveq	#119,d0		
.rest	move.b	-(a3),-(a5)	
	dbf	d0,.rest
.not_packed:
	movem.l	(sp)+,d0-a6
	unlk	a3
	rts
.getinfo: 
	moveq	#3,d1		
.getbytes:
	lsl.l	#8,d0	
	move.b	(a0)+,d0
	dbf	d1,.getbytes
	rts
.normal_bytes:	
	bsr.s	.get_1_bit
	bcc.s	.test_if_end	
	moveq.l	#0,d1		
	bsr.s	.get_1_bit
	bcc.s	.copy_direkt	
	lea.l	.direkt_tab+20(pc),a1
	moveq.l	#4,d3
.nextgb:
	move.l	-(a1),d0
	bsr.s	.get_d0_bits
	swap.w	d0
	cmp.w	d0,d1		
	dbne	d3,.nextgb	
.no_more: 
	add.l	20(a1),d1 	
.copy_direkt:	
	move.b	-(a5),-(a6)	
	dbf	d1,.copy_direkt	
.test_if_end:	
	cmpa.l	a4,a6		
	bgt.s	.strings	
	rts	

.get_1_bit:
	add.b	d7,d7		
	bne.s	.bitfound 	
	move.b	-(a5),d7	
	addx.b	d7,d7
.bitfound:
	rts	

.get_d0_bits:	
	moveq.l	#0,d1		
.hole_bit_loop:	
	add.b	d7,d7		
	bne.s	.on_d0		
	move.b	-(a5),d7	
	addx.b	d7,d7
.on_d0:	addx.w	d1,d1		
	dbf	d0,.hole_bit_loop	
	rts	

.strings: 
	lea.l	.length_tab(pc),a1	
	moveq.l	#3,d2		
.get_length_bit:	
	bsr.s	.get_1_bit
	dbcc	d2,.get_length_bit
.no_length_bit:	
	moveq.l	#0,d4		
	moveq.l	#0,d1
	move.b	1(a1,d2.w),d0	
	ext.w	d0		
	bmi.s	.no_Åber	
.get_Åber:
	bsr.s	.get_d0_bits
.no_Åber:
	move.b	6(a1,d2.w),d4
	add.w	d1,d4	
	beq.s	.get_offset_2	

	lea.l	.more_offset(pc),a1 
	moveq.l	#1,d2
.getoffs: 
	bsr.s	.get_1_bit
	dbcc	d2,.getoffs
	moveq.l	#0,d1		
	move.b	1(a1,d2.w),d0	
	ext.w	d0		
	bsr.s	.get_d0_bits
	add.w	d2,d2		
	add.w	6(a1,d2.w),d1	
	bpl.s	.depack_bytes	
	sub.w	d4,d1		
	bra.s	.depack_bytes


.get_offset_2:	
	moveq.l	#0,d1		
	moveq.l	#5,d0		
	moveq.l	#-1,d2		
	bsr.s	.get_1_bit
	bcc.s	.less_40	
	moveq.l	#8,d0		
	moveq.l	#$3f,d2		
.less_40: 
	bsr.s	.get_d0_bits
	add.w	d2,d1		

.depack_bytes:			
	lea.l	2(a6,d4.w),a1	
	adda.w	d1,a1		
	move.b	-(a1),-(a6)	
.dep_b:	move.b	-(a1),-(a6)	
	dbf	d4,.dep_b 	
	bra	.normal_bytes	


.direkt_tab:
	dc.l $7fff000e,$00ff0007,$00070002,$00030001,$00030001	
	dc.l 270-1,15-1,8-1,5-1,2-1	

.length_tab:
	dc.b 9,1,0,-1,-1	
	dc.b 8,4,2,1,0		

.more_offset:
	dc.b	  11,   4,   7,  0	
	dc.w	$11f,  -1, $1f	

ende_AU5_decrunch_2:

; end of automation depack

;-------------------------------------------------------------------------
