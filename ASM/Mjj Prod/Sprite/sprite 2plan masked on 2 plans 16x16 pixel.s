subpixel equ 4

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


; init screen
	move.l #screenbuf,d0
	clr.w d0
	move.l d0,d1
	add.l #$10000,D1
	MOVE.L D0,log
	move.l d1,phys

; creation convx et convy 
	move.l #$8000,d0	; offset,motif or
	lea convx,a0
.loopconvx
	rept subpixel
	  move.l d0,(a0)+
	endr
	lsr.w #1,d0
	bne.s .loopconvx
	add.l #$00088000,d0
	cmp.l #$00a08000,d0
	bne.s .loopconvx

	move.w #0,d0
	move.w #199,d1
	lea convy,a0
.loopconvy
	rept subpixel
	move.w d0,(a0)+
	endr
	add #160,d0
	dbf d1,.loopconvy

	jsr extractsprite

	lea convxSprite,a0
	lea codegenliste,a1
	move.w #19,d0
	moveq #0,d2
.loop3
	lea codegenliste,a1
	moveq #15,d3
.loop2
	rept subpixel
	move.l (a1),d1
	move.l d1,(a0)+
	move.w d2,(a0)+
	addq.w #2,a0
	endr
	addq.l #4,a1
	dbf d3,.loop2
	addq.w #8,d2
	dbf d0,.loop3

	jsr convsinus
	
main

	jsr waitvbl
	jsr swap_screen
	move.l log,d0
	add.w #0*160+80-8,d0
	
;	lea spritedeca,a0
;	move.l d0,a1
;	move.w cptdeca,d1
;	mulu #128,d1
;	add d1,a0
;
;	move.w #15,d7	
;.copysprite
;	move.l (a0)+,(a1)
;	move.l (a0)+,8(a1)
;
;	lea 160(a1),a1
;	dbf d7,.copysprite

	lea codeeffliste,a5
	move.w cptdeca,d2
	subq #2,d2
	and.w #$F,d2
	add.w d2,d2
	add.w d2,d2	
	add.w d2,a5
	move.l (a5),a4
	move.l d0,a0
	move.l d0,-(sp)
	moveq #0,d0
	jsr (a4)
	move.l (sp)+,d0

	lea codegenliste,a2
	move.l d0,a0
	move.w cptdeca,d2
	add.w d2,d2
	add.w d2,d2
	add.w d2,a2

	move.l (a2),a4
	jsr (a4)	; le test ultime



	move.w cptdeca,d0
	addq.w #1,d0
	and.w #$F,d0
	move.w d0,cptdeca
 
 
	jsr majangle
	lea convxSprite,a0
	move.l #angles,a2
	lea sinx1,a3
	move.w (a2)+,d0
	add.w d0,D0
	move.w (a3,d0),d1
	move.L #sinx2,a3
	move.w (a2)+,d0
	ADD D0,D0
	ADD (A3,D0.w),D1
	ADD D1,D1		; *8
	LEA (A0,D1),A4
	MOVE.L (A4)+,A5
	MOVE.L log,D0
	MOVE.W (A4)+,D0

	lea siny1,a3
	move.w (a2)+,d2
	add.w d2,d2
	move.w (a3,d2.w),d3  siny1
	lea siny2,a3
	move.w (a2)+,d2
	add d2,d2
	add.w (a3,d2.w),d3  siny2
 	lea convy,a0
	move.w (a0,d3),d3  y*160
	add.w d3,d0

	MOVE.L D0,A0
	JSR (A5)
	
	cmp.b #$b9,$fffffc02.w
	beq.s .fin
	jmp main
.fin

	move.l $44e.w,d0
	lsr.w #8,d0
	move.l d0,$ffff8200.w
	bsr waitvbl
    move.l $44e.w,d0   

    move.w #1,-(sp)

    move.l d0,-(sp)

    move.l d0,-(sp)

    move.w #5,-(sp)

    trap #14

    lea 12(sp),sp

	

	clr.w -(sp)
	trap #1

cptdeca	dc.w 0
angles	dc.w 128,128,50,70
ajoutangle	dc.w 14,7,512-11,6


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
	lea sinx1,a1
	lea sinx2,a2
	lea sin512,a0
	move.w #511,d0
.loop
	move.w (a0)+,d1
	add.w #32767,d1
	move.w d1,d2
	mulu #(40*2-8)*subpixel*4,d1
	mulu #(60*2-8)*subpixel*4,d2
	;asl #1,d1
	;asl #1,d2
	swap d1
	swap d2
	and.w #-4,d1
	and.w #-4,d2
	move.w d1,(a1)+
	move.w d2,(a2)+
	dbf d0,.loop
	
	lea siny1,a1
	lea siny2,a2
	lea sin512,a0
	move.w #511,d0
.loopy
	move.w (a0)+,d1
	add.w #32767,d1
	move.w d1,d2
	mulu #(40*2-8)*subpixel*2,d1
	mulu #(60*2-8)*subpixel*2,d2
