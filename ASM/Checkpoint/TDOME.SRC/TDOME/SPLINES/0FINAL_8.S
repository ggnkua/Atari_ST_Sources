;-------------------------------------------------------------------------------
TEST            EQU 0
;-------------------------------------------------------------------------------
                OUTPUT 'SPLFILL.PRG'
;-------------------------------------------------------------------------------
;
; 0FINAL_7.SRC  ... multi-vbl
;
;
;
;
;  Hermite Spline - FILLED                                        (w)2002 Defjam
;                                                                    2013
;  deoptimized, now with muls
;
;  IDEA: EXP/LOG !!
;  --> pms_explog:
;
;-----------------------------------------
;                              min     max
; h1 = 1 - ( 3t^2 - 2t^3 )       0     1
; h2 =       3t^2 - 2t^3         0     1
; h3 =   t^3 - 2t^2 + t          0     0.1481
; h4 =   t^3 - t^2           -0.1481   0
;
;         -0.1481 * 256 = -37.9        -->  NEG. START BEI -40
;
;-------------------------------------------------------------------------------
NEXT_X          SET 200*2
;-------------------------------------------------------------------------------


IPOL_PTS_MAX    EQU 256

;-------------------------------------------------------------------------------

STEPS           EQU 16          ;22

CONTROL_POINTS_MAX EQU 32


SPLINE_BITS     EQU 14          ; 10

;------------------------------------------------------------------------------
MAX_DOTS        EQU 256
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
struct_end:     RS.L 0
                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

__start__:
                OPT D-

*    lea     checkpoint_list(pc),A1
                lea     thunderdome_list(PC),A1
                move.l  A1,piv_list_ptr

                IFNE TEST
                OPT D+
                >PART ' init system '
                clr.l   -(SP)
                move.w  #$0020,-(SP)
                trap    #1
                lea     stack,SP
                move    #$2700,SR
                clr.b   $FFFFFA07.w
                clr.b   $FFFFFA09.w
                clr.b   $FFFFFA13.w
                clr.b   $FFFFFA15.w
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

                lea     BSS_START,A0
                lea     BSS_END,A1
                bsr     memclr_a0_a1

                IFNE TEST
                bsr     VQ_PLAYER
                ENDC

                clr.l   colors_ptr.w
                bsr     wait_vbl

                move.l  #scr_ram,D0
                clr.b   D0
                move.l  D0,screen0
                add.l   #32000,D0
                move.l  D0,screen1
                lsr.w   #8,D0
                move.l  D0,$FFFF8200.w

                bsr     wait_vbl

*    lea     colors(PC),A0
*    movem.l (A0),D0-D6/A0
*    movem.l D0-D6/A0,$FFFF8240.w

                bsr     init_colors_plane_effec

                bsr     Init_Linerout

                bsr     precompute_spline

                bsr     init_all_objects


                bsr     init_dot_pre


                bsr     precalc_ipol_vars


                bsr     wait_vbl
                moveq   #__set_replay_fast,D0
                movea.l MUSIC.w,A0
                jsr     __set_replay_mode(A0)

; multi-vbl effect template
; init
                bsr     wait_vbl
                bsr     swap_screens
                bsr     interlace_effect ; cycle & set colorsptr for vbl!
                move.l  #vbl_effect,vbl_slot0.w
                bsr     wait_vbl

                IFEQ TEST
                rts
                ENDC

;------------------------------------------------------------------------------
loop:
                bsr     wait_vbl

                move.b  EFFECT_DONE_FLAG.w,D0
                beq.s   effm
                clr.l   vbl_slot0.w
effm:

                IFNE TEST
                move.b  $FFFFFC02.w,D0
                cmp.b   #$39,D0
                bne.s   loop
                DC.L $4AFC4E71
                ENDC
                bra.s   loop

vbl_effect:
; ---- CALL EFFECT ROUTINES HERE ----

                bsr.s   effect_rout

*    bsr.s   frame_sync
                bsr     swap_screens
                bsr     interlace_effect ; cycle & set colorsptr for vbl!
                rts


vbl_sync:       DC.L 3
frame_sync:
                move.l  vbl_sync(PC),D0
                subq.l  #1,D0
vsync:
                cmp.l   $00000466.w,D0
                bgt.s   vsync
                rts

effect_rout:
                bsr.s   script_rout

                bsr     Clear_y_field

                move.b  objects_done_flag(PC),D0
                bne.s   objdone

                move.l  ipol_rout(PC),D0
                beq.s   *+4
                movea.l D0,A0
                jsr     (A0)
objdone:
                bsr     Output_y_field

                rts


do_ipol:
                bsr     ipol_main
                bsr     ipol_output
                rts

ipol_rout:      DC.L 0

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
;-------------------------------------
check_end:
                move.b  objects_done_flag(PC),D0
                beq.s   cem
                lea     script_end(PC),A0
cem:
                move.l  A0,script_pos
                rts

script:         PART

                DC.L __init_ipol_NEW
                DC.L __do_ipol

*     DC.L check_end

                DC.L GOTO,script
script_end:
                DC.L WAIT,4
                DC.L ST,EFFECT_DONE_FLAG
                DC.L HALT

                ENDPART
;-------------------------------------
;-------------------------------------

__do_ipol:      >PART
                subq.w  #1,ipol_steps_counter
                bpl.s   dim
                move.l  A0,script_pos
dim:
                rts
                ENDPART

;-------------------------------------
fade:           >PART
                movem.l (A0)+,A1-A2
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

                movem.l D0-A6,-(SP)

                move.w  D0,-(SP)        ; fade factor
mfl_fades:
                move.w  (SP),D7         ; fade1
                moveq   #8,D6
                sub.w   D7,D6           ; fade0

                movem.l pal0_mf(PC),A0-A1

                lea     $FFFF8240.w,A6  ; *** DEBUG ***

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

                mulu    D6,D0           ; f0
                mulu    D6,D1           ; f0
                mulu    D6,D2           ; f0

                mulu    D7,D3           ; f1
                mulu    D7,D4           ; f1
                mulu    D7,D5           ; f1

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

*  move.w  D0,(A2)+        ; output

                move.w  D0,(A6)+        ; debug hwcols

                subq.w  #1,(SP)
                bpl.s   mfl_colors
                addq.l  #2,SP

*   addq.w  #1,(SP)
*   cmpi.w  #8,(SP)         ; 0...8
*   ble.s   mfl_fades

                addq.l  #2,SP

                movem.l (SP)+,D0-A6

                rts

pal0_mf:        DC.L 0,0

                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;----------------------------------------------------------------------------------


IPOL_STEP_BITS  EQU 4
IPOL_STEPS      EQU 1<<IPOL_STEP_BITS

ipol_main:      >PART

                lea     ipol_current,A0
                lea     result(PC),A1

im_startjmp:    jmp     0

im_start:

; fastest linear interpolation

                REPT IPOL_PTS_MAX

                move.w  (A0),(A1)+      ; x int                2b
                addi.l  #'CPT!',(A0)+   ; 16:16 interpolate    6b
                move.w  (A0),(A1)+      ; y int                2b
                addi.l  #'CPT!',(A0)+   ; 16:16 interpolate    6b

                ENDR
im_end:
im_size         SET (im_end-im_start)/IPOL_PTS_MAX
                rts

                ENDPART

init_dot_pre:
W:
                lea     T_pre,A0
                lea     dot_pre,A1
                move.w  (A0)+,D6
                move.w  D6,(A1)+

                move.w  #0,D0
                move.w  #0,D1

                subq.w  #1,D6
idpl:
                move.w  D0,(A1)+
                move.w  D1,(A1)+
                dbra    D6,idpl
                rts


