********************************************************************************
*                                                                              *
*                              C64-Emulator V3.0                               *
*                             ½ 1987 by Uwe Seimet                             *
*                             Buchenlochstraže 29                              *
*                             6750 Kaiserslautern                              *
*                                                                              *
*                       Linkreihenfolge: C64.O,VC.O,EMULATOR.O                 *
*                                                                              *
********************************************************************************


      globl op
      globl c64
      globl area
      globl swlo
      globl swhi
      globl ops
      globl itret


      text

op:
      dc op00-op,sto81-op,op00-op,op00-op,op84-op,op85-op,op86-op,op00-op
      dc op88-op,op00-op,op8a-op,op00-op,sto8c-op,sto8d-op,sto8e-op,op00-op
      dc op90-op,sto91-op,op00-op,op00-op,op94-op,op95-op,op96-op,op00-op
      dc op98-op,sto99-op,op9a-op,op00-op,op00-op,sto9d-op,op00-op,op00-op
      dc opa0-op,opa1-op,opa2-op,op00-op,opa4-op,opa5-op,opa6-op,op00-op
      dc opa8-op,opa9-op,opaa-op,op00-op,opac-op,opad-op,opae-op,op00-op
      dc opb0-op,opb1-op,op00-op,op00-op,opb4-op,opb5-op,opb6-op,op00-op
      dc opb8-op,opb9-op,opba-op,op00-op,opbc-op,opbd-op,opbe-op,op00-op
      dc opc0-op,opc1-op,op00-op,op00-op,opc4-op,opc5-op,opc6-op,op00-op
      dc opc8-op,opc9-op,opca-op,op00-op,opcc-op,opcd-op,opce-op,op00-op
      dc opd0-op,opd1-op,op00-op,op00-op,op00-op,opd5-op,opd6-op,op00-op
      dc opd8-op,opd9-op,op00-op,op00-op,op00-op,opdd-op,opde-op,op00-op
      dc ope0-op,ope1-op,op00-op,op00-op,ope4-op,ope5-op,ope6-op,op00-op
      dc ope8-op,ope9-op,opea-op,op00-op,opec-op,oped-op,opee-op,op00-op
      dc opf0-op,opf1-op,op00-op,op00-op,op00-op,opf5-op,opf6-op,op00-op
      dc opf8-op,opf9-op,op00-op,op00-op,op00-op,opfd-op,opfe-op,op00-op
      dc op00-op,op01-op,op00-op,op00-op,op00-op,op05-op,op06-op,op00-op
      dc op08-op,op09-op,op0a-op,op00-op,op00-op,op0d-op,op0e-op,op00-op
      dc op10-op,ora11-op,op00-op,op00-op,op00-op,op15-op,op16-op,op00-op
      dc op18-op,op19-op,op00-op,op00-op,op00-op,op1d-op,op1e-op,op00-op
      dc op20-op,op21-op,op00-op,op00-op,op24-op,op25-op,op26-op,op00-op
      dc op28-op,op29-op,op2a-op,op00-op,op2c-op,op2d-op,op2e-op,op00-op
      dc op30-op,and31-op,op00-op,op00-op,op00-op,op35-op,op36-op,op00-op
      dc op38-op,op39-op,op00-op,op00-op,op00-op,op3d-op,op3e-op,op00-op
      dc op40-op,op41-op,op00-op,op00-op,op00-op,op45-op,op46-op,op00-op
      dc op48-op,op49-op,op4a-op,op00-op,op4c-op,op4d-op,op4e-op,op00-op
      dc op50-op,eor51-op,op00-op,op00-op,op00-op,op55-op,op56-op,op00-op
      dc op58-op,op59-op,op00-op,op00-op,op00-op,op5d-op,op5e-op,op00-op
      dc op60-op,op61-op,op00-op,op00-op,op00-op,op65-op,op66-op,op00-op
      dc op68-op,op69-op,op6a-op,op00-op,op6c-op,op6d-op,op6e-op,op00-op
      dc op70-op,op71-op,op00-op,op00-op,op00-op,op75-op,op76-op,op00-op
      dc op78-op,op79-op,op00-op,op00-op,op00-op,op7d-op,op00-op,op00-op

op00:
      sub.l a6,a5
      move a5,-(a2)
      move.b (a2)+,(a4)
      move.b (a2)+,-(a4)
      move.b d4,-(a4)
      tst.b -(a4)
      move c64+$fffe,d2
      ror #8,d2
      lea (a6,d2.l),a5
      lea l00+2(pc),a0
      move.b (a5)+,(a0)
l00:  jmp 0(a3)

op01:
      move.b (a5)+,d3
      add.b d6,d3
      move.b (a6,d3.l),-(a2)
      move.b 1(a6,d3.l),-(a2)
      move (a2)+,d2
      move d4,ccr
      or.b (a6,d2.l),d5
      move sr,d4
      move.b (a5)+,l01-op01+$0102(a3)
l01:  jmp 0(a3)

op05:
      move.b (a5)+,d3
      move d4,ccr
      or.b (a6,d3.l),d5
      move sr,d4
      move.b (a5)+,l05-op05+$0502(a3)
l05:  jmp 0(a3)

op06:
      move.b (a5)+,d3
      move.b (a6,d3.l),d2
      add.b d2,(a6,d3.l)
      move sr,d4
      move.b (a5)+,l06-op06+$0602(a3)
l06:  jmp 0(a3)

op08:
      move.b d4,(a4)
      tst.b -(a4)
      move.b (a5)+,l08-op08+$0802(a3)
l08:  jmp 0(a3)

op09:
      move d4,ccr
      or.b (a5)+,d5
      move sr,d4
      move.b (a5)+,l09-op09+$0902(a3)
l09:  jmp 0(a3)

op0a:
      add.b d5,d5
      move sr,d4
      move.b (a5)+,l0a-op0a+$0a02(a3)
l0a:  jmp 0(a3)

op0d:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      move d4,ccr
      or.b (a6,d2.l),d5
      move sr,d4
      move.b (a5)+,l0d-op0d+$0d02(a3)
l0d:  jmp 0(a3)

op0e:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      move.b (a6,d2.l),d3
      add.b d3,(a6,d2.l)
      move sr,d4
      move.b (a5)+,l0e-op0e+$0e02(a3)
l0e:  jmp 0(a3)

