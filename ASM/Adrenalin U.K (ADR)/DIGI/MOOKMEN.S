*************************************************************************
*									*
*									*
* DIGI TALLIS menu RECODED and SARCASIC COMMENTS ADDED by MSD/POV	*
*									*
*************************************************************************

doob		movea.l	4(sp),a5	; yeah, fucking shoot us. its PEXEC!
		move.l	#$1000,-(sp)
		move.l	a5,-(sp)
		clr.w	-(sp)
		move.w	#$4a,-(sp)
		trap	#1
		lea	12(sp),sp

		bsr	clear_bss
		bsr	set_super
		move.b	#$12,$fffffc02.w	;no mouse
		bsr	screen_in		;set screen position

		movem.l	$ffff8240.w,d0-d7	;save old pal
		movem.l	d0-d7,old_pal
		movem.l	pal,d0-d7		;set new pal
		movem.l	d0-d7,$ffff8240.w

		bsr	print_logo

		bsr	text_print	;I've left this alone - MSD

		bsr	save_old

		moveq	#1,d0		;init music
		bsr	music

		bsr	new_vecs	

eternity	bra	eternity



vbl		clr.w	$ffff8240.w
		bsr	load_go_control
		bsr	music+8
		bsr	colours_count
		bsr	scroll_rout


		move.w	#$2700,sr	;ISRs off
		move.w	#256,d1
ere		lea $ffff8209.w,a3	;check low video byte
test					;sync in
		tst.b	(a3)
		beq.s	test

		moveq	#0,d0
		move.b	(a3),d0		;get low video byte address
		lea	jump,a3		;get nops address
		add.l	d0,a3
		jmp	(a3)		;jump into NOPS for rock steady code
jump		rept	77
		nop
		endr
		move.w	#$2300,sr	;ISRs on

		move.w	#15,d0		;y_size of font!
		lea	colr_bank,a0
		lea	$ffff8240.w,a1


colp		move.w	y_size,d1

colour_loop	rept	16		;take any NOPs off here.
		nop
		endr
		rept	34
		move.w	(a0)+,(a1)
		endr
		nop			;they must be put back here
		rept	3
		nop
		endr
		sub.w	#68,a0
		dbf	d1,colour_loop

		rept	16		;as above. Take em off
		nop
		endr
		lea	2(a0),a0
		rept	33
		move.w	(a0)+,(a1)
		endr
		rept	3
		nop
		endr
		dbf	d0,colp

		move.w	#$000,$ffff8240.w
		rte




load_go_control	move.b	$fffffc02.w,d0

		cmp.b	#1,d0		;ESCape key
		bne.s	.not_esc
		move.l	#"MSD!",$200.w
		bra.s	.stop
.not_esc	lea	demo_keys,a0	;YEAH POV check key rout!!!
.next		move.w	(a0)+,d1
		bmi.s	quit_key_check
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


.stop		bsr	return_old
		moveq	#0,d0
		jsr	music
		bsr	return_screen
		cmp.l	#"MSD!",$200.w
		beq.s	assem
		bra	load_and_go
quit_key_check	rts




load_and_go	pea	env
		pea	com
		pea	$200.w
		move.w	#0,-(sp)
		move.w	#$4b,-(sp)
		trap	#1
		lea	16(sp),sp
assem		clr.w	-(sp)
		trap	#1
env		dc.l	0
com		dc.l	0




************************************************************************
scroll_rout

******** THE FOLLOWING LINES HAVE BEEN REPLACED - READ THE TEXT ********
*	addq.w	#1,bit_count		;add 1 to rol counter
*	cmpi.w	#16,bit_count		;compare it to end of word
*	bne.s	scroll_main		;NO ITS NOT, LETS FUCK OFF
*	clr.w	bit_count	
*
*	I'VE ALTERED THE ABOVE LINES TO THE 3 BELOW BECAUSE THE sub INSTRUCTION
*	DECREASES A VALUE AND WHEN IT IS ZER0 THE CR BYTE IS ALTERED SO WE DON'T
*	NEED TO DO THE cmp INSTRUCTION. I KNOW IT ONLY SAVE 1 INSTRUCTION BUT
*	IT'S ALL SPEED AND IT COULD BE THE DIFFERENCE BETWEEN 1 & 2 FRAMES!
*
*	msd/pov 24/4/93
*
		sub.w	#1,bit_count	;dec rol counter
		bne.s	scroll_main	;CR bytes has been altered so no need to cmp
		move.w	#16,bit_count
************************************************************************

