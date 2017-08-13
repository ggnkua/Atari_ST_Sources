;-------------------------------------------------------------------------------
TEST            EQU 1
MUSIC_LIB       EQU 0           ; lib: TEST: 0
;-------------------------------------------------------------------------------
CODEBOOK_SIZE   EQU 8192
BITSTREAM_SIZE_MAX EQU 290000
;-------------------------------------------------------------------------------
VIDSIZE         EQU 160000
;-------------------------------------------------------------------------------
                IFNE MUSIC_LIB
                OUTPUT 'VQAUDIO.PRG'
                ELSE
                OUTPUT 'DRIVER.PRG'
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

                RSSET $00000040
KERNEL_ADR:     RS.L 1
bytes_avail:    RS.L 1
load_pos:       RS.L 1
depack_pos:     RS.L 1
depacked_ptr:   RS.L 1          ; pointer to next memory location depack

total_time:     RS.L 1
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

                move.l  intro_end_adr(PC),D0
                bsr     get_absolute_address

                IFNE TEST

;-------------------------------------------------------------------------------
                >PART ' TEST - LOAD FILES FROM HDD '

                move.l  #'HDD!',D2      ; load first vq-audio from hdd

                move.l  D2,hd_flag

                cmpi.l  #'HDD!',hd_flag
                bne.s   no_hd_load

                lea     codebook_0_fn(PC),A0
                lea     codebook_0_loaded,A1
                bsr     gemdos_loadfile

                lea     stream_0_fn(PC),A0
                lea     bitstream_0_loaded,A1
                bsr     gemdos_loadfile

A:
                lea     intro_fn,A0
                movea.l intro_start_address,A1
                bsr     gemdos_loadfile

                lea     stream_intro_fn,A0
                movea.l intro_stream_address,A1
                bsr     gemdos_loadfile

                lea     codebook_intro_fn,A0
                movea.l intro_codebook_addess,A1
                bsr     gemdos_loadfile

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
                bra     VQ_PLAYER
                ENDC
;-------------------------------------------------------------------------------
                IFNE TEST
                bra     __start__
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
; init
                >PART ' vq init template '

                jsr     VQ_PLAYER       ; Init VQ Audio all

                moveq   #__set_replay_free,D0
                movea.l MUSIC.w,A0
                jsr     __set_replay_mode(A0)

                moveq   #__set_replay_fast,D0
                movea.l MUSIC.w,A0
;;  jsr     __set_replay_mode(A0)


;;;   bsr     set_replay_ext
                ENDPART
                ENDC

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
                >PART ' sys-struct '
; MUSIC - relative
                RSSET 0
__VQ_Init_All:  RS.L 1
__set_replay_mode:RS.L 1
__vq_decoder:   RS.L 1          ; in:  A1.samples_output
__get_sample_pointers:RS.L 1    ; out: A0.play A1.work
__get_codebook: RS.L 1          ; out: A0.codebook
__get_streampos:RS.L 1          ; out: A0.streampos
__set_streampos:RS.L 1          ; in:  A0.streampos
__decode_frame_VQ:RS.L 1        ; in:  A0.sampleoutput 8bitS
;-------------------------------

; replay mode setting
                RSSET 0
__set_replay_fast:RS.B 1
__set_replay_free:RS.B 1
__set_replay_ext_render:RS.B 1
;-------------------------------
                RSSET $00000038
MUSIC:          RS.L 1
                RSSET $000004CE
vbl_slot_first: RS.L 1          ; first executed vbl slot
vbl_slot0:      RS.L 1          ; fx vbl slot
script_slot:    RS.L 1
colors_ptr:     RS.L 1
EFFECT_TERMINATE_SIGNAL:RS.B 1
EFFECT_DONE_FLAG:RS.B 1
SR_vbl:         RS.W 1
__stream_pos:   RS.L 1
__codebook_currentPtr:RS.L 1

mute_on_end_flag:RS.B 1
mute_flag:      RS.B 1

struct_end:     RS.L 0
                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

                IFNE TEST
;-------------------------------------------------------------------------------
                jsr     VQ_PLAYER
_VQ_PLAYER:
                PATH 'C:\0NEW\TDOME\0VQSPL.ST\'
;;  IBYTES 'VQAUDIO.PRG'
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

                moveq   #-1,D0
                moveq   #-1,D1
                jsr     KERNEL_INC


*   DC.L $4AFC4E71

                move.l  hd_flag(PC),D2  ; HDD! for hd load

                jmp     DEMO_START      ****************************


** jsr     instr_cycle     *********************

                PART

                bsr     wait_vbl


                bsr     VQ_PLAYER       ; Init VQ Audio all


                moveq   #__set_replay_free,D0
                movea.l MUSIC.w,A0
                jsr     __set_replay_mode(A0)

                moveq   #__set_replay_fast,D0
                movea.l MUSIC.w,A0
