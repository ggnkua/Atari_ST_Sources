***** INFO 40 ******
	bra	skip
 dc.b	"GO AWAY NOSEY!!!    IF YOU WANT TO CONTACT ME "
 DC.B	"THEN WRITE TO...   MARK,   16 CARR LANE,   "
 DC.B	"HAMBLETON,   BLACKPOOL,   FY6 9AZ.        "
skip	bsr	set_super
	dc.w	$a00a
	move.b	#$12,$fffffc02.w
	bsr	get_screen_base
	bsr	get_old_palette
	bsr	set_new_palette
	bsr	get_original_rez
	bsr	set_low_rez
	move.w	pic+4,d0
	move.w	d0,end_pal
	move.w	d0,end_pal+2
	move.w	d0,end_pal+4
	move.w	d0,end_pal+6
	bsr	show_pic
	move.l	screen_base,a0
	add.w	#26*160,a0
	move.l	a0,spec_pos
;************************************************************************
;*                            CRISPY3                                   *
;*                            -------                                   *
;* Stolen by: MAC SYS DATA of P.O.V. 14/10/90 19:30                     *
;*      From: AUTOMATION disc 121                                       *
;* Include files:-                                                      *
;*                 121.IMG into TUNE                                    *
;************************************************************************
;* Written By CRISPY NOODLE
	move.b	$484,old484
	and.b	#%11111100,$484.w		;off with keyclick/bell

;****************************************************************
; There is only one tune...
	jsr	tune

	bsr	init_isr
	bsr	sort_disc_text
	bsr	scroll
	move.w	#$ffff,disc_enable
main_loop:
	bsr	vsync
;	move.w	#$123,$ffff8240.w
	bsr	spec
	bsr	clear_old
	bsr	scroll
	bsr	cycle
	bsr	print_disc
	bsr	print_disc
	bsr	clear_spec
;	move.w	pic+2,$ffff8240.w

	move.b	$fffffc02.w,d0	;is a key pressed?
	btst	#7,d0
	bne.s	main_loop	;NO!!!!!!!!

	cmp.b	#$01,d0
	beq.s	shut_down

	tst.w	disc_enable
	bne.s	main_loop	;to prevent update overlap

	cmp.b	#$48,d0		;cursor up
	beq	dec_thru_list

	cmp.b	#$50,d0		;cursor down
	beq	inc_thru_list

	bra.s	main_loop

shut_down
	bsr	isr_off
	bsr	endmus

	bsr	set_old_palette
	bsr	set_med_rez
	move.b	#8,$fffffc02.w
	dc.w	$a009
	bsr	set_user

	clr.w	-(sp)
	move.w	#$4c,-(sp)
	trap	#1

*******************
* CUSTOM ROUTINES *
*******************
clear_spec
	lea	spec_values,a0
	move.w	#10-1,d0
.cnt_down
	move.b	(a0)+,d1
	beq.s	.next
	sub.b	#1,-1(a0)
.next	move.b	(a0)+,d1
	beq.s	.next2
	sub.b	#1,-1(a0)
.next2	move.b	(a0)+,d1
	beq.s	.next3
	sub.b	#1,-1(a0)
.next3	move.b	(a0)+,d1
	beq.s	.next4
	sub.b	#1,-1(a0)
.next4	move.b	(a0)+,d1
	beq.s	.next5
	sub.b	#1,-1(a0)
.next5	move.b	(a0)+,d1
	beq.s	.next6
	sub.b	#1,-1(a0)
.next6	move.b	(a0)+,d1
	beq.s	.next7
	sub.b	#1,-1(a0)
.next7	move.b	(a0)+,d1
	beq.s	.next8
	sub.b	#1,-1(a0)
.next8	dbf	d0,.cnt_down

	move.l	spec_pos,a0
	sub.w	#24*160,a0
	moveq	#0,d1
	REPT	25
	move.w	d1,(a0)
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
	ENDR
	rts
	
************************************************

AFINE	equ	0
ACOURSE	equ	1	
BFINE	equ	2
BCOURSE	equ	3	
CFINE	equ	4
CCOURSE	equ	5	

COURCE_SHIFT	equ	3
FINE_SHIFT	equ	5

