
**************************************************************************
*
*      COMPACTEUR/DECOMPACTEUR D'IMAGES POUR COMPILATEUR STOS BASIC
*
*      (c) FL Soft 1987/89
*
**************************************************************************

	INCLUDE "EQUATES.S"

**************************************************************************

Debu:           dc.l Para-Debu
                dc.l Data-Debu
                dc.l Libr-Debu

***************************** CATALOGUE **********************************

Cata:   dc.w l2-l1,l3-l2

Para:   dc.w 2,2                                ;Nombre de routines/fonc
        dc.w p1-Para,p2-Para
p1:     dc.b 0 
        dc.b 0,1
        dc.b 0,",",0,1
        dc.b 0,",",0,",",0,1
        dc.b 0,",",0,",",0,",",0,1
        dc.b 0,",",0,",",0,",",0,",",0,1
        dc.b 1,0
p2:     dc.b 0                                  ;Ramene un entier
        dc.b 0,",",0,1
        dc.b 0,",",0,",",0,",",0,",",0,",",0,",",0,",",0,",",0,1
        dc.b 1,0

********************** PARAMETRES / INIT *******************************

Data:           bra Init

params:         equ 4                   ; blk.w 9,0
larg:           equ 9*2+params          ; dc.w 0
haut:           equ larg+2              ; dc.w 0
unpflg:         equ haut+2              ; dc.w 0
adobjet:        equ unpflg+2            ; dc.l 0 
nbplan:         equ adobjet+4           ; dc.w 0
taillex:        equ nbplan+2            ; dc.w 0
tailley:        equ taillex+2           ; dc.w 0
adycar:         equ tailley+2           ; dc.w 0
tmode:          equ adycar+2
palnul:         equ 3*4*2+tmode
resol:          equ $44c

                ds.b  tmode-4
                dc.w  160,8,4,200
                dc.w  160,4,2,200
                dc.w  80,2,1,400
                ds.w  16

;------------------------------> entete de l'image compactee
code:           equ 0           ;code de reconnaissance: $06071963
cmode:          equ 4           ;resolution
dx:             equ 6           ;debut en X (mots)
dy:             equ 8           ;debut en Y (pixels)
tx:             equ 10          ;taille en X (mots)
ty:             equ 12          ;taille en Y (carres de compactage)
tcar:           equ 16          ;taille du carre de compactage
flags:          equ 18          ;flags divers
table2:         equ 20          ;adresse de la table 2
point2:         equ 24          ;adressse des pointeurs 2
palette:        equ 38          ;palette de couleurs
dcomp:          equ 70          ;debut du compactage de l'image


Init:   lea End(pc),a2
End:	rts

Libr:
**************************************************************************

adoubank:       equ 214
adecran:        equ 234
aback1:         equ 578
aback2:         equ 579

**************************************************************************
*       Unpack origine[ ,ecran [,flags] [,dx,dy] ]
l1:     dc.w l1a-l1,l1b-l1,l1c-l1,l1d-l1,0
******************************************
        move.l Debut(a5),a3
        move.l 0(a3,d1.w),a3            ;Adresses des extensions

        clr unpflg(a3)
        lea params(a3),a2
        move.w #-1,(a2)                 ;flags par defaut
        move.l adback(a5),2(a2)         ;decor des sprites
        move.w #-1,6(a2)                ;dx
        move.w #-1,8(a2)                ;dy

        cmp.w #1,d0 
        beq.s unp4
        cmp.w #2,d0
        beq.s unp3
        cmp.w #3,d0
        beq.s unp1
        cmp.w #4,d0
        beq.s unp2
; Cinq parametres
        move.l (a6)+,d3
        move.w d3,8(a2)
        move.l (a6)+,d3
        lsr.w #4,d3     ;divise par 16!
        move.w d3,6(a2)
; Trois parametres
unp1:   move.l (a6)+,d3         ;Flag
        move.w d3,(a2)
        bra.s unp3
; Quatre parametres
unp2:   move.l (a6)+,d3
        move.w d3,8(a2)
        move.l (a6)+,d3
        lsr.w #4,d3
        move.w d3,6(a2)
; Deux parametres
unp3:   move #1,unpflg(a3)      ;Image
l1a:    jsr adecran
        move.l d3,2(a2)
; Un parametre         
unp4:   
l1b:    jsr adoubank
        move.l d3,a0            ;adresse d'origine
        move.l 2(a2),a1         ;adresse destination
        move.w 6(a2),d1         ;dx
        move.w 8(a2),d2         ;dy
        move.w (a2),d3          ;flags
