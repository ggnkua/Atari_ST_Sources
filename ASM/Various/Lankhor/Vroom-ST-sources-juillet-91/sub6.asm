        TTL     SUB6 - ROUTE - V13 - 06 Jul 91

* DM06JUL : NO3C
*NO3C    DC.W    0
*        DC.W    0
        INCLUDE "EQU.ASM"     
        
        XDEF    degre,figam,evnmo,evnco,adscrol,esevt1,mvtscrol
        XDEF    topcod,admodr,vitco,topvib,reste,haldco,decaco
        XDEF    CMPROD,DSPROD,adsky,volant,htprl,F1DEP,MODTAB,DCHAMP

        XREF    MGAME,OCCUR,CURSCR,CARSRT,JUMPE,CRASHE,ACCEL,RPMIN,rapport
        XREF    Y1,XB,FEVTAD,LAP,CRCLAP,F1SRT,HAUT,rtsvoit,PANIM,nouson
        XREF    FROTT,TIRUSE,MCOMM

LIMFRN  EQU     -10000
MADE:   EQU     32
MIDE:   EQU     -32
DECPL:  EQU     8
HAUTEUR: EQU    -128
DEMAR:  EQU     -65

VMSUP:  EQU     5
VCSUP:  EQU     7
MINSUP: EQU     21000  ;980*32
CINSUP: EQU     980*128
VCOSUP: EQU     880*128
MAXECR: EQU     690

OCCENT: EQU     32
OCNMSK: EQU     $3FF

objdiv: move.w  (a0),d2
        btst    #3,d2
        bne     objdivr
        addq.w  #4,adgam+6
        and.w   #$003f,adgam+6
        move.w  (a0),d2
        and.w   #$4,d2
        lsr.w   #1,d2
        move.w  d2,colban
        bra     procevt
objdivr:
        and.w   #$fffc,d2
        move.w  d2,comodr
        move.l  betrou1(pc),etrou1
        move.l  betrou2(pc),etrou2
        move.w  d7,depmod
        bra     procevt1
vo3ou:  move.w  4(a3),d5
        sub.w   depmod(pc),d5
        lsr.w   #1,d5
        cmp.w   #2677,d5
        ble.s   pacht1
        clr.w   comodr
        move.w  #2677,d5
pacht1: move.l  admodr(pc),a5
        move.b  0(a5,d5.w),d5
        and.w   #$ff,d5
        mulu    d2,d5
        lsr.l   #8,d5
        sub.w   d5,-8(a0)
        tst.b   -1(a0)
        bne.s   pa2b
        move.b  #-2,-2(a0)
pa2b:   movem.l (sp)+,d5/a5
        rts
vo3fe:  move.w  depmod(pc),d5
        sub.w   4(a3),d5
        asr.w   #1,d5
        cmp.w   #-2678,d5
        bge.s   pacht2
        move.l  metrou1(pc),etrou1
        move.l  metrou2(pc),etrou2
        move.w  #-2678,d5
pacht2: move.l  admodr(pc),a5
        add.w   #2678,a5
        move.b  0(a5,d5.w),d5
        and.w   #$ff,d5
        mulu    d2,d5
        lsr.l   #8,d5
        sub.w   d5,-8(a0)
        tst.b   -1(a0)
        bne.s   pa2b1
        move.b  #-2,-2(a0)
pa2b1:  movem.l (sp)+,d5/a5
        rts
vo3co:  
        tst.b   -1(a0)
        bne.s   pa2b2
        move.b  #-2,-2(a0)
pa2b2:  sub.w   d2,-8(a0)
        movem.l (sp)+,d5/a5
        rts
garou:  move.w  4(a3),d5
        sub.w   depmod(pc),d5
        lsr.w   #1,d5
        cmp.w   #2677,d5
        ble.s   pacht5
        move.w  #$20,comodr
        move.w  #2677,d5
pacht5: move.l  admodr(pc),a5
        move.b  0(a5,d5.w),d5
        and.w   #$ff,d5
        mulu    d2,d5
        lsr.l   #8,d5
        add.w   d5,-6(a0)
        tst.b   -1(a0)
        bne.s   pa2bg
        move.b  #-1,-2(a0)
pa2bg:  movem.l (sp)+,d5/a5
        rts
garfe:  move.w  depmod(pc),d5
        sub.w   4(a3),d5
        asr.w   #1,d5
        cmp.w   #-2678,d5
        bge.s   pacht6
        move.l  metrou1(pc),etrou1
        move.l  metrou2(pc),etrou2
        move.w  #-2678,d5
pacht6: move.l  admodr(pc),a5
        add.w   #2678,a5
        move.b  0(a5,d5.w),d5
        and.w   #$ff,d5
        mulu    d2,d5
        lsr.l   #8,d5
        add.w   d5,-6(a0)
        tst.b   -1(a0)
        bne.s   pa2b1g
        move.b  #-1,-2(a0)
pa2b1g: movem.l (sp)+,d5/a5
        rts
garco:
        tst.b   -1(a0)
        bne.s   pa2b1c
        move.b  #-1,-2(a0)
pa2b1c: add.w   d2,-6(a0)
        movem.l (sp)+,d5/a5
        rts
chiou:  move.w  4(a3),d5
        sub.w   depmod(pc),d5
        lsr.w   #1,d5
        cmp.w   #2677,d5
        ble.s   pacht3
        move.w  #4,comodr
        move.w  #2677,d5
pacht3: move.l  admodr(pc),a5
        move.b  0(a5,d5.w),d5
        and.w   #$ff,d5
        mulu    d2,d5
        lsr.l   #8,d5
        add.w   d5,-8(a0)
        move.b  #1,-2(a0)
        movem.l (sp)+,d5/a5
        rts
chife:  move.w  depmod(pc),d5
        sub.w   4(a3),d5
        asr.w   #1,d5
        cmp.w   #-2678,d5
        bge.s   pacht4
        move.l  metrou1(pc),etrou1
        move.l  metrou2(pc),etrou2
        move.w  #-2678,d5
pacht4: move.l  admodr(pc),a5
        add.w   #2678,a5
        move.b  0(a5,d5.w),d5
        and.w   #$ff,d5
        mulu    d2,d5
        lsr.l   #8,d5
        add.w   d5,-8(a0)
        move.b  #1,-2(a0)
        movem.l (sp)+,d5/a5
        rts
chico:  
        add.w   d2,-8(a0)
        move.b  #1,-2(a0)
        movem.l (sp)+,d5/a5
        rts
metrou1:        dc.l    $30fa0146
metrou2:        dc.l    $30fa011C
betrou1:        dc.l    $61000148
betrou2:        dc.l    $6100011E
* CMPROD - Stripes and Road Computation

;  TRT TABLES MULTIPL
MODTAB:
        MOVE.W  D0,D1
        ADD.W   D1,D1
        LEA.L   VCHAMP(pc),A0
        MOVE.W  0(A0,D1.W),DCHAMP
        MOVE.L  #JLLEQU,A0
        MOVE.L  #TCHAMP,A1
        SWAP    D0
        CLR.W   D0
        LSR.L   #6,D0
        ADD.W   D0,A1
        MOVE.W  (A1),D1
        MOVE.W  D1,D0
        MOVE.W  #254,D2
        SUB.W   D1,D2
        SUBQ.W  #1,D0
        ADD.W   D1,D1
        ADD.W   D1,A1
B1CHCH: MOVE.W  (A1),(A0)+
        MOVE.W  #$7FFF,(A0)+
        DBF     D0,B1CHCH
        ADDQ.W  #2,A1
        MOVE.W  #32768-128,D1
BCHCH:  MOVE.W  (A1)+,(A0)+
        MOVE.W  D1,(A0)+
        SUB.W   #128,D1
        DBF     D2,BCHCH
        ADDQ.W  #4,A0
        MOVE.W  #255,D2
B2CHCH: MOVE.W  (A1)+,(A0)+
        DBF     D2,B2CHCH
        RTS

CMPROD: 
        jsr     rtsvoit
        move.l  #JLLEQU+2050+16004,admodr
        move.l  FEVTAD(pc),a0
        move.l  Y1(pc),posvoit
        tst.w   LAP
        beq.s   pchtour
        move.l  CRCLAP(pc),d0
        add.l   d0,posvoit
pchtour:
        moveq   #0,d2
        move.w  F1DEP(pc),d2
        tst.w   topmod
        beq.s   pamodro
        blt.s   tmodco
        sub.w   d2,topdep
        cmp.w   #-5356,topdep
        bgt.s   t0modc
        move.w  topcod(pc),d3
        btst    #4,d3
        beq.s   oumod
        clr.w   topmod
        bra.s   pamodro
oumod:  move.w  #-1,topmod
        move.w  #4,topcod
        btst    #2,d3
        beq.s   t0modc
        clr.w   topcod
        btst    #5,d3
        beq.s   t0modc
        move.w  #$20,topcod
t0modc: move.w  topdep(pc),depmod
tmodco: move.l  betrou1(pc),etrou1
        move.l  betrou2(pc),etrou2
        move.w  topcod(pc),comodr
        bra.s   fmodro
pamodro:
        move.l  metrou1(pc),etrou1
        move.l  metrou2(pc),etrou2
fmodro:
        clr.w   FROTT+2
        tst.w   MGAME+2
        bne     angul
; mode parallele
        clr.w   d5
        tst.w   JUMPE+2
        blt.s   angno2
        bgt.s   pabnd2
        move.w  #2,NSON
pabnd2: clr.w   d7
        tst.w   CRASHE+2
        bne     sang2
        move.w  #1,CRASHE+2
        move.w  #3,NSON
        bra     sang2
angno2:
*******TRT SON
        tst.w   CRASHE+2
        bne.s   psosc2
        move.w  #3,NSON
psosc2: 
        move.w  OCCUR+18(pc),d0
        tst.b   evnco
        beq.s   pacri2
        clr.w   d7
        move.b  vaco(pc),d7
        add.w   d7,d7
        lea.l   CRIVIR(pc),a4
        cmp.w   0(a4,d7.w),d0
        blt.s   pacri2
*        mulu    d0,d0
*        lsr.l   #3,d0
*        move.w  d7,d4
*        bge.s   d7sup2
*        neg.w   d4
*d7sup2: LSR.W   #1,D4
*        mulu    d4,d0
*        LEA.L   LIMCRI(PC),A4
*        MOVE.W  TIRUSE,D4
*        SUBQ.W  #1,D4
*        BGE.S   TUSO2
*        CLR.W   D4
*TUSO2:  LSR.W   #7,D4
*        AND.W   #$FFFC,D4
*        SUB.L   0(A4,D4.W),d0
*        blt.s   pacri2
        clr.w   PANIM
        move.w  #1,d5
pacri2: move.w  OCCUR+18,d0
        muls    ACCEL,d0
        cmp.l   #LIMFRN,d0
        bgt.s   sang2
        clr.w   PANIM
        moveq   #1,d5
sang2:  move.w  NSON(pc),d0
        bge.s   gnso2
        clr.w   d0
        tst.w   d5
        beq.s   gnso2
        subq.w  #1,TIRUSE+2
        move.w  #1,d0
        MOVE.W  #-1,FROTT+2
gnso2:  move.w  #-1,NSON 
        move.w  RPMIN,d5
        asr.w   #4,d5
        move.w  topvib(pc),d4
        beq.s   ppvvi2
        tst.w   vibco
        beq.s   ppvvi2
        lsl.w   #3,d4
        add.w   d4,d5
ppvvi2: cmp.w   #943,d5
        ble.s   rerao2
        move.w  #943,d5
rerao2: move.w  d5,rapport
        move.w  d0,nouson
*******
        tst.b   evnco
        bne.s   tourne
        clr.w   mvtscrol
        bra.s   ftour
tourne: clr.w   d7
        move.b  vaco(pc),d7
        add.w   d7,d7
        move.w  ttour(pc,d7.w),d7
        tst.b   evnco
        bge.s   tournd
        neg.w   d7
tournd: muls    d2,d7
        move.w  X2(pc),d0     ; ****** a voir
        asr.l   d0,d7
        move.w  reste(pc),d5
        ext.l   d5
        add.l   d5,d7
        divs    DCHAMP(PC),d7
        neg.w   d7
        move.w  d7,mvtscrol   ;****** move.w
        swap    d7
        move.w  d7,reste
        bra.s   ftour
ttour:  dc.w    512,256,128,64,32,16,8,4
ftour:
        moveq   #0,d3
        tst.b   evnmo
        beq.s   avavt
        bgt.s   nhau
        move.w  d2,d3
        neg.w   d3
        bra.s   snhau
nhau:   move.w  d2,d3
snhau:  move.w  #VMSUP,d7
        sub.b   vamo(pc),d7
        asl.w   d7,d3
        ext.l   d3

avavt:  move.l  2(a0),d0
        sub.l   posvoit(pc),d0
        bgt     fava
        move.w  (a0),d1
        cmp.w   #-1,d1
        bne.s   ppchto
        move.l  Y1(pc),posvoit
        move.l  #CRCEVT,a0
        move.l  a0,FEVTAD
        bra.s   avavt
ppchto: and.w   #$3,d1
        lsl.w   #2,d1
        jmp     ptevn(pc,d1.w)
ptevn:  bra.l   pcourco
        bra.l   pinclco
        bra.l   pobjco
        bra.l   pmroco
        nop
pobjco: cmp.b   #4,(a0)
        bgt     psava
        bra     psava
pmroco: move.w  (a0),comodr
        and.w   #$fffc,comodr
        move.l  betrou1(pc),etrou1
        move.l  betrou2(pc),etrou2
        move.w  d0,depmod
        move.w  #1,topmod
        move.w  depmod(pc),topdep
        move.w  comodr(pc),topcod
        bra     psava
pcourco: move.w  (a0),d1
        lsr.w   #2,d1
        and.w   #$3,d1
        move.b  (a0),vaco
        move.b  pcorr(pc,d1.w),evnco
        bra.s   psava
pinclco: move.w  (a0),d1   
        lsr.w   #2,d1
        and.w   #$3,d1
        move.w  d0,d4
        tst.b   evnmo
        beq.s   pstabl
        bgt.s   pinhau1
        neg.w   d4
pinhau1: asl.w   d7,d4
        ext.l   d4
        add.l   d4,d3
pstabl: move.b  (a0),vamo
        move.b  pcorr(pc,d1.w),evnmo
        beq.s   psava
        bgt.s   pinhau2
        neg.w   d0
pinhau2: move.w  #VMSUP,d7
        sub.b   vamo(pc),d7
        asl.w   d7,d0
        ext.l   d0
        sub.l   d0,d3
        bra.s   psava
pcorr:  dc.b    0,1,-1,0
        
psava:   addq.l  #8,a0
        move.l  a0,FEVTAD
        bra.L   avavt

angul:  move.w  XB(pc),SXB
        move.w  volant(pc),d7
        clr.w   d5
        tst.w   JUMPE+2
        blt.s   angnor
        bgt.s   pabnd
        move.w  #2,NSON
