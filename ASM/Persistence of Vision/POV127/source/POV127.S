*************************************************************************
*				P.O.V. 127				*
*				----------				*
*									*
* Coded By:	 MACHINE SYSTEM DATA					*
*									*
*									*
* Grafix by:	OZ							*
*									*
*									*
* Music by:	Jochen Hippel from Ghost battle				*	
*									*
*									*
* Date:		12/12/92						*
*									*
*									*
* 			All code ½ P.O.V. 1991,1992			*
* 									*
*************************************************************************

****** DOWNLOAD DEVELOPMENT SWITCHES *********************************
YES	equ	1
NO	equ	0
DOWNLOAD	equ	NO

	ifne	DOWNLOAD
	include	sttx1.s
	org	$1000

Code_Start
Exec_Addr
	ENDC
*************************************************************************

AUTORUN4=NO	;YES to use POV AUTORUN 4 (poke filename at $200 and exit)
		;NO to run program from here
FINAL=NO

	opt	o+,w-

BORDER_COLOUR=0		;Change this for border colours


	ifeq	DOWNLOAD
	ifeq	AUTORUN4
begin	bra	start
	ds.l	100
ustack	ds.l	1

; filename has already been stored in $200 so we can now P_EXEC
exec	pea	blank
	pea	blank
	pea	$200
	clr.w	-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	lea	16(sp),sp
	pea	.reset		;always reset on return from prog
	move.w	#$26,-(sp)
	trap	#14
.reset	move.l	4.w,-(sp)
	rts

blank	dc.l	0

*******************************************************************
start	move.l	4(a7),a0
	move.l	#ustack,a7
	move.l	#start-begin+$100,-(a7)	;keep only EXEC routine
	move.l	a0,-(a7)
	clr.w	-(a7)
	move.w	#$4a,-(a7)
	trap	#1
	lea	12(a7),a7
	ENDC
	ENDC

	bsr	clear_bss

	ifeq	DOWNLOAD
	bsr	set_super		;set supervisor mode (except in DL mode)
	endc


;~~~~~~~~~~~~~~~ MENU START ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

MulNops	MACRO
	REPT	\1
	nop
	ENDR
	ENDM

	move.b	#$12,$fffffc02.w	;Disable mouse
	bsr	init_routines


*************************************************************************
; Ghost Battle Semi Digi Zak
; By Jochen Hippel Of The Exceptions
*
* Relocatable version by MAC SYS DATA of PERSISTENCE OF VISION
*
* Originally ripped By Grazey From The P.H.F. Of Kingston-Upon-Hull
* Note: D0 Selects the tune and A0 points to the music data  
*
*
*
* The sample drums install on $114 
	lea	music_data,a0
	moveq	#1,d0
	jsr	music_driver(pc)
	jsr	music_driver+8(pc)
*************************************************************************

	bsr	set_palette		;set new colours
	bsr	start_interrupts		;knock out lower border

	bsr	show_pic
	bsr	flush			;flush keyboard buffer
main_loop
	bsr	flip_screen
	bsr	vsync
	move.w	hertz_switch,scroll_pal		;show a hertz change
;	move.w	#$070,$ffff8240.w
	bsr	scroll
;	move.w	pic+2,$ffff8240.w
	bsr	check_fade

	move.b	$fffffc02.w,d0

	IFEQ	FINAL
	cmp.b	#01,d0			;escape?
	beq	exit			;yes get out...
	cmp.b	#$39,d0
	beq	exit
	ENDC

	cmp.b	#$b,d0			;0 key
	beq	zero

	cmp.b	#$70,d0			;0 key
	beq	zero

	cmp.b	#$53,d0
	beq	reset

check_keys
	lea	key_codes,a6
.loop	cmp.b	#$ff,(a6)	;end of table?
	beq.s	main_loop	;yes
	cmp.b	(a6)+,d0	;is key one we want?
	beq.s	load		;yes so load demo
	move.b	(a6)+,d6	;NO so get offset
	bra.s	.loop		;check another key code


load	move.b	(a6),-(sp)	;store offset on stack for later use
 	bsr	vsync			;shut the interrupts down
	move.w	sr,-(sp)			
	move.w	#$2700,sr		
	lea	store,a0		
	move.l	(a0)+,$70.w
	move.l	(a0)+,$114.w
	move.l	(a0)+,$120.w
	move.b	(a0)+,$fffffa07.w	;restore mfp
	move.b	(a0)+,$fffffa09.w	
	move.b	(a0)+,$fffffa0d.w	
	move.b	(a0)+,$fffffa11.w	
	move.b	(a0)+,$fffffa13.w	
	move.b	(a0)+,$fffffa15.w
	move.b	(a0)+,$fffffa17.w
	move.b	(a0)+,$fffffa1d.w
	move.b	(a0)+,$fffffa23.w

	lea	$ffff8800.w,a0
	move.l	#$0707ffff,(a0)
	move.l	#$08080000,(a0)
	move.l	#$09090000,(a0)
	move.l	#$0a0a0000,(a0)
	move.b	#$c0,$fffffa23.w		
	move.w	(sp)+,sr			

	move.l	old_base,a0	;put screen base back to original value
	bsr	set_screen
	move.b	org_rez,$ffff8260.w
	bsr	black_out	;all black (where am I?)

	moveq	#0,d0		;clear D0.L
	move.b	(sp)+,d0	;get key value off stack

*** new piece of filename selector....
	lea	filename_table,a0
	lsl.w	#2,d0		;multiply D0 by 4 (one long word)
	add.w	d0,a0
	move.l	(a0),a1		;get filename address

*** now move filename into $200 for AUTORUN4 to find
	lea	$200.w,a0
	movem.l	(a1),d0/d1/d2/d3	;move 16 bytes
	movem.l	d0-d3,(a0)		;into $200


*** now check hertz and exit cleanly...
	tst.w	hertz_switch		;has hertz been pressed?
	beq.s	hz50			;no so it stays in 50Hz
	eor.b	#2,$ffff820a.w		;yes so go 60Hz
hz50	move.b	#8,$fffffc02.w		;mouse back on

***************************************************************
***** fiddle so OMEGA demo can only run from this menu!!! *****
	move.l	$84.w,$BC.w
***************************************************************
	move.l	user_stack,a7

	ifeq	DOWNLOAD
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	endc

	ifeq	DOWNLOAD
	ifeq	AUTORUN4
	bra	exec
	ELSEIF
	clr.w	-(sp)
	trap	#1
	ENDC
	ENDC

zero	tst.w	zero_counter
	bne	check_keys
	eor.w	#$123,hertz_switch	;toggle a check
	move.w	#10,zero_counter	;delay in between hertz switches
	bra	main_loop

reset	move.l	4.w,a0
	jmp	(a0)

	IFEQ	FINAL
exit	bsr	vsync			;shut the interrupts down
	move.w	sr,-(sp)			
	move.w	#$2700,sr		
	lea	store,a0		
	move.l	(a0)+,$70.w
	move.l	(a0)+,$114.w
	move.l	(a0)+,$120.w
	move.b	(a0)+,$fffffa07.w	;restore mfp
	move.b	(a0)+,$fffffa09.w	
	move.b	(a0)+,$fffffa0d.w	
	move.b	(a0)+,$fffffa11.w	
	move.b	(a0)+,$fffffa13.w	
	move.b	(a0)+,$fffffa15.w
	move.b	(a0)+,$fffffa17.w
	move.b	(a0)+,$fffffa1d.w
	move.b	(a0)+,$fffffa23.w
	move.b	#$c0,$fffffa23.w		

	lea	$ffff8800.w,a0
	move.l	#$0707ffff,(a0)
	move.l	#$08080000,(a0)
	move.l	#$09090000,(a0)
	move.l	#$0a0a0000,(a0)
	move.w	(sp)+,sr			

	move.l	old_base,a0		;put screen back to original
	bsr	set_screen
	move.b	org_rez,$ffff8260.w	;go org rez for assembler/desktop
	bsr	restore_pal		;restore colours
	move.b	#8,$fffffc02.w		;mouse back on
	move.b	old484,$484.w		;keyclick, etc
	bsr	flush			;clear keyboard buffer

	ifeq	DOWNLOAD
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	endc

	ifne	DOWNLOAD
	move.l	4.w,a0
	jmp	(a0)
	endc

	clr.w	-(sp)			;assembler/desktop
	trap	#1			;BYE!
	ENDC

***************
* Subroutines *
***************



check_fade	tst.w	fade_active
		bne.s	.active
		tst.w	fade_timer
		beq.s	.yes
		sub.w	#1,fade_timer
		rts
.yes		clr.w	fade_active
		move.w	#8,fade_active
.active		tst.w	fade_speed
		beq.s	.alt
		sub.w	#1,fade_speed
		rts
.alt		move.w	#4,fade_speed
		move.w	fade_offset,d0
		lea	palettes,a0
		move.l	0(a0,d0.w),d1
		bpl.s	.no_reset
		move.l	#palettes,d1
		clr.w	fade_offset
