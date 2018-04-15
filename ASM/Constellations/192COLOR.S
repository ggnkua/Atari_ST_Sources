start     move.l    a7,a5
          lea       stack,a7
          move.l    4(a5),a5     
          move.l    $c(a5),d0    
          add.l     $14(a5),d0
          add.l     $1c(a5),d0
          add.l     #$100,d0
          move.l    d0,-(sp)
          move.l    a5,-(sp)
          move      #0,-(sp)
          move      #$4a,-(sp)
          trap      #1
          add.l     #12,sp
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	add.l	#6,sp
	move.l	d0,oldsp
	dc.W	$a00a
	pea	cls
	move.w	#9,-(sp)
	trap	#1
	add.l	#6,sp
	move.b	$ff8260,shiftr
	cmp.b	#$02,$ff8260
	beq	out1
	cmp.b	#$01,$ff8260
	bne 	on1
	clr.b	$ff8260
on1	lea	$ff8240,a0
	lea	shiftc,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	lea	pal0,a1
	movem.l	(a1),d0-d7
	movem.l	d0-d7,(a0)
	move.b	$ff820a,shifts
	move.b	#$02,$ff820a
	pea	keyoff
	clr.w	-(sp)
	move.w	#$19,-(sp)
	trap	#14
	add.l	#$08,sp
	bsr	save_ints
	move.l	#disty,disty1
	bsr	set_ints
key	move.w	#7,-(sp)
	trap	#1
	add.l	#2,sp
	cmp.b	#$1b,d0
	beq	off1
	jmp	key
off1	bsr	old_ints
out	pea	cls
	move.w	#9,-(sp)
	trap	#1
	add.l	#6,sp
	pea	keyon
	clr.w	-(sp)
	move.w	#$19,-(sp)
	trap	#14
	add.l	#8,sp
out1	move.l	oldsp,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	add.l	#6,sp
	dc.w	$a009
	clr.w	-(sp)
	trap	#1

cls	dc.b	27,'E',0
pal0	dc.w	$000,$700,$070,$007,$707,$777,$774,$770
	dc.w	$757,$453,$466,$722,$755,$676,$777,$777
keyon	dc.b	$08,00,00
keyoff	dc.b	$12,00,00	
	ds.l	256
stack	ds.l	1
oldsp	ds.l	1																			
shiftc	ds.w	16
shiftr	ds.w	1
shifts	ds.w	1

save_ints move.l	$118,oldkey
	move.l	$120,mfpb
	move.l	$70,old4
	move.l	#$fffa00,a0
	move.b	7(a0),mfp+7
	move.b	9(a0),mfp+9
	move.b	11(a0),mfp+11
	move.b	13(a0),mfp+13
	move.b	15(a0),mfp+15
	move.b	17(a0),mfp+17
	move.b	19(a0),mfp+19
	move.b	21(a0),mfp+21
	move.b	27(a0),mfp+27
	move.b	33(a0),mfp+33
	rts

back	rte
okey	ds.l	6
oldkey	ds.l	1
mfpb	ds.l	1
mfp	ds.l	18
old4	ds.l	1

old_ints  move.l	oldkey,$118
	move.l	mfpb,$120
	move.l	old4,$70
	move.l	#$fffa00,a0
	move.b	mfp+7,7(a0)
	move.b	mfp+9,9(a0)
	move.b	mfp+11,11(a0)
	move.b	mfp+13,13(a0)
	move.b	mfp+15,15(a0)
	move.b	mfp+17,17(a0)
	move.b	mfp+19,19(a0)
	move.b	mfp+21,21(a0)
	move.b	mfp+27,27(a0)
	move.b	mfp+33,33(a0)
	rts
		
