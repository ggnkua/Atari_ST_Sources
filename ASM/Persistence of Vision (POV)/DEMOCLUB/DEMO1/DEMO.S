********************************************
*                          DEMOCLUB INTRO 2
*                          ----------------
*
* (c) Copyright MSD 1990
* Written in April 1990
*
* Assemble with GENST2
*
********************************************
WIDTH=16

	move.l	sp,a5
	move.l	4(a5),a5	;get basepage
	move.l	12(a5),d0	;text segment
	add.l	$14(a5),d0	;data segment
	add.l	$1c(a5),d0	;unitialized
	add.l	#$100,d0	;basepage size
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move.w	d0,-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	add.l	#12,sp		;okay that's it memory free & allocated

	bsr	set_super
	dc.w	$a00a		;hide mouse
	bsr	get_screen_base
	bsr	get_old_palette
	bsr	set_new_palette
	bsr	get_original_rez
	bsr	set_low_rez
	bsr	show_pic

;************************************************************************
;*                            THUNDERCATS                               *
;*                            -----------                               *
;* Stolen by: MAC SYS DATA of P.O.V. in 1988                            *
;*      From: Er, I think WAS (NOT WAS) or BLADERUNNERS                 *
;* Include files;-                                                      *
;*                 THUNDER.IMG                                          *
;************************************************************************
	move.b	$484,old484
	move.b	#0,$484		;no keyclick/repeat/bell
	move.l	#isr,$4d2
	jsr	tune

wait:
	bsr	v_sync
;	move.w	#$123,$ffff8240.w
	bsr	scroll_background
	bsr	scroll
	bsr	scroll
	bsr	scroll
	bsr	scroll
	bsr	show_buffer
;	clr.w	$ffff8240.w
	bsr	tst_key
	tst.l	d0
	beq.s	wait

	bsr	endmus
	move.b	old484,$484
	bsr	set_old_palette
	bsr	set_org_rez
	dc.w	$a009
	bsr	set_user

	clr.w	-(sp)
	MOVE.W	#$4c,-(SP)	; RETURN TO GEM DESKTOP.
	TRAP	#1
ERR:	bra.s	ERR


*******************
* CUSTOM ROUTINES *
*******************
scroll: move.l  text_pointer,a6
	cmp.b	#$7f,(a6)
	bne.s	no_curve_change
	move.b	(a6)+,d0
	move.b	(a6)+,d0
	and.w	#$ff,d0
	move.w	d0,new_curve
	move.l	a6,text_pointer

no_curve_change:
	cmp.b   #$ff,(a6)
	bne     loop3
	lea     text,a6  ;restart message
	move.l  a6,text_pointer
loop3:  
	tst.w   scroll_number
	bne     loop2
	move.w  #WIDTH,scroll_number
	clr.l   d0
	move.b  (a6)+,d0
	move.l  a6,text_pointer
	sub.w   #32,d0
	lsl.w   #5,d0   ;*32 (1 plane char set)
	lea     font,a6
	add.l   d0,a6   ;letter address is in a6
;transfer letter into buffer
; each line in buffer is 42 bytes long.
	lea     buffer+42,a1
	move.w  (a6)+,40(a1)
	move.w  (a6)+,82(a1)
	move.w  (a6)+,124(a1)
	move.w  (a6)+,166(a1)
	move.w  (a6)+,208(a1)
	move.w  (a6)+,250(a1)
	move.w  (a6)+,292(a1)
	move.w  (a6)+,334(a1)
	move.w  (a6)+,376(a1)
	move.w  (a6)+,418(a1)
	move.w  (a6)+,460(a1)
	move.w  (a6)+,502(a1)
	move.w  (a6)+,544(a1)
	move.w  (a6)+,586(a1)
	move.w  (a6)+,628(a1)
	move.w  (a6),670(a1)    ;32 bytes per char

loop2:
	lea     buffer+42,a5    ;scroll buffer
	move.w  #16-1,d0
loopy:
	roxl    40(a5)
	roxl    38(a5)
	roxl    36(a5)
	roxl    34(a5)
	roxl    32(a5)
	roxl    30(a5)
	roxl    28(a5)
	roxl    26(a5)
	roxl    24(a5)
	roxl    22(a5)
	roxl    20(a5)
	roxl    18(a5)
	roxl    16(a5)
	roxl    14(a5)
	roxl    12(a5)
	roxl    10(a5)
	roxl    8(a5)
	roxl    6(a5)
	roxl    4(a5)
	roxl    2(a5)
	roxl    (a5)

	add.w   #42,a5
	dbf     d0,loopy
	sub.w   #1,scroll_number
	rts

