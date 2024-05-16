;
;	a v e n a
;
;	maggie 21 st intro
;
;	started 20th august 1996
;	tunnel effect to 22nd august
;	water effect 5th september to 9th september
;


		output	d:\source2\m21.st\intro.prg
		opt	p=68000

start:
		clr.l	-(a7)
		move.w	#$20,-(a7)
		trap	#1
		move.l	d0,save_stack
		lea	stack,a7

		move.w	#4,-(a7)
		trap	#14
		addq.l	#2,a7
		cmp.w	#2,d0
		bge	resolution_error
		move.w	d0,save_resolution

		bsr	save_colours
		bsr	save_all
		bsr	save_soundchip
		bsr	install_all
		bsr	install_music
		bsr	install_music_interrupt
		bsr	install_screens

		;bra	debug

		move.l	#script,a6
script_loop:
		move.l	(a6)+,d0
		bmi.s	script_finished
		move.l	d0,a1
		jsr	(a1)
		bra	script_loop
script_finished:

debug_end:
here:		cmp.b	#$39,$fffffc02.w
		bne.s	here


; Restore everything: 
exit_intro:
		bsr	restore_music_interrupt
		bsr	restore_soundchip
		bsr	restore_all
		bsr	restore_colours

		move.w	save_resolution,-(a7)
		move.l	$044e.w,-(a7)
		move.l	#-1,-(a7)
		move.w	#5,-(a7)
		trap	#14
		lea	12(a7),a7

exit_program:
		move.l	save_stack,-(a7)
		move.w	#$20,-(a7)
		trap	#1
		addq.l	#6,a7

		clr.w	-(a7)
		trap	#1

		;illegal

resolution_error:
		pea	res_string(pc)
		move.w	#9,-(a7)
		trap	#1
		addq.l	#6,a7

		move.w	#1,-(a7)
		trap	#1
		addq.l	#2,a7
		bra	exit_program


res_string:	dc.b	27,"E"
		dc.b	"'maggie intro no likey falcon or",13,10
		dc.b	"monochrome screen resolutions!'",13,10,10
		dc.b	"Please switch to ST-Low or ST-Medium",0
		even

;-------------------------------------------------------
;		SECTION	MUSIC
;-------------------------------------------------------
script_install_picture:
		move.l	(a6)+,a0
		pea	(a6)
		bsr	install_picture
		move.l	(a7)+,a6
		rts

script_reset_timer:
		clr.l	music_timer
		rts

script_reloop:
		move.l	(a6)+,a6
		rts

script_wait_music:
		move.l	(a6)+,d0
		pea	(a6)
		bsr	wait_music
		move.l	(a7)+,a6
		rts

script_display_picture:
		pea	(a6)
		bsr	display_picture
		move.l	(a7)+,a6
		rts

script_display_text_screen
		pea	(a6)
		bsr	display_text_screen
		move.l	(a7)+,a6
		rts

script_install_fade:
		move.l	(a6)+,a0
		move.l	(a6)+,d0
		pea	(a6)
		bsr	install_fade
		move.l	(a7)+,a6
		rts

script_fade:	move.l	(a6)+,a0
		move.l	(a6)+,d0
		pea	(a6)
		bsr	install_fade
		bsr	start_fade
		move.l	(a7)+,a6
		rts

script_text_handler:
		move.l	(a6)+,a0
		pea	(a6)
		bsr	text_handler
		move.l	(a7)+,a6
		rts

script_start_fade:
		pea	(a6)
		bsr	start_fade
		move.l	(a7)+,a6
		rts

script_bunny:
		pea	(a6)
		lea	bunny_picture+2,a0
		lea	bunny_palette,a1
		moveq	#16-1,d0
.neg		move.w	(a0),d1
		move.w	d1,(a1)+
		;eor.w	#$fff,d1
		move.w	d1,(a0)+
		dbf	d0,.neg
		move.l	(a7)+,a6
		rts

;-------------------------------------------------------
;		SECTION	SCRIPT
;-------------------------------------------------------

timer_b:	movem.l	d0-a6,-(a7)
		jsr	tune+312
		addq.l	#1,music_timer
		movem.l	(a7)+,d0-a6
		rte


music_fix:
		move.l	d0,d7
		bsr	.set_chip
		move.l	d1,d7
		bsr	.set_chip
		move.l	d2,d7
		bsr	.set_chip
		move.l	d3,d7
		bsr	.set_chip
		jmp	tune+700
