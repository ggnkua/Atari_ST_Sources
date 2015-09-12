;
; Ripped Off Overscan Intro 1
;
; Border-cide by Griff
; Rest of Code by Obers.   31/3/91
; Music by Count Zero
;
; Nothing spectacular. But quite nice!
;
;

; 2009/01/22	AJB		Verified buildable under Devpac3
;						Verified working under Steem 3.2
;						Config: 8MHz 1Mb TOS 1.04 

	section	text

OFFSET	equ $e6		; Overscan line length
SLINE	equ 170		; Scan line to start text output

PDS	equ	0

	IFNE	PDS
	ORG	$6000
	;DC.L	START
	ENDC

start
	IFEQ	PDS
	CLR.L -(SP)
	MOVE #$20,-(SP)
	TRAP #1
	ADDQ.L #6,SP
	move.l	d0,old_ssp
	move.w	#4,-(a7)
	trap	#14
	addq.l	#2,a7
	move.w	d0,old_res
	move.w	#2,-(a7)
	trap	#14
	addq.l	#2,a7
	move.l	d0,old_physbase
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,save_pal
	ENDC

	movem.l	blank,d0-d7
	movem.l	d0-d7,$ffff8240.w

	jsr reset_frame
	jsr clear_screen
	jsr draw_screen
	move.l	#1,d0
	jsr music

	movem.l	screen+2,d0-d7
	movem.l	d0-d7,$ffff8240.w

	MOVE #$2700,SR
	LEA my_stack+1024,SP
	MOVE.L #$70000,D5
set_scrn
	LSR #8,D5
	MOVE.L D5,$FFFF8200.W
set_ints
	JSR flush
	MOVE.B #$12,$FFFFFC02.W
	LEA old_mfp,A0
	MOVE.B $FFFFFA07.W,(A0)+
        MOVE.B $FFFFFA09.W,(A0)+
	MOVE.B $FFFFFA13.W,(A0)+
        MOVE.B $FFFFFA15.W,(A0)+
        MOVE.B $FFFFFA19.W,(A0)+
        MOVE.B $FFFFFA1F.W,(A0)+
        MOVE.B #$20,$FFFFFA07.W
        MOVE.B #0,$FFFFFA09.W
        MOVE.B #$20,$FFFFFA13.W
	CLR.B $FFFFFA15.W
	CLR.B $FFFFFA19.W
	MOVE.L $68.W,old_phbl
	MOVE.L $70.W,old_vbl
	MOVE.L $134.W,old_tmra
	MOVE.L #overscan,$134.W
	MOVE.L #first_vbl,$70.W
	STOP #$2300

wait_key
	CMP.B #$39,$FFFFFC02.W
	BNE.S wait_key

restore	MOVE #$2700,SR
	LEA old_mfp,A0
	JSR flush
	MOVE.B #$8,$FFFFFC02.W
	MOVE.B (A0)+,$FFFFFA07.W
        MOVE.B (A0)+,$FFFFFA09.W
        MOVE.B (A0)+,$FFFFFA13.W
        MOVE.B (A0)+,$FFFFFA15.W
        MOVE.B (A0)+,$FFFFFA19.W
        MOVE.B (A0)+,$FFFFFA1F.W
	MOVE.L old_phbl,$68.W 
	MOVE.L old_vbl,$70.W
	MOVE.L old_tmra,$134.W 
	MOVE #$2300,SR

	move.l	#0,d0
	jsr music

	IFEQ	PDS
	movem.l	save_pal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.w	old_res,-(a7)
	move.l	old_physbase,-(a7)
	move.l	(a7),-(a7)
	move.w	#5,-(a7)
	trap	#14
	lea	12(a7),a7
	move.l	old_ssp,-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	CLR -(SP)
	TRAP #1
	ELSE
	move.w	#$2700,sr
	jmp	$148.w
	ENDC

first_vbl
	move.l	#vbl,$70.w			VBL Vector
	addq	#1,vbl_timer
	RTE
			
vbl	clr.b	$fffffa19.w			Timer A Control		Stop Timer
	move.b	#99,$fffffa1f.w		Timer A Data		
	move.b	#4,$fffffa19.w		Timer A Control		Start Timer, /50 mode
	move.l	#overscan,$134.w	Timer A Vector

	addq	#1,vbl_timer

	movem.l	d0-d7/a0-a6,-(a7)

	jsr		raster_config
	jsr		next_letter
	jsr		music+6
	
	movem.l	(a7)+,d0-d7/a0-a6
	rte

* The Full Overscan routine!

; Macros: The following vars are required to be set
; a0	$ff820a		Video Sync Mode 
; a1	$ff8260		Shift Mode
; d3	2			60 Hz / High Res
; d4	0			50 Hz / Low Res

Set50Hz macro
	move.b d4,(a0)			; 8c
	endm

Set60Hz macro
	move.b d3,(a0)			; 8c
	endm
	
SetLowRes macro
	move.b #0,(a1)			; 12c
	endm

SetHighRes macro
	move.b d3,(a1)			; 8c
	endm

