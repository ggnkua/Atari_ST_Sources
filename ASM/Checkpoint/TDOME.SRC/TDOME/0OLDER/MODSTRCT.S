;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
                >PART ' mod-player struct '
                RSSET 0
HBL_replay:     RS.B 1
TIMER_replay:   RS.B 1
spectrum_replay:RS.B 1
set_spectrum_color_adr_:RS.B 1  ; A0...colors start
get_colptr_inc_code_:RS.B 1     ; A0...output list
                ENDPART
                >PART ' system struct '
                RSSET $000004CE
vbl_slot_first: RS.L 1          ; first executed vbl slot
vbl_slot0:      RS.L 1          ; fx vbl slot
script_slot:    RS.L 1
colors_ptr:     RS.L 1
EFFECT_TERMINATE_SIGNAL:RS.B 1
res0:           RS.B 1
res1:           RS.B 1
res2:           RS.B 1
                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------