pabnd:  clr.w   d7
        tst.w   CRASHE+2
        bne     sang
        move.w  #1,CRASHE+2
        move.w  #3,NSON
        bra     sang
angnor:
*******TRT SON
        tst.w   CRASHE+2
        bne.s   psoscr
        move.w  #3,NSON
psoscr: move.w  OCCUR+18,d0
        mulu    d0,d0
        lsr.l   #3,d0
        move.w  d7,d4
        bge.s   d7sup
        neg.w   d4
d7sup:  mulu    d4,d0
        LEA.L   LIMCRI(PC),A4
        MOVE.W  TIRUSE,D4
        SUBQ.W  #1,D4
        BGE.S   TUSO
        CLR.W   D4
TUSO:   LSR.W   #7,D4
        AND.W   #$FFFC,D4
        SUB.L   0(A4,D4.W),d0
        blt.s   pacris
        lsl.l   #3,d0   ;div 8192
        swap    d0
        cmp.w   #16,d0
        blt.s   d0i16
        move.w  #15,d0
d0i16:  eor.w   #$f,d0
        addq.w  #1,d0
        asr.w   #4,d7
        muls    d0,d7
        clr.w   PANIM
        move.w  #1,d5
pacris: move.w  OCCUR+18,d0
        muls    ACCEL,d0
        cmp.l   #LIMFRN,d0
        bgt.s   sang
        clr.w   d7
        clr.w   PANIM
        or.w    #$8000,d5
sang:   move.w  NSON(pc),d0
        bge.s   gnso
        clr.w   d0
        tst.w   d5
        beq.s   gnso
        move.w  #1,d0
        subq.w  #1,TIRUSE+2
        move.w  #-1,FROTT+2
gnso:   move.w  #-1,NSON 
        move.w  RPMIN,d5
        asr.w   #4,d5
        move.w  topvib(pc),d4
        beq.s   ppvvi
        tst.w   vibco
        beq.s   ppvvi
        lsl.w   #3,d4
        add.w   d4,d5
ppvvi:  cmp.w   #943,d5
        ble.s   rerao
        move.w  #943,d5
rerao:  move.w  d5,rapport
        move.w  d0,nouson
*******
        muls    d2,d7
        move.w  X2(pc),d0     ; ****** a voir
        asr.l   d0,d7
        sub.l   d7,haldco
        move.w  reste(pc),d5
        ext.l   d5
        add.l   d5,d7
        divs    DCHAMP(PC),d7
        neg.w   d7
        move.w  d7,mvtscrol   ;****** move.w
        swap    d7
        move.w  d7,reste
        bsr     contro1

        moveq   #0,d5
        tst.b   evnco
        bne.s   indrg
        bsr     cacinc
        muls    d2,d4
        asr.l   #DECPL,d4
        add.l   d4,decaco
        bra.s   modhau        
indrg:  bgt.s   indro
        move.w  d2,d5
        neg.l   d5
        move.w  #VCSUP,d6
        sub.b   vaco(pc),d6
        asl.l   d6,d5
        bsr     cdepet
        move.l  d4,d7
        add.l   d5,haldco
        bsr     contro1
        bsr     cacdec
        move.l  d4,d5
        sub.l   d4,d7
        add.l   d7,decaco
        bra.s   modhau
indro:  move.w  d2,d5
        move.w  #VCSUP,d6
        sub.b   vaco(pc),d6
        asl.l   d6,d5
        bsr     cdepet
        move.l  d4,d7
        add.l   d5,haldco
        bsr     contro1
        bsr     cacdec
        move.l  d4,d5
        sub.l   d7,d4
        add.l   d4,decaco

modhau: move.l  haldco(pc),d3   ;limit angul voit
        cmp.l   #VCOSUP,d3
        ble.s   lvco1
        move.l  #VCOSUP,haldco
        bra.s   flvco
lvco1:  cmp.l   #-VCOSUP,d3
        bge.s   flvco
        move.l  #-VCOSUP,haldco
flvco:  moveq   #0,d3
        tst.b   evnmo
        beq.s   avaevt
        bgt.s   inhau
        move.w  d2,d3
        neg.w   d3
        bra.s   sinhau
inhau:  move.w  d2,d3
sinhau: move.w  #VMSUP,d7
        sub.b   vamo(pc),d7
        asl.w   d7,d3
        ext.l   d3

avaevt: move.l  2(a0),d0
        sub.l   posvoit(pc),d0
        bgt     fava
        move.w  (a0),d1
        cmp.w   #-1,d1
        bne.s   pchto
        move.l  Y1(pc),posvoit
        move.l  #CRCEVT,a0
        move.l  a0,FEVTAD
        bra.s   avaevt
pchto:  and.w   #$3,d1
        lsl.w   #2,d1
        jmp     tevn(pc,d1.w)
tevn:   bra.l   courco
        bra.l   inclco
        bra.l   objco
        bra.l   mroco
LIMCRI: DC.L    680500,840000,940800,980000
CRIVIR: DC.W    270,300,330,375,420,490,600,700
objco:  
        bra     sava
mroco:  move.w  (a0),comodr
        and.w   #$fffc,comodr
        move.l  betrou1(pc),etrou1
        move.l  betrou2(pc),etrou2
        move.w  d0,depmod
        move.w  #1,topmod
        move.w  depmod(pc),topdep
        move.w  comodr(pc),topcod
        bra     sava

courco: move.w  (a0),d1  
        lsr.w   #2,d1
        and.w   #$3,d1
        move.w  d0,d6
        tst.b   evnco
        bne.s   pstal
        muls    inild(pc),d6
        asr.l   #DECPL,d6
        add.l   d6,decaco
        bra.s   stabld
pstal:  bgt.s   indro1
        neg.w   d6
        move.w  #VCSUP,d7
        sub.b   vaco(pc),d7
        ext.l   d6
        asl.l   d7,d6
        add.l   d6,haldco
        bsr     cacdec
        sub.l   d4,d5
        add.l   d5,decaco
        move.l  d4,d5
        bra.s   stabld
indro1: move.w  #VCSUP,d7
        sub.b   vaco(pc),d7
        ext.l   d6
        asl.l   d7,d6
        add.l   d6,haldco
        bsr     cacdec
        move.l  d4,d6
        sub.l   d5,d4
        add.l   d4,decaco
        move.l  d6,d5
        
stabld: move.b  (a0),vaco
        move.b  corr1(pc,d1.w),evnco
        bne.s   pstab2
        bsr     cacinc
        muls    d4,d0
        asr.l   #DECPL,d0
        sub.l   d0,decaco
        bra     sava
pstab2: bgt.s   indro2
        neg.w   d0
        move.w  #VCSUP,d7
        sub.b   vaco(pc),d7
        ext.l   d0
        asl.l   d7,d0
        bsr     cdepet
        move.l  d4,d6
        sub.l   d0,haldco
        bsr     contro1
        bsr     cacdec
        move.l  d4,d5
        sub.l   d4,d6
        add.l   d6,decaco
        bra     sava
indro2: move.w  #VCSUP,d7
        sub.b   vaco(pc),d7
        ext.l   d0
        asl.l   d7,d0
        bsr     cdepet
        move.l  d4,d6
        sub.l   d0,haldco
        bsr     contro1
        bsr     cacdec
        move.l  d4,d5
        sub.l   d6,d4
        add.l   d4,decaco
        bra.s   sava
corr1:  dc.b    0,1,-1,0

inclco: move.w  (a0),d1  
        lsr.w   #2,d1
        and.w   #$3,d1
        move.w  d0,d4
        tst.b   evnmo
        beq.s   stabl
        bgt.s   inhau1
        neg.w   d4
inhau1: move.w  #VMSUP,d7
        sub.b   vamo(pc),d7
        asl.w   d7,d4
        ext.l   d4
        add.l   d4,d3
stabl:  
        move.b  (a0),vamo
        move.b  corr(pc,d1.w),evnmo
        beq.s   sava
        bgt.s   inhau2
        neg.w   d0
inhau2: move.w  #VMSUP,d7
        sub.b   vamo(pc),d7
        asl.w   d7,d0
        ext.l   d0
        sub.l   d0,d3
        bra.s   sava
corr:   dc.b    0,1,-1,0
sava:   addq.l  #8,a0
        move.l  a0,FEVTAD
        bra.L   avaevt

cacinc: move.l  haldco(pc),d4
        and.w   #$ffc0,d4
        asr.l   #4,d4
        move.l  #JLLEQU+2050+8000,a4
        lea.l   0(a4,d4.w),a4
        move.w  32(a4),d4
        add.w   32-4(a4),d4
        add.w   32-8(a4),d4
        add.w   32-12(a4),d4
        add.w   32-16(a4),d4
        add.w   32+4(a4),d4
        add.w   32+8(a4),d4
        add.w   32+12(a4),d4
        sub.w   -32(a4),d4
        sub.w   -32-4(a4),d4
        sub.w   -32-8(a4),d4
        sub.w   -32-12(a4),d4
        sub.w   -32-16(a4),d4
        sub.w   -32+4(a4),d4
        sub.w   -32+8(a4),d4
        sub.w   -32+12(a4),d4
        asr.w   #3,d4
        move.w  d4,inild
        rts
cdepet: lea.l   vetdec(pc),a4
        clr.w   d4
        move.b  vaco(pc),d4
        lsl.w   #1,d4
        move.w  0(a4,d4.w),-4(a4)
cacdec: move.l  haldco(pc),d4
        and.w   #$ffc0,d4
        asr.l   #4,d4
        move.l  #JLLEQU+2050+8000,a4
        move.w  0(a4,d4.w),d4
        ext.l   d4
etdec:  nop
        rts
vetdec: asr.w   #5,d4
        asr.w   #4,d4
        asr.w   #3,d4
        asr.w   #2,d4
        asr.w   #1,d4
        nop
        add.w   d4,d4
        asl.l   #2,d4
contro1:
        move.l  haldco(pc),d5
        cmp.l   #CINSUP,d5
        ble.s   degmax2
        move.l  #CINSUP,haldco
        rts
degmax2: cmp.l   #-CINSUP,d5
        bge.s   fdeg2
        move.l  #-CINSUP,haldco
fdeg2:  rts
fava:
;trt ecras
        move.w  rafec(pc),d2
        bge.s   ecrap
        neg.w   d2
ecrap:  asr.w   #2,d2
        add.w   #MAXECR,d2
        move.w  d2,d7
        neg.w   d7
        move.w  d3,d0
        add.w   rafec(pc),d0
        move.w  d0,d4
        move.w  dafec(pc),d1
        sub.w   d1,d0
        blt.s   ecra1
        cmp.w   d2,d0
        bgt.s   ecra2
        add.w   d0,d1
        bra.s   ecra3
ecra2:  add.w   d2,d1
        bra.s   ecra3
ecra1:  cmp.w   d7,d0
        blt.s   ecra4
        add.w   d0,d1
        bra.s   ecra3
ecra4:  add.w   d7,d1
ecra3:  move.w  d1,dafec
        sub.w   d1,d4
        move.w  d4,rafec
        
        ext.l   d3
        add.l   degre(pc),d3
        move.l  d3,degre
;calcul moment de pente
        asr.l   #7,d3
*        move.w  d3,d7
*        asr.w   #2,d7
*        sub.w   d7,d3
        move.w  d3,moment

        move.l  Y1(pc),d7
        move.w  F1DEP(pc),d2   
        lea.l   CARSRT,a0
        lea.l   OCCUR(pc),a1
        add.l   F1SRT(pc),a0
        lea.l   zafvo(pc),a4
        move.l  a4,adgam+8
safvo1: move.w  -(a0),d0
        bge.s   pchtv
        lea.l   34(a0),a0
        sub.l   CRCLAP(pc),d7
brpvo:  move.w  -(a0),d0
        blt.s   brpvo
pchtv:  move.l  a1,a2
        add.w   d0,a2
        move.w  (a2)+,d0
        move.l  (a2),d1
        move.w  6(a2),d3
        sub.l   d7,d1
        cmp.l   #32767,d1
        blt.s   safvo
        move.w  d0,(a4)+
        move.w  #32767,(a4)
        bra.s   fafvoi
safvo:  move.l  a4,a3
        clr.w   d4
bafvo:  cmp.w   -4(a3),d1
        bge.s   safvo2
        addq.w  #1,d4
        lea.l   -6(a3),a3
        bra.s   bafvo
safvo2: subq.w  #1,d4
        blt.s   safvo3
        move.l  a4,a3
bafvo2: subq.w  #6,a3
        move.l  (a3),6(a3)
        move.w  4(a3),10(a3)
        dbf     d4,bafvo2
        move.w  d0,(a3)+
        move.w  d1,(a3)+
        move.w  d3,(a3)
        lea.l   6(a4),a4
        bra.s   safvo4
safvo3: move.w  d0,(a4)+
        move.w  d1,(a4)+
        move.w  d3,(a4)+
safvo4: cmp.w   #2000,d1
        bgt.s   safvo1
        add.w   #$100,d0
        move.w  d0,(a4)+
        add.w   #150,d1
        move.w  d1,(a4)+
;        sub.w   #28,d3
        move.w  d3,(a4)+
        bra     safvo1
fafvoi:
        lea.l   esevt1(pc),a0
        move.l  deevt1(pc),d0
        move.w  #6,d1
bpoba:  sub.w   d2,2(a0,d0.w)
        addq.w  #4,d0
        and.w   #$3f,d0
        sub.w   d2,2(a0,d0.w)
        addq.w  #4,d0
        and.w   #$3f,d0
        dbf     d1,bpoba
roba:   move.l  deevt1(pc),d0
        move.w  0(a0,d0.w),d1
        swap    d1
        move.w  2(a0,d0.w),d1
        bgt.s   fpoba
        add.w   #7000,d1
        clr.w   inico
        cmp.w   #3,0(a0,d0.w)
        beq.s   bldeb
        move.w  #2,inico
bldeb:  move.l  #$7fff,0(a0,d0.w)
        subq.w  #4,d0
        and.w   #$3f,d0
        move.l  #$71b59,0(a0,d0.w)
        subq.w  #4,d0
        and.w   #$3f,d0
        move.l  d1,0(a0,d0.w)
        move.w  deevt1+2(pc),d0
        addq.w  #4,d0
        and.w   #$3f,d0
        move.w  d0,deevt1+2
        bra.s   roba
fpoba:
        move.l  deevt1(pc),adgam+4
        move.l  FEVTAD(pc),adgam
        moveq   #0,d7
        lea.l   adgam(pc),a1
        move.l  20(a1),a0
        add.w   6(a1),a0
        move.w  2(a0),d7
        move.l  (a1),a0
        cmp.w   #-1,(a0)
        bne.s   pchto1
        move.l  #CRCEVT,a0
        move.l  a0,(a1)
        move.l  CRCLAP(pc),d0
        sub.l   d0,posvoit
