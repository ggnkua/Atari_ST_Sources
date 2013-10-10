*************************************************************************
*			PERSISTENCE OF VISION 149			*
*			-------------------------			*
*									*
* Written by: 	MAC SYS DATA of PERSISTENCE OF VISION			*
*		Falcon compatible menu					*
*									*
* Music by:	Unknown							*
*									*
*									*
* Grafix by: 	Ozymandias						*
*									*
*									*
* Date:		14-May-1995  to  Oct-1995				*
*									*
*			½ Persistence Of Vision 1994/1995		*
*									*
*************************************************************************
no=0
NO=no
yes=1
YES=yes


FINAL		equ	no	yes
		ifne	FINAL
		opt	d-
		endc


******************** POV WIDGET DOWNLOAD V3 (MIDI VERSION) **************
DOWNLOAD=no
		ifne	DOWNLOAD
		include	transmit.s		;include Transmit code
		org	$30000		;origin to start of code in memory
exec_addr
mycode
Code_Start
Exec_Addr

		endc
*************************************************************************


		opt	o+,w-



		ifeq	DOWNLOAD
begin		bra	start
	dc.b	"** JOHN COVE IS A COMPLETE WANKER **"
	even
		ds.l	100
ustack		ds.l	1

exec		pea	blank
		pea	blank
		pea	$200.w
		clr.w	-(sp)
		move.w	#$4b,-(sp)
		trap	#1
		lea	16(sp),sp
		pea	reset_me(pc)
		move.w	#$26,-(sp)
		trap	#14
reset_me	move.l	4.w,-(sp)
		rts

blank		dc.l	0

start		move.l	4(a7),a0
		move.l	#ustack,a7
		move.l	#start-begin+$100,-(a7)	;keep only EXEC routine
		move.l	a0,-(a7)
		clr.w	-(a7)
		move.w	#$4a,-(a7)
		trap	#1
		lea	12(a7),a7
		endc


		jsr	set_up


main_loop
		jsr	vsync
		jsr	set_screen
;	move.w	#$123,$ffff8240.w

		eor.w	#(21*2),off_ptr
		lea	offsets,a6
		add.w	off_ptr,a6
		jsr	restore_sprites

		jsr	display_sprites

		jsr	scroll

		tst.w	falcon030
		beq.s	.nofalcon
		bsr	play
.nofalcon

;	move.w	pic+2,$ffff8240.w

		moveq	#0,d0
		move.b	$fffffc02.w,d0
		cmp.b	#$1d,d0
		bne.s	.k1
		bset	#2,key
.k1		cmp.b	#$9d,d0
		bne.s	.k2
		bclr	#2,key
.k2		cmp.b	#$38,d0
		bne.s	.k3
		bset	#3,key
.k3		cmp.b	#$b8,d0
		bne.s	.k4
		bclr	#3,key
.k4		move.b	d0,key+1

		move.w	key,d0

		IFEQ	FINAL
		cmp.w	#1,d0		;escape
		beq	exit
		endc

		cmp.w	#11,d0		;0 key
		beq	zero

		cmp.w	#$70,d0		;keypad 0
		beq	zero
	

		cmp.w	#$c53,d0
		beq	do_reset

		lea	demo_keys,a4
.next		move.w	(a4)+,d1
		bmi	main_loop
		cmp.b	d1,d0
		beq.s	.run
		bra.s	.next
.run		move.w	#$2300,sr
		lsr.w	#8,d1
		and.w	#$f,d1
		lsl.w	#2,d1
		lea	filename_table,a3
		move.l	(a3,d1.w),a3
		lea	$200.w,a1
		REPT	4
		move.l	(a3)+,(a1)+
		ENDR

assem		tst.w	hertz_toggle
		beq.s	hz50
		and.b	#%11111101,$ffff820a.w	;60Hz
hz50

		move.b	#8,$fffffc02.w

		tst.w	falcon030
		beq.s	.shutdownst

* Must be a Falcon so shut Falcon 030 specific stuff down
		bsr	shutdownfalcon
		bra.s	.overststuff

.shutdownst	bsr	shutdownst
.overststuff
		move.l	old_base,d0
		lsr.l	#8,d0
		lea	$ffff8201.w,a0
		movep.w	d0,(a0)


		movem.l	oldstpal,d0-d7
		movem.l	d0-d7,$ffff8240.w

		move.b	#8,$fffffc02.w

		move.b	old484,$484.w


		ifeq	DOWNLOAD
		jsr	user_mode
		endc

		ifeq	DOWNLOAD
		IFNE	FINAL
		bra	exec
		ENDC
		ENDC

		clr.w	-(sp)
		trap	#1

zero		tst.w	hertz_toggle
		bne	main_loop
		eor.w	#$012,font_pal
		eor.w	#-1,hertz_switch
		move.w	#10,hertz_toggle
		bra	main_loop

do_reset
	move.l	4.w,a0
	jmp	(a0)

exit
		tst.w	falcon030
		beq.s	.shutdownst

* Must be a Falcon so shut Falcon 030 specific stuff down
		bsr	shutdownfalcon
		bra.s	.overststuff

.shutdownst	bsr	shutdownst
.overststuff

		move.l	old_base,d0
		lsr.l	#8,d0
		lea	$ffff8201.w,a0
		movep.w	d0,(a0)


		movem.l	oldstpal,d0-d7
		movem.l	d0-d7,$ffff8240.w

		move.b	#8,$fffffc02.w
		move.b	old484,$484.w
		jsr	user_mode
		clr.w	-(sp)
		trap	#1



shutdownst
		bsr	vsync
		move.w	#$2700,sr
		lea	store,a0
		move.l	(a0)+,$70.w
		move.l	(a0)+,$120.w
		move.b	(a0)+,$fffffa07.w
		move.b	(a0)+,$fffffa09.w
		move.b	(a0)+,$fffffa0f.w
		move.b	(a0)+,$fffffa13.w
		move.b	(a0)+,$fffffa17.w
		move.b	(a0)+,$fffffa1b.w
		move.b	(a0)+,$fffffa21.w
		move.w	#$2300,sr

		lea	$ffff8800.w,a0
		move.l	#$8080000,(a0)
		move.l	#$9090000,(a0)
		move.l	#$a0a0000,(a0)
		move.b	oldstrez,$ffff8260.w

		rts

shutdownfalcon
		jsr	stopmod
		move.w	#$2700,sr
		lea	store,a0
		move.l	(a0)+,$70.w
		move.l	(a0)+,$120.w
		move.b	(a0)+,$fffffa07.w
		move.b	(a0)+,$fffffa09.w
		move.b	(a0)+,$fffffa0f.w
		move.b	(a0)+,$fffffa13.w
		move.b	(a0)+,$fffffa17.w
		move.b	(a0)+,$fffffa1b.w
		move.b	(a0)+,$fffffa21.w
		move.w	#$2300,sr

		move.w	org_overscanbtm,$ffff82aa.w	;bottom overscan

		move.w	org_falcon_rez,-(sp)
		move.w	#$58,-(sp)	;set_original_rez
		trap	#14
		addq.l	#4,sp

		rts




***************
* Subroutines *
***************
WIDTH=5
DEPTH=25
scroll	move.l	scr_now,a0
	lea	202*160(a0),a0
	add.l	last_scroll,a0
	movem.l	black,d0-d7
	movem.l	d0-d7,-320(a0)
	movem.l	d0-d7,-320+32(a0)
	movem.l	d0-d7,-320+64(a0)
	movem.l	d0-d7,-320+96(a0)
	movem.l	d0-d7,-320+128(a0)
	movem.l	d0-d7,-160(a0)
	movem.l	d0-d7,-160+32(a0)
	movem.l	d0-d7,-160+64(a0)
	movem.l	d0-d7,-160+96(a0)
	movem.l	d0-d7,-160+128(a0)
	movem.l	d0-d7,(a0)
	movem.l	d0-d7,32(a0)
	movem.l	d0-d7,64(a0)
	movem.l	d0-d7,96(a0)
	movem.l	d0-d7,128(a0)
	movem.l	d0-d7,160(a0)
	movem.l	d0-d7,160+32(a0)
	movem.l	d0-d7,160+64(a0)
	movem.l	d0-d7,160+96(a0)
	movem.l	d0-d7,160+128(a0)
	lea	160*DEPTH(a0),a0
	movem.l	d0-d7,-320(a0)
	movem.l	d0-d7,-320+32(a0)
	movem.l	d0-d7,-320+64(a0)
	movem.l	d0-d7,-320+96(a0)
	movem.l	d0-d7,-320+128(a0)
	movem.l	d0-d7,-160(a0)
	movem.l	d0-d7,-160+32(a0)
	movem.l	d0-d7,-160+64(a0)
	movem.l	d0-d7,-160+96(a0)
	movem.l	d0-d7,-160+128(a0)
	movem.l	d0-d7,(a0)
	movem.l	d0-d7,32(a0)
	movem.l	d0-d7,64(a0)
	movem.l	d0-d7,96(a0)
	movem.l	d0-d7,128(a0)
	movem.l	d0-d7,160(a0)
	movem.l	d0-d7,160+32(a0)
	movem.l	d0-d7,160+64(a0)
	movem.l	d0-d7,160+96(a0)
	movem.l	d0-d7,160+128(a0)
	move.w	sine_number,d0
	cmp.w	#54-1,d0
	blt	.no_reset
	moveq	#0,d0
	move.w	d0,sine_number
.no_reset
	add.w	d0,d0
	lea	sine_table,a1
	add.w	d0,a1
	move.w	(a1),d0
	lsl.l	#5,d0
	move.w	d0,d1
	lsl.l	#2,d0
	add.l	d1,d0
	addq.w	#1,sine_number
	and.l	#$ffff,d0
	move.l	d0,last_scroll

	move.l	scr_now,a1
	lea	202*160(a1),a1
	add.l	d0,a1
	lea	font_offsets,a2
	lea	font,a3
	move.l	scroll_pointer,a4
	move.l	a4,a5
	moveq	#0,d4
	moveq	#40,d5
	move.w	char_offset,d6
next_char
	move.b	(a5),d7		;get a letter
	sub.b	#32,d7
	ext.w	d7

	moveq	#0,d0
	move.l	a3,a0
	move.b	(a2,d7),d0
	mulu	#(DEPTH*WIDTH)*4,d0
	add.l	d0,a0
	move.w	d6,d0
	mulu	#(DEPTH*4),d0
	add.l	d0,a0
.column
OFF	set	0
	REPT	DEPTH
	move.l	(a0)+,d0
	movep.l	d0,OFF(a1)
OFF	set	OFF+160
	ENDR

	subq.w	#1,d5
	beq	.finish		;have we done 40 columns?

	addq.w	#1,a1		;lower byte of word
	tst.w	d4
	beq	.skip		;if D4=0 then do next word
	addq.w	#6,a1		;else goto next word on screen
.skip	not.w	d4
	addq.w	#1,d6		;character offset
	cmp.w	#WIDTH,d6
	blt	.column

	clr.w	d6

	addq.w	#1,a5		;scroll pointer
	tst.b	(a5)		;is end of text?
	bpl	next_char	;NO!
	lea	scroll_text,a5	;do reset scrolline
	bra	next_char

.finish
;we have done 40 columns so now check for end of letter...
	addq.w	#1,char_offset
	cmp.w	#WIDTH,char_offset
	blt	.end

	clr.w	char_offset

	addq.w	#1,a4
	tst.b	(a4)
	bpl	.end
	lea	scroll_text,a4
.end	move.l	a4,scroll_pointer
	rts

display_sprites
	lea	path,a3
	lea	sprite_pos+(21*2),a4
	lea	sprite_nums+(21*2),a5
	moveq	#21-1,d7
