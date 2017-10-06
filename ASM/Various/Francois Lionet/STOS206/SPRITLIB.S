  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;                       LIBRAIRIE GENERATEUR DE SPRITES
;
;                        (c) Francois Lionet INC. 1987
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

          bra debut

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          dc.b "Sprite 101"
even
;-----------------------------> copie des vecteurs d'interruption
ancient1: dc.l 0
ancient2: dc.l 0
;-----------------------------> fonctions de la trappe
trappe:   dc.l initmode       ;0
          dc.l chgbank        ;1
          dc.l chglimit       ;2
          dc.l synconoff      ;3
          dc.l prionoff       ;4
          dc.l boum           ;5
          dc.l posprite       ;6
          dc.l sponoff        ;7
          dc.l spxonoff       ;8
          dc.l sprnxya        ;9
          dc.l movonoff       ;10
          dc.l mvxonoff       ;11
          dc.l depinit        ;12
          dc.l anonoff        ;13
          dc.l anxonoff       ;14
          dc.l animinit       ;15
          dc.l actualise      ;16
          dc.l show           ;17
          dc.l hide           ;18
          dc.l chgmouse       ;19
          dc.l mouse          ;20
          dc.l mousekey       ;21
          dc.l ectodec        ;22
          dc.l dectoec        ;23
          dc.l drawmouse      ;24
          dc.l setzone        ;25
          dc.l zone           ;26
          dc.l chgscreen      ;27
          dc.l stopmouse      ;28
          dc.l spreaff        ;29
          dc.l departint      ;30
          dc.l arretint       ;31
          dc.l limouse        ;32
          dc.l scrcopy        ;33
          dc.l icone          ;34
          dc.l putspr         ;35
          dc.l razones        ;36
          dc.l getspr         ;37
          dc.l reduce         ;38
          dc.l razflash       ;39
          dc.l flashinit      ;40
          dc.l mousbete       ;41
          dc.l zoom           ;42
          dc.l appear         ;43
          dc.l chgcmous       ;44
          dc.l mouvon         ;45
          dc.l shifton        ;46
          dc.l redraw         ;47
          dc.l interson       ;48
          dc.l inter          ;49
          dc.l cls            ;50
          dc.l getbloc        ;51
          dc.l putbloc        ;52
          dc.l fade           ;53

; adaptation 520/1040
advect:   dc.l 0
admouse:  dc.l 0
;------animeur/deplaceur------
nbanimes: =   15              ;quinze sprites geres par interruption
intersync:dc.w 0              ;chaine avec les interruptions?
animflg:  dc.w 0              ;flag: routine d'interruption en route?
tablact:  blk.b nbanimes*8,0  ;table d'actualisation
actimage: =   2
actx:     =   4
acty:     =   6
tablanim: blk.b nbanimes*12,0 ;table d'animation
animad:   =   2               ;adresse table animation
animpos:  =   6               ;position dans cette table
animax:   =   8               ;position maximale
anibcle:  =   10              ;boucle si arrive a la fin?
tablemvt: blk.w nbanimes*2*22,0
mvtind:   =   2               ;indice de vitesse
mvtdir:   =   4               ;direction du mouvement
mvtnbre:  =   6               ;nombre de mouvements dans cette direction
mvtad:    =   8               ;adresse de la table de mouvements
mvtpos:   =   12              ;position dans cette table
mvtmax:   =   14              ;maximum de la table
mvtcond:  =   16              ;condition?
mvtbcle:  =   18              ;boucle si condition?
mvtpdeb:  =   20              ;position de sprite au debut
doitact:  dc.w 0              ;doit actualiser, par defaut!
doitactad:dc.l 0              ;adresse du doit actualiser/ctrl-c
mouvxy:   dc.w 0              ;flag: mvt en X ou en Y
;---------souris--------------
intmouse: dc.w 0              ;flag: peut-on gerer la souris?
showon:   dc.w 0              ;compteur hide/show
xmouse:   dc.w 0
ymouse:   dc.w 0
dxmouse:  dc.w 0
dymouse:  dc.w 0
mxmouse:  dc.w 0              ;maxi en X souris
mymouse:  dc.w 0
buttons:  dc.w 0
form:     dc.w 0
oldform:  dc.w 0
;---------flasheur------------
nbflash:  dc.w 0
flcpt:    equ 2
flpos:    equ 4
flind:    equ 6
flcolor:  equ 22
lflash:   equ 54
tflash:   blk.b lflash*16,0
;---------shifter-------------
shiftcpt: dc.w 0
shiftind: dc.w 0      
shiftad:  dc.l 0
shiftnb:  dc.w 0
;---------fadeur -------------
fadeflg:  dc.w 0
fadevit:  dc.w 0
fadecpt:  dc.w 0
;---------sprites-------------
nbsprite: =   17             ;souris/15 sprites normaux/icones
ecran:    =   $44e           ;pointe sur v_bas_ad
backg:    dc.l 0
dessins1: dc.l 0             ;adresse des dessins
dessins2: dc.l picture       ;adresse des dessins de la souris
goodbank: dc.w 0
mode:     dc.w 0
nbplan:   dc.w 0
motligne: dc.w 0
sync:     dc.w 0
prioron:  dc.w 0
maxlimg:  dc.w 0
maxlimd:  dc.w 0
maxlimh:  dc.w 0
maxlimb:  dc.w 0
limg:     dc.w 0
limd:     dc.w 0
limh:     dc.w 0
limb:     dc.w 0

plusmasq: dc.w 0
plusoct:  dc.w 0
plusbuf:  dc.w 0
xbuf:     dc.w 0
fxbuf:    dc.w 0
ybuf:     dc.w 0
fybuf:    dc.w 0
txbuf:    dc.w 0
tybuf:    dc.w 0
numspr:   dc.w 0
sortie:   dc.w 0
tpxmot:   dc.w 0
tpdecx:   dc.w 0
tpy:      dc.w 0
tptx:     dc.w 0
tpty:     dc.w 0
tptxr:    dc.w 0
adsprite: dc.l 0
iconflg:  dc.w 0
;-------- zoom ---------
zparams:  blk.w 14,0
zdor:     equ 0
zddest:   equ 2
zty:      equ 4
zzymin:   equ 6
zzymax:   equ 8
zzycpt:   equ 10
zpligne:  equ 12
;-------- cls ----------
plans:    dc.l 0,0
;-------- appear: table des parametres qui ne plantent pas! ----------
tappear:  dc.w 22223,11,89,101,121,131,159,69
          dc.w 13,77,103,119,133,161,43,53                  ;16
          dc.w 67,107,127,137,163,119,41,47
          dc.w 117,129,139,3001,16001,1777,3889,30013       ;32
          dc.w 12003,281,12587,31111,20007,2001,3557,20009
          dc.w 20001,3559,12569,99,3269,30001,16001,33      ;48
          dc.w 97,32001,9999,777,7777,9997,17777,22777
          dc.w 26777,29057,3023,30099,27777,30057,447,657   ;64
          dc.w 30097,30091,30059,327,31857,1487,1489,1491
          dc.w 2,4,6,14,18,22,122,118                       ;72->80 : pairs!
;---------------------------------------------tables
;;;;;;;;;;       TABLE DES SPRITES
xinput:   =   2
yinput:   =   4
dxhot:    =   6
dyhot:    =   8
y:        =   10
xmot:     =   12
decx:     =   14
tx:       =   16
ty:       =   18
txr:      =   20
pointeur: =   22
image:    =   24

sprites:  blk.b nbsprite*28,0

;;;;;;;;;;       TABLE DES CROISEMENTS
dx:       =   nbsprite*2
fx:       =   nbsprite*2*2
dy:       =   nbsprite*2*3
fy:       =   nbsprite*2*4
dx1:      =   nbsprite*2*5
fx1:      =   nbsprite*2*6
dy1:      =   nbsprite*2*7
fy1:      =   nbsprite*2*8

croise:   blk.w nbsprite*9,0

;;;;;;;;;;       TABLE DES PRIORITES
priorite: blk.w nbsprite,0
multiple: blk.w nbsprite,0

;---------------------------->fausse table de dessins
picture:  dc.l 0,0,0
          dc.w 0,0,0
          
          dc.b "SpBuff"       ;Reconnaissance pour modifier le buffer
;;;;;;;;;;       BUFFER DES SPRITES
sizebuf:  dc.w 2500           ;Taille du buffer de dessin
buffer:   dc.l 0
;;;;;;;;;;       TABLE DES ZONES: 64 ZONES!!!
tzones:   dc.l 0
;;;;;;;;;;       BUFFER DE L'ANIMEUR
buffanim: dc.l 0              ;16 images par sprite
;;;;;;;;;;       BUFFER DU DEPLACEUR
buffmvt:  dc.l 0              ;16 deplacements par sprite
;---------------------------->chargement de la souris
dta:      blk.b 48,0
nomouse:  dc.b "mouse.spr",0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                             Reducteur a YOUYOU
x_max:    dc.w      320,640,640         ;   X max+1  for each resolution
y_max:    dc.w      200,200,400         ;   Y max+1  for each resolution
sp0:      dc.w      0
sp2:      dc.w      0
sp4:      dc.w      0
sp6:      dc.w      0
sp8:      dc.l      0
b_pline:  dc.w      $A0,$A0,$50         ; bytes per line
col_len:  dc.w      4,2,1               ; number of bits to encode 1 color
b_pb:     dc.w      8,4,2               ; v_plane*2
tab_x:    blk.w     640,0               ; maximum contenance of table
params:   blk.w     5,0
;                                Sacre YOUYOU!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
; Lors de l'appel, A3 contient l'adresse des adresses!
debut:  movem.l d1-d7/a1-a6,-(sp)  
        move.l (a3),admouse           ;adresse coords souris
        move.l 20(a3),advect          ;adresse vecteur souris
; Banque souris par defaut
        cmp.l #$19861987,(a2)+
        bne Debout
        move.l a2,dessins2            ;met la banque!
; Fait de la PLACE pour les BUFFERS
        move.l a0,a6
        move.l a0,tzones              ;zones de test
        add.l #128*4*2,a0
        move.l a0,buffer              ;buffer des sprites
        move.w d0,sizebuf             ;Taille en MOTS du buffer
        lsl.w #1,d0                   ;---> en octets
        add.l d0,a0
        move.l a0,buffanim            ;buffer animeur
        add.l #nbanimes*64,a0
        move.l a0,buffmvt             ;buffer deplaceur
        add.l #nbanimes*96*2,a0
        cmp.l a1,a0
        bcc.s Debout
        move.l a0,d6
        sub.l a6,d6
        subq #1,d6
debut2: clr.b (a6)+                   ;nettoie les buffers!
        dbra d6,debut2
; initialise la trappe
        move.l a0,-(sp)
        bsr initrap
        move.l (sp)+,a0               ;ramene l'adresse de fin
        moveq #0,d0
DOut:   movem.l (sp)+,d1-d7/a1-a6
        rts
; Out of mem!
Debout: moveq #1,d0
        bra.s DOut

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        Calcule l'AD ECRAN: d1=x, d2=y, retour: a2=AD, d3=nb mots/ligne      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
adecran:  move motligne(pc),d3
          sub #40,d1
          sub #400,d2
          mulu d3,d2
          add d1,d2
          mulu nbplan(pc),d2
          asl #1,d2
          swap d2
          clr d2
          swap d2
          add d2,a2
          rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         COLLIDE: test des collisions entre sprites
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
collide:  moveq #nbsprite-2,d4           ;ne teste pas l'icone ici!
          lea sprites(pc),a0
          lea croise(pc),a1
          clr d7
          addq #1,d5
autrec:   subq #1,d5
          beq pascol
          tst (a0)
          bne.s teste
pascol:   clr (a1)
suivantc: add #28,a0
          add #2,a1
          dbra d4,autrec
          rts

;------------------compare dx a dx'
teste:    move d0,d6
          sub xmot(a0),d6
          bcc.s lcomp1
          clr dx1(a1)
          bra.s compfx
lcomp1:   cmp txr(a0),d6
          bge.s pascol
          move d6,dx1(a1)

;------------------compare fx a fx'
compfx:   move xmot(a0),d6
          add txr(a0),d6
          sub d1,d6
          bcc.s lcomp5
          move txr(a0),fx1(a1)
          bra.s compdy
lcomp5:   cmp txr(a0),d6
          bge.s pascol
          neg d6
          add txr(a0),d6
          move d6,fx1(a1)

;------------------compare dy a dy'
compdy:   move d2,d6
          sub y(a0),d6
          bcc.s lcomp10
          clr dy1(a1)
          bra.s compfy
lcomp10:  cmp ty(a0),d6
          bge.s pascol
          move d6,dy1(a1)

;------------------compare fy a fy'
compfy:   move y(a0),d6
          add ty(a0),d6
          sub d3,d6
          bcc.s lcomp15
          move ty(a0),fy1(a1)
          bra.s calculs
lcomp15:  cmp ty(a0),d6
          bge.s pascol
          neg d6
          add ty(a0),d6
          move d6,fy1(a1)

;------------------calcule le masque de la zone testee: dx fx dy fy
calculs:  move xmot(a0),d6
          add dx1(a1),d6
          sub d0,d6
          move d6,dx(a1)
          sub dx1(a1),d6
          add fx1(a1),d6
          move d6,fx(a1)

          move y(a0),d6
          add dy1(a1),d6
          sub d2,d6
          move d6,dy(a1)
          sub dy1(a1),d6
          add fy1(a1),d6
          move d6,fy(a1)

          move #1,(a1)
          addq #1,d7
          bra suivantc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         ADSPR : POINTE LE SPRITE D1 DANS LA TABLE, D1 ---> D5
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
adspr:    clr intmouse
adspr1:   and #$f,d1
          move d1,d5
          mulu #28,d1
          lea sprites(pc),a0
          add d1,a0
          rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         BOUM: ramene d0 les collisions du sprite d1, d2=TX, d3=TY
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; entree BOUM
boum:     move.w d1,-(sp)
	  bsr adspr           ;calcule l'adresse du sprite en a0, d1 ---> d5
          move.w (sp)+,d1
	  clr.l d0
          tst (a0)            ;le sprite n'est pas en route
          beq finboum
; calcule le carre a tester
          move.w xinput(a0),d4
          move.w d4,d5
          sub.w d2,d4         ;DX
          bcc boum1
          clr d4
boum1:    add.w d2,d5         ;FX
          move.w yinput(a0),d6
          move.w d6,d7
          sub.w d3,d6         ;DY
          bcc boum2
          clr d6
boum2:    add.w d3,d7         ;FY
; teste tous les sprites
          clr d2              ;compteur de # sprite
          lea sprites(pc),a0
boum5:    cmp d1,d2	      ;ne teste pas le sprite en question
          beq.s boum6
          tst (a0)
          bne.s boum10
boum6:    add #28,a0
          addq #1,d2
          cmp.w #nbsprite-1,d2
          bne boum5
finboum:  move #1,intmouse
          rts
; sprite en route
boum10:   cmp.w xinput(a0),d4
          bhi.s boum6
          cmp.w xinput(a0),d5
          bcs.s boum6
          cmp.w yinput(a0),d6
          bhi.s boum6
          cmp.w yinput(a0),d7
          bcs.s boum6
; BOUME!
          bset d2,d0
          bra boum6

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         POSPRITE: ramene en d0/d1 les coordonnees du sprite d1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
posprite: bsr adspr
          clr.l d0
          clr.l d1
          tst (a0)
          beq finpos
          move xinput(a0),d0
          sub #640,d0
          move pointeur(a0),d1
          swap d1                       ;en d1.l pointeur du sprite
          move yinput(a0),d1
          sub #400,d1
finpos:   move #1,intmouse
          rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;            Putsprite: dessine les sprites dans le buffer dessin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
putsprite:tst sortie
          bne retourput
          move xbuf(pc),d0
          move fxbuf(pc),d1
          move ybuf(pc),d2
          move fybuf(pc),d3
          moveq #nbsprite+2,d5          ;teste TOUS les sprites
          bsr collide
          tst d7
          beq retourput

          lea priorite(pc),a2           ;table des priorite:
bcletest: move (a2)+,d0
putbis:   lsl #1,d0
          lea croise(pc),a1
          add d0,a1
          mulu #14,d0
          lea sprites(pc),a0
          add d0,a0

          tst (a1)
          bne.s dessine
nxtsprite:tst d7
          bne.s bcletest
retourput:rts

dessine:  subq #1,d7
          movem.l d7/a0-a2,-(sp)
          move nbplan(pc),d7    ;d7 nombre de plans
          move.l image(a0),a2
          move.l a2,a3
          move.l buffer(pc),a4
          move tx(a0),d0        ;taille du sprite dans la memoire!
          mulu ty(a0),d0
          asl #1,d0             ;travail par MOTS (+++rapide)
          add d0,a3
          move tx(a0),d0
          mulu dy1(a1),d0
          add dx1(a1),d0
          asl #1,d0
          add d0,a2             ;a2 adresse du masque
          mulu d7,d0
          add d0,a3             ;a3 adresse des octets
          move txbuf(pc),d0
          mulu dy(a1),d0
          add dx(a1),d0
          asl #1,d0
          mulu d7,d0
          add d0,a4          ;a4 adresse dans le buffer

          move fx(a1),d0
          sub dx(a1),d0
          subq #2,d0
          move d0,a5         ;a5 compteur en X -1
          addq #2,d0
          move fy(a1),d1
          sub dy(a1),d1
          subq #1,d1
          move d1,d3          ;d3: compteur en Y
          move decx(a0),d5    ;d5 decalages
          move #16,d6
          sub d5,d6           ;d6 16-decalages

          move txbuf(pc),d1
          sub d0,d1
          asl #1,d1
          mulu d7,d1
          move d1,plusbuf     ;addtion au buffer

          bclr #31,d7
          tst d5              ;calcul addtion masque/dessin
          beq.s paschgt       ;les modifications de la taille reelle du sprite
          move fx1(a1),d1     ;ne doivent pas etre prises en compte si
          cmp txr(a0),d1      ;il n'est pas recouvert jusqu'a la fin...
          bne.s paschgt
          subq #1,d0          ;si le sp est decale et est recouvert: tx-1
          bset #31,d7         ;positionne le flag DROITE en d7

paschgt:  move tx(a0),d1
          sub d0,d1
          asl #1,d1           ;travaille par mots
          move d1,plusmasq
          mulu d7,d1
          move d1,plusoct

          bclr #30,d7         ;bit 30 a un si quelquechose a chercher a gauche
          tst dx1(a1)
          beq.s pasgche
          bset #30,d7

pasgche:  bsr drawsp
          movem.l (sp)+,d7/a0-a2
          bra nxtsprite

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         SOUS PROGRAMME de dessin dans buffer/ecran
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;          
drawsp:   move mode(pc),d0
          subq #1,d0
          bmi sprbasse
          beq sprmoyen
;-------------------------------sprites HAUTE RESOLUTION

sprhaute: move.w plusmasq(pc),a0
          move.w plusoct(pc),a1
          move.w plusbuf(pc),d1
          tst d5
          beq htessdec

;----> boucle hires AVEC DECALAGE
          
htnxtl:   move a5,d7
          btst #30,d7
          bne.s htgche
          moveq #-1,d4
          moveq #0,d0
          bra.s httdrt
htgche:   move.w -2(a2),d4
          ror.l d5,d4
          move.w -2(a3),d0
          ror.l d5,d0

httdrt:   tst d7
          bmi.s htdrt
htbcle:   lsr.l d6,d4
          lsr.l d6,d0
          move.w (a2)+,d4
          move.w (a3)+,d0
          ror.l d5,d4
          ror.l d5,d0
          and.w d4,(a4)
          or.w d0,(a4)+
          dbra d7,htbcle

htdrt:    lsr.l d6,d4
          lsr.l d6,d0
          btst #31,d7
          beq.s htpasd
          move.w #$ffff,d4
          clr.w d0
          bra.s htrotate
htpasd:   move.w (a2)+,d4
          move.w (a3)+,d0
htrotate: ror.l d5,d4
          ror.l d5,d0
          and.w d4,(a4)
          or.w d0,(a4)+

          add.w a0,a2
          add.w a1,a3
          add.w d1,a4
          dbra d3,htnxtl

          rts

;---->boucle hires SANS DECALAGE

htessdec: addq #1,a5
htsd1:    move a5,d7          ;d7 compteur en X
htsd2:    move.w (a2)+,d4
          and.w d4,(a4)
          move.w (a3)+,d0
          or.w d0,(a4)+
          dbra d7,htsd2
          add.w a0,a2
          add.w a1,a3
          add.w d1,a4
          dbra d3,htsd1
          rts

;------------------------------>sprites MOYENNE RESOLUTION

sprmoyen: move.w plusmasq(pc),a0
          move.w plusoct(pc),a1
          move.w plusbuf(pc),d2
          tst d5
          beq myssdec

;----> boucle moyenne resolution AVEC DECALAGE

mynxtl:   move a5,d7
          btst #30,d7
          bne.s mygche
          moveq #-1,d4
          moveq #0,d0
          moveq #0,d1
          bra.s mytdrt
mygche:   move.w -2(a2),d4
          ror.l d5,d4
          move.w -4(a3),d0
          move.w -2(a3),d1
          ror.l d5,d0
          ror.l d5,d1

mytdrt:   tst d7
          bmi.s mydrt
mybcle:   lsr.l d6,d4
          lsr.l d6,d0
          lsr.l d6,d1
          move.w (a2)+,d4
          move.w (a3)+,d0
          move.w (a3)+,d1
          ror.l d5,d4
          ror.l d5,d0
          ror.l d5,d1
          and.w d4,(a4)
          or.w d0,(a4)+
          and.w d4,(a4)
          or.w d1,(a4)+
          dbra d7,mybcle

mydrt:    lsr.l d6,d4
          lsr.l d6,d0
          lsr.l d6,d1
          btst #31,d7
          beq.s mypasd
          move.w #$ffff,d4
          clr.w d0
          clr.w d1
          bra.s myrotate
mypasd:   move.w (a2)+,d4
          move.w (a3)+,d0
          move.w (a3)+,d1
myrotate: ror.l d5,d4
          ror.l d5,d0
          ror.l d5,d1
          and.w d4,(a4)
          or.w d0,(a4)+
          and.w d4,(a4)
          or.w d1,(a4)+

          add.w a0,a2
          add.w a1,a3
          add.w d2,a4
          dbra d3,mynxtl
          rts

;---->boucle moyenne resolution SANS DECALAGE

myssdec:  addq #1,a5
mysd1:    move a5,d7
mysd2:    move.w (a2)+,d4
          move.w (a3)+,d0
          move.w (a3)+,d1
          and.w d4,(a4)
          or.w d0,(a4)+
          and.w d4,(a4)
          or.w d1,(a4)+
          dbra d7,mysd2
          add.w a0,a2
          add.w a1,a3
          add.w d2,a4
          dbra d3,mysd1
          rts

;--------------------------------->sprites BASSE RESOLUTION

sprbasse: tst d5
          beq bsssdec

;---->boucle basse resolution AVEC DECALAGE

          move d3,a1
bsnxtl:   move a5,d7
          btst #30,d7
          bne.s bsgche
          moveq #-1,d4
          moveq #0,d0
          moveq #0,d1
          moveq #0,d2
          moveq #0,d3
          bra.s bstdrt
bsgche:   move.w -2(a2),d4
          ror.l d5,d4
          subq.l #8,a3
          move.w (a3)+,d0
          move.w (a3)+,d1
          move.w (a3)+,d2
          move.w (a3)+,d3
          ror.l d5,d0
          ror.l d5,d1
          ror.l d5,d2
          ror.l d5,d3

bstdrt:   tst d7
          bmi.s bsdrt
bsbcle:   lsr.l d6,d4
          lsr.l d6,d0
          lsr.l d6,d1
          lsr.l d6,d2
          lsr.l d6,d3
          move.w (a2)+,d4
          move.w (a3)+,d0
          move.w (a3)+,d1
          move.w (a3)+,d2
          move.w (a3)+,d3
          ror.l d5,d4
          ror.l d5,d0
          ror.l d5,d1
          ror.l d5,d2
          ror.l d5,d3
          and.w d4,(a4)
          or.w d0,(a4)+
          and.w d4,(a4)
          or.w d1,(a4)+
          and.w d4,(a4)
          or.w d2,(a4)+
          and.w d4,(a4)
          or.w d3,(a4)+
          dbra d7,bsbcle

bsdrt:    lsr.l d6,d4
          lsr.l d6,d0
          lsr.l d6,d1
          lsr.l d6,d2
          lsr.l d6,d3
          btst #31,d7
          beq.s bspasd
          move #$ffff,d4
          clr.w d0
          clr.w d1
          clr.w d2
          clr.w d3
          bra.s bsrotate
bspasd:   move.w (a2)+,d4
          move.w (a3)+,d0
          move.w (a3)+,d1
          move.w (a3)+,d2
          move.w (a3)+,d3
bsrotate: ror.l d5,d4
          ror.l d5,d0
          ror.l d5,d1
          ror.l d5,d2
          ror.l d5,d3
          and.w d4,(a4)
          or.w d0,(a4)+
          and.w d4,(a4)
          or.w d1,(a4)+
          and.w d4,(a4)
          or.w d2,(a4)+
          and.w d4,(a4)
          or.w d3,(a4)+

          add plusmasq(pc),a2
          add plusoct(pc),a3
          add plusbuf(pc),a4
          subq.w #1,a1
          cmp #$ffff,a1
          bne bsnxtl
          rts

;---->boucle basse resolution SANS DECALAGE

bsssdec:  move.w plusmasq(pc),a0
          move.w plusoct(pc),a1
          move.w plusbuf(pc),d6
          move d3,d5
          addq #1,a5
bssd1:    move a5,d7
bssd2:    move.w (a2)+,d4
          move.w (a3)+,d0
          move.w (a3)+,d1
          move.w (a3)+,d2
          move.w (a3)+,d3
          and.w d4,(a4)
          or.w d0,(a4)+
          and.w d4,(a4)
          or.w d1,(a4)+
          and.w d4,(a4)
          or.w d2,(a4)+
          and.w d4,(a4)
          or.w d3,(a4)+
          dbra d7,bssd2
          add.w a0,a2
          add.w a1,a3
          add.w d6,a4
          dbra d5,bssd1
          rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                     Balance le buffer dans l'ecran                         ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
balance:  move.l ecran,a2
          tst sortie
          bne.s retourbal
balbis:   move.l buffer(pc),a1       ;a1=adresse du buffer
          move txbuf(pc),d6
          mulu nbplan(pc),d6      ;d6=nombre de mots en X
          move tybuf(pc),d7       ;d7=taille en Y
          subq #1,d7
          move xbuf(pc),d1
          move ybuf(pc),d2
          bsr adecran         ;A2=adresse dans l'ecran ou le decor (icone)
          mulu nbplan(pc),d3
          sub d6,d3
          asl #1,d3           ;d5=addition … a0 pour ligne suivante
          subq #1,d6          ;DBRA s'arrete a - 1!

lbal1:    move d6,d0
lbal2:    move.w (a1)+,(a2)+
          dbra d0,lbal2
          add d3,a2
          dbra d7,lbal1
retourbal:rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                  Recupere le decor de la copie d'ecran                     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getdecor: tst sortie
          bne.s retourdec
          move xbuf(pc),d1
          move ybuf(pc),d2
          move.l backg(pc),a2
          bsr adecran         ;a2 adresse dans le decor
          move nbplan(pc),d7
          move txbuf(pc),d2
          sub d2,d3
          mulu d7,d3
          asl #1,d3           ;d3 addition au decor
          mulu d7,d2
          subq #1,d2          ;d2 compteur en X
          move tybuf(pc),d1
          subq #1,d1          ;d1 compteur en Y
          move.l buffer(pc),a3  ;a3 adresse dans le buffer

bback1:   move d2,d0
bback2:   move (a2)+,(a3)+
          dbra d0,bback2
          add d3,a2
          dbra d1,bback1

retourdec:rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;            Masque du buffer en fonction des limites du terrain              ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; teste limite gauche
limites:  cmp limg(pc),d4         ;d2=Xbuf, d3=Ybuf, d4=FXbuf, d5=FYbuf
          ble out
          cmp limg(pc),d2
          bge.s tstdrt
          move limg(pc),d2
; teste limite droite
tstdrt:   cmp limd(pc),d2
          bge.s out
          cmp limd(pc),d4
          ble.s tstht
          move limd,d4
; teste limite haute
tstht:    cmp limh(pc),d5
          ble.s out
          cmp limh(pc),d3
          bge.s tstbs
          move limh(pc),d3
; teste limite basse
tstbs:    cmp limb(pc),d3
          bge.s out
          cmp limb(pc),d5
          ble.s finlim
          move limb(pc),d5

finlim:   move d2,xbuf    ;retour: d6=TXbuf, d7=TYbuf
          move d3,ybuf
          move d4,fxbuf
          move d5,fybuf
          move d4,d6
          move d5,d7
          sub d2,d6
          move d6,txbuf
          sub d3,d7
          move d7,tybuf
          clr sortie
          rts

out:      move #1,sortie
          rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         ENTREE GENSPRITE: d0=numspr, d1=X, d2=Y, d3=pointeur                ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
genicone: movem.l d1-d7/a0-a6,-(sp)
          and #$f000,d0
          move.b #16,d0
          bra.s gs1
gensprite:movem.l d1-d7/a0-a6,-(sp)     ;entree normale
          and #$ff0f,d0
          tst.b d0                      ;pas le sprite zero!
          beq generr
          clr intmouse
          clr iconflg
          bra.s gs1
geninter: movem.l d1-d7/a0-a6,-(sp)     ;entree sous interruption
          clr iconflg
          clr.b d0

gs1:      clr d4
          move.b d0,d4
          move d4,numspr
          mulu #28,d4
          lea sprites(pc),a0
          add d4,a0
          move.l a0,adsprite

          tst d0
          bpl marche

;------------------------> arret du sprite si bit 15 de D0 a un
          tst (a0)
          beq genout          ;deja arrete
          clr (a0)            ;arret du sprite dans la table

eteint:   tst prioron         ;faut-il calculer les priorites?
          beq.s etint
          bsr priocalc
etint:    move xmot(a0),d2
          move y(a0),d3
          move d2,d4
          move d3,d5
          add txr(a0),d4
          add ty(a0),d5
          bsr limites         ;calcul de l'AD buffer
          bsr getdecor        ;met le decor dans le buffer
          tst iconflg         ;si un icone: revient tout de suite!
          bne outicon
          bsr putsprite       ;dessine les sprites dans le buffer
          bsr synchro         ;synchronisation avec le balayage
          bsr balance         ;efface a l'ecran
          bra genout

;------------------------> sprite en marche: changement des coordonnees?
marche:   tst.w d1              ;changement de X?
          bne.s egen2
          tst.w xinput(a0)
          beq generr          ;erreur: X n'etait pas defini
          move.w xinput(a0),d1

egen2:    tst.w d2            ;changement de Y?
          bne.s egen6
          tst.w yinput(a0)
          beq generr          ;erreur: Y n'etat pas defini!
          move.w yinput(a0),d2

egen6:    tst d3              ;changement du pointeur?
          bne.s egen8
          tst pointeur(a0)
          beq generr          ;erreur, le dessin n'etait pas defini!
egen7:    move tx(a0),d4      ;recupere les donnees du dessin
          move ty(a0),d5
          bra.s egen10

egen8:    tst.b d0
          bne.s egen9
          cmp #4,d3
          bcc.s egen8a
          move.l dessins2(pc),a2
          bra.s egen9a
egen8a:   sub #3,d3            ;ramene au debut de la banque normale
egen9:    move.l dessins1(pc),a2   ;adresse des dessins
          tst goodbank
          beq generr
