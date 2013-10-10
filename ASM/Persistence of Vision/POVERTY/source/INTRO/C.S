*************************************************************************
*				POVerty demo				*
*				~~~~~~~~~~~~				*
*									*
*									*
* Written by:	MAC SYS DATA of Persistence Of Vision			*
*									*
*									*
* Date:									*
*									*
*									*
*									*
*									*
*									*
*									*
*				FALCON 030 VERSION			*
*									*
*************************************************************************
yes=1
YES=yes
NO=0
no=NO


FINAL	equ	yes		;final disk version



;Based on STE stuff (c) May 1990

LINEWID		equ	160

MVOL	EQU	$80
FREQ	EQU	2			; 0=6.259, 1=12.517, 2=25.036
					; 3=50.072 (MegaSTe/TT)

	IFEQ FREQ
PARTS	EQU 5-1				; 6.259
LEN	EQU 25
INC	EQU $023BF313			; 3579546/6125*65536
	ELSEIF
	IFEQ FREQ-1
PARTS	EQU 5-1				; 12.517
LEN	EQU 50
INC	EQU $011DF989			; 3579546/12517*65536
	ELSEIF
	IFEQ FREQ-2
PARTS	EQU 5-1				; 25.035
LEN	EQU 100
INC	EQU $008EFB4E			; 3579546/25035*65536
	ELSEIF
	IFEQ FREQ-3
PARTS	EQU 5-1				; 50.072
LEN	EQU 200
INC	EQU $00477CEC			; 3579546/50072*65536
	ELSEIF
	FAIL
	END
	ENDC
	ENDC
	ENDC
	ENDC


start
		ifne	FINAL
		org	$10000
		endc

		lea	bssstart,a0
		move.l	#bssend-bssstart,d0
		lsr.l	#2,d0
clear_bss	clr.l	(a0)+
		sub.l	#1,d0
		bne.s	clear_bss

		ifeq	FINAL
		bsr	set_super
		dc.w	$a00a		;hide mouse
		endc

		bsr	set_up
		movem.l	new_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w


;************************************************************************
;
		move.w	#LINEWID,$ffff820e.w	;offset to next line
;
;		size
;FF820f		8	Line offset (LINEWID) - the number of extra words 
;			added to the address counter at the end of each 
;			line, _MINUS ONE DATA FETCH_. This allows for 
;			virtual screens that are wider than the actual 
;			screen display. Clearing this register means the 
;			STE acts like an ordinary ST.
;************************************************************************


wait		rept	1
		bsr	v_sync
		endr
		sub.w	#1,main_timer
		beq.s	shutdown
;	move.w	#$123,$ffff8240.w

		bsr	sequencer
;	move.b	hard_addr+1,$ffff8201.w
;	move.b	hard_addr+2,$ffff8203.w
;	move.b	hard_addr+3,$ffff820d.w

	move.b	hard_addr+1,$ffff8205.w
	move.b	hard_addr+2,$ffff8207.w
	move.b	hard_addr+3,$ffff8209.w

;	move.w	#0,$ffff8240.w
		bsr	tst_key
		tst.l	d0
		beq	wait
		bsr	get_key

shutdown	bsr	musoff


		move.w	#0,$ffff820e.w		;offset to next word of screen
		clr.w	$ffff8264.w		;bit offset

		clr.b	$ffff8901.w		;DI DMA sample

		movem.l	old_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w

		tst.w	falcon_flag
		beq.s	.no_falcon

		move.b	#%1110,$ffff8800.w
		move.b	old_falcon_speaker,$ffff8802.w

		move.w	original_falcon_rez,-(sp)	;set rez
		move.w	#$58,-(sp)
		trap	#14
		addq.l	#4,sp

		move.b	old_falcon_proc,$ffff8007.w
		bra.s	.over
.no_falcon
		bsr	set_old_rez
.over
		ifne	FINAL
		jmp	$9100
		elseif
		dc.w	$a009
		bsr	set_user
		endc

		clr.w	-(sp)
		trap	#1


*******************
* CUSTOM ROUTINES *
*******************
sequencer	tst.l	sequencer_timer
		bne.s	.nochange
		lea	routine_table,a0
		add.w	routine_offset,a0
		move.l	(a0)+,present_routine
		move.l	(a0)+,sequencer_timer
		add.w	#8,routine_offset
		rts
.nochange	sub.l	#1,sequencer_timer
		move.l	present_routine,a0
		jmp	(a0)


null		rts




fadescrolldown	bsr	scroll
		lea	black,a1
		bra	fade

fadescrollup	bsr	scroll
		lea	new_pal,a1
		bra	fade

fadetextup	lea	white,a1
		bra	fade

fadetextdown	lea	black,a1
		bra	fade


;A0=SOURCE PALETTE 	A1=TARGET PALETTE
fade		lea	$ffff8240.w,a0
		move.w	#16-1,d7
.loop		bsr	modify
		add.w	#2,a0
		add.w	#2,a1
		dbf	d7,.loop
		rts
modify		move.w	(a0),d0		;get color value
		move.w	(a1),d1		;target pal
		move.w	d0,d4		;NEW COL
		move.w	d0,d2
		move.w	d1,d3
		and.w	#7,d2
		and.w	#7,d3
		cmp.w	d2,d3
		beq.s	blue_ok
		bmi.s	blue_dn
		addq.w	#1,d4
		bra.s	blue_ok
blue_dn		subq	#1,d4
blue_ok		move.w	d0,d2
		move.w	d1,d3
		and.w	#$70,d2
		and	#$70,d3
		cmp.w	d2,d3
		beq.s	grn_ok
		bmi.s	grn_dn
		add.w	#$10,d4
		bra.s	grn_ok