spec	lea	$ffff8800.w,a1

	move.b	#8,(a1)
	move.b	(a1),d0
	beq.s	do_b
	move.b	#ACOURSE,(a1)		;A course tune
	move.b	(a1),d0
	and.w	#$ff,d0
	lsl.w	#COURCE_SHIFT,d0
	lea	spec_values,a2
	move.w	d0,d1

	move.b	#AFINE,(a1)	;A fine tune
	move.b	(a1),d0
	and.w	#$ff,d0
	lsr.w	#FINE_SHIFT,d0
	add.w	d0,d1
	add.w	d1,a2
	move.b	#24,(a2)


******************
do_b
	move.b	#9,(a1)
	move.b	(a1),d0
	beq.s	do_c

	move.b	#BCOURSE,(a1)		;B course tune
	move.b	(a1),d0
	and.w	#$ff,d0
	lsl.w	#COURCE_SHIFT,d0
	lea	spec_values,a2
	move.w	d0,d1

	move.b	#BFINE,(a1)		;B fine tune
	move.b	(a1),d0
	and.w	#$ff,d0
	lsr.w	#FINE_SHIFT,d0
	add.w	d0,d1
	add.w	d1,a2
	move.b	#24,(a2)

******************
do_c
	move.b	#$a,(a1)
	move.b	(a1),d0
	beq.s	ps

	move.b	#CCOURSE,(a1)		;C course tune
	move.b	(a1),d0
	and.w	#$ff,d0
	lsl.w	#COURCE_SHIFT,d0
	lea	spec_values,a2
	move.w	d0,d1

	move.b	#CFINE,(a1)		;C fine tune
	move.b	(a1),d0
	and.w	#$ff,d0
	lsr.w	#FINE_SHIFT,d0
	add.w	d0,d1
	add.w	d1,a2
	move.b	#24,(a2)


******************** print speccy *******************
ps	move.l	spec_pos,a0
	lea	spec_values,a2
	move.b	#20-1,d1
.loop	move.l	a0,a1

	move.b	(a2)+,d0
	beq.s	.nib2
	and.w	#$ff,d0
.loop1	move.b	#%01110000,(a1)
	lea	-160(a1),a1
	dbf	d0,.loop1

.nib2	move.b	(a2)+,d0
	beq.s	.nib3
	and.w	#$ff,d0
	move.l	a0,a1
.loop2	or.b	#%00000111,(a1)
	lea	-160(a1),a1
	dbf	d0,.loop2

.nib3	move.b	(a2)+,d0
	beq.s	.nib4
	and.w	#$ff,d0
	move.l	a0,a1
.loop3	or.b	#%01110000,1(a1)
	lea	-160(a1),a1
	dbf	d0,.loop3

.nib4	move.b	(a2)+,d0
	beq.s	.nonib
	and.w	#$ff,d0
	move.l	a0,a1
.loop4	or.b	#%00000111,1(a1)
	lea	-160(a1),a1
	dbf	d0,.loop4
.nonib
	add.w	#8,a0
	dbf	d1,.loop
	rts

dec_thru_list
	tst.w	disc_number
	bne.s	.do_dec
	bra	main_loop
.do_dec
	subq.w	#1,disc_number
	moveq	#0,d0
	move.w	disc_number,d0
	lsl.w	#2,d0
	lea	disc_start_table,a0
	add.w	d0,a0
	move.l	(a0),disc_text_pos
	move.w	#$ffff,disc_enable
	move.w	#$ffff,is_clear
	bra	main_loop

inc_thru_list
	cmp.w	#39,disc_number
	bne.s	.do_inc
	bra	main_loop
.do_inc
	addq.w	#1,disc_number
	moveq	#0,d0
	move.w	disc_number,d0
	lsl.w	#2,d0
	lea	disc_start_table,a0
	add.w	d0,a0
	move.l	(a0),disc_text_pos
	move.w	#$ffff,disc_enable
	move.w	#$ffff,is_clear
	bra	main_loop

print_disc
	tst.w	disc_enable
	bne.s	.do_stuff
	rts
.do_stuff
	tst.w	is_clear
	beq.s	.do_rout
	bra	do_clear
.do_rout
	move.l	disc_text_pos,a1
	move.l	screen_base,a0
	add.w	#(8*15)*160,a0
.restart
	moveq	#0,d1
	lea	minifont,a2
	move.b	(a1)+,d1
	move.l	a1,disc_text_pos
	cmp.b	#"^",d1		;termintor
	bne.s	.do_text
	clr.w	disc_enable
	clr.b	xpos
	clr.w	ypos
	clr.w	byte_offset
	rts
