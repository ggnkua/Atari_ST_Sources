
;Routines to handler Timer B colour palette effects
;Timer B is allowed to interrupt IKBD and also the sound running on Timer D
;As MOVEM can delay the execution of the Timer B vector (causing a glitch in the sky)
;we sync the game loop to the last Timer B rather than the VBL allowing the code to
;run and complete before the starting Timer B on the next retrace
;NOTE - we need to keep Timer C running (for TOS 2.06 or later) but it causes a glitch
;in the sky as the Timer B vector is delayed so we disable the timer for the duration of
;our Timer B raster effects and then enable it again

RASTERSET_BLACKOUT = 0						;List of different raster effect settings
RASTERSET_TITLE = 1
RASTERSET_GETREADY = 2
RASTERSET_GAME = 3
RASTERSET_MEDAL = 4

SKYDAY1 = $137								;Sky day RGB raster colours
SKYDAY2 = $147
SKYDAY3 = $157
SKYDAY4 = $167
SKYDAY5 = $177
SKYNIGHT1 = $017							;Sky night
SKYNIGHT2 = $027
SKYNIGHT3 = $037
SKYNIGHT4 = $047
SKYNIGHT5 = $057
SKYBRIGHT = $080							;STe enhanced palette bit for sky

	SECTION	TEXT

;----------------------------------
;Initialise Timer B palette raster effects
rastersinit
	move.l	#0,timerbhandler				;Clear Timer B VBL handler
	move.b	$fffffa1d.w,d0					;Read Timer C+D Control
	and.b	#$70,d0							;Keep just Timer C control bits 4-6
	move.b	d0,rastertimerccontrol
	rts

;----------------------------------
;End Timer B
rasterendtimerb
	addq.l	#1,blankingcount				;Increment Display Blanking counter
	move.b	#0,$fffffa1b.w					;Stop Timer B
	bclr	#0,$fffffa0f.w					;Clear bit 0 (TimerB) in Interrupt In-Service A
	move.w	d0,-(sp)
	move.b	rastertimerccontrol,d0
	or.b	d0,$fffffa1d.w					;Start Timer C in Timer C+D Control
	move.w	(sp)+,d0
	rte

;----------------------------------
;Sky
skyhandler
	and.b	#$8f,$fffffa1d.w				;Stop Timer C in Timer C+D Control so cannot trigger during effects
	cmp.w	#RASTERSET_BLACKOUT,rasterset
	bne.s	.noblackout
	moveq.l	#0,d0							;We're safe to corrupt d0 and a0 in this handler
	lea		$ffff8240.w,a0
	move.l	d0,(a0)+						;Black out entire palette
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.b	#0,$fffffa1b.w					;Stop Timer B to set new count
	move.l	#rasterendtimerb,$120.w			;Set new Timer B vector
	move.b	#161,$fffffa21.w				;Set Timer B Data with lines to count
	bra.s	.starttimerb
.noblackout
	
	move.w	skydaynight,d0					;Set sky day or night rasters
	bne.s	.nightsky
	move.l	#skyday1,$120.w					;Set new Timer B vector
	move.w	#SKYDAY1,$ffff8242.w			;Reset palette (not index 0)
	bra.s	.daysky
.nightsky
	move.l	#skynight1,$120.w
	move.w	#SKYNIGHT1,$ffff8242.w
.daysky
	move.l	#$07770444,$ffff8244.w			;Set game palette
	move.l	#$01200240,$ffff8248.w
	move.l	#$03610774,$ffff824c.w
	move.l	#$00300161,$ffff8250.w
	move.l	#$07000721,$ffff8254.w
	move.l	birdpalette,$ffff8258.w
	move.l	birdpalette+4,$ffff825c.w
	move.b	#0,$fffffa1b.w					;Stop Timer B to set new count
	move.b	#7,$fffffa21.w					;Set Timer B Data with lines to count
.starttimerb
	move.b	#8,$fffffa1b.w					;Set Timer B for Event Count Mode
	bset	#0,$fffffa07.w					;Enable Timer B in Interrupt Enable A
	bset	#0,$fffffa13.w					;Mask Timer B in Interrupt Mask A
	rts

