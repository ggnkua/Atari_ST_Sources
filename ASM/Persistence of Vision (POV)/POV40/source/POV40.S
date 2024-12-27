*** P.O.V. 40 *****

	dc.w	$a00a
	bsr	set_super
	or.b	#2,$ffff820a.w	;50Hz
	move.b	#$12,$fffffc02.w
	bsr	get_oldbase
	bsr	get_old_pal
	bsr	calc_new_base
	movem.l	screen+2,d0-d7
	movem.l	d0-d7,pal
	bsr	chop_screens
	move.l	screen_base,a0
	bsr	set_low_rez
	bsr	set_new_palette
	move.b	$484.w,old484
	clr.b	$484.w
;************************************************************************
;*                            UNKNOWN                                   *
;*                            -------                                   *
;* Stolen by: MAC SYS DATA of P.O.V. 16/08/90 18:04                     *
;*      From: DELIRIUS DEMO ADVERT                                      *
;* Include files:-                                                      *
;*                 ADVERT.IMG into TUNE                                 *
;************************************************************************
;* music by MAD MAX
;*

;****************************************************************
; There is more than one tune in this code....
; 0=no music
; 1=no music
; 2=tune 1
; 3=tune 2 - pretty good (On an Automation menu as well I think)
; 4=tune 3 - weird start but brill!
; 5=tune 4
; 6=jingle
; 7=sound effect - bleeps
; 8=tune 5
	moveq	#5,D0
	bsr	tune

	moveq	#0,d0
	move.b	ytab,d0
	mulu	#160,d0
	move.w	d0,old_logo_height
	bsr	flip_screen
	bsr	animate
	bsr	v_sync
	bsr	isr_on
	bsr	v_sync

***********************************************************
wait:
	bsr	flip_screen
	bsr	v_sync
;	move.w	#$123,$ffff8240.w
	bsr	clear_old_animate
	bsr	animate
	bsr	scroll
	tst.w	hz_countdown
	beq.s	.no_dec
	subq.w	#1,hz_countdown
.no_dec
;	move.w	pal,$ffff8240.w
	bsr	tst_key
	tst.l	d0
	beq.s	wait
************************************************************

	bsr	get_key
;	cmp.b	#27,d0
;	beq	exit

	cmp.b	#"0",d0
	beq	switch_hertz
	cmp.b	#" ",d0
	beq	tune_sequencer
	cmp.l	#$53001f,d0
	beq	do_reset
	cmp.b	#"1",d0
	blt.s	wait
	cmp.b	#"5",d0
	bgt.s	wait

	sub.w	#"1",d0
	move.w	d0,-(sp)
	bsr	isr_off
	move.l	oldbase,a0
	bsr	set_low_rez
	move.b	#$8,$fffffc02.w
	dc.w	$a009
	move.b	old484,$484.w
	lea	$ffff8240.w,a0
	moveq	#0,d0
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.w	(sp)+,d0
	and.l	#$ff,d0
	mulu	#14,d0
	lea	filenames,a1
	add.w	d0,a1
	move.l	oldbase,a0
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.w	(a1),(a0)

;	tst.w	hz_switch
;	beq.s	doit_50
;	and.b	#$fd,$ffff820a.w	;60Hz
;doit_50
	bsr	set_user
	clr.w	-(sp)
	trap	#1

exit:	bsr	isr_off
	move.l	oldbase,a0
	bsr	set_med_rez
	bsr	set_old_pal
	move.b	#$8,$fffffc02.w
	dc.w	$a009
	move.b	old484,$484.w
	bsr	set_user

	clr.w	-(sp)
	trap	#1


do_reset
	move.l	4.w,a0
	jmp	(a0)

switch_hertz
	tst.w	hz_countdown
	bne	wait
	eor.b	#2,$fffff820a.w
	move.w	#10,hz_countdown
	bra	wait

*******************
* CUSTOM ROUTINES *
*******************
reset_tunes
	clr.w	tune_number
