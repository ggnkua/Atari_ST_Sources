;-------------------------------------------------------------------------------
TEST            EQU 0
MUSIC_LIB       EQU 0           ; lib: TEST: 0
;-------------------------------------------------------------------------------
VIDSIZE         EQU 160000
;-------------------------------------------------------------------------------
                IFNE MUSIC_LIB
                OUTPUT 'DISKBLIB.PRG'
                ELSE
                OUTPUT 'DISKB.PRG'
                ENDC
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


;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
program_start:

*   move.l  intro_end_adr(PC),D0
                bsr     get_absolute_address

                IFNE TEST

;-------------------------------------------------------------------------------
                >PART ' TEST - LOAD FILES FROM HDD '

                move.l  #'HDD!',D2      ; load first vq-audio from hdd

                move.l  D2,hd_flag

                cmpi.l  #'HDD!',hd_flag
                bne.s   no_hd_load

*   lea     codebook_0_fn(PC),A0
*   lea     codebook_0_loaded,A1
*   bsr     gemdos_loadfile

no_hd_load:
                bra     skip_kernel

intro_fn:
                DC.B "C:\0NEW\TDOME\INTRO\"
                DC.B "INTRO.PRG",0

codebook_intro_fn:
                DC.B "C:\0NEW\TDOME\0MUSIC\0BERO.NEW\"
                DC.B "CODEBOOK.INT",0
stream_intro_fn:
                DC.B "C:\0NEW\TDOME\0MUSIC\0BERO.NEW\"
                DC.B "VQST_0.INT",0


codebook_0_fn:
                DC.B "C:\0NEW\TDOME\0MUSIC\0BERO.NEW\"
                DC.B "CODEBOOK.DAT",0
stream_0_fn:
                DC.B "C:\0NEW\TDOME\0MUSIC\0BERO.NEW\"
                DC.B "VQST_0.STR",0

                EVEN

                ENDPART
;-------------------------------------------------------------------------------

hd_flag:        DC.L 0

                DS.B 1024       ; kernel stack
KERNEL_INC:
                PATH 'C:\0NEW\TDOME\0FILES\KERNEL\'
                IBYTES 'KERNEL.PRG'
                EVEN

                moveq   #-1,D0
                moveq   #-1,D1
                jsr     KERNEL_INC

                moveq   #load_depack__,D0 ;A0.fname, A1.buffer | D0.depacked_size
; a0
; a1
                jsr     __KernelCall
                ENDC
skip_kernel:
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
                IFEQ TEST
                cmp.l   #'DEMO',D1
                beq     DEMO_START
                bra     INIT_LIB
                ENDC
;-------------------------------------------------------------------------------
                bra     __start__
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
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



;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
                >PART ' info & defs '
;
; full bitstream implementation(codebook embedded in stream)
;
; fast ym-sample-replay
;
; max. optimized vq-decoding
;
; semi-adaptive, multi-codebooks
;
;-------------------------------------------------------------------------------
CODE_BOOKS      EQU 1
CBOOK           EQU 1024
BLOCK_SIZE      EQU 8
;-------------------------------------------------------------------------------
; timer data for app. 15650 Hz
Timer_Ctrl      EQU 1
Timer_Data      EQU $00000027
;-------------------------------------------------------------------------------
                ENDPART
;-------------------------------------------------------------------------------
__start__:
                OPT D-
                IFNE TEST
                OPT D+
                >PART ' init machine '
                clr.l   -(SP)
                move.w  #$0020,-(SP)
                trap    #1

                move    #$2700,SR
                clr.l   $FFFFFA06.w
                clr.l   $FFFFFA12.w

                lea     stack,SP

                move.l  #cnt_vbl,$00000070.w
                move    #$2300,SR

                bsr     wait_vbl
                bsr     wait_vbl
                clr.b   $FFFF8260.w
                move.b  #2,$FFFF820A.w

                ENDPART

                jsr     save_memory

                jsr     save_mfp

                moveq   #-1,D0
                moveq   #-1,D1
                jsr     KERNEL_INC


*   DC.L $4AFC4E71

                move.l  hd_flag(PC),D2  ; HDD! for hd load

                jmp     DEMO_START      ****************************


** jsr     instr_cycle     *********************

                PART

                bsr     wait_vbl


                jsr     INIT_LIB

loop:
                bsr     wait_vbl

                clr.w   $FFFF8240.w

                move.w  scol(PC),$FFFF8240.w


*   move.w  #196,D0

                move.w  #50,D0
                bsr     wait_scanlines

                move.w  #$0007,$FFFF8240.w

                move.b  $FFFFFC02.w,D0
                cmp.b   oldkey(PC),D0
                beq.s   loop
                move.b  D0,oldkey

                cmp.b   #$3B,D0
;  beq.s   f1
                cmp.b   #$3C,D0
;  beq.s   f2

                cmp.b   #$62,D0
                bne.s   n62
                move.w  #$0007,$FFFF8240.w
n62:
                cmp.b   #$39,D0
                bne.s   loop
                DC.L $4AFC4E71
                bra.s   loop
f1:

oldkey:         DC.W 0
scol:           DC.W $0070

                ENDPART

wait_scanlines: >PART
                DS.W 128-3,$00004E71
                dbra    D0,wait_scanlines
                rts
                ENDPART

regs:           DS.L 32,$AAAAAAAA

                ENDC
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

sector_buffer_address:DC.L 0

check_Disk_B:   >PART

*    DC.L $4AFC4E71

                move.l  $00000070.w,-(SP)
                bsr     wait_vbl
                clr.l   db_colindex
                move.l  #disk_b_vbl,$00000070.w
db_loop:
                movea.l sector_buffer_address(PC),A0
                lea     boot_sector_struct(PC),A1
                moveq   #load__sectors__,D0
                bsr     __KernelCall

                movea.l sector_buffer_address(PC),A0
                cmpi.l  #"TD#2",$0020(A0)
                bne.s   db_loop
disk_b_ok:
                move.l  (SP)+,$00000070.w
                bsr     wait_vbl
                clr.w   $FFFF8240.w
                rts
db_colindex:    DC.L 0
disk_b_vbl:
                move.l  D0,-(SP)
                move.l  db_colindex(PC),D0
                lsr.l   #1,D0
                and.l   #15,D0
                cmp.w   #7,D0
                ble.s   dbok
                neg.w   D0
                add.w   #15,D0
dbok:
                mulu    #$0100,D0
                move.w  D0,$FFFF8240.w

                addq.l  #1,db_colindex

                move.l  (SP)+,D0
                rte

