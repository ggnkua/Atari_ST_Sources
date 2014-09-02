*
*	JOYSTICK.S	Interrupt-Driven ST Joystick Handler.
*

	.text

	.globl	stick0
	.globl	stick1
	.globl	joystick
	.globl	unstick

*
*	JOYSTICK
*
*	Initialize Interrupt-Driven Joystick Event Handler
*
*	Given:
*		Nothing
*
*	Returns:
*		w/Joystick Handler Installed
*		and Stick0 and Stick1 initialized.
*
*	Register Usage:
*		d0-d2 and a0-a2
*
*	Externals:
*		none
*
joystick:
	move.w	#$12,-(sp)
	move.w	#4,-(sp)
	move.w	#3,-(sp)
	trap	#13
	addq.l	#6,sp			* turn off IKBD MOUSE EVENT REPORTING

	move.w	#0,stick0		* init. both sticks to zero
	move.w	#34,-(sp)
	trap	#14			* KBDVBASE extended BIOS call
	addq.l	#2,sp
	move.l	d0,a0			* a0 = ptr to stucture
	move.l	24(a0),savestik
	move.l	#stickler,24(a0)	* install handler

	move.w	#$14,-(sp)
	move.w	#4,-(sp)
	move.w	#3,-(sp)
	trap	#13
	addq.l	#6,sp			* put IKBD into EVENT REPORTING

	rts

*
*	STICKLER
*
*	Interrupt-driven Joystick Event Handler
*
*	Given:
*		a0 = pointer to joystick event record
*
*	Returns:
*		w/Stick0 or Stick1 updated.
*
*	Register Usage:
*		d0, d1 and a0 altered but saved.
*
*	Externals:
*		none
*
stickler:
	movem.l	d0-d1/a0,-(sp)
	move.b	(a0)+,d1
	and	#1,d1			; d1=joystick which changed
	move.b	(a0,d1),d0		; get different stick reading
	lea	stick0,a0
	move.b	d0,(a0,d1)		; save it
	movem.l	(sp)+,d0-d1/a0
	rts

*
*	UNSTICK
*
*	Restore Mouse Handling (more or less)
*
*	Given:
*		nothing
*
*	Returns:
*		w/mouse re-enabled
*
*	Register Usage:
*		d0-d3 and a0-a3
*
*	Externals:
*		BIOS
*
unstick:
	move.w	#$1a,-(sp)
	move.w	#4,-(sp)
	move.w	#3,-(sp)
	trap	#13
	addq.l	#6,sp			* Disable Joysticks

	move.w	#34,-(sp)
	trap	#14			* KBDVBASE extended BIOS call
	addq.l	#2,sp
	move.l	d0,a0			* a0 = ptr to stucture
	move.l	savestik,24(a0)		* restore old joystick handler

	move.w	#$8,-(sp)
	move.w	#4,-(sp)
	move.w	#3,-(sp)
	trap	#13
	addq.l	#6,sp			* enable IKBD MOUSE POSITION REPORTING
	rts


*
*	Data Storage
*
	.data

savestik:
	.ds.l	1		* old joystick handler address

stick0:	.ds.b	1		* joystick0 reading
stick1:	.ds.b	1		* joystick1 reading
*				bit7 = trigger
*				bit3 = right
*				bit2 = left
*				bit1 = down
*				bit0 = up
	.end
