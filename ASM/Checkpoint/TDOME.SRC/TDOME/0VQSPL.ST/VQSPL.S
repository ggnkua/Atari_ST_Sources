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
VQ_PLAYER_INC:
                PATH 'C:\0NEW\TDOME\0VQSPL.ST\'
;;  IBYTES 'VQAUDIO.PRG'
                EVEN
;-------------------------------------------------------------------------------

                jsr     VQ_PLAYER_INC

                moveq   #__set_replay_free,D0
                movea.l MUSIC.w,A0
                jsr     __set_replay_mode(A0)

                moveq   #__set_replay_fast,D0
                movea.l MUSIC.w,A0
                jsr     __set_replay_mode(A0)

                ENDC