;----------------------------------
;Set next Timer B vector and line count
RASTERSET	MACRO
	move.b	#0,$fffffa1b.w					;Stop Timer B to set new count
	move.l	\1,$120.w						;Set new Timer B vector
	move.b	#\2,$fffffa21.w					;Set Timer B Data with lines to count
	move.b	#8,$fffffa1b.w					;Set Timer B for Event Count Mode
	bclr	#0,$fffffa0f.w					;Clear bit 0 (TimerB) in Interrupt In-Service A
	ENDM

;----------------------------------
;Sky day
skyday1										;Line 7, 'Game Over'
	move.w	#SKYDAY1+SKYBRIGHT,$ffff8242.w
	cmp.w	#RASTERSET_MEDAL,rasterset
	bne.s	.nomedal1
	move.l	#$06100740,$ffff8250.w			;Dark orange, index 8 and Orange, index 9
	move.l	#$07770777,$ffff8254.w			;White, index 10 and White, index 11
.nomedal1
	RASTERSET	#skyday2,1
	rte
skyday2										;Line 8
	move.w	#SKYDAY1,$ffff8242.w
	RASTERSET	#skyday3,1
	rte
skyday3										;Line 9
	move.w	#SKYDAY1+SKYBRIGHT,$ffff8242.w
	RASTERSET	#skyday4,19
	rte
skyday4										;Line 28
	move.w	#SKYDAY2,$ffff8242.w
	RASTERSET	#skyday5,1
	rte
skyday5										;Line 29
	move.w	#SKYDAY1+SKYBRIGHT,$ffff8242.w
	RASTERSET	#skyday6,1
	rte
skyday6										;Line 30
	move.w	#SKYDAY2,$ffff8242.w
	RASTERSET	#skyday7,16
	rte
skyday7										;Line 46
	move.w	#SKYDAY2+SKYBRIGHT,$ffff8242.w
	RASTERSET	#skyday8,1
	rte
skyday8										;Line 47, 'Medal'
	move.w	#SKYDAY2,$ffff8242.w
	cmp.w	#RASTERSET_MEDAL,rasterset
	bne.s	.nomedal2
	move.l	#$06630552,$ffff8250.w			;Beige, index 8 and Dark beige, index 9
	move.l	#$07000721,$ffff8254.w			;Red, index 10 and Light red, index 11
	move.l	medalpalette,$ffff8258.w
	move.l	medalpalette+4,$ffff825c.w
.nomedal2
	RASTERSET	#skyday9,1
	rte
skyday9										;Line 48
	move.w	#SKYDAY2+SKYBRIGHT,$ffff8242.w
	RASTERSET	#skyday10,14
	rte
skyday10									;Line 62
	move.w	#SKYDAY3,$ffff8242.w
	RASTERSET	#skyday11,1
	rte
skyday11									;Line 63
	move.w	#SKYDAY2+SKYBRIGHT,$ffff8242.w
	RASTERSET	#skyday12,1
	rte
skyday12									;Line 64
	move.w	#SKYDAY3,$ffff8242.w
	RASTERSET	#skyday13,12
	rte
skyday13									;Line 76
	move.w	#SKYDAY3+SKYBRIGHT,$ffff8242.w
	RASTERSET	#skyday14,1
	rte
skyday14									;Line 77
	move.w	#SKYDAY3,$ffff8242.w
	RASTERSET	#skyday15,1
	rte
skyday15									;Line 78
	move.w	#SKYDAY3+SKYBRIGHT,$ffff8242.w
	cmp.w	#RASTERSET_GETREADY,rasterset
	bne.s	.nofiretoflap
	move.w	#$0700,$ffff8254.w				;Red, index 10
.nofiretoflap
	RASTERSET	#skyday16,9
	rte
skyday16									;Line 87
	move.w	#SKYDAY4,$ffff8242.w
	RASTERSET	#skyday17,1
	rte
skyday17									;Line 88
	move.w	#SKYDAY3+SKYBRIGHT,$ffff8242.w
	RASTERSET	#skyday18,1
	rte
skyday18									;Line 89
	move.w	#SKYDAY4,$ffff8242.w
	RASTERSET	#skyday19,8
	rte
