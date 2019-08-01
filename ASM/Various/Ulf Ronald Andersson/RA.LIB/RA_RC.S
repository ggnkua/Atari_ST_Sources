;----------------------------------------------------------------------------
;File name:	RA_RC.S				Revision date:	1998.09.08
;Creator:	Ulf Ronald Andersson		Creation date:	1993.05.05
;(c)1993 by:	Ulf Ronald Andersson		All rights reserved
;Released as:	FREEWARE			(commercial sales forbidden!)
;----------------------------------------------------------------------------
;Purpose:	Macro library for low level Raster Copy operations
;----------------------------------------------------------------------------
;	Condition ensures inclusion once per pass only
;
	ifnd	RA_RC_defined
RA_RC_defined	set	1
;----------------------------------------------------------------------------
	include	RA_LA.I
;----------------------------------------------------------------------------
;	Library functions:
;
;void	rc_init()
;void	rc_scroll(x,y,w,h,dir,vbase)	d0h,d0l,d1h,d1l,d2l,a0
;void	rc_blank(x,y,w,h,colour,vbase)	d0h,d0l,d1h,d1l,d2l,a0
;GRECT	rc_intersect(X,Y,W,H,x,y,w,h)	d0h,d0l,d1h,d1l,d2h,d2l,d3h,d3l
;GRECT	rc_joint(X,Y,W,H,x,y,w,h)	d0h,d0l,d1h,d1l,d2h,d2l,d3h,d3l
;
;NB_1:	GRECT's are returned as d0h,d0l,d1h,d1l.
;NB_2:  Failed 'rc_joint' returns flag < 0 in d2, with d0,d1 unchanged
;NB_3:	'rc_scroll' & 'rc_blank' use system routines if 'rc_voff' > 0
;
; ----------------------------------------------------------------------------
;	Data for raster copy operations
;
rc_voff:	dc.w	0
rc_ones:	dc.l	-1
rc_maxcolours:	dc.w	2
rc_planes:	ds.w	1
rc_bytes_lin:	ds.w	1
rc_nxwd:	ds.w	1
rc_nxln:	ds.w	1
rc_nxpl:	ds.w	1
rc_bltm_t:	ds.b	blt_size
planes_ix_t:	dc.w	-1,00,01,-1,02,-1,-1,-1,03	;legal bitplanes > 0
		dc.w	-1,-1,-1,-1,-1,-1,04,04
;
;
	_debdef	rc_voff,2
	_debdef	rc_ones,2
	_debdef	rc_maxcolours,2
	_debdef	rc_planes,2
	_debdef	rc_bytes_lin,2
	_debdef	rc_nxwd,2
	_debdef	rc_nxln,2
	_debdef	rc_nxpl,2
	_debdef	rc_bltm_t,2
	_debdef	planes_ix_t,2
;
rc_init:
	_debdef	rc_init,2
	_a_init
	move	la_bytes_lin(a0),rc_bytes_lin
	move	la_wk_maxcolours(a0),rc_maxcolours
	move	la_planes(a0),d0
	move	d0,rc_planes
	asl	#1,d0
	move	d0,rc_nxwd
	cmp	#2,d0
	sgt	d0
	and	#2,d0
	ext	d0
	move	d0,rc_nxpl
	move	-2(a0),rc_nxln
;
;	initialize table for moving blits "rc_bltm_t"
;
	lea	rc_bltm_t(pc),a1
	move.l	#$03030303,blt_op_tab(a1)
	move	rc_nxwd(pc),blt_s_nxwd(a1)
	move	rc_nxln(pc),blt_s_nxln(a1)
	move	rc_nxpl(pc),blt_s_nxpl(a1)
	move	rc_nxwd(pc),blt_d_nxwd(a1)
	move	rc_nxln(pc),blt_d_nxln(a1)
	move	rc_nxpl(pc),blt_d_nxpl(a1)
	rts
;
;	ends	rc_init
; ----------------------------------------------------------------------------
rc_scroll:				;vertical scroll routine
	_debdef	rc_scroll,2
;
; tolerates up to 8 bit planes with maximum 1024 byte lines
; also supports TT-low and Falcon-truecolour up to 1024 pixels wide
;
; arguments:	d0=x.y  d1=w.h  d2=dir  a0->vbase
; remarks:	'dir' is signed scroll distance
; destroys:	d0-d2/a0-a2
;
	movem.l	d3-d7/a3-a6,-(sp)
	tst.b	rc_maxcolours
	bne.s	rc_own_scroll		;TT low or falcon !
	tst	rc_voff
	beq.s	rc_own_scroll
rc_sys_scroll:
	move.l	d0,d4
	move.l	d1,d5
	move	d2,d6
	move	d6,d0
	bpl.s	.keep_size
	neg	d0			;d0 = dist
.keep_size:
	move	d0,d3			;d3 = dist
	sub	d5,d0			;d0 = dist-h
	bge.s	.non_roll		;IF dist<h
	neg	d0			;d0 = bh = y-dist
	move	d4,d1			;d1 = sy = y
	move	d1,d2
	add	d3,d2			;d2 = dy = y+dist
	tst	d6
	bmi.s	.roll_out		;IF dir>=0
	exg	d1,d2				;SWAP sy,dy
.roll_out:				;ENDIF
	lea	rc_bltm_t(pc),a1
	move	d0,d5
	move.l	d5,blt_b_wd(a1)			;rc_bltm(0).rc_bltm(1) = w.bh
	move	rc_planes(pc),blt_plane_ct(a1)	;rc_bltm(2)=rc_planes
	clr.l	blt_fg_col(a1)			;rc_bltm(3).rc_bltm(4) = 0.0
	move	d1,d4
	move.l	d4,blt_s_xmin(a1)		;rc_bltm(7).rc_bltm(8) = x.sy
	move.l	a0,blt_s_form(a1)		;rc_bltm(9),rc_bltm(10) = video base
	move	d2,d4
	move.l	d4,blt_d_xmin(a1)		;rc_bltm(14).rc_bltm(15) = x.dy
	move.l	a0,blt_d_form(a1)		;rc_bltm(16).rc_bltm(17) = video base
	clr.l	blt_p_addr(a1)			;rc_bltm(21).rc_bltm(22)=0
	lea	rc_bltm_t(pc),a6
	_a_bitblt
