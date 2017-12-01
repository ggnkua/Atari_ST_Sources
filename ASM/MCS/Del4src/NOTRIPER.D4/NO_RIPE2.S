
*   "we are not rippers " screen 
* supposed to be coded by the misfits
*   ( joker: code   doctor J:gfx )




* screen de tom awauk pour la trans2
*    low border and raster routs 
*    by sidewinder from defcon 4
* megha thanks to Nucleus from Naos
*    and GUDUL  
*for debugging my fuck'in source code ...
*

*  tom awauk the lame coder ...

	OPT	D+
x	set	8
y	set	8


*  a:\rtgvcom5.S
*
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	
	MOVE.W	#$2700,SR

	move.l	#pal8,thepalencours
	move.l	#ecran2,a1
	move.l	a1,d1
	move.b	#0,d1
	add.l	#256,d1
	move.l	d1,phys2

	move.l	#table,sauvpointable  *sprites

****************************************
	
	move.w	$ffff8260.w,sauv_resol
	move.b	#0,$ffff8260.w

	lea	sauv_pal,a0
	move.l	#$ffff8240,a1
	rept 	8
	move.l	(a1)+,(a0)+
	endr


	move.l	#ECRAN+$100,d0
	clr.b	d0
	move.l	d0,physbase
	move.l	d0,phys1
****************************************
****************************************
* programme de changement de palette 
*lors d'une hbl & border bas (l 199)

int_vbl:	=$70		;adresse du vecteur vbl

initialisation:
	
* init timers et vbl
	move.b	iera,sv_mfp
	move.b	ierb,sv_mfp+1
	move.l	$120,sv_mfp+2
	move.b	imra,sv_mfp+6
	move.l	$70,sauve_vbl
	clr.b	iera
	clr.b	ierb
	move.l	#vbl,$70
	move.l	#timer_b,$120
	or.b	#%00000001,imra
	MOVE.W	#$2300,SR

	bra	suitpre564658


iera:	equ	$fffffa07
ierb:	equ	$fffffa09	
iprb:	equ	$fffffa0d
isra:	equ	$fffffa0f
isrb:	equ	$fffffa11
imra:	equ	$fffffa13
imrb:	equ	$fffffa15
tbcr:	equ	$fffffa1b
tbdr:	equ	$fffffa21


*  cette routine sera active apres la fin du programme

vbl:
	movem.l	a0-a6/d0-d7,-(sp)
	clr.w	vs_flag
	jsr	music+8


*  changement de couleurs en haut de l'ecran

	move.l	#$00000070,$ffff8240.w    ;0 et 1
	move.l	#$06430633,$ffff8244.w  
	move.l	#$07340744,$ffff8248.w  
	move.l	#$06240754,$ffff824c.w  
	move.l	#$07730763,$ffff8250.w  
	move.l	#$06530753,$ffff8254.w  
	move.l	#$07430733,$ffff8258.w  
	move.l	#$07230777,$ffff825c.w    ;14 et 15

	
* init timer b pour la ligne 199

	or.b	#%00000001,iera
	clr.b	tbcr	;timer_b  stop
	move.b	#199,tbdr
	
	move.l	#timer_b,$120	;routine timer b vectorisee
	move.b	#8,tbcr
	movem.l	(sp)+,a0-a6/d0-d7	
	rte

*  fin obligee du vbl	revectorisation sur ancien VBL
*	move.l	sauve_vbl,-(sp)
*	rts
* timer du premier changement de couleur
timer_b	clr.b  	$fffffa1b.w     	;on stoppe le timer
        movem.l	d0-d1/a0-a1,-(sp)
        move.w 	#$fa21,a1
        move.b 	#200,(a1)
        move.b 	#8,$fffffa1b.w

        move.b 	(a1),d0
wait	cmp.b  	(a1),d0		;on attend la derniŠre ligne
        beq    	wait
        clr.b  	$ffff820a.w     	;60 Hz
        	
        moveq  	#4,d0		;une p'tite
wait2	dbf    	d0,wait2		;pause...
                                
        move.b 	#2,$ffff820a.w  	;50 Hz

        movem.l	(sp)+,d0-d1/a0-a1
        bclr   	#0,$fffffa0f.w	;ISRA(reg interruptions en cours)  
	
	move.l	a0,sauva0raster
	move.l	a1,sauva1raster
	move.l	thepalencours,a0
	move.l	#$ffff8240,a1

	rept	16
	move.w	(a0)+,(a1)+    ;0 et 1
	endr	


