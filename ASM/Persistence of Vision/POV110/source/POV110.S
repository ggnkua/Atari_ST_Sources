*************************************************************************
*				POV 110					*
*				-------					*
*									*
* Written by MAC SYS DATA of Persistence Of Vision			*
*									*
* All code wrapped around TCB player by AN COOL V1.0 in 4 hours.	*
*									*
* STFM/STE VERSION - this code detects TOS version and if higher than	*
*		     1.06 plays the mod in stereo.			*
*		     This technique may knacker up on later TOS releases*
*		     but I can't use the 'cookie jar' as it's not	*
*		     totally reliable.					*
*									*
*************************************************************************
*
* EQUATES AND BITS............
*
* At P.O.V. we use a program called AUTORUN which P_EXECs the program
* from a seperate program in the AUTO folder (after the menu).
* We use AUTORUN because it allows us to use our own GEM start and it
* ensures ALL 512K demos run in 512K and don't not 1 meg.
*
* If you have a copy of AUTORUN and use it then set 'AUTORUN4' to YES
*
* If you want to P_EXEC the program from this menu then set AUTORUN4 to NO
*
* If you haven't got AUTORUN then get POV 60 onwards and steal it!
*
*
*
*
YES=1
NO=0



;change FINAL to optimize code and remove EXIT code
FINAL=YES	;YES=optimize assemble
		;NO=assemble normal (to memory)



AUTORUN4=YES	;YES to use POV AUTORUN 4 (poke filename at $200 and exit)
		;NO to run program from here




***************************
	SECTION TEXT
***************************


*~~~~~~~~~~~~~~~~~~~~~~~ HERE GOES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
	opt	o+


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
	tst.l	d0
	beq	clean_exit
boom	pea	.reset
	move.w	#$26,-(sp)
	trap	#14
.reset	move.l	4.w,-(sp)
	rts
clean_exit
	clr.w	-(sp)
	trap	#1




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

	lea	bssstart,a0	;clear BSS 'cause most packer don't
clr_bss	clr.l	(a0)+
	cmp.l	#stopper,a0
	blt.s	clr_bss

	bsr	set_super
	move.b	#2,$ffff820a.w		;50Hz
	move.b	#$12,$fffffc02.w	;kiss mouse goodbye
	move.b	$484.w,old484		;save keyboard state
	and.b	#$fe,$484.w		;goodbye click/bell
	bsr	get_old_pal
	bsr	get_screen_base
	bsr	get_org_rez
	bsr	set_low_rez
	bsr	set_up			;set our own screens up
	movem.l	black,d0-d7		;make all black
	movem.l	d0-d7,$ffff8240.w
	move.l	#font_offsets,store_a2	;set up scroller bit
	lea	pic+2,a1		;fade new pic in
	bsr	fadein
	bsr	set_new_pal		;just in case we're using STE colours

	move.w	2.w,d0		;get OS version
	cmp.w	#$0106,d0	;is TOS 1.60
	bge	init_ste	;yes so go init STE code

init	lea	module,a0		;a0=module start
	moveq	#-1,d0			;-1=the default soundtable 0=the other
	move.l	replay_rot,a1
	add.l	replay_offset,a1
	jsr	(a1)		;init. replay routine

* don't use d6-d7/a2-a6 from here
	jsr	save_ints		;save interrupts
	jsr	init_ints		;init. interrupts

main_loop
	bsr	vsync
	bsr	set_screen	;flip screen to stop flicker

;	move.w	#$123,$ffff8240.w
	bsr	scroll
;	move.w	pic+2,$ffff8240.w

	move.b	$fffffc02.w,d0	;get keyboard input

	ifeq	FINAL		;if FINAL=1 then skip ESCape key
	cmp.b	#1,d0		;ESCape to exit to assembler
	beq	exit
	ENDC

	cmp.b	#11,d0		;0 keyboard
	beq.s	zero

	cmp.b	#$70,d0		;0 keypad
	beq.s	zero

	cmp.b	#$53,d0		;DELete key
	beq.s	do_reset

	lea	key_codes,a0	;lookup table of keys to allow easy keypad use
.loop	cmp.b	#$ff,(a0)	;is end of table?
	beq.s	main_loop	;yeh
	cmp.b	(a0)+,d0	;is same as our key press?
	beq.s	load		;yeh!
	move.b	(a0)+,d1	;no so get offset into dummy reg
	bra.s	.loop		;go back and look for more

load	move.b	(a0),-(sp)	;store key somewhere
	jsr	ret_ints	;restore interrupts

