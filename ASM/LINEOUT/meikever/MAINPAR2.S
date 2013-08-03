;                       /+----------------------------+\         
;                      / |      ST demo shell v1.1    | \
;                      \ | 12-08-2007 by earx/lineout | /
;                       \+----------------------------+/  

;- asm options, paths -----------------------------------------------------

	COMMENT	HEAD=%001
	;OPT	P=68000
testmode:=	0			; debug mode
	ifeq	testmode
	OPT	D-
	endc

;- library includes -------------------------------------------------------

	bra	START
	include	stmath.s
	include	sprite.s
	include	mat.s
	include	common.s
	include lib_3d.s
	text

;- global equates ---------------------------------------------------------

DEMO_SYSTEM:=	1			; leave this

EMPTY:=		0			; without any effects?
triggermode:=	1			; 0=manual effect-trigger, 1=event-table trigger
objectmode:=	1			; Must always be 1!

* computertype equates
st:	=	0
falcon:	=	1

scrxbytes:=	160
scrlines:=	200
maxscrsize:=	scrxbytes*scrlines
* monitormode-equ's
autodetect:=	0
rgb50:	=	1			* RGB/TV, 50Hz
vga60:	=	2			* VGA, 60Hz, noniterlaced
vga100:	=	3			* VGA, 100Hz, interlaced
* monitormode selector ( =autodetect ) or force mode ( >0 )
monitorequ:=	autodetect

		RSRESET
Fx.MAINLOOP:	RS.L	1
Fx.INIT:	RS.L	1
Fx.INIT_RT:	RS.L	1
Fx.DEINIT_RT:	RS.L	1
Fx.SIZE:	RS.B	0

;- initialisation ---------------------------------------------------------

START:	move.l	4(sp),a5			* mshrink
	move.l	$0c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	addi.l	#$1000,d0
	move.l	a5,d1
	add.l	d0,d1
	andi.b	#%11111110,d1			* even address
	move.l	d1,sp
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move.w	d0,-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	lea	12(sp),sp

; Initialize screenaddresses..
	move.l	#screen_buffer,d0
	lea	scr,a0
	addi.l	#$000000ff,d0
	clr.b	d0
	move.l	d0,screen_buffers_adr
	move.l	d0,(a0)+
	addi.l	#maxscrsize,d0
	move.l	d0,(a0)+
	addi.l	#maxscrsize,d0
	move.l	d0,(a0)+

* Set supervisormode and save old stackpointer..
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq	#6,sp
	move.l	#ustk,sp			* Install own stack..

	IFEQ	testmode

* Save old screenaddress..
	move.w	#2,-(sp)
	trap	#14
	addq	#2,sp
	move.l	d0,oldscr

	ifne	1

; Check out if it's an ST or better (STe, Falcon, TT).
	move.l	$05A0.w,d0
	beq	.st
	movea.l	d0,a0
.fndvdo:move.l	(a0),d0
	beq	.st			; no _MCH cookie? -> it's an ST.
	cmpi.l	#"_MCH",d0
	addq	#8,a0
	bne.s	.fndvdo
	tst.w	-4(a0)
	beq	.st
	st	enhanced
	cmpi.w	#3,-4(a0)
	bne.s	.no_falcon

; it's a falcon allright..
	move.l	$05A0.w,a0
.fndcpu:move.l	(a0),d0
	beq.s	.its_a_030			; no _CPU cookie? -> assume 030.
	cmpi.l	#"_CPU",d0
	addq	#8,a0
	bne.s	.fndvdo
	cmpi.w	#40,-2(a0)
	blt.s	.its_a_030

; disable 040/060 caches!
	st	ct60
	clr.w	-(sp)
	move.w	#5,-(sp)
	move.w	#160,-(sp)
	trap	#14
	addq	#6,sp

.its_a_030:
	movec	cacr,d0
	move.l	d0,old_cacr
; disable instruction cache
	bclr	#4,d0
	bclr	#0,d0
; disable data cache
	bclr	#12,d0
	bclr	#8,d0
	movec	d0,cacr

	else

; Check out if it's an ST or better (STe, Falcon, TT).
	move.l	$05A0.w,d0
	beq.s	.st
	movea.l	d0,a0
.fndvdo:cmpi.l	#"_VDO",(a0)
	addq	#8,a0
	bne.s	.fndvdo
	tst.w	4(a0)
	beq.s	.st
	st	enhanced
	cmpi.w	#3,4(a0)
	bne.s	.no_falcon

	endc

