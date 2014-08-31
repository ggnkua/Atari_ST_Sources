*******************************************************************************
*******************************************************************************
**************                  MANIAC                    *********************
*******************************************************************************
**************            (c) CCM Soft 1986               *********************
**************        Auteurs: J.L. Montagnier            *********************
**************                 E. Colonna Ceccaldi        *********************
*******************************************************************************
**************               version   4.5                *********************
*******************************************************************************
*******************************************************************************
**************       Libre circulation de la source       *********************
**************          Maniac.s et des donnees           *********************
**************  gameo,mort,chiffre,lettre,motif,          *********************
**************              present,tableau               *********************
**************    ainsi que le programme correspondant    *********************
**************                  MANIAC                    *********************
**************  >>uniquement pour les membres du club <<  *********************
**************  >>              STart                 <<  *********************
*******************************************************************************
*******************************************************************************

.comm buffer,32000                * buffer image
.comm buffpas,900                 * buffer pastille
                                  
jsr main                          *prog principal
clr -(sp)                         *sortie du prog      p135
trap #1             

sauve:     .ds.l 1                *registre de superviseur
pacx:      .ds.w 1                *cooor x du pacman
pacy:      .ds.w 1                *coord y du pacman
pacadr:    .ds.l 1                *adresse du pacman
pacbck:    .ds.l 16               *tampon du backround du pacman
niveau:    .ds.w 1                *increment de deplacement
type:      .ds.w 1                *choix entre les trois dessins du pacman
typi:      .ds.w 1                *choix entre les deux dessins du fantome
vitesse:   .ds.l 1                *vitesse
attent:    .ds.w 1                *boucle d'affichage
inv:       .ds.w 1                *inverse de la direction choisie
joue:      .ds.w 1                *direction choisie
point:     .ds.w 1                *compteur des points
hiscor:    .ds.w 1                *meilleur score
fantx:     .ds.w 4                *coordonnee x des fantomes
fanty:     .ds.w 4                *coordonnee y des fantomes
diractu:   .ds.w 4                *directions actuelles des fantomes
dirprio:   .ds.w 4                *directions prioritaires des fantomes
joueb:     .ds.w 4                *direction choisie pour
fantadr:   .ds.l 4                *adresse des fantomes
fantbck:   .ds.l 64               *background des fantomes
nombre:    .ds.w 1                *nombre de fantomes -1
tabl:      .ds.w 1                *methode d'affichage
nbpasm:    .ds.w 1                *nb pastille a manger
vie:       .ds.w 1                *nb de vies de pacman
poursuit:  .ds.w 1                *flag: =1 si les fantomes poursuivent
timer:     .ds.w 1                *temps de poursuite autorisee
timerf:    .ds.w 4                * temps ds la prison pour fantome
aimx:      .ds.w 1                *objectif x a atteindre
aimy:      .ds.w 1                *objectif y a atteindre
truc:      .ds.l 1                *contient dessin du pacman
level:     .ds.w 1                * # tableau
levelj:    .ds.w 1                * nb de tableaux franchis
table:     .ds.l 1                * adresse du tableau actuel
num:       .ds.w 1                * # du fantome mange
fini:      .ds.w 1                * type d'effacement
var:       .ds.l 1                *variable bidon
text1: .dc.b ' [C] CCM SOFT 1986 ',0
text2: .dc.b '     AUTEURS_',0
text3: .dc.b 'E^ COLONNA CECCALDI',0
text4: .dc.b '  J^L^ MONTAGNIER',0
text5: .dc.b 'VITESSE_ F1 [ RAPIDE ] A F10 [ LENT ]',0
score: .dc.b 'SCORE',0
hisco: .dc.b ' RECORD',0
tpause: .dc.b "PAUSE",0
niv:.dc.b "NIVEAU 00",0
help1: .dc.b "            MANIAC _TOUCHES UTILISEES",0
help2: .dc.b "MOUVEMENT_FLECHES DU CURSEUR OU JOYSTICK DANS LE PORT 2",0
help3: .dc.b "PAUSE    _P^REDEMARRAGE AVEC LA BARRE ESPACE ",0
help4: .dc.b "SUICIDE  _BACKSPACE  ",0
help5: .dc.b "QUITTER  _Q [SEULEMENT LORS DU GAME OVER]",0
help6: .dc.b "F1 A F10 _VITESSE",0
help7: .dc.b "            PRESSEZ LA BARRE ESPACE",0

main:
      clr hiscor
      clr.l -(sp)                 *mode superviseur
      move.w #$20,-(sp)
      trap #1
      add.l #6,sp
      move.l d0,sauve
      move.b #$12,$fffffc02       *deconnexion souris
      move.b #2,$484              * enleve le bip des touches
      jsr clear
      clr -(sp)                   *inversion video
      clr -(sp)
      move #7,-(sp)
      trap #14
      addq.l #6,sp
********************************* PRESENTATION **********
      move.b $fffffc02,d0         *pressez tab pour eviter la presentation
      cmp.b #$0f,d0
      beq abb
      move.l #buffer,a0           *recopie du titre dans le buffer:
      move.l #2599,d0
   ql3:clr.l (a0)+                *d'abord 10k de blanc
      dbf d0,ql3
      move.l #present,a1
      move.l #73,d0
 qll:  move.l #19,d1              *puis une ligne sur deux est
   ql1:move.l (a1)+,(a0)+         *le decor
      dbf d1,ql1
      move.l #19,d1
   ql2:clr.l (a0)+                *du blanc
      dbf d1,ql2
  dbf d0,qll
      move #300,d0
   ql4:clr.l (a0)+
       dbf d0,ql4
      move #283,d0                *affichage du titre en 284 fois
  ab5:move.l #buffer,a0           * \
       move #22800,d2
       move d0,d1                 *calcul de: d1=decalage par rapport au debut
       mulu #80,d1                *du buffer du dessin a afficher
       adda.w d1,a0               *d2=nb de long_mots a afficher
       sub d1,d2
       lsr d2                     * /
       move.l $44e,a2
 ab6:move.l (a0)+,(a2)+           * affichage du tableau
       dbf d2,ab6
       dbf d0,ab5
       move.l #buffer,a1          * affichage du copyright dans le buffer
       add.l #28,a1
       move.l #text1,a2
       jsr afflet
       add.l #1280,a1
       move.l #text2,a2
       jsr afflet
       add.l #640,a1
       move.l #text3,a2
       jsr afflet
       move.l #text4,a2
       jsr afflet
       clr d0
       move.l #pacmand,a1
       move.l #pacbck,a2
       move #370,pacy
       move #40,pacx
       move #370,d1
       move #40,d2
       jsr pacaff
       move.l a3,pacadr
       move.l #fantome,a1
       move.l #fantbck,a2
       move #370,fanty
       move #1,fantx
       move #370,d1
       move #1,d2
       jsr pacaff
       move.l a3,fantadr
       clr attent
       clr type
       clr typi
        move.b $fffffc02,d5
        clr d6
    ab7:move #639,d1
        move.l $44e,a0            * scroll de la partie basse de l'ecran
        add.l #25600,a0
        move.l a0,a1
        add.l #80,a1
    ab8:move.l (a1)+,(a0)+
        dbf d1,ab8
        move #19,d1
        move d0,d2
        mulu #80,d2
        move.l #buffer,a1
        adda.w d2,a1              * affichage sur la derniere ligne d'une
    ab9:move.l (a1)+,(a0)+        * ligne du buffer
        dbf d1,ab9
        inc d0
        cmp #22,d0
        bne abbu
        tst.b d6
        bne abbi
    abbu:cmp #124,d0              * est-ce la derniere ligne du buffer?
        bne aba
        clr d0
    aba:move #9000,d2
    abc:dbf d2,abc
        move.l pacadr,a1
        move.l #pacbck,a2
        jsr efface
        inc pacx
        cmp #640,pacx
        bne adf
        clr pacx
    adf:move pacy,d1
        move pacx,d2
        move.l #pacmand,a1
        adda.w type,a1
        move.l #pacbck,a2
        jsr pacaff
        move.l a3,pacadr
      inc attent                  *\
      cmpi #8,attent
      bne adg
      clr attent                  *gestion des trois motifs differents,affiche
      add #32,type                *l'un apres l'autre.Ils restent 8 fois a
      add #32,typi                *l ecran
      cmpi #96,type
      bne adgi
      clr type
 adgi:cmpi #64,typi               */
      bne adg
      clr typi
 adg: move.l fantadr,a1
      move.l #fantbck,a2
      jsr efface
      inc fantx
      cmp #640,fantx
      bne adh
      clr fantx
  adh:move fanty,d1
      move fantx,d2
      move.l #fantome,a1
      adda.w typi,a1
      move.l #fantbck,a2
      jsr pacaff
      move.l a3,fantadr
      tst.b d6
      bne ab7
      move.b $fffffc02,d1
       cmp.b d1,d5
       beq ab7
       move.b d1,d6
       jmp ab7
   abbi:move.l pacadr,a1
       move.l #pacbck,a2
       jsr efface
       move.l fantadr,a1
       move.l #fantbck,a2
       jsr efface
       clr tabl
       clr fini
       cmp.b #$62,d6
       bne abb
       jsr aide