.no_reset	move.l	d1,a1
		bsr	fade
		sub.w	#1,fade_active
		tst.w	fade_active
		beq.s	.dead
		rts
.dead		move.w	#300,fade_timer
		add.w	#4,fade_offset
		rts


;A0=SOURCE PALETTE 	A1=TARGET PALETTE
fade		move.w	#7,d6
next_value	lea	scroll_pal,a0
		move.w	#16-1,d7
.loop		bsr	modify
		add.w	#2,a0
		add.w	#2,a1
		dbf	d7,.loop
		rts

modify	move.w	(a0),d0		;get color value
	move.w	(a1),d1		;target pal
	move.w	d0,d4		;NEW COL
	move.w	d0,d2
	move.w	d1,d3
	and.w	#$7,d2
	and.w	#$7,d3
	cmp.w	d2,d3
	beq.s	MOK1
	bmi.s	MDN1
	addq.w	#1,d4
	bra.s	MOK1
MDN1	SUBQ #1,D4
MOK1	MOVE D0,D2
	MOVE D1,D3
	AND #$70,D2
	AND #$70,D3
	CMP D2,D3
	BEQ.S MOK2
	BMI.S MDN2
	ADD #$10,D4
	BRA.S MOK2
MDN2	SUB #$10,D4
MOK2	MOVE D0,D2
	MOVE D1,D3
	AND #$700,D2
	AND #$700,D3
	CMP D2,D3
	BEQ.S MOK3
	BMI.S MDN3
	ADD #$100,D4
	BRA.S MOK3
MDN3	SUB #$100,D4
MOK3	MOVE D4,(A0)
	RTS




*-------------------------------------------------------------------

scroll	move.l	last_base,a2
	lea	((160*200)+(230-6))(a2),a2
	move.l	scroll_pointer,a4
	lea	font_offsets,a3		;font lookup table
	move.w	char_offset,d7
	moveq	#0,d2
	moveq	#51,d1
.loop	moveq	#0,d0
	move.b	(a4),d6
	bpl.s	.cont
	lea	scroll_text,a4
	bra.s	.loop
.cont	lea	font,a0
	sub.b	#32,d6		;rid of ASCII
	ext.w	d6
	moveq	#0,d0
	move.b	(a3,d6),d0	;find correct offset

	mulu	#(31*4*4),d0
	add.w	d0,a0
	move.w	d7,d0
	mulu	#(31*4),d0
	add.w	d0,a0
OFF	set	6
	REPT	31
	move.l	(a0)+,d0
	movep.l	d0,OFF(a2)
OFF	set	OFF+230
	ENDR
	addq.w	#1,d7
	and.w	#3,d7
	bne.s	.ok
	addq.w	#1,a4
	tst.b	(a4)
	bpl.s	.ok
	lea	scroll_text,a4
.ok	addq.w	#1,a2
	move.w	a2,d0
	and.w	#1,d0
	bne.s	.next
	addq.w	#6,a2
.next	dbf	d1,.loop
	move.l	scroll_pointer,a4
	addq.w	#1,d7
	and.w	#3,d7
	move.w	d7,char_offset
	bne.s	.end
	addq.w	#1,a4
	tst.b	(a4)
	bpl.s	.end
	lea	scroll_text,a4
.end	move.l	a4,scroll_pointer
	rts



********************
* SERVICE ROUTINES *
********************

flip_screen	;flip between 2 screens to stop flickering
	move.l	present_base,last_base
	move.l	screen_1,a0
	move.w	screen_number,d0
	beq	.1
	move.l	screen_2,a0
.1	move.l	a0,present_base
	eor.w	#-1,screen_number

set_screen	move.l	a0,d0
		lsr.l	#8,d0
		lea	$fffff8201.w,a0
		movep.w	d0,(a0)
		rts





flush	btst.b	#0,$fffffC00.w	;flush keyboard
	beq.s	flush2
	move.b	$fffffC02.w,d0
	bra.s	flush
flush2	rts


vsync	move.w	#$ffff,vsync_flag	;custom routine to wait
vs	tst.w	vsync_flag		;for screen refresh
	bne.s	vs
	rts


set_super
	move.l	d7,user_stack

	clr.l	-(sp)		;set supervisor mode
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,stack_save
	rts


init_routines
		movem.l	$ffff8240.w,d0-d7
		movem.l	d0-d7,old_pal

		move.l	$44e.w,old_base		;get org screen address

		move.b	$ffff8260.w,org_rez

		bsr	black_out		;make all colours black
		bsr	calc_screen		;calc our own screen address

		clr.b	$ffff8260.w		;low rez
		move.l	screen_1,a0		;new screen base
		bsr	set_screen

		move.l	screen_1,present_base
		move.l	screen_2,last_base

		move.b	$484.w,old484		;save keyboard click/speed, etc
		clr.b	$484.w			;disable repeat/click/bell


		lea	store,a0		;save mfp,vbl etc
		move.l	$70.w,(a0)+		
		move.l	$114.w,(a0)+		
		move.l	$120.w,(a0)+		
		move.b	$fffffa07.w,(a0)+	
		move.b	$fffffa09.w,(a0)+	
		move.b	$fffffa0d.w,(a0)+	
		move.b	$fffffa11.w,(a0)+	
		move.b	$fffffa13.w,(a0)+	
		move.b	$fffffa15.w,(a0)+
		move.b	$fffffa17.w,(a0)+
		move.b	$fffffa1d.w,(a0)+
		move.b	$fffffa23.w,(a0)+

		move.w	#800,fade_timer		;set init scroll fade to 800 vbls

		rts






restore_pal			;put back original colours
	lea	old_pal,a0
	bra.s	set_p

set_palette
	lea	pic+2,a0
set_p	lea	$ffff8240.w,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts





calc_screen	;calc our own screen address...
	lea	screen,a0
	move.l	a0,d0
	clr.b	d0
	move.l	d0,screen_1
	add.l	#41984,d0
	move.l	d0,screen_2
	rts



show_pic
	lea	pic+34,a0
	move.l	present_base,a1

	lea	32000-160(a0),a2
	lea	32000-160(a1),a3

	move.w	#200/2-1,d7
.loop	bsr	vsync
	movem.l	(a0),d0-d6	;28 bytes
	movem.l	d0-d6,(a1)
	movem.l	28(a0),d0-d6	;56
	movem.l	d0-d6,28(a1)
	movem.l	56(a0),d0-d6	;84
	movem.l	d0-d6,56(a1)
	movem.l	84(a0),d0-d6	;112
	movem.l	d0-d6,84(a1)
	movem.l	112(a0),d0-d6	;140
	movem.l	d0-d6,112(a1)
	movem.l	140(a0),d0-d4	;160
	movem.l	d0-d4,140(a1)
	lea	320(a0),a0
	lea	320(a1),a1

	movem.l	(a2),d0-d6	;28 bytes
	movem.l	d0-d6,(a3)
	movem.l	28(a2),d0-d6	;56
	movem.l	d0-d6,28(a3)
	movem.l	56(a2),d0-d6	;84
	movem.l	d0-d6,56(a3)
	movem.l	84(a2),d0-d6	;112
	movem.l	d0-d6,84(a3)
	movem.l	112(a2),d0-d6	;140
	movem.l	d0-d6,112(a3)
	movem.l	140(a2),d0-d4	;160
	movem.l	d0-d4,140(a3)
	lea	-320(a2),a2
	lea	-320(a3),a3
	dbf	d7,.loop

		move.l	present_base,a0		;copy to second screen
		move.l	screen_2,a1		;for flip screen
		move.w	#32000/4-1,d1
copy		move.l	(a0)+,(a1)+
		dbf	d1,copy
		rts


black_out				;all colours black
		movem.l	black,d0-d7
		movem.l	d0-d7,$ffff8240.w
		rts



clear_bss	lea	bss_start,a0
.clear		clr.l	(a0)+
		cmp.l	#bss_end,a0
		blt.s	.clear
		rts



start_interrupts		;save old interrupt values
	move.w	#$2700,sr
	move.l	#new_vbl,$70.w
	move.l	#timerb,$120.w

	bset	#0,$fffffa07.w		;ena timerb
	bclr	#0,$fffffa0f.w		;ena timerb
	bset	#0,$fffffa13.w		;ena timerb

	and.b	#%00100000,$fffffa09.w	;di timers
					;but leave timerc enabled (for the tune)


	bclr	#3,$fffffa17.w		;enable auto A-INTERRUPT IN SERVICE clear
	clr.b	$fffffa1b.w		;disable timerb
	clr.b	$fffffa21.w		;clear timerb data
	move.w	#$2300,sr
	rts				;ISRs are now running




*********
* ISRs  *
*********
new_vbl	;every screen update...
	movem.l	d0-d7/a0-a6,-(sp)	;preserve regs
	movem.l	pic+2,d0-d7		;set colours after isr
	movem.l	d0-d7,$ffff8240.w

	bsr	music_driver+4

	clr.w	vsync_flag		;own screen update rout
	tst.w	zero_counter
	beq.s	.clear
	sub.w	#1,zero_counter
