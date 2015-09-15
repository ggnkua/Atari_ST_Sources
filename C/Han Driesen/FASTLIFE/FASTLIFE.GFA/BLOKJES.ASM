        section text

p4:     bra.s   pix4

p8:     bra.s   pix8

pix16:  movea.l $0004(a7),a0
        adda.l  a0,a0
        moveq   #-2,d0
        eor.w   d0,(a0)
        eor.w   d0,$0050(a0)
        eor.w   d0,$00A0(a0)
        eor.w   d0,$00F0(a0)
        eor.w   d0,$0140(a0)
        eor.w   d0,$0190(a0)
        eor.w   d0,$01E0(a0)
        eor.w   d0,$0230(a0)
        eor.w   d0,$0280(a0)
        eor.w   d0,$02D0(a0)
        eor.w   d0,$0320(a0)
        eor.w   d0,$0370(a0)
        eor.w   d0,$03C0(a0)
        eor.w   d0,$0410(a0)
        eor.w   d0,$0460(a0)
        rts

pix4:   move.l  $0004(a7),d0
        moveq   #-$20,d1
        lsr.l   #1,d0
        bcc.s   skip1
        ror.b   #4,d1
skip1:  movea.l d0,a0
        eor.b   d1,(a0)
        eor.b   d1,$0050(a0)
        eor.b   d1,$00A0(a0)
        rts

pix8:   movea.l $0004(a7),a0
        moveq   #-2,d0
        eor.b   d0,(a0)
        eor.b   d0,$0050(a0)
        eor.b   d0,$00A0(a0)
        eor.b   d0,$00F0(a0)
        eor.b   d0,$0140(a0)
        eor.b   d0,$0190(a0)
        eor.b   d0,$01E0(a0)
        rts

        end