show_buffer:    ;puts scrolline buffer to screen
; sort out if new data for curved scroller is needed.
	tst.w	new_curve
	beq.s	do_same_curve

	lea	curve_tables,a0
	move.w	new_curve,d0
	sub.w	#1,d0	;compensate for 0-7 and not 1-8
	mulu	#8,d0
	add.w	d0,a0
	movem.l	(a0),d0/d1
	move.w	d0,screen_offset
	move.l	d1,last_curve
	clr.w	new_curve
do_same_curve:
	lea	buffer,a0
	move.l  screen_base,a1
	move.w	screen_offset,d0
	add.w	#32000+6,a1
	sub.w	d0,a1

	clr.l	d1
	move.l	d1,d2
	move.l	d2,d3
	move.l	d3,d4
	move.l	d4,d5
	move.l	last_curve,a3

; move data from buffer into D6 then move D6 to screen
; Manipulate D6 in any way to adjust scroll.
	move.w  #16-1,d0
.loop:
	move.l	a1,a2
	move.l	last_curve,a3
	movem.w	(a3)+,d1/d2/d3/d4
	move.w  (a0)+,d6	;get data from buffer
	move.b	d6,d7		;store lower byte
	lsr.w	#8,d6		;move upper byte into lower
	move.b	d6,(a1,d1)	;put lower byte on screen
	move.b	d7,d6		;get lower byte back
	move.b	d6,1(a1,d2)	;put lower byte to screen

	move.w  (a0)+,d6
	move.b	d6,d7
	lsr.w	#8,d6
	move.b	d6,8(a1,d3)	;poke upper bytes
	move.b	d7,d6
	move.b	d6,9(a1,d4)	;poke lower byte

	movem.w	(a3)+,d1/d2/d3/d4
	move.w  (a0)+,d6
	move.b	d6,d7
	lsr.w	#8,d6
	move.b	d6,16(a1,d1)	;poke upper bytes
	move.b	d7,d6
	move.b	d6,17(a1,d2)	;poke lower byte

	move.w  (a0)+,d6
	move.b	d6,d7
	lsr.w	#8,d6
	move.b	d6,24(a1,d3)	;poke upper bytes
	move.b	d7,d6
	move.b	d6,25(a1,d4)	;poke lower byte

	movem.w	(a3)+,d1/d2/d3/d4
	move.w  (a0)+,d6
	move.b	d6,d7
	lsr.w	#8,d6
	move.b	d6,32(a1,d1)	;poke upper bytes
	move.b	d7,d6
	move.b	d6,33(a1,d2)	;poke lower byte
	move.w  (a0)+,d6
	move.b	d6,d7
	lsr.w	#8,d6
	move.b	d6,40(a1,d3)	;poke upper bytes
	move.b	d7,d6
	move.b	d6,41(a1,d4)	;poke lower byte

	movem.w	(a3)+,d1/d2/d3/d4
	move.w  (a0)+,d6
	move.b	d6,d7
	lsr.w	#8,d6
	move.b	d6,48(a1,d1)	;poke upper bytes
	move.b	d7,d6
	move.b	d6,49(a1,d2)	;poke lower byte
	move.w  (a0)+,d6
	move.b	d6,d7
	lsr.w	#8,d6
	move.b	d6,56(a1,d3)	;poke upper bytes
	move.b	d7,d6
	move.b	d6,57(a1,d4)	;poke lower byte

	movem.w	(a3)+,d1/d2/d3/d4
	move.w  (a0)+,d6
	move.b	d6,d7
	lsr.w	#8,d6
	move.b	d6,64(a1,d1)	;poke upper bytes
	move.b	d7,d6
	move.b	d6,65(a1,d2)	;poke lower byte
	move.w  (a0)+,d6
	move.b	d6,d7
	lsr.w	#8,d6
	move.b	d6,72(a1,d3)	;poke upper bytes
	move.b	d7,d6
	move.b	d6,73(a1,d4)	;poke lower byte

	add.w	#80,a1
	movem.w	(a3)+,d1/d2/d3/d4
	move.w  (a0)+,d6
	move.b	d6,d7
	lsr.w	#8,d6
	move.b	d6,(a1,d1)	;poke upper bytes
	move.b	d7,d6
	move.b	d6,1(a1,d2)	;poke lower byte
	move.w  (a0)+,d6
	move.b	d6,d7
	lsr.w	#8,d6
	move.b	d6,8(a1,d3)	;poke upper bytes
	move.b	d7,d6
	move.b	d6,9(a1,d4)	;poke lower byte

	movem.w	(a3)+,d1/d2/d3/d4
	move.w  (a0)+,d6
	move.b	d6,d7
	lsr.w	#8,d6
	move.b	d6,16(a1,d1)	;poke upper bytes
	move.b	d7,d6
	move.b	d6,17(a1,d2)	;poke lower byte
	move.w  (a0)+,d6
	move.b	d6,d7
	lsr.w	#8,d6
	move.b	d6,24(a1,d3)	;poke upper bytes
	move.b	d7,d6
	move.b	d6,25(a1,d4)	;poke lower byte

	movem.w	(a3)+,d1/d2/d3/d4
	move.w  (a0)+,d6
	move.b	d6,d7
	lsr.w	#8,d6
	move.b	d6,32(a1,d1)	;poke upper bytes
	move.b	d7,d6
	move.b	d6,33(a1,d2)	;poke lower byte
	move.w  (a0)+,d6
	move.b	d6,d7
	lsr.w	#8,d6
	move.b	d6,40(a1,d3)	;poke upper bytes
	move.b	d7,d6
	move.b	d6,41(a1,d4)	;poke lower byte

	movem.w	(a3)+,d1/d2/d3/d4
	move.w  (a0)+,d6
	move.b	d6,d7
	lsr.w	#8,d6
	move.b	d6,48(a1,d1)	;poke upper bytes
	move.b	d7,d6
	move.b	d6,49(a1,d2)	;poke lower byte
	move.w  (a0)+,d6
	move.b	d6,d7
	lsr.w	#8,d6
	move.b	d6,56(a1,d3)	;poke upper bytes
	move.b	d7,d6
	move.b	d6,57(a1,d4)	;poke lower byte

	movem.w	(a3)+,d1/d2/d3/d4
	move.w  (a0)+,d6
	move.b	d6,d7
	lsr.w	#8,d6
	move.b	d6,64(a1,d1)	;poke upper bytes
	move.b	d7,d6
	move.b	d6,65(a1,d2)	;poke lower byte
	move.w  (a0)+,d6
	move.b	d6,d7
	lsr.w	#8,d6
	move.b	d6,72(a1,d3)	;poke upper bytes
	move.b	d7,d6
	move.b	d6,73(a1,d4)	;poke lower byte

	add.w   #2,a0
	move.l	a2,a1
	add.w	#160,a1
	dbf	d0,.loop
	rts


