; TLT-Letterwriter v0.25 - Coded by Zaphod/TLT in 1991......

	opt 	d+
	
	dc.w	$a000
	dc.w	$a00a
	
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	lea	6(sp),sp
	move.l	d0,super
	
	clr.w	-(sp)
	pea	-1
	pea	-1
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,palsave
	clr.w	$ffff8240
	move.w	#$777,$ffff8242
	
	lea	temp,a0
	lea	pbuf2,a1
	move.b	#32+0,xpos
	move.b	#32+0,ypos
	move.b	#$1b,(a1)+
	move.b	#$65,(a1)+
	bsr	print
	clr.l	bytez
	
loop:
	lea	pbuf2,a1
	clr.l	d0
	clr.l	d1
	movem.l	a0-a1,-(sp)
	move.w	#7,-(sp)
	trap	#1
	lea	2(sp),sp
	movem.l	(sp)+,a0-a1
	move.l	d0,d1	; d0=ASCII code, d1=KEYCODE
	and.l	#$ffff,d0
	lsr.l	#8,d1
	lsr.l	#8,d1
	and.l	#$ffff,d1
	
	cmp.b	#$1b,d0
	beq	exit
	
	cmp.b	#$d,d0
	bne	not_cr
	
	lea	pbuf2,a1
	move.b	#$a,(a0)+
	move.w	#$0a,(a1)+
	move.w	#$0d,(a1)+
	move.w	#$0000,(a1)+
	move.b	#32+0,xpos
	addq.l	#1,bytez
	cmp.b	#32+24,ypos
	bge	not_cr2
	addq.b	#1,ypos
	
not_cr2:
	bsr	print

not_cr:
	cmp.b	#$8,d0
	bne	not_bs
	
	cmp.b	#32+0,xpos
	ble	not_bs
	lea	pbuf2,a1
	move.b	#$8,(a0)+
	move.b	#$20,(a1)+
	move.b	#$8,(a1)+
	move.b	#0,(a1)+
	sub.b	#1,xpos
	addq.l	#1,bytez
	bsr	print
	
not_bs:
	cmp.b	#$48,d1		; Up?
	bne	notup
	cmp.b	#32+0,ypos
	ble	notup
	lea	pbuf2,a1
	move.w	#$1b41,(a1)+
	move.w	#$0000,(a1)+
	move.b	#$1,(a0)+
	bsr	print
	addq.l	#1,bytez
	sub.b	#1,ypos
	
notup:
	cmp.b	#$50,d1		; Down ?
	bne	notdown
	cmp.b	#32+24,ypos
	bge	notdown
	lea	pbuf2,a1
	move.w	#$1b42,(a1)+
	move.w	#$0000,(a1)+
	move.b	#$2,(a0)+
	bsr	print
	addq.l	#1,bytez
	add.b	#1,ypos
	
notdown:
	cmp.b	#$4b,d1		; Left ?
	bne	notleft
	cmp.b	#32+0,xpos
	ble	notleft
	lea	pbuf2,a1
	move.w	#$1b44,(a1)+
	move.w	#$0000,(a1)+
	move.b	#$3,(a0)+
	bsr	print
	addq.l	#1,bytez
	sub.b	#1,xpos
	
notleft:
	cmp.b	#$4d,d1		; Right ?
	bne	notright
	cmp.b	#32+38,xpos
	bge	notright
	lea	pbuf2,a1
	move.w	#$1b43,(a1)+
	move.w	#$0000,(a1)+
	move.b	#$4,(a0)+
	bsr	print
	addq.l	#1,bytez
	add.b	#1,xpos
	
notright:
	cmp.b	#$3b,d1
	bne	notinv
	lea	pbuf2,a1
	move.b	#$11,(a0)+
	move.w	#$1b70,(a1)+
	move.w	#$0000,(a1)+
	bsr	print
	addq.l	#2,bytez
	
notinv:
	cmp.b	#$3c,d1
	bne	notnotinv
	lea	pbuf2,a1
	move.b	#$12,(a0)+
	move.w	#$1b71,(a1)+
	move.w	#$0000,(a1)+
	bsr	print
	addq.l	#2,bytez
	
notnotinv:
	
not8:
	cmp.b	#$20,d0
	blt	notval
	cmp.b	#$7d,d0
	bgt	notval
	
	cmp.b	#32+38,xpos
	bge	notval
	lea	pbuf2,a1
	move.b	d0,(a0)+
	move.b	d0,(a1)+
	move.b	#$0,(a1)+
	bsr	print
	addq.l	#2,bytez
	addq.b	#1,xpos

notval:
	bra	loop
	
exit:
	move.b	#$00,(a0)+
	move.b	#$00,(a0)+
	addq.l	#2,bytez
	
	lea	pbuf2,a1
	move.l	#$1b711b66,(a1)+
	move.w	#$0000,(a1)+
	bsr	print
	
	clr.w	-(sp)
	pea	filename
	move.w	#$3c,-(sp)
	trap	#1
	lea	8(sp),sp
	move.w	d0,handle
	
	pea	temp
	move.l	bytez,-(sp)
	move.w	handle,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	lea	12(sp),sp
	
	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	lea	4(sp),sp
	
	movem.l	palsave,d0-d7
	movem.l	d0-d7,$ffff8240.w
	
	move.l	super,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	lea	6(sp),sp
	
	dc.w	$a009
	
	clr.w	-(sp)
	trap	#1

print:
	movem.l	a0-a1/d0-d1,-(sp)
	pea	prints
	move.w	#9,-(sp)
	trap	#1
	lea	6(sp),sp
	movem.l	(sp)+,a0-a1/d0-d1
	lea	pbuf2,a1
	rts
	
prints:		dc.b	27,'Y'
ypos:		dc.b	32+0
xpos:		dc.b	32+0
pbuf2:		ds.b	80
	even
filename:	dc.b 'LETT40.TXT',0
	even
handle:		dc.w	0
bytez:		dc.l	0
super:		dc.l	0

	section bss
	
palsave:	ds.w	16
temp:		ds.b 	50000
	end