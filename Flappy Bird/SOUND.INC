
;Sound interrupt using Timer D
;Uses Timer D, rather than the normal Timer A, as this has a lower priority on the MFP allowing Timer B
;to interrupt the routine as palette effects are more important/visible
;NOTE - the timer handler uses move.w #$2500,sr to allow higher priority MFP interrupts to run (ie Timer B)
;NOTE - some sound players use MOVEM to access mirror registers after $ff8800/$ff8802 but these do not exist
;on all machines so we must access the hardware byte registers correctly
;NOTE - ensure PSG register #7 always leaves PortA+B set as output otherwise disc access is disabled

ENABLESOUND = 1								;Set to 1 to enable sound

	SECTION	TEXT

;----------------------------------
;Set sound interrupt on 50Hz Timer D
soundinit
	moveq.l	#0,d0
	move.l	d0,soundsfx0
	move.l	d0,soundsfx1

	IFGT ENABLESOUND	
	move.w	#$2700,sr						;Disable interrupts
	bclr.b	#4,$fffffa0d.w					;Clear Timer D in Interrupt Pending B
	move.l	#inttimerd,$110.w				;Set new Timer D vector
	and.b	#$f8,$fffffa1d.w				;Set Timer D for Delay Mode Div 200 (ie 50Hz)
	or.b	#$07,$fffffa1d.w
	bset.b	#4,$fffffa09.w					;Enable Timer D in Interrupt Enable B
	move.b	#245,$fffffa25.w				;Set Timer D Data as close to 50Hz as we can get
	bset.b	#4,$fffffa15.w					;Mask Timer D in Interrupt Mask B
	move.w	#$2300,sr						;Enable interrupts
	ENDC
	rts

;----------------------------------
;Stop all sounds on exit
soundstopall
	move.b	#7,$ffff8800.w
	move.b	#$ff,$ffff8802.w				;Turn off all channels, ensure PortA+B are set as output
	rts

;----------------------------------
;Timer D sound interrupt handler
inttimerd
	move.w	#$2500,sr						;Allow higher priority MFP Timer B interrupt this routine

	IFGT ENABLESOUND
	movem.l	d0/a0-a2,-(sp)			;40
	lea		$ffff8800.w,a1			;8		;PSG register
	lea		2(a1),a2				;8		;PSG value

	move.l	soundsfx0,d0			;20		;Read sound data pointer
	beq.s	.nosound0				;10/8	;Do have playing sound?
	move.l	d0,a0					;4
	bsr		soundsetpsg				;20		;Set PSG values
	move.l	a0,soundsfx0			;20		;Update playing sound pointer (set to 0 if finished)
.nosound0
	move.l	soundsfx1,d0
	beq.s	.nosound1
	move.l	d0,a0
	bsr		soundsetpsg
	move.l	a0,soundsfx1
.nosound1

	movem.l	(sp)+,d0/a0-a2			;44
	ENDC
	
	bclr.b	#4,$fffffa11.w					;Clear bit 4 (Timer D) in Interrupt In-Service B
	rte

;----------------------------------
;Set PSG registers from sound data, pass a0.l as sound data and return a0.l (0 if sound has finished)
soundsetpsg
	moveq.w	#0,d0					;4
	move.b	(a0)+,d0				;8		;Jump table offset
	jmp		.setpsg(pc,d0.w)		;16		;Jump ahead into unrolled loop
.setpsg
	move.b	(a0)+,(a1)				;12		;PSG register
	move.b	(a0)+,(a2)				;12		;PSG value
	move.b	(a0)+,(a1)
	move.b	(a0)+,(a2)
	move.b	(a0)+,(a1)
	move.b	(a0)+,(a2)
	move.b	(a0)+,(a1)
	move.b	(a0)+,(a2)
	move.b	(a0)+,(a1)
	move.b	(a0)+,(a2)
	move.b	(a0)+,(a1)
	move.b	(a0)+,(a2)
	move.b	(a0)+,(a1)
	move.b	(a0)+,(a2)
	move.b	(a0)+,(a1)
	move.b	(a0)+,(a2)
	move.b	(a0)+,(a1)
	move.b	(a0)+,(a2)
	move.b	(a0)+,(a1)
	move.b	(a0)+,(a2)
	move.b	(a0)+,(a1)
	move.b	(a0)+,(a2)
	move.b	(a0)+,(a1)
	move.b	(a0)+,(a2)
	move.b	(a0)+,(a1)
	move.b	(a0)+,(a2)
	move.b	(a0)+,(a1)
	move.b	(a0)+,(a2)

	move.b	(a0),d0					;8		;Jump table offset for next frame 
	beq.s	.soundend				;10/8	;Has reached end of sound?
	rts

.soundend
	move.l	#0,a0					;12		;Return zero
	rts
	
