;-------------------------------------------------------------------------------
TEST            EQU 0
                OUTPUT 'TRNTBL.PRG'
;-------------------------------------------------------------------------------
;
; Vinyl Player
;
; 3d-design: Exocet
; code:      lsl
;
;
;-------------------------------------------------------------------------------
SIN_MASK        EQU $00000FFE   ; 2048*2-2
COS             EQU $00000400   ; 2048/4*2
PI2             EQU 2048*2
;-------------------------------------------------------------------------------
CRAM_X          EQU 256+256     ; width of chunkybuffer
;-------------------------------------------------------------------------------
; linerout
cram_x          EQU CRAM_X      ;y Offset
cr_max_x        EQU 160         ;MAX X
cr_max_y        EQU 100         ;MAX Y
;-------------------------------------------------------------------------------
Z_NULL_PROJZ    SET 500
;-------------------------------------------------------------------------------
;;;;;;;##### triangle texture mapping routine ...
; A1 A2 A3  points
; struct point { short y; short x; short u; short v; }
                RSSET 0
y:              RS.W 1
x:              RS.W 1
u:              RS.W 1
v:              RS.W 1
;-------------------------------------------------------------------------------
; Fast byte-based C2P using only a 32KB table
; (w)20xx/2014 lsl/checkpoint
;-------------------------------------------------------------------------------
CHB             EQU $00000006   ; base value of chunky
C2P_TABLE       EQU $00000606   ; c2p table
;-------------------------------------------------------------------------------
; chunky_value = color*8 + CHB
;-------------------------------------------------------------------------------
                OPT D+
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
                >PART ' sys-struct '

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

total_time:     RS.L 1

music_hz:       RS.L 1

struct_end:     RS.L 0
                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
start:
                move.l  A0,sintab_adr

                OPT D-
                IFNE TEST
                OPT D+
                >PART ' init '
                clr.l   -(SP)
                move.w  #$0020,-(SP)
                trap    #1
                lea     stack,SP
                move    #$2700,SR
                clr.l   $FFFFFA06.w
                clr.l   $FFFFFA12.w
                bclr    #3,$FFFFFA17.w  ; auto eoi

                lea     vbl_slot_first.w,A0
clr0:
                clr.l   (A0)+
                cmpa.l  #struct_end,A0
                ble.s   clr0

                move.l  #69,music_hz.w

                move.l  #vbl,$00000070.w
                move    #$2300,SR
                bsr     wait_vbl
                clr.b   $FFFF8260.w
                move.b  #2,$FFFF820A.w
                ENDPART
                ENDC

                IFNE TEST
                jsr     save_mfp
                jsr     DRIVER_INC
                ENDC


                bsr     wait_vbl

                lea     black,A0
                movem.l (A0),D0-D7
                movem.l D0-D7,$FFFF8240.w

                lea     BSS_START,A0
                lea     BSS_END,A1
                jsr     memclr_a0_a1

                move.l  #screen_ram,D0
                clr.b   D0
                lea     screen0(PC),A0
                move.l  D0,(A0)+
                add.l   #32000,D0
                move.l  D0,(A0)+
                lsr.w   #8,D0
                move.l  D0,$FFFF8200.w

                bsr     wait_vbl

                IFNE TEST
                jsr     save_memory
                ENDC

                move.l  #zero_base,D0
                clr.w   D0
                move.l  D0,player_tex_adr

                add.l   #256*256,D0     ; texture
                add.l   #256*256,D0     ; 2nd half
                move.l  D0,label_tex_adr

;------------------------------------------------------------

                IFNE TEST
                bsr     init_sintab
                ENDC

                bsr     init_cuvx_rout_table


**  jsr     instr_cycle     ********************


                lea     player_tex_inc,A0
                movem.l (A0),D0-D6/A0
*   movem.l D0-D6/A0,$FFFF8240.w
                movem.l D0-D6/A0,colors

                lea     player_st3,A0   ; ST3
                lea     object0,A1      ; OUTPUT
                bsr     init_st3
                bsr     init_object

                lea     arm_st3,A0      ; ST3
                lea     object1,A1      ; OUTPUT
                bsr     init_st3
                bsr     init_object

                lea     label_st3,A0    ; ST3
                lea     object2,A1      ; OUTPUT
                bsr     init_st3
                bsr     init_object


                bsr     init_z_mul_tab


                jsr     init_c2p

                bsr     init_texturemapper

                bsr     clr_colorram

; multi-vbl effect template
; init
                bsr     wait_vbl
                bsr     swap_screens    ; SWAP SCREENS!!!
                move.l  #vbl_script,vbl_slot_first.w ; first executed vbl slot

                move.l  #vbl_effect,vbl_slot0.w

*     move.l  #sucker,vbl_slot0.w

                bsr     wait_vbl

                IFEQ TEST
                rts
                ENDC
;-------------------------------------------------------------------------------
loop:
                bsr     wait_vbl
;-----------------------------------------------------

*    bsr     vbl_effect


                move.b  $FFFFFC02.w,D0
                cmp.b   #$39,D0
                bne     loop
                bra     e
                DC.L $4AFC4E71
                bra     loop

sucker:
                move.w  #5*313,D0
sw:
                DS.W 128-3,$00004E71
                dbra    D0,sw
                rts


label_only_flag:DC.B 0          ; $FF
oldk:           DC.B 0
                EVEN


sintab_adr:     DC.L 0


vbl_effect:     >PART
; ---- CALL EFFECT ROUTINES HERE ----

                move.b  EFFECT_DONE_FLAG.w,D0
                bne.s   no_eff

                bsr     effect_main

*    bsr.s   frame_sync
                bsr     swap_screens
no_eff:
                rts


vbl_sync:       DC.L 5
frame_sync:
                move.l  vbl_sync(PC),D0
                subq.l  #1,D0
vsync:
                cmp.l   $00000466.w,D0
                bgt.s   vsync
                rts
                ENDPART

vbl_script:     >PART

*  addi.w  #$0111,$FFFF8240.w


                bsr     script_rout
                bsr     inc_w
                rts

                ENDPART

effect_main:    >PART

                bsr     setup_matrix_normal

                move.w  #$7FFF,2+ymin_check
                move.w  #-$7FFF,2+ymax_check

                RSSET 0
PLAYER:         RS.B 1
LABEL:          RS.B 1
ARM:            RS.B 1

;-------------------------------------------------------
                move.b  label_only_flag(PC),D0
                bne.s   label_only0

                movea.l player_tex_adr(PC),A0
                bsr     set_texture

                lea     player_st3,A0
                lea     object0,A1
                lea     pivot_player,A2
                move.w  #PLAYER,object_current
                bsr     render_object
label_only0:
;-------------------------------------------------------
                movea.l label_tex_adr(PC),A0
                bsr     set_texture

                lea     label_st3,A0
                lea     object2,A1
                lea     pivot_label,A2
                move.w  #LABEL,object_current
                bsr     render_object
;-------------------------------------------------------
                move.b  label_only_flag(PC),D0
                bne.s   label_only1

                movea.l player_tex_adr(PC),A0
                bsr     set_texture

                lea     arm_st3,A0
                lea     object1,A1
                lea     pivot_arm,A2
                move.w  #ARM,object_current
                bsr     render_object
label_only1:
;-------------------------------------------------------
                bsr     c2p_buffer
                bsr     clr_colorram
;-------------------------------------------------------
                rts
                ENDPART

sin_modulated_speed:
                movea.l sintab_adr,A0
                adda.w  w0,A0
                move.w  (A0),D0
                muls    #40*4,D0
                swap    D0
                add.w   #69,D0
                ext.l   D0
                move.l  D0,music_hz.w
                rts

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
script_rout:    >PART

;     DC.L $4AFC4E71

                move.l  fade_sub(PC),D0
                beq.s   *+4
                movea.l D0,A0
                jsr     (A0)

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

                move.l  interpolate_linear_sub(PC),D0
                beq.s   *+4
                movea.l D0,A0
                jsr     (A0)

                addq.l  #1,t

                subq.l  #1,script_delay
                bpl.s   sr_wait
script_loop:
                clr.b   script_exe_more_flag
                moveq   #0,D0
                movea.l script_pos(PC),A0
                movea.l (A0)+,A1
                jsr     (A1)
                move.b  script_exe_more_flag(PC),D0
                bne.s   script_loop
sr_wait:
                rts

script_pos:     DC.L script
script_delay:   DC.L 0
t:              DC.L 0

fade_sub:       DC.L 0

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
script_exe_more_flag:DC.W 0
END_SET_PARAMS  EQU $C001BABE
INTERPOLATE_LINEAR_END EQU $C001BABE
;-------------------------------------
SET_PARAMS_WORD:>PART
spw_loop:
                movem.l (A0)+,D0/A1
                move.w  D0,(A1)
                cmpi.l  #END_SET_PARAMS,(A0)
                bne.s   spw_loop
                addq.l  #4,A0
                move.l  A0,script_pos
                st      script_exe_more_flag
                rts
                ENDPART
;-------------------------------------

IL_BITS         EQU 12
IL_ONE          EQU 4096

interpolate_linear_sub:DC.L 0

INTERPOLATE_LINEAR:PART

*    DC.L $4AFC4E71

                move.l  (A0)+,D0        ; speed
                move.w  D0,ipol_speed

                moveq   #-1,D7          ; amount values
                lea     interpolate_arrayLin,A6
il_setup_loop:
                move.l  (A0)+,D1        ; end value
                movea.l (A0)+,A1        ; valuePtr
                move.w  (A1),D0         ; start value
; .l valuePtr
; .w start value
; .w end value
                move.l  A1,(A6)+        ; valuePtr
                move.w  D0,(A6)+        ; start value
                move.w  D1,(A6)+        ; end value

                addq.w  #1,D7
                cmpi.l  #INTERPOLATE_LINEAR_END,(A0)
                bne.s   il_setup_loop

                addq.l  #4,A0
                move.l  A0,script_pos

                clr.w   ipol_t
                move.w  D7,num_ipols
                move.l  #interpolate_linear,interpolate_linear_sub
                rts
                ENDPART

interpolate_linear:PART

                moveq   #IL_BITS,D5
                move.w  ipol_t,D6
                move.w  num_ipols,D7
                lea     interpolate_arrayLin,A6
ils_l:
                movea.l (A6)+,A0        ; valuePtr
                movem.w (A6)+,D0        ; start value
                movem.w (A6)+,D1        ; end   value
                sub.l   D0,D1           ; end-start
                muls    D6,D1           ; *t

                asl.l   D5,D0
                add.l   D1,D0
                asr.l   D5,D0
                move.w  D0,(A0)         ; *valuePtr
                dbra    D7,ils_l

                add.w   ipol_speed(PC),D6
                cmp.w   #IL_ONE,D6
                ble.s   ilM
                move.w  #IL_ONE,D6
                clr.l   interpolate_linear_sub
ilM:
                move.w  D6,ipol_t
                rts
                ENDPART
wait_ipol:
                move.l  interpolate_linear_sub(PC),D0
                bne.s   wiM
                move.l  A0,script_pos
wiM:
                rts
                ENDPART

ipol_t:         DC.W 0
ipol_speed:     DC.W 0
num_ipols:      DC.W 0

interpolate_arrayLin:>PART
; .l valuePtr
; .w start value
; .w end value
                DS.B 256
                ENDPART

