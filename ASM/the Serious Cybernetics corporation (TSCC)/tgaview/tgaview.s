;==============================
;=
;=  24bit tga viewer
;=
;= by ray//.tSCc.	  2002
;==============================

		opt	d-,o+,ow-
		opt	p=68000
		comment	HEAD=%011	; TT RAM + Fastload flag on
		output	.ttp		; Command line tool

		section	text
		bsr.w	init		; Setup sytem
		bsr.w	LoadTga		; Load image	
			
main		pea.l	0.w
		move.w	#$20,-(sp)	; Super()
		trap	#1
		addq.l	#6,sp
		move.l	d0,-(sp)	; Save usp


; Test for 9/12bit color DAC

		lea.l	$ffff8240.w,a2
		bset.b	#3,(a2)
				
		move.w	#$2100,sr	; Wait until next hbl
		stop	#$2100

		bclr.b	#3,(a2)		; Was the bit kept?
		bne.s	.DAC12bit	; Yes, then it is a 12bit DAC

		lea.l	pages(pc),a0	; Select gradient optimized
		moveq.l	#96,d0		; for a 9bit DAC otherwise
		add.l	d0,(a0)
		add.l	d0,8(a0)
		add.l	d0,16(a0)

.DAC12bit

; Save system regs (sloppy, hacked version)
		
		move.w	#$2700,sr	; Disable irqs
		bsr.w	flush
		move.w	$484.w,-(sp)
		move.l	$70.w,-(sp)
		move.l	$ffff8260.w,-(sp); Save as .l for TT compatibility
		move.l	$ffff8200.w,-(sp)
		move.b	$ffff820a.w,-(sp); Works as it gets .w extended
		movem.l	$ffff8240.w,d0-d7
		movem.l	d0-d7,-(sp)	
	
	
; Apply new settings
	
		clr.b	$484.w		; Keyclick off
		clr.b	$ffff8260.w	; ST-Low
		bclr.b	#1,$ffff820a.w	; 60Hz
	
		move.l	Tga.picture,d0	; Validade first screen page
		lsr.w	#8,d0
		move.l	d0,$ffff8200.w
		
		move.l	#vbl,$70.w	; Install interlacer as vbl routine
		
		move.w	#$2300,sr
		
; Mainloop

.wait_esc	cmpi.b	#$01,$fffffc02.w; Stay here until user
		bne.s	.wait_esc	; presses escape

		
; Restore and exit

		bsr.w	flush		; Flush IKBD
		
		move.w	#$2700,sr
		movem.l	(sp)+,d0-d7
		movem.l	d0-d7,$ffff8240.w
		move.b	(sp)+,$ffff820a.w
		move.l	(sp)+,$ffff8200.w
		move.l	(sp)+,$ffff8260.w
		move.l	(sp)+,$70.w
		move.w	(sp)+,$484.w
		move.w	#$2300,sr

		
		move.w	#$20,-(sp)	; Return from supervisor mode
		trap	#1
		addq.l	#6,sp

exit		clr.w	-(sp)		; Pterm0()
		trap	#1


;-----------------------------------------------------------------------------
; Subroutines
		include	'inc\tga.s'	; TGA processing
		include	'inc\c2p.s'	; chunk 2 planar converter
		include	'inc\atari.s'	; System snippets
;-----------------------------------------------------------------------------
		end		