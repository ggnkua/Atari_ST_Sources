; (c) The Voice 5
; TFTE
*********************************
* Procedura do stawiania punktu *
*********************************
* Moze dziala - moze nie. 		*
*********************************
* Pamietaj o wl. SUPERVISORA +  *
* podanie punktow + skok bsr    *
*********************************
* Coded by STRYCH				*
*********************************




punkt				*w d0,d1 punkt w a0 adr ekr
	move.l #$f8000,a0	; adr. ekranu STFM 1 MB
	and.l #$0000ffff,d0
	and.l #$0000ffff,d1
	mulu #160,d1
	add.l d1,a0
	moveq.l #16,d3
	moveq.l #3,d4
	move.l d0,d1

	divu d3,d0
*	lsl.l #4,d0
	mulu d3,d0
	sub.l d0,d1
	move.l d0,d2	* w d2 adr
	lsr.l #1,d2

	lea tabela_punktow,a1
	moveq #0,d0
	lsl.l #2,d1

	move.w (a1,d1.w),d0
	move.w 2(a1,d1.w),d1
	add.l d2,a0
	add.l d0,a0
	bset d1,(a0)
	rts


tabela_punktow:

	dc.w 0,7
	dc.w 0,6
	dc.w 0,5
	dc.w 0,4
	dc.w 0,3
	dc.w 0,2
	dc.w 0,1
	dc.w 0,0
	dc.w 1,7
	dc.w 1,6
	dc.w 1,5
	dc.w 1,4
	dc.w 1,3
	dc.w 1,2
	dc.w 1,1
	dc.w 1,0