op10:
      move.b (a5)+,d2
      btst #3,d4
      bne rt10
      ext d2
      add d2,a5
rt10: move.b (a5)+,l10-op10+$1002(a3)
l10:  jmp 0(a3)

op11:
      move.b (a5)+,d3
      move.b (a6,d3.l),-(a2)
      move.b 1(a6,d3.l),-(a2)
      move (a2)+,d2
      add d7,d2
      move d4,ccr
      or.b (a6,d2.l),d5
      move sr,d4
      move.b (a5)+,l11-op11+$1102(a3)
l11:  jmp 0(a3)

ora11:
      move.b (a5)+,d3
      move.b (a6,d3.l),-(a2)
      move.b 1(a6,d3.l),-(a2)
      move (a2)+,d2
      add d7,d2
      cmp #$d000,d2
      bcs or
      sub #$d000,d2
      lea grbss,a0
      move d4,ccr
      or.b (a0,d2.l),d5
      move sr,d4
      move.b (a5)+,l11b-ora11+$1102(a3)
l11b: jmp 0(a3)
or:   move d4,ccr
      or.b (a6,d2.l),d5
      move sr,d4
      move.b (a5)+,l11c-ora11+$1102(a3)
l11c: jmp 0(a3)

op15:
      move.b (a5)+,d3
      add.b d6,d3
      move d4,ccr
      or.b (a6,d3.l),d5
      move sr,d4
      move.b (a5)+,l15-op15+$1502(a3)
l15:  jmp 0(a3)

op16:
      move.b (a5)+,d3
      add.b d6,d3
      move.b (a6,d3.l),d2
      add.b d2,(a6,d3.l)
      move sr,d4
      move.b (a5)+,l16-op16+$1602(a3)
l16:  jmp 0(a3)

op18:
      and.b #$ee,d4
      move.b (a5)+,l18-op18+$1802(a3)
l18:  jmp 0(a3)

op19:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      add d7,d2
      move d4,ccr
      or.b (a6,d2.l),d5
      move sr,d4
      move.b (a5)+,l19-op19+$1902(a3)
l19:  jmp 0(a3)

op1d:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      add d6,d2
      move d4,ccr
      or.b (a6,d2.l),d5
      move sr,d4
      move.b (a5)+,l1d-op1d+$1d02(a3)
l1d:  jmp 0(a3)

op1e:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      add d6,d2
      move.b (a6,d2.l),d3
      add.b d3,(a6,d2.l)
      move sr,d4
      move.b (a5)+,l1e-op1e+$1e02(a3)
l1e:  jmp 0(a3)

op20:
      move.b (a5)+,-(a2)
      move.b (a5),-(a2)
      move (a2)+,d2
      sub.l a6,a5
      move a5,-(a2)
      move.b (a2)+,(a4)
      move.b (a2)+,-(a4)
      tst.b -(a4)
      cmp #$ff81,d2
      bcc jr64
      lea (a6,d2.l),a5
      move.b (a5)+,l20-op20+$2002(a3)
l20:  jmp 0(a3)
jr64: jmp jmp64

op21:
      move.b (a5)+,d3
      add.b d6,d3
      move.b (a6,d3.l),-(a2)
      move.b 1(a6,d3.l),-(a2)
      move (a2)+,d2
      move d4,ccr
      and.b (a6,d2.l),d5
      move sr,d4
      move.b (a5)+,l21-op21+$2102(a3)
l21:  jmp 0(a3)

op24:
      move.b (a5)+,d3
      move.b (a6,d3.l),d2
      move.b d5,d3
      move d4,ccr
      and.b d2,d3
      move sr,d4
      and.b #$f5,d4
      btst #6,d2
      beq l241
      or #$02,d4
l241: tst.b d2
      bpl l242
      or #$08,d4
l242: move.b (a5)+,l24-op24+$2402(a3)
l24:  jmp 0(a3)

op25:
      move.b (a5)+,d3
      move d4,ccr
      and.b (a6,d3.l),d5
      move sr,d4
      move.b (a5)+,l25-op25+$2502(a3)
l25:  jmp 0(a3)

op26:
      move.b (a5)+,d3
      move.b (a6,d3.l),d2
      move d4,ccr
      roxl.b #1,d2
      move sr,d4
      move.b d2,(a6,d3.l)
      move.b (a5)+,l26-op26+$2602(a3)
l26:  jmp 0(a3)

op28:
      tst.b (a4)+
      move.b (a4),d4
      move.b (a5)+,l28-op28+$2802(a3)
l28:  jmp 0(a3)

op29:
      move d4,ccr
      and.b (a5)+,d5
      move sr,d4
      move.b (a5)+,l29-op29+$2902(a3)
l29:  jmp 0(a3)

op2a:
      move d4,ccr
      roxl.b #1,d5
      move sr,d4
      move.b (a5)+,l2a-op2a+$2a02(a3)
l2a:  jmp 0(a3)

op2c:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      move.b (a6,d2.l),d2
      move.b d2,d3
      move d4,ccr
      and.b d5,d3
      move sr,d4
      and.b #$f5,d4
      btst #6,d2
      beq l2c1
      or #$02,d4
l2c1: tst.b d2
      bpl l2c2
      or #$08,d4
l2c2: move.b (a5)+,l2c-op2c+$2c02(a3)
l2c:  jmp 0(a3)

op2d:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      move d4,ccr
      and.b (a6,d2.l),d5
      move sr,d4
      move.b (a5)+,l2d-op2d+$2d02(a3)
l2d:  jmp 0(a3)

op2e:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      move.b (a6,d2.l),d3
      move d4,ccr
      roxl.b #1,d3
      move sr,d4
      move.b d3,(a6,d2.l)
      move.b (a5)+,l2e-op2e+$2e02(a3)
l2e:  jmp 0(a3)

op30:
      move.b (a5)+,d2
      btst #3,d4
      beq rt30
      ext d2
      add d2,a5
rt30: move.b (a5)+,l30-op30+$3002(a3)
l30:  jmp 0(a3)

op31:
      move.b (a5)+,d3
      move.b (a6,d3.l),-(a2)
      move.b 1(a6,d3.l),-(a2)
      move (a2)+,d2
      add d7,d2
      move d4,ccr
      and.b (a6,d2.l),d5
      move sr,d4
      move.b (a5)+,l31-op31+$3102(a3)
