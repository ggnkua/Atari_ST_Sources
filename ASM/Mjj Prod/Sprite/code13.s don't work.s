subpixel equ 4
subpixel2 equ 6
nbbob	equ 64
spr_pi1	equ 0 1
tempmachine	equ 1 



_instmovelimd7	equ $2e3c
_instandld7depa0 equ $cfa8


*_instandld7a6 equ $cf96
*_instandwd7a6p   equ $cf5e
*_instandwd7a6   equ $cf56
*_instorwima6	equ $0056
start:

;	clr.l -(sp)
;	move.w #$20,-(sp)
;	trap #1
;	addq.l #6,sp
 

	jsr mjj_sys_init

	jsr prepare_segments



	lea sin1pack,a0
	move.l sin512,a1
	jsr depackperiod

	lea sin2pack,a0
	move.l sin900,a1
	jsr depackperiod


	lea spritedeca,a0
	move.w #16*2*16-1,d0
.toto	clr.w (a0)+
	dbf d0,.toto

	jsr extractsprite

;
;; creation convx et convy 
;;	move.l #$8000,d0	;     offset,motif or
;;	lea convx,a0
;;.loopconvx
;;	rept subpixel
;;	  move.l d0,(a0)+
;;	endr
;;	lsr.w #1,d0
;;	bne.s .loopconvx
;;	add.l #$00088000,d0
;;	cmp.l #$00a08000,d0
;;	bne.s .loopconvx
;;
;;	move.w #0,d0
;;	move.w #199,d1
;;	lea convy,a0
;;.loopconvy
;;	rept subpixel
;;	move.w d0,(a0)+
;;	endr
;;	add #160,d0
;;	dbf d1,.loopconvy
;;

;	move.l ptrConvX,a0
;	lea codegenliste,a1
;	move.w #19,d0
;	moveq #0,d2
;.loop3
;	lea codegenliste,a1
;	lea codeeffliste,a3
;	moveq #15,d3
;.loop2
;	move.l (a3)+,d5
;	move.l (a1)+,d1
;
;	rept subpixel2
;	move.w d2,(a0)+		; offset
;	move.l d5,(a0)+		; code effacement
;	move.l d1,(a0)+		; code affichage
;	endr
;
;	dbf d3,.loop2
;	addq.w #8,d2
;	dbf d0,.loop3

; creation convx avec seulement numero du code affiche et du code efface qui est le meme
	move.l ptrConvX,a0
    moveq #19,d0
    moveq #0,d2
.loop3
	moveq #15,d3
	moveq #0,d4
.loop2
	rept subpixel2
		move.w d2,(a0)+
		move.w d4,(a0)+	   ; numero de sprite de 0..15 * 4
	endr
	addq.w #4,d4
    dbf d3,.loop2
    addq.w #8,d2
    dbf d0,.loop3

    ; convx a changé    mais toiiii tu n'a pas changéééé
 

	move.l ptrConvY,a0
	moveq #0,d2
	move.w #160,d1
	move.w #199,d0 		; pas de cliping pour l'instant
	move.w #100*subpixel2-1,d7

.1	move.l d2,(a0)+   ; 2 y
	dbf d7,.1

.loop4
	rept subpixel2
	move.w d2,(a0)+
	endr
	add d1,d2
	dbf d0,.loop4
	jsr initcleartozerozero
	jsr waitvbl
	jsr swap_screen

	move.l #efface1lst,codecurefface
	move.l log,d0
	move.l d0,codelog
	jsr convsinus
	jmp main
effaceallbob
	move.l codelog,d1
	move.l codecurefface,a4
	move.w #nbbob-1,d6
	moveq #0,d0
.clear
	move.w (a4)+,d1
	move.l d1,a0
	move.l (a4)+,a5
	jsr (a5)
	dbf d6,.clear
	rts

	jsr waitvbl
main
	tst.w flagtransition
	beq.s .11
	jsr transfo1
.11
	move.l ptrscr1,d0

	add.l #160*16,d0

	lsr.w #8,d0
	move.l d0,$ffff8200.w 

	move.l #efface1lst,codecurefface
	move.l ptrscr1,d0
	move.l d0,codelog
	move.l ptrscr1,log
	jsr effaceallbob
	jsr majAngle
	jsr calcAllPos
	
	jsr waitvbl
	tst.w flagtransition
	beq.s .12
	jsr transfo1
.12

	move.l ptrscr2,d0

	add.l #160*16,d0
	lsr.w #8,d0
	move.l d0,$ffff8200.w

	move.l #efface2lst,codecurefface
	move.l ptrscr2,d0
	move.l d0,codelog
	move.l ptrscr2,log

	
	jsr effaceallbob
	jsr majAngle
	jsr calcAllPos
	jsr waitvbl

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
    move.w #1,-(sp)
    move.l d0,-(sp)
    move.l d0,-(sp)
   move.w #5,-(sp)
    trap #14
;
    lea 12(sp),sp

	
	jsr mjj_sys_fini	

	clr.w -(sp)
	trap #1

;; ca doit etre deprecated vu que les convx on changé
initcleartozerozero
	moveq #0,d0
