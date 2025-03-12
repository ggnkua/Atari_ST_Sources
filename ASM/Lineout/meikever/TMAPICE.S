; texturemapped ice cream
;

IceCone.MEASURE_CPU:=	0
IceCone.NR_VBLS:=	4
IceCone.PERSPECTIVE:=	0

IceCone.TRANSLATION:=	500

IceCone.BALL_WIDTH:=	25

;- test shell --------------------------------------------------------------

	ifnd	DEMO_SYSTEM
testmode:=	0
	bra	end_libs
	include	mat.s
	include common.s
	include	lib_3d.s
	text
end_libs:
	include	tester.s
	text
	endc


;- plugin table ------------------------------------------------------------

	dc.l	IceCone.mainloop
	dc.l	IceCone.init
	dc.l	IceCone.rt_init			; 2
	dc.l	IceCone.deinit
	dc.l	0

;- plugin routines ---------------------------------------------------------

IceCone.init:
	rts

IceCone.rt_init:
	move.w	#160,Viewport.settingsTable+Viewport.XSCREEN
	move.w	#100,Viewport.settingsTable+Viewport.YSCREEN
	move.w	#0,Viewport.settingsTable+Viewport.XSTART
	move.w	#0,Viewport.settingsTable+Viewport.YSTART
	move.w	#160,Viewport.settingsTable+Viewport.XEND
	move.w	#100,Viewport.settingsTable+Viewport.YEND

	bsr	Polygon.calcInvTable
	jsr	Lib3D.precalc_mul_table

	bsr	IceCone.init_c2p_lut
	bsr	IceCone.init_c2p_code

	move.l	#IceCone.chunky,Primitive.screenadr
	move.l	#IceCone.texture,Polygon.textureadr

	bsr	IceCone.init_texture

	jsr	getTime
	move.l	d0,IceCone.rot_start
	rts

IceCone.deinit:
	rts

IceCone.mainloop:
	ifne	IceCone.MEASURE_CPU
	ifeq	testmode
	move.w	#$0400,$FFFF8240.w
	endc
	endc

	move.l	frmcnt,d0
	sub.l	lastfrmcnt,d0
	subq.l	#2,d0
	bge.s	.clear_done
;	movea.l	scr,a0
;	jsr	CLEAR_STSCREEN
	nop
.clear_done:

	bsr	IceCone.render_3d_scene

	ifne	IceCone.MEASURE_CPU
	ifeq	testmode
	move.w	#$0600,$FFFF8240.w
	endc
	endc

	ifne	IceCone.MEASURE_CPU
	movea.l	scr,a0
	move.w	IceCone.measured_vbls,d0
	cmpi.w	#20,d0
	blo.s	.range_ok
	moveq	#20,d0
.range_ok:
	moveq	#-1,d1
	subq.w	#1,d0
	bmi.s	.end_paint_vbls
.paint_vbls_loop:
	movep.l	d1,(a0)
	addq	#8,a0
	dbf	d0,.paint_vbls_loop
.end_paint_vbls:
	clr.l	(a0)+
	clr.l	(a0)+
	endc

; swap screens..
	lea	scr,a0
	move.l	(a0)+,d0
	move.l	(a0),-(a0)
	move.l	d0,4(a0)
	ifeq	testmode
	lsr.w	#8,d0
	move.l	d0,$FFFF8200.w
	endc

	ifne	IceCone.MEASURE_CPU
	ifeq	testmode
	move.w	#$0000,$FFFF8240.w
	endc
	endc

	move.l	frmcnt,d0
	cmp.l	lastfrmcnt,d0
	bne.s	.end_pal
	move.l	#IceCone.init_pal,palirq
.end_pal:

; wait for vbl..
	move.w	IceCone.old_468(pc),d0
.vbl:	move.w	$0468.w,d1
	move.w	d1,d2
	sub.w	d0,d1
	cmpi.w	#IceCone.NR_VBLS,d1
	bcs.s	.vbl
	move.w	d2,IceCone.old_468
	move.w	d1,IceCone.measured_vbls
	rts

