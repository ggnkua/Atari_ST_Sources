;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                ;
;       BLACK SECT: assembleur   ;
;                                ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FALCON: EQU 1

*** ASSEMBLE ET SAUVER DE DEBDEB A FINFIN (SECTASS.O)

SECTASS:        EQU     $2A0000-40000
BASLOAD:        EQU     $2A0000-40000-10000
PRGMUS:         EQU     $2A0000
PASCAL:         EQU     50000  ;Pour recherche buffer de sauvegarde

EX_AMB:     EQU  6
EX_PRIO:    EQU  14
EX_SURI:    EQU  10
EX_COUPSON: EQU  22
EX_COUPPRI: EQU  18

ADDUREE:    EQU  4
ADVOLUME:   EQU  2
ADMORCEAU:  EQU  0

        ORG     SECTASS
        LOAD    SECTASS

NBLIEU:   EQU     33       ; reporter valeur dans BOOT_ST

debdeb:
   DC.L     PEEK,PEEKW,POKE,POKEW,MEMLIB,MEMRES,DECOMP,GROSSI,SAVMEM
   DC.L     VBLSYNC,INITMOUSE,CHNGMOUSE,HIDEMOUSE,SHOWMOUSE,BOITE
   DC.L     MOVBLK,CLRBLK,PAROLE,POKEL,PEEKL,ADSAUV
   DC.L     AFMEN,AFTEXT,TRACLIGN,EFFETS,DPB,AFMARK
   DC.L     LOADLIEU,LOADOBJT,LOADPERS,GNON,LOADSUIV
   DC.L     RESETANI,INITANI,EXITANI,CHNGANI,MLOUPE,VERIF
   DC.L     DOMORT,REMAPEC,PALJNF,PALJN,COUPSON,SURIMP,POURCENT
   DC.L     DEPADR,ADEPLONW,ADEPLONB,TAILTA,BRUITAGE,COUPRI,STOPANI 
   DC.L     LOADFIC,BRUIERGO,TESTLOAD,AMBIANCE,HAZARD,ADEC,MUSIQUE,APRIO
   DC.L     CHARGE,SAUVE
   DC.L     BLOCANI,ALERTE,INITDEMO,CONFIGSYS,tab1
   DC.L     demini,EXITMOUSE,INITADR,AFFICHE,PEEKB
   DC.L     HIDEMOUF,SHOWMOUF,COORDMOUS,INITPAL,FLAGSON
;
LADRES: dc.l    0
FLAGSON: dc.w     0
demini:
        bclr    #3,$fffffa17.w
        move.w  #1,fltimb
        move.l  #new_clav,$118.w
        move.l  #new_vbl,$70.w
        rts
CHMUTOT:
        rts
INIMUS:
        rts
ADSAUV:
        MOVE.L  D0,A0                   ;TRANSFERE PAR AMAUP.S
        MOVE.L  #80000,A0               ;POUR LA VERSION SYSTEME!!!
        MOVE.L  VALMAG(PC),D0
        MOVE.L  VALMAG+4(PC),D1
AD1SAUV:
        CMP.L   (A0),D0
        BEQ.S   AD0SAUV
        ADDQ    #2,A0
        BRA.S   AD1SAUV
AD0SAUV:
        ADDQ    #4,A0
        CMP.L   (A0),D1
        BNE.S   AD1SAUV
        MOVE.L  A0,D0
        SUBQ    #4,D0
        RTS
VALMAG: DC.L    $13578642,$75312468
VERIF:  rts
POURCENT:
        move.l  4(a7),d0
        move.l  #PRGMUS+4,a0
;        jsr     (a0)
        move.l  (a7),4(a7)
        lea.l   4(a7),a7
        rts
APRIO:  tst.b   flmu25
        bne.s   paprio
        move.l  4(a7),d0
        movem.l d1-d7/a0-a6,-(a7)
        move.l  #PRGMUS+16,a0
;        jsr     (a0)
        movem.l (a7)+,d1-d7/a0-a6
paprio: move.l  (a7),4(a7)
        lea.l   4(a7),a7
        rts
tab1:   dc.w    0               ;BUG GOURIER
COUPRI: 
        tst.b   flmu25
        bne.s   pcoupr
        move.l  #PRGMUS+70,a0
;        jsr     (a0)
pcoupr: rts
SET_SON:
        move.l  #PRGMUS,A0
        move    D0,D1
        andi    #$3ff,D1
        move    D1,ADMORCEAU(A0)
        moveq   #10,D1
        asr     D1,D0
        move    D0,ADVOLUME(A0)
        RTS
SURIMP:
BRUITAGE:
        move.l  4(a7),d0
        movem.l d1-d7/a0-a6,-(a7)
        TST     FLAGSON
        BEQ.S   PASSURIMP
        BSR     SET_SON
        JSR     EX_SURI(A0)
PASSURIMP:
        movem.l (a7)+,d1-d7/a0-a6
        move.l  (a7),4(a7)
        lea.l   4(a7),a7
        rts

AMBIANCE:
        move.l  4(a7),d0
        movem.l d1-d7/a0-a6,-(a7)
        TST     FLAGSON
        BEQ.S   PASAMBIANCE
        BSR     SET_SON
        JSR     EX_AMB(A0)
PASAMBIANCE:
        movem.l (a7)+,d1-d7/a0-a6
        move.l  (a7),4(a7)
        lea.l   4(a7),a7
        rts

MUSIQUE:
        TST     FLAGSON
        BEQ.S   PASMUSIQUE
        move.l  #PRGMUS,A0
        move    10(a7),ADMORCEAU(A0)
        move    6(a7),ADVOLUME(A0)
        movem.l d1-d7/a0-a6,-(a7)
        JSR     EX_PRIO(A0)
        movem.l (a7)+,d1-d7/a0-a6
PASMUSIQUE:
        move.l  (a7),8(a7)
        lea     8(a7),a7
        rts
BRUIERGO:
        TST     FLAGSON
        BEQ.S   PASERGO
        move.l  #PRGMUS,A0
        move    10(a7),ADMORCEAU(A0)
        move    6(a7),ADVOLUME(A0)
        movem.l d1-d7/a0-a6,-(a7)
        JSR     EX_PRIO(A0)
        movem.l (a7)+,d1-d7/a0-a6
PASERGO:
        move.l  (a7),8(a7)
        lea     8(a7),a7
        rts
DAMB:
FEU:
        rts
exebruit:
        tst.b   flmu25
        bne.s   fexeb
        movem.l d0-d7/a0-a6,-(a7)
        subq    #1,D0
        move.l  #PRGMUS,a0
;        jsr     (a0)
        movem.l (a7)+,d0-d7/a0-a6
fexeb:  rts
flmu25: dc.w    0
INITBASECH:
;        move.l  adpiano+8,PRGMUS+56
;        move.l  adpiano+8,PRGMUS+60
        rts
COUPSO4:
fltimb: dc.w    0
COUPSON:
        movem.l d1-d7/a0-a6,-(a7)
        TST     FLAGSON
        BEQ.S   PASCOUPSON
        JSR     EX_COUPSON+PRGMUS
PASCOUPSON:
        movem.l (a7)+,d1-d7/a0-a6
        rts

VBLBJL:
;        move.l  #PRGMUS+48,a0
;        jsr     (a0)
        rts

LOADFIC:        rts
HAZARD:
        MOVEM.L D0-D1,-(SP)
        bsr     RTHAZ
        MOVEM.L (SP)+,D0-D1
        MOVE.L  4(A7),D1
        SUB.L   8(A7),D1
        ADDQ.L  #1,D1
        MOVE.L  VAMOUN(PC),D0
        DIVU    D1,D0
        CLR.W   D0
        SWAP    D0
        ADD.L   8(A7),D0
        MOVE.L  (A7),8(A7)
        ADDQ    #8,A7
        RTS
RTHAZ:  MOVEQ   #0,D1
        MOVE.L  VAMOUN(PC),D0
        MOVE.B  $CD.w,D1
        ADD.L   D1,D0
        MOVE.B  $CC.w,D1
        ADD.L   D1,D0
        MOVE.W  D0,VAMOUN+2
        RTS
VAMOUN: DC.L    0

ADEC:
        MOVE.B  $FFFF8201.W,ECRA+1
        MOVE.B  $FFFF8203.W,ECRA+2
        MOVE.L  ECRA(PC),D0
        RTS
ECRA:   DC.L    0

MEMLIB: rts
MEMRES:
    movem.l  d1-d7/a0-a6,-(a7)          ;avec systeme
    move.l   #200000,-(a7)
    move     #$48,-(a7)
    trap     #1
    ADDQ     #6,A7
    move.l   d0,basemem
    movem.l  (a7)+,d1-d7/a0-a6
    rts
basemem:     dc.l    0
;   move.l   $C0.w,d0                   ;version disque
;   rts
;
PEEKB:
   move.l   8(a7),a0
   move.b   7(a7),d1
   clr.l    d0
   btst     d1,(a0)
   beq.s    endpeekb
   move.l   #1,d0
endpeekb:
   move.l   (a7),8(a7)
   addq     #8,a7
   rts
;
PEEK:
   move.l   4(a7),a0
   moveq    #0,d0
   move.b   (a0),d0
   move.l   (a7),4(a7)
   addq     #4,a7
   rts
;
PEEKW:
   move.l   4(a7),a0
   moveq    #0,d0
   move.b   (a0)+,d0
   lsl      #8,d0
   move.b   (a0),d0
   move.l   (a7),4(a7)
   addq     #4,a7
   rts
;
PEEKL:
   move.l   4(a7),a0
   move.b   (a0)+,d0
   lsl      #8,d0
   move.b   (a0)+,d0
   swap     d0
   move.b   (a0)+,d0
   lsl      #8,d0
   move.b   (a0),d0
   move.l   (a7),4(a7)
   addq     #4,a7
   rts
;
POKE:
   move.l   8(a7),a0
   move.b   7(a7),(a0)
   move.l   (a7),8(a7)
   addq     #8,a7
   rts
;
POKEW:
   move.l   8(a7),a0
   move.b   6(a7),(a0)+
   move.b   7(a7),(a0)
   move.l   (a7),8(a7)
   addq     #8,a7
   rts
;
POKEL:
   move.l   8(a7),a0
   move.b   4(a7),(a0)+
   move.b   5(a7),(a0)+
   move.b   6(a7),(a0)+
   move.b   7(a7),(a0)
   move.l   (a7),8(a7)
   addq     #8,a7
   rts
;
ADEPLONB:
   move.l   8(a7),a0
   move.l   4(a7),d0
        clr.l   tampdt
        subq.w  #1,d0
        blt.s   padpo1
        moveq   #0,d1
        moveq   #0,d2
badta1: move.b  (a0)+,d2
        add.w   d2,d1
        dbf     d0,badta1
        move.w  d1,tampdt
padpo1: move.b  (a0),tampdt+3
        move.l  #tampdt,d0
   move.l   (a7),8(a7)
   addq     #8,a7
   rts
;
ADEPLONW:
        move.l  8(a7),a0
        move.l  4(a7),d0
        clr.l   tampdt
        clr.l   tampdt+4
        subq.w  #1,d0
        blt.s   paadpo
        moveq   #0,d1
        moveq   #0,d2
badta:  move.w  (a0)+,d2
        add.l   d2,d1
        dbf     d0,badta
        move.l  d1,tampdt
paadpo: move.w  (a0),tampdt+6
        move.l  #tampdt,d0
        move.l  (a7),8(a7)
        addq    #8,a7
        rts
tampdt: dc.l    0,0
;
TAILTA:
        move.l  8(a7),a0
        move.l  4(a7),d1
        lsl.w   #1,d1
        moveq   #0,d0
        moveq   #0,d2
        move.w  0(a0,d1.w),d0
        move.w  -2(a0,d1.w),d2
        sub.l   d2,d0
        move.l  (a7),8(a7)
        addq    #8,a7
        rts
;
INITADR:
        move.l  4(a7),a0              
        moveq   #0,d0
        move.w  (a0)+,d0
        moveq   #0,d2
        move.w  d0,d1
        subq.w  #4,d1
        lsr.w   #1,d1
bprfo:  move.w  (a0),d2
        add.l   d2,d0
        move.w  d0,(a0)+
sbprfo: dbf     d1,bprfo
        move.l  (a7),4(a7)
        addq    #4,a7
        rts
;
DEPADR:
        move.l   8(a7),a0              
paprfo: move.l   4(a7),d0              ; no du poste
        lsl.w    #1,d0
        move.w   0(a0,d0.w),d0
        add.l    8(a7),d0
        move.l   (a7),8(a7)
        addq     #8,a7
        rts

PAROLE:
  MOVE.L   (A7),40(A7)
  LEA.L    40(A7),A7
  RTS

PALJNF:
        movem.l d0-d7/a0-a6,-(sp)
        move.l  64(a7),a0    ;inutile
        move.l  68(a7),adjnco
;        move.l  #paljo,palmidi
;        move.l  #pal6,palsix
;        move.l  #pal12,palnuit
        move.l  76(a7),d0               
        mulu    #6,d0
        add.l   80(a7),d0
        bsr     conbpal
        movem.l (sp)+,d0-d7/a0-a6
        move.l  (a7),20(a7)
        lea.l   20(a7),a7
        rts
;
valdemi:
        dc.w    0
PALJN:
        movem.l d0-d7/a0-a6,-(sp)
        move.l  68(a7),d0
        move.w  d0,valdemi
        mulu    #6,d0
        add.l   72(a7),d0
        bsr     conbpal
        move.l  adjnco(pc),P_pal
        bsr     apalr
 noamb: movem.l (sp)+,d0-d7/a0-a6
        move.l  (a7),12(a7)
        lea.l   12(a7),a7
        rts
extint: dc.b    1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0
        dc.b    1,1,1,0,1,1,1,1,1,1,0,0,0,0,0,0
conbpal:
        cmp.w   #288,d0
        blt.s   psoud0
        sub.w   #288,d0
psoud0: move.w  adpiano+12,d4
        move.b  extint(pc,d4.w),d4
        beq     exteri
        cmp.w   #91,d0
        blt     exteri
        cmp.w   #252,d0
        blt     crpa1
        cmp.w   #268,d0
        bge.s   tpal9
        sub.w   #250,d0
        lsr.w   #1,d0
        move.w  d0,d4
        move.w  #8,d3
        sub.w   d4,d3
        move.l  palmidi(pc),a2
        move.l  palsix(pc),a3
        bsr     calpal
        rts
tpal9:  cmp.w   #275,d0
        bge.L   crpa3
        sub.w   #267,d0
        move.w  d0,d4
        move.w  #8,d3
        sub.w   d4,d3
        move.l  palsix(pc),a2
        move.l  palnuit(pc),a3
        bsr     calpal
        rts
exteri: cmp.w   #60,d0
        blt     crpa3
        cmp.w   #76,d0
        bge.s   tpal2
        sub.w   #58,d0
        lsr.w   #1,d0
        move.w  d0,d4
        move.w  #8,d3
        sub.w   d4,d3
        move.l  palnuit(pc),a2
        move.l  palsix(pc),a3
        bsr     calpal
        rts
tpal2:  cmp.w   #91,d0
        bge.s   tpal3
        sub.w   #74,d0
        lsr.w   #1,d0
        move.w  d0,d4
        move.w  #8,d3
        sub.w   d4,d3
        move.l  palsix(pc),a2
        move.l  palmidi(pc),a3
        bsr     calpal
        rts
tpal3:  cmp.w   #229,d0
        blt     crpa1
        cmp.w   #237,d0
        bge.s   tpal4
        sub.w   #228,d0
        move.w  d0,d4
        move.w  #8,d3
        sub.w   d4,d3
        move.l  palmidi(pc),a2
        move.l  palsix(pc),a3
        bsr     calpal
        rts
tpal4:  cmp.w   #266,d0
        bge.s   crpa3
        sub.w   #233,d0
        lsr.w   #2,d0
        move.w  d0,d4
        move.w  #8,d3
        sub.w   d4,d3
        move.l  palsix(pc),a2
        move.l  palnuit(pc),a3
        bsr     calpal
        rts
crpa3:  move.l  palnuit(pc),a0
        bra.s   chpco
crpa1:  move.l  palmidi(pc),a0
chpco:  move.l  adjnco(pc),a1
        move.w  #7,d0
bchpco: move.l  (a0)+,(a1)+
        dbf     d0,bchpco
        rts
calpal: 
        move.l  adjnco(pc),a4
        move.w  #15,d0
bcpal:  move.w  (a2),d1
        move.w  (a3),d2
        lsr.w   #8,d1
        lsr.w   #8,d2
        and.w   #$0007,d1
        and.w   #$0007,d2
        bsr     c1modpa
        lsl.w   #8,d1
        and.w   #$00ff,(a4)     
        or.w    d1,(a4)
        move.w  (a2),d1
        move.w  (a3),d2
        lsr.w   #4,d1
        lsr.w   #4,d2
        and.w   #$0007,d1
        and.w   #$0007,d2
        bsr     c1modpa
        lsl.w   #4,d1
        and.w   #$0f0f,(a4)     
        or.w    d1,(a4)
        move.w  (a2)+,d1
        move.w  (a3)+,d2
        and.w   #$0007,d1
        and.w   #$0007,d2
        bsr     c1modpa
        and.w   #$0ff0,(a4)     
        or.w    d1,(a4)+
        dbf     d0,bcpal
        rts
c1modpa: mulu    d3,d1
        mulu    d4,d2
        add.w   d2,d1
        lsr.w   #3,d1
        rts
adjnco: dc.l    0
palmidi: dc.l   0
palsix: dc.l    0
palnuit: dc.l   0
;paljo:  blk.w    16,0
;pal6:   blk.w    16,0
;pal12:  blk.w    16,0
;
EFFETS:
        move.l  36(a7),P_eff
        move.l  32(a7),P_sty
        move.l  28(a7),P_pal
        move.l  24(a7),P_ecd
        move.l  20(a7),P_eca
        move.l  16(a7),P_xh
        move.l  12(a7),P_yh
        move.l  8(a7),P_xb
        move.l  4(a7),P_yb
        movem.l d0-d7/a0-a6,-(sp)
        cmp.l   #0,P_eff
        beq     onoir
        cmp.l   #1,P_eff
        beq     fnoir
        cmp.l   #2,P_eff
        beq     ocarr
        cmp.l   #3,P_eff
        beq     fcarr
        cmp.l   #4,P_eff
        beq     pixlis
        cmp.l   #5,P_eff
        beq     pixlisb
        cmp.l   #6,P_eff
        beq     palbas
feffets:
        movem.l (sp)+,d0-d7/a0-a6
        move.l  (a7),36(a7)
        lea.l   36(a7),a7
        rts
palbas: bsr     apalr
        bra.s   feffets
apalr:  move.w  #$8240,a0
        move.l  P_pal,a3
        move.w  #7,d1
bypalb: move.l  (a3)+,(a0)+
        dbf     d1,bypalb
        rts
fnoir:  bsr     appal
        lea.l   z1buf,a1
        move.w  #8,36(a1)
        clr.w   38(a1)
        move.w  #2,40(a1)
        move.l  #paleco,paldep
        move.l  #palnoir,palari
        bsr     inipal
        move.w  #24,nbfois
bouv2:  bsr     modpal
        bsr     atten
        subq.w  #1,nbfois
        bgt.s   bouv2
        bra     feffets
onoir:
        lea.l   z1buf,a1
        move.w  #8,36(a1)
        clr.w   38(a1)
        move.w  #2,40(a1)
        move.l  P_pal,palari
        move.l  #palnoir,paldep
        bsr     inipal
        move.w  #24,nbfois
bouv3:  bsr     modpal
        bsr     atten
        subq.w  #1,nbfois
        bgt.s   bouv3
        bra     feffets
atten:  move.w  #12000,d0
batten: dbf     d0,batten
        rts
ocarr:  bsr     appal
        move.l  #paleco,paldep
        move.l  P_pal,palari
        clr.l   valrupt+2
        move.w  #2,valrupt+6
        cmp.l   #1,P_sty
        blt.s   socarr
        bgt.s   s1ocarr
        move.l  #palnoir,palari
        move.w  #1,valrupt+6
        bra.s   socarr
s1ocarr:
        move.l  #palnoir,paldep
        move.w  #-1,valrupt+6
socarr: move.l  P_xb,d1
        sub.l   P_xh,d1
        move.l  P_yb,d2
        sub.l   P_yh,d2
        bsr     inipal
        cmp.l   d1,d2
        bge.s   s2ocarr
        move.l  d2,d1
s2ocarr:
        lsr.w   #1,d1
        lea.l   z1buf,a1
        move.l  P_xh,4(a1)
        move.l  P_yh,8(a1)
        move.l  P_xb,12(a1)
        move.l  P_yh,16(a1)
        move.l  P_xb,20(a1)
        move.l  P_yb,24(a1)
        move.l  P_xh,28(a1)
        move.l  P_yb,32(a1)
        add.l   d1,4(a1)
        add.l   d1,8(a1)
        sub.l   d1,12(a1)
        add.l   d1,16(a1)
        sub.l   d1,20(a1)
        sub.l   d1,24(a1)
        add.l   d1,28(a1)
        sub.l   d1,32(a1)
        addq.l  #1,d1
        move.w  d1,nbfois
        move.w  #8,36(a1)
        clr.w   38(a1)
        move.w  #2,40(a1)
        move.l  d1,d0
        divu    #24,d0
        move.w  d0,anva
        clr.w   anva+2
        tst.l   P_sty
        beq.s   broutz
        move.w  #1000,anva+2
broutz: lea.l   salig(pc),a2
        lea.l   4(a1),a3
        move.w  #7,d1
bslim:  move.l  (a3)+,(a2)+
        dbf     d1,bslim
        move.w  nbfois,d1
        lsr.w   #1,d1
        sub.w   d1,nbfois
        move.w  d1,nbfoisb
brout0: bsr     tligs
        subq.l  #2,4(a1)
        subq.l  #2,8(a1)
        addq.l  #2,12(a1)
        subq.l  #2,16(a1)
        addq.l  #2,20(a1)
        addq.l  #2,24(a1)
        subq.l  #2,28(a1)
        addq.l  #2,32(a1)
        subq.w  #1,anva+2
        bgt.s   pampal
        move.w  anva,anva+2
        bsr     modpal
        lea.l   z1buf,a1
pampal: subq.w  #1,nbfois
        bgt     brout0
        tst.w   nbfoisb
        blt     feffets
        move.w  nbfoisb(pc),nbfois
        move.w  #-1,nbfoisb
        lea.l   salig(pc),a2
        lea.l   4(a1),a3
        move.w  #7,d1
bslim1: move.l  (a2)+,(a3)+
        dbf     d1,bslim1
        subq.l  #1,4(a1)
        subq.l  #1,8(a1)
        addq.l  #1,12(a1)
        subq.l  #1,16(a1)
        addq.l  #1,20(a1)
        addq.l  #1,24(a1)
        subq.l  #1,28(a1)
        addq.l  #1,32(a1)
        bra     brout0
nbfoisb:        dc.w    0
salig:  dc.l    0,0,0,0,0,0,0,0
fcarr:  bsr     appal
        move.l  #paleco,paldep
        move.l  P_pal,palari
        clr.l   valrupt+2
        move.w  #2,valrupt+6
        cmp.l   #1,P_sty
        blt.s   sfcarr
        bgt.s   s1fcarr
        move.l  #palnoir,palari
        move.w  #1,valrupt+6
        bra.s   sfcarr
s1fcarr:
        move.l  #palnoir,paldep
        move.w  #-1,valrupt+6
sfcarr: move.l  P_xb,d1
        sub.l   P_xh,d1
        move.l  P_yb,d2
        sub.l   P_yh,d2
        bsr     inipal
        cmp.l   d1,d2
        bge.s   s2fcarr
        move.l  d2,d1
s2fcarr:
        lsr.w   #1,d1
        lea.l   z1buf,a1
        move.l  P_xh,4(a1)
        move.l  P_yh,8(a1)
        move.l  P_xb,12(a1)
        move.l  P_yh,16(a1)
        move.l  P_xb,20(a1)
        move.l  P_yb,24(a1)
        move.l  P_xh,28(a1)
        move.l  P_yb,32(a1)
        addq.l  #1,d1
        move.w  d1,nbfois
        move.w  #8,36(a1)
        clr.w   38(a1)
        move.w  #2,40(a1)
        move.l  d1,d0
        divu    #24,d0
        move.w  d0,anva
        clr.w   anva+2
        tst.l   P_sty
        beq.s   bfoutz
        move.w  #1000,anva+2
bfoutz: lea.l   salig(pc),a2
        lea.l   4(a1),a3
        move.w  #7,d1
bsfim:  move.l  (a3)+,(a2)+
        dbf     d1,bsfim
        move.w  nbfois,d1
        lsr.w   #1,d1
        sub.w   d1,nbfois
        move.w  d1,nbfoisb
bfout0: bsr     tligs
        addq.l  #2,4(a1)
        addq.l  #2,8(a1)
        subq.l  #2,12(a1)
        addq.l  #2,16(a1)
        subq.l  #2,20(a1)
        subq.l  #2,24(a1)
        addq.l  #2,28(a1)
        subq.l  #2,32(a1)
        subq.w  #1,anva+2
        bgt.s   pamfal
        move.w  anva,anva+2
        bsr     modpal
        lea.l   z1buf,a1
pamfal: subq.w  #1,nbfois
        bgt     bfout0
        tst.w   nbfoisb
        blt     feffets
        move.w  nbfoisb(pc),nbfois
        move.w  #-1,nbfoisb
        lea.l   salig(pc),a2
        lea.l   4(a1),a3
        move.w  #7,d1
bsfim1: move.l  (a2)+,(a3)+
        dbf     d1,bsfim1
        addq.l  #1,4(a1)
        addq.l  #1,8(a1)
        subq.l  #1,12(a1)
        addq.l  #1,16(a1)
        subq.l  #1,20(a1)
        subq.l  #1,24(a1)
        addq.l  #1,28(a1)
        subq.l  #1,32(a1)
        bra     bfout0

tligs:  move.l  12(a1),ligne
        move.l  16(a1),ligne+4
        move.l  4(a1),ligne+8
        move.l  8(a1),ligne+12
        bsr     lig
        move.l  12(a1),ligne
        move.l  16(a1),ligne+4
        move.l  20(a1),ligne+8
        move.l  24(a1),ligne+12
        bsr     lig
        move.l  20(a1),ligne
        move.l  24(a1),ligne+4
        move.l  28(a1),ligne+8
        move.l  32(a1),ligne+12
        bsr     lig
        move.l  4(a1),ligne
        move.l  8(a1),ligne+4
        move.l  28(a1),ligne+8
        move.l  32(a1),ligne+12
        bsr     lig
        rts
lig:    
        movem.l ligne,d1-d4
        lea.l   z1buf,a1
        move.w  #$e39d,sbc
        move.l  #$518a518b,adsbc
        move.w  #$e39d,bouc
        move.l  #$518a518b,adbouc
       cmp.w d1,d3
       blt posd3
        move.w  #$e29d,sbc
        move.l  #$508a508b,adsbc
        move.w  #$e29d,bouc
        move.l  #$508a508b,adbouc
posd3:  
       sub.w d1,d3
        bge.s   s1pos3
       neg.w d3
s1pos3:  addq.w #1,d3
       move.l #160,(a1)
       sub.w d2,d4
       bge.s posd4
       move.l #-160,(a1)
       neg.w d4
posd4:
       addq.w #1,d4
       mulu #160,d2
       move.w d1,d6
       lsr.w #1,d6
       andi.b #$f8,d6
       andi.w #$000f,d1
       eori.b #$0f,d1
       add.w d6,d2
       move.l d2,a2
       moveq #0,d5
       bset d1,d5
        swap    d5
        bset    d1,d5
        move.l  a2,a3
        add.l   P_eca,a2
        add.l   P_ecd,a3
        lea.l   valrupt,a5
        cmp.w   #1,6(a5)
        bne.s   padepn
        not.l   d5
        and.l   d5,(a2)
        and.l   d5,4(a2)
        not.l   d5
        bra.s   spaden
padepn: not.l   d5
        and.l   d5,(a2)
        and.l   d5,4(a2)
        not.l   d5
        move.l  (a3),d0
        and.l   d5,d0
        or.l    d0,(a2)
        move.l  4(a3),d0
        and.l   d5,d0
        or.l    d0,4(a2)
spaden: ext.l d3
       ext.l d4
       cmp.w d3,d4
       bge livert
        cmp.w   #2,6(a5)
        beq     horap
       divu d4,d3
       move.l d3,d1
       subq.w #1,d3
       lsr.l #8,d1
       lsr.l #1,d1 
       divu d4,d1
       subq.w #1,d4
       move.w d1,d2
       move.w d3,d7
        tst.w   6(a5)
        bgt     hornode
        blt     hordeno
       subq.w #1,d7
       bge.s bouc
       subq.w #1,d4
bouc1:
       adda.l (a1),a2
        adda.l  (a1),a3
       move.w d3,d7
       add.w d1,d2
       bclr #7,d2
       beq.s bouc
       addq.w #1,d7
bouc:
       rol.l #1,d5
       bcc.s bc1f
adbouc:
       subq.l #8,a2
        subq.l  #8,a3
bc1f:
        not.l   d5
        and.l   d5,(a2)
        and.l   d5,4(a2)
        not.l   d5
        move.l  (a3),d0
        and.l   d5,d0
        or.l    d0,(a2)
        move.l  4(a3),d0
        and.l   d5,d0
        or.l    d0,4(a2)
       dbf d7,bouc
       dbf d4,bouc1
       bra term
horap: 
        lea.l   bouc,a0
        lea.l   boucr,a6
        move.w  (a0),(a6)
        lea.l   adboucr,a6
        move.l  a3neg,(a6)
        cmp.w   #$e29d,(a0)
        bne.s   horpa1
        move.l  a3plu,(a6)
horpa1: lea.l   adbouc,a0
        lea.l   fadbou,a6
        move.l  (a0),(a6)
        subq.w #2,d3
       blt term
boucr:
       rol.l #1,d5
       bcc.s bc1fr
        divu    #16,d3
        subq.w  #1,d3
        blt.s   fadbou
adboucr:
        move.l  -(a3),-(a2)
        move.l  -(a3),-(a2)
        dbf     d3,adboucr
fadbou: subq.l #8,a2
        subq.l  #8,a3
        swap    d3
bc1fr:
        not.l   d5
        and.l   d5,(a2)
        and.l   d5,4(a2)
        not.l   d5
        move.l  (a3),d0
        and.l   d5,d0
        or.l    d0,(a2)
        move.l  4(a3),d0
        and.l   d5,d0
        or.l    d0,4(a2)
       dbf d3,boucr
       bra term
a3neg:  move.l  -(a3),-(a2)
        move.l  -(a3),-(a2)
a3plu:  move.l  (a3)+,(a2)+
        move.l  (a3)+,(a2)+
hordeno:
        lea.l   bouc,a0
        lea.l   bouce,a6
        move.w  (a0),(a6)
        lea.l   adbouc,a0
        lea.l   adbouce,a6
        move.l  (a0),(a6)
       subq.w #1,d7
       bge.s bouce
       subq.w #1,d4
bouc1e:
       adda.l (a1),a2
        adda.l  (a1),a3
       move.w d3,d7
       add.w d1,d2
       bclr #7,d2
       beq.s bouce
       addq.w #1,d7
bouce:
       rol.l #1,d5
       bcc.s bc1fe
adbouce:
       subq.l #8,a2
        subq.l  #8,a3
bc1fe:
        move.l  (a3),d0
        and.l   d5,d0
        or.l    d0,(a2)
        move.l  4(a3),d0
        and.l   d5,d0
        or.l    d0,4(a2)
       dbf d7,bouce
       dbf d4,bouc1e
       bra term
hornode:
;       rol.l #1,d5
        lea.l   bouc,a0
        lea.l   boucd,a6
        move.w  (a0),(a6)
        lea.l   adbouc,a0
        lea.l   adboucd,a6
        move.w  (a0),(a6)
       subq.w #1,d7
       bge.s boucd
       subq.w #1,d4
bouc1d:
       adda.l (a1),a2
       move.w d3,d7
       add.w d1,d2
       bclr #7,d2
       beq.s boucd
       addq.w #1,d7
boucd:
       rol.l #1,d5
       bcc.s bc1fd
adboucd:
       subq.l #8,a2
bc1fd:
        not.l   d5
        and.l   d5,(a2)
        and.l   d5,4(a2)
        not.l   d5
       dbf d7,boucd
       dbf d4,bouc1d
       bra term
livert:
       cmpi.w #1,d4
       beq term
       divu d3,d4
       move.l d4,d1
       lsr.l #8,d1
       lsr.l #1,d1 
       divu d3,d1
       subq.w #1,d4
       subq.w #1,d3
       move.w d1,d2
       move.w d4,d7
        tst.w   6(a5)
        bgt     vernode
        blt     verdeno
liveno: subq.w #1,d7
       bge.s sbouc
       subq.w #1,d3
sbouc1:
       move.w d4,d7
       add.w d1,d2
       bclr #7,d2
       beq.s sbc
       addq.w #1,d7
sbc:
       rol.l #1,d5
       bcc.s sbouc
adsbc:
       subq.l #8,a2
        subq.l  #8,a3
sbouc:
       adda.l (a1),a2
       adda.l (a1),a3
        not.l   d5
        and.l   d5,(a2)
        and.l   d5,4(a2)
        not.l   d5
        move.l  (a3),d0
        and.l   d5,d0
        or.l    d0,(a2)
        move.l  4(a3),d0
        and.l   d5,d0
        or.l    d0,4(a2)
       dbf d7,sbouc
       dbf d3,sbouc1
term:   rts
vernode:
        cmp.w   #2,6(a5)
        beq     liveno
        lea.l   sbc,a0
        lea.l   sbcd,a6
        move.w  (a0),(a6)
        lea.l   adsbc,a0
        lea.l   adsbcd,a6
        move.w  (a0),(a6)
       subq.w #1,d7
       bge.s sboucd
       subq.w #1,d3
