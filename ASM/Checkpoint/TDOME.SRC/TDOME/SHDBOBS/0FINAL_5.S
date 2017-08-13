;-------------------------------------------------------------------------------
TEST            EQU 1
;-------------------------------------------------------------------------------
                OUTPUT 'SHDBOBS.PRG'
;-------------------------------------------------------------------------------
SIN_MASK        EQU $00000FFE   ; 2048*2-2
COS             EQU $00000400   ; 2048/4*2
;-------------------------------------------------------------------------------
                OPT D-
;-------------------------------------------------------------------------------
cycle_screens   EQU 8
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

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


;-------------------------------------------------------------------------------
Effect_Init:
                move.l  A0,sintab_adr

                IFNE t
;-------------------------------------------------------------------------------
                jmp     skip_music
VQ_PLAYER_INC:
                PATH 'C:\0NEW\TDOME\0VQSPL.ST\'
                IBYTES 'VQAUDIO.PRG'
                EVEN
;-------------------------------------------------------------------------------
skip_music:
                ENDC


                OPT D-
                IFNE TEST
                OPT D+
                >PART

                clr.l   -(SP)
                move.w  #$0020,-(SP)
                trap    #1
                lea     stack,SP
                move    #$2700,SR
                clr.l   $FFFFFA06.w
                clr.l   $FFFFFA12.w

                move.l  #vbl,$00000070.w
                move    #$2300,SR
                bsr     wait_vbl
                bsr     wait_vbl
                clr.b   $FFFF8260.w
                move.b  #2,$FFFF820A.w
                ENDPART
                ENDC

                bsr     wait_vbl

                lea     black(PC),A0
                movem.l (A0),D0-D6/A1
                movem.l D0-D6/A1,$FFFF8240.w

                IFNE TEST
                jsr     VQ_PLAYER_INC

                movea.l MUSIC.w,A3
                jsr     __get_streampos(A3) ; out: A0.streampos

                adda.l  #100000,A0

                movea.l MUSIC.w,A3
                jsr     __set_streampos(A3) ; in:  A0.streampos

                ENDC


                moveq   #__set_replay_fast,D0
                movea.l MUSIC.w,A0
                jsr     __set_replay_mode(A0)


                lea     BSS_START,A0
                lea     BSS_END,A1
                bsr     memclr_a0_a1

                IFNE TEST
                bsr     init_sintab
                ENDC

                move.l  #screen_ram,D0
                clr.b   D0
                move.l  D0,init_screen
                move.l  D0,screen0
                move.l  D0,screen1

                lea     scr_tab(PC),A0
                moveq   #cycle_screens-1,D6
sti:
                move.l  D0,(A0)+
                add.l   #32000,D0
                dbra    D6,sti

                bsr     wait_vbl
                move.l  -(A0),D0
                lsr.w   #8,D0
                move.l  D0,$FFFF8200.w

                bsr     set_x_plot_tab
                bsr     set_y_offs_tab
                bsr     generate_circle
                bsr     shift_sprites
                bsr     set_x_sprite_tab

Effect_Start:
                movea.l init_screen(PC),A0
                bsr     clear_screen
                movea.l screen0(PC),A0
                bsr     clear_screen
                movea.l screen1(PC),A0
                bsr     clear_screen

                bsr     wait_vbl

                lea     colors(PC),A0
                movem.l (A0),D0-D6/A1
*    movem.l D0-D6/A1,$FFFF8240.w


                bsr     wait_vbl
                bsr.s   cycle_screens_rout
                move.l  #blobs_vbl,vbl_slot0.w

                move.l  #vbl_script,vbl_slot_first.w ; first executed vbl slot

                IFEQ TEST
                rts
                ENDC

                IFNE TEST
loop:
                bsr     wait_vbl

                move.b  $FFFFFC02.w,D0
                cmp.b   #$39,D0
                bne.s   loop
                DC.L $4AFC4E71
                bra.s   loop
                ENDC


vbl_script:
                movem.l D0-D6/A0-A3,-(SP)
                bsr.s   script_rout
                movem.l (SP)+,D0-D6/A0-A3
                rts
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
script_rout:    >PART

;     DC.L $4AFC4E71

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


                addq.l  #1,t

                subq.l  #1,script_delay
                bpl.s   sr_wait

                moveq   #0,D0
                movea.l script_pos(PC),A0
                movea.l (A0)+,A1
                jsr     (A1)
sr_wait:
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
script:         >PART

STAY_E          SET 0

STAY            SET 3*50
                DC.L set_fade_speed,8
                DC.L fade,white,colors
                DC.L wait_fade
                DC.L WAIT,STAY

STAY            SET 6*50
                DC.L WAIT,STAY

                DC.L set_fade_speed,10
                DC.L fade,colors,black
                DC.L wait_fade

