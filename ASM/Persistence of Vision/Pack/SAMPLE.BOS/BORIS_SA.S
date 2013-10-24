**********************************************************************
*                         TRAP 1 interception routine                *
*                         ---------------------------                *
*                                                                    *
* Written by MAC SYS DATA   April 1990                               *
* Version 3.0                                                        *
*                                                                    *
* Use to unpack files packed with AUTOMATION 2.3r                    *
*                                                                    *
*                                                                    *
* Changed on 20/9/90 by Boris                                        *
* Now depacks sample:- packed using BORIS SAMPLE PACKER II           *
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
	cmp.l	#'LSD!',d1	;check for packed data
	beq.s	aut_unpack
	cmp.l	#"BSP2",d1
	beq	bsp2_unpack
	bra.s	exit_trap1

aut_unpack
; God knows what this does, I think it copies part of the program
; below the load address.
	lea	bytes_loaded(pc),a3
	move.l	4(a1),(a3)
	move.l	a1,a0
	lea	-$40(a1),a2
	lea	data_store(pc),a3
	move.w	#$3f,d1
save_below:
	move.b	(a2)+,(a3)+
	dbf	d1,save_below

	lea	-$40(a1),a2
sort_store:
	move.b	(a0)+,(a2)+
	dbf	d0,sort_store
	sub.l	#$10000,d0
	bpl.s	sort_store
	lea	-$40(a1),a0

	move.w	$ffff825e.w,-(sp)
	bsr	depack
	move.w	(sp)+,$ffff825e.w

	lea	data_store(pc),a0
	lea	-$40(a1),a1
	move.w	#$3f,d0
return_below:
	move.b	(a0)+,(a1)+
	dbf	d0,return_below

exit_trap1:
	move.l	bytes_loaded(pc),d0
	lea	store_sr(pc),a0
	move.w	(a0)+,sr
	move.l	(a0),-(sp)
	movem.l	$1000,d1-d7/a0-a6
	rts

bytes_loaded:	dc.l	0
store_sr:	dc.w	0
store_pc:	dc.l	0

data_store:
	dc.l	0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0


depack:	addq.l	#4,a0	;skip over ident (LSD! or POV!)
	move.w	#%0001001000110111,d7	;used for colour flashing
	move.l	a0,a4	;store start in A4
	move.l	(a0)+,d5	;get length of unpacked file
	add.l	d5,a1		;add to destination
	adda.l	(a0),a0		;get end of packed data
	suba.l	#4,a0		;back up 1 long word
	tst.w	-(a0)
	bpl.s	l1
	subq.l	#1,a0
l1:	move.b	-(a0),d0
l2:
	rol.w	#1,d7		;set-up for flash
	move.w	d7,$ffff825e.w	;and flash colours

	lsl.b	#1,d0
	bne.s	l3
	move.b	-(a0),d0
	roxl.b	#1,d0
l3:	bcc.s	l11
	clr.w	d1
	lsl.b	#1,d0
	bne.s	l4
	move.b	-(a0),d0
	roxl.b	#1,d0
l4:	bcc.s	l10
	lea	l9(pc),a3
	moveq	#3,d3
l5:	clr.w	d1
	move.b	0(a3,d3.w),d2
	ext.w	d2
	moveq	#-1,d4
	lsl.w	d2,d4
	not.w	d4
	subq.w	#1,d2
l6:	lsl.b	#1,d0
	bne.s	l7
	move.b	-(a0),d0
	roxl.b	#1,d0
l7:	roxl.w	#1,d1
	dbf	d2,l6
	tst.w	d3
	beq.s	l8
	cmp.w	d1,d4
	dbne	d3,l5
l8:	move.b	4(a3,d3.w),d2
	ext.w	d2
	add.w	d2,d1
	bra.s	l10
l9:	dc.b	$A,3,2,2,$E,7,4,1
l10:	move.b	-(a0),-(a1)
	dbf	d1,l10
l11:	move.l	a4,a3
	addq.l	#8,a3
	cmp.l	a3,a0
	ble	l32
	lea	l18(pc),a3
	moveq	#3,d2
l12:	lsl.b	#1,d0
	bne.s	l13
	move.b	-(a0),d0
	roxl.b	#1,d0
l13:	bcc.s	l14
	dbf	d2,l12
l14:	clr.w	d1
	addq.w	#1,d2
	move.b	0(a3,d2.w),d3
	beq.s	l17
	ext.w	d3
	subq.w	#1,d3
l15:	lsl.b	#1,d0
	bne.s	l16
	move.b	-(a0),d0
	roxl.b	#1,d0
l16:	roxl.w	#1,d1
	dbf	d3,l15
l17:	move.b	5(a3,d2.w),d3
	ext.w	d3
	add.w	d3,d1
	bra	l19
l18:	dC.b	$a,2,1,0,0,$a,6,4
	dC.b	3,2
l19:	cmp.w	#2,d1
	beq.s	l26
	lea	l25(pc),a3
	moveq	#1,d3
l20:	lsl.b	#1,d0
	bne.s	l21
	move.b	-(a0),d0
	roxl.b	#1,d0
l21:	bcc.s	l22
	dbf	d3,l20
l22:	addq.w	#1,d3
	clr.w	d2
	move.b	0(a3,d3.w),d4
	ext.w	d4
l23:	lsl.b	#1,d0
	bne.s	l24
	move.b	-(a0),d0
	roxl.b	#1,d0
l24:	roxl.w	#1,d2
	dbf	d4,l23
	lsl.w	#1,d3
	add.w	4(a3,d3.w),d2
	bra.s	l30
l25:	dc.b	$b,4,7,0,1,$20,0,0
	dc.b	0,$20,0,0
l26:	clr.w	d2
	moveq	#5,d3
	clr.w	d4
	lsl.b	#1,d0
	bne.s	l27
	move.b	-(a0),d0
	roxl.b	#1,d0
l27:	bcc.s	l28
	moveq	#8,d3
	moveq	#$40,d4
l28:	lsl.b	#1,d0
	bne.s	l29
	move.b	-(a0),d0
	roxl.b	#1,d0
l29:	roxl.w	#1,d2
	dbf	d3,l28
	add.w	d4,d2
l30:	lea	0(a1,d2.w),a2
	ext.l	d1
	adda.l	d1,a2
	subq.w	#1,d1
l31:	move.b	-(a2),-(a1)
	dbf	d1,l31
	bra	l2
l32:	rts		;exit from depack
laddr:	dc.l	0


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