sbouc1d:
       move.w d4,d7
       add.w d1,d2
       bclr #7,d2
       beq.s sbcd
       addq.w #1,d7
sbcd:
       rol.l #1,d5
       bcc.s sboucd
adsbcd:
       subq.l #8,a2
sboucd:
       adda.l (a1),a2
        not.l   d5
        and.l   d5,(a2)
        and.l   d5,4(a2)
        not.l   d5
       dbf d7,sboucd
       dbf d3,sbouc1d
        rts
verdeno:
        lea.l   sbc,a0
        lea.l   sbce,a6
        move.w  (a0),(a6)
        lea.l   adsbc,a0
        lea.l   adsbce,a6
        move.l  (a0),(a6)
       subq.w #1,d7
       bge.s sbouce
       subq.w #1,d3
sbouc1e:
       move.w d4,d7
       add.w d1,d2
       bclr #7,d2
       beq.s sbce
       addq.w #1,d7
sbce:
       rol.l #1,d5
       bcc.s sbouce
adsbce:
       subq.l #8,a2
        subq.l  #8,a3
sbouce:
       adda.l (a1),a2
        adda.l  (a1),a3
        move.l  (a3),d0
        and.l   d5,d0
        or.l    d0,(a2)
        move.l  4(a3),d0
        and.l   d5,d0
        or.l    d0,4(a2)
       dbf d7,sbouce
       dbf d3,sbouc1e
        rts
modpal: 
        movem.l d0-d2/a0-a4,-(sp)
        lea.l   z1buf,a1
        move.l  paldep,a2
        move.l  palari,a3
        lea.l   paltra,a4
        move.w  #15,d0
        subq.w  #1,40(a1)
        blt.s   b2modpa
        beq.s   b1modpa
        subq.w  #1,36(a1)
        bge.s   smodp
        clr.w   36(a1)
        bra.s   bmodpa
smodp:  addq.w  #1,38(a1)
bmodpa: move.w  (a2)+,d1
        move.w  (a3)+,d2
        lsr.w   #8,d1
        lsr.w   #8,d2
        and.w   #$0007,d1
        and.w   #$0007,d2
        bsr     cmodpa
        lsl.w   #8,d1
        and.w   #$00ff,(a4)     
        or.w    d1,(a4)+
        dbf     d0,bmodpa
        bra.s   fmodpa
b1modpa:        move.w  (a2)+,d1
        move.w  (a3)+,d2
        lsr.w   #4,d1
        lsr.w   #4,d2
        and.w   #$0007,d1
        and.w   #$0007,d2
        bsr     cmodpa
        lsl.w   #4,d1
        and.w   #$0f0f,(a4)     
        or.w    d1,(a4)+
        dbf     d0,b1modpa
        bra.s   fmodpa
b2modpa:        move.w  (a2)+,d1
        move.w  (a3)+,d2
        and.w   #$0007,d1
        and.w   #$0007,d2
        bsr     cmodpa
        and.w   #$0ff0,(a4)     
        or.w    d1,(a4)+
        dbf     d0,b2modpa
        move.w  #2,40(a1)
fmodpa: bsr     rpal
        movem.l (sp)+,d0-d2/a0-a4
        rts
rpal:   move.w  #$8240,a0
        move.l  #paltra,a3
        move.w  #7,d1
brpal:  move.l  (a3)+,(a0)+
        dbf     d1,brpal
        rts
appal:  bsr     appalr
        rts
appalr: move.w  #$8240,a0
        move.l  #paleco,a3
        move.w  #7,d1
brpalb: move.l  (a0)+,(a3)+
        dbf     d1,brpalb
        rts
inipal: move.w  #7,d0
        move.l  paldep,a0
        move.l  #paltra,a2
binip:  move.l  (a0)+,(a2)+
        dbf     d0,binip
        rts
cmodpa: mulu    36(a1),d1
        mulu    38(a1),d2
        add.w   d2,d1
        lsr.w   #3,d1
        rts
pixlisb:
        bsr     appal
        move.l  #paleco,paldep
        move.l  #paleco,palari
        bra.s   spixb 
pixlis: bsr     appal
        move.l  #paleco,paldep
        move.l  P_pal,palari
spixb:  lea.l   z1buf,a1
        move.w  #8,36(a1)
        clr.w   38(a1)
        move.w  #2,40(a1)
        bsr     inipal
        move.l  P_xh,d0
        lsr.w   #1,d0
        and.w   #$fff8,d0
        move.l  P_yh,d1
        mulu    #160,d1
        move.l  P_xb,d2
        addq.l  #1,d2
        move.l  d2,d3
        lsr.w   #1,d2
        and.w   #$fff8,d2
        and.w   #$f,d3
        beq.s   pix1
        addq.l  #8,d2
pix1:   sub.l   d0,d2
        lsr.w   #3,d2   
        subq.w  #1,d2
        add.l   d1,d0
        move.l  d0,a0
        move.l  a0,a6
        add.l   P_eca,a0
        add.l   P_ecd,a6
        move.l  P_yb,d0
        sub.l   P_yh,d0
        addq.w  #1,d0
        move.w  d0,d1
        lsr.w   #4,d0
        and.w   #$f,d1
        bne.s   pix2
        subq.w  #1,d0
        move.w  #16,d1
pix2:   subq.w  #1,d1
        move.w  d1,nbyf
        move.w  d2,nbx
        move.w  d0,nby
        clr.l   d3
        clr.w   fl8f
        move.w  #16,nbfois
        move.l  #tamask,a4
        move.l  P_sty(pc),d1
        cmp.w   #6,d1
        blt.s   sspix
        subq.l  #6,d1
        move.b  #-1,fl8f
        move.w  #8,nbfois
        move.l  #tamask6,a4
        move.l  #tamask,a5
        move.w  #15,d5
        lsl.l   #7,d1
        add.l   d1,a5
bipir:  move.l  (a5)+,d1
        or.l    (a5)+,d1
        move.l  d1,64(a4)
        move.l  d1,(a4)+
        dbf     d5,bipir
        move.l  #tamask6,a4
        bra.s   bpix1
sspix:  lsl.l   #7,d1
        add.l   d1,a4
bpix1:  move.l  a0,a2
        move.l  a6,a3
        move.w  nby(pc),d5
bpix2:  move.w  nbx(pc),d4
        move.w  #15,d6
        tst.w   d5
        bne.s   bpix3
        move.w  nbyf(pc),d6
bpix3:  move.w  d6,d7
        move.l  a4,a5
        add.l   d3,a5
        clr.l   d1
bpix4:  move.l  (a5)+,d2
        not.l   d2
        and.l   d2,0(a2,d1.w)
        and.l   d2,4(a2,d1.w)
        not.l   d2
        move.l  0(a3,d1.w),d0
        and.l   d2,d0
        or.l    d0,0(a2,d1.w)
        move.l  4(a3,d1.w),d0
        and.l   d2,d0
        or.l    d0,4(a2,d1.w)
        add.l   #160,d1
        dbf     d7,bpix4
        addq.l  #8,a2
        addq.l  #8,a3
        dbf     d4,bpix3
        move.w  nbx(pc),d1
        addq.w  #1,d1
        lsl.w   #3,d1
        sub.w   d1,a2
        sub.w   d1,a3
        lea.l   2560(a2),a2
        lea.l   2560(a3),a3
        dbf     d5,bpix2
        addq.l  #4,d3
        tst.b   fl8f
        blt.s   modp3
        bchg    #0,fl8f
        beq.s   modp2
        bra.s   modp1
modp3:  bsr     modpal
modp2:  bsr     modpal
modp1:  bsr     modpal
        subq.w  #1,nbfois
        bgt     bpix1
        bra     feffets
fl8f:   dc.w    0
nbyf:   dc.w    0
nby:    dc.w    0
nbx:    dc.w    0
nbfois: dc.w    0
z1buf:   blk.l  15,0
ligne:  dc.l    0,0,319,187
valrupt:        dc.w    0,0,0,0
anva:   dc.l    0
tamask: dc.l    $20002000,$20002,$100010,$1000100
        dc.l    $80008000,$80008,$8000800,$800080
        dc.l    $10001,$10001000,$40004,$40004000
        dc.l    $400040,$4000400,$200020,$2000200
        dc.l    $20002000,$20002,$100010,$1000100
        dc.l    $80008000,$80008,$8000800,$800080
        dc.l    $10001,$10001000,$40004,$40004000
        dc.l    $400040,$4000400,$200020,$2000200
tamask1:
        dc.l    $80088008,$40044004,$20022002,$10011001
        dc.l    $08800880,$04400440,$02200220,$01100110
        dc.l    $01100110,$02200220,$04400440,$08800880
        dc.l    $10011001,$20022002,$40044004,$80088008
        dc.l    $80088008,$40044004,$20022002,$10011001
        dc.l    $08800880,$04400440,$02200220,$01100110
        dc.l    $01100110,$02200220,$04400440,$08800880
        dc.l    $10011001,$20022002,$40044004,$80088008
tamask2:
        dc.l    $80008000,$40004000,$20002000,$10001000
        dc.l    $8000800,$4000400,$2000200,$1000100
        dc.l    $800080,$400040,$200020,$100010
        dc.l    $80008,$40004,$20002,$10001
        dc.l    $80008000,$40004000,$20002000,$10001000
        dc.l    $8000800,$4000400,$2000200,$1000100
        dc.l    $800080,$400040,$200020,$100010
        dc.l    $80008,$40004,$20002,$10001
tamask3:
        dc.l    $80088008,$80088008,$40044004,$40044004
        dc.l    $20022002,$20022002,$10011001,$10011001
        dc.l    $08800880,$08800880,$04400440,$04400440
        dc.l    $02200220,$02200220,$01100110,$01100110
        dc.l    $80088008,$80088008,$40044004,$40044004
        dc.l    $20022002,$20022002,$10011001,$10011001
        dc.l    $08800880,$08800880,$04400440,$04400440
        dc.l    $02200220,$02200220,$01100110,$01100110
tamask4:
        dc.l    $00010001,$00040004,$00100010,$00400040
        dc.l    $01000100,$04000400,$10001000,$40004000
        dc.l    $80008000,$20002000,$08000800,$02000200
        dc.l    $00800080,$00200020,$00080008,$00020002
        dc.l    $00010001,$00040004,$00100010,$00400040
        dc.l    $01000100,$04000400,$10001000,$40004000
        dc.l    $80008000,$20002000,$08000800,$02000200
        dc.l    $00800080,$00200020,$00080008,$00020002

tamask5:
        dc.l    $00010001,$000a000a,$00120012,$00240024
        dc.l    $00880088,$00080008,$04900490,$09200920
        dc.l    $02200220,$24402440,$28802880,$01000100
        dc.l    $26002600,$58005800,$c000c000,$80008000
        dc.l    $00010001,$000a000a,$00120012,$00240024
        dc.l    $00880088,$00080008,$04900490,$09200920
        dc.l    $02200220,$24402440,$28802880,$01000100
        dc.l    $26002600,$58005800,$c000c000,$80008000
tamask6: 
        dc.l    $80408040,$4080408,$8200820,$2800280
        dc.l    $20012001,$10021002,$140014,$41004100
        dc.l    $80408040,$4080408,$8200820,$2800280
        dc.l    $20012001,$10021002,$140014,$41004100
        dc.l    $80408040,$4080408,$8200820,$2800280
        dc.l    $20012001,$10021002,$140014,$41004100
        dc.l    $80408040,$4080408,$8200820,$2800280
        dc.l    $20012001,$10021002,$140014,$41004100
paleco: dc.l    0,0,0,0,0,0,0,0
paldep: dc.l    0
palari: dc.l    0
paltra: dc.w    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
palnoir:        dc.w    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
P_eff:  dc.l    0
P_sty:  dc.l    0
P_pal:  dc.l    0
P_ecd:  dc.l    0
P_eca:  dc.l    0
P_xh:   dc.l    0
P_yh:   dc.l    0
P_xb:   dc.l    0
P_yb:   dc.l    0
;
REMAPEC:
        movem.l d0-d7/a0-a6,-(sp)
        move.l  64(a7),a1
        move.l  68(a7),a0
        lea.l   zbuf,a3
        move.w  74(a7),10(a3)
        move.w  78(a7),12(a3)
        move.w  82(a7),14(a3)
        move.w  86(a7),16(a3)
        move.l  88(a7),a5
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
    adda.l d2,a0
    move.w 14(a3),d1 
    move.w 16(a3),d2 
    sub.w 10(a3),d1 
    sub.w 12(a3),d2 
    move.l a1,(a3) 
    move.l a0,8(a3)
    move.w d3,4(a3) 
    move.w d1,6(a3) 
    move.w d2,d0
    bra.s idebcl 
ibclx:
    subq.w #1,d3 
    bge.s ibcld3 
    move.w #15,d3 
        move.w  d4,(a0)+
        move.w  d5,(a0)+
        move.w  d6,(a0)+
        move.w  d7,(a0)+
idebcl:
    move.w (a1)+,d4 
    move.w (a1)+,d5 
    move.w (a1)+,d6 
    move.w (a1)+,d7 
ibcld3:
    clr.w  d2
    btst d3,d4 
    beq.s itstd5 
    bset #0,d2 
itstd5:
    btst d3,d5 
    beq.s itstd6 
    bset #1,d2 
itstd6:
    btst d3,d6 
    beq.s itstd7 
    bset #2,d2 
itstd7:
    btst d3,d7 
    beq.s iftst 
    bset #3,d2 
iftst:
    move.b      0(a5,d2.w),d2
    bclr        d3,d4
    bclr        d3,d5
    bclr        d3,d6
    bclr        d3,d7
        btst    #0,d2
        beq.s   yy0
        bset    d3,d4
yy0:    btst    #1,d2
        beq.s   yy1
        bset    d3,d5
yy1:    btst    #2,d2
        beq.s   yy2
        bset    d3,d6
yy2:    btst    #3,d2
        beq.s   yy3
        bset    d3,d7
yy3:
    dbf d1,ibclx  
        move.w  d4,(a0)+
        move.w  d5,(a0)+
        move.w  d6,(a0)+
        move.w  d7,(a0)+
    addi.l #160,(a3) 
    addi.l #160,8(a3)
    move.l (a3),a1 
    move.l 8(a3),a0
    move.w 4(a3),d3 
    move.w 6(a3),d1 
    dbf d0,idebcl 
        movem.l (sp)+,d0-d7/a0-a6
        move.l  (a7),28(a7)
        lea.l   28(a7),a7
    rts 
;
DECOMP:
    move.l 4(a7),adecr
    move.w 10(a7),ycoor
    move.w 14(a7),xcoor
    move.l 16(a7),adfi
    move.l 20(a7),plcomp
    move.l 24(a7),adremap
    movem.l d0-d7/a0-a6,-(sp)
        move.l  adremap(pc),a2
        cmpa.l  #0,a2
        ble.s   paremap
        move.w  #15,d0
        lea.l   tabinst2(pc),a0
        lea.l   tabinst(pc),a1
        lea.l   taconv(pc),a3
        clr.w   d1
        clr.w   d2
b0chtin:
        move.b  0(a3,d0.w),d2
        move.b  0(a2,d0.w),d1
        move.b  0(a3,d1.w),d1
        lsl.w   #2,d2
        lsl.w   #2,d1
        move.l  0(a0,d1.w),0(a1,d2.w)
        dbf     d0,b0chtin
        bra.s   firemap
paremap:
        move.w  #3,d0
        lea.l   tabinst2(pc),a0
        lea.l   tabinst(pc),a1
bchtin:
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        dbf     d0,bchtin
firemap:
    move.l adfi(pc),a0
    move.b (a0),typfi
    move.b 1(a0),nbcar
    add.l #2,adfi
    tst.b typfi
    bne fiani
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
    lea.l zbuf(pc),a3
        moveq   #0,d6
;;;;;;    test pour sprite loupe
        cmp.w   #1,ztal
        bne     paspgr
        move.l  adfi(pc),a0
        tst.l   4(a0)
        bne     atcara
        lea.l   tspgr(pc),a0
        lea.l   12(a0),a1
        move.w  6(a3),d2
        addq.w  #1,d2
        lsr.w   #1,d2
        move.w  8(a0),d0
        move.w  d0,d1
        add.w   d2,d1
        subq.w  #1,d1
        bsr     tstbol
        lea.l   2(a0),a0
        lea.l   6(a1),a1
        move.w  8(a3),d2
        addq.w  #1,d2
        lsr.w   #1,d2
        move.w  8(a0),d0
        move.w  d0,d1
        add.w   d2,d1
        subq.w  #1,d1
        bsr     tstbol
        lea.l   tspgr+12(pc),a1
        move.w  2(a1),d0
        lsl.w   #1,d0
        add.w   d0,10(a3)
        move.w  8(a1),d0
        lsl.w   #1,d0
        add.w   d0,12(a3)
        move.w  6(a3),d6
        lsr.w   #1,d6
        addq.w  #1,d6
        move.w  d6,d1
        mulu    6(a1),d1
        lsl.l   #1,d1
        add.w   (a1),d1
        add.l   d1,adcomp
        sub.w   4(a1),d6
        move.w  4(a1),d0
        lsl.w   #1,d0
        subq.w  #1,d0
        move.w  d0,6(a3)
        move.w  10(a1),d0
        lsl.w   #1,d0
        subq.w  #1,d0
        move.w  d0,8(a3)
        bra     paspgr
tstbol: clr.w   d3
        cmp.w   (a0),d0
        blt.s   tbol1
        bset    #3,d3
tbol1:  cmp.w   4(a0),d0
        bgt.s   tbol2
        bset    #2,d3
tbol2:  cmp.w   (a0),d1
        blt.s   tbol3
        bset    #1,d3
tbol3:  cmp.w   4(a0),d1
        bgt.s   tbol4
        bset    #0,d3
tbol4:  lsl.w   #1,d3
        lea.l   tabol(pc),a5
        jmp     0(a5,d3.w)
tabol:  
        bra.s   padbol
        bra.s   padbol
        bra.s   padbol
        bra.s   padbol
        bra.s   padbol
        bra.s   padbol
        bra.s   bol0110
        bra.s   bol0111
        bra.s   padbol
        bra.s   padbol
        bra.s   padbol
        bra.s   padbol
        bra.s   padbol
        bra.s   padbol
        bra.s   bol1110
        bra.s   bol1111
padbol: move.l  #atcara1,(a7)
        rts
bol0110:
        move.w  (a0),(a1)
        sub.w   d0,(a1)
        clr.w   2(a1)
        move.w  4(a0),d0
        sub.w   (a0),d0
        addq.w  #1,d0
        move.w  d0,4(a1)
        rts
bol0111:
        move.w  (a0),(a1)
        sub.w   d0,(a1)
        clr.w   2(a1)
        sub.w   (a1),d2
        move.w  d2,4(a1)
        rts
bol1110:
        clr.w   (a1)
        move.w  4(a0),d2
        sub.w   d0,d2
        addq.w  #1,d2
        move.w  d2,4(a1)
        sub.w   (a0),d0
        move.w  d0,2(a1)
        rts
bol1111:
        clr.w   (a1)
        sub.w   (a0),d0
        move.w  d0,2(a1)
        move.w  d2,4(a1)
        rts
paspgr:
    lea.l tabinst(pc),a4
    lea.l chet1(pc),a5
    lea.l chet2(pc),a6 
    move.l adecr(pc),a1 
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
    bsr    chet1                ;pour vider la memoire cache 
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
    bsr    chet2                    ;pour vider la memoire cache
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
;;;;;    add pour objet loupe
        add.w   d6,a0 
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
    move.l adfi,a4
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
tabinst: blk.l  16,0
tabinst2:
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
    move.l adanc,a0
    move.l plcomp,a1
    move.l a1,adcoc
    clr.b d1
    clr.b d0
    move.l adfi,a5
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
    move.l adanq,a0
    move.l tailcou,a1
    move.l tailcou,adcoq
    clr.b d0
    move.l adfi,a5
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
    lea.l zbuf,a3
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
    lea.l zbuf,a3
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
    lea.l zbuf,a3
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
    lea.l zbuf,a3
    move.w #3,14(a3)
    bra.s hcomm
dcomph4:
    lea.l zbuf,a3
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
    cmp.w savbcg,d1
    bgt ddifin
    cmp.w ppt,d1
    bgt.s ddipac1
    add.w #1,savbc1
ddipac1:
    cmp.w pga,d1
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
    move.w savbc1,d6
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
    lea.l zbuf,a3
    move.w #1,14(a3)
    bra hdomm
dcomdh2:
    lea.l zbuf,a3
    move.w #2,14(a3)
    bra hdomm
dcomdh3:
    lea.l zbuf,a3
    move.w #3,14(a3)
    bra hdomm
dcomdh4:
    lea.l zbuf,a3
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
    lea.l zbuf,a3
    move.l adcoq,a1
    move.l adcoc,a2
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
;
GROSSI:
    movem.l d0-d7/a0-a6,-(sp)
    move.l 64(a7),adecr
    move.l 68(a7),plcomp
    move.w 74(a7),xcoor
    move.w 78(a7),ycoor
    move.w 82(a7),d0
    move.w 86(a7),d1
    sub.w xcoor,d0
    sub.w ycoor,d1
    move.w d0,tailx
    move.w d1,taily
    move.w 90(a7),x1coor
    move.w 94(a7),y1coor
    move.w 98(a7),d0
    move.w 102(a7),d1
    sub.w x1coor,d0
    sub.w y1coor,d1
    move.w d0,tail1x
    move.w d1,tail1y
    move.w 106(a7),x2coor
    move.w 110(a7),y2coor
    move.w 114(a7),fact
    move.l 116(a7),ad_par
    move.l plcomp,a0
    move.w #149,d0
    moveq       #0,d1
bxxx:
    move.l  d1,(a0)+
    move.l  d1,(a0)+
    move.l  d1,(a0)+
    move.l  d1,(a0)+
    move.l  d1,(a0)+
    move.l  d1,(a0)+
    move.l  d1,(a0)+
    move.l  d1,(a0)+
    move.l  d1,(a0)+
    move.l  d1,(a0)+
    dbf d0,bxxx
    move.l plcomp,a0
    move.l adecr,a1
    move.l #zbuf,a3
    move.w xcoor,d1
    move.w ycoor,d2
    move.w d1,d3
    mulu #160,d2
    lsr.w #1,d1
    andi.b #$f8,d1
    add.w d1,d2
    andi.w #$000f,d3
    eori.b #$0f,d3
    adda.l d2,a1
    move.w tailx,d1
    move.w taily,d2
    move.l a1,(a3)
    move.w d3,4(a3)
    move.w d1,6(a3)
    move.w d2,8(a3)
    move.w #7,d0
    bra.s debcl
bclx:
    subq.w #1,d3
    bge.s bcld3
    move.w #15,d3
debcl:
    move.w (a1)+,d4
    move.w (a1)+,d5
    move.w (a1)+,d6
    move.w (a1)+,d7
bcld3:
    btst d3,d4
    beq.s tstd5
    bset d0,(a0)
tstd5:
    subq.w #1,d0
    btst d3,d5
    beq.s tstd6
    bset d0,(a0)
tstd6:
    subq.w #1,d0
    btst d3,d6
    beq.s tstd7
    bset d0,(a0)
tstd7:
    subq.w #1,d0
    btst d3,d7
    beq.s ftst
    bset d0,(a0)
ftst:
    subq.w #1,d0
    bgt.s moct
    move.w #7,d0
    addq.l #1,a0
moct:
    dbf d1,bclx
    cmpi.w #7,d0
    beq.s xpair
    move.b (a0)+,d0
    lsr.b #4,d0
    or.b d0,-1(a0)
    move.w #7,d0
xpair:
    addi.l #160,(a3)
    move.l (a3),a1
    move.w 4(a3),d3
    move.w 6(a3),d1
    dbf d2,debcl
    move.l adecr,a1
    move.w x1coor,d1
    move.w y1coor,d2
    move.w d1,d3
    mulu #160,d2
    lsr.w #1,d1
    andi.b #$f8,d1
    add.w d1,d2
    andi.w #$000f,d3
    eori.b #$0f,d3
    adda.l d2,a1
    clr.w d7
    bset d3,d7
    move.w d7,4(a3)
    move.w d7,d3
    eor.w #$ffff,d3
    move.w #$ffff,maskdeb
memade:
    and.w d3,maskdeb
    ror.w #1,d3
    bcs.s memade
    move.w maskdeb,d2
    move.w tail1x,d1
    move.w tail1y,boucy
    move.l a1,(a3)
    clr.w filin
bafxx:
    ror.w #1,d7
    bcc.s btaf
    and.w d2,(a1)
    and.w d2,2(a1)
    and.w d2,4(a1)
    and.w d2,6(a1)
    addq.l #8,a1
    clr.w d2    
btaf:
    dbf d1,bafxx
    tst.w filin
    bne.s seclg
    move.w #1,filin
    move.w d7,d1
    eor.w #$ffff,d1
    move.w #$ffff,maskfi
memafi:
    and.w d1,maskfi
    rol.w #1,d1
    bcs.s memafi
seclg:
    or.w maskfi,d2
    and.w d2,(a1)
    and.w d2,2(a1)
    and.w d2,4(a1)
    and.w d2,6(a1)
    move.w maskdeb,d2
    addi.l #160,(a3)
    move.l (a3),a1
    move.w 4(a3),d7
    move.w tail1x,d1
    sub.w #1,boucy
    bge bafxx
    move.l adecr,a1
    move.w x2coor,d1
    move.w y2coor,d2
    move.w d1,d3
    mulu #160,d2
    lsr.w #1,d1
    andi.b #$f8,d1
    add.w d1,d2
    andi.w #$000f,d3
    eori.b #$0f,d3
    adda.l d2,a1
    clr.w d7
    bset d3,d7
    move.w d7,4(a3)
    move.w tailx,d1
    move.w taily,d2
    move.l a1,(a3)
    move.w #7,d0
    move.l plcomp,a0
    sub.w #1,fact
    bra.s obitaf
obafx:
    move.w fact,d3
drord7:
    ror.w #1,d7
    bcc.s obitf
    addq.l #8,a1
obitf:
    dbf d3,drord7
obitaf:
    btst d0,(a0)
    beq.s obaf1
    move.w fact,d3
    move.l a1,a6
    move.w d7,d6
bcc0:
    move.w fact,d4
    clr.w d5
bcx0:
    or.w d6,0(a6,d5.w)
    add.w #160,d5
    dbf d4,bcx0
    ror.w #1,d6
    bcc.s itaf
    addq.l #8,a6
itaf:
    dbf d3,bcc0
obaf1:
    subq.w #1,d0
    btst d0,(a0)
    beq.s obaf2
    move.w fact,d3
    move.l a1,a6
    move.w d7,d6
bcc1:
    move.w fact,d4
    clr.w d5
bcx1:
    or.w d6,2(a6,d5.w)
    add.w #160,d5
    dbf d4,bcx1
    ror.w #1,d6
    bcc.s itaf1
    addq.l #8,a6
itaf1:
    dbf d3,bcc1
obaf2:
    subq.w #1,d0
    btst d0,(a0)
    beq.s obaf3
    move.w fact,d3
    move.l a1,a6
    move.w d7,d6
bcc2:
    move.w fact,d4
    clr.w d5
bcx2:
    or.w d6,4(a6,d5.w)
    add.w #160,d5
    dbf d4,bcx2
    ror.w #1,d6
    bcc.s itaf2
    addq.l #8,a6
itaf2:
    dbf d3,bcc2
obaf3:
    subq.w #1,d0
    btst d0,(a0)
    beq.s ofbaf
    move.w fact,d3
    move.l a1,a6
    move.w d7,d6
bcc3:
    move.w fact,d4
    clr.w d5
bcx3:
    or.w d6,6(a6,d5.w)
    add.w #160,d5
    dbf d4,bcx3
    ror.w #1,d6
    bcc.s itaf3
    addq.l #8,a6
itaf3:
    dbf d3,bcc3
ofbaf:
    subq.w #1,d0
    bgt.s omocaf
    move.w #7,d0
    addq.l #1,a0
omocaf:
    dbf d1,obafx
    cmpi.w #7,d0
    beq.s oxpaiaf
    addq.l #1,a0
    move.w #7,d0
oxpaiaf:
    move.w fact,d3
bada3:
    addi.l #160,(a3)
    dbf d3,bada3
    move.l (a3),a1
    move.w 4(a3),d7
    move.w tailx,d1
    dbf d2,obitaf
atcara2:
        move.l  ad_par(pc),a0
        moveq   #9,d0
        lea.l   tspgr,a1
        lea.l   40(a0),a2
        move.w  xcoor(pc),(a1)
        move.w  ycoor(pc),2(a1)
        move.w  xcoor(pc),4(a1)
        move.w  ycoor(pc),6(a1)
        move.w  tailx(pc),d1
        add.w   d1,4(a1)
        move.w  taily(pc),d1
        add.w   d1,6(a1)
        move.w  #1,ztal
btafgr: tst.l   (a0)
        blt.s   stafgr
        move.l  #0,-(a7)
        move.l  plcomp(pc),-(a7)
        move.l  (a0),-(a7)
        move.w  x2coor(pc),-(a7)
        lea.l   -2(a7),a7
        move.w  y2coor(pc),-(a7)
        lea.l   -2(a7),a7
        move.l  adecr(pc),-(a7)
        move.w  (a2),8(a1)
        move.w  20(a2),10(a1)
        bsr     DECOMP
stafgr: lea.l   4(a0),a0
        lea.l   2(a2),a2
        dbf     d0,btafgr
        clr.w   ztal
    movem.l  (sp)+,d0-d7/a0-a6
    move.l (a7),56(a7)
    add.l #56,a7
    rts
taconv:  dc.b 0,8,4,12,2,10,6,14,1,9,5,13,3,11,7,15
adremap: dc.l 0
tspgr:  blk.w  12,0
ztal:   dc.w  0
ad_par:  dc.l  0
adfi:  dc.l 0
xcoor: dc.w 0
ycoor: dc.w 0
x1coor: blk.w 1,0
y1coor: blk.w 1,0
x2coor: blk.w 1,0
y2coor: blk.w 1,0
tailx:  blk.w 1,0
taily:  blk.w 1,0
tail1x:  blk.w 1,0
tail1y:  blk.w 1,0
fact:   blk.w 1,0
adcomp:   blk.l 1,0
adecr:    blk.l 1,0
adcoc:    blk.l 1,0
adcoq:    blk.l 1,0
adanc:    blk.l 1,0
adanq:    blk.l 1,0
plcomp:   blk.l 1,0
plaff:    blk.l 1,0
tailcou:  blk.l 1,0
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
zbuf:     blk.l 6,0

chet1:
    nop
    nop
    rts
chet2:
    nop
    nop
    rts
adpiano:
        dc.l    0       ;adresse premier mot du piano dans animation
        dc.l    0       ;adresse fichier son-anim Jean-Luc
        dc.l    0       ;adresse fin animation
        dc.w    0       ;numero de lieu



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;                      ROUTINES DROIN
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

NOMSAUVE: EQU     6

CLOSE:   EQU     BASLOAD                ;inutile
MAKEKEY: EQU     BASLOAD+6
CALCHUF: EQU     BASLOAD+12
HUFFMAN: EQU     BASLOAD+18
BLOAD:   EQU     BASLOAD+24             ;inutile
READ:    EQU     BASLOAD+30
WRITE:   EQU     BASLOAD+36
INDISK:  EQU     BASLOAD+42
TSTFACE: EQU     BASLOAD+48

ecrsup:
        dc.l    0
bufsup:
        dc.l    0
sensmort:
        dc.w    0
savpi8: dc.l    0

DOMORT: 
        movem.l D1-D7/A0-A6,-(A7)
        JSR     COUPSON
        BSR     EXITANI
        move.l  adpiano+8,savpi8
        move.l  LADRES,adpiano+8
        add.l   #64000,adpiano+8
        jsr     INITBASECH
;        move.l  #53,d0
;        move.l  PRGMUS+16,a0
;        jsr     (a0)
        move.l  savpi8(pc),adpiano+8
        jsr     INITBASECH
        MOVE.L  #1,-(A7)
        BSR     VBLSYNC
        move.w  66(A7),sensmort
        bne.s   sn1mort
        move.l  60(A7),paldep
        move.l  #palnoir,palari
        move.w  #26,ampmort+6
        bra.s   sn2mort
sn1mort:
        move.l  60(A7),palari
        move.l  #palnoir,paldep
        clr.w   ampmort+6
sn2mort:
        lea     z1buf,A1
        move.w  #8,36(a1)
        clr.w   38(a1)
        move.w  #2,40(a1)
        jsr     inipal
        bsr     inmort
        clr.w   debmort
        move.w  #1,ampmort
        tst.w   sensmort
        beq.s   am8mort
        move.w  #3,ampmort
        move.w  #5,debmort
am8mort:
        move.w  ampmort(PC),D2
        move.w  D2,ampmort+2
        move.w  D2,D0
        lsl     #3,D0
        move.w  D0,ampmort+4
        tst.w   sensmort
        beq.s   a11mort
        subq    #1,D2
am6mort:
        moveq   #2,D1
        bsr     exemort
        dbf     D2,am6mort
        moveq   #0,D2
a15mort:
        moveq   #0,D1
        bsr     exemort
        dbf     D2,a15mort
        bra     a12mort
a11mort:
        moveq   #6,D1
        bsr     exemort
a12mort:
        moveq   #8,D1
        bsr     exemort
exe2mort:
        subq    #1,ampmort+6
        bgt.s   a13mort
        jsr     modpal
        move.w  #1,ampmort+6
a13mort:
        move.w  debmort(PC),D1
        andi.w  #7,D1
        bsr     exemort
        moveq   #8,D1
        bsr     exemort
        subq    #1,ampmort+2
        bgt.s   am1mort
        addq    #1,debmort
        move.w  ampmort(PC),ampmort+2
