; Generate bakgrounds for zooming checkerboard


x:		equ	512
y:		equ	512*2

size:		equ	x*y/2

		comment HEAD=%111
		output	.tos

start:
		bsr	generate
		bsr	save

		clr.w	-(sp)
		trap	#1

generate:

		moveq	#0,d2				;scale factor

		move.w	#512-1,d7			;scale levels
.y:
		lea	bgch+256,a0			;chunky dest
		lea	512(a0),a1			;inverse
		lea	(a0),a2
		lea	(a1),a3
		moveq	#1,d0				;start colour
		moveq	#0,d1				;pixel width control
		addq.w	#1,d2
		moveq	#16,d3
		move.w	#512/2-1,d6			;width
.x:
		move.b	d0,(a0)+
		move.b	d3,-(a2)
		move.b	d3,(a1)+
		move.b	d0,-(a3)

		add.w	d2,d1
		cmp.w	#512,d1
		blt.s	.no_change
		sub.w	#512,d1

		addq.w	#1,d0				;next colour dl1
		cmp.w	#30,d0
		blt.s	.no_dl1
		moveq	#1,d0

.no_dl1:	addq.w	#1,d3				;next colour dl2
		cmp.w	#30,d3
		blt.s	.no_dl2
		moveq	#1,d3
.no_dl2:
.no_change:
		dbra	d6,.x
		bsr	clear_space
		bsr	c2p
		dbra	d7,.y

		rts

clear_space:
		movem.l	d0-a6,-(sp)

		lea	bgch,a0
		moveq	#0,d0
		move.w	#512*2-1,d7
.l1:		move.b	(a0),d0
		cmp.b	#15,d0
		ble.s	.ok
		clr.b	d0

.ok:		move.b	d0,(a0)+
		dbra	d7,.l1

		movem.l	(sp)+,d0-a6
		rts

c2p:
		movem.l	d0-a6,-(sp)
		lea	bgch,a0
		move.l	.dstadr,a1
		add.l	#512/2,.dstadr

		move.w	#2-1,d6
.l2:
		move.w	#512/16-1,d7
.l1:
		moveq	#0,d0
		moveq	#0,d2
		moveq	#0,d3
		moveq	#0,d4
		moveq	#0,d5


		rept	16

		lsl.l	#1,d2
		lsl.l	#1,d3
		lsl.l	#1,d4
		lsl.l	#1,d5

		move.b	(a0)+,d0

		move.l	d0,d1
		and.l	#%00000001,d1
		or.l	d1,d2

		move.l	d0,d1
		and.l	#%00000010,d1
		lsr.l	#1,d1
		or.l	d1,d3

		move.l	d0,d1
		and.l	#%00000100,d1
		lsr.l	#2,d1
		or.l	d1,d4

		move.l	d0,d1
		and.l	#%00001000,d1
		lsr.l	#3,d1
		or.l	d1,d5

		endr

		move.w	d2,(a1)+
		move.w	d3,(a1)+
		move.w	d4,(a1)+
		move.w	d5,(a1)+

		dbra	d7,.l1
		add.l	#512/2*511,a1
		dbra	d6,.l2

		movem.l	(sp)+,d0-a6
		rts
.dstadr:	dc.l	buf


		rts


save:		move.w	#0,-(sp)			;fcreate()
		move.l	#fn,-(sp)
		move.w	#$3c,-(sp)
		trap	#1
		addq.l	#8,sp
		move.w	d0,fid

		pea	buf				;fwrite()
		move.l	#size,-(sp)
		move.w	fid,-(sp)
		move.w	#$40,-(sp)
		trap	#1
		lea	12(sp),sp

		move.w	fid,-(sp)			;fclose()
		move.w	#$3e,-(sp)
		trap	#1
		addq.l	#4,sp

		rts


		section	data

fn:		dc.b	'chkbg.4pl',0
		even


		section	bss

fid:		ds.w	1
bgch:		ds.b	512*2
buf:		ds.b	size


		section	text