********************************** INITIALISATION *******
abb:
     move.l #text5,a2             *vitesse
     move.l $44e,a1
     add.l #30660,a1
     jsr afflet
     clr.b $fffffc02
loop:move.b $fffffc02,d0
      cmp #$3b,d0  * F1
      blt loop
      cmp #$44,d0  * F10
      bgt loop
      sub #$3b,d0
      mulu #1000,d0
      move d0,vitesse
      move.l $44e,a0
      add.l #25600,a0
      move #1599,d0
atl:  clr.l (a0)+
      dbf d0,atl
      clr level
      move #1,levelj
      move.l #tableau,a1
      move.l a1,table
      clr point
      move #4,vie
rrrrr:jsr afftab
      move.l table,a0
      move 70(a0),nbpasm
obese:move.l table,a0
      move #10(a0),pacx           *pos pacman
      move #12(a0),pacy
      move pacx,d2                *transmet coord x,y
      move pacy,d1
      move.l #pacmana,a1          *et adresses
      move.l #pacbck,a2
      jsr pacaff
      move.l a3,pacadr
      move.l #diractu,a1          *direction actuelle des fantomes
      move 30(a0),(a1)
      move 32(a0),2(a1)
      move 34(a0),4(a1)
      move 36(a0),6(a1)
      move 38(a0),nombre          *nombre de fantomes
      dec nombre
      move.l #fantx,a1
      move 14(a0),(a1)            *pos initiales fantomes
      move 18(a0),2(a1)           *coord x
      move 22(a0),4(a1)
      move 26(a0),6(a1)
      move.l #fanty,a4            *coord y
      move 16(a0),(a4)
      move 20(a0),2(a4)
      move 24(a0),4(a4)
      move 28(a0),6(a4)
      move.l #fantx,a0
      move nombre,d6
    ad:move d6,d7                 * affichage des fantomes
       lsl d7
       move (a0,d7.w),d2          *transmet coord x,y
       move (a4,d7.w),d1
       lsl #5,d7
       move.l #fantbck,a2
       adda.w d7,a2
       move.l #fantome,a1
       jsr pacaff
       lsr #4,d7
       move.l #fantadr,a1
       move.l a3,(a1,d7.w)
       dbf d6,ad
      clr  joue
      clr type
      clr typi
      clr attent
      clr inv
      jsr affchi
      move.l #timerf,a0
      clr (a0)
      clr 2(a0)
      clr 4(a0)
      clr 6(a0)
      move #1,niveau
      move #1,poursuit
  fgt:move.b $fffffc02,d0          * pause ...
  asz:move.b $fffffc02,d1
      cmp.b d0,d1
      beq asz

*******************************************************************************
************************** MOUVEMENT DU PACMAN ********************************
*******************************************************************************
sasi: move vitesse,d1
fff:  dbf d1,fff
      clr.l d0                    *gestion du joystick
      move.l #pacmana,a6
      move.b $fffffc02,d0         *registre ACIA
      cmp.b #$19,d0
      beq pause
      cmp.b #$66,d0
      beq suivant
      cmp.b #$0e,d0
      beq gover
      cmp.b #$62,d0
      bne ggg
      jsr aide
      jmp fgt
 ggg: tst.b d0
      beq suit45                  *on est en position arret
      btst #7,d0
      bne sa4
      cmp.b #$48,d0
      bne sa1
      move.b #1,d0
      jmp sas
  sa1:cmp.b #$50,d0
      bne sa2
      move.b #2,d0
      jmp sas
  sa2:cmp.b #$4b,d0
      bne sa3
      move.b #4,d0
      jmp sas
  sa3:cmp.b #$4d,d0
      bne sas
      move.b #8,d0
      jmp sas
  sa4:move.b joue,d0
 sas: move pacy,d3
      move pacx,d4
      and #$000f,d3               * calcul de y mod 16
      and #$000f,d4               * calcul de x mod 16
      tst d3                      *\
      bne suit                    *  est-on a un croisement?
      tst d4                      *
      bne suit                    */
      move pacy,d1                * oui donc on calcule l'adresse
      lsr #4,d1                   * ou est decrite la case sur laquelle on est
      mulu #40,d1                 * add= #tableau+(y/16)*40+(x/16)-9
      move d1,d3
      move pacx,d1
      lsr #4,d1
      add d1,d3
      sub #9,d3
      move.l table,a1
      adda d3,a1
      and.b (a1),d0               * on ne garde que les directions possibles
      tst.b d0
      bne sasm
      move.b joue,d0
      and.b (a1),d0
sasm:move.l #buffpas,a1           *y a t'il une pastille?
      adda d3,a1
      move.b (a1),d1
      tst.b d1
      beq suit0
      cmp.b #1,d1
      beq sss
      add #5,point                *on a affaire a un bonus
      movem.l d0-d7/a0-a6,-(sp)
      jsr son4
      movem.l (sp)+,d0-d7/a0-a6
      clr poursuit
      move #2,niveau
      add #500,timer
      jmp sst
  sss:addi #1,point               *oui ->incrementer point
      dec nbpasm
      tst nbpasm
      beq suivant      
      addi #1,point               *oui ->incrementer point
  sst:jsr affchi                  *      afficher le score
      clr.b (a1)                  *      actualiser buffpas
      move.l #pacbck,a1           *effacer le background:
      move #15,d1
  sui:clr (a1)
      addi.l #4,a1
      dbf d1,sui
      jmp suit0
 suit:cmp.b joue,d0               *si on est pas a un croisement,seulement
      beq suit0                   *deux directions possibles:continuer son
      cmp.b inv,d0                *chemin ou partir dans l'autre sens
      beq suit0
      move.b joue,d0              *sinon imposer la direction precedente
