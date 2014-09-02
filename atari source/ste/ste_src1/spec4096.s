/************************************************************************/
/*                                                                      */
/*            CREATE BY ATARI FRANCE                                    */
/*                 FOR DEVELOPERS                                       */
/*                 THIS IS A DEMONSTRATION D'UNE IMAGE SPECTRUM         */
/*                                                                      */
/*                 THIS IS PROGRAMMING IN MADMAC                        */

/************************************************************************/

MFP = $FFFFFA01
NBLIG = 8

; On commence par passer en superviseur
debut:   clr.l     -(SP)
    move.w    #$20,-(SP)
    trap #1
    addq.l    #6,SP

; Cr‚ation de la palette spectrum
    bsr  init

; Sauve la palette
    movea.w   #$8240,A0
    lea  savepal,A1
    lea  newpal,A2
    moveq     #15,D0
.0: move.w    (A0),(A1)+
    move.w    (A2)+,(A0)+
    dbra D0,.0

; Sauve la r‚solution
    move.w    #4,-(SP)
    trap #14
    addq.l    #2,SP
    move.w    D0,Oldres

; Passe en basse r‚solution
    clr.w     -(SP)
    pea  -1.w 
    pea  -1.w 
    move.w    #5,-(SP)
    trap #14
    adda.w    #12,SP

; Construit un ‚cran constitu‚ de bandes verticales
    bsr  MakeScreen

; Detourne le clavier pour qu'il soit pas trop prioritaire
    move.l    $118,oldikbd+2
    move.l    #ikbd,$118

; Installe le gestionnaire spectrum
    bsr  InitVBL

; Attend un Ctrl-C
; ou des fleches pour le r‚glage de la synchro
.1: pea  .1(PC)
    move.w    #2,-(SP)
    move.w    #2,-(SP)
    trap #13
    addq.l    #4,SP
    cmp.l     #$004B0000,D0  ; 
    beq  moins
    cmp.l     #$004D0000,D0  ; 
    beq  plus
    addq.l    #4,SP
        cmp.b #3,D0          ; CTRL-C
    bne.s     .1

; On enlŠve le gestionnaire spectrum
    bsr  DelVBL

; Restaure l'ancienne r‚solution
    move.w    Oldres,-(SP)
    pea  -1.w 
    pea  -1.w 
    move.w    #5,-(SP)
    trap #14
    adda.w    #12,SP

; de meme que la palette
    movea.w   #$8240,A0
    lea  savepal,A1
    moveq     #15,D0
.2: move.w    (A1)+,(A0)+
    dbra D0,.2

; Remet le clavier comme avant
    move.l    oldikbd+2,$118

; Retourne … l'appelant
    clr.w     -(SP)
    trap #1
    illegal

* -----------------------------------*

; Augmentation de la synchro
moins:   subq.l    #2,increment
    bpl.s     .1
    clr.l     increment
.1: rts

; diminution de la synchro
plus:    addq.l    #2,increment
    cmp.l     #142,increment
    bmi.s     .1
    move.l    #140,increment
.1: rts


; Table de conversion d'une composante couleur du format
; 4 bits standard vers le format STE qui est l‚gŠrement
; modifi‚
ctb:     dc.b %0000
    dc.b %1000
    dc.b %0001
    dc.b %1001
    dc.b %0010
    dc.b %1010
    dc.b %0011
    dc.b %1011
    dc.b %0100
    dc.b %1100
    dc.b %0101
    dc.b %1101
    dc.b %0110
    dc.b %1110
    dc.b %0111
    dc.b %1111

; Routine de conversion d'une composante vers le format STE
code:    move.b    ctb(PC,D7.W),D7
    rts

; Construction d'une table de 4096 couleurs au format STE
; et pour spectrum … raison de 200 lignes de 3 palettes
init:    lea  colortable,A0

    move.w    #199,D0
.1: move.w    #$700,D6
    clr.w     (A0)+
    .rept 15
    move.w    D6,(A0)+
    .endr
    
    move.w    #$070,D6
    clr.w     (A0)+
    .rept 15
    move.w    D6,(A0)+
    .endr

    move.w    #$007,D6
    clr.w     (A0)+
    .rept 15
    move.w    D6,(A0)+
    .endr
    dbra D0,.1
    rts

