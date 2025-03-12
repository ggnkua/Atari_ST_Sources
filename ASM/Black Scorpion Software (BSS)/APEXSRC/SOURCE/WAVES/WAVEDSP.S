
;-----------------------------------------------------------------------
; DSP Wave System
; by
; Neil Stewart
; (28/8/94)
;
; This program simulates a liquid basin with variable dampening and
; reactivity to waveforms.
;
; The result is a pleasing plasma effect which can be amplified by
; indirecting the wave heights through a moving colour palette and
; making wave pulses bounce off the edges of the basin.
;
; The simulation uses the Laplacian difference filter on a cellular
; automaton (like Conway's Life).
;
; This demo is a prelude to the forthcoming AutoTRIP, which allows
; the user to script a series of waves effects with other pleasing
; visuals, and is designed for people who like swallowing small bits
; of paper with funny pictures on them as a form of recreation (?)
;
;-----------------------------------------------------------------------

	include	"gemdos.i"
	include	"xbios.i"
	include	"general.i"
	include	"dspmac2.i"
	include	"video.i"
	include	"cache.i"

;	output	d:\wavedsp.prg

;-----------------------------------------------------------------------
; Equates
;-----------------------------------------------------------------------

width	=	64
height	=	40

;-----------------------------------------------------------------------
; Start
;-----------------------------------------------------------------------

	G_SUPER	#0

	move.l	#screen1,d0
	add.l	#3,d0
	and.l	#-4,d0
	move.l	d0,screenptr1
	move.l	#screen2,d0
	add.l	#3,d0
	and.l	#-4,d0
	move.l	d0,screenptr2

	V_PHYSBASE
	move.l	d0,oldphys
	V_LOGBASE
	move.l	d0,oldlog
	V_SETSCREEN screenptr1,screenptr1,#-1,#-1
	V_SETMODE #TRUE|VGA|LACE
;	V_SETMODE #TRUE|PAL
	move.w	d0,oldmode
;	bset	#0,$fffff82c3.w
	clr.l	$ffff9800.w

	move.l	$70.w,oldvbl
	move.l	#vbl,$70.w

;	bsr	createtable

;-----------------------------------------------------------------------
; Init DSP libraries							
;-----------------------------------------------------------------------

	jsr		IsDspDrv

;-----------------------------------------------------------------------
; Execute program
;-----------------------------------------------------------------------

	lea	DSP,a0		address of DSP file
	move.l	#DSP_L,d0	length of DSP file/3
	moveq	#1,d1		must be #1
	jsr	DspExecProg

;-----------------------------------------------------------------------
; Main loop 
;-----------------------------------------------------------------------

Main:

;-----------------------------------------------------------------------
; Send various params to DSP
; These are:
;	DAMPEN		- 24 bit fraction
;	REACT		- 24 bit fraction
;	MAX		- 16 bit integer
;	OUTPUT		- 0 or 1 (16 bit integer)
;	BITS		- 16 bit integer
;	CLEARVELOCITY	- 0 or 1 (16 bit integer)
;-----------------------------------------------------------------------

	dsptx				; wait till DSP ready
	dsp_write.l	DAMPEN
	dsp_write.l	REACT
	dsp_write.l	MAX
	dsp_write.l	INTERPOLATE
	dsp_write.l	BITS
	dsp_write.l	CLEARVELOCITY
	dsp_write.l	COLOURLOOKUP

;-----------------------------------------------------------------------
; DSP should be ready to send first frame.
; Get it and dump it to screen.
;-----------------------------------------------------------------------

Again	
	move.l	screenptr1,d0
	move.l	screenptr2,screenptr1
	move.l	d0,screenptr2

	V_SETSCREEN screenptr1,screenptr1,#-1,#-1
	X_VSYNC
	clr.w	vblcount

	jsr	DoSources

; Get palette address and send it to DSP (if in LOOKUP mode)

	tst.l	COLOURLOOKUP
	beq	.nolookup
	lea	tablefile+20,a0
	moveq	#0,d0
	move.w	tablecount,d0
	move.w	d0,d1
	lsl.l	#8,d0			*256
	add.l	d0,d0
	add.l	d0,a0
	add.w	tabledir,d1
	move.w	d1,tablecount
	cmp.w	#tablemax,d1
	blt.s	.tableok1
	move.w	#-1,tabledir
.tableok1
	tst.w	d1
	bne.s	.tableok2
	move.w	#1,tabledir
.tableok2
	jsr	SendPalette
.nolookup	

	dsptx
	move.w	numsources,d0
	dsp_write.w	d0		; send number of plots

	lea	sourcedata,a0
	bra.s	.endsourcelp
.sourcelp
	dsp_write.w	(a0)+		; x
	dsp_write.w	(a0)+		; y
	dsp_write.l	(a0)+		; height
.endsourcelp
	dbf	d0,.sourcelp

	dsprx				; ready to send ?
	move.w	#0,$ffff9800.w

	move.w	#width,d7
	move.w	d7,d6
	add.w	d6,d6
	move.w	d6,d5
	add.w	d5,d5
	add.w	d6,d5
	neg.w	d7
	add.w	#320,d7
	add.w	d7,d7
;	lsl.w	#2,d7			; skip after each 4 lines

	move.l	screenptr2,a0
	lea	$FFFFA206.w,a3

	CACHE	C_IENAB
;|C_DENAB|C_IBRST|C_DBRST
;	CACHE	0
	
	move.w	#height*2,d1
	bra	.endylp
.ylp
	dsprx
	move.w	#width*2/16,d0
	bra	.endxlp
.xlp
	rept	16
	move.w	(a3),d2
;(a0)+
;	move.w	(a3),d2
;	move.w	(tablefile+20,pc,d2.w*2),(a0)+
;	move.w	(tablefile+20,pc,d2.w*2),(a0)+
;	move.w	(tablefile+20,pc,d2.w*2),(a0)+
;	move.w	(tablefile+20,pc,d2.w*2),(a0)+
;	move.w	d2,(a0)+
	move.w	d2,(a0)+
;	move.w	d2,(a0)+
;	move.w	d2,(a0)+
	endr
.endxlp
	dbf	d0,.xlp
	add.w	#320+64,a0
;	add.w	d7,a0
.endylp
	dbf	d1,.ylp

;	X_VSYNC
;	move.w	#-1,$ffff9800.w

	CACHE	0

	move.w	vblcount,permcount

;	move.w	#7,-(sp)
;	trap	#1
;	addq.w	#2,sp
;	swap	d0
;	cmp.b	#57,d0

WaitBack
	move.b	$fffffc02.w,d0
	cmp.b	#72,d0
	beq	Wait

	cmp.b	#57,d0
	bne	Again

;-----------------------------------------------------------------------
; End program
;-----------------------------------------------------------------------

	move.l	oldvbl,$70.w

	move.l	#-1,$ffff9800.w
	V_SETMODE	oldmode
	V_SETSCREEN oldlog,oldphys,#-1,#-1

	clr.w	-(sp)
	trap	#1

Wait
	X_VSYNC
	bra	WaitBack
	
createtable
	lea	tablefile+20,a0
;	lea	table,a1
	move.w	#256-1,d0
.lp
	move.w	(a0)+,d1
	move.w	d1,d2
	swap	d2
	move.w	d1,d2
	move.l	d2,(a1)+
	dbf	d0,.lp
	rts

;tablefile	incbin	"e:\colrast.blk"
;tablefile	incbin	"e:\bluerast.blk"
tablefile	incbin	"megacol.apx"
;tablefile	incbin	"d:\fire.apx"
;tablefile	incbin	"d:\pastel.apx"

tablecount	dc.w	0
tablemax	=	127
tabledir	dc.w	1

;tablefile
	ds.b	20
q	set	0
	rept	32
	dc.w	q,q,q,q,q,q,q,q
q	set	q+%0000100001000001
	endr
q	set	0
	rept	32
	dc.w	q,q,q,q,q,q,q,q
q	set	q+%0000100001000001
	endr

;-----------------------------------------------------------------------
; Send a palette (16 bit TC format) to the DSP
; a0 = palette address
;-----------------------------------------------------------------------

SendPalette:
	move.w	#256-1,d7
	moveq	#0,d0
.lp
	dsptx
	move.w	(a0)+,d0
	dsp_write.l	d0
	dbf	d7,.lp
	rts

;-----------------------------------------------------------------------
; Source point control
;-----------------------------------------------------------------------

		rsreset
Source_X	rs.w	1
Source_Y	rs.w	1
Source_Height	rs.l	1
Source_Skip	rs.b	0

		rsreset
S_X		rs.w	1
S_Y		rs.w	1
S_Index		rs.w	1
S_Inc		rs.w	1
S_Amp		rs.w	1
S_Base		rs.w	1
S_Skip		rs.b	0

DoSources
	move.w	posxamp,d0
	move.w	posxindex,d1
	muls	(sintab,pc,d1.w*2),d0
	add.l	d0,d0
	swap	d0
	add.w	posxbase,d0
	move.w	d0,posx
	add.w	posxinc,d1
	and.w	#4095,d1
	move.w	d1,posxindex

	move.w	posyamp,d0
	move.w	posyindex,d1
	muls	(sintab,pc,d1.w*2),d0
	add.l	d0,d0
	swap	d0
	add.w	posybase,d0
	move.w	d0,posy
	add.w	posyinc,d1
	and.w	#4095,d1
	move.w	d1,posyindex

	lea	sourcespecs,a0
	lea	sourcedata,a1
	move.w	numsources,d7
	bra	.endlp
.lp
	move.w	S_X(a0),d0
	add.w	posx,d0
	move.w	d0,Source_X(a1)

	move.w	S_Y(a0),d0
	add.w	posy,d0
	move.w	d0,Source_Y(a1)

	move.w	S_Index(a0),d0
	move.w	d0,d1
	add.w	S_Inc(a0),d1
	and.w	#4095,d1
	move.w	d1,S_Index(a0)
	move.w	(sintab,pc,d0.w*2),d0
	muls	S_Amp(a0),d0
	add.l	d0,d0
	move.w	S_Base(a0),d1
	swap	d1
	clr.w	d1
	add.l	d1,d0
	asr.l	d0
	move.l	d0,Source_Height(a1)
	lea	S_Skip(a0),a0
	lea	Source_Skip(a1),a1
.endlp
	dbf	d7,.lp
	rts

posx		dc.w	32
posxamp		dc.w	30
posxindex	dc.w	1024
posxbase	dc.w	32
posxinc		dc.w	57

posy		dc.w	20
posyamp		dc.w	15
posyindex	dc.w	0
posybase	dc.w	20
posyinc		dc.w	33

numsources
	dc.w	1

sourcedata
	ds.w	Source_Skip*10

sourcespecs

	dc.w	0,0,0,200,127,128

; Swirl (n=4)
a	set	127
b	set	128
i	set	200
;	dc.w	0,-1,0,i,a,b
;	dc.w	1,0,1024,i,a,b
;	dc.w	0,1,2048,i,a,b
;	dc.w	-1,0,3072,i,a,b

; BigSwirl (n=8)
	rept	1
a	set	127
b	set	128
i	set	-400
	dc.w	0,-2,0,i,a,b
	dc.w	1,-1,512,i,a,b
	dc.w	2,0,1024,i,a,b
	dc.w	1,1,1536,i,a,b
	dc.w	0,2,2048,i,a,b
	dc.w	-1,1,2560,i,a,b
	dc.w	-2,0,3072,i,a,b
	dc.w	-1,-1,3584,i,a,b
	endr

; Dipole (n=2)
;	dc.w	39,20,0,200,127,128
;	dc.w	41,20,2048,200,127,128

; Confuse (n=2)
;	dc.w	40,20,0,50,127,128
;	dc.w	41,20,0,800,17,18

; Line (n=20)
qp	set	0
qx	set	30
	rept	20
	dc.w	qx,20,qp,50,127/2,128/2
qp	set	qp+102
qx	set	qx+1
	endr

;-----------------------------------------------------------------------
; Include DSP library
;-----------------------------------------------------------------------

	include	"dsplib.s"

;-----------------------------------------------------------------------
; Include DSP program
;-----------------------------------------------------------------------

DSP:		incbin	"waves.dsp"
DSP_E:	even
DSP_L:	=		(DSP_E-DSP)/3

;-----------------------------------------------------------------------
; VBL Counter
;-----------------------------------------------------------------------

vbl
	addq.w	#1,vblcount
	move.l	oldvbl,-(sp)
	rts

;-----------------------------------------------------------------------
; Variables
;-----------------------------------------------------------------------

DAMPEN		dc.l	$3a0000
REACT		dc.l	$200000
MAX		dc.l	255*32768
INTERPOLATE	dc.l	1
BITS		dc.l	1
CLEARVELOCITY	dc.l	1
COLOURLOOKUP	dc.l	1

sintab	incbin	"f:\inc\hirescos.tab"

;-----------------------------------------------------------------------
; BSS section
;-----------------------------------------------------------------------

	section	bss

oldlog		ds.l	1
oldphys		ds.l	1
oldmode		ds.l	1
oldvbl		ds.l	1
vblcount	ds.w	1
permcount	ds.w	1

screenptr1	ds.l	1
screenptr2	ds.l	1

screen1
	ds.w	320*240+4
screen2
	ds.w	320*240+4