grn_dn		sub.w	#$10,d4
grn_ok		move.w	d0,d2
		move.w	d1,d3
		and.w	#$700,d2
		and.w	#$700,d3
		cmp.w	d2,d3
		beq.s	red_ok
		bmi.s	red_dn
		add.w	#$100,d4
		bra.s	red_ok
red_dn		sub.w	#$100,d4
red_ok		move.w	d4,(a0)
		rts






scroll		move.w	screen_offset,d0
		add.w	#1,screen_offset
		move.w	d0,d1
		move.w	d1,d2

		and.w	#$f0,d1			;shift /8
		lsr.w	#1,d1

		move.l	screen_base,d6
		and.w	#$ff00,d2		;256 boundary
		lsr.w	#1,d2
		add.w	d1,d2
		add.w	d2,d6
		move.l	d6,hard_addr

		and.w	#$f,d0			;bit shift
		bne.s	.extra_fetch
		move.w	#LINEWID,$ffff820e.w	;offset to next line
		move.b	d0,$ffff8265.w		;pixel shift
		rts
.extra_fetch	move.w	#LINEWID-4,$ffff820e.w	;offset to next line
		move.b	d0,$ffff8265.w		;pixel shift
		rts






temp		ds.l	1	;scroll screen pos
		ds.w	1	;word offset to screen
		ds.w	1	;bit offset of screen
reset_scroll_scrn
		lea	temp(pc),a0
		move.l	(a0)+,hard_addr
		move.w	(a0)+,$ffff820e.w	;offset to next word of screen
		move.w	(a0)+,$ffff8264.w	;bit offset
		rts

print_text	move.l	text_screen_pos,a0	;clear screen
		move.w	#32000/4-1,d0
.loop		clr.l	(a0)+
		dbf	d0,.loop

		lea	temp(pc),a0
		move.l	hard_addr,(a0)+
		move.w	$ffff820e.w,(a0)+
		move.w	$ffff8264.w,(a0)
		clr.w	$ffff820e.w
		clr.w	$ffff8264.w
		move.l	text_screen_pos,d6
		move.l	d6,hard_addr

		move.l	text_pos,a1
		move.l	text_screen_pos,a6
		add.w	#6,a6
.restart	move.l	a6,a0
		moveq	#0,d1
		move.b	(a1)+,d1
		bpl.s	.do_text
		add.w	#4,texttableoffset
		lea	texttable,a0
		add.w	texttableoffset,a0
		tst.l	(a0)
		bpl.s	.ok
		clr.w	texttableoffset		;start at restart
		rts
.ok		move.l	(a0),text_pos
		move.w	#100,texttimer
		clr.b	xpos
		clr.b	ypos
		rts
.clear		moveq	#0,d1
		move.l	screen_base,a5
		move.w	#32000/4-1,d0
.clr_loop	move.l	d1,(a5)+
		dbf	d0,.clr_loop
		rts

.do_text	cmp.b	#$7f,d1
		bne.s	.no_restart
		lea	texttable,a0
		clr.w	texttableoffset
		move.l	(a0),text_pos
		move.w	#100,texttimer
		clr.b	xpos
		clr.b	ypos
		rts

.no_restart	move.l	a1,text_pos
		cmp.b	#13,d1
		bne.s	.notcr
		clr.b	xpos
		bra	.restart
.notcr		cmp.b	#10,d1
		bne.s	.notlf
		addq.b	#1,ypos
		bra	.restart
.notlf		cmp.b	#9,d1		;HORIZONTAL TAB
		bne.s	.notab		;routine added 11/2/92 for print speed
;calc TAB by getting MOD 8.
		moveq	#0,d5
		move.b	xpos,d5
		and.w	#%111,d5	;mod 8
		move.w	#8,d4
		sub.w	d5,d4		;sub MOD 8
		add.b	d4,xpos		;add to XPOS so now we are in correct word
		bra	.restart
.notab		sub.b	#32,d1
		mulu	#32,d1
		lea	font,a2
		add.w	d1,a2
		moveq	#0,d0
		move.b	ypos,d0
		mulu	#160*18,d0	;drop down 18 pixels...
		add.l	d0,a0
		move.b	xpos,d0
		and.l	#$ff,d0
		lsl.l	#3,d0	;*8	;bytes across screen
		add.l	d0,a0
		addq.b	#1,xpos
LINE_OFFSET	set	0
		rept	16
		move.w	(a2)+,LINE_OFFSET(a0)
LINE_OFFSET	set	LINE_OFFSET+160
		endr
		bra	.restart




set_up
************************************************************************
*** Detect Falcon computer code...
***
*** Written by MAC SYS DATA of PERSISTENCE OF VISION
***
***
		move.l	$5a0.w,a0
		cmp.l	#0,a0
		beq.s	.nocookiejar
		move.l	$14(a0),d0	;get video shifter type?
		tst.l	d0
		beq.s	.notdma
		cmp.l	#$30000,d0
		bne.s	.nofalcon
		move.w	#-1,falcon_flag
