
;
; DUMP
;
; May 9, 2005
; Anders Eriksson
; ae@dhs.nu
;
; Odd Skancke
; ozk@atari.org
;
; dspmod.s



dspmod_init:		equ	28
dspmod_off:		equ	32
dspmod_playeron:	equ	36
dspmod_playeroff:	equ	40
dspmod_playmusic:	equ	44
dspmod_playtime:	equ	48
dspmod_modtype:		equ	52
dspmod_fx:		equ	56
dspmod_not_used:	equ	60
dspmod_flags:		equ	61
dspmod_surrounddelay:	equ	62
dspmod_dsptracks:	equ	64
dspmod_playinfos:	equ	66
dspmod_samplesets:	equ	70


dspmod_interpolation:	equ	0
dspmod_surround:	equ	0

		section	text

dspmod_play_module:
		move.l	filebuffer,a0
		lea.l	dspmod_voltab4,a1			;4channel volumetable
		bsr.w	dspmod_player+dspmod_modtype	;check mod type
		cmp.w	#4,d0					;if 4, start module
		beq.s	.four					;
		lea.l	dspmod_voltab8,a1			;otherwise, use 8channel table
.four:
		move.l	filebuffer,a0
		bsr.w	dspmod_player+dspmod_playeron 	;start playing


		tst.w	surround
		beq.s	.nosurr
		bchg    #0,dspmod_player+dspmod_flags 	;toggle surround on/off

.nosurr:	tst.w	interpolation
		beq.s	.nointer
		bchg    #1,dspmod_player+dspmod_flags 	;toggle interpolation on/off

.nointer:	rts



dspmod_vbl:
		bsr.w	dspmod_player+44			;call player
		rts



dspmod_start:	
		bsr.w	dspmod_player+dspmod_init 		;install player

		move.w	#$200b,$ffff8932.w 			;DSP-Out-> DAC & DMA-In
		clr.b	$ffff8900.w     			;no DMA-Interrupts
		clr.b	$ffff8936.w     			;record 1 track
		move.b	#$40,$ffff8921.w 			;16 Bit

		move.b	#$80,$ffff8901.w 			;select record-frame-register
		move.l	dma_pointer,d0				;
		move.l	d0,d1					;
		move.b	d1,$ffff8907.w  			;Basis Low
		lsr.l	#8,d1					;
		move.b	d1,$ffff8905.w  			;Basis Mid
		lsr.l	#8,d1					;
		move.b	d1,$ffff8903.w  			;Basis High
		add.l	#8000,d0				;
		move.l	d0,d1					;
		move.b	d1,$ffff8913.w  			;End Low
		lsr.l	#8,d1					;
		move.b	d1,$ffff8911.w  			;End Mid
		lsr.l	#8,d1					;
		move.b	d1,$ffff890f.w  			;End High

		move.b	#$b0,$ffff8901.w 			;repeated record

		rts


dspmod_stop:
		clr.b	$ffff8901.w     			;DMA-Stop
		bsr.w	dspmod_player+dspmod_playeroff		;stop module
		bsr.w	dspmod_player+dspmod_off		;dsp system off
		bsr.w	dspmod_fix				;load new dsp bootstrap (bugfix)
		rts

; Hello, evl.
; I was told that this program didnt work with XaAES - after starting this
; program, mouse clicks didnt work at all. Now, out of curiosity I looked
; at the sources, and what do I find? Yeah, you forcefeed your handler into
; a specific position, which, as luck will have it, works under n.aes.
; Extremely lucky indeed that no other apps use this list while using
; Dump.ttp ,-))
; XaAES, however, or rather moose.adi, also installs a vbl handler in the
; deferred vbl handler list, which was overwritten here. And when moose
; dont have any notion of time, it takes a VERY LONG time for it to timeout
; and deliver clicks to XaAES ;-))
;
; However, I have changed it so that it now works with XaAES, and in all
; cases other applications also wants a handler in the deferred vbl list,
; see below.
;
; Ozk

dspmod_end:	move.l	#dspmod_vbl,d0				;address of vbl function to...
		bsr.w	dspmod_deinstall_vbi			;..deinstall.
		;clr.l	$04d2.w					;remove vbl routine
		bsr.w	dspmod_stop				;stop player and restore dsp
		bsr.w	restoreaudio				;restore audio hardware
		rts



dspmod_begin:	bsr.w	saveaudio				;save audio hardware
		bsr.w	dspmod_start				;init dspmod
		bsr.w	dspmod_play_module			;start player
		move.l	#dspmod_vbl,d0				;address of vbl handler..
		bsr.w	dspmod_install_vbi			;..to install
		;move.l	#dspmod_vbl,$04d2.w			;place routine on vbl
		rts
		
