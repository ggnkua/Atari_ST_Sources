* File-depacker
* by James Ingram, 1994
* will intercept packed files + allow them to be read
* as per normal (memory permitting)

* handles:-
*	SPEED
*	ICE 2.4
*	LZH


	opt	o+,ow-

	include	macros.s

print	macro
	lea	\1(pc),a0
	bsr	print_mes
	endm


	print	intro

* am I resident?
	move.l	#"TEST",-(a7)
	move.l	#"INTE",-(a7)
	trap	#1
	addq.l	#8,a7
	cmp.l	#"CEPT",d0
	bne	not_resident

* yup!
	print	question
wait:
	move.w	#7,-(a7)
	trap	#1
	addq.l	#2,a7

	cmp.b	#"1",d0
	blt.s	wait

	cmp.b	#"3",d0
	bgt.s	wait

	cmp.b	#"1",d0
	beq	turn_off

	cmp.b	#"2",d0
	beq	turn_on

term:
	clr.w	-(a7)
	trap	#1

turn_off:
	move.l	#" OFF",-(a7)
	move.l	#"INTE",-(a7)
	trap	#1
	addq.l	#8,a7
	bra	term

turn_on:
	move.l	#"  ON",-(a7)
	move.l	#"INTE",-(a7)
	trap	#1
	addq.l	#8,a7
	bra	term

not_resident:
	move.l	4(a7),a5
	move.l	$c(a5),a6
	add.l	$14(a5),a6
	add.l	$1c(a5),a6
	lea	$100(a6),a6

	super_on
	move.l	$84,old_trap1
	move.l	#my_trap1,$84.w
	super_off

	clr.w	-(a7)
	pea	(a6)
	move.w	#$31,-(a7)
	trap	#1


print_mes:
	pea	(a0)
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	rts

my_trap1:
* here is where I intercept the TRAP calls...

	tst.w	skipping
	bne	skip

	st	skipping
	movem.l	d1-7/a0-6,variables

	lea	6(a7),a0
	btst	#5,(a7)
	bne.s	.super
	move.l	usp,a0
.super:
* keep addr of stack stuff
	move.l	a0,stack_addr

	cmp.l	#"INTE",(a0)
	beq	call_to_me

	cmp.b	#"y",off
	beq	do_nothing

* is this a call I need to intercept???
b	macro
	cmp.w	#$\1,(a0)
	beq	\2
	endm


	b	3d,open
	b	3e,close
	b	3f,read
	b	40,write
	b	42,lseek
	b	4e,sfirst
	b	4f,snext

* not a call I need to do anything about...
do_nothing:
	clr.w	skipping

	movem.l	variables,d1-7/a0-6
skip:
	move.l	old_trap1,a0
	jmp	(a0)


call_to_me:
	move.l	4(a0),d0
	cmp.l	#"TEST",d0
	bne.s	.not_test

	move.l	#"CEPT",d0
	bra	return

.not_test:
	cmp.l	#" OFF",d0
	bne.s	.not_off

	move.b	#"y",off
	bra	return

.not_off:
	cmp.l	#"  ON",d0
	bne.s	.not_on

	move.b	#"n",off
	bra	return

.not_on:
	bra	return


write:
* cannot wrtie to file if it's one of mine!
	moveq	#0,d7
	move.w	2(a0),d7
	bsr	get_hand

	tst.l	(a6)
	beq	do_nothing

* it's one of mine!
* I cannot write to it!
	moveq	#-13,d0
	bra	return

lseek:
	moveq	#0,d7
	move.w	6(a0),d7
	bsr	get_hand
	tst.l	(a6)
	beq	do_nothing

* lseeking one of my files!
	move.l	2(a0),d6	; get length
	move.w	8(a0),d0	; get type!
	dbra	d0,.not_from_start

* from start of file...
	move.l	d6,d0
	bra	.dun_move

.not_from_start:
	dbra	d0,.not_rel

* relative...
	move.l	8(a6),d1	; get current offset
	add.l	d1,d0		; get file pointer
	bra	.dun_move

.not_rel:
* from end...
	move.l	4(a6),d1	; get file length
	sub.l	d0,d1		; back from end
	move.l	d1,d0		; keep value

.dun_move:
* check valid value
	tst.l	d0
	bpl.s	.ok

	moveq	#0,d0
.ok:
	move.l	4(a6),d1
	sub.l	d0,d1
	bpl.s	.ok2		; branch if not past end of file

	move.l	4(a6),d0
.ok2:
	move.l	d0,8(a6)	; keep new offset
	bra	return


sfirst:
* do the search...
	move.w	6(a0),-(a7)
	move.l	2(a0),-(a7)
	move.w	(a0),-(a7)
	trap	#1
	addq.l	#2,a7
	move.l	(a7)+,a4	; get original search path & name...
	addq.l	#2,a7

search_rej:
* did I find a file?
	tst.w	d0
	bne	return		; return if no file found

* test to see if CONTROL is pressed...
	move.l	d0,return_value
	bsr	test_control
	tst.w	d0
	beq.s	.ctrl

