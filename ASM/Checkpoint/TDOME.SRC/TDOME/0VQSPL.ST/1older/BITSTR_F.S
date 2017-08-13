;-------------------------------------------------------------------------------
TEST            EQU 0
MUSIC_LIB       EQU 1           ; lib: TEST: 0
;-------------------------------------------------------------------------------
CODEBOOK_SIZE   EQU 8192
BITSTREAM_SIZE_MAX EQU 310000
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
start_main_music:RS.B 1         ;
Init_Kernel_ALL:RS.B 1          ;
Get_timeline_list:RS.B 1
Get_timeline_next:RS.B 1
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
program_start:
                IFNE TEST

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
no_hd_load:
                bra     skip_kernel

hd_flag:        DC.L 0

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
res0:           RS.B 1
SR_vbl:         RS.W 1
__stream_pos:   RS.L 1
__codebook_currentPtr:RS.L 1
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

*     DC.L $4AFC4E71


                moveq   #-1,D0
                moveq   #-1,D1
                jsr     KERNEL_INC


                DC.L $4AFC4E71

                move.l  hd_flag(PC),D2  ; HDD! for hd load

                jmp     DEMO_START      ****************************


** jsr     instr_cycle     *********************

                >PART

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

wait_scanlines: >PART
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
Q:
start_d2:       DC.L 0
DEMO_START:
                move.l  D2,start_d2
                move    #$2700,SR
                lea     stack,SP
                clr.l   $FFFFFA06.w
                clr.l   $FFFFFA12.w
                bclr    #3,$FFFFFA17.w  ; auto eoi
                move.l  #cnt_vbl,$00000070.w
                move    #$2300,SR

                bsr     load_music_0


                bsr     VQ_PLAYER       ; Init VQ Audio all
                bsr     VQ_InitStream_and_Start

                bsr     wait_vbl
                clr.l   total_time.w
demo_loop:

                bsr     Set_Replay_Fast

                lea     fname0(PC),A0
                lea     effect_memory0,A1
                moveq   #load_depack__,D0 ;A0.fname, A1.buffer | D0.depacked_size
                bsr     __KernelCall

                lea     (A1),A0
                moveq   #relocate__,D0  ;A0.prg
                bsr     __KernelCall

                bsr     Set_Replay_Free

                jsr     (A0)

                bra.s   demo_loop

fname0:
                DC.B 'TCVQ_ST.NRV',0
                EVEN



__KernelCall:
                movea.l KERNEL_ADR.w,A3
                jsr     (A3)
                rts

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

load_music_0:   PART

                move.l  #300000,bitstream_loaded_size

                cmpi.l  #'HDD!',start_d2
                beq.s   lm0_hdd

                lea     codebook_0_fn(PC),A0
                lea     codebook_0_loaded,A1
                moveq   #load__,D0      ;A0.fname, A1.buffer | D0.loaded_size
                bsr     __KernelCall

                lea     stream_0_fn(PC),A0
                lea     bitstream_0_loaded,A1
                moveq   #load__,D0      ;A0.fname, A1.buffer | D0.loaded_size
                bsr     __KernelCall
                rts
lm0_hdd:
                rts

                ENDPART

codebook_0_fn:  DC.B "CODEBOOK.DAT",0
stream_0_fn:    DC.B "VQST_0.STR",0
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

VQ_InitStream_and_Start:>PART

                lea     bitstream_0_loaded,A0
                lea     codebook_0_loaded,A1

                pea     (A0)
                adda.l  bitstream_loaded_size(PC),A0
                move.l  A0,stream_end_pos ; bitstream_end

                movea.l (SP)+,A0        ;       bitstream
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
VQ_PLAYER:
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
                lea     bitstream_end,A0
                move.l  A0,stream_end_pos ; bitstream_end

                lea     bitstream,A0
                lea     codebook,A1
                move.l  A0,stream_pos   ;       bitstream
                move.l  A0,vqRestart_stream ;   bitstream
                move.l  A1,vqRestart_codebook ; codebook
                bsr     VQ_Init

                moveq   #__set_replay_free,D0
                bsr.s   set_replay_mode
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

get_sample_pointers:                    ; out: A0.play A1.work
                movea.l spl_play_ptr(PC),A0
                movea.l spl_work_ptr(PC),A1
                rts

get_codebook:                           ; out: A0.codebook
                movea.l codebook_currentPtr(PC),A0
                rts

get_streampos:                          ; out: A0.streampos
                movea.l stream_pos(PC),A0
                rts
set_streampos:                          ; in:  A0.streampos
                move.l  A0,stream_pos
                rts

