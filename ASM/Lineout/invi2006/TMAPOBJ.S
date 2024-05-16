DEBUGG:=	0

;---------------------------------------------------------------------------
; c2p equates
;---------------------------------------------------------------------------

DOUBLING:=	1				; doubling of scanlines yes/no [1/0]

;---------------------------------------------------------------------------
; transformation equates
;---------------------------------------------------------------------------

Tmap.MAX_Y:=	100
INV_SIZE:=	160

* Internal point-structure (with texture-coordinates)
		RSRESET
pointx:		RS.W	1
pointy:		RS.W	1
pointtx:	RS.W	1
pointty:	RS.W	1
pointz:		RS.W	1
pointsize:	RS.W	0

* Internal triangle format (with color & hiddenedge info)
		RSRESET
trianglep1:	RS.W	1
trianglep2:	RS.W	1
trianglep3:	RS.W	1
triangleinfo:	RS.W	1
trianglesize:	RS.W	0

		RSRESET
edgelength:	RS.W	1
edgestarty:	RS.W	1
edgeslope:	RS.L	1
edgeheadersize:	RS.W	0

		RSRESET
edgex:		RS.W	1
edgetx:		RS.W	1
edgety:		RS.W	1
edgeentrysize:	RS.W	0

ENVLIGHTROT:=	1
MAX_POINTS:=	50
MAX_EDGES:=	50
MAX_TRIANGLES:=	50

; object:
;nr_points:	rs.w	1
;points:	rs.b	n*pointsize
;nr_pointtris:	rs.w	1
;pointtris:	rs.b	m*trianglesize
;nr_edges:	rs.w	1
;edges:		rs.b	l*4
;edgetris:	rs.b	m*6
;normals:	rs.b	n*6

		RSRESET
EDGEBUF_OFFSET:	rs.w	3*Tmap.MAX_Y*MAX_EDGES
C2PINST_OFFSET:	rs.b	70000
C2PLUT_OFFSET:	rs.l	1<<16
TEMPBUF_SIZE	rs.b	0

;- test shell --------------------------------------------------------------

	ifnd	DEMO_SYSTEM
testmode:=	0
	include	tester.s
	text
	endc

;- plugin table ------------------------------------------------------------

	dc.l	Tmap.mainloop
	dc.l	Tmap.init
	dc.l	Tmap.rt_init
	dc.l	Tmap.deinit
	dc.l	Tmap.init_tables
	dc.l	0

;- plugin routines ---------------------------------------------------------

Tmap.init:
	bsr	Tmap.calcInvTable
	lea	env_object,a1
	bsr	INIT_OBJECT

	lea	white,a0
	bsr	conv_apx_to_chunky
;	move.l	#$3C3C3C3C,d0
;	move.w	#65536/4-1,d7
;.loop:	move.l	d0,(a0)+
;	dbf	d7,.loop

	move.l	#white,envtextureadr
	rts

Tmap.rt_init:
	move.l	#Tmap.init_pal,palirq
	bsr	Tmap.init_tables
	rts

Tmap.init_tables:
	tst.w	.init_done
	bne.s	.end
	move.w	#1,.init_done
	bsr	init_c2p_tables
	bsr	init_c2p_code
.end:	rts

.init_done:
	dc.w	0

Tmap.deinit:
	rts

Tmap.mainloop:
	ifne	1

;	bsr	clear_chunky
	bsr	feedback_chunky

	ifeq	testmode
;	move.w	#$0304,$FFFF8240.w
	endc

; Now calculate everything and prepare for painting to the screen.
	lea	env_object,a1
	lea	.rot_tbl(pc),a2

	ifd	DEMO_SYSTEM
	move.l	ticks_done,d0
	else
	move.w	$4bc.w,d0
	lsr.w	#2,d0
	endc
;	clr.w	d0

	add.w	d0,d0
	add.w	d0,d0
;	move.w	#200,d0

	move.w	d0,d1
	add.w	d0,d0
	move.w	d0,(a2)
	mulu.w	#3,d1
	lsr.l	#2,d1
	move.w	d1,2(a2)
	bsr	ROTATE_OBJECT

	moveq	#0,d0
	moveq	#0,d1
	move.w	#-350,d2
	bsr	TRANSFORM_OBJECT

	ifeq	testmode
;	move.w	#$0050,$FFFF8240.w
	endc

; finally paint everything on screen.
	bsr	PLOT_OBJECT
;	bsr	plot_edges

	ifeq	testmode
;	move.w	#$0005,$FFFF8240.w
	endc

	ifne	0
	movea.l	chunky_adr,a0
	move.l	frmcnt,d0
	lsr.w	#1,d0
	bcc.s	.zero
	move.l	#$0F0E0D0C<<2,(a0)+
	move.l	#$0B0A0908<<2,(a0)+
	move.l	#$07060504<<2,(a0)+
	move.l	#$03020100<<2,(a0)+
	bra.s	.end_mark
.zero:	move.l	#$00010203<<2,(a0)+
	move.l	#$04050607<<2,(a0)+
	move.l	#$08090A0B<<2,(a0)+
	move.l	#$0C0D0E0F<<2,(a0)+
.end_mark:
	endc

	movea.l	scr,a0
	movea.l	chunky_adr,a1
	lea	temp_buf+C2PLUT_OFFSET,a2	c2p_lut,a2
	jsr	temp_buf+C2PINST_OFFSET ;c2p_instr_table

	endc

	lea	scr,a0
; triple buffer
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0),-4(a0)
	move.l	d0,(a0)
	move.l	d1,-8(a0)
; double buffer
;	move.l	(a0)+,d0
;	move.l	(a0),-4(a0)
;	move.l	d0,(a0)

	ifeq	testmode
;	clr.w	$FFFF8240.w
	endc

	ifeq	testmode
	lsr.w	#8,d0
	move.l	d0,$FFFF8200.w
	endc

; only required in case of double buffer..
;	move.w	$0468.w,d0
;.wait:	cmp.w	$0468.w,d0
;	beq.s	.wait

;	move.w	$0468.w,d0
;.wait:	move.w	$0468.w,d1
;	sub.w	d0,d1
;	cmpi.w	#60,d1
;	blt.s	.wait

	rts

.rot_tbl:
	ds.w	3

Tmap.scan_table:
.offset	set	0
	rept	Tmap.MAX_Y
	dc.w	.offset
.offset	set	.offset+160
	endr

background_color:
	dc.w	0

;--------------------------------------------------------------------------

Tmap.init_pal:
; blue white
	move.w	#$0000,$FFFF8240.w
	move.w	#$0881,$FFFF8242.w
	move.w	#$0112,$FFFF8244.w
	move.w	#$0993,$FFFF8246.w
	move.w	#$0224,$FFFF8248.w
	move.w	#$0AA5,$FFFF824A.w
	move.w	#$0336,$FFFF824C.w
	move.w	#$0BBF,$FFFF824E.w
	move.w	#$044F,$FFFF8250.w
	move.w	#$0CCF,$FFFF8252.w
	move.w	#$055F,$FFFF8254.w
	move.w	#$0DDF,$FFFF8256.w
	move.w	#$066F,$FFFF8258.w
	move.w	#$0EEF,$FFFF825A.w
	move.w	#$077F,$FFFF825C.w
	move.w	#$0FFF,$FFFF825E.w
	ifne	0
