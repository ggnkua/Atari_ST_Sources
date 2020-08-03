/************************************************************************/
/*                                                                      */
/*            CREATE BY ATARI FRANCE                                    */
/*                 FOR DEVELOPERS                                       */
/*                 THIS IS A DEMONSTRATION NEW PALLETE                  */
/*                                                                      */
/*                 THIS IS PROGRAMMING IN MADMAC                        */

/************************************************************************/

MFP = $FFFFFA01
NBLIG = 8

    clr.l     -(SP)
    move.w    #$20,-(SP)
    trap #1
    addq.l    #6,SP

    bsr  init

; Sauve la palette
    movea.w   #$8240,A0
    lea  savepal,A1
    moveq     #15,D0
.0: move.w    (A0)+,(A1)+
    dbra D0,.0

; Sauve la r‚solution et passe en basse
    move.w    #4,-(SP)
    trap #14
    addq.l    #2,SP
    move.w    D0,Oldres

    clr.w     -(SP)
    pea  -1.w 
    pea  -1.w 
    move.w    #5,-(SP)
    trap #14
    adda.w    #12,SP

; Efface l'‚cran
    movea.w   #$8200,A0
    clr.l     -(SP)
    move.b    1(A0),1(SP)
    move.b    3(A0),2(SP)
    move.b    13(A0),3(Sp)
    move.l    (SP)+,A0
    move.w    #199,D0
    moveq     #-1,D1
    moveq     #0,D2
.cls:    
    move.w    D2,(A0)+  
    move.w    D2,(A0)+  
    move.w    D2,(A0)+  
    move.w    D2,(A0)+  ; couleur 0

    move.w    D1,(A0)+  
    move.w    D2,(A0)+  
    move.w    D2,(A0)+  
    move.w    D2,(A0)+  ; couleur 1

    move.w    D2,(A0)+  
    move.w    D1,(A0)+  
    move.w    D2,(A0)+
    move.w    D2,(A0)+  ; couleur 2

    move.w    D1,(A0)+  
    move.w    D1,(A0)+
    move.w    D1,(A0)+
    move.w    D1,(A0)+  ; couleur 3

    move.w    D2,(A0)+
    move.w    D2,(A0)+
    move.w    D1,(A0)+  
    move.w    D2,(A0)+  ; couleur 4
    
    move.w    D1,(A0)+
    move.w    D2,(A0)+
    move.w    D1,(A0)+  
    move.w    D2,(A0)+  ; couleur 5

    move.w    D2,(A0)+
    move.w    D1,(A0)+
    move.w    D1,(A0)+  
    move.w    D2,(A0)+  ; couleur 6

    move.w    D1,(A0)+
    move.w    D1,(A0)+
    move.w    D1,(A0)+  
    move.w    D2,(A0)+  ; couleur 7

    move.w    D2,(A0)+  
    move.w    D2,(A0)+  
    move.w    D2,(A0)+  
    move.w    D1,(A0)+  ; couleur 8

    move.w    D1,(A0)+  
    move.w    D2,(A0)+  
    move.w    D2,(A0)+  
    move.w    D1,(A0)+  ; couleur 9

    move.w    D2,(A0)+  
    move.w    D1,(A0)+  
    move.w    D2,(A0)+
    move.w    D1,(A0)+  ; couleur 10

    move.w    D1,(A0)+  
    move.w    D1,(A0)+
    move.w    D2,(A0)+
    move.w    D1,(A0)+  ; couleur 11

    move.w    D2,(A0)+
    move.w    D2,(A0)+
    move.w    D1,(A0)+  
    move.w    D1,(A0)+  ; couleur 12
    
    move.w    D1,(A0)+
    move.w    D2,(A0)+
    move.w    D1,(A0)+  
    move.w    D1,(A0)+  ; couleur 13

    move.w    D2,(A0)+
    move.w    D1,(A0)+
    move.w    D1,(A0)+  
    move.w    D1,(A0)+  ; couleur 14

    move.w    D1,(A0)+
    move.w    D1,(A0)+
    move.w    D1,(A0)+  
    move.w    D1,(A0)+  ; couleur 15

    .rept     8
    clr.l     (A0)+          ; complŠte en couleur 0
    .endr

    dbra D0,.cls
    
    move.l    $118,oldikbd+2
    move.l    #ikbd,$118

    move.l    $70,OldVBL+2
    move.l    #vbl,$70

    bset.b    #0,MFP+18
    bset.b    #0,MFP+6

