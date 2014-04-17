/************************************************************************/
/*                                                                      */
/*            CREATE BY ATARI FRANCE                                    */
/*                 FOR DEVELOPERS                                       */
/*                 THIS IS A DEMONSTRATION NEW HSCROLL                  */
/*                                                                      */
/*                 THIS IS PROGRAMMING IN MADMAC                        */

/************************************************************************/

NBAREA = 10        ; 10 zones
NBLIG  = 20        ; de 20 lignes

vblvec   = $70
ikbdvec  = $118
hblvec   = $120

vcounthi = $FFFF8205
vcountmed = $FFFF8207
vcountlo = $FFFF8209
linewid = $FFFF820F
palette = $FFFF8240
hscroll = $FFFF8265

MFP = $FFFFFA01

    .text
start:   movea.l a7,a5
    movea.l #mystack,a7
    movea.l 4(a5),a5
    move.l    $C(a5),d0
    add.l     $14(a5),d0
    add.l     $1C(a5),d0
    add.l     #$100,d0
    move.l    d0,d4
    move.l    d0,-(a7)
    move.l    a5,-(a7)
    clr.w     -(a7)
    move.w    #$4A,-(a7)
    trap #1
    adda.w    #$C,a7

; Passe en mode superviseur
    clr.l     -(a7)
    move.w    #$20,-(a7)
    trap #1
    addq.w    #6,a7
    move.l    d0,-(a7)

; Lit le premier fichier neo
    move.w    #$2F,-(a7)
    trap #1
    addq.w    #2,a7
    movea.l d0,a4
    adda.w    #$1E,a4
    move.w    #0,-(a7)
    move.l    #neofile,-(a7)
    move.w    #$4E,-(a7)
    trap #1
    addq.w    #8,a7
    tst.w     d0
    bmi  abort
    move.w    #0,-(a7)
    move.l    a4,-(a7)
    move.w    #$3D,-(a7)
    trap #1
    addq.w    #8,a7
    tst.w     d0
    bmi  abort
    move.w    d0,handle

; Et charge le dans neobuff
    move.l    #neobuff,-(a7)
    move.l    #32128,-(a7)
    move.w    d0,-(a7)
    move.w    #$3F,-(a7)
    trap #1
    adda.w    #$C,a7
    tst.l     d0
    bmi  abort
    move.w    handle,-(a7)
    move.w    #$3E,-(a7)
    trap #1
    addq.w    #4,a7
    tst.w     d0
    bmi  abort

; Passe en basse r‚solution et sauve l'adresse de base
    move.b    $FFFF8260,Oldres
    clr.b     $FFFF8260
    clr.l     -(SP)
    move.b    $FFFF8201,1(SP)
    move.b    $FFFF8203,2(SP)
    move.b    $FFFF820D,3(SP)
    move.l    (SP)+,Oldbase

; Initialise la palette de couleur tout en sauvant l'ancienne
    lea  neobuff+4,a2
    lea  palette,a0
    lea  oldpal,a1
    move.w    #16-1,d0
.ploop:  move.w    (a0),(a1)+
    move.w    (a2)+,(a0)+
    dbf  d0,.ploop

; double chaque ligne d'affichage dans bigbuff
    move.w    #160,d0
    lea  bigbuff,a0
    lea  neobuff+128,a1
    move.w    #200-1,d2
.linlp:  move.w    #40-1,d1
.dublp:  move.l    (a1),0(a0,d0)
    move.l    (a1)+,(a0)+
    dbf  d1,.dublp
    adda.w    d0,a0
    dbf  d2,.linlp

; Initialise les descripteurs des 10 zones
    lea  baseaddr,a0    ; adresse de base
    lea  xoffset,a1     ; offset en pixel
    lea  bigbuff,a2
    move.w    #NBAREA-1,d0   ; 10 zones
.strlp:  move.w    #0,(a1)+  ; pas de d‚calage pour commencer
    move.l    a2,(a0)+  ; adresse de d‚part
    adda.w    #320*NBLIG,a2  ; zone suivante
    dbf  d0,.strlp

; Inhibe le MFP, ne garde que le timer B
    lea  MFP,A0
    movep.w   6(A0),D0
    move.w    D0,savMFP
    move.w    #$0100,D0
    movep.w   D0,6(A0)
    
; D‚tourne le clavier, la vbl et le timer B
    move.l    ikbdvec,oldikbd+2
    move.l    #ikbd,ikbdvec
    move.l    vblvec,oldvbl+2
    move.l    #vbl,vblvec
    move.l    #hbl,hblvec
    bset.b    #0,MFP+18
    bset.b    #0,MFP+6

; Attend quelques temps pour sortir
    move.l    #10000000,D0
.wait:   subq.l    #1,D0
    bpl.s     .wait

; Stoppe le timer B          
    bclr.b    #0,MFP+6
    bclr.b    #0,MFP+18

; restaure l'‚tat du MFP
    lea  MFP,A0
    move.w    savMFP,D0
    movep.w   D0,6(A0)
    
; Remet l'IT clavier en ordre
    move.l    oldikbd+2,ikbdvec
    move.l    oldvbl+2,vblvec