* Set monitormode..
	IFNE	monitorequ-autodetect
	move.w	#monitorequ,monitormode
	ELSE
	move.w	$ffff8006.w,d0
	lsr.w	#8,d0
	lsr.w	#6,d0
	beq	N_EXIT				* Arg! mono monitor!
	btst	#0,d0
	beq.s	.vga
	move.w	#rgb50,monitormode
	bra.s	.endmonitorcheck
.vga:	move.w	#vga60,monitormode
.endmonitorcheck:
	ENDC
* Save resolution..
	bsr	SAVE_FV
* Computer is a Falcon.
	move.w	#falcon,computer
	bra.s	.falc

.no_falcon:

* Computer is an ST.
.st:	move.w	#st,computer
	move.b	$FFFF820A.w,oldstsync
	move.b	$FFFF8260.w,oldstres
	ori.b	#2,$FFFF820A.w			; force 50 Hz.
;	andi.b	#-3,$FFFF820A.w			; force 60 Hz.

.falc:	bsr	SAVE_SYSTEMVARS

	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,savepal_tbl

* Install own vbl-routine..
	move	#$2700,sr
	move.l	#NEWVBL,$0070.w
	move.l	#NEW118,$0118.w
	bclr	#3,$fffffa17.w			* Set hardware end of interrupt for easier & faster interrupts.
	move	#$2300,sr

; set st low resolution..
	lea	$FFFF8240.w,a0
	moveq	#0,d0
	REPT	8
	move.l	d0,(a0)+
	ENDR
	bsr	set_stlow

	ENDC					* IFEQ testmode

	bsr	init_sincos_table

	lea	event_tbl,a0
	bsr	INIT_DEMOPARTS
	move.w	d0,objectcount

	lea	event_tbl,a0
	lea	subeffect_tbl,a1
	move.w	objectcount,d0
	bsr	CHECK_DEMOEVENTS

	clr.l	frmcnt
	clr.l	lastfrmcnt

	lea	music,a6
	move.w	#60,d7				; for 1, dayafter
	;move.w	#50,d7				; for 1evoke
	moveq	#1,d0
	bsr	start

	IFNE	triggermode

	move.l	$04BA.w,starttime

mainloopcycle:
	cmpi.b	#$39,$fffffc02.w
	beq	OUT
	move.l	actpartadr,d0
	beq.s	.do
	movea.l	d0,a0
	move.l	(a0),a1
	jsr	(a1)
	addq.l	#1,frmcnt
.do:	lea	event_tbl,a0
	bsr	DO_DEMOEVENTS
	bra.s	mainloopcycle

	ELSE

triggerloopcycle:
	moveq	#0,d0
	move.b	$fffffc02.w,d0
	cmp.w	.oldkey(pc),d0
	seq.b	d1
	move.w	d0,.oldkey
	cmpi.b	#$39,d0
	beq	OUT
	cmpi.w	#.subeffects-.key2object_tbl,d0
	bhs.s	.do_subeffect
	lea	.key2object_tbl,a0
	move.b	(a0,d0.l),d0
	beq.s	.do_old
	cmp.w	objectcount,d0
	bhi.s	.do_old
	movea.l	event_tbl,a0
	lsl.l	#2,d0
	movea.l	(a0,d0.l),a0
	cmpa.l	actpartadr,a0
	beq.s	.do_old
	move.w	d0,.actpart			; kick in new object.
	move.l	a0,actpartadr			;

	move.l	frmcnt,lastfrmcnt
	movea.l	Fx.INIT_RT(a0),a0		; rt_init
	jsr	(a0)				; do rt_init.
.do_old:move.l	actpartadr,d0
	beq.s	triggerloopcycle

; start timer when the first effect is called (for fair benchmarking!)
	tst.w	.first_fx_exec(pc)
	bne.s	.first_done
	st	.first_fx_exec
	move.l	$04BA.w,starttime
.first_done:

	move.l	d0,a0
	movea.l	(a0),a0
	jsr	(a0)				; jump to fx-mainloop.
	addq.l	#1,frmcnt
	bra.w	triggerloopcycle
.do_subeffect:
	lea	.key2object_tbl,a0
	move.b	(a0,d0.l),d0
	beq.s	.do_old
	tst.b	d1
	bne.s	.do_old
	move.l	actpartadr,d2
	beq	triggerloopcycle
	movea.l	d2,a0
	move.w	.actpart(pc),d1
	lea	subeffect_tbl,a1
	cmp.b	(a1,d1.w),d0
	bhs.s	.do_old
	lsl.l	#2,d0
	movea.l	Fx.INIT_RT(a0,d0.l),a0
	jsr	(a0)
	bra.s	.do_old