skyday19									;Line 97
	move.w	#SKYDAY4+SKYBRIGHT,$ffff8242.w
	RASTERSET	#skyday20,1
	rte
skyday20									;Line 98
	move.w	#SKYDAY4,$ffff8242.w
	RASTERSET	#skyday21,1
	rte
skyday21									;Line 99
	move.w	#SKYDAY4+SKYBRIGHT,$ffff8242.w
	RASTERSET	#skyday22,7
	rte
skyday22									;Line 106
	move.w	#SKYDAY5,$ffff8242.w
	RASTERSET	#skyday23,1
	rte
skyday23									;Line 107
	move.w	#SKYDAY4+SKYBRIGHT,$ffff8242.w
	RASTERSET	#skyday24,1
	rte
skyday24									;Line 108, 'Sky'
	move.w	#SKYDAY5,$ffff8242.w
	cmp.w	#RASTERSET_MEDAL,rasterset
	bne.s	.nomedal3
	move.l	birdpalette,$ffff8258.w			;Reset bird palette under medal
	move.l	birdpalette+4,$ffff825c.w
.nomedal3
	RASTERSET	#skyday25,17
	rte
skyday25									;Line 125
	move.w	#$262,$ffff8242.w				;Light green, index 1
	move.l	#$03660565,$ffff8250.w			;Blue, index 8 and Light blue, index 9
	move.l	#$06750252,$ffff8254.w			;Grey, index 10 and Dark green, index 11
	RASTERSET	#skyday26,16
	rte
skyday26									;Line 141
	RASTERSET	#skyday27,20
	rte
skyday27									;Line 161, 'Floor'
	move.l	#$02400361,$ffff8250.w			;Green, index 8 and Light green, index 9
	move.l	#$05310663,$ffff8254.w			;Dark beige, index 10 and Beige, index 11
	addq.l	#1,blankingcount				;Increment Display Blanking counter
	move.b	#0,$fffffa1b.w					;Stop Timer B
	bclr	#0,$fffffa0f.w					;Clear bit 0 (TimerB) in Interrupt In-Service A
	rte

;----------------------------------
;Sky night
skynight1									;Line 7, 'Game Over'
	move.w	#SKYNIGHT1+SKYBRIGHT,$ffff8242.w
	cmp.w	#RASTERSET_MEDAL,rasterset
	bne.s	.nomedal1
	move.l	#$06100740,$ffff8250.w			;Dark orange, index 8 and Orange, index 9
	move.l	#$07770777,$ffff8254.w			;White, index 10 and White, index 11
.nomedal1
	RASTERSET	#skynight2,1
	rte
skynight2									;Line 8
	move.w	#SKYNIGHT1,$ffff8242.w
	RASTERSET	#skynight3,1
	rte
skynight3									;Line 9
	move.w	#SKYNIGHT1+SKYBRIGHT,$ffff8242.w
	RASTERSET	#skynight4,19
	rte
skynight4									;Line 28
	move.w	#SKYNIGHT2,$ffff8242.w
	RASTERSET	#skynight5,1
	rte
skynight5									;Line 29
	move.w	#SKYNIGHT1+SKYBRIGHT,$ffff8242.w
	RASTERSET	#skynight6,1
	rte
skynight6									;Line 30
	move.w	#SKYNIGHT2,$ffff8242.w
	RASTERSET	#skynight7,16
	rte
skynight7									;Line 46
	move.w	#SKYNIGHT2+SKYBRIGHT,$ffff8242.w
	RASTERSET	#skynight8,1
	rte
skynight8									;Line 47, 'Medal'
	move.w	#SKYNIGHT2,$ffff8242.w
	cmp.w	#RASTERSET_MEDAL,rasterset
	bne.s	.nomedal2
	move.l	#$06630552,$ffff8250.w			;Beige, index 8 and Dark beige, index 9
	move.l	#$07000721,$ffff8254.w			;Red, index 10 and Light red, index 11
	move.l	medalpalette,$ffff8258.w
	move.l	medalpalette+4,$ffff825c.w
.nomedal2
	RASTERSET	#skynight9,1
	rte
