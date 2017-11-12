**************************************************************************
*									 *
*	CORESONG-PLAYER v1.0						 *
*	--------------------						 *
*									 *
*	This program is an examplefile for showing how to use		 *
*	UCDM-Players and the Coresong-feeder in your own programs.	 *
*									 *
*	The code is written for Devpac 3 by HiSoft and I can't guarantee *
*	that it will work with any other assembler or earlier version of *
*	Devpac.								 *
*									 *
*	This feeder does what is called TRASHY-update and supports CIA-  *
*	timing (the BPM flag in The Octalyser).				 *
*									 *
*									 *
*	The following commands are supported in this version:		 *
*	-----------------------------------------------------		 *
*									 *
*	0 - Arpeggio/Normal Play					 *
*	1 - Slide up							 *
*	2 - Slide down							 *
*	3 - Tone Portamento						 *
*	4 - Vibrato							 *
*	5 - Tone Portamento + volume slide				 *
*	6 - Vibrato + volume slide					 *
*	7 - Tremolo							 *
*	8 - Set flag							 *
*	9 - Set sample offset						 *
*	A - Volume slide						 *
*	B - Position jump						 *
*	C - Set volume							 *
*	D - Pattern break						 *
*	E1 - Fine slide up						 *
*	E2 - Fine slide down						 *
*	E4 - Set Vibrato Waveform					 *
*	E5 - Set Finetune						 *
*	E7 - Set Tremolo Waveform					 *
*	E9 - Retrig Note						 *
*	EA - Fine volume slide up					 *
*	EB - Fine volume slide down					 *
*	EC - Notecut							 *
*	ED - Note Delay							 *
*	EE - Pattern Delay						 *
*	F - Set speed							 *
*									 *
*	As you can see we have added a "Set Flag"-command (number 8,	 *
*	previously unused).						 *
*	This gives you a fantastic opportunity to time screen-events to	 *
*	the music very easy.						 *
*	When a patternline containing a "Set Flag"-command is reached	 *
*	a byte named "FLAG" will be set to the value entered as data	 *
*	after the command.						 *
*									 *
*	For example:							 *
*	If you write 8FE on a patternline will FLAG be set to $FE as	 *
*	soon as this patternline is reached.				 *
*									 *
*	Unfortunately doesn't Set Flag work so well with TRASH-play.	 *
*									 *
**************************************************************************



FREQUENCY_SEED	EQU	4685596

*	The number above tells what basefrequency to use.
*	All normal Amiga-modfiles uses 16 kHz basefrequency.
*
*	4685596 gives 16 kHz basefrequency
*	5602486 gives 20 kHz basefrequency
*	7012352 gives 25 kHz basefrequency



TONES		EQU	35

*	This value does the same as tones in The Octalyser (found in the
*	UCDM-menu). It simply determines how many entries there shall be
*	in the frequencytable between each halfnote and can range from 0
*	to 33. 
*
*	High values makes portamento and slides, as well as finetuned
*	samples, sound better. However, increasing this value also
*	increases the amount of memory many players take.
*
*	If your module doesn't use commands 1,2,3,5,E1,E2 and no samples
*	are finetuned there is absolutely no reason to put this value to
*	anything else than 0.
*
*	If your module only is using some fast slides among the above
*	mentioned commands, a value of 2 or 3 should be enough.
*
*	If you are using Finetune or commands 3,5,E1 and E2 I should
*	recomend you to use a value of at least 5.
*
*	It's very unlikely that you ever will need values above 10.
*
*	Please notice!
*	Putting TONES to the same value as in The Octalyser doesn't
*	neccessarily mean that the player will take the same amount of
*	memory as in The Octalyser.


TRASH_BUFFER	EQU	3

*	This value tells how many fifties (1/50) of a second the buffer shall
*	be set to. I.e. a value of 50 gives you a buffer that lasts one second.


FQ	EQU	50066
DATLEN	EQU	56

*	Well, these two numbers shouldn't be changed at all.



	SECTION	TEXT

*	Now it's time for some preferences, entering supervisor mode etc.


NOW_PREFS:
	move.l	4(sp),a5
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$1000,d0
	add.l	#$100,d0
	move.l	a5,d1
	add.l	d0,d1
	
	and.l	#-2,d1
	
	move.l	d1,sp			; put up our own stack.
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move.w	d0,-(sp)
	move.w	#$4a,-(sp)
	trap	#1			; give back all memory we don't need.
	lea	12(sp),sp
	


	move.l	#0,-(SP)		; supervisor mode, the Players only
	move.w	#32,-(sp)		; work in supervisor mode.
	trap	#1
	addq.l	#6,sp


	jsr	MAKE_FREQLIST_VALUELIST

*	The call above creates a table of values the player needs to make
*	its frequency table.

	lea	SAMPLEBANK,a0
	jsr	manipulate_samples

*	Some players (Termody & Rachel) wants to have their samples prepared
*	in a special way before they can use them. The samples are destroyed
*	after this call if byte 351 (i.e. the 352:nd byte since count starts
*	at 0) in the player is set to anything else than 8.
*
*	Tammany, Nikita, Angelica, Cathryn, Banshee and Naishee doesn't need
*	this call.
*

	jsr	calc_mem_consump	; minnesÜtgÜng i d0

*	This call returns how much memory that has to be reserved for the
*	player before initiating it. The answer is put in d0.


	move.l	d0,-(sp)		; reserve memory
	move.w	#72,-(sp)
	trap	#1
	addq.l	#6,sp
	tst.l	d0
	beq	out			; not enough memory
	move.l	d0,BUFFER

	move.l	d0,a0
	jsr	init_player

*	The call above initiates the player.
*	A0 shall point at the memory-buffer.
*


	lea	SAMPLEBANK,a0
	lea	SONGFILE,a1
	jsr	init_feeder
	
*	This call initiates the feeder.
*	A0 shall point at the samplebank.
*	A1 shall point at the songfile you want to play.


	move.l	$70.w,OLD_VBL
	move.l	#MY_VBL,$70.w

main

	jsr	FEEDER

.wait
	move.l	TRASH_ADR,a0
	jsr	(a0)
	
	cmp.b	#$39,$fffffc02.w	; exit if we pressed space...
	beq	exit

	tst.w	d0
	bmi.s	.wait

	bra	main			; Repeat the main-loop.


exit
	bsr	PLAYER+8		; turn off the soundchip

	move.l	BUFFER,-(sp)		; return reserved memory
	move.w	#73,-(sp)
	trap	#1
	addq.l	#6,sp

	move.l	OLD_VBL,$70.w		; give back the old VBL


out
	clr.w	-(sp)
	trap	#1

MY_VBL
	tst.w	OVERRUN		; Overrun protection, don't run this VBL
	bne.s	.go_on		; if we allready are running a VBL.
	rte
.go_on
	clr.w	OVERRUN
	movem.l	d0-d7/a0-a6,-(sp)


	jsr	PLAYER+344

;	This call runs a few fast routines that some of the players have
;	to run 50 times a second even in TRASH-mode. If your screenupdate
;	is not 50 Hz you have to put this call on another timer.
;	The only players that need this call is Termody (a player that
;	was supplied with older versions of Octalyser) and the players
;	written by Lance.	
	

				; Place your own routine here, it will be		
				; run once every VBL (=screenupdate).

	movem.l	(sp)+,d0-d7/a0-a6
	move.w	#-1,OVERRUN
	rte
	

OVERRUN
	ds.w	1

OLD_VBL
	ds.l	1

BUFFER:
	ds.l	1