script:         PART

                DC.L SET_PARAMS_WORD

                DC.L 160/2,poly_center_x ;:  DC.W 160/2      ; +80
                DC.L 100/2,poly_center_y ;:  DC.W 100/2      ;  +100  ;         100/2-30   ;  +14

                DC.L 30,view_x_lt ;:      DC.W 0          ;28
                DC.L 36,view_y_lt ;:      DC.W 0          ;32+120
                DC.L -200,view_z_lt ;:      DC.W 0          ;  -200       ;150-30     ; -200       ;   -200  150

                DC.L END_SET_PARAMS

                DC.L ST,label_only_flag

                DC.L set_fade_speed,16
                DC.L fade,black,colors
                DC.L wait_fade

                DC.L WAIT,3*50

                DC.L MOVE_W,5,music_sd_speed ; music speed down
                DC.L music_speed_down

                DC.L CLR_B,label_only_flag

                DC.L WAIT,2*50

                DC.L INTERPOLATE_LINEAR
                DC.L IL_ONE/(2*50) ;   speed
                DC.L 0,view_x_lt ;:      DC.W 0          ;28
                DC.L 60,view_y_lt ;:      DC.W 0          ;32+120
                DC.L 150,view_z_lt ;:      DC.W 0          ;  -200       ;150-30     ; -200       ;   -200  150
                DC.L -60*PI2/360,xr
                DC.L 23*PI2/360,yr
                DC.L INTERPOLATE_LINEAR_END

                DC.L wait_ipol

                DC.L MOVE_W,4,music_sd_speed
                DC.L MOVE_L,music_speedup_sub,script_sub2 ; music speed up

                DC.L INTERPOLATE_LINEAR
                DC.L IL_ONE/(1*50) ;   speed
                DC.L 0,view_x_lt ;:      DC.W 0          ;28
                DC.L 60,view_y_lt ;:      DC.W 0          ;32+120
                DC.L 100,view_z_lt ;:      DC.W 0          ;  -200       ;150-30     ; -200       ;   -200  150
                DC.L -40*PI2/360,xr
                DC.L -32*PI2/360,yr
                DC.L INTERPOLATE_LINEAR_END
                DC.L wait_ipol

                DC.L INTERPOLATE_LINEAR
                DC.L IL_ONE/(2*50) ;   speed
                DC.L 40,view_x_lt ;:      DC.W 0          ;28
                DC.L 60+30,view_y_lt ;:      DC.W 0          ;32+120
                DC.L 50,view_z_lt ;:      DC.W 0          ;  -200       ;150-30     ; -200       ;   -200  150
                DC.L -20*PI2/360,xr
                DC.L 38*PI2/360,yr
                DC.L INTERPOLATE_LINEAR_END
                DC.L wait_ipol

                DC.L INTERPOLATE_LINEAR
                DC.L IL_ONE/(1*50) ;   speed
                DC.L -52,view_x_lt ;:      DC.W 0          ;28
                DC.L 60-40,view_y_lt ;:      DC.W 0          ;32+120
                DC.L 50,view_z_lt ;:      DC.W 0          ;  -200       ;150-30     ; -200       ;   -200  150
                DC.L 0*PI2/360,xr
                DC.L -38*PI2/360,yr
                DC.L -52*PI2/360,zr
                DC.L INTERPOLATE_LINEAR_END
                DC.L wait_ipol

                DC.L INTERPOLATE_LINEAR
                DC.L IL_ONE/(1*50) ;   speed
                DC.L 10,view_x_lt ;:      DC.W 0          ;28
                DC.L 60,view_y_lt ;:      DC.W 0          ;32+120
                DC.L 70,view_z_lt ;:      DC.W 0          ;  -200       ;150-30     ; -200       ;   -200  150
                DC.L -70*PI2/360,xr
                DC.L 0*PI2/360,yr
                DC.L 0*PI2/360,zr
                DC.L INTERPOLATE_LINEAR_END
                DC.L wait_ipol

                DC.L WAIT,30

                DC.L get_angles_temp
                DC.L MOVE_L,angle_incs_sub,script_sub0

                DC.L WAIT,6*50

                DC.L MOVE_L,camera_out_sub,script_sub1

                DC.L WAIT,1*50

*  DC.L GOTO,nozout
Q:

                DC.L INTERPOLATE_LINEAR
                DC.L IL_ONE/(20) ;   speed
*  DC.L 10,view_x_lt ;:      DC.W 0          ;28
*  DC.L 60,view_y_lt ;:      DC.W 0          ;32+120
                DC.L -180,view_z_lt ;:      DC.W 0          ;  -200       ;150-30     ; -200       ;   -200  150
; -180
                DC.L INTERPOLATE_LINEAR_END

nozout:

*  DC.L CLR_L,script_sub0

                DC.L set_fade_speed,4
                DC.L fade,colors,white
                DC.L wait_fade

                DC.L set_fade_speed,1
                DC.L fade,white,black
                DC.L wait_fade

                DC.L ST,a
                DC.L ST,EFFECT_DONE_FLAG

                DC.L HALT

cot_t:          DC.W 256

camera_out_sub:

* move.w  #176,D7

                lea     cot_t(PC),A1
                move.w  (A1),D7
                movem.w camera_x,D0-D2
                muls    D7,D0
                muls    D7,D1
                muls    D7,D2
                asr.l   #8,D0
                asr.l   #8,D1
                asr.l   #8,D2
                movem.w D0-D2,camera_x

                subi.w  #8,(A1)         ; 5
                bpl.s   cos_m
                clr.w   (A1)
cos_m:
                rts

get_angles_temp:>PART
                move.w  xr,xrT
                move.w  yr,yrT
                move.w  zr,zrT
                move.l  A0,script_pos
                rts
                ENDPART

xrT:            DC.W 0
yrT:            DC.W 0
zrT:            DC.W 0

xrA:            DC.W 0
yrA:            DC.W 0
zrA:            DC.W 0

ait:            DC.W 0

precalc_frame:  DC.W 0
pf_wrap:        DC.W 0

pf_xr_speed:    DC.W 16
pf_yr_speed:    DC.W 32
pf_zr_speed:    DC.W 16

cam_x_speed:    DC.W 20
cam_y_speed:    DC.W 22

angle_incs_sub: >PART

                move.w  precalc_frame(PC),D0
                move.w  D0,pf_wrap

                movea.l sintab_adr,A0
                move.w  pf_wrap(PC),D0
                mulu    pf_xr_speed(PC),D0
                and.w   #SIN_MASK,D0
                move.w  0(A0,D0.w),D0
                muls    #200*4,D0
                swap    D0
                add.w   #-1*700*PI2/3600,D0
                and.w   #SIN_MASK,D0
                move.w  D0,xrA

                movea.l sintab_adr,A0
                move.w  pf_wrap(PC),D0
                mulu    pf_yr_speed(PC),D0
                and.w   #SIN_MASK,D0
                move.w  0(A0,D0.w),D0
                muls    #400*4,D0
                swap    D0
                and.w   #SIN_MASK,D0
                move.w  D0,yrA

                movea.l sintab_adr,A0
                move.w  pf_wrap(PC),D0
                mulu    pf_zr_speed(PC),D0
                and.w   #SIN_MASK,D0
                move.w  0(A0,D0.w),D0
                muls    #400*4,D0
                swap    D0
                and.w   #SIN_MASK,D0
                move.w  D0,zrA


                movea.l sintab_adr,A0
                move.w  pf_wrap(PC),D0
                mulu    cam_x_speed(PC),D0
                and.w   #SIN_MASK,D0
                move.w  0(A0,D0.w),D0
                muls    #400*4,D0
                swap    D0
                move.w  D0,camera_x

                movea.l sintab_adr,A0
                move.w  pf_wrap(PC),D0
                mulu    cam_y_speed(PC),D0
                and.w   #SIN_MASK,D0
                move.w  0(A0,D0.w),D0
                muls    #300*4,D0
                swap    D0
                move.w  D0,camera_y


                addq.w  #1,precalc_frame

                move.w  ait(PC),D7

                lea     xrT,A0
                lea     xrA,A1
                lea     xr,A2
*  bsr     interpolate

                lea     yrT,A0
                lea     yrA,A1
                lea     yr,A2
*  bsr     interpolate

                lea     zrT,A0
                lea     zrA,A1
                lea     zr,A2
*  bsr     interpolate

*   bra     ki

                move.w  xrA,xr
                move.w  yrA,yr
                move.w  zrA,zr
ki:
                lea     ait(PC),A0
                addi.w  #4096/(4*50),(A0)
                cmpi.w  #4096,(A0)
                ble.s   aitM
                move.w  #4096,(A0)
aitM:
                rts
                ENDPART

; A0--A1, A2.output   D7.t
interpolate:    >PART

                moveq   #12,D6
                movem.w (A0),D0         ; start
                movem.w (A1),D1         ; end

*    move.w  D1,(A2)
*    rts

                move.w  #4096,D5
                sub.w   D7,D5
                muls    D5,D0
                muls    D7,D1
                add.l   D1,D0
                asr.l   D6,D0
                move.w  D0,(A2)
                rts


                sub.w   D0,D1
                muls    D7,D1
                asl.l   D6,D0
                add.l   D1,D0
                asr.l   D6,D0
                move.w  D0,(A2)
                rts
                ENDPART

a:              DC.L 0

music_sd_speed: DC.W 0
music_sd_cnt:   DC.W 0
music_speed_down:>PART
                subq.w  #1,music_sd_cnt
                bpl.s   msd_ny
                move.w  music_sd_speed(PC),music_sd_cnt

                move.l  music_hz.w,D0
                subq.l  #1,D0
                cmp.l   #15,D0
                bge.s   msd_more
                move.l  A0,script_pos
                rts
msd_more:
                move.l  D0,music_hz.w
msd_ny:
                rts
                ENDPART

music_speedup_sub:
                subq.w  #1,music_sd_cnt
                bpl.s   msd_ny2
                move.w  music_sd_speed(PC),music_sd_cnt

                move.l  music_hz.w,D0
                addq.l  #1,D0
                cmp.l   #76,D0
                ble.s   msd_more2
                clr.l   script_sub2
                rts
msd_more2:
                move.l  D0,music_hz.w
msd_ny2:
                rts
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
                move.l  #fade_sub_rout,fade_sub
                rts
                ENDPART
fade_sub_rout:  >PART
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
*   move.l  A0,script_pos
                clr.l   fade_sub
wfn:
                rts
                ENDPART
wait_fade:      >PART
                move.l  fade_sub(PC),D0
                bne.s   wfm
                move.l  A0,script_pos
wfm:
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
;-------------------------------------------------------------------------------

e:              PART
                move    #$2700,SR
                clr.l   $FFFFFA06.w
                clr.l   $FFFFFA12.w
                move.w  #$0700,$FFFF8240.w
                IFNE TEST
                move.l  #rte,$00000070.w
                move.l  #rte,$00000114.w
                jsr     restore_memory
                jsr     restore_mfp
                ENDC
                move.w  #$0070,$FFFF8240.w
                DC.L $4AFC4E71
                DC.L $4AFC4E71
                DC.L $4AFC4E71
                ENDPART

pivot_player:
                DC.W 0
                DC.W 0
                DC.W 0
pivot_label:
plx:            DC.W $FF8D      ;     (-247+29)/2
ply:            DC.W $FF74      ; (-288+-12)/2
                DC.W 0
pivot_arm:
                DC.W (198+445)/2+10
                DC.W (-520+142)/2-165
                DC.W 0


set_texture:    >PART

                move.l  A0,D0
                swap    D0
                move.w  D0,2+tex_adr0
                move.w  D0,2+tex_adr1
                rts
                ENDPART

object_current: DC.W 0

current_st3:    DC.L 0
current_obj:    DC.L 0

; A0.object (ST3)
render_object:  >PART
                movem.l A0-A1,current_st3
                move.w  (A2)+,pivot_point_x
                move.w  (A2)+,pivot_point_y
                move.w  (A2)+,pivot_point_z

                bsr     load_object_to_engine

                bsr     transform_vertices

                bsr     display_texmapped_OPTI

                rts
                ENDPART


c2p_buffer:     >PART

                bsr     output_colorram_sht_YCK

                bsr     double_screen

                rts
                ENDPART



test_texture_mapper:>PART

                lea     ttm_vts,A0
                lea     ttm_uv,A1

                lea     vertex0,A2
                bsr     ttm_copy_vertex
                lea     vertex1,A2
                bsr     ttm_copy_vertex
                lea     vertex2,A2
                bsr     ttm_copy_vertex
                lea     vertex3,A2
                bsr     ttm_copy_vertex

                lea     vertex0,A1
                lea     vertex1,A2
                lea     vertex2,A3
                bsr     TRI_MAP

                lea     vertex2,A1
                lea     vertex3,A2
                lea     vertex0,A3
                bsr     TRI_MAP

                rts
ttm_copy_vertex:
                move.l  (A0)+,D0
                swap    D0              ; y,x
                move.l  D0,(A2)+
                move.l  (A1)+,(A2)+     ; u,v
                rts

;y:              RS.W 1
;x:              RS.W 1
;u:              RS.W 1
;v:              RS.W 1

ttm_vts:
                DC.W 0,0
                DC.W 99,0
                DC.W 99,99
                DC.W 0,99
ttm_uv:
                DC.W 0,0
                DC.W 255,0
                DC.W 255,255
                DC.W 0,255
                ENDPART

x0:             DC.W 0
y0:             DC.W 0
x1:             DC.W 159
y1:             DC.W 99
x2:             DC.W 0
y2:             DC.W 0

;-------------------------------------------------------------------------------
inc_w:          PART

