		section	text


env_c2p:
		move.l	screen_adr2,a0
		move.l	a0,a2
		ifne	hatari
		lea.l	230*49+104(a2),a2
		endc
		ifeq	hatari
		lea.l	224*49+104(a2),a2
		endc
		

		move.l	env_destadr,a1

		lea.l	c2ptable,a4
		move.w	#50-1,d7
.loop:
q		set	0
		rept	13
		moveq.l	#0,d1

		move.w	(a1)+,d1
		lsl.l	#2,d1
		move.l	(a4,d1.l),d1
		movep.l	d1,q(a0)
		movep.l	d1,q(a2)
		moveq.l	#0,d1
		move.w	(a1)+,d1
		lsl.l	#2,d1
		move.l	(a4,d1.l),d1
		movep.l	d1,q+1(a0)
		movep.l	d1,q+1(a2)

q		set	q+8
		endr

		ifne	hatari
		lea.l	230(a0),a0
		lea.l	-230(a2),a2
		endc
		ifeq	hatari
		lea.l	224(a0),a0
		lea.l	-224(a2),a2
		endc
		

		dbra	d7,.loop
		rts
		

		section	text
