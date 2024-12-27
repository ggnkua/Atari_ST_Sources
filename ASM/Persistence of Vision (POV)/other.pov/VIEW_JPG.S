;GIF Viewer
	move.l	A7,A5
	move.l	4(A5),A5	;get basepage
	move.l	$C(A5),D0	;text segment
	add.l	$14(A5),D0	;data segment
	add.l	$1C(A5),D0	;unitialized
	add.l	#$100,D0	;basepage size
	move.l	D0,-(sp)
	move.l	A5,-(sp)
	move.w	D0,-(sp)
	move.w	#$4A,-(sp)
	trap	#1
	add.l	#12,sp
	move.l	sp,store
	move.l	#mystack,sp

;* Get DTA
	move.w	#$2f,-(sp)
	trap	#1
	addq.w	#2,sp
	move.l	d0,olddta

;* Set DTA
	pea	mydta
	move.w	#$1a,-(sp)
	trap	#1
	addq.w	#6,sp

;* First search for the first entry of a file
	move.w	#0,-(sp)
	pea	fsfirst
	move.w	#$4e,-(sp)
	trap	#1
	addq.w	#8,sp


loop
	lea	mydta+30,a0
	lea	commandline+1,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

	pea	0
	pea	commandline
	pea	ttp
	move.w	#0,-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	lea	16(sp),sp
 
;* Now do a Fsnext
	move.w	#$4f,-(sp)
	trap	#1
	addq.w	#2,sp
	tst.l	d0
	bmi.s	exit
	bra.s	loop
exit
	move.l	olddta,-(sp)
	move.w	#$1a,-(sp)
	trap	#1
	addq.w	#6,sp


	move.l	store,sp

	clr.w	-(sp)
	trap	#1



mydta	ds.b	256

	ds.b	256
mystack	dc.l	0

fsfirst	dc.b	"*.jpg",0
	even

ttp	dc.b	"apxjpg24.ttp",0
	even


commandline	dc.b	12
		dcb.b	128,0

	section bss
store	ds.l	1
olddta	ds.l	1
