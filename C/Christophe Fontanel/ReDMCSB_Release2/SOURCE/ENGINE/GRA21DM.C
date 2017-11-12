/* This routine is identical to the one used in CSB except at the end. See comments in GRA21CSB.S */
asm {
                movem.l D6-D7/A3,-(A7)
                movea.l 16(A7),A0
                lea     20(A0),A0
                movea.l 20(A7),A3
                movea.l (A3)+,A1
                move.w  #489,D6
                moveq   #16,D7
                moveq   #0,D0
        InspectionLoop:
                moveq   #0,D1
                moveq   #0,D2
        AnalysisLoop:
                move.b  (A0)+,D3
                bpl.s   FuzzyBitClear
                bset    D1,D2
                andi.b  #0x7F,D3
        FuzzyBitClear:
                cmpi.b  #0x68,D3
                beq.s   ValidByte
                moveq   #0,D0
                bra.s   ExitInspectionLoop
        ValidByte:
                addq.w  #1,D1
                subq.w  #1,D6
                beq.s   ExitAnalysisLoop
                cmp.w   D7,D1
                bne.s   AnalysisLoop
        ExitAnalysisLoop:
                cmp.w   (A1),D2
                beq.s   NoDifferenceFound
                addq.w  #1,D0
        NoDifferenceFound:
                move.w  D2,(A1)+
                tst.w   D6
                bne.s   InspectionLoop
        ExitInspectionLoop:
                movea.l (A3)+,A0
                move.w  #136,(A0)
                tst.w   D0
                bne.s   DiskIsOriginal
                movea.l (A3),A3
                clr.l   (A3)
        DiskIsOriginal:
                movem.l (A7)+,D6-D7/A3
                rts
                dc.l    0x00000000
}