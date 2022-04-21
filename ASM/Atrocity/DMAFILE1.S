************************************************
*     DMA FILE ROUT BY THE GREAT EMPIRE !!!    *
************************************************
;A0=add du nom du fichier (majuscule..)
;A1=add de chargement du fichier ..
;retour en D0=longueur du fichier..


DMAFILE:
          movem.l d1-a6,-(a7) 
          lea     L103F0(pc),a6 
          clr.w   $28(a6) 
          move.l  a0,$1A(a6)
L10010    tst.b   (a0)+ 
          bne.s   L10010
          move.l  a0,$1E(a6)
          move.l  a1,0(a6)
          bsr.s   L1003C
          bsr.s   L1004E
L10020    bmi.s   L10028
          bsr.s   L1008E
          move.l  $3A(a6),d0
L10028    move.l  #$E0E0707,$FFFF8800.w 
          movem.l (a7)+,d1-a6
          rts 


L1003C    clr.l   d0
          clr.l   d1
          clr.l   d2
          clr.l   d3
          clr.l   d4
          clr.l   d5
          clr.l   d6
          clr.l   d7
          rts 
L1004E    move.l  #$E0E0505,$C(a6)
          move.l  #$E0E0404,$10(a6) 
          lea     L10068(pc),a5 
          move.l  a5,(a7) 
          bra     L10182
L10068    tst.l   d0
          beq.s   L10020
          bsr.s   L1003C
          move.l  #$E0E0707,$FFFF8800.w 
          move.l  #$E0E0303,$C(a6)
          move.l  #$E0E0202,$10(a6) 
          pea     L10020(pc)
          bra     L10182
L1008E    move.w  4(a6),d0
          move.w  #$FFFF,$2A(a6)
L10098    move.w  d0,4(a6)
          cmp.w   #$FFF,d0
          beq.s   L100BC
          movea.l 0(a6),a4
          bsr     L100BE
          addi.l  #$400,0(a6) 
          lea     $3E(a6),a4
          bsr     L100D8
          bra.s   L10098
L100BC    rts 
L100BE    lsl.w   #1,d0 
          add.w   6(a6),d0
          subq.w  #4,d0 
          bsr     L102EE
          adda.l  #$200,a4
          addq.w  #1,d0 
          bsr     L102EE
          rts 
L100D8    lea     $200(a4),a3 
          move.w  4(a6),d0
          move.w  $2A(a6),d1
          bsr     L1015A
          move.w  d0,d3 
          cmp.w   d0,d1 
          beq.s   L100F2
          bsr     L102EE
L100F2    bsr     L10142
          bne.s   L1011C
          move.b  (a5)+,d0
          cmpa.l  a3,a5 
          bne.s   L1010C
          addq.w  #1,d3 
          move.w  d0,-(a7)
          move.w  d3,d0 
          bsr     L102EE
          move.w  (a7)+,d0
          movea.l a4,a5 
L1010C    move.b  (a5),d1 
          andi.w  #$FF,d0 
          andi.w  #$F,d1
          lsl.w   #8,d1 
          add.w   d1,d0 
          rts 
L1011C    move.b  (a5)+,d0
          cmpa.l  a3,a5 
          bne.s   L10130
          addq.w  #1,d3 
          move.w  d0,-(a7)
          move.w  d3,d0 
          bsr     L102EE
          move.w  (a7)+,d0
          movea.l a4,a5 
L10130    move.b  (a5),d1 
          rol.b   #4,d0 
          andi.w  #$F,d0
          andi.w  #$FF,d1 
          lsl.w   #4,d1 
          add.w   d1,d0 
          rts 
L10142    clr.w   d0
          lea     $3E(a6),a5
          swap    d0
          adda.w  d0,a5 
          move.w  4(a6),d0
          divu    #2,d0 
          swap    d0
          tst.w   d0
          rts 
L1015A    movem.w d1-d2,-(a7) 
          move.w  d0,d2 
          lsr.w   #1,d0 
          lsl.w   #1,d0 
          sub.w   d0,d2 
          lsr.w   #1,d0 
          ext.l   d0
          mulu    #3,d0 
          addi.w  #$200,d0
          add.w   d2,d0 
          divu    #$200,d0
          move.w  d0,$2A(a6)
          movem.w (a7)+,d1-d2 
          rts 
L10182    lea     $3E(a6),a4
          moveq   #1,d0 
          clr.w   d1
          move.l  d4,-(a7)
          bsr     L10318
          move.l  (a7)+,d4
          move.b  $11(a4),d4
          move.b  $16(a4),d0
          move.b  $18(a4),d1
          move.b  $1A(a4),d2
          move.w  d0,d3 
          lsl.w   #1,d3 
          addq.w  #1,d3 
          lsr.w   #4,d4 
          move.w  d3,$A(a6) 
          move.w  d4,8(a6)
          lea     6(a6),a5
          clr.w   (a5)
          add.w   d3,(a5) 
          add.w   d4,(a5) 
          move.w  d0,$18(a6)
          move.w  d1,$14(a6)
          move.w  d2,$16(a6)
          movea.l $1A(a6),a0
          move.l  a0,$22(a6)
          move.w  $A(a6),$26(a6)
          move.w  $28(a6),d7
          beq.s   L101DE
          subq.w  #1,d7 
L101DE    move.w  $26(a6),d0
          move.w  d0,d3 
          bsr     L102EE
          clr.w   $38(a6) 
          movea.l $22(a6),a0
          bsr     L102B8
          movea.l a4,a5 
          move.w  8(a6),d7
