
	a2=fond
	a3=sprites
	a4=sauve fond


st	set	0
	rept	16
	movem.l	st(a2),d1-d4	* 12+8*4=	34
	movem.l	d1-d4,-(a4)	* 8+8*4=	40
	and.l	(a3),d1		* 	16
	and.l	(a3)+,d2		*	16
	or.l	(a3)+,d1		*	16
	or.l	(a3)+,d2		*	16
	and.l	(a3),d3		*	16
	and.l	(a3)+,d4		*	16
	or.l	(a3)+,d3		*	16
	or.l	(a3)+,d4		*	16
	movem.l	d1-d4,st(a2)	*	40 = 242
st	set	st+230
	endr
	
