
;   raster graphic equalizers Version I
;   coded by Tony B of the Untouchables
;   devpak v2.23     tabs set at 10


	opt	o+,ow-


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
	rept	25
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	endr
	
	move.l	#buffer,offset	;pointer to palettes
	
	bsr	music+6
	
	lea	$ffff8800.w,a1
	move.b	#8,(A1)
	move.b	(a1),d0
	asr	d0		;DIV by 2 cos we are copying half 
				;up and then other half down..
	and	#7,d0		;mask off lower 8 bits
	move	d0,d1
	
	lea	bar_1(pc),a0	;note how the value decreases
copy1	move	d0,-(a0)		;so does the color value!
	move	d0,-(a0)
	dbf	d0,copy1
	lea	bar_1(pc),a0	;and for second half of bar
.copy	move	d1,(a0)+		;NOTE: I am copying twice coz
	move	d1,(a0)+		;i want bigger bars!!
	dbf	d1,.copy

	move.b	#9,(A1)		;and for 2nd bar
	move.b	(a1),d0
	asr	d0
	and	#7,d0
	move	d0,d1
	
	lea	bar_2(pc),a0
copy2	move	d0,-(a0)
	move	d0,-(a0)
	dbf	d0,copy2
	lea	bar_2(pc),a0
.copy	move	d1,(a0)+
	move	d1,(a0)+
	dbf	d1,.copy
	
	
	move.b	#10,(A1)		;repeat for 3rd bar
	move.b	(a1),d0
	asr	d0
	and	#7,d0
	move	d0,d1
	
	lea	bar_3(pc),a0
copy3	move	d0,-(a0)
	move	d0,-(a0)
	dbf	d0,copy3
	lea	bar_3(pc),a0
.copy	move	d1,(a0)+
	move	d1,(a0)+
	dbf	d1,.copy

	rte

*------------------
newhbl:	move.l	a0,-(sp)
	move.l	offset(pc),a0
	move	(a0)+,$ffff8240.w	;put the palettes into the border
	move.l	a0,offset
	move.l	(sp)+,a0
	rte



*------------------
set_ints:	move	#$2700,sr
	clr.b	$fffffa07.w
	clr.b	$fffffa09.w	; disable timer c
	move.l	$118.w,oldkey
	move.l	$120.w,oldhbl
	move.l	$70.w,oldvbl
	move.l	#keyhand,$118.w
	move.l	#newhbl,$120.w
	move.l	#newvbl,$70.w
	bset	#0,$fffffa07.w
	bset	#0,$fffffa13.w
	bset	#6,$fffffa09.w	; set kbd irq
	bset	#6,$fffffa15.w
	bclr	#3,$fffffa17.w
	move	#$2300,sr
	rts

oldkey	dc.l	0
oldvbl	dc.l	0
oldhbl	dc.l	0

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

; ziq ripped by Tony B from Decade Demo!
music	incbin	realwill.mus
	even

buffer	ds.w	50		;start pos. 

	dcb.w	16,0
bar_1	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dcb.w	16,0		;space out each bar
bar_2	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dcb.w	16,0		;(each bar =32 words)
bar_3	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dcb.w	16,0

buff_end	ds.w	54		;gives 200