boot_sector_struct:
                DC.W 0          ; track
                DC.W 1          ; sector
                DC.W 0          ; side
                DC.W 1          ; count
                ENDPART


KB              SET 1000

start_d2:       DC.L 0


DEMO_START:

*   DC.L $4AFC4E71

                move.l  D2,start_d2
                move    #$2700,SR
                lea     stack,SP
                clr.l   $FFFFFA06.w
                clr.l   $FFFFFA12.w
                bclr    #3,$FFFFFA17.w  ; auto eoi
                move.l  #cnt_vbl,$00000070.w
                move    #$2300,SR

; depack music
                lea     music_nrv,A0
                lea     music,A1
                moveq   #depack__,D0    ;A0.src  , A1.dest
                bsr     __KernelCall

                bsr     INIT_LIB

*     IFNE TEST
*     lea     memend_test,A0
*     ELSE
                lea     $000FFFF0,A0
*     ENDC

                lea     (A0),A3

                lea     -512(A0),A1
                move.l  A1,sector_buffer_address

                suba.l  #VIDSIZE,A0
                move.l  A0,video_address

                suba.l  #36000,A0
                move.l  A0,_36k_address

                lea     (A3),A0
                suba.l  #96000,A0
                move.l  A0,_96k_address

                lea     (A3),A0
                suba.l  #210*KB,A0
                move.l  A0,endpart_load_address

;-------------------------------------------------------------------

*  DC.L $4AFC4E71

                bsr     init_sintab


                bsr     wait_vbl
                clr.l   total_time.w
demo_loop:
                bsr     wait_vbl
                bsr     script_rout

                IFNE TEST
                move.b  $FFFFFC02.w,D0
                cmp.b   #$39,D0
                bne.s   demo_loop

                move.l  address_MAX(PC),D0
                DC.L $4AFC4E71
                ENDC

                bra.s   demo_loop


video_address:  DC.L 0

_36k_address:   DC.L 0
_96k_address:   DC.L 0

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
script_rout:    >PART

;     DC.L $4AFC4E71

                bsr.s   do_script_subs

                subq.l  #1,script_delay
                bpl.s   sr_wait

                moveq   #0,D0
                movea.l script_pos(PC),A0
                movea.l (A0)+,A1
                jsr     (A1)
sr_wait:
                addq.l  #1,t
                rts
do_script_subs:
                move.l  script_sub0(PC),D0
                beq.s   *+4
                movea.l D0,A0
                jsr     (A0)

                move.l  script_sub1(PC),D0
                beq.s   *+4
                movea.l D0,A0
                jsr     (A0)

                move.l  script_sub2(PC),D0
                beq.s   *+4
                movea.l D0,A0
                jsr     (A0)


                rts

script_pos:     DC.L script
script_delay:   DC.L 0
t:              DC.L 0


script_sub0:    DC.L 0
script_sub1:    DC.L 0
script_sub2:    DC.L 0

                ENDPART
WAIT:           >PART
                move.l  (A0)+,script_delay
                move.l  A0,script_pos
                rts
                ENDPART
MOVE_L:         >PART
                move.l  (A0)+,D0        ; value
                movea.l (A0)+,A1        ; address
                move.l  D0,(A1)
                move.l  A0,script_pos
                rts
                ENDPART
MOVE_W:         >PART
                move.l  (A0)+,D0        ; value
                movea.l (A0)+,A1        ; address
                move.w  D0,(A1)
                move.l  A0,script_pos
                rts
                ENDPART
MOVE_B:         >PART
                move.l  (A0)+,D0        ; value
                movea.l (A0)+,A1        ; address
                move.b  D0,(A1)
                move.l  A0,script_pos
                rts
                ENDPART
CLR_L:          >PART
                movea.l (A0)+,A1        ; address
                clr.l   (A1)
                move.l  A0,script_pos
                rts
                ENDPART
CLR_W:          >PART
                movea.l (A0)+,A1        ; address
                clr.w   (A1)
                move.l  A0,script_pos
                rts
                ENDPART
CLR_B:          >PART
                movea.l (A0)+,A1        ; address
                clr.b   (A1)
                move.l  A0,script_pos
                rts
                ENDPART
ST:             >PART
                movea.l (A0)+,A1        ; address
                st      (A1)
                move.l  A0,script_pos
                rts
                ENDPART
SF:             >PART
                bra.s   CLR_B
                ENDPART
EXEC:           >PART
                movea.l (A0)+,A1
                move.l  A0,script_pos
                jsr     (A1)
                rts
                ENDPART
HALT:           >PART
                rts
                ENDPART
END:            >PART
                move.l  #'END!',D0
                rts
                ENDPART
ILL:            >PART
                DC.L $4AFC4E71
                move.l  A0,script_pos
                rts
                ENDPART
GOTO:           >PART
                movea.l (A0)+,A0
                move.l  A0,script_pos
                rts
                ENDPART
;-------------------------------------
fade_speed:     DC.W 0
fade_scounter:  DC.W 0
fade_num:       DC.W 0
;-------------------------------------
script:
                IFEQ MUSIC_LIB
                PART

                DC.L CLR_L,total_time
script_restart:

*    DC.L GOTO,turntstart
*    DC.L GOTO,marstart


*    DC.L GOTO,wizplsma_start


                DC.L __depack
                DC.L _3d_wizard
                DC.L __start
                DC.L __wait_end

                DC.L __depack
                DC.L twister
                DC.L __start
                DC.L __wait_end

turntstart:
                DC.L __depack
                DC.L turntable
                DC.L __start
                DC.L __wait_end

marstart:
                DC.L __depack
                DC.L marcubes
                DC.L __start
                DC.L __wait_end

                DC.L __depack
                DC.L greets
                DC.L __start
                DC.L __wait_end

wizplsma_start:
                DC.L __depack
                DC.L wizplasma
                DC.L __start
                DC.L LOAD_ENDPART ;;;
                DC.L __wait_end
                DC.L WaitLoad   ;;;

                DC.L DEPACK_ENDPART ;;;
***    DC.L __start

;;;  DC.L LOAD_DEPACK_ENDPART
                DC.L START_ENDPART
Q:
                DC.L HALT
                DC.L HALT
                DC.L HALT

                DC.L GOTO,script_restart


                DC.L LOAD_ENDPART
                DC.L WaitLoad


                ENDC

waitload_ready: >PART
                pea     (A0)
                moveq   #wait_load_ready,D0
                bsr     __KernelCall
                movea.l (SP)+,A0
                move.l  A0,script_pos
                rts
                ENDPART