; grey
	move.w	#$0000,$FFFF8240.w
	move.w	#$0888,$FFFF8242.w
	move.w	#$0111,$FFFF8244.w
	move.w	#$0999,$FFFF8246.w
	move.w	#$0222,$FFFF8248.w
	move.w	#$0AAA,$FFFF824A.w
	move.w	#$0333,$FFFF824C.w
	move.w	#$0BBB,$FFFF824E.w
	move.w	#$0444,$FFFF8250.w
	move.w	#$0CCC,$FFFF8252.w
	move.w	#$0555,$FFFF8254.w
	move.w	#$0DDD,$FFFF8256.w
	move.w	#$0666,$FFFF8258.w
	move.w	#$0EEE,$FFFF825A.w
	move.w	#$0777,$FFFF825C.w
	move.w	#$0FFF,$FFFF825E.w
	endc

	ifne	0
	ifne	0
; red white
	move.w	#$0000,$FFFF8240.w
	move.w	#$0188,$FFFF8242.w
	move.w	#$0211,$FFFF8244.w
	move.w	#$0399,$FFFF8246.w
	move.w	#$0422,$FFFF8248.w
	move.w	#$05AA,$FFFF824A.w
	move.w	#$0633,$FFFF824C.w
	move.w	#$0FBB,$FFFF824E.w
	move.w	#$0F44,$FFFF8250.w
	move.w	#$0FCC,$FFFF8252.w
	move.w	#$0F55,$FFFF8254.w
	move.w	#$0FDD,$FFFF8256.w
	move.w	#$0F66,$FFFF8258.w
	move.w	#$0FEE,$FFFF825A.w
	move.w	#$0F77,$FFFF825C.w
	move.w	#$0FFF,$FFFF825E.w
	else
	move.w	#$0000,$FFFF8240.w
	move.w	#$0100,$FFFF8242.w
	move.w	#$0200,$FFFF8244.w
	move.w	#$0300,$FFFF8246.w
	move.w	#$0400,$FFFF8248.w
	move.w	#$0500,$FFFF824A.w
	move.w	#$0600,$FFFF824C.w
	move.w	#$0F00,$FFFF824E.w
	move.w	#$0F88,$FFFF8250.w
	move.w	#$0F99,$FFFF8252.w
	move.w	#$0FAA,$FFFF8254.w
	move.w	#$0FBB,$FFFF8256.w
	move.w	#$0FCC,$FFFF8258.w
	move.w	#$0FDD,$FFFF825A.w
	move.w	#$0FEE,$FFFF825C.w
	move.w	#$0FFF,$FFFF825E.w
	endc
	endc
	move.l	#dummy,palirq
	rts

;--------------------------------------------------------------------------

Tmap.calcInvTable:
	lea	Tmap.invTable,a0
	move.l	#$8000,d1
	moveq	#2,d0
	move.w	#$7fff,(a0)+
	move.w	#$7fff,(a0)+

.posloop:
	move.l	d1,d2
	divu.w	d0,d2
	move.w	d2,(a0)+
	addq.w	#1,d0
	cmpi.w	#INV_SIZE+1,d0
	blt.s	.posloop
	rts

;--------------------------------------------------------------------------

; clear chunky buffer
clear_chunky:
	movea.l chunky_adr,a0
	lea	160*Tmap.MAX_Y(a0),a0
	move.w	#160*Tmap.MAX_Y/(4*8)-1,d7
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	movea.l	d0,a1
.loop:	movem.l	d0-d6/a1,-(a0)
	dbf	d7,.loop
	rts

scale_f	macro
	move.b	(a1)+,(a0)+			; 1/1
	move.b	(a1)+,(a0)+			; 2/2
	move.b	(a1)+,(a0)+			; 3/3
	move.b	(a1)+,(a0)+			; 4/4
	move.b	(a1),(a0)+			; 4/5
	endm

scale_b	macro
	move.b	-(a1),-(a0)			; 2/2
	move.b	-(a1),-(a0)			; 2/2
	move.b	-(a1),-(a0)			; 3/3
	move.b	-(a1),-(a0)			; 4/4
	move.b	(a1),-(a0)			; 4/5
	endm

; 64x40 -> 80x50
; use quadrants:
;
; 1 | 2
; -----
; 3 | 4
;
feedback_chunky:

; first quadrant..
	movea.l chunky_adr,a0
	movea.l	a0,a1
	lea	80-64+(50-40)*160(a1),a1
	moveq	#10-1,d7
.loop1:
	rept	4
	move.l	(a1)+,(a0)+			; 4/4
	move.b	(a1),(a0)+			; 4/5
	scale_f					; 8/10
	move.l	(a1)+,(a0)+			; 12/14
	move.b	(a1),(a0)+			; 12/15
	scale_f
	move.l	(a1)+,(a0)+
	move.b	(a1),(a0)+
	scale_f
	move.l	(a1)+,(a0)+
	move.b	(a1),(a0)+
	scale_f
	move.l	(a1)+,(a0)+
	move.b	(a1),(a0)+
	scale_f
	move.l	(a1)+,(a0)+
	move.b	(a1),(a0)+
	scale_f
	move.l	(a1)+,(a0)+
	move.b	(a1),(a0)+
	scale_f
	move.l	(a1)+,(a0)+
	move.b	(a1),(a0)+
	scale_f
	lea	80(a0),a0
	lea	160-64(a1),a1
	endr
	lea	160(a0),a0
	dbf	d7,.loop1

; second quadrant..
	movea.l chunky_adr,a0
	movea.l	a0,a1
	lea	160(a0),a0
	lea	80+64+(50-40)*160(a1),a1
	moveq	#10-1,d7
.loop2:
	rept	4
	move.l	-(a1),-(a0)
	move.b	(a1),-(a0)
	scale_b
	move.l	-(a1),-(a0)
	move.b	(a1),-(a0)
	scale_b
	move.l	-(a1),-(a0)
	move.b	(a1),-(a0)
	scale_b
	move.l	-(a1),-(a0)
	move.b	(a1),-(a0)
	scale_b
	move.l	-(a1),-(a0)
	move.b	(a1),-(a0)
	scale_b
	move.l	-(a1),-(a0)
	move.b	(a1),-(a0)
	scale_b
	move.l	-(a1),-(a0)
	move.b	(a1),-(a0)
	scale_b
	move.l	-(a1),-(a0)
	move.b	(a1),-(a0)
	scale_b
	lea	160+80(a0),a0
	lea	160+64(a1),a1
	endr
	lea	160(a0),a0
	dbf	d7,.loop2

	ifne	1

; third quadrant..
	movea.l chunky_adr,a0
	movea.l	a0,a1
	lea	99*160(a0),a0
	lea	80-64+(50+40)*160(a1),a1
	moveq	#10-1,d7
.loop3:
	rept	4
	move.l	(a1)+,(a0)+
	move.b	(a1),(a0)+
	scale_f
	move.l	(a1)+,(a0)+
	move.b	(a1),(a0)+
	scale_f
	move.l	(a1)+,(a0)+
	move.b	(a1),(a0)+
	scale_f
	move.l	(a1)+,(a0)+
	move.b	(a1),(a0)+
	scale_f
	move.l	(a1)+,(a0)+
	move.b	(a1),(a0)+
	scale_f
	move.l	(a1)+,(a0)+
	move.b	(a1),(a0)+
	scale_f
	move.l	(a1)+,(a0)+
	move.b	(a1),(a0)+
	scale_f
	move.l	(a1)+,(a0)+
	move.b	(a1),(a0)+
	scale_f
	lea	-160-80(a0),a0
	lea	-160-64(a1),a1
	endr
	lea	-160(a0),a0
	dbf	d7,.loop3

	endc

	ifne	1

