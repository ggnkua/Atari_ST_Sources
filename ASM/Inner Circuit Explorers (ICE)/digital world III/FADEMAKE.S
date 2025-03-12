
fade_make:      lea       intro_pic+2(pc),a0
                lea       fading(pc),a3

                moveq     #16-1,d7
fade_pal:       movea.l   a3,a1
                move.w    (a0)+,d0

                move.w    d0,d1
                and.w     #$0f,d1
                bsr.s     fade_subr

                movea.l   a3,a1
                move.w    d0,d1
                and.w     #$f0,d1
                lsr.w     #4,d1
                bsr.s     fade_subr_2

                movea.l   a3,a1
                move.w    d0,d1
                and.w     #$0f00,d1
                lsr.w     #8,d1
                bsr.s     fade_subr_3

                adda.w    #15*2,a3
                dbra      d7,fade_pal
                rts

fade_subr:      cmp.w     #$08,d1
                beq.s     end_subr
                cmp.w     #$00,d1
                beq.s     end_subr

                lea       fade(pc),a2
no:             cmp.w     (a2)+,d1
                bne.s     no
wrt_fade:       move.w    (a2),(a1)+
                cmpi.w    #$00,(a2)+
                bne.s     wrt_fade
end_subr:       rts

fade_subr_2:    cmp.w     #$08,d1
                beq.s     end_subr_2
                cmp.w     #$00,d1
                beq.s     end_subr_2

                lea       fade(pc),a2
no_2:           cmp.w     (a2)+,d1
                bne.s     no_2
wrt_fade_2:     move.w    (a2),d2
                lsl.w     #4,d2
                or.w      d2,(a1)+
                cmpi.w    #$00,(a2)+
                bne.s     wrt_fade_2
end_subr_2:     rts

fade_subr_3:    cmp.w     #$08,d1
                beq.s     end_subr_3
                cmp.w     #$00,d1
                beq.s     end_subr_3

                lea       fade(pc),a2
no_3:           cmp.w     (a2)+,d1
                bne.s     no_3
wrt_fade_3:     move.w    (a2),d2
                lsl.w     #8,d2
                or.w      d2,(a1)+
                cmpi.w    #$00,(a2)+
                bne.s     wrt_fade_3
end_subr_3:     rts

**********************************************************************
fade:         dc.w $0f,$07,$0e,$06,$0d,$05,$0c,$04,$0b,$03,$0a,$02,$09,$01,$08,$00
fading:       ds.w 16*16


intro_pic:    ibytes 'ICE.PI1'
              even