.loop
	move.w	-(a5),d0
	move.w	-(a4),d4

	move.l	scr_now,a0
	lea	sprite_data,a1
	lea	sprite_mask,a2
	lsl.w	#6,d0
	add.w	d0,a1
	add.w	d0,a2
	move.w	(a3,d4),d1
	move.w	2(a3,d4),d2
	add.w	d2,a1
	add.w	d2,a2
	move.w	d1,(a6)+
	add.w	d1,a0
	and.w	#1,d1
	beq	.even
	REPT	8
	movep.l	(a0),d0
	and.l	(a2)+,d0
	or.l	(a1)+,d0
	movep.l	d0,(a0)
	movep.l	7(a0),d0
	and.l	(a2)+,d0
	or.l	(a1)+,d0
	movep.l	d0,7(a0)
	lea	160(a0),a0
	ENDR
	bra	.cont
.even
	REPT	8
	movep.l	(a0),d0
	and.l	(a2)+,d0
	or.l	(a1)+,d0
	movep.l	d0,(a0)
	movep.l	1(a0),d0
	and.l	(a2)+,d0
	or.l	(a1)+,d0
	movep.l	d0,1(a0)
	lea	160(a0),a0
	ENDR

.cont	addq.w	#4,d4
	and.w	#$ffc,d4
	move.w	d4,(a4)
	dbf	d7,.loop
	rts

restore_sprites
	move.l	a6,-(sp)
	move.l	scr_now,a2
	lea	pic+34,a3
	moveq	#21-1,d7
.loop
	move.l	a2,a0
	move.l	a3,a1
	move.w	(a6)+,d0
	add.w	d0,a0
	add.w	d0,a1
	and.w	#1,d0
	beq	.even
	REPT	8
	movep.l	(a1),d0
	movep.l	d0,(a0)
	movep.l	7(a1),d0
	movep.l	d0,7(a0)
	lea	160(a0),a0
	lea	160(a1),a1
	ENDR
	bra	.cont
.even
	REPT	8
	movep.l	(a1),d0
	movep.l	d0,(a0)
	movep.l	1(a1),d0
	movep.l	d0,1(a0)
	lea	160(a0),a0
	lea	160(a1),a1
	ENDR
.cont	dbf	d7,.loop
	move.l	(sp)+,a6
	rts




















vsync	move.w	#$ffff,vsync_flag
vs	tst.w	vsync_flag
	bne.s	vs
	rts

flush	btst	#0,$fffffC00.w	;flush keyboard
	beq	flush2
	move.b	$fffffc02.w,d0
	bra.s	flush
flush2	rts


set_up
**** First clear BSS as most packers don't
		lea	bss_start,a0
		move.l	#bss_end-bss_start,d0
		lsr.w	#2,d0
.clear_bss	clr.l	(a0)+
		sub.l	#1,d0
		bne.s	.clear_bss

		IFEQ	DOWNLOAD
		clr.l	-(sp)		;supervisor
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,stack_save
		endc
 
		bsr	test_4_falcon

		move.b	#$12,$fffffc02.w

		move.w	#3,-(sp)	;get screen base
		trap	#14
		addq.l	#2,sp
		move.l	d0,old_base

		movem.l	$ffff8240.l,d0-d7
		movem.l	d0-d7,oldstpal

		move.l	#screen,d0	;calc our screen space
		clr.b	d0
		move.l	d0,scr_now
		move.l	d0,d1
		add.l	#46080,d1
		eor.l	d0,d1
		move.l	d1,scr_xor

		bsr	set_screen
		bsr	set_screen

		clr.w	off_ptr
		lea	offsets,a0
clr		clr.b	(a0)+
		eor.w	#$700,$ffff8240.w
		cmp.l	#s,a0
		bne.s	clr
		move.l	#160*204,last_scroll
		move.b	$484.w,old484
		clr.b	$484.w

		movem.l	pic+2,d0-d7		;set ST/STE palette
		movem.l	d0-d7,$ffff8240.w

*Store system settings before starting any interrupts
		ori.w	#$700,sr
		lea	store,a0
		move.l	$70.w,(a0)+
		move.l	$120.w,(a0)+
		move.b	$fffffa07.w,(a0)+
		move.b	$fffffa09.w,(a0)+
 		move.b	$fffffa0f.w,(a0)+
 		move.b	$fffffa13.w,(a0)+
 		move.b	$fffffa17.w,(a0)+
		move.b	$fffffa1b.w,(a0)+
		move.b	$fffffa21.w,(a0)+


********************************************************************
* Check for Falcon, if so do Falcon rez stuff
		tst.w	falcon030
		beq	.nofalcon

		move.w	#-1,-(sp)
		move.w	#$58,-(sp)	;get_original_rez
		trap	#14
		addq.l	#4,sp
		move.w	d0,org_falcon_rez

		move.w	$ffff82aa.w,org_overscanbtm	;bottom overscan

;This bit will automatically set the falcon video res but it will
;preserve the RGB/VGA mode.
;			  fedcba9876543210
;Octet de poids faible :    S O P V 8 N N N
		move.w	d0,d1
		and.w	#%00010000,d1
		move.w	#%0000000010100010,d0
		or.w	d1,d0
		move.w	d0,-(sp)
		move.w	#$58,-(sp)
		trap	#14
		addq.l	#4,sp

;Octet de poids faible :    S O P V 8 N N N
;	N  Bits par pixels :	4 -> 16 bits	65536 colours
;				3 -> 8  bits	256 colours
;				2 -> 4  bits	16 colours
;				1 -> 2  bits	1 colours
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


		move.w	#48,$ffff82aa.w	;overscan bottom by x number of lines

		jsr	init_mod	;falcon 030


		clr.b	$fffffa1b.w	;stop timerb occuring
		clr.b	$fffffa21.w	;clear timerb data
		move.b	#1,$fffffa07.w
		clr.b	$fffffa09.w

		move.l	#falconvbl,$70.w
		move.l	#falcontimerb,$120.w
		move.b	#199,$fffffa21.w

		bclr	#0,$fffffa0f.w
		bset	#0,$fffffa13.w
		bclr	#3,$fffffa17.w	;enable AUTO ISR enable after RTE
		move.b	#8,$fffffa1b.w
		move.w	#$2300,sr

		bra.s	.overststuff
********************************************************************


.nofalcon
* ST/STE specific stuff...
		move.b	$ffff8260.w,oldstrez
		clr.b	$ffff8260.w		;low rez

		movem.l	black,d0-d7		;black out colours
		movem.l	d0-d7,$ffff8240.w

		clr.b	$fffffa1b.w	;stop timerb occuring
		clr.b	$fffffa21.w	;clear timerb data
		move.b	#1,$fffffa07.w
		clr.b	$fffffa09.w

		move.l	#st_vbl,$70.w
		move.l	#sttimerb,$120.w
		move.b	#199,$fffffa21.w

		bclr	#0,$fffffa0f.w
		bset	#0,$fffffa13.w
		bclr	#3,$fffffa17.w	;enable AUTO ISR enable after RTE
		move.b	#8,$fffffa1b.w
		move.w	#$2300,sr



.overststuff
		jsr	show_pic

		rts













test_4_falcon
*** Detect Falcon computer code...
***
*** Written by MAC SYS DATA of PERSISTENCE OF VISION
***
***

; Execute in Supervisor mode

	move.l	$5a0,a0
	cmp.l	#0,a0
	beq.s	.nocookiejar
	move.l	$14(a0),d0	;get video shifter type?
	tst.l	d0
	beq.s	.notdma
	cmp.l	#$30000,d0
	bne.s	.nocookiejar
	move.w	#-1,falcon030
.notdma
.nocookiejar
	rts








user_mode:
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts




set_screen
	move.l	scr_now,d0
	move.l	scr_xor,d1
	eor.l	d1,d0
	move.l	d0,scr_now
	lsr.l	#8,d0
	lea	$ffff8201.w,a0
	movep.w	d0,(a0)
	rts


show_pic
	lea	pic+34,a0	;pic top left
	move.l	scr_now,a1
	move.w	#20-1,d5
words:	move.l	#%10000000000000001000000000000000,d1
	move.w	#16-1,d7
bit:	move.w	#199,d6
lines:	move.l	(a0),d0
	and.l	d1,d0
	move.l	d0,(a1)
	move.l	4(a0),d0
	and.l	d1,d0
	move.l	d0,4(a1)
	lea	160(a0),a0
	lea	160(a1),a1
	move.w	#7,d2
.loop	dbf	d2,.loop
	dbf	d6,lines
	lea	-32000(a0),a0
	lea	-32000(a1),a1
	move.l	d1,d0
	lsr.l	#1,d0
	or.l	d0,d1
	dbf	d7,bit
	addq.w	#8,a0
	addq.w	#8,a1
	dbf	d5,words
	move.l	scr_now,a0
	move.l	a0,a1
	add.l	#46080,a1
	move.w	#32000/4-1,d0
.loop2	move.l	(a0)+,(a1)+
	dbf	d0,.loop2
	rts

v_sync:	movem.l	d0-d3/a0-a3,-(sp)
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d0-d3/a0-a3
	rts

clear_below_screen:
	lea	s+(160*42),a0
	move.l	#(46080+46080)/4,d0
.clr	clr.l	(a0)+
	subq.l	#1,d0
	bne.s	.clr
	rts




*********
* ISRs  *
*********
st_vbl
	clr.b	$fffffa1b.w
	movem.l	d0-d7/a0-a6,-(sp)	;preserve regs
	movem.l	pic+2,d0-d7
	movem.l	d0-d7,$ffff8240.w

	jsr	tune+$98
exisr	clr.w	vsync_flag
	movem.l	(sp)+,d0-d7/a0-a6
	move.b	#199,$fffffa21.w
	move.b	#8,$fffffa1b.w
	tst.w	hertz_toggle
	bne.s	.dec
	rte
.dec	sub.w	#1,hertz_toggle
	rte

sttimerb
	clr.b	$fffffa1b.w
	movem.l	d0-d6/a0-a1,-(sp)
	lea	$ffff8240.w,a1
	lea	$ffff8209.w,a0
	moveq	#0,d0
	move.b	(a0),d0
	sub.b	#92,d0
	jmp	nops(pc,d0)
nops
	REPT	78
	nop
	ENDR
	clr.b	$ffff820a.w
	REPT	31-26
	nop
	ENDR
	movem.l	font_pal+4,d0-d6	;72
	move.b	#2,$ffff820a.w		;8
	move.l	font_pal,(a1)
	movem.l	d0-d6,4(a1)
	movem.l	(sp)+,d0-d6/a0-a1
	rte






falconvbl
		movem.l	d0-d7,-(sp)
		movem.l	pic+2,d0-d7
		movem.l	d0-d7,$ffff8240.w
		movem.l	(sp)+,d0-d7
		move.b	#8,$fffffa1b.w
		clr.w	vsync_flag
		tst.w	hertz_toggle
		bne.s	.dec
		rte
.dec		sub.w	#1,hertz_toggle
		rte


falcontimerb	clr.b	$fffffa1b.w
		movem.l	d0-d7,-(sp)
		movem.l	font_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w
		movem.l	(sp)+,d0-d7
		rte











******************************
init_mod	moveq	#1,d0
player		movem.l	a0-a6/d0-d7,-(sp)
		TST.W	D0
		BEQ.S	L0001
		BSR	L00A0
L0001		BSR	L009E
		BSR	L0021
		bsr	init
		BSR	L0024
		bsr	L0002
		MOVEM.L	(sp)+,A0-A6/D0-D7
		rts

L0002		lea	$FFFF8930.W,a0
		MOVE.L	(a0),L00AA
		move.l	#$902000,(a0)
		move.w	4(a0),L00AB
		move.w	#$101,4(a0)
		move.w	10(a0),L00AC