.clear	movem.l	(sp)+,d0-d7/a0-a6
	move.b	#199,$fffffa21.w	;next interrupt to occur 199 lines down
	move.b	#8,$fffffa1b.w		;set interrupt method
	rte				;let's leave before interrupt occurs



timerb	move.w	#$2700,sr
	bclr	#5,$fffffa15.w		;stop timerc (digidrum) to stop flicker
	rept	50
	nop
	endr
	clr.b	$fffffa1b.w
	movem.l	d0/a0,-(sp)
	lea	$ffff8209.w,a0
	moveq	#0,d0
	move.b	(a0),d0
	sub.b	#$60,d0
	jmp	nops(pc,d0)
nops
	MulNops	97
	move.b	#0,$ffff820A.w
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w
	move.b	#2,$ffff820A.w

	move.l	scroll_pal,$ffff8240.w	;scroller font colours
	move.l	scroll_pal+4,$ffff8244.w
	move.l	scroll_pal+8,$ffff8248.w
	move.l	scroll_pal+12,$ffff824c.w
	move.l	scroll_pal+16,$ffff8250.w
	move.l	scroll_pal+20,$ffff8254.w
	move.l	scroll_pal+24,$ffff8258.w
	move.l	scroll_pal+28,$ffff825c.w

	bset	#5,$fffffa15.w

	MulNops	83-48-7-16		;-48 for colour changes
	move.b	#0,$ffff820A.w		;-7 for bset command
	move.b	#2,$ffff820A.w		;-16 for scroll pal MOVE.Ls
	MulNops	8
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	MulNops	8
	moveq	#30,d0
.line
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w
	MulNops	87
	move.b	#0,$ffff820A.w
	move.b	#2,$ffff820A.w
	MulNops	8
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	MulNops	6
	dbf	d0,.line
	MulNops	35
	movem.l	(sp)+,d0/a0
	rte



*** GOOD OLD EASYRIDER!!!!!!
music_driver
	BRA	L0004
	BRA	L0008
	BRA	L0048
	BRA	L0050
	BRA	L0001
	BRA	L0000
	PEA	(A0)
	LEA	L0064(PC),A0
	CLR.W	(A0)
	MOVEA.L	(A7)+,A0
	RTS
L0000	MOVEQ	#0,D0
	MOVE.W	L0064(PC),D0
	RTS
L0001	MOVEM.L	A0-A6/D0-D7,-(A7)
	BSR	L0002
	MOVEA.L	24(A0),A1
	ADDA.L	A0,A1
	ADD.W	D0,D0
	ADD.W	D0,D0
	ADDA.W	D0,A1
	MOVE.W	(A1)+,D2
	MOVE.W	(A1)+,D0
	BSR	L0046
	MOVEM.L	(A7)+,A0-A6/D0-D7
	RTS
L0002	LEA	L0072(PC),A0
	LEA	L0055(PC),A1
	TST.B	(A1)
	BNE.S	L0003
	ST	(A1)
	LEA	L0068(PC),A6
	MOVE.L	A0,(A6)
	MOVEA.L	4(A0),A1
	ADDA.L	A0,A1
	LEA	L0069(PC),A6
	MOVE.L	A1,(A6)
	MOVEA.L	8(A0),A1
	ADDA.L	A0,A1
	LEA	L006A(PC),A6
	MOVE.L	A1,(A6)
L0003	RTS
L0004	MOVEM.L	A0-A6/D0-D7,-(A7)
	BSR	L0005
	MOVEM.L	(A7)+,A0-A6/D0-D7
	RTS
L0005	BSR	L0049
	BSR.S	L0007
	TST.W	D0
	BEQ.S	L0006
	SUBQ.W	#1,D0
	MOVEA.L	L0066(PC),A1
	ADD.W	D0,D0
	MOVE.W	D0,D1
	ADD.W	D0,D0
	ADD.W	D1,D0
	ADDA.W	D0,A1
	MOVE.W	(A1)+,D0
	MOVE.W	(A1)+,D1
	LEA	L005B(PC),A6
	MOVE.W	(A1)+,(A6)
	BSR	L0043
	RTS
L0006:LEA	L005C(PC),A0
	ST	(A0)
	BRA	L0008
L0007:LEA	L006B(PC),A6
	MOVE.L	A0,(A6)
	MOVEA.L	4(A0),A1
	ADDA.L	A0,A1
	LEA	L006C(PC),A6
	MOVE.L	A1,(A6)
	MOVEA.L	8(A0),A1
	ADDA.L	A0,A1
	LEA	L006D(PC),A6
	MOVE.L	A1,(A6)
	MOVEA.L	12(A0),A1
	ADDA.L	A0,A1
	LEA	L0062(PC),A6
	MOVE.L	A1,(A6)
	MOVEA.L	16(A0),A1
	ADDA.L	A0,A1
	LEA	L0061(PC),A6
	MOVE.L	A1,(A6)
	MOVEA.L	20(A0),A1
	ADDA.L	A0,A1
	LEA	L0066(PC),A6
	MOVE.L	A1,(A6)+
	MOVEA.L	28(A0),A1
	ADDA.L	A0,A1
	LEA	L0067(PC),A6
	MOVE.L	A1,(A6)
	RTS
L0008	LEA	L0058(PC),A6
	LEA	L005A(PC),A5
	TST.B	4(A5)
	BEQ.S	L000A
	TST.B	5(A5)
	BNE.S	L0009
	ST	5(A5)
	MOVEQ	#0,D0
	MOVE.B	D0,34(A6)
	MOVE.B	D0,38(A6)
	MOVE.B	D0,42(A6)
	MOVE	SR,-(A7)
	MOVE	#$2700,SR
	MOVEM.L	28(A6),D0-D3
	MOVEM.L	D0-D3,$FFFF8800.W
	MOVE.B	#$A,$FFFF8800.W
	MOVE	(A7)+,SR
L0009:RTS
L000A:LEA	L006B(PC),A0
	LEA	L006E(PC),A1
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	SUBQ.W	#1,(A5)+
	BNE.S	L000B
	MOVE.W	(A5),-(A5)
	MOVEQ	#0,D5
	LEA	L005D(PC),A0
	BSR	L0012
	LEA	L005E(PC),A0
	BSR	L0012
	LEA	L005F(PC),A0
	BSR	L0012
L000B:LEA	L0063(PC),A5
	LEA	L005D(PC),A0
	BSR	L001E
	MOVE.W	D0,-(A7)
	MOVE.B	(A7)+,6(A6)
	MOVE.B	D0,2(A6)
	MOVE.B	D1,34(A6)
	LEA	L005E(PC),A0
	BSR	L001E
	MOVE.W	D0,-(A7)
	MOVE.B	(A7)+,14(A6)
	MOVE.B	D0,10(A6)
	MOVE.B	D1,38(A6)
	LEA	L005F(PC),A0
	BSR	L001E
	MOVE.W	D0,-(A7)
	MOVE.B	(A7)+,22(A6)
	MOVE.B	D0,18(A6)
	MOVE.B	D1,42(A6)
	MOVE.W	4(A5),D0
	BEQ.S	L000E
	MOVE.W	D0,-(A7)
	LEA	L0068(PC),A0
	LEA	L006E(PC),A1
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	LEA	L0060(PC),A0
	BSR	L001E
	MOVEA.L	10(A0),A1
	ADDA.L	14(A0),A1
	CMPI.B	#$E1,1(A1)
	BNE.S	L000C
	CLR.W	4(A5)
L000C:MOVE.W	(A7)+,D7
	LEA	L0059(PC),A1
	ADD.W	D7,D7
	ADD.W	D7,D7
	ADDA.W	D7,A1
	MOVEQ	#0,D6
	MOVE.B	(A1)+,D6
	MOVE.W	D0,-(A7)
	MOVE.B	D0,0(A6,D6.W)
	MOVE.B	(A1)+,D6
	MOVE.B	(A7)+,0(A6,D6.W)
	MOVE.B	(A1)+,D6
	CMP.B	#$10,D1
	BEQ.S	L000D
	SUBQ.B	#1,D1
	BPL.S	L000D
	SF	D1
L000D:MOVE.B	D1,0(A6,D6.W)
L000E:MOVE.B	(A5)+,D7
	ORI.B	#$C0,D7
	LEA	L0054(PC),A4
	TST.B	(A4)
	BEQ.S	L000F
	ORI.B	#$24,D7
L000F	MOVE.B	D7,30(A6)
	MOVE.B	(A5)+,26(A6)
	MOVEM.L	(A6),A0-A2/D0-D7
	LEA	L0054(PC),A3
	TST.B	(A3)
	BNE.S	L0011
	MOVEM.L	A0-A2/D0-D7,$FFFF8840.W
L0010	RTS
L0011	MOVE	SR,-(A7)
	MOVE	#$2700,SR
	MOVEM.L	A0-A1/D0-D7,$FFFF8840.W
	MOVE.B	#$A,$FFFF8800.W
	MOVE	(A7)+,SR
	RTS