.non_roll:			;ENDIF
	bra	rcsc_exit
;
;
rc_own_scroll:
	clr.l	d6
	move	rc_bytes_lin(pc),d6	;d6 = bytes_lin
	move	d0,d3			;d3 = y
	mulu	d6,d3			;d3 = y*bytes_lin
	move.l	a0,a4
	add.l	d3,a4			;a4 = vbase+y*bytes_lin
	move.l	a4,a6			;a6 = vbase+y*bytes_lin
	move	d2,d3			;d3 = dir
	muls	d6,d3			;d3 = dir*bytes_lin
	add.l	d3,a4			;a4 = vbase+(y+dir)*bytes_lin
	move	d2,d3			;d3 = dir
	bpl.s	.keep_dir	;IF dir<0
	neg	d3			;d3 = dist
	move	d1,d4			;d4 = h
	subq	#1,d4			;d4 = h-1
	mulu	d6,d4			;d4 = (h-1)*bytes_lin
	add.l	d4,a4			;a4 = vbase+(y+h-dist-1)*bytes_lin
	add.l	d4,a6			;a6 = vbase+(y+h-1)*bytes_lin
.keep_dir:			;ENDIF
;NB: a4 (src) & a6 (dest) -> bases of first scanlines to process
	sub	d3,d1			;d1 = w.(h-dist)
	ble	rcsc_exit	;exit if h <= dist
	clr.l	d7			;hi word of d7 has some flags
	move	d1,d7			;d7 = h-dist
	subq	#1,d7			;d7 = dbra count for loop
;NB: d7 is ready for loop, as h-dist-1
;NB: d0 = x.y   d1 = w.(h-dist)   d2 = dir
	swap	d1			;d1 = w
	tst	d1
	ble	rcsc_exit	;exit if w <= 0
	cmp	#256,rc_maxcolours
	bhi	rc_truecol_scroll
.ST_rez:
	swap	d0			;d0 = x
	move	d0,d3			;d3 = x
	lsr	#4,d3			;d3 = (x/16)
	add	d3,d3			;d3 = (x/16)*2
	mulu	rc_planes(pc),d3	;d3 = (x/16)*2*rc_planes = X byte offset
	add.l	d3,a4			;a4-> first source data to move
	add.l	d3,a6			;a6-> first dest to store data
;NB: a4 & a6 are ready for loop
	move	d0,d5			;d5 = x
	add	d1,d5			;d5 = x+w
	move	d5,d4			;d4 = x+w
	add	#15,d4			;d4 = x+w+15
	lsr	#4,d4			;d4 = ((x+w+15)/16)
	add	d4,d4			;d4 = ((x+w+15)/16)*2
	mulu	rc_planes(pc),d4	;d4 = ((x+w+15)/16)*2*rc_planes = X limit byte offset
	sub.l	d3,d4			;d4 = total count of affected bytes per line
	move.l	d4,d1			;d1 = affected bytes per line  (even)
	neg.l	d1
	add.l	d6,d1			;d1 = offset for unaffected bytes per line
	tst	d2		;IF dir<0
	bpl.s	.keep_offs
	sub.l	d6,d1
	sub.l	d6,d1			;d1 = offs from block end to start of previous block
.keep_offs:			;ENDIF
	move.l	d1,a5			;a5 = dir_dependent offset between blocks
;NB: a5 is ready for loop
	move.l	d4,d3
	asr.l	#1,d3
	divs	rc_planes(pc),d3
	ble	rcsc_exit
	cmp	#2,d3
	bge.s	.maybe_2g_1
	bset	#31,d7
.maybe_2g_1:
	and	#15,d0			;d0 = x mod 16
	lsl	#2,d0
	move.l	lft_mask_t(pc,d0),d2	;d2 = ldm.ldm  left destination mask
	move.l	d2,d3
	not.l	d3			;d3 = lsm.lsm  left source mask
;NB: d2 & d3 are ready for loop
	and	#15,d5			;d5 = (x+w) mod 16
	lsl	#2,d5
	move.l	lft_mask_t(pc,d5),d5	;d5 = rsm.rsm  right source mask
	move.l	d5,d6
	not.l	d6			;d6 = rdm.rdm  right destination mask
;NB: d5 & d6 are ready for loop
	tst.l	d7
	bpl.s	.maybe_2g_2
	and.l	d5,d3
	or.l	d6,d2
	clr.l	d5
.maybe_2g_2:
	bra.s	calc_d4
;
lft_mask_t:
	dc.l	$00000000,$80008000,$C000C000,$E000E000
	dc.l	$F000F000,$F800F800,$FC00FC00,$FE00FE00
	dc.l	$FF00FF00,$FF80FF80,$FFC0FFC0,$FFE0FFE0
	dc.l	$FFF0FFF0,$FFF8FFF8,$FFFCFFFC,$FFFEFFFE
;
calc_d4:				;d4 = affected bytes per line  (even)
	move	rc_planes(pc),d0
	add	d0,d0
	ext.l	d0			;d0 = 2*rc_planes = bytes per 16 pixels
	tst	d2
	beq.s	.keep_d4_1
	sub.l	d0,d4			;d4-= bytes of 16 pixels
.keep_d4_1:
	tst	d5
	beq.s	.keep_d4_2
	sub.l	d0,d4			;d4-= bytes of 16 pixels
.keep_d4_2:
	lsr.l	#1,d4			;d4 = words in midsection
;
;NB: all registers except d4/a0/a1/a3 are ready for loop
;
	add	d0,d0			;d0 = 4*rc_planes
	move.l	rcsc_left_t(pc,d0),a0	;a0-> left edge code
	lea	rcsc_m_l(pc),a1		;a1-> middle section code
	move.l	rcsc_right_t(pc,d0),a3	;a3-> right edge code
	btst	#0,d4
	beq.s	.not_oddwords
	lea	rcsc_m_w(pc),a1		;a1-> middle section code for odd words
