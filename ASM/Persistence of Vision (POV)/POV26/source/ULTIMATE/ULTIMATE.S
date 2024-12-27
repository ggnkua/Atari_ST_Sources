************************************
* ULTIMATE DEMO HACK               *
* Hopefully now 1/2 meg compatable *
************************************


**********************************************************************
*                         TRAP 1 interception routine                *
*                         ---------------------------                *
*                                                                    *
* Written by MAC SYS DATA   April 1990                               *
* Version 3.0                                                        *
*                                                                    *
* Use to unpack files packed with AUTOMATION 2.3r                    *
*                                                                    *
**********************************************************************

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	#$77800-10,sp	;set stack

	lea	do_jmp+2(pc),a0
	move.l	$84,(a0)

	dc.w	$a00a

	pea	mess
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp

	move.w	#2,$440
	clr.w	$444

	lea	$ffff8240.w,a0
	moveq	#7,d0
a	clr.l	(a0)+
	dbf	d0,a

	clr.b	$ffff8260.w
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp

	move.l	d0,a1
	lea	pic+34,a0
	move.w	#32000/4-1,d0
b	move.l	(a0)+,(a1)+
	dbf	d0,b

	lea	black,a0
	lea	pic+2,a1
	bsr	fade_in

	lea	new_load(pc),a0
	lea	$77800,a1
	move.l	#new_loadend-new_load,d0
c	move.b	(a0)+,(a1)+
	sub.l	#1,d0
	bne.s	c

	lea	$9000,a1
	lea	new_trap1,a0
	move.l	#newtrap1end-new_trap1,d0
install:
	move.b	(a0)+,(a1)+
	sub.l	#1,d0
	bne.s	install

	move.l	#$9000,$84	;install our own TRAP 1 route

	jmp	$77800

fade_in	MOVE #7,D6
	MOVE.L A1,A2
FADEIN1:LEA	PALREG,A0
	MOVE #16-1,D7
FADEIN2:
	bsr MODIFY
	ADDQ #2,A0
	ADDQ #2,A1
	DBRA D7,FADEIN2
	MOVE #4,D0
	BSR	WAIT
	MOVE.L A2,A1
	DBRA D6,FADEIN1
	RTS
WAIT:	BSR	owvbl
	DBRA D0,WAIT
	RTS
owvbl:	MOVEM.L D0-D2/A0-A2,-(SP)
	MOVE.W #37,-(sp)
	TRAP #14
	ADDQ.L #2,SP
	MOVEM.L (SP)+,D0-D2/A0-A2
	RTS
PALREG:	EQU $FF8240
MODIFY:	MOVE (A0),D0 ;PALREG
	MOVE (A1),D1 ;TARGET
	MOVE D0,D4 ;NEW COL
	MOVE D0,D2
	MOVE D1,D3
	AND #$7,D2
	AND #$7,D3
	CMP D2,D3
	BEQ.S MOK1
	BMI.S MDN1
	ADDQ #1,D4
	BRA.S MOK1
 MDN1:	SUBQ #1,D4
 MOK1:	MOVE D0,D2
	MOVE D1,D3
	AND #$70,D2
	AND #$70,D3
	CMP D2,D3
	BEQ.S MOK2
	BMI.S MDN2
	ADD #$10,D4
	BRA.S MOK2
 MDN2:	SUB #$10,D4
 MOK2:	MOVE D0,D2
	MOVE D1,D3
	AND #$700,D2
	AND #$700,D3
	CMP D2,D3
	BEQ.S MOK3
	BMI.S MDN3
	ADD #$100,D4
	BRA.S MOK3
MDN3:	SUB #$100,D4
MOK3:	MOVE D4,(A0)
	RTS

mess:	dc.b	27,'E'
	dc.b	"    ULTIMATE DEMO BY THE DYNAMIC DUO",13,10
	dc.b	"    --------------------------------",13,10,10,10
	dc.b	"          Hacked 'n' packed by",13,10,10
	dc.b	"              MAC SYS DATA",13,10,10
	dc.b	"             29th June 1990",13,10,10,10,10,10
	dc.b	"      Another boot loading demo...",13,10,10,10
	dc.b	"        Press a key to continue.",13,10,0
	even

new_load:
	move.w	#2,-(sp)
	pea	filename(pc)
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
	move.l	d0,d7
	pea	$ffe4
	move.l	#404480,-(sp)
	move.w	d7,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	add.l	#12,sp
	move.w	d7,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	add.l	#4,sp
	jmp	$10000
filename:	dc.b	'a:\ffe4.ult',0,0
	even
new_loadend:	

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
	bne.s	exit_trap1		;not packed


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

	move.w	$ff8240,-(sp)
	bsr	depack
	move.w	(sp)+,$ff8240

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
	move.w	d7,$ffff8240.w	;and flash colours

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
newtrap1end

	SECTION DATA
pic:	incbin	"e:\ultimate\pic.pi1"
	even

	SECTION BSS
black:	ds.b	34