suit0:move niveau,d3
      btst #0,d0                  *aller en haut
      beq suit1
      sub d3,pacy
      move.l #pacmanh,a6
      move.b #2,inv               * direction inverse:vers le bas
      jmp suit4
suit1:btst #1,d0                  *aller en bas
      beq suit2
      add d3,pacy
      move.l #pacmanb,a6
      move.b #1,inv
      jmp suit4
suit2:btst #2,d0                  *aller a gauche
      beq suit3
      sub d3,pacx
      move.l #pacmang,a6
      move.b #8,inv
      jmp suit4
suit3:btst #3,d0                  *aller a droite
      beq suit4
      add d3,pacx
      move.b #4,inv
      move.l #pacmand,a6
suit4:move.b d0,joue              *mise en memoire de la direction choisie
suit45:move.l a6,truc             *mise en memoire de la forme selectionnee
      tst poursuit
      bne suit5
      dec timer
      tst timer
      bne suit5
      move #1,niveau
      move #1,poursuit
*******************************************************************************
********************** MOUVEMENT DES FANTOMES *********************************
*******************************************************************************
suit5:                            *mouvements des fantomes
      move pacx,aimx
      move pacy,aimy
      cmp #1,poursuit
      beq tutu
      cmp #320,aimx               *inversion objectif par rotation
      bge papa1                   *de quadrant
      cmp #200,aimy
      bge papa2
      clr aimy
      move #640,aimx
      jmp tutu
papa2:clr aimx
      clr aimy
      jmp tutu
papa1:cmp #200,aimy
      bge papa3
      move #400,aimy
      move #640,aimx
      jmp tutu
papa3:clr aimx
      move #400,aimy
tutu: move nombre,d0
      move.l #timerf,a2
tutu4:move d0,d7
      lsl d7
      cmp #1,(a2,d7.w)
      bne tutu2
      move.l #fantx,a0            * sortie du fantome
      move.l #fanty,a1
      move.l table,a5
      move 6(a5),(a0,d7.w)        *sortie x
      move 8(a5),(a1,d7.w)        *sortie y
tutu2:dec (a2,d7.w)               *inversion de l objectif
tutu5:dbf d0,tutu4
tutu1:move.l #fantadr,a6
      move nombre,d0              *il y a 4 fantomes
bouf1:move d0,d7
      lsl #2,d7                   * x 4
      move.l (a6,d7.w),a1         *adresse fantome No d7
      lsr d7                      * / 2
      move.l #diractu,a3          *direction actuelle du fantome
      move (a3,d7.w),d1           *code:HBGD --> 0123 (No bit)
      move.l #fantx,a0            *calcul d'adresse
      move.l #fanty,a1
      move (a0,d7.w),d3           *coordonnee x   cf mvt  pavman
      move (a1,d7.w),d4           *coordonnee y
      move d3,d5
      move d4,d6
      and #$000f,d5               *case tableau: x mod 16
      and #$000f,d6               *              y mod 16
      tst d6
      bne bouf9                   *fantome pas dans intersection
      tst d5                      *->pas de test de direction
      bne bouf9
      move (a1,d7.w),d4
      lsr #4,d4                   *calcul de l adresse qui decrit  la case
      mulu #40,d4                 *du tableau ou se trouve le fantome
      move d4,d3                  *adr= #tableau+(y/16)*40+(x/16)-9
      move (a0,d7.w),d4
      lsr #4,d4
      add d4,d3
      sub #9,d3
      move.l table,a2
      adda d3,a2                  *-->adresse case du fantome
      move #$000f,d2
      and.b (a2),d2               *contient les dir possibles
      move d1,d5                  *direction actuelle du fantome
      move.l #dirprio,a4          *direction de la priorite
      move (a0,d7.w),d3           *x
      move (a1,d7.w),d4           *y
      btst #0,d0                  *si No fantome impaire --> test d alignement
      bne clp7
      cmp aimx,d3                 *si objectif est sur la meme ligne on
      bne clp15                   *le poursuit
      bgt clp16
      move #3,d5                  *nouvelle direction actuelle
      bra clp7
clp16:move #2,d5
      bra clp7
clp15:cmp aimy,d4                 *idem sur la colonne
      bne clp7                    
      bgt clp17
      move #0,d5
      bra clp7
clp17:move #1,d5
********************* calcul de la priorite du fantome ************************
clp7: cmp #1,d5
      bgt drga3                   *calcule la direction perpendiculaire
      cmp aimx,d3                 *position x par rapport a pacman
      bgt clp20
      move #3,d1                  *direction a droite
      bra clp25
clp20:move #2,d1                  *direction a gauche
      bra clp25
drga3:cmp aimy,d4                 *position y par rapport a pacman
      bgt clp21
      move #1,d1                  *direction en bas
      bra clp25
clp21:move #0,d1                  *sinon en haut
clp25:move d1,(a4,d7.w)           *nouvelle priorite du fantome
************************ calcule la direction a prendre ***********************
      move (a4,d7.w),d1
      btst d1,d2                  *dir priorite possible ?
      bne clp6
      move d5,d1
      btst d1,d2                  *dir actuelle possible ?
      bne clp6
      move (a4,d7.w),d1
      cmp #1,d1                   *inversion dir de la priorite
      bgt drga1                   *si No bit sup a 1 alors dir droite/gauche
      not d1
      and #1,d1
      bra clp10
drga1:not d1                      *sinon inverse dir haut/bas
      or #2,d1
      and #3,d1
clp10:btst d1,d2                  *dir opposee a dir priorite possible ?
      bne clp6
      move d5,d1                  *non: reste que la dir opposee a dir actuelle
      cmp #1,d1                   *inversion de la dir actuelle
      bgt drga2
      not d1
      and #1,d1
      bra clp6
drga2:not d1
      or #2,d1
      and #3,d1
clp6: move d1,(a3,d7.w)           *correction dir actuelle si changee
************************** incrementation coord fantome ***********************
bouf9:cmp #0,d1                   *suivant dir actuelle
      bne clp2
      sub #1,d4
      bra clp1
clp2: cmp #1,d1
      bne clp3
      add #1,d4
      bra clp1
clp3: cmp #2,d1
      bne clp4
      sub #1,d3
      bra clp1
clp4: add #1,d3
clp1: move d3,(a0,d7.w)           *nouvelle coord x fantome
      move d4,(a1,d7.w)           *nouvelle coord y fantome
      dbf d0,bouf1
*******************************************************************************
***************************** affiche les protagonistes ***********************
*******************************************************************************
      move nombre,d0              ***efface fantomes
rac1: move d0,d7
      move.l #fantbck,a2
      lsl #2,d7                   * x 4
      move.l (a6,d7.w),a1         *adresse fantome No d7
      lsl #4,d7                   * x 16
      adda.w d7,a2                *adresse bck du fantome No d7
      jsr efface
      dbf d0,rac1
      move.l #pacbck,a2           *efface pacman
      move.l pacadr,a1
      jsr efface
      move nombre,d0              ***sauve background fantome
rac2: move d0,d7
      clr.l d2
      move.l #fantbck,a2
      lsl #6,d7                   * x 64
      adda.w d7,a2
      lsr #5,d7
      move.l #fantx,a0
      move (a0,d7.w),d2
      move.l #fanty,a0
      move (a0,d7.w),d1
      move d2,d3
      mulu #80,d1
      lsr #4,d2                   *adr=491520+80*y+int(x/16)*2
      lsl d2
      add d1,d2
      add.l $44e,d2
      move.l d2,a3                *** sauve background pacman
      move #15,d1
