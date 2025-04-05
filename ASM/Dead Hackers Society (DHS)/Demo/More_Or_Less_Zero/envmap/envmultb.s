
		section	text

rots:		equ	7
maps:		equ	2^rots
ands:		equ	$ff80

env_maxy:	equ	50
env_maxx:	equ	104
env_maxix:	equ	52
env_minix:	equ	-52

env_maxface:	equ	32					;maximum number of faces to support
env_maxvertex:	equ	32					;maximum number of vertexes to support


;---------------------------------------------------------------
;		Rotate
;---------------------------------------------------------------

; input for matrix rotation
;
; env_coordsadr.l	=	address to vertexlist
; env_ecoordsadr.l	=	address to env vertexlist
; env_numvertex.w	=	numbero f vertexes

env_mul_rotate:	lea.l	matrix,a0
		move.w	env_anx,d0				;x-angle
		move.w	env_any,d1				;y-angle
		move.w	env_anz,d2				;z-angle 
		bsr.w 	matrix_rotate				;rotate it

		move.l	env_coordsadr,a0
		lea.l	env_rotcoords,a1
		lea.l	matrix,a2
		move.w	env_numvertex,d0
		moveq.l	#0,d1
		moveq.l	#0,d2
		moveq.l	#0,d3
		bsr.w	transform_mul6_pro	;supersnabb
	;	bsr	transform_mul		;korrekt

		;bsr	transform_mul6	;utan perspektiv för test 

		move.l	env_ecoordsadr,a0
		lea.l	env_envcoords,a1
		lea.l	matrix,a2
		move.w	env_numvertex,d0
		moveq.l	#0,d1
		moveq.l	#0,d2
		moveq.l	#0,d3
		bsr.w	transform_mul6
		
		rts


; --------------------------------------------------------------
;		Backface Faces
; --------------------------------------------------------------

; input
;
; env_numface.w		=	number of faces

env_backfaces:	clr.w	env_numsynlfac
		move.l	env_facesadr,a3
		lea.l	env_synl_faces,a5
		lea.l	env_zposition,a6
		lea.l	env_rotcoords,a0
		move.w	env_numface,d7
		subq.w	#1,d7
.drawloop:
		movem.w	(a3)+,d0-d2

;---------------
		movem.w	d0-d2,-(sp)	
		add.w	d0,d0
		add.w	d1,d1
		add.w	d2,d2
;---------------

		move.w	0(a0,d1),d3				;DX1=XP(F2)-XP(F1)
		sub.w	0(a0,d0),d3				;dx1
		move.w	2(a0,d1),d4				;DY1=YP(F2)-YP(F1)
		sub.w	2(a0,d0),d4				;dy1
		move.w	0(a0,d2),d5				;DX2=XP(F3)-XP(F1)
		sub.w	0(a0,d0),d5				;dx2
		move.w	2(a0,d2),d6				;DY2=YP(F3)-YP(F1)
		sub.w	2(a0,d0),d6				;dy2

;---------------
		movem.w	(sp)+,d0-d2
;---------------

		muls	d3,d6					;DV=DX1*DY2-DX2*DY1
		muls	d4,d5
		sub.l	d5,d6					;nv
		move.w	(a3)+,d3				;F4=F(N+3)
		tst.w	d6					;If NV>0
		blt.b	.noPoly
		addq.w	#1,env_numsynlfac
		move.w	env_numface,d6
		subq.w	#1,d6
		sub.w	d7,d6
		move.w	d6,(a5)+
		; face num

;---------------
		;movem.w	d0-d2,-(sp)
		add.w	d0,d0
		add.w	d1,d1
		add.w	d2,d2
;---------------

		move.w	4(a0,d0),d4				;z1+z2+z3+z4
		add.w	4(a0,d1),d4
		add.w	4(a0,d2),d4

;---------------
		;movem.w	(sp)+,d0-d2