.nofalcon
.notdma
.nocookiejar
************************************************************************
		move.l	$44e.w,old_base
		movem.l	$ffff8240.w,d0-d7
		movem.l	d0-d7,old_pal

		move.w	#4,-(sp)	;get original rez
		trap	#14
		addq.l	#2,sp
		move.w	d0,org_rez

		tst.w	falcon_flag
		beq.s	.not_falcon
		move.w	#-1,-(sp)
		move.w	#$58,-(sp)	;get original falcon rez
		trap	#14
		addq.l	#4,sp
		move.w	d0,original_falcon_rez

		clr.l	$ffff9800.w		;black out falcon
		move.b	#%1110,$ffff8800.w		;i/o port A select
		move.b	$ffff8802.w,old_falcon_speaker	;get value of reg
		or.b	#%10111111,$ffff8802.w		;turn internal speaker off

		move.b	$ffff8007,old_falcon_proc	;set falcon into 8 Mhz!

		clr.b	$ffff8007.w		

		clr.b	$ffff8935.w		;ste freq div internal sync

		move.w	#%0000000010100010,-(sp)	;set rez
		move.w	#$58,-(sp)
		trap	#14
		addq.l	#4,sp
;Octet de poids faible :    S O P V 8 N N N
;	N  Bits par pixels :	4 -> 16 bits
;				3 -> 8  bits
;				2 -> 4  bits
;				1 -> 2  bits
;				0 -> 1  bit
;	8 Flag 80 colonnes :	1 -> mode 80 colonnes
;				0 -> mode 40 colonnes
;	V Flag VGA         :	1 -> mode moniteur VGA
;				0 -> mode TV
;	P Flag PAL         :	1 -> mode PAL
;				0 -> mode NTSC
;	O Flag Overscan    :	1 -> Overscan ON (impossible en VGA)
;				0 -> Overscan OFF

;Where 'mode' looks like this:-
;    bits            meaning
;    0-2             These bits form a value so that 2^X represents the 
;                    number of bits/pixel
;    3               80 coloun flag (if set, 80 columns, otherwise 40)
;    4               VGA Flag (if set, VGA mode, if not TV/RGB mode) 
;    5               PAL Flag (if set, PAL mode, otherwise NTSC)
;    6               Overscan Flag (not valid with VGA)
;    7               ST compatibility flag
;    8               Vertical flag (if set, enables interlace mode on a         
;                    colour monitor or double line mode on a VGA monitor)
;    9-15            Reserved (set 0)

		movem.l	black,d0-d7
		movem.l	d0-d7,$ffff8240.w
		bra.s	.over

.not_falcon	movem.l	black,d0-d7
		movem.l	d0-d7,$ffff8240.w


.over		move.l	#screen,d6
		clr.b	d6
		move.l	d6,screen_base

		bsr	set_low_rez

		bsr	set_screen

		move.l	#text_screen,d6
		clr.b	d6
		move.l	d6,text_screen_pos

******** set up text timer variables
		move.w	#1,texttimer

		move.w	#2352,main_timer

;make 2 PI1's into a 3 pic wide image

		movem.l	image+2,d0-d7
		movem.l	d0-d7,new_pal

		move.l	screen_base,a0
		add.w	#8*20,a0
		lea	image+34,a1		;pic 1
		lea	32034(a1),a2		;pic 2

		move.w	#200-1,d0
.loop		move.w	d0,-(sp)
		movem.l	(a1)+,d0-d7
		movem.l	d0-d7,(a0)
		movem.l	(a1)+,d0-d7
		movem.l	d0-d7,32(a0)
		movem.l	(a1)+,d0-d7
		movem.l	d0-d7,64(a0)
		movem.l	(a1)+,d0-d7
		movem.l	d0-d7,96(a0)
		movem.l	(a1)+,d0-d7
		movem.l	d0-d7,128(a0)	;160 bytes (1 line)
		lea	160(a0),a0

		movem.l	(a2)+,d0-d7
		movem.l	d0-d7,(a0)
		movem.l	(a2)+,d0-d7
		movem.l	d0-d7,32(a0)
		movem.l	(a2)+,d0-d7
		movem.l	d0-d7,64(a0)
		movem.l	(a2)+,d0-d7
		movem.l	d0-d7,96(a0)
		movem.l	(a2)+,d0-d7
		movem.l	d0-d7,128(a0)
		lea	160(a0),a0
		lea	160(a0),a0

		move.w	(sp)+,d0
		dbf	d0,.loop


******** sequencer startup variables
		lea	routine_table,a0
		move.l	(a0)+,present_routine
		move.l	(a0)+,sequencer_timer
		move.w	#8,routine_offset


;*** mod startup
		bsr	vol		; Calculate volume tables
		bsr	incrcal		; Calculate tonetables
		jsr	init		; Initialize music
		jsr	prepare		; Prepare samples
;***
		move	#$2700,sr
		bset	#5,$FFFFFA07.w
		bset	#5,$FFFFFA13.w
		clr.b	$FFFFFA19.w
		move.b	#1,$FFFFFA1F.w
		move.b	#8,$FFFFFA19.w
		move.l	$134.w,oldtima
		move.l	#stereo,$0134.w
		move.b	#FREQ,$FFFF8921.w		; Frequency
		lea	$FFFF8907.w,a0
		move.l	#sample1,d0
		move.b	d0,(a0)
		lsr.w	#8,d0
		move.l	d0,-5(a0)
		move.l	#sample1+LEN*2,d0
		move.b	d0,12(a0)
		lsr.w	#8,d0
		move.l	d0,7(a0)
		move.b	#3,$FFFF8901.w		; Start DMA
		move	#$2300,sr
		rts


set_low_rez	clr.w	-(sp)
		bra.s	set_rez
set_med_rez	move.w	#1,-(sp)
		bra.s	set_rez
set_org_rez	tst.w	falcon_flag
		beq.s	.no_falcon
		move.w	original_falcon_rez,-(sp)
		bra.s	set_rez
