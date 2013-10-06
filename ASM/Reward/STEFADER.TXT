; ::: STE colour fader :::                           (c)1993 Alan F. of Reward
; 
; This public release manages 3 fade-modes: Fade in from black
;                                           Fade out to black
;                                           Fade out to white
;
; You shouldn't have any problems in adding new features by yourselves, and
; the routine is awfully easy to use!
; The routine is capable of fading in 4096 colours. Well, actually, this
; hasn't been tested on a ST at all, but it SHOULD work fine.
;
; Last changes (some extra comments, and this text): 1993 - Juny - 6th
;
; Made by Alan F. of Reward (alias Davor Slutej). The original was made for
; use in the Octalyser STE. To contact me, or to get a copy of OCTALYSER STE,
; please use one of the following communication adresses:

; DATA    : +46-(0)21-112076, 2400BPS
; VOICE   : +46-(0)21-135980
; NETMAIL : 2:206/209 (FidoNet, nodes also in Fuji, NeST, DNL, Sex and Black)
; POST    : Davor Slutej, S”dra All‚gatan 18, 72214 V„ster†s, Sweden

;////////////////////////////////////////////////////////////////////////////;

; FADE-ROUTINE INITIALISATION	

 ; You should run this before you intend to fade something. Please note that
 ; this routine copies the pallete of the picture into a buffer, so if you
 ; want to fade some other palletes, you must initialize the routine again!

	move.w	#0,mode		; mode = #0	-> Fade In
				;      = #1	-> Fade Out to Black
			        ;      = #2	-> Fade Out to White
	move.l	#1,d1           ; d1.l = #1     -> Init-registers
	                        ;        #0     -> Do not intitialise
	lea	piccy+2,a1      ; a0.l = Pallete-adress
	bsr	init_fade

 ; The routine assumes that the pallete consists of 16 words, in the 
 ; hardware STE-format.

 ; Now, the routine is initialized, and you may execute the fade by simply
 ; executing the subroutine called FADE. You should syncronize the routine
 ; with the VBL! To fade the pallete completely, run the routine 16 times!

	bsr	fade			

;////////////////////////////////////////////////////////////////////////////;

init_fade	
	cmp.w	#0,mode	                ; What mode is selected?
	bne	not_fadein              ; Not fade-in...
	lea	currentpall,a0
	rept	8
	move.l	#0,(a0)+                ; Let's start with BLACK	
	endr
	lea	finalpall,a0
	rept	8
	move.l	(a1)+,(a0)+             ; And end with the actual pallete
	endr
	move.w	#0,fade_mode
	bra	initdone

not_fadein
	cmp.w	#1,mode
	bne	not_fadeout
	lea	finalpall,a0
	rept	8
	move.l	#0,(a0)+                ; Lets END with black
	endr
	lea	currentpall,a0
	rept	8
	move.l	(a1)+,(a0)+             ; And START with the actual pallete
	endr
	move.w	#1,fade_mode
	bra	initdone

not_fadeout	
	cmp.w	#2,mode
	bne	not_fadeout2
	lea	finalpall,a0
	rept	16
	move.w	#$FFF,(a0)+             ; Fadeing from white...
	endr
	lea	currentpall,a0
	rept	8
	move.l	(a1)+,(a0)+             ; ... to the actual pallete
	endr
	move.w	#0,fade_mode
	bra	initdone
not_fadeout2	
	bra	noIDfound               ; MODE MISSMATCH...

initdone
	cmp.l	#1,d1                   ; Initialize pallete right away?
	bne	do_not_change_colours   ; No -> DO_NOT_CHANGE_COLOURS
	lea	currentpall,a0          ; Oh, yes please...
	movem.l (a0),d0-d7
	movem.l	d0-d7,$ffff8240.w
do_not_change_colours	
noIDfound
	rts



fade	lea	currentpall,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.w	#15,d1
fade_routine
	lea	currentpall,a0		; Separating RED, GREEN and BLUE
	lea	finalpall,a1		; from the two palletes!
	move.w	d1,d2		
	asl.w	#1,d2		
	adda.w	d2,a0
	adda.w	d2,a1
	move.w	(a0),d2
	move.w	d2,d3
	move.w	d2,d4
	and.w	#$F00,d2
	and.w	#$0F0,d3
	and.w	#$00F,d4
	asr.w	#8,d2
	asr.w	#4,d3
	move.w	(a1),d5
	move.w	d5,d6
	move.w	d5,d7
	and.w	#$F00,d5
	and.w	#$0F0,d6
	and.w	#$00F,d7
	asr.w	#8,d5
	asr.w	#4,d6

	bsr	convert_from_ste	; $0,$8... to $0,$1...
	
	cmp.w	#0,fade_mode
	beq	sub_fadein
	cmp.w	#1,fade_mode
	beq	sub_fadeout