precalc_ipol_vars:>PART

*   DC.L $4AFC4E71

                movea.l piv_list_ptr(PC),A2
                movem.l (A2),A0-A1
                move.w  (A0)+,D0        ; points
                move.w  (A1)+,D1        ; points
                move.w  #IPOL_PTS_MAX,D1
                sub.w   D0,D1
                mulu    #im_size,D1
                add.l   #im_start,D1
                move.l  D1,im_start_ptr
                move.l  D1,im_startjmp+2

                move.w  D0,D6
                subq.w  #1,D6
                move.w  D6,amount_points

                lea     precalc_ipol_list(PC),A0
                lea     precalc_ipol_data,A3
piv_loop:
                move.l  A3,(A0)+        ; list
                pea     (A0)            ; listPtr

                movem.l (A2)+,A0-A1
                pea     (A2)

                move.w  (A0)+,D0        ; points
                move.w  (A1)+,D1        ; points
                move.w  D0,D6
                subq.w  #1,D6
ii_pre_loop:
; x
                move.w  (A0)+,D0        ; x0
                move.w  (A1)+,D1        ; x1
                sub.w   D0,D1           ; x1-x0
                swap    D1
                clr.w   D1
                asr.l   #IPOL_STEP_BITS,D1
                move.l  D1,(A3)+        ; interpolation step X

                swap    D0
                clr.w   D0
                move.l  D0,(A3)+        ; x0<<16   ipol_current.x
; y
                move.w  (A0)+,D0        ; y0
                move.w  (A1)+,D1        ; y1
                sub.w   D0,D1           ; y1-y0
                swap    D1
                clr.w   D1
                asr.l   #IPOL_STEP_BITS,D1
                move.l  D1,(A3)+        ; interpolation step Y
                addq.l  #8,A2

                swap    D0
                clr.w   D0
                move.l  D0,(A3)+        ; y0<<16   ipol_current.y

                dbra    D6,ii_pre_loop

                movea.l (SP)+,A2
                movea.l (SP)+,A0        ; listPtr
                tst.l   (A2)
                bpl.s   piv_loop

                move.l  #-1,(A0)+

                rts
                ENDPART

piv_list_ptr:
*   DC.L checkpoint_list

                DC.L thunderdome_list

thunderdome_list:
                DC.L dot_pre,T_pre

                DC.L T_pre,H_pre
                DC.L H_pre,U_pre
                DC.L U_pre,N_pre
                DC.L N_pre,D_pre
                DC.L D_pre,E_pre
                DC.L E_pre,R_pre
                DC.L R_pre,D_pre
                DC.L D_pre,O_pre
                DC.L O_pre,M_pre
                DC.L M_pre,E_pre
*  DC.L E_pre,T_pre

                DC.L E_pre,dot_pre

                DC.L -1

checkpoint_list:
                DC.L C_pre,H_pre
                DC.L H_pre,E_pre
                DC.L E_pre,C_pre
                DC.L C_pre,K_pre
                DC.L K_pre,P_pre
                DC.L P_pre,O_pre
                DC.L O_pre,I_pre
                DC.L I_pre,N_pre
                DC.L N_pre,T_pre
                DC.L T_pre,C_pre
                DC.L -1

ipol_list_pos:  DC.L precalc_ipol_list
precalc_ipol_list:DS.L 32


__init_ipol_NEW:PART

*   DC.L $4AFC4E71

                move.w  #IPOL_STEPS-2,ipol_steps_counter

                move.l  A0,script_pos

                movea.l ipol_list_pos(PC),A0
                move.l  (A0)+,D0
                bpl.s   ii_not_end

;     lea     precalc_ipol_list(PC),A0
;     move.l  (A0)+,D0

                subq.l  #4,A0
                move.l  A0,ipol_list_pos

                st      objects_done_flag
                move.l  #script_end,script_pos

                rts

ii_not_end:
                move.l  A0,ipol_list_pos
                movea.l D0,A0
                bsr.s   ipol_init_NEW
                move.l  #do_ipol,ipol_rout
                rts
                ENDPART

objects_done_flag:DC.W 0


im_start_ptr:   DC.L 0

ipol_init_NEW:  >PART

                lea     im_start(PC),A2
                lea     ipol_current,A3

                move.w  amount_points(PC),D6
                neg.w   D6
                add.w   #256-1,D6
                add.w   D6,D6
                add.w   D6,D6           ;*4
                move.w  D6,D5
                add.w   D6,D6           ;*8
                add.w   D5,D6
                jmp     iiN_set(PC,D6.w)
iiN_set:
o               SET 2+2
                REPT MAX_DOTS
; x
                move.l  (A0)+,o(A2)     ; 4b
                move.l  (A0)+,(A3)+     ; 2b   x0<<16   ipol_current.x
o               SET o+8
; y
                move.l  (A0)+,o(A2)     ; 4b
                move.l  (A0)+,(A3)+     ; 2b   x0<<16   ipol_current.x
o               SET o+8         ;       ; ...12 bytes
                ENDR

                rts

                ENDPART

; A0,A1
ipol_init:      >PART

                move.w  #IPOL_STEPS,ipol_steps_counter

                move.w  (A0)+,D0        ; points
                move.w  (A1)+,D1        ; points

                lea     im_start(PC),A2

                move.w  #IPOL_PTS_MAX,D1
                sub.w   D0,D1
                mulu    #im_size,D1
                adda.l  D1,A2
                move.l  A2,im_startjmp+2
                addq.l  #2+2,A2         ; code modi start

                lea     ipol_current,A3

                move.w  D0,D6
                subq.w  #1,D6
                move.w  D6,amount_points
iil:
; x
                move.w  (A0)+,D0        ; x0
                move.w  (A1)+,D1        ; x1
                sub.w   D0,D1           ; x1-x0
                swap    D1
                clr.w   D1
                asr.l   #IPOL_STEP_BITS,D1
                move.l  D1,(A2)
                addq.l  #8,A2

                swap    D0
                clr.w   D0
                move.l  D0,(A3)+        ; x0<<16   ipol_current.x
; y
                move.w  (A0)+,D0        ; y0
                move.w  (A1)+,D1        ; y1
                sub.w   D0,D1           ; y1-y0
                swap    D1
                clr.w   D1
                asr.l   #IPOL_STEP_BITS,D1
                move.l  D1,(A2)
                addq.l  #8,A2

                swap    D0
                clr.w   D0
                move.l  D0,(A3)+        ; y0<<16   ipol_current.y

                dbra    D6,iil
                rts

                ENDPART

ipol_output:    >PART

*    DC.L $4AFC4E71

                lea     result(PC),A0
                lea     (A0),A1
                move.l  #160*65536+100,D2

                move.w  amount_points(PC),D6
                neg.w   D6
                add.w   #256-1,D6
                add.w   D6,D6
                jmp     io_center_xy(PC,D6.w)
io_center_xy:
                REPT 256
                add.l   D2,(A1)+
                ENDR

                move.l  (A0),(A1)+      ; last = first
;------------------------------------------------------------
                move.w  amount_points(PC),D6
                neg.w   D6
                add.w   #256-1,D6
                add.w   D6,D6           ; *2
                move.w  D6,D5
                add.w   D6,D6
                add.w   D6,D6           ; *8
                add.w   D5,D6
                jmp     output_lines_start(PC,D6.w)
output_lines_start:
o               SET 255*4
                REPT 256
                movem.w result+o(PC),D0-D3 ;  6b
                bsr     draw_line_eor_d0_d3 ; 4b ...10b
o               SET o-4
                ENDR
                rts

                ENDPART