LOAD_VIDEO:     >PART

                movea.l (A0)+,A1        ; fname
;    lea     video_0_fname(PC),A0
                pea     (A0)
                lea     (A1),A0

                movea.l video_address(PC),A1
                moveq   #load_depack__,D0 ;A0.fname, A1.buffer | D0.depacked_size

*    bsr     Set_Replay_Free

                bsr     __KernelCall

                movea.l (SP)+,A0
                move.l  A0,script_pos
                rts
                ENDPART


EFFECT_END_CHECK_VBL:>PART
                st      effect_end_vbl_flag
                move.l  A0,script_pos
                rts
effect_end_vbl_flag:DC.W 0
                ENDPART

vbl_end_effect: >PART

*   move    #$2700,SR
*   move.l  #hbl_lock,$00000068.w
*   move.l  #rte,$00000120.w
*   clr.b   $FFFFFA1B.w
*   bclr    #0,$FFFFFA07.w  ;Timer B OFF
*   bclr    #0,$FFFFFA13.w  ;Timer B OFF

                clr.l   vbl_slot_first.w ; first executed vbl slot
                clr.l   vbl_slot0.w     ; fx vbl slot
                clr.l   script_slot.w
                clr.l   colors_ptr.w
                clr.b   EFFECT_TERMINATE_SIGNAL.w
*****clr.b   EFFECT_DONE_FLAG.w
;; move.w  #$2400,SR_vbl.w
;; move    #$2400,SR
                rts
                ENDPART

effect_end_sub_routine:DC.L 0

vbl_effect_end_check:>PART      ; called semaphore-locked !

                move.b  effect_end_vbl_flag(PC),D0
                beq.s   no_veec
                move.b  EFFECT_DONE_FLAG.w,D0
                beq.s   no_veec

                clr.b   effect_end_vbl_flag
                bsr     vbl_end_effect

                move.l  effect_end_sub_routine(PC),D0
                beq.s   no_eesr
                movea.l D0,A0
                jsr     (A0)
                clr.b   EFFECT_DONE_FLAG.w ;
no_eesr:
no_veec:
                rts
                ENDPART

hbl_lock:       >PART
                move    #$2700,SR
                move.b  #$23,(SP)
                rte
                ENDPART


__depack:       >PART

                move.l  (A0)+,dep_src_adr
                pea     (A0)

                movea.l dep_src_adr(PC),A0
                lea     effect_memory0,A1
                pea     (A1)
                moveq   #depack__,D0    ;A0.src  , A1.dest
                bsr     __KernelCall

                movea.l (SP)+,A0
                bsr     get_prg_stats

                movea.l (SP)+,A0
                move.l  A0,script_pos
                rts
dep_src_adr:    DC.L 0
                ENDPART

__start:        >PART

                pea     (A0)

                lea     effect_memory0,A0
                move.l  A0,start_jsr+2
                moveq   #relocate__,D0  ;A0.prg
                bsr     __KernelCall

                lea     sintab,A0

start_jsr:      jsr     0

                movea.l (SP)+,A0
                move.l  A0,script_pos
                rts
                ENDPART

endpart_address:DC.L effect_memory0+$00010000 ; because of low-mem tables!!


LOAD_ENDPART:   PART
                pea     (A0)

                lea     endpart_fn(PC),A0
                movea.l endpart_load_address(PC),A1
                moveq   #load__noReadyWait__,D0
                bsr     __KernelCall

                movea.l (SP)+,A0
                move.l  A0,script_pos
                rts
                ENDPART
DEPACK_ENDPART: >PART
                pea     (A0)

                movea.l endpart_load_address(PC),A0

***  lea     effect_memory0,A1

                movea.l endpart_address(PC),A1

                moveq   #depack__,D0    ;A0.src  , A1.dest
                bsr     __KernelCall

                movea.l (SP)+,A0
                move.l  A0,script_pos
                rts
                ENDPART



LOAD_DEPACK_ENDPART:
                pea     (A0)

                lea     endpart_fn(PC),A0
                movea.l endpart_address(PC),A1
                moveq   #load_depack__,D0 ;A0.fname, A1.buffer | D0.depacked_size
                bsr     __KernelCall

                movea.l (SP)+,A0
                move.l  A0,script_pos
                rts

START_ENDPART:
                movea.l endpart_address(PC),A0
                move.l  A0,start_jsrE+2
                moveq   #relocate__,D0  ;A0.prg
                bsr     __KernelCall

                lea     sintab,A0

start_jsrE:     jmp     0

                ENDPART




endpart_load_address:DC.L 0

endpart_fn:     DC.B "ENDPART.NRV",0
                EVEN

WaitLoad:       >PART
                pea     (A0)
                moveq   #get__loaderstate__,D0
                bsr     __KernelCall
                movea.l (SP)+,A0
                tst.b   D0
                beq.s   wem_notyet
                move.l  A0,script_pos
                rts
wem_notyet:
                rts
                ENDPART

EFFECT_END_SUB:
                st      effect_end_vbl_flag
                move.l  (A0)+,effect_end_sub_routine
                move.l  A0,script_pos
                rts

;-------------------------------------------------------------

__loaddepack:   >PART

                move.l  (A0)+,D0        ; method
                movea.l (A0)+,A2        ; filename
                pea     (A0)
                lea     (A2),A0

                add.w   D0,D0
                jmp     ld_methods(PC,D0.w)
ld_methods:
                OPT O-,W-
                bra.s   ld_to_effect0mem
                bra.s   ld_to_96k
                illegal
                illegal
                OPT O+,W+
ld_to_96k:
                movea.l _96k_address(PC),A1
                bra.s   ld_start
ld_to_effect0mem:
                lea     effect_memory0,A1
ld_start:
                moveq   #load_depack__,D0 ;A0.fname, A1.buffer | D0.depacked_size
                bsr     __KernelCall
                move.l  D0,depacked_size
ld_done:
                movea.l (SP)+,A0
                move.l  A0,script_pos
                rts

depacked_size:  DC.L 0
                ENDPART

__memcpy_current_96K:>PART

                pea     (A0)

                movea.l _96k_address(PC),A0
                lea     effect_memory0,A1
                move.l  depacked_size(PC),D0
                bsr     memcpy

                movea.l (SP)+,A0
                move.l  A0,script_pos
                rts
                ENDPART

;-------------------------------------------------------------


loadsub:        DC.L 0

