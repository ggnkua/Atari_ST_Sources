

debut	equ	1356-36-160*4-16*24	* don't touch dis !!

tab230:	ds.l	1
tabpred:	ds.l	1

restore:
	move.l	ptrestore11,a4
	move.l	(a4)+,a2

st	set	14*230
	rept	15
	movem.l	(a4)+,d1-d4
	movem.l	d1-d4,st(a2)
st	set	st-230
	endr


	move.l	ptrestore21,a4
	move.l	(a4)+,a2

st	set	14*230
	rept	15
	movem.l	(a4)+,d1-d4
	movem.l	d1-d4,st(a2)
st	set	st-230
	endr

	move.l	ptrestore31,a4
	move.l	(a4)+,a2

st	set	14*230
	rept	15
	movem.l	(a4)+,d1-d4
	movem.l	d1-d4,st(a2)
st	set	st-230
	endr

	move.l	ptrestore41,a4
	move.l	(a4)+,a2

st	set	14*230
	rept	15
	movem.l	(a4)+,d1-d4
	movem.l	d1-d4,st(a2)
st	set	st-230
	endr

	move.l	ptrestore51,a4
	move.l	(a4)+,a2

st	set	14*230
	rept	15
	movem.l	(a4)+,d1-d4
	movem.l	d1-d4,st(a2)
st	set	st-230
	endr

	move.l	ptrestore61,a4
	move.l	(a4)+,a2

st	set	14*230
	rept	15
	movem.l	(a4)+,d1-d4
	movem.l	d1-d4,st(a2)
st	set	st-230
	endr

	move.l	ptrestore71,a4
	move.l	(a4)+,a2

st	set	14*230
	rept	15
	movem.l	(a4)+,d1-d4
	movem.l	d1-d4,st(a2)
st	set	st-230
	endr

	move.l	ptrestore81,a4
	move.l	(a4)+,a2

st	set	14*230
	rept	15
	movem.l	(a4)+,d1-d4
	movem.l	d1-d4,st(a2)
st	set	st-230
	endr

	move.l	ptrestore91,a4
	move.l	(a4)+,a2

st	set	14*230
	rept	15
	movem.l	(a4)+,d1-d4
	movem.l	d1-d4,st(a2)
st	set	st-230
	endr

	move.l	ptrestore101,a4
	move.l	(a4)+,a2

st	set	14*230
	rept	15
	movem.l	(a4)+,d1-d4
	movem.l	d1-d4,st(a2)
st	set	st-230
	endr


sprite:
	move.w	#%1111111111110000,d7
	lea	tab230,a5
	move.l	ecr1,a2
	adda.w	#debut,a2
	move.l	a2,usp
	

	move.w	posx1,d1
	move.w	posy1,d2


	move.l	a5,a3
	add.w	d2,d2
	add.w	d2,d2
	adda.w	d2,a3
	move.l	(a3),d2
	add.l	d2,a2

	move.w	d1,d2

	and.w	d7,d2	* 8
	lsr.w	#1,d2		* 8
	adda.w	d2,a2


	move.l	ptrestore11,a4
	move.l	a2,(a4)+
	adda.w	#15*16,a4
	
*	a2=fond
*	a3=sprites
*	a4=sauve fond


st	set	0
	rept	15
	movem.l	st(a2),d1-d4	* 12+8*4=	34
	movem.l	d1-d4,-(a4)	* 8+8*4=	40
st	set	st+230
	endr


	move.w	posx2,d1
	move.w	posy2,d2

	move.l	usp,a2

	move.l	a5,a3
	add.w	d2,d2
	add.w	d2,d2
	adda.w	d2,a3
	move.l	(a3),d2
	add.l	d2,a2

	move.w	d1,d2
	and.w	d7,d2	* 8
	lsr.w	#1,d2		* 8
	adda.w	d2,a2


	move.l	ptrestore21,a4
	move.l	a2,(a4)+
	adda.w	#15*16,a4
	
*	a2=fond
*	a3=sprites
*	a4=sauve fond


st	set	0
	rept	15
	movem.l	st(a2),d1-d4	* 12+8*4=	34
	movem.l	d1-d4,-(a4)	* 8+8*4=	40
st	set	st+230
	endr

	move.w	posx3,d1
	move.w	posy3,d2

	move.l	usp,a2

	move.l	a5,a3
	add.w	d2,d2
	add.w	d2,d2
	adda.w	d2,a3
	move.l	(a3),d2
	add.l	d2,a2

	move.w	d1,d2
	and.w	d7,d2	* 8
	lsr.w	#1,d2		* 8
	adda.w	d2,a2


	move.l	ptrestore31,a4
	move.l	a2,(a4)+
	adda.w	#15*16,a4
	
*	a2=fond
*	a3=sprites
*	a4=sauve fond


st	set	0
	rept	15
	movem.l	st(a2),d1-d4	* 12+8*4=	34
	movem.l	d1-d4,-(a4)	* 8+8*4=	40
st	set	st+230
	endr

	move.w	posx4,d1
	move.w	posy4,d2

	move.l	usp,a2

	move.l	a5,a3
	add.w	d2,d2
	add.w	d2,d2
	adda.w	d2,a3
	move.l	(a3),d2
	add.l	d2,a2

	move.w	d1,d2
	and.w	d7,d2	* 8
	lsr.w	#1,d2		* 8
	adda.w	d2,a2


	move.l	ptrestore41,a4
	move.l	a2,(a4)+
	adda.w	#15*16,a4
	
*	a2=fond
*	a3=sprites
*	a4=sauve fond


st	set	0
	rept	15
	movem.l	st(a2),d1-d4	* 12+8*4=	34
	movem.l	d1-d4,-(a4)	* 8+8*4=	40
