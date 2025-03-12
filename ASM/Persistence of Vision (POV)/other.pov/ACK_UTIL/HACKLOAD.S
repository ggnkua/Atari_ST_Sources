****************************************************************
*                   TRAP 1 interception routine                *
*                   ---------------------------                *
*                                                              *
* Written by MAC SYS DATA  FRB '90                             *
* Version 2.3                                                  *
*                                                              *
* This version will return the unpacked file length in D0.L    *
* after a load. ( V2.2 returned the packed file length which   *
* made some demos crash.                                       *
*                                                              *
****************************************************************

	move.l	sp,a5
	move.l	4(a5),a5
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	addi.l	#$100,d0
	move.l	d0,d7
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move.w	#0,-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	add.l	#$c,sp

	dc.w	$a00a
	pea	mess
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	bsr	flip_mode

	lea	do_jmp+2(pc),a0
	move.l	$84,(a0)
	move.l	#new_trap1,$84

	bsr	flip_mode

	pea	laddr(pc)
	pea	laddr(pc)
	pea	filename(pc)
	move.w	#0,-(sp)
	move.w	#$4b,-(sp)
	trap	#1


flip_mode:
	move.l	(sp),a6
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,stack_save
	jmp	(a6)

stack_save:
	dc.l	0

new_trap1:
	movem.l	d1-d7/a0-a6,store
	move.l	sp,a1
	addq.l	#6,a1
	move.w	(sp),d0
	btst	#13,d0
	bne.s	in_user

	move.l	USP,a1

in_user:
	cmp.w	#$3f,(a1)	;F_READ call.
	bne	go_jmp

	lea	store_sr(pc),a0
	move.w	(sp)+,(a0)+	;store SR
	move.l	(sp)+,(a0)	;and PC for return address

; simulate the load routine by putting all the bits back on the stack
; at the correct position.
	lea	$c(a1),a3
	move.l	-(a3),-(sp)	;address to load at
	move.l	-(a3),-(sp)	;number of bytes
	move.l	-(a3),-(sp)	;file handle and $3f for f_read

	pea	trap1_return(pc);push our return address to stack.
	move.w	#$2300,-(sp)	;put the SR back on the stack.

;return saved registers here........
go_jmp:	movem.l	store,d1-d7/a0-a6
do_jmp:	jmp	0		;and jump to ROM

store:	dcb.l	0,16


; the read routine will return to here now... (depack)
trap1_return:
	movem.l	d1-d7/a0-a6,store

	lea	bytes_loaded(pc),a3
	move.l	d0,(a3)		;store number of bytes read

	move.l	8(sp),a1	;get where to load
	move.l	4(sp),a2	;how much to load
	add.l	#$c,sp
	move.l	a1,load_addr

	move.l	a1,a3
	add.l	d0,a1	;get end of file?
	sub.w	#4,a1	;back up 4 bytes to start of ident long-word

	move.b	(a1),d1		;1st letter
	rol.l	#8,d1
	move.b	1(a1),d1	;2nd
	rol.l	#8,d1
	move.b	2(a1),d1	;3rd
	rol.l	#8,d1
	move.b	3(a1),d1	;4th
	cmp.l	#"MSD!",d1	;check ident long-word (if LSD pack then LSD!)
	bne.s	exit_trap1	;not packed	       (if JEK pack then JEK!)
;						       (if POV pack then MSD!)
; a0 must point to end of compacted code
; a1 must point to destination
	move.l	a1,a0
	move.l	a3,a1

	bsr	depak

	move.l	end_of_file,a0	;calc the original file length.
	move.l	load_addr,a1
	sub.l	a1,a0
	move.l	a0,bytes_loaded

exit_trap1:
	lea	bytes_loaded(pc),a0
	move.l	(a0)+,d0	; no. bytes loaded.
	move.w	(a0)+,sr
	move.l	(a0),-(sp)
	movem.l	store,d1-d7/a0-a6
	rts

bytes_loaded:	dc.l	0
store_sr:	dc.w	0
store_pc:	dc.l	0
load_addr:	dc.l	0
end_of_file:	dc.l	0

depak:	move.w	$ffff8240.w,-(sp)
	move.l	-(a0),d1
	move.l	-(a0),d5
	move.l 	a1,a2
	adda.l 	d1,a2
	move.l	a2,end_of_file
	move.l 	-(a0),d0
	eor.l 	d0,d5
l1:	lsr.l 	#1,d0
	bne.s 	l2
	bsr 	l16
l2:	bcs.s 	l9
	moveq 	#8,d1
	moveq 	#1,d3
	lsr.l 	#1,d0
	bne.s 	l3
	bsr 	l16
l3:	bcs.s 	l11
	moveq 	#3,d1
	clr.w 	d4
l4:	bsr 	l17
	move.w 	d2,d3
	add.w 	d4,d3
l5:	moveq 	#7,d1
l6:	lsr.l 	#1,d0
	bne.s 	l7
	bsr 	l16
l7:	roxl.l 	#1,d2
	dbf 	d1,l6
	move.b 	d2,-(a2)
	dbf 	d3,l5
	bra.s 	l13
l8:	moveq 	#8,d1
	moveq 	#8,d4
	bra.s 	l4
l9:	moveq 	#2,d1
	bsr 	l17
	cmpi.b 	#2,d2
	blt.s 	l10
	cmpi.b 	#3,d2
	beq.s 	l8
	moveq 	#8,d1
	bsr.s 	l17
	move.w 	d2,d3
	move.w 	#12,d1
	bra.s 	l11
l10:	move.w 	#9,d1
	add.w 	d2,d1
	addq.w 	#2,d2
	move.w 	d2,d3
l11:	bsr.s 	l17
l12:	subq.w 	#1,a2
	move.b 	0(a2,d2.w),(a2)
	dbf 	d3,l12
l13:	move.w	d0,$ffff8240.w
	cmpa.l 	a2,a1
	blt.s 	l1
	tst.l 	d5
	bne.s 	l14
fin	move.w	(sp)+,$ffff8240.w
	rts
l14:	nop
l15:	moveq 	#1,d0	;if an error occurs then d0.L = 1
	rts
l16:	move.l 	-(a0),d0
	eor.l 	d0,d5
	move.b 	#$10,ccr
	roxr.l 	#1,d0
	rts
l17:	subq.w 	#1,d1
	clr.w	 d2
l18:	lsr.l 	#1,d0
	bne.s	 l19
	move.l 	-(a0),d0
	eor.l 	d0,d5
	move.w	d0,$ffff8240.w
	move.b 	#$10,ccr
	roxr.l 	#1,d0
l19:	roxl.l 	#1,d2
	dbf 	d1,l18
	rts

	even
laddr:	dc.l	0
filename:
	dc.b	"RUNSCAPE.MSD",0
	even
mess:	dc.b	27,'E'
	dc.b	"             CYBERSCAPE DEMO",13,10
	dc.b	"             ---------------",13,10,10,10,10
	dc.b	"               Packed by",13,10,10
	dc.b	"              MAC SYS DATA",13,10,10
	dc.b	"                  of",13,10,10
	dc.b	"         PERSISTENCE OF VISION",13,10,10,10,10
	dc.b	"               24/02/90",13,10,10,0
	even
	dc.l	0