__wait_end:     >PART

                pea     (A0)
wend_loop:
                bsr     wait_vbl

                move.l  loadsub(PC),D0  ; any request pending
                beq.s   no_loadsub
                movea.l D0,A0
                jsr     (A0)
no_loadsub:
                move.b  EFFECT_DONE_FLAG.w,D0
                beq.s   wend_loop


                bsr     clean_system

                movea.l (SP)+,A0
                move.l  A0,script_pos
                rts
                ENDPART

; A0.colors
set_colors:
                movem.l (A0),D0-D6/A3
                movem.l D0-D6/A3,$FFFF8240.w
                rts

clean_system:   >PART

                st      set_replay_colors_black

                bsr     wait_vbl

                clr.l   vbl_slot_first.w ; first executed vbl slot
                clr.l   vbl_slot0.w     ; fx vbl slot
                clr.l   script_slot.w
                clr.l   colors_ptr.w
                clr.b   EFFECT_TERMINATE_SIGNAL.w
                clr.b   EFFECT_DONE_FLAG.w
                move.w  #$2400,SR_vbl.w

                move    #$2700,SR
                move.l  #hbl_lock,$00000068.w
                move.l  #rte,$00000120.w
                clr.b   $FFFFFA1B.w
                bclr    #0,$FFFFFA07.w  ;Timer B OFF
                bclr    #0,$FFFFFA13.w  ;Timer B OFF

                move    #$2300,SR
                rts
                ENDPART


; A0...prg
get_prg_stats:  >PART

                movem.l D0-D3/A0-A1,-(SP)

                lea     2(A0),A1
                lea     $001C(A0),A0
                move.l  A0,D0

                adda.l  (A1)+,A0        ; text
                adda.l  (A1)+,A0        ; data
                move.l  A0,data_end
                adda.l  (A1)+,A0        ; bss
                lea     2048(A0),A0     ; extra savety
                move.l  A0,bss_end

                move.l  A0,D0
                bsr     get_absolute_address
                move.l  D0,address_end
                lea     address_MAX(PC),A0
                cmp.l   (A0),D0
                blt.s   nnmax
                move.l  D0,(A0)
nnmax:
                movem.l (SP)+,D0-D3/A0-A1
                rts
                ENDPART

; in: D0  out: D0.translated
get_absolute_address:>PART
                sub.l   #program_start,D0 ; start of kernel!
                add.l   #$00008000,D0   ;   absolute address start
                rts
                ENDPART

data_end:       DC.L 0
bss_end:        DC.L 0
address_end:    DC.L 0
am:
address_MAX:    DC.L 0

;-------------------------------------
fadeR:          >PART
                movem.l (A0)+,A1-A2
                exg     A1,A2
                bra.s   fade_
                ENDPART
fade:           >PART
                movem.l (A0)+,A1-A2
fade_:
                movem.l A1-A2,pal0_mf
                move.l  A0,script_pos
                clr.w   fade_num
                clr.w   fade_scounter
                rts
                ENDPART
wait_fade:      >PART
                lea     fade_scounter(PC),A1
                subq.w  #1,(A1)
                bpl.s   wfn
                move.w  fade_speed(PC),(A1)

                lea     fade_num(PC),A1
                move.w  (A1),D0
                bsr.s   fade_hw

                addq.w  #1,(A1)
                cmpi.w  #8,(A1)
                ble.s   wfn
                move.w  #8,(A1)
                move.l  A0,script_pos
wfn:
                rts
                ENDPART
set_fade_speed: >PART
                move.l  (A0)+,D0
                move.w  D0,fade_speed
                move.l  A0,script_pos
                rts
                ENDPART
white:          DS.W 16,$00000777
;-------------------------------------------------------------------------------
; pal0_mf + 0   src
; pal0_mf + 4   dest
; D0...fade_factor
fade_hw:        >PART

*    DC.L $4AFC4E71

                movem.l D0-D6/A0-A3,-(SP)

                move.w  D0,-(SP)        ; fade factor
mfl_fades:
                move.w  (SP),D0         ; fade1
                moveq   #8,D6
                sub.w   D0,D6           ; fade0
                move.w  D0,fade_d7
                move.w  D6,fade_d6

                movem.l pal0_mf(PC),A0-A1

                lea     $FFFF8240.w,A2  ; *** DEBUG ***

                move.w  #16-1,-(SP)     ; amount colors
mfl_colors:

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

                move.w  fade_d6(PC),D6
                mulu    D6,D0           ; f0
                mulu    D6,D1           ; f0
                mulu    D6,D2           ; f0

                move.w  fade_d7(PC),D6
                mulu    D6,D3           ; f1
                mulu    D6,D4           ; f1
                mulu    D6,D5           ; f1

                add.w   D3,D0           ; r mix
                add.w   D4,D1           ; g mix
                add.w   D5,D2           ; b mix

                lsr.w   #3,D0
                lsr.w   #3,D1
                lsr.w   #3,D2

                lsl.w   #4,D0
                or.w    D1,D0
                lsl.w   #4,D0
                or.w    D2,D0

                move.w  D0,(A2)+        ; output

                subq.w  #1,(SP)
                bpl.s   mfl_colors
                addq.l  #2,SP

*   addq.w  #1,(SP)
*   cmpi.w  #8,(SP)         ; 0...8
*   ble.s   mfl_fades

                addq.l  #2,SP

                movem.l (SP)+,D0-D6/A0-A3

                rts

fade_d6:        DC.W 0
fade_d7:        DC.W 0

pal0_mf:        DC.L 0,0

                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;----------------------------------------------------------------------------------
