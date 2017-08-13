;-------------------------------------------------------------------------------
                >PART ' sys-struct '

;-------------------------------
                RSSET $00000038
MUSIC:          RS.L 1
LIB_ADR:        RS.L 1

                RSSET $000004CE
vbl_slot_first: RS.L 1          ; first executed vbl slot
vbl_slot0:      RS.L 1          ; fx vbl slot
script_slot:    RS.L 1
colors_ptr:     RS.L 1
EFFECT_TERMINATE_SIGNAL:RS.B 1
EFFECT_DONE_FLAG:RS.B 1
SR_vbl:         RS.W 1

total_time:     RS.L 1

music_hz:       RS.L 1

struct_end:     RS.L 0
                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------


                IFNE TEST
;-------------------------------------------------------------------------------
                jsr     save_mfp
                jsr     restore_mfp

                jsr     DRIVER_INC
save_mfp:       >PART
                move    #$2700,SR
                lea     mfp_regslist(PC),A0
                lea     mfp_save(PC),A1
sml:
                move.w  (A0)+,D0
                beq.s   smle
                movea.w D0,A2
                move.b  (A2),(A1)+
                bra.s   sml
smle:
                move    #$2300,SR
                rts
                ENDPART
restore_mfp:    >PART
                move    #$2700,SR

                lea     rte,A0
                move.l  A0,$00000110.w
                move.l  A0,$00000114.w
                move.l  A0,$00000134.w

                lea     mfp_regslist(PC),A0
                lea     mfp_save(PC),A1
rml:
                move.w  (A0)+,D0
                beq.s   rmle
                movea.w D0,A2
                move.b  (A1)+,(A2)
                bra.s   rml
rmle:
                move.b  #$C0,$FFFFFA23.w ; timer c data

                clr.b   $FFFFFA0F.w
                clr.b   $FFFFFA11.w
                move    #$2300,SR
                rts

mfp_save:       DS.B 16

mfp_regslist:
                DC.W $FA1F      ; td a
                DC.W $FA21      ; td b
                DC.W $FA23      ; td c
                DC.W $FA25      ; td d

                DC.W $FA19      ; tc a
                DC.W $FA1B      ; tc b
                DC.W $FA1D      ; tc cd

                DC.W $FA07
                DC.W $FA09
                DC.W $FA13
                DC.W $FA15
                DC.W $FA17

                DC.W 0
                ENDPART
DRIVER_INC:
                PATH 'C:\0NEW\TDOME\0YMPART\'
*  IBYTES 'DISKBLIB.PRG'
                EVEN
;-------------------------------------------------------------------------------
                ENDC

