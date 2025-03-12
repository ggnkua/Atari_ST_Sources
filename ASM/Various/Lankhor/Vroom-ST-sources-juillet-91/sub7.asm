        TTL     SUB7 - Object Routines - V15 - 09 Apr 91

        INCLUDE "EQU.ASM"     
        
        XDEF    meptig,SPRITE,DECOMP,tstcra
        XDEF    adhaut,nolog,rdlog,tabobj,FROTT

        XREF    htprl,XB,CURSCR,JUMPE,CHRPAL,OCCUR,SP1D,pasfr

*INIT TIGE
meptig: lea.l   ttail(pc),a0
        moveq   #0,d0
        moveq   #0,d3
        move.w  #15,d1
btail:  move.w  d3,(a0)+
        addq.w  #4,d0
        move.w  d0,d3
        add.w   -2(a0),d3
        dbf     d1,btail
        
        move.l  #BCKEQU+13440,a0    ;ecran voiture
        move.l  a4,a1   ;adr chrgt
        move.l  a1,hgauch
        move.w  #15,d0
btig1:  move.l  a0,a2
        move.w  d0,d1
        lsl.w   #3,d1
        add.w   d1,a2
        move.w  d0,d2
        eor.b   #$0f,d2
        move.w  d2,d3
        mulu    #160,d3
        add.l   d3,a2
atig1:  move.w  (a2),(a1)+
        move.w  6(a2),(a1)+
        lea.l   -160(a2),a2
        dbf     d2,atig1
        dbf     d0,btig1

        add.l   #160*16,a0
        move.l  a1,tgauch
        move.w  #15,d0
        move.l  a0,a2
        move.w  d0,d1
        lsl.w   #3,d1
        add.w   d1,a2
btig2:  move.w  (a2),(a1)+
        move.w  6(a2),(a1)+
        lea.l   -8(a2),a2
        dbf     d0,btig2

        add.l   #160*1,a0
        move.l  a1,tgauch1
        move.w  #15,d0
        move.l  a0,a2
        move.w  d0,d1
        lsl.w   #3,d1
        add.w   d1,a2
btig21: move.w  (a2),(a1)+
        move.w  6(a2),(a1)+
        lea.l   -8(a2),a2
        dbf     d0,btig21

        add.l   #160*1,a0
        move.w  #15,d0
        move.l  a0,a2
        move.w  d0,d1
        lsl.w   #3,d1
        add.w   d1,a2
btig22: move.w  (a2),(a1)+
        move.w  6(a2),(a1)+
        lea.l   -8(a2),a2
        dbf     d0,btig22

        add.l   #160*1,a0
        move.w  #15,d0
        move.l  a0,a2
        move.w  d0,d1
        lsl.w   #3,d1
        add.w   d1,a2
btig23: move.w  (a2),(a1)+
        move.w  6(a2),(a1)+
        lea.l   -8(a2),a2
        dbf     d0,btig23

        add.l   #160*1,a0
        move.l  a1,hdroit
        move.w  #15,d0
btig3:  move.l  a0,a2
        move.w  d0,d1
        lsl.w   #3,d1
        add.w   d1,a2
        move.w  d0,d2
        eor.b   #$0f,d2
        move.w  d2,d3
        mulu    #160,d3
        add.l   d3,a2
atig3:  move.w  (a2),(a1)+
        move.w  6(a2),(a1)+
        lea.l   -160(a2),a2
        dbf     d2,atig3
        dbf     d0,btig3

        add.l   #160*16,a0
        move.l  a1,tdroit
        move.w  #15,d0
        move.l  a0,a2
        move.w  d0,d1
        lsl.w   #3,d1
        add.w   d1,a2
btig4:  move.w  (a2),(a1)+
        move.w  6(a2),(a1)+
        lea.l   -8(a2),a2
        dbf     d0,btig4

        add.l   #160*1,a0
        move.l  a1,tdroit1
        move.w  #15,d0
        move.l  a0,a2
        move.w  d0,d1
        lsl.w   #3,d1
        add.w   d1,a2
btig41: move.w  (a2),(a1)+
        move.w  6(a2),(a1)+
        lea.l   -8(a2),a2
        dbf     d0,btig41

        add.l   #160*1,a0
        move.w  #15,d0
        move.l  a0,a2
        move.w  d0,d1
        lsl.w   #3,d1
        add.w   d1,a2
btig42: move.w  (a2),(a1)+
        move.w  6(a2),(a1)+
        lea.l   -8(a2),a2
        dbf     d0,btig42

        add.l   #160*1,a0
        move.w  #15,d0
        move.l  a0,a2
        move.w  d0,d1
        lsl.w   #3,d1
        add.w   d1,a2
btig43: move.w  (a2),(a1)+
        move.w  6(a2),(a1)+
        lea.l   -8(a2),a2
        dbf     d0,btig43

        add.l   #160*1,a0
        move.l  a1,lampa
        move.w  #15,d0
        move.l  a0,a2
        move.w  d0,d1
        lsl.w   #3,d1
        add.w   d1,a2
btig5:  move.w  (a2),(a1)+
        move.w  6(a2),(a1)+
        lea.l   -8(a2),a2
        dbf     d0,btig5

        add.l   #160*1,a0
        move.l  a1,lampaf
        move.w  #15,d0
        move.l  a0,a2
        move.w  d0,d1
        lsl.w   #3,d1
        add.w   d1,a2
btig5f: move.w  (a2),(a1)+
        move.w  6(a2),(a1)+
        lea.l   -8(a2),a2
        dbf     d0,btig5f

        add.l   #160*1,a0
        move.l  a1,hpot
        move.w  #5,d0
btig6:  move.l  a0,a2
        move.w  d0,d1
        lsl.w   #3,d1
        add.w   d1,a2
        move.w  #5,d2
        sub.w   d0,d2
        move.w  d2,d3
        mulu    #160,d3
        add.l   d3,a2
atig6:  move.w  (a2),(a1)+
        move.w  6(a2),(a1)+
        lea.l   -160(a2),a2
        dbf     d2,atig6
        dbf     d0,btig6

        add.l   #160*6,a0
        move.l  a1,tpot
        move.w  #5,d0
        move.l  a0,a2
        move.w  d0,d1
        lsl.w   #3,d1
        add.w   d1,a2
btig7:  move.w  (a2),(a1)+
        move.w  6(a2),(a1)+
        lea.l   -8(a2),a2
        dbf     d0,btig7
        rts
*AFFI TIGE
vecteur:
        move.b  (a5),d0
        ext.w   d0
        neg.w   d0
        lea.l   coorbas+12,a3
        subq.w  #2,d0
        bge.s   rafft            ;obj vide
        clr.w   -10(a3)
        move.w  #256,-12(a3)
objvi:  rts
vecteub:
        move.b  (a5),d0
        ext.w   d0
        neg.w   d0
        lea.l   coorbas+12,a3
        subq.w  #2,d0
        cmp.w   #48,d0
        bge     rectang
;ici trt vecteur second
        rts
;affichage metal  d0=no obj pos - 2
rafft: 
        cmp.w   #48,d0
        bge     rectang
        clr.w   d1
        move.b  1(a5),d1
        move.w  d1,(a3)
        move.w  6(a5),2(a3)
        move.w  6+8(a5),d6
        clr.w   d1
        move.b  4(a5),d1
        subq.w  #1,d1
        move.w  d1,6(a3)
        move.w  2(a5),4(a3)
        add.w   d0,d0
        move.w  jpaf(pc,d0.w),d0
        jmp     jpaf(pc,d0.w)
touch1: move.b  #1,-8(a3)
touche: rts
jpaf:   dc.w    cadra1-jpaf
        dc.w    cadra2-jpaf
        dc.w    cadra3-jpaf
        dc.w    cadrb1-jpaf
        dc.w    cadrb2-jpaf
        dc.w    cadrb3-jpaf
        dc.w    lampa16-jpaf
        dc.w    lampa8-jpaf
        dc.w    lampb16-jpaf
        dc.w    lampb8-jpaf
        dc.w    pdbl1-jpaf
        dc.w    pdbl2-jpaf
        dc.w    pdbl3-jpaf
        dc.w    pspl1-jpaf
        dc.w    pspl2-jpaf
        dc.w    pspl3-jpaf
        dc.w    lampc16-jpaf
        dc.w    pdbl4-jpaf
        dc.w    pdbl5-jpaf
        dc.w    pdbl6-jpaf
        dc.w    pdbl7-jpaf
rectang:
        sub.w   #48,d0
        add.w   d0,d0
        add.w   d0,d0
        lea.l   trect(pc),a0
        add.w   d0,a0
        move.w  -12+10(a3),d0
        move.w  d0,d4
        mulu    (a0)+,d0
        lsr.l   #8,d0
        mulu    (a0)+,d4
        lsr.l   #8,d4
        move.w  2(a5),d5
        move.w  6(a5),d1

        tst.w   d6
        bne.s   rsecon
        move.w  d0,-12(a3)
        move.w  d4,-12+2(a3)
        tst.b   5(a5)
        beq     fprect
        sub.w   d4,d1
        bra     fprect
rsecon: move.b  -12+5(a3),d3
        move.w  -12+10(a3),d7
        btst    #1,d3
        beq.s   rorout
        sub.w   -12(a3),d5
        btst    #0,d3
        beq.s   rocom
        add.w   d0,d5
        bra.s   rocom
rorout: btst    #0,d3
        beq.s   rocom
        sub.w   d7,d5
        add.w   d0,d5
rocom:  muls    -12+8(a3),d7
        asr.w   #8,d7
        add.w   d7,d5

        tst.b   5(a5)
        beq.s   rscal
        sub.w   -12+2(a3),d1
rscal:  move.w  -12+10(a3),d2
        muls    -12+6(a3),d2
        asr.w   #8,d2
        move.b  -12+5(a3),d3
        btst    #4,d3
        bne.s   ralctr
        add.w   d2,d1
        btst    #3,d3
        bne.s   ralgch
        add.w   -12+2(a3),d1
        btst    #2,d3
        bne.s   rdrgc
        sub.w   d4,d1
        bra.s   fprect
rdrgc:  addq.w  #1,d1
        bra.s   fprect
ralgch: btst    #2,d3
        beq.s   fprect
        sub.w   d4,d1
        subq.w  #1,d1
        bra.s   fprect
ralctr: move.w  -12+2(a3),d3
        lsr.w   #1,d3
        add.w   d3,d2
        move.w  d4,d3
        lsr.w   #1,d3
        sub.w   d3,d2
        add.w   d2,d1
fprect:
        MOVE.W  D0,D7
        JSR     CLIVECT
        BRA.S   III
        MOVE.L  #RODEQU,A0
        MOVE.W  D1,(A0)
        ADD.W   D1,D4
        MOVE.W  D4,2(A0)
        MOVE.B  EFSP,D6
        AND.W   #$F0,D6
        LSR.W   #1,D6
        JSR     XPOLY
        RTS
III:    MOVE.B  #1,coorbas+4
        RTS
trect:  dc.w    100,100,120,120,140,140,180,180,220,220
        dc.w    60,120,80,160,120,240,80,200,120,300
        dc.w    120,60,160,80,240,120,200,80,300,120

cadra1: cmp.w   #20,(a3)
        ble     cadrb1
        move.w  (a3),d0
        move.w  2(a3),d7
        add.w   d0,d7
        move.w  d7,2(a3)
        move.w  d7,6(a5)
        sub.w   d7,d6
        move.w  d6,-10(a3)
        bra.s   cadrac
cadra3: cmp.w   #20,(a3)
        ble     cadrb3
        move.w  (a3),d0
        move.w  2(a3),d7
        sub.w   d0,d7
        move.w  d7,2(a3)
        move.w  d7,6(a5)
        sub.w   d7,d6
        move.w  d6,-10(a3)
        bra.s   cadrac
cadra2: cmp.w   #20,(a3)
        ble     cadrb2
        move.w  (a3),d0
        sub.w   2(a3),d6
        move.w  d6,-10(a3)
cadrac: move.w  d0,d7
        add.w   d7,d7
        add.w   d0,d7
        lsr.w   #2,d7
        move.w  d7,-12(a3)
        clr.b   5(a5)
        move.w  (a3),d0
        move.w  d0,d7
        add.w   d7,d7
        add.w   d7,d0
        lsr.w   #5,d0
        cmp.w   #16,d0
        blt.s   laok1
        move.w  #15,d0
laok1:  move.w  d0,larti

        lea.l   preti(pc),a4
        move.w  4(a3),d0
        bsr     prclip
        mulu    #160,d0
        move.l  CURSCR,a1
        add.l   d0,a1
        move.l  a1,42(a4)
        move.w  2(a3),d7
        sub.w   larti(pc),d7
        move.w  d7,d2
        and.w   #$000f,d7
        and.w   #$fff0,d2
        asr.w   #1,d2
        bsr     cliga
        add.w   d2,a1
        bsr     aftia
        move.w  18(a4),a2
        move.w  -12(a3),d7
        move.w  larti(pc),d0
        sub.w   d0,d7
        subq.w  #1,d7
        ble     touch1
        lsl.w   #2,d0
        move.w  d0,4(a4)
        move.w  d7,2(a4)
        and.w   #$3,2(a4)
        lsr.w   #2,d7
        move.w  d7,(a4)
        move.l  tgauch(pc),a0
        add.w   d0,a0
        subq.w  #1,2(a4)
        bge.s   raj1
        subq.w  #1,d7
raj1:   bsr     cliphb
        bra.s   tpa1
        bsr     aftib
tpa1:   move.w  #1,d7
        bsr     cliphb
        bra.s   tpa1b
        bsr     rupti
tpa1b:
        move.w  (a4),d7
        move.l  tgauch1(pc),a0
        add.w   4(a4),a0
        subq.w  #1,2(a4)
        bge.s   raj2
        subq.w  #1,d7
raj2:   bsr     cliphb
        bra.s   tpa2
        bsr     aftib
tpa2:   move.w  #1,d7
        bsr     cliphb
        bra.s   tpa2b
        bsr     rupti
tpa2b:
        move.w  (a4),d7
        move.l  tgauch(pc),a0
        add.w   4(a4),a0
        subq.w  #1,2(a4)
        bge.s   raj3
        subq.w  #1,d7
raj3:   bsr     cliphb
        bra.s   tpa3
        bsr     aftib
tpa3:   move.w  #1,d7
        bsr     cliphb
        bra.s   tpa3b
        bsr     rupti
tpa3b:
        move.w  (a4),d7
        subq.w  #1,d7
        move.l  tgauch1(pc),a0
        add.w   4(a4),a0
        bsr     cliphb
        bra.s   tpa4
        bsr     aftib
tpa4:   move.w  #1,d7
        bsr     cliphb
        bra.s   tpa4b
        bsr     rupti
tpa4b:
        lea.l   ttail(pc),a0
        move.w  larti(pc),d7
        move.w  d7,d0
        add.w   d0,d0
        move.w  0(a0,d0.w),d0
        move.l  hgauch(pc),a0
        add.w   d0,a0
        bsr     cliphb1
        bra.s   colodb
        lsl.w   #2,d0
        add.w   d0,a0
        bsr     afhti
        swap    d7
        move.w  d7,8(a4)
        move.l  a1,10(a4)
colodb:        
        move.l  42(a4),a1
        move.w  -10(a3),d7
        add.w   2(a3),d7
        move.w  d7,d2
        and.w   #$000f,d7
        and.w   #$fff0,d2
        asr.w   #1,d2
        bsr     clidr
        add.w   d2,a1
        bsr     aftia
        move.w  20(a4),a2
        move.l  tdroit(pc),a0
        add.w   4(a4),a0
        move.w  22(a4),d7
        blt.s   tpa5
        bsr     aftib
tpa5:   move.w  24(a4),d7
        blt.s   tpa5b
        bsr     rupti
tpa5b:
        move.l  tdroit1(pc),a0
        add.w   4(a4),a0
        move.w  26(a4),d7
        blt.s   tpa6
        bsr     aftib
tpa6:   move.w  28(a4),d7
        blt.s   tpa6b
        bsr     rupti
tpa6b:
        move.l  tdroit(pc),a0
        add.w   4(a4),a0
        move.w  30(a4),d7
        blt.s   tpa7
        bsr     aftib
tpa7:   move.w  32(a4),d7
        blt.s   tpa7b
        bsr     rupti
tpa7b:
        move.l  tdroit1(pc),a0
        add.w   4(a4),a0
        move.w  34(a4),d7
        blt.s   tpa8
        bsr     aftib
tpa8:   move.w  36(a4),d7
        blt.s   tpa8b
        bsr     rupti
tpa8b:
        move.w  38(a4),d7
        blt     touche
        lea.l   ttail(pc),a0
        move.w  larti(pc),d0
        add.w   d0,d0
        move.w  0(a0,d0.w),d0
        move.l  hdroit(pc),a0
        add.w   d0,a0
        move.w  40(a4),d0
        lsl.w   #2,d0
        add.w   d0,a0
        bsr     afhti
        swap    d7
        bra     tighor
cadrb1: move.w  (a3),d0
        move.w  2(a3),d7
        add.w   d0,d7
        move.w  d7,2(a3)
        move.w  d7,6(a5)
        sub.w   d7,d6
        move.w  d6,-10(a3)
        bra.s   cadrac2
cadrb3: move.w  (a3),d0
        move.w  2(a3),d7
        sub.w   d0,d7
        move.w  d7,2(a3)
        move.w  d7,6(a5)
        sub.w   d7,d6
        move.w  d6,-10(a3)
        bra.s   cadrac2
cadrb2: move.w  (a3),d0
        sub.w   2(a3),d6
        move.w  d6,-10(a3)
cadrac2: move.w  d0,d7
        add.w   d7,d7
        add.w   d0,d7
        lsr.w   #2,d7
        move.w  d7,-12(a3)
        clr.b   5(a5)
        move.w  (a3),d0
        move.w  d0,d7
        add.w   d7,d7
        add.w   d7,d0
        lsr.w   #5,d0
        cmp.w   #16,d0
        blt.s   laok2
        move.w  #15,d0
laok2:  move.w  d0,larti

        lea.l   preti(pc),a4
        move.w  4(a3),d0
        bsr     prclip
        mulu    #160,d0
        move.l  CURSCR,a1
        add.l   d0,a1
        move.l  a1,42(a4)
        move.w  2(a3),d7
        sub.w   larti(pc),d7
        move.w  d7,d2
        and.w   #$000f,d7
        and.w   #$fff0,d2
        asr.w   #1,d2
        bsr     cliga
        add.w   d2,a1
        bsr     aftia
        move.w  18(a4),a2
        move.w  -12(a3),d7
        move.w  larti(pc),d0
        sub.w   d0,d7
        subq.w  #1,d7
        ble     touch1
        bsr     cliphb
        bra.s   tetga
        lsl.w   #2,d0
        move.l  tgauch(pc),a0
        add.w   d0,a0
        bsr     aftib
tetga:  lea.l   ttail(pc),a0
        move.w  larti(pc),d7
        move.w  d7,d0
        add.w   d0,d0
        move.w  0(a0,d0.w),d0
        move.l  hgauch(pc),a0
        add.w   d0,a0
        bsr     cliphb1
        bra.s   colodr
        lsl.w   #2,d0
        add.w   d0,a0
        bsr     afhti
        swap    d7
        move.w  d7,8(a4)
        move.l  a1,10(a4)
colodr:        
        move.l  42(a4),a1
        move.w  -10(a3),d7
        add.w   2(a3),d7
        move.w  d7,d2
        and.w   #$000f,d7
        and.w   #$fff0,d2
        asr.w   #1,d2
        bsr     clidr
        add.w   d2,a1
        bsr     aftia
        move.w  20(a4),a2
        move.w  22(a4),d7
        blt.s   tetdr
        move.w  larti(pc),d0
        lsl.w   #2,d0
        move.l  tdroit(pc),a0
        add.w   d0,a0
        bsr     aftib
tetdr:  move.w  38(a4),d7
        blt     touche
        lea.l   ttail(pc),a0
        move.w  larti(pc),d0
        add.w   d0,d0
        move.w  0(a0,d0.w),d0
        move.l  hdroit(pc),a0
        add.w   d0,a0
        move.w  40(a4),d0
        lsl.w   #2,d0
        add.w   d0,a0
        bsr     afhti
        swap    d7
tighor:
        cmp.w   #4,a2
        beq     touche
        move.l  a1,d0
        move.l  10(a4),a1
        move.w  larti(pc),d2
        cmp.w   2(a3),d2
        ble.s   gasup
        tst.w   2(a3)
        bge.s   ga1sup
        clr.w   d2
        bra.s   prmot
ga1sup: subq.l  #8,a1
gasup:  add.w   8(a4),d2
        addq.w  #1,d2
        bclr    #4,d2
        beq.s   prmot
        addq.l  #8,a1
prmot:  lea.l   tmas1(pc),a5
        lsl.w   #2,d2
        move.w  0(a5,d2.w),d4
        swap    d4
        move.w  0(a5,d2.w),d4
        move.l  d4,d5
        not.l   d5
        move.w  -10(a3),d1
        add.w   2(a3),d1
        cmp.w   #319,d1
        ble.s   drsup
        clr.w   d7
drsup:  sub.l   a1,d0
        subq.l  #8,d0
        lsr.w   #1,d0
        move.w  #80,d1
        sub.w   d0,d1
        
        lsl.w   #2,d7
        move.w  0(a5,d7.w),d0
        swap    d0
        move.w  0(a5,d7.w),d0
        move.l  d0,d7
        not.l   d7
        move.w  larti(pc),d6
        lea.l   seqti(pc),a5
        lsl.w   #4,d6
        add.w   larti(pc),d6
        sub.w   38(a4),d6
        sub.w   40(a4),d6
        add.w   d6,a5
        move.w  38(a4),d6
        lea.l   coulti(pc),a0
        lea.l   160(a1),a1
        tst.w   d1
        blt     usmot
        lea.l   tjuli(pc),a4
        add.w   d1,a4
        move.l  a1,a2
        clr.w   d1
btiho:  move.b  (a5)+,d1
        move.l  0(a0,d1.w),d2
        move.l  4(a0,d1.w),d3
        and.l   d5,d2
        and.l   d5,d3
        and.l   d4,(a1)
        or.l    d2,(a1)+
        and.l   d4,(a1)
        or.l    d3,(a1)+
        move.l  0(a0,d1.w),d2
        move.l  4(a0,d1.w),d3
        jmp     (a4)
tjuli:
        move.l  d2,(a1)+
        move.l  d3,(a1)+
        move.l  d2,(a1)+
        move.l  d3,(a1)+
        move.l  d2,(a1)+
        move.l  d3,(a1)+
        move.l  d2,(a1)+
        move.l  d3,(a1)+
        move.l  d2,(a1)+
        move.l  d3,(a1)+
        move.l  d2,(a1)+
        move.l  d3,(a1)+
        move.l  d2,(a1)+
        move.l  d3,(a1)+
        move.l  d2,(a1)+
        move.l  d3,(a1)+
        move.l  d2,(a1)+
        move.l  d3,(a1)+
        move.l  d2,(a1)+
        move.l  d3,(a1)+
        move.l  d2,(a1)+
        move.l  d3,(a1)+
        move.l  d2,(a1)+
        move.l  d3,(a1)+
        move.l  d2,(a1)+
        move.l  d3,(a1)+
        move.l  d2,(a1)+
        move.l  d3,(a1)+
        move.l  d2,(a1)+
        move.l  d3,(a1)+
        move.l  d2,(a1)+
        move.l  d3,(a1)+
        move.l  d2,(a1)+
        move.l  d3,(a1)+
        move.l  d2,(a1)+
        move.l  d3,(a1)+
        move.l  d2,(a1)+
        move.l  d3,(a1)+
        move.l  d2,(a1)+
        move.l  d3,(a1)+
        and.l   d0,d2
        and.l   d0,d3
        and.l   d7,(a1)
        or.l    d2,(a1)+
        and.l   d7,(a1)
        or.l    d3,(a1)+
        lea.l   160(a2),a2
        move.l  a2,a1
        dbf     d6,btiho
retrout:
        rts
usmot:  clr.w   d1
        and.l   d5,d0
        or.l    d4,d7
btihos: move.b  (a5)+,d1
        move.l  0(a0,d1.w),d2
        move.l  4(a0,d1.w),d3
        and.l   d0,d2
        and.l   d0,d3
        and.l   d7,(a1)
        or.l    d2,(a1)+
        and.l   d7,(a1)
        or.l    d3,(a1)+
        lea.l   152(a1),a1
        dbf     d6,btihos
        rts
lampb8: move.l  lampaf(pc),-6(a3)
        bra.s   l8cb
lampa8: move.l  lampa(pc),-6(a3)
l8cb:   move.w  (a3),d0
        move.w  d0,-12(a3)
        add.w   d0,d0
        add.w   (a3),d0
        lsr.w   #7,d0
        bra.s   lampc
lampc16: move.l  lampaf(pc),-6(a3)
        move.w  (a3),d0
        move.w  d0,d7
        lsl.w   #2,d7
        add.w   d0,d7
        lsr.w   #3,d7
        bra.s   l16c 
lampb16: move.l  lampaf(pc),-6(a3)
        move.w  (a3),d0
        move.w  d0,d7
        lsl.w   #3,d7
        add.w   d0,d7
        lsr.w   #4,d7
        bra.s   l16c 
lampa16: move.l  lampa(pc),-6(a3)
        move.w  (a3),d0
        move.w  d0,d7
        lsr.w   #1,d7
        add.w   d0,d7
        add.w   d0,d0
        add.w   (a3),d0
        lsr.w   #6,d0
        move.w  d7,-12(a3)
        bra.s   lampc
l16c:   move.w  d7,-12(a3)
        lsr.w   #4,d0
lampc:  move.w  d0,larti
        move.w  d0,-10(a3)

        lea.l   preti(pc),a4
        move.w  2(a3),d7
        tst.b   5(a5)
        beq.s   lamdrt
        sub.w   larti(pc),d7
lamdrt: move.w  4(a3),d0
        bsr     prclip
        mulu    #160,d0
        move.l  CURSCR,a1
        add.l   d0,a1
        move.w  d7,d2
        and.w   #$000f,d7
        and.w   #$fff0,d2
        asr.w   #1,d2
        bsr     cliga
        add.w   d2,a1
        bsr     aftia
        move.w  18(a4),a2
        move.w  -12(a3),d7
        ble     touch1
        move.w  larti(pc),d0
        bsr     cliphb
        bra.s   touch2
        lsl.w   #2,d0
        move.l  -6(a3),a0
        add.w   d0,a0
        bsr     aftib
touch2: rts
pdbl7:  move.w  #200,d7
        bra.s   rdbl
pdbl6:  move.w  #160,d7
        bra.s   rdbl
pdbl5:  move.w  #120,d7
        bra.s   rdbl
pdbl4:  move.w  #80,d7
rdbl:   move.w  (a3),d0
        mulu    d0,d7
        lsr.w   #8,d7
        move.w  d7,-10(a3)
        move.w  d0,d7
        add.w   d7,d7
        add.w   d0,d7
        lsr.w   #5,d7
        move.w  d7,-12(a3)  ;haut
        bra.s   pdblc
pdbl1:  move.w  (a3),d0
        move.w  d0,d7
        lsr.w   #3,d7
        move.w  d7,-10(a3)  ;larg
        move.w  d7,-12(a3)  ;haut
        bra.s   pdblc
pdbl2:  move.w  (a3),d0
        move.w  d0,d7
        lsr.w   #2,d7
        move.w  d7,-10(a3)
        lsr.w   #1,d7
        move.w  d7,-12(a3)
        bra.s   pdblc
pdbl3:  move.w  (a3),d0
        move.w  d0,d7
        lsr.w   #3,d7
        move.w  d7,-12(a3)
        move.w  d0,d7
        lsl.w   #3,d7
        move.w  d7,d2
        lsl.w   #1,d7
        add.w   d2,d7
        sub.w   d0,d7
        lsr.w   #6,d7
        move.w  d7,-10(a3)
pdblc:  lsr.w   #5,d0
        subq.w  #1,d0
        bge.s   tsu6
        clr.w   d0
        bra.s   fsu6
tsu6:   cmp.w   #5,d0
        ble.s   fsu6
        move.w  #5,d0
fsu6:   move.w  d0,larti
        move.w  2(a3),d7
        tst.b   5(a5)
        beq.s   piedr
        sub.w   -10(a3),d7
        move.w  d7,2(a3)
piedr:  lea.l   preti(pc),a4
        move.w  4(a3),d0
        bsr     prclip
        mulu    #160,d0
        move.l  CURSCR,a1
        add.l   d0,a1
        move.l  a1,42(a4)
        move.w  d7,d2
        and.w   #$000f,d7
        and.w   #$fff0,d2
        asr.w   #1,d2
        bsr     cliga
        add.w   d2,a1
        bsr     aftia
        move.w  18(a4),a2
        move.w  -12(a3),d7
        move.w  larti(pc),d0
        sub.w   d0,d7
        subq.w  #1,d7
        ble     touche
        bsr     cliphb
        bra.s   tetgab
        lsl.w   #2,d0
        move.l  tpot(pc),a0
        add.w   d0,a0
        bsr     aftib
tetgab: lea.l   ttail(pc),a0
        move.w  larti(pc),d7
        move.w  d7,d0
        add.w   d0,d0
        move.w  0(a0,d0.w),d0
        move.l  hpot(pc),a0
        add.w   d0,a0
        bsr     cliphb1
        bra.s   colodp
        lsl.w   #2,d0
        add.w   d0,a0
        bsr     afhti
        swap    d7
        move.w  d7,8(a4)
        move.l  a1,10(a4)
colodp:        
        move.l  42(a4),a1
        move.w  -10(a3),d7
        add.w   2(a3),d7
        sub.w   larti(pc),d7
        move.w  d7,d2
        and.w   #$000f,d7
        and.w   #$fff0,d2
        asr.w   #1,d2
        bsr     clidr
        add.w   d2,a1
        bsr     aftia
        move.w  20(a4),a2
        move.w  22(a4),d7
        blt.s   tetdrp
        move.w  larti(pc),d0
        lsl.w   #2,d0
        move.l  tpot(pc),a0
        add.w   d0,a0
        bsr     aftib
tetdrp: move.w  38(a4),d7
        blt     touche
        lea.l   ttail(pc),a0
        move.w  larti(pc),d0
        add.w   d0,d0
        move.w  0(a0,d0.w),d0
        move.l  hpot(pc),a0
        add.w   d0,a0
        move.w  40(a4),d0
        lsl.w   #2,d0
        add.w   d0,a0
        bsr     afhti
        rts
pspl1:  move.w  (a3),d0
        move.w  d0,d7
        lsr.w   #3,d7
        move.w  d7,d2
        lsr.w   #1,d2
        add.w   d2,d7
        move.w  d7,-12(a3)
        bra.s   psplc
pspl2:  move.w  (a3),d0
        move.w  d0,d7
        lsr.w   #3,d7
        move.w  d7,-12(a3)
        bra.s   psplc
pspl3:  move.w  (a3),d0
        move.w  d0,d7
        lsr.w   #2,d7
        move.w  d7,d2
        lsr.w   #1,d2
        add.w   d2,d7
        move.w  d7,-12(a3)
psplc:  lsr.w   #5,d0
        subq.w  #1,d0
        bge.s   tsu6b
        clr.w   d0
        bra.s   fsu6b
tsu6b:  cmp.w   #5,d0
        ble.s   fsu6b
        move.w  #5,d0
fsu6b:  move.w  d0,larti
        move.w  d0,-10(a3)
        move.w  2(a3),d7
        tst.b   5(a5)
        beq.s   piedb
        sub.w   d0,d7
piedb:  lea.l   preti(pc),a4
        move.w  4(a3),d0
        bsr     prclip
        mulu    #160,d0
        move.l  CURSCR,a1
        add.l   d0,a1
        move.w  d7,d2
        and.w   #$000f,d7
        and.w   #$fff0,d2
        asr.w   #1,d2
        bsr     cliga
        add.w   d2,a1
        bsr     aftia
        move.w  18(a4),a2
        move.w  -12(a3),d7
        move.w  larti(pc),d0
        sub.w   d0,d7
        ble     touche
        bsr     cliphb
        bra.s   tetgap
        lsl.w   #2,d0
        move.l  tpot(pc),a0
        add.w   d0,a0
        bsr     aftib
tetgap: lea.l   ttail(pc),a0
        move.w  larti(pc),d7
        move.w  d7,d0
        add.w   d0,d0
        move.w  0(a0,d0.w),d0
        move.l  hpot(pc),a0
        add.w   d0,a0
        bsr     cliphb1
        bra.s   coldb
        lsl.w   #2,d0
        add.w   d0,a0
        bsr     afhti
        swap    d7
        move.w  d7,8(a4)
        move.l  a1,10(a4)
coldb:  rts
cliga:
        clr.l   18(a4)
        cmp.w   #-8,d2
        bgt.s   tdr
        blt.s   tga
        clr.w   d2
        move.w  #1*4,18(a4)
        bra.s   tcomot
tga:    clr.w   d2
        bra.s   tcomot
tdr:    cmp.w   #152,d2
        blt.s   pacent
        beq.s   bodrt
        move.l  #retrout,(a7)
        rts
bodrt:  move.w  #3*4,18(a4)
        bra.s   tcomot
pacent: move.w  #2*4,18(a4)
tcomot: move.w  larti(pc),d0
        add.w   d7,d0
        cmp.w   #16,d0
        blt.s   unmo
        rts
unmo:   bset    #4,19(a4)
        rts
clidr:
        cmp.w   #-8,d2
        bgt.s   tdrb
        blt.s   tgab
        clr.w   d2
        move.w  #1*4,20(a4)
        rts
tgab:   move.l  #retrout,(a7)
        rts
tdrb:   cmp.w   #152,d2
        blt.s   pacentb
        beq.s   bodrtb
        move.w  #160,d2
        bra.s   tcomotb
bodrtb: move.w  #3*4,20(a4)
        bra.s   tcomotb
pacentb:
        move.w  #2*4,20(a4)
tcomotb: move.w  larti(pc),d0
        add.w   d7,d0
        cmp.w   #16,d0
        blt.s   unmob
        rts
unmob:  bset    #4,21(a4)
        rts

prclip:
        move.w  6(a3),d1
        sub.w   d0,d1
        blt.s   cpba1
        clr.w   14(a4)
        bra.s   cpbco1
cpba1:  move.w  d1,14(a4)
        move.w  6(a3),d0
cpbco1: move.w  d0,16(a4)
        sub.w   #banner,16(a4)
        move.l  14(a4),18(a4)
        lea.l   22(a4),a5
        rts
cliphb:
        tst.w   14(a4)
        beq.s   cpbx2
        add.w   14(a4),d7
        bgt.s   cpbx1
        move.w  d7,14(a4)
        bra.s   cpby2
cpbx1:  clr.w   14(a4)
cpbx2:  sub.w   d7,16(a4)
        blt.s   cpby1
cpby0:  addq.l  #2,(a7)
cpby2:  subq.w  #1,d7
        move.w  d7,(a5)+
        rts
cpby1:  add.w   16(a4),d7
        bgt.s   cpby0
        bra.s   cpby2
cliphb1:
        move.w  larti(pc),d0
        tst.w   14(a4)
        beq.s   cpbx21
        add.w   14(a4),d7
        bge.s   cpbx11
        move.w  d7,14(a4)
        bra.s   cpby21
cpbx11: clr.w   14(a4)
cpbx21: subq.w  #1,16(a4)
        sub.w   d7,d0
        sub.w   d7,16(a4)
        blt.s   cpby11
cpby01: addq.l  #2,(a7)
cpby21: move.w  d7,38(a4)
        move.w  d0,40(a4)
        rts
cpby11: add.w   16(a4),d7
        bge.s   cpby01
        bra.s   cpby21
aftia:  move.w  larti(pc),d3
        lea.l   tmas(pc),a2
        lsl.w   #2,d3
        move.l  0(a2,d3.w),d6
        ror.l   d7,d6
        move.w  d6,d4
        swap    d4
        move.w  d6,d4
        swap    d6
        move.w  d6,d5
        swap    d5
        move.w  d6,d5
        move.w  d6,d1
        not.w   d1
        swap    d6
        not.l   d6
        swap    d7
        rts
aftib:  swap    d7
        move.l  (a0),d0
        ror.l   d7,d0
        swap    d7
        move.l  d0,d2
        and.l   d5,d0
        and.l   d4,d2
        swap    d0
        move.w  d0,d3
        move.w  d2,d0
        swap    d2
        jmp     tchti(pc,a2.w)
tchti:  bra.l   calecr
        bra.l   duphd
        bra.l   duph
        bra.l   duphg
        bra.l   calecr
        bra.l   calecr
        bra.l   duphg
        bra.l   duphg
afhti:
        jmp     tchhti(pc,a2.w)
tchhti: bra.l   calecr
        bra.l   afhtid
        bra.l   afhtic
        bra.l   afhtig
        bra.l   calecr
        bra.l   calecr
        bra.l   afhtig
        bra.l   afhtig
afhtic: move.l  (a0)+,d0
        swap    d7
        ror.l   d7,d0
        swap    d7
        move.l  d0,d2
        and.l   d5,d0
        and.l   d4,d2
        swap    d0
        move.w  d0,d3
        move.w  d2,d0
        swap    d2
        and.w   d1,(a1)
        or.w    d3,(a1)+
        or.l    d5,(a1)+
        and.l   d6,(a1)
        or.l    d0,(a1)+
        or.l    d4,(a1)+
        and.w   d6,(a1)
        or.w    d2,(a1)
        lea.l   -174(a1),a1
        dbf     d7,afhtic
        rts
afhtig: move.l  (a0)+,d0
        swap    d7
        ror.l   d7,d0
        swap    d7
        and.l   d5,d0
        move.l  d0,d3
        swap    d3
        and.w   d1,(a1)
        or.w    d3,(a1)+
        or.l    d5,(a1)+
        and.w   d1,(a1)
        or.w    d0,(a1)
        lea.l   -166(a1),a1
        dbf     d7,afhtig
        rts
afhtid: move.l  (a0)+,d0
        swap    d7
        ror.l   d7,d0
        swap    d7
        move.l  d0,d2
        and.l   d4,d2
        move.w  d2,d0
        swap    d2
        and.w   d6,(a1)
        or.w    d0,(a1)+
        or.l    d4,(a1)+
        and.w   d6,(a1)
        or.w    d2,(a1)
        lea.l   -166(a1),a1
        dbf     d7,afhtid
        rts
rupti:  move.l  128(a0),d0
        swap    d7
        ror.l   d7,d0
        swap    d7
        move.l  d0,d2
        and.l   d5,d0
        and.l   d4,d2
        swap    d0
        move.w  d0,d3
        move.w  d2,d0
        swap    d2
        jmp     tchmti(pc,a2.w)
tchmti: bra.l   calecb
        bra.l   afmtid
        bra.l   afmtic
        bra.l   afmtig
        bra.l   calecb
        bra.l   calecb
        bra.l   afmtig
        bra.l   afmtig
afmtic: and.w   d1,(a1)
        or.w    d3,(a1)+
        or.l    d5,(a1)+
        and.l   d6,(a1)
        or.l    d0,(a1)+
        or.l    d4,(a1)+
        and.w   d6,(a1)
        or.w    d2,(a1)
        lea.l   -174(a1),a1
        rts
afmtig: swap    d0
        and.w   d1,(a1)
        or.w    d3,(a1)+
        or.l    d5,(a1)+
        and.w   d1,(a1)
        or.w    d0,(a1)
        lea.l   -166(a1),a1
        rts
afmtid:  
        and.w   d6,(a1)
        or.w    d0,(a1)+
        or.l    d4,(a1)+
        and.w   d6,(a1)
        or.w    d2,(a1)
        lea.l   -166(a1),a1
        rts
calecr: move.w  d7,d0
        addq.w  #1,d0
        mulu    #160,d0
        sub.l   d0,a1
        rts
calecb: 
        lea.l   -160(a1),a1
        rts
duph:
        lsr.w   #1,d7
        bcc.s   duph1
duph0:  and.w   d1,(a1)
        or.w    d3,(a1)+
        or.l    d5,(a1)+
        and.l   d6,(a1)
        or.l    d0,(a1)+
        or.l    d4,(a1)+
        and.w   d6,(a1)
        or.w    d2,(a1)
        lea.l   -174(a1),a1
duph1:  and.w   d1,(a1)
        or.w    d3,(a1)+
        or.l    d5,(a1)+
        and.l   d6,(a1)
        or.l    d0,(a1)+
        or.l    d4,(a1)+
        and.w   d6,(a1)
        or.w    d2,(a1)
        lea.l   -174(a1),a1
        dbf     d7,duph0
        rts
duphg:  swap    d0
        lsr.w   #1,d7
        bcc.s   duphg1
duphg0: and.w   d1,(a1)
        or.w    d3,(a1)+
        or.l    d5,(a1)+
        and.w   d1,(a1)
        or.w    d0,(a1)
        lea.l   -166(a1),a1
duphg1: and.w   d1,(a1)
        or.w    d3,(a1)+
        or.l    d5,(a1)+
        and.w   d1,(a1)
        or.w    d0,(a1)
        lea.l   -166(a1),a1
        dbf     d7,duphg0
        rts
duphd:  
        lsr.w   #1,d7
        bcc.s   duphd1
duphd0:  
        and.w   d6,(a1)
        or.w    d0,(a1)+
        or.l    d4,(a1)+
        and.w   d6,(a1)
        or.w    d2,(a1)
        lea.l   -166(a1),a1
duphd1: 
        and.w   d6,(a1)
        or.w    d0,(a1)+
        or.l    d4,(a1)+
        and.w   d6,(a1)
        or.w    d2,(a1)
        lea.l   -166(a1),a1
        dbf     d7,duphd0
        rts
ttail:  ds.w    16
tmas1:  dc.w    0,0
tmas:   dc.w    $8000,0,$c000,0,$e000,0,$f000,0
        dc.w    $f800,0,$fc00,0,$fe00,0,$ff00,0
        dc.w    $ff80,0,$ffc0,0,$ffe0,0,$fff0,0
        dc.w    $fff8,0,$fffc,0,$fffe,0,$ffff,0
coulti: dc.w    0,-1,-1,0,-1,-1,-1,0,0,-1,-1,-1,-1,-1,-1,-1
seqti:  
        dc.b    8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        dc.b    16,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        dc.b    16,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        dc.b    16,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0
        dc.b    16,8,8,16,0,0,0,0,0,0,0,0,0,0,0,0
        dc.b    16,0,8,8,16,0,0,0,0,0,0,0,0,0,0,0
        dc.b    16,0,8,8,8,16,0,0,0,0,0,0,0,0,0,0
        dc.b    16,8,0,8,8,16,8,0,0,0,0,0,0,0,0,0
        dc.b    16,8,0,8,8,8,16,8,0,0,0,0,0,0,0,0
        dc.b    16,8,0,8,8,8,8,16,8,0,0,0,0,0,0,0
        dc.b    16,8,0,8,8,8,8,16,8,8,0,0,0,0,0,0
        dc.b    16,8,8,0,8,8,8,8,16,8,8,0,0,0,0,0
        dc.b    16,8,8,0,8,8,8,8,8,16,8,8,0,0,0,0
        dc.b    16,8,8,0,8,8,8,8,8,16,8,8,8,0,0,0
        dc.b    16,8,8,8,0,8,8,8,8,8,16,8,8,8,0,0
        dc.b    16,8,8,8,0,8,8,8,8,8,16,8,8,8,0,0
larti:  dc.w    0
hgauch: dc.l    0
hdroit: dc.l    0
tgauch: dc.l    0
tdroit: dc.l    0
tgauch1: dc.l    0
tdroit1: dc.l    0
lampaf: dc.l    0
lampa:  dc.l    0
hpot:   dc.l    0
tpot:   dc.l    0
        ds.l    5
preti:  ds.l    14

;       A3=COORBAS  A5=ZAFEVT
AVPNTR: MOVE.L  #RODEQU,A0
        CLR.W   D0
        MOVE.B  1(A5),D0
        MOVE.W  D0,D1
        MOVE.W  D0,D3
        LSR.W   #2,D1
        LSL.W   #1,D3
        SUB.W   D1,D0
        BEQ     FAVPNTR
        MOVE.W  6(A5),D2
        MOVE.W  D2,2(A0)

        MOVE.W  6+8(A5),D5
        MOVE.W  D5,4(A0)
        ADD.W   D3,D5
        MOVE.W  D5,6(A0)
        SUB.W   D3,D2
        MOVE.W  D2,(A0)
        MOVE.W  D0,D7
        MOVE.W  2(A5),D5
        BSR     CLIVECT
        BRA.S   COT1
        MOVE.L  #RODEQU,A0
        MOVE.W  #14*8,D6
        MOVEM.L D0/D1/D5/D7/A5,-(SP)
        BSR     XPOLY
        MOVEM.L (SP)+,D0/D1/D5/D7/A5
        MOVE.L  #RODEQU+4,A0
        MOVE.W  #14*8,D6
        MOVEM.L D0/D1/A5,-(SP)
        BSR     XPOLY
        MOVEM.L (SP)+,D0/D1/A5
COT1:   
        MOVE.W  D1,D7
        MOVE.W  2(A5),D5
        SUB.W   D0,D5
        BSR     CLIVECT
        BRA.S   FAVPNTR
        MOVE.L  #RODEQU,A0
        MOVE.W  6(A0),2(A0)
        MOVE.W  #14*8,D6
        MOVE.L  A5,-(SP)
        BSR     XPOLY
        MOVE.L  (SP)+,A5
FAVPNTR: RTS
;       A4=ZAFEVT DEVANT   A5=ZAFEVT DERR
ARPNTR: 
        CMP.L   #-1,8(A4)
        BNE.S   AVAR7
        SUB.W   #255+64,6(A4)
        ADD.W   #255+64,6+8(A4)
AVAR7:  LEA.L   preti(PC),A3
        CLR.W   D7
        MOVE.B  1(A4),D7
        MOVE.W  D7,D6
        MOVE.W  D6,D5
        LSL.W   #1,D6
        LSR.W   #2,D5

        CLR.W   D4
        MOVE.B  1(A5),D4
        MOVE.W  D4,D3
        MOVE.W  D3,D2
        LSL.W   #1,D3
        LSR.W   #2,D2

        MOVE.W  2(A4),D0
        SUB.W   D7,D0
        MOVE.W  D0,(A3)+
        ADD.W   D5,D0
        MOVE.W  D0,(A3)+
        MOVE.W  2(A5),D0
        SUB.W   D4,D0
        MOVE.W  D0,(A3)+
        ADD.W   D2,D0
        MOVE.W  D0,(A3)+

        MOVE.W  6(A4),D0
        SUB.W   D6,D0
        MOVE.W  D0,(A3)+
        MOVE.W  6+8(A4),D0
        MOVE.W  D0,(A3)+
        ADD.W   D6,D0
        MOVE.W  D0,(A3)+

        MOVE.W  6(A5),D0
        SUB.W   D3,D0
        MOVE.W  D0,(A3)+
        MOVE.W  6+8(A5),D0
        MOVE.W  D0,(A3)+
        ADD.W   D3,D0
        MOVE.W  D0,(A3)

        LEA.L   preti(PC),A3
;PREM BLOC
APO1:   LEA.L   preti+20(PC),A2
        MOVE.W  #6*8,(A2)+
        MOVE.W  6(A4),D1
        CMP.W   6(A5),D1
        BGE.S   APO2
        MOVE.W  6(A5),(A2)+        ;5
        MOVE.W  2(A5),(A2)+
        CLR.W   (A2)+
        MOVE.W  D1,(A2)+        ;1
        MOVE.W  2(A4),(A2)+
        CLR.W   (A2)+
        MOVE.W  D1,(A2)+        ;1
        MOVE.W  2(A4),(A2)+
        MOVE.W  #14*4,(A2)+
        CMP.L   #-1,8(A4)
        BNE.S   BRDC5
        MOVE.W  #16*4,-2(A2)
BRDC5:  MOVE.W  D1,(A2)+        ;1-5
        MOVE.W  2(A5),(A2)+
        CLR.W   (A2)+
        MOVE.L  22(A3),(A2)     ;5
        BSR     TRLIG
;BLOC 2
APO2:   LEA.L   preti+20(PC),A2
        MOVE.W  #6*8,(A2)+
        MOVE.W  10(A3),D0
        CMP.W   16(A3),D0
        BLE.S   APO3
        MOVE.W  D0,(A2)+        ;2
        MOVE.W  2(A4),(A2)+
        CLR.W   (A2)+
        MOVE.W  16(A3),(A2)+        ;6
        MOVE.W  2(A5),(A2)+
        CLR.W   (A2)+
        MOVE.W  16(A3),(A2)+        ;6
        MOVE.W  2(A5),(A2)+
        CLR.W   (A2)+
        MOVE.W  D0,(A2)+        ;2-6
        MOVE.W  2(A5),(A2)+
        MOVE.W  #14*4,(A2)+
        CMP.L   #-1,8(A4)
        BNE.S   BRDC6
        MOVE.W  #15*4,-2(A2)
BRDC6:  MOVE.L  22(A3),(A2)     ;2
        BSR     TRLIG
;BLOC 3
APO3:   CLR.W   -2(A3)
        LEA.L   preti+20(PC),A2
        MOVE.W  #7*8,(A2)+
        MOVE.W  8(A3),D0
        CMP.W   14(A3),D0
        BLE.S   APO4
        MOVE.W  D0,(A2)+        ;9
        MOVE.W  2(A4),(A2)+
        CLR.W   (A2)+
        MOVE.W  14(A3),(A2)+        ;11
        MOVE.W  2(A5),(A2)+
        MOVE.W  #1*4,(A2)+
        MOVE.W  14(A3),(A2)+        ;13
        MOVE.W  4(A3),(A2)+
        CLR.W   (A2)+
        MOVE.W  D0,(A2)+        ;15
        MOVE.W  (A3),(A2)+
        MOVE.W  #1*4,(A2)+
        CMP.L   #-1,8(A4)
        BNE.S   BRDC7
        MOVE.W  #12*4,-2(A2)
BRDC7:  MOVE.L  22(A3),(A2)     ;9
        BSR     TRLIG
; BLOC 4
APO4:   LEA.L   preti+20(PC),A2
        MOVE.W  #7*8,(A2)+
        MOVE.W  18(A3),D1
        CMP.W   12(A3),D1
        BLE.S   APO5
        MOVE.W  D1,(A2)+        ;12
        MOVE.W  2(A5),(A2)+
        CLR.W   (A2)+
        MOVE.W  12(A3),(A2)+        ;10
        MOVE.W  2(A4),(A2)+
        MOVE.W  #1*4,(A2)+
        CMP.L   #-1,8(A4)
        BNE.S   BRDC8
        MOVE.W  #13*4,-2(A2)
BRDC8:  MOVE.W  12(A3),(A2)+        ;16
        MOVE.W  (A3),(A2)+
        CLR.W   (A2)+
        MOVE.W  D1,(A2)+        ;14
        MOVE.W  4(A3),(A2)+
        MOVE.W  #1*4,(A2)+
        MOVE.L  22(A3),(A2)     ;12
        BSR     TRLIG
;BLOC 5
APO5:   MOVE.W  6(A5),D0
        MOVE.L  #RODEQU,A0
        MOVE.W  6(A4),(A0)
        CMP.L   #-1,8(A4)
        BNE.S   BRDC9
        CLR.W   (A0)
BRDC9:  MOVE.W  D0,2(A0)
        CMP.W   6(A4),D0
        BLE.S   APO6
        MOVE.W  2(A5),D7
        SUB.W   6(A3),D7
        MOVE.W  2(A5),D5
        BSR     CLIVECT
        BRA.S   APO7
        MOVE.L  #RODEQU,A0
        MOVE.W  #6*8,D6
        MOVEM.L A3-A5,-(SP)
        BSR     XPOLY
        MOVEM.L (SP)+,A3-A5
APO6:   MOVE.W  10(A3),D0
        MOVE.L  #RODEQU+4,A0
        MOVE.W  16(A3),(A0)
        MOVE.W  D0,2(A0)
        CMP.L   #-1,8(A4)
        BNE.S   BRDCA
        MOVE.W  #319,2(A0)
BRDCA:  CMP.W   16(A3),D0
        BLE.S   APO7
        MOVE.W  2(A5),D7
        SUB.W   6(A3),D7
        MOVE.W  2(A5),D5
        BSR     CLIVECT
        BRA.S   APO7
        MOVE.L  #RODEQU+4,A0
        MOVE.W  #6*8,D6
        MOVEM.L A3-A5,-(SP)
        BSR     XPOLY
        MOVEM.L (SP)+,A3-A5
APO7:   MOVE.W  6(A3),D0
        CMP.W   2(A3),D0
        BLT.S   FARPNTR
        MOVE.L  #RODEQU,A0
        MOVE.W  6(A0),2(A0)
        MOVE.W  6(A3),D7
        SUB.W   2(A3),D7
        MOVE.W  6(A3),D5
        BSR     CLIVECT
        BRA.S   FARPNTR
        MOVE.L  #RODEQU,A0
        MOVE.W  #6*8,D6
        MOVEM.L A3-A5,-(SP)
        BSR     XPOLY
        MOVEM.L (SP)+,A3-A5
FARPNTR:        RTS

;       A3=COORBAS  A5=ZAFEVT
AVPONT: MOVE.L  #RODEQU,A1
        MOVE.W  10(A3),D0
        MOVE.W  D0,D1
        ADD.W   D0,D0
        ADD.W   D1,D0
        LSR.W   #2,D0
        BEQ     FAVPONT
        SUB.W   D0,D1
        MOVE.W  6(A5),D2
        LEA.L   1000(A1),A0
        MOVE.W  D0,D7
        MOVEQ   #1,D6
        BSR     CHLVER
        MOVE.L  A1,A0
        MOVE.W  D0,D7
        ADD.W   D1,D7
        MOVEQ   #2,D6
        MOVE.W  10(A3),D2
        ADD.W   D2,D2
        SUBQ.W  #2,D2
        MOVE.W  6(A5),D4
        SUB.W   D2,D4
        BSR     CHLHOR
        MOVE.W  D0,D7
        MOVE.L  A1,A0
        MOVE.W  2(A5),D5
        BSR     CLIVECT
        BRA.S   PAV1
        MOVE.W  #13*8,D6
        MOVEM.L D0/D1/A1/A3/A5,-(SP)
        BSR     POLY
        MOVEM.L (SP)+,D0/D1/A1/A3/A5
PAV1:   
        MOVE.W  6+8(A5),D2
        MOVE.W  10(A3),D3
        ADD.W   D3,D3
        SUBQ.W  #2,D3
        MOVE.W  D2,D4
        ADD.W   D3,D4
        MOVE.L  A1,A0
        MOVE.W  D0,D7
        MOVEQ   #-1,D6
        BSR     CHLVER
        LEA.L   1000(A1),A0
        MOVE.W  D0,D7
        ADD.W   D1,D7
        MOVEQ   #-2,D6
        BSR     CHLHOR
        MOVE.W  D0,D7
        ADD.W   D1,D7
        MOVE.L  A1,A0
        MOVE.W  2(A5),D5
        BSR     CLIVECT
        BRA.S   FAVPONT
        MOVE.W  #13*8,D6
        MOVE.L  A5,-(SP)
        BSR     POLY
        MOVE.L  (SP)+,A5
FAVPONT: RTS

;       A4=ZAFEVT DEVANT   A5=ZAFEVT DERR
ARPONT: 
        CMP.L   #-1,8(A4)
        BNE.S   AVAR1
        SUB.W   #255+64,6(A4)
        ADD.W   #255+64,6+8(A4)
AVAR1:  LEA.L   preti-20(PC),A3
        CLR.W   D7
        MOVE.B  1(A4),D7
        ADDQ.W  #1,D7
        MOVE.W  D7,D6
        MOVE.W  D6,D5
        ADD.W   D6,D6
        ADD.W   D7,D6
        LSR.W   #2,D6
        BEQ.S   FAVPONT
        SUB.W   D6,D5
        CLR.W   D4
        MOVE.B  1(A5),D4
        ADDQ.W  #1,D4
        MOVE.W  D4,D3
        MOVE.W  D3,D2
        ADD.W   D3,D3
        ADD.W   D4,D3
        LSR.W   #2,D3
        SUB.W   D3,D2

        MOVE.W  2(A4),D0
        SUB.W   D6,D0
        MOVE.W  D0,(A3)+
        SUB.W   D5,D0
        MOVE.W  D0,(A3)+
        MOVE.W  2(A5),D0
        SUB.W   D3,D0
        MOVE.W  D0,(A3)+
        SUB.W   D2,D0
        MOVE.W  D0,(A3)+

        MOVE.W  6(A4),D0
        SUB.W   D7,D0
        SUB.W   D7,D0
        ADDQ.W  #2,D0
        MOVE.W  D0,(A3)+
        ADD.W   D6,D0
        ADD.W   D6,D0
        ADD.W   D5,D0
        ADD.W   D5,D0
        MOVE.W  D0,(A3)+
        MOVE.W  D6,D0
        LSR.W   #1,D0
        ADD.W   6(A4),D0
        MOVE.W  D0,(A3)+
        SUBQ.W  #1,D7
        MOVE.W  6+8(A4),D0
        MOVE.W  D0,(A3)+
        MOVE.W  D0,D1
        ADD.W   D7,D0
        ADD.W   D7,D0
        MOVE.W  D0,(A3)+
        SUB.W   D6,D0
        SUB.W   D6,D0
        SUB.W   D5,D0
        SUB.W   D5,D0
        MOVE.W  D0,(A3)+
        MOVE.W  D6,D0
        LSR.W   #1,D0
        NEG.W   D0
        ADD.W   D1,D0
        MOVE.W  D0,(A3)+

        MOVE.W  6(A5),D0
        SUB.W   D4,D0
        SUB.W   D4,D0
        ADDQ.W  #2,D0
        MOVE.W  D0,(A3)+
        ADD.W   D3,D0
        ADD.W   D3,D0
        ADD.W   D2,D0
        ADD.W   D2,D0
        MOVE.W  D0,(A3)+
        MOVE.W  D3,D0
        LSR.W   #1,D0
        ADD.W   6(A5),D0
        MOVE.W  D0,(A3)+
        SUBQ.W  #1,D4
        MOVE.W  6+8(A5),D0
        MOVE.W  D0,(A3)+
        MOVE.W  D0,D1
        ADD.W   D4,D0
        ADD.W   D4,D0
        MOVE.W  D0,(A3)+
        SUB.W   D3,D0
        SUB.W   D3,D0
        SUB.W   D2,D0
        SUB.W   D2,D0
        MOVE.W  D0,(A3)+
        MOVE.W  D3,D0
        LSR.W   #1,D0
        NEG.W   D0
        ADD.W   D1,D0
        MOVE.W  D0,(A3)

        LEA.L   preti-20(PC),A3
;PREM BLOC
APON1:  LEA.L   preti+20(PC),A2
        MOVE.W  #11*8,(A2)+
        MOVE.W  2(A4),D1
        SUB.W   2(A5),D1
        ASR.W   #1,D1
        ADD.W   6(A4),D1
        CMP.W   6(A5),D1
        BGE.S   APON2
        MOVE.W  6(A5),(A2)+        ;9
        MOVE.W  2(A5),(A2)+
        CLR.W   (A2)+
        MOVE.W  6(A4),(A2)+        ;1
        MOVE.W  2(A4),(A2)+
        MOVE.W  #2*4,(A2)+
        CMP.L   #-1,8(A4)
        BNE.S   BRDC0
        MOVE.W  #13*4,-2(A2)
BRDC0:  MOVE.W  12(A3),(A2)+        ;5
        MOVE.W  (A3),(A2)+
        CLR.W   (A2)+
        MOVE.W  26(A3),(A2)+        ;15
        MOVE.W  4(A3),(A2)+
        MOVE.W  #2*4,(A2)+
        MOVE.L  22+20(A3),(A2)     ;9
        BSR     TRLIG
;BLOC 2
APON2:  LEA.L   preti+20(PC),A2
        MOVE.W  #10*8,(A2)+
        MOVE.W  2(A5),D0
        SUB.W   2(A4),D0
        ASR.W   #1,D0
        ADD.W   14(A3),D0
        CMP.W   28(A3),D0
        BLE.S   APON3
        MOVE.W  14(A3),(A2)+        ;3
        MOVE.W  2(A4),(A2)+
        CLR.W   (A2)+
        MOVE.W  28(A3),(A2)+        ;11
        MOVE.W  2(A5),(A2)+
        MOVE.W  #3*4,(A2)+
        MOVE.W  34(A3),(A2)+        ;16
        MOVE.W  4(A3),(A2)+
        CLR.W   (A2)+
        MOVE.W  20(A3),(A2)+        ;6
        MOVE.W  (A3),(A2)+
        MOVE.W  #3*4,(A2)+
        CMP.L   #-1,8(A4)
        BNE.S   BRDC1
        MOVE.W  #12*4,-2(A2)
BRDC1:  MOVE.L  22+20(A3),(A2)     ;3
        BSR     TRLIG
;BLOC 3
APON3:  LEA.L   preti+20(PC),A2
        MOVE.W  #4*8,(A2)+
        MOVE.W  4(A3),D0
        CMP.W   (A3),D0
        BLT.S   APON4
        MOVE.W  26(A3),(A2)+        ;15
        MOVE.W  D0,(A2)+
        CLR.W   (A2)+
        MOVE.W  12(A3),(A2)+        ;5
        MOVE.W  (A3),(A2)+
        CLR.W   (A2)+
        MOVE.W  20(A3),(A2)+        ;6
        MOVE.W  (A3),(A2)+
        CLR.W   (A2)+
        MOVE.W  34(A3),(A2)+        ;16
        MOVE.W  D0,(A2)+
        CLR.W   (A2)+
        MOVE.L  22+20(A3),(A2)     ;15
        BSR     TRLIG
; BLOC 4
APON4:  LEA.L   preti+20(PC),A2
        MOVE.W  #4*8,(A2)+
        MOVE.W  2(A4),D1
        SUB.W   2(A5),D1
        ADD.W   D1,D1
        ADD.W   8(A3),D1
        CMP.W   22(A3),D1
        BLE.S   APON5
        MOVE.W  8(A3),(A2)+        ;2
        MOVE.W  2(A4),(A2)+
        CLR.W   (A2)+
        MOVE.W  22(A3),(A2)+        ;10
        MOVE.W  2(A5),(A2)+
        MOVE.W  #9*4,(A2)+
        MOVE.W  24(A3),(A2)+        ;13
        MOVE.W  6(A3),(A2)+
        CLR.W   (A2)+
        MOVE.W  10(A3),(A2)+        ;7
        MOVE.W  2(A3),(A2)+
        MOVE.W  #9*4,(A2)+
        MOVE.L  22+20(A3),(A2)     ;2
        BSR     TRLIG
;BLOC 5
APON5:  LEA.L   preti+20(PC),A2
        MOVE.W  #4*8,(A2)+
        MOVE.W  2(A5),D0
        SUB.W   2(A4),D0
        ADD.W   D0,D0
        ADD.W   16(A3),D0
        CMP.W   30(A3),D0
        BGE.S   APON6
        MOVE.W  30(A3),(A2)+        ;12
        MOVE.W  2(A5),(A2)+
        CLR.W   (A2)+
        MOVE.W  16(A3),(A2)+        ;4
        MOVE.W  2(A4),(A2)+
        MOVE.W  #6*4,(A2)+
        MOVE.W  18(A3),(A2)+        ;8
        MOVE.W  2(A3),(A2)+
        CLR.W   (A2)+
        MOVE.W  32(A3),(A2)+        ;14
        MOVE.W  6(A3),(A2)+
        MOVE.W  #6*4,(A2)+
        MOVE.L  22+20(A3),(A2)     ;12
        BSR     TRLIG
;BLOC 6
APON6:  LEA.L   preti+20(PC),A2
        MOVE.W  #4*8,(A2)+
        MOVE.W  2(A3),D0
        CMP.W   6(A3),D0
        BLT.S   FAPON
        MOVE.W  10(A3),(A2)+        ;7
        MOVE.W  D0,(A2)+
        CLR.W   (A2)+
        MOVE.W  24(A3),(A2)+        ;13
        MOVE.W  6(A3),(A2)+
        CLR.W   (A2)+
        MOVE.W  32(A3),(A2)+        ;14
        MOVE.W  6(A3),(A2)+
        CLR.W   (A2)+
        MOVE.W  18(A3),(A2)+        ;8
        MOVE.W  D0,(A2)+
        CLR.W   (A2)+
        MOVE.L  22+20(A3),(A2)     ;7
        BSR     TRLIG
FAPON:  RTS

;       A3=COORBAS  A5=ZAFEVT
AVTRBD: MOVE.L  #RODEQU,A1
        MOVE.W  10(A3),D1
        MOVE.W  D1,D3
        LSR.W   #1,D3
        MOVE.W  D3,D5
        LSR.W   #1,D5
        MOVE.L  A1,A0
        MOVE.W  D5,D6
        MOVE.W  6(A5),D2
        CMP.W   #319,D2
        BGT.S   PTRID
        BSR     CREALVM
        MOVE.W  D2,D4
        MOVEQ   #4,D6
        MOVE.W  D3,D7
        BSR     CHLHOR
        LEA.L   1000(A1),A0
        MOVE.W  D3,D6
        ADD.W   D5,D6
        MOVE.W  D6,D7
        ADD.W   D1,D1
        ADD.W   6(A5),D1
        BLT.S   PTRID
        MOVE.W  D1,D2
        BSR     CREALVM
        MOVE.W  2(A5),D5
        MOVE.L  A1,A0
        BSR     CLIVECT
        BRA.S   PTRID
        MOVE.W  #2*8,D6
        MOVE.L  A5,-(SP)
        BSR     POLY
        MOVE.L  (SP)+,A5
PTRID:  RTS
;       A4=ZAFEVT DEVANT   A5=ZAFEVT DERR
ARTRBD: 
        CMP.L   #-1,8(A4)
        BNE.S   AVAR2
        ADD.W   #255+670,6(A4)
AVAR2:  LEA.L   preti(PC),A3
        CMP.W   #319,6(A5)
        BGT.S   PTRID
        CLR.W   D7
        MOVE.B  1(A4),D7
        ADDQ.W  #1,D7
        MOVE.W  D7,D6
        LSR.W   #1,D6
        MOVE.W  D6,D5
        LSR.W   #1,D5
        CLR.W   D4
        MOVE.B  1(A5),D4
        ADDQ.W  #1,D4
        MOVE.W  D4,D3
        LSR.W   #1,D3
        MOVE.W  D3,D2
        LSR.W   #1,D2
        MOVE.W  2(A4),D0
        MOVE.W  D0,D1
        SUB.W   D5,D0
        MOVE.W  D0,(A3)+
        SUB.W   D6,D0
        MOVE.W  D0,(A3)+
        SUB.W   D7,D1
        MOVE.W  D1,(A3)+
        ADD.W   D7,D7
        ADD.W   6(A4),D7
        BLT.S   PTRID
        MOVE.W  D7,(A3)+
        MOVE.W  2(A5),D0
        MOVE.W  D0,D1
        SUB.W   D2,D0
        MOVE.W  D0,(A3)+
        SUB.W   D3,D0
        MOVE.W  D0,(A3)+
        SUB.W   D4,D1
        MOVE.W  D1,(A3)+
        ADD.W   D4,D4
        ADD.W   6(A5),D4
        MOVE.W  D4,(A3)
        LEA.L   preti(PC),A3
;PREM BLOC
ATRD1:  LEA.L   preti+20(PC),A2
        MOVE.W  #10*8,(A2)+
        MOVE.W  6(A4),D0
        MOVE.W  6(A5),D1
        CMP.W   D1,D0
        BLE.S   ATRD2
        MOVE.W  D0,(A2)+        ;1
        MOVE.W  2(A4),(A2)+
        CLR.W   (A2)+
        MOVE.W  D1,(A2)+        ;5
        MOVE.W  2(A5),(A2)+
        MOVE.W  #4,(A2)+
        MOVE.W  D1,(A2)+        ;6
        MOVE.W  8(A3),(A2)+
        CLR.W   (A2)+
        MOVE.W  D0,(A2)+        ;4
        MOVE.W  (A3),(A2)+
        MOVE.W  #4,(A2)+
        MOVE.L  22(A3),(A2)     ;1
        BSR     TRLIG
;BLOC 2
ATRD2:  LEA.L   preti+20(PC),A2
        MOVE.W  #11*8,(A2)+
        MOVE.W  (A3),D0
        SUB.W   8(A3),D0
        ASL.W   #2,D0
        ADD.W   6(A4),D0
        CMP.W   6(A5),D0
        BLE.S   ATRD3
        MOVE.W  6(A4),(A2)+        ;4
        MOVE.W  (A3),(A2)+
        CLR.W   (A2)+
        MOVE.W  6(A5),(A2)+        ;6
        MOVE.W  8(A3),(A2)+
        MOVE.W  #44,(A2)+
        MOVE.W  14(A3),(A2)+        ;7
        MOVE.W  10(A3),(A2)+
        CLR.W   (A2)+
        MOVE.W  6(A3),(A2)+        ;3
        MOVE.W  2(A3),(A2)+
        MOVE.W  #44,(A2)+
        MOVE.L  22(A3),(A2)     ;4
        BSR     TRLIG
;BLOC 3
ATRD3:  LEA.L   preti+20(PC),A2
        MOVE.W  #14*8,(A2)+
        MOVE.W  6(A3),D0
        MOVE.W  14(A3),D1
        CMP.W   D1,D0
        BLE.S   ATRD4
        MOVE.W  D0,(A2)+        ;3
        MOVE.W  2(A3),(A2)+
        CLR.W   (A2)+
        MOVE.W  D1,(A2)+        ;7
        MOVE.W  10(A3),(A2)+
        MOVE.W  #4,(A2)+
        MOVE.W  D1,(A2)+        ;11
        MOVE.W  12(A3),(A2)+
        CLR.W   (A2)+
        MOVE.W  D0,(A2)+        ;8
        MOVE.W  4(A3),(A2)+
        MOVE.W  #4,(A2)+
        MOVE.L  22(A3),(A2)     ;3
        BSR     TRLIG
;BLOC 4
ATRD4:  LEA.L   preti+20(PC),A2
        MOVE.W  #13*8,(A2)+
        MOVE.W  12(A3),D0
        CMP.W   4(A3),D0
        BLE.S   FATRD
        MOVE.W  6(A3),(A2)+        ;8
        MOVE.W  4(A3),(A2)+
        CLR.W   (A2)+
        MOVE.W  14(A3),(A2)+        ;11
        MOVE.W  12(A3),(A2)+
        CLR.W   (A2)+
        MOVE.W  6(A5),(A2)+        ;10
        MOVE.W  12(A3),(A2)+
        CLR.W   (A2)+
        MOVE.W  6(A4),(A2)+        ;9
        MOVE.W  4(A3),(A2)+
        CLR.W   (A2)+
        MOVE.L  22(A3),(A2)     ;8
        BSR     TRLIG
FATRD:  RTS

;       A3=COORBAS  A5=ZAFEVT
AVTRBG: MOVE.L  #RODEQU,A1
        MOVE.W  10(A3),D1
        MOVE.W  D1,D3
        LSR.W   #1,D3
        MOVE.W  D3,D5
        LSR.W   #1,D5
        LEA.L   1000(A1),A0
        MOVE.W  D5,D6
        MOVE.W  6(A5),D2
        BLT.S   FATRD
        BSR     CREALVM
        MOVE.W  D2,D4
        MOVEQ   #-4,D6
        MOVE.W  D3,D7
        BSR     CHLHOR
        MOVE.L  A1,A0
        MOVE.W  D3,D6
        ADD.W   D5,D6
        MOVE.W  D6,D7
        ADD.W   D1,D1
        MOVE.W  6(A5),D3
        SUB.W   D1,D3
        CMP.W   #319,D3
        BGT.S   FATRD
        MOVE.W  D3,D2
        BSR     CREALVM
        MOVE.W  2(A5),D5
        MOVE.L  A1,A0
        BSR     CLIVECT
        BRA.S   PTRIG
        MOVE.W  #2*8,D6
        MOVE.L  A5,-(SP)
        BSR     POLY
        MOVE.L  (SP)+,A5
PTRIG:  RTS
;       A4=ZAFEVT DEVANT   A5=ZAFEVT DERR
ARTRBG:  
        CMP.L   #-1,8(A4)
        BNE.S   AVAR3
        SUB.W   #255+670,6(A4)
AVAR3:  LEA.L   preti(PC),A3
        TST.W   6(A5)
        BLT.S   PTRIG
        CLR.W   D7
        MOVE.B  1(A4),D7
        ADDQ.W  #1,D7
        MOVE.W  D7,D6
        LSR.W   #1,D6
        MOVE.W  D6,D5
        LSR.W   #1,D5
        CLR.W   D4
        MOVE.B  1(A5),D4
        ADDQ.W  #1,D4
        MOVE.W  D4,D3
        LSR.W   #1,D3
        MOVE.W  D3,D2
        LSR.W   #1,D2
        MOVE.W  2(A4),D0
        MOVE.W  D0,D1
        SUB.W   D5,D0
        MOVE.W  D0,(A3)+
        SUB.W   D6,D0
        MOVE.W  D0,(A3)+
        SUB.W   D7,D1
        MOVE.W  D1,(A3)+
        ADD.W   D7,D7
        MOVE.W  6(A4),D0
        SUB.W   D7,D0
        CMP.W   #319,D0
        BGT.S   PTRIG
        MOVE.W  D0,(A3)+
        MOVE.W  2(A5),D0
        MOVE.W  D0,D1
        SUB.W   D2,D0
        MOVE.W  D0,(A3)+
        SUB.W   D3,D0
        MOVE.W  D0,(A3)+
        SUB.W   D4,D1
        MOVE.W  D1,(A3)+
        MOVE.W  6(A5),D0
        ADD.W   D4,D4
        SUB.W   D4,D0
        MOVE.W  D0,(A3)
        LEA.L   preti(PC),A3
;PREM BLOC
ATRG1:  LEA.L   preti+20(PC),A2
        MOVE.W  #10*8,(A2)+
        MOVE.W  6(A4),D0
        MOVE.W  6(A5),D1
        CMP.W   D1,D0
        BGE.S   ATRG2
        MOVE.W  D1,(A2)+        ;5
        MOVE.W  2(A5),(A2)+
        CLR.W   (A2)+
        MOVE.W  D0,(A2)+        ;1
        MOVE.W  2(A4),(A2)+
        MOVE.W  #4,(A2)+
        MOVE.W  D0,(A2)+        ;4
        MOVE.W  (A3),(A2)+
        CLR.W   (A2)+
        MOVE.W  D1,(A2)+        ;6
        MOVE.W  8(A3),(A2)+
        MOVE.W  #4,(A2)+
        MOVE.L  22(A3),(A2)     ;5
        BSR     TRLIG
;BLOC 2
ATRG2:  LEA.L   preti+20(PC),A2
        MOVE.W  #11*8,(A2)+
        MOVE.W  8(A3),D0
        SUB.W   (A3),D0
        ASL.W   #2,D0
        ADD.W   6(A4),D0
        CMP.W   6(A5),D0
        BGE.S   ATRG3
        MOVE.W  6(A5),(A2)+        ;6
        MOVE.W  8(A3),(A2)+
        CLR.W   (A2)+
        MOVE.W  6(A4),(A2)+        ;4
        MOVE.W  (A3),(A2)+
        MOVE.W  #16,(A2)+
        MOVE.W  6(A3),(A2)+        ;3
        MOVE.W  2(A3),(A2)+
        CLR.W   (A2)+
        MOVE.W  14(A3),(A2)+        ;7
        MOVE.W  10(A3),(A2)+
        MOVE.W  #16,(A2)+
        MOVE.L  22(A3),(A2)     ;6
        BSR     TRLIG
;BLOC 3
ATRG3:  LEA.L   preti+20(PC),A2
        MOVE.W  #14*8,(A2)+
        MOVE.W  6(A3),D0
        MOVE.W  14(A3),D1
        CMP.W   D1,D0
        BGE.S   ATRG4
        MOVE.W  D1,(A2)+        ;7
        MOVE.W  10(A3),(A2)+
        CLR.W   (A2)+
        MOVE.W  D0,(A2)+        ;3
        MOVE.W  2(A3),(A2)+
        MOVE.W  #4,(A2)+
        MOVE.W  D0,(A2)+        ;8
        MOVE.W  4(A3),(A2)+
        CLR.W   (A2)+
        MOVE.W  D1,(A2)+        ;11
        MOVE.W  12(A3),(A2)+
        MOVE.W  #4,(A2)+
        MOVE.L  22(A3),(A2)     ;7
        BSR     TRLIG
;BLOC 4
ATRG4:  LEA.L   preti+20(PC),A2
        MOVE.W  #13*8,(A2)+
        MOVE.W  12(A3),D0
        CMP.W   4(A3),D0
        BLE.S   FATRG
        MOVE.W  14(A3),(A2)+        ;11
        MOVE.W  12(A3),(A2)+
        CLR.W   (A2)+
        MOVE.W  6(A3),(A2)+        ;8
        MOVE.W  4(A3),(A2)+
        CLR.W   (A2)+
        MOVE.W  6(A4),(A2)+        ;9
        MOVE.W  4(A3),(A2)+
        CLR.W   (A2)+
        MOVE.W  6(A5),(A2)+        ;10
        MOVE.W  12(A3),(A2)+
        CLR.W   (A2)+
        MOVE.L  22(A3),(A2)     ;11
        BSR     TRLIG
FATRG:  RTS

;       A3=COORBAS  A5=ZAFEVT
AVGARA: MOVE.L  #RODEQU,A1
        MOVE.W  10(A3),D0
        MOVE.W  D0,D1
        MOVE.W  D1,D3
        LSR.W   #4,D3
        ADD.W   D1,D1
        ADD.W   D1,D1
        ADD.W   D0,D1
        LSR.W   #3,D1
        MOVE.L  A1,A0
        MOVE.W  D1,D6
        SUB.W   D3,D6
        SUBQ.W  #1,D6
        MOVE.W  6(A5),D2
        ADD.W   D0,D2
        BSR     CREALVM
        MOVE.W  D3,D6
        ADDQ.W  #2,D6
        MOVE.W  6(A5),D2
        CMP.W   #319,D2
        BGT.S   PGAR
        BSR     CREALVM
        LEA.L   1000(A1),A0
        ADD.W   D0,D2
        ADD.W   D1,D2
        MOVE.W  D2,D4
        BLT.S   PGAR
        MOVEQ   #-1,D6
        ADDQ.W  #1,D1
        MOVE.W  D1,D7
        BSR     CHLHOR
        MOVE.W  D1,D7
        MOVE.W  2(A5),D5
        MOVE.L  A1,A0
        BSR     CLIVECT
        RTS
        MOVE.W  #10*8,D6
        MOVE.L  A5,-(SP)
        BSR     POLY
        MOVE.L  (SP)+,A5
PGAR:   RTS
;       A4=ZAFEVT DEVANT   A5=ZAFEVT DERR
ARGARA:
        CMP.L   #-1,8(A4)
        BNE.S   AVAR4
        ADD.W   #255,6(A4)
AVAR4:  LEA.L   preti(PC),A3
        CMP.W   #319,6(A5)
        BGT.S   PGAR
        CLR.W   D7
        MOVE.B  1(A4),D7
        MOVE.W  D7,D6
        MOVE.W  D6,D5
        LSR.W   #4,D5
        ADD.W   D6,D6
        ADD.W   D6,D6
        ADD.W   D7,D6
        LSR.W   #3,D6
        CLR.W   D4
        MOVE.B  1(A5),D4
        MOVE.W  D4,D3
        MOVE.W  D3,D2
        LSR.W   #4,D2
        ADD.W   D3,D3
        ADD.W   D3,D3
        ADD.W   D4,D3
        LSR.W   #3,D3
        MOVE.W  2(A4),D0
        SUB.W   D6,D0
        MOVE.W  D0,(A3)+
        ADD.W   D5,D0
        MOVE.W  D0,(A3)+
        ADD.W   6(A4),D7
        MOVE.W  D7,(A3)+
        ADD.W   D6,D7
        BLT.S   PGAR
        MOVE.W  D7,(A3)+
        MOVE.W  2(A5),D0
        SUB.W   D3,D0
        MOVE.W  D0,(A3)+
        ADD.W   D2,D0
        MOVE.W  D0,(A3)+
        ADD.W   6(A5),D4
        MOVE.W  D4,(A3)+
        ADD.W   D3,D4
        MOVE.W  D4,(A3)

        LEA.L   preti(PC),A3
;PREM BLOC
AGAR1:
        MOVE.L  #RODEQU,A0
        MOVE.W  2(A5),D6
        SUB.W   8(A3),D6
        MOVE.W  D6,D7
        MOVE.W  12(A3),D2
        BSR     CREALVM
        MOVE.L  #RODEQU+1000,A0
        MOVE.W  14(A3),D2
        MOVEQ   #-1,D6
        MOVE.W  D7,D0
        BSR     CHLHOR
        MOVE.W  D0,D7
        MOVE.W  2(A5),D5
        MOVE.L  #RODEQU,A0
        BSR     CLIA4
        BRA.S   AGAR2
        MOVE.W  #10*8,D6
        MOVEM.L A3-A5,-(SP)
        BSR     POLY
        MOVEM.L (SP)+,A3-A5
;BLOC 2
AGAR2:  LEA.L   preti+20(PC),A2
        MOVE.W  #4*8,(A2)+
        MOVE.W  6(A3),D0
        ADD.W   2(A5),D0
        SUB.W   2(A4),D0
        CMP.W   14(A3),D0
        BLE.S   AGAR3
        MOVE.W  6(A3),D0
        MOVE.W  D0,(A2)+        ;2
        MOVE.W  2(A4),(A2)+
        CLR.W   (A2)+
        MOVE.W  14(A3),(A2)+        ;8
        MOVE.W  2(A5),(A2)+
        MOVE.W  #28,(A2)+
        MOVE.W  12(A3),(A2)+        ;9
        MOVE.W  8(A3),(A2)+
        CLR.W   (A2)+
        MOVE.W  4(A3),(A2)+        ;3
        MOVE.W  (A3),(A2)+
        MOVE.W  #28,(A2)+
        CMP.L   #-1,8(A4)
        BNE.S   BRDC2
        MOVE.W  #12*4,-2(A2)
BRDC2:  MOVE.L  22(A3),(A2)     ;2
        BSR     TRLIG
;BLOC 3
AGAR3:  LEA.L   preti+20(PC),A2
        MOVE.W  #11*8,(A2)+
        MOVE.W  10(A3),D0
        MOVE.W  2(A3),D1
        CMP.W   D1,D0
        BLT.S   AGAR4
        SUBQ.W  #1,D1
        MOVE.W  12(A3),(A2)+        ;12
        MOVE.W  D0,(A2)+
        CLR.W   (A2)+
        MOVE.W  6(A5),(A2)+        ;11
        MOVE.W  D0,(A2)+
        CLR.W   (A2)+
        MOVE.W  6(A4),(A2)+        ;5
        MOVE.W  D1,(A2)+
        CLR.W   (A2)+
        MOVE.W  4(A3),(A2)+        ;6
        MOVE.W  D1,(A2)+
        CLR.W   (A2)+
        MOVE.L  22(A3),(A2)     ;12
        BSR     TRLIG
;BLOC 4
AGAR4:  LEA.L   preti+20(PC),A2
        MOVE.W  #5*8,(A2)+
        MOVE.W  6(A4),D0
        CMP.W   6(A5),D0
        BLE.S   AGAR5
        MOVE.W  D0,(A2)+        ;5
        MOVE.W  2(A3),(A2)+
        CLR.W   (A2)+
        MOVE.W  6(A5),(A2)+        ;11
        MOVE.W  10(A3),(A2)+
        MOVE.W  #4,(A2)+
        MOVE.W  6(A5),(A2)+        ;10
        MOVE.W  8(A3),(A2)+
        CLR.W   (A2)+
        MOVE.W  D0,(A2)+        ;4
        MOVE.W  (A3),(A2)+
        CLR.W   (A2)+
        MOVE.L  22(A3),(A2)     ;5
        BSR     TRLIG
;BLOC 5
AGAR5:  LEA.L   preti+20(PC),A2
        MOVE.W  #5*8,(A2)+
        MOVE.W  4(A3),D0
        CMP.W   12(A3),D0
        BGE.S   FAGAR
        MOVE.W  12(A3),(A2)+        ;12
        MOVE.W  10(A3),(A2)+
        CLR.W   (A2)+
        MOVE.W  D0,(A2)+        ;6
        MOVE.W  2(A3),(A2)+
        MOVE.W  #4,(A2)+
        MOVE.W  D0,(A2)+        ;3
        MOVE.W  (A3),(A2)+
        CLR.W   (A2)+
        MOVE.W  12(A3),(A2)+        ;9
        MOVE.W  8(A3),(A2)+
        CLR.W   (A2)+
        MOVE.L  22(A3),(A2)     ;12
        BSR     TRLIG
FAGAR:  RTS

;       A3=COORBAS  A5=ZAFEVT
AVPNT2: MOVE.L  #RODEQU,A1
        MOVE.W  10(A3),D0
        MOVE.W  D0,D1
        ADD.W   D0,D0
        ADD.W   D0,D0
        ADD.W   D1,D0
        LSR.W   #3,D0
        BEQ.S   FAGAR
        LSR.W   #3,D1
        ADDQ.W  #1,D1
        MOVE.W  6(A5),D4
        LEA.L   1000(A1),A0
        MOVE.W  D0,D7
        ADD.W   D1,D7
        MOVEQ   #-1,D6
        BSR     CHLHOR
        MOVE.L  A1,A0
        MOVE.W  10(A3),D2
        ADD.W   D2,D2
        ADD.W   10(A3),D2
        ADD.W   D0,D2
        ADD.W   D1,D2
        MOVE.W  6(A5),D4
        SUB.W   D2,D4
        MOVE.W  D0,D7
        ADD.W   D1,D7
        MOVEQ   #4,D6
        BSR     CHLHOR
        MOVE.W  D0,D7
        ADD.W   D1,D7
        MOVE.L  A1,A0
        MOVE.W  2(A5),D5
        BSR     CLIVECT
        BRA.S   PAN1
        MOVE.W  #3*8,D6
        MOVEM.L D0/D1/A1/A3/A5,-(SP)
        BSR     POLY
        MOVEM.L (SP)+,D0/D1/A1/A3/A5
PAN1:   
        MOVE.L  A1,A0
        MOVE.W  6+8(A5),D2
        MOVE.W  D2,D4
        MOVE.W  D0,D7
        ADD.W   D1,D7
        MOVEQ   #1,D6
        BSR     CHLHOR
        LEA.L   1000(A1),A0
        MOVE.W  10(A3),D7
        ADD.W   D7,D7
        ADD.W   10(A3),D7
        ADD.W   D1,D7
        ADD.W   D0,D7
        MOVE.W  D2,D4
        ADD.W   D7,D4
        MOVE.W  D0,D7
        ADD.W   D1,D7
        MOVEQ   #-4,D6
        BSR     CHLHOR
        MOVE.W  D0,D7
        ADD.W   D1,D7
        MOVE.L  A1,A0
        MOVE.W  2(A5),D5
        BSR     CLIVECT
        BRA.S   PAN2
        MOVE.W  #3*8,D6
        MOVEM.L D0/D1/D2/A1/A3/A5,-(SP)
        BSR     POLY
        MOVEM.L (SP)+,D0/D1/D2/A1/A3/A5
PAN2:
        MOVE.W  6(A5),D4
        MOVE.L  A1,A0
        SUB.W   D0,D4
        MOVE.W  D1,D7
        MOVEQ   #-1,D6
        BSR     CHLHOR
        LEA.L   1000(A1),A0
        MOVE.W  D2,D4
        ADD.W   D0,D4
        MOVE.W  D1,D7
        MOVEQ   #1,D6
        BSR     CHLHOR
        MOVE.W  D1,D7
        MOVE.L  A1,A0
        MOVE.W  2(A5),D5
        SUB.W   D0,D5
        BSR     CLIVECT
        BRA.S   FAVPT2
        MOVE.W  #11*8,D6
        MOVE.L  A5,-(SP)
        BSR     POLY
        MOVE.L  (SP)+,A5
FAVPT2: RTS
;       A4=ZAFEVT DEVANT   A5=ZAFEVT DERR
ARPNT2: 
        CMP.L   #-1,8(A4)
        BNE.S   AVAR5
        SUB.W   #255+64,6(A4)
        ADD.W   #255+64,6+8(A4)
AVAR5:  LEA.L   preti(PC),A3
        CLR.W   D7
        MOVE.B  1(A4),D7
        ADDQ.W  #1,D7
        MOVE.W  D7,D6
        ADD.W   D7,D7
        ADD.W   D7,D7
        ADD.W   D6,D7
        LSR.W   #3,D7
        BEQ.S   FAVPT2
        LSR.W   #3,D6
        CLR.W   D5
        MOVE.B  1(A5),D5
        ADDQ.W  #1,D5
        MOVE.W  D5,D4
        ADD.W   D5,D5
        ADD.W   D5,D5
        ADD.W   D4,D5
        LSR.W   #3,D5
        LSR.W   #3,D4

        MOVE.W  2(A4),D0
        SUB.W   D7,D0
        MOVE.W  D0,(A3)+
        MOVE.W  2(A5),D0
        SUB.W   D5,D0
        MOVE.W  D0,(A3)+
        MOVE.W  6+8(A4),D0
        MOVE.W  D0,(A3)+
        ADD.W   D7,D0
        MOVE.W  D0,(A3)+
        MOVE.W  6(A4),D0
        SUB.W   D7,D0
        MOVE.W  D0,(A3)+
        MOVE.W  6+8(A5),D0
        MOVE.W  D0,(A3)+
        ADD.W   D5,D0
        MOVE.W  D0,(A3)+
        MOVE.W  6(A5),D0
        SUB.W   D5,D0
        MOVE.W  D0,(A3)  

        LEA.L   preti(PC),A3
;PREM BLOC
APT21:  LEA.L   preti+20(PC),A2
        MOVE.W  #13*8,(A2)+
        MOVE.W  6(A4),D1
        ADD.W   2(A5),D1
        SUB.W   2(A4),D1
        CMP.W   6(A5),D1
        BGE.S   APT22
        MOVE.W  6(A5),(A2)+        ;2
        MOVE.W  2(A5),(A2)+
        CLR.W   (A2)+
        MOVE.W  6(A4),(A2)+        ;1
        MOVE.W  2(A4),(A2)+
        MOVE.W  #7*4,(A2)+
        CMP.L   #-1,8(A4)
        BNE.S   BRDC3
        MOVE.W  #13*4,-2(A2)
BRDC3:  MOVE.W  8(A3),(A2)+        ;5
        MOVE.W  (A3),(A2)+
        CLR.W   (A2)+
        MOVE.W  14(A3),(A2)+        ;6
        MOVE.W  2(A3),(A2)+
        MOVE.W  #7*4,(A2)+
        MOVE.L  22(A3),(A2)     ;2
        BSR     TRLIG
;BLOC 2
APT22:  LEA.L   preti+20(PC),A2
        MOVE.W  #13*8,(A2)+
        MOVE.W  4(A3),D0
        ADD.W   2(A4),D0
        SUB.W   2(A5),D0
        CMP.W   10(A3),D0
        BLE.S   APT23
        MOVE.W  4(A3),(A2)+        ;3
        MOVE.W  2(A4),(A2)+
        CLR.W   (A2)+
        MOVE.W  10(A3),(A2)+        ;4
        MOVE.W  2(A5),(A2)+
        MOVE.W  #8*4,(A2)+
        MOVE.W  12(A3),(A2)+        ;8
        MOVE.W  2(A3),(A2)+
        CLR.W   (A2)+
        MOVE.W  6(A3),(A2)+        ;7
        MOVE.W  (A3),(A2)+
        MOVE.W  #8*4,(A2)+
        CMP.L   #-1,8(A4)
        BNE.S   BRDC4
        MOVE.W  #12*4,-2(A2)
BRDC4:  MOVE.L  22(A3),(A2)     ;3
        BSR     TRLIG
;BLOC 3
APT23:  LEA.L   preti+20(PC),A2
        MOVE.W  #10*8,(A2)+
        MOVE.W  (A3),D0
        CMP.W   2(A3),D0
        BGT.S   FAPT2
        MOVE.W  14(A3),(A2)+        ;6
        MOVE.W  2(A3),(A2)+
        CLR.W   (A2)+
        MOVE.W  8(A3),(A2)+        ;5
        MOVE.W  D0,(A2)+
        CLR.W   (A2)+
        MOVE.W  6(A3),(A2)+        ;7
        MOVE.W  D0,(A2)+
        CLR.W   (A2)+
        MOVE.W  12(A3),(A2)+        ;8
        MOVE.W  2(A3),(A2)+
        CLR.W   (A2)+
        MOVE.L  22(A3),(A2)     ;6
        BSR     TRLIG
FAPT2:  RTS

;       A3=COORBAS  A5=ZAFEVT
AVPLAQ: MOVE.L  #RODEQU,A1
        MOVE.W  10(A3),D0
        MOVE.W  D0,D1
        ADD.W   D0,D0
        ADD.W   D0,D0
        ADD.W   D1,D0
        LSR.W   #3,D0
        BEQ.S   FAPT2
        ADDQ.W  #4,D1
        LSR.W   #3,D1
        MOVE.W  6(A5),D2
        MOVE.L  A1,A0
        MOVE.W  D1,D6
        BSR     CREALVM
        LEA.L   1000(A1),A0
        MOVE.W  6+8(A5),D2
        MOVE.W  D1,D6
        BSR     CREALVM
        MOVE.W  D1,D7
        MOVE.L  A1,A0
        MOVE.W  2(A5),D5
        SUB.W   D0,D5
        BSR     CLIVECT
        BRA.S   FAVPLA
        MOVE.W  #5*8,D6
        MOVEM.L D0/D1/A1/A3/A5,-(SP)
        BSR     POLY
        MOVEM.L (SP)+,D0/D1/A1/A3/A5
FAVPLA: RTS

;       A4=ZAFEVT DEVANT   A5=ZAFEVT DERR
ARPLAQ: 
        CMP.L   #-1,8(A4)
        BNE.S   AVAR6
        SUB.W   #255+128,6(A4)
        ADD.W   #255+128,6+8(A4)
AVAR6:  LEA.L   preti(PC),A3
        CLR.W   D7
        MOVE.B  1(A4),D7
        ADDQ.W  #1,D7
        MOVE.W  D7,D6
        ADD.W   D7,D7
        ADD.W   D7,D7
        ADD.W   D6,D7
        LSR.W   #3,D7
        BEQ.S   FAVPLA
        LSR.W   #3,D6

        CLR.W   D5
        MOVE.B  1(A5),D5
        ADDQ.W  #1,D5
        MOVE.W  D5,D4
        ADD.W   D5,D5
        ADD.W   D5,D5
        ADD.W   D4,D5
        LSR.W   #3,D5
        LSR.W   #3,D4

        MOVE.W  2(A4),D0
        SUB.W   D7,D0
        MOVE.W  D0,(A3)+
        SUB.W   D6,D0
        MOVE.W  D0,(A3)+
        MOVE.W  2(A5),D0
        SUB.W   D5,D0
        MOVE.W  D0,(A3)+
        SUB.W   D4,D0
        MOVE.W  D0,(A3)+
        MOVE.W  6+8(A4),(A3)+
        MOVE.W  6+8(A5),(A3)

        LEA.L   preti(PC),A3
;PREM BLOC
APLA1:  LEA.L   preti+20(PC),A2
        MOVE.W  #4*8,(A2)+
        MOVE.W  4(A3),D1
        CMP.W   (A3),D1
        BLT.S   APLA2
        MOVE.W  6(A5),(A2)+        ;4
        MOVE.W  D1,(A2)+
        CLR.W   (A2)+
        MOVE.W  6(A4),(A2)+        ;1
        MOVE.W  (A3),(A2)+
        CLR.W   (A2)+
        MOVE.W  8(A3),(A2)+        ;2
        MOVE.W  (A3),(A2)+
        CLR.W   (A2)+
        MOVE.W  10(A3),(A2)+        ;3
        MOVE.W  D1,(A2)+
        CLR.W   (A2)+
        MOVE.L  22(A3),(A2)     ;4
        BSR     TRLIG
;BLOC 2
APLA2:  LEA.L   preti+20(PC),A2
        MOVE.W  #9*8,(A2)+
        MOVE.W  6(A5),D0
        CMP.W   6(A4),D0
        BGT.S   APLA3
        MOVE.W  6(A4),(A2)+        ;1
        MOVE.W  (A3),(A2)+
        CLR.W   (A2)+
        MOVE.W  D0,(A2)+        ;4
        MOVE.W  4(A3),(A2)+
        MOVE.W  #4,(A2)+
        MOVE.W  6(A5),(A2)+        ;7
        MOVE.W  6(A3),(A2)+
        CLR.W   (A2)+
        MOVE.W  6(A4),(A2)+        ;5
        MOVE.W  2(A3),(A2)+
        MOVE.W  #4,(A2)+
        MOVE.L  22(A3),(A2)     ;1
        BSR     TRLIG
;BLOC 3
APLA3:  LEA.L   preti+20(PC),A2
        MOVE.W  #9*8,(A2)+
        MOVE.W  8(A3),D0
        CMP.W   10(A3),D0
        BGT.S   APLA4
        MOVE.W  10(A3),(A2)+        ;3
        MOVE.W  4(A3),(A2)+
        CLR.W   (A2)+
        MOVE.W  D0,(A2)+        ;2
        MOVE.W  (A3),(A2)+
        MOVE.W  #4,(A2)+
        MOVE.W  D0,(A2)+        ;6
        MOVE.W  2(A3),(A2)+
        CLR.W   (A2)+
        MOVE.W  10(A3),(A2)+        ;8
        MOVE.W  6(A3),(A2)+
        MOVE.W  #4,(A2)+
        MOVE.L  22(A3),(A2)     ;3
        BSR     TRLIG
;BLOC 4
APLA4:  LEA.L   preti+20(PC),A2
        MOVE.W  #4*8,(A2)+
        MOVE.W  2(A3),D0
        CMP.W   6(A3),D0
        BLT.S   FAPLA
        MOVE.W  6(A4),(A2)+        ;5
        MOVE.W  D0,(A2)+
        CLR.W   (A2)+
        MOVE.W  6(A5),(A2)+        ;7
        MOVE.W  6(A3),(A2)+
        CLR.W   (A2)+
        MOVE.W  10(A3),(A2)+        ;8
        MOVE.W  6(A3),(A2)+
        CLR.W   (A2)+
        MOVE.W  8(A3),(A2)+        ;6
        MOVE.W  D0,(A2)+
        CLR.W   (A2)+
        MOVE.L  22(A3),(A2)     ;7
        BSR     TRLIG
FAPLA:  RTS

TRLIG:  LEA.L   preti+22(PC),A2
        MOVE.L  A2,A1
        MOVE.L  #RODEQU,A0
        MOVE.W  #3,D0
        MOVE.W  2(A2),D6
        SUB.W   8(A2),D6
        BGE.S   PODEPB
        LEA.L   6(A2),A2
        MOVE.L  A2,A1
        MOVE.L  (A2),24(A2)
        MOVE.W  -2(A2),22(A2)
        MOVE.W  2(A2),D6
        SUB.W   8(A2),D6
        BRA.S   PODEPB
TRMONT: MOVE.W  2(A2),D6
        SUB.W   8(A2),D6
        BLT.S   TRDES1
PODEPB: BGT.S   S1TRMON
        TST.W   4(A2)
        BEQ.S   STRMONT
S1TRMON: MOVE.W  (A2),D2
        MOVE.W  6(A2),D5
        SUB.W   D2,D5
        MOVE.W  4(A2),D3
        JSR     RTTR(PC,D3.W)
STRMONT:
        LEA.L   6(A2),A2
        DBF     D0,TRMONT
ERROR:  RTS
TRDES1: LEA.L   18(A1),A2
        MOVE.L  #RODEQU+1000,A0
TRDESC: MOVE.W  8(A2),D6
        SUB.W   2(A2),D6
        BLT.S   ERROR   ;A VIRER
        BGT.S   S1TRDE
        TST.W   4(A2)
        BEQ.S   STRDES
S1TRDE: MOVE.W  6(A2),D2
        MOVE.W  (A2),D5
        SUB.W   D2,D5
        MOVE.W  4(A2),D3
        JSR     RTTR(PC,D3.W)
STRDES: LEA.L   -6(A2),A2
        DBF     D0,TRDESC
;        MOVE.W  -1002(A0),D7
;        CMP.W   -2(A0),D7
;        BLE.S   POINTO
;        MOVE.W  D7,-2(A0)
POINTO: MOVE.L  A0,D7
        MOVE.L  #RODEQU,A0
        MOVE.W  2(A1),D5
        SUB.L   #RODEQU+1000,D7
        LSR.W   #1,D7
        BSR     CLIA4
        RTS
        MOVE.W  preti+20(PC),D6
        MOVEM.L A3-A5,-(SP)
        BSR     POLY
        MOVEM.L (SP)+,A3-A5
        RTS
RTTR:   BRA.L   CREAL
        BRA.L   CREALV
        BRA.L   RCHV1
        BRA.L   RCHVM1
        BRA.L   RCHHM4
        BRA.L   RCHHM3
        BRA.L   RCHHM2
        BRA.L   RCHHM1
        BRA.L   RCHH1
        BRA.L   RCHH2
        BRA.L   RCHH3
        BRA.L   RCHH4
        BRA.L   TTDRT
        BRA.L   TTGCH
        BRA.L   CREALVM
        BRA.L   TTDRTM
        BRA.L   TTGCHM
TTDRTM: SUBQ.W #1,D6
        BLT.S   FTTDG
TTDRT:  MOVE.W  #640,D2
        LSR.W   #1,D6
        BCC.S   B3LV
B2LV:   MOVE.W  D2,(A0)+
B3LV:   MOVE.W  D2,(A0)+
        DBF     D6,B2LV
FTTDG:  RTS
TTGCHM: SUBQ.W #1,D6
        BLT.S   FTTDG
TTGCH:  MOVE.W  #-320,D2
        LSR.W   #1,D6
        BCC.S   B5LV
B4LV:   MOVE.W  D2,(A0)+
B5LV:   MOVE.W  D2,(A0)+
        DBF     D6,B4LV
        RTS
RCHV1:  MOVE.W  D6,D7
        MOVEQ   #1,D6
        BRA     CHLVERB
RCHVM1: MOVE.W  D6,D7
        MOVEQ   #-1,D6
        BRA     CHLVERB
RCHHM4: MOVE.W  D2,D4
        MOVE.W  D6,D7
        MOVEQ   #-4,D6
        BRA     CHLHORB
RCHHM3: MOVE.W  D2,D4
        MOVE.W  D6,D7
        MOVEQ   #-3,D6
        BRA     CHLHORB
RCHHM2: MOVE.W  D2,D4
        MOVE.W  D6,D7
        MOVEQ   #-2,D6
        BRA     CHLHORB
RCHHM1: MOVE.W  D2,D4
        MOVE.W  D6,D7
        MOVEQ   #-1,D6
        BRA     CHLHORB
RCHH1:  MOVE.W  D2,D4
        MOVE.W  D6,D7
        MOVEQ   #1,D6
        BRA     CHLHORB
RCHH2:  MOVE.W  D2,D4
        MOVE.W  D6,D7
        MOVEQ   #2,D6
        BRA     CHLHORB
RCHH3:  MOVE.W  D2,D4
        MOVE.W  D6,D7
        MOVEQ   #3,D6
        BRA     CHLHORB
RCHH4:  MOVE.W  D2,D4
        MOVE.W  D6,D7
        MOVEQ   #4,D6
        BRA     CHLHORB

CREALVM: SUBQ.W #1,D6
        BGE.S   CREALV
        RTS
CREALV: LSR.W   #1,D6
        BCC.S   B1LV
B0LV:   MOVE.W  D2,(A0)+
B1LV:   MOVE.W  D2,(A0)+
        DBF     D6,B0LV
        RTS

CREAL:  TST.W   D5
        BLT.S   CREALG
        BEQ.S   CREALVM
        ADDQ.W  #1,D5
        ADDQ.W  #1,D6
        CMP.W   D5,D6
        BGE.S   LVERD
        SUBQ.W  #1,D2
        EXT.L   D5
        LSL.W   #5,D5
        DIVU    D6,D5
        SUBQ.W  #2,D6
        MOVE.W  D5,D4
        LSR.W   #5,D5
        AND.W   #$1F,D4
        MOVEQ   #-16,D3
BCLHD:  ADD.W   D5,D2
        ADD.W   D4,D3
        BLT.S   SCLHD
        SUB.W   #32,D3
        ADDQ.W  #1,D2
SCLHD:  MOVE.W  D2,(A0)+
        DBF     D6,BCLHD
        RTS
LVERD:  MOVE.W  D5,D3
        SUB.W   D6,D3
        ADD.W   D3,D3
        ADD.W   D5,D5
        MOVE.W  D3,D4
        SUBQ.W  #2,D6
BCLVD:  MOVE.W  D2,(A0)+
        TST.W   D4
        BLT.S   SCLVD
        ADD.W   D3,D4
        ADDQ.W  #1,D2
        DBF     D6,BCLVD
        RTS
SCLVD:  ADD.W   D5,D4
        DBF     D6,BCLVD
        RTS
CREALG: NEG.W   D5
        ADDQ.W  #1,D5
        ADDQ.W  #1,D6
        CMP.W   D5,D6
        BGE.S   LVERG
        ADDQ.W  #1,D2
        EXT.L   D5
        LSL.W   #5,D5
        DIVU    D6,D5
        SUBQ.W  #2,D6
        MOVE.W  D5,D4
        LSR.W   #5,D5
        AND.W   #$1F,D4
        MOVEQ   #-16,D3
BCLHG:  SUB.W   D5,D2
        ADD.W   D4,D3
        BLT.S   SCLHG
        SUB.W   #32,D3
        SUBQ.W  #1,D2
SCLHG:  MOVE.W  D2,(A0)+
        DBF     D6,BCLHG
        RTS
LVERG:  MOVE.W  D5,D3
        SUB.W   D6,D3
        ADD.W   D3,D3
        ADD.W   D5,D5
        MOVE.W  D3,D4
        SUBQ.W  #2,D6
BCLVG:  MOVE.W  D2,(A0)+
        TST.W   D4
        BLT.S   SCLVG
        ADD.W   D3,D4
        SUBQ.W  #1,D2
        DBF     D6,BCLVG
        RTS
SCLVG:  ADD.W   D5,D4
        DBF     D6,BCLVG
        RTS

CHLVER: SUBQ.W  #1,D7
        BGE.S   CHLVERB
        RTS
CHLVERB: LSR.W   #1,D7
        BCC.S   B1VER
B0VER:  MOVE.W  D2,(A0)+
B1VER:  MOVE.W  D2,(A0)+
        ADD.W   D6,D2
        DBF     D7,B0VER
        RTS
CHLHOR: SUBQ.W  #1,D7
        BGE.S   CHLHORB
        RTS
CHLHORB: LSR.W   #1,D7
        BCC.S   B1HOR
B0HOR:  MOVE.W  D4,(A0)+
        ADD.W   D6,D4
B1HOR:  MOVE.W  D4,(A0)+
        ADD.W   D6,D4
        DBF     D7,B0HOR
        RTS
CLIVECT:
        CLR.W   D3
        MOVE.B  4(A5),D3
        BRA.S   CLI45
CLIA4:  CLR.W   D3
        MOVE.B  4(A4),D3
CLI45:  SUB.W   D5,D3
        BGT.S   CLIHVE
        NEG.W   D3
        ADDQ.W  #1,D3
        SUB.W   D3,D5
        SUB.W   D3,D7
        BLE.S   FCLIVE
        ADD.W   D3,D3
        ADD.W   D3,A0
CLIHVE: MOVE.W  D5,D6
        SUB.W   D7,D6
        SUB.W   #banner,D6
        BGE.S   CLIST
        ADD.W   D6,D7
        BLE.S   FCLIVE
CLIST:  ADDQ.L  #2,(A7)
FCLIVE: RTS
XPOLY:  LEA.L   COULEUR(PC),A4
        ADD.W   D6,A4
        MOVE.L  (A4)+,D2
        MOVE.L  (A4),D3
        MOVE.L  D2,A2
        MOVE.L  D3,A3
        LEA.L   MPOLY(PC),A4
        LEA.L   IPOLY(PC),A1
        ADD.W   D6,A1
        MOVE.L  (A1),XMAF1-MPOLY(A4)
        MOVE.L  128(A1),XMAF2-MPOLY(A4)
        MOVE.L  (A1),XMAF3-MPOLY(A4)
        MOVE.L  128(A1),XMAF5-MPOLY(A4)
        MOVE.L  (A1)+,XMAF4-MPOLY(A4)
        MOVE.L  (A1),XMAF1-MPOLY+4(A4)
        MOVE.L  128(A1),XMAF2-MPOLY+4(A4)
        MOVE.L  (A1),XMAF3-MPOLY+4(A4)
        MOVE.L  128(A1),XMAF5-MPOLY+4(A4)
        MOVE.L  (A1),XMAF4-MPOLY+4(A4)
        MOVE.L  CURSCR,A5
        MULU    #160,D5
        ADDQ.W  #8,D5
        ADD.W   D5,A5
        SUBQ.W  #1,D7
        BGE.S   XAFLIG
        RTS
XAF0:   CLR.W   D0
        MOVE.W  D0,D1
        BRA.S   XAF1
XFAF2:
;  MOVE.B  #1,coorbas+4
        RTS
XAF2:   MOVEQ   #19,D6
        MOVEQ   #30,D1
        BRA.S   XAF3
XAFLIG: MOVE.L  A5,A1
        MOVE.W  (A0)+,D0
        BLT.S   XAF0
        CMP.W   #319,D0
        BGT.S   XFAF2
        MOVE.W  D0,D1
        LSR.W   #4,D0
        AND.W   #$F,D1
        ADD.W   D1,D1
XAF1:   MOVE.W  0(A4,D1.W),D4
        MOVE.W  (A0),D6
        BLT.S   XFAF2
        CMP.W   #319,D6
        BGT.S   XAF2
        MOVE.W  D6,D1
        LSR.W   #4,D6
        AND.W   #$F,D1
        ADD.W   D1,D1
XAF3:   MOVE.W  2(A4,D1.W),D5
        SUB.W   D6,D0
        BGE.L   XAF4
        MOVE.W  D5,D1
        NOT.W   D5
        LSL.W   #3,D6
        ADD.W   D6,A1
        MOVE.W  D4,D6
        NOT.W   D6
        ADDQ.W  #1,D0
        BEQ.S   XMAF4
        BCLR    #0,D0
        BEQ.S   XSAF5
        ADDQ.W  #2,D0
        LEA.L   AFIMP(PC),A4
        ADD.W   D0,D0
        LEA.L   XMAF2(PC,D0.W),A0
        BRA.S   XSSAF5
XSAF5:  ADD.W   D0,D0
        LEA.L   XMAF2(PC,D0.W),A4
XSSAF5: MOVE.L  A1,A5

XMAF1:  AND.W   D5,-(A1)
        OR.W    D1,-(A1)
        AND.W   D5,-(A1)
        OR.W    D1,-(A1)
        JMP     (A4)
        NOP
AFIMP:  MOVE.L  D3,-(A1)
        MOVE.L  D2,-(A1)
        JMP     (A0)
        MOVEM.L D2-D3/A2-A3,-(A1)
        MOVEM.L D2-D3/A2-A3,-(A1)
        MOVEM.L D2-D3/A2-A3,-(A1)
        MOVEM.L D2-D3/A2-A3,-(A1)
        MOVEM.L D2-D3/A2-A3,-(A1)
        MOVEM.L D2-D3/A2-A3,-(A1)
        MOVEM.L D2-D3/A2-A3,-(A1)
        MOVEM.L D2-D3/A2-A3,-(A1)
        MOVEM.L D2-D3/A2-A3,-(A1)
XMAF2:  AND.W   D4,-(A1)
        OR.W    D6,-(A1)
        AND.W   D4,-(A1)
        OR.W    D6,-(A1)
        LEA.L   -160(A5),A5
        MOVE.L  A5,A1
        DBF     D7,XMAF1
        RTS
;AFF SANS MOT COMPLET
XMAF4:  AND.W   D5,-(A1)
        OR.W    D1,-(A1)
        AND.W   D5,-(A1)
        OR.W    D1,-(A1)
XMAF5:  AND.W   D4,-(A1)
        OR.W    D6,-(A1)
        AND.W   D4,-(A1)
        OR.W    D6,-(A1)
        LEA.L   -144(A1),A1
        DBF     D7,XMAF4
        RTS

;AFF SUR PREM MOT
XAF4:   NOT.W   D4
        OR.W    D4,D5    
        MOVE.W  D5,D1
        NOT.W   D5
        LSL.W   #3,D6
        ADD.W   D6,A1
XMAF3:  AND.W   D5,-(A1)
        OR.W    D1,-(A1)
        AND.W   D5,-(A1)
        OR.W    D1,-(A1)
        LEA.L   -152(A1),A1
        DBF     D7,XMAF3
        RTS
POLY:   LEA.L   COULEUR(PC),A4
        ADD.W   D6,A4
        MOVE.L  (A4)+,D2
        MOVE.L  (A4),D3
        MOVE.L  D2,A2
        MOVE.L  D3,A3
        LEA.L   MPOLY(PC),A4
        LEA.L   IPOLY(PC),A1
        ADD.W   D6,A1
        MOVE.L  (A1),MAF1-MPOLY(A4)
        MOVE.L  (A1),MAF3-MPOLY(A4)
        MOVE.L  (A1)+,MAF2-MPOLY(A4)
        MOVE.L  (A1),MAF1-MPOLY+4(A4)
        MOVE.L  (A1),MAF3-MPOLY+4(A4)
        MOVE.L  (A1),MAF2-MPOLY+4(A4)
        MOVE.L  CURSCR,A5
        MULU    #160,D5
        ADDQ.W  #8,D5
        ADD.W   D5,A5
        SUBQ.W  #1,D7
        BGE.S   AFLIG
        RTS
AF0:    CLR.W   D0
        MOVE.W  D0,D1
        BRA.S   AF1
FAF2:   LEA.L   -160(A5),A5
        DBF     D7,AFLIG
        RTS
AF2:    MOVEQ   #19,D6
        MOVEQ   #30,D1
        BRA.S   AF3
AFLIG:  MOVE.L  A5,A1
        MOVE.W  (A0)+,D0
        BLT.S   AF0
        CMP.W   #319,D0
        BGT.S   FAF2
        MOVE.W  D0,D1
        LSR.W   #4,D0
        AND.W   #$F,D1
        ADD.W   D1,D1
AF1:    MOVE.W  0(A4,D1.W),D4
        MOVE.W  998(A0),D6
        BLT.S   FAF2
        CMP.W   #319,D6
        BGT.S   AF2
        MOVE.W  D6,D1
        LSR.W   #4,D6
        AND.W   #$F,D1
        ADD.W   D1,D1
AF3:    MOVE.W  2(A4,D1.W),D5
        SUB.W   D6,D0
        BGE.S   AF4
        MOVE.W  D5,D1
        NOT.W   D5
        LSL.W   #3,D6
        ADD.W   D6,A1
MAF1:   AND.W   D5,-(A1)
        OR.W    D1,-(A1)
        AND.W   D5,-(A1)
        OR.W    D1,-(A1)
        ADDQ.W  #1,D0
        BEQ.S   AF6
AF5:    BCLR    #0,D0
        BEQ.S   SAF5
        ADDQ.W  #2,D0
        MOVE.L  D3,-(A1)
        MOVE.L  D2,-(A1)
SAF5:   ADD.W   D0,D0
        JMP     AF6(PC,D0.W)
        MOVEM.L D2-D3/A2-A3,-(A1)
        MOVEM.L D2-D3/A2-A3,-(A1)
        MOVEM.L D2-D3/A2-A3,-(A1)
        MOVEM.L D2-D3/A2-A3,-(A1)
        MOVEM.L D2-D3/A2-A3,-(A1)
        MOVEM.L D2-D3/A2-A3,-(A1)
        MOVEM.L D2-D3/A2-A3,-(A1)
        MOVEM.L D2-D3/A2-A3,-(A1)
        MOVEM.L D2-D3/A2-A3,-(A1)
AF6:    MOVE.W  D4,D5
        MOVE.W  D4,D1
        NOT.W   D1
MAF2:   AND.W   D5,-(A1)
        OR.W    D1,-(A1)
        AND.W   D5,-(A1)
        OR.W    D1,-(A1)
FAF:    LEA.L   -160(A5),A5
        DBF     D7,AFLIG
        RTS
AF4:    NOT.W   D4
        OR.W    D4,D5    
        MOVE.W  D5,D1
        NOT.W   D5
        LSL.W   #3,D6
        ADD.W   D6,A1
MAF3:   AND.W   D5,-(A1)
        OR.W    D1,-(A1)
        AND.W   D5,-(A1)
        OR.W    D1,-(A1)
        LEA.L   -160(A5),A5
        DBF     D7,AFLIG
        RTS
IPOLY:  
;0000
        AND.W   D1,-(A1)
        AND.W   D1,-(A1)
        AND.W   D1,-(A1)
        AND.W   D1,-(A1)
;0001
        OR.W    D5,-(A1)
        AND.W   D1,-(A1)
        AND.W   D1,-(A1)
        AND.W   D1,-(A1)
;0010
        AND.W   D1,-(A1)
        OR.W    D5,-(A1)
        AND.W   D1,-(A1)
        AND.W   D1,-(A1)
;0011
        OR.W    D5,-(A1)
        OR.W    D5,-(A1)
        AND.W   D1,-(A1)
        AND.W   D1,-(A1)
;0100
        AND.W   D1,-(A1)
        AND.W   D1,-(A1)
        OR.W    D5,-(A1)
        AND.W   D1,-(A1)
;0101
        OR.W    D5,-(A1)
        AND.W   D1,-(A1)
        OR.W    D5,-(A1)
        AND.W   D1,-(A1)
;0110
        AND.W   D1,-(A1)
        OR.W    D5,-(A1)
        OR.W    D5,-(A1)
        AND.W   D1,-(A1)
;0111
        OR.W    D5,-(A1)
        OR.W    D5,-(A1)
        OR.W    D5,-(A1)
        AND.W   D1,-(A1)
;1000
        AND.W   D1,-(A1)
        AND.W   D1,-(A1)
        AND.W   D1,-(A1)
        OR.W    D5,-(A1)
;1001
        OR.W    D5,-(A1)
        AND.W   D1,-(A1)
        AND.W   D1,-(A1)
        OR.W    D5,-(A1)
;1010
        AND.W   D1,-(A1)
        OR.W    D5,-(A1)
        AND.W   D1,-(A1)
        OR.W    D5,-(A1)
;1011
        OR.W    D5,-(A1)
        OR.W    D5,-(A1)
        AND.W   D1,-(A1)
        OR.W    D5,-(A1)
;1100
        AND.W   D1,-(A1)
        AND.W   D1,-(A1)
        OR.W    D5,-(A1)
        OR.W    D5,-(A1)
;1101
        OR.W    D5,-(A1)
        AND.W   D1,-(A1)
        OR.W    D5,-(A1)
        OR.W    D5,-(A1)
;1110
        AND.W   D1,-(A1)
        OR.W    D5,-(A1)
        OR.W    D5,-(A1)
        OR.W    D5,-(A1)
;1111
        OR.W    D5,-(A1)
        OR.W    D5,-(A1)
        OR.W    D5,-(A1)
        OR.W    D5,-(A1)

;0000
        AND.W   D6,-(A1)
        AND.W   D6,-(A1)
        AND.W   D6,-(A1)
        AND.W   D6,-(A1)
;0001
        OR.W    D4,-(A1)
        AND.W   D6,-(A1)
        AND.W   D6,-(A1)
        AND.W   D6,-(A1)
;0010
        AND.W   D6,-(A1)
        OR.W    D4,-(A1)
        AND.W   D6,-(A1)
        AND.W   D6,-(A1)
;0011
        OR.W    D4,-(A1)
        OR.W    D4,-(A1)
        AND.W   D6,-(A1)
        AND.W   D6,-(A1)
;0100
        AND.W   D6,-(A1)
        AND.W   D6,-(A1)
        OR.W    D4,-(A1)
        AND.W   D6,-(A1)
;0101
        OR.W    D4,-(A1)
        AND.W   D6,-(A1)
        OR.W    D4,-(A1)
        AND.W   D6,-(A1)
;0110
        AND.W   D6,-(A1)
        OR.W    D4,-(A1)
        OR.W    D4,-(A1)
        AND.W   D6,-(A1)
;0111
        OR.W    D4,-(A1)
        OR.W    D4,-(A1)
        OR.W    D4,-(A1)
        AND.W   D6,-(A1)
;1000
        AND.W   D6,-(A1)
        AND.W   D6,-(A1)
        AND.W   D6,-(A1)
        OR.W    D4,-(A1)
;1001
        OR.W    D4,-(A1)
        AND.W   D6,-(A1)
        AND.W   D6,-(A1)
        OR.W    D4,-(A1)
;1010
        AND.W   D6,-(A1)
        OR.W    D4,-(A1)
        AND.W   D6,-(A1)
        OR.W    D4,-(A1)
;1011
        OR.W    D4,-(A1)
        OR.W    D4,-(A1)
        AND.W   D6,-(A1)
        OR.W    D4,-(A1)
;1100
        AND.W   D6,-(A1)
        AND.W   D6,-(A1)
        OR.W    D4,-(A1)
        OR.W    D4,-(A1)
;1101
        OR.W    D4,-(A1)
        AND.W   D6,-(A1)
        OR.W    D4,-(A1)
        OR.W    D4,-(A1)
;1110
        AND.W   D6,-(A1)
        OR.W    D4,-(A1)
        OR.W    D4,-(A1)
        OR.W    D4,-(A1)
;1111
        OR.W    D4,-(A1)
        OR.W    D4,-(A1)
        OR.W    D4,-(A1)
        OR.W    D4,-(A1)

MPOLY:  DC.W    $FFFF,$7FFF,$3FFF,$1FFF
        DC.W    $0FFF,$07FF,$03FF,$01FF
        DC.W    $00FF,$007F,$003F,$001F
        DC.W    $000F,$0007,$0003,$0001
        DC.W    $0000
COULEUR:
        DC.W    0,0,0,0
        DC.W    0,0,0,-1
        DC.W    0,0,-1,0
        DC.W    0,0,-1,-1
        DC.W    0,-1,0,0
        DC.W    0,-1,0,-1
        DC.W    0,-1,-1,0
        DC.W    0,-1,-1,-1
        DC.W    -1,0,0,0
        DC.W    -1,0,0,-1
        DC.W    -1,0,-1,0
        DC.W    -1,0,-1,-1
        DC.W    -1,-1,0,0
        DC.W    -1,-1,0,-1
        DC.W    -1,-1,-1,0
        DC.W    -1,-1,-1,-1
banner: equ     67
MWD2D6: EQU     $3C02
MWA1D3: EQU     $3611
SWPD7:  EQU     $4847
MLA1D3: EQU     $2611
MQ0D3:  EQU     $7600
MWA1D5: EQU     $3A11
MLA1D5: EQU     $2A11
SWMWD7: EQU     $48473E3A
MWD0D3: EQU     $3600
MWX1D6: EQU     $3C29
MLX1D6: EQU     $2C29
ORD3:   EQU     $876B
AND0:   EQU     $C16B
AND2:   EQU     $C56B
*AFFI OBJ 3D
obj3d:  cmp.b   #254,d0
        beq     SPRITE
;        cmp.w   #1,10(a3)
;        ble     SPRITE
        btst    #0,d0
        beq.s   oavant
        move.l  a5,a4
        move.w  d0,d1
        subq.w  #1,d1
bro3d:  lea.l   -8(a4),a4
        cmp.b   (a4),d1
        beq.s   oavant
        cmp.l   #-1,(a4)
        bne.s   bro3d
        lea.l   -8(a4),a4
        move.w  XB,d1
        add.w   #160,d1
        move.w  d1,6(a4)
        move.w  d1,6+8(a4)
        move.w  htprl(pc),d1
        asr.w   #1,d1
        neg.w   d1
        add.w   #199-64,d1
        cmp.w   #199,d1
        bge.s   prlac
        move.w  #199,d1
prlac:  move.w  d1,2(a4)
oavant: sub.w   #220,d0
        add.w   d0,d0
        add.w   d0,d0
        jsr     to3d(pc,d0.w)
        bra.s   SPRITE

to3d:   BRA.L   AVPONT
        BRA.L   ARPONT
        BRA.L   AVGARA
        BRA.L   ARGARA
        BRA.L   AVTRBD
        BRA.L   ARTRBD
        BRA.L   AVTRBG
        BRA.L   ARTRBG
        BRA.L   AVPNT2
        BRA.L   ARPNT2
        BRA.L   AVPLAQ
        BRA.L   ARPLAQ
        BRA.L   AVPNTR
        BRA.L   ARPNTR
*AFFIC OBJET LOGIQUE
SPRITE: lea.l   -8(a5),a5
        cmp.l   #-1,(a5)
        bne.s   srafft
        rts
srafft: lea.l   coorbas(pc),a3
        clr.b   4(a3)
        clr.w   d6
        clr.w   d2
        move.b  1(a5),d2
        addq.w  #1,d2
        move.w  d2,10(a3)
        clr.w   d0
        move.b  (a5),d0
        cmp.w   #200,d0
        bge     obj3d
        move.b  d0,nolog+1
        move.l  #LOGEQU,a0   ;adr du fichier logi
        add.w   d0,d0
        add.w   0(a0,d0.w),a0
        clr.w   d0
        move.b  6(a0),d0
        MOVE.B  5(A0),EFSP
        move.b  7(a0),(a5)
        bge.s   syaob0
        movem.l a0/a3/a5/d0,-(a7)
        bsr     vecteur
        movem.l (a7)+,d0/a0/a3/a5
        bra.s   syaob1
syaob0: movem.l a0/a3/d0,-(a7)
        bsr     afspri          ;affi obj base
        movem.l (a7)+,d0/a0/a3
syaob1: tst.b   4(a3)
        bne     SPRITE
        addq.w  #8,a0
        subq.w  #2,d0
        blt     SPRITE
        tst.b   -5(a0)
        beq     byaob1
        move.l  a0,a1
        move.l  a0,a2
        move.b  -2(a0),d0
        subq.b  #1,d0
        add.w   d0,d0
        add.w   d0,d0
        add.w   d0,a1
        move.b  1(a1),d0
        beq.s   yaob3
        subq.w  #1,d0
byaob2: move.b  3(a0),5(a3)
        move.b  1(a0),d1
        ext.w   d1
        move.w  d1,6(a3)
        move.b  2(a0),d1
        ext.w   d1
        move.w  d1,8(a3)
        moveq   #1,d6
        move.b  (a0),(a5)
        bge.s   pvect0
        movem.l a0-a3/a5/d0,-(a7)
        bsr     vecteub
        movem.l (a7)+,d0/a0-a3/a5
        bra.s   s1yaob2
pvect0: movem.l a0-a3/d0,-(a7)
        bsr     afspri  ;affi obj fixe avec anim
        movem.l (a7)+,d0/a0-a3
s1yaob2: lea.l   4(a0),a0
        dbf     d0,byaob2
yaob3:  clr.w   d0
        tst.b   3(a1)
        bne.s   seqbcl
        tst.b   5(a1)
        beq.s   pchsan
        subq.b  #1,4(a1)
        bge.s   pchsan
        move.b  (a1),4(a1)
        move.b  5(a1),d0
        addq.b  #1,d0
        move.w  d0,d1
        add.b   2(a1),d1
        cmp.b   -5(a2),d1
        blt.s   prus1
        clr.w   d0
        addq.b  #1,4(a1)
prus1:  move.b  d0,5(a1)
        bra.s   pchsan
seqbcl: subq.b  #1,4(a1)
        bge.s   pchsan
        move.b  (a1),4(a1)
        move.b  5(a1),d0
        add.b   3(a1),d0
        move.w  d0,d1
        add.b   2(a1),d1
        cmp.b   -5(a2),d1
        blt.s   pruse
        clr.w   d0
pruse:  move.b  d0,5(a1)
pchsan: move.b  2(a1),d0
        clr.w   d2
        move.b  5(a1),d2
        lea.l   6(a1),a1
        add.w   d2,a1
byaob3: clr.w   d1
        move.b  (a1)+,d1
        add.w   d1,d1
        add.w   d1,d1
        lea.l   0(a2,d1.w),a0
        move.b  3(a0),5(a3)
        move.b  1(a0),d1
        ext.w   d1
        move.w  d1,6(a3)
        move.b  2(a0),d1
        ext.w   d1
        move.w  d1,8(a3)
        moveq   #1,d6
        move.b  (a0),(a5)
        bge.s   pvect1
        movem.l a0-a3/a5/d0,-(a7)
        bsr     vecteub
        movem.l (a7)+,d0/a0-a3/a5
        bra.s   s1yaob3
pvect1: movem.l a1-a3/d0,-(a7)
        bsr     afspri    ;affi anim
        movem.l (a7)+,d0/a1-a3
s1yaob3: dbf     d0,byaob3
        bra     SPRITE
;trt normal
byaob1: move.b  3(a0),5(a3)
        move.b  1(a0),d1
        ext.w   d1
        move.w  d1,6(a3)
        move.b  2(a0),d1
        ext.w   d1
        move.w  d1,8(a3)
        moveq   #1,d6
        move.b  (a0),(a5)
        bge.s   pvect2
        movem.l a0-a3/a5/d0,-(a7)
        bsr     vecteub
        movem.l (a7)+,d0/a0-a3/a5
        bra.s   s1yaob1
pvect2: movem.l a0/a3/d0,-(a7)
        bsr     afspri  ;affi obj sans anim
        movem.l (a7)+,d0/a0/a3
s1yaob1: lea.l   4(a0),a0
        dbf     d0,byaob1
FSPRI:  bra     SPRITE

afspri: lea.l   tabobj(pc),a0
        clr.w   d0
        move.b  (a5),d0
        add.w   d0,d0
        add.w   d0,d0
        move.l  0(a0,d0.w),a0
        move.l  a0,a1
        move.l  a0,a4
        move.l  a0,a2
        clr.w   d4
        move.b  1(a5),d4
        cmp.w   2(a0),d4
        bge     paaf2
        move.b  4(a0,d4.w),d4
        bge.s   posaf
        cmp.b   #-1,d4
        beq     paaf2
posaf:  add.w   2(a0),a0
        addq.w  #4,a0
        add.w   d4,d4
        add.w   (a0)+,a2
        add.w   6(a0,d4.w),a4
        clr.w   d0
        move.b  (a4)+,d0
        lsl.w   #3,d0
        add.w   d0,a2
        add.w   (a2)+,a1
        clr.w   d0
        move.b  (a4)+,d0
        move.w  2(a5),d1
        tst.w   d6
        beq.s   ybas
        move.b  5(a3),d3
        move.w  10(a3),d7
        btst    #1,d3
        beq.s   porout
        sub.w   (a3),d1
        btst    #0,d3
        beq.s   pocom
        add.w   d0,d1
        bra.s   pocom
porout: btst    #0,d3
        beq.s   pocom
        sub.w   d7,d1
        add.w   d0,d1
pocom:  muls    8(a3),d7
        asr.w   #8,d7
        add.w   d7,d1
        bra.s   pcom1  
ybas:   move.w  d0,(a3)
pcom1:  move.w  d1,d3
        sub.w   d0,d3
        sub.w   #banner,d3
        bge.L   enthaut
        cmp.w   #banner,d1
        ble.L   paaf2
        add.w   d3,d0
        move.l  a4,a3
        move.w  6+2(a0,d4.w),d7
        sub.w   6(a0,d4.w),d7
        subq.w  #3,d7
        add.w   d7,a3
        btst    #0,d7
        beq.s   lidbl
lispl:  move.b  -(a3),d7
        add.w   d7,d3
        blt.s   lidbl
        addq.w  #1,sseq
        move.b  1(a3),-(a7)
        move.b  d7,-(a7)
        move.l  a3,-(a7)
        move.w  #1,-(a7)
        move.b  d3,(a3)+
        clr.b   (a3)
        bra.s   enthaut
lidbl:  move.b  -(a3),d7
        add.w   d7,d3
        add.w   d7,d3
        blt.s   lispl
        lsr.w   #1,d3
        bcs.s   sdbls
        addq.w  #1,sseq
        move.b  1(a3),-(a7)
        move.b  d7,-(a7)
        move.l  a3,-(a7)
        move.w  #1,-(a7)
        move.b  d3,(a3)+
        clr.b   (a3)
        bra.s   enthaut
sdbls:  addq.w  #1,sseq
        tst.b   d3
        bne.s   sdbl2
        move.b  d7,-(a7)
        move.b  -(a3),-(a7)
        move.l  a3,-(a7)
        move.w  #1,-(a7)
        addq.b  #1,(a3)+
        clr.b   (a3)
        bra.s   enthaut
sdbl2:  move.b  3(a3),-(a7)
        move.b  2(a3),-(a7)
        move.b  1(a3),-(a7)
        move.b  d7,-(a7)
        move.l  a3,-(a7)
        move.w  #3,-(a7)
        move.b  d3,(a3)+
        move.b  #1,(a3)+
        clr.b   (a3)
enthaut:
        clr.w   d3
        move.b  4(a5),d3
        sub.w   d1,d3
        bgt     entbas
        neg.w   d3
        addq.w  #1,d3
        cmp.w   d3,d0
        bgt.s   ppaaf
paaf:   tst.w   d6
        bne     rfspr
        move.b  2(a2),coorbas+3
        bra     rfspr
paaf2:  move.b  #1,4(a3)
        rts
ppaaf:  sub.w   d3,d1
        clr.w   d0
        clr.w   d7
lispl1: move.b  (a4)+,d7
        add.w   d7,d0
        sub.w   d7,d3
        bgt.s   lidbl1
        add.w   d3,d0
        addq.w  #1,sseq
        move.b  (a4),-(a7)
        move.b  -(a4),-(a7)
        move.l  a4,-(a7)
        move.w  #1,-(a7)
        neg.w   d3
        move.b  d3,(a4)
        bra.s   fli1
lidbl1: move.b  (a4)+,d7
        add.w   d7,d0
        sub.w   d7,d3
        sub.w   d7,d3
        bgt.s   lispl1
        neg.w   d3
        lsr.w   #1,d3
        bcs.s   sdbl1
        tst.w   d3
        beq.s   fli1
        sub.w   d3,d0
        addq.w  #1,sseq
        move.b  -(a4),-(a7)
        move.b  -(a4),-(a7)
        move.l  a4,-(a7)
        move.w  #1,-(a7)
        clr.b   (a4)
        move.b  d3,1(a4)
        bra.s   fli1
sdbl1:  sub.w   d3,d0
        addq.w  #1,sseq
        subq.w  #1,d0
        tst.w   d3
        bne.s   sdbl3
        tst.b   (a4)
        bne.s   sdbx
        move.b  1(a4),-(a7)
        move.b  (a4),-(a7)
        move.l  a4,-(a7)
        move.w  #1,-(a7)
        move.b  #1,(a4)
        clr.b   1(a4)
        bra.s   fli1
sdbx:   move.b  1(a4),-(a7)
        move.b  (a4),-(a7)
        move.l  a4,-(a7)
        move.w  #1,-(a7)
        addq.b  #1,(a4)
        bra.s   fli1
sdbl3:  move.b  -(a4),-(a7)
        move.b  -(a4),-(a7)
        move.l  a4,-(a7)
        move.w  #1,-(a7)
        move.b  #1,(a4)
        move.b  d3,1(a4)
fli1:   mulu    4(a2),d0
        add.w   d0,a1
entbas: move.l  CURSCR,a3
        lsl.w   #5,d1
        move.w  d1,d4
        lsl.w   #2,d4
        add.w   d4,d1
        add.w   d1,a3
        clr.w   d4
        move.b  2(a2),d4
        move.w  6(a5),d1
        tst.w   d6
        beq.s   xbas
        move.l  a0,d5
        lea.l   coorbas(pc),a0
        tst.b   5(a5)
        beq.s   scal
        sub.w   2(a0),d1
scal:   move.w  10(a0),d2
        muls    6(a0),d2
        asr.w   #8,d2
        move.b  5(a0),d3
        btst    #4,d3
        bne.s   calctr
        add.w   d2,d1
        btst    #3,d3
        bne.s   calgch
        add.w   2(a0),d1
        btst    #2,d3
        bne.s   drgc
        sub.w   d4,d1
calcom: move.l  d5,a0
        bra.s   objdrt
drgc:   addq.w  #1,d1
        move.l  d5,a0
        bra.s   objdrt
calgch: btst    #2,d3
        beq.s   calcom
        sub.w   d4,d1
        subq.w  #1,d1
        move.l  d5,a0
        bra.s   objdrt
calctr: move.w  2(a0),d3
        lsr.w   #1,d3
        add.w   d3,d2
        move.w  d4,d3
        lsr.w   #1,d3
        sub.w   d3,d2
        add.w   d2,d1
        move.l  d5,a0
        bra.s   objdrt
xbas:   move.w  d4,coorbas+2
        tst.b   5(a5)
        beq.s   objdrt
        sub.w   d4,d1
objdrt: move.w  d4,d5
        lsr.w   #4,d5
        subq.w  #1,d5
        move.w  d1,d2
        move.w  d4,d3
        add.w   d1,d3
        and.w   #$f,d2
        and.w   #$f,d3
        move.w  #$7,d6
        moveq   #16,d7
        cmp.w   d2,d3
        blt.s   trplv
        bclr    #2,d6
        subq.w  #8,d7
trplv:  tst.w   d1
        bge.s   spr1
        add.w   d1,d4
        blt     paaf
        move.w  d1,d4
        asr.w   #4,d4
        addq.w  #1,d4
        add.w   d4,d5
        asl.w   #1,d4
        sub.w   d4,a1
        bclr    #0,d6
        subq.w  #8,d7
        move.w  d2,d1
        move.w  #16,d2
        sub.w   d1,d2
        bra.s   sprc
spr1:   cmp.w   #320,d1
        bge     paaf
        add.w   d1,d4
        sub.w   #320,d4
        blt.s   spr2
        lsr.w   #4,d4
        sub.w   d4,d5
        subq.w  #8,d7
        or.w    #$ff00,d6
        bclr    #2,d6
        bne.s   spr2
        addq.w  #8,d7
        subq.w  #1,d5
spr2:   move.w  d1,d4
        lsr.w   #1,d4
        and.w   #$fff8,d4
        add.w   d4,a3
        move.w  d2,d1
        move.w  #16,d2
        sub.w   d1,d2
sprc:   btst    #1,1(a0)
        beq.s   pcarre
        move.l  a0,-(sp)
        lea.l   TBMK(pc),a0
        move.w  d1,d4
        add.w   d4,d4
        move.w  0(a0,d4.w),d4
        move.w  d4,d0
        swap    d0
        move.w  d4,d0
        tst.w   d6
        bge.s   mskex
        clr.l   -(a0)
        move.l  (sp)+,a0
        bra.s   pcarre
mskex:  add.w   d3,d3
        move.w  32(a0,d3.w),-(a0)
        move.w  34(a0,d3.w),-(a0)
        move.l  (sp)+,a0
        btst    #2,d6
        bne.s   pcarre
        tst.w   d5
        blt.s   pcarre
        addq.w  #8,d7
        subq.w  #1,d5
        bset    #3,d6
pcarre: move.w  (a2),d4
        move.w  4(a2),a2
        tst.w   d5
        blt.s   pap2
        move.w  d5,VD7
        addq.w  #1,d5
        add.w   d5,d5
        add.w   d5,a1
        add.w   d5,a2
        add.w   d5,d5
        add.w   d5,d5             
        bra.s   spap2
pap2:   bclr    #1,d6
        clr.w   d5
spap2:  add.w   d7,d5
        add.w   d5,a3
        MOVE.W  (A0)+,D7
        ADD.W   D7,D7
        MOVE.W  TRTSP-24(PC,D7.W),D7
        JSR     R1234(PC,D7.W)
rfspr:  move.w  sseq(pc),d0
        beq.s   fsprit
        clr.w   sseq
        subq.w  #1,d0
bsprc:  move.w  (a7)+,d1
        move.l  (a7)+,a3
b1spr:  move.b  (a7)+,(a3)+
        dbf     d1,b1spr
        dbf     d0,bsprc
fsprit: rts
sseq:   dc.w    0
MSKD2:  DC.L    0
TBMK:   DC.W    $0000,$8000,$C000,$E000,$F000,$F800,$FC00,$FE00
        DC.W    $FF00,$FF80,$FFC0,$FFE0,$FFF0,$FFF8,$FFFC,$FFFE
        DC.W    $7FFF,$3FFF,$1FFF,$0FFF,$07FF,$03FF,$01FF,$00FF
        DC.W    $007F,$003F,$001F,$000F,$0007,$0003,$0001,$0000
VD7:    DC.W    0

R1234:
TRTSP:  
        DC.W    RN0034-R1234
        DC.W    RM0034-R1234
        DC.W    0 ;RC0034-R1234
        DC.W    0               ;VIDE
        DC.W    0,0,0  ;UN SEUL PLAN
        DC.W    0               ;VIDE
        DC.W    0 ;RN0204-R1234
        DC.W    0 ;RM0204-R1234
        DC.W    0 ;RC0204-R1234
        DC.W    0               ;VIDE
        DC.W    0 ;RN0230-R1234
        DC.W    0 ;RM0230-R1234
        DC.W    0 ;RC0230-R1234
        DC.W    0               ;VIDE
        DC.W    0 ;RN0234-R1234
        DC.W    0 ;RM0234-R1234
        DC.W    0 ;RC0234-R1234
        DC.W    0               ;VIDE
        DC.W    RN1000-R1234   ;TRT UNIQ UN PLAN
        DC.W    0 ;RM1000-R1234
        DC.W    0 ;RC1000-R1234
        DC.W    0               ;VIDE
        DC.W    0 ;RN1004-R1234
        DC.W    RM1004-R1234
        DC.W    RC1004-R1234
        DC.W    0               ;VIDE
        DC.W    0 ;RN1030-R1234
        DC.W    0 ;RM1030-R1234
        DC.W    0 ;RC1030-R1234
        DC.W    0               ;VIDE
        DC.W    0 ;RN1034-R1234
        DC.W    RM1034-R1234
        DC.W    0 ;RC1034-R1234
        DC.W    0               ;VIDE
        DC.W    RN1200-R1234
        DC.W    0 ;RM1200-R1234
        DC.W    RC1200-R1234
        DC.W    0               ;VIDE
        DC.W    0 ;RN1204-R1234
        DC.W    RM1204-R1234
        DC.W    0 ;RC1204-R1234
        DC.W    0               ;VIDE
        DC.W    0 ;RN1230-R1234
        DC.W    0 ;RM1230-R1234
        DC.W    0 ;RC1230-R1234
        DC.W    0               ;VIDE
        DC.W    RN1234-R1234
        DC.W    0 ;RM1234-R1234
        DC.W    RC1234-R1234
**********
RN1234: 
;NBR PLAN
        MOVE.W  D4,D3
        ADD.W   D4,D3
        MOVE.W  D3,D0
        ADD.W   D4,D0
        CMP.W   D2,D1
        BLE.S   RN1234R
        MOVE.W  D2,D1
        BRA     RN1234L
RN1234R:
        LEA.L   R0C(PC),A0
        LSR.B   #1,D6
        BCS.S   R0P1
        MOVE.W  #$6000+R0F-R0A-2,R0A-R0C(A0)
        MOVE.W  #$6000+R0MF-R0MA-2,R0MA-R0C(A0)
        BRA.S   R0PP1
R0P1:   MOVE.W  #MWA1D3,R0A-R0C(A0)
        MOVE.W  D4,ER0A0-R0C+2(A0)
        MOVE.W  D3,ER0A1-R0C+2(A0)
        MOVE.W  D0,ER0A2-R0C+2(A0)
        MOVE.W  #MWA1D3,R0MA-R0C(A0)
        MOVE.W  D4,ER0MA0-R0C+2(A0)
        MOVE.W  D3,ER0MA1-R0C+2(A0)
        MOVE.W  D0,ER0MA2-R0C+2(A0)
        TST.B   D6
        BNE.S   R0PP1
        MOVE.W  #R0A-R0F-6,R0F-R0C+6(A0)
        MOVE.W  #R0MA-R0MF-10,R0MF-R0C+10(A0)
        BRA.S   R0PP3
R0PP1:  LSR.B   #1,D6
        BCS.S   R0P2
        MOVE.W  #$6000+R0A-R0B-2,R0B-R0C(A0)
        MOVE.L  #$60000000+R0MA-R0MB-2,R0MB-R0C(A0)
        BRA.S   R0PP2
R0P2:   MOVE.W  #SWPD7,R0B-R0C(A0)
        MOVE.W  D4,ER0B0-R0C+2(A0)
        MOVE.W  D3,ER0B1-R0C+2(A0)
        MOVE.W  D0,ER0B2-R0C+2(A0)
        MOVE.L  #SWMWD7,R0MB-R0C(A0)
        MOVE.W  D4,ER0MB0-R0C+2(A0)
        MOVE.W  D3,ER0MB1-R0C+2(A0)
        MOVE.W  D0,ER0MB2-R0C+2(A0)
        TST.B   D6
        BNE.S   R0PP2
        MOVE.W  #R0B-R0F-6,R0F-R0C+6(A0)
        MOVE.W  #R0MB-R0MF-10,R0MF-R0C+10(A0)
        BRA.S   R0PP3
R0PP2:  MOVE.W  D4,ER0C0-R0C+2(A0)
        MOVE.W  D3,ER0C1-R0C+2(A0)
        MOVE.W  D0,ER0C2-R0C+2(A0)
        MOVE.W  D4,ER0MC0-R0C+2(A0)
        MOVE.W  D3,ER0MC1-R0C+2(A0)
        MOVE.W  D0,ER0MC2-R0C+2(A0)
        MOVE.W  #R0C-R0F-6,R0F-R0C+6(A0)
        MOVE.W  #R0MC-R0MF-10,R0MF-R0C+10(A0)
R0PP3:
        MOVE.W  #160,A0
        SUB.W   D5,A0
        MOVE.B  (A4)+,D7
        BEQ     R0MD-6
R0D:    EXT.W   D7
        BRA.L   R0F+4

R0C:    MOVE.L  (A1),D3
        CLR.W   D3
        LSR.L   D1,D3
ER0C0:  MOVE.L  2(A1),D4
        CLR.W   D4
        LSR.L   D1,D4
ER0C1:  MOVE.L  4(A1),D5
        CLR.W   D5
        LSR.L   D1,D5
ER0C2:  MOVE.L  6(A1),D6
        CLR.W   D6
        LSR.L   D1,D6

        MOVE.W  D3,D2
        OR.W    D4,D2
        OR.W    D5,D2
        OR.W    D6,D2
        BNE.S   R0C0
        SUBQ.W  #8,A3
        BRA.S   R0B
R0C0:   NOT.W   D2
        MOVE.L  -(A3),D0
        AND.W   D2,D0
        OR.W    D0,D6
        SWAP    D0
        AND.W   D2,D0
        OR.W    D0,D5
        MOVE.L  -(A3),D0
        AND.W   D2,D0
        OR.W    D0,D4
        SWAP    D0
        AND.W   D2,D0
        OR.W    D0,D3
R0C1:   MOVEM.W D3-D6,(A3)
 
R0B:    SWAP    D7
        MOVE.W  VD7(PC),D7
R0B0:   SUBQ.W  #2,A1
        MOVE.L  (A1),D3
        LSR.L   D1,D3
ER0B0:  MOVE.L  2(A1),D4
        LSR.L   D1,D4
ER0B1:  MOVE.L  4(A1),D5
        LSR.L   D1,D5
ER0B2:  MOVE.L  6(A1),D6
        LSR.L   D1,D6

        MOVE.W  D3,D2
        OR.W    D4,D2
        OR.W    D5,D2
        OR.W    D6,D2
        BNE.S   R0B1
        SUBQ.W  #8,A3
        DBF     D7,R0B0
        BRA.S   R0BF+4
R0B1:   NOT.W   D2
        BEQ.S   R0B2
        MOVE.L  -4(A3),D0
        AND.W   D2,D0
        OR.W    D0,D6
        SWAP    D0
        AND.W   D2,D0
        OR.W    D0,D5
        MOVE.L  -8(A3),D0
        AND.W   D2,D0
        OR.W    D0,D4
        SWAP    D0
        AND.W   D2,D0
        OR.W    D0,D3
R0B2:   MOVEM.W D3-D6,-(A3)
R0BF:   DBF     D7,R0B0
        SWAP    D7

R0A:    MOVE.W  (A1),D3
        LSR.W   D1,D3
ER0A0:  MOVE.W  2(A1),D4
        LSR.W   D1,D4
ER0A1:  MOVE.W  4(A1),D5
        LSR.W   D1,D5
ER0A2:  MOVE.W  6(A1),D6
        LSR.W   D1,D6

        MOVE.W  D3,D2
        OR.W    D4,D2
        OR.W    D5,D2
        OR.W    D6,D2
        BNE.S   R0A1
        SUBQ.W  #8,A3
        BRA.S   R0F
R0A1:   NOT.W   D2
        MOVE.L  -(A3),D0
        AND.W   D2,D0
        OR.W    D0,D6
        SWAP    D0
        AND.W   D2,D0
        OR.W    D0,D5
        MOVE.L  -(A3),D0
        AND.W   D2,D0
        OR.W    D0,D4
        SWAP    D0
        AND.W   D2,D0
        OR.W    D0,D3
R0A2:   MOVEM.W D3-D6,(A3)
R0F:    ADD.W   A2,A1
        SUB.W   A0,A3
        DBF     D7,R0C

        MOVE.B  (A4)+,D7
        BNE.S   R0MD
        RTS
R0MD:   EXT.W   D7
        BRA.L   R0MF+8           

R0MC:   MOVE.L  (A1),D3
        CLR.W   D3
        LSR.L   D1,D3
ER0MC0: MOVE.L  2(A1),D4
        CLR.W   D4
        LSR.L   D1,D4
ER0MC1: MOVE.L  4(A1),D5
        CLR.W   D5
        LSR.L   D1,D5
ER0MC2: MOVE.L  6(A1),D6
        CLR.W   D6
        LSR.L   D1,D6

        MOVE.W  D3,D2
        OR.W    D4,D2
        OR.W    D5,D2
        OR.W    D6,D2
        BNE.S   R0MC0
        SUBQ.W  #8,A3
        BRA.S   R0MB
R0MC0:  NOT.W   D2
        LEA.L   -168(A3),A3
        MOVE.L  (A3),D0
        AND.W   D2,D0
        OR.W    D4,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D3,D0
        SWAP    D0
        MOVE.L  D0,(A3)+
        MOVE.L  (A3),D0
        AND.W   D2,D0
        OR.W    D6,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)+
        LEA.L   152(A3),A3
        MOVE.L  (A3)+,D0
        AND.W   D2,D0
        OR.W    D0,D4
        SWAP    D0
        AND.W   D2,D0
        OR.W    D0,D3
        MOVE.L  (A3)+,D0
        AND.W   D2,D0
        OR.W    D0,D6
        SWAP    D0
        AND.W   D2,D0
        OR.W    D0,D5
R0MC2:  MOVEM.W D3-D6,-(A3)
 
R0MB:   SWAP    D7
        MOVE.W  VD7(PC),D7
R0MB0:  SUBQ.W  #2,A1
        MOVE.L  (A1),D3
        LSR.L   D1,D3
ER0MB0: MOVE.L  2(A1),D4
        LSR.L   D1,D4
ER0MB1: MOVE.L  4(A1),D5
        LSR.L   D1,D5
ER0MB2: MOVE.L  6(A1),D6
        LSR.L   D1,D6

        MOVE.W  D3,D2
        OR.W    D4,D2
        OR.W    D5,D2
        OR.W    D6,D2
        BNE.S   R0MB1
        SUBQ.W  #8,A3
        DBF     D7,R0MB0
        BRA.S   R0MBF+4
R0MB1:  NOT.W   D2
        BEQ.S   R0MB2
        LEA.L   -168(A3),A3
        MOVE.L  (A3),D0
        AND.W   D2,D0
        OR.W    D4,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D3,D0
        SWAP    D0
        MOVE.L  D0,(A3)+
        MOVE.L  (A3),D0
        AND.W   D2,D0
        OR.W    D6,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)+
        LEA.L   152(A3),A3
        MOVE.L  (A3)+,D0
        AND.W   D2,D0
        OR.W    D0,D4
        SWAP    D0
        AND.W   D2,D0
        OR.W    D0,D3
        MOVE.L  (A3)+,D0
        AND.W   D2,D0
        OR.W    D0,D6
        SWAP    D0
        AND.W   D2,D0
        OR.W    D0,D5
        BRA.S   R0MB3
R0MB2:  MOVEM.W D3-D6,-168(A3)
R0MB3:  MOVEM.W D3-D6,-(A3)
R0MBF:  DBF     D7,R0MB0
        SWAP    D7

R0MA:   MOVE.W  (A1),D3
        LSR.W   D1,D3
ER0MA0: MOVE.W  2(A1),D4
        LSR.W   D1,D4
ER0MA1: MOVE.W  4(A1),D5
        LSR.W   D1,D5
ER0MA2: MOVE.W  6(A1),D6
        LSR.W   D1,D6

        MOVE.W  D3,D2
        OR.W    D4,D2
        OR.W    D5,D2
        OR.W    D6,D2
        BNE.S   R0MA0
        SUBQ.W  #8,A3
        BRA.S   R0MF
R0MA0:  NOT.W   D2
        LEA.L   -168(A3),A3
        MOVE.L  (A3),D0
        AND.W   D2,D0
        OR.W    D4,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D3,D0
        SWAP    D0
        MOVE.L  D0,(A3)+
        MOVE.L  (A3),D0
        AND.W   D2,D0
        OR.W    D6,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)+
        LEA.L   152(A3),A3
        MOVE.L  (A3)+,D0
        AND.W   D2,D0
        OR.W    D0,D4
        SWAP    D0
        AND.W   D2,D0
        OR.W    D0,D3
        MOVE.L  (A3)+,D0
        AND.W   D2,D0
        OR.W    D0,D6
        SWAP    D0
        AND.W   D2,D0
        OR.W    D0,D5
R0MA2:  MOVEM.W D3-D6,-(A3)

R0MF:   ADD.W   A2,A1
        LEA.L   -160(A3),A3
        SUB.W   A0,A3
        DBF     D7,R0MC
        MOVE.B  (A4)+,D7
        BNE     R0D
        RTS
*********
RN1234L:
        LEA.L   L0C(PC),A0
        LSR.B   #1,D6
        BCS.S   L0P1
        MOVE.W  #$6000+L0F-L0A-2,L0A-L0C(A0)
        MOVE.W  #$6000+L0MF-L0MA-2,L0MA-L0C(A0)
        BRA.S   L0PP1
L0P1:   MOVE.W  #MLA1D3,L0A-L0C(A0)
        MOVE.W  D4,EL0A0-L0C+2(A0)
        MOVE.W  D3,EL0A1-L0C+2(A0)
        MOVE.W  D0,EL0A2-L0C+2(A0)
        MOVE.W  #MLA1D3,L0MA-L0C(A0)
        MOVE.W  D4,EL0MA0-L0C+2(A0)
        MOVE.W  D3,EL0MA1-L0C+2(A0)
        MOVE.W  D0,EL0MA2-L0C+2(A0)
        TST.B   D6
        BNE.S   L0PP1
        MOVE.W  #L0A-L0F-6,L0F-L0C+6(A0)
        MOVE.W  #L0MA-L0MF-10,L0MF-L0C+10(A0)
        BRA.S   L0PP3
L0PP1:  LSR.B   #1,D6
        BCS.S   L0P2
        MOVE.W  #$6000+L0A-L0B-2,L0B-L0C(A0)
        MOVE.L  #$60000000+L0MA-L0MB-2,L0MB-L0C(A0)
        BRA.S   L0PP2
L0P2:   MOVE.W  #SWPD7,L0B-L0C(A0)
        MOVE.W  D4,EL0B0-L0C+2(A0)
        MOVE.W  D3,EL0B1-L0C+2(A0)
        MOVE.W  D0,EL0B2-L0C+2(A0)
        MOVE.L  #SWMWD7,L0MB-L0C(A0)
        MOVE.W  D4,EL0MB0-L0C+2(A0)
        MOVE.W  D3,EL0MB1-L0C+2(A0)
        MOVE.W  D0,EL0MB2-L0C+2(A0)
        TST.B   D6
        BNE.S   L0PP2
        MOVE.W  #L0B-L0F-6,L0F-L0C+6(A0)
        MOVE.W  #L0MB-L0MF-10,L0MF-L0C+10(A0)
        BRA.S   L0PP3
L0PP2:  MOVE.W  D4,EL0C0-L0C+2(A0)
        MOVE.W  D3,EL0C1-L0C+2(A0)
        MOVE.W  D0,EL0C2-L0C+2(A0)
        MOVE.W  D4,EL0MC0-L0C+2(A0)
        MOVE.W  D3,EL0MC1-L0C+2(A0)
        MOVE.W  D0,EL0MC2-L0C+2(A0)
        MOVE.W  #L0C-L0F-6,L0F-L0C+6(A0)
        MOVE.W  #L0MC-L0MF-10,L0MF-L0C+10(A0)
L0PP3:
        MOVE.W  #160,A0
        SUB.W   D5,A0
        MOVE.B  (A4)+,D7
        BEQ     L0MD-6
L0D:    EXT.W   D7
        BRA.L   L0F+4

L0C:    MOVE.W  (A1),D3
        LSL.W   D1,D3
EL0C0:  MOVE.W  2(A1),D4
        LSL.W   D1,D4
EL0C1:  MOVE.W  4(A1),D5
        LSL.W   D1,D5
EL0C2:  MOVE.W  6(A1),D6
        LSL.W   D1,D6

        MOVE.W  D3,D2
        OR.W    D4,D2
        OR.W    D5,D2
        OR.W    D6,D2
        BNE.S   L0C0
        SUBQ.W  #8,A3
        BRA.S   L0B
L0C0:   NOT.W   D2
        MOVE.L  -(A3),D0
        AND.W   D2,D0
        OR.W    D0,D6
        SWAP    D0
        AND.W   D2,D0
        OR.W    D0,D5
        MOVE.L  -(A3),D0
        AND.W   D2,D0
        OR.W    D0,D4
        SWAP    D0
        AND.W   D2,D0
        OR.W    D0,D3
L0C1:   MOVEM.W D3-D6,(A3)
 
L0B:    SWAP    D7
        MOVE.W  VD7(PC),D7
L0B0:   SUBQ.W  #2,A1
        MOVE.L  (A1),D3
        LSL.L   D1,D3
        SWAP    D3
EL0B0:  MOVE.L  2(A1),D4
        LSL.L   D1,D4
        SWAP    D4
EL0B1:  MOVE.L  4(A1),D5
        LSL.L   D1,D5
        SWAP    D5
EL0B2:  MOVE.L  6(A1),D6
        LSL.L   D1,D6
        SWAP    D6

        MOVE.W  D3,D2
        OR.W    D4,D2
        OR.W    D5,D2
        OR.W    D6,D2
        BNE.S   L0B1
        SUBQ.W  #8,A3
        DBF     D7,L0B0
        BRA.S   L0BF+4
L0B1:   NOT.W   D2
        BEQ.S   L0B2
        MOVE.L  -4(A3),D0
        AND.W   D2,D0
        OR.W    D0,D6
        SWAP    D0
        AND.W   D2,D0
        OR.W    D0,D5
        MOVE.L  -8(A3),D0
        AND.W   D2,D0
        OR.W    D0,D4
        SWAP    D0
        AND.W   D2,D0
        OR.W    D0,D3
L0B2:   MOVEM.W D3-D6,-(A3)
L0BF:   DBF     D7,L0B0
        SWAP    D7

L0A:    MOVE.L  (A1),D3
        CLR.W   D3
        ROL.L   D1,D3
EL0A0:  MOVE.L  2(A1),D4
        CLR.W   D4
        ROL.L   D1,D4
EL0A1:  MOVE.L  4(A1),D5
        CLR.W   D5
        ROL.L   D1,D5
EL0A2:  MOVE.L  6(A1),D6
        CLR.W   D6
        ROL.L   D1,D6

        MOVE.W  D3,D2
        OR.W    D4,D2
        OR.W    D5,D2
        OR.W    D6,D2
        BNE.S   L0A1
        SUBQ.W  #8,A3
        BRA.S   L0F
L0A1:   NOT.W   D2
        MOVE.L  -(A3),D0
        AND.W   D2,D0
        OR.W    D0,D6
        SWAP    D0
        AND.W   D2,D0
        OR.W    D0,D5
        MOVE.L  -(A3),D0
        AND.W   D2,D0
        OR.W    D0,D4
        SWAP    D0
        AND.W   D2,D0
        OR.W    D0,D3
L0A2:   MOVEM.W D3-D6,(A3)
L0F:    ADD.W   A2,A1
        SUB.W   A0,A3
        DBF     D7,L0C

        MOVE.B  (A4)+,D7
        BNE.S   L0MD
        RTS
L0MD:   EXT.W   D7
        BRA.L   L0MF+8           

L0MC:   MOVE.W  (A1),D3
        LSL.W   D1,D3
EL0MC0: MOVE.W  2(A1),D4
        LSL.W   D1,D4
EL0MC1: MOVE.W  4(A1),D5
        LSL.W   D1,D5
EL0MC2: MOVE.W  6(A1),D6
        LSL.W   D1,D6

        MOVE.W  D3,D2
        OR.W    D4,D2
        OR.W    D5,D2
        OR.W    D6,D2
        BNE.S   L0MC0
        SUBQ.W  #8,A3
        BRA.S   L0MB
L0MC0:  NOT.W   D2
        LEA.L   -168(A3),A3
        MOVE.L  (A3),D0
        AND.W   D2,D0
        OR.W    D4,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D3,D0
        SWAP    D0
        MOVE.L  D0,(A3)+
        MOVE.L  (A3),D0
        AND.W   D2,D0
        OR.W    D6,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)+
        LEA.L   152(A3),A3
        MOVE.L  (A3)+,D0
        AND.W   D2,D0
        OR.W    D0,D4
        SWAP    D0
        AND.W   D2,D0
        OR.W    D0,D3
        MOVE.L  (A3)+,D0
        AND.W   D2,D0
        OR.W    D0,D6
        SWAP    D0
        AND.W   D2,D0
        OR.W    D0,D5
L0MC2:  MOVEM.W D3-D6,-(A3)
 
L0MB:   SWAP    D7
        MOVE.W  VD7(PC),D7
L0MB0:  SUBQ.W  #2,A1
        MOVE.L  (A1),D3
        LSL.L   D1,D3
        SWAP    D3
EL0MB0: MOVE.L  2(A1),D4
        LSL.L   D1,D4
        SWAP    D4
EL0MB1: MOVE.L  4(A1),D5
        LSL.L   D1,D5
        SWAP    D5
EL0MB2: MOVE.L  6(A1),D6
        LSL.L   D1,D6
        SWAP    D6

        MOVE.W  D3,D2
        OR.W    D4,D2
        OR.W    D5,D2
        OR.W    D6,D2
        BNE.S   L0MB1
        SUBQ.W  #8,A3
        DBF     D7,L0MB0
        BRA.S   L0MBF+4
L0MB1:  NOT.W   D2
        BEQ.S   L0MB2
        LEA.L   -168(A3),A3
        MOVE.L  (A3),D0
        AND.W   D2,D0
        OR.W    D4,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D3,D0
        SWAP    D0
        MOVE.L  D0,(A3)+
        MOVE.L  (A3),D0
        AND.W   D2,D0
        OR.W    D6,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)+
        LEA.L   152(A3),A3
        MOVE.L  (A3)+,D0
        AND.W   D2,D0
        OR.W    D0,D4
        SWAP    D0
        AND.W   D2,D0
        OR.W    D0,D3
        MOVE.L  (A3)+,D0
        AND.W   D2,D0
        OR.W    D0,D6
        SWAP    D0
        AND.W   D2,D0
        OR.W    D0,D5
        BRA.S   L0MB3
L0MB2:  MOVEM.W D3-D6,-168(A3)
L0MB3:  MOVEM.W D3-D6,-(A3)
L0MBF:  DBF     D7,L0MB0
        SWAP    D7

L0MA:   MOVE.L  (A1),D3
        CLR.W   D3
        ROL.L   D1,D3
EL0MA0: MOVE.L  2(A1),D4
        CLR.W   D4
        ROL.L   D1,D4
EL0MA1: MOVE.L  4(A1),D5
        CLR.W   D5
        ROL.L   D1,D5
EL0MA2: MOVE.L  6(A1),D6
        CLR.W   D6
        ROL.L   D1,D6

        MOVE.W  D3,D2
        OR.W    D4,D2
        OR.W    D5,D2
        OR.W    D6,D2
        BNE.S   L0MA0
        SUBQ.W  #8,A3
        BRA.S   L0MF
L0MA0:  NOT.W   D2
        LEA.L   -168(A3),A3
        MOVE.L  (A3),D0
        AND.W   D2,D0
        OR.W    D4,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D3,D0
        SWAP    D0
        MOVE.L  D0,(A3)+
        MOVE.L  (A3),D0
        AND.W   D2,D0
        OR.W    D6,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)+
        LEA.L   152(A3),A3
        MOVE.L  (A3)+,D0
        AND.W   D2,D0
        OR.W    D0,D4
        SWAP    D0
        AND.W   D2,D0
        OR.W    D0,D3
        MOVE.L  (A3)+,D0
        AND.W   D2,D0
        OR.W    D0,D6
        SWAP    D0
        AND.W   D2,D0
        OR.W    D0,D5
L0MA2:  MOVEM.W D3-D6,-(A3)

L0MF:   ADD.W   A2,A1
        LEA.L   -160(A3),A3
        SUB.W   A0,A3
        DBF     D7,L0MC
        MOVE.B  (A4)+,D7
        BNE     L0D
        RTS
**********
RC1234: 
;NBR PLAN
        MOVE.W  D4,D3
        ADD.W   D4,D3
        MOVE.W  D3,D7
        ADD.W   D4,D7
        CMP.W   D2,D1
        BLE.S   RC1234R
        MOVE.W  D2,D1
        BRA     RC1234L
RC1234R:
        MOVE.L  MSKD2(PC),D2
        LEA.L   CR0C(PC),A0
        LSR.B   #1,D6
        BCS.S   CR0P1
        MOVE.W  #$6000+CR0F-CR0A-2,CR0A-CR0C(A0)
        MOVE.W  #$6000+CR0MF-CR0MA-2,CR0MA-CR0C(A0)
        BRA.S   CR0PP1
CR0P1:  MOVE.W  #MWA1D3,CR0A-CR0C(A0)
        MOVE.W  D4,ECR0A0-CR0C+2(A0)
        MOVE.W  D3,ECR0A1-CR0C+2(A0)
        MOVE.W  D7,ECR0A2-CR0C+2(A0)
        MOVE.W  #MWA1D3,CR0MA-CR0C(A0)
        MOVE.W  D4,ECR0MA0-CR0C+2(A0)
        MOVE.W  D3,ECR0MA1-CR0C+2(A0)
        MOVE.W  D7,ECR0MA2-CR0C+2(A0)
        TST.B   D6
        BNE.S   CR0PP1
        OR.L    D2,D0
        MOVE.W  #CR0A-CR0F-6,CR0F-CR0C+6(A0)
        MOVE.W  #CR0MA-CR0MF-10,CR0MF-CR0C+10(A0)
        BRA     CR0PP3
CR0PP1: LSR.B   #1,D6
        BCS.S   CR0P2
        MOVE.W  #$6000+CR0A-CR0B-2,CR0B-CR0C(A0)
        MOVE.W  #$6000+CR0MA-CR0MB-2,CR0MB-CR0C(A0)
        BRA.S   CR0PP2
CR0P2:  MOVE.W  #SWPD7,CR0B-CR0C(A0)
        MOVE.W  D4,ECR0B0-CR0C+2(A0)
        MOVE.W  D3,ECR0B1-CR0C+2(A0)
        MOVE.W  D7,ECR0B2-CR0C+2(A0)
        MOVE.W  #SWPD7,CR0MB-CR0C(A0)
        MOVE.W  D4,ECR0MB0-CR0C+2(A0)
        MOVE.W  D3,ECR0MB1-CR0C+2(A0)
        MOVE.W  D7,ECR0MB2-CR0C+2(A0)
        TST.B   D6
        BNE.S   CR0PP2
        MOVE.W  #CR0B-CR0F-6,CR0F-CR0C+6(A0)
        MOVE.W  #CR0MB-CR0MF-10,CR0MF-CR0C+10(A0)
        BRA.S   CR0PP3
CR0PP2: LSR.B   #1,D6
        BCC.S   CR0PPX
        MOVE.W  D4,ECR0C0-CR0C+2(A0)
        MOVE.W  D3,ECR0C1-CR0C+2(A0)
        MOVE.W  D7,ECR0C2-CR0C+2(A0)
        MOVE.W  D4,ECR0MC0-CR0C+2(A0)
        MOVE.W  D3,ECR0MC1-CR0C+2(A0)
        MOVE.W  D7,ECR0MC2-CR0C+2(A0)
        MOVE.W  #CR0C-CR0F-6,CR0F-CR0C+6(A0)
        MOVE.W  #CR0MC-CR0MF-10,CR0MF-CR0C+10(A0)
        BRA.S   CR0PP3
CR0PPX: MOVE.W  D4,ECR0X0-CR0C+2(A0)
        MOVE.W  D3,ECR0X1-CR0C+2(A0)
        MOVE.W  D7,ECR0X2-CR0C+2(A0)
        MOVE.W  D4,ECR0MX0-CR0C+2(A0)
        MOVE.W  D3,ECR0MX1-CR0C+2(A0)
        MOVE.W  D7,ECR0MX2-CR0C+2(A0)
        MOVE.W  #CR0X-CR0F-6,CR0F-CR0C+6(A0)
        MOVE.W  #CR0MX-CR0MF-10,CR0MF-CR0C+10(A0)
CR0PP3:
        MOVE.W  #160,A0
        SUB.W   D5,A0

        MOVE.B  (A4)+,D7
        BEQ     CR0MD-6
CR0D:   EXT.W   D7
        BRA     CR0F+4

CR0C:   MOVEQ   #0,D3
ECR0C1: MOVE.W  4(A1),D3
        ROR.L   D1,D3
ECR0C2: MOVE.L  6(A1),D6
        CLR.W   D6
        LSR.L   D1,D6
        MOVE.W  D6,D3
        AND.L   D2,-(A3)
        OR.L    D3,(A3)
        MOVEQ   #0,D3
        MOVE.W  (A1),D3
        ROR.L   D1,D3
ECR0C0: MOVE.L  2(A1),D6
        CLR.W   D6
        LSR.L   D1,D6
        MOVE.W  D6,D3
        AND.L   D2,-(A3)
        OR.L    D3,(A3)
        BRA.S   CR0B

CR0X:  
ECR0X1: MOVE.L  4(A1),D3
        LSR.L   D1,D3
        SWAP    D3
ECR0X2: MOVE.L  6(A1),D6
        LSR.L   D1,D6
        MOVE.W  D6,D3
        AND.L   D2,-(A3)
        OR.L    D3,(A3)
        MOVE.L  (A1),D3
        LSR.L   D1,D3
        SWAP    D3
ECR0X0: MOVE.L  2(A1),D6
        LSR.L   D1,D6
        MOVE.W  D6,D3
        AND.L   D2,-(A3)
        OR.L    D3,(A3)

CR0B:   SWAP    D7
        MOVE.W  VD7(PC),D7
CR0B0:  SUBQ.W  #2,A1
        MOVE.L  (A1),D3
        LSR.L   D1,D3
ECR0B0: MOVE.L  2(A1),D4
        LSR.L   D1,D4
ECR0B1: MOVE.L  4(A1),D5
        LSR.L   D1,D5
ECR0B2: MOVE.L  6(A1),D6
        LSR.L   D1,D6
        MOVEM.W D3-D6,-(A3)
        DBF     D7,CR0B0
        SWAP    D7

CR0A:   MOVE.W  (A1),D3
        LSR.W   D1,D3
        SWAP    D3
ECR0A0: MOVE.W  2(A1),D3
        LSR.W   D1,D3
ECR0A1: MOVE.W  4(A1),D5
        LSR.W   D1,D5
        SWAP    D5
ECR0A2: MOVE.W  6(A1),D5
        LSR.W   D1,D5
        AND.L   D0,-(A3)
        OR.L    D5,(A3)
        AND.L   D0,-(A3)
        OR.L    D3,(A3)

CR0F:   ADD.W   A2,A1
        SUB.W   A0,A3
        DBF     D7,CR0C

        MOVE.B  (A4)+,D7
        BNE.S   CR0MD
        RTS
CR0MD:  EXT.W   D7
        BRA     CR0MF+8  

CR0MC:  MOVEQ   #0,D3
ECR0MC1: MOVE.W  4(A1),D3
        ROR.L   D1,D3
ECR0MC2: MOVE.L  6(A1),D6
        CLR.W   D6
        LSR.L   D1,D6
        MOVE.W  D6,D3
        AND.L   D2,-164(A3)
        OR.L    D3,-164(A3)
        AND.L   D2,-(A3)
        OR.L    D3,(A3)
        MOVEQ   #0,D3
        MOVE.W  (A1),D3
        ROR.L   D1,D3
ECR0MC0: MOVE.L  2(A1),D6
        CLR.W   D6
        LSR.L   D1,D6
        MOVE.W  D6,D3
        AND.L   D2,-164(A3)
        OR.L    D3,-164(A3)
        AND.L   D2,-(A3)
        OR.L    D3,(A3)
        BRA.S   CR0MB

CR0MX:   
ECR0MX1: MOVE.L  4(A1),D3
        LSR.L   D1,D3
        SWAP    D3
ECR0MX2: MOVE.L  6(A1),D6
        LSR.L   D1,D6
        MOVE.W  D6,D3
        AND.L   D2,-164(A3)
        OR.L    D3,-164(A3)
        AND.L   D2,-(A3)
        OR.L    D3,(A3)
        MOVE.L  (A1),D3
        LSR.L   D1,D3
        SWAP    D3
ECR0MX0: MOVE.L  2(A1),D6
        LSR.L   D1,D6
        MOVE.W  D6,D3
        AND.L   D2,-164(A3)
        OR.L    D3,-164(A3)
        AND.L   D2,-(A3)
        OR.L    D3,(A3)

CR0MB:  SWAP    D7
        MOVE.W  VD7(PC),D7
CR0MB0: SUBQ.W  #2,A1
        MOVE.L  (A1),D3
        LSR.L   D1,D3
ECR0MB0: MOVE.L  2(A1),D4
        LSR.L   D1,D4
ECR0MB1: MOVE.L  4(A1),D5
        LSR.L   D1,D5
ECR0MB2: MOVE.L  6(A1),D6
        LSR.L   D1,D6
        MOVEM.W D3-D6,-(A3)
        MOVEM.W D3-D6,-160(A3)
        DBF     D7,CR0MB0
        SWAP    D7

CR0MA:  MOVE.W  (A1),D3
        LSR.W   D1,D3
        SWAP    D3
ECR0MA0: MOVE.W  2(A1),D3
        LSR.W   D1,D3
ECR0MA1: MOVE.W  4(A1),D5
        LSR.W   D1,D5
        SWAP    D5
ECR0MA2: MOVE.W  6(A1),D5
        LSR.W   D1,D5
        AND.L   D0,-(A3)
        OR.L    D5,(A3)
        AND.L   D0,-160(A3)
        OR.L    D5,-160(A3)
        AND.L   D0,-(A3)
        OR.L    D3,(A3)
        AND.L   D0,-160(A3)
        OR.L    D3,-160(A3)

CR0MF:  ADD.W   A2,A1
        LEA.L   -160(A3),A3
        SUB.W   A0,A3
        DBF     D7,CR0MC
        MOVE.B  (A4)+,D7
        BNE     CR0D
        RTS
**********
RC1234L:
        MOVE.L  MSKD2(PC),D2
        LEA.L   CL0C(PC),A0
        LSR.B   #1,D6
        BCS.S   CL0P1
        MOVE.W  #$6000+CL0F-CL0A-2,CL0A-CL0C(A0)
        MOVE.W  #$6000+CL0MF-CL0MA-2,CL0MA-CL0C(A0)
        BRA.S   CL0PP1
CL0P1:  MOVE.W  #MQ0D3,CL0A-CL0C(A0)
        MOVE.W  D4,ECL0A0-CL0C+2(A0)
        MOVE.W  D3,ECL0A1-CL0C+2(A0)
        MOVE.W  D7,ECL0A2-CL0C+2(A0)
        MOVE.W  #MQ0D3,CL0MA-CL0C(A0)
        MOVE.W  D4,ECL0MA0-CL0C+2(A0)
        MOVE.W  D3,ECL0MA1-CL0C+2(A0)
        MOVE.W  D7,ECL0MA2-CL0C+2(A0)
        TST.B   D6
        BNE.S   CL0PP1
        OR.L    D2,D0
        MOVE.W  #CL0A-CL0F-6,CL0F-CL0C+6(A0)
        MOVE.W  #CL0MA-CL0MF-10,CL0MF-CL0C+10(A0)
        BRA     CL0PP3
CL0PP1: LSR.B   #1,D6
        BCS.S   CL0P2
        MOVE.W  #$6000+CL0A-CL0B-2,CL0B-CL0C(A0)
        MOVE.W  #$6000+CL0MA-CL0MB-2,CL0MB-CL0C(A0)
        BRA.S   CL0PP2
CL0P2:  MOVE.W  #SWPD7,CL0B-CL0C(A0)
        MOVE.W  D4,ECL0B0-CL0C+2(A0)
        MOVE.W  D3,ECL0B1-CL0C+2(A0)
        MOVE.W  D7,ECL0B2-CL0C+2(A0)
        MOVE.W  #SWPD7,CL0MB-CL0C(A0)
        MOVE.W  D4,ECL0MB0-CL0C+2(A0)
        MOVE.W  D3,ECL0MB1-CL0C+2(A0)
        MOVE.W  D7,ECL0MB2-CL0C+2(A0)
        TST.B   D6
        BNE.S   CL0PP2
        MOVE.W  #CL0B-CL0F-6,CL0F-CL0C+6(A0)
        MOVE.W  #CL0MB-CL0MF-10,CL0MF-CL0C+10(A0)
        BRA.S   CL0PP3
CL0PP2: LSR.B   #1,D6
        BCC.S   CL0PPX
        MOVE.W  D4,ECL0C0-CL0C+2(A0)
        MOVE.W  D3,ECL0C1-CL0C+2(A0)
        MOVE.W  D7,ECL0C2-CL0C+2(A0)
        MOVE.W  D4,ECL0MC0-CL0C+2(A0)
        MOVE.W  D3,ECL0MC1-CL0C+2(A0)
        MOVE.W  D7,ECL0MC2-CL0C+2(A0)
        MOVE.W  #CL0C-CL0F-6,CL0F-CL0C+6(A0)
        MOVE.W  #CL0MC-CL0MF-10,CL0MF-CL0C+10(A0)
        BRA.S   CL0PP3
CL0PPX: MOVE.W  D4,ECL0X0-CL0C+2(A0)
        MOVE.W  D3,ECL0X1-CL0C+2(A0)
        MOVE.W  D7,ECL0X2-CL0C+2(A0)
        MOVE.W  D4,ECL0MX0-CL0C+2(A0)
        MOVE.W  D3,ECL0MX1-CL0C+2(A0)
        MOVE.W  D7,ECL0MX2-CL0C+2(A0)
        MOVE.W  #CL0X-CL0F-6,CL0F-CL0C+6(A0)
        MOVE.W  #CL0MX-CL0MF-10,CL0MF-CL0C+10(A0)
CL0PP3:
        MOVE.W  #160,A0
        SUB.W   D5,A0

        MOVE.B  (A4)+,D7
        BEQ     CL0MD-6
CL0D:   EXT.W   D7
        BRA     CL0F+4

CL0C:   
ECL0C1: MOVE.W  4(A1),D3
        LSL.W   D1,D3
        SWAP    D3
ECL0C2: MOVE.W  6(A1),D3
        LSL.W   D1,D3
        AND.L   D2,-(A3)
        OR.L    D3,(A3)
        MOVE.W  (A1),D3
        LSL.W   D1,D3
        SWAP    D3
ECL0C0: MOVE.W  2(A1),D3
        LSL.W   D1,D3
        AND.L   D2,-(A3)
        OR.L    D3,(A3)
        BRA.S   CL0B

CL0X:   
ECL0X1: MOVE.L  4(A1),D3
        LSL.L   D1,D3
ECL0X2: MOVE.L  6(A1),D6
        LSL.L   D1,D6
        SWAP    D6
        MOVE.W  D6,D3
        AND.L   D2,-(A3)
        OR.L    D3,(A3)
        MOVE.L  (A1),D3
        LSL.L   D1,D3
ECL0X0: MOVE.L  2(A1),D6
        LSL.L   D1,D6
        SWAP    D6
        MOVE.W  D6,D3
        AND.L   D2,-(A3)
        OR.L    D3,(A3)

CL0B:   SWAP    D7
        MOVE.W  VD7(PC),D7
CL0B0:  SUBQ.W  #2,A1
        MOVE.L  (A1),D3
        LSL.L   D1,D3
        SWAP    D3
ECL0B0: MOVE.L  2(A1),D4
        LSL.L   D1,D4
        SWAP    D4
ECL0B1: MOVE.L  4(A1),D5
        LSL.L   D1,D5
        SWAP    D5
ECL0B2: MOVE.L  6(A1),D6
        LSL.L   D1,D6
        SWAP    D6
        MOVEM.W D3-D6,-(A3)
        DBF     D7,CL0B0
        SWAP    D7

CL0A:   MOVEQ   #0,D3
ECL0A1: MOVE.W  4(A1),D3
        LSL.L   D1,D3
ECL0A2: MOVE.L  6(A1),D6
        CLR.W   D6
        ROL.L   D1,D6
        MOVE.W  D6,D3
        AND.L   D0,-(A3)
        OR.L    D3,(A3)
        MOVEQ   #0,D3
        MOVE.W  (A1),D3
        LSL.L   D1,D3
ECL0A0: MOVE.L  6(A1),D6
        CLR.W   D6
        ROL.L   D1,D6
        MOVE.W  D6,D3
        AND.L   D0,-(A3)
        OR.L    D3,(A3)

CL0F:   ADD.W   A2,A1
        SUB.W   A0,A3
        DBF     D7,CL0C

        MOVE.B  (A4)+,D7
        BNE.S   CL0MD
        RTS
CL0MD:  EXT.W   D7
        BRA     CL0MF+8

CL0MC:   
ECL0MC1: MOVE.W  4(A1),D3
        LSL.W   D1,D3
        SWAP    D3
ECL0MC2: MOVE.W  6(A1),D3
        LSL.W   D1,D3
        AND.L   D2,-(A3)
        OR.L    D3,(A3)
        AND.L   D2,-160(A3)
        OR.L    D3,-160(A3)
        MOVE.W  (A1),D3
        LSL.W   D1,D3
        SWAP    D3
ECL0MC0: MOVE.W  2(A1),D3
        LSL.W   D1,D3
        AND.L   D2,-(A3)
        OR.L    D3,(A3)
        AND.L   D2,-160(A3)
        OR.L    D3,-160(A3)
        BRA.S   CL0MB

CL0MX:   
ECL0MX1: MOVE.L  4(A1),D3
        LSL.L   D1,D3
ECL0MX2: MOVE.L  6(A1),D6
        LSL.L   D1,D6
        SWAP    D6
        MOVE.W  D6,D3
        AND.L   D2,-(A3)
        OR.L    D3,(A3)
        AND.L   D2,-160(A3)
        OR.L    D3,-160(A3)
        MOVE.L  (A1),D3
        LSL.L   D1,D3
ECL0MX0: MOVE.L  2(A1),D6
        LSL.L   D1,D6
        SWAP    D6
        MOVE.W  D6,D3
        AND.L   D2,-(A3)
        OR.L    D3,(A3)
        AND.L   D2,-160(A3)
        OR.L    D3,-160(A3)

CL0MB:  SWAP    D7
        MOVE.W  VD7(PC),D7
CL0MB0: SUBQ.W  #2,A1
        MOVE.L  (A1),D3
        LSL.L   D1,D3
        SWAP    D3
ECL0MB0: MOVE.L  2(A1),D4
        LSL.L   D1,D4
        SWAP    D4
ECL0MB1: MOVE.L  4(A1),D5
        LSL.L   D1,D5
        SWAP    D5
ECL0MB2: MOVE.L  6(A1),D6
        LSL.L   D1,D6
        SWAP    D6
        MOVEM.W D3-D6,-(A3)
        MOVEM.W D3-D6,-160(A3)
        DBF     D7,CL0MB0
        SWAP    D7

CL0MA:  MOVEQ   #0,D3
ECL0MA1: MOVE.W  4(A1),D3
        LSL.L   D1,D3
ECL0MA2: MOVE.L  6(A1),D6
        CLR.W   D6
        ROL.L   D1,D6
        MOVE.W  D6,D3
        AND.L   D0,-(A3)
        OR.L    D3,(A3)
        AND.L   D0,-160(A3)
        OR.L    D3,-160(A3)
        MOVEQ   #0,D3
        MOVE.W  (A1),D3
        LSL.L   D1,D3
ECL0MA0: MOVE.L  6(A1),D6
        CLR.W   D6
        ROL.L   D1,D6
        MOVE.W  D6,D3
        AND.L   D0,-(A3)
        OR.L    D3,(A3)
        AND.L   D0,-160(A3)
        OR.L    D3,-160(A3)

CL0MF:  ADD.W   A2,A1
        LEA.L   -160(A3),A3
        SUB.W   A0,A3
        DBF     D7,CL0MC
        MOVE.B  (A4)+,D7
        BNE     CL0D
        RTS
**********
RN0034: MOVE.L  A5,-(SP)
        MOVE.W  D4,D0
        CLR.W   D7
        MOVE.W  (A0)+,D4
        BEQ.S   S1RN34
        MOVEQ   #4,D7
S1RN34: MOVE.W  D4,A5
        MOVE.W  (A0),D4
        BEQ.S   S2RN34
        BSET    #3,D7
S2RN34: MOVE.L  VRN34(PC,D7.W),D3
        MOVE.L  VRN34+16(PC,D7.W),D7
        CMP.W   D2,D1
        BLE.S   RN0034R
        MOVE.W  D2,D1
        BRA     RN0034L
VRN34:  AND.W   D2,-(A3)
        AND.W   D2,-(A3)
        AND.W   D2,-(A3)
        OR.W    D3,-(A3)
        OR.W    D3,-(A3)
        AND.W   D2,-(A3)
        OR.W    D3,-(A3)
        OR.W    D3,-(A3)
        AND.W   D2,(A3)+
        AND.W   D2,(A3)+
        OR.W    D3,(A3)+
        AND.W   D2,(A3)+
        AND.W   D2,(A3)+
        OR.W    D3,(A3)+
        OR.W    D3,(A3)+
        OR.W    D3,(A3)+
RN0034R:
        LEA.L   R1C(PC),A0
        LSR.B   #1,D6
        BCS.S   R1P1
        MOVE.W  #$6000+R1F-R1A-2,R1A-R1C(A0)
        MOVE.W  #$6000+R1MF-R1MA-2,R1MA-R1C(A0)
        BRA.S   R1PP1
R1P1:   MOVE.W  #MWA1D5,R1A-R1C(A0)
        MOVE.W  D0,ER1A0-R1C+2(A0)
        MOVE.W  #MWA1D5,R1MA-R1C(A0)
        MOVE.W  D0,ER1MA0-R1C+2(A0)
        MOVE.L  D3,CR1A0-R1C(A0)
        MOVE.L  D3,CR1MA0-R1C(A0)
        MOVE.L  D7,CR1MA1-R1C(A0)
        TST.B   D6
        BNE.S   R1PP1
        MOVE.W  #R1A-R1F-6,R1F-R1C+6(A0)
        MOVE.W  #R1MA-R1MF-10,R1MF-R1C+10(A0)
        BRA.S   R1PP3
R1PP1:  LSR.B   #1,D6
        BCS.S   R1P2
        MOVE.W  #$6000+R1A-R1B-2,R1B-R1C(A0)
        MOVE.L  #$60000000+R1MA-R1MB-2,R1MB-R1C(A0)
        BRA.S   R1PP2
R1P2:   MOVE.W  #SWPD7,R1B-R1C(A0)
        MOVE.W  D0,ER1B0-R1C+2(A0)
        MOVE.L  #SWMWD7,R1MB-R1C(A0)
        MOVE.W  D0,ER1MB0-R1C+2(A0)
        MOVE.L  D3,CR1B0-R1C(A0)
        MOVE.L  D3,CR1MB0-R1C(A0)
        MOVE.L  D7,CR1MB1-R1C(A0)
        TST.B   D6
        BNE.S   R1PP2
        MOVE.W  #R1B-R1F-6,R1F-R1C+6(A0)
        MOVE.W  #R1MB-R1MF-10,R1MF-R1C+10(A0)
        BRA.S   R1PP3
R1PP2:  MOVE.W  D0,ER1C0-R1C+2(A0)
        MOVE.W  D0,ER1MC0-R1C+2(A0)
        MOVE.W  #R1C-R1F-6,R1F-R1C+6(A0)
        MOVE.W  #R1MC-R1MF-10,R1MF-R1C+10(A0)
        MOVE.L  D3,CR1C0-R1C(A0)
        MOVE.L  D3,CR1MC0-R1C(A0)
        MOVE.L  D7,CR1MC1-R1C(A0)
R1PP3:
        MOVE.W  #160,A0
        SUB.W   D5,A0
        MOVE.B  (A4)+,D7
        BEQ     R1MD-8
R1D:    EXT.W   D7
        BRA.L   R1F+4

R1C:    MOVE.L  (A1),D5
        CLR.W   D5
        LSR.L   D1,D5
ER1C0:  MOVE.L  2(A1),D6
        CLR.W   D6
        LSR.L   D1,D6

        MOVE.W  D5,D2
        OR.W    D6,D2
        BNE.S   R1C0
        SUBQ.W  #8,A3
        BRA.S   R1B
R1C0:   MOVE.W  D2,D3
        NOT.W   D2
        MOVE.L  -(A3),D0
        AND.W   D2,D0
        OR.W    D6,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)
CR1C0:  AND.W   D2,-(A3)        ;OU     OR.W D3,-(A3)
        AND.W   D2,-(A3)   ;  IDEM

R1B:    SWAP    D7
        MOVE.W  VD7(PC),D7
R1B0:   SUBQ.W  #2,A1
        MOVE.L  (A1),D5
        LSR.L   D1,D5
ER1B0:  MOVE.L  2(A1),D6
        LSR.L   D1,D6

        MOVE.W  D5,D2
        OR.W    D6,D2
        BNE.S   R1B1
        SUBQ.W  #8,A3
        DBF     D7,R1B0
        BRA.S   R1BF+4
R1B1:   MOVE.W  D2,D3
        NOT.W   D2
        BNE.S   R1B2
        MOVE.W  A5,D3
        MOVEM.W D3-D6,-(A3)
        DBF     D7,R1B0
        BRA.S   R1BF+4
R1B2:   MOVE.L  -(A3),D0
        AND.W   D2,D0
        OR.W    D6,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)
CR1B0:  AND.W   D2,-(A3)        ;OU     OR.W D3,-(A3)
        AND.W   D2,-(A3)   ;  IDEM
R1BF:   DBF     D7,R1B0
        SWAP    D7

R1A:    MOVE.W  (A1),D5
        LSR.W   D1,D5
ER1A0:  MOVE.W  2(A1),D6
        LSR.W   D1,D6

        MOVE.W  D5,D2
        OR.W    D6,D2
        BNE.S   R1A1
        SUBQ.W  #8,A3
        BRA.S   R1F
R1A1:   MOVE.W  D2,D3
        NOT.W   D2
        MOVE.L  -(A3),D0
        AND.W   D2,D0
        OR.W    D6,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)
CR1A0:  AND.W   D2,-(A3)        ;OU     OR.W D3,-(A3)
        AND.W   D2,-(A3)   ;  IDEM
R1F:    ADD.W   A2,A1
        SUB.W   A0,A3
        DBF     D7,R1C

        MOVE.B  (A4)+,D7
        BNE.S   R1MD
        MOVE.L  (SP)+,A5
        RTS
R1MD:   EXT.W   D7
        BRA.L   R1MF+8           

R1MC:   MOVE.L  (A1),D5
        CLR.W   D5
        LSR.L   D1,D5
ER1MC0: MOVE.L  2(A1),D6
        CLR.W   D6
        LSR.L   D1,D6

        MOVE.W  D5,D2
        OR.W    D6,D2
        BNE.S   R1MC0
        SUBQ.W  #8,A3
        BRA.S   R1MB
R1MC0:  MOVE.W  D2,D3
        NOT.W   D2
        LEA.L   -168(A3),A3
CR1MC1: AND.W   D2,(A3)+
        AND.W   D2,(A3)+
        MOVE.L  (A3),D0
        AND.W   D2,D0
        OR.W    D6,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)+
        LEA.L   156(A3),A3
        MOVE.L  (A3),D0
        AND.W   D2,D0
        OR.W    D6,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)
CR1MC0: AND.W   D2,-(A3)         ;OU    OR.W D3,-(A3)
        AND.W   D2,-(A3)   ;  IDEM
 
R1MB:   SWAP    D7
        MOVE.W  VD7(PC),D7
R1MB0:  SUBQ.W  #2,A1
        MOVE.L  (A1),D5
        LSR.L   D1,D5
ER1MB0: MOVE.L  2(A1),D6
        LSR.L   D1,D6

        MOVE.W  D5,D2
        OR.W    D6,D2
        BNE.S   R1MB1
        SUBQ.W  #8,A3
        DBF     D7,R1MB0
        BRA.S   R1MBF+4
R1MB1:  MOVE.W  D2,D3
        NOT.W   D2
        BNE.S   R1MB2
        MOVE.W  A5,D3
        MOVEM.W D3-D6,-168(A3)
        MOVEM.W D3-D6,-(A3)
        DBF     D7,R1MB0
        BRA.S   R1MBF+4
R1MB2:  LEA.L   -168(A3),A3
CR1MB1: AND.W   D2,(A3)+
        AND.W   D2,(A3)+
        MOVE.L  (A3),D0
        AND.W   D2,D0
        OR.W    D6,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)+
        LEA.L   156(A3),A3
        MOVE.L  (A3),D0
        AND.W   D2,D0
        OR.W    D6,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)
CR1MB0: AND.W   D2,-(A3)         ;OU    OR.W D3,-(A3)
        AND.W   D2,-(A3)   ;  IDEM
R1MBF:  DBF     D7,R1MB0
        SWAP    D7

R1MA:   MOVE.W  (A1),D5
        LSR.W   D1,D5
ER1MA0: MOVE.W  2(A1),D6
        LSR.W   D1,D6

        MOVE.W  D5,D2
        OR.W    D6,D2
        BNE.S   R1MA0
        SUBQ.W  #8,A3
        BRA.S   R1MF
R1MA0:  MOVE.W  D2,D3
        NOT.W   D2
        LEA.L   -168(A3),A3
CR1MA1: AND.W   D2,(A3)+
        AND.W   D2,(A3)+
        MOVE.L  (A3),D0
        AND.W   D2,D0
        OR.W    D6,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)+
        LEA.L   156(A3),A3
        MOVE.L  (A3),D0
        AND.W   D2,D0
        OR.W    D6,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)
CR1MA0: AND.W   D2,-(A3)         ;OU    OR.W D3,-(A3)
        AND.W   D2,-(A3)   ;  IDEM

R1MF:   ADD.W   A2,A1
        LEA.L   -160(A3),A3
        SUB.W   A0,A3
        DBF     D7,R1MC
        MOVE.B  (A4)+,D7
        BNE     R1D
        MOVE.L  (SP)+,A5
        RTS
*********
RN0034L:
        LEA.L   L1C(PC),A0
        LSR.B   #1,D6
        BCS.S   L1P1
        MOVE.W  #$6000+L1F-L1A-2,L1A-L1C(A0)
        MOVE.W  #$6000+L1MF-L1MA-2,L1MA-L1C(A0)
        BRA.S   L1PP1
L1P1:   MOVE.W  #MLA1D5,L1A-L1C(A0)
        MOVE.W  D0,EL1A0-L1C+2(A0)
        MOVE.W  #MLA1D5,L1MA-L1C(A0)
        MOVE.W  D0,EL1MA0-L1C+2(A0)
        MOVE.L  D3,CL1A0-L1C(A0)
        MOVE.L  D3,CL1MA0-L1C(A0)
        MOVE.L  D7,CL1MA1-L1C(A0)
        TST.B   D6
        BNE.S   L1PP1
        MOVE.W  #L1A-L1F-6,L1F-L1C+6(A0)
        MOVE.W  #L1MA-L1MF-10,L1MF-L1C+10(A0)
        BRA.S   L1PP3
L1PP1:  LSR.B   #1,D6
        BCS.S   L1P2
        MOVE.W  #$6000+L1A-L1B-2,L1B-L1C(A0)
        MOVE.L  #$60000000+L1MA-L1MB-2,L1MB-L1C(A0)
        BRA.S   L1PP2
L1P2:   MOVE.W  #SWPD7,L1B-L1C(A0)
        MOVE.W  D0,EL1B0-L1C+2(A0)
        MOVE.L  #SWMWD7,L1MB-L1C(A0)
        MOVE.W  D0,EL1MB0-L1C+2(A0)
        MOVE.L  D3,CL1B0-L1C(A0)
        MOVE.L  D3,CL1MB0-L1C(A0)
        MOVE.L  D7,CL1MB1-L1C(A0)
        TST.B   D6
        BNE.S   L1PP2
        MOVE.W  #L1B-L1F-6,L1F-L1C+6(A0)
        MOVE.W  #L1MB-L1MF-10,L1MF-L1C+10(A0)
        BRA.S   L1PP3
L1PP2:  MOVE.W  D0,EL1C0-L1C+2(A0)
        MOVE.W  D0,EL1MC0-L1C+2(A0)
        MOVE.W  #L1C-L1F-6,L1F-L1C+6(A0)
        MOVE.W  #L1MC-L1MF-10,L1MF-L1C+10(A0)
        MOVE.L  D3,CL1C0-L1C(A0)
        MOVE.L  D3,CL1MC0-L1C(A0)
        MOVE.L  D7,CL1MC1-L1C(A0)
L1PP3:
        MOVE.W  #160,A0
        SUB.W   D5,A0
        MOVE.B  (A4)+,D7
        BEQ     L1MD-8
L1D:    EXT.W   D7
        BRA.L   L1F+4

L1C:    MOVE.W  (A1),D5
        LSL.W   D1,D5
EL1C0:  MOVE.W  2(A1),D6
        LSL.W   D1,D6

        MOVE.W  D5,D2
        OR.W    D6,D2
        BNE.S   L1C0
        SUBQ.W  #8,A3
        BRA.S   L1B
L1C0:   MOVE.W  D2,D3
        NOT.W   D2
        MOVE.L  -(A3),D0
        AND.W   D2,D0
        OR.W    D6,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)
CL1C0:  AND.W   D2,-(A3)        ;OU     OR.W D3,-(A3)
        AND.W   D2,-(A3)   ;  IDEM
 
L1B:    SWAP    D7
        MOVE.W  VD7(PC),D7
L1B0:   SUBQ.W  #2,A1
        MOVE.L  (A1),D5
        LSL.L   D1,D5
        SWAP    D5
EL1B0:  MOVE.L  2(A1),D6
        LSL.L   D1,D6
        SWAP    D6

        MOVE.W  D5,D2
        OR.W    D6,D2
        BNE.S   L1B1
        SUBQ.W  #8,A3
        DBF     D7,L1B0
        BRA.S   L1BF+4
L1B1:   MOVE.W  D2,D3
        NOT.W   D2
        BNE.S   L1B2
        MOVE.W  A5,D3
        MOVEM.W D3-D6,-(A3)
        DBF     D7,L1B0
        BRA.S   L1BF+4
L1B2:   MOVE.L  -(A3),D0
        AND.W   D2,D0
        OR.W    D6,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)
CL1B0:  AND.W   D2,-(A3)        ;OU     OR.W D3,-(A3)
        AND.W   D2,-(A3)   ;  IDEM

L1BF:   DBF     D7,L1B0
        SWAP    D7

L1A:    MOVE.L  (A1),D5
        CLR.W   D5
        ROL.L   D1,D5
EL1A0:  MOVE.L  2(A1),D6
        CLR.W   D6
        ROL.L   D1,D6

        MOVE.W  D5,D2
        OR.W    D6,D2
        BNE.S   L1A1
        SUBQ.W  #8,A3
        BRA.S   L1F
L1A1:   MOVE.W  D2,D3
        NOT.W   D2
        MOVE.L  -(A3),D0
        AND.W   D2,D0
        OR.W    D6,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)
CL1A0:  AND.W   D2,-(A3)        ;OU     OR.W D3,-(A3)
        AND.W   D2,-(A3)   ;  IDEM

L1F:    ADD.W   A2,A1
        SUB.W   A0,A3
        DBF     D7,L1C

        MOVE.B  (A4)+,D7
        BNE.S   L1MD
        MOVE.L  (SP)+,A5
        RTS
L1MD:   EXT.W   D7
        BRA.L   L1MF+8           

L1MC:   MOVE.W  (A1),D5
        LSL.W   D1,D5
EL1MC0: MOVE.W  2(A1),D6
        LSL.W   D1,D6

        MOVE.W  D5,D2
        OR.W    D6,D2
        BNE.S   L1MC0
        SUBQ.W  #8,A3
        BRA.S   L1MB
L1MC0:  MOVE.W  D2,D3
        NOT.W   D2
        LEA.L   -168(A3),A3
CL1MC1: AND.W   D2,(A3)+
        AND.W   D2,(A3)+
        MOVE.L  (A3),D0
        AND.W   D2,D0
        OR.W    D6,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)+
        LEA.L   156(A3),A3
        MOVE.L  (A3),D0
        AND.W   D2,D0
        OR.W    D6,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)
CL1MC0: AND.W   D2,-(A3)         ;OU    OR.W D3,-(A3)
        AND.W   D2,-(A3)   ;  IDEM
 
L1MB:   SWAP    D7
        MOVE.W  VD7(PC),D7
L1MB0:  SUBQ.W  #2,A1
        MOVE.L  (A1),D5
        LSL.L   D1,D5
        SWAP    D5
EL1MB0: MOVE.L  2(A1),D6
        LSL.L   D1,D6
        SWAP    D6

        MOVE.W  D5,D2
        OR.W    D6,D2
        BNE.S   L1MB1
        SUBQ.W  #8,A3
        DBF     D7,L1MB0
        BRA.S   L1MBF+4
L1MB1:  MOVE.W  D2,D3
        NOT.W   D2
        BNE.S   L1MB2
        MOVE.W  A5,D3
        MOVEM.W D3-D6,-168(A3)
        MOVEM.W D3-D6,-(A3)
        DBF     D7,L1MB0
        BRA.S   L1MBF+4
L1MB2:  LEA.L   -168(A3),A3
CL1MB1: AND.W   D2,(A3)+
        AND.W   D2,(A3)+
        MOVE.L  (A3),D0
        AND.W   D2,D0
        OR.W    D6,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)+
        LEA.L   156(A3),A3
        MOVE.L  (A3),D0
        AND.W   D2,D0
        OR.W    D6,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)
CL1MB0: AND.W   D2,-(A3)         ;OU    OR.W D3,-(A3)
        AND.W   D2,-(A3)   ;  IDEM
L1MBF:  DBF     D7,L1MB0
        SWAP    D7

L1MA:   MOVE.L  (A1),D5
        CLR.W   D5
        ROL.L   D1,D5
EL1MA0: MOVE.L  2(A1),D6
        CLR.W   D6
        ROL.L   D1,D6

        MOVE.W  D5,D2
        OR.W    D6,D2
        BNE.S   L1MA0
        SUBQ.W  #8,A3
        BRA.S   L1MF
L1MA0:  MOVE.W  D2,D3
        NOT.W   D2
        LEA.L   -168(A3),A3
CL1MA1: AND.W   D2,(A3)+
        AND.W   D2,(A3)+
        MOVE.L  (A3),D0
        AND.W   D2,D0
        OR.W    D6,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)+
        LEA.L   156(A3),A3
        MOVE.L  (A3),D0
        AND.W   D2,D0
        OR.W    D6,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)
CL1MA0: AND.W   D2,-(A3)         ;OU    OR.W D3,-(A3)
        AND.W   D2,-(A3)   ;  IDEM

L1MF:   ADD.W   A2,A1
        LEA.L   -160(A3),A3
        SUB.W   A0,A3
        DBF     D7,L1MC
        MOVE.B  (A4)+,D7
        BNE     L1D
        MOVE.L  (SP)+,A5
        RTS
**********
RM1004: MOVE.L  A5,-(SP)
        MOVE.W  D4,D0
        MOVE.W  D5,-(SP)
        CLR.W   D7
        MOVE.W  (A0)+,D5
        BEQ.S   S1RM14
        MOVEQ   #4,D7
S1RM14: MOVE.W  D5,A5
        MOVE.W  (A0),D5
        BEQ.S   S2RM14
        BSET    #3,D7
S2RM14: MOVE.L  VRM14(PC,D7.W),D4
        MOVE.L  VRM14+16(PC,D7.W),D7
        CMP.W   D2,D1
        BLE.S   RM1004R
        MOVE.W  D2,D1
        BRA     RM1004L
VRM14:  AND.W   D2,-(A3)
        AND.W   D2,-(A3)
        AND.W   D2,-(A3)
        OR.W    D4,-(A3)
        OR.W    D4,-(A3)
        AND.W   D2,-(A3)
        OR.W    D4,-(A3)
        OR.W    D4,-(A3)
        AND.W   D2,(A3)+
        AND.W   D2,(A3)+
        OR.W    D4,(A3)+
        AND.W   D2,(A3)+
        AND.W   D2,(A3)+
        OR.W    D4,(A3)+
        OR.W    D4,(A3)+
        OR.W    D4,(A3)+
RM1004R:
        LEA.L   R2C(PC),A0
        LSR.B   #1,D6
        BCS.S   R2P1
        MOVE.W  #$6000+R2F-R2A-2,R2A-R2C(A0)
        MOVE.W  #$6000+R2MF-R2MA-2,R2MA-R2C(A0)
        BRA.S   R2PP1
R2P1:   MOVE.W  #MWA1D3,R2A-R2C(A0)
        MOVE.W  D0,ER2A0-R2C+2(A0)
        MOVE.W  #MWA1D3,R2MA-R2C(A0)
        MOVE.W  D0,ER2MA0-R2C+2(A0)
        MOVE.L  D4,CR2A0-R2C(A0)
        MOVE.L  D4,CR2MA0-R2C(A0)
        MOVE.L  D7,CR2MA1-R2C(A0)
        TST.B   D6
        BNE.S   R2PP1
        MOVE.W  #R2A-R2F-6,R2F-R2C+6(A0)
        MOVE.W  #R2MA-R2MF-10,R2MF-R2C+10(A0)
        BRA.S   R2PP3
R2PP1:  LSR.B   #1,D6
        BCS.S   R2P2
        MOVE.W  #$6000+R2A-R2B-2,R2B-R2C(A0)
        MOVE.L  #$60000000+R2MA-R2MB-2,R2MB-R2C(A0)
        BRA.S   R2PP2
R2P2:   MOVE.W  #SWPD7,R2B-R2C(A0)
        MOVE.W  D0,ER2B0-R2C+2(A0)
        MOVE.L  #SWMWD7,R2MB-R2C(A0)
        MOVE.W  D0,ER2MB0-R2C+2(A0)
        MOVE.L  D4,CR2B0-R2C(A0)
        MOVE.L  D4,CR2MB0-R2C(A0)
        MOVE.L  D7,CR2MB1-R2C(A0)
        TST.B   D6
        BNE.S   R2PP2
        MOVE.W  #R2B-R2F-6,R2F-R2C+6(A0)
        MOVE.W  #R2MB-R2MF-10,R2MF-R2C+10(A0)
        BRA.S   R2PP3
R2PP2:  MOVE.W  D0,ER2C0-R2C+2(A0)
        MOVE.W  D0,ER2MC0-R2C+2(A0)
        MOVE.W  #R2C-R2F-6,R2F-R2C+6(A0)
        MOVE.W  #R2MC-R2MF-10,R2MF-R2C+10(A0)
        MOVE.L  D4,CR2C0-R2C(A0)
        MOVE.L  D4,CR2MC0-R2C(A0)
        MOVE.L  D7,CR2MC1-R2C(A0)
R2PP3:
        MOVE.W  #160,A0
        SUB.W   (A7)+,A0
        MOVE.B  (A4)+,D7
        BEQ     R2MD-8
R2D:    EXT.W   D7
        BRA.L   R2F+4

R2C:    MOVE.L  (A1),D3
        CLR.W   D3
        LSR.L   D1,D3
ER2C0:  MOVE.L  2(A1),D6
        CLR.W   D6
        LSR.L   D1,D6

        MOVE.W  D3,D2
        OR.W    D6,D2
        BNE.S   R2C0
        SUBQ.W  #8,A3
        BRA.S   R2B
R2C0:   MOVE.W  D2,D4
        NOT.W   D2
        MOVE.W  -(A3),D0
        OR.W    D4,D0
        EOR.W   D6,D0
        MOVE.W  D0,(A3)
CR2C0:  AND.W   D2,-(A3)
        AND.W   D2,-(A3)
        MOVE.W  -(A3),D0
        OR.W    D4,D0
        EOR.W   D3,D0
        MOVE.W  D0,(A3)

R2B:    SWAP    D7
        MOVE.W  VD7(PC),D7
R2B0:   SUBQ.W  #2,A1
        MOVE.L  (A1),D3
        LSR.L   D1,D3
ER2B0:  MOVE.L  2(A1),D6
        LSR.L   D1,D6

        MOVE.W  D3,D2
        OR.W    D6,D2
        BNE.S   R2B1
        SUBQ.W  #8,A3
        DBF     D7,R2B0
        BRA.S   R2BF+4
R2B1:   MOVE.W  D2,D4
        NOT.W   D2
        BNE.S   R2B2
        MOVE.W  A5,D4
        NOT.W   D3
        NOT.W   D6
        MOVEM.W D3-D6,-(A3)
        DBF     D7,R2B0
        BRA.S   R2BF+4
R2B2:   MOVE.W  -(A3),D0
        OR.W    D4,D0
        EOR.W   D6,D0
        MOVE.W  D0,(A3)
CR2B0:  AND.W   D2,-(A3)
        AND.W   D2,-(A3)
        MOVE.W  -(A3),D0
        OR.W    D4,D0
        EOR.W   D3,D0
        MOVE.W  D0,(A3)
R2BF:   DBF     D7,R2B0
        SWAP    D7

R2A:    MOVE.W  (A1),D3
        LSR.W   D1,D3
ER2A0:  MOVE.W  2(A1),D6
        LSR.W   D1,D6

        MOVE.W  D3,D2
        OR.W    D6,D2
        BNE.S   R2A1
        SUBQ.W  #8,A3
        BRA.S   R2F
R2A1:   MOVE.W  D2,D4
        NOT.W   D2
        MOVE.W  -(A3),D0
        OR.W    D4,D0
        EOR.W   D6,D0
        MOVE.W  D0,(A3)
CR2A0:  AND.W   D2,-(A3)
        AND.W   D2,-(A3)
        MOVE.W  -(A3),D0
        OR.W    D4,D0
        EOR.W   D3,D0
        MOVE.W  D0,(A3)
R2F:    ADD.W   A2,A1
        SUB.W   A0,A3
        DBF     D7,R2C

        MOVE.B  (A4)+,D7
        BNE.S   R2MD
        MOVE.L  (SP)+,A5
        RTS
R2MD:   EXT.W   D7
        BRA.L   R2MF+8           

R2MC:   MOVE.L  (A1),D3
        CLR.W   D3
        LSR.L   D1,D3
ER2MC0: MOVE.L  2(A1),D6
        CLR.W   D6
        LSR.L   D1,D6

        MOVE.W  D3,D2
        OR.W    D6,D2
        BNE.S   R2MC0
        SUBQ.W  #8,A3
        BRA.S   R2MB
R2MC0:  MOVE.W  D2,D4
        NOT.W   D2
        LEA.L   -168(A3),A3
        MOVE.W  (A3),D0
        OR.W    D4,D0
        EOR.W   D3,D0
        MOVE.W  D0,(A3)+
CR2MC1: AND.W   D2,(A3)+
        AND.W   D2,(A3)+
        MOVE.W  (A3),D0
        OR.W    D4,D0
        EOR.W   D6,D0
        MOVE.W  D0,(A3)+
        LEA.L   158(A3),A3
        MOVE.W  (A3),D0
        OR.W    D4,D0
        EOR.W   D6,D0
        MOVE.W  D0,(A3)
CR2MC0: AND.W   D2,-(A3)
        AND.W   D2,-(A3)
        MOVE.W  -(A3),D0
        OR.W    D4,D0
        EOR.W   D3,D0
        MOVE.W  D0,(A3)
 
R2MB:   SWAP    D7
        MOVE.W  VD7(PC),D7
R2MB0:  SUBQ.W  #2,A1
        MOVE.L  (A1),D3
        LSR.L   D1,D3
ER2MB0: MOVE.L  2(A1),D6
        LSR.L   D1,D6

        MOVE.W  D3,D2
        OR.W    D6,D2
        BNE.S   R2MB1
        SUBQ.W  #8,A3
        DBF     D7,R2MB0
        BRA.S   R2MBF+4
R2MB1:  MOVE.W  D2,D4
        NOT.W   D2
        BNE.S   R2MB2
        MOVE.W  A5,D4
        NOT.W   D3
        NOT.W   D6
        MOVEM.W D3-D6,-168(A3)
        MOVEM.W D3-D6,-(A3)
        DBF     D7,R2MB0
        BRA.S   R2MBF+4
R2MB2:  LEA.L   -168(A3),A3
        MOVE.W  (A3),D0
        OR.W    D4,D0
        EOR.W   D3,D0
        MOVE.W  D0,(A3)+
CR2MB1: AND.W   D2,(A3)+
        AND.W   D2,(A3)+
        MOVE.W  (A3),D0
        OR.W    D4,D0
        EOR.W   D6,D0
        MOVE.W  D0,(A3)+
        LEA.L   158(A3),A3
        MOVE.W  (A3),D0
        OR.W    D4,D0
        EOR.W   D6,D0
        MOVE.W  D0,(A3)
CR2MB0: AND.W   D2,-(A3)
        AND.W   D2,-(A3)
        MOVE.W  -(A3),D0
        OR.W    D4,D0
        EOR.W   D3,D0
        MOVE.W  D0,(A3)

R2MBF:  DBF     D7,R2MB0
        SWAP    D7

R2MA:   MOVE.W  (A1),D3
        LSR.W   D1,D3
ER2MA0: MOVE.W  2(A1),D6
        LSR.W   D1,D6

        MOVE.W  D3,D2
        OR.W    D6,D2
        BNE.S   R2MA0
        SUBQ.W  #8,A3
        BRA.S   R2MF
R2MA0:  MOVE.W  D2,D4
        NOT.W   D2  
        LEA.L   -168(A3),A3
        MOVE.W  (A3),D0
        OR.W    D4,D0
        EOR.W   D3,D0
        MOVE.W  D0,(A3)+
CR2MA1: AND.W   D2,(A3)+
        AND.W   D2,(A3)+
        MOVE.W  (A3),D0
        OR.W    D4,D0
        EOR.W   D6,D0
        MOVE.W  D0,(A3)+
        LEA.L   158(A3),A3
        MOVE.W  (A3),D0
        OR.W    D4,D0
        EOR.W   D6,D0
        MOVE.W  D0,(A3)
CR2MA0: AND.W   D2,-(A3)
        AND.W   D2,-(A3)
        MOVE.W  -(A3),D0
        OR.W    D4,D0
        EOR.W   D3,D0
        MOVE.W  D0,(A3)

R2MF:   ADD.W   A2,A1
        LEA.L   -160(A3),A3
        SUB.W   A0,A3
        DBF     D7,R2MC
        MOVE.B  (A4)+,D7
        BNE     R2D
        MOVE.L  (SP)+,A5
        RTS
*********
RM1004L:
        LEA.L   L2C(PC),A0
        LSR.B   #1,D6
        BCS.S   L2P1
        MOVE.W  #$6000+L2F-L2A-2,L2A-L2C(A0)
        MOVE.W  #$6000+L2MF-L2MA-2,L2MA-L2C(A0)
        BRA.S   L2PP1
L2P1:   MOVE.W  #MLA1D3,L2A-L2C(A0)
        MOVE.W  D0,EL2A0-L2C+2(A0)
        MOVE.W  #MLA1D3,L2MA-L2C(A0)
        MOVE.W  D0,EL2MA0-L2C+2(A0)
        MOVE.L  D4,CL2A0-L2C(A0)
        MOVE.L  D4,CL2MA0-L2C(A0)
        MOVE.L  D7,CL2MA1-L2C(A0)
        TST.B   D6
        BNE.S   L2PP1
        MOVE.W  #L2A-L2F-6,L2F-L2C+6(A0)
        MOVE.W  #L2MA-L2MF-10,L2MF-L2C+10(A0)
        BRA.S   L2PP3
L2PP1:  LSR.B   #1,D6
        BCS.S   L2P2
        MOVE.W  #$6000+L2A-L2B-2,L2B-L2C(A0)
        MOVE.L  #$60000000+L2MA-L2MB-2,L2MB-L2C(A0)
        BRA.S   L2PP2
L2P2:   MOVE.W  #SWPD7,L2B-L2C(A0)
        MOVE.W  D0,EL2B0-L2C+2(A0)
        MOVE.L  #SWMWD7,L2MB-L2C(A0)
        MOVE.W  D0,EL2MB0-L2C+2(A0)
        MOVE.L  D4,CL2B0-L2C(A0)
        MOVE.L  D4,CL2MB0-L2C(A0)
        MOVE.L  D7,CL2MB1-L2C(A0)
        TST.B   D6
        BNE.S   L2PP2
        MOVE.W  #L2B-L2F-6,L2F-L2C+6(A0)
        MOVE.W  #L2MB-L2MF-10,L2MF-L2C+10(A0)
        BRA.S   L2PP3
L2PP2:  MOVE.W  D0,EL2C0-L2C+2(A0)
        MOVE.W  D0,EL2MC0-L2C+2(A0)
        MOVE.W  #L2C-L2F-6,L2F-L2C+6(A0)
        MOVE.W  #L2MC-L2MF-10,L2MF-L2C+10(A0)
        MOVE.L  D4,CL2C0-L2C(A0)
        MOVE.L  D4,CL2MC0-L2C(A0)
        MOVE.L  D7,CL2MC1-L2C(A0)
L2PP3:
        MOVE.W  #160,A0
        SUB.W   (A7)+,A0
        MOVE.B  (A4)+,D7
        BEQ     L2MD-8
L2D:    EXT.W   D7
        BRA.L   L2F+4

L2C:    MOVE.W  (A1),D3
        LSL.W   D1,D3
EL2C0:  MOVE.W  2(A1),D6
        LSL.W   D1,D6

        MOVE.W  D3,D2
        OR.W    D6,D2
        BNE.S   L2C0
        SUBQ.W  #8,A3
        BRA.S   L2B
L2C0:   MOVE.W  D2,D4
        NOT.W   D2
        MOVE.W  -(A3),D0
        OR.W    D4,D0
        EOR.W   D6,D0
        MOVE.W  D0,(A3)
CL2C0:  AND.W   D2,-(A3)
        AND.W   D2,-(A3)
        MOVE.W  -(A3),D0
        OR.W    D4,D0
        EOR.W   D3,D0
        MOVE.W  D0,(A3)
 
L2B:    SWAP    D7
        MOVE.W  VD7(PC),D7
L2B0:   SUBQ.W  #2,A1
        MOVE.L  (A1),D3
        LSL.L   D1,D3
        SWAP    D3
EL2B0:  MOVE.L  2(A1),D6
        LSL.L   D1,D6
        SWAP    D6

        MOVE.W  D3,D2
        OR.W    D6,D2
        BNE.S   L2B1
        SUBQ.W  #8,A3
        DBF     D7,L2B0
        BRA.S   L2BF+4
L2B1:   MOVE.W  D2,D4
        NOT.W   D2
        BNE.S   L2B2
        MOVE.W  A5,D4
        NOT.W   D3
        NOT.W   D6
        MOVEM.W D3-D6,-(A3)
        DBF     D7,L2B0
        BRA.S   L2BF+4
L2B2:   MOVE.W  -(A3),D0
        OR.W    D4,D0
        EOR.W   D6,D0
        MOVE.W  D0,(A3)
CL2B0:  AND.W   D2,-(A3)
        AND.W   D2,-(A3)
        MOVE.W  -(A3),D0
        OR.W    D4,D0
        EOR.W   D3,D0
        MOVE.W  D0,(A3)

L2BF:   DBF     D7,L2B0
        SWAP    D7

L2A:    MOVE.L  (A1),D3
        CLR.W   D3
        ROL.L   D1,D3
EL2A0:  MOVE.L  2(A1),D6
        CLR.W   D6
        ROL.L   D1,D6

        MOVE.W  D3,D2
        OR.W    D6,D2
        BNE.S   L2A1
        SUBQ.W  #8,A3
        BRA.S   L2F
L2A1:   MOVE.W  D2,D4
        NOT.W   D2
        MOVE.W  -(A3),D0
        OR.W    D4,D0
        EOR.W   D6,D0
        MOVE.W  D0,(A3)
CL2A0:  AND.W   D2,-(A3)
        AND.W   D2,-(A3)
        MOVE.W  -(A3),D0
        OR.W    D4,D0
        EOR.W   D3,D0
        MOVE.W  D0,(A3)

L2F:    ADD.W   A2,A1
        SUB.W   A0,A3
        DBF     D7,L2C

        MOVE.B  (A4)+,D7
        BNE.S   L2MD
        MOVE.L  (SP)+,A5
        RTS
L2MD:   EXT.W   D7
        BRA.L   L2MF+8           

L2MC:   MOVE.W  (A1),D3
        LSL.W   D1,D3
EL2MC0: MOVE.W  2(A1),D6
        LSL.W   D1,D6

        MOVE.W  D3,D2
        OR.W    D6,D2
        BNE.S   L2MC0
        SUBQ.W  #8,A3
        BRA.S   L2MB
L2MC0:  MOVE.W  D2,D4
        NOT.W   D2  
        LEA.L   -168(A3),A3
        MOVE.W  (A3),D0
        OR.W    D4,D0
        EOR.W   D3,D0
        MOVE.W  D0,(A3)+
CL2MC1: AND.W   D2,(A3)+
        AND.W   D2,(A3)+
        MOVE.W  (A3),D0
        OR.W    D4,D0
        EOR.W   D6,D0
        MOVE.W  D0,(A3)+
        LEA.L   158(A3),A3
        MOVE.W  (A3),D0
        OR.W    D4,D0
        EOR.W   D6,D0
        MOVE.W  D0,(A3)
CL2MC0: AND.W   D2,-(A3)
        AND.W   D2,-(A3)
        MOVE.W  -(A3),D0
        OR.W    D4,D0
        EOR.W   D3,D0
        MOVE.W  D0,(A3)

L2MB:   SWAP    D7
        MOVE.W  VD7(PC),D7
L2MB0:  SUBQ.W  #2,A1
        MOVE.L  (A1),D3
        LSL.L   D1,D3
        SWAP    D3
EL2MB0: MOVE.L  2(A1),D6
        LSL.L   D1,D6
        SWAP    D6

        MOVE.W  D3,D2
        OR.W    D6,D2
        BNE.S   L2MB1
        SUBQ.W  #8,A3
        DBF     D7,L2MB0
        BRA.S   L2MBF+4
L2MB1:  MOVE.W  D2,D4
        NOT.W   D2
        BNE.S   L2MB2
        MOVE.W  A5,D4
        NOT.W   D3
        NOT.W   D6
        MOVEM.W D3-D6,-168(A3)
        MOVEM.W D3-D6,-(A3)
        DBF     D7,L2MB0
        BRA.S   L2MBF+4
L2MB2:  LEA.L   -168(A3),A3
        MOVE.W  (A3),D0
        OR.W    D4,D0
        EOR.W   D3,D0
        MOVE.W  D0,(A3)+
CL2MB1: AND.W   D2,(A3)+
        AND.W   D2,(A3)+
        MOVE.W  (A3),D0
        OR.W    D4,D0
        EOR.W   D6,D0
        MOVE.W  D0,(A3)+
        LEA.L   158(A3),A3
        MOVE.W  (A3),D0
        OR.W    D4,D0
        EOR.W   D6,D0
        MOVE.W  D0,(A3)
CL2MB0: AND.W   D2,-(A3)
        AND.W   D2,-(A3)
        MOVE.W  -(A3),D0
        OR.W    D4,D0
        EOR.W   D3,D0
        MOVE.W  D0,(A3)
L2MBF:  DBF     D7,L2MB0
        SWAP    D7

L2MA:   MOVE.L  (A1),D3
        CLR.W   D3
        ROL.L   D1,D3
EL2MA0: MOVE.L  2(A1),D6
        CLR.W   D6
        ROL.L   D1,D6

        MOVE.W  D3,D2
        OR.W    D6,D2
        BNE.S   L2MA0
        SUBQ.W  #8,A3
        BRA.S   L2MF
L2MA0:  MOVE.W  D2,D4
        NOT.W   D2
        LEA.L   -168(A3),A3
        MOVE.W  (A3),D0
        OR.W    D4,D0
        EOR.W   D3,D0
        MOVE.W  D0,(A3)+
CL2MA1: AND.W   D2,(A3)+
        AND.W   D2,(A3)+
        MOVE.W  (A3),D0
        OR.W    D4,D0
        EOR.W   D6,D0
        MOVE.W  D0,(A3)+
        LEA.L   158(A3),A3
        MOVE.W  (A3),D0
        OR.W    D4,D0
        EOR.W   D6,D0
        MOVE.W  D0,(A3)
CL2MA0: AND.W   D2,-(A3)
        AND.W   D2,-(A3)
        MOVE.W  -(A3),D0
        OR.W    D4,D0
        EOR.W   D3,D0
        MOVE.W  D0,(A3)

L2MF:   ADD.W   A2,A1
        LEA.L   -160(A3),A3
        SUB.W   A0,A3
        DBF     D7,L2MC
        MOVE.B  (A4)+,D7
        BNE     L2D
        MOVE.L  (SP)+,A5
        RTS
**********
RM0034: 
        MOVE.W  D4,D0
        MOVE.L  A5,-(SP)
        CLR.W   D7
        MOVE.W  (A0)+,D4
        BEQ.S   S1RM34
        MOVEQ   #4,D7
S1RM34: MOVE.W  D4,A5
        MOVE.W  (A0),D4
        BEQ.S   S2RM34
        BSET    #3,D7
S2RM34: MOVE.L  VRM34(PC,D7.W),D3
        MOVE.L  VRM34+16(PC,D7.W),D7
        CMP.W   D2,D1
        BLE.S   RM0034R
        MOVE.W  D2,D1
        BRA     RM0034L
VRM34:  AND.W   D2,-(A3)
        AND.W   D2,-(A3)
        AND.W   D2,-(A3)
        OR.W    D3,-(A3)
        OR.W    D3,-(A3)
        AND.W   D2,-(A3)
        OR.W    D3,-(A3)
        OR.W    D3,-(A3)
        AND.W   D2,(A3)+
        AND.W   D2,(A3)+
        OR.W    D3,(A3)+
        AND.W   D2,(A3)+
        AND.W   D2,(A3)+
        OR.W    D3,(A3)+
        OR.W    D3,(A3)+
        OR.W    D3,(A3)+
RM0034R:
        LEA.L   R3C(PC),A0
        LSR.B   #1,D6
        BCS.S   R3P1
        MOVE.W  #$6000+R3F-R3A-2,R3A-R3C(A0)
        MOVE.W  #$6000+R3MF-R3MA-2,R3MA-R3C(A0)
        BRA.S   R3PP1
R3P1:   MOVE.W  #MWA1D5,R3A-R3C(A0)
        MOVE.W  D0,ER3A0-R3C+2(A0)
        MOVE.W  #MWA1D5,R3MA-R3C(A0)
        MOVE.W  D0,ER3MA0-R3C+2(A0)
        MOVE.L  D3,CR3A0-R3C(A0)
        MOVE.L  D3,CR3MA0-R3C(A0)
        MOVE.L  D7,CR3MA1-R3C(A0)
        TST.B   D6
        BNE.S   R3PP1
        MOVE.W  #R3A-R3F-6,R3F-R3C+6(A0)
        MOVE.W  #R3MA-R3MF-10,R3MF-R3C+10(A0)
        BRA.S   R3PP3
R3PP1:  LSR.B   #1,D6
        BCS.S   R3P2
        MOVE.W  #$6000+R3A-R3B-2,R3B-R3C(A0)
        MOVE.L  #$60000000+R3MA-R3MB-2,R3MB-R3C(A0)
        BRA.S   R3PP2
R3P2:   MOVE.W  #SWPD7,R3B-R3C(A0)
        MOVE.W  D0,ER3B0-R3C+2(A0)
        MOVE.L  #SWMWD7,R3MB-R3C(A0)
        MOVE.W  D0,ER3MB0-R3C+2(A0)
        MOVE.L  D3,CR3B0-R3C(A0)
        MOVE.L  D3,CR3MB0-R3C(A0)
        MOVE.L  D7,CR3MB1-R3C(A0)
        TST.B   D6
        BNE.S   R3PP2
        MOVE.W  #R3B-R3F-6,R3F-R3C+6(A0)
        MOVE.W  #R3MB-R3MF-10,R3MF-R3C+10(A0)
        BRA.S   R3PP3
R3PP2:  MOVE.W  D0,ER3C0-R3C+2(A0)
        MOVE.W  D0,ER3MC0-R3C+2(A0)
        MOVE.W  #R3C-R3F-6,R3F-R3C+6(A0)
        MOVE.W  #R3MC-R3MF-10,R3MF-R3C+10(A0)
        MOVE.L  D3,CR3C0-R3C(A0)
        MOVE.L  D3,CR3MC0-R3C(A0)
        MOVE.L  D7,CR3MC1-R3C(A0)
R3PP3:
        MOVE.W  #160,A0
        SUB.W   D5,A0
        MOVE.B  (A4)+,D7
        BEQ     R3MD-8
R3D:    EXT.W   D7
        BRA.L   R3F+4

R3C:    MOVE.L  (A1),D5
        CLR.W   D5
        LSR.L   D1,D5
ER3C0:  MOVE.L  2(A1),D6
        CLR.W   D6
        LSR.L   D1,D6

        MOVE.W  D5,D2
        OR.W    D6,D2
        BNE.S   R3C0
        SUBQ.W  #8,A3
        BRA.S   R3B
R3C0:   MOVE.W  D2,D3
        NOT.W   D2
        MOVE.L  -(A3),D0
        OR.W    D3,D0
        EOR.W   D6,D0
        SWAP    D0
        OR.W    D3,D0
        EOR.W   D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)
CR3C0:  AND.W   D2,-(A3)        ;OU     OR.W D3,-(A3)
        AND.W   D2,-(A3)   ;  IDEM

R3B:    SWAP    D7
        MOVE.W  VD7(PC),D7
R3B0:   SUBQ.W  #2,A1
        MOVE.L  (A1),D5
        LSR.L   D1,D5
ER3B0:  MOVE.L  2(A1),D6
        LSR.L   D1,D6

        MOVE.W  D5,D2
        OR.W    D6,D2
        BNE.S   R3B1
        SUBQ.W  #8,A3
        DBF     D7,R3B0
        BRA.S   R3BF+4
R3B1:   MOVE.W  D2,D3
        NOT.W   D2
        BNE.S   R3B2
        MOVE.W  A5,D3
        NOT.W   D5
        NOT.W   D6
        MOVEM.W D3-D6,-(A3)
        DBF     D7,R3B0
        BRA.S   R3BF+4
R3B2:   MOVE.L  -(A3),D0
        OR.W    D3,D0
        EOR.W   D6,D0
        SWAP    D0
        OR.W    D3,D0
        EOR.W   D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)
CR3B0:  AND.W   D2,-(A3)        ;OU     OR.W D3,-(A3)
        AND.W   D2,-(A3)   ;  IDEM
R3BF:   DBF     D7,R3B0
        SWAP    D7

R3A:    MOVE.W  (A1),D5
        LSR.W   D1,D5
ER3A0:  MOVE.W  2(A1),D6
        LSR.W   D1,D6

        MOVE.W  D5,D2
        OR.W    D6,D2
        BNE.S   R3A1
        SUBQ.W  #8,A3
        BRA.S   R3F
R3A1:   MOVE.W  D2,D3
        NOT.W   D2
        MOVE.L  -(A3),D0
        OR.W    D3,D0
        EOR.W   D6,D0
        SWAP    D0
        OR.W    D3,D0
        EOR.W   D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)
CR3A0:  AND.W   D2,-(A3)        ;OU     OR.W D3,-(A3)
        AND.W   D2,-(A3)   ;  IDEM
R3F:    ADD.W   A2,A1
        SUB.W   A0,A3
        DBF     D7,R3C

        MOVE.B  (A4)+,D7
        BNE.S   R3MD
        MOVE.L  (SP)+,A5
        RTS
R3MD:   EXT.W   D7
        BRA.L   R3MF+8           

R3MC:   MOVE.L  (A1),D5
        CLR.W   D5
        LSR.L   D1,D5
ER3MC0: MOVE.L  2(A1),D6
        CLR.W   D6
        LSR.L   D1,D6

        MOVE.W  D5,D2
        OR.W    D6,D2
        BNE.S   R3MC0
        SUBQ.W  #8,A3
        BRA.S   R3MB
R3MC0:  MOVE.W  D2,D3
        NOT.W   D2
        LEA.L   -168(A3),A3
CR3MC1: AND.W   D2,(A3)+
        AND.W   D2,(A3)+
        MOVE.L  (A3),D0
        OR.W    D3,D0
        EOR.W   D6,D0
        SWAP    D0
        OR.W    D3,D0
        EOR.W   D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)+
        LEA.L   156(A3),A3
        MOVE.L  (A3),D0
        OR.W    D3,D0
        EOR.W   D6,D0
        SWAP    D0
        OR.W    D3,D0
        EOR.W   D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)
CR3MC0: AND.W   D2,-(A3)         ;OU    OR.W D3,-(A3)
        AND.W   D2,-(A3)   ;  IDEM
 
R3MB:   SWAP    D7
        MOVE.W  VD7(PC),D7
R3MB0:  SUBQ.W  #2,A1
        MOVE.L  (A1),D5
        LSR.L   D1,D5
ER3MB0: MOVE.L  2(A1),D6
        LSR.L   D1,D6

        MOVE.W  D5,D2
        OR.W    D6,D2
        BNE.S   R3MB1
        SUBQ.W  #8,A3
        DBF     D7,R3MB0
        BRA.S   R3MBF+4
R3MB1:  MOVE.W  D2,D3
        NOT.W   D2
        BNE.S   R3MB2
        MOVE.W  A5,D3
        NOT.W   D5
        NOT.W   D6
        MOVEM.W D3-D6,-168(A3)
        MOVEM.W D3-D6,-(A3)
        DBF     D7,R3MB0
        BRA.S   R3MBF+4
R3MB2:  LEA.L   -168(A3),A3
CR3MB1: AND.W   D2,(A3)+
        AND.W   D2,(A3)+
        MOVE.L  (A3),D0
        OR.W    D3,D0
        EOR.W   D6,D0
        SWAP    D0
        OR.W    D3,D0
        EOR.W   D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)+
        LEA.L   156(A3),A3
        MOVE.L  (A3),D0
        OR.W    D3,D0
        EOR.W   D6,D0
        SWAP    D0
        OR.W    D3,D0
        EOR.W   D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)
CR3MB0: AND.W   D2,-(A3)         ;OU    OR.W D3,-(A3)
        AND.W   D2,-(A3)   ;  IDEM
R3MBF:  DBF     D7,R3MB0
        SWAP    D7

R3MA:   MOVE.W  (A1),D5
        LSR.W   D1,D5
ER3MA0: MOVE.W  2(A1),D6
        LSR.W   D1,D6

        MOVE.W  D5,D2
        OR.W    D6,D2
        BNE.S   R3MA0
        SUBQ.W  #8,A3
        BRA.S   R3MF
R3MA0:  MOVE.W  D2,D3
        NOT.W   D2
        LEA.L   -168(A3),A3
CR3MA1: AND.W   D2,(A3)+
        AND.W   D2,(A3)+
        MOVE.L  (A3),D0
        OR.W    D3,D0
        EOR.W   D6,D0
        SWAP    D0
        OR.W    D3,D0
        EOR.W   D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)+
        LEA.L   156(A3),A3
        MOVE.L  (A3),D0
        OR.W    D3,D0
        EOR.W   D6,D0
        SWAP    D0
        OR.W    D3,D0
        EOR.W   D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)
CR3MA0: AND.W   D2,-(A3)         ;OU    OR.W D3,-(A3)
        AND.W   D2,-(A3)   ;  IDEM

R3MF:   ADD.W   A2,A1
        LEA.L   -160(A3),A3
        SUB.W   A0,A3
        DBF     D7,R3MC
        MOVE.B  (A4)+,D7
        BNE     R3D
        MOVE.L  (SP)+,A5
        RTS
*********
RM0034L:
        LEA.L   L3C(PC),A0
        LSR.B   #1,D6
        BCS.S   L3P1
        MOVE.W  #$6000+L3F-L3A-2,L3A-L3C(A0)
        MOVE.W  #$6000+L3MF-L3MA-2,L3MA-L3C(A0)
        BRA.S   L3PP1
L3P1:   MOVE.W  #MLA1D5,L3A-L3C(A0)
        MOVE.W  D0,EL3A0-L3C+2(A0)
        MOVE.W  #MLA1D5,L3MA-L3C(A0)
        MOVE.W  D0,EL3MA0-L3C+2(A0)
        MOVE.L  D3,CL3A0-L3C(A0)
        MOVE.L  D3,CL3MA0-L3C(A0)
        MOVE.L  D7,CL3MA1-L3C(A0)
        TST.B   D6
        BNE.S   L3PP1
        MOVE.W  #L3A-L3F-6,L3F-L3C+6(A0)
        MOVE.W  #L3MA-L3MF-10,L3MF-L3C+10(A0)
        BRA.S   L3PP3
L3PP1:  LSR.B   #1,D6
        BCS.S   L3P2
        MOVE.W  #$6000+L3A-L3B-2,L3B-L3C(A0)
        MOVE.L  #$60000000+L3MA-L3MB-2,L3MB-L3C(A0)
        BRA.S   L3PP2
L3P2:   MOVE.W  #SWPD7,L3B-L3C(A0)
        MOVE.W  D0,EL3B0-L3C+2(A0)
        MOVE.L  #SWMWD7,L3MB-L3C(A0)
        MOVE.W  D0,EL3MB0-L3C+2(A0)
        MOVE.L  D3,CL3B0-L3C(A0)
        MOVE.L  D3,CL3MB0-L3C(A0)
        MOVE.L  D7,CL3MB1-L3C(A0)
        TST.B   D6
        BNE.S   L3PP2
        MOVE.W  #L3B-L3F-6,L3F-L3C+6(A0)
        MOVE.W  #L3MB-L3MF-10,L3MF-L3C+10(A0)
        BRA.S   L3PP3
L3PP2:  MOVE.W  D0,EL3C0-L3C+2(A0)
        MOVE.W  D0,EL3MC0-L3C+2(A0)
        MOVE.W  #L3C-L3F-6,L3F-L3C+6(A0)
        MOVE.W  #L3MC-L3MF-10,L3MF-L3C+10(A0)
        MOVE.L  D3,CL3C0-L3C(A0)
        MOVE.L  D3,CL3MC0-L3C(A0)
        MOVE.L  D7,CL3MC1-L3C(A0)
L3PP3:
        MOVE.W  #160,A0
        SUB.W   D5,A0
        MOVE.B  (A4)+,D7
        BEQ     L3MD-8
L3D:    EXT.W   D7
        BRA.L   L3F+4

L3C:    MOVE.W  (A1),D5
        LSL.W   D1,D5
EL3C0:  MOVE.W  2(A1),D6
        LSL.W   D1,D6

        MOVE.W  D5,D2
        OR.W    D6,D2
        BNE.S   L3C0
        SUBQ.W  #8,A3
        BRA.S   L3B
L3C0:   MOVE.W  D2,D3
        NOT.W   D2
        MOVE.L  -(A3),D0
        OR.W    D3,D0
        EOR.W   D6,D0
        SWAP    D0
        OR.W    D3,D0
        EOR.W   D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)
CL3C0:  AND.W   D2,-(A3)        ;OU     OR.W D3,-(A3)
        AND.W   D2,-(A3)   ;  IDEM
 
L3B:    SWAP    D7
        MOVE.W  VD7(PC),D7
L3B0:   SUBQ.W  #2,A1
        MOVE.L  (A1),D5
        LSL.L   D1,D5
        SWAP    D5
EL3B0:  MOVE.L  2(A1),D6
        LSL.L   D1,D6
        SWAP    D6

        MOVE.W  D5,D2
        OR.W    D6,D2
        BNE.S   L3B1
        SUBQ.W  #8,A3
        DBF     D7,L3B0
        BRA.S   L3BF+4
L3B1:   MOVE.W  D2,D3
        NOT.W   D2
        BNE.S   L3B2
        MOVE.W  A5,D3
        NOT.W   D5
        NOT.W   D6
        MOVEM.W D3-D6,-(A3)
        DBF     D7,L3B0
        BRA.S   L3BF+4
L3B2:   MOVE.L  -(A3),D0
        OR.W    D3,D0
        EOR.W   D6,D0
        SWAP    D0
        OR.W    D3,D0
        EOR.W   D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)
CL3B0:  AND.W   D2,-(A3)        ;OU     OR.W D3,-(A3)
        AND.W   D2,-(A3)   ;  IDEM

L3BF:   DBF     D7,L3B0
        SWAP    D7

L3A:    MOVE.L  (A1),D5
        CLR.W   D5
        ROL.L   D1,D5
EL3A0:  MOVE.L  2(A1),D6
        CLR.W   D6
        ROL.L   D1,D6

        MOVE.W  D5,D2
        OR.W    D6,D2
        BNE.S   L3A1
        SUBQ.W  #8,A3
        BRA.S   L3F
L3A1:   MOVE.W  D2,D3
        NOT.W   D2
        MOVE.L  -(A3),D0
        OR.W    D3,D0
        EOR.W   D6,D0
        SWAP    D0
        OR.W    D3,D0
        EOR.W   D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)
CL3A0:  AND.W   D2,-(A3)        ;OU     OR.W D3,-(A3)
        AND.W   D2,-(A3)   ;  IDEM

L3F:    ADD.W   A2,A1
        SUB.W   A0,A3
        DBF     D7,L3C

        MOVE.B  (A4)+,D7
        BNE.S   L3MD
        MOVE.L  (SP)+,A5
        RTS
L3MD:   EXT.W   D7
        BRA.L   L3MF+8           

L3MC:   MOVE.W  (A1),D5
        LSL.W   D1,D5
EL3MC0: MOVE.W  2(A1),D6
        LSL.W   D1,D6

        MOVE.W  D5,D2
        OR.W    D6,D2
        BNE.S   L3MC0
        SUBQ.W  #8,A3
        BRA.S   L3MB
L3MC0:  MOVE.W  D2,D3
        NOT.W   D2
        LEA.L   -168(A3),A3
CL3MC1: AND.W   D2,(A3)+
        AND.W   D2,(A3)+
        MOVE.L  (A3),D0
        OR.W    D3,D0
        EOR.W   D6,D0
        SWAP    D0
        OR.W    D3,D0
        EOR.W   D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)+
        LEA.L   156(A3),A3
        MOVE.L  (A3),D0
        OR.W    D3,D0
        EOR.W   D6,D0
        SWAP    D0
        OR.W    D3,D0
        EOR.W   D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)
CL3MC0: AND.W   D2,-(A3)         ;OU    OR.W D3,-(A3)
        AND.W   D2,-(A3)   ;  IDEM
 
L3MB:   SWAP    D7
        MOVE.W  VD7(PC),D7
L3MB0:  SUBQ.W  #2,A1
        MOVE.L  (A1),D5
        LSL.L   D1,D5
        SWAP    D5
EL3MB0: MOVE.L  2(A1),D6
        LSL.L   D1,D6
        SWAP    D6

        MOVE.W  D5,D2
        OR.W    D6,D2
        BNE.S   L3MB1
        SUBQ.W  #8,A3
        DBF     D7,L3MB0
        BRA.S   L3MBF+4
L3MB1:  MOVE.W  D2,D3
        NOT.W   D2
        BNE.S   L3MB2
        MOVE.W  A5,D3
        NOT.W   D5
        NOT.W   D6
        MOVEM.W D3-D6,-168(A3)
        MOVEM.W D3-D6,-(A3)
        DBF     D7,L3MB0
        BRA.S   L3MBF+4
L3MB2:  LEA.L   -168(A3),A3
CL3MB1: AND.W   D2,(A3)+
        AND.W   D2,(A3)+
        MOVE.L  (A3),D0
        OR.W    D3,D0
        EOR.W   D6,D0
        SWAP    D0
        OR.W    D3,D0
        EOR.W   D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)+
        LEA.L   156(A3),A3
        MOVE.L  (A3),D0
        OR.W    D3,D0
        EOR.W   D6,D0
        SWAP    D0
        OR.W    D3,D0
        EOR.W   D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)
CL3MB0: AND.W   D2,-(A3)         ;OU    OR.W D3,-(A3)
        AND.W   D2,-(A3)   ;  IDEM
L3MBF:  DBF     D7,L3MB0
        SWAP    D7

L3MA:   MOVE.L  (A1),D5
        CLR.W   D5
        ROL.L   D1,D5
EL3MA0: MOVE.L  2(A1),D6
        CLR.W   D6
        ROL.L   D1,D6

        MOVE.W  D5,D2
        OR.W    D6,D2
        BNE.S   L3MA0
        SUBQ.W  #8,A3
        BRA.S   L3MF
L3MA0:  MOVE.W  D2,D3
        NOT.W   D2
        LEA.L   -168(A3),A3
CL3MA1: AND.W   D2,(A3)+
        AND.W   D2,(A3)+
        MOVE.L  (A3),D0
        OR.W    D3,D0
        EOR.W   D6,D0
        SWAP    D0
        OR.W    D3,D0
        EOR.W   D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)+
        LEA.L   156(A3),A3
        MOVE.L  (A3),D0
        OR.W    D3,D0
        EOR.W   D6,D0
        SWAP    D0
        OR.W    D3,D0
        EOR.W   D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)
CL3MA0: AND.W   D2,-(A3)         ;OU    OR.W D3,-(A3)
        AND.W   D2,-(A3)   ;  IDEM

L3MF:   ADD.W   A2,A1
        LEA.L   -160(A3),A3
        SUB.W   A0,A3
        DBF     D7,L3MC
        MOVE.B  (A4)+,D7
        BNE     L3D
        MOVE.L  (SP)+,A5
        RTS
**********
RC1200: MOVE.W  D5,-(A7)
        MOVE.L  (A0),-(A7)
        MOVE.W  D6,-(A7)
        CLR.W   D7
        TST.W   (A0)+
        BEQ.S   S1RC12
        MOVEQ   #4,D7
S1RC12: TST.W   (A0)
        BEQ.S   S2RC12
        BSET    #3,D7
S2RC12: MOVE.L  VRC12(PC,D7.W),D3
        MOVE.L  VRC12+16(PC,D7.W),D5
        MOVE.L  VRC12+32(PC,D7.W),D6
        MOVE.L  VRC12+48(PC,D7.W),D7
        CMP.W   D2,D1
        BLE.S   RC1200R
        MOVE.W  D2,D1
        BRA     RC1200L
VRC12:  AND.W   D2,-(A3)
        AND.W   D2,-(A3)
        AND.W   D2,-(A3)
        OR.W    D3,-(A3)
        OR.W    D3,-(A3)
        AND.W   D2,-(A3)
        OR.W    D3,-(A3)
        OR.W    D3,-(A3)
        AND.W   D0,-(A3)
        AND.W   D0,-(A3)
        AND.W   D0,-(A3)
        OR.W    D3,-(A3)
        OR.W    D3,-(A3)
        AND.W   D0,-(A3)
        OR.W    D3,-(A3)
        OR.W    D3,-(A3)
        DC.W    AND2
        DC.W    AND2
        DC.W    AND2
        DC.W    ORD3
        DC.W    ORD3
        DC.W    AND2
        DC.W    ORD3
        DC.W    ORD3

        DC.W    AND0
        DC.W    AND0
        DC.W    AND0
        DC.W    ORD3
        DC.W    ORD3
        DC.W    AND0
        DC.W    ORD3
        DC.W    ORD3
RC1200R:
        MOVE.W  (A7)+,D2
        LEA.L   CR1C(PC),A0
        LSR.B   #1,D2
        BCS.S   CR1P1
        MOVE.W  #$6000+CR1F-CR1A-2,CR1A-CR1C(A0)
        MOVE.W  #$6000+CR1MF-CR1MA-2,CR1MA-CR1C(A0)
        BRA.S   CR1PP1
CR1P1:  MOVE.W  #MWD0D3,CR1A-CR1C(A0)
        MOVE.W  D4,ECR1A0-CR1C+2(A0)
        MOVE.W  #MWD0D3,CR1MA-CR1C(A0)
        MOVE.W  D4,ECR1MA0-CR1C+2(A0)
        MOVE.L  D5,ICR1A0-CR1C(A0)
        MOVE.L  D5,ICR1MA0-CR1C(A0)
        MOVE.W  D7,ICR1MA0-CR1C+8(A0)
        SWAP    D7
        MOVE.W  D7,ICR1MA0-CR1C+4(A0)
        SWAP    D7
        TST.B   D2
        BNE.S   CR1PP1
        OR.L    MSKD2(PC),D0
        MOVE.W  #CR1A-CR1F-6,CR1F-CR1C+6(A0)
        MOVE.W  #CR1MA-CR1MF-10,CR1MF-CR1C+10(A0)
        BRA     CR1PP3
CR1PP1: LSR.B   #1,D2
        BCS.S   CR1P2
        MOVE.W  #$6000+CR1A-CR1B-2,CR1B-CR1C(A0)
        MOVE.W  #$6000+CR1MA-CR1MB-2,CR1MB-CR1C(A0)
        BRA.S   CR1PP2
CR1P2:  MOVE.W  #SWPD7,CR1B-CR1C(A0)
        MOVE.W  D4,ECR1B0-CR1C+2(A0)
        MOVE.W  #SWPD7,CR1MB-CR1C(A0)
        MOVE.W  D4,ECR1MB0-CR1C+2(A0)
        TST.B   D2
        BNE.S   CR1PP2
        MOVE.W  #CR1B-CR1F-6,CR1F-CR1C+6(A0)
        MOVE.W  #CR1MB-CR1MF-10,CR1MF-CR1C+10(A0)
        BRA.S   CR1PP3
CR1PP2: LSR.B   #1,D2
        BCC.S   CR1PPX
        MOVE.W  D4,ECR1C0-CR1C+2(A0)
        MOVE.W  D4,ECR1MC0-CR1C+2(A0)
        MOVE.W  #CR1C-CR1F-6,CR1F-CR1C+6(A0)
        MOVE.W  #CR1MC-CR1MF-10,CR1MF-CR1C+10(A0)
        MOVE.L  D3,ICR1C0-CR1C(A0)
        MOVE.L  D3,ICR1MC0-CR1C(A0)
        MOVE.W  D6,ICR1MC0-CR1C+8(A0)
        SWAP    D6
        MOVE.W  D6,ICR1MC0-CR1C+4(A0)
        SWAP    D6
        BRA.S   CR1PP3
CR1PPX: MOVE.W  D4,ECR1X0-CR1C+2(A0)
        MOVE.W  D4,ECR1MX0-CR1C+2(A0)
        MOVE.W  #CR1X-CR1F-6,CR1F-CR1C+6(A0)
        MOVE.W  #CR1MX-CR1MF-10,CR1MF-CR1C+10(A0)
        MOVE.L  D3,ICR1X0-CR1C(A0)
        MOVE.L  D3,ICR1MX0-CR1C(A0)
        MOVE.W  D6,ICR1MX0-CR1C+8(A0)
        SWAP    D6
        MOVE.W  D6,ICR1MX0-CR1C+4(A0)
        SWAP    D6
CR1PP3:
        MOVE.L  MSKD2(PC),D2
        MOVE.W  (A7)+,D5
        MOVE.W  (A7)+,D6
        MOVE.W  #160,A0
        SUB.W   (A7)+,A0

        MOVE.B  (A4)+,D7
        BEQ     CR1MD-6
CR1D:   EXT.W   D7
        BRA     CR1F+4

CR1C:   MOVE.W  D2,D3
        NOT.W   D3
ICR1C0: OR.W    D2,-(A3)
        AND.W   D3,-(A3)
        MOVEQ   #0,D3
        MOVE.W  (A1),D3
        ROR.L   D1,D3
ECR1C0: MOVE.L  2(A1),D4
        CLR.W   D4
        LSR.L   D1,D4
        MOVE.W  D4,D3
        AND.L   D2,-(A3)
        OR.L    D3,(A3)
        BRA.S   CR1B

CR1X:   MOVE.W  D2,D3
        NOT.W   D3
ICR1X0: OR.W    D2,-(A3)
        AND.W   D3,-(A3)
        MOVE.L  (A1),D3
        LSR.L   D1,D3
        SWAP    D3
ECR1X0: MOVE.L  2(A1),D4
        LSR.L   D1,D4
        MOVE.W  D4,D3
        AND.L   D2,-(A3)
        OR.L    D3,(A3)

CR1B:   SWAP    D7
        MOVE.W  VD7(PC),D7
CR1B02: SUBQ.W  #2,A1
        MOVE.L  (A1),D3
        LSR.L   D1,D3
ECR1B0: MOVE.L  2(A1),D4
        LSR.L   D1,D4
        MOVEM.W D3-D6,-(A3)
        DBF     D7,CR1B02
        SWAP    D7

CR1A:   MOVE.W  D0,D3
        NOT.W   D3
ICR1A0: OR.W    D0,-(A3)
        AND.W   D3,-(A3)
        MOVE.W  (A1),D3
        LSR.W   D1,D3
        SWAP    D3
ECR1A0: MOVE.W  2(A1),D3
        LSR.W   D1,D3
        AND.L   D0,-(A3)
        OR.L    D3,(A3)

CR1F:   ADD.W   A2,A1
        SUB.W   A0,A3
        DBF     D7,CR1C

        MOVE.B  (A4)+,D7
        BNE.S   CR1MD
        RTS
CR1MD:  EXT.W   D7
        BRA     CR1MF+8  

CR1MC:  MOVE.W  D2,D3
        NOT.W   D3
ICR1MC0:
        OR.W    D3,-(A3)
        AND.W   D2,-(A3)
        OR.W    D3,-158(A3)
        AND.W   D2,-160(A3)
        MOVEQ   #0,D3
        MOVE.W  (A1),D3
        ROR.L   D1,D3
ECR1MC0: MOVE.L  2(A1),D4
        CLR.W   D4
        LSR.L   D1,D4
        MOVE.W  D4,D3
        AND.L   D2,-164(A3)
        OR.L    D3,-164(A3)
        AND.L   D2,-(A3)
        OR.L    D3,(A3)
        BRA.S   CR1MB

CR1MX:  MOVE.W  D2,D3
        NOT.W   D3
ICR1MX0:
        OR.W    D2,-(A3)
        AND.W   D3,-(A3)
        OR.W    D2,-158(A3)
        AND.W   D3,-160(A3)
        MOVE.L  (A1),D3
        LSR.L   D1,D3
        SWAP    D3
ECR1MX0: MOVE.L  2(A1),D4
        LSR.L   D1,D4
        MOVE.W  D4,D3
        AND.L   D2,-164(A3)
        OR.L    D3,-164(A3)
        AND.L   D2,-(A3)
        OR.L    D3,(A3)

CR1MB:  SWAP    D7
        MOVE.W  VD7(PC),D7
CR1MB02: SUBQ.W  #2,A1
        MOVE.L  (A1),D3
        LSR.L   D1,D3
ECR1MB0: MOVE.L  2(A1),D4
        LSR.L   D1,D4
        MOVEM.W D3-D6,-(A3)
        MOVEM.W D3-D6,-160(A3)
        DBF     D7,CR1MB02
        SWAP    D7

CR1MA:  MOVE.W  D0,D3
        NOT.W   D3
ICR1MA0:
        OR.W    D3,-(A3)
        AND.W   D0,-(A3)
        OR.W    D3,-158(A3)
        AND.W   D0,-160(A3)
        MOVE.W  (A1),D3
        LSR.W   D1,D3
        SWAP    D3
ECR1MA0: MOVE.W  2(A1),D3
        LSR.W   D1,D3
        AND.L   D0,-(A3)
        OR.L    D3,(A3)
        AND.L   D0,-160(A3)
        OR.L    D3,-160(A3)

CR1MF:  ADD.W   A2,A1
        LEA.L   -160(A3),A3
        SUB.W   A0,A3
        DBF     D7,CR1MC
        MOVE.B  (A4)+,D7
        BNE     CR1D
        RTS
**********
RC1200L:
        MOVE.W  (A7)+,D2
        LEA.L   CL1C(PC),A0
        LSR.B   #1,D2
        BCS.S   CL1P1
        MOVE.W  #$6000+CL1F-CL1A-2,CL1A-CL1C(A0)
        MOVE.W  #$6000+CL1MF-CL1MA-2,CL1MA-CL1C(A0)
        BRA.S   CL1PP1
CL1P1:  MOVE.W  #MWD0D3,CL1A-CL1C(A0)
        MOVE.W  D4,ECL1A0-CL1C+2(A0)
        MOVE.W  #MWD0D3,CL1MA-CL1C(A0)
        MOVE.W  D4,ECL1MA0-CL1C+2(A0)
        MOVE.L  D5,ICL1A0-CL1C(A0)
        MOVE.L  D5,ICL1MA0-CL1C(A0)
        MOVE.W  D7,ICL1MA0-CL1C+8(A0)
        SWAP    D7
        MOVE.W  D7,ICL1MA0-CL1C+4(A0)
        SWAP    D7
        TST.B   D2
        BNE.S   CL1PP1
        OR.L    MSKD2(PC),D0
        MOVE.W  #CL1A-CL1F-6,CL1F-CL1C+6(A0)
        MOVE.W  #CL1MA-CL1MF-10,CL1MF-CL1C+10(A0)
        BRA     CL1PP3
CL1PP1: LSR.B   #1,D2
        BCS.S   CL1P2
        MOVE.W  #$6000+CL1A-CL1B-2,CL1B-CL1C(A0)
        MOVE.W  #$6000+CL1MA-CL1MB-2,CL1MB-CL1C(A0)
        BRA.S   CL1PP2
CL1P2:  MOVE.W  #SWPD7,CL1B-CL1C(A0)
        MOVE.W  D4,ECL1B0-CL1C+2(A0)
        MOVE.W  #SWPD7,CL1MB-CL1C(A0)
        MOVE.W  D4,ECL1MB0-CL1C+2(A0)
        TST.B   D2
        BNE.S   CL1PP2
        MOVE.W  #CL1B-CL1F-6,CL1F-CL1C+6(A0)
        MOVE.W  #CL1MB-CL1MF-10,CL1MF-CL1C+10(A0)
        BRA.S   CL1PP3
CL1PP2: LSR.B   #1,D2
        BCC.S   CL1PPX
        MOVE.W  D4,ECL1C0-CL1C+2(A0)
        MOVE.W  D4,ECL1MC0-CL1C+2(A0)
        MOVE.W  #CL1C-CL1F-6,CL1F-CL1C+6(A0)
        MOVE.W  #CL1MC-CL1MF-10,CL1MF-CL1C+10(A0)
        MOVE.L  D3,ICL1C0-CL1C(A0)
        MOVE.L  D3,ICL1MC0-CL1C(A0)
        MOVE.W  D6,ICL1MC0-CL1C+8(A0)
        SWAP    D6
        MOVE.W  D6,ICL1MC0-CL1C+4(A0)
        SWAP    D6
        BRA.S   CL1PP3
CL1PPX: MOVE.W  D4,ECL1X0-CL1C+2(A0)
        MOVE.W  D4,ECL1MX0-CL1C+2(A0)
        MOVE.W  #CL1X-CL1F-6,CL1F-CL1C+6(A0)
        MOVE.W  #CL1MX-CL1MF-10,CL1MF-CL1C+10(A0)
        MOVE.L  D3,ICL1X0-CL1C(A0)
        MOVE.L  D3,ICL1MX0-CL1C(A0)
        MOVE.W  D6,ICL1MX0-CL1C+8(A0)
        SWAP    D6
        MOVE.W  D6,ICL1MX0-CL1C+4(A0)
        SWAP    D6
CL1PP3:
        MOVE.L  MSKD2(PC),D2
        MOVE.W  (A7)+,D5
        MOVE.W  (A7)+,D6
        MOVE.W  #160,A0
        SUB.W   (A7)+,A0

        MOVE.B  (A4)+,D7
        BEQ     CL1MD-6
CL1D:   EXT.W   D7
        BRA     CL1F+4

CL1C:   MOVE.W  D2,D3
        NOT.W   D3
ICL1C0: OR.W    D2,-(A3)
        AND.W   D3,-(A3)
        MOVE.W  (A1),D3
        LSL.W   D1,D3
        SWAP    D3
ECL1C0: MOVE.W  2(A1),D3
        LSL.W   D1,D3
        AND.L   D2,-(A3)
        OR.L    D3,(A3)
        BRA.S   CL1B

CL1X:   MOVE.W  D2,D3
        NOT.W   D3
ICL1X0: OR.W    D2,-(A3)
        AND.W   D3,-(A3)
        MOVE.L  (A1),D3
        LSL.L   D1,D3
ECL1X0: MOVE.L  2(A1),D4
        LSL.L   D1,D4
        SWAP    D4
        MOVE.W  D4,D3
        AND.L   D2,-(A3)
        OR.L    D3,(A3)

CL1B:   SWAP    D7
        MOVE.W  VD7(PC),D7
CL1B02: SUBQ.W  #2,A1
        MOVE.L  (A1),D3
        LSL.L   D1,D3
        SWAP    D3
ECL1B0: MOVE.L  2(A1),D4
        LSL.L   D1,D4
        SWAP    D4
        MOVEM.W D3-D6,-(A3)
        DBF     D7,CL1B02
        SWAP    D7

CL1A:   MOVE.W  D0,D3
        NOT.W   D3
ICL1A0: OR.W    D0,-(A3)
        AND.W   D3,-(A3)
        MOVEQ   #0,D3
        MOVE.W  (A1),D3
        LSL.L   D1,D3
ECL1A0: MOVE.L  6(A1),D4
        CLR.W   D4
        ROL.L   D1,D4
        MOVE.W  D4,D3
        AND.L   D0,-(A3)
        OR.L    D3,(A3)

CL1F:   ADD.W   A2,A1
        SUB.W   A0,A3
        DBF     D7,CL1C

        MOVE.B  (A4)+,D7
        BNE.S   CL1MD
        RTS
CL1MD:  EXT.W   D7
        BRA     CL1MF+8

CL1MC:  MOVE.W  D2,D3
        NOT.W   D3
ICL1MC0: OR.W    D2,-(A3)
        AND.W   D3,-(A3)
        OR.W    D2,-158(A3)
        AND.W   D3,-160(A3)
        MOVE.W  (A1),D3
        LSL.W   D1,D3
        SWAP    D3
ECL1MC0: MOVE.W  2(A1),D3
        LSL.W   D1,D3
        AND.L   D2,-(A3)
        OR.L    D3,(A3)
        AND.L   D2,-160(A3)
        OR.L    D3,-160(A3)
        BRA.S   CL1MB

CL1MX:  MOVE.W  D2,D3
        NOT.W   D3
ICL1MX0: OR.W    D2,-(A3)
        AND.W   D3,-(A3)
        OR.W    D2,-158(A3)
        AND.W   D3,-160(A3)
        MOVE.L  (A1),D3
        LSL.L   D1,D3
ECL1MX0: MOVE.L  2(A1),D4
        LSL.L   D1,D4
        SWAP    D4
        MOVE.W  D4,D3
        AND.L   D2,-(A3)
        OR.L    D3,(A3)
        AND.L   D2,-160(A3)
        OR.L    D3,-160(A3)

CL1MB:  SWAP    D7
        MOVE.W  VD7(PC),D7
CL1MB02: SUBQ.W  #2,A1
        MOVE.L  (A1),D3
        LSL.L   D1,D3
        SWAP    D3
ECL1MB0: MOVE.L  2(A1),D4
        LSL.L   D1,D4
        SWAP    D4
        MOVEM.W D3-D6,-(A3)
        MOVEM.W D3-D6,-160(A3)
        DBF     D7,CL1MB02
        SWAP    D7

CL1MA:  MOVE.W  D0,D3
        NOT.W   D3
ICL1MA0: OR.W    D0,-(A3)
        AND.W   D3,-(A3)
        OR.W    D0,-158(A3)
        AND.W   D3,-160(A3)
        MOVEQ   #0,D3
        MOVE.W  (A1),D3
        LSL.L   D1,D3
ECL1MA0: MOVE.L  6(A1),D4
        CLR.W   D4
        ROL.L   D1,D4
        MOVE.W  D4,D3
        AND.L   D0,-(A3)
        OR.L    D3,(A3)
        AND.L   D0,-160(A3)
        OR.L    D3,-160(A3)

CL1MF:  ADD.W   A2,A1
        LEA.L   -160(A3),A3
        SUB.W   A0,A3
        DBF     D7,CL1MC
        MOVE.B  (A4)+,D7
        BNE     CL1D
        RTS
**********
RC1004: MOVE.W  D5,-(A7)
        MOVE.L  (A0),-(A7)
        MOVE.W  D6,-(A7)
        CLR.W   D7
        TST.W   (A0)+
        BEQ.S   S1RC14
        MOVEQ   #4,D7
S1RC14: TST.W   (A0)
        BEQ.S   S2RC14
        BSET    #3,D7
S2RC14: MOVE.L  VRC14(PC,D7.W),D3
        MOVE.L  VRC14+16(PC,D7.W),D5
        MOVE.L  VRC14+32(PC,D7.W),D6
        MOVE.L  VRC14+48(PC,D7.W),D7
        CMP.W   D2,D1
        BLE.S   RC1004R
        MOVE.W  D2,D1
        BRA     RC1004L
VRC14:  AND.W   D2,-(A3)
        AND.W   D2,-(A3)
        AND.W   D2,-(A3)
        OR.W    D3,-(A3)
        OR.W    D3,-(A3)
        AND.W   D2,-(A3)
        OR.W    D3,-(A3)
        OR.W    D3,-(A3)
        AND.W   D0,-(A3)
        AND.W   D0,-(A3)
        AND.W   D0,-(A3)
        OR.W    D3,-(A3)
        OR.W    D3,-(A3)
        AND.W   D0,-(A3)
        OR.W    D3,-(A3)
        OR.W    D3,-(A3)
        DC.W    AND2
        DC.W    AND2
        DC.W    AND2
        DC.W    ORD3
        DC.W    ORD3
        DC.W    AND2
        DC.W    ORD3
        DC.W    ORD3

        DC.W    AND0
        DC.W    AND0
        DC.W    AND0
        DC.W    ORD3
        DC.W    ORD3
        DC.W    AND0
        DC.W    ORD3
        DC.W    ORD3
RC1004R:
        MOVE.W  (A7)+,D2
        LEA.L   CR2C(PC),A0
        LSR.B   #1,D2
        BCS.S   CR2P1
        MOVE.W  #$6000+CR2F-CR2A-2,CR2A-CR2C(A0)
        MOVE.W  #$6000+CR2MF-CR2MA-2,CR2MA-CR2C(A0)
        BRA.S   CR2PP1
CR2P1:  MOVE.W  #MWX1D6,CR2A-CR2C(A0)
        MOVE.W  D4,ECR2A0-CR2C+2(A0)
        MOVE.W  #MWX1D6,CR2MA-CR2C(A0)
        MOVE.W  D4,ECR2MA0-CR2C+2(A0)
        MOVE.L  D5,ICR2A0-CR2C(A0)
        MOVE.L  D5,ICR2MA0-CR2C(A0)
        MOVE.W  D7,ICR2MA0-CR2C+8(A0)
        SWAP    D7
        MOVE.W  D7,ICR2MA0-CR2C+4(A0)
        SWAP    D7
        TST.B   D2
        BNE.S   CR2PP1
        OR.L    MSKD2(PC),D0
        MOVE.W  #CR2A-CR2F-6,CR2F-CR2C+6(A0)
        MOVE.W  #CR2MA-CR2MF-10,CR2MF-CR2C+10(A0)
        BRA     CR2PP3
CR2PP1: LSR.B   #1,D2
        BCS.S   CR2P2
        MOVE.W  #$6000+CR2A-CR2B-2,CR2B-CR2C(A0)
        MOVE.W  #$6000+CR2MA-CR2MB-2,CR2MB-CR2C(A0)
        BRA.S   CR2PP2
CR2P2:  MOVE.W  #SWPD7,CR2B-CR2C(A0)
        MOVE.W  D4,ECR2B0-CR2C+2(A0)
        MOVE.W  #SWPD7,CR2MB-CR2C(A0)
        MOVE.W  D4,ECR2MB0-CR2C+2(A0)
        TST.B   D2
        BNE.S   CR2PP2
        MOVE.W  #CR2B-CR2F-6,CR2F-CR2C+6(A0)
        MOVE.W  #CR2MB-CR2MF-10,CR2MF-CR2C+10(A0)
        BRA.S   CR2PP3
CR2PP2: LSR.B   #1,D2
        BCC.S   CR2PPX
        MOVE.W  D4,ECR2C0-CR2C+2(A0)
        MOVE.W  D4,ECR2MC0-CR2C+2(A0)
        MOVE.W  #CR2C-CR2F-6,CR2F-CR2C+6(A0)
        MOVE.W  #CR2MC-CR2MF-10,CR2MF-CR2C+10(A0)
        MOVE.L  D3,ICR2C0-CR2C(A0)
        MOVE.L  D3,ICR2MC0-CR2C(A0)
        MOVE.W  D6,ICR2MC0-CR2C+8(A0)
        SWAP    D6
        MOVE.W  D6,ICR2MC0-CR2C+4(A0)
        SWAP    D6
        BRA.S   CR2PP3
CR2PPX: MOVE.W  D4,ECR2X0-CR2C+2(A0)
        MOVE.W  D4,ECR2MX0-CR2C+2(A0)
        MOVE.W  #CR2X-CR2F-6,CR2F-CR2C+6(A0)
        MOVE.W  #CR2MX-CR2MF-10,CR2MF-CR2C+10(A0)
        MOVE.L  D3,ICR2X0-CR2C(A0)
        MOVE.L  D3,ICR2MX0-CR2C(A0)
        MOVE.W  D6,ICR2MX0-CR2C+8(A0)
        SWAP    D6
        MOVE.W  D6,ICR2MX0-CR2C+4(A0)
        SWAP    D6
CR2PP3:
        MOVE.L  MSKD2(PC),D2
        MOVE.W  (A7)+,D4
        MOVE.W  (A7)+,D5
        MOVE.W  #160,A0
        SUB.W   (A7)+,A0

        MOVE.B  (A4)+,D7
        BEQ     CR2MD-6
CR2D:   EXT.W   D7
        BRA     CR2F+4

CR2C:
ECR2C0: MOVE.L  2(A1),D6
        CLR.W   D6
        LSR.L   D1,D6
        AND.W   D2,-(A3)
        OR.W    D6,(A3)
        MOVE.W  D2,D3
        NOT.W   D3
ICR2C0: OR.W    D2,-(A3)
        AND.W   D3,-(A3)
        MOVE.L  (A1),D3
        CLR.W   D3
        LSR.L   D1,D3
        AND.W   D2,-(A3)
        OR.W    D3,(A3)
        BRA.S   CR2B

CR2X:
ECR2X0: MOVE.L  2(A1),D6
        LSR.L   D1,D6
        AND.W   D2,-(A3)
        OR.W    D6,(A3)
        MOVE.W  D2,D3
        NOT.W   D3
ICR2X0: OR.W    D2,-(A3)
        AND.W   D3,-(A3)
        MOVE.L  (A1),D3
        LSR.L   D1,D3
        AND.W   D2,-(A3)
        OR.W    D3,(A3)

CR2B:   SWAP    D7
        MOVE.W  VD7(PC),D7
CR2B02: SUBQ.W  #2,A1
        MOVE.L  (A1),D3
        LSR.L   D1,D3
ECR2B0: MOVE.L  2(A1),D6
        LSR.L   D1,D6
        MOVEM.W D3-D6,-(A3)
        DBF     D7,CR2B02
        SWAP    D7

CR2A:
ECR2A0: MOVE.W  2(A1),D6
        LSR.W   D1,D6
        AND.W   D0,-(A3)
        OR.W    D6,(A3)
        MOVE.W  D0,D3
        NOT.W   D3
ICR2A0: OR.W    D0,-(A3)
        AND.W   D3,-(A3)
        MOVE.W  (A1),D3
        LSR.W   D1,D3
        AND.W   D0,-(A3)
        OR.W    D3,(A3)

CR2F:   ADD.W   A2,A1
        SUB.W   A0,A3
        DBF     D7,CR2C

        MOVE.B  (A4)+,D7
        BNE.S   CR2MD
        RTS
CR2MD:  EXT.W   D7
        BRA     CR2MF+8  

CR2MC:
ECR2MC0: MOVE.L  2(A1),D6
        CLR.W   D6
        LSR.L   D1,D6
        AND.W   D2,-162(A3)
        OR.W    D6,-162(A3)
        AND.W   D2,-(A3)
        OR.W    D6,(A3)
        MOVE.W  D2,D3
        NOT.W   D3
ICR2MC0:
        OR.W    D3,-(A3)
        AND.W   D2,-(A3)
        OR.W    D3,-158(A3)
        AND.W   D2,-160(A3)
        MOVE.L  (A1),D3
        CLR.W   D3
        LSR.L   D1,D3
        AND.W   D2,-162(A3)
        OR.W    D3,-162(A3)
        AND.W   D2,-(A3)
        OR.W    D3,(A3)
        BRA.S   CR2MB

CR2MX:
ECR2MX0: MOVE.L  2(A1),D6
        LSR.L   D1,D6
        AND.W   D2,-162(A3)
        OR.W    D6,-162(A3)
        AND.W   D2,-(A3)
        OR.W    D6,(A3)
        MOVE.W  D2,D3
        NOT.W   D3
ICR2MX0:
        OR.W    D2,-(A3)
        AND.W   D3,-(A3)
        OR.W    D2,-158(A3)
        AND.W   D3,-160(A3)
        MOVE.L  (A1),D3
        LSR.L   D1,D3
        AND.W   D2,-162(A3)
        OR.W    D3,-162(A3)
        AND.W   D2,-(A3)
        OR.W    D3,(A3)

CR2MB:  SWAP    D7
        MOVE.W  VD7(PC),D7
CR2MB02: SUBQ.W  #2,A1
        MOVE.L  (A1),D3
        LSR.L   D1,D3
ECR2MB0: MOVE.L  2(A1),D6
        LSR.L   D1,D6
        MOVEM.W D3-D6,-(A3)
        MOVEM.W D3-D6,-160(A3)
        DBF     D7,CR2MB02
        SWAP    D7

CR2MA:
ECR2MA0: MOVE.W  2(A1),D6
        LSR.W   D1,D6
        AND.W   D0,-(A3)
        OR.W    D6,(A3)
        AND.W   D0,-160(A3)
        OR.W    D6,-160(A3)
        MOVE.W  D0,D3
        NOT.W   D3
ICR2MA0:
        OR.W    D3,-(A3)
        AND.W   D0,-(A3)
        OR.W    D3,-158(A3)
        AND.W   D0,-160(A3)
        MOVE.W  (A1),D3
        LSR.W   D1,D3
        AND.W   D0,-(A3)
        OR.W    D3,(A3)
        AND.W   D0,-160(A3)
        OR.W    D3,-160(A3)

CR2MF:  ADD.W   A2,A1
        LEA.L   -160(A3),A3
        SUB.W   A0,A3
        DBF     D7,CR2MC
        MOVE.B  (A4)+,D7
        BNE     CR2D
        RTS
**********
RC1004L:
        MOVE.W  (A7)+,D2
        LEA.L   CL2C(PC),A0
        LSR.B   #1,D2
        BCS.S   CL2P1
        MOVE.W  #$6000+CL2F-CL2A-2,CL2A-CL2C(A0)
        MOVE.W  #$6000+CL2MF-CL2MA-2,CL2MA-CL2C(A0)
        BRA.S   CL2PP1
CL2P1:  MOVE.W  #MLX1D6,CL2A-CL2C(A0)
        MOVE.W  D4,ECL2A0-CL2C+2(A0)
        MOVE.W  #MLX1D6,CL2MA-CL2C(A0)
        MOVE.W  D4,ECL2MA0-CL2C+2(A0)
        MOVE.L  D5,ICL2A0-CL2C(A0)
        MOVE.L  D5,ICL2MA0-CL2C(A0)
        MOVE.W  D7,ICL2MA0-CL2C+8(A0)
        SWAP    D7
        MOVE.W  D7,ICL2MA0-CL2C+4(A0)
        SWAP    D7
        TST.B   D2
        BNE.S   CL2PP1
        OR.L    MSKD2(PC),D0
        MOVE.W  #CL2A-CL2F-6,CL2F-CL2C+6(A0)
        MOVE.W  #CL2MA-CL2MF-10,CL2MF-CL2C+10(A0)
        BRA     CL2PP3
CL2PP1: LSR.B   #1,D2
        BCS.S   CL2P2
        MOVE.W  #$6000+CL2A-CL2B-2,CL2B-CL2C(A0)
        MOVE.W  #$6000+CL2MA-CL2MB-2,CL2MB-CL2C(A0)
        BRA.S   CL2PP2
CL2P2:  MOVE.W  #SWPD7,CL2B-CL2C(A0)
        MOVE.W  D4,ECL2B0-CL2C+2(A0)
        MOVE.W  #SWPD7,CL2MB-CL2C(A0)
        MOVE.W  D4,ECL2MB0-CL2C+2(A0)
        TST.B   D2
        BNE.S   CL2PP2
        MOVE.W  #CL2B-CL2F-6,CL2F-CL2C+6(A0)
        MOVE.W  #CL2MB-CL2MF-10,CL2MF-CL2C+10(A0)
        BRA.S   CL2PP3
CL2PP2: LSR.B   #1,D2
        BCC.S   CL2PPX
        MOVE.W  D4,ECL2C0-CL2C+2(A0)
        MOVE.W  D4,ECL2MC0-CL2C+2(A0)
        MOVE.W  #CL2C-CL2F-6,CL2F-CL2C+6(A0)
        MOVE.W  #CL2MC-CL2MF-10,CL2MF-CL2C+10(A0)
        MOVE.L  D3,ICL2C0-CL2C(A0)
        MOVE.L  D3,ICL2MC0-CL2C(A0)
        MOVE.W  D6,ICL2MC0-CL2C+8(A0)
        SWAP    D6
        MOVE.W  D6,ICL2MC0-CL2C+4(A0)
        SWAP    D6
        BRA.S   CL2PP3
CL2PPX: MOVE.W  D4,ECL2X0-CL2C+2(A0)
        MOVE.W  D4,ECL2MX0-CL2C+2(A0)
        MOVE.W  #CL2X-CL2F-6,CL2F-CL2C+6(A0)
        MOVE.W  #CL2MX-CL2MF-10,CL2MF-CL2C+10(A0)
        MOVE.L  D3,ICL2X0-CL2C(A0)
        MOVE.L  D3,ICL2MX0-CL2C(A0)
        MOVE.W  D6,ICL2MX0-CL2C+8(A0)
        SWAP    D6
        MOVE.W  D6,ICL2MX0-CL2C+4(A0)
        SWAP    D6
CL2PP3:
        MOVE.L  MSKD2(PC),D2
        MOVE.W  (A7)+,D4
        MOVE.W  (A7)+,D5
        MOVE.W  #160,A0
        SUB.W   (A7)+,A0

        MOVE.B  (A4)+,D7
        BEQ     CL2MD-6
CL2D:   EXT.W   D7
        BRA     CL2F+4

CL2C:
ECL2C0: MOVE.W  2(A1),D3
        LSL.W   D1,D3
        AND.W   D2,-(A3)
        OR.W    D3,(A3)
        MOVE.W  D2,D3
        NOT.W   D3
ICL2C0: OR.W    D2,-(A3)
        AND.W   D3,-(A3)
        MOVE.W  (A1),D3
        LSL.W   D1,D3
        AND.W   D2,-(A3)
        OR.W    D3,(A3)
        BRA.S   CL2B

CL2X:
ECL2X0: MOVE.L  2(A1),D6
        LSL.L   D1,D6
        SWAP    D6
        AND.W   D2,-(A3)
        OR.W    D6,(A3)
        MOVE.W  D2,D3
        NOT.W   D3
ICL2X0: OR.W    D2,-(A3)
        AND.W   D3,-(A3)
        MOVE.L  (A1),D6
        LSL.L   D1,D6
        SWAP    D6
        AND.W   D2,-(A3)
        OR.W    D6,(A3)

CL2B:   SWAP    D7
        MOVE.W  VD7(PC),D7
CL2B02: SUBQ.W  #2,A1
        MOVE.L  (A1),D3
        LSL.L   D1,D3
        SWAP    D3
ECL2B0: MOVE.L  2(A1),D6
        LSL.L   D1,D6
        SWAP    D6
        MOVEM.W D3-D6,-(A3)
        DBF     D7,CL2B02
        SWAP    D7

CL2A:
ECL2A0: MOVE.L  6(A1),D6
        CLR.W   D6
        ROL.L   D1,D6
        AND.W   D0,-(A3)
        OR.W    D6,(A3)
        MOVE.W  D0,D3
        NOT.W   D3
ICL2A0: OR.W    D0,-(A3)
        AND.W   D3,-(A3)
        MOVE.L  (A1),D6
        CLR.W   D6
        ROL.L   D1,D6
        AND.W   D0,-(A3)
        OR.W    D6,(A3)

CL2F:   ADD.W   A2,A1
        SUB.W   A0,A3
        DBF     D7,CL2C

        MOVE.B  (A4)+,D7
        BNE.S   CL2MD
        RTS
CL2MD:  EXT.W   D7
        BRA     CL2MF+8

CL2MC:
ECL2MC0: MOVE.W  2(A1),D3
        LSL.W   D1,D3
        AND.W   D2,-(A3)
        OR.W    D3,(A3)
        AND.W   D2,-160(A3)
        OR.W    D3,-160(A3)
        MOVE.W  D2,D3
        NOT.W   D3
ICL2MC0: OR.W    D2,-(A3)
        AND.W   D3,-(A3)
        OR.W    D2,-158(A3)
        AND.W   D3,-160(A3)
        MOVE.W  (A1),D3
        LSL.W   D1,D3
        AND.W   D2,-(A3)
        OR.W    D3,(A3)
        AND.W   D2,-160(A3)
        OR.W    D3,-160(A3)
        BRA.S   CL2MB

CL2MX:
ECL2MX0: MOVE.L  2(A1),D6
        LSL.L   D1,D6
        SWAP    D6
        AND.W   D2,-(A3)
        OR.W    D6,(A3)
        AND.W   D2,-160(A3)
        OR.W    D6,-160(A3)
        MOVE.W  D2,D3
        NOT.W   D3
ICL2MX0: OR.W    D2,-(A3)
        AND.W   D3,-(A3)
        OR.W    D2,-158(A3)
        AND.W   D3,-160(A3)
        MOVE.L  (A1),D6
        LSL.L   D1,D6
        SWAP    D6
        AND.W   D2,-(A3)
        OR.W    D6,(A3)
        AND.W   D2,-160(A3)
        OR.W    D6,-160(A3)

CL2MB:  SWAP    D7
        MOVE.W  VD7(PC),D7
CL2MB02: SUBQ.W  #2,A1
        MOVE.L  (A1),D3
        LSL.L   D1,D3
        SWAP    D3
ECL2MB0: MOVE.L  2(A1),D6
        LSL.L   D1,D6
        SWAP    D6
        MOVEM.W D3-D6,-(A3)
        MOVEM.W D3-D6,-160(A3)
        DBF     D7,CL2MB02
        SWAP    D7

CL2MA:
ECL2MA0: MOVE.L  6(A1),D6
        CLR.W   D6
        ROL.L   D1,D6
        AND.W   D0,-(A3)
        OR.W    D6,(A3)
        AND.W   D0,-160(A3)
        OR.W    D6,-160(A3)
        MOVE.W  D0,D3
        NOT.W   D3
ICL2MA0: OR.W    D0,-(A3)
        AND.W   D3,-(A3)
        OR.W    D0,-158(A3)
        AND.W   D3,-160(A3)
        MOVE.L  (A1),D6
        CLR.W   D6
        ROL.L   D1,D6
        AND.W   D0,-(A3)
        OR.W    D6,(A3)
        AND.W   D0,-160(A3)
        OR.W    D6,-160(A3)

CL2MF:  ADD.W   A2,A1
        LEA.L   -160(A3),A3
        SUB.W   A0,A3
        DBF     D7,CL2MC
        MOVE.B  (A4)+,D7
        BNE     CL2D
        RTS
**********
RN1200: 
        MOVE.W  D4,D0
        MOVE.W  D6,D4
        MOVE.L  A5,-(SP)
        MOVE.W  D5,D3
        CLR.W   D7
        MOVE.W  (A0)+,D6
        BEQ.S   S1RN12
        MOVEQ   #4,D7
S1RN12: MOVE.W  D6,A5
        MOVE.W  (A0),D6
        BEQ.S   S2RN12
        BSET    #3,D7
S2RN12: MOVE.L  VRN12(PC,D7.W),D5
        MOVE.L  VRN12+16(PC,D7.W),D7
        CMP.W   D2,D1
        BLE.S   RN1200R
        MOVE.W  D2,D1
        BRA     RN1200L
VRN12:  AND.W   D2,-(A3)
        AND.W   D2,-(A3)
        AND.W   D2,-(A3)
        OR.W    D5,-(A3)
        OR.W    D5,-(A3)
        AND.W   D2,-(A3)
        OR.W    D5,-(A3)
        OR.W    D5,-(A3)
        AND.W   D2,(A3)+
        AND.W   D2,(A3)+
        OR.W    D5,(A3)+
        AND.W   D2,(A3)+
        AND.W   D2,(A3)+
        OR.W    D5,(A3)+
        OR.W    D5,(A3)+
        OR.W    D5,(A3)+
RN1200R:
        LEA.L   R4C(PC),A0
        LSR.B   #1,D4
        BCS.S   R4P1
        MOVE.W  #$6000+R4F-R4A-2,R4A-R4C(A0)
        MOVE.W  #$6000+R4MF-R4MA-2,R4MA-R4C(A0)
        BRA.S   R4PP1
R4P1:   MOVE.W  #MWA1D3,R4A-R4C(A0)
        MOVE.W  D0,ER4A0-R4C+2(A0)
        MOVE.W  #MWA1D3,R4MA-R4C(A0)
        MOVE.W  D0,ER4MA0-R4C+2(A0)
        MOVE.L  D5,CR4A0-R4C(A0)
        MOVE.L  D5,CR4MA0-R4C(A0)
        MOVE.L  D7,CR4MA1-R4C(A0)
        TST.B   D4
        BNE.S   R4PP1
        MOVE.W  #R4A-R4F-6,R4F-R4C+6(A0)
        MOVE.W  #R4MA-R4MF-10,R4MF-R4C+10(A0)
        BRA.S   R4PP3
R4PP1:  LSR.B   #1,D4
        BCS.S   R4P2
        MOVE.W  #$6000+R4A-R4B-2,R4B-R4C(A0)
        MOVE.L  #$60000000+R4MA-R4MB-2,R4MB-R4C(A0)
        BRA.S   R4PP2
R4P2:   MOVE.W  #SWPD7,R4B-R4C(A0)
        MOVE.W  D0,ER4B0-R4C+2(A0)
        MOVE.L  #SWMWD7,R4MB-R4C(A0)
        MOVE.W  D0,ER4MB0-R4C+2(A0)
        MOVE.L  D5,CR4B0-R4C(A0)
        MOVE.L  D5,CR4MB0-R4C(A0)
        MOVE.L  D7,CR4MB1-R4C(A0)
        TST.B   D4
        BNE.S   R4PP2
        MOVE.W  #R4B-R4F-6,R4F-R4C+6(A0)
        MOVE.W  #R4MB-R4MF-10,R4MF-R4C+10(A0)
        BRA.S   R4PP3
R4PP2:  MOVE.W  D0,ER4C0-R4C+2(A0)
        MOVE.W  D0,ER4MC0-R4C+2(A0)
        MOVE.W  #R4C-R4F-6,R4F-R4C+6(A0)
        MOVE.W  #R4MC-R4MF-10,R4MF-R4C+10(A0)
        MOVE.L  D5,CR4C0-R4C(A0)
        MOVE.L  D5,CR4MC0-R4C(A0)
        MOVE.L  D7,CR4MC1-R4C(A0)
R4PP3:
        MOVE.W  #160,A0
        SUB.W   D3,A0
        MOVE.B  (A4)+,D7
        BEQ     R4MD-8
R4D:    EXT.W   D7
        BRA.L   R4F+4

R4C:    MOVE.L  (A1),D3
        CLR.W   D3
        LSR.L   D1,D3
ER4C0:  MOVE.L  2(A1),D4
        CLR.W   D4
        LSR.L   D1,D4

        MOVE.W  D3,D2
        OR.W    D4,D2
        BNE.S   R4C0
        SUBQ.W  #8,A3
        BRA.S   R4B
R4C0:   MOVE.W  D2,D5
        NOT.W   D2
CR4C0:  AND.W   D2,-(A3)
        AND.W   D2,-(A3)
        MOVE.L  -(A3),D0
        AND.W   D2,D0
        OR.W    D4,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D3,D0
        SWAP    D0
        MOVE.L  D0,(A3)

R4B:    SWAP    D7
        MOVE.W  VD7(PC),D7
R4B0:   SUBQ.W  #2,A1
        MOVE.L  (A1),D3
        LSR.L   D1,D3
ER4B0:  MOVE.L  2(A1),D4
        LSR.L   D1,D4

        MOVE.W  D3,D2
        OR.W    D4,D2
        BNE.S   R4B1
        SUBQ.W  #8,A3
        DBF     D7,R4B0
        BRA.S   R4BF+4
R4B1:   MOVE.W  D2,D5
        NOT.W   D2
        BNE.S   R4B2
        MOVE.W  A5,D5
        MOVEM.W D3-D6,-(A3)
        DBF     D7,R4B0
        BRA.S   R4BF+4
R4B2: 
CR4B0:  AND.W   D2,-(A3)        ;OU     OR.W D5,-(A3)
        AND.W   D2,-(A3)   ;  IDEM
        MOVE.L  -(A3),D0
        AND.W   D2,D0
        OR.W    D4,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D3,D0
        SWAP    D0
        MOVE.L  D0,(A3)
R4BF:   DBF     D7,R4B0
        SWAP    D7

R4A:    MOVE.W  (A1),D3
        LSR.W   D1,D3
ER4A0:  MOVE.W  2(A1),D4
        LSR.W   D1,D4

        MOVE.W  D3,D2
        OR.W    D4,D2
        BNE.S   R4A1
        SUBQ.W  #8,A3
        BRA.S   R4F
R4A1:   MOVE.W  D2,D5
        NOT.W   D2
CR4A0:  AND.W   D2,-(A3)        ;OU     OR.W D5,-(A3)
        AND.W   D2,-(A3)   ;  IDEM
        MOVE.L  -(A3),D0
        AND.W   D2,D0
        OR.W    D4,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D3,D0
        SWAP    D0
        MOVE.L  D0,(A3)
R4F:    ADD.W   A2,A1
        SUB.W   A0,A3
        DBF     D7,R4C

        MOVE.B  (A4)+,D7
        BNE.S   R4MD
        MOVE.L  (SP)+,A5
        RTS
R4MD:   EXT.W   D7
        BRA.L   R4MF+8           

R4MC:   MOVE.L  (A1),D3
        CLR.W   D3
        LSR.L   D1,D3
ER4MC0: MOVE.L  2(A1),D4
        CLR.W   D4
        LSR.L   D1,D4

        MOVE.W  D3,D2
        OR.W    D4,D2
        BNE.S   R4MC0
        SUBQ.W  #8,A3
        BRA.S   R4MB
R4MC0:  MOVE.W  D2,D5
        NOT.W   D2
        LEA.L   -168(A3),A3
        MOVE.L  (A3),D0
        AND.W   D2,D0
        OR.W    D4,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D3,D0
        SWAP    D0
        MOVE.L  D0,(A3)+
CR4MC1: AND.W   D2,(A3)+
        AND.W   D2,(A3)+
        LEA.L   160(A3),A3
CR4MC0: AND.W   D2,-(A3)         ;OU    OR.W D5,-(A3)
        AND.W   D2,-(A3)   ;  IDEM
        MOVE.L  -(A3),D0
        AND.W   D2,D0
        OR.W    D4,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D3,D0
        SWAP    D0
        MOVE.L  D0,(A3)
 
R4MB:   SWAP    D7
        MOVE.W  VD7(PC),D7
R4MB0:  SUBQ.W  #2,A1
        MOVE.L  (A1),D3
        LSR.L   D1,D3
ER4MB0: MOVE.L  2(A1),D4
        LSR.L   D1,D4

        MOVE.W  D3,D2
        OR.W    D4,D2
        BNE.S   R4MB1
        SUBQ.W  #8,A3
        DBF     D7,R4MB0
        BRA.S   R4MBF+4
R4MB1:  MOVE.W  D2,D5
        NOT.W   D2
        BNE.S   R4MB2
        MOVE.W  A5,D5
        MOVEM.W D3-D6,-168(A3)
        MOVEM.W D3-D6,-(A3)
        DBF     D7,R4MB0
        BRA.S   R4MBF+4
R4MB2:  LEA.L   -168(A3),A3
        MOVE.L  (A3),D0
        AND.W   D2,D0
        OR.W    D4,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D3,D0
        SWAP    D0
        MOVE.L  D0,(A3)+
CR4MB1: AND.W   D2,(A3)+
        AND.W   D2,(A3)+
        LEA.L   160(A3),A3
CR4MB0: AND.W   D2,-(A3)         ;OU    OR.W D5,-(A3)
        AND.W   D2,-(A3)   ;  IDEM
        MOVE.L  -(A3),D0
        AND.W   D2,D0
        OR.W    D4,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D3,D0
        SWAP    D0
        MOVE.L  D0,(A3)
R4MBF:  DBF     D7,R4MB0
        SWAP    D7

R4MA:   MOVE.W  (A1),D3
        LSR.W   D1,D3
ER4MA0: MOVE.W  2(A1),D4
        LSR.W   D1,D4

        MOVE.W  D3,D2
        OR.W    D4,D2
        BNE.S   R4MA0
        SUBQ.W  #8,A3
        BRA.S   R4MF
R4MA0:  MOVE.W  D2,D5
        NOT.W   D2
        LEA.L   -168(A3),A3
        MOVE.L  (A3),D0
        AND.W   D2,D0
        OR.W    D4,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D3,D0
        SWAP    D0
        MOVE.L  D0,(A3)+
CR4MA1: AND.W   D2,(A3)+
        AND.W   D2,(A3)+
        LEA.L   160(A3),A3
CR4MA0: AND.W   D2,-(A3)         ;OU    OR.W D5,-(A3)
        AND.W   D2,-(A3)   ;  IDEM
        MOVE.L  -(A3),D0
        AND.W   D2,D0
        OR.W    D4,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D3,D0
        SWAP    D0
        MOVE.L  D0,(A3)

R4MF:   ADD.W   A2,A1
        LEA.L   -160(A3),A3
        SUB.W   A0,A3
        DBF     D7,R4MC
        MOVE.B  (A4)+,D7
        BNE     R4D
        MOVE.L  (SP)+,A5
        RTS
*********
RN1200L:
        LEA.L   L4C(PC),A0
        LSR.B   #1,D4
        BCS.S   L4P1
        MOVE.W  #$6000+L4F-L4A-2,L4A-L4C(A0)
        MOVE.W  #$6000+L4MF-L4MA-2,L4MA-L4C(A0)
        BRA.S   L4PP1
L4P1:   MOVE.W  #MLA1D3,L4A-L4C(A0)
        MOVE.W  D0,EL4A0-L4C+2(A0)
        MOVE.W  #MLA1D3,L4MA-L4C(A0)
        MOVE.W  D0,EL4MA0-L4C+2(A0)
        MOVE.L  D5,CL4A0-L4C(A0)
        MOVE.L  D5,CL4MA0-L4C(A0)
        MOVE.L  D7,CL4MA1-L4C(A0)
        TST.B   D4
        BNE.S   L4PP1
        MOVE.W  #L4A-L4F-6,L4F-L4C+6(A0)
        MOVE.W  #L4MA-L4MF-10,L4MF-L4C+10(A0)
        BRA.S   L4PP3
L4PP1:  LSR.B   #1,D4
        BCS.S   L4P2
        MOVE.W  #$6000+L4A-L4B-2,L4B-L4C(A0)
        MOVE.L  #$60000000+L4MA-L4MB-2,L4MB-L4C(A0)
        BRA.S   L4PP2
L4P2:   MOVE.W  #SWPD7,L4B-L4C(A0)
        MOVE.W  D0,EL4B0-L4C+2(A0)
        MOVE.L  #SWMWD7,L4MB-L4C(A0)
        MOVE.W  D0,EL4MB0-L4C+2(A0)
        MOVE.L  D5,CL4B0-L4C(A0)
        MOVE.L  D5,CL4MB0-L4C(A0)
        MOVE.L  D7,CL4MB1-L4C(A0)
        TST.B   D4
        BNE.S   L4PP2
        MOVE.W  #L4B-L4F-6,L4F-L4C+6(A0)
        MOVE.W  #L4MB-L4MF-10,L4MF-L4C+10(A0)
        BRA.S   L4PP3
L4PP2:  MOVE.W  D0,EL4C0-L4C+2(A0)
        MOVE.W  D0,EL4MC0-L4C+2(A0)
        MOVE.W  #L4C-L4F-6,L4F-L4C+6(A0)
        MOVE.W  #L4MC-L4MF-10,L4MF-L4C+10(A0)
        MOVE.L  D5,CL4C0-L4C(A0)
        MOVE.L  D5,CL4MC0-L4C(A0)
        MOVE.L  D7,CL4MC1-L4C(A0)
L4PP3:
        MOVE.W  #160,A0
        SUB.W   D3,A0
        MOVE.B  (A4)+,D7
        BEQ     L4MD-8
L4D:    EXT.W   D7
        BRA.L   L4F+4

L4C:    MOVE.W  (A1),D3
        LSL.W   D1,D3
EL4C0:  MOVE.W  2(A1),D4
        LSL.W   D1,D4

        MOVE.W  D3,D2
        OR.W    D4,D2
        BNE.S   L4C0
        SUBQ.W  #8,A3
        BRA.S   L4B
L4C0:   MOVE.W  D2,D5
        NOT.W   D2
CL4C0:  AND.W   D2,-(A3)        ;OU     OR.W D5,-(A3)
        AND.W   D2,-(A3)   ;  IDEM
        MOVE.L  -(A3),D0
        AND.W   D2,D0
        OR.W    D4,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D3,D0
        SWAP    D0
        MOVE.L  D0,(A3)
 
L4B:    SWAP    D7
        MOVE.W  VD7(PC),D7
L4B0:   SUBQ.W  #2,A1
        MOVE.L  (A1),D3
        LSL.L   D1,D3
        SWAP    D3
EL4B0:  MOVE.L  2(A1),D4
        LSL.L   D1,D4
        SWAP    D4

        MOVE.W  D3,D2
        OR.W    D4,D2
        BNE.S   L4B1
        SUBQ.W  #8,A3
        DBF     D7,L4B0
        BRA.S   L4BF+4
L4B1:   MOVE.W  D2,D5
        NOT.W   D2
        BNE.S   L4B2
        MOVE.W  A5,D5
        MOVEM.W D3-D6,-(A3)
        DBF     D7,L4B0
        BRA.S   L4BF+4
L4B2:
CL4B0:  AND.W   D2,-(A3)        ;OU     OR.W D5,-(A3)
        AND.W   D2,-(A3)   ;  IDEM
        MOVE.L  -(A3),D0
        AND.W   D2,D0
        OR.W    D4,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D3,D0
        SWAP    D0
        MOVE.L  D0,(A3)

L4BF:   DBF     D7,L4B0
        SWAP    D7

L4A:    MOVE.L  (A1),D3
        CLR.W   D3
        ROL.L   D1,D3
EL4A0:  MOVE.L  2(A1),D4
        CLR.W   D4
        ROL.L   D1,D4

        MOVE.W  D3,D2
        OR.W    D4,D2
        BNE.S   L4A1
        SUBQ.W  #8,A3
        BRA.S   L4F
L4A1:   MOVE.W  D2,D5
        NOT.W   D2
CL4A0:  AND.W   D2,-(A3)        ;OU     OR.W D5,-(A3)
        AND.W   D2,-(A3)   ;  IDEM
        MOVE.L  -(A3),D0
        AND.W   D2,D0
        OR.W    D4,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D3,D0
        SWAP    D0
        MOVE.L  D0,(A3)

L4F:    ADD.W   A2,A1
        SUB.W   A0,A3
        DBF     D7,L4C

        MOVE.B  (A4)+,D7
        BNE.S   L4MD
        MOVE.L  (SP)+,A5
        RTS
L4MD:   EXT.W   D7
        BRA.L   L4MF+8           

L4MC:   MOVE.W  (A1),D3
        LSL.W   D1,D3
EL4MC0: MOVE.W  2(A1),D4
        LSL.W   D1,D4

        MOVE.W  D3,D2
        OR.W    D4,D2
        BNE.S   L4MC0
        SUBQ.W  #8,A3
        BRA.S   L4MB
L4MC0:  MOVE.W  D2,D5
        NOT.W   D2
        LEA.L   -168(A3),A3
        MOVE.L  (A3),D0
        AND.W   D2,D0
        OR.W    D4,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D3,D0
        SWAP    D0
        MOVE.L  D0,(A3)+
CL4MC1: AND.W   D2,(A3)+
        AND.W   D2,(A3)+
        LEA.L   160(A3),A3
CL4MC0: AND.W   D2,-(A3)         ;OU    OR.W D5,-(A3)
        AND.W   D2,-(A3)   ;  IDEM
        MOVE.L  -(A3),D0
        AND.W   D2,D0
        OR.W    D4,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D3,D0
        SWAP    D0
        MOVE.L  D0,(A3)
 
L4MB:   SWAP    D7
        MOVE.W  VD7(PC),D7
L4MB0:  SUBQ.W  #2,A1
        MOVE.L  (A1),D3
        LSL.L   D1,D3
        SWAP    D3
EL4MB0: MOVE.L  2(A1),D4
        LSL.L   D1,D4
        SWAP    D4

        MOVE.W  D3,D2
        OR.W    D4,D2
        BNE.S   L4MB1
        SUBQ.W  #8,A3
        DBF     D7,L4MB0
        BRA.S   L4MBF+4
L4MB1:  MOVE.W  D2,D5
        NOT.W   D2
        BNE.S   L4MB2
        MOVE.W  A5,D5
        MOVEM.W D3-D6,-168(A3)
        MOVEM.W D3-D6,-(A3)
        DBF     D7,L4MB0
        BRA.S   L4MBF+4
L4MB2:  LEA.L   -168(A3),A3
        MOVE.L  (A3),D0
        AND.W   D2,D0
        OR.W    D4,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D3,D0
        SWAP    D0
        MOVE.L  D0,(A3)+
CL4MB1: AND.W   D2,(A3)+
        AND.W   D2,(A3)+
        LEA.L   160(A3),A3
CL4MB0: AND.W   D2,-(A3)         ;OU    OR.W D5,-(A3)
        AND.W   D2,-(A3)   ;  IDEM
        MOVE.L  -(A3),D0
        AND.W   D2,D0
        OR.W    D4,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D3,D0
        SWAP    D0
        MOVE.L  D0,(A3)
L4MBF:  DBF     D7,L4MB0
        SWAP    D7

L4MA:   MOVE.L  (A1),D3
        CLR.W   D3
        ROL.L   D1,D3
EL4MA0: MOVE.L  2(A1),D4
        CLR.W   D4
        ROL.L   D1,D4

        MOVE.W  D3,D2
        OR.W    D4,D2
        BNE.S   L4MA0
        SUBQ.W  #8,A3
        BRA.S   L4MF
L4MA0:  MOVE.W  D2,D5
        NOT.W   D2
        LEA.L   -168(A3),A3
        MOVE.L  (A3),D0
        AND.W   D2,D0
        OR.W    D4,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D3,D0
        SWAP    D0
        MOVE.L  D0,(A3)+
CL4MA1: AND.W   D2,(A3)+
        AND.W   D2,(A3)+
        LEA.L   160(A3),A3
CL4MA0: AND.W   D2,-(A3)         ;OU    OR.W D5,-(A3)
        AND.W   D2,-(A3)   ;  IDEM
        MOVE.L  -(A3),D0
        AND.W   D2,D0
        OR.W    D4,D0
        SWAP    D0
        AND.W   D2,D0
        OR.W    D3,D0
        SWAP    D0
        MOVE.L  D0,(A3)

L4MF:   ADD.W   A2,A1
        LEA.L   -160(A3),A3
        SUB.W   A0,A3
        DBF     D7,L4MC
        MOVE.B  (A4)+,D7
        BNE     L4D
        MOVE.L  (SP)+,A5
        RTS
**********
RM1204: 
;control pour chgt coul voit
        MOVE.W  nolog(pc),D0
        CMP.W   #4,D0
        BLT     RM1034
        CMP.W   #5,D0
        BLE.S   AFVOV
        ADD.W   D4,D4
        BRA     RM1004
AFVOV:
        MOVE.W  D4,D0
        MOVE.W  D0,D3
        ADD.W   D3,D3
        MOVE.W  D6,D4
        MOVE.L  A5,-(SP)
        MOVE.W  D5,-(A7)
        CLR.W   D7
        MOVE.W  (A0),D6
        BEQ.S   S1RM124
        MOVEQ   #2,D7
S1RM124: MOVE.W  D6,A5
        MOVE.W  VRM124(PC,D7.W),D5
        MOVE.W  VRM124+4(PC,D7.W),D7
        CMP.W   D2,D1
        BLE.S   RM1204R
        MOVE.W  D2,D1
        BRA     RM1204L
VRM124: AND.W   D2,-(A3)
        OR.W    D5,-(A3)
        AND.W   D2,(A3)+
        OR.W    D5,(A3)+
RM1204R:
        LEA.L   R5C(PC),A0
        LSR.B   #1,D4
        BCS.S   R5P1
        MOVE.W  #$6000+R5F-R5A-2,R5A-R5C(A0)
        MOVE.W  #$6000+R5MF-R5MA-2,R5MA-R5C(A0)
        BRA.S   R5PP1
R5P1:   MOVE.W  #MWA1D3,R5A-R5C(A0)
        MOVE.W  D0,ER5A0-R5C+2(A0)
        MOVE.W  D3,ER5A1-R5C+2(A0)
        MOVE.W  #MWA1D3,R5MA-R5C(A0)
        MOVE.W  D0,ER5MA0-R5C+2(A0)
        MOVE.W  D3,ER5MA1-R5C+2(A0)
        MOVE.W  D5,CR5A0-R5C(A0)
        MOVE.W  D5,CR5MA0-R5C(A0)
        MOVE.W  D7,CR5MA1-R5C(A0)
        TST.B   D4
        BNE.S   R5PP1
        MOVE.W  #R5A-R5F-6,R5F-R5C+6(A0)
        MOVE.W  #R5MA-R5MF-10,R5MF-R5C+10(A0)
        BRA.S   R5PP3
R5PP1:  LSR.B   #1,D4
        BCS.S   R5P2
        MOVE.W  #$6000+R5A-R5B-2,R5B-R5C(A0)
        MOVE.L  #$60000000+R5MA-R5MB-2,R5MB-R5C(A0)
        BRA.S   R5PP2
R5P2:   MOVE.W  #SWPD7,R5B-R5C(A0)
        MOVE.W  D0,ER5B0-R5C+2(A0)
        MOVE.W  D3,ER5B1-R5C+2(A0)
        MOVE.L  #SWMWD7,R5MB-R5C(A0)
        MOVE.W  D0,ER5MB0-R5C+2(A0)
        MOVE.W  D3,ER5MB1-R5C+2(A0)
        MOVE.W  D5,CR5B0-R5C(A0)
        MOVE.W  D5,CR5MB0-R5C(A0)
        MOVE.W  D7,CR5MB1-R5C(A0)
        TST.B   D4
        BNE.S   R5PP2
        MOVE.W  #R5B-R5F-6,R5F-R5C+6(A0)
        MOVE.W  #R5MB-R5MF-10,R5MF-R5C+10(A0)
        BRA.S   R5PP3
R5PP2:  MOVE.W  D0,ER5C0-R5C+2(A0)
        MOVE.W  D3,ER5C1-R5C+2(A0)
        MOVE.W  D0,ER5MC0-R5C+2(A0)
        MOVE.W  D3,ER5MC1-R5C+2(A0)
        MOVE.W  #R5C-R5F-6,R5F-R5C+6(A0)
        MOVE.W  #R5MC-R5MF-10,R5MF-R5C+10(A0)
        MOVE.W  D5,CR5C0-R5C(A0)
        MOVE.W  D5,CR5MC0-R5C(A0)
        MOVE.W  D7,CR5MC1-R5C(A0)
R5PP3:
        MOVE.W  #160,A0
        SUB.W   (A7)+,A0
        MOVE.B  (A4)+,D7
        BEQ     R5MD-8
R5D:    EXT.W   D7
        BRA.L   R5F+4

R5C:    MOVE.L  (A1),D3
        CLR.W   D3
        LSR.L   D1,D3
ER5C0:  MOVE.L  2(A1),D4
        CLR.W   D4
        LSR.L   D1,D4
ER5C1:  MOVE.L  2(A1),D6
        CLR.W   D6
        LSR.L   D1,D6

        MOVE.W  D3,D2
        OR.W    D4,D2
        OR.W    D6,D2
        BNE.S   R5C0
        SUBQ.W  #8,A3
        BRA.S   R5B
R5C0:   MOVE.W  D2,D5
        NOT.W   D2
        OR.W    D5,-(A3)
        EOR.W   D6,(A3)
CR5C0:  AND.W   D2,-(A3)
        MOVE.L  -(A3),D0
        OR.W    D5,D0
        EOR.W   D4,D0
        SWAP    D0
        OR.W    D5,D0
        EOR.W   D3,D0
        SWAP    D0
        MOVE.L  D0,(A3)

R5B:    SWAP    D7
        MOVE.W  VD7(PC),D7
R5B0:   SUBQ.W  #2,A1
        MOVE.L  (A1),D3
        LSR.L   D1,D3
ER5B0:  MOVE.L  2(A1),D4
        LSR.L   D1,D4
ER5B1:  MOVE.L  2(A1),D6
        LSR.L   D1,D6

        MOVE.W  D3,D2
        OR.W    D4,D2
        OR.W    D6,D2
        BNE.S   R5B1
        SUBQ.W  #8,A3
        DBF     D7,R5B0
        BRA.S   R5BF+4
R5B1:   MOVE.W  D2,D5
        NOT.W   D2
        BNE.S   R5B2
        MOVE.W  A5,D5
        NOT.W   D3
        NOT.W   D4
        NOT.W   D6
        MOVEM.W D3-D6,-(A3)
        DBF     D7,R5B0
        BRA.S   R5BF+4
R5B2:   OR.W    D5,-(A3)
        EOR.W   D6,(A3)
CR5B0:  AND.W   D2,-(A3)        ;OU     OR.W D5,-(A3)
        MOVE.L  -(A3),D0
        OR.W    D5,D0
        EOR.W   D4,D0
        SWAP    D0
        OR.W    D5,D0
        EOR.W   D3,D0
        SWAP    D0
        MOVE.L  D0,(A3)
R5BF:   DBF     D7,R5B0
        SWAP    D7

R5A:    MOVE.W  (A1),D3
        LSR.W   D1,D3
ER5A0:  MOVE.W  2(A1),D4
        LSR.W   D1,D4
ER5A1:  MOVE.W  2(A1),D6
        LSR.W   D1,D6

        MOVE.W  D3,D2
        OR.W    D4,D2
        OR.W    D6,D2
        BNE.S   R5A1
        SUBQ.W  #8,A3
        BRA.S   R5F
R5A1:   MOVE.W  D2,D5
        NOT.W   D2
        OR.W    D5,-(A3)
        EOR.W   D6,(A3)
CR5A0:  AND.W   D2,-(A3)        ;OU     OR.W D5,-(A3)
        MOVE.L  -(A3),D0
        OR.W    D5,D0
        EOR.W   D4,D0
        SWAP    D0
        OR.W    D5,D0
        EOR.W   D3,D0
        SWAP    D0
        MOVE.L  D0,(A3)
R5F:    ADD.W   A2,A1
        SUB.W   A0,A3
        DBF     D7,R5C

        MOVE.B  (A4)+,D7
        BNE.S   R5MD
        MOVE.L  (SP)+,A5
        RTS
R5MD:   EXT.W   D7
        BRA.L   R5MF+8           

R5MC:   MOVE.L  (A1),D3
        CLR.W   D3
        LSR.L   D1,D3
ER5MC0: MOVE.L  2(A1),D4
        CLR.W   D4
        LSR.L   D1,D4
ER5MC1: MOVE.L  2(A1),D6
        CLR.W   D6
        LSR.L   D1,D6

        MOVE.W  D3,D2
        OR.W    D4,D2
        OR.W    D6,D2
        BNE.S   R5MC0
        SUBQ.W  #8,A3
        BRA.S   R5MB
R5MC0:  MOVE.W  D2,D5
        NOT.W   D2
        LEA.L   -168(A3),A3
        MOVE.L  (A3),D0
        OR.W    D5,D0
        EOR.W   D4,D0
        SWAP    D0
        OR.W    D5,D0
        EOR.W   D3,D0
        SWAP    D0
        MOVE.L  D0,(A3)+
CR5MC1: AND.W   D2,(A3)+
        OR.W    D5,(A3)
        EOR.W   D6,(A3)+
        LEA.L   158(A3),A3
        OR.W    D5,(A3)
        EOR.W   D6,(A3)
CR5MC0: AND.W   D2,-(A3)         ;OU    OR.W D5,-(A3)
        MOVE.L  -(A3),D0
        OR.W    D5,D0
        EOR.W   D4,D0
        SWAP    D0
        OR.W    D5,D0
        EOR.W   D3,D0
        SWAP    D0
        MOVE.L  D0,(A3)
 
R5MB:   SWAP    D7
        MOVE.W  VD7(PC),D7
R5MB0:  SUBQ.W  #2,A1
        MOVE.L  (A1),D3
        LSR.L   D1,D3
ER5MB0: MOVE.L  2(A1),D4
        LSR.L   D1,D4
ER5MB1: MOVE.L  2(A1),D6
        LSR.L   D1,D6

        MOVE.W  D3,D2
        OR.W    D4,D2
        OR.W    D6,D2
        BNE.S   R5MB1
        SUBQ.W  #8,A3
        DBF     D7,R5MB0
        BRA.S   R5MBF+4
R5MB1:  MOVE.W  D2,D5
        NOT.W   D2
        BNE.S   R5MB2
        MOVE.W  A5,D5
        NOT.W   D3
        NOT.W   D4
        NOT.W   D6
        MOVEM.W D3-D6,-168(A3)
        MOVEM.W D3-D6,-(A3)
        DBF     D7,R5MB0
        BRA.S   R5MBF+4
R5MB2:  LEA.L   -168(A3),A3
        MOVE.L  (A3),D0
        OR.W    D5,D0
        EOR.W   D4,D0
        SWAP    D0
        OR.W    D5,D0
        EOR.W   D3,D0
        SWAP    D0
        MOVE.L  D0,(A3)+
CR5MB1: AND.W   D2,(A3)+
        OR.W    D5,(A3)
        EOR.W   D6,(A3)+
        LEA.L   158(A3),A3
        OR.W    D5,(A3)
        EOR.W   D6,(A3)
CR5MB0: AND.W   D2,-(A3)         ;OU    OR.W D5,-(A3)
        MOVE.L  -(A3),D0
        OR.W    D5,D0
        EOR.W   D4,D0
        SWAP    D0
        OR.W    D5,D0
        EOR.W   D3,D0
        SWAP    D0
        MOVE.L  D0,(A3)
R5MBF:  DBF     D7,R5MB0
        SWAP    D7

R5MA:   MOVE.W  (A1),D3
        LSR.W   D1,D3
ER5MA0: MOVE.W  2(A1),D4
        LSR.W   D1,D4
ER5MA1: MOVE.W  2(A1),D6
        LSR.W   D1,D6

        MOVE.W  D3,D2
        OR.W    D4,D2
        OR.W    D6,D2
        BNE.S   R5MA0
        SUBQ.W  #8,A3
        BRA.S   R5MF
R5MA0:  MOVE.W  D2,D5
        NOT.W   D2
        LEA.L   -168(A3),A3
        MOVE.L  (A3),D0
        OR.W    D5,D0
        EOR.W   D4,D0
        SWAP    D0
        OR.W    D5,D0
        EOR.W   D3,D0
        SWAP    D0
        MOVE.L  D0,(A3)+
CR5MA1: AND.W   D2,(A3)+
        OR.W    D5,(A3)
        EOR.W   D6,(A3)+
        LEA.L   158(A3),A3
        OR.W    D5,(A3)
        EOR.W   D6,(A3)
CR5MA0: AND.W   D2,-(A3)         ;OU    OR.W D5,-(A3)
        MOVE.L  -(A3),D0
        OR.W    D5,D0
        EOR.W   D4,D0
        SWAP    D0
        OR.W    D5,D0
        EOR.W   D3,D0
        SWAP    D0
        MOVE.L  D0,(A3)

R5MF:   ADD.W   A2,A1
        LEA.L   -160(A3),A3
        SUB.W   A0,A3
        DBF     D7,R5MC
        MOVE.B  (A4)+,D7
        BNE     R5D
        MOVE.L  (SP)+,A5
        RTS
*********
RM1204L:
        LEA.L   L5C(PC),A0
        LSR.B   #1,D4
        BCS.S   L5P1
        MOVE.W  #$6000+L5F-L5A-2,L5A-L5C(A0)
        MOVE.W  #$6000+L5MF-L5MA-2,L5MA-L5C(A0)
        BRA.S   L5PP1
L5P1:   MOVE.W  #MLA1D3,L5A-L5C(A0)
        MOVE.W  D0,EL5A0-L5C+2(A0)
        MOVE.W  D3,EL5A1-L5C+2(A0)
        MOVE.W  #MLA1D3,L5MA-L5C(A0)
        MOVE.W  D0,EL5MA0-L5C+2(A0)
        MOVE.W  D3,EL5MA1-L5C+2(A0)
        MOVE.W  D5,CL5A0-L5C(A0)
        MOVE.W  D5,CL5MA0-L5C(A0)
        MOVE.W  D7,CL5MA1-L5C(A0)
        TST.B   D4
        BNE.S   L5PP1
        MOVE.W  #L5A-L5F-6,L5F-L5C+6(A0)
        MOVE.W  #L5MA-L5MF-10,L5MF-L5C+10(A0)
        BRA.S   L5PP3
L5PP1:  LSR.B   #1,D4
        BCS.S   L5P2
        MOVE.W  #$6000+L5A-L5B-2,L5B-L5C(A0)
        MOVE.L  #$60000000+L5MA-L5MB-2,L5MB-L5C(A0)
        BRA.S   L5PP2
L5P2:   MOVE.W  #SWPD7,L5B-L5C(A0)
        MOVE.W  D0,EL5B0-L5C+2(A0)
        MOVE.W  D3,EL5B1-L5C+2(A0)
        MOVE.L  #SWMWD7,L5MB-L5C(A0)
        MOVE.W  D0,EL5MB0-L5C+2(A0)
        MOVE.W  D3,EL5MB1-L5C+2(A0)
        MOVE.W  D5,CL5B0-L5C(A0)
        MOVE.W  D5,CL5MB0-L5C(A0)
        MOVE.W  D7,CL5MB1-L5C(A0)
        TST.B   D4
        BNE.S   L5PP2
        MOVE.W  #L5B-L5F-6,L5F-L5C+6(A0)
        MOVE.W  #L5MB-L5MF-10,L5MF-L5C+10(A0)
        BRA.S   L5PP3
L5PP2:  MOVE.W  D0,EL5C0-L5C+2(A0)
        MOVE.W  D3,EL5C1-L5C+2(A0)
        MOVE.W  D0,EL5MC0-L5C+2(A0)
        MOVE.W  D3,EL5MC1-L5C+2(A0)
        MOVE.W  #L5C-L5F-6,L5F-L5C+6(A0)
        MOVE.W  #L5MC-L5MF-10,L5MF-L5C+10(A0)
        MOVE.W  D5,CL5C0-L5C(A0)
        MOVE.W  D5,CL5MC0-L5C(A0)
        MOVE.W  D7,CL5MC1-L5C(A0)
L5PP3:
        MOVE.W  #160,A0
        SUB.W   (A7)+,A0
        MOVE.B  (A4)+,D7
        BEQ     L5MD-8
L5D:    EXT.W   D7
        BRA.L   L5F+4

L5C:    MOVE.W  (A1),D3
        LSL.W   D1,D3
EL5C0:  MOVE.W  2(A1),D4
        LSL.W   D1,D4
EL5C1:  MOVE.W  2(A1),D6
        LSL.W   D1,D6

        MOVE.W  D3,D2
        OR.W    D4,D2
        OR.W    D6,D2
        BNE.S   L5C0
        SUBQ.W  #8,A3
        BRA.S   L5B
L5C0:   MOVE.W  D2,D5
        NOT.W   D2
        OR.W    D5,-(A3)
        EOR.W   D6,(A3)
CL5C0:  AND.W   D2,-(A3)        ;OU     OR.W D5,-(A3)
        MOVE.L  -(A3),D0
        OR.W    D5,D0
        EOR.W   D4,D0
        SWAP    D0
        OR.W    D5,D0
        EOR.W   D3,D0
        SWAP    D0
        MOVE.L  D0,(A3)
 
L5B:    SWAP    D7
        MOVE.W  VD7(PC),D7
L5B0:   SUBQ.W  #2,A1
        MOVE.L  (A1),D3
        LSL.L   D1,D3
        SWAP    D3
EL5B0:  MOVE.L  2(A1),D4
        LSL.L   D1,D4
        SWAP    D4
EL5B1:  MOVE.L  2(A1),D6
        LSL.L   D1,D6
        SWAP    D6

        MOVE.W  D3,D2
        OR.W    D4,D2
        OR.W    D6,D2
        BNE.S   L5B1
        SUBQ.W  #8,A3
        DBF     D7,L5B0
        BRA.S   L5BF+4
L5B1:   MOVE.W  D2,D5
        NOT.W   D2
        BNE.S   L5B2
        MOVE.W  A5,D5
        NOT.W   D3
        NOT.W   D4
        NOT.W   D6
        MOVEM.W D3-D6,-(A3)
        DBF     D7,L5B0
        BRA.S   L5BF+4
L5B2:   OR.W    D5,-(A3)
        EOR.W   D6,(A3)
CL5B0:  OR.W    D5,-(A3)   ;OU  OR.W D5,-(A3)
        MOVE.L  -(A3),D0
        OR.W    D5,D0
        EOR.W   D4,D0
        SWAP    D0
        OR.W    D5,D0
        EOR.W   D3,D0
        SWAP    D0
        MOVE.L  D0,(A3)

L5BF:   DBF     D7,L5B0
        SWAP    D7

L5A:    MOVE.L  (A1),D3
        CLR.W   D3
        ROL.L   D1,D3
EL5A0:  MOVE.L  2(A1),D4
        CLR.W   D4
        ROL.L   D1,D4
EL5A1:  MOVE.L  2(A1),D6
        CLR.W   D6
        ROL.L   D1,D6

        MOVE.W  D3,D2
        OR.W    D4,D2
        OR.W    D6,D2
        BNE.S   L5A1
        SUBQ.W  #8,A3
        BRA.S   L5F
L5A1:   MOVE.W  D2,D5
        NOT.W   D2
        OR.W    D5,-(A3)
        EOR.W   D6,(A3)
CL5A0:  OR.W    D5,-(A3)   ;OU  OR.W D5,-(A3)
        MOVE.L  -(A3),D0
        OR.W    D5,D0
        EOR.W   D4,D0
        SWAP    D0
        OR.W    D5,D0
        EOR.W   D3,D0
        SWAP    D0
        MOVE.L  D0,(A3)

L5F:    ADD.W   A2,A1
        SUB.W   A0,A3
        DBF     D7,L5C

        MOVE.B  (A4)+,D7
        BNE.S   L5MD
        MOVE.L  (SP)+,A5
        RTS
L5MD:   EXT.W   D7
        BRA.L   L5MF+8           

L5MC:   MOVE.W  (A1),D3
        LSL.W   D1,D3
EL5MC0: MOVE.W  2(A1),D4
        LSL.W   D1,D4
EL5MC1: MOVE.W  2(A1),D6
        LSL.W   D1,D6

        MOVE.W  D3,D2
        OR.W    D4,D2
        OR.W    D6,D2
        BNE.S   L5MC0
        SUBQ.W  #8,A3
        BRA.S   L5MB
L5MC0:  MOVE.W  D2,D5
        NOT.W   D2
        LEA.L   -168(A3),A3
        MOVE.L  (A3),D0
        OR.W    D5,D0
        EOR.W   D4,D0
        SWAP    D0
        OR.W    D5,D0
        EOR.W   D3,D0
        SWAP    D0
        MOVE.L  D0,(A3)+
CL5MC1: OR.W    D5,(A3)+
        OR.W    D5,(A3)
        EOR.W   D6,(A3)+
        LEA.L   158(A3),A3
        OR.W    D5,(A3)
        EOR.W   D6,(A3)
CL5MC0: OR.W    D5,-(A3)        ;OU     OR.W D5,-(A3)
        MOVE.L  -(A3),D0
        OR.W    D5,D0
        EOR.W   D4,D0
        SWAP    D0
        OR.W    D5,D0
        EOR.W   D3,D0
        SWAP    D0
        MOVE.L  D0,(A3)
 
L5MB:   SWAP    D7
        MOVE.W  VD7(PC),D7
L5MB0:  SUBQ.W  #2,A1
        MOVE.L  (A1),D3
        LSL.L   D1,D3
        SWAP    D3
EL5MB0: MOVE.L  2(A1),D4
        LSL.L   D1,D4
        SWAP    D4
EL5MB1: MOVE.L  2(A1),D6
        LSL.L   D1,D6
        SWAP    D6

        MOVE.W  D3,D2
        OR.W    D4,D2
        OR.W    D6,D2
        BNE.S   L5MB1
        SUBQ.W  #8,A3
        DBF     D7,L5MB0
        BRA.S   L5MBF+4
L5MB1:  MOVE.W  D2,D5
        NOT.W   D2
        BNE.S   L5MB2
        MOVE.W  A5,D5
        NOT.W   D3
        NOT.W   D4
        NOT.W   D6
        MOVEM.W D3-D6,-168(A3)
        MOVEM.W D3-D6,-(A3)
        DBF     D7,L5MB0
        BRA.S   L5MBF+4
L5MB2:  LEA.L   -168(A3),A3
        MOVE.L  (A3),D0
        OR.W    D5,D0
        EOR.W   D4,D0
        SWAP    D0
        OR.W    D5,D0
        EOR.W   D3,D0
        SWAP    D0
        MOVE.L  D0,(A3)+
CL5MB1: OR.W    D5,(A3)+
        OR.W    D5,(A3)
        EOR.W   D6,(A3)+
        LEA.L   158(A3),A3
        OR.W    D5,(A3)
        EOR.W   D6,(A3)
CL5MB0: OR.W    D5,-(A3)        ;OU     OR.W D5,-(A3)
        MOVE.L  -(A3),D0
        OR.W    D5,D0
        EOR.W   D4,D0
        SWAP    D0
        OR.W    D5,D0
        EOR.W   D3,D0
        SWAP    D0
        MOVE.L  D0,(A3)
L5MBF:  DBF     D7,L5MB0
        SWAP    D7

L5MA:   MOVE.L  (A1),D3
        CLR.W   D3
        ROL.L   D1,D3
EL5MA0: MOVE.L  2(A1),D4
        CLR.W   D4
        ROL.L   D1,D4
EL5MA1: MOVE.L  2(A1),D6
        CLR.W   D6
        ROL.L   D1,D6

        MOVE.W  D3,D2
        OR.W    D4,D2
        OR.W    D6,D2
        BNE.S   L5MA0
        SUBQ.W  #8,A3
        BRA.S   L5MF
L5MA0:  MOVE.W  D2,D5
        NOT.W   D2
        LEA.L   -168(A3),A3
        MOVE.L  (A3),D0
        OR.W    D5,D0
        EOR.W   D4,D0
        SWAP    D0
        OR.W    D5,D0
        EOR.W   D3,D0
        SWAP    D0
        MOVE.L  D0,(A3)+
CL5MA1: OR.W    D5,(A3)+
        OR.W    D5,(A3)
        EOR.W   D6,(A3)+
        LEA.L   158(A3),A3
        OR.W    D5,(A3)
        EOR.W   D6,(A3)
CL5MA0: OR.W    D5,-(A3)        ;OU     OR.W D5,-(A3)
        MOVE.L  -(A3),D0
        OR.W    D5,D0
        EOR.W   D4,D0
        SWAP    D0
        OR.W    D5,D0
        EOR.W   D3,D0
        SWAP    D0
        MOVE.L  D0,(A3)

L5MF:   ADD.W   A2,A1
        LEA.L   -160(A3),A3
        SUB.W   A0,A3
        DBF     D7,L5MC
        MOVE.B  (A4)+,D7
        BNE     L5D
        MOVE.L  (SP)+,A5
        RTS
**********
RM1034: 
        MOVE.W  D4,D0
        MOVE.W  D0,D3
        ADD.W   D3,D3
        MOVE.L  A5,-(SP)
        MOVE.W  D5,-(A7)
        CLR.W   D7
        MOVE.W  (A0),D4
        BEQ.S   S1RM134
        MOVEQ   #2,D7
S1RM134: MOVE.W  D4,A5
        MOVE.W  VRM134(PC,D7.W),D4
        MOVE.W  VRM134+4(PC,D7.W),D7
        CMP.W   D2,D1
        BLE.S   RM1034R
        MOVE.W  D2,D1
        BRA     RM1034L
VRM134: AND.W   D2,-(A3)
        OR.W    D4,-(A3)
        AND.W   D2,(A3)+
        OR.W    D4,(A3)+
RM1034R:
        LEA.L   R6C(PC),A0
        LSR.B   #1,D6
        BCS.S   R6P1
        MOVE.W  #$6000+R6F-R6A-2,R6A-R6C(A0)
        MOVE.W  #$6000+R6MF-R6MA-2,R6MA-R6C(A0)
        BRA.S   R6PP1
R6P1:   MOVE.W  #MWA1D3,R6A-R6C(A0)
        MOVE.W  D0,ER6A0-R6C+2(A0)
        MOVE.W  D3,ER6A1-R6C+2(A0)
        MOVE.W  #MWA1D3,R6MA-R6C(A0)
        MOVE.W  D0,ER6MA0-R6C+2(A0)
        MOVE.W  D3,ER6MA1-R6C+2(A0)
        MOVE.W  D4,CR6A0-R6C(A0)
        MOVE.W  D4,CR6MA0-R6C(A0)
        MOVE.W  D7,CR6MA1-R6C(A0)
        TST.B   D6
        BNE.S   R6PP1
        MOVE.W  #R6A-R6F-6,R6F-R6C+6(A0)
        MOVE.W  #R6MA-R6MF-10,R6MF-R6C+10(A0)
        BRA.S   R6PP3
R6PP1:  LSR.B   #1,D6
        BCS.S   R6P2
        MOVE.W  #$6000+R6A-R6B-2,R6B-R6C(A0)
        MOVE.L  #$60000000+R6MA-R6MB-2,R6MB-R6C(A0)
        BRA.S   R6PP2
R6P2:   MOVE.W  #SWPD7,R6B-R6C(A0)
        MOVE.W  D0,ER6B0-R6C+2(A0)
        MOVE.W  D3,ER6B1-R6C+2(A0)
        MOVE.L  #SWMWD7,R6MB-R6C(A0)
        MOVE.W  D0,ER6MB0-R6C+2(A0)
        MOVE.W  D3,ER6MB1-R6C+2(A0)
        MOVE.W  D4,CR6B0-R6C(A0)
        MOVE.W  D4,CR6MB0-R6C(A0)
        MOVE.W  D7,CR6MB1-R6C(A0)
        TST.B   D6
        BNE.S   R6PP2
        MOVE.W  #R6B-R6F-6,R6F-R6C+6(A0)
        MOVE.W  #R6MB-R6MF-10,R6MF-R6C+10(A0)
        BRA.S   R6PP3
R6PP2:  MOVE.W  D0,ER6C0-R6C+2(A0)
        MOVE.W  D3,ER6C1-R6C+2(A0)
        MOVE.W  D0,ER6MC0-R6C+2(A0)
        MOVE.W  D3,ER6MC1-R6C+2(A0)
        MOVE.W  #R6C-R6F-6,R6F-R6C+6(A0)
        MOVE.W  #R6MC-R6MF-10,R6MF-R6C+10(A0)
        MOVE.W  D4,CR6C0-R6C(A0)
        MOVE.W  D4,CR6MC0-R6C(A0)
        MOVE.W  D7,CR6MC1-R6C(A0)
R6PP3:
        MOVE.W  #160,A0
        SUB.W   (A7)+,A0
        MOVE.B  (A4)+,D7
        BEQ     R6MD-8
R6D:    EXT.W   D7
        BRA.L   R6F+4

R6C:    MOVE.L  (A1),D3
        CLR.W   D3
        LSR.L   D1,D3
ER6C0:  MOVE.L  2(A1),D5
        CLR.W   D5
        LSR.L   D1,D5
ER6C1:  MOVE.L  2(A1),D6
        CLR.W   D6
        LSR.L   D1,D6

        MOVE.W  D3,D2
        OR.W    D5,D2
        OR.W    D6,D2
        BNE.S   R6C0
        SUBQ.W  #8,A3
        BRA.S   R6B
R6C0:   MOVE.W  D2,D4
        NOT.W   D2
        MOVE.L  -(A3),D0
        OR.W    D4,D0
        EOR.W   D6,D0
        SWAP    D0
        OR.W    D4,D0
        EOR.W   D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)
CR6C0:  OR.W    D4,-(A3)
        OR.W    D4,-(A3)
        EOR.W   D3,(A3)

R6B:    SWAP    D7
        MOVE.W  VD7(PC),D7
R6B0:   SUBQ.W  #2,A1
        MOVE.L  (A1),D3
        LSR.L   D1,D3
ER6B0:  MOVE.L  2(A1),D5
        LSR.L   D1,D5
ER6B1:  MOVE.L  2(A1),D6
        LSR.L   D1,D6

        MOVE.W  D3,D2
        OR.W    D5,D2
        OR.W    D6,D2
        BNE.S   R6B1
        SUBQ.W  #8,A3
        DBF     D7,R6B0
        BRA.S   R6BF+4
R6B1:   MOVE.W  D2,D4
        NOT.W   D2
        BNE.S   R6B2
        MOVE.W  A5,D4
        NOT.W   D3
        NOT.W   D5
        NOT.W   D6
        MOVEM.W D3-D6,-(A3)
        DBF     D7,R6B0
        BRA.S   R6BF+4
R6B2:   MOVE.L  -(A3),D0
        OR.W    D4,D0
        EOR.W   D6,D0
        SWAP    D0
        OR.W    D4,D0
        EOR.W   D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)
CR6B0:  OR.W    D4,-(A3)   ;OU  OR.W D4,-(A3)
        OR.W    D4,-(A3)
        EOR.W   D3,(A3)
R6BF:   DBF     D7,R6B0
        SWAP    D7

R6A:    MOVE.W  (A1),D3
        LSR.W   D1,D3
ER6A0:  MOVE.W  2(A1),D5
        LSR.W   D1,D5
ER6A1:  MOVE.W  2(A1),D6
        LSR.W   D1,D6

        MOVE.W  D3,D2
        OR.W    D5,D2
        OR.W    D6,D2
        BNE.S   R6A1
        SUBQ.W  #8,A3
        BRA.S   R6F
R6A1:   MOVE.W  D2,D4
        NOT.W   D2
        MOVE.L  -(A3),D0
        OR.W    D4,D0
        EOR.W   D6,D0
        SWAP    D0
        OR.W    D4,D0
        EOR.W   D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)
CR6A0:  OR.W    D4,-(A3)   ;OU  OR.W D4,-(A3)
        OR.W    D4,-(A3)
        EOR.W   D3,(A3)
R6F:    ADD.W   A2,A1
        SUB.W   A0,A3
        DBF     D7,R6C

        MOVE.B  (A4)+,D7
        BNE.S   R6MD
        MOVE.L  (SP)+,A5
        RTS
R6MD:   EXT.W   D7
        BRA.L   R6MF+8           

R6MC:   MOVE.L  (A1),D3
        CLR.W   D3
        LSR.L   D1,D3
ER6MC0: MOVE.L  2(A1),D5
        CLR.W   D5
        LSR.L   D1,D5
ER6MC1: MOVE.L  2(A1),D6
        CLR.W   D6
        LSR.L   D1,D6

        MOVE.W  D3,D2
        OR.W    D5,D2
        OR.W    D6,D2
        BNE.S   R6MC0
        SUBQ.W  #8,A3
        BRA.S   R6MB
R6MC0:  MOVE.W  D2,D4
        NOT.W   D2
        LEA.L   -168(A3),A3
        OR.W    D4,(A3)
        EOR.W   D3,(A3)+
CR6MC1: OR.W    D4,(A3)+
        MOVE.L  (A3),D0
        OR.W    D4,D0
        EOR.W   D6,D0
        SWAP    D0
        OR.W    D4,D0
        EOR.W   D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)+
        LEA.L   156(A3),A3
        MOVE.L  (A3),D0
        OR.W    D4,D0
        EOR.W   D6,D0
        SWAP    D0
        OR.W    D4,D0
        EOR.W   D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)
CR6MC0: OR.W    D4,-(A3)        ;OU     OR.W D4,-(A3)
        OR.W    D4,-(A3)
        EOR.W   D3,(A3)
 
R6MB:   SWAP    D7
        MOVE.W  VD7(PC),D7
R6MB0:  SUBQ.W  #2,A1
        MOVE.L  (A1),D3
        LSR.L   D1,D3
ER6MB0: MOVE.L  2(A1),D5
        LSR.L   D1,D5
ER6MB1: MOVE.L  2(A1),D6
        LSR.L   D1,D6

        MOVE.W  D3,D2
        OR.W    D5,D2
        OR.W    D6,D2
        BNE.S   R6MB1
        SUBQ.W  #8,A3
        DBF     D7,R6MB0
        BRA.S   R6MBF+4
R6MB1:  MOVE.W  D2,D4
        NOT.W   D2
        BNE.S   R6MB2
        MOVE.W  A5,D4
        NOT.W   D3
        NOT.W   D5
        NOT.W   D6
        MOVEM.W D3-D6,-168(A3)
        MOVEM.W D3-D6,-(A3)
        DBF     D7,R6MB0
        BRA.S   R6MBF+4
R6MB2:  LEA.L   -168(A3),A3
        OR.W    D4,(A3)
        EOR.W   D3,(A3)+
CR6MB1: OR.W    D4,(A3)+
        MOVE.L  (A3),D0
        OR.W    D4,D0
        EOR.W   D6,D0
        SWAP    D0
        OR.W    D4,D0
        EOR.W   D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)+
        LEA.L   156(A3),A3
        MOVE.L  (A3),D0
        OR.W    D4,D0
        EOR.W   D6,D0
        SWAP    D0
        OR.W    D4,D0
        EOR.W   D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)
CR6MB0: OR.W    D4,-(A3)        ;OU     OR.W D4,-(A3)
        OR.W    D4,-(A3)
        EOR.W   D3,(A3)
R6MBF:  DBF     D7,R6MB0
        SWAP    D7

R6MA:   MOVE.W  (A1),D3
        LSR.W   D1,D3
ER6MA0: MOVE.W  2(A1),D5
        LSR.W   D1,D5
ER6MA1: MOVE.W  2(A1),D6
        LSR.W   D1,D6

        MOVE.W  D3,D2
        OR.W    D5,D2
        OR.W    D6,D2
        BNE.S   R6MA0
        SUBQ.W  #8,A3
        BRA.S   R6MF
R6MA0:  MOVE.W  D2,D4
        NOT.W   D2
        LEA.L   -168(A3),A3
        OR.W    D4,(A3)
        EOR.W   D3,(A3)+
CR6MA1: OR.W    D4,(A3)+
        MOVE.L  (A3),D0
        OR.W    D4,D0
        EOR.W   D6,D0
        SWAP    D0
        OR.W    D4,D0
        EOR.W   D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)+
        LEA.L   156(A3),A3
        MOVE.L  (A3),D0
        OR.W    D4,D0
        EOR.W   D6,D0
        SWAP    D0
        OR.W    D4,D0
        EOR.W   D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)
CR6MA0: OR.W    D4,-(A3)        ;OU     OR.W D4,-(A3)
        OR.W    D4,-(A3)
        EOR.W   D3,(A3)

R6MF:   ADD.W   A2,A1
        LEA.L   -160(A3),A3
        SUB.W   A0,A3
        DBF     D7,R6MC
        MOVE.B  (A4)+,D7
        BNE     R6D
        MOVE.L  (SP)+,A5
        RTS
*********
RM1034L:
        LEA.L   L6C(PC),A0
        LSR.B   #1,D6
        BCS.S   L6P1
        MOVE.W  #$6000+L6F-L6A-2,L6A-L6C(A0)
        MOVE.W  #$6000+L6MF-L6MA-2,L6MA-L6C(A0)
        BRA.S   L6PP1
L6P1:   MOVE.W  #MLA1D3,L6A-L6C(A0)
        MOVE.W  D0,EL6A0-L6C+2(A0)
        MOVE.W  D3,EL6A1-L6C+2(A0)
        MOVE.W  #MLA1D3,L6MA-L6C(A0)
        MOVE.W  D0,EL6MA0-L6C+2(A0)
        MOVE.W  D3,EL6MA1-L6C+2(A0)
        MOVE.W  D4,CL6A0-L6C(A0)
        MOVE.W  D4,CL6MA0-L6C(A0)
        MOVE.W  D7,CL6MA1-L6C(A0)
        TST.B   D6
        BNE.S   L6PP1
        MOVE.W  #L6A-L6F-6,L6F-L6C+6(A0)
        MOVE.W  #L6MA-L6MF-10,L6MF-L6C+10(A0)
        BRA.S   L6PP3
L6PP1:  LSR.B   #1,D6
        BCS.S   L6P2
        MOVE.W  #$6000+L6A-L6B-2,L6B-L6C(A0)
        MOVE.L  #$60000000+L6MA-L6MB-2,L6MB-L6C(A0)
        BRA.S   L6PP2
L6P2:   MOVE.W  #SWPD7,L6B-L6C(A0)
        MOVE.W  D0,EL6B0-L6C+2(A0)
        MOVE.W  D3,EL6B1-L6C+2(A0)
        MOVE.L  #SWMWD7,L6MB-L6C(A0)
        MOVE.W  D0,EL6MB0-L6C+2(A0)
        MOVE.W  D3,EL6MB1-L6C+2(A0)
        MOVE.W  D4,CL6B0-L6C(A0)
        MOVE.W  D4,CL6MB0-L6C(A0)
        MOVE.W  D7,CL6MB1-L6C(A0)
        TST.B   D6
        BNE.S   L6PP2
        MOVE.W  #L6B-L6F-6,L6F-L6C+6(A0)
        MOVE.W  #L6MB-L6MF-10,L6MF-L6C+10(A0)
        BRA.S   L6PP3
L6PP2:  MOVE.W  D0,EL6C0-L6C+2(A0)
        MOVE.W  D3,EL6C1-L6C+2(A0)
        MOVE.W  D0,EL6MC0-L6C+2(A0)
        MOVE.W  D3,EL6MC1-L6C+2(A0)
        MOVE.W  #L6C-L6F-6,L6F-L6C+6(A0)
        MOVE.W  #L6MC-L6MF-10,L6MF-L6C+10(A0)
        MOVE.W  D4,CL6C0-L6C(A0)
        MOVE.W  D4,CL6MC0-L6C(A0)
        MOVE.W  D7,CL6MC1-L6C(A0)
L6PP3:
        MOVE.W  #160,A0
        SUB.W   (A7)+,A0
        MOVE.B  (A4)+,D7
        BEQ     L6MD-8
L6D:    EXT.W   D7
        BRA.L   L6F+4

L6C:    MOVE.W  (A1),D3
        LSL.W   D1,D3
EL6C0:  MOVE.W  2(A1),D5
        LSL.W   D1,D5
EL6C1:  MOVE.W  2(A1),D6
        LSL.W   D1,D6

        MOVE.W  D3,D2
        OR.W    D5,D2
        OR.W    D6,D2
        BNE.S   L6C0
        SUBQ.W  #8,A3
        BRA.S   L6B
L6C0:   MOVE.W  D2,D4
        NOT.W   D2
        MOVE.L  -(A3),D0
        OR.W    D4,D0
        EOR.W   D6,D0
        SWAP    D0
        OR.W    D4,D0
        EOR.W   D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)
CL6C0:  OR.W    D4,-(A3)   ;OU  OR.W D4,-(A3)
        OR.W    D4,-(A3)
        EOR.W   D3,(A3)
 
L6B:    SWAP    D7
        MOVE.W  VD7(PC),D7
L6B0:   SUBQ.W  #2,A1
        MOVE.L  (A1),D3
        LSL.L   D1,D3
        SWAP    D3
EL6B0:  MOVE.L  2(A1),D5
        LSL.L   D1,D5
        SWAP    D5
EL6B1:  MOVE.L  2(A1),D6
        LSL.L   D1,D6
        SWAP    D6

        MOVE.W  D3,D2
        OR.W    D5,D2
        OR.W    D6,D2
        BNE.S   L6B1
        SUBQ.W  #8,A3
        DBF     D7,L6B0
        BRA.S   L6BF+4
L6B1:   MOVE.W  D2,D4
        NOT.W   D2
        BNE.S   L6B2
        MOVE.W  A5,D4
        NOT.W   D3
        NOT.W   D5
        NOT.W   D6
        MOVEM.W D3-D6,-(A3)
        DBF     D7,L6B0
        BRA.S   L6BF+4
L6B2:   MOVE.L  -(A3),D0
        OR.W    D4,D0
        EOR.W   D6,D0
        SWAP    D0
        OR.W    D4,D0
        EOR.W   D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)
CL6B0:  OR.W    D4,-(A3)   ;OU  OR.W D4,-(A3)
        OR.W    D4,-(A3)
        EOR.W   D3,(A3)

L6BF:   DBF     D7,L6B0
        SWAP    D7

L6A:    MOVE.L  (A1),D3
        CLR.W   D3
        ROL.L   D1,D3
EL6A0:  MOVE.L  2(A1),D5
        CLR.W   D5
        ROL.L   D1,D5
EL6A1:  MOVE.L  2(A1),D6
        CLR.W   D6
        ROL.L   D1,D6

        MOVE.W  D3,D2
        OR.W    D5,D2
        OR.W    D6,D2
        BNE.S   L6A1
        SUBQ.W  #8,A3
        BRA.S   L6F
L6A1:   MOVE.W  D2,D4
        NOT.W   D2
        MOVE.L  -(A3),D0
        OR.W    D4,D0
        EOR.W   D6,D0
        SWAP    D0
        OR.W    D4,D0
        EOR.W   D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)
CL6A0:  OR.W    D4,-(A3)   ;OU  OR.W D4,-(A3)
        OR.W    D4,-(A3)
        EOR.W   D3,(A3)

L6F:    ADD.W   A2,A1
        SUB.W   A0,A3
        DBF     D7,L6C

        MOVE.B  (A4)+,D7
        BNE.S   L6MD
        MOVE.L  (SP)+,A5
        RTS
L6MD:   EXT.W   D7
        BRA.L   L6MF+8           

L6MC:   MOVE.W  (A1),D3
        LSL.W   D1,D3
EL6MC0: MOVE.W  2(A1),D5
        LSL.W   D1,D5
EL6MC1: MOVE.W  2(A1),D6
        LSL.W   D1,D6

        MOVE.W  D3,D2
        OR.W    D5,D2
        OR.W    D6,D2
        BNE.S   L6MC0
        SUBQ.W  #8,A3
        BRA.S   L6MB
L6MC0:  MOVE.W  D2,D4
        NOT.W   D2
        LEA.L   -168(A3),A3
        OR.W    D4,(A3)
        EOR.W   D3,(A3)+
CL6MC1: OR.W    D4,(A3)+
        MOVE.L  (A3),D0
        OR.W    D4,D0
        EOR.W   D6,D0
        SWAP    D0
        OR.W    D4,D0
        EOR.W   D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)+
        LEA.L   156(A3),A3
        MOVE.L  (A3),D0
        OR.W    D4,D0
        EOR.W   D6,D0
        SWAP    D0
        OR.W    D4,D0
        EOR.W   D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)
CL6MC0: OR.W    D4,-(A3)        ;OU     OR.W D4,-(A3)
        OR.W    D4,-(A3)
        EOR.W   D3,(A3)
 
L6MB:   SWAP    D7
        MOVE.W  VD7(PC),D7
L6MB0:  SUBQ.W  #2,A1
        MOVE.L  (A1),D3
        LSL.L   D1,D3
        SWAP    D3
EL6MB0: MOVE.L  2(A1),D5
        LSL.L   D1,D5
        SWAP    D5
EL6MB1: MOVE.L  2(A1),D6
        LSL.L   D1,D6
        SWAP    D6

        MOVE.W  D3,D2
        OR.W    D5,D2
        OR.W    D6,D2
        BNE.S   L6MB1
        SUBQ.W  #8,A3
        DBF     D7,L6MB0
        BRA.S   L6MBF+4
L6MB1:  MOVE.W  D2,D4
        NOT.W   D2
        BNE.S   L6MB2
        MOVE.W  A5,D4
        NOT.W   D3
        NOT.W   D5
        NOT.W   D6
        MOVEM.W D3-D6,-168(A3)
        MOVEM.W D3-D6,-(A3)
        DBF     D7,L6MB0
        BRA.S   L6MBF+4
L6MB2:  LEA.L   -168(A3),A3
        OR.W    D4,(A3)
        EOR.W   D3,(A3)+
CL6MB1: OR.W    D4,(A3)+
        MOVE.L  (A3),D0
        OR.W    D4,D0
        EOR.W   D6,D0
        SWAP    D0
        OR.W    D4,D0
        EOR.W   D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)+
        LEA.L   156(A3),A3
        MOVE.L  (A3),D0
        OR.W    D4,D0
        EOR.W   D6,D0
        SWAP    D0
        OR.W    D4,D0
        EOR.W   D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)
CL6MB0: OR.W    D4,-(A3)        ;OU     OR.W D4,-(A3)
        OR.W    D4,-(A3)
        EOR.W   D3,(A3)
L6MBF:  DBF     D7,L6MB0
        SWAP    D7

L6MA:   MOVE.L  (A1),D3
        CLR.W   D3
        ROL.L   D1,D3
EL6MA0: MOVE.L  2(A1),D5
        CLR.W   D5
        ROL.L   D1,D5
EL6MA1: MOVE.L  2(A1),D6
        CLR.W   D6
        ROL.L   D1,D6

        MOVE.W  D3,D2
        OR.W    D5,D2
        OR.W    D6,D2
        BNE.S   L6MA0
        SUBQ.W  #8,A3
        BRA.S   L6MF
L6MA0:  MOVE.W  D2,D4
        NOT.W   D2
        LEA.L   -168(A3),A3
        OR.W    D4,(A3)
        EOR.W   D3,(A3)+
CL6MA1: OR.W    D4,(A3)+
        MOVE.L  (A3),D0
        OR.W    D4,D0
        EOR.W   D6,D0
        SWAP    D0
        OR.W    D4,D0
        EOR.W   D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)+
        LEA.L   156(A3),A3
        MOVE.L  (A3),D0
        OR.W    D4,D0
        EOR.W   D6,D0
        SWAP    D0
        OR.W    D4,D0
        EOR.W   D5,D0
        SWAP    D0
        MOVE.L  D0,(A3)
CL6MA0: OR.W    D4,-(A3)        ;OU     OR.W D4,-(A3)
        OR.W    D4,-(A3)
        EOR.W   D3,(A3)

L6MF:   ADD.W   A2,A1
        LEA.L   -160(A3),A3
        SUB.W   A0,A3
        DBF     D7,L6MC
        MOVE.B  (A4)+,D7
        BNE     L6D
        MOVE.L  (SP)+,A5
        RTS

**********
RN1000: MOVE.B  EFSP(PC),D7
        AND.W   #$7,D7
        CMP.W   #3,D7
        BGT     RM1000
        ADD.W   D7,D7
        SUB.W   D7,A3
        CMP.W   D2,D1
        BLE.S   RN1000R
        MOVE.W  D2,D1
        BRA     RN1000L
RN1000R:
        MOVE.W  VD7(PC),D2
        LEA.L   R7C(PC),A0
        LSR.B   #1,D6
        BCS.S   R7P1
        MOVE.W  #$6000+R7F-R7A-2,R7A-R7C(A0)
        MOVE.W  #$6000+R7MF-R7MA-2,R7MA-R7C(A0)
        BRA.S   R7PP1
R7P1:   MOVE.W  #MWA1D5,R7A-R7C(A0)
        MOVE.W  #MWA1D5,R7MA-R7C(A0)
        TST.B   D6
        BNE.S   R7PP1
        MOVE.W  #R7A-R7F-6,R7F-R7C+6(A0)
        MOVE.W  #R7MA-R7MF-10,R7MF-R7C+10(A0)
        BRA.S   R7PP3
R7PP1:  LSR.B   #1,D6
        BCS.S   R7P2
        MOVE.W  #$6000+R7A-R7B-2,R7B-R7C(A0)
        MOVE.W  #$6000+R7MA-R7MB-2,R7MB-R7C(A0)
        BRA.S   R7PP2
R7P2:   MOVE.W  #MWD2D6,R7B-R7C(A0)
        MOVE.W  #MWD2D6,R7MB-R7C(A0)
        TST.B   D6
        BNE.S   R7PP2
        MOVE.W  #R7B-R7F-6,R7F-R7C+6(A0)
        MOVE.W  #R7MB-R7MF-10,R7MF-R7C+10(A0)
        BRA.S   R7PP3
R7PP2:  MOVE.W  #R7C-R7F-6,R7F-R7C+6(A0)
        MOVE.W  #R7MC-R7MF-10,R7MF-R7C+10(A0)
R7PP3:
        MOVE.W  #160,A0
        SUB.W   D5,A0
        MOVE.B  (A4)+,D7
        BEQ     R7MD-6
R7D:    EXT.W   D7
        BRA.S   R7F+4

R7C:    MOVE.L  (A1),D5
        CLR.W   D5
        LSR.L   D1,D5
        OR.W    D5,-(A3)
        LEA.L   -6(A3),A3

R7B:    MOVE.W  D2,D6
R7B0:   SUBQ.W  #2,A1
        MOVE.L  (A1),D5
        LSR.L   D1,D5
        OR.W    D5,-(A3)
        LEA.L   -6(A3),A3
        DBF     D6,R7B0

R7A:    MOVE.W  (A1),D5
        LSR.W   D1,D5
        OR.W    D5,-(A3)
        LEA.L   -6(A3),A3
R7F:    ADD.W   A2,A1
        SUB.W   A0,A3
        DBF     D7,R7C

        MOVE.B  (A4)+,D7
        BNE.S   R7MD
        RTS
R7MD:   EXT.W   D7
        BRA.S   R7MF+8           

R7MC:   MOVE.L  (A1),D5
        CLR.W   D5
        LSR.L   D1,D5
        OR.W    D5,-(A3)
        OR.W    D5,-160(A3)
        LEA.L   -6(A3),A3

R7MB:   MOVE.W  D2,D6
R7MB0:  SUBQ.W  #2,A1
        MOVE.L  (A1),D5
        LSR.L   D1,D5
        OR.W    D5,-(A3)
        OR.W    D5,-160(A3)
        LEA.L   -6(A3),A3
        DBF     D6,R7MB0

R7MA:   MOVE.W  (A1),D5
        LSR.W   D1,D5
        OR.W    D5,-(A3)
        OR.W    D5,-160(A3)
        LEA.L   -6(A3),A3

R7MF:   ADD.W   A2,A1
        LEA.L   -160(A3),A3
        SUB.W   A0,A3
        DBF     D7,R7MC
        MOVE.B  (A4)+,D7
        BNE     R7D
        RTS
*********
RN1000L:
        MOVE.W  VD7(PC),D2
        LEA.L   L7C(PC),A0
        LSR.B   #1,D6
        BCS.S   L7P1
        MOVE.W  #$6000+L7F-L7A-2,L7A-L7C(A0)
        MOVE.W  #$6000+L7MF-L7MA-2,L7MA-L7C(A0)
        BRA.S   L7PP1
L7P1:   MOVE.W  #MLA1D5,L7A-L7C(A0)
        MOVE.W  #MLA1D5,L7MA-L7C(A0)
        TST.B   D6
        BNE.S   L7PP1
        MOVE.W  #L7A-L7F-6,L7F-L7C+6(A0)
        MOVE.W  #L7MA-L7MF-10,L7MF-L7C+10(A0)
        BRA.S   L7PP3
L7PP1:  LSR.B   #1,D6
        BCS.S   L7P2
        MOVE.W  #$6000+L7A-L7B-2,L7B-L7C(A0)
        MOVE.W  #$6000+L7MA-L7MB-2,L7MB-L7C(A0)
        BRA.S   L7PP2
L7P2:   MOVE.W  #MWD2D6,L7B-L7C(A0)
        MOVE.W  #MWD2D6,L7MB-L7C(A0)
        TST.B   D6
        BNE.S   L7PP2
        MOVE.W  #L7B-L7F-6,L7F-L7C+6(A0)
        MOVE.W  #L7MB-L7MF-10,L7MF-L7C+10(A0)
        BRA.S   L7PP3
L7PP2:  MOVE.W  #L7C-L7F-6,L7F-L7C+6(A0)
        MOVE.W  #L7MC-L7MF-10,L7MF-L7C+10(A0)
L7PP3:
        MOVE.W  #160,A0
        SUB.W   D5,A0
        MOVE.B  (A4)+,D7
        BEQ     L7MD-6
L7D:    EXT.W   D7
        BRA.S   L7F+4

L7C:    MOVE.W  (A1),D5
        LSL.W   D1,D5
        OR.W    D5,-(A3)
        LEA.L   -6(A3),A3

L7B:    MOVE.W  D2,D6
L7B0:   SUBQ.W  #2,A1
        MOVE.L  (A1),D5
        LSL.L   D1,D5
        SWAP    D5
        OR.W    D5,-(A3)
        LEA.L   -6(A3),A3
L7BF:   DBF     D6,L7B0

L7A:    MOVE.L  (A1),D5
        CLR.W   D5
        ROL.L   D1,D5
        OR.W    D5,-(A3)
        LEA.L   -6(A3),A3

L7F:    ADD.W   A2,A1
        SUB.W   A0,A3
        DBF     D7,L7C

        MOVE.B  (A4)+,D7
        BNE.S   L7MD
        RTS
L7MD:   EXT.W   D7
        BRA.S   L7MF+8           

L7MC:   MOVE.W  (A1),D5
        LSL.W   D1,D5
        OR.W    D5,-(A3)
        OR.W    D5,-160(A3)
        LEA.L   -6(A3),A3

L7MB:   MOVE.W  D2,D6
L7MB0:  SUBQ.W  #2,A1
        MOVE.L  (A1),D5
        LSL.L   D1,D5
        SWAP    D5
        OR.W    D5,-(A3)
        OR.W    D5,-160(A3)
        LEA.L   -6(A3),A3
L7MBF:  DBF     D6,L7MB0

L7MA:   MOVE.L  (A1),D5
        CLR.W   D5
        ROL.L   D1,D5
        OR.W    D5,-(A3)
        OR.W    D5,-160(A3)
        LEA.L   -6(A3),A3

L7MF:   ADD.W   A2,A1
        LEA.L   -160(A3),A3
        SUB.W   A0,A3
        DBF     D7,L7MC
        MOVE.B  (A4)+,D7
        BNE     L7D
        RTS

**********
RM1000: SUBQ.W  #4,D7
        ADD.W   D7,D7
        SUB.W   D7,A3
        CMP.W   D2,D1
        BLE.S   RM1000R
        MOVE.W  D2,D1
        BRA     RM1000L
RM1000R:
        MOVE.W  VD7(PC),D2
        LEA.L   R8C(PC),A0
        LSR.B   #1,D6
        BCS.S   R8P1
        MOVE.W  #$6000+R8F-R8A-2,R8A-R8C(A0)
        MOVE.W  #$6000+R8MF-R8MA-2,R8MA-R8C(A0)
        BRA.S   R8PP1
R8P1:   MOVE.W  #MWA1D5,R8A-R8C(A0)
        MOVE.W  #MWA1D5,R8MA-R8C(A0)
        TST.B   D6
        BNE.S   R8PP1
        MOVE.W  #R8A-R8F-6,R8F-R8C+6(A0)
        MOVE.W  #R8MA-R8MF-10,R8MF-R8C+10(A0)
        BRA.S   R8PP3
R8PP1:  LSR.B   #1,D6
        BCS.S   R8P2
        MOVE.W  #$6000+R8A-R8B-2,R8B-R8C(A0)
        MOVE.W  #$6000+R8MA-R8MB-2,R8MB-R8C(A0)
        BRA.S   R8PP2
R8P2:   MOVE.W  #MWD2D6,R8B-R8C(A0)
        MOVE.W  #MWD2D6,R8MB-R8C(A0)
        TST.B   D6
        BNE.S   R8PP2
        MOVE.W  #R8B-R8F-6,R8F-R8C+6(A0)
        MOVE.W  #R8MB-R8MF-10,R8MF-R8C+10(A0)
        BRA.S   R8PP3
R8PP2:  MOVE.W  #R8C-R8F-6,R8F-R8C+6(A0)
        MOVE.W  #R8MC-R8MF-10,R8MF-R8C+10(A0)
R8PP3:
        MOVE.W  #160,A0
        SUB.W   D5,A0
        MOVE.B  (A4)+,D7
        BEQ     R8MD-6
R8D:    EXT.W   D7
        BRA.S   R8F+4

R8C:    MOVE.L  (A1),D5
        CLR.W   D5
        LSR.L   D1,D5
        NOT.W   D5
        AND.W   D5,-(A3)
        LEA.L   -6(A3),A3

R8B:    MOVE.W  D2,D6
R8B0:   SUBQ.W  #2,A1
        MOVE.L  (A1),D5
        LSR.L   D1,D5
        NOT.W   D5
        AND.W   D5,-(A3)
        LEA.L   -6(A3),A3
        DBF     D6,R8B0

R8A:    MOVE.W  (A1),D5
        LSR.W   D1,D5
        NOT.W   D5
        AND.W   D5,-(A3)
        LEA.L   -6(A3),A3
R8F:    ADD.W   A2,A1
        SUB.W   A0,A3
        DBF     D7,R8C

        MOVE.B  (A4)+,D7
        BNE.S   R8MD
        RTS
R8MD:   EXT.W   D7
        BRA.S   R8MF+8           

R8MC:   MOVE.L  (A1),D5
        CLR.W   D5
        LSR.L   D1,D5
        NOT.W   D5
        AND.W   D5,-(A3)
        AND.W   D5,-160(A3)
        LEA.L   -6(A3),A3

R8MB:   MOVE.W  D2,D6
R8MB0:  SUBQ.W  #2,A1
        MOVE.L  (A1),D5
        LSR.L   D1,D5
        NOT.W   D5
        AND.W   D5,-(A3)
        AND.W   D5,-160(A3)
        LEA.L   -6(A3),A3
        DBF     D6,R8MB0

R8MA:   MOVE.W  (A1),D5
        LSR.W   D1,D5
        NOT.W   D5
        AND.W   D5,-(A3)
        AND.W   D5,-160(A3)
        LEA.L   -6(A3),A3

R8MF:   ADD.W   A2,A1
        LEA.L   -160(A3),A3
        SUB.W   A0,A3
        DBF     D7,R8MC
        MOVE.B  (A4)+,D7
        BNE     R8D
        RTS
*********
RM1000L:
        MOVE.W  VD7(PC),D2
        LEA.L   L8C(PC),A0
        LSR.B   #1,D6
        BCS.S   L8P1
        MOVE.W  #$6000+L8F-L8A-2,L8A-L8C(A0)
        MOVE.W  #$6000+L8MF-L8MA-2,L8MA-L8C(A0)
        BRA.S   L8PP1
L8P1:   MOVE.W  #MLA1D5,L8A-L8C(A0)
        MOVE.W  #MLA1D5,L8MA-L8C(A0)
        TST.B   D6
        BNE.S   L8PP1
        MOVE.W  #L8A-L8F-6,L8F-L8C+6(A0)
        MOVE.W  #L8MA-L8MF-10,L8MF-L8C+10(A0)
        BRA.S   L8PP3
L8PP1:  LSR.B   #1,D6
        BCS.S   L8P2
        MOVE.W  #$6000+L8A-L8B-2,L8B-L8C(A0)
        MOVE.W  #$6000+L8MA-L8MB-2,L8MB-L8C(A0)
        BRA.S   L8PP2
L8P2:   MOVE.W  #MWD2D6,L8B-L8C(A0)
        MOVE.W  #MWD2D6,L8MB-L8C(A0)
        TST.B   D6
        BNE.S   L8PP2
        MOVE.W  #L8B-L8F-6,L8F-L8C+6(A0)
        MOVE.W  #L8MB-L8MF-10,L8MF-L8C+10(A0)
        BRA.S   L8PP3
L8PP2:  MOVE.W  #L8C-L8F-6,L8F-L8C+6(A0)
        MOVE.W  #L8MC-L8MF-10,L8MF-L8C+10(A0)
L8PP3:
        MOVE.W  #160,A0
        SUB.W   D5,A0
        MOVE.B  (A4)+,D7
        BEQ     L8MD-6
L8D:    EXT.W   D7
        BRA.S   L8F+4

L8C:    MOVE.W  (A1),D5
        LSL.W   D1,D5
        NOT.W   D5
        AND.W   D5,-(A3)
        LEA.L   -6(A3),A3

L8B:    MOVE.W  D2,D6
L8B0:   SUBQ.W  #2,A1
        MOVE.L  (A1),D5
        LSL.L   D1,D5
        SWAP    D5
        NOT.W   D5
        AND.W   D5,-(A3)
        LEA.L   -6(A3),A3
L8BF:   DBF     D6,L8B0

L8A:    MOVE.L  (A1),D5
        CLR.W   D5
        ROL.L   D1,D5
        NOT.W   D5
        AND.W   D5,-(A3)
        LEA.L   -6(A3),A3

L8F:    ADD.W   A2,A1
        SUB.W   A0,A3
        DBF     D7,L8C

        MOVE.B  (A4)+,D7
        BNE.S   L8MD
        RTS
L8MD:   EXT.W   D7
        BRA.S   L8MF+8           

L8MC:   MOVE.W  (A1),D5
        LSL.W   D1,D5
        NOT.W   D5
        AND.W   D5,-(A3)
        AND.W   D5,-160(A3)
        LEA.L   -6(A3),A3

L8MB:   MOVE.W  D2,D6
L8MB0:  SUBQ.W  #2,A1
        MOVE.L  (A1),D5
        LSL.L   D1,D5
        SWAP    D5
        NOT.W   D5
        AND.W   D5,-(A3)
        AND.W   D5,-160(A3)
        LEA.L   -6(A3),A3
L8MBF:  DBF     D6,L8MB0

L8MA:   MOVE.L  (A1),D5
        CLR.W   D5
        ROL.L   D1,D5
        NOT.W   D5
        AND.W   D5,-(A3)
        AND.W   D5,-160(A3)
        LEA.L   -6(A3),A3

L8MF:   ADD.W   A2,A1
        LEA.L   -160(A3),A3
        SUB.W   A0,A3
        DBF     D7,L8MC
        MOVE.B  (A4)+,D7
        BNE     L8D
        RTS

nob:    dc.b    "o***.phy"
        dc.b    0
        CNOP    0,2
ecrit:  divu    #10,d0
        move.l  d0,d2
        swap    d2
        andi.l  #$0000ffff,d0
        addi.b  #48,d2
        move.b  d2,0(a1,d1.w)
        dbf     d1,ecrit
        rts
chargt: 
        moveq   #0,d0
        move.w  naobj(pc),d0
        lea.l   nob+1(pc),a1
        move.w  #2,d1
        jsr     ecrit
        clr.w   -(sp)
        move.l  #nob,-(sp)
        move.w  #$3d,-(sp)
        trap    #1
        addq.l  #8,sp
        move.w  d0,handl
        move.l  adhaut(pc),-(sp)
        move.l  #20000,-(sp)
        move.w  handl,-(sp)
        move.w  #$3f,-(sp)
        trap    #1
        add.l   #12,sp
        move.w  handl,-(sp)
        move.w  #$3e,-(sp)
        trap    #1
        addq.l  #4,sp
        rts
handl:  dc.w    0
**********
iniobj: lea.l   tabobj(pc),a0
        move.w  naobj(pc),d0
        lsl.w   #2,d0
        tst.l   0(a0,d0.w)
        beq.s   siniob
        rts
siniob: move.l  adhaut(pc),0(a0,d0.w)
        bsr     chargt
        move.l  adhaut(pc),a0
        add.w   (a0),a0
        move.l  CURSCR,a1       ;zone de trav
        move.w  (a0),d0
        subq.w  #1,d0
rechom: move.b  (a0)+,(a1)+
        dbf     d0,rechom
        move.l  a1,a2
        move.w  #21,d0
        add.w   4(a0),d0
        add.w   6(a0),d0
        bclr    #0,d0
        subq.w  #1,d0
recomp: move.b  (a0)+,(a1)+
        dbf     d0,recomp
        
        move.l  #1,-(a7)
        move.l  a1,-(a7)
        move.l  a2,-(a7)
        clr.l   -(a7)
        clr.l   -(a7)
        move.l  CURSCR,-(a7)
        bsr     DECOMP

        move.w  #15,d0
        lea.l   tabinst(pc),a4
        lea.l   tabins2(pc),a3
        move.l  adhaut(pc),a0
        add.w   2(a0),a0
        addq.w  #4,a0
        btst    #0,3(a0)
        beq.s   biins1
        lea.l   tabins3(pc),a3
biins1: move.l  (a3)+,(a4)+
        dbf     d0,biins1
;trt homo
        lea.l   zbuf(pc),a3
        lea.l   tabinst(pc),a4
        moveq   #0,d1
        move.w  6(a3),d1
        addq.w  #2,d1
        lsr.w   #1,d1
        move.l  d1,10(a3)
        addq.w  #1,d1
        move.w  8(a3),d7
        addq.w  #1,d7
        mulu    d7,d1
        add.l   adcomp(pc),d1
        bclr    #0,d1
        move.l  d1,a6
        clr.l   (a6)+
        clr.l   (a6)+
        clr.l   (a6)+
        clr.l   (a6)+
        clr.l   (a6)+
        clr.l   (a6)+
        clr.l   (a6)+
        clr.l   (a6)+
        move.w  2(a0),d7
        move.w  (a0),a0
        add.l   adhaut(pc),a0
        move.l  CURSCR,a2    ;meme zone de trav
        move.w  (a2)+,d0
        subq.w  #2,d0
bhom:   movem.l d0/d7/a0/a6,-(sp)
        bsr     thomo
        movem.l (sp)+,d0/d7/a0/a6
        move.l  adhaut(pc),a5
        add.w   (a0),a5
        move.w  6(a0),d1
        move.w  d1,d2
        lsl.w   #2,d1
        lsr.w   #1,d2
        subq.w  #1,d2
        sub.w   d1,a1
        add.w   d1,d1
        move.l  a1,d3
        btst    #5,d7
        beq.s   d2hom
b1hom:  clr.w   d4
        move.b  5(a0),d4
        subq.w  #1,d4
sb1ho:  move.w  d2,d5
sb1ho1: move.w  (a1),(a5)+
        lea.l   8(a1),a1
        dbf     d5,sb1ho1
        sub.w   d1,a1
        dbf     d4,sb1ho
d2hom:  btst    #4,d7
        beq.s   d3hom
b2hom:  clr.w   d4
        move.b  5(a0),d4
        subq.w  #1,d4
        move.l  d3,a1
        addq.w  #2,a1
sb2ho:  move.w  d2,d5
sb2ho1: move.w  (a1),(a5)+
        lea.l   8(a1),a1
        dbf     d5,sb2ho1
        sub.w   d1,a1
        dbf     d4,sb2ho
d3hom:  btst    #3,d7
        beq.s   d4hom
b3hom:  clr.w   d4
        move.b  5(a0),d4
        subq.w  #1,d4
        move.l  d3,a1
        addq.w  #4,a1
sb3ho:  move.w  d2,d5
sb3ho1: move.w  (a1),(a5)+
        lea.l   8(a1),a1
        dbf     d5,sb3ho1
        sub.w   d1,a1
        dbf     d4,sb3ho
d4hom:  btst    #2,d7
        beq.s   b5hom
b4hom:  clr.w   d4
        move.b  5(a0),d4
        subq.w  #1,d4
        move.l  d3,a1
        addq.w  #6,a1
sb4ho:  move.w  d2,d5
sb4ho1: move.w  (a1),(a5)+
        lea.l   8(a1),a1
        dbf     d5,sb4ho1
        sub.w   d1,a1
        dbf     d4,sb4ho
b5hom:  lea.l   8(a0),a0
        lea.l   6(a2),a2
        subq.w  #6,d0
        bgt     bhom
        move.l  a5,adhaut
        rts

thomo:  move.l a6,a1 
        move.l #$80008000,d7
        move.l #$80000000,d5
        move.w 8(a3),boucy 
        move.l adcomp(pc),a0 
        moveq   #0,d3 
        move.l  d3,d4
        move.w  (a2),d6
        moveq   #0,d2
        move.w  d6,d2
        moveq   #0,d0
        move.b  4(a2),d0
        mulu    d0,d2
        lsr.l   #6,d2
        move.w  d2,16(a3)
        moveq   #0,d1
        move.w  2(a2),d1
        move.b  5(a2),d0
        mulu    d0,d1
        lsr.l   #6,d1
        move.w  d1,14(a3)
        clr.w   d0
        tst.w   2(a2)
        beq     ggross
 
        lea.l   dchet1,a5
        lea.l   dchet2,a6
        move.w  2(a2),d1
drep1:  add.w   #128,14(a3)
        cmp.w   14(a3),d1
        bgt.s   dcopr4
        sub.w   d1,14(a3)
        add.l   10(a3),a0
        subq.w  #1,boucy
        bge.s   drep1
        rts
dcopr4: move.w  6(a3),d1
dbitaf: add.w   #128,d2
        cmp.w   d6,d2
        blt.s   dcopr1
        sub.w   d6,d2
        bra.s   dbaf5
dcopr1: move.b  (a0),d0
        and.w   #$f0,d0 
        lsr.w   #2,d0
        move.l  0(a4,d0.w),(a5) 
        nop
dchet1: nop
        nop
        ror.l   #1,d5
        ror.l   #1,d7 
        bcc.s   dbaf5 
        swap    d5
        move.l  d3,(a1)+  
        move.l  d4,(a1)+ 
        moveq   #0,d3 
        move.l  d3,d4
        dbf     d1,dbaf6
        addq.l  #1,a0
        bra.s   dfilib
dbaf5:  dbf     d1,dbaf6
        addq.l  #1,a0
        bra.s   dfili
dbaf6:  add.w   #128,d2
        cmp.w   d6,d2
        blt.s   dcopr2
        sub.w   d6,d2
        addq.l  #1,a0
        dbf     d1,dbitaf
        bra.s   dfili
dcopr2: move.b  (a0)+,d0
        and.w   #$f,d0
        lsl.w   #2,d0
        move.l  0(a4,d0.w),(a6)
        nop
dchet2: nop
        nop
dbaf7:  ror.l   #1,d5
        ror.l   #1,d7 
        bcc.s   dbafx 
        swap    d5
        move.l  d3,(a1)+
        move.l  d4,(a1)+ 
        moveq   #0,d3 
        move.l  d3,d4
        dbf     d1,dbitaf
        bra.s   dfilib
dbafx:  dbf     d1,dbitaf
dfili:  tst.w   d7
        blt.s   dfilib
        move.l  d3,(a1)+  
        move.l  d4,(a1)+ 
        moveq   #0,d3 
        move.l  d3,d4
dfilib: 
        move.l  #$80008000,d7
        move.l  #$80000000,d5
        move.w  16(a3),d2
        move.w  2(a2),d1
drep2:  add.w   #128,14(a3)
        cmp.w   14(a3),d1
        bgt.s   dcopr3
        sub.w   d1,14(a3)
        add.l   10(a3),a0
        subq.w  #1,boucy
        bge.s   drep2
        rts
dcopr3: move.w  6(a3),d1
        subq.w  #1,boucy 
        bge     dbitaf
        rts

ggross: move.w  6(a3),d1
        lea.l   gchet1,a5
        lea.l   gchet2,a6
gbitaf: move.b  (a0),d0
        and.b   #$f0,d0 
        lsr.b   #2,d0
        move.l  0(a4,d0.w),(a5) 
        nop
gchet1: nop
        nop
        ror.l   #1,d5
        ror.l   #1,d7
        bcc.s   gbaf5
        swap    d5
        move.l  d3,(a1)+  
        move.l  d4,(a1)+ 
        moveq   #0,d3 
        move.l  d3,d4
gbaf5:  add.w   #128,d2
        cmp.w   d6,d2
        blt.s   gcopr1
        sub.w   d6,d2
        bra.s   gchet1
gcopr1: dbf     d1,gbaf6
        addq.l  #1,a0
        bra.s   gfili
gbaf6:  move.b  (a0)+,d0
        and.b   #$f,d0
        lsl.b   #2,d0
        move.l  0(a4,d0.w),(a6)
        nop
gchet2: nop
        nop
        ror.l   #1,d5
        ror.l   #1,d7 
        bcc.s   gbafx 
        swap    d5
        move.l  d3,(a1)+  
        move.l  d4,(a1)+ 
        moveq   #0,d3 
        move.l  d3,d4
gbafx:  add.w   #128,d2
        cmp.w   d6,d2
        blt.s   gcopr2
        sub.w   d6,d2
        bra.s   gchet2
gcopr2: dbf     d1,gbitaf 
gfili:  tst.w   d7
        blt.s   gfilib
        move.l  d3,(a1)+
        move.l  d4,(a1)+ 
        moveq   #0,d3 
        move.l  d3,d4
gfilib: move.l  #$80008000,d7
        move.l  #$80000000,d5
        move.w  16(a3),d2
        move.w  6(a3),d1
        subq.w  #1,boucy
        bge     gbitaf
        rts
DECOMP:
    move.l 4(a7),adecr
    move.w 10(a7),ycoor
    move.w 14(a7),xcoor
    move.l 16(a7),adfi
    move.l 20(a7),plcomp
        move.l  24(a7),flsprite
    movem.l d0-d7/a0-a6,-(sp)
    move.l adfi(pc),a0
    move.b (a0),typfi
    move.b 1(a0),nbcar
    add.l #2,adfi
        move.w  #15,d0
        lea.l   tabinst(pc),a4
        lea.l   tabins2(pc),a3
bins:   move.l  (a3)+,(a4)+
        dbf     d0,bins
    tst.b typfi
    bne fiani
;voir palette
    add.l #32,adfi
    bra inicont
fiani:
    clr.w  d0
    move.b 2(a0),d0
    lsl.b #2,d0
    lea.l  tabinst(pc),a0
    move.l codanim(pc),0(a0,d0.w)
    add.l #2,adfi
inicont:
    move.l plcomp(pc),tailcou
    move.l plcomp(pc),plaff
    lea.l zbuf(pc),a3
    move.l adfi(pc),a4
    move.l 10(a4),6(a3)
    move.w xcoor(pc),10(a3)
    move.w ycoor(pc),12(a3)
    move.l a4,adcomp
    addi.l #14,adcomp
    move.w 4(a4),d0
    add.w d0,10(a3)
    move.w 6(a4),d0
    add.w d0,12(a3)
    tst.b 8(a4)
    beq afficha
    move.l adcomp(pc),adanc
    move.l adcomp(pc),adanq
    move.l adcomp(pc),adcoc
    move.l adcomp(pc),adcoq
    move.l plaff(pc),adcomp
    clr.l d0
    move.w (a4),d0
    add.l d0,adanq
    add.l d0,adcoq
    add.w 2(a4),d0
    btst #0,d0
    beq.s bonfron
    add.l #1,adanq
    add.l #1,adcoq
bonfron:
    btst #0,9(a4)
    beq.s tst1
    bsr repanac
    move.l adfi(pc),a4
tst1:
    btst #1,9(a4)
    beq.s tst2
    bsr repanav
    move.l adfi(pc),a4
tst2:
    clr.w d6
    move.b 8(a4),d6
    lea.l zbuf(pc),a3
    lsl.b #2,d6
    move.w d6,14(a3)
    lea.l tabadcb(pc),a6
    jsr 0(a6,d6.w)
afficha:
        tst.l   flsprite
        bne     atcara1
    lea.l zbuf(pc),a3
    lea.l tabinst(pc),a4
    lea.l chet1(pc),a5
    lea.l chet2(pc),a6 
    move.l adecr,a1 
    move.w 10(a3),d1 
    move.w 12(a3),d2 
    move.w d1,d3 
    mulu #160,d2 
    lsr.w #1,d1 
    andi.b #$f8,d1 
    add.w d1,d2 
    andi.w #$000f,d3 
    eori.b #$0f,d3 
    adda.l d2,a1 
    moveq  #0,d7 
    bset d3,d7
    swap d7
    move.l d7,d5
    bset d3,d7 
    move.w d7,4(a3) 
    move.w d7,d3 
    eor.w #$ffff,d3 
    move.w #$ffff,maskdeb 
mepmade:
    and.w d3,maskdeb 
    ror.w #1,d3 
    bcs.s mepmade 
    move.w maskdeb(pc),d2
    swap  d2
    move.w maskdeb(pc),d2 
    move.w 6(a3),d1 
    lsr.w #1,d1 
    move.w 8(a3),boucy 
    move.l a1,(a3) 
    move.l adcomp(pc),a0 
    clr.w filin 
    moveq       #0,d3 
    moveq       #0,d4
    clr.w d0 
    move.b (a0),d0
    bra.s bitaf 
bafx:
    ror.l #1,d5
    ror.l #1,d7 
    bcc.s bitaf 
    swap  d5
    and.l d2,(a1)
    or.l d3,(a1)+  
    and.l d2,(a1) 
    or.l d4,(a1)+ 
    moveq       #0,d2     
    move.l      d2,d3 
    move.l      d2,d4 
bitaf:
    and.b  #$f0,d0 
    lsr.b  #2,d0
    move.l 0(a4,d0.w),(a5)
    move.b (a0)+,d0 
chet1:
    nop
    nop
    ror.l #1,d5
    ror.l #1,d7 
    bcc.s baf5
    swap  d5 
    and.l d2,(a1)
    or.l d3,(a1)+  
    and.l d2,(a1) 
    or.l d4,(a1)+  
    moveq       #0,d2     
    move.l      d2,d3 
    move.l      d2,d4 
baf5:
    and.b  #$f,d0
    lsl.b #2,d0
    move.l 0(a4,d0.w),(a6)
    move.b (a0),d0
chet2:
    nop
    nop
    dbf d1,bafx 
    btst #0,7(a3) 
    bne.s xpaiaf 
    move.l d7,d1 
    eor.l #$ffffffff,d1 
    and.l d1,d3 
    and.l d1,d4 
xpaiaf:
    tst.w filin 
    bne.s seclig 
    move.w #1,filin 
    move.w d7,d1 
    eor.w #$ffff,d1 
    move.w #$ffff,maskfi 
    btst #0,7(a3) 
    bne.s mepmafi 
    rol.w #1,d1 
    bcc.s seclig 
mepmafi:
    and.w d1,maskfi 
    rol.w #1,d1 
    bcs.s mepmafi 
seclig:
    or.w maskfi(pc),d2
    swap d2
    or.w maskfi(pc),d2 
    and.l d2,(a1) 
    or.l d3,(a1)+  
    and.l d2,(a1) 
    or.l d4,(a1)+ 
    moveq       #0,d3 
    moveq       #0,d4 
    move.w maskdeb(pc),d2
    swap  d2
    move.w maskdeb(pc),d2 
    addi.l #160,(a3)
    move.l (a3),a1 
    move.w 4(a3),d7
    swap   d7
    move.l d7,d5
    clr.w  d5
    move.w 4(a3),d7 
    move.w 6(a3),d1 
    lsr.w #1,d1 
    move.b (a0),d0
    subq.w #1,boucy 
    bge bitaf
atcara:
    subi.b #1,nbcar
    ble.s atcara1
    move.l adfi(pc),a4
    clr.l d0
    move.w (a4),d0
    add.w 2(a4),d0
    add.l #15,d0
    bclr #0,d0
    add.l d0,adfi
    bra inicont
atcara1:
    movem.l (sp)+,d0-d7/a0-a6
    move.l (a7),24(a7)
    add.l #24,a7
    rts
codanim:
        or.l    d7,d2
        nop
tabinst:        ds.l    64
tabins2: 
        nop             ;0000
        nop
        nop             ;0001
        or.w    d7,d4
        nop             ;0010
        or.l    d5,d4
        nop             ;0011
        or.l    d7,d4
        or.w    d7,d3   ;0100
        nop
        or.w    d7,d3   ;0101
        or.w    d7,d4
        or.w    d7,d3   ;0110
        or.l    d5,d4
        or.w    d7,d3   ;0111
        or.l    d7,d4
        or.l    d5,d3   ;1000
        nop
        or.l    d5,d3   ;1001
        or.w    d7,d4
        or.l    d5,d3   ;1010
        or.l    d5,d4
        or.l    d5,d3   ;1011
        or.l    d7,d4
        or.l    d7,d3   ;1100
        nop
        or.l    d7,d3   ;1101
        or.w    d7,d4
        or.l    d7,d3   ;1110
        or.l    d5,d4
        or.l    d7,d3   ;1111
        or.l    d7,d4
tabins3: 
        or.l    d7,d3   ;1111
        or.l    d7,d4
        or.l    d7,d3   ;1110
        or.l    d5,d4
        or.l    d7,d3   ;1101
        or.w    d7,d4
        or.l    d7,d3   ;1100
        nop
        or.l    d5,d3   ;1011
        or.l    d7,d4
        or.l    d5,d3   ;1010
        or.l    d5,d4
        or.l    d5,d3   ;1001
        or.w    d7,d4
        or.l    d5,d3   ;1000
        nop
        or.w    d7,d3   ;0111
        or.l    d7,d4
        or.w    d7,d3   ;0110
        or.l    d5,d4
        or.w    d7,d3   ;0101
        or.w    d7,d4
        or.w    d7,d3   ;0100
        nop
        nop             ;0011
        or.l    d7,d4
        nop             ;0010
        or.l    d5,d4
        nop             ;0001
        or.w    d7,d4
        nop             ;0000
        nop

remqut:
    clr.w d6
    clr.w d7
    move.b (a0),d7
    bchg #0,d0
    beq.s abq01
    addq.l #1,a0
    andi.b #$0f,d7
    bra.s abq02
abq01:
    lsr.b #4,d7
abq02:
    cmp.b #15,d7
    blt.s wbq02
bqut:
    clr.w d7
    move.b (a0),d7
    bchg #0,d0
    beq.s bq01
    addq.l #1,a0
    andi.b #$0f,d7
    bra.s bq02
bq01:
    lsr.b #4,d7
bq02:
    add.w d7,d6
    cmpi.b #15,d7
    beq.s bqut
    mulu #15,d6
    move.b (a0),d7
    bchg #0,d0
    beq.s wbq01
    addq.l #1,a0
    andi.b #$0f,d7
    bra.s wbq02
wbq01:
    lsr.b #4,d7
wbq02:
    add.w d7,d6
    subq.w #1,d6
    rts
repanac:
    move.l adanc(pc),a0
    move.l plcomp(pc),a1
    move.l a1,adcoc
    clr.b d1
    clr.b d0
    move.l adfi(pc),a5
    move.l a0,a4
    move.w (a5),d7
    ext.l d7
    adda.l d7,a4
    subq.l #1,a4
bgenc:
    bsr remqut
    move.w d6,d5
    bsr remqut
bremc:
    move.w d6,d4
    move.l a0,a2
    move.b d0,d3
bremc1:
    move.b (a2),d7
    bchg #0,d3
    beq.s bremc10
    addq.l #1,a2
    andi.b #$0f,d7
    bra.s bremc11
bremc10:
    lsr.b #4,d7
bremc11:
    bchg #0,d1
    beq.s bremc12
    or.b d7,(a1)+
    bra.s bremc13
bremc12:
    lsl.b #4,d7
    move.b d7,(a1)
bremc13:
    dbf d4,bremc1
    dbf d5,bremc
    move.l a2,a0
    move.b d3,d0
    cmpa.l a4,a0
    blt bgenc
    addq.l #1,a1
    move.l a1,tailcou
    move.l a1,adcomp
    rts
repanav:
    move.l adanq(pc),a0
    move.l tailcou(pc),a1
    move.l tailcou(pc),adcoq
    clr.b d0
    move.l adfi(pc),a5
    move.l a0,a4
    move.w 2(a5),d7
    ext.l d7
    adda.l d7,a4
    subq.l #1,a4
bgencb:
    bsr remqut
    move.w d6,d5
    bsr remqut
    btst #0,d0
    beq.s bremcb
    clr.b d0
    addq.l #1,a0
bremcb:
    move.w d6,d4
    move.l a0,a2
bremc1b:
    move.b (a2)+,(a1)+
    dbf d4,bremc1b
    dbf d5,bremcb
    move.l a2,a0
    cmpa.l a4,a0
    blt bgencb
    move.l a1,adcomp
    rts
dcomphl:
    bsr initb
dbyc1hl:
    move.w d7,d1
    subq.w #1,d1
dbxc1hl:
    dbf d5,ee00
    bsr tracoulb
ee00:
    move.b d4,(a0)
    dbf d5,ee01
    bsr tracoulb
ee01:
    or.b d3,(a0)+
    dbf d1,dbxc1hl
    dbf d0,dbyc1hl
    rts
dcompvl:
    bsr initb
    move.w 6(a3),d1
    move.l a0,16(a3)
dbxc1vl:
    move.w d0,d6
dbyc1vl:
    dbf d5,ee02
    bsr tracoulb
ee02:
    tst.l d7
    blt.s dremontl
    or.b d4,(a0)
    adda.l d7,a0
    bra.s dcomml
dremontl:
    or.b d3,(a0)
    suba.l d7,a0
dcomml:
    dbf d6,dbyc1vl
    neg.l d7
    tst.l d7
    blt.s dremocl
    addq.l #1,16(a3)
dremocl:
    move.l 16(a3),a0
    dbf d1,dbxc1vl
    rts
dcomph:
    lea.l zbuf(pc),a3
    clr.w 14(a3)
    bra hcomm
dcompv:
    bsr initb
    move.w 6(a3),d1
dbxc1v:
    move.w d0,d6
dbyc1v:
    dbf d5,ee03
    bsr tracoulb
ee03:
    tst.l d7
    blt.s dremont
    or.b d4,(a0)
    bra.s dcomm
dremont:
    or.b d3,(a0)
dcomm:
    adda.l d7,a0
    dbf d6,dbyc1v
    neg.l d7
    adda.l d7,a0
    tst.l d7
    blt.s dremoc
    addq.l #1,a0
dremoc:
    dbf d1,dbxc1v
    rts
dcomph1:
    lea.l zbuf(pc),a3
    move.w #1,14(a3)
    bra hcomm
dcompv1:
    bsr initb
    move.w 6(a3),d1
dbxc1v1:
    move.w d0,d6
dbyc1v1:
    dbf d5,ee04
    bsr tracoulb
ee04:
    or.b d4,(a0)
    tst.w d1
    beq.s dunig1
    dbf d5,ee05
    bsr tracoulb
ee05:
    or.b d3,(a0)
dunig1:
    tst.w d6
    beq.s dfunigd
    subq.w #1,d6
    adda.l d7,a0
    tst.w d1
    beq.s dunid1
    dbf d5,ee06
    bsr tracoulb
ee06:
    or.b d3,(a0)
dunid1:
    dbf d5,ee07
    bsr tracoulb
ee07:
    or.b d4,(a0)
dfunigd:
    adda.l d7,a0
    dbf d6,dbyc1v1
    neg.l d7
    adda.l d7,a0
    addq.l #1,a0
    subq.w #1,d1
    bge.s dd1nf
    clr.w d1
dd1nf:
    dbf d1,dbxc1v1
    rts
dcomph2:
    lea.l zbuf(pc),a3
    move.w #2,14(a3)
    bra hcomm
dcompv2:
    bsr initb
    move.w 6(a3),d1
dbxc1v2:
    move.w d0,d6
dbyc1v2:
    dbf d5,ee08
    bsr tracoulb
ee08:
    or.b d4,(a0)
    tst.w d1
    beq.s dunig2
    dbf d5,ee09
    bsr tracoulb
ee09:
    or.b d3,(a0)
    cmpi.w #1,d1
    beq.s dunig2
    dbf d5,ee10
    bsr tracoulb
ee10:
    or.b d4,1(a0)
    cmpi.w #2,d1
    beq.s dunig2
    dbf d5,ee11
    bsr tracoulb
ee11:
    or.b d3,1(a0)
dunig2:
    tst.w d6
    beq.s dfunigd2
    subq.w #1,d6
    adda.l d7,a0
    tst.w d1
    beq.s dunid23
    cmpi.w #1,d1
    beq.s dunid22
    cmpi.w #2,d1
    beq.s dunid21
    dbf d5,ee12
    bsr tracoulb
ee12:
    or.b d3,1(a0)
dunid21:
    dbf d5,ee13
    bsr tracoulb
ee13:
    or.b d4,1(a0)
dunid22:
    dbf d5,ee14
    bsr tracoulb
ee14:
    or.b d3,(a0)
dunid23:
    dbf d5,ee15
    bsr tracoulb
ee15:
    or.b d4,(a0)
dfunigd2:
    adda.l d7,a0
    dbf d6,dbyc1v2
    neg.l d7
    adda.l d7,a0
    addq.l #2,a0
    subq.w #3,d1
    bge.s dd1nf2
    clr.w d1
dd1nf2:
    dbf d1,dbxc1v2
    rts
dcomph3:
    lea.l zbuf(pc),a3
    move.w #3,14(a3)
    bra.s hcomm
dcomph4:
    lea.l zbuf(pc),a3
    move.w #5,14(a3)
hcomm:
    bsr initb
dbyc1h4:
    move.w d7,d1
    subq.w #1,d1
dbxc1h4:
    tst.l d6
    blt dpartdr4
    dbf d5,ee16
    bsr tracoulb
ee16:
    or.b d4,(a0)
    tst.w d0
    beq dgniv4
    tst.w 14(a3)
    beq dgniv4
    dbf d5,ee17
    bsr tracoulb
ee17:
    or.b d4,0(a0,d7.w)
    cmpi.w #1,d0
    beq dgniv40
    cmpi.w #1,14(a3)
    beq dgniv40
    dbf d5,ee18
    bsr tracoulb
ee18:
    adda.l d7,a0
    or.b d4,0(a0,d7.w)
    cmpi.w #2,d0
    beq dgniv41
    cmpi.w #2,14(a3)
    beq dgniv41
    dbf d5,ee19
    bsr tracoulb
ee19:
    adda.l d7,a0
    or.b d4,0(a0,d7.w)
    cmpi.w #3,d0
    beq.s dgniv42
    cmpi.w #3,14(a3)
    beq.s dgniv42
    dbf d5,ee20
    bsr tracoulb
ee20:
    adda.l d7,a0
    or.b d4,0(a0,d7.w)
    cmpi.w #4,d0
    beq.s dgniv43
    dbf d5,ee21
    bsr tracoulb
ee21:
    adda.l d7,a0
    or.b d4,0(a0,d7.w)
    dbf d5,ee22
    bsr tracoulb
ee22:
    or.b d3,0(a0,d7.w)
    suba.l d7,a0
dgniv43:
    dbf d5,ee23
    bsr tracoulb
ee23:
    or.b d3,0(a0,d7.w)
    suba.l d7,a0
dgniv42:
    dbf d5,ee24
    bsr tracoulb
ee24:
    or.b d3,0(a0,d7.w)
    suba.l d7,a0
dgniv41:
    dbf d5,ee25
    bsr tracoulb
ee25:
    or.b d3,0(a0,d7.w)
    suba.l d7,a0
dgniv40:
    dbf d5,ee26
    bsr tracoulb
ee26:
    or.b d3,0(a0,d7.w)
dgniv4:
    dbf d5,ee27
    bsr tracoulb
ee27:
    or.b d3,(a0)
    bra dpartcom4
dpartdr4:
    dbf d5,ee28
    bsr tracoulb
ee28:
    or.b d3,(a0)
    tst.w d0
    beq ddniv4
    tst.w 14(a3)
    beq ddniv4
    dbf d5,ee29
    bsr tracoulb
ee29:
    or.b d3,0(a0,d7.w)
    cmpi.w #1,d0
    beq ddniv40
    cmpi.w #1,14(a3)
    beq ddniv40
    adda.l d7,a0
    dbf d5,ee30
    bsr tracoulb
ee30:
    or.b d3,0(a0,d7.w)
    cmpi.w #2,d0
    beq ddniv41
    cmpi.w #2,14(a3)
    beq ddniv41
    adda.l d7,a0
    dbf d5,ee31
    bsr tracoulb
ee31:
    or.b d3,0(a0,d7.w)
    cmpi.w #3,d0
    beq.s ddniv42
    cmpi.w #3,14(a3)
    beq.s ddniv42
    adda.l d7,a0
    dbf d5,ee32
    bsr tracoulb
ee32:
    or.b d3,0(a0,d7.w)
    cmpi.w #4,d0
    beq.s ddniv43
    adda.l d7,a0
    dbf d5,ee33
    bsr tracoulb
ee33:
    or.b d3,0(a0,d7.w)
    dbf d5,ee34
    bsr tracoulb
ee34:
    or.b d4,0(a0,d7.w)
    suba.l d7,a0
ddniv43:
    dbf d5,ee35
    bsr tracoulb
ee35:
    or.b d4,0(a0,d7.w)
    suba.l d7,a0
ddniv42:
    dbf d5,ee36
    bsr tracoulb
ee36:
    or.b d4,0(a0,d7.w)
    suba.l d7,a0
ddniv41:
    dbf d5,ee37
    bsr tracoulb
ee37:
    or.b d4,0(a0,d7.w)
    suba.l d7,a0
ddniv40:
    dbf d5,ee38
    bsr tracoulb
ee38:
    or.b d4,0(a0,d7.w)
ddniv4:
    dbf d5,ee39
    bsr tracoulb
ee39:
    or.b d4,(a0)
dpartcom4:
    adda.l d6,a0
    dbf d1,dbxc1h4
    sub.w 14(a3),d0
    bge.s dd0nf4
    clr.w d0
dd0nf4:
    adda.l d7,a0
    tst.w 14(a3)
    beq.s addfin
    adda.l d7,a0
    cmpi.w #1,14(a3)
    beq.s addfin
    adda.l d7,a0
    cmpi.w #2,14(a3)
    beq.s addfin
    adda.l d7,a0
    cmpi.w #3,14(a3)
    beq.s addfin
    adda.l d7,a0
    adda.l d7,a0
addfin:
    neg.l d6
    adda.l d6,a0
    dbf d0,dbyc1h4
    rts
dcompdi:
    bsr initb
    clr.w d0
    clr.w d1
    move.w 6(a3),ppt
    move.w 8(a3),pga
    move.w 6(a3),savbcg
    move.w 8(a3),d6
    cmp.w 6(a3),d6
    bge.s zdiboa
    move.w 8(a3),ppt
    move.w 6(a3),pga
zdiboa:
    add.w d6,savbcg
    clr.w savbc1
    clr.w d6
    bra.s ddiok
ddiabc:
    adda.l d7,a0
    bchg #0,d0
    beq.s ddipach
    addq.l #1,a0
ddipach:
    tst.l d7
    blt.s ddiok
    subq.l #1,a0
ddiok:
    dbf d5,ee40
    bsr tracoulb
ee40:
    tst.b d0
    bne.s ddicd
       or.b     d4,(a0)
       dbf      d6,ddiabc
        bra.s   sddicd
ddicd:
    or.b d3,(a0)
    dbf d6,ddiabc
sddicd:
    addq.w #1,d1
    cmp.w savbcg(pc),d1
    bgt ddifin
    cmp.w ppt(pc),d1
    bgt.s ddipac1
    add.w #1,savbc1
ddipac1:
    cmp.w pga(pc),d1
    ble.s ddipac2
    sub.w #1,savbc1
ddipac2:
    tst.l d7
    bge.s ddirem
    cmp.w 6(a3),d1
    ble.s ddipl1
    sub.l d7,a0
    bra.s ddicom1
ddipl1:
    bchg #0,d0
    beq.s ddicom1
    addq.l #1,a0
    bra.s ddicom1
ddirem:
    cmp.w 8(a3),d1
    bgt.s ddipl2
    add.l d7,a0
    bra.s ddicom1
ddipl2:
    bchg #0,d0
    beq.s ddicom1
    addq.l #1,a0
ddicom1:
    neg.l d7
    move.w savbc1(pc),d6
    bra ddiok
ddifin:
    rts
dcomdh0:
    bsr initb
dbyc1h1i:
    move.w d7,d1
    subq.w #1,d1
dbxc1h1i:
    tst.l d6
    blt.s dpartdri
    dbf d5,ee41
    bsr tracoulb
ee41:
    or.b d4,(a0)
    tst.w d0
    beq.s dgniv1i
    dbf d5,ee42
    bsr tracoulb
ee42:
    or.b d3,0(a0,d7.w)
    bra.s dpartcoi
dgniv1i:
    dbf d5,ee43
    bsr tracoulb
ee43:
    or.b d3,(a0)
    bra.s dpartcoi
dpartdri:
    dbf d5,ee44
    bsr tracoulb
ee44:
    or.b d3,(a0)
    dbf d5,ee45
    bsr tracoulb
ee45:
    or.b d4,0(a0,d7.w)
dpartcoi:
    adda.l d6,a0
    dbf d1,dbxc1h1i
    tst.l d6
    bge.s daaddoo
    adda.l d7,a0
    adda.l d7,a0
daaddoo:
    neg.l d6
    adda.l d6,a0
    dbf d0,dbyc1h1i
    rts
dcomdv1:
    bsr initb
    move.w 6(a3),d1
dbxd1v1:
    move.w d0,d6
dbyd1v1:
    dbf d5,ee46
    bsr tracoulb
ee46:
    or.b d4,(a0)
    tst.w d1
    beq.s dundig1
    tst.w d6
    beq.s dundih1
    adda.l d7,a0
    dbf d5,ee47
    bsr tracoulb
ee47:
    or.b d3,(a0)
    suba.l d7,a0
dundih1:
    dbf d5,ee48
    bsr tracoulb
ee48:
    or.b d3,(a0)
dundig1:
    tst.w d6
    beq.s dfundigd
    subq.w #1,d6
    adda.l d7,a0
    dbf d5,ee49
    bsr tracoulb
ee49:
    or.b d4,(a0)
dfundigd:
    adda.l d7,a0
    dbf d6,dbyd1v1
    neg.l d7
    adda.l d7,a0
    addq.l #1,a0
    subq.w #1,d1
    bge.s dd1dnf
    clr.w d1
dd1dnf:
    dbf d1,dbxd1v1
    rts
dcomdv2:
    bsr initb
    move.w 6(a3),d1
dbxd1v2:
    move.w d0,d6
dbyd1v2:
    dbf d5,ee50
    bsr tracoulb
ee50:
    or.b d4,(a0)
    tst.w d1
    beq.s dundig2
    tst.w d6
    beq.s donfaca
    adda.l d7,a0
    dbf d5,ee51
    bsr tracoulb
ee51:
    or.b d3,(a0)
    suba.l d7,a0
    bra.s dfofaca
donfaca:
    dbf d5,ee52
    bsr tracoulb
ee52:
    or.b d3,(a0)
dfofaca:
    cmpi.w #1,d1
    beq.s dundig2
    dbf d5,ee53
    bsr tracoulb
ee53:
    or.b d4,1(a0)
    cmpi.w #2,d1
    beq.s dundig2
    tst.w d6
    beq.s donfaca1
    adda.l d7,a0
    dbf d5,ee54
    bsr tracoulb
ee54:
    or.b d3,1(a0)
    suba.l d7,a0
    bra.s dundig2
donfaca1:
    dbf d5,ee55
    bsr tracoulb
ee55:
    or.b d3,1(a0)
dundig2:
    tst.w d6
    beq.s dfundig2
    subq.w #1,d6
    adda.l d7,a0
    tst.w d1
    beq.s dundid23
    cmpi.w #1,d1
    beq.s dundid22
    cmpi.w #2,d1
    beq.s dundid21
    suba.l d7,a0
    dbf d5,ee56
    bsr tracoulb
ee56:
    or.b d3,1(a0)
    adda.l d7,a0
dundid21:
    dbf d5,ee57
    bsr tracoulb
ee57:
    or.b d4,1(a0)
dundid22:
    suba.l d7,a0
    dbf d5,ee58
    bsr tracoulb
ee58:
    or.b d3,(a0)
    adda.l d7,a0
dundid23:
    dbf d5,ee59
    bsr tracoulb
ee59:
    or.b d4,(a0)
dfundig2:
    adda.l d7,a0
    dbf d6,dbyd1v2
    neg.l d7
    adda.l d7,a0
    addq.l #2,a0
    subq.w #3,d1
    bge.s dd1ndf2
    clr.w d1
dd1ndf2:
    dbf d1,dbxd1v2
    rts
dcomdh1:
    lea.l zbuf(pc),a3
    move.w #1,14(a3)
    bra hdomm
dcomdh2:
    lea.l zbuf(pc),a3
    move.w #2,14(a3)
    bra hdomm
dcomdh3:
    lea.l zbuf(pc),a3
    move.w #3,14(a3)
    bra hdomm
dcomdh4:
    lea.l zbuf(pc),a3
    move.w #5,14(a3)
hdomm:
    bsr initb
dbyd1h4:
    move.w d7,d1
    subq.w #1,d1
dbxd1h4:
    tst.l d6
    blt dparddr4
    dbf d5,ee60
    bsr tracoulb
ee60:
    or.b d4,(a0)
    tst.w d0
    beq dgndiv4
    dbf d5,ee61
    bsr tracoulb
ee61:
    or.b d3,0(a0,d7.w)
    cmpi.w #1,d0
    beq dgndiv40
    cmpi.w #1,14(a3)
    beq  dgndiv40
    dbf d5,ee62
    bsr tracoulb
ee62:
    adda.l d7,a0
    or.b d4,0(a0,d7.w)
    cmpi.w #2,d0
    beq.s dgndiv41
    cmpi.w #2,14(a3)
    beq.s dgndiv41
    dbf d5,ee63
    bsr tracoulb
ee63:
    adda.l d7,a0
    or.b d3,0(a0,d7.w)
    cmpi.w #3,d0
    beq.s dgndiv42
    cmpi.w #3,14(a3)
    beq.s dgndiv42
    dbf d5,ee64
    bsr tracoulb
ee64:
    adda.l d7,a0
    or.b d4,0(a0,d7.w)
    cmpi.w #4,d0
    beq.s dgndiv43
    dbf d5,ee65
    bsr tracoulb
ee65:
    adda.l d7,a0
    or.b d3,0(a0,d7.w)
    dbf d5,ee66
    bsr tracoulb
ee66:
    or.b d4,0(a0,d7.w)
    suba.l d7,a0
dgndiv43:
    dbf d5,ee67
    bsr tracoulb
ee67:
    or.b d3,0(a0,d7.w)
    suba.l d7,a0
dgndiv42:
    dbf d5,ee68
    bsr tracoulb
ee68:
    or.b d4,0(a0,d7.w)
    suba.l d7,a0
dgndiv41:
    dbf d5,ee69
    bsr tracoulb
ee69:
    or.b d3,0(a0,d7.w)
    suba.l d7,a0
dgndiv40:
    dbf d5,ee70
    bsr tracoulb
ee70:
    or.b d4,0(a0,d7.w)
dgndiv4:
    dbf d5,ee71
    bsr tracoulb
ee71:
    or.b d3,(a0)
    bra dpardcom4
dparddr4:
    dbf d5,ee72
    bsr tracoulb
ee72:
    or.b d3,(a0)
    tst.w d0
    beq ddndiv4
    dbf d5,ee73
    bsr tracoulb
ee73:
    or.b d4,0(a0,d7.w)
    cmpi.w #1,d0
    beq ddndiv40
    cmpi.w #1,14(a3)
    beq  ddndiv40
    adda.l d7,a0
    dbf d5,ee74
    bsr tracoulb
ee74:
    or.b d3,0(a0,d7.w)
    cmpi.w #2,d0
    beq.s ddndiv41
    cmpi.w #2,14(a3)
    beq.s ddndiv41
    adda.l d7,a0
    dbf d5,ee75
    bsr tracoulb
ee75:
    or.b d4,0(a0,d7.w)
    cmpi.w #3,d0
    beq.s ddndiv42
    cmpi.w #3,14(a3)
    beq.s ddndiv42
    adda.l d7,a0
    dbf d5,ee76
    bsr tracoulb
ee76:
    or.b d3,0(a0,d7.w)
    cmpi.w #4,d0
    beq.s ddndiv43
    adda.l d7,a0
    dbf d5,ee77
    bsr tracoulb
ee77:
    or.b d4,0(a0,d7.w)
    dbf d5,ee78
    bsr tracoulb
ee78:
    or.b d3,0(a0,d7.w)
    suba.l d7,a0
ddndiv43:
    dbf d5,ee79
    bsr tracoulb
ee79:
    or.b d4,0(a0,d7.w)
    suba.l d7,a0
ddndiv42:
    dbf d5,ee80
    bsr tracoulb
ee80:
    or.b d3,0(a0,d7.w)
    suba.l d7,a0
ddndiv41:
    dbf d5,ee81
    bsr tracoulb
ee81:
    or.b d4,0(a0,d7.w)
    suba.l d7,a0
ddndiv40:
    dbf d5,ee82
    bsr tracoulb
ee82:
    or.b d3,0(a0,d7.w)
ddndiv4:
    dbf d5,ee83
    bsr tracoulb
ee83:
    or.b d4,(a0)
dpardcom4:
    adda.l d6,a0
    dbf d1,dbxd1h4
    sub.w 14(a3),d0
    bge.s dd0dnf4
    clr.w d0
dd0dnf4:
    adda.l d7,a0
    adda.l d7,a0
    cmpi.w #1,14(a3)
    beq.s daddfin
    adda.l d7,a0
    cmpi.w #2,14(a3)
    beq.s daddfin
    adda.l d7,a0
    cmpi.w #3,14(a3)
    beq.s daddfin
    adda.l d7,a0
    adda.l d7,a0
daddfin:
    neg.l d6
    adda.l d6,a0
    dbf d0,dbyd1h4
    rts
initb:
    lea.l zbuf(pc),a3
    move.l adcoq(pc),a1
    move.l adcoc(pc),a2
    move.w 8(a3),d0
    clr.l d7
    move.w 6(a3),d7
    addq.w #2,d7
    lsr.w #1,d7
        move.l  adcomp(pc),a0
        move.l  a0,d5
        btst    #0,d5
        beq.s   dapair
        clr.b   (a0)+
dapair: move.w  d7,d5
        mulu    d0,d5
        add.l   d7,d5
        addq.l  #4,d5
        lsr.l   #6,d5
        moveq   #0,d6
bef:    move.l  d6,(a0)+
        move.l  d6,(a0)+
        move.l  d6,(a0)+
        move.l  d6,(a0)+
        move.l  d6,(a0)+
        move.l  d6,(a0)+
        move.l  d6,(a0)+
        move.l  d6,(a0)+
        move.l  d6,(a0)+
        move.l  d6,(a0)+
        move.l  d6,(a0)+
        move.l  d6,(a0)+
        move.l  d6,(a0)+
        move.l  d6,(a0)+
        move.l  d6,(a0)+
        move.l  d6,(a0)+
        dbf     d5,bef
    move.l #1,d6
    move.l adcomp(pc),a0
    clr.l d5
    clr.b d2
    rts
tracoulb:
    clr.w d5
    clr.w d4
bchgtco:
    bchg #1,d2
    beq.s demgau
    move.b (a1)+,d4
    andi.b #$0f,d4
    bra.s demfin
demgau:
    move.b (a1),d4
    lsr.b #4,d4
demfin:
    add.w d4,d5
    cmpi.b #$0f,d4
    beq.s bchgtco
    bchg #0,d2
    beq.s pcada2
    move.b (a2)+,d3
    andi.b #$0f,d3
        move.b  d3,d4
        lsl.b   #4,d4
        subq.w  #1,d5
        rts
pcada2:
    move.b (a2),d3
        move.b  d3,d4
        and.b   #$f0,d4
    lsr.b #4,d3
        subq.w  #1,d5
        rts
tabadcb:
    bra atcara
    bra dcomph
    bra dcompv
    bra dcomph1
    bra dcompv1
    bra dcomph2
    bra dcompv2
    bra dcomphl
    bra dcompvl
    bra dcomph3
    bra dcomph4
    bra dcompdi
    bra dcomdh1
    bra dcomdh0
    bra dcomdv1
    bra dcomdh2
    bra dcomdv2
    bra dcomdh3
    bra dcomdh4
    bra atcara

flsprite:       dc.l    0
adfi:  dc.l 0
xcoor: dc.w 0
ycoor: dc.w 0
tailx:  ds.w  1
taily:  ds.w  1
adcomp:   dc.l  0
adecr:  dc.l    0
adcoc:    dc.l  0
adcoq:    dc.l  0
adanc:    dc.l  0
adanq:    dc.l  0
plcomp:   dc.l  0
plaff:    dc.l  0
tailcou:  dc.l  0
typfi:    dc.b 0
nbcar:    dc.b 0
filin:    dc.w 0
boucy:    dc.w 0
maskdeb:  dc.w 0
maskfi:   dc.w 0
ppt:      dc.w 0
pga:      dc.w 0
savbcg:   dc.w 0
savbc1:   dc.w 0
zbuf:           ds.l    6

;********* ROUT TEST CRASH  
;       A4 EN ENTREE SUR OCNUR
;       SORTIE
;       D7      NO DE RT CRAS OU ZERO
;       D4      -1=GCHE  0=CTRE  1  DRTE
tstcra:
        move.l  #LOGEQU,a0   ;adr du fichier logi
        clr.w   d0
        move.b  (a4),d0      ;pointe sur ocnur
        cmp.w   #200,d0
        bge     cra3d
        add.w   d0,d0
        add.w   0(a0,d0.w),a0
        clr.w   d7      ;init cras
        move.b  (a0),d7
        beq.s   adrcra
        move.b  1(a0),pasfr+13  ;volum objet
        tst.w   JUMPE+2
        blt.s   paju
        bclr    #6,d7
        bne.s   paju
        cmp.w   #-188,htprl
        blt.s   fcra
paju:   bclr    #6,d7
        move.b  7(a0),d0    ;no phys
        ext.w   d0
        bge.s   craobj
        bra     cravec
fcra:   clr.w   d7
adrcra: rts
adrcrf: clr.w   FROTT
        rts
craobj: lea.l   tabobj(pc),a0
        add.w   d0,d0
        add.w   d0,d0
        move.l  0(a0,d0.w),a0
        move.w  2(a0),d4
        subq.w  #1,d4

        move.l  a0,a1   ;seq
        move.l  a0,a2   ;obj
        add.w   2(a0),a0
        addq.w  #4,a0
        add.w   d4,d4
        add.w   (a0)+,a2
        add.w   6(a0,d4.w),a1
        clr.w   d0
        move.b  (a1)+,d0  ;no sprit
        lsl.w   #3,d0
        add.w   d0,a2
        clr.w   d0
        move.b  4(a2),d0    ;larg-1
creccr: move.w  XB,d2
        move.w  6(a4),d1
        blt.s   tgaob
        add.w   #255,d2
        bra.s   tgdob
tgaob:  sub.w   #255,d2
        sub.w   d0,d2
tgdob:  lsl.w   #1,d1
        asr.w   #1,d1
        add.w   d1,d2
        bsr     tcrcoo
;test demarr bruit blanc
tbrbl:  tst.w   d7
        bne.s   adrcro
tbrb1:  cmp.w   #176,pasfr+14
        bgt.s   adrcro
        tst.w   pasfr+12
        beq.s   adrcro
        cmp.b   #4,pasfr+8
        beq.s   adrcro
        move.w  #1,pasfr+16
adrcro: rts
tcrcoo: tst.w   d2
        blt.s   tcrga
        cmp.w   #80,d2
        bgt.s   patou1
tcrdr:  move.w  #80,d0
        sub.w   d2,d0
        lsr.w   #1,d0
        move.w  #80,d4
        sub.w   d0,d4
        rts
patou1: sub.w   #80,d2
patou2: clr.w   d7
        move.w  d2,pasfr+14
        rts
tcrga:  add.w   d0,d2
        cmp.w   #-80,d2
        bge.s   stcrg
        add.w   #80,d2
        neg.w   d2
        bra.s   patou2
stcrg:  cmp.w   #80,d2
        ble.s   tcrga1
        sub.w   d0,d2
        cmp.w   #-80,d2
        bge.s   tcrdr
        clr.w   d4
        rts
tcrga1: move.w  #-80,d0
        sub.w   d2,d0
        asr.w   #1,d0
        move.w  #-80,d4
        sub.w   d0,d4
touc:   rts
cra3d:  clr.w   d7
        cmp.b   #254,d0
        beq     sorcra
        sub.w   #220,d0
        lea.l   trtc3d(pc),a0
        move.b  0(a0,d0.w),d7
        bgt.s   psorc
        beq     sorcra
        clr.w   d7
        cmp.w   #10,d0
        beq     apsom
        clr.l   FROTT
        move.l  #CHRPAL,a0      ;aff pal norm
        move.l  -4(a0),4(a0)
        move.l  -4(a0),(a0)
        bra     sorcra
psorc:  cmp.b   #2,d7
        bne.s   psorcs
        moveq   #1,d7
        clr.l   FROTT
psorcs: move.b  14(a0,d0.w),d2
        beq.s   pafrot
        move.w  #1,FROTT
        and.w   #$ff,d2
        move.l  28(a0,d2.w),FROTT+4
pafrot: lea.l   tcra3d(pc),a0
        lsl.w   #3,d0
        add.w   d0,a0
        move.w  XB,d2
        add.w   (a0)+,d2
        move.w  (a0)+,d0
        blt.s   sorcra
        move.w  d7,d6
        bsr     tcrcoo
        tst.w   d7
        bne     adrcrf
        move.w  d6,d7
        move.w  XB,d2
        add.w   (a0)+,d2
        move.w  (a0),d0
        blt.s   sorcra
        bsr     tcrcoo
        tst.w   d7
        bne     adrcrf
apsom:  move.l  #CHRPAL+8,a0      ;aff pal sombre
        move.l  a0,-4(a0)
        move.l  a0,-8(a0)
        bra     adrcra
cravec: lea.l   tcrave(pc),a0
        neg.w   d0
        subq.w  #2,d0
        bge.s   crapv
sorcra: clr.w   d7
        bra     adrcra
sorcra1:        clr.w   d7
        bra     tbrb1
crapv:  cmp.w   #48,d0
        bge     crarec
        lsl.w   #3,d0
        add.w   d0,a0
        move.w  2(a0),d0    ;larg-1
        blt.s   sorcra
        move.w  XB,d2
        move.w  6(a4),d1
        blt.s   tgave
        add.w   #255,d2
        bra.s   tgdve
tgave:  sub.w   #255,d2
        sub.w   d0,d2
tgdve:  lsl.w   #1,d1
        asr.w   #1,d1
        add.w   d1,d2
        clr.w   d4
        add.w   (a0),d2
        bge.s   papal1
        moveq   #1,d4
papal1: lea.l   4(a0),a0
        move.w  d7,d6
        bsr     tcrcoo
        tst.w   d7
        bne     adrcra
        move.w  d6,d7
        move.w  2(a0),d0    ;larg-1
        blt.s   sorcra1
        move.w  pasfr+14,-(a7)
        move.w  XB,d2
        move.w  6(a4),d1
        blt.s   tgave1
        add.w   #255,d2
        bra.s   tgdve1
tgave1: sub.w   #255,d2
        sub.w   d0,d2
tgdve1: lsl.w   #1,d1
        asr.w   #1,d1
        add.w   d1,d2
        add.w   (a0),d2
        bge.s   papal2
        clr.w   d4
papal2: bsr     tcrcoo
        move.w  (a7)+,d1
        tst.w   d7
        bne     adrcra
        cmp.w   pasfr+14,d1
        bge.s   prdio
        move.w  d1,pasfr+14
prdio:  tst.w   d4
        beq     tbrb1
        lea.l   OCCUR,a0
        move.l  2(a0),d0
        ADD.L   SP1D,D0
        cmp.l   2(a4),d0
        blt     tbrb1
        move.l  #CHRPAL+8+30,a0      ;aff pal sombre
        move.l  a0,-38(a0)
        bra     tbrb1
crarec: sub.w   #48,d0
        add.w   d0,d0
        add.w   d0,d0
        lea.l   trect,a0
        move.w  2(a0,d0.w),d0
        bra     creccr
FROTT:  dc.w    0,0,0,0
trtc3d: dc.b    1,-1,1,2,1,0,1,0,1,-1,-1,-1,1,-1
        dc.b    4,0,8,0,0,0,0,0,4,0,0,0,4,0
tfrot:  dc.w    0,0,-239,239,-1999,590
tcra3d: DC.W    -829,510,319,510    ;AV PONT
        DC.W    0,-1,0,-1           ;AR PONT
        DC.W    510,160,0,-1        ;AV GARA
        DC.W    510,160,0,-1        ;AR GARA
        DC.W    0,-1,0,-1           ;AV TRBD
        DC.W    0,-1,0,-1           ;AR TRBD
        DC.W    0,-1,0,-1           ;AV TRBG
        DC.W    0,-1,0,-1           ;AR TRBG
        DC.W    -1279,960,319,960   ;AV PONT2
        DC.W    0,-1,0,-1           ;AR PONT2
        DC.W    0,-1,0,-1           ;AV PLAQ
        DC.W    0,-1,0,-1           ;AR PLAQ
        DC.W    -829,510,319,510    ;AV PNTR
        DC.W    0,-1,0,-1           ;AR PNTR
tcrave: DC.W    255,16,654,16   ;CADRA1
        DC.W    0,16,654,16   ;CADRA2
        DC.W    -255,16,654,16   ;CADRA3
        DC.W    255,16,654,16   ;CADRB1
        DC.W    0,16,654,16   ;CADRB2
        DC.W    -255,16,654,16   ;CADRB3
        DC.W    0,12,0,-1       ;LAMPA16
        DC.W    0,6,0,-1        ;LAMPA8 
        DC.W    0,16,0,-1       ;LAMPB16
        DC.W    0,6,0,-1        ;LAMPB8
        DC.W    0,32,0,-1       ;PDBL1 
        DC.W    0,64,0,-1       ;PDBL2
        DC.W    0,96,0,-1       ;PDBL3
        DC.W    0,6,0,-1        ;PSPL1
        DC.W    0,6,0,-1        ;PSPL2
        DC.W    0,6,0,-1        ;PSPL3
        DC.W    0,16,0,-1       ;LAMPC16
        DC.W    0,80,0,-1       ;PDBL4
        DC.W    0,120,0,-1       ;PDBL5 
        DC.W    0,160,0,-1       ;PDBL6
        DC.W    0,200,0,-1       ;PDBL7

*CHARGT DES OBJETS LOG
rdlog:  move.l  #LOGEQU,a0   ;adr du fichier logi
        move.w  nolog,d0
        cmp.w   #200,d0
        bge.s   ESSER
        add.w   d0,d0
        move.w  0(a0,d0.w),d0
        beq.s   ESSER
        add.w   d0,a0
        clr.w   d0
        move.b  6(a0),d0
        bne.s   yaob
ESSER:  rts
yaob:   clr.w   d1
        move.b  7(a0),d1
        blt.s   syaob
        move.w  d1,naobj
        movem.l a0/d0,-(a7)
        jsr     iniobj
        movem.l (a7)+,d0/a0
syaob:  addq.w  #8,a0
        subq.w  #2,d0
        bge.s   byaob
        rts
byaob:  clr.w   d1
        move.b  (a0),d1
        blt.s   s1yaob
        move.w  d1,naobj
        movem.l a0/a1/d0,-(a7)
        jsr     iniobj
        movem.l (a7)+,d0/a0/a1
s1yaob: lea.l   4(a0),a0
        dbf     d0,byaob
        rts
;data pour vroom
EFSP:   dc.w    0
coorbas: dc.l   0,0,0,0,0,0
nolog:  dc.w    0
naobj:  dc.w    0
adhaut: dc.l    0
tabobj: ds.l    128
        END



