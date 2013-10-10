*************************************************************************
*				P.O.V. 73 MENU				*
*				-------------				*
*									*
* Written MAChine SYStem DATA						*
* Date: 27-4-91								*
*									*
* Use GENST 2.08 or higher to assemble					*
*									*
*************************************************************************
	SECTION TEXT
	bsr	set_super
	or.b	#$2,$ffff820a.w
	dc.w	$a00a
	move.b	#$12,$fffffc02.w
	bsr	get_screen_base
	bsr	get_old_palette
	bsr	set_new_palette
	bsr	get_original_rez
	bsr	set_up
	bsr	set_low_rez

	lea	spec_values1,a0
	move.w	#240/4-1,d0
clear_s
	move.l	#0,(a0)+
	dbf	d0,clear_s

	lea	pic+34,a0
	move.l	screen_base,a1
	move.w	#32000/4-1,d0
pic_sho	move.l	(a0),32000(a1)
	move.l	(a0)+,(a1)+
	dbf	d0,pic_sho

	move.b	$484,old484
	clr.b	$484
	move.l	#1,d0
	jsr	tune

	move.w	#$2700,sr
; Store original vector slots
	move.l	$120.w,old120
	move.l	$70.w,old70
	move.b	$fffffa09.w,old_a09
	move.b	$fffffa07.w,old_a07
	move.b	$fffffa13.w,old_a13
	and.b	#$df,$fffffa09.w
	and.b	#$fe,$fffffa07.w
	move.l	#isr120_1,$120.w
	move.l	#isr70,$70.w
	or.b	#1,$fffffa07.w
	or.b	#1,$fffffa13.w
	move.w	#$2300,sr

main_loop
	bsr	vsync
;	move.w	#$123,$ff8240
	bsr	clear_spec
	bsr	spec
	bsr	scroll
;	move.w	pic+2,$ff8240
	bsr	tst_key
	tst.l	d0
	beq.s	main_loop
	bsr	get_key

	cmp.b	#27,d0
	beq.s	exit

	cmp.b	#"0",d0
	beq.s	hertz_flip

	lea	key_codes,a0
.loop	cmp.b	#$ff,(a0)
	beq.s	main_loop
	cmp.b	(a0)+,d0
	beq.s	load
	move.b	(a0)+,d1
	bra.s	.loop

load	move.b	(a0),d0
	move.l	d0,-(sp)
	bsr	isr_off
	move.l	(sp)+,d0
	and.l	#$ff,d0
	lea	filename,a6
	mulu	#16,d0
	add.w	d0,a6
	lea	$200,a0
	movem.l	(a6),d0-d3
	movem.l	d0-d3,(a0)
	move.b	#$8,$fffffc02.w
	move.b	old484,$484
	bsr	set_old_palette
	bsr	set_user
	move.l	org_base,a0
	bsr	set_low_rez
	clr.w	-(sp)
	trap	#1

hertz_flip
	eor.b	#2,$ffff820a.w
	bra	main_loop

exit	bsr	isr_off
	move.b	#$8,$fffffc02.w
	move.b	old484,$484
	bsr	set_old_palette
	bsr	set_user
	move.l	org_base,a0
	bsr	set_low_rez
	clr.w	-(sp)
	trap	#1

*******************
* CUSTOM ROUTINES *
*******************
scroll	move.l	screen_base,a1
	lea	font_offsets,a2
	lea	font,a3
	move.l	scroll_pointer,a4
	move.l	a4,a5
	moveq	#40,d5
	move.w	char_offset,d6
	moveq	#0,d4
next_char
	move.b	(a5),d7		;get a letter
	sub.b	#32,d7		;rid of ASCII
	ext.w	d7

	moveq	#0,d0
	move.l	a3,a0
	move.b	(a2,d7),d0
	mulu	#124*4,d0	;char depth * 4 *4
	add.w	d0,a0
	move.w	d6,d0
	mulu	#124,d0		;character depth * 4 (31*4)
	add.w	d0,a0
.column
OFF	set	0
	REPT	31
	move.l	(a0)+,d0
	movep.l	d0,OFF(a1)
