		TEXT

init_gesMem
	move.l #seg1,d0
		
	; efface 5 flag
	clr.l segflag
	sf.b segflag+4

	clr.w d0
	lea segptr,a0
	moveq #1,d1
	swap d1
	move.l d0,(a0)+
	add.l d1,d0
	move.l d0,(a0)+
	add.l d1,d0
	move.l d0,(a0)+
	add.l d1,d0
	move.l d0,(a0)+
	add.l d1,d0
	move.l d0,(a0)+

	rts

get64k

	movem.l d0/d1/a1,-(sp)
	lea segptr,a0
	lea segflag,a1
	moveq #4,d1				; 5 segment de 64k

.looptest
	tst.b (a1)+
	beq.s .match
	addq.l #4,a0
	dbf d1,.looptest
	moveq #-1,d0
	move.l d0,a0
	bra.s .fin
.match
	move.l (a0),a0
	st.b -1(a1)
.fin
	movem.l (sp)+,d0/d1/a1
	rts

free64k:
	movem.l d1/d2/d3/a1/a2,-(sp)
; d0 = adresse seg64k qui doit matché une des adresse de segptr
  ;pas de test si >5
	moveq #3,d2
 	lea segptr,a1
 	lea segflag,a2
 	moveq #0,d3
 	bra.s .2
.loop
	addq.w #1,d3
.2	move.l (a1)+,d1
 	cmp.l d0,d1
 	beq.s .match
 	dbf d2,.loop
	movem.l (sp)+,d1/d2/d3/a1/a2
 	rts
.match
	add.w d3,a2
	sf.b (a2)
	movem.l (sp)+,d1/d2/d3/a1/a2
	rts

	BSS

segptr
	ds.l 5
segflag
	ds.b 5
	even

	ds.b 65536
seg1
	ds.l 16384
	ds.l 16384
	ds.l 16384
	ds.l 16384		256+64 = 320k
	ds.l 16384    256+128 =384k

