;
;	Multi sub-tune SNDH example source code 
;
;	gwEm 2005, 2006
;

		opt	CHKPC					;make sure PC relative code	(only required for SNDH or binary file)

		section	text
;..................................................................................
;header - for binary and sndh dont forget to trim away the $1C byte TOS header after compilation

		bra	multituneinit				;+$0 = init (with d0.w = current sub-tune)
		bra	multitunedeinit				;+$4 = deinit
		bra	multituneinter				;+$8 = 200Hz interrupt

;..................................................................................
;SNDHv2 tags - comment out this section if SNDH file not required
		dc.b	"SNDH"					;SNDH start tag
		dc.b	"COMM"
		dc.b	"Dma-Sc / gwEm",0			;composer

		dc.b	"TITL"
		dc.b	"maxYMiser test tunes",0		;track title

		dc.b	"RIPP"
		dc.b	"Not ripped (original track)",0		;ripper credits - up to you ;)

		dc.b	"CONV"
		dc.b	"gwEm",0				;converter credits - insert your name here	

		dc.b	"YEAR"
		dc.b	"2005",0

		dc.b	"##02",0				;number of sub-tunes in ASCII
		dc.b	"TC200",0				;replay method - 200Hz allows us to interpolate
		even						; all speeds for mixed replay speed sndh files

		dc.b	"TIME"					;track length array
		dc.w	60					;duration in seconds
		dc.w	60

		even
		dc.b	"HDNS"					;SNDH end tag
;..................................................................................
;Multi tune selector

multituneinit:	movem.l	a0/a1,-(sp)				;save a0

		lea	currentsubtune(pc),a0
		tst.b	2(a0)					;are we playing?
		beq.s	.continue
		cmp.w	(a0),d0					;compare with current sub-tune
		bne.s	.changetune				

		movem.l	(sp)+,a0/a1				;current tune already playing so do nothing
		rts

.changetune:	bsr	replayroutine+$4			;stop current tune before starting new one

.continue:	lea	voicedataoffset(pc),a0
		tst.w	d0					;could optimise with jump table
		beq.s	.default

		cmpi.w	#1,d0
		beq.s	.subtune1
		cmpi.w	#2,d0
		beq.s	.subtune2
		;cmpi.w	#3,d0					;add extra tunes here
		;beq.s	.subtune3
		;cmpi.w	#4,d0
		;beq.s	.subtune4
		;cmpi.w	#5,d0
		;beq.s	.subtune5

		bra.s	.default				;default case

.subtune1:	move.l	#one_voice-voicedataoffset,(a0)+	;setup offsets
		move.l	#one_song-songdataoffset,(a0)+
		move.l	#one_song_end-one_song,(a0)+
		lea	currentreplayhz+1(pc),a0		;setup replay speed
		lea	.subtune1(pc),a1
		add.l	#22+one_song-.subtune1,a1		;+22 holds offset to replay speed
		move.b	(a1),(a0)+
		bra.s	.playit

.default:
.subtune2:	move.l	#two_voice-voicedataoffset,(a0)+	;setup offsets
		move.l	#two_song-songdataoffset,(a0)+
		move.l	#two_song_end-two_song,(a0)+
		lea	currentreplayhz+1(pc),a0		;setup replay speed
		lea	.subtune2(pc),a1
		add.l	#22+two_song-.subtune2,a1		;+22 holds offset to replay speed
		move.b	(a1),(a0)+
		bra.s	.playit

		nop

.playit:	move.w	d0,(a0)+				;set current subtune
		st.b	(a0)					;set playing
		movem.l	(sp)+,a0/a1				;restore a0 and a1
		bra.s	replayroutine+$0			;call replay routine init

;..........

multitunedeinit:move.l	a0,-(sp)				;save a0
		lea	currenthzcount(pc),a0
		move.w	#200,(a0)+				;reset hz counter
		clr.w	(a0)+					;clear current replay hz to zero (interrupt never calls replayer)
		addq.l	#2,a0					;skip changing current sub-tune
		clr.b	(a0)					;no longer playing
		move.l	(sp)+,a0				;restore a0
		bra.s	replayroutine+$4			;call replay routine deinit

;..........

multituneinter:	movem.l	a0/d0,-(sp)				;save reg
		lea	currenthzcount(pc),a0			;call replay rout depending on replay frequency
		move.w	currentreplayhz(pc),d0
		sub.w	d0,(a0)				
		bgt.s	.no_call

.yes_call	add.w	#200,(a0)
		movem.l	(sp)+,a0/d0				;restore reg
		bra.s	replayroutine+$8

.no_call	movem.l	(sp)+,a0/d0				;restore reg
		rts

;..........

currenthzcount:	dc.w	200
currentreplayhz:dc.w	0
currentsubtune:	dc.w	0
playing:	dc.b	0
		even

;..................................................................................
;Include files

replayroutine:	incbin	MYM_REPL.BIN				;+$0	=init
								;+$4	=deinit
								;+$8	=interrupt
								;+$C.b	=zync code
voicedataoffset:ds.l	1
songdataoffset:	ds.l	1
songdatalength:	ds.l	1


one_voice:	incbin	example1.myv				;example music by Dma-Sc
		even
one_song:	incbin	example1.mys
one_song_end:	
		even


two_voice:	incbin	example2.myv				;example music by gwEm
		even
two_song:	incbin	example2.mys
two_song_end:	
		even