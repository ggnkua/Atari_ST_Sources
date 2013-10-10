****************
* P.O.V. 41    *
****************

	bsr	set_super
	clr.l	$24.w
wait_for_drive:
	move.w	$ffff8604.w,d0
	btst	#7,d0
	bne.s	wait_for_drive

	move.b	#$12,$fffffc02.w
	bsr	save_pal
	bsr	get_base
	bsr	calc_screen
	move.l	screen_base,a0	;screen_base
	bsr	set_low_rez
	bsr	clear_below_screen
	move.b	$484,old484
	clr.b	$484

;************************************************************************
;*                           VERMINATOR                                 *
;*                           ----------                                 *
;* Stolen by: MAC SYS DATA of P.O.V. 24/08/90 10:25                     *
;*      From: AUTOMATION disc 220                                       *
;* Include files:-                                                      *
;*                 vermin.img into TUNE                                 *
;************************************************************************

;****************************************************************
; There is more than one tune in this code....
; 0=Automation 220
; 1=tune 1
; 2=tune 2
; 3=tune 3
; 4=tune 4
; 5=jingle 5

	move.l	#0,D0
	jsr	tune
	clr.l	$24.w

	bsr	set_palette
	bsr	set_for_border
	bsr	show_pic
	bsr	vsync
	bsr	animate
	move.b	#0,$fffffc02.w
main_loop:
	bsr	vsync
;	move.w	#$123,$ffff8240.w
	bsr	return_screen
	bsr	animate
	bsr	scroll
;	move.w	pic+2,$ffff8240.w
	move.b	$fffffc02.w,d0
;	cmp.b	#01,d0		;escape
;	beq	exit

	cmp.b	#$b,d0		;0 key
	bne.s	not_zero
	tst.w	zero_counter
	bne.s	aa
	eor.w	#$300,bor+2
	eor.w	#$ffff,hertz_switch
	move.w	#10,zero_counter
	bra.s	main_loop
not_zero:
	tst.w	zero_counter
	beq.s	car
aa:	sub.w	#1,zero_counter

car:	cmp.b	#$53,d0
	beq.s	do_reset
	cmp.b	#2,d0		;1 key
	blt.s	main_loop
	cmp.b	#6,d0		;5 key
	bge.s	main_loop	

	move.l	d0,-(sp)
	bsr	isr_off
	move.l	old_base,a0	;screen_base
	bsr	set_low_rez
	lea	$ffff8240.w,a1
	clr.l	(a1)+
	clr.l	(a1)+
	clr.l	(a1)+
	clr.l	(a1)+
	clr.l	(a1)+
	clr.l	(a1)+
	clr.l	(a1)+
	clr.l	(a1)+
	move.l	(sp)+,d0

;key is in D0.L
	and.l	#$ff,d0
	lea	filenames,a6
	sub.b	#2,d0
	mulu	#14,d0
	add.w	d0,a6
	move.l	old_base,a0
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.w	(a6)+,(a0)

	tst.w	hertz_switch
	beq.s	hz50
	eor.b	#2,$ff820a
hz50:
	bsr	user_mode
	clr.w	-(sp)
	trap	#1

do_reset
	move.l	4,a0
	jmp	(a0)
exit:
	bsr	isr_off

;reset rez
	move.l	old_base,a0
	bsr	set_med_rez

	bsr	restore_pal
	move.b	#8,$fffffc02.w
	move.b	old484,$484
	bsr	user_mode

	clr.w	-(sp)
	trap	#1
	addq.l	#4,sp
	rts

***************
* Subroutines *
***************
return_screen
	move.l	old_pos,d0
	move.l	screen_base,a1
	add.w	d0,a1
	lea	pic+34,a0
	add.w	d0,a0
	REPT	35
	movem.l	(a0),d0/d1/d2/d3/d4/d5/d6/d7/a2/a3
	movem.l	d0-d7/a2/a3,(a1)
	add.w	#160,a0
	add.w	#160,a1
	ENDR
	rts

animate:
	moveq	#0,d7
	move.l	d7,d6
	move.l	d6,d5
	move.l	d5,d4
	move.l	xtable_pos,a0
	cmp.b	#$ff,(a0)
	bne.s	.xno_reset
	lea	xtable,a0
	move.l	a0,xtable_pos
.xno_reset
	move.b	(a0)+,d6
	move.b	(a0)+,d5
	move.l	a0,xtable_pos

	move.l	ytable_pos,a0
	cmp.b	#$ff,(a0)
	bne.s	.yno_reset
	lea	ytable,a0
	move.l	a0,ytable_pos
