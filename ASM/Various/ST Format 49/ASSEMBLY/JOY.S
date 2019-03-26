*Example joystick handler
*The handler itself is found at j_handler
	include	gmdosmac.i
	include	xbiosmac.i
	include	biosmac.i
	Kbdvbase	This tells us where the IKBD vectors are

	move.l	d0,a3		address of system vectors
	Supexec	#install_j_handler	run the joystick handler
					*installation routine
	Bconout	#$15,#4		Tell the IKBD we will request
				*packets
loop
	Cconis	
	cmp.w	#0,d0
	bne	exit
********************************
*The important call
*this requests a joystick packet from the IKBD
	Bconout	#$16,#4
********************************
	move.w	j_event,d3
	beq	loop
	btst	#0,d3
	beq	not_up
	Bconout	#'u',#2
not_up	btst	#1,d3
	beq	not_down
	Bconout	#'d',#2
not_down
	btst	#2,d3
	beq	not_left
	Bconout	#'l',#2
not_left
	btst	#3,d3
	beq	not_right
	Bconout	#'r',#2
not_right
	btst	#7,d3
	beq	loop
	Bconout	#'f',#2
	bra	loop
exit	
	Bconout	#$8,#4
	Supexec	#remove_j_handler
	Pterm	#0

install_j_handler
	lea	24(a3),a3					move to joystick vector
	move.l	a3,j_vector			store the address of the vector
	move.l	(a3),old_packet				store the old vector
	move.l	#j_handler,(a3)			patch in the new one
	rts

remove_j_handler
	move.l	j_vector,a3
	move.l	old_packet,(a3)				put the old joystick handler back
	rts
	
j_handler
	move.w	d0,-(sp)
	clr.w	d0
	move.b	1(a0),d0
	move.w	d0,j_event
	clr.w	d0
	
*The following is only needed 
*if you have a second joystick in the 
*mouse port
	move.b	(a0),d0	
	move.w	d0,j2_event
	move.w	(sp)+,d0
*********************************	

	rts
	bss

j_vector	ds.l	1
old_packet	ds.l	1
j_event		ds.w	1
j2_event	ds.w	1