pchto1:
        move.l  2(a0),d0
        sub.l   posvoit(pc),d0
        cmp.l   d0,d7
        bgt.s   gam13b
        move.l  8(a1),a0
        cmp.w   2(a0),d7
        bgt.s   gam3b
        move.w  d7,evt
        move.w  #4,tevt
        bra.s   frevt
gam3b:  move.w  2(a0),evt
        move.w  #8,tevt
        bra.s   frevt
gam13b: move.l  d0,d7
        move.l  8(a1),a0
        move.w  2(a0),d0
        ext.l   d0
        cmp.l   d0,d7
        bgt.s   gam3b
        move.w  d7,evt
        clr.w   tevt
frevt:

        move.w  inico(pc),colban

        tst.w   MGAME+2
        bne.s   trang
        move.w  XB(pc),d0        ;Middle of Road
        cmp.w   #256*3,d0
        ble.s   suibo
        move.w  #256*3,d0
        move.w  d0,XB
        bra.s   finbo
suibo:  cmp.w   #-768*1,d0
        bge.s   finbo
        move.w  #-768*1,d0
        move.w  d0,XB
finbo:  move.w  d0,d1
        ext.l   d0
        asl.l   #1,d0
        clr.l   haldco
        clr.w   inild
        MOVE.W  FROTT,D3
        BEQ     fang
        BSR     TFROT
        EXT.L   D1
        ASL.L   #1,D1
        MOVE.L  D1,D0
        bra     fang
trang:  move.l  decaco(pc),d0
        cmp.l   #3072-20,d0
        ble.s   suibo1
        move.l  #3072-20,d0
        move.l  d0,decaco
        bra.s   finbo1
suibo1: cmp.l   #-3072+20,d0
        bge.s   finbo1
        move.l  #-3072+20,d0
        move.l  d0,decaco
finbo1: 
        asr.l   #1,d0
        move.w  d0,d1
        asr.w   #1,d1
        move.w  d1,XB
        TST.W   FROTT
        BEQ.S   afang
        BSR     TFROT
        EXT.L   D1
        ASL.L   #1,D1
        MOVE.L  D1,D0
        ASL.L   #1,D1
        MOVE.L  D1,decaco
afang:  TST.W   MCOMM+2 ;limite XB pour comm
        BLE.S   fang
        move.w  XB(PC),d1
        sub.w   SXB(PC),d1
        blt.s   decneg
        sub.w   #63,d1
        ble.s   fang
        bra.s   modxb
decneg: add.w   #63,d1
        bge.s   fang
modxb:  sub.w   d1,XB
        move.w  XB(pc),d1
        ext.l   d1
        asl.l   #1,d1
        move.l  d1,d0
        asl.l   #1,d1
        move.l  d1,decaco
        BRA.S   fang
TFROT:  MOVE.L  #FROTT+2,A4
        CMP.W   2(A4),D1
        BGE.S   PAFRT1
        MOVE.W  2(A4),D1
        ADDQ.W  #1,D1
        BRA.S   FROTCO
PAFRT1: CMP.W   4(A4),D1
        BLE.S   FFROT
        MOVE.W  4(A4),D1
        SUBQ.W  #1,D1
FROTCO: MOVE.W  #1,(A4)
        MOVE.W  D1,XB
        move.l  haldco(pc),d0
        asr.l   #1,d0
        move.l  d0,haldco
FFROT:  RTS
fang:
****
        move.w  #HAUTEUR,d3
        move.l  #JLLEQU+2050+8000,a4
        move.l  #$ffff,-8004(a4)
        move.l  #zafevt,a5
        move.l  a5,usp
        move.w  #DEMAR,a5
        move.l  #JLLEQU,a3

        clr.l   rupmd
        clr.l   tevco1
        clr.l   hald
        clr.l   pdeld
        clr.w   sdem
        clr.l   sdec
********************
        tst.w   JUMPE+2
        blt     pajump
        bgt.s   jumpco          
        clr.w   crasco 
        move.w  JUMPE+4(PC),D1
        cmp.w   #400,d1
        ble.s   saupo
        move.w  #400,d1
saupo:  
        cmp.w   #120,d1
        bge.s   saupos
        move.w  #120,d1
saupos: 
        MOVE.W  D1,JUMPE+4
        move.w  #1,JUMPE+2
        move.w  d1,valhau
        move.w  d1,saucra
        move.w  #HAUTEUR,hautco
jumpco: cmp.w   #2,JUMPE+2        
        bgt.L   tjump
        beq.s   djump
pjump:  move.w  JUMPE+4(pc),d1
        bgt.s   epjump
        move.w  crasco(pc),d1
        ext.l   d1
        move.w  valhau(pc),d4
        ext.l   d4
tyty:   divs    #20,d4
        divs    d4,d1
        move.w  d1,JUMPE+4
        move.w  #2,JUMPE+2
djump:  move.w  JUMPE+4(pc),d1
        sub.w   d1,crasco
        bra.s   pdjump
epjump: 
        asr.w   #2,d1
        muls    d1,d1
        sub.w   d1,crasco
        sub.w   #80,JUMPE+4
pdjump: 
        move.w  crasco(pc),hapl
        move.w  valhau(pc),d1
        ext.l   d1
        asr.w   #3,d1
        move.w  d1,d3
        asr.w   #1,d3
        add.w   d3,d1
        asr.w   #1,d1   
spdjs:  sub.w   #48,valhau   ; nb fois hauteur
        sub.w   d1,hautco
        move.w  hautco(pc),d3
        cmp.w   #HAUTEUR,d3
        bge.s   ssjmp
        bra     pavbi
ssjmp:
        move.w  #3,JUMPE+2
        move.w  saucra(pc),d1
        move.w  #2,NSON
        cmp.w   #250,d1
        blt.s   sssjmp
        move.w  #4,JUMPE+2
sssjmp:
        move.w  #1,CRASHE+2
        clr.w   CRASHE+4
        bra     scrash
tjump:  
        move.w  #-1,JUMPE+2
        bra     craco
pajump: tst.w   CRASHE+2
        blt.L   pacras
        bgt.s   craco
        move.w  #1,CRASHE+2
        clr.w   crasco
        move.w  CRASHE+4(pc),d1
        cmp.w   #330,d1
        ble.s   bvj
        move.w  #330,d1
bvj:    move.w  d1,CRASHE+4
        move.w  d1,saucra
        bra.s   scrash
craco:  cmp.w   #1,CRASHE+2
        bgt.s   encscr
        sub.w   #60,CRASHE+4 
scrash: move.w  CRASHE+4(pc),d1
        asr.w   #2,d1
        bge.s   crapo
        muls    d1,d1
        neg.w   d1
        bra.s   cracco
crapo:  muls    d1,d1
cracco: move.w  d1,d4
        asr.w   #2,d4
        sub.w   d4,d1
        add.w   d1,crasco
        move.w  crasco(pc),d1
        asr.w   #8,d1
        asr.w   #1,d1
        sub.w   d1,d3
        move.w  crasco(pc),hapl
        ble.s   sscra
        bra     pavbi
sscra:  move.w  #HAUTEUR,d3
        move.w  #2,CRASHE+2
        moveq   #0,d1
        move.w  saucra(pc),d1
        divu    #6,d1
        move.w  d1,CRASHE+4
        clr.w   crasco
        clr.w   hapl
        bra     pavbi
encscr: subq.w  #8,CRASHE+4
        move.w  CRASHE+4(pc),d1
        bge.s   crapo1
        muls    d1,d1
        neg.w   d1
        bra.s   cracc1
crapo1: muls    d1,d1
cracc1: 
        add.w   d1,crasco
        move.w  crasco(pc),d1
        ble.s   pchha
        asr.w   #8,d1
        asr.w   #1,d1
        sub.w   d1,d3
pchha:  move.w  crasco(pc),hapl
        cmp.w   #-200,hapl
        bgt.s   pavbi
        move.w  #-1,CRASHE+2
        move.w  #-200,hapl
pavbi:
        move.w  #HAUTEUR,d5
        sub.w   d3,d5
        asr.w   #1,d5
        move.w  #20,d4
        sub.w   d5,d4
        cmp.w   #24,d4
        ble.s   rho
        move.w  #24,d4
        bra.s   rbo
rho:    cmp.w   #16,d4
        bge.s   rbo
        move.w  #16,d4
rbo:    move.w  d4,d5
        bra     pavib
pacras: move.w  vitco(pc),d1
        sub.w   F1DEP(pc),d1
        move.w  F1DEP(pc),vitco
        move.w  d1,d5
        sub.w   haplco(pc),d5
        beq.s   memacc
        blt.s   extim
        cmp.w   #5,d5
        ble.s   telqu
        addq.w  #5,haplco
        clr.w   lisacc
        bra.s   fafhap
extim:  cmp.w   #-5,d5
        bge.s   telqun
        clr.w   lisacc
        subq.w  #5,haplco
        bra.s   fafhap
memacc: move.w  #1,lisacc
        bra.s   fafhap
telqun: neg.w   d5
telqu:  move.w  lisacc(pc),d4
        beq.s   telquc
        subq.w  #1,d5
        bne.s   telque
        clr.w   lisacc
        bra.s   fafhap
telque: clr.w   lisacc
telquc: move.w  d1,haplco
fafhap: move.w  haplco(pc),d1
;       ble.s   pviec
        move.w  d1,d5
        asr.w   #2,d5
;       add.w   d1,d5
;       bge.s   bbb
;       neg.w   d5
;       asr.w   #1,d5
bbb:    move.w  rafec(pc),d4
        asr.w   #7,d4
        add.w   d4,d3
        add.w   d5,d3
        move.w  #-128,d5
        sub.w   d3,d5
        asr.w   #1,d5
        move.w  #20,d4
        sub.w   d5,d4
        cmp.w   #25,d4
        ble.s   rhok
        move.w  #25,d4
        bra.s   rbok
rhok:   cmp.w   #14,d4
        bge.s   rbok
        move.w  #14,d4
rbok:   asl.w   #6,d1
        move.w  d1,d5
        asr.w   #1,d5
        add.w   d5,d1
        add.w   rafec(pc),d1
        move.w  d1,hapl

facc:   move.w  d4,d5
        move.w  topvib(pc),d1
        beq.s   pavib
        cmp.w   #50,F1DEP
        ble.s   pavib
        subq.w  #1,d1
        or.w    topvib-2(pc),d1
        add.w   d1,d1
        lea.l   teor1(pc),a1
        move.w  0(a1,d1.w),d7
        eor.w   d7,vigch
        add.w   d1,d1
        lea.l   16(a1),a1
        add.w   d1,a1
        move.b  vigch(pc),d1
        move.b  0(a1,d1.w),d7
        ext.w   d7
        add.w   d7,d4
        move.b  vidrt(pc),d1
        move.b  2(a1,d1.w),d7
        ext.w   d7
        add.w   d7,d5
        
        eor.w   #$ffff,vibco
        beq.s   pavib
        move.w  #-150,d1
        mulu    topvib(pc),d1
        sub.w   #50,d1
        add.w   d1,hapl
pavib:  move.w  d4,HAUT
        move.w  d5,HAUT+2
        move.w  hapl(pc),d1
        cmp.w   #MINSUP,d1
        ble.s   stdegr
        move.w  #MINSUP,d1
        move.w  d1,hapl
        bra.s   ftde
stdegr: cmp.w   #-MINSUP,d1
        bge.s   ftde
        move.w  #-MINSUP,d1
        move.w  d1,hapl
ftde:
        move.w  d1,sdem
        move.l  degre(pc),d4
        neg.l   d4
        ext.l   d1
        add.l   d1,d4
        cmp.l   #MINSUP,d4
        ble.s   stdeg1
        move.w  #MINSUP,d4
        bra.s   ftde1
stdeg1: cmp.l   #-MINSUP,d4
        bge.s   ftde1
        move.w  #-MINSUP,d4
ftde1:
        and.w   #$fff0,d4
        asr.w   #2,d4
        bsr     rt_pmd
        move.w  1016(a3),d4
        muls    d7,d4
        asr.l   #DECPL,d4
        add.w   d3,d4
        muls    1018(a3),d4
        swap    d4
        neg.w   d4
        muls    #160,d4
        add.l   #21600,d4
        move.l  d4,adscrol

        move.w  d3,htprl
*******************
        clr.w   d2
        move.w  #1,evtrup
        tst.b   evnmo
        bgt.L   montee
        blt.s   descen
        move.w  #$7fff,evtrup+2
        move.w  hapl(pc),d4
        and.w   #$fff0,d4
        asr.w   #2,d4
        bsr     rt_pmd
        move.w  d7,d1
        lea.l   plat0(pc),a1
        bra.L   tinvir
;iii:   dc.l    0
descen: 
        MOVE.W  sdem(PC),d1
        move.w  #VMSUP,d7
        sub.b   vamo(pc),d7
; rupt
        move.l  #MINSUP,d4
        add.w   d1,d4
        lsr.w   d7,d4
        cmp.l   #$7fff,d4
        ble.s   rudeo
        move.w  #$7fff,d4
rudeo:  move.w  d4,evtrup+2
        asr.w   d7,d1
        move.b  vamo(pc),d2
        move.b  d2,vcohb
        bsr     rt_md
        add.w   d7,d3
        move.w  #$20,tevco1
        lsl.w   #3,d2
        lea.l   tasrl(pc),a0
        add.w   d2,a0
        lea.l   eetd1-2(pc),a1
        move.w  (a0)+,(a1)
        move.w  (a0)+,4(a1)
        move.w  (a0)+,10(a1)
        move.w  (a0),18(a1)
        lea.l   desc1(pc),a1
        bra.s   tinvir
montee: 
        MOVE.W  sdem(PC),d1
        move.w  #VMSUP,d7
        sub.b   vamo(pc),d7
; rupt
        move.l  #MINSUP,d4
        sub.w   d1,d4
        lsr.w   d7,d4
        cmp.l   #$7fff,d4
        ble.s   rumoo
        move.w  #$7fff,d4
rumoo:  move.w  d4,evtrup+2
        asr.w   d7,d1
        move.b  vamo(pc),d2
        move.b  d2,vcohb
        bsr     rt_md
        sub.w   d7,d3
        move.w  #$10,tevco1
        lsl.w   #3,d2
        lea.l   tasrl(pc),a0
        add.w   d2,a0
        lea.l   eetm1-2(pc),a1
        move.w  (a0)+,(a1)
        move.w  (a0)+,4(a1)
        move.w  (a0)+,10(a1)
        move.w  (a0),16(a1)
        lea.l   mont1(pc),a1
tinvir: clr.w   adgam+14
        tst.b   evnco
        bgt.s   drote
        blt.L   gauch
        move.w  #$7fff,evtrup+6
        lea.l   droit1(pc),a2
        move.l  haldco(pc),sdec
        move.w  inild(pc),d5
        move.w  #254,d2
        MOVE.L  #RODEQU,a0
        bra     contevt