; fourth quadrant..
	movea.l chunky_adr,a0
	movea.l	a0,a1
	lea	160*100(a0),a0
	lea	80+64+(50+40)*160(a1),a1
	moveq	#10-1,d7
.loop4:
	rept	4
	move.l	-(a1),-(a0)
	move.b	(a1),-(a0)
	scale_b
	move.l	-(a1),-(a0)
	move.b	(a1),-(a0)
	scale_b
	move.l	-(a1),-(a0)
	move.b	(a1),-(a0)
	scale_b
	move.l	-(a1),-(a0)
	move.b	(a1),-(a0)
	scale_b
	move.l	-(a1),-(a0)
	move.b	(a1),-(a0)
	scale_b
	move.l	-(a1),-(a0)
	move.b	(a1),-(a0)
	scale_b
	move.l	-(a1),-(a0)
	move.b	(a1),-(a0)
	scale_b
	move.l	-(a1),-(a0)
	move.b	(a1),-(a0)
	scale_b
	lea	-80(a0),a0
	lea	64-160(a1),a1
	endr
	lea	-160(a0),a0
	dbf	d7,.loop4

	endc

; repeat last row
	movea.l chunky_adr,a0
	lea	160*4(a0),a0
	moveq	#10-1,d7
.copy_loop_hi:
	movem.l	-160(a0),d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,(a0)
	movem.l	-160+48(a0),d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,48(a0)
	movem.l	-160+96(a0),d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,96(a0)
	movem.l	-160+144(a0),d0-d3
	movem.l	d0-d3,144(a0)
	lea	160*5(a0),a0
	dbf	d7,.copy_loop_hi

	movea.l chunky_adr,a0
	lea	160*95(a0),a0
	moveq	#10-1,d7
.copy_loop_lo:
	movem.l	160(a0),d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,(a0)
	movem.l	160+48(a0),d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,48(a0)
	movem.l	160+96(a0),d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,96(a0)
	movem.l	160+144(a0),d0-d3
	movem.l	d0-d3,144(a0)
	lea	-160*5(a0),a0
	dbf	d7,.copy_loop_lo
	rts

; Unrolling a loop a few thousand times.
; note that the chunky format expects pixels formatted as follows:
; %00pppp0000pppp0000pppp0000pppp00
init_c2p_code:
	lea	temp_buf+C2PINST_OFFSET,a0
;	lea	c2p_instr_table,a0

	moveq	#Tmap.MAX_Y-1,d7
	moveq	#0,d0

.c2pyloop:
	moveq	#160/16-1,d6

.c2pxloop:
	lea	c2ploopstart,a1
	movea.l	a0,a3
	moveq	#c2ploopsize/2-1,d5
.c2pinstrloop:
	move.w	(a1)+,(a0)+
	dbf	d5,.c2pinstrloop
	add.w	d0,c2poffset1-c2ploopstart(a3)
	add.w	d0,c2poffset2-c2ploopstart(a3)
	add.w	d0,c2poffset3-c2ploopstart(a3)
	add.w	d0,c2poffset4-c2ploopstart(a3)
	addi.w	#16,d0
	dbf	d6,.c2pxloop

	ifne	0
; tail bits.. (smaller movem)
	lea	c2p2loopstart,a1
	movea.l	a0,a3
	moveq	#c2p2loopsize/2-1,d5
.c2p2instrloop:
	move.w	(a1)+,(a0)+
	dbf	d5,.c2p2instrloop
	add.w	d0,c2p2offset1-c2p2loopstart(a3)
	add.w	d0,c2p2offset2-c2p2loopstart(a3)
	endc

	addi.w	#160,d0
	dbf	d7,.c2pyloop

	IFNE	DOUBLING

	move.w	#$2248,(a0)+			* "movea.l a0,a1"
	move.l	#$41e800a0,(a0)+		* "lea     160(a0),a0"
	moveq	#0,d0
	moveq	#Tmap.MAX_Y-1,d7
.doubleyloop:
	lea	doubleloopstart,a1
	movea.l	a0,a3

	moveq	#doubleloopsize/2-1,d6
.doublecopyloop:
	move.w	(a1)+,(a0)+
	dbf	d6,.doublecopyloop

	add.w	d0,double1offset-doubleloopstart(a3)
	add.w	d0,double2offset-doubleloopstart(a3)
	add.w	d0,double3offset-doubleloopstart(a3)
	add.w	d0,double4offset-doubleloopstart(a3)
	addi.w	#320,d0
	dbf	d7,.doubleyloop

	ENDC

	move.w	#$4e75,(a0)+			* "rts"
	rts

init_c2p_tables:
	lea	temp_buf+C2PLUT_OFFSET,A6
;	lea	c2p_lut,a6
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

TAB1:
	DC.B $00,$00,$00,$00
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
TAB2:
	DC.B $00,$00,$00,$00
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
TAB3:
	DC.B $00,$00,$00,$00
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
TAB4:
	DC.B $00,$00,$00,$00
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

;--------------------------------------------------------------------------

* Gets addresses of all tables in the 3d-object.
* INPUT: a1: objectaddress (EARX envmapped format)
INIT_OBJECT:
	move.w	(a1)+,d0
	cmpi.w	#MAX_POINTS,d0
	mulu.w	#pointsize,d0
	adda.l	d0,a1
	move.l	a1,pnttritbladr			* address of pointtriangles
	move.w	(a1)+,d0
	cmpi.w	#MAX_TRIANGLES,d0
	move.w	d0,d1
	mulu.w	#trianglesize,d0
	lea	(a1,d0.l),a1
	move.l	a1,edgestbladr			* address of edges
	move.w	(a1)+,d0
	cmpi.w	#MAX_EDGES,d0
	lsl.w	#2,d0
	lea	(a1,d0.w),a1
	move.l	a1,tritbladr			* address of edgetriangles
	mulu.w	#6,d1
	lea	(a1,d1.l),a1
	move.l	a1,normaltbladr			* address of normals
	rts

* This routine is just a easy to calculate sinus-matrix thingy
* rotates around the x-axis and then around the y-axis.
* makes a rotated copy of the original...
* INPUT: a1: address of source objectbuffer
*        a2: address of rotation-array
ROTATE_OBJECT:
* Get sine-values..
	lea	sine_tbl,a0
	move.w	(a2)+,d0
	andi.w	#$07FF,d0
	add.w	d0,d0
	add.w	d0,d0
	movem.w	(a0,d0.w),d1-d2
	move.w	(a2)+,d0
	andi.w	#$07FF,d0
	add.w	d0,d0
	add.w	d0,d0
	movem.w	(a0,d0.w),d3-d4
	lea	points_tbl,a0
	move.w	(a1)+,d7
	move.w	d7,(a0)+
	subq.w	#1,d7
	movea.w	d7,a5
	movea.l	a1,a2
	movea.l	a0,a6

