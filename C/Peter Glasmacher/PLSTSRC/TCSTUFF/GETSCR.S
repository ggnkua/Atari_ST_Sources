		globl getscreen,malloc
getscreen:
		move.l	#$3fff,d0
		jsr		malloc
		move.l	a0,d0
		beq		nocore
		add.l	#$100,d0
		and.l	#$ffffff00,d0
		move.l	d0,a0
		rts
nocore:
		clr.l	a0
		rts					
	