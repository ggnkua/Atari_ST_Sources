; 5 st madmax l}tar, rippat av Joke Of Lynx!
; anv{nd F1-F5 f|r att byta l}t...
;

	clr.l	-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7

	move.l	$44e,$a0
	move.w	#8004,d0
clear_loop:
	move.l	#0,(a0)+
	dbra	d0,clear_loop

	lea	$50600,a1
	lea	tune,a0
	move.w	#$3000,d0
copy_loop:
	move.b	(a0)+,(a1)+
	dbra	d0,copy_loop

	moveq	#0,d0
	jsr	$50600

	move.l	$70,safe_vbl
	move.b	$fffffa07.w,safe_iera
	move.b	$fffffa09.w,safe_ierb
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,safe_colors
	move	sr,safe_sr

	move	#$2700,sr
	move.l	#vbl,$70
	move.b	#0,$fffffa07.w
	move.b	#0,$fffffa09.w
	move	#$2300,sr

key_loop:
	cmp.b	#$39,$fffffc02.w
	bne.s	key_loop

	move	#$2700,sr
	move.l	safe_vbl,$70
	move.b	safe_iera,$fffffa07.w
	move.b	safe_ierb,$fffffa09.w
	move	safe_sr,sr
	movem.l	safe_colors,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.b	#$7,$ffff8800.w
	move.b	#$ff,$ffff8802.w
	rts

vbl:
	move.w	#1945,d0
wait_loop:
	dbra	d0,wait_loop
	move.w	#$707,$ffff8240.w
	jsr	$50612
	clr.w	$ffff8240.w
	cmp.b	#$3b,$fffffc02.w
	beq.s	tune1
	cmp.b	#$3c,$fffffc02.w
	beq.s	tune2
	cmp.b	#$3d,$fffffc02.w
	beq.s	tune3
	cmp.b	#$3e,$fffffc02.w
	beq.s	tune4
	cmp.b	#$3f,$fffffc02.w
	beq.s	tune5
	rte
tune1:
	moveq	#0,d0
	jsr	$50600
	rte
tune2:
	moveq	#1,d0
	jsr	$50600
	rte
tune3:
	moveq	#2,d0
	jsr	$50600
	rte
tune4:
	moveq	#3,d0
	jsr	$50600
	rte
tune5:
	moveq	#4,d0
	jsr	$50600
	rte

safe_vbl:	dc.l	0
safe_colors:	ds.l	16
safe_iera:	dc.b	0
safe_ierb:	dc.b	0
safe_sr:	dc.w	0
tune:	incbin	a:\muzexx\madmax4.muz