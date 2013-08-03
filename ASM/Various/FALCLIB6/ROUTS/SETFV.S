*
* SETFV.S
*
*	@setfv
*	 Sets the falcon video registers. The data that is
*	 written to the video registers must be a .FV (Falcon Video)
*	 file. Supervisor only.
* In	 a0.l=adr. to Falcon Video data
* Out	 d0.l: 0=no error  -1=error, no FV data  -2=error, wrong monitor (not used yet)
*	 (destroys a0-a1)
*
*	@savefv
*	 Saves the falcon video registers to memory. Supervisor only.
*	 (destroys a0-a1)
*
*	@resorefv
*	 Restores the saved falcon video registers. Supervisor only.
*	 (destroys a0-a1)
*


@setfv		cmp.l	#'FVD2',(a0)+	4 bytes header
		bne	.error
		
.ready		addq.l	#2,a0
		move.l	$70,-(sp)
		move	sr,-(sp)
		move.l	#.vbl,$70
		move	#$2300,sr
		
		move.l	$466,d0
.wait		cmp.l	$466,d0
		beq	.wait
		
		move.l	(a0)+,$ff820e	offset & vwrap
		move.w	(a0)+,$ff8266	spshift
		move.l	#$ff8282,a1	horizontal control registers
.loop1		move	(a0)+,(a1)+
		cmp.l	#$ff8292,a1
		bne	.loop1
		move.l	#$ff82a2,a1	vertical control registers
.loop2		move	(a0)+,(a1)+
		cmp.l	#$ff82ae,a1
		bne	.loop2
		move	(a0)+,$ff82c2	video control
		move	(a0)+,$ff82c0	video clock
		addq.l	#1,a0
		move.b	(a0)+,$ff820a	video sync mode
		move	(sp)+,sr
		move.l	(sp)+,$70
		moveq	#0,d0
		rts
.error		moveq	#-1,d0
		rts
.wrongmon	moveq	#-2,d0
		rts
.sm124		cmp.b	#0,(a0)
		bne	.wrongmon
		bra	.ready
.vga		cmp.b	#2,(a0)
		bne	.wrongmon
		bra	.ready
.vbl		addq.l	#1,$466
		rte
		

@savefv		lea	FVbuffer1298,a1
		move.l	#'FVD2',(a1)+	4 bytes header
		move.b	$ff8006,(a1)+	monitor type
		move.b	$ff820a,(a1)+	sync
		move.l	$ff820e,(a1)+	offset & vwrap
		move.w	$ff8266,(a1)+	spshift
		move.l	#$ff8282,a0	horizontal control registers
.loop1		move	(a0)+,(a1)+
		cmp.l	#$ff8292,a0
		bne	.loop1
		move.l	#$ff82a2,a0	vertical control registers
.loop2		move	(a0)+,(a1)+
		cmp.l	#$ff82ae,a0
		bne	.loop2
		move	$ff82c2,(a1)+	video control
		move	$ff82c0,(a1)+	video clock
		move.b	$ff8260,(a1)+	shifter resolution
		move.b	$ff820a,(a1)+	video sync mode
		rts
		
@restorefv	move.l	#FVbuffer1298,a0
		bsr	@setfv
		rts


FVbuffer1298	ds.w	24