.yno_reset
	move.b	(a0)+,d7
	move.l	a0,ytable_pos

	mulu	#160,d7
	mulu	#8,d6

	add.w	d6,d7
	move.l	d7,old_pos
	move.l	screen_base,a1
	add.w	d7,a1

	lea	logo,a0
	mulu	#(35*40),d5
	add.w	d5,a0
	REPT	35
	move.w	(a0)+,d3
	move.w	(a0)+,d2
	move.w	(a0)+,d1
	move.w	(a0)+,d0
	or.w	d3,(a1)
	or.w	d2,2(a1)
	or.w	d1,4(a1)
	or.w	d0,6(a1)
	add.w	#8,a1

	move.w	(a0)+,d3
	move.w	(a0)+,d2
	move.w	(a0)+,d1
	move.w	(a0)+,d0
	or.w	d3,(a1)
	or.w	d2,2(a1)
	or.w	d1,4(a1)
	or.w	d0,6(a1)
	add.w	#8,a1

	move.w	(a0)+,d3
	move.w	(a0)+,d2
	move.w	(a0)+,d1
	move.w	(a0)+,d0
	or.w	d0,(a1)
	or.w	d1,2(a1)
	or.w	d2,4(a1)
	or.w	d3,6(a1)
	add.w	#8,a1

	move.w	(a0)+,d3
	move.w	(a0)+,d2
	move.w	(a0)+,d1
	move.w	(a0)+,d0
	or.w	d0,(a1)
	or.w	d1,2(a1)
	or.w	d2,4(a1)
	or.w	d3,6(a1)
	add.w	#8,a1

	move.w	(a0)+,d3
	move.w	(a0)+,d2
	move.w	(a0)+,d1
	move.w	(a0)+,d0
	or.w	d0,(a1)
	or.w	d1,2(a1)
	or.w	d2,4(a1)
	or.w	d3,6(a1)
	add.w	#8,a1

	add.w	#160-40,a1
	ENDR
	rts

scroll:	move.l	screen_base,a1
	add.w	#160*203,a1
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
	mulu	#480,d0		;30 * 4 (4 planes)
	add.w	d0,a0
	move.w	d6,d0
	mulu	#120,d0		;character depth * 4 (30*4)
	add.w	d0,a0

.column
OFF	set	0
	REPT	30
	move.b	(a0)+,OFF(a1)
OFF	set	OFF+2
	move.b	(a0)+,OFF(a1)
OFF	set	OFF+2
	move.b	(a0)+,OFF(a1)
OFF	set	OFF+2
	move.b	(a0)+,OFF(a1)
OFF	set	OFF+154
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

vsync:	move.w	#$ffff,vsync_flag
vs:	tst.w	vsync_flag
	bne.s	vs
	rts

set_super:
	clr.l	-(sp)		;set supervisor mode
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,stack_save
	rts

user_mode:
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

save_pal:
	lea	old_pal,a1
	lea	$ffff8240,a0
	move.w	#16-1,d0
save_p:
	move.w	(a0)+,(a1)+
	dbf	d0,save_p
	rts

restore_pal:
	lea	old_pal,a0
	bra.s	set_p

set_palette:
	lea	pic+2,a0
set_p:	lea	$ffff8240.w,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts

get_base:
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,old_base
	rts

calc_screen:
	lea	screen,a0
	move.l	a0,d0
	clr.b	d0
	move.l	d0,screen_base
	rts

set_med_rez:
	move.w	#1,-(sp)
	bra.s	set_rez

set_low_rez:
	clr.w	-(sp)
set_rez:
	move.l	a0,-(sp)
	move.l	a0,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts

show_pic:
	lea	position_table,a2
	move.w	#500/4-1,d0
.loop
	movem.l	d0/a0-a1,-(sp)
	bsr	v_sync
	bsr	print
	bsr	print
	bsr	print
	bsr	print
	movem.l	(sp)+,d0/a0-a1
	dbf	d0,.loop
	rts

print
	lea	pic+34,a0
	move.l	screen_base,a1
	moveq	#0,d0
	moveq	#0,d1
	move.b	(a2)+,d1
	move.b	(a2)+,d0
	mulu	#160*8,d0
	mulu	#8,d1
	add.w	d1,d0
	add.w	d0,a0
	add.w	d0,a1
	REPT	8
	move.w	(a0),(a1)
	move.w	2(a0),2(a1)
	move.w	4(a0),4(a1)
	move.w	6(a0),6(a1)
	add.w	#160,a0
	add.w	#160,a1
	ENDR
	rts


v_sync:	movem.l	d0-d3/a0-a3,-(sp)
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d0-d3/a0-a3
	rts