OFF	set	OFF+160
	ENDR

	subq.w	#1,d5
	beq.s	.finish

	add.w	#1,a1		;lower byte of word
	tst.w	d4
	beq.s	.skip		;if D4=0 then do next word
	add.w	#6,a1		;else goto next word on screen
.skip	not.w	d4
	addq.w	#1,d6		;character offset
	and.w	#3,d6
	bne	.column

	addq.w	#1,a5		;scroll pointer
	tst.b	(a5)		;is end of text?
	bpl	next_char	;NO!
	lea	scroll_text,a5	;do reset scrolline
	bra	next_char

.finish
	addq.w	#1,char_offset
	and.w	#3,char_offset
	bne.s	.end
	addq.w	#1,a4
	tst.b	(a4)
	bpl.s	.end
	lea	scroll_text,a4
.end	move.l	a4,scroll_pointer
	rts

clear_spec
	lea	spec_values1,a0
	move.l	screen_base,a1
	add.l	spec_pos1,a1
	bsr	clear_spec_area
clear_spec2
	lea	spec_values2,a0
	move.l	screen_base,a1
	add.l	spec_pos2,a1
	bsr	clear_spec_area
clear_spec3
	lea	spec_values3,a0
	move.l	screen_base,a1
	add.l	spec_pos3,a1

clear_spec_area
	move.w	#80-1,d0
.cnt_down
	move.b	(a0)+,d1
	beq.s	.next
	sub.b	#1,-1(a0)
.next	dbf	d0,.cnt_down
	move.l	a1,a0
	sub.w	#12*160,a0
	moveq	#0,d1

	move.w	#26-1,d2
.loop	move.w	d1,(a0)
	move.w	d1,8(a0)
	move.w	d1,16(a0)
	move.w	d1,24(a0)
	move.w	d1,32(a0)
	move.w	d1,40(a0)
	move.w	d1,48(a0)
	move.w	d1,56(a0)
	move.w	d1,64(a0)
	move.w	d1,72(a0)
	move.w	d1,80(a0)
	move.w	d1,88(a0)
	move.w	d1,96(a0)
	move.w	d1,104(a0)
	move.w	d1,112(a0)
	move.w	d1,120(a0)
	move.w	d1,128(a0)
	move.w	d1,136(a0)
	move.w	d1,144(a0)
	move.w	d1,152(a0)
	lea	160(a0),a0
	dbf	d2,.loop
	rts
	
************************************************

AFINE	equ	0
ACOURSE	equ	1	
BFINE	equ	2
BCOURSE	equ	3	
CFINE	equ	4
CCOURSE	equ	5	
AAMP	equ	8
BAMP	equ	9
CAMP	equ	10

spec	lea	$ffff8800.w,a1
	bsr	spec_calc_a
	bsr	spec_calc_b
	bsr	spec_calc_c
	rts

spec_calc_a
	move.b	#AAMP,(a1)
	move.b	(a1),d0
	beq.s	return_from_a
	moveq.l	#0,d0
	move.b	#ACOURSE,(a1)		;A course tune
	move.b	(a1),d0
	lsl.w	#8,d0
	move.b	#AFINE,(a1)	;A fine tune
	move.b	(a1),d0
	tst.w	d0
	bne.s	.calc
	rts
.calc	lea	spec_lookup,a3
	move.w	#80-1,d1
loopa	cmp.w	(a3),d0
	bgt.s	return_from_a
	beq.s	.yes
	addq.w	#4,a3
	dbf	d1,loopa
	rts
.yes	lea	spec_values1,a2
	move.w	2(a3),d0
	move.b	#12,(a2,d0.w)
return_from_a
	rts

******************
spec_calc_b
	move.b	#BAMP,(a1)
	move.b	(a1),d0
	beq.s	return_from_b
	moveq.l	#0,d0
	move.b	#BCOURSE,(a1)
	move.b	(a1),d0
	lsl.w	#8,d0
	move.b	#BFINE,(a1)
	move.b	(a1),d0
	tst.w	d0
	bne.s	.calc
	rts
