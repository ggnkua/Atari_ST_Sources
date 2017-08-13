;-------------------------------------------------------------------------------
TEST            EQU 1
;-------------------------------------------------------------------------------
SIN_MASK        EQU $00000FFE   ; 2048*2-2
COS             EQU $00000400   ; 2048/4*2
;-------------------------------------------------------------------------------
                RSSET $00000038
music_vbl:      RS.L 1
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
; Simple 4x4 Chunky plasma      (w)2014 lsl/checkpoint
;
; exclusively for pat! (don't spread!)
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

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

                move.l  #rts,music_vbl.w

                bclr    #3,$FFFFFA17.w  ; auto eoi

                move.l  #vbl,$00000070.w
                move    #$2300,SR
                bsr     wait_vbl

                move.l  #screen_ram,D0
                clr.b   D0
                lea     screen0(PC),A0
                move.l  D0,(A0)+
                add.l   #32000,D0
                move.l  D0,(A0)+
                lsr.w   #8,D0
                move.l  D0,$FFFF8200.w
                bsr     wait_vbl
                bsr     wait_vbl
                clr.b   $FFFF8260.w
                move.b  #2,$FFFF820A.w

                ENDPART
                ENDC

                lea     BSS_START(PC),A0
                lea     BSS_END,A1
                bsr     memclr_a0_a1

                bsr     wait_vbl

                lea     colors(PC),A0
                movem.l (A0),D0-D6/A0
                movem.l D0-D6/A0,$FFFF8240.w

*  jsr     instr_cycle     ******************* measure instruction time

                move.l  #zerobase,D0
                clr.w   D0
                move.l  D0,c2p_adr


                bsr     init_c2p_table

                IFNE TEST
                bsr     init_sintab
                ENDC

;-------------------------------------------------------------------------------
loop:
*  bra.s   no_swap_l
                bsr     swap_screens
no_swap_l:
                bsr     wait_vbl

                clr.w   $FFFF8240.w

                bsr.s   effect_main

*  move.w  #$0007,$FFFF8240.w

                move.b  $FFFFFC02.w,D0
                cmp.b   #$39,D0         ; space?
j:              beq.s   el
                bra.s   loop

el:
                DC.L $4AFC4E71
                bra.s   loop
e:
                move    #$2700,SR
                DC.L $4AFC4E71
                DC.L $4AFC4E71
                DC.L $4AFC4E71



effect_main:    PART

                bsr.s   plasma

                bsr     output_colorram_normal

                bsr     inc_w

                rts

                ENDPART

;-------------------------------------------------------------------------------
cycle:          DC.L 0

plasma:         PART

                bsr     calc_plasma_x   ; calculate x coefficients

                movea.l sintab_adr(PC),A0

                movem.w w2(PC),D5-D6

                move.w  #SIN_MASK,D4

                move.w  #63*4,D2        ; masker

                moveq   #5+2+2,D3       ; amplitude

                lea     colorram(PC),A1 ; output

                move.w  #50-1,-(SP)     ; y loop counter
fxt_y:
                and.w   D4,D5
                and.w   D4,D6
                movem.w 0(A0,D5.w),D0   ; sin
                movem.w 0(A0,D6.w),D1   ;+sin
                asl.l   #8,D0           ; amplitude
                asl.l   D3,D1           ; amplitude
                add.l   D1,D0

                add.w   #77*2,D5
                add.w   #61*2,D6

                moveq   #0,D1
                move.w  (SP),D1         ; y
                lsl.w   #3,D1
                swap    D1
                add.l   D1,D0           ;+y

                add.l   cycle(PC),D0

                lea     plasma_x_coeff(PC),A2

x               SET 0
                REPT 80
                move.l  (A2)+,D1        ; plasma(x)
                add.l   D0,D1           ;+plasma(y)
                asr.l   #3,D1
                swap    D1
                and.w   D2,D1           ; masker
                move.b  D1,(A1)+        ; chunky output

x               SET x+1
                ENDR

                subq.w  #1,(SP)
                bpl     fxt_y
                addq.l  #2,SP

                addi.l  #1*7*65536,cycle

                rts
                ENDPART
calc_plasma_x:  PART

                movea.l sintab_adr(PC),A0

                lea     plasma_x_coeff(PC),A1

                movem.w w0(PC),D5-D6

                move.w  #SIN_MASK,D4

                moveq   #5+2+2,D3       ; amplitude

x               SET 1
                REPT 80
                and.w   D4,D5
                and.w   D4,D6
                movem.w 0(A0,D5.w),D0   ; sin
                movem.w 0(A0,D6.w),D1   ;+sin
                asl.l   D3,D0           ; amplitude
                asl.l   #8,D1           ; amplitude
                add.l   #x*16*65536,D0
                move.l  D0,(A1)+

                add.w   #67*2,D5
                add.w   #51*2,D6
x               SET x+1
                ENDR
                rts
                ENDPART
plasma_x_coeff: DS.L 80
;-------------------------------------------------------------------------------
output_colorram_normal:>PART
                bsr.s   output_colorram
                bsr     quad_screen_y
                rts
                ENDPART
output_colorram:>PART

                lea     colorram(PC),A0

                movea.l screen1(PC),A1

                move.l  c2p_adr(PC),D0

                moveq   #50-1,D6
oc_y:

o               SET 0
oi              SET 1
                REPT 320/8
                move.w  (A0)+,D0        ; 2 pixel
                movea.l D0,A3
                move.l  (A3),D1
                movep.l D1,o(A1)
o               SET o+oi
oi              SET oi^6
                ENDR

                lea     4*160(A1),A1
                dbra    D6,oc_y
                rts
                ENDPART
quad_screen_y:  >PART

                movea.l screen1(PC),A3

                REPT 50
                movem.l (A3)+,D0-D6/A0-A2 ;10*4 = 40
                movem.l D0-D6/A0-A2,-40+1*160(A3)
                movem.l D0-D6/A0-A2,-40+2*160(A3)
                movem.l D0-D6/A0-A2,-40+3*160(A3)

                movem.l (A3)+,D0-D6/A0-A2 ;10*4 = 40
                movem.l D0-D6/A0-A2,-40+1*160(A3)
                movem.l D0-D6/A0-A2,-40+2*160(A3)
                movem.l D0-D6/A0-A2,-40+3*160(A3)

                movem.l (A3)+,D0-D6/A0-A2 ;10*4 = 40
                movem.l D0-D6/A0-A2,-40+1*160(A3)
                movem.l D0-D6/A0-A2,-40+2*160(A3)
                movem.l D0-D6/A0-A2,-40+3*160(A3)

                movem.l (A3)+,D0-D6/A0-A2 ;10*4 = 40
                movem.l D0-D6/A0-A2,-40+1*160(A3)
                movem.l D0-D6/A0-A2,-40+2*160(A3)
                movem.l D0-D6/A0-A2,-40+3*160(A3)

                lea     3*160(A3),A3
                ENDR
                rts

                ENDPART
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
inc_w:          >PART

                moveq   #5-1,D0

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
zoom_w0:        DC.W 0
;------------------------------------
w0_inc:         DC.W (78)*2
w1_inc:         DC.W (-65)*2

w2_inc:         DC.W -(86)*2
w3_inc:         DC.W -(43)*2

zoom_w0_inc:    DC.W (2*16)*2
                DC.W 8*2

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

                movea.l music_vbl.w,A0
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
rts:            rts
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

                movea.l screen1(PC),A0

                lea     (A0),A1
                lea     (A0),A2
                lea     (A0),A3
                lea     (A0),A4
                lea     (A0),A5
                lea     (A0),A6

                lea     $FFFF8800.w,A6

                lea     es(PC),A2

                move.w  #$0120,D0
                move.w  #$0020,D1

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

                move.l  0(A0,D0.w),D1

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
; 256/4 = 64 / 16 = 4
init_c2p_table: >PART

*   DC.L $4AFC4E71

                movea.l c2p_adr(PC),A0
                lea     ic2pt_16cols_movepl(PC),A2
                moveq   #64-1,D6
ic2p_t_0:
                lea     ic2pt_colors(PC),A1
                moveq   #64-1,D0
                sub.w   D6,D0
                move.b  0(A1,D0.w),D0
                lsl.w   #2,D0
                move.l  0(A2,D0.w),D0   ; movepl
                lsl.l   #4,D0           ; hi

                moveq   #0,D1
                lea     ic2pt_colors(PC),A1
                REPT 64
                move.b  (A1)+,D1
                lsl.w   #2,D1
                move.l  0(A2,D1.w),D2   ; movepl
                or.l    D0,D2
                move.l  D2,(A0)+
                ENDR

                lea     $0300(A0),A0

                dbra    D6,ic2p_t_0
                rts

ic2pt_16cols_movepl:
                OPT O-,W-
F               SET $000F
                DC.B 0,0,0,0    ;0
                DC.B F,0,0,0    ;1
                DC.B 0,F,0,0    ;2
                DC.B F,F,0,0    ;3
                DC.B 0,0,F,0    ;4
                DC.B F,0,F,0    ;5
                DC.B 0,F,F,0    ;6
                DC.B F,F,F,0    ;7
                DC.B 0,0,0,F    ;8
                DC.B F,0,0,F    ;9
                DC.B 0,F,0,F    ;10
                DC.B F,F,0,F    ;11
                DC.B 0,0,F,F    ;12
                DC.B F,0,F,F    ;13
                DC.B 0,F,F,F    ;14
                DC.B F,F,F,F    ;15
                OPT O+,W+


o               SET 0
                REPT 32         ;1
                DC.B o/2
o               SET o+1
                ENDR
                REPT 32         ;2
o               SET o-1
                DC.B o/2
                ENDR

ic2pt_colors:
;-----------------------------------------
o               SET 0
                REPT 64         ;1
                DC.B o/4
o               SET o+1
                ENDR
;-----------------------------------------


o               SET 0
                REPT 16         ;1
                DC.B o
o               SET o+1
                ENDR
                REPT 16         ;2
o               SET o-1
                DC.B o
                ENDR
                REPT 16         ;3
                DC.B o
o               SET o+1
                ENDR
                REPT 16         ;4
o               SET o-1
                DC.B o
                ENDR

                ENDPART
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
memclr_a0_a1:   >PART
                move.l  A1,D0           ; end
                sub.l   A0,D0           ;-start
                bsr.s   memclr
                rts
                ENDPART
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

c2p_adr:        DC.L 0,0
sintab_adr:     DC.L 0

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

                IFNE TEST
;-------------------------------------------------------------------------------
load_file:      >PART           ;A0 Filename   A1 Buffer

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
                moveq   #-1,D0
                bra.s   lf_done
err_lf:
                moveq   #-1,D0
                rts

file_handle:    DC.W 0
                ENDPART
save_file:      >PART           ;A0 Filename   A1 Buffer  D0 length

                move.l  D0,fsize
                lea     (A1),A6         ; buffer

                move.w  #0,-(SP)        ;normal file
                pea     (A0)
                move.w  #$003C,-(SP)    ;fcreate
                trap    #1
                addq.l  #8,SP
                move.w  D0,file_handle
                move.l  D0,D7
                bmi.s   err_sf

                pea     (A6)            ;buffer
                move.l  fsize(PC),-(SP) ;count
                move.w  D7,-(SP)        ;handle
                move.w  #$0040,-(SP)    ;fwrite
                trap    #1
                lea     $000C(SP),SP
                tst.l   D0
                bmi.s   err_sf

                move.l  D0,-(SP)

                move.w  D7,-(SP)        ;handle
                move.w  #$003E,-(SP)    ;close
                trap    #1
                addq.l  #4,SP

                move.l  (SP)+,D0
sf_done:
                rts
fsize:          DC.L 0

err_save_file:
                moveq   #-1,D0
                bra.s   sf_done
err_sf:
                moveq   #-1,D0
                rts
                ENDPART
;-------------------------------------------------------------------------------
                ENDC

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

                DATA

zero:           DS.L 16

colors:         >PART
                DC.W $0000      ;            0 ;

                DC.W $0100      ;    0       1 ;

                DC.W $0101      ;   1        2 ;
                DC.W $0102      ;   10       3 ;

                DC.W $0112      ;  2         4 ;
                DC.W $0213      ;  2 0       5 ;
                DC.W $0214      ;  21        6 ;
                DC.W $0225      ;  210       7 ;

                DC.W $0326      ; 3          8 ;
                DC.W $0337      ; 3  0       0 ;
                DC.W $0346      ; 3 1       10 ;
                DC.W $0355      ; 3 10      11 ;
                DC.W $0244      ; 32        12 ;
                DC.W $0133      ; 32 0      13 ;
                DC.W $0022      ; 321       14 ;
                DC.W $0011      ; 3210      15 ;

                ENDPART

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

                BSS
BSS_START:

colorram:       DS.B 50*80

                DS.L 65536/4
zerobase:
                DS.L 65536/4    ;c2p
;-------------------------------------------------------------------------------
                IFNE TEST

sintab:         DS.W 2*2048

                DS.B 256
screen_ram:
                DS.B 32000
                DS.B 32000
BSS_END:

                DS.B 512
stack:          DS.B 2

                ENDC
;-------------------------------------------------------------------------------
                END