L0012	SUBQ.B	#1,38(A0)
	BPL.S	L0010
	MOVE.B	39(A0),38(A0)
L0013	MOVEA.L	34(A0),A1
L0014	MOVE.B	(A1)+,D0
	CMP.B	#$FF,D0
	BNE.S	L0018
	MOVEA.L	52(A0),A3
	MOVEA.L	(A0),A2
	ADDA.L	4(A0),A2
	CMPA.L	A3,A2
	BNE.S	L0015
	MOVE.L	D5,4(A0)
	MOVEA.L	(A0),A2
L0015:MOVEQ	#0,D1
	MOVE.B	(A2),D1
	MOVE.B	1(A2),44(A0)
	MOVE.B	2(A2),22(A0)
	MOVE.B	3(A2),D0
	MOVE.B	D0,D2
	ANDI.W	#$F0,D2
	CMP.W	#$F0,D2
	BNE.S	L0016
	MOVE.B	D0,D2
	ANDI.B	#$F,D2
	MOVE.B	D2,40(A0)
	BRA.S	L0017
L0016:CMP.B	#$E0,D2
	BNE.S	L0017
	MOVE.B	D0,D2
	ANDI.W	#$F,D2
	MOVE.W	D2,2(A5)
L0017:ADD.W	D1,D1
	MOVEA.L	L0062(PC),A3
	MOVEA.W	0(A3,D1.W),A3
	ADDA.L	L006E(PC),A3
	MOVE.L	A3,34(A0)
	ADDI.L	#$C,4(A0)
	BRA	L0013
L0018:CMP.B	#$FE,D0
	BNE.S	L0019
	MOVE.B	(A1),39(A0)
	MOVE.B	(A1)+,38(A0)
	BRA	L0014
L0019:CMP.B	#$FD,D0
	BNE.S	L001A
	MOVE.B	(A1),39(A0)
	MOVE.B	(A1)+,38(A0)
	MOVE.L	A1,34(A0)
	RTS
L001A:MOVE.B	D0,8(A0)
	MOVE.B	(A1)+,D1
	MOVE.B	D1,9(A0)
	ANDI.W	#$E0,D1
	BEQ.S	L001B
	MOVE.B	(A1)+,31(A0)
L001B:MOVE.L	A1,34(A0)
	MOVE.L	D5,56(A0)
	TST.B	D0
	BMI.S	L001D
	MOVE.B	9(A0),D1
	MOVE.B	D1,D0
	ANDI.W	#$1F,D1
	ADD.B	22(A0),D1
	MOVEA.L	L0070(PC),A2
	ADD.W	D1,D1
	MOVEA.W	0(A2,D1.W),A2
	ADDA.L	L006E(PC),A2
	MOVE.L	D5,14(A0)
	MOVE.B	(A2),23(A0)
	MOVE.B	(A2)+,24(A0)
	MOVEQ	#0,D1
	MOVE.B	(A2)+,D1
	MOVE.B	(A2)+,27(A0)
	MOVE.B	#$40,46(A0)
	MOVE.B	(A2)+,D2
	MOVE.B	D2,28(A0)
	MOVE.B	D2,29(A0)
	MOVE.B	(A2)+,30(A0)
	MOVE.L	A2,10(A0)
	ANDI.B	#$40,D0
	BEQ.S	L001C
	MOVE.B	31(A0),D1
L001C:MOVEA.L	L006F(PC),A2
	ADD.W	D1,D1
	MOVEA.W	0(A2,D1.W),A2
	ADDA.L	L006E(PC),A2
	MOVE.L	A2,18(A0)
	MOVE.L	D5,48(A0)
	MOVE.B	D5,26(A0)
	MOVE.B	D5,25(A0)
L001D:RTS
L001E:MOVEQ	#0,D7
	MOVE.B	D7,32(A0)
L001F:TST.B	26(A0)
	BEQ.S	L0020
	SUBQ.B	#1,26(A0)
	BRA	L002B
L0020:MOVEA.L	18(A0),A1
	ADDA.L	48(A0),A1
	CMPI.B	#$E1,(A1)
	BEQ	L002B
	CMPI.B	#$E0,(A1)
	BNE	L0021
	MOVE.B	1(A1),D0
	ANDI.L	#$3F,D0
	MOVE.L	D0,48(A0)
	MOVEA.L	18(A0),A1
	ADDA.L	D0,A1
L0021:CMPI.B	#$E2,(A1)
	BNE	L0022
	CLR.L	14(A0)
	MOVE.B	#1,23(A0)
	ADDQ.L	#1,48(A0)
	BRA	L0020
L0022:CMPI.B	#$E9,(A1)
	BNE	L0023
	MOVE	SR,-(A7)
	MOVE	#$2700,SR
	MOVE.B	#$B,$FFFF8800.W
	MOVE.B	1(A1),$FFFF8802.W
	MOVE.B	#$C,$FFFF8800.W
	MOVE.B	#0,$FFFF8802.W
	MOVE.B	#$D,$FFFF8800.W
	MOVE.B	#$A,$FFFF8802.W
	MOVE.B	#$A,$FFFF8800.W
	MOVE	(A7)+,SR
	ADDQ.L	#2,48(A0)
	BRA	L0020
L0023:CMPI.B	#$E7,(A1)
	BNE.S	L0024
	LEA	L0054(PC),A4
	SF	(A4)
	ANDI.B	#$F,$FFFFFA1D.W
	ADDQ.L	#1,48(A0)
	BRA	L0020
L0024:CMPI.B	#$E8,(A1)
	BNE.S	L0025
	MOVE.B	1(A1),26(A0)
	ADDQ.L	#2,48(A0)
	BRA	L001F
L0025:CMPI.B	#$E4,(A1)
	BNE.S	L0026
	MOVE.B	D7,42(A0)
	MOVE.B	1(A1),32(A0)
	ADDQ.L	#2,48(A0)
	BRA	L002A
L0026:CMPI.B	#$E5,(A1)
	BNE.S	L0027
	MOVE.B	#1,42(A0)
	ADDQ.L	#1,48(A0)
	BRA	L001F
L0027:CMPI.B	#$E6,(A1)
	BNE.S	L0028
	MOVE.B	#2,42(A0)
	ADDQ.L	#1,48(A0)
	BRA	L002A

L0028	CMPI.B	#$E3,(A1)
	BNE.S	L0029
	ADDQ.L	#3,48(A0)
	MOVE.B	1(A1),27(A0)
	MOVE.B	2(A1),28(A0)
L0029	CMPI.B	#$EA,(A1)
	BNE	L002A
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.B	1(A1),D0
	ADD.W	D0,D0
	ADD.W	D0,D0
	ADD.W	D0,D0
	ADD.L	L0067(PC),D0
	MOVEA.L	D0,A2
	LEA	L0054(PC),A4
	ST	(A4)
	MOVEA.W	(A2)+,A1
	ADDA.L	L0067(PC),A1
	LEA	L0052(PC),A2
	MOVE.l	A1,(A2)		;this is the first fix...
	ANDI.B	#$F,$FFFFFA1D.W		;stop timerc
	ORI.B	#$10,$FFFFFA1D.W	;make timerc run delay_mode/4
	MOVE.B	#$66,$FFFFFA23.W	;timerc data reg
	ADDQ.L	#3,48(A0)
	RTS
L002A	MOVEA.L	18(A0),A1
	ADDA.L	48(A0),A1
	MOVE.B	(A1),43(A0)
	ADDQ.L	#1,48(A0)
L002B:TST.B	25(A0)
	BEQ.S	L002C
	SUBQ.B	#1,25(A0)
	BRA.S	L0030
L002C:SUBQ.B	#1,23(A0)
	BNE.S	L0030
	MOVE.B	24(A0),23(A0)
L002D:MOVEA.L	10(A0),A1
	ADDA.L	14(A0),A1
	MOVE.B	(A1),D0
	CMP.B	#$E8,D0
	BNE.S	L002E
	ADDQ.L	#2,14(A0)
	MOVE.B	1(A1),25(A0)
	BRA.S	L002B
L002E:CMP.B	#$E1,D0
	BEQ.S	L0030
	CMP.B	#$E0,D0
	BNE.S	L002F
	MOVE.B	1(A1),D0
	ANDI.L	#$3F,D0
	SUBQ.L	#5,D0
	MOVE.L	D0,14(A0)
	BRA.S	L002D
L002F:MOVE.B	(A1),45(A0)
	ADDQ.L	#1,14(A0)
L0030:MOVE.B	43(A0),D0
	BMI.S	L0031
	ADD.B	8(A0),D0
	ADD.B	44(A0),D0
L0031:ANDI.W	#$7F,D0
	LEA	L0071(PC),A1
	ADD.W	D0,D0
	MOVE.W	D0,D1
	ADDA.W	D0,A1
	MOVE.W	(A1),D0
	MOVE.B	33(A0),D3
	MOVE.B	42(A0),D2
	ANDI.L	#$F,D2
	BNE.S	L0032
	BCLR	D3,(A5)
	ADDQ.W	#3,D3
	BCLR	D3,(A5)
	BRA.S	L0035
