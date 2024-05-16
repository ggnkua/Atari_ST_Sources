;                      [=/\===/\===/\===/\===/\===/\=]
;                     /: ST FX testing skeleton v1.2 :\
;                     \: 12-08-2007 by earx/lineout  :/
;                      [=\/===\/===\/===\/===\/===\/=]

;- asm options ------------------------------------------------------------

	COMMENT	HEAD=%001
;	OPT	P=68000
	OPT	O-
	ifeq	testmode
	OPT	D-
	endc

;- libraries --------------------------------------------------------------

	bra	START
	include	stmath.s

;- global constants -------------------------------------------------------

objectmode:	=	0			* demo-os inclusion mode (dummy)

; computertype equates
st:		=	0
falcon:		=	1
DEV3CRAP:	=	0
; monitormode-equates for falcon
autodetect:	=	0
rgb50:		=	1			* RGB/TV, 50Hz
vga100:		=	2			* VGA, 100Hz, interlaced
vga60:		=	3			* VGA, 60Hz, noninterlaced
; screendimension-equates
scrxbytes:	=	320/2			* number of bytes per scanline
scrlines:	=	200			* number of scanlines
maxscrsize:	=	scrxbytes*scrlines	* max. size of screen

monitorequ:	=	autodetect		* current monitormode

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
	andi.b	#%11111110,d1			; even address
	move.l	d1,sp
	move.l	d0,-(sp)
 	move.l	a5,-(sp)
	move.w	d0,-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	lea	12(sp),sp
* Reserve RAM for screens.
	move.l	#maxscrsize*2+256,-(sp)		; size of screens.. 2 this time!
	move.w	#$48,-(sp)
	trap	#1
	addq	#8,sp
	move.l	d0,d0
	bgt.s	.ramok
