*************************************************************************
* ST keyboard handler 							*
*************************************************************************
* NB:                       *
* This routine handles ALL  *
* packet types              *
*****************************
*************************************************************************
* Initialize joystick							*
*************************************************************************
init_joy
.cfoz
	move.b	$fffc00,d0
	btst	#0,d0
	beq	.ikbd_ok
.wait
	btst	#1,$fffc00
	beq	.wait
	move.b	$fffc02,d1
	bra	.cfoz
.ikbd_ok
	lea	ikbd_strt,a0
	move	#2,d7
	jsr	ikbd_send
	lea	ikbd_strm,a0
	move	#ikbd_strmL,d7
	jsr	ikbd_send
	move.l	$118,old_118
	move.l	#ikbd_int,$118
	or.b	#$40,$fffa09
	or.b	#$40,$fffa15
	bclr	#6,$fffa11
	rts
****************************************************************************
* Kill joystick				*
****************************************************************************
no_joy
	lea	off,a0
	moveq	#offl,d7
	jsr	ikbd_send
	move.l	old_118,$118
	rts
****************************************************************************
* Send a string to the ikbd				*
****************************************************************************
ikbd_send
	lea	$fffc00,a1
.loop
	move.b	(a0)+,d0
	bsr.s	send_ikbd
	dbf	d7,.loop
	rts
send_ikbd
.wait   
	btst	#1,(a1)
	beq.s	.wait
	move.b	d0,2(a1)
	rts
****************************************************************************
* Read a byte from the ikbd				*
****************************************************************************
read_ikbd
.wait   
	btst	#1,(a1)
	beq.s	.wait
	move.b	2(a1),d0
	rts
****************************************************************************
* The interrupt				*
****************************************************************************
ikbd_int
	movem.l	d0-d7/a0-a6,-(sp)
	move	sr,d0
	and	#$f8ff,d0
	or	#$500,d0
	move	d0,sr
	bclr	#6,$fffa11
	bsr	proc_key_int
	movem.l	(sp)+,d0-d7/a0-a6
	rte
proc_key_int
	lea	$fffc00,a1
	move.b	(a1),d6
	btst	#7,d6
	beq.s	.exit
	btst	#0,d6
	beq.s	.skip
	bsr.s	read_keyb
.skip
	and.b	#$20,d6
	beq.s	.exit
	move.b	2(a1),d0
.exit
	rts
read_keyb
	moveq	#0,d0
	bsr	read_ikbd
	tst.b	packet_bcnt
	bne.s	.get_packet
	cmp	#$f6,d0
	bge.s	.start_packet
	move.b	d0,key	  ;store raw keycode
	rts
.start_packet
	move.b	d0,packet_hd    ;packet type.
	sub	#$f6,d0
	lea	packet_lens,a0
	move.b	(a0,d0),packet_bcnt     ;store length.
	rts
.get_packet
	moveq	#0,d1
	move.b	packet_bcnt,d1
	lea	packet_hd,a0
	move.b	d0,(a0,d1)
	subq.b	#1,packet_bcnt
	beq.s	.do_packet
	rts
.do_packet
	moveq	#0,d0
	move.b	packet_hd,d0
	sub	#$f6,d0
	add	d0,d0
	add	d0,d0
	move.l	.jumper(pc,d0),a6
	lea	packet_hd,a0
	jmp	(a6)
.jumper 	
	dc.l	drts,damouse,drmouse,drmouse,drmouse,drmouse,dtime,djoy2,djoy0,djoy1
drmouse
	move.b	(a0),d0
	and	#3,d0
	move	d0,mbuts
	move.b	2(a0),d0
	ext	d0
	add	d0,mxdelta
	move.b	1(a0),d0
	ext	d0
	add	d0,mydelta
drts
	Bsr	Do_Mouse_Bound
	rts
damouse
	rts
djoy0
	move.b	1(a0),port0
	rts
djoy1
	move.b	1(a0),port1
	rts
djoy2
	move.b	1(a0),d2
	move.b	2(a0),d0

	move	d0,d1
	and	#$f,d1
	and	#$f0,d0
	lsr	#4,d0
	btst	#0,d2
	beq.s	.1
	bset	#7,d0
.1
	btst	#1,d2
	beq.s	.2
	bset	#7,d1
.2
	move.b	d0,port0
	move.b	d1,port1
	rts
dtime
	rts

port0		dc.b	0
port1		dc.b	0
packet_lens	dc.b	7,5,2,2,2,2,6,2,1,1
packet_hd	ds.b	8
packet_bcnt	dc.b	0
key		ds.b	1
		even
old_118		ds.l	1
ikbd_strJ	dc.b    $12,$14         ;turn on joystick.
ikbd_strJL	equ	*-ikbd_strJ-1
ikbd_strm	dc.b	$08,$0b,1,1
ikbd_strml	equ	*-ikbd_strm-1
off		dc.b    $0a
;		dc	320,200
offl		equ	*-off-1
ikbd_strt	dc.b	$0b,$ff,$ff
		even
mxdelta		ds	1
mydelta		ds	1
Prev_MouseXy	Ds.w	2
mbuts		ds	1