drote:  move.w  #$10,tevco2
        move.b  vaco(pc),d2
        move.b  d2,vcodg
        move.l  haldco(pc),d5
; rupt
        move.w  #VCSUP,d6
        sub.b   d2,d6
        move.l  #CINSUP,d4
        sub.l   d5,d4
        asr.l   d6,d4
        cmp.l   #$7fff,d4
        ble.s   ruco1
        move.w  #$7fff,d4
ruco1:  move.w  d4,evtrup+6
        cmp.w   evtrup+2(pc),d4
        bge.s   fruco1
        move.w  #4,adgam+14
fruco1:
        asr.l   d6,d5
        bsr     rt_dg
        sub.l   d7,d0
        lsl.w   #3,d2
        lea.l   tasrl+64(pc),a0
        add.w   d2,a0
        lea.l   eecd1-2(pc),a2
        move.w  (a0)+,(a2)
        move.w  (a0)+,4(a2)
        move.w  (a0)+,10(a2)
        move.w  (a0),18(a2)
        lea.l   vird1(pc),a2
        move.w  #254,d2
        MOVE.L  #RODEQU,a0
        bra     contevt
gauch:  move.w  #$20,tevco2
        move.b  vaco(pc),d2
        move.b  d2,vcodg
        move.l  haldco(pc),d5
; rupt
        move.w  #VCSUP,d6
        sub.b   d2,d6
        move.l  #CINSUP,d4
        add.l   d5,d4
        asr.l   d6,d4
        cmp.l   #$7fff,d4
        ble.s   ruco2
        move.w  #$7fff,d4
ruco2:  move.w  d4,evtrup+6
        cmp.w   evtrup+2(pc),d4
        bge.s   fruco2
        move.w  #4,adgam+14
fruco2:
        asr.l   d6,d5
        bsr     rt_dg
        add.l   d7,d0
        lsl.w   #3,d2
        lea.l   tasrl+64(pc),a0
        add.w   d2,a0
        lea.l   eecg1-2(pc),a2
        move.w  (a0)+,(a2)
        move.w  (a0)+,4(a2)
        move.w  (a0)+,10(a2)
        move.w  (a0),20(a2)
        lea.l   virg1(pc),a2
        move.w  #254,d2
        MOVE.L  #RODEQU,a0
        bra     contevt
        bra.l   omont1
mont2:  subq.w  #1,-8002(a4)
        ble.s   mont1
        addq.w  #4,a3
        dbf     d2,smont2
        bra     ffrou
smont2: move.w  evt(pc),d7
        cmp.w   (a3),d7
        bge.s   mont2
        bra     strevt
        bra.l   omont1
mont1:  move.w  (a3)+,d4
        sub.w   rupmd(pc),d4
        add.w   d1,d4
        move.w  d4,d7
        and.w   #$ffff,d7
eetm1:  sub.w   d7,d4
        asr.w   #4,d7
        muls    2(a4,d7.w),d4
        asr.w   #4,d4
eetm2:  add.w   0(a4,d7.w),d4
        asl.w   #4,d4
        add.w   d3,d4
        muls    (a3)+,d4
        swap    d4
        sub.w   a5,d4
        bgt.s   oklim
        move.w  d4,-8006(a4)
        lea.l   mont1(pc),a1
        dbf     d2,contevt
        bra     ffrou
oklim:  move.w  -8004(a4),d7
        move.w  d2,-8004(a4)
        sub.w   d2,d7
        asr.w   #1,d7
;        addq.w  #1,d7
        move.w  d7,-8002(a4)
        lea.l   mont2(pc),a1
        jmp     (a2)
        bra.l   odes1
desc2:  subq.w  #1,-8002(a4)
        ble.s   desc1
        addq.w  #4,a3
        dbf     d2,sdesc2
        bra     ffrou
sdesc2: move.w  evt(pc),d7
        cmp.w   (a3),d7
        bge.s   desc2
        bra     strevt
        bra.l   odes1
desc1:  move.w  rupmd(pc),d4
        sub.w   (a3)+,d4
trude:  add.w   d1,d4
        move.w  d4,d7
        and.w   #$ffff,d7
eetd1:  sub.w   d7,d4
        asr.w   #4,d7
        muls    2(a4,d7.w),d4
        asr.w   #4,d4
eetd2:  add.w   0(a4,d7.w),d4
        neg.w   d4
        asl.w   #4,d4
        add.w   d3,d4
erude:  muls    (a3)+,d4
        swap    d4
        sub.w   a5,d4
        bgt.s   oklid
        move.w  d4,-8006(a4)
        lea.l   desc1(pc),a1
        dbf     d2,contevt
        bra     ffrou
oklid:  move.w  -8004(a4),d7
        move.w  d2,-8004(a4)
        sub.w   d2,d7
        subq.w  #1,d7
        move.w  d7,-8002(a4)
        lea.l   desc2(pc),a1
        jmp     (a2)
        bra.l   odrt1
plat2:  subq.w  #2,-8002(a4)
        ble.s   plat1
        addq.w  #4,a3
        dbf     d2,splat2
        bra     ffrou
splat2: move.w  evt(pc),d7
        cmp.w   (a3),d7
        bge.s   plat2
        bra     strevt
        bra.l   odrt1
plat1:  move.w  (a3)+,d4
        sub.w   pdepl(pc),d4
        muls    d1,d4
        asr.l   #DECPL,d4
        add.w   d3,d4
        muls    (a3)+,d4
        swap    d4
        sub.w   a5,d4
        bgt.s   oklip
        move.w  d4,-8006(a4)
        lea.l   plat1(pc),a1
        dbf     d2,contevt
        bra     ffrou
oklip:  move.w  -8004(a4),d7
        move.w  d2,-8004(a4)
        sub.w   d2,d7
        add.w   d7,d7
        subq.w  #1,d7
        add.w   d7,-8002(a4)
        lea.l   plat2(pc),a1
        jmp     (a2)
        bra.l   odrt1
plat0:  move.w  (a3)+,d4
        sub.w   pdepl(pc),d4
        muls    d1,d4
        asr.l   #DECPL,d4
        add.w   d3,d4
        muls    (a3)+,d4
        swap    d4
        sub.w   a5,d4
        bgt.s   oklip2
        dbf     d2,contevt
        bra     ffrou
oklip2: move.w  d2,-8004(a4)
        lea.l   plat1(pc),a1
        jmp     (a2)

        bra.l   odrot1
vird1:  move.w  -4(a3),d7
        sub.w   rupco(pc),d7
        ext.l   d7
        add.l   d5,d7
        move.l  d7,d6
        and.w   #$ffff,d6
eecd1:  sub.w   d6,d7
        asr.l   #4,d6
        muls    2(a4,d6.w),d7
        asr.w   #4,d7
eecd2:  add.w   0(a4,d6.w),d7
        ext.l   d7
        asl.l   #4,d7
        add.l   d0,d7
        blt.s   vdneg
;        asl.l   #1,d7
        move.w  d7,d6
        mulu    -2(a3),d6
        swap    d6
        swap    d7
        subq.w  #1,d7
        blt.s   fvdr
svdr:   add.w   -2(a3),d6
;        dbf     d7,svdr
fvdr:   add.w   #160,d6
        bra.L   eclig
vdneg:  
;        asl.l   #1,d7
        move.w  d7,d6
        mulu    -2(a3),d6
        swap    d6
        swap    d7
        neg.w   d7
        subq.w  #1,d7
        sub.w   -2(a3),d6
        dbf     d7,snvdr
        add.w   #160,d6
        bra.l   eclig
snvdr:  sub.w   -2(a3),d6
        add.w   #160,d6
        bra     eclig
        bra.l   ogch1
virg1:  move.w  rupco(pc),d7
        sub.w   -4(a3),d7
        ext.l   d7
        add.l   d5,d7
        move.l  d7,d6
        and.w   #$ffff,d6
eecg1:  sub.w   d6,d7
        asr.l   #4,d6
        muls    2(a4,d6.w),d7
        asr.w   #4,d7
eecg2:  add.w   0(a4,d6.w),d7
        neg.w   d7
        ext.l   d7
        asl.l   #4,d7
        add.l   d0,d7
        blt.s   vgneg
;        asl.l   #1,d7
        move.w  d7,d6
        mulu    -2(a3),d6
        swap    d6
        swap    d7
        subq.w  #1,d7
        blt.s   fvgr
svgr:   add.w   -2(a3),d6
;        dbf     d7,svgr
fvgr:   add.w   #160,d6
        bra.L   eclig
vgneg:  
;        asl.l   #1,d7
        move.w  d7,d6
        mulu    -2(a3),d6
        swap    d6
        swap    d7
        neg.w   d7
        subq.w  #1,d7
        sub.w   -2(a3),d6
        dbf     d7,snvgr
        add.w   #160,d6
        bra.l   eclig
snvgr:  sub.w   -2(a3),d6
        add.w   #160,d6
        bra.s   eclig
        bra.l   odrit
droit1: move.w  -4(a3),d7
        sub.w   pdeld(pc),d7
        muls    d5,d7
        asr.l   #DECPL,d7
        add.l   d0,d7
        blt.s   vneg
;        asl.l   #1,d7
        move.w  d7,d6
        mulu    -2(a3),d6
        swap    d6
        swap    d7
        subq.w  #1,d7
        blt.s   fvr
svr:    add.w   -2(a3),d6
;        dbf     d7,svr
fvr:    add.w   #160,d6
        bra.s   eclig
vneg:   
;        asl.l   #1,d7
        move.w  d7,d6
        mulu    -2(a3),d6
        swap    d6
        swap    d7
        neg.w   d7
        subq.w  #1,d7
        sub.w   -2(a3),d6
        dbf     d7,snvr
        add.w   #160,d6
        bra.l   eclig
snvr:   sub.w   -2(a3),d6
        add.w   #160,d6
eclig:  subq.w  #1,d4
        ble.L   ecligb
        cmp.w   #DEMAR,a5
        bne.s   pdemar
        add.w   d4,a5
        mulu    #10,d4
        move.w  d4,-8008(a4)
        add.w   d4,a0
        bra     ecligb  
pdemar: cmp.w   #DEMAR+140,a5
        bge     ffrou
        addq.w  #1,d4
        add.w   d4,a5
        swap    d1
        move.w  -6(a0),d7
        sub.w   -10(a0),d7
        subq.w  #6,d7
        cmp.w   d2,d7
        ble.s   prolin
        move.l  a1,-(a7)
        lea.l   eclig(pc),a1
        move.w  #$4e75,(a1)
        subq.w  #4,a3
        swap    d3
        move.w  d6,d3
        jsr     (a2)
        move.w  #$5344,(a1)
        move.l  (a7)+,a1
        addq.w  #4,a3
        moveq   #0,d7
        move.w  d6,d7
        move.w  d3,d6
        sub.w   d7,d6
        ext.l   d6
        asl.l   #7,d6
        swap    d7
        move.w  -8006(a4),d3
        neg.w   d3
        move.w  d3,d1
        add.w   d4,d3
        divs    d3,d6
        swap    d3
        swap    d6
        clr.w   d6
        asr.l   #7,d6
        bra.s   plicac
licac:  add.l   d6,d7
plicac: dbf     d1,licac
        bra.s   caccom
prolin: 
        moveq   #0,d7
        move.w  -10(a0),d7
        sub.w   d7,d6
        ext.l   d6
        asl.l   #7,d6
        swap    d7
        divs    d4,d6
        swap    d6
        clr.w   d6
        asr.l   #7,d6
caccom: subq.w  #1,d4
        move.w  d2,d1
        lsr.w   #3,d1
        addq.w  #1,d2
        addq.w  #1,d1
beclig: add.l   d6,d7
        swap    d7
        move.w  d7,(a0)+
        move.w  d7,(a0)
        sub.w   d2,(a0)+
        move.w  d7,(a0)
        add.w   d2,(a0)+
        move.w  d1,(a0)+
etrou1: 
        move.w  colban(pc),(a0)+
;        BSR     MODROU
        swap    d7
        dbf     d4,beclig
        swap    d1
        subq.w  #1,d2
        dbf     d2,contevt
        bra.s   ffrou

ecligb: addq.w  #1,a5
        move.w  d2,d7
        lsr.w   #3,d7
        addq.w  #1,d7
        addq.w  #1,d2
        move.w  d6,(a0)+
        move.w  d6,(a0)
        sub.w   d2,(a0)+
        add.w   d2,d6
        move.w  d6,(a0)+
        move.w  d7,(a0)+
etrou2: 
        move.w  colban(pc),(a0)+
;        BSR     MODROU
feclig: subq.w  #1,d2
        dbf     d2,contevt
ffrou:  move.b  #-1,9(a0)
;calcul de adsky
        move.l  a0,d0
        sub.l   #RODEQU,d0
        lsl.w   #4,d0
        move.l  #32000,d1
        sub.l   d0,d1
        cmp.l   adscrol(pc),d1
        ble.s   pmosky
        move.l  adscrol(pc),d1
pmosky: move.l  d1,adsky

        move.w  -8008(a4),d3
        beq.s   demnor
        lsr.w   #4,d0
        sub.w   #10,d0
        move.w  d3,d1
        move.w  d3,d2
        add.w   d1,d1
        sub.w   d0,d1
        ble.s   nblisu
        sub.w   d1,d2
        bgt.s   nblisu
        clr.w   d0
        bra.s   nblis1
nblisu: move.w  d2,d0
        add.w   #10,d0
nblis1: move.l  #RODEQU,a0
        clr.w   -8008(a4)
        add.w   d3,a0
        lea.l   -10(a0),a0
bfrou:  move.w  10(a0),d1
        add.w   0(a0,d2.w),d1
        sub.w   0(a0,d0.w),d1
        move.w  d1,(a0)+
        move.w  10(a0),d1
        add.w   0(a0,d2.w),d1
        sub.w   0(a0,d0.w),d1
        move.w  d1,(a0)+
        move.w  10(a0),d1
        add.w   0(a0,d2.w),d1
        sub.w   0(a0,d0.w),d1
        move.w  d1,(a0)+
        move.w  10(a0),d1
        add.w   0(a0,d2.w),d1
        sub.w   0(a0,d0.w),d1
        move.w  d1,(a0)+
        move.w  10(a0),(a0)
        lea.l   -18(a0),a0
        sub.w   #10,d3
        bgt.s   bfrou
demnor: MOVE.L  #RODEQU,A0
        moveq   #0,d0
        cmp.w   #78,2(a0)
        blt.s   tdrr
        cmp.w   #78+32+17,2(a0)
        blt.s   tbande
        cmp.w   #242-17,2(a0)
        blt.s   verd1
        cmp.w   #242+32,2(a0)
        blt.s   tband1
verd2:  bset    #2,d0
        bra.s   pvibry