L0003		RTS

stopmod		lea	$FFFF8930.W,A0
		move.l	L00AA,(A0)
		move.w	L00AB,4(A0)
		move.w	L00AC,10(A0)
		BCLR	#0,$FFFFFA07.W
		BCLR	#0,$FFFFFA13.W
		MOVE.B	(A0)+,$FFFFFA1B.W
		MOVE.B	(A0)+,$FFFFFA21.W
L0006		RTS

play		lea	L00B8,A0
		lea	L00B7,A1
		lea	$FFFFA202.W,A3
		lea	3(A3),A4
		lea	4(A3),A5
		CLR.W	(A5)
		MOVEQ	#3,D6
L0009		MOVE.B	19(A1),(A4)
		CLR.W	(A5)
		move.w	16(A1),D0
		LEA	(0,A0,D0.W*4),A2
		MOVE.B	1(A2),(A4)
		move.w	2(A2),(A5)
		MOVEQ	#0,D0
L000A		BTST	#0,(A3)
		beq.s	L000A
		move.w	(A5),D0
		tst.W	20(A1)
		beq.s	L000B
		clr.W	20(A1)
		bra.S	L000E
L000B		MOVEM.L	(A1),D1-D4
		add.L	D0,D1
		move.l	D1,D0
		sub.L	D2,D0
		bls.S	L000D
		cmp.L	#2,D4
		bne.s	L000C
		move.l	D2,D1
		bra.S	L000D
L000C		MOVE.L	D3,D1
		DIVUL.L	D4,D4:D0
		add.L	D4,D1
L000D		MOVE.L	D1,(A1)
L000E		MOVEQ	#0,D0
L000F		BTST	#0,(A3)
		beq.s	L000F
		move.w	(A5),D0
		addQ.L	#2,D0
L0010		BTST	#0,(A3)
		beq.s	L0010
		move.w	(A5),D7
		move.w	D7,L00B0
		moveM.L	(A1),D1-D4
		move.l	D2,D5
		sub.L	D1,D5
		cmp.L	D5,D0
		bls.S	L0014
		sub.L	D5,D0
		move.w	D5,D7
		moveA.L	D1,A2
		bsr.S	L0016
		cmp.L	#2,D4
		beq.s	L0012
		cmp.L	D4,D0
		BCS.S	L0011
		move.l	D4,D0
L0011		MOVE.W	D0,D7
		moveA.L	D3,A2
		bsr.S	L0016
		bra.S	L0015
L0012		CLR.B	(A4)
		move.w	#2,(A5)
L0013		BTST	#1,(A3)
		beq.s	L0013
		clr.W	(A5)
		NOP
		clr.W	(A5)
		bra.S	L0015
L0014		MOVE.W	D0,D7
		moveA.L	D1,A2
		bsr.S	L0016
		clr.b	(A4)
		clr.W	(A5)
L0015		ADDA.W	#$16,A1
		addQ.W	#1,L00B1
		DBF	D6,L0009
		bsr	L0026
		rts

L0016		CLR.B	(A4)
		move.w	D7,(A5)
		beq.s	L0019
		lsr.W	#1,D7
L0017		BTST	#1,(A3)
		beq.s	L0017
L0018		MOVE.W	(A2)+,(A5)
		DBF	D7,L0018
L0019		RTS

init
		lea	mod,a0
		lea	$3b6(a0),a1
		lea	$86(a1),a2
incrcal		moveq	#30,d0
		moveq	#1,D3
		cmp.l	#"M.K.",1080(a0)
		beq.s	L001B
		cmp.l	#"FLT4",1080(A0)
		beq.s	L001B
		lea	470(a0),a1
		lea	130(a1),a2
		moveq	#$E,D0
		moveq	#0,d3

L001B		MOVE.L	A1,L00B3
		move.l	A2,L00B4
		move.w	D0,L00B5
		moveA.L	L00B3,A1
		moveA.L	A1,A2
		addQ.L	#2,A1

		moveq	#$7f,d0
		moveq	#0,d1
L001C		move.b	(a1)+,d2
		cmp.b	D2,D1
		BCC.S	L001D
		move.b	D2,D1
L001D		DBF	D0,L001C

		cmp.b	1(A2),D1
		BCC.S	L001E
		clr.b	1(A2)
L001E		ADDQ.W	#1,D1
		mulu.L	#$400,D1
		moveA.L	L00B4,A1
		lea	0(A1,D1.L),a1
		add.w	#$2a,a0
		lea	L00B6,a2
		move.w	L00B5,d0

lop3		MOVE.L	A1,(A2)+
		moveQ	#0,D1
		move.w	(A0),D1
		add.L	D1,D1
		addA.L	D1,A1
		tst.W	D3
		bne.s	L0020
		lsr	4(A0)
L0020		ADDA.W	#$1E,A0
		DBF	D0,lop3
		rts

L0021		LEA	L00B8,A0
		move.w	#$4F,D0
L0022		clr.l	(a0)+
		DBF	D0,L0022
		move.w	#$31F,D0
		moveQ	#$50,D1
		move.l	#$24665268,D2
L0023		MOVE.L	D2,D4
		DIVU.L	D1,D4
		move.l	D4,(A0)+
		addQ.L	#1,D1
		DBF	D0,L0023
		rts

L0024		LEA	L00AA,A0
		lea	L00B7,A1
		move.w	#3,D0
L0025		MOVE.L	A0,(A1)
		move.l	A0,4(A1)
		clr.l	8(a1)
		move.l	#2,12(A1)
		move.w	#1,20(A1)
		addA.W	#$16,A1
		DBF	D0,L0025
		rts

L0026		lea	mod,a0
		addq.w	#1,L00BD
		move.w	L00BD,d0
		cmp.w	L00BE,d0
		BCS.S	L0027
		clr.w	L00BD
		tst.B	L00C7
		beq.s	L002A
		bsr.S	L0028
		bra	L002C
L0027		BSR.S	L0028
		bra	L0031

L0028		moveq	#4-1,d6
		lea	voice1,a6
		lea	L00B7,A5
L0029		BSR	L0040
		addA.W	#$2C,A6
		addA.W	#$16,A5
		DBF	D6,L0029
		rts

L002A		LEA	12(A0),A3
		moveA.L	L00B4,A0
		moveQ	#0,D1
		moveA.L	L00B3,A2
		move.w	L00C1,D0
		move.b	2(A2,D0.W),D1
		ASL.L	#8,D1
		ASL.L	#2,D1
		move.w	L00C0,D0
		EXT.L	D0
		add.L	D0,D1
		clr.w	L00BF
		moveQ	#0,D6
		lea	L00B7,A5
		lea	voice1,A6
L002B		MOVE.W	D6,D2
		bsr	L0032
		moveQ	#0,D0
		move.b	19(A6),D0
		move.w	D0,18(A5)
		addA.W	#$16,A5
		addA.W	#$2C,A6
		addQ.W	#1,D6
		cmp.W	#4,D6
		bne.s	L002B
L002C		ADDI.W	#$10,L00C0
		move.b	L00C6,D0
		beq.s	L002D
		move.b	D0,L00C7
		clr.b	L00C6
L002D		TST.B	L00C7
		beq.s	L002E
		subQ.B	#1,L00C7
		beq.s	L002E
		subI.W	#$10,L00C0
L002E		TST.B	L00C4
		beq.s	L002F
		SF	L00C4
		moveQ	#0,D0
		move.b	L00C2,D0
		lsl.W	#4,D0 
		move.w	D0,L00C0
		clr.b	L00C2 
L002F		CMPI.W	#$400,L00C0
		bne.s	L0031
L0030		MOVEQ	#0,D0
		move.b	L00C2,D0
		lsl.W	#4,D0
		move.w	D0,L00C0
		clr.b	L00C2
		clr.b	L00C3
		addQ.W	#1,L00C1
		andI.W	#$7F,L00C1
		move.w	L00C1,D1
		moveA.L	L00B3,A0
		cmp.b	(A0),D1
		BCS.S	L0031
		moveQ	#0,D1
		move.b	1(A0),D1
		move.w	D1,L00C1
L0031		TST.B	L00C3
		bne.s	L0030
		rts
L0032		TST.L	(A6)
		bne.s	L0033
		bsr	L0043
L0033		MOVE.L	0(A0,D1.L),(A6)
		addQ.L	#4,D1
		btst	D2,L00C8
		beq	nop
		moveQ	#0,D2
		move.b	2(A6),D2
		and.B	#$F0,D2
		lsr.B	#4,D2
		move.b	(A6),D0
		and.B	#$F0,D0
		OR.B	D0,D2
		tst.B	D2
		beq	L0036
		moveQ	#0,D3
		lea	L00B6,A1
		move.w	D2,D4
		move.b	D2,43(A6)
		subQ.L	#1,D2
		lsl.L	#2,D2
		mulu	#$1E,D4
		move.l	0(A1,D2.L),4(A6)
		move.w	0(A3,D4.L),8(A6)
		move.w	0(A3,D4.L),40(A6)
		move.b	2(A3,D4.L),18(A6)
		move.b	3(A3,D4.L),19(A6)
		move.w	4(A3,D4.L),D3
		beq.s	L0035
		move.l	4(A6),D2
		ASL.W	#1,D3
		add.L	D3,D2
		move.l	D2,10(A6)
		move.l	D2,36(A6)
		moveM.W	4(A3,D4.L),D2/D0
		add.W	D2,D0
		move.w	40(A6),D3
		cmp.W	D3,D0
		bls.S	L0034
		move.w	D3,8(A6)
		sub.W	D3,D0
		sub.W	D0,D2
		move.w	D2,14(A6)
		bra.S	L0036
L0034		MOVE.W	D0,8(A6)
		move.w	D2,14(A6)
		bra.S	L0036
L0035		MOVE.L	4(A6),D2
		move.l	D2,10(A6)
		move.l	D2,36(A6)
		move.w	6(A3,D4.L),14(A6)
L0036		MOVE.W	(A6),D0
		and.W	#$FFF,D0
		beq	L0084
		move.w	2(A6),D0
		and.W	#$FF0,D0
		cmp.W	#$E50,D0
		beq.s	L0037

		move.b	2(A6),D0
		and.B	#$F,D0
		cmp.b	#3,D0
		beq.s	L0038
		cmp.b	#5,D0
		beq.s	L0038
		cmp.b	#9,D0
		bne.s	L0039
		bsr	L0084
		bra.S	L0039
L0037		BSR	L0089
		bra.S	L0039
L0038		BSR	L0050
		bra	L0084
L0039		MOVEM.L	A0-A1/D0-D1,-(A7)
		move.w	(A6),D1
		and.w	#$FFF,D1
		lea	periods,A1
		moveQ	#0,D0
		moveQ	#$24,D7
L003A		CMP.W	0(A1,D0.W),D1
		BCC.S	L003B
		addQ.L	#2,D0
		DBF	D7,L003A
L003B		MOVEQ	#0,D1
		move.b	18(A6),D1
		mulu	#$4A,D1
		addA.L	D1,A1
		move.w	0(A1,D0.W),16(A6)
		moveM.L	(A7)+,A0-A1/D0-D1
		move.w	2(A6),D0
		and.W	#$FF0,D0
		cmp.W	#$ED0,D0
		beq	L0084
		btst	#2,30(A6)
		bne.s	L003C
		clr.b	27(A6)
L003C		BTST	#6,30(A6)
		bne.s	L003D
		clr.b	29(A6)
L003D		MOVE.W	#1,20(A5)
		move.l	4(A6),D0
		bne.s	L003E
		move.l	#periods,D0
		move.l	D0,(A5)
		move.l	D0,4(A5)
		moveQ	#2,D0
		move.l	D0,12(A5)
		clr.L	10(A6)
		move.w	#1,14(A6)
		bra.S	L003F