egen9a:   move mode(pc),d4
          lsl #2,d4
          move.l 0(a2,d4.w),d0 ;dessins dans cette resolution
          beq generr           ;pas de sprite dans cette resolution
          move.l d0,a1
          add.l a2,a1          ;adresse des sprites du mode en a1
          lsr #1,d4
          cmp 12(a2,d4.w),d3
          bhi generr           ;erreur: le dessin n'existe pas!
          move d3,pointeur(a0)  ;sauve le pointeur du sprite
          lsl #3,d3
          lea -8(a1,d3.w),a2
          add.l (a2)+,a1
          move.l a1,image(a0)   ;sauve l'adresse absolue du dessin
          clr d4
          clr d5
          move.b (a2)+,d4       ;TX en d4
          move.b (a2)+,d5       ;TY en d5
          clr d7
          move.b (a2)+,d7       ;HOT-SPOT: poke les nouveaux decalages
          move.w d7,dxhot(a0)
          move.b (a2)+,d7
          move.w d7,dyhot(a0)

egen10:   move.w d1,xinput(a0)  ;stocke x reel: on y touche plus
          move.w yinput(a0),d7
          move.w d2,yinput(a0)  ;stocke y reel: "  "   "     "

;--------------------------> etabli la compatibilite entre les modes
          sub.w dxhot(a0),d1
          sub.w dyhot(a0),d2
          move d4,d3          ;taille du sprite en X
          bsr coords
          beq.s egen12
          addq #1,d3          ;d3 taille reelle du sprite

;--------------------------> le sprite sort-il des limites permises?
egen12:   tst d0
          beq generr
          cmp #120,d0
          bge generr
          cmp d5,d2
          blt generr
          cmp #1200,d2
          bge generr

; met tout dans la table

          move xmot(a0),tpxmot      ;sauve les donnees du sprite
          move decx(a0),tpdecx      ;d'avant
          move y(a0),tpy
          move tx(a0),tptx
          move txr(a0),tptxr
          move ty(a0),tpty
          move d0,xmot(a0)              ;poke les nouvelles
          move d1,decx(a0)
          move d2,y(a0)
          move d3,txr(a0)
          move d4,tx(a0)
          move d5,ty(a0)

;-------------------------> le sprite est-il arrete en ce moment?
          tst (a0)
          bne.s egen13
          move #1,(a0)        ;OUI: le met en route
          bra eteint          ;utilise la meme routine que eteint!

;-------------------------> mouvement en Y=>recalcul des priorites

egen13:   cmp yinput(a0),d7
          beq.s egen14
          tst prioron
          beq.s egen14
          movem.w d4-d5,-(sp)
          bsr priocalc
          movem.w (sp)+,d4-d5

;-------------> mouvement du sprite: trouve le meilleur mode d'affichage.

egen14:   
;          cmp tptx,d4         ;regarde s'il peut afficher le sprite en UNE
;          bne absolu          ;fois: c'est vachement mieux!
;          cmp tpty,d5
;          bne absolu          ;si changement de taille, alors NON!

;---> calcul du mouvement RELATIF

; trouve xbuf-> d2 : le plus a gauche
          move tpxmot(pc),d2
          cmp xmot(a0),d2
          blt.s egen20
          move xmot(a0),d2

; trouve fxbuf-> d4 : le plus a droite
egen20:   move xmot(a0),d0
          add txr(a0),d0
          move tpxmot(pc),d1
          add tptxr(pc),d1
          cmp d0,d1
          bge.s egen22
          move d0,d4
          bra.s egen25
egen22:   move d1,d4

; trouve ybuf->  d3 : le plus haut
egen25:   move tpy(pc),d3
          cmp y(a0),d3
          blt.s egen30
          move y(a0),d3

; trouve fybuf-> d5 : le plus haut
egen30:   move y(a0),d0
          add ty(a0),d0
          move tpy(pc),d1
          add tpty(pc),d1
          cmp d0,d1
          bge.s egen32
          move d0,d5
          bra.s egen35
egen32:   move d1,d5

egen35:   bsr limites

; le buffer est-il assez grand?
          mulu d6,d7
          mulu nbplan(pc),d7
          cmp.w sizebuf(pc),d7
          bgt.s absolu           ;c'est trop grand, dommage!
          move txr(a0),d6
          mulu ty(a0),d6
          mulu nbplan(pc),d6
          mulu #3,d6
          cmp d7,d6              ;absolu aussi si: TXR;TY;NBPLAN;3<taille prise
          bls.s absolu           ;pour un traitement par buffer...

; affiche  le sprite
          bsr getdecor
          bsr putsprite
          bsr synchro
          bsr balance
          bra genout

;----------------------------->affichage du sprite en ABSOLU!

absolu:   move xmot(a0),d2    ;affiche le nouveau sprite.
          move y(a0),d3
          move d2,d4
          move d3,d5
          add txr(a0),d4
          add ty(a0),d5
          bsr limites
          bsr getdecor
          bsr putsprite
          bsr synchro
          bsr balance

          move tpxmot(pc),d2  ;efface l'ancien
          move tpy(pc),d3
          move d2,d4
          move d3,d5
          add tptxr(pc),d4
          add tpty(pc),d5
          bsr limites
          bsr getdecor
          bsr putsprite
          bsr balance

generr:   moveq #1,d0
          bra.s genout1
genout:   clr d0
genout1:  move #1,intmouse
genout2:  movem.l (sp)+,d1-d7/a0-a6
          rts
outicon:  clr iconflg       ;par precaution!
          clr d0
          bra.s genout2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         PUTSPRITE: pokage du sprite d1 dans le decor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
putspr:   bsr posprite
          tst (a0)
          bne.s putspr1
          move #1,intmouse
          rts
putspr1:  move d1,d2          ;Y
          swap d1
          move d1,d3          ;pointeur
          move d0,d1          ;X
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         ICON: pokage d'un "sprite" dans le decor: d1-x/d2-y/d3-pointeur
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
icone:    add #640,d1
          add #400,d2
icone0:   clr intmouse
          move #1,iconflg
          clr.w d0
          bsr genicone        ;va faire tous les calculs!!!
          tst d0              ;erreur!
          bne icon10
          tst sortie
          bne icon9
          movem.l d1-d7/a0-a6,-(sp)
          move.l adsprite,a0  ;pointe directement le sprite 17!
          lea croise(pc),a1
          move xbuf(pc),d0
          move fxbuf(pc),d1
          move ybuf(pc),d2
          move fybuf(pc),d3
          clr d4
          clr d7
          bsr teste           ;une seule collision---> premiere table!
          move.l adsprite,a0
          lea croise(pc),a1
          bsr dessine         ;va dessiner ce seul sprite!
          move.l backg(pc),a2     ;balance dans le decor
          bsr balbis
          bsr balance         ;balance dans l'ecran
          movem.l (sp)+,d1-d7/a0-a6
icon9:    clr d0              ;pas d'erreur
icon8:    clr iconflg
          move.l adsprite(pc),a0
          clr (a0)            ;efface l'icone
          move #1,intmouse
          rts
icon10:   moveq #1,d0
          bra icon8

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         GET SPRITE: recupere un bout du decor--->sprite (d4=couleur mask)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getspr:   clr intmouse
          move #1,iconflg
          clr d0              ;MET EN ROUTE l'icone!
          add #640,d1
          add #400,d2
          bsr genicone
          move.l adsprite,a0
          clr.w (a0)          ;avant tout, arrete l'icone!
          tst d0
          bne icon10
          tst sortie          ;si sorti: ne prend rien!
          bne icon9
          move.l image(a0),a1 ;a1: adresse du masque
          move.l a1,a2
          move tx(a0),d0
          mulu ty(a0),d0
          lsl #1,d0           ;fois deux 
          add d0,a2           ;a2: adresse du dessin
          move.l a2,a3        ;a3 aussi pour le masque!!
          move txr(a0),d1
          cmp txbuf(pc),d1        ;sortie!
          bne icon9
          move ty(a0),d2
          cmp tybuf(pc),d2        ;sortie aussi!
          bne icon9
          move d4,-(sp)       ;pousse la couleur transparente
          move.l buffer(pc),a4       ;a4=buffer
          move decx(a0),d3
          bne.s getspr2
; pas de decalage: SIMPLE: recopie tout betement
          mulu d1,d2
          mulu nbplan(pc),d2
          subq #1,d2
getspr1:  move.w (a4)+,(a3)+
          dbra d2,getspr1
          bra getspr10
; decalage
getspr2:  moveq #16,d4
          sub d3,d4           ;d4= 16-decalages
          move nbplan(pc),d5
          subq #1,d5          ;d5= nbplans ind
          subq #2,d1          ;ind en x
          subq #1,d2          ;ind en y
getspr3:  move d1,d6          ;nouvelle ligne d6= cpt X
          move d5,d7          ;d7= cpt en plans
          lea croise(pc),a6       ;buffer de stockage des plans couleur
getspr4:  clr.l d0            ;prepare le premier octet
          move.w (a4)+,d0
          ror.l d4,d0
          move.l d0,(a6)+
          dbra d7,getspr4
getspr5:  move d5,d7
          lea croise(pc),a6       ;buffer des plans ---> zero
getspr6:  move.l (a6),d0
          lsr.l d3,d0         ;prepare
          move.w (a4)+,d0
          ror.l d4,d0
          move.w d0,(a3)+     ;poke dans le dessin!
          move.l d0,(a6)+     ;remet pour le suivant!
          dbra d7,getspr6     ;autre plan!
          dbra d6,getspr5     ;autre X
          dbra d2,getspr3     ;autre Y
; fabrique le masque: que c'est chiant!!!
getspr10: move tx(a0),a4
          subq #1,a4          ;ind en X
          move ty(a0),d7
          subq #1,d7          ;cpt en Y
          move nbplan(pc),a5      ;nbplans en a5
          move.w (sp)+,d3     ;Couleur transparente
          bpl.s getspr10c

; masque entierement transparent (si couleur<0)
getspr10a:move a4,d0
getspr10b:move #$ffff,(a1)+
          dbra d0,getspr10b
          dbra d7,getspr10a
          bra getspr17

getspr10c:cmp #2,mode
          beq getspr20
; masque calcule en MIDRES et LOWRES!
getspr11: move a4,d6          ;nouvelle ligne
getspr12: moveq #15,d5        ;nouveau mot
          clr d1
          move.l a2,a3
getspr13: move.l a3,a2
          clr d4
          clr d2
getspr14: move.w (a2)+,d0
          btst d5,d0
          beq.s getspr15
          bset d4,d2
getspr15: addq #1,d4          ;autre plan?
          cmp d4,a5
          bne.s getspr14
          cmp.b d2,d3
          bne.s getspr16
          bset d5,d1
getspr16: dbra d5,getspr13    ;autre pixel?
          move.w d1,(a1)+     ;poke le masque ainsi calcule
          dbra d6,getspr12    ;autre mot?
          dbra d7,getspr11    ;autre ligne?
          bra getspr17

; masque calcule: HIRES
getspr20: and #7,d3
          beq getspr11        ;si masque=0: normal  
          move.l a1,a3
getspr20a:move a4,d0          ;masque entierement transparent
getspr20b:move #$ffff,(a3)+
          dbra d0,getspr20b
          dbra d7,getspr20a
          move d3,d7
          move ty(a0),a6
          move tx(a0),d0
          lsl #1,d0
          move d0,a5          ;taille d'une ligne en octets
          lsl #3,d0
          move d0,a0          ;nombre de pixels/ligne           
          moveq #0,d6
getspr21: moveq #0,d5
getspr22: bsr pointe
          btst d4,(a4)
          beq getspr30
          movem d5-d6,-(sp)
          move d5,d2
          move d6,d3
          add d7,d3
          addq #1,d3
          cmp a6,d3
          bls getspr23
          move a6,d3
getspr23: add d7,d2
          addq #1,d2
          cmp a0,d2
          bls getspr24                    
          move a0,d2
getspr24: sub d7,d6
          bcc getspr25
          moveq #0,d6
getspr25: sub d7,d5
          bcc getspr26
          moveq #0,d5
getspr26: move d5,d1
getspr27: bsr pointe
          bclr d4,(a3)
          addq #1,d5
          cmp d2,d5
          bcs getspr27
          move d1,d5
          addq #1,d6
          cmp d3,d6
          bcs getspr27
          movem (sp)+,d5-d6
getspr30: addq #1,d5
          cmp a0,d5
          bne getspr22
          addq #1,d6
          cmp a6,d6
          bne getspr21

; finininini: pas d'erreur
getspr17: bsr spreaff         ;va TOUT reafficher!
          clr d0
          rts

; sspgm: pointe 
pointe:   move a5,d0
          mulu d6,d0
          move d5,d4
          lsr #3,d4
          add d4,d0
          move.l a1,a3        ;pointe dans le masque
          add d0,a3
          move.l a2,a4        ;pointe dans le sprite
          add d0,a4
          move d5,d4
          and #7,d4
          eor #7,d4
          rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         Synchronisation avec le balayage s'il faut
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
synchro:  tst sync
          beq.s finsync
          tst numspr
          bne.s sync1
          tst showon
          bpl.s finsync
sync1:    move.w #37,-(sp)    ;appel de WVBL (BIOS)
          trap #14
          addq.l #2,sp
finsync:  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         Calcul des priorites                                                ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
priocalc: lea sprites(pc),a5
          lea priorite(pc),a2
          lea multiple(pc),a4
          clr d2
          moveq #nbsprite-2,d6      ;compteur RAZ a la fin!

prior1:   move d2,d3
          move #$7fff,d2
          move.l a5,a1
          clr d1
          moveq #nbsprite-2,d4      ;pas le 17 eme!
prior2:   tst (a1)
          beq.s prior4
          cmp yinput(a1),d3
          bge.s prior4
          cmp yinput(a1),d2
          beq.s prior3
          blt.s prior4
          move.l a4,a3
          clr d5
          move yinput(a1),d2
prior3:   move d1,(a3)+
          addq #1,d5
prior4:   add #28,a1
          addq #1,d1
          dbra d4,prior2

          btst #14,d2        ;si =#$7fff: plus de sprite
          bne.s prior6

          subq #1,d5         ;remplit la table dans l'ordre inverse
prior5:   move -(a3),(a2)+
          subq #1,d6
          dbra d5,prior5
          bra.s prior1

prior6:   tst.w d6
          bmi.s finprior
          moveq #-1,d1
prior7:   move.w d1,(a2)+
          dbra d6,prior7

finprior: rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         Transforme les coordonnees                                          ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
coords:   move d1,d0
          lsr #4,d0          ;d0 Xmot 40--> 80 ou 60 si basse resolution
          and #15,d1         ;d1 decX
          rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         Synchronisation avec le balayage ON/OFF                             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
synconoff:move d1,sync
          clr.l d0
          rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         Priorite on/off                                                     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
prionoff: move d1,prioron
          bne priocalc        ;actualise la table
; re-initialisation de la table
          lea priorite(pc),a0
          moveq #nbsprite-1,d0
pinit:    move d0,(a0)+
          dbra d0,pinit
          moveq #0,d0
          rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         Changement des limites du terrain                                   ;
;         d1/d2/d3/d4= limG/limD/limH/limB                                    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
chglimit: clr intmouse
          bsr dectoec         ;efface tous les sprites, VITE!
          bsr chglim          ;va changer les limites
          bsr spreaff         ;va tout reafficher
          clr.l d0
          rts
; entree pour initmode
chglim:   add #640,d1         ;coords negatives----> coords positives!
          add #640,d2
          add #400,d3
          add #400,d4
          tst d1              ;si d1<zero: limites par defaut
          bmi limax
          cmp d1,d2
          bls.s chgl2           ;limite a droite<limite a gauche!
          bsr coords          ;limite a gauche
          cmp maxlimd(pc),d0
          bcc.s chgl1
          cmp maxlimg(pc),d0
          bcs.s chgl1
          move d0,limg
chgl1:    move d2,d1          ;limite a droite
          bsr coords
          cmp maxlimg(pc),d0
          bcs.s chgl2
          cmp maxlimd(pc),d0
          bcc.s chgl2
          move d0,limd

chgl2:    cmp d3,d4
          bls.s chgl4           ;limite en bas < limite en haut!
          cmp maxlimb(pc),d3      ;limite en haut
          bcc.s chgl3
          cmp maxlimh(pc),d3
          bcs.s chgl3
          move d3,limh
chgl3:    cmp maxlimh(pc),d4      ;limite en bas
          bcs.s chgl4
          cmp maxlimb(pc),d4
          bcc.s chgl4
          move d4,limb
