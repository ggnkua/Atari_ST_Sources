; Sid Sound Designer (SIDvoices on Timer A/B/D)
; June 7, 2004
;
; Example of a rather system-friendly 200Hz
; Timer-C (OS clock) shell around the SSD
; replaycode.
;
; Anders Eriksson
; ae@dhs.nu


replay_freq:	equ	50			;Hz (max 200)


		section	text

start:		move.l	#init_replay,d0		;init player
		bsr.w	supexec



		move.w	#7,-(sp)		;crawkin() wait for key
		trap	#1
		addq.l	#2,sp


		move.l	#deinit_replay,d0	;deinit player
		bsr.w	supexec

		clr.w	-(sp)			;pterm()
		trap	#1




my_tc:		movem.l	d0-a6,-(sp)
		sub.w	#replay_freq,count	;make an approx replay rate
		bpl.s	.no			;from OS 200Hz clock
		add.w	#200,count
		bsr.w	ssd_driver+4		;call music player
.no:		movem.l	(sp)+,d0-a6
		move.l	tc,-(sp)		;run the OS 200Hz rout
		rts

count:		dc.w	200



init_replay:	lea.l	instrumentdata,a0	;tvs file
		lea.l	notedata,a1		;tri file
		bsr.w	ssd_driver		;init music player

		move.l	$114.w,tc		;save old timer-c
		move.l	#my_tc,$114.w		;install our vbl
		rts


deinit_replay:	move.l	tc,$114.w		;restore timer-c
		bsr.w	ssd_driver+8		;deinit music player
		rts


supexec:	move.l	d0,-(sp)		;supexec()
		move.w	#$26,-(sp)
		trap	#14
		addq.l	#6,sp
		rts



		section	data

ssd_driver:	incbin	'ssd_abd.drv'		;SSD replay code
		even
notedata:	incbin	'..\timbral.tri'	;note datas
		even
instrumentdata:	incbin	'..\timbral.tvs'	;instrument datas
		even


		section	bss

tc:		ds.l	1
ssp:		ds.l	1

		end