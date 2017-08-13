; timer data for app. 15650 Hz
Timer_Ctrl      EQU 1
Timer_Data      EQU $00000027

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

;-----------------------
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