l31:  jmp 0(a3)

and31:
      move.b (a5)+,d3
      move.b (a6,d3.l),-(a2)
      move.b 1(a6,d3.l),-(a2)
      move (a2)+,d2
      add d7,d2
      cmp #$d000,d2
      bcs and
      sub #$d000,d2
      lea grbss,a0
      move d4,ccr
      and.b (a0,d2.l),d5
      move sr,d4
      move.b (a5)+,l31b-and31+$3102(a3)
l31b: jmp 0(a3)
and:  move d4,ccr
      and.b (a6,d2.l),d5
      move sr,d4
      move.b (a5)+,l31c-and31+$3102(a3)
l31c: jmp 0(a3)

op35:
      move.b (a5)+,d3
      add.b d6,d3
      move d4,ccr
      and.b (a6,d3.l),d5
      move sr,d4
      move.b (a5)+,l35-op35+$3502(a3)
l35:  jmp 0(a3)

op36:
      move.b (a5)+,d3
      add d6,d3
      move.b (a6,d3.l),d2
      move d4,ccr
      roxl.b #1,d2
      move sr,d4
      move.b d2,(a6,d3.l)
      move.b (a5)+,l36-op36+$3602(a3)
l36:  jmp 0(a3)

op38:
      or.b d1,d4
      move.b (a5)+,l38-op38+$3802(a3)
l38:  jmp 0(a3)

op39:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      add d7,d2
      move d4,ccr
      and.b (a6,d2.l),d5
      move sr,d4
      move.b (a5)+,l39-op39+$3902(a3)
l39:  jmp 0(a3)

op3d:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      add d6,d2
      move d4,ccr
      and.b (a6,d2.l),d5
      move sr,d4
      move.b (a5)+,l3d-op3d+$3d02(a3)
l3d:  jmp 0(a3)

op3e:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      add d6,d2
      move.b (a6,d2.l),d3
      move d4,ccr
      roxl.b #1,d3
      move sr,d4
      move.b d3,(a6,d2.l)
      move.b (a5)+,l3e-op3e+$3e02(a3)
l3e:  jmp 0(a3)

op40:
      tst.b (a4)+
      move.b (a4)+,d4
      move.b (a4)+,-(a2)
      move.b (a4),-(a2)
      move (a2)+,d2
      lea (a6,d2.l),a5
      move.b (a5)+,l40-op40+$4002(a3)
l40:  jmp 0(a3)

op41:
      move.b (a5)+,d3
      add.b d6,d3
      move.b (a6,d3.l),-(a2)
      move.b 1(a6,d3.l),-(a2)
      move (a2)+,d2
      move.b (a6,d2.l),d3
      move d4,ccr
      eor.b d3,d5
      move sr,d4
      move.b (a5)+,l41-op41+$4102(a3)
l41:  jmp 0(a3)

op45:
      move.b (a5)+,d3
      move.b (a6,d3.l),d3
      move d4,ccr
      eor.b d3,d5
      move sr,d4
      move.b (a5)+,l45-op45+$4502(a3)
l45:  jmp 0(a3)

op46:
      move.b (a5)+,d3
      move.b (a6,d3.l),d2
      lsr.b #1,d2
      move sr,d4
      move.b d2,(a6,d3.l)
      move.b (a5)+,l46-op46+$4602(a3)
l46:  jmp 0(a3)

op48:
      move.b d5,(a4)
      tst.b -(a4)
      move.b (a5)+,l48-op48+$4802(a3)
l48:  jmp 0(a3)

op49:
      move.b (a5)+,d3
      move d4,ccr
      eor.b d3,d5
      move sr,d4
      move.b (a5)+,l49-op49+$4902(a3)
l49:  jmp 0(a3)

op4a:
      lsr.b #1,d5
      move sr,d4
      move.b (a5)+,l4a-op4a+$4a02(a3)
l4a:  jmp 0(a3)

op4c:
      move.b (a5),-(a2)
      move.b 1(a5),-(a2)
      move (a2)+,d2
      cmp #$ff81,d2
      bcc jp64
      lea (a6,d2.l),a5
      move.b (a5)+,l4c-op4c+$4c02(a3)
l4c:  jmp 0(a3)
jp64: jmp jmp64

op4d:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      move.b (a6,d2.l),d3
      move d4,ccr
      eor.b d3,d5
      move sr,d4
      move.b (a5)+,l4d-op4d+$4d02(a3)
l4d:  jmp 0(a3)

op4e:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      move.b (a6,d2.l),d3
      lsr.b #1,d3
      move sr,d4
      move.b d3,(a6,d2.l)
      move.b (a5)+,l4e-op4e+$4e02(a3)
l4e:  jmp 0(a3)

op50:
      move.b (a5)+,d2
      btst #1,d4
      bne rt50
      ext d2
      add d2,a5
rt50: move.b (a5)+,l50-op50+$5002(a3)
l50:  jmp 0(a3)

op51:
      move.b (a5)+,d3
      move.b (a6,d3.l),-(a2)
      move.b 1(a6,d3.l),-(a2)
      move (a2)+,d2
      add d7,d2
      move.b (a6,d2.l),d3
      move d4,ccr
      eor.b d3,d5
      move sr,d4
      move.b (a5)+,l51-op51+$5102(a3)
l51:  jmp 0(a3)

eor51:
      move.b (a5)+,d3
      move.b (a6,d3.l),-(a2)
      move.b 1(a6,d3.l),-(a2)
      move (a2)+,d2
      add d7,d2
      cmp #$d000,d2
      bcs eor
      sub #$d000,d2
      lea grbss,a0
      move.b (a0,d2.l),d3
      move d4,ccr
      eor.b d3,d5
      move sr,d4
      move.b (a5)+,l51b-eor51+$5102(a3)
l51b: jmp 0(a3)
eor:  move.b (a6,d2.l),d3
      move d4,ccr
      eor.b d3,d5
      move sr,d4
      move.b (a5)+,l51c-eor51+$5102(a3)
l51c: jmp 0(a3)

op55:
      move.b (a5)+,d3
      add.b d6,d3
      move.b (a6,d3.l),d3
      move d4,ccr
      eor.b d3,d5
      move sr,d4
      move.b (a5)+,l55-op55+$5502(a3)
l55:  jmp 0(a3)