; current_music_hz:   69

                move.l  music_hz.w,D7

                move.l  zr_arm_inc(PC),D0
                muls    D7,D0           ; music_hz
                divs    #69,D0
                ext.l   D0
                add.l   D0,zr_arm

                move.l  zr_label_inc(PC),D0
                asr.l   #8,D0
                muls    D7,D0           ; music_hz
                divs    #69,D0
                ext.l   D0
                asl.l   #8,D0
                add.l   D0,zr_label

                moveq   #7-1,D0
                lea     xr(PC),A0
                lea     xr_inc(PC),A1
iwl:
                move.w  (A0),D1
                add.w   (A1)+,D1
** and.w   #SIN_MASK,D1
                move.w  D1,(A0)+
                dbra    D0,iwl
                rts
                ENDPART

zr_arm:         DC.L -$00F00000
zr_arm_inc:     DC.L -8*65536/50/4

zr_label:       DC.L 0
zr_label_inc:   DC.L -$00100000

                PART 'angles'

xr:             DC.W 0          ;  -1*900*PI2/3600 ;  PI2/4
yr:             DC.W 0          ;   PI2/6
zr:             DC.W 0

w0:             DC.W 0
w1:             DC.W 0
w2:             DC.W 0
w3:             DC.W 0
;------------------------------------------
xr_inc:         DC.W 32*2*0
yr_inc:         DC.W 16*2*0
zr_inc:         DC.W 32*2*0

w0_inc:         DC.W 1*2
w1_inc:         DC.W 64*2       ;  +8*2
w2_inc:         DC.W 0
w3_inc:         DC.W 0
                ENDPART
;-------------------------------------------------------------------------------
swap_screens:   >PART
                move.l  screen1(PC),D0
                move.l  screen0(PC),screen1
                move.l  D0,screen0
                lsr.w   #8,D0
                move.l  D0,$FFFF8200.w
                rts


                ENDPART
vbl:            PART

                movem.l D0-A6,-(SP)

                move.l  vbl_slot_first.w,D0 ; first executed vbl slot
                beq.s   *+4
                movea.l D0,A0
                jsr     (A0)

                movem.l (SP)+,D0-A6

                addq.l  #1,$00000466.w
                rte
                ENDPART
wait_vbl:       >PART
                clr.l   $00000466.w
wv:
                tst.l   $00000466.w
                beq.s   wv
                rts
                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------


;-------------------------------------------------------------------------------
clr_colorram:   PART

                move.l  SP,cc_sp+2

                lea     colorram,SP
o               SET 100*CRAM_X
o               SET o-(CRAM_X-160)
                adda.l  #o,SP

                movem.l clr_colorram_cols(PC),D0-A6 ; 15*4 = 60

;160/60 = 2, rest 40
                REPT 100
                movem.l D0-A6,-(SP)
                movem.l D0-A6,-(SP)
                movem.l D0-A1,-(SP)
o               SET -(CRAM_X-160)
                lea     o(SP),SP
                ENDR
cc_sp:          lea     0,SP
                rts
                ENDPART
clr_colorram_cols:>PART
                REPT 64
                DC.B 0*8+CHB
                DC.B 0*8+CHB
                DC.B 0*8+CHB
                DC.B 0*8+CHB
                ENDR
                ENDPART
;-------------------------------------------------------------------------------
; D0...start
; D1...length
clear_lines_screen:>PART

                movea.l screen1(PC),A6
                move.w  D0,D2           ; start
                add.w   D1,D2           ; end

                addq.w  #1,D2           ; pre-decrement fix
                mulu    #2*160,D2
                adda.l  D2,A6

                neg.w   D1
                add.w   #100-1,D1
                mulu    #cls_size,D1
                add.l   #cls_s,D1
                move.l  D1,2+cls_start_jmp

                movem.l zero(PC),D0-A5  ; 14*4 = 56
; 2*160 = 320
; 320/56 = 5, rest 40

cls_start_jmp:  jmp     0

cls_s:
                REPT 100
                movem.l D0-A5,-(A6)
                movem.l D0-A5,-(A6)
                movem.l D0-A5,-(A6)
                movem.l D0-A5,-(A6)
                movem.l D0-A5,-(A6)
                movem.l D0-A1,-(A6)
                ENDR
cls_e:
cls_size        SET (cls_e-cls_s)/100
                rts

                ENDPART
;-------------------------------------------------------------------------------
output_colorram_sht_YCK:PART

*    DC.L $4AFC4E71

                moveq   #0,D0
                move.w  y_min(PC),D1
                bmi     no_oc
                subq.w  #1,D1
                bmi.s   ntop_clr
                addq.w  #1,D1
                bsr     clear_lines_screen
ntop_clr:
                move.w  y_max(PC),D0
                move.w  #100-1,D1
                sub.w   D0,D1
                bmi.s   nbot_clr
                bsr     clear_lines_screen
nbot_clr:

                move.l  SP,oc_sp4+2

                movem.w y_min(PC),D0-D1
                sub.w   D0,D1
                move.w  D1,D7           ; length

                movea.l screen1(PC),A6
                lea     colorram,SP

                move.w  D0,D1
                mulu    #2*160,D0
                mulu    #CRAM_X,D1
                adda.l  D0,A6
                adda.l  D1,SP

                move    A6,USP
;;  moveq   #100-1,D7
oc_y4:

xo              SET 0
xi              SET 1

; render 56 pixel
; 320/56 = 5, rest 40
                REPT 5

                movem.w (SP)+,A0-A6     ;7

                move.l  (A0),D0
                or.l    -(A1),D0

                move.l  (A2),D1
                or.l    -(A3),D1

                move.l  (A4),D2
                or.l    -(A5),D2
;-------------------------------------
                move.l  (A6),D3
                movem.w (SP)+,A0-A6     ;7
                or.l    -(A0),D3

                move.l  (A1),D4
                or.l    -(A2),D4

                move.l  (A3),D5
                or.l    -(A4),D5

                move.l  (A5),D6
                or.l    -(A6),D6


                move    USP,A6          ; screen

                movep.l D0,xo(A6)
xo              SET xo+xi
xi              SET xi^6
                movep.l D1,xo(A6)
xo              SET xo+xi
xi              SET xi^6
                movep.l D2,xo(A6)
xo              SET xo+xi
xi              SET xi^6
                movep.l D3,xo(A6)
xo              SET xo+xi
xi              SET xi^6
                movep.l D4,xo(A6)
xo              SET xo+xi
xi              SET xi^6
                movep.l D5,xo(A6)
xo              SET xo+xi
xi              SET xi^6
                movep.l D6,xo(A6)
xo              SET xo+xi
xi              SET xi^6
                ENDR

; render 40 pixel
                movem.w (SP)+,A0-A6     ;7

                move.l  (A0),D0
                or.l    -(A1),D0

                move.l  (A2),D1
                or.l    -(A3),D1

                move.l  (A4),D2
                or.l    -(A5),D2
;-------------------------------------
                move.l  (A6),D3
                movem.w (SP)+,A0-A2
                or.l    -(A0),D3

                move.l  (A1),D4
                or.l    -(A2),D4

                move    USP,A6          ; screen

                movep.l D0,xo(A6)
xo              SET xo+xi
xi              SET xi^6
                movep.l D1,xo(A6)
xo              SET xo+xi
xi              SET xi^6
                movep.l D2,xo(A6)
xo              SET xo+xi
xi              SET xi^6
                movep.l D3,xo(A6)
xo              SET xo+xi
xi              SET xi^6
                movep.l D4,xo(A6)
xo              SET xo+xi
xi              SET xi^6

                lea     CRAM_X-160(SP),SP
                lea     2*160(A6),A6
                move    A6,USP
                dbra    D7,oc_y4

no_oc:
oc_sp4:         lea     0,SP
                rts

                ENDPART
;-------------------------------------------------------------------------------
double_screen:  >PART

*   DC.L $4AFC4E71

                move.w  y_min(PC),D0
                bmi     no_ds
                move.w  y_max(PC),D1

                movea.l screen1(PC),A6

                sub.w   D0,D1
                neg.w   D1
                add.w   #100-1,D1
                mulu    #ds_size,D1

                mulu    #2*160,D0
                adda.l  D0,A6
                jmp     ds_s(PC,D1.w)
ds_s:
                REPT 100
                movem.l (A6)+,D0-A5     ;14*4 = 56
                movem.l D0-A5,-56+160(A6)
                movem.l (A6)+,D0-A5     ;14*4 = 56
                movem.l D0-A5,-56+160(A6)
                movem.l (A6)+,D0-A3     ;12*4 = 48
                movem.l D0-A3,-48+160(A6)
                lea     160(A6),A6
                ENDR
ds_e:
ds_size         SET (ds_e-ds_s)/100

no_ds:
                rts
                ENDPART
;-------------------------------------------------------------------------------


;-------------------------------------------------------------------------------

st3_init_object_ptr:DC.L 0


; A0...object
init_st3:       PART

                movem.l D0-D6/A0-A3,-(SP)

                move.l  A0,st3_init_object_ptr



                bsr.s   load_object_to_engine

                bsr.s   ist3_scale_vertices

                movem.l (SP)+,D0-D6/A0-A3
                rts
                ENDPART

; A0.object (ST3)
load_object_to_engine:>PART

*    DC.L $4AFC4E71

; vertices
                move.l  (A0)+,D0        ; id  VERT
                move.w  (A0)+,D0
                move.w  D0,vertices_amount
                move.l  A0,vertices_ptr
                mulu    #3*2,D0
                adda.l  D0,A0

; vertices-texture
                move.l  (A0)+,D0        ; id  VTEX
                move.w  (A0)+,D0
                move.w  D0,vert_tex_amount
                move.l  A0,vert_tex_ptr
                mulu    #2*2,D0
                adda.l  D0,A0

; faces
                move.l  (A0)+,D0        ; id  FACES
                move.w  (A0)+,D0
                move.w  D0,faces_amount
                move.l  A0,faces_ptr
                mulu    #6*2,D0
                adda.l  D0,A0
                rts
                ENDPART

xr_init:        DC.W 900*PI2/3600
zr_init:        DC.W 1800*PI2/3600

trans_x_init:   DC.W 0
trans_y_init:   DC.W -150

ist3_scale_vertices:PART

                move.w  #160,D5

                movea.l sintab_adr,A6
                move.w  xr_init(PC),D0
                and.w   #SIN_MASK,D0
                adda.w  D0,A6
                move.w  (A6),xri_sin
                move.w  COS(A6),xri_cos

                movea.l sintab_adr,A6
                move.w  zr_init(PC),D0
                and.w   #SIN_MASK,D0
                adda.w  D0,A6
                move.w  (A6),zri_sin
                move.w  COS(A6),zri_cos

                move.w  #$7FFF,xmin
                move.w  #-$7FFF,xmax

                move.w  #$7FFF,ymin
                move.w  #-$7FFF,ymax

                move.w  #$7FFF,zmin
                move.w  #-$7FFF,zmax

                move.w  vertices_amount,D6
                subq.w  #1,D6
                movea.l vertices_ptr,A0
isv:
                movem.w (A0),D0-D2
                muls    D5,D0
                muls    D5,D1
                muls    D5,D2
                asr.l   #8,D0
                asr.l   #8,D1
                asr.l   #8,D2

*    neg.w   D1              ;-y

; x axxis
                move.w  D1,D3           ; y
                move.w  D2,D4           ; z

                muls    xri_cos(PC),D1
                muls    xri_sin(PC),D4
                add.l   D4,D1
                asl.l   #2,D1
                swap    D1

                muls    xri_cos(PC),D2
                muls    xri_sin(PC),D3
                sub.l   D3,D2
                asl.l   #2,D2
                swap    D2
; z axxis
                move.w  D0,D3           ; y
                move.w  D1,D4           ; z

                muls    zri_cos(PC),D0
                muls    zri_sin(PC),D4
                add.l   D4,D0
                asl.l   #2,D0
                swap    D0

                muls    zri_cos(PC),D1
                muls    zri_sin(PC),D3
                sub.l   D3,D1
                asl.l   #2,D1
                swap    D1

                add.w   trans_x_init(PC),D0
                add.w   trans_y_init(PC),D1


                lea     xmin(PC),A6
                cmp.w   (A6),D0
                bge.s   *+2
                move.w  D0,(A6)

                lea     xmax(PC),A6
                cmp.w   (A6),D0
                ble.s   *+2
                move.w  D0,(A6)


                lea     ymin(PC),A6
                cmp.w   (A6),D1
                bge.s   *+2
                move.w  D1,(A6)

                lea     ymax(PC),A6
                cmp.w   (A6),D1
                ble.s   *+2
                move.w  D1,(A6)


                lea     zmin(PC),A6
                cmp.w   (A6),D2
                bge.s   *+2
                move.w  D2,(A6)

                lea     zmax(PC),A6
                cmp.w   (A6),D2
                ble.s   *+2
                move.w  D2,(A6)

                movem.w D0-D2,(A0)
                addq.l  #6,A0
                dbra    D6,isv

                cmpi.l  #arm_st3,st3_init_object_ptr
                bne.s   nomindisp