;;  jsr     __set_replay_mode(A0)


                bsr     set_replay_ext


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
                moveq   #__set_replay_fast,D0
                bsr     set_replay_mode
                move.w  #$0070,scol
                bra     loop
f2:
                moveq   #__set_replay_free,D0
                bsr     set_replay_mode
                move.w  #$0700,scol
                bra     loop

oldkey:         DC.W 0
scol:           DC.W $0070

                ENDPART

wait_scanlines: PART
                DS.W 128-3,$00004E71
                dbra    D0,wait_scanlines
                rts
                ENDPART

regs:           DS.L 32,$AAAAAAAA

set_replay_ext: >PART

                moveq   #__set_replay_ext_render,D0
                movea.l MUSIC.w,A0
                jsr     __set_replay_mode(A0)

                move.l  #vbl_ext,$00000070.w

                move.l  #timer_play_ext,$00000068.w

                move    #$2100,SR

                rts
                ENDPART

vbl_ext:        >PART

                move    #$2700,SR
;-------------------------------------------------------
                movem.l A4/A6,-(SP)
                movem.l sample_buffPtrE(PC),A4/A6
                exg     A4,A6
                movem.l A4/A6,sample_buffPtrE

                move.l  A4,sample_adr_ext+2

                move.l  A4,spl_play_ptrE
                move.l  A6,spl_work_ptrE
                movem.l (SP)+,A4/A6
;-------------------------------------------------------
                move    #$2100,SR

                movem.l D0-A6,-(SP)

                bsr     vbl_top_routine

                movea.l spl_work_ptrE(PC),A1 ; sample output

                movea.l MUSIC.w,A3
                jsr     __vq_decoder(A3)

                movem.l (SP)+,D0-A6

                addq.l  #1,$00000466.w
                rte

                ENDPART

spl_play_ptrE:  DC.L 0
spl_work_ptrE:  DC.L 0
sample_buffPtrE:DC.L sound_bufferX0,sound_bufferX1

timer_play_ext: >PART
                move    #$2700,SR

                move.l  D7,-(SP)
                pea     (A6)
                moveq   #0,D7
                lea     $FFFF8800.w,A6
sample_adr_ext: move.b  sound_bufferX0,D7
                lsl.w   #3,D7
                move.l  ym_table_optimum2(PC,D7.w),(A6)
                move.l  ym_table_optimum2+4(PC,D7.w),D7
                movep.l D7,0(A6)
                addq.l  #1,sample_adr_ext+2
                movea.l (SP)+,A6
                move.l  (SP)+,D7
                rte
                ENDPART
ym_table_optimum2:
                IBYTES 'YM_TAB.FIN'

sound_bufferX0: DS.B 330
sound_bufferX1: DS.B 330

                ENDC
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

check_Disk_B:   >PART

                DC.L $4AFC4E71

                move.l  $00000070.w,-(SP)
                bsr     wait_vbl
                clr.l   db_colindex
                move.l  #disk_b_vbl,$00000070.w
db_loop:
                lea     effect_memory0,A0 ; buffer
                lea     boot_sector_struct(PC),A1
                moveq   #load__sectors__,D0
                bsr     __KernelCall

                lea     effect_memory0,A0 ; buffer
                cmpi.l  #"TD#2",$003C(A0)
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

o               SET 0

intro_start_address:
                DC.L intro_mem+o
o               SET o+388*KB

intro_stream_address:
                DC.L intro_mem+o
o               SET o+80*KB

intro_codebook_addess:
                DC.L intro_mem+o
o               SET o+8192

intro_end_adr:
                DC.L intro_mem+o


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

                bsr     relocate_VQ

*      bsr     check_Disk_B


;    move.l  KERNEL_ADR.w,D0
;    sub.l   #$00008000,D0
;    add.l   #$000FFF00-VIDSIZE,D0
;    move.l  D0,video_address


                lea     $000FFFF0,A0

                suba.l  #VIDSIZE,A0
                move.l  A0,video_address

                suba.l  #36000,A0
                move.l  A0,_36k_address

; setup raymarching pointers
                lea     $000FFFF0,A0
                suba.l  #55*KB,A0
                move.l  A0,rm_Intro_address
                suba.l  #256000+1024,A0
                move.l  A0,rmarch_data_address

                DC.L $4AFC4E71


                bsr     load_music_0

*     DC.L $4AFC4E71

                bsr     load_intro


                bsr     init_sintab

                bsr     VQ_PLAYER       ; Init VQ Audio player

                bsr     wait_vbl
                clr.l   total_time.w