.set_chip:
		rol.l	#8,d7
		move.b	d7,$ffff8800.w
		rol.l	#8,d7
		move.b	d7,$ffff8802.w
		rol.l	#8,d7
		move.b	d7,$ffff8800.w
		rol.l	#8,d7
		move.b	d7,$ffff8802.w
		rts

save_soundchip:
		lea	$ffff8800.w,a0
		lea	soundchip_buffer,a1
		moveq	#$f,d0
.loop		move.b	d0,(a0)
		move.b	(a0),(a1)+
		dbf	d0,.loop
		rts

restore_soundchip:
		lea	$ffff8800.w,a0
		lea	soundchip_buffer,a1
		moveq	#$f,d0
.loop		move.b	d0,(a0)
		move.b	(a1)+,2(a0)
		dbf	d0,.loop
		move.b	#8,(a0)
		clr.b	2(a0)
		move.b	#9,(a0)
		clr.b	2(a0)
		move.b	#$a,(a0)
		clr.b	2(a0)
		rts

install_music:
		clr.l	music_timer

; Original music didn't work on Falcons, so this patch has
; been introduced:
		lea	tune+684,a0			;Falcon fix
		movem.w	music_fix_instructions,d0/d1/d2
		movem.w	d0/d1/d2,(a0)
; Music:
		lea	tune+350,a0
		lea	tune+368,a1
		move.l	a0,10(a1)
		move.l	a1,10(a0)
		jsr	tune+32

		lea	tune+1774,a0
		jsr	tune
		rts

; The following instruction is copied onto the old movep.l
;   instruction which only works on ST
music_fix_instructions:
		jmp	music_fix


install_music_interrupt:
		move.l	#timer_b,$120.w
		clr.b	$fffffa1b.w
		move.b	#$f5,$fffffa21.w
		move.b	#7,$fffffa1b.w
		bset	#0,$fffffa07.w
		bset	#0,$fffffa13.w
		rts

restore_music_interrupt:
		clr.b	$fffffa1b.w
		bclr	#0,$fffffa07.w
		bclr	#0,$fffffa13.w
		rts

wait_music
		cmp.l	music_timer,d0
		bgt.s	wait_music
		rts

wait_vbl
		move.l	vbl_timer,d0
.wait		cmp.l	vbl_timer,d0
		beq.s	.wait
		rts

;-------------------------------------------------------
;		SECTION	INTERRUPTS
;-------------------------------------------------------
save_all:	lea	save_area,a0
		move.l	$70.w,(a0)+
		move.l	$110.w,(a0)+
		move.l	$114.w,(a0)+
		move.l	$118.w,(a0)+
		move.l	$120.w,(a0)+
		move.l	$134.w,(a0)+
		move.b	$fffffa01.w,(a0)+
		move.b	$fffffa07.w,(a0)+
		move.b	$fffffa09.w,(a0)+
		move.b	$fffffa0f.w,(a0)+
		move.b	$fffffa13.w,(a0)+
		move.b	$fffffa15.w,(a0)+
		move.b	$fffffa17.w,(a0)+
		move.b	$fffffa19.w,(a0)+
		move.b	$fffffa1b.w,(a0)+
		move.b	$fffffa1f.w,(a0)+
		move.b	$fffffa21.w,(a0)+
		rts

save_colours	movem.l	$ffff8240.w,d0-d7
		moveM.l	d0-d7,old_colours
		rts


restore_all:	lea	save_area,a0
		move.l	(a0)+,$70.w
		move.l	(a0)+,$110.w
		move.l	(a0)+,$114.w
		move.l	(a0)+,$118.w
		move.l	(a0)+,$120.w
		move.l	(a0)+,$134.w
		move.b	(a0)+,$fffffa01.w
		move.b	(a0)+,$fffffa07.w
		move.b	(a0)+,$fffffa09.w
		move.b	(a0)+,$fffffa0f.w
		move.b	(a0)+,$fffffa13.w
		move.b	(a0)+,$fffffa15.w
		move.b	(a0)+,$fffffa17.w
		move.b	(a0)+,$fffffa19.w
		move.b	(a0)+,$fffffa1b.w
		move.b	(a0)+,$fffffa1f.w
		move.b	(a0)+,$fffffa21.w
		rts

restore_colours	movem.l	old_colours,d0-d7
		movem.l	d0-d7,$ffff8240.w
		rts