L003E		MOVE.L	D0,(A5)
		moveQ	#0,D2
		move.w	8(A6),D2
		add.L	D2,D2
		add.L	D2,D0
		move.l	D0,4(A5)
		move.l	10(A6),8(A5)
		moveQ	#0,D0
		move.w	14(A6),D0
		add.L	D0,D0
		move.l	D0,12(A5)
L003F		MOVE.W	16(A6),D0
		move.w	D0,16(A5)
		ST	42(A6)
		move.w	20(A6),D0
		OR.W	D0,L00BF
		bra	L0084
L0040		BSR.S	checkcom
		moveQ	#0,D0
		move.b	19(A6),D0
		move.w	D0,18(A5)
		rts

checkcom	BSR	L009B

		move.w	2(a6),d0
		and.w	#$fff,d0
		beq.s	nop
		move.b	2(a6),d0
		and.b	#$f,d0
		tst.b	d0
		beq	arpeggio
		cmp.b	#1,d0
		beq	portup
		cmp.b	#2,d0
		beq	portdown
		cmp.b	#3,d0
		beq	myport
		cmp.b	#4,d0
		beq	vib
		cmp.b	#5,d0
		beq	port_toneslide
		cmp.b	#6,d0
		beq	vib_toneslide
		cmp.b	#$e,d0	?
		beq	L0085	?
		move.w	16(a6),16(a5)
		cmp.b	#7,D0	?
		beq	L0068	?
		cmp.b	#$a,d0
		beq	volslide
nop		rts

L0043		MOVE.W	16(A6),16(A5)
		rts


volslide	moveq	#0,d0
		move.b	3(a6),d0
		lsr.b	#4,d0
		tst.b	d0
		beq.s	voldown
L0078		add.w	d0,18(a6)
		cmp.w	#$40,18(a6)
		bmi.s	vol2
		move.w	#$40,18(a6)
vol2		move.w	18(a6),d0
		rts
voldown		moveq	#0,d0
		move.b	3(a6),d0
		and.b	#$f,d0
L007B		sub.w	d0,18(a6)
		bpl.s	vol3
		clr.w	18(a6)
vol3		move.w	18(a6),d0
		rts




arpeggio		MOVEQ	#0,D0
		move.w	L00BD,D0
	DIVS	#3,D0
	SWAP	D0
		cmp.W	#1,D0
		beq.s	L0045
		cmp.W	#2,D0
		beq.s	L0046
		move.w	16(A6),D2
		bra.S	L0049
L0045		MOVEQ	#0,D0
		move.b	3(A6),D0
		lsr.B	#4,D0
		bra.S	L0047
L0046		MOVEQ	#0,D0
		move.b	3(A6),D0
		and.B	#$F,D0
L0047		ASL.W	#1,D0
		moveQ	#0,D1
		move.b	18(A6),D1
		mulu	#$4A,D1
		lea	periods,A0
		addA.L	D1,A0
		moveQ	#0,D1
		move.w	16(A6),D1
		moveQ	#$24,D7
L0048		MOVE.W	0(A0,D0.W),D2
		cmp.W	(A0),D1
	BCC.S	L0049
		addQ.L	#2,A0
	DBF	D7,L0048
		rts
L0049		MOVE.W	D2,16(A5)
		rts
L004A		TST.W	L00BD
		bne	nop
		move.b	#$F,L00C5

portup		moveq	#0,d0
		move.b	3(a6),d0
 and.b	L00C5,d0
 move.b	#$ff,L00C5
		sub.w	d0,16(a6)
		move.w	16(a6),d0
		and.w	#$fff,d0
		cmp.w	#$71,d0
		bpl.s	por2
		and.w	#$f000,16(a6)
		or.w	#$71,16(a6)
por2		move.w	16(a6),d0
		and.w	#$fff,d0
		move.w	d0,16(a5)
		rts

L004D		TST.W	L00BD
		bne	nop
		move.b	#$F,L00C5
portdown		CLR.W	D0
		move.b	3(A6),D0
		and.B	L00C5,D0
		move.b	#$FF,L00C5
		add.W	D0,16(A6)
		move.w	16(A6),D0
		and.W	#$FFF,D0
		cmp.W	#$358,D0
	BMI.S	L004F
		andI.W	#$F000,16(A6)
	ORI.W	#$358,16(A6)
L004F		MOVE.W	16(A6),D0
		and.W	#$FFF,D0
		move.w	D0,16(A5)
		rts

L0050		MOVE.L	A0,-(A7)
		move.w	(A6),D2
		and.W	#$FFF,D2
		moveQ	#0,D0
		move.b	18(A6),D0
		mulu	#$4A,D0
		lea	periods,A0
		addA.L	D0,A0
		moveQ	#0,D0
L0051		CMP.W	0(A0,D0.W),D2
	BCC.S	L0052
		addQ.W	#2,D0
		cmp.W	#$4A,D0
	BCS.S	L0051
		moveQ	#$46,D0
L0052		MOVE.B	18(A6),D2
		and.B	#8,D2
		beq.s	setmyport
		tst.W	D0
		beq.s	setmyport
		subQ.W	#2,D0

setmyport
	MOVE.W	0(A0,D0.W),D2
	moveA.L	(A7)+,A0
		move.w	d2,24(a6)
		move.w	16(a6),d0
		clr.b	22(a6)
		cmp.w	d0,d2
		beq.s	clrport
		bge.s	rt
		move.b	#1,22(a6)
		rts

clrport		clr.w	24(a6)
rt		rts

myport		move.b	3(a6),d0
		beq.s	myslide
		move.b	d0,23(a6)
		clr.b	3(a6)
myslide		tst.w	24(a6)
		beq.s	rt
		moveq	#0,d0
		move.b	23(a6),d0
		tst.b	22(a6)
		bne.s	mysub
		add.w	d0,16(a6)
		move.w	24(a6),d0
		cmp.w	16(a6),d0
		bgt.s	myok
		move.w	24(a6),16(a6)
		clr.w	24(a6)
		bra.s	myok

mysub		sub.w	d0,16(a6)
		move.w	24(a6),d0
		cmp.w	16(a6),d0
		blt.s	myok
		move.w	24(a6),16(a6)
		clr.w	24(a6)
myok		move.w	16(a6),d2

		move.b	31(a6),d0
		and.b	#$F,d0
		beq.s	L005B
		moveq	#0,d0
		move.b	18(a6),d0
		mulu	#$4A,d0
		lea	periods,a0
		add.l	d0,a0
		moveQ	#0,D0
L0059		CMP.W	0(A0,D0.W),D2
	BCC.S	L005A
		addQ.W	#2,D0
		cmp.W	#$4A,D0
	BCS.S	L0059
		moveQ	#$46,D0
L005A		MOVE.W	0(A0,D0.W),D2
L005B		mOVE.W	D2,16(A5)
		rts

vib		move.b	3(a6),d0
		beq.s	vi
		move.b	26(a6),d2
vi		move.b	27(a6),d0
		lea	sin,a4
		lsr.w	#2,d0
		and.w	#$1f,d0
		moveq	#0,d2
		move.b	0(a4,d0.w),d2
		move.b	26(a6),d0
		and.w	#$f,d0
		mulu	d0,d2
		lsr.w	#6,d2		* lsr.w #7,d2 **MSD
		move.w	16(a6),d0
		tst.b	27(a6)
		bmi.s	vibmin
		add.w	d2,d0
		bra.s	vib2
vibmin		sub.w	d2,d0
vib2		move.w	d0,16(a5)
		move.b	26(a6),d0
		lsr.w	#2,d0
		and.w	#$3C,d0
		add.b	d0,27(a6)
		rts

port_toneslide	bsr	myslide
		bra	volslide

vib_toneslide	bsr.s	vi
		bra	volslide

L0068		MOVE.L	A4,-(A7)
		move.b	3(A6),D0
		beq.s	L006B
		move.b	28(A6),D2
		and.B	#$F,D0
		beq.s	L0069
		and.B	#$F0,D2
	OR.B	D0,D2
L0069		MOVE.B	3(A6),D0
		and.B	#$F0,D0
		beq.s	L006A
		and.B	#$F,D2
	OR.B	D0,D2
L006A		MOVE.B	D2,28(A6)
L006B		MOVE.B	29(A6),D0
		lea	sin,A4
		lsr.W	#2,D0
		and.W	#$1F,D0
		moveQ	#0,D2
		move.b	30(A6),D2
		lsr.B	#4,D2
		and.B	#3,D2
		beq.s	L006E
		lsl.B	#3,D0
		cmp.b	#1,D2
		beq.s	L006C
		move.b	#$FF,D2
		bra.S	L006F

L006C		TST.B	27(A6)
	BPL.S	L006D
		move.b	#$FF,D2
		sub.B	D0,D2
		bra.S	L006F

L006D		MOVE.B	D0,D2
		bra.S	L006F

L006E		MOVE.B	0(A4,D0.W),D2
L006F		MOVE.B	28(A6),D0
		and.W	#$F,D0
		mulu	D0,D2
		lsr.W	#6,D2
		moveQ	#0,D0
		move.b	19(A6),D0
		tst.B	29(A6)
	BMI.S	L0070
		add.W	D2,D0
		bra.S	L0071

L0070		SUB.W	D2,D0
L0071		BPL.S	L0072
		clr.W	D0
L0072		CMP.W	#$40,D0
		bls.S	L0073
		move.w	#$40,D0
L0073	MOVE.W	D0,18(A5)
		move.b	28(A6),D0
		lsr.W	#2,D0
		and.W	#$3C,D0
		add.B	D0,29(A6)
		moveA.L	(A7)+,A4
		addQ.L	#4,A7
		rts

L0074	MOVEQ	#0,D0
		move.b	3(A6),D0
		beq.s	L0075
		move.b	D0,32(A6)
L0075	MOVE.B	32(A6),D0
		lsl.W	#7,D0
		cmp.W	8(A6),D0
	BGE.S	L0076
		sub.W	D0,8(A6)
		lsl.W	#1,D0
		add.L	D0,4(A6)
		rts
L0076	MOVE.W	#1,8(A6)
		rts

L007D	MOVEQ	#0,D0 
		move.b	3(A6),D0
		subQ.B	#1,D0 
		move.w	D0,L00C1
L007E	CLR.B	L00C2 
	ST	L00C3 
		rts 
L007F	MOVEQ	#0,D0 
		move.b	3(A6),D0
		cmp.b	#$40,D0 
		bls.S	L0080 
		moveQ	#$40,D0 
L0080	MOVE.B	D0,19(A6) 
		rts 
L0081	MOVEQ	#0,D0 
		move.b	3(A6),D0
	move.l	D0,D2 
		lsr.B	#4,D0 
		mulu	#$A,D0
		and.B	#$F,D2
		add.B	D2,D0 
		cmp.b	#$3F,D0 
	BHI.S	L007E 
		move.b	D0,L00C2
	ST	L00C3 
		rts 
L0082	MOVE.B	3(A6),D0
		and.W	#$FF,D0 
		beq.s	L0083 
		clr.W	L00BD 
		move.w	D0,L00BE
L0083	RTS 
L0084	MOVE.B	2(A6),D0
		and.B	#$F,D0
		cmp.b	#9,D0 
		beq	L0074 
		cmp.b	#$B,D0
		beq	L007D 
		cmp.b	#$D,D0
		beq.s	L0081 
		cmp.b	#$E,D0
		beq.s	L0085 
		cmp.b	#$F,D0
		beq.s	L0082 
		cmp.b	#$C,D0
		beq	L007F 
		bra	L0043 