IceCone.measured_vbls:
	ds.w	1
IceCone.old_468:
	ds.w	1

;- event routines ----------------------------------------------------------

;- sub-routines ------------------------------------------------------------

IceCone.init_texture:
	move.l	#$08080808,d0

; horizontal stripes
	lea	IceCone.texture,a0
	moveq	#16-1,d7
.hloop:
	rept	(4*256)/4
	move.l	d0,(a0)+
	endr
	lea	12*256(a0),a0
	dbf	d7,.hloop

; vertical stripes
	lea	IceCone.texture,a0
	move.w	#256-1,d7
.vloop:	move.l	d0,(a0)
off	set	0
	rept	15
	move.l	d0,off(a0)
off	set	off+16
	endr
	lea	256(a0),a0
	dbf	d7,.vloop

	rts

; Clear chunkypixel-buffer
; input:
; d0.l=colors
; a0: buffer
IceCone.clear_chunky:
	lea	160*100(a0),a0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,d7
	movea.l	d0,a1
	movea.l	d0,a2
	movea.l	d0,a3
	movea.l	d0,a4
	movea.l	d0,a5
	movea.l	d0,a6
	REPT	(160*100)/56
	movem.l	d0-d7/a1-a6,-(a0)	
	ENDR
	REPT	(160*100-((160*100)/56)*56)/4
	move.l	d0,-(a0)
	ENDR
	rts

IceCone.init_c2p_lut:
	LEA	IceCone.c2p_lut,A6
	LEA	TAB1(pc),A0
	MOVEQ	#0,D3

GENLOOP1:
	LEA	TAB3(pc),A2
	MOVEQ	#0,D4

GENLOOP2:
	MOVEQ	#0,D5
	LEA	TAB2(pc),A1

GENLOOP3:
	MOVEQ	#$10-1,D6
	LEA	TAB4(pc),A3
	MOVE.L  (A0),D2
	OR.L	(A1),D2
	OR.L	(A2),D2

GENLOOP4:
	MOVE.L	D2,D0
	OR.L	(A3)+,D0
	MOVE.L  D0,(A6)+
	DBF	D6,GENLOOP4

	ADDQ	#4,A1
	ADDQ.W  #4,D5
	CMP.B   #$40,D5
	BNE.S   GENLOOP3

	ADDQ	#4,A2
	ADDQ.W  #4,D4
	CMP.B   #$40,D4
	BNE.S   GENLOOP2

	ADDQ	#4,A0
	ADDQ.W  #4,D3
	CMP.B   #$40,D3
	BNE.S   GENLOOP1

	RTS

TAB1:	DC.B $00,$00,$00,$00
	DC.B $C0,$00,$00,$00
	DC.B $00,$C0,$00,$00
	DC.B $C0,$C0,$00,$00
	DC.B $00,$00,$C0,$00
	DC.B $C0,$00,$C0,$00
	DC.B $00,$C0,$C0,$00
	DC.B $C0,$C0,$C0,$00
	DC.B $00,$00,$00,$C0
	DC.B $C0,$00,$00,$C0
	DC.B $00,$C0,$00,$C0
	DC.B $C0,$C0,$00,$C0
	DC.B $00,$00,$C0,$C0
	DC.B $C0,$00,$C0,$C0
	DC.B $00,$C0,$C0,$C0
	DC.B $C0,$C0,$C0,$C0
TAB2:	DC.B $00,$00,$00,$00
	DC.B $30,$00,$00,$00
	DC.B $00,$30,$00,$00
	DC.B $30,$30,$00,$00
	DC.B $00,$00,$30,$00
	DC.B $30,$00,$30,$00
	DC.B $00,$30,$30,$00
	DC.B $30,$30,$30,$00
	DC.B $00,$00,$00,$30
	DC.B $30,$00,$00,$30
	DC.B $00,$30,$00,$30
	DC.B $30,$30,$00,$30
	DC.B $00,$00,$30,$30
	DC.B $30,$00,$30,$30
	DC.B $00,$30,$30,$30
	DC.B $30,$30,$30,$30
