*************************************************************************
*			PERSISTENCE OF VISION¿ 140			*
*			ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ			*
*									*
* Code by:	MACHINE SYSTEM DATA					*
*									*
*									*
* Art by:	MACHINE SYSTEM DATA					*
*									*
*									*
* Music by:	NO-MORE of ANIMAL MINE					*
*									*
*									*
*									*
*************************************************************************


YES=1
yes=YES
NO=0
no=NO


AUTORUN4=NO	;YES to use POV AUTORUN 4 (poke filename at $200 and exit)
		;NO to run program from here

FINAL=NO	;YES to remove escape to assembler code
		;NO to keep it on


	opt	o+,w-

DISPLAY_TIME	equ	200		;time text is held on screen
					;Increase this to allow user
					;to read text


	ifeq	AUTORUN4
begin	bra	start
	ds.l	100
ustack	ds.l	1

; filename has already been stored in $200 so we can now P_EXEC
exec		pea	blank
		pea	blank
		pea	$200
		clr.w	-(sp)
		move.w	#$4b,-(sp)
		trap	#1
		lea	16(sp),sp
		pea	.reset		;always reset on return from prog
		move.w	#$26,-(sp)
		trap	#14
.reset		move.l	4.w,-(sp)
		rts

blank		dc.l	0

*******************************************************************
start		move.l	4(a7),a0
		move.l	#ustack,a7
		move.l	#start-begin+$100,-(a7)	;keep only EXEC routine
		move.l	a0,-(a7)
		clr.w	-(a7)
		move.w	#$4a,-(a7)
		trap	#1
		lea	12(a7),a7
		ENDC

		bra	over
		dc.b	"******** POV 140 WAS BROUGHT TO YOU BY MAC SYS DATA."
		dc.b	"        TO CONTACT POV WRITE TO THE ADDRESS IN THE SCROLLTEXT. ********"
		even
over		bsr	set_up

main_loop	bsr	vsync
		bsr	set_screen	;screen flip
;		move.w	#$123,$ffff8240.w
		jsr	music+6
		bsr	clock
		bsr	scroll
		bsr	print_text
;		move.w	pic+2,$ffff8240.w

		move.w	key,d0

		ifeq	FINAL
		cmp.w	#1,d0
		beq	assem
		endc

		cmp.w	#11,d0		;0 keyboard
		beq	zero

		cmp.w	#$70,d0		;0 keypad
		beq	zero

		cmp.w	#$c53,d0	;ALT+CONTROL+DELETE=RESET!
		beq	reset

		lea	demo_keys,a0
.next		move.w	(a0)+,d1
		bmi.s	main_loop
		cmp.b	d1,d0
		beq.s	.run
		bra.s	.next
.run		lsr.w	#8,d1
		and.w	#$f,d1
		lsl.w	#2,d1
		lea	filename_table,a0
		move.l	(a0,d1.w),a0
		lea	$200.w,a1
		REPT	4
		move.l	(a0)+,(a1)+
		ENDR

		tst.w	hertz_toggle
		beq.s	hz50
		and.b	#%11111101,$ffff820a.w	;60Hz
hz50		jsr	music+2		;music OFF

		movem.l	old_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w

		move.l	screen_base,d6
		lsr.l	#8,d6
		lea	$ffff8201.w,a6
		movep.w	d6,(a6)

		move.w	#$2700,sr
		lea	storage,a0
		move.l	(a0)+,$70.w
		move.l	(a0)+,$118.w
		move.l	(a0)+,$120.w
		move.b	(a0)+,$fffffa09.w
		move.b	(a0)+,$fffffa07.w
		move.b	(a0)+,$fffffa13.w
		move.w	#$2300,sr

		move.w	#$25,-(sp)
		trap	#14
		addq.l	#2,sp
		move.b	#0,$ffff8260.w
		move.b	#$8,$fffffc02.w

		move.l	stack_save,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp


		ifeq	AUTORUN4
		bra	exec
		else
		clr.w	-(sp)
		trap	#1
		endc

		ifeq	FINAL
assem		jsr	music+2		;music OFF

		movem.l	old_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w

		move.l	screen_base,d6
		lsr.l	#8,d6
		lea	$ffff8201.w,a6
		movep.w	d6,(a6)

		move.w	#$2700,sr
		lea	storage,a0
		move.l	(a0)+,$70.w
		move.l	(a0)+,$118.w
		move.l	(a0)+,$120.w
		move.b	(a0)+,$fffffa09.w
		move.b	(a0)+,$fffffa07.w
		move.b	(a0)+,$fffffa13.w
		move.w	#$2300,sr

		move.w	#$25,-(sp)
		trap	#14
		addq.l	#2,sp
		move.b	#1,$ffff8260.w
		move.b	#$8,$fffffc02.w

		move.l	stack_save,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp

		clr.w	-(sp)
		trap	#1
		endc

