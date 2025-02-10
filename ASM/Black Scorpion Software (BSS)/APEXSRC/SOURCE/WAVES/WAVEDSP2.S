
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

INCIT

	ifnd	INCIT
	include	"gemdos.i"
	include	"xbios.i"
	include	"general.i"
	include	"video.i"
	include	"cache.i"
	include	"dspmac2.i"
	elseif
	include	"incdir\dspmac2.i"
	endc
	
;-----------------------------------------------------------------------
; Equates
;-----------------------------------------------------------------------

bum_width	=	64
bum_height	=	40

;-----------------------------------------------------------------------
; Start
;-----------------------------------------------------------------------

	ifnd	INCIT
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

	move.l	$70.w,oldvbl
	move.l	#vbl,$70.w
	
;-----------------------------------------------------------------------
; Init DSP libraries							
;-----------------------------------------------------------------------

	jsr		IsDspDrv

;-----------------------------------------------------------------------
; Execute program
;-----------------------------------------------------------------------

	lea		DSP_Bum,a0		;address of DSP file
	move.l	#DSP_BumL,d0	;length of DSP file/3
	moveq		#1,d1			;must be #1
	jsr		DspExecProg

	endc

;-----------------------------------------------------------------------
; Main loop 
;-----------------------------------------------------------------------

	ifnd	INCIT
Main:
	endc

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

Init_Bum
	ifd		INCIT
	lea		DSP_Bum,a0		;address of DSP file
	move.l	#DSP_BumL,d0	;length of DSP file/3
	moveq		#1,d1			;must be #1
	jsr		DspExecProg
	endc

	dsptx				; wait till DSP ready
	dsp_write.l	DAMPEN
	dsptx				; wait till DSP ready
	dsp_write.l	REACT
	dsptx				; wait till DSP ready
	dsp_write.l	MAX
	dsptx				; wait till DSP ready
	dsp_write.l	INTERPOLATE
	dsptx				; wait till DSP ready
	dsp_write.l	BITS
	dsptx				; wait till DSP ready
	dsp_write.l	CLEARVELOCITY
	dsptx				; wait till DSP ready
	dsp_write.l	COLOURLOOKUP

	ifd		INCIT
	rts
	endc
	
;-----------------------------------------------------------------------
; DSP should be ready to send first frame.
; Get it and dump it to screen.
;-----------------------------------------------------------------------

	ifnd	INCIT
Again	
	move.l	screenptr1,d0
	move.l	screenptr2,screenptr1
	move.l	d0,screenptr2

	V_SETSCREEN screenptr1,screenptr1,#-1,#-1
	X_VSYNC
	clr.w	vblcount

	jsr	DoSources

	move.l	screenptr1,a0
	bsr	Draw_Bum
	
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

	V_SETMODE	oldmode
	V_SETSCREEN oldlog,oldphys,#-1,#-1

	clr.w	-(sp)
	trap	#1

Wait
	X_VSYNC
	bra	WaitBack

	endc
		
;-----------------------------------------------------------------------
; Call each VBL
; Pass screen address in a0
;-----------------------------------------------------------------------

Draw_Bum	
; a0 = screen

	pushall
	push.l	a0

	IFD		INCIT
	cache		reset
	ENDC

		
	jsr	DoSources

; Get palette address and send it to DSP (if in LOOKUP mode)

	tst.l	COLOURLOOKUP
	beq	.nolookup
	move.l	megacol_ptr,a0
	lea		20(a0),a0
;	lea	tablefile+20,a0
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

	moveq		#0,d0
	move.w	numsources,d0
	dsptx
	dsp_write.l	d0		; send number of plots

	lea	sourcedata,a0
	bra.s	.endsourcelp
.sourcelp
	dsptx				; wait till DSP ready
	dsp_write.w	(a0)+		; x
	dsptx				; wait till DSP ready
	dsp_write.w	(a0)+		; y
	dsptx				; wait till DSP ready
	dsp_write.l	(a0)+		; bum_height
