/* This routine is never used and is identical to R138_lzzz_COPYPROTECTIONEF_HiddenCodeLauncher but without some of the data at the end */
asm {
        Graphic548:
                lea     Graphic548+0x3C(PC),A0
                clr.w   (A0)+
                movea.l jmpTarget(PC),A1
                move.l  (A0)+,(A1)+
                move.w  (A0),(A1)
                movea.l GetGraphicAddressFunction(PC),A0
                move.w  Graphic548+0x32(PC),-(A7)
                jsr     (A0)
                movea.l D0,A0
                move.l  Graphic548+0x38(PC),-(A7)
                move.l  Graphic548+0x34(PC),-(A7)
                jsr     (A0)
                lea     10(A7),A7
                dc.w    0x4EF9          /* jmp instruction */
        jmpTarget:
                dc.l    0x00000000      /* jmp instruction target address */
        GetGraphicAddressFunction:
                dc.w    0x0000
}
