; Sid Sound Designer (SIDvoices on Timer A/B/D)
; June 7, 2004
;
; Example of a simple VBL based shell
; around the SSD replaycode.
;
; Will only play at the current VBL frequency.
;
; Anders Eriksson
; ae@dhs.nu


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


my_vbl:		movem.l	d0-a6,-(sp)
		bsr.w	ssd_driver+4		;call music player
		movem.l	(sp)+,d0-a6
		rte



		section	data

ssd_driver:	incbin	'ssd_abd.drv'		;SSD replay code
		even
notedata:	incbin	'..\timbral.tri'	;note datas
		even
instrumentdata:	incbin	'..\timbral.tvs'	;instrument datas
		even


		section	bss

vbl:		ds.l	1
ssp:		ds.l	1

		end