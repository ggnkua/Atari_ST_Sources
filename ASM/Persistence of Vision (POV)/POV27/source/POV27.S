*************************************
*              POV 27               *
*              ------               *
* Written by                        *
*           MAC SYS DATA            *
*             22-7-90               *
*************************************
* Assemble with GENST2 v2.08 onward *
* Code assembled using GENST2 v2.21 *
*************************************


BUFFER_SIZE:	EQU	32*4
WIDTH:		EQU	32
BASE:		equ	$66000	;lower to 66000 for final assembly


	move.l	sp,a5
	move.l	4(a5),a5	;get basepage
	move.l	$C(a5),d0	;text segment
	add.l	$14(a5),d0	;data segment
	add.l	$1C(a5),d0	;unitialized
	add.l	#$100,d0	;basepage size
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move.w	d0,-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	add.l	#12,sp		;okay that's it memory free & allocated

	bsr	set_super
	bsr	wait_for_drive
	bsr	hide_cursor
	bsr	save_pal
	bsr	set_palette
	bsr	get_base
	move.l	#BASE,a0	;screen_base
	bsr	set_low_rez
	bsr	clear_below_screen
	bsr	set_for_border

*******************************
* Music from TCB soundtracker *
* Ripped by THE MEDWAY BOYS   *
*******************************

	move.b	$484.w,old484
	move.b	#2,$484.w		;no sound from IKBD
	moveq	#1,d0				music #1
	bsr	tune
	bsr	transfer

main_loop:
	bsr	vsync
;	move.w	#$123,$ffff8240.w

	move.w	speed_count,d0		;variable speed scroll
speed_loop:
	move.w	d0,-(sp)
	bsr	scroll
	move.w	(sp)+,d0
	dbf	d0,speed_loop

;	move.w	pic+2,$ffff8240.w

	move.b	$fffc02,d0
;	cmp.b	#01,d0		;escape ********************
;	beq	exit

	tst.w	key_delay
	beq.s	test_for_speed
	subq	#1,key_delay
	bra.s	on
test_for_speed:
	move.w	#6,key_delay
	cmp.b	#$4e,d0		;keypad +
	bne.s	not_plus
	cmp.w	#6,speed_count
	bgt.s	on
	addq	#1,speed_count
	bra.s	on
not_plus:
	cmp.b	#$4a,d0		;keypad -
	bne.s	on
	tst.w	speed_count
	ble.s	on
	subq	#1,speed_count


on:	cmp.b	#$b,d0		;0 key
	bne.s	not_zero
	tst.w	zero_counter
	bne.s	aa
	eor.w	#$222,pic+2
	eor.w	#$ffff,toggle
	move.w	#10,zero_counter
	bra	main_loop
not_zero:
	tst.w	zero_counter
	beq.s	car
aa:	subq	#1,zero_counter
car:	cmp.b	#2,d0		;1 key
	blt	main_loop
	cmp.b	#5,d0		;4 key
	bge	main_loop	
	move.l	d0,-(sp)
	bsr	isr_off
	move.l	old_base,a0	;screen_base
	bsr	set_low_rez
	move.l	(sp)+,d0

;key is in D0.L
	and.l	#$ff,d0
	lea	filenames,a6
	subq	#2,d0
	mulu	#14,d0
	add.w	d0,a6

	tst.w	toggle
	beq.s	hz50
	eor.b	#2,$ff820a
hz50:
	move.l	old_base,a0
	bsr	set_low_rez
	bsr	restore_pal
	bsr	show_cursor
	move.b	old484,$484.w

	lea	$ffff8240.w,a0	;clear colours
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.w	(a0)
	bsr	user_mode

	move.l	old_base,a0	;move filename to screen
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+

	clr.w	-(sp)
	move.w	#$4c,-(sp)
	trap	#1
	addq	#4,sp
	rts

exit:	bsr	isr_off
	move.l	old_base,a0
	bsr	set_med_rez
	bsr	restore_pal
	bsr	show_cursor
	move.b	old484,$484.w
	bsr	user_mode
	clr.w	-(sp)
	move.w	#$4c,-(sp)
	trap	#1
	addq	#4,sp
	rts