am1mort:
        subq    #1,ampmort+4
        bgt     am2mort
        tst     sensmort
        bgt     a10mort
        moveq   #7,D1
        bsr     exemort
        moveq   #8,D1
        bsr     exemort
        clr.w   debmort
        addq    #1,ampmort
        move.w  ampmort(PC),D1
        move.w  D1,ampmort+2
        lsl     #3,D1
        move.w  D1,ampmort+4
        subq    #1,ampmort+2
        subq    #1,ampmort+4
        cmpi    #4,ampmort
        blt     exe2mort
        bra     fn1mort
a10mort:
        move.w  debmort(PC),D1
        andi    #7,D1
        bsr     exemort
        moveq   #8,D1
        bsr     exemort
        move.w  #5,debmort
        subq    #1,ampmort
        move.w  ampmort(PC),D1
        move.w  D1,ampmort+2
        lsl     #3,D1
        move.w  D1,ampmort+4
        subq    #1,ampmort+4
        btst    #0,ampmort+1
        beq.s   am2mort
        subq    #1,ampmort+4
        tst     ampmort
        bgt     exe2mort
        bra     fn1mort
am2mort:
        bra     exe2mort
fn1mort:
        movem.l (A7)+,D1-D7/A0-A6
        move.l  (A7),8(A7)
        lea     8(A7),A7
        rts
ampmort:
        dc.w    1,1,8,0
debmort:
        dc.w    0
exemort:
        clr.w   D0
        add     D1,D1
        move.b  ta1mort(PC,D1.W),D0
        bsr     ex1mort
        move.b  ta1mort+1(PC,D1.W),D0
        bsr     ex1mort
        rts
ex1mort:
        lsl     #2,D0
        movem.l D0-D7/A0-A5,-(A7)
        move.l  bufsup(PC),A0
        move.l  ecrbuf(PC),A1
        move.l  adphys(PC),A2
        jmp     tabmort(PC,D0.W)
ta1mort:
        dc.b    1,0,1,3,0,3,2,3,2,0,2,4,0,4,1,4,0,5
tabmort:
        bra     do6mort
        bra     supmort
        bra     infmort
        bra     dromort
        bra     gaumort
        bra     do4mort
mskmort:
        dc.l    0
ligmort:
        dc.w    0
snsmort:
        dc.w    0
inmort:
        move.w  #199,ligmort
        clr.w   snsmort
        movem.l D0-D7/A0-A5,-(A7)
        move.l  ecrbuf(PC),A0            ;init ecrbuf avec ecran trame
        move.l  adphys(PC),A1
        move.l  ecrsup(PC),A2
        move.w  #199,D0
        move.l  #$aaaaaaaa,D4
        move.l  D4,mskmort
        not.l   mskmort
do2mort:
        moveq   #19,D1
        clr.l   (A2)+
        clr.l   (A2)+
do1mort:
        move.l  (A0)+,D2
        move.l  (A0)+,D3
        move.l  D2,(A1)+
        move.l  D3,(A1)+
        and.l   D4,D2
        and.l   D4,D3
        move.l  D2,(A2)+
        move.l  D3,(A2)+
        dbf     D1,do1mort
        clr.l   (A2)+
        clr.l   (A2)+
        ror.l   #1,D4
        dbf     D0,do2mort             ;fin init ecrbuf
        move.l  ecrsup(PC),bufsup
        movem.l (A7)+,D0-D7/A0-A5
        rts
supmort:
        not.l   mskmort
        addq    #1,snsmort
        ble     su1mort
        subq.w  #1,ligmort
        add.l   #176,bufsup
        bra     do6mort
su1mort:
        addq    #1,ligmort
        bra     do6mort
infmort:
        not.l   mskmort
        subq    #1,snsmort
        bge     in1mort
        subq.w  #1,ligmort
        bra     do6mort
in1mort:
        addq    #1,ligmort
        sub.l   #176,bufsup
        bra     do6mort
gaumort:
        dc.l    $023c0000       ;        andi.b     #0,CCR
        not.l   mskmort
        move.l  ecrsup(PC),A3
        adda.l  #35200,A3
        moveq   #3,D1
gau2mort:
        move.w  #1099,D0
gau1mort:
        roxl    (A3)
        subq    #8,A3
        roxl    (A3)
        subq    #8,A3
        roxl    (A3)
        subq    #8,A3
        roxl    (A3)
        subq    #8,A3
        dbf     D0,gau1mort
        adda.l  #35198,A3
        dbf     D1,gau2mort
        bra     do6mort
dromort:
        not.l   mskmort
        move.l  ecrsup(PC),A3
        moveq   #3,D1
dro2mort:
        dc.l    $023c0000       ;        andi.b    #0,CCR
        move.w  #1099,D0
dro1mort:
        roxr    (A3)+
        addq    #6,A3
        roxr    (A3)+
        addq    #6,A3
        roxr    (A3)+
        addq    #6,A3
        roxr    (A3)+
        addq    #6,A3
        dbf     D0,dro1mort
        suba.l  #35198,A3
        dbf     D1,dro2mort
        bra     do6mort
do4mort:
        adda    #8,A0
        move.l  mskmort(PC),D4
        tst.w   snsmort
        bge.s   doamort
        not.l   D4
        bsr     do9mort
doamort:
        move.w  ligmort,D7
do5mort:
        moveq   #9,D6
do3mort:
        movem.l (A0)+,D0-D3               ;superpose les deux ecrans
        move.l  (A1)+,D5
        and.l   D4,D5
        or.l    D0,D5
        move.l  D5,(A2)+
        move.l  (A1)+,D5
        and.l   D4,D5
        or.l    D1,D5
        move.l  D5,(A2)+
        move.l  (A1)+,D5
        and.l   D4,D5
        or.l    D2,D5
        move.l  D5,(A2)+
        move.l  (A1)+,D5
        and.l   D4,D5
        or.l    D3,D5
        move.l  D5,(A2)+
        dbf     D6,do3mort
        adda    #16,A0
        not.l   D4
        dbf     D7,do5mort
        tst.w   snsmort
        ble.s   do6mort
        bsr     do9mort
do6mort:
        movem.l (A7)+,D0-D7/A0-A5
        rts
do9mort:
        move.w  #199,D7
        sub.w   ligmort,D7
do8mort:
        moveq   #9,D6
do7mort:
        movem.l  (A1)+,D0-D3
        and.l   D4,D0
        and.l   D4,D1
        and.l   D4,D2
        and.l   D4,D3
        movem.l D0-D3,(A2)
        add     #16,A2
        dbf     D6,do7mort
        not.l   D4
        dbf     D7,do8mort
        rts
;
SAVMEM:
  link     A6,#0
  movem.l  D1-D7/A0-A5,-(A7)
  move.l   28(A6),A0  ;;source
  move.l   24(A6),A1  ;;dest
  move.l   20(A6),D0  ;;xh
  move.l   16(A6),D1  ;;yh
  move.l   12(A6),D2  ;;xb
  move.l   8(A6),D3   ;;yb
  cmpi.w   #199,D3
  blt.s    clipsav
  move.w   #199,D3
clipsav:
  sub.w    D1,D3      ;;nombre de lignes
  mulu     #160,D1    ;;offset par rapport debut en octets
  lsr.w    #1,D0
  andi.w   #-8,D0     ;;premier bloc de la ligne
  lsr.w    #1,D2
  and.w    #-8,D2     ;;dernier bloc de la ligne
  sub.w    D0,D2      ;;largeur en octets
  move.w   #152,D4
  sub.w    D2,D4
  lsr.w    #3,D2      ;;largeur en bloc
ajout:
  add.w    D0,D1 
  tst      34(A6)     ;;mot faible du drapeau
;*** A0 = source
;*** A1 = dest
;*** D1 = depla 
;*** D2 = largeur
;*** D3 = nombre de lignes
  bgt      sload
  blt      sloadmsk
;*
;**** sauve la zone ***
;*
sauvi:
  adda     D1,A0      ;;deb ligne source
  move.w   D3,D1
savm001:
  move.w   D2,D0
savm002:
  move.l   (A0)+,(A1)+
  move.l   (A0)+,(A1)+
  dbf      D0,savm002
  adda     D4,A0
  dbf      D1,savm001
  bra      xfinx
;*
;**** restore la zone sans couleur de masque ***
;*
sload:                      ;;recharge zone sauvee
  move.l   A1,D0
  beq      biload
;*
;**** restore un seul ecran ***
;*
  adda     D1,A1            ;;deb ligne dest
  move.w   D3,D1
  bsr      smemcm
  subq     #1,D2
savm101:
  andi.l   D7,(A1)          ;;bord gauche
  andi.l   D7,4(A1)
  not.l    D7
  move.l   (A0)+,D0
  andi.l   D7,D0
  or.l     D0,(A1)+
  move.l   (A0)+,D0
  andi.l   D7,D0
  or.l     D0,(A1)+
  not.l    D7   
  move.w   D2,D0
  bra.s    savm103
savm102:
  move.l   (A0)+,(A1)+
  move.l   (A0)+,(A1)+
savm103:
  dbf      D0,savm102
  andi.l   D6,(A1)          ;;bord droit
  andi.l   D6,4(A1)
  not.l    D6
  move.l   (A0)+,D0
  andi.l   D6,D0
  or.l     D0,(A1)+
  move.l   (A0)+,D0
  andi.l   D6,D0
  or.l     D0,(A1)+
  not.l    D6 
  adda     D4,A1
  dbf      D1,savm101
  bra      xfinx
;*
;*** code modifie pour 2 ecrans ***
;*
insbilo:
  move.w   D6,(A3)+             ;; efface masque
  move.w   (A4)+,(A3)+
incmask:
  move.l   A5,A4                ;si flgmask = 0
  nop
  adda     D5,A4                ;si flgmask = 1
  nop
  lea      40(A4),A4            ;si ligne < 12 ou ligne > 173
;*
;**** restore les 2 ecrans ***
;*
biload:
  move.l   ecrbuf(PC),A1
  move.l   adphys(PC),A2
  adda     D1,A1      ;;deb ligne dest
  adda     D1,A2
  move.l   admask(PC),A3
  lsr.w    #2,D1      ;;pour ad mask
  adda     D1,A3      ;;     '
  move.l   A3,A4
  lea      8000(A4),A4
  move.w   18(A6),D1
  mulu     #40,D1
  sub      D1,A4
  move.l   A4,A5
  move.w   D4,D5      ;;     '
  lsr.w    #2,D5      ;;     '
  move.w   D3,D1
  clr.w    D6
  tst      flgmask
  beq.s    debypag1
  move.l   A3,A4
  sub.l    admask(PC),A4
  sub      #12*40,A4
  add.l    bufmask(PC),A4
debypag1:
  move.w   D2,D0
  cmpi.w   #12,18(A6)
  blt.s    insbilo2
  cmpi.w   #175,18(A6)
  bge.s    insbilo2
  move.w   insbilo+2(PC),insbilo1
  move.l   incmask(PC),insbilo3
  tst      flgmask
  beq.s    clmnor1
  move.l   incmask+4(PC),insbilo3
clmnor1:
  bra.s    debylign1
insbilo2:
  move.w   insbilo(PC),insbilo1
  move.l   incmask+8(PC),insbilo3    
debylign1:
  move.l   (A0)+,D7
  move.l   D7,(A1)+
  move.l   D7,(A2)+
  move.l   (A0)+,D7
  move.l   D7,(A1)+
  move.l   D7,(A2)+
insbilo1:
  nop                           ;; installe par comparateur ligne
  dbf      D0,debylign1
  adda     D4,A1
  adda     D4,A2
  adda     D5,A3                ;; incremente ad mask
insbilo3:
  nop                           ;; installe par flgmask
  nop
  addq     #1,18(A6)
  dbf      D1,debypag1
xfinx:
  addq     #1,D3
  addq     #1,D2
  mulu     D2,D3
  lsl.w    #3,D3
  move.w   D3,D0                ;; taille du bloc
  andi.l   #$ffff,D0
  movem.l  (A7)+,D1-D7/A0-A5
  unlk     A6
  move.l   (A7),28(A7)
  lea      28(A7),A7
  rts
;
smemcm:     ;*** calcule masques gauche et droit pour savmem ***
  move     20(A6),D0
  andi     #15,D0
  move     #-1,D7
  lsr      D0,D7
  not      D7
  move     D7,D0
  swap     D7
  move     D0,D7            ;;masque gauche
  move     12(A6),D0
  andi     #15,D0
  subq     #1,D0
  move     #$8000,D6
  asr      D0,D6
  not      D6
  move     D6,D0
  swap     D6
  move     D0,D6            ;;masque droit
  rts
;*
;**** restore la zone avec masquage ***
;*
;*
;**** restore un seul ecran ***
;*
zx1234:
  nop
  not      D0
  not      D1
sloadmsk:                   ;;recharge zone sauvee
  move     34(A6),D7
  addq     #1,D7
  neg      D7
  lea      zx1(pc),A2
  move     zx1234(pc),zx1-zx1(A2)
  move     zx1234(pc),zx2-zx1(A2)
  move     zx1234(pc),zx3-zx1(A2)
  move     zx1234(pc),zx4-zx1(A2)
  btst     #0,D7
  beq.s    azx1
  move     zx1234+2(pc),zx1-zx1(A2)
azx1:
  btst     #1,D7
  beq.s    azx2
  move     zx1234+4(pc),zx2-zx1(A2)
azx2:
  btst     #2,D7
  beq.s    azx3
  move     zx1234+4(pc),zx3-zx1(A2)
azx3:
  btst     #3,D7
  beq.s    azx4
  move     zx1234+4(pc),zx4-zx1(A2)
azx4:
  adda     D1,A1            ;;deb ligne dest
  move.w   D3,10(A6)
  move     D4,8(A6)
debzpag1:
  move.w   D2,D3
debz1lign:
  movem    (A0)+,D4-D7
  move     D4,D0           ;
zx1:
  not      D0
  move     D5,D1           ;
zx2:
  not      D1
  or       D1,D0
  move     D6,D1           ;
zx3:
  not      D1
  or       D1,D0
  move     D7,D1           ;
zx4:
  not      D1
  or       D1,D0

  and      D0,D4
  and      D0,D5
  and      D0,D6
  and      D0,D7
  not      D0
  and      D0,(A1)
  or       D4,(A1)+
  and      D0,(A1)
  or       D5,(A1)+
  and      D0,(A1)
  or       D6,(A1)+
  and      D0,(A1)
  or       D7,(A1)+
debz2lign:
  dbf      D3,debz1lign
  adda     8(A6),A1
  subq     #1,10(A6)
  bge      debzpag1
  bra      xfinx
;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;       nouvelle interruption clavier
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 0 <=> bouton ;; 1 <=> x ;; 2 <=> y ;; 3 <=> clavier ;; 4 <=> joystick ;;
;;; 5 <=> var de positionnement

;;;;;;;;;;;;;;;;;;;;
;;;
;;;  interruption 68901
;;;
;;;;;;;;;;;;;;;;;;;;

;;;; D0 numero d'interruption ;;;;
;;;; D1: 1 <=> active, 0 <=> desactive ;;;;

         IF FALCON = 0
Mfp_act:
    move.l  A0,-(A7)
    lea     $fffffa03.w,A0  ; registre B
    cmpi.w  #7,D0
    ble     suit_Jen
    lea     -2(A0),A0    ; si interupt>=8 registre A
    subi.w  #8,D0
suit_Jen:
    tst.w   D1
    bne     desact
    bclr    D0,18(A0)
    bclr    D0,6(A0)
    bclr    D0,10(A0)
    bclr    D0,14(A0)
    bra.s   fin_Jen
desact:
    bset    D0,6(A0)
    bset    D0,18(A0)
fin_Jen:
    move.l  (A7)+,A0
    rts
         ELSE
Mfp_act:
        tst      D1
        bne.s    Mfp0
        move     D0,-(A7)
        move     #$1a,-(A7)
        trap     #14
        addq     #4,A7
        rts
Mfp0:   move     D0,-(A7)
        move     #$1b,-(A7)
        trap     #14
        addq     #4,A7
        rts
         ENDIF
DELBONH:       EQU 5                 ;; delai en 1/50 entre deux dep
VITBONH:       EQU 1                 ;; vitesse bonhommes
TAILZON:       EQU 40                ;; buffer pour un bonhomme

maskprim:
              movem.l  D0-D1/A0-A2,-(A7)
              move.l   admask(PC),A0
              lea      8000(A0),A0
              move.l   A0,A2
              move.l   bufmask(PC),A1
              move     #162,D0
mask1prim:    moveq    #9,D1
mask2prim:    move.l   (A0)+,(A1)+
              dbf      D1,mask2prim
              move.l   A2,A0
              dbf      D0,mask1prim
              movem.l  (A7)+,D0-D1/A0-A2
              rts
copmask:
              movem.l  D0-D1/A0-A2,-(A7)
              move.l   admask(PC),A0
              lea      12*40(A0),A0
              move.l   bufmask(PC),A1
              move     #162,D0
cop1mask:     moveq    #9,D1
cop2mask:     move.l   (A1)+,(A0)+
              dbf      D1,cop2mask
              dbf      D0,cop1mask
              movem.l  (A7)+,D0-D1/A0-A2
              rts
creemask:
              movem.l  A0/A1/D0/D1,-(A7)
              move.l   admask(PC),A1
              move.w   #109,D0          ;barre du haut sur 11 lignes
cremsk:       clr.l    (A1)+
              dbf      D0,cremsk
              move.l   admask(PC),A1
              adda     #6960,A1         ;barre du bas en 175
              move.w   #259,D0          ;barre du bas sur 24 lignes
cremsk1:      clr.l    (A1)+
              dbf      D0,cremsk1
              move.l   admask(PC),A1    ;modele mask centre en ligne 200
              adda     #8000,A1
              lea      modelmsk(PC),A0
              move.l   (A0)+,(A1)+
              move.l   (A0),(A1)+
              move.l   (A0),(A1)+
              move.l   (A0),(A1)+
              move.l   (A0),(A1)+
              move.l   (A0),(A1)+
              move.l   (A0),(A1)+
              move.l   (A0)+,(A1)+
              move.l   (A0)+,(A1)+
              move.l   (A0),(A1)+
              move.l   A1,A0
              move.l   admask(PC),A1    ;mask centre en ligne 12 
              adda     #480,A1
              move.w   #162,D1          ;sur 163 lignes
cremsk3:      lea      -40(A0),A0
              moveq    #9,D0
cremsk2:      move.l   (A0)+,(A1)+
              dbf      D0,cremsk2
              dbf      D1,cremsk3
              movem.l  (A7)+,A0/A1/D0/D1
              rts
modelmsk:
        dc.l  $0fffffff,$ffffffff,$f0000000,$0
flgmask:
        dc.w    0
bufmask:
        dc.l    0
COORDMOUS:
              movem.l  D0-D1/A0,-(A7)
              move.l   tab_clav(PC),A0
              movem    2(A0),D0/D1
              add      deltaxy(PC),D0
              add      deltaxy+2(PC),D1
              movem    D0/D1,-4(A0)
              movem.l  (A7)+,D0-D1/A0
              rts
CHNGMOUSE:
              move.w   10(A7),numani
              move.w   6(A7),delai
              movem.l  D0-D7/A0-A5,-(A7)
              move.w   numani(PC),D0
              add.w    D0,D0
              move     D0,D1
              add      D1,D1
              lea      coordsour(PC),A0
              move.l   0(A0,D1.W),deltaxy
              lea      numlist(PC),A0
              move.w   0(A0,D0.W),D0
              add.w    D0,D0
              lea      listsour(PC),A0
              lea      0(A0,D0.W),A0
              clr.w    num_sprt
              clr.w    curdel
              move.l   A0,adr_lst
              movem.l  (A7)+,D0-D7/A0-A5
              move.l   (A7),8(A7)
              lea      8(A7),A7
              rts
SHOWMOUF:
              move     flag_mous,NOMHIDE
              clr      flag_mous
attshof:      tst.w    flag1mous
              beq.s    attshof
              rts

HIDEMOUF:
              move     NOMHIDE,flag_mous
              tst      flag_mous
              beq.s    nonhidf
atthidf:      tst.w    flag1mous
              bne.s    atthidf
nonhidf:      rts
NOMHIDE:      DC.W    0
SHOWMOUSE:
              tst.w    flag_mous
              beq.s    finshow
              addq.w   #1,flag_mous
              blt.s    finshow
attshow:      tst.w    flag1mous
              beq.s    attshow
finshow:      rts

HIDEMOUSE:
finhide:      subq.w   #1,flag_mous
atthide:      tst.w    flag1mous
              bne.s    atthide
              rts  

tabdemo:        equ   524500
INITDEMO:
              cmpi.l   #$00010001,$c6.w
              beq.s    demposs
xnod:         move.w   #1,$d0.w
              clr.w    $d2.w
              bra      xnodemo
demposs:      tst.b    $ce.w           ;demomode
              beq.s    xnod
              cmp.l    #$10000,$d0.w
              beq.s    xnod
              move     #1,$d2.w 
              tst      $d0.w
              bne.s    xsuidemo
              move.w   #1,$d0.w        ;charge
*        move.l  #tabdemo+1000,-(sp)
*        move.l  #tabdemo,-(sp)
*        move.l  #0,-(sp)     
*        move.l  #24,-(sp)     
*        jsr     LOADOBJT
         
        MOVEQ   #79,D0                  ;PISTE EN SECTEURS ET NON COMPRESSE
        MOVEQ   #1,D1
        MOVEQ   #2,D2
        JSR     READ
        move.l  tab_clav(pc),a1
        clr.b   28(a1)
        MOVE.L  #tabdemo,A1
        MOVE.L  BUFPIST(PC),A0
        MOVE    #249,D0
TRDEM:  MOVE.L  (A0)+,(A1)+
        DBF     D0,TRDEM                ;Fin transfert fichier demo

xsuidemo:     clr      D0
              move.b   tabdemo,D0
              mulu     #50,D0
              move     D0,timedemo
              move.l   #tabdemo,curdemo
              move     #1,flagdemo
              clr      waitdemo
xnodemo:      rts
adrte:        rte
EXITMOUSE:
              ori      #$2700,SR
              moveq    #8,D0
              moveq    #0,D1
              bsr      Mfp_act
              move.l   #adrte,$120
              move.l   oldtimerD(pc),$120
              move.l   oldvbl+2(pc),$70
              move.l   oldclav(pc),$118
              andi     #$2300,SR

              move.l   basemem(pc),-(A7)
              move.w   #$49,-(a7)
              trap     #1
              addq     #6,a7

              rts
savevecteurs:
              move.l   $120,oldtimerD
              move.l   $70,oldvbl+2
              move.l   $118,oldclav
              rts
oldclav:      dc.l     0
oldtimerD:    dc.l     0
INITMOUSE:
              MOVE.L   #FONT7,adpolice
              MOVE.L   #ALERTE,D0
;              JSR      INDISK
              move.l   #BASLOAD-20000,D0    ;version systeme
              MOVE.L   D0,abalert
              MOVE.L   D0,BUFPIST
              move.l   24(A7),adr_lst
              move.l   20(A7),admask
              move.l   16(A7),ad1cran
              move.l   16(A7),adphys
              move.l   12(A7),ecrbuf
              move.l   8(A7),adr_sprt
              move.l   4(A7),tab_clav
              move.l   4(A7),A1
              moveq    #27,D0
clrtbclv:     clr.b    (A1)+
              dbf      D0,clrtbclv
              MOVE.B   #-1,(A1)
              or       #$2700,sr
              bsr      savevecteurs
              bsr      demini           ;VERSION SYSTEME
              move.w   #100,LIGHBL
              move.w   #198,LIGVBL
              jsr      COUPSON  
              move.l   adr_sprt,A1      ;ad data 5 plans
              move.l   #norm2sour,D7    ;;;;;;; cree souris ;;;;;;
              move.l   #norm1sour,A2
              sub.l    A2,D7
              lsr      #1,D7
              subq     #1,D7
inm1:         move.l   adr_lst(PC),A0   ;page ecran
              move.w   (A2)+,D0
              moveq    #15,D1           ;hauteur souris
              bsr      creemous
              dbf      D7,inm1
              bsr      creemask
              clr.l    -(A7)            ;;numero d'animation
              move.l   #50,-(A7)
              bsr      CHNGMOUSE
              btst     #1,$ffff820a.w
              bne.s    hrz50
              move.w   #120,hrz5060
hrz50:        
              move.w   #-1,flag_mous

              move.l   #int_hbl,$120.w       ;posit vecteur hbl
              clr.w    fltimb
              clr.b    $fffffa1b.w
              move.b   LIGHBL+1,$fffffa21.w  ;reg donnee init hbl
              move.b   #16+8,$fffffa1b.w     ;reg control compte d'events
              moveq    #8,D0
              moveq    #1,D1
              bsr      Mfp_act
              
              lea      num_sprt(PC),A0
              clr.w    (A0)
              move.w   2(A0),4(A0)

;              tst.w    $d2.w            ;demomode
;              beq.s    nodemo1
;              move.l   #nodemo,$118.w
nodemo1:
              and.w     #$f3ff,sr
              move.l   (A7),24(A7)
              lea      24(A7),A7
              rts
         IF FALCON = 0
new_clav:     move.w   D0,-(A7)
new1clav:     move.b   $fffffc00.w,D0
              btst     #7,D0
              beq      new3clav
              btst     #0,D0
              beq      new2clav
movclav:      move.b   $fffffc02.w,DUMCLAV
              addq     #1,movclav+6
              bclr     #6,movclav+7
              addq     #1,cmptclav
              btst     #4,$fffffa01.w
              beq      new1clav
              move.w   (A7)+,D0
nodemo:       rte
new2clav:     and.b    #$20,D0
              beq.s    new3clav
              move.b   $fffffc02.w,D0
new3clav:     btst     #4,$fffffa01.w
              beq      new1clav
              move.w   (A7)+,D0
              rte
         ELSE
new_clav:     movem.l   D0/A0,-(A7)
new1clav:     move.b   $fffffc00.w,D0
              btst     #7,D0
              beq      new3clav
              btst     #0,D0
              beq      new2clav
              MOVE.L   movclav(PC),A0
              move.b   $fffffc02.w,(A0)
              addq     #1,movclav+2
              bclr     #6,movclav+3
              addq     #1,cmptclav
              btst     #4,$fffffa01.w
              beq      new1clav
              movem.l  (A7)+,D0/A0
nodemo:       rte
new2clav:     and.b    #$20,D0
              beq.s    new3clav
              move.b   $fffffc02.w,D0
new3clav:     btst     #4,$fffffa01.w
              beq      new1clav
              movem.l  (A7)+,D0/A0
              rte
movclav:      dc.l     DUMCLAV
recclav:      dc.l     DUMCLAV
         ENDIF
flgclav:      dc.w     0
cmptclav:     dc.w     0
              blk.w     64,0
DUMCLAV:      blk.w     40,0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; nouvelle routine souris en vbl
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cache:
              move.w   old_pos(PC),D0        ;;restaure sous le curseur
              move.w   old_pos+2(PC),D1
              move.l   ad1cran(PC),A1
              move.l   ecrbuf(PC),A0
              move.w   #199,D2
              sub.w    D1,D2
              cmpi.w   #15,D2
              blt.s    cache1
              moveq    #15,D2
cache1:       bsr      restsour
              rts
montre:
              move.l   tab_clav(PC),A0
              lea      old_pos(PC),A1
              move.l   2(A0),(A1)
              move.l   ad1cran(PC),A1
              move.l   adr_lst(PC),A1         ;;cherche pour affichage
              lea      num_sprt(PC),A0
              move.w   (A0),D0
              add.w    D0,D0
              subq.w   #1,curdel-num_sprt(A0)
              bgt.s    vbl1
              move.w   delai(PC),curdel-num_sprt(A0)
              add.w    #1,(A0)
vbl2:         tst.w    2(A1,D0.W)
              bge.s    vbl1
              clr.w    (A0)
vbl1:         move.w   0(A1,D0.W),D1
              move.l   adr_sprt(PC),A0
              add      D1,A0
              move.l   ad1cran(PC),A1
              move.w   old_pos(PC),D0
              move.w   old_pos+2(PC),D1
              move.w   #199,D7
              sub.w    D1,D7
              cmpi.w   #15,D7
              blt.s    montre1
              moveq    #15,D7
montre1:      clr.w    D2
              bsr      affisour
              rts
nbdyne:
        dc.w  0
nbdyn1:
        dc.w  0
tabdyn:
        blk.b  20,0      ;5 objets max

;;;; Attente de deux  vbl ;;;;

VBLSYNC:      move.l  cmptvbl(PC),D0
              add.l   4(A7),D0
vbl1sync:     cmp.l   cmptvbl(PC),D0
              bge.s   vbl1sync
              move.l  (A7),4(A7)
              lea     4(A7),A7
              rts
LIGVBL:
              dc.w    0
LIGHBL:
              dc.w    0
BUFHBL:
              dc.w    0
cmptvbl:
              dc.l    0
BUFBOUT:     dc.w    0
new_vbl:
              tst     flagvbl
              bne     oldvbl
con_vbl:
;              clr     $d2.w          ;pour pas de demo avec systeme
;              addq.l  #1,$462.w
;              addq.l  #1,$466.w
;              addq.l  #1,$4ba.w
              move    #1,flagvbl
;              addq.l  #1,$ca.w
              movem.l D0-D1/A0,-(A7)
              tst.w   fltimb
              bne.s   mumort
              or.w    #$700,sr
              clr.b   $fffffa1b.w
              move.b  LIGHBL+1,$fffffa21.w
              move.b  #16+8,$fffffa1b.w
              and.w   #$f5ff,sr
mumort:       addq.l  #1,cmptvbl       ; compteur vbl pour VBLSYNC
              move.l  tab_clav(PC),A0
              subq.w  #1,24(A0)
              bge.s   pasheure
              addq.w  #2,22(A0)
              move.w  hrz5060(PC),24(A0)
pasheure:
;              tst.w    $d2.w            ;demomode
;              bne      okdemo           ;demo si != 0
vblclav:      tst      cmptclav
              beq      fin1clav
         IF FALCON = 0
              move.l   tab_clav(PC),A0
debclav:      clr.w    D0
recclav:      move.b   DUMCLAV,D0
              addq     #1,recclav+4
              bclr     #6,recclav+5
         ELSE
debclav:      clr.w    D0
              MOVE.L   recclav(PC),A0
              move.b   (A0),D0
              addq     #1,recclav+2
              bclr     #6,recclav+3
              move.l   tab_clav(PC),A0
         ENDIF
              tst.w    10(A0)
              beq      headclav        ;; autrement octet de donnee
              cmpi.w   #1,10(A0)
              bne.s    clav2
              addq.w   #1,10(A0)
              ext.w    D0
              add.w    D0,2(A0)
              move.w   2(A0),D0
              cmp.w    12(A0),D0
              bge      xsup
              move.w   12(A0),2(A0)
              bra      finclav
xsup:         cmp.w    12+4(A0),D0
              ble      finclav
              move.w   12+4(A0),2(A0)
              bra      finclav
clav2:        cmpi.w   #2,10(A0)
              bne.s    clav3
              clr.w    10(A0)
              ext.w    D0
              add.w    D0,4(A0)
              move.w   4(A0),D0
              cmp.w    12+2(A0),D0
              bge      ysup
              move.w   12+2(A0),4(A0)
              bra      finclav
ysup:         cmp.w    12+6(A0),D0
              ble      finclav
              move.w   12+6(A0),4(A0)
              bra      finclav
clav3:        move     d0,8(a0)
              clr      10(a0)
              bra      finclav
headclav:     cmpi.w   #$f8,d0
              blt.s    clav01
              btst     #2,d0
              beq.s    clav02
              move     #4,10(a0)        ;; info joystick
              bra      finclav
clav02:       move     #1,10(a0)        ;; header souris et bouton
boutgauch:    btst     #1,D0            ;; bouton gauche
              bne.s    boutgau1
              bclr     #0,BUFBOUT+1
              bclr     #0,1(A0)
              bra.s    boutdroit
boutgau1:     btst     #0,BUFBOUT+1
              bne.s    boutdroit
              bset     #0,BUFBOUT+1
              bset     #0,1(A0)
boutdroit:    btst     #0,D0            ;; bouton droit
              bne.s    boutdroi1
              bclr     #1,BUFBOUT+1
              bclr     #1,1(A0)
              bra.s    finclav
boutdroi1:    btst     #1,BUFBOUT+1
              bne.s    finclav
              bset     #1,BUFBOUT+1
              bset     #1,1(A0)
              bra      finclav
clav01:       move.w   D0,6(A0)         ;; code clavier
              cmpi.w   #$3B,D0          ;  < F1 >
              bne.s    clavF5
              not.b    26(A0)
              bra.s    finclav
clavF5:       cmpi.w   #$3F,D0          ;  < F5 >
              bne.s    clavF10
              not.b    27(A0)
              bra.s    finclav
clavF10:      cmpi.w   #$44,D0          ; < F10 >
              bne.s    clavalt
              not.b    28(A0)
              bra.s    finclav
clavalt:      cmpi.w   #$38,D0
              bne.s    clavspace
              move.b   #1,$ce.w         ; <ALT> 
              bra.s    finclav
clavspace:    cmpi      #$39,D0
              bne.s    finclav
              move.b   #1,$cf.w         ; <space>
              bra.s    finclav
clav4:        move.w   #4,10(A0)
finclav:      subq     #1,cmptclav
              bne      debclav
fin1clav:
              jsr      VBLBJL
        IF  FALCON = 0
; test lumiere lecteur

        tst.w   $3a.w
        beq.s   noflop
        blt.s   dsflop
        subq.w  #1,deflop
        bge.s   noflop
        move.w  sr,-(a7)
        or.w    #$700,sr
        move.b  #$e,$ffff8800.w
        move.b  $ffff8802.w,d0
        or.b    #7,d0
        move.b  d0,$ffff8802.w
        clr.w   $3a.w
        move.w  (a7)+,sr
        bra.s   noflop