tdrr:   moveq   #4,d0
        swap    d0
        cmp.w   #242,4(a0)
        bgt.s   pvibry
        cmp.w   #242-32-17,4(a0)
        bgt.s   tbande
        cmp.w   #78+17,4(a0)
        bgt.s   verd1
        cmp.w   #78-32,4(a0)
        bgt.s   tband1
        bra.s   verd2
tbande: bset    #1,d0
        bra.s   pvibry
tband1: move.w  #3,d0
        bra.s   pvibry
verd1:  bset    #0,d0
pvibry: move.l  d0,topvib-2
        move.b  #-1,1320+9(A0)
        RTS
colban: dc.w    0
MODROU: move.w  colban(pc),(a0)+
        movem.l d5/a5,-(sp)
        move.w  comodr(pc),d5
        jmp     tmodr(pc,d5.w)
tmodr:  bra.l   vo3co
        bra.l   chico
        bra.l   chiou
        bra.l   vo3ou
        bra.l   vo3co
        bra.l   vo3co
        bra.l   chife
        bra.l   vo3fe
        bra.l   garco
        bra.l   garco
        bra.l   garco
        bra.l   garou
        bra.l   garco
        bra.l   garco
        bra.l   garco
        bra.l   garfe
inclin: move.w  (a0),d2
        and.w   #$000c,d2
        or.w    tevco1(pc),d2
        jmp     ancnou(pc,d2.w)
ancnou: 
        bra.l   procevt1
        bra.l   plamon
        bra.l   plades
        bra.l   procevt1

        bra.l   monpla
        bra.l   monmon
        bra.l   mondes
        bra.l   procevt1

        bra.l   despla
        bra.l   desmon
        bra.l   desdes
        bra.l   sommet
monmon: sub.w   rupmd(pc),d7
        add.w   d7,d1
        move.b  vcohb(pc),d2
        bsr     rt_md
        add.w   d7,d3
        move.w  #VMSUP,d7
        sub.b   d2,d7
        asl.w   d7,d1
        move.b  (a0),d2
        move.b  d2,vcohb
        move.w  #VMSUP,d7
        sub.b   d2,d7
; rupt
        move.w  #MINSUP,d4
        sub.w   d1,d4
        bsr     rumond
        asr.w   d7,d1
        bsr     rt_md
        sub.w   d7,d3
        lsl.w   #3,d2
        lea.l   tasrl(pc),a0
        add.w   d2,a0
        lea.l   eetm1-2(pc),a1
        move.w  (a0)+,(a1)
        move.w  (a0)+,4(a1)
        move.w  (a0)+,10(a1)
        move.w  (a0),16(a1)
        move.w  evt(pc),rupmd
        clr.w   -8004(a4)
        lea.l   mont1(pc),a1
        bra     procevt1
desdes: sub.w   rupmd(pc),d7
        sub.w   d7,d1
        move.b  vcohb(pc),d2
        bsr     rt_md
        sub.w   d7,d3
        move.w  #VMSUP,d7
        sub.b   d2,d7
        asl.w   d7,d1
        move.b  (a0),d2
        move.b  d2,vcohb
        move.w  #VMSUP,d7
        sub.b   d2,d7
        move.w  d1,-(a7)
        move.w  d7,-(a7)
        asr.w   d7,d1
        bsr     rt_md
        add.w   d7,d3
; rupt
        move.w  (a7)+,d7
        move.w  d1,d6
        ext.l   d6
        add.l   evt-2(pc),d6
        move.w  d3,d4
        bge.s   moi1
        neg.w   d4
        ext.l   d4
        cmp.l   d6,d4
        bge.s   pmoi1
        mulu    #36000,d4
        divu    d6,d4
        cmp.w   #16000,d4
        bgt.s   pmoi1
        neg.w   d4
        bra.s   cmoi1
moi1:   ext.l   d4
        cmp.l   d6,d4
        bge.s   pmoi1
        mulu    #36000,d4
        divu    d6,d4
        cmp.w   #19000,d4
        bgt.s   pmoi1
cmoi1:  cmp.w   (a7),d4
        bgt.s   pmoi1
        move.w  d4,-8010(a4)
        sub.w   (a7)+,d4
        neg.w   d4
        bsr     rudes2
        bra.s   smoi1
pmoi1:  move.w  #MINSUP,d4
        add.w   (a7)+,d4
        bsr     rumond
smoi1:  lsl.w   #3,d2
        lea.l   tasrl(pc),a0
        add.w   d2,a0
        lea.l   eetd1-2(pc),a1
        move.w  (a0)+,(a1)
        move.w  (a0)+,4(a1)
        move.w  (a0)+,10(a1)
        move.w  (a0),18(a1)
        move.w  evt(pc),rupmd
        move.l  #$ffff,-8004(a4)
        lea.l   desc1(pc),a1
        bra     procevt1
sommet: 
        lea.l   -9026(a4),a0
        moveq   #0,d6
        move.w  (a0)+,d6
        move.w  d6,d4
        add.w   (a3),d6
        swap    d6
        lsr.l   #1,d6
        add.w   d7,d4
        divu    d4,d6
        sub.w   #32768,d6
        move.w  #254,d4
        sub.w   2(a7),d4
        add.w   d4,d4
        mulu    0(a0,d4.w),d6
        swap    d6
        add.w   2(a3),d6
        lea.l   contevt(pc),a0
        move.w  #$4e75,(a0)
        lea.l   ffrou(pc),a0
        move.w  #$4e75,(a0)
        movem.l (a7)+,a0/d2
        move.l  (a3),-(a7)
        move.w  d7,(a3)
        move.w  d6,2(a3)
        bsr     desc1
        move.l  (a7)+,-(a3)
        addq.w  #1,d2
        movem.l a0/d2,-(a7)
        lea.l   contevt(pc),a0
        move.w  #$3e3a,(a0)
        lea.l   ffrou(pc),a0
        move.w  #$117c,(a0)

        move.w  #VMSUP,d7
        clr.w   d2
        move.b  vcohb(pc),d2
        sub.b   d2,d7
        move.w  #MINSUP,d4
        add.w   -8010(a4),d4
        bsr     rumond
        bra     procevt1
rumond:
        lsr.w   d7,d4
        and.l   #$ffff,d4
        add.l   evt-2(pc),d4
        cmp.l   #$7fff,d4
        ble.s   rumo3
        move.w  #$7fff,d4
rumo3:  move.w  d4,evtrup+2
        move.w  #1,evtrup
        cmp.w   evtrup+6(pc),d4
        bge.s   srumo3
        clr.w   adgam+14
        rts
srumo3: move.w  #4,adgam+14
        rts
rudes2: 
        lsr.w   d7,d4
        ext.l   d4
        add.l   evt-2(pc),d4
        cmp.l   #$7fff,d4
        ble.s   rumo4
        move.w  #$7fff,d4
rumo4:  move.w  d4,evtrup+2
        move.w  #$d,evtrup
        cmp.w   evtrup+6(pc),d4
        bge.s   srumo4
        clr.w   adgam+14
        rts
srumo4: move.w  #4,adgam+14
        rts
plamon: move.w  d7,rupmd
        sub.w   pdepl(pc),d7
        muls    d1,d7
        asr.l   #DECPL,d7
        add.w   d7,d3
        move.w  sdem(pc),d1
        move.b  (a0),d2
        move.b  d2,vcohb
        move.w  #VMSUP,d7
        sub.b   d2,d7
; rupt
        move.w  #MINSUP,d4
        sub.w   d1,d4
        bsr     rumond
        asr.w   d7,d1
        bsr     rt_md
        sub.w   d7,d3
        lsl.w   #3,d2
        lea.l   tasrl(pc),a0
        add.w   d2,a0
        lea.l   eetm1-2(pc),a1
        move.w  (a0)+,(a1)
        move.w  (a0)+,4(a1)
        move.w  (a0)+,10(a1)
        move.w  (a0),16(a1)
        clr.w   -8004(a4)
        lea.l   mont1(pc),a1
        move.w  #$10,tevco1
procevt1:
        addq.l  #8,adgam
procevt:
        moveq   #0,d7
        move.l  figam+4(pc),a0
        add.w   adgam+6(pc),a0
        move.w  2(a0),d7
        move.l  adgam(pc),a0
        cmp.w   #-1,(a0)
        bne.s   pchto2
        move.l  #CRCEVT,a0
        move.l  a0,adgam
        move.l  CRCLAP(pc),d2
        sub.l   d2,posvoit
pchto2:
        move.l  2(a0),d2
        sub.l   posvoit(pc),d2
        cmp.l   d2,d7
        bgt.L   gam13
        move.l  adgam+8(pc),a0
        move.w  2(a0),d2
        cmp.w   d2,d7
        bgt.s   gam3
        lea.l   evtrup(pc),a0
        add.w   adgam+14(pc),a0
        cmp.w   2(a0),d7
        bgt.s   tevtrup
        move.w  d7,evt
        move.w  #4,tevt
        movem.l (a7)+,a0/d2
        bra     contevt
tevtrup:
        subq.l  #8,adgam
        move.w  2(a0),evt
        move.w  #12,tevt
        movem.l (a7)+,a0/d2
        bra     contevt
gam3:   lea.l   evtrup(pc),a0
        add.w   adgam+14(pc),a0
        cmp.w   2(a0),d2
        bgt.s   tevtrup
        move.w  d2,evt
        move.w  #8,tevt
        movem.l (a7)+,a0/d2
        bra     contevt
gam13:  move.l  d2,d7
        move.l  adgam+8(pc),a0
        move.w  2(a0),d2
        ext.l   d2
        cmp.l   d2,d7
        bgt.s   gam3
        lea.l   evtrup(pc),a0
        add.w   adgam+14(pc),a0
        cmp.w   2(a0),d7
        bgt.s   tevtrup
        move.w  d7,evt
        clr.w   tevt
        movem.l (a7)+,a0/d2
        bra     contevt
plades: move.w  d7,rupmd
        sub.w   pdepl(pc),d7
        muls    d1,d7
        asr.l   #DECPL,d7
        add.w   d7,d3
        move.w  sdem(pc),d1
        move.b  (a0),d2
        move.b  d2,vcohb
        move.w  #VMSUP,d7
        sub.b   d2,d7
        move.w  d1,-(a7)
        move.w  d7,-(a7)
        asr.w   d7,d1
        bsr     rt_md
        add.w   d7,d3
; rupt
        move.w  (a7)+,d7
        move.w  d1,d6
        ext.l   d6
        add.l   evt-2(pc),d6
        move.w  d3,d4
        bge.s   moi2
        neg.w   d4
        ext.l   d4
        cmp.l   d6,d4
        bge.s   pmoi2
        mulu    #36000,d4
        divu    d6,d4
        cmp.w   #16000,d4
        bgt.s   pmoi2
        neg.w   d4
        bra.s   cmoi2
moi2:   ext.l   d4
        cmp.l   d6,d4
        bge.s   pmoi2
        mulu    #36000,d4
        divu    d6,d4
        cmp.w   #19000,d4
        bgt.s   pmoi2
cmoi2:  cmp.w   (a7),d4
        bgt.s   pmoi2
        move.w  d4,-8010(a4)
        sub.w   (a7)+,d4
        neg.w   d4
        bsr     rudes2
        bra.s   smoi2
pmoi2:  move.w  #MINSUP,d4
        add.w   (a7)+,d4
        bsr     rumond
smoi2:  lsl.w   #3,d2
        lea.l   tasrl(pc),a0
        add.w   d2,a0
        lea.l   eetd1-2(pc),a1
        move.w  (a0)+,(a1)
        move.w  (a0)+,4(a1)
        move.w  (a0)+,10(a1)
        move.w  (a0),18(a1)
        move.l  #$ffff,-8004(a4)
        lea.l   desc1(pc),a1
        move.w  #$20,tevco1
        bra     procevt1
mondes: sub.w   rupmd(pc),d7
        add.w   d7,d1
        move.b  vcohb(pc),d2
        bsr     rt_md
        add.w   d7,d3
        move.w  #VMSUP,d7
        sub.b   d2,d7
        asl.w   d7,d1
        move.b  (a0),d2
        move.b  d2,vcohb
        move.w  #VMSUP,d7
        sub.b   d2,d7
        move.w  d1,-(a7)
        move.w  d7,-(a7)
        asr.w   d7,d1
        bsr     rt_md
        add.w   d7,d3
; rupt
        move.w  (a7)+,d7
        move.w  d1,d6
        ext.l   d6
        add.l   evt-2(pc),d6
        move.w  d3,d4
        bge.s   moi3
        neg.w   d4
        ext.l   d4
        cmp.l   d6,d4
        bge.s   pmoi3
        mulu    #36000,d4
        divu    d6,d4
        cmp.w   #16000,d4
        bgt.s   pmoi3
        neg.w   d4
        bra.s   cmoi3
moi3:   ext.l   d4
        cmp.l   d6,d4
        bge.s   pmoi3
        mulu    #36000,d4
        divu    d6,d4
        cmp.w   #19000,d4
        bgt.s   pmoi3
cmoi3:  cmp.w   (a7),d4
        bgt.s   pmoi3
        move.w  d4,-8010(a4)
        sub.w   (a7)+,d4
        neg.w   d4
        bsr     rudes2
        bra.s   smoi3
pmoi3:  move.w  #MINSUP,d4
        add.w   (a7)+,d4
        bsr     rumond
smoi3:  lsl.w   #3,d2
        lea.l   tasrl(pc),a0
        add.w   d2,a0
        lea.l   eetd1-2(pc),a1
        move.w  (a0)+,(a1)
        move.w  (a0)+,4(a1)
        move.w  (a0)+,10(a1)
        move.w  (a0),18(a1)
        move.l  #$ffff,-8004(a4)
        lea.l   desc1(pc),a1
        move.w  evt(pc),rupmd
        move.w  #$20,tevco1
        bra     procevt1
desmon: sub.w   rupmd(pc),d7
        sub.w   d7,d1
        move.b  vcohb(pc),d2
        bsr     rt_md
        sub.w   d7,d3
        move.w  #VMSUP,d7
        sub.b   d2,d7
        asl.w   d7,d1
        move.b  (a0),d2
        move.b  d2,vcohb
        move.w  #VMSUP,d7
        sub.b   d2,d7
; rupt
        move.w  #MINSUP,d4
        sub.w   d1,d4
        bsr     rumond
        asr.w   d7,d1
        bsr     rt_md
        sub.w   d7,d3
        lsl.w   #3,d2
        lea.l   tasrl(pc),a0
        add.w   d2,a0
        lea.l   eetm1-2(pc),a1
        move.w  (a0)+,(a1)
        move.w  (a0)+,4(a1)
        move.w  (a0)+,10(a1)
        move.w  (a0),16(a1)
        clr.w   -8004(a4)
        lea.l   mont1(pc),a1
        move.w  evt(pc),rupmd
        move.w  #$10,tevco1
        bra     procevt1
