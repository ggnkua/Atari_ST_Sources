* This is the keyboard interrupt code.

iea	equ	$fffffa07 
ieb	equ	$fffffa09 
imb	equ	$fffffa15
;isrb	equ	$fffffa11
keyb	equ	$118

key_int_on
	move	#$2700,sr
	move.l	(keyb).w,oldkeyb
	move.b	(ieb).w,oldieb
	move.b	(iea).w,oldiea
	move.b	(imb).w,oldimb
	move.b	(isrb).w,oldisrb
	move.l	#key_handler,$118
	bset	#6,(ieb).w			; keyboard irq on
	bset	#6,(imb).w
	move	#$2300,sr
	rts

key_int_off
	move	#$2700,sr
	move.l	oldkeyb,(keyb).w
	move.b	oldieb,(ieb).w
	move.b	oldiea,(iea).w
	move.b	oldimb,(imb).w
	move.b	oldisrb,(isrb).w
	move	#$2300,sr
	rts

oldiea	ds.b	1
oldieb	ds.b	1
oldimb	ds.b	1
oldisrb	ds.b	1
oldkeyb	ds.l	1

key_handler	
	move	#$2500,sr
	clr.b	keybuff
	clr.b	mouse_y
;	clr.b	mouse_buttons
	movem.l	d0-d7/a0-a6,-(sp)
	lea	$fffffc00.w,a1
	move.b	(a1),d2
	btst	#7,d2
	beq	.exit
	btst	#0,d2
	beq	.clear
	movem.l	d2/a0-a2,-(a7)
	bsr	.getbyte
	movem.l	(a7)+,d2/a0-a2
.clear	and.b	#$20,d2
	beq	.exit
	move.b	2(a1),d0
.exit
	movem.l	(sp)+,d0-d7/a0-a6
	bclr	#6,isrb
	btst	#4,$fffffa01.w
	beq.s	key_handler
	rte
.getbyte			; shifty type key jobbys
	IFEQ	MOUSE_Y
.nup	tst.b	mouse_flag 
	bne.s	.m_x
	move.b	2(a1),d0
	cmp.b	#$f8,d0
	blt	.nomouse
	cmp.b	#$fb,d0
	bgt	.nomouse
	move.b	2(a1),d0
	clr.b	keybuff
	andi.b	#3,d0 
	move.b	d0,mouse_buttons
	move.b	#1,mouse_flag
	bra	.bye
.m_x	cmp.b	#1,mouse_flag
	bne.s	.m_y
	move.b	#2,mouse_flag
	bra	.bye
.m_y	tst.b	step
	bne	.bye
	move.b	2(a1),d0
	moveq	#-1,d1
	tst.b	d0
	bmi.s	.minus
	moveq	#1,d1
.minus	add	d1,mouse_y
	tst	mouse_y
	bpl.s	.pos
	clr	mouse_y
.upsc	tst.b	start_pos
	beq	.endy
	subi.b	#1,start_pos
	subi.b	#1,end_pos
	move.b	#-1,step
	bra.s	.endy
.pos	cmp	#19*8,mouse_y
	blt.s	.endy
	move	#19*8,mouse_y
.downsc	move.b	lines,d0
	cmp.b	end_pos,d0
	beq	.endy
	addi.b	#1,start_pos
	addi.b	#1,end_pos
	move.b	#1,step
.endy	move	mouse_y,d0
	lsr.w	#3,d0
	move.b	d0,curs_pos
	move.b	#1,vwait
	clr.b	mouse_flag
	rts
.nomouse
	move.b	d0,keybuff
.bye	rts 
	ELSE
.nup	tst.b	mouse_flag 
	bne.s	.m_x
	move.b	2(a1),d0
	cmp.b	#$f8,d0
	blt	.nomouse
	cmp.b	#$fb,d0
	bgt	.nomouse
	move.b	2(a1),d0
	andi.b	#3,d0 
	move.b	d0,mouse_buttons
	move.b	#1,mouse_flag
	bra.s	.bye
.m_x	cmp.b	#1,mouse_flag
	bne.s	.m_y
	move.b	#2,mouse_flag
	bra.s	.bye
.m_y	move.b	2(a1),d0
	move.b	d0,mouse_y
	clr.b	mouse_flag 
.nomouse
	move.b	d0,keybuff
.bye	rts 
	ENDC
keybuff	ds.b	1
mouse_flag
	ds.b	1
mouse_f	ds.b	1
mouse_buttons:
	ds.b	1		; 1=R,2=L,3=Both!
mouse_y	ds.w	1
shift	ds.b	1
alt	ds.b	1
ctrl	ds.b	1
vwait	ds.b	1
	even