dsflop: move.w  #50*3,deflop
        neg.w   $3a.w 
        ENDIF
noflop:       movem.l  (A7)+,D0-D1/A0
              clr      flagvbl
oldvbl:       jmp      vbl_rte
vbl_rte:      rte
deflop: dc.w    0
okdemo:
              tst      flagdemo
              beq.s    fin1clav
              move.l   A1,-(A7)
              move.l   curdemo(PC),A0
              move.l   tab_clav(PC),A1
              tst      waitdemo
              bne      ok1demo
              subq     #1,timedemo
              bgt.s    findemo
              move.b   1(A0),1(A1)      ;bouton
              move     #1,waitdemo
              move     #48,timedemo
              bra      findemo
ok1demo:
              subq     #1,timedemo
              bgt.s    findemo
              move.l   2(A0),2(A1)      ;xmouse,ymouse
              addq     #6,A0
              clr      D0
              move.b   (A0),D0
              mulu     #50,D0
              move     D0,timedemo
              clr      waitdemo
              move.l   A0,curdemo
findemo:
              move.l   (A7)+,A1
              bra      fin1clav
waitdemo:
              dc.w     0
flagdemo:
              dc.w     0
curdemo:
              dc.l     524500
timedemo:
              dc.w     0
flagvbl:      dc.w     0
flg1hbl:      dc.w     0
flg2hbl:      dc.w     0
hrz5060:      dc.w     100
int_hbl:
            tst     flg1hbl
            beq.s   ok1hbl
            rte
ok1hbl:     not     flg1hbl
            clr.b   $fffffa1b.w
            move.l  #int_vbl,$120.w
            movem.l D0-D7/A0-A6,-(A7)
            move.w  LIGVBL,D0
            sub.w   LIGHBL,D0
            move.b  D0,$fffffa21.w
            move.b  #16+8,$fffffa1b.w
            andi.w  #$2300,SR
            bsr     execani
            movem.l (A7)+,D0-D7/A0-A6
            clr     flg1hbl
            rte
;;;;;;;;; HBL pour souris bonhommes etc... ;;;;;;;;;;;;
int_vbl:
            tst     flg2hbl
            beq.s   ok2hbl
            rte
ok2hbl:     not     flg2hbl
            clr.b   $fffffa1b.w
            andi.w  #$2300,SR
            move.l  #int_hbl,$120.w
            movem.l D0-D7/A0-A6,-(A7)
            tst.w   flag1mous
            beq.s   vbldyne
            bsr     cache
            not.w   flag1mous
vbldyne:
            move.w  nbdyne(PC),nbdyn1
vbldyn:     sub.w   #4,nbdyn1
            blt.s   vbldyn1
            lea     tabdyn(PC),A1
            add.w   nbdyn1(PC),A1
            move.l  (A1),A0
            movem.w 34(A0),D0/D1/D2
            tst.w   D0
            blt.s   vbldyn
            move.l  ecrbuf(PC),A0
            move.l  adphys(PC),A1
            bsr     restsour
            bra.s   vbldyn
vbldyn1:
vbldyn2:
            subq.w  #4,nbdyne
            blt.s   vbldyn3
            lea     tabdyn(PC),A1
            add.w   nbdyne(PC),A1
            move.l  (A1),A0
            move.l  30(A0),A1            ;sequence + appel son
            move.w  (A1)+,D2
            move.w  (A1),D0
            beq.s   vbldyn4
            bsr     exebruit
vbldyn4:
            movem.w 4(A0),D0/D1/D7
            tst     D0
            blt.s   vbldyn2
            move.l  4(A0),34(A0)
            move.l  48(A0),A0
            move.l  adphys(PC),A1
            bsr     affi1616
            bra.s   vbldyn2
vbldyn3:
            tst.w   flag_mous
            bne.s   termvbl
            not.w   flag1mous
            bsr     montre
termvbl:
            movem.l (A7)+,D0-D7/A0-A6
            clr     flg2hbl
            rte 
; restaure sous la souris: x=D0, y=D1, D2=hauteur, A0=adrsauv, A1=adr_ecran
restsour:        
           tst.w       D1
           bge.s       pclre
           add         D1,D2
           clr.w       D1
pclre:
           mulu        #160,D1
           lsr.w       #1,D0
           andi.w      #-8,D0
           add.w       D0,D1
           adda.w      D1,A1
           adda.w      D1,A0
debrest:
           move.l      (A0)+,(A1)+
           move.l      (A0)+,(A1)+
           move.l      (A0)+,(A1)+
           move.l      (A0)+,(A1)+
           lea         144(A1),A1
           lea         144(A0),A0
           dbf         D2,debrest
           rts

; x=D0, y=D1, D7=nombre de lignes, A0=adr_souris, A1=adr_ecran
; D2 adresse du sprite dans la page ecran

affimask:
  adda.w  D2,A0
  mulu    #160,D1
  move.w  D0,D2
  lsr.w   #1,D0
  andi.w  #-8,D0
  add.w   D0,D1
  adda.w  D1,A1
  move.l  admask(pc),A2     ;adresse masque
  lsr.w   #2,D1         ;    '
  adda    D1,A2         ;    '
  andi.w  #15,D2
  beq     blkmask
  cmpi.w  #8,D2
  bge     righmask
leftmask:
  move.w  D7,D0
deblmask:
  moveq   #0,D1
  moveq   #0,D3
  moveq   #0,D4
  moveq   #0,D5
  moveq   #0,D6
  move.w  (A0)+,D1
  move.w  (A0)+,D3
  move.w  (A0)+,D4
  move.w  (A0)+,D5
  move.w  (A0)+,D6
  ror.l   D2,D1
  ror.l   D2,D3
  ror.l   D2,D4
  ror.l   D2,D5
  ror.l   D2,D6
  not.l   D6
  and.w   D6,(A2)+
  and.w   D6,(A1)
  or.w    D1,(A1)+
  and.w   D6,(A1)
  or.w    D3,(A1)+
  and.w   D6,(A1)
  or.w    D4,(A1)+
  and.w   D6,(A1)
  or.w    D5,(A1)+
  swap    D1
  swap    D3
  swap    D4
  swap    D5
  swap    D6
  and.w   D6,(A2)+      ;     '
  and.w   D6,(A1)
  or.w    D1,(A1)+
  and.w   D6,(A1)
  or.w    D3,(A1)+
  and.w   D6,(A1)
  or.w    D4,(A1)+
  and.w   D6,(A1)
  or.w    D5,(A1)+
  lea     36(A2),A2     ;     '
  lea     144(A1),A1
  dbf     D0,deblmask
  rts
righmask:
  subi.w  #16,D2
  neg.w   D2
  move.w  D7,D0
debrmask:
  moveq   #0,D1
  moveq   #0,D3
  moveq   #0,D4
  moveq   #0,D5
  moveq   #0,D6
  move.w  (A0)+,D1
  move.w  (A0)+,D3
  move.w  (A0)+,D4
  move.w  (A0)+,D5
  move.w  (A0)+,D6
  lsl.l   D2,D1
  lsl.l   D2,D3
  lsl.l   D2,D4
  lsl.l   D2,D5
  lsl.l   D2,D6
  swap    D1
  swap    D3
  swap    D4
  swap    D5
  swap    D6
  not.l   D6
  and.w   D6,(A2)+
  and.w   D6,(A1)
  or.w    D1,(A1)+
  and.w   D6,(A1)
  or.w    D3,(A1)+
  and.w   D6,(A1)
  or.w    D4,(A1)+
  and.w   D6,(A1)
  or.w    D5,(A1)+
  swap    D1
  swap    D3
  swap    D4
  swap    D5
  swap    D6
  and.w   D6,(A2)+      ;    '
  and.w   D6,(A1)
  or.w    D1,(A1)+
  and.w   D6,(A1)
  or.w    D3,(A1)+
  and.w   D6,(A1)
  or.w    D4,(A1)+
  and.w   D6,(A1)
  or.w    D5,(A1)+
  lea     36(A2),A2     ;    '
  lea     144(A1),A1
  dbf     D0,debrmask
  rts
blkmask:
  move.w  D7,D0
debblkm:
  move.l  (A0)+,D1
  move.l  (A0)+,D3
  move.w  (A0)+,D5
  move    D5,D4
  swap    D4
  move    D5,D4
  not.l   D4
  and.w   D4,(A2)+      ;     '
  and.l   D4,(A1)
  or.l    D1,(A1)+
  and.l   D4,(A1)
  or.l    D3,(A1)+
  lea     38(A2),A2     ;     '
  lea     152(A1),A1
  dbf     D0,debblkm
  rts
affi1616:
  adda    D2,A0
  mulu    #160,D1
  move.w  D0,D2
  lsr.w   #1,D0
  andi.w  #-8,D0
  add.w   D0,D1
  adda.w  D1,A1
  move.l  admask(pc),A2     ;;;;;;;;;;;;;;;;;
  lsr.w   #2,D1         ;;;;;;;;;;;;;;;;;
  adda    D1,A2         ;;;;;;;;;;;;;;;;;
  andi.w  #15,D2
  beq     blk1616
  cmpi.w  #8,D2
  bge     righ1616
left1616:
  move.w  D7,D0
debl1616:
  moveq   #0,D1
  moveq   #0,D3
  moveq   #0,D4
  moveq   #0,D5
  moveq   #0,D6
  move.w  (A0)+,D1
  move.w  (A0)+,D3
  move.w  (A0)+,D4
  move.w  (A0)+,D5
  move.w  (A0)+,D6
  ror.l   D2,D1
  ror.l   D2,D3
  ror.l   D2,D4
  ror.l   D2,D5
  ror.l   D2,D6
  swap    D6
  and.l   (A2)+,D6      ;;;;;;;;;;;;;;;;;;
  swap    D6
  and.l   D6,D1
  and.l   D6,D3
  and.l   D6,D4
  and.l   D6,D5
  not.l   D6
  and.w   D6,(A1)
  or.w    D1,(A1)+
  and.w   D6,(A1)
  or.w    D3,(A1)+
  and.w   D6,(A1)
  or.w    D4,(A1)+
  and.w   D6,(A1)
  or.w    D5,(A1)+
  swap    D1
  swap    D3
  swap    D4
  swap    D5
  swap    D6
  and.w   D6,(A1)
  or.w    D1,(A1)+
  and.w   D6,(A1)
  or.w    D3,(A1)+
  and.w   D6,(A1)
  or.w    D4,(A1)+
  and.w   D6,(A1)
  or.w    D5,(A1)+
  lea     36(A2),A2             ;;;;;;;;;;;;;;;;;;
  lea     144(A1),A1
  dbf     D0,debl1616
  rts
righ1616:
  subi.w  #16,D2
  neg.w   D2
  move.w  D7,D0
  addq    #8,A1
debr1616:
  moveq   #0,D1
  moveq   #0,D3
  moveq   #0,D4
  moveq   #0,D5
  moveq   #0,D6
  move.w  (A0)+,D1
  move.w  (A0)+,D3
  move.w  (A0)+,D4
  move.w  (A0)+,D5
  move.w  (A0)+,D6
  lsl.l   D2,D1
  lsl.l   D2,D3
  lsl.l   D2,D4
  lsl.l   D2,D5
  lsl.l   D2,D6
  and.l   (A2)+,D6      ;;;;;;;;;;;;;;;;;;
  and.l   D6,D1
  and.l   D6,D3
  and.l   D6,D4
  and.l   D6,D5
  not.l   D6
  and.w   D6,(A1)
  or.w    D1,(A1)+
  and.w   D6,(A1)
  or.w    D3,(A1)+
  and.w   D6,(A1)
  or.w    D4,(A1)+
  and.w   D6,(A1)
  or.w    D5,(A1)+
  swap    D1
  swap    D3
  swap    D4
  swap    D5
  swap    D6
  lea     -16(A1),A1
  and.w   D6,(A1)
  or.w    D1,(A1)+
  and.w   D6,(A1)
  or.w    D3,(A1)+
  and.w   D6,(A1)
  or.w    D4,(A1)+
  and.w   D6,(A1)
  or.w    D5,(A1)+
  lea     36(A2),A2             ;;;;;;;;;;;;;;;;;;
  lea     160(A1),A1
  dbf     D0,debr1616
  rts
blk1616:
  move.w  D7,D0
debb1616:
  move.l  (A0)+,D1
  move.l  (A0)+,D3
  move.w  (A0)+,D5
  move.w  D5,D4
  swap    D4
  move.w  D5,D4
  move.w  (A2),D5
  swap    D5
  move.w  (A2)+,D5
  and.l   D5,D4
  and.l   D4,D1
  and.l   D4,D3
  not.l   D4
  and.l   D4,(A1)
  or.l    D1,(A1)+
  and.l   D4,(A1)
  or.l    D3,(A1)+
  lea     38(A2),A2
  lea     152(A1),A1
  dbf     D0,debb1616
  rts
affisour:
  tst.w   D1
  bge.s   pclaf
  add     D1,D7
  neg     D1
  mulu    #10,D1
  adda    D1,A0
  clr.w   D1
pclaf:
  adda.w  D2,A0
  mulu    #160,D1
  move.w  D0,D2
  lsr.w   #1,D0
  andi.w  #-8,D0
  add.w   D0,D1
  adda.w  D1,A1
  andi.w  #15,D2
  beq     blksour
  cmpi.w  #8,D2
  bge     righsour
leftsour:
  move.w  D7,D0
debleft:
  moveq   #0,D1
  moveq   #0,D3
  moveq   #0,D4
  moveq   #0,D5
  moveq   #0,D6
  move.w (A0)+,D1
  move.w (A0)+,D3
  move.w (A0)+,D4
  move.w (A0)+,D5
  move.w (A0)+,D6
  ror.l   D2,D1
  ror.l   D2,D3
  ror.l   D2,D4
  ror.l   D2,D5
  ror.l   D2,D6
  not.l   D6
  and.w   D6,(A1)
  or.w    D1,(A1)+
  and.w   D6,(A1)
  or.w    D3,(A1)+
  and.w   D6,(A1)
  or.w    D4,(A1)+
  and.w   D6,(A1)
  or.w    D5,(A1)+
  swap    D1
  swap    D3
  swap    D4
  swap    D5
  swap    D6
  and.w   D6,(A1)
  or.w    D1,(A1)+
  and.w   D6,(A1)
  or.w    D3,(A1)+
  and.w   D6,(A1)
  or.w    D4,(A1)+
  and.w   D6,(A1)
  or.w    D5,(A1)+
  lea     144(A1),A1
  dbf     D0,debleft
  rts
righsour:
  subi.w  #16,D2
  neg.w   D2
  move.w  D7,D0
  addq    #8,A1
debright:
  moveq   #0,D1
  moveq   #0,D3
  moveq   #0,D4
  moveq   #0,D5
  moveq   #0,D6
  move.w  (A0)+,D1
  move.w  (A0)+,D3
  move.w  (A0)+,D4
  move.w  (A0)+,D5
  move.w  (A0)+,D6
  lsl.l   D2,D1
  lsl.l   D2,D3
  lsl.l   D2,D4
  lsl.l   D2,D5
  lsl.l   D2,D6
  not.l   D6
  and.w   D6,(A1)
  or.w    D1,(A1)+
  and.w   D6,(A1)
  or.w    D3,(A1)+
  and.w   D6,(A1)
  or.w    D4,(A1)+
  and.w   D6,(A1)
  or.w    D5,(A1)+
  swap    D1
  swap    D3
  swap    D4
  swap    D5
  swap    D6
  lea     -16(A1),A1
  and.w   D6,(A1)
  or.w    D1,(A1)+
  and.w   D6,(A1)
  or.w    D3,(A1)+
  and.w   D6,(A1)
  or.w    D4,(A1)+
  and.w   D6,(A1)
  or.w    D5,(A1)+
  lea     160(A1),A1
  dbf     D0,debright
  rts
blksour:
  move.w  D7,D0
debblk:
  move.l  (A0)+,D1
  move.l  (A0)+,D3
  move.w  (A0)+,D5
  move.w  D5,D4
  swap    D4
  move.w  D5,D4
  not.l   D4
  and.l   D4,(A1)
  or.l    D1,(A1)+
  and.l   D4,(A1)
  or.l    D3,(A1)+
  lea     152(A1),A1
  dbf     D0,debblk
  rts

creemous:
        adda    D0,A0
cremo1: 
        movem   (A0)+,D2-D5
        move    D2,D6
        or      D3,D6
        or      D4,D6
        not     D5
        or      D5,D6
        not     D5
        and     D6,D2
        and     D6,D3
        and     D6,D4
        and     D6,D5
        movem   D2-D6,(A1)
        lea     10(A1),A1
        lea     152(A0),A0
        dbf     D1,cremo1
        rts

RESETANI:
        rts
*        
*** lance toutes les animations valides ***
*
INITANI:
        move.l  A0,-(A7)
        move.l  adscript(pc),D0
        blt.s   init1ani
        move.l  D0,A0
        cmpi.l  #-1,(A0)
        beq.s   init1ani
        move.w  #-1,flgani
init1ani:
        move.l  (A7)+,A0
        rts
*
*** stoppe toutes les animations
*
EXITANI:
        clr.w   flgani
        rts
        EVEN
*
*** stoppe une animation
*
STOPANI:
        movem.l D1-D2/A0,-(A7)
        move    18(A7),D0
        move.l  tabchain(pc),A0
        add     D0,D0
        move.w  0(A0,D0.W),D2
        moveq   #15,D0
stop1an:
        subq    #1,D0
        blt.s   stop2an
        btst    D0,D2
        beq.s   stop1an
        move.l  adscript(pc),A0
        move    D0,D1
        lsl     #2,D1
        bset    #7,0(A0,D1.W)
        bra.s   stop1an
stop2an:
        movem.l (A7)+,D1-D2/A0
        move.l  (A7),4(A7)
        lea     4(A7),A7
        rts
*
*
*** modifie une sequence d'animation et la lance
*
;; D0 = numero objet composite, D1 = numero de sequence ;;
BLOCANI:
        MOVE.L  ecrbuf(pc),A0      ;RECOPIE ECRAN
        LEA     32000(A0),A0
        MOVE.L  A0,bufsup
        MOVE    #1,modeani
        BSR     HIDEMOUSE
        BRA.S   dochngani
CHNGANI:
        CLR     modeani
dochngani:
        movem.l D1-D5/A0-A3,-(A7) ;
        move    42(A7),D2
        move    46(A7),D1
        move    50(A7),D0
        move.l  tabchain(pc),A0
        add     D0,D0
        move.w  0(A0,D0.W),D3
        moveq   #15,D0
chng1an:
        subq    #1,D0
        blt.s   chng2an
        btst    D0,D3
        beq.s   chng1an
        movem.l D0-D3/A0,-(A7)
        move.l  adscript(pc),A1
        lsl     #2,D0
        lea     0(A1,D0.W),A1
        move.l  (A1),D0
        bclr    #31,D0
        move.l  D0,A0
        move.l  A1,-(A7)
        bsr     modifani
        move.l  (A7)+,A1
        bclr    #7,(A1)
        movem.l (A7)+,D0-D3/A0
        
        bra.s   chng1an
chng2an:
        tst     modeani    ;remis a zero par ani bloquante
        beq.s   chng3an
chng4an:
        tst     modeani
        bne.s   chng4an
chng5an:
        bsr     SHOWMOUSE
chng3an:
        movem.l (A7)+,D1-D5/A0-A3
        move.l  (A7),12(A7)
        lea     12(A7),A7
        rts
;; D0 = numero d'objet, D1 = numero de sequence ;;
;; D2 = mode si 0 nouvelle seq au debut, si 1 a partir objet en cours ;;
modifani:
        move    (A0),D0
        bne     ch5seq
        lea     40(A0),A1
        addq    #2,A0
        tst     D1
        beq.s   finchseq
        subq    #1,D1
debchseq:
        tst.l   (A1)
        lea     10(A1),A1
        blt.s   cherchseq
        bra.s   debchseq
cherchseq:
        dbf     D1,debchseq
        tst     D2
        beq.s   finchseq            ;si != 0 retire seq asynchrone
        lea     10(A1),A1           ;A0 adr zone trav obj, A1 pointe sur seq.
finchseq:                   
        move.l  A1,(A0)             ;ad 1ere sequence
        add.l   #10,(A0)+           ;repete a partir 2eme sequence
        move.l  A1,(A0)+            ;ad cur sequence
        tst     D2
        beq.s   ch1seq
        move.l  4(A0),A2
        tst     (A2)
        bgt.s   ch2seq
        move.l  (A0),4(A0)
        move.l  (A1)+,(A0)+
        addq    #4,A0
        bra.s   ch3seq
ch2seq:
        move.l  (A1)+,(A0)+
        addq    #4,A0
        bra.s   ch3seq
ch1seq:
        move.l  (A1),(A0)+          ;bloc
        move.l  (A1)+,(A0)+
ch3seq:
        move.w  (A1),(A0)+          ;vitesse
        move.w  (A1)+,(A0)+
        move.w  (A1),(A0)+          ;delai
        move.w  (A1)+,(A0)+
        move.w  (A1),(A0)+          ;repeat
        move.w  (A1)+,(A0)+
        bra     ch4seq
        rts                         ;anim mobile ou bloquante
ch5seq:
        cmpi    #16,D0
        beq     chspec
        lea     58(A0),A1
        addq    #2,A0
        tst     D1
        beq.s   finch1seq
        subq    #1,D1
debch1seq:
        tst.w   (A1)
        lea     18(A1),A1
        blt.s   cherch1seq
        bra.s   debch1seq
cherch1seq:
        dbf     D1,debch1seq        ;A0 adr zone trav obj, A1 pointe sur seq.
finch1seq:                  
        move.l  A1,40(A0)           ;ad 1ere sequence
        tst     D2
        bne.s   ch4seq
        move.l  A1,44(A0)
        move.w  (A1),(A0)          ;time
        move.w  (A1)+,2(A0)        ; ...
        move.l  30(A0),D0
        sub.l   26(A0),D0
        move.l  (A1)+,26(A0)
        move.l  (A1)+,30(A0)
        move.l  (A1)+,14(A0)
        move.w  (A1)+,12(A0)
        move.w  (A1)+,52(A0)
        move.w  (A1)+,54(A0)
ch4seq:
        rts
chspec:
        addq    #2,A0
        move    #-1,8(A0)       ;oldxy
        move    #-1,16(A0)
        lea     32(A0),A1
        move.l  A1,24(A0)
        move    (A1),22(A0)
        rts
modeani:    dc.w    0
adrload:    dc.l    0
bufload:    dc.l    0
num:        dc.w    0
bufdecomp:  dc.l    0
nboctet:    dc.l    0
BUFPIST:    DC.L    0

tabcod1:
   dc.b   0,76,5,1,19,18,14,9,21,20,15,12,84,4,3,77,16,13,8,22,2,101
   dc.b    6,7,67,94,83,88,85
tabcod2:
   dc.b   38,29,39,25,54,26,17,65,27,28,24,58,30,57,56,35,48,45,55
   dc.b   44,36,46,10,60,70,59,42,68,61,31
tabcod3:
   dc.b   82,82,32,41,47,11,89,62,40,53,23,87,33,49,43,93,91,92,73,34
   dc.b   96,63,66,71,86,37,51,78,79,72
   EVEN
FONT7:
   DC.W   $7000,$4E75,$0000,$0000
   DC.W   $0000,$0000,$0C00,$0024,$8D1E,$0F80,$0001,$0000,$0000,$4D61
   DC.W   $7570,$2020,$2020,$2020,$2020,$2020,$2020,$2020,$2020,$2020
   DC.W   $2020,$2020,$2020,$2020,$2020,$0000,$0000,$0000,$0000,$0C00
   DC.W   $0024,$8D1E,$0000,$0000,$0000,$0008,$0062,$0007,$0006,$0001
   DC.W   $0000,$0179,$0000,$006E,$0038,$0000,$022E,$0000,$0416,$0000
   DC.W   $050A,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   DC.W   $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0030,$0C03
   DC.W   $7062,$0D2C,$DC08,$6A05,$C260,$000B,$CA4C,$80C9,$13BC,$0400
   DC.W   $8304,$0118,$0000,$0008,$0000,$001E,$79FD,$F79E,$12FC,$7919
   DC.W   $6F37,$8DF9,$98C6,$3F70,$9CE1,$FC7F,$6749,$4204,$8A95,$B203
   DC.W   $2334,$AA06,$2291,$0016,$3F30,$1112,$2000,$E73B,$BCBC,$430E
   DC.W   $B9BC,$D6FF,$331D,$C7E9,$2612,$8A65,$2D44,$51BD,$94CA,$5359
   DC.W   $98A9,$5189,$A312,$4081,$98F3,$9C77,$73B8,$0CCC,$0009,$0404
   DC.W   $2509,$000A,$494C,$8383,$076C,$54C4,$CC4C,$012D,$6653,$3B09
   DC.W   $3352,$2829,$2612,$8221,$2444,$915B,$94CA,$5049,$9AB9,$C29A
   DC.W   $B294,$7902,$68A9,$4A89,$94CA,$5333,$3322,$000C,$450F,$FFE2
   DC.W   $294C,$9154,$CCDC,$94C4,$D64F,$43CD,$6653,$30C9,$3352,$10CF
   DC.W   $3A12,$E321,$E447,$1119,$974B,$8C49,$9A90,$84AE,$8425,$0644
   DC.W   $94CA,$528A,$A552,$5333,$3324,$8014,$8909,$0002,$2F4C,$A254
   DC.W   $CCCC,$94A4,$A43C,$C32C,$665D,$7029,$3552,$1109,$2612,$8225
   DC.W   $2444,$9119,$946A,$8249,$9AB8,$88C8,$889F,$8628,$914A,$5264
   DC.W   $4222,$5333,$3329,$4040,$0891,$01E2,$294C,$C254,$CCCC,$EF9F
   DC.W   $9C2C,$B32C,$6590,$F1C6,$F9AD,$93E9,$2512,$8A15,$2444,$9319
   DC.W   $945A,$5249,$AAA8,$9188,$9111,$4628,$9277,$BD13,$3199,$2CCC
   DC.W   $EEF0,$815C,$9060,$0002,$C94C,$C7AB,$3CCC,$0000,$0030,$0C00
   DC.W   $0000,$0000,$0000,$0010,$F8FD,$F40E,$1F88,$7D19,$683E,$6CEE
   DC.W   $CD44,$9F71,$FEE1,$79CC,$6C00,$0060,$0000,$0000,$0000,$00A0
   DC.W   $1000,$0002,$10B7,$3800,$0048,$0000,$0005,$0005,$0004,$0009
   DC.W   $0004,$000D,$0004,$0011,$0004,$0015,$0004,$0019,$0004,$001D
   DC.W   $0004,$0021,$0002,$0023,$0004,$0027,$0004,$002B,$0002,$002D
   DC.W   $0005,$0032,$0004,$0036,$0004,$003A,$0005,$003F,$0004,$0043
   DC.W   $0004,$0047,$0004,$004B,$0004,$004F,$0004,$0053,$0004,$0057
   DC.W   $0005,$005C,$0005,$0061,$0005,$0066,$0005,$006B,$0006,$0071
   DC.W   $0005,$0076,$0004,$007A,$0005,$007F,$0006,$0085,$0005,$008A
   DC.W   $0004,$008E,$0006,$0094,$0003,$0097,$0005,$009C,$0006,$00A2
   DC.W   $0005,$00A7,$0005,$00AC,$0004,$00B0,$0004,$00B4,$0005,$00B9
   DC.W   $0004,$00BD,$0006,$00C3,$0004,$00C7,$0005,$00CC,$0004,$00D0
   DC.W   $0004,$00D4,$0005,$00D9,$0005,$00DE,$0005,$00E3,$0005,$00E8
   DC.W   $0005,$00ED,$0005,$00F2,$0005,$00F7,$0005,$00FC,$0005,$0101
   DC.W   $0005,$0106,$0005,$010B,$0005,$0110,$0004,$0114,$0005,$0119
   DC.W   $0005,$011E,$0005,$0123,$0005,$0128,$0004,$012C,$0004,$0130
   DC.W   $0005,$0135,$0004,$0139,$0004,$013D,$0003,$0140,$0003,$0143
   DC.W   $0004,$0147,$0004,$014B,$0004,$014F,$0000,$014F,$0000,$014F
   DC.W   $0004,$0153,$0004,$0157,$0004,$015B,$0007,$0162,$0003,$0165
   DC.W   $0002,$0167,$0001,$0168,$0002,$016A,$0002,$016C,$0001,$016D
   DC.W   $0001,$016E,$0005,$0173,$0004,$0177,$0003,$017A,$0003,$017D
   DC.W   $0005,$0182,$0005,$0187,$0004,$018B,$0003,$018E,$0005,$0193
   DC.W   $0006,$0199,$0004,$019D,$0004,$01A1,$0000,$01A1,$0005,$01A6
   DC.W   $0005,$01AB,$0002,$01AD,$0004,$01B1,$0004,$01B5,$0004,$01B9
   DC.W   $0004,$01BD,$0001,$01BE,$0000,$01BE,$0000,$01BE,$0000,$01BE
   DC.W   $0000,$01BE,$0000,$01BE,$0000,$01BE,$0000,$01BE,$0000,$01BE
   DC.W   $0000,$01BE,$0000,$01BE,$0000,$01BE,$0000,$01BE,$0000,$0008
   DC.W   $0006,$0006,$0006,$0006,$0006,$0006,$0006,$0004,$0006,$0006
   DC.W   $0004,$0007,$0006,$0006,$0007,$0006,$0006,$0006,$0006,$0006
   DC.W   $0006,$0007,$0007,$0007,$0007,$0008,$0007,$0006,$0007,$0008
   DC.W   $0007,$0006,$0008,$0005,$0007,$0008,$0007,$0007,$0006,$0006
   DC.W   $0007,$0006,$0008,$0006,$0007,$0006,$0006,$0007,$0007,$0007
   DC.W   $0007,$0007,$0007,$0007,$0007,$0007,$0007,$0007,$0007,$0006
   DC.W   $0007,$0007,$0007,$0007,$0006,$0006,$0007,$0006,$0006,$0005
   DC.W   $0005,$0006,$0006,$0006,$0006,$0006,$0006,$0006,$0006,$0009
   DC.W   $0005,$0004,$0003,$0004,$0004,$0003,$0003,$0007,$0006,$0005
   DC.W   $0005,$0007,$0007,$0006,$0005,$0007,$0008,$0006,$0006,$0005
   DC.W   $0007,$0007,$0004,$0006,$0006,$0006,$0006,$0003,$0001,$0001
   DC.W   $0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001
   DC.W   $0004,$0001,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   DC.W   $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   DC.W   $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   DC.W   $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   DC.W   $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   DC.W   $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   DC.W   $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   DC.W   $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   DC.W   $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   DC.W   $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   DC.W   $0000,$FFFF,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   DC.W   $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
   DC.W   $0000,$0000,$0000,$0000,$0000,$03EC,$0000,$0006,$0000,$0000
   DC.W   $0000,$006A,$0000,$0066,$0000,$0062,$0000,$005C,$0000,$0044
   DC.W   $0000,$000E,$0000,$0000,$0000,$03F2
TLONG8:
   DC.W   $0017,$0003,$0003,$0027,$0003,$0005,$0007,$0002,$0002,$0002
   DC.W   $0002,$001B,$000A,$0007,$0020,$0020,$0020,$0016,$0017,$0003
   DC.W   $0014,$0006,$FFFF
TCOMP8:
   DC.W   $F064,$32DC,$5111,$9216,$E906,$1060,$32A4,$E209,$0689,$8AE3
   DC.W   $2B70,$20FA,$1460,$F8D0,$70F3,$CC4C,$145E,$2850,$6105,$A727
   DC.W   $8C81,$2522,$0B44,$120D,$1315,$C656,$882D,$1988,$1588,$2B13
   DC.W   $9224,$1427,$3244,$5308,$F8FE,$50F2,$0C64,$2C45,$F064,$32DC
   DC.W   $5111,$92F1,$00F4,$80F3,$80F3,$40F0,$4413,$6844,$4860,$3205
   DC.W   $0610,$5A72,$78C8,$1252,$20B4,$4120,$D131,$5C65,$68B6,$F4C4
   DC.W   $E546,$2233,$85E2,$B18C,$F446,$898A,$E32B,$44F3,$CC4C,$145E
   DC.W   $2856,$30B4,$E4F1,$9024,$A441,$F482,$D198,$8158,$82B1,$3922
   DC.W   $4142,$7324,$4530,$80F3,$CC4C,$145E,$2856,$30B4,$E4F1,$9024
   DC.W   $A441,$F482,$D198,$8158,$82B1,$3922,$4142,$2F29,$2229,$84F3
   DC.W   $CC4C,$145E,$2856,$30B4,$E4F1,$9024,$A441,$F102,$D198,$8158
   DC.W   $82B1,$3922,$4142,$7324,$4530,$80F0,$4413,$6844,$4860,$3205
   DC.W   $630D,$1463,$082D,$393C,$6409,$2916,$C0F3,$0E4F,$1902,$4A44
   DC.W   $11D0,$8232,$4415,$2022,$3355,$188E,$F813,$18C0,$F88E,$60F0
   DC.W   $4494,$8824,$1A26,$2B8C,$AD10,$4444,$8446,$6AA3,$11DF,$02F2
   DC.W   $1092,$898C,$6092,$898C,$6000,$0000,$0000,$0000,$0000,$0000

nbpix:
        dc.w    0               ;nb points a mettre sous les boutons
nbout:
        dc.w    0               ;nb de boutons actifs
polalert:
        dc.l    FONT7           ;adresse police pour alerte
atalert:
        dc.l    TCOMP8          ;adresse textes alerte