ipol_steps_counter:DC.W 0
amount_points:  DC.W 0

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
init_all_objects:>PART

                lea     init_object_list(PC),A1
iao_loop:
                movea.l (A1)+,A0
                pea     (A1)
                bsr.s   init_obj
                movea.l (SP)+,A1
                tst.l   (A1)
                bpl.s   iao_loop

                bsr.s   compute_objects_pre
                rts
                ENDPART
init_obj:       >PART
                pea     (A0)
                movea.l 4(A0),A0
                bsr     init_spline_object
                movea.l (SP)+,A1
                move.l  A0,(A1)
                rts
                ENDPART

init_object_list:
                DC.L c_sobj
                DC.L e_sobj
                DC.L h_sobj
                DC.L i_sobj
                DC.L k_sobj
                DC.L n_sobj
                DC.L o_sobj
                DC.L p_sobj
                DC.L t_sobj

                DC.L u_sobj
                DC.L d_sobj
                DC.L r_sobj
                DC.L m_sobj

                DC.L -1

                ENDPART

;------------------------------------------------------------------------------

compute_objects_pre:>PART

*    DC.L $4AFC4E71

                lea     cop_list(PC),A6
cop_loop:
                movem.l (A6)+,A0-A2
                pea     (A6)
                bsr     calc_spline_object
                movea.l (SP)+,A6
                tst.l   (A6)
                bpl.s   cop_loop
                rts

                ENDPART
cop_list:
                DC.L c_sobj,C_pre,0
                DC.L h_sobj,H_pre,0
                DC.L e_sobj,E_pre,0
                DC.L k_sobj,K_pre,0
                DC.L p_sobj,P_pre,0
                DC.L o_sobj,O_pre,0
                DC.L i_sobj,I_pre,0
                DC.L n_sobj,N_pre,0
                DC.L t_sobj,T_pre,0

                DC.L u_sobj,U_pre,0
                DC.L d_sobj,D_pre,0
                DC.L r_sobj,R_pre,0
                DC.L m_sobj,M_pre,0

                DC.L -1


; A0 ... knots
; A1 ... output
calc_spline_object:>PART

                move.l  A1,op_current

*    DC.L $4AFC4E71

;  movea.l ols_ptr(PC),A0
;  movea.l (A0),A0
;  lea     h_sobj,A0

                movea.l (A0),A0
                addq.l  #2,A0           ;amount patches
                move.w  (A0)+,D5        ;amount_control_points
                move.w  D5,amount_control_points

                lea     temp,A1
                move.l  A1,current_control_points
cso_copy:
                move.l  (A0)+,(A1)+     ; x,y
                dbra    D5,cso_copy

                bsr     DO_SPLINE_LINE


                movea.l ols_ptr(PC),A0
                addq.l  #4,A0
                tst.l   (A0)
                bpl.s   cso_more_frames
                lea     obj_list_src(PC),A0
cso_more_frames:
                move.l  A0,ols_ptr

                rts

ols_ptr:        DC.L obj_list_src

f0:             DC.W 256
f1:             DC.W 0

                ENDPART

obj_list_src:
                DC.L c_sobj
                DC.L h_sobj
                DC.L e_sobj
                DC.L c_sobj
                DC.L k_sobj
                DC.L p_sobj
                DC.L o_sobj
                DC.L i_sobj
                DC.L n_sobj
                DC.L t_sobj
                DC.L -1


swap_screens:   >PART
                move.l  screen1(PC),D0
                move.l  screen0(PC),screen1
                move.l  D0,screen0
                lsr.w   #8,D0
                move.l  D0,$FFFF8200.w
                rts
                ENDPART




obj1:           DC.L 0
obj2:           DC.L 0


scr_list_pos:   DC.L scrlist
scrlist:
                DC.L c_sobj
                DC.L h_sobj
                DC.L e_sobj
                DC.L c_sobj
                DC.L k_sobj
                DC.L p_sobj
                DC.L o_sobj
                DC.L i_sobj
                DC.L n_sobj
                DC.L t_sobj
                DC.L -1


;-------------------------------------------------------------------------------
hermite_coeff_4096:>PART        ;IN:  D0.w 0...4095     OUT: 2^16 A0...A3

; z = 3 * t^2  - 2* t^3

; h1 = 1 - z
; h2 = z
; h3 = t^3 - 2 * t^2 + t        t*(t*(t-2)+1)
; h4 = t^3 - t^2

                moveq   #0,D1
                move.w  D0,D1
                move.w  D0,D2
                move.w  D0,D3

                mulu    D2,D2           ;t*t                     2^12 * 2^12
                lsr.l   #8,D2           ;        auf 2^16
                mulu    D2,D3           ;t*t*t                   2^16 * 2^12
                lsr.l   #8,D3
                lsr.l   #4,D3           ;        auf 2^16

                lsl.l   #4,D1           ;        auf 2^16

;      normiert auf 2^16:
;D1...t
;D2...t^2
;D3...t^3

; z = 3 * t^2  - 2* t^3
                move.l  D2,D6
                add.l   D6,D6           ; 2* t^2
                move.l  D6,D7
                add.l   D2,D7           ; 3* t^2

                sub.l   D3,D7
                sub.l   D3,D7           ; -2* t^3
; D7...z

; h1 = 1 - z
                move.l  #65536,D4
                sub.l   D7,D4           ; 1 - z
                movea.l D4,A0           ; h1   =  1-z

; h2 = z
                movea.l D7,A1           ; h2   =  z


; h4 = t^3 - t^2
                move.l  D3,D4           ;t^3
                sub.l   D2,D4           ;t^3 - t^2
                movea.l D4,A3

; h3 = t^3 - 2 * t^2 + t
                sub.l   D2,D4           ;t^3 - 2*t^2
                add.l   D1,D4           ;t^3-2*t^2  + t
                movea.l D4,A2

;...A0-A3   h1...h4            auf 2^16
                rts
                ENDPART
;-------------------------------------------------------------------------------
hermite_coeff_65536:>PART       ;IN:  D0.w 0...65535    OUT: 2^16 A0...A3

; z = 3 * t^2  - 2* t^3

; h1 = 1 - z
; h2 = z
; h3 = t^3 - 2 * t^2 + t        t*(t*(t-2)+1)
; h4 = t^3 - t^2

                moveq   #0,D1
                move.w  D0,D1
                move.w  D0,D2
                move.w  D0,D3

                mulu    D2,D2           ;t*t                     2^16 * 2^16
                clr.w   D2
                swap    D2              ;auf 2^16

                mulu    D2,D3           ;t*t*t                   2^16 * 2^16
                clr.w   D3
                swap    D3

;      normiert auf 2^16:
;D1...t
;D2...t^2
;D3...t^3

; z = 3 * t^2  - 2* t^3
                move.l  D2,D6           ;    t^2
                add.l   D6,D6           ; 2* t^2
                move.l  D6,D7
                add.l   D2,D7           ; 3* t^2

                sub.l   D3,D7
                sub.l   D3,D7           ; -2* t^3
; D7...z

; h1 = 1 - z
                move.l  #65536,D4
                sub.l   D7,D4           ; 1 - z
                movea.l D4,A0           ; h1   =  1-z

; h2 = z
                movea.l D7,A1           ; h2   =  z


; h4 = t^3 - t^2
                move.l  D3,D4           ;t^3
                sub.l   D2,D4           ;t^3 - t^2
                movea.l D4,A3

; h3 = t^3 - 2 * t^2 + t
                sub.l   D2,D4           ;t^3 - 2*t^2
                add.l   D1,D4           ;t^3-2*t^2  + t
                movea.l D4,A2

