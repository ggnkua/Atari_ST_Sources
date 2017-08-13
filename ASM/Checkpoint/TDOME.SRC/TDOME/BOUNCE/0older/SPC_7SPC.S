;-------------------------------------------------------------------------------
SIN_MASK        EQU $00000FFE   ; 2048*2-2
COS             EQU $00000400   ; 2048/4*2
;-------------------------------------------------------------------------------
TEST            EQU 1
;-------------------------------------------------------------------------------
;
; SPC_7SPW.SRC ... max. optimized init-routine
;
; SPC_5SPW.SRC ... fading!
;                  fade-init needs to be optimized!!
;
; SPC_4SPW.SRC ... Spectrum512 bouncer, SPW input file
;
;
;-------------------------------------------------------------------------------
                >PART ' mod-player struct '
                RSSET 0
HBL_replay:     RS.B 1
TIMER_replay:   RS.B 1
spectrum_replay:RS.B 1
set_spectrum_color_adr_:RS.B 1  ; A0...colors start
get_colptr_inc_code_:RS.B 1     ; A0...output list
                ENDPART
;-------------------------------------------------------------------------------
                >PART ' sys struct '
                RSSET $000004CE
vbl_slot_first: RS.L 1          ; first executed vbl slot
vbl_slot0:      RS.L 1          ; fx vbl slot
script_slot:    RS.L 1
colors_ptr:     RS.L 1
EFFECT_TERMINATE_SIGNAL:RS.B 1
res0:           RS.B 1
res1:           RS.B 1
res2:           RS.B 1
;-------------------------------------------------------------------------------
                ENDPART
;-------------------------------------------------------------------------------


PLAYER_ADR      EQU $00000200   ; *** NEEDS TO BE FIXED ***


;-------------------------------------------------------------------------------
                RSSET 0
SPW_ID0:        RS.L 1
SPW_ID:         RS.L 1
SPW_col0:       RS.W 1
SPW_col15:      RS.W 1
SPW_gfx:        RS.B 32000
SPW_colors_9bit:RS.L 0

COLORS_FRAME_SIZE EQU $000041A8 ; size of colormap used by routine

LINES_SHIFT     EQU 8

                OPT D+

                IFNE TEST
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
                move.l  #PLAYER_INC,PLAYER_ADR.w
                ENDC

                bsr     wait_vbl

                lea     black(PC),A0
                movem.l (A0),D0-D6/A0
                movem.l D0-D6/A0,$FFFF8240.w

                lea     BSS_START,A0
                lea     BSS_END,A1
                bsr     memclr_a0_a1

                bsr     init_screens

*  jsr     instr_cycle     ******************* measure instruction time

                bsr     init_sintab



                bsr     wait_vbl

                bsr     init_SPW_decoder

                lea     pic_SPW(PC),A0
                bsr     SPW_decode

                move.l  $00000466.w,D0
*  DC.L $4AFC4E71

;-------------------------------------------------------------------------------
                IFNE TEST
                bsr     save_mem
                lea     $00000500.w,A0
                move.w  #($2000-$0500)/2-1,D0
f00:            move.w  #$2121,(A0)+
                dbra    D0,f00

                bsr     INIT_MOD_AND_START

                ENDC
;-------------------------------------------------------------------------------

                lea     colors_d6_modi_list(PC),A0
                moveq   #get_colptr_inc_code_,D0
                bsr     PLAYER

; call effect first
                bsr     wait_vbl
                move.w  #COS,w0
                bsr     wave
                bsr     bounce_main
                bsr     Bounce_vbl


* movea.l color_adr_start(PC),A0
* move.l  A0,color_adr
* moveq   #set_spectrum_color_adr_,D0
* jsr     PLAYER

;;moveq   #TIMER_replay,D0
                moveq   #spectrum_replay,D0 ; start Spectrum512 Modplay
                bsr     PLAYER

                bsr     wait_vbl

                move.l  #Bounce_vbl,vbl_slot_first.w

;-------------------------------------------------------------------------------
loop:
                bsr     wait_vbl

*     move.w  #$0700,$FFFF8240.w

*   bsr     Bounce_vbl

*    clr.w   $FFFF8240.w

                move.b  $FFFFFC02.w,D0
                cmp.b   #$3B,D0
                bne.s   n_f1
                move.l  #wave_bounce,wave_rout
                bra.s   loop
n_f1:
                cmp.b   #$3C,D0
                bne.s   n_f2
                move.l  #wave_const_y_pos,wave_rout
                bra.s   loop
n_f2:
                cmp.b   #$003B+9,D0     ; f10?
                beq     e
                cmp.b   oldk(PC),D0
                beq.s   samekey
                move.b  D0,oldk
                cmp.b   #$62,D0
                bne.s   n62
                not.b   showp