install_all:
		move.w	#0,-(a7)
		pea	-1.w
		pea	-1.w
		move.w	#5,-(a7)
		trap	#14
		lea	12(a7),a7

		move.w	#37,-(a7)
		trap	#14
		addq.l	#2,a7

		move.w	#$2700,sr
		clr.l	vbl_timer
		move.l	#vbl,$70.w
		clr.l	$fffffa06.w
		clr.l	$fffffa12.w
		move.b	#$40,$fffffa17.w
		bsr	install_keyboard

		lea	current_palette,a0
		bsr	install_palette
		move.w	#$2300,sr
		rts

;-------------------------------------------------------
install_keyboard:
		move.l	#key,$118.w
		bset	#6,$fffffa09.w
		bset	#6,$fffffa15.w
		rts

key:		move.b	$fffffc02.w,keyboard_dummy
		rte

;-------------------------------------------------------
vbl:		movem.l	d0-a6,-(a7)
		cmp.b	#$39,$fffffc02.w
		beq	exit_intro

		tst.w	palette_flag
		beq.s	.nopal

		clr.w	palette_flag
		move.l	palette_address,a0
		movem.l	(a0),d0-d7
		movem.l	d0-d7,$ffff8240.w

.nopal:
		move.l	vbl_routine,d0
		beq.s	.none
		move.l	d0,a0
		jsr	(a0)
.none:
		addq.l	#1,vbl_timer
		movem.l	(a7)+,d0-a6
		rte

swap_screens:
		move.l	logic,d0
		move.l	physic,logic
		move.l	d0,physic
		lsr.w	#8,d0
		move.l	d0,$ffff8200.w
		rts

;-------------------------------------------------------
;		SECTION	PALETTE
;-------------------------------------------------------
install_palette:
		move.l	a0,palette_address
		move.w	#-1,palette_flag
		rts

install_screens:
		move.l	#screens,d0
		sub.b	d0,d0
		move.l	d0,physic
		add.l	#32000,d0
		move.l	d0,logic
		rts

install_fade:
		move.w	d0,fade_speed
		lea	fade_destination,a1
		moveq	#16-1,d7
.fade		move.w	(a0)+,d0
		bsr	convert_to_internal
		move.b	d1,(a1)+
		move.b	d2,(a1)+
		move.b	d3,(a1)+
		dbf	d7,.fade

		move.l	palette_address,a0
		lea	fade_start,a1
		moveq	#16-1,d7
.fade2		move.w	(a0)+,d0
		bsr	convert_to_internal
		move.b	d1,(a1)+
		move.b	d2,(a1)+
		move.b	d3,(a1)+
		dbf	d7,.fade2
		rts

convert_to_internal:
		lea	convert_to_internal_table,a6
		move.b	d0,d1
		and.w	#$f,d1
		move.b	(a6,d1.w),d3
		lsr.w	#4,d0
		move.b	d0,d1
		and.w	#$f,d1
		move.b	(a6,d1.w),d2
		lsr.w	#4,d0
		move.b	d0,d1
		and.w	#$f,d1
		move.b	(a6,d1.w),d1
		rts



vbl_fade:
		subq.w	#1,fade_temp
		bgt	.no_fade

		move.w	fade_speed,fade_temp
		addq.w	#1,fade_count
		cmp.w	#17,fade_count
		beq.s	vbl_fade_done

		lea	fade_start,a0
		lea	fade_destination,a1
		lea	convert_to_ste_table,a2
		move.l	palette_address,a3

		move.w	fade_count,d2
		moveq	#16-1,d0
.fader
		move.b	(a1)+,d1
		sub.b	(a0),d1
		ext.w	d1
		muls.w	d2,d1
		asr.w	#4,d1
		add.b	(a0)+,d1
		ext.w	d1
		move.b	(a2,d1.w),d3

		move.b	(a1)+,d1		
		sub.b	(a0),d1
		ext.w	d1
		muls.w	d2,d1
		asr.w	#4,d1
		add.b	(a0)+,d1
		ext.w	d1

		asl.w	#4,d3
		or.b	(a2,d1.w),d3

		move.b	(a1)+,d1		
		sub.b	(a0),d1
		ext.w	d1
		muls.w	d2,d1
		asr.w	#4,d1
		add.b	(a0)+,d1
		ext.w	d1

		asl.w	#4,d3
		or.b	(a2,d1.w),d3

		and.w	#$0fff,d3
		move.w	d3,(a3)+
		dbf	d0,.fader

		move.w	#-1,palette_flag