TAB3:	DC.B $00,$00,$00,$00
	DC.B $0C,$00,$00,$00
	DC.B $00,$0C,$00,$00
	DC.B $0C,$0C,$00,$00
	DC.B $00,$00,$0C,$00
	DC.B $0C,$00,$0C,$00
	DC.B $00,$0C,$0C,$00
	DC.B $0C,$0C,$0C,$00
	DC.B $00,$00,$00,$0C
	DC.B $0C,$00,$00,$0C
	DC.B $00,$0C,$00,$0C
	DC.B $0C,$0C,$00,$0C
	DC.B $00,$00,$0C,$0C
	DC.B $0C,$00,$0C,$0C
	DC.B $00,$0C,$0C,$0C
	DC.B $0C,$0C,$0C,$0C
TAB4:	DC.B $00,$00,$00,$00
	DC.B $03,$00,$00,$00
	DC.B $00,$03,$00,$00
	DC.B $03,$03,$00,$00
	DC.B $00,$00,$03,$00
	DC.B $03,$00,$03,$00
	DC.B $00,$03,$03,$00
	DC.B $03,$03,$03,$00
	DC.B $00,$00,$00,$03
	DC.B $03,$00,$00,$03
	DC.B $00,$03,$00,$03
	DC.B $03,$03,$00,$03
	DC.B $00,$00,$03,$03
	DC.B $03,$00,$03,$03
	DC.B $00,$03,$03,$03
	DC.B $03,$03,$03,$03

c2ploopstart:	MOVEm.W	(A1)+,D0-d7		; 44
                LSL.L   #4,D0			; 16
                OR.W    d1,D0			;  4
                MOVE.L  0(A2,D0.l),D0		; 20
c2poffset1:	=	*+2
		MOVEP.L D0,0(A0)		; 24
                LSL.L   #4,D2			; 16
                OR.W    d3,D2			;  4
                MOVE.L  0(A2,D2.l),D0		; 20
c2poffset2:	=	*+2
		MOVEP.L D0,1(A0)		; 24
                LSL.L   #4,D4			; 16
                OR.W    d5,D4			;  4
                MOVE.L  0(A2,D4.l),D0		; 20
c2poffset3:	=	*+2
		MOVEP.L D0,8(A0)		; 24
                LSL.L   #4,D6			; 16
                OR.W    d7,D6			;  4
                MOVE.L  0(A2,D6.l),D0		; 20
c2poffset4:	=	*+2
		MOVEP.L D0,9(A0)		; 24
						; -- +
						;300
c2ploopend:

c2ploopsize:	=	c2ploopend-c2ploopstart


; 300000 cycles per frame!
; 371600 cycles with linedoubling.. 2.3225 VBL/frame

doubleloopstart:
		movem.l	(a1)+,d0-d7/a2-a6	* 112
double1offset:	=	*+4
		movem.l	d0-d7/a2-a6,0(a0)	* 116
		movem.l	(a1)+,d0-d7/a2-a6	* 112
double2offset:	=	*+4
		movem.l	d0-d7/a2-a6,52(a0)	* 116
		movem.l	(a1)+,d0-d7/a2-a6	* 112
double3offset:	=	*+4
		movem.l	d0-d7/a2-a6,104(a0)	* 116
double4offset:	=	*+2
		move.l	(a1)+,156(a0)		*  24
		lea	160(a1),a1		*   8
doubleloopend:

doubleloopsize:	=	doubleloopend-doubleloopstart

;						 ---- +
;                                                 716
; 716 cycles/scanline * 100 scanlines        =  71600 cycles

; Unrolling a loop a few thousand times.
IceCone.init_c2p_code:
	lea	IceCone.c2p_code,a0
	moveq	#100-1,d7
	moveq	#0,d0

.c2pyloop:
	moveq	#10-1,d6

.c2pxloop:
	lea	c2ploopstart,a1
	movea.l	a0,a3

	moveq	#c2ploopsize/2-1,d5