L0085	MOVE.B	3(A6),D0
		and.B	#$F0,D0 
		lsr.B	#4,D0 
		beq.s	L0086 
		cmp.b	#1,D0 
		beq	L004A 
		cmp.b	#2,D0 
		beq	L004D 
		cmp.b	#3,D0 
		beq.s	L0087 
		cmp.b	#4,D0 
		beq.s	L0088 
		cmp.b	#5,D0 
		beq	L0089 
		cmp.b	#6,D0 
		beq	L008A 
		cmp.b	#7,D0 
		beq	L008E 
		cmp.b	#8,D0 
		beq	L008F 
		cmp.b	#$E,D0
		beq	L0099 
		cmp.b	#9,D0 
		beq	L0091 
		cmp.b	#$A,D0
		beq	L0095 
		cmp.b	#$B,D0
		beq	L0096 
		cmp.b	#$C,D0
		beq	L0097 
		cmp.b	#$D,D0
		beq	L0098 
		cmp.b	#$F,D0
		beq	L009A 
		rts 
L0086	MOVE.B	3(A6),D0
		and.B	#1,D0 
	ASL.B	#1,D0 
		rts 
L0087	MOVE.B	3(A6),D0
		and.B	#$F,D0
		andI.B	#$F0,31(A6) 
	OR.B	D0,31(A6) 
		rts 
L0088	MOVE.B	3(A6),D0
		and.B	#$F,D0
		andI.B	#$F0,30(A6) 
	OR.B	D0,30(A6) 
		rts 
L0089	MOVE.B	3(A6),D0
		and.B	#$F,D0
		move.b	D0,18(A6) 
		rts 
L008A	TST.W	L00BD 
		bne	nop 
		move.b	3(A6),D0
		and.B	#$F,D0
		beq.s	L008D 
		tst.B	34(A6)
		beq.s	L008C 
		subQ.B	#1,34(A6) 
		beq	nop 
L008B		MOVE.B	33(A6),L00C2
		ST	L00C4 
		rts 
L008C		MOVE.B	D0,34(A6) 
		bra.S	L008B 
L008D		MOVE.W	L00C0,D0
		lsr.L	#4,D0 
		and.B	#$3F,D0 
		move.b	D0,33(A6) 
		rts 
L008E		MOVE.B	3(A6),D0
		and.B	#$F,D0
		lsl.B	#4,D0 
		andI.B	#$F,30(A6)
		OR.B	D0,30(A6) 
		rts 
L008F		MOVEM.L	A0-A1/D1-D2,-(A7) 
		moveA.L	10(A6),A0 
		moveA.L	A0,A1 
		move.w	14(A6),D0 
		add.W	D0,D0 
		subQ.W	#2,D0 
L0090		MOVE.B	(A0),D1 
		EXT.W	D1
		move.b	1(A0),D2
		EXT.W	D2
		add.W	D1,D2 
		ASR.W	#1,D2 
		move.b	D2,(A0)+
		DBF	D0,L0090
		move.b	(A0),D1 
		EXT.W	D1
		move.b	(A1),D2 
		EXT.W	D2
		add.W	D1,D2 
		ASR.W	#1,D2 
		move.b	D2,(A0) 
		moveM.L	(A7)+,A0-A1/D1-D2 
		rts 
L0091		MOVE.L	D1,-(A7)
		moveQ	#0,D0 
		move.b	3(A6),D0
		and.B	#$F,D0
		beq.s	L0094 
		move.w	L00BD,D1
		bne.s	L0092 
		move.w	(A6),D1 
		and.W	#$FFF,D1
		bne.s	L0094 
		move.w	L00BD,D1
L0092		EXT.L	D1
		DIVU	D0,D1 
		SWAP	D1
		tst.W	D1
		bne.s	L0094 
L0093		MOVE.W	#1,20(A5) 
		move.l	4(A6),D0
		move.l	D0,(A5) 
		moveQ	#0,D1 
		move.w	8(A6),D1
		add.L	D1,D1 
		add.L	D1,D0 
		move.l	D0,4(A5)
		move.w	16(A6),16(A5) 
		move.l	10(A6),8(A5)
		moveQ	#0,D0 
		move.w	14(A6),D0 
		add.L	D0,D0 
		move.l	D0,12(A5) 
L0094		MOVE.L	(A7)+,D1
		rts 
L0095		TST.W	L00BD 
		bne	nop 
		moveQ	#0,D0 
		move.b	3(A6),D0
		and.B	#$F,D0
		bra	L0078 

L0096		TST.W	L00BD 
		bne	nop 
		moveQ	#0,D0 
		move.b	3(A6),D0
		and.B	#$F,D0
		bra	L007B 

L0097		MOVEQ	#0,D0 
		move.b	3(A6),D0
		and.B	#$F,D0
		cmp.W	L00BD,D0
		bne	nop 
		clr.b	19(A6)
		rts 
L0098		MOVEQ	#0,D0 
		move.b	3(A6),D0
		and.B	#$F,D0
		cmp.W	L00BD,D0
		bne	nop 
		move.w	(A6),D0 
		and.W	#$FFF,D0
		beq	nop 
		move.l	D1,-(A7)
		bra	L0093 
L0099		TST.W	L00BD 
		bne	nop 
		moveQ	#0,D0 
		move.b	3(A6),D0
		and.B	#$F,D0
		tst.B	L00C7 
		bne	nop 
		addQ.B	#1,D0 
		move.b	D0,L00C6
		rts 
L009A		TST.W	L00BD 
		bne	nop 
		move.b	3(A6),D0
		and.B	#$F,D0
		lsl.B	#4,D0 
		andI.B	#$F,31(A6)
		OR.B	D0,31(A6) 
		tst.B	D0
		beq	nop 
L009B		MOVEM.L	A0/D1,-(A7) 
		moveQ	#0,D0 
		move.b	31(A6),D0 
		lsr.B	#4,D0 
		beq.s	L009D 
		lea	L00B9,A0
		move.b	0(A0,D0.W),D0 
		add.B	D0,35(A6) 
		btst	#7,35(A6) 
		beq.s	L009D 
		clr.b	35(A6)
		move.l	10(A6),D0 
		moveQ	#0,D1 
		move.w	14(A6),D1 
		add.L	D1,D0 
		add.L	D1,D0 
		moveA.L	36(A6),A0 
		addQ.L	#1,A0 
		cmpA.L	D0,A0 
		bCS.S	L009C 
		moveA.L	10(A6),A0 
L009C		MOVE.L	A0,36(A6) 
		moveq	#$FF,D0 
		sub.B	(A0),D0 
		move.b	D0,(A0) 
L009D		MOVEM.L	(A7)+,A0/D1 
		rts 

L009E		movem.l	a0-a1,-(sp) 
		lea	voice1,A0
		lea	L00C9,A1
L009F		clr.b	(a0)+ 
		cmp.l	a0,a1 
		bne.s	L009F 

		lea	voice1,A0
		move.b	#1,20(A0) 
		move.b	#2,64(A0) 
		move.b	#4,108(A0)
		move.b	#8,152(A0)

		move.w	#6,L00BE

		move.b	#$F,L00C8 
		movem.l	(sp)+,a0-a1 
		rts 

L00A0		MOVEM.L	A0-A6/D0-D7,-(A7) 
		bsr	L00A1
		moveM.L	(A7)+,A0-A6/D0-D7 
		rts 

L00A1		LEA	$FFFF8800.W,A0
		move	SR,D1 
		move	#$2700,SR 
		move.b	#$E,(A0)
		move.b	(A0),D0 
		and.B	#$EF,D0 
		move.b	D0,2(A0)
		OR.B	#$10,D0 
		move.b	D0,2(A0)
		move	D1,SR 
		move.l	$4BA.W,D0 
		addQ.L	#2,D0 
L00A2		CMP.L	$4BA.W,D0 
		BLT.S	L00A2 
		move	SR,D1 
		move	#$2700,SR 
		move.b	#$E,(A0)
		move.b	(A0),D0 
		and.B	#$EF,D0 
		move.b	D0,2(A0)
		move	D1,SR 
		lea	$FFFFA200.W,A0
		lea	L00CA,A1
		move.w	#$200,D0
L00A3		TST.B	(A1)
		BMI.S	L00A4 
		addq.w	#3,A1 
		move.b	(A1)+,5(A0) 
		move.b	(A1)+,6(A0) 
		move.b	(A1)+,7(A0) 
		subq.w	#1,D0 
		bra.S	L00A3 
L00A4	TST.W	D0
		beq.s	L00A6 
L00A5	CLR.B	5(A0) 
		clr.b	6(A0) 
		clr.b	7(A0) 
		subQ.W	#1,D0 
		bne.s	L00A5 
L00A6	BTST	#2,2(A0)
		beq.s	L00A6 
		clr.b	5(A0) 
		clr.b	6(A0) 
		clr.b	7(A0) 
		lea	L00CB,A1
L00A7		BTST	#2,2(A0)
		beq.s	L00A7
		move.b	(A1)+,5(A0)
		move.b	(A1)+,6(A0)
		move.b	(A1)+,7(A0)
		tst.B	-3(A1)
	BMI.S	L00A9
L00A8	BTST	#2,2(A0)
		beq.s	L00A8 
		move.b	(A1)+,5(A0) 
		move.b	(A1)+,6(A0) 
		move.b	(A1)+,7(A0) 
		bra.S	L00A7 
L00A9		RTS 

** do not move the following data else where!!!
	ifeq	DOWNLOAD
*******************
   SECTION DATA
*******************
	endc

	DC.w	$00 
L00AA	DC.l	0 
L00AB	DC.w	$00 
L00AC	DC.w	$00 
L00AF	DCB.W	3,0 
L00B0	DC.w	$00 
L00B1	DC.w	$00 

L00B3	dc.l	0 
L00B4	dc.l	0 
L00B5	dc.b	0 
L00B6	DCB.W	62,0

L00B7	dc.l	0 
L00B8	DCB.W	1760,0

L00B9	DC.B	$00,$05,$06,$07,$08,$0A,$0B,$0D 
	DC.B	$10,$13,$16,$1A,' +@',$80 

sin	DC.B $00,$18,$31,$4A,$61,$78,$8D,$A1,$B4,$C5,$D4,$E0,$EB,$F4,$FA,$FD
	DC.B $FF,$FD,$FA,$F4,$EB,$E0,$D4,$C5,$B4,$A1,$8D,$78,$61,$4A,$31,$18
	DC.B $00,$00 

periods
	DC.W $0358,$0328,$02FA,$02D0,$02A6,$0280,$025C,$023A,$021A,$01FC,$01E0
	DC.W $01C5,$01AC,$0194,$017D,$0168,$0153,$0140,$012E,$011D,$010D,$FE
	DC.W $F0,$E2,$D6,$CA,$BE,$B4,$AA,$A0,$97,$8F,$87
	DC.W $7F,$78,$71,$00,$00

voice1	ds.w	18
	dc.w	$1
	ds.w	3

voice2	ds.w	18
	dc.w	$2
	ds.w	3 

voice3	ds.w	18
	DC.w	$4
	ds.w	3

voice4	ds.w	18
	dc.w	$8
	ds.w	3

	ds.w	8 

L00BD	dc.w	0 
L00BE	DC.l	0 
L00BF	DC.w	0 
L00C0	DC.w	0 
L00C1	DC.l	0 
L00C2	DC.B	0 
L00C3	DC.B	0 
L00C4	DC.B	0 
L00C5	DC.B	0 
L00C6	DC.B	0 
L00C7	DC.B	0 
L00C8	DC.B	0 
L00C9	DC.B	0 

