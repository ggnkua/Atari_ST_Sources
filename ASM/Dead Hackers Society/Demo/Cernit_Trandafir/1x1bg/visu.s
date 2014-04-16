; Altparty 2009 STe demo
; Texturemapper on top of 1x1 background
;
; visu.s

		section	text

YCLIP		=	1
XCLIP		=	0
;SIZEOPT	=	0
BLENDER_OBJ	=	1

ACCU		=	8
ACCUMASK	=	$ff00

bg1x1_max_y	=	100
bg1x1_max_x	=	160
bg1x1_max_ix	=	52
bg1x1_min_ix	=	-52

bg1x1_maxface:		equ	32		;maximum number of faces to support
bg1x1_maxvertex:	equ	32		;maximum number of vertexes to support

;done_backface:	equ	0
;done_sort:	equ	1

;%%%%%%%%%%%%%%%%%%%%%%% Backface Faces %%%%%%%%%%%%%%%%%%%%%%%%%
; input:
; bg1x1_numface.w = number of faces
bg1x1_backfaces:
		clr.w	bg1x1_num_visible
		move.l	bg1x1_facesadr,a3
		lea	bg1x1_visible_faces,a5
		lea	bg1x1_rotcoords,a0
		lea	2(a0),a1		;ycoord
		lea	4(a0),a2		;zcoord
		clr.w	d7			;face num
.backface:
		movem.w	(a3)+,d0-d2
		addq.l	#2,a3			;skip F4
		add.w	d0,d0
		add.w	d1,d1
		add.w	d2,d2

		move.w	(a0,d1),d3		;DX1=XP(F2)-XP(F1)
		sub.w	(a0,d0),d3		;dx1
		move.w	(a1,d1),d4		;DY1=YP(F2)-YP(F1)
		sub.w	(a1,d0),d4		;dy1
		move.w	(a0,d2),d5		;DX2=XP(F3)-XP(F1)
		sub.w	(a0,d0),d5		;dx2
		move.w	(a1,d2),d6		;DY2=YP(F3)-YP(F1)
		sub.w	(a1,d0),d6		;dy2

		muls	d3,d6			;DV=DX1*DY2-DX2*DY1
		muls	d4,d5
		sub.l	d5,d6			;nv
		blt.b	.noPoly

		addq.w	#1,bg1x1_num_visible
		move.w	d7,(a5)+		;face num

		move.w	(a2,d0),d4		;z1+z2+z3+z4
		add.w	(a2,d1),d4
		add.w	(a2,d2),d4
		asr.w	#4,d4 			;8 bit zval
		ifeq	BLENDER_OBJ
		neg.b	d4			;Blender / Neon ?
		endc
		move.w	d4,(a5)+		;zval
.noPoly:	
		addq.w	#1,d7
		cmp.w	bg1x1_numface,d7
		blt.s	.backface
.done:
		rts

;###############################################################
;		Draw
;input:
; bg1x1_destadr.l 	=	address output buffer
; bg1x1_center.l	=	center of output buffer
; bg1x1_fillrout.l	=	address of envmap fillrout

bg1x1_get_faces:
		lea.l	bg1x1_visible_sorted,a0
		subq.w	#1,bg1x1_num_visible
		blt	.done
.getface:
		move.l	(a0)+,d0		;face:zval
		swap	d0			;xxxx:face
		lsl.w	#2+1,d0			;muls #4+2
		move.l	bg1x1_facesadr,a3
		add.w	d0,a3
		movem.w	(a3)+,d0-d2
		move.l	a0,-(sp)
		lea.l	bg1x1_rotcoords,a0
		lea.l	bg1x1_sortcoords,a1
		lea.l	bg1x1_mapcoords,a4
		add.w	d0,d0
		add.w	d1,d1
		add.w	d2,d2
		move.l	(a0,d2),(a1)		;xp(f1)
		move.l	(a0,d1),4(a1)		;xp(f2)
		move.l	(a0,d0),8(a1)		;xp(f3)
		bsr	bg1x1_trace_map		;polygon outline
		move.l	bg1x1_fillrout,a5	;polygon filler
		jsr	(a5)
		move.l	(sp)+,a0
		subq.w	#1,bg1x1_num_visible
		bge	.getface		
.done:
		rts

bg1x1_get_faces_env:
		lea.l	bg1x1_visible_sorted,a0
		subq.w	#1,bg1x1_num_visible
		blt	.done
.getface:
		move.l	(a0)+,d0		;face:zval
		swap	d0			;xxxx:face
		lsl.w	#2+1,d0			;muls #4+2
		move.l	bg1x1_facesadr,a3
		add.w	d0,a3
		movem.w	(a3)+,d0-d2
		move.l	a0,-(sp)
		lea.l	bg1x1_rotcoords,a0
		lea.l	bg1x1_sortcoords,a1
		lea.l	bg1x1_mapcoords,a4