.no_fade:	rts


vbl_fade_done:	clr.l	vbl_routine
		clr.w	fade_count
		clr.w	fade_temp
		st	fade_done_flag
		rts

start_fade:	move.w	#0,fade_count
		clr.w	fade_done_flag
		clr.w	fade_temp
		move.l	#vbl_fade,vbl_routine
		rts


convert_to_internal_table:
		dc.b	0,2,4,6,8,10,12,14
		dc.b	1,3,5,7,9,11,13,15
convert_to_ste_table:
		dc.b	0,8,1,9,2,10,3,11
		dc.b	4,12,5,13,6,14,7,15


;-------------------------------------------------------
;		SECTION	PICTURE
;-------------------------------------------------------
install_picture:
		pea	(a0)
		lea	32(a0),a1
		move.l	logic,a2
		bsr	backform
		move.l	(a7)+,a0

		moveq	#1,d1
		bsr	install_fade
		bsr	swap_screens
		rts


backform:
; formt Bild aus Spezialformat zurÅck
; a0=Adresse

		move.w	#(200*20)-1,D0
.backformloop0:	moveq	#0,D1		; clear Plane 0-3
		moveq	#0,D2
		moveq	#0,D3
		moveq	#0,D4
		moveq	#3,D5		; 4 words
.backformloop1:	move.w	(A1)+,D7	; get word (Special)
		add.w	D7,D7		; shift left by 1
		addx.w	D1,D1		; Plane 0 set
		add.w	D7,D7		;
		addx.w	D2,D2		;
		add.w	D7,D7		;
		addx.w	D3,D3		;
		add.w	D7,D7		;
		addx.w	D4,D4		;
		add.w	D7,D7		;
		addx.w	D1,D1		;
		add.w	D7,D7		;
		addx.w	D2,D2		;
		add.w	D7,D7		;
		addx.w	D3,D3		;
		add.w	D7,D7		;
		addx.w	D4,D4		;
		add.w	D7,D7		;
		addx.w	D1,D1		;
		add.w	D7,D7		;
		addx.w	D2,D2		;
		add.w	D7,D7		;
		addx.w	D3,D3		;
		add.w	D7,D7		;
		addx.w	D4,D4		;
		add.w	D7,D7		;
		addx.w	D1,D1		;
		add.w	D7,D7		;
		addx.w	D2,D2		;
		add.w	D7,D7		;
		addx.w	D3,D3		;
		add.w	D7,D7		;
		addx.w	D4,D4		;
		dbra	D5,.backformloop1
		move.w	D4,(A2)+	;
		move.w	D3,(A2)+
		move.w	D2,(A2)+
		move.w	D1,(A2)+
		dbra	D0,.backformloop0
		rts

display_picture:
		bsr	start_fade
		rts

;-------------------------------------------------------
;			SECTION	TEXT
;-------------------------------------------------------
Char_Width	=	17
Space_Width	=	8

text_handler:
.display_loop:
		moveq	#0,d0
		move.b	(a0)+,d0
		bpl.s	.display_loop

		sub.w	#128,d0
		ext.w	d0
		add.w	d0,d0
		add.w	d0,d0
		move.l	dlist(pc,d0.w),a1
		jsr	(a1)
		bra	.display_loop
display_end:	addq.l	#4,a7
		rts


dlist:		dc.l	clear_logic
		dc.l	display_end
		dc.l	wait_music
		dc.l	set_text
		dc.l	print_text
		dc.l	0	;initialize_screen
		dc.l	swap_screens

ComClear	equ	128
ComEnd		equ	129
ComWait		equ	130
ComSet		equ	131
ComPrint	equ	132
ComShow		equ	133
ComSwap		equ	134

clear_screens:
		move.l	physic,a1
		bsr	clear_one
		;Falls through
clear_logic:
		move.l	logic,a1
clear_one:	moveq	#0,d0
		move.w	#32000/16-1,d1
.clear:		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		dbf	d1,.clear
		rts

set_text:
		moveq	#0,d0
		move.b	(a0)+,d0
		asl.w	#1,d0
		move.w	d0,text_x
		moveq	#0,d0
		move.b	(a0)+,d0
		move.w	d0,text_y
		rts

print_text:
		moveq	#0,d0
		move.b	(a0)+,d0		;which screen! (ignored)
		move.l	logic,a1
		move.l	a1,textscreen

