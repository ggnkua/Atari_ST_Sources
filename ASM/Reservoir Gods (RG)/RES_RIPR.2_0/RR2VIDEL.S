*************************************************************************************
* Reservoir Ripper II :: VIDEL Setter :: Coded by MrPink :: [c] 1998 Reservoir Gods *
*************************************************************************************

; Use Reservoir Ripper's new 'Save VIDEL' function to dump the
; current video mode. Now incbin this file into your program
; and use this routine to set the capture VIDEL stting


set_screen_mode:
	lea	videl_data,a0

	move.w	(a0)+,$ffff8282.w	; 4 Horizontal Hold Timer
	move.w	(a0)+,$ffff8284.w	; 6 Horizontal Border Begin
	move.w	(a0)+,$ffff8286.w	; 8 Horizontal Border End
	move.w	(a0)+,$ffff8288.w	;10 Horizontal Display Begin
	move.w	(a0)+,$ffff828a.w	;12 Horizontal display End 
	move.w	(a0)+,$ffff828c.w	;14 HSS-Synchro
	move.w	(a0)+,$ffff828e.w	;16 HFS
	move.w	(a0)+,$ffff8290.w	;18 HEE
	move.w	(a0)+,$ffff82a2.w	;20 Vertical Frequency Timer
	move.w	(a0)+,$ffff82a4.w	;22 Vertical Border Begin
	move.w	(a0)+,$ffff82a6.w	;24 Vertical Border End
	move.w	(a0)+,$ffff82a8.w	;26 Vertical Display Begin
	move.w	(a0)+,$ffff82aa.w	;28 Vertical Display End
	move.w	(a0)+,$ffff82ac.w	;30 VSS
	move.w	(a0)+,$ffff820a.w	;32 Video Sync Mode
	move.w	(a0)+,$ffff82c0.w	;34 Video Clock
	move.w	(a0)+,$ffff8266.w	;36 SPSHIFT - Falcon res
	tst.b	7(a0)
	beq.s	.no_st
	move.b	6(a0),$ffff8260.w	;ST Mode
.no_st
	move.w	(a0)+,$ffff82c2.w	;38 Video Control
	move.w	(a0)+,$ffff8210.w	;40 Falcon Line Width
	move.w	(a0)+,$ffff820e.w	;42 STe Line Width
	rts

videl_data:
	incbin	'c:\scrnmod.vid'