overscan
	move.l	#phbl,$68.w			HBL Vector
	
	stop	#$2100				Top border synchronisation
	stop	#$2100				Top border synchronisation

	move	#$2700,sr			(12c)

	movem.l	d0-d7/a0-a1,-(sp)	(58c)
	
	clr.b	$fffffa19.w			(16c)

	dcb.w	59,$4e71

	move.b	#0,$ffff820a.w		(16c)		Video synchronization mode			60Hz

	dcb.w	16,$4e71
	
	move	#$8209,a0			(12c) 8c?	Video address pointer (Low byte)

	move.b	#2,$ffff820a.w		(16c)		Video synchronization mode			50Hz
	
	move.l	use_at,a2		; RASTERS
	move.l	use_at2,a3		; RASTERS

syncloop
	move.b	(a0),d1				Spin while counter is 0
	beq.s	syncloop
	
	moveq	#22,d2
	sub		d1,d2
	lsl		d2,d1				(6c+ n*2c)
	
	moveq	#23,d1
delayloop1
	dbf		d1,delayloop1

	move	#$820a,a0
	move	#$8260,a1
	moveq	#2,d3
	moveq	#0,d4
	
	nop

* Overscan both sides of main screen

lineloop
	rept	228

	move.w	(a3)+,$ffff8242.w	; RASTERS (16 cycles/4 nops)
	move.w	(a2)+,$ffff8244.w	; RASTERS

	dcb.w	4,$4e71				

	SetHighRes
	SetLowRes

	dcb.w	89,$4e71	

	Set50Hz
	Set60Hz

	dcb.w	13,$4e71

	SetHighRes
	SetLowRes
	
	endr

BOT_BORD
	move.b d4,(a0)
	move.w	(a3)+,$ffff8242.w	; RASTERS
	move.w	(a2)+,$ffff8244.w	; RASTERS
	dcb.w	8-6,$4e71
	move.b d3,(a1)
	move.b #0,(a1)
	move.b d3,(a0)
	dcb.w 87,$4e71
	move.b d4,(a0)
	move.b d3,(a0)	
	dcb.w 13,$4e71	
	move.b d3,(a1)
	move.b #0,(a1)
	
	rept 36
	move.w	(a3)+,$ffff8242.w	; RASTERS
	move.w	(a2)+,$ffff8244.w	; RASTERS
	dcb.w	12-8,$4e71	
	move.b d3,(a1)
	move.b #0,(a1)
	dcb.w 89,$4e71
	move.b d4,(a0)
	move.b d3,(a0)	
	dcb.w 13,$4e71
	move.b d3,(a1)
	move.b #0,(a1)
	endr

	movem.l	(sp)+,d0-d7/a0-a1
	bclr.b	#5,$fffffa0f.w
	rte

phbl	
	rte

* Flush keyboard

flush	
	btst.b #0,$fffffc00.w
	beq.s flok
	move.b $fffffc02.w,d0
	bra.s flush
flok	
	rts

save_pal	ds.w	16
vbl_timer	ds.w 1
old_vbl		ds.l 1
old_tmra	ds.l 1
old_phbl	ds.l 1
old_mfp	ds.l 4
		
	even

clear_11 dc.b "                                                        ",-1
clear_10 dc.b "                                                        ",-1
clear_9	dc.b "                                                        ",-1
clear_8	dc.b "                                                        ",-1
clear_7	dc.b "                                                        ",-1
clear_6	dc.b "                                                        ",-1
clear_5	dc.b "                                                        ",-1
clear_4	dc.b "                                                        ",-1
clear_3	dc.b "                                                        ",-1
	dc.b "                                                        ",-1
	dc.b "                                                        ",-1
	dc.b 0

	     ;----					        ------
	     ;12345678901234567890123456789012345678901234567890123456
message_01
	dc.b "                       AND                              ",-1
	dc.b "                                                        ",-1
	dc.b "  ++++ @+++ @+   + @++++ @++++ @+++  @+++  @ ++  @+++  @ +++@     ",-1
	dc.b "  +    @ +  @++  + @+    @+    @+  + @+  + @+  + @+  + @+   @     ",-1
	dc.b "  ++   @ +  @+ + + @+ ++ @++   @+++  @+++  @+  + @+++  @ ++ @     ",-1
	dc.b "  +    @ +  @+  ++ @+  + @+    @+ +  @+  + @+  + @+  + @   +@     ",-1
	dc.b "  +    @+++ @+   + @++++ @++++ @+  + @+++  @ ++  @+++  @+++ @     ",-1
	dc.b "                                                        ",-1
	dc.b "                  Proudly Present                       ",-1
	dc.b "                                 ",-1
	dc.b 0
message_0
	dc.b "@                                                        ",-1
	dc.b "      BRAIN OVERDRIVE HYPERDIMENSIONAL OVERSCAN         ",-1
	dc.b "                    NANO-INTRO                          ",-1
	dc.b "                                                        ",-1
	dc.b "        ( Please do not adjust your monitor )           ",-1
	dc.b "                                 ",-1
	dc.b 0

message_1
	dc.b "@     CREDITS..............                              ",-1
	dc.b "                                                        ",-1
	dc.b "     @CODE       - @OBERJE' ( FINGERBOBS )                ",-1
	dc.b "     @BORDERCIDE - @GRIFF ( INNER CIRCLE )                ",-1
	dc.b "     @MUSIX      - @COUNT ZERO ( INNER CIRCLE )           ",-1
	dc.b "     @GRAFIX     - @STICK ( RIPPED OFF ) & WIZ            ",-1
	dc.b "                                                        ",-1
	dc.b "                                 ",-1
	dc.b 0

