subpixel equ 4
subpixel2 equ 8
nbbob	equ 80

start:

	clr.l -(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp

	lea spritedeca,a0
	move.w #16*2*16-1,d0
.toto	clr.w (a0)+
	dbf d0,.toto

   move.l $44e.w,d0   
   clr.w -(sp)
    move.l d0,-(sp)
    move.l d0,-(sp)
    move.w #5,-(sp)
    trap #14
    lea 12(sp),sp


	jsr extractsprite

    jsr prepare_segments

; creation convx et convy 
;	move.l #$8000,d0	;     offset,motif or
;	lea convx,a0
;.loopconvx
;	rept subpixel
;	  move.l d0,(a0)+
;	endr
;	lsr.w #1,d0
;	bne.s .loopconvx
;	add.l #$00088000,d0
;	cmp.l #$00a08000,d0
;	bne.s .loopconvx
;
;	move.w #0,d0
;	move.w #199,d1
;	lea convy,a0
;.loopconvy
;	rept subpixel
;	move.w d0,(a0)+
;	endr
;	add #160,d0
;	dbf d1,.loopconvy
;

	move.l ptrConvX,a0
	lea codegenliste,a1
	move.w #19,d0
	moveq #0,d2
.loop3
	lea codegenliste,a1
	lea codeeffliste,a3
	moveq #15,d3
.loop2
	move.l (a3),d5
	move.l (a1)+,d1
	rept subpixel2
	move.w d2,(a0)+		; offset
	move.l d5,(a0)+		; code effacement
	move.l d1,(a0)+		; code affichage

	endr

	dbf d3,.loop2
	addq.w #8,d2
	dbf d0,.loop3

	move.l ptrConvY,a0
	moveq #0,d2
	move.w #160,d1
	move.w #199,d0 		; pas de cliping pour l'instant
.loop4
	rept subpixel2
	move.w d2,(a0)+
	endr
	add d1,d2
	dbf d0,.loop4

	jsr convsinus
	jsr swap_screen
	
main

	jsr majAngle
	jsr calcAllPos


	move.w #$111,$ffff8240.w
	jsr waitvbl
	clr.w $ffff8240.w
	;jsr swap_screen
	move.l log,d0
	
	
	cmp.b #$b9,$fffffc02.w
	beq.s .fin
	jmp main
.fin

	bsr waitvbl
	move.l $44e.w,d0
	lsr.w #8,d0
	move.l d0,$ffff8200.w
	bsr waitvbl
    move.l $44e.w,d0   
;
    move.w #1,-(sp)
;
    move.l d0,-(sp)
;
    move.l d0,-(sp)
;
   move.w #5,-(sp)
;
    trap #14
;
    lea 12(sp),sp

	

	clr.w -(sp)
	trap #1

cptdeca	dc.w 0
angles	dc.w 128,128,50,70
ajoutangle	dc.w 21,3,512-2,1


majangle
	lea ajoutangle,a0
	lea angles,a1
	moveq #3,d7
.loop
	move.w (a0)+,d0
	move.w (a1),d1
	add d0,d1
	and.w #511,d1
	move.w d1,(a1)+
	dbf d7,.loop

	rts

convsinus
	move.l sinx1,a1
	move.l sinx2,a2
	lea sin512,a0
	move.w #511,d0
	move.w ptrconvX+2,d4
.loop
	moveq #0,d1
	move.w (a0)+,d1
	add.w #32767,d1

	move.l d1,d2
	mulu #(180-8)*subpixel2,d1
	mulu #(140-8)*subpixel2,d2   ; 8 subpixel
	;asl #1,d1
	;asl #1,d2
	swap d1
	swap d2
; *10 = *8+*2 = *2(*4+1)

	add d1,d1
	move.w d1,d3
    add.w d3,d3 *4
    add.w d3,d3
    add d3,d1	; d1 = d1 * 10
;	and.w #-4,d1

;	and.w #-4,d2

 	add d2,d2
 	move.w d2,d3
 	add d3,d3
 	add d3,d3
 	add d3,d2

 	add d4,d1				; premiere table de sinus, on ajoute l'offset de convX
	move.w d1,(a1)+
	move.w d2,(a2)+
	dbf d0,.loop
	

	move.w ptrConvY+2,d4
	move.l siny1,a1
	move.l siny2,a2
	lea sin512,a0
	move.w #511,d0
.loopy
	moveq #0,d1
	move.w (a0)+,d1
	add.w #32767,d1
	move.l d1,d2
	mulu #(40*2-8)*subpixel2*2,d1
	mulu #(60*2-8)*subpixel2*2,d2
;	asl #1,d1
;	asl #1,d2
	swap d1
	swap d2
	and.w #-2,d1
	and.w #-2,d2
	add d4,d1			; ajoute l'offset segment
	move.w d1,(a1)+
	move.w d2,(a2)+
	dbf d0,.loopy


; createContigustable
;
; a0 = ram
; d0 = nombre d'element de la table sinus
; d1 = pas interne
; d2 = nombre de copie de valeurs
; a3 = table de sinus d'amplitude final
;
; pendant le fonctionnement:
; constante  d3,d4,d5 = pas interne,*2,*4
;
;
;

; retour:
; a0 = ram
; a1 = adresse table de d0 adresses  reftable pris a partir de la ram
;  

	lea ram3,a0
	move.w #512,d0
	move.w #nbbob,d2 ; nombre de copie de valeur
	move.w #11,d1		; pas interne 5 /512
	move.l sinx1,a3
	jsr createContigustable
	move.l a1,ptrref1

	move.w #512,d0
	move.w #28,d1
	move.w #nbbob,d2
	move.l sinx2,a3
	jsr createContigustable
	move.l a1,ptrref2

	move.w #512,d0
	move.w #512-12,d1
	move.w #nbbob,d2
	move.l siny1,a3
	jsr createContigustable
	move.l a1,ptrref3

	move.w #512,d0
	move.w #512-24,d1
	move.w #nbbob,d2
	move.l siny2,a3
	jsr createContigustable
	move.l a1,ptrref4
	rts


ang1	dc.w 128
ang2	dc.w 128
ang3	dc.w 10
ang4	dc.w 0
ajoutang1	dc.w 4
ajoutang2 	dc.w 1
ajoutang3	dc.w 512-3
ajoutang4   dc.w 1
calcAllpos
	move.l ptrref1,a5
	move.l ptrref2,a1
	move.w ang1,d0
	add d0,d0
	add d0,d0
	add.w d0,a5
	move.w ang2,d0
	add d0,d0
	add.w d0,d0
	add.w d0,a1

	move.l ptrref3,a2
	move.l ptrref4,a3
	move.w ang3,d0
	add d0,d0
	add d0,d0
	add d0,a2
	move.w ang4,d0
	add d0,d0
	add d0,d0
	add d0,a3

	move.l (a5),a5
	move.l (a1),a1
	move.l (a2),a2
	move.l (a3),a3

	lea efface1lst,a4

	move.l ptrConvX,d0
	move.l ptrConvY,d1
	move.l ptrscr1,d3

	move.w #nbbob-1,d2
.loopcalcul

	move.w (a5)+,d0
	add.w (a1)+,d0
	move.w (a2)+,d1
	add.w (a3)+,d1

	move.l d1,a6
	move.w (a6),d3 			;  y*160

	move.l d0,a6
	add.w (a6)+,d3
	move.w d3,(a4)+			; effacement offset
	move.l (a6)+,(a4)+		; routine d'effacement

	move.l (a6),a6			; routine d'affichage
	move.l d3,a0

	jsr (a6)
	dbf d2,.loopcalcul

	lea ang1,a0
	lea 8(a0),a1
	movem.w (a1),d0-d3

	move.w (a0),d4
	add.w d0,d4
	move.w #511,d5
	and d5,d4
	move.w d4,(a0)+

	move.w (a0),d4
	add.w d1,d4
	and d5,d4
	move.w d4,(a0)+

	move.w (a0),d4
	add.w d2,d4
	and d5,d4
	move.w d4,(a0)+

	move.w (a0),d4
	add.w d3,d4
	and d5,d4
	move.w d4,(a0)+
; maj angle fait

	rts

prepare_segments
	
	move.l #screenbuf,d0
	moveq #4,d1
	swap d1
	jsr getMem1					; prepare 16 zone memoire allant de 32768 a 1 octet (puissance de 2)

	lea ptrMem,a0
	movem.l (a0)+,d0-d3			; 1 buffer de 32k un de 16k un de 8k un de 4k  pas aligné mais contigu au meme segment  

	move.l d3,sinX1			; sinx1 x2 y1 y2 devenu des pointeur sur
							; 512 word
	move.l #1024,d5
	add.l d5,d3
	move.l d3,sinX2
	add.l d5,d3
	move.l d3,sinY1
	add.l d5,d3
	move.l d3,sinY2					; place pour 4k = 4 table de 512 word


								; cad poid fort de l'adresse du buffer est toujours a la meme valeur 
	move.l d0,ptrConvY			; 32k alloué pour convy: 1856*2 en comptant cliping haut bas de 16 pixel de hauteur et 4 subpixel
	add.l #2*1856,d0
	; 30912 octet libre
	move.l d0,ptrConvX	; 12800 octet pour 320 pixel 4 subpixel 10 octet (adresseEFF,adresseAFF,offset)
	add.l #320*8*10,d0		; pile poil 4 subpixel  convy 232*8 subpixel*2 + 352*8 subpixel*10 octet
	moveq #0,d4 				; 31872 octet sur 32768
	move.w #1024,d4
	lea sinx1,a1
	move.l d0,(a1)+
	add.l d4,d0
	move.l d0,(a1)+
	add.l d4,d0
	move.l d0,(a1)+
	add.l d4,d0
	move.l d0,(a1)+
	
	move.l d1,ptr16k
	move.l d2,ptrFlag			; 8k max pour les flag, sinus dont le nombre d'element ne depasse pas 8192
	move.l d3,ptr4k

	move.l #screenbuf,d0
	moveq #1,d1
	swap d1
	add.l d1,d0
	clr.w d0
	move.l d0,log
	move.l d0,ptrscr1
	add.l d1,d0
	move.l d0,phys
	move.l d0,ptrscr2
	add.l d1,d0
	move.l d0,ptrscr3
	add.l d1,d0
	move.l d0,ptrscr4

;	add.l d1,d0
;	move.l d0,convX
;	add.l #320*subpixel*8,d0
;	add.l d1,d0
;	move.l d0,convY

	rts
waitvbl
	move.w $468.w,d0
.loop	cmp.w $468.w,d0
	beq.s .loop
	rts

swap_screen
	move.l log,d0
	move.l phys,d1
	move.l d0,phys
	move.l d1,log
	lsr.w #8,d0
	move.l d0,$ffff8200.w
	rts

extractsprite
	lea pi1+2,a0
	movem.w (a0),d0-d3
	movem.w d0-d3,$ffff8240.w
	lea pi1+34,a0
	
	lea spritedeca,a1
	moveq #0,d1
	moveq #15,d7
.loop0
	move.l (a0),d0
	lea 160(a0),a0
	move.l d0,(a1)+
	move.l d1,(a1)+
	dbf d7,.loop0

	moveq #14,d7
	lea spritedeca,a1
	move.l a1,a3
	lea 128(a1),a2
	move.l a2,a4
.copyandshift
	move.w #15,d6
.ligne
;	rept 2
;	move.w (a1)+,d0
;	move.w 2(a1),d1
;	move.w #0,ccr		; set x to 0
;	roxr #1,d0
;	roxr #1,d1
;	move.w d0,(a2)+
;	move.w d1,2(a2)
;	;lea 2(a1),a1
;	;lea 2(a2),a2
;	endr

	MOVE.L (A1)+,(A2)+
	MOVE.L (A1)+,(A2)+
	LEA -8(A2),A2
	MOVE.B #0,CCR
	ROXR (A2)
	ROXR 4(A2)
	MOVE.B #0,CCR
	ROXR 2(A2)
	ROXR 6(a2)

	lea 8(a2),a2
	dbf d6,.ligne
	lea 128(a3),a3
	lea 128(a4),a4
	move.l a3,a1
	move.l a4,a2

;	lea 4(a2),a2
;	lea 4(a1),a1
	dbf d7,.copyandshift
	
makecodegen
	lea spritedeca,a0
	lea ram,a1
	lea codegenliste,a2
	lea codeeffliste,a3
	lea ram2,a4
	moveq #15,d0
.loopSprite
	move.l a4,(a3)+
	move.l a1,(a2)+
	moveq #15,d1
	moveq #0,d6		; offset
.loopligne
	move.w (a0)+,d2
	move.w (a0)+,d3
	move.w (a0)+,d4
	move.w (a0)+,d5
	tst.w d2
	bne.s .1
	tst.w d3
	beq.s .nerienfaire
	; or.w #d3,offset+2(a0)
	move.w d3,d7
	addq #2,d6
	bsr orwd7d6_2
	subq #2,d6
	


	bra.s .suite
.1	; d2 contient kekchose
	tst.w d3
	beq.s .wordd2
	; or.l #d2d3,offset(a0)
	move.w d2,d7
	swap d7
	move.w d3,d7
	bsr orld7d6
	bra.s .suite
.wordd2
	; or.w #d2,offset(a0)
	move.w d2,d7
	bsr orwd7d6
	bra.s .suite
.nerienfaire
	nop
.suite
	tst.w d4
	bne.s .2
	tst.w d5
	beq.s .nerienfaire2
	; or.w #d5,offset+8+2(a0)
	move.w d5,d7
	add.w #10,d6
	bsr orwd7d6_2
	sub.w #10,d6


	bra.s .suite2	
.2	tst.w d5
	beq.s .wordd4
	; or.l #d4d5,offset+8(a0)
	move.w d4,d7
	swap d7
	move.w d5,d7
	addq.w #8,d6
	bsr orld7d6
	subq #8,d6

	bra.s .suite2
.wordd4
	; or.w #d4,offset+8(a0)
	move.w d4,d7
	addq #8,d6
	bsr orwd7d6
	subq #8,d6
	bra.s .suite2
.nerienfaire2
	nop
.suite2
	add #160,d6
	dbf d1,.loopligne
	move.w #$4e75,(a1)+
	move.w #$4e75,(a4)+
	dbf d0,.loopSprite
	rts
orwd7d6
;	move.l d2,-(sp)
	move.w d7,d2   ; plus besoin de d2
	swap d2
	move.w d7,d2
	not.l d2

	; and.l d2,d6(a0)   02a8

	move.w #$02a8,(a1)+		; + 8 octet au code genere
	move.l d2,(a1)+
	move.w d6,(a1)+


	move.w #$68,(a1)+
	move.w d7,(a1)+
	move.w d6,(a1)+

	move.w #$2140,(a4)+		; since it's masked on 2 plan, the clearing is long instead of word 

	move.w d6,(A4)+			; ($2140 instead of $3140) (move.l d0,d6(a0) instead of move.w d0,d6(a0))

;	move.l (sp)+,d2
	rts
orwd7d6_2					; cas ou orwd7d6 mais sur le deuxieme plan, l'effacement se fait naturellement sur le premier plan
;	move.l d2,-(sp)
	move.w d7,d2   ; plus besoin de d2
	swap d2
	move.w d7,d2
	not.l d2

	; and.l d2,d6(a0)   02a8

	move.w #$02a8,(a1)+		; + 8 octet au code genere
	move.l d2,(a1)+
	move.w d6,(a1)
	subq.w #2,(a1)+



	move.w #$68,(a1)+
	move.w d7,(a1)+
	move.w d6,(a1)+

	move.w #$2140,(a4)+		; since it's masked on 2 plan, the clearing is long instead of word 

	move.w d6,(A4)			; ($2140 instead of $3140) (move.l d0,d6(a0) instead of move.w d0,d6(a0))
	subq.w #2,(a4)+			; on and.l sur le plan 0 et 1 et pas 1 et 2
;	move.l (sp)+,d2
	rts
orld7d6
	; d7 = le data sur 2 plan
	;

;	move.l d2,-(sp)
;	move.l d3,-(sp)
	move.w d7,d2
	swap d7
	or.w d7,d2
	swap d7  	; remet d7 a la bonne valeur
	not.w d2
	move.w d2,d3
	swap d2
	move.w d3,d2
	; d2.l = masque a partir des 2 valeur poid fort poid faible de d7

	move.w #$02a8,(a1)+
	move.l d2,(a1)+
	move.w d6,(a1)+				; + 8 octets

	move.w #$A8,(a1)+
	move.l d7,(a1)+
	move.w d6,(a1)+

	move.w #$2140,(a4)+
	move.w d6,(a4)+

;	;move.l (sp)+,d3
;	move.l (sp)+,d2

	rts
	
	BSS
	ds.l 1
	ds.b 65536
screenbuf
	ds.w 65536
	ds.w 65536
log		ds.l 1
phys	ds.l 1
ptrscr1	ds.l 1
ptrscr2	ds.l 1
ptrscr3	ds.l 1
ptrscr4	ds.l 1


;convx	ds.l 320*subpixel
;convy	ds.w 200*subpixel

ptrconvX ds.l 1
ptrconvY ds.l 1

	BSS


efface1lst
		ds.l nbbob
		ds.l nbbob

efface2lst
		ds.l nbbob
		ds.l nbbob


sinx1	ds.l 1   *ds.w 512
sinx2	ds.l 1   *ds.w 512
siny1	ds.l 1   *ds.w 512
siny2	ds.l 1   *ds.w 512

ptrref1	ds.l 1
ptrref2	ds.l 1
ptrref3	ds.l 1
ptrref4	ds.l 1


codegenliste	ds.l 16
codeeffliste	ds.l 16
ram	ds.b ($b24dA-$b19f2)+2000
	ds.l 5000
ram2	ds.l 5000
	ds.l 5000
ram3	ds.l 32000
	
;convxSprite	ds.l 320*2*subpixel
	

sprite	ds.w 32

spritedeca
	ds.w 128*16


	DATA
sin512:			; sin 512 element amplitude 32766
	dc.w 0,402,804,1206,1607,2009,2410,2811
	dc.w 3211,3611,4010,4409,4807,5205,5601,5997
	dc.w 6392,6786,7179,7570,7961,8350,8739,9125
	dc.w 9511,9895,10278,10659,11038,11416,11792,12166
	dc.w 12539,12909,13278,13644,14009,14371,14731,15090
	dc.w 15445,15799,16150,16498,16845,17188,17529,17868
	dc.w 18203,18536,18866,19194,19518,19840,20158,20474
	dc.w 20786,21095,21401,21704,22004,22300,22593,22882
	dc.w 23169,23451,23730,24006,24278,24546,24810,25071
	dc.w 25328,25581,25830,26076,26317,26555,26788,27018
	dc.w 27243,27465,27682,27895,28104,28308,28509,28705
	dc.w 28897,29084,29267,29445,29620,29789,29954,30115
	dc.w 30271,30423,30570,30712,30850,30983,31112,31236
	dc.w 31355,31469,31579,31683,31784,31879,31969,32055
	dc.w 32136,32212,32283,32349,32411,32467,32519,32566
	dc.w 32608,32645,32677,32704,32726,32743,32756,32763
	dc.w 32766,32763,32756,32743,32726,32704,32677,32645
	dc.w 32608,32566,32519,32467,32411,32349,32283,32212
	dc.w 32136,32055,31969,31879,31784,31683,31579,31469
	dc.w 31355,31236,31112,30983,30850,30712,30570,30423
	dc.w 30271,30115,29954,29789,29620,29445,29267,29084
	dc.w 28897,28705,28509,28308,28104,27895,27682,27465
	dc.w 27243,27018,26788,26555,26317,26076,25830,25581
	dc.w 25328,25071,24810,24546,24278,24006,23730,23451
	dc.w 23169,22882,22593,22300,22004,21704,21401,21095
	dc.w 20786,20474,20158,19840,19518,19194,18866,18536
	dc.w 18203,17868,17529,17188,16845,16498,16150,15799
	dc.w 15445,15090,14731,14371,14009,13644,13278,12909
	dc.w 12539,12166,11792,11416,11038,10659,10278,9895
	dc.w 9511,9125,8739,8350,7961,7570,7179,6786
	dc.w 6392,5997,5601,5205,4807,4409,4010,3611
	dc.w 3211,2811,2410,2009,1607,1206,804,402
	dc.w 0,-402,-804,-1206,-1607,-2009,-2410,-2811
	dc.w -3211,-3611,-4010,-4409,-4807,-5205,-5601,-5997
	dc.w -6392,-6786,-7179,-7570,-7961,-8350,-8739,-9125
	dc.w -9511,-9895,-10278,-10659,-11038,-11416,-11792,-12166
	dc.w -12539,-12909,-13278,-13644,-14009,-14371,-14731,-15090
	dc.w -15445,-15799,-16150,-16498,-16845,-17188,-17529,-17868
	dc.w -18203,-18536,-18866,-19194,-19518,-19840,-20158,-20474
	dc.w -20786,-21095,-21401,-21704,-22004,-22300,-22593,-22882
	dc.w -23169,-23451,-23730,-24006,-24278,-24546,-24810,-25071
	dc.w -25328,-25581,-25830,-26076,-26317,-26555,-26788,-27018
	dc.w -27243,-27465,-27682,-27895,-28104,-28308,-28509,-28705
	dc.w -28897,-29084,-29267,-29445,-29620,-29789,-29954,-30115
	dc.w -30271,-30423,-30570,-30712,-30850,-30983,-31112,-31236
	dc.w -31355,-31469,-31579,-31683,-31784,-31879,-31969,-32055
	dc.w -32136,-32212,-32283,-32349,-32411,-32467,-32519,-32566
	dc.w -32608,-32645,-32677,-32704,-32726,-32743,-32756,-32763
	dc.w -32766,-32763,-32756,-32743,-32726,-32704,-32677,-32645
	dc.w -32608,-32566,-32519,-32467,-32411,-32349,-32283,-32212
	dc.w -32136,-32055,-31969,-31879,-31784,-31683,-31579,-31469
	dc.w -31355,-31236,-31112,-30983,-30850,-30712,-30570,-30423
	dc.w -30271,-30115,-29954,-29789,-29620,-29445,-29267,-29084
	dc.w -28897,-28705,-28509,-28308,-28104,-27895,-27682,-27465
	dc.w -27243,-27018,-26788,-26555,-26317,-26076,-25830,-25581
	dc.w -25328,-25071,-24810,-24546,-24278,-24006,-23730,-23451
	dc.w -23169,-22882,-22593,-22300,-22004,-21704,-21401,-21095
	dc.w -20786,-20474,-20158,-19840,-19518,-19194,-18866,-18536
	dc.w -18203,-17868,-17529,-17188,-16845,-16498,-16150,-15799
	dc.w -15445,-15090,-14731,-14371,-14009,-13644,-13278,-12909
	dc.w -12539,-12166,-11792,-11416,-11038,-10659,-10278,-9895
	dc.w -9511,-9125,-8739,-8350,-7961,-7570,-7179,-6786
	dc.w -6392,-5997,-5601,-5205,-4807,-4409,-4010,-3611
	dc.w -3211,-2811,-2410,-2009,-1607,-1206,-804,-402
sin896:		; sin 896 element amplitude 32766
	dc.w 0,229,459,689,918,1148,1378,1607
	dc.w 1837,2066,2295,2524,2753,2982,3211,3440
	dc.w 3668,3896,4124,4352,4580,4807,5034,5261
	dc.w 5488,5714,5941,6166,6392,6617,6842,7066
	dc.w 7291,7514,7738,7961,8184,8406,8628,8849
	dc.w 9070,9291,9511,9731,9950,10168,10387,10604
	dc.w 10821,11038,11254,11470,11685,11899,12113,12326
	dc.w 12539,12750,12962,13173,13383,13592,13801,14009
	dc.w 14216,14423,14629,14834,15038,15242,15445,15648
	dc.w 15849,16050,16250,16449,16647,16845,17041,17237
	dc.w 17432,17626,17819,18012,18203,18394,18584,18772
	dc.w 18960,19147,19333,19518,19702,19885,20067,20249
	dc.w 20429,20608,20786,20963,21139,21314,21488,21661
	dc.w 21833,22004,22174,22342,22510,22676,22841,23006
	dc.w 23169,23330,23491,23651,23809,23967,24123,24278
	dc.w 24431,24584,24735,24885,25034,25182,25328,25473
	dc.w 25617,25760,25901,26041,26180,26317,26454,26589
	dc.w 26722,26854,26985,27115,27243,27370,27496,27620
	dc.w 27743,27865,27985,28104,28221,28337,28452,28565
	dc.w 28677,28788,28897,29004,29110,29215,29318,29420
	dc.w 29521,29620,29717,29813,29908,30001,30093,30183
	dc.w 30271,30359,30444,30528,30611,30692,30772,30850
	dc.w 30927,31002,31076,31148,31218,31287,31355,31421
	dc.w 31485,31548,31609,31669,31727,31784,31839,31892
	dc.w 31944,31994,32043,32090,32136,32180,32222,32263
	dc.w 32303,32340,32376,32411,32444,32475,32505,32533
	dc.w 32559,32584,32608,32629,32650,32668,32685,32700
	dc.w 32714,32726,32737,32745,32753,32758,32762,32765
	dc.w 32766,32765,32762,32758,32753,32745,32737,32726
	dc.w 32714,32700,32685,32668,32650,32629,32608,32584
	dc.w 32559,32533,32505,32475,32444,32411,32376,32340
	dc.w 32303,32263,32222,32180,32136,32090,32043,31994
	dc.w 31944,31892,31839,31784,31727,31669,31609,31548
	dc.w 31485,31421,31355,31287,31218,31148,31076,31002
	dc.w 30927,30850,30772,30692,30611,30528,30444,30359
	dc.w 30271,30183,30093,30001,29908,29813,29717,29620
	dc.w 29521,29420,29318,29215,29110,29004,28897,28788
	dc.w 28677,28565,28452,28337,28221,28104,27985,27865
	dc.w 27743,27620,27496,27370,27243,27115,26985,26854
	dc.w 26722,26589,26454,26317,26180,26041,25901,25760
	dc.w 25617,25473,25328,25182,25034,24885,24735,24584
	dc.w 24431,24278,24123,23967,23809,23651,23491,23330
	dc.w 23169,23006,22841,22676,22510,22342,22174,22004
	dc.w 21833,21661,21488,21314,21139,20963,20786,20608
	dc.w 20429,20249,20067,19885,19702,19518,19333,19147
	dc.w 18960,18772,18584,18394,18203,18012,17819,17626
	dc.w 17432,17237,17041,16845,16647,16449,16250,16050
	dc.w 15849,15648,15445,15242,15038,14834,14629,14423
	dc.w 14216,14009,13801,13592,13383,13173,12962,12750
	dc.w 12539,12326,12113,11899,11685,11470,11254,11038
	dc.w 10821,10604,10387,10168,9950,9731,9511,9291
	dc.w 9070,8849,8628,8406,8184,7961,7738,7514
	dc.w 7291,7066,6842,6617,6392,6166,5941,5714
	dc.w 5488,5261,5034,4807,4580,4352,4124,3896
	dc.w 3668,3440,3211,2982,2753,2524,2295,2066
	dc.w 1837,1607,1378,1148,918,689,459,229
	dc.w 0,-229,-459,-689,-918,-1148,-1378,-1607
	dc.w -1837,-2066,-2295,-2524,-2753,-2982,-3211,-3440
	dc.w -3668,-3896,-4124,-4352,-4580,-4807,-5034,-5261
	dc.w -5488,-5714,-5941,-6166,-6392,-6617,-6842,-7066
	dc.w -7291,-7514,-7738,-7961,-8184,-8406,-8628,-8849
	dc.w -9070,-9291,-9511,-9731,-9950,-10168,-10387,-10604
	dc.w -10821,-11038,-11254,-11470,-11685,-11899,-12113,-12326
	dc.w -12539,-12750,-12962,-13173,-13383,-13592,-13801,-14009
	dc.w -14216,-14423,-14629,-14834,-15038,-15242,-15445,-15648
	dc.w -15849,-16050,-16250,-16449,-16647,-16845,-17041,-17237
	dc.w -17432,-17626,-17819,-18012,-18203,-18394,-18584,-18772
	dc.w -18960,-19147,-19333,-19518,-19702,-19885,-20067,-20249
	dc.w -20429,-20608,-20786,-20963,-21139,-21314,-21488,-21661
	dc.w -21833,-22004,-22174,-22342,-22510,-22676,-22841,-23006
	dc.w -23169,-23330,-23491,-23651,-23809,-23967,-24123,-24278
	dc.w -24431,-24584,-24735,-24885,-25034,-25182,-25328,-25473
	dc.w -25617,-25760,-25901,-26041,-26180,-26317,-26454,-26589
	dc.w -26722,-26854,-26985,-27115,-27243,-27370,-27496,-27620
	dc.w -27743,-27865,-27985,-28104,-28221,-28337,-28452,-28565
	dc.w -28677,-28788,-28897,-29004,-29110,-29215,-29318,-29420
	dc.w -29521,-29620,-29717,-29813,-29908,-30001,-30093,-30183
	dc.w -30271,-30359,-30444,-30528,-30611,-30692,-30772,-30850
	dc.w -30927,-31002,-31076,-31148,-31218,-31287,-31355,-31421
	dc.w -31485,-31548,-31609,-31669,-31727,-31784,-31839,-31892
	dc.w -31944,-31994,-32043,-32090,-32136,-32180,-32222,-32263
	dc.w -32303,-32340,-32376,-32411,-32444,-32475,-32505,-32533
	dc.w -32559,-32584,-32608,-32629,-32650,-32668,-32685,-32700
	dc.w -32714,-32726,-32737,-32745,-32753,-32758,-32762,-32765
	dc.w -32766,-32765,-32762,-32758,-32753,-32745,-32737,-32726
	dc.w -32714,-32700,-32685,-32668,-32650,-32629,-32608,-32584
	dc.w -32559,-32533,-32505,-32475,-32444,-32411,-32376,-32340
	dc.w -32303,-32263,-32222,-32180,-32136,-32090,-32043,-31994
	dc.w -31944,-31892,-31839,-31784,-31727,-31669,-31609,-31548
	dc.w -31485,-31421,-31355,-31287,-31218,-31148,-31076,-31002
	dc.w -30927,-30850,-30772,-30692,-30611,-30528,-30444,-30359
	dc.w -30271,-30183,-30093,-30001,-29908,-29813,-29717,-29620
	dc.w -29521,-29420,-29318,-29215,-29110,-29004,-28897,-28788
	dc.w -28677,-28565,-28452,-28337,-28221,-28104,-27985,-27865
	dc.w -27743,-27620,-27496,-27370,-27243,-27115,-26985,-26854
	dc.w -26722,-26589,-26454,-26317,-26180,-26041,-25901,-25760
	dc.w -25617,-25473,-25328,-25182,-25034,-24885,-24735,-24584
	dc.w -24431,-24278,-24123,-23967,-23809,-23651,-23491,-23330
	dc.w -23169,-23006,-22841,-22676,-22510,-22342,-22174,-22004
	dc.w -21833,-21661,-21488,-21314,-21139,-20963,-20786,-20608
	dc.w -20429,-20249,-20067,-19885,-19702,-19518,-19333,-19147
	dc.w -18960,-18772,-18584,-18394,-18203,-18012,-17819,-17626
	dc.w -17432,-17237,-17041,-16845,-16647,-16449,-16250,-16050
	dc.w -15849,-15648,-15445,-15242,-15038,-14834,-14629,-14423
	dc.w -14216,-14009,-13801,-13592,-13383,-13173,-12962,-12750
	dc.w -12539,-12326,-12113,-11899,-11685,-11470,-11254,-11038
	dc.w -10821,-10604,-10387,-10168,-9950,-9731,-9511,-9291
	dc.w -9070,-8849,-8628,-8406,-8184,-7961,-7738,-7514
	dc.w -7291,-7066,-6842,-6617,-6392,-6166,-5941,-5714
	dc.w -5488,-5261,-5034,-4807,-4580,-4352,-4124,-3896
	dc.w -3668,-3440,-3211,-2982,-2753,-2524,-2295,-2066
	dc.w -1837,-1607,-1378,-1148,-918,-689,-459,-229



pi1	incbin 'SPRITE4.PI1'

	TEXT
createContigustable
;
; a0 = ram
; d0 = nombre d'element de la table sinus
; d1 = pas interne
; d2 = nombre de copie de valeurs
; a3 = table de sinus d'amplitude final
;
; pendant le fonctionnement:
; constante  d3,d4,d5 = pas interne,*2,*4
;
;
;

; retour:
; a0 = ram
; a1 = adresse table de d0 adresses  reftable pris a partir de la ram
;  

	move.l a0,a1		; a1 = table refsin
	move.l a1,-(sp)
	move.w d0,d3
	add.w d3,d3		; *2
	move.l a3,a4
	add.w d3,a4
	add.w d3,d3		; *4
	add.w d3,a0			; a0 =ram



	lea tempbuffer,a2
	move.w d0,d4
	lsr #2,d4
	moveq #0,d3
.clearFlag
	move.l d3,(a2)+
	dbf d4,.clearFlag	; +- 4 octet

	lea tempbuffer,a2
	move.l a2,a5
	add.w d0,a5
	


	;moveq #0,d5			; angle
	
	move.w d1,d3		; pas interne<>0
	move.w d3,d4
	add d4,d4			; pas interne*2
	move.w d4,d5
	add.w d5,d5			; pas interne*4
	neg.w d0
	move.w d0,.auto1+2			; nombre d'elements
	move.w d0,.auto1b+2
	add.w d0,d0
	move.w d0,.auto2+2
	move.w d0,.auto2b+2
	move.w d0,.auto2c+2
	add.w d0,d0
	move.w d0,.auto3+2
	move.w d0,.auto3b+2
;----------------------------------------
	bra.s .loop
.loopaddq
	addq.w #2,a3
	addq.w #4,a1
	; ps le tst.b (a2) deux ligne plus loin est redondant quand on sort de la boucle dans le code flaga1
	move.w (a3),d7
	bra.s .11
.loop
	move.w (a3),d7
	tst.b (a2)
	bne.s .flaga1
.11	st.b (a2)
	move.l a0,(a1)		; on stoque l'adresse de la valeur dans table refsin
	move.w d7,(a0)+
	; on met a jour a3 avec le pas interne*2
	; on met a jour a2 avec le pas interne (flags)
	add.w d3,a2
	add.w d4,a3
	add.w d5,a1

	cmp.l a2,a5
	bgt.s .loop
.auto1
	lea 0(a2),a2
.auto2
	lea 0(a3),a3
.auto3
	lea 0(a1),a1
	bra.s .loop
.flaga1
	move.w d2,d6		; nombre de copie
	;subq.w #1,d6

	move.l a3,-(sp)
.cpy
	move.w d7,(a0)+
	add.w d4,a3
	cmp.l a3,a4
	bgt.s .1
.auto2b
	lea 0(a3),a3

.1
	move.w (a3),d7
	dbf d6,.cpy
	move.l (sp)+,a3

	addq.w #1,a2
	cmp.l a2,a5
	bgt.s .2
.auto1b
	lea 0(a2),a2
.auto2c
	lea 0(a3),a3
.auto3b
	lea 0(a1),a1
.2
	; s'assurer qu'on est pas en fin de tableau:
	;
	;

	tst.b (a2)
	beq.s .loopaddq
.fin
	move.l (sp)+,a1

	rts	
	
	BSS
segmentX	ds.w 1
segmentY	ds.w 1
tempbuffer
	ds.w 2048

	TEXT
;
;
;
; mem lib
;

;; exemple d'utilisation
;	move.l #buffer,d0
;	move.l #8*65536,d1 taille totale du buffer aligné sur 64k
;	jsr getmem1
;	lea -16*4(a0),a0
;	nop
;	nop
;	nop
;	nop
;	illegal
; format de memoire
;toto			; le label toto est la pour verifier l'algo
;	ds.b 65536	
;buffer	ds.l 65536*2    8*64k				; buffer sera aligné sur 64k donc un peu avant
;fin											; et apres un peu de memoire libre entre fin buffer et label fin

getmem1:

; d0 = adresse segment 64k non aligné
; d1 = nombre de segment a la suite*64k
; retour: a0 = liste d'adresse
; (a0)+ = 32k buffer
; (a0)+ = 16k buffer
; (a0)+ = 8k buffer
; (a0)+ = 4k buffer
; (a0)+ = 2k
; (a0)+ = 1k
; (a0)+ = 512
; (a0)+ = 256
; (a0)+ = 128
; (a0)+ = 64 octet
; 
; a0: 64 octet = 16 adresses

	; metre le buffer start dans d4

	moveq.w #1,d5
	swap d5
	move.l d0,d4
	sub.l d5,d4		; start memoire basse
	move.l d0,d3
	clr.w d3		;  debut multiple de 64k  fin memoire basse
	; d3 = start segment
	
	
	move.l d4,d7
	sub.l d3,d7		; d7 = taille en bas
				; d4 = start bas
	
	add.l d1,d3		; d3+ 4*64k = adresse start haut


	
	lea ptrMem,a0
	moveq #0,d6
	move.w #$8000,d6
	
.loop
	move.w d6,d1
	and.w d7,d1

	; bit 15 a 0 ? 
	tst.w d1
	bne.s .before			; was beq
	move.l d3,(a0)+
	add.l d6,d3
	
	bra.s .suite
.before
	move.l d4,(a0)+
	add.l d6,d4
.suite
	lsr #1,d5
	bne.s .loop			; ici ca s'arrete a un buffer de 1 octet il faudrai faire un meilleur test
	
	lea -64(a0),a0					; et s'arreter a un plus gros buffer 
	rts
	
;pgcd	; de d0 et d1
;; d0 le plus grand nombre
;	cmp.w d1,d0
;	blt.s .1
;	exg d0,d1
;.1
;	: d0 > d1
;    move.w d0,d2
;
;	sub d1,d0
;    cmp d1,d0
;    blt.s .1
;    



ptrMem		ds.l 16  		; dans ram apres l'appel de getmem1 adresses contenant les bloc memoire utilisable comme on veut

;;;    			; les label entour? de ;;; doivent etre dans l'ordre et contigu (ne pas deplacer l'un des label)
;ptrtabsin1	ds.l 1
;ptrtabsin2	ds.l 1
;ptrtabsin3	ds.l 1
;ptrtabsin4	ds.l 1
ptr16k	ds.l 1
ptr4k	ds.l 1
ptrflag	ds.l 1
;;;