.do_text
	cmp.b	#13,d1
	bne.s	.notcr
	clr.b	xpos
	clr.w	byte_offset
	bra.s	.restart
.notcr	cmp.b	#10,d1
	bne.s	.notlf
	addq.b	#1,ypos
	bra.s	.restart
.notlf	sub.w	#32,d1
	lsl.w	#3,d1
	add.w	d1,a2

	move.b	ypos,d0
	and.b	#$ff,d0
	mulu	#160*8,d0
	add.w	d0,a0

	move.b	xpos,d0
	and.w	#$ff,d0
	lsr.w	#1,d0	;\2
	lsl.w	#3,d0	;*8
	add.w	d0,a0

	add.w	byte_offset,a0
	add.w	tab_offset,a0

	move.b	(a2)+,(a0)
	move.b	(a2)+,160(a0)
	move.b	(a2)+,320(a0)
	move.b	(a2)+,480(a0)
	move.b	(a2)+,640(a0)
	move.b	(a2)+,800(a0)
	move.b	(a2)+,960(a0)
	move.b	(a2)+,1120(a0)
	addq.b	#1,xpos
	eor.w	#1,byte_offset
	rts

do_clear
	tst.w	lines_to_clear
	bne.s	.not_all_done
	clr.w	is_clear
	move.w	#10,lines_to_clear
	move.l	screen_base,a0
	add.w	#(8*15)*160,a0
	move.l	a0,line_add
	rts
.not_all_done
	move.l	line_add,a0
	moveq	#0,d0
	move.w	#9,d1
.loop
OFF	set 0
	REPT 20
	move.w	d0,OFF(a0)
OFF	set	OFF+8
	ENDR
	add.w	#8*160,a0
	dbf	d1,.loop

	subq.w	#1,lines_to_clear
	add.l	#160,line_add
	rts

scroll:	move.l	sine_position,a1
	cmp.b	#$ff,(a1)
	bne.s	.no_reset
	lea	sine_table,a1
	move.l	a1,sine_position
.no_reset
	moveq	#0,d0
	move.b	(a1)+,d0
	move.l	a1,sine_position

	move.l	d0,d1
	lsl.l	#7,d1
	lsl.w	#5,d0
	add.l	d1,d0
;	mulu	#160,d0
	move.l	screen_base,a1
	add.w	d0,a1
	move.l	a1,old_scroll_pos

	lea	font_offsets,a2
	lea	font,a3
	move.l	scroll_pointer,a4
	move.l	a4,a5

	moveq	#0,d4
	moveq	#40,d5
	move.w	char_offset,d6
next_char
	move.b	(a5),d7		;get a letter
	sub.b	#32,d7		;rid of ASCII
	ext.w	d7

	moveq	#0,d0
	move.l	a3,a0
	move.b	(a2,d7),d0
	mulu	#120,d0
	add.w	d0,a0
	move.w	d6,d0
	mulu	#30,d0
	add.w	d0,a0

.column
OFF	set	0
	REPT	30
	move.b	(a0)+,OFF(a1)
OFF	set	OFF+160
	ENDR

	subq.w	#1,d5
	beq.s	.finish

	addq.w	#1,a1
	tst.w	d4
	beq.s	.skip
	addq.w	#6,a1
.skip	not.w	d4
	addq.w	#1,d6
	and.w	#3,d6
	bne	.column

	addq.w	#1,a5
	tst.b	(a5)
	bpl	next_char
	lea	scroll_text,a5
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

clear_old
	move.l	old_scroll_pos,a0
	moveq	#0,d0
	REPT	30
	move.w	d0,(a0)
	move.w	d0,8(a0)
	move.w	d0,16(a0)
	move.w	d0,24(a0)
	move.w	d0,32(a0)
	move.w	d0,40(a0)
	move.w	d0,48(a0)
	move.w	d0,56(a0)
	move.w	d0,64(a0)
	move.w	d0,72(a0)
	move.w	d0,80(a0)
	move.w	d0,88(a0)
	move.w	d0,96(a0)
	move.w	d0,104(a0)
	move.w	d0,112(a0)
	move.w	d0,120(a0)
	move.w	d0,128(a0)
	move.w	d0,136(a0)
	move.w	d0,144(a0)
	move.w	d0,152(a0)
	lea	160(a0),a0
	ENDR
	rts

cycle	move.l	colours_pos,a0
	cmp.w	#$ffff,(a0)
	bne.s	.no_reset
	lea	colours,a0
	move.l	a0,colours_pos