;init:   lea  colortable,A0
    moveq     #0,D3          ; Rouge
    moveq     #0,D4          ; Vert
    moveq     #0,D5          ; bleu
    move.w    #200-1,D0 ; On fait 200 lignes
.nxtlig:moveq #3-1,D1        ; 3 palettes
.nxtpal:clr.w (A0)+          ; Couleur 0 en noir
    moveq     #15-1,D2  ; 15 couleurs
.nxtcol:move.l     D3,D7
    bsr  code      ; R
    move.l    D7,D6
    lsl.l     #4,D6
    move.l    D4,D7
    bsr  code      ; V
    or.l D7,D6
    lsl.l     #4,D6
    move.l    D5,D7
    bsr  code      ; B
    or.l D7,D6
    move.w    D6,(A0)+
; Augmente la couleur
    addq.w    #1,D3
    cmp.w     #16,D3
    bmi.s     .4
    clr.w     D3
    addq.w    #1,D4
    cmp.w     #16,D4
    bmi.s     .4
    clr.w     D4
    addq.w    #1,D5
    cmp.w     #16,D5
    bmi.s     .4
    clr.w     D5
.4: dbra D2,.nxtcol     ; prochaine couleur dans la palette
    dbra D1,.nxtpal     ; prochaine palette dans la ligne
    dbra D0,.nxtlig     ; prochaine ligne
    rts

coltab:  dc.w 0,0,0,0
    dc.w 1,0,0,0
    dc.w 0,1,0,0
    dc.w 1,1,0,0
    dc.w 0,0,1,0
    dc.w 1,0,1,0
    dc.w 1,1,1,0
    dc.w 0,0,0,1
    dc.w 1,0,0,1
    dc.w 0,1,0,1
    dc.w 1,1,0,1
    dc.w 0,0,1,1
    dc.w 1,0,1,1
    dc.w 1,1,1,1
SetColor:
    move.w    D5,D0
    lsl.w     #3,D0
    lea  coltab(PC,D0.W),A0
    move.l    (A0)+,24(A5)
    move.l    (A0)+,28(A5)
    rts
    
pattern:dc.w  $FFFF,$FFFF

; Construction d'un ‚cran
MakeScreen:
    dc.w $A000          ; initialise la line A
    move.l    A0,A5          ; sauvegarde de la base lineA
    
    moveq     #0,D7          ; Y d‚part
    moveq     #12,D6         ; Y fin
    moveq     #1,D5          ; couleur de d‚part

    clr.w     36(A5)         ; mode replace
    clr.w     54(A5)         ; pas de clipping
    clr.w     52(A5)         ; matrice monoplan
    move.l    #pattern,46(A5)     ; matrice de remplissage
    move.w    #1,50(A5) ; 1 ligne
         
.1: bsr  SetColor
    clr.w     38(A5)         ; X1=0
    move.w    #319,42(A5)    ; X2=319
    move.w    D7,40(A5) ; Y1
    move.w    D6,44(A5) ; Y2
    dc.w $A005          ; trace le rectangle

    addq.w    #1,D5          ; Incr‚mente la couleur
    and.w     #15,D5         ; dans certaines limites
    
    add.w     #13,D6         ; augmente le Y de fin
    cmp.w     #200,D6        ; si plus bas que le bas
    bmi.s     .2
    move.w    #199,D6        ; on coupe...
.2: add.w     #12,D7         ; augmente le Y de d‚but
    cmp.w     #200,D7        ; on arrŠte … la fin
    bmi.s     .1
    rts  

    .data
; palette de d‚grad‚s de gris
newpal:  dc.w $000,$888,$111,$999,$222,$AAA,$333,$BBB
    dc.w $444,$CCC,$555,$DDD,$666,$EEE,$777,$FFF
    
    .bss 
OldVBL:  ds.l 1       ; sauvegarde d'o— est notre VBL
OldFreq:ds.b  1    ; sauvegarde du registre fr‚quence
Oldres: ds.w  1    ; sauvegarde de la r‚solution
savepal:ds.w 16         ; sauvegarde de la palette

* ------------------------------------------------------------  
*             MODULE D'AFFICHAGE SPECTRUM
* ------------------------------------------------------------

FLOCK         =  $43E
VCOUNTLOW       =  $FFFF8209
Color0        =  $FFFF8240
    .text

