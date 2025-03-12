**********************************************************************
*                         TRAP 1 interception routine                *
*                         ---------------------------                *
*                                                                    *
* Written by MAC SYS DATA   April 1990                               *
* Version 3.1                                                        *
*                                                                    *
* Changed on 20/9/90 by Boris                                        *
* Now depacks sample:- packed using BORIS SAMPLE PACKER II           *
*                                                                    *
* Altered to only depack BORIS PACKER II files by M.S.D. 5/12/90     *
*                                                                    *
**********************************************************************

WORKSIZE	equ	100	; This may have to be larger.

	move.l	sp,a5		;free GEM
	move.l	4(a5),a5
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$100,d0
	move.l	d0,d7
	move.l	D0,-(sp)
	move.l	A5,-(sp)
	move.w	#0,-(sp)
	move.w	#$4A,-(sp)
	trap	#1
	add.l	#12,sp

	bsr	flip_mode	;go into supervisor mode
	lea	do_jmp+2(pc),a0
	move.l	$84,(a0)
	move.l	#new_trap1,$84	;install our own TRAP 1 route
	bsr	flip_mode	;go back to user mode

	dc.w	$a00a
; Print mess
	pea	text(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

; get a key.
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp

;	dc.w	$a009
	pea	laddr(pc)	;run demo
	pea	laddr(pc)
	pea	filename(pc)
	move.w	#0,-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	add.l	#16,sp
	tst.l	d0
	bne.s	oops
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	do_jmp+2,a0
	move.l	a0,$84
	move.l	d0,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	clr.w	-(sp)
	trap	#1
oops:	
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	4,a0
	jmp	(a0)
filename:
	dc.b	'scree_sk.unk',0	;filename
	even
text:	dc.b	27,'E'
	dc.b	27,'Y',6+32,7+32,"SCREE DEMO BY 'THE SKUNK'"
	dc.b	27,'Y',7+32,7+32,"-------------------------"
	dc.b	27,'Y',10+32,15+32,"Packed by"
	dc.b	27,'Y',12+32,9+32,"MAC SYS DATA and BORIS"
	dc.b	27,'Y',14+32,10+32,"16/9/90 and 20/9/90"
	dc.b	27,'Y',17+32,14+32,"Press a key."
	dc.b	0
	even
flip_mode:
	move.l	(sp),a6
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,stack_save
	jmp	(a6)
stack_save:	dc.l	0

new_trap1:
	movem.l	d1-d7/a0-a6,$1000
	move.l	sp,a1
	addq.l	#6,a1
	move.w	(sp),d0
	btst	#$d,d0		;test for supervisor
	bne.s	in_user
	move.l	USP,a1
in_user:
	cmpi.w	#$3f,(a1)	;is F_READ call?
	bne	go_jmp

	lea	store_sr(pc),a0
	move.w	(sp)+,(a0)+	;store sr
	move.l	(sp)+,(a0)	;store pc

;simulate the load routine by putting all the data back into the stack
	lea	$c(a1),a2
	move.l	-(a2),-(sp)	;address to load at
	move.l	-(a2),-(sp)	;number of bytes to load
	move.l	-(a2),-(sp)	;file handle and $3f for F_READ

	pea	trap1_return(pc)	;push our TRAP 1 address to return to
	move.w	#$2300,-(sp)	;put a SR on the stack
go_jmp:	movem.l	$1000,d1-d7/a0-a6	;return regs
do_jmp	jmp	0		;jump to offical ROM address

trap1_return:
	movem.l	d1-d7/a0-a6,$1000

	move.l	8(sp),a1	;load address
	add.l	#$c,sp
	lea	bytes_loaded(pc),a3
	move.l	d0,(a3)		;store number of bytes loaded

	move.b	(a1),d1		;get 1st letter
	rol.l	#8,d1
	move.b	1(a1),d1	;2nd
	rol.l	#8,d1
	move.b	2(a1),d1	;3rd
	rol.L	#8,d1
	move.b	3(a1),d1	;4th
	cmp.l	#"BSP2",d1
	beq	bsp2_unpack

exit_trap1
	move.l	bytes_loaded(pc),d0
	lea	store_sr(pc),a0
	move.w	(a0)+,sr
	move.l	(a0),-(sp)
	movem.l	$1000,d1-d7/a0-a6
	rts

bytes_loaded:	dc.l	0
store_sr:	dc.w	0
store_pc:	dc.l	0


bsp2_unpack	; This version only works on EVEN address.
	cmp.b	#2,4(a1)	; Same version?
	bne	exit_bsp2
	cmp.b	#$e0,5(a1)	; Same mask?
	bne	exit_bsp2

	lea	bytes_loaded(pc),a2
	move.l	(a2),d0
	move.l	6(a1),d1	; Get original length.
	move.l	d1,(a2)
	btst.l	#0,d0
	beq.s	.even1
	addq.l	#1,d0
.even1	move.l	d1,d2
	btst.l	#0,d1
	beq.s	.even2
	addq.l	#1,d1
.even2
	move.l	a1,a6		; Save memory above sample.
	add.l	d1,a6
	lea	workspace(pc),a0
	move.w	#(WORKSIZE/2)-1,d3
.save	move.w	(a6)+,(a0)+
	dbf	d3,.save

	move.l	a1,a2		; Move sample up.
	lea	10(a1),a3
	add.l	d0,a2
.move	move.w	-(a2),-(a6)
	cmp.l	a3,a2
	bgt.s	.move

	move.w	$ffff825e.w,colour	; Colour flashing.
	move.l	a1,a0
	add.l	d2,a1
	moveq	#0,d5
	moveq	#0,d6
	move.w	(a6)+,d0
bsp_depack
	moveq	#0,d2
	lsl.w	#1,d0
	roxl.b	#1,d2
	addq.w	#1,d5
	and.w	#15,d5
	bne	.cont
	move.w	(a6)+,d0
.cont	tst.b	d2
	bne	byte

	move.w	#$333,$ffff825e.w	; Colour flashing.

	moveq	#0,d2
	lsl.w	#1,d0
	roxl.b	#1,d2
	addq.w	#1,d5
	and.w	#15,d5
	bne	.ok1
	move.w	(a6)+,d0
.ok1
	lsl.w	#1,d0
	roxl.b	#1,d2
	addq.w	#1,d5
	and.w	#15,d5
	bne	.ok2
	move.w	(a6)+,d0
.ok2
	lsl.w	#1,d0
	roxl.b	#1,d2
	addq.w	#1,d5
	and.w	#15,d5
	bne	.ok3
	move.w	(a6)+,d0
.ok3
	lsl.w	#1,d0
	roxl.b	#1,d2
	addq.w	#1,d5
	and.w	#15,d5
	bne	.ok4
	move.w	(a6)+,d0
.ok4
	lsl.w	#1,d0
	roxl.b	#1,d2
	addq.w	#1,d5
	and.w	#15,d5
	bne	.ok5
	move.w	(a6)+,d0
.ok5
	move.w	colour,$ffff825e.w	; Colour flashing.

	move.b	d6,d1
	and.b	#$e0,d1
	or.b	d1,d2
	bra	store
byte
	moveq	#0,d2
	lsl.w	#1,d0
	roxl.b	#1,d2
	addq.w	#1,d5
	and.w	#15,d5
	bne	.ok1
	move.w	(a6)+,d0
.ok1
	lsl.w	#1,d0
	roxl.b	#1,d2
	addq.w	#1,d5
	and.w	#15,d5
	bne	.ok2
	move.w	(a6)+,d0
.ok2
	lsl.w	#1,d0
	roxl.b	#1,d2
	addq.w	#1,d5
	and.w	#15,d5
	bne	.ok3
	move.w	(a6)+,d0
.ok3
	lsl.w	#1,d0
	roxl.b	#1,d2
	addq.w	#1,d5
	and.w	#15,d5
	bne	.ok4
	move.w	(a6)+,d0
.ok4
	lsl.w	#1,d0
	roxl.b	#1,d2
	addq.w	#1,d5
	and.w	#15,d5
	bne	.ok5
	move.w	(a6)+,d0
.ok5
	lsl.w	#1,d0
	roxl.b	#1,d2
	addq.w	#1,d5
	and.w	#15,d5
	bne	.ok6
	move.w	(a6)+,d0
.ok6
	lsl.w	#1,d0
	roxl.b	#1,d2
	addq.w	#1,d5
	and.w	#15,d5
	bne	.ok7
	move.w	(a6)+,d0
.ok7
	lsl.w	#1,d0
	roxl.b	#1,d2
	addq.w	#1,d5
	and.w	#15,d5
	bne	.ok8
	move.w	(a6)+,d0
.ok8
	move.b	d2,d6
store	move.b	d2,(a0)+
	cmp.l	a1,a0
	blt	bsp_depack

	move.l	a0,d0		; Restore memory above sample.
	btst.l	#0,d0
	beq.s	.even
	addq.w	#1,a0
.even	lea	workspace(pc),a1
	move.w	#(WORKSIZE/2)-1,d0
.move	move.w	(a1)+,(a0)+
	dbf	d0,.move
exit_bsp2
	bra	exit_trap1

colour		ds.w	1	; Colour flashing.
workspace	ds.b	WORKSIZE
laddr:		dc.l	0