demo_loop:
                bsr     script_rout

                IFNE TEST
                move.b  $FFFFFC02.w,D0
                cmp.b   #$39,D0
                bne.s   demo_loop

                move.l  address_MAX(PC),D0
                DC.L $4AFC4E71
                ENDC

                bra.s   demo_loop




                lea     video_0_fname(PC),A0
                movea.l video_address(PC),A1
                moveq   #load_depack__,D0 ;A0.fname, A1.buffer | D0.depacked_size
                bsr     __KernelCall

                lea     (A1),A0
                moveq   #relocate__,D0  ;A0.prg
                bsr     __KernelCall


                jsr     (A0)

                bra.s   demo_loop

                bsr     Set_Replay_Fast
                bsr     Set_Replay_Free

video_0_fname:
                DC.B "VIDSTR_0.NRV",0
                EVEN

va:
video_address:
; NEEDS TO BE FIXED!!! (KERNEL_START)
                DC.L $000FFFFE-$8000-VIDSIZE+program_start

_36k_address:   DC.L 0

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

                DC.L GOTO,script_start


                DC.L __depack
                DC.L icircles
                DC.L EFFECT_END_CHECK_VBL
                DC.L __start
                DC.L LOAD_VIDEO,video_0_fname
                DC.L __wait_end

                DC.L __depack
                DC.L _88compr_st_tc
                DC.L __start_VIDEO
                DC.L __wait_end

                DC.L ILL
;-----------------------------------------------------

                DC.L __depack
                DC.L machine
                DC.L __start
                DC.L __wait_end
script_start:

                DC.L start_main_music
                DC.L GOTO,oszi_start


*   DC.L GOTO,bump_start

                DC.L start_intro

                DC.L CLR_L,total_time

                DC.L start_main_music
script_restart:

                DC.L __depack
                DC.L icircles
                DC.L __start
                DC.L __wait_end

                DC.L __depack
                DC.L bounce     ; ** NO LOAD **
                DC.L __start
                DC.L __wait_end


; TODO: vbl_end -- callback to new fx init routine   **DONE**

bump_start:
                DC.L Depack_Machine

                DC.L __depack
                DC.L bump
                DC.L __start
                DC.L EFFECT_END_SUB,MachineStart_vbl
                DC.L LOAD_VIDEO,video_0_fname
                DC.L __wait_end

                DC.L __depack
                DC.L _88compr_st_tc
                DC.L __start_VIDEO
                DC.L __wait_end


;----------------------------------
                DC.L __depack
                DC.L insphere
                DC.L __start
                DC.L __wait_end

                DC.L __depack
                DC.L enge       ; ** NO LOAD **
                DC.L __start
                DC.L __wait_end
Q:
                DC.L __depack
                DC.L morphdot   ; ** NO LOAD **
                DC.L __start
                DC.L __wait_end

oszi_start:
                DC.L Depack_rm_Intro

                DC.L __depack
                DC.L oszi
                DC.L __start
                DC.L EFFECT_END_SUB,rm_IntroStart_vbl
                DC.L LOAD_RAYMARCH_SHADER
                DC.L __wait_end

                DC.L __depack
                DC.L raymarch
                DC.L __start_RAYMARCH
                DC.L __wait_end


                DC.L WAIT,10000

                DC.L GOTO,script_restart

                ENDC

start_intro:    >PART

                pea     (A0)

                bsr     wait_vbl

; start intro music
                movea.l intro_stream_address(PC),A0
                movea.l intro_codebook_addess(PC),A1
                move.l  #"VQI!",D0
                bsr     VQ_InitStream_and_Start

                movea.l intro_start_address(PC),A0
                moveq   #relocate__,D0  ;A0.prg
                bsr     __KernelCall
                jsr     (A0)

; PRECALC SU FOR ICIRCLES HERE!!

intro_wait_end:
                move.b  EFFECT_DONE_FLAG.w,D0
                beq.s   intro_wait_end

                bsr     clean_system

                movea.l (SP)+,A0
                move.l  A0,script_pos
                rts
                ENDPART
start_main_music:PART

                pea     (A0)

                lea     bitstream_0_loaded,A0
                lea     codebook_0_loaded,A1
                move.l  #"VQI!",D0
                bsr     VQ_InitStream_and_Start

                clr.b   mute_on_end_flag.w
                clr.b   mute_flag.w

                move.l  (SP)+,script_pos
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


                bsr     Set_Replay_Fast
*   bsr     Set_Replay_Free

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

                bsr     Set_Replay_Free

;;; bsr     clean_system

*  DC.L $4AFC4E71

                lea     sintab,A0

start_jsr:      jsr     0

                movea.l (SP)+,A0
                move.l  A0,script_pos
                rts
                ENDPART
__start_VIDEO:  >PART

                pea     (A0)

                lea     effect_memory0,A0
                move.l  A0,start_jsrV+2
                moveq   #relocate__,D0  ;A0.prg
                bsr     __KernelCall

                bsr     Set_Replay_Free

;;; bsr     clean_system

                lea     sintab,A0
                movea.l video_address(PC),A1
start_jsrV:     jsr     0

                movea.l (SP)+,A0
                move.l  A0,script_pos
                rts
                ENDPART