;	move.l codeeffliste,d4
	moveq #0,d4 			; 
	lea ptrlsteff,a2
	moveq #2-1,d7
xx4
	move.w #nbbob-1,d6
	move.l (a2)+,a3	
.clearall
	move.w d0,(a3)+ 	;offset
	move.w d4,(a3)+ 	; decalage = 0
	dbf d6,.clearall

	dbf d7,xx4
	rts


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
	move.l sin512,a0
	move.w #511,d0
	move.w ptrconvX+2,d4
.loop
	moveq #0,d1
	move.w (a0)+,d1
	add.w #32767,d1

	move.l d1,d2
	mulu #(160-8-60)*subpixel2*4,d1
	mulu #(140-8-20)*subpixel2*4,d2   ; 8 subpixel
	;asl #1,d1
	;asl #1,d2
	swap d1
	add.w #5*subpixel2,d1   ; additionner 5 pixel a x
	swap d2
; *10 = *8+*2 = *2(*4+1)

;	add d1,d1
;	move.w d1,d3
 ;   add.w d3,d3 *4
;    add.w d3,d3
;    add d3,d1	; d1 = d1 * 10
	and.w #-4,d1

	and.w #-4,d2

; 	add d2,d2
; 	move.w d2,d3
; 	add d3,d3
; 	add d3,d3
; 	add d3,d2

 	add d4,d1				; premiere table de sinus, on ajoute l'offset de convX
	move.w d1,(a1)+
	move.w d2,(a2)+
	dbf d0,.loop
	
; ici sinx1 et sinx2 fait

	move.w ptrConvY+2,d4
	add.w #216*subpixel2*2,d4
	move.l siny1,a1
	move.l siny2,a2
	move.l sin512,a0
	move.w #511,d0
.loopy
	moveq #0,d1
	move.w (a0)+,d1
	add.w #32767,d1
	move.l d1,d2
	mulu #(60-8)*subpixel2*2,d1
	mulu #(79-8)*subpixel2*2,d2
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


 	lea sin900,a0
    move.l siny3,a1
    move.w #900-1,d0
.loopy3
 	moveq #0,d1
 	move.w (a0)+,d1
 	add.w #32767,d1
 	mulu #60*subpixel2*2,d1
 	swap d1
 	and.w #-2,d1   ; 	aligné sur mot   (mode grand debutant :p)
 	move.w d1,(a1)+		; siny3 calculé
 	dbf d0,.loopy3    ; now on a calculé les siny3 on calcul les sinx3

	move.l sin900,a0
	move.l sinx3,a1 
	move.w #900-1,d0
.loopx3
	moveq #0,d1
	move.w (a0)+,d1
	add.w #32767,d1
	mulu #80*subpixel*4,d1
	swap d1
	and.w #-4,d1
	move.w d1,(a1)+    ; sinx3
	dbf d0,.loopx3


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

totoisback
	move.l parametreInternStep,a6		; le seul registre dispo
.automodif
	lea ram3,a0
	move.w #512,d0
	move.w #nbbob,d2 ; nombre de copie de valeur
	move.w (a6)+,d1
	;move.w #512-13,d1		; pas interne 5 /512
	move.l sinx1,a3
	jsr createContigustable
.auto1	move.l a1,ptrref1

	move.w #512,d0
	move.w (a6)+,d1
	;move.w #14,d1
	move.w #nbbob,d2
	move.l sinx2,a3
	jsr createContigustable
.auto2	move.l a1,ptrref2

	move.w #512,d0
	move.w (a6)+,d1
	;move.w #512-16,d1
	move.w #nbbob,d2
	move.l siny1,a3
	jsr createContigustable
.auto3	move.l a1,ptrref3

	move.w #512,d0
	;	move.w #19,d1
	move.w (a6)+,d1	
	move.w #nbbob,d2
	move.l siny2,a3
	jsr createContigustable
.auto4	move.l a1,ptrref4

	move.w #900,d0
	move.w (a6)+,d1
	move.w #nbbob,d2
	move.l sinx3,a3
	jsr createContigustable
	move.l a1,ptrref5

	move.w #900,d0
	move.w (a6)+,d1
	move.w #nbbob,d2
	move.l siny3,a3
	jsr createContigustable
	move.l a1,ptrref6

; ordre des ptrref:
; ptrref1,2,5  3,4,6



	lea ajoutangle,a5
	move.w (a6)+,(a5)+
	move.w (a6)+,(a5)+
	move.w (a6)+,(a5)+
	move.w (a6)+,(a5)+
	lea angles,a5
	move.w #128,(a5)+
	move.w #128,(a5)+
	move.w #0,(a5)+
	move.w #0,(a5)

	move.l a6,parametreInternStep
	move.l (a6),d0
tstt	cmp.l #$31415926,d0
	bne.s .nolooop
	move.l #fct,d0
	move.l d0,parametreInternStep
.nolooop