alalert:
        dc.l    TLONG8          ;adresse longueurs alertes
abalert:
        dc.l    0               ;adresse buffer decompression
baseboit:
        dc.w    0,70,0,40       ;X,Y,LARG
basebout:
        blk.l   14              ;(4BOUTONS + -1L)
adr_mes:
        dc.l    err0mes,err1mes,err2mes,err3mes,err4mes,err5mes
        dc.l    err6mes,err7mes,err8mes,err9mes,errames
err0mes:
        dc.w    152                   ;larg
        dc.w    10,4,50,10,1,1        ;x,y,larg,haut,mode(0/1),numero
        dc.w    27,24,24,8,0,2        ;x,y,larg,haut,mode(0/1),numero
        dc.w    106,24,22,8,0,3       ;x,y,larg,haut,mode(0/1),numero
        dc.w    -1
err1mes:
        dc.w    162
        dc.w    10,2,16,8,1,4
        dc.w    30,26,16,8,0,5
        dc.w    100,26,48,8,0,6
        dc.w    -1
err2mes:
        dc.w    96
        dc.w    10,4,50,10,1,7
        dc.w    20,16,7,15,0,8
        dc.w    36,16,7,15,0,9
        dc.w    52,16,7,15,0,10
        dc.w    68,16,7,15,0,11
        dc.w    -1
err3mes:
        dc.w    182
        dc.w    10,4,50,10,1,12
        dc.w    20,24,75,8,0,13
        dc.w    120,24,48,8,0,6
        dc.w    -1
err4mes:
        dc.w    100
        dc.w    10,4,50,10,1,14
        dc.w    20,16,7,15,0,8
        dc.w    36,16,7,15,0,9
        dc.w    52,16,7,15,0,10
        dc.w    68,16,7,15,0,11
        dc.w    -1
err5mes:
        dc.w    152
        dc.w    10,4,50,10,1,21
        dc.w    20,24,42,8,0,22
        dc.w    88,24,42,8,0,6
        dc.w    -1 
err6mes:
        dc.w    172
        dc.w    10,4,50,10,1,15
        dc.w    76,24,14,8,0,5
        dc.w    -1
err7mes:
        dc.w    172
        dc.w    10,4,50,10,1,16
        dc.w    76,24,14,8,0,5
        dc.w    -1
err8mes:
        dc.w    152
        dc.w    10,4,50,10,1,17
        dc.w    68,24,14,8,0,5
        dc.w    -1
err9mes:
        dc.w    152
        dc.w    10,4,50,10,1,18
        dc.w    44,24,75,8,0,13
        dc.w    -1
errames:
        dc.w    152
        dc.w    10,4,50,10,1,19
        dc.w    40,24,75,8,0,13
        dc.w    -1
bufmous:
        blk.w   7
byecr:
        dc.w    0
ALERTE:
        MOVEM.L D1-D7/A0-A5,-(A7)
        TST     flgani
        BNE.S   NALERT  
        CMPI    #6,D0
        BGE     CALERT          ;BOITE UN SEUL BOUTON
NALERT:
        MOVE.L  polalert(PC),adpolice   
        MOVE    D1,nbout
        LSL     #1,D1
        MOVE    D1,nbpix
        LSL     #2,D0
        LEA     ADR_MES(PC),A0
        MOVE.L  0(A0,D0.W),A0
        MOVE    (A0)+,D0
        MOVE    D0,baseboit+4   ;LARGEUR
        MOVE    D0,D1
        SUB     #256,D1         ;LARGEUR DE LA FENETRE D'IMAGE
        NEG     D1
        LSR     #1,D1
        MOVE    D1,baseboit     ;X
        MOVEM   baseboit(PC),D0/D1/D2/D3
        ADD     D0,D2
        ADD     D1,D3
        CLR.L   -(A7)
        MOVE.L  ecrbuf(PC),-(A7)
        MOVE.L  abalert(PC),-(A7)
        ADD.L   #100,(A7)
        MOVE.L  D0,-(A7)
        MOVE.L  D1,-(A7)
        MOVE.L  D2,-(A7)
        MOVE.L  D3,-(A7)
        BSR     SAVMEM

        MOVEM   baseboit(PC),D0/D1/D2/D3
        CLR.L   -(A7)
        MOVE.L  D2,-(A7)        ;LARGEUR
        MOVE.L  D1,-(A7)        ;Y
        MOVE.L  D0,-(A7)        ;X
        MOVE.L  ecrbuf(PC),-(A7)    ;ECRAN
        MOVE.L  adr_sprt(PC),-(A7)  ;PLANCHE
        BSR     BOITE

        LEA     BASEBOUT(PC),A1
DALERT:
        MOVE    (A0)+,D0
        BLT     FALERT
        MOVEM   (A0)+,D1/D2/D3
        ADD     baseboit(PC),D0
        ADD     baseboit+2(PC),D1
        ADD     D0,D2
        ADD     D1,D3
        MOVEM   D0/D1/D2/D3,(A1) ;x,y,w,h
        ADDQ    #1,D0
        ADDQ    #1,D1
        ADDQ    #8,A1
        MOVE.W  #-1,highbox
        MOVE.L  atalert(PC),adr_tab
        MOVE.L  alalert(PC),adr_lng
        MOVE.L  abalert(PC),adr_buf
        MOVE.L  ecrbuf(PC),adecran
        MOVE.W  D0,xecri
        MOVE.W  D1,yecri
        MOVE.W  D1,byecr
        MOVE    D0,D2
        SUB     baseboit(PC),D2
        ADD     D2,D2
        SUB     baseboit+4(PC),D2
        NEG     D2
        MOVE.W  D2,lngbox
        MOVE.W  #7,interlig ;INTERLIGNE
        CLR.L   couleur
        MOVE.W  (A0)+,justif
        CLR.W   flg_aff
        CLR.W   numero
        MOVE.W  (A0)+,numero+2
        MOVEM.L D0-D7/A0-A6,-(A7)

        MOVEQ   #24,D0
        MOVE.L  abalert(PC),A0
ct0:    CLR.L   (A0)+
        DBF     D0,ct0

        BSR     afftxt0     ;NOIR
        SUBQ    #1,xecri
        MOVE    byecr(PC),yecri
        BSR     afftxt0     ;NOIR
        SUBQ    #1,byecr
        MOVE    byecr(PC),yecri
        MOVE.W  #15,couleur+2
        BSR     afftxt0     ;BLANC
        MOVEM.L (A7)+,D0-D7/A0-A6
        LSR     nbpix
        BCC     DALERT
        MOVE.L  ecrbuf(PC),-(A7)
        MOVE    -8(A1),D0
        ADDQ    #2,D0
        MOVE.L  D0,-(A7)
        MOVE    -6(A1),D0
        ADD     #10,D0
        MOVE.L  D0,-(A7)
        CLR.L   -(A7)
        BSR     AFMARK
        MOVE.L  ecrbuf(PC),-(A7)
        MOVE    -8(A1),D0
        ADDQ    #1,D0
        MOVE.L  D0,-(A7)
        MOVE    -6(A1),D0
        ADD     #9,D0
        MOVE.L  D0,-(A7)
        MOVE.L  #15,-(A7)
        BSR     AFMARK
        BRA     DALERT
FALERT: MOVE.L  #-1,(A1)+

        MOVE.L  ecrbuf(PC),A0
        MOVE.L  adphys(PC),A1
        MOVE.W  #7999,D0
IJK:    MOVE.L  (A0)+,(A1)+
        DBF     D0,IJK

        MOVE    flag_mous(PC),bufmous
        NEG     bufmous
        BEQ.S   ALERT0
        MOVE    bufmous(PC),D2
        SUBQ    #1,D2
ALERT1: BSR     SHOWMOUSE
        DBF     D2,ALERT1
ALERT0: MOVE.L  tab_clav(PC),A0
        MOVE.L  2(A0),bufmous+2     ;xmouse,ymouse
        MOVE.L  12(A0),bufmous+6
        MOVE.L  16(A0),bufmous+10
        MOVE.L  #$00820064,2(A0)    ;160,100
        CLR.L   12(A0)              ;  0,  0
        MOVE.L  #$013000b8,16(A0)   ;304,184

        MOVE.L  tab_clav(PC),A1
        BTST    #7,nbout
        BEQ.S   MALER2
        MOVE    #$FFFF,nbout
MALER2: TST     nbout
        BNE.S   MALERT
        NOT     nbout
MALERT: TST     (A1)
        BEQ.S   MALERT
        TST     flagdemo
        BNE     DEMALE     
MALER1: TST     (A1)
        BNE.S   MALER1
DEMALE: MOVEM   2(A1),D0/D1     ;XM,YM
        LEA     BASEBOUT(PC),A0   ;la premiere ne sert pas
        MOVE    #-1,D2
SALERT:
        ADDQ    #1,D2
        ADDQ    #8,A0
        CMPI    #-1,(A0)
        BEQ.S   MALERT          ;Pas trouve
        CMP     (A0),D0
        BLT.S   SALERT
        CMP     2(A0),D1
        BLT.S   SALERT
        CMP     4(A0),D0
        BGT.S   SALERT
        CMP     6(A0),D1
        BGT.S   SALERT
        BTST    D2,nbout+1   
        BEQ.S   SALERT          ;bouton inactif

        MOVE.W  D2,-(A7)
        MOVEM   baseboit(PC),D0/D1/D2/D3
        ADD     D0,D2
        ADD     D1,D3
        MOVE.L  #1,-(A7)
        MOVE.L  abalert(PC),-(A7)
        ADD.L   #100,(A7)
        MOVE.L  #0,-(A7)
        MOVE.L  D0,-(A7)
        MOVE.L  D1,-(A7)
        MOVE.L  D2,-(A7)
        MOVE.L  D3,-(A7)
        BSR     SAVMEM
        MOVE    bufmous(PC),D2
        BEQ.S   ALERT3
        SUBQ    #1,D2
ALERT2: BSR     HIDEMOUSE
        DBF     D2,ALERT2

ALERT3:
        MOVE.W  (A7)+,D2
        MOVE.L  tab_clav(PC),A0
        MOVE.L  bufmous+2(PC),2(A0)     ;xmouse,ymouse
        MOVE.L  bufmous+6(PC),12(A0)
        MOVE.L  bufmous+10(PC),16(A0)
        MOVE    D2,D0               ;Numero du bouton
        MOVEM.L (A7)+,D1-D7/A0-A5
        RTS
FLGACOL:
        DC.W    0
CALERT:
        BSR     HIDEMOUSE

        MOVE.L  polalert(PC),adpolice   
        LSL     #2,D0
        LEA     ADR_MES(PC),A0
        MOVE.L  0(A0,D0.W),A0
        MOVE    (A0)+,D0
        MOVE    D0,baseboit+4   ;LARGEUR
        MOVE    D0,D1
        SUB     #256,D1         ;LARGEUR DE LA FENETRE D'IMAGE
        NEG     D1
        LSR     #1,D1
        MOVE    D1,baseboit     ;X

        MOVE.L  adphys(PC),A2
        ADD     #11200+16,A2
        MOVE.L  abalert(PC),A1
        ADD     #100,A1
        MOVEQ   #39,D1
GAG2:   MOVEQ   #11,D0
GAG1:   MOVE.L  (A2)+,(A1)+
        MOVE.L  (A2)+,(A1)+
        DBF     D0,GAG1
        ADD     #64,A2
        DBF     D1,GAG2
        
        MOVEM   baseboit(PC),D0/D1/D2/D3
        CLR.L   -(A7)
        MOVE.L  D2,-(A7)        ;LARGEUR
        MOVE.L  D1,-(A7)        ;Y
        MOVE.L  D0,-(A7)        ;X
        MOVE.L  adphys(PC),-(A7)    ;ECRAN
        MOVE.L  adr_sprt(PC),-(A7)  ;PLANCHE
        BSR     BOITE

        CLR.L   -(A7)           ;UNE DEUXIEME FOIS A CAUSE ANIMATIONS
        MOVE.L  D2,-(A7)        ;LARGEUR
        MOVE.L  D1,-(A7)        ;Y
        MOVE.L  D0,-(A7)        ;X
        MOVE.L  adphys(PC),-(A7)    ;ECRAN
        MOVE.L  adr_sprt(PC),-(A7)  ;PLANCHE
        BSR     BOITE

CDALER:
        MOVE    (A0)+,D0
        BLT     CFALER
        MOVEM   (A0)+,D1/D2/D3
        ADD     baseboit(PC),D0
        ADD     baseboit+2(PC),D1
        ADD     D0,D2
        ADD     D1,D3
        ADDQ    #1,D0
        ADDQ    #1,D1
        MOVE.W  #-1,highbox
        MOVE.L  atalert(PC),adr_tab
        MOVE.L  alalert(PC),adr_lng
        MOVE.L  abalert(PC),adr_buf
        MOVE.L  adphys(PC),adecran
        MOVE.W  D0,xecri
        MOVE.W  D1,yecri
        MOVE.W  D1,byecr
        MOVE    D0,D2
        SUB     baseboit(PC),D2
        ADD     D2,D2
        SUB     baseboit+4(PC),D2
        NEG     D2
        MOVE.W  D2,lngbox
        MOVE.W  #7,interlig ;INTERLIGNE
        CLR.L   couleur
        MOVE.W  (A0)+,justif
        CLR.W   flg_aff
        CLR.W   numero
        MOVE.W  (A0)+,numero+2
        MOVEM.L D0-D7/A0-A6,-(A7)

        MOVEQ   #24,D0
        MOVE.L  abalert(PC),A0
ct2:    CLR.L   (A0)+
        DBF     D0,ct2

        BSR     afftxt0     ;NOIR
        SUBQ    #1,xecri
        MOVE    byecr(PC),yecri
        BSR     afftxt0     ;NOIR
        SUBQ    #1,byecr
        MOVE    byecr(PC),yecri
        MOVE.W  #15,couleur+2
        BSR     afftxt0     ;BLANC
        MOVEM.L (A7)+,D0-D7/A0-A6
        BRA     CDALER
CFALER:
        CLR.W   FLGACOL
        MOVE    $FFFF825E.W,D0
        ANDI    #$777,D0
        BNE.S   BLANCALERT
        MOVE    #1,FLGACOL
        MOVE    #$777,$FFFF825E.W
BLANCALERT:
        MOVE.L  tab_clav(PC),A1
        TST     (A1)
        BEQ.S   BLANCALERT
        TST     flagdemo
        BNE.S   CHALER
CGALER: TST     (A1)
        BNE.S   CGALER

CHALER:
        MOVE.L  adphys(PC),A0
        ADD     #11200+16,A0
        MOVE.L  abalert(PC),A1
        ADD     #100,A1
        MOVEQ   #39,D1
GAG3:   MOVEQ   #11,D0
GAG4:   MOVE.L  (A1)+,(A0)+
        MOVE.L  (A1)+,(A0)+
        DBF     D0,GAG4
        ADD     #64,A0
        DBF     D1,GAG3

        TST     FLGACOL
        BEQ.S   NOBLALERT
        CLR     $FFFF825E.W
NOBLALERT:
        BSR     SHOWMOUSE
        MOVEM.L (A7)+,D1-D7/A0-A5
        RTS

;;;;;;;;;;; CHARGEMENT ET INSTALLATION PERSONNAGES ;;;;;;;;;
ecrvisag:
            dc.l    0
adrgnons:
            dc.l    0
advisage:
;            dc.w    11224,11392,11552,12504,11712,11392,10424,11864,11544
            dc.w    48,70,64,71,64,72,48,78,64,73,64,71,48,65,48,74,48,72
GNON:
LOADSUIV:
LOADPERS:
            RTS

;;;;;;;;;;;;; CHARGEMENT FICHIER HUFFMAN OBJETS ;;;;;;;;;;;;

LOADOBJT:
            MOVEM.L D0-D7/A0-A6,-(A7)
            MOVE.W  60+6(A7),D0                ; numero du fichier
            MOVE.W  60+10(A7),num              ; numero d'objet
            MOVE.L  60+12(A7),adrload          ; adr dest
            MOVE.L  60+16(A7),bufload          ; buffer de chrgt

            BSR     EXELDOBJ

            MOVEM.L (A7)+,D0-D7/A0-A6
            MOVE.L  (A7),16(A7)
            LEA     16(A7),A7
            MOVE.L  LONG_FIC(PC),D0
            RTS
EXELDOBJ:
            ADD     #NBLIEU-1,D0        ; 31 pour objet, 32 anim ...
EXE0DOBJ:   MOVE.L  bufload(PC),A0      ; ADRSRC
            JSR     MAKEKEY  
            MOVE    num(PC),D0
            JSR     CALCHUF
            MOVE.L  D1,LONG_FIC
            MOVE.L  bufload(PC),A0
            MOVE.L  adrload(PC),A1
            MOVE.L  A1,ADRTMP
            JSR     HUFFMAN             ; charge et decomp chap. num
            RTS

ADRTMP:     dc.l    0
ADRSRC:     dc.l    0
LONG_FIC:   dc.l    0
INITPAL:
            MOVE.L  4(A7),D0
            MOVE.L  D0,palmidi
            ADD.L   #32,D0
            MOVE.L  D0,palsix
            ADD.L   #32,D0
            MOVE.L  D0,palnuit
            MOVE.L  (A7),4(A7)
            LEA     4(A7),A7
            RTS
adrbase:
            dc.l    0
TROUTLIEU:
            BRA     LOADECOR        ;decor
            BRA     LOADTABLE       ;table
            BRA     EXE0DOBJ        ;ouvert/ferme
            BRA     LOADASON        ;animations sonores
            BRA     EXE0DOBJ        ;aide
            BRA     LOADANIS        ;animations statiques
            BRA     LOADANIP        ;animations de personnages
            BRA     LOADANIP        ;animations de personnages
            BRA     LOADANIP        ;animations de personnages
            BRA     APDECOR         ;a faire si pas LOADANIP
LOADLIEU:
            MOVEM.L D0-D7/A0-A6,-(A7)
            MOVE.W  60+6(A7),D0
            MOVE.W  D0,numanim          ; numero de lieu
            MOVE.L  60+12(A7),adrload         ; adr dest
            MOVE.L  60+16(A7),bufload         ; buffer de chrgt
            MOVE    60+10(A7),num             ; sous-fichier
            MOVE    num(PC),D1
            LSL     #2,D1
            JSR     TROUTLIEU(PC,D1.W)
            MOVEM.L (A7)+,D0-D7/A0-A6
            MOVE.L  LONG_FIC(PC),D0
            ADDQ.L  #1,D0
            BCLR    #0,D0
            MOVE.L  (A7),16(A7)
            LEA     16(A7),A7
            RTS
LOADTABLE:
            MOVE.L  adrload(PC),LADRES
            BSR     EXE0DOBJ
            RTS
LOADECOR: 
            tst.w   fltimb
            beq     paintib
            clr.w   fltimb
            bsr     inib
            bra.s   paintib
inib:       lea      int_hbl(PC),A0      ;posit vecteur hbl
            move.l   A0,$120.w
            or.w     #$700,sr
            clr.b    $fffffa1b.w
            move.b   LIGHBL+1,$fffffa21.w   ;reg donnee init hbl
            move.b   #16+8,$fffffa1b.w       ;reg control compte d'events
            and.w    #$f3ff,sr
            moveq    #8,D0
            moveq    #1,D1
            bsr      Mfp_act
            rts
paintib:
            MOVE.W  numanim(PC),D0 
            MOVE.L  bufload(PC),A0
            JSR     MAKEKEY

            CLR.W   D0                  ; Decompresse decor                 
            JSR     CALCHUF
            MOVE.L  bufload(PC),A1
            MOVE.L  A1,A0
            ADD.L   D1,A0               ;T_LEN  
            MOVE.L  A0,ADRTMP
            JSR     HUFFMAN
            MOVE.L  bufload(PC),A0
            CLR.L   -(A7)               ; Pas de palette remap
            MOVE.L  ADRTMP(PC),-(A7)    ; Buffer de decompression
            MOVE.L  A0,-(A7)            ; Source compresse
            CLR.L   -(A7)
            CLR.L   -(A7)
            MOVE.L  ecrbuf(PC),-(A7)    ; Ecran 2       
            BSR     DECOMP              ; Et installe sur ecran 2

            TST.L   adrload
            BNE.S   load1lieu                 ; Seulement le decor
            CLR.L   adpiano+4                 ; ani-son Jean-Luc
            MOVE    numanim(PC),adpiano+12    ; numero de lieu
            JSR     COUPSON
            RTS
load1lieu:                               ;*** si seulement chrgt decor
;            BSR     APDECOR
            RTS

LOADASON:
            CLR.L   LONG_FIC       ;provisoire!!!!
;            BSR     EXE0DOBJ
;            MOVE.L  adrload(PC),adpiano+4   ; Adresse anim-son pour jl
            RTS
LOADANIP:
            MOVE.L  adrload(PC),A1
            MOVE.L  A1,adrbase
            LEA     32000(A1),A1
            MOVE.L  A1,adrload
            MOVE.L  bufload(PC),bufdecomp

            MOVE.W  numanim(PC),D0
            ADDQ    #2,num
            BSR     EXE0DOBJ
            TST.L   LONG_FIC
            BEQ.S   ERL03
            BSR     LOADANIM
ERL03:
            move.l  suivani(PC),D0     ; fin du buffer d'animation
            move.l  D0,adrload
            sub.l   D0,adrbase
            neg.l   adrbase
            move.l  adrbase,LONG_FIC

            MOVE.L  adrload(PC),adpiano+8   ; adresse memoire libre
            MOVE.L  adrload(PC),ecrsup
            JSR     INITBASECH
            MOVE.L  adpiano+8,D0

            RTS
LOADANIS:
            MOVE.L  adrload,adrbase
            move    #20,BUFHBL          ;par defaut
            clr.w   flgani
            clr.w   flgmask
            MOVE.L  #1,-(A7)
            BSR     VBLSYNC

            MOVE.L  adrload(PC),A1
            MOVE.L  A1,tabchain
            LEA     30200(A1),A1
            MOVE.L  A1,adrload
            MOVE.L  bufload(PC),bufdecomp

            MOVE.W  numanim(PC),D0          ; charge chainages
            BSR     EXE0DOBJ

            TST.L   LONG_FIC
            BEQ.S   ERL04         
            MOVE.L  adrload(PC),A0
            MOVE.L  tabchain(PC),A1
MOVCHAIN:   MOVE    (A0)+,(A1)+
            BGE.S   MOVCHAIN
ERL04:   
            MOVE.L  A1,D0
            MOVE.L  D0,adscript
            ADD.L   #200,D0
            MOVE.L  D0,adobjet
            MOVE.L  #-1,(A1)
            MOVE.L  adscript(PC),curscript
            MOVE.L  adobjet(PC),curobjet

            MOVE.W  numanim(PC),D0          ; charge animations statiques
            ADDQ    #1,num
            BSR     EXE0DOBJ
            TST.L   LONG_FIC
            BEQ.S   ERL01
            BSR     LOADANIM
ERL01:
            MOVE.W  numanim(PC),D0          ; charge animations mobiles
            ADDQ    #1,num
            BSR     EXE0DOBJ
            TST.L   LONG_FIC
            BEQ.S   ERL02
            BSR     LOADANIM
ERL02:
            move.l  suivani(PC),D0     ; fin du buffer d'animation
            move.l  D0,adrload
            sub.l   D0,adrbase
            neg.l   adrbase
            move.l  adrbase,LONG_FIC            

            MOVE.L  adrload(PC),adpiano+8   ; adresse memoire libre
            MOVE.L  adrload(PC),ecrsup
            JSR     INITBASECH
            MOVE.L  adpiano+8,D0

            RTS
;;;;;;;;;;;;;;;; ROUTINE CHARGEMENT ANIMATIONS ;;;;;;;;;;;;;
LOADANIM:
        move.l  adrload(PC),A0
        move.w  (A0)+,D0            ;type animation
        move    D0,typeani
        clr.l   D1
        move.w  (A0)+,D1            ;memoire totale animation
        add.l   curobjet(PC),D1     ;         '
        move.l  D1,suivani          ;         '
        clr.l   D1
        move.w  (A0)+,D1            ;memoire data's animation
        add.l   curobjet(PC),D1     ;         '
        move.l  D1,adrani           ;         '
        jsr     ltabani(PC,D0.W)
        move.l  suivani(PC),curobjet
        bra.s   finload
ltabani:
        bra     loadstat
        bra     loadbloc
        bra     loadmobi
        bra     loadmask
        bra     loadspec
finload:
        move.l  adscript(PC),A0
fin2load:
        cmpi.l  #-1,(A0)
        beq.s   fin3load
        bset    #7,(A0)
        addq.w  #4,A0
        bra     fin2load
fin1load:
        move    BUFHBL(PC),LIGHBL
fin3load:
        tst     flgmask
        bne.s   fin4load
        bsr     creemask
fin4load:
        rts
; appele par LOADLIEU si chrt decor
APDECOR:
        tst.l   adscript
        blt     mod2ani
        move.l  adscript(PC),A0         ;aff objets prem fois
mod4ani:
        move.l  (A0)+,D0
        cmpi.l  #-1,D0
        beq     mod2ani
        btst    #31,D0
        bne.s   mod4ani
mod1ani:
        move.l  A0,-(A7)
        move.l  D0,A0
        tst     (A0)
        bne     mod3ani
        move.l  10(A0),14(A0)       ;bloc
        move.l  14(A0),A1
        move.w  (A1),D0             ;sequence + appel son
        andi    #$fff0,D0
        lsr     #1,D0
        move.l  36(A0),A2           ;source
        adda    D0,A2
        move.l  A2,adpiano          ;doit etre dernier objet
        clr     D0                  ;x*y source
        move    30(A0),D1           ;x*y dest
        move.w  32(A0),D2           ;largeur
        move.w  34(A0),D3           ;hauteur

        move.l  adphys(PC),-(A7)
        move.l  ecrbuf(PC),adphys
        bsr     goblock
        move.l  (A7)+,adphys
mod3ani:
        move.l  (A7)+,A0
        bra     mod4ani
mod2ani:
        rts
paschain:
loadstat:
        move.l  curscript(PC),premscript
load1stat: 
        move.w  (A0)+,D0
        blt     finldstat
        lea     -2(A0,D0.W),A1      ;adresse objet n sur fichier
        move.l  curscript(PC),A2
        move.l  curobjet(PC),A3         ;ad deb objet dans script
        move.l  A3,(A2)+            ;    ..........
        move.l  A2,curscript        ;et pointe sur suivant
        move.l  A3,A2               ;ad deb objet dans A2
        move.l  adrani(PC),36(A2)   ;adresse ecran sprites
        clr.w   (A2)+               ;flag anim static
        lea     40(A3),A4           ;taille zone travail
        move.l  A4,(A2)             ;ad 1ere sequence
        add.l   #10,(A2)+           ;repete a partir 2eme sequence
        move.l  A4,(A2)+            ;ad cur sequence
        clr.l   D0
        move.w  (A1),D0
        add.l   A4,D0
        move.l  D0,(A2)+            ;adresse premier bloc
        move.l  D0,(A2)+            ;adresse bloc courant (premier)
        move.w  2(A1),(A2)+         ;vitesse en cours
        move.w  2(A1),(A2)+         ;valeur vitesse
        move.w  4(A1),(A2)+         ;delai en cours
        move.w  4(A1),(A2)+         ;valeur delai
        move.w  6(A1),(A2)+         ;repeat en cours
        move.w  6(A1),(A2)+         ;valeur repeat
        add     #10,A2
*****************************************
debscript:
        move.w  (A1)+,D0
        ext.l   D0
        cmpi    #-1,D0
        beq.s   finscript
        cmpi    #-2,D0
        beq.s   deb1scri
        add.l   A4,D0
deb1scri:
        move.l  D0,(A2)+            ;adresse premier bloc
        move.w  (A1)+,(A2)+         ;valeur vitesse
        move.w  (A1)+,(A2)+         ;valeur delai
        move.w  (A1)+,(A2)+         ;valeur repeat
        bra     debscript
finscript:
        clr.w   BUFHBL
        move.l  #-1,(A2)+
*********************************************
debseq:
        move.w  (A1)+,(A2)+         ;sequence + appel son
        cmpi    #-1,-2(A2)
        bne.s   debseq
        cmpi    #-1,(A1)
        bne.s   debseq
        addq    #2,A1
*********************************************
        move.l  (A1)+,30(A3)        ;(x,y), largeur
        move.w  (A1)+,34(A3)        ;hauteur
        clr.l   D0                  ;determine ligne HBL
        move    30(A3),D0
        divu    #160,D0
        add     34(A3),D0
        cmp     BUFHBL(PC),D0
        blt.s   debobj
        move    D0,BUFHBL
*********************************************
debobj:
        move.w  (A1)+,D0            ;(x,y) source du bloc
        blt     finobj
;;;;;;;; faire sous-routine ;;;;;;;;
        movem.l A0-A1,-(A7)
        move.l  adrani(PC),A1       ;dest
        adda    D0,A1
        move.l  ecrbuf(PC),A0       ;source 
        adda    30(A3),A0           ;x*y
        move.w  32(A3),D2           ;largeur
        move.w  D2,D0
        sub.w   #19,D2
        neg.w   D2
        lsl.w   #3,D2
        move.w  34(A3),D1           ;hauteur
dobjlig:
        move.l  (A0)+,(A1)+
        move.l  (A0)+,(A1)+
        dbf     D0,dobjlig
        adda    D2,A0
        adda    D2,A1
        move.w  32(A3),D0
        dbf     D1,dobjlig
        movem.l (A7)+,A0-A1
        bra     debobj
finobj:
        move.l  A2,curobjet         ;adresse objet suivant
        bra     load1stat            ;vers objet suivant
*********************************************
finldstat:
        move.l  #-1,(A2)+
        move.l  A2,curobjet
        move.w  (A0)+,D0
        lea     -2(A0,D0.W),A1      ;adr image compressee

;;;;;;;;;;;;;;;; vers decompresseur ;;;;;;;;;;;;;;;

        move.l  curscript(PC),A2
        move.l  #-1,(A2)
        move.l  A3,-(A7)
        clr.l   -(A7)
        move.l  bufdecomp(PC),-(A7)
        move.l  A1,-(A7)
        clr.l   -(A7)
        clr.l   -(A7)
        move.l  adrani(PC),-(A7)
        jsr     DECOMP
        move.l  (A7)+,A3
        rts
typeani:
        dc.w    0
loadmask:
        add.l   #6520,adrani        ;place du buffer masque
        add.l   #6520,suivani       ;   '
        move    #8,typeani
loadmobi:
        lea     zzbuf(PC),A5
        bra     loadblo1
loadbloc:
        move    #100,LIGHBL
loadblo1:
        move.w  (A0)+,D0
        blt     finldbloc
        lea     -2(A0,D0.W),A1      ;adresse objet n sur fichier
        move.l  curscript(PC),A2
        move.l  curobjet(PC),A3     ;ad deb objet dans script
        move.l  A3,(A2)+            ;    ..........
        move.l  A2,curscript        ;et pointe sur suivant
        move.l  A3,A2               ;ad deb objet dans A2
        move.w  typeani(PC),(A2)+   ;flag anim bloquante ou mobile
        move.l  (A1)+,18(A2)        ;x y clip coin haut
        move.l  (A1)+,22(A2)        ;x y clip coin bas
        move.l  (A1)+,4(A2)         ;x y debut
        move.l  (A1)+,8(A2)         ;largeur hauteur
        move.w  10(A2),(A5)+
        move.w  (A1),0(A2)          ;time    
        move.w  (A1),2(A2)          ;curtime
        move.l  6(A1),14(A2)        ;vx vy
        move.w  10(A1),12(A2)       ;nombre de pas d'animation
        move.w  12(A1),52(A2)       ;nombre d'images par position
        move.w  12(A1),54(A2)       ;idem pour travail
        lea     58(A3),A4           ;nombre d'octets de la zone travail
        move.l  adrani(PC),48(A2)   ;ecran des sprites
        move.l  A4,40(A2)           ;adr premiere sequence
        move.l  A4,44(A2)           ;adr sequence en cours
        move.w  #-1,34(A2)          ;oldx, oldy
        clr.l   D0                  ;adr prem sequence
        move.w  2(A1),D0
        add.l   A4,D0
        move.l  D0,26(A2)
        clr.l   D0                  ;adr sequence cur
        move.w  4(A1),D0
        bgt.s   lobloc1
        move.l  #-1,30(A2) 
        bra.s   lobloc2
lobloc1:
        add.l   A4,D0
        move.l  D0,30(A2)
lobloc2:
        move.l  A4,A2
lobloc3:                            ;sequences
        move.w  (A1)+,D0
        cmpi    #-1,D0
        beq.s   lobloc4
        move.w  D0,(A2)+
        clr.l   D0
        move.w  (A1)+,D0
        add.l   A4,D0
        move.l  D0,(A2)+            ;adresse premier bloc
        clr.l   D0
        move.w  (A1)+,D0
        bgt.s   lobloc5
        move.l  #-1,(A2)+
        bra.s   lobloc6
lobloc5:
        add.l   A4,D0
        move.l  D0,(A2)+            ;adr bloc courant
lobloc6:
        move.l  (A1)+,(A2)+
        move.l  (A1)+,(A2)+
        bra     lobloc3
lobloc4:
        move.l  #-1,(A2)+
lobloc7:
        move.l  (A1)+,(A2)+         ;sequence + appel son
        tst.w   -4(A2)
        bge.s   lobloc7
        tst.w   (A1)
        bge.s   lobloc7
        addq    #4,A1
lobloce:
        move    (A1)+,D0            ;;;;;;
        addq    #2,A1               ;;;;;;
        move    D0,(A5)+            ;;;;;;
        bge.s   lobloce             ;;;;;;
        move.l  A2,curobjet         ;adresse objet suivant
        bra     loadblo1            ;vers objet suivant