* Calculate the x-coordinates..
.xloop	move.w	(a1),d0
	muls.w	d4,d0
	addq	#pointz,a1
	move.w	(a1)+,d5
	muls.w	d3,d5
	sub.l	d5,d0
	add.l	d0,d0
	swap	d0
	move.w	d0,(a0)
	lea	pointsize(a0),a0
	dbra	d7,.xloop

* Calculate the texture x-coordinates..
	lea	pointtx(a6),a0			* Get address of first texture x-coord
	movea.l	normaltbladr,a1
	move.w	a5,d7
	IFNE	ENVLIGHTROT
.normxloop:
	move.w	(a1)+,d0
	muls.w	d4,d0
	addq	#2,a1
	move.w	(a1)+,d5
	muls.w	d3,d5
	sub.l	d5,d0
	swap	d0
	move.w	d0,(a0)
	lea	pointsize(a0),a0
	dbra	d7,.normxloop
	ELSE
.normxloop:
	move.w	(a1),(a0)
	addq	#6,a1
	lea	pointsize(a0),a0
	dbra	d7,.normxloop
	ENDC

* Calculate the y-coordinates..
	lea	pointy(a6),a0			* Get address of first y-coord
	move.l	d3,a3				* Backup
	move.l	d4,a4				* Backup
	muls.w	d1,d3
	muls.w	d1,d4
	subq.l	#1,d3
	subq.l	#1,d4
	add.l	d3,d3
	add.l	d4,d4
	swap	d3
	swap	d4
	move.l	a2,a1
	move.w	a5,d7
.yloop:	movem.w	(a1),d5-d6
	muls.w	d3,d5
	muls.w	d2,d6
	addq	#pointz,a1
	move.w	(a1)+,d0
	muls.w	d4,d0
	add.l	d0,d5
	add.l	d6,d5
	add.l	d5,d5
	swap	d5
	move.w	d5,(a0)
	lea	pointsize(a0),a0
	dbra	d7,.yloop

* Calculate the texture y-coordinates..
	lea	pointty(a6),a0			* Get address of first texture y-coord
	movea.l	normaltbladr,a1
	move.w	a5,d7
	IFNE	ENVLIGHTROT
.normyloop:
	movem.w	(a1)+,d5-d6
	muls.w	d3,d5
	muls.w	d2,d6
	move.w	(a1)+,d0
	muls.w	d4,d0
	add.l	d0,d5
	add.l	d6,d5
	swap	d5
	move.w	d5,(a0)
	lea	pointsize(a0),a0
	dbra	d7,.normyloop
	ELSE	
	addq	#2,a1
.normyloop:
	move.w	(a1),(a0)
	addq	#6,a1
	lea	pointsize(a0),a0
	dbra	d7,.normyloop
	ENDC

* Calculate the z-coordinates..
	lea	pointz(a6),a0			* Get address of first z-coord
	move.l	a3,d3
	move.l	a4,d4
	muls.w	d2,d3
	muls.w	d2,d4
	subq.l	#1,d3
	subq.l	#1,d4
	add.l	d3,d3
	add.l	d4,d4
	swap	d3
	swap	d4
	move.l	a2,a1
	move.w	a5,d7
.zloop:	movem.w	(a1),d5-d6
	muls.w	d3,d5
	muls.w	d1,d6
	sub.l	d6,d5
	addq	#pointz,a1
	move.w	(a1)+,d0
	muls.w	d4,d0
	add.l	d0,d5
	add.l	d5,d5
	swap	d5
	move.w	d5,(a0)
	lea	pointsize(a0),a0
	dbra	d7,.zloop
	rts

* Adds x, y, z values to each of the points in the object and
* transforms 3d -> 2d.
* INPUT: d0.w: x-offset
*        d1.w: y-offset
*        d2.w: z-offset
TRANSFORM_OBJECT:
	lea	points_tbl,a0
	move.w	(a0)+,d7
	subq.w	#1,d7

	move.w	#160/2,d3
	move.w	#100/2,d4
	movea.w	d0,a3
	movea.w	d1,a4
	move.w	#$0100,d5
	sub.w	d2,d5
	move.w	#310,d6

.loop:	move.w	pointz(a0),d0
	neg.w	d0
	add.w	d5,d0			* d0.w: scale factor
	movem.w	(a0),d1-d2
	add.l	a3,d1
	add.l	a4,d2
	lsl.l	#8,d1
	muls.w	d6,d2
	divs.w	d0,d1			* Scale x-coordinate.
	divs.w	d0,d2			* Scale y-coordinate.
	add.w	d3,d1			* Center x-coordinate.
	add.w	d4,d2			* Center y-coordinate.
	move.w	d1,(a0)+
	move.w	d2,(a0)+

; plot the dot... just for some testing..
	ifne	DEBUGG
	mulu.w	#160,d2
	add.w	d1,d2
	movea.l	chunky_adr,a1

	;move.b	#$3C,(a1,d2.w)
	move.b	(a1,d2.w),d0
	not.b	d0
	andi.b	#$3C,d0
	move.b	d0,(a1,d2.w)

	endc

	addq	#pointsize-4,a0
	dbra	d7,.loop
	rts

; for testing.. wireframe always helps..
plot_edges:
;	lea	edgesdone_tbl,a3
	movea.l	edgestbladr,a2
	move.w	(a2)+,d7
	subq.w	#1,d7
	bmi	.rts
	lea	points_tbl+2,a1

.calcedgeloop:
	move.w	d7,-(sp)

	movea.l	chunky_adr,a0
	move.w	(a2)+,d0
	move.w	(a2)+,d4
	mulu.w	#pointsize,d0
	mulu.w	#pointsize,d4
	movem.w	(a1,d0.l),d0-d3
	movem.w	(a1,d4.l),d4-d7
	bsr	draw_edge

	move.w	(sp)+,d7
	dbra	d7,.calcedgeloop
.rts:	rts

; d0.l: X-start
; d1.l: Y-start
; d2.l: U-start
; d3.l: V-start
; d4.l: X-end
; d5.l: Y-end
; d6.l: U-end
; d7.l: V-end
; a0: screen
draw_edge:
	cmp.w	d5,d1
	bgt.s	.domirrored

	beq.s	.emptyedge
	sub.l	d1,d5

	mulu.w	#160,d1
	adda.w	d1,a0

	swap	d0
	swap	d4
	sub.w	d0,d0
	clr.w	d4
	sub.l	d0,d4
	lsl.l	#8,d2
	lsl.l	#8,d3	
	lsl.l	#8,d6
	lsl.l	#8,d7
	sub.l	d2,d6
	sub.l	d3,d7
	divs.w	d5,d6
	divs.w	d5,d7

; todo: !!
;	divs.l	d5,d4

; todo: without wrapping d2,d3 could be paired! saving 8 cycles per scan..
; or.. movem.w could be used?
.loop:	move.l	d0,d1
	swap	d1
	move.b	#$3C,(a0,d1)
	add.l	d4,d0
	add.w	d6,d2
	add.w	d7,d3
	adda.w	#160,a0
	dbf	d5,.loop
.emptyedge:
	rts	