;...A0-A3   h1...h4            auf 2^16
                rts
                ENDPART
;-------------------------------------------------------------------------------

hermite_coeff_65536_14:>PART    ;IN:  D0.w 0...16384    OUT: 2^16 A0...A3

; z = 3 * t^2  - 2* t^3

; h1 = 1 - z
; h2 = z
; h3 = t^3 - 2 * t^2 + t        t*(t*(t-2)+1)
; h4 = t^3 - t^2

                moveq   #14,D5

                moveq   #0,D1

                move.w  D0,D1
                move.w  D0,D2
                move.w  D0,D3

                mulu    D2,D2           ;t*t                     2^16 * 2^16
                lsr.l   D5,D2           ;auf 2^16

                mulu    D2,D3           ;t*t*t                   2^16 * 2^16
                lsr.l   D5,D3

;      normiert auf 2^16:
;D1...t
;D2...t^2
;D3...t^3

; z = 3 * t^2  - 2* t^3
                move.l  D2,D6           ;    t^2
                add.l   D6,D6           ; 2* t^2
                move.l  D6,D7
                add.l   D2,D7           ; 3* t^2

                sub.l   D3,D7
                sub.l   D3,D7           ; -2* t^3
; D7...z

; h1 = 1 - z
                move.l  #16384,D4
                sub.l   D7,D4           ; 1 - z
                movea.l D4,A0           ; h1   =  1-z

; h2 = z
                movea.l D7,A1           ; h2   =  z


; h4 = t^3 - t^2
                move.l  D3,D4           ;t^3
                sub.l   D2,D4           ;t^3 - t^2
                movea.l D4,A3

; h3 = t^3 - 2 * t^2 + t
                sub.l   D2,D4           ;t^3 - 2*t^2
                add.l   D1,D4           ;t^3-2*t^2  + t
                movea.l D4,A2

;...A0-A3   h1...h4            auf 2^16
                rts
                ENDPART


precompute_spline:>PART
;     DC.L $4AFC4E71

                lea     spline_coeffs_h1h2h3h4(PC),A5

                moveq   #16-SPLINE_BITS,D6
                subq.w  #2,D6           ; auf 2^16

                move.w  #STEPS-1,D7
ph_l:
                move.w  #STEPS-1,D0
                sub.w   D7,D0

                swap    D0              ; *65536
                clr.w   D0
                lsr.l   #2,D0           ; 2^14

                divu    #STEPS,D0
A:

                movem.l D6-D7/A5-A6,-(SP)
                bsr.s   hermite_coeff_65536_14
                movem.l (SP)+,D6-D7/A5-A6

                move.l  A0,D0           ;h1
                asr.l   D6,D0
                move.w  D0,(A5)+

                move.l  A1,D0           ;h2
                asr.l   D6,D0
                move.w  D0,(A5)+

                move.l  A2,D0           ;h3
                asr.l   D6,D0
                move.w  D0,(A5)+

                move.l  A3,D0           ;h4
                asr.l   D6,D0
                move.w  D0,(A5)+

                dbra    D7,ph_l
                rts
                ENDPART

spline_coeffs_h1h2h3h4:
                DS.W STEPS*4

;-------------------------------------------------------------------------------

amount_control_points:DC.W 0
wrap_control_point:DC.W 0       ;+(amount_control_points+1)
current_control_points:DC.L 0

DO_SPLINE_LINE: >PART

                clr.w   amt_points

                movea.l op_current(PC),A0
                move.l  A0,op_current_start
                move.w  #'CP',(A0)+     ; amt_points
                move.l  A0,op_current
;------------------------------------------------------------------

                move.w  amount_control_points(PC),D0
                addq.w  #1,D0
                move.w  D0,wrap_control_point ; (amount_control_points+1)

;¯FOR i=0 TO amount_control_points
                moveq   #0,D0

do_all_spline_lines:
                move.w  D0,-(SP)
;¯adj0=0.5
;¯adj1=0.5

                bsr     get_spline_points

                movea.l current_control_points(PC),A0
                lsl.w   #2,D0
                lsl.w   #2,D1
                lsl.w   #2,D2
                lsl.w   #2,D3
                lea     0(A0,D3.w),A3   ;kn
                lea     0(A0,D2.w),A2   ;k1
                lea     0(A0,D1.w),A1   ;k0
                adda.w  D0,A0           ;kp

;  d10__y          EQU y1-y0
;  dd0__y          EQU adj0*((y0-yp)+d10__y)
;  ds1__y          EQU adj1*((yn-y1)+d10__y)


                move.w  2(A2),D7        ;y1
                sub.w   2(A1),D7        ;y1-y0
                move.w  2(A1),D6        ;y0
                sub.w   2(A0),D6        ;y0-yp
                add.w   D6,D7
                asr.w   #1,D7           ; *adj0          0.5
                move.w  D7,-(SP)        ;### dd0__y ###

                move.w  2(A3),D5        ;yn
                sub.w   2(A2),D5        ;yn-y1
                add.w   D6,D5
                asr.w   #1,D5           ; *adj1          0.5
                move.w  D5,-(SP)        ;### ds1__y ###

                move.w  2(A1),-(SP)     ;### y0 ###
                move.w  2(A2),-(SP)     ;### y1 ###

; d10__x = x1-x0
;  dd0__x          EQU adj0*((x0-xp)+d10__x)
;  ds1__x          EQU adj1*((xn-x1)+d10__x)
;¯'

;¯x = x0 *h1 +  x1 *h2  +  dd0__x *h3  +  ds1__x  *h4
;¯y = y0 *h1 +  y1 *h2    +dd0__y *h3  +  ds1__y  *h4


                move.w  (A2),D4         ;x1
                sub.w   (A1),D4         ;x1-x0
                move.w  (A1),D2         ;x0
                sub.w   (A0),D2         ;x0-xp
                add.w   D4,D2
                asr.w   #1,D2           ; *adj0          0.5
; D2                                 ;### dd0__x ###

                move.w  (A3),D3         ;xn
                sub.w   (A2),D3         ;xn-x1
                add.w   D4,D3
                asr.w   #1,D3           ; *adj1          0.5
; D3                                    ;### ds1__x ###

                move.w  (A1),D0         ;### x0 ###
                move.w  (A2),D1         ;### x1 ###

; D0 ... x0
; D1 ... x1
; D2 ... dd0__x
; D3 ... ds1__x
;------------------------------------------------------------

                lea     x_result_buffer,A4
                bsr     points_mul_spline_X
;------------------------------------------------------------
; D0 ... y0
; D1 ... y1
; D2 ... dd0__y
; D3 ... ds1__y
                move.w  (SP)+,D1        ;### y1 ###
                move.w  (SP)+,D0        ;### y0 ###
                move.w  (SP)+,D3        ;### ds1__y ###
                move.w  (SP)+,D2        ;### dd0__y ###
;------------------------------------------------------------
                lea     y_result_buffer,A4
                bsr     points_mul_spline_Y
;------------------------------------------------------------

*  DC.L $4AFC4E71

;;  bsr     draw_dots

                bsr.s   output_points

                addi.w  #STEPS,amt_points

                move.w  (SP)+,D0
                addq.w  #1,D0
                cmp.w   amount_control_points(PC),D0
                ble     do_all_spline_lines

                movea.l op_current_start(PC),A0
                move.w  amt_points(PC),(A0)+

                rts

                ENDPART


amt_points:     DC.W 0
op_current:     DC.L 0
op_current_start:DC.L 0

output_points:  >PART

*  DC.L $4AFC4E71

                movea.l op_current(PC),A6

                lea     x_result_buffer,A0
                lea     y_result_buffer,A1

                move.w  #STEPS-1,D7