monpla: move.b  vcohb(pc),d2
        move.w  d7,pdepl
        sub.w   rupmd(pc),d7
        add.w   d7,d1
        bsr     rt_md
        add.w   d7,d3
        bsr     rt_pmd
        move.w  #VMSUP,d6
        sub.w   d2,d6
        asl.w   d6,d1
        move.w  d1,sdem
        move.w  d7,d1
        move.l  #$ffff,-8004(a4)
        lea.l   plat0(pc),a1
        clr.w   tevco1
        move.w  #4,adgam+14
        move.w  #$7fff,evtrup+2
        bra     procevt1
despla: move.b  vcohb(pc),d2
        move.w  d7,pdepl
        sub.w   rupmd(pc),d7
        sub.w   d7,d1
        bsr     rt_md
        sub.w   d7,d3
        bsr     rt_pmd
        move.w  #VMSUP,d6
        sub.w   d2,d6
        asl.w   d6,d1
        move.w  d1,sdem
        move.w  d7,d1
        move.l  #$ffff,-8004(a4)
        lea.l   plat0(pc),a1
        clr.w   tevco1
        move.w  #4,adgam+14
        move.w  #$7fff,evtrup+2
        bra     procevt1
courbu: move.w  (a0),d2
        and.w   #$000c,d2
        or.w    tevco2(pc),d2
        jmp     ancno2(pc,d2.w)
ancno2: 
        bra.l   procevt1
        bra.l   pladrt
        bra.l   plagch
        bra.l   procevt1

        bra.l   drtpla
        bra.l   drtdrt
        bra.l   drtgch
        bra.l   procevt1

        bra.l   gchpla
        bra.l   gchdrt
        bra.l   gchgch
        bra.l   procevt1
drtdrt: sub.w   rupco(pc),d7
        ext.l   d7
        add.l   d7,d5
        move.b  vcodg(pc),d2
        bsr     rt_dg
        add.l   d7,d0
        move.w  #VCSUP,d7
        sub.b   d2,d7
        asl.l   d7,d5
        move.b  (a0),d2
        move.b  d2,vcodg
        move.w  #VCSUP,d7
        sub.b   d2,d7
; rupt
        move.l  #CINSUP,d4
        sub.l   d5,d4
        bsr     rucond
        asr.l   d7,d5
        bsr     rt_dg
        sub.l   d7,d0
        lsl.w   #3,d2
        lea.l   tasrl+64(pc),a0
        add.w   d2,a0
        lea.l   eecd1-2(pc),a2
        move.w  (a0)+,(a2)
        move.w  (a0)+,4(a2)
        move.w  (a0)+,10(a2)
        move.w  (a0),18(a2)
        move.w  evt(pc),rupco
        lea.l   vird1(pc),a2
        bra     procevt1
rucond:
        asr.l   d7,d4
        add.l   evt-2(pc),d4
        cmp.l   #$7fff,d4
        ble.s   ruco3
        move.w  #$7fff,d4
ruco3:  move.w  d4,evtrup+6
        cmp.w   evtrup+2(pc),d4
        bge.s   sruco3
        move.w  #4,adgam+14
        rts
sruco3: clr.w   adgam+14
        rts
gchgch: sub.w   rupco(pc),d7
        ext.l   d7
        sub.l   d7,d5
        move.b  vcodg(pc),d2
        bsr     rt_dg
        sub.l   d7,d0
        move.w  #VCSUP,d7
        sub.b   d2,d7
        asl.l   d7,d5
        move.b  (a0),d2
        move.b  d2,vcodg
        move.w  #VCSUP,d7
        sub.b   d2,d7
; rupt
        move.l  #CINSUP,d4
        add.l   d5,d4
        bsr     rucond
        asr.l   d7,d5
        bsr     rt_dg
        add.l   d7,d0
        lsl.w   #3,d2
        lea.l   tasrl+64(pc),a0
        add.w   d2,a0
        lea.l   eecg1-2(pc),a2
        move.w  (a0)+,(a2)
        move.w  (a0)+,4(a2)
        move.w  (a0)+,10(a2)
        move.w  (a0),20(a2)
        move.w  evt(pc),rupco
        lea.l   virg1(pc),a2
        bra     procevt1
pladrt: move.w  d7,rupco
        sub.w   pdeld(pc),d7
        muls    d5,d7
        asr.l   #DECPL,d7
        add.l   d7,d0
        move.l  sdec(pc),d5
        move.b  (a0),d2
        move.b  d2,vcodg
        move.w  #VCSUP,d7
        sub.b   d2,d7
; rupt
        move.l  #CINSUP,d4
        sub.l   d5,d4
        bsr     rucond
        asr.l   d7,d5
        bsr     rt_dg
        sub.l   d7,d0
        lsl.w   #3,d2
        lea.l   tasrl+64(pc),a0
        add.w   d2,a0
        lea.l   eecd1-2(pc),a2
        move.w  (a0)+,(a2)
        move.w  (a0)+,4(a2)
        move.w  (a0)+,10(a2)
        move.w  (a0),18(a2)
        lea.l   vird1(pc),a2
        move.w  #$10,tevco2
        bra     procevt1
plagch: move.w  d7,rupco
        sub.w   pdeld(pc),d7
        muls    d5,d7
        asr.l   #DECPL,d7
        add.l   d7,d0
        move.l  sdec(pc),d5
        move.b  (a0),d2
        move.b  d2,vcodg
        move.w  #VCSUP,d7
        sub.b   d2,d7
; rupt
        move.l  #CINSUP,d4
        add.l   d5,d4
        bsr     rucond
        asr.l   d7,d5
        bsr     rt_dg
        add.l   d7,d0
        lsl.w   #3,d2
        lea.l   tasrl+64(pc),a0
        add.w   d2,a0
        lea.l   eecg1-2(pc),a2
        move.w  (a0)+,(a2)
        move.w  (a0)+,4(a2)
        move.w  (a0)+,10(a2)
        move.w  (a0),20(a2)
        lea.l   virg1(pc),a2
        move.w  #$20,tevco2
        bra     procevt1
drtgch: sub.w   rupco(pc),d7
        ext.l   d7
        add.l   d7,d5
        move.b  vcodg(pc),d2
        bsr     rt_dg
        add.l   d7,d0
        move.w  #VCSUP,d7
        sub.b   d2,d7
        asl.l   d7,d5
        move.b  (a0),d2
        move.b  d2,vcodg
        move.w  #VCSUP,d7
        sub.b   d2,d7
; rupt
        move.l  #CINSUP,d4
        add.l   d5,d4
        bsr     rucond
        asr.l   d7,d5
        bsr     rt_dg
        add.l   d7,d0
        lsl.w   #3,d2
        lea.l   tasrl+64(pc),a0
        add.w   d2,a0
        lea.l   eecg1-2(pc),a2
        move.w  (a0)+,(a2)
        move.w  (a0)+,4(a2)
        move.w  (a0)+,10(a2)
        move.w  (a0),20(a2)
        lea.l   virg1(pc),a2
        move.w  evt(pc),rupco
        move.w  #$20,tevco2
        bra     procevt1
gchdrt: sub.w   rupco(pc),d7
        ext.l   d7
        sub.l   d7,d5
        move.b  vcodg(pc),d2
        bsr     rt_dg
        sub.l   d7,d0
        move.w  #VCSUP,d7
        sub.b   d2,d7
        asl.l   d7,d5
        move.b  (a0),d2
        move.b  d2,vcodg
        move.w  #VCSUP,d7
        sub.b   d2,d7
; rupt
        move.l  #CINSUP,d4
        sub.l   d5,d4
        bsr     rucond
        asr.l   d7,d5
        bsr     rt_dg
        sub.l   d7,d0
        lsl.w   #3,d2
        lea.l   tasrl+64(pc),a0
        add.w   d2,a0
        lea.l   eecd1-2(pc),a2
        move.w  (a0)+,(a2)
        move.w  (a0)+,4(a2)
        move.w  (a0)+,10(a2)
        move.w  (a0),18(a2)
        lea.l   vird1(pc),a2
        move.w  evt(pc),rupco
        move.w  #$10,tevco2
        bra     procevt1
drtpla: move.b  vcodg(pc),d2
        move.w  d7,pdeld
        sub.w   rupco(pc),d7
        ext.l   d7
        add.l   d7,d5
        bsr     rt_dg
        add.l   d7,d0
        bsr     rt_pdg
        move.w  #VCSUP,d6
        sub.w   d2,d6
        asl.l   d6,d5
        move.l  d5,sdec
        move.w  d7,d5
        lea.l   droit1(pc),a2
        clr.w   tevco2
        move.w  #$7fff,evtrup+6
        clr.w   adgam+14
        bra     procevt1
gchpla: move.b  vcodg(pc),d2
        move.w  d7,pdeld
        sub.w   rupco(pc),d7
        ext.l   d7
        sub.l   d7,d5
        bsr     rt_dg
        sub.l   d7,d0
        bsr     rt_pdg
        move.w  #VCSUP,d6
        sub.w   d2,d6
        asl.l   d6,d5
        move.l  d5,sdec
        move.w  d7,d5
        lea.l   droit1(pc),a2
        clr.w   tevco2
        move.w  #$7fff,evtrup+6
        clr.w   adgam+14
        bra     procevt1

objet1: move.w  a5,-(sp)
        move.l  usp,a5
        move.w  4(a7),d6
        addq.w  #2,d6
        move.w  (a0),(a5)
        clr.b   8(a5)
        cmp.w   #8,tevt
        bne.s   patut
        clr.b   5(a5)
        move.w  4(a0),d2
        asl.w   #1,d2
        bra.s   spatut
patut:  move.w  6(a0),d2
        lsl.w   #1,d2
        asr.w   #1,d2
        btst    #7,6(a0)
        bne.s   left
        clr.b   5(a5)
        add.w   #255,d2
        bra.s   spat
left:   sub.w   #255,d2
        move.b  #1,5(a5)
spat:   asl.w   #1,d2
        btst    #3,1(a0)
        beq.s   spatut  ;trt obj dbl pied
        move.w  d2,6+8(a5)
        neg.w   6+8(a5)
        move.b  #254,8(a5)
spatut: move.w  d2,6(a5)
        move.b  d6,1(a5)
        bne.s   vhorl
        move.b  #$ff,1(a5)
vhorl:  lea.l   -9026(a4),a0
        moveq   #0,d6
        move.w  (a0)+,d6
        move.w  d6,d4
        add.w   (a3),d6
        swap    d6
        lsr.l   #1,d6
        add.w   d7,d4
        divu    d4,d6
        sub.w   #32768,d6
        move.w  #254,d4
        sub.w   4(a7),d4
        add.w   d4,d4
        mulu    0(a0,d4.w),d6
        swap    d6
        add.w   2(a3),d6
        jmp     -4(a1)
retobj: add.w   #160,6(a5)
        lea.l   8(a5),a5
        tst.b   (a5)
        beq.s   sreto
        clr.b   8(a5)
        jmp     -4(a2)
sreto:  move.l  a5,usp
        move.w  (sp)+,a5
        cmp.w   #8,tevt
        bne     procevt1
        addq.l  #6,adgam+8
        bra     procevt
omont1: move.w  d1,d4
        sub.w   rupmd(pc),d4
        add.w   d7,d4
        clr.w   d2
        move.b  vcohb(pc),d2
        bsr     rt_omd
        add.w   d3,d7
        muls    d6,d7
        bra.s   omonco
odes1:  move.w  d1,d4
        sub.w   d7,d4
        add.w   rupmd(pc),d4
        clr.w   d2
        move.b  vcohb(pc),d2
        bsr     rt_omd
        neg.w   d7
        add.w   d3,d7
        muls    d6,d7
        bra.s   omonco
odrt1:  
        sub.w   pdepl(pc),d7
        muls    d1,d7
        asr.l   #DECPL,d7
        add.w   d3,d7
        muls    d6,d7
omonco: swap    d7
        neg.w   d7
        add.w   #199+DEMAR,d7
        move.w  d7,2(a5)
        move.w  (a7),d4
        neg.w   d4
        add.w   #200+DEMAR,d4
        move.b  d4,4(a5)
        jmp     -4(a2)

odrot1: move.w  evt(pc),d4
        sub.w   rupco(pc),d4
        ext.l   d4
        add.l   d5,d4
        clr.w   d2
        move.b  vcodg(pc),d2
        bsr     rt_odg
        bra.s   ocouco
ogch1:  move.w  rupco(pc),d4
        sub.w   evt(pc),d4
        ext.l   d4
        add.l   d5,d4
        clr.w   d2
        move.b  vcodg(pc),d2
        bsr     rt_odg
        neg.l   d7
        bra.s   ocouco
odrit:  
        move.w  evt(pc),d7
        sub.w   pdeld(pc),d7
        muls    d5,d7
        asr.l   #DECPL,d7
ocouco: add.l   d0,d7
        move.w  6(a5),d4
        ext.l   d4
        add.l   d4,d7
        blt.s   vdnego
;        asl.l   #1,d7
        move.w  d7,d4
        mulu    d6,d4
        swap    d4
        swap    d7
        subq.w  #1,d7
        blt.s   fvdro
svdro:  add.w   d6,d4
;        dbf     d2,svdro
fvdro:  move.w  d4,6(a5)
        bra.L   retobj
vdnego: 
;        asl.l   #1,d7
        move.w  d7,d4
        mulu    d6,d4
        swap    d4
        swap    d7
        neg.w   d7
        subq.w  #1,d7
        sub.w   d6,d4
        dbf     d7,snvdro
        move.w  d4,6(a5)
        bra     retobj
snvdro: sub.w   d6,d4
        move.w  d4,6(a5)
        bra     retobj
contevt:
        move.w  evt(pc),d7
        cmp.w   (a3),d7
        blt.s   strevt
        jmp     (a1)
strevt: movem.l a0/d2,-(a7)
        move.w  tevt(pc),d2
        move.l  adgam(pc,d2.w),a0
        add.l   figam(pc,d2.w),a0
        move.w  (a0),d2
        and.w   #$0003,d2
        add.w   d2,d2
        add.w   d2,d2
        jmp     natur(pc,d2.w)
        dc.w    0
evt:    dc.w    0
tevt:   dc.w    0
adgam:  dc.l    0,0,0,0
figam:  dc.l    0,0,0
        dc.l    evtrup
natur:  bra.l   courbu
        bra.l   inclin
        bra.l   objet1
        bra.l   objdiv
rt_omd: add.w   d2,d2
        add.w   d2,d2
        move.w  d4,d7
        jmp     ta_omd(pc,d2.w)
ta_omd:  
        bra.l   mo0
        bra.l   mo1
        bra.l   mo2
        bra.l   mo3
        bra.l   mo4
        bra.l   mo5
        bra.l   mo6
        bra.l   mo7
mo0:    asl.w   #3,d4
        move.w  0(a4,d4.w),d7
        asr.w   #5,d7
        rts
mo1:    asl.w   #2,d4
        move.w  0(a4,d4.w),d7
        asr.w   #4,d7
        rts