; y-start is larger than y-end, so do everything the other way round.
.domirrored:
	sub.l	d5,d1
	beq.s	.mirroremptyedge

	mulu.w	#160,d5
	adda.w	d5,a0

	swap	d4
	swap	d0
	sub.w	d4,d4
	sub.w	d0,d0
	sub.l	d4,d0
	lsl.l	#8,d6
	lsl.l	#8,d7	
	lsl.l	#8,d2
	lsl.l	#8,d3
	sub.l	d6,d2
	sub.l	d7,d3
	divs.w	d1,d2
	divs.w	d1,d3

; todo: !!
;	divs.l	d1,d0

.mirrorloop:
	move.l	d4,d5
	swap	d5
	move.b	#$3C,(a0,d5)
	add.l	d0,d4
	add.w	d2,d6
	add.w	d3,d7
	adda.w	#160,a0
	dbra	d1,.mirrorloop
.mirroremptyedge:
	rts	

* Plots one environment mapped object. Backface culling and painters
* algorithm depthsorting are used.
* The object plotting is only suited to objects that have a texture mapped
* around them. That is: only one texturebitmap.
PLOT_OBJECT:
* STEP 0:
* Set all edges to unused..
	moveq	#0,d0
	lea	edgesdone_tbl,a0
	movea.l	edgestbladr,a1
	move.w	(a1),d7
	lsr.w	#2,d7
.clredgesdoneloop:
	move.l	d0,(a0)+
	dbra	d7,.clredgesdoneloop

* STEP 1:
* Put all Z-points of triangles in the sorting table and kick out backface
* triangles. Also mark the used edges.
.putsortvals:
	movea.l	pnttritbladr,a5
	move.w	(a5)+,d7
	subq.w	#1,d7
	bmi	.rts
	moveq	#0,d0
	lea	points_tbl+2,a3
	lea	sort_tbl+2,a6
	movea.l	tritbladr,a1
	lea	edgesdone_tbl,a2

.putsortvalsloop:
	move.w	(a5)+,d6
	mulu.w	#pointsize,d6
	movea.w	pointz(a3,d6.l),a4
	movem.w	(a3,d6.l),d1-d2
	move.w	(a5)+,d6
	mulu.w	#pointsize,d6
	adda.w	pointz(a3,d6.l),a4
	movem.w	(a3,d6.l),d3-d4
	move.w	(a5)+,d6
	mulu.w	#pointsize,d6
	adda.w	pointz(a3,d6.l),a4
	movem.w	(a3,d6.l),d5-d6

	sub.w	d3,d1
	sub.w	d3,d5
	sub.w	d4,d2
	sub.w	d4,d6
	muls.w	d1,d6
	muls.w	d2,d5
	cmp.l	d6,d5
	bgt.s	.visible
	addq	#6,a1
	bra.s	.endputsortvalsloop
.visible:
	addq.w	#1,d0					* Increase number of visible triangles.
	move.w	a4,(a6)+				* Store Z-center of triangle in sortingtable.
	move.l	a1,(a6)+				* Store address of triangle.
	movem.w	(a1)+,d1-d3				* Get edgenumbers.
	moveq	#1,d4
	move.b	d4,(a2,d1.l)				* Mark edge 0 as visible.
	move.b	d4,(a2,d2.l)				* Mark edge 1 as visible.
	move.b	d4,(a2,d3.l)				* mark edge 2 as visible.
.endputsortvalsloop:
	addq	#trianglesize-triangleinfo,a5
	dbra	d7,.putsortvalsloop
	move.w	d0,sort_tbl				* Store number of visible triangles.

* STEP 2:
* Calculate all the visible edges into nice edgetables.
.calcedges:
	lea	temp_buf,a4
	lea	edgesdone_tbl,a3
	movea.l	edgestbladr,a2
	move.w	(a2)+,d7
	subq.w	#1,d7
	bmi	.rts
	lea	points_tbl+2,a1
	lea	2*2*MAX_EDGES(a4),a0
	movea.l	a0,a6

.calcedgeloop:
	move.w	d7,-(sp)

	tst.b	(a3)+
	beq.s	.dontcalcedge

	move.l	a0,(a4)+

	move.w	(a2)+,d0
	move.w	(a2)+,d4

	mulu.w	#pointsize,d0
	mulu.w	#pointsize,d4
	movem.w	(a1,d0.l),d0-d3
	movem.w	(a1,d4.l),d4-d7
	bsr	CALCULATE_EDGETABLE
	bra.s	.calcedgeloopend

.dontcalcedge:
	addq	#4,a4
	addq	#4,a2

.calcedgeloopend:
	move.w	(sp)+,d7
	dbra	d7,.calcedgeloop

	ifne	0
* STEP 3:
; not required for this object!
* Now sort all the visible triangles using combsort.
* Combsort rules!! Thanx to Dynacore/.tSCc. for his great article!
	lea	sort_tbl,a1
	move.w	(a1)+,d7			* d7.w: number of triangles
	subq.w	#1,d7
	beq.s	.endcombsort
	bmi	.rts
	movea.l	a1,a3
	move.w	d7,d4
	lsr.w	#1,d4				* d4.w: gapsize
	bra.s	.endcalcgap
.combsortloop:
	cmpi.w	#2,d4				* / If the gapsize
	bhi.s	.calcgap			* | is already 1 or
	moveq	#1,d4				* | 2 then always
	bra.s	.endcalcgap			* \ set it to 1.
.calcgap:
	mulu.w	#((1<<16)*10)/13,d4		* / Resize
	swap	d4				* \ the gap.
.endcalcgap:
	move.w	d7,d6
	sub.w	d4,d6
	move.w	d4,d0
	mulu.w	#2+4,d0
	lea	(a3,d0.l),a5
	moveq	#0,d5				* d5.w: number of swaps done in loop

.combsortinloop:
	move.w	(a1),d0
	move.w	(a5),d1
	cmp.w	d1,d0
	ble.s	.noswap
	move.w	d1,(a1)+			* / Swap
	move.w	d0,(a5)+			* \ depth.
	move.l	(a1),d0				* / Swap the 
	move.l	(a5),(a1)+			* | triangle
	move.l	d0,(a5)+			* \ addresses.
	addq.w	#1,d5
	dbra	d6,.combsortinloop
	bra.s	.combsortloopend
.noswap:	
	addq	#6,a1
	addq	#6,a5
	dbra	d6,.combsortinloop
.combsortloopend:
	movea.l	a3,a1
	move.w	d5,d5
	bne.s	.combsortloop
	cmpi.w	#1,d4
	bne.s	.combsortloop
.endcombsort:
	endc

* STEP 4:
* Plot all the visible triangles in their Z-order.
	lea	sort_tbl,a1
	move.w	(a1)+,d7
	subq.w	#1,d7
	bmi.s	.rts
	lea	temp_buf,a2
	movea.l	envtextureadr,a3
	adda.l	#256*128+128,a3

.plottriangleloop:
	move.w	d7,-(sp)

	addq	#2,a1
	movea.l	(a1)+,a0
	movem.w	(a0),d0-d2
	movem.l	a1-a3,-(sp)
	bsr	PLOT_ENVMAPTRIANGLE
	movem.l	(sp)+,a1-a3

	move.w	(sp)+,d7
	dbra	d7,.plottriangleloop

.rts:	rts