opl:
                move.w  (A0)+,(A6)+     ; x
                move.w  (A1)+,(A6)+     ; y
                dbra    D7,opl

                move.l  A6,op_current

                rts
                ENDPART


get_spline_points:>PART         ;IN: D0 (i)    (i,VAR kp,k0,k1,kn)
                move.w  D0,D1           ;k0
                move.w  D0,D2           ;k1
                move.w  D0,D3           ;kn

; D0..kp       i-1
; D1..k0       i
; D2..k1       i+1
; D3..kn       i+2

                addq.w  #1,D2           ;i+1
                addq.w  #2,D3           ;i+2

;    FšR GESCHLOSSENE KURVE:

; if (kp<0) kp+=(amount_control_points+1);
                subq.w  #1,D0           ;i+1
                bpl.s   kp_is_ok___gsp
                add.w   wrap_control_point(PC),D0 ;+(amount_control_points+1)
kp_is_ok___gsp:

; if(kn>amount_control_points) kn-=(amount_control_points+1);
                cmp.w   amount_control_points(PC),D2
                ble.s   kn_is_ok__gsp
                sub.w   wrap_control_point(PC),D2 ;-(amount_control_points+1)
kn_is_ok__gsp:

; if(k1>amount_control_points) k1-=(amount_control_points+1);
                cmp.w   amount_control_points(PC),D3
                ble.s   k1_is_ok__gsp
                sub.w   wrap_control_point(PC),D3 ;-(amount_control_points+1)
k1_is_ok__gsp:
                rts
                ENDPART

;-------------------------------------------------------------------------------

; D0 ... x0
; D1 ... x1
; D2 ... dd0__x
; D3 ... ds1__x
points_mul_spline_X:>PART


*   bra     pms_explog

                bra.s   no_up

                moveq   #6,D4
                asl.w   D4,D0
                asl.w   D4,D1
                asl.w   D4,D2
                asl.w   D4,D3
no_up:

* moveq   #SPLINE_BITS-2,D6 ; keep 2 bits

                moveq   #SPLINE_BITS,D6 ; keep 2 bits

                lea     spline_coeffs_h1h2h3h4(PC),A5

; precision test
                REPT STEPS

                move.w  D0,D4           ; x0
                muls    (A5)+,D4        ; x0  *  h1

                move.w  D1,D5           ; x1
                muls    (A5)+,D5        ; x1  *  h2
                add.l   D5,D4

                move.w  D2,D5           ; x2
                muls    (A5)+,D5        ; x2  *  h3
                add.l   D5,D4

                move.w  D3,D5           ; x3
                muls    (A5)+,D5        ; x3  *  h4
                add.l   D5,D4

                asr.l   D6,D4

                move.w  D4,(A4)+
                ENDR

                rts


                move.w  D0,D4           ; x0
                muls    (A5)+,D4        ; x0  *  h1

                move.w  D1,D5           ; x1
                muls    (A5)+,D5        ; x1  *  h2
                add.l   D5,D4

                move.w  D2,D5           ; x2
                muls    (A5)+,D5        ; x2  *  h3
                add.l   D5,D4

                move.w  D3,D5           ; x3
                muls    (A5)+,D5        ; x3  *  h4
                add.l   D5,D4

*    asl.l   #2,D4
                swap    D4
                move.w  D4,(A4)+

;-------------------------------------------------------


                REPT STEPS
                move.l  0(A0),D0        ; x0  *  h1
                add.l   0(A1),D0        ; x1  *  h1
                add.l   0(A2),D0        ; x2  *  h2
                add.l   0(A3),D0        ; x3  *  h3
                swap    D0
                move.w  D0,(A4)+
                ENDR
pms_X_end:
                rts
                ENDPART

; D0 ... y0
; D1 ... y1
; D2 ... dd0__y
; D3 ... ds1__y
points_mul_spline_Y:>PART

                bra     points_mul_spline_X

                ENDPART

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

init_spline_object:>PART
;   DC.L $4AFC4E71

                movea.l iso_free_ptr(PC),A1
                pea     (A1)

                move.w  (A0)+,D0        ;amount patches in the object
;                                        (currently 0)
                move.w  D0,iso_patches
                move.w  D0,(A1)+


                move.w  (A0)+,D1        ;amount_control_points -1
                move.w  D1,iso_points
                move.w  D1,(A1)+


*   DC.L $4AFC4E71

                move.w  D1,D7
                bsr.s   iso_get_min_max


                move.w  D1,D7
iso_l:
                move.w  (A0)+,D0        ;x
                move.w  (A0)+,D1        ;y
                move.w  (A0)+,D2        ;z(unused)

                add.w   iso_center_x(PC),D0
                add.w   iso_center_y(PC),D1

                asl.w   #1,D0
;    asl.w   #1,D1

                muls    #256+160,D1
                asr.l   #8,D1


                move.w  D0,(A1)+
                move.w  D1,(A1)+
                dbra    D7,iso_l


;-------- copydata again   ROTZ!

;   DC.L $4AFC4E71
                movea.l (SP),A0
                addq.l  #4,A0

*   move.w  iso_points(PC),D7
*iso_double:
*   move.w  (A0)+,(A1)+     ;x
*   move.w  (A0)+,(A1)+     ;y
*   dbra    D7,iso_double

                move.l  #'END!',(A1)+

                move.l  A1,iso_free_ptr
                movea.l (SP)+,A0
                rts

iso_get_min_max:
;    DC.L $4AFC4E71

                movem.l D0-A6,-(SP)
                lea     iso_xmin(PC),A1
                move.l  #$7FFF8000,D0
                move.l  D0,(A1)+
                move.l  D0,(A1)+
                move.l  D0,(A1)+
iso_gmm:
                lea     iso_xmin(PC),A1
                moveq   #3-1,D6
iso_gmm_components:
                move.w  (A0)+,D0

                cmp.w   (A1)+,D0
                bge.s   *+4
                move.w  D0,-2(A1)

                cmp.w   (A1)+,D0
                ble.s   *+4
                move.w  D0,-2(A1)

                dbra    D6,iso_gmm_components
                dbra    D7,iso_gmm


                lea     iso_xmin(PC),A1
                lea     iso_center_x(PC),A2
                moveq   #3-1,D7
iso_get_center:
                move.w  (A1)+,D0        ;min
                sub.w   (A1)+,D0        ;-max
                asr.w   #1,D0           ;/2  center

                sub.w   -4(A1),D0


                move.w  D0,(A2)+
                dbra    D7,iso_get_center

                movem.l (SP)+,D0-A6
                rts

iso_xmin:       DC.W 0
iso_xmax:       DC.W 0

iso_ymin:       DC.W 0
iso_ymax:       DC.W 0

iso_zmin:       DC.W 0          ;u
iso_zmax:       DC.W 0          ;u


iso_center_x:   DC.W 0
iso_center_y:   DC.W 0
iso_center_z:   DC.W 0          ;u


iso_patches:    DC.W 0
iso_points:     DC.W 0

iso_free_ptr:   DC.L sobj_converted
                ENDPART

;-------------------------------------------------------------------------------
vbl:            >PART
                movem.l D0-A6,-(SP)
                movem.l (SP)+,D0-A6
                addq.l  #1,$00000466.w
                rte
                ENDPART
wait_vbl:       >PART
                clr.l   $00000466.w
wv:             tst.l   $00000466.w
                beq.s   wv
                rts
                ENDPART
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
Init_Linerout:  >PART

                bsr     make_linecode
                bsr     make_linecode2

                rts

                ENDPART
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
                movem.w (A0),D0-D3
                bsr.s   draw_line_eor_d0_d3_SD

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