*     DC.L $4AFC4E71

                movem.w xmin,D0-D1
                movem.w ymin,D0-D1
                movem.w zmin,D0-D1
nomindisp:
                rts

xmin:           DC.W 0
xmax:           DC.W 0
ymin:           DC.W 0
ymax:           DC.W 0
zmin:           DC.W 0
zmax:           DC.W 0


xri_cos:        DC.W 0
xri_sin:        DC.W 0

zri_cos:        DC.W 0
zri_sin:        DC.W 0

                ENDPART



vertices_amount:DC.W 0
vert_tex_amount:DC.W 0
faces_amount:   DC.W 0

vertices_ptr:   DC.L 0
vert_tex_ptr:   DC.L 0
faces_ptr:      DC.L 0


;-------------------------------------------------------------------------------
transform_vertices:>PART

                movea.l vertices_ptr(PC),A0
                lea     _3d_result,A1
                move.w  vertices_amount(PC),D0
                bsr     _3d_calc_points

                rts
                ENDPART
;-------------------------------------------------------------------------------

init_object:    >PART

;;  DC.L $4AFC4E71

*** lea     object0,A1      ; OUTPUT

                move.l  #object0_Z_ptr,D0
                clr.b   D0
                move.l  D0,object0_Z_ptr_adr
                movea.l D0,A2

                movea.l faces_ptr(PC),A0

                lea     _3d_result,A4
                moveq   #-1,D6

                move.w  faces_amount(PC),D7
                subq.w  #1,D7
io_loop:

; Z_ptr fill
                move.w  #'ZZ',(A2)+     ; z.w
                move.l  A1,(A2)+        ; *polygon.l
                move.w  #'cp',(A2)+     ; filler.w
; init vertices
                movea.l vert_tex_ptr(PC),A6

                movem.w (A0)+,D0-D2     ; v0,v1,v2
                moveq   #3*2,D3         ; x,y,z
                mulu    D3,D0
                mulu    D3,D1
                mulu    D3,D2
                add.l   A4,D0           ; _3d_result
                add.l   A4,D1           ; _3d_result
                add.l   A4,D2           ; _3d_result

                movem.w (A0)+,D3-D5     ; vt0,vt1,vt2
                lsl.w   #2,D3
                lsl.w   #2,D4
                lsl.w   #2,D5

                move.l  D0,(A1)+        ;  _3d_result+v0
                move.l  D1,(A1)+        ;  _3d_result+v1
                move.l  D2,(A1)+        ;  _3d_result+v2
; v0
                move.l  D6,(A1)+        ;  y,x
                move.l  0(A6,D3.w),(A1)+ ; u,v
; v1
                move.l  D6,(A1)+        ;  y,x
                move.l  0(A6,D4.w),(A1)+ ; u,v
; v2
                move.l  D6,(A1)+        ;  y,x
                move.l  0(A6,D5.w),(A1)+ ; u,v
;-----------------------------------------------------
                dbra    D7,io_loop

                suba.l  #object0,A1
                suba.l  object0_Z_ptr_adr,A2

                rts
                ENDPART

; .w z_average
; .l polyptr

faces_visible:  DC.W 0



W:
; object0 !!!
display_texmapped_OPTI:>PART

*   DC.L $4AFC4E71

;; lea     object0,A5

                movea.l current_obj(PC),A5

                movea.l object0_Z_ptr_adr,A6 ; OUTPUT

                move.w  faces_amount(PC),D7
                subq.w  #1,D7
dtO_cull_loop:
                movem.l (A5)+,A1-A3     ; _3d_result + v0,v1,v2
;--------------------------------------------------------
; backface culling
                movem.w (A1),D0-D1      ;y0 x0
                movem.w (A2),D2-D3      ;y1 x1
                movem.w (A3),D4-D5      ;y2 x2

                sub.w   D1,D3           ;x1-x0   X0
                sub.w   D0,D2           ;y1-y0   Y0

                sub.w   D1,D5           ;x2-x0   X1
                sub.w   D0,D4           ;y2-y0   Y1

                muls    D3,D4           ; X0*Y1
                muls    D2,D5           ; Y0*X1

                sub.l   D5,D4           ; X0*Y1 - Y0*X1
*   bmi.s   tri_nvis3       ;
                bpl.s   tri_nvis3       ;
; visible
                move.l  A5,D1           ; *polygon

                move.l  (A1)+,(A5)+     ; y,x
                addq.l  #4,A5           ; u,v
                move.l  (A2)+,(A5)+     ; y,x
                addq.l  #4,A5           ; u,v
                move.l  (A3)+,(A5)+     ; y,x
                addq.l  #4,A5           ; u,v

                move.w  (A1)+,D0        ; z
                add.w   (A2)+,D0        ; z
                add.w   (A3)+,D0        ; z
                move.w  D0,(A6)+        ; z_sum
                move.l  D1,(A6)+        ; *polygon
                addq.l  #2,A6           ; filler

                dbra    D7,dtO_cull_loop
                bra.s   cull_done
tri_nvis3:                              ;
                lea     3*4*2(A5),A5    ; y,x,u,v
                dbra    D7,dtO_cull_loop
cull_done:

**  DC.L $4AFC4E71

                move.l  A6,D0
                sub.l   object0_Z_ptr_adr,D0
                lsr.l   #3,D0
                move.w  D0,faces_visible
                beq.s   no_faces

                move.w  D0,anz_sort
                movea.l object0_Z_ptr_adr,A0
                move.l  A0,sort_table_adr
                bsr     sort_pointers

                bsr     output_polygon_list
no_faces:
                rts
                ENDPART

output_polygon_list:>PART

                movea.l object0_Z_ptr_adr,A6
                addq.l  #2,A6           ; skip z

                move.w  faces_visible(PC),D0
                subq.w  #1,D0
                move.w  D0,-(SP)
ocnzs_l:
                pea     8(A6)
                movea.l (A6),A1         ; *polygon
                lea     8(A1),A2
                lea     8(A2),A3
                bsr     TRI_MAP
                movea.l (SP)+,A6
                subq.w  #1,(SP)
                bpl.s   ocnzs_l
                addq.l  #2,SP
                rts

                ENDPART

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
; Pointer-arithmetics Quicksort
; stack-usage: app. 256 bytes
; (w)2104 lsl/checkpoint
;-------------------------------------------------------------------------------
anz_sort:       DC.W 0
sort_table_adr: DC.L 0
sort_pointers:  >PART

                movea.l sort_table_adr,A0

                moveq   #0,D0
                move.w  anz_sort(PC),D1
                subq.w  #1,D1
                lsl.w   #3,D1

                lea     (A0),A1
                adda.w  D0,A0           ;links
                adda.w  D1,A1           ;rechts

                moveq   #-8,D6          ; masker

                lea     links_i_done(PC),A2 ;***
                lea     i_rechts_done(PC),A3 ;***

                lea     quick_sort_polygon3(PC),A5
                jsr     (A5)            ; start sorting
qs_ptrs_done:
                rts
                ENDPART
;--------------------------------------------
; A0...links,i
; A1...rechts,i
; A2...links_i_done
; A3...i_rechts_done
;
; A5...qsort_function
; A6...temp
;
; D0...links
; D1...rechts
; D5...temp
; D6...masker
; D7...temp
                IFNE TEST
                >PART ' stack check '
smax:           DC.L 0
; check stack size
                move.l  #stack,D0
                sub.l   SP,D0
                cmp.l   smax(PC),D0
                ble.s   nsmax
                move.l  D0,smax
nsmax:
                ENDPART
                ENDC
quick_sort_polygon3:>PART
;
; A0 ... links
; A1 ... rechts
; D2 ... i
; D3 ... j
                move.l  A0,D0           ;links
                add.l   A1,D0           ;links+rechts
                lsr.l   #1,D0           ;(links+rechts)/2
                and.w   D6,D0           ;-8 mask
                movea.l D0,A6
                move.w  (A6),D7         ;xvergleich = (links+rechts)/2

                move.l  A0,D0           ; links
                move.l  A1,D1           ; rechts
;-----------------------------------------------------
qs_loop_inner3:
*; while (a0,d2.w) < D4      i
*                subq.l  #8,A0
*qs_13:
*                addq.l  #8,A0                     ;i++
*                cmp.w   (A0),D7
*                bgt.s   qs_13

; while (a0,d2.w) > D4      i
                subq.l  #8,A0
qs_13:
                addq.l  #8,A0           ;i++
                cmp.w   (A0),D7
                blt.s   qs_13
;-----------------------------------------------------
*;while D4 < (a0,d3.w)       j
*                addq.l  #8,A1
*qs_23:
*                subq.l  #8,A1                     ;j--
*                cmp.w   (A1),D7
*                blt.s   qs_23


;while D4 > (a0,d3.w)       j
                addq.l  #8,A1
qs_23:
                subq.l  #8,A1           ;j--
                cmp.w   (A1),D7
                bgt.s   qs_23
;-----------------------------------------------------
;if D2<=D3      i<=j
                cmpa.l  A0,A1
                blt.s   qs_no_swap3
; swap Z
                move.w  (A0),D5
                move.w  (A1),(A0)+
                move.w  D5,(A1)+
; swap polyptr
                move.l  (A0),D5
                move.l  (A1),(A0)+
                move.l  D5,(A1)+

                addq.l  #2,A0
*** addq.l  #2,A1
;i++
;j--
                lea     -8-8+2(A1),A1   ;j--
qs_no_swap3:
;until I>J
                cmpa.l  A0,A1           ; while( i<=j)
                bge.s   qs_loop_inner3

;if Links<J   D0<D3   then rekursiv
                cmpa.l  D0,A1           ; if( links<j)
                ble.s   qs_n13
; qsort(links,j);
                movem.l D1/A0,-(SP)     ;
                movea.l D0,A0           ;links
                jsr     (A5)            ;qsort(links,j);
links_i_done:
                movem.l (SP)+,D1/A0
qs_n13:
;--------------------------------------------------
;if I<Rechts  D2<D1   then rekursiv
                cmp.l   A0,D1
                ble.s   qs_n23
; qsort(i,rechts);
                movea.l D1,A1           ;rechts
                jsr     (A5)            ;qsort(i,rechts);
i_rechts_done:
qs_n23:
                rts

                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

;y:              RS.W 1
;x:              RS.W 1
;u:              RS.W 1
;v:              RS.W 1

vertex0:        DS.B 32
vertex1:        DS.B 32
vertex2:        DS.B 32
vertex3:        DS.B 32


proj_z:         DC.W -300       ;   -200
z_zoom:         DC.W -150

poly_center_x:  DC.W 160/2      ; +80
poly_center_y:  DC.W 100/2      ;  +100  ;         100/2-30   ;  +14

view_x_lt:      DC.W 0          ;28
view_y_lt:      DC.W 0          ;32+120
view_z_lt:      DC.W 0          ;  -200       ;150-30     ; -200       ;   -200  150
;-------------------------------------------------------------------------------


setup_matrix_normal:
                bsr     init_matrix     ; identity matrix

                move.w  yr(PC),D0
                bsr     set_matrix_yr

                move.w  xr(PC),D0
                bsr     set_matrix_xr


                move.w  zr(PC),D0
                bsr     set_matrix_zr

                rts
                ENDPART

setup_matrix_label:

                bsr     init_matrix     ; identity matrix

                move.w  yr(PC),D0
                bsr     set_matrix_yr

                move.w  xr(PC),D0
                bsr     set_matrix_xr

                move.w  zr(PC),D0
                bsr     set_matrix_zr

                rts

set_matrix_xr:
                bsr     get_sin_cos
                lea     rot_matrix(PC),A0
                bsr     matrix_xrot

                lea     m(PC),A0
                lea     rot_matrix(PC),A1
                bsr     mat_mul
                rts
set_matrix_yr:
                bsr     get_sin_cos
                lea     rot_matrix(PC),A0
                bsr     matrix_yrot

                lea     m(PC),A0
                lea     rot_matrix(PC),A1
                bsr     mat_mul
                rts