finldbloc:
        move    #-1,(A5)+
        move.l  #-1,(A2)+
        move.l  A2,curobjet
        move.w  (A0)+,D0
        lea     -2(A0,D0.W),A1      ;adr image compressee
;;;;;; charge masque si existe      ;;;;;;;;;;;;;;;;;;
        cmpi    #-1,(A1)+
        beq.s   pair1msk
        subq    #2,A1
        move.l  A1,trav1
        move.l  adrani(PC),A1       ;debut du buffer de masque
        sub     #6520,A1            ;   '
        move.l  A1,bufmask          ;   '
        bsr     maskprim
        bsr     decmask
        bsr     copmask
        move.l  A0,D0
        btst    #0,D0
        beq.s   pairmsk
        subq.l  #1,D0
pairmsk:
        move.l  D0,A1
        move    #1,flgmask
pair1msk:
;;;;;;;;;;;;;;;; vers decompresseur ;;;;;;;;;;;;;;;
        move.l  adrani(PC),A2
        move.l  suivani(PC),D0
        sub.l   A2,D0
        lsr.w   #2,D0
        subq    #1,D0
lobloc9:
        clr.l   (A2)+
        dbf     D0,lobloc9
        move.l  curscript(PC),A2
        move.l  #-1,(A2)
        move.l  A3,-(A7)
        clr.l   -(A7)
        move.l  bufdecomp(PC),-(A7)
        move.l  A1,-(A7)
        clr.l   -(A7)
        clr.l   -(A7)
        cmpi    #8,typeani
        bne.s   loblocb
        move.l  bufdecomp(PC),-(A7)
        add.l   #5000,(A7)
        bra.s   loblocc
loblocb:
        move.l  adrani(PC),-(A7)
loblocc:
        jsr     DECOMP
        cmpi    #8,typeani
        bne     loblocg
        move.l  #zzbuf,adzzbuf
        lea     zzbuf+2(PC),A3
        move.l  adrani(PC),A1
loblocd:
        move.l  bufdecomp(PC),A0
        adda    #5000,A0
        move.w  (A3)+,D0
        blt.s   lobloca
        lsr     #1,D0
        add     D0,A0
        move.l  A2,-(A7)
        move.l  adzzbuf,A2
        move.w  (A2),D1
        bsr     creemous
        move.l  (A7)+,A2
        bra     loblocd
adzzbuf:
        dc.l    0
lobloca:
        tst     (A3)
        blt.s   loblocg
        move.l  A3,adzzbuf
        addq    #2,A3
        bra.s   loblocd
loblocg:
        move.l  (A7)+,A3
        rts
loadspec:
        move    #100,LIGHBL
loadspe1:
        move.w  (A0)+,D0
        blt     finldspec
        lea     -2(A0,D0.W),A1      ;adresse objet n sur fichier
        move.l  curscript(PC),A2
        move.l  curobjet(PC),A3     ;ad deb objet dans script
        move.l  A3,(A2)+            ;    ..........
        move.l  A2,curscript        ;et pointe sur suivant
        move.l  A3,A2               ;ad deb objet dans A2

        move.w  typeani(PC),(A2)+   ;flag anim spec
        move.l  (A1)+,(A2)+         ;x y clip coin haut
        move    #-100,-4(A2)        ;verrue pour clip ---
        move.l  (A1)+,(A2)+         ;x y clip coin bas
        move    #-1,(A2)+           ;xyaffichage
        clr.l   (A2)+               ;w,h
        clr     (A2)+               ;offset par rapport au debut de bloc
        move    #-1,(A2)+           ;oldxy
        clr.l   (A2)+               ;oldw,oldh
        clr     (A2)+               ;curtime
        clr.l   (A2)+               ;adresse sequence
        move.l  adrani(PC),(A2)+    ;page des sprites
loadspe2:
        move    (A1)+,(A2)+         ;time
        blt.s   lospece
        move.l  (A1)+,(A2)+         ;xbloc,ybloc
        move.l  (A1)+,(A2)+         ;wbloc,hbloc
        move.l  (A1)+,(A2)+         ;xdest,ydest
        bra.s   loadspe2
lospece:
        move.l  A2,curobjet         ;adresse objet suivant
        bra     loadspe1            ;vers objet suivant
finldspec:
        move.l  #-1,(A2)+
        move.l  A2,curobjet
        move.l  curscript(PC),A2
        move.l  #-1,(A2)
        clr.l   -(A7)
        move.l  bufdecomp(PC),-(A7)
        move.w  (A0)+,D0
        pea     -2(A0,D0.W)         ;adr image compressee
        clr.l   -(A7)
        clr.l   -(A7)
        move.l  adrani(PC),-(A7)
        jsr     DECOMP
        rts
zzbuf:
        blk.w    50,0     ;50 blocs
premscript:
        dc.l    0
suivani:
        dc.l    0
adrani:
        dc.l    0
flgani:
        dc.w    0
baseanim:
        dc.l    0
numanim:
        dc.w    0
debanim:
        dc.l    0
tabchain:
        dc.l    0
adscript:
        dc.l    0
curscript:
        dc.l    0
adobjet:
        dc.l    0
curobjet:
        dc.l    0
;;;;;;;;;; ROUTINE EXECUTION ANIMATIONS ;;;;;;;
execani:
            clr.w   nbdyne          ;nb anim dynamiques
            tst.w   flgani
            beq     finani
            move.l  adscript(PC),curscript
exeani3:
            move.l  curscript(PC),A0
exeani1:
            move.l  (A0)+,D0          ;adresse de l'objet
            bge.s   exeani2
            cmpi.l  #-1,D0
            beq     finani
            bra.s   exeani1
exeani2:
            move.l  A0,curscript
            move.l  D0,A0             ;base adresse objet
            move.w  (A0),D0           ;type d'animation
            jmp     etabani(PC,D0.W)
finani:     rts
etabani:
            bra     exestat           ;animation type statique
            bra     exebloc           ;animation type bloquante
            bra     exedyna           ;animation de sprites
            bra     exedyna           ;idem pour ani + masque
            bra     exespec
exestat:
            subq.w  #1,18(A0)         ;compteur vitesse
            bgt     exeani3
            beq.s   exesta3
            subq.w  #1,22(A0)         ;delai fin de sequence
            bgt     exeani3
            subq.w  #1,26(A0)         ;repeat sequence
            blt.s   exesta1
            move.l  10(A0),14(A0)     ;bloc
            move.w  20(A0),18(A0)     ;vitesse
            move.w  24(A0),22(A0)     ;delai
            bra     exeani3
exesta1:
            add.l   #10,6(A0)         ;sequence suivante
            move.l  6(A0),A1
            move.l  (A1),D0
            bge.s   exesta2
            move.l  2(A0),A1
            move.l  A1,6(A0)
exesta2:    move.l  (A1),10(A0)         ;bloc
            move.l  (A1)+,14(A0)
            move.w  (A1),18(A0)         ;vitesse
            move.w  (A1)+,20(A0)
            move.w  (A1),22(A0)         ;delai
            move.w  (A1)+,24(A0)
            move.w  (A1),26(A0)         ;repeat
            move.w  (A1)+,28(A0)
            bra     exeani3
exesta3:    move.l  A0,-(A7)
            move.l  36(A0),A2           ;adresse ecran sprite
            move.l  14(A0),A1
            move.w  (A1),D0             ;sequence + appel son
            move    D0,D1
            andi    #$fff0,D1
            lsr     #1,D1
            andi    #$f,D0
            beq.s   exesta4
            jsr     exebruit
exesta4:
            move.w  D1,D0
            move.w  30(A0),D1
            move.w  32(A0),D2
            move.w  34(A0),D3
            bsr     goblock
            move.l  (A7)+,A0
            addq.l  #2,14(A0)           ;bloc suivant
            move.l  14(A0),A1
            cmpi.w  #-1,(A1)
            beq     exeani3
            move.w  20(A0),18(A0)       ;vitesse
            bra     exeani3
exebloc:
            addq    #2,A0
            subq.w  #1,(A0)             ;compteur vitesse
            bgt     exeani3
exeblo17:
            move.w  2(A0),(A0)
            move.w  34(A0),D0           ;xyold en adresse
            blt.s   exeblo1
            move.w  36(A0),D1           ;largeur en blocs
            move.w  38(A0),D2           ;hauteur
            movem.l A0-A1,-(A7)
            move.l  ecrbuf(PC),A0
            move.l  bufsup(PC),A1
            bsr     clrblok
            movem.l (A7)+,A0-A1
exeblo1:
            clr.w   D6
            move.w  18(A0),D2           ;xclip
            move.w  4(A0),D0            ;x0
            move.w  8(A0),D1            ;largeur
            sub.w   D0,D2
            ble.s   exeblo2
            sub.w   D2,D1
            move    8(A0),D1            ;******* NEW ROUT SPRT *******
            bgt.s   exeblo3
            move.w  #-1,34(A0)          ;xold => pas d'aff
            bra     exeblo9
exeblo3:
;            move.w  D2,D6
;            move.w  18(A0),D0
            bra     exeblo4
exeblo2:
            move.w  4(A0),D0
            move.w  8(A0),D1
            move.w  D0,D2
            add.w   D1,D2
            sub.w   22(A0),D2
            ble.s   exeblo4
            sub.w   D2,D1
            bgt.s   exeblo4
            move.w  #-1,34(A0)
            bra     exeblo9
exeblo4:
            swap    D6
            move.w  20(A0),D4           ;yclip
            move.w  6(A0),D2            ;y0
            move.w  10(A0),D3           ;hauteur
            sub.w   D2,D4
            ble.s   exeblo6
            sub.w   D4,D3
            bgt.s   exeblo7
            move.w  #-1,34(A0)          ;xold => pas d'aff
            bra     exeblo9
exeblo7:
            move.w  D4,D6
            move.w  20(A0),D2
            bra     exeblo8
exeblo6:
            move.w  6(A0),D2
            move.w  10(A0),D3
            move.w  D2,D4
            add.w   D3,D4
            sub.w   24(A0),D4
            ble.s   exeblo8
            sub.w   D4,D3
            bgt.s   exeblo8
            move.w  #-1,34(A0)
            bra     exeblo9
exeblo8:
            move.w  D2,D4
            mulu    #160,D4
            move.w  D0,D5
            lsr.w   #1,D5
            andi.w  #-8,D5
            add.w   D4,D5
            move.w  D5,34(A0)           ;xold etc...
            move.w  D1,D5
            lsr.w   #4,D5
            addq    #1,D5
            move.w  D5,36(A0)           ;  '
            move.w  D3,38(A0)           ;  '

            move.l  admask,-(A7)
            move.l  bufsup(PC),-(A7)
            move.l  48(A0),-(A7)        ;adresse ecran sprite
            move.w  D2,-(A7)
            move.w  D0,-(A7)
            move.w  D3,-(A7)
            move.w  D1,-(A7)
            move.l  30(A0),A1

            move.w  2(A1),D0            ;sequence + appel son
            lsr     #8,D0
            beq.s   exeblo18
            bsr     exebruit
exeblo18:
            move    2(A1),D0
            andi    #$ff,D0
            add     D0,D6
            move.w  D6,-(A7)
            swap    D6
            add.w   (A1),D6
            move.w  D6,-(A7)
            bsr     go1block
            lea     24(A7),A7
exeblo9:
            subq.w  #1,54(A0)
            bgt.s   exeblo12
            move.w  52(A0),54(A0)   
            move.l  14(A0),D0
            add.w   D0,6(A0)
            swap    D0
            add.w   D0,4(A0)
            subq.w  #1,12(A0)
            blt.s   exeblo11
exeblo12:                               ;nouveau sprite
            move.l  30(A0),A1
            addq    #4,A1
            tst.w   (A1)
            bge.s   exeblo13
            move.l  26(A0),30(A0)
            bra     exeani3
exeblo13:
            move.l  A1,30(A0)
            bra     exeani3
exeblo11:
            move.l  44(A0),A1
            adda    #18,A1
            tst.w   (A1)
            blt.s   exeblo15
            move.l  A1,44(A0)
            move.w  (A1),(A0)          ;time
            move.w  (A1)+,2(A0)        ; ...
            move.l  30(A0),D0
            sub.l   26(A0),D0
            move.l  (A1)+,26(A0)
            move.l  (A1)+,30(A0)
            bgt.s   exeblo16
            move.l  26(A0),30(A0)
            add.l   D0,30(A0)
exeblo16:
            move.l  (A1)+,14(A0)
            move.w  (A1)+,12(A0)
            move.w  (A1)+,52(A0)
            move.w  (A1)+,54(A0)
            bra     exeani3
exeblo15:
            move.l  curscript(PC),A1
            bset    #7,-4(A1)           ;fin d'animation et 
            clr     modeani             ;debloque le jeu
            bra     finani
exespec:
            addq    #2,A0
            move.l  24(A0),A1           ;adresse etape  ---
            tst.l   (A1)
            bge.s   exespec1
            move.l  curscript(PC),A1
            bset    #7,-4(A1)           ;fin d'animation et 
            clr     modeani             ;debloque le jeu
            bra     exeani3             ;exeani3
exespec1:
            subq.w  #1,22(A0)           ;compteur vitesse ---
            bgt     exeani3

            move    (A1),22(A0)         ;curtime
            move    2(A1),D2            ;xs
            move    6(A1),D1            ;largeur
            move    10(A1),D0           ;xdest
            cmp     (A0),D0             ;xclip
            bge.s   exespec3
            sub     (A0),D0
            add     D0,D1               ;largeur apres clip
            ble     exespec7            ;hors zone de clip
            sub     D0,D2               ;xs apres clip
            move    (A0),D0             ;xdest = clip
            bra.s   exespec4
exespec3:
            move    D0,D3
            add     D1,D3
            cmp     4(A0),D3
            ble.s   exespec4
            sub     4(A0),D3
            sub     D3,D1
            ble     exespec7            ;hors zone de clip
exespec4:
            move    4(A1),D6            ;ys
            move    8(A1),D5            ;hauteur
            move    12(A1),D4           ;ydest
            cmp     2(A0),D4            ;yclip
            bge.s   exespec5
            sub     2(A0),D4
            add     D4,D5               ;hauteur
            ble     exespec7            ;hors zone de clip
            sub     D4,D6               ;ys apres clip
            move    2(A0),D4            ;ydest = clip
            bra.s   exespec6
exespec5:
            move    D4,D3
            add     D5,D3
            cmp     6(A0),D3
            ble.s   exespec6
            sub     6(A0),D3
            sub     D3,D5
            ble     exespec7           ;hors zone de clip
exespec6:
            move.l  admask,-(A7)
            move.l  bufsup(PC),-(A7)
            move.l  28(A0),-(A7)       ;adresse ecran sprite
            move.w  D4,-(A7)
            move.w  D0,-(A7)
            move.w  D5,-(A7)
            move.w  D1,-(A7)
            move.w  D6,-(A7)
            move.w  D2,-(A7)
            bsr     go1block
            lea     24(A7),A7
            movem   16(A0),D0/D1/D2     ;xyold en adresse,w,h ---
            tst     D0
            blt.s   exespec2

            movem.l A0-A1,-(A7)
            move.l  ecrbuf(PC),A0
            move.l  adphys(PC),A1
            bsr     clrblok
            movem.l (A7)+,A0-A1
            move    #-1,16(A0)          ; ---
exespec2:   movem.l A0-A1,-(A7)
            movem   8(A0),D0-D3
            move    D0,16(A0)
            blt.s   exespec20
            move    D1,18(A0)
            blt.s   exespec20
            move    D2,20(A0)
            blt.s   exespec20
            move.l  bufsup(PC),A0
            move.l  adphys(PC),A1
            bsr     clr1blok
exespec20:  movem.l (A7)+,A0-A1
            
exespec7:
            add.l   #14,24(A0)
            bra     exeani3
exedyna:
            addq    #2,A0
            move.w  10(A0),8(A0)
            move.w  8(A0),38(A0)
            lea     tabdyn(PC),A1
            add     nbdyne(PC),A1
            addq    #4,nbdyne            ;nb ani pour vbl
            move.l  A0,(A1)             ;positionne adr ani pour vbl
            subq.w  #1,(A0)             ;compteur vitesse
            bgt     exeani3
exedyn17:
            move.w  2(A0),(A0)
            subq.w  #1,54(A0)
            bgt.s   exedyn12
            move.w  52(A0),54(A0)   
            move.l  14(A0),D0
            add.w   D0,6(A0)
            swap    D0
            add.w   D0,4(A0)
            subq.w  #1,12(A0)
            blt.s   exedyn11
exedyn12:                               ;nouveau sprite
            move.l  30(A0),A1
            addq    #4,A1
            tst.w   (A1)
            bge.s   exedyn13
            move.l  26(A0),30(A0)
            bra     exeani3
exedyn13:
            move.l  A1,30(A0)
            bra     exeani3
exedyn11:
            move.l  44(A0),A1
            adda    #18,A1
            tst.w   (A1)
            bge.s   exedyn18
            tst     18(A0)
            beq.s   exedyn15
            move.l  40(A0),A1
exedyn18:
            move.l  A1,44(A0)
            move.w  (A1),(A0)          ;time
            move.w  (A1)+,2(A0)        ; ...
            move.l  30(A0),D0
            sub.l   26(A0),D0
            move.l  (A1)+,26(A0)
            move.l  (A1)+,30(A0)
            bgt.s   exedyn16
            move.l  26(A0),30(A0)
            add.l   D0,30(A0)
exedyn16:
            move.l  (A1)+,14(A0)
            move.w  (A1)+,12(A0)
            move.w  (A1),52(A0)
            move.w  (A1)+,54(A0)
            bra     exeani3
exedyn15:
            move.l  curscript(PC),A1
            bset    #7,-4(A1)
            bra     finani
clrblok:
            moveq   #19,D4
            sub.w   D1,D4
            lsl.w   #3,D4
            adda    D0,A0
            adda    D0,A1
            move.w  D1,D3
clrblok1:
            move.l  (A0)+,(A1)+
            move.l  (A0)+,(A1)+
            dbf     D3,clrblok1
            adda    D4,A0
            adda    D4,A1
            move.w  D1,D3
            dbf     D2,clrblok1
            rts
clr1blok:
            moveq   #19,D4
            sub     D1,D4
            add     D3,D4  ;a cause offset debut de bloc
            sub     D3,D1
            lsl     #3,D4
            lsl     #3,D3  ;offset debut
            adda    D0,A1
            adda    D3,A0
            move.w  D1,D5
clr1blok1:
            move.l  (A0)+,(A1)+
            move.l  (A0)+,(A1)+
            dbf     D5,clr1blok1
            adda    D4,A1
            adda    D3,A0
            move.w  D1,D5
            dbf     D2,clr1blok1
            rts
FILLSPRT:
        MOVEM.L A0-A1/D0-D7,-(A7)
        MOVEM   8(A0),D0-D3
        MOVE.L  ecrbuf,A0     ;rempli le buffer avec la portion d'ecran
        MOVE.L  bufsup,A1
        BSR     clr2blok
        MOVEM.L (A7)+,A0-A1/D0-D7
        RTS
clr2blok:
            moveq   #19,D4
            sub.w   D1,D4
            add     D3,D4
            sub     D3,D1
            lsl.w   #3,D4
            lsl     #3,D3
            adda    D0,A0
            move.w  D1,D5
            adda    D3,A1
clr2blok1:
            move.l  (A0)+,(A1)+
            move.l  (A0)+,(A1)+
            dbf     D5,clr2blok1
            adda    D4,A0
            adda    D3,A1
            move.w  D1,D5
            dbf     D2,clr2blok1
            rts
goblock:
    move.l  ecrbuf(PC),A0
    move.l  adphys(PC),A1
    move.l  admask(PC),A3
    adda    D0,A2              ;offset du bloc source
    adda    D1,A0              ;offset dest
    adda    D1,A1              ;  .     .
    lsr.w   #2,D1              ;pour masque
    adda    D1,A3              ;       '
    moveq   #19,D1
    sub.w   D2,D1
    lsl.w   #1,D1
    move.w  D1,D0
    lsl.w   #2,D0
    move.w  D1,A4
dcuph:
    move.w  D2,D4
dcupl:
    move.w  (A3)+,D1
    cmpi.w  #-1,D1
    bne.s   dcupl1
    move.l  (A2)+,D5
    move.l  D5,(A0)+
    move.l  D5,(A1)+
    move.l  (A2)+,D5
    move.l  D5,(A0)+
    move.l  D5,(A1)+
    dbf     D4,dcupl
    adda    D0,A0
    adda    D0,A1
    adda    D0,A2
    adda    A4,A3      ;   '
    dbf     D3,dcuph
    rts
dcupl1:
    move.w  D1,D5
    swap    D1
    move.w  D5,D1
    move.l  D1,D5
    not.l   D1
    move.l  (A2)+,D6
    and.l   D5,D6
    move.l  (A0),D7
    and.l   D1,D7
    or.l    D6,D7
    move.l  D7,(A0)+
    move.l  (A1),D7     ;;;;
    and.l   D1,D7       ;;;;
    or.l    D6,D7       ;;;;
    move.l  D7,(A1)+

    move.l  (A2)+,D6
    and.l   D5,D6
    move.l  (A0),D7
    and.l   D1,D7
    or.l    D6,D7
    move.l  D7,(A0)+
    move.l  (A1),D7     ;;;;
    and.l   D1,D7       ;;;;
    or.l    D6,D7       ;;;;
    move.l  D7,(A1)+

    dbf     D4,dcupl
    adda    D0,A0
    adda    D0,A1
    adda    D0,A2
    adda    A4,A3      ;   '
    dbf     D3,dcuph
    rts

go1block:
        LINK    A6,#-18
        MOVEM.L a0-a5/d0-D7,-(A7)
        MOVE.L  20(A6),A3
        MOVE.L  24(A6),A2
        MOVE    16(A6),D6  ;xdest
        MOVE    D6,D0
        ADD     12(A6),D0  ;x droit
        ASR     #4,D0
        MOVE    D6,D1
        ASR     #4,D1
        SUB     D1,D0
        MOVE    D0,-6(A6)  ;largeur en blocs
        MOVE    D0,10(A0)  ;pour recopier le bloc sur l'ecran
        CLR     14(A0)     ;depla dans le bloc
L0A2:   TST     D6
        BGE.S   L0A1
        ADD     #1,14(A0)
        ADD     #16,D6
        BRA.S   L0A2
L0A1:   MOVE    D6,D1
        LSR     #1,D1
        ANDI    #-8,D1
        MOVE    18(A6),D0
        MULU    #160,D0
        ADD     D0,D1
        MOVE    D1,8(A0) ;depla pour recopier sur ecran
        MOVE.L  28(A6),A5
        LSR     #2,D1
        ADDA    D1,A5
        MOVE    14(A6),12(A0) ;hauteur
        ANDI    #15,D6
        MOVE    8(A6),D1   ;xsource
        ASR     #1,D1
        AND     #-8,D1
        ADDA    D1,A3
        MOVE    10(A6),D1
        MULU    #160,D1
        ADDA    D1,A3      ;adresse source
        MOVE.L  A5,A4      ;mask
        TST     D6
        BEQ     L0LEQ
        BSR     FILLSPRT
        SUBQ    #1,-6(A6)
        BGE.S   L0FALS
L0TRUE:
        MOVE.B  #$50,L0L8
        BRA     L0L3
L0FALS:
        MOVE.B  #$51,L0L8
        BRA     L0L3
L0L4:
        MOVE.L  A3,A1
        MOVE.L  A4,A5
L0L7:
        MOVE.L  #$80000000,D0
        ASR.L   D6,D0
        ADD.L   D0,D0         ; <-> $8000000 >> (D6-1)
        MOVE.L  D0,D1
        MOVE.L  D0,D2
        MOVE.L  D0,D3
        MOVE.L  D0,D4
        BRA     L0L91
L0L9:
        CLR     D1
        CLR     D2
        CLR     D3
        CLR     D4
L0L91:
        MOVE    (A1)+,D5   ;plan 0
        SWAP    D5
        CLR     D5
        LSR.L   D6,D5
        OR.L    D5,D1
        MOVE    (A1)+,D5   ;plan 1
        SWAP    D5
        CLR     D5
        LSR.L   D6,D5
        OR.L    D5,D2
        MOVE    (A1)+,D5   ;plan 2
        SWAP    D5
        CLR     D5
        LSR.L   D6,D5
        OR.L    D5,D3
        MOVE    (A1)+,D5   ;plan 3
        SWAP    D5
        CLR     D5
        LSR.L   D6,D5
        OR.L    D5,D4
        SWAP    D1
        SWAP    D2
        SWAP    D3
        SWAP    D4
        MOVE    D1,D0
        AND     D2,D0
        AND     D3,D0
        AND     D4,D0      ;si bit = 1 transparent
        MOVE    (A5)+,D5   ;plan de masque
        NOT     D0
        AND     D5,D0
        AND     D0,D1
        AND     D0,D2
        AND     D0,D3
        AND     D0,D4
        NOT     D0
        AND     D0,(A2)
        OR      D1,(A2)+
        AND     D0,(A2)
        OR      D2,(A2)+
        AND     D0,(A2)
        OR      D3,(A2)+
        AND     D0,(A2)
        OR      D4,(A2)+
L0L8:
        DBF     D7,L0L9
        SWAP    D1
        SWAP    D2
        SWAP    D3
        SWAP    D4
        MOVE    D1,D0
        AND     D2,D0
        AND     D3,D0
        AND     D4,D0      ;si bit = 1 transparent
        MOVE.L  #$ffff0000,D5
        ASR.L   D6,D5
        AND     (A5)+,D5   ;plan de masque
        NOT     D0
        AND     D5,D0
        AND     D0,D1
        AND     D0,D2
        AND     D0,D3
        AND     D0,D4
        NOT     D0
        AND     D0,(A2)
        OR      D1,(A2)+
        AND     D0,(A2)
        OR      D2,(A2)+
        AND     D0,(A2)
        OR      D3,(A2)+
        AND     D0,(A2)
        OR      D4,(A2)+
L0L12:
        ADDA    #160,A3
        ADDA    #40,A4
L0L3:
        MOVE    -6(A6),D7
        BLT     L0L1                ;rien a aficher
        SUBQ    #1,14(A6)
        BGE     L0L4
L0L6:
        BRA     L0L1
;************************* SANS DECALAGE ***********************************
L0LEQ:
        SUBQ    #1,-6(A6)
        SUBQ    #1,10(A0)
        BSR     FILLSPRT
        BRA     L0LEQ3
L0LEQ4:
        MOVE.L  A3,A1
        MOVE.L  A4,A5
L0LEQ9:
        MOVEM   (A1)+,D1-D4
        MOVE    D1,D0
        AND     D2,D0
        AND     D3,D0
        AND     D4,D0
        MOVE    (A5)+,D5
        NOT     D5
        OR      D5,D0 
        NOT     D0
        AND     D0,D1
        AND     D0,D2
        AND     D0,D3
        AND     D0,D4
        NOT     D0
        AND     D0,(A2)
        OR      D1,(A2)+
        AND     D0,(A2)
        OR      D2,(A2)+
        AND     D0,(A2)
        OR      D3,(A2)+
        AND     D0,(A2)
        OR      D4,(A2)+
L0LEQ8:
        DBF     D7,L0LEQ9
        ADDA    #160,A3
        ADD     #40,A4
L0LEQ3:
        MOVE    -6(A6),D7
        BLT     L0L1
        SUBQ    #1,14(A6)
        BGE     L0LEQ4
L0L1:
        MOVEM.L (A7)+,a0-a5/d0-d7
        UNLK    A6
        RTS
adr_sprt:     blk.l    1,0     ;adresse page ecran des sprites souris
tab_clav:     blk.l    1,0     ;adresse tampon clavier souris
admask:       blk.l    1,0
adphys:       blk.l    1,0     ;ecran physique
ad1cran:      blk.l    1,0     ;adresse ecran d'affichage
ecrbuf:       blk.l    1,0     ;buffer d'ecran
adecran:      blk.l    1,0     ;adresse affichage menus et textes et lignes
flgecran:     blk.l    1,0     ;flag pour affiche sur un ou deux ecrans
num_sprt:     dc.w    0     ;numero en cours dans la liste
delai:        dc.w    0     ;vitesse d'animation
curdel:       dc.w    0     ;compteur interne de vitesse
flag_mous:    dc.w    0     ;hide show etc...
flag1mous:    dc.w    0     ;en flip-flop 0 on doit effacer -1 on doit afficher
old_pos:      blk.w   2,0
numani:       dc.w    0
norm1sour:    dc.w    000,008,016,024,032,040,048,056,064,072    ;16 pts haut
              dc.w    080,088,096,104,112,120,128,136,144,152
norm2sour:
deltaxy:      dc.l    0
coordsour:    dc.w    7,0,10,1,0,0,0,0,7,7,5,1
numlist:      dc.w    0,2,9,17,23,25
listsour:     dc.w    0,-1                           ;; 0  <=> Black secte
              dc.w    0160,0320,0480,0640            ;; 1  <=> main animee
              dc.w    0640,0640
              dc.w    -1
              dc.w    1440,1120,1280,0960            ;; 3  <=> livre
              dc.w    0800,0800,0800
              dc.w    -1
              dc.w    1600,1760,1920,2080            ;; 6  <=> cloche
              dc.w    2240
              dc.w    -1
              dc.w    2400                           ;; 9  <=> Loupe
              dc.w    -1
              dc.w    3040,2880,2720,2560            ;; 10 <=> main objet
              dc.w    2560,2560,2560
              dc.w    -1
adr_lst:      blk.l   1,0                            ;;adresse liste d'animation

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;               DEPLACE ZONE RECTANGULAIRE
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MOVBLK:
    link     A6,#0
    movem.l  D0-D7/A0-A5,-(A7)
    move.l   28(A6),A1          ;ecran source
    move.l   24(A6),A0          ;ecran dest
    move.w   10(A6),D1          ;y1
    move.w   18(A6),D0          ;y0
    sub.w    D0,D1
    mulu     #160,D0
    adda.w   D0,A0
    adda.w   D0,A1
    move.w   22(A6),D0          ;x0
    lsr.w    #1,D0
    andi.w   #-8,D0
    adda.w   D0,A0              ;adr base
    adda.w   D0,A1
    move.w   14(A6),D2
    lsr.w    #1,D2
    andi.w   #-8,D2
    sub.w    D0,D2              ;largeur
    lsr.w    #3,D2
    move.w   22(A6),D0
    andi.w   #15,D0
    moveq    #-1,D3
    lsr.w    D0,D3
    not.w    D3                 ;masque gauche
    move.w   D3,D0
    swap     D3
    move.w   D0,D3              ;pour 2 plans
    move.w   14(A6),D0
    andi.w   #15,D0
    move.w   #$8000,D4
    asr.w    D0,D4              ;masque droit
    not.w    D4
    move.w   D4,D0
    swap     D4
    move.w   D0,D4
    tst.w    D2
    bne.s    lc11
    or.w     D3,D4              ;mixe masques
    move.l   D4,D3
    not.l    D3
lc12:
    move.l   (A1)+,D5
    and.l    D3,D5
    and.l    D4,(A0)
    or.l     D5,(A0)+
    move.l   (A1),D5
    and.l    D3,D5
    and.l    D4,(A0)
    or.l     D5,(A0)
    adda     #156,A0
    adda     #156,A1
    dbf      D1,lc12
    bra      lc13

lc11:
    subq.w   #1,D2
    moveq    #19,D0
    subq.w   #1,D0
    sub.w    D2,D0
    lsl.w    #3,D0
    move.w   D2,22(A6)
lc16:
    move.w   22(A6),D2
    move.l   D3,D6
    not.l    D6
    move.l   (A1)+,D5
    and.l    D6,D5
    and.l    D3,(A0)
    or.l     D5,(A0)+
    move.l   (A1)+,D5
    and.l    D6,D5
    and.l    D3,(A0)
    or.l     D5,(A0)+
    bra.s    lc15
lc14:
    move.l   (A1)+,(A0)+
    move.l   (A1)+,(A0)+
lc15:
    dbf      D2,lc14
    move.l   D4,D6
    not.l    D6
    move.l   (A1)+,D5
    and.l    D6,D5
    and.l    D4,(A0)
    or.l     D5,(A0)+
    move.l   (A1)+,D5
    and.l    D6,D5
    and.l    D4,(A0)
    or.l     D5,(A0)+
    add.w    D0,A0
    add.w    D0,A1
    dbf      D1,lc16
lc13:
    movem.l  (A7)+,D0-D7/A0-A5
    unlk     A6
    move.l   (A7),24(A7)
    lea      24(A7),A7
    rts

blocmask:
  MULU      #$A0,D1
  MOVE.W    D0,D4
  ASR.W     #1,D0
  AND.W     #-8,D0
  ADD       D0,D1
  ADDA.W    D1,A1         ;; adresse debut de ligne
  LSR       #2,D1         ;POUR MASQUE
  MOVE.L    admask(PC),A2     ;     '
  ADDA      D1,A2         ;     '

  AND.W     #15,D4
  MOVE.W    #-1,D3
  LSR.W     D4,D3
  MOVE.W    D3,D6
  SWAP      D6
  MOVE.W    D3,D6   ;; mask debut de ligne

  MOVE.W    D2,D3
  ASR.W     #1,D2
  AND.W     #-8,D2
  SUB.W     D0,D2
  LSR.W     #3,D2   ;;; D2 = nombre mots de la ligne

  AND.W     #15,D3
  MOVE.W    #$8000,D4
  ASR.W     D3,D4 
  MOVE.W    D4,D3
  SWAP      D4
  MOVE.W    D3,D4   ;; mask de fin de ligne
  MOVE.W    D2,nbmotbl
  MOVE.W    D2,D0
  LSL.W     #3,D0
  SUB.W     #152,D0
  NEG.W     D0
  MOVE.W    D0,nboctbl
  LSR.W     #2,D0
  MOVE.W    D0,nb1octbl
  TST.W     D2
  BNE.S     blmsk1
  AND.L     D6,D4    ;;mixe les deux masques