tune_sequencer
	moveq	#0,d0
	move.w	tune_number,d0
	add.w	#1,tune_number
	lsl.w	#2,d0	;*4
	lea	tune_sequence,a0
	add.w	d0,a0
	move.l	(a0),d0
	cmp.l	#-1,d0
	beq.s	reset_tunes
	bsr	tune	;start new tune
	bra	wait


flip_screen:
	move.l	present_base,last_base
	move.w	screen_number,d0
	cmp.w	#8,d0
	blt.s	.no_change
	clr.w	screen_number
	clr.w	d0
.no_change
	and.l	#$ff,d0
	mulu	#32000,d0
	move.l	screen_base,a0
	add.l	a0,d0
	move.l	d0,present_base
	bsr.s	set_screen_address
	addq	#1,screen_number
	rts

set_screen_address
	lsr.l	#8,d0
	lea	$ffff8201.w,a0
	movep.w	d0,(a0)
	rts

******************* ANIMATE **************
animate	move.l	ytab_pos,a0
	cmp.b	#$ff,(a0)
	bne.s	.no_reset
	lea	ytab,a0
	move.l	a0,ytab_pos
.no_reset
	moveq	#0,d0
	move.b	(a0)+,d0
	mulu	#160,d0
	move.w	d0,old_logo_height
	move.l	a0,ytab_pos
	move.l	present_base,a1
	add.w	#52,a1
	add.w	d0,a1

	move.l	xtab_pos,a0
	cmp.b	#$ff,(a0)
	bne.s	.no_res
	lea	xtab,a0
	move.l	a0,xtab_pos
.no_res
	move.b	(a0)+,d0
	move.l	a0,xtab_pos
	and.l	#$ff,d0
	mulu	#72*32,d0
	lea	logo,a0
	add.l	d0,a0
	move.w	#72-1,d0
OFF	set	0
.loop	REPT	8
	move.l	(a0)+,OFF(a1)
OFF	set	OFF+8
	ENDR
	lea	160(a1),a1
	DBF	d0,.loop
	rts

clear_old_animate
	move.w	old_logo_height,d0
	move.l	last_base,a0
	add.w	#52,a0
	add.w	d0,a0
	moveq	#0,d1
	move.w	#72-1,d0
.loop	move.l	d1,(a0)
	move.l	d1,8(a0)
	move.l	d1,16(a0)
	move.l	d1,24(a0)
	move.l	d1,32(a0)
	move.l	d1,40(a0)
	move.l	d1,48(a0)
	move.l	d1,56(a0)
	add.w	#160,a0
	dbf	d0,.loop
	rts

scroll:	move.l	present_base,a1
	add.w	#(160*169)+4,a1
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


***********************
* SUBROUTINES SECTION *
***********************
fadein	move.w	#7-1,d0
.loop	add.w	#$111,$ffff825e.w
	move.w	#4,d1
.loop2	bsr.s	v_sync
	dbf	d1,.loop2
	dbf	d0,.loop
	rts

fadeout	move.w	#7-1,d0
.loop	sub.w	#$111,$ffff825e.w
	move.w	#4,d1
.loop2	bsr.s	v_sync
	dbf	d1,.loop2
	dbf	d0,.loop
	rts

sync100	move.w	#100,d0
.loop	bsr	v_sync
	dbf	d0,.loop
	rts
v_sync:	movem.l	d0-d3/a0-a3,-(sp)
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d0-d3/a0-a3
	rts

print_string
	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
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
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,stack_save
	rts
set_user:
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

set_new_palette:
	lea	pal,a0
	lea	$ffff8240.w,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts

get_old_pal
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,oldpal
	moveq	#0,d0
	move.l	d0,d1
	move.l	d1,d2
	move.l	d2,d3
	move.l	d3,d4
	move.l	d4,d5
	move.l	d5,d6
	move.l	d6,d7
	movem.l	d0-d7,$ffff8240.w
	rts

set_old_pal
	movem.l	oldpal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	rts