;	lea .automodif+2,a0
;	move.l (a0),d0
;	cmp.l #ram3,d0
;	beq.s .modif1
;	move.l #ram3,(a0)
;	move.l #ptrref1,d1
;	move.l d1,.auto1+2
;	move.l #ptrref2,d1
;	move.l d1,.auto2+2
;	move.l #ptrref3,d1
;	move.l d1,.auto3+2
;	move.l #ptrref4,d1
;	move.l d1,.auto4+2
;
	rts
;.modif1
;	move.l ptrscr3,d1	64k libre
;;	move.l d1,(a0)
;
;	move.l #ptrref5,d1
;	move.l d1,.auto1+2
;	move.l #ptrref6,d1
;	move.l d1,.auto2+2
;	move.l #ptrref7,d1
;	move.l d1,.auto3+2
;	move.l #ptrref8,d1
;	move.l d1,.auto4+2
;	
;	rts

parametreInternStep	dc.l fct

fct	dc.w 512-13,14,512-16,11
	   dc.w 3,4,7,6
	dc.w 4,11,512-12,3
	   dc.w 9,512-13,17,6
	dc.w 10,512-19,5,512-15
	   dc.w 2,4,1,3
	dc.w 10,2,30,4
	   dc.w 4,9,5,8
	dc.w 5,15,10,512-6
	   dc.w 10,9,11,7
	dc.w 50,512-45,42,43
	dc.w 3,5,2,1

	dc.w 10,9,8,11
	dc.w 7,15,9,13

	dc.w 5,6,7,8
	dc.w 9,10,11,12

	dc.w 50,512-59,512-47,43
	dc.w 10,20,15,16
	
	dc.w 100,2,99,3
	dc.w 2,13,3,15
	
	dc.w 200,5,207,512-6
	dc.w 10,4,512-13,12



	dc.l $31415926



changefct
	jmp totoisback
	; swap ptrref1..4 to ptrref5..8
;	lea ptrref1,a0
;	movem.l (a0),d0-d3
;	lea ptrref5,a1
;	movem.l (a1),d4-d7
;	movem.l d0-d3,(a1)
;	movem.l d4-d7,(a0)
;	
	;; to be continued
		
	;rts


;superhackitVBL:			; remplace it 70.w
;	addq.l #1,$466.w
;	movem.l d0-d7/a0-a6,-(sp)
;	lea (8+7)*4+2(sp),a0
;	move.l (a0),d0		; adresse de retour de l'interuption
;	cmp.l #waitvbl,d0    d0-waitvbl>0   d0>waitvbl
;	bge.s .suitedutest
;	
;	jsr savejob
;
;	jmp .noprecalc
;.suitedutest
;	cmp.l #finwaitvbl,d0  d0-fin<0 d0<fin	; en fait metre toute les routine
;						; qui calcul entre 2 adresse
;	bge.s .noprecalc	
;			
;	jsr savejob
;
;.noprecalc
;	movem.l (sp)+,d0-d7/a0-a6
;	rte
;savejob	move.l (a0),actualjob
;	
;
calcAllposOLD				; deprecated
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

	move.l codecurefface,a4

	move.l ptrConvX,d0
	move.l ptrConvY,d1
	move.l log,d3

	move.w #nbbob-1,d2
	
	moveq #0,d4
	move.w seuil,d5
.loopcalcul

	move.w d5,d0
	add.w (a2)+,d0
	add.w (a3)+,d0

	move.l d0,a6
	move.w (a6),d3 			;  y*160

	move.w (a5)+,d0
	add.w (a1)+,d0

	move.l d0,a6
	add.w (a6)+,d3
	move.w d3,(a4)+			; effacement offset
	move.l (a6)+,(a4)+		; routine d'effacement

	move.l (a6),a6			; routine d'affichage
	move.l d3,a0

	jsr (a6)
;	move.w d5,d0
;	add.w (a2)+,d0
;	add.w (a3)+,d0
;
;	move.l d0,a6
;	move.w (a6),d3 			;  y*160
;
;	move.w (a5)+,d0
;	add.w (a1)+,d0
;
;	move.l d0,a6
;	add.w (a6)+,d3
;	addq.w #4,d3
;	move.w d3,(a4)+			; effacement offset
;	move.l (a6)+,(a4)+		; routine d'effacement
;
;	move.l (a6),a6			; routine d'affichage
;	move.l d3,a0
;
;	jsr (a6)
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

calcAllpos
;	move.l ptrref1,a5
;	move.l ptrref2,a1
;	move.w ang1,d0
;	add d0,d0
;	add d0,d0
;	add.w d0,a5
;	move.w ang2,d0
;	add d0,d0
; 	add.w d0,d0
;	add.w d0,a1

; calcul des sinus y dans un tableau intermediaire
	move.l ptrref3,a2
	move.l ptrref4,a3
	move.l ptrrefY1,a4     ; reference 3iem sinus Y, nb element different de 512
	move.w ang3,d0
	add d0,d0
	add d0,d0
	add d0,a2
	move.w ang4,d0
	add d0,d0
	add d0,d0
	add d0,a3
	move.w angY1,d0 	;	    ptrrefY1 et angY1 n'existe pas encore
	add d0,d0
	add d0,d0
	add d0,a4