n62:
samekey:
                cmp.b   #$39,D0
                bne.s   loop
                DC.L $4AFC4E71
                bra.s   loop
oldk:           DC.B 0
showp:          DC.B 0

;-------------------------------------------------------------------------------
colors_d6_modi_list:DS.L 280
                DS.L 200

colors_d6_modi_old_ptr:DC.L 0

restore_old_d6_modi:>PART
                move.l  colors_d6_modi_old_ptr(PC),D0
                beq.s   no_d6_old
                movea.l D0,A1
                move.w  #$4E71,(A1)     ; restore
no_d6_old:
                rts
                ENDPART

d6_modi_reset:
                moveq   #-3*14*2,D6

Bounce_vbl:     >PART

*  DC.L $4AFC4E71

;-----------------------------------------------------------------
; set d6 color_ptr reset code

                bsr.s   restore_old_d6_modi

                lea     colors_d6_modi_list(PC),A0

                move.w  y_pos(PC),D0
                neg.w   D0
                add.w   #198,D0

                add.w   D0,D0
                add.w   D0,D0
                move.l  0(A0,D0.w),D0
                move.l  D0,colors_d6_modi_old_ptr
                beq.s   no_d6_set
                movea.l D0,A0
                move.w  d6_modi_reset(PC),(A0) ; reset color ptr
no_d6_set:
;-----------------------------------------------------------------
                movea.l color_adr_start(PC),A0

                move.w  spectrum_fade(PC),D0
                mulu    #COLORS_FRAME_SIZE,D0 ; size of colormap used by routine
                adda.l  D0,A0

                move.w  y_pos(PC),D0
                mulu    #3*14*2,D0
                adda.l  D0,A0

                moveq   #set_spectrum_color_adr_,D0
                bsr     PLAYER

                bsr.s   wave

                bsr.s   bounce_main

                rts
                ENDPART
;-------------------------------------------------------------------------------
y_pos:          DC.W 0
spectrum_fade:  DC.W 0
;-------------------------------------------------------------------------------
y_pos_scale:    DC.W 256
wave_rout:      DC.L wave_bounce
wave:           >PART
                movea.l wave_rout(PC),A0
                jmp     (A0)
                ENDPART
;--------------------------
wave_bounce:    >PART
;----------------------------------------------
                lea     y_pos_scale(PC),A0
                addq.w  #4,(A0)
                cmpi.w  #256,(A0)
                ble.s   yps_ok
                move.w  #256,(A0)
yps_ok:
;----------------------------------------------
                ENDPART
wave_bounce_calc:>PART
                lea     sintab,A0
                adda.w  w0(PC),A0

                move.w  (A0),D0

*   muls    D0,D0
*   asl.l   #2,D0
*   swap    D0
*   muls    #(200+80)*4,D0
*   swap    D0

* muls    #(200+90)*4,D0

                muls    #(150)*4,D0
                bpl.s   *+2
                neg.l   D0
                swap    D0

                muls    y_pos_scale(PC),D0
                asr.l   #8,D0

                move.w  D0,y_pos

                bsr     inc_w

                rts
                ENDPART
;--------------------------
wave_const_y_pos:>PART

*  move.w  #0,y_pos

                lea     y_pos_scale(PC),A0
                subq.w  #4,(A0)
                bpl.s   yps_ok2
                clr.w   (A0)
yps_ok2:
                bsr.s   wave_bounce_calc

                rts
                ENDPART
;-------------------------------------------------------------------------------
bounce_main:    >PART

*   DC.L $4AFC4E71

                move.w  y_pos(PC),D0
                bpl.s   y_pos_pos
                moveq   #0,D0
y_pos_pos:
                cmp.w   #200,D0
                ble.s   y_pos_le
                move.w  #200,D0
y_pos_le:

; get fade
                move.w  D0,D1
                sub.w   #32,D1
                bpl.s   spc_pos
                moveq   #0,D1
spc_pos:
                lsl.w   #3,D1
                divu    #100,D1

                cmp.w   #8,D1
                ble.s   spectrum_fade_le8
                moveq   #8,D1
spectrum_fade_le8:
                move.w  D1,spectrum_fade


                addq.w  #LINES_SHIFT-1,D0 ; adjust y-position

                move.w  D0,D1
                lsr.w   #3,D0           ; hw screen line, 256 bytes boundary

                and.w   #LINES_SHIFT-1,D1
                neg.w   D1
                addq.w  #LINES_SHIFT-1,D1

                add.w   D1,D1
                add.w   D1,D1
                lea     screens_list(PC),A0
                move.l  0(A0,D1.w),D2   ; screen

                mulu    #8*160,D0

                add.l   D2,D0

                lsr.w   #8,D0
                move.l  D0,$FFFF8200.w  ; SET SCREEN

                rts
                ENDPART
