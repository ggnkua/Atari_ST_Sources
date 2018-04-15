	opt d+
	pea end+1000
	move.w #$20,-(a7)
	trap #1
	addq.l #2,a7
	bra blit_it
*
* ADRESSE DE BASE DU BLITTER
*
BLITTER        equ       $FF8A00
*
* DECALAGES DES REGISTRES DU BLITTER
*
demiteinte     equ       0         * Matrice demi-teinte *
Src_Xinc       equ       32        * Incr‚ment X source *
Src_Yinc       equ       34        * Incr‚ment Y source *
Src_Addr       equ       36        * Adresse bloc source *
Endmask1       equ       40        * Masque final 1 *
Endmask2       equ       42        * Masque final 2 *
Endmask3       equ       44        * Masque final 3 *
Dst_Xinc       equ       46        * Incr‚ment X destination *
Dst_Yinc       equ       48        * Incr‚ment Y destination *
Dst_Addr       equ       50        * Adresse bloc destination *
largeur        equ       54        * Largeur de bloc *
hauteur        equ       56        * auteur de bloc *
HOP            equ       58        * Type op‚ration demi-teinte *
OP             equ       59        * Type op‚ration logique *
Line_Num       equ       60        * index de ligne dans matrice *
Oblique        equ       61        * Oblique *
*
* DRAPEAUX DE REGISTRES DU BLITTER
*
fHOP_Source   	equ       1
fHOP_demiteinte  	equ       0
*
fObliqueFXSR      	equ       7
fObliqueNFSR      	equ       6
*
fLineBusy      	equ       7
fLineHog       	equ       6
fLineSmudge    	equ       5
*
* MASQUES DE REGISTRES DU BLITTER
*
mHOP_Source    	equ       $02
mHOP_demiteinte  	equ       $01
*
mObliqueFXSR      	equ       $80
mObliqueNFSR      	equ       $40
*
mLineBusy      	equ       $80
mLineHog       	equ       $40
mLineSmudge    	equ       $20
*
*                   DONNEES DES MASQUES FINAUX
*
* Ces tables sont r‚f‚renc‚es par des instructions d'adressage 
* relatives au compteur de programme. Aussi les noms de ces
* tables doivent-ils se trouver dans les 128 octets des 
* instructions de r‚f‚rence.  Amen.
*
* 0: Destination   1: Source
* << Inverser donn‚es du masque de donn‚es droite >>
*
lf_endmask
     dc.w      $FFFF
*
rt_endmask
     dc.w      $7FFF
     dc.w      $3FFF
     dc.w      $1FFF
     dc.w      $0FFF
     dc.w      $07FF
     dc.w      $03FF
     dc.w      $01FF
     dc.w      $00FF
     dc.w      $007F
     dc.w      $003F
     dc.w      $001F
     dc.w      $000F
     dc.w      $0007
     dc.w      $0003
     dc.w      $0001
     dc.w      $0000
*
* Titre:       BLiT_iT
*
* But:         Transf‚rer un bloc de pixels situ‚s … une position
*              arbitraire  X,Y  dans la forme m‚moire source vers
*              une  autre  position  arbitraire X,Y dans la forme
*              m‚moire  destination  en utilisant le mode REPLACE
*              (op‚ration logique 3).
*              Les  rectangles  source  et destination ne doivent 
*              pas se recouvrir.
*
* Entr‚es:
*              a4:  pointeur vers un bloc de param‚tres d'entr‚e
*                   de 34 octets.
*
* Note:        Cette  routine  doit  ˆtre ex‚cut‚e en mode super-
*              viseur  car  un accŠs vers des registres mat‚riels
*              est effectu‚ dans une r‚gion prot‚g‚e de m‚moire.
*
*
*    D‚calages du Bloc de ParamŠtres d'entr‚e
*
SRC_BASE       equ       0; Adresse base du bloc source
SRC_NXWD       equ       4; D‚calage entre mots dans plan source
SRC_NXLN       equ       6; Largeur du bloc source
SRC_NXPL       equ       8; D‚calage entre plans de la source
SRC_XMIN       equ      10; X minimum rectangle source
SRC_YMIN       equ      12; Y minimum rectangle source
*
DST_BASE       equ      14; Adresse base du bloc destination
DST_NXWD       equ      18; D‚calage entre mots plan destination
DST_NXLN       equ      20; Largeur du bloc destination
DST_NXPL       equ      22; D‚calage entre plans destination
DST_XMIN       equ      24; X minimum rectangle destination
DST_YMIN       equ      26; Y minimum rectangle destination
*
WIDTH          equ      28; Largeur du rectangle … transf‚rer
HEIGHT         equ      30; Hauteur du rectangle … transf‚rer
PLANES         equ      32; Nombre de plans … transf‚rer
*
blit_it:
*
     lea       BLITTER,a5       ; a5-> registre bloc BLITTER