*    DC.L ILL
                DC.L ST,EFFECT_DONE_FLAG

                DC.L HALT
* DC.L GOTO,script

                DC.L set_fade_speed,1
                DC.L fade,white,black
                DC.L wait_fade

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


blobs_vbl:
                bsr.s   color_cycle
                bsr     set_sprites
                bsr.s   cycle_screens_rout

*     lea     colors_out(PC),A0
*     movem.l (A0),D0-D6/A1
*    movem.l D0-D6/A1,$FFFF8240.w

                rts

cycle_screens_rout:>PART

                moveq   #cycle_screens-1,D6

                lea     cyc_scr(PC),A1
                move.w  (A1),D0
                move.w  D0,D1
                addq.w  #1,D1

                and.w   D6,D0           ; vis screen
                and.w   D6,D1           ; draw screen
                lsl.w   #2,D0
                lsl.w   #2,D1

                lea     scr_tab(PC),A0
                move.l  0(A0,D0.w),D0
                lsr.w   #8,D0
                move.l  D0,$FFFF8200.w

                move.l  0(A0,D1.w),draw_screen

                addq.w  #1,(A1)         ; cyc_scr
                and.w   D6,(A1)         ; cyc_scr

                rts
                ENDPART

cyc_scr:        DC.W 0          ;actual screen

cc_speed:       DC.W 1          ; 3
cc_counter:     DC.W 0
color_cycle:    >PART

                subq.w  #1,cc_counter
                bpl.s   no_cc
                move.w  cc_speed(PC),cc_counter

                lea     cc_num(PC),A0
                lea     colors+2(PC),A1

*  lea     $FFFF8242.w,A2

                lea     colors_out(PC),A2
*    move.l  A2,colors_ptr.w
                clr.w   (A2)+           ; col0


                move.w  (A0),D0
                move.w  D0,D1
                moveq   #15,D3
                sub.w   D1,D3

                add.w   D0,D0
                adda.w  D0,A1

                exg     D1,D3

                subq.w  #1,D1
                bmi.s   n_cc0
cc0:
                move.w  (A1)+,(A2)+
                dbra    D1,cc0
n_cc0:
                lea     colors+2(PC),A1
                subq.w  #1,D3
                bmi.s   n_cc1
cc1:
                move.w  (A1)+,(A2)+
                dbra    D3,cc1
n_cc1:
                addq.w  #1,(A0)         ; cc_num
                cmpi.w  #15,(A0)
                ble.s   ccmore
                clr.w   (A0)
ccmore:
no_cc:

*   IFNE TEST
*   movem.l colors_out(PC),D0-D6/A0
*   movem.l D0-D6/A0,$FFFF8240.w
*   ENDC

                rts

cc_num:         DC.W 0

                ENDPART

colors_out:     DS.W 16


a_w:            DC.W 0          ; 256*2
b_w:            DC.W 0          ;  512*2      ; 450*2
c_w:            DC.W 0          ;  1024*2     ; 900*2

a_w_inc:        DC.W 30*2       ;   2*2*2*2*3
b_w_inc:        DC.W 24*2       ; 18*2       ;  2*2*1*2*3
c_w_inc:        DC.W 28*4       ; 22*2       ;  2*2*3*2*3

num_plots:      DC.W 32

wink_inc:       >PART
                add.w   D0,(A0)
                andi.w  #SIN_MASK,(A0)
                rts
                ENDPART

set_sprites:    >PART

                lea     a_w(PC),A0
                move.w  a_w_inc(PC),D0
                bsr.s   wink_inc

                lea     b_w(PC),A0
                move.w  b_w_inc(PC),D0
                bsr.s   wink_inc

                lea     c_w(PC),A0
                move.w  c_w_inc(PC),D0
                bsr.s   wink_inc

                bsr     calc_koords
;-----------------------------------------------------------

                movea.l koords_pnt(PC),A0

                move.w  num_plots(PC),-(SP)
                subq.w  #1,(SP)
                bmi.s   no_sets
set_sprites_loop:

                lea     sprite_buffer(PC),A2
                adda.w  (A0)+,A2        ; shift

                movea.l draw_screen(PC),A3
                adda.w  (A0)+,A3        ; screen offset

                bsr.s   shade_rout

                subq.w  #1,(SP)
                bpl.s   set_sprites_loop
no_sets:
                addq.l  #2,SP
                rts

                ENDPART