zero		tst.w	hertz_delay
		bne	main_loop
		eor.w	#$002,hertz_toggle
		move.w	#8,hertz_delay	;delay used to stop key fast repeat
		bra	main_loop

reset		move.l	4.w,-(sp)
		rts





*******************
* CUSTOM ROUTINES *
*******************
clock		bsr	.clock
.clock		moveq	#0,d0
		lea	max,a1
		lea	clock6,a0
.loop		move.b	(a0),d2
		cmp.b	(a1),d2
		bne.s	.no
		move.b	#'0',(a0)
		add.w	#1,a0
		add.w	#1,a1
		bra.s	.loop
.no		add.b	#1,(a0)
.print_clock	move.l	scr_now,a1
		lea	160*185(a1),a1
		lea	clock0+1,a0
		move.w	#7,d1		;number of digits allowed
		lea	clock_scr_offsets,a3
.print_loop	lea	font,a2
		moveq	#0,d0
		move.b	-(a0),d0
		sub.w	#32,d0
		mulu	#32,d0
		add.w	d0,a2
offset		set	0
		rept	15
		move.w	(a2)+,offset(a1)
offset		set	offset+160
		endr
		add.w	(a3)+,a1
		sub.w	#1,d1
		bne.s	.print_loop
		rts


scroll		move.l	scr_now,a1
		lea	plane_font_offsets,a2
		lea	plane_font,a3
		move.l	scroll_pointer,a4
		move.l	a4,a5
		moveq	#0,d4
		moveq	#40,d5
		move.w	char_offset,d6
next_char	move.b	(a5),d7		;get a letter
		sub.b	#32,d7		;rid of ASCII
		ext.w	d7
		moveq	#0,d0
		move.l	a3,a0
		move.b	(a2,d7),d0
		mulu	#32*4,d0
		add.w	d0,a0
		move.w	d6,d0
		lsl.w	#5,d0		;*32
		add.w	d0,a0
.column
OFF	set	0
		REPT	31-1		;Font is 30 but I use 32 as *32 is quicker then *30
		move.b	(a0)+,OFF(a1)
OFF	set	OFF+160
		ENDR
		add.w	#2,a0		;see above!
		subq.w	#1,d5
		beq.s	.finish
		add.w	#1,a1		;lower byte of word
		tst.w	d4
		beq.s	.skip		;if D4=0 then do next word
		add.w	#6,a1		;else goto next word on screen
.skip		not.w	d4
		addq.w	#1,d6		;character offset
		and.w	#3,d6
		bne	.column
		addq.w	#1,a5		;scroll pointer
		tst.b	(a5)		;is end of text?
		bpl	next_char	;NO!
		lea	scroll_text,a5	;do reset scrolline
		bra	next_char
.finish		addq.w	#1,char_offset
		and.w	#3,char_offset
		bne.s	.end
		addq.w	#1,a4
		tst.b	(a4)
		bpl.s	.end
		lea	scroll_text,a4
.end		move.l	a4,scroll_pointer
		rts



print_text	tst.w	disc_clear_enable
		bne	.do_clear

		tst.w	disc_enable
		beq.s	.do_stuff
		rts
.do_stuff	move.l	text_pos,a1
		move.l	scr_now,a0
		move.l	last_scr,a3

		lea	31*160(a0),a0
		lea	31*160(a3),a3
.restart	moveq	#0,d1
		move.b	(a1)+,d1
		move.l	a1,text_pos
		cmp.b	#-1,d1
		bne.s	.no_reset
		move.l	#middle_text,a1
		bra.s	.restart
.no_reset	cmp.b	#"^",d1		;terminator
		bne.s	.do_text
		cmp.b	#13,(a1)
		bne.s	.notcr_here	;if CR is here then take for granted CR,LF
		add.l	#2,text_pos
.notcr_here	move.w	#-1,disc_clear_enable
		move.w	#-1,disc_enable
		move.w	#(22*7)-1,lines_to_do
		move.w	#DISPLAY_TIME,do_clear_delay
		clr.b	xpos
		clr.w	ypos
		clr.w	byte_offset
		rts
.do_text	cmp.b	#13,d1
		bne.s	.notcr
		clr.b	xpos
		clr.w	byte_offset
		bra	.restart
.notcr		cmp.b	#10,d1
		bne.s	.notlf
		add.w	#160*7,ypos
		bra	.restart
.notlf		cmp.b	#9,d1		;HORIZONTAL TAB
		bne.s	.notab		;routine added 11/2/92 for print speed
