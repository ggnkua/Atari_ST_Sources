* This player is extremly flexible in the matter of 
* interval between the calls to it.
*
* I have tried with vbl freqs of 50 to 100 Hz
* and all modules seems to work well in all vbl-freqs.
*
* You can also replace the vbl with a timer.

dspmod32_init:		EQU 28
dspmod32_off:		EQU 32
dspmod32_playeron:	EQU 36
dspmod32_playeroff:	EQU 40
dspmod32_playmusic:	EQU 44
dspmod32_playtime:	EQU 48
dspmod32_modtype:	EQU 52
dspmod32_fx:		EQU 56
not_used:		EQU 60
dspmod32_flags:		EQU 61
dspmod32_surrounddelay:	EQU 62
dspmod32_dsptracks:	EQU 64
dspmod32_playinfos:	EQU 66
dspmod32_samplesets:	EQU 70

	TEXT

* INPUT: 
* a0: mod
dspmod32_play_module:
	move.l	a0,-(sp)
	lea.l	dspmod32_voltab4,a1			*4channel volumetable
	bsr.w	dspmod32_player+dspmod32_modtype	*check mod type
	cmp.w	#4,d0					*if 4, start module
	beq.s	.four
	lea.l	dspmod32_voltab8,a1			*otherwise, use 8channel table
.four:	movea.l	(sp)+,a0
	bsr.w	dspmod32_player+dspmod32_playeron	*start playing
	rts

* INPUT: a0: address to put irq routine into.
install_dspmod32irq:
	move.l	#dspmod32_player+dspmod32_playmusic,(a0)
	rts	

dspmod32_start:
	bsr.w	dspmod32_player+dspmod32_init 		*install Player

	move.w	#$200b,$ffff8932.w 			*DSP-Out-> DAC & DMA-In
	clr.b	$ffff8900.w     			*no DMA-Interrupts
	clr.b	$ffff8936.w     			*record 1 Track
	move.b	#$40,$ffff8921.w 			*16 Bit

* mxalloc - Reserve stram ONLY for audio.
	move.w	#0,-(sp)
	move.l	#8000,-(sp)				* size of dma buffer
	move.w	#$44,-(sp)
	trap	#1
	addq	#8,sp
	move.l	d0,sdmabufadr

	move.b	#$80,$ffff8901.w 			*select Record-Frame-Register
	addq.l	#3,d0
	andi.w	#$fffc,d0
	move.l	d0,d1
	lsr.w	#8,d1
	move.l	d1,$ffff8902.w 				;8903 8905 8907
	move.b	d0,$ffff8907.w
	addi.l	#8000,d0
	move.l	d0,d1
	lsr.w	#8,d1
	move.l	d1,$ffff890e.w
	move.b	d0,$ffff8913.w 

	move.b	#$b0,$ffff8901.w 			*repeated record
	rts

dspmod32_stop:
	clr.b	$ffff8901.w     			*DMA-Stop
	bsr.w	dspmod32_player+dspmod32_playeroff	*stop module
	bsr.w	dspmod32_player+dspmod32_off		*dsp system off
	bsr.w	dspmod32_fix				*load new dsp bootstrap (bugfix)
	rts

dspmod32_fix:
	INCLUDE	DSP_FIX.S				*NoCrew DSP bootstrap-code replacement
	EVEN

dspmod32_voltab4:
	DC.W	$7fff,$7fff,$7fff,$7fff
	DC.W	0,0,0,0

dspmod32_voltab8:
	DC.W	$3fff,$3fff,$3fff,$3fff
	DC.W	$3fff,$3fff,$3fff,$3fff

dspmod32_player:
	INCBIN	DSPMOD.TCE
	EVEN

	BSS

dspmod32_timer:
	DS.W	1
dspmod32_count:
	DS.W	1
sdmabufadr:
	DS.L	1
dspmod32_save_stack:
	DS.L	1
dspmod32_save_vbl:
	DS.L	1