*
* Calcule les coordonn‚es maximales horizontales … partir des
* coordonn‚es minimales horizontales et de la largeur
*
     move.w    WIDTH(a4),d6
     subq.w    #1,d6            ; d6 <- largeur - 1

     move.w    SRC_XMIN(a4),d0  ; d0 <- X minimum source
     move.w    d0,d1            ; d1 <- X minimal source
     add.w     d6,d1            ;  + largeur du bloc 

     move.w    DST_XMIN(a4),d2  ; d2 <- X minimum destination
     move.w    d2,d3            ; d3 <- X minimal destination
     add.w     d6,d3            ;  + largeur du bloc
*
* Les masques de fin sont d‚duits de l'origine horizontale de la
* source modulo 16 et de l'origine horizontale de la destination
* modulo 16.
*
     moveq     #$0F,d6          ; d6 <- masque modulo 16

     move.w    d2,d4            ; d4 <- DST_XMIN
     and.w     d6,d4            ; d4 <- DST_XMIN modulo 16
     add.w     d4,d4            ; d4 <- d‚calage gauche
     move.w    lf_endmask(pc,d4.w),d4; d4 <- masque fin gauche

     move.w    d3,d5            ; d5 <- DST_XMAX
     and.w     d6,d5            ; d5 <- DST_XMAX modulo 16
     add.w     d5,d5            ; d5 <- d‚calage droite 
     move.w    rt_endmask(pc,d5.w),d5; d5 <- masque fin droite
     not.w     d5               ; d5 <- masque fin droite
*
* La valeur d'Oblique est ‚gale … (Xmin destination modulo 16
* - Xmin source modulo 16) && 0x000F. Trois discriminants sont
* utilis‚s pour d‚terminer les ‚tats des drapeaux FXSR et NFSR:
*
*    bit 0     0: Xmin source mod 16 <= Xmin destination mod 16
*              1: Xmin source mod 16 > Xmin destination mod 16
*
*    bit 1     0: SrcXmax/16-SrcXmin/16 <> DstXmax/16-DstXmin/16
*                     largeur source         largeur destination
*              1: SrcXmax/16-SrcXmin/16 == DstXmax/16-DstXmin/16
*
*    bit 2     0: largeur destination multi-mots
*              1: largeur destination = un seul mot
*
*    Ces drapeaux fournissent le d‚calage dans la table d'Oblique
*    supportant les drapeaux d'‚tat FXSR et NFSR pour des aligne-
*    ments donn‚s de la source et de la destination.
*

     move.w    d2,d7            ; d7 <- Dst Xmin
     and.w     d6,d7            ; d7 <- Dst Xmin modulo 16
     and.w     d0,d6            ; d6 <- Src Xmin modulo 16
     sub.w     d6,d7            ; d7 <- Dst Xmin modulo 16
                                ;  - Src Xmin modulo 16
     clr.w     d6               ; d6 <- index base table drapeaux
     addx.w    d6,d6            ; d6[bit 0] <- drapeau d'aligne-
                                ; ment dans le mot
     lsr.w     #4,d0            ; d0 = d‚calage hor. vers srcXmin
     lsr.w     #4,d1            ; d1 = d‚calage vert.vers srcXmax
     sub.w     d0,d1            ; d1 <- largeur source - 1

     lsr.w     #4,d2            ; d2 <- d‚calage mot vers dstXmin
     lsr.w     #4,d3            ; d3 <- d‚calage mot vers dstXmax
     sub.w     d2,d3            ; d3 <- largeur destination - 1
     bne       set_endmasks     ; deuxiŠme discriminant = un mot
                                ; de destination
*
* Lorsque la destination n'a qu'un mot de large, les masques de
* d‚but et de fin sont fusionn‚s pour cr‚er le Masque Final 1.
* Les autres masques finaux seront ignor‚s par le BLiTTER.
*
     and.w     d5,d4            ; d4 <- masque de fin mot simple
     addq.w    #4,d6            ; d6[bit 2]:1 => un mot dest.