blmsk2:
  MOVEM.L   (A0)+,D0-D1  ;matrice de remplissage 4 plans
  ADDQ      #2,A0
  AND.L     D4,D0
  AND.L     D4,D1
  NOT.L     D4
  AND.W     D4,(A2)+
  AND.L     D4,(A1)  ;; maskage de la destination
  OR.L      D0,(A1)+
  AND.L     D4,(A1)  ;; maskage de la destination
  OR.L      D1,(A1)+
  NOT.L     D4
  LEA       38(A2),A2
  LEA       152(A1),A1
  DBF       D7,blmsk2  
  RTS
blmsk1:
  SUBQ.W    #1,D2
blmsk3:
  MOVEM.L   (A0)+,D0-D1  ;matrice de remplissage plans 0 et 1
  ADDQ      #2,A0
  MOVE.L    D0,D3
  MOVE.L    D1,D5
  AND.L     D6,D3
  AND.L     D6,D5
  NOT.L     D6
  AND.W     D6,(A2)+
  AND.L     D6,(A1)  ;; maskage de la destination
  OR.L      D3,(A1)+
  AND.L     D6,(A1)  ;; maskage de la destination
  OR.L      D5,(A1)+
  NOT.L     D6
  BRA       blmsk4
blmsk5:
  MOVE.L    D0,(A1)+
  MOVE.L    D1,(A1)+
  CLR.W     (A2)+
blmsk4:
  dbf       D2,blmsk5 
  AND.L     D4,D0
  AND.L     D4,D1
  NOT.L     D4
  and.w     D4,(a2)+
  AND.L     D4,(A1)  ;; maskage de la destination
  OR.L      D0,(A1)+
  AND.L     D4,(A1)  ;; maskage de la destination
  OR.L      D1,(A1)+
  NOT.L     D4
  move.w    nbmotbl(PC),D2
  add       nboctbl(PC),A1
  add       nb1octbl(PC),A2       
  dbf       D7,blmsk1
  RTS
nb1octbl:
  dc.w      0
affibloc:
  MULU      #$A0,D1
  MOVE.W    D0,D4
  ASR.W     #1,D0
  AND.W     #-8,D0
  ADD       D0,D1
  ADDA.W    D1,A1   ;; adresse debut de ligne

  AND.W     #15,D4
  MOVE.W    #-1,D3
  LSR.W     D4,D3
  MOVE.W    D3,D6
  SWAP      D6
  MOVE.W    D3,D6   ;; mask debut de ligne

  MOVE.W    D2,D3
  ASR.W     #1,D2
  AND.W     #-8,D2
  SUB.W     D0,D2
  LSR.W     #3,D2   ;;; D2 = nombre mots de la ligne

  AND.W     #15,D3
  MOVE.W    #$8000,D4
  ASR.W     D3,D4 
  MOVE.W    D4,D3
  SWAP      D4
  MOVE.W    D3,D4   ;; mask de fin de ligne
  MOVE.W    D2,nbmotbl
  MOVE.W    D2,D0
  LSL.W     #3,D0
  SUB.W     #152,D0
  NEG.W     D0
  MOVE.W    D0,nboctbl
  TST.W     D2
  BNE.S     adr86
  AND.L     D6,D4    ;;mixe les deux masques
adr84:
  MOVEM.L   (A0)+,D0-D1  ;matrice de remplissage plans 0 et 1
  ADDQ      #2,A0
  AND.L     D4,D0
  AND.L     D4,D1
  NOT.L     D4
  AND.L     D4,(A1)  ;; maskage de la destination
  OR.L      D0,(A1)+
  AND.L     D4,(A1)  ;; maskage de la destination
  OR.L      D1,(A1)+
  NOT.L     D4
  LEA       152(A1),A1
  DBF       D7,adr84  
  RTS
adr86:
  SUBQ.W    #1,D2
adr80:
  MOVEM.L   (A0)+,D0-D1  ;matrice de remplissage plans 0 et 1
  ADDQ      #2,A0
  MOVE.L    D0,D3
  MOVE.L    D1,D5
  AND.L     D6,D3
  AND.L     D6,D5
  NOT.L     D6
  AND.L     D6,(A1)  ;; maskage de la destination
  OR.L      D3,(A1)+
  AND.L     D6,(A1)  ;; maskage de la destination
  OR.L      D5,(A1)+
  BRA       adr81
adr82:
  MOVE.L    D0,(A1)+
  MOVE.L    D1,(A1)+
adr81:
  dbf       D2,adr82 
  AND.L     D4,D0
  AND.L     D4,D1
  NOT.L     D4
  AND.L     D4,(A1)  ;; maskage de la destination
  OR.L      D0,(A1)+
  AND.L     D4,(A1)  ;; maskage de la destination
  OR.L      D1,(A1)+
  NOT.L     D4
  NOT.L     D6
  move.w    nbmotbl(PC),D2
  add       nboctbl(PC),A1       
  dbf       D7,adr86
adr60:
  RTS
nbmotbl:
  dc.w 0
nboctbl:
  dc.w 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;               EFFACE UNE PORTION D'ECRAN
;;               parametres: ad_ecran, x0,y0, x1,y1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CLRBLK:
    link     A6,#0
    movem.l  D0-D7/A0-A5,-(A7)
    move.l   24(A6),A0
    move.w   10(A6),D1          ;y1
    move.w   18(A6),D0          ;y0
    sub.w    D0,D1
    mulu     #160,D0
    adda.w   D0,A0  
    move.w   22(A6),D0          ;x0
    lsr.w    #1,D0
    andi.w   #-8,D0
    adda.w   D0,A0              ;adr base
    move.w   14(A6),D2          ;x1
    lsr.w    #1,D2
    andi.w   #-8,D2
    sub.w    D0,D2              ;largeur
    lsr.w    #3,D2
    move.w   22(A6),D0
    andi.w   #15,D0
    move.w   #-1,D3
    lsr.w    D0,D3
    not.w    D3                 ;masque gauche
    move.w   D3,D0
    swap     D3
    move.w   D0,D3              ;pour 2 plans
    move.w   14(A6),D0
    andi.w   #15,D0
    move.w   #$8000,D4
    asr.w    D0,D4              ;masque droit
    not.w    D4
    move.w   D4,D0
    swap     D4
    move.w   D0,D4
    tst.w    D2
    bne.s    lc01
    or.w     D3,D4              ;mixe masques
lc02:
    and.l    D4,(A0)+
    and.l    D4,(A0)
    adda     #156,A0
    dbf      D1,lc02
    bra      lc03

lc01:
    moveq    #18,D0
    subq.w   #1,D2
    sub.w    D2,D0
    lsl.w    #3,D0
    move.w   D2,22(A6)
lc06:
    move.w   22(A6),D2
    and.l    D3,(A0)+
    and.l    D3,(A0)+
    bra.s    lc05
lc04:
    clr.l    (A0)+
    clr.l    (A0)+
lc05:
    dbf      D2,lc04
    and.l    D4,(A0)+
    and.l    D4,(A0)+
    add.w    D0,A0
    dbf      D1,lc06
lc03:
    movem.l  (A7)+,D0-D7/A0-A5
    unlk    A6
    move.l   (A7),20(A7)
    lea      20(A7),A7
    rts
;;
        
BOITE:
    RTS

          
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;               AFFICHE LES MENUS
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
COPBLK:
    move.l   ecrbuf(PC),A0
    move.l   adphys(PC),A1
    mulu     #160,D1
    lsr      #1,D0
    andi.w   #-8,D0
    add      D0,D1
    adda     D1,A0
    adda     D1,A1
    lsr      #1,D2
    andi.w   #-8,D2
    sub.w    D0,D2
    move.w   #160,D0
    sub.w    D2,D0
    lsr      #3,D2      ;largeur
    subq     #1,D2
dcoph:
    move.w   D2,D4
dcopl:
    move.l   (A0)+,(A1)+
    move.l   (A0)+,(A1)+
    dbf      D4,dcopl
    adda     D0,A0
    adda     D0,A1
    dbf      D3,dcoph
    rts
;;;;;;;;;;;;;;;;;;;;;; AFFICHAGE MENUS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;   si adr_lng == -1 (adr table longueur) convertit et affiche un nombre
;;                       compris entre 0 et 9999 place dans tab_adr
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
tabdiv:
    dc.w     1000,100,10,1,0
conv0int:
    move     adr_lng+2(pc),D0
    add      #4,d0
    add      d0,d0
    lea      tabdiv(PC,d0.w),A1
    moveq    #0,D0        ;larg chaine affiche
    move.l   adr_buf(PC),A0
    move.l   adr_tab(PC),D1
xconvint4:
    divu     (A1)+,D1
    add.w    #8,D0
    add.w    #53,D1     ;'0' dans cette fonte
    move.b   D1,(A0)+
    clr.w    D1
    swap     D1
    tst.w    (A1)
    bne.s    xconvint4
    clr.b    (A0)
    rts
convint:
    moveq    #0,D0        ;larg chaine affiche
    move.l   adr_buf(PC),A0
    move.l   adr_tab(PC),D1
    beq.s    convint1
    clr.w    D2
    lea      tabdiv(PC),A1
convint4:
    divu     (A1)+,D1
    bne.s    convint2
    tst.w    D2
    bne.s    convint2
    swap     D1
    bra.s    convint4
convint2:
    add.w    #8,D0
    add.w    #53,D1
    move.b   D1,(A0)+
    clr.w    D1
    swap     D1
    moveq    #1,D2
    tst.w    (A1)
    beq.s    convint3
    bra.s    convint4
convint1:
    move.b   #53,(A0)+
    moveq    #7,D0
convint3:
    clr.b    (A0)
    rts
AFMEN:
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;              AFFICHAGE CHAINE COMPRESSEE
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

AFTEXT:
  movem.l  d0-d7/a0-a6,-(a7)
  lea      highbox(pc),a0
  move.w   54+60(A7),highbox-highbox(a0)
  move.l   48+60(A7),adr_tab-highbox(a0)
  move.l   44+60(A7),adr_lng-highbox(a0)
  move.l   40+60(A7),adr_buf-highbox(a0)
  move.l   36+60(A7),adecran-highbox(a0)
  move.w   34+60(A7),xecri-highbox(a0)
  move.w   30+60(A7),yecri-highbox(a0)
  move.w   26+60(A7),lngbox-highbox(a0)
  move.w   22+60(A7),interlig-highbox(a0)
  move.l   16+60(A7),couleur-highbox(a0)
  move.l   12+60(A7),effet-highbox(a0)
  move.w   10+60(A7),flg_aff-highbox(a0)
  move.l   4+60(A7),numero-highbox(a0)
  move.l   adr_buf(PC),A0
  moveq    #24,d0
ct1:
  clr.l    (A0)+
  dbf      D0,ct1
  move.l   adpolice(PC),A0      ;;init police
  lea      fontdata(PC),A1
  move.l   A0,D0
  move.l   92(A0),(A1)          ;;adresse police
  add.l    D0,(A1)
  lea      fontloc(PC),A1
  move.l   98(A0),(A1)          ;;table de decalage
  add.l    D0,(A1)
  lea      fontspace(PC),A1
  move.l   102(A0),(A1)         ;;table d'emcombrement
  add.l    D0,(A1)
  lea      fontkern(PC),A1
  move.l   106(A0),(A1)         ;;table d'emcombrement
  add.l    D0,(A1)
  tst.l    adr_lng
  bge.s    aftxt1
  cmpi.l   #-1,adr_lng
  beq.s    etiqplouf
  bsr      conv0int              ;convertit entier en chaine formatee
  bsr      aftmenu
  bra.s    aftxt2
etiqplouf:
  bsr      convint              ;convertit entier en chaine
  bsr      aftmenu
  bra.s    aftxt2
aftxt1:
  bsr      afftxt0
aftxt2:
  movem.l  (A7)+,D0-D7/A0-A6
  move.l   (A7),52(A7)         
  lea      52(A7),A7            ;;depile pour le PASCAL
  rts
afftxt0:
  clr.b    flpart
  move.w   numero+2(PC),D1
  move.l   adr_buf(PC),A3
  clr.l    adr1buf
deb1long:
  move.l  adr_tab(PC),A0       ;;adresse de base des chaines de caractere
  move.l  adr_lng(PC),A1       ;;table des longueurs de chaines
  subq.w   #1,D1
  moveq    #0,D3
  bra.s    fin_long
deb_long:
  add.w    (A1)+,D3
fin_long:
  dbf      D1,deb_long
  adda.w   D3,A0       ;adresse de debut de la chaine
  move.w   (A1),D0     ;longueur de la chaine
  move.w   D0,D1       ;sauve longueur
  lea      tabcod1(PC),A2
debdecomp:
  move.b   (A0)+,D2
  lsl.l    #8,D2
  move.b   (A0)+,D2
  lsl.l    #8,D2
  move.b   (A0)+,D2
  lsl.l    #8,D2
  move.b   (A0)+,D2
  move.b   (A0)+,D3
  lea      bufinter+8(PC),A1
  subq.w   #5,D1
  bge.s    suidecomp
  clr.b    D3
  cmpi.w   #-1,D1
  bge.s    suidecomp
  clr.b    D2
  cmpi.w   #-2,D1
  bge.s    suidecomp
  clr.w    D2
  cmpi.w   #-3,D1
  bge.s    suidecomp
  andi.l   #$ff00ffff,D2
  cmpi.w   #-4,D1
  bge.s    suidecomp
  clr.l    D2
suidecomp:
  move.b   D3,-(A1)
  andi.b   #31,(A1)
  lsr.b    #5,D3
  move.b   D2,D4
  andi.b   #3,D4
  lsl.b    #3,D4
  or.b     D4,D3
  move.b   D3,-(A1)
  lsr.l    #2,D2
  move.b   D2,D3
  andi.b   #31,D3
  move.b   D3,-(A1)
  moveq    #4,D4
decal:
  lsr.l    #5,D2
  move.b   D2,D3
  andi.b   #31,D3
  move.b   D3,-(A1)
  dbf      D4,decal
  moveq    #7,D5
decode:
  move.b   (A1)+,D2
  beq      fincod
  cmpi.b   #29,D2
  ble.s    codnorm
  cmpi.b   #30,D2
  bne.s    vtab2
  lea      tabcod2(PC),A2
  bra.s    codsuiv
vtab2:
  lea      tabcod3(PC),A2
  bra.s    codsuiv
codnorm:
  ext.w    D2
  move.b   0(A2,D2.W),(A3)+
  lea      tabcod1(PC),A2
codsuiv:
  dbf      D5,decode
  tst.w    D1
  ble      fincod
  bra      debdecomp
fincod:
  clr.b    (A3)+                ;marque la fin de la chaine a afficher
  move.w   numero(PC),D1
  beq.s    fin1cod
  blt.s    finpcod
  clr      numero
  move.l   A3,adr1buf
  bra      deb1long
finpcod:
        clr     numero
        move.b  #1,flpart
        neg.w   d1
        subq.w  #1,d1
        lea.l   nopart(pc),a0
        move.b  0(a0,d1.w),d1
        lea.l   16(a0),a0
        add.w   d1,a0
        move.b  (a0)+,qtpart
        move.l  a0,adpart
fin1cod:
  move.l   adr_buf(PC),A0       ;adresse debut chaine decompressee
  move.w   lngbox(PC),D1        ;largeur de la boite
  move.l   fontspace(PC),A1     ;table d'emcombrement
  tst.w    flg_aff
  beq      deblig
  clr.w    D1
debmod1:
  clr.w    D0
  move.b   (A0)+,D0
  beq      finmod1
  add.w    D0,D0
  add.w    -2(A1,D0.W),D1
  bra.s    debmod1
finmod1:
  move.w   D1,largtxt
  rts                  ;;;;;;;; fin et retourne largeur
flpart: dc.b    0
qtpart: dc.b    0
adpart: dc.l    0
nopart: dc.b    98,34,9,78,66,14,69,12,72,76,10,3,24,0,88,0
spart1: dc.b    4,1,2,2,0,1,3,2,4,1,2,2,0,1,1,3
        dc.b    1,1,1,1,2,1,2,1,2,1,1,3,2,0,2,1
        dc.b    3,2,2,2,2,1,2,1,5,1,1,2,0,2,1,2
        dc.b    4,1,3,0,2,0,3,1,1,1,2,2,3,0,5,4,-1,-1
spart2: dc.b    1,2,1,0,3,1,0,2,3,1,0,1,2,3,1,3
        dc.b    2,0,1,1,1,1,2,1,2,1,1,2,0,0,1,0
        dc.b    2,3,1,2,2,0,4,1,3,2,2,2,0,2,1,3
        dc.b    7,5,3,0,1,1,4,2,4,0,0,10,3,2,0,0,-1,-1
;;;; affiche chaine decompresse ;;;
aftmenu:
  move.l   adr_buf(PC),A0       ;adresse debut chaine decompressee
  move.w   xecri(PC),D4
debtxtmenu:
  clr.w    D0
  move.b   (A0)+,D0
  beq.s    fintxtmenu
  subq.w   #1,D0
  add.w    D0,D0
  cmpi.w   #194,D0
  bgt.s    menu01
  bsr      rout_car
  move.l   fontspace(PC),A1
  add.w    0(A1,D0.W),D4
menu01:
  bra.s    debtxtmenu
fintxtmenu:
  rts                  ;;;;; fin affichage du texte                 
deblig:
  tst.w    highbox
  blt      pashaut
  clr.w    D0
  clr.w    D4
  clr.w    D2
  clr.w    D3           ;nb caracteres a afficher sur une ligne
  move.l  A0,A3        ;conserve premier caractere a afficher
hdebcent:
  move.b   (A3)+,D4
  bne.s    hpaszer
  tst.w    D3           ;incertitude sur la longueur
  beq      hfincent
  addq.w   #1,D0        ;nombre de lignes
  bra      hfincent
hpaszer:
  add.w    D4,D4
  subq.w   #2,D4
  cmpi.w   #200,D4      ;retour chariot
  bne.s    hsuit1
  addq.w   #1,D0        ;nombre de lignes
  clr.w    D3
  bra      hdebcent
hsuit1:
  add.w    0(A1,D4.W),D3
  cmp.w    lngbox(PC),D3
  blt      hdebcent     ; a cause de cette heure-ci
  addq.w   #1,D0        ; nombre de lignes
  clr.w    D3
  bra      hsuit1 
hfincent:
  mulu     interlig(PC),D0
  sub.w    highbox(PC),D0
  neg.w    D0
  asr.w    #1,D0
  addq.w   #1,D0
  add.w    D0,yecri
pashaut:
  clr.w    D0
  clr.w    D4
  clr.w    D2
  clr.w    D3           ;nb caracteres a afficher sur une ligne
  move.l  A0,A3        ;conserve premier caractere a afficher
  move.l  A0,A2
  adda     #20,A2
blctail:
  move.b   (A0)+,D4
  bne.s    nonzero
  tst.w    D3
  beq      fintail      ;plus de caracteres a afficher
  bsr      afftxt
  bra      fintail
nonzero:
  subq.b   #1,D4
  cmpi.b   #75,D4      ;espace
  bne.s    nonspace
  move.l  A0,A2      ;stocke position dernier blanc + 1
  move.w   D0,D5
nonspace:
  cmpi.b   #100,D4    ;caractere #:retour chariot code en 101
  bne.s    suitail    ;pas de justification dans ce cas
  move.w   justif(PC),-(A7)
  bgt.s    xjust
  lea      justif(PC),A5
  clr.w    (A5)
xjust:
  bsr      afftxt
  lea      justif(PC),A3
  move.w   (A7)+,(A3)
  bra      pashaut
suitail:
  addq.w   #1,D3
  add.w    D4,D4
  move.w   effet(PC),D2
  btst     #0,D2
  beq.s    propor
  cmpi.w   #76*2,D4      ;tabulation de 5 espaces
  bne.s    pastab1
  move.l   adpolice(PC),A0
  move.w   82(A0),D2
  add.w    D2,D0
  add.w    D2,D2
  add.w    D2,D2
  add.w    D2,D0
  bra.s    nonpropor
pastab1:
  move.l   A0,-(A7)
  move.l   adpolice(PC),A0
  add.w    82(A0),D0
  move.l   (A7)+,A0
  bra.s    nonpropor
propor:
  move.w   0(A1,D4.W),D2
  cmpi.w   #76*2,D4
  bne.s    pastab2
  add.w    D2,D0
  add.w    D2,D2
  add.w    D2,D2
pastab2:
  add.w    D2,D0         ;largeur ligne
nonpropor:
  cmp.w    D1,D0         ;largeur encadrement
  blt      blctail
  addq.w   #2,D5
  move.w   D5,D0
  subq.l   #1,A2
  move.l  A2,A0
veraff:
  bsr      afftxt        ;A3 adresse premier caractere
  addq.l   #1,A0
  bra      pashaut
; c'est la fin de la routine
fintail:
  rts
afftxt:
  movem.l  D0-D7/A0-A5,-(A7)
  lea      nbcar1(PC),A5    ;efface nbcar1 nbcar2
  clr.l    (A5)+        ;nbcar3 nbpts1
  clr.l    (A5)+        ;idem
  move.w   justif(PC),D3
  blt      totjust
  clr.w    (A5)         ;efface nbpts2
  bra      nonjust
totjust:
  move.w   #1,(A5)
  clr.w    D4
  move.l   A0,D3        ;dernier caractere
  sub.l    A3,D3        ;moins premier
  subq.w   #2,D3        ;moins 2 = nombre d'espaces entre lettres
  ble.s    nondiv
  move.w   D1,D4
  sub.w    D0,D4        ;nombre de points a ajouter
  ble.s    cadrgauch    ;si pas de points a ajouter
  divu     D3,D4        ;mot fort = nb points en trop restant, mot faible nb points a mettre entre deux caracteres
  swap     D4
  tst.w    D4
  bne.s    verdiv
  clr.l    D3
  bra.s    nondiv
verdiv:
  divu     D4,D3        ;mot fort = nb d'espaces avant de commencer ajout, mot faible nb spaces entre ajouts consecutifs
  add.l    #$10000,D3
nondiv:
  lea      nbcar2(PC),A5
  move.l   D3,(A5)+
  swap     D4
  move.w   D4,(A5)
nonjust:
  move.w   justif(PC),D3
  bgt.s    cadrcentr
  clr.w    D4
  bra.s    cadrgauch
cadrcentr:
  move.w   D1,D4
  sub.w    D0,D4
  bge.s    cadrok
  clr.w    D4
cadrok:
  lsr.w    #1,D4        ;nombre de points a gauche
; A2 adr 1er caractere A0 dernier + 1
cadrgauch:
  add.w    xecri(PC),D4     ;abscisse de depart ecriture
blafftxt:
  clr.w    D0
  move.b   (A3)+,D0
  beq      afffin
  cmpa.l   A3,A0
  blt      afffin
suitaff:
  subq.w   #1,D0             ;;;;;;;;;
  add.w    D0,D0
affcar:
  cmpi.w   #196,D0
  bgt.L    noncar
  cmpi.w   #76*2,D0
  beq.s    noncar1
  tst.b    flpart
  bne.s    trtpart
  move.l   adr1buf,D2
  beq.s    noncar2
  move.l   D2,A1
  move.b   (A1)+,D2
  subq     #1,D2
  ext.w    D2
  add      D2,D2
  cmp      D2,D0
  bne.s    noncar2
  move.l   A1,adr1buf
  bra.s    copart
trtpart:
        cmp.w   #150,d0
        beq.s   noncar2
        subq.b  #1,qtpart
        bge.s   noncar2
        move.l  adpart(pc),a1
        move.b  (a1)+,qtpart
        bge.s   tr2par
        sub.l   #65,a1
        move.b  (a1)+,qtpart
tr2par: move.l  a1,adpart        
copart:
  move.l   couleur,D2
  swap     D2
  move.l   D2,couleur
  bsr      rout_car
  swap     D2
  move.l   D2,couleur
  bra.s    noncar
noncar2:
  bsr      rout_car
  bra.s    noncar
noncar1:
  move.l   fontspace(PC),A1
  move.w   0(A1,D0.W),D2
  add.w    D2,D4
  add.w    D2,D2
  add.w    D2,D2
noncar:
  move.l   fontspace(PC),A1
  move.w   0(A1,D0.W),D2
  move.w   effet(PC),D0
  btst     #0,D0
  beq.s    affpro
  move.l   A0,-(A7)
  move.l   adpolice(PC),A0
  move.w   82(A0),D2
  move.l   (A7)+,A0
affpro:
  lea      nbcar1(PC),A5
  addq     #1,(A5)
  add.w    nbpts1(PC),D2          ;nombre de points en plus de chaque espace
  move.w   nbcar2(PC),D7
  cmp.w    nbcar1(PC),D7
  bne      suipro
  add.w    nbpts2(PC),D2
  clr.w    (A5)
  move.w   nbcar3(PC),2(A5)       ;2(A5) en nbcar2
suipro:
  add.w    D2,D4              ;nouvelle position d'ecriture
  bra      blafftxt
afffin:
  move.w   interlig(PC),D7
  lea      yecri(PC),A0
  add.w    D7,(A0)
  movem.l  (A7)+,D0-D7/A0-A5
  rts
;nombre de caracteres en cours affichage
nbcar1:    
  dc.w 0
;nb caracteres avant premier espace
nbcar2:    
  dc.w 0
;nb caracteres en chaque point
nbcar3:
  dc.w 0
;nb de points entre deux caracteres consecutifs
nbpts1:
  dc.w 0
;points a ajouter de temps en temps
nbpts2:
  dc.w 1
rout_car:
  movem.l D0-D7/A0-A5,-(A7)
  link    A6,#-10
  move.l  adpolice(PC),A0
  move.w  96(A0),-10(A6)
  move.w  78(A0),-8(A6)
  move.l  fontkern(PC),A1
  move.w  0(A1,D0.W),D5
  add.w   D0,D0
  move.l  fontloc(PC),A1
  move.w  0(A1,D0.W),D1  ;position binaire
  move.w  2(A1,D0.W),D2  ;largeur
  beq     end_car        ;si 0 rien a afficher
deb:
  move.w  D1,D3
  lsr.w   #4,D1          ;mot debut
  add.w   D1,D1
  andi.w  #15,D3         ;bit dans le premier mot
  move.l  #-1,D6
  lsr.l   D3,D6          ;masque gauche
  add.w   D3,D2
  subq.w  #1,D2
  move.l  #$80000000,D7
  asr.l   D2,D7          ;masque droit
  and.l   D7,D6          ;mixe les deux masques
  move.w  D5,D0
  add.w   D4,D0          ;xecri
  move.w  D0,D2          ;  '
  lsr.w   #1,D2
  andi.w  #-8,D2
  andi.w  #15,D0         ;position affichage en bits
  sub.w   D0,D3          ;valeur de rotation + ou -
  move.l  fontdata(PC),A1
  adda.w  D1,A1
  move.l A1,A0  
  move.l adecran(PC),A2
  move.w  yecri(PC),D0
  mulu    #160,D0
  add.w   D2,D0
  adda.w  D0,A2
  move.l A2,A3
  move.w  -8(A6),D0
  subq.w  #1,D0
  move.w  couleur+2(PC),D4
  lea     decalgd(PC),A1
  move.w  decalg(PC),(A1)
  tst.w   D3
  bgt.s   codegauch
  neg.w   D3
  move.w  decald(PC),(A1)
codegauch:
  cmp.w   oldcolt(PC),D4
  beq     plan7gd
  move.w  D4,oldcolt
  lea     codecar(PC),A1
  lea     ecrg1(PC),A2
  lea     ecrg2(PC),A4
  btst    #0,D4
  beq.s   plan0gd
  move.l  (A1),(A2)+
  move.l  (A1),(A4)+
  bra.s   plan1gd
plan0gd:
  move.l  4(A1),(A2)+
  move.l  4(A1),(A4)+
plan1gd:    
  btst    #1,D4
  beq.s   plan2gd
  move.l  (A1),(A2)+
  move.l  (A1),(A4)+
  bra.s   plan3gd
plan2gd:
  move.l  4(A1),(A2)+
  move.l  4(A1),(A4)+
plan3gd:    
  btst    #2,D4
  beq.s   plan4gd
  move.l  (A1),(A2)+
  move.l  (A1),(A4)+
  bra.s   plan5gd
plan4gd:
  move.l  4(A1),(A2)+
  move.l  4(A1),(A4)+
plan5gd:    
  btst    #3,D4
  beq.s   plan6gd
  move.l  (A1),(A2)+
  move.l  (A1),(A4)+
  bra.s   plan7gd
plan6gd:
  move.l  4(A1),(A2)+
  move.l  4(A1),(A4)+
plan7gd: 
  move.w  #160,D4
  move.w  -10(A6),D1
debletg:
  move.l A0,A1
  move.l A3,A2
debligg:
  move.l  (A1)+,D5
  and.l   D6,D5
decalgd:
  lsl.l   D3,D5        ;donnee a afficher
  swap    D5
  move.l  D5,D7
  not.l   D7
  tst.w   D5
  bne.s   ecrg1
  lea     8(A2),A2
  bra.s   ecrg4
ecrg1:
  and.w   D7,(A2)
  or.w    D5,(A2)+
  and.w   D7,(A2)
  or.w    D5,(A2)+
  and.w   D7,(A2)
  or.w    D5,(A2)+
  and.w   D7,(A2)
  or.w    D5,(A2)+
ecrg4:
  swap    D5
  tst.w   D5
  beq.s   ecrg5   
  swap    D7
ecrg2:
  and.w   D7,(A2)
  or.w    D5,(A2)+
  and.w   D7,(A2)
  or.w    D5,(A2)+
  and.w   D7,(A2)
  or.w    D5,(A2)+
  and.w   D7,(A2)
  or.w    D5,(A2)+
ecrg5:
  adda.w  D1,A0
  adda.w  D4,A3
  dbf     D0,debletg
end_car:
  unlk    A6
  movem.l (A7)+,D0-D7/A0-A5
  rts
codecar:
  and.w   D7,(A2)
  or.w    D5,(A2)+
  and.w   D7,(A2)+
  nop
decalg:
  lsl.l   D3,D5
decald:
  lsr.l   D3,D5
largtxt:
  dc.w   0
bufinter:
  blk.b   16,0
adr_tab:
  dc.l  0
adr_lng:
  dc.l  0
adr_buf:
  dc.l  0
adr1buf:
  dc.l  0
numero:
  dc.l  0
mode:
  dc.w  0  ;si 0 texte normal si 1 texte pour longueur
effet:
  dc.w 0
justif:
  dc.w  0
xecri:
  dc.w 10
yecri:
  dc.w 0
interlig:
  dc.w 8
lngbox:
  dc.w 300
couleur:
  dc.l 0
oldcolt:
  dc.w 15
flg_aff:
  dc.w 0
highbox:
  dc.w 0
fontkern:
  dc.l  0       ;table decalage gauche/droite a l'affichage
fontspace:
  dc.l 0        ;table d'emcombrement a l'affichage
fontloc:
  dc.l 0        ;table de decalage et largeur dans fichier
fontdata:
  dc.l 0        ;data's police
adpolice:
  dc.l 0        ;;police de caractere

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;              TRACE DE LIGNES
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Routine generale ;
adr21:
  MOVE.W     D2,-(A7)
  MOVE.W     D3,-(A7)
  MULU       #$a0,D1  ;;nb octets par ligne
  MOVEQ      #1,D3
  MOVE.W     D0,D2
  AND.W      #$F,D0
  AND.W      #-$10,D2
  LSR.W      D3,D2
  ADD.W      D2,D1
  MOVE.W     (A7)+,D3
  MOVE.W     (A7)+,D2
  RTS

; trace ligne entre deux points $A003 ;
TRACLIGN:
  move.w     6(A7),couleur
  move.w     10(A7),yfin
  move.w     14(A7),xfin
  move.w     18(A7),ydeb
  move.w     22(A7),xdeb
  move.l     24(A7),adecran
  movem.l    D0-D7/A0-A6,-(A7)
  bsr        lign
  movem.l    (A7)+,D0-D7/A0-A6
  move.l     (A7),24(A7)
  lea        24(A7),A7
  rts
lign:  
  move.w     couleur(PC),D0
  cmp.w      oldcoll(PC),D0
  beq.s      lignx1
  move.w     D0,oldcoll
  lea        matremp(PC),A6
  move.l     #-1,D1
  moveq      #0,D2
  move.l     D1,(A6)
  move.l     D1,4(A6)
  btst       #0,D0
  bne.s      lignx2
  move.w     D2,(A6)
lignx2:
  btst       #1,D0
  bne.s      lignx3
  move.w     D2,2(A6)
lignx3:
  btst       #2,D0
  bne.s      lignx4
  move.w     D2,4(A6)
lignx4:
  btst       #3,D0
  bne.s      lignx1
  move.w     D2,6(A6)
lignx1:
  MOVE.L    adecran(PC),A5
  LEA        matremp(PC),A6
  MOVEQ      #4,D6              ;nombre de plans
  MOVE.W     D6,D3
  ASL.W      #1,D6
  SUBQ.W     #1,D3
  MOVE.W     #$a0,D7            ;nb octets par ligne
  MOVE.W     xfin(PC),D5
  SUB.W      xdeb(PC),D5
  BMI        adr23
  MOVE.W     xdeb(PC),D0
  MOVE.W     ydeb(PC),D1
  BSR        adr21
  ADDA.W     D1,A5
  MOVE.W     yfin(PC),D4
  SUB.W      ydeb(PC),D4
  BNE        adr24
  BRA        lign_h             ;; ligne horizontale
adr23:
  MOVE.W     xfin(PC),D0
  MOVE.W     yfin(PC),D1
  BSR        adr21
  ADDA.W     D1,A5
  NEG.W      D5
  MOVE.W     ydeb(PC),D4
  SUB.W      yfin(PC),D4
  BNE        adr24
  BRA        lign_h
