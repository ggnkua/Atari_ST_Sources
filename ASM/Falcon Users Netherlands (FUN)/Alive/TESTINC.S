	bra	START

	INCLUDE	INCLOAD.I

START:	move.l	4(sp),a5			* mshrink
	move.l	$0c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	addi.l	#$1000,d0
	addi.l	#$100,d0
	move.l	a5,d1
	add.l	d0,d1
	andi.b	#%11111110,d1			* even address
	move.l	d1,sp
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move.w	d0,-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	lea	12(sp),sp

	lea	filename_txt,a1
	bsr	LOAD_INCFILE
	tst.l	d0
	bmi.s	.error

	move.l	a0,bufadr

	pea	success_txt
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp

.error:
	clr.w	-(sp)
	trap	#1

filename_txt:
	DC.B	"PLASMAD.RAW",0
success_txt:
	DC.B	"SUCCESS!!!",$a,$d,0
	EVEN


bufadr:	DS.L	1