.calc
	lea	spec_lookup,a3
	move.w	#80-1,d1
.loop	cmp.w	(a3),d0
	bgt.s	return_from_b
	beq.s	.yes
	add.w	#4,a3
	dbf	d1,.loop
	rts
.yes	lea	spec_values2,a2
	move.w	2(a3),d0
	move.b	#12,(a2,d0.w)
return_from_b
	rts

******************
spec_calc_c
	move.b	#CAMP,(a1)
	move.b	(a1),d0
	beq.s	return_from_c

	moveq.l	#0,d0
	move.b	#CCOURSE,(a1)
	move.b	(a1),d0
	lsl.w	#8,d0
	move.b	#CFINE,(a1)
	move.b	(a1),d0
	tst.w	d0
	beq.s	return_from_c

	lea	spec_lookup,a3
	move.w	#80-1,d1
.loop	cmp.w	(a3),d0
	bgt.s	return_from_c
	beq.s	.yes
	add.w	#4,a3
	dbf	d1,.loop
	rts		;not found..... so exit
.yes	lea	spec_values3,a2
	move.w	2(a3),d0
	move.b	#12,(a2,d0.w)
return_from_c


******************** print speccy *******************
ps	move.l	screen_base,a0
	add.l	spec_pos1,a0
	lea	spec_values1,a2
	bsr	spr

	move.l	screen_base,a0
	add.l	spec_pos2,a0
	lea	spec_values2,a2
	bsr	spr

	move.l	screen_base,a0
	add.l	spec_pos3,a0
	lea	spec_values3,a2

spr	move.w	#(80/4)-1,d1
.loop	move.l	a0,a1
	lea	160(a0),a3
	moveq.l	#0,d0
	move.b	(a2)+,d0
	beq.s	.nib2
	move.b	#%11100000,d2
.loop1	or.b	d2,(a1)
	or.b	d2,(a3)
	lea	-160(a1),a1
	lea	160(a3),a3
	dbf	d0,.loop1

.nib2	moveq.l	#0,d0
	move.b	(a2)+,d0
	beq.s	.nib3
	move.l	a0,a1
	lea	160(a0),a3
	move.b	#%00001110,d2
.loop2	or.b	d2,(a1)
	or.b	d2,(a3)
	lea	-160(a1),a1
	lea	160(a3),a3
	dbf	d0,.loop2

.nib3	moveq.l	#0,d0
	move.b	(a2)+,d0
	beq.s	.nib4
	move.l	a0,a1
	lea	160(a0),a3
	move.b	#%11100000,d2
.loop3	or.b	d2,1(a1)
	or.b	d2,1(a3)
	lea	-160(a1),a1
	lea	160(a3),a3
	dbf	d0,.loop3
.nib4	moveq.l	#0,d0
	move.b	(a2)+,d0
	beq.s	.nonib
	move.l	a0,a1
	lea	160(a0),a3
	move.b	#%00001110,d2
.loop4	or.b	d2,1(a1)
	or.b	d2,1(a3)
	lea	-160(a1),a1
	lea	160(a3),a3
	dbf	d0,.loop4
.nonib	addq.w	#8,a0
	dbf	d1,.loop
	rts

***********************
* SUBROUTINES SECTION *
***********************
v_sync	movem.l	d0-d3/a0-a3,-(sp)
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d0-d3/a0-a3
	rts

set_up	move.l	#screens,d0
	clr.b	d0
	move.l	d0,scr_now
	move.l	d0,screen_base
	move.l	d0,d1
	add.l	#32000,d1
	eor.l	d0,d1
	move.l	d1,scr_xor
	rts

set_screen
	move.l	scr_now,d0
	move.l	scr_xor,d1
	eor.l	d1,d0
	move.l	d0,scr_now
	move.l	d0,screen_base
	lsr.l	#8,d0
	lea	$ffff8201.w,a0
	movep.w	d0,(a0)
	rts

tst_key	move.w	#11,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

get_key	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
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
	lea	$ffff8240.w,a0
	lea	old_palette,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts

set_new_palette:
	lea	pic+2,a0
	bra	set_pal
set_old_palette:
	lea	old_palette,a0