adr24:
  BPL        adr28
  NEG.W      D4
  NEG.W      D7
adr28:
  ASL.W      #1,D0
  MOVE.W     adr29(PC,D0.W),D0
  CMP.W      D4,D5
  BMI        adr30
  MOVE.W     D5,D2
  ASL.W      #1,D4
  MOVE.W    D4,A3
  SUB.W      D5,D4
  MOVE.W    D4,A2
  SUBA.W     D5,A2
  MOVE.W     masklig(PC),D1
  MOVE.W     D0,D5
  NOT.W      D5
  BRA        adr37

adr29:
  dc.w  $8000,  $4000,  $2000,  $1000,  $0800,  $0400
  dc.w  $0200,  $0100,  $0080,  $0040,  $0020,  $0010
  dc.w  $0008,  $0004,  $0002,  $0001,  $0000,  $0000
adr37:
  MOVEM.W    D0-D2/D4-D5,-(A7)
  MOVE.L     A5,-(A7)
  TST.W      (A6)+
  BNE        adr32
  CLR.W      D1
adr32:
  ROL.W      #1,D1
  BCC        adr33
  OR.W       D0,(A5)
  BRA        adr34
adr33:
  AND.W      D5,(A5)
adr34:
  ROR.W      #1,D5
  ROR.W      #1,D0
  BCC        adr35
  ADDA.W     D6,A5
adr35:
  TST.W      D4
  BMI        adr36
  ADD.W      A2,D4
  ADDA.W     D7,A5
  DBF        D2,adr32
adr39:
  MOVE.L    (A7)+,A5
  MOVEM.W    (A7)+,D0-D2/D4-D5
  ADDQ.W     #2,A5
  DBF        D3,adr37
  BRA        etlfin
adr36:
  ADD.W      A3,D4
  DBF        D2,adr32
  BRA        adr39
adr30:
  EXG        D4,D5
  MOVE.W     D5,D2
  ASL.W      #1,D4
  MOVE.W    D4,A3
  SUB.W      D5,D4
  MOVE.W    D4,A2
  SUBA.W     D5,A2
  MOVE.W     masklig(PC),D1
  MOVE.W     D0,D5
  NOT.W      D5
adr46:
  MOVEM.W    D0-D2/D4-D5,-(A7)
  MOVE.L     A5,-(A7)
  TST.W      (A6)+
  BNE        adr41
  CLR.W      D1
adr41:
  ROL.W      #1,D1
  BCC        adr42
  OR.W       D0,(A5)
  BRA        adr43
adr42:
  AND.W      D5,(A5)
adr43:
  ADDA.W     D7,A5
  TST.W      D4
  BMI        adr44
  ADD.W      A2,D4
  ROR.W      #1,D5
  ROR.W      #1,D0
  BCC        adr45
  ADDA.W     D6,A5
adr45:
  DBF        D2,adr41
adr47:
  MOVE.L    (A7)+,A5
  MOVEM.W    (A7)+,D0-D2/D4-D5
  ADDQ.W     #2,A5
  DBF        D3,adr46
  BRA        etlfin
adr44:
  ADD.W      A3,D4
  DBF        D2,adr41
  BRA        adr47

; Ligne horizontale
lign_h:
  MOVE.L    adecran(PC),A5
  MOVE.W     ydeb(PC),D0
  MULU       #$A0,D0
  ADDA.L     D0,A5
  
  MOVE.W     xdeb(PC),D0
  MOVE.W     xfin(PC),D5
  cmp.w      D0,D5
  bge        adrx84
  EXG        D0,D5              ;;; inverse si XFIN<XDEB
adrx84:
  MOVE.W     D0,D1
  ASR.W      #1,D0
  AND.W      #-8,D0
  ADDA.W     D0,A5              ; adresse debut de ligne

  AND.W      #15,D1
  MOVE.W     #-1,D2
  LSR.W      D1,D2
  MOVE.W     D2,D6
  SWAP       D6
  MOVE.W     D2,D6              ; mask debut de ligne

  MOVE.W     D5,D3
  ASR.W      #1,D5
  AND.W      #-8,D5
  SUB.W      D0,D5
  LSR.W      #3,D5              ;; D5 = nombre mots de la ligne

  AND.W      #15,D3
  MOVE.W     #$8000,D7
  ASR.W      D3,D7
  MOVE.W     D7,D3
  SWAP       D7
  MOVE.W     D3,D7              ; mask de fin de ligne
  LEA        matremp(PC),A1
  MOVE.L     (A1)+,D0           ;matrice de remplissage plans 0 et 1
  MOVE.L     (A1)+,D1           ;matrice de remplissage plans 2 et 3
  
  TST.W      D5
  BNE.S      adrx80
  AND.L      D6,D7              ; si un seul mot mixe les deux masks
  AND.L      D7,D0
  AND.L      D7,D1
  NOT.L      D7
  AND.L      D7,(A5)            ; maskage de la destination
  OR.L       D0,(A5)+
  AND.L      D7,(A5)            ; maskage de la destination
  OR.L       D1,(A5)+
  bra        etlfin
adrx80:
  SUBQ.W     #1,D5
  MOVE.L     D0,D3
  MOVE.L     D1,D4
  AND.L      D6,D3
  AND.L      D6,D4
  NOT.L      D6
  AND.L      D6,(A5)            ; maskage de la destination
  OR.L       D3,(A5)+
  AND.L      D6,(A5)            ; maskage de la destination
  OR.L       D4,(A5)+
  BRA        adrx81
adrx82:
  MOVE.L     D0,(A5)+
  MOVE.L     D1,(A5)+
adrx81:
  dbf        D5,adrx82
  AND.L      D7,D0
  AND.L      D7,D1
  NOT.L      D7
  AND.L      D7,(A5)            ; maskage de la destination
  OR.L       D0,(A5)+
  AND.L      D7,(A5)            ; maskage de la destination
  OR.L       D1,(A5)+
  bra        etlfin
etlfin:
  RTS
masklig:
  dc.w   $ffff
matremp:
  dc.w   $ffff, $ffff, $ffff, $ffff
oldcoll:
  dc.w   15
xdeb:
  dc.w   0
ydeb:
  dc.w   0
xfin:
  dc.w   0
yfin:
  dc.w   0
NBH:
  dc.w   0
PBHBL:
  dc.w   24      
DPB:
              rts
;;;;;;;;; decompression d'un masque : type loupe ;;;;;;;;;;;;
MLOUPE:
        movem.l D0-D7/A0-A6,-(A7)
        move.l  72(A7),trav1
        move.l  trav1(PC),A0
        move.w  68+2(A7),(A0)+          ;x
        move.w  64+2(A7),(A0)           ;y
        move.l  admask(PC),A1
        bsr     decmask
        movem.l (A7)+,D0-D7/A0-A6
        move.l  (A7),12(A7)
        lea     12(A7),A7
        rts
trav1:
        dc.l    0


decmask:
        movem.l D0-D7/A0-A2,-(A7)
        move.l  trav1(PC),A0
        movem   (A0)+,D0-D3
        mulu    #40,D1
        move    D0,D4
        lsr     #3,D4
        andi    #-2,D4
        add     D4,D1
        adda    D1,A1
        move.l  A1,A2
        move    D2,D4
        andi    #15,D0
        move.w  #$7fff,D1
        ror     D0,D1
        move    D1,D6
        move    #-1,D0
        clr     D7
        tst.b   (A0)+
        bne.s   dc3lig
        not     D7
dc3lig:
        clr     D5
        move.b  (A0)+,D5
        cmpi    #$80,D5
        blt.s   dclign
        sub     #$80,D5
        lsl     #8,D5
        move.b  (A0)+,D5
dclign:
        move    D4,D2
dc1lig:
        tst     D7
        bne.s   dc10lig
        and     D1,D0
dc10lig:
        ror     #1,D1
        bcs.s   dc2lig
        and     D0,(A1)+
        move    #-1,D0
dc2lig:
        subq.w  #1,D5
        bgt.s   dc4lig
        not     D7
        clr     D5
        move.b  (A0)+,D5
        cmpi    #$80,D5
        blt.s   dc4lig
        sub     #$80,D5
        lsl     #8,D5
        move.b  (A0)+,D5
dc4lig:
        dbf     D2,dc1lig
        and     D0,(A1)
        add     #40,A2
        move.l  A2,A1
        move    D6,D1
        move    #-1,D0
        dbf     D3,dclign
        movem.l (A7)+,D0-D7/A0-A2
        rts
         
;;;;;;;;;;;;;; Affiche marque sur 4 points ;;;;;;;;;;;;;;;;
;; 76(A7)  adresse ecran
;; 66(A7)  couleur
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

AFMARK:
        movem.l D0-D7/A0-A6,-(A7)
        move.w  72+2(A7),D0         ;x
        move.w  68+2(A7),D6         ;y
        mulu    #160,D6
        move    D0,D3
        lsr     #1,D3
        andi.l  #-8,D3
        add.l   D3,D6           ;D6 offset ecran
        andi    #15,D0
        move.l  #$c0000000,D7
        lsr.l   D0,D7
        move    D7,D0
        swap    D0
        move    D7,D0           ;D0 = 2eme bloc 16 pts plans 0 1
        move.l  D0,D1           ;D1 = plans 2 3
        move.l  D0,D2
        not.l   D2              ;D2 = mask
        swap    D7
        move    D7,D3
        swap    D3
        move    D7,D3           ;D3 = 1er bloc 16 pts plans 0 1
        move.l  D3,D4           ;D4 = plans 2 3
        move.l  D3,D5
        not.l   D5              ;D5 = 1er mask
        move.w  66(A7),D7
        btst    #1,D7
        bne.s   dcolm1
        clr     D0
        clr     D3
dcolm1:
        btst    #0,D7
        bne.s   dcolm2
        swap    D0
        swap    D3
        clr     D0
        clr     D3
        swap    D0
        swap    D3
dcolm2:
        btst    #3,D7
        bne.s   dcolm3
        clr     D1
        clr     D4
dcolm3:
        btst    #2,D7
        bne.s   dcolm4
        swap    D1
        swap    D4
        clr     D1
        clr     D4
        swap    D1
        swap    D4
dcolm4:
        move.l  ecrbuf(PC),A0
        tst.l   76(A7)
        beq.s   ec2mark
        move.l  76(A7),A0
ec2mark:
        adda    D6,A0
        moveq   #1,D7
dmark:
        and.l   D5,(A0)         ;1er bloc
        or.l    D3,(A0)+
        and.l   D5,(A0)
        or.l    D4,(A0)+
        and.l   D2,(A0)        ;2eme bloc
        or.l    D0,(A0)+    
        and.l   D2,(A0)
        or.l    D1,(A0)+
        lea     144(A0),A0
        dbf     D7,dmark
        tst.l   76(A7)
        bne.s   d1mark
        not.l   76(A7)
        move.l  adecran(PC),A0
        bra.s   ec2mark
d1mark:
        movem.l (A7)+,D0-D7/A0-A6
        move.l  (A7),16(A7)
        lea     16(A7),A7
        rts

;*** debut affichage ouverts/fermes etc... ***/

base_des:
         dc.l     0
depl_des:
         dc.l     0
valid_des:
         dc.l     0
nbdes:
         dc.w     0
rectaff:
         dc.w     0,0,0,0

AFFICHE:
         LINK     A6,#AFFL0
         MOVE     #319,rectaff
         MOVE     #199,rectaff+2
         MOVE     #0,rectaff+4
         MOVE     #0,rectaff+6
         MOVEM.L  D1-D7/A0-A5,-(A7)
         MOVE.L   16(A6),A3             ;valid_des
         MOVE.L   A3,valid_des
         MOVE.L   20(A6),depl_des
         MOVE.L   24(A6),base_des
         MOVE     10(A6),nbdes
         MOVE.L   12(A6),-(A7)          ;atrava
         JSR      X_Init_all(PC)
         ADDQ     #4,A7
         MOVEQ    #0,D7
         MOVEQ    #0,D6
         BRA      AFFIL2
AFFIL3:
         BCLR     #4,0(A3,D7.W)
         BEQ      AFFIL6
         MOVE     D6,-(A7)
         JSR      initpile(PC)
         ADDQ     #2,A7
         MOVE     D7,D0
         MOVE.L   valid_des(PC),A0
         MOVE.B   0(A0,D7.W),D1
         EXT      D1
         MULS     D1,D0
         MOVE     D0,-(A7)
         MOVE     D7,-(A7)
         MOVE     D6,-(A7)
         JSR      cherc_list(PC)
         ADDQ     #6,A7
         ADDQ     #1,D6
AFFIL6:
         ADDQ     #1,D7
AFFIL2:
         CMP      nbdes(PC),D7
         BLT      AFFIL3
AFFIL5:
         TST      D6
         BEQ      AFFIL10
         MOVE.L   #100,-(A7)
         JSR      X_Malloc(PC)
         ADDQ.L   #4,A7
         MOVE.L   D0,-4(A6)
         MOVE     D6,-(A7)
         MOVE.L   -4(A6),-(A7)
         JSR      mergpile(PC)
         ADDQ     #6,A7
         MOVE.L   -4(A6),-(A7)
         MOVE.L   28(A6),-(A7)          ;ecran
         JSR      affich_obj(PC)
         ADDQ     #8,A7
         MOVE.L   -4(A6),-(A7)
         JSR      X_Mfree(PC)
         ADDQ     #4,A7
         BRA      AFFIL7
AFFIL8:
         SUBQ     #1,D6
         MOVE     D6,-(A7)
         JSR      exitpile(PC)
         ADDQ     #2,A7
AFFIL7:
         TST      D6
         BGT      AFFIL8
AFFIL10:
         LEA      rectaff(PC),A0
         CMPI     #319,(A0)
         BNE.S    AFFIL1
         MOVE     #-1,(A0)
AFFIL1:
         MOVE.L   A0,D0
         MOVEM.L  (A7)+,D1-D7/A0-A5
         UNLK     A6
         MOVE.L   (A7),24(A7)
         LEA      24(A7),A7
         RTS
AFFL0:     EQU     -4
cherc_list:
         LINK     A6,#AFFL11
         MOVE     D7,-(A7)
         MOVE     12(A6),D7
         BRA      AFFIL13
AFFIL14:
         MOVE     D7,-(A7)
         MOVE     10(A6),-(A7)
         JSR      compar_cmp(PC)
         ADDQ     #4,A7
         TST      D0
         BEQ      AFFIL17
         MOVE     D7,-(A7)
         MOVE     8(A6),-(A7)
         JSR      empile(PC)
         ADDQ.L   #4,A7
AFFIL17:
AFFIL15:
         ADDQ     #1,D7
AFFIL13:
         MOVE     D7,D0
         CMP      nbdes(PC),D0
         BLT      AFFIL14
AFFIL16:
         MOVE     8(A6),-(A7)
         JSR      depile(PC)
         ADDQ.L   #2,A7
         MOVE     D0,12(A6)
         CMPI     #0,D0
         BLT      AFFIL18
         MOVE     12(A6),-(A7)
         MOVE     12(A6),-(A7)
         MOVE     8(A6),-(A7)
         JSR      cherc_list(PC)
         ADDQ.L   #6,A7
AFFIL18:
AFFIL12:
         MOVE     (A7)+,D7
         UNLK     A6
         RTS
AFFL11:    EQU     0
compar_cmp:
         LINK     A6,#AFFL19
         MOVEM.L  A2-A3/D6-D7,-(A7)
         MOVE.L   valid_des(PC),A0
         ADDA     10(A6),A0
         MOVE.B   (A0),D0
         EXT      D0
         AND      #15,D0
         TST      D0
         BNE      AFFIL21
         MOVE     #0,D0
         BRA      AFFIL20
AFFIL21:
         MOVE.L   base_des(PC),D0
         MOVE     8(A6),D1
         ADD      D1,D1
         MOVE.L   depl_des(PC),A0
         MOVE     0(A0,D1.W ),D3
         EXT.L    D3
         ADD.L    D3,D0
         MOVE.L   D0,-4(A6)
         MOVE.L   base_des(PC),D0
         MOVE     10(A6),D1
         ADD      D1,D1
         MOVE.L   depl_des(PC),A0
         MOVE     0(A0,D1.W),D3
         EXT.L    D3
         ADD.L    D3,D0
         MOVE.L   D0,-8(A6)
         MOVE.L   -4(A6),D0
         ADDQ.L   #1,D0
         MOVE.L   D0,A0
         MOVE.B   (A0),D0
         EXT      D0
         MOVE     D0,-14(A6)
         MOVE.L   -8(A6),D0
         ADDQ.L   #1,D0
         MOVE.L   D0,A0
         MOVE.B   (A0),D0
         EXT      D0
         MOVE     D0,-16(A6)
         MOVE.L   -4(A6),A0
         MOVE.B   (A0),D0
         EXT      D0
         CMP      #0,D0
         BNE      AFFIL22
         ADDI.L   #32,-4(A6)
AFFIL22:
         ADDQ.L   #4,-4(A6)
         MOVE.L   -8(A6),A0
         MOVE.B   (A0),D0
         EXT      D0
         CMP      #0,D0
         BNE      AFFIL23
         ADDI.L   #32,-8(A6)
AFFIL23:
         ADDQ.L   #4,-8(A6)
         MOVE.L   -8(A6),-12(A6)
         CLR      D7
         BRA      AFFIL24
AFFIL25:
         MOVE.L   -4(A6),D0
         MOVE.L   D0,A3
         MOVE.L   -12(A6),D0
         MOVE.L   D0,-8(A6)
         CLR      D6
         BRA      AFFIL28
AFFIL29:
         MOVE.L   -8(A6),A2
         MOVE.L   A2,-(A7)
         MOVE.L   A3,-(A7)
         JSR      intersect(PC)
         ADDQ.L   #8,A7
         TST      D0
         BEQ      AFFIL32
         MOVE     #1,D0
         BRA      AFFIL20
AFFIL32:
         MOVE     (A2),D0
         ADD      2(A2),D0
         ADD      #15,D0
         AND      #-2,D0
         EXT.L    D0
         ADD.L    D0,-8(A6)
AFFIL30:
         ADDQ     #1,D6
AFFIL28:
         MOVE     D6,D0
         CMP      -16(A6),D0
         BLT      AFFIL29
AFFIL31:
         MOVE     (A3),D0
         ADD      2(A3),D0
         ADD      #15,D0
         AND      #-2,D0
         EXT.L    D0
         ADD.L    D0,-4(A6)
AFFIL26:
         ADDQ     #1,D7
AFFIL24:
         MOVE     D7,D0
         CMP      -14(A6),D0
         BLT      AFFIL25
AFFIL27:
         MOVE     #0,D0
         BRA      AFFIL20
AFFIL20:
         MOVEM.L  (A7)+,D6-D7/A2-A3
         UNLK     A6
         RTS
AFFL19:    EQU     -16
intersect:
         LINK     A6,#AFFL33
         MOVEM.L  A2-A3/D4-D7,-(A7)
         MOVE.L   8(A6),A3
         MOVE.L   12(A6),A2
         MOVE     4(A3),D7
         ADD      10(A3),D7
         MOVE     4(A2),D5
         ADD      10(A2),D5
         CMP      D7,D5
         BLE      AFFIL35
         MOVE     D7,D5
AFFIL35:
         MOVE     6(A3),D6
         ADD      12(A3),D6
         MOVE     6(A2),D4
         ADD      12(A2),D4
         CMP      D6,D4
         BLE      AFFIL36
         MOVE     D6,D4
AFFIL36:
         MOVE     4(A3),D7
         CMP      4(A2),D7
         BGE      AFFIL37
         MOVE     4(A2),D7
AFFIL37:
         MOVE     6(A3),D6
         CMP      6(A2),D6
         BGE      AFFIL38
         MOVE     6(A2),D6
AFFIL38:
         MOVEQ    #0,D0
         CMP      D7,D5
         BLE.S    AFFIL39
         CMP      D6,D4
         BLE.S    AFFIL39
         MOVEQ    #1,D0
AFFIL39:
         MOVEM.L  (A7)+,D4-D7/A2-A3
         UNLK     A6
         RTS

AFFL33:    EQU     0
affich_obj:
         LINK     A6,#AFFL40
         MOVE.L   A3,-(A7)
         MOVE.L   12(A6),A3
         MOVE.L   #100,-(A7)
         JSR      X_Malloc(PC)
         ADDQ     #4,A7
         MOVE.L   D0,-4(A6)
         BRA      AFFIL42
AFFIL43:
         MOVE.L   base_des(PC),A0
         MOVEQ    #0,D1
         MOVE.B   (A3),D1
         ADD      D1,D1
         MOVE.L   depl_des(PC),A1
         MOVE     0(A1,D1.W),D3
         ADD      D3,A0
         CLR.L    -(A7)                      ;Pas de palette remap
         MOVE.L   -4(A6),-(A7)               ;Buffer de decompression
         MOVE.L   A0,-(A7)                   ;dessin a decompresser
         CLR.L    -(A7)
         CLR.L    -(A7)
         MOVE.L   8(A6),-(A7)                ;Ecran
         BSR      DECOMP
         TST.B    (A0)
         BNE      AFFIL45
         ADD      #32,A0
AFFIL45:
         ADDQ     #4,A0
         MOVE     4(A0),D0
         CMP      rectaff(PC),D0
         BGE      AFFIL46
         MOVE     D0,rectaff
AFFIL46:
         MOVE     6(A0),D0
         CMP      rectaff+2(PC),D0
         BGE      AFFIL47
         MOVE     D0,rectaff+2
AFFIL47:
         MOVE     4(A0),D0
         ADD      10(A0),D0
         CMP      rectaff+4(PC),D0
         BLE      AFFIL48
         MOVE     D0,rectaff+4
AFFIL48:
         MOVE     6(A0),D0
         ADD      12(A0),D0
         CMP      rectaff+6(PC),D0
         BLE      AFFIL49
         MOVE     D0,rectaff+6
AFFIL49:
         ADDQ     #1,A3
AFFIL42:
         CMP.B    #255,(A3)
         BNE      AFFIL43
AFFIL44:
         MOVE.L   (A7)+,A3
         UNLK     A6
         RTS
AFFL40:    EQU     -4

pile:
         blk.l    20

initpile:
         LINK     A6,#AFFL51
         MOVE.L   #800,-(A7)
         JSR      X_Malloc(PC)
         ADDQ     #4,A7

         MOVE     8(A6),D1
         ASL.L    #3,D1
         LEA      pile(PC),A0
         ADDA     D1,A0
         MOVE.L   D0,(A0)
         CLR      4(A0)
         CLR      6(A0)

         UNLK     A6
         RTS
AFFL51:  EQU      0
exitpile:
         LINK     A6,#AFFL53
         MOVE     8(A6),D0
         ASL.L    #3,D0
         LEA      pile(PC),A0
         ADDA     D0,A0
         MOVE.L   (A0),-(A7)
         JSR      X_Mfree(PC)
         ADDQ.L   #4,A7

         UNLK     A6
         RTS
AFFL53:  EQU      0
empile:
         LINK     A6,#AFFL55
         MOVEM.L  A3/D7,-(A7)
         MOVEQ    #0,D7
         MOVE     8(A6),D0
         ASL.L    #3,D0
         LEA      pile(PC),A0
         ADDA     D0,A0
         MOVE.L   (A0),A3
         BRA      AFFIL57
AFFIL58:
         MOVE.B   (A3)+,D0
         MOVE.B   11(A6),D1
         AND      #255,D1
         EXT      D0
         CMP      D1,D0
         BNE      AFFIL61
         MOVE     #0,D0
         BRA      AFFIL56
AFFIL61:
         ADDQ     #1,D7
AFFIL57:
         MOVE     8(A6),D1
         ASL.L    #3,D1
         LEA      pile+6(PC),A0
         ADDA     D1,A0
         CMP      (A0),D7
         BLT      AFFIL58
AFFIL60:
         MOVE     8(A6),D0
         ASL.L    #3,D0
         LEA      pile+6(PC),A0
         ADDA     D0,A0
         MOVE     (A0),D0
         ADDQ     #1,(A0)
         MOVE     8(A6),D1
         ASL.L    #3,D1
         LEA      pile(PC),A0
         ADDA     D1,A0
         MOVE.L   (A0),A0
         ADDA     D0,A0
         MOVE.B   11(A6),(A0)
AFFIL56:
         MOVEM.L  (A7)+,D7/A3
         UNLK     A6
         RTS
AFFL55:  EQU      0
depile:
         LINK     A6,#AFFL62
         MOVE     8(A6),D0
         ASL.L    #3,D0
         LEA      pile+4(PC),A0
         ADDA     D0,A0
         MOVE     (A0),D0
         MOVE     8(A6),D1
         ASL.L    #3,D1
         LEA      pile+6(PC),A0
         ADDA     D1,A0
         CMP      (A0),D0
         BLT      AFFIL64
         MOVE     #-1,D0
         BRA      AFFIL65
AFFIL64:
         MOVE     8(A6),D0
         ASL.L    #3,D0
         LEA      pile+4(PC),A0
         ADDA     D0,A0
         MOVE     (A0),D0
         ADDQ     #1,(A0)
         MOVE     8(A6),D1
         ASL.L    #3,D1
         LEA      pile(PC),A0
         ADDA     D1,A0
         MOVE.L   (A0),A0
         ADDA     D0,A0
         MOVE.B   (A0),D0
         AND      #255,D0
AFFIL65:
         UNLK     A6
         RTS
AFFL62:  EQU      -2
mergpile:
         LINK     A6,#AFFL66
         MOVEM.L  D4-D7,-(A7)
         MOVE.L   8(A6),-4(A6)
AFFIL68:
         MOVE.B   #-2,-5(A6)
         MOVE     #-1,D7
         CLR      D5
         BRA      AFFIL71
AFFIL72:
         CLR      D4
         BRA      AFFIL75
AFFIL76:
         MOVE     D5,D0
         ASL.L    #3,D0
         LEA      pile(PC),A0
         ADDA     D0,A0
         MOVE.L   (A0),A0
         ADDA     D4,A0
         MOVE.B   (A0),D0
         MOVE.B   -5(A6),D1
         AND      #255,D1
         AND      #255,D0
         CMP      D1,D0
         BNE      AFFIL79
         MOVE     D5,D0
         ASL.L    #3,D0
         LEA      pile(PC),A0
         ADDA     D0,A0
         MOVE.L   (A0),A0
         ADDA     D4,A0
         MOVE.B   #-1,(A0)
AFFIL79:
         MOVE     D5,D0
         ASL.L    #3,D0
         LEA      pile(PC),A0
         ADDA     D0,A0
         MOVE.L   (A0),A0
         ADDA     D4,A0
         MOVE.B   (A0),D0
         MOVE.B   -5(A6),D1
         AND      #255,D1
         AND      #255,D0
         CMP      D1,D0
         BGE      AFFIL80
         MOVE     D5,D0
         MOVE     D0,D7
         MOVE     D4,D0
         MOVE     D0,D6
         MOVE     D5,D0
         ASL.L    #3,D0
         LEA      pile(PC),A0
         ADDA     D0,A0
         MOVE.L   (A0),A0
         ADDA     D4,A0
         MOVE.B   (A0),-5(A6)
AFFIL80:
AFFIL77:
         ADDQ     #1,D4
AFFIL75:
         MOVE     D4,D0
         MOVE     D5,D1
         ASL.L    #3,D1
         LEA      pile+6(PC),A0
         ADDA     D1,A0
         CMP      (A0),D0
         BLT      AFFIL76
AFFIL78:
AFFIL73:
         ADDQ     #1,D5
AFFIL71:
         MOVE     D5,D0
         CMP      12(A6),D0
         BLT      AFFIL72
AFFIL74:
         CMPI     #0,D7
         BGE      AFFIL81
         BRA      AFFIL70
AFFIL81:
         MOVE.L   8(A6),A0
         ADDQ.L   #1,8(A6)
         MOVE.B   -5(A6),(A0)
         MOVE     D7,D0
         ASL.L    #3,D0
         LEA      pile(PC),A0
         ADDA     D0,A0
         MOVE.L   (A0),A0
         ADDA     D6,A0
         MOVE.B   #-1,(A0)
AFFIL69:
         MOVE     #1,D0
         BNE      AFFIL68
AFFIL70:
         MOVE.L   8(A6),A0
         ADDQ.L   #1,8(A6)
         MOVE.B   #-1,(A0)

         MOVEM.L  (A7)+,D4-D7
         UNLK     A6
         RTS
AFFL66:  EQU      -6

X_tabmem:
         blk.l    50
anum:
         dc.w     0

X_Init_all:
         MOVE.L   4(A7),X_tabmem
         CLR      anum
         RTS
X_Malloc:
         MOVE     anum(PC),D0
         ASL.L    #2,D0
         LEA      X_tabmem(PC),A0
         ADDA     D0,A0
         MOVE.L   (A0)+,D1
         MOVE.L   D1,D0             ;ADRESSE DE RETOUR
         ADD.L    4(A7),D1
         MOVE.L   D1,(A0)
         ADDQ     #1,anum
         RTS
X_Mfree:
         SUBQ     #1,anum
         RTS

;*** fin affichage ouverts/fermes etc... ***/

CONFIGSYS:
        rts                           ;pour version systeme
        TST.W   $C6.W                 ;1ER LECTEUR SF
        BEQ.S   CONFIGSF
        CLR     $C4.w
        BRA.S   FINCONFIG
CONFIGSF:
        TST     $C4.w             ;1/2 LECTEURS
        BEQ.S   FINCONFIG
        MOVEQ   #7,D0           ;DISK2 -> LECTEUR 2
        CLR     D1
        BSR     ALERTE
        MOVEQ   #2,D0           ;FACE 1 LECTEUR 2
        JSR     TSTFACE
        MOVE    D0,$C6.w
        jsr     INIMUS
        jsr     CHMUTOT
        RTS
FINCONFIG:
        jsr     INIMUS
        MOVEQ   #6,D0           ;DISK2 -> LECTEUR 1
        CLR     D1
        BSR     ALERTE
        jsr     CHMUTOT
        RTS
;*
;;;;;;;;;;;;;;;;;; CHARGEMENT ET SAUVEGARDE PARTIE ;;;;;;;;;;;;;;;;;;;;;;;;
;*
;**** LECTURE PISTE 1 SECTEUR 3 ****
;**** DANS D0 BITS CORRESPONDANT A SAUVEGARDE ****
;*
nom0sauv:
        DC.B    'E:\SECTE.ESS\SAUVE.O',0
nom1sauv:
        DC.B    'E:\SECTE.ESS\SAUVE1.O',0
        DC.B    'E:\SECTE.ESS\SAUVE2.O',0
        DC.B    'E:\SECTE.ESS\SAUVE3.O',0
        DC.B    'E:\SECTE.ESS\SAUVE4.O',0
        DC.B    'E:\SECTE.ESS\SAUVE5.O',0
        EVEN
CHARGE:
        MOVE.L  4(A7),nboctet
        MOVE.L  8(A7),ADRSRC
        MOVE    14(A7),D0       ;numero de sauvegarde
        movem.l d0-d7/a0-a6,-(a7)
        BLT.S   CHRGT0
        MULU    #22,D0
        LEA     nom1sauv,A0
        ADD     D0,A0
        BRA.S   CHRGT1
CHRGT0: LEA     nom0sauv,A0
CHRGT1: CLR     -(A7)               ;FOPEN
        MOVE.L  A0,-(A7)
        move    #$3d,-(A7)
        trap    #1
        addq    #8,A7
        move    D0,identif

        MOVE.L  ADRSRC(pc),-(A7)    ;FREAD
        move.l  nboctet(pc),-(A7)
        move.w  identif(pc),-(A7)
        move.w  #$3f,-(A7)
        trap    #1
        lea     12(A7),A7

        MOVE.W  identif(pc),-(A7)   ;FCLOSE
        move.w  #$3e,-(A7)
        trap    #1
        addq    #4,A7

        movem.l (A7)+,d0-d7/a0-a6
        MOVE.L  (A7),12(A7)
        LEA     12(A7),A7

        RTS
SAUVE:
        MOVE.L  4(A7),nboctet
        MOVE.L  8(A7),ADRSRC
        MOVE    14(A7),D0       ;numero de sauvegarde
        movem.l d0-d7/a0-a6,-(a7)
        MULU    #22,D0
        LEA     nom1sauv,A0
        ADD     D0,A0
        CLR     -(A7)               ;FOPEN
        MOVE.L  A0,-(A7)
        move    #$3c,-(A7)
        trap    #1
        addq    #8,A7
        move    D0,identif

        MOVE.L  ADRSRC(pc),-(A7)    ;FREAD
        move.l  nboctet(pc),-(A7)
        move.w  identif(pc),-(A7)
        move.w  #$40,-(A7)
        trap    #1
        lea     12(A7),A7

        MOVE.W  identif(pc),-(A7)   ;FCLOSE
        move.w  #$3e,-(A7)
        trap    #1
        addq    #4,A7

        movem.l (A7)+,d0-d7/a0-a6
        MOVE.L  (A7),12(A7)
        LEA     12(A7),A7

        RTS
TESTLOAD:
        MOVEQ   #0,D2
        MOVEQ   #4,D1
        LEA     nom1sauv+[4*22],A0
TST0LOAD:
        MOVEM.L D1-D7/A0-A6,-(A7)
        MOVE    #$20,-(A7)
        MOVE.L  A0,-(A7)
        MOVE    #$4E,-(A7)
        TRAP    #1
        ADDQ    #8,A7
        MOVEM.L (A7)+,D1-D7/A0-A6
        TST     D0
        BNE.S   TST1LOAD
        BSET    D1,D2
TST1LOAD:
        SUB     #22,A0
        DBF     D1,TST0LOAD
        MOVE.L  D2,D0
        MOVE.L  4(A7),A0
        MOVE.L  D0,(A0)
        MOVE.L  (A7),4(A7)
        LEA     4(A7),A7
        RTS
identif:
        dc.w    0
finfin:
