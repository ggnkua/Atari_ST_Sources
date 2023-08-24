;
; 1st Division by Alastair Brimble
;
; Music hacked by: MUG U.K - 19/2/1992 (in 30 seconds !!)
;

super	clr.l	-(a7)		; set TAB to 8
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	d0,old_sp

	move.l	$70.w,old_70

	lea	text(pc),a0	
	bsr	print
	bsr	mouseoff

start	moveq	#0,d0	;7 tune (0-6)
	bsr	play

wait	move.b	$fffc02,d0
	
try_f1	cmpi.b	#$3b,d0	; F1
	bne.s	try_f2
	moveq	#0,d0
	bsr	data

try_f2	cmpi.b	#$3c,d0	; F2
	bne.s	try_f3
	moveq	#1,d0
	bsr	data

try_f3	cmpi.b	#$3d,d0	; F3
	bne.s	try_f4
	moveq	#2,d0
	bsr	data

try_f4	cmpi.b	#$3e,d0	; F4
	bne.s	try_f5
	moveq	#3,d0
	bsr	data

try_f5	cmpi.b	#$3f,d0	; F5
	bne.s	try_f6
	moveq	#4,d0
	bsr	data

try_f6	cmpi.b	#$40,d0	; F6
	bne.s	try_f7
	moveq	#5,d0
	bsr	data

try_f7	cmpi.b	#$41,d0	; F7
	bne.s	try_f8
	moveq	#6,d0
	bsr	data

try_f8	cmpi.b	#$42,d0	; F8
	bne.s	try_sp
	moveq	#7,d0
	bsr	data

try_sp	cmpi.b	#$39,d0
redo	bne.s	wait

	bsr.s	stop
	bsr	mouseon

exit	move.l	old_70,$70.w
	move.l	#old_sp,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.l	-(sp)
	trap	#1

play	cmp.l	#8,d0
	bge.s	exitpl
	bclr	#0,$484.w
	jsr	data
	move.l	#new_70,$70.w
exitpl	rts

stop	move.w	#2,d0
	moveq	#8,d1
stop1	move.b	d1,$ff8800
	clr.b	$ff8802
	addq.l	#1,d1
	dbf	d0,stop1
	bset	#0,$484.w
	rts

new_70	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$fff,d0
loop	dbf	d0,loop
	move.w	#$700,$ffff8240.w
	jsr	data+4
	move.w	#$777,$ffff8240.w
	movem.l	(sp)+,d0-d7/a0-a6
	rte

print	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

mouseoff	move.l	#moff,-(a7)
	clr.w	-(a7)
	move.w	#$19,-(a7)
	trap	#14
	addq.l	#8,a7
	dc.w	$a00a
	rts

mouseon	move.l	#mon,-(a7)
	clr.w	-(a7)
	move.w	#$19,-(a7)
	trap	#14
	addq.l	#8,a7
	dc.w	$a009
	rts

moff	dc.w	$1212
mon	dc.w	$0808

text	dc.b	$1b,"E"
	dc.b	"+------------------------------+",13,10
	dc.b	"| '1st Division' by A. Brimble |",13,10
	dc.b	"+------------------------------+",13,10,10
	dc.b	"Music ripped by MUG U.K",$bf,13,10,10
	dc.b	"Press f1 - f8 for tunes",13,10,10
	dc.b	"Space to exit.",13,10
	dc.b	0

old_sp	ds.l	1
old_70	ds.l	1
data	incbin "1st_divi.mus"
	even
