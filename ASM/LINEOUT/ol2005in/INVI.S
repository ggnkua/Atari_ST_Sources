*                       /----------<<<==>>>----------\    =>
*                <=    / |     ST DEMO-OS v1.0      | \            =>
*      <=              \ | 03-02-1999 by EarX<=>fUn | /       =>
*             <=        \----------<<<==>>>----------/  =>

******** ASM OPTIONS AND PATHS ********

	COMMENT	HEAD=%001
	OPT	P=68000
	OPT	D-

******** GLOBAL EQUS ********

DEMO_SYSTEM:

triggermode:	EQU	1			* 0=manual effect-trigger, 1=event-table trigger
testmode:	EQU	0			* debug mode
objectmode:	EQU	1			* Must always be 1!

* computertype equates
st:		EQU	0
falcon:		EQU	1

scrxbytes:	EQU	160
scrlines:	EQU	(200+16)
maxscrsize:	EQU	scrxbytes*scrlines
* monitormode-equ's
autodetect:	EQU	0
rgb50:		EQU	1			* RGB/TV, 50Hz
vga60:		EQU	2			* VGA, 60Hz, noniterlaced
vga100:		EQU	3			* VGA, 100Hz, interlaced
* monitormode selector ( =autodetect ) or force mode ( >0 )
monitorequ:	EQU	autodetect

******** INITIALISING ********

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
* Reserve RAM for screens.
	move.l	#maxscrsize*2+256,-(sp)		* size of screens..
	move.w	#$48,-(sp)
	trap	#1
	addq	#8,sp
	tst.l	d0
	bgt.s	.ramok
* Not enough RAM free :(
	clr.w	-(sp)
	trap	#1
* Initialize screenaddresses..
.ramok	lea	scr,a0
	addi.l	#16*160,d0
	addi.l	#$000000ff,d0
	clr.b	d0
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

; Check out if it's an ST or better (STe, Falcon, TT).
	move.l	$05A0.w,d0
	beq.s	.st
	movea.l	d0,a0
.fndvdo:cmpi.l	#"_MCH",(a0)
	addq	#8,a0
	bne.s	.fndvdo
	tst.w	-4(a0)
	beq.s	.st
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

; set monitor mode..
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
	move.b	$ffff8260.w,oldstres

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
	clr.l	d0
	REPT	8
	move.l	d0,(a0)+
	ENDR
	bsr	set_stlow

	ENDC					* IFEQ testmode

	lea	event_tbl,a0
	bsr	INIT_DEMOPARTS
	move.w	d0,objectcount

	lea	event_tbl,a0
	lea	subeffect_tbl,a1
	move.w	objectcount,d0
	bsr	CHECK_DEMOEVENTS

	ifeq	testmode
	jsr	track					; init music.
	move.l	#play,musicirq				; play music.
	endc

	clr.l	frmcnt
	clr.l	lastfrmcnt

	IFNE	triggermode

	move.l	$466.w,starttime

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
	addq.w	#1,.cyclecount
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
	move.w	d0,.actpart			* / Kick in new
	move.l	a0,actpartadr			* \ object.
	movea.l	8(a0),a0			*
	jsr	(a0)				* Jump to res-setter.
.do_old:move.l	actpartadr,d0
	beq.s	triggerloopcycle
	move.l	d0,a0
	movea.l	(a0),a0
	jsr	(a0)				* Jump to fx-mainloop.
	addq.l	#1,frmcnt
	bra.s	triggerloopcycle
.do_subeffect:
	lea	.key2object_tbl,a0
	move.b	(a0,d0.l),d0
	beq.s	.do_old
	move.b	d1,d1
	bne.s	.do_old
	move.l	actpartadr,d2
	beq	triggerloopcycle
	movea.l	d2,a0
	move.w	.actpart(pc),d1
	lea	subeffect_tbl,a1
	cmp.b	(a1,d1.w),d0
	bhs.s	.do_old
	lsl.l	#2,d0
	movea.l	8(a0,d0.l),a0
	jsr	(a0)
	bra.s	.do_old

.actpart:
	DC.W	0
.oldkey:
	DC.W	0
.cyclecount:
	DC.W	0

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

******** PART CODE ********

event_tbl:
	DC.L	eventpart_tbl
	DC.W	(.end-.start)/6
	DC.W	0
.start:
; paint words 'lineout and homoos'
	DC.L	0
	DC.W	beecode+8
; fade in
	DC.L	0
	DC.W	beecode+6
; show bee..
	DC.L	0
	DC.W	beecode
; flash and show bee!
	DC.L	140
	DC.W	beecode+7

time:	set	500
; fade out
	DC.L	time
	DC.W	beecode+5
; paint words 'invite you to'
	DC.L	time+100
	DC.W	beecode+9
; fade in
	DC.L	time+100
	DC.W	beecode+6
; flash and show bee again: zoomed!
	DC.L	time+200
	DC.W	beecode+11
	DC.L	time+200
	DC.W	beecode+7

time:	set	1100
; fade out
	DC.L	time
	DC.W	beecode+5
; paint outline2005 logo
	DC.L	time+100
	DC.W	beecode+10
; fade in
	DC.L	time+100
	DC.W	beecode+6
; flash and show the bee again, but flapping!
	DC.L	1500
	DC.W	beecode+3
	DC.L	1500
	DC.W	beecode+7

; enter text displayer!
	DC.L	2550
	DC.W	textcode

; hammer on the fast and normal scrolling for music sync =)
time	set	2550
	dc.l	time
	dc.w	textcode+3
; scroll back..
time	set	time+380
	dc.l	time
	dc.w	textcode+6
time	set	time+148