chgl4:    clr.l d0
          rts
limax:    move maxlimg(pc),limg   ;limites par defaut
          move maxlimd(pc),limd
          move maxlimh(pc),limh
          move maxlimb(pc),limb
          bra chgl4

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         CHGSCREEN changement des adresse ecran logique/decor                ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
chgscreen:cmp.l #0,a0
          bne.s chgs1
          move.l backg(pc),a0
          rts
chgs1:    move.l a0,backg
          rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         INITMODE initialisation a la resolution                             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
initmode: clr intmouse        ;interdiction des interruptions
          clr animflg
          move.w #4,-(sp)     ;getrez
          trap #14
          addq.l #2,sp
          move d0,mode
          beq.s ibasse
          cmp #1,d0
          beq.s imoyen
          move #1,nbplan
          move #40,motligne
          bra.s isuite
imoyen:   move #2,nbplan
          move #40,motligne
          bra.s isuite
ibasse:   move #4,nbplan
          move #20,motligne
; initialisation des limites
isuite:   move #40,maxlimg
          move #400,maxlimh
          move motligne,d0
          add #40,d0
          move d0,maxlimd
          move #600,d0
          cmp #2,mode
          bne.s ilim1
          add #200,d0
ilim1:    move d0,maxlimb
          bsr limax
;pas synchro balayage
          clr sync
;initialisation deplaceur/animeur/actualisateur
          bsr initactiv
;initialisation du flasheur
          bsr razflash
;initialisation du shifter
          bsr initshift
;initialisation du fadeur
          clr.w fadeflg 
;initialisation zoneur
          bsr razones
;initialisation de la table des sprites
          lea sprites(pc),a0
          moveq #nbsprite-1,d0
binit1:   move #27,d1
binit2:   clr.b (a0)+
          dbra d1,binit2
          dbra d0,binit1
;pas de calcul de priorite
          clr d1
          bsr prionoff
;copie de l'ecran
          bsr ectodec
;initialisation et autorisation de la souris
          clr d3
          bsr limouse         ;limites de la souris
          move #1,d1
          bsr chgmouse        ;dessin de la souris
;autorisation de l'animeur
          move #1,animflg
;adresse du doit-actualiser
          move.l doitactad,a0
          clr (a0)            ;raz des flags
;interruptions chainees
          move.w #1,intersync
          moveq #0,d0
          rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         Sprite off: arret de tous les sprites sauf la souris
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sproff:   move #$8001,d4
sproff1:  move d4,d0
          bsr gensprite
          addq #1,d4
          cmp.b #16,d4
          bne.s sproff1
          rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         Recopie de l'ecran dans le decor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ectodec:  move.l ecran,a0
          move.l backg(pc),a1
ec0:      move #8007,d0       ;recopie la palette!
ec1:      move.l (a0)+,(a1)+
          dbra d0,ec1
          moveq #0,d0
          rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         Recopie du decor dans l'ecran
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dectoec:  move.l backg(pc),a0
          move.l ecran,a1
          bra ec0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         Recopies d'ecran a ecran a0/a1-d1/d2/d3/d4-d5/d6
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
scrcopy:  tst d5
          bne scc2

; RECOPIE TOTALE, ULTRA RAPIDE!
          move #500,d0       ;recopie la palette!
scc1:     move.l (a0)+,(a1)+
          move.l (a0)+,(a1)+
          move.l (a0)+,(a1)+
          move.l (a0)+,(a1)+
          move.l (a0)+,(a1)+
          move.l (a0)+,(a1)+
          move.l (a0)+,(a1)+
          move.l (a0)+,(a1)+

          move.l (a0)+,(a1)+
          move.l (a0)+,(a1)+
          move.l (a0)+,(a1)+
          move.l (a0)+,(a1)+
          move.l (a0)+,(a1)+
          move.l (a0)+,(a1)+
          move.l (a0)+,(a1)+
          move.l (a0)+,(a1)+
          dbra d0,scc1
          bra scc20

; RECOPIE PARTIELLE
scc2:     add #640,d1         ;desole je peux pas faire autrement!
          add #400,d2
          add #640,d3
          add #400,d4
          lsr #4,d1           ;/ 16
          lsr #4,d3
          lsr #4,d5
          beq scc20           ;rien a recopier!
          tst d6
          beq scc20           ;non plus!
          movem d3-d4,-(sp)
          tst d7
          bne scc10

; RECOPIE MOT PAR MOT, SANS DECALAGE
; calcul de l'adresse de depart
          move.l a0,a2        ;va calculer
          bsr adecran         ;l'adresse de depart
          move.l a2,a3        ;en a3
; calcul de l'adresse d'arrivee
          movem (sp)+,d1-d2
          move.l a1,a2
          bsr adecran         ;adresse d'arrivee en a2
          move nbplan(pc),d2
          mulu d2,d3          ;D3= nb mots/ligne
          move.w d3,d7
          move.w d5,d4
          mulu d2,d4          ;D4= nb mots recopies / ligne
          sub.w d4,d7
          lsl.w #1,d7         ;D7---> passage ligne a l'autre
          cmp.l a3,a2
          bcc sccd
; Screen copy vers le haut ---> Haut vers bas / gauche vers droite   
          subq #1,d5          ;compteurs en DBRA
          subq #1,d6
          move.w mode(pc),d0
          subq.w #1,d0
          bmi sccub1
          beq sccum1
; boucle de recopie sans decalage/ HIRES
sccuh1:   move.w d5,d0
sccuh2:   move.w (a3)+,(a2)+
          dbra d0,sccuh2
          add.l d7,a2
          add.l d7,a3
          dbra d6,sccuh1
          bra scc20
; Boucle de recopie sans decalage/ MIDRES
sccum1:   move.l d5,d0
sccum2:   move.l (a3)+,(a2)+
          dbra d0,sccum2
          add.l d7,a2
          add.l d7,a3
          dbra d6,sccum1
          bra scc20
; Boucle de recopie sans decalage/ LORES
sccub1:   move.l d5,d0
sccub2:   move.l (a3)+,(a2)+
          move.l (a3)+,(a2)+
          dbra d0,sccub2
          add.l d7,a2
          add.l d7,a3
          dbra d6,sccub1
          bra scc20 
        
; Screen copy vers le bas ---> Bas vers haut / droite vers gauche
sccd:     move.w d6,d0
          subq.w #1,d0
          mulu d3,d0          ;En bas/gauche de la zone
          add.w d0,d4         ;En bas/droite
          lsl.w #1,d4
          add.l d4,a2
          add.l d4,a3         ;Pointe en bas a droite de la zone a recopier
          subq #1,d5          ;Compteurs en DBRA
          subq #1,d6
          move.w mode(pc),d0
          subq.w #1,d0
          bmi sccdb1
          beq sccdm1
; boucle de recopie sans decalage/ HIRES
sccdh1:   move.w d5,d0
sccdh2:   move.w -(a3),-(a2)
          dbra d0,sccdh2
          sub.l d7,a2
          sub.l d7,a3
          dbra d6,sccdh1
          bra scc20
; Boucle de recopie sans decalage/ MIDRES
sccdm1:   move.l d5,d0
sccdm2:   move.l -(a3),-(a2)
          dbra d0,sccdm2
          sub.l d7,a2
          sub.l d7,a3
          dbra d6,sccdm1
          bra scc20
; Boucle de recopie sans decalage/ LORES
sccdb1:   move.l d5,d0
sccdb2:   move.l -(a3),-(a2)
          move.l -(a3),-(a2)
          dbra d0,sccdb2
          sub.l d7,a2
          sub.l d7,a3
          dbra d6,sccdb1
          bra scc20 

; RECOPIE AVEC DECALAGE
scc10:    bclr #30,d7
          btst #31,d7
          bne.s scc11
          move.w d5,d0    
          add.w d1,d0         ;additionne la taille en X
          cmp maxlimd(pc),d0
          bcs.s scc11
          bset #30,d7         ;si flag a UN: rien a droite!
scc11:    bclr #29,d7
          cmp.l a0,a1
          bne.s scc11a
          bset #29,d7         ;Flag meme ecran    
scc11a:   move.l a0,a2
          bsr adecran         ;adresse d'origine en A3
          move.l a2,a3
          movem (sp)+,d1-d2
          move.l a1,a2
          bsr adecran         ;adresse destination en A2
          move.w nbplan(pc),d2
          lsl.w #1,d2         ;---> nb octets
          mulu d2,d3          ;D3= Nb octets/ligne
          move.l d3,a4        ;Plus/Moins ligne
          subq #1,d6          ;Compteur en DBRA
          moveq #16,d4
          sub.w d7,d4         ;d4= 16-decalage
          btst #29,d7         ;meme ecran?
          beq.s scdu          ;NON---> + rapide=vers le haut!
          cmp.l a3,a2         ;Vers le haut ou le bas???
          bcc scdd
; Screen copy vers le haut ---> haut vers bas / gauche vers droite
scdu:     move.w d5,a5
          subq.w #1,a5        ;Compteur en DBRA
          btst #31,d7
          beq.s scc12
          subq.w #1,a5
scc12:    move mode(pc),d0
          beq scdul1
          cmp.w #1,d0
          beq scdum1
; HIRES
scduh1:   move.l a3,a0
          move.l a2,a1
          btst #31,d7         ;Octet de gauche
          beq.s scduh2
          move.w (a0),d0 
          swap d0
          clr.w d0
          move.w #$ffff,d5
          rol.l d7,d0
          lsl.w d7,d5
          and.w d5,(a1)
          or.w d0,(a1)+
          move.w a5,d5
          bmi.s scduh6
scduh2:   move.w a5,d5
          move.w 2(a0),d0
          swap d0
          move.w (a0),d0
          addq.l #4,a0
          subq.w #1,d5
          bmi.s scduh4
scduh3:   rol.l d7,d0         ;Boucle de recopie des TX-1 mots
          move.w d0,(a1)+
          move.w (a0)+,d0
          swap d0
          rol.w d4,d0
          dbra d5,scduh3
scduh4:   btst #30,d7         ;Octet de droite
          beq.s scduh5
          lsl.w d7,d0         ;Fin de l'ecran origine a droite
          move.l #$ffff0000,d5
          rol.l d7,d5
          and.w d5,(a1)
          or.w d0,(a1)
          bra.s scduh6
scduh5:   rol.l d7,d0         ;Quelque chose a droite
          move.w d0,(a1)
scduh6:   add.l a4,a2
          add.l a4,a3
          dbra d6,scduh1
          bra scc20
; MIDRES
scdum1:   move.l a3,a0
          move.l a2,a1
          btst #31,d7         ;Octet de gauche
          beq.s scdum2
          move.w (a0),d0
          move.w 2(a0),d1 
          swap d0
          swap d1
          clr.w d0
          clr.w d1
          move.w #$ffff,d5
          rol.l d7,d0
          rol.l d7,d1
          lsl.w d7,d5
          and.w d5,(a1)
          or.w d0,(a1)+
          and.w d5,(a1)
          or.w d1,(a1)+
          move.w a5,d5
          bmi.s scdum6
scdum2:   move.w a5,d5
          move.w 4(a0),d0
          move.w 6(a0),d1
          swap d0
          swap d1
          move.w (a0),d0
          move.w 2(a0),d1
          addq.l #8,a0
          subq.w #1,d5
          bmi.s scdum4
scdum3:   rol.l d7,d0         ;Boucle de recopie des TX-1 mots
          rol.l d7,d1
          move.w d0,(a1)+
          move.w d1,(a1)+
          move.w (a0)+,d0
          move.w (a0)+,d1
          swap d0
          swap d1
          rol.w d4,d0
          rol.w d4,d1
          dbra d5,scdum3
scdum4:   btst #30,d7         ;Octet de droite
          beq.s scdum5
          lsl.w d7,d0         ;Fin de l'ecran origine a droite
          lsl.w d7,d1
          move.l #$ffff0000,d5
          rol.l d7,d5
          and.w d5,(a1)
          or.w d0,(a1)+
          and.w d5,(a1)
          or.w d1,(a1)+
          bra.s scdum6
scdum5:   rol.l d7,d0         ;Quelque chose a droite
          rol.l d7,d1
          move.w d0,(a1)+
          move.w d1,(a1)
scdum6:   add.l a4,a2
          add.l a4,a3
          dbra d6,scdum1
          bra scc20
; LOWRES
scdul1:   move.l a3,a0
          move.l a2,a1
          btst #31,d7         ;Octet de gauche
          beq.s scdul2
          move.w (a0),d0
          move.w 2(a0),d1
          move.w 4(a0),d2
          move.w 6(a0),d3 
          swap d0
          swap d1
          swap d2
          swap d3
          clr.w d0
          clr.w d1
          clr.w d2
          clr.w d3
          move.w #$ffff,d5
          rol.l d7,d0
          rol.l d7,d1
          rol.l d7,d2
          rol.l d7,d3
          lsl.w d7,d5
          and.w d5,(a1)
          or.w d0,(a1)+
          and.w d5,(a1)
          or.w d1,(a1)+
          and.w d5,(a1)
          or.w d2,(a1)+
          and.w d5,(a1)
          or.w d3,(a1)+
          move.w a5,d5
          bmi scdul6
scdul2:   move.w a5,d5
          move.w 8(a0),d0
          move.w 10(a0),d1
          move.w 12(a0),d2
          move.w 14(a0),d3
          swap d0
          swap d1
          swap d2
          swap d3
          move.w (a0),d0
          move.w 2(a0),d1
          move.w 4(a0),d2
          move.w 6(a0),d3
          lea 16(a0),a0
          subq.w #1,d5
          bmi.s scdul4
scdul3:   rol.l d7,d0         ;Boucle de recopie des TX-1 mots
          rol.l d7,d1
          rol.l d7,d2
          rol.l d7,d3
          move.w d0,(a1)+
          move.w d1,(a1)+
          move.w d2,(a1)+
          move.w d3,(a1)+
          move.w (a0)+,d0
          move.w (a0)+,d1
          move.w (a0)+,d2
          move.w (a0)+,d3
          swap d0
          swap d1
          swap d2
          swap d3
          rol.w d4,d0
          rol.w d4,d1
          rol.w d4,d2
          rol.w d4,d3
          dbra d5,scdul3
scdul4:   btst #30,d7         ;Octet de droite
          beq.s scdul5
          lsl.w d7,d0         ;Fin de l'ecran origine a droite
          lsl.w d7,d1
          lsl.w d7,d2
          lsl.w d7,d3
          move.l #$ffff0000,d5
          rol.l d7,d5
          and.w d5,(a1)
          or.w d0,(a1)+
          and.w d5,(a1)
          or.w d1,(a1)+
          and.w d5,(a1)
          or.w d2,(a1)+
          and.w d5,(a1)
          or.w d3,(a1)+
          bra.s scdul6
scdul5:   rol.l d7,d0         ;Quelque chose a droite
          rol.l d7,d1
          rol.l d7,d2
          rol.l d7,d3
          move.w d0,(a1)+
          move.w d1,(a1)+
          move.w d2,(a1)+
          move.w d3,(a1)+
scdul6:   add.l a4,a2
          add.l a4,a3
          dbra d6,scdul1
          bra scc20

; Screen copy vers le bas: de bas en haut / de droite a gauche
scdd:     move.w d5,a5
          subq.w #1,a5        ;Compteur en DBRA
          btst #31,d7
          beq.s scc13
          subq.w #1,a5
          sub.w d2,a3
scc13:    mulu d2,d5
          mulu d6,d3          ;Pointe la derniere ligne
          add.w d5,d3
          add.w d3,a2         ;En bas a droite         
          add.w d3,a3
          move mode(pc),d0
          beq scddb1
          cmp.w #1,d0
          beq scddm1
; HAUTE RESOLUTION
scddh1:   move.l a3,a0
          move.l a2,a1
          btst #30,d7
          beq.s scddh2
          moveq #0,d0
          move.w -(a0),d0
          move.l #$ffff0000,d5
          lsl.l d7,d0
          rol.l d7,d5
          and.w d5,-(a1)
          or.w d0,(a1)
          move.w a5,d5
          subq.w #1,d5
          bpl.s scddh3
          bmi.s scddh6