aff1: move.l (a3),(a2)+
      add.l #80,a3
      dbf d1,aff1
      lsl d7
      move.l d2,(a6,d7.w)
      dbf d0,rac2
      clr.l d2                    ***affiche pacman
      move pacx,d2
      move pacy,d1
      move.l #pacbck,a2
      move.l truc,a1
      adda.w type,a1
      jsr pacaff
      move.l a3,pacadr
      move.l #fantx,a5            ***affiche tous les fantomes
      move nombre,d0
rac3: move d0,d7
      lsl d7
      move (a5,d7.w),d3
      lsl d7
      move.l (a6,d7.w),a2
      move.l #fantome,a1
      adda.w typi,a1
      and #$f,d3                  *decalage = 16 - x and 15
      sub #16,d3
      neg d3
      move #15,d2
aff2: clr.l d1
      move (a1)+,d1               *affichage du fantome
      asl.l d3,d1
      or .l d1,(a2)
      add.l #80,a2
      dbf d2,aff2
      dbf d0,rac3
      inc attent                  *\
      cmpi #8,attent
      bne suite                   *pour pacman:
      clr attent                  *gere trois motifs differents,affiches
      add #32,type                *l'un apres l'autre.restent 8 fois a l'ecran
      add #32,typi
      cmpi #96,type
      bne mite
      clr type
mite: cmpi #64,typi               *pour fantome: 2 motifs
      bne suite
      clr typi                    */
****************** collisions fantomes / pacman *******************************
suite:move nombre,d0
      clr.l d1
      move.l #fantx,a5
      move.l #fanty,a6
coco1:move d0,d7
      lsl d7
      move (a5,d7.w),d1           *x
      move (a6,d7.w),d4           *y
      cmp pacy,d4
      bne coco25
      sub pacx,d1
      cmp #0,d1
      bgt coco2
      neg d1
coco2:cmp #12,d1
      bgt coco5
      jmp coco9
coco25:cmp pacx,d1
      bne coco5
      sub pacy,d4
      cmp #0,d4
      bgt coco3
      neg d4
coco3:cmp #14,d4
      bls coco9
coco5:dbf d0,coco1
      bra sasi
coco9:cmp #1,poursuit             *collision constatee
      beq coco10
*********************** mort du fantome--> rentre chez lui *******
      movem.l d0-d7/a0-a6,-(sp)
      jsr son1
      movem.l (sp)+,d0-d7/a0-a6
      move d0,num
      move.l #fantbck,a2          *effacement du fantome mort
      move.l #fantadr,a6
      lsl d7
      move.l (a6,d7.w),a1
      lsl #4,d7
      adda.w d7,a2
      jsr efface
      cmp #0,attent
      bne frac26
      sub #32,typi
      cmp #0,typi
      bge frac26
      move #32,typi
frac26:move.l #fantx,a5           ***affiche tous les fantomes sauf le mort
      move nombre,d6
frac3: cmp d0,d6
      beq faff3
      move d6,d7
      lsl d7
      move (a5,d7.w),d3
      lsl d7
      move.l (a6,d7.w),a2
      move.l #fantome,a1
      adda.w typi,a1
      and #$f,d3                  *decalage = 16 - x and 15
      sub #16,d3
      neg d3
      move #15,d2
faff2: clr.l d1
      move (a1)+,d1               *affichage du fantome
      asl.l d3,d1
      or .l d1,(a2)
      add.l #80,a2
      dbf d2,faff2
faff3:dbf d6,frac3
      clr.l d2                    ***affiche pacman
      move.l pacadr,a2
      move pacx,d3
      move.l truc,a1
      adda.w type,a1
      and #$f,d3                  *decalage = 16 - x and 15
      sub #16,d3
      neg d3
      move #15,d2
faff4: clr.l d1
      move (a1)+,d1               *affichage du fantome
      asl.l d3,d1
      or .l d1,(a2)
      add.l #80,a2
      dbf d2,faff4
      move num,d7
      lsl #2,d7
      move.l #fantadr,a6          *on sauve le nouveau back
      move.l (a6,d7.w),a1
      move.l #fantbck,a2
      lsl #4,d7
      adda.w d7,a2
      move #15,d6
faff5: move.l (a1),(a2)+
      add.l #80,a1
      dbf d6,faff5
      move num,d7
      lsl d7
      move num,d0
      move d0,d6
      lsl #6,d6
      move.l #fantx,a5
      move.l #fanty,a6
      move (a5,d7.w),d5           *coord x du fantome pris
      move (a6,d7.w),d4           *y
      move.l #timerf,a5
      move #400,(a5,d7.w)
      move.b #7,  $ff8800         *selection canal A
      move.b #254,$ff8802
      move.b #12,$ff8800
      move.b #1, $ff8802
      move.b #13,$ff8800
      move.b #13,$ff8802
      move.b #8, $ff8800          *volume voie A
      move.b #16,$ff8802
      clr.l d3
      lsl d7
riri1:move.l #fantadr,a1
      move.l #fantbck,a2
      move.l (a1,d7.w),a1
      adda.w d6,a2
      jsr efface
      inc d4
      inc.b d3
      jsr bouge
      cmp #337,d4
      bne riri1
      move.l table,a1
      move (a1),d0
      dec d0
      lsl #3,d0
      add #305,d0
riri2:move.l #fantadr,a1
      move.l #fantbck,a2
      move.l (a1,d7.w),a1
      adda.w d6,a2
      jsr efface
      inc d5
      dec.b d3
      jsr bouge
      cmp d0,d5
      bne riri2
riri3:move.l #fantadr,a1
      move.l #fantbck,a2
      move.l (a1,d7.w),a1
      adda.w d6,a2
      jsr efface
      dec d4
      inc.b d3
      jsr bouge
      cmp #46,d4
      bne riri3
      move.l table,a5
      move 2(a5),d0
      move 4(a5),d6
riri4:move.l #fantadr,a1
      move.l #fantbck,a2
      move.l (a1,d7.w),a1
      lsl #4,d7
      adda.w d7,a2
      lsr #4,d7
      jsr efface
      dec d5
      dec.b d3
      jsr bouge
      cmp d0,d5
      bne riri4
riri5:move.l #fantadr,a1
      move.l #fantbck,a2
      move.l (a1,d7.w),a1
      lsl #4,d7
      adda.w d7,a2
      lsr #4,d7
      jsr efface
      inc d4
      inc.b d3
      jsr bouge
      cmp d6,d4
      bne riri5
      jsr tempa
      move.l #fantadr,a1
      move.l #fantbck,a2
      move.l (a1,d7.w),a1
      lsl #4,d7
      adda.w d7,a2
      jsr efface
      move num,d7
      lsl d7
      move.l #fantx,a1
      move.l #fanty,a2
      move d0,(a1,d7.w)
      move d6,(a2,d7.w)
      add #25,point
      jsr affchi
      move.l #fantbck,a2          * \
      move num,d0
      lsl #6,d0
      adda.w d0,a2
      move.l a2,a1
      move #15,d1
riri9:clr.l (a1)+                 *effacement du back du fantome mort
      dbf d1,riri9                *pour eviter les 'cadavres' de fantomes
      add.l #20,a2                *dans leur maison
      move.l #$03e003e0,(a2)+
      move.l #$06300630,(a2)+
      move.l #$06300630,(a2)+
      move.l #$03e003e0,(a2)      * /
      move.b #8,$ff8800           *volume voie A = 0
      move.b #0,$ff8802

      jmp sasi