mo2:    and.w   #$fffe,d4
        sub.w   d4,d7
        add.w   d4,d4
        muls    2(a4,d4.w),d7
        asr.w   #1,d7
        add.w   0(a4,d4.w),d7
        asr.w   #3,d7
        rts
mo3:    and.w   #$fffc,d4
        sub.w   d4,d7
        muls    2(a4,d4.w),d7
        asr.w   #2,d7
        add.w   0(a4,d4.w),d7
        asr.w   #2,d7
        rts
mo4:    and.w   #$fff8,d4
        sub.w   d4,d7
        asr.w   #1,d4
        muls    2(a4,d4.w),d7
        asr.w   #3,d7
        add.w   0(a4,d4.w),d7
        asr.w   #1,d7
        rts
mo5:    and.w   #$fff0,d4
        sub.w   d4,d7
        asr.w   #2,d4
        muls    2(a4,d4.w),d7
        asr.w   #4,d7
        add.w   0(a4,d4.w),d7
        rts
mo6:    and.w   #$ffe0,d4
        sub.w   d4,d7
        asr.w   #3,d4
        muls    2(a4,d4.w),d7
        asr.w   #5,d7
        add.w   0(a4,d4.w),d7
        add.w   d7,d7
        rts
mo7:    and.w   #$ffc0,d4
        sub.w   d4,d7
        asr.w   #4,d4
        muls    2(a4,d4.w),d7
        asr.w   #6,d7
        add.w   0(a4,d4.w),d7
        asl.w   #2,d7
        rts
rt_md:  move.w  d2,d4
        add.w   d4,d4
        add.w   d4,d4
        jmp     ta_md(pc,d4.w)
ta_md:  
        bra.l   md0
        bra.l   md1
        bra.l   md2
        bra.l   md3
        bra.l   md4
        bra.l   md5
        bra.l   md6
        bra.l   md7
md0:    move.w  d1,d4
        asl.w   #3,d4
        move.w  0(a4,d4.w),d7
        asr.w   #5,d7
        rts
md1:    move.w  d1,d4
        asl.w   #2,d4
        move.w  0(a4,d4.w),d7
        asr.w   #4,d7
        rts
md2:    move.w  d1,d4
        move.w  d1,d7
        and.w   #$fffe,d4
        sub.w   d4,d7
        add.w   d4,d4
        muls    2(a4,d4.w),d7
        asr.w   #1,d7
        add.w   0(a4,d4.w),d7
        asr.w   #3,d7
        rts
md3:    move.w  d1,d4
        move.w  d1,d7
        and.w   #$fffc,d4
        sub.w   d4,d7
        muls    2(a4,d4.w),d7
        asr.w   #2,d7
        add.w   0(a4,d4.w),d7
        asr.w   #2,d7
        rts
md4:    move.w  d1,d4
        move.w  d1,d7
        and.w   #$fff8,d4
        sub.w   d4,d7
        asr.w   #1,d4
        muls    2(a4,d4.w),d7
        asr.w   #3,d7
        add.w   0(a4,d4.w),d7
        asr.w   #1,d7
        rts
md5:    move.w  d1,d4
        move.w  d1,d7
        and.w   #$fff0,d4
        sub.w   d4,d7
        asr.w   #2,d4
        muls    2(a4,d4.w),d7
        asr.w   #4,d7
        add.w   0(a4,d4.w),d7
        rts
md6:    move.w  d1,d4
        move.w  d1,d7
        and.w   #$ffe0,d4
        sub.w   d4,d7
        asr.w   #3,d4
        muls    2(a4,d4.w),d7
        asr.w   #5,d7
        add.w   0(a4,d4.w),d7
        add.w   d7,d7
        rts
md7:    move.w  d1,d4
        move.w  d1,d7
        and.w   #$ffc0,d4
        sub.w   d4,d7
        asr.w   #4,d4
        muls    2(a4,d4.w),d7
        asr.w   #6,d7
        add.w   0(a4,d4.w),d7
        asl.w   #2,d7
        rts
rt_odg: add.w   d2,d2
        add.w   d2,d2
        move.l  d4,d7
        jmp     ta_odg(pc,d2.w)
ta_odg:  
        bra.l   do0
        bra.l   do1
        bra.l   do2
        bra.l   do3
        bra.l   do4
        bra.l   do5
        bra.l   do6
        bra.l   do7
do0:    asl.w   #3,d4
        move.w  0(a4,d4.w),d7
        asr.w   #5,d7
        ext.l   d7
        rts
do1:    asl.w   #2,d4
        move.w  0(a4,d4.w),d7
        asr.w   #4,d7
        ext.l   d7
        rts
do2:    and.w   #$fffe,d4
        sub.w   d4,d7
        add.w   d4,d4
        muls    2(a4,d4.w),d7
        asr.w   #1,d7
        add.w   0(a4,d4.w),d7
        asr.w   #3,d7
        ext.l   d7
        rts
do3:    and.w   #$fffc,d4
        sub.w   d4,d7
        muls    2(a4,d4.w),d7
        asr.w   #2,d7
        add.w   0(a4,d4.w),d7
        asr.w   #2,d7
        ext.l   d7
        rts
do4:    and.w   #$fff8,d4
        sub.w   d4,d7
        asr.w   #1,d4
        muls    2(a4,d4.w),d7
        asr.w   #3,d7
        add.w   0(a4,d4.w),d7
        asr.w   #1,d7
        ext.l   d7
        rts
do5:    and.w   #$fff0,d4
        sub.w   d4,d7
        asr.w   #2,d4
        muls    2(a4,d4.w),d7
        asr.w   #4,d7
        add.w   0(a4,d4.w),d7
        ext.l   d7
        rts
do6:    and.w   #$ffe0,d4
        sub.w   d4,d7
        asr.l   #3,d4
        muls    2(a4,d4.w),d7
        asr.w   #5,d7
        add.w   0(a4,d4.w),d7
        ext.l   d7
        add.w   d7,d7
        rts
do7:    and.w   #$ffc0,d4
        sub.w   d4,d7
        asr.l   #4,d4
        muls    2(a4,d4.w),d7
        asr.w   #6,d7
        add.w   0(a4,d4.w),d7
        ext.l   d7
        asl.l   #2,d7
        rts
rt_dg:  move.w  d2,d4
        add.w   d4,d4
        add.w   d4,d4
        jmp     ta_dg(pc,d4.w)
ta_dg:  
        bra.l   dg0
        bra.l   dg1
        bra.l   dg2
        bra.l   dg3
        bra.l   dg4
        bra.l   dg5
        bra.l   dg6
        bra.l   dg7
dg0:    move.l  d5,d4
        asl.w   #3,d4
        move.w  0(a4,d4.w),d7
        asr.w   #5,d7
        ext.l   d7
        rts
dg1:    move.l  d5,d4
        asl.w   #2,d4
        move.w  0(a4,d4.w),d7
        asr.w   #4,d7
        ext.l   d7
        rts
dg2:    move.l  d5,d4
        move.l  d5,d7
        and.w   #$fffe,d4
        sub.w   d4,d7
        add.w   d4,d4
        muls    2(a4,d4.w),d7
        asr.w   #1,d7
        add.w   0(a4,d4.w),d7
        asr.w   #3,d7
        ext.l   d7
        rts
dg3:    move.l  d5,d4
        move.l  d5,d7
        and.w   #$fffc,d4
        sub.w   d4,d7
        muls    2(a4,d4.w),d7
        asr.w   #2,d7
        add.w   0(a4,d4.w),d7
        asr.w   #2,d7
        ext.l   d7
        rts
dg4:    move.l  d5,d4
        move.l  d5,d7
        and.w   #$fff8,d4
        sub.w   d4,d7
        asr.w   #1,d4
        muls    2(a4,d4.w),d7
        asr.w   #3,d7
        add.w   0(a4,d4.w),d7
        asr.w   #1,d7
        ext.l   d7
        rts
dg5:    move.l  d5,d4
        move.l  d5,d7
        and.w   #$fff0,d4
        sub.w   d4,d7
        asr.w   #2,d4
        muls    2(a4,d4.w),d7
        asr.w   #4,d7
        add.w   0(a4,d4.w),d7
        ext.l   d7
        rts
dg6:    move.l  d5,d4
        move.l  d5,d7
        and.w   #$ffe0,d4
        sub.w   d4,d7
        asr.l   #3,d4
        muls    2(a4,d4.w),d7
        asr.w   #5,d7
        add.w   0(a4,d4.w),d7
        ext.l   d7
        add.w   d7,d7
        rts
dg7:    move.l  d5,d4
        move.l  d5,d7
        and.w   #$ffc0,d4
        sub.w   d4,d7
        asr.l   #4,d4
        muls    2(a4,d4.w),d7
        asr.w   #6,d7
        add.w   0(a4,d4.w),d7
        ext.l   d7
        asl.l   #2,d7
        rts
rt_pdg: lea.l   0(a4,d4.w),a2
        move.w  MADE(a2),d7
        add.w   MADE-4(a2),d7
        add.w   MADE-8(a2),d7
        add.w   MADE-12(a2),d7
        add.w   MADE-16(a2),d7
        add.w   MADE+4(a2),d7
        add.w   MADE+8(a2),d7
        add.w   MADE+12(a2),d7
        sub.w   MIDE(a2),d7
        sub.w   MIDE-4(a2),d7
        sub.w   MIDE-8(a2),d7
        sub.w   MIDE-12(a2),d7
        sub.w   MIDE-16(a2),d7
        sub.w   MIDE+4(a2),d7
        sub.w   MIDE+8(a2),d7
        sub.w   MIDE+12(a2),d7
        asr.w   #3,d7
        rts
rt_pmd: lea.l   0(a4,d4.w),a1
        move.w  MADE(a1),d7
        add.w   MADE-4(a1),d7
        add.w   MADE-8(a1),d7
        add.w   MADE-12(a1),d7
        add.w   MADE-16(a1),d7
        add.w   MADE+4(a1),d7
        add.w   MADE+8(a1),d7
        add.w   MADE+12(a1),d7
        sub.w   MIDE(a1),d7
        sub.w   MIDE-4(a1),d7
        sub.w   MIDE-8(a1),d7
        sub.w   MIDE-12(a1),d7
        sub.w   MIDE-16(a1),d7
        sub.w   MIDE+4(a1),d7
        sub.w   MIDE+8(a1),d7
        sub.w   MIDE+12(a1),d7
        asr.w   #3,d7
        rts
evtrup: dc.w    1,$7fff,0,$7fff
degre:  dc.l    0
vites:  dc.w    0
rupmd:  dc.w    0
rupco:  dc.w    0
tevco1: dc.w    0
tevco2: dc.w    0
        dc.w    0
topvib: dc.w    0
vitco:  dc.w    0
vibco:  dc.w    0
hautco: dc.w    0
valhau: dc.w    0
saucra: dc.w    0
crasco: dc.w    0
inild:  dc.w    0
decaco: dc.l    0
haplco: dc.w    0
haldco: dc.l    0
hald:   dc.w    0
hapl:   dc.w    0
pdeld:  dc.w    0
pdepl:  dc.w    0
sdem:   dc.w    0
sdec:   dc.l    0
inico:  dc.w    2
evnmo:  dc.b    0
evnco:  dc.b    0
vamo:   dc.b    0
vaco:   dc.b    0
vcohb:  dc.b    0
vcodg:  dc.b    0
X2:     DC.W    2
SXB:    dc.w    0
VCHAMP: DC.W    970,797,622,506
DCHAMP: DC.W    622,2
lisacc: dc.w    0
esevt1: dc.w    7,0,3,500
        dc.w    7,1000,3,1500
        dc.w    7,2000,3,2500
        dc.w    7,3000,3,3500
        dc.w    7,4000,3,4500
        dc.w    7,5000,3,5500
        dc.w    7,6000,3,6500
        dc.w    7,7001,0,$7fff
deevt1:  dc.l    0
adscrol: dc.l   0
posvoit: dc.l   0
        dc.l    0
zafvo:  ds.w    96
vigch:  dc.b    0
vidrt:  dc.b    0
teor1:  dc.w    $100,$100,$101,$101,1,1,$101,$101
        dc.b    1,-1,0,0,1,0,0,0,1,-1,1,0,1,-2,1,-2
        dc.b    0,0,1,-1,0,0,1,0,1,0,1,-1,1,-2,1,-2
F1DEP:  dc.l    0

admodr:         dc.l    0
topcod:         dc.w    0
topdep:         dc.w    0
topmod:         dc.w    0
comodr:         dc.w    0
depmod:         dc.w    0
mvtscrol:   dc.w    0
reste:  dc.w    0
volant: dc.w    0
moment: dc.w    0       ;moment du a la pente
dafec:  dc.w    0
rafec:  dc.w    0
htprl:  dc.w    -128
NSON:   dc.w    -1

tasrl:
        dc.w    $ffff
        asl.w   #3,d7
        nop
        asr.w   #5,d4
        dc.w    $ffff
        asl.w   #2,d7
        nop
        asr.w   #4,d4
        dc.w    $fffe
        add.w   d7,d7
        asr.w   #1,d4
        asr.w   #3,d4
        dc.w    $fffc
        nop
        asr.w   #2,d4
        asr.w   #2,d4
        dc.w    $fff8
        asr.w   #1,d7
        asr.w   #3,d4
        asr.w   #1,d4
        dc.w    $fff0
        asr.w   #2,d7
        asr.w   #4,d4
        nop
        dc.w    $ffe0
        asr.w   #3,d7
        asr.w   #5,d4
        add.w   d4,d4
        dc.w    $ffc0
        asr.w   #4,d7
        asr.w   #6,d4
        asl.w   #2,d4
* table courbe
        dc.w    $ffff
        asl.w   #3,d6
        nop
        asr.w   #5,d7
        dc.w    $ffff
        asl.w   #2,d6
        nop
        asr.w   #4,d7
        dc.w    $fffe
        add.w   d6,d6
        asr.w   #1,d7
        asr.w   #3,d7
        dc.w    $fffc
        nop
        asr.w   #2,d7
        asr.w   #2,d7
        dc.w    $fff8
        asr.w   #1,d6
        asr.w   #3,d7
        asr.w   #1,d7
        dc.w    $fff0
        asr.w   #2,d6
        asr.w   #4,d7
        nop
        dc.w    $ffe0
        asr.l   #3,d6
        asr.w   #5,d7
        add.w   d7,d7
        dc.w    $ffc0
        asr.l   #4,d6
        asr.w   #6,d7
        asl.l   #2,d7
;* Display Road

DSPROD: MOVE.L  #RODEQU,A0
        MOVE.L  CURSCR(PC),A1
        ADD.L   #32000,A1
        CLR.W   D4
        MOVE.L  #$0000FFFF,A5
        MOVE.L  A5,A2
        MOVEQ   #0,D6
        MOVE.L  D6,A4
        MOVE.L  #-1,D5
        MOVE.L  D5,A3
        BRA.L   BDSPRO
