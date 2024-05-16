* 'Anchor' muzak from The Bloodsucker Demo
* ripped by Illegal Exception/The Light Team

	OPT	D+,X+,C+
	dc.w	$a00a

	bsr	SUPER1
	bsr	S_ADD
	bsr	MUZAK

key	cmp.b	#$44,$fffffc02.w
	bne.s	key

	move.w	#$2700,sr
	clr.l	$4d2.w
	move.b	int_a(pc),$fffffa07.w
	move.b	int_b(pc),$fffffa09.w
	move.l	s_hbl(pc),$120.w
	move.l	s_vbl(pc),$70.w
	move.w	s_sr(pc),sr
	movem.l	s_pal(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w
	bsr	CLR_SOUND

	move.l	s_super(pc),-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.w	-(sp)
	trap	#1

CLR_SOUND
	move.l	#$8080000,$ffff8800.w
	move.l	#$9090000,$ffff8800.w
	move.l	#$a0a0000,$ffff8800.w
	move.l	#$707ff00,$ffff8800.w
	move.l	#$e0efe00,$ffff8800.w
	rts
	
SUPER1	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	lea	s_super(pc),a0
	move.l	d0,(a0)
	rts

S_ADD	lea	s_hbl(pc),a0
	move.l	$120.w,(a0)+
	move.l	$70.w,(a0)+
	move.w	sr,(a0)+
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,(a0)
	rts

MUZAK	
	move.b	$ffff8260.w,d0
	and.w	#3,d0
	cmp.w	#2,d0
	bne.s	lo_res
	st	muz_var
lo_res	moveq.w	#1,d0			; 1
	bsr	music
	move.l	#INTERRUPT,$4d2.w
	rts

INTERRUPT
	movem.l	d0-d7/a0-a6,-(sp)
	tst.b	muz_var
	beq.s	not_70Hz
	lea	muz_counter(pc),a0
	subq.w	#1,(a0)
	bne.s	not_70Hz
	move.w	#4,(a0)
	bra.s	exit_muz_int
not_70Hz
	jsr	music+$8
	move.b	#$8,$ffff8800.w
	move.b	$ffff8800.w,d0
	move.b	#$9,$ffff8800.w
	move.b	$ffff8800.w,d1
	move.b	#$a,$ffff8800.w
	move.b	$ffff8800.w,d2
	and.w	#$f,d0
	and.w	#$f,d1
	and.w	#$f,d2
	moveq.b	#0,d4
	moveq.b	#0,d5
	cmp.b	#14,d0
	blo.s	clr_led
	bra.s	set_led
clr_led	moveq.b	#2,d4
set_led	cmp.b	#14,d1
	blo.s	clr_led2
	bra.s	set_led2
clr_led2
	moveq.b	#4,d5
set_led2
	lsr.w	#1,d0
	muls.w	#$10,d1
	muls.w	#$100,d2
	move.b	#$e,$ffff8800.w
	move.b	$ffff8800.w,d3
	and.b	#$f8,d3
	or.b	d4,d3
	or.b	d5,d3
	move.b	d3,$ffff8802.w	
	move.w	d0,$ffff8240.w
	move.w	d2,$ffff8244.w
exit_muz_int
	movem.l	(sp)+,d0-d7/a0-a6
	rts

s_super		dc.l	0
s_hbl		dc.l	0
s_vbl		dc.l	0
s_sr		ds.w	1
int_a		dc.b	0
int_b		dc.b	0
s_pal		ds.w	16
muz_var		ds.b	1
	EVEN
muz_counter	dc.w	4
music	incbin 	B:ANCHOR.MUS

	end