scroll_update	addq.w	#1,letter	
		lea	ascii,a0		
		add.w	letter,a0	

**** why CMP when TST will do (it saves a byte - wow!)
		tst.b	(a0)			;cmpi.b	#$ff,(a0)
		bpl.s	scroll_next_letter	;bne.s	scroll_next_letter

		lea	ascii,a0			
		clr.w	letter			
scroll_next_letter			
		moveq	#0,d0
		move.b	(a0)+,d0
		sub.w	#32,d0
		mulu.w	#32,d0		;this could be LSL.W #5,D0
		lea	font,a0
		add.w	d0,a0
		lea	temp_buffer,a1
		rept	16			; Y        
		move.w	(a0)+,(a1)+	        
		endr
scroll_main	lea	colr_bank,a0	;IT COPYS THE BANK LEFT. HAPPY NOW?
		rept	16
		move.w	2(a0),(a0)
		move.w	4(a0),2(a0)
		move.w	6(a0),4(a0)
		move.w	8(a0),6(a0)
		move.w	10(a0),8(a0)
		move.w	12(a0),10(a0)
		move.w	14(a0),12(a0)
		move.w	16(a0),14(a0)
		move.w	18(a0),16(a0)
		move.w	20(a0),18(a0)
		move.w	22(a0),20(a0)
		move.w	24(a0),22(a0)
		move.w	26(a0),24(a0)
		move.w	28(a0),26(a0)
		move.w	30(a0),28(a0)
		move.w	32(a0),30(a0)
		move.w	34(a0),32(a0)
		move.w	36(a0),34(a0)
		move.w	38(a0),36(a0)
		move.w	40(a0),38(a0)
		move.w	42(a0),40(a0)
		move.w	44(a0),42(a0)
		move.w	46(a0),44(a0)
		move.w	48(a0),46(a0)
		move.w	50(a0),48(a0)
		move.w	52(a0),50(a0)
		move.w	54(a0),52(a0)
		move.w	56(a0),54(a0)
		move.w	58(a0),56(a0)
		move.w	60(a0),58(a0)
		move.w	62(a0),60(a0)
		move.w	64(a0),62(a0)
		move.w	66(a0),64(a0)
		lea	68(a0),a0
		endr

		lea	colr_bank,a0	
		lea	temp_buffer,a1
		move.w	#15,d0
come_here	roxl	(a1)+
	 	bcs.s	slap_down	
		move.w	#$000,66(a0)	
		bra.s	out_rep		
slap_down	move.w	(a6),66(a0)
out_rep		lea	2(a6),a6
		lea	68(a0),a0	
		dbf	d0,come_here	
		rts


colours_count	addq.w	#2,color_pnt
		cmpi.w	#(57*2),color_pnt
		bne.s	out_color
		clr.w	color_pnt
out_color	lea	colors,a6
		add.w	color_pnt,a6
		rts	


****************UNTOUCHED AS IT ISN'T SPEED ESSENTIAL************
	;pass in text location in a0
text_print	clr.l	bit_place
		lea	test_text,a0
		move.l	x_text_pos,d0
		move.l	y_text_pos,d1
go_printer	cmpi.b	#0,(a0)			;terminate text!!
		beq	quit_text_print
		cmpi.b	#13,(a0)		;return to beginning of line.
		beq	back_to_beginning
		cmpi.b	#10,(a0)		;down a line.
		beq	down_a_line

		cmp.b	#32,(a0)		;less than space
		blt	no_print
		cmp.b	#126,(a0)		;bigger than lower z	
		bgt	no_print

		move.l	base,a1			;\
		add.l	#2,a1
		add.l	d0,a1			;-get right place on screen!
		add.l	d1,a1			;/
		lea	text_font,a2
		moveq.l	#0,d2
		move.b	(a0)+,d2		;store letter in data reg!
		sub.b	#32,d2			;right in bank
		lsl.l	#3,d2			;mulu	#8,d2
		add.l	d2,a2

		rept	8
		move.b	(a2)+,d3
		or.b	d3,0(a1)
		or.b	d3,2(a1)
		lea	160(a1),a1
		endr

		cmp.l	#1,bit_place
		beq.s	second_8
		add.l	#1,bit_place
		addq.l	#1,d0	
		bra.s	compare_for_end
second_8	move.l	#0,bit_place
		addq.l	#7,d0	
compare_for_end	cmp.l	#160,d0
		beq.s	back_and_down	
		bra	go_printer
quit_text_print	rts