*	move.l	#$00060777,$ffff8244.w  
*	move.l	#$02220333,$ffff8248.w  
*	move.l	#$05550666,$ffff824c.w  
*	move.l	#$00000100,$ffff8250.w  
*	move.l	#$00010232,$ffff8254.w  
*	move.l	#$01110121,$ffff8258.w  
*	move.l	#$02120222,$ffff825c.w    ;14 et 15
*

	move.l	sauva0raster,a0
	move.l	sauva1raster,a1
	
	bclr	#0,isra
	rte

*=-=-=-=-=-=-=-=-=-=-=-=-=-=-
* nouvelle routine de precalq
* pour les sprites 16*16*4

suitpre564658
	lea	buffer,a1
	moveq.l	#5,d3
	moveq.l	#0,d4
	
theboucle
	lea	spri,a0
	adda.l	d4,a0
	moveq.l	#15,d0  
	moveq	#0,d1
.1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	
	dbra	d0,.1

	lea	-16*16(a1),a0    
	moveq	#14,d0

remplis
	moveq	#15,d1  
totoz4	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+ 
	move.l	(a0)+,(a1)+ 
	move.l	(a0)+,(a1)+ 
	
	dbra	d1,totoz4
	moveq.l	#15,d1
	
rot	roxr.w	(a0)
	roxr.w	8(a0)
	roxr.w	2(a0)
	roxr.w	10(a0)
	roxr.w	4(a0)
	roxr.w	12(a0)
	roxr.w	6(a0)
	roxr.w	14(a0)	
	lea	16(a0),a0 
	dbra	d1,rot

	lea	-16*16(a0),a0

	dbra	d0,remplis		

	add.l	#8*16,d4
	dbra	d3,theboucle

	lea	sauveface,a0
	rept	12
	move.l	physbase,(a0)+
	endr	

********** fin nvel rotation
*=-=-=-=-=-=-=-=-=-=-=-=-=-=-

* a0,a1,a2,d1,d2
*KEYBOARD OFF
	move.b  $fffffa09,souris
        move.b  #0,$fffffa09

*INIT MUSIC
        move.l	#1,d0
	jsr	music

*MUSIC ON VBL
*	move.l	#music+8,$4d2.w

	move.l	physbase,a0
	move.w	#32000/4-1,d0
cls	move.l	#0,(a0)+
	dbra	d0,cls

	move.l	#ho,a2

deb	move.l	#txt,a3

bouclafi

	moveq.l	#0,d3
	move.b	(a3)+,d3
	cmp.b	#255,d3
	beq	deb

	mulu.w	#34*4,d3
	move.l	#font,a4
	adda.l	d3,a4

	move.l	a4,erlsaset
	move.l	#0,d5
ttt
	move.l	physbase,a5
	adda.l	#160*202+153+6,a5

	move.l	erlsaset,a4
	move.l	#33,d4
afilettr
	move.b	(a4,d5),(a5)

	addq.l	#4,a4
	adda.l	#160,a5
	dbra	d4,afilettr

	move.l	physbase,a5
	adda.l	#160*202,a5
	move.l	paphys,a6
	adda.l	#160*202,a6

	move.l	#33,d4
yoyoy	
a	set	0
	rept 19
	move.b	1+a+6(a6),a+6(a5)
	move.b	8+a+6(a6),1+6+a(a5)
a	set	a+8
	endr
	move.b	153+6(a6),152+6(a5)
	adda.l	#160,a5
	adda.l	#160,a6
	dbra	d4,yoyoy
***************************

****************************
* ici le tgv...

	move.l	physbase,a5
	adda.l	#160*202,a5
	move.l	paphys,a6
	adda.l	#160*202,a6

	move.l	#33,d4
*********
* pas de bug (?)
*  par pas de 16,test clavier,15% ?

	movem.l	a0-a3/d0-d3,sauvtgvreg

	movem.l	sauvtgvregin,a0-a3/d0-d3
	addq.l	#1,d0
	cmp.b	#74,d0
	ble	suitedelaffichagedutgv
	moveq	#0,d0

suitedelaffichagedutgv
	move.l	d0,d1
	mulu.w	#33*6,d1
	move.l	#tgv,a0
	adda.l	d1,a0