x0:             DC.W 0
y0:             DC.W 0
x1:             DC.W 319
y1:             DC.W 199

xs:             DC.W 0
ys:             DC.W 0

; subdiv
draw_line_eor_d0_d3_SD:>PART    ; subdivided

                movem.w D0-D3,x0

                add.w   D0,D2
                add.w   D1,D3
                asr.w   #1,D2
                asr.w   #1,D3
                movem.w D2-D3,xs

                bsr.s   draw_line_eor_d0_d3

                movem.w xs(PC),D0-D1
                movem.w x1(PC),D2-D3

                bsr.s   draw_line_eor_d0_d3

                rts

                ENDPART

;-----------------------------------------------------------
draw_line_eor_d0_d3:
output_line_d0_d3:>PART

                cmp.w   D0,D2
                beq     senkrecht
                bge.s   links_rechts
                exg     D0,D2
                exg     D1,D3
links_rechts:
                sub.w   D0,D2           ; dx

                moveq   #2,D5           ;Offset Y Pos/Neg

                sub.w   D1,D3           ; dy
                bpl.s   dy_positiv
                neg.w   D3
                neg.w   D5
dy_positiv:
                movea.w D5,A2           ;šbertrag Y Offset
                ext.l   D3              ; and.l   #$0000FFFF,D3

                divu    D2,D3           ; dy/dx
                muls    D3,D5           ; * Offset_Y   Y_Offset Increment

                clr.w   D3
                divu    D2,D3           ;fractional part
                movea.w D3,A3           ;Fractional Increment
                swap    D3              ;Rest
                add.w   #$8000,D3       ;+0.5
                move.w  D3,D6           ;Fractional


; A0 Buffer
; A2 šbertrag Y Offset
; A3 Fractional Increment

; D6 Fractional
; D5 Y_Offset Increment   was: D7

                lea     y_field,A0
                add.w   D1,D1
                adda.w  D1,A0           ; + Y_START

                move.w  D0,D1
                lsr.w   #4,D1           ;/16
                bcc.s   even_start
                addq.l  #1,A0
even_start:
                muls    #200*2,D1       ;Offset next 16Pix
                adda.w  D1,A0           ; + X_OFFSET

                and.w   #15,D0          ; X Shift
                add.w   D0,D0
                add.w   D0,D0

                tst.w   D5
                beq.s   Y_STG_LESS_1

                lea     linecode_offset(PC),A1
                adda.w  D0,A1           ;X Start

                add.w   D2,D2
                add.w   D2,D2           ;dx*4
                move.l  (A1),line_start1+2

                movea.l 0(A1,D2.w),A1
                move.w  (A1),-(SP)
                move.w  #$4E75,(A1)

                moveq   #1,D0
                moveq   #4,D1
                moveq   #3,D2
                moveq   #5,D3
                moveq   #6,D4

line_start1:    jsr     0

                move.w  (SP)+,(A1)
                rts
                ENDPART
;-------------------------
Y_STG_LESS_1:   >PART

                lea     linecode_offset2(PC),A1
                adda.w  D0,A1           ;X Start

                add.w   D2,D2
                add.w   D2,D2           ;dx*4

                move.l  (A1),line_start2+2
                movea.l 0(A1,D2.w),A1   ; end of line
                move.w  (A1),-(SP)
                move.w  #$4E75,(A1)

                moveq   #1,D0
                moveq   #4,D1
                moveq   #3,D2
                moveq   #5,D3
                moveq   #6,D4
* moveq   #$80,D5

                moveq   #0,D5           ;Clear Plotbits!

line_start2:    jsr     0

                eor.b   D5,(A0)

                move.w  (SP)+,(A1)
                rts
senkrecht:
;D0 XS   D1 YS
;D2 XE   D3 YE
                cmp.w   D1,D3
                bne.s   d1_not_d3
                rts                     ;P1 = P2 !
d1_not_d3:
                lea     y_field,A0
                add.w   D1,D1
                adda.w  D1,A0           ; + Y_START

                move.w  D0,D1           ;X_START
                and.w   #$000F,D0
                add.w   D0,D0
                move.w  bits(PC,D0.w),D0 ;bits

                lsr.w   #4,D1           ;/16
                muls    #200*2,D1
                adda.w  D1,A0           ; + X_OFFSET

                eor.w   D0,(A0)         ;XS;YS

                lea     y_field,A0
                add.w   D3,D3
                adda.w  D3,A0           ; + Y_END
                adda.w  D1,A0           ; + X_OFFSET
                eor.w   D0,(A0)         ;XE;YE

                rts

                OPT W-
bits:
b               SET $8000
                REPT 16
                DC.W b
b               SET b>>1
                ENDR

                OPT W+

                ENDPART
;-----------------------------------------------------------
linecode_offset:DS.L 640
linecode_offset2:DS.L 640
;-------------------------------------------------------------------------------
Output_y_field: >PART

                lea     y_field,A0

                movea.l screen1(PC),A1
                adda.w  il_bitplane(PC),A1

                move.w  #320/16-1,-(SP)
Oyf_lines:

o               SET 0

                movem.w (A0)+,D0-D6     ; 7 lines

                move.w  D0,(A1)
o               SET o+160
                eor.w   D1,D0
                move.w  D0,o(A1)
o               SET o+160
                eor.w   D2,D0
                move.w  D0,o(A1)
o               SET o+160
                eor.w   D3,D0
                move.w  D0,o(A1)
o               SET o+160
                eor.w   D4,D0
                move.w  D0,o(A1)
o               SET o+160
                eor.w   D5,D0
                move.w  D0,o(A1)
o               SET o+160
                eor.w   D6,D0
                move.w  D0,o(A1)
o               SET o+160

; 200 - 7 = 193
; 193 / 6 = 32, rest: 1 !
                REPT 32

                movem.w (A0)+,D1-D6     ; 6 lines
                eor.w   D1,D0
                move.w  D0,o(A1)
o               SET o+160
                eor.w   D2,D0
                move.w  D0,o(A1)
o               SET o+160
                eor.w   D3,D0
                move.w  D0,o(A1)
o               SET o+160
                eor.w   D4,D0
                move.w  D0,o(A1)
o               SET o+160
                eor.w   D5,D0
                move.w  D0,o(A1)
o               SET o+160
                eor.w   D6,D0
                move.w  D0,o(A1)
o               SET o+160

                ENDR

                move.w  (A0)+,D1
                eor.w   D1,D0
                move.w  D0,o(A1)
o               SET o+160

                addq.l  #8,A1           ; next 16 pix screen

                subq.w  #1,(SP)
                bpl     Oyf_lines
                addq.l  #2,SP
                rts

                ENDPART
Clear_y_field:  >PART

                move.l  SP,cyf_sp+2
                lea     y_field+8000,SP

                movem.l zero(PC),D0-D6/A0-A3 ; 44 bytes
; 8000/44 = 181, rest 36

                REPT 181
                movem.l D0-D6/A0-A3,-(SP)
                ENDR

                movem.l D0-D6/A0-A1,-(SP)

cyf_sp:         lea     0,SP
                rts
                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

make_linecode:  >PART
;--- LINIENCODE FOR STEIGUNG >= 1

*        DC.L $4AFC4E71

                lea     linecode_offset(PC),A5
                lea     linecode,A6

                lea     ml_setpix(PC),A4
                moveq   #0,D5           ;Flag Even/Odd Offset Inc.
                moveq   #7-1,D6         ;Bitrun

                move.w  #320+16,D7