;-------------------------------------------------------------------------------
init_screens:   >PART

                move.l  #screen_ram,D0
                clr.b   D0
                move.l  #32000,D1

                lea     screens_list(PC),A0
                moveq   #LINES_SHIFT-1,D2
is_l:
                move.l  D0,(A0)+
                add.l   D1,D0
                dbra    D2,is_l

* move.l  screens_list(PC),D0
* lsr.w   #8,D0
* move.l  D0,$FFFF8200.w

                rts
                ENDPART
;-------------------------------------------------------------------------------
screens_list:   DS.L 8
;-------------------------------------------------------------------------------
inc_w:          >PART
                lea     w0(PC),A0
                move.w  (A0),D0
                add.w   w0_inc(PC),D0
                and.w   #SIN_MASK,D0
                move.w  D0,(A0)
                rts
;-----------------------------------------------
                moveq   #4-1,D0
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
                >PART 'angles'
w0:             DC.W 0
w1:             DC.W 0
w2:             DC.W 0
w3:             DC.W 0
w0_inc:         DC.W 16*2
w1_inc:         DC.W 13*2
w2_inc:         DC.W -14*2
w3_inc:         DC.W -7*2
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
wv:
                tst.l   $00000466.w
                beq.s   wv
                rts
                ENDPART
rte:            rte
rts:            rts
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
                move.w  #2048-1,D7
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
                dbra    D7,init_sin_
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

                lea     screen_ram,A0

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
                bra     sloop

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

screen0:        DC.L 0
screen1:        DC.L 0

;-------------------------------------------------------------------------------
clear_screens:  >PART
                movea.l screen0(PC),A0
                move.l  #32000,D0
                bsr     memclr
                movea.l screen1(PC),A0
                move.l  #32000,D0
                bsr.s   memclr
                rts
                ENDPART
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

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
INIT_MOD_AND_START:>PART

                IFNE TEST

                clr.l   vbl_slot_first.w ; first executed vbl slot
                clr.l   vbl_slot0.w     ; fx vbl slot
                clr.l   script_slot.w
                clr.l   colors_ptr.w

                lea     mod,A0
                moveq   #-1,D0
                bsr     PLAYER

                ENDC

* moveq   #normal_replay,D0
* jsr     PLAYER

                rts

                ENDPART
;-------------------------------------------------------------------------------
e:              >PART
end:
                IFNE TEST
                move    #$2700,SR
                move.w  #$0700,$FFFF8240.w
                lea     stack,SP
                move.l  #rte,$00000068.w
                move.l  #rte,$00000070.w
                move.l  #rte,$00000120.w
                clr.l   $FFFFFA06.w
                clr.l   $FFFFFA12.w
                bsr.s   restore_mem
                move.w  #$0070,$FFFF8240.w
                DC.L $4AFC4E71
                DC.L $4AFC4E71
                DC.L $4AFC4E71
                ENDC
                ENDPART
                IFNE TEST
save_mem:       >PART
                move    #$2700,SR
                lea     $00000500.w,A0
                lea     mem_save,A1
                bsr.s   sm_copy
                move    #$2300,SR
                rts
sm_copy:
                move.w  #$8000/8-1,D0
sm0:
                move.l  (A0)+,(A1)+
                move.l  (A0)+,(A1)+
                dbra    D0,sm0
                rts
                ENDPART
restore_mem:    >PART
                move    #$2700,SR
                lea     mem_save,A0
                lea     $00000500.w,A1
                bsr.s   sm_copy
                rts
                ENDPART
                ENDC
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------



;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
pic_adr:        DC.L 0
color_adr:      DC.L 0
color_adr_start:DC.L 0
col0:           DC.W 0
col15:          DC.W 0
;-------------------------------------------------------------------------------
SPW_decode:     >PART           ; A0...SPW

*  DC.L $4AFC4E71

                move.l  A0,pic_adr

                move.w  SPW_col0(A0),col0
                move.w  SPW_col15(A0),col15

                bsr.s   init_spectrum_gfx_SPW

*  bsr     wait_vbl

                bsr     init_colors_SPW

*  move.l  $00000466.w,D0
*  DC.L $4AFC4E71

                rts

                ENDPART
;---------------------------------
init_spectrum_gfx_SPW:>PART

*  DC.L $4AFC4E71

; SPU:
; (0) syncline
; (1) 1st gfx line
; (2)
                bsr.s   copy_screens_gfx_SPW
                bra.s   gfx_copied2