text_print2
.get_letter
		moveq	#0,d2
		move.b	(a0)+,d2		;d0 = letter to do
		bmi	.text_done
		moveq	#0,d1
		sub.w	#" ",d2
		move.w	#Char_Width,d1
		lea	text_convert_table,a6
		move.b	(a6,d2.w),d2
		bpl.s	.ok2
		move.w	#Space_Width,d1
		bra	.dont_draw
.ok2
		move.w	d1,text_to_add
		pea	(a0)
		  bsr	   text_draw_letter
		move.l	(a7)+,a0
.dont_draw:
		move.w	text_to_add,d0
		add.w	d0,text_x
		bra	.get_letter

.text_done:	subq.l	#1,a0
		rts

;--------------------------------------------------------------
text_draw_letter:
		movem.w	text_x,d0/d1
		mulu.w	#8*48,d2
		add.l	#text_font,d2
		move.l	d2,a0

		move.l	textscreen,A1
		mulu.w	#160,D1			;can't be bothered...
		add.l	D1,A1
		move.w	D0,D1
		and.w	#$F,D0			;d0 = shift amt

		move.w	d0,d7
		lea	text_mask_table,a6

		add.w	d7,d7
		move.w	0(a6,d7.w),d6		;left mask
		move.w	d6,d7
		not.w	d7

		eor.w	d0,d1			;d1 = x-offset
		asr.w	#1,d1			;16 pixels = 8 bytes
		add.w	d1,a1

		moveq	#48-1,d5
.doline:
		move.l	(a0)+,d1		;fiddle with
		move.l	(a0)+,d2
		ror.l	d0,d1
		ror.l	d0,d2
		eor.w	d1,8(a1)		;middle section sorted...
		eor.w	d2,10(a1)		;this is correct
		swap	d1
		swap	d2

		move.w	d1,d3
		and.w	d6,d3
		eor.w	d3,0(a1)
		move.w	d2,d3
		and.w	d6,d3
		eor.w	d3,2(a1)

		and.w	d7,d1
		eor.w	d1,16(a1)
		and.w	d7,d2
		eor.w	d2,18(a1)

		lea	160(a1),a1
		dbf	d5,.doline
		rts

text_error	rts

display_text_screen
		bsr	swap_screens
		lea	text_palette,a0
		moveq.l	#1,d0
		bsr	install_fade
		bsr	start_fade
		rts


;-----------------------------------------------------------
			SECTION DATA
;-----------------------------------------------------------
		even
text_1:
		dc.b	ComClear
		dc.b	ComSet,160/2,150,ComPrint,0,"maggie"
		dc.b	ComEnd
text_2:
		dc.b	ComClear
		dc.b	ComSet,160/2,0,ComPrint,0,"goes back"
		dc.b	ComSet,160/2,40,ComPrint,0,"to basics"
		dc.b	ComEnd
text_3:
		dc.b	ComClear
		dc.b	ComSet,80/2+4,100,ComPrint,0,"for issue"
		dc.b	ComSet,80/2,140,ComPrint,0,"twenty one"
		dc.b	ComEnd

text_4:
		dc.b	ComClear
		dc.b	ComSet,0/2,100,ComPrint,0,"pixel excellence"
		dc.b	ComSet,0/2,140,ComPrint,0,"by flan of exa"
		dc.b	ComEnd

text_5:
		dc.b	ComClear
		dc.b	ComSet,0/2,100,ComPrint,0,"sonic excellence"
		dc.b	ComSet,0/2,140,ComPrint,0,"by lap of next"
		dc.b	ComEnd

text_6:
		dc.b	ComClear
		dc.b	ComSet,0/2,100,ComPrint,0,"coding negligence"
		dc.b	ComSet,0/2,140,ComPrint,0,"by tat of avena"
		dc.b	ComEnd

text_7:
		dc.b	ComClear
		dc.b	ComSet,0/2,00,ComPrint,0,"Four plane"
		dc.b	ComSet,0/2,40,ComPrint,0,"distortion"
		dc.b	ComSet,0/2,80,ComPrint,0,"routines"
		dc.b	ComEnd

text_8:
		dc.b	ComClear
		dc.b	ComSet,50/2,100,ComPrint,0,"Now lets"
		dc.b	ComSet,50/2,130,ComPrint,0,"ruin Uncle"
		dc.b	ComSet,50/2,160,ComPrint,0,"Sam Tramiel"
		dc.b	ComEnd

