;
; Absolute mode mouse controller.
;
; Written by T.A.King Copyright 1993 Ninth Wave Software
;
; The normal mouse controller is operated in the relative mode. In this
; mode the keyboard processor constantly interrupts the processor for
; every pixel that the mouse moves. In absolute mode the keyboard
; processor keeps quite until it is asked every 1/50th of a second to
; send its x,y and button values. Conclusion ... Much better on program
; speed.
;
	bra	mouse_on
	bra	mouse_off
	bra	set_mouse
mse_packet	
mb	dc.b	0			; mouse button
	dc.b  	0 			; empty byte (not used)
mx	dc.w 	0			; mouse x
my	dc.w 	0 			; mouse y

mouse_on
	movem.l	d0-7/a0-6,-(a7)
	lea	setup(pc),a0	
	bset	#0,(a0)			; set and test setup flag
	bne.s	.done			; already been setup
	lea	initmouse(pc),a0	; point to initiate mouse routine
	move.l	a0,-(a7)
	move	#38,-(a7)		; run it in supervisor mode
	trap	#14
	addq.l	#6,a7
.done	movem.l	(a7)+,d0-7/a0-6
	rts
mouse_off
	movem.l	d0-7/a0-6,-(a7)
	lea	setup(pc),a0	
	bclr	#0,(a0)			; reset and test setup flag
	beq.s	.done			; already been reset
	lea	resmouse(pc),a0		; point to restore mouse routine
	move.l	a0,-(a7)
	move	#38,-(a7)		; run it in supervisor mode
	trap	#14
	addq.l	#6,a7
.done	movem.l	(a7)+,d0-7/a0-6
	rts
initmouse	
	lea	set_abs_mouse(pc),a0
	move.l	a0,-(a7)
	move	#11,-(a7)		
	move	#25,-(a7)		; put mouse in absolute mode
	trap	#14
	addq.l	#8,a7
	move	#34,-(a7)		; get address of IKBD vector table
	trap	#14
	addq.l	#2,a7
	move.l	d0,a0
	add.l	#16,a0			; mouse vector address in table
	lea	oldpak(pc),a1
	move.l	(a0),(a1)		; save original packet handler address
	lea	mousepacket(pc),a1	; address of new packet handler
	move.l	a1,(a0)			; modify vector to point to
	lea	mse_packet(pc),a0	; the new packet handler
	clr	(a0)
	lea	vbl(pc),a0		; install interrupt to call
	move.l	a0,$4d2.w		; keyboard processor every 1/50
	rts	
resmouse
	clr.l	$4d2.w			; kill interrupt
	move.w	#34,-(a7)		; address of IKBD vector table
	trap	#14
	addq.l	#2,a7
	move.l	d0,a0
	add.l	#16,a0			; mouse vector
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
	
; Setmouse to x,y coords and give maximum x and y movement
; ~c:set_mouse%(x,y,xmax,ymax)
set_mouse
	movem.l	d0-7/a0-6,-(a7)
	lea	set_abs_mouse(pc),a0
	lea	mse_packet(pc),a1	
	move	64(a7),d0		; get x
	move	d0,2(a1)		; write new values
	move.b	d0,9(a0)
	move	66(a7),d0		; get y
	move	d0,4(a1)		; write new values
	move.b	d0,11(a0)
	move	68(a7),d0		; get max x
	move.b	d0,2(a0)		; write new value
	lsr	#8,d0
	move.b	d0,1(a0)
	move	70(a7),d0		; get max y
	move.b	d0,4(a0)		; write new value
	lsr	#8,d0
	move.b	d0,3(a0)
	move.l	a0,-(a7)
	move	#11,-(a7)		; write values to the
	move	#25,-(a7)		; keyboard processor
	trap	#14
	addq.l	#8,a7
	movem.l	(a7)+,d0-7/a0-6
	rts

vbl	btst.b	#1,$FFFFFC00.w		; test keyboard busy
	beq.s	vbl			; yes, so loop until it's not
	move.b	#$0d,$FFFFFC02.w	; request mouse packet
	rts

mousepacket	
	movem.l	d0/a0-1,-(a7)		
	lea	mse_packet(pc),a1
	move.b	(a0),d0			; get mouse button from a0
	btst	#0,d0
	beq.s	.t2
	or	#2,(a1)			; right pressed
	bra.s	.t3
.t2	btst	#1,d0
	beq.s	.t3
	and	#1,(a1)			; right released
.t3	btst	#2,d0
	beq.s	.t4
	or	#1,(a1)			; left pressed
	bra.s	.t5
.t4	btst	#3,d0
	beq.s	.t5
	and	#2,(a1)			; left released
.t5	move.b	1(a0),d0		; X movement
	lsl	#8,d0
	move.b	2(a0),d0
	move	d0,2(a1)
	move.b	3(a0),d0		; Y movement
	lsl	#8,d0
	move.b	4(a0),d0
	move	d0,4(a1)
	movem.l	(a7)+,d0/a0-a1
	rts

oldpak 	dc.l	0			; old packet handler address
setup	dc.w	0
set_abs_mouse
	dc.b	9,1,0,0,199,0,$E,0,0,160,0,100