clear_below_screen:
	move.l	screen_base,a0
	add.w	#32000,a0
	move.w	#20,d0
clr1:	move.w	#8*40-1,d1
clr2:	clr.l	(a0)+
	dbf	d1,clr2
	dbf	d0,clr1
	rts

set_for_border:
	ori.w	#$700,sr
	move.l	$70,old70
	move.l	$120,old120
	move.b	$fffffa07,olda07
	move.b	$fffffa09,olda09
 	move.b	$fffffa17,olda17
	move.b	$fffffa1b,olda1b
	move.b	$fffffa21,olda21

	MOVE.L	#vert_isr,$70.W
	MOVE.L	#horiz_isr,$120.W

	MOVE.B	#1,$FFFFFA07.W
	CLR.B	$FFFFFA09.W
	BCLR	#0,$FFFFFA0F.W
	BSET	#0,$FFFFFA13.W
	BCLR	#3,$FFFFFA17.W
	CLR.B	$FFFFFA1B.W
	CLR.B	$FFFFFA21.W
	MOVE.W	#$2300,SR
	rts


isr_off:
	ORI.W	#$700,SR
	CLR.B	$FFFF8260.W
	move.l	old120,$120
	move.l	old70,$70

	MOVE.B	olda07,$FFFFFA07
	MOVE.B	olda09,$FFFFFA09
	MOVE.B	olda17,$FFFFFA17
	move.b	olda1b,$fffffa1b
	move.b	olda21,$fffffa21

	MOVE.W	#$2300,SR

endmusic:
	lea	$ff8800,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	rts

*********
* ISRs  *
*********
vert_isr:
	movem.l	d0-d7/a0-a6,-(sp)	;preserve regs
	movem.l	pic+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.b	#49,counter	;49 lines at 4 pixels each ISR
	move.l	#horiz_isr,$120.W
	clr.w	horiz_sync
	bsr	tune+$e
	clr.w	vsync_flag
	movem.l	(sp)+,d0-d7/a0-a6
	move.b	#8,$fffffa1b.w
	move.b	#3,$fffffa21.w
	rte

horiz_isr:
	move.b	#4,$fffffa21.w	;4 lines per isr 
	move.l	#go_border,$120.w
	rte

go_border:
	subq.b	#1,counter
	beq.s	extended_scan
	rte

extended_scan:
	REPT	98
	nop
	ENDR
	clr.b	$ffff820a.w	;60 hertz
	REPT	31
	nop
	ENDR
	move.b	#2,$ffff820a.w	;back to 50 hertz
	move.l	#lower_border,$120.w
	rte

lower_border:
	clr.b	$fffffa1b.w	;DI all other interrupts
	movem.l	fontpal,d0-d7
	movem.l	d0-d7,$ffff8240.w
bor	move.w	#$000,$ffff8240.w
	bclr	#0,$fffffa0f.w
	rte


********
* Data *
********
	SECTION DATA
fontpal:
	dc.w	$000,$100,$210,$320,$430,$540,$650,$760
	dc.w	$300,$400,$500,$700,$711,$722,$724,$710

zero_counter:	dc.w	0
screen_base:	dc.l	0
old484:	dc.w	0
stack_save:	dc.l	0
vsync_flag:	dc.w	0
old70:	dc.l	0
old120:	dc.l	0
olda07:	dc.b	0
olda09:	dc.b	0
olda17:	dc.b	0
olda1b:	dc.b	0
olda21:	dc.b	0
	even
horiz_sync:	dc.w	0
old_base:	dc.l	0
counter:	dc.w	0
hertz_switch	dc.w	0

scroll_number:	dc.w	0
scroll_buffer:	ds.b	44*35+4*35