;	move.l (a5),a5
;	move.l (a1),a1

	move.l (a2),a2
	move.l (a3),a3
	move.l (a4),a4  		; ptrrefY1-> adresse serie de nbbob valeur de sinus

	move.l codecurefface,a5  buffer pour l'effacement, qui va maintenant servir aussi pour l'affichage
	move.l ptrConvY,d1
	move.w #nbbob-1,d2
	moveq #0,d4
	move.w seuil,d5
.loopcalcul

	move.w d5,d1
	add.w (a2)+,d1
	add.w (a3)+,d1
    add.w (a4)+,d1

;	move.l d0,a6
;	move.w (a6),d3 			;  y*160

;	move.w (a5)+,d0
;	add.w (a1)+,d0

;	move.l d0,a6
;	add.w (a6)+,d3

	move.l d1,a6 			; convY contient adresse 0 = cliping, 16*160= debut de l'ecran

	move.w (a6)+,(a5)+
	dbf d2,.loopcalcul

	lea -nbbob*2(a5),a5  	; a5 contient tout les offset Y calculé a partir de 3 sinus dont 1 de taille 
							; differente
	move.w #nbbob-1,d2

	move.l ptrConvX,d1
	move.l log,d3 			a ton besoin de l'ecran a ce stade ??

	move.l ptrref1,a2
	move.l ptrref2,a3
	move.l ptrrefX1,a4     ; reference 3iem sinus X, nb element different de 512
	move.w ang1,d0
	add d0,d0
	add d0,d0
	add d0,a2
	move.w ang2,d0
	add d0,d0
	add d0,d0
	add d0,a3
	move.w angX1,d0 	;	    ptrrefX1 et angX1 n'existe pas encore
	add d0,d0
	add d0,d0
	add d0,a4

	move.l (a2),a2
	move.l (a3),a3
	move.l (a4),a4

	lea routeffaff,a1 		; n'existe pas encore


.loopcalcul2
; dans a5  l'ensemble des offset Y

	move.w (a2)+,d1
	add.w (a3)+,d1
	add.w (a4)+,d1

	move.l d1,a6 		; 
						; je vais changer pour convx[i]=offset,numero d'affichage*4 octet	
	move.w (a5),d7
	add.w (a6)+,d7
	move.w d7,(a5)+
	

						   *move.w (a5)+,d3     ; ca me semble super chelou....
	move.w (a6)+,(a1)+  ; numero d'effacage affichage du x nb entre 0 et 15
    dbf d2,.loopcalcul2


; now affichage
	
	lea codegenliste,a4 	; bien un lea
	move.l codecurefface,a2 ; offsetX+Y+seuil
	lea routeffaff,a3 		; numero 0..15*4 
	lea -nbbob*2(a1),a1    ; codecurefface
	moveq #0,d4            ; registre reservé pour les moves de masque dans les codes generes actuels
	move.l log,d0
; d7 reservé pour le masquage de plusieur section du sprite d7 affecté dans les code genere
    move.w #nbbob-1,d2

.loopcalcul3
	move.w (a2)+,d0         ; log + offsetx+offsety
	move.l d0,a0            ; addresse ecran pour la routine d'affichage
	move.l (a3)+,d1
	move.l a4,a6
	add.w d1,a6
	move.l (a6),a6 			; routine d'affichage

	jsr (a6)				; plus tard un jmp(an) a la place des rts
	dbf d2,.loopcalcul3





;	move.w d5,d0
;	add.w (a2)+,d0
;	add.w (a3)+,d0
;
;	move.l d0,a6
;	move.w (a6),d3 			;  y*160
;
;	move.w (a5)+,d0
;	add.w (a1)+,d0
;
;	move.l d0,a6
;	add.w (a6)+,d3
;	addq.w #4,d3
;	move.w d3,(a4)+			; effacement offset
;	move.l (a6)+,(a4)+		; routine d'effacement
;
;	move.l (a6),a6			; routine d'affichage
;	move.l d3,a0
;
;	jsr (a6)
;	dbf d2,.loopcalcul

	
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
	moveq #2,d1
	swap d1
	jsr getmem1					; prepare 16 zone memoire allant de 32768 a 1 octet (puissance de 2)

	lea ptrMem,a0
	movem.l (a0)+,d0-d3			; 1 buffer de 32k un de 16k un de 8k un de 4k  pas aligné mais contigu au meme segment  

;	move.l d3,sinX1			; sinx1 x2 y1 y2 devenu des pointeur sur
							; 512 word