.endsourcelp
	dbf		d0,.sourcelp

	dsprx				; ready to send ?

	move.w	#bum_width,d7
	move.w	d7,d6
	add.w		d6,d6
	move.w	d6,d5
	add.w		d5,d5
	add.w		d6,d5
	neg.w		d7
	add.w		#320,d7
	add.w		d7,d7
;	lsl.w		#2,d7			; skip after each 4 lines

	pop.l		a0
	lea		$FFFFA206.w,a3

	move.w	#bum_height*2,d1
	bra		.endylp
.ylp
	dsprx
	move.w	#bum_width*2/16,d0
	bra		.endxlp
.xlp
	rept		16
	move.w	(a3),(a0)+
	endr
.endxlp
	dbf		d0,.xlp
	ifd		INCIT
	add.w		physwid,a0
	lea		-256(a0),a0
	else
	lea		320+64(a0),a0
	endc
.endylp
	dbf		d1,.ylp

	popall

	IFD		INCIT
	cache		reset
	ENDC
	rts
	
	ifnd	INCIT

tablefile	incbin	"megacol.apx"
megacol_ptr:	dc.l	tablefile

	elseif
megacol_ptr:	ds.l	1

	endc


tablecount	dc.w	0
tablemax	=	127
tabledir	dc.w	1

;-----------------------------------------------------------------------
; Send a palette (16 bit TC format) to the DSP
; a0 = palette address
;-----------------------------------------------------------------------

SendPalette:
	move.w	#256-1,d7
	moveq	#0,d0
.lp	move.w	(a0)+,d0
	dsptx
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
	muls	(SINE.l,d1.w*2),d0
	add.l	d0,d0
	swap	d0
	add.w	posxbase,d0
	move.w	d0,posx
	add.w	posxinc,d1
	and.w	#4095,d1
	move.w	d1,posxindex

	move.w	posyamp,d0
	move.w	posyindex,d1
	muls	(SINE.l,d1.w*2),d0
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
	move.w	(SINE.l,d0.w*2),d0
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

posx			dc.w	32
posxamp		dc.w	40
posxindex		dc.w	1024
posxbase		dc.w	32
posxinc		dc.w	35

posy			dc.w	20
posyamp		dc.w	30
posyindex		dc.w	0
posybase		dc.w	20
posyinc		dc.w	23

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
	dc.w	0,-1,0,i,a,b
	dc.w	1,0,1024,i,a,b
	dc.w	0,1,2048,i,a,b
	dc.w	-1,0,3072,i,a,b

; BigSwirl (n=8)
	rept	0
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
	dc.w	0,0,0,200,127,128
	dc.w	1,0,2048,200,127,128

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

	ifnd	INCIT

	include	"dsplib.s"
	
	endc
;-----------------------------------------------------------------------
; Include DSP program
;-----------------------------------------------------------------------

		even
DSP_Bum:	incbin	waves\waves.dsp
DSP_BumE:	even
DSP_BumL:	=		(DSP_BumE-DSP_Bum)/3

;-----------------------------------------------------------------------
; VBL Counter
;-----------------------------------------------------------------------

	ifnd	INCIT

vbl
	addq.w	#1,vblcount
	move.l	oldvbl,-(sp)
	rts

	endc
	
;-----------------------------------------------------------------------
; Variables
;-----------------------------------------------------------------------

DAMPEN		dc.l	$3a0000
REACT			dc.l	$200000
MAX			dc.l	255*32768
INTERPOLATE		dc.l	1
BITS			dc.l	1
CLEARVELOCITY	dc.l	1
COLOURLOOKUP	dc.l	1

	ifnd	INCIT

SINE:		incbin	"l:\inc\hirescos.tab"

	endc
	
;-----------------------------------------------------------------------
; BSS section
;-----------------------------------------------------------------------

	section	bss

	ifnd	INCIT

oldlog		ds.l	1
oldphys		ds.l	1
oldmode		ds.l	1
oldvbl		ds.l	1

	endc

vblcount	ds.w	1
permcount	ds.w	1

	ifnd	INCIT

screenptr1	ds.l	1
screenptr2	ds.l	1

screen1
	ds.w	320*240+4
screen2
	ds.w	320*240+4

	endc
	
	text