.actpart:
	DC.W	0
.oldkey:
	DC.W	0
.first_fx_exec
	dc.w	0

.key2object_tbl:
	DC.B	0,0
	DC.B	$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c
	DC.B	0,0,0
	DC.B	$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1a,$1b
	DC.B	0,0
	DC.B	$1e,$1f,$20,$21,$22,$23,$24,$25,$26,$27,$28
	DC.B	0,0,0
	DC.B	$2c,$2d,$2e,$2f,$30,$31,$32,$33,$34,$35
	DS.B	19
.subeffects:
	DC.B	8				* numpad "-": $4a
	DS.B	3
	DC.B	12				* numpad "+": $4e
	DS.B	$14
	DC.B	1				* numpad "(": $63
	DC.B	2				* numpad ")": $64
	DC.B	3				* numpad "/": $65
	DC.B	4				* numpad "*": $66
	DC.B	5				* numpad "7": $67
	DC.B	6				* numpad "8": $68
	DC.B	7				* numpad "9": $69
	DC.B	9				* numpad "4": $6a
	DC.B	10				* numpad "5": $6b
	DC.B	11				* numpad "6": $6c
	DC.B	13				* numpad "1": $6d
	DC.B	14				* numpad "2": $6e
	DC.B	15				* numpad "3": $6f
	DC.B	16				* numpad "0": $70
	DC.B	17				* numpad ".": $71
	DC.B	18				* numpad "ENTER": $72
	DS.B	$8e
	EVEN

	ENDC

;- event list code --------------------------------------------------------

event_tbl:
	DC.L	eventpart_tbl
	DC.W	(.end-.start)/6
	DC.W	0
.start:

; todo: fade in
	DC.L	0
	DC.W	LEDPLS_CODE
	DC.L	0
	DC.W	LEDPLS_CODE+4			; fade in
	DC.L	170
	DC.W	LEDPLS_CODE+13			; start bee upward spiral
	DC.L	170
	DC.W	LEDPLS_CODE+10			; start bee movement

	DC.L	200
	DC.W	LEDPLS_CODE+8			; inc speed
	DC.L	200
	DC.W	LEDPLS_CODE+7			; switch direction

	DC.L	230
	DC.W	LEDPLS_CODE+9			; dec speed
	DC.L	230
	DC.W	LEDPLS_CODE+7			; switch direction

	DC.L	280
	DC.W	LEDPLS_CODE+8			; inc speed
	DC.L	280
	DC.W	LEDPLS_CODE+8			; inc speed

	DC.L	350
	DC.W	LEDPLS_CODE+9			; dec speed
	DC.L	350
	DC.W	LEDPLS_CODE+9			; dec speed
	DC.L	350
	DC.W	LEDPLS_CODE+7			; switch direction

	DC.L	400
	DC.W	LEDPLS_CODE+9			; dec speed
	DC.L	400
	DC.W	LEDPLS_CODE+9			; dec speed
	DC.L	400
	DC.W	LEDPLS_CODE+7			; switch direction

	DC.L	470
	DC.W	LEDPLS_CODE+9			; dec speed
	DC.L	470
	DC.W	LEDPLS_CODE+9			; dec speed
	DC.L	470
	DC.W	LEDPLS_CODE+7			; switch direction

;	DC.L	520
;	DC.W	LEDPLS_CODE+9			; dec speed
;	DC.L	520
;	DC.W	LEDPLS_CODE+9			; dec speed
;	DC.L	520
;	DC.W	LEDPLS_CODE+7			; switch direction

	DC.L	540
	DC.W	LEDPLS_CODE+11			; spiral down
	DC.L	560
	DC.W	LEDPLS_CODE+10			; stop bee movement

	DC.L	670
	DC.W	LEDPLS_CODE+6			; overlay on
	DC.L	1100
	DC.W	LEDPLS_CODE+12			; overlay off
	DC.L	1180
	DC.W	LEDPLS_CODE+5			; fade out
; todo: fade to other effect colours

; todo: roto here.. (see notes in hybroto2.s)
	DC.L	1440
	DC.W	ROT_CODE			; start roto
	DC.L	1440
	DC.W	ROT_CODE+$11			; fade in the foreground
	DC.L	1900
	DC.W	ROT_CODE+$5			; 2x2
; start of 'tip-toe-tip-toe' part
	DC.L	2700
	DC.W	ROT_CODE+$9			; enable roto

