; BOOT DM FROM OTHER DRIVE - JimB

dsetdrv		equ	$0e
dsetpath	equ	$3b

start_code	pea	$100.w		reserve basepage
		pea	start_code-$100	start of base page
		pea	$004a0000
		trap	#1		release memory
		lea	12(sp),sp

		clr.l	-(sp)
		move.w	#32,-(sp)
		trap	#1
		addq.l	#6,sp

; PUT YOUR DRIVE LETTER HERE (MUST BE CAPITAL)
;                         |
;                         V
		move.w	#'D'-'A',-(sp)
		move.w	#dsetdrv,-(sp)
		trap	#1
		addq.l	#4,sp

		pea	gamepath
		move.w	#dsetpath,-(sp)
		trap	#1
		addq.l	#6,sp

		lea	exec_code,a0
		lea	$2000,a1
		move.w	#512-1,d0
copy_code	move.b	(a0)+,(a1)+
		dbra	d0,copy_code
		jmp	$2000

exec_code	pea	blank(pc)
		pea	blank(pc)
		pea	filename(pc)
		pea	$4b0000
		trap	#1
		lea	16(sp),sp
		pea	.reset(pc)	;always reset on return from prog
		move.w	#$26,-(sp)
		trap	#14
.reset		move.l	4.w,-(sp)
		rts

		section	data
filename	dc.b	'dm.prg',0

; PUT YOUR DM GAME PATH HERE
;                        |
;                        V

gamepath	dc.b	'd:\dm',0
		even
blank		dc.l	0