scddh2:   move.w (a0),d0
          swap d0
          move.w -(a0),d0
          move.w a5,d5
          bpl.s scddh4
          bmi.s scddh5
scddh3:   rol.l d4,d0
          move.w -(a0),d0
scddh4:   rol.l d7,d0
          move.w d0,-(a1)
          dbra d5,scddh3          
scddh5:   btst #31,d7
          beq.s scddh6
          rol.l d4,d0
          clr.w d0
          move.w #$ffff,d5
          rol.l d7,d0
          lsl.w d7,d5
          and.w d5,-(a1)
          or.w d0,(a1)
scddh6:   sub.l a4,a2
          sub.l a4,a3
          dbra d6,scddh1
          bra scc20
; MOYENNE RESOLUTION
scddm1:   move.l a3,a0
          move.l a2,a1
          btst #30,d7
          beq.s scddm2
          moveq #0,d1
          moveq #0,d0
          move.w -(a0),d1
          move.w -(a0),d0
          move.l #$ffff0000,d5
          lsl.l d7,d1
          lsl.l d7,d0
          rol.l d7,d5
          and.w d5,-(a1)
          or.w d1,(a1)
          and.w d5,-(a1)
          or.w d0,(a1)
          move.w a5,d5
          subq.w #1,d5
          bpl.s scddm3
          bmi.s scddm6
scddm2:   move.w 2(a0),d1
          move.w (a0),d0
          swap d1
          swap d0
          move.w -(a0),d1
          move.w -(a0),d0
          move.w a5,d5
          bpl.s scddm4
          bmi.s scddm5
scddm3:   rol.l d4,d1
          rol.l d4,d0
          move.w -(a0),d1
          move.w -(a0),d0
scddm4:   rol.l d7,d1
          rol.l d7,d0
          move.w d1,-(a1)
          move.w d0,-(a1)
          dbra d5,scddm3          
scddm5:   btst #31,d7
          beq scddm6
          rol.l d4,d1
          rol.l d4,d0
          clr.w d1
          clr.w d0
          move.w #$ffff,d5
          rol.l d7,d1
          rol.l d7,d0
          lsl.w d7,d5
          and.w d5,-(a1)
          or.w d1,(a1)
          and.w d5,-(a1)
          or.w d0,(a1)
scddm6:   sub.l a4,a2
          sub.l a4,a3
          dbra d6,scddm1
          bra scc20
; BASSE RESOLUTION
scddb1:   move.l a3,a0
          move.l a2,a1
          btst #30,d7
          beq.s scddb2
          moveq #0,d3 
          moveq #0,d2
          moveq #0,d1
          moveq #0,d0
          move.w -(a0),d3
          move.w -(a0),d2
          move.w -(a0),d1
          move.w -(a0),d0
          move.l #$ffff0000,d5
          lsl.l d7,d3
          lsl.l d7,d2
          lsl.l d7,d1
          lsl.l d7,d0
          rol.l d7,d5
          and.w d5,-(a1)
          or.w d3,(a1)
          and.w d5,-(a1)
          or.w d2,(a1)
          and.w d5,-(a1)
          or.w d1,(a1)
          and.w d5,-(a1)
          or.w d0,(a1)
          move.w a5,d5
          subq.w #1,d5
          bpl.s scddb3
          bmi.s scddb6
scddb2:   move.w 6(a0),d3
          move.w 4(a0),d2
          move.w 2(a0),d1
          move.w (a0),d0
          swap d3
          swap d2
          swap d1
          swap d0
          move.w -(a0),d3
          move.w -(a0),d2
          move.w -(a0),d1
          move.w -(a0),d0
          move.w a5,d5
          bpl.s scddb4
          bmi.s scddb5
scddb3:   rol.l d4,d3
          rol.l d4,d2
          rol.l d4,d1
          rol.l d4,d0
          move.w -(a0),d3
          move.w -(a0),d2
          move.w -(a0),d1
          move.w -(a0),d0
scddb4:   rol.l d7,d3
          rol.l d7,d2
          rol.l d7,d1
          rol.l d7,d0
          move.w d3,-(a1)
          move.w d2,-(a1)
          move.w d1,-(a1)
          move.w d0,-(a1)
          dbra d5,scddb3         
scddb5:   btst #31,d7
          beq.s scddb6
          rol.l d4,d3
          rol.l d4,d2
          rol.l d4,d1
          rol.l d4,d0
          clr.w d3
          clr.w d2
          clr.w d1
          clr.w d0
          move.w #$ffff,d5
          rol.l d7,d3
          rol.l d7,d2
          rol.l d7,d1
          rol.l d7,d0
          lsl.w d7,d5
          and.w d5,-(a1)
          or.w d3,(a1)
          and.w d5,-(a1)
          or.w d2,(a1)
          and.w d5,-(a1)
          or.w d1,(a1)
          and.w d5,-(a1)
          or.w d0,(a1)
scddb6:   sub.l a4,a2
          sub.l a4,a3
          dbra d6,scddb1
; Fin screen copy OUF!
scc20:    move #1,intmouse
          moveq #0,d0
          rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         CLS A0=ecran / D1/D2 - D3/D4= fenetre / D5=couleur
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cls:      clr intmouse

; fabrique les plans couleurs
          lea plans(pc),a1
          clr.l (a1)
          clr.l 4(a1)
          move.w nbplan(pc),d6
          moveq #4,d7
cls0:     clr d0
cls1:     btst d0,d5
          beq.s cls2
          move #$ffff,(a1)
cls2:     addq.l #2,a1
          subq #1,d7
          beq.s cls3
          addq #1,d0
          cmp d6,d0
          bcs.s cls1
          bcc.s cls0
cls3:     tst.w d3
          bne.s cls10
; efface TOUT L'ECRAN
          move.l plans(pc),d0
          move.l plans+4(pc),d1
          move #999,d2
cls4:     move.l d0,(a0)+
          move.l d1,(a0)+
          move.l d0,(a0)+
          move.l d1,(a0)+
          move.l d0,(a0)+
          move.l d1,(a0)+
          move.l d0,(a0)+
          move.l d1,(a0)+
          dbra d2,cls4
          bra fincls
; Efface une fenetre
cls10:    move.w d3,d5
          move.w d4,d6
          add.w #640,d1
          add.w #400,d2
          lsr.w #4,d1
          lsr.w #4,d5
          move.l a0,a2
          bsr adecran
          sub.w d5,d3
          mulu nbplan(pc),d3
          lsl.w #1,d3           ;Plus ligne en D3
          subq.w #1,d5          ;Compteurs en DBRA
          bmi fincls
          subq.w #1,d6
          bmi fincls
          move.l plans(pc),d0   ;Prend les plans couleurs
          move.l plans+4(pc),d1
          move.w mode(pc),d7
          beq.s clsb
          cmp.w #1,d7
          beq.s clsm
; CLS en haute resolution
clsh:     move.w d5,d7
clsh1:    move.w d0,(a2)+
          dbra d7,clsh1
          add.w d3,a2
          dbra d6,clsh
          bra.s fincls
; CLS en moyenne resolution
clsm:     move.w d5,d7
clsm1:    move.l d0,(a2)+
          dbra d7,clsm1
          add.w d3,a2
          dbra d6,clsm
          bra.s fincls
; CLS en basse resolution
clsb:     move.w d5,d7
clsb1:    move.l d0,(a2)+
          move.l d1,(a2)+
          dbra d7,clsb1
          add.w d3,a2
          dbra d6,clsb
fincls:   move #1,intmouse
          rts   

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         Fabrication d'un bloc: a1= ecran / a2= destination
;                                d1-d2= X1/X2  /  d3-d4= tx/ty
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getbloc:  move.l #$44553528,(a2)+       ;code BLOC
          and.w #$fff0,d3
          move.w d3,(a2)+               ;TX
          move.w d4,(a2)+               ;TY
          lsr.w #4,d3
          move.w d3,d5
          exg a1,a2
          add.w #640,d1
          add.w #400,d2
          lsr.w #4,d1
          bsr adecran
          sub.w d5,d3
          mulu nbplan(pc),d3
          lsl.w #1,d3                   ;plus ligne ecran
          subq.w #1,d4                  ;Compteurs en DBRA
          subq.w #1,d5
          move mode(pc),d0
          beq getbb
          cmp.w #1,d0
          beq getbm
; Haute resolution
getbh:    move.w d5,d6
getbh1:   move.w (a2)+,(a1)+
          dbra d6,getbh1
          add.w d3,a2
          dbra d4,getbh
          bra.s fingetb
; Moyenne resolution
getbm:    move.w d5,d6
getbm1:   move.l (a2)+,(a1)+
          dbra d6,getbm1
          add.w d3,a2
          dbra d4,getbm
          bra.s fingetb
; Basse resolution
getbb:    move.w d5,d6
getbb1:   move.l (a2)+,(a1)+
          move.l (a2)+,(a1)+
          dbra d6,getbb1
          add.w d3,a2
          dbra d4,getbb
; Fin de la prise du bloc: ramene la fin de la chaine
fingetb:  move.l a1,d0
          rts          
          
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         Restitution d'un bloc, avec masque des bords
;                             a1= ad bloc / a2= ad ecran
;                             d1/d2= X/Y
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
putbloc:  cmp.l #$44553528,(a1)+
          bne pasbloc

; Calcul coordonnees d'arrivee
          and.w #$fff0,d1
          move.w d1,d5
          move.w d2,d6
          add.w (a1),d5       ;point de fin du bloc droite/bas
          add.w 2(a1),d6
          move.w d1,d3
          move.w d2,d4
          move.w mode(pc),d0  ;Pointe XMAX et YMAX
          lsl.w #1,d0
          lea x_max,a5
          add.w d0,a5
          lea y_max,a6
          add.w d0,a6
          
          tst.w d1            ;Limite a gauche      
          bpl.s putb1
          moveq #0,d1
putb1:    cmp.w (a5),d1
          bcc finputb
          tst.w d2            ;Limite a droite
          bpl.s putb2
          moveq #0,d2
putb2:    cmp.w (a6),d2
          bcc finputb

          tst.w d5            ;Limite a droite
          bmi finputb
          beq finputb
          cmp.w (a5),d5
          bcs.s putb3
          move.w (a5),d5
putb3:    tst.w d6            ;Limite en bas
          bmi finputb 
          beq finputb
          cmp.w (a6),d6
          bcs.s putb4
          move.w (a6),d6

putb4:    sub.w d1,d5         ;Calcule TX
          beq finputb
          bmi finputb
          sub.w d2,d6         ;Calcule TY
          beq finputb
          bmi finputb

          neg.w d3            ;Decale le depart vers la droite
          add.w d1,d3
          neg.w d4            ;Decale le depart vers le bas
          add.w d2,d4

; Calcul autres adresses
          move.w (a1),d0
          lsr.w #4,d0
          mulu nbplan(pc),d0
          lsl.w #1,d0
          move.w d0,a5                  ;Plus ligne BLOC en A5
          
          move.w (a1),d0                ;Calcule l'adresse dans le bloc
          lsr.w #4,d0
          mulu d0,d4
          lsr.w #4,d3
          add.w d3,d4
          mulu nbplan(pc),d4
          lsl.w #1,d4
          addq.l #4,a1                  ;Saute les tailles
          add.w d4,a1                   ;A1= adresse bloc

          add.w #640,d1
          lsr.w #4,d1
          add.w #400,d2
          bsr adecran                   ;adresse ecran---> A2
          mulu nbplan(pc),d3
          lsl.w #1,d3
          move.w d3,a6                  ;Plus ligne ECRAN en A6

          lsr.w #4,d5
          subq #1,d5                    ;Indice TX en D5
          bmi finputb                   ;Securite pour les petits pokeurs!
          subq #1,d6                    ;Indice TY en D6
          bmi finputb

          move.w mode(pc),d0
          beq putbb
          cmp.w #1,d0
          beq putbm

; Dessin du bloc en haute resolution                    
putbh:    move.l a1,a3
          move.l a2,a4
          move.w d5,d7
putbh1:   move.w (a3)+,d0
          or.w d0,(a4)+              ;Facile pour la haute resolution!
          dbra d7,putbh1
          add.w a5,a1
          add.w a6,a2
          dbra d6,putbh
          bra finputb
; Dessin du bloc en moyenne resolution
putbm:    move.l a1,a3
          move.l a2,a4
          move.w d5,d7
putbm1:   move.w (a3)+,d0
          move.w (a3)+,d1
          move.w d0,d4
          or.w d1,d4                    ;Masque
          not.w d4
          and.w d4,(a4)
          or.w d0,(a4)+
          and.w d4,(a4)
          or.w d1,(a4)+
          dbra d7,putbm1
          add.w a5,a1
          add.w a6,a2
          dbra d6,putbm
          bra finputb
; Dessin du bloc en basse resolution
putbb:    move.l a1,a3
          move.l a2,a4
          move.w d5,d7
putbb1:   move.w (a3)+,d0
          move.w (a3)+,d1
          move.w (a3)+,d2
          move.w (a3)+,d3
          move.w d0,d4
          or.w d1,d4     
          or.w d2,d4
          or.w d3,d4               ;Masque
          not.w d4
          and.w d4,(a4)
          or.w d0,(a4)+
          and.w d4,(a4)
          or.w d1,(a4)+
          and.w d4,(a4)
          or.w d2,(a4)+
          and.w d4,(a4)
          or.w d3,(a4)+
          dbra d7,putbb1
          add.w a5,a1
          add.w a6,a2
          dbra d6,putbb
; Fin de la recopie bloc
finputb:  moveq #0,d0
          rts
; Erreur ! pas un bloc
pasbloc:  moveq #1,d0
          rts

          

 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         Changement du jeu de sprites: a0 contient l'adresse
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
chgbank:  clr goodbank
          cmp.l #$19861987,(a0)+  ;verifie si c'est une banque
          bne.s chgb1
          move #1,goodbank
          move.l a0,dessins1
          bsr sproff              ;arret de tous les sprites
          clr.l d0
          rts
chgb1:    moveq #1,d0
          rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         Initialisation des interruptions et de la trappe #5
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
super:    move.l d0,-(sp)
          move.w #38,-(sp)
          trap #14
          addq.l #6,sp
          rts
;initialisation de la trappe
initrap:  move.l #routrap,d0
          bra super
; branche la trappe
routrap:  move.l #entrappe,$94          ;trappe #5
          rts
;INITIALISATION DES INTERRUPTIONS: A0=DOITACT
departint:clr intmouse                  ;aucune interruption
          clr animflg
          clr nbflash
          clr goodbank
          move #-1,showon               ;hide -1!
          move.l $42e,d0                ;fin de la memoire physique
          sub.l #$10000,d0
          move.l d0,backg               ;decor par defaut
          cmp.l #0,a0
          bne dep1
          lea doitact(pc),a0
dep1:     move.l a0,doitactad           ;adresse du flag
          clr.w (a0)
;inter VBL!
          move.l $456,a0
          move.l (a0),ancient1
          move.l #ecrint,(a0)           ;VBL
          move.w #1,intersync           ;synchronise interruption dep/vbl
;init coords souris
          move mode(pc),d0
          lsl #1,d0
          lea x_max(pc),a0
          move.w 0(a0,d0.w),d1
          subq.w #1,d1
          move.w d1,mxmouse
          move.w 6(a0,d0.w),d1
          subq.w #1,d1
          move.w d1,mymouse
          move.l advect,a0              ;adresse du vecteur interruptions
          move.l (a0),ancient2
          move.l #sourint,(a0)          ;branche la routine souris
          rts
;ARRET DES INTERRUPTIONS
arretint: tst.l ancient2		    ;Si deja sauve!
	  beq.s PaArr 
	  move.l $456,a0
          move.l ancient1(pc),(a0)          ;remet le VBL
          move.l advect(pc),a0
          move.l ancient2(pc),(a0)          ;remet la routine souris normale
PaArr:    rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         Entree des interruptions souris (vecteur en $DDC)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sourint:  move.w d0,-(sp)
          move.w d1,-(sp)
          move.w d2,-(sp)
          move.l a1,-(sp)
          move.b (a0),d0
          move.b d0,d1
          and.b #$f8,d1
          cmp.b #$f8,d1
          bne sourint10
          move.l admouse(pc),a1      ;adresse table gestion souris!
          and.w #$3,d0
          lsr.b #1,d0
          bcc.s sourint1
          bset #1,d0