L0032:CMP.B	#1,D2
	BNE.S	L0034
	BSET	D3,(A5)
	ADDQ.W	#3,D3
	BCLR	D3,(A5)
	MOVE.B	8(A0),32(A0)
	MOVE.B	43(A0),D4
	BPL.S	L0033
	ANDI.B	#$7F,D4
	MOVE.B	D4,32(A0)
	BRA.S	L0035
L0033:ADD.B	D4,32(A0)
	BRA.S	L0035
L0034:BCLR	D3,(A5)
	ADDQ.W	#3,D3
	BSET	D3,(A5)
L0035:TST.B	32(A0)
	BEQ.S	L0036
	MOVE.B	32(A0),D3
	ANDI.B	#$1F,D3
	EORI.B	#$1F,D3
	MOVE.B	D3,1(A5)
L0036:MOVE.B	46(A0),D7
	TST.B	30(A0)
	BEQ.S	L0037
	SUBQ.B	#1,30(A0)
	BRA.S	L003F
L0037:MOVE.B	D1,D5
	MOVE.B	28(A0),D4
	ADD.B	D4,D4
	MOVE.B	29(A0),D1
	TST.B	D7
	BPL.S	L0038
	BTST	#0,D7
	BNE.S	L003B
L0038:BTST	#5,D7
	BNE.S	L0039
	SUB.B	27(A0),D1
	BCC.S	L003A
	BSET	#5,D7
	MOVEQ	#0,D1
	BRA.S	L003A
L0039:ADD.B	27(A0),D1
	CMP.B	D4,D1
	BCS.S	L003A
	BCLR	#5,D7
	MOVE.B	D4,D1
L003A:MOVE.B	D1,29(A0)
L003B:LSR.B	#1,D4
	SUB.B	D4,D1
	BCC.S	L003C
	SUBI.W	#$100,D1
L003C:ADDI.B	#$A0,D5
	BCS.S	L003E
L003D:ADD.W	D1,D1
	ADDI.B	#$18,D5
	BCC.S	L003D
L003E:ADD.W	D1,D0
L003F:EORI.B	#1,D7
	MOVE.B	D7,46(A0)
	BTST	#5,9(A0)
	BEQ	L0040
	MOVEQ	#0,D7
	MOVE.W	D7,D1
	MOVE.B	31(A0),D1
	EXT.W	D1
	MOVE.L	56(A0),D2
	MOVEQ	#$C,D3
	ASL.L	D3,D1
	ADD.L	D1,D2
	MOVE.L	D2,56(A0)
	SWAP	D2
	SUB.W	D2,D0
L0040:MOVE.B	45(A0),D1
	SUB.B	40(A0),D1
	CMP.B	#$10,D1
	BEQ.S	L0042
	LEA	L0064(PC),A1
	TST.W	(A1)
	BEQ.S	L0041
	LEA	L0060(PC),A1
	CMPA.L	A1,A0
	BEQ.S	L0041
	SUBQ.B	#1,D1
L0041:TST.B	D1
	BPL.S	L0042
	MOVEQ	#0,D1
L0042:RTS
L0043:LEA	L0065(PC),A0
	CLR.L	(A0)
	MOVE.L	D0,D7
	MULU	#$C,D7
	MOVE.L	D1,D6
	ADDQ.L	#1,D6
	MULU	#$C,D6
	MOVEQ	#2,D0
	LEA	L005D(PC),A0
	LEA	L0056(PC),A1
	LEA	L0057(PC),A2
L0044:MOVE.L	A1,10(A0)
	CLR.L	14(A0)
	CLR.B	45(A0)
	CLR.B	8(A0)
	CLR.B	9(A0)
	MOVE.L	A1,18(A0)
	CLR.L	48(A0)
	MOVE.B	#1,23(A0)
	MOVE.B	#1,24(A0)
	CLR.B	25(A0)
	CLR.L	26(A0)
	CLR.W	30(A0)
	CLR.B	32(A0)
	MOVE.B	(A2),D3
	ANDI.L	#$F,D3
	ADD.W	D3,D3
	ADD.W	D3,D3
	MOVE.B	(A2)+,33(A0)
	MOVE.L	L0061(PC),(A0)
	MOVE.L	L0061(PC),52(A0)
	ADD.L	D6,52(A0)
	ADD.L	D3,52(A0)
	ADD.L	D7,(A0)
	ADD.L	D3,(A0)
	MOVE.L	#$C,4(A0)
	MOVEA.L	(A0),A3
	MOVE.B	(A3),D1
	ANDI.L	#$FF,D1
	ADD.W	D1,D1
	MOVEA.L	L0062(PC),A4
	MOVEA.W	0(A4,D1.W),A4
	ADDA.L	L006B(PC),A4
	MOVE.L	A4,34(A0)
	CLR.L	38(A0)
	MOVE.B	#2,42(A0)
	MOVE.B	1(A3),44(A0)
	CLR.B	43(A0)
	MOVE.B	2(A3),22(A0)
	CLR.B	40(A0)
	MOVE.B	3(A3),D1
	ANDI.W	#$F0,D1
	CMP.W	#$F0,D1
	BNE.S	L0045
	MOVE.B	3(A3),D1
	ANDI.B	#$F,D1
	MOVE.B	D1,40(A0)
L0045:CLR.B	45(A0)
	CLR.L	56(A0)
	ADDA.L	#$3C,A0
	DBF	D0,L0044
	LEA	L005A(PC),A0
	MOVE.W	#1,(A0)
	CLR.W	4(A0)
	LEA	L0054(PC),A0
	SF	(A0)
	RTS
L0046:MOVEQ	#1,D1
	TST.W	D2
	BEQ	L0047
	LEA	L0060(PC),A0
	LEA	L0063(PC),A5
	MOVE.B	D2,8(A0)
	MOVE.B	D1,33(A0)
	CLR.B	22(A0)
	MOVEQ	#0,D5
	ANDI.W	#$FF,D0
	MOVEA.L	L006A(PC),A2
	ADD.W	D0,D0
	MOVEA.W	0(A2,D0.W),A2
	ADDA.L	L0068(PC),A2
	MOVE.L	D5,14(A0)
	MOVE.B	(A2),23(A0)
	MOVE.B	(A2)+,24(A0)
	MOVE.B	(A2)+,D0
	ANDI.W	#$FF,D0
	MOVE.B	(A2)+,27(A0)
	MOVEQ	#0,D2
	MOVE.B	#$40,46(A0)
	MOVE.B	(A2)+,D2
	MOVE.B	D2,28(A0)
	MOVE.B	D2,29(A0)
	MOVE.B	(A2)+,30(A0)
	MOVE.L	A2,10(A0)
	MOVEA.L	L0069(PC),A2
	ADD.W	D0,D0
	MOVEA.W	0(A2,D0.W),A2
	ADDA.L	L0068(PC),A2
	MOVE.L	A2,18(A0)
	MOVE.L	D5,48(A0)
	CLR.B	25(A0)
	CLR.B	26(A0)
	CLR.L	56(A0)
	CLR.B	31(A0)
	ADDQ.W	#1,D1
	MOVE.W	D1,4(A5)
L0047	RTS
L0048	MOVE	SR,-(A7)
	MOVE	#$2700,SR
	BSET	#5,$FFFFFA09.W		;ena timerc
	BSET	#5,$FFFFFA0D.W		;ena timerc
	BSET	#5,$FFFFFA15.W		;ena timerc
	BCLR	#5,$FFFFFA11.W		;clear isr in service timerc
	ANDI.B	#7,$FFFFFA1D.W		;start timerc running
	LEA	L0051(PC),A1
	MOVE.L	A1,$114.W
	MOVE.L	#$707FFFF,$FFFF8800.W
	MOVE.B	#$A,$FFFF8800.W
	MOVE	(A7)+,SR
	RTS
L0049	MOVEA.L	A0,A1
	MOVEA.L	28(A1),A1
	ADDA.L	A0,A1
	CMPI.L	#$4A4F4348,192(A1)
	BEQ.S	L004A
	MOVE.L	#$4A4F4348,192(A1)
	MOVEM.L	A0/D0,-(A7)
	BSR	L004B
	MOVEM.L	(A7)+,A0/D0
L004A	RTS
L004B	MOVEA.L	A1,A0
	LEA	256(A0),A1
	MOVEA.L	A1,A2
	MOVE.L	252(A0),D0
	SUBI.L	#$100,D0
	ADDA.L	D0,A2
L004C:MOVE.B	(A1),D0
	CMP.B	#$FF,D0
	BNE.S	L004D
	MOVE.B	#$88,D0
	BRA.S	L004E
L004D:EORI.B	#$80,D0
	LSR.B	#4,D0
	ANDI.W	#$F,D0
	MOVE.B	L004F(PC,D0.W),D0
L004E:MOVE.B	D0,(A1)+
	CMPA.L	A2,A1
	BLE.S	L004C
	RTS