.no_reset
	move.w	(a0)+,col3
	move.w	(a0)+,col7
	move.w	(a0)+,col11
	move.w	(a0)+,col15
	move.l	a0,colours_pos
	rts

***********************
* SUBROUTINES SECTION *
***********************
v_sync:	movem.l	d0-d3/a0-a3,-(sp)	;system sync
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
	movem.l	$ffff8240.w,d0-d7
	lea	old_palette,a1
	movem.l	d0-d7,(a1)
	rts

set_new_palette:
	lea	pic+2,a0
	bra.s	set_pal
set_old_palette:
	lea	old_palette,a0
set_pal:
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240.w
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

set_low_rez:
	clr.w	-(sp)
	bra.s	set_rez
set_med_rez:
	move.w	#1,-(sp)
set_rez:
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts

endmus:	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	rts

show_pic
	move.l	screen_base,a1
	lea	pic+34,a0
	move.w	#32000/4-1,d0
.loop	move.l	(a0)+,(a1)+
	dbf	d0,.loop
	rts


sort_disc_text
	lea	disc_text,a0
	lea	disc_start_table,a1
	move.l	a0,(a1)+
.loop	cmp.b	#$ff,(a0)
	beq.s	.quit
	move.b	(a0)+,d0
	cmp.b	#'^',d0
	bne.s	.loop
	move.b	(a0)+,d0	;cr
	move.b	(a0)+,d0	;lf
	move.l	a0,(a1)+
	bra.s	.loop
.quit	rts

********************************* isr bits *****************
init_isr
	move.w	#$2700,sr
	move.l	$120.w,old120
	move.l	$70.w,old70
	move.l	$118.w,old118
	move.l	$118.w,key_frig+2
	move.b	$fffffa09.w,a09
	move.b	$fffffa07.w,a07
	move.b	$fffffa13.w,a13
	and.b	#$df,$fffffa09.w
	and.b	#$fe,$fffffa07.w
	move.l	#isr_keys,$118.w
	move.l	#isr1,$120.w
	move.l	#isr2,$70.w
	or.b	#1,$fffffa07.w
	or.b	#1,$fffffa13.w
	move.w	#$2300,sr
	rts

isr_keys
	move.w	#$2500,sr
key_frig
	jmp	0

isr1:	move.b	#0,$fffffa1b.w	;$120
	move.l	a0,-(sp)
	move.l	isr_data,a0
	move.w	(a0)+,$ffff8242.w
	move.l	a0,isr_data
	move.l	(sp)+,a0
	move.l	#isr1_2,$120.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	bclr	#0,$fffffa0f.w
	rte

isr1_2:
	move.b	#0,$fffffa1b.w	;$120
	addq.w	#1,isr120_count
	cmp.w	#63,isr120_count
	bge.s	set_exi120

	move.l	a0,-(sp)
	move.l	isr_data,a0
	move.w	(a0)+,$ffff8242.w
	move.l	a0,isr_data
	move.l	(sp)+,a0

	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	bclr	#0,$fffffa0f.w
	rte

set_exi120
	move.l	a0,-(sp)
	move.l	isr_data,a0
	move.w	(a0),$ffff8242.w
	move.w	2(a0),$ffff8246.w
	add.l	#2,isr_data
	move.l	(sp)+,a0
	move.l	#exi120,$120

	move.b	#2,$fffffa21.w
	move.b	#8,$fffffa1b.w
	bclr	#0,$fffffa0f.w
	rte

exi120	move.b	#0,$fffffa1b.w	;$120
	move.l	a0,-(sp)
	move.l	isr_data,a0
	move.w	(a0),$ffff8242.w
	move.w	2(a0),$ffff8246.w
	move.w	2(a0),$ffff824e.w
	move.w	2(a0),$ffff8256.w
	move.w	2(a0),$ffff825e.w
	add.l	#2,isr_data
	move.l	(sp)+,a0
	move.w	col3,$ffff8244.w
	move.w	col7,$ffff824c.w
	move.w	col11,$ffff8254.w
	move.w	col15,$ffff825c.w

	move.b	#2,$fffffa21.w
	move.b	#8,$fffffa1b.w
	bclr	#0,$fffffa0f.w
	rte

isr120_count
	dc.w	0

