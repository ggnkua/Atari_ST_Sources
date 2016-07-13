
; Full screen vertical scrolling in 4 pixel steps!
; Uses 4 full screens (2 preshifted), and is easily
; adaptable to 2, 6 or even 8 pixel steps!!!
;
; Original Code (not idea!) by Tony B of the Untouchables
;
; Devpak v2.25     tabs set at 10


; assumed 1 meg machine cos i was in a rush to get this code done...


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
start	move.b	#$12,$fffffc02.w

	move.l	#gfx+2+(160*4),$45a.w

	clr.b	$ffff8260.w
	
	lea	gfx+34(pc),a0	;make copies to 256 boundary
	lea	$d8900,a1		;addresses!
	lea	$e0600,a2		;2 copies: one right after first,
copy1	move	#7999,d0		;to allow for extra screen
.copy_32k	move.l	(a0),(a1)+	;whilst 2nd screen is being
	move.l	(a0)+,(a2)+	;displayed...geddit!!!
	dbf	d0,.copy_32k

	lea	gfx+34+640(pc),a0	;now 4 pixels further
	lea	$e8300,a3
	lea	$f0000,a4
copy2	move	#7999-160,d0
.copy_32k	move.l	(a0),(a3)+
	move.l	(a0)+,(a4)+
	dbf	d0,.copy_32k


*------------------
scan	move	#37,-(sp)
	trap	#14
	addq.l	#2,sp

	cmp.b	#$66,$fffffc02.w	;stop scroll
	beq.s	scan

notok	move.l	scroff(pC),a1
	cmpa.l	#scrend,a1	;flipped 4 screens?
	bne.s	ok
	lea	screens(pc),a2
	cmp.l	#$e0600-1280,(a2)	;screen end?
	bne.s	adder
	move.l	#$d8900,(a2)+	;reset screen offsets!
	move.l	#$e8300,(a2)+
	move.l	#screens,scroff
	bra.s	notok
adder	add.l	#1280,(a2)+	;advance screen 8 lines
	add.l	#1280,(a2)+
	move.l	#screens,scroff
	bra.s	notok

ok	move.l	(a1)+,d0		;set screen!
	move.l	a1,scroff
	lsr	#8,d0
	move.l	d0,$ffff8200.w
	
	cmp.b	#$39,$fffffc02.w
	bne	scan


	move.b	#8,$fffffc02.w
	move.l	#gempal,$45a.w
	
	rts


*------------------
	data
scroff	dc.l	screens

screens	dc.l	$d8900,$e8300
scrend

gempal	dc.w	$777,$700,$070,$000,$007,$707,$077,$555
	dc.w	$333,$733,$373,$773,$337,$737,$377,$000

gfx	ds.b	160*4
	incbin	a:\picture\*.pi1 

* Any PI1 picture will do ?! ..