;----------------------------------
;Play sound in slot 0, pass a0.l as sound data to play
soundplay0
	move.l	a0,soundsfx0					;Store pointer to be picked up safely by interrupt
	rts
	
;----------------------------------
;Play sound in slot 1, pass a0.l as sound data to play
soundplay1
	move.l	a0,soundsfx1
	rts

;----------------------------------

	SECTION	DATA

;Sound effects
hitsfx
	dc.b	32, 4,$84,5,$08,6,$03,7,$F1,8,$0D,10,$0F
	dc.b	44, 4,$DE,6,$0C,8,$0F
	dc.b	36, 4,$38,5,$09,6,$14,8,$0E,10,$0E
	dc.b	40, 4,$92,6,$1D,8,$0D,10,$0D
	dc.b	40, 4,$EC,6,$06,8,$0C,10,$0C
	dc.b	40, 4,$46,5,$0A,6,$0F,8,$0A
	dc.b	40, 4,$A0,6,$17,8,$09,10,$0B
	dc.b	40, 4,$FA,6,$00,8,$08,10,$0A
	dc.b	36, 4,$54,5,$0B,6,$09,8,$07,10,$09
	dc.b	44, 4,$AE,6,$12,8,$05
	dc.b	36, 4,$08,5,$0C,6,$1A,8,$04,10,$08
	dc.b	40, 4,$62,6,$03,8,$03,10,$07
	dc.b	40, 4,$BC,6,$0C,8,$02,10,$06
	dc.b	40, 4,$16,5,$0D,6,$15,8,$00
	dc.b	44, 4,$70,6,$1D,10,$05
	dc.b	48, 4,$CA,10,$04
	dc.b	44, 4,$24,5,$0E,10,$03
	dc.b	52, 4,$7E
	dc.b	48, 4,$D8,10,$02
	dc.b	44, 4,$32,5,$0F,10,$01
	dc.b	48, 4,$8C,10,$00
	dc.b	0

flapsfx
	dc.b	40, 6,$1F,7,$F1,8,$02,10,$00
	dc.b	52, 8,$04
	dc.b	52, 8,$07
	dc.b	48, 6,$1C,8,$09
	dc.b	52, 8,$0A
	dc.b	52, 8,$0E
	dc.b	48, 6,$19,8,$0D
	dc.b	52, 8,$0C
	dc.b	52, 8,$0B
	dc.b	48, 6,$16,8,$0A
	dc.b	52, 8,$09
	dc.b	52, 8,$08
	dc.b	48, 6,$13,8,$07
	dc.b	52, 8,$06
	dc.b	52, 8,$05
	dc.b	52, 6,$10
	dc.b	56
	dc.b	52, 8,$04
	dc.b	52, 6,$0C
	dc.b	52, 8,$03
	dc.b	56
	dc.b	52, 6,$08
	dc.b	52, 8,$02
	dc.b	56
	dc.b	52, 6,$04
	dc.b	52, 8,$01
	dc.b	56
	dc.b	52, 6,$00
	dc.b	56
	dc.b	52, 8,$00
	dc.b	56
	dc.b	0

gameoversfx
	dc.b	40, 6,$18,7,$F1,8,$02,10,$00
	dc.b	48, 6,$19,8,$04
	dc.b	48, 6,$18,8,$06
	dc.b	48, 6,$17,8,$08
	dc.b	48, 6,$16,8,$0A
	dc.b	48, 6,$15,8,$0D
	dc.b	56
	dc.b	48, 6,$14,8,$0C
	dc.b	56
	dc.b	48, 6,$13,8,$0B
	dc.b	56
	dc.b	48, 6,$12,8,$0A
	dc.b	56
	dc.b	48, 6,$11,8,$09
	dc.b	56
	dc.b	48, 6,$10,8,$08
	dc.b	56
	dc.b	48, 6,$0F,8,$07
	dc.b	56
	dc.b	48, 6,$0E,8,$06
	dc.b	56
	dc.b	52, 6,$0D
	dc.b	52, 8,$05
	dc.b	52, 6,$0C
	dc.b	56
	dc.b	52, 6,$0B
	dc.b	56
	dc.b	48, 6,$0A,8,$04
	dc.b	56
	dc.b	52, 6,$09
	dc.b	56
	dc.b	48, 6,$08,8,$03
	dc.b	56
	dc.b	52, 6,$07
	dc.b	56
	dc.b	52, 6,$05
	dc.b	56
	dc.b	48, 6,$04,8,$02
	dc.b	56
	dc.b	56
	dc.b	52, 6,$03
	dc.b	52, 6,$02
	dc.b	52, 8,$01
	dc.b	52, 6,$01
	dc.b	56
	dc.b	56
	dc.b	56
	dc.b	48, 6,$00,8,$00
	dc.b	0