isr2:	;$70
	move.b	#0,$fffffa1b.w	;timer B
	move.l	#msd_pal,isr_data
	movem.l	d0-d7,-(sp)
	movem.l	pic+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	movem.l	(sp)+,d0-d7

	clr.w	vsync_flag
	clr.w	isr120_count
	jsr	tune+$a8
	move.l	#isr1,$120.w
	move.b	#50,$fffffa21.w
	move.b	#8,$fffffa1b.w
	bclr	#0,$fffffa0f.w
	rte


vsync:	move.w	#-1,vsync_flag
vsyn:	tst.w	vsync_flag
	bne.s	vsyn
	rts

isr_off:
	move.w	#$2700,sr
	move.l	old70,$70.w
	and.b	#$df,$fffffa09.w
	and.b	#$fe,$fffffa07.w
	move.l	old120,$120.w
	move.l	old118,$118.w
	move.b	a07,$fffffa07.w
	move.b	a09,$fffffa09.w
	move.b	a13,$fffffa13.w
	move.w	#$2300,sr
	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	move.b	old484,$484
	rts

****************
* DATA SECTION *
****************
	SECTION DATA
key		dc.w	0
stack_save:	dc.l	0
screen_base	dc.l	0
original_rez:	dc.w	0
old_palette:	ds.w	16