PLAYER:
	incbin	"G:\UCDM.ump\NIKITA.ump"
	EVEN

SONGFILE
	incbin	"G:\JAM.SNG"
	EVEN

SAMPLEBANK			
	incbin	"G:\JAM.SBK"
	EVEN


**************************************************************************
*									 *
*	The following data belongs to the Coresong-feeder and is nothing *
*	you have to bother about.					 *
*									 *
*	Anyone who wants to change or optimize this feeder is free to do *
*	so and spread the result in whatever way they want as long as it *
*	is clearly stated that the code is based upon "Blade's Coresong  *
*	Feeder" and that it has been changed. 				 *
*									 *
*	I would like to point out that this code ain't so optimized as	 *
*	it could have been and that it probably is rather hard to	 *
*	understand, especially since many labels and remarks are in	 *
*	Swedish. (sorry!)						 *
*									 *
**************************************************************************

calc_mem_consump
	lea	PLAYER,a0
	move.l	340(a0),d0
	mulu.w	#TRASH_BUFFER,d0		; Minne till TRASH-areor
	add.l	332(a0),d0		; GrundlÑggande minneskonsumption
	move.l	am_of_freqlist_entries,d1
	move.l	336(a0),d2
	mulu.w	d2,d1
	add.l	d1,d0
	rts

manipulate_samples
	move.l	4(a0),d0		; startpos spl1
	adda.l	d0,a0		; pekar pÜ bîrjan

	move.l	-12(a0),d1		; endpos spl X
	move.l	-16(a0),d2		; startpos spl X

	cmp.l	d1,d2
	beq.s	.empty_sample
	add.l	#1000,d1	; antal bytes
.empty_sample	
	sub.l	d0,d1
	subq.l	#1,d1
	moveq	#8,d0 
	lea	PLAYER,a1
	sub.w	350(a1),d0	; antal steg som ska skiftas.
.loop
	move.b	(a0),d2
	ext.w	d2
	lsr.w	d0,d2
	move.b	d2,(a0)+
	subq.l	#1,d1
	bpl.s	.loop
	rts

init_player
	move.w	#125,PLAYER+356	; set normal tempo
	lea	FREQLIST,a1
	move.l	#TRASH_BUFFER,d0
	moveq	#0,d1
	jsr	(PLAYER+4)
	move.l	a0,TRASH_ADR
	rts

init_feeder
	lea	4(a0),a0
	move.l	a0,SPL_BEG
	move.l	a1,SèNGFIL

	clr.w	P_DELAY
	moveq	#-1,d0
	move.l	d0,P_DELAY_MASK

	lea	VIB_PEK,a0
	lea	sin,a2
	moveq	#15,d0		; Vibrato- och Tremolo-pekare.
.a
	move.l	a2,(a0)+
	dbf	d0,.a

	move.l	a1,a0

	move.b	5(a0),d0	; kollar om det Ñr byte/word.
	move.w	#1,B_W
	cmp.b	#"B",d0
	beq.s	.byte
	move.w	#2,B_W
.byte

	move.b	6(a0),d0	; kollar antal stÑmmor
	move.w	#4,V_AM
	cmp.b	#"4",d0	
	beq.s	.fyra
	move.w	#8,V_AM
.fyra
	lea	8(a0),a1
	move.l	a1,POS_PAT	; stÑller in POS_PAT pekaren.

	moveq	#0,d0		; stÑller in restartpekaren.
	move.b	7(a0),d0
	cmpi.b	#127,d0
	bne.s	.data_ok
	moveq	#0,d0
.data_ok
	move.w	V_AM,d1
	mulu.w	d1,d0
	lea	8(a0,d0.w),a1
	move.l	a1,RES_POS	; RÑknar ut restart adressen

	addq.l	#8,a0
.loop1
	cmp.w	#-8888,(a0)+
	bne.s	.loop1
	move.l	a0,PAT_BEG
.loop2	
	cmp.w	#-9999,(a0)+
	bne.s	.loop2
	move.l	a0,POL_BEG

	move.w	#5,TEMPO
	move.w	#0,T_DBF
	move.w	#125,BPM
	move.w	#125-1,B_DBF


	rts


FEEDER
	move.w	B_DBF,d0
	sub.w	#125,d0
	bmi.s	.go_on

	move.w	d0,B_DBF
	move.w	#125,PLAYER+356
	rts

.go_on
	add.w	#126,d0
	move.w	d0,PLAYER+356

	move.w	BPM,d0
	subq	#1,d0
	move.w	d0,B_DBF

	move.w	T_DBF,d0
	dbf	d0,cont

	tst.w	P_DELAY
	beq.s	.further

	tst.w	P_DELAY_MASK
	bpl.s	.redan_delayad

	moveq.l	#0,d0
	move.w	B_W,d0
	lea	PAT_PEK,a0

	sub.l	d0,(a0)+
	sub.l	d0,(a0)+
	sub.l	d0,(a0)+
	sub.l	d0,(a0)+
	sub.l	d0,(a0)+
	sub.l	d0,(a0)+
	sub.l	d0,(a0)+
	sub.l	d0,(a0)+

	move.l	#$0000ffff,P_DELAY_MASK
.redan_delayad
	sub.w	#1,P_DELAY
	bra	.the_play

.further
	tst.w	P_DELAY_MASK
	bmi.s	.hitÜt

	moveq.l	#0,d0
	move.w	B_W,d0
	lea	PAT_PEK,a0

	add.l	d0,(a0)+
	add.l	d0,(a0)+
	add.l	d0,(a0)+
	add.l	d0,(a0)+
	add.l	d0,(a0)+
	add.l	d0,(a0)+
	add.l	d0,(a0)+
	add.l	d0,(a0)+

.hitÜt
	moveq.l	#-1,d0
	move.l	d0,P_DELAY_MASK

	move.w	P_DBF,d0
	dbf	d0,.update



	move.l	POS_PAT,a0
	cmp.w	#-8888,(a0)
	bne.s	.no_restart
	move.l	RES_POS,a0
	
.no_restart
	move.w	V_AM,d2
	subq	#1,d2		; rÑknare
	move.w	B_W,d1		; hur mÜnga gÜnger extra man ska skifta.
	addq.l	#5,d1
	lea	PAT_PEK,a1
	move.l	PAT_BEG,d4
.loop1
	moveq	#0,d3
	move.b	(a0)+,d3
	rol.w	d1,d3
	add.l	d4,d3
	move.l	d3,(a1)+
	
	dbf	d2,.loop1
	
	move.l	a0,POS_PAT


	moveq	#63,d0
.update
	move.w	d0,P_DBF

; Alla patterns Ñr nu rÑttstÑllda. Det Ñr bara att skîta sjÑlva spelningen.

.the_play
	move.w	V_AM,d0
	subq	#1,d0
	lea	PAT_PEK,a0		; Ñr îkad
	lea	EFCT_J,a1		; Ñr îkad ?
	lea	VOICE1,a2
	move.l	POL_BEG,a3
	move.l	SPL_BEG,a4
	lea	PLAYER+12,a5

	move.w	TEMPO,T_DBF		; Vi fÜr gîra detta nu innan om patterndelay ska fungera


.loop
	move.l	(a0),a6
	moveq	#1,d1

	cmp.w	B_W,d1
	beq.s	.byte
.word
	move.w	(a6)+,d1
	bra.s	.vidare
.byte
	move.b	(a6)+,d1
.vidare
	tst.w	P_DELAY_MASK
	bpl.s	.hit2
	move.l	a6,(a0)