shade_rout:     >PART
yo              SET 0
                REPT 16
                movem.w (A3)+,D2-D5

                move.w  (A2)+,D0        ;get data

                move.w  D0,D1
                and.w   D2,D1
                eor.w   D0,D2


                move.w  D1,D0           ;plane 2
                and.w   D3,D0           ;next
                eor.w   D1,D3

                move.w  D0,D1           ;plane 3
                and.w   D4,D1           ;next
                eor.w   D0,D4

                eor.w   D1,D5
                movem.w D2-D5,-8(A3)

                movem.w (A3)+,D2-D5
                move.w  (A2)+,D0        ;get data

                move.w  D0,D1           ;plane 1
                and.w   D2,D1           ;next
                eor.w   D0,D2

                move.w  D1,D0           ;plane 2
                and.w   D3,D0           ;next
                eor.w   D1,D3

                move.w  D0,D1           ;plane 3
                and.w   D4,D1           ;next
                eor.w   D0,D4

                eor.w   D1,D5
                movem.w D2-D5,-8(A3)

                lea     160-16(A3),A3
                ENDR
                rts

                ENDPART

calc_koords:    >PART

                movea.l sintab_adr(PC),A0
                movea.l koords_pnt(PC),A1 ;output

                move.w  a_w(PC),D2      ; A0
                move.w  b_w(PC),D3      ; A1
                move.w  c_w(PC),D4      ; A2


*  moveq   #32-1,D6        ; amount points

                move.w  num_plots(PC),D6
                subq.w  #1,D6
                bmi     no_calcc
ck_l0:
                move.w  #SIN_MASK,D5
                and.w   D5,D2
                and.w   D5,D3
                and.w   D5,D4

                move.w  0(A0,D2.w),D0   ; x
                add.w   #COS,D4
                muls    0(A0,D4.w),D0
                sub.w   #COS,D4
                asl.l   #2,D0
                swap    D0

                move.w  0(A0,D4.w),D1   ; A2
                muls    #2*COS*4,D1
                swap    D1
                and.w   D5,D1
                muls    0(A0,D1.w),D0
                asl.l   #2,D0
                swap    D0

; x amplitude
                muls    #(320-16)/2*4,D0
                swap    D0
                add.w   #(320-16)/2,D0

; Y
                move.w  0(A0,D3.w),D1
                muls    0(A0,D4.w),D1
                asl.l   #2,D1
                swap    D1

                move.w  0(A0,D2.w),D5
                muls    #9999,D5
                swap    D5
                and.w   #SIN_MASK,D5
                move.w  0(A0,D5.w),D5
                muls    D5,D1
                asl.l   #2,D1
                swap    D1


                muls    #(200-16)/2*4,D1
                swap    D1
                add.w   #(200-16)/2,D1
;
                add.w   D0,D0
                add.w   D0,D0
                lea     x_sprite_tab(PC),A3
                move.l  0(A3,D0.w),D0   ;x_sprite_tab

                add.w   D1,D1
                lea     y_offs_tab(PC),A3
                add.w   0(A3,D1.w),D0

                move.l  D0,(A1)+        ; coords out

                add.w   #12*2,D2        ; sintab x
                add.w   #14*2,D3        ; sintab y
                add.w   #16*2,D4        ; 72


                dbra    D6,ck_l0

no_calcc:
                rts
                ENDPART

koords_pnt:     DC.L koords


radius:         DC.W 7

generate_circle:>PART

                movea.l init_screen(PC),A0

                move.w  radius(PC),D5
                mulu    D5,D5

                move.w  #16-1,-(SP)     ;y
gc_yl0:
                moveq   #16/2,D0
                sub.w   (SP),D0
                muls    D0,D0

                lea     x_plot_tab(PC),A1

                move.w  #16-1,D6
gc_xl0:
                moveq   #16/2,D1
                sub.w   D6,D1
                muls    D1,D1
                add.l   D0,D1
                subq.l  #4,D1
                cmp.l   D5,D1
                bgt.s   d1_gt_d5

                movem.l D0-D1,-(SP)
                movem.w (A1),D0-D1
                or.w    D0,0(A0,D1.w)
                movem.l (SP)+,D0-D1
d1_gt_d5:                               ;ausserhalb
                addq.l  #4,A1
                dbra    D6,gc_xl0

                lea     160(A0),A0

                subq.w  #1,(SP)
                bpl.s   gc_yl0
                addq.l  #2,SP

                rts
                ENDPART

shift_sprites:  >PART

                lea     sprite_buffer(PC),A0
                move.w  #16-1,-(SP)     ;16 shifts
shift_l0:

;get data 1 plane:
                movea.l init_screen(PC),A1
                moveq   #16-1,D6
gd_yl0:
                move.w  (A1),(A0)+
                move.w  8(A1),(A0)+
                lea     160(A1),A1
                dbra    D6,gd_yl0

;shift 1 plane:
                movea.l init_screen(PC),A1
o               SET 0
                REPT 16
                lsr.w   o(A1)
                roxr.w  o+8(A1)
o               SET o+160
                ENDR

                subq.w  #1,(SP)
                bpl     shift_l0
                addq.l  #2,SP

                rts
                ENDPART