.no_falcon	move.w	org_rez,-(sp)
set_rez		move.l	screen_base,-(sp)
		move.l	(sp),-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp
		rts


musoff	move	#$2700,sr

	clr.b	$FFFFFA19.w		; Stop timers

	move.l	oldtima,$0134.w	; Restore everything

	bclr	#5,$FFFFFA07.w
	bclr	#5,$FFFFFA13.w

	clr.b	$FFFF8901.w		; Stop DMA

	move	#$2300,sr
	rts


set_screen	lsr.l	#8,d6
		lea	$ffff8201.w,a6
		movep.w	d6,(a6)
		rts








v_sync		movem.l	d0-d3/a0-a3,-(sp)
		move.w	#$25,-(sp)
		trap	#14
		addq.l	#2,sp
		movem.l	(sp)+,d0-d3/a0-a3
		rts

tst_key		move.w	#11,-(sp)
		trap	#1
		addq.l	#2,sp
		rts

get_key		move.w	#7,-(sp)
		trap	#1
		addq.l	#2,sp
		rts

set_super	clr.l	-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,stack_save
		rts

set_user	move.l	stack_save,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		rts




set_old_rez	move.b	org_rez,$ffff8260.w
		move.l	old_base,d6
		bra.s	set_screen



;--------------------------------------------------------- Volume table --
vol	moveq	#64,d0
	lea	vtabend(pc),a0

.ploop	move.w	#255,d1
.mloop	move.w	d1,d2
	ext.w	d2
	muls	d0,d2
	divs	#MVOL,d2		; <---- Master volume
	move.b	d2,-(a0)
	dbra	d1,.mloop
	dbra	d0,.ploop

	rts

vtab	DS.B 65*256
vtabend

;------------------------------------------------------ Increment-table --
incrcal	lea	stab(pc),a0
	move.w	#$30,d1
	move.w	#$039F-$30,d0
	move.l	#INC,d2

recalc	swap	d2
	moveq	#0,d3
	move.w	d2,d3
	divu	d1,d3
	move.w	d3,d4
	swap	d4

	swap	d2
	move.w	d2,d3
	divu	d1,d3
	move.w	d3,d4
	move.l	d4,(a0)+

	addq.w	#1,d1
	dbra	d0,recalc
	rts

itab	DS.L $30
stab	DS.L $03A0-$30

;-------------------------------------------------------- DMA interrupt --
stereo	move	#$2500,sr
	bclr	#5,$FFFFFA0F.w
	movem.l	d0-a6,-(sp)

	move.l	samp1(pc),d0
	move.l	samp2(pc),samp1
	move.l	d0,samp2

	lea	$FFFF8907.w,a0

	move.l	samp1(pc),d0
	move.b	d0,(a0)
	lsr.w	#8,d0
	move.l	d0,-5(a0)

	move.l	samp1(pc),d0
	add.l	#LEN*2,d0
	move.b	d0,12(a0)
	lsr.w	#8,d0
	move.l	d0,7(a0)

	subq.w	#1,count
	bpl.s	.nomus

	move.w	#PARTS,count
	bsr	music

.nomus	lea	itab(pc),a5
	lea	vtab(pc),a3
	moveq	#0,d0
	moveq	#0,d4

v1	movea.l	wiz2lc(pc),a0

	move.w	wiz2pos(pc),d0
	move.w	wiz2frc(pc),d1

	move.w	aud2per(pc),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d2

	movea.w	2(a5,d7.w),a4

	move.w	aud2vol(pc),d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a2


	movea.l	wiz3lc(pc),a1

	move.w	wiz3pos(pc),d4
	move.w	wiz3frc(pc),d5

	move.w	aud3per(pc),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d6
	movea.w	2(a5,d7.w),a5

	move.w	aud3vol(pc),d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a3

	movea.l	samp1(pc),a6
	moveq	#0,d3

	REPT LEN
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.w	d7,(a6)+
	ENDR

	cmp.l	wiz2len(pc),d0
	blt.s	.ok2
	sub.w	wiz2rpt(pc),d0

.ok2	move.w	d0,wiz2pos
	move.w	d1,wiz2frc

	cmp.l	wiz3len(pc),d4
	blt.s	.ok3
	sub.w	wiz3rpt(pc),d4

.ok3	move.w	d4,wiz3pos
	move.w	d5,wiz3frc



	lea	itab(pc),a5
	lea	vtab(pc),a3
	moveq	#0,d0
	moveq	#0,d4

v2	movea.l	wiz1lc(pc),a0

	move.w	wiz1pos(pc),d0
	move.w	wiz1frc(pc),d1

	move.w	aud1per(pc),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d2
	movea.w	2(a5,d7.w),a4

	move.w	aud1vol(pc),d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a2


	movea.l	wiz4lc(pc),a1

	move.w	wiz4pos(pc),d4
	move.w	wiz4frc(pc),d5

	move.w	aud4per(pc),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d6
	movea.w	2(a5,d7.w),a5

	move.w	aud4vol(pc),d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a3

	movea.l	samp1(pc),a6
	moveq	#0,d3

	REPT LEN
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.b	d7,(a6)
	addq.w	#2,a6
	ENDR

	cmp.l	wiz1len(pc),d0
	blt.s	.ok1
	sub.w	wiz1rpt(pc),d0

.ok1	move.w	d0,wiz1pos
	move.w	d1,wiz1frc

	cmp.l	wiz4len(pc),d4
	blt.s	.ok4
	sub.w	wiz4rpt(pc),d4

.ok4	move.w	d4,wiz4pos
	move.w	d5,wiz4frc

	movem.l	(sp)+,d0-a6
	rte