; Remet l'heure en ordre 
    move.w    #$17,-(a7)     ;gettime
    trap #$E       ;XBIOS
    addq.w    #2,a7
    move.l    d0,vbltemp
    move.w    d0,-(a7)
    move.w    #$2D,-(a7)     ;Tsettime
    trap #1        ;GEMDOS
    addq.w    #4,a7
    move.w    vbltemp,-(a7)
    move.w    #$2B,-(a7)     ;Tsetdate
    trap #1        ;GEMDOS
    addq.w    #4,a7

; restaure la palette de couleurs
    lea  oldpal,a0
    lea  palette,a1
    move.w    #16-1,d0
.unplp:  move.w    (a0)+,(a1)+
    dbf  d0,.unplp

; Restaure l'adresse de base, la largeur d'‚cran et le shift
    move.b    Oldres,$FFFF8260
    move.l    Oldbase,-(SP)
    move.b    1(SP),$FFFF8201
    move.b    2(SP),$FFFF8203
    move.b    3(SP),$FFFF820D
    addq.l    #4,SP
    clr.b     hscroll
    clr.b     linewid

abort:   move.w    #$20,-(a7)     ;Super
    trap #1        ;GEMDOS
    addq.w    #6,a7
    clr.w     -(a7)
    trap #1
    illegal

; VBL d'initialisation
;   -- Construction de la liste d'affichage
;   -- Cette liste est compos‚e de long dont l'octet fort
;   -- contient le d‚calage dans le mot (0..15)
;   -- et l'adresse de la zone sur les 3 octets qui restent
vbl:     movem.l d0-d2/a0-a2,-(a7)

    lea  video,a0  ; liste d'affichage => hbl
    lea  xoffset,a1     ; liste des d‚calages
    lea  baseaddr,a2    ; liste des adresses d'‚cran

    moveq     #1,D2
    move.w    #NBAREA-1,d1   ; 10 r‚gions
.reglp:  move.w    (a1),d0        ; d‚calage
    btst.l    #0,d1
    bne  .odd
    add.w     D2,d0          ; pair on incr‚mente
    cmp.w     #320,d0        ; teste la limite sup‚rieure
    blt  .join
    sub.w     #320,D0
    bra  .join

.odd:    sub.w     D2,d0          ; impair on d‚cr‚mente
    bge  .join
    add.w     #320,D0

.join:   move.w    d0,(a1)        ; sauve la nouvelle valeur
    asr.w     #1,d0
    and.l     #$FFF8,d0 ; offset en mots
    add.l     (a2)+,d0  ; D0 = position dans la r‚gion
    move.l    d0,(a0)

    move.w    (a1)+,d0
    and.w     #$F,d0         ; D‚calage en bits dans lle mot
    move.b    d0,(a0)

    addq.w    #1,D2
    addq.l    #4,a0          ; r‚gion suivante
    dbf  d1,.reglp

; Initialise l'adresse de base pour la premiŠre r‚gion
    lea  video,a0  ; Liste d'affichage
    move.b    (a0)+,d0  ; d‚calage … appliquer
    move.b    d0,hscroll
    move.b    (a0)+,vcounthi
    move.b    (a0)+,vcountmed
    move.b    (a0)+,vcountlo

; Initialise la largeur de l'‚cran
    move.w    #80,d1         ; stride normal pour un d‚calage nul
    tst.b     d0
    beq.s     .zero
    subq.w    #4,d1          ; On retranche 4 mots
.zero:   move.b    d1,linewid

; Pr‚pare le terrain pour la 1er HBL
    move.l    (a0)+,d0
    rol.l     #8,d0
    move.l    d0,videodat
    move.l    a0,videoptr

; Active la HBL
    clr.b     MFP+26         ; Stoppe le timer B
        move.b     #NBLIG,MFP+32  ; 20 lignes
    move.b    #8,MFP+26 ; en event count mode

    movem.l (a7)+,d0-d2/a0-a2
oldvbl:  jmp  0.l

ikbd:    move.w    d0,-(a7)
    move sr,d0
    and.w     #$F8FF,d0
    or.w #$500,d0
    move d0,sr          ; Descend le SR en niveau 5
    move.w    (a7)+,d0
oldikbd:jmp   0.l

; Interruption sur Timer B
hbl:     movem.l d0/a0,-(a7)      ; 44+28=72

    move.l    videodat,d0         ; 20
    lea  vcounthi,A0         ; 8
    move.b    D0,hscroll          ; 12
    movep.l   D0,0(A0)       ; 24

    tst.b     D0
    beq  .zero
    move.b    #76,linewid    ; D‚calage non nul
    bra  .join

.zero:   move.b    #80,linewid    ; D‚calage nul
.join:   movea.l videoptr,a0
    move.l    (a0)+,d0
    rol.l     #8,d0
    move.l    d0,videodat
    move.l    a0,videoptr

    movem.l (a7)+,d0/a0
    bclr.b    #0,MFP+14
    rte

neofile:dc.b  '*.neo',0

    .even
videoptr:dc.l 0
videodat:dc.l 0

    .bss
savMFP:  ds.w 1
Oldbase:ds.l  1
NbArea:  ds.w 1
Oldres:  ds.w 1
oldpal:  ds.l 16
handle:  ds.w 1
baseaddr:ds.l NBAREA
xoffset:ds.w  NBAREA
video:   ds.l NBAREA
neobuff:ds.b  32128
bigbuff:ds.b  2*32000
vbltemp:ds.l  1
    ds.l 256
mystack:ds.l  1
    .end




