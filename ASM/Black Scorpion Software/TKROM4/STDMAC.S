hidemouse		macro				; mouse macros
	dc.w		$A00A
	endm

showmouse		macro
	dc.w		$A009
	endm

setup	macro						; environment control
	move.l	sp,a5
	move.l	$04(a5),a5
	move.l	$0C(a5),d0
	add.l		$14(a5),d0
	add.l		$1C(a5),d0
	add.l		#$100,d0
	push.l	d0
	push.l	a5
	push.w	d0
	push.w	#$4A
	trap		#1
	add.w		#12,sp
	supervisor
	endm

push	macro
	move.\0	\1,-(sp)
	endm
	
pop	macro
	move.\0	(sp)+,\1
	endm

pushall		macro
	movem.l	d0-d7/a0-a6,-(sp)
	endm
	
popall		macro
	movem.l	(sp)+,d0-d7/a0-a6
	endm

supervisor		macro
	clr.l		-(sp)
	move.w	#32,-(sp)
	trap		#1
	addq		#6,sp
	move.l	d0,-(sp)
	endm

user	macro
	move.w	#32,-(sp)
	trap		#1
	addq		#6,sp
	endm
	
col	macro
	IFD		RASTERTEST
	move.w	#$\1,COLOUR
	ENDC
	endm

sendkey		macro
	push.w	\1
	push.w	#4
	push.w	#3
	trap		#13
	addq		#6,sp
	endm