;-----------------------------------------------
;-----------------------------------------------
                movea.l pic_adr(PC),A0  ; zeiger auf bilddaten
                movea.l screen1(PC),A1
; copy gfx lines
                move.w  #200*160/4-1,D1
showpic_loop2:  move.l  (A0)+,(A1)+
                dbra    D1,showpic_loop2
;-----------------------------------------------
;-----------------------------------------------
gfx_copied2:
                rts

                ENDPART
copy_screens_gfx_SPW:>PART      ; new version

*  DC.L $4AFC4E71

                lea     screens_list(PC),A0
                movea.l (A0)+,A1

                movea.l pic_adr(PC),A0  ; zeiger auf bilddaten
                lea     SPW_gfx(A0),A0

cs_next_screen  SET 32000+160

                lea     cs_next_screen(A1),A1 ; -1,0,+1 trick

                movea.l #3*cs_next_screen,A2

                move.w  #32000/32-1,-(SP)
cs_copy_new:
                movem.l (A0)+,D0-D6/A3  ; 32   SRC

                movem.l D0-D6/A3,-cs_next_screen(A1) ; 0
                movem.l D0-D6/A3,(A1)   ;              1
                movem.l D0-D6/A3,cs_next_screen(A1) ;  2
                adda.l  A2,A1           ;<1>
                movem.l D0-D6/A3,-cs_next_screen(A1) ; 3
                movem.l D0-D6/A3,(A1)   ;              4
                movem.l D0-D6/A3,cs_next_screen(A1) ;  5
                adda.l  A2,A1           ;<2>
                movem.l D0-D6/A3,-cs_next_screen(A1) ; 6
                movem.l D0-D6/A3,(A1)   ;              7

                adda.l  #32-2*3*cs_next_screen,A1

                subq.w  #1,(SP)
                bcc.s   cs_copy_new
                addq.l  #2,SP

                rts
                ENDPART
;---------------------------------
init_colors_SPW:>PART

                movea.l pic_adr(PC),A0  ; zeiger auf bilddaten
                adda.l  #SPW_colors_9bit,A0

                lea     colsdecoded,A1  ;      output
                move.l  A1,color_adr
                move.l  A1,color_adr_start
                bsr.s   color_decoder_faded

                bsr.s   clear_color_lines_end

* lea     colsdecoded,A0  ;      output
* move.l  A1,D0
* sub.l   A0,D0

                rts
                ENDPART
clear_color_lines_end:>PART
                moveq   #0,D0           ; col
                move.w  #2*3*14-1,D6
cc_clearlines_col_l:
                move.w  D0,(A1)+
                dbra    D6,cc_clearlines_col_l
                rts
                ENDPART
;-------------------------------------------------------------------------------

;-----------------------------------------------------
init_SPW_decoder:>PART

                bsr     init_fade_multable

                bsr     init_9bit_to_0RGB_tabV2

                rts
                ENDPART
;-----------------------------------------------------
; A0...9bit stream
; A1...output

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
; A0...9bit packed rgb
; A1...faded output
color_decoder_faded:>PART

*  DC.L $4AFC4E71

                lea     COLORS_FRAME_SIZE(A1),A1 ; -1,0,+1 trick


                lea     _9bit_to_0RGB_table,A2

                move.l  #2-2*3*COLORS_FRAME_SIZE,D3 ; next col

                move.w  #(198*3*14+16)/16-1,D4 ; loop counter

                moveq   #9,D5           ;        9 bits shift

                move.w  #511,D6         ;        9 bit masker

; D0...bits
; D1...sub_bits fill / temp
; D2...temp
; D3
; D4...loop counter
; D5...9 const
; D6...511 (9 bit masker)
                ENDPART
color_decode_loop:
;-- Decodes 16 values ---
;-----------------------------------------------
                move.l  (A0)+,D0        ; 32 bit
; 32 bits left
;-----------------------------------------------
; 32/9 = 3, rest 5
                REPT 3
                >PART ' decode 1 color faded '

                rol.l   D5,D0           ; 9
                move.w  D0,D1
                and.w   D6,D1           ; 511
; 9*2 = 18
                add.w   D1,D1           ; *2
                move.w  D1,D2
                lsl.w   #3,D2           ;*16
                add.w   D2,D1           ;*18

                lea     (A2),A3
                adda.w  D1,A3

                move.l  #3*COLORS_FRAME_SIZE,D1
