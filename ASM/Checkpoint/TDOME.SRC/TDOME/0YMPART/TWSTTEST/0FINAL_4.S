;-------------------------------------------------------------------------------
TEST            EQU 0
                OUTPUT 'TWISTER.PRG'
;-------------------------------------------------------------------------------
SIN_MASK        EQU $00000FFE   ; 2048*2-2
COS             EQU $00000400   ; 2048/4*2
PI2             EQU 2048*2
;-------------------------------------------------------------------------------
; Arbitrary Twister   (w)lsl/checkpoint
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


FRAMES          EQU 32

                move.l  A0,sintab_adr

                OPT D-

                IFNE TEST
                OPT D+
                >PART ' init '

                clr.l   -(SP)
                move.w  #$0020,-(SP)
                trap    #1
                move    #$2700,SR
                lea     stack,SP
                clr.l   $FFFFFA06.w
                clr.l   $FFFFFA12.w

                bclr    #3,$FFFFFA17.w  ; auto eoi

                move.l  #vbl,$00000070.w
                move    #$2300,SR
                bsr     wait_vbl
                bsr     wait_vbl
                clr.b   $FFFF8260.w
                move.b  #2,$FFFF820A.w

                ENDPART
                ENDC

                bsr     wait_vbl

                lea     black,A0
                movem.l (A0),D0-D7
                movem.l D0-D7,$FFFF8240.w

*   DC.L $4AFC4E71

                IFNE TEST
                jsr     save_mfp
                jsr     DRIVER_INC
                ENDC


                lea     BSS_START,A0
                lea     BSS_END,A1
                bsr     memclr_a0_a1

                move.l  #screen_ram,D0
                clr.b   D0
                lea     screen0(PC),A0
                move.l  D0,(A0)+
                add.l   #32000+128*160,D0
                move.l  D0,(A0)+
                lsr.w   #8,D0
                move.l  D0,$FFFF8200.w
                bsr     wait_vbl

                lea     colors,A0
                movem.l (A0),D0-D7
*     movem.l D0-D7,$FFFF8240.w


                IFNE TEST
                bsr     init_sintab
                ENDC

                bsr     init_twister

                bsr     init_c2p

; multi-vbl effect template
; init
                bsr     wait_vbl
                bsr     swap_screens    ; SWAP SCREENS!!!
                move.l  #vbl_script,vbl_slot_first.w ; first executed vbl slot
                move.l  #vbl_effect,vbl_slot0.w
                bsr     wait_vbl

                IFEQ TEST
                rts
                ENDC

;-------------------------------------------------------------------------------
loop:
                IFNE TEST
                bsr     wait_vbl


                move.b  $FFFFFC02.w,D0
                cmp.b   #$39,D0
                bne     loop
                jsr     restore_mfp
                DC.L $4AFC4E71
                bra     loop
                ENDC

rte:            rte
rts:            rts

vbl_script:
                bsr     script_rout
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
script:         PART

                DC.L set_start_vals

                DC.L set_fade_speed,8
                DC.L fade,black,white_bg0

                DC.L MOVE_L,move_in_x_sub,script_sub0

                DC.L wait_fade

                DC.L set_fade_speed,8
                DC.L fade,white_bg0,colors
                DC.L wait_fade

                DC.L wait_ssub0

                DC.L WAIT,50

                DC.L rot_add_in

                DC.L set_vars_wx

                DC.L WAIT,3*50

                DC.L set_fade_speed,2
                DC.L fade,colors,white
                DC.L wait_fade

                DC.L set_vars_wx_inner

                DC.L WAIT,12

                DC.L set_fade_speed,1
                DC.L fade,white,colors
                DC.L wait_fade


                DC.L ST,wave_xy_pos_flag

                DC.L move_in_xy_pos_amp

                DC.L WAIT,8*50

                DC.L set_fade_speed,4
                DC.L fade,colors,red
                DC.L wait_fade

                DC.L set_fade_speed,2
                DC.L fade,red,black
                DC.L wait_fade

                DC.L ST,EFFECT_DONE_FLAG
                DC.L HALT


set_start_vals: >PART

                move.w  #-70*PI2/360,zr

                move.w  #-70,x_pos
                move.w  #(200-128)/2,y_pos
                move.l  A0,script_pos
                rts
                ENDPART