***************
* Subroutines *
***************
scroll:	
	tst.w	delay
	beq.s	carry_on
	subq	#1,delay
	rts
carry_on:
	move.l	line_ptr,a6
	cmp.b	#$7f,(a6)
	bne.s	no_delay
	addq.l	#1,line_ptr
	move.w	#320,delay
	rts
delay:	dc.w	0
no_delay:
	cmp.b	#$ff,(a6)
	bne.s	not_wrap_scroll
	lea	scroll_line,a6	;restart message
	move.l	a6,line_ptr

not_wrap_scroll:
	tst.w	scroll_number
	bne.s	loop2
	move.w	#WIDTH,scroll_number
	clr.l	d0
	move.b	(a6)+,d0
	move.l	a6,line_ptr
	sub.w	#32,d0
	mulu	#32*4,d0
	lea	font,a6
	add.l	d0,a6	;letter address is in a6
;transfer letter into buffer
	lea	buffer,a1
	move.w	#32*4,d0
.loop:	move.b	(a6)+,(a1)+
	dbf	d0,.loop

loop2:	move.l	#BASE+32000+480,a6
	move.l	a6,a2
	add.w	#152,a2
	lea	buffer,a1
;scroll buffer into right pixel of screen ready for scrolling
	move.w	#32-1,d1
loop
	roxl.w	2(a1)	;scroll
	roxl.w	(a1)	;letter
	move.w	sr,d0	;get the X flag (extra bit scrolled from letter)
	and.w	#1,d0	;mask off lowest bit
	or.w	d0,(a2)	;put onto screen
	sub.w	d4,d4	;clear carry flag to prevent crap appearing at top of letters
	addq	#4,a1	;increase buffer position
	add.w	#160,a2	;increase screen
	dbf	d1,loop


	move.w	#32-1,d0
loopy:	roxl.w	152(a6)
	roxl.w	144(a6)
	roxl.w	136(a6)
	roxl.w	128(a6)
	roxl.w	120(a6)
	roxl.w	112(a6)
	roxl.w	104(a6)
	roxl.w	96(a6)
	roxl.w	88(a6)
	roxl.w	80(a6)
	roxl.w	72(a6)
	roxl.w	64(a6)
	roxl.w	56(a6)
	roxl.w	48(a6)
	roxl.w	40(a6)
	roxl.w	32(a6)
	roxl.w	24(a6)
	roxl.w	16(a6)
	roxl.w	8(a6)
	roxl.w	(a6)
	sub.w	d4,d4	;clear X flag to stop wrapping.
	add.w	#160,a6
	dbf	d0,loopy
	subq	#1,scroll_number
	rts

set_super:
	clr.l	-(sp)		;set supervisor mode
	move.w	#32,-(sp)
	trap	#1
	addq	#6,sp
	move.l	d0,stack_save
	rts

user_mode:
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq	#6,sp
	rts

save_pal:
	lea	old_pal,a1
	lea	$ffff8240.w,a0
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
set_p:	lea	$ffff8240,a1
	move.w	#16-1,d0
set_pal:
	move.w	(a0)+,(a1)+
	dbf	d0,set_pal
	rts

get_base:
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,old_base
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
	lea	pic+34,a0
	move.l	#BASE,a1
	move.w	#32000/4-1,d0
d_pic:	move.l	(a0)+,(a1)+
	dbf	d0,d_pic
	rts

hide_cursor:
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

pause:	move.w	d0,-(sp)
	move.w	#1000,d0
.loop:	nop
	dbf	d0,.loop
	move.w	(sp)+,d0
	rts

clear_below_screen:
	move.l	#BASE+32000,a0
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

	MOVE.B	olda07,$FFFFFA07.w
	MOVE.B	olda09,$FFFFFA09.w
	MOVE.B	olda17,$FFFFFA17.w
	move.b	olda1b,$fffffa1b.w
	move.b	olda21,$fffffa21.w

	MOVE.W	#$2300,SR

endmusic:
	lea	$ff8800,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	rts

transfer:
	lea	pic+32034,a0	;Clear data at end of a DEGAS pic
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	move.l	#BASE,a0
	lea	pic+34,a1
	move.w	#200-1,d0
.loop1	bsr.s	vsync
	bsr.s	display_all
	add.w	#160,a0
	add.w	#160,a1
	dbf	d0,.loop1