.hit2
	addq.l	#4,a0
	add.l	d1,d1
	add.l	d1,d1

	moveq	#0,d2
	move.b	2(a3,d1.w),d2

	move.l	(a3,d1.w),d1
	and.l	P_DELAY_MASK,d1

	lea	COMMAND_TAB,a6
	move.l	(a6,d2.w),a6
	jsr	(a6)

	addq	#4,a5
	lea	DATLEN(a2),a2
	dbf	d0,.loop


	moveq	#-1,d7			; fîr att meddela PUT_FREQ	
	bra.s	PUT_FREQ
cont
	move.w	d0,T_DBF



**	UTFôRA KOMMANDONA

DO_COMMANDS
	move.w	V_AM,d0
	subq	#1,d0
	lea	EFCT_J,a0
	lea	VOICE1,a2
	lea	PLAYER+12,a3
.loop
	move.l	(a0)+,a1
	jsr	(a1)
	lea	DATLEN(a2),a2
	addq	#4,a3
	dbf	d0,.loop

	moveq	#0,d7


**	RéKNA OM CLOCKCYKLER TILL FREKVENS

PUT_FREQ
	lea	VOICE1+4,a0
	lea	PLAYER+12+2,a1
	lea	VALUELIST,a2
	lea	EFCT_J,a3
	move.l	#Arpeggio,d6
	move.w	V_AM,d1
	subq	#1,d1
.loop
	cmp.l	(a3)+,d6
	beq.s	.arpeggio
.ingen_arp
	move.w	38-4(a0),d0		; hÑmta vibrerad frekvens
	bmi.s	.hit
	bra.s	.hit2
.hit
	move.w	(a0),d0			; hÑmta orginalfrekvens
.hit2
	add.w	d0,d0
	move.w	(a2,d0.w),(a1)
	addq	#4,a1
	lea	DATLEN(a0),a0
	dbf	d1,.loop
	rts

.arpeggio
	tst.w	d7
	bmi.s	.ingen_arp

	move.w	32-4(a0),d0		; hÑmta arpeggiofrekvensen
	add.w	d0,d0
	move.w	(a2,d0.w),(a1)
	addq	#4,a1
	lea	DATLEN(a0),a0
	dbf	d1,.loop
	rts

.reset_arp
;	lea	22-4(a0),a6
;	move.l	a6,26-4(a0)	; bîrja om pÜ nÑst fîrsta, nÑsta VBL
	bra.s	.ingen_arp



*********	EFFECT_INSTALLS

*	D1: InnehÜller patterndatan
*	A2: Pekar pÜ VOICE-datan
*	A5: Pekar pÜ kommunikationsvariablerna (UCDM)


I_ARP
	move.w	d1,d3
	beq	.nothing

	bsr	INSTR_TONE
	move.l	#Arpeggio,(a1)+

	lea	22(a2),a6
	move.l	a6,26(a2)	; pekaren pÜ fîrsta "icke-orginal"
				; (orginalet spelas 1VBL innan Arp-rutinen
				; kommer till)


	move.l	(a2),a6		; instrumentheader
	move.w	48(a2),d3
	mulu.w	#72,d3

	lea	FINETUNE_TAB-2,a6
	add.w	d3,a6
	

	cmp.b	#16,d1
	blt.s	.org_last		; eller blo

	move.b	d1,d3
	and.b	#$f,d3
	beq.s	.second_org
.all_three
	add.w	30(a2),a6
	move.w	(a6),20(a2)	; orginalfrekvensen


	move.b	d1,d3
	and.w	#$f0,d3
	ror.w	#3,d3
	move.w	(a6,d3.w),22(a2)	; frekvens 2
	move.b	d1,d3
	and.w	#$f,d3
	add.w	d3,d3
	move.w	(a6,d3.w),24(a2)	; frekvens 3
	rts

.org_last
	add.w	30(a2),a6
	move.w	(a6),20(a2)	; orginalfrekvensen

	move.b	d1,d3
	and.w	#$f,d3
	add.w	d3,d3
	move.w	(a6,d3.w),22(a2)	; frekvens 3
	move.w	#-1,24(a2)
	rts

.second_org
	add.w	30(a2),a6
	move.w	(a6),22(a2)	; orginalfrekvensen

	move.b	d1,d3
	and.w	#$f0,d3
	ror.w	#3,d3
	move.w	(a6,d3.w),20(a2)	; frekvens 2
	move.w	#-1,24(a2)
	rts
	

.nothing
	move.l	#Nothing,(a1)+
	bra	INSTR_TONE	
I_UPSL					; done?
	moveq	#0,d3
	move.b	d1,d3
	move.w	d3,6(a2)
	move.l	#Slide_Up,(a1)+
	bra	INSTR_TONE	
I_DWNSL					; done?
	moveq	#0,d3
	move.b	d1,d3
	move.w	d3,6(a2)
	move.l	#Slide_Down,(a1)+
	bra	INSTR_TONE

I_TPORT
	move.l	d1,d3
	rol.l	#8,d3
	and.w	#$ff,d3
	tst.w	d3
	beq.s	.dont_change_dest

	lea	FINETUNE_TAB-2,a6		; ingen finetune?
	move.w	(a6,d3.w),16(a2)	; destination

.dont_change_dest
;	moveq	#0,d3		; redan gjort
	move.b	d1,d3
	beq.s	.dont_change_speed
	move.w	d3,18(a2)		; speed
.dont_change_speed

	move.l	d1,d3
	swap	d3
	and.w	#$ff,d3
	tst.w	d3
	beq.s	.out

	move.l	SPL_BEG,a6
	subq.w	#1,d3
	rol.w	#4,d3
	move.b	12(a6,d3.w),4*16*4+2(a5)	; volym	

.out
	move.w	#-1,38(a2)	; vi ska inte anvÑnda vibratofrekvensen (i fall den var satt)
	move.b	#-1,54(a2)	; tala om att vi inte har Tremolo
	move.l	#Tone_Portamento,(a1)+
	rts	

I_VIB
	move.w	38(a2),-(sp)
	bsr	INSTR_TONE
	move.w	(sp)+,38(a2)
	
	tst.b	36(a2)
	beq.s	.hit

	clr.b	34(a2)		; restart vibrato
	move.w	#-1,38(a2)
	clr.b	36(a2)		; ingen retrigg efter vibraton Ñn sÜ lÑnge...
.hit
	move.l	#Vibrato,(a1)+
	
	tst.b	d1
	beq.s	.out
	move.w	d1,d3
	lsr.w	#4,d3
	and.w	#$f,d3

	move.b	d3,35(a2)		; speed
	move.w	d1,d3
	and.w	#$f,d3
	move.b	d3,37(a2)		; depth
.out
	rts


I_TPORTVOLSL
	move.l	#Tone_Portamento_w_Volume_slide,(a1)+
	bra	inhopp	

I_VIBVOLSL
	move.l	#Vibrato_w_Volume_Slide,(a1)+

	move.b	d1,d3
	and.w	#$f,d3
	move.w	d3,12(a2)	; sub
	move.b	d1,d3
	and.w	#$f0,d3
	lsr.w	#4,d3
	move.w	d3,14(a2)	; add

	move.w	38(a2),-(sp)
	bsr	INSTR_TONE
	move.w	(sp)+,38(a2)
	
	tst.b	36(a2)
	beq.s	.hit

	clr.b	34(a2)		; restart vibrato
	move.w	#-1,38(a2)
	clr.b	36(a2)		; ingen retrigg efter vibraton Ñn sÜ lÑnge...		
.hit
	rts