set_ints	and.b	#$fe,$fffa13
	and.b	#$fe,$fffa0f
	and.b	#$fe,$fffa0b
	and.b	#$fe,$fffa07
	and.b	#$df,$fffa09
	move.l	#new6b,$120
	move.l	#new4,$70
	move.l	#newkey,$118
	or.b	#$01,$fffa07
	or.b	#$01,$fffa13
	rts

new4	clr.b	$fffa1b
	movem.l	d0-d7/a0-a2,-(sp)
	move.l	#$fffa21,a0
	move.l	#disty1,a2
	cmp.b	#$ff,(a2)
	bne	nvbl1
	move.l	#disty,disty1
	move.l	disty1,(a2)
nvbl1	move.b	(a2),d0
	add.b	#01,d0
	move.b	d0,(a0)
	move.b	#$08,-6(a0)
	lea	$ff8240,a0
	lea	pal0,a1
	movem.l	(a1),d0-d7
	movem.l	d0-d7,(a0)
	add.l	#1,a2
	move.l	a2,disty1
	movem.l	(sp)+,d0-d7/a0-a2
	rte

disty	dc.b	$00,$02,$1a
	dc.b	$26,$2c,$32,$35,$36,$37,$38,$39,$40	
	dc.b	$40,$40,$40,$40,$40,$40,$40,$40,$40
	dc.b	$40,$40,$40,$40,$40,$40,$40,$40,$40
	dc.b	$40,$39,$38,$37,$36,$35,$32,$2c,$26
	dc.b	$1a,$02,$0,$ff
	
disty1	ds.l	1
new6b	clr.b	$fffa1b
	movem.l	d0-d3/a0-a3,-(sp)
	move.l	#$fffa21,a0
	move.l	#$ff8240,a1
	move.b	#$f4,(a0)
	move.b	#$08,-6(a0)
	move.w	#192,d1
	move.l	#bcol,a2
drawlc	move.b	(a0),d0
drawlc1	cmp.b	(a0),d0
	beq	drawlc1
	mulu	d0,d0
	move.w	(a2)+,(a1)
	dbra	d1,drawlc
	
	movem.l	(sp)+,d0-d3/a0-a3

	bclr	#00,$fffa0f
	rte


bcol        dc.l   $00000001,$00020003,$00040005,$00060007,$01170227,$03370447

            dc.l   $05570667,$07770777,$07770667,$05570447,$03370227,$01170007

            dc.l   $00060005,$00040003,$00020001,$00000101,$02020303,$04040505

            dc.l   $06060707,$07170727,$07370747,$07570767,$07770777,$07770767

            dc.l   $07570747,$07370727,$07170707,$06060505,$04040303,$02020101

            dc.l   $00000100,$02000300,$04000500,$06000700,$07110722,$07330744

            dc.l   $07550766,$07770777,$07770766,$07550744,$07330722,$07110700

            dc.l   $06000500,$04000300,$02000100,$00000110,$02200330,$04400550

            dc.l   $06600770,$07710772,$07730774,$07750776,$07770777,$07770776

            dc.l   $07750774,$07730772,$07710770,$06600550,$04400330,$02200110

            dc.l   $00000010,$00200030,$00400050,$00600070,$01710272,$03730474

            dc.l   $05750676,$07770777,$07770676,$05750474,$03730272,$01710070

            dc.l   $00600050,$00400030,$00200010,$00000011,$00220033,$00440055

            dc.l   $00660077,$01770277,$03770477,$05770677,$07770777,$07770677

            dc.l   $05770477,$03770277,$01770077,$00660055,$00440033,$00220011

            dc.l   $00000000,$00000000,$00000000,$00000000,$00000000,$00000000
            dc.l   $00000000,$00000000,$00000000,$00000000,$00000000,$00000000
            dc.l   $00000000,$00000000,$00000000,$00000000,$00000000,$00000000
            dc.l   $00000000,$00000000,$00000000,$00000000,$00000000,$00000000

newkey	move.w	#$2300,sr
	move.l	oldkey,-(sp)
	rts
	
	end