; bring speed boosts in earlier, since music is shortened
; tip-toe 2 (extra chord)
	DC.L	2700+200
	DC.W	ROT_CODE+$12			; fade in the background
	DC.L	2700+300
	DC.W	ROT_CODE+$A			; rotation speed boost
	DC.L	2700+400
	DC.W	ROT_CODE+$A			; rotation speed boost
	DC.L	2700+500
	DC.W	ROT_CODE+$B			; rotation speed boost

; lead instrument start
	DC.L	3300
	DC.W	ROT_CODE+$C			; block circles
	DC.L	3400
	DC.W	ROT_CODE+$5			; 8x8
	DC.L	3700
	DC.W	ROT_CODE+$7			; fade out

; train (NS = dutch railways) thing..
	DC.L	4000				; transition
	DC.W	GUPTA_CODE+6
	DC.L	4000				; start effect
	DC.W	GUPTA_CODE
	DC.L	4000+200			; fade in vector colours
	DC.W	GUPTA_CODE+7
	DC.L	4000+600			; kick in anti-alias
	DC.W	GUPTA_CODE+4
	DC.L	4000+850			; fix magnifyer position
	DC.W	GUPTA_CODE+5
	DC.L	5400-140			; fade to purple..
	DC.W	GUPTA_CODE+8

; dots.
	DC.L	84*64+0
;	DC.L	5400+0
	DC.W	DOTS_CODE
	DC.L	5400+600
	DC.W	DOTS_CODE+5
	DC.L	5400+800
	DC.W	DOTS_CODE+6
	DC.L	5400+1000
	DC.W	DOTS_CODE+4			; spin 360: todo: musicsync
	DC.L	5400+1050
	DC.W	DOTS_CODE+7
	DC.L	5400+1300
	DC.W	DOTS_CODE+9			; fuji
	DC.L	5400+1565
	DC.W	DOTS_CODE+8			; square

; todo: change the shape (half ball + cube inside)..
	DC.L	7000
	DC.W	GLENZ_CODE
;	DC.L	7000+300
;	DC.W	GLENZ_CODE+$7
;	DC.L	7000+600
;	DC.W	GLENZ_CODE+$8
	DC.L	7000
	DC.W	GLENZ_CODE+$6			; move both closer
	DC.L	7000+250
	DC.W	GLENZ_CODE+$7			; move big one closer
	DC.L	7000+500
	DC.W	GLENZ_CODE+$8			; go crazy..
; todo: transition to wibbly (spaz) cube..
	DC.L	8000
	DC.W	WIBBLE_CODE
	DC.L	8000+200
	DC.W	WIBBLE_CODE+$4			; start bouncing
	DC.L	8000+800
	DC.W	WIBBLE_CODE+$5			; start morphing to a ribbon
	DC.L	8000+970
	DC.W	WIBBLE_CODE+$6			; fix rotation and wave 
	DC.L	8000+1220
	DC.W	WIBBLE_CODE+$7			; zoom out
	DC.L	8000+1450
	DC.W	WIBBLE_CODE+$8			; fade..
; todo: some great transition (zoom?) from wibbler (spaz) to ribbons
; todo: this ribbons part is shown too long. needs more variation!
	DC.L	9000+500
	DC.W	RIBBONS_CODE
	DC.L	9000+500
	DC.W	RIBBONS_CODE+5			; start fading in..
	DC.L	9000+1750
	DC.W	RIBBONS_CODE+4			; start to shorten ribbons..
	DC.L	9000+2000
	DC.W	RIBBONS_CODE+6			; start fading out..

; time to end this part..
	;DC.L	(1<<31)-1
	DC.L	11600
	DC.W	0

.end:

GLENZ_CODE:	=	1<<8
ROT_CODE:	=	2<<8
GUPTA_CODE:	=	3<<8
DOTS_CODE:	=	4<<8
LEDPLS_CODE:	=	5<<8
RIBBONS_CODE:	=	6<<8
WIBBLE_CODE:	=	7<<8
TWIST_CODE:	=	8<<8
;DUMMY_CODE:	=	9<<8
DUMMY_CODE:	=	8<<8

DEBOG:		=	0

eventpart_tbl:
	dc.l	OUT
	ifeq	EMPTY
	dc.l	glenz_table
	dc.l	rot_table
	dc.l	gupta_table		;blockyrot_table
	dc.l	dots_table
	dc.l	ledpls_table
	dc.l	ribbons_table
	dc.l	wibble_table
;	dc.l	twist_table			; new

	dc.l	dummy_table
	endc
	dc.l	0

;- exit code --------------------------------------------------------------