bouge:                            *affiche fantome
      move d4,d1
      move d5,d2
      move.l #yeux,a1
      move.l #fantbck,a2
      lsl #4,d7
      adda.w d7,a2
      lsr #4,d7
      move.l d3,-(sp)
      jsr pacaff
      move.l (sp)+,d3
      move.l #fantadr,a1
      move.l a3,(a1,d7.w)

      move.b #0,$ff8800           *frequence voie A (note)
      move.b d3,$ff8802
      jsr tempa
      rts
******************** mort de pacman **************
coco10:
      movem.l d0-d7/a0-a6,-(sp)
      jsr son3
      movem.l (sp)+,d0-d7/a0-a6
      clr.l d1
      move.l #pacbck,a2           *efface pacman
      move.l pacadr,a1
      jsr efface
      cmp #0,attent
      bne coc101
      sub #32,typi
      cmp #0,typi
      beq coc101
      move #32,typi
coc101:move.l #fantx,a5           ***affiche tous les fantomes
      move.l #fantadr,a6
      move nombre,d6
coc102:move d6,d7
      lsl d7
      move (a5,d7.w),d3
      lsl d7
      move.l (a6,d7.w),a2
      move.l #fantome,a1
      adda.w typi,a1
      and #$f,d3                  *decalage = 16 - x and 15
      sub #16,d3
      neg d3
      move #15,d2
coc103: clr.l d1
      move (a1)+,d1               *affichage du fantome
      asl.l d3,d1
      or .l d1,(a2)
      add.l #80,a2
      dbf d2,coc103
      dbf d6,coc102
      move.l pacadr,a1            *sauvegarde du nouveau back
      move.l #pacbck,a2
      move #15,d0
coc104:move.l (a1),(a2)+
      add.l #80,a1
      dbf d0,coc104
      clr.l d0
      move pacx,d3
      and #$f,d3
      sub #16,d3
      neg d3
      jsr initson
      move.b #7,   $ff8800        *selection des canaux
      move.b #248, $ff8802
      move.b #0,d5
      move.b #13, $ff8800         *forme enveloppe
      move.b #13, $ff8802
coco11:move d0,d7
      lsl #5,d7
      move.l #pacmort,a1
      adda.w d7,a1
      move.l pacadr,a2
      move #15,d2
coco12:clr.l d1
      move (a1)+,d1               *affichage de pacman
      lsl.l d3,d1
      or.l  d1,(a2)
      add.l #80,a2
      dbf d2,coco12
      jsr son2
      move.l pacadr,a2
      move.l #pacbck,a1
      move #15,d2                 *efface pacman
coco13:move.l (a1)+,(a2)
      add.l #80,a2
      dbf d2,coco13
      inc d0
      cmp #15,d0
      bne coco11
      jsr termin
      move.l pacadr,a1
      move.l #pacbck,a2
      jsr efface
      jsr time2
      jsr time2
      move.l #fantadr,a6
      move nombre,d0              *efface fantomes
coco20:move d0,d7
      move.l #fantbck,a2
      lsl #2,d7                   * x 4
      move.l (a6,d7.w),a1         *adresse fantome No d7
      lsl #4,d7                   * x 16
      adda.w d7,a2                *adresse bck du fantome No d7
      jsr efface
      dbf d0,coco20
      move #10000,d7
      jsr tempf2
      move.l $44e,a0
      add.l #30392,a0
      move vie,d0
      mulu #6,d0
      adda.w d0,a0
      move #15,d0
coco21:clr (a0)
       add.l #80,a0
       dbf d0,coco21
      dec vie
      cmp #0,vie
      beq gover
      bra obese
************************ affiche game over ************************************
gover:
      jsr time2
      jsr time2
      jsr time2
      move.l $44e,a0              *effacement bas d'ecran
      add.l #30320,a0
      move #399,d0
momo: clr.l (a0)+
      dbf d0,momo
      cmp #0,fini
      bne momo8
*************** 1er methode d'effacement de l'ecran
      move.l $44e,a1
      add.l #79,a1
      move.l $44e,a0
      move #40,d2
momo2:move.l a0,a3
      move #367,d3
momo3:move #39,d4                 *\
      move.l a3,a2
momo4:move.b 1(a2),(a2)+
      dbf d4,momo4                *scroll partie gauche
      add.l #80,a3
      dbf d3,momo3                */
      move.l a1,a3                *\
      move #367,d3
momo5:move #37,d4
      move.l a3,a2                *scroll partie droite
momo6:move.b -(a2),1(a2)
      dbf d4,momo6                */
      add.l #80,a3
      dbf d3,momo5
      move.l $44e,a3              *\
      add.l #40,a3
      move #367,d3
momo7:clr (a3)                    *effacement bande centrale
      add.l #80,a3
      dbf d3,momo7                */
      dbf d2,momo2
      jmp mama
momo8:cmp #1,fini
      bne momoc
******************** 2eme methode
      move.l table,a0
      move (a0),d0
      add #39,d0
momo9:move.l $44e,a1
      move.l #29439,d1
momoa:move.b 401(a1),(a1)+
      dbf d1,momoa
      move.l $44e,a1
      add.l #80,a1
      move #367,d1
momob:clr.b (a1)
      add.l #80,a1
      dbf d1,momob
      dbf d0,momo9
      move.l $44e,a1
      clr.l (a1)
      jmp mama
momoc:cmp #2,fini
      bne momoh
******************** 3eme methode
      move #368,d0
      clr d1
momod:move.l $44e,a1
      move d1,d2
      mulu #80,d2
      adda.w d2,a1
      move #19,d2
momoe:clr.l (a1)+
      dbf d2,momoe
      add #117,d1
      cmp #367,d1
      ble momof
      sub #368,d1
momof:move #2000,d2
momog:dbf d2,momog
      dbf d0,momod
      jmp mama
******************* 4eme methode
momoh:move #39,d0
momoi:move #190,d1
      move.l $44e,a0
      move.l a0,a1
      move.l a1,a2
      move.l a2,a3
      add.l #15600,a0
      add.l #15641,a1
      add.l #16081,a2
      add.l #16120,a3
momoj:move #39,d2
momok:move.b (a0)+,400(a0)        *quart nw
      move.b (a1)+,398(a1)        *quart ne
      move.b 399(a2),(a2)+        *quart sw
      move.b 401(a3),(a3)+        *quart se
      dbf d2,momok
      sub.l #120,a0
      sub.l #120,a1
      add.l #40,a2
      add.l #40,a3
      dbf d1,momoj
      dbf d0,momoi
**************************************************************************
mama: inc fini
      cmp #4,fini
      bne mam
      clr fini
mam:  move point,d0
      cmp hiscor,d0
      bls mama9
      move point,hiscor
mama9:move.l $44e,a4
      add.l #13375,a4
      jsr chim                    *affichage des chiffres
      move.l $44e,a1
      add.l #13365,a1
      move.l #score,a2
      jsr afflet
      move.l #hisco,a2
      move.l $44e,a1
      add.l #13420,a1
      jsr afflet
      move hiscor,point
      move.l $44e,a4
      add.l #13432,a4
      jsr chim
      move.l #finpac,a2
      add.l #240,a2
      move.l a2,a3
      move #100,d7                *affichage game over
      jsr initson
      move.b #10,$ff8800
      move.b #0, $ff8802
      move.b #7,   $ff8800        *selection des canaux
      move.b #199, $ff8802
      move.b #13,$ff8800          *forme du signal
      move.b #12,$ff8802
      clr.l d0