.c2pinstrloop:
	move.w	(a1)+,(a0)+
	dbra	d5,.c2pinstrloop

	add.w	d0,c2poffset1-c2ploopstart(a3)
	add.w	d0,c2poffset2-c2ploopstart(a3)
	add.w	d0,c2poffset3-c2ploopstart(a3)
	add.w	d0,c2poffset4-c2ploopstart(a3)
	addi.w	#16,d0
	dbra	d6,.c2pxloop

	addi.w	#160,d0
	dbra	d7,.c2pyloop

	move.w	#$2248,(a0)+			* "movea.l a0,a1"
	move.l	#$41e800a0,(a0)+		* "lea     160(a0),a0"
	moveq	#0,d0
	moveq	#100-1,d7
.doubleyloop:
	lea	doubleloopstart,a1
	movea.l	a0,a3

	moveq	#doubleloopsize/2-1,d6
.doublecopyloop:
	move.w	(a1)+,(a0)+
	dbra	d6,.doublecopyloop

	add.w	d0,double1offset-doubleloopstart(a3)
	add.w	d0,double2offset-doubleloopstart(a3)
	add.w	d0,double3offset-doubleloopstart(a3)
	add.w	d0,double4offset-doubleloopstart(a3)
	addi.w	#320,d0
	dbra	d7,.doubleyloop

	move.w	#$4e75,(a0)+			* "rts"
	rts

;--------------------------------------------------------------------------

IceCone.render_3d_scene:
	bsr	IceCone.gen_matrix

	lea	IceCone.2d_vertices,a0
	lea	Lib3D.temp_matrix,a1
	;lea	IceCone.test_vertices,a2
	lea	IceCone.cone_vertices,a2
	bsr	IceCone.transform_no_z

	lea	IceCone.tr_ball_vertices,a0
	lea	Lib3D.temp_matrix,a1
	lea	IceCone.ball_vertices,a2
	bsr	IceCone.transform_with_z

	lea	IceCone.chunky,a0
	moveq	#0,d0
	bsr	IceCone.clear_chunky
	lea	IceCone.zbuf,a0
	move.l	#$80808080,d0
	bsr	IceCone.clear_chunky

	bsr	IceCone.paint_cone

; fakk.. need the z coord too
;	movem.w	IceCone.2d_vertices+4*10,d0-d1
;	bsr	Ice
	movem.w	IceCone.tr_ball_vertices,d0-d2
	subi.w	#IceCone.BALL_WIDTH/2,d0
	subi.w	#IceCone.BALL_WIDTH/2,d1
	bsr	IceCone.paint_ball
	movem.w	IceCone.tr_ball_vertices+6*1,d0-d2
	subi.w	#IceCone.BALL_WIDTH/2,d0
	subi.w	#IceCone.BALL_WIDTH/2,d1
	bsr	IceCone.paint_ball
	movem.w	IceCone.tr_ball_vertices+6*2,d0-d2
	subi.w	#IceCone.BALL_WIDTH/2,d0
	subi.w	#IceCone.BALL_WIDTH/2,d1
	bsr	IceCone.paint_ball

	lea	IceCone.c2p_lut,a2
	lea	IceCone.chunky,a1
	movea.l	scr,a0
	jsr	IceCone.c2p_code

	rts

	include	tmap.s
	text

IceCone.gen_matrix:
	bsr	getTime
	sub.l	IceCone.rot_start,d0
	move.w	d0,.time
	lsr.w	#1,d0

	ifne	0
; cogwheel rotation..
	mulu.w	#3,d0
	move.w	d0,d2
	move.w	#900,d0
	move.w	#200,d1
	else
	move.w	d0,d1
	move.w	d0,d2
	mulu.w	#3,d0
	mulu.w	#5,d1
	mulu.w	#7,d2
;	lsr.l	#1,d1
;	lsr.l	#2,d2
;	move.w	#1024+100,d0
;	move.w	#100,d1
;	move.w	#0,d2
	move.w	#-512+150,d0
	move.w	#0,d1
	;move.w	#512,d2
	endc
	move.w	#512,d3				; fixed scale (for non-perspective mode)
	bsr	Lib3D.generate_matrix

	lea	sine_tbl,a0
	move.w	.time(pc),d2
	add.w	d2,d2
	andi.w	#SINTABLE_LEN-1,d2
	add.w	d2,d2
	add.w	d2,d2
	move.b	(a0,d2.w),d0
	ext.w	d0
	asr.w	#2,d0
	;move.w	#0,d0
	moveq	#5,d1
	move.w	#IceCone.TRANSLATION,d2
	jsr	Lib3D.translate_matrix

	rts