I_TREM
	tst.b	54(a2)
	bmi.s	.hit

	bsr	INSTR_TONE	

.maybe_retrigg
	move.l	d1,d3
	and.l	#$ff000000,d3
	beq.s	.vidare
	clr.b	50(a2)		; restart
.vidare
	move.l	d1,d3
	and.l	#$00ff0000,d3
	beq.s	.hit2

	move.b	4*16*4+2(a5),55(a2)	; orginalvolym
	bra.s	.hit2

.hit
	clr.b	50(a2)		; bîrja om frÜn bîrjan pÜ vÜgformen
	bsr	INSTR_TONE	
	move.b	4*16*4+2(a5),55(a2)	; orginalvolym
.hit2
	move.l	#Tremolo,(a1)+
	clr.b	54(a2)

	tst.b	d1
	beq.s	.out
	move.w	d1,d3
	lsr.w	#4,d3
	and.w	#$f,d3

	move.b	d3,51(a2)		; speed
	move.w	d1,d3
	and.w	#$f,d3
	move.w	d3,52(a2)		; depth
.out
	rts


I_NOTUSED
	move.l	#Nothing,(a1)+
	bra	INSTR_TONE	

I_SPLOFFSET				; done ?
	bsr	INSTR_TONE
	moveq	#0,d3
	move.b	d1,d3
	rol.w	#8,d3

	move.l	(a2),a6
	add.l	(a6),d3
	
	cmp.l	4(a6),d3
	blt.s	.ok
	move.l	(a6),d3
.ok
	move.l	d3,44(a2)

	and.l	#$ff000000,d1
	beq.s	.vidare			; Har ej retrigats, sÜ vi ska ej modifiera aktuell pekare
	
	add.l	SPL_BEG,d3
	subq.l	#4,d3
	move.l	d3,4*16(a5)
.vidare
	move.l	#Nothing,(a1)+
	rts

I_VOLSLIDE				; done ?
	move.l	#VolumeSlide,(a1)+
inhopp
	move.b	d1,d3
	and.w	#$f,d3
	move.w	d3,12(a2)	; sub
	move.b	d1,d3
	and.w	#$f0,d3
	lsr.w	#4,d3
	move.w	d3,14(a2)	; add
	bra	INSTR_TONE

I_POS_JMP				; done ?
	clr.w	P_DBF
	moveq	#0,d3
	move.b	d1,d3
	mulu.w	V_AM,d3
	addq	#8,d3
	add.l	SèNGFIL,d3
	move.l	d3,POS_PAT
	move.l	#Nothing,(a1)+
	bra	INSTR_TONE
I_SETVOL				; done
	bsr	INSTR_TONE
	move.b	d1,4*16*4+2(a5)
	move.l	#Nothing,(a1)+
	rts
I_PBREAK
	tst.b	d1
	bne.s	.svÜr
	clr.w	P_DBF
	move.l	#Nothing,(a1)+
	bra	INSTR_TONE

.svÜr
	moveq	#63,d4
	sub.b	d1,d4
	move.w	d4,P_DBF

	moveq	#0,d7
	move.b	d1,d7
	mulu.w	B_W,d7

	move.l	POS_PAT,a6
	cmp.w	#-8888,(a6)
	bne.s	.no_restart
	move.l	RES_POS,a6
	
.no_restart
	move.l	a5,-(sp)

	move.w	V_AM,d6
	subq	#1,d6		; rÑknare
	move.w	B_W,d5		; hur mÜnga gÜnger extra man ska skifta.
	addq	#5,d5
	lea	PAT_PEK,a5
	move.l	PAT_BEG,d4
	add.l	d7,d4
.loop1
	moveq	#0,d3
	move.b	(a6)+,d3
	rol.w	d5,d3
	add.l	d4,d3
	move.l	d3,(a5)+
	
	dbf	d6,.loop1
	
	move.l	a6,POS_PAT

	move.l	(sp)+,a5

	move.l	#Nothing,(a1)+
	bra	INSTR_TONE
I_ECOM
	lea	E_COM_TAB,a6
	move.l	d1,d3
	and.w	#$f0,d3
	ror.w	#2,d3
	move.l	(a6,d3.w),a6
	jmp	(a6)
I_TEMPO					; done
	move.l	#Nothing,(a1)+
	cmp.b	#$20,d1
	bhs.s	.set_BPM		; eller bhs

	subq	#1,d1
	move.b	d1,TEMPO+1
	move.b	d1,T_DBF+1
	bra	INSTR_TONE
.set_BPM
	move.l	#15625,d3
	move.l	d1,d2
	and.l	#$ff,d2
	divu.w	d2,d3
	move.w	d3,BPM
	subq	#1,d3
	move.w	d3,B_DBF
	bra	INSTR_TONE

	

*****	E-commands   *****

I_SET_FILTER
I_GLISSANDO_CONTR
I_LOOP
	move.l	#Nothing,(a1)+
	bra	INSTR_TONE




I_TREM_WAVEFORM
	move.l	d1,d3

	and.w	#$f,d3
	beq.s	.sine

	cmp.b	#1,d3
	beq.s	.ramp_down
.square
	lea	square,a6
	bra.s	.vidare	
.ramp_down
	lea	ramp_down,a6
	bra.s	.vidare
.sine
	lea	sin,a6		
.vidare
	move.l	a6,8*4*2(a1)
	move.l	#Nothing,(a1)+
	bra	INSTR_TONE


I_SET_FINETUNE
	bsr	INSTR_TONE
	move.w	d1,d3
	and.w	#$f,d3
	move.w	d3,48(a2)
	move.l	#Nothing,(a1)+
	and.l	#$ff000000,d1
	bra	INSTR_TONE



I_VIB_WAVEFORM
	move.l	d1,d3

	and.w	#$f,d3
	beq.s	.sine

	cmp.b	#1,d3
	beq.s	.ramp_down
.square
	lea	square,a6
	bra.s	.vidare	
.ramp_down
	lea	ramp_down,a6
	bra.s	.vidare
.sine
	lea	sin,a6		
.vidare
	move.l	a6,8*4(a1)
	move.w	#-1,38(a2)
	move.l	#Nothing,(a1)+
	bra	INSTR_TONE



I_RETRIG_NOTE
	move.l	#RetrigNote,(a1)+
	move.l	d1,40(a2)
	bra	INSTR_TONE



I_FLAG
	move.l	#Nothing,(a1)+
	move.b	d1,FLAG
	bra	INSTR_TONE


I_FINESLIDE_UP
	bsr	INSTR_TONE
	
	move.b	d1,d3
	and.w	#$f,d3
	add.w	4(a2),d3
	cmpi.w	#907,d3
	ble.s	.ej_îverslag
	move.w	#907,d3
.ej_îverslag
	move.w	d3,4(a2)	
	move.l	#Nothing,(a1)+
	rts

I_FINESLIDE_DOWN
	bsr	INSTR_TONE
	
	move.b	d1,d3
	and.w	#$f,d3
	neg.w	d3
	add.w	4(a2),d3
	cmpi.w	#108,d3
	bge.s	.ej_îverslag
	move.w	#108,d3
.ej_îverslag
	move.w	d3,4(a2)	
	move.l	#Nothing,(a1)+
	rts



		

I_FINE_VOL_UP
	bsr	INSTR_TONE

	move.b	d1,d3
	and.b	#$f,d3
	add.b	4*16*4+2(a5),d3
	cmp.b	#64,d3
	ble.s	.ok
	move.b	#64,d3
.ok	
	move.b	d3,4*16*4+2(a5)
	
	move.l	#Nothing,(a1)+
	rts
	
	