text_9:
		dc.b	ComClear
		dc.b	ComSet,0/2,160,ComPrint,0,"Greetings bit"
		dc.b	ComEnd

text_10:
		dc.b	ComClear
		dc.b	ComSet,0/2,50,ComPrint,0,"Hope you enjoyed"
		dc.b	ComSet,0/2,90,ComPrint,0,"this little intro"
		dc.b	ComEnd

text_11:
		dc.b	ComClear
		dc.b	ComSet,0/2,120,ComPrint,0,"Some more patterns"
		dc.b	ComSet,0/2,160,ComPrint,0,"to finish"
		dc.b	ComEnd

		even

Text_Convert_Table:
		dcb.b	65-32,-1
		dc.b	26,27,28,29,30,31,32,33,34,35,36,37,38
		dc.b	39,40,41,42,43,44,45,46,47,48,49,50,51
		dcb.b	6,-1
		dc.b	0,1,2,3,4,5,6,7,8,9,10,11,12
		dc.b	13,14,15,16,17,18,19,20,21,22,23,24,25
		even

text_mask_table:
		dc.w	%1111111111111111	;16
		dc.w	%0111111111111111	;15
		dc.w	%0011111111111111	;14
		dc.w	%0001111111111111	;13
		dc.w	%0000111111111111	;12
		dc.w	%0000011111111111	;11
		dc.w	%0000001111111111	;10
		dc.w	%0000000111111111	;9
		dc.w	%0000000011111111	;8
		dc.w	%0000000001111111	;7
		dc.w	%0000000000111111	;6
		dc.w	%0000000000011111	;5
		dc.w	%0000000000001111	;4
		dc.w	%0000000000000111	;3
		dc.w	%0000000000000011	;2
		dc.w	%0000000000000001	;1	








script:
		;dc.l	script_fade,greetings_palette,1
		;dc.l	script_wait_music,$10
		;dc.l	greetings


		dc.l	script_install_picture,avena_picture
		dc.l	script_wait_music,$120
		dc.l	script_display_picture

		dc.l	script_wait_music,100+$120
		dc.l	script_fade,black_palette,1

		dc.l	script_text_handler,text_1
		dc.l	script_wait_music,200+$120
		dc.l	script_display_text_screen
		dc.l	script_wait_music,270+$120
		dc.l	script_fade,black_palette,1

		dc.l	script_text_handler,text_2
		dc.l	script_wait_music,340+$120
		dc.l	script_display_text_screen
		dc.l	script_wait_music,410+$120
		dc.l	script_fade,black_palette,1
		dc.l	script_text_handler,text_3
		dc.l	script_wait_music,480+$120
		dc.l	script_display_text_screen
		dc.l	script_wait_music,550+$120
		dc.l	script_fade,black_palette,1

		dc.l	script_wait_music,$3d0
		dc.l	script_fade,white_palette,1
		dc.l	script_wait_music,$3f0

		dc.l	script_tunnel_start,$480	;go!
		dc.l	20,80
		dc.l	2*((200*0)+0),tunnel_palette_1
		dc.l	tunnel_gfx_1

		dc.l	script_fade,white_palette,1
		dc.l	script_wait_music,$4a0
		dc.l	script_bunny
		dc.l	script_install_picture,bunny_picture
		dc.l	script_display_picture
		dc.l	script_wait_music,$540
		dc.l	script_fade,white_palette,1
		dc.l	script_wait_music,$560

		dc.l	script_tunnel_start,$600
		dc.l	10,100
		dc.l	2*((200*0)+100),tunnel_palette_2
		dc.l	tunnel_gfx_2

		dc.l	script_tunnel_start,$700
		dc.l	20,50
		dc.l	2*((200*0)+40),tunnel_palette_3
		dc.l	tunnel_gfx_3

		dc.l	script_tunnel_start,$800
		dc.l	10,100
		dc.l	2*((200*0)+100),tunnel_palette_4
		dc.l	tunnel_gfx_4

		dc.l	script_text_handler,text_4
		dc.l	script_wait_music,$810
		dc.l	script_display_text_screen
		dc.l	script_wait_music,$880
		dc.l	script_fade,black_palette,1
		dc.l	script_text_handler,text_5
		dc.l	script_wait_music,$890
		dc.l	script_display_text_screen
		dc.l	script_wait_music,$900
		dc.l	script_fade,black_palette,1

		dc.l	script_text_handler,text_6
		dc.l	script_wait_music,$910
		dc.l	script_display_text_screen

		dc.l	script_wash_start
		dc.l	0,bunny_picture+32+30

		dc.l	script_wait_music,$980
		dc.l	script_fade,black_palette,2
		dc.l	script_wait_music,$9e0