op56:
      move.b (a5)+,d3
      add.b d6,d3
      move.b (a6,d3.l),d2
      lsr.b #1,d2
      move sr,d4
      move.b d2,(a6,d3.l)
      move.b (a5)+,l56-op56+$5602(a3)
l56:  jmp 0(a3)

op58:
      bclr #31,d4
      move.b (a5)+,l58-op58+$5802(a3)
l58:  jmp 0(a3)

op59:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      add d7,d2
      move.b (a6,d2.l),d3
      move d4,ccr
      eor.b d3,d5
      move sr,d4
      move.b (a5)+,l59-op59+$5902(a3)
l59:  jmp 0(a3)

op5d:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      add d6,d2
      move.b (a6,d2.l),d3
      move d4,ccr
      eor.b d3,d5
      move sr,d4
      move.b (a5)+,l5d-op5d+$5d02(a3)
l5d:  jmp 0(a3)

op5e:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      add d6,d2
      move.b (a6,d2.l),d3
      lsr.b #1,d3
      move sr,d4
      move.b d3,(a6,d2.l)
      move.b (a5)+,l5e-op5e+$5e02(a3)
l5e:  jmp 0(a3)

op60:
      tst.b (a4)+
      move.b (a4)+,-(a2)
      move.b (a4),-(a2)
      move (a2)+,d2
      lea 1(a6,d2.l),a5
      move.b (a5)+,l60-op60+$6002(a3)
l60:  jmp 0(a3)

op61:
      move.b (a5)+,d3
      add.b d6,d3
      move.b (a6,d3.l),-(a2)
      move.b 1(a6,d3.l),-(a2)
      move (a2)+,d2
      move.b (a6,d2.l),d3
      move d4,ccr
      btst d1,d4
      bne dc61
      addx.b d3,d5
      move sr,d4
      move.b (a5)+,l61-op61+$6102(a3)
l61:  jmp 0(a3)
dc61: or #$04,ccr
      abcd d3,d5
      move sr,d4
      move.b (a5)+,d61-op61+$6102(a3)
d61:  jmp 0(a3)

op65:
      move.b (a5)+,d3
      move.b (a6,d3.l),d3
      move d4,ccr
      btst d1,d4
      bne dc65
      addx.b d3,d5
      move sr,d4
      move.b (a5)+,l65-op65+$6502(a3)
l65:  jmp 0(a3)
dc65: or #$04,ccr
      abcd d3,d5
      move sr,d4
      move.b (a5)+,d65-op65+$6502(a3)
d65:  jmp 0(a3)

op66:
      move.b (a5)+,d3
      move.b (a6,d3.l),d2
      move d4,ccr
      roxr.b #1,d2
      move sr,d4
      move.b d2,(a6,d3.l)
      move.b (a5)+,l66-op66+$6602(a3)
l66:  jmp 0(a3)

op68:
      tst.b (a4)+
      move d4,ccr
      move.b (a4),d5
      move sr,d4
      move.b (a5)+,l68-op68+$6802(a3)
l68:  jmp 0(a3)

op69:
      move.b (a5)+,d3
      move d4,ccr
      btst d1,d4
      bne dc69
      addx.b d3,d5
      move sr,d4
      move.b (a5)+,l69-op69+$6902(a3)
l69:  jmp 0(a3)
dc69: or #$04,ccr
      abcd d3,d5
      move sr,d4
      move.b (a5)+,d69-op69+$6902(a3)
d69:  jmp 0(a3)

op6a:
      move d4,ccr
      roxr.b #1,d5
      move sr,d4
      move.b (a5)+,l6a-op6a+$6a02(a3)
l6a:  jmp 0(a3)

op6c:
      move.b (a5)+,-(a2)
      move.b (a5),-(a2)
      move (a2)+,d2
      cmp.b #$ff,d2
      bne op6c1
      move.l d2,d0
      clr.b d0
      move.b (a6,d0.l),-(sp)
      bra op6c2
op6c1:move.b 1(a6,d2.l),-(sp)
op6c2:move.b (a6,d2.l),1(sp)
      move (sp)+,d2
      lea (a6,d2.l),a5
      move.b (a5)+,l6c-op6c+$6c02(a3)
l6c:  jmp 0(a3)

op6d:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      move.b (a6,d2.l),d3
      move d4,ccr
      btst d1,d4
      bne dc6d
ndcad:addx.b d3,d5
      move sr,d4
      move.b (a5)+,l6d-op6d+$6d02(a3)
l6d:  jmp 0(a3)
dc6d: or #$04,ccr
      abcd d3,d5
      move sr,d4
      move.b (a5)+,d6d-op6d+$6d02(a3)
d6d:  jmp 0(a3)

op6e:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      move.b (a6,d2.l),d3
      move d4,ccr
      roxr.b #1,d3
      move sr,d4
      move.b d3,(a6,d2.l)
      move.b (a5)+,l6e-op6e+$6e02(a3)
l6e:  jmp 0(a3)

op70:
      move.b (a5)+,d2
      btst #1,d4
      beq rt70
      ext d2
      add d2,a5
rt70: move.b (a5)+,l70-op70+$7002(a3)
l70:  jmp 0(a3)

op71:
      move.b (a5)+,d3
      move.b (a6,d3.l),-(a2)
      move.b 1(a6,d3.l),-(a2)
      move (a2)+,d2
      add d7,d2
      move.b (a6,d2.l),d3
      move d4,ccr
      btst d1,d4
      bne dc71
      addx.b d3,d5
      move sr,d4
      move.b (a5)+,l71-op71+$7102(a3)
l71:  jmp 0(a3)
dc71: or #$04,ccr
      abcd d3,d5
      move sr,d4
      move.b (a5)+,d71-op71+$7102(a3)
d71:  jmp 0(a3)

op75:
      move.b (a5)+,d3
      add.b d6,d3
      move.b (a6,d3.l),d3
      move d4,ccr
      btst d1,d4
      bne dc75
      addx.b d3,d5
      move sr,d4
      move.b (a5)+,l75-op75+$7502(a3)
l75:  jmp 0(a3)
dc75: or #$04,ccr
      abcd d3,d5
      move sr,d4
      move.b (a5)+,d75-op75+$7502(a3)
d75:  jmp 0(a3)

op76:
      move.b (a5)+,d3
      add.b d6,d3
      move.b (a6,d3.l),d2
      move d4,ccr
      roxr.b #1,d2
      move sr,d4
      move.b d2,(a6,d3.l)
      move.b (a5)+,l76-op76+$7602(a3)