;		ifne	ENVMAPPER
		lea.l	bg1x1_envcoords,a3
		move.l	(a3,d2),(a4)		;u3,v3
		move.l	(a3,d1),4(a4)		;u2,v2
		move.l	(a3,d0),8(a4)		;u1,v1
;		endc
		add.w	d0,d0
		add.w	d1,d1
		add.w	d2,d2
		move.l	(a0,d2),(a1)		;xp(f1)
		move.l	(a0,d1),4(a1)		;xp(f2)
		move.l	(a0,d0),8(a1)		;xp(f3)
		bsr.b	bg1x1_trace_map		;polygon outline
		move.l	bg1x1_fillrout,a5	;polygon filler
		jsr	(a5)
		move.l	(sp)+,a0
		subq.w	#1,bg1x1_num_visible
		bge	.getface		
.done:
		rts

; --------------------------------------------------------------
;		Trace Map
; --------------------------------------------------------------

bg1x1_num_edges	=	3

bg1x1_trace_map:	
		lea.l	bg1x1_inv_table+32768*2+4,a6	;+4 : comp for subq...
		move.l	(a1),2*2*bg1x1_num_edges(a1)	;wrap verts
		move.l	(a4),2*2*bg1x1_num_edges(a4)	;wrap verts
		move.w	2(a1),bg1x1_ymax	;init ymax = y1
		move.w	2(a1),bg1x1_ymin	;init ymin = y1

		move.w	#bg1x1_num_edges-1,.edgecnt
.drawedge:	
		movem.w	(a1),d0-d3		;x1/y1/x2/y2
		addq.l	#4,a1
		movem.w	(a4),d4-d7		;u1/v1/u2/v2
		addq.l	#4,a4
		lea	bg1x1_tracescr,a3
		lea	bg1x1_tracemap,a5

		;find y min/max for this face
		cmp.w	bg1x1_ymax,d1
		blt.b	.nomaxy
		move.w	d1,bg1x1_ymax
.nomaxy:
		cmp.w	bg1x1_ymin,d1
		bgt.b	.nominy
		move.w	d1,bg1x1_ymin
.nominy:

		;flip polygon?
		cmp.w	d1,d3
		bgt.b	.ydirok
		exg	d0,d2
		exg	d1,d3		
		exg	d4,d6
		exg	d5,d7
		lea	256*2(a3),a3
		lea	256*4(a5),a5
.ydirok:
		sub.w	d1,d3			;y2-y1 = dy
		subq.w	#1,d3
		blt.b	.nodraw

		sub.w	d0,d2			;x2-x1 = dx
		lsl.w	#ACCU,d0
		lsl.w	#ACCU,d2

		add.w	d1,d1
		add.w	d1,a3
		add.w	d1,d1
		add.w	d1,a5

		lea	(a6,d3),a0
		move.w	(a0,d3),d1
		muls	d1,d2
		swap	d2			;dx_dy
		
		sub.w	d4,d6			;u2-u1 = du
		muls	d1,d6
		swap	d6			;du_dy

		sub.w	d5,d7			;v2-v1
		muls	d1,d7
		swap	d7			;dv_dv = dv
.trace_y:
		add.w	d2,d0
		add.w	d6,d4
		add.w	d7,d5
		move.w	d0,d1
		asr.w	#ACCU,d1
		move.w	d1,(a3)+
		move.w	d4,(a5)+
		move.w	d5,(a5)+
		dbra	d3,.trace_y
.nodraw:
		subq.w	#1,.edgecnt
		bge	.drawedge
		
		rts

.edgecnt:	dc.w	0

; --------------------------------------------------------------
;		2 instruction texturemap 144*100 256col chunky
; --------------------------------------------------------------

bg1x1_filler_160x100_256col:	
		move.l	bg1x1_destadr,a6
		move.l	bg1x1_center,a5
		lea	bg1x1_tracescr,a1
		lea	bg1x1_tracemap,a2

		move.w	bg1x1_ymax,d7
		move.w	bg1x1_ymin,d6
		sub.w	d6,d7			;yfill counter
		move.w	d7,d1
		subq.w	#1,d7
		blt.w	.nofill
		asr.w	#1,d1			;midpoint

		move.w	d6,d0			;scratch
		add.w	d0,d0
		add.w	d0,a1
		add.w	d0,d0
		add.w	d0,a2

		add.w	d1,d1
		lea	(a1,d1),a3
		add.w	d1,d1
		lea	(a2,d1),a4

		move.w	2*256(a3),d0
		move.w	4*256(a4),d2
		move.w	4*256+2(a4),d4
		sub.w	(a3),d0			;x2_t-x_t
		ble	.nofill
		sub.w	(a4)+,d2
		sub.w	(a4),d4

		lea	bg1x1_inv_table+32768*2,a0
		add.w	d0,d0			;add d0,d0 here. SEE BELOW!