* Not enough RAM free :(
	clr.w	-(sp)
	trap	#1
* Initialize screenaddresses..
.ramok:	lea	scr,a0
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

* Check if the demo-object table has all necessary entries..
	lea	end_tester_code,a0
	moveq	#3-1,d7
.chklp:	tst.l	(a0)+
	beq	N_EXIT				* On premature NULL > go out!
	dbra	d7,.chklp

	IFEQ	testmode
	bsr	SAVE_SYSTEMVARS
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
.fndvdo:cmpi.l	#"_MCH",(a0)
	addq	#8,a0
	bne.s	.fndvdo
	tst.w	-4(a0)
	beq	.st
	st	enhanced
	cmpi.w	#3,-4(a0)
	bne.s	.no_falcon

; it's a falcon allright..
	move.l	$05A0.w,a0
.fndcpu:cmpi.l	#"_CPU",(a0)
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
	ifeq	DEV3CRAP
	movec	cacr,d0
	endc
	move.l	d0,old_cacr
; disable instruction cache
	bclr	#4,d0
	bclr	#0,d0
; disable data cache
	bclr	#12,d0
	bclr	#8,d0
	ifeq	DEV3CRAP
	movec	d0,cacr
	endc
	else

* Falcon check..
	move.l	$05a0.w,a0
	cmpa.l	#0,a0
	beq	.st
.fndmch:
	cmpi.l	#"_MCH",(a0)
	beq.s	.found
	addq	#8,a0
	bra.s	.fndmch
.found:	cmpi.w	#3,4(a0)
	bne	.st

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
.vga:	move.w	#vga100,monitormode	;move.w	#vga60,monitormode
.endmonitorcheck:
	ENDC
* Install own vbl-routine..

* Computer is a Falcon.
.installvbl:
* Save resolution..
	bsr	SAVE_FV
	move.w	#falcon,computer
	bra.s	.falc

.no_falcon:
* Computer is an ST.
.st:	move.w	#st,computer
	move.b	$FFFF820A.w,oldstsync
	move.b	$FFFF8260.w,oldstres
	ori.b	#2,$FFFF820A.w

.falc:	move	#$2700,sr
	move.l	#NEWVBL,$70.w
	move.l	#NEWTIMERC,$114.w
	move.l	#NEW118,$118.w
	bclr	#5,$fffffa07.w			* Disable timer A!!
;	bclr	#5,$fffffa09.w			* Disable timer C!!
	bclr	#4,$fffffa09.w			* Disable timer D!!
	move.b	#%00000000,$fffffa07.w
	move.b	#%01100000,$fffffa15.w
	move.b	#%01100000,$fffffa09.w		; acia int on, TIC on
	move.b	#%01000000,$fffffa17.w
	bclr	#3,$fffffa17.w			* Set hardware end of interrupt for easier & faster interrupts.
	move	#$2300,sr
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,savepal_tbl

; set st low resolution..
	lea	$FFFF8240.w,a0
	clr.l	d0
	REPT	8
	move.l	d0,(a0)+
	ENDR
	bsr	set_stlow
	ENDC

	lea	end_tester_code+Fx.DEINIT_RT,a0
	moveq	#-1,d0
.countloop:
	addq.b	#1,d0
	tst.l	(a0)+
	bne.s	.countloop
	move.b	d0,subeffectsnum

	bsr	init_sincos_table

	movea.l	end_tester_code+4,a0
	jsr	(a0)				; initialize demo-fx.
	movea.l	end_tester_code+8,a0
	jsr	(a0)				; initialize demo-fx.

	move.l	$04BA.w,starttime
	clr.l	frmcnt
	clr.l	lastfrmcnt

singlefxloop:
	ifne	0

	cmpi.b	#$39,$fffffc02.w
	beq	OUT
	movea.l	end_tester_code,a0
	jsr	(a0)				; jump to demo-fx main.
	addq.l	#1,frmcnt
;	cmpi.l	#700,frmcnt
;	bne.s	singlefxloop
;	movea.l	end_tester_code+12,a0
;	jsr	(a0)
	bra.s	singlefxloop

	else	

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
.do_old:movea.l	end_tester_code,a0
	jsr	(a0)				; Jump to fx-mainloop.
	addq.l	#1,frmcnt
	bra.s	triggerloopcycle
.do_subeffect:
	move.b	.key2object_tbl(pc,d0.l),d0
	beq.s	.do_old
	tst.b	d1
	bne.s	.do_old
	lea	end_tester_code,a0
	cmp.b	subeffectsnum,d0
	bhs.s	.do_old
	moveq	#0,d2
	subq.b	#1,d0
	move.b	d0,d2
	lsl.l	#2,d2
	movea.l	Fx.SIZE(a0,d2.l),a0		; skip past the 'housekeeping' routs
	jsr	(a0)
	bra.s	.do_old

.oldkey:DC.W	0

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

	endc

OUT:	bsr	print_stats

	movea.l	end_tester_code+12,a0
	jsr	(a0)				; de-initialize demo-fx.

	ifeq	testmode
	bsr	RESTORE_SYSTEMVARS
	endc

; wait and still show screen?
;	ifd	WAIT_FOR_KEY
;	move.w	#1,-(sp)
;	trap	#1
;	addq	#2,sp
;	endc

	IFEQ	testmode

	movem.l	savepal_tbl,d0-d7
	movem.l	d0-d7,$ffff8240.w

	cmpi.w	#falcon,computer
	beq.s	.falc

	move.b	oldstres,$FFFF8260.w
	move.b	oldstsync,$FFFF820A.w
	bra.s	EXIT
	
.falc:	move.l	old_cacr,d0
	movec	d0,cacr
	lea	save_fv,a0
	bsr	CHANGE_FVFAST

EXIT:	move.l	oldscr,d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w

	;bsr	DISPLAY_FRMSPERSEC
	ENDC

; enable 040/060 caches!
	tst.w	ct60
	beq.s	.ct60_stuff_done
	move.w	#1,-(sp)
	move.w	#5,-(sp)
	move.w	#160,-(sp)
	trap	#14
	addq	#6,sp
.ct60_stuff_done:

N_EXIT:
	ifd	WAIT_FOR_KEY
	move.w	#1,-(sp)
	trap	#1
	addq	#2,sp
	endc

	clr.w	-(sp)
	trap	#1

;------- SUBROUTINE CODE --------

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

	move.b	#"/",(a4)+

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
	clr.b	$ffff8260.w
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

; 320x200
	MOVE.L	#$41903B9,$FFFF82A2.W
	MOVE.L	#$61008D,$FFFF82A6.W
	MOVE.L	#$3AD0415,$FFFF82AA.W

	MOVE.W	#$200,$FFFF820A.W
	MOVE.W	#$186,$FFFF82C0.W
	CLR.W	$FFFF8266.W
	MOVE.B	#$0,$FFFF8260.W
	MOVE.W	#$5,$FFFF82C2.W
	MOVE.W	#$50,$FFFF8210.W
;	lea	stlowvga_fv,a0
;	bsr	CHANGE_FVFAST

	rts

.rgb50:	MOVE.L   #$003E0032,$FFFF8282.W
        MOVE.L   #$0009023F,$FFFF8286.W
        MOVE.L   #$001C0035,$FFFF828A.W

; 320x200
        MOVE.L   #$02710265,$FFFF82A2.W
        MOVE.L   #$001F006F,$FFFF82A6.W
        MOVE.L   #$01FF026B,$FFFF82AA.W
; 320x240
;        MOVE.L   #$02710265,$FFFF82A2.W
;        MOVE.L   #$001F006F,$FFFF82A6.W
;        MOVE.L   #$01FF026B,$FFFF82AA.W

        MOVE.W   #$0200,$FFFF820A.W
        MOVE.W   #$0081,$FFFF82C0.W
        CLR.W    $FFFF8266.W
        MOVE.B   #$00,$FFFF8260.W
        MOVE.W   #$0000,$FFFF82C2.W
        MOVE.W   #$0050,$FFFF8210.W
	rts

SAVE_FV:lea	save_fv,a0
	move.l	$ffff8282.w,(a0)+		* h-regs
	move.l	$ffff8286.w,(a0)+		*
	move.l	$ffff828a.w,(a0)+		*
	move.l	$ffff82a2.w,(a0)+		* v-regs
	move.l	$ffff82a6.w,(a0)+		*
	move.l	$ffff82aa.w,(a0)+		*
	move.w	$ffff82c0.w,(a0)+		* vco
	move.w	$ffff82c2.w,(a0)+		* c_s
	move.l	$ffff820e.w,(a0)+		* offset
	move.w	$ffff820a.w,(a0)+		* sync
	move.b	$ffff8265.w,(a0)+		* p_o
	clr.b	(a0)				* test of st(e) or falcon mode
	cmp.w	#$b0,$ffff8282.w		* hht kleiner $b0?
	sle 	(a0)+				* flag setzen
	move.w	$ffff8266.w,(a0)+		* f_s
	move.w	$ffff8260.w,(a0)+		* st_s
	rts

* Changes screenresolution the fast way..
* Note: Takes one vbl, necessary to avoid monochrome sync errors.
* INPUT: a0: address of fv2-buffer
CHANGE_FVFAST:
	lea	save_fv,a0
	clr.w	$ffff8266.w			* falcon-shift clear
	move.l	(a0)+,$ffff8282.w	0	* h-regs
	move.l	(a0)+,$ffff8286.w	4	*
	move.l	(a0)+,$ffff828a.w 	8	*
	move.l	(a0)+,$ffff82a2.w	12	* v-regs
	move.l	(a0)+,$ffff82a6.w 	16	*
	move.l	(a0)+,$ffff82aa.w 	20	*
	move.w	(a0)+,$ffff82c0.w	24	* vco
	move.w	(a0)+,$ffff82c2.w	26	* c_s
	move.l	(a0)+,$ffff820e.w	28	* offset
	move.w	(a0)+,$ffff820a.w	32	* sync
	move.b	(a0)+,$ffff8265.w	34	* p_o
	tst.b	(a0)+			35	* st(e) compatible mode?
	bne.s	.ok			36
	move.w	$468.w,d0			* / wait for vbl
.wait468:					* | to avoid
	cmp.w	$468.w,d0			* | falcon monomode
	beq.s	.wait468			* \ syncerrors.
	move.w	(a0),$ffff8266.w	38	* falcon-shift
	bra.s	.video_restored
.ok:	move.w	2(a0),$ffff8260.w	40	* st-shift
	move.w	-10(a0),$ffff82c2.w		* c_s
	move.l	-8(a0),$ffff820e.w		* offset		
.video_restored:
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

	IFNE	1

* Emulated 16bit * 32bit multiply. Beware that the product must be below 2^32.
* INPUT: d0.w: number to multiply with
*        d1.l: number to multiply
* OUTPUT: d1.l: result of multiplication
Mulu_WordLong:	MACRO	word,long,tempLong
		move.l	\2,\3
		mulu.w	\1,\2
		swap	\3
		mulu.w	\1,\3
		swap	\3
		clr.w	\3
		add.l	\3,\2
		ENDM

Divu_LongLong:	MACRO	long,resLong,tempLong,tempLong2,tempLong3
		cmp.l	\1,\2
		blt.s	\@is_null
		moveq	#-1,\3
		move.l	\1,\4
		moveq	#0,\5
\@loop1:	addq.w	#1,\3
		add.l	\1,\1
		cmp.l	\1,\2
		bhi.s	\@loop1
\@loop2:	lsr.l	#1,\1
		sub.l	\1,\2
		bmi.s	\@skip_set
		bset	\3,\5
\@skip_set:	dbra	\3,\@loop2
		bra.s	\@end
\@is_null:	moveq	#0,\5
\@end:		move.l	\5,\2
		ENDM

Divu_LongBig:	MACRO	long,bigHigh,bigLow
		
		ENDM

* Displays a dialogbox with average framerate.
DISPLAY_FRMSPERSEC:
	move.l	frmcnt,d1
	moveq	#0,d2
	move.l	$04BA.w,d0
	sub.l	starttime,d0
	Mulu_WordLong	#200,d1,d2	;mulu.l	#200,d1
	;Divu_LongBig	d0,d2,d1	;divu.l	d0,d2:d1
	swap	d2
	Divu_LongLong	d0,d2,d3,d4,d5	;divu.l	d0,d2	
	move.l	d1,d0
	moveq	#-1,d7
.loop1	divu.w	#10,d0
	swap	d0
	addi.b	#'0',d0
	move.b	d0,-(sp)
	eor.w	d0,d0
	swap	d0
	addq.w	#1,d7
	tst.w	d0
	bne.s	.loop1

	lea	.alertpre_txt(pc),a1
	lea	.temp_txt(pc),a0
	lea	(a1),a6
.bloop1	move.b	(a1),(a0)+
	cmpi.b	#"]",(a1)+
	bne.s	.bloop1
.bloop2	move.b	(a1),(a0)+
	cmpi.b	#"]",(a1)+
	bne.s	.bloop2
	subq	#1,a0
	subq	#1,a1

.plop1	move.b	(sp)+,(a0)+
	dbra	d7,.plop1
.pre2	move.b	#".",(a0)+
	moveq	#5-1,d7
	;mulu.l	#$000186a0,d0:d2		
	move.w	d0,d2
	swap	d2
	move.l	d2,d0
.loop2	divu.w	#10,d0
	swap	d0
	addi.b	#"0",d0
	move.b	d0,-(sp)
	eor.w	d0,d0
	swap	d0
	dbra	d7,.loop2
	moveq	#5-1,d7
.plop2	move.b	(sp)+,(a0)+
	dbra	d7,.plop2

	move.l	#" fps",(a0)+
	move.b	#".",(a0)+

.0loop	move.b	(a1)+,(a0)+
	bne.s	.0loop

	move.w	#1,intin
	move.l	#.temp_txt,addrin
	move.l	#.alert_tbl,aespb
	move.l	#aespb,d1
	moveq	#0,d0
	move.b	#$c8,d0
	trap	#2
	rts

.temp_txt:
	DS.B	256
.alertpre_txt:
	DC.B	"[1][ Average framerate: | ][ OK ]",0
	EVEN

.alert_tbl:
	DC.W	$0034,$0001,$0001,$0001,$0000

	ENDC

;------- INTERRUPT ROUTINE CODE --------

NEW118:
.keylop:
	tst.b	$fffffc02.w
	bclr    #6,$FFFFFA11.w			* isrb
	btst    #4,$FFFFFA01.w			* gpip
	beq.s   .keylop
	rte

NEWTIMERC:
	addq.l	#1,$4ba.w
	rte

NEWVBL:	addq.l	#1,$466.w
	movem.l	d0-a6,-(sp)
	movea.l	musicirq(pc),a0
	jsr	(a0)
	movea.l	palirq(pc),a0
	jsr	(a0)
	movem.l	(sp)+,d0-a6
	rte

musicirq:
	DC.L	dummy
palirq:
	DC.L	dummy
notimerb:
	move	#$2700,sr
	bclr	#0,$fffffa07.w
	bclr	#0,$fffffa13.w
	move	#$2300,sr
	rts

dummy:	rts

end_tester_code:

;- data section -----------------------------------------------------------

	data

; AES parameter block
aespb:	DC.L	contrl,global,intin,intout,addrin,addrout

;- bss section ------------------------------------------------------------

	bss

	EVEN
*init-data
	DS.L	256
ustk:	DS.L	1
oldscr:	DS.L	1
oldstsync:
	ds.w	1
oldstres:
	ds.w	1
savepal_tbl:
	DS.W	16
save_fv:
	DS.W	24
sys_var:
	DS.L	19
old_cacr:
	ds.l	1

* machine stats
computer:
	DS.W	1
monitormode:
	DS.W	1
enhanced:
	ds.w	1
ct60:	ds.w	1

*GEM-shit
contrl:	DS.W    12
intin:	DS.W    128
intout:	DS.W    128
global:	DS.W    16
addrin:	DS.W    128
addrout:
	DS.W    128

*counter/timer shit
frmcnt:	DS.L	1
lastfrmcnt:
	DS.L	1
starttime:
	DS.L	1
gwem_sync_mode:
	ds.w	1
subeffectsnum:
	ds.w	1

*scr-stuff
scr:	ds.l	3
screen_buffers_adr:
	ds.l	1

sine_tbl:
	ds.l	2048

