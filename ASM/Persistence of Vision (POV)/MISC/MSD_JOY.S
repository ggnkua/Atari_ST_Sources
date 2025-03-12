kbd_init
	move.l	#key_int,KBD_ISR
	bset.b	#6,IERB
	bset.b	#6,IMRB

	moveq	#$14,d0
	bsr	write_ikbd
	rts


key_int
	move.w	d0,-(sp)
.again
	move.b	KBD_DATA,d0
	cmp.b	#$ff,d0
	beq.s	.joy
.key
	move.b	d0,key_val
.cont
	btst.b	#4,GPIP
	beq.s	.again
.done
	move.w	(sp)+,d0
	rte

.joy
	move.l	#joy_int,KBD_ISR
	btst.b	#4,GPIP
	bne.s	.done
	move.w	(sp)+,d0

joy_int
	move.b	KBD_DATA,joystick
	move.l	#key_int,KBD_ISR
	btst.b	#4,GPIP
	beq	key_int
	rte


write_ikbd
	btst.b	#1,KBD_CNTL
	beq.s	write_ikbd
	move.b	d0,KBD_DATA
	rts


key_val		ds.b	1
joystick	ds.b	1