display_all
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#160/4-1,d0
.loop1	move.l	(a1)+,(a0)+
	dbf	d0,.loop1
	lea	offset_table,a2
	move.w	#31,d0
.loop2	move.w	(a2)+,d2
	move.l	a1,a3
	add.w	d2,a3
	move.w	#160/4-1,d1
.loop3	move.l	(a3)+,(a0)+
	dbf	d1,.loop3
	dbf	d0,.loop2
	movem.l	(sp)+,d0-d7/a0-a6
	rts

vsync:	move.w	#$ffff,vsync_flag
vs:	tst.w	vsync_flag
	bne.s	vs
	rts

wait_for_drive:
wfd:	tst.w	$43e
	bne.s	wfd
	rts

*********
* ISRs  *
*********
vert_isr:
	movem.l	d0-d7/a0-a6,-(sp)	;preserve regs
	move.b	#49,counter	;49 lines at 4 pixels each ISR
	move.l	#horiz_isr,$120.W
	clr.w	vsync_flag

	bsr	tune+8

	movem.l	pic+2,d0-d7
	movem.l	d0-d7,$ffff8240.w

	movem.l	(sp)+,d0-d7/a0-a6
	move.w	pic+4,$ffff8242.w
	move.b	#8,$fffffa1b.w
	move.b	#3,$fffffa21.w
	RTE

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
	clr.b	$fffa1b		;DI all other interrupts
	movem.l	d0/a0,-(sp)
	lea	pal_table,a0
	move.w	#32-1,d0
col_loop:
	move.w	(a0)+,$ffff8242.w
	REPT 120
	nop
	ENDR
	dbf	d0,col_loop
	movem.l	(sp)+,d0/a0
	bclr	#0,$fffa0f
	rte
pal_table:
	dc.w	$001
	dc.w	$002,$003,$004,$005,$106,$207,$307,$407
	dc.w	$507,$607,$706,$705,$704,$703,$702,$701
	dc.w	$710,$720,$730,$740
	dc.w	$750,$760,$770,$671,$572,$473,$374,$275,$176,$077


********
* Data *
********
	SECTION DATA
zero_counter:	dc.w	0	;used as a delay for 50/60 hertz
speed_count:	dc.w	4
key_delay:	dc.w	6
old484:	dc.w	0
scroll_number:	dc.w	16
old_pal:	ds.b	32
stack_save:	dc.l	0
toggle:		dc.w	0	;hertz toggle
old70:	dc.l	0
old120:	dc.l	0
olda07:	dc.l	0
olda09:	dc.b	0
olda17:	dc.b	0
olda1b:	dc.b	0
olda21:	dc.b	0
	even
vsync_flag:	dc.w	0
old_base:	dc.l	0
counter:	dc.w	0

ei_mouse:	dc.b	$14,8
di_mouse:	dc.b	$12,$1a
buffer:		dcb.b	BUFFER_SIZE,0
	even