move_in_x_sub:  >PART
                lea     x_pos(PC),A1
                addi.w  #1,(A1)
                cmpi.w  #(160-64)/2,(A1)
                ble.s   mixM
                clr.l   script_sub0
mixM:
                rts
                ENDPART
wait_ssub0:     >PART
                move.l  script_sub0(PC),D0
                bne.s   ws0
                move.l  A0,script_pos
ws0:
                rts
                ENDPART

rot_add_in:     >PART
                lea     rot_add_inc(PC),A1 ; $111
                addi.l  #2,(A1)
                cmpi.l  #$00000111,(A1)
                ble.s   raiM
                move.l  A0,script_pos
raiM:
                rts
                ENDPART

set_vars_wx:    >PART
                move.w  #8*2*2,w0_inc
                move.w  #-12*2*2,w1_inc

                move.w  #-31*2,w2_inc
                move.w  #-33*2,w3_inc

                move.w  #-16*2,w4_inc
                move.w  #-14*2,w5_inc

                move.l  A0,script_pos
                rts
                ENDPART

set_vars_wx_inner:>PART
                lea     inc_w0_inner(PC),A1
                move.w  #4*2,(A1)+
                move.w  #-12*2,(A1)+
                move.w  #15*2,(A1)+
                move.w  #29*2,(A1)+
                move.l  A0,script_pos
                rts
                ENDPART

move_in_xy_pos_amp:>PART
                addi.w  #1,x_pos_amp    ;   DC.W 0          ; 60*4
                addi.w  #1,y_pos_amp    ;    DC.W 0          ; 60*4

                cmpi.w  #90*4,y_pos_amp
                ble.s   mixyM
                move.l  A0,script_pos
mixyM:
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
                rts
                ENDPART
wait_fade:      >PART
                lea     fade_scounter(PC),A1
                subq.w  #1,(A1)
                bpl.s   wfn
                move.w  fade_speed(PC),(A1)

                lea     fade_num(PC),A1
                move.w  (A1),D0
                bsr     fade_hw

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

white_bg0:      DC.W 0
                DS.W 15,$00000777

red:            DS.W 16,$00000703

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

wave_xy_pos_flag:DC.W 0


effect_rout:
                bsr     clear_old

                move.b  wave_xy_pos_flag(PC),D0
                beq.s   nwxyp
                bsr     wave_xy_pos
nwxyp:
                bsr     calc_twister_wave

                bsr     do_twister
                bsr     double_lines

                bsr     inc_w
                rts

vbl_effect:
; ---- CALL EFFECT ROUTINES HERE ----
                bsr     effect_rout
                bsr     swap_screens
                rts

SIZE            EQU 64

wave_xy_pos:    PART

                movea.l sintab_adr(PC),A0
                adda.w  w2(PC),A0
                move.w  (A0),D0

                movea.l sintab_adr(PC),A1
                adda.w  w4(PC),A1

                move.w  (A1),D1
                move.w  D1,D2
                sub.w   #$0909,D2
                muls    D1,D1
                asl.l   #2,D1
                swap    D1
                muls    D2,D1
                asl.l   #2,D1
                swap    D1

                muls    D1,D0
                asl.l   #2,D0
                swap    D0

*  muls    #60*4,D0
                muls    x_pos_amp(PC),D0
                swap    D0
                add.w   #(160-64)/2,D0
                move.w  D0,x_pos
;----------------------------------------------------
                movea.l sintab_adr(PC),A0
                adda.w  w3(PC),A0
                move.w  (A0),D0

                movea.l sintab_adr(PC),A1
                adda.w  w5(PC),A1

                move.w  (A1),D1
                move.w  D1,D2
                add.w   #$0303,D2
                muls    D1,D1
                asl.l   #2,D1
                swap    D1
                muls    D2,D1
                asl.l   #2,D1
                swap    D1

                muls    D1,D0
                asl.l   #2,D0
                swap    D0

*     muls    #60*4,D0
                muls    y_pos_amp(PC),D0
                swap    D0
                add.w   #(200-128)/2,D0
                move.w  D0,y_pos
                rts
                ENDPART

x_pos_amp:      DC.W 0          ; 60*4
y_pos_amp:      DC.W 0          ; 60*4

;-------------------------------------------------------------------------------
inc_w:          >PART
                moveq   #6-1,D0
                lea     w0(PC),A0
                lea     w0_inc(PC),A1