l76:  jmp 0(a3)

op78:
      bset #31,d4
      move.b (a5)+,l78-op78+$7802(a3)
l78:  jmp 0(a3)

op79:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      add d7,d2
      move.b (a6,d2.l),d3
      move d4,ccr
      btst d1,d4
      bne dc79
      addx.b d3,d5
      move sr,d4
      move.b (a5)+,l79-op79+$7902(a3)
l79:  jmp 0(a3)
dc79: or #$04,ccr
      abcd d3,d5
      move sr,d4
      move.b (a5)+,d79-op79+$7902(a3)
d79:  jmp 0(a3)

op7d:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      add d6,d2
      move.b (a6,d2.l),d3
      move d4,ccr
      btst d1,d4
      bne dc7d
      addx.b d3,d5
      move sr,d4
      move.b (a5)+,l7d-op7d+$7d02(a3)
l7d:  jmp 0(a3)
dc7d: or #$04,ccr
      abcd d3,d5
      move sr,d4
      move.b (a5)+,d7d-op7d+$7d02(a3)
d7d:  jmp 0(a3)

op81:
      move.b (a5)+,d3
      add.b d6,d3
      move.b (a6,d3.l),-(a2)
      move.b 1(a6,d3.l),-(a2)
      move (a2)+,d2
      move.b d5,(a6,d2.l)
      move.b (a5)+,l81-op81+$8102(a3)
l81:  jmp 0(a3)

sto81:
      move.b (a5)+,d3
      add.b d6,d3
      move.b (a6,d3.l),-(a2)
      move.b 1(a6,d3.l),-(a2)
      move (a2)+,d2
stoa: move d5,-(sp)
sto:  cmp #$d000,d2
      bcc grap
grap2:move.b d5,(a6,d2.l)
      move.l d2,d0
      move.b $0288(a6),d2
      asl #8,d2
      sub d2,d0
      bcs c81
      cmp #1000,d0
      bcc c81
      jmp its
itret:moveq #$10,d1
c81:  move (sp)+,d5
      lea l81b(pc),a0
      move.b (a5)+,2(a0)
l81b: jmp 0(a3)
grap: sub #$d000,d2
      cmp #$1000,d2
      bcc grap1
      btst #2,$01(a6)
      beq grap1
      add #$d000,d2
      move.b d5,(a6,d2.l)
      bra c81
grap1:lea grbss,a0
      move.b d5,(a0,d2.l)
      btst #5,c64+$d011                 *Grafik-Modus?
      beq c81                           *nein-
      sub #$1000,d2
      cmp #8000,d2
      bcc c81
      jmp graph

op84:
      move.b (a5)+,d3
      move.b d7,(a6,d3.l)
      move.b (a5)+,l84-op84+$8402(a3)
l84:  jmp 0(a3)

op85:
      move.b (a5)+,d3
      move.b d5,(a6,d3.l)
      move.b (a5)+,l85-op85+$8502(a3)
l85:  jmp 0(a3)

op86:
      move.b (a5)+,d3
      move.b d6,(a6,d3.l)
      move.b (a5)+,l86-op86+$8602(a3)
l86:  jmp 0(a3)

op88:
      subq.b #1,d7
      move d4,ccr
      tst.b d7
      move sr,d4
      move.b (a5)+,l88-op88+$8802(a3)
l88:  jmp 0(a3)

op8a:
      move d4,ccr
      move.b d6,d5
      move sr,d4
      move.b (a5)+,l8a-op8a+$8a02(a3)
l8a:  jmp 0(a3)

op8c:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      move.b d7,(a6,d2.l)
      move.b (a5)+,l8c-op8c+$8c02(a3)
l8c:  jmp 0(a3)

sto8c:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      move d5,-(sp)
      move.b d7,d5
      jmp sto

op8d:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      move.b d5,(a6,d2.l)
      move.b (a5)+,l8d-op8d+$8d02(a3)
l8d:  jmp 0(a3)
      
sto8d:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      jmp stoa

op8e:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      move.b d6,(a6,d2.l)
      move.b (a5)+,l8e-op8e+$8e02(a3)
l8e:  jmp 0(a3)

sto8e:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      move d5,-(sp)
      move.b d6,d5
      jmp sto

op90:
      move.b (a5)+,d2
      btst #4,d4
      bne rt90
      ext d2
      add d2,a5
rt90: move.b (a5)+,l90-op90+$9002(a3)
l90:  jmp 0(a3)

op91:
      move.b (a5)+,d3
      move.b (a6,d3.l),-(a2)
      move.b 1(a6,d3.l),-(a2)
      move (a2)+,d2
      add d7,d2
      move.b d5,(a6,d2.l)
      move.b (a5)+,l91-op91+$9102(a3)
l91:  jmp 0(a3)

sto91:
      move.b (a5)+,d3
      move.b (a6,d3.l),-(a2)
      move.b 1(a6,d3.l),-(a2)
      move (a2)+,d2
      add d7,d2
      jmp stoa

op94:
      move.b (a5)+,d3
      add.b d6,d3
      move.b d7,(a6,d3.l)
      move.b (a5)+,l94-op94+$9402(a3)
l94:  jmp 0(a3)

op95:
      move.b (a5)+,d3
      add.b d6,d3
      move.b d5,(a6,d3.l)
      move.b (a5)+,l95-op95+$9502(a3)
l95:  jmp 0(a3)

op96:
      move.b (a5)+,d3
      add.b d7,d3
      move.b d6,(a6,d3.l)
      move.b (a5)+,l96-op96+$9602(a3)
l96:  jmp 0(a3)

op98:
      move d4,ccr
      move.b d7,d5
      move sr,d4
      move.b (a5)+,l98-op98+$9802(a3)
l98:  jmp 0(a3)

op99:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      add d7,d2
      move.b d5,(a6,d2.l)
      move.b (a5)+,l99-op99+$9902(a3)
l99:  jmp 0(a3)

sto99:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      add d7,d2
      jmp stoa

op9a:
      lea $0100(a6),a4
      add.l d6,a4
      move.b (a5)+,l9a-op9a+$9a02(a3)
l9a:  jmp 0(a3)

op9d:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      add d6,d2
      move.b d5,(a6,d2.l)
      move.b (a5)+,l9d-op9d+$9d02(a3)
