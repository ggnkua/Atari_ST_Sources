; Falcon demosystem
;
; May 22, 2011
;
; mouse.s

		section	text

mouse_init:	move.w	#$22,-(sp)				;kbdvbase()
		trap	#14					;
		addq.l	#2,sp					;

		move.l	d0,save_kbdvbase			;Save address to addresstable
		move.l	d0,a0					;
		move.l	16(a0),save_mouse			;Mouse packet rout
		move.l	#mouse_rout,16(a0)			;Install own
		rts

mouse_exit:	move.l	save_kbdvbase,a0			;Address to addresstable
		move.l	save_mouse,16(a0)			;Restore old routine
		rts

mouse_rout:	move.b	(a0)+,mousebuttons			;Header (buttons incl.)
		move.b	(a0)+,xmouse				;X
		move.b	(a0),ymouse				;Y
		rts

		section	bss

save_kbdvbase:	ds.l	1					;Address to addresstable
save_mouse:	ds.l	1					;Old mouse routine
xmouse:		ds.w	1					;Relative x coord (signed byte)
ymouse:		ds.w	1					;Relative y coord (signed byte)
mousebuttons:	ds.w	1					;Header and mousebuttons (right=bit0, left=bit1)

		section	text