EFFECT_END_SUB:
                st      effect_end_vbl_flag
                move.l  (A0)+,effect_end_sub_routine
                move.l  A0,script_pos
                rts

Depack_Machine: >PART

                pea     (A0)

                move.l  _36k_address(PC),machine_address

                lea     machine,A0
                movea.l machine_address(PC),A1
                moveq   #depack__,D0    ;A0.src  , A1.dest
                bsr     __KernelCall

                movea.l machine_address(PC),A0
                move.l  A0,start_jsrMS+2
                moveq   #relocate__,D0  ;A0.prg
                bsr     __KernelCall

                movea.l (SP)+,A0
                move.l  A0,script_pos
                rts
                ENDPART
MachineStart_vbl:>PART

                bsr     Set_Replay_Fast
*   bsr     Set_Replay_Free


                lea     sintab,A0

start_jsrMS:    jsr     0

                rts

machine_address:DC.L 0
                ENDPART

;-------------------------------------------------------------
rm_Intro_address:DC.L 0
rmarch_data_address:DC.L 0      ; address of the shaderdata

Depack_rm_Intro:>PART

                pea     (A0)

                lea     raymarch_intro,A0
                movea.l rm_Intro_address(PC),A1
                moveq   #depack__,D0    ;A0.src  , A1.dest
                bsr     __KernelCall

                movea.l rm_Intro_address(PC),A0
                moveq   #relocate__,D0  ;A0.prg
                bsr     __KernelCall

                movea.l (SP)+,A0
                move.l  A0,script_pos
                rts
                ENDPART
rm_IntroStart_vbl:>PART

                bsr     Set_Replay_Fast
                movea.l rm_Intro_address(PC),A3
                jsr     (A3)
                rts

                ENDPART

LOAD_RAYMARCH_SHADER:>PART
                pea     (A0)

                lea     rm_shader_fn(PC),A0
                movea.l rmarch_data_address(PC),A1
                moveq   #load_depack__,D0 ;A0.fname, A1.buffer | D0.depacked_size

*    bsr     Set_Replay_Free

                bsr     __KernelCall

                movea.l (SP)+,A0
                move.l  A0,script_pos
                rts
                ENDPART
rm_shader_fn:   DC.B "RMDATA.NRV",0
                EVEN

__start_RAYMARCH:>PART

                pea     (A0)

                lea     effect_memory0,A0
                moveq   #relocate__,D0  ;A0.prg
                bsr     __KernelCall

                bsr     Set_Replay_Free

;;; bsr     clean_system

                lea     sintab,A0
                movea.l rmarch_data_address(PC),A1
                jsr     effect_memory0

                movea.l (SP)+,A0
                move.l  A0,script_pos
                rts
                ENDPART
;-------------------------------------------------------------



__wait_end:     >PART

                move.b  EFFECT_DONE_FLAG.w,D0
                beq.s   __wait_end

                pea     (A0)

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

clean_system:   PART

                st      set_replay_colors_black

                bsr     wait_vbl

                clr.l   vbl_slot_first.w ; first executed vbl slot
                clr.l   vbl_slot0.w     ; fx vbl slot
                clr.l   script_slot.w
                clr.l   colors_ptr.w
                clr.b   EFFECT_TERMINATE_SIGNAL.w
                clr.b   EFFECT_DONE_FLAG.w
                move.w  #$2400,SR_vbl.w

                bsr     Set_Replay_Free

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
get_prg_stats:  PART

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
get_absolute_address:PART
                sub.l   #program_start,D0 ; start of kernel!
                add.l   #$00008000,D0   ;   absolute address start
                rts
                ENDPART

data_end:       DC.L 0
bss_end:        DC.L 0
address_end:    DC.L 0
am:
address_MAX:    DC.L 0



*bounce:         IBYTES 'BOUNCE.NRV'
*bump:           IBYTES 'TD_BUMP.NRV'
*enge:           IBYTES 'ENGE.NRV'
*icircles:       IBYTES 'ICIRCLES.NRV'
*insphere:       IBYTES 'INSPHERE.NRV'




STAY_E          SET 0

; STAY            SET 3*50
;   DC.L set_fade_speed,8
;   DC.L fade,white,colors
;   DC.L wait_fade
;   DC.L WAIT,STAY

                DC.L HALT

                ENDPART
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

Set_Replay_Free:>PART
                movem.l D0-D6/A0-A3,-(SP)
                bsr     wait_vbl
                moveq   #__set_replay_free,D0
                movea.l MUSIC.w,A0
                jsr     __set_replay_mode(A0)
                bsr     wait_vbl
                movem.l (SP)+,D0-D6/A0-A3
                rts
                ENDPART
Set_Replay_Fast:>PART
                movem.l D0-D6/A0-A3,-(SP)
                bsr     wait_vbl
                moveq   #__set_replay_fast,D0
                movea.l MUSIC.w,A0
                jsr     __set_replay_mode(A0)
                bsr     wait_vbl
                movem.l (SP)+,D0-D6/A0-A3
                rts
                ENDPART