;
        tst unpflg(a3)          ;si l'adresse d'ecran est precisee              
        bne.s unp5              ;aucune gestion d'autoback
l1c:    jsr aback1
unp5:   bsr decomp
        tst unpflg(a3)
        bne.s unp6
        move.w d0,-(sp)
l1d:    jsr aback2
        move.w (sp)+,d0
unp6:   tst d0
        bne.s l1fc
        rts
l1fc:   moveq #13,d0
        move.l error(a5),a0
        jmp (a0) 

********************************************** DECOMPACTEUR
decomp: movem.l a3-a6,-(sp)
        cmp.l #$06071963,code(a0)       ;verifie le code
        bne Derr2
 
; Prepare les parametres
        move.l a0,-(sp)         ;adresse d'origine
        move.l a1,-(sp)         ;adresse destination
;
        tst.w d3
        bpl.s dflag
        move.w flags(a0),d3
dflag:  move.w d3,-(sp)         ;pousse les flags
        btst #0,d3
        beq.s flag1
; Toutes les couleurs a zero pendant le travail! FLAG= XXXXXXX1
        movem.l a0-a1/d1-d2,-(sp)
        pea palnul(a3)
        move.w #6,-(sp)
        trap #14
        addq.l #6,sp
        movem.l (sp)+,a0-a1/d1-d2

flag1:  lea -10(sp),sp          ;place pour les parametres
        move.l a1,a4            ;a4--> adresse ecran
        lea tmode(a3),a2
        move.w cmode(a0),d0
        lsl.w #3,d0
        move.w 0(a2,d0.w),d7    ;d7--> taille ligne
        move.w 2(a2,d0.w),d6    ;d6--> taille plans
        move.w 4(a2,d0.w),d5    ;d5--> nbplans
        move.w 6(a2,d0.w),d4    ;d4--> taille en Y ecran
        move.w d5,nbplan(a3)
        tst.w d1
        bpl.s dec1
        move.w dx(a0),d1
dec1:   tst.w d2
        bpl.s dec2
        move.w dy(a0),d2
dec2:   mulu d6,d1              ;calcule et verifie en X
        add.w d1,a1
        move.w tx(a0),d0        ;taille en X en mots
        mulu d6,d0
        add d0,d1
        cmp d7,d1
        bhi Derr
        move.w ty(a0),d0        ;calcule et verifie en Y
        mulu tcar(a0),d0
        add.w d2,d0
        cmp.w d4,d0
        bhi Derr
        mulu d7,d2
        add.w d2,a1
        move.l a1,6(sp)         ;6(sp)--> adresse ecran de destination     
        move tcar(a0),d0
        mulu d7,d0
        move d0,2(sp)           ;2(sp)--> addition change de ligne de carre
        move d6,(sp)            ; (sp)--> addition change de carre
        move tcar(a0),d6        ;D6--> indice hauteur carre
        move.w tx(a0),d0
        subq #1,d0
        move d0,taillex(a3)
        move.w ty(a0),d0        
        move d0,tailley(a3)
        lea dcomp(a0),a4        ;a4--> table octets 1
        move.l a0,a5
        move.l a0,a6
        add.l table2(a0),a5     ;a5--> table octets 2
        add.l point2(a0),a6     ;a6--> table pointeurs
        moveq #7,d0             ;prepare les variables de compactage
        moveq #7,d1
        move.b (a5)+,d2
        move.b (a4)+,d3
        btst d1,(a6)
        beq.s prep
        move.b (a5)+,d2
prep:   subq #1,d1

; Decompactage proprement dit
dplan:  move.l 6(sp),a2
        move.w tailley(a3),4(sp)        ;4(sp)--> compteur tailleY
dligne: move.l a2,a1
        move.w taillex(a3),d5
dcarre: move.l a1,a0
        move.w d6,d4            ;  D4 --> compteur hauteur carre

doctet1:subq.w #1,d4
        bmi.s doct3
        btst d0,d2
        beq.s doct1
        move.b (a4)+,d3
doct1:  move.b d3,(a0)
        add.w d7,a0
        dbra d0,doctet1
        moveq #7,d0
        btst d1,(a6)
        beq.s doct2
        move.b (a5)+,d2
doct2:  dbra d1,doctet1
        moveq #7,d1
        addq.l #1,a6
        bra.s doctet1
doct3:  move.l a1,a0
        move.w d6,d4

doctet2:subq.w #1,d4
        bmi.s doct7
        btst d0,d2
        beq.s doct5
        move.b (a4)+,d3
doct5:  move.b d3,1(a0)
        add.w d7,a0
        dbra d0,doctet2
        moveq #7,d0
        btst d1,(a6)
        beq.s doct6
        move.b (a5)+,d2