;calc TAB by getting MOD 8 then testing for odd/even position and altering byte_offset.
		moveq	#0,d5
		move.b	xpos,d5
		and.b	#%111,d5	;mod 8
		move.b	#8,d4
		sub.b	d5,d4		;sub MOD 8
		add.b	d4,xpos		;add to XPOS so now we are in correct word
		clr.w	byte_offset
		bra	.restart
.notab		sub.w	#32,d1
		mulu	#7,d1	;each char is 6 bytes long
		lea	minifont,a2
		add.w	d1,a2

		moveq	#0,d0
		move.w	ypos,d0

		add.w	d0,a0
		add.w	d0,a3

		move.b	xpos,d0
		and.w	#$ff,d0
		lsr.w	#1,d0	;\2
		lsl.w	#3,d0	;*8	;bytes across screen
		add.w	d0,a0
		add.w	d0,a3

		addq.b	#1,xpos

		add.w	byte_offset,a0
		add.w	byte_offset,a3

		move.b	(a2),(a0)
		move.b	(a2)+,(a3)
		move.b	(a2),160(a0)
		move.b	(a2)+,160(a3)
		move.b	(a2),320(a0)
		move.b	(a2)+,320(a3)
		move.b	(a2),480(a0)
		move.b	(a2)+,480(a3)
		move.b	(a2),640(a0)
		move.b	(a2)+,640(a3)
		move.b	(a2),800(a0)
		move.b	(a2)+,800(a3)
		move.b	(a2),960(a0)
		move.b	(a2)+,960(a3)	;chars are 7 pixels high

		eor.w	#1,byte_offset
		rts

.do_clear	tst.w	do_clear_delay
		beq.s	.yeah
		sub.w	#1,do_clear_delay
		rts
.yeah		tst.w	lines_to_do
		beq	.stop
		sub.w	#1,lines_to_do

		move.l	scr_now,a0
		move.l	last_scr,a3
		lea	31*160(a0),a0
		lea	31*160(a3),a3
		add.w	clear_line_offset,a0
		add.w	clear_line_offset,a3
		moveq	#0,d0
OFF	set	0
		rept	40
		move.w	d0,OFF(a0)
		move.w	d0,OFF(a3)
OFF	set	OFF+8
		endr
		add.w	#160,clear_line_offset
		rts
.stop		clr.w	disc_clear_enable
		move.w	#1,disc_enable
		clr.w	clear_line_offset
		rts

sort_text	lea	middle_text,a0
		lea	disc_start_table,a1
		move.l	a0,(a1)+	;poke start of disc into lookup table
.loop		cmp.b	#$ff,(a0)	;is end of list???
		beq.s	.quit
		move.b	(a0)+,d0
		cmp.b	#'^',d0
		bne.s	.loop
		move.b	(a0)+,d0	;cr
		move.b	(a0)+,d0	;lf
		move.l	a0,(a1)+
		bra.s	.loop
.quit		rts


***********************
* SUBROUTINES SECTION *
***********************
vsync		move.w	#-1,vsync_flag
.sync		tst.w	vsync_flag
		bne.s	.sync
		rts

set_up		lea	bss_start,a0		;clear bss
		move.l	#bss_end-bss_start,d0
.clr		clr.b	(a0)+
		sub.l	#1,d0
		bne.s	.clr

		clr.l	-(sp)			;supervisor
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,stack_save

		move.b	#$12,$fffffc02.w	;DI mouse

		move.w	#3,-(sp)		;get scrn base
		trap	#14
		addq.l	#2,sp
		move.l	d0,screen_base

		movem.l	$ffff8240.w,d0-d7	;get old pal
		movem.l	d0-d7,old_pal

		move.w	#4,-(sp)		;get old rez
		trap	#14
		addq.l	#2,sp
		move.w	d0,org_rez

		move.w	#$25,-(sp)		;sync
		trap	#14
		addq.l	#2,sp
		clr.b	$ffff8260.w		;go low rez

		bsr	sort_text		;sort text printer ascii

		move.l	#screens,d0
		clr.b	d0
		move.l	d0,scr_now
		move.l	d0,d1
		add.l	#32000,d1
		eor.l	d0,d1
		move.l	d1,scr_xor
		bsr	set_screen

; Show address pic....
		movem.l	black,d0-d7
		movem.l	d0-d7,$ffff8240.w
		lea	address_pic,a0
		move.l	scr_now,a1
		sub.w	#34,a1
		bsr	depack_atom35
		addq.w	#2,a1
		bsr	fade
		move.w	#300-1,d7
.delay_loop	move.w	#$25,-(sp)
		trap	#14
		addq.w	#2,sp
		move.w	#11,-(sp)
		trap	#1
		addq.w	#2,sp
		tst.l	d0
		bmi.s	.yes
		dbf	d7,.delay_loop
		bra.s	.cont