;		and.w	#-2,d0
		move.w	(a0,d0.w),d1		;d1 scratch
;		divs	d0,d2
		muls	d1,d2
		swap	d2
;		divs	d0,d4
		muls	d1,d4
		swap	d4
		
		moveq.l	#0,d1
		movem.w	d6-d7,-(a7)
		lea.l	bg1x1_tracevect,a0
		moveq.l	#0,d6
;		move.w	#ACCUMASK,d7
;		add.l	d0,d0
.make_tracevect:
		add.w	d2,d6			;x	
		add.w	d4,d1			;y
		move.w	d6,d3
		asr.w	#ACCU,d3
		move.w	d1,d5
		move.b	d3,d5
		move.w	d5,(a0)+
		dbra	d0,.make_tracevect

		movem.w	(a7)+,d6-d7

;--------------	actual writer ----------------------------------

;		move.w	bg1x1_ymax,d7
;		move.w	bg1x1_ymin,d6

		muls.w	#bg1x1_max_x/2,d6	;start line
		;move.l	a6,d4			;a6 = screen_adr
		move.l	bg1x1_destadr,d4
		add.l	#bg1x1_max_x/2*bg1x1_max_y,d4	;d4 = last line for writing

		move.w	#bg1x1_max_ix-1,d0	;data for xclip
		swap	d0
		move.w	#bg1x1_min_ix,d0
.y:		
		;move.l	a6,a0			;screen_adr
		;add.l	a5,a0			;center
		move.l	bg1x1_destadr,a6
		move.l	a6,a0
		add.l	bg1x1_center,a0
 		add.l	d6,a0			;line to write at

		move.w	(a1)+,d1		;d1 = scanline pixelstart offset
		move.w	(a2)+,d3		;d3 =
		move.w	(a2)+,d5		;d5 =

		ifne	YCLIP
		;------------------------------	y clip
		cmp.l	a6,a0			;y top clip
		blt	.noxfill
		cmp.l	d4,a0			;y bot clip
		bgt	.noxfill
		endc
		
		swap	d7			;y->xcount
		move.w	256*2-2(a1),d7		;xcounter
		sub.w	d1,d7			;xcounter-start offset
		ble.s	.noxswap		;if smaller no line

		lea.l	bg1x1_tracevect,a4

		ifne	XCLIP
		;------------------------------	x clip left
		cmp.w	d0,d1			;d0 = -144 ; d1 = xpos
		bgt.s	.ok			;ok if higher than -144
		sub.w	d0,d1			;get difference from -144 and xpos
		neg	d1			;make positive
		cmp.w	d1,d7			;see if line is longer than difference
		blt.s	.noxswap		;line shorter than cliplength
		sub.w	d1,d7			;sub the difference to x counter
		add.w	d1,a4
		add.w	d1,a4
		move.w	d0,d1			;force starting val
.ok:
		;------------------------------	x clip right
		swap	d0
		swap	d3
		move.w	d1,d3			;d1 = x start offset
		add.w	d7,d3			;d7 = length of line
		cmp.w	d0,d3			;d0 = 143 (max val)
		blt.s	.ok2
		cmp.w	d0,d1
		bgt.s	.noxswap
		move.w	d0,d3			;d3 = 143
		sub.w	d1,d3			;143 - start ofs 
		move.w	d3,d7			;= max length
.ok2:		swap	d3

		endc
		
.nosh:
		move.l	bg1x1_textureadr,a3
		move.l	bg1x1_textureadr2,a6
		asr.w	#ACCU,d3
		move.b	d3,d5
		add.w	d5,a3
		add.w	d5,a6

		asr.w	#1,d1
		lea	(a0,d1),a0		;lea does not affect carry
		bcc.s	.even			;carry clear?
.noteven:
		move.b	(a0),d5
		and.b	#$f0,d5
		move.w	(a4)+,d3
		or.b	(a3,d3.w),d5
		move.b	d5,(a0)+
		subq.w	#1,d7
.even:
		move.w	d7,d3
		add.w	d7,d7
		lea.l	oflist,a5
		move.w	(a5,d7.w),d7
		lea.l	tmap,a5
		jsr	(a5,d7.w)		

.noxswap:
		swap	d7
		swap	d0
.noxfill:
		add.l	#bg1x1_max_x/2,d6	;next line
		dbra	d7,.y
.nofill:
		rts