tb= $9e0
; purely stationary
		dc.l	script_wash_do
		dc.l	bunny_picture+0
		dc.l	$40			;rot start
		dc.l	100,0,0			;rot amount, speed, offset
		dc.l	20,0,0			;rip amount, speed, offset
		dc.l	tb+$50			;finish time

		dc.l	script_wash_do
		dc.l	bunny_picture+0
		dc.l	$80			;rot start
		dc.l	200,0,20		;rot amount, speed, offset
		dc.l	0,00,0			;rip amount, speed, offset
		dc.l	tb+$a0			;finish time

		dc.l	script_wash_do
		dc.l	bunny_picture+0
		dc.l	0			;rot start
		dc.l	100,0,10		;rot amount, speed, offset
		dc.l	0,00,0			;rip amount, speed, offset
		dc.l	tb+$f0			;finish time

; Oh dear, whats this?
		dc.l	script_text_handler,text_7
		dc.l	script_display_text_screen
		dc.l	script_wait_music,tb+$180
		dc.l	script_fade,black_palette,1
		dc.l	script_wait_music,tb+$1a0

		dc.l	script_wash_do
		dc.l	bunny_picture+0
		dc.l	0		;rot start
		dc.l	100,10,4	;rot amount, speed, offset
		dc.l	0,00,0		;rip amount, speed, offset
		dc.l	tb+$280		;finish time

		dc.l	script_wash_do
		dc.l	bunny_picture+0
		dc.l	0		;rot start
		dc.l	0,0,0		;rot amount, speed, offset
		dc.l	20,20,0		;rip amount, speed, offset
		dc.l	tb+$480		;finish time

		dc.l	script_wash_do
		dc.l	bunny_picture+0
		dc.l	0		;rot start
		dc.l	0,0,0		;rot amount, speed, offset
		dc.l	20,20,-40	;rip amount, speed, offset
		dc.l	tb+$600		;finish time

		dc.l	script_text_handler,text_8
		dc.l	script_display_text_screen

		dc.l	script_wash_start
		dc.l	0,stramiel_picture+32

		dc.l	script_wait_music,tb+$700

		dc.l	script_fade,black_palette,1
		dc.l	script_wait_music,tb+$720
; Uncle Sam
		dc.l	script_wash_do
		dc.l	stramiel_picture+0
		dc.l	0		;rot start
		dc.l	100,8,8		;rot amount, speed, offset
		dc.l	0,0,0		;rip amount, speed, offset
		dc.l	tb+$880		;finish time

		dc.l	script_wash_do
		dc.l	stramiel_picture+0
		dc.l	0		;rot start
		dc.l	100,8,4		;rot amount, speed, offset
		dc.l	30,4,4		;rip amount, speed, offset
		dc.l	tb+$a00		;finish time

tb2=tb+$a00

		dc.l	script_wash_start
		dc.l	1,0

;tb2=$80
; Patterned effects:
		dc.l	script_wash_do
		dc.l	pattern_palette_1
		dc.l	0		;rot start
		dc.l	0,8,4		;rot amount, speed, offset
		dc.l	0,14,-8		;rip amount, speed, offset
		dc.l	tb2+$80	;finish time

		dc.l	script_wash_do
		dc.l	pattern_palette_2
		dc.l	0		;rot start
		dc.l	0,8,4		;rot amount, speed, offset
		dc.l	20,14,-38	;rip amount, speed, offset
		dc.l	tb2+$180	;finish time

		dc.l	script_wash_do
		dc.l	pattern_palette_3
		dc.l	0		;rot start
		dc.l	100,4,4		;rot amount, speed, offset
		dc.l	20,14,10	;rip amount, speed, offset
		dc.l	tb2+$3c0	;finish time

gb=tb2+$3c0
; Greetings:
		dc.l	script_text_handler,text_9
		dc.l	script_display_text_screen
		dc.l	script_wait_music,gb+$c0
		dc.l	script_fade,black_palette,1
		dc.l	script_wait_music,gb+$10
		dc.l	script_reset_timer
		dc.l	script_fade,greetings_palette,1
		dc.l	script_wait_music,$10
		dc.l	greetings

		dc.l	script_reset_timer