st	set	st+230
	endr

	move.w	posx5,d1
	move.w	posy5,d2

	move.l	usp,a2

	move.l	a5,a3
	add.w	d2,d2
	add.w	d2,d2
	adda.w	d2,a3
	move.l	(a3),d2
	add.l	d2,a2

	move.w	d1,d2
	and.w	d7,d2	* 8
	lsr.w	#1,d2		* 8
	adda.w	d2,a2


	move.l	ptrestore51,a4
	move.l	a2,(a4)+
	adda.w	#15*16,a4
	
*	a2=fond
*	a3=sprites
*	a4=sauve fond


st	set	0
	rept	15
	movem.l	st(a2),d1-d4	* 12+8*4=	34
	movem.l	d1-d4,-(a4)	* 8+8*4=	40
st	set	st+230
	endr

	move.w	posx6,d1
	move.w	posy6,d2

	move.l	usp,a2

	move.l	a5,a3
	add.w	d2,d2
	add.w	d2,d2
	adda.w	d2,a3
	move.l	(a3),d2
	add.l	d2,a2

	move.w	d1,d2
	and.w	d7,d2	* 8
	lsr.w	#1,d2		* 8
	adda.w	d2,a2


	move.l	ptrestore61,a4
	move.l	a2,(a4)+
	adda.w	#15*16,a4
	
*	a2=fond
*	a3=sprites
*	a4=sauve fond


st	set	0
	rept	15
	movem.l	st(a2),d1-d4	* 12+8*4=	34
	movem.l	d1-d4,-(a4)	* 8+8*4=	40
st	set	st+230
	endr

	move.w	posx7,d1
	move.w	posy7,d2

	move.l	usp,a2

	move.l	a5,a3
	add.w	d2,d2
	add.w	d2,d2
	adda.w	d2,a3
	move.l	(a3),d2
	add.l	d2,a2

	move.w	d1,d2
	and.w	d7,d2	* 8
	lsr.w	#1,d2		* 8
	adda.w	d2,a2


	move.l	ptrestore71,a4
	move.l	a2,(a4)+
	adda.w	#15*16,a4
	
*	a2=fond
*	a3=sprites
*	a4=sauve fond


st	set	0
	rept	15
	movem.l	st(a2),d1-d4	* 12+8*4=	34
	movem.l	d1-d4,-(a4)	* 8+8*4=	40
st	set	st+230
	endr

	move.w	posx8,d1
	move.w	posy8,d2

	move.l	usp,a2

	move.l	a5,a3
	add.w	d2,d2
	add.w	d2,d2
	adda.w	d2,a3
	move.l	(a3),d2
	add.l	d2,a2

	move.w	d1,d2
	and.w	d7,d2	* 8
	lsr.w	#1,d2		* 8
	adda.w	d2,a2


	move.l	ptrestore81,a4
	move.l	a2,(a4)+
	adda.w	#15*16,a4
	
*	a2=fond
*	a3=sprites
*	a4=sauve fond


st	set	0
	rept	15
	movem.l	st(a2),d1-d4	* 12+8*4=	34
	movem.l	d1-d4,-(a4)	* 8+8*4=	40
st	set	st+230
	endr

	move.w	posx9,d1
	move.w	posy9,d2

	move.l	usp,a2

	move.l	a5,a3
	add.w	d2,d2
	add.w	d2,d2
	adda.w	d2,a3
	move.l	(a3),d2
	add.l	d2,a2

	move.w	d1,d2
	and.w	d7,d2	* 8
	lsr.w	#1,d2		* 8
	adda.w	d2,a2


	move.l	ptrestore91,a4
	move.l	a2,(a4)+
	adda.w	#15*16,a4
	
*	a2=fond
*	a3=sprites
*	a4=sauve fond


st	set	0
	rept	15
	movem.l	st(a2),d1-d4	* 12+8*4=	34
	movem.l	d1-d4,-(a4)	* 8+8*4=	40
st	set	st+230
	endr

	move.w	posx10,d1
	move.w	posy10,d2

	move.l	usp,a2

	move.l	a5,a3
	add.w	d2,d2
	add.w	d2,d2
	adda.w	d2,a3
	move.l	(a3),d2
	add.l	d2,a2

	move.w	d1,d2
	and.w	d7,d2	* 8
	lsr.w	#1,d2		* 8
	adda.w	d2,a2


	move.l	ptrestore101,a4
	move.l	a2,(a4)+
	adda.w	#15*16,a4
	
*	a2=fond
*	a3=sprites
*	a4=sauve fond


st	set	0
	rept	15
	movem.l	st(a2),d1-d4	* 12+8*4=	34
	movem.l	d1-d4,-(a4)	* 8+8*4=	40
st	set	st+230
	endr


ptrestore11:	ds.l	1
ptrestore21:	ds.l	1
ptrestore31:	ds.l	1
ptrestore41:	ds.l	1
ptrestore51:	ds.l	1
ptrestore61:	ds.l	1
ptrestore71:	ds.l	1
ptrestore81:	ds.l	1
ptrestore91:	ds.l	1
ptrestore101:	ds.l	1


posx1:	ds.w	1
posy1:	ds.w	1
posx2:	ds.w	1
posy2:	ds.w	1
posx3:	ds.w	1
posy3:	ds.w	1
posx4:	ds.w	1
posy4:	ds.w	1
posx5:	ds.w	1
posy5:	ds.w	1
posx6:	ds.w	1
posy6:	ds.w	1
posx7:	ds.w	1
posy7:	ds.w	1
posx8:	ds.w	1
posy8:	ds.w	1
posx9:	ds.w	1
posy9:	ds.w	1
posx10:	ds.w	1
posy10:	ds.w	1

ecr1:	ds.l	1
 	end