;-------------------------------------------- Hardware-registers & data --
count	DC.W PARTS

wiz1lc	DC.L sample1
wiz1len	DC.L 0
wiz1rpt	DC.W 0
wiz1pos	DC.W 0
wiz1frc	DC.W 0

wiz2lc	DC.L sample1
wiz2len	DC.L 0
wiz2rpt	DC.W 0
wiz2pos	DC.W 0
wiz2frc	DC.W 0

wiz3lc	DC.L sample1
wiz3len	DC.L 0
wiz3rpt	DC.W 0
wiz3pos	DC.W 0
wiz3frc	DC.W 0

wiz4lc	DC.L sample1
wiz4len	DC.L 0
wiz4rpt	DC.W 0
wiz4pos	DC.W 0
wiz4frc	DC.W 0

aud1lc	DC.L dummy
aud1len	DC.W 0
aud1per	DC.W 0
aud1vol	DC.W 0
	DS.W 3

aud2lc	DC.L dummy
aud2len	DC.W 0
aud2per	DC.W 0
aud2vol	DC.W 0
	DS.W 3

aud3lc	DC.L dummy
aud3len	DC.W 0
aud3per	DC.W 0
aud3vol	DC.W 0
	DS.W 3

aud4lc	DC.L dummy
aud4len	DC.W 0
aud4per	DC.W 0
aud4vol	DC.W 0

dmactrl	DC.W 0

dummy	DC.L 0


sample1	DS.W LEN
sample2	DS.W LEN

samp1	DC.L sample1
samp2	DC.L sample2

;========================================================= EMULATOR END ==

prepare	lea	workspc,a6
	movea.l	samplestarts,a0
	movea.l	end_of_samples(pc),a1

tostack	move.w	-(a1),-(a6)
	cmpa.l	a0,a1			; Move all samples to stack
	bgt.s	tostack

	lea	samplestarts,a2
	lea	mod,a1		; Module
	movea.l	(a2),a0			; Start of samples
	movea.l	a0,a5			; Save samplestart in a5

	moveq	#30,d7

roop	move.l	a0,(a2)+		; Sampleposition

	tst.w	$2A(a1)
	beq.s	samplok			; Len=0 -> no sample

	tst.w	$2E(a1)			; Test repstrt
	bne.s	repne			; Jump if not zero

repeq	move.w	$2A(a1),d0		; Length of sample
	move.w	d0,d4
	subq.w	#1,d0

	movea.l	a0,a4
fromstk	move.w	(a6)+,(a0)+		; Move all samples back from stack
	dbra	d0,fromstk

	bra.s	rep



repne	move.w	$2E(a1),d0
	move.w	d0,d4
	subq.w	#1,d0

	movea.l	a6,a4
get1st	move.w	(a4)+,(a0)+		; Fetch first part
	dbra	d0,get1st

	adda.w	$2A(a1),a6		; Move a6 to next sample
	adda.w	$2A(a1),a6



rep	movea.l	a0,a5
	moveq	#0,d1
toosmal	movea.l	a4,a3
	move.w	$30(a1),d0
	subq.w	#1,d0
moverep	move.w	(a3)+,(a0)+		; Repeatsample
	addq.w	#2,d1
	dbra	d0,moverep
	cmp.w	#320,d1			; Must be > 320
	blt.s	toosmal

	move.w	#320/4-1,d2
last320	move.l	(a5)+,(a0)+		; Safety 320 bytes
	dbra	d2,last320

done	add.w	d4,d4

	move.w	d4,$2A(a1)		; length
	move.w	d1,$30(a1)		; Replen
	clr.w	$2E(a1)

samplok	lea	$1E(a1),a1
	dbra	d7,roop

	cmp.l	#workspc,a0
	bgt.s	.nospac

	rts

.nospac	illegal

end_of_samples	DC.L 0

;------------------------------------------------------ Main replayrout --
init	lea	mod,a0
	lea	$03B8(a0),a1

	moveq	#$7F,d0
	moveq	#0,d1
loop	move.l	d1,d2
	subq.w	#1,d0
lop2	move.b	(a1)+,d1
	cmp.b	d2,d1
	bgt.s	loop
	dbra	d0,lop2
	addq.b	#1,d2

	lea	samplestarts,a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#$043C,d2
	add.l	a0,d2
	movea.l	d2,a2

	moveq	#$1E,d0
lop3	clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#0,d1
	move.w	42(a0),d1
	add.l	d1,d1
	adda.l	d1,a2
	adda.l	#$1E,a0
	dbra	d0,lop3

	move.l	a2,end_of_samples
	rts

music	lea	mod(pc),a0
	addq.w	#1,counter
	move.w	counter(pc),d0
	cmp.w	speed(pc),d0
	blt.s	nonew
	clr.w	counter
	bra	getnew

nonew	lea	voice1(pc),a4
	lea	aud1lc(pc),a3
	bsr	checkcom
	lea	voice2(pc),a4
	lea	aud2lc(pc),a3
	bsr	checkcom
	lea	voice3(pc),a4
	lea	aud3lc(pc),a3
	bsr	checkcom
	lea	voice4(pc),a4
	lea	aud4lc(pc),a3
	bsr	checkcom
	bra	endr

mt_arpeggio
	moveq	#0,d0
	move.w	counter(pc),d0
	divs	#$03,d0
	swap	d0
	tst.w	d0
	beq.s	arp2
	cmp.w	#$02,d0
	beq.s	arp1

	moveq	#0,d0
	move.b	$03(a4),d0
	lsr.b	#4,d0
	bra.s	arp3

