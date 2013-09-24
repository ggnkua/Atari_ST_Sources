	globl ret0,ret1,ret2,ret3,get_modes,param
get_modes:
		movem.l d0-a6,-(sp)
		move d0,tmp1
		move d1,tmp2
		pea		get_it(pc)
		move.w	#$26,-(a7)
		trap	#14		; Supexec
		addq.l	#6,a7
		movem.l (sp)+,d0-a6
		rts
get_it:
		move.l $5a0,d4
		beq no_cookie
		move.l d4,a0
cookie_loop:
		move.l (a0),d4
		beq no_cookie
		cmp.l #"BLOW",d4
		beq cookie_found
		addq.l #8,a0
		bra cookie_loop
cookie_found:
		addq.l #4,a0
		move.l (a0),a0	; zeiger auf tabele
		move.l a0,d0
		add.l  6+128*5*2*2+4,d0
		move.l d0,param
		move.l 6+128*5*2*2(a0),a0	; zeiger auf set_modes
		move tmp1,d0
		move tmp2,d1
		jsr (a0)		; und ausfuehren
		move d0,ret0
		move d1,ret1
		move d2,ret2
		move d3,ret3
		rts
no_cookie:
		move #0,ret3
		rts
tmp1:	dc 0
tmp2:   dc 0