set_endmasks:

     move.w    d4,Endmask1(a5)  ; masque final gauche
     move.w    #$FFFF,Endmask2(a5); masque final centre
     move.w    d5,Endmask3(a5)  ; masque final droite

     cmp.w     d1,d3            ; dernier discriminant correspond
     bne       set_count        ; ‚galit‚ largeurs src et dst

     addq.w    #2,d6            ; d6[bit 1]:1 => largeurs ‚gales

set_count:

     move.w    d3,d4
     addq.w    #1,d4            ; d4 <- nombre mots ligne dest.
     move.w    d4,largeur(a5)   ; place valeur dans BLiTTER

* Calcule l'adresse de d‚part de la Source:
*
*     Adresse du Bloc Source +
*     ( Ymin source * Largeur Bloc source ) +
*    (( Xmin source / 16) * Xinc Source)

     move.l    SRC_BASE(a4),a0  ; a0 <- d‚but bloc source
     move.w    SRC_YMIN(a4),d4  ; d4 <- d‚calage en lignes SrcYmin
     move.w    SRC_NXLN(a4),d5  ; d5 <- longueur ligne source
     mulu      d5,d4            ; d4 <- d‚calage en octets jusque
                                ; (0,Ymin)
     add.l     d4,a0            ; a0 -> (0,Ymin)

     move.w    SRC_NXWD(a4),d4  ; d4<- d‚calage entre mots cons‚-
     move.w    d4,Src_Xinc(a5)  ;    cutifs dans un plan source

     mulu      d4,d0            ; d0<- d‚calage mot contenant Xmin
     add.l     d0,a0            ; a0-> 1er mot source(Xmin, Ymin)

* Src_Yinc est le d‚calage en octets entre de dernier mot d'une
* ligne de la source et le premier mot de la ligne suivante.

     mulu      d4,d1            ; d1<- taille ligne srce en octets
     sub.w     d1,d5            ; d5 <- valeur ajout‚e au pointeur
     move.w    d5,Src_Yinc(a5)  ;    de fin de ligne pour pointer
                                ;    le d‚but de ligne suivante
*
* Calcule l'adresse de d‚part de la destination:
*
*     Adresse du Bloc destination +
*     ( Ymin destination * Largeur Bloc destination ) +
*    (( Xmin destination / 16) * Xinc destination)

     move.l    DST_BASE(a4),a1  ; a1 <- d‚but bloc destination
     move.w    DST_YMIN(a4),d4  ; d4 <- d‚calage en lignes DstYmin
     move.w    DST_NXLN(a4),d5  ; d5 <- longueur ligne destination
     mulu      d5,d4            ; d4 <- d‚calage en octets jusque
                                ; (0, Ymin)
     add.l     d4,a1            ; a1 -> (0,Ymin)

     move.w    DST_NXWD(a4),d4  ; d4<- d‚calage entre mots cons‚-
     move.w    d4,Dst_Xinc(a5)  ;    cutifs dans un plan dest.

     mulu      d4,d2            ; d2<- d‚calage mot contenant Xmin
     add.l     d2,a1            ; a1-> 1er mot dest.(Xmin, Ymin)

* Dst_Yinc est le d‚calage en octets entre de dernier mot d'une
* ligne de la destination et le premier mot de la ligne suivante.

     mulu      d4,d3            ; d3<- taille ligne DSTe en octets
     sub.w     d3,d5            ; d5 <- valeur ajout‚e au pointeur
     move.w    d5,Dst_Yinc(a5)  ;de fin de ligne pour pointer
                                ;le d‚but de ligne suivante
*
* Le quartet bas de la diff‚rence entre l'alignement de la source
* et de la destination constitue la valeur Oblique. Utilisation 
* du drapeau d'index d'Oblique pour r‚f‚rencer les ‚tats de FXSR
* et NFSR dans la table des drapeaux d'Oblique
*
     and.b     #$0F,d7          	       ; d7 <- compte Oblique de base
     or.b      Oblique_flags(pc,d6.w),d7  ; d7 <- drapeaux n‚cessaires
     move.b    d7,Oblique(a5)      	; charge registre Oblique

     move.b    #mHOP_Source,HOP(a5)	; HOP fix‚: source seule
     move.b    #3,OP(a5)        		; OP logique = mode REPLACE

     lea       Line_Num(a5),a2  		; registre num‚ro de ligne
     move.b    #fLineBusy,d2    		; drapeau ligne Busy
     move.w    PLANES(a4),d7    		; d7 <- controleur de plan
     bsr       begin