doct6:  dbra d1,doctet2
        moveq #7,d1
        addq.l #1,a6
        bra.s doctet2
     
doct7:  add.w (sp),a1           ;autre carres ?
        dbra d5,dcarre
        add.w 2(sp),a2          ;autre ligne de carres?
        sub.w #1,4(sp)
        bne dligne
        addq.l #2,6(sp)         ;autre plan couleur?
        sub.w #1,nbplan(a3)
        bne dplan

        lea 10(sp),sp           ;retabli la pile

; Fin du decompactage
        move.w (sp)+,d1         ;recupere les flags
        move.l (sp)+,a1         ;adresse de destination
        move.l (sp)+,a0         ;adresse de l'image
        lea palette(a0),a0
        lea 32000(a1),a1
        move.l a1,a2
        moveq #15,d0
dpal:   move.w (a0)+,(a1)+
        dbra d0,dpal
        btst #1,d1              ;ne pas changer les couleurs de l'ecran
        beq.s findec            
        move.l a2,-(sp)         ;change les couleurs de l'ecran
        move.w #6,-(sp)
        trap #14
        addq.l #6,sp

findec: movem.l (sp)+,a3-a6
        moveq #0,d0
        rts

; Erreur!
Derr:   lea 20(sp),sp           ;restore la pile!
Derr2:  movem.l (sp)+,a3-a6
        moveq #-1,d0
        rts

**************************************************************************
*       PACK (image,destination [,mode,flags,hauteur,dx,dy,tx,ty])
l2:     dc.w l2a-l2,l2b-l2,0
***********************
        move.l Debut(a5),a3
        move.l 0(a3,d1.w),a3    ;Adresses des extensions

        lea params(a3),a2
        moveq #0,d4
        move.b $44c,d4          ;resolution .B!
        move.w d4,d1
        lsl.w #3,d1
        lea tmode(a3),a0
        moveq #0,d2
        move.w 6(a0,d1.w),d2    ;taille ecran en Y
        moveq #5,d3
        divu d3,d2
        move.w d2,(a2)+         ;TY
        moveq #0,d2
        move.w 0(a0,d1.w),d2    ;taille ligne en octets
        divu 2(a0,d1.w),d2      ;divise par taille plan en octet
        move.w d2,(a2)+         ;TX
        clr.w (a2)+             ;dy
        clr.w (a2)+             ;dx
        move.w d3,(a2)+         ;hauteur
        move.w #%11,(a2)+       ;flags
        move.w d4,(a2)+         ;resolution

        cmp.w #1,d0
        beq.s pack3
; Neuf parametres
        lea params(a3),a2
        moveq #6,d7
pack2:  
        move.l (a6)+,d3         ;empile les cinq params
        move.w d3,(a2)+
        dbra d7,pack2
; deux parametres
pack3:  
l2a:    jsr adoubank
        move.l d3,-(sp)
l2b:    jsr adecran
        move.l d3,-(sp)
; Verifie les parametres
        lea params(a3),a2   
        move.w 12(a2),d0        ;resolution image
        cmp.w #2,d0
        bhi l2fc
        lsl #3,d0
        lea tmode(a3),a0
        moveq #0,d1
        move.w 0(a0,d0.w),d1    ;verifie en X
        divu 2(a0,d0.w),d1
        move.w 6(a2),d2
        add.w 2(a2),d2
        cmp.w d1,d2
        bhi l2fc
        move.w (a2),d2          ;verifie en Y
        mulu 8(a2),d2
        add.w 4(a2),d2
        cmp.w 6(a0,d0.w),d2
        bhi l2fc
        move.w (a2)+,d5         ;ty
        beq l2fc
        move.w (a2)+,d4         ;tx
        beq l2fc
        move.w (a2)+,d3         ;dy
        move.w (a2)+,d2         ;dx
        move.w (a2)+,d1         ;hauteur
        beq l2fc
        move.w (a2)+,d6         ;flags
        move.w (a2)+,d7         ;resolution
        move.l (sp)+,a0
        move.l (sp)+,a1

********************************************** COMPACTAGE
        movem.l a4-a6,-(sp)

;-----> Preparation de l'entete de l'image compactee
        move.l a1,adobjet(a3)
        move.l #$06071963,code(a1)
        move.w d7,cmode(a1)
        move.w d2,dx(a1)
        move.w d3,dy(a1)  
        move.w d4,tx(a1)  
        move.w d5,ty(a1)   
        move.w d1,tcar(a1)  
        move.w d6,flags(a1)  

; Copie de la palette
        moveq #15,d0
        lea 32000(a0),a2        ;palette de couleurs apres l'image
        lea palette(a1),a4