yobou	
	move.l	physbase,a1
	adda.l	#160-8+160*202,a1
	rept 	33 
	move.l	(a0)+,(a1)+
	move.w	(a0)+,(a1)
	adda.l	#160-4,a1 
	endr
	
scrolagauche
	move.l	#33,d1
scrag
a 	set	0
	rept 19
	move.l	a+8(a6),a(a5)
	move.w	a+12(a6),a+4(a5)
a 	set 	a+8
	endr
	adda.l	#160,a6
	adda.l	#160,a5
	dbra 	d1,scrag

	movem.l	a0-a3/d0-d3,sauvtgvregin
	movem.l	sauvtgvreg,a0-a3/d0-d3

****************************************


*	move.w	#$070,$ffff8240.w

	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	nop
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	nop
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w

*	move.w	#$077,$ffff8240.w





****************************************
* ici le trilogo

	bra	main
dt	move.l	#ho,a2

main	moveq.l	#0,d2
	move.b	(a2)+,d2
	cmp.b	#255,d2
	beq	dt
	mulu.w	#160,d2

	move.l	physbase,a0
	adda.l	#24+40,a0
	adda.l	d2,a0
	move.l	#image,a1

b	set	0
	rept	4+5
	move.l	#b,16(a0)
	move.l	#b,20(a0)
	move.l	#b,24(a0)
	move.l	#b,28(a0)
	adda.l	#160,a0
	endr
	adda.l	#8,a0

	move.l	#23,d1
boucaf1	
	rept 	32/4
	move.l	(a1)+,(a0)+
	endr
	adda.l	#160-32,a0
	dbra	d1,boucaf1
	subq.l	#8,a0
	
 	movem.l	a2-a6/d0/d2-d7,sauvtgvmovem


	move.l	#0,-160(a0)
	move.l	#0,-160+4(a0)
	move.l	#0,-160*2(a0)
	move.l	#0,-160*2+4(a0)


	move.l	#28,d1
boucaf2	
	movem.l	(a1)+,a2-a6/d0/d2-d7   *28*29=812 cycles gagnes
	movem.l	a2-a6/d0/d2-d7,(a0)
	adda.l	#160,a0

	dbra	d1,boucaf2	
	subq.l	#8,a0
	





	move.l	#8,d1
boucaf3	
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	movem.l	(a1)+,a2-a6/d0/d2-d7   *28*29=812 cycles gagnes
	movem.l	a2-a6/d0/d2-d7,(a0)
	adda.l	#160-16,a0

	dbra	d1,boucaf3
	subq.l	#8,a0

	moveq.l	#0,d1  *rajout de derniere minute
a	set	1
	rept	5
	move.l	d1,-160*a(a0)
	move.l	d1,-160*a+4(a0)
	move.l	d1,-160*a+72(a0)
	move.l	d1,-160*a+76(a0)
a	set 	a+1
	endr




	move.l	#9,d1
boucaf4	
	movem.l	(a1)+,a4-a6/d0/d2-d7   *28*29=812 cycles gagnes
	movem.l	a4-a6/d0/d2-d7,(a0)
	adda.l	#40,a0
	movem.l	(a1)+,a4-a6/d0/d2-d7   *28*29=812 cycles gagnes
	movem.l	a4-a6/d0/d2-d7,(a0)
	adda.l	#120,a0

	dbra	d1,boucaf4
	subq.l	#8,a0


	move.l	#0,-160(a0)   *rajout de derniere minute
	move.l	#0,-160+4(a0)
	move.l	#0,-160*2(a0)
	move.l	#0,-160*2+4(a0)


	move.l	#13,d1
boucaf5	
	movem.l	(a1)+,a2-a6/d0/d2-d7   *28*29=812 cycles gagnes
	movem.l	a2-a6/d0/d2-d7,(a0)
	adda.l	#48,a0
	movem.l	(a1)+,a2-a6/d0/d2-d7   *28*29=812 cycles gagnes
	movem.l	a2-a6/d0/d2-d7,(a0)
	adda.l	#160-48,a0

	dbra	d1,boucaf5
	subq.l	#8,a0

	move.l	#19,d1
boucaf6	
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+

	movem.l	(a1)+,a2-a6/d0/d2-d7   *492 cycles par ligne
	movem.l	a2-a6/d0/d2-d7,(a0)    *au lieu de 1120
	adda.l	#48,a0
	movem.l	(a1)+,a2-a6/d0/d2-d7   *628*20=12560 cycles gagnes
	movem.l	a2-a6/d0/d2-d7,(a0)    * y a pas erreur ????
	adda.l	#160-48-16,a0

	dbra	d1,boucaf6

	moveq.l	#4+5,d1
	moveq.l	#0,d0