.not_oddwords
	tst	d5
	bne.s	.keep_r
	lea	rcsc_next(pc),a3	;patch a3 to skip right edge
.keep_r:
	tst.l	d4
	bne.s	.keep_m
	move.l	a3,a1			;patch a1 to skip middle section
.keep_m:
	tst	d2
	bne.s	.keep_l
	move.l	a1,a0			;patch a0 to skip left edge
.keep_l:
	bclr	#0,d4			;remove odd bit from d4
	neg.l	d4			;d4 = -longs*2
;NB: all registers are now ready for loop
	bra.s	rcsc_loop		;start loop with single right edge
;
rcsc_left_t:
	dc.l	rcsc_exit,rcsc_l_1,rcsc_l_2,rcsc_exit
	dc.l	rcsc_l_4,rcsc_exit,rcsc_exit,rcsc_exit
	dc.l	rcsc_l_8,rcsc_exit,rcsc_exit,rcsc_exit
;
rcsc_right_t:
	dc.l	rcsc_exit,rcsc_r_1,rcsc_r_2,rcsc_exit
	dc.l	rcsc_r_4,rcsc_exit,rcsc_exit,rcsc_exit
	dc.l	rcsc_r_8,rcsc_exit,rcsc_exit,rcsc_exit
;
; registers:	a4->sm  a6->dm
;   - " -	a0->left_fn  a1->mid_fn  a3->rgt_fn  a5=line_offset
;   - " -	d2=ldm.ldm  d3=lsm.lsm  d4=-mid_longs*2
;   - " -	d5=rsm.rsm  d6=rdm.rdm  d7=(scanlines-1)
;
rcsc_loop:
	jmp	(a0)		;alt: rcsc_l_?/rcsc_m_l/rcsc_m_w
;
rcsc_l_8:
	move.l	(a4)+,d0
	move.l	(a6),d1
	and.l	d3,d0
	and.l	d2,d1
	or.l	d1,d0
	move.l	d0,(a6)+
;;;rcsc_l_6:
	move.l	(a4)+,d0
	move.l	(a6),d1
	and.l	d3,d0
	and.l	d2,d1
	or.l	d1,d0
	move.l	d0,(a6)+
rcsc_l_4:
	move.l	(a4)+,d0
	move.l	(a6),d1
	and.l	d3,d0
	and.l	d2,d1
	or.l	d1,d0
	move.l	d0,(a6)+
rcsc_l_2:	;a4->sm  a6->dm  d2=smsk d3=dmsk
	move.l	(a4)+,d0
	move.l	(a6),d1
	and.l	d3,d0
	and.l	d2,d1
	or.l	d1,d0
	move.l	d0,(a6)+
	jmp	(a1)		;alt: rcsc_m_l/rcsc_m_w/rcsc_r_?/rcsc_next
;
rcsc_l_1:
	move	(a4)+,d0
	move	(a6),d1
	and	d3,d0
	and	d2,d1
	or	d1,d0
	move	d0,(a6)+
	jmp	(a1)		;alt: rcsc_m_l/rcsc_m_w/rcsc_r_1/rcsc_next
;
;
	rept	256
	move.l	(a4)+,(a6)+
	endr
rcsc_m_0:	;a4->sm  a6->dm  d4=-longs*2=words=bytes/2
	jmp	(a3)		;alt: rcsc_r_?/rcsc_next
;
rcsc_m_w:
	move	(a4)+,(a6)+
rcsc_m_l:
	jmp	rcsc_m_0(pc,d4)
;
;
rcsc_r_8:
	move.l	(a4)+,d0
	move.l	(a6),d1
	and.l	d5,d0
	and.l	d6,d1
	or.l	d1,d0
	move.l	d0,(a6)+
;;;rcsc_r_6:
	move.l	(a4)+,d0
	move.l	(a6),d1
	and.l	d5,d0
	and.l	d6,d1
	or.l	d1,d0
	move.l	d0,(a6)+
rcsc_r_4:
	move.l	(a4)+,d0
	move.l	(a6),d1
	and.l	d5,d0
	and.l	d6,d1
	or.l	d1,d0
	move.l	d0,(a6)+
rcsc_r_2:	;a4->sm  a6->dm  d2=smsk d3=dmsk
	move.l	(a4)+,d0
	move.l	(a6),d1
	and.l	d5,d0
	and.l	d6,d1
	or.l	d1,d0
	move.l	d0,(a6)+
	add	a5,a4
	add	a5,a6
	dbra	d7,rcsc_loop
	bra.s	rcsc_exit
;
rcsc_r_1:
	move	(a4)+,d0
	move	(a6),d1
	and	d5,d0
	and	d6,d1
	or	d1,d0
	move	d0,(a6)+
rcsc_next:
	add	a5,a4
	add	a5,a6
	dbra	d7,rcsc_loop
rcsc_exit:
	movem.l	(sp)+,d3-d7/a3-a6
	rts
;
;
	rept	512
	move.l	(a4)+,(a6)+
	endr
rcsc_move_longs:
	jmp	(a3)
;
;
rc_truecol_scroll:
; arguments:	d0=x.y  d1=w.h  d2=dir  a0->vbase
; remarks:	'dir' is signed scroll distance, entry d3-d7/a3-a6 are on stack
; destroys:	d0-d2/a0-a2
; NB:		a4 (src) & a6 (dest) -> bases of first scanlines to process
; NB:		d7 is ready for loop, as h-dist-1
; NB:		d0 = x.y   d1 = w.(h-dist)   d2 = dir   d6 = bytes per line
	swap	d0		;d0 = x
	add	d0,d0		;d0 = 2*x
	add	d0,a6		;a6 -> left edge of dest block
	add	d0,a4		;a4 -> left edge of src block
; NB: a4 & a6 are ready for loop
	clr.l	d3
	move	d1,d3		;d3 = w  affected pixels (=words) per line
	add	d3,d3		;d3 = affected bytes per line
	neg.l	d3
	add.l	d6,d3		;d3 = offset for unaffected bytes per line
	tst	d2		;IF dir<0
	bpl.s	.keep_offs
	sub.l	d6,d3
	sub.l	d6,d3			;d3 = offs from block end to start of previous block
