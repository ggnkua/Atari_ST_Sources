;
; Eternal Developments Music Player
; ---------------------------------
;
; My thanks go to Mr.X of Prophecy PD for sending me eight or so of
; these music hacks.  Once I worked it all out, the other eight
; fell out of the main music bit a.s.a.p
;
; Enjoy this digi-music by Hotline/Eternal Developments
;

	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	MOVE.L	D0,OLDSP

	CLR.B	$484

	MOVE.L	$70.W,OLDVBL

	MOVEQ	#0,D0
	JSR	MUSIC
	JSR	MUSIC+18

	MOVE.L	#NEWVBL,$70.W

MLOOP	CMP.B	#$39,$FFFC02
	BNE	MLOOP

	MOVE.L	OLDVBL,$70.W

	move	#$ff,d0
	JSR	MUSIC
	JSR	MUSIC+22

	MOVE.L	#$08080000,$FF8800
	MOVE.L	#$09090000,$FF8800
	MOVE.L	#$0a0a0000,$FF8800

	MOVE.B	#7,$484

	MOVE.L	OLDSP,-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP

	CLR.L	-(SP)
	TRAP	#1

NEWVBL	MOVEM.L	D0-D7/A0-A6,-(SP)
	JSR	MUSIC+26
	MOVEM.L	(SP)+,D0-D7/A0-A6
	MOVE.L	OLDVBL,-(SP)
	RTS

OLDVBL	DC.L	0
OLDSP	DC.L	0

MUSIC	INcbin	eternal.MUS
		;bubble is ok
;
; Files working with this source are:
; -----------------------------------
;
; ALLPLACE.MUS	- Of All Places (from Monster Business)
; BLOWJAM.MUS	- Blowjam
; BRAINDRP.MUS	- Braindrops
; GROOVY.MUS	- In A Groovy Mood
; JBLITTER.MUS	- Joardy Blitter
; MICROKIT.MUS	- Micro Kit     (from Monster Business)
; PACE.MUS	- Pace
; RUNNING.MUS	- Running Status
; SHUFFLE.MUS	- Shuffle Express
; STATE_OF.MUS	- State Of The World
; TWAVES.MUS	- Tidal Waves   (from Monster Business)
; YKLOTUS.MUS	- You Know, Lotus
; WORLD.MUS
;
; All of these music hacks are from the Main 'JukeBox' 
; section of the 'Synth Dream II' demo.