message_2
	dc.b "   ""SCROLLTEXT"" CREATED BY OBERJE & STICK               ",-1
	DC.B "   This funky little intro/menu/whatever was            ",-1
	dc.b "   created at @RIPPED OFF@ Subdivisional HQ.              ",-1
	dc.b "   ( This means STICK's house! ).                       ",-1
	dc.b "                                                        ",-1
	dc.b 0

message_3
	dc.b "   Eeee, by 'eck! Is that Oberje' bloke on thy          ",-1
	dc.b "   keyboooooard? .................. Yes!                ",-1
	dc.b "                                                        ",-1
	dc.b "   Hoots mon! It's me! And I'm @%$&%^$^-ed@ if I          ",-1
	dc.b "   can think of anything to speak of. So as usual       ",-1
	dc.b "   here is a right pile of shite........                ",-1  
	dc.b "                                                        ",-1
	dc.b 0

message_4
	dc.b "   Well, anyway my little cherubs, let me tell of       ",-1
	dc.b "   my fabbo most exquisite adventures in @Ripped-        ",-1
	dc.b "   Off-Land@...............                              ",-1
	dc.b "                                                        ",-1
	dc.b 0

message_5
	dc.b "   T'was a crisp March morning when I set out and       ",-1
	dc.b "   boarded a delightful 125 Intershitty train from      ",-1
	dc.b "   the glorious loins of wonderous British-Wankers      ",-1
	dc.b "   oh, sorry that meant to say British Snail!           ",-1
	dc.b "   Noooo! Damn! British Rail! Thats what I meant        ",-1
	dc.b "   to say.                                              ",-1
	dc.b "                                                        ",-1
	dc.b "                                                        ",-1
	dc.b 0

message_6
	dc.b "   Well, I got on this friggin train and it was         ",-1
	dc.b "   mega-fucking-balls-to-the-walls packed like          ",-1
	dc.b "   fucking sardines in an unusally small tin for        ",-1
	dc.b "   the number of sardines involved.                     ",-1
	dc.b "                                                        ",-1
	dc.b 0
	
message_7
	dc.b "   I had a seat reservation but I could not get         ",-1
	dc.b "   within 15 miles of it, before the train reached      ",-1
	dc.b "   Edinburgh. That was about two hours!!                ",-1
	dc.b "                                                        ",-1
	dc.b 0
	
message_8
	dc.b "   Anyway, I got there and there was some cunt in       ",-1
	dc.b "   my seat. I showed him the reservation slip and       ",-1
	dc.b "   asked him to bugger off ( nicely of course. )        ",-1
	dc.b "   It was a complete surprise to me when he......       ",-1
	dc.b "                                                        ",-1
	dc.b 0
	
message_9
	dc.b "   .......actually did bugger off and let me have       ",-1
	dc.b "   my seat!                                             ",-1
	dc.b "                                                        ",-1
	dc.b "   Apart from that the journey was alas rather          ",-1
	dc.b "   uneventful, rather dull, rather boring, yaaaawn!     ",-1
	dc.b "   6.33 hours of pure boredom.                          ",-1
	dc.b "                                                        ",-1
	dc.b 0

message_10
	dc.b "   Arrival....                                          ",-1
	dc.b "   Well I finally got to Leeds, where Stick said he     ",-1
	dc.b "   would meet me. He said I would recognise him by      ",-1
	dc.b "   his 'yes-this-bugger-shows-up-well-in-the-dark'      ",-1
	dc.b "   jacket.......                                        ",-1
	dc.b "                                                        ",-1
	dc.b 0

message_11
	dc.b "   ......I had @No@ trouble recognising him!              ",-1
	dc.b "   All there was, was this bare @arse@ with @Stick@         ",-1
	dc.b "   inscribed across the two cheeks.                     ",-1
	dc.b "                                                        ",-1
	dc.b 0

message_12
	dc.b "   As if that, wasn't proof enough, they started        ",-1
	dc.b "   talking to me in a mild Yorkshire accent.....        ",-1
	dc.b "                                                        ",-1
	dc.b "   I'm lying..........of course!                        ",-1
	dc.b 0

message_13
	dc.b "   I suppose I'd better let the talking-arse get        ",-1
	dc.b "   his revenge..........                                ",-1
	dc.b "                                                        ",-1
	dc.b 0

message_14
	dc.b "   Well after an introduction like that, what can       ",-1
	dc.b "   I say ? ? ?                                          ",-1
	dc.b "   Except to tell you about some of the events          ",-1
	dc.b "   which happened over Easter weekend.......            ",-1 
	dc.b "                                                        ",-1
	dc.b "                                                        ",-1
	dc.b 0

message_15
	dc.b "   Yes, Obie-poos had descibed to me what he looked     ",-1
	dc.b "   like, so as I would recognise him easily.....        ",-1
	dc.b "   I saw what I can only descibe as this @Midget         ",-1
	dc.b "   in a dirty, soiled & creased raincoat@.....           ",-1
	dc.b "   This wasn't too bad,  but he realised I had          ",-1
	dc.b "   recognised him he...                                 ",-1
	dc.b "                                                        ",-1
	dc.b "                                                        ",-1
	dc.b 0
	