.time:	dc.w	0

; seems; input:
; a0: dst object
; a1: matrix
; a2: untransformed object
IceCone.transform_no_z:
	lea	Matrix.TX(a1),a3		; a3: translation vector
	move.w	(a2)+,d7			; d7.w=#vertices
;	move.w	d7,(a0)+			; store #vertices in dst object.
	subq.w	#1,d7
	movea.l	d7,a5				; a5=#vertices
	move.l	a0,.dst
	lea	Lib3D.mul_table+128*256*2,a4

	move.w	(a3),d6
	movea.w	8(a3),a6
	movea.w	4(a3),a3

.vertexloop:
	movem.w	(a2)+,d0-d2

; 68000 optimised version! a4: multiply table
; x'
	movem.w	(a1)+,d3-d5

	move.b	d0,d3
	move.b	d1,d4
	move.b	d2,d5
	add.w	d3,d3
	add.w	d4,d4
	add.w	d5,d5
	move.w	(a4,d3.l),d3
	add.w	(a4,d4.l),d3
	add.w	(a4,d5.l),d3
	move.w	d3,(a0)+			; store coordinate.
; y'
	movem.w	(a1)+,d3-d5

	move.b	d0,d3
	move.b	d1,d4
	move.b	d2,d5
	add.w	d3,d3
	add.w	d4,d4
	add.w	d5,d5
	move.w	(a4,d3.l),d3
	add.w	(a4,d4.l),d3
	add.w	(a4,d5.l),d3
	move.w	d3,(a0)+			; store coordinate.
; z'

	ifne	IceCone.PERSPECTIVE

	movem.w	(a1)+,d3-d5

	move.b	d0,d3
	move.b	d1,d4
	move.b	d2,d5
	add.w	d3,d3
	add.w	d4,d4
	add.w	d5,d5
	move.w	(a4,d3.l),d3
	add.w	(a4,d4.l),d3
	add.w	(a4,d5.l),d3
	add.w	a6,d3				; translate coordinate.
	move.w	d3,(a0)+			; store coordinate.
	lea	-3*6(a1),a1

	else

	;addq	#2,a0
	lea	-2*6(a1),a1

	endc

	dbf	d7,.vertexloop

; perspectivate...
	movea.l	.dst(pc),a0			; a0: dst object
	move.w	a5,d7				; d7.w=#vertices
	moveq	#80,d4
	add.w	d6,d4
	moveq	#50,d5
	add.w	a3,d5
	move.w	#$0100,d3			; d3.w=z_offset

	lea	inv_table,a1

.persp_loop:

	ifne	IceCone.PERSPECTIVE

	movem.w	(a0),d0-d2
	add.w	d3,d2

	ifne	0
	add.w	d2,d2
	move.w	(a1,d2.w),d2
	muls.w	d2,d0
	muls.w	d2,d1
	asr.l	#7,d0
	asr.l	#7,d1
	else
	lsl.l	#8,d0
	lsl.l	#8,d1
	divs.w	d2,d0
	divs.w	d2,d1
	endc

	add.w	d4,d0
	add.w	d5,d1
	move.w	d0,(a0)+
	move.w	d1,(a0)+
	addq	#2,a0

	else

	move.w	(a0),d0
	asr.w	#2,d0
	add.w	d4,d0
	move.w	d0,(a0)+
	move.w	(a0),d1
	asr.w	#2,d1
	add.w	d5,d1
	move.w	d1,(a0)+
	;addq	#2,a0

	endc

	dbf	d7,.persp_loop

	rts

.dst:	dc.l	0