L004F	DC.B	$00,$07,$09,$0A,$0B,$0C,$0C,$0D
	DC.B	$0D,$0D,$0E,$0E,$0E,$0F,$0F,$0F
L0050	MOVE	SR,-(A7)
	MOVE	#$2700,SR
	ANDI.B	#$F,$FFFFFA1D.W		;stop timerc by clearing its data reg
	MOVE	(A7)+,SR
	RTS
L0051	move.b	$deadface,$ffff8802.w
L0052	EQU	*-6		;this is the 2nd fix
	BMI.S	L0053 
	ADDQ.l	#1,L0052	;this is the 3rd fix
	RTE
L0053	PEA	(A0)
	LEA	L0054(PC),A0
	SF	(A0)
	ANDI.B	#$F,$FFFFFA1D.W		;stop timerc by clearing its data reg
	MOVEA.L	(A7)+,A0
	RTE
L0054	dc.b	0
L0055	dc.w	0,0,0,0
L0056	DC.B	$01,$00,$00,$00,$00,$00,$00,$E1
L0057	dc.b	0,1,2,0
L0058	DCB.W	2,0
	DC.B	$01,$01,$00,$00,$02,$02,$00,$00
	DC.B	$03,$03,$00,$00,$04,$04,$00,$00
	DC.B	$05,$05,$00,$00,$06,$06,$00,$00
	DC.B	$07,$07,$FF,$FF,$08,$08,$00,$00
	DC.B	$09,$09,$00,$00,$0A,$0A,$00,$00
L0059:DCB.W	2,0
	DC.B	$02,$06,'"',$00,$0A,$0E,'&',$00
	DC.B	$12,$16,'*',$00
L005A:DC.B	$00,$04
L005B:DC.B	$00,$04
L005C:DC.B	$FF,$00,$00,$01,$02,$03,$04,$05
	DC.B	$06,$07,$08,$09,$0A,$0B,$0F,$0F
	DC.B	$0F,$0F,$0F,$0F
L005D:DCB.W	30,0
L005E:DCB.W	30,0
L005F:DCB.W	30,0
L0060:DCB.W	30,0
L0061:DCB.W	2,0
L0062:DCB.W	2,0
L0063:DCB.W	2,0
L0064:DCB.W	2,0
L0065:DCB.W	2,0
L0066:DCB.W	2,0
L0067:DCB.W	2,0
L0068:DCB.W	2,0
L0069:DCB.W	2,0
L006A:DCB.W	2,0
L006B:DCB.W	2,0
L006C:DCB.W	2,0
L006D:DCB.W	2,0
L006E:DCB.W	2,0
L006F:DCB.W	2,0
L0070:DCB.W	3,0
L0071:DC.B	$0E,$EE,$0E,$17,$0D,'M',$0C,$8E
	DC.B	$0B,$D9,$0B,'/',$0A,$8E,$09,$F7
	DC.B	$09,'g',$08,$E0,$08,'a',$07,$E8
	DC.B	$07,'w',$07,$0B,$06,$A6,$06,'G'
	DC.B	$05,$EC,$05,$97,$05,'G',$04,$FB
	DC.B	$04,$B3,$04,'p',$04,'0',$03,$F4
	DC.B	$03,$BB,$03,$85,$03,'S',$03,'#'
	DC.B	$02,$F6,$02,$CB,$02,$A3,$02,'}'
	DC.B	$02,'Y',$02,'8',$02,$18,$01,$FA
	DC.B	$01,$DD,$01,$C2,$01,$A9,$01,$91
	DC.B	$01,'{',$01,'e',$01,'Q',$01,'>'
	DC.B	$01,',',$01,$1C,$01,$0C,$00,$FD
	DC.B	$00,$EE,$00,$E1,$00,$D4,$00,$C8
	DC.B	$00,$BD,$00,$B2,$00,$A8,$00,$9F
	DC.B	$00,$96,$00,$8E,$00,$86,$00,'~'
	DC.B	$00,'w',$00,'p',$00,'j',$00,'d'
	DC.B	$00,'^',$00,'Y',$00,'T',$00,'O'
	DC.B	$00,'K',$00,'G',$00,'C',$00,'?'
	DC.B	$00,';',$00,'8',$00,'5',$00,'2'
	DC.B	$00,'/',$00,',',$00,'*',$00,$27
	DC.B	$00,'%',$00,'#',$00,'!',$00,$1F
	DC.B	$00,$1D,$00,$1C,$00,$1A,$00,$19
	DC.B	$00,$17,$00,$16,$00,$15,$00,$13
	DC.B	$00,$12,$00,$11,$00,$10,$00,$0F