mama1:move.l $44e,a0
      move.l a0,a1
      add.l #13968,a0
      add.l #14028,a1
      move.l a2,a4
      move.l a3,a5
      move #11,d2                 *12 lignes
mama2:move #4,d1                  *5 long-mots par lignes
mama3:move.l -(a4),-(a0)
      move.l (a5)+,(a1)+
      dbf d1,mama3
      add.l #60,a1
      sub.l #60,a0
      jsr tempf2
      jsr son5
      jsr tempf2
      dbf d2,mama2
      jsr tempf2
      jsr son5
      jsr tempf2
      sub.l #60,a1                *correction
      add.l #60,a0
      move #11,d2                 *efface en sens inverse
mama4:move #4,d1
mama5:clr.l (a0)+
      clr.l -(a1)
      dbf d1,mama5
      sub.l #60,a1
      add.l #60,a0
      jsr tempf2
      jsr son5
      jsr tempf2
      dbf d2,mama4
      jsr son5
      lsl d7
      inc d0
      cmp #4,d0
      bne mama1
      jsr son5
      move.l $44e,a0
      move.l a0,a1
      add.l #13968,a0
      add.l #14028,a1
      move #11,d2                 *12 lignes
mama6:move #4,d1                  *9 mots par lignes
mama7:move.l -(a2),-(a0)
      move.l (a3)+,(a1)+
      dbf d1,mama7
      add.l #60,a1
      sub.l #60,a0
      jsr tempf2
      jsr son5
      jsr tempf2
      dbf d2,mama6
      jsr son5
      jsr termin
      move.b $fffffc02,d0         *recommencer ?
mama8:move.b $fffffc02,d1
      cmp.b d1,d0
      beq mama8
      cmp.b #$1e,d1
      beq fin
      cmp.b #$62,d1
      bne abb
      jsr aide
      bra abb

tempf2:move d7,d6
tempf1:jsr tempf
      dbf d6,tempf1
      rts
tempf:move #10,d5
tempf3:nop
      dbf d5,tempf3
      rts
*******************************************************************************
****************************** fin du programme *******************************
fin:  move.b #$08,$fffffc02       *reactive la souris  p101
      jsr xray                    *inversions video
      jsr clear
      move $9f8,$9fa              *vide tampon clavier
      move #1,$452
      move.l sauve,-(sp)          *mode utilisateur
      move.w #$20,-(sp)
      trap #1
      add.l #6,sp
      rts
*******************************************************************************
pacaff:                           *affiche pacman transparent
      move d2,d3                  *adr=491520+80*y+int(x/16)*2
      mulu #80,d1
      lsr #4,d2
      lsl d2
      add d1,d2
      add.l $44e,d2
      move.l d2,a3                *sauve background
      move #15,d1
paff1:move.l (a3),(a2)+
      add.l #80,a3
      dbf d1,paff1
      move.l d2,a3
      and #$f,d3                  *decalage = 15- x and 15
      sub #16,d3
      neg d3
      move.l d2,a2
      move #15,d2
paff2:clr.l d1
      move (a1)+,d1               * affichage du sprite
      asl.l d3,d1
      or .l d1,(a2)
      add.l #80,a2
      dbf d2,paff2
      rts
*******************************************************************************
efface:                           * affichage du background
      move #15,d1
eff:  move.l (a2)+,(a1)
      add.l #80,a1
      dbf d1,eff
      rts
*******************************************************************************
clear:                            *efface ecran
      move.l $44e,a1              *$44e:contient adresse de la ram video
      move.l #7999,d1
cpl10:clr.l (a1)+
      dbf d1,cpl10
      rts
*******************************************************************************
affchi:                           *routine d'affichage du score
      move.l $44e,a4
chi0: add.l #844,a4               *calcul de l'adresse ou s'affiche le score
chim: clr.l d4
      move point,d4
      move #4,d3
chi1: move.l d4,d5                *on prend point mod 10
      divu #10,d5
      move d5,d4
      swap d5
      move.l #chiffre,a5          *on prend l'adresse de description du chiffre
      lsl #4,d5                   *add= #chiffre + chiffre*16
      adda.w d5,a5
      move #15,d5
      move.l a4,a3
chi2: move.b (a5)+,(a3)           *affichage du chiffre
      add.l #80,a3
      dbf d5,chi2
      subq.l #1,a4                *chiffre suivant
      dbf d3,chi1
      rts
*******************************************************************************
afftab:move.l #buffer,a3          * routine d'affichage du tableau
      move #7999,d0
tab:  clr.l (a3)+
      dbf d0,tab
      move.l $44e,a0
      add.l #30320,a0
      move #399,d0
tacb: clr.l (a0)+
      dbf d0,tacb
      add.l #72,a1
      move.l #buffer,a3
      add.l #2562,a3              *il est d'abord cree dans le buffer
      move.l table,a0
      move #39,d6
      move (a0),d5
      sub d5,d6
      adda.w d6,a3
      dec d5
      move d6,d7
      lsr d7
      adda.w d7,a1
      move d6,d7
      inc d7
      lsl d6
      add #1202,d6
      move #20,d0                 *21 lignes
  tab0:move d5,d1                 *d5 colonnes
  tab1:move.l a3,a0
       clr d2
       move.b (a1)+,d2            *a1 contient un descriptif du tableau
       move d2,d3
       and.b #$0f,d2              *si descripteur mod 16<>0 ->case vide
       tst.b d2
       bne tab3
       move.l #motif,a2           *c'est un motif
       lsl d3                     *on recupere le descriptif du motif
       adda.w d3,a2
       move #15,d3                *les motifs ont 16 lignes de hauteur
  tab2:move (a2)+,(a0)
       add.l #80,a0
       dbf d3,tab2
       jmp tab4
  tab3:add.l #400,a0
       move #$03e0,(a0)
       add.l #80,a0               *affichage pastille dans une case vide
       move #$0630,(a0)
       add.l #80,a0
       move #$0630,(a0)
       add.l #80,a0
       move #$03e0,(a0)
  tab4:addq.l #2,a3               *colonne suivante
       dbf d1,tab1
       adda.w d6,a3               *ligne suivante
       adda.w d7,a1
       dbf d0,tab0
       move.l #buffer,a4
       jsr chi0                   *affichage des chiffres
       move.l #buffer,a1
       add.l #834,a1
       move.l #score,a2
       jsr afflet
       move.l #niv,a2
       move levelj,d0
       divu #10,d0
       move d0,d1
       swap d0
       and #$00ff,d0
       add #48,d0
       and #$00ff,d1
       add #48,d1
       move.b d1,7(a2)
       move.b d0,8(a2)
       move.l #buffer,a1
       add.l #804,a1
       jsr afflet
       move.l #hisco,a2
       move.l #buffer,a1
       add.l #859,a1
       jsr afflet
       move point,d7
       move hiscor,point
       move.l #buffer,a4
       add.l #27,a4
       jsr chi0
       move d7,point
       move #224,d0               *il y a 224*4 cases
       move.l #buffpas,a0         *remplissage du tableau 'pastille'
  tab9:move.l #%00000001000000010000000100000001,(a0)+    * 1->pastille
       dbf d0,tab9
       move.l #fruit,a0           *affichage des bonus
       move.l table,a1
       move 40(a1),d0             *nb de bonus
       dec d0
  tabs:move d0,d1
       lsl #2,d1
       add #46,d1
       move (a1,d1.w),d2          *x du bonus
       move 2(a1,d1.w),d3         *y du bonus
       mulu #80,d3                *adr= buffer+y*80+x/8
       lsr #3,d2
       move.l #buffer,a2
       adda.w d3,a2               *affichage ds buffer ecran
       adda.w d2,a2
       move #15,d2
   tabt:move (a0)+,(a2)
       add.l #80,a2
       dbf d2,tabt
       move (a1,d1.w),d2          *affichage ds buffer pastille
       move 2(a1,d1.w),d3         *adr= #buffpas+x+y*80-9
       lsr #4,d2
       lsr #4,d3
       mulu #40,d3
       move.l #buffpas,a2
       adda.w d3,a2
       adda.w d2,a2
       suba.w #9,a2
       move.b #2,(a2)
       dbf d0,tabs
       cmp #0,tabl
       bne tab7