skynight9									;Line 48
	move.w	#SKYNIGHT2+SKYBRIGHT,$ffff8242.w
	RASTERSET	#skynight10,14
	rte
skynight10									;Line 62
	move.w	#SKYNIGHT3,$ffff8242.w
	RASTERSET	#skynight11,1
	rte
skynight11									;Line 63
	move.w	#SKYNIGHT2+SKYBRIGHT,$ffff8242.w
	RASTERSET	#skynight12,1
	rte
skynight12									;Line 64
	move.w	#SKYNIGHT3,$ffff8242.w
	RASTERSET	#skynight13,12
	rte
skynight13									;Line 76
	move.w	#SKYNIGHT3+SKYBRIGHT,$ffff8242.w
	RASTERSET	#skynight14,1
	rte
skynight14									;Line 77
	move.w	#SKYNIGHT3,$ffff8242.w
	RASTERSET	#skynight15,1
	rte
skynight15									;Line 78
	move.w	#SKYNIGHT3+SKYBRIGHT,$ffff8242.w
	cmp.w	#RASTERSET_GETREADY,rasterset
	bne.s	.nofiretoflap
	move.w	#$0700,$ffff8254.w				;Red, index 10
.nofiretoflap
	RASTERSET	#skynight16,9
	rte
skynight16									;Line 87
	move.w	#SKYNIGHT4,$ffff8242.w
	RASTERSET	#skynight17,1
	rte
skynight17									;Line 88
	move.w	#SKYNIGHT3+SKYBRIGHT,$ffff8242.w
	RASTERSET	#skynight18,1
	rte
skynight18									;Line 89
	move.w	#SKYNIGHT4,$ffff8242.w
	RASTERSET	#skynight19,8
	rte
skynight19									;Line 97
	move.w	#SKYNIGHT4+SKYBRIGHT,$ffff8242.w
	RASTERSET	#skynight20,1
	rte
skynight20									;Line 98
	move.w	#SKYNIGHT4,$ffff8242.w
	RASTERSET	#skynight21,1
	rte
skynight21									;Line 99
	move.w	#SKYNIGHT4+SKYBRIGHT,$ffff8242.w
	RASTERSET	#skynight22,7
	rte
skynight22									;Line 106
	move.w	#SKYNIGHT5,$ffff8242.w
	RASTERSET	#skynight23,1
	rte
skynight23									;Line 107
	move.w	#SKYNIGHT4+SKYBRIGHT,$ffff8242.w
	RASTERSET	#skynight24,1
	rte
skynight24									;Line 108, 'Sky'
	move.w	#SKYNIGHT5,$ffff8242.w
	move.w	#$167,$ffff8256.w				;Sky blue, index 11
	cmp.w	#RASTERSET_MEDAL,rasterset
	bne.s	.nomedal3
	move.l	birdpalette,$ffff8258.w			;Reset bird palette under medal
	move.l	birdpalette+4,$ffff825c.w
.nomedal3
	RASTERSET	#skynight25,17
	rte
skynight25									;Line 125
	move.w	#$050,$ffff8242.w				;Dark green, index 1
	move.l	#$00340770,$ffff8250.w			;Dark blue, index 8 and Yellow, index 9
	move.w	#$045,$ffff8254.w				;Light blue, index 10
	RASTERSET	#skynight26,16
	rte
skynight26									;Line 141
	move.w	#$0060,$ffff8256.w				;Light green, index 11
	RASTERSET	#skynight27,20
	rte
skynight27									;Line 161, 'Floor'
	move.l	#$02400361,$ffff8250.w			;Green, index 8 and Light green, index 9
	move.l	#$05310663,$ffff8254.w			;Dark beige, index 10 and Beige, index 11
	addq.l	#1,blankingcount				;Increment Display Blanking counter
	move.b	#0,$fffffa1b.w					;Stop Timer B
	bclr	#0,$fffffa0f.w					;Clear bit 0 (TimerB) in Interrupt In-Service A
	rte

;----------------------------------

	SECTION	BSS

timerbhandler			ds.l	1			;Address of routine to handle Timer B from VBL (can be 0)
rastertimerccontrol		ds.b	1			;MFP Timer C control bits 4-6
	EVEN
