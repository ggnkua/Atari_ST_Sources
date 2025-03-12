*=======================================================*
*	IKBD routines: latest update 25/03/96		*
*=======================================================*
*	Handle keyboard & mouse				*
*=======================================================*

ikbd		=	$118		; keyboard vector
key_ctl		=	$fffffc00	; keyboard control register
key_dat		=	$fffffc02	; keyboard data register

	ifnd	debuggable

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* Initialise custom keyboard packet handler		*
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
initialise_ikbd:
*-------------------------------------------------------*
	lea	key_buffer,a0
	moveq	#128/4-1,d7
.clear_keybd:
	clr.l	(a0)+
	dbf	d7,.clear_keybd
	bsr	flush_ikbd
	move.l	ikbd.w,old_ikbd
	move.l	#ikbd_handler,ikbd.w
	rts

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* Remove custom keyboard packet handler			*
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
remove_ikbd:
*-------------------------------------------------------*
	bsr	flush_ikbd
	move.l	old_ikbd,ikbd.w
	rts

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* Remove unread data from ikbd chip			*
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
flush_ikbd:
*-------------------------------------------------------*
.wl:	tst.b	key_dat.w
	bpl.s	.wl
	move.b	key_ctl.w,d0
	btst	#0,d0
	bne.s	.read
	rts
.read	move.b	key_dat.w,d0
	bra.s	flush_ikbd

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* Keyboard Packet handler				*
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
	txtlong
*-------------------------------------------------------*
ikbd_handler:
*-------------------------------------------------------*
	movem.l	a0/d0-d1,-(sp)

ikbd_loop:
	move.b	key_ctl.w,d0

	btst	#7,d0
	beq.s	ikbd_aq2

	btst	#4,d0
	bne.s	ik_err
	btst	#5,d0
	bne.s	ik_err
	btst	#6,d0
	bne.s	ik_err
	btst	#0,d0
	beq.s	ik_err

	move.b	key_dat.w,d0

	cmp.b	#$ff,d0			; joystick 1 packet
	beq.s	do_joy1
	cmp.b	#$fe,d0			; joystick 0 packet
	beq.s	do_joy0

mouse_event:
	move.b	d0,d1
	and.b	#$fc,d1			; %111110xx = mouse packet 
	cmp.b	#$f8,d1
	bne.s	key_press
	and.b	#3,d0
	move.b	d0,buttons
	move.l	#get_dx,ikbd.w
	bra.s	ikbd_aq

do_joy0:
;	move.l	#get_joy0,ikbd.w
	bra.s	ikbd_aq

do_joy1:
;	move.l	#get_joy1,ikbd.w
	bra.s	ikbd_aq


key_press:
	btst	#7,d0			; test release bit
	seq	d1			; d1.b cleared if release bit set
	and.w	#$7f,d0			; mask off release bit
	lea	key_buffer,a0
	move.b	d1,(a0,d0.w)

ikbd_aq:

	btst	#0,key_ctl.w
	bne	ikbd_loop

ikbd_aq2:
	
	bclr	#6,$fffffa11.w
	movem.l	(sp)+,a0/d0-d1
	rte


ik_err:	move.l	#ikbd_handler,ikbd.w
.ikl:	btst	#0,key_ctl.w
	beq.s	.clr
	move.b	key_dat.w,d0
	bra.s	.ikl
.clr:	bra.s	ikbd_aq

get_dx:
	movem.l	a0/d0-d1,-(sp)

	move.b	key_ctl.w,d0
	btst	#4,d0
	bne.s	ik_err
	btst	#5,d0
	bne.s	ik_err
	btst	#6,d0
	bne.s	ik_err
	btst	#0,d0
	beq.s	ik_err

	move.b	key_dat.w,d0
	ext.w	d0
	add	d0,mouse_dx
	move.l	#get_dy,ikbd.w

	bra.s	ikbd_aq

get_dy:
	movem.l	a0/d0-d1,-(sp)

	move.b	key_ctl.w,d0
	btst	#4,d0
	bne.s	ik_err
	btst	#5,d0
	bne.s	ik_err
	btst	#6,d0
	bne.s	ik_err
	btst	#0,d0
	beq.s	ik_err

	move.b	key_dat.w,d0
	ext.w	d0
	add	d0,mouse_dy
	move.l	#ikbd_handler,ikbd.w

	bra	ikbd_aq

get_joy1:
	move.b	key_dat.w,joy0
	move.l	#ikbd_handler,ikbd.w
	bclr	#6,$fffffa11.w
	rte