l9d:  jmp 0(a3)

sto9d:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      add d6,d2
      jmp stoa

opa0:
      move d4,ccr
      move.b (a5)+,d7
      move sr,d4
      move.b (a5)+,la0-opa0+$a002(a3)
la0:  jmp 0(a3)

opa1:
      move.b (a5)+,d3
      add.b d6,d3
      move.b (a6,d3.l),-(a2)
      move.b 1(a6,d3.l),-(a2)
      move (a2)+,d2
      move d4,ccr
      move.b (a6,d2.l),d5
      move sr,d4
      move.b (a5)+,la1-opa1+$a102(a3)
la1:  jmp 0(a3)

opa2:
      move d4,ccr
      move.b (a5)+,d6
      move sr,d4
      move.b (a5)+,la2-opa2+$a202(a3)
la2:  jmp 0(a3)

opa4:
      move.b (a5)+,d3
      move d4,ccr
      move.b (a6,d3.l),d7
      move sr,d4
      move.b (a5)+,la4-opa4+$a402(a3)
la4:  jmp 0(a3)

opa5:
      move.b (a5)+,d3
      move d4,ccr
      move.b (a6,d3.l),d5
      move sr,d4
      move.b (a5)+,la5-opa5+$a502(a3)
la5:  jmp 0(a3)

opa6:
      move.b (a5)+,d3
      move d4,ccr
      move.b (a6,d3.l),d6
      move sr,d4
      move.b (a5)+,la6-opa6+$a602(a3)
la6:  jmp 0(a3)

opa8:
      move d4,ccr
      move.b d5,d7
      move sr,d4
      move.b (a5)+,la8-opa8+$a802(a3)
la8:  jmp 0(a3)

opa9:
      move d4,ccr
      move.b (a5)+,d5
      move sr,d4
      move.b (a5)+,la9-opa9+$a902(a3)
la9:  jmp 0(a3)

opaa:
      move d4,ccr
      move.b d5,d6
      move sr,d4
      move.b (a5)+,laa-opaa+$aa02(a3)
laa:  jmp 0(a3)

opac:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      move d4,ccr
      move.b (a6,d2.l),d7
      move sr,d4
      move.b (a5)+,lac-opac+$ac02(a3)
lac:  jmp 0(a3)

opad:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      move d4,ccr
      move.b (a6,d2.l),d5
      move sr,d4
      move.b (a5)+,lad-opad+$ad02(a3)
lad:  jmp 0(a3)

opae:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      move d4,ccr
      move.b (a6,d2.l),d6
      move sr,d4
      move.b (a5)+,lae-opae+$ae02(a3)
lae:  jmp 0(a3)

opb0:
      move.b (a5)+,d2
      btst #4,d4
      beq rtb0
      ext d2
      add d2,a5
rtb0: move.b (a5)+,lb0-opb0+$b002(a3)
lb0:  jmp 0(a3)

opb1:
      move.b (a5)+,d3
      move.b (a6,d3.l),-(a2)
      move.b 1(a6,d3.l),-(a2)
      move (a2)+,d2
      add d7,d2
      move d4,ccr
      move.b (a6,d2.l),d5
      move sr,d4
      move.b (a5)+,lb1-opb1+$b102(a3)
lb1:  jmp 0(a3)

opb4:
      move.b (a5)+,d3
      add.b d6,d3
      move d4,ccr
      move.b (a6,d3.l),d7
      move sr,d4
      move.b (a5)+,lb4-opb4+$b402(a3)
lb4:  jmp 0(a3)

opb5:
      move.b (a5)+,d3
      add.b d6,d3
      move d4,ccr
      move.b (a6,d3.l),d5
      move sr,d4
      move.b (a5)+,lb5-opb5+$b502(a3)
lb5:  jmp 0(a3)

opb6:
      move.b (a5)+,d3
      add.b d7,d3
      move d4,ccr
      move.b (a6,d3.l),d6
      move sr,d4
      move.b (a5)+,lb6-opb6+$b602(a3)
lb6:  jmp 0(a3)

opb8:
      and.b #$fd,d4
      move.b (a5)+,lb8-opb8+$b802(a3)
lb8:  jmp 0(a3)

opb9:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      add d7,d2
      move d4,ccr
      move.b (a6,d2.l),d5
      move sr,d4
      move.b (a5)+,lb9-opb9+$b902(a3)
lb9:  jmp 0(a3)

opba:
      move.l a4,d6
      sub.l #c64+$0100,d6
      move d4,ccr
      tst.b d6
      move sr,d4
      move.b (a5)+,lba-opba+$ba02(a3)
lba:  jmp 0(a3)

opbc:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      add d6,d2
      move.b (a6,d2.l),d7
      move.b (a5)+,lbc-opbc+$bc02(a3)
lbc:  jmp 0(a3)

opbd:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      add d6,d2
      move d4,ccr
      move.b (a6,d2.l),d5
      move sr,d4
      move.b (a5)+,lbd-opbd+$bd02(a3)
lbd:  jmp 0(a3)

opbe:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      add d7,d2
      move d4,ccr
      move.b (a6,d2.l),d6
      move sr,d4
      move.b (a5)+,lbe-opbe+$be02(a3)
lbe:  jmp 0(a3)

opc0:
      move d7,d3
      sub.b (a5)+,d3
      move sr,d4
      eor d1,d4
      move.b (a5)+,lc0-opc0+$c002(a3)
lc0:  jmp 0(a3)

opc1:
      move.b (a5)+,d3
      add.b d6,d3
      move.b (a6,d3.l),-(a2)
      move.b 1(a6,d3.l),-(a2)
      move (a2)+,d2
      move d5,d3
      sub.b (a6,d2.l),d3
      move sr,d4
      eor d1,d4
      move.b (a5)+,lc1-opc1+$c102(a3)
lc1:  jmp 0(a3)

opc4:
      move.b (a5)+,d3
      move d7,d2
      sub.b (a6,d3.l),d2
      move sr,d4
      eor d1,d4
      move.b (a5)+,lc4-opc4+$c402(a3)
lc4:  jmp 0(a3)

opc5:
      move.b (a5)+,d3
      move d5,d2
      sub.b (a6,d3.l),d2
      move sr,d4
      eor d1,d4
      move.b (a5)+,lc5-opc5+$c502(a3)
