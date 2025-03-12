* Muzak-driver by Illegal Exception/S.O.T.E.
* -------------------------------------------------------------------------
* YM-2149 muzak by Mad Max/TEX from TLB's "Ooh Crikey Wot A Scorcher"
* ripped by Illegal Exception/Scum Of The Earth using "The Explorer v0.1"
* by AN Cool/TCB/The Union. If U use any of the rips then don't credit me,
* credit AN Cool/TCB instead as The Explorer-cart. makes it so easy...
* -------------------------------------------------------------------------
* Key		Function
* F1	=	Toggle ON/OFF Channel A
* F2	=	Toggle ON/OFF Channel B
* F3	=	Toggle ON/OFF Channel C
* F10	=	Exit player...
* (I am aware of the fact that it sounds like hell when disabling all 3
* channels but I simply don't give a fakk!!! So PISS OFF if U're bothered!)

	OPT	D+,C+,X+

tune_no		EQU	1	; 1 to X to change tune #...

	dc.w	$a00a
	bsr	SUPER1
	bsr	S_ADD
	lea	main_text(pc),a0
	bsr	PRINT_L
	bsr	MUZAK

demo_l	movem.l	d0-a6,-(sp)
	move	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d0-a6

	bsr	INTERRUPT
	bsr	OUTP_TEXT

	move.b	$fffffc02.w,d0
	cmp.b	key,d0
	beq.s	demo_l
	move.b	d0,key
f1	cmp.b	#$3b,$fffffc02.w
	bne.s	f2
	bchg	#0,vol_flg
	beq.s	clr_A
	move	#$4E71,ch_A
	bra.s	f2
clr_A	move	#$7000,ch_A
f2	cmp.b	#$3c,$fffffc02.w
	bne.s	f3
	bchg	#1,vol_flg
	beq.s	clr_B
	move	#$4E71,ch_B
	bra.s	f3
clr_B	move	#$7200,ch_B
f3	cmp.b	#$3d,$fffffc02.w
	bne.s	f10
	bchg	#2,vol_flg
	beq.s	clr_C
	move	#$4E71,ch_C
	bra.s	f10
clr_C	move	#$7400,ch_C

f10	cmp.b	#$44,$fffffc02.w
	bne	demo_l

	move	#$2700,sr
	clr.l	$4d2.w
	bsr	RESET_ADD
	bsr	CLR_SOUND

	move.l	s_super(pc),-(sp)
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	clr	-(sp)
	trap	#1

OUTP_TEXT
	lea	status_textA(pc),a0
	moveq	#0,d0
	move.b	vol_flg(pc),d0
	and	#$1,d0
	mulu	#11,d0
	add	d0,a0
	bsr	PRINT_L

	lea	status_textB(pc),a0
	moveq	#0,d0
	move.b	vol_flg(pc),d0
	and	#$2,d0
	lsr	#1,d0
	mulu	#11,d0
	add	d0,a0
	bsr	PRINT_L

	lea	status_textC(pc),a0
	moveq	#0,d0
	move.b	vol_flg(pc),d0
	and	#$4,d0
	lsr	#2,d0
	mulu	#11,d0
	add	d0,a0
	bsr	PRINT_L
	rts

CLR_SOUND
	move.l	#$8080000,$ffff8800.w
	move.l	#$9090000,$ffff8800.w
	move.l	#$a0a0000,$ffff8800.w
	move.l	#$707ff00,$ffff8800.w
	move.l	#$e0efe00,$ffff8800.w
	rts
	
SUPER1	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	lea	s_super(pc),a0
	move.l	d0,(a0)
	rts

S_ADD	lea	s_buff(pc),a0
	move.l	$120.w,(a0)+
	move.l	$70.w,(a0)+
	move	sr,(a0)+
	move	$484.w,(a0)+
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,(a0)
	rts

RESET_ADD
	lea	s_buff(pc),a0
	move.l	(a0)+,$120.w
	move.l	(a0)+,$70.w
	move	(a0)+,sr
	move	(a0)+,$484.w
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa09.w
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240.w
	rts

PRINT_L	pea	(a0)
	move	#9,-(sp)
	trap	#1
	addq	#6,sp
	rts

MUZAK	bclr	#0,$484.w
	move.l	#$777,$ffff8240.w
	move.b	$ffff8260.w,d0
	and	#3,d0
	cmp	#2,d0
	bne.s	lo_res
	st	muz_var
lo_res	moveq	#tune_no,d0
	bsr	music
	rts

INTERRUPT
	movem.l	d0-a6,-(sp)
	tst.b	muz_var
	beq.s	not_70Hz
	lea	muz_counter(pc),a0
	subq	#1,(a0)
	bne.s	not_70Hz
	move	#4,(a0)
	bra	exit_muz_int
not_70Hz
	jsr	music+$8
	move.b	#$8,$ffff8800.w
	move.b	$ffff8800.w,d0
ch_A	nop
	move.b	d0,$ffff8802.w
	move.b	#$9,$ffff8800.w
	move.b	$ffff8800.w,d1
ch_B	nop
	move.b	d1,$ffff8802.w
	move.b	#$a,$ffff8800.w
	move.b	$ffff8800.w,d2
ch_C	nop
	move.b	d2,$ffff8802.w
	and	#$f,d0
	and	#$f,d1
	and	#$f,d2
	moveq	#0,d4
	moveq	#0,d5
	cmp.b	#14,d0
	blo.s	clr_led
	bra.s	set_led
clr_led	moveq	#2,d4
set_led	cmp.b	#14,d1
	blo.s	clr_led2
	bra.s	set_led2
clr_led2
	moveq	#4,d5
set_led2
	lsr	#1,d0
	mulu	#$10,d1
	mulu	#$100,d2
	move.b	#$e,$ffff8800.w
	move.b	$ffff8800.w,d3
	and.b	#$f8,d3
	or.b	d4,d3
	or.b	d5,d3
	move.b	d3,$ffff8802.w	
	move	d0,$ffff8240.w
	move	d2,$ffff8244.w
exit_muz_int
	movem.l	(sp)+,d0-a6
	rts

s_super		dc.l	0
s_buff		ds.b	46
muz_counter	dc.w	4
muz_var		ds.b	1
vol_flg		ds.b	1
key		ds.b	1
main_text	dc.b	27,'E',27,'b',1,0
status_textA	dc.b	27,'Y',32+0,32+0,'A: ON ',0
		dc.b	27,'Y',32+0,32+0,'A: OFF',0
status_textB	dc.b	27,'Y',32+1,32+0,'B: ON ',0
		dc.b	27,'Y',32+1,32+0,'B: OFF',0
status_textC	dc.b	27,'Y',32+2,32+0,'C: ON ',0
		dc.b	27,'Y',32+2,32+0,'C: OFF',0
	EVEN
music	INCBIN 	A:\OHCRIKEY.TLB\NO_SHEEP.MUS

	END