set_matrix_zr:
                bsr     get_sin_cos
                lea     rot_matrix(PC),A0
                bsr     matrix_zrot

                lea     m(PC),A0
                lea     rot_matrix(PC),A1
                bsr     mat_mul
                rts

;-------------------------------------------------------------------------------
init_matrix:    >PART ' init + definitions '
EINS            SET $4000
ROW             SET 3*2

                lea     m(PC),A0
                move.w  #EINS,(A0)+     ;X_x
                move.w  #0,(A0)+        ;X_y
                move.w  #0,(A0)+        ;X_z

                move.w  #0,(A0)+        ;Y_x
                move.w  #EINS,(A0)+     ;Y_y
                move.w  #0,(A0)+        ;Y_z

                move.w  #0,(A0)+        ;Z_x
                move.w  #0,(A0)+        ;Z_y
                move.w  #EINS,(A0)+     ;Z_z
                rts

;         PART 'Matrizen'
m:
                DC.W 0,0,0
                DC.W 0,0,0
                DC.W 0,0,0
temp_matrix:
                DC.W 0,0,0
                DC.W 0,0,0
                DC.W 0,0,0
rot_matrix:
                DC.W 0,0,0
                DC.W 0,0,0
                DC.W 0,0,0
                ENDPART
get_sin_cos:    PART            ; D0 ... angle   OUT: D0=sin  D1=cos
                movea.l sintab_adr,A0
                and.w   #SIN_MASK,D0
                adda.w  D0,A0
                move.w  (A0),D0         ;sin
                move.w  COS(A0),D1      ;cos
                rts
                ENDPART
matrix_xrot:    >PART           ; A0 Matrix   D0 sin   D1 cos
                move.w  D0,D2
                neg.w   D2              ;-sin

                move.w  #EINS,(A0)+     ;X_x      1
                move.w  #0,(A0)+        ;X_y
                move.w  #0,(A0)+        ;X_z

                move.w  #0,(A0)+        ;Y_x
                move.w  D1,(A0)+        ;Y_y     cos
                move.w  D2,(A0)+        ;Y_z    -sin

                move.w  #0,(A0)+        ;Z_x
                move.w  D0,(A0)+        ;Z_y     sin
                move.w  D1,(A0)+        ;Z_z     cos
                rts
                ENDPART
matrix_yrot:    >PART           ; A0 Matrix   D0 sin   D1 cos
                move.w  D0,D2
                neg.w   D2              ;-sin

                move.w  D1,(A0)+        ;X_x     cos
                move.w  #0,(A0)+        ;X_y
                move.w  D0,(A0)+        ;X_z     sin

                move.w  #0,(A0)+        ;Y_x
                move.w  #EINS,(A0)+     ;Y_y
                move.w  #0,(A0)+        ;Y_z

                move.w  D2,(A0)+        ;Z_x    -sin
                move.w  #0,(A0)+        ;Z_y
                move.w  D1,(A0)+        ;Z_z     cos
                rts
                ENDPART
matrix_zrot:    >PART           ; A0 Matrix   D0 sin   D1 cos
                move.w  D0,D2
                neg.w   D2              ;-sin

                move.w  D1,(A0)+        ;X_x   cos
                move.w  D2,(A0)+        ;X_y  -sin
                move.w  #0,(A0)+        ;X_z

                move.w  D0,(A0)+        ;Y_x   sin
                move.w  D1,(A0)+        ;Y_y   cos
                move.w  #0,(A0)+        ;Y_z

                move.w  #0,(A0)+        ;Z_x
                move.w  #0,(A0)+        ;Z_y
                move.w  #EINS,(A0)+     ;Z_z
                rts
                ENDPART
; multiplies Matrix A0  by Matrix A1  result is stored in A0
mat_mul:        >PART
;;; A0 m
;;; A1 matrix2 (f.e. Rotation_Matrix)

                lea     temp_matrix(PC),A6
                movem.l A0/A6,-(SP)
                moveq   #3-1,D7
i_mm:
                moveq   #3-1,D6
                pea     (A1)
j_mm:
                moveq   #0,D0           ;temp_matrix(i,j) = 0

                lea     (A0),A2         ;m
                lea     (A1),A3         ;matrix2
                moveq   #3-1,D5
k_mm:
;; temp_matrix(i,j) = temp_matrix(i,j) +  m(i,k) * matrix2(k,j)

                move.w  (A2)+,D1        ; m(i,k)
                muls    (A3),D1         ; matrix(k,j)
                add.l   D1,D0
                lea     ROW(A3),A3

                dbra    D5,k_mm

                asl.l   #2,D0
                swap    D0
                move.w  D0,(A6)+
                addq.l  #2,A1           ;j++
                dbra    D6,j_mm

                movea.l (SP)+,A1
                lea     ROW(A0),A0      ;i++
                dbra    D7,i_mm

                movem.l (SP)+,A0/A6

; write result to final matrix:
                move.w  (A6)+,(A0)+
                move.w  (A6)+,(A0)+
                move.w  (A6)+,(A0)+

                move.w  (A6)+,(A0)+
                move.w  (A6)+,(A0)+
                move.w  (A6)+,(A0)+

                move.w  (A6)+,(A0)+
                move.w  (A6)+,(A0)+
                move.w  (A6)+,(A0)+
                rts
                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

pivot_point_x:  DC.W 0
pivot_point_y:  DC.W 0
pivot_point_z:  DC.W 0


pre_transformation:DC.W 0
input_vertices_ptr:DC.L 0

pretrans_label: PART

                movem.l A0-A1,-(SP)

                move.w  zr_label(PC),D0
                bsr     get_sin_cos
                move.w  D0,D5           ; sin
                move.w  D1,D6           ; cos

                movea.l input_vertices_ptr(PC),A0
                lea     pre_trans_input_xyz,A1 ; OUTPUT

                movea.w pivot_point_x(PC),A2
                movea.w pivot_point_y(PC),A3


                move.w  amt_calc(PC),D7
ptl_l:
                move.w  (A0)+,D0        ; x
                move.w  (A0)+,D1        ; y

                sub.w   A2,D0           ; pivot_point_x
                sub.w   A3,D1           ; pivot_point_y

                add.w   D0,D0
                add.w   D0,D0

                add.w   D1,D1
                add.w   D1,D1

                move.w  D0,D2
                move.w  D1,D3

                muls    D6,D0           ; x*cos
                muls    D5,D3           ; y*sin
                add.l   D3,D0

                muls    D6,D1           ; y*cos
                muls    D5,D2           ; x*cos
                sub.l   D2,D1

                swap    D0
                swap    D1

                add.w   A2,D0           ; pivot_point_x
                add.w   A3,D1           ; pivot_point_y

                move.w  D0,(A1)+        ;x
                move.w  D1,(A1)+        ;y
                move.w  (A0)+,(A1)+     ;z

                dbra    D7,ptl_l

                movem.l (SP)+,A0-A1
                rts
                ENDPART

pretrans_arm:   >PART

                movem.l A0-A1,-(SP)

*   move.l  zr_arm(PC),D0
*   asr.l   #6,D0

                move.w  zr_arm(PC),D0

                bsr     get_sin_cos
                move.w  D0,D5           ; sin
                move.w  D1,D6           ; cos

                movea.l input_vertices_ptr(PC),A0
                lea     pre_trans_input_xyz,A1 ; OUTPUT

                movea.w pivot_point_x(PC),A2
                movea.w pivot_point_y(PC),A3

                move.w  amt_calc(PC),D7
pta_l:
                move.w  (A0)+,D0        ; x
                move.w  (A0)+,D1        ; y

                sub.w   A2,D0           ; pivot_point_x
                sub.w   A3,D1           ; pivot_point_y

                add.w   D0,D0
                add.w   D0,D0

                add.w   D1,D1
                add.w   D1,D1

                move.w  D0,D2
                move.w  D1,D3

                muls    D6,D0           ; x*cos
                muls    D5,D3           ; y*sin
                add.l   D3,D0

                muls    D6,D1           ; y*cos
                muls    D5,D2           ; x*cos
                sub.l   D2,D1

                swap    D0
                swap    D1

                add.w   A2,D0           ; pivot_point_x
                add.w   A3,D1           ; pivot_point_y

                move.w  D0,(A1)+        ;x
                move.w  D1,(A1)+        ;y
                move.w  (A0)+,(A1)+     ;z

                dbra    D7,pta_l

                movem.l (SP)+,A0-A1
                rts
                ENDPART



;A0 source   A1 target
_3d_calc_points:>PART           ;IN: A0.xyz D0.amount  OUT: A1.xy

                subq.w  #1,D0
                move.w  D0,amt_calc
                move.l  A0,input_vertices_ptr

                movem.l A0-A1,-(SP)

                clr.b   pre_transformation

                move.w  object_current(PC),D0
                cmp.w   #LABEL,D0
                beq.s   label_object
                cmp.w   #ARM,D0
                beq.s   arm_object
normal_object:
                bra.s   pretrans_done
arm_object:
                st      pre_transformation
                bsr     pretrans_arm
                bra.s   pretrans_done
label_object:
                st      pre_transformation
                bsr     pretrans_label
pretrans_done:
                lea     m(PC),A5
                lea     xx+2(PC),A6
                BASE A6,xx
                move.w  (A5)+,xx(A6)
                move.w  (A5)+,xy(A6)
                move.w  (A5)+,xz(A6)
                move.w  (A5)+,yx(A6)
                move.w  (A5)+,yy(A6)
                move.w  (A5)+,yz(A6)
                move.w  (A5)+,zx(A6)
                move.w  (A5)+,zy(A6)
                move.w  (A5)+,zz(A6)
                BASE A6,OFF


                movea.w poly_center_x(PC),A2
                movea.w poly_center_y(PC),A3


                moveq   #14,D7

                movem.w view_x_lt(PC),D0

*  movem.w pivot_point_x(PC),D1
                moveq   #0,D1

                asl.l   #2,D0
                add.l   D1,D0
                asl.l   D7,D0           ; 2^16
                movea.l D0,A5

                movem.w view_y_lt(PC),D0

*   movem.w pivot_point_y(PC),D1
                moveq   #0,D1

                asl.l   #2,D0
                add.l   D1,D0
                asl.l   D7,D0           ; 2^16
                movea.l D0,A6

*   movem.w pivot_point_x(PC),D3-D5
*    movea.w view_x_lt(PC),A5
*    movea.w view_y_lt(PC),A6
*    adda.w  D3,A5
*     adda.w  D4,A6

                lea     z_mul_tab+Z_NULL_PROJZ*2,A4

                move.w  view_z_lt(PC),D2
                movem.w pivot_point_z(PC),D1
                asr.w   #2,D1
                add.w   D1,D2

                add.w   D2,D2
                adda.w  D2,A4

                movem.l (SP)+,A0-A1

                tst.b   pre_transformation
                beq.s   no_pretrans
                lea     pre_trans_input_xyz,A0
no_pretrans:
                move.w  camera_x(PC),cam_x_add+2
                move.w  camera_y(PC),cam_y_add+2
                move.w  camera_z(PC),cam_z_add+2

                move.w  amt_calc(PC),D7
_3d_do_koords:
                move.w  (A0)+,D0        ;x
                move.w  (A0)+,D1        ;y
                move.w  (A0)+,D2        ;z

cam_x_add:      add.w   #0,D0
cam_y_add:      add.w   #0,D1
cam_z_add:      add.w   #0,D2

                move.w  D0,D3
                move.w  D1,D4
                move.w  D2,D5

xx:             muls    #0,D0           ;x_x
xy:             muls    #0,D1           ;x_y
xz:             muls    #0,D2           ;x_z
                add.l   D1,D0
                add.l   D2,D0
                add.l   A5,D0           ; view_x_lt
                swap    D0


                move.w  D3,D6
                move.w  D4,D1
                move.w  D5,D2

yx:             muls    #0,D6           ;y_x
yy:             muls    #0,D1           ;y_y
yz:             muls    #0,D5           ;y_z
                add.l   D6,D1
                add.l   D5,D1
                add.l   A6,D1           ; view_y_lt
                swap    D1


zx:             muls    #0,D3           ;z_x
zy:             muls    #0,D4           ;z_y
zz:             muls    #0,D2           ;z_z
                add.l   D3,D2
                add.l   D4,D2
                swap    D2