iwl:
                move.w  (A0),D1
                add.w   (A1)+,D1
                and.w   #SIN_MASK,D1
                move.w  D1,(A0)+
                dbra    D0,iwl
                rts
                ENDPART
                PART 'angles'
w0:             DC.W 0
w1:             DC.W 0
w2:             DC.W 0
w3:             DC.W 0
w4:             DC.W 0
w5:             DC.W 0

w0_inc:         DC.W 8*2*2*0    ; 6
w1_inc:         DC.W -12*2*2*0  ; 10

w2_inc:         DC.W -31*2*0
w3_inc:         DC.W -33*2*0

w4_inc:         DC.W -16*2*0
w5_inc:         DC.W -14*2*0
                ENDPART
;-------------------------------------------------------------------------------
swap_screens:   >PART
                move.l  screen1(PC),D0
                move.l  screen0(PC),screen1
                move.l  D0,screen0
                lsr.w   #8,D0
                move.l  D0,$FFFF8200.w
                rts

screen0:        DC.L 0
screen1:        DC.L 0

                ENDPART
vbl:            >PART

                movem.l D0-A6,-(SP)

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
init_c2p:       >PART

                move.l  #zero_base,D0
                clr.w   D0
                lea     c2p_adr(PC),A4
                move.l  D0,(A4)+        ;c2p_adr1
                add.l   #65536,D0
                move.l  D0,(A4)+        ;c2p_adr2

                bsr.s   init_c2p_8bit_mixed
                rts
                ENDPART
init_c2p_8bit_mixed:>PART

                movem.l c2p_adr(PC),A5-A6
c2p_mixed:
                moveq   #64-1,D7
c2pm_1:
                move.w  D7,-(SP)

                neg.w   D7
                add.w   #64-1,D7

                cmp.w   #15,D7
                ble.s   *+2
                moveq   #15,D7

                moveq   #64-1,D6
c2pm_2:
                move.w  D6,-(SP)

                neg.w   D6
                add.w   #64-1,D6

                cmp.w   #15,D6
                ble.s   *+2
                moveq   #15,D6

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
                move.l  D2,(A5)+
                lsr.l   #4,D2
                move.l  D2,(A6)+

                move.w  (SP)+,D6
                dbra    D6,c2pm_2

                move.w  (SP)+,D7

                lea     $0400-($0100)(A5),A5
                lea     $0400-($0100)(A6),A6
                dbra    D7,c2pm_1
                rts
                ENDPART
;-------------------------------------------------------------------------------

zr:             DC.W 0*45*2048*2/360

x_pos:          DC.W 0          ; -90        ; 64         ;    +16+1

x_pos_sub:      DC.W 0
x_pos_screen_offset:DC.W 0

y_pos:          DC.W 0
y_pos_screen_offset:DC.L 0

screen_pos_cube:DC.L 0


if:             DC.W 0
il:             DC.W 0

x_right         EQU 64+16
y_max           EQU 128

do_twister:

*  DC.L $4AFC4E71

                move.w  x_pos(PC),D0
                cmp.w   #-x_right,D0
                bge.s   xp0
                move.w  #-x_right,D0
xp0:
                cmp.w   #160,D0
                ble.s   xp1
                move.w  #160,D0
xp1:
                move.w  D0,x_pos

                move.w  y_pos(PC),D0
                cmp.w   #-y_max,D0
                bge.s   yp0
                move.w  #-y_max,D0
yp0:
                cmp.w   #y_max,D0
                ble.s   yp1
                move.w  #y_max,D0
yp1:
                move.w  D0,y_pos


                bsr     setup_x_clip

                move.w  x_pos(PC),D0
                moveq   #7,D1
                and.w   D0,D1
                move.w  D1,x_pos_sub

                and.w   #-8,D0
                move.w  D0,x_pos_screen_offset

                move.w  y_pos(PC),D1
                muls    #160,D1

                movea.l screen1(PC),A0
                adda.w  D0,A0
                adda.l  D1,A0
                move.l  A0,cold_ptr
                move.l  A0,screen_pos_cube


                bsr     do_twister_frame ; twist it & copy to 128x128 buffer

                bsr     output_ZR

*  addi.w  #16*2,zr
                addi.w  #9*2,zr

                andi.w  #SIN_MASK,zr

                rts

