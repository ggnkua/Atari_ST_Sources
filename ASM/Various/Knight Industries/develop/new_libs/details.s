setDetails
	rsrc_gaddr	#0,#DETAILS
	move.l	addrout,a0

	rsrc_gaddr	#0,#ABOUTBOX
	move.l	addrout,a1

	move.l	#URL*24,d0
	move.l	a0,a2
	add.l	d0,a2
	move.l	objectSpec(a2),a2

	move.l	#MAIL*24,d0
	move.l	a0,a3
	add.l	d0,a3
	move.l	objectSpec(a3),a3

	move.l	#PUTURL*24,d0
	move.l	a1,a4
	add.l	d0,a4
	move.l	objectSpec(a4),a4

	move.l	#PUTMAIL*24,d0
	move.l	a1,a5
	add.l	d0,a5
	move.l	objectSpec(a5),a5

	move.l	a2,(a4)
	move.l	a3,(a5)

	rts