message_16
	dc.b "   Grabbed the lapels of his coat & slowly opened       ",-1
	dc.b "   the front of it.                                     ",-1
	dc.b "                                                        ",-1
	dc.b "                                                        ",-1
	dc.b 0
	
message_17
	dc.b "   @Revealing@............                                ",-1
	dc.b "                                                        ",-1
	dc.b "                                                        ",-1
	dc.b 0
	
message_18
	dc.b "   His rather wonderful @Tee-shirt@ . . . .               ",-1
	dc.b "                                                        ",-1
	dc.b "                                                        ",-1
	dc.b 0

message_19
	dc.b "   Anyway, we met and after a brief introduction we     ",-1
	dc.b "   set off for the short-ish car journey to my house.   ",-1
	dc.b "   Needless to say, 'cos we had never met in person     ",-1
	dc.b "   before, we spent the rest of the evening chatting.   ",-1
	dc.b "                                                        ",-1
	dc.b "                                                        ",-1 
	dc.b 0
	
message_20
	dc.b "   The next day was spent doing a bit of shopping       ",-1
	dc.b "   at the local supermarket, ( had to stock up on       ",-1
	dc.b "   the beers! ). Then into Bradford to have a quick     ",-1
	dc.b "   look about, ( Obers & I actually spent quite a       ",-1
	dc.b "   bit of dosh each!!! )                                ",-1
	dc.b "   But, we eventually got to spend some time infront    ",-1
	dc.b "   of the St's ( An STE & STFM )....                    ",-1
	dc.b "                                                        ",-1 
	dc.b 0

message_21
	dc.b "   On the Saturday Bilbo dropped in and we all set      ",-1
	dc.b "   off to visit TCC & Keith over in Nelson.             ",-1
	dc.b "   If I haven't mentioned it already, @TCC & Keith@       ",-1
	dc.b "   are working on a very nice game which is entitled:   ",-1
	dc.b "                    @RUBYCON@                             ",-1
	dc.b "   Which has the @biggest animated sprites@ you've        ",-1
	dc.b "   ever seen in an ST game ! !                          ",-1
	dc.b "                                                        ",-1 
	dc.b 0

message_22
	dc.b "   Anyway the day was wasted away in suitable style     ",-1
	dc.b "   by gassing about knack all & a brief visit to the    ",-1
	dc.b "   @Pub@ for lunch.........                               ",-1
	dc.b "   The next day or two was spent by Ober-e-poos-ville   ",-1
	dc.b "   writing this here little intro & Just generally      ",-1
	dc.b "   messing about on the ST.........                     ",-1
	dc.b "                                                        ",-1 
	dc.b 0
	
message_23
	dc.b "   Anyway, My inspiration to type in more scroll is     ",-1
	dc.b "   is fading fast, @( What do ya mean I never had any    ",-1
	dc.b "   in the first place ! ! )@                             ",-1
	dc.b "   So I'll hand over @Wilf's STE@ keyboard to the         ",-1
	dc.b "   one and only Obers"
	dcb.b 29,13
	dc.b "      ",-1
	dc.b "                                                        ",-1 
	dc.b 0
	
message_24
	dc.b "   @Well-friggin-done!                                   ",-1
	dc.b "   Still here? Blinky-flip I wouldn't be!               ",-1
	dc.b "   Haven't you got something better to do?              ",-1
	dc.b "   like anything at all??                               ",-1
	dc.b "                                                        ",-1 
	dc.b 0
	
message_25
	dc.b "   I suggest sticking a big banana up yer arse and      ",-1
	dc.b "   playing the national anthem by banging a large       ",-1
	dc.b "   and rusty spark plug on your wanger.                 ",-1
	dc.b "   Or...........if you can't find a banana try a        ",-1
	dc.b "   crisp, stick ( no pun intended ) of rhubarb.         ",-1
	dc.b "                                                        ",-1 
	dc.b 0

message_26
	dc.b "   @I think that perhaps ( just maybe ) I might get      ",-1
	dc.b "   a little offensive in this text. But please do       ",-1
	dc.b "   stop me if it gets out of hand                       ",-1
	dc.b "                                                        ",-1
	dc.b 0
	
message_27
	dc.b "                                                        ",-1 
	dc.b "   STOP! "
	dcb.b 3,14
	dc.b " Readers voice                              ",-1
	dc.b "                                                        ",-1
	dc.b 0

message_28
	dc.b "   Shit, out of beer, and Stick needs more cider,       ",-1
	dc.b "   back in five...................                      ",-1	 
	dc.b 0

message_29
	dc.b "   Let us take you on a trip into the realms of:        ",-1
	DC.B "                                                        ",-1
	dc.b "              @THE BOTTOM BORDER@                       ",-1
	DC.B "                                                        ",-1
	DC.B 0
	
message_30
	dc.b "                                                        ",-1
	dc.b "   Follow me: "
	dcb.b 9,8
	dc.b 9,"                                ",-1
	dc.b "                       ",10,"                                ",-1
	dc.b "                       ",10,"                                ",-1
	dc.b "                       ",10,"                                ",-1
	dc.b "                       ",10,"                                ",-1
	dc.b "                       ",10,"                                ",-1
	dc.b "                       ",10,"                                ",-1
	dc.b "                       ",10,"                                ",-1
	dc.b "                       ",10,"                                ",-1
	dc.b "                       ",15,"                                ",-1
	dc.b 0