; seems; input:
; a0: dst object
; a1: matrix
; a2: untransformed object
IceCone.transform_with_z:
	lea	Matrix.TX(a1),a3		; a3: translation vector
	move.w	(a2)+,d7			; d7.w=#vertices
;	move.w	d7,(a0)+			; store #vertices in dst object.
	subq.w	#1,d7
	movea.l	d7,a5				; a5=#vertices
	move.l	a0,.dst
	lea	Lib3D.mul_table+128*256*2,a4

	move.w	(a3),d6
	movea.w	8(a3),a6
	movea.w	4(a3),a3

.vertexloop:
	movem.w	(a2)+,d0-d2

; 68000 optimised version! a4: multiply table
; x'
	movem.w	(a1)+,d3-d5

	move.b	d0,d3
	move.b	d1,d4
	move.b	d2,d5
	add.w	d3,d3
	add.w	d4,d4
	add.w	d5,d5
	move.w	(a4,d3.l),d3
	add.w	(a4,d4.l),d3
	add.w	(a4,d5.l),d3
	move.w	d3,(a0)+			; store coordinate.
; y'
	movem.w	(a1)+,d3-d5

	move.b	d0,d3
	move.b	d1,d4
	move.b	d2,d5
	add.w	d3,d3
	add.w	d4,d4
	add.w	d5,d5
	move.w	(a4,d3.l),d3
	add.w	(a4,d4.l),d3
	add.w	(a4,d5.l),d3
	move.w	d3,(a0)+			; store coordinate.
; z'

	movem.w	(a1)+,d3-d5

	move.b	d0,d3
	move.b	d1,d4
	move.b	d2,d5
	add.w	d3,d3
	add.w	d4,d4
	add.w	d5,d5
	move.w	(a4,d3.l),d3
	add.w	(a4,d4.l),d3
	add.w	(a4,d5.l),d3
	add.w	a6,d3				; translate coordinate.
	move.w	d3,(a0)+			; store coordinate.
	lea	-3*6(a1),a1

	dbf	d7,.vertexloop

; perspectivate...
	movea.l	.dst(pc),a0			; a0: dst object
	move.w	a5,d7				; d7.w=#vertices
	moveq	#80,d4
	add.w	d6,d4
	moveq	#50,d5
	add.w	a3,d5
	move.w	#$0100,d3			; d3.w=z_offset

	lea	inv_table,a1

.persp_loop:

	ifne	IceCone.PERSPECTIVE

	movem.w	(a0),d0-d2
	add.w	d3,d2

	ifne	0
	add.w	d2,d2
	move.w	(a1,d2.w),d2
	muls.w	d2,d0
	muls.w	d2,d1
	asr.l	#7,d0
	asr.l	#7,d1
	else
	lsl.l	#8,d0
	lsl.l	#8,d1
	divs.w	d2,d0
	divs.w	d2,d1
	endc

	add.w	d4,d0
	add.w	d5,d1
	move.w	d0,(a0)+
	move.w	d1,(a0)+
	addq	#2,a0

	else

	move.w	(a0),d0
	asr.w	#2,d0
	add.w	d4,d0
	move.w	d0,(a0)+
	move.w	(a0),d1
	asr.w	#2,d1
	add.w	d5,d1
	move.w	d1,(a0)+
	move.w	(a0),d0
	asr.w	#3,d0
	move.w	d0,(a0)+

	endc

	dbf	d7,.persp_loop

	rts

.dst:	dc.l	0

IceCone.paint_cone:
	lea	IceCone.cone_polys,a1
	;lea	IceCone.test_polys,a1

	move.w	(a1)+,d7
	subq.w	#1,d7

.loop:	movea.l	scr,a0
;	move.w	(a1)+,d0			; d0.w=plane index
;	add.w	d0,d0				; d0.w=plane offset
;	adda.w	d0,a0
;	move.l	a0,Lib3D.screenadr

	lea	IceCone.uv_vertices,a3
	;lea	IceCone.test_uv_vertices,a3

	lea	IceCone.2d_vertices,a2
	lea	IceCone.temp_poly(pc),a0
	;move.w	(a1)+,d6
	moveq	#3,d6
	move.w	d6,(a0)+
	subq.w	#1,d6

