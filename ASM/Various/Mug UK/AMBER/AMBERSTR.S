;
; Amberstar Music
;
; Music hacked by: MUG U.K (on 15/11/1992)
;

	opt	o+,d+,s-


super	clr.l	-(a7)		; set TAB to 8
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	d0,old_sp

	move.l	$70.w,old_70
	move.w	$ffff8240.w,old_8240

	lea	text(pc),a0	
	bsr	print
	move.b	#12,$fffffc02.w

start	bsr.s	play

wait	move.b	$fffc02,d0
try_sp	cmpi.b	#$39,d0
	bne.s	wait

	bsr.s	stop
	move.b	#8,$fffffc02.w

exit	move.w	old_8240,$ffff8240.w
	move.l	#old_sp,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.l	-(sp)
	trap	#1

play	move.l	#1,d0
	bclr	#0,$484.w
	lea	tune1,a0	; alter this according to table below
	jsr	music
	move.w	#$2700,sr
	move.l	#new_70,$70.w
	move.w	#$2300,sr
exitpl	rts

stop
	move.w	#$2700,sr
	move.l	old_70,$70.w
	move.w	#2,d0
	moveq	#8,d1
stop1	move.b	d1,$ff8800
	clr.b	$ff8802
	addq.l	#1,d1
	dbf	d0,stop1
;	bset	#0,$484.w
	move.w	#$2300,sr
	rts

new_70	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$fff,d0
loop	dbf	d0,loop

 	move.w	#$700,$ffff8240.w
	jsr	music+8
	move.w	#$777,$ffff8240.w
	movem.l	(sp)+,d0-d7/a0-a6
	rte

print	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

text	dc.b	$1b,"E"
	dc.b	"+------------------------------------+",13,10
	dc.b	"| AMBERSTAR by Jochen Hippel/Thalion |",13,10
	dc.b	"+------------------------------------+",13,10,10
	dc.b	"Music ripped by MUG U.K",$bf,13,10,10
	dc.b	"Space to exit.",13,10
	dc.b	0

old_sp	ds.l	1
old_70	ds.l	1
old_8240	ds.w	1
	even

music	incbin "amber.bin"
tune	incbin "amber.tun"
	even

tune1	equ	tune
tune2	equ	tune+$612
tune3	equ	tune+$bae
tune4	equ	tune+$1086
tune5	equ	tune+$16bc
tune6	equ	tune+$1c7c
tune7	equ	tune+$2428
tune8	equ	tune+$2a42
tune9	equ	tune+$31ea
tune10	equ	tune+$3ca0
tune11	equ	tune+$428c
tune12	equ	tune+$4710
tune13	equ	tune+$4b10
tune14	equ	tune+$50d2
tune15	equ	tune+$5dbe
tune16	equ	tune+$6354