back_and_down	move.l	x_text_pos,d0
		move.l	#0,bit_place
		bra.s	down_a_line

*** MSD sez WHY is this here when a BRA is above???????
;;;;		bra	go_printer	;security reasons!!! (ahah! lazy!)

back_to_beginning
		addq.l	#1,a0
		move.l	x_text_pos,d0
		move.l	#0,bit_place
		bra	go_printer
down_a_line	addq.l	#1,a0
		add.l	#(160*8),d1
		cmp.l	#(200*160),d1
		bge.s	quit_text_print
		bra	go_printer
no_print	addq.l	#1,a0
		bra	go_printer


************************************************************************
screen_in	
;first we MUST define our own screen area NEVER assume a memory address!!!!
;         ~~~~                            ~~~~~
;
; If a coder assumes a screen address then they are dumb fuckers who don't
; have a hard disc (wot no 512K disc cache???) - MSD/POV
;
; PLUS we must save the old base and rez!
; 
		move.b	$ffff8260.w,old_rez
		move.l	$44e.w,old_base

		move.l	#screens,d0	;setup our screens
		clr.b	d0
		move.l	d0,base
		move.l	d0,base_one
		add.l	#32000,d0
		move.l	d0,base_two

		clr.w	-(sp)
		move.l	base,-(sp)
		move.l	base,-(sp)
		move.w	#$5,-(sp)
		trap	#14
		add.w	#12,sp
		rts

return_screen	moveq	#0,d0
		move.w	old_rez,d0
		move.w	d0,-(sp)
		move.l	old_base,-(sp)
		move.l	(sp),-(sp)
		move.w	#$5,-(sp)
		trap	#14
		add.w	#12,sp
		movem.l	old_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w
		rts


clear_bss
;clear BSS saves us clearing screen and some packers don't clear it.
		lea	bss_start,a0
		move.l	#bss_end-bss_start,d0
.clear		clr.b	(a0)+
		sub.l	#1,d0
		bne.s	.clear
		rts

set_super	clr.l 	-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.w	#6,sp
		move.l	d0,savesp
		rts

set_user	move.l	savesp,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.w	#6,sp
		rts

print_logo	lea	logo+34,a1	;print logo
		move.l	base,a0
		move.w	#8000/4-1,d0
clear_it	move.l	(a1)+,(a0)+
		dbra	d0,clear_it
		rts


save_old	move.l	$70.w,old_vbl
		move.b	$fffffa1b.w,old_a1b
		move.b	$fffffa21.w,old_a21
		move.b	$fffffa07.w,old_a07
		move.b	$fffffa09.w,old_a09
		move.b	$fffffa13.w,old_a13
		move.b	$fffffa15.w,old_a15
		rts

return_old	move.w	#$2700,sr
		move.l	old_vbl,$70.w
		move.b	old_a1b,$fffffa1b.w
		move.b	old_a21,$fffffa21.w
		move.b	old_a07,$fffffa07.w
		move.b	old_a09,$fffffa09.w
		move.b	old_a13,$fffffa13.w
		move.b	old_a15,$fffffa15.w
		movem.l	old_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w
		move.b	#8,$fffffc02.w
		move.w	#$2300,sr
		rts


new_vecs	move.w	#$2700,sr	;tell everythinn to shut up
		move.l	#vbl,$70.w	;set new vbl
		clr.b	$fffffa09.w
		move.b	#1,$fffffa07.w	
		move.b	#1,$fffffa13.w
		clr.b	$fffffa1b.w	;stop timerb
		bclr	#6,$fffffa15.w	;take no stick
		move.w	#$2300,sr
		rts
	




flipper		addq.w	#1,base_place	;poor screen flip but I'm not gonna change it!
		cmpi.w	#2,base_place
		bne	next_base
		clr.w	base_place
next_base	tst.w	base_place
		bne.s	to_base_2
		move.l	base_one,base
		bra.s	flip_screens
to_base_2	move.l	base_two,base
flip_screens	move	#$8201,a0
		move.l	base,d0
		lsr.l	#8,d0
		movep	d0,(a0)
		rts



	SECTION DATA


test_text
	dc.b	13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10
	dc.b	"           ADR MENU LOTS!",13,10,13,10
	dc.b	13,10,13,10
	dc.b	"         (1) Game 1 BOLLOX",13,10
	dc.b	"         (2) Game 2 TESTIS",13,10
	dc.b	"         (3) Game 3 GONADS",13,10
	dc.b	"         (4) Game 4 WEBOS!",13,10
	dc.b	"         (5) Game 5 ZOBBS!",13,10
	dc.b	13,10
	dc.b	13,10
	dc.b	13,10,13,10,13,10,13,10,13,10
	dc.b	" Menu kindly donated by Magic Sector."
	dc.b	" "
	dc.b	0,0,0,0,0,0
	even
