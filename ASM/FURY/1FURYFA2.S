screen	equ	$f8000

	opt	d+
	
	section text
	
	pea	0
	move	#$20,-(a7)
	trap	#1
	addq	#6,a7
	
	clr.b	$ffff8260.w
	move.l	#screen,d0
	lea	$ffff8200.w,a0
	lsr.l	#8,d0
	movep	d0,1(a0)
		
	lea	pic_dat,a0
	lea	screen,a1
	move	#(200*40)-1,d0
aff	clr.l	(a1)+	move.l	(a0)+,(a1)+
	dbra	d0,aff
	
	lea	pic_dat,a0
	lea	scro_buf_a,a1
	moveq	#27,d0
cfd	moveq	#1,d1
cfg	move	(a0),(a1)+
	move	8(a0),(a1)+
	move	16(a0),(a1)+
	move	24(a0),(a1)+
	move	32(a0),(a1)+
	move	40(a0),(a1)+
	move	48(a0),(a1)+
	move	56(a0),(a1)+
	dbra	d1,cfg
	lea	16(a1),a1
	lea	160(a0),a0
	dbra	d0,cfd
	
	move.l	#scroll_pos,last_scro
	move.l	#scro_buf_a,scro_a
	move.l	#scro_buf_a,scro_b
	
main	move	#$25,-(a7)
	trap	#14
	addq	#2,a7
	
	move	#3000,d0
efe	dbra	d0,efe	
	clr	$ffff8240.w
	
	bsr	scroll
	
	move	#$777,$ffff8240.w
	
	cmp.b	#$39,$fffffc02.w
	bne.s	main
	
	pea	0
	trap	#1
		
scroll	move.l	scro_a,a0
	move.l	scro_b,scro_a
	move.l	a0,scro_b
	
	move.l	last_scro,a1
	move.l	(a1)+,a2
	tst	(a1)
	bpl.s	zlot
	
	
	lea	scroll_pos,a1
zlot	move.l	a1,last_scro
	
	
	lea	screen+160*100,a1
	moveq	#27,d0	* Hauteur
	jmp	(a2)
	
scro_0	
gizi	set	0
	rept	20
	move	(a0)+,gizi*8(a1)
gizi	set	gizi+1
	endr
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_0
	
	rts
	
scro_1	move	(a0)+,152(a1)
gizi	set	0
	rept	19
	move	(a0)+,gizi*8(a1)
gizi	set	gizi+1
	endr
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_1
	
	rts

scr	set	2
scro_2	
gizi	set	0
	rept	scr
	move	(a0)+,152-(scr-1)*8+gizi*8(a1)
gizi	set	gizi+1
	endr
	
gizi	set	0
	rept	20-scr
	move	(a0)+,gizi*8(a1)
gizi	set	gizi+1
	endr
	lea	160(a1),a1
	addq	#8,a0
	
	dbra	d0,scro_2
	rts

scr	set	3
scro_3	
gizi	set	0
	rept	scr
	move	(a0)+,152-(scr-1)*8+gizi*8(a1)
gizi	set	gizi+1
	endr
gizi	set	0
	rept	20-scr
	move	(a0)+,gizi*8(a1)
gizi	set	gizi+1
	endr
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_3
	
	rts

scr	set	4
scro_4	
gizi	set	0
	rept	scr
	move	(a0)+,152-(scr-1)*8+gizi*8(a1)
gizi	set	gizi+1
	endr
gizi	set	0
	rept	20-scr
	move	(a0)+,gizi*8(a1)
gizi	set	gizi+1
	endr
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_4
	
	rts

scr	set	5
scro_5	
gizi	set	0
	rept	scr
	move	(a0)+,152-(scr-1)*8+gizi*8(a1)
gizi	set	gizi+1
	endr
gizi	set	0
	rept	20-scr
	move	(a0)+,gizi*8(a1)
gizi	set	gizi+1
	endr
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_5
	
	rts
	
scr	set	6
scro_6	
gizi	set	0
	rept	scr
	move	(a0)+,152-(scr-1)*8+gizi*8(a1)
gizi	set	gizi+1
	endr
gizi	set	0
	rept	20-scr
	move	(a0)+,gizi*8(a1)
gizi	set	gizi+1
	endr
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_6
	rts

scr	set	7
scro_7	
gizi	set	0
	rept	scr
	move	(a0)+,152-(scr-1)*8+gizi*8(a1)
gizi	set	gizi+1
	endr
gizi	set	0
	rept	20-scr
	move	(a0)+,gizi*8(a1)
gizi	set	gizi+1
	endr
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_7
	rts

scr	set	8
scro_8	
gizi	set	0
	rept	scr
	move	(a0)+,152-(scr-1)*8+gizi*8(a1)
gizi	set	gizi+1
	endr
gizi	set	0
	rept	20-scr
	move	(a0)+,gizi*8(a1)
