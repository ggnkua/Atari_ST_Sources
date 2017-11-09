; Sid Sound Designer (single SIDvoice on Timer A)
; Use middle channel in SSD editor for SID only
; Avoid changing YM address register, for example by calling system VBL / 200hz
;
; Dec 18, 2005
;
; Example of a simple VBL based shell
; around the SSD replaycode.
;
; Will only play at the current VBL frequency.
;
; Anders Eriksson (with slight tweaks by gwEm)
; ae@dhs.nu

;..............................................................................
		section	text

start:		clr.l	-(sp)			;super()
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp		
		move.l	d0,ssp

		lea.l	instrumentdata,a0	;tvs file
		lea.l	notedata,a1		;tri file
		bsr.w	ssd_driver		;init music player

		move.l	$70.w,vbl		;save old vbl
		move.l	#my_vbl,$70.w		;install our vbl
		
		
space:		cmp.b	#$39,$fffffc02.w	;wait for space
		bne.s	space


		move.l	vbl,$70.w		;restore vbl
		bsr.w	ssd_driver+8		;deinit music player

		move.l	ssp,-(sp)		;super()
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp

		clr.w	-(sp)			;pterm()
		trap	#1


my_vbl:		bsr.w	ssd_driver+4		;call music player
		rte

;..............................................................................
ssd_driver:	incbin	ssd_gwem.drv		;SSD replay code
		even
notedata:	incbin	'.\cassiope.tri'	;Music by Floopy/MJJ 
						; (modified to by single SID voice by gwEm)
		even
instrumentdata:	incbin	'.\cassiope.tvs'	;Music by Floopy/MJJ
		even


;..............................................................................
		section	bss
vbl:		ds.l	1
ssp:		ds.l	1