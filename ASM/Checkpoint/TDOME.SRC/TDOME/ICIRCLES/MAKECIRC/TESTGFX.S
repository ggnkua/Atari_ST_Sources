;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
                bsr     output_gfx

output_gfx:     >PART
                lea     gfx_0,A0
                movea.l screen1,A1
                bsr     gfx_out
                rts
                ENDPART
gfx_out:        >PART
                move.w  (A0)+,D0        ; width
                lsr.w   #4,D0           ; /16
                subq.w  #1,D0

                move.w  (A0)+,D1        ; height
                subq.w  #1,D1
og_y:
                lea     (A1),A2
                move.w  D0,D2
og_x:
                move.w  (A0)+,(A2)
                addq.l  #8,A2
                dbra    D2,og_x
                lea     160(A1),A1
                dbra    D1,og_y
                rts
                ENDPART
gfx_0:
                PATH 'C:\0NEW\ML.10\3D\POLYSPLT\'
                PATH 'GFXCONV.ERT\'
                IBYTES '0_KB.GFX'
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
