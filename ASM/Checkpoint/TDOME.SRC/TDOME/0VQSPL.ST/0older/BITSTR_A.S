;-------------------------------------------------------------------------------
TEST            EQU 0

                OUTPUT 'VQAUDIO.PRG'
                IFNE TEST
                bra     __start__

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
; init
                jsr     VQ_PLAYER       ; Init VQ Audio all


                moveq   #__set_replay_free,D0
                movea.l MUSIC.w,A0
                jsr     __set_replay_mode(A0)

                moveq   #__set_replay_fast,D0
                movea.l MUSIC.w,A0
;;  jsr     __set_replay_mode(A0)


                bsr     set_replay_ext

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

                IFNE TEST
;-------------------------------------------------------------------------------
                jsr     VQ_PLAYER
VQ_PLAYER:
                PATH 'C:\0NEW\TDOME\0VQSPL.ST\'
;;  IBYTES 'VQAUDIO.PRG'
                EVEN
;-------------------------------------------------------------------------------
                ENDC


__start__:
;-------------------------------------------------------------------------------
; Audio-VQ-Decoder
; ----------------
; (w)2014 lsl/checkpoint
; based on ideas by Algorithm/Onslaught (C-64)
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
program_start:
                OPT D-
                IFNE TEST
                OPT D+
                >PART
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

** jsr     instr_cycle     *********************

                bsr     wait_vbl


                bsr     VQ_Service      ; Init VQ Audio all


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


wait_scanlines: >PART
                DS.W 128-3,$00004E71
                dbra    D0,wait_scanlines
                rts
                ENDPART

regs:
                DS.L 32,$AAAAAAAA


set_replay_ext:
                moveq   #__set_replay_ext_render,D0
                movea.l MUSIC.w,A0
                jsr     __set_replay_mode(A0)

                move.l  #vbl_ext,$00000070.w

                move.l  #timer_play_ext,$00000068.w

                move    #$2100,SR

                rts


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
VQ_Service:
                OPT O-,W-
                bra     VQ_Init_All
                bra     set_replay_mode
                bra     vq_decoder      ;     in:  A1.samples_output
                bra     get_sample_pointers ; out: A0.play A1.work
                bra     get_codebook    ; out: A0.codebook
                bra     get_streampos   ; out: A0.streampos
                bra     set_streampos   ; in:  A0.streampos
                OPT O+,W+
;-------------------------------------------------------------------------------
VQ_Init_All:    >PART

                lea     VQ_Service(PC),A0
                move.l  A0,MUSIC.w

;;; DC.L $4AFC4E71

                lea     vbl_slot_first.w,A0
                move.w  #struct_end-vbl_slot_first-1,D0
clrstr:         clr.b   (A0)+
                dbra    D0,clrstr


                bsr     relocate_VQ


                lea     rte(PC),A0
                move.l  A0,$00000134.w
                move.l  A0,$00000060.w
                move.l  A0,$00000068.w
                move.l  #cnt_vbl,$00000070.w

                lea     sound_buffer0,A0
                move.w  #sbuff_end-sound_buffer0-1,D0
clrsb:          clr.b   (A0)+
                dbra    D0,clrsb

                bsr     init_soundchip

                bsr     Init_VQ_Decoder

                lea     bitstream,A0
                lea     codebook,A1
                bsr     VQ_Init

                moveq   #__set_replay_free,D0
                bsr.s   set_replay_mode
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

                movem.l D0-D6/A0-A3,-(SP)

                bsr     vbl_top_routine
                move    #$2400,SR

                movea.l spl_work_ptr(PC),A1 ; sample output
                bsr     vq_decoder

                movem.l (SP)+,D0-D6/A0-A3

                addq.l  #1,$00000466.w
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

                movem.l D0-A6,-(SP)

                bsr     vbl_top_routine
                move    #$2400,SR

                movea.l spl_work_ptr(PC),A1 ; sample output
                bsr     vq_decoder

                movem.l (SP)+,D0-A6

                addq.l  #1,$00000466.w
                rte

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

sample_buffPtr: DC.L sound_buffer0,sound_buffer1

stream_pos:
                DC.L bitstream

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

vq_check_stream_end:>PART
                cmpa.l  #bitstream_end,A0
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
VQ_Restart:     >PART
                lea     bitstream,A0
                lea     codebook,A1
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

                IFNE TEST
;-------------------------------------------------------------------------------
instr_cycle:    >PART
                move.l  #svbl,$00000070.w
                move    #$2300,SR
sloop:
                lea     stack,SP
                move    #$2300,SR
                clr.b   $FFFF8201.w
                clr.b   $FFFF8203.w

                bsr     wait_vbl_cc
                move    #$2700,SR

                moveq   #0,D0
                moveq   #0,D1

;;   movea.l screen1,A0

                lea     bss_end,A0

                lea     (A0),A1
                lea     (A0),A2
                lea     (A0),A3
                lea     (A0),A4
                lea     (A0),A5
                lea     (A0),A6

                lea     $FFFF8800.w,A6


;get synced
                move.l  D0,resd0+2
sts:            move.b  $FFFF8209.w,D0
                beq.s   sts
                not.w   D0
                lsl.w   D0,D0

;sync to $0 - $A0 Position!
w:              move.b  $FFFF8209.w,D0
                bne.s   w

resd0:          move.l  #$00000000,D0
                DS.W 40,$00004E71

uzi:
;Sync_Pos should be Zero now!!   (1 nop before --> Sync_pos=2 !)
                move.b  $FFFF8209.w,_1st+3 ;3
;--------------------------------------------------------------------
your_code_here:

; pea     (A6)
                movea.l (SP)+,A6

es:
;--------------------------------------------------------------------
                move.b  $FFFF8209.w,_2nd+3 ;3            move.b (a3),d4 [2]
;Maximum_Count_Cycles = (160 - 6)/2 = 77 Nops!

_2nd:           move.b  #0,D0
_1st:           sub.b   #0,D0
                sub.b   #12,D0
                lsr.b   #1,D0           ;/2 = nop's
                and.l   #$000000FF,D0

                lea     stack,SP
                DC.L $4AFC4E71

                move.w  #$0700,$FFFF8240.w
                move.w  #$0000,$FFFF8240.w
                jmp     sloop

svbl:           addq.l  #1,$00000466.w
                rte
wait_vbl_cc:
                clr.l   $00000466.w
wv_cc:          tst.l   $00000466.w
                beq.s   wv_cc
                rts

                ENDPART
;-------------------------------------------------------------------------------
                ENDC

                DATA

sound_buffer0:  DS.B 330
sound_buffer1:  DS.B 330
sbuff_end:

codebook:
                IBYTES 'CODEBOOK.DAT'

bitstream:
                IBYTES 'VQST_0.STR'
bitstream_end:
                EVEN

relocation_table:
;-------------------------------------------------------------------------------
                BSS

                IFNE TEST
                DS.B 1024
stack:          DS.B 4
bss_end:
                ENDC

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