.keep_offs:			;ENDIF
	move.l	d3,a5		;a5 = dir_dependent offset between blocks
;NB: a5 is ready for loop
	btst	#0,d1		;odd or even number of words to move per line ?
	bne.s	.set_odd
.set_even:
	lea	rcsc_move_longs(pc),a0
	lea	rcsc_next(pc),a3
	sub	d1,a0			;a0 adjusted to move needed longs
	jmp	(a0)
;
.set_odd:
	subq	#1,d1			;mark 1 word handled
	bgt.s	.set_odd_l		;go fix longs if needed
	lea	.move_sw(pc),a0
	lea	rcsc_next(pc),a1
.move_sw:
	move	(a4)+,(a6)+
	jmp	(a1)
;
.set_odd_l:
	lea	.move_sw(pc),a0
	lea	rcsc_move_longs(pc),a1
	lea	rcsc_next(pc),a3
	sub	d1,a1			;a1 adjusted to move needed longs
	jmp	(a0)
;
;
;	ends	rc_scroll
; ----------------------------------------------------------------------------
;	Code & data for "rc_blank"
;
rc_blank:				;rectangular blanking
	_debdef	rc_blank,2
;
; tolerates up to 8 bit planes with maximum 1024 byte lines
; also supports TT-low and Falcon-truecolour up to 1024 pixels wide
;
; arguments:	d0=x.y  d1=w.h  d2=colour  a0->vbase
; destroys:	d0-d2/a0-a2
;
	movem.l	d3-d7/a3-a6,-(sp)
	tst.b	rc_maxcolours
	bne	rc_own_blank		;TT low or falcon !
	tst	rc_voff
	beq	rc_own_blank
rc_sys_blank:
	move.l	d0,d4
	move.l	d1,d5
	move	d2,d6
	_a_init				;a0->line_a variables
	move.l	d4,la_x1(a0)
	add.l	d4,d5
	sub.l	#$10001,d5
	move.l	d5,la_x2(a0)
	lea	la_colbit0(a0),a1
	rept	4
	lsr	#1,d6
	scs	d0
	ext	d0
	move	d0,(a1)+
	endr
	clr	la_wmode(a0)
	move.l	#rc_ones,la_patptr(a0)
	clr	la_patmsk(a0)
	clr.l	la_mfill(a0)		;clear la_mfill & la_clip
	_a_bar				;draw the rectangle
	bra	rcbl_exit
;
;
rcbl_ldm:
	ds.l	1	;left edge destination mask
rcbl_ld:
	ds.w	8	;left edge data
rcbl_md:
	ds.w	8	;middle section data
rcbl_rdm:
	ds.l	1	;right edge destination mask
rcbl_rd:
	ds.w	8	;right edge data
;
;
rc_own_blank:
	clr	d5
	clr	d6
	move	rc_planes(pc),a6
	cmp	#16,a6
	bhi.s	.ignore_planes
	add	a6,a6
	add.l	#planes_ix_t,a6
	move	(a6),d5			;planes 1,2,4,8,15,16 => d5= 0,1,2,3,4,4
	bmi	rc_sys_blank
	move	d5,d6
	lsl	#2,d6			;planes 1,2,4,8,15,16 => d6= 0,4,8,12,16,16
.ignore_planes:
;
	move	d0,d3			;d3 = y
	blt	rcbl_exit
	mulu	rc_bytes_lin(pc),d3	;d3 = y*bytes_lin
	move.l	a0,a6			;a6 = vbase
	add.l	d3,a6			;a6 = vbase+y*bytes_lin
;NB: a6 -> base of first scanline to process
	clr.l	d7			;hi word of d7 has some flags
	move	d1,d7			;d7 = h
	ble	rcbl_exit
	subq	#1,d7			;d7 = dbra count for loop
;NB: d7 is ready for loop
	swap	d1			;d1 = w
	tst	d1
	ble	rcbl_exit	;exit if w <= 0
	cmp	#256,rc_maxcolours
	bhi	rc_truecol_blank
.ST_rez:
	swap	d0			;d0 = x
	clr.l	d3
	move	d0,d3			;d3 = x
	blt	rcbl_exit
	lsr	#4,d3			;d3 = (x/16)
	move	d3,a5			;a5 = (x/16)
	add	d3,d3			;d3 = (x/16)*2
	lsl.l	d5,d3			;d3 = (x/16)*2*rc_planes = X byte offset
	add.l	d3,a6			;a6-> first dest to store data
;NB: a6 is ready for loop
	add	d0,d1			;d1 = x+w
	clr.l	d4
	move	d1,d4			;d4 = d1 = x+w
	add	#15,d4			;d4 = x+w+15
	lsr	#4,d4			;d4 = ((x+w+15)/16)
	sub	a5,d4			;d4 = width in affected pixel groups(16)
	cmp	#1,d4
	bgt.s	.maybe_2g_1		;IF only one group
	blt	rcbl_exit
	bset	#31,d7			;	flag long d7 negative
.maybe_2g_1:				;ENDIF
	move	d4,d3			;d3 = d4 = groups
	add	d3,d3			;d3 = groups*2
	lsl	d5,d3			;d3 = groups*2*rc_planes = affected width (bytes)
	move	rc_bytes_lin(pc),a5	;a5 = bytewidth
	sub	d3,a5			;a5 = byteoffset for unaffected bytes per line
;NB: a5 is ready for loop
;
.get_colour:
	move.l	.fix_colour_t(pc,d6),a0
	jmp	(a0)
;
.fix_colour_t:
	dc.l	.fix_col_1,.fix_col_2,.fix_col_4,.fix_col_8
;
.fix_col_1:
	ror	#1,d2
	scs	d2
	ext	d2
	bra.s	.fix_col_8
;
.fix_col_16:
	lea	rcbl_ld(pc),a0
	lea	rcbl_md(pc),a1
	lea	rcbl_rd(pc),a3
	rept	8
	move	d2,(a0)+
	move	d2,(a1)+
	move	d2,(a3)+
	endr
	bra.s	.got_colour
