***************************************************************
*                Persistence Of Vision disc 6                 *
*                ----------------------------                 *
*                                                             *
* Written by MAC SYS DATA and BORIS                           *
* Date: 10/12/89, added message to parrot demo 27/2/90        *
*                version 6.4 (I hope it bloody works)         *
* Date: 7/7/90, AUTO-RUN loading system added so BALLIT demo  *
*               is now compatable with ALL TOS version.       *
***************************************************************
	bra	go
 dc.b "HELLO, YOU CLEVER, CLEVER HACKER! (OR SHOULD I SAY 'PISS OFF YOU NOSEY BASTARD!) "
 DC.B "        WELL NOW YOU'RE HERE "
 DC.B "I EXPECT YOU'LL WANT THE TUNE.  IF SO, IT CAN BE FOUND AT THE END "
 DC.B "OF THE FILE AND IS 8696 BYTES LONG. TO INITIALIZE THE TUNE, LOAD REG D0 "
 DC.B "WITH THE TUNE NUMBER (0 OR 1) AND JSR TO THE TUNE START.  THE ISR FOR "
 DC.B "THE TUNE IS $E BYTES AFTER THE TUNE START.  THAT MEANS, IF YOU "
 DC.B "PUT THE TUNE ADDRESS +$E INTO $4D2 AFTER INITIALIZING THE TUNE, "
 DC.B "IT WILL START PLAYING.      TO STOP THE TUNE JUST CLR.L $4D2 AND "
 DC.B "POKE $FF8800 WITH $8080000 THEN $9090000 THEN $A0A0000.   SIMPLE "
 DC.B "EH?     I'VE GOT VURTUALLY ALL THE TUNES FROM THE AUTOMATION DISCS "
 DC.B "PLUS A FEW OF MAD MAX'S TUNES.  IF YOU ARE DESPERATE AND CANNOT "
 DC.B "STEAL THEM YOURSELVES THEN PHONE ME ON THE NUMBER GIVEN "
 DC.B "JUST BEFORE THE TUNE.      THAT'S IT FOLKS, BYE. (MAC SYS DATA)." 

BUFFER_SIZE:	equ	48*44
SPEED:		equ	2
go:
	move.l	sp,A5
	move.l	#save_stk,sp
	move.l	4(A5),A5	;get basepage
	move.l	$C(A5),D0	;text segment
	add.l	$14(A5),D0	;data segment
	add.l	$1C(A5),D0	;unitialized
	add.l	#$100,D0	;basepage size
	move.l	D0,-(sp)
	move.l	A5,-(sp)
	move.w	d0,-(sp)
	move.w	#$4A,-(sp)
	trap	#1
	add.l	#12,sp		;okay that's it memory free & allocated

	bsr	super_mode
	bsr	hide_cursor
	bsr	get_scr_base
	bsr	save_palette
	bsr	low_res
	bsr	set_palette
	or.b	#$2,$ff820a	;go into 50Hz

wait_for_drive:
	tst.w	$43e
	bne.s	wait_for_drive

	move.w	#$2700,sr
; Store original vector slots
	move.l	$120,hbc	;horiz blank counter timing vector
	move.l	$70,v_blank
	move.b	$FFFa09,a09
	move.b	$FFFa07,a07
	move.b	$FFFa13,a13
	and.b	#$DF,$FFFA09
	and.b	#$FE,$FFFA07
	move.l	#isr1,$120
	move.l	#isr2,$70
	or.b	#1,$FFFA07	;EI
	or.b	#1,$FFFA13	;EI
	move.w	#$2300,sr

	clr.l	$24
;****************************************************************
; There is more than one tune in this code....
; 0=AUTOMATION disc 85
; 1=AUTOMATION disc 80
; 2=Jingle
	move.l	#0,D0
	jsr	TUNE

	bsr	setup_screen
	bsr	reset_buffer
main_loop:
	bsr	vsync
;	move.w	#$123,$ff8240 
	move.w	#$060,$ff8242
	bsr	show_buffer
	bsr	reset_buffer
	bsr	scroll
;	clr.w	$ff8240
	bsr	check_key
	beq.s	main_loop

	move.w	#$ff,-(sp)
	move.w	#6,-(sp)
	trap	#1
	addq.l	#4,sp
	tst.l	d0
	beq.s	main_loop
	
	cmp.b	#$30,d0		;0 key
	bne.s	not_zero
	eor.b	#$2,$ff820a
	bra.s	main_loop
not_zero:
	cmp.b	#$20,d0		;space key
	beq	toggle_tune