;	move.l #1024,d5
;	add.l d5,d3
;	move.l d3,sinX2
;	add.l d5,d3
;	move.l d3,sinY1
;	add.l d5,d3
;	move.l d3,sinY2					; place pour 4k = 4 table de 512 word


								; cad poid fort de l'adresse du buffer est toujours a la meme valeur 
	move.l d0,ptrConvY			; 32k alloué pour convy: 1856*2 en comptant cliping haut bas de 16 pixel de hauteur et 4 subpixel
	add.l #2*subpixel2*400,d0
	; 30912 octet libre
	move.l d0,ptrConvX	; 12800 octet pour 320 pixel 4 subpixel 10 octet (adresseEFF,adresseAFF,offset)
	add.l #320*subpixel2*10,d0		; pile poil 4 subpixel  convy 232*8 subpixel*2 + 352*8 subpixel*10 octet
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
	add.l d4,d0
	move.l d0,flagtab	

	move.l d1,ptr16k
	move.l d2,ptrFlag			; 8k max pour les flag, sinus dont le nombre d'element ne depasse pas 8192
	move.l d3,ptr4k

	lea ptrMem+4*4,a0
	movem.l (a0)+,d0-d3
	move.l d0,sin900      2k ca tient
	move.l d1,sin512      1k ca tient pile poil
	
	

	move.l #screenbuf,d0
	moveq #1,d1
	swap d1
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

	move.l #sintempx3,sinx3
	move.l #sintempy3,siny3 


	rts
timer1	dc.w 700
waitvbl
	subq.w #1,timer1
	tst.w timer1
	bne.s .titi
	move.w #700,timer1
	move.w #1,flagtransition
	
	
.titi
	ifne tempmachine
	not.w $ffff8240.w
	rept 60
	nop
	endr
	not.w $ffff8240.w
	endc

	move.w $468.w,d0
.loop	cmp.w $468.w,d0
	beq.s .loop
	rts
nowaitvbl
swap_screen
	move.l log,d0
	move.l phys,d1
	move.l d0,phys
	move.l d1,log

	add.l #16*160,d1
	
	lsr.w #8,d1
	move.l d1,$ffff8200.w
	rts

extractsprite

	ifne spr_pi1

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
	endc

	ifeq spr_pi1
		lea pal_and_sprite,a0
		movem.w (a0)+,d0-d3
		movem.w d0-d3,$ffff8240.w
		;addq.w #2,d0
		;addq.w #2,d1
		;addq.w #2,d2
		;addq.w #2,d3
		;movem.w d0-d3,$ffff8248.w
		lea spritedeca,a1
		moveq #0,d1
		moveq #15,d7
.loop000
		move.l (a0)+,d0
		move.l d0,(a1)+
 	 	move.l d1,(a1)+
	 	dbf d7,.loop000
	endc
	

	moveq #14,d7
	lea spritedeca,a1
	move.l a1,a3
	lea 128(a1),a2
	move.l a2,a4
.copyandshift
	move.w #15,d6
.ligne
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

;*************************************************************************************
;
;   prepareMask
;
;*************************************************************************************
*prepareMask
*	move.w #15,d1
*	lea setoffset,a0
*	moveq #0,d0
*.loop00
*	move.w d0,(a0)+
*	addq.w #8,d0
*	move.w d0,(a0)+
*	add.w #160-8,d0
*	dbf d1,.loop00
*
*	lea setflag,a0
*	move.w #7,d1
*	moveq #0,d0
*.loop000
*	move.l d0,(a0)+			; 4*8 = 32 position a 0, utilisé par le scaner
*	dbf d1,.loop000
*
*
*	lea spritedeca,a0
*bigloop16sprites
*	lea spritemask,a2
*
*	move.w #15,d0
*	moveq #0,d6
*.loopmaskligne
*	move.w (a0)+,d2
*	and.w (a0)+,d2
*	not.w d2
*	move.w (a0)+,d3
*	and.w (a0)+,d3
*	not.w d3
*	move.w d2,(a2)+
*	move.w d3,(a2)+
*	dbf d0,.loopmaskligne
*	lea -4*16(a2),a2
*
*; a2 = ensemble des not mask un word=16 pixel, 32 pixel pour 2 masque * 15 = 32 valeur de mask
*
*
*	lea listeoccurmask,a1
*	lea moveliste,a3
*	lea setflag,a4
*	lea spritemask,a2
*
*	move.w #14,d0
*	move.w (a2)+,d2
*	move.b #1,(a4)+	
*
*	moveq #0,d4 	; nombre d'occurence
*	moveq #0,d6		; numero d'offset
*	    
 *.searchoccurence
*	move.w d2,(a1)+			; valeur de d2 dans liste occurence
*   move.w d6,(a1)+
*  move.w d0,d5  			; au debut 14 ligne a verifier
*	add.w d5,d5
* 	;subq.w #1,d5
* .scanit
* 	addq.w #1,d6
* 	tst.b (a4)
* 	bne.s .skip
* 	move.w (a2)+,d3
*	cmp.w d3,d2
*	beq.s .match
*	                        ;addq.w #1,d6
*	addq.l #1,a4
*	dbf d5,.scanit
*	bra.s .suite
*.match 
*	move.w d6,(a1)+
*	addq.w #1,d4   ; nombre d'occurence -1
*	;addq.w #1,d6   ; offset 0 1  to 30 31
*	move.b #1,(a4)+
*	dbf d5,.scanit
*	bra.s .suite
*.skip
*	addq.l #2,a2
*	addq.l #1,a4
*
*	dbf d5,.scanit
*.suite
*	bra.s .1
*	nop
*.1
*
*	; ici on a scanné un mot (le premier au depart) et on a la liste des indice 
*
*	tst.w d4
*	beq.s .unexemplaire
*	lea listeoccurmask,a1
*	move.w (a1)+,d2
*.loop
*
*
*
*	tst.w d2  				;not masque a 0  ? -> pas de and et un move sur les data
*	beq.s .vide		
*	cmp.w #-1,d2 			;not masque = FFFF -> zero truc affiché
*	beq.s .zerodata
; 