load_music_0:   >PART

                move.l  #300000,bitstream_loaded_size

                cmpi.l  #'HDD!',start_d2
                beq.s   lm0_hdd

                lea     codebook_0_fnDemo(PC),A0
                lea     codebook_0_loaded,A1
                moveq   #load__,D0      ;A0.fname, A1.buffer | D0.loaded_size
                bsr     __KernelCall

                lea     stream_0_fnDemo(PC),A0
                lea     bitstream_0_loaded,A1
                moveq   #load__,D0      ;A0.fname, A1.buffer | D0.loaded_size
                bsr     __KernelCall
                rts
lm0_hdd:
                rts

                ENDPART

codebook_0_fnDemo:
                DC.B "CODEBOOK.DAT",0
stream_0_fnDemo:
                DC.B "VQST_0.STR",0
                EVEN

load_intro:     PART

                cmpi.l  #'HDD!',start_d2
                beq.s   lm0_hdd2

                lea     intro_fnDemo(PC),A0
                movea.l intro_start_address(PC),A1
                moveq   #load_depack__,D0 ;A0.fname, A1.buffer | D0.depacked_size
                bsr     __KernelCall

                lea     stream_intro_fnDemo(PC),A0
                movea.l intro_stream_address(PC),A1
                moveq   #load__,D0      ;A0.fname, A1.buffer | D0.loaded_size
                bsr     __KernelCall

                lea     codebook_intro_fnDemo(PC),A0
                movea.l intro_codebook_addess(PC),A1
                moveq   #load__,D0      ;A0.fname, A1.buffer | D0.loaded_size
                bsr     __KernelCall
lm0_hdd2:
                rts

                ENDPART
intro_fnDemo:
                DC.B "INTRO.NRV",0
codebook_intro_fnDemo:
                DC.B "CODEBOOK.INT",0
stream_intro_fnDemo:
                DC.B "VQST_0.INT",0
                EVEN


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

stream_size:    DC.L 0

; A0.stream
; A1.codebook

VQ_InitStream_and_Start:>PART

;  lea     bitstream_0_loaded,A0
;  lea     codebook_0_loaded,A1

                move.l  (A0)+,D0
                move.l  D0,stream_size
                lea     0(A0,D0.l),A2
                move.l  A2,stream_end_pos ; bitstream_end

                move.l  A0,stream_pos   ;       bitstream
                move.l  A0,vqRestart_stream ;   bitstream
                move.l  A1,vqRestart_codebook ; codebook
                bsr     VQ_Init

                moveq   #__set_replay_free,D0
                bsr     set_replay_mode
                rts

                ENDPART

bitstream_loaded_size:DC.L 0

;-------------------------------------------------------------------------------
;VQ_Service:
VQ_PLAYER:      PART
                OPT O-,W-
                bra     VQ_Init_All
                bra     set_replay_mode
                bra     vq_decoder      ;     in:  A1.samples_output
                bra     get_sample_pointers ; out: A0.play A1.work
                bra     get_codebook    ; out: A0.codebook
                bra     get_streampos   ; out: A0.streampos
                bra     set_streampos   ; in:  A0.streampos
                bra     decode_frame_VQ ; in:  A0.sampleoutput 8bitS
                OPT O+,W+
                ENDPART
;-------------------------------------------------------------------------------
VQ_Init_All:    PART

                lea     VQ_PLAYER(PC),A0
                move.l  A0,MUSIC.w

;;; DC.L $4AFC4E71

                lea     vbl_slot_first.w,A0
                move.w  #struct_end-vbl_slot_first-1,D0
clrstr:         clr.b   (A0)+
                dbra    D0,clrstr


                bsr     relocate_VQ

                move.w  #$2400,SR_vbl.w

                lea     rte(PC),A0
                move.l  A0,$00000134.w
                move.l  A0,$00000060.w
                move.l  A0,$00000068.w
                move.l  #cnt_vbl,$00000070.w

                move    #$2300,SR

                lea     sound_buffer0,A0
                move.w  #sbuff_end-sound_buffer0-1,D0
clrsb:          clr.b   (A0)+
                dbra    D0,clrsb

                bsr     init_soundchip

                bsr     Init_VQ_Decoder

                IFNE MUSIC_LIB

                lea     bitstream,A0
                lea     codebook,A1
                bsr     VQ_InitStream_and_Start

                ENDC
                rts
                ENDPART
;-------------------------------------------------------------------------------
relocate_VQ:    >PART

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
get_sample_pointers:>PART       ; out: A0.play A1.work
                movea.l spl_play_ptr(PC),A0
                movea.l spl_work_ptr(PC),A1
                rts
                ENDPART
get_codebook:   >PART           ; out: A0.codebook
                movea.l codebook_currentPtr(PC),A0
                rts
                ENDPART