;---------------

		lsr.w	#4,d4 					; fixa 8 bit zval
		neg.b	d4                                      ;no neg for Blender objects
		move.w	d4,(a5)+
.noPoly:	dbra	d7,.drawloop				;Next N

		rts



; --------------------------------------------------------------
;		Draw
; --------------------------------------------------------------

; input for drawing enviornment mapped polygons
;
; env_destadr.l 	=	address output buffer
; env_center.l		=	center of output buffer
; env_fillrout.l	=	address of envmap fillrout


env_get_faces:	lea.l	env_synl_faces2,a5	;!!!!!!!!!!
		moveq.l	#0,d7
		move.w	env_numsynlfac,d7
		subq	#1,d7
		blt.s	.no
.tstface:	move.l	(a5)+,d0				; face:zval
		swap	d0					; xxxx:face
		muls	#4*2,d0
		;lea.l	faces,a3
		move.l	env_facesadr,a3
		add.w	d0,a3
		move.w	(a3)+,d0
		move.w	(a3)+,d1
		move.w	(a3)+,d2
		move.w	(a3)+,d3
		movem.l	d0-a5,-(a7)

		lea.l	env_rotcoords,a0
		lea.l	env_envcoords,a3
		lea.l	env_sortcoords,a1


;---------------
		;movem.w	d0-d2,-(sp)
		add.w	d0,d0
		add.w	d1,d1
		add.w	d2,d2
;---------------

		move.l	(a0,d2),(a1)+			;xp(f1)
		move.l	(a0,d1),(a1)+			;xp(f2)
		move.l	(a0,d0),(a1)+			;xp(f3)
		lea.l	env_mapcoords,a4
		move.l	(a3,d2),(a4)+			;u1,v1
		move.l	(a3,d1),(a4)+			;u1,v1
		move.l	(a3,d0),(a4)+			;u1,v1

;---------------
		;movem.w	(sp)+,d0-d2
;---------------

		sub.w	#4*4-4,a1
		sub.w	#4*4-4,a4
		bsr.b	env_trace_map				;polygon struct
		move.l	env_fillrout,a5				;polygon filler
		jsr	(a5)					;
		movem.l	(a7)+,d0-a5
		dbra	d7,.tstface
.no:		rts

; --------------------------------------------------------------
;		Trace Map
; --------------------------------------------------------------

env_sidor:	equ	3

env_trace_map:	
		lea.l	env_inv_table+32768*2,a6
		lea.l	env_ymax,a0
		move.l	#$ff8000ff,(a0)
		move.l	(a1),2*2*env_sidor(a1)
		move.l	(a4),2*2*env_sidor(a4)
		moveq.l	#env_sidor-1,d7
.draw:		move.l	d7,-(a7)
		move.w	(a1)+,d0				;x1
		move.w	(a1)+,d1				;y1
		move.w	(a1),d2					;x2
		move.w	2(a1),d3				;y2
		move.w	(a4)+,d4
		move.w	(a4)+,d5
		move.w	(a4),d6
		move.w	2(a4),d7
		lea.l	env_tracescr,a3
		lea.l	env_tracemap,a5
		cmp.w	(a0),d1
		blt.b	.nomaxy
		move.w	d1,(a0)
.nomaxy:	cmp.w	2(a0),d1
		bgt.b	.nominy
		move.w	d1,2(a0)
.nominy:	cmp.w	d1,d3
		bgt.b	.ydirok
		exg.l	d0,d2
		exg.l	d1,d3		
		exg.l	d4,d6
		exg.l	d5,d7
		lea.l	256*2(a3),a3
		lea.l	256*4(a5),a5
.ydirok:	sub.w	d1,d3					;y2-y1
		ble.b	.nodraw
		sub.w	d0,d2					;x2-x1
		ext.l	d2
		lsl.l	#rots,d2