; d1.l=u0 0000UUuu
; d2.l=u1 0000UUuu
; d3.l=v0 0000VVvv
; d4.l=v1 0000VVvv
; d7.w=width [w]
prestep_hline:
	lea	Tmap.invTable,a1
	tst.w	d7
	bpl.s	.width_abs
	neg.w	d7
.width_abs:
	move.w	d7,d6
	add.w	d6,d6
	move.w	(a1,d6.w),d5				; d5.w=1/w [16:16]

; u coord stuffs..
	sub.l	d1,d2					; d2.l=u1-u0
	muls.w	d5,d2
	add.l	d2,d2					; d2.w=(u1-u0)/w=u_step UUuucrap
; v coord stuffs..
	sub.l	d3,d4					; d4.l=v1-v0
	muls.w	d5,d4
	add.l	d4,d4					; d4.w=(v1-v0)/w=v_step VVvvcrap
	clr.w	d4					; d4.l=v_step VVvv0000
	add.l	d2,d2

; step: mix u and v.
	rol.l	#8,d4					; d4.l=v_step vv0000VV
	move.w	d4,d5					; d5.w=v_step 00VV
	swap	d2
	move.w	d2,d4					; d4.l=v_step|u_vstep vv00UUuu
; start: mix u and v.
	ror.l	#8,d3					; d3.l=v0 vv0000VV
	move.w	d3,d2					; d2.w=00VV
	move.w	d1,d3					; d3.l=v0|u0 vv00UUuu

	lea	map_instr_table,a0
	move.l	map_instr_template,d0
	lea	.tree_end(pc),a2

	ifne	DEBUGG
	cmpi.w	#160,d7
	ble.s	.width_ok
	move.w	#$0FFF,$FFFF8240.w
.hang:	jmp	.hang
.width_ok:
	endc

	move.w	d7,d1				; d7.w=w
	add.w	d7,d7				; d7.w=2w
	add.w	d7,d7				; d7.w=4w
	add.w	d1,d7				; d7.w=5w=4w+w
	add.w	d7,d7				; d7.w=10w
	neg.w	d7				; d7.w=-10w
	jmp	(a2,d7.w)

	rept	160
	move.w	d3,d0
	move.b	d2,d0
	move.l	d0,(a0)+
	add.l	d4,d3
	addx.w	d5,d2
	endr
.tree_end:

	move.w	map_term_template(pc),(a0)+		; terminate with rts.
	rts

map_instr_template:
	move.b	$1234(a1),(a0)+
map_term_template:
	rts

; Calculates all scanline points of the edges and puts them in a table.
; This should also take care of horizontal clipping and of onscreen
; detection.
; input:
; d0.l: X-start
; d1.l: Y-start
; d2.l: U-start
; d3.l: V-start
; d4.l: X-end
; d5.l: Y-end
; d6.l: U-end
; d7.l: V-end
; a0: address to write new edgetable to
; output:
; a0: address of next edgetable
; todo: kill divs.. and replace with muls
CALCULATE_EDGETABLE:
	cmp.w	d5,d1
	bgt.s	.domirrored

	beq.s	.emptyedge
	sub.l	d1,d5
	move.w	d5,(a0)+
	move.w	d1,(a0)+

	sub.l	d0,d4
	swap	d0
	clr.w	d0

	lsl.l	#8,d2
	lsl.l	#8,d3	
	lsl.l	#8,d6
	lsl.l	#8,d7
	sub.l	d2,d6
	sub.l	d3,d7
	divs.w	d5,d6
	divs.w	d5,d7

	lsl.l	#8,d4
	divs.w	d5,d4
	ext.l	d4
	lsl.l	#8,d4

	move.l	d4,(a0)+
; todo: without wrapping d2,d3 could be paired! saving 8 cycles per scan..
; or.. movem.w could be used?
.loop:	move.l	d0,d1
	swap	d1
	move.w	d1,(a0)+
	move.w	d2,(a0)+
	move.w	d3,(a0)+
	add.l	d4,d0
	add.w	d6,d2
	add.w	d7,d3
	dbf	d5,.loop
	rts	
; edge is completely horizontal, so it doesn't need to be drawn.
.emptyedge:
	clr.w	(a0)+
	move.w	d1,(a0)+
	addq	#edgeheadersize-4,a0
	rts

; y-start is larger than y-end, so do everything the other way round.
.domirrored:
	sub.l	d5,d1
	beq.s	.mirroremptyedge
	move.w	d1,(a0)+
	move.w	d5,(a0)+

	sub.l	d4,d0
	swap	d4
	clr.w	d4

	lsl.l	#8,d6
	lsl.l	#8,d7	
	lsl.l	#8,d2
	lsl.l	#8,d3
	sub.l	d6,d2
	sub.l	d7,d3
	divs.w	d1,d2
	divs.w	d1,d3
	lsl.l	#8,d0
	divs.w	d1,d0
	ext.l	d0
	lsl.l	#8,d0

	move.l	d0,(a0)+
.mirrorloop:
	move.l	d4,d5
	swap	d5
	move.w	d5,(a0)+
	move.w	d6,(a0)+
	move.w	d7,(a0)+
	add.l	d0,d4
	add.w	d2,d6
	add.w	d3,d7
	dbra	d1,.mirrorloop
	rts	
; edge is completely horizontal, so it doesn't need to be drawn.
.mirroremptyedge:
	clr.w	(a0)+
	move.w	d5,(a0)+
	addq	#edgeheadersize-4,a0
	rts

; plots a texturemapped triangle using the specified edgetables.
; horizontal clip is done per scanline..
; vertical clip i don't know..
; input:
; d0.l: edge index 1
; d1.l: edge index 2
; d2.l: edge index 3
; a2: address of edgetable-buffer
; a3: address of middle of texture (256*256 bytes)
PLOT_ENVMAPTRIANGLE:
	move.l	a3,.textureadr
	add.w	d0,d0
	add.w	d0,d0
	add.w	d1,d1
	add.w	d1,d1
	add.w	d2,d2
	add.w	d2,d2
	movea.l	(a2,d0.w),a4
	movea.l	(a2,d1.w),a5
	movea.l	(a2,d2.w),a6

* Find out which two edges are first and which one is second.
.order:	move.w	edgestarty(a4),d0
	move.w	edgestarty(a5),d1
	move.w	edgestarty(a6),d2
	cmp.w	d0,d1
	beq.s	.endorder
	cmp.w	d0,d2
	bne.s	.1_2
	exg	a6,a5
	exg	d2,d1
	bra.s	.endorder
.1_2:	exg	a6,a4
	exg	d2,d0
.endorder:

* Test if all edges start are first => triangle is a dot/scanline or a \/
.testspecial:
	cmp.w	d0,d2
	bne.s	.calcnormalslope
	tst.w	(a4)
	bne.s	.testa5
	exg	a4,a6
	bra.s	.testscan
.testa5:tst.w	(a5)
	bne.s	.testscan
	exg	a5,a6
* Test if the triangle is a dot/scanline
.testscan:
	tst.w	(a4)
	bne.s	.specialslope
	tst.w	(a5)
	bne.s	.specialslope
	tst.w	(a6)
	bne.s	.specialslope
	rts

