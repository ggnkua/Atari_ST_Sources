	opt d+
start:
	move.w #$00,-(sp)
	move.w #$20,-(sp)
	trap #01
	lea 4(sp),sp	
	;move.b #12,$fffc02
	bclr.b #0,$484
	move.w #2,-(a7)
	trap #14
	addq.l #2,a7
	move.l d0,ecran
	move.w #0,-(a7)
	move.l #$f8000,-(a7)
	move.l #$f8000,-(a7)
	move.w #5,-(a7)
	trap #14
	add.l #12,a7
	lea	palette,a0
	lea	$ff8240,a1
	rept 8
	move.l (a0)+,(a1)+
	endr
	move.l	#prog,$4d2
cont	nop
	cmp.b #1,$fffc02
	bne cont
	move.l	#0,$4d2
	clr.w -(a7)
	trap #1

prog 	lea	$f8000+160*100,a1
	move.w	#160*8,d0
cler	move.l #0,(a1)+
	dbf d0,cler
	
	
	move.w #$242,$ff8240
	add.w #1,x
	cmp.w #320,x
	bne	ss
	move.w #0,x
ss	
	;add.w #1,y
	;cmp.w #199,y
	;ble	ss1
	;move.w #0,y
ss1
	movem.l a0-a6/d0-d7,-(a7)
	bsr blit_it
	movem.l (a7)+,a0-a6/d0-d7
	move.w #0,$ff8240
	rts

BLITTER        equ       $FF8A00
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
fHOP_Source   	equ       1
fHOP_demiteinte  	equ       0
fObliqueFXSR      	equ       7
fObliqueNFSR      	equ       6
fLineBusy      	equ       7
fLineHog       	equ       6
fLineSmudge    	equ       5
mHOP_Source    	equ       $02
mHOP_demiteinte  	equ       $01
mObliqueFXSR      	equ       $80
mObliqueNFSR      	equ       $40
mLineBusy      	equ       $80
mLineHog       	equ       $40
mLineSmudge    	equ       $20
lf_endmask
     dc.w      $FFFF
*
rt_endmask
     dc.w      $7FFF			*01111111 11111111
     dc.w      $3FFF			*00111111 11111111
     dc.w      $1FFF			*00011111 11111111
     dc.w      $0FFF			*00001111 11111111
     dc.w      $07FF			*00000111 11111111
     dc.w      $03FF	 		*00000011 11111111
     dc.w      $01FF			*00000001 11111111
     dc.w      $00FF			*00000000 11111111
     dc.w      $007F			*00000000 01111111
     dc.w      $003F			*00000000 00111111
     dc.w      $001F			*00000000 00011111
     dc.w      $000F			*00000000 00001111
     dc.w      $0007			*00000000 00000111
     dc.w      $0003			*00000000 00000011
     dc.w      $0001			*00000000 00000001
     dc.w      $0000			*00000000 00000000


blit_it:
     lea       BLITTER,a5       ; a5-> registre bloc BLITTER
     lea	 para,a4
     move.w    WIDTH(a4),d6
     subq.w    #1,d6            ; d6 <- largeur - 1

     move.w    SRC_XMIN(a4),d0  ; d0 <- X minimum source
     move.w    d0,d1            ; d1 <- X minimal source
     add.w     d6,d1            ;  + largeur du bloc 

     move.w    DST_XMIN(a4),d2  ; d2 <- X minimum destination
     move.w    d2,d3            ; d3 <- X minimal destination
     add.w     d6,d3            ;  + largeur du bloc
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


     mulu      d4,d1            ; d1<- taille ligne srce en octets
     sub.w     d1,d5            ; d5 <- valeur ajout‚e au pointeur
     move.w    d5,Src_Yinc(a5)  ;    de fin de ligne pour pointer
                                ;    le d‚but de ligne suivante

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


     mulu      d4,d3            ; d3<- taille ligne DSTe en octets
     sub.w     d3,d5            ; d5 <- valeur ajout‚e au pointeur
     move.w    d5,Dst_Yinc(a5)  ;de fin de ligne pour pointer
                                ;le d‚but de ligne suivante
     and.b     #$0F,d7          	       ; d7 <- compte Oblique de base
     or.b      Oblique_flags(pc,d6.w),d7  ; d7 <- drapeaux n‚cessaires
     move.b    d7,Oblique(a5)      	; charge registre Oblique

     move.b    #mHOP_Source,HOP(a5)	; HOP fix‚: source seule
     move.b    #3,OP(a5)        		; OP logique = mode REPLACE

     lea       Line_Num(a5),a2  		; registre num‚ro de ligne
     move.b    #fLineBusy,d2    		; drapeau ligne Busy
     move.w    PLANES(a4),d7    		; d7 <- controleur de plan
     bra       begin



Oblique_flags:

     dc.b      mObliqueNFSR        ; Larg.Source < larg. Destination
     dc.b      mObliqueFXSR        ; Larg. Source > larg. Destination
     dc.b      0                   ; Largeur=d‚calage droite source
     dc.b      mObliqueNFSR+mObliqueFXSR ; Largeur=d‚calage gche source


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



restart:
     
     bset.b    d2,(a2)          ; red‚marre le Blitter +  Test BUSY
     nop                        ; pour laisser du temps aux inter.
     bne       restart          ; red‚marrage du Blitter si le
*                               ; drapeau n'‚tait pas … 0.

begin:

     dbra      d7,next_plane    ; plan suivant
     rts
ecran	dc.l 0
sprite	include	c:\dessin\copyb1.s
	even
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

para	dc.l	sprite
	dc.w	8
	dc.w   32
	dc.w   2
	dc.w  	0
	dc.w	0

	dc.l	$f8000
	dc.w	8
	dc.w	160
	dc.w	2
x	dc.w	0
y	dc.w	100

	dc.w	31
	dc.w	31
	dc.w	4

palette dc.w $0,$777,$666,$555,$444,$333,$222,$111,$766,$755,$643,$210,$020,$710,$140,$557

end