; There is a pointer to a list of "deferred vbl handlers" at
; address $0456. The size of this list (in pointers) are found
; in $0454. The routines 'dspmod_install_vbi' and 'dspmod_desintall_vbi'
; correctly installs/deinstalls such handlers... almost. The only thing
; missing is creating a larger list if there are no free space left in
; list.

; -> D0 Function to install.
; <- D0 If successful, D0 still contains address of function.
;       If unsucessful, D0 is cleared.
dspmod_install_vbi:
		movem.l	d1/a0,-(sp)
		move.w	$0454.w,d1
		subq.w	#1,d1
		move.l	$0456.w,a0

.search:	tst.l	(a0)+
		beq.s	.found
		dbra	d1,.search
		bra.s	.fail
.found:		move.l	d0,-(a0)
		bra.s	.exit
.fail:		moveq	#0,d0
.exit:		movem.l	(sp)+,d1/a0
		rts

; -> D0 Function to deinstall.
; <- D0 If successful, D0 still contains address of function.
;       If unsucessful, D0 is cleared.
dspmod_deinstall_vbi:
		movem.l	d1/a0,-(sp)
		move.w	$0454.w,d1
		subq.w	#1,d1
		move.l	$0456.w,a0

.search:	cmp.l	(a0)+,d0
		beq.s	.found
		dbra	d1,.search
		bra.s	.fail
.found:		clr.l	-(a0)
		bra.s	.exit
.fail:		moveq	#0,d0
.exit:		movem.l	(sp)+,d1/a0
		rts

		
dspmod_fix:	
		include	'dsp_fix.s'				;NoCrew DSP bootstrap-code replacement


saveaudio:	lea.l	saveaudiobuf,a0
		move.w	$ffff8930.w,(a0)+
		move.w	$ffff8932.w,(a0)+
		move.b	$ffff8934.w,(a0)+
		move.b	$ffff8935.w,(a0)+
		move.b	$ffff8936.w,(a0)+
		move.b	$ffff8937.w,(a0)+
		move.b	$ffff8938.w,(a0)+
		move.b	$ffff8939.w,(a0)+
		move.w	$ffff893a.w,(a0)+
		move.b	$ffff893c.w,(a0)+
		move.b	$ffff8941.w,(a0)+
		move.b	$ffff8943.w,(a0)+
		move.b	$ffff8900.w,(a0)+
		move.b	$ffff8901.w,(a0)+
		move.b	$ffff8920.w,(a0)+
		move.b	$ffff8921.w,(a0)+
		rts

restoreaudio:	lea.l	saveaudiobuf,a0
		move.w	(a0)+,$ffff8930.w
		move.w	(a0)+,$ffff8932.w
		move.b	(a0)+,$ffff8934.w
		move.b	(a0)+,$ffff8935.w
		move.b	(a0)+,$ffff8936.w
		move.b	(a0)+,$ffff8937.w
		move.b	(a0)+,$ffff8938.w
		move.b	(a0)+,$ffff8939.w
		move.w	(a0)+,$ffff893a.w
		move.b	(a0)+,$ffff893c.w
		move.b	(a0)+,$ffff8941.w
		move.b	(a0)+,$ffff8943.w
		move.b	(a0)+,$ffff8900.w
		move.b	(a0)+,$ffff8901.w
		move.b	(a0)+,$ffff8920.w
		move.b	(a0)+,$ffff8921.w
		rts


toggle_interpol:
		btst	#1,dspmod_player+dspmod_flags		;check current mode
		beq.s	.enable					;

.disable:	bclr    #1,dspmod_player+dspmod_flags 		;interpolation off
		move.l	#"Off ",inter_text+10			;
		bra.s	.done

.enable:	bset    #1,dspmod_player+dspmod_flags 		;interpolation on
		move.l	#"On  ",inter_text+10			;

.done:		move.l	#inter_text,d0				;print
		bsr.w	print					;
		bra.w	mainloop				;
		

toggle_surround:
		btst	#0,dspmod_player+dspmod_flags		;check current mode
		beq.s	.enable					;

.disable:	bclr    #0,dspmod_player+dspmod_flags 		;surround off
		move.l	#"Off ",surr_text+10			;
		bra.s	.done

.enable:	bset    #0,dspmod_player+dspmod_flags 		;surround on
		move.l	#"On  ",surr_text+10			;

.done:		move.l	#surr_text,d0				;print
		bsr.w	print					;
		bra.w	mainloop				;


		section	data

		even

dspmod_voltab4:
		dc.w $7fff,$7fff,$7fff,$7fff
		dc.w 0,0,0,0
		even


dspmod_voltab8:
		dc.w $3fff,$3fff,$3fff,$3fff
		dc.w $3fff,$3fff,$3fff,$3fff
		even


dspmod_player:
		incbin 'dspmod.tce'
		even

		section	bss

		even

saveaudiobuf:	ds.w	10

		section	text