; ------------------------------------------------------- *
; Nouvelle interruption clavier
; On se contente de mettre le SR en ipl5 pour pas g‚ner
; (note : C'est g‚n‚ralement pour les programme utilisant
;         le timer B mais l… j'ai pas envie de l'enlever)
; --------------------------------------------------------*
ikbd:    move.w    D0,-(SP)
    move SR,D0
    and.w     #$F8FF,D0
    or.w #$500,D0
    move D0,SR
    move.w    (SP)+,D0
oldikbd:jmp   $0.l


; -------------------------------------------------- *
; Installation du gestionnaire spectrum
; -------------------------------------------------- *
InitVBL:move.l     #colortable,palette

; Installation du gestionnaire de palette 
    move.l    $4CE,OldVBL
    move.l    #NewVBL,$4CE   ; Installe la VBL

; Change quelques paramŠtres d'affichage
    move.b    $FFFF820A,OldFreq
    bclr.b    #1,$FFFF820A   ; Passe en 60 Hz
    clr.b     $FFFF8260 ; en basse r‚solution
    rts

; --------------------------------------------------- *
; EnlŠve le gestionnaire spectrum            *
; --------------------------------------------------- *
DelVBL::move.l     OldVBL,$4CE    ; Remplace la VBL
    move.b    OldFreq,$FFFF820A
    rts



; ------------------------------------------------------------------- *
; Routine de gestion de la palette
; Cette routine est ex‚cut‚e sous VBL et prend le controle 
; pendant une trame complete. Pendant ce temps, la palette est
; modifi‚e en permanence. Cel… permet d'obtenir 512 couleurs
; … l'‚cran … raison de 3 palettes par ligne. Par contre, il 
; faut d‚terminer … quelle palette appartient un pixel d'une couleur
; donn‚e.
; ------------------------------------------------------------------- *
NewVBL:  tst.w     FLOCK
    bne  DiskBusy  ; On fait rien si le disque tourne

    move SR,-(SP)
    ori  #$700,SR  ; Inhibe les ITs

    lea  Color0,a4
    lea  VCOUNTLOW,a5
    lea  (a4),a0
    lea  (a4),a1
    lea  (a4),a2
    lea  NopTbl(pc),a6  ; Table de temporisation
    move.l    palette,a3     ; Adresse de la palette de la 2eme ligne 
    move.w    #$C4,d7        ; 200 lignes
    moveq     #0,d0
.Wait0:  tst.b     (a5)
    beq.s     .Wait0
    move.b    (a5),d0
    adda.l    d0,a6
    adda.l    increment,a6   ; pr‚vu pour r‚gler la synchronisation
    jmp  (a6)

* liste de NOPs destines a rattraper le temps perdu
* une demi micro seconde … chaque nop
NopTbl:  
    .rept     74
    nop
    .endr
    
.line:   nop            ; 0.0 microsecondes
    lea  (a4),a0
    lea  (a4),a1
    lea  (a4),a2

* Transfere les 3 palettes de la ligne
    .rept 8
    move.l    (a3)+,(a0)+
    .endr
    .rept 8
    move.l    (a3)+,(a1)+
    .endr
    .rept 8
    move.l    (a3)+,(a2)+
    .endr
    dbra d7,.line

* On recommence pour les deux derniŠres lignes
    lea  (a4),a0
    lea  (a4),a1
    lea  (a4),a2

    .rept 8
    move.l    (a3)+,(a0)+
    .endr
    .rept 8
    move.l    (a3)+,(a1)+
    .endr
    .rept 8
    move.l    (a3)+,(a2)+
    .endr

    lea  (a4),a0
    lea  (a4),a1
    lea  (a4),a2
    lea  $B5A0(a3),a4   ; 198 ligne avant
    nop
    nop
    .rept 8
    move.l    (a3)+,(a0)+
    .endr
    .rept 8
    move.l    (a3)+,(a1)+
    .endr
    .rept 8
    move.l    (a3)+,(a2)+
    .endr

    move (SP)+,SR
DiskBusy:
    rts

    .bss
palette:ds.l  1         ; Adresse de la palette
increment:ds.l     1         ; r‚glage de la synchro
colortable:ds.w    200*16*3  ; palette spectrum
endtable:ds.l 0

    .end