;		divs	d3,d2					;dx

		move.l	d3,-(sp)
		add.w	d3,d3
		move.w	(a6,d3.w),d3
		muls	d3,d2
		swap	d2
		
		lsl.w	#rots,d0
		sub.w	d4,d6					;x2_map-x1_map
		sub.w	d5,d7					;y2_map-y1_map
		ext.l	d6
		ext.l	d7

;		divs	d3,d6					;dx_map
		muls	d3,d6
		swap	d6
;		divs	d3,d7					;dy_map
		muls	d3,d7
		swap	d7

		move.l	(sp)+,d3
		
		subq.w	#1,d3
		blt.b	.nodraw

;---------------
		;move.w	d1,-(sp)
		add.w	d1,d1
;---------------


		lea.l	(a3,d1),a3

;---------------
		add.w	d1,d1
;---------------

		lea.l	(a5,d1),a5

;---------------
		;move.w	(sp)+,d1
;---------------


.trace_y:	add.w	d2,d0
		add.w	d6,d4
		add.w	d7,d5
		move.w	d0,d1
		asr.w	#rots,d1
		move.w	d1,(a3)+
		move.w	d4,(a5)+
		move.w	d5,(a5)+
		dbra	d3,.trace_y
.nodraw:	move.l	(a7)+,d7
		dbra	d7,.draw				
		rts




; --------------------------------------------------------------
;		2 instruction texturemap 144*100 256col chunky
; --------------------------------------------------------------

env_filler_144x100_256col:	

		move.l	env_destadr,a6
		move.l	env_center,a5

		lea.l	env_tracescr,a1
		lea.l	env_tracemap,a2
		move.w	(a0)+,d7
		move.w	(a0),d6
		sub.w	d6,d7					;yfill counter
		move.w	d7,d1
		asr.w	#1,d1					;medel

;---------------
		move.w	d6,-(sp)
		add.w	d6,d6
;---------------

		lea.l	(a1,d6),a1

;---------------
		add.w	d6,d6
;---------------

		lea.l	(a2,d6),a2

;---------------
		move.w	(sp)+,d6
;---------------


		add.w	#256,d1

;---------------
		move.w	d1,-(sp)
		add.w	d1,d1
;---------------

		move.w	(a1,d1),d0
;---------------
		add.w	d1,d1
;---------------
		move.w	(a2,d1),d2
		move.w	2(a2,d1),d4
;---------------
		move.w	(sp)+,d1
;---------------


		sub.w	#256,d1

;---------------
		move.w	d1,-(sp)
		add.w	d1,d1
;---------------

		sub.w	(a1,d1),d0				;x2_t-x_t

;---------------
		move.w	(sp)+,d1
		tst.w	d0
;---------------

		ble.w	.nofill

;---------------
		;move.w	d1,-(sp)
		lsl.w	#2,d1
;---------------

		sub.w	(a2,d1),d2
		sub.w	2(a2,d1),d4

;---------------
		;move.w	(sp)+,d1
;---------------

;		ext.l	d2		;no divs -> we dont need this
;		ext.l	d4

		lea	env_inv_table+32768*2,a0
		add.l	d0,d0		;add d0,d0 here. SEE BELOW!
		move.w	(a0,d0.w),d1	;d1 scratch
;		divs	d0,d2
		muls	d1,d2
		swap	d2
;		divs	d0,d4
		muls	d1,d4
		swap	d4
		
		moveq.l	#0,d1
		movem.w	d6-d7,-(a7)
		lea.l	env_tracevect,a0
		moveq.l	#0,d6
		move.w	#ands,d7
;		add.l	d0,d0
.make_tracevect:
		add.w	d2,d6					;x	
		add.w	d4,d1					;y
		move.w	d6,d3
		asr.w	#rots,d3
		move.w	d1,d5
		and.w	d7,d5
		add.w	d3,d5
		move.w	d5,(a0)+
		dbra	d0,.make_tracevect

		move.l	d7,d2
		movem.w	(a7)+,d6-d7

		subq.w	#1,d7
		blt.w	.nofill

