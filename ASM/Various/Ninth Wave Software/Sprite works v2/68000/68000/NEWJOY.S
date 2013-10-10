		
;
; Joystick interrogation mode.
;
; To be used when using the border removal routines as normal joystick
; mode will cause the border routine to glitch.
;
; Written by T.A.King Copyright 1993 Ninth Wave Software
;

	bra	install_joystick
	bra	reset_joystick

joy_packet	
	dc.b	0			; joystick 0
	dc.b  	0 			; joystick 1

install_joystick
	movem.l	d0-7/a0-6,-(a7)
	lea	setup(pc),a0	
	bset	#0,(a0)			; set and test setup flag
	bne.s	.done			; already been setup
	lea	initjoystick(pc),a0	; point to initiate joystick routine
	move.l	a0,-(a7)
	move	#38,-(a7)		; run it in supervisor mode
	trap	#14
	addq.l	#6,a7
.done	movem.l	(a7)+,d0-7/a0-6
	rts
	
reset_joystick
	movem.l	d0-7/a0-6,-(a7)
	lea	setup(pc),a0		
	bclr	#0,(a0)			; reset and test setup flag
	beq.s	.done			; already been cleared
	lea	resjoystick(pc),a0	; point to restore joystick routine
	move.l	a0,-(a7)
	move	#38,-(a7)		; run it in supervisor mode
	trap	#14
	addq.l	#6,a7
.done	movem.l	(a7)+,d0-7/a0-6
	rts

initjoystick
	move	#$15,-(a7)
	move	#4,-(a7)
	move	#3,-(a7)
	trap	#13			; set joystick interrogation mode
	addq	#6,a7
	move	#34,-(a7)		; get address of IKBD vector table
	trap	#14
	addq.l	#2,a7
	move.l	d0,a0
	add.l	#24,a0			; joystick vector
	lea	oldpak(pc),a1
	move.l	(a0),(a1)	
	lea	joystickpacket(pc),a1
	move.l	a1,(a0)			; install new handler			
	lea	joy_packet(pc),a0	
	clr	(a0)
	lea	vbl(pc),a0		; install interrupt to call
	move.l	a0,$4d2.w		; keyboard processor every 1/50
	rts	

resjoystick
	clr.l	$4d2.w			; kill interrupt
	move.w	#34,-(a7)		; address of IKBD vector table
	trap	#14
	addq.l	#2,a7
	move.l	d0,a0
	add.l	#24,a0			; joystick vector
	move.l	oldpak(pc),(a0)		; restore original pack hndler
	move.w	#128,-(a7)		; reset keyboard processor to
	move.w	#4,-(a7)		; power up state
	move.w	#3,-(a7)
	trap	#13
	addq.l	#6,a7			
	move.w	#1,-(a7)		
	move.w	#4,-(a7)		
	move.w	#3,-(a7)		
	trap	#13
	addq.l	#6,a7
	rts
	
vbl	btst.b	#1,$FFFFFC00.w		; test keyboard busy
	beq.s	vbl			; yes, so loop until it's not
	move.b	#$16,$FFFFFC02.w	; request joystick packet
	rts
	
joystickpacket	
	movem.l	a0-1,-(a7)		
	lea	joy_packet(pc),a1
	move.b	(a0)+,(a1)+		
	move.b	(a0)+,(a1)
	movem.l	(a7)+,a0-a1
	rts
oldpak 	dc.l	0			; old packet handler address
setup	dc.w	0
