;-------------------------------------------------------------------------------
IC_X            EQU (320+320)
IC_Y            EQU (200+200)
;-------------------------------------------------------------------------------
SIN_MASK        EQU $00000FFE   ; 2048*2-2
COS             EQU $00000400   ; 2048/4*2
;-------------------------------------------------------------------------------
; interference circles
; (w)2013 lsl/checkpoint
;-------------------------------------------------------------------------------
                OPT D+
                >PART ' init '
                clr.l   -(SP)
                move.w  #$0020,-(SP)
                trap    #1
                lea     stack,SP
                move    #$2700,SR
                clr.b   $FFFFFA07.w
                clr.b   $FFFFFA09.w
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
                clr.b   $FFFF8260.w

                movem.l colors,D0-D7
                movem.l D0-D7,$FFFF8240.w
                ENDPART
;-------------------------------------------------------------------------------

                bsr     icirc_preshift

                bsr     init_sintab
loop:
                bsr     swap_screens
                bsr     wait_vbl
                clr.w   $FFFF8240.w

                bsr     ic_wave

                movem.w x0(PC),D0-D1
                bsr     draw_circle_1plane

                movem.w x1(PC),D0-D1
                bsr     draw_circle_2planes

                bsr     inc_w

                move.w  #$0007,$FFFF8240.w

                move.b  $FFFFFC02.w,D0
                cmp.b   #$39,D0
                bne     loop
                DC.L $4AFC4E71
                bra     loop

x0:             DC.W 0
y0:             DC.W 0

x1:             DC.W 0
y1:             DC.W 0

swap_screens:
                move.l  screen1(PC),D0
                move.l  screen0(PC),screen1
                move.l  D0,screen0
                lsr.w   #8,D0
                move.l  D0,$FFFF8200.w
                rts

ic_wave:        >PART

                lea     sintab,A0
                lea     (A0),A1
                lea     (A0),A2
                lea     (A0),A3
                adda.w  w0(PC),A0
                adda.w  w1(PC),A1
                adda.w  w2(PC),A2
                adda.w  w3(PC),A3

                move.w  (A0),D0
                muls    #(160-16)*4/2,D0
                swap    D0
                move.w  D0,x0

                move.w  (A1),D0
                muls    #99*4,D0
                swap    D0
                move.w  D0,y0
;--------------------------------------------
                move.w  (A2),D0
                muls    #(160-16)*4/2,D0
                swap    D0
                move.w  D0,x1

                move.w  (A3),D0
                muls    #99*4,D0
                swap    D0
                move.w  D0,y1
                rts

                ENDPART

;-------------------------------------------------------------------------------
inc_w:          >PART
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
w0_inc:         DC.W 24*2
w1_inc:         DC.W 16*2
w2_inc:         DC.W 26*2
w3_inc:         DC.W 20*2
                ENDPART
;-------------------------------------------------------------------------------
vbl:            >PART
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
                move.w  D4,2048*2(A0)
                move.w  D4,2*2048*2(A0)
                move.w  D4,3*2048*2(A0)
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

                DATA
screen0:        DC.L 0
screen1:        DC.L 0

c0              SET $0557
c1              SET $0447
c01             SET $0334

c3              SET $0777
c7_             EQU $00000070
colors:         >PART
                DC.W $0000      ;            0 ;
                DC.W c0         ;    0       1 ;  ***
                DC.W c1         ;   1        2 ;
                DC.W c01        ;   10       3 ;
                DC.W c7_        ;  2         4 ;
                DC.W c7_        ;  2 0       5 ;
                DC.W c7_        ;  21        6 ;
                DC.W c7_        ;  210       7 ;
                DC.W c0         ; 3          8 ;  ***
                DC.W c0         ; 3  0       0 ;
                DC.W c01        ; 3 1       10 ;
                DC.W c01        ; 3 10      11 ;
                DC.W c7_        ; 32        12 ;
                DC.W c7_        ; 32 0      13 ;
                DC.W c7_        ; 321       14 ;
                DC.W c7_        ; 3210      15 ;
                ENDPART
;-------------------------------------------------------------------------------

; D0...X
; D1...Y
draw_circle_1plane:>PART

*   DC.L $4AFC4E71

                bsr     get_circle_pos

                movea.l screen1,A1
                addq.l  #2,A1           ; plane1

                bsr     display_icirc_1plane
                rts
                ENDPART

; D0...X
; D1...Y
draw_circle_2planes:>PART

