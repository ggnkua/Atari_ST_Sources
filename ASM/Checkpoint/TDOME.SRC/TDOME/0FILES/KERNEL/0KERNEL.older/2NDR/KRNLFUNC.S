;-------------------------------------------------------------------------------
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
music_vbl:      RS.L 1          ; $38
music_start:    RS.L 1          ; $3C

                RSSET $00000040
KERNEL_ADR:     RS.L 1
bytes_avail:    RS.L 1
load_pos:       RS.L 1
depack_pos:     RS.L 1

total_time:     RS.L 1
;-------------------------------
RTE_            EQU $00000030
RTS_            EQU $00000032
;-------------------------------------------------------------------------------
                ENDPART
;-------------------------------------------------------------------------------
                IFNE TEST
                bra     skip_kernel
                PATH 'C:\0NEW\2NDREAL\'
kernel:         IBYTES 'KERNEL.PRG'
                DS.B 2048       ; kernel bss
skip_kernel:
                ENDC
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------


