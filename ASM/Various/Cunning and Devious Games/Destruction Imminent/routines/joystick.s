	*A:\JOYSTICK.S
	******************************************************
	*   initjoy - joystick controller (corrupts a0/d0)   *
	* Once active returns joystick info in joy0 and joy1 *
	*bit0=up, bit1=down, bit2=left, bit3=right, bit7=fire*
	******************************************************

initjoy	move.w	#34,-(sp)		Function Kbdvbase
	trap	#14		Call XBIOS
	addq.l	#2,sp		Correct stack
	move.l	d0,a0		address of system vectors
	move.l	#jhandler,24(a0)	patch in routine
	move.w	#$12,-(sp)	Turn off mouse
	move.w	#4,-(sp)		Message to IKBD
	move.w	#3,-(sp)		Function number
	trap	#13		Call BIOS
	addq.l	#6,sp		Correct stack
	move.w	#$14,-(sp)	Turn to auto packets
	move.w	#4,-(sp)		Message to IKBD
	move.w	#3,-(sp)		Function number
	trap	#13		Call BIOS
	addq.l	#6,sp		Correct stack
	rts			Return

jhandler	move.b	2(a0),joy0	Store joystick 0
	rts			Return

joy0	dc.b	0		Status of joystick 0