; " Goodbye"
		dc.l	script_fade,black_palette,1
		dc.l	script_wait_music,$10
		dc.l	script_text_handler,text_10
		dc.l	script_display_text_screen
		dc.l	script_wait_music,$80
		dc.l	script_fade,black_palette,1
		dc.l	script_wait_music,$90

		dc.l	script_reset_timer

		dc.l	script_text_handler,text_11
		dc.l	script_display_text_screen

		dc.l	script_wash_start
		dc.l	1,0

		dc.l	script_wait_music,$80
		dc.l	script_fade,black_palette,1
		dc.l	script_wait_music,$90
; End Loop
end_loop:
		dc.l	script_reset_timer

;tb2=$80
; Patterned effects:
		dc.l	script_wash_do
		dc.l	pattern_palette_1
		dc.l	0		;rot start
		dc.l	0,8,4		;rot amount, speed, offset
		dc.l	0,14,-8		;rip amount, speed, offset
		dc.l	$300		;finish time

		dc.l	script_wash_do
		dc.l	pattern_palette_2
		dc.l	0		;rot start
		dc.l	30,8,4		;rot amount, speed, offset
		dc.l	10,14,-28	;rip amount, speed, offset
		dc.l	$600		;finish time

		dc.l	script_wash_do
		dc.l	pattern_palette_3
		dc.l	0		;rot start
		dc.l	100,4,2		;rot amount, speed, offset
		dc.l	10,14,10	;rip amount, speed, offset
		dc.l	$900		;finish time
		dc.l	script_reloop,end_loop

		dc.l	-1

;-------------------------------------------------------
			SECTION	DATA
;-------------------------------------------------------
vbl_routine:		dc.l	0

text_font		incbin	data\courier.dat
			even


tunnel_gfx_buffer:
ring_buffer		;ds.b	max_ring_number*max_ring_angle*2
			;ds.b	4*(64*64*2)		; = 32768 bytes
avena_picture:		incbin	d:\source2\maggie.ori\m21.pic
			ds.b	768

bunny_picture:		incbin	data\lapours.pic
stramiel_picture	incbin	data\stramiel.pic

			even
tune:			incbin	data\tune.lap
			even
sine_table:		incbin	f:\data\smallsin.dat
			even

tunnel_palette_1:	dc.w	$000,$112,$224,$336
tunnel_palette_2:	dc.w	$000,$212,$424,$636
tunnel_palette_3:	dc.w	$000,$114,$2ef,$fff
tunnel_palette_4:	dc.w	$000,$122,$244,$366

text_palette:		dc.w	$000,$444,$666,$777
			dcb.w	12,$fff

pattern_palette_1:
			dc.w	$000,$100,$200,$300
			dc.w	$400,$500,$600,$f00
			dc.w	$f11,$f22,$f33,$f44
			dc.w	$f55,$f66,$f77,$fff

pattern_palette_2:
			dc.w	$000,$001,$002,$003
			dc.w	$004,$005,$006,$007
			dc.w	$11f,$22f,$33f,$44f
			dc.w	$55f,$66f,$77f,$fff

pattern_palette_3:
			dc.w	$000,$101,$202,$303
			dc.w	$404,$505,$606,$707
			dc.w	$f1f,$f2f,$f3f,$f4f
			dc.w	$f5f,$f6f,$f7f,$fff

black_palette:		dcb.w	16,0
blue_palette:		dcb.w	16,$00f
white_palette:		dcb.w	16,$fff


;-------------------------------------------------------
			SECTION	BSS
;-------------------------------------------------------
			even
bunny_palette:		ds.w	16
old_colours		ds.w	16
text_x			ds.w	1
text_y			ds.w	1
text_to_add		ds.w	1
textscreen		ds.l	1

logic			ds.l	1
physic			ds.l	1
keyboard_dummy:		ds.w	1

palette_address:	ds.l	1
palette_flag:		ds.w	1
fade_speed		ds.w	1
fade_temp		ds.w	1
fade_start		ds.b	16*3
fade_destination	ds.b	16*3
			even
fade_count		ds.w	1
fade_done_flag		ds.w	1
current_palette		ds.w	16

vbl_timer:		ds.l	1
music_timer:		ds.l	1

save_stack:		ds.l	1
save_area:		ds.b	64
save_resolution:	ds.w	1
soundchip_buffer:	ds.b	16

			ds.l	200
stack:

			ds.b	256
screens:		ds.b	32000*2


			include	greets.s
			include	wash2.s
			include	tunnel2.s