pointsfx
	dc.b	40, 2,$22,3,$00,7,$F1,9,$0D
	dc.b	48, 2,$3D,9,$0E
	dc.b	48, 2,$58,9,$0D
	dc.b	52, 2,$73
	dc.b	48, 2,$64,9,$0E
	dc.b	52, 2,$75
	dc.b	52, 2,$64
	dc.b	52, 2,$53
	dc.b	48, 2,$42,9,$0D
	dc.b	52, 2,$31
	dc.b	52, 2,$42
	dc.b	52, 2,$53
	dc.b	48, 2,$64,9,$0C
	dc.b	52, 2,$75
	dc.b	52, 2,$64
	dc.b	52, 2,$53
	dc.b	48, 2,$42,9,$0B
	dc.b	52, 2,$31
	dc.b	52, 2,$42
	dc.b	52, 2,$53
	dc.b	48, 2,$64,9,$0A
	dc.b	52, 2,$75
	dc.b	52, 2,$64
	dc.b	52, 2,$53
	dc.b	48, 2,$42,9,$09
	dc.b	52, 2,$31
	dc.b	52, 2,$42
	dc.b	52, 2,$53
	dc.b	48, 2,$64,9,$08
	dc.b	52, 2,$75
	dc.b	52, 2,$64
	dc.b	52, 2,$53
	dc.b	48, 2,$42,9,$07
	dc.b	52, 2,$31
	dc.b	52, 2,$42
	dc.b	52, 2,$53
	dc.b	48, 2,$64,9,$06
	dc.b	52, 2,$75
	dc.b	52, 2,$64
	dc.b	52, 2,$53
	dc.b	48, 2,$42,9,$05
	dc.b	52, 2,$31
	dc.b	52, 2,$42
	dc.b	52, 2,$53
	dc.b	48, 2,$64,9,$04
	dc.b	52, 2,$75
	dc.b	52, 2,$64
	dc.b	52, 2,$53
	dc.b	48, 2,$42,9,$03
	dc.b	52, 2,$31
	dc.b	52, 2,$42
	dc.b	52, 2,$53
	dc.b	48, 2,$64,9,$02
	dc.b	52, 2,$75
	dc.b	52, 2,$64
	dc.b	52, 2,$53
	dc.b	48, 2,$42,9,$01
	dc.b	52, 2,$31
	dc.b	52, 2,$42
	dc.b	52, 2,$53
	dc.b	48, 2,$64,9,$00
	dc.b	0

fallsfx
	dc.b	40, 2,$6C,3,$01,7,$F1,9,$0D
	dc.b	52, 2,$6E
	dc.b	52, 2,$7C
	dc.b	52, 2,$7E
	dc.b	48, 2,$8C,9,$0C
	dc.b	52, 2,$8E
	dc.b	52, 2,$9C
	dc.b	52, 2,$9E
	dc.b	48, 2,$AC,9,$0B
	dc.b	52, 2,$AE
	dc.b	52, 2,$BC
	dc.b	52, 2,$BE
	dc.b	48, 2,$CC,9,$0A
	dc.b	52, 2,$CE
	dc.b	52, 2,$DC
	dc.b	52, 2,$DE
	dc.b	48, 2,$EC,9,$09
	dc.b	52, 2,$EE
	dc.b	52, 2,$FC
	dc.b	52, 2,$FE
	dc.b	44, 2,$0C,3,$02,9,$08
	dc.b	52, 2,$0E
	dc.b	52, 2,$1C
	dc.b	52, 2,$1E
	dc.b	48, 2,$2C,9,$07
	dc.b	52, 2,$2E
	dc.b	52, 2,$3C
	dc.b	52, 2,$3E
	dc.b	48, 2,$4C,9,$06
	dc.b	52, 2,$4E
	dc.b	52, 2,$5C
	dc.b	52, 2,$5E
	dc.b	48, 2,$6C,9,$05
	dc.b	52, 2,$6E
	dc.b	52, 2,$7C
	dc.b	52, 2,$7E
	dc.b	48, 2,$8C,9,$04
	dc.b	52, 2,$8E
	dc.b	52, 2,$9C
	dc.b	52, 2,$9E
	dc.b	48, 2,$AC,9,$03
	dc.b	52, 2,$AE
	dc.b	52, 2,$BC
	dc.b	52, 2,$BE
	dc.b	48, 2,$CC,9,$02
	dc.b	52, 2,$CE
	dc.b	52, 2,$DC
	dc.b	52, 2,$DE
	dc.b	48, 2,$EC,9,$01
	dc.b	52, 2,$EE
	dc.b	52, 2,$FC
	dc.b	52, 2,$FE
	dc.b	52, 9,$00
	dc.b	0

	EVEN

;----------------------------------

	SECTION	BSS

soundsfx0		ds.l	1					;Sound data slots to play if !=0
soundsfx1		ds.l	1
