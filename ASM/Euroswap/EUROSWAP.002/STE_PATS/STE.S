* the Lord HackBear STE write-protect patch.
* Don't ask me how it works, I dunno.

		pea	mess(pc)
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp
		move.w	#7,-(sp)
		pea	code(pc)
		move.w	#38,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	#$4c0000,-(sp)
		trap	#1

code:		lea	a+2(pc),a3
		move.l	$28.w,(a3)
		lea	$610,a1
		lea	rout(pc),a2
		move.w	#16,d0
loop:		move.l	(a2)+,(a1)+
		dbra	d0,loop
		move.l	#$610,$28.w
		rts

rout:		move.l	2(sp),a1
		cmp.l	$436.w,a1
		bgt.s	a
		move.l	$432.w,a0
		move.l	$436.w,a1
search:		cmp.l	#$9f8,(a0)+
		beq.s	got_it
		cmp.l	a1,a0
		blt.s	search
		bra.s	a
got_it:		move.l	#$a38,-4(a0)
		move.l	a+2(pc),$28.w
a:		jmp	$12345678

		data

mess:		dc.b	27,"E"
		dc.b	"Hackbears STE fix for old ST NEWS issues",13,10
		dc.b	"Insert ST NEWS disk and press any key...",13,10,0
		