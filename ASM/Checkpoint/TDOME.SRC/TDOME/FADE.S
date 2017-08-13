;-------------------------------------------------------------------------------
; pal0_mf + 0   src
; pal0_mf + 4   dest
; D0...fade_factor
fade_hw:        >PART

*   DC.L $4AFC4E71

                movem.l D0-D6/A0-A3,-(SP)

                lea     colors_faded_output(PC),A0
                lea     (A0),A2         ; *** OUTPUT ***
                bsr     set_main_colors

*  lea     $FFFF8240.w,A2  ; *** OUTPUT ***

                lea     fade_multable(PC),A0
                lea     (A0),A1
                moveq   #8,D1
                sub.w   D0,D1
                lsl.w   #4,D0
                lsl.w   #4,D1
                adda.w  D0,A0           ; fade_d7
                adda.w  D1,A1           ; fade_d6
                movem.l A0-A1,fade_mul_ptrs

                movem.l pal0_mf(PC),A0-A1

;-----------------------------------------------------------
                movea.l colors_ptr.w,A3
                movem.l (A3),D0-D6/A3

                cmpa.l  #current_fx_colors,A0
                bne.s   n_a0_currcol
                movem.l D0-D6/A3,(A0)   ; current_fx_colors
                bra.s   currcol_done
n_a0_currcol:
                cmpa.l  #current_fx_colors,A1
                bne.s   n_a1_currcol
                movem.l D0-D6/A3,(A1)   ; current_fx_colors
n_a1_currcol:
currcol_done:
;-----------------------------------------------------------


                move.w  #16-1,-(SP)     ; amount colors
mfl_colors_2:

; D0.r  D1.g  D2.b
                move.w  (A0)+,D0        ; rgb
                moveq   #7,D2
                and.w   D0,D2           ; b
                lsr.w   #4,D0
                moveq   #7,D1
                and.w   D0,D1           ; g
                lsr.w   #4,D0           ; r
; D0.r  D1.g  D2.b

; D3.r  D4.g  D5.b
                move.w  (A1)+,D3        ; rgb
                moveq   #7,D5
                and.w   D3,D5           ; b
                lsr.w   #4,D3
                moveq   #7,D4
                and.w   D3,D4           ; g
                lsr.w   #4,D3           ; r

                movea.l fade_mul_ptrs+4(PC),A3 ; d6
                add.w   D0,D0
                add.w   D1,D1
                add.w   D2,D2
                move.w  0(A3,D0.w),D0
                move.w  0(A3,D1.w),D1
                move.w  0(A3,D2.w),D2

                movea.l fade_mul_ptrs(PC),A3 ; d6
                add.w   D3,D3
                add.w   D4,D4
                add.w   D5,D5
                add.w   0(A3,D3.w),D0
                add.w   0(A3,D4.w),D1
                add.w   0(A3,D5.w),D2

                lsr.w   #3,D0
                lsr.w   #3,D1
                lsr.w   #3,D2

                lsl.w   #4,D0
                or.w    D1,D0
                lsl.w   #4,D0
                or.w    D2,D0

                move.w  D0,(A2)+        ; output color

                subq.w  #1,(SP)
                bpl.s   mfl_colors_2
                addq.l  #2,SP

                movem.l (SP)+,D0-D6/A0-A3

                rts

fade_mul_ptrs:  DC.L 0,0

colors_faded_output:DS.W 16

                ENDPART
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
init_fade_multable:>PART

*  DC.L $4AFC4E71

                lea     fade_multable(PC),A0
                moveq   #0,D0
ifm0:
                moveq   #0,D1
ifm1:
                move.w  D0,D2
                mulu    D1,D2
                move.w  D2,(A0)+

                addq.w  #1,D1
                cmp.w   #7,D1
                ble.s   ifm1

                addq.w  #1,D0
                cmp.w   #8,D0
                ble.s   ifm0
                rts
                ENDPART
fade_multable:  DS.W 9*8
;-------------------------------------------------------------------------------


