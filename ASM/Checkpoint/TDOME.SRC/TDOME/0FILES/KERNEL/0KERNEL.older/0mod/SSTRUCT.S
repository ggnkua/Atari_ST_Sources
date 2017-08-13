;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
                >PART ' *** music struct *** '

                RSSET $00000038
music_vbl:      RS.L 1
music_start:    RS.L 1
;----------------------------------------------------------
                RSSET 0
Init__:         RS.L 1          ;  +0
Exit__:         RS.L 1          ;  +4
Replay__:       RS.L 1          ;  +8
Set_SID_flags__:RS.L 1          ; +12   D0: %00000ABC
Get_PlayPos__:  RS.L 1          ; +16
Set_PlayPos__:  RS.L 1          ; +20
Get_SID_state__:RS.L 1          ; +24
Get_Speed__:    RS.L 1          ;
Set_Speed__:    RS.L 1          ;

use_MFP__:      RS.B 1
                RSEVEN

                ENDPART
;-------------------------------------------------------------------------------
                >PART ' kernel data '
;-------------------------------------------------------------------------------
                RSSET 0
load_depack__:  RS.B 1          ;A0.fname, A1.buffer | D0.depacked_size
load__:         RS.B 1          ;A0.fname, A1.buffer | D0.loaded_size
depack__:       RS.B 1          ;A0.src  , A1.dest
relocate__:     RS.B 1          ;A0.prg
get_kernel_space__:RS.B 1       ;A0.kernel start D0.size
START_MAIN__:   RS.B 1          ;
Init_Kernel__:  RS.B 1          ;
wait_load_ready:RS.B 1          ;
start_main_music:RS.B 1         ;
Init_Kernel_ALL:RS.B 1          ;
Get_timeline_list:RS.B 1
Get_timeline_next:RS.B 1
;-------------------------------
lbuffer_size    EQU 2048        ; 8192

                RSSET $00000038
music_vbl_:     RS.L 1          ; $38
MUSIC_START:    RS.L 1          ; $3C

                RSSET $00000040
KERNEL_ADR:     RS.L 1
bytes_avail:    RS.L 1
load_pos:       RS.L 1
depack_pos:     RS.L 1
lbuffer_end:    RS.L 1
DEPACK_PTR:     RS.L 1          ; current depacked position

total_time:     RS.L 1

_d7:            RS.B 1
;-------------------------------
RTE_            EQU $00000030
RTS_            EQU $00000032
;-------------------------------------------------------------------------------
                ENDPART
;-------------------------------------------------------------------------------
                RSSET $000004CE
vbl_slot0:      RS.L 1          ; fx vbl slot
script_slot:    RS.L 1
colors_ptr:     RS.L 1
EFFECT_TERMINATE_SIGNAL:RS.B 1
res0:           RS.B 1
res1:           RS.B 1
res2:           RS.B 1
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