message_31
	dc.b "                                                        ",-1
	dc.b "   @Okay?@                                                ",-1
	dc.b "                                                        ",-1
	dc.b 0
	
message_32
	dc.b "   Well, How's about a quick trip into                  ",-1
	dc.b "                                                        ",-1
	dc.b "                 @THE SIDE BORDERS!@                      ",-1
	dc.b "                                                        ",-1
	dc.b 0
	
message_33
	dc.b "   Follow me:",10,"                                          ",-1
	dc.b "             ",10,"                                          ",-1
	dc.b "             ",10,"                                          ",-1
        dc.b 14
       dcb.b 52,8
        dc.b 13,"  ",-1
        dc.b "                                                        ",-1
        dc.b "                                                        ",-1
        dc.b 0

message_34
	dc.b "                                                        ",-1
	dc.b "   Cheerie-bye!                                         ",-1
        dc.b "                                                        ",-1
	dc.b "   ",21," Fingerbobs ",21," Inner Circle ",21," Ripped Off - 1991       ",-1
        dc.b "                                                        ",-1
	dc.b 0

message_x
	dc.b "                                                        ",-1
	dc.b 0

	even	

message_list
	dc.l	message_01,clear_9
	dc.l	message_0,clear_5
	dc.l	message_1,clear_6
	dc.l	message_2,clear_5
	dc.l	message_3,clear_6
	dc.l	message_4,clear_4
	dc.l	message_5,clear_6
	dc.l	message_6,clear_4
	dc.l	message_7,clear_3
	dc.l	message_8,clear_4
	dc.l	message_9,clear_6
	dc.l	message_10,clear_5
	dc.l	message_11,clear_3
	dc.l	message_12,clear_4
	dc.l	message_13,clear_3
	dc.l	message_14,clear_4
	dc.l	message_15,clear_6
	dc.l	message_16,clear_3
	dc.l	message_17,clear_3
	dc.l	message_18,clear_3
	dc.l	message_19,clear_4
	dc.l	message_20,clear_7
	dc.l	message_21,clear_7
	dc.l	message_22,clear_6
	dc.l	message_23,clear_5
	dc.l	message_24,clear_4
	dc.l	message_25,clear_5
	dc.l	message_26,clear_3
	dc.l	message_27,clear_3
	dc.l	message_28,clear_3
	dc.l	message_30,clear_11
	dc.l	message_28,clear_3
	dc.l	message_32,clear_4
	dc.l	message_33,clear_4	
	dc.l	message_28,clear_3
	dc.l	message_28,clear_3
	dc.l	message_28,clear_3
	dc.l	message_34,clear_8
	dc.l	-1
		
message_list_pointer	ds.l	1
message_pointer		ds.l	1
screen_count		ds.l	1

reset_frame
	move.l	#message_list,message_list_pointer	
start_frame	
	move.l	message_list_pointer,a0
	move.l	(a0)+,message_pointer
	bmi.s	reset_frame
	move.l	a0,message_list_pointer
	move.l	#$700a0+OFFSET*SLINE,screen_count
	rts

next_letter
	move.l	message_pointer,a0
resume
	moveq	#0,d0			; Clear
	move.b	(a0)+,d0		; Get letter
	bmi	end_line		; -1 ?
	beq	end_text		; 0 ?
	move.l	a0,message_pointer	; Save new pointer
	cmpi.w	#' ',d0
	beq	space_case
	cmpi.w	#'@',d0
	beq	toggle
;	subi.w	#32,d0			; -32 ( Blocky8 )
	asl.w	#3,d0			; x8 ( 8 bytes per char )
	lea	char_set,a0		; Char data base
	lea	(a0,d0.w),a0		; Letter we want
	move.l	screen_count,a1		; Destination addr ( screen )
	tst.b	colour
	bne	fuck_up

x	set	0
	rept	8
	move.b	(a0)+,d0
	move.b	d0,d1
	not.b	d0		; Mask!
	and.b	d0,x(a1)
	and.b	d0,x+2(a1)
	and.b	d0,x+4(a1)
	and.b	d0,x+6(a1)
	or.b	d1,x(a1)		; Copy Char to Screen
x	set	OFFSET+x
	endr	
	
resume_2
	move.l	#1,d1			; Add is 1 ( Next word )
	move.l	screen_count,d0		; Get dest addr
	lsr.l	#1,d0			; Get lsb
	bcc.s	.over			; Even? Yup ---->
	move.l	#7,d1			; Add is 7 ( Next byte )
.over	add.l	d1,screen_count		; update dest.

	rts
end_line
	add.l	#7*OFFSET+6,screen_count	; Next Row
	bra	resume
end_text
	bsr	start_frame	; Next message
	rts	

colour	dc.w	0

space_case
	move.l	screen_count,d0
	move.l	d0,a1
	sub.l	#$700a0,d0	; Offset
	lea	screen_in,a0
	lea	(a0,d0.l),a0

x	set	0
	rept	8
	move.b	x(a0),x(a1)
	move.b	x+2(a0),x+2(a1)
	move.b	x+4(a0),x+4(a1)
	move.b	x+6(a0),x+6(a1)
x	set	OFFSET+x
	endr	
	
	bra	resume_2	