;	asl #1,d1
;	asl #1,d2
	swap d1
	swap d2
	and.w #-2,d1
	and.w #-2,d2
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
	move.w #5,d1		; pas interne 5 /512
	lea sinx1,a3
	jsr createContigustable
	move.l a1,ptrref1

	move.w #512,d0
	move.w #10,d1
	move.w #nbbob,d2
	lea sinx2,a3
	jsr createContigustable
	move.l a1,ptrref2

	move.w #512,d0
	move.w #6,d1
	move.w #nbbob,d2
	lea siny1,a3
	jsr createContigustable
	move.l a1,ptrref3

	move.w #512,d0
	move.w #512-4,d1
	move.w #nbbob,d2
	lea siny2,a3
	jsr createContigustable
	move.l a1,ptrref4
	rts
ang1	dc.w 128
ang2	dc.w 128
ang3	dc.w 0
ang4	dc.w 0
ajoutang1	dc.w 4
ajoutang2 	dc.w 11
ajoutang3	dc.w 512-8
ajoutang4   dc.w 6
calcAllpos
	move.l ptrref1,a5
	move.l ptrref2,a1
	move.w ang1,d0
	add d0,d0
	add d0,d0
	add.w d0,a5
	move.w ang2,d0
	add.w d0,d0
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

	move.w segmentX,d0
	swap d0
	move.w segmentY,d1
	swap d1

	move.w #nbbob,d2
.loopcalcul

	move.w (a5)+,d0
	add.w (a1)+,d0
	move.w (a2)+,d1
	add (a3)+,d1

	move.l d1,a6
	move.w (a6),d3 			;  y*160

	move.l d0,a6
	add (a6)+,d3
	move.w d3,(a4)+			; effacement offset
	move.l (a6)+,(a4)+		; routine d'effacement

	move.l (a6),a6			; routine d'affichage
	move.l d3,a0

	jsr (a6)
	dbf d7,.loopcalcul

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
	moveq #1,d1
	swap d1
	add.l d1,d0
	clr.w d0
	move.l d0,log
	add.l d1,d0
	move.l d0,phys
	add.l d1,d0
	move.l d0,convX
;	add.l #320*subpixel*8,d0
	add.l d1,d0
	move.l d0,convY

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
	bsr orwd7d6
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
	bsr orwd7d6
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
	ds.b 65536
screenbuf
	ds.w 65536
	ds.w 65536
log	ds.l 1
phys	ds.l 1

convx	ds.l 320*subpixel
convy	ds.w 200*subpixel

	BSS
nbbob	equ 20

efface1lst
		ds.l nbbob
		ds.l nbbob
efface2lst
		ds.l nbbob
		ds.l nbbob


sinx1	ds.w 512
sinx2	ds.w 512
siny1	ds.w 512
siny2	ds.w 512

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
ram3	ds.l 16000
	
convxSprite	ds.l 320*2*subpixel
	

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



pi1	incbin 'SPRITE2.PI1'

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
	move.w d0,d3
	add.w d3,d3		; *2
	move.l a3,a4
	add d3,a4
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
	add.w d0,a5			; a5 = fin tempbuffer


	;moveq #0,d5			; angle
	
	move.w d1,d3		; pas interne<>0
	move.w d3,d4
	add d4,d4			; pas interne*2
	move.w d4,d5
	add.w d5,d5			; pas interne*4
	neg.w d0
	move.w d0,.auto1+2			; nombre d'elements
	add.w d0,d0
	move.w d0,.auto2+2
	move.w d0,.auto2b+2
	add.w d0,d0
	move.w d0,.auto3+2
;----------------------------------------
.loop
	move.w (a3),d7
	tst.b (a2)
	bne.s .flaga1
	st.b (a2)
	move.l a0,(a1)		; on stoque l'adresse de la valeur dans table refsin
	move.w d7,(a0)+
	; on met a jour a3 avec le pas interne*2
	; on met a jour a2 avec le pas interne (flags)
	add.w d3,a2
	add.w d4,a3
	add.w d5,a1

	cmp.l a2,a5
	blt.s .loop
.auto1
	lea 0(a2),a2
.auto2
	lea 0(a3),a3
.auto3
	lea 0(a1),a1
	bra.s .loop
.flaga1
	move.w d2,d6		; nombre de copie
	subq.w #1,d6

	move.l a3,-(sp)
.cpy
	move.w d7,(a0)+
	add.w d4,a3
	cmp.l a3,a4
	blt.s .1
.auto2b
	lea 0(a3),a3

.1
	move.w (a3),d7
	dbf d6,.cpy
	move.l (sp)+,a3

	addq.w #1,a2
	addq.w #2,a3
	addq.w #4,a1
	tst.b (a2)
	bne.s .fin
	bra.s .loop
.fin
	rts	
	BSS
segmentX	ds.w 1
segmentY	ds.w 1
tempbuffer
	ds.w 2048