lc5:  jmp 0(a3)

opc6:
      move.b (a5)+,d3
      subq.b #1,(a6,d3.l)
      move d4,ccr
      tst.b (a6,d3.l)
      move sr,d4
      move.b (a5)+,lc6-opc6+$c602(a3)
lc6:  jmp 0(a3)

opc8:
      addq.b #1,d7
      move d4,ccr
      tst.b d7
      move sr,d4
      move.b (a5)+,lc8-opc8+$c802(a3)
lc8:  jmp 0(a3)

opc9:
      move d5,d3
      sub.b (a5)+,d3
      move sr,d4
      eor d1,d4
      move.b (a5)+,lc9-opc9+$c902(a3)
lc9:  jmp 0(a3)

opca:
      subq.b #1,d6
      move d4,ccr
      tst.b d6
      move sr,d4
      move.b (a5)+,lca-opca+$ca02(a3)
lca:  jmp 0(a3)

opcc:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      move d7,d3
      sub.b (a6,d2.l),d3
      move sr,d4
      eor d1,d4
      move.b (a5)+,lcc-opcc+$cc02(a3)
lcc:  jmp 0(a3)

opcd:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      move d5,d3
      sub.b (a6,d2.l),d3
      move sr,d4
      eor d1,d4
      move.b (a5)+,lcd-opcd+$cd02(a3)
lcd:  jmp 0(a3)

opce:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      subq.b #1,(a6,d2.l)
      move d4,ccr
      tst.b (a6,d2.l)
      move sr,d4
      move.b (a5)+,lce-opce+$ce02(a3)
lce:  jmp 0(a3)

opd0:
      move.b (a5)+,d2
      btst #2,d4
      bne rtd0
      ext d2
      add d2,a5
rtd0: move.b (a5)+,ld0-opd0+$d002(a3)
ld0:  jmp 0(a3)

opd1:
      move.b (a5)+,d3
      move.b (a6,d3.l),-(a2)
      move.b 1(a6,d3.l),-(a2)
      move (a2)+,d2
      add d7,d2
      move d5,d3
      sub.b (a6,d2.l),d3
      move sr,d4
      eor d1,d4
      move.b (a5)+,ld1-opd1+$d102(a3)
ld1:  jmp 0(a3)

opd5:
      move.b (a5)+,d3
      add.b d6,d3
      move d5,d2
      sub.b (a6,d3.l),d2
      move sr,d4
      eor d1,d4
      move.b (a5)+,ld5-opd5+$d502(a3)
ld5:  jmp 0(a3)

opd6:
      move.b (a5)+,d3
      add.b d6,d3
      subq.b #1,(a6,d3.l)
      move d4,ccr
      tst.b (a6,d3.l)
      move sr,d4
      move.b (a5)+,ld6-opd6+$d602(a3)
ld6:  jmp 0(a3)

opd8:
      bclr d1,d4
      move.b (a5)+,ld8-opd8+$d802(a3)
ld8:  jmp 0(a3)

opd9:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      add d7,d2
      move d5,d3
      sub.b (a6,d2.l),d3
      move sr,d4
      eor d1,d4
      move.b (a5)+,ld9-opd9+$d902(a3)
ld9:  jmp 0(a3)

opdd:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      add d6,d2
      move d5,d3
      sub.b (a6,d2.l),d3
      move sr,d4
      eor d1,d4
      move.b (a5)+,ldd-opdd+$dd02(a3)
ldd:  jmp 0(a3)

opde:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      add d6,d2
      subq.b #1,(a6,d2.l)
      move d4,ccr
      tst.b (a6,d2.l)
      move sr,d4
      move.b (a5)+,lde-opde+$de02(a3)
lde:  jmp 0(a3)

ope0:
      move d6,d3
      sub.b (a5)+,d3
      move sr,d4
      eor d1,d4
      move.b (a5)+,le0-ope0+$e002(a3)
le0:  jmp 0(a3)

ope1:
      move.b (a5)+,d3
      add.b d6,d3
      move.b (a6,d3.l),-(a2)
      move.b 1(a6,d3.l),-(a2)
      move (a2)+,d2
      move.b (a6,d2.l),d3
      eor d1,d4
      move d4,ccr
      btst d1,d4
      bne dce1
      subx.b d3,d5
      move sr,d4
      eor d1,d4
      move.b (a5)+,le1-ope1+$e102(a3)
le1:  jmp 0(a3)
dce1: or #$04,ccr
      sbcd d3,d5
      move sr,d4
      eor d1,d4
      move.b (a5)+,de1-ope1+$e102(a3)
de1:  jmp 0(a3)

ope4:
      move.b (a5)+,d3
      move d6,d2
      sub.b (a6,d3.l),d2
      move sr,d4
      eor d1,d4
      move.b (a5)+,le4-ope4+$e402(a3)
le4:  jmp 0(a3)

ope5:
      move.b (a5)+,d3
      move.b (a6,d3.l),d3
      eor d1,d4
      move d4,ccr
      btst d1,d4
      bne dce5
      subx.b d3,d5
      move sr,d4
      eor d1,d4
      move.b (a5)+,le5-ope5+$e502(a3)
le5:  jmp 0(a3)
dce5: or #$04,ccr
      sbcd d3,d5
      move sr,d4
      eor d1,d4
      move.b (a5)+,de5-ope5+$e502(a3)
de5:  jmp 0(a3)

ope6:
      move.b (a5)+,d3
      addq.b #1,(a6,d3.l)
      move d4,ccr
      tst.b (a6,d3.l)
      move sr,d4
      move.b (a5)+,le6-ope6+$e602(a3)
le6:  jmp 0(a3)

ope8:
      addq.b #1,d6
      move d4,ccr
      tst.b d6
      move sr,d4
      move.b (a5)+,le8-ope8+$e802(a3)
le8:  jmp 0(a3)

ope9:
      move.b (a5)+,d3
      eor d1,d4
      move d4,ccr
      btst d1,d4
      bne dce9
      subx.b d3,d5
      move sr,d4
      eor d1,d4
      move.b (a5)+,le9-ope9+$e902(a3)
le9:  jmp 0(a3)
dce9: or #$04,ccr
      sbcd d3,d5
      move sr,d4
      eor d1,d4
      move.b (a5)+,de9-ope9+$e902(a3)
