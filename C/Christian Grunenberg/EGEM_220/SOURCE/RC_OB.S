
	globl rc_equal,rc_copy,rc_intersect,rc_inside,rc_grect_to_array,rc_array_to_grect
	globl vq_gdos

g_x 		= 0
g_y 		= 2
g_w 		= 4
g_h 		= 6

xmin1		= -16
ymin1		= -14
xmin2		= -12
ymin2		= -10
xmax1		= -8
ymax1		= -6
xmax2		= -4
ymax2		= -2

			TEXT

MODULE vq_gdos
			pea		(a2)
			moveq.l	#-2,d0
			trap	#2
			addq.l	#2,d0
			move.l	(sp)+,a2
			rts
ENDMOD

MODULE rc_equal
			cmpm.l	(a0)+,(a1)+
			bne.b	notequal

			cmpm.l	(a0)+,(a1)+
			beq.b	equal

notequal:	moveq.l #0,d0
			rts

equal:		moveq.l #1,d0
			rts
ENDMOD

MODULE rc_copy
			move.l	(a0)+,(a1)+
			move.l	(a0),(a1)
			moveq.l	#0,d0
			rts
ENDMOD

MODULE rc_intersect
			link	a6,#-16
			move.w	g_y(a0),d0
			cmp.w	g_y(a1),d0
			bge.b	skip

			move.l	g_x(a0),xmin1(a6)

			move.w	g_x(a0),d0
			add.w	g_w(a0),d0
			move.w	d0,xmax1(a6)

			move.w	g_y(a0),d0
			add.w	g_h(a0),d0
			move.w	d0,ymax1(a6)
			
			move.l	g_x(a1),xmin2(a6)

			move.w	g_x(a1),d0
			add.w	g_w(a1),d0
			move.w	d0,xmax2(a6)

			move.w	g_y(a1),d0
			add.w	g_h(a1),d0
			move.w	d0,ymax2(a6)
			bra.b	skp

skip:		move.l	g_x(a0),xmin2(a6)

			move.w	g_x(a0),d0
			add.w	g_w(a0),d0
			move.w	d0,xmax2(a6)

			move.w	g_y(a0),d0
			add.w	g_h(a0),d0
			move.w	d0,ymax2(a6)

			move.l	g_x(a1),xmin1(a6)

			move.w	g_x(a1),d0
			add.w	g_w(a1),d0
			move.w	d0,xmax1(a6)

			move.w	g_y(a1),d0
			add.w	g_h(a1),d0
			move.w	d0,ymax1(a6)

skp:		move.w	ymin2(a6),d0
			cmp.w	ymax1(a6),d0
			bge.b	ret

			move.w	xmin1(a6),d0
			cmp.w	xmax2(a6),d0
			bge.b	ret

			move.w	xmin2(a6),d0
			cmp.w	xmax1(a6),d0
			bge.b	ret

			move.w	xmin1(a6),d0
			move.w	xmin2(a6),d1
			cmp.w	d1,d0
			bge.b	(*)+4

			move.w	d1,d0
			move.w	d0,g_x(a1)
			
			move.w	ymin1(a6),d0
			move.w	ymin2(a6),d1
			cmp.w	d1,d0
			bge.b	(*)+4
			
			move.w	d1,d0
			move.w	d0,g_y(a1)
			
			move.w	xmax1(a6),d0
			move.w	xmax2(a6),d1
			cmp.w	d1,d0
			blt.b	(*)+4
			
			move.w	d1,d0
			move.w	d0,g_w(a1)
			
			move.w	ymax1(a6),d0
			move.w	ymax2(a6),d1
			cmp.w	d1,d0
			blt.b	(*)+4

			move.w	d1,d0
			move.w	d0,g_h(a1)

			move.w	g_x(a1),d0
			sub.w	d0,g_w(a1)
			move.w	g_y(a1),d0
			sub.w	d0,g_h(a1)
			
			moveq.l	#1,d0
			unlk	a6
			rts

ret:		moveq.l	#0,d0
			unlk	a6
			rts
ENDMOD

MODULE rc_inside
			move.w	(a0)+,d2
			cmp.w	d2,d0
			blt.b	outside

			add.w	2(a0),d2
			cmp.w	d2,d0
			bge.b	outside

			move.w	(a0)+,d2
			cmp.w	d2,d1
			blt.b	outside

			add.w	2(a0),d2
			cmp.w	d2,d1
			bge.b	outside

			moveq.l #1,d0
			rts

outside:	moveq.l #0,d0
			rts
ENDMOD

MODULE rc_grect_to_array
			move.l	(a0)+,d0
			move.l	d0,(a1)+

			swap	d0
			add.w	(a0)+,d0
			subq.w	#1,d0
			move.w	d0,(a1)+

			swap	d0
			add.w	(a0),d0
			subq.w	#1,d0
			move.w	d0,(a1)

			rts
ENDMOD

MODULE rc_array_to_grect
			move.l	(a0)+,d0
			move.l	d0,(a1)+

			swap	d0
			sub.w	(a0)+,d0
			neg.w	d0
			addq.w	#1,d0
			move.w	d0,(a1)+

			swap	d0
			sub.w	(a0),d0
			neg.w	d0
			addq.w	#1,d0
			move.w	d0,(a1)

			rts
ENDMOD
