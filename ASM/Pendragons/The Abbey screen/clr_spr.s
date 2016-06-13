	* a0 : adresse ecran
	* a1 : adresse du buffer
	
	move.l pos_buf1,a1
	move.l save_pos,a2
	move.l (a2),a0
	
n1	set 0	
n2	set 0
	rept 35
	movem.l n1(a1),d0-d5
	movem.l d0-d5,n2(a0)
n1	set n1+24
n2	set n2+160
	endr
	
	rts
	