L0072	DC.B	'COSO',$00,$00,$00,' '
	DC.B	$00,$00,$01,$D8,$00,$00,$04,'0'
	DC.B	$00,$00,$04,'6',$00,$00,$04,'B'
	DC.B	$00,$00,$04,'H',$00,$00,$04,$CC
	DC.B	$00,'H',$00,'^',$00,$8F,$00,$A7
	DC.B	$00,$C0,$00,$D6,$00,$E4,$00,$F9
	DC.B	$01,$05,$01,$15,$01,'4',$01,'='
	DC.B	$01,'Q',$01,'[',$01,'m',$01,'v'
	DC.B	$01,$85,$01,$92,$01,$AD,$01,$C1
	DC.B	$E2,$E5,$98,$96,$94,$92,$90,$8E
	DC.B	$8C,$8A,$8A,$8C,$8E,$90,$92,$94
	DC.B	$96,$98,$9A,$9C,$9E,$E1,$E2,$E5
	DC.B	$98,$E6,$00,$02,$E5,$98,$94,$93
	DC.B	$92,'4',$93,$92,'C!A#'
	DC.B	'B„r',$96,'ti„v'
	DC.B	'9HV#”v)G'
	DC.B	'b7”e#G4',$93
	DC.B	'y',$82,'Y',$02,'v',$E0,$07,$E2
	DC.B	$E5,$98,$94,$90,$8C,$88,$80,$81
	DC.B	$82,$83,$84,$85,$86,$87,$86,$85
	DC.B	$84,$83,$82,$81,$80,$E0,$08,$E2
	DC.B	$E6,$00,$00,$E9,$11,$00,$00,$E9
	DC.B	$10,$00,$00,$E9,$11,$00,$00,$E6
	DC.B	$18,$16,$14,$12,$E5,$10,$E0,$10
	DC.B	$E2,$E5,$98,$E6,$00,$01,$02,$03
	DC.B	$04,$05,$06,$07,$08,$07,$06,$05
	DC.B	$04,$03,$02,$01,$00,$E1,$E2,$E5
	DC.B	$98,$E6,$10,$0E,$0C,$0A,$08,$06
	DC.B	$04,$02,$00,$E1,$E2,$E5,$98,$E6
	DC.B	$00,$02,$E5,$98,$96,$94,$92,$90
	DC.B	$8E,$8C,$8A,$88,$86,$84,$82,$80
	DC.B	$E1,$E2,$E6,$04,$04,$04,$04,$00
	DC.B	$00,$00,$00,$E0,$02,$E2,$E6,$00
	DC.B	$02,$E5,$90,$8C,$88,$84,$80,$80
	DC.B	$80,$80,$80,$E0,$05,$E2,$E5,$80
	DC.B	$80,$80,$80,$84,$88,$8C,$90,$94
	DC.B	$98,$9C,$9F,$9F,$9F,$9F,$9F,$9F
	DC.B	$9F,$9F,$9C,$98,$94,$90,$8C,$88
	DC.B	$84,$80,$E0,$19,$E2,$E5,$98,$E6
	DC.B	$07,$05,$03,$E0,$01,$E2,$E5,$98
	DC.B	$E6,$00,$02,$E5,$98,$E6,$00,$04
	DC.B	$08,$0C,$10,$14,$18,$1C,$10,$E0
	DC.B	$09,$E2,$E5,$98,$E6,$10,$0C,$08
	DC.B	$04,$00,$E1,$E2,$E5,$88,$E6,$04
	DC.B	$02,$E5,$9F,$9C,$98,$94,$90,$8C
	DC.B	$88,$84,$80,$E0,$07,$E2,$E6,$00
	DC.B	$04,$08,$0C,$10,$E0,$02,$E2,$E5
	DC.B	$98,$E6,$9D,$9F,$E5,$98,$94,$90
	DC.B	$8C,$88,$84,$80,$E1,$E2,$E6,$00
	DC.B	$01,$02,$03,$04,$03,$02,$01,$00
	DC.B	$E0,$02,$E2,$E5,$90,$E6,$10,$E5
	DC.B	$90,$E6,$0C,$E5,$90,$E6,$08,$E5
	DC.B	$90,$E6,$04,$E5,$94,$E6,$00,$E5
	DC.B	$94,$E6,$04,$E0,$01,$E2,$E5,$90
	DC.B	$8F,$8E,$8D,$8C,$8B,$8A,$88,$87
	DC.B	$86,$85,$84,$83,$82,$81,$80,$E0
	DC.B	$02,$E2,$E9,'@',$00,$E4,$00,$00
	DC.B	$00,$01,$E8,' ',$02,$E8,' ',$03
	DC.B	$E8,' ',$04,$E8,' ',$05,$E1,$94
	DC.B	$02,$02,$02,$19,$02,'A',$02,'V'
	DC.B	$02,'{',$02,$90,$02,$9E,$02,$BA
	DC.B	$02,$CE,$02,$F5,$03,$13,$03,'*'
	DC.B	$03,'H',$03,'V',$03,'{',$03,$8D
	DC.B	$03,$A9,$03,$BB,$03,$CE,$03,$E4
	DC.B	$03,$EF,$01,$00,$00,$00,$00,$0D
	DC.B	$0C,$0C,$0C,$0B,$0B,$0A,$09,$08
	DC.B	$07,$06,$05,$04,$03,$02,$01,$00
	DC.B	$E1,$01,$01,$00,$00,$00,$0D,$0F
	DC.B	$0F,$0E,$0E,$0D,$0D,$0C,$0C,$0B
	DC.B	$0B,$0A,$0A,$09,$09,$08,$08,$07
	DC.B	$07,$06,$06,$05,$05,$04,$04,$03
	DC.B	$03,$02,$02,$02,$01,$01,$01,$00
	DC.B	$E1,$03,$02,$00,$00,$00,$0E,$0D
	DC.B	$0C,$0B,$0A,$09,$08,$07,$05,$05
	DC.B	$04,$03,$02,$01,$00,$E1,$02,$03
	DC.B	$00,$00,$00,$0D,$10,$10,$10,$0F
	DC.B	$0E,$0D,$0C,$0B,$0B,$0A,$0A,$09
	DC.B	$09,$08,$08,$07,$07,$06,$06,$05
	DC.B	$05,$04,$04,$03,$03,$02,$02,$01
	DC.B	$01,$00,$E1,$01,$04,$00,$00,$00
	DC.B	$0A,$0F,$0E,$0D,$0C,$0B,$0B,$0A
	DC.B	$0A,$09,$08,$07,$07,$06,$00,$E1
	DC.B	$01,$05,$00,$00,$00,$0A,$0D,$0D
	DC.B	$0A,$08,$07,$03,$00,$E1,$01,$06
	DC.B	$00,$00,$00,$0D,$0F,$0F,$0E,$0E
	DC.B	$0E,$0D,$0D,$0C,$0C,$0B,$0A,$0C
	DC.B	$08,$07,$06,$07,$04,$03,$02,$01
	DC.B	$00,$E1,$03,$07,$00,$00,$00,$0D
	DC.B	$0C,$0B,$0A,$09,$08,$07,$06,$05
	DC.B	$04,$03,$02,$01,$00,$E1,$01,$08
	DC.B	$00,$00,$00,$0D,$0F,$0F,$0E,$0E
	DC.B	$0D,$0D,$0C,$0C,$0B,$0B,$0A,$0A
	DC.B	$09,$09,$08,$08,$08,$07,$07,$07
	DC.B	$06,$06,$05,$05,$04,$04,$03,$03
	DC.B	$02,$02,$01,$00,$E1,$02,$09,$00
	DC.B	$00,$00,$0A,$0B,$0C,$0D,$E8,$04
	DC.B	$0C,$0C,$0B,$0B,$0A,$09,$08,$07
	DC.B	$07,$06,$06,$05,$05,$04,$04,$03
	DC.B	$03,$00,$E1,$01,$0A,$00,$00,$00
	DC.B	$0D,$0F,$0E,$0D,$0C,$0B,$0A,$09
	DC.B	$08,$07,$06,$05,$04,$03,$02,$01
	DC.B	$00,$E1,$01,$0B,$00,$00,$00,$0D
	DC.B	$0F,$0F,$0E,$0E,$0D,$0D,$0C,$0C
	DC.B	$0B,$0B,$0A,$0A,$09,$09,$08,$08
	DC.B	$07,$07,$06,$05,$04,$02,$00,$E1
	DC.B	$01,$0C,$00,$00,$00,$0D,$0F,$0F
	DC.B	$0E,$0E,$0D,$0A,$00,$E1,$04,$0D
	DC.B	$00,$00,$00,$0F,$0E,$0E,$0E,$0E
	DC.B	$0D,$0D,$0C,$0C,$0B,$0B,$0A,$0A
	DC.B	$09,$09,$08,$08,$07,$07,$06,$06
	DC.B	$05,$05,$04,$04,$03,$02,$03,$02
	DC.B	$02,$00,$E1,$02,$0E,$00,$00,$00
	DC.B	$0D,$0D,$0D,$0D,$0C,$0C,$0C,$0C
	DC.B	$0A,$0A,$08,$00,$E1,$01,$0F,$00
	DC.B	$00,$00,$0D,$0F,$0F,$0D,$0D,$0D
	DC.B	$0C,$0C,$0B,$0B,$0A,$0A,$09,$09
	DC.B	$08,$08,$07,$07,$06,$06,$05,$00
	DC.B	$E1,$01,$10,$00,$00,$00,$0D,$0E
	DC.B	$0E,$0E,$0E,$0D,$0D,$0C,$0C,$0B
	DC.B	$0A,$00,$E1,$01,$11,$00,$00,$00
	DC.B	$0D,$0F,$0D,$0D,$0A,$0D,$0A,$0D
	DC.B	$0A,$0D,$0A,$0A,$00,$E1,$03,$12
	DC.B	$00,$00,$00,$0F,$0E,$0D,$0C,$0B
	DC.B	$0A,$09,$08,$07,$06,$05,$04,$03
	DC.B	$02,$01,$00,$E1,$01,$10,$00,$00
	DCB.W	3,0
	DC.B	$E1,$01,$13,$00,$00,$00,$10,$10
	DC.B	$10,$00,$00,$10,$00,$00,$00,$10
	DCB.W	2,0
	DC.B	$10,$00,$00,$00,$00,$00,$10,$00
	DCB.W	2,0
	DC.B	$00,$10,$00,$00,$00,$00,$00,$00
	DC.B	$00,$00,$10,$00,$00,$00,$00,$00
	DCB.W	2,0
	DC.B	$00,$10,$00,$00,$00,$00,$00,$00
	DC.B	$00,$00,$10,$00,$E1,$07,$04,'2'
	DC.B	$FD,$1F,$FF,$04,$00,$00,$00,$00
	DCB.W	7,0
	DC.B	$00,$01,$00,$00,$00,$1E,$00,$01
	DC.B	$00,$01,$00,$02,$00,$1D,$00,$03
	DC.B	$00,$14,$00,$04,$00,'#',$00,$05
	DC.B	$00,$1A,$00,$06,$00,',',$00,$07
	DC.B	$00,$1B,$00,$08,$00,$01,$00,$09
	DC.B	$00,$19,$00,$0A,$00,$1F,$00,$0B
	DC.B	$00,$0E,$00,$0C,$00,$1D,$00,$0D
	DC.B	$00,'4',$00,$0E,$00,$02,$00,$0F
	DC.B	$00,$11,$00,$10,$00,$11,$00,$11
	DC.B	$00,$01,$00,$12,$00,$01,$00,$13
	DC.B	$00,'$',$00,$14,$00,$00,$00,$00
	DCB.W	11,0
	DC.B	$03,$12,$00,$00,$00,$0F,$0E,$0D
	DC.B	$0C,$0B,$0A,$09,$08,$07,$06,$05
	DC.B	$04,$03,$02,$01,$00,$E1

music_data	incbin	gbdata5
		dc.l	0	;must be here as tune uses it!
;List Of Relevant Files :

; gbdata1 - Loding Music
; gbdata2 - Title  Music 
; gbdata3 - Congratualtions  Music 
; gbdata4 - Level  Music 
; gbdata5 - Level  Music 
; gbdata6 - Level  Music 
; gbdata7 - Level  Music 



	ifeq	DOWNLOAD
	SECTION DATA
	endc




scroll_pal	dc.w	$000,$556,$335,$224,$500,$600,$700,$720
		dc.w	$730,$740,$750,$760,$770,$774,$247,$057



palettes	dc.l	pal1
		dc.l	pal2
		dc.l	pal3
		dc.l	pal4
		dc.l	pal5
		dc.l	pal6
		dc.l	pal7
		dc.l	-1


pal1	dc.w	$000,$556,$335,$224,$500,$600,$700,$720
	dc.w	$730,$740,$750,$760,$770,$774,$247,$057
pal2	dc.w	$000,$650,$540,$320,$500,$600,$700,$720
	dc.w	$730,$740,$750,$760,$770,$774,$247,$057
pal3	dc.w	$000,$750,$530,$330,$300,$400,$500,$600
	dc.w	$700,$600,$500,$400,$300,$200,$000,$000
pal4	dc.w	$000,$066,$044,$033,$003,$004,$005,$006
	dc.w	$007,$107,$207,$307,$407,$407,$000,$000
pal5	dc.w	$000,$666,$444,$333,$303,$404,$505,$606
	dc.w	$707,$717,$727,$737,$747,$757,$000,$000
