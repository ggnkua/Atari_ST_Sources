; Atari ST/e synclock demosystem
; January 6, 2008
;
; fullexit.s


		section	text
exit:
		bsr.w	black_pal
		bsr.w	syncfix

		
		move.w	#$2700,sr			;stop interrupts
		lea.l	save_buffer,a0			;restore vectors and mfp
		move.l	(a0)+,$68.w			;
		move.l	(a0)+,$70.w			;
		move.l	(a0)+,$120.w
		move.l	(a0)+,$134.w			;
		move.b	(a0)+,$fffffa07.w		;
		move.b	(a0)+,$fffffa09.w		;
		move.b	(a0)+,$fffffa13.w		;
		move.b	(a0)+,$fffffa15.w		;
		move.b	(a0)+,$fffffa17.w		;
		move.b	(a0)+,$fffffa19.w		;
		move.b	(a0)+,$fffffa1f.w		;
		move.w	#$2300,sr			;start interrupts


		

		ifne	music_ym			;music deinit
		jsr	music_ym_exit			;
		endc					;
		
		ifne	music_sndh			;
		jsr	music_sndh_exit			;
		endc					;
		
		ifne	music_dma			;
		jsr	music_dma_exit			;
		endc					;

		ifne	music_mod			;
		jsr	protracker_exit			;
		endc					;


		move.w	save_res,-(sp)			;restore screenadr & resolution (st)
		move.l	save_phys,-(sp)			;
		move.l	save_log,-(sp)			;
		move.w	#5,-(sp)			;
		trap	#14				;
		lea.l	12(sp),sp			;

		clr.w	$ffff8264.w			;reset left border
		move.b	#0,$ffff820f.w			;reset linewidth

		movem.l	save_pal,d0-d7			;restore palette
		movem.l	d0-d7,$ffff8240.w		;

		move.b	save_keymode,$484.w		;restore keyclick

		move.l	save_stack,-(sp)		;exit supervisor
		move.w	#32,-(sp)			;
		trap	#1				;
		addq.l	#6,sp				;

		clr.w	-(sp)				;pterm()
		trap	#1				;


exit_nostram:	move.l	#text_noram,d0			;if not enough ramfor screens
		bsr.w	print				;
		bsr.w	waitkey				;
		clr.w	-(sp)				;
		trap #1					;
		
		

print:		move.l	d0,-(sp)			;cconws()
		move.w	#9,-(sp)			;
		trap	#1				;
		addq.l	#6,sp				;
		rts					;

waitkey:	move.w	#7,-(sp)			;crawcin()
		trap	#1				;
		addq.l	#2,sp				;
		rts					;


		section	data

text_noram:	dc.b	'Not enough RAM to run this program!',13,10,0
		even
	


		section	bss

save_buffer:	ds.l	6				;save vectors & mfp
save_res:	ds.w	1				;save resolution
save_phys:	ds.l	1				;save psys address
save_log:	ds.l	1				;save logic address
save_keymode:	ds.w	1				;save keyclick
save_stack:	ds.l	1				;user stack
save_pal:	ds.l	8				;save palette
screen_adr:	ds.l	1				;screen 1
screen_adr2:	ds.l	1				;screen 2
screen_adr_base:ds.l	1				;address to both buffers
big_screen_adr:	ds.l	1				;screentop of both buffers


		section	text