; stop scrolling, set manual mode..
 	DC.L	time
	DC.W	textcode+5

	DC.L	1000000
	DC.W	0
.end:

wordscode:	=	1<<8
beecode:	=	2<<8
textcode:	=	3<<8

eventpart_tbl:
	DC.L	OUT
	DC.L	words_table
	DC.L	bee_table
	DC.L	text_table
	DC.L	0

* Included objects::

; this one was planned, but eventually incorporated in the bee screen..
words_table:
	dc.l	dummy,dummy,dummy,0

bee_table:
	include	sprite3.s
	text
text_table:
	include	vtscrol2.s
	text

******** EXITTING CODE ********

OUT:

	bsr	show_out_pic


	IFEQ	testmode

	movem.l	savepal_tbl,d0-d7
	movem.l	d0-d7,$ffff8240.w

	cmpi.w	#falcon,computer
	beq.s	.falc

	move.b	oldstres,$ffff8260.w
	bra.s	EXIT
	
.falc:	lea	save_fv,a0
	bsr	CHANGE_FVFAST

EXIT:
	ifeq	testmode
	move.l	#dummy,musicirq
	jsr	track+4					; de-init music.
	endc

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

******** DEMO-OS SUBROUTINES ********

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
	MOVE.L	#$41903B9,$FFFF82A2.W
	MOVE.L	#$61008D,$FFFF82A6.W
	MOVE.L	#$3AD0415,$FFFF82AA.W
	MOVE.W	#$200,$FFFF820A.W
	MOVE.W	#$186,$FFFF82C0.W
	CLR.W	$FFFF8266.W
	MOVE.B	#$0,$FFFF8260.W
	MOVE.W	#$5,$FFFF82C2.W
	MOVE.W	#$50,$FFFF8210.W
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

RESTORE_FV:
	lea	save_fv,a0
	bsr	CHANGE_FVFAST
	rts

* Changes screenresolution the fast way..
* Note: Takes one vbl, necessary to avoid monochrome sync errors.
* INPUT: a0: address of fv2-buffer
CHANGE_FVFAST:
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
	bra	.loop

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
	move.l	$466.w,d1
	sub.l	starttime,d1
	cmp.l	d0,d1
	blt.s	.rts
	move.w	(a0)+,d1
	beq	OUT
	move.w	d1,d0
	lsr.w	#8,d0
	andi.w	#$00ff,d1
	bne.s	.intern
	move.l	frmcnt,lastfrmcnt
	lsl.w	#2,d0
	move.l	(a1,d0.w),actpartadr
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
.ok2:	dbra	d7,.loop
.rts	rts

SEEYOU:=	1

show_out_pic:
; disable vbl left-overs
	move.l	#dummy,palirq

	ifne	SEEYOU

	bsr	paint_words4

	else

; paint pic
	movea.l	scr,a0
	lea	title_pi1+34,a1
	move.w	#200*20-1,d7
.loop	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbf	d7,.loop

	endc

; set vbase
	move.l	scr,d0
	lsr.w	#8,d0
	move.l	d0,$FFFF8200.w

; set palette synced with vbl
	ifne	SEEYOU
	lea	words_fade_palette+15*32,a0
	else
	lea	title_fade_palette+15*32,a0
	endc
	move.w	$0468.w,d0
.wait1:	cmp.w	$0468.w,d0
	beq.s	.wait1
	movem.l	(a0),d0-d6/a1
	movem.l	d0-d6/a1,$FFFF8240.w

; wait a while..
	move.w	$0468.w,d0
.wait:	move.w	$0468.w,d1
	sub.w	d0,d1
	cmpi.w	#300,d1
	blt.s	.wait

; fade down
	moveq	#15-1,d7

.floop:	move.w	$0468.w,d0
.wait2:	cmp.w	$0468.w,d0
	beq.s	.wait2

	lea	-32(a0),a0
	movem.l	(a0),d0-d6/a1
	movem.l	d0-d6/a1,$FFFF8240.w
	dbf	d7,.floop

	rts

******** INTERRUPTS ********

NEWVBL:	addq.l	#1,$466.w
	movem.l	d0-a6,-(sp)
	movea.l	musicirq(pc),a0
	jsr	(a0)
	movea.l	palirq(pc),a0
	jsr	(a0)
	movem.l	(sp)+,d0-a6
	rte

play:
;	move.w	#2000-1,d7
;.loop:	dbf	d7,.loop

	lea	$FFFF8240.w,a0
	move.w	(a0),-(sp)
	move.w	#$00F0,(a0)
	jsr	track+8
	move.b	track+$A6,scroll_sync
	move.w	(sp)+,$FFFF8240.w
	rts

musicirq:
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

******** DATA + INCBINS ********

	DATA

sine_tbl:
	INCBIN	SINUS.DAT

track:	incbin	outlined.snd
	even

******** RESERVES ********

	BSS

	EVEN

* Init-data
	DS.L	256
ustk:	DS.L	1
oldsp:	DS.L	1
oldscr:	DS.L	1
oldvbl:	DS.L	1
old118:	DS.L	1
oldstres:
	DS.W	1
savepal_tbl:
	DS.W	16
save_fv:DS.W	24
sys_var:DS.L	19

* VIDEL mode shit
computer:
	DS.W	1
monitormode:
	DS.W	1
enhanced:
	DS.W	1
ct60:	ds.w	1

* Object handling
objectcount:
	DS.W	1
subeffect_tbl:
	DS.B	128

* Timer stuffs
starttime:
	DS.L	1
frmcnt:	DS.L	1
lastfrmcnt:
	DS.L	1
gwem_sync_mode:
	ds.w	1

* Scr-stuff
scr:	DS.L	3
