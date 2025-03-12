;' STE stuff (c) May 1990

	bsr	clear_bss
	bsr	set_super
	move.b	#$12,$fffffc02.w
	bsr	get_pal
	bsr	get_base
	bsr	get_rez
	bsr	calc_screen
	move.l	scr_now,a0
	bsr	set_low_rez

	move.b	$484.w,old484		;save keyboard click/speed, etc
	clr.b	$484.w			;disable repeat/click/bell

	bsr	show_credits
	move.l	#sample1start,sample_start
	move.l	#sample1end,sample_stop
	bsr	start_sample
	bsr	delay
	bsr	black_out
	bsr	show_pic
	clr.b	$ffff8901.w		;DI DMA sample
	move.l	#sample2start,sample_start
	move.l	#sample2end,sample_stop
	bsr	start_sample
	bsr	set_pal


wait	bsr	v_sync
;	move.w	#$123,$ffff8240.w
	bsr	scroll
;	move.w	#0,$ffff8240.w
	bsr	tst_key
	tst.l	d0
	beq.s	wait

	clr.b	$ffff8901.w		;DI DMA sample

	move.b	old484,$484.w
	bsr	set_old_pal
	move.l	old_base,a0
	bsr	set_old_rez
	move.b	#8,$fffffc02.w
	bsr	set_user
	clr.w	-(sp)
	TRAP	#1


*******************
* CUSTOM ROUTINES *
*******************
*********** SCROLLER **********************
DEPTH		EQU	7
WIDTH		EQU	8
BUFFER_SIZE	EQU	DEPTH*(WIDTH*2)

scroll	move.l	line_ptr,a5
	tst.b	(a5)
	bpl.s	loop3
	lea	scroll_line,a5	;restart message
	move.l	a5,line_ptr
loop3	tst.w	scroll_number
	bne.s	loop2
	move.w	#WIDTH,scroll_number
	moveq	#0,d0
.get	move.b	(a5)+,d0
	move.l	a5,line_ptr
	sub.w	#32,d0
	mulu	#(DEPTH*2),d0
	lea	font,a5
	add.l	d0,a5	;letter address is in a5
;transfer letter into buffer
	lea	sbuffer,a1
	REPT	DEPTH
	move.w	(a5)+,(a1)+
	ENDR

loop2	move.l	scr_now,a5
	add.w	#160*192+4,a5
	move.l	a5,a2
	add.w	#152,a2

	lea	sbuffer,a1
;scroll buffer into right pixel of screen ready for scrolling
	move.w	#(DEPTH-1),d1
aloop	roxl.w	(a1)+			;shift buffer
	move.w	sr,d0			;get the status regster
	and.w	#1,d0			;mask off all but carry flag
	or.w	d0,(a2)			;poke right pixel to screen
	lea	160(a2),a2		;down a line on screen
	dbf	d1,aloop

	and.w	#%1111111111101111,SR		;clear X flag

	move.w	#DEPTH-1,d0
loopy	roxl.w	152(a5)
	roxl.w	144(a5)
	roxl.w	136(a5)
	roxl.w	128(a5)
	roxl.w	120(a5)
	roxl.w	112(a5)
	roxl.w	104(a5)
	roxl.w	96(a5)
	roxl.w	88(a5)
	roxl.w	80(a5)
	roxl.w	72(a5)
	roxl.w	64(a5)
	roxl.w	56(a5)
	roxl.w	48(a5)
	roxl.w	40(a5)
	roxl.w	32(a5)
	roxl.w	24(a5)
	roxl.w	16(a5)
	roxl.w	8(a5)
	move.w	(a5),d3
	and.w	#$3fff,d3
	roxl.w	#1,d3
	move.w	d3,(a5)
	lea	160(a5),a5
	dbf	d0,loopy
	sub.w	#1,scroll_number
	rts



start_sample	move.l	sample_start,d0	;set start DMA
		lea	$ffff8903.w,a0
		move.b	d0,4(a0)
		lsr.l	#8,d0
		move.b	d0,2(a0)
		lsr.l	#8,d0
		move.b	d0,(a0)

		move.l	sample_stop,d0	;set end DMA
		lea	$ffff890f.w,a0
		move.b	d0,4(a0)
		lsr.l	#8,d0
		move.b	d0,2(a0)
		lsr.l	#8,d0
		move.b	d0,(a0)

; m=0 for stereo, 1 for mono
;rr=00 for 6258Hz
;rr=01 for 12517Hz
;rr=10 for 25033Hz
;rr=11 for 50066Hz
;	                 m00000rr
		move.w	#%00000001,$ff8920	;mono + 12KHz

;                 00=DI dma sound
;                 01=DI at end of frame
;                 11=Repeat forever
		move.b	#%11,$ffff8901.w
		rts

***********************
* SUBROUTINES SECTION *
***********************

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

show_pic	move.l	scr_now,a1
		lea	pic+34,a0
		move.w	#32000/4-1,d0
.loop		move.l	(a0)+,(a1)+
		dbf	d0,.loop
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

get_pal		movem.l	$ffff8240.w,d0-d7
		movem.l	d0-d7,old_pal
		rts

set_pal		movem.l	pic+2,d0-d7
		movem.l	d0-d7,$ffff8240.w
		rts

set_old_pal	movem.l	old_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w
		rts