sourint1: move.b 254(a1),d1      ;$27de (520/1040) ou $283e (MEGA) 
          and.w #$3,d1
          cmp.b d1,d0
          beq.s sourint2
          move.w d0,6(a1)
          eor.b d0,d1
          ror.b #2,d1
          or.b d1,d0
          move.b d0,254(a1)
sourint2: move.b 1(a0),d0
          or.b 2(a0),d0
          bne.s sourint3
          bclr #5,254(a1)
          bra.s sourint10
sourint3: bset #5,254(a1)
          move.w (a1),d0
          move.b 1(a0),d1
          ext.w d1
          add.w d1,d0
          move.w 2(a1),d1
          move.b 2(a0),d2
          ext.w d2
          add.w d2,d1
; test des coordonnees
          tst.w d0
          bge.s sourint4
          clr.w d0
          bra.s sourint5
sourint4: cmp.w mxmouse(pc),d0
          ble.s sourint5
          move.w mxmouse(pc),d0
sourint5: tst.w d1
          bge.s sourint6
          clr.w d1
          bra sourint7
sourint6: cmp.w mymouse(pc),d1
          ble.s sourint7
          move.w mymouse(pc),d1
; fin de la gestion
sourint7: move.w d0,(a1)
          move.w d1,2(a1)
sourint10:move.l (sp)+,a1
          move.w (sp)+,d2
          move.w (sp)+,d1
          move.w (sp)+,d0
          rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         Entree de la trappe
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
entrappe: movem.l d2-d7/a1-a6,-(sp)
          lsl #2,d0
          lea trappe(pc),a6
          add d0,a6
          move.l (a6),a6
          jsr (a6)
          movem.l (sp)+,d2-d7/a1-a6
          rte

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         Show mouse: d1=parametre (0=raz, <>0 moins un)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
show:     clr intmouse        ;ne pas gerer la souris pendant ce temps!
          tst d1
          bne show1
          move #-1,showon
show1:    add #1,showon
          bmi finhide
          bne finhide
          move #-1,xmouse         ;doit dessiner...
          move oldform(pc),form   ;...l'ancienne souris
          bra showshow            ;Affiche DEBUGGE!!!

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         Hide mouse: d1=parametre (0= raz, <>0 moins un)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
hide:     clr intmouse
          tst d1
          bne hide1
          clr showon
hide1:    sub #1,showon
          bcc finhide
          move #$8000,d0
          bsr geninter        ;efface tout de suite la souris!
finhide:  move #1,intmouse
          clr.l d0
          rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         Change Mouse: change la forme de la souris
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
chgmouse: clr intmouse        ;si >=4 pointe le premier sprite de la banque
          move d1,form        ;utilisateur...
          move d1,oldform
          move #-1,xmouse
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         Remise en marche toute bete de la souris
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mousbete: move #1,intmouse
          move #-1,xmouse     ;force le redessin
          clr.l d0
          rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         Mouse: ramene X et Y souris en d0/d1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mouse:    move.l admouse(pc),a0
          move (a0),d0
          add dxmouse(pc),d0
          move 2(a0),d1
          add dymouse(pc),d1
          rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         Mouse key: touches enfoncees en d0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mousekey: move.l admouse(pc),a0
          move 6(a0),d0
          rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         REDRAW: actualisation ET reaffichage SANS bavure!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
redraw:   move.l ecran,d0
          cmp.l backg(pc),d0
          beq.s rapact0
          bsr actualise
          bra spreaf0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         ACTUALISATION/REDRAW ULTRA RAPIDE SI BACK=LOGIC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
rapact0:  clr intmouse
          lea sprites+28(pc),a0
          lea tablact(pc),a1
          moveq #0,d7
          moveq #0,d6
;
rapact1:  tst.w (a1)
          beq rapact11 
          bmi rapact6 
; changement
          tst.w (a0)
          bne.s rapact1a
          moveq #1,d6
          move.w d6,(a0)
rapact1a: move.w actx(a1),d1
          beq.s rapact2
          move.w d1,xinput(a0)
rapact2:  move.w acty(a1),d2
          beq.s rapact3
          cmp.w yinput(a0),d2
          beq.s rapact3
          moveq #1,d6
          move.w d2,yinput(a0)
rapact3:  move.w actimage(a1),d3
          beq.s rapact5
          move.l dessins1(pc),a2
          tst goodbank
          beq rapact6
rapact4:  move mode(pc),d4
          lsl.w #2,d4
          move.l 0(a2,d4.w),d0
          beq rapact6
          move.l d0,a3
          add.l a2,a3
          lsr.w #1,d4
          cmp 12(a2,d4.w),d3
          bhi rapact6
          move d3,pointeur(a0)
          lsl.w #3,d3
          lea -8(a3,d3.w),a2
          add.l (a2)+,a3
          move.l a3,image(a0)
          clr d4
          move.b (a2)+,d4
          move.w d4,tx(a0)
          move.b (a2)+,d4
          move.w d4,ty(a0)
          move.b (a2)+,d4
          move.w d4,dxhot(a0)
          move.b (a2)+,d4
          move.w d4,dyhot(a0)
          bra.s rapact10
rapact5:  tst pointeur(a0)
          bne.s rapact10
; effacement
rapact6:  clr.w (a0)
          moveq #1,d6
        
; actualisation suivante
rapact10: clr.w (a1)
rapact11: lea 28(a0),a0
          lea 8(a1),a1
          addq #1,d7
          cmp #nbanimes,d7
          bne rapact1

; Classement des priorites?
          move.w prioron(pc),d0
          beq.s rapact20
          tst d6 
          beq.s rapact20
          bsr priocalc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         Super redessine!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
rapact20: moveq #nbsprite-2,d0
          lea priorite(pc),a1
          
rapact21: move.w (a1)+,d1
          bmi.s rapnext
          mulu #28,d1
          lea sprites(pc),a0
          add.w d1,a0
          tst.w (a0)
          bne.s rapfiche
rapnext:  dbra d0,rapact21
; redessine la souris
          move.w #-1,xmouse
          move.w #1,intmouse     
          rts          
;
rapfiche: movem.l a1/d0,-(sp)
; taille du dessin
          move.w tx(a0),d4
          move.w ty(a0),d5
; calcule les adresses
          move.w xinput(a0),d1
          move.w yinput(a0),d2
          sub.w dxhot(a0),d1
          sub.w dyhot(a0),d2
          move d4,d3
          bsr coords
          beq.s rapf1
          addq #1,d3
; stocke les coordonnees
rapf1:    move.w d0,xmot(a0)
          move.w d1,decx(a0)
          move.w d2,y(a0)
          move.w d3,txr(a0)
; limite l'affichage
          add.w d2,d5         ;d5-FY
          move.w d0,d4
          add.w d3,d4         ;d4-FX
          move.w d2,d3        ;d3-DY
          move.w d0,d2        ;d2-DX
          bsr limites
          tst sortie
          bne rapfin
; calcule les adresses
          move.w d2,d1
          move.w d3,d2
          move.l backg(pc),a2
          bsr adecran         ;adresse dans l'ecran
          move.l a2,a4
          move.w nbplan(pc),d7
          move.l image(a0),a2
          move.l a2,a3
          move tx(a0),d0
          mulu ty(a0),d0
          asl.w #1,d0
          add.w d0,a3
          move.w xbuf(pc),d0
          sub.w xmot(a0),d0     ;decalage en X
          move.w ybuf(pc),d1   
          sub.w y(a0),d1        ;decalage en Y
          mulu tx(a0),d1
          add.w d1,d0
          lsl #1,d0
          add.w d0,a2           ;adresse dans le masque
          mulu d7,d0
          add.w d0,a3           ;adresse dans les octets

          move.w txbuf(pc),d0
          move.w d0,a5
          subq #2,a5            ;a5: taille en X(-2)

          move.w d0,d1
          sub.w d1,d3           ;taille ligne ecran-taille sprite
          mulu d7,d3            ;nombre de plans
          lsl.w #1,d3           ;fois 2 = plusecran
          move.w d3,plusbuf

          move.w decx(a0),d5    ;d5: decalages
          moveq #16,d6
          sub.w d5,d6           ;d6: 16-decalages

          bclr #31,d7           ;flag droite
          tst.w d5
          beq.s rapf2
          move.w xmot(a0),d1
          add.w txr(a0),d1
          cmp.w fxbuf(pc),d1
          bne.s rapf2
          bset #31,d7
          subq #1,d0

rapf2:    bclr #30,d7           ;flag: gauche
          move.w xbuf(pc),d1
          cmp.w xmot(a0),d1
          beq.s rapf3
          bset #30,d7
          
rapf3:    move.w tx(a0),d1
          sub d0,d1
          lsl #1,d1
          move d1,plusmasq
          mulu d7,d1
          move d1,plusoct

          move.w tybuf(pc),d3
          subq #1,d3

          bsr drawsp

rapfin:   movem.l (sp)+,a1/d0
          bra rapnext
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         Reaffichage simple de tous les sprites et de la souris
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
spreaff:  moveq #0,d5
spreaf0:  lea sprites+28(pc),a1   ;pointe le sprite #1
          moveq #1,d4
          clr d1              ;prend les coordonnees existantes!!!
          clr d2
          clr d3
spreaf1:  tst (a1)
          beq.s spreaf2
          btst d4,d5
          bne.s spreaf2
          move d4,d0
          bsr gensprite
spreaf2:  lea 28(a1),a1
          addq #1,d4
          cmp.b #16,d4
          bne.s spreaf1
          move #1,intmouse
drawmouse:move #-1,xmouse
          rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         Arret de la souris pendant l'affichage des fenetres
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
stopmouse:clr intmouse
          rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         Limit mouse: limite les coordonnees de la souris
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
limouse:  move.l admouse(pc),a0
          tst d3
          bne limous2
          clr d1
          clr d2
          move #640,d3
          move #400,d4
          cmp #2,mode
          beq limous2
          tst mode
          bne limous1
          lsr #1,d3
limous1:  lsr #1,d4
          subq #1,d3
          subq #1,d4
limous2:  clr intmouse
          move d1,dxmouse     ;depart de la souris
          move d2,dymouse
          sub d1,d3
          sub d2,d4
          move d3,mxmouse     ;largeur du mouvement de la souris
          move d4,mymouse
          lsr #1,d3           ;met la souris au milieu de la zone
          move d3,(a0)
          lsr #1,d4
          move d4,2(a0)
          move #1,intmouse
          rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         CHANGE LES COORDONNEES DE LA SOURIS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
chgcmous: clr intmouse
          move.l admouse(pc),a0
	  sub dxmouse(pc),d1	;ramene au debut de la zone
          cmp mxmouse(pc),d1    ;regarde si les coords ne sont pas trop grandes
          bcc chgc1
          move d1,(a0)
chgc1:    sub dymouse(pc),d2	
	  cmp mymouse(pc),d2
          bcc chgc2
          move d2,2(a0)
chgc2:    move #1,intmouse
          rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         RAZ ZONE: initialisation table zoneur
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
razones:  move #127,d0
          move.l tzones(pc),a0
rz1:      clr.l (a0)+
          clr.l (a0)+
          dbra d0,rz1
          rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         SET ZONE: d1-(d2-d3-d4-d5)  -(dx-fx-dy-fy)-
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
setzone:  move.l tzones(pc),a0
          tst d1
          beq.s synt
          cmp #129,d1
          bcc.s synt
          subq #1,d1
          lsl #3,d1
          add d1,a0
          cmp d3,d2
          bcc.s synt
          cmp d5,d4
          bcc.s synt
          move d2,(a0)+
          move d3,(a0)+
          move d4,(a0)+
          move d5,(a0)+
          clr.l d0
          rts
synt:     move.l #1,d0
          rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         ZONE: ramene la zone dans laquelle se trouve le sprite D1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
zone:     cmp #nbsprite,d1
          bcc.s synt
          bsr adspr1          ;adresse du sprite
          tst (a0)
          beq.s z2
          move xinput(a0),d2
          move yinput(a0),d3
          move.l tzones(pc),a1
          move #127,d1
z0:       tst (a1)
          bne.s z3
z1:       addq.l #8,a1
          dbra d1,z0
z2:       clr.l d0
          clr.l d1
          rts
z3:       cmp (a1),d2         ;compare DX
          bcs.s z1
          cmp 2(a1),d2        ;compare FX
          beq.s z4
          bcc.s z1
z4:       cmp 4(a1),d3        ;compare DY
          bcs.s z1
          cmp 6(a1),d3        ;compare FY
          beq.s z5
          bcc.s z1
z5:       neg d1              ;calcul de la zone
          add #128,d1
          clr.l d0
          rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         Animeur/Deplaceur
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Mini CHRGET: (a0)--->d0
miniget:  move.b (a0)+,d0     ;beq: fini
          beq.s mini5           ;bmi: lettre
          cmp.b #32,d0        ;bne: chiffre
          beq.s miniget
          cmp.b #"0",d0
          blt.s mini2
          cmp.b #"9",d0
          bhi.s mini2
          move #1,d7
          rts
mini2:    cmp.b #"a",d0       ;transforme en majuscules
          bcs.s mini3
          sub.b #32,d0
mini3:    move #-1,d7
mini5:    rts

;Conversion dec/hexa a0 -> chiffre en d1
dechexa:  clr d1         ; derniere lettre en D0
          clr d2
          bsr miniget
          beq.s dh5
          bpl.s dh2
          cmp.b #"-",d0
          bne.s dh5
          move #1,d2
dh0:      bsr miniget
          beq.s dh3
          bmi.s dh3
dh2:      mulu #10,d1
          sub.b #48,d0
          and #$00ff,d0
          add d0,d1
          bra.s dh0
dh3:      tst d2
          beq.s dh4
          neg d1
dh4:      clr d2              ;beq: un chiffre
          rts
dh5:      moveq #1,d2         ;bne: pas de chiffre
          rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         INITIALISATION DU FLASHEUR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
razflash: clr nbflash
          move #lflash*16-1,d0
          lea tflash(pc),a0
razfl1:   clr.b (a0)+
          dbra d0,razfl1
          rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         FLASH X,A$     d1=numero de la couleur, a0=adresse de la chaine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
flashinit:move nbflash(pc),d6
          clr nbflash         ;arrete les flashes
          clr d5
          cmp #16,d1
          bcc flsynt
          lea tflash(pc),a2       ;trouve la position dans la table
          moveq #1,d0
          addq #1,d1
          lsl #1,d1
flshi1:   tst (a2)            ;premiere place libre
          beq flsbug
          cmp (a2),d1         ;si meme couleur: aucun en plus!!!
          beq flshi2
          add #lflash,a2
          addq #1,d0
          cmp #16,d0
          bls flshi1
          bra flsont          ;par securite
flsynt:   clr.w (a2)          ;arrete la couleur
flsont:   moveq #1,d0
flout:    move.w d6,nbflash
          rts
flsbug:   cmp d6,d0           ;si trouve un trou au milieu de la table
          bls flshi2          ;n'additionne pas
          moveq #1,d5         ;un flash de plus!
flshi2:   moveq #lflash-1,d0  ;nettoie la table
          move.l a2,a1
flshi3:   clr.b (a1)+
          dbra d0,flshi3
          clr.l d0
          tst.b (a0)          ;flash 1,"": arret de la couleur
          beq flout
          move.w d1,(a2)      ;poke le numero de couleur
          move.b #1,flcpt(a2) ;initialise le compteur
          moveq #-2,d3
          moveq #-1,d4
flshi4:   bsr miniget
          cmp.b #"(",d0
          bne flshi5
          addq.l #2,d3
          addq.l #1,d4
          cmp #16,d4             ;16 couleurs autorisees!
          bcc flsynt
          bsr dechexa
          bne flsynt
          and.l #$ffff,d1
          clr.w d2
          divu #100,d1
          cmp.w #7,d1
          bhi flsynt
          move.b d1,d2
          lsl #4,d2
          clr d1
          swap d1
          divu #10,d1
          cmp.w #7,d1
          bhi flsynt
          or.b d1,d2
          lsl #4,d2
          clr d1
          swap d1
          cmp.w #7,d1
          bhi flsynt
          or.b d1,d2
          move.w d2,flcolor(a2,d3.w)  ;poke la couleur!
          cmp.b #",",d0
          bne flsynt
          bsr dechexa
          bne flsynt
          tst d1
          beq flsynt
          cmp #255,d1
          bhi flsynt
          move.b d1,flind(a2,d4.w)    ;poke la vitesse
          cmp.b #")",d0
          bne flsynt
          bra flshi4