* Calculate slope-offset table for special \/ case.
.specialslope:
	movem.w	edgeheadersize(a4),d0-d2		; d0-d2=x0,u0,v0
	movem.w	edgeheadersize(a5),d3-d5		; d3-d5=x1,u1,v1

	move.w	d3,d7
	sub.w	d0,d7					; d7.w=x1-x0=w
	move.w	d2,d3					; d3.w=v0
	move.w	d5,d4					; d4.w=v1
	exg	d1,d3
	exg	d2,d4
	bsr	prestep_hline

* Find out which edges are left and which are right.
	move.w	edgeheadersize(a5),d0
	cmp.w	edgeheadersize(a4),d0
	bge.s	.plot
	exg	a4,a5
	bra.s	.plot

* Calculate slope-offset table for normal case.
.calcnormalslope:
	move.w	(a4),d6
	move.w	(a5),d1
	cmp.w	d1,d6
	ble.s	.d6smaller
	move.w	d1,d6
.d6smaller:
	mulu.w	#6,d6
	movem.w	edgeheadersize(a4,d6.l),d0-d2		; d0-d2=x0,u0,v0
	movem.w	edgeheadersize(a5,d6.l),d3-d5		; d3-d5=x1,u1,v1

	move.w	d3,d7
	sub.w	d0,d7					; d7.w=x1-x0=w
	move.w	d2,d3					; d3.w=v0
	move.w	d5,d4					; d4.w=v1
	exg	d1,d3
	exg	d2,d4
	bsr	prestep_hline

* Find out which edges are left and which are right..
.leftright:
	move.l	edgeslope(a5),d0
	cmp.l	edgeslope(a4),d0
	bge.s	.noswap
	exg	a4,a5
.noswap:

* Prepare for plotting in the screenbuffer.
.plot:
.initplot:
	moveq	#0,d6
	move.w	(a4),d5
	move.w	(a5),d6
	sub.w	d5,d6
	bgt.s	.endinitplot
	neg.w	d6
	move.w	(a5),d5
	bset	#31,d6				* Edge in a4 is longest.
.endinitplot:

	movea.l	chunky_adr,a3
	move.l	.textureadr(pc),d7
	move.l	#map_instr_table,d4

.yclip:	move.w	edgestarty(a4),d0
	bpl.s	.noylowclip
	add.w	d0,d5
	ble.s	.noplotfirst
	neg.w	d0
	mulu.w	#6,d0
	adda.l	d0,a4
	adda.l	d0,a5
	moveq	#0,d0
	bra.s	.endyclip
.noplotfirst:
	add.w	d5,d6
	ble	.rts
	neg.w	d0
	neg.w	d5
	mulu.w	#6,d0
	mulu.w	#6,d5
	lea	edgeheadersize(a4,d0.l),a4
	lea	edgeheadersize(a5,d0.l),a5
	adda.l	d5,a6
	bra	.plotsecond
.noylowclip:
	cmpi.w	#Tmap.MAX_Y,d0
	bge	.rts
	move.w	d6,d1
	add.w	d5,d1
	add.w	d0,d1
	bmi	.rts
	subi.w	#Tmap.MAX_Y,d1
	bmi.s	.endyclip
	sub.w	d1,d6
	bpl.s	.endyclip
	add.w	d6,d5
.endyclip:

.plotfirst:
	mulu.w	#160,d0
	addq	#edgeheadersize,a4
	addq	#edgeheadersize,a5
	adda.l	d0,a3
	subq.w	#1,d5

; Plot upper part of triangle.
.firstloop:
	movea.l	d4,a2				; a2: prestepped instructions
	move.w	(a5),d3				; d3.w=rx
	addq	#6,a5
	movem.w	(a4)+,d0-d2

	movea.l	d7,a1
	lsr.w	#8,d1
	move.b	d1,d2
	lea	(a1,d2.w),a1

	ifne	0
	move.l	d0,d1
	bpl.s	.xpos1
; should never happen in this fx..
	move.w	#$0F0F,background_color
	neg.w	d1
	add.w	d1,d1
	add.w	d1,d1				; d1.w=-4x0
	lea	(a2,d1.w),a2			; not too useful in this case??
	moveq	#0,d0
	endc

.xpos1:	lea	(a3,d0.w),a0

	ifne	0
	cmpi.w	#160,d3
	blt.s	.nottoobig
; should never happen in this fx..
	move.w	#$0FF0,background_color
	move.w	d3,d2
	subi.w	#160,d2
	sub.w	d2,d3
.nottoobig:
	endc

	sub.w	d0,d3
	bmi.s	.endfirstline

	ifne	DEBUGG
	cmpi.w	#100,d3
	ble.s	.width_ok
	move.w	#$0FFF,$FFFF8240.w
.hang:	jmp	.hang
.width_ok:
	endc

; d3.w=width
; a2: instruction table start
	add.w	d3,d3
	add.w	d3,d3				; d3.w=4w
	move.w	(a2,d3.w),d0			; store instr word at table+4w.
	move.w	#$4E75,(a2,d3.w)		; 'rts' at table+4w
	jsr	(a2)
	move.w	d0,(a2,d3.w)			; restore table+4w.

.endfirstline:
	lea	160(a3),a3
	dbf	d5,.firstloop
.endplotfirst:

* Plot lower part of triangle..
.plotsecond:
	subq.w	#1,d6
	bmi.s	.endsecond			; Triangle is a /\ or a \/
* Test if left or right was shorter..
	tst.l	d6				; Which edge is longest?
	bmi.s	.noswaplr
	lea	edgeheadersize(a6),a4
	move.w	d6,d5
	sub.w	d6,d6
	bra	.firstloop

.noswaplr:
	move.w	d6,d5
	sub.w	d6,d6
	lea	edgeheadersize(a6),a5
	bra	.firstloop

.endsecond:

.endscanplot:

.rts:	rts

.edgestartadr:
	DS.L	1
.textureadr:
	DS.L	1
.textureoffset_tbl:
	DS.W	scrxbytes/2

;--------------------------------------------------------------------------

conv_apx_to_chunky:
	lea	white,a0
	moveq	#0,d7
.loop:	
; prepare for 4bpp texture (pre-shifted)
	move.b	(a0),d0

	ifne	0

	moveq	#0,d1
	move.b	d0,d1
	mulu.w	#15,d1
	addi.w	#$0100,d1
	lsr.w	#6,d1
	move.w	d1,d0
	
	else

	lsr.b	#2,d0

	endc

	andi.w	#$3C,d0
	move.b	d0,(a0)+
	addq.w	#1,d7
	bne.s	.loop
	rts

;--------------------------------------------------------------------------
	data

; 4bpl
;
; 00.00llll0000llll00<<4
; =
; ll.ll0000llll000000
; 
; ll.ll0000llll000000
; 00.00rrrr0000rrrr00
; ------------------- +
; ll.llrrrrllllrrrr00

c2ploopstart:
	MOVEm.W	(A1)+,D0-d7		; 44
	LSL.l	#4,D0			; 16
	OR.W	d1,D0			;  4
	MOVE.L	0(A2,D0.l),D0		; 18
c2poffset1:	=	*+2
	MOVEP.L	D0,0(A0)		; 24
	LSL.l	#4,D2			; 16
	OR.W	d3,D2			;  4
	MOVE.L	0(A2,D2.l),D0		; 18
c2poffset2:	=	*+2
	MOVEP.L	D0,1(A0)		; 24
	LSL.l	#4,D4			; 16
	OR.W	d5,D4			;  4
	MOVE.L	0(A2,D4.l),D0		; 18