I_FINE_VOL_DOWN
	bsr.s	INSTR_TONE

	move.b	d1,d3
	and.w	#$f,d3
	neg.w	d3
	add.b	4*16*4+2(a5),d3
	tst.b	d3
	bpl.s	.ok
	move.b	#0,d3
.ok	
	move.b	d3,4*16*4+2(a5)
	
	move.l	#Nothing,(a1)+
	rts

I_NOTECUT
	bsr.s	INSTR_TONE

	move.b	d1,d3
	and.w	#$f,d3
	beq.s	.now

	move.w	d3,12(a2)	; rÑknare
	move.l	#Notecut,(a1)+
	rts
.now
	clr.b	4*16*4+2(a5)
	move.l	#Nothing,(a1)+
	rts
		


I_NOTEDELAY
	move.l	#NoteDelay,(a1)+
	move.l	d1,40(a2)
	and.l	#$ffffff,d1
	bra.s	INSTR_TONE
	
I_P_DELAY
	move.l	#Nothing,(a1)+
	tst.w	P_DELAY_MASK
	bpl.s	INSTR_TONE
	move.b	d1,d3
	and.w	#$f,d3
	move.w	d3,P_DELAY	
	bra.s	INSTR_TONE

I_INV_LOOP
	move.l	#Nothing,(a1)+
	bra	INSTR_TONE



*********	TA INSTR/TONE
INSTR_TONE

	move.b	#-1,54(a2)	; tala om att vi inte har Tremolo

	move.w	#-1,38(a2)	; Vi kîr inte med Vibrato (Ñnnu i alla fall)

	move.l	d1,d2
	swap	d2
	lsr.w	#8,d2
	and.w	#$ff,d2		; tonnummer

	beq.s	.vidare
	move.w	d2,30(a2)	; spara undan tonnummer fîr arpeggio
.vidare
	move.l	d1,d3
	swap	d3
	and.w	#$ff,d3		; instrumentnr

	tst.w	d3
	beq.s	.no_new_instr

	subq	#1,d3		; nr > offset
	rol.w	#4,d3		; offset

	lea	(a4,d3.w),a6
	move.l	a6,(a2)		; spara pekare pÜ instrumentheadern

	move.l	(a6),44(a2)	; Where to trig from

	move.b	12(a4,d3.w),16*4*4+2(a5)	; Volym

	move.b	13(a6),49(a2)			; Finetune


.no_new_instr

	tst.w	d2
	beq.s	.no_new_tone

	move.b	#-1,36(a2)	; tala om att vi ska retrigga Vibrato

	move.l	(a2),a6

	move.l	SPL_BEG,d4
	subq.l	#4,d4

	move.l	44(a2),d5
	add.l	d4,d5
	move.l	d5,16*4(a5)		; retrigg

	move.l	4(a6),d5
	add.l	d4,d5
	move.l	d5,16*4*2(a5)		; Stopp
	
	move.l	8(a6),16*4*3(a5)	; Loop


	move.w	48(a2),d4	; finetune
.finetune
	lea	FINETUNE_TAB-2,a6 ; -2 pga att freq startar pÜ 1.
	mulu.w	#72,d4		; rÑtt tabell
	add.w	d2,d4		; rÑtt tal
	move.w	(a6,d4.w),d4	; Frekvenscykler

	move.w	d4,4(a2)		; ton i amigaklockcykler

.no_new_tone

	rts



*********	EFFECT_JUMPS

*	A2 pekar pÜ DATAN
*	A3 pekar pÜ KOMMUNIKATIONSVEKTORERNA (UCDM)


Nothing
	rts
Arpeggio
	lea	26(a2),a5
	move.l	(a5),a4	; hÑmta pekare

	cmp.l	a4,a5
	bne.s	.loopa_ej
	lea	20(a2),a4	; peka pÜ bîrjan	
.loopa_ej
	cmp.w	#-1,(a4)
	bne.s	.loopa_ej2
	lea	20(a2),a4
.loopa_ej2	
	move.w	(a4)+,32(a2)	; ut med frekvensen...
	move.l	a4,(a5)		; spara pekare
	rts

Slide_Up
	move.w	4(a2),d1
	sub.w	6(a2),d1	; lÑgre tal ger hîgre frekvens
	cmpi.w	#108,d1
	bge.s	.ej_îverslag
	move.w	#108,d1
.ej_îverslag
	move.w	d1,4(a2)	
	rts

Slide_Down
	move.w	4(a2),d1
	add.w	6(a2),d1	; hîgre tal ger lÑgre frekvens
	cmpi.w	#907,d1
	ble.s	.ej_îverslag
	move.w	#907,d1
.ej_îverslag
	move.w	d1,4(a2)	
	rts

Tone_Portamento
	move.w	16(a2),d1	; ny frekvens
	move.w	4(a2),d2	; gammal frekvens
	cmp.w	d1,d2
	blt.s	.slide_down	(mao slide_up talet)
.slide_up
	sub.w	18(a2),d2	; speed
	cmp.w	d1,d2
	blt.s	.last
.out
	move.w	d2,4(a2)
	rts

.slide_down
	add.w	18(a2),d2
	cmp.w	d1,d2
	blt.s	.out
.last
	move.w	d1,4(a2)
	rts

Vibrato
	move.l	4*8-4(a0),a4		; vib-pekare
	moveq	#0,d1
	move.b	34(a2),d1		; pekare i vib-tab
	moveq	#0,d2
	move.b	(a4,d1.w),d2		; vib_tab vÑrde
	moveq	#0,d3
	move.b	37(a2),d3
	mulu.w	d3,d2
	lsr.l	#7,d2

	move.w	4(a2),d3		; orginalfrekvens
	cmp.b	#$1f,d1
	bge.s	.minus
.plus
	add.w	d2,d3
	bra.s	.more
.minus
	sub.w	d2,d3
.more
	cmp.w	#907,d3
	ble.s	.ok1
	move.w	#907,d3
.ok1
	cmp.w	#108,d3
	bge.s	.ok2
	move.w	#108,d3
.ok2
	move.w	d3,38(a2)		; ny frekvens

	add.b	35(a2),d1
	and.b	#%111111,d1
	move.b	d1,34(a2)		; ny pekare i vib-tab
	rts

Tone_Portamento_w_Volume_slide
	bsr.s	Tone_Portamento
	bra.s	VolumeSlide
Vibrato_w_Volume_Slide
	bsr.s	Vibrato
	bra.s	VolumeSlide

Tremolo
	move.l	4*8*2-4(a0),a4		; Trem-pekare
	moveq	#0,d1
	move.b	50(a2),d1		; pekare i vib-tab
	moveq	#0,d2
	move.b	(a4,d1.w),d2		; vib_tab vÑrde
	mulu.w	52(a2),d2
	lsr.w	#6,d2

	move.b	55(a2),d3		; orginalvolym
	cmp.b	#$1f,d1
	bge.s	.minus
.plus
	add.b	d2,d3
	bra.s	.more
.minus
	sub.b	d2,d3

.more
	cmp.b	#64,d3
	ble.s	.ok1
	moveq	#64,d3
.ok1
	tst.b	d3
	bpl.s	.ok2
	moveq	#0,d3
.ok2
	move.b	d3,4*16*4+2(a3)		; ny volym

	add.b	51(a2),d1
	and.b	#%111111,d1
	move.b	d1,50(a2)		; ny pekare i vib-tab
	rts