bdeb2	rept	112/4
	move.l	d0,(a0)+    *350 cycles par ligne..
	endr
	adda.l	#160-112,a0
	dbra	d1,bdeb2
	

**** **** ***  * *****
*    *  * *  *     *
**** **** * *  *   *
   * *    ***  *   *
**** *    *  * *   *

***********






***********
*. affichage sprit

	move.l	sauvpointable,a5
	bra	zozo

retoursiarrivealafinduprexy
	move.l	#table,a5
zozo

	addq.l	#3,a5
	cmp.l	#fintable,a5		
	bgt	retoursiarrivealafinduprexy

	move.l	a5,a4

	move.l	#5,d7
	move.l	#4096*6,lekel

	lea	sauveface,a6

ffred
*	move.w	#$222,$ff8240

	lea	buffer,a0
	sub.l	#4096,(lekel)
	adda.l	(lekel),a0
merde
*	move.b	2(a5),d0    *decalage
*	mulu.w	#16*16,d0   *un asl serait plus cool
*best optimized:
	move.b	2(a5),d0 *dessus/sous 
	cmp.b	#16,d0  *en fnct de Y
	bge	sprdessous

	move.b	2(a5),d0
	lsl	#8,d0  *ya plus rapide avec SP
*	cmp.b	#16,d0

	adda.l	d0,a0
**	adda.l	#(16*16)*5,a0

	move.l	physbase,a1
**	adda.l	#160*16+24,a1
*	adda.L	#160*100+80,a1
	moveq.l	#0,d0
	move.b	(a4),d0    *a4 !!!!!!!!
	mulu.w	#160,d0
**	add.b	1(a5),d0
	moveq.l	#0,d1
	move.b	1(a5),d1
	add.w	d1,d0
	adda.l	d0,a1

	move.l	a1,(a6)+

eiruvzertvfhri
	
*****************************************
*  affichage  1  (par dessus le fond)
*
***	moveq	#0,d1
***	moveq	#0,d2

	moveq.w	#15,D0

boucspr
	*masque 16 premiers pix
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	move.w	(a0)+,d3
	move.w	(a0)+,d4


	move.w	d1,d5
	or.w	d2,d5
	or.w	d3,d5
	or.w	d4,d5
	not 	d5

	*fond and NOT masque or sprite

	move.w	d5,d6  * 
	and.w	(a1),d6  * 1er bitplan
	or.w	d1,d6  * 16 pix
	move.w	d6,(a1)+

	move.w	d5,d6  * 
	and.w	(a1),d6  * 2eme bitplan
	or.w	d2,d6  * 16 pix
	move.w	d6,(a1)+
*
	move.w	d5,d6  * 
	and.w	(a1),d6  * 3eme bitplan
	or.w	d3,d6  * 16 pix
	move.w	d6,(a1)+
*
	move.w	d5,d6  * 
	and.w	(a1),d6  * 4eme bitplan
	or.w	d4,d6  * 16 pix
	move.w	d6,(a1)+
*
************

*masque 16 derniers pix
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	move.w	(a0)+,d3
	move.w	(a0)+,d4

	move.w	d1,d5
	or.w	d2,d5
	or.w	d3,d5
	or.w	d4,d5
	not 	d5

	*fond and NOT masque or sprite

	move.w	d5,d6  * 
	and.w	(a1),d6  * 2eme bitplan
	or.w	d1,d6  * 16 pix
	move.w	d6,(a1)+
	
*
	move.w	d5,d6  * 
	and.w	(a1),d6  * 2eme bitplan
	or.w	d2,d6  * 16 pix
	move.w	d6,(a1)+
*
	move.w	d5,d6  * 
	and.w	(a1),d6  * 3eme bitplan
	or.w	d3,d6  * 16 pix
	move.w	d6,(a1)+
*
	move.w	d5,d6  * 
	and.w	(a1),d6  * 4eme bitplan
	or.w	d4,d6  * 16 pix
	move.w	d6,(a1)+
*

************

	adda.l	#160-16,a1
***	adda.l	#16,a0

	dbra	d0,boucspr


*****************************************

*	dbra	d0,eiruvzertvfhri


	adda.l	#x*3,a5
	adda.l	#y*3,a4

	dbra	d7,ffred
	bra	zozo34