return_label				; This is where the subroutines jump

	bsr	convert_to_ste		; $0,$1... to $0,$8...
	bsr	create_colour
	dbra	d1,fade_routine
	rts		

; Subroutines for the fade routine

sub_fadein
	cmp.w	d5,d2
	bge	nored1		
	add.w	#1,d2
nored1	cmp.w	d6,d3
	bge	nogren1
	add.w	#1,d3
nogren1	cmp.w	d7,d4
	bge	noblue1
	add.w	#1,d4
noblue1
	bra	return_label

sub_fadeout
	cmp.w	d2,d5
	bge	nored2		
	sub.w	#1,d2
nored2	cmp.w	d3,d6
	bge	nogren2
	sub.w	#1,d3
nogren2	cmp.w	d4,d7
	bge	noblue2
	sub.w	#1,d4
noblue2
	bra	return_label

create_colour
	move.w	#0,colour
	move.w	d4,colour
	asl.w	#4,d3
	add.w	d3,colour
	asl.w	#8,d2
	add.w	d2,colour
	move.w	colour,(a0)
	rts

convert_from_ste
	lea	conv_table,a5
	asl.w	#1,d2
	move.w	(a5,d2.w),d2
	asl.w	#1,d3
	move.w	(a5,d3.w),d3
	asl.w	#1,d4
	move.w	(a5,d4.w),d4
	asl.w	#1,d5
	move.w	(a5,d5.w),d5
	asl.w	#1,d6
	move.w	(a5,d6.w),d6
	asl.w	#1,d7
	move.w	(a5,d7.w),d7
	rts

convert_to_ste
	lea	conv_table2,a5
	asl.w	#1,d2
	move.w	(a5,d2.w),d2
	asl.w	#1,d3
	move.w	(a5,d3.w),d3
	asl.w	#1,d4
	move.w	(a5,d4.w),d4
	asl.w	#1,d5
	move.w	(a5,d5.w),d5
	asl.w	#1,d6
	move.w	(a5,d6.w),d6
	asl.w	#1,d7
	move.w	(a5,d7.w),d7
	rts

;////////////////////////////////////////////////////////////////////////////;

conv_table
 dc.w 0,2,4,6,8,10,12,14,1,3,5,7,9,11,13,15
conv_table2
 dc.w 0,8,1,9,2,10,3,11,4,12,5,13,6,14,7,15

currentpall	ds.w	16
finalpall	ds.w	16
colour		dc.w	1
convert		dc.w	1
mode		dc.w	0
fade_mode	dc.w	0

;////////////////////////////////////////////////////////////////////////////;

; Greetings must go the Octalyser Team: CODE OF TBL 
;                                       BLADE OF NEW CORE
;                                       CHAOS OF REWARD
; ... and to all betatesters around!
;
; Furthermore, greets to these fine dudes and groups:
;
; Unit 17 especially Jason (one lazy coder), Dead Meat Association especially
; Mephisto (for having an ATARI), Dead Hacker Society (totally wicked group,
; extremly perverted), ICE (nice demo, XTC!), AN COOL (still haven't got those
; TCB tracker-specs.), Green Tommy (I forgot about it at the TCC!), 
; Best Babies (perverts!), SOTE (as lazy as we are obviously, and quite
; perveted...), Python (yet another pervert), all Octalyser user (perverts!),
; all Vodka BBS users (quite interesting, the most popular area seems to be
; the one consisting of SEX-STORIES ONLY, a bunch of perverts) and all other
; perverts around the globe.. (like Mr Toaster, Smurfen, Stein etc...)
; Beware, you are surrounded by PERVERTS!
;
; I would like to say hi (like, if they can read this), to some special
; girls out there. Unfortunatelly, I forgot all names, but you know who you
; are... (you lucky ones...)
;
; You should look out for these products:   Octalyser 0.9, Octalyser 1.0
;                                           Contractions (demo by REWARD/DMA)
;                                           CuBase Audio for Falcon030!!!
;                                           My demotape
;
; You may use this source freely, but no text may be removed! Haha, just
; kidding.. So, why did I write this much crap here? Well, the source looked
; to bloody short, so I thought: HEY, WHY NOT WRITING SOME GREETS AND OTHER
; CRAP?