set_pal	lea	$ffff8240.w,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts

get_screen_base
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,org_base
	rts

get_original_rez
	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,original_rez
	rts

set_low_rez
	clr.w	-(sp)
	bra	set_rez
set_med_rez:
	move.w	#1,-(sp)
set_rez:
	move.l	org_base,-(sp)
	move.l	(sp),-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts

RASTER_COLOUR=$ffff8242
isr120_1
	move.b	#0,$fffffa1b.w
	move.l	a0,-(sp)	;$120
	move.l	isr_data,a0
	move.w	(a0)+,RASTER_COLOUR.w
	move.l	a0,isr_data
	move.l	(sp)+,a0
	cmp.w	#26,isr120_counter
	beq.s	.set
	add.w	#1,isr120_counter
	move.b	#1,$fffffa21.w		;1 line of each colour.....
	move.b	#8,$fffffa1b.w
	bclr	#0,$fffffa0f.w
	rte
.set	clr.w	isr120_counter
	clr.w	RASTER_COLOUR.w
	move.l	#isr120_2,$120.w
	move.b	#34,$fffffa21.w		;34 lines of each colour.....
	move.b	#8,$fffffa1b.w
	bclr	#0,$fffffa0f.w
	rte

isr120_2
	move.b	#0,$fffffa1b.w
	move.l	a0,-(sp)	;$120
	move.l	isr_data,a0
	move.w	(a0)+,RASTER_COLOUR.w
	move.l	a0,isr_data
	move.l	(sp)+,a0
	cmp.w	#26,isr120_counter
	beq.s	.set
	add.w	#1,isr120_counter
	move.b	#1,$fffffa21.w		;1 line of each colour.....
	move.b	#8,$fffffa1b.w
	bclr	#0,$fffffa0f.w
	rte
.set	clr.w	isr120_counter
	clr.w	RASTER_COLOUR.w
	move.l	#isr120_3,$120.w
	move.b	#34,$fffffa21.w		;34 lines of each colour.....
	move.b	#8,$fffffa1b.w
	bclr	#0,$fffffa0f.w
	rte

isr120_3
	move.b	#0,$fffffa1b.w
	move.l	a0,-(sp)	;$120
	move.l	isr_data,a0
	move.w	(a0)+,RASTER_COLOUR.w
	move.l	a0,isr_data
	move.l	(sp)+,a0
	cmp.w	#26,isr120_counter
	beq.s	.set
	add.w	#1,isr120_counter
	move.b	#1,$fffffa21.w		;1 line of each colour.....
	move.b	#8,$fffffa1b.w
	bclr	#0,$fffffa0f.w
	rte
.set	move.w	pic+4,RASTER_COLOUR.w
	move.b	#40,$fffffa21.w
	move.b	#8,$fffffa1b.w
	bclr	#0,$fffffa0f.w
	rte
	
isr70	move.l	#b_line,isr_data
	movem.l	d0-a6,-(sp)
	jsr	tune+8
	movem.l	(sp)+,d0-a6
	move.l	#isr120_1,$120.w
	clr.w	vsync_flag
	clr.w	isr120_counter
	move.b	#0,$fffffa1b.w	;timer B
	move.b	#36,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte

vsync	move.w	#-1,vsync_flag
.vsyn	tst.w	vsync_flag
	bne.s	.vsyn
	bsr	set_screen
	rts

isr_off	move.w	#$2700,sr
	move.l	old70,$70.w
	and.b	#$df,$fffffa09.w
	and.b	#$fe,$fffffa07.w
	move.l	old120,$120.w
	move.b	old_a07,$fffffa07.w
	move.b	old_a09,$fffffa09.w
	move.b	old_a13,$fffffa13.w
	moveq	#0,d0
	bsr	tune
	move.w	#$2300,sr
	rts

****************
* DATA SECTION *
****************
	SECTION DATA