.yes		move.w	#7,-(sp)
		trap	#1
		addq.w	#2,sp
.cont
		lea	black,a1
		bsr	fade

******************************************************
; print the : between the digits on the pic
		lea	pic+34,a1
		lea	160*185(a1),a1
		lea	font,a0
		move.w	#":",d0
		sub.w	#32,d0
		mulu	#32,d0
		add.w	d0,a0
		move.w	#16-1,d7
.loop		move.w	(a0),8(a1)
		move.w	(a0),32(a1)
		move.w	(a0)+,56(a1)
		lea	160(a1),a1
		dbf	d7,.loop
******************************************************

		bsr	set_screen
		lea	pic+34,a0		;show pic to BOTH screens
		move.l	scr_now,a1
		move.l	a1,a2
		add.l	#32000,a2
		move.w	#32000/4-1,d0
.sho		move.l	(a0),(a1)+
		move.l	(a0)+,(a2)+
		dbf	d0,.sho

		jsr	music			;init music

		movem.l	pic+2,d0-d7		;set new pal
		movem.l	d0-d7,$ffff8240.w

		lea	storage,a0
		move.l	$70.w,(a0)+
		move.l	$118.w,(a0)+
		move.l	$120.w,(a0)+
		move.b	$fffffa09.w,(a0)+
		move.b	$fffffa07.w,(a0)+
		move.b	$fffffa13.w,(a0)+

		and.b	#$df,$fffffa09.w
		and.b	#$fe,$fffffa07.w
		move.l	#timerb,$120.w
		move.l	#new_kbd,$118.w
		move.l	#vbl,$70.w
		or.b	#1,$fffffa07.w
		or.b	#1,$fffffa13.w
		bclr	#3,$fffffa17.w
		move.w	#$2300,sr
		rts

set_screen	move.l	scr_now,d6		;set screen to ours
		move.l	d6,last_scr
		move.l	scr_xor,d7
		eor.l	d7,d6
		move.l	d6,scr_now
		lsr.l	#8,d6
		lea	$ffff8201.w,a6
		movep.w	d6,(a6)
		rts

fade		move.w	#7,d6
		move.l	a1,a2
next_value	lea	$ffff8240.w,a0
		move.w	#16-1,d7
.loop		bsr	modify
		add.w	#2,a0
		add.w	#2,a1
		dbf	d7,.loop
		move.w	#4,d0
		bsr	.fade_vbl
		move.l	a2,a1
		dbf	d6,next_value
		rts
.fade_vbl	movem.l	d0-d3/d7/a0-a3,-(sp)
		move.l	d0,d7
.vbl_loop	move.w	#$25,-(sp)
		trap	#14
		addq.l	#2,sp
		dbf	d7,.vbl_loop
		movem.l	(sp)+,d0-d3/d7/a0-a3
		rts
modify		move.w	(a0),d0		;get color value
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
MDN1		SUBQ #1,D4
MOK1		MOVE D0,D2
		MOVE D1,D3
		AND #$70,D2
		AND #$70,D3
		CMP D2,D3
		BEQ.S MOK2
		BMI.S MDN2
		ADD #$10,D4
		BRA.S MOK2
MDN2		SUB #$10,D4
MOK2		MOVE D0,D2
		MOVE D1,D3
		AND #$700,D2
		AND #$700,D3
		CMP D2,D3
		BEQ.S MOK3
		BMI.S MDN3
		ADD #$100,D4
		BRA.S MOK3
MDN3		SUB #$100,D4
MOK3		MOVE D4,(A0)
		RTS




RASTER_COLOUR	equ	$ffff8242
vbl		clr.w	vsync_flag
		move.w	hertz_toggle,$ffff8240.w
		clr.b	$fffffa1b.w
		move.w	timerb_col,RASTER_COLOUR.w
		move.b	#1,$fffffa21.w
		move.l	#timerb,$120.w
		move.l	#timerb_col+2,timerb_col_pos
		move.b	#8,$fffffa1b.w
		tst.w	disc_enable
		bne.s	.dec
		tst.w	hertz_delay
		beq.s	.no_hz_dec
		sub.w	#1,hertz_delay
.no_hz_dec	rte
.dec		sub.w	#1,disc_enable
		tst.w	hertz_delay
		beq.s	.no_hz_dec
		sub.w	#1,hertz_delay
		rte



timerb		move.l	a0,-(sp)
		move.l	timerb_col_pos,a0
		move.w	(a0)+,RASTER_COLOUR.w
		move.l	a0,timerb_col_pos
		move.l	(sp)+,a0
		rte


new_kbd		movem.l	d0,-(sp)
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
		bclr	#6,$fffffa11.w
		movem.l	(sp)+,d0
		rte