*zozo34
*	suba.l	#24*6,a5	
*	jsr	vsync

*	move.w	#$227,$ff8240
*efaspr
*	bra	zozo


********************************
* et ca ca passe dessous !!!

sprdessous
	move.b	2(a5),d0
	sub.w	#16,d0 *obligatoire?
	lsl	#8,d0
	adda.l	d0,a0
**	adda.l	#(16*16)*5,a0

	move.l	physbase,a1
**	adda.l	#160*16+24,a1
*	adda.L	#160*100+80,a1
	moveq.l	#0,d0
	move.b	(a4),d0    *a4 !!!!!!!!
	mulu.w	#160,d0
**	add.b	1(a5),d0
	moveq.l	#0,d1
	move.b	1(a5),d1
	add.w	d1,d0
	adda.l	d0,a1

	move.l	a1,(a6)+

eiruvzertvfhri2
	
*****************************************
*  affichage  1  (par dessus le fond)
*
***	moveq	#0,d1
***	moveq	#0,d2

	moveq.w	#15,D0

boucspr2
	*masque 16 premiers pix
	move.w	0(a1),d1
	move.w	2(a1),d2
	move.w	4(a1),d3
	move.w	6(a1),d4


	move.w	d1,d5
	or.w	d2,d5
	or.w	d3,d5
	or.w	d4,d5
	not 	d5

    *sprite and NOT masqfond or fond

	move.w	d5,d6  * 
	and.w	(a0)+,d6  * 1er bitplan
	or.w	d1,d6  * 16 pix
	move.w	d6,(a1)+

	move.w	d5,d6  * 
	and.w	(a0)+,d6  * 2eme bitplan
	or.w	d2,d6  * 16 pix
	move.w	d6,(a1)+
*
	move.w	d5,d6  * 
	and.w	(a0)+,d6  * 3eme bitplan
	or.w	d3,d6  * 16 pix
	move.w	d6,(a1)+
*
	move.w	d5,d6  * 
	and.w	(a0)+,d6  * 4eme bitplan
	or.w	d4,d6  * 16 pix
	move.w	d6,(a1)+
*
************

*masque 16 derniers pix
	move.w	(a1),d1
	move.w	2(a1),d2
	move.w	4(a1),d3
	move.w	6(a1),d4

	move.w	d1,d5
	or.w	d2,d5
	or.w	d3,d5
	or.w	d4,d5
	not 	d5

	*spr and NOT masqfnd or fnd

	move.w	d5,d6  * 
	and.w	(a0)+,d6  * 2eme bitplan
	or.w	d1,d6  * 16 pix
	move.w	d6,(a1)+
	
*
	move.w	d5,d6  * 
	and.w	(a0)+,d6  * 2eme bitplan
	or.w	d2,d6  * 16 pix
	move.w	d6,(a1)+
*
	move.w	d5,d6  * 
	and.w	(a0)+,d6  * 3eme bitplan
	or.w	d3,d6  * 16 pix
	move.w	d6,(a1)+
*
	move.w	d5,d6  * 
	and.w	(a0)+,d6  * 4eme bitplan
	or.w	d4,d6  * 16 pix
	move.w	d6,(a1)+
*

************

	adda.l	#160-16,a1
***	adda.l	#16,a0

	dbra	d0,boucspr2


*****************************************

*	dbra	d0,eiruvzertvfhri2

	adda.l	#x*3,a5
	adda.l	#y*3,a4

	dbra	d7,ffred
	bra	zozo34

****************************************

zozo34
	suba.l	#x*3*6,a5	
	move.l	a5,sauvpointable


*. fin affichage sprit


*	movem.l	sauvtgvmovem,a2-a6/d0/d2-d7

	cmp.b	#$39,$FFFFfc02.w
	beq	stop

stomop
	cmp.b	#$3b,$FFFFfc02.w
	beq	stomop


	cmp.b	#$3c,$FFFFfc02.w
	bne	zee0
	move.l	#pal0,thepalencours
	BRA	aaz

zee0	cmp.b	#$3d,$FFFFfc02.w
	bne	zee1
	move.l	#pal1,thepalencours
	bra	aaz

zee1	cmp.b	#$3e,$FFFFfc02.w
	bne	zee2
	move.l	#pal2,thepalencours
	bra	aaz