;
.fix_col_2:
	and	#3,d2
	move	d2,d5
	lsl	#2,d5
	or	d5,d2
.fix_col_4:
	and	#15,d2
	move	d2,d5
	lsl	#4,d5
	or	d5,d2
.fix_col_8:
	lea	rcbl_ld(pc),a0
	lea	rcbl_md(pc),a1
	lea	rcbl_rd(pc),a3
	rept	8
	lsr	#1,d2
	scs	d5
	ext	d5
	move	d5,(a0)+
	move	d5,(a1)+
	move	d5,(a3)+
	endr
.got_colour:
;
.get_masks:
	lea	lft_mask_t(pc),a1
	and	#15,d0			;d0 = x mod 16
	lsl	#2,d0
	move.l	(a1,d0),d2		;d2 = ldm.ldm  left edge destination mask
	move.l	d2,rcbl_ldm
	not.l	d2			;d2 = lsm.lsm  left edge source mask
	lea	rcbl_ld(pc),a0
	and.l	d2,(a0)+
	and.l	d2,(a0)+
	and.l	d2,(a0)+
	and.l	d2,(a0)+
	not.l	d2			;d2 = ldm.ldm  left edge destination mask
	and	#15,d1			;d5 = (x+w) mod 16
	lsl	#2,d1
	move.l	(a1,d1),d5		;d5 = rsm.rsm  right edge source mask
	beq.s	.keep_rsm
	lea	rcbl_rd(pc),a0
	tst.l	d7
	bpl.s	.maybe_2g_2		;IF single_group
	lea	rcbl_ld(pc),a0		;right & left are same !!!
.maybe_2g_2:				;ENDIF
	and.l	d5,(a0)+
	and.l	d5,(a0)+
	and.l	d5,(a0)+
	and.l	d5,(a0)+
	not.l	d5			;d5 = rdm.rdm  right edge destination mask
	tst.l	d7
	bpl.s	.maybe_2g_3		;IF single_group
	or.l	d5,d2
	move.l	d2,rcbl_ldm
	moveq	#-1,d5
.maybe_2g_3:				;ENDIF
	move.l	d5,rcbl_rdm
	not.l	d5			;d5 = rsm.rsm  right edge source mask
.keep_rsm:
	beq.s	.keep_d4_1
	subq	#1,d4			;middle loses 1 group as right edge
.keep_d4_1:
	tst	d2
	beq.s	.keep_d4_2
	subq	#1,d4			;middle loses 1 group as left edge
.keep_d4_2:
	tst	d4
	beq.s	.keep_d4_3
	bset	#30,d4
.keep_d4_3:
.got_masks:
;
.get_pointers:
	move.l	.rcbl_l_fn_t(pc,d6),a0
	move.l	.rcbl_r_fn_t(pc,d6),a3
	move.l	.rcbl_m_c_t(pc,d6),a1
	jmp	(a1)
;
.rcbl_l_fn_t:
	dc.l	rcbl_l_1,rcbl_l_2,rcbl_l_4,rcbl_l_8
.rcbl_r_fn_t:
	dc.l	rcbl_r_1,rcbl_r_2,rcbl_r_4,rcbl_r_8
.rcbl_m_c_t:
	dc.l	.get_count_1,.get_count_2,.get_count_4,.get_count_8
;
.get_count_8:
	suba.l	a1,a1
	lea	rcbl_m_8_0(pc),a2
	lsl	#3,d4			;8 code bytes per block
	bra	.set_count
;
.get_count_4:
	suba.l	a1,a1
	lea	rcbl_m_4_0(pc),a2
	lsl	#2,d4			;4 code bytes per block
	bra	.set_count
;
.get_count_2:
	move	d4,d0			;d0 = d4 = groups in middle
	and	#7,d0
	lsl	#2,d0
	move.l	.rcbl_m_2_t(pc,d0),a1
	lea	rcbl_m_2_0(pc),a2
	lsr	#3,d4			;8 groups per block
	lsl	#3,d4			;8 code bytes per block
	bra.s	.set_count
;
.rcbl_m_2_t:
	dc.l	rcbl_m_2_000,rcbl_m_2_001,rcbl_m_2_010,rcbl_m_2_011
	dc.l	rcbl_m_2_100,rcbl_m_2_101,rcbl_m_2_110,rcbl_m_2_111
;
.rcbl_m_1_t:
	dc.l	rcbl_m_1_0000,rcbl_m_1_0001,rcbl_m_1_0010,rcbl_m_1_0011
	dc.l	rcbl_m_1_0100,rcbl_m_1_0101,rcbl_m_1_0110,rcbl_m_1_0111
	dc.l	rcbl_m_1_1000,rcbl_m_1_1001,rcbl_m_1_1010,rcbl_m_1_1011
	dc.l	rcbl_m_1_1100,rcbl_m_1_1101,rcbl_m_1_1110,rcbl_m_1_1111
;
.get_count_1:
	move	d4,d0			;d0 = d4 = groups in middle
	and	#15,d0
	lsl	#2,d0
	move.l	.rcbl_m_1_t(pc,d0),a1
	lea	rcbl_m_2_0(pc),a2
	lsr	#4,d4			;16 groups per block
	lsl	#3,d4			;8 code bytes per block
.set_count
	sub	d4,a2		;  a2->block move code (<=4 planes)
	move.l	a1,d0
	bne.s	.keep_a1
	move.l	a2,a1
.keep_a1:
;
.fix_pointers:
	tst	d5
	bne.s	.keep_r			;IF no right edge
	lea	rcbl_next(pc),a3	;	patch a3 to skip right edge
.keep_r:				;ENDIF
	tst	d4
	bne.s	.keep_m_c		;IF not long middle section
	move.l	a3,a2			;	patch a2 to skip long middle
.keep_m_c:				;ENDIF
	tst.l	d4
	bne.s	.keep_m			;IF no middle section
	move.l	a3,a1			;	patch a1 to skip middle section
