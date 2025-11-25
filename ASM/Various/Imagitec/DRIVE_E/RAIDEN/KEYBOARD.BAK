
; Andys Keyboard routine & Joypad stuff!
read_joypad
	lea	key_pad_info(pc),a0
	move.l	d0,-(sp)
	move.w	#$ff77,d0
.lp	move.w	d0,$ff9202
	move.b	$ff9201,(a0)+
	move.b	$ff9202,(a0)+
	ror.b	#1,d0
	bcs.s	.lp
	move.l	(sp)+,d0
	rts

key_pad_info
	dcb.w	4,-1

;Zero-Pressed

options_pressed
	Moveq	#2,d0
	And.b	key_pad_info(pc),d0
	rts
pause_pressed
	Moveq	#1,d0
	And.b	6+key_pad_info(pc),d0
	rts
fire_a_pressed
	Moveq	#2,d0
	And.b	6+key_pad_info(pc),d0
	rts
fire_b_pressed
	Moveq	#2,d0
	And.b	4+key_pad_info(pc),d0
	rts
fire_c_pressed
	Moveq	#2,d0
	And.b	2+key_pad_info(pc),d0
	rts
direction_pressed
	Moveq	#$f,d0
	And.b	7+key_pad_info(pc),d0
	rts

options_pressed_2
	Moveq	#8,d0
	And.b	key_pad_info(pc),d0
	rts
pause_pressed_2
	Moveq	#4,d0
	And.b	6+key_pad_info(pc),d0
	rts
fire_a_pressed_2
	Moveq	#8,d0
	And.b	6+key_pad_info(pc),d0
	rts
fire_b_pressed_2
	Moveq	#8,d0
	And.b	4+key_pad_info(pc),d0
	rts
fire_c_pressed_2
	Moveq	#8,d0
	And.b	2+key_pad_info(pc),d0
	rts

direction_pressed_2
	move.b	7+key_pad_info(pc),d0
	lsr.b	#4,d0
	rts
	

init_joy
.cfoz	move.b	$fffc00.l,d0
	btst	#0,d0
	beq.s	.ikbd_ok
.wait	btst	#1,$fffc00.l
	beq.s	.wait
	move.b	$fffc02.l,d1
	bra.s	.cfoz
.ikbd_ok
	lea	ikbd_strt,a0
	move	#2,d7
	Bsr	ikbd_send
	lea	ikbd_strm,a0
	move	#ikbd_strml,d7
	Bsr	ikbd_send
	move.l	$118.w,old_118
	Pea	Ikbd_Int(pc)
	Move.l	(sp)+,$118.w
	or.b	#$40,$fffa09.l
	or.b	#$40,$fffa15.l
	bclr	#6,$fffa11.l
	rts

****************************************************************************
* Kill joystick				*
****************************************************************************
no_joy
.cfoz	move.b	$fffc00.l,d0
	btst	#0,d0
	beq.s	.ikbd_ok
.wait	btst	#1,$fffc00.l
	beq.s	.wait
	move.b	$fffc02,d1
	bra.s	.cfoz
.ikbd_ok
	lea	off,a0
	moveq	#offl,d7
	Bsr	ikbd_send
	move.l	old_118(pc),$118.w
	rts
****************************************************************************
* Send a string to the ikbd				*
****************************************************************************
ikbd_send
	lea	$fffc00.l,a1
.loop	move.b	(a0)+,d0
	bsr.s	send_ikbd
	dbf	d7,.loop
	rts
send_ikbd
.wait   btst	#1,(a1)
	beq.s	.wait
	move.b	d0,2(a1)
	rts
****************************************************************************
* Read a byte from the ikbd				*
****************************************************************************
read_ikbd
.wait   btst	#1,(a1)
	beq.s	.wait
	move.b	2(a1),d0
	rts
****************************************************************************
* The interrupt				*
****************************************************************************
ikbd_int
	movem.l	d0-d7/a0-a6,-(sp)
	Or.w	#$500,sr
	bsr	proc_key_int
	bclr	#6,$fffa11.l
	movem.l	(sp)+,d0-d7/a0-a6
	rte

proc_key_int
	lea	$fffc00.l,a1
	move.b	(a1),d6
	btst	#7,d6
	beq.s	.exit
	btst	#0,d6
	beq.s	.skip
	bsr.s	read_keyb
.skip	and.b	#$20,d6
	beq.s	.exit
	move.b	2(a1),d0
.exit	rts

read_keyb
	moveq	#0,d0
	bsr	read_ikbd
	tst.b	packet_bcnt
	bne.s	.get_packet
	cmp.w	#$f6,d0
	bge.s	.start_packet
	move.b	d0,key	  ;store raw keycode
	rts
.start_packet
	move.b	d0,packet_hd    ;packet type.
	sub.w	#$f6,d0
	move.b	.packet_lens(pc,d0),packet_bcnt     ;store length.
	rts
.packet_lens	dc.b	7,5,2,2,2,2,6,2,1,1
	even
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
	dc.l	drts,drts,drmouse,drmouse,drmouse,drmouse,drts,drts,drts,drts
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
	rts

port0		dc.b	0
port1		dc.b	0
packet_hd	ds.b	8
packet_bcnt	dc.b	0
key		ds.b	1
		even
old_118		ds.l	1
ikbd_strJ	dc.b    $12,$14         ;turn on joystick.
ikbd_strJL	equ	*-ikbd_strJ-1
ikbd_strm	dc.b	$08,$0b,1,1
ikbd_strml	equ	*-ikbd_strm-1
off		dc.b    $08
offl		equ	*-off-1
ikbd_strt	dc.b	$0b,$ff,$ff
		even
mxdelta		ds.w	1
mydelta		ds.w	1
mbuts		ds.w	1

palsave		ds.l	256

modecode	ds.w	1
scr1		ds.l	1
scr2		ds.l	1
scrc		ds.l	1
scrs		ds.l	1
tbs		ds.l	5
	Even