.vloop:	move.w	(a1)+,d0
	add.w	d0,d0				; d0.w=2i
	add.w	d0,d0				; d0.w=4i
	move.l	(a2,d0.w),(a0)+
	move.l	(a3,d0.w),(a0)+
	dbf	d6,.vloop

	movem.w	IceCone.temp_poly+2(pc),d0-d1	; d0.w=x1, d1.w=y1
	movem.w	IceCone.temp_poly+10(pc),d2-d3	; d2.w=x2, d3.w=y2
	movem.w	IceCone.temp_poly+18(pc),d4-d5	; d4.w=x3, d5.w=y3
	sub.w	d2,d0				; d0.w=x1-x2
	sub.w	d3,d1				; d1.w=y1-y2
	sub.w	d2,d4				; d4.w=x3-x2
	sub.w	d3,d5				; d5.w=y3-y2
	muls.w	d1,d4				; d4.l=(x3-x2)(y1-y2)
	muls.w	d0,d5				; d5.l=(x1-x2)(y3-y2)
	sub.l	d4,d5
	ble.s	.skippy_the_bush_kangaroo

	movem.l	d7/a1,-(sp)
	lea	IceCone.temp_poly(pc),a0
	bsr	Polygon.clipV2
	movem.l	(sp)+,d7/a1

; vis flags only needed when patterns mapped on polys..
	;addq.w	#1,vis_flags+2
.skippy_the_bush_kangaroo:
	;lea	vis_flags(pc),a0
	;move.l	(a0),d0
	;add.l	d0,d0
	;move.l	d0,(a0)

.next_poly:
	dbf	d7,.loop
.end_loop:
	rts

	dc.w	3
IceCone.temp_poly:
	ds.l	2*10

;--------------------------------------------------------------------------

; input:
; d0.w=x
; d1.w=y
; d2.b=z
IceCone.paint_ball:
	;lea	IceCone.ball,a1
	lea	IceCone.ballz,a1

	lea	IceCone.chunky,a0
	lea	IceCone.zbuf,a2
	mulu.w	#160,d1
	add.w	d0,d1
	adda.w	d1,a0
	adda.w	d1,a2
	moveq	#IceCone.BALL_WIDTH-1,d7

.yloop:	moveq	#IceCone.BALL_WIDTH-1,d6

.xloop:	move.b	(a2),d1
	;move.b	(a1),d0
	move.b	(a1)+,d0
	bmi.s	.next				; skip if masked out.

	move.b	d0,d4
	add.b	d2,d4				; d4.b=z
	cmp.b	d4,d1
	bgt.s	.next				; skip if z value low.

	add.b	d0,d0
	addi.w	#8*4,d0
	andi.b	#$FC,d0				; d0.b=scaled colour for chunky
	move.b	d0,(a0)				; store new colour.
	move.b	d4,(a2)				; store new z.

; increase to next pixel in src and dst buffers.
.next:	;addq	#2,a1
	addq	#1,a0
	addq	#1,a2
	dbf	d6,.xloop

	adda.w	#160-IceCone.BALL_WIDTH,a0
	adda.w	#160-IceCone.BALL_WIDTH,a2
	dbf	d7,.yloop

	rts

IceCone.init_pal:
	lea	$FFFF8240.w,a0
	moveq	#-1,d0
	rept	8
	move.l	d0,(a0)+
	endr

	move.w	#4,IceCone.countdown
	move.l	#IceCone.wait_vbl,palirq
	rts

IceCone.wait_vbl:
	subq.w	#1,IceCone.countdown
	bpl.s	.end
	move.l	#IceCone.set_real_pal,palirq
.end:	rts

IceCone.countdown:
	dc.w	0

IceCone.set_real_pal:
	lea	$FFFF8240.w,a0

	move.l	#$01010110,(a0)+
	move.l	#$02100320,(a0)+
	move.l	#$04200530,(a0)+
	move.l	#$06300640,(a0)+