pic	incbin	pov73.pi1
tune	incbin	cuddly2.mus
spec_lookup
	dc.w	$e17,0
	dc.w	$967,1
	dc.w	$777,2
	dc.w	$64f,3
	dc.w	$647,4
	dc.w	$63f,5
	dc.w	$637,6
	dc.w	$59f,7
	dc.w	$597,8
	dc.w	$58f,9
	dc.w	$587,10
	dc.w	$4fb,11
	dc.w	$4f3,12
	dc.w	$470,13
	dc.w	$430,14
	dc.w	$428,15
	dc.w	$3f4,16
	dc.w	$3bf,17
	dc.w	$3bb,18
	dc.w	$3b7,19
	dc.w	$3b3,20
	dc.w	$2a3,21
	dc.w	$259,22
	dc.w	$1dd,23
	dc.w	$13e,24
	dc.w	$11c,25
	dc.w	$10c,26
	dc.w	$0ef,27
	dc.w	$0ee,28
	dc.w	$0ed,29
	dc.w	$0d4,30
	dc.w	$0d3,31
	dc.w	$0cc,32
	dc.w	$0ca,33
	dc.w	$0c9,34
	dc.w	$0c8,35
	dc.w	$0c7,36
	dc.w	$0c6,37
	dc.w	$0c4,38
	dc.w	$0b4,39
	dc.w	$0b2,40
	dc.w	$0b0,41
	dc.w	$0ae,42
	dc.w	$0a7,43
	dc.w	$09f,44
	dc.w	$09e,45
	dc.w	$096,46
	dc.w	$086,47
	dc.w	$085,48
	dc.w	$07b,49
	dc.w	$079,50
	dc.w	$078,51
	dc.w	$077,52
	dc.w	$076,53
	dc.w	$075,54
	dc.w	$073,55
	dc.w	$06a,56
	dc.w	$069,57
	dc.w	$066,58
	dc.w	$065,59
	dc.w	$064,60
	dc.w	$063,61
	dc.w	$062,62
	dc.w	$060,63
	dc.w	$059,64
	dc.w	$054,65
	dc.w	$053,66
	dc.w	$051,67
	dc.w	$04f,68
	dc.w	$04e,69
	dc.w	$04d,70
	dc.w	$04b,71
	dc.w	$043,72
	dc.w	$042,73
	dc.w	$03c,74
	dc.w	$03b,75
	dc.w	$03a,76
	dc.w	$033,77
	dc.w	$032,78
	dc.w	$031,79

spec_pos1	dc.l	160*48
spec_pos2	dc.l	160*(60+48)
spec_pos3	dc.l	160*(60+48+60)

isr_data	dc.l	b_line
b_line
 dc.w	$010,$090,$020,$0a0,$030,$0b0,$040,$0c0
 dc.w	$050,$0d0,$060,$0e0,$070,$0f0,$8f0,$1f0
 dc.w	$9f0,$2f0,$af0,$3f0,$bf0,$4f0,$cf0,$5f0
 dc.w	$df0,$6f0,$ef0

 dc.w	$7f0,$ff0,$f70,$fe0,$f60,$fd0,$f50,$fc0
 dc.w	$f40,$fb0,$f30,$fa0,$f20,$f90,$f10,$f80
 dc.w	$f00,$708,$e01,$609,$d02,$50a,$c03,$40b
 dc.w	$b04,$30c,$a05

 dc.w	$20d,$906,$10e,$807,$00f,$08f,$01f,$09f
 dc.w	$02f,$0af,$03f,$0bf,$04f,$0cf,$05f,$0df
 dc.w	$06f,$0ef,$07f,$0ff,$877,$1ee,$966,$2dd
 dc.w	$a55,$3cc,$b44
	even

