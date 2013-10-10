	OUTPUT	"ESSAI.PRG"
	MC68030
	MC68881
	TEXT
	fmove.b	#65,fp0
	fmove.b	#2,fp1
	fmove.b	#64,fp2
	fmul.x	fp0,fp1
	fsub.x	fp2,fp1
	flogn.x	fp1
	fetox.x	fp1
	fmove.w	fp1,-(sp)
	move.w	#2,-(sp)
	move.w	#3,-(sp)
	trap	#13
	addq.l	#6,sp
	move.w	#15,d0
bouc1:	move.w	#$ffff,d1
bouc2:	dbra	d1,bouc2
	dbra	d0,bouc1
	clr.w	-(sp)
	trap	#1
