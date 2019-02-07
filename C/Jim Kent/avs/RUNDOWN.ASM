	; :ts=8


	;word_uncompress(s, d, length)
	;	uncompress s of length into d 
	;	with word-run compression
	public _word_uncompress
firstp	set	12
s	set	firstp
d	set	firstp+4
length	set	firstp+8
_word_uncompress
	movem.l  d2/d3,-(sp)
	move.l	s(sp),a0
	move.l	d(sp),a1
	move.l	length(sp),d2

	;bra	zwuc_lp ;DEBUG

wuclp 	ble	zwuc_lp
	move.w	(a0)+,d0
	bmi	diffucl	; it's a uniq run (yuck!) have to branch
	move.w	(a0)+,d1 ; yeah! Get to repeat d1 d0 times
	move.w	d0,d3 ; so set up a "tower" to do it.
	asr.w	#4,d3 ; d3 is number of loops through tower
	and.w	#15,d0 ; d0 is where in tower to start
	add.w	d0,d0 ; 2 bytes/tower element
	neg.w	d0
	jmp	32+same_tower(pc,d0.w)
same_tower
	move.w	d1,(a1)+
	move.w	d1,(a1)+
	move.w	d1,(a1)+
	move.w	d1,(a1)+

	move.w	d1,(a1)+
	move.w	d1,(a1)+
	move.w	d1,(a1)+
	move.w	d1,(a1)+

	move.w	d1,(a1)+
	move.w	d1,(a1)+
	move.w	d1,(a1)+
	move.w	d1,(a1)+

	move.w	d1,(a1)+
	move.w	d1,(a1)+
	move.w	d1,(a1)+
	move.w	d1,(a1)+

	dbra	d3,same_tower
	subq.l	#2,d2
	bra	wuclp
diffucl	and.w	#$7fff,d0	;	mask off hi bit
	sub.l	d0,d2	; subtract count from size to uncompress
	move.w	d0,d3 ; so set up a "tower" to do it.
	asr.w	#4,d3 ; d3 is number of loops through tower
	and.w	#15,d0 ; d0 is where in tower to start
	add.w	d0,d0 ; 2 bytes/tower element
	neg.w	d0
	jmp	32+uniq_tower(pc,d0.w)
uniq_tower	
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+

	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+

	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+

	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+

zdiflp	dbra	d3,uniq_tower
	subq.l	#1,d2
	bra	wuclp
zwuc_lp 
	movem.l  (sp)+,d2/d3
	rts