get_streampos:  >PART           ; out: A0.streampos
                movea.l stream_pos(PC),A0
                rts
                ENDPART
set_streampos:  >PART           ; in:  A0.streampos
                move.l  A0,stream_pos
                rts
                ENDPART
decode_frame_VQ:>PART
                lea     (A0),A1         ; sample output
                bsr     vq_decoder
                rts
                ENDPART

set_replay_mode:>PART

                bsr     wait_vbl

                move    #$2700,SR
                lsl.w   #2,D0
                jsr     srm(PC,D0.w)
QQ:
                move.b  set_replay_colors_black(PC),D0
                beq.s   srm_not_black
                lea     black(PC),A0
                bsr     set_colors
                clr.b   set_replay_colors_black
srm_not_black:
                bsr     wait_vbl
                rts
srm:
                OPT O-,W-
                bra     set_replay_fast
                bra     set_replay_free
                bra     set_replay_ext_render
                OPT O+,W+
                ENDPART
;-------------------------------------------------------------------------------
set_replay_fast:>PART
;D7
;A4    ...sample_pointer
;A5/USP...ym_table
;A6    ...$FF8800

                move.w  #$2400,SR_vbl.w

                lea     sound_buffer0,A4

                lea     ym_table_optimum(PC),A5
                lea     -$00000A00*8(A5),A5 ; 1337 trick
                move    A5,USP
                lea     $FFFF8800.w,A6
                move.w  #$0A00,D7       ;     1337 trick

                move.l  #timer_play_fast,$00000134.w

                bsr.s   set_timer_data

                move.l  #vbl_play_fast,$00000070.w
                move    #$2300,SR
                rts
                ENDPART
set_replay_free:PART

                move.w  #$2400,SR_vbl.w

                lea     sound_buffer0,A4
                move.l  A4,sample_adr0+2

                move.l  #timer_play_free,$00000134.w

                bsr.s   set_timer_data

                move.l  #vbl_play_free,$00000070.w
                move    #$2300,SR
                rts
                ENDPART

set_replay_ext_render:>PART

                move.l  stream_pos(PC),__stream_pos.w
                move.l  codebook_currentPtr(PC),__codebook_currentPtr.w

                move.l  #vbl_empty,$00000070.w
                bsr     disable_timer_a

                move    #$2300,SR
                rts
                ENDPART
;-------------------------------------------------------------------------------
set_timer_data: >PART

                bclr    #3,$FFFFFA17.w  ; auto eoi

                clr.b   $FFFFFA19.w
                move.b  #Timer_Data,$FFFFFA1F.w ; ta_data
                move.b  #Timer_Ctrl,$FFFFFA19.w ; ta_ctrl

; enable Timer A IRQ
                bset    #5,$FFFFFA07.w
                bset    #5,$FFFFFA13.w

                rts
                ENDPART
disable_timer_a:>PART
                clr.b   $FFFFFA19.w
                bclr    #5,$FFFFFA07.w
                bclr    #5,$FFFFFA13.w
                rts
                ENDPART
;-------------------------------------------------------------------------------

vbl_fx_sem:     DC.W 0

vbl_play_fast:  PART
                move    #$2700,SR
;-------------------------------------------------------
                movem.l sample_buffPtr(PC),A4/A6
                exg     A4,A6
                movem.l A4/A6,sample_buffPtr

                move.l  A4,spl_play_ptr
                move.l  A6,spl_work_ptr
                lea     $FFFF8800.w,A6
;-------------------------------------------------------
;; move    #$2400,SR

                movem.l D0-D6/A0-A3,-(SP)

                bsr     vbl_top_routine
                move    SR_vbl.w,SR
*** move    #$2400,SR

                movea.l spl_work_ptr(PC),A1 ; sample output
                bsr     vq_decoder

                bsr     vbl_fx_rout

*  bsr     vbl_effect_end_check

                movem.l (SP)+,D0-D6/A0-A3

                addq.l  #1,$00000466.w
                cmpi.b  #$21,SR_vbl.w
                bne.s   no_hbl_vbl_end0
                move.b  #$21,(SP)
no_hbl_vbl_end0:
                rte

                ENDPART

vbl_play_free:  >PART

                move    #$2700,SR
;-------------------------------------------------------
                movem.l A4/A6,-(SP)
                movem.l sample_buffPtr(PC),A4/A6
                exg     A4,A6
                movem.l A4/A6,sample_buffPtr

                move.l  A4,sample_adr0+2

                move.l  A4,spl_play_ptr
                move.l  A6,spl_work_ptr
                movem.l (SP)+,A4/A6
;-------------------------------------------------------
;;   move    #$2400,SR

                movem.l D0-A6,-(SP)

                bsr     vbl_top_routine
                move    SR_vbl.w,SR