VolumeSlide
	moveq	#0,d1
	move.b	16*4*4+2(a3),d1
	add.w	14(a2),d1	; upp
	sub.w	12(a2),d1	; ner
	cmpi.w	#64,d1
	ble.s	.ej_îverslag
	moveq	#64,d1
.ej_îverslag
	tst.w	d1
	bpl.s	.ej_underslag
	moveq	#0,d1
.ej_underslag
	move.b	d1,16*4*4+2(a3)
	rts

NoteDelay
	moveq	#0,d1
	move.b	43(a2),d1
	and.b	#$0f,d1
	move.w	TEMPO,d2
	sub.w	T_DBF,d2
	beq.s	.out
	cmp.b	d2,d1
	bne.s	.out
	move.b	40(a2),d1
	beq.s	.out
.do_it
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	40(a2),d1
	move.l	a3,a5			; a2 stÜr redan rÑtt
	move.l	SPL_BEG,a4
	bsr	INSTR_TONE
	movem.l	(sp)+,d0-d7/a0-a6
.out
	rts



RetrigNote
	moveq	#0,d1
	move.b	43(a2),d1
	and.w	#$f,d1
	beq.s	.out

	moveq.l	#0,d2
	move.w	TEMPO,d2
	sub.w	T_DBF,d2
	bne.s	.maybe
	tst.b	43(a2)
	bne.s	.out
	moveq	#0,d2
.maybe
	divu	d1,d2
	swap	d2
	tst.w	d2
	bne.s	.out
.do_it
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	40(a2),d1
	move.l	a3,a5			; a2 stÜr redan rÑtt
	move.l	SPL_BEG,a4
	bsr	INSTR_TONE
	movem.l	(sp)+,d0-d7/a0-a6
.out
	rts




Notecut
	subi.w	#1,12(a2)
	bne.s	.no_cut
	clr.b	16*4*4+2(a3)
.no_cut
	rts

	

	SECTION BSS
am_of_freqlist_entries	ds.l	1	; frÜn  make_freqlist till
					; calc_mem_consump.

FLAG	ds.b	1	; signal
	even
P_DELAY		ds.w	1
P_DELAY_MASK	ds.l	1

B_W	ds.w	1	; 1=byte, 2=word
V_AM	ds.w	1	; Antal stÑmmor
POS_PAT	ds.l	1	; Pekar pÜ POS_PAT TABELLEN
RES_POS	ds.l	1	; Var POS_PAT ska hamna vid restart.
PAT_BEG	ds.l	1	; Pekar pÜ bîrjan av patternsen.
POL_BEG	ds.l	1	; Pekar pÜ bîrjan av datapoolen.
SPL_BEG	ds.l	1	; Pekar pÜ bîrjan av samplingsbanken+4 !!!
P_DBF	ds.w	1	; DBF fîr patternlÑngd

TEMPO	ds.w	1	; Tempo-1
T_DBF	ds.w	1	; Tempo DBF, arbetsregistret.
BPM	ds.w	1	; BPM-vÑrde
B_DBF	ds.w	1	; BPM-vÑrde som rÑknas ner.

PAT_PEK	ds.l	8	; Pekar i patternsen fîr de olika stÑmmorna.




VOICE1
	ds.l	1	; Adressen till instrumentets header
	ds.w	1	; Frekvens i Amiga klockcykler
	ds.b	10	; Effect_Data
	ds.w	1	; 3: Destinationsfrekvens i Amigaklockcykler
	ds.w	1	; 3: Slidespeed
	ds.w	3	; 0: 3 Arpeggiofrekvenser
	ds.l	1	; 0: Pekare pÜ ny Arpeggiofrekvens fîr nÑsta frame.
	ds.w	1	; 0: Last frequency-hit, for Arpeggiostart 
	ds.w	1	; 0: Arpeggiofrekvens, sÜ sparar vi inte îver den andre.
	ds.w	1	; 4: Pekare & Speed
	ds.w	1	; 4: Check & Depth
	ds.w	1	; 4: Frekvens
	ds.l	1	; E9/ED: Data att trigga.
	ds.l	1	; 9: Triggposition, sÑtts bl a av 9 men anvÑnds av normal uppdatering
	ds.w	1	; Finetune
	ds.w	1	; 7: Pekare & Speed
	ds.w	1	; 7: Depth
	ds.w	1	; 7: Orginalvolym

VOICE2
	ds.l	1	; Adressen till instrumentets header
	ds.w	1	; Frekvens i Amiga klockcykler
	ds.b	10	; Effect_Data
	ds.w	1	; 3: Destinationsfrekvens i Amigaklockcykler
	ds.w	1	; 3: Slidespeed
	ds.w	3	; 0: 3 Arpeggiofrekvenser
	ds.l	1	; 0: Pekare pÜ ny Arpeggiofrekvens fîr nÑsta frame.
	ds.w	1	; 0: Last frequency-hit, for Arpeggiostart 
	ds.w	1	; 0: Arpeggiofrekvens, sÜ sparar vi inte îver den andre.
	ds.w	1	; 4: Pekare & Speed
	ds.w	1	; 4: Check & Depth
	ds.w	1	; 4: Frekvens
	ds.l	1	; E9/ED: Data att trigga.
	ds.l	1	; 9: Triggposition, sÑtts bl a av 9 men anvÑnds av normal uppdatering
	ds.w	1	; Finetune
	ds.w	1	; 7: Pekare & Speed
	ds.w	1	; 7: Depth
	ds.w	1	; 7: Orginalvolym

VOICE3
	ds.l	1	; Adressen till instrumentets header
	ds.w	1	; Frekvens i Amiga klockcykler
	ds.b	10	; Effect_Data
	ds.w	1	; 3: Destinationsfrekvens i Amigaklockcykler
	ds.w	1	; 3: Slidespeed
	ds.w	3	; 0: 3 Arpeggiofrekvenser
	ds.l	1	; 0: Pekare pÜ ny Arpeggiofrekvens fîr nÑsta frame.
	ds.w	1	; 0: Last frequency-hit, for Arpeggiostart 
	ds.w	1	; 0: Arpeggiofrekvens, sÜ sparar vi inte îver den andre.
	ds.w	1	; 4: Pekare & Speed
	ds.w	1	; 4: Check & Depth
	ds.w	1	; 4: Frekvens
	ds.l	1	; E9/ED: Data att trigga.
	ds.l	1	; 9: Triggposition, sÑtts bl a av 9 men anvÑnds av normal uppdatering
	ds.w	1	; Finetune
	ds.w	1	; 7: Pekare & Speed
	ds.w	1	; 7: Depth
	ds.w	1	; 7: Orginalvolym

VOICE4
	ds.l	1	; Adressen till instrumentets header
	ds.w	1	; Frekvens i Amiga klockcykler
	ds.b	10	; Effect_Data
	ds.w	1	; 3: Destinationsfrekvens i Amigaklockcykler
	ds.w	1	; 3: Slidespeed
	ds.w	3	; 0: 3 Arpeggiofrekvenser
	ds.l	1	; 0: Pekare pÜ ny Arpeggiofrekvens fîr nÑsta frame.
	ds.w	1	; 0: Last frequency-hit, for Arpeggiostart 
	ds.w	1	; 0: Arpeggiofrekvens, sÜ sparar vi inte îver den andre.
	ds.w	1	; 4: Pekare & Speed
	ds.w	1	; 4: Check & Depth
	ds.w	1	; 4: Frekvens
	ds.l	1	; E9/ED: Data att trigga.
	ds.l	1	; 9: Triggposition, sÑtts bl a av 9 men anvÑnds av normal uppdatering
	ds.w	1	; Finetune
	ds.w	1	; 7: Pekare & Speed
	ds.w	1	; 7: Depth
	ds.w	1	; 7: Orginalvolym