de9:  jmp 0(a3)

opea:
      move.b (a5)+,lea-opea+$ea02(a3)
lea:  jmp 0(a3)

opec:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      move d6,d3
      sub.b (a6,d2.l),d3
      move sr,d4
      eor d1,d4
      move.b (a5)+,lec-opec+$ec02(a3)
lec:  jmp 0(a3)

oped:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      move.b (a6,d2.l),d3
      eor d1,d4
      move d4,ccr
      btst d1,d4
      bne dced
ndcsb:subx.b d3,d5
      move sr,d4
      eor d1,d4
      move.b (a5)+,led-oped+$ed02(a3)
led:  jmp 0(a3)
dced: or #$04,ccr
      sbcd d3,d5
      move sr,d4
      eor d1,d4
      move.b (a5)+,ded-oped+$ed02(a3)
ded:  jmp 0(a3)

opee:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      addq.b #1,(a6,d2.l)
      move d4,ccr
      tst.b (a6,d2.l)
      move sr,d4
      move.b (a5)+,lee-opee+$ee02(a3)
lee:  jmp 0(a3)

opf0:
      move.b (a5)+,d2
      btst #2,d4
      beq rtf0
      ext d2
      add d2,a5
rtf0: move.b (a5)+,lf0-opf0+$f002(a3)
lf0:  jmp 0(a3)

opf1:
      move.b (a5)+,d3
      move.b (a6,d3.l),-(a2)
      move.b 1(a6,d3.l),-(a2)
      move (a2)+,d2
      add d7,d2
      move.b (a6,d2.l),d3
      eor d1,d4
      move d4,ccr
      btst d1,d4
      bne dcf1
      subx.b d3,d5
      move sr,d4
      eor d1,d4
      move.b (a5)+,lf1-opf1+$f102(a3)
lf1:  jmp 0(a3)
dcf1: or #$04,ccr
      sbcd d3,d5
      move sr,d4
      eor d1,d4
      move.b (a5)+,df1-opf1+$f102(a3)
df1:  jmp 0(a3)

opf5:
      move.b (a5)+,d3
      add.b d6,d3
      move.b (a6,d3.l),d3
      eor d1,d4
      move d4,ccr
      btst d1,d4
      bne dcf5
      subx.b d3,d5
      move sr,d4
      eor d1,d4
      move.b (a5)+,lf5-opf5+$f502(a3)
lf5:  jmp 0(a3)
dcf5: or #$04,ccr
      sbcd d3,d5
      move sr,d4
      eor d1,d4
      move.b (a5)+,df5-opf5+$f502(a3)
df5:  jmp 0(a3)

opf6:
      move.b (a5)+,d3
      add.b d6,d3
      addq.b #1,(a6,d3.l)
      move d4,ccr
      tst.b (a6,d3.l)
      move sr,d4
      move.b (a5)+,lf6-opf6+$f602(a3)
lf6:  jmp 0(a3)

opf8:
      bset d1,d4
      move.b (a5)+,lf8-opf8+$f802(a3)
lf8:  jmp 0(a3)

opf9:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      add d7,d2
      move.b (a6,d2.l),d3
      eor d1,d4
      move d4,ccr
      btst d1,d4
      bne dcf9
      subx.b d3,d5
      move sr,d4
      eor d1,d4
      move.b (a5)+,lf9-opf9+$f902(a3)
lf9:  jmp 0(a3)
dcf9: or #$04,ccr
      sbcd d3,d5
      move sr,d4
      eor d1,d4
      move.b (a5)+,df9-opf9+$f902(a3)
df9:  jmp 0(a3)

opfd:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      add d6,d2
      move.b (a6,d2.l),d3
      eor d1,d4
      move d4,ccr
      btst d1,d4
      bne dcfd
      subx.b d3,d5
      move sr,d4
      eor d1,d4
      move.b (a5)+,lfd-opfd+$fd02(a3)
lfd:  jmp 0(a3)
dcfd: or #$04,ccr
      sbcd d3,d5
      move sr,d4
      eor d1,d4
      move.b (a5)+,dfd-opfd+$fd02(a3)
dfd:  jmp 0(a3)

opfe:
      move.b (a5)+,-(a2)
      move.b (a5)+,-(a2)
      move (a2)+,d2
      add d6,d2
      addq.b #1,(a6,d2.l)
      move d4,ccr
      tst.b (a6,d2.l)
      move sr,d4
      move.b (a5)+,lfe-opfe+$fe02(a3)
lfe:  jmp 0(a3)


swlo:
        movem.l a0-a3/d0-d3,-(sp)
        move.l opage,a0
        lea savnr+6,a1
        lea sav81,a2
        lea op,a3
        moveq #6,d3
swlo2:  move (a2),d0
        move 2(a2),(a2)+
        move d0,(a2)+
        move (a1)+,d1
        moveq #16,d2
swlo1:  move.l (a3,d0),(a0,d1)
        addq #4,d0
        addq #4,d1
        dbf d2,swlo1
        dbf d3,swlo2
        movem.l (sp)+,a0-a3/d0-d3
        rts

swhi:
        movem.l a0-a3/d0-d3,-(sp)
        move.l opage,a0
        lea savnr,a1
        lea sav11,a2
        lea op,a3
        moveq #2,d3
swhi2:  move (a2),d0
        move 2(a2),(a2)+
        move d0,(a2)+
        move (a1)+,d1
        moveq #16,d2
swhi1:  move.l (a3,d0),(a0,d1)
        addq #4,d0
        addq #4,d1
        dbf d2,swhi1
        dbf d3,swhi2
        movem.l (sp)+,a0-a3/d0-d3
        rts


sav11:  dc op11-op,ora11-op
sav31:  dc op31-op,and31-op
sav51:  dc op51-op,eor51-op
sav81:  dc op81-op,sto81-op
sav8d:  dc op8d-op,sto8d-op
sav91:  dc op91-op,sto91-op
sav99:  dc op99-op,sto99-op
sav9d:  dc op9d-op,sto9d-op
sav8e:  dc op8e-op,sto8e-op
sav8c:  dc op8c-op,sto8c-op

savnr:  dc $1100,$3100,$5100,$8100,$8d00,$9100,$9900,$9d00,$8e00,$8c00


      bss

      ds.b 2
area: ds.b 1

      even

ops:  ds.b 65536

c64:  ds.b 65536