scroll_background:
	move.l	screen_base,a0
	add.w	#160*136,a0
	move.w	#62-1,d0
.loop:	roxr	(a0)
	roxr	8(a0)
	roxr	16(a0)
	roxr	24(a0)
	roxr	32(a0)
	roxr	40(a0)
	roxr	48(a0)
	roxr	56(a0)
	roxr	64(a0)
	roxr	72(a0)
	roxr	80(a0)
	roxr	88(a0)
	roxr	96(a0)
	roxr	104(a0)
	roxr	112(a0)
	roxr	120(a0)
	roxr	128(a0)
	roxr	136(a0)
	roxr	144(a0)
	move.w	152(a0),d1
	roxr	#1,d1
	move.w	d1,152(a0)
	move.w	d1,(a0)
	add.w	#160,a0
	dbf	d0,.loop
	rts

*******************
endmus:	clr.l	$4d2
	lea	$FF8800,A0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	rts
isr:	movem.l	D0-D7/A0-A6,-(sp)
	jsr	tune+$64
	movem.l	(sp)+,D0-D7/A0-A6
	rts

***********************
* SUBROUTINES SECTION *
***********************
v_sync:	movem.l	d0-d3/a0-a3,-(sp)
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d0-d3/a0-a3
	rts

tst_key:
	move.w	#11,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

get_key:
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

show_pic:
	lea	pic+34,a0
	move.l	screen_base,a1
	move.w	#32000/4-1,d0
.loop:	move.l	(a0)+,(a1)+
	dbf	d0,.loop
	rts

set_super:
	clr.l	-(sp)		;Set super stack equal
	move.w	#$20,-(sp)	; to user stack before call
	trap	#1
	addq.l	#6,sp		;correct stack
	move.l	d0,stack_save	;save old supervisor stack value
	rts
set_user:
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1		;back to user
	addq.l	#6,sp		;correct stack
	rts

get_old_palette:
	move.w	#8-1,d0
	lea	$ff8240,a0
	lea	old_palette,a1