get_joy0:
	move.b	key_dat.w,joy1
	move.l	#ikbd_handler,ikbd.w
	bclr	#6,$fffffa11.w
	rte

	elseif

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* Initialise custom keyboard packet handler		*
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
initialise_ikbd:
*-------------------------------------------------------*
	lea		key_buffer,a0
	moveq		#128/4-1,d7
.clear_keybd:
	clr.l		(a0)+
	dbf		d7,.clear_keybd
	bsr		flush_ikbd

	move.w		#34,-(sp)
	trap		#14
	addq.l		#2,sp
	move.l		d0,a0
	move.l		16(a0),old_mousevec
	move.l		#Handle_Mouse,16(a0)

	move.w		#1,-(sp)
	move.w		#14,-(sp)
	trap		#14
	addq.w		#4,sp
	move.l		d0,key_recptr

	rts

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* Remove custom keyboard packet handler			*
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
remove_ikbd:
*-------------------------------------------------------*
	bsr		flush_ikbd
	move.w		#34,-(sp)
	trap		#14
	addq.l		#2,sp
	move.l		d0,a0
	move.l		old_mousevec,16(a0)
	rts

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* Handle mouse packet					*
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
	txtlong
*-------------------------------------------------------*
Handle_Mouse:
*-------------------------------------------------------*
	movem.l		d0/a0,-(sp)
	move.b		(a0)+,d0
	and.b		#3,d0
	move.b		d0,buttons

	move.b		(a0)+,d0
	ext.w		d0
	add.w		d0,mouse_dx

	move.b		(a0)+,d0
	ext.w		d0
	add.w		d0,mouse_dy

	movem.l		(sp)+,d0/a0
	rts

		
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* Flush gem keyboard routine.				*
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
flush_ikbd:
*-------------------------------------------------------*
	bra		empty_buffer

*-------------------------------------------------------*
	txtlong
*-------------------------------------------------------*
read_key:
*-------------------------------------------------------*
	move.w		last_key,d0
	lea		key_buffer,a0
	sf		(a0,d0.w)
	bsr		read_keybuf
	and.w		#$7f,d0
	move.w		d0,last_key
	st		(a0,d0.w)
	rts

*-------------------------------------------------------*
* Init the GEMDOS key buffer reader
*-------------------------------------------------------*
* IOrec structure

		rsreset
ibuf		rs.l	1
ibufsize	rs.w	1	
ibufhd		rs.w	1
ibuftl		rs.w	1

*-------------------------------------------------------*
* Read the GEMDOS key buffer
* returns scancode/ascii value in d0,d1
* or -1 if no key
*-------------------------------------------------------*
	txtlong
*-------------------------------------------------------*
read_keybuf:
*-------------------------------------------------------*
	movem.l	d2-d7/a0-a6,-(sp)

	move.l	key_recptr,a0
	move.w	ibufhd(a0),d1
	move.l	ibuf(a0),a1

	cmp.w	ibuftl(a0),d1
	beq.s	.nokey
	addq.w	#4,d1
	cmp.w	ibufsize(a0),d1
	blt.s	.nomod
	moveq	#0,d1
.nomod
	move.w	d1,ibufhd(a0)
	move.w	d1,ibuftl(a0)
.noinc
	movem.w	(a1,d1.w),d0-d1
	bra.s	.gotkey
.nokey
	moveq	#-1,d0
	moveq	#-1,d1
.gotkey
	movem.l	(sp)+,d2-d7/a0-a6
	rts
	

		endc

*-------------------------------------------------------*
*	Flush keyboard buffer				*
*-------------------------------------------------------*
empty_buffer:
*-------------------------------------------------------*
.bk	push.w		#11
	trap		#1
	addq		#2,sp
	tst.w		d0
	beq.s		.ot
	move.w		#7,-(sp)
	trap		#1
	addq		#2,sp
	bra.s		.bk
.ot	rts

*-------------------------------------------------------*
			bsslong
*-------------------------------------------------------*

old_ikbd:		ds.l	1
old_mousevec:		ds.l	1
key_recptr:		ds.l	1
key_buffer:		ds.b	128

last_key:		ds.w	1
mouse_dx:		ds.w	1
mouse_dy:		ds.w	1

joy0:			ds.b	1
joy1:			ds.b	1
buttons:		ds.b	1

*-------------------------------------------------------*
			txtlong
*-------------------------------------------------------*
