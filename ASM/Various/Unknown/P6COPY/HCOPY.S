*       Hardcopy mit Prediction
*       NEC-P6 Grafikparameter

g_mode  equ     1
b_low   equ     0
b_high  equ     5

*       Systemparameter

s_chip  equ     $ffff8800
mfp     equ     $fffffa00
gemdos  equ     1
xbios   equ     14
prntout equ     5
super   equ     $20
keep    equ     $31
physbas equ     2
supexec equ     38
do_vect equ     $502
alt_flg equ     $4ee

sex     macro                   ;setzt das X-Flag
        move    #%11111,ccr
        endm

clx     macro                   ;l”scht das X-Flag
        move    #%00000,ccr
        endm

init    pea     set1(pc)
        move.w  #supexec,-(a7)
        trap    #xbios
        addq.l  #6,sp

        clr.w   -(sp)
        move.l  #date-init+$100+48*160,-(sp)
        move.w  #keep,-(sp)
        trap    #gemdos

set1    lea     start(pc),a0
        move.l  a0,do_vect
        rts

start   link    a0,#00
        movem.l d0-d7/a0-a6,-(a7)
        move.w  #1,alt_flg
        bsr     doit
        move.w  #$ffff,alt_flg
        movem.l (a7)+,d0-d7/a0-a6
        unlk    a0
        rts

realst  pea     start(pc)
        move.w  #supexec,-(a7)
        trap    #xbios
        addq.l  #6,sp
        move    0,d0

whlp1   macro
        clx
        move    \1,d7
        btst    d1,d7
        beq     *+6
        sex
        roxl.w  #1,d0
        endm

whlp    macro
        whlp1   0*160(\1)
        whlp1   1*160(\1)
        whlp1   2*160(\1)
        whlp1   3*160(\1)
        whlp1   4*160(\1)
        whlp1   5*160(\1)
        whlp1   6*160(\1)
        whlp1   7*160(\1)
        endm

doit    jsr     getadr
*        move.w  #0,d0
*show    move.w  d0,0(a0,d0.w)
*        addq    #2,d0
*        cmp     #$2000,d0
*        bne     show
        bsr     setlf

        move.l  anfadr,a0
        move.l  anfadr,a1
        add.l   #80,a1

        move    #33,d1
bld1    move    #11,d0
        move    #80,d7
        move.l  #date,a2
build   bsr     predict1
        bsr     predict2
        dbra    d0,build
        bsr     write
        bsr     break
        bne     schluss
        dbra    d1,bld1
        move    #26*160,d0
        move.l  #date,a2
erase   clr.l   (a2)+
        dbra    d0,erase
        move.l  #date,a2
        bsr     predict1
        bsr     predict2
        bsr     predict1
        bsr     predict2
        bsr     predict1
        bsr     predict2
        bsr     predict1
        bsr     write
schluss rts

break   cmp.w   #1,alt_flg
        rts

write   movem.l d0-d7/a0-a6,-(a7)
        bsr     grafon
        move    #79,d5
        move.l  #date,a2
        move.l  #date+8*160,a3
        move.l  #date+16*160,a4
wrlop   move    #15,d1
writ1   whlp    a2
        bsr     cenout
        whlp    a3
        bsr     cenout
        whlp    a4
        bsr     cenout
        dbra    d1,writ1
        addq    #2,a2
        addq    #2,a3
        addq    #2,a4
        dbra    d5,wrlop
        bsr     sendcr
        movem.l (a7)+,d0-d7/a0-a6
        rts

predict1:       ;predict1 erzeugt EINE neue Pixelreihe aus EINER alten
                ;gegeben: alte Reihe in a0; neue Reihe in a2 updated
                ;L„nge der alten Reihe in d7

        movem.l d0-d7/a0-a6,-(a7)
        subq    #1,d7
pr11    move.w  (a0)+,d0
        move.w  #14,d1
pr12    btst    #15,d0
        beq     pr1off
        sex
        roxl.l  #1,d2
        sex
        btst    #14,d0
        bne     pr1on
        clx
