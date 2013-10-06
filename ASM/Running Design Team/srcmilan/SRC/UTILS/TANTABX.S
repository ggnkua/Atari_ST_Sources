
MAXX		equ	1024


		lea	alphatab(pc),a0
		lea	tantab(pc),a1
		move.w	#MAXX-1,d0
		moveq	#0,d1
loop
		fmove.w	#200,fp0
		fmul.w	d1,fp0
		fdiv.w	#1023,fp0

		fmove.w	#100,fp1
		fsub.x	fp0,fp1		; fp1 = y  ( x = 100 )
		fdiv.w	#100,fp1	; fp1 = y / x  ( = tangens )

		fmove.x	fp1,(a1)+

		fatan.x	fp1
		fmul.w	#128,fp1
		fdiv.x	#3.1415926535,fp1
		fmove.b	fp1,(a0)+

		addq.w	#1,d1

		dbra	d0,loop


		clr.w	-(sp)
		pea	filename1
		move.w	#60,-(sp)
		trap	#1
		addq.l	#8,sp
		move.w	d0,d7

		pea	alphatab(pc)
		move.l	#MAXX,-(sp)
		move.w	d7,-(sp)
		move.w	#64,-(sp)
		trap	#1
		lea	12(sp),sp

		move.w	d7,-(sp)
		move.w	#62,-(sp)
		trap	#1
		addq.l	#4,sp


		clr.w	-(sp)
		pea	filename2
		move.w	#60,-(sp)
		trap	#1
		addq.l	#8,sp
		move.w	d0,d7

		pea	tantab(pc)
		move.l	#MAXX*12,-(sp)
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

filename1	dc.b	"e:\running.040\data\bin\alp1024b.tab",0
filename2	dc.b	"e:\running.040\data\bin\tan1024x.tab",0

		bss


alphatab	ds.b	MAXX
tantab		ds.b	MAXX*12