decode_frame_VQ:
                lea     (A0),A1         ; sample output
                bsr     vq_decoder
                rts


set_replay_mode:
                bsr     wait_vbl

                move    #$2700,SR
                lsl.w   #2,D0
                jsr     srm(PC,D0.w)

                bsr     wait_vbl
                rts
srm:
                OPT O-,W-
                bra     set_replay_fast
                bra     set_replay_free
                bra     set_replay_ext_render
                OPT O+,W+

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
set_replay_free:>PART

                move.w  #$2400,SR_vbl.w

                lea     sound_buffer0,A4
                move.l  A4,sample_adr0+2

                move.l  #timer_play_free,$00000134.w

                bsr.s   set_timer_data

                move.l  #vbl_play_free,$00000070.w
                move    #$2300,SR
                rts
                ENDPART

set_replay_ext_render:

                move.l  stream_pos(PC),__stream_pos.w
                move.l  codebook_currentPtr(PC),__codebook_currentPtr.w

                move.l  #vbl_empty,$00000070.w
                bsr     disable_timer_a

                move    #$2300,SR
                rts
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


vbl_play_fast:  >PART
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

                move.l  vbl_slot0.w,D0  ; fx vbl slot
                beq.s   no_fx_vbl

                move    #$2700,SR
                tas.b   vbl_fx_sem
                bne.s   no_fx_vbl

                movea.l D0,A0
                move.w  SR_vbl.w,D1
                cmp.w   #$2100,D1
                beq.s   vfr_hbl
                move.w  #$2300,D1       ; ENABLE VBL!!!
vfr_hbl:
                move    D1,SR           ; ENABLE HBL & VBL!!!
vfr_SR_done:
                jsr     (A0)            ; vbl_slot0
                move    #$2700,SR
                clr.b   vbl_fx_sem
no_fx_vbl:
                move    SR_vbl.w,SR
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
                cmp.b   #$003B+9,D0     ; F10
                bne.s   to_no_break
                DC.L $4AFC4E71
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


vq_decoder:     >PART

*  DC.L $4AFC4E71

;;; movea.l spl_work_ptr(PC),A1 ; sample output

                movea.l stream_pos(PC),A0
                movea.l codebook_currentPtr(PC),A2

                bsr     vq_decode_40

                bsr.s   vq_check_stream_end

                rts

                ENDPART

vq_check_stream_end:PART
                cmpa.l  stream_end_pos(PC),A0 ; #bitstream_end,A0
                blt.s   map_not_end
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
cnt_vbl:
                addq.l  #1,$00000466.w
rte:            rte
rts:            rts
;-------------------------------------------------------------------------------

                DATA

sound_buffer0:  DS.B 330
sound_buffer1:  DS.B 330
sbuff_end:


                IFNE MUSIC_LIB
                PATH 'C:\0NEW\TDOME\0VQSPL.ST\'
codebook:
                IBYTES 'CODEBOOK.DAT'
bitstream:
                IBYTES 'VQST_0.STR'
bitstream_end:
                EVEN
                ENDC


                PATH 'C:\0NEW\TDOME\0VQSPL.ST\'
relocation_table:
;-------------------------------------------------------------------------------
                BSS

                DS.B 1024
stack:          DS.B 4
bss_end:        DS.B 4

codebook_0_loaded:DS.B CODEBOOK_SIZE
bitstream_0_loaded:DS.B BITSTREAM_SIZE_MAX

effect_memory0:
                END
;-------------------------------------------------------------------------------
                END


;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
                >PART ' sys-struct '
; MUSIC - relative
                RSSET 0
__VQ_Init_All:  RS.L 1
__set_replay_mode:RS.L 1
__vq_decoder:   RS.L 1          ; in:  A1.samples_output
__get_sample_pointers:RS.L 1    ; out: A0.play A1.work
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
res0:           RS.B 1
res1:           RS.B 1
res2:           RS.B 1
__stream_pos:   RS.L 1
__codebook_currentPtr:RS.L 1
struct_end:     RS.L 0
                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

MUSIC_ON        EQU 1

                IFNE MUSIC_ON
                jsr     VQ_audio
                ENDC

                moveq   #__set_replay_free,D0
                movea.l MUSIC.w,A0
                jsr     __set_replay_mode(A0)

                moveq   #__set_replay_fast,D0
                movea.l MUSIC.w,A0
;;  jsr     __set_replay_mode(A0)


                IFNE MUSIC_ON
VQ_audio:
                PATH 'C:\0NEW\TDOME\'
                PATH '0VQSPL.ST\'
                IBYTES 'VQAUDIO.PRG'
                EVEN
                ENDC
                END