L00CA	DC.B	'P',$00,$00,'D',$F4,$00,'P',$00 
	DC.B	$01,$00,$00,$0E,'P',$00,$02,' ' 
	DC.B	$92,$00,'P',$00,$03,'V',$F4,$00 
	DC.B	'P',$00,$04,$00,$00,'IP',$00
	DC.B	$05,' ',$00,'DP',$00,$06,'`'
	DC.B	$F4,$00,'P',$00,$07,$00,'|',$0E 
	DC.B	'P',$00,$08,'"',$11,$00,'P',$00 
	DC.B	$09,$06,$CE,$00,'P',$00,$0A,$00 
	DC.B	$00,$0C,'P',$00,$0B,$07,$DA,$84 
	DC.B	'P',$00,$0C,$07,'X„P',$00 
	DC.B	$0D,$0A,$E1,$80,'P',$00,$0E,$08 
	DC.B	$F4,$A0,'P',$00,$0F,$00,$00,$01 
	DC.B	'P',$00,$10,'0',$00,$00,'P',$00 
	DC.B	$11,' ',$00,$13,'P',$00,$12,$06 
	DC.B	'@',$A0,'P',$00,$13,$07,'XŽ'
	DC.B	'P',$00,$14,$0B,$F0,$80,'P',$00 
	DC.B	$15,$00,'|EP',$00,$16,' ' 
	DC.B	$8F,$00,'P',$00,$17,' ',$00,$0B 
	DC.B	'P',$00,$18,$0A,$F0,$AA,'P',$00 
	DC.B	$19,$00,'|#P',$00,$1A,'`' 
	DC.B	$F4,$00,'P',$00,$1B,$00,'`',$00 
	DC.B	'P',$00,$1C,$0B,$F0,$80,'P',$00 
	DC.B	$1D,$00,'|EP',$00,$1E,$06 
	DC.B	$C4,$00,'P',$00,$1F,$00,'|"'
	DC.B	'P',$00,' ',$0B,$F0,$80,'P',$00 
	DC.B	'!',$00,'|EP',$00,'"',$07 
	DC.B	'X„P',$00,'#',$0B,$F0,$80 
	DC.B	'P',$00,'$',$00,'|EP',$00 
	DC.B	'% ',$90,$00,'P',$00,'& ' 
	DC.B	$8E,$00,'P',$00,$27,'$',$FF,$00 
	DC.B	'P',$00,'( ',$00,'FP',$00 
	DC.B	')%PEP',$00,'*',$0A 
	DC.B	$F0,$AA,'P',$00,'+',$00,'|@'
	DC.B	'P',$00,',',$0B,$F0,$80,'P',$00 
	DC.B	'-',$00,'|EP',$00,'.%'
	DC.B	'XeP',$00,'/',$0A,$F0,$A2 
	DC.B	'P',$00,'0',$00,'|4P',$00 
	DC.B	'1',$07,'`„P',$00,'2',$0A 
	DC.B	$F0,$80,'P',$00,'3',$00,'|#'
	DC.B	'P',$00,'4%YeP',$00 
	DC.B	'5',$0A,$F0,$A2,'P',$00,'6',$00 
	DC.B	'|:P',$00,'7D`',$00 
	DC.B	'P',$00,'8',$0A,$F0,$80,'P',$00 
	DC.B	'9',$00,'|#P',$00,': '
	DC.B	$00,'eP',$00,';',$0A,$F0,$A2
	DC.B	'P',$00,'<',$00,'|#P',$00 
	DC.B	'=L`',$00,'P',$00,'>',$0A 
	DC.B	$F0,$80,'P',$00,'?',$00,'|#'
	DC.B	'P',$00,'@ ',$00,$0B,'P',$00
	DC.B	'A',$0A,$F0,$AA,'P',$00,'B',$00 
	DC.B	$00,$00,'P',$00,'C',$0A,$F0,$80 
	DC.B	'P',$00,'D',$00,'`',$00,'P',$00 
	DC.B	'E',$0A,$A9,$80,'P',$00,'F',$00 
	DC.B	'|EP',$00,'G',$08,'D+'
	DC.B	'P',$00,'H',$00,$00,$0C,$FF,$FF 
	DC.B	$FF,$FF,$FF,$FF 

