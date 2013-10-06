**********************************************************************
* Ceci est la mega super hyper dement giga whhoooouuuaaaaa reset     *
* demo, en fait, c'est le bonhomme de 7 pixels de haut qui appuie    *
* sur le bouton reset                                                *
* (vous noterez que le sprite N'EST PAS PREDECALE (hahaha!!!)        *
* on ne recule devant rien !!!				             *
* By MLM                                                             *
**********************************************************************

* Reset demo

	clr.l	-(a7)			superviseur
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	
	move.l	#reset,$42a.w		vecteur reset
	move.l	#$31415926,$426.w	reset valide
	
	clr.w	-(a7)			bye
	trap	#1
	
reset	move.w	#$2700,sr
	lea	$80000,a7
	lea	vbl(pc),a0
	move.l	a0,$70.w
	
	move.b	#2,$ffff820a.w		50 Hz
	move.b	#0,$ffff8260.w		basse resolution
	
	move.w	#1,x
	lea	tab_anim(pc),a0
	lea	point_anim(pc),a1
	move.l	a0,(a1)			init table d'animation
	
	move.w	#$780,d0		ecran en $78000
	lea	$ffff8201.w,a0
	movep.w	d0,(a0)
	
	lea	$78000,a0		black is black
	move.w	#7999,d0
eff	clr.l	(a0)+
	dbra	d0,eff
	
	lea	palette(pc),a0		palette
	movem.l	(a0),d0-d1
	movem.l	d0-d1,$ffff8240.w
	
	move.w	#$2300,sr
	
boucle	move.l	$466.w,d0		compteur de vbl
stop	cmp.l	$466.w,d0
	beq.s	stop
	move.l	$466.w,d0
stop1	cmp.l	$466.w,d0
	beq.s	stop1

	lea	$78000,a2
	move.l	a2,a0
	
	move.w	#40*8-1,d0		efface les traces
raz	clr.l	(a2)+
	dbra	d0,raz
	
	lea	image(pc),a1
	lea	56(a1),a1
	
	move.w	#304,d0
	bsr.s	sprite_draw		affiche sprite
	
anim	clr.l	d0
	move.l	point_anim(pc),a1
	move.w	(a1)+,d0
	blt.s	reinit_pointeur
	lea	point_anim(pc),a2
	move.l	a1,(a2)
	lea	image(pc),a1
	add.l	d0,a1
	
	addq.w	#1,x
	move.w	x,d0
	cmpi.w	#304,d0
	beq.s	fin_anim
	
	bsr.s	sprite_draw
	
	bra.s	boucle
	
reinit_pointeur
	lea	tab_anim(pc),a1
	lea	point_anim(pc),a2
	move.l	a1,(a2)
	bra.s	anim	

fin_anim
	move.w	#1000,d4
encore	lea	image(pc),a1
	lea	48(a1),a1
	
	lea	$78000,a0
	move.w	x,d0
	bsr.s	sprite_draw
	dbra	d4,encore
	
	move.l	#0,$426.w	reset invalide
	reset
	lea	$0.w,a7		pile apres reset
	lea	4.w,a0		pc apres reset
	move.l	(a0),a0
	jmp	(a0)		reset !
	
vbl	addq.l	#1,$466.w
	rte

;entr‚e:A0=ad ‚cran,A1=ad sprite
;       D0=x,D1=y*160,D2=w-1,D3=h-1

sprite_draw	movem.l d0-d7/a0-a3,-(a7)
                
                move.l  d0,d7
                andi.w  #$0f,d7
                moveq   #16,d4
                sub.w   d7,d4
                lea	decal,a2
                move.w  d4,(a2)
                andi.w  #$fff0,d0
                lsr.w   #1,d0
                adda.l  d0,a0
                moveq	#7,d7
                
fori            moveq   #0,d0
                moveq	#0,d1
                moveq   #0,d2
                moveq   #0,d3
                moveq   #0,d4
                move.w  d7,-(a7)
                lea	decal,a2
                move.w  (a2),d7
                movea.l a0,a2
                movea.l a1,a3
                moveq	#0,d6
forj            clr.w   d0
                clr.w   d1
                clr.w   d2
                clr.w   d3      
                clr.w   d4
                moveq   #0,d5
                move.w  (a1)+,d5
                lsl.l   d7,d5
                or.l    d5,d0
                or.l    d5,d1
                swap    d1
                moveq   #0,d5
                move.w  (a1)+,d5
                lsl.l   d7,d5
                or.l    d5,d0
                or.l    d5,d2
                swap    d2
                moveq   #0,d5
                move.w  (a1)+,d5        
                lsl.l   d7,d5
                or.l    d5,d0
                or.l    d5,d3
                swap    d3
                moveq   #0,d5
                move.w  (a1)+,d5
                lsl.l   d7,d5
                or.l    d5,d0
                or.l    d5,d4
                swap    d4
                swap    d0
                not.w   d0
                and.w   d0,(a0)
                or.w    d1,(a0)+
                or.w    d2,(a0)+
                or.w    d3,(a0)+
                or.w    d4,(a0)+
                dbra     d6,forj
                
                move.w  (a7)+,d7
                swap    d0
                swap    d1
                swap    d2
                swap    d3
                swap    d4
                not.w   d0
                and.w   d0,(a0)
                or.w    d1,(a0)+
                or.w    d2,(a0)+
                or.w    d3,(a0)+
                or.w    d4,(a0)+
                lea     160(a2),a0
                lea     160(a3),a1
                dbra     d7,fori
                
                movem.l (a7)+,d0-d7/a0-a3
                rts

decal           dc.w    0
x		ds.w	1
palette		dc.w	0,$555,$222,$333
image		incbin a:\reset\complet.bin
		even
tab_anim	dc.w	0,0,8,8,16,16,24,24,32,32,40,40,-1,-1
tab_fin		dc.w	48,48
point_anim	ds.l	1
