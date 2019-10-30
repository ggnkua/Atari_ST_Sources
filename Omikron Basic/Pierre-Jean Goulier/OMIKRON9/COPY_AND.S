;
; AND logique entre 2 ‚crans. R‚sultat dans un 3Šme.
; Appel du Basic : Call Copy_And(L Ecran_1, L Ecran_2, L Ecran_3)
;
	move.l	4(sp),a0
	move.l	8(sp),a1
	move.l	12(sp),a2
	move	#199,d0
loop:	rept	40
	move.l	(a0)+,d1
	and.l	(a1)+,d1
	move.l	d1,(a2)+
	endr
	dbra	d0,loop
	rts
	