zee2	cmp.b	#$3F,$FFFFfc02.w
	bne	zee3
	move.l	#pal3,thepalencours
	bra	aaz

zee3	cmp.b	#$40,$FFFFfc02.w
	bne	zee4
	move.l	#pal4,thepalencours
	bra	aaz
zee4	cmp.b	#$41,$FFFFfc02.w
	bne	zee5
	move.l	#pal5,thepalencours
	bra	aaz
zee5	cmp.b	#$42,$FFFFfc02.w
	bne	zee6
	move.l	#pal6,thepalencours
	bra	aaz
zee6	cmp.b	#$43,$FFFFfc02.w
	bne	zee7
	move.l	#pal7,thepalencours
	bra	aaz
zee7	cmp.b	#$44,$FFFFfc02.w
	bne	zee9
	move.l	#pal8,thepalencours
	bra	aaz

zee9
	nop

aaz

*	move.w	#$333,$ff8240
	jsr	vsync
*	move.w	#$000,$ff8240

*.... debut effacement sprit

efaspr
	lea	sauveface,a6
	moveq.l	#5,d7
boucefaspr
	move.l	(a6)+,a1
	moveq.l	#0,d0
	moveq.l	#0,d1
	moveq.l	#0,d2
	moveq.l	#0,d3
a	set	0
	rept	16
	movem.l	d0-d3,a(a1)
a	set	a+160
	endr

	dbra	d7,boucefaspr

*.... fin effacement sprit 

	movem.l	sauvtgvmovem,a2-a6/d0/d2-d7



	addq.l	#1,d5
	cmp.b	#3,d5
	ble	ttt

	bra	bouclafi
*	bra 	stop

****************************************
****************************************
vsync:
	movem.l	a0-a2/d0-d2,sauvreg
*******swapping

	move.l	physbase,a0
	move.l	phys1,a1
	cmp.l	a0,a1
	beq	sw2
	move.l	a1,physbase  *phys1 -> physbase 	
	move.l	phys2,paphys

	move.l	phys2,d0
	lsr.w	#8,d0
	move.b	d0,$ffff8203.w
	swap	d0
	move.b	d0,$ffff8201.w
	bra 	suisw

sw2	*phys2 -> physbase 	
	move.l	phys2,physbase
	move.l	phys1,paphys


	move.l	phys1,d0
	lsr.w	#8,d0
	move.b	d0,$ffff8203.w
	swap	d0
	move.b	d0,$ffff8201.w

suisw
	move.w	#255,vs_flag
wait_vbl	tst.w	vs_flag
	bne	wait_vbl

* pour les spr

	lea	sauveface,a0
a	set	0
	rept	6
	move.l	(6+a)*4(a0),d0
	move.l	a*4(a0),(6+a)*4(a0)
	move.l	d0,a*4(a0)
a	set	a+1
	endr

* fin spr

	movem.l	sauvreg,a0-a2/d0-d2
	rts
****************************************
stop:
	move.w	#$2700,sr
	move.l	sauve_vbl,$70

	move.b  souris,$fffffa09

	move.b	sv_mfp,iera
	move.b	sv_mfp+1,ierb
	move.b	sv_mfp+6,imra
	move.l	sv_mfp+2,$120

	move.b	#8,$ff8800
	clr.b	$ff8802
	move.b	#9,$ff8800
	clr.b	$ff8802
	move.b	#10,$ff8800
	clr.b	$ff8802

	move.l	phys2,d0
	lsr.w	#8,d0
	move.b	d0,$ffff8203.w
	swap	d0
	move.b	d0,$ffff8201.w

*------------------------------
*  recollage de toute derniere minute !!!!!!!!
*
	move.l	phys2,a1
	lea	final_im,a0
	move.w	#4000,d1
.zob	
	move.w	(a0),(a1)+
	move.w	(a0),(a1)+
	move.w	(a0),(a1)+
	move.w	(a0)+,(a1)+
	dbra	d1,.zob


	move.w	#20031,d1
.khigfgfhtfcty
	rept	100
	nop
	endr
	dbra	d1,.khigfgfhtfcty


.lszyhsmtygbhnzei
	cmp.b	#$39,$ffffc02
	bne	.lszyhsmtygbhnzei

	
*--------------------------------
	move.w	sauv_resol,$ffff8260.w

	lea	sauv_pal,a1
	move.l	#$ffff8240,a0
	rept 	8
	move.l	(a1)+,(a0)+
	endr

	ILLEGAL

