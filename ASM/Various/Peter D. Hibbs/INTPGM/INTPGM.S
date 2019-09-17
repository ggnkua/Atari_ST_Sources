;Install interrupt program in vbl queue (at start of pgm)
;ENTRY -
;EXIT  20mS Interrupt vector installed
;      int_add holds vector address

install_int	movem.l	a0-a1/d0-d1,-(sp)

	clr.l	-(sp)	go to supervisor mode
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp	d0=supervisor stack

	move.l	$456,a0	fetch vdu blank vector
install_int1	add.l	#4,a0	next vector
	tst.l	(a0)
	bne	install_int1	find blank vector
	move.l	#intpgm,(a0)	copy routine addr to memory
	move.l	a0,int_add	save interrupt vector

	move.l	d0,-(sp) 	set user mode
	move	#$20,-(sp)
	trap	#1
	add.l	#6,sp

	movem.l	(sp)+,a0-a1/d0-d1
	rts

;Remove interrupt vector and restore vbl queue (at end of pgm)
;ENTRY int_add holds old address of interrupt vector
;EXIT  vbl queue restored

de_install	movem.l	a0-a1/d0-d1,-(sp)

	clr.l	-(sp)	go to supervisor mode
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	move.l	int_add,a0	restore address
	clr.l	(a0)	clr int vector	

	move.l	d0,-(sp)	set user mode
	move	#$20,-(sp)
	trap	#1
	add	#6,sp

	movem.l	(sp)+,a0-a1/d0-d1
	rts

;Interrupt routine (20mS interval)

int_pgm

;Interrupt program goes in here

int_pgm1	rts

int_add	ds.l	1	queue addr
	