VOICE5
	ds.l	1	; Adressen till instrumentets header
	ds.w	1	; Frekvens i Amiga klockcykler
	ds.b	10	; Effect_Data
	ds.w	1	; 3: Destinationsfrekvens i Amigaklockcykler
	ds.w	1	; 3: Slidespeed
	ds.w	3	; 0: 3 Arpeggiofrekvenser
	ds.l	1	; 0: Pekare pÜ ny Arpeggiofrekvens fîr nÑsta frame.
	ds.w	1	; 0: Last frequency-hit, for Arpeggiostart 
	ds.w	1	; 0: Arpeggiofrekvens, sÜ sparar vi inte îver den andre.
	ds.w	1	; 4: Pekare & Speed
	ds.w	1	; 4: Check & Depth
	ds.w	1	; 4: Frekvens
	ds.l	1	; E9/ED: Data att trigga.
	ds.l	1	; 9: Triggposition, sÑtts bl a av 9 men anvÑnds av normal uppdatering
	ds.w	1	; Finetune
	ds.w	1	; 7: Pekare & Speed
	ds.w	1	; 7: Depth
	ds.w	1	; 7: Orginalvolym

VOICE6
	ds.l	1	; Adressen till instrumentets header
	ds.w	1	; Frekvens i Amiga klockcykler
	ds.b	10	; Effect_Data
	ds.w	1	; 3: Destinationsfrekvens i Amigaklockcykler
	ds.w	1	; 3: Slidespeed
	ds.w	3	; 0: 3 Arpeggiofrekvenser
	ds.l	1	; 0: Pekare pÜ ny Arpeggiofrekvens fîr nÑsta frame.
	ds.w	1	; 0: Last frequency-hit, for Arpeggiostart 
	ds.w	1	; 0: Arpeggiofrekvens, sÜ sparar vi inte îver den andre.
	ds.w	1	; 4: Pekare & Speed
	ds.w	1	; 4: Check & Depth
	ds.w	1	; 4: Frekvens
	ds.l	1	; E9/ED: Data att trigga.
	ds.l	1	; 9: Triggposition, sÑtts bl a av 9 men anvÑnds av normal uppdatering
	ds.w	1	; Finetune
	ds.w	1	; 7: Pekare & Speed
	ds.w	1	; 7: Depth
	ds.w	1	; 7: Orginalvolym

VOICE7
	ds.l	1	; Adressen till instrumentets header
	ds.w	1	; Frekvens i Amiga klockcykler
	ds.b	10	; Effect_Data
	ds.w	1	; 3: Destinationsfrekvens i Amigaklockcykler
	ds.w	1	; 3: Slidespeed
	ds.w	3	; 0: 3 Arpeggiofrekvenser
	ds.l	1	; 0: Pekare pÜ ny Arpeggiofrekvens fîr nÑsta frame.
	ds.w	1	; 0: Last frequency-hit, for Arpeggiostart 
	ds.w	1	; 0: Arpeggiofrekvens, sÜ sparar vi inte îver den andre.
	ds.w	1	; 4: Pekare & Speed
	ds.w	1	; 4: Check & Depth
	ds.w	1	; 4: Frekvens
	ds.l	1	; E9/ED: Data att trigga.
	ds.l	1	; 9: Triggposition, sÑtts bl a av 9 men anvÑnds av normal uppdatering
	ds.w	1	; Finetune
	ds.w	1	; 7: Pekare & Speed
	ds.w	1	; 7: Depth
	ds.w	1	; 7: Orginalvolym

VOICE8
	ds.l	1	; Adressen till instrumentets header
	ds.w	1	; Frekvens i Amiga klockcykler
	ds.b	10	; Effect_Data
	ds.w	1	; 3: Destinationsfrekvens i Amigaklockcykler
	ds.w	1	; 3: Slidespeed
	ds.w	3	; 0: 3 Arpeggiofrekvenser
	ds.l	1	; 0: Pekare pÜ ny Arpeggiofrekvens fîr nÑsta frame.
	ds.w	1	; 0: Last frequency-hit, for Arpeggiostart 
	ds.w	1	; 0: Arpeggiofrekvens, sÜ sparar vi inte îver den andre.
	ds.w	1	; 4: Pekare & Speed
	ds.w	1	; 4: Check & Depth
	ds.w	1	; 4: Frekvens
	ds.l	1	; E9/ED: Data att trigga.
	ds.l	1	; 9: Triggposition, sÑtts bl a av 9 men anvÑnds av normal uppdatering
	ds.w	1	; Finetune
	ds.w	1	; 7: Pekare & Speed
	ds.w	1	; 7: Depth
	ds.w	1	; 7: Check & Orginalvolym


EFCT_J	ds.l	8	; Effect_Jump.
VIB_PEK	ds.l	8	; Pekar pÜ rÑtt vÜgform fîr vibrato
TREM_PEK ds.l	8	; Pekar pÜ rÑtt vÜgform fîr tremolo

	SECTION DATA

COMMAND_TAB
	dc.l	I_ARP
	dc.l	I_UPSL
	dc.l	I_DWNSL
	dc.l	I_TPORT
	dc.l	I_VIB
	dc.l	I_TPORTVOLSL
	dc.l	I_VIBVOLSL
	dc.l	I_TREM
	dc.l	I_FLAG
	dc.l	I_SPLOFFSET
	dc.l	I_VOLSLIDE
	dc.l	I_POS_JMP
	dc.l	I_SETVOL
	dc.l	I_PBREAK
	dc.l	I_ECOM
	dc.l	I_TEMPO
E_COM_TAB
	dc.l	I_SET_FILTER
	dc.l	I_FINESLIDE_UP
	dc.l	I_FINESLIDE_DOWN
	dc.l	I_GLISSANDO_CONTR
	dc.l	I_VIB_WAVEFORM
	dc.l	I_SET_FINETUNE
	dc.l	I_LOOP
	dc.l	I_TREM_WAVEFORM
	dc.l	I_FLAG
	dc.l	I_RETRIG_NOTE
	dc.l	I_FINE_VOL_UP
	dc.l	I_FINE_VOL_DOWN
	dc.l	I_NOTECUT
	dc.l	I_NOTEDELAY
	dc.l	I_P_DELAY
	dc.l	I_INV_LOOP



FINETUNE_TAB:
; Tuning 0, Normal
	dc.w	856,808,762,720,678,640,604,570,538,508,480,453
	dc.w	428,404,381,360,339,320,302,285,269,254,240,226
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113
; Tuning 1
	dc.w	850,802,757,715,674,637,601,567,535,505,477,450
	dc.w	425,401,379,357,337,318,300,284,268,253,239,225
	dc.w	213,201,189,179,169,159,150,142,134,126,119,113
; Tuning 2
	dc.w	844,796,752,709,670,632,597,563,532,502,474,447
	dc.w	422,398,376,355,335,316,298,282,266,251,237,224
	dc.w	211,199,188,177,167,158,149,141,133,125,118,112
; Tuning 3
	dc.w	838,791,746,704,665,628,592,559,528,498,470,444
	dc.w	419,395,373,352,332,314,296,280,264,249,235,222
	dc.w	209,198,187,176,166,157,148,140,132,125,118,111
; Tuning 4
	dc.w	832,785,741,699,660,623,588,555,524,495,467,441
	dc.w	416,392,370,350,330,312,294,278,262,247,233,220
	dc.w	208,196,185,175,165,156,147,139,131,124,117,110