ml_build:
                move.l  A6,(A5)+        ;Offset

                move.w  (A4)+,(A6)+     ; pixset
                bne.s   ml_nz0
                subq.l  #2,A6
                move.l  ml_setpix7(PC),(A6)+ ; pixset
ml_nz0:

                lea     ml_y(PC),A0
                bsr     ml_write_ycode

                dbra    D6,ml_morepix

                not.w   D5
                beq.s   ml_eveninc

                move.l  A6,(A5)+        ;Offset
                move.w  ml_lastpix_inc1(PC),(A6)+ ;         eor.b d0,(a5)+
                lea     ml_y(PC),A0
                bsr     ml_write_ycode

                bra.s   ml_incdone
ml_eveninc:
                move.l  A6,(A5)+        ;Offset
                move.w  (A4)+,(A6)+     ;eor.b d0,(a5)
                lea     ml_y(PC),A0
                bsr     ml_write_ycode
                move.l  ml_lastpix_inc2(PC),(A6)+ ;         lea NEXT_O(a5),a5
ml_incdone:
                subq.w  #1,D7
                bmi.s   ml_build_end

                moveq   #7-1,D6         ;Bitrun
                lea     ml_setpix(PC),A4
ml_morepix:
                dbra    D7,ml_build
ml_build_end:
                move.l  A5,D0
                sub.l   #linecode_offset,D0
                lsr.l   #2,D0

*     DC.L $4AFC4E71

                lea     (A6),A0
                suba.l  #linecode,A0
                rts

; D0 = 1   0001      --> Bit 0,1
; D1 = 4   0100      --> Bit 2,4
; D2 = 3   0011      --> Bit 3
; D3 = 5                 Bit 5
; D4 = 6                 Bit 6
;                                     D5 = $80               Bit 7

ml_setpix7:
                eori.b  #$80,(A0)       ;Bit 7

ml_setpix:
                DC.W 0          ;  eor.b   D5,(A0)         ;Bit 7
                bchg    D4,(A0)         ;Bit 6
                bchg    D3,(A0)         ;Bit 5
                bchg    D1,(A0)         ;Bit 4
                bchg    D2,(A0)         ;Bit 3
                eor.b   D1,(A0)         ;Bit 2
                bchg    D0,(A0)         ;Bit 1
                eor.b   D0,(A0)         ;Bit 0

ml_lastpix_inc1:eor.b   D0,(A0)+
ml_lastpix_inc2:lea     NEXT_X-1(A0),A0

ml_y:
                DC.W (ml_ye-ml_y-2)/2-1
                add.w   A3,D6
                bcc.s   *+2
                adda.w  A2,A0           ;šbertrag Y
                adda.w  D5,A0           ;Normaler Anstieg Y   was: D7
ml_ye:
                ENDPART

make_linecode2: >PART
;--- LINIENCODE FOR STEIGUNG < 1

*    DC.L $4AFC4E71

                lea     linecode_offset2(PC),A5
                lea     linecode2,A6

                lea     ml_setpix2(PC),A4
                moveq   #0,D5           ;Flag Even/Odd Offset Inc.
                moveq   #7-1,D6         ;Bitrun

                move.w  #320+16,D7
ml_build2:
                move.l  A6,(A5)+        ;Offset

                move.w  (A4)+,(A6)+
                lea     ml_y2(PC),A0
                bsr.s   ml_write_ycode

                dbra    D6,ml_morepix2
                not.w   D5
                beq.s   ml_eveninc2

                move.l  A6,(A5)+        ;Offset
                move.w  (A4)+,(A6)+     ;              or.b d0,d7
                move.w  ml_lastpix_inc1_2(PC),(A6)+ ;         eor.b d7,(a5)+
                bra.s   ml_incdone2
ml_eveninc2:
                move.l  A6,(A5)+        ;Offset
                move.w  (A4)+,(A6)+     ;              or.b d0,d7
                move.w  ml_lastpix_inc2_2(PC),(A6)+ ;         eor.b d7,(a5)
                move.l  ml_lastpix_inc2_2+2(PC),(A6)+ ;         lea NEXT_O(a5),a5
ml_incdone2:
                lea     ml_y2_nowrite(PC),A0
                bsr.s   ml_write_ycode

                moveq   #7-1,D6         ;Bitrun
                lea     ml_setpix2(PC),A4
                subq.w  #1,D7
                bmi.s   ml_build_end2
ml_morepix2:
                dbra    D7,ml_build2
ml_build_end2:

*    DC.L $4AFC4E71

                lea     (A6),A0
                suba.l  #linecode2,A0
                rts

ml_setpix2:
                moveq   #$80,D5         ; * move.b  D5,D7           ;Bit 7
                bset    D4,D5           ;Bit 6
                bset    D3,D5           ;Bit 5
                bset    D1,D5           ;Bit 4
                bset    D2,D5           ;Bit 3
                or.b    D1,D5           ;Bit 2
                bset    D0,D5           ;Bit 1
                or.b    D0,D5           ;Bit 0

ml_lastpix_inc1_2:
                eor.b   D5,(A0)+        ;2b

ml_lastpix_inc2_2:
                eor.b   D5,(A0)         ;2b
                lea     NEXT_X-1(A0),A0 ;4b

ml_y2:
                DC.W (ml_ye2-ml_y2-2)/2-1

                add.w   A3,D6
                bcc.s   ml_ye2
                eor.b   D5,(A0)
                moveq   #0,D5
                adda.w  A2,A0           ;šbertrag Y
ml_ye2:

ml_y2_nowrite:
                DC.W (ml_ye2_nowrite-ml_y2_nowrite-2)/2-1
                moveq   #0,D5           ;<-- MUSS!!  sonst eor nach Verlassen!
; Oder evtl. eine Logik ...

                add.w   A3,D6
                bcc.s   ml_ye2_nowrite
                adda.w  A2,A0           ;šbertrag Y
ml_ye2_nowrite:
                ENDPART

ml_write_ycode: >PART
                move.w  (A0)+,D0
ml_ycode:       move.w  (A0)+,(A6)+
                dbra    D0,ml_ycode
                rts
                ENDPART

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------


init_colors_plane_effec:>PART

; icpe_new:

*   DC.L $4AFC4E71

                lea     colors_plane_effect,A0

                lea     icpe_list(PC),A1

                moveq   #4-1,D5
icpe_frames_new:
                moveq   #16-1,D6
icpe_l_new:
                lea     (A1),A2
                moveq   #16-1,D0
                sub.w   D6,D0
                beq.s   icpe_n_zero

                clr.w   red
                clr.w   green
                clr.w   blue

                moveq   #0,D2

                REPT 4
                lsr.b   #1,D0
                bcc.s   *+4
                addq.b  #1,D2
                bsr.s   mix_color_a2

                addq.l  #2,A2
                ENDR

                movem.w red(PC),D0-D2

*   lsr.w   #4,D0           ; /16
*   lsr.w   #4,D1           ; /16
*   lsr.w   #4,D2           ; /16

                moveq   #7,D3
                cmp.w   D3,D0
                ble.s   *+2
                move.w  D3,D0
                cmp.w   D3,D1
                ble.s   *+2
                move.w  D3,D1
                cmp.w   D3,D2
                ble.s   *+2
                move.w  D3,D2


                lsl.w   #4,D0
                or.w    D1,D0
                lsl.w   #4,D0
                or.w    D2,D0

                move.w  D0,(A0)+

                bra.s   icpe_n_next
;-----------------------------------------------
                cmp.b   #1,D2
                bne.s   more_bitplanes

                move.w  (A2),(A0)+
                bra.s   icpe_n_next