*.vide
*	
*
; more than 2 occurence

*	sub.w d4,a1
*	sub.w d4,a1


	; codage:
	;  move.l maskmask,dn
	;  and.l dn,dep(a0)
	;  or.w #$1234,dep(a0) si un seul plan et plan 0
	; ou 
	;  or.l #$12345678,dep(a0)  si 2 plan ocupé
	;
	;  si dans ce cas, alors on peut optimiser en utilisant un lea
	;
	;  move.l #maskmask,d7
	;  lea dep(a0),a6

	;  and.l d7,(a6)
	;  or.w/or.l #1234/12345678,(a6)

	; si or se trouve au deuxieme plan seulement
	; and.l d7,dep(a0)
	; or.w #$1234,dep+2(a0)		 plus rapide

*	move.w -2(a1),d7
*	move.w d7,d6
*	swap d7
*	move.w d6,d7
*	; d7 = maskmask


*structure1
*	move.l #0,d7
*
*	and.l d7,dep(a0)
*	; or.w #1234,dep+2(a0)		; 2 nop pour les dep si 2iem plan de donné seulement, on pioche dans a0
*
*	; sinon on pioche dans a6
*	lea $1234(a0),a6
*	and.l d7,(a6)
*	or.l #0,(a6)
*	or.w #0,(a6)
*
*
*
*
;***************************************************************************************************
;
;**************************************************************************************************

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

	tst.w d2
	beq.s .move

	; and.l d2,d6(a0)   02a8

	move.w #$02a8,(a1)+		; + 8 octet au code genere
	move.l d2,(a1)+
	move.w d6,(a1)+
 	bra.s .aa
.move	move.w #$2144,(a1)+
	move.w d6,(a1)+
.aa
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
	tst.w d2
	beq.s .move
	; and.l d2,d6(a0)   02a8

	move.w #$02a8,(a1)+		; + 8 octet au code genere
	move.l d2,(a1)+
	move.w d6,(a1)
	subq.w #2,(a1)+
	bra.s .aa

.move	move.w #$2144,(a1)+
	move.w d6,(a1)
	subq.w #2,(a1)+


.aa
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

	tst.l d2
	bne.s .aa

	; and.l #0 remplacer par un move.l d4,dep(a0)
	move.w #$2144,(a1)+
	move.w d6,(a1)+

	bra.s .bb
.aa
	move.w #$02a8,(a1)+
	move.l d2,(a1)+
	move.w d6,(a1)+
					; + 8 octets
.bb
	move.w #$A8,(a1)+
	move.l d7,(a1)+
	move.w d6,(a1)+

	move.w #$2140,(a4)+
	move.w d6,(a4)+

;	;move.l (sp)+,d3
;	move.l (sp)+,d2

	rts

cpttransfo	dc.w 200/2-1
steptransfo	dc.w -subpixel2*2*2
transfo1
	move.w steptransfo,d0
	add.w d0,seuil
	subq.w #1,cpttransfo
	tst cpttransfo
	bne.s .ok
	tst.w steptransfo
	bpl.s .stoptransition
	move.w #200/2-1,cpttransfo
	neg.w steptransfo
	jsr changefct
	rts
	
.stoptransition
	neg.w steptransfo
	move.w #200/2-1,cpttransfo
	move.w #700,timer1
	move.w #0,flagtransition
.ok	rts

flagtransition	dc.w 0
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

	;movem.l d0-d3/a0-a6,-(sp)
	
;:	move.l flagtab,a2	moveq #0,d3
;	move.l d3,(a2)+
;	move.l d3,(a2)+
;	lea 512-8(a2),a2
;	move.l d3,a4
;	move.l d3,a5
;	move.l d3,d4
;	move.l d3,d5
;	move.l d3,d6
;	move.l d3,d7

;	rept 32
;	movem.l d3-d7/a4/a5,-(a2)   7 registre *4 = 28 octet 512/36=12 reste 8 octet
;	endr
;	SUBQ #8,a2 			; 36*14=504  512-504=8


     move.l flagtab,a2
     move d0,d2
     moveq #0,d3
     subq #1,d2
.clearflag
     move.b d3,(a2)+
     dbf d2,.clearflag



	move.l a0,a1		; a1 = table refsin
	move.l a1,-(sp)
	move.w d0,d3
	add.w d3,d3		; *2
	move.l a3,a4
	add.w d3,a4
	add.w d3,d3		; *4
	add.w d3,a0			; a0 =ram











	move.l flagtab,a2
	move.l a2,a5
	add.w d0,a5
	


	moveq #0,d5			; angle
	
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
	move.w d2,d6		; nombre de coPIE
	subq.w #1,d6
	;addq.w #1,d6

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

