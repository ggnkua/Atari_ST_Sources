screen	equ	$f8000

	opt	d+
	section 	text

	pea	0
	move	#$20,-(a7)
	trap	#1
	addq	#6,a7
	
	clr.b	$ffff8260.w
	move.l	#screen,d0
	lsr.l	#8,d0
	lea	$ffff8200.w,a0
	movep	d0,1(a0)
	
	move.l	#scroll_tab,scrol_pos

	lea	pic_dat,a0
	lea	screen,a1
	move	#(200*40)-1,d0
cc	move.l	(a0)+,(a1)+
	dbra	d0,cc
		
main	move	#$25,-(a7)
	trap	#14
	addq	#2,a7
	
	bsr	scroll
	
	cmp.b	#$39,$fffffc02.w
	bne.s	main
	
	pea	0
	trap	#1
	
scroll	
	rts

	data
	
scroll_tab	
gizi	set	0
	rept	24
	dc.w	gizi*2
gizi	set	gizi+1
	endr
	
pic	incbin	"bigfonts.pi1"
pic_dat	equ	pic+34
	
	bss
scrol_pos	ds.l	1