*** move    #$2400,SR

                movea.l spl_work_ptr(PC),A1 ; sample output
                bsr     vq_decoder

                bsr     vbl_fx_rout

*   bsr     vbl_effect_end_check

                movem.l (SP)+,D0-A6

                addq.l  #1,$00000466.w
                cmpi.b  #$21,SR_vbl.w
                bne.s   no_hbl_vbl_end1
                move.b  #$21,(SP)
no_hbl_vbl_end1:
                rte

                ENDPART


vbl_fx_rout:    >PART

                bsr     timer_output

                move    #$2700,SR
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

                move    #$2700,SR
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
vbl_top_routine:>PART

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
;D7
;A4...sample_pointer
;A5...ym_table
;A6...$FF8800
;-----------------------
timer_play_fast:>PART
                move.b  (A4)+,D7        ; sample  0A|sample
                lsl.w   #3,D7           ; (0A|sample)*8
                move    USP,A5          ; ym_table
                adda.w  D7,A5
                move.l  (A5)+,(A6)
                move.l  (A5)+,D7
                movep.l D7,0(A6)
                rte
                ENDPART

timer_play_free:>PART
                move.l  D7,-(SP)
                pea     (A6)
                moveq   #0,D7
                lea     $FFFF8800.w,A6
sample_adr0:    move.b  sound_buffer0,D7
                lsl.w   #3,D7
                move.l  ym_table_optimum(PC,D7.w),(A6)
                move.l  ym_table_optimum+4(PC,D7.w),D7
                movep.l D7,0(A6)
                addq.l  #1,sample_adr0+2
                movea.l (SP)+,A6
                move.l  (SP)+,D7
                rte
                ENDPART

ym_table_optimum:
                PATH 'C:\0NEW\TDOME\0VQSPL.ST\'
                IBYTES 'YM_TAB.FIN'

hbl_play_fast:  >PART
                move    #$2700,SR       ; Wichtig!!! hbl interrupts itself in border!!
                move.b  (A4)+,D7        ; sample
                lsl.w   #3,D7
                move    USP,A5          ; ym_table
                adda.w  D7,A5
                move.l  (A5)+,(A6)
                move.l  (A5)+,D7
                movep.l D7,0(A6)
                rte
                ENDPART

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
PRINT_HEX8      EQU 0
PRINT_HEX2      EQU $00000018
;-------------------------------------------------------------------------------
timer_output:   >PART

                addq.l  #1,total_time.w

*    bra.s   to_do           ;-------------

                move.b  $FFFFFC02.w,D0
                cmp.b   #$61,D0         ; UNDO
                beq.s   to_do

                IFNE TEST
                cmp.b   #$003B+9,D0     ; F10
                bne.s   to_no_break
                jmp     e               ;--------------------------------------
                ENDC
to_no_break:
                rts
to_do:
                move    SR,-(SP)
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
                move    (SP)+,SR
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

sample_buffPtr: DC.L sound_buffer0,sound_buffer1

stream_pos:     DC.L 0          ; bitstream
stream_end_pos: DC.L 0          ; bitstream_end

spl_play_ptr:   DC.L 0
spl_work_ptr:   DC.L 0

;-------------------------------------------------------------------------------


vq_decoder:     PART

*  DC.L $4AFC4E71

;;; movea.l spl_work_ptr(PC),A1 ; sample output

                move.b  mute_flag.w,D0
                bne.s   output_muted

                movea.l stream_pos(PC),A0
                movea.l codebook_currentPtr(PC),A2

                bsr     vq_decode_40

                bsr.s   vq_check_stream_end

                rts
output_muted:
                moveq   #0,D0
                move.w  #320/4-1,D6
fill_muted:
                move.l  D0,(A1)+
                dbra    D6,fill_muted
                rts

                ENDPART

vq_check_stream_end:PART
                cmpa.l  stream_end_pos(PC),A0 ; #bitstream_end,A0
                blt.s   map_not_end

                move.b  mute_on_end_flag.w,D0
                beq.s   no_mute_on_end
                st      mute_flag.w
                rts
no_mute_on_end:
                bsr     VQ_Restart
map_not_end:
                move.l  A0,stream_pos
                move.l  A2,codebook_currentPtr
                addq.l  #1,f
                rts

f:              DC.L 0

                ENDPART

;-------------------------------------------------------------------------------
codebook_currentPtr:DC.L 0
;-------------------------------------------------------------------------------
; A0...stream
; A1...codebook
init_stream:    >PART

;  move.l  (A0)+,D0        ; ID  "BLCK"
;  move.l  (A0)+,D0        ; codebook_new_counter
;  subq.w  #1,D0
;  move.w  D0,codebook_new_counter
;  move.w  D0,codebook_new_freq

*   DC.L $4AFC4E71

                move.l  A1,codebook_currentPtr
                lea     (A1),A2

;  lea     CBOOK*BLOCK_SIZE(A0),A0
;  move.l  (A0)+,D0        ; ID  "MAP!"

                move.l  A0,stream_pos
                rts
                ENDPART
