	include	vdi.i
**************************************
*** Routine de dessin des userdefs ***
**************************************
	rsreset
pb_tree		rs.l	1
pb_obj		rs.w	1
pb_prevstate	rs.w	1
pb_currstate	rs.w	1
pb_x		rs.w	1
pb_y		rs.w	1
pb_w		rs.w	1
pb_h		rs.w	1
pb_xc		rs.w	1
pb_yc		rs.w	1
pb_wc		rs.w	1
pb_hc		rs.w	1

	XDEF	userdef_draw
userdef_draw
;	moveq.l	#0,d0
;	rts
	movem.l	d1-a6,-(sp)
	lea	60(sp),a6
	move.l	(a6),a6

	movem.w	pb_xc(a6),d1-d4
	add.w	d1,d3
	sub.w	#1,d3
	add.w	d2,d4
	sub.w	#1,d4

	vs_clip	#1,d1,d2,d3,d4

	vsl_color	#1		; puis on definie le type de ligne

	movem.w	pb_x(a6),d1-d4
	add.w	d1,d3
	sub.w	#1,d3
	add.w	d2,d4
	sub.w	#1,d4
	v_rbox	d1,d2,d3,d4

	vs_clip	#0,d1,d2,d3,d4

	moveq.l	#0,d0
	movem.l	(sp)+,d1-a6
	rts

	data
	XDEF	user_blk
user_blk
ub_code	dc.l	userdef_draw
ub_parm	ds.l	1
	text