calc_twister_wave:PART

                movea.l sintab_adr,A0
                lea     twister_frametable,A1

                lea     twister_y_gfxlist,A2 ; OUTPUT

                movem.w w0(PC),D0-D3
                move.w  #SIN_MASK,D6

                movea.l rot_add(PC),A6

                REPT 64
                and.w   D6,D0
                and.w   D6,D1
                and.w   D6,D2
                and.w   D6,D3

                movem.w 0(A0,D0.w),D4

                movem.w 0(A0,D1.w),D5
                asr.l   #1,D5
                add.l   D5,D4

                movem.w 0(A0,D2.w),D5
                asr.l   #3,D5
                add.l   D5,D4

                add.l   A6,D4



;  asl.l   #2+7,D4
;  swap    D4
                asr.l   #7,D4

                and.w   #31*4,D4
                move.l  0(A1,D4.w),(A2)+

*    add.w   #4*2,D0
*    add.w   #-12*2,D1
*    add.w   #15*2,D2
*    add.w   #29*2,D3

                lea     inc_w0_inner(PC),A5
                add.w   (A5)+,D0
                add.w   (A5)+,D1
                add.w   (A5)+,D2
                add.w   (A5)+,D3

                ENDR

*   addi.l  #$00000111,rot_add

                move.l  rot_add_inc(PC),D0
                add.l   D0,rot_add

                rts
                ENDPART
Q:
inc_w0_inner:   DC.W 0          ;   4*2
inc_w1_inner:   DC.W 0          ; -12*2
inc_w2_inner:   DC.W 0          ;  15*2
inc_w3_inner:   DC.W 0          ;  29*2

rot_add:        DC.L 0
rot_add_inc:    DC.L 0          ; $111


do_twister_frame:>PART

ox              SET ((128-64)/2)
oy              SET ((128-64)/2)*128

;;  lea     twister_64_64_data,A2

                lea     field_128_128+ox+oy,A3

o               SET 0
oy              SET 0
oout            SET 0
                REPT 64
                movea.l twister_y_gfxlist+o(PC),A2
                lea     oy(A2),A2
                movem.l (A2)+,D0-D6/A0-A1 ; 9*4 = 36
                movem.l D0-D6/A0-A1,oout(A3)
                movem.l (A2)+,D0-D6     ;   7*4 = 28
                movem.l D0-D6,oout+36(A3)
o               SET o+4
oy              SET oy+64
oout            SET oout+128
                ENDR
                rts

                ENDPART

output_ZR:      >PART

;;   DC.L $4AFC4E71


                bsr     setup_zr

                movem.l c2p_adr,D4-D5

                movea.l screen_pos_cube(PC),A1
                adda.w  il(PC),A1

; x = x*cos + y*sin
; y ' y*cos - x*sin

                movem.w zsin(PC),D6
                move.w  #-32*4,D0
                muls    D6,D0
                asl.l   #2,D6
                move.l  D6,D2

                movem.w zcos(PC),D6
                move.w  #-32*4,D1
                muls    D6,D1
                asl.l   #2,D6
                move.l  D6,D3

                add.l   #$00008000,D0
                add.l   #$00008000,D1

                lea     screen_ram-4096,A3 ; x clip

                move.w  #64-1,-(SP)
ozr_y:
ox              SET (128/2)     ;   ((128-64)/2)
oy              SET (128/2)*128 ;   ((128-64)/2)*128
                lea     field_128_128+ox+oy,A0

                move.l  D0,D6
                swap    D6
                adda.w  D6,A0

                move.l  D1,D6
                swap    D6
                asl.w   #7,D6
                adda.w  D6,A0

                add.l   D2,D0
                add.l   D3,D1

xo              SET 0
xi              SET 1
ozr_inner:

; free:
; d0,d1,d2,d3, a3

; used:
; d4,d5,d6  a0,a1,a2

                REPT (64+16)/4

                movep.w 'dj'(A0),D4
                move.b  'dj'(A0),D4
                movep.w 'dj'(A0),D5
                move.b  'dj'(A0),D5     ; 16 bytes

                movea.l D4,A2
                move.l  (A2),D6
                movea.l D5,A2
                or.l    (A2),D6
                movep.l D6,xo(A1)       ; 12 bytes

xo              SET xo+xi
xi              SET xi^6
                ENDR

                lea     2*160(A1),A1
                subq.w  #1,(SP)
                bpl     ozr_y
                addq.l  #2,SP
                rts
                ENDPART



setup_x_clip:   >PART

; restore normal
                lea     ozr_inner+16+12-4(PC),A0
                move.w  x_ok(PC),D0