;--------------	actual writer ----------------------------------

		muls.w	#env_maxx/2,d6				;start line

		;move.l	a6,d4					;a6 = screen_adr
		move.l	env_destadr,d4
		add.l	#env_maxx/2*env_maxy,d4			;d4 = last line for writing

		move.w	#env_maxix-1,d0				;data for xclip
		swap	d0					;
		move.w	#env_minix,d0				;

.y:		
		;move.l	a6,a0					;screen_adr
		;add.l	a5,a0					;center
		move.l	env_destadr,a6
		move.l	a6,a0
		add.l	env_center,a0
 		add.l	d6,a0					;line to write at

		move.w	(a1)+,d1				;d1 = scanline pixelstart offset
		move.w	(a2)+,d3				;d3 =
		move.w	(a2)+,d5				;d5 =

		;------------------------------	y clip
		cmp.l	a6,a0					;y top clip
		blt	.noxfill				;
		cmp.l	d4,a0					;y bot clip
		bgt	.noxfill				;
		;------------------------------

		swap	d7					;y->xcount
		move.w	256*2-2(a1),d7				;xcounter

		sub.w	d1,d7					;xcounter-start offset
		ble.s	.noxswap				;if smaller no line

		lea.l	env_tracevect,a4			;

;		;------------------------------	x clip left
;		cmp.w	d0,d1					;d0 = -144 ; d1 = xpos
;		bgt.s	.ok					;ok if higher than -144
;		sub.w	d0,d1					;get difference from -144 and xpos
;		neg	d1					;make positive
;		cmp.w	d1,d7					;see if line is longer than difference
;		blt.s	.noxswap				;line shorter than cliplength
;		sub.w	d1,d7					;sub the difference to x counter
;		add.w	d1,a4
;		add.w	d1,a4
;		move.w	d0,d1					;force starting val
;.ok:		;------------------------------
;
;		;------------------------------	x clip right
;		swap	d0
;		swap	d3
;		move.w	d1,d3					;d1 = x start offset
;		add.w	d7,d3					;d7 = length of line
;		cmp.w	d0,d3					;d0 = 143 (max val)
;		blt.s	.ok2
;		cmp.w	d0,d1
;		bgt.s	.noxswap
;		move.w	d0,d3					;d3 = 143
;		sub.w	d1,d3					;143 - start ofs 
;		move.w	d3,d7					;= max length
;.ok2:		swap	d3
;		;------------------------------


.nosh:
		move.l	env_textureadr,a3
		move.l	env_textureadr2,a6
		asr.w	#rots,d3				;
		and.w	d2,d5					;
		add.w	d3,d5					;

		add.w	d5,a3					;
		add.w	d5,a6					;

		asr.w	#1,d1
		bcc.s	.even		;carry clear

.noteven:
		move.b	(a0,d1.w),d5
		and.b	#$f0,d5
		move.w	(a4)+,d3
		or.b	(a3,d3.w),d5
		move.b	d5,(a0,d1.w)
		addq.w	#1,d1
		subq.w	#1,d7
.even:
		add.w	d1,a0					;
 
		move.w	d7,d3
		add.w	d7,d7
		lea.l	oflist,a5
		move.w	(a5,d7.w),d7
		lea.l	tmap,a5
		jsr	(a5,d7.w)		


.noxswap:	swap	d7					;
		swap	d0					;
.noxfill:	add.l	#env_maxx/2,d6				;next line
		dbra	d7,.y					;
.nofill:	rts						;


tmap:		
		rept	env_maxx/2

		move.w	(a4)+,d5					;
		move.b	(a6,d5.w),d1
		*nop

		move.w	(a4)+,d5
		or.b	(a3,d5.w),d1
		move.b	d1,(a0)+

		endr


		btst	#0,d3
		beq.s	.even2

		move.w	(a4)+,d5					;
		move.b	(a0),d1
		and.b	#$0f,d1
		or.b	(a6,d5.w),d1
		move.b	d1,(a0)

.even2:

		rts