black:
zero:           DS.L 16
;----------------------------------------------------------------------------------
;----------------------------------------------------------------------------------
;----------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
init_sintab:    >PART           ;; 36 bytes!   (and the quality fit's !!)

;
; 36bytes Sine-generator   MC68000!!  (no 030 muls.l!) (w)`99 defjam/checkpoint!
;   * BUT a bit erroranous
;   * this version a bit corrected !?

size            SET 2048

;; Erweiterungsfaktor ist 65536*16384

sin_inc         SET 3294198     ;GENAU: 3294198     ;; 2*PI / size
cos_inc         SET -20212      ;   10106*2     ;; ((2*PI)^2) / (size^2)


                lea     sintab,A0
                moveq   #0,D0           ;oe

                move.l  #1*sin_inc,D3
                move.w  #2048-1,D6
init_sin_:
                move.l  D0,D4
                swap    D4

                move.w  D4,1*2048*2(A0)
                move.w  D4,(A0)+

                muls    #cos_inc,D4

                add.l   D4,D4
                swap    D4
                ext.l   D4

                add.l   D4,D3           ;sin_inc - erg1
                add.l   D3,D0           ;oe + sin_inc
                dbra    D6,init_sin_
                rts

                ENDPART
;-------------------------------------------------------------------------------

__KernelCall:   >PART
                movea.l KERNEL_ADR.w,A3
                jsr     (A3)
                rts
                ENDPART

set_replay_colors_black:DC.W 0

                IFNE TEST
gemdos_loadfile:>PART           ; A0.fname  A1.buffer

                lea     (A1),A6         ; buffer

                clr.w   -(SP)           ;read only
                pea     (A0)
                move.w  #$003D,-(SP)    ;open
                trap    #1
                addq.l  #8,SP
                move.w  D0,file_handle
                move.l  D0,D7
                bmi.s   err_open_file

                pea     (A6)            ;buffer
                move.l  #1512000,-(SP)  ;count
                move.w  D7,-(SP)        ;handle
                move.w  #$003F,-(SP)    ;read
                trap    #1
                lea     $000C(SP),SP
                tst.l   D0
                bmi.s   err_lf

                move.l  D0,-(SP)

                move.w  D7,-(SP)        ;handle
                move.w  #$003E,-(SP)    ;close
                trap    #1
                addq.l  #4,SP

                move.l  (SP)+,D0
lf_done:
                rts
err_open_file:
err_lf:
                move.w  #$0700,$FFFF8240.w
                DC.L $4AFC4E71
                DC.L $4AFC4E71
                DC.L $4AFC4E71
                moveq   #-1,D0
                rts

file_handle:    DC.W 0
                ENDPART
                ENDC

;-------------------------------------------------------------------------------

vbl_fx_sem:     DC.W 0

v:
vbl_routine:    PART

                movem.l D0-A6,-(SP)

                bsr     vbl_top_routine

*     move    SR_vbl.w,SR

                bsr     vbl_fx_rout

                bsr     timer_output

                movem.l (SP)+,D0-A6

                addq.l  #1,total_time.w

                addq.l  #1,$00000466.w
*    cmpi.b  #$21,SR_vbl.w
*    bne.s   no_hbl_vbl_end0
*    move.b  #$21,(SP)
no_hbl_vbl_end0:
                rte

                ENDPART

vbl_fx_rout:    PART
A:
                tas.b   vbl_fx_sem
                bne.s   vbl_locked2

                move    #$2300,SR       ; enable vbl

                move.l  vbl_slot0.w,D0  ; fx vbl slot
                beq.s   no_fx_vbl2
                movea.l D0,A0
                jsr     (A0)            ; vbl_slot0
no_fx_vbl2:
                bsr     vbl_effect_end_check
                move    #$2400,SR
                clr.b   vbl_fx_sem
vbl_locked2:
                rts



*   move    #$2700,SR
                tas.b   vbl_fx_sem
                bne.s   vbl_locked

                move.w  SR_vbl.w,D1
                cmp.w   #$2100,D1
                beq.s   vfr_hbl
                move.w  #$2300,D1       ; ENABLE VBL!!!
vfr_hbl:
                move    D1,SR           ; ENABLE HBL & VBL!!!
vfr_SR_done:
                move.l  vbl_slot0.w,D0  ; fx vbl slot
                beq.s   no_fx_vbl
                movea.l D0,A0
                jsr     (A0)            ; vbl_slot0
no_fx_vbl:
                bsr     vbl_effect_end_check

*   move    #$2700,SR
                clr.b   vbl_fx_sem      ; unlock semaphore
vbl_locked:
                move    SR_vbl.w,SR     ; restore SR
                rts
                ENDPART

vbl_empty:      >PART

                movem.l D0-A6,-(SP)

                bsr     vbl_top_routine

                movem.l (SP)+,D0-A6

                addq.l  #1,$00000466.w
                rte

                ENDPART

;-------------------------------------------------------------------------------
vbl_top_routine:PART

; timer-b setup etc.
                move.l  vbl_slot_first.w,D0 ; first executed vbl slot
                beq.s   *+4
                movea.l D0,A0
                jsr     (A0)

; set palette
                move.l  colors_ptr.w,D0
                beq.s   no_colors_set
                movea.l D0,A1
                movem.l (A1),D0-D6/A1
                movem.l D0-D6/A1,$FFFF8240.w
;; clr.l   colors_ptr.w
no_colors_set:
                rts
                ENDPART
;-------------------------------------------------------------------------------


;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
PRINT_HEX8      EQU 0
PRINT_HEX2      EQU $00000018
;-------------------------------------------------------------------------------
timer_output:   PART

*    bra.s   to_do           ;-------------

                rts

                move.b  $FFFFFC02.w,D0
                cmp.b   #$61,D0         ; UNDO
                beq.s   to_do

                IFNE TEST
                cmp.b   #$003B+9,D0     ; F10
                bne.s   to_no_break
                jmp     e               ;--------------------------------------
                ENDC
to_no_break:
                moveq   #0,D0
                rts
to_do:
*   move    SR,-(SP)
                move    #$2700,SR
                lea     $FFFF8240.w,A0
                move.l  (A0),-(SP)      ; save color0,1

                move.l  #$00000777,(A0) ; set display colors

                ENDPART
;----------------------------------------------------
to_display:     >PART

; get screen address
                moveq   #0,D0
                lea     $FFFF8201.w,A2
                movep.w 0(A2),D0
                lsl.l   #8,D0
                movea.l D0,A2           ; screen
;----------------------------------------------------
                lea     (A2),A1         ; screen
                moveq   #1,D6           ; reset x_inc
;----------------------------------------------------
; print min:sec:vbl

                move.l  total_time.w,D0
                divu    #50,D0

                move.l  D0,-(SP)        ; save t/50

                ext.l   D0

                divu    #60,D0
                move.l  D0,-(SP)
; D0...minutes
                bsr.s   display_num2    ; display minutes

                move.l  (SP)+,D0
                swap    D0              ; seconds
; D0...seconds
                bsr.s   display_num2    ; display seconds

                move.l  (SP)+,D0        ; t/50
                swap    D0              ; vbl_ticks
                bsr.s   display_num2    ; display vbl_ticks

;----------------------------------------------------

; print total_time ticks

                lea     1*8*160(A2),A1  ; screen
                moveq   #1,D6           ; reset x_inc

                move.l  total_time.w,D2 ; value
                moveq   #PRINT_HEX8,D3
                bsr.s   print_hex       ; hex8
;----------------------------------------------------
; print music position

                lea     2*8*160(A2),A1  ; screen
                moveq   #1,D6           ; reset x_inc

                move.l  D0,D2           ; play_position

                moveq   #PRINT_HEX2,D3
***   bsr.s   print_hex       ; hex2
;----------------------------------------------------
                ENDPART
;----------------------------------------------------
to_wait_cont:   >PART
                eori.w  #$0112,$FFFF8240.w
                cmpi.b  #$3B,$FFFFFC02.w ; F1
                bne.s   to_wait_cont

                move.l  (SP)+,$FFFF8240.w ; restore color0,1
*   move    (SP)+,SR
                moveq   #1,D0
                rts
                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
; D6...x_inc
; A1...screem
display_num2:   >PART           ; D0,D1, D6,A0,A1

                ext.l   D0
                divu    #10,D0
                bsr.s   display_num1
                swap    D0
                bsr.s   display_num1

; --> separator is following!

                ENDPART
separator:      >PART           ; D0,D1, D6,A1

                lea     (A1),A3         ; screen_pos
                moveq   #8-1,D0
s_y:
                moveq   #%00011100,D1   ; bit pattern
                bsr.s   output_d1_movepl
                dbra    D0,s_y
                bra.s   advance_cursor_x

                ENDPART
display_num1:   >PART           ; D0,D1, D6,A0,A1

                move.l  D0,-(SP)

                mulu    #7,D0
                lea     nums_gfx(PC,D0.w),A0

                lea     (A1),A3         ; screen_pos
                moveq   #7-1,D0         ; 7 lines!
dnt_y:
                moveq   #0,D1
                move.b  (A0)+,D1
                bsr.s   output_d1_movepl
                dbra    D0,dnt_y

                moveq   #0,D1
                bsr.s   output_d1_movepl ; line 8

                move.l  (SP)+,D0
advance_cursor_x:
                adda.w  D6,A1
                eori.w  #6,D6
                rts

                ENDPART
; D1.b, A3 screen
output_d1_movepl:>PART
                ror.l   #8,D1
                movep.l D1,0(A3)
                lea     160(A3),A3
                rts
                ENDPART
;-----------------------------------------------
; D2...digit
; D3...PRINT_HEXx (0...$1C)
;
print_hex:      >PART

                rol.l   D3,D2           ; shift to msb
phl:
                rol.l   #4,D2
                moveq   #$0F,D0
                and.w   D2,D0
                bsr.s   display_num1

                addq.w  #4,D3
                cmp.w   #$0020,D3
                bne.s   phl

                rts

                ENDPART
;-----------------------------------------------
                PATH 'C:\0NEW\TDOME\0FILES\KERNEL\'
nums_gfx:       IBYTES 'NUMS_7.GFX'
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
wait_vbl:       >PART

                move.l  D0,-(SP)
                move.l  $00000466.w,D0
wv2:
                cmp.l   $00000466.w,D0
                beq.s   wv2
                move.l  (SP)+,D0
                rts
woo:
                clr.l   $00000466.w
wv:             tst.l   $00000466.w
                beq.s   wv
                rts
                ENDPART
;-------------------------------------------------------------------------------
cnt_vbl:        >PART
                addq.l  #1,$00000466.w
rte:            rte
rts:            rts
                ENDPART
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
music_timer_b_on:>PART

*   move    #$2700,SR
*   clr.b   $FFFFFA1B.w
*   bclr    #0,$FFFFFA07.w  ;Timer B
*   bclr    #0,$FFFFFA13.w  ;Timer B

                lea     patch_list(PC),A0
plistl2:
                lea     music,A1
                adda.l  (A0)+,A1
                move.l  (A0)+,D0        ; orig
                move.w  D0,(A1)
                addq.l  #4,A0

                cmpi.l  #-1,(A0)
                bne.s   plistl2

                lea     music,A0
                move.w  driver_length(PC),D7
                move.w  #$021B,D0
                move.w  #$0221,D1
                move.w  #$0220,D2
ptb_a2:
                move.w  (A0)+,D6
                cmp.w   D0,D6
                bne.s   n1b_a2
                move.w  #$FA1B,-2(A0)
                bra.s   tbn_a2
n1b_a2:
                cmp.w   D1,D6
                bne.s   n21_a2
                move.w  #$FA21,-2(A0)
                bra.s   tbn_a2
n21_a2:
                cmp.w   D2,D6
                bne.s   n120_a2
                move.w  #$0120,-2(A0)
n120_a2:
tbn_a2:
                dbra    D7,ptb_a2

                move    #$2700,SR
                move.l  tb_music(PC),$00000120.w
                clr.b   $FFFFFA1B.w
                bset    #0,$FFFFFA07.w  ;Timer B
                bset    #0,$FFFFFA13.w  ;Timer B
                move    #$2300,SR
                rts
                ENDPART
music_timer_b_off:>PART

*     move    #$2700,SR
*     clr.b   $FFFFFA1B.w
*     bclr    #0,$FFFFFA07.w  ;Timer B
*     bclr    #0,$FFFFFA13.w  ;Timer B

                move.l  $00000120.w,tb_music

                lea     patch_list(PC),A0
plistl:
                lea     music,A1
                adda.l  (A0)+,A1
                addq.l  #4,A0
                move.l  (A0)+,D0
                move.w  D0,(A1)
                cmpi.l  #-1,(A0)
                bne.s   plistl

                lea     music,A0
                move.w  driver_length(PC),D7
                move.w  #$FA1B,D0
                move.w  #$FA21,D1
                move.w  #$0120,D2
ptb_a:
                move.w  (A0)+,D6
                cmp.w   D0,D6
                bne.s   n1b_a
                move.w  #$021B,-2(A0)
                bra.s   tbn_a
n1b_a:
                cmp.w   D1,D6
                bne.s   n21_a
                move.w  #$0221,-2(A0)
                bra.s   tbn_a
n21_a:
                cmp.w   D2,D6
                bne.s   n120_a
                move.w  #$0220,-2(A0)
n120_a:
tbn_a:
                dbra    D7,ptb_a

                move    #$2700,SR
                clr.b   $FFFFFA1B.w
                bclr    #0,$FFFFFA07.w  ;Timer B
                bclr    #0,$FFFFFA13.w  ;Timer B
                move    #$2300,SR
                rts
                ENDPART
                >PART ' music timer b patchlist '

driver_length:  DC.W $4600/2

tb_music:       DC.L 0

padr            EQU $00000200
patch_list:
                DC.L $0000189A,$000021C9,$00006016
                DC.L $00001F7C,$00000120,padr
                DC.L $00001F8A,$00000120,padr

                DC.L $000018F8,$0000FA13,padr
                DC.L $00001F36,$0000FA13,padr

                DC.L -1
                ENDPART
;-------------------------------------------------------------------------------

INIT_LIB:
                lea     INIT_LIB(PC),A6
                move.l  A6,LIB_ADR.w
                move.l  A6,MUSIC.w

                cmp.l   #"TBON",D0
                beq     music_timer_b_on
                cmp.l   #"TBOF",D0
                beq     music_timer_b_off

                move    #$2700,SR
                clr.l   $FFFFFA06.w
                clr.l   $FFFFFA12.w
                bclr    #3,$FFFFFA17.w  ; auto eoi

                lea     rte(PC),A0
                move.l  A0,$00000060.w
                move.l  A0,$00000068.w
                move.l  A0,$00000110.w
                move.l  A0,$00000114.w
                move.l  A0,$00000120.w
                move.l  A0,$00000134.w

                lea     vbl_slot_first.w,A0
                moveq   #(struct_end-vbl_slot_first)/4,D0
clr0:           clr.l   (A0)+
                dbra    D0,clr0

                bsr     relocate_driver

*  bsr     init_soundchip

                move.l  #vbl_routine,$00000070.w

                move.w  #$2400,SR_vbl.w

                bsr     init_music

                move    #$2300,SR
                bsr     wait_vbl
                rts

;-------------------------------------------------------------------------------
relocate_driver:>PART

                lea     program_start(PC),A0
                cmpa.l  #program_start,A0
                beq.s   relocated
                move.l  A0,D0

                adda.l  #relocation_table-program_start,A0

                move.l  (A0)+,D1        ;relocation info ??
                beq.s   end_relocation  ;nope...
                movea.l D0,A1           ; text start
                adda.l  D1,A1           ;1st adress - long offset
                moveq   #0,D1
relo_do:
                add.l   D0,(A1)         ;relocate!
RELO2:
                move.b  (A0)+,D1
                beq.s   end_relocation
                cmp.b   #1,D1
                bne.s   normal_distance
                lea     254(A1),A1
                bra.s   RELO2
normal_distance:
                adda.l  D1,A1
                bra.s   relo_do
end_relocation:
relocated:
                rts
                ENDPART
;-------------------------------------------------------------------------------
init_soundchip: >PART
                lea     $FFFF8800.w,A0
                move.w  #$0D00,D0
clr_ym:
                movep.w D0,0(A0)
                sub.w   #$0100,D0
                bpl.s   clr_ym
                move.w  #$07FF,D0
                movep.w D0,0(A0)
                rts
                ENDPART
;-------------------------------------------------------------------------------
e:
                IFNE TEST
                >PART
                move    #$2700,SR
                clr.l   $FFFFFA06.w
                clr.l   $FFFFFA12.w
                move.w  #$0700,$FFFF8240.w
                lea     rte,A0
                move.l  A0,$00000068.w
                move.l  A0,$00000070.w
                move.l  A0,$00000110.w
                move.l  A0,$00000114.w
                move.l  A0,$00000120.w
                move.l  A0,$00000134.w

                bsr     restore_memory
                jsr     restore_mfp

                move.w  #$0070,$FFFF8240.w
                DC.L $4AFC4E71
                DC.L $4AFC4E71
                DC.L $4AFC4E71
                DC.L $4AFC4E71
                DC.L $4AFC4E71
                ENDPART
                DC.L $4AFC4E71
save_memory:    >PART
                lea     $00000500.w,A0
                lea     memsave,A1
                bsr.s   sm_copy
                rts
                ENDPART
restore_memory: >PART
                lea     memsave,A0
                lea     $00000500.w,A1
                bsr.s   sm_copy
                rts
sm_copy:
                move.w  #$8000/4-1,D0
smcl:
                move.l  (A0)+,(A1)+
                dbra    D0,smcl
                rts
                ENDPART
                ENDC


;-------------------------------------------------------------------------------
; A0-->A1 , D0 length
memcpy:         >PART

                movem.l D0-D6/A0-A3,-(SP)

                divu    #4*32,D0
                bra.s   mcpy0_
mcpy0:
                movem.l (A0)+,D1-D6/A2-A3 ; 8*4 = 32
                movem.l D1-D6/A2-A3,(A1)
                movem.l (A0)+,D1-D6/A2-A3 ; 8*4 = 32
                movem.l D1-D6/A2-A3,1*32(A1)
                movem.l (A0)+,D1-D6/A2-A3 ; 8*4 = 32
                movem.l D1-D6/A2-A3,2*32(A1)
                movem.l (A0)+,D1-D6/A2-A3 ; 8*4 = 32
                movem.l D1-D6/A2-A3,3*32(A1)
                lea     4*32(A1),A1
mcpy0_:         dbra    D0,mcpy0

                clr.w   D0
                swap    D0
                divu    #4,D0
                bra.s   mcpy1_
mcpy1:
                move.l  (A0)+,(A1)+
mcpy1_:         dbra    D0,mcpy1

                swap    D0
                bra.s   mcpy2_
mcpy2:
                move.b  (A0)+,(A1)+
mcpy2_:         dbra    D0,mcpy2

                movem.l (SP)+,D0-D6/A0-A3

                rts
                ENDPART
;-------------------------------------------------------------------------------
memclr_a0_a1:   >PART
                movem.l D0/A0-A1,-(SP)
                move.l  A1,D0           ; end
                sub.l   A0,D0           ; length
                bsr.s   memclr
                movem.l (SP)+,D0/A0-A1
                rts
                ENDPART
;-------------------------------------------------------------------------------
; A0, D0 length
memclr:         >PART

                movem.l D0-D6/A0-A3,-(SP)

                adda.l  D0,A0

                movem.l zero(PC),D1-D6/A1-A3

                divu    #8*36,D0
                bra.s   _mc0
mc0:
                movem.l D1-D6/A1-A3,-(A0) ; 9*4 = 36
                movem.l D1-D6/A1-A3,-(A0) ; 9*4 = 36
                movem.l D1-D6/A1-A3,-(A0) ; 9*4 = 36
                movem.l D1-D6/A1-A3,-(A0) ; 9*4 = 36
                movem.l D1-D6/A1-A3,-(A0) ; 9*4 = 36
                movem.l D1-D6/A1-A3,-(A0) ; 9*4 = 36
                movem.l D1-D6/A1-A3,-(A0) ; 9*4 = 36
                movem.l D1-D6/A1-A3,-(A0) ; 9*4 = 36
_mc0:           dbra    D0,mc0

                clr.w   D0
                swap    D0
                divu    #4,D0
                bra.s   _mcl1
mcl1:
                move.l  D1,-(A0)
_mcl1:          dbra    D0,mcl1

                swap    D0
                bra.s   _mcl2
mcl2:           move.b  D1,-(A0)
_mcl2:          dbra    D0,mcl2

                movem.l (SP)+,D0-D6/A0-A3
                rts
                ENDPART
;-------------------------------------------------------------------------------

                PATH 'C:\0NEW\TDOME\0YMPART\'

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
init_music:     >PART

                move    #$2700,SR

                clr.l   $000005A0.w     ; cookie jar   WICHTIG!!!!

                move.l  #trap_0,$00000080.w
                lea     (SP),A6
                move.l  #"CPT!",-(SP)
                trap    #0
                illegal
trap_0:
get_id:
                addq.w  #2,stackframe_size
                addq.l  #2,SP
                cmpi.l  #"CPT!",(SP)
                bne.s   get_id
                lea     (A6),SP

                move.l  #trap1,$00000084.w

                lea     rte(PC),A0
                move.l  A0,$00000060.w  ; NMI

                bclr    #3,$FFFFFA17.w  ; auto eoi

                moveq   #1,D0
                jsr     music_syd

                move    #$2700,SR

                andi.b  #$0F,$FFFFFA1D.w ; stop timer c
                move.l  #music_replay_timer,$00000114.w

                bset    #5,$FFFFFA09.w  ; enable timer c
                bset    #5,$FFFFFA15.w  ; enable timer c


                move.l  #69,D0          ; 69 Hz
                move.l  D0,music_hz.w
                bsr     set_music_speed_hz

                move    #$2300,SR
                rts
trap1:
*   DC.L $4AFC4E71
*   lea     (SP),A0
*   adda.w  stackframe_size(PC),A0
                move.l  #music_syd_bss,D0
                rte

stackframe_size:DC.W 0
                ENDPART
;-------------------------------------------------------------------------------
; D0.hz long
set_music_speed_hz:>PART

                cmp.w   old_music_hz(PC),D0
                beq.s   same_hz
                move.w  D0,old_music_hz
; Timer C
                bsr.s   Hertz_to_MFP
                lsl.b   #4,D0           ; c control
                andi.b  #$0F,$FFFFFA1D.w
                move.b  D1,$FFFFFA23.w  ; c data
                or.b    D0,$FFFFFA1D.w  ; c control set
same_hz:
                rts
old_music_hz:   DC.W 0
                ENDPART
;-------------------------------------------------------------------------------
; IN:    D0.l frequency in Hertz
; OUT:   D0.b timer prediv set
;        D1.b timer data
Hertz_to_MFP:   >PART


                lsl.l   #2,D0


; MFP frequency:   2.4576 MHz  =  2457600 Hz
;
; MFP prediv
; 1:4                              614400 Hz      (614.4 KHz)

                pea     (A0)
                lea     mfp_prediv_table(PC),A0
                lea     -12+4(A0),A0
mfp_get_min:
                lea     12(A0),A0
                cmp.l   (A0),D0
                blt.s   mfp_get_min
                move.l  -(A0),D1        ; MFP_freq * prediv
                divu    D0,D1           ; timer data
                move.l  8(A0),D0        ; timer prediv set
                movea.l (SP)+,A0
                rts

mfp_prediv_table:
; .l  MFP_freq * prediv       ( = max freq.)
; .l  MIN freq
; .l  MFP bits
                DC.L 614400,2409+1,%0000000000000001 ; 1:4
                DC.L 245760,963+1,%0000000000000010 ; 1:10
                DC.L 153600,602+1,%0000000000000011 ; 1:16
                DC.L 49152,192+1,%0000000000000100 ;  1:50
                DC.L 38400,150+1,%0000000000000101 ;  1:64
                DC.L 24576,96+1,%0000000000000110 ;  1:100
                DC.L 12288,48+1,%0000000000000111 ;  1:200
                ENDPART
;-------------------------------------------------------------------------------
mrt_speed:      DC.W 3
mrt_delay:      DC.W 0
music_replay_timer:PART

                move    #$2400,SR

                subq.w  #1,mrt_delay
                bpl.s   not_yet
                move.w  mrt_speed(PC),mrt_delay

* not.w   $FFFF8240.w

                movem.l D0-A6,-(SP)

                jsr     music_syd+8

                move.l  music_hz.w,D0
                bsr     set_music_speed_hz

                movem.l (SP)+,D0-A6

* not.w   $FFFF8240.w

not_yet:

                rte
                ENDPART
;-------------------------------------------------------------------------------
music_nrv:
                IBYTES 'FINALOOP.NRV'
                EVEN
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

                lea     music_nrv,A0
                lea     music,A1

                DATA
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
                IFEQ MUSIC_LIB
                PATH 'C:\0NEW\TDOME\0FILES\'
                PATH '0FILES.YM\'

_3d_wizard:     IBYTES '3D_WIZ.NRV'
twister:        IBYTES 'TWISTER.NRV'
turntable:      IBYTES 'TRNTBL.NRV'
marcubes:       IBYTES 'MARCUBES.NRV'
greets:         IBYTES 'GREETS.NRV'
wizplasma:      IBYTES 'WIZPLSMA.NRV'

                EVEN

                ELSE

turntable:
_3d_wizard:
twister:
wizplasma:

                ENDC

                PATH 'C:\0NEW\TDOME\'
                PATH '0YMPART\'
relocation_table:
;-------------------------------------------------------------------------------
                BSS

                IFNE TEST
memsave:        DS.B $8000
                ENDC

sintab:         DS.W 2*2048

music:
music_syd:
                DS.B 65000
;;  IBYTES 'FINALOOP.SND'
;;  EVEN
music_syd_bss:  DS.B 512
                EVEN

                DS.B 2048
stack:          DS.B 2
BSS_END:        DS.B 2

em:
effect_memory0: DS.B 2

                DS.L 1512000/4
mt:
memend_test:    DS.B 2

                END
;-------------------------------------------------------------------------------
                END

                lea     BSS_START,A0
                lea     BSS_END,A1
                bsr     memclr_a0_a1
black:
zero:           DS.L 16
                END


                END