get_oldbase:
	move.w	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,oldbase
	rts

set_low_rez:
	clr.w	-(sp)
	bra	set_rez
set_med_rez:
	move.w	#1,-(sp)
set_rez:
	move.l	a0,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts

chop_screens
;make all screens continuous by cutting off pal + colour cycle info
	lea	screen,a0
	lea	screen+34,a1
	move.w	#8-1,d1
make2
	move.w	#32000/4-1,d0
make	move.l	(a1)+,(a0)+
	dbf	d0,make
	add.w	#32+34,a1
	dbf	d1,make2

	move.l	screen_base,a1		;set tp 256 byte boundry
	lea	screen,a0
	move.l	#screenend-screen,d1
	lsr.l	#2,d1	;/4
trans:	move.l	(a0)+,(a1)+
	subq.w	#1,d1
	bne.s	trans
	rts

;calc new datum screen address from SCREEN$
calc_new_base:
	lea	screen,a0	;get buffer of 32000
	move.l	a0,d0
	clr.b	d0		;make screen on 256 byte boundary
	move.l	d0,screen_base	;save it
	rts

isr_on
	move.w	#$2700,sr
; Store original vector slots
	move.l	$120.w,hbc
	move.l	$70.w,v_blank
	move.b	$fffffa09.w,a09
	move.b	$fffffa07.w,a07
	move.b	$fffffa13.w,a13
	and.b	#$df,$fffffa09.w
	and.b	#$fe,$fffffa07.w
	move.l	#isr1,$120.w
	move.l	#isr2,$70.w
	or.b	#1,$fffffa07.w
	or.b	#1,$fffffa13.w
	move.w	#$2300,sr
	rts

isr_off:
	move.w	#$2700,sr
	move.l	v_blank,$70.w
	and.b	#$df,$fffffa09.w
	and.b	#$fe,$fffffa07.w
	move.l	hbc,$120.w
	move.b	a07,$fffffa07.w
	move.b	a09,$fffffa09.w
	move.b	a13,$fffffa13.w
	move.w	#$2300,sr

	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	rts

************* isr routines *******
isr1:	move.l	a0,-(sp)	;$120
	move.l	isr_data,a0
;	move.w	(a0),$ffff8240.w
	move.w	(a0),$ffff8248.w
	move.w	(a0),$ffff824a.w
	move.w	(a0),$ffff824c.w
	move.w	(a0)+,$ffff824e.w
	move.l	a0,isr_data
	move.l	(sp)+,a0
	move.b	#0,$fffffa1b.w
	move.b	#1,$fffffa21.w		;1 line of each colour.....
	move.b	#8,$fffffa1b.w
	bclr	#0,$fffffa0f.w
	rte

isr2:	;$70
	move.l	a0,-(sp)
	lea	isr_data,a0
	move.l	#b_line,(a0)
	move.l	(sp)+,a0
	jsr	tune+8
	move.b	#0,$fffffa1b.w	;timer B
	move.b	#169,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte


****************
* DATA SECTION *
****************
	SECTION DATA
hz_countdown	dc.w	0
oldbase:	dc.l	0
last_base	dc.l	0
present_base	dc.l	0
pal		ds.w	16
stack_save:	dc.l	0
screen_base	dc.l	0
screen_number	dc.w	0
old484		dc.w	0
tune:		incbin	advert.img
	even
scroll_number:	dc.w	0
scroll_buffer:	ds.b	44*35+4*35

scroll_pointer:	dc.l	init_scroll_text+7
init_scroll_text:
 dc.b "                                       "
 dc.b "                           ............YO EVERYONE THIS IS "
