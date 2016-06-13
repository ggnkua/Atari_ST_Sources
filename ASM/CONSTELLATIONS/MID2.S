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
	bsr	save_ints
	move.l	#disty,d0
	move.l	d0,disty1
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
	move.l	shifts,$ff820a
	move.l	shiftr,$ff8260
	movem.l	shiftc,d0-d7
	movem.l	d0-d7,$ff8240
out1	move.l	oldsp,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	add.l	#6,sp
	dc.w	$a009
	clr.w	-(sp)
	trap	#1

cls	dc.b	27,'E',0
pal0	dc.w	$000,$700,$070,$707,$707,$777,$774,$770
	dc.w	$757,$453,$466,$722,$755,$676,$777,$777
	
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
	move.l	#new6b,$120
	move.l	#new4,$70
	move.l	#newkey,$118
	or.b	#$01,$fffa07
	or.b	#$01,$fffa13
	rts

new4	clr.b	$fffa1b
	movem.l	d0-d7/a0-a3,-(sp)
	clr.l	d0
	move.l	#$fffa21,a0
	move.l	disty1,a2
	add.l	#4,a2
	move.l	a2,disty1
	cmp.b	#$ff,(a2)
	bne	nvbl1
	move.l	#disty,disty1
	move.l	disty1,a2
nvbl1	move.b	(a2),d0
	add.b	#2,d0
	move.b	d0,(a0)
	move.b	#$08,-6(a0)
	lea	$ff8240,a0
	movem.l	pal0,d0-d7
	movem.l	d0-d7,(a0)
	movem.l	(sp)+,d0-d7/a0-a3
	move.l	old4,-(sp)
	rts

disty	dc.b	0
stay	ds.l	4
	dc.b	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16
	dc.b	18,20,22,24,26,28,30,32,34,36,38,40,42
	dc.b	45,48,51,54,57,60,63,66,69,72,75
	dc.b	80,85,90,95,100,105,110,115,120,125
	dc.b	125,120,115,110,105,100,95,90,85,80
	dc.b	75,72,69,66,63,60,57,54,51,48,45
	dc.b	42,40,38,36,34,32,30,28,26,24,22,20,18
	dc.b	16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1	
	dc.b	$ff	
	dc.b	$ff	
	dc.b	$ff	
	dc.b	$ff	
	dc.b	$ff	
	dc.b	$ff	
	dc.b	$ff	
	dc.b	$ff	
	dc.b	$ff	
	dc.b	$ff	
	dc.b	$ff	
	dc.b	$ff	
	dc.b	$ff	
	dc.b	$ff	
	dc.b	$ff	
	dc.b	$ff	
	dc.b	$ff	
	dc.b	$ff	
	dc.b	$ff	
	dc.b	$ff	
	dc.b	$ff	
	dc.b	$ff	
	dc.b	$ff	
	dc.b	$ff	
	dc.b	$ff	
	dc.b	$ff	
	dc.b	$ff	
	dc.b	$ff	
disty1	ds.l	1
new6b	clr.b	$fffa1b
	movem.l	d0-d3/a0-a4,-(sp)
	move.l	#$fffa21,a0
	move.l	#$ff8240,a1
	move.b	#$c8,(a0)
	move.b	#$08,-6(a0)
	move.w	#20,d1
	move.l	#blue,a2
drawlc	move.b	(a0),d0
drawlc1	move.w	#40,d2
	cmp.b	(a0),d0
	beq	drawlc1
	mulu	d0,d0
	
	move.w	(a2)+,(a1)
sasa	dbra	d2,sasa	
	dbra	d1,drawlc
	movem.l	(sp)+,d0-d3/a0-a4
	bclr	#00,$fffa0f
	rte
blue1	ds.l	1

blue	incbin	ffill1.pal

newkey	move.w	#$2300,sr
	move.l	oldkey,-(sp)
	rts
	
	end