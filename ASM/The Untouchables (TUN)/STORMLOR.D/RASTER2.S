;   raster graphic equalizers Version II
;   coded by Tony Bennett
;   devpak v2.23     tabs set at 10



	movea.l	4(sp),a5
	pea	$200.w
	pea	(a5)
	pea	$4a0000
	trap	#1
	lea	$c(sp),sp

	pea	start(pc)
	move	#38,-(sp)
	trap	#14
	addq.l	#6,sp
	
	clr	-(sp)
	trap	#1



*------------------
start	moveq.l	#1,d0
	bsr	music
	
	move.b	#$12,$fffffc02.w

	move.l	$44e.w,a0
	move	#7999,d0
cls	clr.l	(a0)+
	dbf	d0,cls

	bsr	set_ints		; save/install interrupts

scan:	cmp.b	#$39,$fffffc02.w
	bne.s	scan

	bsr	rem_ints		; remove interrupts

	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	
	move.b	#8,$fffffc02.w
	move	#$777,$ffff8240.w
	
	rts



*------------------
keyhand:	move	#$2500,sr
	move.b	$fffffc02.w,ikbd_bin
	bclr	#6,$fffffa11.w
	rte


newvbl:	clr.b	$fffffa1b.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	
	lea	buffer(pc),a0	;clear old wave-forms...
	moveq.l	#0,d5
	rept	25
	move.l	d5,(a0)+
	move.l	d5,(a0)+
	move.l	d5,(a0)+
	move.l	d5,(a0)+
	endr
	
	move.l	#buffer,offset	;pointer to palettes
	
	bsr	music+8
	
	lea	$ffff8800.w,a1
	move.b	#8,(A1)
	move.b	(a1),d0
	asr	d0
	and	#7,d0		;mask out rubbish
	
	lea	bar_1(pc),a0
	move	#$224,(a0)	;give bar a base!!
copy1	move.l	#$00070007,-(a0)
	dbf	d0,copy1
	move	#$006,-(a0)	;fade out...neat huh!!
	move	#$005,-(a0)
	move	#$004,-(a0)
	move	#$003,-(a0)
	move	#$002,-(a0)
	move	#$001,-(a0)

	move.b	#9,(A1)		;and for 2nd bar
	move.b	(a1),d0
	asr	d0
	and	#7,d0
	
	lea	bar_2(pc),a0
	move	#$373,(a0)
copy2	move.l	#$00700070,-(a0)
	dbf	d0,copy2
	move	#$060,-(a0)
	move	#$050,-(a0)
	move	#$040,-(a0)
	move	#$030,-(a0)
	move	#$020,-(a0)
	move	#$010,-(a0)
	
	move.b	#10,(A1)		;repeat for 3rd bar
	move.b	(a1),d0
	asr	d0
	and	#7,d0
	
	lea	bar_3(pc),a0
	move	#$733,(a0)
copy3	move.l	#$07000700,-(a0)
	dbf	d0,copy3
	move	#$600,-(a0)
	move	#$500,-(a0)
	move	#$400,-(a0)
	move	#$300,-(a0)
	move	#$200,-(a0)
	move	#$100,-(a0)
	rte

*------------------
newhbl:	move.l	a0,-(sp)
	move.l	offset(pc),a0
	move	(a0)+,$ffff8240.w	;put the palettes into the border
	move.l	a0,offset
	move.l	(sp)+,a0
	bclr	#0,$fffffa0f.w
	rte



*------------------
set_ints:	move	#$2700,sr
	clr.b	$fffffa07.w
	clr.b	$fffffa09.w	; disable timer c
	move.l	$70.w,oldvbl
	move.l	$120.w,oldhbl
	move.l	$118.w,oldkey
	move.l	#keyhand,$118.w
	move.l	#newhbl,$120.w
	move.l	#newvbl,$70.w
	bset	#0,$fffffa07.w
	bset	#0,$fffffa13.w
	bset	#6,$fffffa09.w	; set kbd irq
	bset	#6,$fffffa15.w
	move	#$2300,sr
	rts

oldvbl	dc.l	0
oldhbl	dc.l	0
oldkey	dc.l	0

*------------------
rem_ints:	move	#$2700,sr
	move.b	#$1e,$fffffa07.w
	move.b	#$64,$fffffa09.w
	move.b	#$1e,$fffffa13.w
	move.l	oldvbl,$70.w
	move.l	oldhbl,$120.w
	move.l	oldkey,$118.w
	move	#$2300,sr
	rts



*------------------
ikbd_bin	dc.b	0
	even

offset	dc.l	0

; enchanted lands ziq ripped by Argonaut!!
music	incbin	enl.mus
	even

buffer	ds.w	50		;start pos. 

	dcb.w	10,0
bar_1	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dcb.w	10,0		;space out each bar
bar_2	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dcb.w	10,0
bar_3	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dcb.w	10,0

buff_end	ds.w	72		;gives 200