scroll_text
 dc.b "PERSISTENCE OF VISION COMPACT DEMO DISC 40.    "
 DC.B "ALL CODING, ART AND MUSIC RIPPING BY MAC SYS DATA."
 DC.B "         P.O.V. CONSISTS OF THE "
 DC.B "FOLLOWING MEMBERS ...   MAC SYS DATA (CODER/HACKER/PACKER),     "
 DC.B "BORIS (CODER),     OZYMANDIAS (GRAPHIX)     AND     ALY "
 DC.B "(GRAPHIX).      DR.SYNE HAS NOW PARTLY RE-JOINED TO DO SOME DIRECT "
 DC.B "DISTRIBUTION - SEE THE INFO PROGRAM FOR DETAILS....          "
 DC.B "GREETINGS TO...    "
 DC.B "AUTOMATION,   DR.SYNE,   DTB,   MEDWAY BOYS,   POMPEY PIRATES,   SEWER SOFTWARE,   "
 DC.B "TCB,   AND   THE LOST BOYS.     "
 dc.b "HELLO DEMO FANS, IT'S MAC SYS DATA AT THE KEYBOARD BRINGING YOU "
 DC.B "MORE PACKED DEMOS TO ADD TO YOUR COLLECTION.    THE INFO FILE "
 DC.B "ON THIS DISC WAS WRITTEN BY ME (M.S.D.) AND CONTAINS "
 DC.B "ALL THE INFO ABOUT OUR DISCS.      P.O.V. WOULD LIKE "
 DC.B "TO THANK THE FOLLOWING GROUPS WHOSE PACKERS WE HAVE USED... "
 DC.B "AUTOMATION FOR 1.2 AND 2.3/2.4R,     POMPEY PIRATES FOR THEIR "
 DC.B "PACKER V1.5     AND     AXE OF DELIGHT FOR ICE VERSION 1.1 AND 2.11.   "
 DC.B "  WE MOSTLY USE ICE 2.11 BUT USE 2.4R WHEN PACKING DEMOS THAT ALSO USE "
 DC.B "THE BORIS SAMPLE PACKER V1.0.   THE BORIS SAMPLE PACKER WILL PACK A SAMPLE "
 DC.B "BETTER AND FASTER THAN ANY OTHER PACKER AND IT DOESN'T ALTER THE "
 DC.B "SAMPLE SO THE QUALITY ISN'T AFFECTED.    BORIS AND HIS MATES "
 DC.B "ARE WORKING ON MORE SAMPLE PACKERS AND HAVE HAD SOME THAT PACK "
 DC.B "SAMPLES UP TO 50 PERCENT.      "
 DC.B "AS THIS IS THE START OF ANOTHER DECADE OF DISCS I THOUGHT WE HAD "
 DC.B "BETTER HAVE A DIFFERENT TYPE OF MENU, THIS IS THE RESULT "
 DC.B "OF MY WORK.      OKAY SO IT ISN'T AMAZING BUT IT SURE BEATS "
 DC.B "OUR COMPETITORS ATTEMPT! (IN FACT IT LOOKS BETTER THAN HALF THE "
 DC.B "DEMOS WE PACK!!!!!!!).         "
 DC.B "WHILST WRITING THIS MENU I KEPT GETTING THE ERROR 'OUT OF INTERNAL "
 DC.B "MEMORY: USE FOLDR100.PRG TO GET SOME MORE', WHAT THE F*CK DOES "
 DC.B "THAT MEAN??? I DON'T KNOW IF IT COMES FROM GENST2 OR FROM THE IDC "
 DC.B "HARD DISC SOFTWARE, ANYWAY IT ALSO SAYS 'SYSTEM HALTED' AND MY STE "
 DC.B "JUST STOPS SO I EXPECT IT'S THE IDC SOFTWARE.   I HOPE ALL YOU ST FANS "
 DC.B "GOT DECEMBER'S ISSUE OF ST-FORMAT.   WHAT, YOU DIDN'T?   WELL "
 DC.B "RUSH OUT AND BUY A COPY 'COS WE ARE ON PAGE 151. LOOK AT THE "
 DC.B "'ART AND MUSIC' SECTION - WELL THERE WE ARE ON THE P.O.V. SOUNDTRACKER."
 DC.B "    OK HAVE YOU NOTICED IT?   RIGHT, LOOK ABOVE THE NOISETRACKER "
 DC.B "PICTURE - YEH THAT'S IT 'POV MICROMIX 1 AND 2' - THAT'S P.O.V. 1!!! "
 DC.B "     RIGHT ONCE YOU'VE CALMED DOWN AND READ THE TWO ARTICLES "
 DC.B "TURN TO PAGE 172 AND THERE WE ARE AGAIN ON THE 'WEST LONDON PD' "
 DC.B "ADVERT - WOW!!!      OK SO I FREAKED OUT, BUT WE HAVE ACTUALLY "
 DC.B "APPEARED IN A NATIONAL MAG.    "
 DC.B "AS WE GET MORE POPULAR AND OUR DISCS GET SPREAD, THERE ARE BOUND "
 DC.B "TO BE OTHERS TRYING TO GET IN ON THE ACT BUT REMEMBER, "
 DC.B "PERSISTENCE OF VISION ARE THE ORIGINAL AND BEST DEMO PACKERS "
 DC.B "IN THE U.K.  THERE MAY BE OTHER PACKING GROUPS BUT "
 DC.B "UNLIKE THOSE "
 DC.B "WE DON'T JUST PACK THE EASY "
 DC.B "ONES, WE PACK EVERY DEMO WE CAN GET OUR HANDS ON.     "
 dc.b "YOU MAY FIND OTHER CREWS DON'T PACK DATA FILES DUE TO "
 DC.B "THE WAY SOME DEMOS LOAD THEIR FILES BUT WE AT P.O.V. "
 DC.B "PACK ALL FILES.   IF THERE ARE ANY DEMOS PACKERS OUT THERE "
 DC.B "WHO IS STRUGGLING TO PACK DATA FILES THEN TAKE MY ADVISE AND "
 DC.B "LOOK AT THE VECTORS ADDRESS FOR TRAP 1.      "
 DC.B "   RIGHT I'LL WRAP IT UP HERE, "
 DC.B "BYE. "
 DC.B "                                                        "
 DC.B "                                                        "
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