line_ptr:	dc.l	scroll_line
scroll_line:
 DC.B "WELCOME TO P.O.V.  27 ",$7F,"     MENU CODED BY MAC SYS DATA, ROLL ON SCREEN CODED "
 DC.B "BY BORIS AND MAC SYS DATA,  ART BY OZ, "
 dc.b "MUSIC BY MAD MAX FROM THE TCB SOUNDTRACKER.       PRESS + AND - ON THE KEYPAD FOR SPEED CONTROL.        GREETINGS TO "
 dc.b "THE MEDWAY BOYS (THANX TO ZIPPY FOR RIPPING THE MUSIC),  POMPEY PIRATES,  "
 dc.b "AUTOMATION,  THE DEMO CLUB,  SWSL,  THE REPLICANTS,  THE LOST BOYS,  MARTIAN,  THE SKUNK (HAVE YOU "
 DC.B "WRITTEN ANY MORE DEMOS FOR ME TO PACK?!!!!!!!),  EQUINOX  AND  DTB (A NEW PACKING CREW).      "
 dc.b "I DEDICATE THIS MENU TO A MATE (DARREN) WHO HAS RECENTLY BEEN KILLED IN A MOTORCYCLE ACCIDENT AT THE AGE OF 19 (R.I.P 19-7-90).  MAY ALL DOPEY CAR DRIVERS "
 DC.B "DIE A PAINFULL DEATH (ESPECIALLY ALL THOSE WHO ARE IN THE LANCASTER GOLF CLUB).                "
 DC.B "BORIS AND I HAVE JUST FINISHED WRITING A SOUNDTRACKER MENU FOR 'THE DEMO CLUB'.  IT "
 DC.B "ALLOWS YOU TO LOAD AND PLAY AMIGA SOUNDTRACKER FILES. THE DEMO CLUB WILL BE DISTRIBUTING DISCS FULL OF "
 DC.B "AMIGA MUSIC, IF YOU WANT SOME THEN WRITE TO...      THE DEMO CLUB     23 ALMA PLACE     SPILSBY     LINCS     PE23 5LB.        "
 DC.B "       IF THERE ARE ANY DEMO WRITERS OUT THERE READING THIS THEN PLEASE WRITE SOME GRAPHIC DEMOS OR SOME GOOD SAMPLED SOUND DEMOS "
 DC.B "THAT WILL WORK IN HALF MEG.  I'VE GOT LOADS OF DEMOS TO PUT ON P.O.V. DISCS BUT THEY'RE NEARLY ALL 1 MEG SAMPLES.    IF YOU THINK "
 DC.B "YOU CAN DO A DEMO BUT ARE STUCK FOR SOME MUSIC THEN GET IN TOUCH WITH THE DEMO CLUB AND ASK JOHN TO PASS YOUR ADDRESS ONTO ME (MAC SYS DATA), I'LL "
 DC.B "GET IN TOUCH AS SOON AS I CAN.         I SEE AUTOMATION ARE UPTO 299, IT'S A PITY THAT ALL THE GAMES DON'T WORK!  I WISH PEOPLE WOULD COPY "
 DC.B "DISCS CORRECTLY BECAUSE FOR THE LAST 6 MONTHS OR SO, ALL THE AUTOMATION DISCS I'VE RECEIVED HAVE BEEN CORRUPT. THE PATH FROM AUTOMATION TO ME ONLY GOES THROUGH 3 PEOPLE, "
 DC.B "SO EITHER AUTOMATION ARE PASSING DUFF COPIES OUT OR THE LAMERS AT CHORLEY "
 DC.B "CAN'T COPY!   I GET THE MEDWAY BOYS AND POMPEY PIRATES GAMES DISCS "
 DC.B "AND THEY'RE NEVER CORRUPT, ANYWAY I'M NOW THINKING OF TRASHING HALF MY AUTOMATION "
 DC.B "COLLECTION BECAUSE THEY PACK GAMES THAT WOULD BE SLAGGED OFF ON THE ZX81!    I'M NOT SLAGGING "
 DC.B "AUTOMATION BUT I THINK THEY'VE SACRIFICED QUALITY FOR QUANTITY.          "
 DC.B "I WONDER HOW MANY PEOPLE ACTUALLY READ ALL THE TEXT IN SCROLLERS.     "
 DC.B "THE REASON FOR MY QUERY IS THAT LATELY A FEW PEOPLE HAVE COMMENTED ON WHAT WAS SAID AT THE END "
 DC.B "OF SCROLLINES OF PREVIOUS P.O.V. DISCS.      WELL SO FAR I HAVE TYPED "
 DC.B "2K OF TEXT (WELL 2426 BYTES) WHICH IS QUITE A LOT TO READ WHEN THE CHARACTER SET "
 DC.B "IS AS LARGE AS THIS.       IF YOU'RE STILL READING THIS THEN HELLO TO OZ AND MARTIN THE MARTIAN! "
 DC.B "      OH YEH, HELLO JOHN FROM THE DEMO CLUB!                         "
 DC.B "  WHY ARE YOU LOT SITTING IN FRONT OF YOUR MONITOR (OR TV) READING THIS WHEN YOU "
 DC.B "COULD DEPACK THE FILE AND READ THE TEXT IN 80 COLUMN?   AN EVEN BETTER IDEA IS TO ASK ME "
 DC.B "FOR ALL THE SCROLLINES FROM ALL THE P.O.V MENUS ON A DISC AS ASCII FILES.        "
 DC.B "I WISH I HAD A TURBO BOARD FOR MY STFM BECAUSE IT TAKES AGES TO PACK SAMPLE FILES AND "
 DC.B "EVEN THEN THE FILE CAN GET LARGER.   IT WOULD BE A HELP IF I COULD PACK "
 DC.B "ST FILES ON THE AMIGA, THAT WAY I COULD PACK TWICE AS MUCH AS I DO NOW.  IF "
 DC.B "YOU'RE INTERESTED I PACK ON A 1040 STFM AND WRITE ON A 4160 (4 MEG) STE. "
 DC.B "I ALSO HAVE A 45 MEG HARD DISC WHICH HELPS FOR DEVELOPMENT.   I WONDER WHAT "
 DC.B "OTHER HACKERS AND PACKERS USE, I KNOW NIEL OF CB USES A MEGA 1 BUT I DON'T KNOW "
 DC.B "HOW MUCH MEMORY HE HAS.         IT HAS BEEN SAID THAT I REFER TO P.O.V. DISCS THAT "
 DC.B "HAVEN'T BEEN WRITTEN YET SO HERE GOES.... ON P.O.V. 32 THERE SHOULD BE A SAMPLED SOUND "
 DC.B "DEMO! AND ON 33 THERE SHOULD BE A COUPLE OF DEMOS, A MENU AND A TUNE!    HA-HA-HA-HA "
 DC.B "   TALKING OF FUTURE DISCS, I AM NOW STUCK FOR SMALL DEMOS (100-200K). "
 DC.B "I GET SENT QUITE A FEW SMALL ONES BUT THEY ALWAYS PACK TO ABOUT 50K SO I USE THEM UP "
 DC.B "IN ABOUT 2 MENUS.    YOU MAY SOON SEE THE P.O.V. FILLER DEMO 2 (THE SEQUEL) TO FILL UP "
 DC.B "A DISC.  I'VE GOT A COUPLE OF IDEAS FOR A DEMO BUT I CAN'T PUT TOO MANY "
 DC.B "INTO IT BECAUSE I'M TRYING TO WRITE SOME DEMOS FOR OUR MEGADEMO.   "
 DC.B "      HEY THIS SCROLLTEXT HAS NOW FILLED TWO AND A HALF PAGES IN GENST2 AND I'VE "
 DC.B "STILL GOT A LOT TO SAY.    THERE, I'VE JUST STARTED MY STFM PACKING A PET SHOP BOYS "
 DC.B "SAMPLE, IT'LL TAKE AGES 'COS THE SAMPLE IS OVER 500K.   HANDS UP ALL YOU FREAKS WHO "
 DC.B "HAVE GOT ALL THE P.O.V. DISCS.     YOU HAVE?     EVEN DISC 7?      WOW! I ACTUALLY "
 DC.B "COUNTED 3 PEOPLE THERE AND TWO OF THOSE ARE FROM PD LIBRARIES!     EVEN DR.SYNE AND BORIS "
 DC.B "HAVEN'T GOT ALL THE DISCS (I HAVE BECAUSE I WROTE 25 OUT OF THE LAST 26!).   THE STFM IS DOING "
 DC.B "WELL, IT'S UPTO 8 PERCENT.        FOR THE LAST TWO WEEKS I'VE BEEN OFF WORK ON HOLIDAY, ALL I DID WAS "
 DC.B "FINISH DISC 25 AND 26. I HAD PLANNED TO GOTO SPAIN BUT MY MATE BOTTLED OUT AND I COULDN'T "
 DC.B "FIND ANYONE ELSE WITH ANY MONEY.   THE TIME IS 16:53 ON 22-7-90 AND I'M LISTENING TO "
 DC.B "PHILIP SCOFIELD ON RADIO 1, BRUNO BROOKES WILL COME ON SOON WITH THE NEW CHART.  "
 DC.B "I AM BEGINNING TO RUN OUT OF THINGS TO WRITE.    I KNOW I'LL SAY A QUICK BIT ABOUT VDU 3.5.... "
 DC.B "WHEN YOU'VE LOADED THE PROGRAM, LOOK FOR THE PIXEL AT THE TOP RIGHT OF THE SCREEN.   "
 DC.B "FOUND IT?    NOW CLICK ON IT WITH THE MOUSE POINTER.....        HEY YOU'RE A GOOD "
 DC.B "VIRUS KILLER!        I HAVE RECEIVED VDU 3.9 (WELL AVK 3.9) BUT SOMEBODY HAS PACKED "
 DC.B "THE FILES WITH THE OLD JEK PACKER AND AS A RESULT IT WON'T PRINT THE TITLE PICTURE "
 DC.B "AND FIX THE BOOTSECTORS.  WHEN I GET HALF AN HOUR, I'LL DEPACK THE FILES AND REPACK "
 DC.B "THEM WITH 2.3R THEN I'LL WRITE A DEPACKER TO LOAD THE PROGRAM.    I SEE MORE PEOPLE "
 DC.B "ARE PACKING GAMES AND DEMOS, THE TROUBLE IS THAT YOU CAN GET THE SAME PROGRAM ON "
 DC.B "SEVERAL COLLECTIONS.   IN THE DEMO DEPARTMENT THERE ARE ABOUT 4 GROUPS DOING COMPILATIONS "
 DC.B "BUT WE'RE WAY AHEAD OF THE REST HAVING PACKED OVER 80 DEMOS TO DATE.  WE PACK "
 DC.B "DEMOS SO THEY STILL WORK IN HALF MEG AND HAVE A GOOD OUTLET FOR OUR DISCS SO WHY "
 DC.B "BOTHER WITH OTHER GROUPS DISCS WHEN P.O.V. DISCS ARE SO FREELY AVAILABLE?     OH MY "
 DC.B "GOD! I'M BEGINNING TO SOUND LIKE AUTOMATION...         WELL YOU KNOW WHAT I MEAN, IF "
 DC.B "WE GET SENT A DEMO AND IT'S PACKABLE THEN I'LL DO IT.  EVEN SOME OF THE DEMOS THAT "
 DC.B "WERE NOT PACKABLE BEFORE BECAUSE THEY LOADED "
 DC.B "FROM THE BOOT SECTOR (MEGABANG 2, ULTIMATE DEMO, OFFICIAL STE DEMO, ETC) "
 DC.B "HAVE BEEN HACKED AND A NEW LOADER WRITTEN BEFORE "
 DC.B "BEING PACKED.      I HAVE HAD A HACK AT THE CST DEMO 1 AND SO FAR "
 DC.B "I'VE GOT THE LOADER AND MENU WORKING AS FILES (A LOT OF WORK).  NEXT "
 DC.B "I'VE TO HACK THROUGH THE CODE AND LOOK FOR THE DMA LOADER IN THE MENU "
 DC.B "AND PATCH OVER IT WITH A NEW ONE TO LOAD FILES, THIS MAY BE A LITTLE "
 DC.B "HARDER THAN IT SOUNDS BUT I'LL HAVE A GO..      RIGHT THE STFM IS NOW ON "
 DC.B "20 PERCENT AND IT'S 17:06.   MY FINGERS ARE GETTING TIRED AND MY WRISTS ARE "
 DC.B "STARTING TO ACHE.....   TOMORROW (23-7-90) IT'S THE COMPUTER CLUB SO "
 DC.B "I'LL HAVE A CHANCE TO TEST DISCS 25 AND 26 ON A HALF MEG MACHINE.  "
 DC.B "I CAN GUARANTEE THAT THE FINGERBOBS NEW YEAR DEMO WILL NOT WORK ON "
 DC.B "A HALF MEG STE - I HOPE IT WORKS ON A HALF MEG STFM!      IF ANYBODY HAS "
 DC.B "A HALF MEG STE AND WOULD LIKE TO UPGRADE IT TO 1 MEG THEN GET IN TOUCH "
 DC.B "AS I HAVE 4 256K SIMMS FOR SALE.  I'LL SELL 2 SIMMS (HALF MEG TO 1 MEG) FOR "
 DC.B "THE SUPER LOW PRICE OF 35 POUNDS, IF YOU NEED MORE THAN 1 MEG THEN YOU WILL "
 DC.B "HAVE TO BUY SOME 1 MEG SIMMS FROM SOMEWHERE WHICH LEAVES YOU WITH SOME "
 DC.B "256K ONES TO SELL.   I UPGRADED TO 4 MEG BECAUSE IT WAS EITHER 2 OR 4 AND I "
 DC.B "FIGURED THAT I COULD USE A 1 MEG RAM DISC THEN LOAD MONST2 ABOVE THE RAM DISC "
 DC.B "AND USE IT TO HACK DEMOS THAT USE ALL 1 MEG - GOOD IDEA EH?   WELL IT WORKS "
 DC.B "'COS I'VE DONE IT, ALSO WITH 4 MEG RAM I CAN USE LOADS OF ACCESSORIES AND "
 dc.b "SAMPLE AN LP IN ONE GO (WELL NEARLY)!           YOU HAVE TO BE CAREFULL WHEN HACKING THROUGH DEMOS AS "
 DC.B "MOST DISABLE THE INTERRUPTS THAT DRIVE THE KEYBOARD ALSO A LOT OF CRAFTY "
 DC.B "ONES REVECTOR THE TRACE EXCEPTION TO A STRANGE ADDRESS WHICH THEN CRASHES "
 DC.B "MONST2.  THE CST DEMO FOR EXAMPLE HAS NO LESS THAN 24 TRACE EXCEPTION CLEARS "
 DC.B "AND IT ALSO USES THE TRACE EXCEPTION TO STORE VALUES THAT IT USES LATER ON, "
 DC.B "IF YOU SKIP OVER THESE INSTRUCTIONS THEN THE DEMO GETS THE WRONG VALUES "
 DC.B "AND ENDS UP CRASHING. ANOTHER NASTY TRICK USED LATELY IS TO REVECTOR THE "
 DC.B "ILLEGAL INSTRUCTION TO A CUSTOM EXCEPTION ROUTINE THEN EXECUTE AN ILLEGAL "
 DC.B "INSTRUCTION. THE ST GOES OOPS THAT'S ILLEGAL AND JUMPS TO THE NEW VECTOR "
 DC.B "WHICH LOADS THE DEMO OR GAME.  IT'S A BIT OF A BASTARD THING TO DO BUT "
 DC.B "YOU CAN GET AROUND IT QUITE EASILY..... BUT THAT'S ANOTHER STORY!      "
 DC.B "     I'M GETTING TIRED OF THIS TEXT SO I'LL WRAP IT UP HERE AND TRY TO "
 DC.B "FIND A DEMO THAT'S 210K LONG TO FILL THIS DISC UP.... BYE                 "
 DC.B "                   "
 dc.b	$ff,$ff
 dc.b "Hello hacker, I dedicate this menu to Aly's sister who is rather fancyable (is that"
 dc.b " an English word?)  Well I can say what I want here 'cos this bit will never appear "
 dc.b "in the scrolline. I am the best demo packer around (that's because nobody else can be "
 dc.b "bothered to do them!!!!).         bye. ",0

	even