; decode 9 fades
                move.w  (A3)+,-COLORS_FRAME_SIZE(A1) ; 0
                move.w  (A3)+,(A1)      ;              1
                move.w  (A3)+,COLORS_FRAME_SIZE(A1) ;  2
                adda.l  D1,A1           ;<1>
                move.w  (A3)+,-COLORS_FRAME_SIZE(A1) ; 3
                move.w  (A3)+,(A1)      ;              4
                move.w  (A3)+,COLORS_FRAME_SIZE(A1) ;  5
                adda.l  D1,A1           ;<2>
                move.w  (A3)+,-COLORS_FRAME_SIZE(A1) ; 6
                move.w  (A3)+,(A1)      ;              7
                move.w  (A3)+,COLORS_FRAME_SIZE(A1) ;  8
                adda.l  D3,A1           ; #2-2*3*COLORS_FRAME_SIZE,A1 | next col

                ENDPART
                ENDR
; 5 bits left
                and.l   #%11111000000000000000000000000000,D0
                moveq   #0,D1
                move.w  (A0)+,D1        ; 16 bit
                swap    D1
                lsr.l   #5,D1
                or.l    D1,D0
; 5+16 = 21
; 21 bits left
;-----------------------------------------------
; 21/9 = 2, rest 3
                REPT 2
                >PART ' decode 1 color faded '

                rol.l   D5,D0           ; 9
                move.w  D0,D1
                and.w   D6,D1           ; 511
; 9*2 = 18
                add.w   D1,D1           ; *2
                move.w  D1,D2
                lsl.w   #3,D2           ;*16
                add.w   D2,D1           ;*18

                lea     (A2),A3
                adda.w  D1,A3

                move.l  #3*COLORS_FRAME_SIZE,D1
; decode 9 fades
                move.w  (A3)+,-COLORS_FRAME_SIZE(A1) ; 0
                move.w  (A3)+,(A1)      ;              1
                move.w  (A3)+,COLORS_FRAME_SIZE(A1) ;  2
                adda.l  D1,A1           ;<1>
                move.w  (A3)+,-COLORS_FRAME_SIZE(A1) ; 3
                move.w  (A3)+,(A1)      ;              4
                move.w  (A3)+,COLORS_FRAME_SIZE(A1) ;  5
                adda.l  D1,A1           ;<2>
                move.w  (A3)+,-COLORS_FRAME_SIZE(A1) ; 6
                move.w  (A3)+,(A1)      ;              7
                move.w  (A3)+,COLORS_FRAME_SIZE(A1) ;  8
                adda.l  D3,A1           ; #2-2*3*COLORS_FRAME_SIZE,A1 | next col

                ENDPART
                ENDR
; 3 bits left
                and.l   #%11100000000000000000000000000000,D0
                moveq   #0,D1
                move.w  (A0)+,D1        ; 16 bit
                swap    D1
                lsr.l   #3,D1
                or.l    D1,D0
; 3+16 = 19
; 19 bits left
;-----------------------------------------------
; 19/9 = 2, rest 1
                REPT 2
                >PART ' decode 1 color faded '

                rol.l   D5,D0           ; 9
                move.w  D0,D1
                and.w   D6,D1           ; 511
; 9*2 = 18
                add.w   D1,D1           ; *2
                move.w  D1,D2
                lsl.w   #3,D2           ;*16
                add.w   D2,D1           ;*18

                lea     (A2),A3
                adda.w  D1,A3

                move.l  #3*COLORS_FRAME_SIZE,D1
; decode 9 fades
                move.w  (A3)+,-COLORS_FRAME_SIZE(A1) ; 0
                move.w  (A3)+,(A1)      ;              1
                move.w  (A3)+,COLORS_FRAME_SIZE(A1) ;  2
                adda.l  D1,A1           ;<1>
                move.w  (A3)+,-COLORS_FRAME_SIZE(A1) ; 3
                move.w  (A3)+,(A1)      ;              4
                move.w  (A3)+,COLORS_FRAME_SIZE(A1) ;  5
                adda.l  D1,A1           ;<2>
                move.w  (A3)+,-COLORS_FRAME_SIZE(A1) ; 6
                move.w  (A3)+,(A1)      ;              7
                move.w  (A3)+,COLORS_FRAME_SIZE(A1) ;  8
                adda.l  D3,A1           ; #2-2*3*COLORS_FRAME_SIZE,A1 | next col

                ENDPART
                ENDR
; 1 bit  left
                and.l   #%10000000000000000000000000000000,D0
                moveq   #0,D1
                move.w  (A0)+,D1        ; 16 bit
                swap    D1
                lsr.l   #1,D1
                or.l    D1,D0
; 1+16 = 17
; 17 bits left
;-----------------------------------------------
; 17/9 = 1, rest 8
                REPT 1
                >PART ' decode 1 color faded '

                rol.l   D5,D0           ; 9
                move.w  D0,D1
                and.w   D6,D1           ; 511
