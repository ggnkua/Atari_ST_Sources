
	globl ob_dostate,ob_undostate,ob_isstate
	globl ob_doflag,ob_undoflag,ob_isflag
	globl ob_xywh
	globl ob_get_text,ob_set_text
	globl ob_draw_dialog,ob_undraw_dialog

	globl rc_equal,rc_copy,rc_intersect,rc_inside,rc_grect_to_array,rc_array_to_grect
	globl _center,_typetest,_dial

	globl form_center,form_dial
	globl objc_draw

	globl vq_gdos

G_TEXT		= 21
G_BOXTEXT	= 22
G_USERDEF	= 24
G_BUTTON	= 26
G_STRING	= 28
G_FTEXT 	= 29
G_FBOXTEXT	= 30
G_TITLE 	= 32

ATTR_TEXT	= 13

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

MODULE ob_dostate
			mulu.w	#24,d0
			or.w	d1,10(a0,d0.l)
			rts
ENDMOD

MODULE ob_undostate
			not.w	d1
			mulu.w	#24,d0
			and.w	d1,10(a0,d0.l)
			rts
ENDMOD

MODULE ob_isstate
			mulu.w	#24,d0
			and.w	10(a0,d0.l),d1
			bne.b	flag_set

			moveq.l #0,d0
			rts

flag_set:	moveq.l #1,d0
			rts
ENDMOD

MODULE ob_doflag
			mulu.w	#24,d0
			or.w	d1,8(a0,d0.l)
			rts
ENDMOD

MODULE ob_undoflag
			not.w	d1
			mulu.w	#24,d0
			and.w	d1,8(a0,d0.l)
			rts
ENDMOD

MODULE ob_isflag
			mulu.w	#24,d0
			and.w	8(a0,d0.l),d1
			bne.b	state_set

			moveq.l #0,d0
			rts

state_set:	moveq.l #1,d0
			rts
ENDMOD

MODULE ob_xywh
			mulu.w	#24,d0
			move.l	16(a0,d0.l),(a1)+
			move.l	20(a0,d0.l),(a1)
			rts
ENDMOD

MODULE ob_get_text
			jsr 	_typetest

			move.l	(a0),a0
			tst.w	d1
			beq.b	no_init

			clr.b	(a0)
no_init:	rts
ENDMOD

MODULE ob_set_text
			jsr 	_typetest
			move.l	a1,(a0)
			rts
ENDMOD

MODULE _typetest
			mulu.w	#24,d0
			add.l	d0,a0
			move.w	6(a0),d2

			cmp.b	#G_TEXT,d2
			beq.b	text
			cmp.b	#G_FTEXT,d2
			beq.b	text
			cmp.b	#G_BOXTEXT,d2
			beq.b	text
			cmp.b	#G_FBOXTEXT,d2
			beq.b	text

			cmp.b	#G_STRING,d2
			beq.b	string
			cmp.b	#G_BUTTON,d2
			beq.b	string
			cmp.b	#G_TITLE,d2
			beq.b	string

			and.w	#$7fff,d2	; ~G_MODAL
			cmp.w	#(ATTR_TEXT<<8)|G_USERDEF,d2
			beq.b	userdef

			sub.l	a0,a0
			addq.l	#4,sp
			rts

text:		move.l	12(a0),a0
			rts

string: 	lea.l	12(a0),a0
			rts

userdef:	move.l	12(a0),a0
			move.l	4(a0),a0
			rts
ENDMOD


MODULE ob_draw_dialog
			link	a6,#-16
			jsr 	_center
			clr.w	-2(a6)
			bsr 	_dial
			move.w	-4(a6),d0
			or.w	-6(a6),d0
			or.w	-8(a6),d0
			or.w	8(a6),d0
			beq.b	no_grow

			move.w	#1,-2(a6)
			jsr 	_dial

no_grow:	lea.l	-16(a6),a1
			move.l	(a1)+,-(sp)
			move.w	(a1)+,-(sp)
			move.w	(a1),d2
			moveq.l #127,d1
			moveq.l #0,d0
			jsr 	objc_draw
			addq.l	#6,sp
			unlk	a6
			rts
ENDMOD

MODULE ob_undraw_dialog
			link	a6,#-16
			jsr 	_center
			move.w	-4(a6),d0
			or.w	-6(a6),d0
			or.w	-8(a6),d0
			or.w	8(a6),d0
			beq.b	no_shrink

			move.w	#2,-2(a6)
			jsr 	_dial

no_shrink:	move.w	#3,-2(a6)
			jsr 	_dial
			unlk	a6
			rts
ENDMOD

MODULE _center
			move.w	d2,-8(a6)
			move.w	d1,-6(a6)
			move.w	d0,-4(a6)
			pea 	(a0)
			lea.l	-10(a6),a1
			pea 	-16(a6)
			pea 	-14(a6)
			pea 	-12(a6)
			jsr 	form_center
			lea.l	12(sp),sp
			move.l	(sp)+,a0
			rts
ENDMOD

MODULE _dial
			pea 	(a0)
			lea.l	-16(a6),a1
			move.l	(a1)+,-(sp)
			move.l	(a1),-(sp)
			move.w	8(a6),-(sp)
			move.w	-8(a6),-(sp)
			move.w	-6(a6),d2
			move.w	-4(a6),d1
			move.w	-2(a6),d0
			jsr 	form_dial
			lea.l	12(sp),sp
			move.l	(sp)+,a0
			rts
ENDMOD

MODULE rc_equal
			cmpm.l	(a0)+,(a1)+
			bne.b	notequal

			cmpm.l	(a0)+,(a1)+
			beq 	equal

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
			bcc.b	skip
			
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
			bcc.b	ret

			move.w	xmin1(a6),d0
			cmp.w	xmax2(a6),d0
			bcc.b	ret

			move.w	xmin2(a6),d0
			cmp.w	xmax1(a6),d0
			bcc.b	ret

			move.w	xmin1(a6),d0
			move.w	xmin2(a6),d1
			cmp.w	d1,d0
			bcc.b	(*)+4

			move.w	d1,d0
			move.w	d0,g_x(a1)
			
			move.w	ymin1(a6),d0
			move.w	ymin2(a6),d1
			cmp.w	d1,d0
			bcc.b	(*)+4
			
			move.w	d1,d0
			move.w	d0,g_y(a1)
			
			move.w	xmax1(a6),d0
			move.w	xmax2(a6),d1
			cmp.w	d1,d0
			bcs.b	(*)+4
			
			move.w	d1,d0
			move.w	d0,g_w(a1)
			
			move.w	ymax1(a6),d0
			move.w	ymax2(a6),d1
			cmp.w	d1,d0
			bcs.b	(*)+4

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
			bcs.b	outside

			add.w	2(a0),d2
			cmp.w	d2,d0
			bcc.b	outside

			move.w	(a0)+,d2
			cmp.w	d2,d1
			bcs.b	outside

			add.w	2(a0),d2
			cmp.w	d2,d1
			bcc.b	outside

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