;now move filename into $200 for AUTORUN 4
	moveq	#0,d0
	move.b	(sp)+,d0	;get key back
	lsl.w	#2,d0		;*4
	lea	filenames,a0	;filename lookup table
	add.w	d0,a0		;goto pointer
	move.l	(a0),a1		;get address of EXE file
	movem.l	(a1),d0-d3	;move 16 bytes for good measure!
	movem.l	d0-d3,$200.w	;store at $200 for AUTORUN 4 to use

;Okay let's shut this baby down......
	move.b	old484,$484.w	;keyboard
	move.b	#8,$fffffc02.w	;mouse on
	move.l	old_base,a0	;put the OS screen back
	bsr	set_low_rez
	bsr	set_old_pal	;original colours

	tst.w	hertz_toggle	;did the user want 60Hz?
	beq.s	.hz50
	and.b	#%11111101,$ffff820a.w		;60Hz
.hz50	bsr	set_user	;boring mode

	ifeq	AUTORUN4
	bra	exec
	ENDC

	clr.w	-(sp)
	trap	#1

	ifeq	FINAL
********* shut the thing down to return to assembler *********
exit	jsr	ret_ints	;restore interrupts
	move.b	old484,$484.w
	move.b	#8,$fffffc02.w
	move.l	old_base,a0
	bsr	set_med_rez
	bsr	set_old_pal
	bsr	set_user
	clr.w	-(sp)		;exit
	trap	#1
	ENDC

do_reset
	move.w	4.w,-(sp)	;DELete key resets
	rts

zero	;flip hertz indicator...
	tst.w	hertz_delay
	bne	main_loop
	eor.w	#$002,font_pal
	eor.w	#-1,hertz_toggle
	move.w	#6,hertz_delay	;delay used to stop key being pressed too fast
	bra	main_loop


****************************
* Subroutines for the menu *
****************************

*******************************************************
* Bloody AN COOL only leaving 2 fuckin' address regs
*
* This is gonna take some serious shit to make it work but here goes
* for a 4 plane 8 pixel every VBL scroller......
*
* remember d0-d5/a0-a1 !!!!!! (how can I forget???)

scroll	move.l	scr_now,d4	;scroller position on screen
	add.l	#160*204,d4	;go into border

	move.l	scroll_pointer,a0	;pointer into ASCII
	move.l	a0,a1

	clr.w	byte_toggle	;always start on left of word
	moveq	#40,d5		;40 columns across screen
	move.w	char_offset,d2
next_char
	move.b	(a1),d3		;get a letter

	sub.w	#32,d3		;rid of ASCII bonds

	ext.w	d3		;same as AND.W #$ff,D3

	move.l	#font,store_a0	;set up due to lack of address regs
	move.l	a1,tmp2
	move.l	store_a2,a1
	move.b	(a1,d3),d1
	move.l	a1,store_a2
	move.l	tmp2,a1

	and.l	#$ff,d1		;mask off crap in letter offset
	mulu	#(32*4)*4,d1	;32 * 4 (4 planes)
	add.l	d1,store_a0

	move.w	d2,d1
	mulu	#(32*4),d1	;character depth * 4 (32*4)
	add.l	d1,store_a0

	move.l	a0,tmp4
	move.l	store_a0,a0
	move.l	a1,store_
.column
	move.l	d4,a1
OFF	set	0
	REPT	32		;scroller is 32 lines deep
	move.l	(a0)+,d0
	movep.l	d0,OFF(a1)
OFF	set	OFF+160
	ENDR
	move.l	store_,a1
	subq.w	#1,d5
	beq.s	.finish

	addq.w	#1,d4		;lower byte of word
	tst.w	byte_toggle
	beq.s	.skip		;if byte_toggle=0 then do next word
	addq.w	#6,d4		;else goto next word on screen
.skip	not.w	byte_toggle
	addq.w	#1,d2		;character offset
	and.w	#3,d2
	bne	.column

	move.l	tmp4,a0

	addq.w	#1,a1		;scroll pointer
	tst.b	(a1)		;is end of text?
	bpl	next_char	;NO!
	lea	scroll_text,a1	;do reset scrolline
	bra	next_char

.finish
	move.l	tmp4,a0
	addq.w	#1,char_offset
	and.w	#3,char_offset
	bne.s	.end
	addq.w	#1,a0
	tst.b	(a0)
	bpl.s	.end
	lea	scroll_text,a0
.end	move.l	a0,scroll_pointer
	rts


**********************
* Common subroutines *
**********************
set_super
	pea	0.w
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,save_stk
	move.l	usp,a0			;save usp
	move.l	a0,save_usp
	rts

set_user
	move.l	save_usp,a0
	move.l	a0,usp
	move.l	save_stk,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

vsync	move.w	#-1,vsync_flag
_vsyn	tst.w	vsync_flag			;wait for video
	bne.s	_vsyn
	rts


;A0=SOURCE PALETTE 	A1=TARGET PALETTE
fadein	move.w	#8-1,d6
	move.l	a1,a2
FADEIN1	lea	$ffff8240.w,a0	; TARGET IN A1
	move.w	#16-1,d7
FADEIN2	BSR.s	MODIFY
	addq.w	#2,a0
	addq	#2,a1
	dbf	d7,FADEIN2
	move.w	#4,d0
	BSR.s	WAIT
	move.l	a2,a1
	dbf	d6,FADEIN1
	rts

WAIT	bsr	v_sync
	DBRA D0,WAIT
	RTS

MODIFY	MOVE (A0),D0
	MOVE (A1),D1 ;TARGET
	MOVE D0,D4	;NEW COL
	MOVE D0,D2
	MOVE D1,D3
	AND #$7,D2
	AND #$7,D3
	CMP D2,D3
	BEQ.S MOK1
	BMI.S MDN1
	ADDQ #1,D4
	BRA.S MOK1
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




;*****************************************************
;* Okay all you STE freaks here is the important bit...
;*
;* I've put loads of comments in to help you change the settings
;* The BASS and TREBLE bit has a FULL breakdown of what bits do what
;* so you have no excuse for not changing them now.
;*
;* MAC SYS DATA 25/2/92
;*
;*****************************************************
init_ste
	move.l	#$20,replay_offset
	move.l	#$88ca,replay_isr_offset
	move.l	#ste_tracker,replay_rot
	move.w	#0,$ffff8900.w		*init. STE
	lea	setsam_dat(pc),a0
	move.w	#4-1,d0
mwwrite
	move.w	#$07ff,$ffff8924.w	;MICROWIRE mask register
mwwrite2
	cmp.w	#$07ff,$ffff8924.w	;wait for write state
	bne.s	mwwrite2
	move.w	(a0)+,$ffff8922.w	;MICROWIRE data register - make new values...
	dbra	d0,mwwrite

	move.l	#$486,temp
	move.b	temp+1,$ffff8903.w	;Frame address high
	move.b	temp+2,$ffff8905.w	;Frame address med
	move.b	temp+3,$ffff8907.w	;Frame address low

	move.l	#$488,temp
	move.b	temp+1,$ffff890f.w	;frame end address high
	move.b	temp+2,$ffff8911.w	;frame end address med
	move.b	temp+3,$ffff8913.w	;frame end address low

;if you change the frequency then you'll have to change the lookup tables...
	move.w	#%01,$ffff8920.w	;sound mode control
					;00  6258 Hz sample rate (reset state)
					;01 12517 Hz sample rate
					;10 25033 Hz sample rate
					;11 50066 Hz sample rate

	move.w	#%11,$ffff8900.w	;enable DMA sound
					;%00 - sound disabled (reset state)
					;%01 - sound enabled, disable at end of frame
					;%11 - sound enabled, repeat forever

	bra	init


setsam_dat
;this is complex but I'll try to make it simple....
;                     dd = always 10 cos that's the device output for GI tone chip
;                     ||xxx=master volume (%011 or can be left %101 or right %100)
;                     |||||yyyyyy=volume setting 000000 -80dB (sound off)
;                     |||||||||||                010100 -40dB
;                     |||||||||||                101???   0dB (??? doesn't matter)
	dc.w	%0000010011101000		;make full volume

;base + treble
;       z zzz
;	0 000 -12 dB
;	0 110   0 dB
;	1 100 +12 dB
;                     xx = always 10 cos that's the device output for GI tone chip
;                     ||yyy = define BASS (001) or TREBLE (010)
;                     |||||@@=don't matter
;                     |||||||zzzz=+12,0,-12Db (see table above)
;                     |||||||||||
	dc.w	%0000010010001100  	*treble  (+12 dB) 
	dc.w	%0000010001000110  	*bass    (  0 dB)
	dc.w	%0000000000000001  	*mixer	01=mix sound chip
					*       10=do not mix
					*       11=reserved

save_ints
	move.b	$fffffa07.w,mfpa07	;save interrupts
	move.b	$fffffa09.w,mfpa09
	move.b	$fffffa13.w,mfpa13
	move.b	$fffffa15.w,mfpa15
	move.b	$fffffa19.w,mfpa19
	move.b	$fffffa1f.w,mfpa1f
	move.l	$134.w,old134
	move.l	$70.w,old_70
	move.l	$120.w,old_120
	rts

init_ints
	move.w	#$2700,sr
	clr.b	$fffffa09.w		;init interrupts
	and.b	#$fe,$fffffa07.w	;isr off
	clr.b	$fffffa15.w
	move.w	module+$90,d0
	lea	mfp_freqs,a0
	move.b	(a0,d0.w),$fffffa1f.w
	move.b	#2,$fffffa19.w
	move.b	#32,$fffffa07.w
	move.b	#32,$fffffa13.w
	bclr	#3,$fffffa17.w	;auto isr ena at rte

	lea	replay_rot,a1
	move.l	(a1),a0
	add.l	replay_isr_offset,a0
	move.l	a0,dynamic_code+2
dynamic_code
	move.l	#0,$134.w

	move.l	#new_70,$70.w
	move.l	#new_120,$120.w

	or.b	#1,$fffffa07.w		;isr on
	or.b	#1,$fffffa13.w		;isr on
	move.w	#$2300,sr
	rts

mfp_freqs
	dc.b	24			;10 and 8.3 Khz
	dc.b	29
ret_ints
	eor.w	#$0700,sr
	move.b	mfpa07,$fffffa07.w	;restore interrupts
	move.b	mfpa09,$fffffa09.w
	move.b	mfpa13,$fffffa13.w
	move.b	mfpa15,$fffffa15.w
	move.b	mfpa19,$fffffa19.w
	move.b	mfpa1f,$fffffa1f.w
	move.l	old134,$134.w
	move.l	old_70,$70.w
	move.l	old_120,$120.w
	rts



v_sync	movem.l	d0-d3/a0-a3,-(sp)
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d0-d3/a0-a3
	rts


get_old_pal
	lea	$ffff8240.w,a0
	lea	old_pal,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts

get_screen_base
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,old_base
	rts

get_org_rez
	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,org_rez
	rts

set_org_rez
	move.w	org_rez,-(sp)
	bra.s	set_rez
set_low_rez
	clr.w	-(sp)
	bra.s	set_rez
set_med_rez
	move.w	#1,-(sp)
set_rez	move.l	old_base,-(sp)
	move.l	(sp),-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts

set_up
	move.l	#screens,d0
	clr.b	d0
	move.l	d0,scr_now
	move.l	d0,d1
	add.l	#39680,d1
	eor.l	d0,d1
	move.l	d1,scr_xor

	lea	pic+34,a0
	move.l	scr_now,a1
	move.l	a1,a2
	add.l	#39680,a2

	move.w	#32000/4-1,d0
sho	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	dbf	d0,sho

set_screen
	move.l	scr_now,d0
	move.l	scr_xor,d1
	eor.l	d1,d0
	move.l	d0,scr_now
	lsr.l	#8,d0
	lea	$ffff8201.w,a0
	movep.w	d0,(a0)
	rts

set_new_pal
	lea	pic+2,a0
	bra.s	set_pal
set_old_pal
	lea	old_pal,a0
set_pal	lea	$ffff8240.w,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts




**********************
* Interrupt routines *
**********************

new_70	clr.b	$fffffa1b.w
	movem.l	d0-d5/a0-a1,-(sp)	;save registers

	move.l	replay_rot,a1
	add.l	replay_offset,a1
	jsr	4(a1)

	clr.w	vsync_flag		;set video flag
	lea	pic+2,a1
	lea	$ffff8240.w,a0		;this could be quicker.... (movem.l)
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	movem.l	(sp)+,d0-d5/a0-a1	;pop registers
	tst.w	hertz_delay
	beq.s	.hertz_zero
	subq.w	#1,hertz_delay
.hertz_zero
	move.b	#199,$fffffa21.w	;set hbl isr at line 199
	move.b	#8,$fffffa1b.w		;ei isr
	rte


new_120
.not	tst.b	$ffff8209.w	;wait for raster to get to right hand side
	bne.s	.not

	clr.b	$ffff820a.w	;60Hz
	REPT	22
	nop
	ENDR
	move.b	#2,$ffff820a.w	;50hz
	move.w	font_pal,$ffff8240.w

	move.l	a0,-(sp)
	move.l	a1,-(sp)
	lea	font_pal+2,a0
	lea	$ffff8242.w,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.l	(sp)+,a1
	move.l	(sp)+,a0
	rte




******************************
	SECTION DATA
******************************
replay_offset		dc.l	$24	;default to STFM
replay_isr_offset	dc.l	$8918	;   "        "

font_pal	incbin	font.col

scroll_pointer	dc.l	scroll_text+7
scroll_text	dc.b	"                       "
 dc.b "   MAC SYS DATA OF PERSISTENCE OF VISION PRESENTS "
 dc.b "DISC 110  RELEASE DATE 6/4/92.     OH LORD PLEASE FORGIVE ME FOR I HAVE SINNED, "
 DC.B "I HAVE BROUGHT DISGRACE UPON MY FAMILY AND BROUGHT THE "
 DC.B "ALMIGHTY NAME OF P.O.V. DOWN TO THE RANKS OF MERE MORTALS.   "
 DC.B "    THE REASON FOR MY BEGGING IS THAT I HAVE BROKEN "
 DC.B "MY VOW OF NEVER USING A TCB MODULE ON A MENU....     EH?     "
 DC.B "YES INDEEDY THIS MENU IS PLAYING A TCB TRACKER MOD. "
 dc.b "This menu detects if you have an ste or not and plays the "
 dc.b "mod back in stereo if it can.      i've altered the STE "
 dc.b "bass and treble settings to have more treble and less bass, the "
 dc.b "result is a more tinny sound instead of the usual dull and muffled "
 dc.b "trash.         if you have a program that converts "
 dc.b "between noisetracker mods and TCB mods then get in touch "
 dc.b "via the address later on in the scroll text.    i can "
 dc.b "convert between tcb and noisetracker "
 dc.b "but not the other way around.        if nobody comes forward "
 dc.b "with such a program i'll have to bloody write one and i hate "
 dc.b "having to code utilities - hey mug uk there's a nice job "
 dc.b "for you.....           right here is the contact "
 dc.b "address....         MAC SYS DATA,      p.o.v.,      "
 dc.b "P.O. box 40,      thornton-cleveleys,      lancs.,      "
 dc.b "fy5 3ph,      uk.           "
 dc.b "and HERE ARE THE CREDITS.....       "
 DC.B "ALL CODING/FONT BY MAC SYS DATA,     GRAFIX FROM OZ     AND     MUSIC "
 DC.B "BY PHENOMENA (AMIGA CREW).       "
 dc.b "       if any of you coders had trouble putting the "
 dc.b "killing game show mod on a menu then take a look at the tempo "
 dc.b "setting as there is a bug in most replayers that ignores 2 "
 dc.b "tempo changes on the same line and most don't detect a tempo of zero......        "
 dc.b "      i wonder how many people wait with baited breath for the "
 dc.b "greetings to see if they are on but get all depressed when "
 dc.b "they aren't.         WELL I'LL PUT YOU OUT OF YOUR MISERY WITH THE GREETINGS."
 DC.B "      P.O.V. SENDS ITS GREETINGS TO      BART,   DEL,   MARTIAN,   "
 DC.B "BILBO,   MUK UK,   SPEED,   DELTA FORCE,   ADRENALIN,   DR. SYNE,   "
 DC.B "INNER CIRCLE,   ERIK PLANKTON AND BLIND BASTARD,   MEDWAY AND POMPEY BOYS "
 DC.B "(ARE YOU DEAD OR WHAT?),   NOW 5,   UTOS,   THE ENTERPRISE,   "
 DC.B "ELECTRONIC,   KGB,   THE FORCE,   PIXEL TWINS,   NOD,   ZOGG AND THE WATCHMEN,   "
 DC.B "SEWER SOFTWARE,   EMPIRE,   FACTORY,   REPLICANTS,   ETERNAL DEVELOPMENT,   "
 DC.B "HAPPENING BOIZ,   OXYGENE CREW,    GENESIS INC.,   MAD VISION,   "
 DC.B "CYNIX,   HOTLINE/MCA,   DELIGHT,   ALTAIR   AND   MR.X (thanks for all the bug reports).          "
 dc.b "if you have p.o.v. 105 and it says 'NOT STE' for vdu radiation then "
 dc.b "it is an old version.  I tested it on my 4 meg ste and it crashed just "
 dc.b "like non-compatible stos programs do so I automatically thought "
 dc.b "it wasn't compatible but I was wrong as it works on some ste machines.   "
 dc.b "Sorry to the people who got the old version but I can't test all "
 dc.b "discs on all st's.         we test p.o.v. discs on the following machines... "
 dc.b "     4 meg ste (tos 1.6),      1 meg stfm (tos 0.19),      "
 dc.b "1/2 meg stfm (tos 1.09),      1 meg stfm (tos 1.09)      and      "
 dc.b "2.5 meg stfm (tos 1.09).       I often try our discs on my amiga "
 dc.b "but they never work so that proves the amiga is a games machine!!!      "
 dc.b "speaking of the amiga, I should have mine back from commobore soon "
 dc.b "so i can start coding on it again.    i've knocked up a small "
 dc.b "tracker demo for a test and i think i've got the screen layout "
 dc.b "figured out so it shouldn't be long before p.o.v. go games machine "
 dc.b "busting.            if you are in a group that compiles "
 dc.b "software of any sort and are short of menu code then ask "
 dc.b "around as I have sent this menu code out to some contacts.  "
 dc.b "there seems to be quite a few people asking for my code so this "
 dc.b "should shut them up for a day or two.   for those of you who "
 dc.b "use my menu code, you may like to know that I have made this "
 dc.b "menu compatible with both autorun and normal menu p_exec. the "
 dc.b "menu uses conditional assembly so all you change is 1 equate and "
 dc.b "genst sorts it out.             thanks to all the foreign crews who "
 dc.b "are coding some screens for us and to kgb for passing them onto us.       "
 DC.B "     well I think I've said enough for now so i'll wrap it up here.     "
 dc.b "                                                                "
 DC.B $ff
	even

char_offset	dc.w	0
font		dcb.b	(32*4)*4,0
		incbin	font.fnt

;reference table for font - makes cross and multiple reference possible
; e.g. - make letters xyz appear as a logo on scroller, etc.
;        also make ' " ` appear as '
;        also make all lower & upper case appear in upper case
font_offsets
;          !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
 dc.b	0,39,43,00,00,00,00,43,40,41,45,00,42,46,28,46

;        0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @
 dc.b	29,30,31,32,33,34,35,36,37,38,00,00,00,00,00,44,00

;        A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q
 dc.b	01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17

;        R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  `  a  b  c
 dc.b	18,19,20,21,22,23,24,25,26,40,00,41,00,47,00,01,02,03

;        d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u
 dc.b	04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21

;        v  w  x  y  z
 dc.b	22,23,24,25,26

	even


key_codes	;enable lines to use more keys
	dc.b	2,0	;key 1
	dc.b	3,1
	dc.b	4,2
	dc.b	5,3	;key 4
	dc.b	6,4	;key 5
	dc.b	7,5	;key 6

	dc.b	$6d,0	;keypad 1
	dc.b	$6e,1
	dc.b	$6f,2
	dc.b	$6a,3	;keypad 4
	dc.b	$6b,4	;keypad 5
	dc.b	$6c,5	;keypad 6
	dc.b	$ff
	even

filenames	dc.l	exec1,exec2,exec3,exec4,exec5,exec6
exec1	dc.b	"$$",0
	even
exec2	dc.b	"charts_6",0
	even
exec3	dc.b	"factory",0
	even
exec4	dc.b	"ima",0
	even
exec5	dc.b	"phraqtal",0
	even
exec6	dc.b	"COPIER.POV",0
	even


pic	incbin	menu.pi1

replay_rot	dc.l	stfm_tracker

stfm_tracker	incbin	tracker.rot
	even
ste_tracker	incbin	trackere.rot
	even

module	incbin 	phenomen.mod
	even



***************************
	SECTION BSS
***************************
bssstart
temp		ds.l	1
byte_toggle	ds.w	1
store_a0	ds.l	1
store_a2	ds.l	1
tmp2		ds.l	1
tmp4		ds.l	1
store_		ds.l	1
old_pal		ds.b	32
old_base	ds.l	1
org_rez		ds.w	1
old_70		ds.l	1
old_120		ds.l	1
old134		ds.l	1
save_usp	ds.l	1
save_stk	ds.l	1
hertz_toggle	ds.w	1
hertz_delay	ds.w	1
vsync_flag	ds.w	1
old484		ds.b	1
mfpa07		ds.b	1
mfpa09		ds.b	1
mfpa13		ds.b	1
mfpa15		ds.b	1
mfpa19		ds.b	1
mfpa1f		ds.b	1
	even
black		ds.b	32
scr_now		ds.l	1
scr_xor		ds.l	1
	ds.b	1024
screens	ds.b	39680
	ds.b	39680
stopper