; 9*2 = 18
                add.w   D1,D1           ; *2
                move.w  D1,D2
                lsl.w   #3,D2           ;*16
                add.w   D2,D1           ;*18

                lea     (A2),A3
                adda.w  D1,A3

                move.l  #3*COLORS_FRAME_SIZE,D1
; decode 9 fades
                move.w  (A3)+,-COLORS_FRAME_SIZE(A1) ; 0
                move.w  (A3)+,(A1)      ;              1
                move.w  (A3)+,COLORS_FRAME_SIZE(A1) ;  2
                adda.l  D1,A1           ;<1>
                move.w  (A3)+,-COLORS_FRAME_SIZE(A1) ; 3
                move.w  (A3)+,(A1)      ;              4
                move.w  (A3)+,COLORS_FRAME_SIZE(A1) ;  5
                adda.l  D1,A1           ;<2>
                move.w  (A3)+,-COLORS_FRAME_SIZE(A1) ; 6
                move.w  (A3)+,(A1)      ;              7
                move.w  (A3)+,COLORS_FRAME_SIZE(A1) ;  8
                adda.l  D3,A1           ; #2-2*3*COLORS_FRAME_SIZE,A1 | next col

                ENDPART
                ENDR
; 8 bits left
                and.l   #%11111111000000000000000000000000,D0
                moveq   #0,D1
                move.w  (A0)+,D1        ; 16 bit
                swap    D1
                lsr.l   #8,D1
                or.l    D1,D0
; 8+16 = 24
; 24 bits left
;-----------------------------------------------
; 24/9 = 2, rest 6
                REPT 2
                >PART ' decode 1 color faded '

                rol.l   D5,D0           ; 9
                move.w  D0,D1
                and.w   D6,D1           ; 511
; 9*2 = 18
                add.w   D1,D1           ; *2
                move.w  D1,D2
                lsl.w   #3,D2           ;*16
                add.w   D2,D1           ;*18

                lea     (A2),A3
                adda.w  D1,A3

                move.l  #3*COLORS_FRAME_SIZE,D1
; decode 9 fades
                move.w  (A3)+,-COLORS_FRAME_SIZE(A1) ; 0
                move.w  (A3)+,(A1)      ;              1
                move.w  (A3)+,COLORS_FRAME_SIZE(A1) ;  2
                adda.l  D1,A1           ;<1>
                move.w  (A3)+,-COLORS_FRAME_SIZE(A1) ; 3
                move.w  (A3)+,(A1)      ;              4
                move.w  (A3)+,COLORS_FRAME_SIZE(A1) ;  5
                adda.l  D1,A1           ;<2>
                move.w  (A3)+,-COLORS_FRAME_SIZE(A1) ; 6
                move.w  (A3)+,(A1)      ;              7
                move.w  (A3)+,COLORS_FRAME_SIZE(A1) ;  8
                adda.l  D3,A1           ; #2-2*3*COLORS_FRAME_SIZE,A1 | next col

                ENDPART
                ENDR
; 6 bits left
                and.l   #%11111100000000000000000000000000,D0
                moveq   #0,D1
                move.w  (A0)+,D1        ; 16 bit
                swap    D1
                lsr.l   #6,D1
                or.l    D1,D0
; 6+16 = 22
; 22 bits left
;-----------------------------------------------
; 22/9 = 2, rest 4
                REPT 2
                >PART ' decode 1 color faded '

                rol.l   D5,D0           ; 9
                move.w  D0,D1
                and.w   D6,D1           ; 511
; 9*2 = 18
                add.w   D1,D1           ; *2
                move.w  D1,D2
                lsl.w   #3,D2           ;*16
                add.w   D2,D1           ;*18

                lea     (A2),A3
                adda.w  D1,A3

                move.l  #3*COLORS_FRAME_SIZE,D1
; decode 9 fades
                move.w  (A3)+,-COLORS_FRAME_SIZE(A1) ; 0
                move.w  (A3)+,(A1)      ;              1
                move.w  (A3)+,COLORS_FRAME_SIZE(A1) ;  2
                adda.l  D1,A1           ;<1>
                move.w  (A3)+,-COLORS_FRAME_SIZE(A1) ; 3
                move.w  (A3)+,(A1)      ;              4
                move.w  (A3)+,COLORS_FRAME_SIZE(A1) ;  5
                adda.l  D1,A1           ;<2>
                move.w  (A3)+,-COLORS_FRAME_SIZE(A1) ; 6
                move.w  (A3)+,(A1)      ;              7
                move.w  (A3)+,COLORS_FRAME_SIZE(A1) ;  8
                adda.l  D3,A1           ; #2-2*3*COLORS_FRAME_SIZE,A1 | next col

                ENDPART
                ENDR