tmap:						;code table
		rept	bg1x1_max_x/2
		move.w	(a4)+,d5
		move.b	(a6,d5.w),d1
		move.w	(a4)+,d5
		or.b	(a3,d5.w),d1
		move.b	d1,(a0)+
		endr

		btst	#0,d3
		beq.s	.even2

		move.b	(a0),d1
		and.b	#$0f,d1
		move.w	(a4)+,d5
		or.b	(a6,d5.w),d1
		move.b	d1,(a0)
.even2:
		rts

ofs:		equ	14

		dc.w	bg1x1_max_x/2*14
oflist:
q		set	bg1x1_max_x/2
		rept	bg1x1_max_x/2
		dc.w	q*ofs
		dc.w	q*ofs
q		set	q-1
		endr
		;ds.b	10000

;%%%%%%%%%%%%%%%%%%%%%%%%%% Counting Sort %%%%%%%%%%%%%%%%%%%%%%%%%%
; input: sort facelist in z order
; timing: 25-28 scans
;
bg1x1_counting_sort:
		lea.l	cntrs,a0		;first clear all counters
		rept	256/4
		clr.l	(a0)+
		endr

		lea.l	cntrs,a0		;inc counters
		;lea	facelst,a1
		lea.l	bg1x1_visible_faces,a1
		move.w	bg1x1_num_visible,d7
	 	subq.w	#1,d7
		blt.s	.doneinc		;sanity check
.inc:		
		move.l	(a1)+,d0		;face num : z val
		addq.b	#1,(a0,d0.w)		;inc counter
		dbra	d7,.inc
.doneinc:

		lea	cntrs,a0		;calc cumulative count
		rept	255
		move.b	(a0)+,d0
		add.b	d0,(a0)
		endr

		lea.l	cntrs,a0		;copy elements
		lea.l	bg1x1_visible_faces,a1
		lea.l	bg1x1_visible_sorted,a2
		move.w	bg1x1_num_visible,d7
		subq.w	#1,d7
		blt.s	.donecpy		;sanity check
		lsl.w	#2,d7
.cpy:
		move.l	(a1,d7.w),d0		;face num : z val
		subq.b	#1,(a0,d0.w)		;dec cum counters
		clr.w	d1
		move.b	(a0,d0.w),d1 		;place for curr z val
		add.w	d1,d1
		add.w	d1,d1
		move.l	d0,(a2,d1.w)		;(a2,d1.w*4)	
		subq.w	#4,d7
		bge.s	.cpy
.donecpy:
		rts

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		section	data

MAXT	= (2<<15-1)	;max size for uv coord
UVMAX	= MAXT/2
			;FIXME: global uv coords for triangle
bg1x1_mapcoords:	dc.w	0,0, UVMAX/2,0, UVMAX/4,UVMAX, 0,0

		section	bss

cntrs:			ds.w	256
bg1x1_destadr:		ds.l	1			;address of output buffer
bg1x1_center:		ds.l	1			;center of output buffer (offset)
bg1x1_fillrout:		ds.l	1			;address of envmap polygon filelr
bg1x1_numvertex:	ds.w	1			;number of vertexes
bg1x1_numface:		ds.w	1			;number of faces
bg1x1_coordsadr:	ds.l	1			;address of vertexlist
bg1x1_ecoordsadr:	ds.l	1			;address of env vertexlist
bg1x1_anx:		ds.w	1			;x angle
bg1x1_any:		ds.w	1			;y angle
bg1x1_anz:		ds.w	1			;z angle
bg1x1_q:		ds.l	1
bg1x1_num_visible:	ds.w	1
bg1x1_ymax:		ds.w	1
bg1x1_ymin:		ds.w	1
bg1x1_sortcoords:	ds.w	2*(4+1)
bg1x1_visible_faces:	ds.l	bg1x1_maxface
bg1x1_visible_sorted:	ds.l	bg1x1_maxface
bg1x1_zposition:	ds.w	bg1x1_maxface
bg1x1_textureadr:	ds.l	1			;address of texture (center point)
bg1x1_textureadr2:	ds.l	1			;address of texture (center point)
bg1x1_facesadr:		ds.l	1			;address of faceslist

bg1x1_rotcoords:	ds.w	bg1x1_maxvertex*4	;x,y,z,0
bg1x1_envcoords:	ds.w	bg1x1_maxvertex*4	;u,v,0,0

bg1x1_tracevect:	ds.w	256

			ds.w	256*2
bg1x1_tracescr:		ds.w	256*2
			ds.w	256*2

			ds.w	256*2
bg1x1_tracemap:		ds.w	256*4
			ds.w	256*2

;bg1x1_inv_table:	ds.b	128*1024		;128kb

	section	text
