	move.l	#0,-(sp)	*supervisor mode
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,sp_usp

	move.w	#$12,-(sp)	*turn off mouse
	move.w	#4,-(sp)
	move.w	#3,-(sp)
	trap	#13
	addq.l	#6,sp

	move.w	#$14,-(sp)	*read joystick
	move.w	#4,-(sp)
	move.w	#3,-(sp)
	trap	#13
	addq.l	#6,sp
	
	

	lea	$118,a0		*spara adressen till interrupt
	move.l	(a0),save_intrpt *vektorn och l„gg in din egen
	move.l	#joy_read,$118	*rutin p† adress $118

	move.w	#0,f”rsta

loop	
	move.b	andra,d2
	
	cmp.b	#$80,d2		*kolla om fire knapp intryckt
	beq	slut	
	btst	#0,d2		*kolla om joystick=upp
	beq	loop

slut	lea	save_intrpt,a0
	move.l	(a0),$118


	move.w	#$08,-(sp)	*mouse on
	move.w	#4,-(sp)
	move.w	#3,-(sp)
	trap	#13
	addq.l	#6,sp 


	move.l	sp_usp,-(sp)
	move	#$20,-(sp)
	trap	#1
	add.l	#6,sp



	move	#0,-(sp)
	trap	#1
	
joy_read:			*om joystick 2 $fe ist„llet f”r $ff
	movem.l	d0-d7/a0-a6,-(sp)
	move.b	$fffffc02.w,d0
	cmp.b	#$ff,d0		*kolla om joystick headern har anl„nt
	bne.s	check		*om inte hoppa till check
	move.b	d0,f”rsta	*om den har kommit l„gg $ff i f”rsta
	bra.s	done
check:
	move.b	f”rsta,d1	*kolla om headern kom f”rra interruptet
	cmp.b	#$ff,d1		
	bne.s	done		*om inte hoppa ut
	move.b	d0,andra	*om den gjorde det s† m†ste detta
	clr.b	f”rsta		*vara joystick data, l„gg i andra
done:	
	movem.l	(sp)+,d0-d7/a0-a6
	move.l	save_intrpt,-(sp)	*hopp till key vektor
	rts
	


sp_usp:	ds.l	1
save_intrpt:	ds.l	1
f”rsta:	ds.b	1
andra:	ds.b	1