gizi	set	gizi+1
	endr
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_8
	rts

scr	set	9
scro_9	
gizi	set	0
	rept	scr
	move	(a0)+,152-(scr-1)*8+gizi*8(a1)
gizi	set	gizi+1
	endr
gizi	set	0
	rept	20-scr
	move	(a0)+,gizi*8(a1)
gizi	set	gizi+1
	endr
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_9
	rts

scr	set	10
scro_10	
gizi	set	0
	rept	scr
	move	(a0)+,152-(scr-1)*8+gizi*8(a1)
gizi	set	gizi+1
	endr
gizi	set	0
	rept	20-scr
	move	(a0)+,gizi*8(a1)
gizi	set	gizi+1
	endr
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_10
	rts

scr	set	11
scro_11	
gizi	set	0
	rept	scr
	move	(a0)+,152-(scr-1)*8+gizi*8(a1)
gizi	set	gizi+1
	endr
gizi	set	0
	rept	20-scr
	move	(a0)+,gizi*8(a1)
gizi	set	gizi+1
	endr
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_11
	rts

scr	set	12
scro_12	
gizi	set	0
	rept	scr
	move	(a0)+,152-(scr-1)*8+gizi*8(a1)
gizi	set	gizi+1
	endr
gizi	set	0
	rept	20-scr
	move	(a0)+,gizi*8(a1)
gizi	set	gizi+1
	endr
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_12
	rts

scr	set	13
scro_13	
gizi	set	0
	rept	scr
	move	(a0)+,152-(scr-1)*8+gizi*8(a1)
gizi	set	gizi+1
	endr
gizi	set	0
	rept	20-scr
	move	(a0)+,gizi*8(a1)
gizi	set	gizi+1
	endr
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_13
	rts

scr	set	14
scro_14	
gizi	set	0
	rept	scr
	move	(a0)+,152-(scr-1)*8+gizi*8(a1)
gizi	set	gizi+1
	endr
gizi	set	0
	rept	20-scr
	move	(a0)+,gizi*8(a1)
gizi	set	gizi+1
	endr
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_14
	rts

scr	set	15
scro_15	
gizi	set	0
	rept	scr
	move	(a0)+,152-(scr-1)*8+gizi*8(a1)
gizi	set	gizi+1
	endr
gizi	set	0
	rept	20-scr
	move	(a0)+,gizi*8(a1)
gizi	set	gizi+1
	endr
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_15
	rts
	
scr	set	16
scro_16	
gizi	set	0
	rept	scr
	move	(a0)+,152-(scr-1)*8+gizi*8(a1)
gizi	set	gizi+1
	endr
gizi	set	0
	rept	20-scr
	move	(a0)+,gizi*8(a1)
gizi	set	gizi+1
	endr
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_16
	rts

scr	set	17
scro_17	
gizi	set	0
	rept	scr
	move	(a0)+,152-(scr-1)*8+gizi*8(a1)
gizi	set	gizi+1
	endr
gizi	set	0
	rept	20-scr
	move	(a0)+,gizi*8(a1)
gizi	set	gizi+1
	endr
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_17
	rts

scr	set	18
scro_18	
gizi	set	0
	rept	scr
	move	(a0)+,152-(scr-1)*8+gizi*8(a1)
gizi	set	gizi+1
	endr
gizi	set	0
	rept	20-scr
	move	(a0)+,gizi*8(a1)
gizi	set	gizi+1
	endr
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_18
	rts

scr	set	19
scro_19	
gizi	set	0
	rept	scr
	move	(a0)+,152-(scr-1)*8+gizi*8(a1)
gizi	set	gizi+1
	endr
gizi	set	0
	rept	20-scr
	move	(a0)+,gizi*8(a1)
gizi	set	gizi+1
	endr
	lea	160(a1),a1
	addq	#8,a0
	dbra	d0,scro_19
	rts

	section data
* Affichage rout
scroll_pos	dc.l	scro_0
	dc.l	scro_1
	dc.l	scro_2
	dc.l	scro_3
	dc.l	scro_4
	dc.l	scro_5
	dc.l	scro_6
	dc.l	scro_7
	dc.l	scro_8
	dc.l	scro_9
	dc.l	scro_10
	dc.l	scro_11
	dc.l	scro_12
	dc.l	scro_13
	dc.l	scro_14
	dc.l	scro_15
	dc.l	scro_16
	dc.l	scro_17
	dc.l	scro_18
	dc.l	scro_19
	dc.w	$ffff

pici	incbin	"bigfonts.pi1"
pic_dat	equ	pici+34

	section bss
last_scro	ds.l	1
scro_a	ds.l	1
scro_b	ds.l	1
scro_buf_a	equ	screen	ds.w	24*30
scro_buf_b	equ	screen+160*30	ds.w	24*30