******************************* scroller info ***********
old_scroll_pos	dc.w	0
scroll_number:	dc.w	0
scroll_buffer:	ds.b	44*35+4*35
scroll_pointer:	dc.l	scroll_text+7
scroll_text:
 dc.b "                     "
 dc.b "............. PERSISTENCE OF VISION INFO 40.    "
 DC.B "ALL CODING, ART AND MUSIC RIPPING BY MAC SYS DATA.    "
 DC.B "  HIDDEN SCREEN CODED BY MAC SYS DATA WITH SCROLL CODE "
 DC.B "BY BORIS.        "
 dc.b "INSTRUCTIONS:   USE THE CURSOR KEYS TO VIEW THE DETAILS "
 DC.B "OF EACH DISC.           - IMPORTATANT -   TO AID THE DISTRIBUTION "
 DC.B "OF P.O.V. DISCS WE CAN NOW RELEASE A CONTACT ADDRESS.  THE "
 DC.B "ADDRESS IS OF AN EX-MEMBER OF P.O.V. WHO HAS RE-JOINED "
 DC.B "OUR CREW FOR THE SOLE PURPOSE OF DISTRIBUTION AND SWAPPING. "
 DC.B "     ARE YOU READY?       HAVE YOU GOT A PEN AND PAPER?       "
 DC.B "RIGHT HERE IT IS, WRITE TO;-          DR.SYNE,       "
 DC.B "BLACKPOOL,       LANCS.,       "
 DC.B "UK.   ..... SORRY BUT I HAD TO DELETE THE ADDRESS AT THE LAST "
 DC.B "MINUTE AS WE ARE PRESENTLY ENQUIRING ABOUT A P.O. BOX AND F.A.S.T. "
 DC.B "HAVE JUST BUSTED SEVERAL OF OUR SUPPLIERS WHO PASS GAMES "
 DC.B "TO OUR AREA, WE IN TURN PASS THEM OUT THEN DELETE OUR COPIES AS WE "
 DC.B "ARE ONLY INTERESTED IN DEMOS AND NOT PIRATED SOFTWARE - OK.     "
 DC.B "WHEN WE GET OUR P.O. BOX WE WILL FOLLOW STRICK RULES, THEY ARE "
 DC.B "AS FOLLOWS....     WE WILL ONLY RETURN DISCS AND NOT SUPPLY THEM SO "
 DC.B "DON'T FORGET TO INCLUDE "
 DC.B "YOUR OWN DISCS AND POSTAGE (EITHER IN POSTAL STAMPS OR "
 DC.B "POSTAL ORDERS/INTERNATIONAL REPLY COUPONS).   IF YOU JUST "
 DC.B "WISH TO CONTACT A CERTAIN MEMBER OF P.O.V. THEN WRITE TO THE SAME "
 DC.B "ADDRESS BUT WRITE THE MEMBERS NAME ON THE FRONT OF THE ENVELOPE. "
 DC.B "     DR.SYNE WILL NOT WRITE BACK TO PEOPLE WHO SAY 'PLEASE SEND "
 DC.B "ALL YOUR DISCS' OR 'PLEASE SEND YOUR LATEST DISCS'.  IF YOU "
 DC.B "WANT MORE THAN JUST A COUPLE THEN IT WOULD BE WISE TO ARRANGE "
 dc.b "IT WITH DR. SYNE FIRST. THE SECOND POINT OF 'SEND YOUR LATEST' IS "
 dc.b "RATHER AMBIGUOUS AS WE HAVE NO IDEA WHAT THE LAST DISC YOU RECEIVED "
 DC.B "WAS, SO PLEASE SPECIFY THE DISC NUMBER.     "
 DC.B "OK?     HAVE YOU GOT IT?     YES?     "
 DC.B "WELL READ THE NEXT BIT...  WE WILL   N O T  REPLY TO "
 DC.B "PEOPLE WHO ARE INTERESTED IN JUST SWAPPING CRACKED SOFTWARE. "
 DC.B "     THE MAIN REASON FOR THE ADDRESS IS TO AID DISTRIBUTION "
 DC.B "AND FOR OTHER PEOPLE TO SEND THEIR DEMOS TO US FOR PACKING.       "
 DC.B "   RIGHT I'M GLAD I PUT THAT BIT IN 'COS WE MIGHT GET "
 DC.B "LOADS OF DEMOS TO PACK!     AND NOW FOR A PLEA.... RECENTLY "
 DC.B "I HAVE RECEIVED A LARGE AMOUNT OF DISCS WITH THE GHOST VIRUS "
 DC.B "ON, WILL YOU ALL PLEASE CHECK YOUR DISCS BEFORE SENDING THEM "
 DC.B "OFF TO OTHER PEOPLE, IT'S OKAY IF YOU KILL YOUR OWN SOFTWARE "
 DC.B "BUT OTHER PEOPLE MAY HAVE HARD DISCS CONTAINING 40 MEG OF "
 DC.B "SOFTWARE OR MORE. WHENEVER I RECEIVE DISCS I USUALLY PUT THEM "
 DC.B "THROUGH AVK 3.9 BUT THERE ARE ALWAYS A COUPLE THAT GET THROUGH "
 DC.B "AND OVER THE LAST WEEK I FOUND 2 GHOST VIRUS INFECTED DISCS "
 DC.B "FLOATING AROUND MY DESK LOOKING FOR A HOME, ANYWAY THE UNDERLYING "
 DC.B "IDEA IS ---- IMMUNIZE ALL YOUR DISCS AND ZAP THOSE VIRII!      "
 dc.b "  IT'S NOW MID NOVEMBER 1990 AND IT'LL SOON BE CHRISTMAS AND "
 DC.B "NEW YEAR, LET'S HOPE SOME GROUPS DO NEW YEAR DEMOS. I "
 DC.B "SUGGESTED TO BORIS THAT WE SHOULD CODE A SMALL MEGADEMO WITH "
 DC.B "ABOUT 4 SCREENS BUT IT NEVER TOOK OFF. WHEN I GET ROUND TO IT "
 DC.B "I'LL CODE UP A COUPLE OF IDEA I HAVE, I'VE ACTUALLY STARTED "
 DC.B "DOING ONE SCREEN FOR THE P.O.V. MEGADEMO BUT PREFER TO PRESS "
 DC.B "ON WITH THESE PACKED DEMO DISCS, MAYBE WHEN I REACH THE 50 MARK "
 DC.B "I'LL STOP FOR A WHILE - WHO KNOWS!        "
 DC.B "I HAVE 14 DEMOS PACKED AND WAITING FOR A MENU, THERE ARE 8 "
 DC.B "1 MEG DEMOS AND 6 1/2 MEG DEMOS, THE 1 MEG ONES TAKE NEARLY "
 DC.B "ALL THE DISC SPACE SO I MAY PUT SOME 'INTROS' ON THE DISCS "
 DC.B "TO FILL THEM UP OR MAYBE EVEN WRITE A FILLER DEMO.     "
 DC.B "I SHOULD BE ABLE TO PUT TWO 1 MEG DEMOS ON ONE DISC FOR "
 DC.B "ALL YOU 1040 PEOPLE.   IF YOU HAVN'T GOT 1 MEG THEN "
 DC.B "GET ONE 'COS THERE ARE A LOT OF DEMOS COMING UP THAT NEED "
 DC.B "ONE MEG, IF YOU'VE GOT A 520 STE THEN AN UPGRADE IS DEAD EASY "
 DC.B "AS IT ONLY TAKES 2 256K SIMMS TO DO THE JOB, THEY COST "
 DC.B "ABOUT 40 POUNDS AND CAN BE FITTED IN APPROX 6 MINUTES. I "
 DC.B "UPGRADED MY 1040 STE TO A 4096 (4 MEG) BACK IN APRIL 1990 AND "
 DC.B "IT TOOK ME ABOUT 6 MINUTES TO RIP THE CASE OPEN AND SLOT THE "
 DC.B "BOARDS IN.   IF YOU HAVN'T GOT AN STE THEN BUY A FRONTIER "
 DC.B "UPGRADE AS THESE ARE EASY TO FIT (BORIS BOUGHT ONE).  "
 DC.B "    LOOKING ON THE HORIZON ON DEMOS I'VE RECEIVED SOME "
 DC.B "MORE STE ONLY STUFF INCLUDING THE STE JUNGLE DEMO AND WORLD "
 DC.B "BEAT SO THEY SHOULD BE SEEN SOON. MOST OF THE STE DEMOS WILL "
 DC.B "NOT RUN FROM THE AUTO FOLDER SO BORIS HAS WRITTEN AN AUTOGEM "
 DC.B "PROGRAM THAT WORKS ON ANY ST/STE SO WE SHOULD BE ABLE TO "
 DC.B "GET THOSE LITTLE NASTY COMPILED CRAP DEMOS ONTO A MENU (EG "
 DC.B "GRUSEL). I PACKED GRUSEL BUT WHEN IT RAN FROM THE AUTO FOLDER "
 DC.B "ONE OF THE COLOURS WOULD NOT DEFINE TO THE CORRECT COLOUR "
 DC.B "WHICH MEANT THE COFFING WAS GLOWING WHITE!     "
 DC.B "WELL I'VE NEARLY RUN OUT OF THINGS TO WRITE SO I'LL DO A QUICK "
 DC.B "WORD ABOUT THE SPECTRUM ANALYSER......  AFTER SEEING ONE ON THE "
 DC.B "AMIGA I THOUGHT I'D HAVE A GO, I KEPT SAYING I'LL DO IT "
 DC.B "TOMORROW AND SUDDENLY AUTOMATION WROTE ONE - DAMN IT.   "
 DC.B "   I STARTED THIS INFO PROGRAM AND INTENDED TO WRITE A STAR "
 DC.B "FIELD FOR THE TOP BUT RAN INTO PROBLEMS WITH THE AMOUNT OF "
 DC.B "CPU TIME IT WAS TAKING SO I WROTE THE SPECTRUM ANALYSER "
 DC.B "BETWEEN 12 AND 3 AM ON 16-11-90, IT'S STILL IN A VERY "
 DC.B "EXPERIMENTAL STAGE AT THE MOMENT AS IT IS PRETTY HARD "
 DC.B "TO GET A BALANCE BETWEEN OCTAVES AND NOTE VALUES FOR "
 DC.B "THE DISPLAY.  THE SOUND CHIP HAS 15 DIFFERENT VALUES FOR "
 DC.B "THE OCTAVES AND 256 DIFFERENT VALUES FOR THE NOTES, WHEN "
 DC.B "I GET TIME I'LL STUDY THE NOTE MAJORS AND WRITE A ROUTINE "
 DC.B "TO CHOP ANY OTHERS, THE OCTAVES ARE PRETTY EASY EXCEPT THERE "
 DC.B "ARE NOT ENOUGH PIXELS ON THE SCREEN FOR A FULL OCTAVE SET IN "
 DC.B "LOW REZ SO I CHOP THE OCTAVES IN HALF WHICH MEANS THE NOTE "
 DC.B "VALUES HAVE 1/2 THE ROOM AS I'D LIKE.   IF YOU CAN UNDERSTAND "
 DC.B "WHAT I'M ON ABOUT THEN YOU MUST BE GOOD 'COS I CAN'T!!!!!  "
 DC.B "BASICALLY I'M TRYING TO SAY THAT I COULD WRITE A SHIT HOT ONE "
 DC.B "FOR MEDIUM REZ!        OKAY FANS THAT'S IT FOR NOW SO I'LL SIGN "
 DC.B "OFF, UNTIL NEXT TIME  BYE...    "
 DC.B "P.S.   I LIED ABOUT THE HIDDEN SCREEN!!!!            "
 DC.B "                                "
 dc.b "PERSISTENCE OF VISION INFO 40.    "
 DC.B "ALL CODING, ART AND MUS          ARE YOU STILL HERE?       "
 DC.B "WHY?              THERE IS NO MORE TEXT THAT WILL BE OF "
 DC.B "ANY INTEREST.            "
 DC.B "FOR GODS SAKE PRESS THE ESCAPE KEY!            "
 DC.B "WOT NO GREETS??????????          "
 DC.B "PEA GREETS      MOVE.W #9,-(SP)      TRAP #1      ADDQ.L #6,SP      "
 DC.B "      GREETINGS TO....   DIRTY TRICKS BRIGADE,   GEORGE C.,   "
 DC.B "SEWER SOFTWARE,   DROMSKI,   AUTOMATION,   V8,   BASHER,   "
 DC.B "ERIK PLANKTON,   MARTIAN,   DR.SYNE,   ROGER MELLEY,   "
 DC.B "BIFFA BACON,   FAT SLAGS,   DYNAMIC DUO,   CONPUTER VISIONS,   "
 DC.B "POMPEY PIRATES,   MEDWAY BOYS,   LOST BOYS,   REPLICANTS   AND   "
 DC.B "ANYBODY ELSO WHO HAS HAD DEALING WITH US.     BYE (FOR REAL)."
 DC.B "       5       4       3       2       1       "
 dc.b $ff
	even