o               SET 0
                REPT (64+16)/4
                move.w  D0,o(A0)
o               SET o+16+12
                ENDR

                move.w  x_pos(PC),D0
                bpl.s   ClipRight_check
ClipLeft_check:
                neg.w   D0
                move.w  D0,D2
                cmp.w   #(64+16),D0
                ble.s   left_ok
; total out
                move.w  #(64+16),D0
left_ok:
                addq.w  #7,D0
;  lsr.w   #3,D0
;  lsl.w   #3,D0
                and.w   #-8,D0

                lsr.w   #2,D0
                move.w  D0,D1

                cmp.w   #(64+16)/4-1,D1
                ble.s   lok
                move.w  #(64+16)/4-1,D1
lok:
                lea     ozr_inner+16+12-4(PC),A0
                move.w  x_clip(PC),D0
set_clip_left:
                move.w  D0,(A0)
                lea     16+12(A0),A0
                dbra    D1,set_clip_left
                rts

ClipRight_check:
                cmp.w   #x_right,D0
                ble.s   no_clip_right

                sub.w   #x_right,D0

                cmp.w   #(64+16),D0
                ble.s   right_ok
; total out
                move.w  #(64+16),D0
right_ok:
                and.w   #-8,D0

                lsr.w   #2,D0

                subq.w  #1,D0
                bpl.s   *+2
                moveq   #0,D0

                move.w  D0,D1

                neg.w   D0
                add.w   #(64+16)/4-1,D0

                mulu    #16+12,D0
                lea     ozr_inner+16+12-4(PC),A0
                adda.w  D0,A0
                move.w  x_clip(PC),D0
set_clip_right:
                move.w  D0,(A0)
                lea     16+12(A0),A0
                dbra    D1,set_clip_right
                rts
no_clip_right:
                rts

x_ok:           movep.l D6,0(A1)
x_clip:         movep.l D6,0(A3)
                ENDPART


setup_zr:       >PART

; clear offsets (lame, can be optimized)
                lea     ozr_inner+2(PC),A3
                move.w  #64+64*128,D0   ; empty area
o               SET 0
x               SET 0
                REPT 64+16
                move.w  D0,o(A3)
o               SET o+4
x               SET x+1
                IF x=4
o               SET o+12
x               SET 0
                ENDC
                ENDR


*  DC.L $4AFC4E71

                movea.l sintab_adr,A0
                move.w  zr(PC),D0
                and.w   #SIN_MASK,D0
                adda.w  D0,A0
                move.w  (A0),zsin
                move.w  COS(A0),zcos

; x = x*cos + y*sin
; y ' y*cos - x*sin

                movem.w zcos(PC),D6
                move.w  #-32*4,D0
                muls    D6,D0
                asl.l   #2,D6
                movea.l D6,A0

                movem.w zsin(PC),D6
                neg.l   D6
                move.w  #-32*4,D1
                muls    D6,D1
                asl.l   #2,D6
                movea.l D6,A1

                add.l   #$00008000,D0
                add.l   #$00008000,D1

                lea     ozr_inner+2(PC),A3

                lea     offset_list(PC),A2
                move.w  x_pos_sub(PC),D2
                add.w   D2,D2
                adda.w  D2,A2

                REPT 64         ;     64+16

                move.l  D0,D2
                swap    D2

                move.l  D1,D3
                swap    D3
                asl.w   #7,D3

                add.w   D3,D2

                move.w  (A2)+,D3        ; offset_list:
                move.w  D2,0(A3,D3.w)

                add.l   A0,D0
                add.l   A1,D1

                ENDR
                rts
zsin:           DC.W 0
zcos:           DC.W 0
                ENDPART

offset_list:
o               SET 0
x               SET 0
                REPT 64+16
                DC.W o
o               SET o+4
x               SET x+1
                IF x=4
o               SET o+12
x               SET 0
                ENDC
                ENDR


twister_frametable:DS.L 32

twister_y_gfxlist:DS.L 64


;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
init_twister:   >PART

;;  DC.L $4AFC4E71


                bsr     init_twister_gfx ; PREPROCESS IN FINAL!!

                bsr     init_twister_frametable

                rts
                ENDPART

init_twister_gfx:>PART
                lea     twister_64_64_data,A0
                moveq   #2,D5
                move.w  #FRAMES*64-1,D6 ;