icpe_n_zero:
                move.w  #$0000,(A0)+
                bra.s   icpe_n_next
more_bitplanes:
                move.w  #$0777,(A0)+
icpe_n_next:
                dbra    D6,icpe_l_new

                addq.l  #4*2,A1

                dbra    D5,icpe_frames_new
                rts

red:            DC.W 0
green:          DC.W 0
blue:           DC.W 0

mix_color_a2:
                movem.l D0-D1,-(SP)

                move.w  (A2),D0
                moveq   #7,D1           ; blue
                and.w   D0,D1
                add.w   D1,blue

                lsr.w   #4,D0
                moveq   #7,D1           ; green
                and.w   D0,D1
                add.w   D1,green

                lsr.w   #4,D0
                and.w   #7,D0           ; red
                add.w   D0,red

                movem.l (SP)+,D0-D1

                rts

                ENDPART

;C3              SET $0432
;C2              SET $0321
;C1              SET $0210
;C0              SET $0100

__C0            SET $0777
__C1            SET $0556       ;   555
__C2            SET $0445       ;    444
__C3            SET $0224       ;224    334

C3              SET $0522
C2              SET $0421
C1              SET $0311
C0              SET $0201

icpe_list:      >PART
                DC.W C0,C1,C2,C3
                DC.W C3,C0,C1,C2
                DC.W C2,C3,C0,C1
                DC.W C1,C2,C3,C0
                ENDPART

interlace_effect:>PART

                not.w   ilf
                beq.s   no_il
                addq.w  #1,il_frame
                andi.w  #3,il_frame
                addq.w  #2,il_bitplane
                andi.w  #3*2,il_bitplane
no_il:

                lea     colors_plane_effect,A0

                move.w  il_frame(PC),D0
                subq.w  #3,D0           ; adjust frame->color index
                and.w   #3,D0           ; wrap

                mulu    #16*2,D0
                adda.w  D0,A0

                movea.l curr_colorsPtr(PC),A1

                move.l  A1,colors_ptr.w

*   movem.l (A1),D0-D6/A1
*   movem.l D0-D6/A1,$FFFF8240.w

                move.l  A0,curr_colorsPtr

                rts

curr_colorsPtr: DC.L black

                ENDPART
ilf:            DC.W 0
il_frame:       DC.W 0
il_bitplane:    DC.W 0
;-------------------------------------------------------------------------------


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


;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------


                DATA
black:
zero:           DS.L 16

colors:         >PART
C0              SET $0777
C1              SET $0556       ;   555
C2              SET $0445       ;    444
C3              SET $0224       ;224    334

                DC.W $0000      ;p....       0
                DC.W C0         ;p0...       1
                DC.W C1         ;p.1..       2
                DC.W C0         ;p01..       3
                DC.W C2         ;p..2.       4
                DC.W C0         ;p0.2.       5
                DC.W C1         ;p.12.       6
                DC.W C0         ;p012.       7
                DC.W C3         ;p...3       8
                DC.W C0         ;p0..3       9
                DC.W C1         ;p.1.3      10
                DC.W C0         ;p01.3      11
                DC.W C2         ;p..23      12
                DC.W C0         ;p0.23      13
                DC.W C1         ;p.123      14
                DC.W C0         ;p0123      15
                ENDPART

colors_:        >PART
C0              SET $0777
C1              SET $0556       ;   555
C2              SET $0445       ;    444
C3              SET $0224       ;224    334

                DC.W $0000      ;p....       0
                DC.W C0         ;p0...       1
                DC.W C1         ;p.1..       2
                DC.W C0         ;p01..       3
                DC.W C2         ;p..2.       4
                DC.W C0         ;p0.2.       5
                DC.W C1         ;p.12.       6
                DC.W C0         ;p012.       7
                DC.W C3         ;p...3       8
                DC.W C0         ;p0..3       9
                DC.W C1         ;p.1.3      10
                DC.W C0         ;p01.3      11
                DC.W C2         ;p..23      12
                DC.W C0         ;p0.23      13
                DC.W C1         ;p.123      14
                DC.W C0         ;p0123      15
                ENDPART


screen0:        DC.L 0
screen1:        DC.L 0


result:         DS.W MAX_DOTS*2


c_sobj:         DC.L 0
                DC.L c_spline_object1

e_sobj:         DC.L 0
                DC.L e_spline_object1

h_sobj:         DC.L 0
                DC.L h_spline_object1

i_sobj:         DC.L 0
                DC.L i_spline_object1

k_sobj:         DC.L 0
                DC.L k_spline_object1

n_sobj:         DC.L 0
                DC.L n_spline_object1

o_sobj:         DC.L 0
                DC.L o_spline_object1

p_sobj:         DC.L 0
                DC.L p_spline_object1

t_sobj:         DC.L 0
                DC.L t_spline_object1


u_sobj:         DC.L 0
                DC.L u_spline_object1
d_sobj:         DC.L 0
                DC.L d_spline_object1
r_sobj:         DC.L 0
                DC.L r_spline_object1
m_sobj:         DC.L 0
                DC.L m_spline_object1


                PATH 'C:\0NEW\TDOME\'
                PATH 'SPLINES\DATA.NEW\'

c_spline_object1:IBYTES 'C.CTP'
e_spline_object1:IBYTES 'E.CTP'
h_spline_object1:IBYTES 'H.CTP'
i_spline_object1:IBYTES 'I.CTP'
k_spline_object1:IBYTES 'K.CTP'
n_spline_object1:IBYTES 'N.CTP'
o_spline_object1:IBYTES 'O.CTP'
p_spline_object1:IBYTES 'P.CTP'
t_spline_object1:IBYTES 'T.CTP'

u_spline_object1:IBYTES '_U.CTP'
d_spline_object1:IBYTES '_D.CTP'
r_spline_object1:IBYTES '_R2.CTP'
m_spline_object1:IBYTES '_M.CTP'

                IFNE TEST
;-------------------------------------------------------------------------------
VQ_PLAYER:
                PATH 'C:\0NEW\TDOME\0VQSPL.ST\'
                IBYTES 'VQAUDIO.PRG'
                EVEN
;-------------------------------------------------------------------------------
                ENDC


                BSS

BSS_START:      DS.B 2

x_result_buffer:DS.W CONTROL_POINTS_MAX*STEPS
y_result_buffer:DS.W CONTROL_POINTS_MAX*STEPS

sobj_converted: DS.W 2*MAX_DOTS

ipol_current:   DS.L 2*MAX_DOTS

dot_pre:        DS.B 1024


C_pre:
                DS.B 1024
H_pre:
                DS.B 1024
E_pre:
                DS.B 1024
K_pre:
                DS.B 1024
P_pre:
                DS.B 1024
O_pre:
                DS.B 1024
I_pre:
                DS.B 1024
N_pre:
                DS.B 1024
T_pre:
                DS.B 1024

U_pre:
                DS.B 1024

D_pre:
                DS.B 1024
R_pre:
                DS.B 1024
M_pre:
                DS.B 1024


temp:           DS.W 1000


colors_plane_effect:DS.W 4*16

linecode:       DS.B $0E00
linecode2:      DS.B $1100

precalc_ipol_data:
; 200 vertices
;  12 stages
;  16 bytes/array
                DS.B 200*12*16


                DS.B 1024       ; stack!!
y_field:        DS.B 200*40     ; 320x200, 1 plane

;----------------------------------------------------

                DS.B 256
scr_ram:
                DS.B 32000
                DS.B 32000

BSS_END:        DS.B 2

                IFNE TEST
                DS.B 512
stack:          DS.B 2
                ENDC

                END
E:
                END



black:
zero:           DS.L 16
                END