x_text_pos	dc.l	8
y_text_pos	dc.l	0
bit_place	dc.l	0
	even
text_font	incbin	'win_fnt.bin'
	even



*****************************************************************
*  data..it all goes from here-on-in 							*
*****************************************************************

bit_count	dc.w	14
y_size		dc.w	13
	even	


******* NEVER make a label called TEXT as DEVPAC takes it as the TEXT SEGMENT!
ascii	;;text
	dc.b	"            "
	dc.b	"PURE ENERGY ARE GREAT MENU CODERS!   (ORM TOLD ME "
	dc.b	"TO WRITE SOMETHING AMUSING!).     ERE YOU JOLLY WELL GO, "
	dc.b	"A MENU, GREAT INIT, USE IT, FLUSH IT, WE DON'T CARE REALLY BUT GIVE "
	DC.B	"CREDIT TO MOON UNIT AND WYRM OF MAGIC SECTOR, CHEERS."
	DC.B	"   OH YEAH, GET YOUR HAIR CUT YOU LANCS GIT!       LOVE D.T."
	DC.B	"       SEE YOU LATER.            BYE           "
	DC.B	"    P.S.    WE'LL SEND YOU AN ADR INTRO SOON!        "
	dc.b	$ff,$ff,$ff
	even
font	incbin	'fbin4.bin'
	even


colors	rept	3
        dc.w    $777,$677,$577,$477,$377,$277,$177,$177,$77,$76
        dc.w    $75,$74,$73,$72,$71,$70,$170,$270,$370,$470
        dc.w    $570,$670,$770,$760,$750,$740,$730,$720,$710,$700
        dc.w    $701,$702,$602,$502,$402,$302,$202,$102,$2,$3
        dc.w    $4,$5,$6,$7,$107,$207,$307,$407,$507,$607
        dc.w    $707,$717,$727,$737,$747,$757,$767
	endr
	dc.w	$000,$000

pal	dc.w	$000,$373,$070,$060,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777



music	incbin	'history.mus'
	even
logo	incbin	'anti.pi1'
	even


demo_keys	;POV KEY CHECK ROUT VALUES
	dc.b	0, $02		;key 1
	dc.b	1, $03		;key 2
	dc.b	2, $04		;key 3
	dc.b	3, $05		;key 4
	dc.b	4, $06		;key 5
	dc.b	5, $07		;key 6
	dc.b	6, $08		;key 7
;	dc.b	7, $09		;key 8
;	dc.b	8, $0a		;key 9

	dc.b	0, $6d		;keypad 1
	dc.b	1, $6e		;keypad 2
	dc.b	2, $6f		;keypad 3
	dc.b	3, $6a		;keypad 4
	dc.b	4, $6b		;keypad 5
	dc.b	5, $6c		;keypad 6
	dc.b	6, $67		;keypad 7
;	dc.b	7, $68		;keypad 8
;	dc.b	8, $69		;keypad 9
	dc.b	-1, -1

filename_table	dc.l	exec1,exec2,exec3,exec4,exec5,exec6,exec7,exec8
exec1	dc.b	"BIG_ALEC.512",0
	even
exec2	dc.b	"TFMX.512",0
	even
exec3	dc.b	"REPLAY4.512",0
	even
exec4	dc.b	"CARTOON.512",0
	even
exec5	dc.b	"TSC49.512",0
	even
exec6	dc.b	"DEMO2.512",0
	even
exec7	dc.b	"COPIER.POV",0
	even
exec8	dc.b	"filename.ext",0
	even





	SECTION BSS
bss_start
savesp		ds.l	1
old_base	ds.l	1
old_rez		ds.b	1
old_a1b		ds.b	1
old_a21		ds.b	1
old_a07		ds.b	1
old_a09		ds.b	1
old_a13		ds.b	1
old_a15		ds.b	1
	even
old_vbl		ds.l	1
color_pnt	ds.w	1
letter		ds.w	1

temp_buffer	ds.w	32

old_pal		ds.w	16
base		ds.l	1
base_one	ds.l	1
base_two	ds.l	1
base_place	ds.w	1

colr_bank	rept	20
		ds.w	34
		endr


	ds.b	256		;space for 256 byte screen boundry
screens	ds.b	32000*2

bss_end