font:	incbin	"lost.fon"
	even
tune:	Incbin	"tracker.mus"
	even

offset_table
	dc.w	160*($28+62),160*($28+56)
	dc.w	160*($28+52),160*($28+49)
	dc.w	160*($28+46),160*($28+44)
	dc.w	160*($28+42),160*($28+40)
	dc.w	160*($28+39),160*($28+38)
	dc.w	160*($28+37),160*($28+36)
	dc.w	160*($28+35),160*($28+34)
	dc.w	160*($28+33),160*($28+32)
	dc.w	160*($28+31),160*($28+30)
	dc.w	160*($28+29),160*($28+28)
	dc.w	160*($28+27),160*($28+26)
	dc.w	160*($28+25),160*($28+24)
	dc.w	160*($28+23),160*($28+21)
	dc.w	160*($28+19),160*($28+17)
	dc.w	160*($28+14),160*($28+11)
	dc.w	160*($28+7),160*($28+1)

filenames:
	dc.b	"ALIEN.MSD",0,0,0,0,0
	dc.b	"TNT2.EEK",0,0,0,0,0,0
	dc.b	"COPIER.POV",0,0,0,0
	even
cls:	dc.b	27,'E',0,0
	even
pic	incbin	"pov_boom.PI1"
	dcb.w	160*65,0
