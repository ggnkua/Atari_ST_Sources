; TLT-Letterwriter v0.25 - Coded by Zaphod/TLT in 1991......

	opt 	d+
	
	dc.w	$a000
	dc.w	$a00a
	
	move.w	#1,-(sp)
	pea	-1
	pea	-1
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	
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
	move.b	#$d,(a0)+
	move.w	#$0a,(a1)+
	move.w	#$0d,(a1)+
	move.w	#$0000,(a1)+
	move.b	#32+0,xpos
	addq.l	#2,bytez
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
	move.b	#$1b,(a0)+
	move.b	#$41,(a0)+
	bsr	print
	addq.l	#2,bytez
	sub.b	#1,ypos
	
notup:
	cmp.b	#$50,d1		; Down ?
	bne	notdown
	cmp.b	#32+24,ypos
	bge	notdown
	lea	pbuf2,a1
	move.w	#$1b42,(a1)+
	move.w	#$0000,(a1)+
	move.b	#$1b,(a0)+
	move.b	#$42,(a0)+
	bsr	print
	addq.l	#2,bytez
	add.b	#1,ypos
	
notdown:
	cmp.b	#$4b,d1		; Left ?
	bne	notleft
	cmp.b	#32+0,xpos
	ble	notleft
	lea	pbuf2,a1
	move.w	#$1b44,(a1)+
	move.w	#$0000,(a1)+
	move.b	#$1b,(a0)+
	move.b	#$44,(a0)+
	bsr	print
	addq.l	#2,bytez
	sub.b	#1,xpos
	
notleft:
	cmp.b	#$4d,d1		; Right ?
	bne	notright
	cmp.b	#32+78,xpos
	bge	notright
	lea	pbuf2,a1
	move.w	#$1b43,(a1)+
	move.w	#$0000,(a1)+
	move.b	#$1b,(a0)+
	move.b	#$43,(a0)+
	bsr	print
	addq.l	#2,bytez
	add.b	#1,xpos
	
notright:
	cmp.b	#$3b,d1
	bne	notinv
	lea	pbuf2,a1
	move.b	#$1b,(a0)+
	move.b	#$70,(a0)+
	move.w	#$1b70,(a1)+
	move.w	#$0000,(a1)+
	bsr	print
	addq.l	#2,bytez
	
notinv:
	cmp.b	#$3c,d1
	bne	notnotinv
	lea	pbuf2,a1
	move.b	#$1b,(a0)+
	move.b	#$71,(a0)+
	move.w	#$1b71,(a1)+
	move.w	#$0000,(a1)+
	bsr	print
	addq.l	#2,bytez
	
notnotinv:
	cmp.b	#$41,d1
	bne	not2
	move.b	#$1a,(a0)+
	move.b	#$00,(a0)+
	addq.l	#2,bytez
	
not2:
	cmp.b	#$42,d1
	bne	not4
	move.b	#$1a,(a0)+
	move.b	#$02,(a0)+
	addq.l	#2,bytez
	
not4:
	cmp.b	#$43,d1
	bne	not6
	move.b	#$1a,(a0)+
	move.b	#$04,(a0)+
	addq.l	#2,bytez
	
not6:
	cmp.b	#$44,d1
	bne	not8
	move.b	#$1a,(a0)+
	move.b	#$08,(a0)+
	addq.l	#2,bytez
	
not8:
	cmp.b	#$20,d0
	blt	notval
	cmp.b	#$7d,d0
	bgt	notval
	
	cmp.b	#32+78,xpos
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
filename:	dc.b 'LETTER.TXT',0
	even
handle:		dc.w	0
bytez:		dc.l	0

	section bss
	
temp:		ds.b 	50000
	end