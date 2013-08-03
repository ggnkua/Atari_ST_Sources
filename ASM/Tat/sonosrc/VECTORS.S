;wait_transmit	macro
;	btst	#1,$ffffa202.w
;	beq.s	*-6
;	endm
;
;wait_receive	macro
;	btst	#0,$ffffa202.w
;	beq.s	*-6
;	endm
;
;
;OFF		equ	0
;ON		equ	1
;

*********************************
*	vector-saving routines:	*
*********************************
savevectors:
	move.w	#-1,-(a7)
	move.w	#$58,-(a7)
	trap	#14
	addq.l	#4,a7
	move.w	d0,resolution

	move.w	#2,-(a7)
	trap	#14
	addq.l	#2,a7
	move.l	d0,screen_base

	move.w	#3,-(a7)
	trap	#14
	addq.l	#2,a7
	move.l	d0,screen_base_2

	lea	save_vectors(pc),a0
	lea	$8.w,a1
	moveq	#($140-8)/4-1,d0
.copy1	move.l	(a1)+,(a0)+
	dbf	d0,.copy1
	
	lea	$fffffa01.w,a1
	moveq	#21,d0
.copy2	move.b	(a1),(a0)+
	addq.l	#2,a1
	dbf	d0,.copy2

;set  error vectors:
	lea	$8.w,a0
	lea	restore_vectors(pc),a1
	moveq	#9,d0
.copy3	move.l	a1,(a0)+
	dbf	d0,.copy3
	bclr	#3,$fffffa17.w
	rts

quit:
restore_vectors:
	movem.l	d0-a6,save_registers
	IFNE	Tracker_On
	JSR	stop_tracker
	ENDC
	move.w	6(a7),a0
	move.w	a0,which_error

	move.l	(a0),-(a7)
	move.w	#$2700,sr
	lea	save_vectors(pc),a0
	lea	$8.w,a1
	moveq	#($140-8)/4-1,d0
.copy1	move.l	(a0)+,(a1)+
	dbf	d0,.copy1

	lea	$fffffa01.w,a1
	moveq	#21,d0
.copy2	move.b	(a0)+,(a1)
	addq.l	#2,a1
	dbf	d0,.copy2

	move.b	#$c8,$fffffa23.w
	lea	mouse_on(pc),a0
	bsr	send_ikbd
; Flush:
.flush	move.b	$fffffc02.w,d0
	btst	#0,$fffffc00.w
	bne.s	.flush
	move.w	#$2300,sr

	move.w	#37,-(a7)
	trap	#14
	addq.l	#2,a7		;wait vbl

	move.w	resolution(pc),-(a7)
	move.w	#3,-(a7)
	move.l	screen_base(pc),-(a7)
	move.l	screen_base_2(pc),-(a7)
	move.w	#5,-(a7)
	trap	#14
	lea	14(a7),a7

	;move.l	#$6f6f006f,$ffff9800.w
	;clr.l	$ffff9804.w
	;clr.b	$ffff8265.w

	move.l	#$3919,d0
	movec	d0,cacr

	movem.l	save_registers(pc),d0-a6
	illegal
	;clr.w	-(a7)
	;trap	#1

which_error	dc.w 0
error_flag	dc.w -1		;assume error

screen_base:
	ds.l 1
screen_base_2:
	ds.l 1
resolution:
	ds.w 1
save_stack:
	ds.l 1

*****************************************
*	Keyboard handler:		*
*****************************************

keyboard:
	move.w	#$2300,sr
	move.w	d6,-(a7)
	move.l	a6,-(a7)
.read_data
	move.w	status(pc),d6
	move.w	.jumplist(pc,d6.w),d6
	jmp	.jumplist(pc,d6.w)

.jumplist
	dc.w	.keypress-.jumplist	;0 - keypress
	dc.w	.mouse1-.jumplist	;$f8 2
	dc.w	.mouse1-.jumplist	;$f9 4
	dc.w	.mouse1-.jumplist	;$fa 6
	dc.w	.mouse1-.jumplist	;$fb 8
	dc.w	.keypress-.jumplist	;$fc 10 - keypress
	dc.w	.mouse2-.jumplist	;$fd 12
	dc.w	.joy1-.jumplist		;$fe 14 - get j1 data
	dc.w	.joy2-.jumplist		;$ff 16 - get j2 data

*routines:
.keypress
	sub.w	d6,d6			;cant use MOVEQ
	move.b	$fffffc02.w,d6
	move.b	d6,keypress

	cmp.w	#$f8,d6			;special cases....
	bge.s	.special

	lea	keyboard_matrix,a6
	bclr	#7,d6			;ignore	bit 7
	bne.s	.keyup

	move.b	d6,lastkey
	st.b	(a6,d6.w)
	bra.s	.end
.keyup	clr.b	(a6,d6.w)
					;falls through
.end
	btst	#4,$fffffa01.w
	beq.s	.read_data		;another interrupt
	move.l	(a7)+,a6
	move.w	(a7)+,d6
	rte

**** Handle joysticks:
.special:	sub.w	#$f7,d6		; 1 or 2
	add.w	d6,d6			; 2 or 4...
	move.w	d6,status
	bra.s	.end

.joy1	move.b	$fffffc02.w,joy1
	clr.w	status
	bra.s	.end
.joy2	move.b	$fffffc02.w,joy2
	clr.w	status
	bra.s	.end

.mouse1	move.b	$fffffc02.w,d6
	ext.w	d6
	add.w	d6,mouse_x
	move.w	status(pc),d6		;2-8
	lsr.w	#1,d6			;1-4
	subq.w	#1,d6			;0-3
	move.b	d6,mouse_button
	move.w	#12,status
	bra.s	.end

.mouse2	move.b	$fffffc02.w,d6
	ext.w	d6
	add.w	d6,mouse_y
	clr.w	status
	bra.s	.end

*****************************
send_ikbd:
	move.w	#$fc00,a1

.loop	btst	#1,(a1)			;ready to send?
	beq.s	.loop
	move.b	(a0)+,2(a1)		;plonk it in
	cmp.b	#-5,(a0)		;end?
	bne.s	.loop
	rts

*****************************
mouse_on	dc.b	$1a,$8,-5
joy_on	dc.b	$14,$8,-5
	even

*********************
vbl:
	addq.w	#1,vbl_timer
	cmp.b	#$39,$fffffc02.w	;check for user quit
	beq	quit
	cmp.b	#$62,$fffffc02.w
	bne	_1
	st	screenshot	
	illegal
_1
	movem.l	d0-a6,-(A7)
	move.l	my_vbl(pc),a0
	jsr	(a0)
	movem.l	(a7)+,d0-a6
	rte

rts	rts

wait_vbl:
	clr.w	vbl_timer
.wv	tst.w	vbl_timer
	beq.s	.wv
	rts

	illegal


*************************
*	Data Section:	*
*************************
* Mouse information:
lastkey		dc.b 0
mouse_button	dc.b 0
		even
mouse_x		dc.w 0
screenshot	dc.w 0
mouse_y		dc.w 0
save_a0		ds.l 1
status		ds.w 1
keypress	ds.w 1
keyboard_matrix	ds.b 128
joy1		ds.w 1
joy2		ds.w 1
kb_data		ds.w 1
vbl_timer	ds.w 1
logic		ds.l 1
physic		ds.l 1
my_vbl		dc.l rts

save_vectors	ds.l 350/4
save_registers	ds.l 16