; depack periodictable
; a0 = packed data
; a1 = unpacked data
depackperiod
	lea extnibble,a2

	move.w (a0)+,d0		; nombre d'element de la table finale
	move.w (a0)+,d1		; tab[0]
	move.w (a0)+,d2		; delta[0]=tab[1]-tab[0]
	move.w d0,d3
	subq #2,d3	    ; nombre de delta de delta: delta2[0]=delta[1]-delta[0]
	lsr #1,d3
.ok
	subq #1,d3
	;bset #0,d3			; si paire = nb impair d'element on set a +1
						; si impair  nb pair d'lement on ne change rien
	move.w d1,(a1)+		; tab[0]
	
.loop
	add d2,d1			; tab[0]+delta[0]=tab[1]
	move.w d1,(a1)+
	
	move.b (a0)+,d4		 lire 2 valeur
	move.w d4,d5
	and.w #$F0,d4
	lsr #4,d4
	move.b (a2,d4.w),d4
	ext.w d4
	add d4,d2			: delta2[0]=delta[1]-delta[0]  d2= delta[1]=tab[2]-tab[1]
	
	add d2,d1
	move.w d1,(a1)+
	and.w #$F,d5
	move.b (a2,d5.w),d5
	ext.w d5
	add d5,d2

	dbf d3,.loop
	add d2,d1
	move.w d1,(a1)+
	rts

; format de memoire
;toto			; le label toto est la pour verifier l'algo
;	ds.b 65536	
;buffer	ds.l 65536*2    8*64k				; buffer sera aligné sur 64k donc un peu avant
;fin											; et apres un peu de memoire libre entre fin buffer et label fin


;
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
	
	
	add.l d1,d3		; d3+ 4*64k = adresse start haut


	
	lea ptrMem,a0
	moveq #0,d6
	move.w #$8000,d6
	
.loop
	move.w d6,d1
	and.w d7,d1

	; bit 15 a 0 ? 
	tst.w d1
	beq.s .before			; was beq
	move.l d3,(a0)+
	add.l d6,d3
	
	bra.s .suite
.before
	move.l d4,(a0)+
	add.l d6,d4
.suite
	lsr.w #1,d6
	tst.w d6
	bne.s .loop			; ici ca s'arrete a un buffer de 1 octet il faudrai faire un meilleur test
	
	lea -64(a0),a0					; et s'arreter a un plus gros buffer 
	rts
		
extnibble	dc.b 0,1,2,3,4,5,6,7,$F8,$f9,$fa,$fb,$fc,$fd,$fe,$ff
	even

	include 'BASEROU2.S'
	


	DATA
codelog	dc.l 0
cptdeca	dc.w 0
angles	dc.w 128,128,50,70
	dc.w 275,275,0,0

ajoutangle	dc.w 6+256,23,512-12,7+256
ptrlsteff	dc.l efface1lst
			dc.l efface2lst
			;dc.l efface3lst
			;dc.l efface4lst

ang1	dc.w 128
ang2	dc.w 128
ang3	dc.w 10
ang4	dc.w 0
ajoutang1	dc.w 4
ajoutang2 	dc.w 1
ajoutang3	dc.w 512-3
ajoutang4   dc.w 1
	
packed_sinus_table:
	
sin1pack
    dc.w 512  ; nombre d'element depack
	dc.w 0je
	dc.w 402

	dc.b	  0,241,240,240,240,240,224,255,254,14,13,14,254,239,238,253
	dc.b	  253,253,239,207,221,252,238,206,222,206,206,205,221,220,220,235
	dc.b	  221,204,205,204,205,189,189,189,188,203,219,203,203,218,204,188
	dc.b	  187,203,203,187,202,218,188,187,187,202,203,187,187,187,202,202
	dc.b	  202,203,187,187,187,202,203,187,188,186,218,203,187,203,203,188
	dc.b	  188,202,219,203,203,219,204,189,189,189,189,204,205,204,205,219
	dc.b	  236,220,221,221,206,206,206,222,206,236,253,223,207,237,253,253
	dc.b	  254,239,238,254,13,14,14,255,240,224,240,240,240,241,240,0
	dc.b	  0,31,16,16,16,16,32,17,18,2,3,2,18,33,34,19
	dc.b	  19,19,33,65,51,20,34,66,50,66,66,67,51,52,52,37
	dc.b	  51,68,67,68,67,83,83,83,84,69,53,69,69,54,68,84
	dc.b	  85,69,69,85,70,54,84,85,85,70,69,85,85,85,70,70
	dc.b	  70,69,85,85,85,70,69,85,84,86,54,69,85,69,69,84
	dc.b	  84,70,53,69,69,53,68,83,83,83,83,68,67,68,67,53
	dc.b	  36,52,51,51,66,66,66,50,66,36,19,49,65,35,19,19
	dc.b	  18,33,34,18,3,2,2,17,16,32,16,16,16,31,16,0
	even