scroll_pointer	dc.l	scroll_text+7
scroll_text
 dc.b "                    PERSISTENCE OF VISION PACKED DEMO DISC 73.    "
 dc.b "ALL CODE AND GRAFIX BY MAC SYS DATA, "
 dc.b "THE MUSIC IS BY MAD MAX AND COMES FROM THE CUDDLY DEMO. "
 dc.b "      HAVE YOU SEEN THE ADVERT FOR A FRIDGE THAT "
 DC.B "GOES ON AND ON AND ON AND ON AND ON AND ON AND....... "
 DC.B "WELL THE TUNE IS FROM THE GAME ROBOCOP ON THE ST.       "
 DC.B "TODAYS DATE IS 26-5-91 AND MY CABLE TO UPGRADE MY HARD DISC "
 DC.B "ARRIVED 1 MONTH AGO BUT MY NEW 65 MEG MECHANISM DIDN'T.  "
 DC.B "   I PHONED THE COMPANY 4 TIMES AND THEY ALWAYS SAY THAT "
 DC.B "THEY SENT IT OFF LAST WEEK SO THREE DAYS AGO I WENT TO THE "
 DC.B "PLACE AND DEMANDED A MECHANISM. AFTER SEVERAL MINUTES THE "
 DC.B "MANAGER CAME OUT AND ADMITTED THEY HADN'T EVEN ORDERED ONE FOR "
 dc.b "ME BUT WOULD DO SO IMMEDIATELY AND THAT I COULD HAVE IT IN 3 DAYS "
 DC.B "TIME.    THAT'S OK BUT IN THREE DAYS TIME I GO TO THE ISLE "
 DC.B "OF MAN FOR THE TT RACES SO I WON'T BE HERE TO INSTALL IT.     "
 DC.B "WHEN I BOUGHT MY HARD DISC I HAD HASSLE ABOUT THEM "
 DC.B "NOT DELIVERING IT ON TIME BUT I THOUGHT THAT WAS A FLASH IN "
 DC.B "THE PAN BUT IT SEEMS OTHER PEOPLE HAVE HAD PROBLEMS "
 DC.B "WITH THE COMPANY.  PLEASE TAKE NOTE -- IF YOU EVER BUY "
 DC.B "A HARD DISC DO NOT GET IT FROM THIRD COAST 'CAUSE THEY "
 DC.B "ARE A BUNCH OF LAMERS AND IF I DON'T GET MY HARD DISC "
 DC.B "ON TIME I'M GOING TO TAKE THEM TO COURT, ONCE I'VE GOT "
 DC.B "MY MONEY BACK I'LL FIRE BOMB THE PLACE.......         "
 dc.b "WELL DISC SPACE IS VERY TIGHT, THERE IS NO ROOM FOR THE "
 DC.B "COPIER SO YOU BETTER GET FAST COPY 3 OUT TO COPY THIS MENU. "
 DC.B "     OK, THAT'S ALL UNTIL NEXT TIME....."
 DC.B "                                     "
 dc.b $ff
	even
font	dcb.b	124*4,0
	incbin	font.fnt
font_offsets
;          !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
 dc.b	0,09,01,00,00,00,00,05,06,07,45,00,26,11,12,00

;        0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @
 dc.b	14,15,16,17,18,19,20,21,22,23,24,25,00,00,00,29,00

;        A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q
 dc.b	31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47

;        R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  `  a  b  c
 dc.b	48,49,50,51,52,53,54,55,56,40,00,41,00,47,00,48,49,50

;        d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u
 dc.b	00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
	even

key_codes
	dc.b	"1",0	;key 1
	dc.b	"2",1
;	dc.b	4,2
;	dc.b	5,3	;key 4

	dc.b	"1",0	;keypad 1
	dc.b	"2",1
;	dc.b	$6f,2
;	dc.b	$6a,3	;keypad 4
	dc.b	$ff
	even

filename
	dc.b	"PREDATOR.HAC",0,0,0,0
	dc.b	"PREDATOR.HAM",0,0,0,0

	SECTION BSS
spec_values1	ds.b	80
spec_values2	ds.b	80
spec_values3	ds.b	80
char_offset	ds.w	1
stack_save:	ds.l	1
org_base	ds.l	1
original_rez	ds.w	1
old_palette	ds.w	16
vsync_flag	ds.w	1
isr120_counter	ds.w	1
old120		ds.l	1
old70		ds.l	1
old_a09		ds.b	1
old_a07		ds.b	1
old_a13		ds.b	1
old484		ds.b	1
	even
screen_base	ds.l	1
scr_now	ds.l	1
scr_xor	ds.l	1
	ds.b	256
screens	ds.b	32000*2