arp1	moveq	#0,d0
	move.b	$03(a4),d0
	and.b	#$0F,d0
	bra.s	arp3

arp2	move.w	$10(a4),d2
	bra.s	arp4

arp3	add.w	d0,d0
	moveq	#0,d1
	move.w	$10(a4),d1
	lea	periods(pc),a0
	moveq	#$24,d4
arploop	move.w	0(a0,d0.w),d2
	cmp.w	(a0),d1
	bge.s	arp4
	addq.l	#2,a0
	dbra	d4,arploop
	rts

arp4	move.w	d2,$06(a3)
	rts

getnew	lea	mod+$043C(pc),a0
	lea	-$043C+$0C(a0),a2
	lea	-$043C+$03B8(a0),a1

	moveq	#0,d0
	move.l	d0,d1
	move.b	songpos(pc),d0
	move.b	0(a1,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.w	pattpos(pc),d1
	clr.w	dmacon

	lea	aud1lc(pc),a3
	lea	voice1(pc),a4
	bsr.s	playvoice
	lea	aud2lc(pc),a3
	lea	voice2(pc),a4
	bsr.s	playvoice
	lea	aud3lc(pc),a3
	lea	voice3(pc),a4
	bsr.s	playvoice
	lea	aud4lc(pc),a3
	lea	voice4(pc),a4
	bsr.s	playvoice
	bra	setdma

playvoice
	move.l	0(a0,d1.l),(a4)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	$02(a4),d2
	and.b	#$F0,d2
	lsr.b	#4,d2
	move.b	(a4),d0
	and.b	#$F0,d0
	or.b	d0,d2
	tst.b	d2
	beq.s	setregs
	moveq	#0,d3
	lea	samplestarts(pc),a1
	move.l	d2,d4
	subq.l	#$01,d2
	asl.l	#2,d2
	mulu	#$1E,d4
	move.l	0(a1,d2.l),$04(a4)
	move.w	0(a2,d4.l),$08(a4)
	move.w	$02(a2,d4.l),$12(a4)
	move.w	$04(a2,d4.l),d3
	tst.w	d3
	beq.s	noloop
	move.l	$04(a4),d2
	add.w	d3,d3
	add.l	d3,d2
	move.l	d2,$0A(a4)
	move.w	$04(a2,d4.l),d0
	add.w	$06(a2,d4.l),d0
	move.w	d0,8(a4)
	move.w	$06(a2,d4.l),$0E(a4)
	move.w	$12(a4),$08(a3)
	bra.s	setregs

noloop	move.l	$04(a4),d2
	add.l	d3,d2
	move.l	d2,$0A(a4)
	move.w	$06(a2,d4.l),$0E(a4)
	move.w	$12(a4),$08(a3)
setregs	move.w	(a4),d0
	and.w	#$0FFF,d0
	beq	checkcom2
	move.b	$02(a4),d0
	and.b	#$0F,d0
	cmp.b	#$03,d0
	bne.s	setperiod
	bsr	setmyport
	bra	checkcom2

setperiod
	move.w	(a4),$10(a4)
	andi.w	#$0FFF,$10(a4)
	move.w	$14(a4),d0
	move.w	d0,dmactrl
	clr.b	$1B(a4)

	move.l	$04(a4),(a3)
	move.w	$08(a4),$04(a3)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	move.w	$14(a4),d0
	or.w	d0,dmacon
	bra	checkcom2

setdma	move.w	dmacon(pc),d0

	btst	#0,d0			;-------------------
	beq.s	wz_nch1			;
	move.l	aud1lc(pc),wiz1lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud1len(pc),d1		;
	move.w	voice1+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz1len		;
	move.w	d2,wiz1rpt		;
	clr.w	wiz1pos			;

wz_nch1	btst	#1,d0			;
	beq.s	wz_nch2			;
	move.l	aud2lc(pc),wiz2lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud2len(pc),d1		;
	move.w	voice2+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz2len		;
	move.w	d2,wiz2rpt		;
	clr.w	wiz2pos			;

wz_nch2	btst	#2,d0			;
	beq.s	wz_nch3			;
	move.l	aud3lc(pc),wiz3lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud3len(pc),d1		;
	move.w	voice3+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz3len		;
	move.w	d2,wiz3rpt		;
	clr.w	wiz3pos			;

wz_nch3	btst	#3,d0			;
	beq.s	wz_nch4			;
	move.l	aud4lc(pc),wiz4lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud4len(pc),d1		;
	move.w	voice4+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz4len		;
	move.w	d2,wiz4rpt		;
	clr.w	wiz4pos			;-------------------

wz_nch4	addi.w	#16,pattpos
	cmpi.w	#$400,pattpos
	bne.s	endr

nex	clr.w	pattpos
	clr.b	break
	addq.b	#1,songpos
	andi.b	#$7F,songpos
	move.b	songpos(pc),d1
	cmp.b	mod+950(pc),d1
	blo.s	endr
;**** Why does this MOD restart code NOT work???? - MSD
	move.b	mod+951(pc),songpos
endr	tst.b	break
	bne.s	nex
	rts

setmyport
	move.w	(a4),d2
	and.w	#$0FFF,d2
	move.w	d2,$18(a4)
	move.w	$10(a4),d0
	clr.b	$16(a4)
	cmp.w	d0,d2
	beq.s	clrport
	bge.s	rt
	move.b	#$01,$16(a4)
	rts

clrport	clr.w	$18(a4)
rt	rts

mt_toneportament
	move.b	$03(a4),d0
	beq.s	myslide
	move.b	d0,$17(a4)
	clr.b	$03(a4)
myslide	tst.w	$18(a4)
	beq.s	rt
	moveq	#0,d0
	move.b	$17(a4),d0
	tst.b	$16(a4)
	bne.s	mysub
	add.w	d0,$10(a4)
	move.w	$18(a4),d0
	cmp.w	$10(a4),d0
	bgt.s	myok
	move.w	$18(a4),$10(a4)
	clr.w	$18(a4)

myok	move.w	$10(a4),$06(a3)
	rts

mysub	sub.w	d0,$10(a4)
	move.w	$18(a4),d0
	cmp.w	$10(a4),d0
	blt.s	myok
	move.w	$18(a4),$10(a4)
	clr.w	$18(a4)
	move.w	$10(a4),$06(a3)
	rts

mt_vibrato	move.b	$03(a4),d0
		beq.s	vi
		move.b	d0,$1A(a4)

vi		move.b	$1B(a4),d0
		lea	sin(pc),a1
		lsr.w	#$02,d0
		and.w	#$1F,d0
		moveq	#0,d2
		move.b	0(a1,d0.w),d2
		move.b	$1A(a4),d0
		and.w	#$0F,d0
		mulu	d0,d2
		lsr.w	#$06,d2
		move.w	$10(a4),d0
		tst.b	$1B(a4)
		bmi.s	vibmin
		add.w	d2,d0
		bra.s	vib2

vibmin		sub.w	d2,d0
vib2		move.w	d0,$06(a3)
		move.b	$1A(a4),d0
		lsr.w	#$02,d0
		and.w	#$3C,d0
		add.b	d0,$1B(a4)
		rts

mt_pernop	move.w	16(a4),6(a3)
		rts

checkcom	move.w	2(a4),d0
		and.w	#$fff,d0
		beq.s	mt_pernop
		move.b	$2(a4),d0
		and.b	#$f,d0
		beq	mt_arpeggio
		cmp.b	#1,d0
		beq.s	mt_portaup
		cmp.b	#2,d0
		beq	mt_portadown
		cmp.b	#3,d0
		beq	mt_toneportament
		cmp.b	#4,d0
		beq	mt_vibrato
		cmp.b	#5,d0
		beq	mt_toneplusvolsl
		cmp.b	#6,d0
		beq	mt_vibratoplusvo
;;extra bits	cmp.b	#$e,d0
;;		beq	mt_e_commands
		move.w	16(a4),6(a3)
;;;xtra!	cmp.b	#7,d0
;;;		beq	mt_tremolo
		cmp.b	#$a,d0
		beq.s	mt_volumeslide
		rts

mt_volumeslide	moveq	#0,d0
		move.b	$03(a4),d0
		lsr.b	#4,d0
		tst.b	d0
		beq.s	voldown
		add.w	d0,$12(a4)
		cmpi.w	#$40,$12(a4)
		bmi.s	vol2
		move.w	#$40,$12(a4)
vol2		move.w	$12(a4),$08(a3)
		rts

voldown		moveq	#0,d0
		move.b	$03(a4),d0
		and.b	#$0F,d0
		sub.w	d0,$12(a4)
		bpl.s	vol3
		clr.w	$12(a4)
vol3		move.w	$12(a4),$08(a3)
		rts

mt_portaup	moveq	#0,d0
		move.b	$03(a4),d0
		sub.w	d0,$10(a4)
		move.w	$10(a4),d0
		and.w	#$0FFF,d0
		cmp.w	#$71,d0
		bpl.s	por2
		andi.w	#$F000,$10(a4)
		ori.w	#$71,$10(a4)
por2		move.w	$10(a4),d0
		and.w	#$0FFF,d0
		move.w	d0,$06(a3)
		rts


mt_toneplusvolsl	bsr	myslide
			bra.s	mt_volumeslide

mt_vibratoplusvo	bsr	vi
			bra.s	mt_volumeslide

mt_portadown	clr.w	d0
		move.b	$03(a4),d0
		add.w	d0,$10(a4)
		move.w	$10(a4),d0
		and.w	#$0FFF,d0
		cmp.w	#$0358,d0
		bmi.s	por3
		andi.w	#$F000,$10(a4)
		ori.w	#$0358,$10(a4)
por3		move.w	$10(a4),d0
		and.w	#$0FFF,d0
		move.w	d0,$06(a3)
		rts

checkcom2	move.b	$02(a4),d0
		and.b	#$0F,d0
		cmp.b	#$0D,d0
		beq.s	pattbreak
		cmp.b	#$0B,d0
		beq.s	posjmp
		cmp.b	#$0C,d0
		beq.s	setvol
		cmp.b	#$0F,d0
		beq.s	setspeed
		rts

pattbreak	st	break
		rts

posjmp		move.b	3(a4),d0
		subq.b	#1,d0
		move.b	d0,songpos
		st	break
		rts

setvol	moveq	#0,d0
	move.b	$03(a4),d0
	cmp.w	#$40,d0
	ble.s	vol4
	move.b	#$40,$03(a4)
vol4	move.b	$03(a4),$09(a3)
	move.b	$03(a4),$13(a4)
	rts

setspeed
	cmpi.b	#$1F,$03(a4)
	ble.s	sets
	move.b	#$1F,$03(a4)
sets	move.b	$03(a4),d0
	beq.s	rts2
	move.w	d0,speed
	clr.w	counter
rts2	rts



	SECTION DATA
counter	DC.W $00
speed	DC.W $06
songpos	DC.B $00
break	DC.B	0
pattpos	DC.W $00

dmacon		DC.W $00
samplestarts	DS.L $1F
voice1	DS.W 10
	DC.W $01
	DS.W 3
voice2	DS.W 10
	DC.W $02
	DS.W 3
voice3	DS.W 10
	DC.W $04
	DS.W 3
voice4	DS.W 10
	DC.W $08
	DS.W 3

sin	dc.b	$00,$18,$31,$4A,$61,$78,$8D,$A1,$B4,$C5,$D4,$E0,$EB,$F4,$FA,$FD
	dc.b	$FF,$FD,$FA,$F4,$EB,$E0,$D4,$C5,$B4,$A1,$8D,$78,$61,$4A,$31,$18

periods	dc.w	$0358,$0328,$02FA,$02D0,$02A6,$0280,$025C,$023A,$021A,$01FC,$01E0
	dc.w	$01C5,$01AC,$0194,$017D,$0168,$0153,$0140,$012E,$011D,$010D,$FE
	dc.w	$F0,$E2,$D6,$CA,$BE,$B4,$AA,$A0,$97,$8F,$87
	dc.w	$7F,$78,$71,$00,$00

mod		incbin	inter1.mod

image		incbin	pov.pi1
		incbin	erty.pi1

	DS.B	1280			; Workspace
workspc	DS.W	1





texttable	dc.l	page1
		dc.l	page2
		dc.l	page3
		dc.l	page4
		dc.l	page5
		dc.l	-1

text_pos		dc.l	middle_text
middle_text		
page1		dc.b	10,10,10,10,10
		dc.b	"    WE ARE BACK!",13,10
		dc.b	$ff

page2		dc.b	10
		dc.b	"     PERSISTENCE",13,10,10
		dc.b	"         OF",13,10,10
		dc.b	"       VISION",13,10,10,10
		dc.b	"      PRESENTS",13,10
		dc.b	$ff

page3		dc.b	10,10,10,10,10
		dc.b	"       AN STE",13,10
		dc.b	"     PRODUCTION",13,10
		dc.b	$ff

page4		dc.b	10,10,10
		dc.b	"      CODED BY",13,10
		dc.b	"    MAC SYS DATA",13,10,10
		dc.b	"       ART BY",13,10
		dc.b	"         OZ",13,10
		dc.b	$ff

page5		dc.b	10,10
		dc.b	'     "POVERTY"',13,10,10,10
		dc.b	"       ALIAS",13,10,10,10
		dc.b	"  OZ SLIDE SHOW 3",13,10
		dc.b	$7f

			even
font			incbin	e:\poverty\intro\oz_font.dat
			even


xpos		dc.b	0
ypos		dc.b	0






routine_table
		dc.l	scroll,140
		rept	8	;8 shades of colours
		dc.l	fadescrolldown,1
		endr

		dc.l	print_text,1
		rept	8
		dc.l	fadetextup,1
		endr
		dc.l	null,200
		rept	8
		dc.l	fadetextdown,1
		endr
		dc.l	reset_scroll_scrn,1

		rept	8
		dc.l	fadescrollup,1
		endr
		dc.l	scroll,140
		rept	8
		dc.l	fadescrolldown,1
		endr

		dc.l	print_text,1
		rept	8
		dc.l	fadetextup,1
		endr
		dc.l	null,200
		rept	8
		dc.l	fadetextdown,1
		endr
		dc.l	reset_scroll_scrn,1

		rept	8	;8 shades of colours
		dc.l	fadescrollup,1
		endr
		dc.l	scroll,140
		rept	8
		dc.l	fadescrolldown,1
		endr

		dc.l	print_text,1
		rept	8
		dc.l	fadetextup,1
		endr
		dc.l	null,200
		rept	8
		dc.l	fadetextdown,1
		endr
		dc.l	reset_scroll_scrn,1

		rept	8	;8 shades of colours
		dc.l	fadescrollup,1
		endr
		dc.l	scroll,140
		rept	8
		dc.l	fadescrolldown,1
		endr

		dc.l	print_text,1
		rept	8
		dc.l	fadetextup,1
		endr
		dc.l	null,200
		rept	8
		dc.l	fadetextdown,1
		endr
		dc.l	reset_scroll_scrn,1


		rept	8	;8 shades of colours
		dc.l	fadescrollup,1
		endr
		dc.l	scroll,220
		rept	8
		dc.l	fadescrolldown,1
		endr

		dc.l	print_text,1
		rept	8
		dc.l	fadetextup,1
		endr
		dc.l	null,350
		rept	8
		dc.l	fadetextdown,1
		endr
		dc.l	reset_scroll_scrn,1
	 	dc.l	null,22000

white	dc.w	0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1

	SECTION BSS
bssstart
screen_base	ds.l	1

sequencer_timer		ds.l	1
present_routine		ds.l	1
routine_offset		ds.l	1

black		ds.w	16

hard_addr	ds.l	1
screen_offset	ds.w	1
new_pal		ds.w	16
stack_save	ds.l	1
old_pal		ds.w	16
old_base	ds.l	1
oldtima		ds.l	1
main_timer	ds.w	1
org_rez		ds.b	1
		even
falcon_flag		ds.w	1
original_falcon_rez	ds.w	1
old_falcon_speaker	ds.b	1
old_falcon_proc		ds.b	1


texttimer	ds.w	1
texttableoffset	ds.w	1

		ds.b	256
screen		ds.b	32000*3		;workspace
		ds.b	160*3

text_screen_pos	ds.l	1
		ds.b	256
text_screen	ds.b	32000
bssend
stop