*   add.w   A5,D0           ; view_x_lt
*   add.w   A6,D1           ; view_y_lt

                add.w   D2,D2
                move.w  0(A4,D2.w),D3   ;Z_Mul_Tab
                muls    D3,D0
                muls    D3,D1
                asr.l   #8,D0
                asr.l   #8,D1

                add.w   A2,D0           ; Center X
                add.w   A3,D1           ; Center Y

ymin_check:     cmp.w   #$7FFF,D1
                bge.s   nymin
                move.w  D1,2+ymin_check
nymin:

ymax_check:     cmp.w   #-$7FFF,D1
                ble.s   nymax
                move.w  D1,2+ymax_check
nymax:

                move.w  D1,(A1)+        ; Yt.result
                move.w  D0,(A1)+        ; Xt.result
                move.w  D2,(A1)+        ; Z

                dbra    D7,_3d_do_koords

; TODO: CHECK TOTAL Y-CLIP!!!

                move.w  2+ymin_check(PC),D0
                bpl.s   ymin_ok
                moveq   #0,D0
ymin_ok:
                move.w  D0,y_min

                move.w  2+ymax_check(PC),D0
                cmp.w   #100-1,D0
                ble.s   ymax_ok
                move.w  #100-1,D0
ymax_ok:
                move.w  D0,y_max
                rts

amt_calc:       DC.W 0

                ENDPART

set_matrix_yxz: >PART
                move.w  cosy(PC),D0     ;x * cosy*cosz
                muls    cosz(PC),D0

                move.w  siny(PC),D1     ;x * -sinx*sinx*sinz
                muls    sinx(PC),D1
                asl.l   #2,D1
                swap    D1
                muls    sinz(PC),D1
                sub.l   D1,D0
                asl.l   #2,D0
                swap    D0
                move.w  D0,(A5)+        ;x_x

                move.w  cosx(PC),D0     ;y * -cosx*sinz
                muls    sinz(PC),D0
                asl.l   #2,D0
                neg.l   D0
                swap    D0
                move.w  D0,(A5)+        ;x_y

                move.w  siny(PC),D0     ;z * siny*cosz
                muls    cosz(PC),D0

                move.w  cosy(PC),D1     ;z * cosx*sinx*sinz
                muls    sinx(PC),D1
                asl.l   #2,D1
                swap    D1
                muls    sinz(PC),D1
                add.l   D1,D0
                asl.l   #2,D0
                swap    D0
                move.w  D0,(A5)+        ;x_z
;;;;
                move.w  cosy(PC),D0     ;x * cosy*sinz
                muls    sinz(PC),D0

                move.w  siny(PC),D1     ;x * siny*sinx*cosz
                muls    sinx(PC),D1
                asl.l   #2,D1
                swap    D1
                muls    cosz(PC),D1
                add.l   D1,D0
                asl.l   #2,D0
                swap    D0
                move.w  D0,(A5)+        ;y_x

                move.w  cosx(PC),D0     ;y * cosx*cosz
                muls    cosz(PC),D0
                asl.l   #2,D0
                swap    D0
                move.w  D0,(A5)+        ;y_y

                move.w  siny(PC),D0     ;z * siny*sinz
                muls    sinz(PC),D0

                move.w  cosy(PC),D1     ;z * -cosy*sinx*cosz
                muls    sinx(PC),D1
                asl.l   #2,D1
                swap    D1
                muls    cosz(PC),D1
                sub.l   D1,D0
                asl.l   #2,D0
                swap    D0
                move.w  D0,(A5)+        ;y_z
;;;;
                move.w  siny(PC),D0     ;x * -siny*cosx
                muls    cosx(PC),D0
                asl.l   #2,D0
                neg.l   D0
                swap    D0
                move.w  D0,(A5)+        ;z_x

                move.w  sinx(PC),D0     ;y * sinx
                move.w  D0,(A5)+        ;z_y

                move.w  cosy(PC),D0     ;z * cosy*cosx
                muls    cosx(PC),D0
                asl.l   #2,D0
                swap    D0
                move.w  D0,(A5)+        ;z_z
                rts

sinx:           DC.W 0
cosx:           DC.W 0
siny:           DC.W 0
cosy:           DC.W 0
sinz:           DC.W 0
cosz:           DC.W 0

matrix:
;                    x y z
                DC.W 1,0,0      ;x
                DC.W 0,1,0      ;y
                DC.W 0,0,1      ;z
                ENDPART

camera_x:       DC.W 0
camera_y:       DC.W 0
camera_z:       DC.W 0

y_min:          DC.W 0
y_max:          DC.W 0
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
get_ztrans:     >PART
                movem.l D1-D2,-(SP)
                move.w  z_zoom(PC),D1
                sub.w   D0,D1
                ext.l   D1
                asl.l   #8,D1

                move.w  proj_z(PC),D2
                sub.w   D0,D2
                bne.s   nzz
                moveq   #0,D0
                bra.s   eg
nzz:
                divs    D2,D1
                move.w  #256,D0
                sub.w   D1,D0
eg:
                movem.l (SP)+,D1-D2
                rts
                ENDPART
init_z_mul_tab: >PART
*   DC.L $4AFC4E71

                lea     z_mul_tab,A0
                move.w  #6000-1,D7
                move.w  #-Z_NULL_PROJZ,D1
izmt0:
                move.w  D1,D0
                bsr.s   get_ztrans
                move.w  D0,(A0)+
                addq.w  #1,D1
                dbra    D7,izmt0
                rts
                ENDPART
;-------------------------------------------------------------------------------


;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
init_texturemapper:>PART
                bsr     init_divtable_polygon
                bsr     init_polydiv_table2
                bsr     init_texture_tmapper
                rts
                ENDPART
;-------------------------------------------------------------------------------
init_texture_tmapper:>PART

*   DC.L $4AFC4E71

; half of the texture needs
; no be copied to the top & bottom (64 k addressing issues!)

                lea     player_tex_inc+32,A0
                movea.l player_tex_adr(PC),A1
                move.w  #256-1,D7
                bsr.s   copy_texlines

                movea.l player_tex_adr(PC),A0
                lea     (A0),A1
                suba.l  #$00008000,A1
                adda.l  #$00008000,A0
                move.w  #128-1,D7
                bsr.s   copy_texlines

                movea.l player_tex_adr(PC),A0
                lea     (A0),A1
                adda.l  #$00010000,A1
                move.w  #128-1,D7
                bsr.s   copy_texlines
;---------------------------------------------------
                lea     label_tex_inc+32,A0
                movea.l label_tex_adr(PC),A1
                move.w  #256-1,D7
                bsr.s   copy_texlines

                movea.l label_tex_adr(PC),A0
                lea     (A0),A1
                adda.l  #$00010000,A1
                move.w  #128-1,D7
                bsr.s   copy_texlines

                rts

copy_texlines:
                REPT 256/4
                move.l  (A0)+,(A1)+
                ENDR
                dbra    D7,copy_texlines
                rts

                ENDPART
;-------------------------------------------------------------------------------
init_divtable_polygon:>PART

*   DC.L $4AFC4E71

                lea     divtable_polygon,A0
                move.w  #$7FFF,(A0)+    ; 0
                moveq   #1,D0
                move.w  #512-1-1,D7
idp:
                move.l  #$00007FFF,D5
                divu    D0,D5
                move.w  D5,(A0)+
                addq.w  #1,D0
                dbra    D7,idp
                rts
                ENDPART
;-------------------------------------------------------------------------------
init_polydiv_table2:>PART

*    DC.L $4AFC4E71

                lea     polydiv_table2_neg,A0
                lea     polydiv_table2_end+2,A1
                movea.l #EXT_*EXT_,A2
                move.w  #-1024,D6
                move.w  #1024-1,D7
ipdt2:
                move.l  A2,D0
                divs    D6,D0
                move.w  D0,(A0)+
                neg.w   D0
                move.w  D0,-(A1)
                addq.w  #1,D6
                dbra    D7,ipdt2
                rts
                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

init_cuvx_rout_table:>PART

*    DC.L $4AFC4E71

                lea     cuvx_s+511*cuvx_size(PC),A0
                lea     cuvx_rout_table(PC),A1
                move.w  #512-1,D7
icvrtl:
                move.l  A0,(A1)+
                lea     -cuvx_size(A0),A0
                dbra    D7,icvrtl
                rts
                ENDPART


                RSSET $00000140
y_clip_flag:    RS.W 1
y_pos:          RS.W 1

;-------------------------------------------------------------------------------
clip_x_tmap     EQU 160
clip_y_tmap     EQU 100
;-------------------------------------------------------------------------------

TRI_MAP:        PART
;;;;;;;##### triangle texture mapping routine ...
; A1 A2 A3  points
; struct point { short y; short x; short u; short v; }
;                RSSET 0
;y:              RS.W 1
;x:              RS.W 1
;u:              RS.W 1
;v:              RS.W 1

EXT_            SET 128
EF_             SET 7

*   DC.L $4AFC4E71

                clr.b   y_clip_flag.w

                moveq   #clip_y_tmap,D7
                cmp.w   (A1),D7         ;; clipY v0
                sls     D1              ;;
                cmp.w   (A2),D7         ;; clipY v1
                sls     D2              ;;
                cmp.w   (A3),D7         ;; clipY v2
                sls     D3              ;;

                moveq   #1,D4
                and.w   D4,D1
                add.w   D1,D1           ; v0
                and.w   D4,D2
                or.w    D2,D1
                add.w   D1,D1           ; v0
                and.w   D4,D3
                or.w    D3,D1
                add.w   D1,D1           ; v0
                beq.s   cyc_noclip
                jmp     clip_y_cases(PC,D1.w)
clip_y_cases:
                OPT O-,W-
                bra.s   cyc_noclip
                bra.s   cyc_xx2
                bra.s   cyc_x1x
                bra.s   cyc_x12
                bra.s   cyc_0xx
                bra.s   cyc_0x2
                bra.s   cyc_01x
                bra.s   cyc_012
                OPT O+,W+
cyc_012:                                ; TOTAL Y_CLIP!
                rts
cx_total:                               ; TOTAL X_CLIP!
                rts
cyc_xx2:
cyc_x1x:
cyc_x12:
cyc_0xx:
cyc_0x2:
cyc_01x:
                st      y_clip_flag.w
cyc_noclip:
y_clipping_done:

; X clip check
                move.w  #clip_x_tmap,D7
                cmp.w   2(A1),D7        ;; clipX v0
                sls     D1              ;;
                cmp.w   2(A2),D7        ;; clipX v1
                sls     D2              ;;
                cmp.w   2(A3),D7        ;; clipX v2
                sls     D3              ;;
; if ALL vertices are outside clipX, no polygon!
                move.b  D1,D0
                and.b   D2,D0
                and.b   D3,D0
                bne.s   cx_total

*     move.b  D1,D0
*    or.b    D2,D0
*   or.b    D3,D0
*  or.b    D0,y_clip_flag.w
;------------------------------------------------------------------------

                move.w  (A2),D0         ;y2
                cmp.w   (A1),D0         ;y1
                bge.s   y1_lt_y2
                exg     A1,A2           ; Tausch wenn y2<y1
y1_lt_y2:
                move.w  (A3),D0         ;y3
                cmp.w   (A1),D0         ;y1
                bge.s   y1_lt_y3
                exg     A1,A3           ; Tausch wenn y3<y1
y1_lt_y3:
                move.w  (A3),D0         ;y3
                cmp.w   (A2),D0         ;y2
                bge.s   y2_lt_y3
                exg     A2,A3           ; Tausch wenn y3<y2
y2_lt_y3:
                move.w  (A3),D2         ;y3       = max_y
                sub.w   (A1),D2         ;y1       = min_y
                beq     no_polygon

                move.w  D2,delta_y      ;; y3 - y1  = max_y_size

                lea     polydiv_table2(PC),A4

                move.w  (A2),D0         ; y2
                sub.w   (A1),D0         ;-y1
                move.w  D0,dy1

                move.w  (A3),D0         ; y3
                sub.w   (A2),D0         ;-y2
                move.w  D0,dy2


                move.w  (A2),D1         ; y2
                sub.w   (A1),D1         ;-y1

*   muls    #EXT_,D1        ; EXT
*   divs    D2,D1           ; / delta_y
*   move.w  D1,y_faktor

; NEW:
;  move.l  #EXT_*EXT_,D7
;  divu    D2,D7
;  mulu    D7,D1
                add.w   D2,D2
                muls    0(A4,D2.w),D1   ; polydiv_table2
                asr.l   #EF_,D1
                move.w  D1,y_faktor

