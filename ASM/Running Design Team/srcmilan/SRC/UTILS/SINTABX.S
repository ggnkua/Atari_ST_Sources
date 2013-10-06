

		fmove.x	#3.1415926535,fp0
		fmul.x	#2,fp0

		lea	sintab(pc),a0
		move.w	#511,d0
		moveq	#0,d1
loop
		fmove.x	fp0,fp1
		fmul.w	d1,fp1
		fdiv.w	#512,fp1
		fsin.x	fp1

		fmove.x	fp1,(a0)
		lea	16(a0),a0

		addq.w	#1,d1

		dbra	d0,loop


		clr.w	-(sp)
		pea	filename
		move.w	#60,-(sp)
		trap	#1
		addq.l	#8,sp
		move.w	d0,d7

		pea	sintab(pc)
		move.l	#512*16,-(sp)
		move.w	d7,-(sp)
		move.w	#64,-(sp)
		trap	#1
		lea	12(sp),sp

		move.w	d7,-(sp)
		move.w	#62,-(sp)
		trap	#1
		addq.l	#4,sp


		clr.w	-(sp)
		trap	#1


		data

filename	dc.b	"e:\running.040\bindata\sin512x.tab",0


		bss


sintab		ds.b	512*16