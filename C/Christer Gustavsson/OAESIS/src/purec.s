	XDEF link_in
	XDEF link_remove
	XDEF set_stack
	XDEF newmvec
	XDEF newbvec
	XDEF newtvec
	XDEF get_stack
	XDEF vdicall
	XDEF accstart

	XREF h_aes_call
	XREF oldbvec
	XREF oldmvec
	XREF Moudev_handler

	TEXT
	
myxgemdos:
	cmp.w		#$c8,d0
	bne		retaddr

	movem.l	d0-d7/a0-a6,-(sp)
	move.l	d1,a0
	jsr		h_aes_call
	movem.l	(sp)+,d0-d7/a0-a6

	rte
	
retaddr:
	jmp		link_in;

link_in:
	move.l	$88,retaddr+2;
	move.l	#myxgemdos,$88
	rts;

link_remove:
	move.l	retaddr+2,$88;
	rts;


set_stack:
	move.l	(sp),-(a0)
	move.l	a0,sp
	rts

newmvec:
	move.l sp,newstack+800
	lea newstack+800,sp
	movem.l	d0-d2/a0-a2,-(sp)
	lea     mmov + 4(pc),a0
	move.w	d1,(a0)+ 	; pass position
	move.w  d0,(a0)
	lea.l   -6(a0),a0
	jsr	Moudev_handler
	movem.l	(sp)+,d0-d2/a0-a2
	move.l (sp),sp
	rts

newbvec:
	move.l sp,newstack+800
	lea newstack+800,sp
	movem.l	d0-d2/a0-a2,-(sp)
	lea     mbut+6(pc),a0
	move.w	d0,(a0) 	; pass buttons
	lea.l   -6(a0),a0
	jsr	Moudev_handler
	movem.l	(sp)+,d0-d2/a0-a2
	move.l  (sp),sp
	rts

newtvec:
	move.l sp,newstack+800
	lea newstack+800,sp
	movem.l	d0-d2/a0-a2,-(sp)
	lea.l   mtim,a0
	jsr	Moudev_handler
	movem.l	(sp)+,d0-d2/a0-a2
	move.l  (sp),sp
	rts

vdicall:
	move.l a0,d1
	move.l #$73,d0
	trap   #2
	rts

accstart:
	move.l 4(sp),a0
	move.l 16(a0),a1
	move.l a1,8(a0)
	add.l  12(a0),a1
	move.l a1,16(a0)
	move.l 8(a0),a1
	jmp (a1)

VsetMode:
	move.w d0,-(sp)
	move.w #$58,-(sp)
	trap   #14
	addq.l #4,sp
	rts
		
	.even
mmov:
	dc.w 0,2,0,0
mbut:
	dc.w 0,1,1,0
mtim:
	dc.w 0,0,0,20
	
newstack:
	ds.l 201