*   DC.L $4AFC4E71

                bsr     get_circle_pos

                movea.l screen1,A1
                addq.l  #3*2,A1         ; plane 3 & 0

                bsr     display_icirc_2planes
                rts
                ENDPART


; D0.x, D1.y
get_circle_pos: >PART
; center
                add.w   #(IC_X/2-160+8)/2,D0
                add.w   #(IC_Y-200)/2,D1

                lea     icirc_list,A0
                moveq   #7,D2
                and.w   D0,D2           ; shift

                neg.w   D2
                addq.w  #7,D2

                lsl.w   #2,D2
                movea.l 0(A0,D2.w),A0

                lsr.w   #3,D0           ; x offset
                add.w   D0,D0           ;
                adda.w  D0,A0           ;

                muls    #IC_X/8,D1
                adda.l  D1,A0
                rts

                ENDPART

; A0-->A1
display_icirc_1plane:>PART

                moveq   #(IC_X-320)/8,D0
                move.w  #200-1,D1
di1p_y:
                move.w  (A0)+,(A1)
                move.w  (A0)+,1*8(A1)
                move.w  (A0)+,2*8(A1)
                move.w  (A0)+,3*8(A1)
                move.w  (A0)+,4*8(A1)
                move.w  (A0)+,5*8(A1)
                move.w  (A0)+,6*8(A1)
                move.w  (A0)+,7*8(A1)
                move.w  (A0)+,8*8(A1)
                move.w  (A0)+,9*8(A1)
                move.w  (A0)+,10*8(A1)
                move.w  (A0)+,11*8(A1)
                move.w  (A0)+,12*8(A1)
                move.w  (A0)+,13*8(A1)
                move.w  (A0)+,14*8(A1)
                move.w  (A0)+,15*8(A1)
                move.w  (A0)+,16*8(A1)
                move.w  (A0)+,17*8(A1)
                move.w  (A0)+,18*8(A1)
                move.w  (A0)+,19*8(A1)
                adda.w  D0,A0
                lea     160(A1),A1
                dbra    D1,di1p_y
                rts
                ENDPART

; A0-->A1
display_icirc_2planes:>PART

                moveq   #(IC_X-320)/8,D0
                move.w  #200-1,D1
di2p_y:
                move.l  (A0)+,(A1)
                move.l  (A0)+,1*16(A1)
                move.l  (A0)+,2*16(A1)
                move.l  (A0)+,3*16(A1)
                move.l  (A0)+,4*16(A1)
                move.l  (A0)+,5*16(A1)
                move.l  (A0)+,6*16(A1)
                move.l  (A0)+,7*16(A1)
                move.l  (A0)+,8*16(A1)
                move.l  (A0)+,9*16(A1)
                adda.w  D0,A0
                lea     160(A1),A1
                dbra    D1,di2p_y
                rts
                ENDPART


icirc_preshift: >PART

*  DC.L $4AFC4E71

                lea     icirc_gfx,A0
                lea     icirc_list,A1
                lea     icirc_preshifted,A2

                move.l  A0,(A1)+        ; 1st shift

                move.w  #8-1-1,-(SP)    ; 7 shifts
icps_s:
                bsr.s   icps_shift_do

                subq.w  #1,(SP)
                bpl.s   icps_s
                addq.l  #2,SP
                rts

icps_shift_do:

; A0...previous
; A1...list
; A2...current
                move.l  A2,(A1)         ; current shift

                move.w  #IC_Y-1,D6
icps_s_y:

                moveq   #0,D0
                move.w  (A0),D0
                swap    D0
                lsr.l   #2,D0
                move.w  D0,(A2)+

o               SET 0
                REPT (IC_X/16)-1
                move.l  o(A0),D0
                lsr.l   #2,D0           ; shift by 2 pixels
                move.w  D0,(A2)+
o               SET o+2
                ENDR

                lea     IC_X/8(A0),A0
                dbra    D6,icps_s_y

                movea.l (A1)+,A0        ; previous = current

                rts

                ENDPART

icirc_gfx:
                PATH 'C:\0NEW\TDOME\'
                PATH 'ICIRCLES\MAKECIRC\'
                IBYTES 'FSINTERF.GFX'

                BSS

sintab:         DS.W 2048*4

icirc_list:     DS.L 8          ; 8 shifts
icirc_preshifted:
                DS.B 7*IC_Y*IC_X/8 ; 7 shifts

stack_top:      DS.B 512
stack:          DS.B 4


                DS.B 256
screen_ram:
                DS.B 32000
                DS.B 32000

                END