; Tuning 5
	dc.w	826,779,736,694,655,619,584,551,520,491,463,437
	dc.w	413,390,368,347,328,309,292,276,260,245,232,219
	dc.w	206,195,184,174,164,155,146,138,130,123,116,109
; Tuning 6
	dc.w	820,774,730,689,651,614,580,547,516,487,460,434
	dc.w	410,387,365,345,325,307,290,274,258,244,230,217
	dc.w	205,193,183,172,163,154,145,137,129,122,115,109
; Tuning 7
	dc.w	814,768,725,684,646,610,575,543,513,484,457,431
	dc.w	407,384,363,342,323,305,288,272,256,242,228,216
	dc.w	204,192,181,171,161,152,144,136,128,121,114,108
; Tuning -8
	dc.w	907,856,808,762,720,678,640,604,570,538,508,480
	dc.w	453,428,404,381,360,339,320,302,285,269,254,240
	dc.w	226,214,202,190,180,170,160,151,143,135,127,120
; Tuning -7
	dc.w	900,850,802,757,715,675,636,601,567,535,505,477
	dc.w	450,425,401,379,357,337,318,300,284,268,253,238
	dc.w	225,212,200,189,179,169,159,150,142,134,126,119
; Tuning -6
	dc.w	894,844,796,752,709,670,632,597,563,532,502,474
	dc.w	447,422,398,376,355,335,316,298,282,266,251,237
	dc.w	223,211,199,188,177,167,158,149,141,133,125,118
; Tuning -5
	dc.w	887,838,791,746,704,665,628,592,559,528,498,470
	dc.w	444,419,395,373,352,332,314,296,280,264,249,235
	dc.w	222,209,198,187,176,166,157,148,140,132,125,118
; Tuning -4
	dc.w	881,832,785,741,699,660,623,588,555,524,494,467
	dc.w	441,416,392,370,350,330,312,294,278,262,247,233
	dc.w	220,208,196,185,175,165,156,147,139,131,123,117
; Tuning -3
	dc.w	875,826,779,736,694,655,619,584,551,520,491,463
	dc.w	437,413,390,368,347,328,309,292,276,260,245,232
	dc.w	219,206,195,184,174,164,155,146,138,130,123,116
; Tuning -2
	dc.w	868,820,774,730,689,651,614,580,547,516,487,460
	dc.w	434,410,387,365,345,325,307,290,274,258,244,230
	dc.w	217,205,193,183,172,163,154,145,137,129,122,115
; Tuning -1
	dc.w	862,814,768,725,684,646,610,575,543,513,484,457
	dc.w	431,407,384,363,342,323,305,288,272,256,242,228
	dc.w	216,203,192,181,171,161,152,144,136,128,121,114


sin	DC.B $00,$18,$31,$4A,$61,$78,$8D,$A1,$B4,$C5,$D4,$E0,$EB,$F4,$FA,$FD
	DC.B $FF,$FD,$FA,$F4,$EB,$E0,$D4,$C5,$B4,$A1,$8D,$78,$61,$4A,$31,$18
	DC.B $00,$18,$31,$4A,$61,$78,$8D,$A1,$B4,$C5,$D4,$E0,$EB,$F4,$FA,$FD
	DC.B $FF,$FD,$FA,$F4,$EB,$E0,$D4,$C5,$B4,$A1,$8D,$78,$61,$4A,$31,$18

square	dc.b $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	dc.b $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	dc.b $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	dc.b $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF

ramp_down
	dc.b $00,$08,$10,$18,$20,$28,$30,$38,$40,$48,$50,$58,$60,$68,$70,$78
	dc.b $80,$88,$90,$98,$A0,$A8,$B0,$B8,$C0,$C8,$D0,$D8,$E0,$E8,$F0,$F8
	dc.b $FF,$F8,$F0,$E8,$E0,$D8,$D0,$C8,$C0,$B8,$B0,$A8,$A0,$98,$90,$88
	dc.b $80,$78,$70,$68,$60,$58,$50,$48,$40,$38,$30,$28,$20,$18,$10,$08





FREQTAB
	dc.w	108,113,120,127,135,143,151,160,170,180,190,202,214
	dc.w	226,240,254,269,285,302,320,339,360,381,404,428
	dc.w	453,480,508,538,570,604,640,678,720,762,808,856
	dc.w	907

SèNGFIL
	ds.l	1

TRASH_ADR
	ds.l	1

FREQLIST
	ds.l	800		; att skicka en gÜng i bîrjan
	


VALUELIST
	dcb.w	109,0
BEGIN_VALUELIST
	ds.w	799

	section	text

MAKE_FREQLIST_VALUELIST


	lea	FREQTAB,a0
	lea	FREQLIST,a1
	

	move.l	#FREQUENCY_SEED,d0	; frî
	move.w	#36,d4

.ta_en_ton
	move.l	#TONES,d1		; antal steg till nÑsta ton (mellansteg+1)

	moveq	#0,d2
	move.w	2(a0),d2
	moveq.l	#0,d3
	move.w	(a0),d3
	swap	d3		; utgÜngsfrekvens vid îkningen
	
	sub.w	(a0)+,d2	; antal klockticks till nÑsta ton
	rol.w	#8,d2		; vi vill ha decimaler
	divu.w	d1,d2		; inkrement * 256
	and.l	#$ffff,d2
	rol.l	#8,d2		; sÜ att vi kan swappa

	cmp.l	#$10000,d2
	bge.s	.cont

	move.l	#$10000,d2
	move.w	(a0),d1
	sub.w	-2(a0),d1
.cont	
	subq.w	#1,d1
	bmi.s	.nÑsta

		
	swap	d3
	
	move.l	d0,d5
	clr.w	d5
	swap	d5
	divu.w	d3,d5
	move.w	d5,(a1)+	; ôversta wordet i frekvensen

	move.w	d0,d5
	divu.w	d3,d5
	move.w	d5,(a1)+	; lÑgsta wordet i frekvensen
			
	swap	d3
	add.l	d2,d3

	bra.s	.cont
.nÑsta
	dbf	d4,.ta_en_ton

	move.l	a1,d1
	sub.l	#FREQLIST,d1
	ror.l	#2,d1
	move.l	d1,am_of_freqlist_entries	; till minnesutrÑknaren.

	move.l	#-1,(a1)+

	
MAKE_VALUELIST

	lea	BEGIN_VALUELIST,a1
	move.w	#798,d1
.loop1
	move.l	a1,d2
	sub.l	#VALUELIST,d2
	ror.l	#1,d2		; offset i longwords frÜn VALUELIST
	

	move.l	d0,d5
	clr.w	d5
	swap	d5
	divu.w	d2,d5
	move.w	d5,d3

	move.w	d0,d5
	divu.w	d2,d5
	swap	d3
	move.w	d5,d3		; frekvensen fîr offseten i d3

	lea	FREQLIST+4,a2
.igen	
	cmp.l	(a2)+,d3	; hitta "skarven"
	ble.s	.igen

	move.l	-(a2),d2	; =< d3
	move.l	-(a2),d4	; > d3

	move.l	d3,d5
	sub.l	d2,d3
	sub.l	d5,d4
	cmp.l	d3,d4
	blt.s	.ta_det_fîrsta
	addq.l	#4,a2
.ta_det_fîrsta
	suba.l	#FREQLIST,a2	; offset frÜn FREQLIST fîr det aktuella.

	move.w	a2,(a1)+	; spara VALUELIST

	dbf	d1,.loop1	
	rts
	end


************** ()()()

