
;   more graphik equalizers.........by Tony B
;   ammended by Mat of the Untouchables
;   Devpak v2.23		Tabs = 10



	pea	0.w
	move	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	
	clr	-(sp)		;hit lo-res!
	pea	-1.w
	pea	-1.w
	move	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	
	clr	$ffff8240.w
	move.l	#$00700700,$ffff8242.w

	move.l	$70.w,oldvbl

	moveq.l	#1,d0
	bsr	music
	move.l	#musvbl,$70.w

wait	cmp.b	#$39,$fffffc02.w	;space?
	bne.s	wait

	move.l	oldvbl,$70.w

	lea	$ffff8800.w,a0	;clear sound chip
	move.l	#$707ffff,(a0)
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	
	not	$ffff8240.w
	
	clr	-(sp)
	trap	#1

oldvbl 	dc.l	0

*------------------
musvbl:	bsr	music+$8		;play music

	lea	$ffff8800.w,a0
	move.b	#8,(a0)		;get the 3 volumes
	move.b	(a0),d1
	move.b	#9,(a0)
	move.b	(a0),d2
	move.b	#10,(a0)
	move.b	(a0),d3
	and.b	#15,d1		;some musix have waveforms
	and.b	#15,d2		;which exceed 15, so mask out
	and.b	#15,d3		;any rubbish
	
	move.l	$44e.w,a0
	lea	160*100+64(a0),a0
	movea.l	a0,a1
	movea.l	a1,a2
	lea	160*5(a2),a2	;so not to clash bit-planes!
	moveq.b	#0,d4
	move	#$fffe,d5
	moveq	#15-1,d0
bar1	cmp.b	d1,d4
	bgt.s	.clear
	move	d5,(a1)
	move	d5,160(a1)
	move	d5,320(a1)

	move	d5,2(a2)
	move	d5,162(a2)
	move	d5,322(a2)
	bra.s	.next
.clear
	clr	(a1)
	clr	160(a1)
	clr	320(a1)

	clr	2(a2)
	clr	162(a2)
	clr	322(a2)
.next	addq.b	#1,d4
	lea	-320(a1),a1
	lea	320(a2),a2
	dbf	d0,bar1

	movea.l	a0,a1
	addq.l	#8,a1
	movea.l	a1,a2
	lea	160*5(a2),a2
	moveq.b	#0,d4
	moveq	#15-1,d0
bar2	cmp.b	d2,d4
	bgt.s	.clear
	move	d5,(a1)
	move	d5,160(a1)
	move	d5,320(a1)

	move	d5,2(a2)
	move	d5,162(a2)
	move	d5,322(a2)
	bra.s	.next
.clear
	clr	(a1)
	clr	160(a1)
	clr	320(a1)

	clr	2(a2)
	clr	162(a2)
	clr	322(a2)
.next	addq.b	#1,d4
	lea	-320(a1),a1
	lea	320(a2),a2
	dbf	d0,bar2
	
	movea.l	a0,a1
	lea	16(a1),a1
	movea.l	a1,a2
	lea	160*5(a2),a2
	moveq.b	#0,d4
	moveq	#15-1,d0
bar3	cmp.b	d3,d4
	bgt.s	.clear
	move	d5,(a1)
	move	d5,160(a1)
	move	d5,320(a1)

	move	d5,2(a2)
	move	d5,162(a2)
	move	d5,322(a2)
	bra.s	.next
.clear
	clr	(a1)
	clr	160(a1)
	clr	320(a1)

	clr	2(a2)
	clr	162(a2)
	clr	322(a2)
.next	addq.b	#1,d4
	lea	-320(a1),a1
	lea	320(a2),a2
	dbf	d0,bar3
	rte


music:	incbin	enl.mus