itw_gfx:
                REPT 64/4
                move.l  (A0),D0
                lsl.l   D5,D0
                move.l  D0,(A0)+
                ENDR
                dbra    D6,itw_gfx
                rts
                ENDPART

init_twister_frametable:>PART
                lea     twister_64_64_data,A0
                lea     twister_frametable,A1
                moveq   #32-1,D6
itfl:
                move.l  A0,(A1)+
                lea     64*64(A0),A0
                dbra    D6,itfl
                rts
                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

double_lines:   >PART

**  DC.L $4AFC4E71

*  movea.l screen1(PC),A3

                movea.l screen_pos_cube(PC),A3

; 128pix + 16 = 144 pix
; 144/2 = 72 bytes

                REPT 64
                movem.l (A3)+,D0-D6/A0-A2 ; 10*4 = 40 bytes
                movem.l D0-D6/A0-A2,160-40(A3)
                movem.l (A3)+,D0-D6/A0  ; 8*4 = 32 bytes
                movem.l D0-D6/A0,160-32(A3)
o               SET 2*160-72
                lea     o(A3),A3
                ENDR
                rts
                ENDPART

cold_ptr:       DC.L 0,0

clear_old:      >PART

                movem.l cold_ptr(PC),D0-D1
                exg     D0,D1
                movem.l D0-D1,cold_ptr
                tst.l   D0
                beq     noco
                movea.l D0,A3

                movem.l zero,D0-D6/A0-A2 ; 10*4 = 40 bytes

* movea.l screen1(PC),A3

; 128pix + 16 = 144 pix
; 144/2 = 72 bytes

o               SET 0
                REPT 64
                movem.l D0-D6/A0-A2,o(A3)
                movem.l D0-D6/A0,o+40(A3)
o               SET o+160
                movem.l D0-D6/A0-A2,o(A3)
                movem.l D0-D6/A0,o+40(A3)
o               SET o+160
                ENDR
noco:
                rts
                ENDPART


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

                IFNE TEST
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

                movea.l screen1,A0

                lea     (A0),A1
                lea     (A0),A2
                lea     (A0),A3
                lea     (A0),A4
                lea     (A0),A5
                lea     (A0),A6

                lea     $FFFF8800.w,A6

                lea     es(PC),A2

                move.w  #$0123,D0
                move.w  #$0023,D1

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

                mulu    D1,D0           ; 11

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
                ENDC
;-------------------------------------------------------------------------------

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

                DATA

sintab_adr:     DC.L 0

c2p_adr:        DC.L 0,0

colors:         >PART
                DC.W $0000      ;            0 ;

                DC.W $0110      ;    0       1 ;
                DC.W $0210      ;   1        2 ;
                DC.W $0310      ;   10       3 ;
                DC.W $0410      ;  2         4 ;
                DC.W $0510      ;  2 0       5 ;
                DC.W $0610      ;  21        6 ;
                DC.W $0710      ;  210       7 ;
                DC.W $0711      ; 3          8 ;
                DC.W $0712      ; 3  0       0 ;
                DC.W $0723      ; 3 1       10 ;
                DC.W $0734      ; 3 10      11 ;
                DC.W $0745      ; 32        12 ;
                DC.W $0756      ; 32 0      13 ;
                DC.W $0767      ; 321       14 ;
                DC.W $0777      ; 3210      15 ;

                ENDPART

black:
zero:           DS.L 16

;-------------------------------------------------------------------------------

                PATH 'C:\0NEW\TDOME\0YMPART\'
                PATH 'TWSTTEST\PC\'
                PATH 'ARBFIN\'
twister_64_64_data:
                IBYTES 'TWST_ARB.DAT'

                IFNE TEST
;-------------------------------------------------------------------------------
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


;-------------------------------------------------------------------------------
                BSS

                IFNE TEST
                DS.B 512
stack:          DS.B 2

sintab:         DS.W 2*2048
                ENDC

BSS_START:      DS.B 2

field_128_128:  DS.B 128*128
                DS.B 32*128     ; empty area

                DS.B 256
                DS.B 128*160    ; clip
screen_ram:
                DS.B 32000
                DS.B 128*160    ; clip
                DS.B 32000
                DS.B 128*160    ; clip

BSS_END:        DS.B 2

                DS.L 65536/4    ;; FOR A 65536 BOUNDARY!!
zero_base:
                DS.L 65536/4    ;C2P_7654
                DS.L 65536/4    ;C2P_3210
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
                END
