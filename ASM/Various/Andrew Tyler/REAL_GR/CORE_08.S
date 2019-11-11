* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Copyright A.Tyler 1991 core_08.s				*
*		Subroutines for eulr_scn, Chapter 12		*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	include core_07.s	previous subroutines

joy_look:
* Change the euler angles etheta and ephi (vtheta and vphi from
* Chapter 10 are same thing)
* Read the joystick and update the variables accordingly
* The data packet containing the FIRE bit (7) and the position
* bits (0-2) is saved in the variable joy_data	
	clr.w	joy_data	
	move.w	#10,d6
ejoy_more:
	bsr	rd_joy		read joystick
	dbf	d6,ejoy_more	give it time to think
	move.w	joy_data,d0	here's the result
	move	d0,d1		save it
	andi.w	#$f0,d0		fire pressed  ?
	bne	ejy_press_fire 	yes
	andi.w	#$f,d1		what direction is the stick?
	bne	ejoy_dr		
	rts			nothing doing
ejoy_dr	lea	ejump_joy,a0	base address
	lsl.w	#2,d1		offset into jump table
	move.l	0(a0,d1.w),a0	the jump address
	jmp	(a0)		go for it	
ejump_joy:
	dc.l	0,eup_jy,edown_jy,0,eleft_jy,eup_left_jy,edown_left_jy
	dc.l	0,eright_jy,eup_right_jy,edown_right_jy
eup_jy	bsr	erot_down	rotate view frame down about vy axis
	rts
edown_jy	bsr	erot_up		rotate up about vy axis
	rts
eleft_jy	bsr	erot_left	rotate left about wx axis
	rts
eright_jy:
	bsr	erot_right	rotate right about wx axis
	rts
eup_left_jy	rts		do nothing for now
edown_left_jy	rts
eup_right_jy	rts
edown_right_jy	rts
ejy_press_fire:
	move.w	#1,fire
	rts

erot_down:
* Rotate down about the yv axis. Decrement ephi (same as vphi)
	move.w	#-5,vphi_inc
	rts

erot_up:
* Rotate up about the yv axis. Increment ephi (same as vphi)
	move.w	#5,vphi_inc		
	rts

erot_left:
* Rotate left about the xw axis . Increment etheta
	move.w	#5,vtheta_inc
	rts

erot_right:
* Rotate right about the xw axis. Decrement etheta
	move.w	#-5,vtheta_inc
	rts

vtran_move:
* move the view transform matrix to the base vectors
* (really just a change of label)
	lea	iv,a0
	lea	jv,a1
	lea	kv,a2
	lea	w_vmatx,a3
	move.w	(a3)+,(a0)+	all	
	move.w	(a3)+,(a0)+	iv
	move.w	(a3)+,(a0)
	move.w	(a3)+,(a1)+	all
	move.w	(a3)+,(a1)+	jv
	move.w	(a3)+,(a1)
	move.w	(a3)+,(a2)+	all
	move.w	(a3)+,(a2)+	kv
	move.w	(a3),(a2)
	rts