L101FA    moveq   #$F,d6
L101FC    bsr     L1024A
          beq.s   L10220
          bmi.s   L1021C
          adda.l  #$20,a5 
          dbf     d6,L101FC 
          addq.w  #1,d3 
          move.w  d3,d0 
          bsr     L102EE
          movea.l a4,a5 
          dbf     d7,L101FA 
L1021C    moveq   #$FF,d0 
          rts 
L10220    move.b  $1B(a5),d1
          move.b  $1A(a5),d0
          lsl.w   #8,d1 
          add.w   d1,d0 
          clr.w   d1
          adda.l  #$20,a5 
          moveq   #3,d2 
L10236    lsl.l   #8,d1 
          move.b  -(a5),d1
          dbf     d2,L10236 
          move.w  d0,4(a6)
          move.l  d1,$3A(a6)
          moveq   #0,d0 
          rts 
L1024A    movem.l d0-d7/a6,-(a7)
          move.l  (a5),d0 
          beq.s   L102A2
          move.l  4(a5),d1
          move.l  8(a5),d2
          move.b  $38(a6),d7
          beq.s   L10264
          cmp.b   d7,d2 
          bne.s   L1029A
L10264    clr.b   d2
          lea     $2C(a6),a6
          move.l  (a6),d3 
          move.l  4(a6),d4
          move.l  8(a6),d5
          move.l  #$20202020,d7 
          or.l    d7,d0 
          or.l    d7,d1 
          or.l    d7,d2 
          or.l    d7,d3 
          or.l    d7,d4 
          or.l    d7,d5 
          cmp.l   d0,d3 
          bne.s   L1029A
          cmp.l   d1,d4 
          bne.s   L1029A
          cmp.l   d2,d5 
          bne.s   L1029A
          movem.l (a7)+,d0-d7/a6
          clr.w   d0
          rts 
L1029A    movem.l (a7)+,d0-d7/a6
          moveq   #1,d0 
          rts 
L102A2    movem.l (a7)+,d0-d7/a6
          moveq   #$FF,d0 
          rts 
          movea.l $1A(a6),a0
L102AE    cmpi.b  #$5C,(a0)+
          bne.s   L102AE
          move.l  a0,$1A(a6)
L102B8    lea     $2C(a6),a1
          moveq   #$A,d5
L102BE    move.b  (a0)+,d0
          beq.s   L102D6
          cmp.b   #$5C,d0 
          beq.s   L102D6
          cmp.b   #$2E,d0 
          beq.s   L102E0
          move.b  d0,(a1)+
          dbf     d5,L102BE 
          rts 
L102D6    move.b  #$20,(a1)+
          dbf     d5,L102D6 
          rts 
L102E0    subq.w  #3,d5 
          bmi.s   L102E6
          bsr.s   L102D6
L102E6    move.b  (a0)+,(a1)+ 
          move.b  (a0)+,(a1)+ 
          move.b  (a0)+,(a1)+ 
          rts 
L102EE    movem.l d0-a6,-(a7) 
          move.w  $16(a6),d2
          move.w  $14(a6),d3
          move.w  d0,d4 
          divu    d3,d4 
          move.w  d4,d5 
          divu    d2,d5 
          swap    d4
          addq.w  #1,d4 
          move.w  d4,d0 
          move.w  d5,d1 
          swap    d5
          move.w  d5,d2 
          bsr     L10318
          movem.l (a7)+,d0-a6 
          rts 
L10318    move.l  $C(a6),$FFFF8800.w
          tst.w   d2
          beq     L1032A
          move.l  $10(a6),$FFFF8800.w 
L1032A    movea.w #$8604,a0 
          bsr     L1033C
          bsr     L1038C
          bsr     L103B8
          rts 
L1033C    moveq   #1,d6 
          move.w  #$84,2(a0)
          divu    d6,d6 
          move.w  d0,(a0) 
          divu    d6,d6 
          move.w  #$86,2(a0)
          divu    d6,d6 
          move.w  d1,(a0) 
          divu    d6,d6 
          move.w  #$80,2(a0)
          divu    d6,d6 
          move.w  #$13,(a0) 
          divu    d6,d6 
          bsr     L1036C
          bne.s   L1033C
          rts 
L1036C    move.l  #$80000,d4
L10372    subq.l  #1,d4 
          beq     L10386
          btst.b  #5,$FFFFFA01.w
          bne.s   L10372
          move    #4,ccr
          rts 
L10386    cmpa.w  #0,a7 
          rts 
L1038C    move.w  #$90,2(a0)
          move.w  #$190,2(a0) 
          move.w  #$90,2(a0)
          divu    d6,d6 
          move.w  #1,(a0) 
          move.l  a4,d4 
          move.b  d4,$FFFF860D.w
          lsr.l   #8,d4 
          move.b  d4,$FFFF860B.w
          lsr.l   #8,d4 
          move.b  d4,$FFFF8609.w
          rts 
L103B8    moveq   #$A,d4
L103BA    move.l  d4,-(a7)
          move.w  #$80,2(a0)
          divu    d6,d6 
          move.w  #$80,(a0) 
          divu    d6,d6 
          bsr.s   L1036C
          beq.s   L103DE
          move.l  (a7)+,d4
          dbf     d4,L103BA 
          move.w  #$77,$FFFF8240.w
L103DA    bra.s   L103DA
          rts 
L103DE    move.l  (a7)+,d4
          move.w  #$80,2(a0)
          move.w  (a0),d4 
          btst.l  #3,d4 
          bne.s   L103BA
          rts 

L103F0:
	ds.l	40