;	cmp.b	#$1b,d0		;ESCape key
;	beq	ex
	cmp.b	#$31,d0		;1 key
	blt.s	main_loop
	cmp.b	#$37,d0		;7 key
	bge.s	main_loop	
	bsr	isr_off

;a valid key has been pressed so clear screen and palette.
bp:	move.l	d0,-(sp)
	bsr	cls
	move.l	(sp)+,d0
	sub.w	#49,d0
	and.l	#$ffff,d0
	mulu	#14,d0
	move.l	screen_base,a0
	add.w	#199*160,a0
	lea	filenames,a1
	add.w	d0,a1
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	clr.w	-(sp)
	trap	#1
	addq.l	#2,sp

ex:
	bsr	isr_off
	bsr	med_res
	bsr	restore_palette
	bsr	show_cursor
	bsr	user_mode
	move.w	#0,-(sp)
	trap	#1
	addq.l	#2,sp


toggle_tune:
	eor.w	#1,tune_no
	move.w	tune_no,d0
	jsr	TUNE
	bra	main_loop

***************
* Subroutines *
***************
isr_off:
	move.w	#$2700,sr
	move.l	v_blank,$70
	and.b	#$DF,$FFFA09
	and.b	#$FE,$FFFA07
	move.l	hbc,$120
	move.b	a07,$FFFa07
	move.b	a09,$FFFa09
	move.b	a13,$fffa13
	move.w	#$2300,sr
	lea	$ff8800,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	rts

scroll:
	lea	buffer,a0
	move.l	a0,a3
	move.l	line_ptr,a1
	lea	offset_table,a2
	move.w	offset_ptr,temp_offset
	moveq	#20,d0
loop1:	sub.l	d2,d2
	move.w	temp_offset,d2
	move.l	a3,a0
	add.w	0(a2,d2),a0
	moveq	#0,d6
	move.b	(a1)+,d6
	sub.b	#32,d6
	lsl.w	#5,d6
	lea	font,a6
	add.l	d6,a6
	moveq	#3,d7
loop2:	move.w	shift_size,d1
	sub.l	d2,d2
	move.l	d2,d3
	move.l	d2,d4
	move.l	d2,d5
	move.w (a6)+,d2
	move.w (a6)+,d3
	move.w (a6)+,d4
	move.w (a6)+,d5
	lsl.l	d1,d2
	lsl.l	d1,d3
	lsl.l	d1,d4
	lsl.l	d1,d5
	move.l	(a0),d1			; Write d2.
	or.l	d2,d1
	move.l	d1,(a0)
	move.l	44(a0),d1		; Write d3.
	or.l	d3,d1
	move.l	d1,44(a0)
	move.l	88(a0),d1		; Write d4.
	or.l	d4,d1
	move.l	d1,88(a0)
	move.l	132(a0),d1		; Write d5.
	or.l	d5,d1
	move.l	d1,132(a0)
	add.w	#176,a0
	dbf	d7,loop2
	addq.w	#2,a3
	move.w	temp_offset,d2
	addq.w	#2,d2
	cmp.w	#38*2,d2
	bne.s	loop6
	moveq	#0,d2
loop6:	move.w	d2,temp_offset
	dbf	d0,loop1
	add.w	#SPEED,shift_size
	cmp.w	#16,shift_size
	bne.s	loop3
	move.w	#0,shift_size
	add.l	#1,line_ptr
	cmp.l	#end_line-22,line_ptr
	bne.s	loop3
	move.l	#scroll_line,line_ptr
loop3:	subq.w	#2,offset_ptr
	bpl.s	loop4
	move.w	#37*2,offset_ptr
loop4:	move.l	back_pattern,d0
	lsr.l	#1,d0
	bcc.s	loop5
	bset	#31,d0
loop5:	move.l	d0,back_pattern
	rts


show_buffer:
	move.l	screen_base,a0
	add.w	#$5f00,a0
	move.l	#buffer+2,a1
	moveq	#47,d0
sho_buff_loop:
	movem.w	(a1)+,d2-d6/a2-a6
	move.w	d2,(a0)
	move.w	d3,8(a0)
	move.w	d4,16(a0)
	move.w	d5,24(a0)
	move.w	d6,32(a0)
	move.w	a2,40(a0)
	move.w	a3,48(a0)
	move.w	a4,56(a0)
	move.w	a5,64(a0)
	move.w	a6,72(a0)
	movem.w	(a1)+,d2-d6/a2-a6
	move.w	d2,80(a0)
	move.w	d3,88(a0)
	move.w	d4,96(a0)
	move.w	d5,104(a0)
	move.w	d6,112(a0)
	move.w	a2,120(a0)
	move.w	a3,128(a0)
	move.w	a4,136(a0)
	move.w	a5,144(a0)
	move.w	a6,152(a0)
	add.w	#160,a0
	addq.w	#4,a1
	dbf	d0,sho_buff_loop
	rts


reset_buffer:
	lea	buffer,a0
	move.l	back_pattern,d2
	move.l	d2,d3
	move.l	d2,d4
	move.l	d2,d5
	move.l	d2,a2
	move.l	d2,a3
	move.l	d2,a4
	move.l	d2,a5
	move.w	#BUFFER_SIZE/64-1,d0
wipe:	movem.l	d2-d5/a2-a5,(a0)
	add.w	#32,a0
	movem.l	d2-d5/a2-a5,(a0)
	add.w	#32,a0
	dbf	d0,wipe
	rts

vsync:	move.w	#1,vsync_flag
vsyn:	tst.w	vsync_flag
	bne.s	vsyn
	rts

check_key:
	move.w	#11,-(sp)
	trap	#1
	addq.w	#2,sp
	tst.w	d0
	rts

setup_screen:
	move.l	screen_base,a1
	lea	pic+34,a0
	move.w	#32000/4-1,d0
setup:	move.l	(a0)+,(a1)+
	dbf	d0,setup
	rts

wait_for_key:
	move.w	#7,-(sp)
	trap	#1
	addq.w	#2,sp
	rts

get_scr_base:
	move.w	#3,-(sp)
	trap	#14
	addq.w	#2,sp
	move.l	d0,screen_base
	rts

super_mode:
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.w	#6,sp
	move.l	d0,save_stk
	rts

user_mode:
	move.l	save_stk,-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.w	#6,sp
	rts

save_palette:
	lea	$ff8240,a0
	lea	old_palette,a1
	bra.s	change_palette

restore_palette:
	lea	old_palette,a0
	lea	$ff8240,a1
	bra.s	change_palette

set_palette:
	lea	pic+2,a0
	lea	$ff8240,a1

change_palette:
	moveq	#15,d0
change_pal:
	move.w	(a0)+,(a1)+
	dbf	d0,change_pal
	rts

low_res:
	clr.w	d0
	bra.s	change_res

med_res:
	moveq	#1,d0
change_res:
	move.w	d0,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.w	#12,sp
	rts

hide_cursor:
	move.w	#-1,-(sp)
	move.w	#0,-(sp)
	move.w	#21,-(sp)
	trap	#14
	addq.w	#6,sp
	pea	di_mouse
	move.w	#$2-1,-(sp)
	move.w	#$19,-(sp)
	trap	#14
	addq.l	#8,sp
	rts

show_cursor:
	pea	ei_mouse
	move.w	#$2-1,-(sp)
	move.w	#$19,-(sp)
	trap	#14
	addq.l	#8,sp
	rts

isr1:	
	add.w	#1,line_count
	cmp.w	#151,line_count
	bgt.s	alt_isr1
	bclr	#0,$fffa0f		;EI
	rte
alt_isr1:
	move.l	a0,-(sp)
	move.l	isr_data,a0
	move.w	(a0)+,$ff8242
	move.l	a0,isr_data
	move.l	(sp)+,A0
	move.b	#0,$FFFA1B
	move.b	#1,$FFFa21		;1 line of each colour.....
	move.b	#8,$FFFA1B		;HBC timer
	bclr	#0,$FFFA0F	;EI
	rte

isr2:	;$70
	move.l	a0,-(sp)
	lea	isr_data,a0
	move.l	#b_line,(a0)
	move.l	(sp)+,a0
	clr.w	line_count
	jsr	TUNE+$e

	bsr.s	VU
	tst.w	vsync_flag
	beq.s	flag_notset
	sub.w	#1,vsync_flag
flag_notset:
	move.b	#0,$FFFA1B	;reset timer B
	move.b	#1,$FFFA21
	move.b	#8,$FFFA1B
	rte

; ISR to animate the VU METER
VU:	movem.l	d3-d7/a4-a6,-(sp)
	move.b	#$8,$ff8800	;chan A
	move.b	$ff8800,d7
	move.l	screen_base,a6	;screen always in A6
	add.w	#104,a6
	bsr.s	METER
	move.b	#$9,$ff8800	;chan B
	move.b	$ff8800,d7
	add.w	#16,a6
	bsr.s	METER
	move.b	#$a,$ff8800	;chan C
	move.b	$ff8800,d7
	add.w	#16,a6
	bsr.s	METER
	movem.l	(sp)+,d3-d7/a4-a6
	rts
;This part fills the VU meter with lines then clears the lines
;from top to bottom depending on the volume level of the sound channel.
METER:	tst.b	d7
	blt.s	exisr	;less than no volume!
	and.w	#$FF,d7
	move.l	a6,a4		;screen base
;----------------------FILL VU METER WITH GREEN---------------
	add.l	#160*85+8,a4	;bottom of VU meter
	move.w	#13-1,d3
FILL:	or.w	#$3ffc,(a4)	;fill the VU meter
	or.w	#$3ffc,320(a4)
	sub.w	#640,a4
	dbra	d3,FILL
;-------------------------------------------------------------
	move.w	d7,d5		;invert chan amp by SUB from max volume.
	move.w	#15,d6
	sub.w	d5,d6
	move.w	a6,a4		;put screen addr into a4
	add.w	#160*85+8,a4	;make a4 point to bottom of VU
	move.l	a6,a5		;get screen start.
	add.l	#160*29+8,a5	;top of VU meter.
	cmp.w	#1,d6		;is second to top ready to be filled
	beq.s	not_top
	blt.s	fill_top
	and.l	#$80018001,(a5)
	and.l	#$80018001,320(a5)
	and.l	#$80018001,640(a5)
	and.l	#$80018001,960(a5)
	subq.w	#1,d6
;----------------------CLEAR VU METER FROM TOP----------------
CLEAR:	and.w	#$8001,(a5)
	and.w	#$8001,320(a5)
	add.w	#640,a5
	dbra	d6,CLEAR 
exisr:	rts
;----------------------TOP IS ACTIVE SO MAKE RED--------------
fill_top:
	or.w	#$3FFc,2(a5)	;fill with red
	or.w	#$3FFc,322(a5)	;fill with red
not_top:
	or.w	#$3FFc,642(a5)	;fill with red
	or.w	#$3FFc,962(a5)	;fill with red
	rts
cls:	pea	cls_mess
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts
cls_mess:
	dc.b	27,'E',0,0

********
* Data *
********
back_pattern:
	dc.l	$01800180

temp_offset:
	dc.w	0

offset_ptr:
	dc.w	0

offset_table:
	dc.w	1408,1276,1144,1056,924,836,704,616
	dc.w	528,440,352,264,220,132,88,44
	dc.w	0,0,0,0,0,0,0,44
	dc.w	88,132,220,264,352,440,528,616
	dc.w	704,836,924,1056,1144,1276

shift_size:
	dc.w	0
di_mouse:
	dc.b	$12,$1a
	even
ei_mouse:
	dc.b	$14,$08
	even
hbc:	dc.l	0
v_blank:	dc.l	0
a09:	dc.l	0
a07:	dc.l	0
a13:	dc.l	0
	even
tune_no:
	dc.w	0
vsync_flag:
	dc.w	0
line_count:
	dc.w	0	;count of horizontal line down screen for ISR1
isr_data:
	dc.l	0
b_line:
	DC.W	$070,$170,$270
	dc.w	$370,$470,$570,$670,$770,$760,$750,$740
	dc.w	$730,$720,$710,$700,$701,$702,$703,$704
	dc.w	$705,$706,$707,$607,$507,$407,$307,$207
	dc.w	$107,$007,$017,$027,$037,$047,$057,$067
	dc.w	$077,$076,$075,$074,$073,$072,$071,$070
	dc.w	$060,$050,$040,$030,$020
	even
old_palette:
	ds.b	32

buffer:
	ds.w	BUFFER_SIZE

screen_base:
	dc.l	0

	ds.l	100
save_stk:
	dc.l	0
	even
line_ptr:	dc.l	scroll_line
scroll_line:
 dc.b "                        HELLO                 "
 dc.b "MAC SYS DATA HERE BRINGING YOU SOME MORE PACKED AND REWORKED "
 DC.B "DEMOS.        THE FIRST THING TO NOTE IS THE ALL NEW INTRO, IT WAS "
 dc.b "CODED BY MAC SYS DATA AND BORIS TO GET AWAY FROM THE "
 dc.b "BORING 'WHAT NOTHING MOVING INTRO' WE USED ON OUR PREVIOUS DISCS."
 dc.b "            "
 dc.b "P.O.V. ARE . . . .          "
 dc.b "MAC SYS DATA              BORIS              DR.SYNE"
 DC.B "              AND ALY          "
 DC.B "   IF YOU DIDN'T NOTICE, WE HAVE A NEW MEMBER, HIS NAME IS BORIS "
 dc.b "AND HE WROTE THE SCROLLER FOR THIS INTRO "
 DC.B " (GOOD, ISN'T IT?)....................  "
 dc.b "WE SEND OUR GREETINGS TO ...       "
 dc.b "AUTOMATION       "
 dc.b "THE BLADERUNNERS       "
 dc.b "THE UNION       "
 dc.b "ALAN.R       "
 DC.B "AND       "
 dc.b "THE REPLICANTS          "
 dc.b "THE TUNE WAS STOLEN FROM ZOMBI BY MAC SYS DATA."
 dc.b "    PRESS THE SPACE-BAR TO TOGGLE BETWEEN THE TWO TUNES."
 dc.b "                "
 dc.b "SOME OF THE FILES ON THIS DISC HAVE BEEN PACKED WITH "
 DC.B "THE HAPPY PACKER BECAUSE THE JON PACKER (LSD VERSION 1.0) "
 DC.B "ACTUALLY INCREASED SOME OF THE SAMPLE FILE LENGTHS.        "
 dc.b "THE RESULT IS THE SAME, SMALLER FILES "
 DC.B "AND A NICE MENU TO LOOK AT.......     "
 dc.b "LOOKING INTO THE FUTURE OF P.O.V. I CAN SEE A DISC 7 VERY SOON AND "
 dc.b "THEN A BIT OF A DELAY... THE REASON BEING LACK OF DEMOS COMING OUR "
 dc.b "WAY.  IF YOU WANT MORE DEMOS ON "
 DC.B "MENUS THEN GET SENDING SOME TO US IN BLACKPOOL.  "
 DC.B "         A LOT OF THE RECENT DEMOS HAVE BEEN SAMPLE ONES, THESE "
 dc.b "POSE THE HARDEST ONES TO PACK "
 DC.B "AS THE DATA IS IN NO UNIFORM ORDER. THE GOOD NEWS IS, WE ARE "
 dc.b "WORKING ON A NEW PACKER SPECIALLY WRITTEN TO PACK SAMPLES.         "
 dc.b "     WELL IT'S 1 MINUTE PAST 11 PM ON THE 26TH OF SEPTEMBER AND "
 DC.B "I'VE NEARLY FINISHED THIS MENU. I SUPPOSE I'D BETTER GET SOME SLEEP"
 DC.B " TONIGHT AS IT'S THE PCW SHOW TOMORROW FOR SOME OF US WHO GET FREE "
 DC.B "TRADE TICKETS THAT IS.      I WONDER WHO I'LL SEE...  I TRIED TO "
 DC.B "PHONE BORIS UP BUT HE DIDN'T ANSWER, I EXPECT HE'S AT HIS LOCAL "
 DC.B "PUB GETTING STONED DOWN IN MANCHESTER AND HERE I AM, SLAVING OVER "
 DC.B "A HOT ST WITHOUT A BREW IN SIGHT.      DID YOU KNOW, I'VE BEEN "
 DC.B "WORKING SO HARD ON THIS MENU THAT I HAVN'T BEEN TO THE COMPUTER "
 DC.B "CLUB FOR 5 WEEKS AND THAT I HAVN'T BEEN OUT TO THE PUB FOR A "
 DC.B "SERIOUS DRINKING SESSION FOR 2 MONTHS?     OH, I COULD MURDER A "
 DC.B "PINT OF NEWCASTLE BROWN ALE, STRAIGHT FROM THE BOTTLE (AS WE "
 DC.B "BIKERS DO).       "
 dc.b "   WELL THAT'S ABOUT IT FOR THIS ONE, I REALLY MUST GO BECAUSE "
 DC.B "I RECIEVED MY ST FORMAT TODAY WITH A DEMO OF XENON II ON IT AND I "
 DC.B "WANT TO STEAL THE TUNE BEFORE I GET SOME SHUT EYE - BYE..."
 dc.b "............"
 dc.b ".............................. >>>                     "
 DC.B "                               <<<                     "
end_line:
	even
pic:	incbin	"pov6.pi1"
	even
font:
	dcb	0,16
set:	incbin	"big_set.img"
	even
	DC.B	"PHONE (0253) 700382 AND ASK FOR MARK."
	EVEN
TUNE:	incbin	"was85i.img"
	even

filenames:
spaceace:	dc.b	"SPACEACE.MSD",0,0
starwars:	dc.b	"STARWARS.MSD",0,0
balldemo:	dc.b	"BALLDEMO.MSD",0,0
globe:		dc.b	"XXXGLOBE.MSD",0,0
bird:		dc.b	"BIRD.MSD",0,0,0,0,0,0
manyboink:	dc.b	"MANYBOIN.MSD",0,0