copal:  move.w (a2)+,(a4)+ 
        dbra d0,copal

; Preparation des parametres
        move.l a0,a4            ;a4--> adresse image
        lea dcomp(a1),a5        ;a5--> adresse TABLE 1
        lea 32000(a5),a6        ;a6--> adresse POINTEUR 1
        move.l a6,-(sp)         ;pour plus tard!
        subq #1,d5
        move d5,tailley(a3)     ;taille en Y de l'image
        move d1,d5
        move.w cmode(a1),d0
        lsl #3,d0
        lea tmode(a3),a0
        move.w 0(a0,d0.w),d7    ;d7--> taille ligne
        move.w 2(a0,d0.w),d6    ;d6--> taille plans
        move.w 4(a0,d0.w),d0    ;d0--> nbplans
        move d0,nbplan(a3)
        move d7,d0
        mulu d5,d0
        move d0,adycar(a3)      ;passage en Y d'un carre a l'autre
        subq #1,d5              ;D5--> indice taille en Y du carre
        subq #1,d4
        move d4,a0              ;a0--> indice taille en X
        move.w dy(a1),d0
        mulu d7,d0
        add.w d0,a4
        move.w dx(a1),d0
        mulu d6,d0
        add.w d0,a4             ;a4--> adresse dans l'ecran
        move.l a4,-(sp)
        moveq #7,d1             ;indice compactage
        clr.b (a5)              ;premier octet a zero
        clr.b (a6)              

; Compactage proprement dit
plan:   move.l (sp),a4
        move.w tailley(a3),d4
ligne:  move.l a4,a2
        move.w a0,d3
carre:  move.l a2,a1
        move.w d5,d2
;
octet1: move.b (a1),d0          ;compacte le carre de gauche
        cmp.b (a5),d0
        beq.s oct1
        addq.l #1,a5
        move.b d0,(a5)
        bset d1,(a6)
oct1:   dbra d1,oct2
        moveq #7,d1
        addq.l #1,a6
        clr.b (a6)
oct2:   add.w d7,a1
        dbra d2,octet1
        move.l a2,a1

        move.w d5,d2
        move.l a2,a1
octet2: move.b 1(a1),d0         ;compacte le carre de droite
        cmp.b (a5),d0
        beq.s oct3
        addq.l #1,a5
        move.b d0,(a5)
        bset d1,(a6)
oct3:   dbra d1,oct4
        moveq #7,d1
        addq.l #1,a6
        clr.b (a6)
oct4:   add.w d7,a1             ;passe a la ligne d'ecran suivante
        dbra d2,octet2

        add.w d6,a2             ;passe au carre suivant
        dbra d3,carre
        add.w adycar(a3),a4     ;passe a la ligne de carre suivante
        dbra d4,ligne
        addq.l #2,(sp)          ;passe au plan couleur suivant
        sub.w #1,nbplan(a3)
        bne.s plan
        addq.l #4,sp

; Compactage de la table de pointeurs 1
        move.l adobjet(a3),a1
        addq.l #1,a5
        move.l a5,d0
        sub.l a1,d0
        move.l d0,table2(a1)    ;adresse de la table intermediaire
        move.l (sp)+,a4         ;recupere le debut des pointeurs
        lea -1(a4),a0           ;nouveaux pointeurs: juste avant!
        move.l a0,-(sp)         ;pour plus tard
        moveq #7,d1
        clr.b (a5)
        clr.b (a0)
comp2:  move.b (a4)+,d0
        cmp.b (a5),d0
        beq.s comp2a
        addq.l #1,a5
        move.b d0,(a5)
        bset d1,(a0)
comp2a: dbra d1,comp2b
        moveq #7,d1
        addq.l #1,a0
        clr.b (a0)
comp2b: cmp.l a6,a4             ;compile toute la table des pointeurs
        bls.s comp2

; Termine le compactage
        addq.l #1,a5
        move.l a5,d0
        sub.l a1,d0
        move.l d0,point2(a1)    ;distance debut-pointeurs 2
        move.l (sp)+,a4
comp2c: move.b (a4)+,(a5)+
        cmp.l a0,a4             ;recopie la table des pointeurs
        bls.s comp2c

; Fini!
        move.l a5,d0
        sub.l a1,d0
        addq.l #1,d0            ;taille de l'image compactee en D0
        movem.l (sp)+,a4-a6
        move.l d0,-(a6)         ;ramene la longueur de la table
        clr.b d2
fini:   rts

l2fc:   moveq #13,d0
        move.l error(a5),a0
        jmp (a0)

l3:     dc.w 0