;ATOMIK DECRUNCH SOURCE CODE v3.5

;MODE=1 depack data from a0 to a0 
;MODE=0 depack data from a0 to a1 (RESTORE SPACE a 1 inutile! si MODE=0)

;PIC_ALGO = 0 decrunch file not encoded with special picture algorythm.
;PIC_ALGO = 1 decrunch all files with or without picture algorythm.

;DEC_SPACE = (lesser decrunch space is gived after packing by atomik v3.5)
             
;RESTORE_SPACE = 1 the allocated decrunch space will be restored .
;RESTORE_SPACE = 0 the allocated decrunch space will not be restored.

MODE		EQU	0
PIC_ALGO	EQU	1
DEC_SPACE	EQU	$80	 ;MAX IS $7FFE (no odd value!)
RESTORE_SPACE	EQU	0

depack_atom35	movem.l	d0-a6,-(a7)
		cmp.l	#"ATM5",(a0)+
		bne	not_packed
		link	a2,#-28
		move.l	(a0)+,d0
		ifne	MODE
		lea	4(a0,d0.l),a5
		move.l	d0,-(a7)
		elseif
		move.l	a1,a5
		add.l	d0,a5
		endc
		move.l	a5,a4
		ifne	MODE
		ifne	DEC_SPACE
		lea	DEC_SPACE(a4),a5
		endc
		endc
		lea	-$c(a4),a4
		move.l	(a0)+,d0
		move.l	a0,a6
		add.l	d0,a6
		ifne	PIC_ALGO
		moveq	#0,d0
		move.b	-(a6),d0
		move	d0,-2(a2)
		ifne	RESTORE_SPACE
		lsl	#2,d0
		sub	d0,a4
		endc
		elseif
		ifne	RESTORE_SPACE
		clr	-2(a2)
		endc
		subq	#1,a6
		endc
		ifne	RESTORE_SPACE
		lea	buff_marg(pc),a3
		move	-2(a2),d0
		lsl	#2,d0
		add	#DEC_SPACE+$C,d0
		bra.s	.save
.save_m		move.b	(a4)+,(a3)+
		subq	#1,d0
.save		bne.s	.save_m
		movem.l	a3-a4,-(a7)
		endc
		ifne	PIC_ALGO
		pea	(a5)
		endc
		move.b	-(a6),d7
		bra	take_type
decrunch	move	d3,d5
take_lenght	add.b	d7,d7
.cont_take	dbcs	d5,take_lenght
		beq.s	.empty1
		bcc.s	.next_cod
		sub	d3,d5
		neg	d5
		bra.s	.do_copy1
.next_cod	moveq	#3,d6
		bsr.s	get_bit2
		beq.s	.next_cod1
		bra.s	.do_copy
.next_cod1	moveq	#7,d6
		bsr.s	get_bit2
		beq.s	.next_cod2
		add	#15,d5
		bra.s	.do_copy
.empty1		move.b	-(a6),d7
		addx.b	d7,d7
		bra.s	.cont_take
.next_cod2	moveq	#13,d6
		bsr.s	get_bit2
		add	#255+15,d5
.do_copy	add	d3,d5
.do_copy1	lea	decrun_table(pc),a4
		move	d5,d2
		bne.s	bigger
		add.b	d7,d7
		bne.s	.not_empty
		move.b	-(a6),d7
		addx.b	d7,d7
.not_empty	bcs.s	.ho_kesako
		moveq	#1,d6
		bra.s	word
.ho_kesako	moveq	#3,d6
		bsr.s	get_bit2
		tst.b	-28(a2)
		beq.s	.ho_kesako1
		move.b	10-28(a2,d5.w),-(a5)
		bra	tst_end
.ho_kesako1	move.b	(a5),d0
		btst	#3,d5
		bne.s	.ho_kesako2
		bra.s	.ho_kesako3
.ho_kesako2	add.b	#$f0,d5
.ho_kesako3	sub.b	d5,d0
		move.b	d0,-(a5)
		bra	tst_end
get_bit2	clr	d5
.get_bits	add.b	d7,d7
		beq.s	.empty
.cont		addx	d5,d5
		dbf	d6,.get_bits
		tst	d5
		rts
.empty		move.b	-(a6),d7
		addx.b	d7,d7
		bra.s	.cont
bigger		moveq	#2,d6
word		bsr.s	get_bit2
contus		move	d5,d4
		move.b	14(a4,d4.w),d6
		ext	d6
		tst.b	1-28(a2)
		bne.s	.spe_ofcod1
		addq	#4,d6
		bra.s	.nospe_ofcod1