sin2pack
    dc.w 900  ; nombre d'element depack
	dc.w 0
	dc.w 228

	dc.b	  16,241,15,31,0,0,15,31,0,15,0,15,0,15,0,240
	dc.b	  240,15,0,240,240,240,240,240,240,255,0,255,240,14,0,224
	dc.b	  240,255,240,255,255,15,255,14,15,255,240,239,14,15,254,15
	dc.b	  254,15,224,254,14,240,239,254,14,14,255,224,239,255,239,255
	dc.b	  224,238,14,254,255,254,255,239,239,255,238,14,239,254,254,255
	dc.b	  239,239,239,239,254,239,239,254,239,254,239,239,239,239,239,238
	dc.b	  254,254,254,254,239,239,238,254,254,254,239,238,255,238,239,254
	dc.b	  238,255,238,239,254,239,238,254,254,254,239,239,238,254,254,254
	dc.b	  254,239,239,239,239,239,238,255,238,255,239,238,255,239,239,239
	dc.b	  239,254,254,255,238,14,239,255,239,239,254,255,254,254,14,224
	dc.b	  239,255,239,255,224,239,254,14,14,255,224,254,14,240,239,14
	dc.b	  255,14,255,14,15,224,255,255,14,15,240,224,255,240,255,240
	dc.b	  240,224,14,0,255,240,15,240,240,240,240,240,240,240,15,0
	dc.b	  240,240,15,0,15,0,15,0,15,31,0,0,15,31,1,240
	dc.b	  16,240,31,1,241,0,0,1,241,0,1,0,1,0,1,0

	dc.b	  16,16,1,0,16,16,16,16,16,16,17,0,17,16,2,0
	dc.b	  32,16,17,16,17,17,1,17,2,1,17,16,33,2,1,18
	dc.b	  1,18,1,32,18,2,16,33,18,2,2,17,32,33,17,33
	dc.b	  17,32,34,2,18,17,18,17,33,33,17,34,2,33,18,18
	dc.b	  17,33,33,33,33,18,33,33,18,33,18,33,33,33,33,33
	dc.b	  34,18,18,18,18,33,33,34,18,18,18,33,34,17,34,33
	dc.b	  18,34,17,34,33,18,33,34,18,18,18,33,33,34,18,18
	dc.b	  18,18,33,33,33,33,33,34,17,34,17,33,34,17,33,33
	dc.b	  33,33,18,18,17,34,2,33,17,33,33,18,17,18,18,2
	dc.b	  32,33,17,33,17,32,33,18,2,2,17,32,18,2,16,33
	dc.b	  2,17,2,17,2,1,32,17,17,2,1,16,32,17,16,17
	dc.b	  16,16,32,2,0,17,16,1,16,16,16,16,16,16,16,1
	dc.b	  0,16,16,1,0,1,0,1,0,1,241,0,0,1,241,15
	dc.b	  16,16
	even



	ifne spr_pi1
pi1	incbin 'SPRITE3.PI1'
	endc

pal_and_sprite
	ifeq spr_pi1
	  incbin 'PAS4.SPR'
	
	endc
;	even
	DATA
seuil	dc.w segmenty
	
	BSS
		rsreset
segmentX	rs.w 1
segmentY	rs.w 1	
codecurefface	ds.l 1
;tempbuffer	ds.w 2048

sin512 	ds.l 1 
sin900  ds.l 1
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

	
	ds.b 65536
screenbuf
	ds.w 65536
	;ds.w 65536
	
log		ds.l 1
phys	ds.l 1
ptrscr1	ds.l 1
ptrscr2	ds.l 1
ptrscr3	ds.l 1
ptrscr4	ds.l 1


;convx	ds.l 320*subpixel
;convy	ds.w 200*subpixel
ptrvariable	ds.l 1
ptrconvX ds.l 1
ptrconvY ds.l 1

sinx1	ds.l 1   *ds.w 512
sinx2	ds.l 1   *ds.w 512
siny1	ds.l 1   *ds.w 512
siny2	ds.l 1   *ds.w 512

sinx3	ds.l 1   * ds.w 900
siny3   ds.l 1   * ds.w 900

sintempx3	ds.w 900
sintempy3	ds.w 900

flagtab	ds.l 1

ptrref1	ds.l 1
ptrref2	ds.l 1
ptrref3	ds.l 1
ptrref4	ds.l 1

ptrrefX1
ptrref5	ds.l 1
ptrrefY1
ptrref6	ds.l 1
ptrref7	ds.l 1
ptrref8	ds.l 1


efface1lst
		ds.w nbbob*6
efface2lst
		ds.w nbbob*6
;efface3lst
;		ds.w nbbob*6
;efface4lst
;		ds.w nbbob*6


codegenliste	ds.l 16
codeeffliste	ds.l 16
ram	ds.b ($b24dA-$b19f2)+2000
	ds.b 3000
ram2	ds.b 5000
;	ds.l 5000
ram3	ds.b 16000
	
;convxSprite	ds.l 320*2*subpixel
	

sprite	ds.w 32

spritedeca
	ds.w 128*16

routeffaff	ds.w nbbob