pr1on   roxl.l  #1,d2
        bra     pr1lop
pr1off  clx
        roxl.l  #1,d2
        clx
        roxl.l  #1,d2
pr1lop  rol.w   #1,d0
        dbra    d1,pr12
        btst    #15,d0
        beq     pr13
        sex
        roxl.l  #1,d2
        move.w  (a0),d0
        clx
        btst    #15,d0
        beq     pr14
        sex
pr14    roxl.l  #1,d2
        bra     pr15
pr13    clx
        roxl.l  #1,d2
        clx
        roxl.l  #1,d2
pr15    move.l  d2,(a2)+
        dbra    d7,pr11
        move.l  -(a2),d2
        and.l   #$fffffffe,d2
        move.l  d2,(a2)
        movem.l (a7)+,d0-d7/a0-a6
        add.l   #160,a2
        rts

predict2:       ;predict2 erzeugt eine neue Pixelreihe aus zwei alten
                ;gegeben: alte Reihen in a0,a1; neue Reihe in a2
                ;L„nge der alten Reihen in d7,alles updated

        movem.l d0-d7/a0-a6,-(a7)
        subq    #1,d7
pr21    move.w  (a0)+,d0
        move.w  (a1)+,d1
        move.w  #14,d3
pr23    clx
        btst    #15,d0
        beq     pr2off
        btst    #15,d1
        beq     pr2off
        sex
pr2off  roxl.l  #1,d2
        clx
        btst    #15,d0
        beq     nopi1
        btst    #14,d1
        bne     nopi4
nopi1   btst    #14,d0
        beq     pr24
        btst    #15,d1
        beq     pr24
nopi4   sex
pr24    roxl.l  #1,d2
        rol     #1,d0
        rol     #1,d1
        dbra    d3,pr23
        clx
        btst    #15,d0
        beq     pr31
        btst    #15,d1
        beq     pr31
        sex
pr31    roxl.l  #1,d2
        move.w  (a0),d4
        move.w  (a1),d5
        sex
        btst    #15,d0
        beq     pr32
        btst    #15,d5
        bne     pr35
pr32    btst    #15,d1
        beq     pr33
        btst    #15,d4
        bne     pr35
pr33    clx
pr35    roxl.l  #1,d2
        move.l  d2,(a2)+
        dbra    d7,pr21
        move.l  -(a2),d2
        and.l   #$fffffffe,d2
        move.l  d2,(a2)
        movem.l (a7)+,d0-d7/a0-a6
        add.l   #160,a2
        add.l   #80,a0
        add.l   #80,a1
        rts



cenout  move.w  sr,-(a7)        ;schnelle prntout-Routine
        movem.l a0-a1,-(a7)
        move.w  #$2700,sr
        lea     s_chip,a1
        lea     mfp+1,a0

busy_cl btst    #0,(a0)
        bne     busy_cl
        move.b  #15,(a1)
        move.b  d0,2(a1)
        move.b  #14,(a1)
        and.b   #%11011111,2(a1)

busy_st btst    #0,(a0)
        beq     busy_st
        or.b    #%00100000,2(a1)
        moveq   #-1,d0
        movem.l (a7)+,a0-a1
        move.w  (a7)+,sr
        rts

getadr  move.w  #physbas,-(sp)
        trap    #xbios
        addq.l  #2,sp
        move.l  d0,anfadr
        move.l  d0,a0
        rts

grafon  lea     grafdat,a4
        moveq   #4,d6
        bra     strout

sendcr  lea     feed,a4
        moveq   #1,d6
        bra     strout

setlf   lea     lfdat,a4
        moveq   #2,d6
        bra     strout

strout  move.b  (a4)+,d0        ;gib String in A4 aus mit L„nge d6+1
        ext.w   d0
        bsr     cenout
        tst.l   d0
        bne.s   lstcont
        bra     endrout
lstcont dbra    d6,strout
endrout rts

lfdat   dc.b    27,'3',24
grafdat dc.b    27,'*',39,0,5
anfadr  ds.l    1
feed    dc.b    13,10

date    end