.keep_m:				;ENDIF
	tst	d2
	bne.s	.keep_l			;IF no left edge
	move.l	a1,a0			;	patch a0 to skip left edge
.keep_l:				;ENDIF
;
rcbl_start:
	cmp	#3*4,d6
	beq.s	rcbl_multi
	tst.l	d7
	bmi	rcbl_single_g
	tst.l	d4
	beq	rcbl_pair_g
rcbl_multi:
	move.l	a0,rcbl_patch_1+2
	move.l	a1,rcbl_patch_2+2
	move.l	a2,rcbl_patch_3+2
	move.l	a3,rcbl_patch_4+2
	move.l	rcbl_init_t(pc,d6),a0
	jmp	(a0)
;
rcbl_init_t:
	dc.l	rcbl_init_1,rcbl_init_2,rcbl_init_4,rcbl_init_8
;
rcbl_init_8:
rcbl_init_4:
	movem.l	rcbl_ld(pc),a0-a1
	movem.l	rcbl_md(pc),d2-d3
	movem.l	rcbl_rd(pc),a2-a3
	move.l	rcbl_ldm,d5
	move.l	rcbl_rdm,d6
	bra.s	rcbl_loop
;
rcbl_init_2:
rcbl_init_1:
	tst.l	d4
	beq.s	.skip_m
	movem.l	rcbl_md(pc),d1-d4
	move.l	d1,a1
	move.l	d1,a3
	move.l	d1,a4
.skip_m
	move.l	rcbl_ld(pc),a0
	move.l	rcbl_rd(pc),a2
	move.l	rcbl_ldm,d5
	move.l	rcbl_rdm,d6
	bra.s	rcbl_loop
;
rcbl_loop:
rcbl_patch_1:
	jmp	(rcbl_next).l	;left edge handler
rcbl_patch_2:
	jmp	(rcbl_next).l	;middle section init
rcbl_patch_3:
	jmp	(rcbl_next).l	;middle section moves
rcbl_patch_4:
	jmp	(rcbl_next).l	;right edge handler
;
;
rcbl_single_g:
	move.l	d2,d5		;move and test combined ldm.ldm & rdm.rdm
	beq.s	.got_sing_md
.got_sing_ld:
	move.l	rcbl_sing_ld_t(pc,d6),a0
	jmp	(a0)
;
.got_sing_md:
	move.l	rcbl_sing_md_t(pc,d6),a0
	jmp	(a0)
;
rcbl_sing_ld_t:
	dc.l	rcbl_sing_ld_1,rcbl_sing_ld_2,rcbl_sing_ld_4
;
rcbl_sing_md_t:
	dc.l	rcbl_sing_md_1,rcbl_sing_md_2,rcbl_sing_md_4
;
;
rcbl_pair_g:
	move.l	rcbl_pair_t(pc,d6),-(sp)
	movem.l	rcbl_ld(pc),a0-a1
	movem.l	rcbl_rd(pc),a2-a3
	move.l	rcbl_ldm(pc),d5
	move.l	rcbl_rdm(pc),d6
	rts
;
rcbl_pair_t:
	dc.l	rcbl_pair_1,rcbl_pair_2,rcbl_pair_4
;
;
rcbl_l_8:
	movem.l	rcbl_ldm(pc),d2-d6
	movem.l	(a6),d0-d1
	and.l	d2,d0
	and.l	d2,d1
	or.l	d3,d0
	or.l	d4,d1
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	movem.l	(a6),d0-d1
	and.l	d2,d0
	and.l	d2,d1
	or.l	d5,d0
	or.l	d6,d1
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	bra	rcbl_patch_2
;
rcbl_l_4:
	movem.l	(a6),d0-d1
	and.l	d5,d0
	and.l	d5,d1
	add.l	a0,d0
	add.l	a1,d1
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	bra	rcbl_patch_2
;
rcbl_l_2:
	move.l	(a6),d0
	and.l	d5,d0
	add.l	a0,d0
	move.l	d0,(a6)+
	bra	rcbl_patch_2
;
rcbl_l_1:
	move	(a6),d0
	and	d5,d0
	add	a0,d0
	move	d0,(a6)+
	bra	rcbl_patch_2
;
;
	rept	64
	movem.l	d0-d3,(a6)
	lea	16(a6),a6
	endr
rcbl_m_8_0:
	bra	rcbl_patch_4
;
rcbl_m_8:
	movem.l	rcbl_md(pc),d0-d3
	bra	rcbl_patch_3
;
;
	rept	128
	move.l	d2,(a6)+
	move.l	d3,(a6)+
	endr
rcbl_m_4_0:
	bra	rcbl_patch_4
;
rcbl_m_4:
	bra	rcbl_patch_3
;
;
	rept	32
	movem.l	d0-d4/a1/a3/a4,(a6)
	lea	32(a6),a6
	endr
rcbl_m_2_0:
	bra	rcbl_patch_4
;
rcbl_m_2_111:
	movem.l	d1-d4/a1/a3/a4,(a6)
	lea	28(a6),a6
	move.l	d2,d0
	bra	rcbl_patch_3
;
rcbl_m_2_110:
	movem.l	d1-d4/a1/a3,(a6)
	lea	24(a6),a6
	move.l	d2,d0
	bra	rcbl_patch_3
;
rcbl_m_2_101:
	movem.l	d1-d4/a1,(a6)
	lea	20(a6),a6
	move.l	d2,d0
	bra	rcbl_patch_3
;
rcbl_m_2_100:
	movem.l	d1-d4,(a6)
	lea	16(a6),a6
	move.l	d2,d0
	bra	rcbl_patch_3
;
rcbl_m_2_011:
	move.l	d2,(a6)+
rcbl_m_2_010:
	move.l	d2,(a6)+
rcbl_m_2_001:
	move.l	d2,(a6)+
rcbl_m_2_000:
	move.l	d2,d0
	bra	rcbl_patch_3
;
rcbl_m_1_1111:
	move	d2,(a6)+
rcbl_m_1_1110:
	movem.l	d1-d4/a1/a3/a4,(a6)
	lea	28(a6),a6
	move.l	d2,d0
	bra	rcbl_patch_3