get_base	move.w	#3,-(sp)
		trap	#14
		addq.l	#2,sp
		move.l	d0,old_base
		rts

get_rez		move.w	#4,-(sp)
		trap	#14
		addq.l	#2,sp
		move.w	d0,org_rez
		rts


set_old_rez	move.w	org_rez,-(sp)
		bra.s	set_rez
set_low_rez	clr.w	-(sp)
		bra	set_rez
set_med_rez	move.w	#1,-(sp)
set_rez		move.l	a0,-(sp)
		move.l	(sp),-(sp)
		move.w	#5,-(sp)
		trap	#14
		lea	12(sp),sp
		rts


calc_screen	lea	screen,a0
		move.l	a0,d0
		clr.b	d0
		move.l	d0,scr_now
		rts


clear_bss	lea	bss_start,a0
.clear		clr.l	(a0)+
		cmp.l	#bss_end,a0
		blt.s	.clear
		rts

show_credits	lea	credits+34,a0
		move.l	scr_now,a1
		move.w	#32000/4-1,d0
.loop		move.l	(a0)+,(a1)+
		dbf	d0,.loop
		movem.l	credits+2,d0-d7
		movem.l	d0-d7,$ffff8240.w
		rts

black_out	movem.l	black,d0-d7
		movem.l	d0-d7,$ffff8240.w
		rts

delay		move.w	#20000,d7
.loop		move.w	#11,-(sp)
		trap	#1
		addq.l	#2,sp
		tst.l	d0
		bmi.s	.yes
		dbf	d7,.loop
		rts
.yes		move.w	#7,-(sp)
		trap	#1
		addq.l	#2,sp
		rts

*****************************
	SECTION DATA
*****************************
line_ptr	dc.l	scroll_line



scroll_line
 dc.b "      SAMPLING AND ORIGINAL PROGRAMMING BY THE GM         DEMO "
 DC.B "RECODED BY MAC SYS DATA OF PERSISTENCE OF VISION (I'VE REMOVED THE "
 DC.B "OPTION TO CHANGE THE BASS AND TREBLE THOUGH).            "
 dc.b "                    GM PRESENTS YOU WITH THE OFFICIAL 3D SOUND "
 dc.b "DEMO FOR YOUR STE COMPUTER FEATURING REAL 3D STEREO SOUND."
 dc.b "             CONNECT UP YOUR HI FI SYSTEM WITH THE RCA OUTPUT "
 dc.b "JACKS TO GET THE 3D EFFECT.                                "
 dc.b "          NOW FOR SOME HELLOS......... "
 dc.b "   THE BIT MASTER "
 dc.b "WHO HELPED WITH THE PROGRAMMING  *  MARK AT BUZZBOX - "
 dc.b "GREAT DISK MAG FOR THE STFM/STE   WRITE TO..... "
 dc.b "       5 BALMORAL ROAD,   MOORLANDS,   LANCASTER,  "
 dc.b "LANCS,  LA1 3BT.    *  CAREBARES - GREAT STE DEMO * "
 dc.b " LOST BOYS  *  TNT  *  CUGEL - GOOD STE STUFF  *  GUIDE  "
 dc.b "*  SAS  *  SKUNK  *  FUNGUS THE BOGEYMAN  *  MAD MAX  *  "
 dc.b "AND ANY OTHER STE\STFM DEMO WRITERS THAT I DONT KNOW (LIKE POV!)    "
 dc.b "                      WHY NOT CONTACT ME TO"
 dc.b " EXCHANGE DEMOS, DISKS ETC.  WRITE TO             "
 dc.b "6 ALBEMARLE RD,              ST.IVES,           "
 dc.b "CAMBRIDGESHIRE,             PE17 6UN.                 "
 dc.b "STARTING SOON AN EXCLUSIVE NEW PBM GAME (THATS PLAY BY "
 dc.b "MAIL TO YOU) CALLED HOTROD RACING, WRITE TO ME FOR MORE INFO."
 dc.b "             COMMING SOON OZONE, SPRITE DESIGNER AND 3 TRACK "
 dc.b "SAMPLE SEQUENCER BY THE BIT MASTER.              "
 dc.b "   THIS DEMO USES THE STE DMA SOUND TO ITS BEST EFFECT "
 dc.b "IN STEREO AND IT TOOK ME JUST 5 DAYS TO PRODUCE. IT IS MY "
 dc.b "FIRST FULL DEMO ON THE STE AND NOT THE LAST.                  "
 DC.B "           OKAY THATS ENOUGH "
 dc.b "LETS WRAP IT AROUND    . . . . . . . . . . . . . . . . AGAIN! "
 dc.b	$ff
	even

font	dcb.b	DEPTH*2,0
	incbin	"8x8_font.dat"
	even

credits	incbin	credits.pi1

pic	incbin	3dpct.pi1

sample1start	incbin	"3dint.dat"
sample1end

sample2start	incbin	"3dmain.dat"
sample2end

	even


	SECTION	BSS
scroll_number	ds.w	1
sbuffer		ds.b	BUFFER_SIZE
stack_save	ds.l	1
old_base	ds.l	1
old484		ds.w	1
old_pal		ds.w	16
org_rez		ds.w	1
scr_now		ds.l	1
black		ds.w	16
sample_start	ds.l	1
sample_stop	ds.l	1
bss_start
	ds.b	256
screen	ds.b	32000
bss_end