toggle	
	tst.b	colour
	beq.s	.over
	move.b	#0,colour
	bra	resume
.over	
	move.b	#-1,colour
	bra	resume

fuck_up
x	set	0
	rept	8
	move.b	(a0)+,d0
	move.b	d0,d1
	not.b	d0		; Mask!
	and.b	d0,x(a1)
	and.b	d0,x+2(a1)
	and.b	d0,x+4(a1)
	and.b	d0,x+6(a1)
	or.b	d1,x+2(a1)		; Copy Char to Screen
x	set	OFFSET+x
	endr	
	
	bra	resume_2
	
	
char_set	incbin	roman_3.fnt

	even

clear_screen
	move.l	a7,save_it
	movem.l blank,d0-d6/a0-a6	
	lea	$700a0+OFFSET*260,a7
	move.l	#(OFFSET*260)/54,d7
.loop	movem.l	d0-d6/a0-a6,-(a7)
	dbf	d7,.loop
	move.l save_it,a7
	rts

draw_screen
	lea	$700a0+32-8,a1	; Main piccy
	lea	screen_in,a0
	move.w	#199,d7
.loop	
	rept	20
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	endr
	lea	$e6-$a0(a1),a1
	dbf	d7,.loop

	lea	screen_in,a0
	lea	$700a0,a1
	lea	$a0+24(a1),a2
	lea	64*$e6(a1),a3
	lea	$a0+24(a3),a4
	lea	128*$e6(a1),a5
	lea	$a0+24(a5),a6
	move.w	#64-1,d7
.loop_3
	move.l	(a0),(a2)
	move.l	(a0),(a4)
	move.l	(a0),(a6)
	move.l	4(a0),4(a2)
	move.l	4(a0),4(a4)
	move.l	4(a0),4(a6)
	move.l	8(a0),8(a2)
	move.l	8(a0),8(a4)
	move.l	8(a0),8(a6)
	move.l	12(a0),12(a2)
	move.l	12(a0),12(a4)
	move.l	12(a0),12(a6)
	move.l	16(a0),16(a2)
	move.l	16(a0),16(a4)
	move.l	16(a0),16(a6)
	move.l	20(a0),20(a2)
	move.l	20(a0),20(a4)
	move.l	20(a0),20(a6)
	move.l	24(a0),24(a2)
	move.l	24(a0),24(a4)
	move.l	24(a0),24(a6)

	move.l	8(a0),(a1)
	move.l	8(a0),(a3)
	move.l	8(a0),(a5)
	move.l	12(a0),4(a1)
	move.l	12(a0),4(a3)
	move.l	12(a0),4(a5)
	move.l	16(a0),8(a1)
	move.l	16(a0),8(a3)
	move.l	16(a0),8(a5)
	move.l	20(a0),12(a1)
	move.l	20(a0),12(a3)
	move.l	20(a0),12(a5)
	move.l	24(a0),16(a1)
	move.l	24(a0),16(a3)
	move.l	24(a0),16(a5)
	move.l	28(a0),20(a1)
	move.l	28(a0),20(a3)
	move.l	28(a0),20(a5)

	lea	$e6(a1),a1
	lea	$e6(a2),a2
	lea	$e6(a3),a3
	lea	$e6(a4),a4
	lea	$e6(a5),a5
	lea	$e6(a6),a6
	lea	$a0(a0),a0
	dbf	d7,.loop_3

	lea	screen_in,a0
	lea	$700a0+192*OFFSET,a1
	move.w	#64-1,d7
.loop_4
x	set	0
	move.l	8(a0),x+0(a1)
	move.l	12(a0),x+4(a1)
	move.l	16(a0),x+8(a1)
	move.l	20(a0),x+12(a1)
	move.l	24(a0),x+16(a1)
	move.l	28(a0),x+20(a1)
x	set	24+x
	rept	6
	move.l	(a0),x(a1)
	move.l	4(a0),x+4(a1)
	move.l	8(a0),x+8(a1)
	move.l	12(a0),x+12(a1)
	move.l	16(a0),x+16(a1)
	move.l	20(a0),x+20(a1)
	move.l	24(a0),x+24(a1)
	move.l	28(a0),x+28(a1)
x	set	32+x
	endr			

	lea	$a0(a0),a0
	lea	$e6(a1),a1
	dbf	d7,.loop_4

	lea	screen_in,a0
	lea	$700a0+256*OFFSET,a1
	move.w	#8-1,d7
.loop_5
x	set	0
	move.l	8(a0),x+0(a1)
	move.l	12(a0),x+4(a1)
	move.l	16(a0),x+8(a1)
	move.l	20(a0),x+12(a1)
	move.l	24(a0),x+16(a1)
	move.l	28(a0),x+20(a1)
x	set	24+x
	rept	6
	move.l	(a0),x(a1)
	move.l	4(a0),x+4(a1)
	move.l	8(a0),x+8(a1)
	move.l	12(a0),x+12(a1)
	move.l	16(a0),x+16(a1)
	move.l	20(a0),x+20(a1)
	move.l	24(a0),x+24(a1)
	move.l	28(a0),x+28(a1)
x	set	32+x
	endr			
	lea	$a0(a0),a0
	lea	$e6(a1),a1
	dbf	d7,.loop_5
	
	lea	$700a0,a0
	lea	screen_in,a1
	move.l	#(OFFSET*260)/4,d7
