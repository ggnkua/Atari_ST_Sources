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

;* Get trap #1 address
	pea	get_trap1
	move.w	#$26,-(sp)
	trap	#14
	addq.w	#6,sp

;* Set new trap #1
	pea	set_new_trap1
	move.w	#$26,-(sp)
;	trap	#14
	addq.w	#6,sp

;	clr.l	-(sp)
;	move.w	#$20,-(sp)
;	trap	#1
;	addq.w	#6,sp

;me	move.w	#$b,-(sp)
;	trap	#1
;	addq.w	#2,sp
;	tst.l	d0
;	beq	me
;	move.w	#7,-(sp)
;	trap	#1
;	addq.w	#2,sp

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
	pea	mess
	move.w	#9,-(sp)
	trap	#1
	addq.w	#6,sp

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

;* Set old trap #1
	pea	set_old_trap1
	move.w	#$26,-(sp)
	trap	#14
	addq.w	#6,sp

	move.l	store,sp

	clr.w	-(sp)
	trap	#1

msd
newtrap1
	movea.l	sp,a0
	btst	#$d,(sp)
	bne.s	supervisor
	move.l	usp,a0
	cmp.w	#$b,(a0)
	bne.s	no
	move.l	2(sp),a0
	move.l	#-1,d0
	move.w	#$f00,$ffff8240.w
	move.l	#-1,$ffff9800.w
	rte


supervisor
	addq.l	#8,a0	;falcon fix!
	cmp.w	#$b,(a0)
	bne.s	no
	move.l	sp,a0
;	move.l	2(sp),a0
	move.l	2(a0),a0
	move.l	#-1,d0
	move.w	#$f00,$ffff8240.w
	move.l	#-1,$ffff9800.w
	jmp	(a0)

no
.no	cmp.w	#7,(a0)
	bne.s	.exit
	move.w	#" ",d0
	rte

.exit	
goold	jmp	$deadface.l

c_prnos		move.l	#-1,d0
ret_addr5	jmp	$deadface.l

c_rawcin	move.w	#" ",d0
		bra.s	ret_addr5


get_trap1
	move.l	$84.w,oldtrap1
	move.l	$84.w,goold+2
	rts

set_new_trap1
	move.l	#newtrap1,$84.w
	rts

set_old_trap1
	move.l	oldtrap1,$84.w
	rts

mydta	ds.b	256

	ds.b	256
mystack	dc.l	0

fsfirst	dc.b	"*.gif",0
	even

ttp	dc.b	"g:\apxgif24.ttp",0
	even

mess	dc.b	27,'E'
	dc.b	"POV GIF VIEWER",13,10,10,0
	even

commandline	dc.b	12
		dcb.b	128,0

	section bss

store	ds.l	1
olddta	ds.l	1
oldtrap1	ds.l	1