*              Le placement des drapeaux Oblique
*
*
* Qualificateurs    Actions  Direction transfert: Gauche->Droite
*
* ‚gal Sx&F>
* larg.Dx&F FXSR NFSR
*
*  0    0    0    1 |..ssssssssssssss|ssssssssssssss..|
*                   |......dddddddddd|dddddddddddddddd|dd......
*
*  0    1    1    0 |......ssssssssss|ssssssssssssssss|ss......
*                   |..dddddddddddddd|dddddddddddddd..|
*
*  1    0    0    0 |..ssssssssssssss|ssssssssssssss..|
*                   |...ddddddddddddd|ddddddddddddddd.|
*
*  1    1    1    1 |...sssssssssssss|sssssssssssssss.|
*                   |..dddddddddddddd|dddddddddddddd..|
*


Oblique_flags:

     dc.b      mObliqueNFSR        ; Larg.Source < larg. Destination
     dc.b      mObliqueFXSR        ; Larg. Source > larg. Destination
     dc.b      0                   ; Largeur=d‚calage droite source
     dc.b      mObliqueNFSR+mObliqueFXSR ; Largeur=d‚calage gche source

* Lorsque la largeur de la destination est un simple mot

     dc.b      0                ; largeur source = 0 mot
     dc.b      mObliqueFXSR     ; largeur source de deux mots
     dc.b      0                ; pas de drapeau d'Oblique si la
     dc.b      0                ; largeur de source et de dest.
                                ; sont ‚gales … un mot.


next_plane:

     move.l    a0,Src_Addr(a5)  		; pointeur Source pour ce plan
     move.l    a1,Dst_Addr(a5)  		; pointeur Dest. pour ce plan
     move.w    HEIGHT(a4),hauteur(a5)	; compteur de lignes

     move.b    #mLineBusy,(a2)  		; <<<d‚marrage du BLiTTER>>>

     add.w     SRC_NXPL(a4),a0  		; a0-> d‚but prochain plan srce
     add.w     DST_NXPL(a4),a1  		; a1-> d‚but prochain plan dest.

*
* Le BLITTER  opŠre  g‚n‚ralement avec le drapeau HOG … 0. Dans ce
* mode,  le BLITTER et l'unit‚ centrale du ST se partagent ‚quita-
* blement  le  bus,  chacun travaillant durant 64 cycles d'horloge 
* tandis  que l'autre est stopp‚. Ce mode permet aux interruptions
* d'ˆtre prises en compte par le 68000 lorsqu'un transfert de bloc
* large  est effectu‚. La contrepartie de ce mode op‚ratoire est 
* que les transferts de blocs effectu‚s dans ce mode prennent deux
* fois plus de temps que dans l'autre mode (HOG … 1).
* 90% des performances du mode HOG peuvent cependant ˆtre obtenues
* si l'on  adopte  une  proc dure  de  red‚marrage ultra-rapide du
* blitter.  Lorsque le contr“le est rendu au 68000 par le blitter,
* celui-ci  r‚initialise imm‚diatement le drapeau BUSY, permettant
* au  Blitter  de  red‚marrer  aprŠs seulement 7 cycles horlogeau
* lieu  des 64 cycles normaux. Les interruptions en attente seront
* trait‚es  avant  que  le code de red‚marrage prenne effet. Si le
* drapeau BUSY est r‚initialis‚ lorsque le compteur de ligne est …
* z‚ro, le drapeau restera … 0, indiquant la fin de l'op‚ration de
* transfert et la non n‚cessit‚ de red‚marrer le Blitter.
*
* (Les  routines de traitement d'interruption doivent obligatoire-
* ment stopper le BLITTER lors de l'ex‚cution de parties critiques
* par  mise  … 0 du drapeau BUSY. L'‚tat ant‚rieur du drapeau BUSY
* devra ensuite ˆtre restaur‚, avant la fin de la routine de trai-
* tement d'interruption.)


restart:
     
     bset.b    d2,(a2)          ; red‚marre le Blitter +  Test BUSY
     nop                        ; pour laisser du temps aux inter.
     bne       restart          ; red‚marrage du Blitter si le
*                               ; drapeau n'‚tait pas … 0.

begin:

     dbra      d7,next_plane    ; plan suivant
     rts
end