scroll_pointer:	dc.l	scroll_text+7
scroll_text:
 dc.b "                        PERSISTENCE OF VISION PACKED DEMO DISC 41.    "
 dc.b "HI FANS - M.S.D. HERE AS USUAL BRINGING YOU MORE GOODIES IN THE "
 DC.B "FORM OF PACKED DEMOS.   THIS MENU WAS CODED BY "
 DC.B "M.S.D.  WITH ART BY OZ  AND  MUSIC RIPPED FROM "
 DC.B "VERMINATOR BY MAC SYS DATA.    IF YOU THINK THIS FONT LOOKS "
 DC.B "FAMILIAR THEN YOU MUST BE A PIRATE BECAUSE I STOLE IT FROM "
 DC.B "AUTOMATION  - TA BOYS!!!      "
 dc.b "THIS DISC WAS FINISHED AFTER DISC 42 BUT WHO CARES - I STILL "
 DC.B "HAVN'T FINISHED DISC 32!!!! (COME ON BORIS GET FINISHING YOUR "
 DC.B "FILLER!).        THE TIME HAS COME TO DO THE GREETS SO HERE "
 DC.B "WE GO - HELLO TO...   AUTOMATION,   POMPEY PIRATES,   "
 DC.B "MEDWAY BOYS,   LOST BOYS,   INNER CIRCLE (EXCELLENT DECADE DEMO),   "
 DC.B "DYNAMIC DUO,   DR. SYNE,   MARTIAN,   GEORGE,   ERIK PLANKTON,   "
 DC.B "BASHER,   THE SKUNK,   DTB (WHERE'S MY DISC STEVE?),   THE DEMO CLUB,   "
 DC.B "SWSL,   THE EMPIRE   AND   THE REPLICANTS.        I HAVE JUST RECEIVED A COPY "
 DC.B "OF NOISETRACKER AND IT'S BLOODY AMAZING! IT LOOKS AND WORKS "
 DC.B "JUST LIKE THE AMIGA VERSION, THE EMPIRE HAS DONE A TERRIFIC "
 DC.B "JOB OF CONVERTING IT.    ANYBODY OUT THERE WANT A COPY?      "
 DC.B "YES?      RIGHT I'LL PUT IT ON A MENU!      TODAY'S DATE IS "
 DC.B "23-11-90 AND IT'LL SOON BE CHRISTMAS, I WANT TO HAVE DISC 50 DONE "
 DC.B "THIS YEAR SO KEEP YOUR EYES ON THOSE PD ADVERTS 'COS IF I "
 DC.B "MAKE IT THERE WILL BE LOADS OF PD STOCKINGS FULL OF P.O.V. "
 DC.B "COMPACTS.    IF I DO FINISH DISC 50 I'LL TRY TO GET OUR "
 DC.B "MEGADEMO WRITTEN, OR I'LL WRITE A MINI-MEGADEMO WITH "
 DC.B "BORIS JUST FOR A LAUGH.    "
 dc.b "HEY HAS ANYBODY GOT AN AMIGA OUT THERE?     IF YOU HAVE THEN "
 DC.B "GET A COPY OF THE CRYPTOBURNERS MEGADEMO 2 'CAUSE IT'S BRILLIANT!!! "
 DC.B "  WE'VE ALL SEEN 3D BEFORE BUT THEY GO OUT OF THEIR WAY TO "
 DC.B "DO SOME REALLY COMPLEX OBJECTS WHICH MAKES IT STAND OUT FROM "
 DC.B "THE CROWD.     IF ANYBODY OUT THERE HAS A GOOD COPY OF THE 'TEC "
 DC.B "DEMO' THEN PLEASE SEND IT TO OUR CONTACT ADDRESS WHICH IS..... "
 DC.B "   P.O.V.   BLACKPOOL,  UK.  ---- SORRY BUT I HAD TO REMOVE THE "
 DC.B "ADDRESS BECAUSE DR.SYNE IS ENQUIRING ABOUT A PO BOX, IF IT FALLS "
 DC.B "THROUGH THEN WE WILL RELEASE DR.SYNE'S ADDRESS.     "
 DC.B "     IF YOU DO SEND SOMETHING "
 DC.B "COULD YOU PLEASE NOTE A NOT INSIDE SAYING WHO IT IS FOR. IF YOU "
 DC.B "WANT YOUR DISC RETURNING PLEASE ENCLOSE THE POSTAGE, WE WILL "
 DC.B "NOT SEND DISCS BACK IF NO RETURN POSTAGE STAMPS OR MONEY IS SENT. "
 DC.B "   THE COST OF SENDING ONE DISC VIA THE ROYAL MAIL IS THE PRICE "
 DC.B "OF A FIRST CLASS STAMP, IF YOU SEND ABOUT 5 THEN THE COST IS ABOUT "
 DC.B "37 PENCE, IF YOU ARE UNSURE OF THE COST THEN SEND 50 PENCE "
 DC.B "AS WE MAY HAVE TO BUY A JIFFY BAG FOR THE RETURN JOURNEY.    "
 DC.B "  IT HAS BEEN NOTICED THAT THERE IS ANOTHER GROUP DOING PACKED "
 DC.B "DEMO COMPILATIONS, THE GROUP IS CALLED 'RIPPED OFF' AS WE "
 DC.B "HAVE NEVER SEEN ANY OF THEIR DISCS, CAN SOMEBODY SEND US SOME?  "
 DC.B "       I HAVE NOW 16 DEMOS ALL PACKED AND READY FOR A MENU, THANKS "
 DC.B "TO GEORGE AND THE DEMO CLUB FOR THE RECENT BATCH.     RIGHT, I'VE "
 DC.B "JUST PUT 'MAHONEY AND KAKTUS MUSIC DISK 2' ON MY AMIGA AND I'M "
 DC.B "LISTENING TO 'CUSTARD' BY GLUE MASTER - YEH!! THERE ARE 44 TRACKER "
 DC.B "TUNES IN IT AND THEY ARE BRILLIANT (IT'S BEGINNING TO BE A CLICHE OF MINE) SO "
 DC.B "IF YOU HAVE OR EVER BUY AN AMIGA WRITE TO ME VIA DR.SYNE AND I'LL "
 DC.B "SEND YOU A COPY.   HAVE ANY OF YOU GOT THE DELIRIUS 2 DEMO?   WELL "
 DC.B "IF YOU HAVE YOU MUST HAVE HEARD THE MUSIC FROM THE INTRO - THE "
 DC.B "BIT WITH THE GHOSTS GOING UP AND DOWN TO THE MUSIC BIT - WELL "
 DC.B "THE LAMERS WHO WROTE THE DEMO SAID THEY COMPOSED IT BUT I KNOW "
 DC.B "BETTER .... IT WAS STOLEN FROM THE MAHONEY AND KAKTUS MUSIC DISK 2. "
 DC.B "IT IS CALLED 'GREETINGCASTLE' AND WAS WRITTEN BY MAHONEY.      "
 DC.B "THERE SEEMS TO BE A LOT OF 'OH LOOK WHAT AN ORIGINAL IDEA I'VE DONE' ON "
 DC.B "THE ST WHICH YOU THEN THINK WOW! WHAT CLEVER BASTARDS BUT THE "
 DC.B "IDEA WILL HAVE BEEN COPIED FROM THE AMIGA WHERE THERE SEEMS TO BE "
 DC.B "A LOT OF GOOD IDEAS AND EFFECTS THAT SLOWLY CREEP ONTO THE ST. THE "
 DC.B "AMIGA IS A BETTER MACHINE BUT TOTALLY NAFF WHEN IT COMES TO "
 DC.B "EASE OF PROGRAMMING, THE AMIGA HAS A MUCH BETTER BLITTER, SOUND "
 DC.B "AND GRAPHIC CHIP BUT IT ALSO HAS A NAFF ARCHITECHTURE, KEYBOARD, "
 DC.B "DISC DRIVE, OPERATING SYSTEM, NO ON/OFF SWITCH AND TO TOP IT ALL "
 DC.B "IT IS VERY OVER-RATED.  MY RECOMMENDATIONS ARE - IF YOU WANT "
 DC.B "A GAMES MACHINE THEN BUY AN AMIGA BUT IF YOU WANT A GAMES "
 DC.B "MACHINE AND ALSO WANT TO DO SOME WORD PROCESSING OR PROGRAMMING "
 DC.B "THEN BUY AN ST OR EVEN BETTER AN STE.         RIGHT I'VE "
 DC.B "WRITTEN QUITE A BIT FOR ONE MENU AND DR.SYNE JUST RANG UP SO I'VE "
 DC.B "GOT TO GO OUT AND COPY SOME 150 DISCS THAT HAVE JUST ARRIVED. "
 DC.B "SO UNTIL NEXT TIME.....             "
 DC.B "                                          WRAP       "
 dc.b $ff
	even
char_offset	dc.w	0
font:	dcb.b	480,0
	incbin	"was254.fnt"
font_offsets:
 dc.b	0,41,43,0,0,0,0,46,44,45,0,0,38,42,39,48
 dc.b	27,28,29,30,31,32,33,34,35,36,40,0,0,0,0,47,0
 dc.b	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26
 dc.b	41,0,42,0,0
	even

******* show pic data *********
position_table
	incbin	fill.dat
;*************************
tune:	Incbin	vermin.img
	even
pic	incbin	pov41.PI1
	even

********** animation data ************
xtable_pos	dc.l	xtable
xtable
	incbin	xtable.dat
	dc.b	$ff,$ff,$ff,$ff
	even
ytable_pos	dc.l	ytable
ytable	
	incbin	ytable.dat
	dc.b	$ff,$ff,$ff,$ff
	even
old_pos	dc.l	0
logo	incbin	logo.dat
	even

filenames:
	dc.b	"OXYGENE.MSD",0,0,0
	dc.b	"MADONNA.MSD",0,0,0
	dc.b	"VECTOR.OVR",0,0,0,0
	dc.b	"COPIER.POV",0
	even
	SECTION BSS
old_pal:	ds.b	32
	ds.b	256
screen:	ds.b	32000