get_old:
	move.l	(a0)+,(a1)+
	dbf	D0,get_old
	rts

set_new_palette:
	lea	pic+2,a0
	bra	set_pal
set_old_palette:
	lea	old_palette,a0
set_pal:
	lea	$ff8240,a1
	move.w	#8-1,d0
set_p:	move.l	(a0)+,(a1)+
	dbf	d0,set_p
	rts

get_screen_base:
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,screen_base
	rts

get_original_rez:
	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,original_rez
	rts

set_org_rez:
	move.w	original_rez,-(sp)
	bra.s	set_rez
set_low_rez:
	clr.w	-(sp)
	bra	set_rez
set_med_rez:
	move.w	#1,-(sp)
set_rez:
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts

****************
* DATA SECTION *
****************
stack_save:	dc.l	0
screen_base	dc.l	0
original_rez:	dc.w	0
old_palette:	ds.w	16
old484:		dc.w	0
scroll_number:	dc.w	16

new_curve:	dc.w	0	;new curve flag toggle.
screen_offset:	dc.w	160*16
last_curve:	dc.l	curve_table1
curve_tables:
	dc.l	160*42,curve_table1
	dc.l	160*48,curve_table2
	dc.l	160*46,curve_table3
	dc.l	160*46,curve_table4
	dc.l	160*48,curve_table5
	dc.l	160*48,curve_table6
	dc.l	160*51,curve_table7
	dc.l	160*35,curve_table8
	dc.l	160*60,curve_table9
	dc.l	'EEK!'

;each curve table is for 40 different positions on screen.
;An offset is in the form of a line (160 bytes).
curve_table1:
	dc.w	0,0,0,0,0,0,0,0		;flat bottom line
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
curve_table2:
	dc.w	0,0,0,0,160,320,480,640
	dc.w	800,960,800,640,480,320,160,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,160,320,480,640,800,960,800
	dc.w	640,480,320,160,0,0,0,0
curve_table3:
	dc.w	0,160,320,480,640,800,960,1120
	dc.w	960,800,640,480,320,160,0,160
	dc.w	320,480,640,800,960,1120,960,800
	dc.w	640,480,320,160,0,160,320,480
	dc.w	640,800,960,1120,960,800,640,480
curve_table4:
	dc.w	0,0,0,0,0,0,0,0
	dc.w	160,320,480,640,800,960,1120,1280
	dc.w	1440,1600,1760,1920,1760,1600,1440,1280
	dc.w	1120,960,800,640,480,320,160,0,0
	dc.w	0,0,0,0,0,0,0,0
curve_table5:
	dc.w	1120,960,800,640,480,320,160,0
	dc.w	0,0,0,0,160,320,480,800
	dc.w	960,1120,1120,1120,1120,1120,1120,960
	dc.w	800,480,320,160,0,0,0,0
	dc.w	0,160,320,480,640,800,960,1120
curve_table6:
	dc.w	0,160,320,160,0,160,320,160
	dc.w	0,160,320,160,0,160,320,160
	dc.w	0,160,320,160,0,160,320,160
	dc.w	0,160,320,160,0,160,320,160
	dc.w	0,160,320,160,0,160,320,160
curve_table7:
	dc.w	0,160,320,480,640,800,960,1120
	dc.w	1280,1440,1600,1760,1920,2080,2240,2400
	dc.w	2400,2400,2400,2400,2400,2400,2400,2400
	dc.w	2400,2240,2080,1920,1760,1600,1440,1280
	dc.w	1120,960,800,640,480,320,160,0
curve_table8:
	dc.w	480,480,480,480,480,480,480,480
	DC.W	640,800,960,1120,1280,1440,1280,1120
	DC.W	960,800,640,480,320,160,0,160
	DC.W	320,480,480,480,480,480,480,480
	DC.W	480,480,480,480,480,480,480,480
curve_table9:
	dc.w	0,160,320,480,640,800,960,1120
	DC.W	1280,1440,1600,1760,1920,2080,2240,2400
	DC.W	2560,2720,2880,3040,3200,3360,3520,3680
	DC.W	3840,4000,4160,4320,4480,4640,4800,4960
	DC.W	5120,5280,5440,5600,5760,5920,6080,6240

text_pointer:	dc.l	init_text
init_text:
 dc.b "           HELLOOOOOOOO "
 dc.b "AND WELCOME TO       "
 dc.b "ER,        WHAT IS THIS?"
 dc.b "           OH YEH, NOW I REMEMBER...."
 dc.b "          "
 dc.b "MAC SYS DATA OF PERSISTENCE OF VISION PRESENTS                     ",$7f,3

