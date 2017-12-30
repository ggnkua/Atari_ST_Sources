;===========================================================================
; example part for inclusion in demo.s
;
; earx/lineout  2002
;
;---------------------------------------------------------------------------

; This table must be first in the part!
	DC.L	Gamma.init
	DC.L	Gamma.start
	DC.L	Gamma.stop


Gamma.screenTable:
	DC.L	0				; dummy (required)
	DC.L	Starfish.table			; 01
	DC.L	Bumpmap.table			; 02
	DC.L	Conch.table			; 03
	DC.L	Bubbles.table			; 04
	DC.L	Fern.table			; 05
	DC.L	ZWater.table			; 06
	DC.L	MCubes.table			; 07
	DC.L	Sparkle.table			; 08
	DC.L	MiniBlobs.table			; 09
	DC.L	Worm.table			; 0A
	DC.L	Twirl.table			; 0B
	DC.L	Spikes.table			; 0C
	DC.L	Julia.table			; 0D
	DC.L	CSpikes.table			; 0E
	DC.L	Galaxy.table			; 0F
	DC.L	0				; terminator (required)


; Initializes this part and returns references and statistics.
; OUTPUT:
; d0.l: =0: success, <0: error
; a0: screentable
; a1: sub fx count table (filled)
Gamma.init:
	lea	Gamma.screenTable,a0
	bsr.l	initScreens
	tst.l	d0
	bmi.s	.error
	move.w	d0,Gamma.screenCount

	lea	Gamma.screenTable,a0
	lea	Gamma.countTable,a1
	bsr.l	countSubFx

	lea	Gamma.screenTable,a0
	lea	Gamma.countTable,a1

	clr.l	d0
.error:	rts

; Initializes this part for action. Starts the music, if any.
; OUTPUT:
; d0.l: >=0: #screens, <0: error
Gamma.start:
	lea	Gamma.modName,a0
	bsr.l	playMod
	tst.w	d0
	bmi.s	.end

;	move.w	#5,EarxPlay.position			; conch, test, todo: remove
;	move.w	#$10,EarxPlay.position
;	move.w	#$16,EarxPlay.position			; metaballs
;	move.w	#$19,EarxPlay.position			; sparkle test
;	move.w	#$1E,EarxPlay.position			; miniblobs test
;	move.w	#$23,EarxPlay.position			; worm test
;	move.w	#$29,EarxPlay.position			; cart wobbler test
;	move.w	#$2F,EarxPlay.position			; circ wobbler test
;	move.w	#$33,EarxPlay.position			; greets, test, todo: remove

	move.w	Gamma.screenCount,d0

.end:	rts

; Stops all music or other part specific background processes.
Gamma.stop:
	bsr.l	EarxPlay.stop
	rts

; screens..
	INCLUDE	STARFISH.SO
	TEXT
	INCLUDE	BUMPMAP2.SO
	TEXT
	INCLUDE	CONCH.SO
	TEXT
	INCLUDE	BUBBLES4.SO
	TEXT
	INCLUDE	FERN2.SO
	TEXT
	INCLUDE	ZWATER2.SO
	TEXT
	INCLUDE	DSPMARCH.SO
	TEXT
	INCLUDE	SPARKLE2.SO
	TEXT
	INCLUDE	MINIBLBS.SO
	TEXT
	INCLUDE	WORM.SO
	TEXT
	INCLUDE	TWIRL.SO
	TEXT
	INCLUDE	SPIKES2.SO
	TEXT
	INCLUDE	JULIA.SO
	TEXT
	INCLUDE	SPIKES3.SO
	TEXT
	INCLUDE	GALAXY2.SO
	TEXT

	DATA

Gamma.modName:
	DC.B	"C.MOD",0
	EVEN

	BSS

Gamma.screenCount:
	DS.W	1					; #screens in part
Gamma.countTable:
	DS.B	128					; #events per screen