; 4 bits left
                and.l   #%11110000000000000000000000000000,D0
                moveq   #0,D1
                move.w  (A0)+,D1        ; 16 bit
                swap    D1
                lsr.l   #4,D1
                or.l    D1,D0
; 4+16 = 20
; 20 bits left
;-----------------------------------------------
; 20/9 = 2, rest 2
                REPT 2
                >PART ' decode 1 color faded '

                rol.l   D5,D0           ; 9
                move.w  D0,D1
                and.w   D6,D1           ; 511
; 9*2 = 18
                add.w   D1,D1           ; *2
                move.w  D1,D2
                lsl.w   #3,D2           ;*16
                add.w   D2,D1           ;*18

                lea     (A2),A3
                adda.w  D1,A3

                move.l  #3*COLORS_FRAME_SIZE,D1
; decode 9 fades
                move.w  (A3)+,-COLORS_FRAME_SIZE(A1) ; 0
                move.w  (A3)+,(A1)      ;              1
                move.w  (A3)+,COLORS_FRAME_SIZE(A1) ;  2
                adda.l  D1,A1           ;<1>
                move.w  (A3)+,-COLORS_FRAME_SIZE(A1) ; 3
                move.w  (A3)+,(A1)      ;              4
                move.w  (A3)+,COLORS_FRAME_SIZE(A1) ;  5
                adda.l  D1,A1           ;<2>
                move.w  (A3)+,-COLORS_FRAME_SIZE(A1) ; 6
                move.w  (A3)+,(A1)      ;              7
                move.w  (A3)+,COLORS_FRAME_SIZE(A1) ;  8
                adda.l  D3,A1           ; #2-2*3*COLORS_FRAME_SIZE,A1 | next col

                ENDPART
                ENDR
; 2 bits left
                and.l   #%11000000000000000000000000000000,D0
                moveq   #0,D1
                move.w  (A0)+,D1        ; 16 bit
                swap    D1
                lsr.l   #2,D1
                or.l    D1,D0
; 2+16 = 18
; 18 bits left
;-----------------------------------------------
; 18/9 = 2 ***DONE***
                REPT 2
                >PART ' decode 1 color faded '

                rol.l   D5,D0           ; 9
                move.w  D0,D1
                and.w   D6,D1           ; 511
; 9*2 = 18
                add.w   D1,D1           ; *2
                move.w  D1,D2
                lsl.w   #3,D2           ;*16
                add.w   D2,D1           ;*18

                lea     (A2),A3
                adda.w  D1,A3

                move.l  #3*COLORS_FRAME_SIZE,D1
; decode 9 fades
                move.w  (A3)+,-COLORS_FRAME_SIZE(A1) ; 0
                move.w  (A3)+,(A1)      ;              1
                move.w  (A3)+,COLORS_FRAME_SIZE(A1) ;  2
                adda.l  D1,A1           ;<1>
                move.w  (A3)+,-COLORS_FRAME_SIZE(A1) ; 3
                move.w  (A3)+,(A1)      ;              4
                move.w  (A3)+,COLORS_FRAME_SIZE(A1) ;  5
                adda.l  D1,A1           ;<2>
                move.w  (A3)+,-COLORS_FRAME_SIZE(A1) ; 6
                move.w  (A3)+,(A1)      ;              7
                move.w  (A3)+,COLORS_FRAME_SIZE(A1) ;  8
                adda.l  D3,A1           ; #2-2*3*COLORS_FRAME_SIZE,A1 | next col

                ENDPART
                ENDR
                dbra    D4,color_decode_loop
                rts
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

;-----------------------------------------------------
fade_col:       DC.W $0777
fade_col_Rf:    DC.W 0
fade_col_Gf:    DC.W 0
fade_col_Bf:    DC.W 0

fade_fac:       DC.W 0

init_9bit_to_0RGB_tabV2:>PART   ; *** OPTI ***

*  DC.L $4AFC4E71

                lea     _9bit_to_0RGB_table,A3

                clr.w   fade_fac
i9b_fades_V2:
                pea     2(A3)           ; next fade address

                move.w  fade_fac(PC),D2

                move.w  fade_col(PC),D0
                moveq   #7,D1
                and.w   D0,D1           ; blue
                mulu    D2,D1
                move.w  D1,fade_col_Bf
                lsr.w   #4,D0
                moveq   #7,D1
                and.w   D0,D1           ; green
                mulu    D2,D1
                move.w  D1,fade_col_Gf
                lsr.w   #4,D0
                moveq   #7,D1
                and.w   D0,D1           ; red
                mulu    D2,D1
                move.w  D1,fade_col_Rf


                lea     fade_multable(PC),A0
                neg.w   D2
                addq.w  #8,D2           ; 1-f
                mulu    #8*2,D2
                adda.w  D2,A0

                move.l  A0,D5

                move.w  #7,-(SP)
i9_R_V2:
                move.w  fade_col_Rf(PC),D0 ;red
                add.w   (A0)+,D0
                lsr.w   #3,D0
                lsl.w   #8,D0

                movea.l D5,A1           ; fade_multable GREEN

                moveq   #7,D6
i9_G_V2:
                move.w  fade_col_Gf(PC),D1 ;green
                add.w   (A1)+,D1
                lsr.w   #3,D1
                lsl.w   #4,D1
                or.w    D0,D1           ; RGx

                move.w  fade_col_Bf(PC),D2 ;blue

                movea.l D5,A2           ; fade_multable BLUE

; blue inner & store

o               SET 0*9*2
                REPT 8

; can be optimzed! (smc, imm. offset register)

                move.w  D2,D3           ; fade_col_Bf
                add.w   (A2)+,D3
                lsr.w   #3,D3
                or.w    D1,D3           ; 0RGB
                move.w  D3,o(A3)        ; 0RGB Output
o               SET o+9*2
                ENDR

                lea     8*9*2(A3),A3

                dbra    D6,i9_G_V2

                subq.w  #1,(SP)
                bpl     i9_R_V2
                addq.l  #2,SP
;------------------------------------------------------
                movea.l (SP)+,A3

                lea     fade_fac(PC),A1
                addq.w  #1,(A1)
                cmpi.w  #8,(A1)
                ble     i9b_fades_V2

                rts

                ENDPART
;-----------------------------------------------------
init_fade_multable:>PART

                lea     fade_multable(PC),A0
                moveq   #0,D6           ; const ZERO

                moveq   #0,D0
ifm0:
                move.w  D0,D1
                move.w  D6,(A0)+        ; ZERO
                move.w  D1,(A0)+        ; ONE
                REPT 6
                add.w   D0,D1
                move.w  D1,(A0)+
                ENDR

                addq.w  #1,D0
                cmp.w   #8,D0
                ble.s   ifm0

                rts
                ENDPART
fade_multable:  DS.W 9*8
;-------------------------------------------------------------------------------


;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------


PLAYER:
                movea.l PLAYER_ADR.w,A3
                jsr     (A3)
                rts

                DATA

pic_SPW:
* PATH 'C:\0NEW\TDOME\SPECTRUM.512\'
                PATH 'C:\0NEW\TDOME\'
                PATH 'BOUNCE\'

                IBYTES 'SPWPIC.SPW'


;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
                IFNE TEST

                PATH 'C:\0NEW\TDOME\PROTRACK.512\'
PLAYER_INC:     IBYTES 'MODPLAY.BIN'
                EVEN

                ENDC
;-------------------------------------------------------------------------------
                IFNE TEST
mod:
                PATH 'C:\0NEW\TDOME\0MUSIC\'
                IBYTES 'TEST_6.MOD'
                EVEN
                DS.B $8000      ********   SIZE HAS TO BE OPTIMIZED !!!
                ENDC
;-------------------------------------------------------------------------------

                PATH 'C:\0NEW\TDOME\'
                PATH 'BOUNCE\'

                IFNE TEST
colors:         >PART
                DC.W $0000      ;0
                DC.W $0100      ;1
                DC.W $0200      ;2
                DC.W $0300      ;3
                DC.W $0400      ;4
                DC.W $0500      ;5
                DC.W $0600      ;6
                DC.W $0700      ;7
                DC.W $0710      ;8
                DC.W $0720      ;9
                DC.W $0730      ;10
                DC.W $0740      ;11
                DC.W $0750      ;12
                DC.W $0760      ;13
                DC.W $0770      ;14
                DC.W $0777      ;15
                ENDPART
                ENDC

                BSS

                IFNE TEST
mem_save:       DS.B $8000
                ENDC

                IFNE TEST
                DS.B 1024
stack:          DS.B 2
                ENDC

sintab:         DS.W 2*2048

BSS_START:

_9bit_to_0RGB_table:DS.W 9*512  ; 9 fades, 8x8x8 combinations

                DS.B 256
screen_ram:
                REPT LINES_SHIFT
                DS.B 32000
                ENDR
                DS.B 160*8      ; finescroll buffer

colsdecoded:
                DS.B 9*COLORS_FRAME_SIZE

BSS_END:
                DS.B 2

                END