pal6	dc.w	$000,$666,$555,$444,$000,$000,$000,$000
	dc.w	$000,$000,$000,$110,$000,$000,$000,$000
pal7	dc.w	$000,$057,$047,$015,$300,$400,$500,$600
	dc.w	$700,$700,$700,$700,$700,$700,$000,$000



scroll_pointer	dc.l	scroll_text+7
scroll_text
 DC.B "                                        "
 dc.b " MERRY CHRISTMAS AND WELCOME TO } DISC 127, RELEASE DATE 25TH DECEMBER 1992.      "
 dc.b "       IT SEEMS THAT SOME PEOPLE HAVE BEEN SPREADING "
 DC.B "RUMOURS ABOUT } AND THAT WE SPLIT UP.  AS YOU CAN SEE WE ARE "
 DC.B "NOT DEAD BUT WE HAVE BEEN BUSY ON OTHER THINGS AND THE "
 DC.B "COMPILATIONS WERE PUT ON ICE.   THE MORAL IS... DON'T BELEIVE "
 dc.b "EVERYTHING YOU READ IN DISC MAGS.....    RIGHT THAT'S CLEARED UP "
 DC.B "SO HERE ARE THE CREDITS.....       MENU CODED BY MAC SYS DATA,      "
 DC.B "ART BY {,      MUSIC BY JOCHEN HIPPLE RIPPED FROM GHOST BATTLE "
 DC.B "BY GRAZEY OF P.H.F BUT FIXED TO WORK ANYWHERE IN MEMORY BY MAC SYS DATA.   "
 DC.B "       WHAT DO YA THINK OF THE ART?               GOOD ISN'T IT, "
 DC.B "IT'S A PICTURE OF OZ ON A GOOD DAY!        "
 DC.B "  'WHAT HAVE } BEEN DOING RECENTLY' I HEAR YOU CRY. WELL I'VE BEEN "
 DC.B "KEPT BUSY WRITING SEVERAL INTROS FOR PD LIBRARIES, CODING A PROTECTOR "
 DC.B "FOR ATOMIC 3.5 FILES, WORKING ON THE MSD/MUG UK LINK FILER, CODING "
 DC.B "MENUS FOR OTHER GROUPS AND RIPPING MUSIC.        "
 dc.b "        "
 DC.B "HERE ARE THE GREETINGS TO PEOPLE I KNOW ARE STILL ALIVE AND "
 DC.B "WHO HAVE RECENTLY GREETED US OR CONTACTED US....     "
 DC.B "808 STATE PD,     "
 DC.B "ADRENALIN UK,     "
 DC.B "BART AT TOWER PD,     "
 DC.B "BEN OF CHAOS,     "
 dc.b "DEL AT D.W. STABLES PD,     "
 DC.B "DR.SYNE (GOOD TO SEE YOU AGAIN, LET'S NOT WAIT 16 MONTHS NEXT TIME),     "
 DC.B "ERIK PLANKTON (WHERE'S YOUR NEW DEMO?),     "
 DC.B "EQUINOX,     "
 DC.B "FUZION,     "
 DC.B "GRAZEY OF P.H.F,     "
 DC.B "INNER CIRCLE,     "
 DC.B "INSOMNIA,     "
 DC.B "KGB (GET IN TOUCH),     "
 DC.B "MUG UK - FOUND ANY MORE BUGS IN THE LINK FILER?,     "
 DC.B "OBERJE (HOW'S THE GAME?),     "
 DC.B "NEXT (WHAT'S UP, CAN YOU NOT SPELL PERSISTENCE OF VISION OR WHAT. YOU "
 DC.B "HEVER INCLUDE US IN YOUR CHARTS),     "
 DC.B "PAL PD,     "
 DC.B "REPLICANTS,     "
 DC.B "RIPPED OFF (BILBO - I HOPE YOU GOT THE PHOTO!),     "
 DC.B "SLAYTANIC CULT,     "
 DC.B "STAX,      "
 DC.B "AND     "
 DC.B "TNC PD - HAVE YOU BUTCHERED ANY MORE OF MY CODE YET?.     "
 dc.b "            WELL I JUST GOT MY HANDS ON A BRAND NEW AMIGA 1200 AND "
 DC.B "IT'S A DEFINITE INPROVEMENT, THE THING DOES ABOUT ST SPEED NOW! "
 DC.B "   UNFORTUNATELY PINBALL DREAMS DOES NOT WORK BUT LUCKILY "
 DC.B "I'VE GOT MY A500 SO I CAN STILL PLAY IT.         "
 DC.B "IN THE NEW YEAR I SHOULD BE GETTING MY FALCON AND WILL START "
 DC.B "WRITING FOR THE NEW HARDWARE, I HAVE SOME HARDWARE ADDRESSES "
 DC.B "WHICH WILL HOPEFULLY ALLOW ME TO EXPERIMENT WITH IT A BIT.  "
 DC.B "   I WILL ALSO GET MY A500 FIXED SO I CAN USE THE "
 DC.B "PARALLEL PORT FOR THE SOFTWARE DEVELOPER KIT I HAVE.   "
 DC.B "        WELL PRESS A KEY AND START A DEMO, THE OMEGA STE DEMO "
 DC.B "IS THE EVILEST STE ONE YET. IF YOU HAVEN'T GOT AN STE I "
 DC.B "WOULD RECOMMEND TAKING THIS DISC TO SOMEONE WHO HAS!          "
 DC.B "                                                              "
 DC.B "                                                              "
 DC.B "YO BORIS - THE FLICKER PREVENTION IN THE SIDE BORDER IS NOT "
 DC.B "COMPLEX, JUST A MATTER OF GETTING THE TIMING RIGHT FOR THE "
 DC.B "INSTRUCTIONS ( THEY WEREN'T IN THE EQUINOX CYCLE LOOKUP TABLE ).    "
 DC.B "                                                              "
 DC.B "                I DEDICATE THIS DISC TO JENNY FROM WORK......."
 DC.B "                                  WRAP......                  "
 DC.B "                                                              "
 DC.B "                                                              "
 DC.B "                                                              "
 DC.B "                                                              "
 DC.B "                 UTTER POVERTY RULES.......            "
 DC.B "JENNY FROM ADMIN - YOU'RE ON MY MIND THROUGHOUT THE XMAS PERIOD. "
 DC.B "                              "
 dc.b $ff
	even


char_offset	dc.w	0
font		dcb.b	31*4*4,0
		incbin	LEAN.FNT


font_offsets
;           !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
 dc.b	00,33,36,00,00,00,00,36,37,38,00,00,32,39,31,40

;        0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @
 dc.b	28,41,42,43,44,45,46,47,48,49,35,00,00,00,00,34,00

;        A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q
 dc.b	01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17

;        R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  `  a  b  c
 dc.b	18,19,20,21,22,23,24,25,26,37,30,38,00,00,00,01,02,03

;        d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u
 dc.b	04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21

;        v  w  x  y  z  {  |  }  ~
 dc.b	22,23,24,25,26,29,00,30,00
	even

pic	incbin	logicsys.PI1			;main menu pic

********** valid key press table
key_codes
	dc.b	2,0	;key 1, offset 0
	dc.b	3,1	;key 2, offset 1
	dc.b	4,2	;key 3, offset 2
	dc.b	5,3	;key 4
	dc.b	6,4	;key 5

	dc.b	$6d,0	;keypad 1, offset 0
	dc.b	$6e,1	;keypad 2, offset 1
	dc.b	$6f,2
	dc.b	$6a,3	;keypad 4
	dc.b	$6b,3	;keypad 5

	dc.b	$ff	;end of table
	even


filename_table	dc.l	filename1
		dc.l	filename2
		dc.l	filename3
		dc.l	filename4
		dc.l	filename5

filename1	dc.b	"omega.92",0
		even
filename2	dc.b	"epssdemo.ste",0
		even
filename3	dc.b	"steel512.ste",0
		even
filename4	dc.b	"tsc42",0
		even
filename5	dc.b	"copier.pov",0
		even


	ifeq	DOWNLOAD
*************************
	SECTION BSS	
*************************
	endc
bss_start
user_stack	ds.l	1

old_base	ds.l	1		;old screen address
old484		ds.w	1
stack_save	ds.l	1

old_pal	ds.b	32		;old colours
black	ds.b	32		;32 bytes of nothing...

store	ds.l	10		;old MFP regs


zero_counter	ds.w	1
screen_number	ds.w	1
present_base	ds.l	1
last_base	ds.l	1
screen_1	ds.l	1
screen_2	ds.l	1
vsync_flag	ds.w	1
org_rez		ds.w	1		;original rez
hertz_switch	ds.w	1		;hertz toggle check

fade_timer	ds.w	1
fade_active	ds.w	1
fade_speed	ds.w	1
fade_offset	ds.w	1


	ds.b	256		;workspace so screen in on 256 bytes boundry
screen	ds.b	41984		;two screens
	ds.b	41984
bss_end

	IFNE	DOWNLOAD
Code_End
Code_Length	equ	Code_End-Code_Start
	ENDC
