	* a0 : adresse ecran
	* a1 : adresse du buffer
	
	move.l pos_buf3,a1
	move.l save_pos3,a2
	move.l (a2),a0
	
n1	set 0	
n2	set 0
	rept 15
	movem.l n1(a1),d0-d7/a2-a3
	movem.l d0-d7/a2-a3,n2(a0)
n1	set n1+40
n2	set n2+160
	endr
	
	rts
	