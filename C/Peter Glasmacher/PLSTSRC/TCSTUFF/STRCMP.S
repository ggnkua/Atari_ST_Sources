        .globl strcmp
        .text
strcmp: tst     a0
        beq     h6a048
        tst     a1
        beq     h6a044                
h6a000: move.b  (a0)+,d0        ;1
        beq     h6a04c
        cmp.b   (a1)+,d0
        bne     h6a040

        move.b  (a0)+,d0        ;2
        beq     h6a04c
        cmp.b   (a1)+,d0
        bne     h6a040

        move.b  (a0)+,d0        ;3
        beq     h6a04c
        cmp.b   (a1)+,d0
        bne     h6a040

        move.b  (a0)+,d0        ;4
        beq     h6a04c
        cmp.b   (a1)+,d0
        bne     h6a040

        move.b  (a0)+,d0        ;5
        beq     h6a04c
        cmp.b   (a1)+,d0
        bne     h6a040

        move.b  (a0)+,d0        ;6
        beq     h6a04c
        cmp.b   (a1)+,d0
        bne     h6a040

        move.b  (a0)+,d0        ;7
        beq     h6a04c
        cmp.b   (a1)+,d0
        bne     h6a040

        move.b  (a0)+,d0        ;8
        beq     h6a04c
        cmp.b   (a1)+,d0
        beq     h6a000

h6a040: cmp.b   -(a1),d0
        bcs     h6a048
h6a044: moveq.l #1,d0
        rts
h6a048: moveq.l #-1,d0
        rts

h6a04c: tst.b   (a1)
        bne     h6a048
        moveq.l #0,d0
        rts
        .end