QUEVERT:
        MOVEM.L A5/A4/A2/D6,-(A1)
        MOVEM.L A5/A4/A2/D6,-(A1)
        MOVEM.L A5/A4/A2/D6,-(A1)
        MOVEM.L A5/A4/A2/D6,-(A1)
        MOVEM.L A5/A4/A2/D6,-(A1)
        MOVEM.L A5/A4/A2/D6,-(A1)
        MOVEM.L A5/A4/A2/D6,-(A1)
        MOVEM.L A5/A4/A2/D6,-(A1)
        MOVEM.L A5/A4/A2/D6,-(A1)
        MOVEM.L A5/A4/A2/D6,-(A1)
        BRA.L   FINLIG
RESTGRI:
        BCLR    D6,D3
        BEQ.S   GRIS2
        MOVEM.L A5/A3,-(A1)
GRIS2:  NEG.W   D3
        ADD.W   D3,D3
        JMP     FGRIS2(PC,D3.W)
QUEGRIS:
        MOVEM.L A5/A3/A2/D5,-(A1)
        MOVEM.L A5/A3/A2/D5,-(A1)
        MOVEM.L A5/A3/A2/D5,-(A1)
        MOVEM.L A5/A3/A2/D5,-(A1)
        MOVEM.L A5/A3/A2/D5,-(A1)
        MOVEM.L A5/A3/A2/D5,-(A1)
        MOVEM.L A5/A3/A2/D5,-(A1)
        MOVEM.L A5/A3/A2/D5,-(A1)
        MOVEM.L A5/A3/A2/D5,-(A1)
        MOVEM.L A5/A3/A2/D5,-(A1)
FGRIS2: TST.W   8(A0)
        BGT     FINLIG
        MOVE.L  A1,D7
        MOVE.W  (A0),D0
        MOVE.W  D0,D1
        MOVE.W  6(A0),D3
        LSR.W   #2,D3
        BEQ     FINLIG
        SUB.W   D3,D0
        ADD.W   D3,D1
        BLE.L   BLANC2
        MOVE.W  D1,D2
        LSR.W   #1,D1
        AND.W   #$FFF8,D1
        CMP.W   #160,D1
        BLT.S   BLANCOK
        CMP.W   #320,D0
        BGE.L   BLANC2
        MOVE.W  #160,D1
        LEA.L   162(A1),A1
        BRA.S   SBL3
BLANCOK:
        ADD.W   D1,A1
        addq.w  #2,a1
        AND.W   #$F,D2
        ADD.W   D2,D2
        MOVE.W  TBPIX1+32(PC,D2.W),(A1)
SBL3:   MOVE.W  D0,D2
        BGE.S   SBL0
        CLR.W   D0
        CLR.W   D2
        BRA.S   SBL1
SBL0:   LSR.W   #1,D0
        AND.W   #$FFF8,D0
SBL1:   SUB.W   D0,D1
        BGT.S   SBLANC
        AND.W   #$F,D2
        ADD.W   D2,D2
        MOVE.W  TBPIX1(PC,D2.W),D2
        OR.W    D2,(A1)
        BRA.S   PABLANC
SBLANC: SUB.W   D1,A1
        AND.W   #$F,D2
        ADD.W   D2,D2
        MOVE.W  TBPIX1(PC,D2.W),(A1)
SBL2:   SUBQ.W  #8,D1
        BLE.S   PABLANC
        LEA.L   8(A1),A1
        MOVE.W  TBPIX1(PC),(A1)
        BRA.S   SBL2
TBPIX1:  DC.W   $0000,$8000,$C000,$E000
         DC.W   $F000,$F800,$FC00,$FE00
         DC.W   $FF00,$FF80,$FFC0,$FFE0
         DC.W   $FFF0,$FFF8,$FFFC,$FFFE

         DC.W   $FFFF,$7FFF,$3FFF,$1FFF
         DC.W   $0FFF,$07FF,$03FF,$01FF
         DC.W   $00FF,$007F,$003F,$001F
         DC.W   $000F,$0007,$0003,$0001  
PABLANC:
        MOVE.L  D7,A1
BLANC2: CMP.B   #-1,8(A0)
        BGT.L   FINLIG
        BLT.S   BANGAU
        MOVE.W  (A0),D2
        MOVE.W  D2,D0
        SUB.W   2(A0),D2
        ADD.W   D2,D0
        BRA.S   BANCOM
BANGAU: MOVE.W  (A0),D2
        SUB.W   2(A0),D2
        MOVE.W  4(A0),D0
        SUB.W   D2,D0
BANCOM: MOVE.L  A1,D7
        MOVE.W  D0,D1
        MOVE.W  6(A0),D3
        LSR.W   #2,D3
        SUB.W   D3,D0
        ADD.W   D3,D1
        BLE.L   FINLIG
        MOVE.W  D1,D2
        LSR.W   #1,D1
        AND.W   #$FFF8,D1
        CMP.W   #160,D1
        BLT.S   BLANCOK1
        CMP.W   #320,D0
        BGE.L   FINLIG
        MOVE.W  #160,D1
        LEA.L   162(A1),A1
        BRA.S   S1BL3
BLANCOK1:
        ADD.W   D1,A1
        addq.w  #2,a1
        AND.W   #$F,D2
        ADD.W   D2,D2
        MOVE.W  TBPIX2+32(PC,D2.W),D2
        AND.W   D2,(A1)
S1BL3:  MOVE.W  D0,D2
        BGE.S   S1BL0
        CLR.W   D0
        CLR.W   D2
        BRA.S   S1BL1
S1BL0:  LSR.W   #1,D0
        AND.W   #$FFF8,D0
S1BL1:  SUB.W   D0,D1
        BGT.S   SBLANC1
        AND.W   #$F,D2
        ADD.W   D2,D2
        MOVE.W  TBPIX2(PC,D2.W),D2
        OR.W    D2,(A1)
        BRA.S   PABLANC1
SBLANC1: SUB.W   D1,A1
        AND.W   #$F,D2
        ADD.W   D2,D2
        MOVE.W  TBPIX2(PC,D2.W),D2
        AND.W   D2,(A1)
S1BL2:  SUBQ.W  #8,D1
        BLE.S   PABLANC1
        LEA.L   8(A1),A1
        MOVE.W  TBPIX2(PC),(A1)
        BRA.S   S1BL2
TBPIX2:  DC.W   $0000,$8000,$C000,$E000
         DC.W   $F000,$F800,$FC00,$FE00
         DC.W   $FF00,$FF80,$FFC0,$FFE0
         DC.W   $FFF0,$FFF8,$FFFC,$FFFE

         DC.W   $FFFF,$7FFF,$3FFF,$1FFF
         DC.W   $0FFF,$07FF,$03FF,$01FF
         DC.W   $00FF,$007F,$003F,$001F
         DC.W   $000F,$0007,$0003,$0001  
PABLANC1:
        MOVE.L  D7,A1
FINLIG: LEA.L   10(A0),A0
BDSPRO: MOVE.B  9(A0),D4
        BLT     FDSPRO
        MOVE.L  TMM(PC,D4.W),D7
        MOVE.W  4(A0),D0
        MOVE.W  D0,D3
        BGE.S   CCLR1
        CLR.W   D3
CCLR1:  ADD.W   6(A0),D0
        BLE.L   QUEVERT
        MOVE.W  D0,D2
        LSR.W   #4,D0
        MOVE.W  #20,D1
        SUB.W   D0,D1
        BGT.S   PVERT1
* TRT DEPASS 319
        EOR.B   #2,D4
        MOVE.W  D3,D2
        LSR.W   #4,D3
        SUB.W   D3,D0
        ADD.W   D1,D0
        BGT.L   REPR1
        MOVE.W  2(A0),D0
        BLE     QUEGRIS
        MOVE.W  D0,D1
        MOVE.W  D1,D2
        LSR.W   #4,D1
        MOVE.W  #20,D3
        SUB.W   D1,D3
        BGT.L   REPR2
        SUB.W   6(A0),D0
        MOVE.W  D0,D2
        LSR.W   #4,D0
        MOVE.W  #20,D1
        SUB.W   D0,D1
        BGT     REPR3
        BRA     QUEVERT
PVERT1: BCLR    D6,D1
        BEQ.S   VERT1
        MOVEM.L A5/A4,-(A1)
VERT1:  NEG.W   D1
        ADD.W   D1,D1
        JMP     FVERT1(PC,D1.W)
TMM:    DC.W    $FFFF,$0000,$FFFF
TBPIX3:  DC.W   $0000,$8000,$C000,$E000
         DC.W   $F000,$F800,$FC00,$FE00
         DC.W   $FF00,$FF80,$FFC0,$FFE0
         DC.W   $FFF0,$FFF8,$FFFC,$FFFE
        MOVEM.L A5/A4/A2/D6,-(A1)
        MOVEM.L A5/A4/A2/D6,-(A1)
        MOVEM.L A5/A4/A2/D6,-(A1)
        MOVEM.L A5/A4/A2/D6,-(A1)
        MOVEM.L A5/A4/A2/D6,-(A1)
        MOVEM.L A5/A4/A2/D6,-(A1)
        MOVEM.L A5/A4/A2/D6,-(A1)
        MOVEM.L A5/A4/A2/D6,-(A1)
        MOVEM.L A5/A4/A2/D6,-(A1)
        MOVEM.L A5/A4/A2/D6,-(A1)
FVERT1: AND.W   #$F,D2
        ADD.W   D2,D2
        MOVE.W  TBPIX3(PC,D2.W),0(A1,D4.W)
        MOVE.W  D3,D2
        LSR.W   #4,D3
        EOR.B   #2,D4
        SUB.W   D3,D0
        BEQ.S   PINT1
REPR1:  SUBQ.W  #1,D0
BINT1:  MOVEM.L A5/D7,-(A1)
        DBF     D0,BINT1
PINT1:  AND.W   #$F,D2
        ADD.W   D2,D2
        MOVE.W  TBPIX3(PC,D2.W),0(A1,D4.W)
        MOVE.W  2(A0),D0
        BLE     RESTGRI
        MOVE.W  D0,D1
        MOVE.W  D1,D2
        LSR.W   #4,D1
        SUB.W   D1,D3
* PREMIER RECOUV
        BEQ.S   PGRIS1
REPR2:  BCLR    D6,D3
        BEQ.S   GRIS1
        MOVEM.L A5/A3,-(A1)
GRIS1:  NEG.W   D3
        ADD.W   D3,D3
        JMP     FGRIS1(PC,D3.W)
PGRIS1: AND.W   #$F,D2
        ADD.W   D2,D2
        MOVE.W  TBPIX4(PC,D2.W),D2
        AND.W   D2,0(A1,D4.W)
        SUB.W   6(A0),D0
        BGE.S   CCLR4
        CLR.W   D0
CCLR4:  MOVE.W  D0,D2
        LSR.W   #4,D0
        SUB.W   D0,D1
* DEUXIEM RECOUVR
        BGT.S   REPR3
        AND.W   #$F,D2
        ADD.W   D2,D2
        EOR.B   #2,D4
        MOVE.W  TBPIX4(PC,D2.W),D2
        AND.W   D2,0(A1,D4.W)
        BRA.S   REPR4
TBPIX4:  DC.W   $FFFF,$7FFF,$3FFF,$1FFF
         DC.W   $0FFF,$07FF,$03FF,$01FF
         DC.W   $00FF,$007F,$003F,$001F
         DC.W   $000F,$0007,$0003,$0001  
        MOVEM.L A5/A3/A2/D5,-(A1)
        MOVEM.L A5/A3/A2/D5,-(A1)
        MOVEM.L A5/A3/A2/D5,-(A1)
        MOVEM.L A5/A3/A2/D5,-(A1)
        MOVEM.L A5/A3/A2/D5,-(A1)
        MOVEM.L A5/A3/A2/D5,-(A1)
        MOVEM.L A5/A3/A2/D5,-(A1)
        MOVEM.L A5/A3/A2/D5,-(A1)
        MOVEM.L A5/A3/A2/D5,-(A1)
        MOVEM.L A5/A3/A2/D5,-(A1)
FGRIS1: AND.W   #$F,D2
        ADD.W   D2,D2
        MOVE.W  TBPIX4(PC,D2.W),0(A1,D4.W)
        SUB.W   6(A0),D0
        BGE.S   CCLR3
        CLR.W   D0
CCLR3:  MOVE.W  D0,D2
        LSR.W   #4,D0
        SUB.W   D0,D1
        BEQ.S   PINT2
REPR3:  SUBQ.W  #1,D1
BINT2:  MOVEM.L A5/D7,-(A1)
        DBF     D1,BINT2
PINT2:  AND.W   #$F,D2
        ADD.W   D2,D2
        EOR.B   #2,D4
        MOVE.W  TBPIX4(PC,D2.W),0(A1,D4.W)
REPR4:  TST.W   D0
        BEQ     FGRIS2
        BCLR    D6,D0
        BEQ.S   VERT2
        MOVEM.L A5/A4,-(A1)
VERT2:  NEG.W   D0
        ADD.W   D0,D0
        JMP     FVERT2(PC,D0.W)
        MOVEM.L A5/A4/A2/D6,-(A1)
        MOVEM.L A5/A4/A2/D6,-(A1)
        MOVEM.L A5/A4/A2/D6,-(A1)
        MOVEM.L A5/A4/A2/D6,-(A1)
        MOVEM.L A5/A4/A2/D6,-(A1)
        MOVEM.L A5/A4/A2/D6,-(A1)
        MOVEM.L A5/A4/A2/D6,-(A1)
        MOVEM.L A5/A4/A2/D6,-(A1)
        MOVEM.L A5/A4/A2/D6,-(A1)
        MOVEM.L A5/A4/A2/D6,-(A1)
FVERT2: BRA     FGRIS2
FDSPRO: 
        move.l  adscrol(pc),d4
        cmp.l   #160*68,d4
        bge.s   scrook
        move.l  #160*68,d4
scrook: move.l  a1,d0
        sub.l   d4,d0
        sub.l   CURSCR,d0
        ble.s   fciel
        divu    #160,d0
        move.l  d6,d4
        move.l  d6,d2
        move.l  a2,d5
        move.l  d5,d3
        subq.w  #1,d0
bvert:  
        movem.l a5/a4/a2/d6/d5/d4/d3/d2,-(a1)
        movem.l a5/a4/a2/d6/d5/d4/d3/d2,-(a1)
        movem.l a5/a4/a2/d6/d5/d4/d3/d2,-(a1)
        movem.l a5/a4/a2/d6/d5/d4/d3/d2,-(a1)
        movem.l a5/a4/a2/d6/d5/d4/d3/d2,-(a1)
        dbf     d0,bvert
; ******
fciel:  
        RTS
adsky:  dc.l    0,0

        dc.b    0,255,0,199,200,0,0,160
        dc.l    -1,-1
zafevt: ds.l    256
        END