;-------------------------------------------------------------------------------
; A0...stream
; A1...codebook
VQ_Init:        >PART

*  DC.L $4AFC4E71

                bsr.s   init_stream

                rts
                ENDPART
;-------------------------------------------------------------------------------
vqRestart_stream:DC.L 0         ; bitstream
vqRestart_codebook:DC.L 0       ; codebook
VQ_Restart:     >PART
;  lea     bitstream,A0
;  lea     codebook,A1
                movem.l vqRestart_stream(PC),A0-A1 ; bitstream
                bsr.s   VQ_Init
                rts
                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
Init_VQ_Decoder:>PART

*    DC.L $4AFC4E71

                lea     vq_decode_40(PC),A1
                moveq   #40/8-1,D0
ivqd_0:
                lea     vq_decode_t0(PC),A0
                move.w  (A0)+,(A1)+     ; fetch bits 10
                moveq   #8-1,D1         ; decode 8 samples
ivqd_1:
                lea     (A0),A2
                moveq   #(vq_decode_t1_e-vq_decode_t1)/2-1,D2
copy_code:
                move.w  (A2)+,(A1)+
                dbra    D2,copy_code
                dbra    D1,ivqd_1
                dbra    D0,ivqd_0

                move.w  #$4E75,(A1)+

;  suba.l  #vq_decode_40,A1

                rts
                ENDPART
vq_decode_t0:   >PART ' decoder template '

; rept 40/8
                move.w  (A0)+,D1        ; 8 values (bits 10)
vq_decode_t1:
; rept 8
;-------------------------------------------------
; decode 8 samples
                moveq   #0,D0
                move.b  (A0)+,D0        ; bits 8765432
                add.w   D1,D1           ; bit         1
                addx.w  D0,D0           ;
                add.w   D1,D1           ; bit          0
                addx.w  D0,D0           ;
                lsl.w   #3,D0
                lea     (A2),A3
                adda.w  D0,A3
                move.l  (A3)+,(A1)+
                move.l  (A3)+,(A1)+
;-------------------------------------------------
; endr
; endr
vq_decode_t1_e:
                DC.L 0,0
                ENDPART
;-------------------------------------------------------------------------------
vq_decode_40:   DS.B $037C
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
wait_vbl:       >PART
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
                move.l  A0,$00000120.w
                move.l  A0,$00000134.w
                bsr     restore_memory
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

                DATA

sound_buffer0:  DS.B 330
sound_buffer1:  DS.B 330
sbuff_end:

                IFNE MUSIC_LIB
                PATH 'C:\0NEW\TDOME\'
                PATH '0MUSIC\0BERO.NEW\'
codebook:
*  IBYTES 'CODEBOOK.INT'

                IBYTES 'CODEBOOK.DAT' ; DEMO
bitstream:
*    IBYTES 'VQST_0.INT'

                IBYTES 'VQST_0.STR' ; DEMO
bitstream_end:
                EVEN
                ENDC

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
                IFEQ MUSIC_LIB
                PATH 'C:\0NEW\TDOME\0FILES\0FILES\'

_88compr_st_tc: IBYTES 'TCVQ_ST.NRV'
bounce:         IBYTES 'BOUNCE.NRV'
bump:           IBYTES 'TD_BUMP.NRV'
enge:           IBYTES 'ENGE.NRV'
icircles:       IBYTES 'ICIRCLES.NRV'
insphere:       IBYTES 'INSPHERE.NRV'
machine:        IBYTES 'MACHINE.NRV'
morphdot:       IBYTES 'MORPHDOT.NRV'
oszi:           IBYTES 'OSZI.NRV'
raymarch_intro: IBYTES 'RMINTRO.NRV'
raymarch:       IBYTES 'RAYMARCH.NRV'

                EVEN

                ELSE
_88compr_st_tc:
bounce:
bump:
enge:
icircles:
insphere:
machine:
morphdot:
oszi:
raymarch_intro:
                ENDC

                PATH 'C:\0NEW\TDOME\0VQSPL.ST\'
relocation_table:
;-------------------------------------------------------------------------------
                BSS

                IFNE TEST
memsave:        DS.B $8000
                ENDC

sintab:         DS.W 2*2048

                DS.B 1024
stack:          DS.B 2
BSS_END:        DS.B 2

codebook_0_loaded:DS.B CODEBOOK_SIZE

bitstream_0_loaded:DS.B BITSTREAM_SIZE_MAX

effect_memory0: DS.B 2

intro_mem:      DS.L 500000/4

                END
;-------------------------------------------------------------------------------
                END


o               SET $000FFFF0

intro_stream_address:
o               SET o-90*KB
                DC.L o

intro_codebook_addess:
o               SET o-9*KB
                DC.L o

intro_start_address:
o               SET o-388*KB
                DC.L o
                END
