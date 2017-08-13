
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
__start_main_music:RS.B 1       ;
Init_Kernel_ALL:RS.B 1          ;
Get_timeline_list:RS.B 1
Get_timeline_next:RS.B 1

load__noReadyWait__:RS.B 1
get__loaderstate__:RS.B 1
load__sectors__:RS.B 1

;-------------------------------
lbuffer_size    EQU 2048        ; 8192

**  RSSET $00000040
                RSSET $00000300
KERNEL_ADR:     RS.L 1
bytes_avail:    RS.L 1
load_pos:       RS.L 1
depack_pos:     RS.L 1
depacked_ptr:   RS.L 1          ; pointer to next memory location depack

current_loadStart:RS.L 1
current_loadAddress:RS.L 1

;-------------------------------
RTE_            EQU $00000030
RTS_            EQU $00000032
;-------------------------------------------------------------------------------
                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------


                bra     skip_kernel

__KernelCall:
                movea.l KERNEL_ADR.w,A3
                jsr     (A3)
                rts

                IFNE TEST
                DS.B 1024       ; kernel stack
KERNEL_INC:
                PATH 'C:\0NEW\TDOME\0FILES\KERNEL\'
                IBYTES 'KERNEL.PRG'
                EVEN

                moveq   #-1,D0          ; init kernel
                moveq   #-1,D1
                jsr     KERNEL_INC

                moveq   #load_depack__,D0 ;A0.fname, A1.buffer | D0.depacked_size
                bsr     __KernelCall

                ENDC
skip_kernel:
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