.spe_ofcod1	bsr.s	get_bit2
		move	d5,d1
		lsl	#4,d1
		moveq	#2,d6
		bsr.s	get_bit2
		cmp.b	#7,d5
		blt.s	.take_orof
		moveq	#0,d6
		bsr.s	get_bit2
		beq.s	.its_little
		moveq	#2,d6
		bsr.s	get_bit2
		add	d5,d5
		or	d1,d5
		bra.s	.spe_ofcod2
.its_little	or.b	2-28(a2),d1
		bra.s	.spe_ofcod3
.take_orof	or.b	3-28(a2,d5.w),d1
.spe_ofcod3	move	d1,d5
		bra.s	.spe_ofcod2
.nospe_ofcod1	bsr.s	get_bit2
.spe_ofcod2	add	d4,d4
		beq.s	.first
		add	-2(a4,d4.w),d5
.first		lea	1(a5,d5.w),a4
		move.b	-(a4),-(a5)
.copy_same	move.b	-(a4),-(a5)
		dbf	d2,.copy_same
		bra.s	tst_end
make_jnk	add.b	d7,d7
		bne.s	.not_empty
		move.b	-(a6),d7
		addx.b	d7,d7
.not_empty	bcs.s	string
		move.b	-(a6),-(a5)
tst_end		cmp.l	a5,a3
		bne.s	make_jnk
		cmp.l	a6,a0
		beq.s	work_done
take_type	moveq	#0,d6
		bsr	get_bit2
		beq.s	.nospe_ofcod
		move.b	-(a6),d0
		lea	2-28(a2),a1
		move.b	d0,(a1)+
		moveq	#1,d1
		moveq	#6,d2
.next		cmp.b	d0,d1
		bne.s	.no_off_4b
		addq	#2,d1
.no_off_4b	move.b	d1,(a1)+
		addq	#2,d1
		dbf	d2,.next
		st	1-28(a2)
		bra.s	.spe_ofcod
.nospe_ofcod	sf	1-28(a2)
.spe_ofcod	moveq	#0,d6
		bsr	get_bit2
		beq.s	.relatif
		lea	10-28(a2),a1
		moveq	#15,d0
.next_f		move.b	-(a6),(a1)+
		dbf	d0,.next_f
		st	-28(a2)
		bra.s	.freq
.relatif	sf	-28(a2)
.freq		clr	d3
		move.b	-(a6),d3
		move.b	-(a6),d0
		lsl	#8,d0
		move.b	-(a6),d0
		move.l	a5,a3
		sub	d0,a3
		bra.s	make_jnk
string		bra	decrunch
work_done
		ifne	PIC_ALGO
		move.l	(a7)+,a0
		pea	(a2)
		bsr.s	decod_picture
		move.l	(a7)+,a2
		endc
		ifne	RESTORE_SPACE
		movem.l	(a7)+,a3-a4
		endc
		ifne	MODE
		move.l	(a7)+,d0
		bsr	copy_decrun
		endc
		ifne	RESTORE_SPACE
		move	-2(a2),d0
		lsl	#2,d0
		add	#DEC_SPACE+$C,d0
		bra.s	.restore
.restore_m	move.b	-(a3),-(a4)
		subq	#1,d0
.restore	bne.s	.restore_m
		endc
		unlk	a2
not_packed	movem.l	(a7)+,d0-a6
	 	rts
decrun_table	dc.w	32,32+64,32+64+256,32+64+256+512,32+64+256+512+1024
	dc.w	32+64+256+512+1024+2048,32+64+256+512+1024+2048+4096
	dc.b	0,1,3,4,5,6,7,8
	ifne	PIC_ALGO
decod_picture	move	-2(a2),d7
.next_picture	dbf	d7,.decod_algo
		rts
.decod_algo	move.l	-(a0),d0
		lea	0(a5,d0.l),a1
.no_odd		lea	$7d00(a1),a2
.next_planes	moveq	#3,d6
.next_word	move	(a1)+,d0
		moveq	#3,d5
.next_bits	add	d0,d0
		addx	d1,d1
		add	d0,d0
		addx	d2,d2
		add	d0,d0
		addx	d3,d3
		add	d0,d0
		addx	d4,d4
		dbf	d5,.next_bits
		dbf	d6,.next_word
		movem	d1-d4,-8(a1)
		cmp.l	a1,a2
		bne.s	.next_planes
		bra.s	.next_picture
		endc
		ifne	MODE
copy_decrun	lsr.l	#4,d0
		lea	-12(a6),a6
.copy_decrun	rept	4
		move.l	(a5)+,(a6)+
		endr
		dbf	d0,.copy_decrun
		rts
		endc
		ifne	RESTORE_SPACE
buff_marg	dcb.b	$90+DEC_SPACE+$C
		endc

*******************
   SECTION DATA
*******************
pic	incbin	"pic.pi1"