OUT:
	IFEQ	testmode

	;bsr	print_stats

	movem.l	savepal_tbl,d0-d7
	movem.l	d0-d7,$ffff8240.w

	cmpi.w	#falcon,computer
	beq.s	.falc

	move.b	oldstsync,$FFFF820A.w
	move.b	oldstres,$ffff8260.w
	bra.s	EXIT
	
.falc:	move.l	old_cacr,d0
	movec	d0,cacr

	lea	save_fv,a0
	bsr	CHANGE_FVFAST

EXIT:	bsr	stop

	bsr	RESTORE_SYSTEMVARS

	move.l	oldscr,d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w

; enable 040/060 caches!
	tst.w	ct60
	beq.s	.ct60_stuff_done
	move.w	#1,-(sp)
	move.w	#5,-(sp)
	move.w	#160,-(sp)
	trap	#14
	addq	#6,sp
.ct60_stuff_done:

	ENDC

N_EXIT:	clr.w	-(sp)
	trap	#1

;- demo system subroutines ------------------------------------------------

	include	gfa_sndh.s
	even
	text

; print frames painted, time taken (200 Hz ticks) ($XXXXXXXX,$YYYYYYYY)
print_stats:
	bsr	getTime
	move.l	d0,time

	lea	text_buf(pc),a4

	move.l	frmcnt,d0
	move.l	#200*16,d2
	bsr	lmulu
	move.l	d2,ticks_times3200
	move.l	d2,d7
	bsr	mkhex8

	move.l	time(pc),d7
	bsr	mkhex8

	move.b	#"=",(a4)+

	move.l	ticks_times3200,d7
	divu.w	time+2(pc),d7
	andi.l	#$0000FFFF,d7
	bsr	mkhex8

	move.b	#$A,(a4)+
	move.b	#$D,(a4)+
	clr.b	(a4)

	pea	text_buf(pc)
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp
	rts

time:	ds.l	1
ticks_times3200:
	ds.l	1
text_buf:
	ds.b	64

; input:
; d7.l=number
; a4: dst buffer..
mkhex8:	moveq	#8-1,d5
.hex1:	rol.l	#4,d7
	move.w	d7,d6
	and.w	#$000F,d6
	add.b	#'0',d6
	cmp.b	#'9',d6
	bls.s	.br1
	addq.b	#'A'-'9'-1,d6
.br1:	move.b	d6,(a4)+
	dbf	d5,.hex1
	rts	

getTime:move.l	$04BA.w,d0	
	sub.l	starttime,d0
	rts

set_stlow:
	cmpi.w	#falcon,computer
	beq.s	.falc
	move.b	#0,$ffff8260.w
	rts

.falc:	move.w	monitormode,d0
	cmpi.w	#vga60,d0
	beq.s	.vga
	cmpi.w	#vga100,d0
	beq.s	.vga
	cmpi.w	#rgb50,d0
	beq.s	.rgb50
* Unknown monitormode..
	rts
.vga:	MOVE.L	#$170012,$FFFF8282.W
	MOVE.L	#$1020E,$FFFF8286.W
	MOVE.L	#$D0012,$FFFF828A.W
	MOVE.L	#$41903B9,$FFFF82A2.W
	MOVE.L	#$61008D,$FFFF82A6.W
	MOVE.L	#$3AD0415,$FFFF82AA.W
	MOVE.W	#$200,$FFFF820A.W
	MOVE.W	#$186,$FFFF82C0.W
	CLR.W	$FFFF8266.W
	MOVE.B	#$0,$FFFF8260.W
	MOVE.W	#$5,$FFFF82C2.W
	MOVE.W	#$50,$FFFF8210.W

	;lea	stlowvga_fv,a0
	;bsr	CHANGE_FVFAST
	rts
.rgb50:	MOVE.L   #$003E0032,$FFFF8282.W
        MOVE.L   #$0009023F,$FFFF8286.W
        MOVE.L   #$001C0035,$FFFF828A.W
        MOVE.L   #$02710265,$FFFF82A2.W
        MOVE.L   #$001F006F,$FFFF82A6.W
        MOVE.L   #$01FF026B,$FFFF82AA.W
        MOVE.W   #$0200,$FFFF820A.W
        MOVE.W   #$0081,$FFFF82C0.W
        CLR.W    $FFFF8266.W
        MOVE.B   #$00,$FFFF8260.W
        MOVE.W   #$0000,$FFFF82C2.W
        MOVE.W   #$0050,$FFFF8210.W
	rts