ofs:		equ	14
		dc.w	env_maxx/2*14
oflist:

q		set	env_maxx/2
		rept	env_maxx/2
		dc.w	q*ofs
		dc.w	q*ofs
q		set	q-1
		endr
		ds.b	10000


;%%% Counting Sort %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

counting_sort:			;sort facelist in z order

	;first clear all counters
	lea	cntrs,a0
	;move.w	#256-1,d7
;.cc:
	;clr.w	(a0)+
	;dbra	d7,.cc
	moveq.l	#0,d0
	rept	128
	move.l	d0,(a0)+
	endr

	;inc counters
	lea	cntrs,a0
	;lea	facelst,a1
	lea.l	env_synl_faces,a1
	;move.w	#NUMFACES-1,d7
	move.w	env_numsynlfac,d7
 	subq.w	#1,d7

.inc:
	move.l	(a1)+,d0	;face num : z val
	add.w	d0,d0	;68000!!!
	addq.w	#1,(a0,d0.w)	;.l ???(a0,d0.w*2)	;inc counter
	dbra	d7,.inc

	;calc cumulative count
	lea	cntrs,a0
	move.w	#256-1-1,d7
.cumc:
	move.w	(a0)+,d0
	add.w	d0,(a0)
	dbra	d7,.cumc

	;copy elements
	lea	cntrs,a0
	lea	env_synl_faces,a1
	lea	env_synl_faces2,a2
	;move.w	#NUMFACES-1,d7
	move.w	env_numsynlfac,d7
	subq.w	#1,d7
.cpy:
	move.w	d7,d6
	lsl.w	#2,d6
	move.l	(a1,d6.w),d0		;face num : z val
	add.w	d0,d0			;68000!!!!
	subq.w	#1,(a0,d0.w)		;.l??? (a0,d0.w*2)	;dec cum counters
	move.w	(a0,d0.w),d1 		;.l ??? (a0,d0.w*2),d1	;place for curr z val
	lsl.w	#2,d1
	move.l	d0,(a2,d1.w)		;(a2,d1.w*4)	
	dbra	d7,.cpy

	rts




; --------------------------------------------------------------
		section	data
; --------------------------------------------------------------

	
env_mapcoords:	dc.w	0,0,maps^2-1,0,maps^2-1,maps^2-1,0,maps^2-1,0,0



; --------------------------------------------------------------
		section	bss
; --------------------------------------------------------------

cntrs:		ds.w	256
env_destadr:	ds.l	1					;address of output buffer
env_center:	ds.l	1					;center of output buffer (offset)
env_fillrout:	ds.l	1					;address of envmap polygon filelr
env_numvertex:	ds.w	1					;number of vertexes
env_numface:	ds.w	1					;number of faces
env_coordsadr:	ds.l	1					;address of vertexlist
env_ecoordsadr:	ds.l	1					;address of env vertexlist
env_anx:	ds.w	1					;x angle
env_any:	ds.w	1					;y angle
env_anz:	ds.w	1					;z angle
env_q:		ds.l	1
env_numsynlfac:	ds.w	1
env_ymax:	ds.w	1
env_ymin:	ds.w	1
env_sortcoords:	ds.w	2*(4+1)
env_synl_faces:	ds.l	env_maxface
env_synl_faces2:	ds.l	env_maxface
env_zposition:	ds.w	env_maxface
env_textureadr:	ds.l	1					;address of texture (center point)
env_textureadr2:ds.l	1					;address of texture (center point)
env_facesadr:	ds.l	1					;address of faceslist

env_rotcoords:	ds.w	env_maxvertex*4				;x,y,z,0
env_envcoords:	ds.w	env_maxvertex*4				;u,v,0,0

env_tracevect:	ds.w	256

		ds.w	256*2
env_tracescr:	ds.w	256*2
		ds.w	256*2

		ds.w	256*2
env_tracemap:	ds.w	256*4
		ds.w	256*2

		section	text
		
		