******************* 1ere methode d'affichage **********
       move #91,d0                *affichage du tableau en 100 fois
tab5:  move.l #buffer,a0          *\
       move #29440,d2
       move d0,d1                 *calcul de: d1=decalage par rapport au debut
       mulu #320,d1               *du buffer du dessin a afficher
       adda.w d1,a0               *d2=nb de long_mots a afficher
       sub d1,d2
       lsr #2,d2                  */
       move.l $44e,a2
tab6:  move.l (a0)+,(a2)+         * affichage du tableau
       dbf d2,tab6
       dbf d0,tab5
       jmp remp
***************** 2eme methode d'affichage *********
 tab7: cmp #1,tabl
       bne taba
       move.l #buffer,d1
       sub.l $44e,d1              *d1 contient le decalage buffer-ecran
       move.l $44e,a1
       move.l a1,a2
       add.l #159,a2
       move #80,d0
  tab8:move.l a1,a3
       move.l a2,a4
       move.l #199,d2
  tabb:move.b (a3,d1.l),(a3)      *affichage des 2 colonnes a g et a d
       move.b (a4,d1.l),(a4)
       add.l #160,a3
       add.l #160,a4
       dbf d2,tabb
       move #12000,d2
  tabc:dbf d2,tabc
       add.l #1,a1                *colonne 1 de + a d
       sub.l #1,a2                *colonne 1 de - a g
       dbf d0,tab8
       jmp remp
*************************** 3eme methode **********
  taba: cmp #2,tabl
        bne tabf
        move.l #buffer,d1
        sub.l $44e,d1
        move #39,d0
  tabd: move.l $44e,a2            * calcul d'adresse du debut de la ligne
        move d0,d2                * du haut
        mulu #800,d2
        adda.w d2,a2
        sub #31200,d2
        neg d2                    * du bas
        move.l $44e,a1
        adda.w d2,a1
        move #199,d3
   tabg:move.l (a2,d1.l),(a2)+    * affichage de ces lignes
        move.l (a1,d1.l),(a1)+
        dbf d3,tabg
        move.l $44e,a1
        suba.w d0,a1
        add.l #39,a1              * colonne de g
        move.l $44e,a2
        add.l #40,a2
        adda.w d0,a2
        move #399,d3              * colonne de d
   tabh:move.b (a1,d1.l),(a1)     * affichage de ces colonnes
        move.b (a2,d1.l),(a2)
        add.l #80,a1
        add.l #80,a2
        dbf d3,tabh
        move #13000,d3
    tabi:dbf d3,tabi
        dbf d0,tabd
        jmp remp
************************ 4eme methode d'affichage *********
  tabf: cmp #3,tabl
        bne tabj
        move.l #buffer,d1
        sub.l $44e,d1
        move.l #32000,d0
        move.l $44e,a1
        move.l a1,a2
        add.l #31999,a2
    tabk:move.b (a1,d1.l),(a1)
         add.l #117,a1
         cmpa.l a2,a1
         ble tabm
         sub.l #32000,a1
     tabm:move #25,d3
     tabn:dbf d3,tabn
          dbf d0,tabk
          jmp remp
****************** 5eme methode d affichage ***************
  tabj:move #15,d0
  tabo:move.l #buffer,d1
       sub.l $44e,d1
       move.l $44e,a3
       move #19,d4
       move d0,d5
       lsl d5
       move.l #$ffffffff,d3
       lsl.l d5,d3
       not.l d3
tabp:  move #399,d6
       move.l a3,a1
tabq:
       move.l (a1,d1.l),d2
       lsl.l d5,d2
       and.l d3,(a1)
       or.l d2,(a1)
       add.l #80,a1
       dbf d6,tabq
       addq.l #4,a3
       dbf d4,tabp
       dbf d0,tabo
****************** remplissage du tableau pastille ****************************
  remp:
         move vie,d0
         sub #2,d0
 remp1:clr.l d2
         move #380,d1
         clr pacx
         move #380,pacy
         move.l #pacmand,a1
         move.l #pacbck,a2
         jsr pacaff
        move.l a3,pacadr
        move d0,d4
        mulu #48,d4
        add #32,d4
   remp2:
        move.l pacadr,a1
        move.l #pacbck,a2
        jsr efface
        inc pacx
        move pacy,d1
        move pacx,d2
        move.l #pacmand,a1
        adda.w type,a1
        move.l #pacbck,a2
        jsr pacaff
        move.l a3,pacadr
        move #1000,d1
    remm:dbf d1,remm
        inc attent                *\
        cmpi #41,attent
        bne remp3
        clr attent                *gestion des trois motifs differents,affiches
        add #32,type              *l'un apres l'autre.Ils restent 8 fois
        cmpi #96,type             *a l'ecran
        bne remp3
        clr type
remp3:dbf d4,remp2
        dbf d0,remp1
       add #1,tabl
       cmp #5,tabl
       bne tabgi
       clr tabl
  tabgi:rts
*******************************************************************************
afflet: move.l a1,a3              *affichage de texte situe en a2 a l'adresse
    let:clr d0                    *a1
        move.b (a2)+,d0
        tst.b d0
        beq let5
        cmp.b #32,d0
        beq let4
        cmp.b #57,d0
        ble let2
        move.l #lettre,a4         *le caractere a afficher est une lettre
        subi.b #65,d0
        jmp let3
   let2:move.l #chiffre,a4        *le caractere a afficher est un chiffre
        subi.b #48,d0
   let3:lsl #4,d0
        adda.w d0,a4
        move #15,d0
        move.l a3,a5
   let1:move.b (a4)+,(a5)
        add.l #80,a5
        dbf d0,let1
   let4:add.l #1,a3
        jmp let
   let5:add.l #1280,a1
        rts
*******************************************************************************
suivant:inc level
        inc levelj
        inc vie
        cmp #12,level
        bne suuui
        clr level
   suuui:move.l #tableau,a0
         move level,d0
         mulu #912,d0             *chaque tableau occupe 912 octets
         adda.w d0,a0
         move.l a0,table
        move.l table,a1
         sub #500,vitesse
         cmp #0,vitesse
         bge rrrrr
         clr vitesse
        jmp rrrrr
*******************************************************************************
aide:  move.l $44e,a0
       move.l #buffer,a1
       move #7999,d0
  aide1:move.l (a0),(a1)+
        clr.l (a0)+
        dbf d0,aide1
       move.l #help1,a2
       move.l $44e,a1
       add.l #10012,a1
       jsr afflet
       add.l #1280,a1
       move.l #help2,a2
       jsr afflet
       move.l #help3,a2
       jsr afflet
       move.l #help4,a2
       jsr afflet
       move.l #help5,a2
       jsr afflet
       move.l #help6,a2
       jsr afflet
       add.l #640,a1
       move.l #help7,a2
       jsr afflet
  aide2:move.b $fffffc02,d1
        cmp.b #$39,d1
        bne aide2
        move.l $44e,a0
        move.l #buffer,a1
        move.l #7999,d0
  aide3:move.l (a1)+,(a0)+
        dbf d0,aide3
        rts