;
rcbl_m_1_1101:
	move	d2,(a6)+
rcbl_m_1_1100:
	movem.l	d1-d4/a1/a3,(a6)
	lea	24(a6),a6
	move.l	d2,d0
	bra	rcbl_patch_3
;
rcbl_m_1_1011:
	move	d2,(a6)+
rcbl_m_1_1010:
	movem.l	d1-d4/a1,(a6)
	lea	20(a6),a6
	move.l	d2,d0
	bra	rcbl_patch_3
;
rcbl_m_1_1001:
	move	d2,(a6)+
rcbl_m_1_1000:
	movem.l	d1-d4,(a6)
	lea	16(a6),a6
	move.l	d2,d0
	bra	rcbl_patch_3
;
rcbl_m_1_0110:
	move.l	d2,(a6)+
rcbl_m_1_0100:
	move.l	d2,(a6)+
rcbl_m_1_0010:
	move.l	d2,(a6)+
rcbl_m_1_0000:
	move.l	d2,d0
	bra	rcbl_patch_3
;
rcbl_m_1_0111:
	move.l	d2,(a6)+
rcbl_m_1_0101:
	move.l	d2,(a6)+
rcbl_m_1_0011:
	move.l	d2,(a6)+
rcbl_m_1_0001:
	move	d2,(a6)+
	move.l	d2,d0
	bra	rcbl_patch_3
;
rcbl_r_8:
	movem.l	rcbl_rdm(pc),d2-d6
	movem.l	(a6),d0-d1
	and.l	d2,d0
	and.l	d2,d1
	or.l	d3,d0
	or.l	d4,d1
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	movem.l	(a6),d0-d1
	and.l	d2,d0
	and.l	d2,d1
	or.l	d5,d0
	or.l	d6,d1
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	add	a5,a6
	dbra	d7,rcbl_loop
	bra.s	rcbl_exit
;
rcbl_r_4:
	movem.l	(a6),d0-d1
	and.l	d6,d0
	and.l	d6,d1
	add.l	a2,d0
	add.l	a3,d1
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	add	a5,a6
	dbra	d7,rcbl_loop
	bra.s	rcbl_exit
;
rcbl_r_2:
	move.l	(a6),d0
	and.l	d6,d0
	add.l	a2,d0
	move.l	d0,(a6)+
	add	a5,a6
	dbra	d7,rcbl_loop
	bra.s	rcbl_exit
;
rcbl_r_1:
	move	(a6),d0
	and	d6,d0
	add	a2,d0
	move	d0,(a6)+
rcbl_next:
	add	a5,a6
	dbra	d7,rcbl_loop
rcbl_exit:
	movem.l	(sp)+,d3-d7/a3-a6
	rts
;
;
rcbl_sing_ld_4:
	movem.l	rcbl_ld(pc),d2-d3
	addq	#8,a5
.loop:
	movem.l	(a6),d0-d1
	and.l	d5,d0
	and.l	d5,d1
	or.l	d2,d0
	or.l	d3,d1
	movem.l	d0-d1,(a6)
	add	a5,a6
	dbra	d7,.loop
	bra	rcbl_exit
;
;
rcbl_sing_ld_2:
	move.l	rcbl_ld(pc),d2
	addq	#4,a5
.loop:
	move.l	(a6),d0
	and.l	d5,d0
	or.l	d2,d0
	move.l	d0,(a6)
	add	a5,a6
	dbra	d7,.loop
	bra	rcbl_exit
;
;
rcbl_sing_ld_1:
	move	rcbl_ld(pc),d2
	addq	#2,a5
.loop:
	move	(a6),d0
	and	d5,d0
	or	d2,d0
	move	d0,(a6)
	add	a5,a6
	dbra	d7,.loop
	bra	rcbl_exit
;
rcbl_sing_md_4:
	movem.l	rcbl_md(pc),d2-d3
	addq	#8,a5
.loop:
	movem.l	d2-d3,(a6)
	add	a5,a6
	dbra	d7,.loop
	bra	rcbl_exit
;
;
rcbl_sing_md_2:
	move.l	rcbl_md(pc),d2
	addq	#4,a5
.loop:
	move.l	d2,(a6)
	add	a5,a6
	dbra	d7,.loop
	bra	rcbl_exit
;
;
rcbl_sing_md_1:
	move	rcbl_md(pc),d2
	addq	#2,a5
.loop:
	move	d2,(a6)
	add	a5,a6
	dbra	d7,.loop
	bra	rcbl_exit
;
;
rcbl_pair_4:
	add	#16,a5
.loop:
	movem.l	(a6),d0-d3
	and.l	d5,d0
	and.l	d5,d1
	and.l	d6,d2
	and.l	d6,d3
	add.l	a0,d0
	add.l	a1,d1
	add.l	a2,d2
	add.l	a3,d3
	movem.l	d0-d3,(a6)
	add	a5,a6
	dbra	d7,.loop
	bra	rcbl_exit
;
rcbl_pair_2:
	addq	#8,a5
.loop:
	movem.l	(a6),d0-d1
	and.l	d5,d0
	and.l	d6,d1
	add.l	a0,d0
	add.l	a2,d1
	movem.l	d0-d1,(a6)
	add	a5,a6
	dbra	d7,.loop
	bra	rcbl_exit
;
rcbl_pair_1:
	addq	#4,a5
	move	d6,d5
	move.l	a0,d2
	move	a2,d2
.loop:
	move.l	(a6),d0
	and.l	d5,d0
	add.l	d2,d0
	move.l	d0,(a6)
	add	a5,a6
	dbra	d7,.loop
	bra	rcbl_exit
;
rcbl_next_2:
	add	a5,a6
	dbra	d7,rcbl_loop_2
	movem.l	(sp)+,d3-d7/a3-a6
	rts
;
rcbl_loop_2:
	jmp	(a0)
;
	rept	512
	move.l	d2,(a6)+
	endr
rcbl_blank_longs:
	jmp	(a3)
