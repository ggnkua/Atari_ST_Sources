;
; A few assembly language additions for PURE C
; By Mike Watson June 1993
; 
 
		EXPORT	Montype,Vsetscreen,Vsetmode,VgetSize

		MACRO	push.size	reggie
		move.size	reggie,-(a7)
		ENDM	
		
		MACRO	pop.size	reggie
		move.size	(a7)+,reggie
		ENDM

Montype:
		push.l	a2
		move.w	#$59,-(sp)
		trap	#$e
		addq.w	#2,sp
		pop.l	a2
		rts

Vsetscreen:
		push.l	a2
		move.w	d1,-(sp)
		move.w	d0,-(sp)
		pea		(a1)
		pea		(a0)
		move.w	#5,-(sp)
		trap	#$e
		lea		$e(sp),sp
		pop.l	a2
		rts

Vsetmode:
		push.l	a2
		move.w	d0,-(sp)
		move.w	#$58,-(sp)
		trap	#$e
		addq.w	#4,sp
		pop.l	a2
		rts

VgetSize:
		push.l	a2
		move.w	d0,-(a7)
		move.w	#$5b,-(a7)
		trap	#14
		addq.w	#4,a7
		pop.l	a2	
		rts					
		
		
		
		