; multi-vbl effect template
; init
                bsr     wait_vbl
                bsr     swap_screens    ; SWAP SCREENS!!!
                move.l  #vbl_effect,vbl_slot0.w
                bsr     wait_vbl
loop:
                bsr     wait_vbl
                bra     loop


vbl_effect:
; ---- CALL EFFECT ROUTINES HERE ----

                bsr.s   frame_sync
                bsr     swap_screens
                rts


vbl_sync:       DC.L 5
frame_sync:
                move.l  vbl_sync(PC),D0
                subq.l  #1,D0
vsync:
                cmp.l   $00000466.w,D0
                bgt.s   vsync
                rts