SAVE_FV:
	lea	save_fv,a1
	move.l	#'FVD2',(a1)+			* 4 bytes header
	move.b	$ffff8006.w,(a1)+		* monitor type
	move.b	$ffff820a.w,(a1)+		* sync
	move.l	$ffff820e.w,(a1)+		* offset & vwrap
	move.w	$ffff8266.w,(a1)+		* spshift
	move.l	#$ff8282,a0			* horizontal control registers
.loop1:	move	(a0)+,(a1)+
	cmp.l	#$ff8292,a0
	bne.s	.loop1
	move.l	#$ff82a2,a0			* vertical control registers
.loop2:	move	(a0)+,(a1)+
	cmp.l	#$ff82ae,a0
	bne.s	.loop2
	move	$ffff82c2.w,(a1)+		* video control
	move	$ffff82c0.w,(a1)+		* video clock
	move.b	$ffff8260.w,(a1)+		* shifter resolution
	move.b	$ffff820a.w,(a1)+		* video sync mode
	rts

RESTORE_FV:
	lea	save_fv,a0
	bra	CHANGE_FVFAST

* Changes screenresolution the fast way.. Do this synced to the VBL for
* the smooth res-change.
* INPUT: a0: address of fv2-buffer
CHANGE_FVFAST:
	addq	#6,a0				* Skip header + monitortype
	lea	(a0),a6

	move.l	(a0)+,$ffff820e.w		* offset & vwrap
	move.w	(a0)+,$ffff8266.w		* spshift
	lea	$ffff8282.w,a1			* horizontal control registers
.loop1	move.w	(a0)+,(a1)+
	cmpa.w	#$8292,a1
	bne.s	.loop1
	lea	$ffff82a2.w,a1			* vertical control registers
.loop2	move.w	(a0)+,(a1)+
	cmpa.w	#$82ae,a1
	bne.s	.loop2
	move.w	(a0)+,$ffff82c2.w		* video control
;	tst.w	centurbofound
;	bne.s	.extclock
	move.w	(a0)+,$ffff82c0.w		* video clock
	cmpi.w	#$50,6(a6)			* ST resolution?
	blt.s	.stres
	addq	#1,a0				* st res
	bra.s	.fres
.stres:	move.b	(a0)+,$ffff8260.w		* st res
.fres:	move.b	(a0)+,$ffff820a.w		* video sync mode
	rts