old_logo_height	dc.w	0
logo	incbin	logo.dat
ytab_pos	dc.l	ytab
ytab	incbin	ytable.dat
	dc.b	$ff,$ff
xtab_pos	dc.l	xtab
xtab	dc.b	0,0,1,1,2,3,4,5,6,7,8,9,10,11,12,13,14,14,15,15
	dc.b	14,14,13,12,11,10,9,8,7,6,5,4,3,2,1,1
	dc.b	$ff
	even

******* colours stuff
hbc:		dc.l	0
v_blank:	dc.l	0
a09:		dc.b	0
a07:		dc.b	0
a13:		dc.b	0
	even
vsync_flag:	dc.w	1
line_count:	dc.w	0	;count of horizontal line down screen for ISR1
isr_data:	dc.l	b_line
b_line:
 dc.w	$030,$050,$070
 dc.w	$1f0,$2f0,$3f0,$4f0,$5f0,$6f0,$7f0
 dc.w	$f60,$f50,$f40,$f30,$f20,$f10,$f00
 dc.w	$701,$602,$503,$404,$305,$206,$107
 dc.w	$01f,$02f,$03f,$04f,$04f,$06f
 dcb.w	50,0
	even

******* tune sequencer *****
tune_number	dc.w	0
tune_sequence
	dc.l	8,2,3,4,5,$ffffffff
filenames
	dc.b	"CEBIT.TLB",0,0,0,0,0
	dc.b	"LOADER.MSD",0,0,0,0
	dc.b	"WIZARD.MSD",0,0,0,0
	dc.b	"INFO40.POV",0,0,0,0
	dc.b	"COPIER.POV",0
	even

****************************
	ds.b	256
screen	incbin	1.pi1
	incbin	2.pi1
	incbin	3.pi1
	incbin	4.pi1
	incbin	5.pi1
	incbin	6.pi1
	incbin	7.pi1
	incbin	8.pi1
screenend
	SECTION BSS
oldpal	ds.b	32