* control pressed! assume unpacked!
	move.l	return_value,d0
	bra	return

.ctrl:


* a file was found!
* where's the dta?
	move.w	#$2f,-(a7)
	trap	#1
	addq.l	#2,a7

	move.l	d0,a5

* it may not be in the current directory (eg it may be in "C:\*.*" and we are in "C:\DEGELITE\")
* so work out the complete pathname
	lea	path(pc),a0

* copy the original search pattern
.copy:
	move.b	(a4)+,(a0)+
	bne.s	.copy

* now search backwards until we reach "\" or a 0
	subq.l	#1,a0

.look:
	move.b	-(a0),d0
	beq.s	.end_name

	cmp.b	#"\",d0
	beq.s	.end_name

	cmp.b	#":",d0
	bne.s	.look

.end_name:
* found the "\" or the ":" or the start of the name
* so write OVER the name with the contents of the dta...

	lea	30(a5),a1
	addq.l	#1,a0

.copy2:
	move.b	(a1)+,(a0)+
	bne.s	.copy2


* is it a folder or a disk label?
	move.b	21(a5),d0
	and.b	#$18,d0

* If either of these bits is set, I don't want to know!
	beq.s	.ok

	moveq	#0,d0
	bra	return

.ok:
* we got a file, boys!

* does it have a compression flag????

* open it!
	clr.w	-(a7)
	pea	path(pc)
	move.w	#$3d,-(a7)
	trap	#1
	addq.l	#8,a7

	moveq	#0,d7
	move.w	d0,d7

	bsr	read_flag

* close the file
	move.w	d7,-(a7)
	move.w	#$3e,-(a7)
	trap	#1
	addq.l	#4,a7

* is it a packed file???
	bsr	check_packed
	tst.l	d0
	beq.s	.yup

* file found, but not packed!
	moveq	#0,d0
	bra	return

.yup:
* file IS packed...

	lea	offs(pc),a1
	move.l	(a1,d5.w),d1	; get offset of length in file...

	lea	flag(pc),a0
	add.l	d1,a0

	move.l	(a0),26(a5)	; store REAL length of file!
	moveq	#0,d0
	bra	return


snext:
* do the search
	move.w	(a0),-(a7)
	trap	#1
	addq.l	#2,a7

	lea	path(pc),a4	; pretend that the last file found was the original pathname...
	bra	search_rej



open:
* it's trying to OPEN a file! Can't have this! I want to have a nose around too...

	move.w	6(a0),-(a7)
	move.l	2(a0),-(a7)
	move.w	(a0),-(a7)
	trap	#1
	addq.l	#8,a7

* d0 now holds the handle or error code we got back
	tst.w	d0
	bpl.s	.ok

* file error!
* so just return control to program calling me...
	bra	return


.ok:
* a file was opened!!!
* keep the handle safe...
	move.l	d0,return_value

* test to see if CONTROL is pressed...
	bsr	test_control
	tst.w	d0
	beq.s	.ctrl

* control pressed! assume unpacked!
	move.l	return_value,d0
	bra	return

.ctrl:
	move.l	return_value,d0

* now, read the first 4 bytes of the file...

	bsr	read_flag

* is it a packed file???
* check the list
	bsr	check_packed
	tst.l	d0
	bmi	not_packed

	lea	files(pc),a6
	moveq	#0,d0
	move.w	d7,d0
	mulu	#16,d0
	add.l	d0,a6
	move.l	(a1),(a6)	; keep flag

* get details of length offset
	lea	offs(pc),a1
	move.l	(a1,d5.w),d1	; get offset of length in file...

	lea	flag(pc),a0
	add.l	d1,a0
	move.l	(a0),4(a6)	; get original length of file
	clr.l	8(a6)		; we are at the start...

* reserve the memory I require...
	move.l	4(a6),-(a7)
	move.w	#$48,-(a7)
	trap	#1
	addq.l	#6,a7
	tst.l	d0
	bmi.s	.mem_err
	bne.s	.mem_ok

.mem_err:
* error with reserving memory!
* so I return to program, but with an error.
	bsr	close_it

	moveq	#-39,d0
	move.l	d0,return_value
	bra	return

.mem_ok:
* I got the memory!
	move.l	d0,12(a6)

* now I have to load it all in & depack it...
* go to end of file (to get length)

	move.w	#2,-(a7)
	move.w	d7,-(a7)
	clr.l	-(a7)
	move.w	#$42,-(a7)
	trap	#1
	lea	10(a7),a7

	move.l	d0,d6		; keep file length safe for now...

* go back to start of file...
	bsr	go_start

* read the file...
	move.l	12(a6),-(a7)
	move.l	d6,-(a7)
	move.w	d7,-(a7)
	move.w	#$3f,-(a7)
	trap	#1
	lea	12(a7),a7

* did it all read in OK?
	sub.l	d6,d0
	beq.s	.read_ok

* no! so I have to return with an error message...
	bsr	close_it
	moveq	#-36,d0
	bra	return

.read_ok:
* now I have to call the routine to de-pack it...

	lea	routines(pc),a0
	move.l	(a0,d5.w),a5
	move.l	12(a6),a0
	jsr	(a5)

* the file is now de-packed in memory.
* so we just return the handle to the calling program
	move.l	return_value,d0
	bra	return


not_packed:
	bsr	go_start
	move.l	return_value,d0
	bra	return

go_start:
	clr.w	-(a7)
	move.w	d7,-(a7)
	clr.l	-(a7)
	move.w	#$42,-(a7)
	trap	#1
	lea	10(a7),a7
	rts

check_packed:
	lea	pack_list(pc),a2
	lea	flag(pc),a1

	moveq	#0,d5
.check:
	move.l	(a2)+,d0
	beq	.not_packed
	cmp.l	(a1),d0
	beq.s	.is_packed
	addq.w	#4,d5
	bra.s	.check

.not_packed:
	moveq	#-1,d0
	rts


.is_packed:
* yup! Keep details about this file...
	moveq	#0,d0
	rts

pack_list:
	dc.b	"SPv3"
	dc.b	"ICE!"
	dc.b	"LZH!"
	dc.l	0

offs:
	dc.l	12,8,4

routines:
	dc.l	speed
	dc.l	ice
	dc.l	lzh

read_flag:
	lea	flag(pc),a0
	moveq	#20-1,d1
.blank:
	clr.b	(a0)+
	dbra	d1,.blank

	move.w	d0,d7
	pea	flag(pc)
	move.l	#20,-(a7)
	move.w	d7,-(a7)
	move.w	#$3f,-(a7)
	trap	#1
	lea	12(a7),a7
	rts

test_control:
	move.w	#-1,-(a7)
	move.w	#11,-(a7)
	trap	#13
	addq.l	#4,a7
	and.w	#%100,d0
	rts



lzh:
* copy 32 bytes behind to buffer
	lea	buffer(pc),a2
	lea	-32(a0),a1
	moveq	#32-1,d0

	pea	(a2)
	pea	(a1)
.copy:
	move.b	(a1)+,(a2)+
	dbra	d0,.copy

* shift everything down in memory by 32 bytes...
	move.l	a0,a1
	lea	-32(a0),a2
	move.l	8(a0),d0	; get length to shift
	add.l	#12,d0

.shift:
	move.b	(a1)+,(a2)+
	subq.l	#1,d0
	bne.s	.shift


	lea	-32(a0),a5
	move.l	a0,a6
	bsr	DEPACK
* restore memory area

	move.l	(a7)+,a1
	move.l	(a7)+,a2
	moveq	#32-1,d1
.copy_back:
	move.b	(a2)+,(a1)+
	dbra	d1,.copy_back
	rts

* LZH DEPACKER; For use with the JAM Packer V3.0 & 4.0
*
* USAGE:
* LEA $ADDRESS OF PACKED DATA,A5
* LEA $ADDRESS TO UNPACK DATA TO,A6
* BSR DEPACK
*
* NOTE: Must save registers before executing depack if original
*       contents are required.

RESET   MOVEM.W D0-D1/D3/D5,-(A7)
	MOVEA.L A1,A2
	MOVEQ   #$00,D2
	MOVEQ   #-$02,D4
	MOVEQ   #$00,D1
	MOVE.W  #$0139,D5
OUTER	ADDQ.W  #2,D4
	CMP.W   (A2)+,D7
	BHI.S   OUTER
	MOVE.W  $00(A3,D4.W),D3
	ADDQ.W  #1,D3
	LSR.W   #1,D3
	CMP.W   -$02(A3,D2.W),D3
	BLS.S 	BIDDLE
	MOVE.W  $00(A3,D1.W),D0
	ADD.W   $02(A3,D1.W),D0
	CMP.W   D0,D3
	BLS.S	BIDDLE
BITH	MOVE.W  D0,$00(A3,D2.W)
	MOVE.W  D1,$00(A1,D2.W)
	MOVE.W  D2,$00(A0,D1.W)
	MOVE.W  D2,$02(A0,D1.W)
	ADDQ.W  #2,D2
	ADDQ.L  #4,D1
	MOVE.W  $00(A3,D1.W),D0
	ADD.W   $02(A3,D1.W),D0
	CMP.W   D0,D3
	BHI.S	BITH
BIDDLE	MOVE.W  D3,$00(A3,D2.W)
	MOVE.W  $00(A1,D4.W),D0
	MOVE.W  D0,$00(A1,D2.W)
	MOVE.W  D2,$00(A0,D0.W)
	ADDQ.W  #2,D2
	DBF     D5,OUTER
MAKETABLE2
	MOVE.W  $00(A3,D1.W),D0
	ADD.W   $02(A3,D1.W),D0
	MOVE.W  D0,$00(A3,D2.W)
	MOVE.W  D1,$00(A1,D2.W)
	MOVE.W  D2,$00(A0,D1.W)
	MOVE.W  D2,$02(A0,D1.W)
	ADDQ.W  #2,D2
	ADDQ.L  #4,D1
	CMP.W   D7,D2
	BNE.S	MAKETABLE2
	MOVEM.W (A7)+,D0-D1/D3/D5
	RTS     

CREATE  MOVE.L	TABLE7(PC),A0
	LEA     TDATA1(PC),A1
	MOVEQ   #$00,D0
	MOVEQ   #$1F,D1
	MOVEQ   #$00,D2
LOOP1   MOVE.B  D0,(A0)+
	DBF     D1,LOOP1
	DBF     D2,EXIT1
	MOVE.W  (A1)+,D3
	MOVEQ   #$03,D2
EXIT1   ROL.W   #4,D3
	MOVE.W  D3,D1
	ANDI.W  #$000F,D1
	ADDQ.B  #4,D0
	BCC.S   LOOP1
	MOVE.L	TABLE8(PC),A0
	LEA     TDATA2(PC),A1
	MOVEQ   #$05,D0
	MOVEQ   #$03,D1
LOOP2   MOVE.B  $00(A1,D0.W),D2
	EXT.W   D2
LOOP3   MOVE.B  D1,(A0)+
	DBF     D2,LOOP3
	ADDQ.W  #1,D1
	DBF     D0,LOOP2
	RTS

CREATE2 MOVE.L	TABLE1(PC),A0
	MOVE.L	TABLE5(PC),A1
	MOVE.L	TABLE4(PC),A2
	MOVEQ   #$01,D1
	MOVE.W  #$04E6,D2
	MOVEQ   #$00,D4
	MOVE.W  #$0139,D0
CONTINUE
	MOVE.W  D1,(A0)+
	MOVE.W  D2,(A1)+
	MOVE.W  D4,(A2)+
	ADDQ.W  #2,D2
	ADDQ.W  #2,D4
	DBF     D0,CONTINUE
	MOVE.L	TABLE1(PC),A0
	MOVE.L	TABLE2(PC),A3
	MOVE.L	TABLE6(PC),A1
	MOVE.L	TABLE3(PC),A2
	MOVE.W  #$0274,D2
	MOVEQ   #$00,D4
	MOVE.W  #$0138,D0
DOMORE	MOVE.W  (A0)+,D1
	ADD.W   (A0)+,D1
	MOVE.W  D1,(A3)+
	MOVE.W  D4,(A1)+
	MOVE.W  D2,(A2)+
	MOVE.W  D2,(A2)+
	ADDQ.W  #4,D4
	ADDQ.W  #2,D2
	DBF     D0,DOMORE
	MOVE.W  #$FFFF,(A3)
	CLR.W   (A2)
	RTS     

RESTORE BSR     RESET
	BRA     BACK

TABLE1 DC.L 00
TABLE2 DC.L 00
TABLE3 DC.L 00
TABLE4 DC.L 00
TABLE5 DC.L 00
TABLE6 DC.L 00
TABLE7 DC.L 00
TABLE8 DC.L 00

EXIT
	ADDQ.L	#4,A7
	RTS

DEPACK
	LEA	TABLE1(PC),A0
	MOVE.L	#0,(A0)		;SET UP RELATIVE TABLE OFFSETS
	MOVE.L	#$274,4(A0)
	MOVE.L	#$4E8,8(A0)
	MOVE.L	#$9CE,12(A0)
	MOVE.L	#$C42,16(A0)
	MOVE.L	#$EB6,20(A0)
	MOVE.L	#$112A,24(A0)
	MOVE.L	#$122A,28(A0)

	move.l	#lzh_tables,d1

	MOVE.W	#7,D0
TABLOOP
	ADD.L	D1,(A0)+	;ADD TABLE BASE ADDRESS TO OFFSETS
	DBF	D0,TABLOOP
	
	BSR	CREATE
	BSR     CREATE2
	MOVE.L	TABLE3(PC),A0
	MOVE.L	TABLE5(PC),A1
	MOVE.L	TABLE1(PC),A3
	MOVE.L  A6,-(A7)
	ADD.L	4(A5),A6
	ADD.L	8(A5),A5
	ADD.L	#$0C,A5
	MOVE.L	A6,A4

	MOVE.W	#59,D0		;MOVE 60 SPACES TO END OF UNPACKED AREA
SPACES	MOVE.B	#$20,(A4)+	;NOTE: SHOULD PROBABLY SAVE THIS AREA
	DBF	D0,SPACES	;      BEFORE WIPING IT OUT!

	MOVEQ   #$08,D6
	MOVE.B  -(A5),D5
	MOVE.W  #$04E6,D7
	MOVE.L	TABLE8(PC),A4

TOP
	movem.l	a0/d0,-(a7)
	move.w	#$8240,a0
	move.w	(a0),d0
	move.w	a6,(a0)
*	move.w	d0,(a0)
	movem.l	(a7)+,d0/a0

	CMPA.L  (A7),A6
	BLE	EXIT

	MOVE.W  $04E4(A1),D0
MORE	DBF     D6,NOTEMPTY
	MOVEQ   #$07,D6
	MOVE.B  -(A5),D5
NOTEMPTY
	ADD.B   D5,D5
	BCC.S   ZERO
	ADDQ.W  #2,D0
ZERO	MOVE.W  $00(A1,D0.W),D0
	CMP.W   D7,D0
	BLT.S   MORE
	MOVE.W  D0,D1
	SUB.W   D7,D0
	MOVE.W  $04E4(A3),D4
	BMI	RESTORE

BACK	MOVE.W  $00(A0,D1.W),D1
SCAN	LEA     $00(A3,D1.W),A2
	ADDQ.W  #1,(A2)
	CMPM.W  (A2)+,(A2)+
	BCS.S   FRSTGTR
	MOVE.W  $00(A0,D1.W),D1
	BNE.S   SCAN
	LSR.W   #1,D0
	CMP.W   #$0100,D0
	BGE.S   GTE256
WRITE	MOVE.B	D0,-(A6)
	BRA.S   TOP

FRSTGTR SUBQ.W  #1,-$0004(A2)
	MOVE.W  -$0004(A2),D4
SAME	CMP.W   (A2)+,D4
	BEQ.S   SAME
	SUBQ.L  #4,A2
	ADDQ.W  #1,(A2)
	SUBA.L  A3,A2
	MOVE.W  $00(A1,D1.W),D4
	MOVE.W  A2,$00(A0,D4.W)
	CMP.W   D7,D4
	BCC.S   SKIP
	MOVE.W  A2,$02(A0,D4.W)
SKIP	MOVE.W  $00(A1,A2.W),D2
	MOVE.W  D4,$00(A1,A2.W)
	MOVE.W  D1,$00(A0,D2.W)
	CMP.W   D7,D2
	BCC.S   SKIP2
	MOVE.W  D1,$02(A0,D2.W)
SKIP2   MOVE.W  D2,$00(A1,D1.W)
	MOVE.W  $00(A0,A2.W),D1
	BNE.S   SCAN
	LSR.W   #1,D0
	CMP.W   #$0100,D0
	BLT.S   WRITE
GTE256	MOVE.B  -1(A5),D1
	MOVEQ   #$00,D2
	LSR.B   D6,D1
	OR.B    D5,D1
	MOVE.B  $00(A4,D1.W),D2
	SUB.W   D2,D6
	BPL.S   POSITIVE
	MOVE.B  -(A5),D5
	MOVE.B  D5,D4
	ADDQ.W  #2,D6
	BMI.S   OVERFLOW
	BEQ.S   MODD4
	LSR.B   #1,D4
	LSL.B   #7,D5
	BRA.S   MODD4
READONE MOVE.B  -(A5),D5
	MOVE.B  D5,D4
	LSL.B   #6,D5
	MOVEQ   #$02,D6
	LSR.B   D6,D4
	BRA.S   DOCOPY
POSITIVE
	BEQ.S   READONE
	MOVE.B (A5),D5
	SUBQ.W  #6,D6
OVERFLOW
	NEG.W   D6
	LSL.B   D6,D5
	MOVE.B  D5,D4
	MOVE.B  -(A5),D5
	MOVE.B  D5,D2
	LSL.B   D6,D5
	SUBQ.W  #8,D6
	NEG.W   D6
	LSR.B   D6,D2
	OR.B    D2,D4
MODD4   ANDI.W  #$003F,D4
DOCOPY	MOVE.L	TABLE7(PC),A0
	MOVE.B  (A0,D1.W),D2
	LSL.W   #4,D2
	OR.B    D4,D2
	;NEG.W   D2
	LEA     $01(A6,D2.W),A0
	SUBI.W  #$00FE,D0
	MOVE.W  D0,D1
COPY	MOVE.B  -(A0),D0
	MOVE.B  D0,-(A6)
	DBF     D1,COPY
	MOVE.L	TABLE3(PC),A0
	BRA	TOP

TDATA2	DC.W	$0F2F
	DC.W	$2F3F
	DC.W	$2F1F
TDATA1
	DC.W	$FFF7
	DC.W	$7777
	DC.W	$7773
	DC.W	$3333
	DC.W	$3333
	DC.W	$3331
	DC.W	$1111
	DC.W	$1111
	DC.W	$1111
	DC.W	$1111
	DC.W	$1111
	DC.W	$1110
	DC.L	$00
	DC.L	$00

ice:
;********************************************* Unpacking routine of PACK-ICE
; a0 = Adress of packed data
; "bsr" or "jsr" to ice_decrunch_2 with register a0 prepared.
ice_decrunch_2:
	link	a3,#-120
	movem.l	d0-a6,-(sp)
	lea	120(a0),a4
	move.l	a4,a6
	bsr	.getinfo
	cmpi.l	#'ICE!',d0
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


	bsr	.get_1_bit
	bcc.s	.no_picture
	move.w	#$0f9f,d7
	bsr	.get_1_bit
	bcc.s	.ice_00
	moveq	#15,d0
	bsr	.get_d0_bits
	move.w	d1,d7
.ice_00:	moveq	#3,d6
.ice_01:	move.w	-(a3),d4
	moveq	#3,d5
.ice_02:	add.w	d4,d4
	addx.w	d0,d0
	add.w	d4,d4
	addx.w	d1,d1
	add.w	d4,d4
	addx.w	d2,d2
	add.w	d4,d4
	addx.w	d3,d3
	dbra	d5,.ice_02
	dbra	d6,.ice_01
	movem.w	d0-d3,(a3)
	dbra	d7,.ice_00
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

.getinfo: moveq	#3,d1
.getbytes: lsl.l	#8,d0
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
.nextgb:	move.l	-(a1),d0
	bsr.s	.get_d0_bits
	swap.w	d0
	cmp.w	d0,d1
	dbne	d3,.nextgb
.no_more: add.l	20(a1),d1
.copy_direkt:	
	move.b	-(a5),-(a6)
	dbf	d1,.copy_direkt
.test_if_end:
	movem.l	a0/d0,-(a7)
	move.w	#$8240,a0
	move.w	(a0),d0
	not.w	(a0)
	move.w	d0,(a0)
	movem.l	(a7)+,d0/a0

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


.strings: lea.l	.length_tab(pc),a1
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
.no_Åber:	move.b	6(a1,d2.w),d4
	add.w	d1,d4
	beq.s	.get_offset_2


	lea.l	.more_offset(pc),a1
	moveq.l	#1,d2
.getoffs: bsr.s	.get_1_bit
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
.less_40: bsr.s	.get_d0_bits
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
	dc.l     270-1,	15-1,	 8-1,	 5-1,	 2-1

.length_tab:
	dc.b 9,1,0,-1,-1
	dc.b 8,4,2,1,0

.more_offset:
	dc.b	  11,   4,   7,  0	; Bits lesen
	dc.w	$11f,  -1, $1f	; Standard Offset

ende_ice_decrunch_2:
;************************************************** end of unpacking routine

	rts

speed:
* UNPACK source for SPACKERv3	(C)THE FIREHAWKS'92
* -------------------------------------------------
* in	a0: even address start packed block
* out	d0: original length or 0 if not SPv3 packed
* =================================================
* Use AUTO_SP3.PRG for multiblk packed files

unpack:	moveq	#0,d0
	movem.l	d0-a6,-(sp)
	lea	sp3_53(pc),a6
	movea.l	a0,a1
	cmpi.l	#'SPv3',(a1)+
	bne.s	sp3_02
	tst.w	(a1)
	bne.s	sp3_02
	move.l	(a1)+,d5
	move.l	(a1)+,d0
	move.l	(a1)+,(sp)
	movea.l	a0,a2
	adda.l	d0,a0
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	adda.l	(sp),a1
	lea	sp3_58-sp3_53(a6),a3
	moveq	#128-1,d0
sp3_01:	move.l	(a2)+,(a3)+
	dbf	d0,sp3_01
	suba.l	a2,a3
	move.l	a3,-(sp)
	bsr.s	sp3_03
	bsr	sp3_21
	move.b	-(a0),d0
	adda.l	(sp)+,a0
	move.b	d0,(a0)+
	lea	sp3_58-sp3_53(a6),a2
	bsr	sp3_22
	bsr	sp3_15
sp3_02:	movem.l	(sp)+,d0-a6
	rts
sp3_03:	move.w	SR,d1
	andi.w	#$2000,d1
	beq.s	sp3_04
	move.w	$FFFF8240.W,2(a6)
	btst	#1,$FFFF8260.W
	bne.s	sp3_04
	swap	d5
sp3_04:	clr.w	d5
	move.w	-(a0),d6
	lea	sp3_54-sp3_53(a6),a3
	move.b	d6,(a3)+
	moveq	#1,d3
	moveq	#6,d4
sp3_05:	cmp.b	d6,d3
	bne.s	sp3_06
	addq.w	#2,d3
sp3_06:	move.b	d3,(a3)+
	addq.w	#2,d3
	dbf	d4,sp3_05
	moveq	#$10,d4
	move.b	-(a0),(a3)+
	move.b	d4,(a3)+
	move.b	-(a0),(a3)+
	move.b	d4,(a3)+
	move.b	-(a0),d4
	move.w	d4,(a6)
	lea	sp3_57-sp3_53(a6),a5
	move.b	-(a0),d4
	lea	1(a5,d4.w),a3
sp3_07:	move.b	-(a0),-(a3)
	dbf	d4,sp3_07
	move.b	-(a0),-(a3)
	beq.s	sp3_08
	suba.w	d4,a0
sp3_08:	moveq	#0,d2
	move.b	-(a0),d2
	move.w	d2,d3
	move.b	-(a0),d7
sp3_09:	bsr.s	sp3_10
	bsr.s	sp3_10
	dbf	d2,sp3_09
	rts
sp3_10:	not.w	d4
	add.b	d7,d7
	bne.s	sp3_11
	move.b	-(a0),d7
	addx.b	d7,d7
sp3_11:	bcs.s	sp3_12
	move.w	d2,d0
	subq.w	#1,d3
	sub.w	d3,d0
	add.w	d0,d0
	add.w	d4,d0
	add.w	d0,d0
	neg.w	d0
	move.w	d0,-(a3)
	rts
sp3_12:	moveq	#2,d1
	bsr	sp3_44
	add.w	d0,d0
	beq.s	sp3_13
	move.b	d0,-(a3)
	moveq	#2,d1
	bsr	sp3_44
	add.w	d0,d0
	move.b	d0,-(a3)
	rts
sp3_13:	moveq	#2,d1
	bsr	sp3_44
	move.w	sp3_55-sp3_53(a6),d1
	add.w	d0,d0
	beq.s	sp3_14
	move.w	sp3_55+2-sp3_53(a6),d1
sp3_14:	or.w	d1,d0
	move.w	d0,-(a3)
	rts
sp3_15:	move.w	SR,d1
	andi.w	#$2000,d1
	beq.s	sp3_16
	move.w	2(a6),$FFFF8240.W
sp3_16:	tst.w	d6
	bpl.s	sp3_20
	movea.l	a1,a2
	movea.l	a1,a3
	adda.l	4(sp),a3
sp3_17:	moveq	#3,d6
sp3_18:	move.w	(a2)+,d0
	moveq	#3,d5
sp3_19:	add.w	d0,d0
	addx.w	d1,d1
	add.w	d0,d0
	addx.w	d2,d2
	add.w	d0,d0
	addx.w	d3,d3
	add.w	d0,d0
	addx.w	d4,d4
	dbf	d5,sp3_19
	dbf	d6,sp3_18
	cmpa.l	a2,a3
	blt.s	sp3_20
	movem.w	d1-d4,-8(a2)
	cmpa.l	a2,a3
	bne.s	sp3_17
sp3_20:	rts
sp3_21:	move.b	-(a0),-(a1)
sp3_22:	swap	d5
	beq.s	sp3_23
	move.w	d5,$FFFF8240.W
sp3_23:	lea	sp3_56+2-sp3_53(a6),a3
	cmpa.l	a0,a2
	blt.s	sp3_25
	rts
sp3_24:	adda.w	d3,a3
sp3_25:	add.b	d7,d7
	bcc.s	sp3_28
	beq.s	sp3_27
sp3_26:	move.w	(a3),d3
	bmi.s	sp3_24
	bra.s	sp3_29
sp3_27:	move.b	-(a0),d7
	addx.b	d7,d7
	bcs.s	sp3_26
sp3_28:	move.w	-(a3),d3
	bmi.s	sp3_24
sp3_29:	ext.w	d3
	jmp	sp3_30(pc,d3.w)
sp3_30:	bra.s	sp3_30
	bra.s	sp3_41
	bra.s	sp3_41
	bra.s	sp3_41
	bra.s	sp3_41
	bra.s	sp3_41
	bra.s	sp3_37
	bra.s	sp3_36
	bra.s	sp3_32
	bra.s	sp3_33
	bra.s	sp3_31
	bra.s	sp3_34
	bra.s	sp3_21
sp3_31:	move.b	(a5),-(a1)
	bra.s	sp3_22
sp3_32:	bsr.s	sp3_43
	move.b	1(a5,d0.w),-(a1)
	bra.s	sp3_22
sp3_33:	bsr.s	sp3_43
	add.w	(a6),d0
	move.b	1(a5,d0.w),-(a1)
	bra.s	sp3_22
sp3_34:	moveq	#3,d1
	bsr.s	sp3_44
	lsr.w	#1,d0
	bcc.s	sp3_35
	not.w	d0
sp3_35:	move.b	(a1),d1
	add.w	d0,d1
	move.b	d1,-(a1)
	bra.s	sp3_22
sp3_36:	lea	sp3_52-2-sp3_53(a6),a4
	bsr.s	sp3_48
	addi.w	#16,d0
	lea	1(a1,d0.w),a3
	move.b	-(a3),-(a1)
	move.b	-(a3),-(a1)
	bra	sp3_22
sp3_37:	moveq	#3,d1
	bsr.s	sp3_44
	tst.w	d0
	beq.s	sp3_38
	addq.w	#5,d0
	bra.s	sp3_40
sp3_38:	move.b	-(a0),d0
	beq.s	sp3_39
	addi.w	#20,d0
	bra.s	sp3_40
sp3_39:	moveq	#13,d1
	bsr.s	sp3_44
	addi.w	#276,d0
sp3_40:	move.w	d0,d3
	add.w	d3,d3
sp3_41:	lea	sp3_52-sp3_53(a6),a4
	bsr.s	sp3_48
	lsr.w	#1,d3
	lea	1(a1,d0.w),a3
	move.b	-(a3),-(a1)
sp3_42:	move.b	-(a3),-(a1)
	dbf	d3,sp3_42
	bra	sp3_22
sp3_43:	moveq	#0,d1
	move.b	(a3),d1
sp3_44:	moveq	#0,d0
	cmpi.w	#7,d1
	bpl.s	sp3_47
sp3_45:	add.b	d7,d7
	beq.s	sp3_46
	addx.w	d0,d0
	dbf	d1,sp3_45
	rts
sp3_46:	move.b	-(a0),d7
	addx.b	d7,d7
	addx.w	d0,d0
	dbf	d1,sp3_45
	rts
sp3_47:	move.b	-(a0),d0
	subq.w	#8,d1
	bpl.s	sp3_45
	rts
sp3_48:	moveq	#0,d1
	move.b	(a3),d1
	adda.w	d1,a4
	move.w	(a4),d1
	bsr.s	sp3_44
	tst.b	d6
	beq.s	sp3_51
	move.w	d0,d4
	andi.w	#$FFF0,d4
	andi.w	#$000F,d0
	beq.s	sp3_50
	lsr.w	#1,d0
	beq.s	sp3_49
	roxr.b	#1,d7
	bcc.s	sp3_50
	move.b	d7,(a0)+
	moveq	#-128,d7
	bra.s	sp3_50
sp3_49:	moveq	#2,d1
	bsr.s	sp3_44
	add.w	d0,d0
	or.w	d4,d0
	bra.s	sp3_51
sp3_50:	lea	sp3_54-sp3_53(a6),a3
	or.b	(a3,d0.w),d4
	move.w	d4,d0
sp3_51:	add.w	18(a4),d0
	rts

	DC.W	3
sp3_52:	DC.W	4,5,7,8,9,10,11,12
	DC.W	-16
	DC.W	0,32,96,352,864,1888,3936,8032



close:
* get the file handle
	moveq	#0,d7
	move.w	2(a0),d7

	bsr	close_it
	bra	return


close_it:
* close file with handle in d7
* is it one of mine?
	lea	files(pc),a6
	moveq	#0,d0
	move.w	d7,d0
	mulu	#16,d0
	add.l	d0,a6

	tst.l	(a6)
	beq	.normal_close

* it's one of mine!
	pea	(a0)
	move.l	12(a6),-(a7)
	move.w	#$49,-(a7)
	trap	#1		; release memory
	addq.l	#6,a7
	move.l	(a7)+,a0
* now wipe the file details
	rept	4
	clr.l	(a6)+
	endr

* now return, with status OK
	moveq	#0,d0

.normal_close:
* it is not one of mine!
* so let it get on with it...
	move.w	2(a0),-(a7)
	move.w	(a0),-(a7)
	trap	#1
	addq.l	#4,a7

	rts

get_hand:
* pass handle in d7
* returns data addr in a6
	lea	files(pc),a6
	moveq	#0,d0
	move.w	d7,d0
	mulu	#16,d0
	add.l	d0,a6
	rts


read:
* read part of a file...
* get handle
	moveq	#0,d7
	move.w	2(a0),d7

* is it one of mine?
	bsr	get_hand

	tst.l	(a6)
	bne.s	.mine

* not my read!
* so just let it do it...
	bra	do_nothing

.mine:
* this file belongs to me...
* get addr I am currently at...
	move.l	12(a6),a1	; get start addr
	add.l	8(a6),a1	; plus offset

* get the length to read
	move.l	4(a0),d0
* and where to put it
	move.l	8(a0),a2

* will this length take me past the EOF?
	move.l	4(a6),d7
	sub.l	8(a6),d7
	sub.l	d0,d7
	bpl.s	.not_past

* I will go -d7 bytes past end of file!
	add.l	d7,d0
.not_past:
	move.l	d0,return_value
	add.l	d0,8(a6)	; go more into file...

* now slap the bytes in...
	move.l	d0,d1
	lsr.l	#5,d1

	tst.l	d1
	beq.s	.end_while

.while:
	movem.l	(a1)+,d2-7/a3-4
	movem.l	d2-7/a3-4,(a2)
	lea	32(a2),a2
	subq.l	#1,d1
	bne.s	.while

.end_while:
* now do last few bytes...
	and.w	#$001f,d0
	tst.w	d0
	beq.s	.end2

.w2:
	move.b	(a1)+,(a2)+
	subq.w	#1,d0
	bne.s	.w2

.end2:

* I have read it all!
* so return OK, with the length read...

	move.l	return_value,d0
	bra	return

return:
	clr.w	skipping
	movem.l	variables,d1-7/a0-6
	rte


skipping	dc.w	0

intro:
	dc.b	10,13
	dc.b	27,"p*** INTERCEPTER ***",27,"q",10,13
	dc.b	"      by James Ingram, 1994",10,13,10,0
question:
	dc.b	"I am already installed. Select option:",10,13
	dc.b	"1... Turn myself off",10,13
	dc.b	"2... Turn myself on",10,13
	dc.b	"3... do nothing",10,13,10,0

off:	dc.b	"n"
	even


	section	bss
variables	ds.l	16
old_trap1	ds.l	1
stack_addr	ds.l	1
return_value	ds.l	1
flag		ds.b	20

buffer	ds.b	32
lzh_tables	ds.b	6000

sp3_53:	DS.L	1
sp3_54:	DS.B	8
sp3_55:	DS.W	2*64
sp3_56:	DS.W	2
	DS.B	1
sp3_57:	DS.B	1
	DS.B	2*64
sp3_58:	DS.B	512


* null path bytes at start...
	ds.b	2
path:	ds.b	512



files:
	ds.l	20*16
* flag
* length
* offset
* address in memory


	ds.b	100
stack:

