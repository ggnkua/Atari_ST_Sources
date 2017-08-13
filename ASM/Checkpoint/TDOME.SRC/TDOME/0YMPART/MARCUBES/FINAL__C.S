;-------------------------------------------------------------------------------
; realtime marching cubes on Atari ST
; (w)2014 lsl/checkpoint
;-------------------------------------------------------------------------------
TEST            EQU 1
                OUTPUT 'MARCUBES.PRG'
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

PARTDIV_BITS    EQU 4           ; descale bits for partial division
;-------------------------------------------------------------------------------
;
; 4X4____3.SRC ... optimized texture-mapper (bringt aber nicht viel!!)
;                  addx.l addx.w muss noch in RENDER_TRI rein
;
; marching halfed --> previous z-plane bitcode
;
; normals only calculated if not done, otherwise copy
;
;-------------------------------------------------------------------------------
                >PART ' 32/16 partial division '
*  move.l  #3000*128,D0
; 32bit/16bit partial division
                move.l  #3124*128,D0
                move.l  #3,D1
                divu    D1,D0
                bvc.s   divok_test
                move.l  D0,D2           ; dividend_temp
                lsr.l   #PARTDIV_BITS,D0 ; dividend/4 DESCALE
                divu    D1,D0
                move.w  D0,D3           ; res0
                mulu    D1,D3           ; res0*divisor
                lsl.l   #PARTDIV_BITS,D3 ; UPSCALE
                sub.l   D3,D2           ; divident_temp-res0

                divu    D1,D2           ;
                and.l   #$0000FFFF,D2
                and.l   #$0000FFFF,D0
                lsl.l   #PARTDIV_BITS,D0 ; UPSCALE
                add.l   D2,D0
divok_test:
                ENDPART
;-------------------------------------------------------------------------------
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
                >PART ' trimapper comments '
*
* TRIANGLE POLYGON FILLING                                          'defjam`2000
*   ... faster ... nicer ...
*
***** THIS ONE: 128x128 Texture -  bcos. having env-mapping with
*                                  multiple lightsources in mind!
*

; Torus converted to run in here ...
; but some bugs.  check the normalvectors stuff!
** --> Normalvectors in TORUS.NOR seem to be CRAP!!
** --> using calc_normals --> the result is OK!
                ENDPART

*      lea     trashmem,A0
*      move.w  #16384,D7
*tm:
*              move.l  #$01010101,(A0)+
*              dbra    D7,tm


                bra     crt0
;-------------------------------------------------------------------------------
SIN_MASK        SET $0FFE       ; 2048*2-2
COS             SET $0400       ; 2048/4*2
;-------------------------------------------------------------------------------
CRAM_X          SET 80
CRAM_Y          SET 50
CRAM_X_line     SET 256
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
; Marching cube equ's
GRID_X          EQU 160         ;  160-32      ; 160+64      ; 64+16       ; 48
GRID_Y          EQU 160         ;  160         ; 160+64
GRID_Z          EQU 160         ;160         ; 160+64      ; 64+16       ; 48

XM              EQU 12          ;12
YM              EQU 8           ; 6
ZM              EQU 8           ; 8

;-------------------------------------------------------------------------------
AMOUNT_BLOBS    EQU 5
;-------------------------------------------------------------------------------
isoc:
                DC.W 4096
crt0:
                move.l  A0,sintab_adr

                OPT D-
                IFNE TEST
                OPT D+
                >PART ' init machine ... '
                clr.l   -(SP)
                move.w  #$0020,-(SP)
                trap    #1
                lea     stack,SP
                move    #$2700,SR
                clr.l   $FFFFFA06.w
                clr.l   $FFFFFA12.w
                bclr    #3,$FFFFFA17.w

                clr.l   vbl_slot_first.w ; first executed vbl slot

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

                bsr     wait_vbl

                lea     BSS_START,A0
                lea     BSS_END,A1
                bsr     memclr

                bsr     wait_vbl

                move.l  #scr_ram,D0
                clr.b   D0
                move.l  D0,D1
                add.l   #32000,D0
                movem.l D0-D1,screen0
                lsr.w   #8,D1
                move.l  D1,$FFFF8200.w

                bsr     wait_vbl


                move.l  #zero_base,D0
                clr.w   D0
                lea     c2p_adr,A4
                move.l  D0,(A4)+        ;c2p_adr1
                add.l   #65536,D0
                move.l  D0,(A4)+        ;c2p_adr2
                add.l   #65536,D0

                add.l   #65536,D0       ; top tex
                move.l  D0,texture_adr

*   jsr     instr_cycle     ********************************


                move.l  #script_intro,script_pos
                jsr     init_marching_intro

                bsr     init_c2p_44

;------------------------------------------------------------
; Init Marching Cubes stuff

                bsr     init_march_tables
                bsr     init_1_15_divtable

                bsr     init_square_table
                bsr     init_normalize_table
                bsr     init_blob_strength_tab

                bsr     init_iso_xyz    ; init grid units
                jsr     init_blobs
                bsr     init_zf_table

                bsr     init_texturemapper

;------------------------------------------------------------

                IFNE TEST
                bsr     init_sintab
                ENDC

                lea     bmp,A0
                jsr     read_bmp_texture


                jsr     wait_intro_done
                move.l  #script,script_pos

                bsr     wait_vbl


                move.l  #vbl_script,vbl_slot_first.w ; first executed vbl slot
                bsr     wait_vbl
loop:
                bsr     swap_screens
                bsr     wait_vbl

                move.l  texture_adr,D0
                swap    D0
                move.w  D0,2+tex_adr0
                move.w  D0,2+tex_adr1


;;   clr.w   tri_count

*    DC.L $4AFC4E71

                bsr     clear_colorram

                bsr     set_isoc_values ; code modi for imm. isoc read

                bsr     normals_used_clear


                move.l  isomethod(PC),D0
                beq.s   *+4
                movea.l D0,A0
                jsr     (A0)


                bsr     MarchingCube    ; main routine

                bsr     output_colorram44

                bsr     do_all_inc_winkels

                IFEQ TEST
                move.b  EFFECT_DONE_FLAG.w,D0
                beq.s   loop
                rts
                ENDC
;----------------------------------------------------
;----------------------------------------------------
;----------------------------------------------------
                move.b  EFFECT_DONE_FLAG.w,D0
                beq.s   loop_nend
                jsr     restore_mfp
                DC.L $4AFC4E71
loop_nend:
                move.w  #$0040,D1
                move.b  $FFFFFC02.w,D0
                cmp.b   #$3B,D0
                bne.s   nf1
                sub.w   D1,isoc
nf1:
                cmp.b   #$3C,D0
                bne.s   nf2
                add.w   D1,isoc
nf2:
                cmp.b   #$39,D0
                bne     loop
                jsr     restore_mfp
                DC.L $4AFC4E71

*   move.w  #$1100,isoc

                bra     loop

blobs_move_flag:DC.W 0

isomethod:
                DC.L set_isosurface_blobs ; set blobs
*  bsr     set_isosurface_algebra


vbl_script:
                bsr.s   script_rout
                rts
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
script_rout:    PART

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

script_sub_fade:
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
script:         PART

*   DC.L GOTO,algebraic_start


                DC.L set_start_vals_blobs

                DC.L set_fade_speed,24
                DC.L fade,white,colors

                DC.L move_in_blobs

                DC.L wait_fade

*   DC.L WAIT,10

                DC.L ST,blobs_move_flag

                DC.L WAIT,20*50

                DC.L set_fade_speed,4
                DC.L fade,colors,black
                DC.L wait_fade

                DC.L SF,blobs_move_flag

*     DC.L ST,rotate_blobs_flag

                DC.L ST,inc_winkels_flag

algebraic_start:
                DC.L ST,inc_winkels_flag
                DC.L set_start_vals_algebrac

                DC.L set_fade_speed,8
                DC.L fade,black,colors
                DC.L wait_fade

                DC.L alg_in

                DC.L WAIT,10*50

                DC.L alg_out

*    DC.L ILL

                DC.L ST,EFFECT_DONE_FLAG
                DC.L HALT

                ENDPART

set_start_vals_algebrac:
                move.w  descnop(PC),descale_norm
                move.w  #$4E71,vis_check_cond

                move.w  #$3800,isoc     ; $5000

                move.w  #$0800,ztrans
                move.l  #set_isosurface_algebra,isomethod
                move.l  A0,script_pos
                rts
descnop:
                lsr.w   #1,D4

alg_in:
                lea     ztrans,A1
                addi.w  #8,(A1)         ; 15
                move.w  #2000*2,D0
                cmp.w   (A1),D0
                bge.s   ai0
                move.w  D0,(A1)
ai0:
                lea     isoc,A1
                subi.w  #2,(A1)         ; 10
                cmpi.w  #$3080,(A1)
                bge.s   aiM
                move.l  A0,script_pos
aiM:
                rts
alg_out:
                lea     ztrans,A1
                subi.w  #30,(A1)
                move.w  #$0600,D0
                cmp.w   (A1),D0
                ble.s   ao0
                move.w  D0,(A1)
ao0:
                lea     isoc,A1
                addi.w  #50,(A1)
                cmpi.w  #$5900-$0400,(A1)
                ble.s   aoM
                move.l  A0,script_pos
aoM:
                rts



set_start_vals_blobs:
                move.w  #-200*2,ztrans
                move.l  A0,script_pos
                rts
move_in_blobs:
                lea     ztrans,A1
                addi.w  #20*2,(A1)
                cmpi.w  #1600*2,(A1)
                ble.s   mibM
                move.l  A0,script_pos
mibM:
                rts

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
                ble.s   wfn2
                move.w  #8,(A1)
                clr.l   fade_sub
wfn2:
                rts
                ENDPART
wait_fade:      >PART

                move.l  fade_sub(PC),D0
                bne.s   wfn
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


;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

AEXT_BITS       SET 6           ;7
AEXT            SET 1<<AEXT_BITS

set_isosurface_algebra:>PART

                bsr     sia_matrix

                bsr     convert_matrix

                bsr     set_x_coeff
                bsr     set_y_coeff
                bsr     set_z_coeff

*    DC.L $4AFC4E71

                bsr     algebraic_main

*   DC.L $4AFC4E71

                rts
                ENDPART

al:
algebraic_main: PART

*  DC.L $4AFC4E71

                lea     iso_array,A6    ; output
; A0,A1,A2
; A3,A4,A5

; D0,D1,D2
; D3,D4,D5
; D6,D7
                moveq   #AEXT_BITS,D7

                lea     z_coeff,A0
                move.w  #ZM-1,-(SP)
am_z:
                move.l  (A0)+,zx        ; zx
                move.l  (A0)+,zy        ; zy
                move.l  (A0)+,zz        ; zz

                lea     y_coeff,A1
                move.w  #YM-1,-(SP)
am_y:
                movea.l (A1)+,A3        ; yx
                movea.l (A1)+,A4        ; yy
                movea.l (A1)+,A5        ; yz
                adda.l  zx,A3           ; +zx
                adda.l  zy,A4           ; +zy
                adda.l  zz,A5           ; +zz

                lea     x_coeff,A2
                REPT XM
                move.l  (A2)+,D0        ; xx
                move.l  (A2)+,D1        ; xy
                move.l  (A2)+,D2        ; xz
                add.l   A3,D0
                add.l   A4,D1
                add.l   A5,D2
                swap    D0
                swap    D1
                swap    D2

; iso = x*x + y*y - x*x*z + y*y*z + z*z

                muls    D0,D0           ; x*x
                muls    D1,D1           ; y*y

                move.l  D0,D3
                asr.l   D7,D3           ; AEXT_BITS
                muls    D2,D3           ; x*x*z

                move.l  D1,D4
                asr.l   D7,D4           ; AEXT_BITS
                muls    D2,D4           ; y*y*z

                muls    D2,D2           ; z*z

                add.l   D1,D0           ; x*x + y*y
                sub.l   D3,D0           ; x*x + y*y - x*x*z
                add.l   D4,D0           ; x*x + y*y - x*x*z + y*y*z
                add.l   D2,D0           ; x*x + y*y - x*x*z + y*y*z + z*z

*   asr.l   D7,D0           ; AEXT_BITS
*   asr.l   #1,D0
*   add.w   #16000,D0       ; <-- can be changed!

                asr.l   D7,D0           ; AEXT_BITS
*    asr.l   #2,D0

                add.w   #$3000,D0

                move.w  D0,(A6)+        ; iso out

                ENDR
Q:
                subq.w  #1,(SP)
                bpl     am_y
                addq.l  #2,SP

                subq.w  #1,(SP)
                bpl     am_z
                addq.l  #2,SP

                rts

                ENDPART

zx:             DC.L 0
zy:             DC.L 0
zz:             DC.L 0

SCL             SET 2+6

set_x_coeff:    >PART

                lea     x_coeff,A6

*  moveq   #AEXT_BITS+2,D6

                moveq   #SCL,D6

                move.w  #(-XM/2),D7     ; xs

                lea     final_matrix,A5
                move.l  (0*3+0)*4(A5),D0 ; xx
                move.l  (1*3+0)*4(A5),D1 ; xy
                move.l  (2*3+0)*4(A5),D2 ; xz
                move.l  D0,D3
                move.l  D1,D4
                move.l  D2,D5

                asl.l   D6,D3           ; AEXT_BITS
                asl.l   D6,D4           ; AEXT_BITS
                asl.l   D6,D5           ; AEXT_BITS

                muls    D7,D0           ; *xs
                muls    D7,D1           ; *xs
                muls    D7,D2           ; *xs

                asl.l   D6,D0           ; AEXT_BITS
                asl.l   D6,D1           ; AEXT_BITS
                asl.l   D6,D2           ; AEXT_BITS

                REPT XM
                move.l  D0,(A6)+
                move.l  D1,(A6)+
                move.l  D2,(A6)+
                add.l   D3,D0
                add.l   D4,D1
                add.l   D5,D2
                ENDR
                rts
                ENDPART
set_y_coeff:    >PART
                lea     y_coeff,A6

*   moveq   #AEXT_BITS+2,D6
                moveq   #SCL,D6

                move.w  #(-YM/2),D7     ; xs

                lea     final_matrix,A5
                move.l  (0*3+1)*4(A5),D0 ; yx
                move.l  (1*3+1)*4(A5),D1 ; yy
                move.l  (2*3+1)*4(A5),D2 ; yz
                move.l  D0,D3
                move.l  D1,D4
                move.l  D2,D5

                asl.l   D6,D3           ; AEXT_BITS
                asl.l   D6,D4           ; AEXT_BITS
                asl.l   D6,D5           ; AEXT_BITS

                muls    D7,D0           ; *ys
                muls    D7,D1           ; *ys
                muls    D7,D2           ; *ys

                asl.l   D6,D0           ; AEXT_BITS
                asl.l   D6,D1           ; AEXT_BITS
                asl.l   D6,D2           ; AEXT_BITS

                REPT YM
                move.l  D0,(A6)+
                move.l  D1,(A6)+
                move.l  D2,(A6)+
                add.l   D3,D0
                add.l   D4,D1
                add.l   D5,D2
                ENDR
                rts
                ENDPART
set_z_coeff:    >PART
                lea     z_coeff,A6

*    moveq   #AEXT_BITS+2,D6
                moveq   #SCL,D6
                move.w  #(-ZM/2),D7     ; xs

                lea     final_matrix,A5
                move.l  (0*3+2)*4(A5),D0 ; zx
                move.l  (1*3+2)*4(A5),D1 ; zy
                move.l  (2*3+2)*4(A5),D2 ; zz
                move.l  D0,D3
                move.l  D1,D4
                move.l  D2,D5

                asl.l   D6,D3           ; AEXT_BITS
                asl.l   D6,D4           ; AEXT_BITS
                asl.l   D6,D5           ; AEXT_BITS

                muls    D7,D0           ; *zs
                muls    D7,D1           ; *zs
                muls    D7,D2           ; *zs

                asl.l   D6,D0           ; AEXT_BITS
                asl.l   D6,D1           ; AEXT_BITS
                asl.l   D6,D2           ; AEXT_BITS

                REPT ZM
                move.l  D0,(A6)+
                move.l  D1,(A6)+
                move.l  D2,(A6)+
                add.l   D3,D0
                add.l   D4,D1
                add.l   D5,D2
                ENDR
                rts
                ENDPART

final_matrix:   DS.L 3*3

x_coeff:        DS.L XM*3
y_coeff:        DS.L YM*3
z_coeff:        DS.L ZM*3

convert_matrix: >PART
                lea     matrix,A0
                lea     final_matrix,A1
                REPT 3
                movem.w (A0)+,D0-D2
                move.l  D0,(A1)+
                move.l  D1,(A1)+
                move.l  D2,(A1)+
                ENDR
                rts
                ENDPART

                >PART ' matrix example '

                lea     matrix(PC),A6

                move.w  (A0)+,D0        ;x
                move.w  (A0)+,D1        ;y
                move.w  (A0)+,D2        ;z

                move.w  D0,D3
                move.w  D1,D4
                move.w  D2,D5

                muls    (A6)+,D0        ;x_x
                muls    (A6)+,D1        ;x_y
                muls    (A6)+,D2        ;x_z
                add.l   D1,D0
                add.l   D2,D0
                swap    D0


                move.w  D3,D6
                move.w  D4,D1
                move.w  D5,D2

                muls    (A6)+,D6        ;y_x
                muls    (A6)+,D1        ;y_y
                muls    (A6)+,D5        ;y_z
                add.l   D6,D1
                add.l   D5,D1
                swap    D1


                muls    (A6)+,D3        ;z_x
                muls    (A6)+,D4        ;z_y
                muls    (A6)+,D2        ;z_z
                add.l   D3,D2
                add.l   D4,D2
                swap    D2

                ENDPART

sia_matrix:     PART

                lea     sinx(PC),A5

                movea.l sintab_adr,A6
                adda.w  xr(PC),A6
                move.w  (A6),(A5)+      ;sinx
                move.w  COS(A6),(A5)+   ;cosx

                movea.l sintab_adr,A6
                adda.w  yr(PC),A6
                move.w  (A6),(A5)+      ;siny
                move.w  COS(A6),(A5)+   ;cosy

                movea.l sintab_adr,A6
                adda.w  zr(PC),A6
                move.w  (A6),(A5)+      ;sinz
                move.w  COS(A6),(A5)+   ;cosz

                lea     matrix,A6
                bsr     set_matrix_yxz

                rts

                lea     matrix(PC),A6

                move.w  (A0)+,D0        ;x
                move.w  (A0)+,D1        ;y
                move.w  (A0)+,D2        ;z

                move.w  D0,D3
                move.w  D1,D4
                move.w  D2,D5

                muls    (A6)+,D0        ;x_x
                muls    (A6)+,D1        ;x_y
                muls    (A6)+,D2        ;x_z
                add.l   D1,D0
                add.l   D2,D0
                swap    D0


                move.w  D3,D6
                move.w  D4,D1
                move.w  D5,D2

                muls    (A6)+,D6        ;y_x
                muls    (A6)+,D1        ;y_y
                muls    (A6)+,D5        ;y_z
                add.l   D6,D1
                add.l   D5,D1
                swap    D1


                muls    (A6)+,D3        ;z_x
                muls    (A6)+,D4        ;z_y
                muls    (A6)+,D2        ;z_z
                add.l   D3,D2
                add.l   D4,D2
                swap    D2


set_matrix_yxz:
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
                move.w  D0,(A6)+        ;x_x

                move.w  cosx(PC),D0     ;y * -cosx*sinz
                muls    sinz(PC),D0
                asl.l   #2,D0
                neg.l   D0
                swap    D0
                move.w  D0,(A6)+        ;x_y

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
                move.w  D0,(A6)+        ;x_z
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
                move.w  D0,(A6)+        ;y_x

                move.w  cosx(PC),D0     ;y * cosx*cosz
                muls    cosz(PC),D0
                asl.l   #2,D0
                swap    D0
                move.w  D0,(A6)+        ;y_y

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
                move.w  D0,(A6)+        ;y_z
;;;;
                move.w  siny(PC),D0     ;x * -siny*cosx
                muls    cosx(PC),D0
                asl.l   #2,D0
                neg.l   D0
                swap    D0
                move.w  D0,(A6)+        ;z_x

                move.w  sinx(PC),D0     ;y * sinx
                move.w  D0,(A6)+        ;z_y

                move.w  cosy(PC),D0     ;z * cosy*cosx
                muls    cosx(PC),D0
                asl.l   #2,D0
                swap    D0
                move.w  D0,(A6)+        ;z_z
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

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------


set_isoc_values:>PART
                move.w  isoc(PC),D0
                move.w  D0,isoc_set0+2
                move.w  D0,isoc_set1+2
                rts
                ENDPART

swap_screens:   >PART
                move.l  screen1,D0
                move.l  screen0,screen1
                move.l  D0,screen0
                lsr.w   #8,D0
                move.l  D0,$FFFF8200.w
                rts
                ENDPART

inc_winkels_flag:DC.W 0
do_all_inc_winkels:>PART
                lea     xr,A0
                lea     xr_inc,A1
                moveq   #6-1,D0
                bsr     inc_winkels
                rts
                ENDPART
inc_winkels:    >PART

                move.b  inc_winkels_flag(PC),D7
                beq.s   no_iw

                move.w  #SIN_MASK,D7
iwl:
                move.w  (A0),D1         ; value
                add.w   (A1)+,D1        ; inc
                and.w   D7,D1           ; SIN_MASK
                move.w  D1,(A0)+

                dbra    D0,iwl
no_iw:
                rts
                ENDPART
                PART ' Winkel '
xr:             DC.W 0
yr:             DC.W 0
zr:             DC.W 0
w0:             DC.W 0
w1:             DC.W 0
w2:             DC.W 0

xr_inc:         DC.W 58*2
yr_inc:         DC.W -42*2
zr_inc:         DC.W 34*2

w0_inc:         DC.W 32*2
w1_inc:         DC.W 39*2
w2_inc:         DC.W 42*2
                ENDPART


do_object:      >PART
                move.w  (A0)+,D7        ;amount faces
                subq.w  #1,D7
object_faces:
                movea.l (A0)+,A4
                movem.l (A4),A1-A3
                movem.w (A1),D0-D1      ;y1 x1
                movem.w (A2),D2-D3      ;y2 x2
                movem.w (A3),D4-D5      ;y3 x3

                sub.w   D1,D3           ;x2-x1
                sub.w   D1,D5           ;x3-x1
                sub.w   D0,D2           ;y2-y1
                sub.w   D0,D4           ;y3-y1

                muls    D2,D5           ;(y2-y1) * (x3-x1)
                muls    D3,D4           ;(x2-x1) * (y3-y1)
                sub.l   D4,D5
                bpl.s   fl„che_nicht_sichtbar_p

                movem.l D7-A0,-(SP)

                pea     (A4)
                bsr     TRI_MAP
                movea.l (SP)+,A4

                movea.l (A4)+,A1
                movem.l 4(A4),A2-A3
                bsr     TRI_MAP

                movem.l (SP)+,D7-A0
fl„che_nicht_sichtbar_p:
                dbra    D7,object_faces
                rts
                ENDPART

RECT_MAP:       >PART
                pea     (A0)
                movem.l (A0),A1-A3
                bsr     TRI_MAP
                movea.l (SP),A0

                movea.l (A0)+,A1
                movem.l 4(A0),A2-A3
                bsr     TRI_MAP
                movea.l (SP)+,A0
                rts
                ENDPART


compute_test_polygon:>PART
                DC.L $4AFC4E71
                lea     test_polygon,A5
                movem.l (A5)+,A1-A3
                bsr     TRI_MAP
                rts
                ENDPART

p1:
                DC.W 33,47
                DC.W 255,255
p2:
                DC.W 10,159
                DC.W 255,0
p3:
                DC.W 99,0
                DC.W 0,0

test_polygon:
                DC.L p1,p2,p3


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
                ENDC

;-------------------------------------------------------------------------------
vbl:            >PART
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
wv:             tst.l   $00000466.w
                beq.s   wv
                rts
                ENDPART
;-------------------------------------------------------------------------------
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

                lea     es(PC),A2

                lea     iso_array,A0
                move.w  isoc,D7

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

*  cmp.w   0(A0),D7        ; 3  [zi][yi][xi]
*  sgt     D1              ; 2 (set)
*  add.w   D1,D1           ; 1  ...6

*    move.w  0(A0),D2        ; 3
*    sub.w   D7,D2           ; 1
*    addx.b  D1,D1           ; 1  (5)

*  move.b  0(A5),(A6)+     ;4   1CED 0000

                move.b  0(A5),-(A6)     ;4   1D2D 0000

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
;-------------------------------------------------------------------------------
iso_surface_clear:>PART

                lea     iso_array,A0
                lea     (ZM)*(YM)*(XM)*2,A1
                adda.l  A0,A1
                bsr     memclr
                rts

                ENDPART
normals_used_clear:>PART
                lea     normals_used_flags,A0
                lea     (ZM)*(YM)*(XM),A1
                adda.l  A0,A1
                bsr     memclr
                rts
                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
proj_z:         DC.W -700       ;-500;  -1000      ; -600
z_zoom:         DC.W 0          ; -600
;-------------------------------------------------------------------------------
ztrans:
                DC.W 1200*2

                DC.W 232*2      ;  623*2


; D6...y_loop counter
; A0...iso
; A1...previous z-plane

; D0 XX00.w bitcode INVERTED!!
do_march:       PART            ;         fetch arrays

*     DC.L $4AFC4E71

                movem.l D6/A0-A1,-(SP)  ; save calling registers

                not.b   D0              ; restore actual bitcode

                subq.l  #2,A0           ; actual array position

; don't touch D0, it's the bitcode!

; get pointer to the x,y,z array (3*2 sized)

                lea     iso_xyz,A2      ; x,y,z grid-array

                lea     iso_nx_ny,A3    ; nx.w, ny.w

                lea     normals_used_flags,A4

                move.l  A0,D1           ; iso array (16 bit sized)
                sub.l   #iso_array,D1   ; get relative position

                move.l  D1,D2
                lsr.l   #1,D2
                adda.l  D2,A4           ; normals_used_flags

                move.l  D1,D2
                add.l   D2,D2           ; *2   (4)

                adda.l  D2,A3           ; iso_nx_ny

                add.l   D2,D1           ; *3   (6)
                adda.l  D1,A2           ; iso_xyz

; fetch 8 control vertices
; ------------------------
; zi, yi, xi
                tas.b   (A4)
                bne.s   k7_normal_da
                lea     (A0),A5         ; iso
                bsr     make_normals_cell
                move.l  D1,(A3)         ; nx,ny
k7_normal_da:
                lea     knot7(PC),A1
                move.l  (A2),(A1)+      ; x y
                move.w  4(A2),(A1)+     ; z
                move.l  (A3),(A1)+      ; nx,ny
                move.w  (A0),(A1)+      ; iso

; zi, yi, xi+1
                tas.b   1(A4)
                bne.s   k6_normal_da
                lea     2(A0),A5        ; iso
                bsr     make_normals_cell
                move.l  D1,4(A3)        ; nx,ny
k6_normal_da:
                lea     knot6(PC),A1
                move.l  3*2(A2),(A1)+   ; x y
                move.w  3*2+4(A2),(A1)+ ; z
                move.l  4(A3),(A1)+     ; nx,ny
                move.w  2(A0),(A1)+     ; iso

; zi, yi+1, xi+1
                tas.b   XM+1(A4)
                bne.s   k5_normal_da
                lea     XM*2+2(A0),A5   ; iso
                bsr     make_normals_cell
                move.l  D1,(XM*2+2)*2(A3) ; nx,ny
k5_normal_da:
                lea     knot5(PC),A1
                move.l  XM*3*2+3*2(A2),(A1)+ ; x y
                move.w  XM*3*2+3*2+4(A2),(A1)+ ; z
                move.l  (XM*2+2)*2(A3),(A1)+ ; nx,ny
                move.w  XM*2+2(A0),(A1)+ ; iso

; zi, yi+1, xi
                tas.b   XM(A4)
                bne.s   k4_normal_da
                lea     XM*2(A0),A5     ; iso
                bsr     make_normals_cell
                move.l  D1,(XM*2)*2(A3) ; nx,ny
k4_normal_da:
                lea     knot4(PC),A1
                move.l  XM*3*2(A2),(A1)+ ; x y
                move.w  XM*3*2+4(A2),(A1)+ ; z
                move.l  (XM*2)*2(A3),(A1)+ ; nx,ny
                move.w  XM*2(A0),(A1)+  ; iso
;----------------------------------------------------
                lea     YM*XM*2(A0),A0
                lea     YM*XM*3*2(A2),A2 ; zi+1
                lea     (YM*XM*2)*2(A3),A3
                lea     YM*XM(A4),A4
; zi+1, yi, xi
                tas.b   (A4)
                bne.s   k3_normal_da
                lea     (A0),A5         ; iso
                bsr     make_normals_cell
                move.l  D1,(A3)         ; nx,ny
k3_normal_da:
                lea     knot3(PC),A1
                move.l  (A2),(A1)+      ; x y
                move.w  4(A2),(A1)+     ; z
                move.l  (A3),(A1)+      ; nx,ny
                move.w  (A0),(A1)+      ; iso

; zi+1, yi, xi+1
                tas.b   1(A4)
                bne.s   k2_normal_da
                lea     2(A0),A5        ; iso
                bsr     make_normals_cell
                move.l  D1,2*2(A3)      ; nx,ny
k2_normal_da:
                lea     knot2(PC),A1
                move.l  3*2(A2),(A1)+   ; x y
                move.w  3*2+4(A2),(A1)+ ; z
                move.l  2*2(A3),(A1)+   ; nx,ny
                move.w  2(A0),(A1)+     ; iso

; zi+1, yi+1, xi+1
                tas.b   XM+1(A4)
                bne.s   k1_normal_da
                lea     XM*2+2(A0),A5   ; iso
                bsr     make_normals_cell
                move.l  D1,(XM*2+2)*2(A3) ; nx,ny
k1_normal_da:
                lea     knot1(PC),A1
                move.l  XM*3*2+3*2(A2),(A1)+ ; x y
                move.w  XM*3*2+3*2+4(A2),(A1)+ ; z
                move.l  (XM*2+2)*2(A3),(A1)+ ; nx,ny
                move.w  XM*2+2(A0),(A1)+ ; iso

; zi+1, yi+1, xi
                tas.b   XM(A4)
                bne.s   k0_normal_da
                lea     XM*2(A0),A5     ; iso
                bsr     make_normals_cell
                move.l  D1,(XM*2)*2(A3) ; nx,ny
k0_normal_da:
                lea     knot0(PC),A1
                move.l  XM*3*2(A2),(A1)+ ; x y
                move.w  XM*3*2+4(A2),(A1)+ ; z
                move.l  (XM*2)*2(A3),(A1)+ ; nx,ny
                move.w  XM*2(A0),(A1)+  ; iso

;----------------------------------------------------
                ENDPART
                >PART ' intersections ' ; intersections & output

*  DC.L $4AFC4E71

                and.w   #$00FF,D0
                lsl.w   #5,D0           ; bitindex*16*2

                lea     edges_mcase(PC),A5
                lea     facettes_mcase(PC),A6
                adda.w  D0,A5
                pea     0(A6,D0.w)      ; save facettes_mcase+bitindex*16*2
; A5...edges_isctP
; A6...facesP

*  DC.L $4AFC4E71

; calculate intersections & project to 2D
;
; note: intersections are the actual polygon-vertices,
;       therefore calc 3d->2d only once, and output polygon_struct

;;    lea     zf_table,A6
;;    adda.w  ztrans(PC),A6

load_zf_table:  lea     zf_table,A6

                move.w  #CRAM_X/2,D3    ; center x
                move.w  #CRAM_Y/2,D4    ; center y

                move.w  (A5)+,D7        ; edge_intersections
                lea     _1_15_divtable,A3
                lea     edge_to_vertice_tab(PC),A4
calc_iscts:
                move.w  (A5)+,D2        ; edge = *edges_isctP++

                lea     (A4),A2         ; edge_to_vertice_tab
                adda.w  D2,A2           ; edge_to_vertice_tab[edge]
; D2 edge  *16
;calc_intersection_iso:
                lea     knot0(PC),A0
                lea     (A0),A1
                adda.w  (A2)+,A0        ; vertice0
                adda.w  (A2)+,A1        ; vertice1

                lea     intersections(PC),A2 ; vertex *isct
                adda.w  D2,A2

; c = (isoc - v0->iso) / (v1->iso - v0->iso)
                move.w  viso(A0),D0     ; v0->iso
isoc_set0:      move.w  #0,D6
                sub.w   D0,D6           ; isoc - v0->iso

                move.w  viso(A1),D1     ; v1->iso
                sub.w   D0,D1           ; v1->iso - v0->iso

                add.w   D1,D1
                muls    0(A3,D1.w),D6   ; (1^15)/d1 table
;--------------------------------------------------------------
; D0--D1, D6(c)
; p0 + (p1-p0)*c
;--------------------------------------------------------------
; -- x --
                move.w  (A0)+,D0        ; v0->x
                move.w  (A1)+,D5        ; v1->x
                sub.w   D0,D5           ; p1-p0
                add.w   D5,D5           ; prepare for 16:16 swap
                muls    D6,D5           ; *c
                swap    D5              ; int
                add.w   D5,D0           ; p0+
; -- y --
                move.w  (A0)+,D1        ; v0->y
                move.w  (A1)+,D5        ; v1->y
                sub.w   D1,D5           ; p1-p0
                add.w   D5,D5           ; prepare for 16:16 swap
                muls    D6,D5           ; *c
                swap    D5              ; int
                add.w   D5,D1           ; p0+
; -- z --
                move.w  (A0)+,D2        ; v0->z
                move.w  (A1)+,D5        ; v1->z
                sub.w   D2,D5           ; p1-p0
                add.w   D5,D5           ; prepare for 16:16 swap
                muls    D6,D5           ; *c
                swap    D5              ; int
                add.w   D5,D2           ; p0+
; 3D-->2D
                add.w   D2,D2
                move.w  0(A6,D2.w),D2   ; zf_table
                muls    D2,D0           ; x*zf
                muls    D2,D1           ; y*zf
                swap    D0
                swap    D1
                add.w   D3,D0           ; center x
                add.w   D4,D1           ; center y
                move.w  D1,(A2)+        ; y
                move.w  D0,(A2)+        ; x
; normalvectors (u,v)
; -- nx --
                move.w  (A0)+,D0        ; v0->nx
                move.w  (A1)+,D5        ; v1->nx
                sub.w   D0,D5           ; p1-p0
                add.w   D5,D5           ; prepare for 16:16 swap
                muls    D6,D5           ; *c
                swap    D5              ; int
                add.w   D5,D0           ; p0+

*    asr.w   #3,D0

                add.w   #128/2,D0

                move.w  D0,(A2)+        ; isct->nx
; -- ny --
                move.w  (A0)+,D0        ; v0->ny
                move.w  (A1)+,D5        ; v1->ny
                sub.w   D0,D5           ; p1-p0
                add.w   D5,D5           ; prepare for 16:16 swap
                muls    D6,D5           ; *c
                swap    D5              ; int
                add.w   D5,D0           ; p0+

*    asr.w   #3,D0

                add.w   #128/2,D0

                move.w  D0,(A2)+        ; isct->ny

                dbra    D7,calc_iscts

                movea.l (SP)+,A6        ; facettes_mcase

                ENDPART
                >PART ' output polygons '
;---------------------------------------------------------------------
; copy faces & render

*  DC.L $4AFC4E71

                move.w  (A6)+,-(SP)     ; faces
do_faces:
                lea     intersections(PC),A3 ; get polygons direct from
                lea     (A3),A1         ;      intersections!
                adda.w  (A6)+,A1        ; triv1
                lea     (A3),A2
                adda.w  (A6)+,A2        ; triv2
                adda.w  (A6)+,A3        ; triv2
;----------------------------------------
; vectorprodukt
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

vis_check_cond:
*    bpl.s   tri_nvis3       ;
                bmi.s   tri_nvis3       ;

;;   addq.w  #1,tri_count

                pea     (A6)
                bsr     TRI_MAP
                movea.l (SP)+,A6
tri_nvis3:
                subq.w  #1,(SP)
                bpl.s   do_faces
                addq.l  #2,SP

do_march_end:
                movem.l (SP)+,D6/A0-A1  ; restore calling registers

isoc_set1:      move.w  #0,D7           ; restore isoc

                rts

                ENDPART

; vertex
                RSSET 0
vx:             RS.W 1          ; 1
vy:             RS.W 1          ; 2
vz:             RS.W 1          ; 3
vnx:            RS.W 1          ; 4 nx (u)
vny:            RS.W 1          ; 5 ny (v)
viso:           RS.W 1          ; 6
                RS.W 1          ; 7
                RS.W 1          ; 8
vertex_size:    RS.L 0

; vertex
intersections:  DS.B 12*vertex_size ; also the polygons!

;---------------------------------------------------------------
edge_to_vertice_tab:>PART
; int edge_to_vertice_tab[12][2] = {
; //      vertices   edge

o               SET 16

                DC.W 0*o,4*o    ;,        // 0
                DS.B 16-4
                DC.W 4*o,5*o    ;,        // 1
                DS.B 16-4
                DC.W 5*o,1*o    ;,        // 2
                DS.B 16-4
                DC.W 1*o,0*o    ;,        // 3
                DS.B 16-4

                DC.W 3*o,7*o    ;,        // 4
                DS.B 16-4
                DC.W 7*o,6*o    ;,        // 5
                DS.B 16-4
                DC.W 6*o,2*o    ;,        // 6
                DS.B 16-4
                DC.W 2*o,3*o    ;,        // 7
                DS.B 16-4

                DC.W 0*o,3*o    ;,        // 8
                DS.B 16-4
                DC.W 4*o,7*o    ;,        // 9
                DS.B 16-4
                DC.W 5*o,6*o    ;,        // 10
                DS.B 16-4
                DC.W 1*o,2*o    ;         // 11
                DS.B 16-4

                DC.L -1
;};
                ENDPART
;---------------------------------------------------------------

; A5...iso_array ptr     DON'T TOUCH D0 !!!
; OUT: D1.l nx,ny
make_normals_cell:PART

*  DC.L $4AFC4E71

                move.w  (A5)+,D4
; nx
                move.w  (A5),D1
                sub.w   D4,D1
; ny
                move.w  XM*2-2(A5),D2
                sub.w   D4,D2
; nz
                move.w  YM*XM*2-2(A5),D3
                sub.w   D4,D3

                add.w   D1,D1
                add.w   D2,D2
                add.w   D3,D3

                lea     square_table+16384*2,A6
                move.w  0(A6,D1.w),D4   ; nx*nx
                add.w   0(A6,D2.w),D4   ; ny*ny
                add.w   0(A6,D3.w),D4   ; nz*nz

                lea     normalize_table,A6
                move.w  0(A6,D4.w),D4   ; normalize_table

descale_norm:   nop                     ;   lsr.w   #2,D4

                muls    D4,D1           ; nx*l
                muls    D4,D2           ; ny*l
                swap    D1
                swap    D2

;    moveq   #64,D4          ; tex_size/2
;    add.w   D4,D1           ; +64   tex_size/2
;    add.w   D4,D2           ; +64   tex_size/2

*    moveq   #127,D4         ; tex_size
*    and.w   D4,D1           ; tex_size
*    and.w   D4,D2           ; tex_size

                swap    D1
                move.w  D2,D1

                rts

                ENDPART

; D0--D1, D6(c)
; p0 + (p1-p0)*c
ipol:           >PART           ; **OBSOLETE**
                sub.w   D0,D1           ; p1-p0
                add.w   D1,D1           ; prepare for 16:16 swap
                muls    D6,D1           ; *c
                swap    D1              ; int
                add.w   D1,D0           ; p0+
                rts

                ENDPART

; vertex
knot0:          DS.B vertex_size
knot1:          DS.B vertex_size
knot2:          DS.B vertex_size
knot3:          DS.B vertex_size
knot4:          DS.B vertex_size
knot5:          DS.B vertex_size
knot6:          DS.B vertex_size
knot7:          DS.B vertex_size

MarchingCube:   >PART

*   DC.L $4AFC4E71

                move.w  ztrans,D0
                and.w   #-2,D0
                lea     zf_table,A0
                adda.w  D0,A0
                move.l  A0,load_zf_table+2

                lea     iso_array,A0

                lea     (ZM-2)*YM*XM*2(A0),A0 ; render back to front

                move.w  isoc(PC),D7

;-----------------------------------------------------
                pea     -YM*XM*2(A0)    ; zi--
                bsr     March_1st
                movea.l (SP)+,A0
;-----------------------------------------------------
                move.w  #ZM-1-1-1,-(SP)
dom_zi:
                lea     bitcodes_prev_Z_plane(PC),A1

                pea     -YM*XM*2(A0)    ; zi--

                moveq   #YM-1-1,D6
dom_yi:
                REPT XM-1

                move.b  (A1),D2         ; prev YX  <3210> (z-plane)

                moveq   #0,D0

                move.w  (A0)+,D1        ; 7   3  [zi][yi][xi]
                sub.w   D7,D1           ;     1
                addx.b  D0,D0           ;     1

                move.w  (A0),D1         ; 6  [zi][yi][xi+1]
                sub.w   D7,D1           ;     1
                addx.b  D0,D0           ;     1

                move.w  XM*2+2-2(A0),D1 ; 5  [zi][yi+1][xi+1]
                sub.w   D7,D1           ;     1
                addx.b  D0,D0           ;     1

                move.w  XM*2-2(A0),D1   ; 4  [zi][yi+1][xi]
                sub.w   D7,D1           ;     1
                addx.b  D0,D0           ;     1
;-------------------
; zi+1
                move.b  D0,(A1)+        ; new prev YX (z-plane)
                lsl.b   #4,D0
                or.b    D2,D0           ; zi plane
                beq.s   *+8             ; bitcode==  0 ?
                not.b   D0              ; bitcode==255 ?
                beq.s   *+4
                bsr     do_march

                ENDR

                addq.l  #2,A0           ; yi++ array  (XM*2)+
                dbra    D6,dom_yi

                movea.l (SP)+,A0        ; zi-- array
                subq.w  #1,(SP)
                bcc     dom_zi
                addq.l  #2,SP

                rts
                ENDPART
March_1st:      PART            ; calculate first z-plane

                lea     bitcodes_prev_Z_plane(PC),A1

                moveq   #YM-1-1,D6
dom_yi_1st:
                REPT XM-1

                moveq   #0,D0
                moveq   #0,D2

                move.w  (A0)+,D1        ; 7   3  [zi][yi][xi]
                sub.w   D7,D1           ;     1
                addx.b  D0,D0           ;     1

                move.w  (A0),D1         ; 6  [zi][yi][xi+1]
                sub.w   D7,D1           ;     1
                addx.b  D0,D0           ;     1

                move.w  XM*2+2-2(A0),D1 ; 5  [zi][yi+1][xi+1]
                sub.w   D7,D1           ;     1
                addx.b  D0,D0           ;     1

                move.w  XM*2-2(A0),D1   ; 4  [zi][yi+1][xi]
                sub.w   D7,D1           ;     1
                addx.b  D0,D0           ;     1
;-------------------
o               SET YM*XM*2     ; zi+1

                move.w  o-2(A0),D1      ; 3  [zi+1][yi][xi]
                sub.w   D7,D1           ;     1
                addx.b  D2,D2           ;     1

                move.w  o+2-2(A0),D1    ; 2  [zi+1][yi][xi+1]
                sub.w   D7,D1           ;     1
                addx.b  D2,D2           ;     1

                move.w  o+XM*2+2-2(A0),D1 ; 1  [zi+1][yi+1][xi+1]
                sub.w   D7,D1           ;     1
                addx.b  D2,D2           ;     1

                move.w  o+XM*2-2(A0),D1 ; 0  [zi+1][yi+1][xi]
                sub.w   D7,D1           ;     1
                addx.b  D2,D2           ;     1
;-------------------
                move.b  D0,(A1)+        ; prev YX  (z-plane)
                lsl.b   #4,D0
                or.b    D2,D0
                beq.s   *+8             ; bitcode==  0 ?
                not.b   D0              ; bitcode==255 ?
                beq.s   *+4
                bsr     do_march

                ENDR

                addq.l  #2,A0           ; yi++ array   (XM*2)+
                dbra    D6,dom_yi_1st

                rts

                ENDPART

                >PART ' MC - old '

                move.w  (A0)+,D1        ; 7   3  [zi][yi][xi]
                sub.w   D7,D1           ;     1
                addx.b  D0,D0           ;     1

                move.w  (A0),D1         ; 6  [zi][yi][xi+1]
                sub.w   D7,D1           ;     1
                addx.b  D0,D0           ;     1

                move.w  XM*2+2-2(A0),D1 ; 5  [zi][yi+1][xi+1]
                sub.w   D7,D1           ;     1
                addx.b  D0,D0           ;     1

                move.w  XM*2-2(A0),D1   ; 4  [zi][yi+1][xi]
                sub.w   D7,D1           ;     1
                addx.b  D0,D0           ;     1
;-------------------
o               SET YM*XM*2     ; zi+1

                move.w  o-2(A0),D1      ; 3  [zi][yi][xi]
                sub.w   D7,D1           ;     1
                addx.b  D0,D0           ;     1

                move.w  o+2-2(A0),D1    ; 2  [zi][yi][xi+1]
                sub.w   D7,D1           ;     1
                addx.b  D0,D0           ;     1

                move.w  o+XM*2+2-2(A0),D1 ; 1  [zi][yi+1][xi+1]
                sub.w   D7,D1           ;     1
                addx.b  D0,D0           ;     1

                move.w  o+XM*2-2(A0),D1 ; 0  [zi][yi+1][xi]
                sub.w   D7,D1           ;     1
                addx.b  D0,D0           ;     1

                tst.b   D0
                beq.s   *+8             ; bitcode==  0 ?
                not.b   D0              ; bitcode==255 ?
                beq.s   *+4
                bsr     do_march


                ENDPART

bitcodes_prev_Z_plane:DS.B YM*XM

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
init_march_tables:>PART

                bsr     init_mcase_tables
                bsr     init_facettes_mcase

                rts
                ENDPART
init_mcase_tables:>PART

*   DC.L $4AFC4E71

                lea     edges_mcase(PC),A0
                move.w  #256-1,D7
iem:
                move.w  (A0),D0         ; num_edges
                subq.w  #1,D0           ; for dbra
                move.w  D0,(A0)+

                moveq   #15-1,D6
iem2:
                move.w  (A0),D0         ; edge
                lsl.w   #4,D0           ; *16
                move.w  D0,(A0)+

                dbra    D6,iem2
                dbra    D7,iem
                rts

                ENDPART
init_facettes_mcase:>PART

*    DC.L $4AFC4E71

                lea     facettes_mcase(PC),A0

                move.w  #256-1,D7
ifm:
                move.w  (A0),D0         ; num_edges
                subq.w  #1,D0           ; for dbra
                move.w  D0,(A0)+

                moveq   #15-1,D6
ifm2:
                move.w  (A0),D0         ; vertex
                lsl.w   #4,D0           ; *16
                move.w  D0,(A0)+

                dbra    D6,ifm2
                dbra    D7,ifm
                rts

                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; int edges_mcase[256][16]
edges_mcase:    >PART

                DC.W 0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 00
                DC.W 3,0,3,8,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 01
                DC.W 3,2,3,11,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 02
                DC.W 4,0,2,8,11,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 03
                DC.W 3,6,7,11,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 04
                DC.W 6,0,3,6,7,8,11,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 05
                DC.W 4,2,3,6,7,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 06
                DC.W 5,0,2,6,7,8,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 07
                DC.W 3,4,7,8,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 08
                DC.W 4,0,3,4,7,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 09
                DC.W 6,2,3,4,7,8,11,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 0A
                DC.W 5,0,2,4,7,11,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 0B
                DC.W 4,4,6,8,11,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 0C
                DC.W 5,0,3,4,6,11,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 0D
                DC.W 5,2,3,4,6,8,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 0E
                DC.W 4,0,2,4,6,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 0F
                DC.W 3,0,1,9,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 10
                DC.W 4,1,3,8,9,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 11
                DC.W 6,0,1,2,3,9,11,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 12
                DC.W 5,1,2,8,9,11,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 13
                DC.W 6,0,1,6,7,9,11,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 14
                DC.W 7,1,3,6,7,8,9,11,-1,-1,-1,-1,-1,-1,-1,-1 ; 15
                DC.W 7,0,1,2,3,6,7,9,-1,-1,-1,-1,-1,-1,-1,-1 ; 16
                DC.W 6,1,2,6,7,8,9,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 17
                DC.W 6,0,1,4,7,8,9,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 18
                DC.W 5,1,3,4,7,9,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 19
                DC.W 9,0,1,2,3,4,7,8,9,11,-1,-1,-1,-1,-1,-1 ; 1A
                DC.W 6,1,2,4,7,9,11,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 1B
                DC.W 7,0,1,4,6,8,9,11,-1,-1,-1,-1,-1,-1,-1,-1 ; 1C
                DC.W 6,1,3,4,6,9,11,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 1D
                DC.W 8,0,1,2,3,4,6,8,9,-1,-1,-1,-1,-1,-1,-1 ; 1E
                DC.W 5,1,2,4,6,9,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 1F
                DC.W 3,1,2,10,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 20
                DC.W 6,0,1,2,3,8,10,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 21
                DC.W 4,1,3,10,11,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 22
                DC.W 5,0,1,8,10,11,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 23
                DC.W 6,1,2,6,7,10,11,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 24
                DC.W 9,0,1,2,3,6,7,8,10,11,-1,-1,-1,-1,-1,-1 ; 25
                DC.W 5,1,3,6,7,10,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 26
                DC.W 6,0,1,6,7,8,10,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 27
                DC.W 6,1,2,4,7,8,10,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 28
                DC.W 7,0,1,2,3,4,7,10,-1,-1,-1,-1,-1,-1,-1,-1 ; 29
                DC.W 7,1,3,4,7,8,10,11,-1,-1,-1,-1,-1,-1,-1,-1 ; 2A
                DC.W 6,0,1,4,7,10,11,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 2B
                DC.W 7,1,2,4,6,8,10,11,-1,-1,-1,-1,-1,-1,-1,-1 ; 2C
                DC.W 8,0,1,2,3,4,6,10,11,-1,-1,-1,-1,-1,-1,-1 ; 2D
                DC.W 6,1,3,4,6,8,10,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 2E
                DC.W 5,0,1,4,6,10,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 2F
                DC.W 4,0,2,9,10,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 30
                DC.W 5,2,3,8,9,10,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 31
                DC.W 5,0,3,9,10,11,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 32
                DC.W 4,8,9,10,11,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 33
                DC.W 7,0,2,6,7,9,10,11,-1,-1,-1,-1,-1,-1,-1,-1 ; 34
                DC.W 8,2,3,6,7,8,9,10,11,-1,-1,-1,-1,-1,-1,-1 ; 35
                DC.W 6,0,3,6,7,9,10,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 36
                DC.W 5,6,7,8,9,10,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 37
                DC.W 7,0,2,4,7,8,9,10,-1,-1,-1,-1,-1,-1,-1,-1 ; 38
                DC.W 6,2,3,4,7,9,10,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 39
                DC.W 8,0,3,4,7,8,9,10,11,-1,-1,-1,-1,-1,-1,-1 ; 3A
                DC.W 5,4,7,9,10,11,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 3B
                DC.W 8,0,2,4,6,8,9,10,11,-1,-1,-1,-1,-1,-1,-1 ; 3C
                DC.W 7,2,3,4,6,9,10,11,-1,-1,-1,-1,-1,-1,-1,-1 ; 3D
                DC.W 7,0,3,4,6,8,9,10,-1,-1,-1,-1,-1,-1,-1,-1 ; 3E
                DC.W 4,4,6,9,10,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 3F
                DC.W 3,5,6,10,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 40
                DC.W 6,0,3,5,6,8,10,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 41
                DC.W 6,2,3,5,6,10,11,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 42
                DC.W 7,0,2,5,6,8,10,11,-1,-1,-1,-1,-1,-1,-1,-1 ; 43
                DC.W 4,5,7,10,11,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 44
                DC.W 7,0,3,5,7,8,10,11,-1,-1,-1,-1,-1,-1,-1,-1 ; 45
                DC.W 5,2,3,5,7,10,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 46
                DC.W 6,0,2,5,7,8,10,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 47
                DC.W 6,4,5,6,7,8,10,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 48
                DC.W 7,0,3,4,5,6,7,10,-1,-1,-1,-1,-1,-1,-1,-1 ; 49
                DC.W 9,2,3,4,5,6,7,8,10,11,-1,-1,-1,-1,-1,-1 ; 4A
                DC.W 8,0,2,4,5,6,7,10,11,-1,-1,-1,-1,-1,-1,-1 ; 4B
                DC.W 5,4,5,8,10,11,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 4C
                DC.W 6,0,3,4,5,10,11,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 4D
                DC.W 6,2,3,4,5,8,10,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 4E
                DC.W 5,0,2,4,5,10,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 4F
                DC.W 6,0,1,5,6,9,10,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 50
                DC.W 7,1,3,5,6,8,9,10,-1,-1,-1,-1,-1,-1,-1,-1 ; 51
                DC.W 9,0,1,2,3,5,6,9,10,11,-1,-1,-1,-1,-1,-1 ; 52
                DC.W 8,1,2,5,6,8,9,10,11,-1,-1,-1,-1,-1,-1,-1 ; 53
                DC.W 7,0,1,5,7,9,10,11,-1,-1,-1,-1,-1,-1,-1,-1 ; 54
                DC.W 8,1,3,5,7,8,9,10,11,-1,-1,-1,-1,-1,-1,-1 ; 55
                DC.W 8,0,1,2,3,5,7,9,10,-1,-1,-1,-1,-1,-1,-1 ; 56
                DC.W 7,1,2,5,7,8,9,10,-1,-1,-1,-1,-1,-1,-1,-1 ; 57
                DC.W 9,0,1,4,5,6,7,8,9,10,-1,-1,-1,-1,-1,-1 ; 58
                DC.W 8,1,3,4,5,6,7,9,10,-1,-1,-1,-1,-1,-1,-1 ; 59
                DC.W 12,0,1,2,3,4,5,6,7,8,9,10,11,-1,-1,-1 ; 5A
                DC.W 9,1,2,4,5,6,7,9,10,11,-1,-1,-1,-1,-1,-1 ; 5B
                DC.W 8,0,1,4,5,8,9,10,11,-1,-1,-1,-1,-1,-1,-1 ; 5C
                DC.W 7,1,3,4,5,9,10,11,-1,-1,-1,-1,-1,-1,-1,-1 ; 5D
                DC.W 9,0,1,2,3,4,5,8,9,10,-1,-1,-1,-1,-1,-1 ; 5E
                DC.W 6,1,2,4,5,9,10,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 5F
                DC.W 4,1,2,5,6,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 60
                DC.W 7,0,1,2,3,5,6,8,-1,-1,-1,-1,-1,-1,-1,-1 ; 61
                DC.W 5,1,3,5,6,11,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 62
                DC.W 6,0,1,5,6,8,11,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 63
                DC.W 5,1,2,5,7,11,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 64
                DC.W 8,0,1,2,3,5,7,8,11,-1,-1,-1,-1,-1,-1,-1 ; 65
                DC.W 4,1,3,5,7,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 66
                DC.W 5,0,1,5,7,8,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 67
                DC.W 7,1,2,4,5,6,7,8,-1,-1,-1,-1,-1,-1,-1,-1 ; 68
                DC.W 8,0,1,2,3,4,5,6,7,-1,-1,-1,-1,-1,-1,-1 ; 69
                DC.W 8,1,3,4,5,6,7,8,11,-1,-1,-1,-1,-1,-1,-1 ; 6A
                DC.W 7,0,1,4,5,6,7,11,-1,-1,-1,-1,-1,-1,-1,-1 ; 6B
                DC.W 6,1,2,4,5,8,11,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 6C
                DC.W 7,0,1,2,3,4,5,11,-1,-1,-1,-1,-1,-1,-1,-1 ; 6D
                DC.W 5,1,3,4,5,8,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 6E
                DC.W 4,0,1,4,5,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 6F
                DC.W 5,0,2,5,6,9,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 70
                DC.W 6,2,3,5,6,8,9,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 71
                DC.W 6,0,3,5,6,9,11,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 72
                DC.W 5,5,6,8,9,11,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 73
                DC.W 6,0,2,5,7,9,11,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 74
                DC.W 7,2,3,5,7,8,9,11,-1,-1,-1,-1,-1,-1,-1,-1 ; 75
                DC.W 5,0,3,5,7,9,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 76
                DC.W 4,5,7,8,9,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 77
                DC.W 8,0,2,4,5,6,7,8,9,-1,-1,-1,-1,-1,-1,-1 ; 78
                DC.W 7,2,3,4,5,6,7,9,-1,-1,-1,-1,-1,-1,-1,-1 ; 79
                DC.W 9,0,3,4,5,6,7,8,9,11,-1,-1,-1,-1,-1,-1 ; 7A
                DC.W 6,4,5,6,7,9,11,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 7B
                DC.W 7,0,2,4,5,8,9,11,-1,-1,-1,-1,-1,-1,-1,-1 ; 7C
                DC.W 6,2,3,4,5,9,11,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 7D
                DC.W 6,0,3,4,5,8,9,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 7E
                DC.W 3,4,5,9,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 7F
                DC.W 3,4,5,9,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 80
                DC.W 6,0,3,4,5,8,9,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 81
                DC.W 6,2,3,4,5,9,11,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 82
                DC.W 7,0,2,4,5,8,9,11,-1,-1,-1,-1,-1,-1,-1,-1 ; 83
                DC.W 6,4,5,6,7,9,11,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 84
                DC.W 9,0,3,4,5,6,7,8,9,11,-1,-1,-1,-1,-1,-1 ; 85
                DC.W 7,2,3,4,5,6,7,9,-1,-1,-1,-1,-1,-1,-1,-1 ; 86
                DC.W 8,0,2,4,5,6,7,8,9,-1,-1,-1,-1,-1,-1,-1 ; 87
                DC.W 4,5,7,8,9,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 88
                DC.W 5,0,3,5,7,9,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 89
                DC.W 7,2,3,5,7,8,9,11,-1,-1,-1,-1,-1,-1,-1,-1 ; 8A
                DC.W 6,0,2,5,7,9,11,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 8B
                DC.W 5,5,6,8,9,11,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 8C
                DC.W 6,0,3,5,6,9,11,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 8D
                DC.W 6,2,3,5,6,8,9,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 8E
                DC.W 5,0,2,5,6,9,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 8F
                DC.W 4,0,1,4,5,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 90
                DC.W 5,1,3,4,5,8,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 91
                DC.W 7,0,1,2,3,4,5,11,-1,-1,-1,-1,-1,-1,-1,-1 ; 92
                DC.W 6,1,2,4,5,8,11,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 93
                DC.W 7,0,1,4,5,6,7,11,-1,-1,-1,-1,-1,-1,-1,-1 ; 94
                DC.W 8,1,3,4,5,6,7,8,11,-1,-1,-1,-1,-1,-1,-1 ; 95
                DC.W 8,0,1,2,3,4,5,6,7,-1,-1,-1,-1,-1,-1,-1 ; 96
                DC.W 7,1,2,4,5,6,7,8,-1,-1,-1,-1,-1,-1,-1,-1 ; 97
                DC.W 5,0,1,5,7,8,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 98
                DC.W 4,1,3,5,7,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 99
                DC.W 8,0,1,2,3,5,7,8,11,-1,-1,-1,-1,-1,-1,-1 ; 9A
                DC.W 5,1,2,5,7,11,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 9B
                DC.W 6,0,1,5,6,8,11,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 9C
                DC.W 5,1,3,5,6,11,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 9D
                DC.W 7,0,1,2,3,5,6,8,-1,-1,-1,-1,-1,-1,-1,-1 ; 9E
                DC.W 4,1,2,5,6,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; 9F
                DC.W 6,1,2,4,5,9,10,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; A0
                DC.W 9,0,1,2,3,4,5,8,9,10,-1,-1,-1,-1,-1,-1 ; A1
                DC.W 7,1,3,4,5,9,10,11,-1,-1,-1,-1,-1,-1,-1,-1 ; A2
                DC.W 8,0,1,4,5,8,9,10,11,-1,-1,-1,-1,-1,-1,-1 ; A3
                DC.W 9,1,2,4,5,6,7,9,10,11,-1,-1,-1,-1,-1,-1 ; A4
                DC.W 12,0,1,2,3,4,5,6,7,8,9,10,11,-1,-1,-1 ; A5
                DC.W 8,1,3,4,5,6,7,9,10,-1,-1,-1,-1,-1,-1,-1 ; A6
                DC.W 9,0,1,4,5,6,7,8,9,10,-1,-1,-1,-1,-1,-1 ; A7
                DC.W 7,1,2,5,7,8,9,10,-1,-1,-1,-1,-1,-1,-1,-1 ; A8
                DC.W 8,0,1,2,3,5,7,9,10,-1,-1,-1,-1,-1,-1,-1 ; A9
                DC.W 8,1,3,5,7,8,9,10,11,-1,-1,-1,-1,-1,-1,-1 ; AA
                DC.W 7,0,1,5,7,9,10,11,-1,-1,-1,-1,-1,-1,-1,-1 ; AB
                DC.W 8,1,2,5,6,8,9,10,11,-1,-1,-1,-1,-1,-1,-1 ; AC
                DC.W 9,0,1,2,3,5,6,9,10,11,-1,-1,-1,-1,-1,-1 ; AD
                DC.W 7,1,3,5,6,8,9,10,-1,-1,-1,-1,-1,-1,-1,-1 ; AE
                DC.W 6,0,1,5,6,9,10,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; AF
                DC.W 5,0,2,4,5,10,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; B0
                DC.W 6,2,3,4,5,8,10,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; B1
                DC.W 6,0,3,4,5,10,11,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; B2
                DC.W 5,4,5,8,10,11,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; B3
                DC.W 8,0,2,4,5,6,7,10,11,-1,-1,-1,-1,-1,-1,-1 ; B4
                DC.W 9,2,3,4,5,6,7,8,10,11,-1,-1,-1,-1,-1,-1 ; B5
                DC.W 7,0,3,4,5,6,7,10,-1,-1,-1,-1,-1,-1,-1,-1 ; B6
                DC.W 6,4,5,6,7,8,10,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; B7
                DC.W 6,0,2,5,7,8,10,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; B8
                DC.W 5,2,3,5,7,10,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; B9
                DC.W 7,0,3,5,7,8,10,11,-1,-1,-1,-1,-1,-1,-1,-1 ; BA
                DC.W 4,5,7,10,11,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; BB
                DC.W 7,0,2,5,6,8,10,11,-1,-1,-1,-1,-1,-1,-1,-1 ; BC
                DC.W 6,2,3,5,6,10,11,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; BD
                DC.W 6,0,3,5,6,8,10,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; BE
                DC.W 3,5,6,10,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; BF
                DC.W 4,4,6,9,10,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; C0
                DC.W 7,0,3,4,6,8,9,10,-1,-1,-1,-1,-1,-1,-1,-1 ; C1
                DC.W 7,2,3,4,6,9,10,11,-1,-1,-1,-1,-1,-1,-1,-1 ; C2
                DC.W 8,0,2,4,6,8,9,10,11,-1,-1,-1,-1,-1,-1,-1 ; C3
                DC.W 5,4,7,9,10,11,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; C4
                DC.W 8,0,3,4,7,8,9,10,11,-1,-1,-1,-1,-1,-1,-1 ; C5
                DC.W 6,2,3,4,7,9,10,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; C6
                DC.W 7,0,2,4,7,8,9,10,-1,-1,-1,-1,-1,-1,-1,-1 ; C7
                DC.W 5,6,7,8,9,10,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; C8
                DC.W 6,0,3,6,7,9,10,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; C9
                DC.W 8,2,3,6,7,8,9,10,11,-1,-1,-1,-1,-1,-1,-1 ; CA
                DC.W 7,0,2,6,7,9,10,11,-1,-1,-1,-1,-1,-1,-1,-1 ; CB
                DC.W 4,8,9,10,11,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; CC
                DC.W 5,0,3,9,10,11,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; CD
                DC.W 5,2,3,8,9,10,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; CE
                DC.W 4,0,2,9,10,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; CF
                DC.W 5,0,1,4,6,10,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; D0
                DC.W 6,1,3,4,6,8,10,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; D1
                DC.W 8,0,1,2,3,4,6,10,11,-1,-1,-1,-1,-1,-1,-1 ; D2
                DC.W 7,1,2,4,6,8,10,11,-1,-1,-1,-1,-1,-1,-1,-1 ; D3
                DC.W 6,0,1,4,7,10,11,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; D4
                DC.W 7,1,3,4,7,8,10,11,-1,-1,-1,-1,-1,-1,-1,-1 ; D5
                DC.W 7,0,1,2,3,4,7,10,-1,-1,-1,-1,-1,-1,-1,-1 ; D6
                DC.W 6,1,2,4,7,8,10,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; D7
                DC.W 6,0,1,6,7,8,10,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; D8
                DC.W 5,1,3,6,7,10,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; D9
                DC.W 9,0,1,2,3,6,7,8,10,11,-1,-1,-1,-1,-1,-1 ; DA
                DC.W 6,1,2,6,7,10,11,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; DB
                DC.W 5,0,1,8,10,11,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; DC
                DC.W 4,1,3,10,11,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; DD
                DC.W 6,0,1,2,3,8,10,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; DE
                DC.W 3,1,2,10,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; DF
                DC.W 5,1,2,4,6,9,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; E0
                DC.W 8,0,1,2,3,4,6,8,9,-1,-1,-1,-1,-1,-1,-1 ; E1
                DC.W 6,1,3,4,6,9,11,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; E2
                DC.W 7,0,1,4,6,8,9,11,-1,-1,-1,-1,-1,-1,-1,-1 ; E3
                DC.W 6,1,2,4,7,9,11,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; E4
                DC.W 9,0,1,2,3,4,7,8,9,11,-1,-1,-1,-1,-1,-1 ; E5
                DC.W 5,1,3,4,7,9,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; E6
                DC.W 6,0,1,4,7,8,9,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; E7
                DC.W 6,1,2,6,7,8,9,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; E8
                DC.W 7,0,1,2,3,6,7,9,-1,-1,-1,-1,-1,-1,-1,-1 ; E9
                DC.W 7,1,3,6,7,8,9,11,-1,-1,-1,-1,-1,-1,-1,-1 ; EA
                DC.W 6,0,1,6,7,9,11,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; EB
                DC.W 5,1,2,8,9,11,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; EC
                DC.W 6,0,1,2,3,9,11,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; ED
                DC.W 4,1,3,8,9,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; EE
                DC.W 3,0,1,9,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; EF
                DC.W 4,0,2,4,6,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; F0
                DC.W 5,2,3,4,6,8,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; F1
                DC.W 5,0,3,4,6,11,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; F2
                DC.W 4,4,6,8,11,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; F3
                DC.W 5,0,2,4,7,11,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; F4
                DC.W 6,2,3,4,7,8,11,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; F5
                DC.W 4,0,3,4,7,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; F6
                DC.W 3,4,7,8,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; F7
                DC.W 5,0,2,6,7,8,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; F8
                DC.W 4,2,3,6,7,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; F9
                DC.W 6,0,3,6,7,8,11,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; FA
                DC.W 3,6,7,11,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; FB
                DC.W 4,0,2,8,11,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; FC
                DC.W 3,2,3,11,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; FD
                DC.W 3,0,3,8,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; FE
                DC.W 0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ; FF

                ENDPART
;-------------------------------------------------------------------------------
; int facettes_mcase[256][16]
facettes_mcase: >PART

                DC.W 0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  00
                DC.W 1,0,3,8,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  01
                DC.W 1,3,2,11,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  02
                DC.W 2,0,2,11,11,8,0,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  03
                DC.W 1,7,11,6,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  04
                DC.W 2,0,3,8,6,7,11,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  05
                DC.W 2,7,3,2,2,6,7,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  06
                DC.W 3,0,2,6,6,8,0,6,7,8,-1,-1,-1,-1,-1,-1 ;  07
                DC.W 1,8,7,4,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  08
                DC.W 2,3,7,4,4,0,3,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  09
                DC.W 2,2,11,3,4,8,7,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  0A
                DC.W 3,4,0,2,2,7,4,2,11,7,-1,-1,-1,-1,-1,-1 ;  0B
                DC.W 2,8,11,6,6,4,8,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  0C
                DC.W 3,6,4,0,0,11,6,0,3,11,-1,-1,-1,-1,-1,-1 ;  0D
                DC.W 3,2,6,4,4,3,2,4,8,3,-1,-1,-1,-1,-1,-1 ;  0E
                DC.W 2,0,2,6,6,4,0,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  0F
                DC.W 1,9,1,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  10
                DC.W 2,1,3,8,8,9,1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  11
                DC.W 2,9,1,0,11,3,2,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  12
                DC.W 3,11,8,9,9,2,11,9,1,2,-1,-1,-1,-1,-1,-1 ;  13
                DC.W 2,0,9,1,7,11,6,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  14
                DC.W 3,1,3,8,8,9,1,7,11,6,-1,-1,-1,-1,-1,-1 ;  15
                DC.W 3,7,3,2,2,6,7,1,0,9,-1,-1,-1,-1,-1,-1 ;  16
                DC.W 4,9,1,6,6,7,9,7,8,9,1,2,6,-1,-1,-1 ;  17
                DC.W 2,1,0,9,7,4,8,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  18
                DC.W 3,1,3,7,7,9,1,7,4,9,-1,-1,-1,-1,-1,-1 ;  19
                DC.W 3,4,8,7,9,1,0,2,11,3,-1,-1,-1,-1,-1,-1 ;  1A
                DC.W 4,9,1,11,11,7,9,4,9,7,1,2,11,-1,-1,-1 ;  1B
                DC.W 3,6,4,8,8,11,6,0,9,1,-1,-1,-1,-1,-1,-1 ;  1C
                DC.W 4,3,4,9,3,11,4,9,1,3,11,6,4,-1,-1,-1 ;  1D
                DC.W 4,0,9,1,3,2,6,6,8,3,6,4,8,-1,-1,-1 ;  1E
                DC.W 3,4,2,6,2,4,9,2,9,1,-1,-1,-1,-1,-1,-1 ;  1F
                DC.W 1,1,10,2,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  20
                DC.W 2,10,2,1,8,0,3,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  21
                DC.W 2,3,1,10,10,11,3,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  22
                DC.W 3,10,11,8,8,1,10,8,0,1,-1,-1,-1,-1,-1,-1 ;  23
                DC.W 2,1,10,2,7,11,6,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  24
                DC.W 3,7,11,6,8,0,3,1,10,2,-1,-1,-1,-1,-1,-1 ;  25
                DC.W 3,7,3,1,1,6,7,1,10,6,-1,-1,-1,-1,-1,-1 ;  26
                DC.W 4,8,10,7,10,8,1,0,1,8,7,10,6,-1,-1,-1 ;  27
                DC.W 2,4,8,7,1,10,2,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  28
                DC.W 3,4,0,3,3,7,4,2,1,10,-1,-1,-1,-1,-1,-1 ;  29
                DC.W 3,10,11,3,3,1,10,8,7,4,-1,-1,-1,-1,-1,-1 ;  2A
                DC.W 4,11,0,1,11,7,0,1,10,11,7,4,0,-1,-1,-1 ;  2B
                DC.W 3,8,11,6,6,4,8,10,2,1,-1,-1,-1,-1,-1,-1 ;  2C
                DC.W 4,2,3,11,1,4,0,4,1,10,4,10,6,-1,-1,-1 ;  2D
                DC.W 4,4,8,1,1,10,4,10,6,4,8,3,1,-1,-1,-1 ;  2E
                DC.W 3,0,6,4,6,0,1,6,1,10,-1,-1,-1,-1,-1,-1 ;  2F
                DC.W 2,9,10,2,2,0,9,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  30
                DC.W 3,8,9,10,10,3,8,10,2,3,-1,-1,-1,-1,-1,-1 ;  31
                DC.W 3,9,10,11,11,0,9,11,3,0,-1,-1,-1,-1,-1,-1 ;  32
                DC.W 2,9,10,11,11,8,9,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  33
                DC.W 3,9,10,2,2,0,9,11,6,7,-1,-1,-1,-1,-1,-1 ;  34
                DC.W 4,11,6,7,3,8,9,9,2,3,9,10,2,-1,-1,-1 ;  35
                DC.W 4,7,0,9,7,9,6,0,7,3,6,9,10,-1,-1,-1 ;  36
                DC.W 3,10,8,9,8,10,6,8,6,7,-1,-1,-1,-1,-1,-1 ;  37
                DC.W 3,2,0,9,9,10,2,4,8,7,-1,-1,-1,-1,-1,-1 ;  38
                DC.W 4,9,3,4,3,9,2,2,9,10,4,3,7,-1,-1,-1 ;  39
                DC.W 4,8,3,0,7,10,11,10,7,4,10,4,9,-1,-1,-1 ;  3A
                DC.W 3,11,9,10,9,11,7,9,7,4,-1,-1,-1,-1,-1,-1 ;  3B
                DC.W 4,0,9,10,10,2,0,8,11,4,4,11,6,-1,-1,-1 ;  3C
                DC.W 3,4,10,6,10,4,9,2,3,11,-1,-1,-1,-1,-1,-1 ;  3D
                DC.W 3,10,4,9,4,10,6,8,3,0,-1,-1,-1,-1,-1,-1 ;  3E
                DC.W 2,4,10,6,10,4,9,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  3F
                DC.W 1,5,6,10,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  40
                DC.W 2,8,0,3,5,6,10,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  41
                DC.W 2,3,2,11,5,6,10,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  42
                DC.W 3,0,2,11,11,8,0,6,10,5,-1,-1,-1,-1,-1,-1 ;  43
                DC.W 2,5,7,11,11,10,5,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  44
                DC.W 3,5,7,11,11,10,5,3,8,0,-1,-1,-1,-1,-1,-1 ;  45
                DC.W 3,5,7,3,3,10,5,3,2,10,-1,-1,-1,-1,-1,-1 ;  46
                DC.W 4,5,8,0,5,0,10,8,5,7,10,0,2,-1,-1,-1 ;  47
                DC.W 2,8,7,4,10,5,6,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  48
                DC.W 3,3,7,4,4,0,3,5,6,10,-1,-1,-1,-1,-1,-1 ;  49
                DC.W 3,5,6,10,4,8,7,3,2,11,-1,-1,-1,-1,-1,-1 ;  4A
                DC.W 4,6,10,5,7,4,0,0,11,7,0,2,11,-1,-1,-1 ;  4B
                DC.W 3,8,11,10,10,4,8,10,5,4,-1,-1,-1,-1,-1,-1 ;  4C
                DC.W 4,4,11,5,11,4,3,3,4,0,5,11,10,-1,-1,-1 ;  4D
                DC.W 4,4,2,5,2,4,3,8,3,4,5,2,10,-1,-1,-1 ;  4E
                DC.W 3,2,4,0,4,2,10,4,10,5,-1,-1,-1,-1,-1,-1 ;  4F
                DC.W 2,6,10,5,0,9,1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  50
                DC.W 3,8,9,1,1,3,8,10,5,6,-1,-1,-1,-1,-1,-1 ;  51
                DC.W 3,3,2,11,0,9,1,5,6,10,-1,-1,-1,-1,-1,-1 ;  52
                DC.W 4,10,1,2,5,8,9,8,5,6,8,6,11,-1,-1,-1 ;  53
                DC.W 3,11,10,5,5,7,11,9,1,0,-1,-1,-1,-1,-1,-1 ;  54
                DC.W 4,3,8,9,9,1,3,11,10,7,7,10,5,-1,-1,-1 ;  55
                DC.W 4,1,0,9,10,5,7,7,2,10,7,3,2,-1,-1,-1 ;  56
                DC.W 3,7,9,5,9,7,8,1,2,10,-1,-1,-1,-1,-1,-1 ;  57
                DC.W 3,0,9,1,8,7,4,6,10,5,-1,-1,-1,-1,-1,-1 ;  58
                DC.W 4,5,4,9,6,3,7,3,6,10,3,10,1,-1,-1,-1 ;  59
                DC.W 4,0,9,1,2,11,3,10,5,6,4,8,7,-1,-1,-1 ;  5A
                DC.W 3,1,2,10,9,5,4,7,6,11,-1,-1,-1,-1,-1,-1 ;  5B
                DC.W 4,9,5,4,1,11,10,11,1,0,11,0,8,-1,-1,-1 ;  5C
                DC.W 3,3,10,1,10,3,11,5,4,9,-1,-1,-1,-1,-1,-1 ;  5D
                DC.W 3,8,3,0,4,9,5,10,1,2,-1,-1,-1,-1,-1,-1 ;  5E
                DC.W 4,4,2,5,5,2,10,2,9,1,9,2,4,-1,-1,-1 ;  5F
                DC.W 2,1,5,6,6,2,1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  60
                DC.W 3,6,2,1,1,5,6,0,3,8,-1,-1,-1,-1,-1,-1 ;  61
                DC.W 3,3,1,5,5,11,3,5,6,11,-1,-1,-1,-1,-1,-1 ;  62
                DC.W 4,8,0,5,5,6,8,6,11,8,0,1,5,-1,-1,-1 ;  63
                DC.W 3,1,5,7,7,2,1,7,11,2,-1,-1,-1,-1,-1,-1 ;  64
                DC.W 4,3,8,0,2,1,5,5,11,2,5,7,11,-1,-1,-1 ;  65
                DC.W 2,3,1,5,5,7,3,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  66
                DC.W 3,7,1,5,1,7,8,1,8,0,-1,-1,-1,-1,-1,-1 ;  67
                DC.W 3,1,5,6,6,2,1,7,4,8,-1,-1,-1,-1,-1,-1 ;  68
                DC.W 4,1,4,0,4,1,5,2,3,6,3,7,6,-1,-1,-1 ;  69
                DC.W 4,7,4,8,11,3,1,1,6,11,1,5,6,-1,-1,-1 ;  6A
                DC.W 3,0,5,4,5,0,1,6,11,7,-1,-1,-1,-1,-1,-1 ;  6B
                DC.W 4,1,4,8,1,8,2,4,1,5,2,8,11,-1,-1,-1 ;  6C
                DC.W 3,5,0,1,0,5,4,3,11,2,-1,-1,-1,-1,-1,-1 ;  6D
                DC.W 3,5,3,1,3,5,4,3,4,8,-1,-1,-1,-1,-1,-1 ;  6E
                DC.W 2,5,0,1,0,5,4,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  6F
                DC.W 3,6,2,0,0,5,6,0,9,5,-1,-1,-1,-1,-1,-1 ;  70
                DC.W 4,2,9,5,2,3,9,5,6,2,3,8,9,-1,-1,-1 ;  71
                DC.W 4,0,6,3,6,0,5,9,5,0,3,6,11,-1,-1,-1 ;  72
                DC.W 3,9,11,8,11,9,5,11,5,6,-1,-1,-1,-1,-1,-1 ;  73
                DC.W 4,0,9,7,7,11,0,11,2,0,9,5,7,-1,-1,-1 ;  74
                DC.W 3,9,7,8,7,9,5,11,2,3,-1,-1,-1,-1,-1,-1 ;  75
                DC.W 3,3,5,7,5,3,0,5,0,9,-1,-1,-1,-1,-1,-1 ;  76
                DC.W 2,7,9,5,9,7,8,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  77
                DC.W 4,4,8,7,5,6,2,2,9,5,2,0,9,-1,-1,-1 ;  78
                DC.W 3,2,7,6,7,2,3,4,9,5,-1,-1,-1,-1,-1,-1 ;  79
                DC.W 3,9,5,4,0,8,3,11,7,6,-1,-1,-1,-1,-1,-1 ;  7A
                DC.W 4,11,9,6,6,9,5,9,7,4,7,9,11,-1,-1,-1 ;  7B
                DC.W 3,11,0,8,0,11,2,9,5,4,-1,-1,-1,-1,-1,-1 ;  7C
                DC.W 2,9,5,4,3,11,2,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  7D
                DC.W 4,5,3,9,9,3,0,3,4,8,4,3,5,-1,-1,-1 ;  7E
                DC.W 1,4,9,5,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  7F
                DC.W 1,4,5,9,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  80
                DC.W 2,5,9,4,3,8,0,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  81
                DC.W 2,9,4,5,3,2,11,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  82
                DC.W 3,11,8,0,0,2,11,9,4,5,-1,-1,-1,-1,-1,-1 ;  83
                DC.W 2,11,6,7,9,4,5,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  84
                DC.W 3,9,4,5,0,3,8,11,6,7,-1,-1,-1,-1,-1,-1 ;  85
                DC.W 3,2,6,7,7,3,2,4,5,9,-1,-1,-1,-1,-1,-1 ;  86
                DC.W 4,4,7,8,5,2,6,2,5,9,2,9,0,-1,-1,-1 ;  87
                DC.W 2,7,5,9,9,8,7,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  88
                DC.W 3,3,7,5,5,0,3,5,9,0,-1,-1,-1,-1,-1,-1 ;  89
                DC.W 3,9,8,7,7,5,9,11,3,2,-1,-1,-1,-1,-1,-1 ;  8A
                DC.W 4,0,7,9,7,0,11,11,0,2,9,7,5,-1,-1,-1 ;  8B
                DC.W 3,9,8,11,11,5,9,11,6,5,-1,-1,-1,-1,-1,-1 ;  8C
                DC.W 4,0,3,6,6,5,0,9,0,5,3,11,6,-1,-1,-1 ;  8D
                DC.W 4,2,5,9,2,9,3,5,2,6,3,9,8,-1,-1,-1 ;  8E
                DC.W 3,6,0,2,0,6,5,0,5,9,-1,-1,-1,-1,-1,-1 ;  8F
                DC.W 2,5,1,0,0,4,5,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  90
                DC.W 3,5,1,3,3,4,5,3,8,4,-1,-1,-1,-1,-1,-1 ;  91
                DC.W 3,5,1,0,0,4,5,3,2,11,-1,-1,-1,-1,-1,-1 ;  92
                DC.W 4,1,8,4,1,2,8,4,5,1,2,11,8,-1,-1,-1 ;  93
                DC.W 3,0,4,5,5,1,0,6,7,11,-1,-1,-1,-1,-1,-1 ;  94
                DC.W 4,7,8,4,11,1,3,1,11,6,1,6,5,-1,-1,-1 ;  95
                DC.W 4,1,0,4,4,5,1,2,6,3,3,6,7,-1,-1,-1 ;  96
                DC.W 3,1,6,5,6,1,2,7,8,4,-1,-1,-1,-1,-1,-1 ;  97
                DC.W 3,7,5,1,1,8,7,1,0,8,-1,-1,-1,-1,-1,-1 ;  98
                DC.W 2,3,5,1,5,3,7,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  99
                DC.W 4,3,0,8,2,5,1,5,2,11,5,11,7,-1,-1,-1 ;  9A
                DC.W 3,1,7,5,7,1,2,7,2,11,-1,-1,-1,-1,-1,-1 ;  9B
                DC.W 4,8,5,0,5,8,6,6,8,11,0,5,1,-1,-1,-1 ;  9C
                DC.W 3,3,5,1,5,3,11,5,11,6,-1,-1,-1,-1,-1,-1 ;  9D
                DC.W 3,6,1,2,1,6,5,0,8,3,-1,-1,-1,-1,-1,-1 ;  9E
                DC.W 2,1,6,5,6,1,2,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  9F
                DC.W 2,4,5,9,2,1,10,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  A0
                DC.W 3,8,0,3,4,5,9,10,2,1,-1,-1,-1,-1,-1,-1 ;  A1
                DC.W 3,3,1,10,10,11,3,5,9,4,-1,-1,-1,-1,-1,-1 ;  A2
                DC.W 4,9,4,5,1,10,11,11,0,1,11,8,0,-1,-1,-1 ;  A3
                DC.W 3,1,10,2,9,4,5,7,11,6,-1,-1,-1,-1,-1,-1 ;  A4
                DC.W 4,0,1,9,2,3,11,10,6,5,4,7,8,-1,-1,-1 ;  A5
                DC.W 4,5,9,4,6,7,3,3,10,6,3,1,10,-1,-1,-1 ;  A6
                DC.W 3,0,1,9,8,4,7,6,5,10,-1,-1,-1,-1,-1,-1 ;  A7
                DC.W 3,7,5,9,9,8,7,1,10,2,-1,-1,-1,-1,-1,-1 ;  A8
                DC.W 4,1,9,0,10,7,5,7,10,2,7,2,3,-1,-1,-1 ;  A9
                DC.W 4,3,9,8,9,3,1,11,7,10,7,5,10,-1,-1,-1 ;  AA
                DC.W 3,11,5,10,5,11,7,9,0,1,-1,-1,-1,-1,-1,-1 ;  AB
                DC.W 4,10,2,1,5,9,8,8,6,5,8,11,6,-1,-1,-1 ;  AC
                DC.W 3,3,11,2,0,1,9,5,10,6,-1,-1,-1,-1,-1,-1 ;  AD
                DC.W 3,8,1,9,1,8,3,10,6,5,-1,-1,-1,-1,-1,-1 ;  AE
                DC.W 4,6,0,10,10,0,1,0,5,9,5,0,6,-1,-1,-1 ;  AF
                DC.W 3,2,0,4,4,10,2,4,5,10,-1,-1,-1,-1,-1,-1 ;  B0
                DC.W 4,4,5,2,2,3,4,8,4,3,5,10,2,-1,-1,-1 ;  B1
                DC.W 4,4,5,11,11,3,4,3,0,4,5,10,11,-1,-1,-1 ;  B2
                DC.W 3,8,10,11,10,8,4,10,4,5,-1,-1,-1,-1,-1,-1 ;  B3
                DC.W 4,6,5,10,7,0,4,0,7,11,0,11,2,-1,-1,-1 ;  B4
                DC.W 3,5,10,6,4,7,8,3,11,2,-1,-1,-1,-1,-1,-1 ;  B5
                DC.W 3,3,4,7,4,3,0,5,10,6,-1,-1,-1,-1,-1,-1 ;  B6
                DC.W 4,8,10,7,7,10,6,10,4,5,4,10,8,-1,-1,-1 ;  B7
                DC.W 4,5,0,8,5,10,0,8,7,5,10,2,0,-1,-1,-1 ;  B8
                DC.W 3,5,3,7,3,5,10,3,10,2,-1,-1,-1,-1,-1,-1 ;  B9
                DC.W 3,5,11,7,11,5,10,3,0,8,-1,-1,-1,-1,-1,-1 ;  BA
                DC.W 2,5,11,7,11,5,10,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  BB
                DC.W 3,0,11,2,11,0,8,6,5,10,-1,-1,-1,-1,-1,-1 ;  BC
                DC.W 4,3,5,2,2,5,10,5,11,6,11,5,3,-1,-1,-1 ;  BD
                DC.W 2,8,3,0,5,10,6,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  BE
                DC.W 1,5,10,6,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  BF
                DC.W 2,4,6,10,10,9,4,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  C0
                DC.W 3,10,9,4,4,6,10,8,0,3,-1,-1,-1,-1,-1,-1 ;  C1
                DC.W 3,4,6,10,10,9,4,2,11,3,-1,-1,-1,-1,-1,-1 ;  C2
                DC.W 4,0,10,9,10,0,2,8,4,11,4,6,11,-1,-1,-1 ;  C3
                DC.W 3,11,10,9,9,7,11,9,4,7,-1,-1,-1,-1,-1,-1 ;  C4
                DC.W 4,8,0,3,7,11,10,10,4,7,10,9,4,-1,-1,-1 ;  C5
                DC.W 4,9,4,3,3,2,9,2,10,9,4,7,3,-1,-1,-1 ;  C6
                DC.W 3,2,9,0,9,2,10,4,7,8,-1,-1,-1,-1,-1,-1 ;  C7
                DC.W 3,10,9,8,8,6,10,8,7,6,-1,-1,-1,-1,-1,-1 ;  C8
                DC.W 4,7,9,0,7,6,9,0,3,7,6,10,9,-1,-1,-1 ;  C9
                DC.W 4,11,7,6,3,9,8,9,3,2,9,2,10,-1,-1,-1 ;  CA
                DC.W 3,9,2,10,2,9,0,11,7,6,-1,-1,-1,-1,-1,-1 ;  CB
                DC.W 2,9,11,10,11,9,8,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  CC
                DC.W 3,9,11,10,11,9,0,11,0,3,-1,-1,-1,-1,-1,-1 ;  CD
                DC.W 3,8,10,9,10,8,3,10,3,2,-1,-1,-1,-1,-1,-1 ;  CE
                DC.W 2,9,2,10,2,9,0,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  CF
                DC.W 3,0,4,6,6,1,0,6,10,1,-1,-1,-1,-1,-1,-1 ;  D0
                DC.W 4,4,1,8,1,4,10,10,4,6,8,1,3,-1,-1,-1 ;  D1
                DC.W 4,2,11,3,1,0,4,4,10,1,4,6,10,-1,-1,-1 ;  D2
                DC.W 3,8,6,11,6,8,4,10,1,2,-1,-1,-1,-1,-1,-1 ;  D3
                DC.W 4,11,1,0,11,0,7,1,11,10,7,0,4,-1,-1,-1 ;  D4
                DC.W 3,10,3,11,3,10,1,8,4,7,-1,-1,-1,-1,-1,-1 ;  D5
                DC.W 3,4,3,0,3,4,7,2,10,1,-1,-1,-1,-1,-1,-1 ;  D6
                DC.W 2,4,7,8,1,2,10,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  D7
                DC.W 4,8,7,10,10,1,8,0,8,1,7,6,10,-1,-1,-1 ;  D8
                DC.W 3,7,1,3,1,7,6,1,6,10,-1,-1,-1,-1,-1,-1 ;  D9
                DC.W 3,7,6,11,8,3,0,1,2,10,-1,-1,-1,-1,-1,-1 ;  DA
                DC.W 4,1,7,10,10,7,6,7,2,11,2,7,1,-1,-1,-1 ;  DB
                DC.W 3,10,8,11,8,10,1,8,1,0,-1,-1,-1,-1,-1,-1 ;  DC
                DC.W 2,3,10,1,10,3,11,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  DD
                DC.W 4,10,8,2,2,8,3,8,1,0,1,8,10,-1,-1,-1 ;  DE
                DC.W 1,1,2,10,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  DF
                DC.W 3,4,6,2,2,9,4,2,1,9,-1,-1,-1,-1,-1,-1 ;  E0
                DC.W 4,0,1,9,3,6,2,6,3,8,6,8,4,-1,-1,-1 ;  E1
                DC.W 4,3,9,4,3,4,11,9,3,1,11,4,6,-1,-1,-1 ;  E2
                DC.W 3,6,8,4,8,6,11,0,1,9,-1,-1,-1,-1,-1,-1 ;  E3
                DC.W 4,9,11,1,11,9,7,4,7,9,1,11,2,-1,-1,-1 ;  E4
                DC.W 3,4,7,8,9,0,1,2,3,11,-1,-1,-1,-1,-1,-1 ;  E5
                DC.W 3,1,7,3,7,1,9,7,9,4,-1,-1,-1,-1,-1,-1 ;  E6
                DC.W 4,1,7,0,0,7,8,7,9,4,9,7,1,-1,-1,-1 ;  E7
                DC.W 4,9,6,1,6,9,7,7,9,8,1,6,2,-1,-1,-1 ;  E8
                DC.W 3,7,2,3,2,7,6,1,9,0,-1,-1,-1,-1,-1,-1 ;  E9
                DC.W 3,1,8,3,8,1,9,7,6,11,-1,-1,-1,-1,-1,-1 ;  EA
                DC.W 2,0,1,9,7,6,11,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  EB
                DC.W 3,11,9,8,9,11,2,9,2,1,-1,-1,-1,-1,-1,-1 ;  EC
                DC.W 4,9,11,1,1,11,2,11,0,3,0,11,9,-1,-1,-1 ;  ED
                DC.W 2,1,8,3,8,1,9,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  EE
                DC.W 1,9,0,1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  EF
                DC.W 2,0,6,2,6,0,4,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  F0
                DC.W 3,2,4,6,4,2,3,4,3,8,-1,-1,-1,-1,-1,-1 ;  F1
                DC.W 3,6,0,4,0,6,11,0,11,3,-1,-1,-1,-1,-1,-1 ;  F2
                DC.W 2,8,6,11,6,8,4,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  F3
                DC.W 3,4,2,0,2,4,7,2,7,11,-1,-1,-1,-1,-1,-1 ;  F4
                DC.W 4,2,4,11,11,4,7,4,3,8,3,4,2,-1,-1,-1 ;  F5
                DC.W 2,3,4,7,4,3,0,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  F6
                DC.W 1,8,4,7,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  F7
                DC.W 3,0,6,2,6,0,8,6,8,7,-1,-1,-1,-1,-1,-1 ;  F8
                DC.W 2,7,2,3,2,7,6,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  F9
                DC.W 4,0,6,3,3,6,11,6,8,7,8,6,0,-1,-1,-1 ;  FA
                DC.W 1,7,6,11,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  FB
                DC.W 2,0,11,2,11,0,8,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  FC
                DC.W 1,3,11,2,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  FD
                DC.W 1,0,8,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  FE
                DC.W 0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 ;  FF

                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;------------------------------
init_iso_xyz:   >PART

*   DC.L $4AFC4E71

                lea     iso_xyz,A0

                lea     GRID_X.w,A1
                lea     GRID_Y.w,A2
                lea     GRID_Z.w,A3

                move.w  #-GRID_Z*ZM/2+GRID_Z/2,D2
                moveq   #ZM-1,D7
iiz:
                move.w  #-GRID_Y*YM/2+GRID_Y/2,D1
                moveq   #YM-1,D6
iiy:
                move.w  #-GRID_X*XM/2+GRID_X/2,D0
                moveq   #XM-1,D5
iix:
                move.w  D0,(A0)+
                move.w  D1,(A0)+
                move.w  D2,(A0)+
                add.w   A1,D0           ; xi++
                dbra    D5,iix

                add.w   A2,D1           ; yi++
                dbra    D6,iiy

                add.w   A3,D2           ; zi++
                dbra    D7,iiz
                rts
                ENDPART
;------------------------------
init_zf_table:  >PART

                lea     zf_table_neg,A0

                move.w  #-4096,D0       ; z

                moveq   #10,D6          ; z_bits

                move.w  #4096+4096-1,D7
izftl:
                move.w  D0,D2           ; z
                move.w  z_zoom(PC),D3
                sub.w   D2,D3
                ext.l   D3
; asl.l   #8,D3
                asl.l   D6,D3           ; z_bits
                neg.w   D2
                add.w   proj_z(PC),D2
                bne.s   znz
                moveq   #1,D2
znz:
                divs    D2,D3
                neg.w   D3
                add.w   #1<<10,D3       ; 1<<z_bits

; 0.1*256 = 25.6
*  muls    #26,D3
; 0.2*256 = 51.2
                muls    #51,D3


;-- asr.l   #8,D3
*   asr.l   #10-8,D3

                asr.l   #8-6,D3

; zf: 2^16
                move.w  D3,(A0)+
                addq.w  #1,D0           ; z++
                dbra    D7,izftl
                rts

                ENDPART
;------------------------------
init_1_15_divtable:>PART

*  DC.L $4AFC4E71

                lea     _1_15_divtable_neg,A0
                lea     _1_15_divtable_end+2,A1

                lea     $00007FFF,A2

                move.w  #-16384,D6
                move.w  #16384-1,D7
i15d:
                move.l  A2,D0           ; $7fff
                divs    D6,D0
                move.w  D0,(A0)+        ; neg
                neg.w   D0
                move.w  D0,-(A1)        ; pos
                addq.w  #1,D6
                dbra    D7,i15d

                rts

                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
; A0-->A1
memclr:         >PART

                move.l  A1,D0
                sub.l   A0,D0           ; block length

                movem.l zero,D1-A0/A2-A6 ; 13*4 = 52

                divu    #8*(13*4),D0
                bra.s   mc0_C
mc0C:
                movem.l D1-A0/A2-A6,-(A1)
                movem.l D1-A0/A2-A6,-(A1)
                movem.l D1-A0/A2-A6,-(A1)
                movem.l D1-A0/A2-A6,-(A1)
                movem.l D1-A0/A2-A6,-(A1)
                movem.l D1-A0/A2-A6,-(A1)
                movem.l D1-A0/A2-A6,-(A1)
                movem.l D1-A0/A2-A6,-(A1)
mc0_C:          dbra    D0,mc0C

                clr.w   D0
                swap    D0
                divu    #4,D0
                bra.s   mc1_C
mc1C:
                move.l  D1,-(A1)
mc1_C:          dbra    D0,mc1C

                swap    D0
                bra.s   mc2_C
mc2C:           move.b  D1,-(A1)
mc2_C:          dbra    D0,mc2C
                rts
                ENDPART
black:
zero:           DS.L 16
;-------------------------------------------------------------------------------

; TEST FUNCTIONS
set_iso_surface_test:>PART

**   DC.L $4AFC4E71

                lea     iso_array,A6
                lea     GRID_Z.w,A0

                move.w  #-(ZM/2)*GRID_Z,D2
                moveq   #ZM-1,D7
sist_z:
                move.w  D2,D3
                muls    D3,D3
                movea.l D3,A1

                move.w  #-(YM/2)*GRID_Y,D1
                moveq   #YM-1,D6
sist_y:
                move.w  D1,D3
                muls    D3,D3
                movea.l D3,A2

                move.w  #-(XM/2)*GRID_X,D0
                moveq   #XM-1,D5
sist_x:
                move.w  D0,D3
                muls    D3,D3
                add.l   A1,D3
                add.l   A2,D3
                asr.l   #8,D3
                asr.l   #3,D3

                addq.l  #1,D3

                move.l  #4096,D4
                divu    D3,D4

                move.w  D4,(A6)+

                add.w   A0,D0           ;
                dbra    D5,sist_x

                add.w   A0,D1           ;
                dbra    D6,sist_y

                add.w   A0,D2           ;
                dbra    D7,sist_z
                rts
                ENDPART

set_iso_function:>PART

**   DC.L $4AFC4E71

                lea     iso_array,A6

                movea.l sintab_adr,A2
                adda.w  w0(PC),A2

                moveq   #ZM-1,D7
sist_z2:
                move.w  (A2),D2
                adda.w  #32*2,A2
                asr.w   #7,D2

                movea.l sintab_adr,A1
                adda.w  w1(PC),A1

                moveq   #YM-1,D6
sist_y2:
                move.w  (A1),D1
                adda.w  #22*2,A1
                asr.w   #7,D1
                add.w   D2,D1

                movea.l sintab_adr,A0
                adda.w  w2(PC),A0

o               SET 0
                REPT XM
                move.w  o(A0),D0
                asr.w   #7,D0
                add.w   D1,D0
                move.w  D0,(A6)+
o               SET o+42*2
                ENDR
                dbra    D6,sist_y2

                dbra    D7,sist_z2
                rts
                ENDPART

set_iso_plane:  >PART

                move.w  isoc,D4
                add.w   #23,D4

                lea     iso_array,A6
                lea     4*YM*ZM*2(A6),A6

                moveq   #YM-1,D6
sip_y:
                moveq   #XM-1,D5
sip_x:
                move.w  D4,(A6)+

                dbra    D5,sip_x
                dbra    D6,sip_y
                rts
                ENDPART

;-------------------------------------------------------------------------------
clear_colorram: >PART

                move.l  SP,cc_sp+2

                movem.l zero,D0-A6      ; 15*4 = 60

                lea     colorram,SP
                lea     256*50(SP),SP   ; bottom
                lea     -176(SP),SP

; 80/60 = 1, rest: 20 / 4 = 5


                REPT 50
                movem.l D0-A6,-(SP)     ; 60
                movem.l D0-D4,-(SP)     ; 20
                lea     -176(SP),SP     ; 256-80 = 176
                ENDR

cc_sp:          lea     0,SP
                rts

                ENDPART
;-------------------------------------------------------------------------------
set_test_colorram:>PART
                lea     colorram,A6
                moveq   #0,D0
                moveq   #200/4-1,D7
stc_y:
                moveq   #0,D1
                moveq   #320/4-1,D6
stc_x:
                move.w  D0,D2
                add.w   D1,D2
                and.w   #15,D2
                lsl.w   #3,D2
                move.b  D2,(A6)+

                addq.w  #1,D1           ; x++
                dbra    D6,stc_x
                lea     256-80(A6),A6
                addq.w  #1,D0           ; y++
                dbra    D7,stc_y
                rts
                ENDPART
;-------------------------------------------------------------------------------
output_colorram44:>PART

                move.l  #super_trap0,$00000080.w
                move    #$0300,SR

                lea     colorram,A5

                movea.l screen1(PC),A6

                movem.l c2p_adr(PC),D0-D1

                move.w  #200/4-1,o44_lines
o44_y:
o               SET 0
                REPT 4
;------------------------------------------------------
; (1)
                move.w  (A5)+,D0        ; 2 texel
                movea.l D0,SP           ;
                move.l  (SP)+,D2        ;
                move.l  (SP)+,D3        ;...9

                move.w  (A5)+,D1        ; 2 texel
                movea.l D1,SP           ;
                or.l    (SP)+,D2        ;
                or.l    (SP)+,D3        ;...9
;------------------------------------------------------
; (2)
                move.w  (A5)+,D0        ; 2 texel
                movea.l D0,SP           ;
                move.l  (SP)+,D4        ;
                move.l  (SP)+,D5        ;...9

                move.w  (A5)+,D1        ; 2 texel
                movea.l D1,SP           ;
                or.l    (SP)+,D4        ;
                or.l    (SP)+,D5        ;...9
;------------------------------------------------------
; (3)
                move.w  (A5)+,D0        ; 2 texel
                movea.l D0,SP           ;
                move.l  (SP)+,D6        ;
                move.l  (SP)+,D7        ;...9

                move.w  (A5)+,D1        ; 2 texel
                movea.l D1,SP           ;
                or.l    (SP)+,D6        ;
                or.l    (SP)+,D7        ;...9
;------------------------------------------------------
; (4)
                move.w  (A5)+,D0        ; 2 texel
                movea.l D0,SP           ;
                movea.l (SP)+,A0        ;
                movea.l (SP)+,A1        ;...9

                move.w  (A5)+,D1        ; 2 texel
                movea.l D1,SP           ;
                adda.l  (SP)+,A0        ;
                adda.l  (SP)+,A1        ;...9
;------------------------------------------------------
; (5)
                move.w  (A5)+,D0        ; 2 texel
                movea.l D0,SP           ;
                movea.l (SP)+,A2        ;
                movea.l (SP)+,A3        ;...9

                move.w  (A5)+,D1        ; 2 texel
                movea.l D1,SP           ;
                adda.l  (SP)+,A2        ;
                adda.l  (SP)+,A3        ;...9
;------------------------------------------------------
;------------------------------------------------------
                movem.l D2-A3,0*160+o(A6)
                movem.l D2-A3,1*160+o(A6)
                movem.l D2-A3,2*160+o(A6)
                movem.l D2-A3,3*160+o(A6)
;------------------------------------------------------
o               SET o+10*4
;------------------------------------------------------
                ENDR

                lea     CRAM_X_line-80(A5),A5

                lea     4*160(A6),A6

                subq.w  #1,o44_lines
                bpl     o44_y

                trap    #0
                rts

o44_lines:      DC.W 0

                ENDPART
;-------------------------------------------------------------------------------
init_c2p_44:    >PART

*   DC.L $4AFC4E71

*  move.l  #zero_base,D0
*  clr.w   D0
*  lea     c2p_adr(PC),A0
*  move.l  D0,(A0)+
*  add.l   #65536,D0
*  move.l  D0,(A0)+

; 256/8 = 32
                movem.l c2p_adr(PC),A0-A1
                lea     col_init_table(PC),A2
                moveq   #32-1,D7
ic0:
                moveq   #32-1,D0
                sub.w   D7,D0
                cmp.w   #15,D0
                ble.s   *+2
                moveq   #15,D0
                lsl.w   #3,D0
                movem.l 0(A2,D0.w),D0-D1
                lsl.l   #4,D0
                lsl.l   #4,D1

                moveq   #32-1,D6
ic1:
                moveq   #32-1,D5
                sub.w   D6,D5
                cmp.w   #15,D5
                ble.s   *+2
                moveq   #15,D5
                lsl.w   #3,D5
                movem.l 0(A2,D5.w),D2-D3
                or.l    D0,D2
                or.l    D1,D3
                move.l  D2,(A0)+
                move.l  D3,(A0)+
                lsr.l   #8,D2
                lsr.l   #8,D3
                move.l  D2,(A1)+
                move.l  D3,(A1)+

                dbra    D6,ic1

                lea     $0700(A0),A0
                lea     $0700(A1),A1

                dbra    D7,ic0
                rts
col_init_table:
T               SET $0F00
                DC.W 0,0,0,0
                DC.W T,0,0,0
                DC.W 0,T,0,0
                DC.W T,T,0,0

                DC.W 0,0,T,0
                DC.W T,0,T,0
                DC.W 0,T,T,0
                DC.W T,T,T,0

                DC.W 0,0,0,T
                DC.W T,0,0,T
                DC.W 0,T,0,T
                DC.W T,T,0,T

                DC.W 0,0,T,T
                DC.W T,0,T,T
                DC.W 0,T,T,T
                DC.W T,T,T,T
                ENDPART
;-------------------------------------------------------------------------------
super_trap0:
                move.b  #$23,(SP)
                rte
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
; struct blob
                RSSET 0
xb:             RS.W 1
yb:             RS.W 1
zb:             RS.W 1
alpha:          RS.W 1
alpha_inc:      RS.W 1
beta:           RS.W 1
beta_inc:       RS.W 1
gamma:          RS.W 1
gamma_inc:      RS.W 1
rq:             RS.L 1          ; LONG!!
struct_blob:    RS.L 0

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
set_isosurface_blobs:>PART

*  DC.L $4AFC4E71

                bsr     move_blobs

                bsr     setup_xyz_values

                bsr     set_blobs_main

                rts
                ENDPART

setup_xyz_values:>PART

                lea     blob_pre_values_X(PC),A0
                lea     blob_pre_values_Y(PC),A1
                lea     blob_pre_values_Z(PC),A2

                lea     blob0,A3
                bsr     set_xyz_blob
                bsr     sxyz_advance_blob

                lea     blob1,A3
                bsr     set_xyz_blob
                bsr     sxyz_advance_blob

                lea     blob2,A3
                bsr     set_xyz_blob
                bsr     sxyz_advance_blob

                lea     blob3,A3
                bsr     set_xyz_blob
                bsr     sxyz_advance_blob

                lea     blob4,A3
                bsr     set_xyz_blob
                bsr     sxyz_advance_blob

                rts

sxyz_advance_blob:
                addq.l  #2,A0
                addq.l  #2,A1
                addq.l  #2,A2
                rts

set_xyz_blob:
                movem.w (A3),D0-D2      ; xb,yb,zb
                movem.w D0-D2,sb_xb

                move.w  sb_xb(PC),D0
                neg.w   D0              ; -xb
                add.w   #-XM/2*GRID_X+GRID_X/2,D0
                move.w  #GRID_X,D2
                lea     (A0),A6         ; x array
                bsr     sxyz_calc_XM

                move.w  sb_yb(PC),D0
                neg.w   D0              ; -yb
                add.w   #-YM/2*GRID_Y+GRID_Y/2,D0
                move.w  #GRID_Y,D2
                lea     (A1),A6         ; y array
                bsr     sxyz_calc_YM

                move.w  sb_zb(PC),D0
                neg.w   D0              ; -zb
                add.w   #-ZM/2*GRID_Z+GRID_Z/2,D0
                move.w  #GRID_Z,D2
                lea     (A2),A6         ; z array
                bsr     sxyz_calc_ZM

                rts

; A0
; x0,x1,x2, x0+GRID,x1+GRID,x2+GRID,...   ... GRID*XM
;
; A1
; y0,y1,y2
;
; A2
; z0,z1,z2

sxyz_calc_XM:
; dx = (x-xb)
                moveq   #-2,D4
o               SET 0
                REPT XM
                move.w  D0,D1
                muls    D1,D1           **OPTI: MULTABLE!!**
                lsr.l   #8-1,D1
                and.w   D4,D1
                move.w  D1,o(A6)        ; 16bit!
                add.w   D2,D0           ; next grid pos
o               SET o+AMOUNT_BLOBS*2
                ENDR
                rts
sxyz_calc_YM:
; dx = (x-xb)
                moveq   #-2,D4
o               SET 0
                REPT YM
                move.w  D0,D1
                muls    D1,D1           **OPTI: MULTABLE!!**
                lsr.l   #8-1,D1
                and.w   D4,D1
                move.w  D1,o(A6)        ; 16bit!
                add.w   D2,D0           ; next grid pos
o               SET o+AMOUNT_BLOBS*2
                ENDR
                rts
sxyz_calc_ZM:
; dx = (x-xb)
                moveq   #-2,D4
o               SET 0
                REPT ZM
                move.w  D0,D1
                muls    D1,D1           **OPTI: MULTABLE!!**
                lsr.l   #8-1,D1
                and.w   D4,D1
                move.w  D1,o(A6)        ; 16bit!
                add.w   D2,D0           ; next grid pos
o               SET o+AMOUNT_BLOBS*2
                ENDR
                rts

sb_xb:          DC.W 0
sb_yb:          DC.W 0
sb_zb:          DC.W 0

                ENDPART

blobs_list:
                DC.L blob0
                DC.L blob1
                DC.L blob2
                DC.L blob3
                DC.L blob4
                DC.L -1

set_blobs_main: >PART

*  DC.L $4AFC4E71

                bsr     set_sib_code_modi_5b
*  bsr     set_sib_code_modi_3b

                lea     iso_array,A6    ; output

                move.l  #blob_strength_table,D6

                lea     blob_pre_values_Z(PC),A0
                move.w  #ZM-1,-(SP)
sib_calc_z:
                move.w  (A0)+,sib_blob1_z+2
                move.w  (A0)+,sib_blob2_z+2
                move.w  (A0)+,sib_blob3_z+2
                move.w  (A0)+,sib_blob4_z+2
                move.w  (A0)+,sib_blob5_z+2

                move.l  A0,D5           ; save _Z

                lea     blob_pre_values_Y(PC),A1
                moveq   #YM-1,D7
sib_calc_y:
                movea.l D6,A2           ; blob_strength_table
sib_blob2_z:    lea     0(A2),A3
sib_blob3_z:    lea     0(A2),A4
sib_blob1_z:    lea     0(A2),A2

                adda.w  (A1)+,A2        ; blob1
                adda.w  (A1)+,A3        ; blob2
                adda.w  (A1)+,A4        ; blob3

                movea.l D6,A0           ; blob_strength_table
sib_blob4_z:    lea     0(A0),A0
                adda.w  (A1)+,A0        ; blob4
                move.w  (A1)+,D0        ; blob5

                move.l  A1,D4           ; save _Y

                movea.l D6,A1           ; blob_strength_table
sib_blob5_z:    lea     0(A1),A1
                adda.w  D0,A1           ; blob5
sib_calc_x:

; l = dx*dx + dy*dy + dz*dz

                REPT XM
; 5 blobs
                move.w  0(A2),D0        ; blob1
                add.w   0(A3),D0        ; blob2
                add.w   0(A4),D0        ; blob3
                add.w   0(A0),D0        ; blob4
                add.w   0(A1),D0        ; blob5

                move.w  D0,(A6)+        ; iso_array output

                ENDR

                movea.l D4,A1           ; restore _Y
                dbra    D7,sib_calc_y

                movea.l D5,A0           ; restore _Z

                subq.w  #1,(SP)
                bcc     sib_calc_z
                addq.l  #2,SP

                rts
                ENDPART

; 5 blobs
set_sib_code_modi_5b:>PART

                lea     blob_pre_values_X(PC),A0
                lea     sib_calc_x+2(PC),A6
o               SET 0
                REPT XM
                move.w  (A0)+,o(A6)     ; blob0
o               SET o+4
                move.w  (A0)+,o(A6)     ; blob1
o               SET o+4
                move.w  (A0)+,o(A6)     ; blob2
o               SET o+4
                move.w  (A0)+,o(A6)     ; blob3
o               SET o+4
                move.w  (A0)+,o(A6)     ; blob4
o               SET o+4
o               SET o+2
                ENDR
                rts

                ENDPART

; 3 blobs
set_sib_code_modi_3b:>PART

                lea     blob_pre_values_X(PC),A0
                lea     sib_calc_x+2(PC),A6
o               SET 0
                REPT XM
                move.w  (A0)+,o(A6)     ; blob0
o               SET o+4
                move.w  (A0)+,o(A6)     ; blob1
o               SET o+4
                move.w  (A0)+,o(A6)     ; blob2
o               SET o+4
o               SET o+2

                addq.l  #2*2,A0

                ENDR
                rts

                ENDPART

                >PART ' array ordering '
; A0
; x0,x1,x2, x0+GRID,x1+GRID,x2+GRID,...   ... GRID*XM
;
; A1
; y0,y1,y2
;
; A2
; z0,z1,z2
                ENDPART


;-------------------------------------------------------------------------------
init_blob_strength_tab:>PART

*  DC.L $4AFC4E71

                lea     blob_strength_table,A0

*  movea.l #16*65536,A1    **ORIG**

                movea.l #10*65536,A1

* lea     8192.w,A2       ; max. density  **ORIG**
                lea     16384.w,A2

                moveq   #PARTDIV_BITS+7,D4

                move.l  #$0000FFFF,D5
                moveq   #1,D1           ; riV = 1

*   move.w  #65536-1-1,D7

                move.w  #32000-1,D7
ibst:
                move.l  A1,D0           ; #3000*128,D0

                divu    D1,D0
                bvc.s   divok0
                move.l  D0,D2           ; dividend_temp
                lsr.l   D4,D0           ;*** dividend/4 DESCALE
                divu    D1,D0
                move.w  D0,D3           ; res0
                mulu    D1,D3           ; res0*divisor
                lsl.l   D4,D3           ;*** UPSCALE
                sub.l   D3,D2           ; divident_temp-res0

                divu    D1,D2           ;
                and.l   D5,D2           ; #$0000FFFF,D2
                and.l   D5,D0           ; #$0000FFFF,D0
                lsl.l   D4,D0           ;*** UPSCALE
                add.l   D2,D0
                bra.s   divdone0
divok0:
                and.l   D5,D0           ; #$0000FFFF,D0
divdone0:

; clip density max
                cmp.l   A2,D0           ;
                ble.s   d_densok        ;
                move.w  A2,D0           ;
d_densok:
                move.w  D0,(A0)+        ; store d

                addq.w  #1,D1           ; riV++
                dbra    D7,ibst
                rts

                ENDPART
;-------------------------------------------------------------------------------
init_normalize_table:>PART

*   DC.L $4AFC4E71

                lea     normalize_table,A0

*  movea.l #$00010000,A1   ; bmp
                movea.l #$00010000,A1   ; bmp

                moveq   #0,D6           ; l start
                move.w  #16384-1,D7
int_l:
                move.l  D6,D0
; l = 128/sqrt(nx*nx + ny*ny + nz*nz);
;-------------------------------------------------------
; sqrt(d0)
                moveq   #1,D1           ; mask=1
                ror.l   #2,D1           ; mask=2^30
                moveq   #0,D2           ; result=0
_loop4:
                move.l  D2,D3           ; tmp=result
                add.l   D1,D3           ; tmp+=mask
                lsr.l   #1,D2           ; result>>=1
                cmp.l   D3,D0           ; x-tmp<0?
                bcs.s   _cont4          ; yep
                sub.l   D3,D0           ; x-=tmp
                add.l   D1,D2           ; result+=mask
_cont4:
                lsr.l   #2,D1           ; mask>>=2;
                bne.s   _loop4          ; nochmal
                move.l  D2,D1           ; d1=result
;-------------------------------------------------------
                addq.w  #2,D1           ; 1

                move.l  A1,D0           ; #$00007FFF,D0
                divu    D1,D0

                move.w  D0,(A0)+

*   addq.l  #1,D6           ; l++
                add.l   #16,D6          ; l++

                dbra    D7,int_l
                rts

                ENDPART
;-------------------------------------------------------------------------------
init_square_table:>PART

*  DC.L $4AFC4E71

                lea     square_table,A0

                moveq   #-2,D4

                move.w  #-16384,D6
                move.w  #2*16384-1,D7
ist_l:
                move.w  D6,D0
                muls    D0,D0
; lsr.l #13,d6
                lsl.l   #16-13,D0
                swap    D0
                and.w   D4,D0           ; even
                move.w  D0,(A0)+

                addq.w  #1,D6
                dbra    D7,ist_l
                rts

                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
blob_pre_values_X:DS.W XM*AMOUNT_BLOBS
blob_pre_values_Y:DS.W YM*AMOUNT_BLOBS
blob_pre_values_Z:DS.W ZM*AMOUNT_BLOBS
;-------------------------------------------------------------------------------


xr_sin:         DC.W 0
xr_cos:         DC.W 0
yr_sin:         DC.W 0
yr_cos:         DC.W 0

rotate_blobs_flag:DC.W 0

move_blobs:     PART

                movea.l sintab_adr,A0
                lea     (A0),A1

*    bra.s   no_rot

                move.b  rotate_blobs_flag(PC),D0
                beq.s   no_rot

; use with care!! (esp. when also having a waveform!)

                adda.w  xr,A0
                adda.w  yr,A1
no_rot:

                move.w  (A0),xr_sin
                move.w  COS(A0),xr_cos

                move.w  (A1),yr_sin
                move.w  COS(A1),yr_cos


*   DC.L $4AFC4E71

                move.w  #SIN_MASK,D7
                movea.l sintab_adr,A6

                lea     blob0(PC),A0
                bsr     move_blob_process
                lea     blob1(PC),A0
                bsr     move_blob_process
                lea     blob2(PC),A0
                bsr     move_blob_process
                lea     blob3(PC),A0
                bsr     move_blob_process
                lea     blob4(PC),A0
                bsr     move_blob_process


                lea     blob0(PC),A0
                bsr     rotate_blob
                lea     blob1(PC),A0
                bsr     rotate_blob
                lea     blob2(PC),A0
                bsr     rotate_blob
                lea     blob3(PC),A0
                bsr     rotate_blob
                lea     blob4(PC),A0
                bsr     rotate_blob

                rts
                ENDPART
move_blob_process:PART          ; A0...blob

A:
                move.w  alpha(A0),D0
                and.w   D7,D0           ; SIN_MASK

                move.w  beta(A0),D1
                and.w   D7,D1           ; SIN_MASK

                move.w  gamma(A0),D2
                and.w   D7,D2           ; SIN_MASK


                move.b  blobs_move_flag(PC),D6
                beq.s   no_incbl

                move.w  alpha_inc(A0),D6
                add.w   D6,alpha(A0)

                move.w  beta_inc(A0),D6
                add.w   D6,beta(A0)

                move.w  gamma_inc(A0),D6
                add.w   D6,gamma(A0)
no_incbl:

; set wave
                move.w  0(A6,D0.w),D3   ; sin(alpha)
                move.w  0(A6,D1.w),D4   ; sin(gamma)
                muls    #400*4,D3
                muls    #300*4,D4
                add.l   D4,D3
                swap    D3
                move.w  D3,xb(A0)

*    asr.w   #1,D1
*    and.w   D7,D1

                move.w  0(A6,D1.w),D3   ; sin(b)
                muls    #300*4,D3

                add.w   #COS,D2
                move.w  0(A6,D2.w),D4   ; cos(gamma)
                muls    #300*4,D4
                add.l   D4,D3
                swap    D3
                move.w  D3,yb(A0)

                move.w  0(A6,D2.w),D3   ; sin(g)
                add.w   #COS,D1
                muls    0(A6,D1.w),D3
                asl.l   #2,D3
                swap    D3
                muls    #300*4,D3
                swap    D3
*  add.w   #200,D3         ; z+200
*  DONE IN ROTATION!
                move.w  D3,zb(A0)
                rts

                ENDPART
rotate_blob:    >PART           ; A0...blob

                movem.w xb(A0),D0-D2    ; x,y,z
; x-rot
                asl.w   #2,D1
                asl.w   #2,D2
                move.w  D1,D3
                move.w  D2,D4
                muls    xr_cos(PC),D1
                muls    xr_sin(PC),D4
                add.l   D4,D1
                swap    D1

                muls    xr_cos(PC),D2
                muls    xr_sin(PC),D3
                sub.l   D3,D2
                swap    D2
; y-rot
                asl.w   #2,D0
                asl.w   #2,D2
                move.w  D0,D3
                move.w  D2,D4
                muls    yr_cos(PC),D0
                muls    yr_sin(PC),D4
                add.l   D4,D0
                swap    D0

                muls    yr_cos(PC),D2
                muls    yr_sin(PC),D3
                sub.l   D3,D2
                swap    D2

*  add.w   #200,D2         ; z+200

                add.w   #300,D2

; also z translation in intersection 3D->2D rout!

                movem.w D0-D2,xb(A0)

                rts

                ENDPART

init_blobs:     >PART
*  DC.L $4AFC4E71

                lea     blobs_init_list(PC),A1
                lea     blob0(PC),A0
                bsr     iblob
                lea     blob1(PC),A0
                bsr     iblob
                lea     blob2(PC),A0
                bsr     iblob
                lea     blob3(PC),A0
                bsr     iblob
                lea     blob4(PC),A0
                bsr     iblob
                rts
iblob:
                move.w  (A1)+,alpha(A0)
                move.w  (A1)+,alpha_inc(A0)
                move.w  (A1)+,beta(A0)
                move.w  (A1)+,beta_inc(A0)
                move.w  (A1)+,gamma(A0)
                move.w  (A1)+,gamma_inc(A0)
                rts
                ENDPART
blobs_init_list:>PART
; (0)
                DC.W 0*2        ; alpha:          RS.W 1
                DC.W 50*2       ; alpha_inc:      RS.W 1
                DC.W 4*409*2    ; beta:           RS.W 1
                DC.W 60*2       ; beta_inc:       RS.W 1
                DC.W -555*2     ; gamma:          RS.W 1
                DC.W 68*2       ; gamma_inc:      RS.W 1
; (1)
                DC.W 409*2      ; alpha:          RS.W 1
                DC.W 40*2       ; alpha_inc:      RS.W 1
                DC.W 3*409*2    ; beta:           RS.W 1
                DC.W 35*2       ; beta_inc:       RS.W 1
                DC.W -2*555*2   ; gamma:          RS.W 1
                DC.W -48*2      ; gamma_inc:      RS.W 1
; (2)
                DC.W 2*409*2    ; alpha:          RS.W 1
                DC.W -46*2      ; alpha_inc:      RS.W 1
                DC.W 2*409*2    ; beta:           RS.W 1
                DC.W -60*2      ; beta_inc:       RS.W 1
                DC.W -3*555*2   ; gamma:          RS.W 1
                DC.W 48*2       ; gamma_inc:      RS.W 1
; (3)
                DC.W 3*409*2    ; alpha:          RS.W 1
                DC.W 54*2       ; alpha_inc:      RS.W 1
                DC.W 409*2      ; beta:           RS.W 1
                DC.W 39*2       ; beta_inc:       RS.W 1
                DC.W -4*555*2   ; gamma:          RS.W 1
                DC.W -48*2      ; gamma_inc:      RS.W 1
; (4)
                DC.W 4*409*2    ; alpha:          RS.W 1
                DC.W -43*2      ; alpha_inc:      RS.W 1
                DC.W 0          ; beta:           RS.W 1
                DC.W -49*2      ; beta_inc:       RS.W 1
                DC.W -5*555*2   ; gamma:          RS.W 1
                DC.W 56*2       ; gamma_inc:      RS.W 1

                ENDPART

blob0:          DS.B struct_blob
blob1:          DS.B struct_blob
blob2:          DS.B struct_blob
blob3:          DS.B struct_blob
blob4:          DS.B struct_blob

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

; A0...texture
init_texture:   >PART

                movea.l texture_adr(PC),A1
                lea     128(A1),A2
                lea     128*256,A3
                adda.l  A1,A3
                lea     128(A3),A4

                moveq   #128-1,D7
ity:
                moveq   #128-1,D6
itx:
                move.b  (A0)+,D4
                lsl.b   #3,D4           ; texel_size = 8
                move.b  D4,(A1)+
                move.b  D4,(A2)+
                move.b  D4,(A3)+
                move.b  D4,(A4)+

                dbra    D6,itx

                adda.w  #128,A1
                adda.w  #128,A2
                adda.w  #128,A3
                adda.w  #128,A4

                dbra    D7,ity

                move.l  #256*256,D0
; mirror textures
                movea.l texture_adr(PC),A0
                lea     (A0),A1
                suba.l  D0,A1
*   bsr     copy_256x256

                lea     (A0),A1
                adda.l  D0,A1
*   bsr     copy_256x256

                rts
                ENDPART

; A0-->A1
copy_256x256:   >PART
                movem.l D7-A1,-(SP)
                move.w  #256*256/8-1,D7
ctex:
                move.l  (A0)+,(A1)+
                move.l  (A0)+,(A1)+
                dbra    D7,ctex
                movem.l (SP)+,D7-A1
                rts
                ENDPART

;-------------------------------------------------------------------------------
; A0...bmp
read_bmp_texture:>PART
                movem.l D0-A6,-(SP)

                move.l  A0,bmp_adr

                bsr     read_bmp_header

                bsr     display_bmp

*   DC.L $4AFC4E71

                movea.l texture_adr(PC),A0
                lea     (A0),A1
                suba.l  #65536,A1
                move.w  #256,D7
                bsr     copy_texlines

                movea.l texture_adr(PC),A0
                lea     (A0),A1
                adda.l  #65536,A1
                move.w  #128,D7
                bsr     copy_texlines

                movem.l (SP)+,D0-A6
                rts

copy_texlines:
                subq.w  #1,D7
ctl_y:
                REPT 256/4
                move.l  (A0)+,(A1)+
                ENDR
                dbra    D7,ctl_y
                rts

                ENDPART
bmp_adr:        DC.L 0
;------------------------------------------------
read_bmp_header:>PART
*  DC.L $4AFC4E71

                movea.l bmp_adr(PC),A0

                lea     10(A0),A1
                bsr     read32
                move.l  D0,bfOffBits

                lea     18(A0),A1
                bsr     read32
                move.l  D0,biWidth

                lea     22(A0),A1
                bsr     read32
                move.l  D0,biHeight

                lea     28(A0),A1
                bsr     read16
                move.l  D0,biBitCount
                moveq   #1,D1
                lsl.l   D0,D1
                move.l  D1,amount_colors

                rts
                ENDPART
read32:         >PART
                addq.l  #4,A1
                move.b  -(A1),D0
                lsl.l   #8,D0
                move.b  -(A1),D0
                lsl.l   #8,D0
                move.b  -(A1),D0
                lsl.l   #8,D0
                move.b  -(A1),D0
                rts
                ENDPART
read16:         >PART
                moveq   #0,D0
                addq.l  #2,A1
                move.b  -(A1),D0
                lsl.l   #8,D0
                move.b  -(A1),D0
                rts
                ENDPART
;------------------------------------------------
bmp_set_colors: >PART

*   DC.L $4AFC4E71

                lea     $FFFF8240.w,A6

                movea.l bmp_adr(PC),A0
                lea     54(A0),A0

                lea     colors,A5

                move.l  amount_colors(PC),D7
                subq.w  #1,D7
bsc:
                move.b  (A0)+,D0        ; blue
                bsr     bsc_pc2st
                move.w  D0,D2           ; blue

                move.b  (A0)+,D0        ; green
                bsr     bsc_pc2st
                move.w  D0,D1           ; green

                move.b  (A0)+,D0        ; red
                bsr     bsc_pc2st

                addq.l  #1,A0

                lsl.w   #4,D0
                or.w    D1,D0           ; green
                lsl.w   #4,D0
                or.w    D2,D0

                move.w  D0,(A5)+        ; colors

                move.w  D0,(A6)+        ; hw regs
                dbra    D7,bsc
                rts
bsc_pc2st:
                and.w   #$00FF,D0
                mulu    #7,D0
                divu    #$00FF,D0
                rts
                ENDPART
                >PART ' bmp data '
bfOffBits:      DC.L 0
biWidth:        DC.L 0
biHeight:       DC.L 0
biBitCount:     DC.L 0
amount_colors:  DC.L 0
                ENDPART
;------------------------------------------------
display_bmp:    >PART

*    DC.L $4AFC4E71

*    bsr     bmp_set_colors

                move.l  biWidth(PC),D6
                lsr.l   #4,D6

                move.l  biHeight(PC),D6

                movea.l bmp_adr(PC),A0
                adda.l  bfOffBits(PC),A0

                move.l  biWidth(PC),D0
                lsr.l   #1,D0           ; 4bpp
                move.l  biHeight(PC),D1
                subq.l  #1,D1
                move.l  D1,D7           ; dg_y loop_counter
                mulu    D0,D1
*  adda.l  D1,A0; backwards

                movea.l texture_adr(PC),A6
dg_y:
*   pea     -128/2(A0)      ; backwards

                pea     128/2(A0)       ; forwards

                pea     256(A6)

                lea     (A6),A1
                lea     128(A6),A2
                lea     128*256,A3
                adda.l  A6,A3
                lea     128(A3),A4

                moveq   #128/2-1,D6
dg_x:
                move.b  (A0)+,D0
                moveq   #$0F,D1
                and.b   D0,D1
                lsr.b   #4,D0

                lsl.b   #3,D0           ; texel_size=8
                lsl.b   #3,D1           ; texel_size=8

                move.b  D0,(A1)+
                move.b  D1,(A1)+

                move.b  D0,(A2)+
                move.b  D1,(A2)+

                move.b  D0,(A3)+
                move.b  D1,(A3)+

                move.b  D0,(A4)+
                move.b  D1,(A4)+

                dbra    D6,dg_x

                movea.l (SP)+,A6
                movea.l (SP)+,A0

                dbra    D7,dg_y

                rts

                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------


;-------------------------------------------------------------------------------
init_texturemapper:>PART
                bsr     init_cuvx_rout_table
                bsr     init_divtable_polygon
                bsr     init_polydiv_table2
                rts
                ENDPART
;-------------------------------------------------------------------------------
init_divtable_polygon:>PART

*   DC.L $4AFC4E71

                lea     divtable_polygon(PC),A0
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

                lea     polydiv_table2_neg(PC),A0
                lea     polydiv_table2_end+2(PC),A1
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
init_cuvx_rout_table:>PART
*   DC.L $4AFC4E71

                lea     cuvx_s+159*cuvx_size(PC),A0
                lea     cuvx_rout_table(PC),A1
                move.w  #160-1,D7
icvrtl:
                move.l  A0,(A1)+
                lea     -cuvx_size(A0),A0
                dbra    D7,icvrtl
                rts
                ENDPART
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
divtable_polygon:DS.W 512
polydiv_table2_neg:DS.W 1024
polydiv_table2: DS.W 1024
polydiv_table2_end:DS.W 1
;-------------------------------------------------------------------------------

clip_x_tmap     EQU 80
clip_y_tmap     EQU 50

                RSSET $00000140
y_clip_flag:    RS.W 1
y_pos:          RS.W 1


TRI_MAP:        >PART
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
                and.b   D2,D1
                and.b   D3,D1
                bne.s   cx_total
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
                lea     render_x_code+2+159*4(PC),A6
                move.b  y_clip_flag.w,D1
                beq.s   rxc_noclip
                lea     render_x_codeCLIP+2+159*4(PC),A6
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

cuvx_rout_table:DS.L 160