;	move.l	#$01110322,(a0)+
;	move.l	#$04330544,(a0)+
;	move.l	#$06550766,(a0)+
;	move.l	#$0F770FFF,(a0)+
	move.l	#$01110321,(a0)+
	move.l	#$04320542,(a0)+
	move.l	#$06530764,(a0)+
	move.l	#$0F750FF5,(a0)+
	move.l	#dummy,palirq
	rts

;- data section ------------------------------------------------------------

	data

IceCone.test_vertices:
	dc.w	(.end-.start)/6
.start:	dc.w	+000,+000,+000
	dc.w	+000,-050,+000
	dc.w	+050,+000,+000
.end:

IceCone.test_uv_vertices:
	dc.w	000,000
	dc.w	000,100
	dc.w	100,000

IceCone.cone_vertices:
	dc.w	(.end-.start)/6
;.start:	dc.w	+000,+000,+060
;	dc.w	-010,-020,-040
;	dc.w	+010,-020,-040
;	dc.w	+020,-010,-040
;	dc.w	+020,+010,-040
;	dc.w	+010,+020,-040
;	dc.w	-010,+020,-040
;	dc.w	-020,+010,-040
;	dc.w	-020,-010,-040
;	dc.w	-010,-020,-040			; copy of vertex 1, for wraps. 
.start:	dc.w	+000,+000,+088			; 80
	dc.w	-017,-034,-068			; 15,30,60
	dc.w	+017,-034,-068
	dc.w	+034,-017,-068
	dc.w	+034,+017,-068
	dc.w	+017,+034,-068
	dc.w	-017,+034,-068
	dc.w	-034,+017,-068
	dc.w	-034,-017,-068
	dc.w	-017,-034,-068			; copy of vertex 1, for wraps. 
.end:

; balls, they are touching
IceCone.ball_vertices:
	dc.w	(.end-.start)/6
.start:	dc.w	+017,+011,-077
	dc.w	-017,+011,-077
	dc.w	+000,-021,-077
.end:

IceCone.test_polys:
	dc.w	1
	dc.w	0,1,2

IceCone.uv_vertices:
	ifne	0
; full texture res
	dc.w	128,255
	dc.w	000,000
	dc.w	032,000
	dc.w	064,000
	dc.w	096,000
	dc.w	128,000
	dc.w	160,000
	dc.w	192,000
	dc.w	224,000
	dc.w	256,000
	else
	dc.w	128,127
	dc.w	064,000
	dc.w	080,000
	dc.w	096,000
	dc.w	112,000
	dc.w	128,000
	dc.w	144,000
	dc.w	160,000
	dc.w	176,000
	dc.w	192,000
	endc

IceCone.cone_polys:
	dc.w	8
	dc.w	0,1,2
	dc.w	0,2,3
	dc.w	0,3,4
	dc.w	0,4,5
	dc.w	0,5,6
	dc.w	0,6,7
	dc.w	0,7,8
	;dc.w	0,8,1
	dc.w	0,8,9			; wrap crap

IceCone.texture:
	dcb.b	256*256,7*4

IceCone.ballz:
	include	ballz.s
	even

;- bss section -------------------------------------------------------------

	bss

IceCone.2d_vertices:
	ds.l	10
IceCone.tr_ball_vertices:
	ds.w	3*6

IceCone.rot_start:
	ds.l	1

	ifne	1

; put in overlapping memory..
IceCone.chunky:=	Lib3D.end_of_bss
;	ds.b	160*100
IceCone.zbuf:=		(IceCone.chunky+160*100)
;	ds.b	160*100
IceCone.ball:=		(IceCone.zbuf+160*100)
;	ds.w	16*16
IceCone.c2p_lut:=	(IceCone.ball+16*16*2)
;	ds.l	1<<16
IceCone.c2p_code:=	(IceCone.c2p_lut+4<<16)
;	ds.b	54000 			; rough guess...

	else

IceCone.chunky:
	ds.b	160*100
IceCone.zbuf:
	ds.b	160*100
IceCone.ball:
	ds.w	16*16
IceCone.c2p_lut:
	ds.l	1<<16
IceCone.c2p_code:
	ds.b	54000 			; rough guess...

	endc
