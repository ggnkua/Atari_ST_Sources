; Sid Sound Designer (SIDvoices on Timer A/C/D)
; June 7, 2004
;
; Example of a simple Timer-B based shell
; around the SSD replaycode.
;
; Edit the Timer-B init to change replay 
; freqeuncy
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

		move.w	sr,d0
		move.w	#$2700,sr
		lea.l	mfp,a0			;save mfp 
		move.b	$fffffa07,(a0)+
		move.b	$fffffa13,(a0)+
		move.b	$fffffa1b,(a0)+
		move.b	$fffffa21,(a0)+
		bset	#0,$fffffa07		;timer-b setup
		bset	#0,$fffffa13
		move.b	#246,$fffffa21		;2457600/200/246 approx 50Hz
		or.b	#%111,$fffffa1b		;%111 = divide by 200
		bclr	#3,$fffffa1b		;tos 2.05 fix
		move.w	d0,sr


		move.l	$120.w,tb		;save old timer-b
		move.l	#my_tb,$120.w		;install our timer-b
		
		
space:		cmp.b	#$39,$fffffc02.w	;wait for space
		bne.s	space


		move.l	tb,$120.w		;restore timer-b
		bsr.w	ssd_driver+8		;deinit music player

		move.l	ssp,-(sp)		;super()
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp

		clr.w	-(sp)			;pterm()
		trap	#1


my_tb:		movem.l	d0-a6,-(sp)
		bsr.w	ssd_driver+4		;call music player
		movem.l	(sp)+,d0-a6
		rte



		section	data

ssd_driver:	incbin	'ssd_acd.drv'		;SSD replay code
		even
notedata:	incbin	'..\timbral.tri'	;note datas
		even
instrumentdata:	incbin	'..\timbral.tvs'	;instrument datas
		even


		section	bss

tb:		ds.l	1
ssp:		ds.l	1
mfp:		ds.l	1

		end