.1: pea  .1(PC)
    move.w    #2,-(SP)
    move.w    #2,-(SP)
    trap #13
    addq.l    #4,SP

    cmp.l     #$00480000,D0
    beq  up
    cmp.l     #$00500000,D0
    beq  down
    addq.l    #4,SP
        cmp.b #3,D0
    bne.s     .1

    move.w    Oldres,-(SP)
    pea  -1.w 
    pea  -1.w 
    move.w    #5,-(SP)
    trap #14
    adda.w    #12,SP

; restaure la palette
    movea.w   #$8240,A0
    lea  savepal,A1
    moveq     #15,D0
.2: move.w    (A1)+,(A0)+
    dbra D0,.2

    bclr.b    #0,MFP+18
    bclr.b    #0,MFP+6
    move.l    OldVBL+2,$70
    move.l    oldikbd+2,$118

    clr.w     -(SP)
    trap #1


up: move.l    #colortable,D0
    cmp.l     colorbeg,D0
    bpl.s     .1
    sub.l     #30,colorbeg
.1: rts

down:    move.l    #endtable-((200/NBLIG)*16*2),D0
    cmp.l     colorbeg,D0
    bmi.s     .1
    add.l     #30,colorbeg
.1: rts

* -------------------------------------------------- *

ikbd:    move.w    D0,-(SP)
    move SR,D0
    and.w     #$F8FF,D0
    or.w #$500,D0
    move D0,SR
    move.w    (SP)+,D0
oldikbd:jmp   $0.l

vbl:     movem.l   A0/A1,-(SP)
    move.l    #hbl,$120      ; Vecteur HBL
    move.l    colorbeg,colorptr   ; Adresse de la table
    move.l    colorptr,A0
    movea.w   #$8242,A1
    move.w    (A0)+,(A1)+
    .rept 7
    move.l    (A0)+,(A1)+
    .endr
    move.l    A0,colorptr
    move.b    #0,MFP+26 ; stoppe le timer B
    move.b    #NBLIG,MFP+32  ; nombre de lignes
    move.b    #8,MFP+26 ; en event count mode
    move.w    #180,limit
    movem.l   (SP)+,A0/A1    
OldVBL:  jmp  $0.l

hbl:     movem.l   D0/A0-A1,-(SP) 

    movea.w   #$FA01,A0
    move.b    32(A0),D0
.1: cmp.b     32(A0),D0
    beq.s     .1

    move.l    colorptr,A0
    movea.w   #$8242,A1

    move.w    (A0)+,(A1)+
    .rept     7
    move.l    (A0)+,(A1)+
    .endr

    move.l    A0,colorptr    

    subq.w    #NBLIG,limit
    bpl.s     .2
    clr.b     MFP+26
.2: bclr.b    #0,MFP+14
    movem.l   (SP)+,D0/A0-A1
        rte

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

code:    move.b    ctb(PC,D7.W),D7
    rts

; Construction d'une table de 4096 couleurs au format STE
init:    lea  colortable,A0
    moveq     #15,D0         ; R
.1: moveq     #15,D1         ; G
.2: moveq     #15,D2         ; B
.3: move.l    D0,D7
    bsr  code
    move.l    D7,D6
    lsl.l     #4,D6
    move.l    D1,D7
    bsr  code
    or.l D7,D6
    lsl.l     #4,D6
    move.l    D2,D7
    bsr  code
    or.l D7,D6
    move.w    D6,(A0)+
    dbra D2,.3
    dbra D1,.2
    dbra D0,.1
    move.l    #colortable,colorbeg
    rts

    .bss
limit:   ds.w 1
Oldres: ds.w  1
savepal:ds.w 16
colorptr:ds.l 1
colorbeg:ds.l 1
colortable:
    ds.w 4096
endtable:ds.l 0

    .end