; x3 - x1
                move.w  x(A3),D0        ;x3
                sub.w   x(A1),D0        ;x1
                muls    D1,D0           ; (y2-y1)*EXT/(y3-y1) * (x3-x1)

; x1 - x2
                move.w  x(A1),D1        ;x1
                sub.w   x(A2),D1        ;x2
                muls    #EXT_,D1        ; EXT

                add.l   D1,D0
                asr.l   #EF_,D0         ; <<EXT

*      tst.w   D0
*      beq     no_polygon
                tst.w   D0
                bne.s   xf_nz
                moveq   #1,D0
xf_nz:
                move.w  D0,x_faktor
                ENDPART
;;;;;;;;;;
f               SET 1           ; mhhhhh
                >PART
                move.w  u(A3),D1        ; u3
                sub.w   u(A1),D1        ;-u1
*    add.w   #f,D1           ***

                muls    y_faktor(PC),D1

                move.w  u(A1),D5        ; u1
                sub.w   u(A2),D5        ;-u2
                add.w   #f,D5           ***

                muls    #EXT_,D5        ; EXT
                add.l   D1,D5

*   divs    x_faktor(PC),D5
*   ext.l   D5
*   muls    #65536/EXT_,D5  ;auf 2^16

; NEW:
;  move.l  #EXT_*EXT_,D7
;  divs    x_faktor(PC),D7
                move.w  x_faktor(PC),D7
                add.w   D7,D7
                move.w  0(A4,D7.w),D7   ; polydiv_table2

                muls    D7,D5
                asr.l   #5,D5

;;;;;;;;;;
                move.w  v(A3),D1        ; v3
                sub.w   v(A1),D1        ;-v1
*   add.w   #f,D1           ***

                muls    y_faktor(PC),D1

                move.w  v(A1),D4        ; v1
                sub.w   v(A2),D4        ;-v2
                add.w   #f,D4           ***

                muls    #EXT_,D4        ; EXT
                add.l   D1,D4

*   divs    x_faktor(PC),D4
*   ext.l   D4
*   muls    #65536/EXT_,D4  ;auf 2^16

; NEW:
                muls    D7,D4
                asr.l   #5,D4
;;;;;;;;;;

                move.w  x_faktor(PC),D0
                bpl.s   pos_dx
                neg.w   D0
pos_dx:

*    cmp.w   #300,D0
*    ble.s   dx_ok
*    move.w  #300,D0
dx_ok:

                lea     render_x_code+2+511*4(PC),A6
                move.b  y_clip_flag.w,D1
                beq.s   rxc_noclip
                lea     render_x_codeCLIP+2+511*4(PC),A6
rxc_noclip:

                lsl.l   #8,D4           ; V_INC*256

** addq.w  #1,D0
** addq.w  #1,D0

                move.l  D5,D1           ;U_INC start
                move.l  D4,D2           ;V_INC start
                moveq   #0,D3

                add.w   D0,D0
                add.w   D0,D0
                movea.l cuvx_rout_table(PC,D0.w),A5
                suba.w  2(A5),A6
                jmp     (A5)

cuvx_rout_table:DS.L 512

cuvx_s:
o               SET 0
                REPT 512
                move.w  D3,o(A6)
                move.l  D2,D3           ;V
                swap    D3
                swap    D1              ;U
                move.b  D1,D3
                swap    D1
                add.l   D5,D1           ;U_INC
                add.l   D4,D2           ;V_INC
o               SET o-4
                ENDR
cuvx_e:
cuvx_size       SET (cuvx_e-cuvx_s)/512
;------------------------------------------------------------

                lea     colorram,A6
                move.w  (A1),D0         ;y1
                move.w  D0,y_pos.w
                muls    #CRAM_X,D0
                adda.l  D0,A6

                move.w  x_faktor(PC),D0
                bmi     umgekehrt

                ENDPART

;       A1
;       /\
;      /  \
;     /   _\ A3
;    / __/
;   /_/
;  //
; A2
                >PART           ;*DONE*

                move.w  dy1(PC),D7
                beq     y1_equal_y2
                subq.w  #1,D7

*    DC.L $4AFC4E71

                movem.l A2-A3,-(SP)     ; p2  p3  sichern

                move.w  x(A1),D0
                swap    D0
                clr.w   D0              ;x_links
                move.l  D0,D1           ;x_rechts

                move.w  u(A1),D2
                swap    D2
                clr.w   D2              ;U

                move.w  v(A1),D3
                lsl.w   #8,D3           ***
                swap    D3
                clr.w   D3              ;V
; X Steigung Links:
                move.w  x(A2),D4
                sub.w   x(A1),D4        ;x2 - x1
*   move.w  dy1(PC),D6      ;y2 - y1
*   move.l  #$00007FFF,D5
*   divu    D6,D5           ;1/(y2-y1)
*   muls    D5,D4           ;(x2-x1) / (y2-y1)
*   add.l   D4,D4

                lea     divtable_polygon(PC),A4
                move.w  dy1(PC),D6      ;y2 - y1
                add.w   D6,D6
                add.w   D4,D4
                move.w  0(A4,D6.w),D5   ; 1/(y2-y1)
                muls    D5,D4           ; (x2-x1) / (y2-y1)

                movea.l D4,A0           ;x_links_increment
; U Steigung:
                move.w  u(A2),D4
                sub.w   u(A1),D4        ;U2 - U1
                muls    D5,D4           ;(U2-U1) / (y2-y1)
                add.l   D4,D4
; movea.l D4,A2           ;U_increment
                move.l  D4,-(SP)        ;U_INC

; V Steigung:
                move.w  v(A2),D4
                sub.w   v(A1),D4        ;V2 - V1
                muls    D5,D4           ;(V2-V1) / (y2-y1)
                add.l   D4,D4
                lsl.l   #8,D4           ***
                move.l  D4,-(SP)        ;A3      V_INC

; X Steigung Rechts:
                move.w  x(A3),D4
                sub.w   x(A1),D4        ;x3 - x1
*    move.w  delta_y(PC),D6
*    move.l  #$00007FFF,D5
*    divu    D6,D5           ;1/(y3-y1)
*    muls    D5,D4           ;(x3-x1) / (y3-y1)
*    add.l   D4,D4

                lea     divtable_polygon(PC),A4
                move.w  delta_y(PC),D6
                add.w   D6,D6
                add.w   D4,D4
                muls    0(A4,D6.w),D4   ;(x3-x1) / (y3-y1)

                movea.l D4,A1           ;x_rechts_increment

                movea.l (SP)+,A3        ;V_INC
                movea.l (SP)+,A2        ;U_INC

                bsr     RENDER_TRI

                movem.l (SP)+,A2-A3     ;p2  p3  wiederholen

                move.w  dy2(PC),D7
FIX0:
**  subq.w  #1,D7
**  bmi     no_poly_y23     ; y2 = y3

;; Strecke P2 --> P3
                move.w  x(A2),D0        ;x2
                swap    D0
                clr.w   D0              ;x_links

                move.w  u(A2),D2        ;U
                swap    D2
                clr.w   D2

                move.w  v(A2),D3        ;V
                lsl.w   #8,D3           ***
                swap    D3
                clr.w   D3

                move.w  x(A3),D4
                sub.w   x(A2),D4        ;x3 - x2
*    move.w  dy2(PC),D6      ;y3 - y2
*    move.l  #$00007FFF,D5
*    divu    D6,D5           ;1/(y3-y2)
*    muls    D5,D4           ;(x3-x2) / (y3-y2)
*    add.l   D4,D4

                lea     divtable_polygon(PC),A4
                move.w  dy2(PC),D6      ;y3 - y2
                add.w   D6,D6
                add.w   D4,D4
                move.w  0(A4,D6.w),D5   ;1/(y3-y2)
                muls    D5,D4           ;(x3-x2) / (y3-y2)


                movea.l D4,A0           ;x_links_increment

                move.w  u(A3),D4
                sub.w   u(A2),D4        ;u3 - u2
                muls    D5,D4           ;(u3-u2) / (y3-y2)
                add.l   D4,D4
;         movea.l D4,A2           ;U increment
                move.l  D4,-(SP)        ;U_INC

                move.w  v(A3),D4
                sub.w   v(A2),D4        ;v3 - v2
                muls    D5,D4           ;(v3-v2) / (y3-y2)
                add.l   D4,D4
                lsl.l   #8,D4           ***
                movea.l D4,A3           ;V increment

                movea.l (SP)+,A2        ;U_INC

                bsr     RENDER_TRI
no_poly_y23:
                rts
                ENDPART
y1_equal_y2:    >PART           ;*DONE*
;A2______A1
;  \    /
;   \  /
;    \/
;    A3

                move.w  x(A2),D0        ;x_links
                swap    D0
                clr.w   D0

                move.w  x(A1),D1        ;x_rechts
                swap    D1
                clr.w   D1

                move.w  u(A2),D2
                swap    D2
                clr.w   D2              ;U

                move.w  v(A2),D3
                lsl.w   #8,D3           ***
                swap    D3
                clr.w   D3              ;V

; X Steigung Links:
                move.w  x(A3),D4
                sub.w   x(A2),D4        ;x3 - x2
*   move.w  delta_y(PC),D6  ;y3 - y2   = delta_y
*   move.l  #$00007FFF,D5
*   divu    D6,D5           ;1/(y3-y2)
*   muls    D5,D4           ;(x3-x2) / (y3-y2)
*   add.l   D4,D4
*   movea.l D4,A0           ;x_links_increment

                lea     divtable_polygon(PC),A4
                move.w  delta_y(PC),D6  ;y3 - y2   = delta_y
                add.w   D6,D6
                add.w   D4,D4
                move.w  0(A4,D6.w),D5   ;1/(y3-y2)
                muls    D5,D4           ;(x3-x2) / (y3-y2)
                movea.l D4,A0           ;x_links_increment

; U Steigung:
                move.w  u(A3),D4
                sub.w   u(A2),D4        ;U3 - U2
                muls    D5,D4           ;(U3-U2) / (y3-y2)
                add.l   D4,D4
;         movea.l D4,A2           ;U_increment
                move.l  D4,-(SP)        ;U_INC

; V Steigung:
                move.w  v(A3),D4
                sub.w   v(A2),D4        ;V3 - V2
                muls    D5,D4           ;(V3-V2) / (y3-y2)
                add.l   D4,D4
                lsl.l   #8,D4           ***
                move.l  D4,-(SP)        ;A3      V_INC

q:
; X Steigung Rechts:
                move.w  x(A3),D4
                sub.w   x(A1),D4        ;x3 - x1
;  move.w  delta_y(PC),D6
;  move.l  #$00007FFF,D5
;  divu    D6,D5           ;1/(y3-y1)
                muls    D5,D4           ;(x3-x1) / (y3-y1)
                add.l   D4,D4
                movea.l D4,A1           ;x_rechts_increment

                movea.l (SP)+,A3        ;V_INC
                movea.l (SP)+,A2        ;U_INC

                move.w  delta_y(PC),D7
                subq.w  #1,D7

                bsr     RENDER_TRI
                rts
                ENDPART


umgekehrt:
;       A1
;       /\
;      /  \
;     /   _\ A2
;    / __/
;   /_/
;  //
; A3
                >PART

                move.w  dy1(PC),D7
                beq     y1_equal_y2_U
                subq.w  #1,D7

                movem.l A2-A3,-(SP)     ; p2  p3  sichern

                move.w  x(A1),D0
                swap    D0
                clr.w   D0              ;x_links
                move.l  D0,D1           ;x_rechts

                move.w  u(A1),D2
                swap    D2
                clr.w   D2              ;U

                move.w  v(A1),D3
                lsl.w   #8,D3           ***
                swap    D3
                clr.w   D3              ;V

; X Steigung Links:
                move.w  x(A3),D4
                sub.w   x(A1),D4        ;x3 - x1
*  move.w  delta_y(PC),D6  ;y3 - y1   = delta_y
*  move.l  #$00007FFF,D5
*  divu    D6,D5           ;1/(y3-y1)
*  muls    D5,D4           ;(x3-x1) / (y3-y1)
*  add.l   D4,D4

                lea     divtable_polygon(PC),A4
                move.w  delta_y(PC),D6  ;y3 - y1   = delta_y
                add.w   D6,D6
                add.w   D4,D4
                move.w  0(A4,D6.w),D5   ;1/(y3-y1)
                muls    D5,D4           ;(x3-x1) / (y3-y1)

                movea.l D4,A0           ;x_links_increment