font	incbin	med_font.dat

clock_scr_offsets	dc.w	16,8,16,8,16,8,16
max		dc.b	'9'	;x9 milliseconds
		dc.b	'9'	;9x milliseconds
		dc.b	'9'	;x9 seconds
		dc.b	'5'	;5x seconds
		dc.b	'9'	;x9 minutes
		dc.b	'5'	;5x minutes
		dc.b	'9'	; x hours

clock6		dc.b	'0'	;x9 milliseconds
clock5		dc.b	'0'	;5x milliseconds
clock4		dc.b	'0'	;x9 seconds
clock3		dc.b	'0'	;5x seconds
clock2		dc.b	'0'	;x9 minutes
clock1		dc.b	'0'	;5x minutes
clock0		dc.b	'0'	; x hours
	even

music		incbin	AMAZNE_4.SID	; AMAZINE #4 MAG INTRO


scroll_pointer	dc.l	init_scroll_text
init_scroll_text
 dc.b	"                                                  "
 dc.b	"                                                  "
scroll_text
 dc.b "PERSISTENCE OF VISION PRESENT.......    POV DEMO "
 dc.b "COMPILATION 140.      "
 DC.B "            HERE'S THE CREDITS:      "
 DC.B "MENU CODED BY MAC SYS DATA,    "
 DC.B "GRAFIX BY MSD,     "
 DC.B "RELEASE DATE 7TH NOV 1993.           "
 dc.b "I HAVE NOW INSTALLED A HIGH DENSITY DRIVE INTO MY STE. "
 DC.B "THE INSTRUCTIONS ARE RUBBISH BUT A QUICK PHONE CALL TO THE "
 DC.B "COMPANY THAT SUPPLIED IT SORTED IT OUT.  IT TOOK ABOUT 1 HOUR "
 DC.B "TO FIT IT AND IT WORKS FINE APART FROM ONLY READING 81 TRACKS "
 dc.b "WHICH ISN'T SO BAD EXCEPT SOME DEMOS ARE ON 82 TRACK DISCS SO "
 DC.B "THEY FAIL TO LOAD. TO FIX THIS I'M GOING TO ADD AN A-B SWITCH SO "
 DC.B "MY EXTERNAL DRIVE CAN STILL ACCESS ALL 82 TRACKS. I FITTED THE AUTO-SENSING DRIVE "
 DC.B "SO IT DETECTS THE HIGH DENSITY DISCS AUTOMATICALLY AND IT WORKS "
 DC.B "ON NORMAL DOUBLE DENSITY DISCS AS WELL.                THE PROBLEM "
 DC.B "WITH CODING THESE DISCS IS THE TIME IT TAKES TO PUT ALL THE "
 DC.B "BITS TOGETHER.  I CODED THE TIMER IN ABOUT 1 HOUR FROM SCRATCH "
 DC.B "BUT IT TOOK 2 HOURS TO SORT THE COLOURS OUT AND A FURTHER "
 DC.B "HALF HOUR TO TYPE THIS TEXT!             WELL I HAVE NOT "
 DC.B "MUCH TO SAY SO I'LL GIVE YOU THE CONTACT ADDRESS...     "
 DC.B "CONTACT P.O.V. AT       MAC SYS DATA,        "
 DC.B "P.O. BOX 40,              THORNTON-CLEVELEYS,              LANCASHIRE,              "
 DC.B "FY5 3PH,              ENGLAND.                       "
 dc.b "                   WELL THAT'S ALL, SEE YA IN POV 141!         "
 DC.B "                                           "
 dc.b $ff
	even

plane_font	dcb.b	32*4,0
		incbin	1plane.fnt
plane_font_offsets
;          !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
 dc.b	00,41,43,00,00,00,00,46,44,45,00,00,38,42,39,48
;       0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @
 dc.b	27,28,29,30,31,32,33,34,35,36,40,00,00,00,00,47,00
;       A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q  R  S  T
 dc.b	01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20
;       U  V  W  X  Y  Z  [  \  ]  ^  _
 dc.b	21,22,23,24,25,26,41,00,42,00,00