.loop2
	move.l	(a0)+,(a1)+
	dbf	d7,.loop2

	rts

raster_set_up
	move.l	#raster_bars,raster_at
	move.l	#raster_bars2,raster_at2
	move.l	#raster_bars,use_at
	move.l	#raster_bars2,use_at2
	move.w	#3,timer_tick	
	rts

raster_config
	sub.w	#1,timer_tick
	bne.s	.exit	
	move.w	#3,timer_tick
	move.l	raster_at,a0
	move.l	raster_at2,a1
	add.l	#2,a0
	add.l	#2,a1
	cmp.l	#raster_bars_middle,a0
	bne.s	.over
	move.l	#raster_bars,a0
	move.l	#raster_bars2,a1
.over
	move.l	a0,raster_at
	move.l	a1,raster_at2
.exit
	move.l	raster_at,use_at	; Set rasters for this frame
	move.l	raster_at2,use_at2	; Set rasters for this frame
	rts

raster_at	dc.l	raster_bars
raster_at2	dc.l	raster_bars2
use_at		dc.l	raster_bars
use_at2		dc.l	raster_bars2
timer_tick	dc.w	3

raster_bars	dc.w	$700,$700,$710,$710,$720,$720,$730,$730	Red -> Yellow
		dc.w	$740,$740,$750,$750,$760,$760,$770,$770
		dc.w	$671,$671,$572,$572,$473,$473,$374,$374	Yellow -> Cyan
		dc.w	$275,$275,$176,$176,$077,$077
		dc.w	$067,$067,$057,$057,$047,$047,$037,$037	Cyan -> Blue
		dc.w	$027,$027,$017,$017,$007,$007
		dc.w	$107,$107,$207,$207,$307,$307,$407,$407	Blue -> Purple
		dc.w	$507,$507,$607,$607,$707,$707
		dc.w	$706,$706,$705,$705,$704,$704,$703,$703	Purple -> Red
		dc.w	$702,$702,$701,$701,$700,$700
raster_bars_middle	equ	*		
		dc.w	$700,$700,$710,$710,$720,$720,$730,$730	Red -> Yellow
		dc.w	$740,$740,$750,$750,$760,$760,$770,$770
		dc.w	$671,$671,$572,$572,$473,$473,$374,$374	Yellow -> Cyan
		dc.w	$275,$275,$176,$176,$077,$077
		dc.w	$067,$067,$057,$057,$047,$047,$037,$037	Cyan -> Blue
		dc.w	$027,$027,$017,$017,$007,$007
		dc.w	$107,$107,$207,$207,$307,$307,$407,$407	Blue -> Purple
		dc.w	$507,$507,$607,$607,$707,$707
		dc.w	$706,$706,$705,$705,$704,$704,$703,$703	Purple -> Red
		dc.w	$702,$702,$701,$701,$700,$700
		dc.w	$700,$700,$710,$710,$720,$720,$730,$730	Red -> Yellow
		dc.w	$740,$740,$750,$750,$760,$760,$770,$770
		dc.w	$671,$671,$572,$572,$473,$473,$374,$374	Yellow -> Cyan
		dc.w	$275,$275,$176,$176,$077,$077
		dc.w	$067,$067,$057,$057,$047,$047,$037,$037	Cyan -> Blue
		dc.w	$027,$027,$017,$017,$007,$007
		dc.w	$107,$107,$207,$207,$307,$307,$407,$407	Blue -> Purple
		dc.w	$507,$507,$607,$607,$707,$707
		dc.w	$706,$706,$705,$705,$704,$704,$703,$703	Purple -> Red
		dc.w	$702,$702,$701,$701,$700,$700
		dc.w	$700,$700,$710,$710,$720,$720,$730,$730	Red -> Yellow
		dc.w	$740,$740,$750,$750,$760,$760,$770,$770
		dc.w	$671,$671,$572,$572,$473,$473,$374,$374	Yellow -> Cyan
		dc.w	$275,$275,$176,$176,$077,$077
		dc.w	$067,$067,$057,$057,$047,$047,$037,$037	Cyan -> Blue
		dc.w	$027,$027,$017,$017,$007,$007
		dc.w	$107,$107,$207,$207,$307,$307,$407,$407	Blue -> Purple
		dc.w	$507,$507,$607,$607,$707,$707
		dc.w	$706,$706,$705,$705,$704,$704,$703,$703	Purple -> Red
		dc.w	$702,$702,$701,$701,$700,$700
		dc.w	$700,$700,$710,$710,$720,$720,$730,$730	Red -> Yellow
		dc.w	$740,$740,$750,$750,$760,$760,$770,$770
		dc.w	$671,$671,$572,$572,$473,$473,$374,$374	Yellow -> Cyan
		dc.w	$275,$275,$176,$176,$077,$077
		dc.w	$067,$067,$057,$057,$047,$047,$037,$037	Cyan -> Blue
		dc.w	$027,$027,$017,$017,$007,$007
		dc.w	$107,$107,$207,$207,$307,$307,$407,$407	Blue -> Purple
		dc.w	$507,$507,$607,$607,$707,$707
		dc.w	$706,$706,$705,$705,$704,$704,$703,$703	Purple -> Red
		dc.w	$702,$702,$701,$701,$700,$700
		dc.w	$700,$700,$710,$710,$720,$720,$730,$730	Red -> Yellow
		dc.w	$740,$740,$750,$750,$760,$760,$770,$770
		dc.w	$671,$671,$572,$572,$473,$473,$374,$374	Yellow -> Cyan
		dc.w	$275,$275,$176,$176,$077,$077
		dc.w	$067,$067,$057,$057,$047,$047,$037,$037	Cyan -> Blue
		dc.w	$027,$027,$017,$017,$007,$007
		dc.w	$107,$107,$207,$207,$307,$307,$407,$407	Blue -> Purple
		dc.w	$507,$507,$607,$607,$707,$707
		dc.w	$706,$706,$705,$705,$704,$704,$703,$703	Purple -> Red
		dc.w	$702,$702,$701,$701,$700,$700