; U Steigung:
                move.w  u(A3),D4
                sub.w   u(A1),D4        ;U3 - U1
                muls    D5,D4           ;(U3-U1) / (y3-y1)
                add.l   D4,D4
;         movea.l D4,A2           ;U_increment
                move.l  D4,-(SP)        ;U_INC

; V Steigung:
                move.w  v(A3),D4
                sub.w   v(A1),D4        ;V3 - V1
                muls    D5,D4           ;(V3-V1) / (y3-y1)
                add.l   D4,D4
                lsl.l   #8,D4           ***
                move.l  D4,-(SP)        ;A3      V_INC

; X Steigung Rechts:
                move.w  x(A2),D4
                sub.w   x(A1),D4        ;x2 - x1
*  move.w  dy1(PC),D6
*  move.l  #$00007FFF,D5
*  divu    D6,D5           ;1/(y2-y1)
*  muls    D5,D4           ;(x2-x1) / (y2-y1)
*  add.l   D4,D4

                lea     divtable_polygon(PC),A4
                move.w  dy1(PC),D6
                add.w   D6,D6
                add.w   D4,D4
                move.w  0(A4,D6.w),D5   ;1/(y2-y1)
                muls    D5,D4           ;(x2-x1) / (y2-y1)

                movea.l D4,A1           ;x_rechts_increment

                movea.l (SP)+,A3        ;V_INC
                movea.l (SP)+,A2        ;U_INC

                bsr     RENDER_TRI

                movem.l (SP)+,A1/A4     ;p2  p3  wiederholen
; A1 p2   A4 p3
                move.w  dy2(PC),D7
FIX1:
** beq     no_poly_y23_U   ; y2 = y3
** subq.w  #1,D7

;; Strecke A2 --> A3  RECHTS!
                move.w  x(A1),D1        ;x2        A2
                swap    D1
                clr.w   D1              ;x_rechts

                move.w  x(A4),D4        ;          A3
                sub.w   x(A1),D4        ;x3 - x2   A2
*  move.w  dy2(PC),D6      ;y3 - y2
*  move.l  #$00007FFF,D5
*  divu    D6,D5           ;1/(y3-y2)
*  muls    D5,D4           ;(x3-x2) / (y3-y2)
*  add.l   D4,D4

                lea     divtable_polygon(PC),A4
                move.w  dy2(PC),D6      ;y3 - y2
                add.w   D6,D6
                add.w   D4,D4
                move.w  0(A4,D6.w),D5   ;1/(y3-y2)
                muls    D5,D4

                movea.l D4,A1           ;x_rechts_increment

                bsr     RENDER_TRI
no_poly_y23_U:
                rts
                ENDPART
y1_equal_y2_U:  >PART
;A1______A2
;  \    /
;   \  /
;    \/
;    A3

                move.w  x(A1),D0
                swap    D0
                clr.w   D0              ;x_links

                move.w  x(A2),D1
                swap    D1
                clr.w   D1              ;x_rechts

                move.w  u(A1),D2
                swap    D2
                clr.w   D2              ;U

                move.w  v(A1),D3
                lsl.w   #8,D3           ***
                swap    D3
                clr.w   D3              ;V
; X Steigung Links:
                move.w  x(A3),D4
                sub.w   x(A1),D4        ;x3 - x1
*  move.w  delta_y(PC),D6  ;y3 - y1   = delta_y
*  move.l  #$00007FFF,D5
*  divu    D6,D5           ;1/(y3-y1)
*  muls    D5,D4           ;(x3-x1) / (y3-y1)
*  add.l   D4,D4

                lea     divtable_polygon(PC),A4
                move.w  delta_y(PC),D6  ;y3 - y1   = delta_y
                add.w   D6,D6
                add.w   D4,D4
                move.w  0(A4,D6.w),D5   ;1/(y3-y1)
                muls    D5,D4           ;(x3-x1) / (y3-y1)

                movea.l D4,A0           ;x_links_increment
; U Steigung:
                move.w  u(A3),D4
                sub.w   u(A1),D4        ;U3 - U1
                muls    D5,D4           ;(U3-U1) / (y3-y1)
                add.l   D4,D4
;   movea.l D4,A2           ;U_increment
                move.l  D4,-(SP)        ;U_INC

; V Steigung:
                move.w  v(A3),D4
                sub.w   v(A1),D4        ;V3 - V1
                muls    D5,D4           ;(V3-V1) / (y3-y1)
                add.l   D4,D4
                lsl.l   #8,D4           ***
                move.l  D4,-(SP)        ;A3      V_INC

; X Steigung Rechts:
                move.w  x(A3),D4
                sub.w   x(A2),D4        ;x3 - x2
                muls    D5,D4           ;(x3-x2) / delta_y
                add.l   D4,D4
                movea.l D4,A1           ;x_rechts_increment

                movea.l (SP)+,A3        ;V_INC
                movea.l (SP)+,A2        ;U_INC

                move.w  delta_y(PC),D7
                subq.w  #1,D7

                bsr.s   RENDER_TRI
                rts
                ENDPART

no_polygon:
                rts

left_fix        EQU $00000000   ;  -$00018000

right_fix       EQU $00008000   ;  -$00018000

left_right_swap_flag EQU $00000140

rechts_lt_links:
                DC.L $4AFC4E71
                rts

no_renderT:
                rts

RENDER_TRI:     >PART

*     DC.L $4AFC4E71

                move.b  y_clip_flag.w,D4
                bne     RENDER_TRI_CLIP_Y

                add.l   #right_fix,D1

                lea     render_x_code+512*4(PC),A4
RT_loop:
                move.l  D0,D4           ;x_links
                move.l  D1,D5           ;x_rechts
                swap    D4
                swap    D5

                sub.w   D5,D4           ;delta_X
;;;;;;; bgt.s   rechts_lt_links
delta_x_ok:
                move    A6,USP
                adda.w  D5,A6           ; X_START = x_rechts

                move.l  D3,D5           ; V
tex_adr0:       move.w  #0,D5           ; texture_address high
                swap    D5
                swap    D2
                move.b  D2,D5           ; U
                swap    D2
                movea.l D5,A5

C               EQU 15*8+$0006
*    clr.w   D6              ***
*    movea.l D6,A5
*    move.b  #C,(A5)

                add.w   D4,D4
                add.w   D4,D4
                jmp     0(A4,D4.w)
render_x_code:
                REPT 512
                move.b  0(A5),-(A6)
                ENDR

                move    USP,A6
                lea     CRAM_X(A6),A6   ; save scanline pos.

                add.l   A0,D0           ;x_links  inc
                add.l   A1,D1           ;x_rechts inc
                add.l   A2,D2           ;U Inc
                add.l   A3,D3           ;V Inc
                dbra    D7,RT_loop

                sub.l   #right_fix,D1

                rts

                ENDPART

RENDER_TRI_CLIP_Y:>PART

*   DC.L $4AFC4E71

                move.w  y_pos.w,D6

                add.l   #right_fix,D1

                lea     render_x_codeCLIP+512*4(PC),A4
RT_loop_cY:
                cmp.w   #clip_y_tmap-1,D6
                bhi     next_line_cy

                move.l  D0,D4           ;x_links
                move.l  D1,D5           ;x_rechts
*    bmi     next_line_cy

                swap    D4
                swap    D5

*    cmp.w   #160,D4
*    bge     next_line_cy

                sub.w   D5,D4           ;delta_X
;;;;;;; bgt.s   rechts_lt_links

                move    A6,USP
                adda.w  D5,A6           ; X_START = x_rechts

                move.l  D3,D5           ; V
tex_adr1:       move.w  #0,D5           ; texture_address high
                swap    D5
                swap    D2
                move.b  D2,D5           ; U
                swap    D2
                movea.l D5,A5

                add.w   D4,D4
                add.w   D4,D4
                jmp     0(A4,D4.w)
render_x_codeCLIP:
                REPT 512
                move.b  0(A5),-(A6)
                ENDR

                move    USP,A6
next_line_cy:
                lea     CRAM_X(A6),A6   ; next scanline pos.
                add.l   A0,D0           ;x_links  inc
                add.l   A1,D1           ;x_rechts inc
                add.l   A2,D2           ;U Inc
                add.l   A3,D3           ;V Inc
                addq.w  #1,D6           ; y_pos++

                dbra    D7,RT_loop_cY

                move.w  D6,y_pos.w
                sub.l   #right_fix,D1

                rts

                ENDPART

delta_y:        DC.W 0
dy1:            DC.W 0          ;y2-y1
dy2:            DC.W 0          ;y3-y2

x_faktor:       DC.W 0
y_faktor:       DC.W 0
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

                IFNE TEST
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
                move.l  A0,sintab_adr

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
                ENDC

;-------------------------------------------------------------------------------
init_c2p:       >PART
                bsr.s   init_c2p_short
                rts
                ENDPART
init_c2p_short: >PART

*   DC.L $4AFC4E71

                lea     C2P_TABLE.w,A0

                moveq   #16-1,D7
c2pm_1:
                move.w  D7,-(SP)
                neg.w   D7
                add.w   #16-1,D7

                moveq   #16-1,D6
c2pm_2:
                move.w  D6,-(SP)
                neg.w   D6
                add.w   #16-1,D6

                moveq   #4-1,D5
c2p_planes:
                btst    D5,D7
                sne     D2
                btst    D5,D6
                sne     D3
                and.b   #%11000000,D2
                and.b   #%00110000,D3
                ror.l   #8,D2
                ror.l   #8,D3
                dbra    D5,c2p_planes

                or.l    D3,D2
                move.l  D2,(A0)
                lsr.l   #4,D2
                move.l  D2,-4(A0)
                addq.l  #8,A0

                move.w  (SP)+,D6
                dbra    D6,c2pm_2

                lea     $0800-16*8(A0),A0

                move.w  (SP)+,D7
                dbra    D7,c2pm_1
                rts
                ENDPART
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

                movea.l screen1(PC),A0

                lea     (A0),A1
                lea     (A0),A2
                lea     (A0),A3
                lea     (A0),A4
                lea     (A0),A5
                lea     (A0),A6

                move.w  #1,D0


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

                tst.w   D0              ;1
                bmi.s   es              ; branch--3, sonst 2
                nop                     ;1
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
;-------------------------------------------------------------------------------
                ENDC
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


colors:         DS.W 16

black:
zero:           DS.L 16

player_tex_adr: DC.L 0
label_tex_adr:  DC.L 0

screen0:        DC.L 0
screen1:        DC.L 0


divtable_polygon:DS.W 512

polydiv_table2_neg:DS.W 1024
polydiv_table2: DS.W 1024
polydiv_table2_end:DS.W 1

                DATA

                PATH 'C:\0NEW\TDOME\0YMPART\'
                PATH '3D_TUTBL\'
player_st3:
                IBYTES 'BASE2.ST3'
arm_st3:
                IBYTES 'ARM.ST3'
label_st3:
                IBYTES 'LABEL.ST3'

player_tex_inc:
                IBYTES 'PLAYER.606'
label_tex_inc:
                IBYTES 'LABEL.606'


                IFNE TEST
;-------------------------------------------------------------------------------
rte:            rte
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
                IBYTES 'DISKBLIB.PRG'
                EVEN
;-------------------------------------------------------------------------------
                ENDC

                BSS

;-----------------------------------------
                IFNE TEST

                DS.B 512
stack:          DS.B 4

memsave:        DS.B $8000

sintab:         DS.W 2*2048

                ENDC
;-----------------------------------------

BSS_START:      DS.B 2

object0_Z_ptr_adr:DS.B 256*8

object0:        DS.B $2000
object1:        DS.B $2000
object2:        DS.B $2000

                DS.B 256
object0_Z_ptr:  DS.B 256*8


pre_trans_input_xyz:DS.B 4096



z_mul_tab:      DS.W 6000
zmte:

_3d_result:     DS.B 4096


                DS.B 256
screen_ram:
                DS.B 32000
                DS.B 32000

BSS_END:        DS.B 2

                DS.B $8000
                DS.L 65536/4    ;; FOR A 65536 BOUNDARY!!
zero_base:
                DS.B 256*256    ; texture 256x256
;  DS.B $8000
                DS.B 256*256    ; 2nd half

                DS.B 256*256    ; label
                DS.B 128*256    ; label 2nd half

                DS.B 100*CRAM_X
colorram:       DS.B 100*CRAM_X
                DS.B 100*CRAM_X


;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
                END
E:
                END

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
                lea     BSS_START,A0
                lea     BSS_END,A1
                bsr     memclr_a0_a1
black:
zero:           DS.L 16
                END