* Special shit for external clock. %-( Dumb CenTurbo shit!
.extclock:
	move.w	(a0)+,d0
	btst	#2,d0				* Test which clock is attached.
	seq.b	d1
	move.w	d0,$ffff82c0.w
	cmpi.w	#$50,6(a6)			* ST resolution?
	blt.s	.xstres
	addq	#1,a0				* st res
	bra.s	.xfres
.xstres:
	move.b	(a0)+,$ffff8260.w		* st res
.xfres:	move.b	(a0)+,d0
	tst.b	d1
	beq.s	.25mhz
	bset	#0,d0				* Set external sync.
.25mhz:	move.b	d0,$ffff820a.w			* video sync mode
	rts

SAVE_SYSTEMVARS:
* Save loads of interrupt crap.
	move    #$2700,SR
	lea     sys_var,a0
	move.l  $0070.w,(a0)+
	move.l  $0068.w,(a0)+
	move.l  $0110.w,(a0)+
	move.l	$0114.w,(a0)+
	move.l	$0118.w,(a0)+
	move.l  $0120.w,(a0)+
	move.l	$0134.w,(a0)+
	lea     $fffffa00.w,a1
	move.b	$01(a1),(a0)+
	move.b	$03(a1),(a0)+
	move.b	$05(a1),(a0)+
	move.b  $07(a1),(A0)+
	move.b  $09(a1),(A0)+
	move.b	$0b(a1),(a0)+
	move.b	$0d(a1),(a0)+
	move.b	$0f(a1),(a0)+
	move.b  $11(a1),(A0)+
	move.b  $13(a1),(A0)+
	move.b  $15(a1),(A0)+
	move.b  $17(a1),(A0)+
	move.b	$19(a1),(a0)+
	move.b  $1B(a1),(A0)+
	move.b	$1d(a1),(a0)+
	move.b	$1f(a1),(a0)+
	move.b  $21(a1),(A0)+
	move.b  $23(a1),(A0)+
	move.b  $25(a1),(A0)+
	move.b  $0484.w,(A0)+
	move	#$2300,sr
	rts

RESTORE_SYSTEMVARS:
	move    #$2700,sr
	clr.b   $fffffa1b.w     ;Timer B stoppen
        lea     sys_var,a0
	move.l  (a0)+,$0070.w
	move.l  (a0)+,$0068.w
	move.l  (a0)+,$0110.w
	move.l	(a0)+,$0114.w
	move.l	(a0)+,$0118.w
	move.l  (a0)+,$0120.w
	move.l	(a0)+,$0134.w
	lea     $fffffa00.w,A1
	move.b	(a0)+,$01(a1)
	move.b	(a0)+,$03(a1)
	move.b	(a0)+,$05(a1)
	move.b  (A0)+,$07(A1)
	move.b  (A0)+,$09(A1)
	move.b	(a0)+,$0b(a1)
	move.b	(a0)+,$0d(a1)
	move.b	(a0)+,$0f(a1)
	move.b  (a0)+,$11(A1)
	move.b  (a0)+,$13(A1)
	move.b  (a0)+,$15(A1)
	move.b  (a0)+,$17(A1)
	move.l	a0,a2
	clr.b	$19(a1)
	clr.b	$1b(a1)
	clr.b	$1d(a1)
	addq	#3,a0
	move.b	(a0)+,d0 $1f(a1)
	move.b  (A0)+,d0 $21(A1)
	move.b  (A0)+,d0 $23(A1)
	move.b  (A0)+,d0 $25(A1)
	move.b	(a2)+,$19(a1)
	move.b	(a2)+,$1B(A1)
	move.b	(a2)+,$1d(a1)
	move.b  (a0)+,$0484.w
	move    #$2300,SR
	rts

; input:
; a0: dst screen
; a1: src screen
copy_stscreen:
	move.w	#200-1,d0
.loop:	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,48(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,48*2(a0)
	movem.l	(a1)+,d1-d4
	movem.l	d1-d4,48*3(a0)
	lea	160(a0),a0
	dbf	d0,.loop
	rts

CLEAR_STSCREEN:
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	movea.l	d1,a1
	movea.l	d1,a2
	movea.l	d1,a3
	movea.l	d1,a4
	movea.l	d1,a5
	movea.l	d1,a6

	move.w	#153-1,d0
	lea	32000(a0),a0
.cl2	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	dbra	d0,.cl2
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d5,-(a0)
	rts

* INPUT: a0: address of eventtable
INIT_DEMOPARTS:
	moveq	#0,d0				* d0.w: objectcounter
	movea.l	(a0),a0				* a0: address of part-table
	addq	#4,a0				* a0: address of first object-pointer

.loop:	move.l	(a0)+,d1
	beq.s	.rts
	movea.l	d1,a1
	move.l	4(a1),a1
	move.w	d0,-(sp)
	move.l	a0,-(sp)
	jsr	(a1)				* Jump to init-subroutine.
	movea.l	(sp)+,a0
	move.w	(sp)+,d0
	addq.w	#1,d0
	bra.s	.loop

.rts:	rts

* INPUT: a0: address of eventtable
DO_DEMOEVENTS:
	move.l	(a0)+,a1
	lea	2(a0),a6
	move.w	(a0)+,d0
	move.w	(a0)+,d1
	cmp.w	d0,d1
	beq	OUT
	mulu.w	#6,d1
	adda.l	d1,a0
	move.l	(a0)+,d0

;	move.l	$4BA.w,d1
;	sub.l	starttime,d1
	move.l	ticks_done,d1		; ticks from SNDH player

	cmp.l	d0,d1
	blt.s	.rts
	move.w	(a0)+,d1
	beq	OUT
	move.w	d1,d0
	lsr.w	#8,d0
	andi.w	#$00ff,d1
	bne.s	.intern

; new effect is scheduled.. deinit old one, and rt_init new one..
	movea.l	actpartadr,a0
	cmpa.l	#0,a0
	beq.s	.skip_deinit				; do not deinit, if no effect was initialised!
	movea.l	Fx.DEINIT_RT(a0),a0			; deinit
	movem.l	d0/a1/a6,-(sp)
	jsr	(a0)
	movem.l	(sp)+,d0/a1/a6
.skip_deinit:

	move.l	frmcnt,lastfrmcnt
	lsl.w	#2,d0
	move.l	(a1,d0.w),actpartadr			; store address of new fx..

	movea.l	actpartadr,a0
	movea.l	Fx.INIT_RT(a0),a0			; rt_init
	move.l	a6,-(sp)
	jsr	(a0)
	movea.l	(sp)+,a6

	bra.s	.out

.intern	lsl.w	#2,d0
	move.l	(a1,d0.w),a0
	lsl.w	#2,d1
	move.l	(a0,d1.w),a0
	move.l	a6,-(sp)
	jsr	(a0)
	movea.l	(sp)+,a6
.out	addq.w	#1,(a6)
.rts	rts

actpartadr:
	DS.L	1

* INPUT: a0: address of eventtable
*        a1: address of subeffectcountertable
*        d0.w: objectcount
CHECK_DEMOEVENTS:
	movea.l	a1,a4
	clr.b	(a1)+
	move.l	(a0),a2
	addq	#4,a2
.countloop:
	move.l	(a2)+,d2
	beq.s	.endcounting
	movea.l	d2,a3
	lea	3*4(a3),a3
	moveq	#0,d1
.incountloop:
	addq.w	#1,d1
	tst.l	(a3)+
	bne.s	.incountloop
	move.b	d1,(a1)+
	bra.s	.countloop
.endcounting:

	move.l	(a0)+,a1
	move.l	(a1),a1				* a1: address of outaddress
	move.w	(a0),d7				* d7.w: number of events
	addq	#4,a0
	subq.w	#1,d7
	bmi.s	.rts
.loop:	addq	#4,a0
	move.w	(a0)+,d1
	move.b	d1,d2
	lsr.w	#8,d1
	cmp.w	d0,d1
	ble.s	.ok
	jmp	(a1)
.ok:	subq.b	#1,d2
	cmp.b	(a4,d1.w),d2
	ble.s	.ok2
	jmp	(a1)
.ok2:	dbf	d7,.loop
.rts	rts

;- interrupts -------------------------------------------------------------

NEWVBL:	addq.l	#1,$466.w
	movem.l	d0-a6,-(sp)
	movea.l	music_irq(pc),a0
	jsr	(a0)
	movea.l	palirq(pc),a0
	jsr	(a0)
	movem.l	(sp)+,d0-a6
	rte

music_irq:
	DC.L	dummy
palirq:	DC.L	notimerb

dummy:	rts
notimerb:
	move	#$2700,sr
	bclr	#0,$fffffa07.w
	bclr	#0,$fffffa13.w
	move	#$2300,sr
	rts

NEW118:
.keylop:tst.b	$fffffc02.w
	bclr    #6,$FFFFFA11.w			* isrb
	btst    #4,$FFFFFA01.w			* gpip
	beq.s   .keylop
	rte

;- data section -----------------------------------------------------------

	data

music:	;incbin	1.snd				; 60 Hz
	;incbin	1evoke.snd			; 50 Hz
	;incbin	dayafter.snd			; 60 Hz
	;incbin	2ndstage.snd			; 60 Hz
	;incbin	4thstag2.snd			; 60 Hz
	;incbin	4thstag3.snd			; 60 Hz
	;incbin	5thstage.snd			; 60 Hz
	;incbin	5thstag2.snd			; 60 Hz
	incbin	5thstag3.snd			; 50 Hz
	even

;- bss section ------------------------------------------------------------

	bss

	EVEN

; system save/restore buffers
	DS.L	256
ustk:	DS.L	1
oldsp:	DS.L	1
oldscr:	DS.L	1
oldvbl:	DS.L	1
old118:	DS.L	1
oldstsync:
	ds.w	1
oldstres:
	ds.w	1
savepal_tbl:
	DS.W	16
save_fv:DS.W	24
sys_var:DS.L	19
old_cacr:
	ds.l	1

; system stats
computer:
	DS.W	1
monitormode:
	DS.W	1
enhanced:
	DS.W	1
ct60:	ds.w	1

; object handling
objectcount:
	DS.W	1
subeffect_tbl:
	DS.B	128

; timer stuffs
starttime:
	DS.L	1
frmcnt:	DS.L	1
lastfrmcnt:
	DS.L	1

; screen buffers, pointers
scr:	DS.L	3
screen_buffers_adr:
	ds.l	1

sine_tbl:
	ds.l	SINTABLE_LEN

screen_buffer:
	ds.b	256
	ds.b	32000*2
	ds.b	2

;--------------------------------------------------------------------------

; included objects:
	text

	ifeq	EMPTY

; to be used in another prod..
;cogs_table:
;	include	cogs.s
;	text

glenz_table:
;	include	glenz.s
	include	boxglenz.s
	text

rot_table:
	include	hybroto2.s
	text

gupta_table:
	include	gupta8.s
	text

dots_table:
	include	dotsext2.s
	text

ledpls_table:
	include	ledpls.s
	text

ribbons_table:
	include ribbons2.s
	text

wibble_table:
	include wibble2.s
	text

;twist_table:
;	include twist.s
;	text

dummy_table:
	include	dummyobj.s
	text

	endc
