* Blitter Test Coded by Elwood Blues *

syncmode	equ	$ffff820a	vertical sync rate
shiftmode	equ	$ffff8260	shifter mode/resolution
palette		equ	$ffff8240	colour palette

		section	text

		move.l	#0,-(sp)
		move.w	#32,-(sp)
		trap	#1
		lea.l	6(sp),sp
		move.l	d0,save_stack
		lea.l	program_stack,sp
		move.l	$44e.w,save_screen
		move.b	syncmode.w,save_syncmode
		move.b	shiftmode.w,save_shiftmode
		movem.l	palette.w,d0-d7
		movem.l	d0-d7,save_palette
		move.w	#$777,palette.w
		moveq.w	#6,d1
fadeout		rept	3
		move.w	#37,-(sp)
		trap	#14
		addq.l	#2,sp
		endr	
		sub.w	#$111,palette.w
		dbf	d1,fadeout
		lea.l	palette.w,a0
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		move.b	physbase+1,$ffff8201.w
		move.b	physbase+2,$ffff8203.w
		clr.w	-(sp)
		move.l	#-1,-(sp)
		move.l	#-1,-(sp)
		move.w	#5,-(sp)
		trap	#14
		lea.l	12(sp),sp
		movem.l	picture+2,d0-d7
		movem.l	d0-d7,palette.w
		move.w	#7999,d0
		lea.l	picture+34,a0
		move.l	physbase,a1
drawloop	move.l	(a0)+,(a1)+
		dbra	d0,drawloop
		move.w	#37,-(sp)
		trap	#14
		addq.l	#2,sp
		lea.l	delta_data,a5
delta		move.w	(a5)+,cc
		subq.w	#1,cc
		bmi.s	.end
		move.l	physbase,a6
.dlp		move.w	(a5)+,d6
		move.l	(a5)+,d7
		eor.l	d7,(a6,d6.w)
		subq.w	#1,cc
		bpl.s	.dlp
		move.w	#37,-(sp)
		trap	#14
		addq.l	#2,sp
		bra.s	delta
.end	
		
wait		cmpi.b	#$39,$fffffc02.w
		bne.s	wait
		move.b	save_syncmode,syncmode.w
		move.w	save_shiftmode,-(sp)
		move.l	save_screen,-(sp)
		move.l	save_screen,-(sp)
		move.w	#5,-(sp)
		trap	#14
		lea.l	12(sp),sp
		movem.l	save_palette,d0-d7
		movem.l	d0-d7,palette.w
		move.l	save_stack,-(sp)
		move.w	#32,-(sp)
		trap	#1
		lea.l	6(sp),sp
		clr.w	-(sp)
		trap	#1
		
		section	data
		
physbase	dc.l	$78000
logbase		dc.l	$70000
picture		incbin	diskette.pi1
delta_data	incbin	diskette.dlt

		section	bss

cc		ds.w	1		
save_screen	ds.l	1
save_syncmode	ds.b	1
save_shiftmode	ds.w	1		
save_stack	ds.l	1
save_palette	ds.w	16
		ds.l	100
program_stack	ds.l	1

		