;
;
rc_truecol_blank:	
; arguments:	d0=x.y  d1=h.w  d2=colour  a0->vbase
; destroys:	d0-d2/a0-a2
; NB: a6 -> base of first scanline to process
; NB: d7 is ready for loop
	move	d2,d3
	swap	d2
	move	d3,d2		;d2 = 2 identical colour words
; NB: d2 is ready for loop
	swap	d0		;d0 = x
	add	d0,d0		;d0 = 2*x
	add	d0,a6		;a6 -> left edge of dest block
; NB: a6 is ready for loop
	clr.l	d3
	move	d1,d3		;d3 = w  affected pixels (=words) per line
	add	d3,d3		;d3 = 2*w  affected bytes per line
	neg.l	d3
	add.l	rc_bytes_lin(pc),d3	;d3 = offset for unaffected bytes per line
	move.l	d3,a5		;a5 = offset between block lines
; NB: a5 is ready for loop
	btst	#0,d1		;odd or even number of words to move per line ?
	bne.s	.set_odd
.set_even:
	lea	rcbl_blank_longs(pc),a0
	lea	rcbl_next_2(pc),a3
	sub	d1,a0			;a0 adjusted to move needed longs
	jmp	(a0)
;
.set_odd:
	subq	#1,d1			;mark 1 word handled
	bgt.s	.set_odd_l		;go fix longs if needed
	lea	.blank_sw(pc),a0
	lea	rcbl_next_2(pc),a1
.blank_sw:
	move	d2,(a6)+
	jmp	(a1)
;
.set_odd_l:
	lea	.blank_sw(pc),a0
	lea	rcbl_blank_longs(pc),a1
	lea	rcbl_next_2(pc),a3
	sub	d1,a1			;a1 adjusted to move needed longs
	jmp	(a0)
;
;
;	ends	rc_blank
; ----------------------------------------------------------------------------
rc_intersect:		;GRECT rc_intersect(GRECT rect_1,GRECT rect_2)
	_debdef	rc_intersect,2
;
;arguments:	d0=x1.y1  d1=w1.h1  d2=x2.y2  d3=w2.h2
;results:	d0=x3.y3  d1=w3.h3  if intersect, else d0=-1 (flagged MI)
;
	add	d0,d1	;d1 = w1.(y1+h1)
	add	d2,d3	;d3 = w2.(y2+h2)
	cmp	d3,d1
	ble.s	.keep_y4
	move	d3,d1	;d1 = w1.(y2+h2)
.keep_y4:		;d1 = w1.y4 = w1.min(y1+h1,y2+h2)
	cmp	d2,d0
	bge.s	.keep_y3
	move	d2,d0	;d0 = x1.y2
.keep_y3:		;d0 = x1.y3 = x1.max(y1,y2)
	sub	d0,d1	;d1 = w1.h3 = w1.(y4-y3)
	ble.s	.error
	swap	d3	;d3 = (y2+h2).w2
	swap	d2	;d2 = y2.x2
	swap	d1	;d1 = h3.w1
	swap	d0	;d0 = y3.x1
	add	d0,d1	;d1 = h3.(x1+w1)
	add	d2,d3	;d3 = (y2+h2).(x2+w2)
	cmp	d3,d1
	ble.s	.keep_x4
	move	d3,d1	;d1 = h3.(x2+w2)
.keep_x4:		;d1 = h3.x4 = h3.min(x1+w1,x2+w2)
	cmp	d2,d0
	bge.s	.keep_x3
	move	d2,d0	;d0 = y3.x2
.keep_x3:		;d0 = y3.x3 = y3.max(x1,x2)
	sub	d0,d1	;d1 = h3.w3 = h3.(x4-x3)
	ble.s	.error
	swap	d1	;d1 = w3.h3
	swap	d0	;d0 = x3.y3
	rts
;
.error:
	moveq	#-1,d0	;d0 = -1  and also flag MI
	rts
;
;	ends	rc_intersect
; ----------------------------------------------------------------------------
rc_joint:		;GRECT rc_intersect(GRECT rect_1,GRECT rect_2)
	_debdef	rc_joint,2
;
;arguments:	d0=x1.y1  d1=w1.h1  d2=x2.y2  d3=w2.h2
;results:	d0=x3.y3  d1=w3.h3  if joint, else d2=-1 (flagged MI)
;
	move.l	d0,d4
	move.l	d1,d5
	add.l	d4,d5
	add.l	d2,d3
	cmp	d4,d2
	bls.s	.min_y3
	exg	d4,d2
	exg	d5,d3
.min_y3:
	cmp	d3,d4
	bhi.s	.error
	cmp	d3,d5
	bls.s	.incl_y
	cmp	d4,d2
	bne.s	.noincl_y
	exg	d4,d2
	exg	d5,d3
	bra.s	.incl_ne_y
;
.incl_y:
	bne.s	.incl_ne_y
	cmp	d4,d2
	bne.s	.incl_ne_y
.equal_y:
	swap	d2
	swap	d3
	swap	d4
	swap	d5
	cmp	d4,d2
	bls.s	.min_x3
	exg	d4,d2
	exg	d5,d3
.min_x3:
	cmp	d3,d4
	bhi.s	.error
	cmp	d5,d3
	bhs.s	.max_x7
.make_d5_x7:
	exg	d5,d3
.max_x7:
	swap	d2
.exitswap_d3:
	swap	d3
	move.l	d2,d0
	move.l	d3,d1
	sub.l	d0,d1
	rts
;
.error:
	moveq	#-1,d2
	rts
;
.noincl_y:
	swap	d2
	swap	d3
	swap	d4
	swap	d5
	cmp	d2,d4
	bne.s	.error
	cmp	d3,d5
	beq.s	.make_d5_x7
	bra.s	.error
;
.incl_ne_y:
	swap	d3
	swap	d5
	cmp	d3,d5
	bls.s	.exitswap_d3
	bra.s	.error
;
;	ends	rc_joint
;-----------------------------------------------------------------------------
	endc	;RA_RC_defined
;-----------------------------------------------------------------------------
;End of file:	RA_RC.S
;-----------------------------------------------------------------------------