text:
 dc.b $7f,1
 dc.b "THE DEMO CLUB INTRO.                     ",$7f,2
 dc.b "THE DEMO CLUB HAS A LARGE SELECTION OF DEMOS FROM ALL THE LEADING "
 dc.b "DEMO WRITERS INCLUDING..........                     ",$7f,4
 dc.b "THE CAREBEARS                     ",$7f,2
 dc.b "THE EXCEPTIONS                     ",$7f,3
 dc.b "THE UNION                     ",$7f,4
 dc.b "THE LOST BOYS                     ",$7f,5
 dc.b "RADICAL SYSTEMS                     ",$7f,6
 dc.b "THE ST SQUAD                     ",$7f,7
 dc.b "THE POLTERGEISTS                     ",$7f,8
 dc.b "THE ALLIANCE                     ",$7f,3
 dc.b "AENIGMATICA                     ",$7f,5
 dc.b "PHALANX                     ",$7f,6
 dc.b "AND MANY, MANY MORE.                     ",$7f,9
 dc.b "THE DEMO CLUB IS ALSO THE MAIN DISTRIBUTION "
 dc.b "POINT FOR PERSISTENCE OF VISION PACKED MENU DISCS. "
 dc.b "        REMEMBER, YOU CAN'T DO BETTER THAN 'THE "
 dc.b "DEMO CLUB'.                              ",$7f,6
 dc.b "PRESS A KEY TO EXIT OR ELSE I'LL WRAPPPPP................."
 dc.b "........ HEY, IF YOU'RE STILL THERE, I'LL GIVE YOU SOME ADVICE:"
 DC.B "                     ",$7F,5
 DC.B "NEVER BELEIVE A DEDICATED AMIGA OWNER BECAUSE THEY TALK A LOAD OF "
 DC.B "BULL.      I'VE GOT A 1040STFM, A 1040STE AND A 1 MEG A500 AMIGA, I'VE HAD "
 DC.B "THE AMIGA FOR A WEEK AND A HALF AND HAVE MET SOME OF THE LAMEST "
 DC.B "AND MOST FULL OF COW DUNG PEOPLE YOU ARE EVER LIKELY TO MEET.       "
 DC.B "YOU KNOW THAT ALL AMIGA OWNERS SLAG THE ST OFF AND PROCLAIM THE "
 DC.B "AMIGA IS THE BEE'S NEES (SOUNDS LIKE AN ARCH OWNER), WELL "
 DC.B "SINCE I GOT THE AMIGA I'VE BEEN WONDERING WHY I BOTHERED.    THE MACHINE "
 DC.B "IS A GAMES/SOUND BOX, YOU CAN'T DO ANY SERIOUS PROGRAMMING BECAUSE "
 DC.B "IT CRASHES AT EVERY POSSIBLE CHANCE.     "
 DC.B "     IF YOU EVER PICK UP AN AMIGA "
 DC.B "MAGAZINE BY ACCIDENT, THEN GET AN EYEFULL OF THE DEMO NAMES.    WHAT "
 DC.B "WE CALL AN INTRO, THEY CALL A DEMO. IF A DEMO HAS MORE THAN ONE SCREEN "
 DC.B "OR PERHAPS TWO DEMOS PUT ONTO ONE DISC THEN IT'S A 'MEGA-DEMO'!    WHAT "
 DC.B "A LOAD OF WIMPS!           THE BEST AMIGA DEMOS I'VE SEEN SO FAR ARE THE "
 DC.B "'DEATHSTAR DEMO' (NEARLY UPTO ST STANDARDS THIS ONE) AND THE 'MAHONEY "
 DC.B "AND KAKTUS' MUSIC DISC 2 DEMO.   ALL THE REST ARE COPIES OF EACH OTHERS "
 DC.B "WITH VERY LITTLE CHANGED, THERE WAS MORE ORIGINALITY ON THE ZX81!       "
 DC.B "ANYWAY THAT'S ENOUGH SLAGGING OFF FOR TODAY BECAUSE I'M USING VALUABLE "
 DC.B "DISC SPACE.      BYE, BYE UNTIL NEXT TIME - M.S.D.                        "
 dc.b "                      "
 dc.b $ff,$ff

	even
tune:	incbin	"f:\democlub\demo1\thunder.img"
	even
font:	incbin	"f:\med_font.dat"
	even
pic:	incbin	"f:\democlub\demo1\demo.pi1"
	even
buffer:	dcb.b	0,42*18