raster_bars2	dc.w	$300,$400,$500,$600,$700,$700,$600,$500
		dc.w	$400,$300,$030,$040,$050,$060,$070,$070
		dc.w	$060,$050,$040,$030,$3,$4,$5,$6	
		dc.w	$7,$7,$6,$5,$4,$3
		dc.w	$303,$404,$505,$606,$707,$707,$606,$505	
		dc.w	$404,$303,$330,$440,$550,$660
		dc.w	$770,$770,$660,$550,$440,$330,$033,$044	
		dc.w	$055,$066,$077,$077,$066,$055
		dc.w	$044,$033,$333,$444,$555,$666,$777,$777	
		dc.w	$666,$555,$444,$333,$222,$300

		dc.w	$300,$400,$500,$600,$700,$700,$600,$500
		dc.w	$400,$300,$030,$040,$050,$060,$070,$070
		dc.w	$060,$050,$040,$030,$3,$4,$5,$6	
		dc.w	$7,$7,$6,$5,$4,$3
		dc.w	$303,$404,$505,$606,$707,$707,$606,$505	
		dc.w	$404,$303,$330,$440,$550,$660
		dc.w	$770,$770,$660,$550,$440,$330,$033,$044	
		dc.w	$055,$066,$077,$077,$066,$055
		dc.w	$044,$033,$333,$444,$555,$666,$777,$777	
		dc.w	$666,$555,$444,$333,$222,$300
		dc.w	$300,$400,$500,$600,$700,$700,$600,$500
		dc.w	$400,$300,$030,$040,$050,$060,$070,$070
		dc.w	$060,$050,$040,$030,$3,$4,$5,$6	
		dc.w	$7,$7,$6,$5,$4,$3
		dc.w	$303,$404,$505,$606,$707,$707,$606,$505	
		dc.w	$404,$303,$330,$440,$550,$660
		dc.w	$770,$770,$660,$550,$440,$330,$033,$044	
		dc.w	$055,$066,$077,$077,$066,$055
		dc.w	$044,$033,$333,$444,$555,$666,$777,$777	
		dc.w	$666,$555,$444,$333,$222,$300
		dc.w	$300,$400,$500,$600,$700,$700,$600,$500
		dc.w	$400,$300,$030,$040,$050,$060,$070,$070
		dc.w	$060,$050,$040,$030,$3,$4,$5,$6	
		dc.w	$7,$7,$6,$5,$4,$3
		dc.w	$303,$404,$505,$606,$707,$707,$606,$505	
		dc.w	$404,$303,$330,$440,$550,$660
		dc.w	$770,$770,$660,$550,$440,$330,$033,$044	
		dc.w	$055,$066,$077,$077,$066,$055
		dc.w	$044,$033,$333,$444,$555,$666,$777,$777	
		dc.w	$666,$555,$444,$333,$222,$300
		dc.w	$300,$400,$500,$600,$700,$700,$600,$500
		dc.w	$400,$300,$030,$040,$050,$060,$070,$070
		dc.w	$060,$050,$040,$030,$3,$4,$5,$6	
		dc.w	$7,$7,$6,$5,$4,$3
		dc.w	$303,$404,$505,$606,$707,$707,$606,$505	
		dc.w	$404,$303,$330,$440,$550,$660
		dc.w	$770,$770,$660,$550,$440,$330,$033,$044	
		dc.w	$055,$066,$077,$077,$066,$055
		dc.w	$044,$033,$333,$444,$555,$666,$777,$777	
		dc.w	$666,$555,$444,$333,$222,$300
		dc.w	$300,$400,$500,$600,$700,$700,$600,$500
		dc.w	$400,$300,$030,$040,$050,$060,$070,$070
		dc.w	$060,$050,$040,$030,$3,$4,$5,$6	
		dc.w	$7,$7,$6,$5,$4,$3
		dc.w	$303,$404,$505,$606,$707,$707,$606,$505	
		dc.w	$404,$303,$330,$440,$550,$660
		dc.w	$770,$770,$660,$550,$440,$330,$033,$044	
		dc.w	$055,$066,$077,$077,$066,$055
		dc.w	$044,$033,$333,$444,$555,$666,$777,$777	
		dc.w	$666,$555,$444,$333,$222,$300

;---------

music	incbin	comehere.czi

save_it	ds.l 1
blank	dc.l 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

old_ssp		ds.l	1
old_res		ds.w	1
old_physbase	ds.w	1
			
my_stack	ds.w 1
		ds.l 200

screen	incbin	test4pic.pi1
screen_in	equ	screen+34

