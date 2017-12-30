v;===========================================================================
; example part for inclusion in demo.s
;
; earx/lineout  2002
;
;---------------------------------------------------------------------------

; This table must be first in the part!
	DC.L	Beta.init
	DC.L	Beta.start
	DC.L	Beta.stop


Beta.screenTable:
	DC.L	0				; dummy (required)
	DC.L	Volumetric.table		; 01
	DC.L	EnvBall.table			; 02
	DC.L	Squares.table			; 03
	DC.L	Interpol.table			; 04 m
	DC.L	Blender.table			; 05
	DC.L	Spiral.table			; 06
	DC.L	Rings.table			; 07
	DC.L	HhhmCube.table			; 08 u
	DC.L	SxT4Cubes.table			; 09
	DC.L	Voxel.table			; 0A m
	DC.L	Pretzel.table			; 0B
	DC.L	Tribal.table			; 0C 
	DC.L	Hemi.table			; 0D u

;	DC.L	Kaleido.table			; 0E !hangs 1 out of 20 times!
	DC.L	Dummy.table			; !!

	DC.L	Transparant.table		; 0F 
	DC.L	Balloid.table			; 10 
	DC.L	InCube.table			; 11
	DC.L	0				; terminator (required)


; Initializes this part and returns references and statistics.
; OUTPUT:
; d0.l: =0: success, <0: error
; a0: screentable
; a1: sub fx count table (filled)
Beta.init:
	lea	Beta.screenTable,a0
	bsr.l	initScreens
	tst.l	d0
	bmi.s	.error
	move.w	d0,Beta.screenCount

	lea	Beta.screenTable,a0
	lea	Beta.countTable,a1
	bsr.l	countSubFx

	lea	Beta.screenTable,a0
	lea	Beta.countTable,a1

	clr.l	d0
.error:	rts

; Initializes this part for action. Starts the music, if any.
; OUTPUT:
; d0.l: >=0: #screens, <0: error
Beta.start:
	lea	Beta.modName,a0
	bsr.l	playMod
	tst.w	d0
	bmi.s	.end

; test shit, todo: remove
;	move.w	#$34,EarxPlay.position			; tribal
;	move.w	#$52,EarxPlay.position			; balloid
;	move.w	#$57,EarxPlay.position			; (dither)
;	move.w	#$6B,EarxPlay.position			; (end)

	move.w	Beta.screenCount,d0

.end:	rts

; Stops all music or other part specific background processes.
Beta.stop:
	bsr.l	EarxPlay.stop
	rts

; screens..
	INCLUDE	VLMETRIC.SO
	TEXT
	INCLUDE	ENVLITE.SO
	TEXT
	INCLUDE	INTERPO2.SO
	TEXT
	INCLUDE	BLENDTNL.SO
	TEXT
	INCLUDE	SQUARES2.SO
	TEXT
	INCLUDE	RINGS.SO
	TEXT
	INCLUDE	HMMMCUBE.SO
	TEXT
	INCLUDE	CUBES.SO
	TEXT
	INCLUDE	VOXEL2.SO
	TEXT
	INCLUDE	DSPSNIL2.SO
	TEXT
	INCLUDE	TRIBAL.SO
	TEXT
	INCLUDE	HEMI.SO
	TEXT
	INCLUDE	TRANSPAR.SO
	TEXT
	INCLUDE	BALLOID.SO
	TEXT
	INCLUDE	INCUBE.SO
	TEXT
	INCLUDE	SPIRAL2.SO
	TEXT

Dummy.table:
	DC.L	rts
	DC.L	rts
	DC.L	rts
	DC.L	0


	DATA

Beta.modName:
	DC.B	"B.MOD",0
	EVEN

	BSS

Beta.screenCount:
	DS.W	1					; #screens in part
Beta.countTable:
	DS.B	128					; #events per screen