cuvx_s:
o               SET 0
                REPT 160
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
cuvx_size       SET (cuvx_e-cuvx_s)/160
;------------------------------------------------------------

                lea     colorram,A6
                move.w  (A1),D0         ;y1
                move.w  D0,y_pos.w
                muls    #CRAM_X_line,D0
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

left_fix        EQU -$00008000  ;  -$00018000

right_fix       EQU $00018000   ;  -$00018000

u_fix           EQU $00000000
v_fix           EQU $00000000

left_right_swap_flag EQU $00000140

rechts_lt_links:
                DC.L $4AFC4E71
                rts

RENDER_TRI:     >PART

*   DC.L $4AFC4E71

                move.b  y_clip_flag.w,D4
                bne     RENDER_TRI_CLIP_Y

                add.l   #left_fix,D0
                add.l   #right_fix,D1

                lea     render_x_code+160*4(PC),A4
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
                REPT 160
                move.b  0(A5),-(A6)
                ENDR

                move    USP,A6
                lea     CRAM_X_line(A6),A6 ; save scanline pos.

                add.l   A0,D0           ;x_links  inc
                add.l   A1,D1           ;x_rechts inc
                add.l   A2,D2           ;U Inc
                add.l   A3,D3           ;V Inc
                dbra    D7,RT_loop

                sub.l   #left_fix,D0
                sub.l   #right_fix,D1

                rts

                ENDPART

RENDER_TRI_CLIP_Y:>PART

*   DC.L $4AFC4E71

                move.w  y_pos.w,D6

                add.l   #left_fix,D0
                add.l   #right_fix,D1

                lea     render_x_codeCLIP+160*4(PC),A4
RT_loop_cY:
                cmp.w   #clip_y_tmap-1,D6
                bhi     next_line_cy

                move.l  D0,D4           ;x_links
                move.l  D1,D5           ;x_rechts
                swap    D4
                swap    D5

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
                REPT 160
                move.b  0(A5),-(A6)
                ENDR

                move    USP,A6
next_line_cy:
                lea     CRAM_X_line(A6),A6 ; next scanline pos.
                add.l   A0,D0           ;x_links  inc
                add.l   A1,D1           ;x_rechts inc
                add.l   A2,D2           ;U Inc
                add.l   A3,D3           ;V Inc
                addq.w  #1,D6           ; y_pos++

                dbra    D7,RT_loop_cY

                move.w  D6,y_pos.w

                sub.l   #left_fix,D0
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


sintab_adr:     DC.L 0

screen0:        DC.L 0
screen1:        DC.L 0
c2p_adr:        DC.L 0,0
texture_adr:    DC.L 0

bmp:
                PATH 'C:\0NEW\TDOME\'
                PATH '0YMPART\MARCUBES\'
                IBYTES 'TEX2.BMP'

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
heightIntrotxt  EQU 24
;-------------------------------------------------------------------------------
TEXT0           EQU 20
TEXT1           EQU 20+64
TEXT2           EQU 20+64+64
;------------------------------------
TFIX            EQU 4

TB0             SET TEXT1-1-TFIX
TB1             SET TEXT2-TEXT1-1-TFIX
;-------------------------------------------------------------------------------
init_marching_intro:>PART

                bsr     make_fades_colors

                lea     pi1+34,A0
                move.w  #TEXT0,D0
                bsr.s   set_itext
                move.w  #TEXT1,D0
                bsr.s   set_itext
                move.w  #TEXT2,D0
                bsr.s   set_itext

                lea     cubes_pi1+34,A0
                movea.l screen0,A1
                move.w  #32000/4-1,D7
cg00:
                move.l  (A0)+,(A1)+
                dbra    D7,cg00
init_timer_b:
                jsr     wait_vbl
                move    #$2700,SR
                move.l  #rte,$00000120.w
                clr.b   $FFFFFA1B.w
                bset    #0,$FFFFFA07.w  ;Timer B
                bset    #0,$FFFFFA13.w  ;Timer B

                move.l  #vbl_tb_1st,vbl_slot_first.w
                move    #$2300,SR
                jsr     wait_vbl

                move.l  screen1(PC),D0
                lsr.w   #8,D0
                move.l  D0,$FFFF8200.w

                jsr     wait_vbl

                rts

set_itext:
                mulu    #160,D0
                movea.l screen1,A1
                adda.l  D0,A1
                move.w  #heightIntrotxt*160/4-1,D7
c00q:
                move.l  (A0)+,(A1)+
                dbra    D7,c00q
                rts

                ENDPART

wait_intro_done:>PART
                jsr     wait_vbl
                move.b  intro_done_flag,D0
                beq.s   wait_intro_done
                rts
                ENDPART

make_fades_colors:>PART

                lea     black,A0
                lea     white,A1
                lea     black_white_fades,A2
                bsr     make_fades

                lea     white,A0
                lea     pi1+2,A1
                lea     white_normal_fades,A2
                bsr     make_fades

                lea     white,A0
                lea     cubes_pi1+2,A1
                lea     white_cubes_fades,A2
                bsr     make_fades

                rts
                ENDPART
;-------------------------------------------------------------------------------
; A0...pal0
; A1...pal1
; A2...output
make_fades:     >PART

*   DC.L $4AFC4E71

                movem.l A0-A1,pal0_mf

                clr.w   -(SP)           ; fade factor
mfl_fadesI:
                move.w  (SP),D0         ; fade1
                move.w  D0,fade_d7
                moveq   #8,D6
                sub.w   D0,D6           ; fade0
                move.w  D6,fade_d6

                movem.l pal0_mf,A0-A1

                move.w  #16-1,-(SP)     ; amount colors
mfl_colorsI:

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

                move.w  fade_d6,D6
                mulu    D6,D0           ; f0
                mulu    D6,D1           ; f0
                mulu    D6,D2           ; f0

                move.w  fade_d7,D6
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
                bpl.s   mfl_colorsI
                addq.l  #2,SP

                addq.w  #1,(SP)
                cmpi.w  #8,(SP)         ; 0...8
                ble.s   mfl_fadesI
                addq.l  #2,SP
                rts
                ENDPART
;-------------------------------------------------------------------------------
colors0_ptr:    DC.L black      ; white
colors1_ptr:    DC.L white
colors2_ptr:    DC.L white
;----------------------------------
vbl_tb_1st:     >PART

                move    #$2700,SR
                move.b  #0,$FFFFFA1B.w

                move.b  timer_b_intro_flag,D0
                beq.s   ntbi

                move.b  #TB0,$FFFFFA21.w
                move.b  #8,$FFFFFA1B.w
                move.l  #timer_b_start,$00000120.w

                bset    #0,$FFFFFA07.w  ;Timer B
                bset    #0,$FFFFFA13.w  ;Timer B

ntbi:
                tas.b   vsem
                bne.s   vsemL
                move    #$2300,SR

                jsr     script_rout
                clr.b   vsem
vsemL:
                movea.l colors0_ptr(PC),A0
                movem.l (A0),D0-D7
                movem.l D0-D7,$FFFF8240.w
                rts

vsem:           DC.W 0

timer_b_start:
                move    #$2700,SR
                move.b  #0,$FFFFFA1B.w
                movem.l A0-A2,-(SP)
                movea.l colors1_ptr(PC),A0
                addq.l  #2,A0
                lea     $FFFFFA21.w,A1
                lea     $FFFF8242.w,A2
                move.b  #128,(A1)
                move.b  #8,$FFFFFA1B.w
tbsync:         tst.b   (A1)
                bmi.s   tbsync

                REPT 7
                move.l  (A0)+,(A2)+
                ENDR
                move.w  (A0)+,(A2)+

                move.b  #0,$FFFFFA1B.w
                move.b  #TB1,$FFFFFA21.w
                move.b  #8,$FFFFFA1B.w
                move.l  #timer_b2,$00000120.w
                movem.l (SP)+,A0-A2
                rte
timer_b2:
                move    #$2700,SR
                move.b  #0,$FFFFFA1B.w
                movem.l A0-A2,-(SP)
                movea.l colors2_ptr(PC),A0
                addq.l  #2,A0
                lea     $FFFFFA21.w,A1
                lea     $FFFF8242.w,A2
                move.b  #128,(A1)
                move.b  #8,$FFFFFA1B.w
tbsync2:        tst.b   (A1)
                bmi.s   tbsync2
                REPT 7
                move.l  (A0)+,(A2)+
                ENDR
                move.w  (A0)+,(A2)+

                move.b  #0,$FFFFFA1B.w
                move.l  #timerb_end,$00000120.w
                movem.l (SP)+,A0-A2
                rte
timerb_end:
                move.b  #0,$FFFFFA1B.w
                rte

                ENDPART


TB0_C           SET 66
TB1_C           SET 66

vbl_tb_1st_cubes:>PART

                move    #$2700,SR
                move.b  #0,$FFFFFA1B.w

                move.b  timer_b_intro_flag,D0
                beq.s   ntbi2

                move.b  #TB0_C,$FFFFFA21.w
                move.b  #8,$FFFFFA1B.w
                move.l  #timer_b_startC,$00000120.w

                bset    #0,$FFFFFA07.w  ;Timer B
                bset    #0,$FFFFFA13.w  ;Timer B
ntbi2:
                tas.b   vsem
                bne.s   vsemL2
                move    #$2300,SR

                jsr     script_rout
                clr.b   vsem
vsemL2:
                movea.l colors0_ptr(PC),A0
                movem.l (A0),D0-D7
                movem.l D0-D7,$FFFF8240.w
                rts

timer_b_startC:
                move    #$2700,SR
                move.b  #0,$FFFFFA1B.w
                movem.l A0-A2,-(SP)
                movea.l colors1_ptr(PC),A0
                addq.l  #2,A0
                lea     $FFFFFA21.w,A1
                lea     $FFFF8242.w,A2
                move.b  #128,(A1)
                move.b  #8,$FFFFFA1B.w
tbsyncC:        tst.b   (A1)
                bmi.s   tbsyncC

                REPT 7
                move.l  (A0)+,(A2)+
                ENDR
                move.w  (A0)+,(A2)+

                move.b  #0,$FFFFFA1B.w
                move.b  #TB1_C,$FFFFFA21.w
                move.b  #8,$FFFFFA1B.w
                move.l  #timer_b2C,$00000120.w
                movem.l (SP)+,A0-A2
                rte
timer_b2C:
                move    #$2700,SR
                move.b  #0,$FFFFFA1B.w
                movem.l A0-A2,-(SP)
                movea.l colors2_ptr(PC),A0
                addq.l  #2,A0
                lea     $FFFFFA21.w,A1
                lea     $FFFF8242.w,A2
                move.b  #128,(A1)
                move.b  #8,$FFFFFA1B.w
tbsync2C:       tst.b   (A1)
                bmi.s   tbsync2C
                REPT 7
                move.l  (A0)+,(A2)+
                ENDR
                move.w  (A0)+,(A2)+

                move.b  #0,$FFFFFA1B.w
                move.l  #timerb_endC,$00000120.w
                movem.l (SP)+,A0-A2
                rte
timerb_endC:
                move.b  #0,$FFFFFA1B.w
                rte

                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
__FADE_INC:     >PART
                move.l  (A0)+,fade_color_ptr
                move.l  (A0)+,D0
                move.l  (A0)+,destfadePtr
                move.w  D0,fade_speed
                clr.w   fade_scounter
                clr.w   fade_num
                move.w  #1,fade_num_inc
                move.l  A0,script_pos
                move.l  #fade_do_subI,script_sub_fade
                rts
;-------------------------------------
fade_num_inc:   DC.W 0
fade_color_ptr: DC.L 0          ; current fadelist
fade_current_colorsP:DC.L 0
;-------------------------------------
                ENDPART
__FADE_DEC:     >PART
                move.l  (A0)+,fade_color_ptr
                move.l  (A0)+,D0
                move.l  (A0)+,destfadePtr
                move.w  D0,fade_speed
                clr.w   fade_scounter
                move.w  #8,fade_num
                move.w  #-1,fade_num_inc
                move.l  A0,script_pos
                move.l  #fade_do_subI,script_sub_fade
                rts
;-------------------------------------
                ENDPART
fade_do_subI:   >PART

                subq.w  #1,fade_scounter
                bpl.s   fds_not_yet
                move.w  fade_speed,fade_scounter

                move.w  fade_num,D0
                mulu    #16*2,D0
                add.l   fade_color_ptr(PC),D0
                move.l  D0,fade_current_colorsP

                movea.l destfadePtr(PC),A1
                move.l  D0,(A1)

*     movea.l D0,A1
*     movem.l (A1)+,D0-D6/A3
*     movem.l D0-D6/A3,$FFFF8240.w

                move.w  fade_num,D0
                move.w  fade_num_inc(PC),D1
                add.w   D1,D0
                bmi.s   fds_done
                cmp.w   #8,D0
                bgt.s   fds_done
                move.w  D0,fade_num
fds_not_yet:
                rts
fds_done:
                clr.l   script_sub_fade
                rts

destfadePtr:    DC.L 0

                ENDPART
__FADE_WAIT:    >PART
                move.l  script_sub_fade,D0
                bne.s   fwmore
                move.l  A0,script_pos
fwmore:
                rts
                ENDPART

timer_b_intro_flag:DC.W 0
intro_done_flag:DC.W 0

script_intro:   PART

*   DC.L GOTO,stest2

                DC.L turn_off_music_timer_b

                DC.L __FADE_INC
                DC.L black_white_fades,5
                DC.L colors0_ptr
                DC.L __FADE_WAIT

                DC.L ST,timer_b_intro_flag

                DC.L __FADE_INC
                DC.L white_normal_fades,10
                DC.L colors0_ptr
                DC.L __FADE_WAIT

                DC.L __FADE_INC
                DC.L white_normal_fades,12
                DC.L colors1_ptr
                DC.L __FADE_WAIT

                DC.L __FADE_INC
                DC.L white_normal_fades,14
                DC.L colors2_ptr
                DC.L __FADE_WAIT

                DC.L WAIT,2*50

                DC.L __FADE_DEC
                DC.L white_normal_fades,8
                DC.L colors2_ptr
                DC.L __FADE_WAIT

                DC.L __FADE_DEC
                DC.L white_normal_fades,4
                DC.L colors1_ptr
                DC.L __FADE_WAIT

                DC.L __FADE_DEC
                DC.L white_normal_fades,2
                DC.L colors0_ptr
                DC.L __FADE_WAIT

                DC.L SF,timer_b_intro_flag
;------------------------------------------------------------

                DC.L start_mcubes_pi1

                DC.L ST,timer_b_intro_flag

                DC.L __FADE_INC
                DC.L white_cubes_fades,4
                DC.L colors0_ptr
                DC.L __FADE_WAIT

                DC.L __FADE_INC
                DC.L white_cubes_fades,4
                DC.L colors1_ptr
                DC.L __FADE_WAIT

                DC.L __FADE_INC
                DC.L white_cubes_fades,4
                DC.L colors2_ptr
                DC.L __FADE_WAIT

                DC.L WAIT,2*50

                DC.L __FADE_DEC
                DC.L white_cubes_fades,2
                DC.L colors0_ptr
                DC.L __FADE_WAIT

                DC.L __FADE_DEC
                DC.L white_cubes_fades,2
                DC.L colors1_ptr
                DC.L __FADE_WAIT

                DC.L __FADE_DEC
                DC.L white_cubes_fades,2
                DC.L colors2_ptr
                DC.L __FADE_WAIT

                DC.L SF,timer_b_intro_flag

                DC.L WAIT,5

                DC.L turn_on_music_timer_b

                DC.L ST,intro_done_flag

                DC.L HALT
;-----------------------------------------------------

                ENDPART

start_mcubes_pi1:
                move.l  A0,script_pos
                move.l  #vbl_tb_1st_cubes,vbl_slot_first.w

                lea     white,A1
                move.l  A1,colors0_ptr
                move.l  A1,colors1_ptr
                move.l  A1,colors2_ptr

                move.l  screen0,D0
                lsr.w   #8,D0
                move.l  D0,$FFFF8200.w
                rts

turn_off_music_timer_b:>PART
                move.l  A0,script_pos
                move.l  #"TBOF",D0      ; music timer b off
                movea.l LIB_ADR.w,A3
                jsr     (A3)
                rts
                ENDPART
turn_on_music_timer_b:>PART
                move.l  A0,script_pos
                move.l  #"TBON",D0      ; music timer b on
                movea.l LIB_ADR.w,A3
                jsr     (A3)
                rts
                ENDPART
;-------------------------------------------------------------------------------
white_normal_fades:DS.W 9*16
black_white_fades:DS.W 9*16
white_cubes_fades:DS.W 9*16

pi1:
                PATH 'C:\0NEW\TDOME\0YMPART\'
                PATH 'MARCUBES\'
                IBYTES 'TEXT5.PI1',11554
cubes_pi1:
                IBYTES 'CUBES1.PI1'
;----------------------------------------------------------------------------------

                DATA

colors:         >PART
                DC.W $0000
                DC.W $0001      ;1
                DC.W $0111      ;2
                DC.W $0112      ;3
                DC.W $0122      ;4
                DC.W $0123      ;5
                DC.W $0233      ;6
                DC.W $0334      ;7
                DC.W $0344      ;8
                DC.W $0345      ;9
                DC.W $0445      ;10
                DC.W $0456      ;11
                DC.W $0556      ;12
                DC.W $0556      ;13
                DC.W $0666      ;14
                DC.W $0777      ;15
                ENDPART

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
                IFNE TEST
;-------------------------------------------------------------------------------
DRIVER_INC:
                PATH 'C:\0NEW\TDOME\0YMPART\'
                IBYTES 'DISKBLIB.PRG'
                EVEN
;-------------------------------------------------------------------------------
                ENDC


                BSS

                IFNE TEST
                DS.B 512
stack:          DS.B 2

sintab:         DS.W 2*2048
                ENDC

BSS_START:      DS.B 2

zf_table_neg:   DS.W 4096
zf_table:       DS.W 4096


                DS.B 1024
colorram:       DS.B 256*50
                DS.B 1024

;-------------- Marching Cubes ------------------------

;;*blob_strength_table:DS.L (65536*2)/4
;;*normalize_table:DS.L (65536*2)/4

blob_strength_table:DS.W 32000
normalize_table:DS.W 16384

square_table:   DS.W 2*16384

_1_15_divtable_neg:DS.W 16384
_1_15_divtable: DS.W 16384
_1_15_divtable_end:DS.W 1


ia:
iso_array:
                DS.W (ZM)*(YM)*(XM)
iso_xyz:
                DS.W (ZM)*(YM)*(XM)*3
iso_nx_ny:                              ; nx.w, ny.w
                DS.W (ZM)*(YM)*(XM)*2
normals_used_flags:
                DS.B ZM*YM*XM
;------------------------------------------------------

                DS.B 256
scr_ram:        DS.B 2*32000


                DS.L 65536/4    ;; FOR A 65536 BOUNDARY!!
zero_base:
                DS.L 65536/4    ;C2P
                DS.L 65536/4    ;C2P

                DS.B 256*256
                DS.B 256*256    ;128*128  but stored as 256*128
                DS.B 128*256
trashmem:

BSS_END:        DS.B 2

                END