flshi5:   tst.b d0            ;la chaine doit etre finie!
          bne flsynt
          add d5,d6           ;change ou non le nombre de couleurs
          clr.l d0            ;pas d'erreur
          bra flout

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         Initialisation shifter
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
initshift:clr shiftcpt
          rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         Depart shiftage: D1= vitesse / D2= premiere couleur
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
shifton:  neg d2
          tst mode
          bne.s sft1
          lea $ff825e,a0
          add.w #14,d2
          bra.s sft2
sft1:     lea $ff8246,a0
          addq #2,d2
sft2:     move.l a0,shiftad
          move.w d2,shiftnb 
          move d1,shiftind
          move d1,shiftcpt
          rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         Initialisation Animeur/Deplaceur/Activateur
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
initactiv:clr animflg         ;arret routine interruptions!
          lea tablact(pc),a0
          move #nbanimes*4-1,d0
iact1:    clr (a0)+
          dbra d0,iact1
          lea tablanim(pc),a0
          move #nbanimes*6-1,d0
iact2:    clr (a0)+
          dbra d0,iact2
          lea tablemvt(pc),a0
          move #nbanimes*10-1,d0
iact3:    clr (a0)+
          dbra d0,iact3
          rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         ANIMATE X,A$     d1=numero du sprite, a0=adresse de la chaine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
animinit: clr animflg
          and #$f,d1
          beq syntax
          lea tablanim(pc),a6
          subq #1,d1
          move d1,d2
          mulu #12,d2
          add d2,a6           ;a6 pointe la table d'animation
          clr (a6)            ;arret du sprite
          lsl #6,d1
          move.l buffanim(pc),a5     ;a5 pointe le buffer d'animation
          add d1,a5
          move.l a5,a4
          clr animpos(a6)
          move.l a5,animad(a6)
          clr anibcle(a6)
          move #16,d3         ;nombre d'animations possibles
anim1:    bsr miniget         ;pokage des parametres dans la table
          cmp.b #"(",d0
          bne anim2
          subq #1,d3          ;16 animations possibles
          beq toolong
          bsr dechexa
          bne syntax
          tst d1
          bmi syntax
          move d1,(a5)+
          cmp.b #",",d0
          bne syntax
          bsr dechexa
          bne syntax
          tst d1
          bmi syntax
          move d1,(a5)+
          cmp.b #")",d0
          bne syntax
          bra anim1
anim2:    sub.l a4,a5
          cmp.l #0,a5
          beq syntax
          move a5,animax(a6)  ;taille de la table
          cmp.b #"L",d0
          bne anim3
anim2b:   move #1,anibcle(a6) ;ca doit boucler a la fin!
          bsr miniget
anim3:    tst.b d0
          bne syntax
anim4:    move #$8001,(a6)    ;attend un animate on
ok:       move.l doitactad,a0
          bset #1,(a0)        ;doitact pour le basic
          move #1,animflg     ;animation en route!
          clr.l d0            ;pas d'erreur
          rts
syntax:   move #1,animflg
          move #1,d0
          rts
toolong:  move #1,animflg
          move #2,d0
          rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         MOVE X/Y n,a$   A0 adresse chaine, D1 numero du sprite, D2 X ou Y
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
depinit:  clr animflg
          and #$f,d1          ;pas de sprite zero!
          beq syntax
          subq #1,d1
          and #1,d2
          move d2,mouvxy
          move d2,d6
          lsl #1,d6
          lea tablact(pc),a2
          move d1,d3
          lsl #3,d3
          add d3,a2           ;a2/d6 pointe la tablact pour ce sprite
          lea tablemvt(pc),a6
          move d1,d3
          lsl #1,d3
          add d2,d3
          mulu #22,d3
          add d3,a6           ;a6 pointe la table mouvement
          move.l buffmvt(pc),a5
          lsl #1,d1
          add d2,d1
          mulu #96,d1
          add d1,a5           ;a5 pointe le buffer mouvement
          move.l a5,a4
          move.l a4,a3
          clr (a6)            ;arret du sprite
          clr mvtbcle(a6)     ;pas de boucle
          clr mvtcond(a6)     ;pas de condition
          move.l a5,mvtad(a6) ;adresse de la table
          bsr dechexa
          beq mvt0
          clr d1              ;pas de chiffre!
          bra mvt05
mvt0:     add #400,d1
          tst mouvxy
          bne mvt05
          add #240,d1
mvt05:    move d1,mvtpdeb(a6) ;init position
          subq.l #1,a0
          move #16,d3         ;nombre de mouvements possibles
mvt1:     bsr miniget         ;pokage des parametres dans la table
          cmp.b #"(",d0
          bne mvt2
          subq #1,d3          ;16 animations possibles
          beq toolong
          bsr dechexa
          bne syntax
          tst d1
          bmi syntax
          move d1,(a5)+
          cmp.b #",",d0
          bne syntax
          bsr dechexa
          bne syntax
          move d1,(a5)+
          cmp.b #",",d0
          bne syntax
          bsr dechexa
          bne syntax
          tst d1
          bmi syntax
          move d1,(a5)+
          cmp.b #")",d0
          bne syntax
          bra mvt1
mvt2:     sub.l a4,a5
          cmp.l #0,a5
          beq syntax
          move a5,mvtmax(a6)  ;taille de la table
          tst.b d0            ;rien apres: arret normal
          beq mvt6
          cmp.b #"E",d0
          beq mvt4
          cmp.b #"L",d0
          bne syntax
          move #1,mvtbcle(a6) ;boucle si condition
mvt4:     bsr dechexa
          beq mvt4a
          clr d1
          bra mvt4b
mvt4a:    add #400,d1
          tst mouvxy
          bne mvt4b
          add #240,d1
mvt4b:    move d1,mvtcond(a6) ;si rien: 0, si <>0: condition
mvt5:     tst.b d0
          bne syntax
mvt6:     move.l a6,a1        ;va activer le sprite en question
          bsr dinit
          or #$8000,(a1)      ;attend un move on
          bra ok

;Calcule les adresses anim->(a4), move->(a5), act->(a6)
actad:    subq #1,d1
          move d1,d7
          lsl #3,d7
          lea tablact(pc),a6
          add d7,a6
          move d1,d7
          mulu #44,d7
          lea tablemvt(pc),a5
          add d7,a5
          mulu #12,d1
          lea tablanim(pc),a4
          add d1,a4
          rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         Fonction MOVE: un sprite est-t-il encore en mouvement?
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mouvon:   moveq #0,d0
          and #$f,d1
          beq.s mouvon1
          bsr actad
          bsr ssmouve
          lea 22(a5),a5
          swap d0
          bsr ssmouve
mouvon1:  rts  
; sous programme
ssmouve:  tst.w (a5)
          beq.s ssmouve1
          moveq #0,d1
          move.w mvtpos(a5),d1
          divu #6,d1
          move.w d1,d0
          lsl.w #8,d0
          lsl.w #4,d0
          move.w mvtnbre(a5),d1
          and.w #%0000111111111111,d1
          or.w d1,d0
ssmouve1: rts 

; OFF/FREEZE/ON
onoff:    tst d2
          bne onof1
          clr (a6)            ;OFF
          rts
onof1:    cmp #1,d2
          bne onof2
          or #$8000,(a6)      ;FREEZE
          rts
onof2:    and #$7fff,(a6)     ;ON
          rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         ANIMATE X ON / ANIMATE X OFF  d1=x, d2: -0:off -1:freeze -3:on
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
anxonoff: clr d3
          and #$f,d1
          bne anmf0
          bra syntax
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         ANIMATE ON / ANIMATE OFF      cf avant
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
anonoff:  moveq #1,d1
          moveq #14,d3
anmf0:    bsr actad
          move.l a4,a6
          clr animflg
anmf1:    bsr onoff
          add #12,a6
          dbra d3,anmf1
          bra ok

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         MOVE X ON / MOVE X OFF    d1=X, cf avant
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mvxonoff: moveq #1,d3
          and #$f,d1
          bne monf0
          bra syntax
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         MOVE ON / MOVE OFF              cf avant
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
movonoff: moveq #1,d1
          moveq #29,d3
monf0:    bsr actad
          move.l a5,a6
          clr animflg
monf1:    bsr onoff
          add #22,a6
          dbra d3,monf1
          bra ok

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         SPRITE x ON / SPRITE x OFF  d1=sprite, d2=onoff
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
spxonoff: and #$f,d1
          beq syntax
	  move d1,-(sp)
	  bsr anxonoff
	  move (sp),d1
	  bsr mvxonoff
	  move (sp)+,d1
	  clr d3
	  bra.s sponof0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         SPRITE ON / OFF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sponoff:  bsr movonoff
	  bsr anonoff
	  moveq #1,d1
          moveq #14,d3
sponof0:  bsr actad
          clr animflg
sponof1:  tst d2
          bne sponof2
          or #$8000,(a6)
          bra sponof3
sponof2:  move #1,(a6)
sponof3:  add #8,a6
          dbra d3,sponof1
          bra ok

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         SPRITE n,x,y,a: sprite D1,D2,D3,D4
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sprnxya:  and #$f,d1
          beq syntax
          bsr actad
          clr animflg
          add #640,d2
          bne sprn1
          moveq #1,d2         ;protege si coords sont a zero!
sprn1:    move d2,4(a6)
          add #400,d3
          bne sprn2
          moveq #1,d3
sprn2:    move d3,6(a6)
          move d4,2(a6)
          move #1,(a6)
          bra ok

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         INTERSYNC ON/OFF: D1=0 (OFF), D1=1 (ON)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
interson: move.w d1,intersync
          rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         INTER: un cran d'interruptions!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
inter:    tst.w intersync               ;Securite: interdit l'appel
          bne.s PasInter
          move.l doitactad(pc),a4       ;si pas en route!
          bra animbis
PasInter: rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         FADE: D2= flag /  D1= vitesse
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fade:     move.w d1,fadecpt
          move.w d1,fadevit
          cmp.w #$ffff,d2
          bne.s fde1
; Si toutes les couleurs----> arrete shift et flash!
          move.w d2,-(sp)
          bsr razflash
          bsr initshift  
          move.w (sp)+,d2

fde1:	  move.w d2,fadeflg    
          rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         Entree interruptions d'ecran: animeur/couleurs/souris
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ecrint:   move.l doitactad(pc),a4
          bset #7,(a4)        ;interruption d'‚cran!

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         FADEUR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          move.w fadeflg(pc),d5
          beq flashint
          sub.w #1,fadecpt
          bne flashint
          move.w fadevit(pc),fadecpt
          clr.w fadeflg                 ;interdit les appels en boucle
; fade
          lea $ff8240+30,a0
          move.l ecran,a1
          lea 32030(a1),a1
          moveq #15,d4
; boucle de fade
fade1:    btst d4,d5
          beq.s fade5
          bclr d4,d5
          move.w (a0),d0      ;palette HARD
          and.w #$777,d0
          move.w (a1),d1      ;palette LOGIQUE
          and.w #$777,d1
          cmp.w d0,d1
          beq.s fade5
; change la couleur
          moveq #2,d3
          swap d0
          swap d1
          lsl.l #4,d0
          lsl.l #4,d1
          moveq #0,d2
fade2:    lsl.w #4,d2
          clr.w d0
          clr.w d1
          rol.l #4,d0
          rol.l #4,d1
          cmp.w d1,d0
          beq.s fade4
          bhi.s fade3
          addq.w #1,d0
          bra.s fade4
fade3:    subq.w #1,d0
fade4:    or.w d0,d2
          dbra d3,fade2
          move.w d2,(a0)
          bset d4,d5
; Couleur suivante!
fade5:    subq.l #2,a0
          subq.l #2,a1
          dbra d4,fade1  
          move.w d5,fadeflg   ;retabli le flag/inhibe si c'est fini!

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         FLASHEUR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
flashint: move.w nbflash(pc),d7
          beq.s shifter
          clr nbflash         ;interdit les appels en boucle!
          move d7,d6
          subq #1,d7
          lea tflash(pc),a0
          lea $ff8240,a2      ;palette du circuit de couleurs
flsh1:    move.w (a0),d0
          bne.s flsh3
flsh2:    add #lflash,a0
          dbra d7,flsh1
          move d6,nbflash     ;retabli nbflash     
          bra.s shifter
flsh3:    sub.b #1,flcpt(a0)
          bne.s flsh2
          move.w flpos(a0),d1
          move.b flind(a0,d1.w),d2        ;derniere couleur?
          bne.s flsh4
          clr.w d1
          move.b flind(a0,d1.w),d2
flsh4:    move.b d2,flcpt(a0)             ;change la vitesse
          lsl #1,d1
          move.w flcolor(a0,d1.w),-2(a2,d0.w)  ;change la couleur
          lsr #1,d1
          addq #1,d1
          cmp #16,d1
          bcs.s flsh5
          clr.w d1
flsh5:    move.w d1,flpos(a0)
          bra.s flsh2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         SHIFTER DE PALETTE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
shifter:  move shiftcpt(pc),d0
          beq.s mouseint
          sub #1,shiftcpt
          bne.s mouseint
          move shiftind(pc),shiftcpt
          move.l shiftad(pc),a0
          move.w shiftnb(pc),d0
; basse resolution
          move.w (a0),d1
shift1:   move.w -2(a0),(a0)
          subq #2,a0
          dbra d0,shift1
          move.w d1,(a0)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         GESTION DE LA SOURIS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mouseint: move intmouse(pc),d0        ;souris autorisee?
          beq.s animeur
          move showon(pc),d0          ;>=0: souris affichee!
          bmi.s animeur
          clr intmouse
          bsr showshow                ;Appelle la routine! PLUS DE BUG!!!!

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         ANIMEUR ET DEPLACEUR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
animeur:  move intersync(pc),d0
          beq fint
; entree directe par la trappe!
animbis:  move animflg(pc),d0 
          beq fint
          clr animflg         ;empeche les appels en boucle!
          lea tablanim(pc),a0
          lea tablemvt(pc),a1
          lea tablact(pc),a2
          moveq #nbanimes-1,d7
anm0:     tst (a0)            ;teste animation
          beq.s anm1
          bmi.s anm1
          sub #1,(a0)         ;decremente vitesse et va animer si zero
          bne.s anm1
; Animation!
          move.l animad(a0),a3          ;adresse de la table
          move animpos(a0),d0           ;adresse dans la table
          cmp animax(a0),d0             ;maximum?
          bcs.s anm7
          tst anibcle(a0)     ;boucle?
          bne.s anm6
          clr (a0)            ;NON: on arrete le sprite
          bra.s anm1
anm6:     clr d0              ;OUI: on remet a zero le pointeur
anm7:     add d0,a3
          move (a3),actimage(a2)        ;image--->table activation
          move 2(a3),(a0)               ;vitesse--->table animation
          addq #4,d0
          move d0,animpos(a0)           ;nouveau pointeur
          add #1,(a2)                   ;doit activer!
          bset #1,(a4)                  ;flag pour le basic!
          bra.s anm1
; teste les deplacements
anm1:     lea 12(a0),a0
          tst (a1)            ;teste mvt en X
          beq.s anm2
          bmi.s anm2
          sub #1,(a1)         ;decremente vitesse en X
          bne.s anm2
          clr d6              ;va bouger X
          bsr deplace
anm2:     lea 22(a1),a1
          tst (a1)            ;teste mvt en Y
          beq.s anm3
          bmi.s anm3
          sub #1,(a1)         ;decremente vitesse en Y
          bne.s anm3
          moveq #2,d6
          bsr deplace
; AUTRE ANIMATION/DEPLACEMENT?
anm3:     lea 22(a1),a1
          addq.l #8,a2
          dbra d7,anm0
          move.w #1,animflg   ;retabli les animations