set_x_plot_tab: >PART

                lea     x_plot_tab(PC),A0
                move.w  #320-1,D6
                move.w  #$8000,D0
                move.w  #0,D1
sx0:
                move.w  D0,(A0)+
                move.w  D1,(A0)+
                ror.w   #1,D0
                bcc.s   sx1
                addq.w  #8,D1
sx1:
                dbra    D6,sx0
                rts
                ENDPART

set_x_sprite_tab:>PART

                lea     x_sprite_tab(PC),A0

                move.w  #320-1,D5
                moveq   #16-1,D6
                moveq   #0,D0           ;shift offs
                moveq   #0,D1           ;screen offs
sst0:
                move.w  D0,(A0)+
                move.w  D1,(A0)+
                add.w   #16*32/8,D0
                dbra    D6,next_pix

                moveq   #16-1,D6
                moveq   #0,D0
                addq.w  #8,D1
next_pix:
                dbra    D5,sst0
                rts
                ENDPART

;-------------------------------------------------------------------------------
set_y_offs_tab: >PART

                lea     y_offs_tab(PC),A0

                lea     y_offs_tab(PC),A0
                move.w  #200-1,D6
                moveq   #0,D0
syt:
                move.w  D0,(A0)+
                add.w   #160,D0
                dbra    D6,syt
                rts
                ENDPART
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; A0
clear_screen:   >PART
                move.l  #32000,D0
                bsr.s   memclr
                rts
                ENDPART
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
black:
zero:           DS.L 16
;-------------------------------------------------------------------------------


                IFNE TEST
init_sintab:    >PART           ;; 36 bytes!   (and the quality fit's !!)

;
; 36bytes Sine-generator   MC68000!!  (no 030 muls.l!) (w)`99 defjam/checkpoint!
;   * BUT a bit erroranous
;   * this version a bit corrected !?

size            SET 2048

;; Erweiterungsfaktor ist 65536*16384

sin_inc         SET 3294198     ;GENAU: 3294198     ;; 2*PI / size
cos_inc         SET -20212      ;   10106*2     ;; ((2*PI)^2) / (size^2)


                lea     sintab(PC),A0
                move.l  A0,sintab_adr

                moveq   #0,D0           ;oe

                move.l  #1*sin_inc,D3
                move.w  #2048-1,D6
init_sin_:
                move.l  D0,D4
                swap    D4
                move.w  D4,2048*2(A0)
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
                ENDC
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
wait_vbl:       >PART
                clr.l   $00000466.w
wv:             tst.l   $00000466.w
                beq.s   wv
                rts
                ENDPART

vbl:            >PART

                move.l  #vbl2,$00000070.w
                move    #$2300,SR

                movem.l D0-D6/A0-A3,-(SP)

                move.l  vbl_slot0.w,D0
                beq.s   *+4
                movea.l D0,A0
                jsr     (A0)

                movem.l (SP)+,D0-D6/A0-A3
                addq.l  #1,$00000466.w

                move    #$2700,SR
                move.l  #vbl,$00000070.w
                rte
                ENDPART
vbl2:           >PART
                movem.l D0-D6/A0-A3,-(SP)

                movem.l (SP)+,D0-D6/A0-A3
                addq.l  #1,$00000466.w
                rte
                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

                DATA

colors:         >PART
                DC.W $0000      ;0
                DC.W $0100      ;1
                DC.W $0200      ;2
                DC.W $0301      ;3
                DC.W $0412      ;4
                DC.W $0523      ;5
                DC.W $0634      ;6
                DC.W $0745      ;7
                DC.W $0756      ;8
                DC.W $0667      ;9
                DC.W $0556      ;10
                DC.W $0445      ;11
                DC.W $0334      ;12
                DC.W $0223      ;13
                DC.W $0112      ;14
                DC.W $0001      ;15

                ENDPART

screen0:        DC.L 0
screen1:        DC.L 0
init_screen:    DC.L 0
draw_screen:    DC.L 0

sintab_adr:     DC.L 0

scr_tab:        DS.L 8

                BSS

x_plot_tab:     DS.L 320
y_offs_tab:     DS.W 200


x_sprite_tab:   DS.L 320*2

koords:         DS.L 256

sprite_buffer:  DS.B 16*(16*32/8)
                DS.B 16*160
                DS.B 32*160
esb:

;-------------------------------------------------------------------------------
                IFNE TEST
sintab:         DS.W 2*2048
                ENDC
;-------------------------------------------------------------------------------

BSS_START:
                DS.B 256
screen_ram:
                DS.B cycle_screens*32000

screen_ram_end: DS.B 2

BSS_END:        DS.B 2


                IFNE TEST
                DS.B 512
stack:          DS.B 2
                ENDC
                END