L00CB	DC.B	'X',$00,$00,$00,$00,$00,'X',$00 
	DC.B	$01,$00,$00,$00,'X',$00,$02,$00 
	DC.B	$00,$00,'X',$00,$03,$00,$00,$00 
	DC.B	'X',$00,$04,$00,$00,$00,'X',$00 
	DC.B	$05,$00,$00,$00,'X',$00,$06,$00 
	DC.B	$00,$00,'X',$00,$07,$00,$00,$00 
	DC.B	'X',$00,$08,$00,$00,$00,'X',$00 
	DC.B	$09,$00,$00,$00,'X',$00,$0A,$00 
	DC.B	$00,$00,'X',$00,$0B,$00,$00,$00 
	DC.B	'X',$00,$0C,$00,$00,$00,'X',$00 
	DC.B	$0D,$00,$00,$00,'X',$00,$0E,$00 
	DC.B	$00,$00,'X',$00,$0F,$00,$00,$00 
	DC.B	'X',$00,$10,$00,$00,$00,'X',$00 
	DC.B	$11,$00,$00,$00,'X',$00,$12,$00 
	DC.B	$00,$00,'X',$00,$13,$00,$00,$00 
	DC.B	'X',$00,$14,$00,$00,$00,'X',$00 
	DC.B	$15,$00,$00,$00,'X',$00,$16,$00 
	DC.B	$00,$00,'X',$00,$17,$00,$00,$00 
	DC.B	'X',$00,$18,$00,$00,$00,'X',$00 
	DC.B	$19,$00,$00,$00,'X',$00,$1A,$00 
	DC.B	$00,$00,'X',$00,$1B,$00,$00,$00 
	DC.B	'X',$00,$1C,$00,$00,$00,'X',$00 
	DC.B	$1D,$00,$00,$00,'X',$00,$1E,$00 
	DC.B	$00,$00,'X',$00,$1F,$00,$00,$00 
	DC.B	'X',$00,' ',$00,$00,$00,'P',$00 
	DC.B	$00,$0A,$F0,$80,'P',$00,$01,$00 
	DC.B	$00,'@P',$00,$10,$0B,$F0,$80
	DC.B	'P',$00,$11,$00,$01,'>P',$00
	DC.B	'@',$08,$F4,$BE,'P',$00,'A',$00 
	DC.B	$00,$00,'P',$00,'B',$08,$F4,$A0 
	DC.B	'P',$00,'C',$00,$00,$01,'P',$00 
	DC.B	'D',$05,$F4,'&P',$00,'E',$00
	DC.B	$07,$FF,'P',$00,'F',$04,'g',$A6 
	DC.B	'P',$00,'G ',$00,$1B,'P',$00
	DC.B	'Hg',$F4,$00,'P',$00,'I',$00
	DC.B	' ',$00,'P',$00,'J',$06,$00,$A8 
	DC.B	'P',$00,'KI_',$00,'P',$00 
	DC.B	'L',$05,$01,$A3,'P',$00,'M',$08 
	DC.B	$F4,$BF,'P',$00,'N',$00,'0',$00 
	DC.B	'P',$00,'O',$08,$F4,$AC,'P',$00 
	DC.B	'P',$00,'A',$00,'P',$00,'Q',$08 
	DC.B	$F4,$AD,'P',$00,'R',$00,'X',$00 
	DC.B	'P',$00,'S',$08,$F4,$A1,'P',$00 
	DC.B	'T',$00,$01,$F0,'P',$00,'U',$08 
	DC.B	$F4,$A3,'P',$00,'V',$00,$00,$08 
	DC.B	'P',$00,'W',$00,$F0,$B8,'P',$00 
	DC.B	'X',$0A,$A9,$80,'P',$00,'Y',$00 
	DC.B	$00,'XP',$00,'Z',$08,'E+' 
	DC.B	'P',$00,'[f',$F4,$00,'P',$00
	DC.B	'\',$00,' ',$00,'P',$00,']g'
	DC.B	$F4,$00,'P',$00,'^',$00,'$',$00 
	DC.B	'P',$00,'_',$0A,$F0,$80,'P',$00 
	DC.B	'`',$00,$00,'dP',$00,'a',$0A
	DC.B	$A9,$80,'P',$00,'b',$00,$00,'a' 
	DC.B	'P',$00,'c',$08,'E+P',$00 
	DC.B	'd',$0A,'p#P',$00,'e',$00 
	DC.B	$FF,$E5,'P',$00,'f"',$EF,$00
	DC.B	'P',$00,'g"',$C4,$00,'P',$00
	DC.B	'hD',$F4,'LP',$00,'i',$00 
	DC.B	$08,$00,'P',$00,'j',$0A,$F0,$A0 
	DC.B	'P',$00,'k',$00,$00,'mP',$00
	DC.B	'l ',$00,'HP',$00,'mW'
	DC.B	' ',$00,'P',$00,'n`',$F4,$00
	DC.B	'P',$00,'o',$00,$02,$00,'P',$00 
	DC.B	'pa',$F4,$00,'P',$00,'q',$00
	DC.B	$00,$04,'P',$00,'r',$0B,$F0,$80 
	DC.B	'P',$00,'s',$00,$01,$0D,'P',$00 
	DC.B	't`',$F4,$00,'P',$00,'u',$00
	DC.B	$06,$00,'P',$00,'va',$F4,$00
	DC.B	'P',$00,'w',$00,$00,$0C,'P',$00 
	DC.B	'x',$0B,$F0,$80,'P',$00,'y',$00 
	DC.B	$01,$0D,'P',$00,'z`',$F4,$00
	DC.B	'P',$00,'{',$00,$0A,$00,'P',$00 
	DC.B	'|a',$F4,$00,'P',$00,'}',$00
	DC.B	$00,$14,'P',$00,'~',$0B,$F0,$80 
	DC.B	'P',$00,$7F,$00,$01,$0D,'P',$00 
	DC.B	$80,'`',$F4,$00,'P',$00,$81,$00 
	DC.B	$0E,$00,'P',$00,$82,'a',$F4,$00 
	DC.B	'P',$00,$83,$00,$00,$1C,'P',$00 
	DC.B	$84,$0B,$F0,$80,'P',$00,$85,$00 
	DC.B	$01,$0D,'P',$00,$86,$0A,'p',$03 
	DC.B	'P',$00,$87,$00,$FF,$E5,'P',$00 
	DC.B	$88,'F',$F4,$00,'P',$00,$89,'p' 
	DC.B	$00,$00,'P',$00,$8A,$27,$00,$00 
	DC.B	'P',$00,$8B,'D',$84,$00,'P',$00 
	DC.B	$8C,' ',$00,$D0,'P',$00,$8D,'V' 
	DC.B	$02,$00,'P',$00,'Ž ',$00,$C0
	DC.B	'P',$00,$8F,'V',$03,$00,'P',$00 
	DC.B	$90,'D',$8C,$00,'P',$00,$91,' ' 
	DC.B	$00,$D0,'P',$00,$92,'V',$0B,$00 
	DC.B	'P',$00,$93,' ',$00,$C0,'P',$00 
	DC.B	$94,'V',$0A,$00,'P',$00,$95,'D' 
	DC.B	$94,$00,'P',$00,$96,' ',$00,$D0 
	DC.B	'P',$00,$97,'V',$13,$00,'P',$00 
	DC.B	$98,' ',$00,$C0,'P',$00,$99,'V' 
	DC.B	$12,$00,'P',$00,'šD',$9C,$00
	DC.B	'P',$00,$9B,' ',$00,$D0,'P',$00 
	DC.B	$9C,'V',$1A,$00,'P',$00,$9D,' ' 
	DC.B	$00,$C0,'P',$00,$9E,'V',$1B,$00 
	DC.B	'P',$00,$9F,'"',$DE,$00,'P',$00 
	DC.B	$A0,$0A,$DA,'`P',$00,$A1,'`'
	DC.B	$F4,$00,'P',$00,$A2,$00,$02,$00 
	DC.B	'P',$00,$A3,'2',$05,$00,'P',$00 
	DC.B	$A4,'3',$02,$00,'P',$00,$A5,$0D 
	DC.B	$00,$B7,'P',$00,$A6,$0A,$DA,'@' 
	DC.B	'P',$00,$A7,'`',$F4,$00,'P',$00 
	DC.B	$A8,$00,$06,$00,'P',$00,$A9,'2' 
	DC.B	$0D,$00,'P',$00,$AA,'3',$0A,$00 
	DC.B	'P',$00,$AB,$0D,$00,$B7,'P',$00 
	DC.B	$AC,'`',$F4,$00,'P',$00,$AD,$00 
	DC.B	$0A,$00,'P',$00,$AE,'2',$15,$00 
	DC.B	'P',$00,$AF,'3',$12,$00,'P',$00 
	DC.B	$B0,$0D,$00,$B7,'P',$00,$B1,'`' 
	DC.B	$F4,$00,'P',$00,$B2,$00,$0E,$00 
	DC.B	'P',$00,$B3,'2',$1D,$00,'P',$00 
	DC.B	$B4,'3',$1A,$00,'P',$00,$B5,$0D 
	DC.B	$00,$B7,'P',$00,$B6,$0C,$00,'a' 
	DC.B	'P',$00,$B7,'a',$F4,$00,'P',$00 
	DC.B	$B8,$00,$12,$00,'P',$00,$B9,'W' 
	DC.B	$D8,$00,'P',$00,$BA,'!',$F9,$00 
	DC.B	'P',$00,$BB,' ',$00,$0B,'P',$00 
	DC.B	$BC,$0B,$F0,$A2,'P',$00,$BD,$00 
	DC.B	$00,$F8,'P',$00,$BE,'a',$F4,$00 
	DC.B	'P',$00,$BF,$00,$12,$00,'P',$00 
	DC.B	$C0,'W',$D8,$00,'P',$00,$C1,' ' 
	DC.B	'I',$00,'P',$00,$C2,'!',$F9,$00 
	DC.B	'P',$00,$C3,'"4',$00,'P',$00
	DC.B	$C4,' ',$00,$0B,'P',$00,$C5,$0A 
	DC.B	$F0,$AA,'P',$00,$C6,$00,$00,$D3 
	DC.B	'P',$00,$C7,$0B,$F0,$80,'P',$00 
	DC.B	$C8,$00,$00,$F8,'P',$00,$C9,'"' 
	DC.B	$91,$00,'P',$00,$CA,'W',$F4,$00 
	DC.B	'P',$00,$CB,$00,$16,$00,'P',$00 
	DC.B	$CC,' I',$00,'P',$00,$CD,'"'
	DC.B	'$',$00,'P',$00,$CE,' ',$00,'L' 
	DC.B	'P',$00,$CF,$06,$CF,$00,'P',$00 
	DC.B	$D0,$00,$00,$D2,'P',$00,$D1,'D' 
	DC.B	$DC,$00,'P',$00,$D2,'DY',$00
	DC.B	'P',$00,$D3,'#',$D6,$00,'P',$00 
	DC.B	$D4,'`',$F4,$00,'P',$00,$D5,$00 
	DC.B	$12,$00,'P',$00,$D6,'D',$DA,$00 
	DC.B	'P',$00,$D7,'E',$D8,$00,'P',$00 
	DC.B	$D8,'F',$DB,$00,'P',$00,$D9,'F' 
	DC.B	$DB,$E0,'P',$00,$DA,'!',$C7,$00 
	DC.B	'P',$00,$DB,' Z',$E0,'P',$00
	DC.B	$DC,'!',$C6,$00,'P',$00,$DD,'W' 
	DC.B	$E2,$00,'P',$00,$DE,'p',$A0,$00 
	DC.B	'P',$00,$DF,$06,$D8,$00,'P',$00 
	DC.B	$E0,$00,$00,$F0,'P',$00,$E1,' ' 
	DC.B	$00,'HP',$00,$E2,$0A,$F0,$A5
	DC.B	'P',$00,$E3,$00,$00,$EB,'P',$00 
	DC.B	$E4,$0A,$CD,'WP',$00,$E5,'E'
	DC.B	$D8,$00,'P',$00,$E6,'F',$DB,$00 
	DC.B	'P',$00,$E7,'F',$DB,$E0,'P',$00 
	DC.B	$E8,'!',$C7,$00,'P',$00,$E9,' ' 
	DC.B	$00,$E0,'P',$00,$EA,'!',$C6,$00 
	DC.B	'P',$00,$EB,'H',$E6,$00,'P',$00 
	DC.B	$EC,$0A,$DA,$00,'P',$00,$ED,$00 
	DC.B	$00,$EF,'P',$00,$EE,' ',$00,$13 
	DC.B	'P',$00,$EF,' ',$00,'0P',$00
	DC.B	$F0,'H^',$00,'P',$00,$F1,'W'
	DC.B	'R',$00,'P',$00,$F2,'"',$0F,$00 
	DC.B	'P',$00,$F3,'D',$F4,$00,'P',$00 
	DC.B	$F4,$00,$12,$01,'P',$00,$F5,' ' 
	DC.B	$00,'LP',$00,$F6,'Wb',$00 
	DC.B	'P',$00,$F7,$00,$00,$0C,'P',$00 
	DC.B	$F8,'D',$F4,'+P',$00,$F9,$00
	DC.B	$00,$01,'P',$00,$FA,' ',$00,'H' 
	DC.B	'P',$00,$FB,$06,$CF,$00,'P',$00 
	DC.B	$FC,$00,$01,$0B,'P',$00,$FD,'D' 
	DC.B	$E0,$00,'P',$00,$FE,'E',$F4,$00 
	DC.B	'P',$00,$FF,$00,$00,$80,'P',$01 
	DC.B	$00,'D',$F4,$A8,'P',$01,$01,$FF 
	DC.B	$00,$00,'P',$01,$02,'!/',$00
	DC.B	'P',$01,$03,'E',$F4,'NP',$01
	DC.B	$04,$00,$80,$00,'P',$01,$05,'U' 
	DC.B	'Y',$00,'P',$01,$06,'D',$D8,$00 
	DC.B	'P',$01,$07,'D',$F4,$A8,'P',$01 
	DC.B	$08,$FF,$00,$00,'P',$01,$09,'!' 
	DC.B	'/',$00,'P',$01,$0A,' ',$00,'N' 
	DC.B	'P',$01,$0B,'UY',$00,'P',$01
	DC.B	$0C,$00,$00,$0C,'P',$01,$0D,$0A 
	DC.B	$A9,$80,'P',$01,$0E,$00,$01,$0D 
	DC.B	'P',$01,$0F,$08,'Y',$AB,'P',$01 
	DC.B	$10,$0A,$A9,$80,'P',$01,$11,$00 
	DC.B	$01,$10,'P',$01,$12,$08,'E+'
	DC.B	'P',$01,$13,'EY',$00,'P',$01
	DC.B	$14,$0A,$A9,$81,'P',$01,$15,$00 
	DC.B	$01,$14,'P',$01,$16,$08,$E1,$AB 
	DC.B	'P',$01,$17,'D',$A0,$00,'P',$01 
	DC.B	$18,' ',$00,$A8,'P',$01,$19,$0A 
	DC.B	$A9,$81,'P',$01,$1A,$00,$01,$19 
	DC.B	'P',$01,$1B,$08,$CF,'+P',$01
	DC.B	$1C,$0A,$A9,$81,'P',$01,$1D,$00 
	DC.B	$01,$1C,'P',$01,$1E,$08,$C4,'+' 
	DC.B	'P',$01,$1F,$0A,$A9,$80,'P',$01 
	DC.B	' ',$00,$01,$1F,'P',$01,'!',$08 
	DC.B	'O+P',$01,'"WX',$00 
	DC.B	'P',$01,'# ',$00,$0B,'P',$01
	DC.B	'$',$0A,$F0,$AA,'P',$01,'%',$00 
	DC.B	$01,'.P',$01,'&D',$F4,'+' 
	DC.B	'P',$01,$27,$00,$00,$01,'P',$01 
	DC.B	'( ',$00,'HP',$01,')',$06 
	DC.B	$CF,$00,'P',$01,'*',$00,$01,'-' 
	DC.B	'P',$01,'+',$0A,$A9,$80,'P',$01 
	DC.B	',',$00,$01,'+P',$01,'-',$08
	DC.B	'X',$AB,'P',$01,'.',$0A,$A9,$80 
	DC.B	'P',$01,'/',$00,$01,'.P',$01
	DC.B	'0',$08,'O+P',$01,'1W'
	DC.B	'X',$00,'P',$01,'2 ',$00,$0B
	DC.B	'P',$01,'3',$0A,$F0,$AA,'P',$01 
	DC.B	'4',$00,$01,'=P',$01,'5D' 
	DC.B	$F4,'+P',$01,'6',$00,$00,$01
	DC.B	'P',$01,'7 ',$00,'HP',$01 
	DC.B	'8',$06,$CF,$00,'P',$01,'9',$00 
	DC.B	$01,'<P',$01,':',$0A,$A9,$80
	DC.B	'P',$01,';',$00,$01,':P',$01
	DC.B	'<',$08,'X',$AB,'P',$01,'=',$00 
	DC.B	$00,$0C,'P',$01,'>',$0A,$AE,$82 
	DC.B	'P',$01,'?',$00,$01,'BP',$01
	DC.B	'@',$08,$DF,$EF,'P',$01,'A',$00 
	DC.B	$00,$04,'P',$01,'B',$08,$E7,$AF 
	DC.B	'P',$01,'C',$00,$00,$04,'P',$01 
	DC.B	'DDSPP',$01,'E-'
	DC.B	'PaP',$01,'Fula'
	DC.B	'P',$01,'G-EmP',$01 
	DC.B	'HulaP',$01,'It'
	DC.B	'orP',$01,'J V2'
	DC.B	'P',$01,'K.0 P',$01 
	DC.B	'LcodP',$01,'Me'
	DC.B	'riP',$01,'Nght'
	DC.B	'P',$01,'O byP',$01 
	DC.B	'P bIP',$01,'QT'
	DC.B	'mAP',$01,'RSTE'
	DC.B	'P',$01,'SR oP',$01 
	DC.B	'Tf BP',$01,'US'
	DC.B	'W P',$01,'Vof '
	DC.B	'P',$01,'WCC ',$FF,$FF
	DC.B	$FF,$FF,$FF,$FF 


















font_pal
	dc.w	$000,$057,$046,$035,$024,$013,$012,$111
	dc.w	$221,$332,$442,$553,$664,$773,$007,$777


scroll_pointer		dc.l	init_scroll_text+7
init_scroll_text
	dc.b	"                          "