fint:     rts

; ROUTINE AFFICHAGE SOURIS
showshow: move.l admouse(pc),a0
          move (a0),d1
          move 2(a0),d2
          cmp xmouse(pc),d1
          bne.s mst1
          cmp ymouse(pc),d2
          beq.s mst2
mst1:     move d1,xmouse
          move d2,ymouse
          add #640,d1
          add #400,d2
          add dxmouse(pc),d1
          add dymouse(pc),d2
          clr d0
          move form(pc),d3
          bsr geninter
          clr form
mst2:     move #1,intmouse
          rts

; ROUTINE DEPLACEMENT
deplace:  move mvtind(a1),(a1) ;repoke la vitesse
          move 4(a2,d6.w),d0
          add mvtdir(a1),d0    ;change les coordonnees du sprite
          move d0,4(a2,d6.w)
          add #1,(a2)          ;flag: doit activer
          bset #1,(a4)         ;flag pour le basic
          cmp mvtcond(a1),d0   ;teste la condition
          beq.s anm10a
          sub #1,mvtnbre(a1)   ;dernier mouvement?
          beq.s anm12
          rts
anm10a:   tst mvtbcle(a1)      ;realisee: on boucle?
          bne.s anm11a
anm11:    clr (a1)             ;non: arret mouvement
          rts
anm11a:   move.l mvtad(a1),a3  ;oui: raz du mouvement
          bra dinit
anm12:    move.l mvtad(a1),a3
          move mvtpos(a1),d0
          cmp mvtmax(a1),d0    ;derniere sequence de mouvements?
          bne.s anm13
          tst mvtbcle(a1)      ;OUI: boucle?
          beq.s anm11
dinit:    clr d0               ;entree lors d'initialisation d'un sprite
          move mvtpdeb(a1),d1  ;position de debut?
          beq.s anm13
          move d1,4(a2,d6.w)   ;si oui: la poke
anm13:    add d0,a3
          move (a3)+,d1
          move d1,mvtind(a1)
          move (a3)+,mvtdir(a1)
          move (a3)+,mvtnbre(a1)
          addq #6,d0
          move d0,mvtpos(a1)
          move d1,(a1)
anm14:    rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         Actualise: dessine tous les sprites qui doivent l'etre!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
actualise:lea tablact(pc),a0
          moveq #0,d4
          moveq #0,d5
act1:     tst (a0)
          bne.s act3
act2:     add #8,a0
          addq #1,d4
          cmp #nbanimes,d4
          bne.s act1
          rts
act3:     bpl.s act4            ;si >$8000, alors arreter le sprite!
          move d4,d0
          addq #1,d0
          or #$8000,d0
          bra.s act5
act4:     move d4,d0
          add #1,d0           ;decalage des sprites animes/autres!
          move actx(a0),d1
          move acty(a0),d2
          move actimage(a0),d3
          clr actimage(a0)
act5:     clr (a0)
          bset d0,d5          ;flag: a ete actualise pour REDRAW!
          bsr gensprite
          bra.s act2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                 REDUCTEUR D'IMAGE A YOURI BELGE-TCHENTKOZ
;
;                 (C) 1987 YouYou Software Internationnal
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
reduce:   lea params,a6
          move.w d1,(a6)+               ;X
          move.w d2,(a6)+               ;Y
          move.w d3,(a6)+               ;Tx
          move.w d4,(a6)+               ;Ty
          move.l a0,(a6)+               ;origine
          move.l a1,(a6)+               ;destination
          move.w mode,d0                ;resolution
          lea params,a6
          clr.l     d1                  ;
          clr.l     d7                  ;
          asl.w     #1,d0               ;
          move.w    (a6)+,d1            ; x in d1  }  for det_adr
          move.w    (a6)+,d2            ; y in d2  }  ( see this routine )
          bsr       det_adr             ; sein' is belevin'
          move.w    (a6)+,d1            ; length of frame  in pixels
          move.w    (a6)+,d7            ; height of frame  in pixels
          move.l    (a6)+,a0            ; wherefrom !
          move.l    (a6),a6             ; where to create slide
          add.l     d3,a6               ; add  d3 ( calculated in det_adr )
          lea       x_max,a3            ; X maximum+1: 320/low,640/high,med
          move.w    0(a3,d0.w),d3       ; ***** d3 = X maximum *****
          lea       y_max,a3            ; Y maximum : 199/low-med,399/high
          move.w    0(a3,d0.w),d4       ; ***** d4 = Y maximum *****
          clr.w     d6                  ; counter
          lea       tab_x,a3            ; table created in a3
          clr.w     (a3)+               ; first element is always zero
          clr.w     d2                  ; contains current X value for table
next_x:
          addq.w    #1,d6               ; next x
          cmp.w     d6,d3               ; last one ?
          beq       out_creat           ; yes, table created
          clr.l     d5                  ;
          move.w    d6,d5               ;
          mulu      d1,d5               ; X*length
          divu      d3,d5               ;
          cmp.w     d5,d2               ; same as last one ?
          beq       next_x              ; yes calculate next
          move.w    d6,(a3)+            ; no store value
          move.w    d5,d2               ; update d2 for next value comparison
          bra       next_x              ; calculate next

out_creat:
          move.l    a0,a1               ; saved  source_image address in a1
sav_dat:
          lea       sp8,a3              ;
          move.l    a6,(a3)             ; save start of slide
          lea       b_pline,a3          ;
          lea       sp6,a5              ;
          move.w    0(a3,d0.w),(a5)     ; d1 = bytes per line
          lea       col_len,a3          ;
          lea       sp4,a5              ;
          move.w    0(a3,d0.w),(a5)     ;
          lea       b_pb,a3             ; 8 for low,4 for med,2 for high
          lea       sp2,a5              ;
          move.w    0(a3,d0.w),(a5)     ;
          lea       sp0,a5              ;
          move.w    d7,(a5)             ; height saved

          lea       tab_x,a3            ; that table's start in a3
          move.w    #$ffff,d5           ; counter for Y
          move.w    #$ff,a2             ; same role as d2 in 1st loop
                                        ; initialized to ff so that
                                        ; first comparison may be false
          move.l    a3,a4               ;
          move.l    #15,d0              ;  to avoid comparison of d5
          bra       cal_new             ;  at first
next_y:
          move.l    a3,a4               ; restore start of tab_x in a4
          moveq     #15,d0              ; the famous point pointer
          clr.l     d7                  ;
          move.w    sp6,d7              ; bytes per line in d7
          add.l     sp8,d7              ; add b_pline to start on slide
          move.l    d7,sp8              ;
                                        ; -> on line downward on slide
                                        ;
          move.l     d7,a6              ; get that address in a6
cal_new:
          addq.w    #1,d5               ;
          cmp.w     d5,d4               ; remember: d4 = Y_max
          beq       all_done            ; exit if done !
no_need:
          clr.l     d7                  ; long cleared for used in divu
          move.w    d5,d7               ; Y in d7
          mulu      sp0,d7              ; Y*height
          divu      d4,d7               ; Y*height/Y_max
          cmp.w     d7,a2               ; if same Y compute a new one
          beq       cal_new             ;
          move.w    d7,a2               ; d7 is Y FOR ALL THAT LINE
          move.w    d5,d7
cal_adr:
          mulu      sp6,d7              ; d0 = Y*b_pline
          move.l    a1,a0               ; remember a1 is Logbase
          move.w    d7,a5               ; that move to insure high word cleared
          add.l     a5,a0               ; start of line in a0
          move.l    a0,a5               ; save it a5

;  d7 can now be used for adr of start of line's been computed

          move.w    #$ffff,d7           ; X counter 
continu:
          addq.w    #1,d7               ; next X
          cmp.w     d7,d1               ; last one ? (remember: d1=length)
          beq       next_y              ; yes,so new line
          move.l    a5,a0               ; no so start of line in a0
          clr.l     d2                  ;
          move.w    (a4)+,d2            ; d2 is X (a4 points to tab_x)
                                        ;
d_setcol:                               ; d_setcol for determines and
                                        ; sets color 
          moveq     #16,d3              ;
          divu      d3,d2               ; x/16
          swap      d2                  ; rest in low d2,quotient in high
          moveq     #15,d3              ;
          sub.w     d2,d3               ; d3=15-rest
          swap      d2                  ; get quotient back in low word
          mulu      sp2,d2              ; (x/16)*(v_plan*2)
          add.l     d2,a0               ;
;
; d2 can now be used for x useless now
;
          clr.l     d6                  ; bits counter
go_zou:
          move.w    (a0),d2             ;
          btst      d3,d2               ;
          beq       b_clr               ;
          move.w    (a6),d2             ;
          bset      d0,d2               ; remember: d0=point_pointer
          move.w    d2,(a6)
          bra       nxt_b
b_clr:                                  ; clear bit in (a6)
          move.w    (a6),d2             ;
          bclr      d0,d2               ;
          move.w    d2,(a6)             ;
nxt_b:
          addq.l    #2,a6               ;
          addq.l    #2,a0               ;
          addq.b    #1,d6               ;
          cmp.w     sp4,d6              ;
          bne       go_zou              ;
          asl.w     #1,d6               ; d6=(video_plans)*2
          sub.l     d6,a0               ;
          sub.l     d6,a6               ;

          subq.w    #1,d0               ;
          bmi       adj_d0              ;
          bra       continu             ;

adj_d0:
          moveq     #15,d0              ; re_init d0
          add.l     d6,a6               ; next 16 points bloc
          bra       continu             ;

all_done: clr.w d0                      ; pas d'erreur!!!
          rts                           ; end of routine

det_adr:
          lea       b_pline,a3          ; address of 'number-of-bytes-per-line'
                                        ; in a3
          clr.l     d3                  ; insures higher bits zeroed
          move.w    0(a3,d0.w),d3       ; get that number (see above) in d3
          mulu      d2,d3               ; y*(bytes_p_line)->d3
          lsr.w     #4,d1               ; x=x/16
          lea       b_pb,a3             ;
          move.w    0(a3,d0.w),d7       ; adjust X to number of bytes
          mulu      d7,d1               ; for 16 points colors encodin'
          add.w     d1,d3               ; d3=adj*(x/16)+y*b_pline
          rts
; erreur de coordonnees!!!
rederr:   move #1,d0
          rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         ZOOM X1,Y1,TX1,TY1,X3,Y3,TX2(a2),TY2(a3) / ecran (a0) to ecran (a1)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
zoom:     movem.l d3-d4/a2-a3,-(sp)
          lea zparams,a6
          exg d1,d5
          exg d2,d6
          add #640,d1
          add #400,d2
          bsr coords
          move.l a1,a2
          eor #$000f,d1       ;decalage de GAUCHE a DROITE
          move d1,zddest(a6)  ;decalage en X dest/cpt en d4
          move d0,d1
          bsr adecran
          move.l a2,a3        ;adresse de destination en A3
          move d5,d1
          move d6,d2
          add #640,d1
          add #400,d2
          bsr coords
          move.l a0,a2
          eor #$000f,d1       ;decalage de GAUCHE a DROITE
          move d1,zdor(a6)    ;decalage en X dest/cpt en d3
          move d0,d1
          bsr adecran         ;adresse origine en A2
          move nbplan,d5
          move motligne,d0
          mulu d5,d0
          lsl #1,d0
          move d0,zpligne(a6) ;passage d'une ligne a l'autre
          move d5,a5
          subq #1,a5          ;indice nbplans: A5
          lsl #1,d5
          move d5,a4          ;passage au mot suivant en A4
          movem.l (sp)+,d0-d1/a0-a1
          move d0,d6          ;indice taille en X origine en A6: zzxmin!
          move d1,zty(a6)     ;compteur taille en Y
          move d1,zzymin(a6)  ;zzymin!
          move a0,d7          ;zzxmax
          move a1,zzymax(a6)  ;zzymax
          move a1,zzycpt(a6)  ;init du compteur ZOOM Y
; nouveau pixel agrandi /
; nouvelle ligne de pixel
zoom2:    move d6,d2
          move zdor(a6),d3
          move zddest(a6),d4
          move.l a2,a0
          move.l a3,a1
          move d7,d1          ;cpt zoom en X au MAXI
; nouveau pixel
zoom4:    move a5,d5          ;cpt nbplans
          movem.l a0-a1,-(sp)
zoom5:    move (a0)+,d0
          btst d3,d0
          beq.s zoom6
          move (a1),d0
          bset d4,d0
          bra.s zoom7
zoom6:    move (a1),d0
          bclr d4,d0
zoom7:    move d0,(a1)+
          dbra d5,zoom5       ;encore un plan?
          movem.l (sp)+,a0-a1
          sub d6,d1           ;super compteur pixel zoom!
          bcs.s zoom8
          dbra d4,zoom4       ;passe au suivant
          add a4,a1           ;plus nbplan*2 (passe au mot suivant)
          moveq #15,d4
          bra.s zoom4
zoom8:    add d7,d1           ;replace le compteur
          subq #1,d4          ;repointe au suivant
          bpl.s zoom9
          add a4,a1
          moveq #15,d4 
zoom9:    subq #1,d2
          beq.s zoom10          ;encore un pixel origine
          dbra d3,zoom4       ;OUI: passe au suivant
          add a4,a0
          moveq #15,d3
          bra.s zoom4
zoom10:   add zpligne(a6),a3  ;passe a la ligne zoom suivante
          move zzymin(a6),d0  ;super compteur en Y
          sub d0,zzycpt(a6)
          bcc.s zoom2
          move zzymax(a6),d0
          add d0,zzycpt(a6)
          add zpligne(a6),a2  ;ligne origine suivante
          subq #1,zty(a6)     ;encore une ligne origine?
          bne.s zoom2
          clr.l d0            ;fini! OUF
          rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         APPEAR a0 TO a1,d0:  0<d1<80
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
appear:   clr intmouse
          sub.l a5,a5                   ;compteurs A5/A6
          sub.l a6,a6
          tst.l d1                      ;verifie, parce que cette
          beq appfin                    ;routine est PLANTANTE!
          cmp.l #80,d1
          bhi appfin
          lea tappear,a2
          lsl #1,d1
          move.w -2(a2,d1.w),a5
          move mode,d0
          lsl #1,d0
          lea x_max,a4
          move.w 0(a4,d0.w),d7
          move.w d7,d1                  ;320/640/640: D7
          mulu 6(a4,d0.w),d1
          move.l d1,a4                  ;64000/128000/256000: A4
          move.w motligne,d6
          mulu nbplan,d6
          lsl #1,d6                     ;d6=80/160/160
          move nbplan,d5
          move d5,d4
          lsl #1,d4                     ;d4: passage d'un mot a l'autre
          subq #1,d5                    ;indice nbplans en d5

; affiche le point selectionn‚
app1:     move.l a0,a2                  ;adresse fraiches
          move.l a1,a3
          move.l a6,d0                  ;numero du point
          divu d7,d0                    ;divise par la taille d'une ligne
          move d0,d1
          mulu d6,d1                    ;position en Y: d2
          add d1,a2
          add d1,a3
          swap d0                       ;reste= decalage sur une ligne!
          move d0,d3
          and #$f,d3
          eor.b #$f,d3                  ;decalage 0-15 en X: D3
          lsr #4,d0                     ;/16
          mulu d4,d0                    ;pointe le bon mot dans la ligne
          add d0,a2                     ;pointe dans l'ecran 1
          add d0,a3                     ;pointe dans l'ecran 2
; boucle d'affichage
          move d5,d2                    ;nbplans
app3:     move.w (a2)+,d0
          move.w (a3),d1
          btst d3,d0
          beq.s app4
          bset d3,d1
          bra.s app5
app4:     bclr d3,d1
app5:     move.w d1,(a3)+
          dbra d2,app3                  ;autre plan?
; addition et test si sort de la boucle
          add.l a5,a6                   ;addition du decalage
          cmp.l a4,a6                   ;si < maximum
          bcs.s app1                    ;OK, va afficher le point
          beq.s appfin                  ;si =: c'est fini!
          sub.l a4,a6                   ;remet dans l'ecran...
          bra.s app1
; fini!
appfin:   move #1,intmouse
          rts

; adresse de chargement des sprites
even
finspr:   equ *

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          end