;STe colours..
; 0 8 1 9 2 a 3 b 4 c 5 d 6 e 7 f
timerb_col_pos	dc.l	timerb_col
timerb_col	dc.w	$010,$010,$020,$020,$130,$130,$240,$240
		dc.w	$350,$350,$460,$460,$570,$570,$6f0,$6f0
		dc.w	$6f0,$6f0,$570,$570,$460,$460,$350,$350
		dc.w	$240,$240,$130,$130,$020,$020

		dc.w	$200,$200,$a00,$300,$b00,$400,$c00
		dc.w	$500,$500,$d00,$600,$e00,$700,$f00
		dc.w	$f80,$f80,$f10,$f90,$f20,$fa0,$f30
		dc.w	$fb0,$fb0,$f40,$fc0,$f50,$fd0,$f60
		dc.w	$fe0,$fe0,$f70,$ff0,$7f0,$ef0,$6f0
		dc.w	$df0,$df0,$5f0,$cf0,$4f0,$bf0,$3f0
		dc.w	$af0,$af0,$2f0,$9f0,$1f0,$8f0,$0f0
		dc.w	$0f8,$0f8,$0f1,$0f9,$0f2,$0fa,$0f3
		dc.w	$0fb,$0fb,$0f4,$0fc,$0f5,$0fd,$0f6
		dc.w	$0fe,$0fe,$0f7,$0ff,$07f,$0ef,$06f
		dc.w	$0df,$0df,$05f,$0cf,$04f,$0bf,$03f
		dc.w	$0af,$0af,$02f,$09f,$01f,$08f,$00f
		dc.w	$80f,$80f,$10f,$90f,$20f,$a0f,$30f
		dc.w	$b0f,$b0f,$40f,$c0f,$50f,$d0f,$60f
		dc.w	$e0f,$e0f,$70f,$f0f,$f07,$f0e,$f06
		dc.w	$f0d,$f0d,$f05,$f0c,$f04,$f0b,$f03
		dc.w	$f0a,$f0a,$f02,$f09,$f01,$f08,$f00
		dc.w	$f80,$f80,$f10,$f90,$f20,$fa0,$f30
		dc.w	$fb0,$fb0,$f40,$fc0,$f50,$fd0,$f60
		dc.w	$fe0,$fe0,$f70,$ff0,$ff8,$ff1,$ff9
		dc.w	$ff2,$ff2,$ffa,$ff3,$ffb,$ff4,$ffc
		dc.w	$ff5,$ff5,$ffd,$ff6,$ffe,$ff7,$fff
		dc.w	$fff

		dc.w	$300,$400,$400,$500,$500,$600,$600
		dc.w	$700,$700,$600,$600,$500,$500,$400,$400
		dc.w	$070,$070
		even


text_pos		dc.l	middle_text
middle_text		incbin	ascii.s
			dc.b	$ff
			even
minifont		incbin	7x6_font.dat
			even


demo_keys
	dc.b	0, $02		;key 1
	dc.b	1, $03		;key 2
	dc.b	2, $04		;key 3
	dc.b	3, $05		;key 4
	dc.b	4, $06		;key 5
	dc.b	5, $07		;key 6
	dc.b	6, $08		;key 7
	dc.b	7, $09		;key 8
	dc.b	8, $0a		;key 9

	dc.b	0, $6d		;keypad 1
	dc.b	1, $6e		;keypad 2
	dc.b	2, $6f		;keypad 3
	dc.b	3, $6a		;keypad 4
	dc.b	4, $6b		;keypad 5
	dc.b	5, $6c		;keypad 6
	dc.b	6, $67		;keypad 7
	dc.b	7, $68		;keypad 8
	dc.b	8, $69		;keypad 9
	dc.b	-1, -1

filename_table	dc.l	exec1,exec2,exec3,exec4,exec5,exec6,exec7,exec8,exec9
exec1	dc.b	"abc16",0
	even
exec2	dc.b	"M_VISION.POV",0
	even
exec3	dc.b	"madvis",0
	even
exec4	dc.b	"NLC_MATH.POV",0
	even
exec5	dc.b	"ELITE.3D",0
	even
exec6	dc.b	"impact.71",0
	even
exec7	dc.b	"insomnia",0
	even
exec8	dc.b	"jmp.5",0
	even
exec9	dc.b	"copier.pov",0
	even


address_pic	incbin	address.pi1

*******************
   SECTION BSS
*******************
	even
bss_start
stack_save		ds.l	1
vsync_flag		ds.w	1
screen_base		ds.l	1
org_rez			ds.w	1
old_pal			ds.w	16
key			ds.w	1
hertz_delay		ds.w	1
hertz_toggle		ds.w	1

scr_now			ds.l	1
scr_xor			ds.l	1
last_scr		ds.l	1

black			ds.b	32

char_offset		ds.w	1

xpos			ds.b	1
	even
ypos			ds.w	1
byte_offset		ds.w	1
lines_to_do		ds.w	1
clear_line_offset	ds.w	1
do_clear_delay		ds.w	1
disc_clear_enable	ds.w	1
disc_enable		ds.w	1
disc_start_table	ds.l	30	;1 long word for each page

storage		ds.b	16

		ds.b	34		;there is a posibility that the address pic can be depacked into here
		ds.b	256
screens		ds.b	32000
		ds.b	32000
bss_end