scroll_text
 dc.b "                  WE ARE BACK!          NOW HOW MANY TIMES "
 DC.B "HAVE YOU HEARD THAT?             PERSISTENCE OF VISION ARE "
 DC.B "PROUD TO PRESENT DISC 149.    THIS IS THE FIRST POV MENU TO "
 DC.B "BE FALCON COMPATIBLE.  YES YOU HEARD CORRECT, THIS MENU "
 DC.B "DETECTS IF YOU HAVE A FALCON AND AUTOMATICALLY ALTERS ITSELF "
 DC.B "TO PLAY A MOD AT 33 MEGAHERTZ INSTEAD OF THE CHIP TUNE. THE "
 DC.B "FALCON 030 ONLY USES APPROX. 40 PERCENT OF THE CPU TIME FOR THIS "
 DC.B "MENU WHILST THE ST/STE USES ABOUT 80 PERCENT CPU TIME.    THE "
 DC.B "MOD DOES NOT USE THE DSP, MAYBE NEXT TIME! OH YEAH, THE MENU WORKS ON "
 dc.b "VGA MONITORS AS WELL.               "
 dc.b "CREDITS FOR THIS MENU GOTO   MAC SYS DATA FOR ALL THE CODING,   "
 DC.B "OZYMANDIAS FOR THE ART,  "
 DC.B "THE CHIP TUNE AND MOD ARE OF UNKNOWN ORIGIN.               "
 DC.B "     I MUST APOLOGISE FOR THE LACK OF POV DISCS OVER THE PAST "
 DC.B "12 MONTHS BUT I HAVE MOVED HOUSE AND HAVE NOT HAD TIME OR ST "
 DC.B "TO WORK ON.            IF YOU ARE A FALCON OWNER, YOU MAY "
 DC.B "BE INTERESTED THAT I HAVE RELEASED A FALCON ONLY DEMO CALLED "
 DC.B "-POVERTY-.      THE DEMO IS AVAILABLE AS A BOOTABLE FLOPPY FROM "
 DC.B "ALL GOOD PD LIBRARIES BUT IF YOU HAVE INTERNET ACCESS YOU CAN "
 DC.B "DOWNLOAD THE FILED VERSION FROM       FTP.DEMON.CO.UK      OR      "
 DC.B "MICROS.HENSA.AC.UK            THESE TWO SITES ARE THE OFFICIAL UK "
 DC.B "SITES FOR POV. THE DEMON SITE WILL ALSO BE PRIVILEDGED TO HAVE "
 DC.B "POV SOURCE CODE.   THE STE VERSION OF POVERTY HAS BEEN FINISHED AND "
 dc.b "SHOULD BE READY NOW.        IF YOU WISH TO MAIL ME OR CANNOT WRITE THE "
 DC.B "FTP SITES DOWN QUICKLY ENOUGH THEN LOOK IN THE CONTACT.TXT FILE "
 DC.B "ON THIS DISC.                "
 DC.B "I HAVE BEEN WORKING A LOT ON MY FALCON IN BETWEEN WORKING ON "
 DC.B "MY NEW HOME AND GOING TO WORK.   I HAVE STARTED WORK ON SOME LINE "
 DC.B "DRAWING ROUTINES AND USED MY TECHNIQUE IN POVERTY DEMO.   THERE WILL BE "
 DC.B "A MENU SOON UTILISING MY ROUTINES (NOTHING SPECIAL) PLUS I WILL "
 DC.B "BE EXPERIMENTING WITH THE TRUE COLOUR MODE ON THE FALCON.   IF YOU "
 DC.B "OWN AN ST OR STE THEN DON'T BE DISAPPOINTED BECAUSE I WILL NOT BE "
 DC.B "FORGETTING YOU.              "
 dc.b "I INTENDED TO STOP DOING POV DISCS AFTER DISC "
 DC.B "150 BECAUSE THE ST SCENE HAS ALL BUT DISAPPEARED. HOWEVER THE RECENT "
 DC.B "PRESS HAS GIVEN ME NEW IDEAS. THERE ARE "
 DC.B "NEW MAGS APPEARING FOR ATARI OWNING PEOPLE AND A NEW MACHINES ARRIVING.   "
 DC.B "   I EXPECT TO GO PAST THE 150 MARK IN A FEW WEEKS, THE DELAY WILL "
 DC.B "BE IN WRITING THE INFORMATION FILE DETAILING ALL THE POV DISCS FROM DAY 1."
 DC.B "        IF YOU ARE EXPERIENCING PROBLEMS GETTING HOLD OF POV DISCS THEN "
 DC.B "I WILL HOPEFULLY BE ABLE TO RELEASE A NEW ADDRESS FOR POSTAL CONTACT SOON. "
 DC.B "THE OLD LIBRARY OF TOWER PD HAS REDUCED IT'S WORK DUE TO LACK OF INTEREST. "
 DC.B "      THIS YEAR -1995- I EXPECT TO BE BUYING A PC (ARRGGHHH) SO IF YOU "
 DC.B "HAVE ONE LOOK OUT FOR ANY PERSISTENCE OF VISION LOOKING CODE AS I ALREADY "
 DC.B "HAVE AN ASSEMBLER (486 ONLY!!!).            "
 DC.B "I HAVE ACCESS TO MANY MORE MACHINES INCLUDING A CRAY, VAX 6000 RANGE, "
 DC.B "DEC ALPHA, SUN AND HP RISC CHIP.     IF YOU HAVE ANY EXPERIENCE OF "
 DC.B "CODING THE HP 712-60 MACHINE PLEASE, PLEASE GET IN TOUCH AS THIS "
 DC.B "IS MY MAIN UNIX MACHINE AT WORK.    IT IS SOON TO BE THE MAIN MAIL "
 DC.B "HOST AT WORK FOR INTERNET MAIL AS SOON AS I CONFIGURE IT!        "
 DC.B "WELL ENOUGH TALK, HERE ARE THE GREETINGS TO THE PEOPLE I KNOW "
 DC.B "AND SPEAK TO REGULARLY FIRST......            "
 DC.B "       FELICE OF MAGGIE CREW - HI, HOPE YOU LIKE MY NEW WORK,          "
 DC.B "GEORGE (OF TOWER PD) - KEEP IN CONTACT AND GET THAT ST USED,          "
 DC.B "JOHN FROM SERENADE - PLEASE FORGIVE MY SLOW RESPONSES!      AND      "
 DC.B "ACID FROM TBB.                "
 DC.B " AND NOW THE PEOPLE WHOS WORK I SEE AND "
 DC.B "WOULD LIKE TO CONTACT.....           "
 DC.B "EKO - NICE FALCON DEMOS,          "
 DC.B "NEW TREND - NICE STRANGE CIRCUMSTANCES DEMO,          "
 DC.B "INTER DEVELOPMENTS - OBNOXIOUS DEMO WAS GOOD,          "
 DC.B "ABSTRACT - NICE EXPERIENCE DEMO,          "
 DC.B "MUGWUMPS     AND     DIGITAL CHAOS (HELLO BENN!).           "
 DC.B "              I HAVE HEARD OVER THE GRAPEVINE THAT SOME PEOPLE "
 DC.B "ACROSS THE WATER IN EUROPE HAVE BEEN ASKING ABOUT US, WELL WE ARE "
 DC.B "NOT DEAD AND WILL CONTINUE TO LIVE AS LONG AS COMPUTERS ARE MADE.  "
 dc.b "      THE BIRDIE 2 DEMO ON THIS DISC HAS BEEN PACKED WITH ICE 2.4.  "
 DC.B " I COULD HAVE PACKED IT SMALLER USING ATOMIC 3.5 BUT IT WOULD HAVE "
 DC.B "MADE IT NON-FALCON COMPATIBLE.    IF YOU HAVE A NEW COPY OF ATOMIC 3.5 THAT "
 DC.B "ACTUALLY ALLOWS YOU TO PACK AN EXECUTABLE PIECE OF CODE AND STILL MAKE IT "
 DC.B "FALCON COMPATIBLE, PLEASE SEND IT VIA SNAIL MAIL OR INTERNET MAIL.     "
 DC.B "THERE ARE SUPPOSIDLY FALCON COMPATIBLE VERSIONS GOING ROUND BUT THEY "
 DC.B "DO NOT WORK.       IF NOBODY HAS A WORKING VERSION I WILL HAVE TO "
 DC.B "HAVE A GO MYSELF.        "
 DC.B "                   LONG LIVE ATARI, LONG LIVE PERSISTENCE OF VISION.      "
 DC.B "   FUCK TO THE RAY TRACING GROUP WHO STOLE OUR NAME.        "
 DC.B "                            WRAP - MSD OCT 1995    "
 dc.b "                                   "
	dc.b $ff
	even

char_offset	dc.w	0
font	dcb.b	WIDTH*DEPTH*4,0
	incbin	font.fnt
font_offsets:
;          !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
 dc.b	0,30,43,00,00,00,00,41,42,43,45,46,27,46,28,00

;        0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @
 dc.b	41,32,33,34,35,36,37,38,39,40,45,29,00,44,00,31,00

;        A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q
 dc.b	01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17

;        R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  `  a  b  c
 dc.b	18,19,20,21,22,23,24,25,26,29,00,41,00,47,00,01,02,03

;        d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u
 dc.b	04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21
	even
last_scroll	dc.l	0
sine_number	dc.w	0
sine_table
	dc.w	0,0,0,0,0,0,0
	dc.w	1,1,1,1,1,1
	dc.w	2,2,2,2,2
	dc.w	3,3,3,3
	dc.w	4,4,4
	dc.w	5,5
	dc.w	6,7,8,10,8,7,6
	dc.w	5,5,4,4,4,3,3,3,3,2,2,2,2,2,1,1,1,1,1,1

black	dcb.b	34,0


;*************************

tune	INCBIN	RALPH_n6.MUX


pic	incbin	hysteria.PI1
	even

sprite_data	incbin	"SPRITES.DAT"
sprite_mask	incbin	"SPRITES.MSK"

sprite_nums
	dc.w	0,1,2,3,4,3,5,1,6,7,1,8,9,10,8,11,4,3,4,9,6
path	incbin	"PATH.DAT"
sprite_pos
NUM	set	(22*16)
	REPT	21
	dc.w	NUM
NUM	set	NUM-16
	ENDR

demo_keys
	dc.b	0, $02		;key 1
	dc.b	1, $03		;key 2
	dc.b	2, $04		;key 3
	dc.b	3, $05		;key 4
	dc.b	4, $06		;key 5
	dc.b	5, $07		;key 6
;	dc.b	6, $08		;key 7
;	dc.b	7, $08		;key 8
;	dc.b	8, $08		;key 9

	dc.b	0, $6d		;keypad 1
	dc.b	1, $6e		;keypad 2
	dc.b	2, $6f		;keypad 3
	dc.b	3, $6a		;keypad 4
	dc.b	4, $6b		;keypad 5
	dc.b	5, $6C		;keypad 6
;	dc.b	6, $67		;keypad 7
;	dc.b	7, $68		;keypad 8
;	dc.b	8, $69		;keypad 9
	dc.b	-1, -1

filename_table	dc.l	exec1,exec2,exec3,exec4,exec5,exec6,exec7,exec8,exec9
exec1	dc.b	"birdie_2.prg",0
	even
exec2	dc.b	"epssdemo.prg",0
	even
exec3	dc.b	"SNORK2.prg",0
	even
exec4	dc.b	"PUL_174.prg",0
	even
exec5	dc.b	"PE47.PRG",0
	even
exec6	dc.b	"copier.pov",0
	even
exec7	dc.b	"filename.ext",0
	even
exec8	dc.b	"filename.ext",0
	even
exec9	dc.b	"filename.ext",0
	even



mod	incbin	bit_beat.mod


	ifeq	DOWNLOAD
	SECTION BSS
	endc

bss_start
scr_now		ds.l	1
scr_xor		ds.l	1
old484		ds.w	1
stack_save	ds.l	1
vsync_flag	ds.w	1
store		ds.b	20	;store system variables in here
	even
old_base	ds.l	1
hertz_switch	ds.w	1



falcon030	ds.w	1
org_overscanbtm	ds.w	1



key		ds.w	1
org_falcon_rez	ds.w	1
oldstrez	ds.b	1
		even

hertz_toggle	ds.w	1
oldstpal	ds.b	32
off_ptr		ds.w	1
offsets		ds.w	(21*2)

s		ds.b	256
screen		ds.b	46080
		ds.b	46080

bss_end

stop


	ifne	DOWNLOAD
myend
Code_End

CODE_LENGTH	equ	myend-mycode
Code_Length	equ	Code_End-Code_Start

	endc
