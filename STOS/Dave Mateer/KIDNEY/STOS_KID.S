* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* 		   KIDNEY MUSIC PLAYER FOR STOS BASIC 		      *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* To use, simply change the .MUS file (last line of this source code) *
* to whatever Kidney music file you want.   Then assemble it to disk. *
* To call the music in STOS, put the music number in d6 [DREG(6)] and *
* call the bank it is in.  Original code by Zippy of the Medway Boys. *
* Altered for use with STOS by the all amazing...    THANE OF LYNX!!! *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	opt s-				NO SYMBOLS
	cmp #0,d6			COMPARE 0 WITH d6
	beq muzoff			IF 0 GO TO muzoff
	cmp #0,d6			COMPARE 0 WITH d6 (AGAIN)
	bne muzon			GO TO muzon IF NOT 0
        rts				RETURN TO STOS

player	movem.l d0-a6,-(sp)		SAVE REGISTERS
	bsr (MUSIC+8)			CALL PLAYBACK
	movem.l (sp)+,d0-a6		RESTORE REGISTERS
	move.l OLDINT,-(sp)		OLD VBL ON SP
	rts				CALL OLD VBL

muzon	move.l $70.w,OLDINT		SAVE OLD VBL
	move.l d6,d0			MUSIC IN d6 (NO OF TUNE)
	bsr MUSIC 			CALL INIT
	move.l #player,$70.w		INSTALL NEW VBL
	rts

muzoff	move.l OLDINT,$70.w		RESTORE OLD VBL
	move.l #$08080000,$ff8800	CLEAR CHANNEL 1
	move.l #$09090000,$ff8800	CLEAR CHANNEL 2
	move.l #$0a0a0000,$ff8800	CLEAR CHANNEL 3
	rts				RETURN

OLDINT	dc.l 0
MUSIC	incbin "\MUZAXX.THK"		STORE THE .MUS IN MEMORY