****************************************
palettefin:even
	dc.w	$000,$070,$643,$633,$734,$744,$624,$754,$773,$763,$853,$753,$743,$733,$723,$777
*palette:even

pal0
*	dc.w	$000,$001,$101,$112,$212,$223,$323,$334,$434,$445,$545,$556,$656,$677,$767,$777
	dc.w	0,$0,$0,$0,$0,$0,$0,$0,$000,$111,$006,$777,$222,$333,$555,$666
*        ^ tgv dans fonte


pal1
	dc.w	$000,$111,$006,$777,$222,$333,$555,$666,$000,$000,$000,0,0,0,$0,$0
*        ^ tgv + fonte noir

pal2
	dc.w	$000,$111,$006,$777,$222,$333,$555,$666,$000,$111,$006,$777,$222,$333,$555,$666

pal3
*	dc.w	0,$001,$002,$003,$104,$204,$304,$404,$000,$111,$006,$777,$222,$333,$555,$666
 	dc.w 	$000,$111,$006,$777,$222,$333,$555,$666,$0,$001,$002,$003,$104,$204,$304,$404
*^ tgv dans le fond +phantom rose dans fonte

pal4 
*NUL	dc.w	$0,$001,$002,$003,$013,$023,$033,$044,0,$200,$300,$400,$411,$422,$433,$533
 	dc.w 	$0,$775,$100,$200,$311,$422,$532,$642,$000,$775,$100,$200,$311,$422,$532,$642
	


pal5
* dc.w	0,$001,$002,$003,$104,$204,$304,$404,$000,$111,$006,$777,$222,$333,$555,$666
*^ tgv rose dans le fond +tgv dans fonte
	DC.W	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

pal6
 	dc.w 	$000,$0,$0,$0,$0,$0,$0,$0,$0,$001,$002,$003,$104,$204,$304,$404

pal7
* 	dc.w 	$000,$111,$003,$232,$111,$121,$212,$222,$0,$001,$002,$003,$104,$204,$304,$404
	dc.w	$000,$111,$006,$777,$222,$333,$555,$666,$000,$010,$002,$222,$101,$222,$323,$333
pal8
	dc.w	0,0,0,0,0,0,0,0,$777,$777,$777,$777,$777,$777,$777,$777,0,0,0,0,0,0,0,0

physbase:even                                          + ***  ***  ***        *  *
 	ds.l	1
erlsaset:even
	ds.l	1
vs_flag	ds.w	1
paphys:even
	ds.l	1
phys1:even
	ds.l	1
phys2:even
	ds.l	1
sauvreg:even
	ds.l	16
sv_mfp	ds.b	8
sauvtgvmovem:even
	ds.l	16
font:even
	incbin 'monofnt.dat'
txt:even
	incbin	'txtTRANS.dat'
*	dc.b 	0,2,3,4,5,6,7,8,9,8,7,6,5,4,3,2,1,0,1,2,3,4,5,6,7,8,9,8
	dc.b	255
ho:even	  *48 max...
	incbin	'boink2.dat'
	dc.b	255
image:even
	incbin 'trilcomp.dat'

	ds.b	160*8

ecran2:ds.b	33000+160*60
sauvtgvreg:even
	ds.l 	10
sauvtgvregin *registres a l'interieur de la boucle tgv
	ds.l	10

stopm_d	dc.b	7,$FF,6,0,8,0,9,0,$A,0
souris: ds.b    1

	even	
music	incbin	"madmax3.mus"

tgv:even
	incbin	"LAST2tgv.dat"
	ds.b	6*33*6

*pour les sprites

sauvpointable:even
	ds.l	1
sauveface:even
	ds.l	6
sauveface2:even
	ds.l	6

lekel:	ds.l	1
buffer:even
	ds.b	4100*6   *4096 en fait...
table:even
	*  ligne y , octet x mod 16 , decalage (0 a 16)
	incbin	sinwave4.dat
fintable:even
	incbin	sinwave4.dat

	dc.b	255,255,255,255
spri:even
	incbin	sprit61.dat
sauve_vbl:	ds.l	1
sauve_super:	ds.l	1
sauva0raster:	ds.l	1
sauva1raster:	ds.l	1
thepalencours	ds.l	1
sauv_resol	ds.l	1
sauv_pal	ds.l	16

ECRAN:	ds.b	32000+$100+160*60

final_im:even
	incbin	"final_im.dat"