*******************************************************************************
pause: move.l #buffer,a1
       move.l $44e,a2
       add.l #30470,a2
       move #15,d1
  sev: move.l (a2)+,(a1)+
       move.l (a2),(a1)+
       add.l #76,a2
       dbf d1,sev
       move.l #tpause,a2
       move.l $44e,a1
       add.l #30470,a1
       jsr afflet
    ser:move.b $fffffc02,d1
        cmp.b #$39,d1
        bne ser
        move.l $44e,a1
        add.l #30470,a1
        move.l #buffer,a2
        move #15,d1
    set:move.l (a2)+,(a1)+
        move.l (a2)+,(a1)
        add.l #76,a1
        dbf d1,set
        jmp sasi
********************************************************************
xray: move #15,d3
gogo: clr -(sp)
      clr -(sp)
      move #7,-(sp)               *inversion video
      trap #14
      addq.l #6,sp
      jsr time2
      move #$777,-(sp)            *inversion video
      clr -(sp)
      move #7,-(sp)
      trap #14
      addq.l #6,sp
      jsr time2
      dbf d3,gogo
      rts
***********************
tempa:
      move.l d3,-(sp)
      move #500,d3
temp2:nop
      dbf d3,temp2
      move.l (sp)+,d3
      rts
************************
time1:
      move.l d5,var
      move.l #1000,d5
time10:nop
      dbf d5,time10
      move.l var,d5
      rts
************************
time2:
      move.l d5,var
      move.l #10000,d5
time20:nop
      dbf d5,time20
      move.l var,d5
      rts
************************
time3:
      move.l d5,var
      move.l #5000,d5
time30:nop
      dbf d5,time30
      move.l var,d5
      rts
******************************************************************
son1:                             *pacman mange fantome
      jsr initson
      move.b #7,   $ff8800        *selection des canaux
      move.b #248, $ff8802
      move.b #13, $ff8800         *forme enveloppe
      move.b #13, $ff8802
      move.l #2,d4
jojo1:move.l #100,d3
      move.b #255,d1
jojo2:move.b #0,  $ff8800         *freqence signal sur A
      move.b d1,  $ff8802
      move.b #2,  $ff8800         *                sur B
      move.b d1,  $ff8802
      move.b #4,  $ff8800         *                sur C
      move.b d1,  $ff8802
      jsr time1
      dec d1
      add.b #150,d6
      dbf d3,jojo2
      move.l #100,d3
jojo3:move.b #0,  $ff8800         *freqence signal sur A
      move.b d1,  $ff8802
      move.b #2,  $ff8800         *                sur B
      move.b d1,  $ff8802
      move.b #4,  $ff8800         *                sur C
      move.b d1,  $ff8802
      jsr time1
      inc d1
      sub.b #150,d6
      dbf d3,jojo3
      dbf d4,jojo1
      jsr termin
      rts
********************************************************************
son2:                             *mort de pacman
      move.b #8, $ff8800          *volume canal A
      move.b #16,$ff8802
      move.b #9, $ff8800          *volume canal B
      move.b #13,$ff8802
      move.b #10,$ff8800          *volume canal C
      move.b #10,$ff8802
      move.l #27,d6
jojo5:move.b #0,  $ff8800         *freqence signal sur A
      move.b d5,  $ff8802
      move.b #2,  $ff8800         *                sur B
      move.b d5,  $ff8802
      move.b #4,  $ff8800         *                sur C
      move.b d5,  $ff8802
      jsr time1
      inc.b d5
      dbf d6,jojo5
      move.b #8, $ff8800          *
      move.b #9, $ff8802          * \
      move.b #9, $ff8800          *  \
      move.b #9, $ff8802          *   volumes = 0
      move.b #10,$ff8800          *  /
      move.b #9, $ff8802          * /
      move #3,d6
jojo6:jsr time2
      dbf d6,jojo6
      sub.b #12,d5
      rts
***********************************************************************
sound1:.dc.b 200,200,100,150,0,200,200,100,150,0
       .dc.b 175,175,175,175,175,175,175,175

son3:                             *fantome prend pacman
      jsr initson
      move.b #7,   $ff8800        *selection des canaux
      move.b #252, $ff8802
      move.b #13,$ff8800
      move.b #13,$ff8802
      move.l #sound1,a0
      move #17,d4
jojo7:move.b (a0)+,d5
      cmp.b #0,d5
      beq jojo8
      move.b #8, $ff8800          *volume canal A
      move.b #16,$ff8802
      move.b #9, $ff8800          *volume canal B
      move.b #13,$ff8802
      move.b #0,  $ff8800         *freqence signal sur A
      move.b d5,  $ff8802
      move.b #2,  $ff8800         *                sur B
      move.b d5,  $ff8802
      jsr time2
      jsr time2
      move.b #8, $ff8800          *
      move.b #4, $ff8802          * \
      move.b #9, $ff8800          *  \
      move.b #0, $ff8802          *   volumes = baisse
jojo8: move #3,d2
jojo9:jsr time2
      dbf d2,jojo9
      sub.b #10,d1
      dbf d4,jojo7
      jsr termin
      rts
************************************************************************
son4:                             *pacman mange fruit
      jsr initson
      move.b #7,   $ff8800        *selection des canaux
      move.b #248, $ff8802
      move.b #13,$ff8800
      move.b #12,$ff8802
      move.l #255,d3
jojo10:move.b #0,  $ff8800        *freqence signal sur A
      move.b #250,  $ff8802
      move.b #2,  $ff8800         *                sur B
      move.b #250,  $ff8802
      move.b #4,  $ff8800         *                sur C
      move.b #250,  $ff8802
      jsr time1
      dbf d3,jojo10
      jsr termin
      rts
*************************************************************************
son5:                             *game over
      btst #0,d2                  *test de parite
      beq jojo11
      move.b #8, $ff8800          *volume canal A
      move.b #16,$ff8802
      move.b #9, $ff8800          *volume canal B
      move.b #13,$ff8802
      move.b #0,  $ff8800         *freqence signal sur A
      move.b #200,  $ff8802
      move.b #2,  $ff8800         *                sur B
      move.b #200,  $ff8802
jojo11:jsr time3
      move.b #8, $ff8800          *
      move.b #0, $ff8802          * \
      move.b #9, $ff8800          *  \
      move.b #0, $ff8802          *   volumes = baisse
      rts
*****************************************************************
initson:
      move.b #8,   $ff8800        *volume canal A
      move.b #16,  $ff8802
      move.b #9,   $ff8800        *volume canal B
      move.b #16,  $ff8802
      move.b #10,  $ff8800        *volume canal C
      move.b #16,  $ff8802
      move.b #12,  $ff8800        *genere enveloppe (longueur periode)
      move.b #1,   $ff8802
      rts
************************************************************************
termin:    
      move.b #8,   $ff8800        *volumes a 0
      move.b #0,   $ff8802
      move.b #9,   $ff8800
      move.b #0,   $ff8802
      move.b #10,  $ff8800
      move.b #0,   $ff8802
      move.b #7,   $ff8800        *deselection des canaux
      move.b #192, $ff8802
      rts

*******************************************************************************
**************             (c) CCM Soft 1986              *********************
*******************************************************************************
.end