char_offset	dc.w	0
font:	dcb.b	120,0
	incbin	was274.fnt
font_offsets:
 dc.b	0,41,43,0,0,0,0,46,44,45,0,0,38,42,39,48
 dc.b	27,28,29,30,31,32,33,34,35,36,40,0,0,0,0,47,0
 dc.b	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26
 dc.b	41,0,42,0,0
	even
sine_position	dc.l	sine_table
sine_table
	incbin	cosine.dat
	dc.b	$ff
	even

*************************************************************
tune:	incbin	121.img
************** isr bits **************
old120:		dc.l	0
old118:		dc.l	0
old70:		dc.l	0
a09:		dc.b	0
a07:		dc.b	0
a13:		dc.b	0
old484		dc.b	0
	even
vsync_flag:	dc.w	1
isr_data:	dc.l	msd_pal
msd_pal	dc.w	$800,$100,$900,$200,$a00,$300,$b00,$400
	dc.w	$c00,$500,$d00,$600,$e00,$700,$f00,$f80
	dc.w	$f10,$f90,$f20,$fa0,$f30,$fb0,$f40,$fc0
	dc.w	$f50,$fd0,$f60,$fe0,$f70,$ff0,$7f0,$ef0
	dc.w	$6f0,$df0,$5f0,$cf0,$4f0,$bf0,$3f0,$af0
	dc.w	$2f0,$9f0,$1f0,$8f0,$0f0,$0f1,$0f2,$0f3
	dc.w	$0f4,$0f5,$0f6,$0f7,$077,$067,$057,$047
	dc.w	$037,$027,$017,$007,$107,$000

	dc.w	0,0
	dc.w	$100,$200,$300,$400,$500,$600,$700
	dc.w	$710,$720,$730,$740,$750,$760,$770
	dc.w	$671,$572,$473,$374,$275,$176,$077
	dc.w	$067,$057,$047,$037,$027,$017,$007
	dc.w	$107,$207,$307,$407,$507,$607,$707
	dc.w	$706,$705,$704,$703,$702,$701,$700
	dc.w	$500
end_pal	dc.w	0,0,0,0
	even

**************** show disc contents ***************
disc_number	dc.w	0
disc_enable	dc.w	0
xpos	dc.w	0
ypos	dc.w	0
byte_offset	dc.w	0
tab_offset	dc.w	0
is_clear	dc.w	$ffff
line_add	dc.l	0
lines_to_clear	dc.w	0
minifont	incbin	font.dat
disc_text_pos	dc.l	disc_text
disc_text
real	incbin	disc_txt.s
	dc.b	$ff
	even
disc_start_table
	ds.l	50

************** spec **********
spec_pos	dc.l	0
spec_values	dcb.b	200,0
	even

************** SHIFTY THING (COLOUR CYCLE) *************
colours_pos	dc.l	colours
colours
	dc.w	$222,0,0,0
	dc.w	0,0,0,$222
	dc.w	0,0,$222,0
	dc.w	0,$222,0,0
	dc.w	$ffff,$ffff
col3	dc.w	0
col7	dc.w	0
col11	dc.w	0
col15	dc.w	0

pic:	incbin	info40.pi1
