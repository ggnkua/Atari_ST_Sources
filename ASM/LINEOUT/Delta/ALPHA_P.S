;===========================================================================
; example part for inclusion in demo.s
;
; earx/lineout  2002
;
;---------------------------------------------------------------------------

; This table must be first in the part!
	DC.L	Alpha.init
	DC.L	Alpha.start
	DC.L	Alpha.stop


Alpha.screenTable:
	DC.L	0				; dummy (required)
	DC.L	Interfer.table			; 01 used
	DC.L	Water.table 			; 02 used (bug? prolly not!)
	DC.L	BlurZoom.table			; 03 used (bug?)
	DC.L	DspWaves.table			; 04 used (bug?)
	DC.L	Plasma.table			; 05 used (bug?)
	DC.L	Flare.table			; 06 used
	DC.L	Lenses.table			; 07 used
	DC.L	RotoZoomer.table		; 08 used (bug?)
	DC.L	TunnelBlob.table		; 09 used
	DC.L	RayPlane.table			; 0A used
	DC.L	ZVoxel.table			; 0B used
	DC.L	Radial.table			; 0C used
	DC.L	ZSphere.table			; 0D used
	DC.L	Pinch.table			; 0E used
	DC.L	0				; terminator (required)


; Initializes this part and returns references and statistics.
; OUTPUT:
; d0.l: =0: success, <0: error
; a0: screentable
; a1: sub fx count table (filled)
Alpha.init:
	lea	Alpha.screenTable,a0
	bsr.l	initScreens
	tst.l	d0
	bmi.s	.error
	move.w	d0,Alpha.screenCount

	lea	Alpha.screenTable,a0
	lea	Alpha.countTable,a1
	bsr.l	countSubFx

	lea	Alpha.screenTable,a0
	lea	Alpha.countTable,a1

	clr.l	d0
.error:	rts

; Initializes this part for action. Starts the music, if any.
; OUTPUT:
; d0.l: >=0: #screens, <0: error
Alpha.start:
	lea	Alpha.modName,a0
	bsr.l	playMod
	tst.w	d0
	bmi.s	.end

; todo: remove tests
;	move.w	#$15,EarxPlay.position			; blurzoom
;	move.w	#$1F,EarxPlay.position			; water
;	move.w	#$24,EarxPlay.position			; interfer
;	move.w	#$31,EarxPlay.position			; zsphere
;	move.w	#$44,EarxPlay.position			; zvoxel
;	move.w	#$72,EarxPlay.position			; pinch

	move.w	Alpha.screenCount,d0

.end:	rts

; Stops all music or other part specific background processes.
Alpha.stop:
	bsr.l	EarxPlay.stop
	rts

; screens..
	INCLUDE	INTERFER.SO
	TEXT
	INCLUDE	WATER.SO
	TEXT
	INCLUDE	BLURZOO2.SO
	TEXT
	INCLUDE	DSPWAVES.SO
	TEXT
	INCLUDE	PLASMA.SO
	TEXT
	INCLUDE	FLARE.SO
	TEXT
	INCLUDE	LENSES.SO
	TEXT
	INCLUDE	ROTOZOOM.SO
	TEXT
	INCLUDE	TNLBLOB2.SO
	TEXT
	INCLUDE	RAYPLANE.SO
	TEXT
	INCLUDE	ZVOXEL.SO
	TEXT
	INCLUDE	RADIALT.SO
	TEXT
	INCLUDE	ZSPHERE.SO
	TEXT
	INCLUDE	PINCH.SO
	TEXT

	DATA

Alpha.modName:
	DC.B	"A.MOD",0
	EVEN

	BSS

Alpha.screenCount:
	DS.W	1					; #screens in part
Alpha.countTable:
	DS.B	128					; #events per screen