c2poffset3:	=	*+2
	MOVEP.L	D0,8(A0)		; 24
	LSL.l	#4,D6			; 16
	OR.W	d7,D6			;  4
	MOVE.L	0(A2,D6.l),D0		; 18
c2poffset4:	=	*+2
	MOVEP.L	D0,9(A0)		; 24
					; -- +
					;292
c2ploopend:

c2ploopsize:=	c2ploopend-c2ploopstart

c2p2loopstart:
	MOVEm.W	(A1)+,D0-d3		; 28
	LSL.L   #4,D0			; 16
	OR.W    d1,D0			;  4
	MOVE.L  0(A2,D0.l),D0		; 18
c2p2offset1:=	*+2
	MOVEP.L D0,0(A0)		; 24
	LSL.L   #4,D2			; 16
	OR.W    d3,D2			;  4
	MOVE.L  0(A2,D2.l),D0		; 18
c2p2offset2:=	*+2
	MOVEP.L D0,1(A0)		; 24
					; -- +
					;152
c2p2loopend:
c2p2loopsize:=	c2p2loopend-c2p2loopstart

doubleloopstart:
	movem.l	(a1)+,d0-d7/a2-a6	; 112
double1offset:=	*+4
	movem.l	d0-d7/a2-a6,0(a0)	; 116
	movem.l	(a1)+,d0-d7/a2-a6	; 112
double2offset:=	*+4
	movem.l	d0-d7/a2-a6,52(a0)	; 116
	movem.l	(a1)+,d0-d7/a2-a6	; 112
double3offset:=	*+4
	movem.l	d0-d7/a2-a6,104(a0)	; 116
double4offset:=	*+2
	move.l	(a1)+,156(a0)		;  16
	lea	160(a1),a1		;   8
;					 ---- +
;                                         708
; 708 cycles/scanline x 100 scanlines =  70800 cycles

doubleloopend:
doubleloopsize:=doubleloopend-doubleloopstart

env_object:
; todo!!
	dc.w (.end-.start)/pointsize
.start:	dc.w -56,2,0,0,-36		;  0
	dc.w +56,10,0,0,-36		;  1
	dc.w +56,10,0,0,36		;  2
	dc.w -56,2,0,0,36		;  3
	dc.w -56,32,0,0,36		;  4
	dc.w +56,32,0,0,36		;  5
	dc.w +56,32,0,0,-36		;  6
	dc.w -56,32,0,0,-36		;  7
	dc.w -12,-10,0,0,36		;  8
	dc.w -12,-10,0,0,-36		;  9
.end:

; triangle list
point_triangles:
	dc.w (.end-.start)/trianglesize

.start:
;	dc.w 5,8,2,5,4,3
	dc.w 8,2,5,0
	dc.w 8,5,4,0
	dc.w 8,4,3,0

;	dc.w 4,6,5,2,1
	dc.w 6,5,2,0
	dc.w 6,2,1,0

;	dc.w 4,3,0,9,8	; <- poly with mouse buttons..
	dc.w 3,0,9,0
	dc.w 3,9,8,0

;	dc.w 4,9,1,2,8
	dc.w 9,1,2,0
	dc.w 9,2,8,0

;	dc.w 4,4,5,6,7
	dc.w 4,5,6,0
	dc.w 4,6,7,0

;	dc.w 4,0,3,4,7
	dc.w 0,3,4,0
	dc.w 0,4,7,0

;	dc.w 5,1,9,0,7,6
	dc.w 1,9,0,0
	dc.w 1,0,7,0
	dc.w 1,7,6,0
.end:

edges:	dc.w	(.end-.start)/4

.start:	dc.w 2,8			;  0
	dc.w 2,5			;  1
	dc.w 5,8			;  2
	dc.w 4,5			;  3
	dc.w 4,8			;  4
	dc.w 3,4			;  5
	dc.w 3,8			;  6

	dc.w 5,6			;  7
;	dc.w 2,5			;  1
	dc.w 2,6			;  8
	dc.w 1,2			;  9
	dc.w 1,6			; 10

	dc.w 0,3			; 11
	dc.w 0,9			; 12
	dc.w 3,9			; 13
	dc.w 8,9			; 14
;	dc.w 3,8			;  6

	dc.w 1,9			; 15
;	dc.w 1,2			;  9
	dc.w 2,9			; 16
;	dc.w 2,8			;  0
;	dc.w 8,9			; 14

;	dc.w 4,5			;  3
;	dc.w 5,6			;  7
	dc.w 4,6			; 17
	dc.w 6,7			; 18
	dc.w 4,7			; 19

;	dc.w 0,3			; 11
;	dc.w 3,4			;  5
	dc.w 0,4			; 20
;	dc.w 4,7			; 19
	dc.w 0,7			; 21

;	dc.w 1,9			; 15
;	dc.w 0,9			; 12
	dc.w 0,1			; 22
;	dc.w 0,7			; 21
	dc.w 1,7			; 23
;	dc.w 1,6			; 10
;	dc.w 6,7			; 18
.end:

edge_triangles:
;	dc.w	(.end-.start)/6
.start:	dc.w 0,1,2
	dc.w 2,3,4
	dc.w 4,5,6

	dc.w 7,1,8
	dc.w 8,9,10

	dc.w 11,12,13
	dc.w 13,14,6

	dc.w 15,9,16
	dc.w 16,0,14

	dc.w 3,7,17
	dc.w 17,18,19

	dc.w 11,5,20
	dc.w 20,19,21

	dc.w 15,12,22
	dc.w 22,21,23
	dc.w 23,10,18
.end:

	dc.w (86*8)/9,(65*8)/9,(68*8)/9
	dc.w (-86*8)/9,(65*8)/9,(68*8)/9
	dc.w (-86*8)/9,(65*8)/9,(-68*8)/9
	dc.w (86*8)/9,(65*8)/9,(-68*8)/9
	dc.w (73*8)/9,(-73*8)/9,(-73*8)/9
	dc.w (-73*8)/9,(-73*8)/9,(-73*8)/9
	dc.w (-73*8)/9,(-73*8)/9,(73*8)/9
	dc.w (73*8)/9,(-73*8)/9,(73*8)/9
	dc.w (0*8)/9,(113*8)/9,(-58*8)/9
	dc.w (0*8)/9,(113*8)/9,(58*8)/9

chunky_adr:
	dc.l	chunky_buffer

sphere:	incbin	sphere.apx
white:	=	sphere+788

;--------------------------------------------------------------------------

	bss

	ifne	DEBUGG
	ds.w	10000
	endc

map_instr_table:
	ds.l	160+1

	ifne	DEBUGG
	ds.w	10000
	endc

chunky_buffer:
	ds.b	160*Tmap.MAX_Y

points_tbl:
	DS.W	1				; number of 3d-points in object
	DS.W	pointsize*MAX_POINTS		; X,Y,TX,TY,Z
pnttritbladr:
	DS.L	1
edgestbladr:
	DS.L	1
tritbladr:
	DS.L	1
normaltbladr:
	DS.L	1
envtextureadr:
	DS.L	1

edgesdone_tbl:
	DS.B	MAX_EDGES
sort_tbl:
	DS.W	3*MAX_TRIANGLES

Tmap.invTable:
	ds.w	INV_SIZE+1
