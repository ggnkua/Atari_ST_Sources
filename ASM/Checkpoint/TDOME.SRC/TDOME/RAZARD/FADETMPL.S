

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
script_rout:    >PART

*   DC.L $4AFC4E71

                move.l  script_sub_fade(PC),D0
                beq.s   *+4
                movea.l D0,A0
                jsr     (A0)

                move.l  script_sub_fadeR(PC),D0
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

script_sub_fade:DC.L 0
script_sub_fadeR:DC.L 0
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

__FADE_INC:     >PART
                move.l  (A0)+,fade_color_ptr
                move.l  (A0)+,D0
                move.w  D0,fade_speed
                clr.w   fade_scounter
                clr.w   fade_num
                move.w  #1,fade_num_inc
                move.l  A0,script_pos
                move.l  #fade_do_sub,script_sub_fade
                rts
;-------------------------------------
fade_speed:     DC.W 0
fade_scounter:  DC.W 0
fade_num:       DC.W 0
fade_num_inc:   DC.W 0
fade_color_ptr: DC.L 0          ; current fadelist
fade_current_colorsP:DC.L 0
;-------------------------------------
                ENDPART
__FADE_DEC:     >PART
                move.l  (A0)+,fade_color_ptr
                move.l  (A0)+,D0
                move.w  D0,fade_speed
                clr.w   fade_scounter
                move.w  #8,fade_num
                move.w  #-1,fade_num_inc
                move.l  A0,script_pos
                move.l  #fade_do_sub,script_sub_fade
                rts
;-------------------------------------
                ENDPART
fade_do_sub:    >PART
                subq.w  #1,fade_scounter
                bpl.s   fds_not_yet
                move.w  fade_speed(PC),fade_scounter

                move.w  fade_num(PC),D0
                mulu    #16*2,D0
                add.l   fade_color_ptr(PC),D0
                move.l  D0,fade_current_colorsP

                movea.l D0,A1
                movem.l (A1)+,D0-D6/A3
                movem.l D0-D6/A3,$FFFF8240.w

                move.w  fade_num(PC),D0
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
                ENDPART
__FADE_WAIT:    >PART
                move.l  script_sub_fade(PC),D0
                bne.s   fwmore
                move.l  A0,script_pos
fwmore:
                rts
                ENDPART

script:         >PART

*   DC.L GOTO,stest2

                DC.L __FADE_INC
                DC.L black_whiteR_fades,10
                DC.L __FADE_WAIT

                DC.L WAIT,5

                DC.L __FADE_INC
                DC.L white_normalR_fades,6
                DC.L __FADE_WAIT

                DC.L WAIT,10

                DC.L __FADE_DEC
                DC.L white_normalR_fades,4
                DC.L __FADE_WAIT

                DC.L __FADE_DEC
                DC.L black_whiteR_fades,2
                DC.L __FADE_WAIT

                DC.L ST,EFFECT_DONE_FLAG

                DC.L HALT
;-----------------------------------------------------
stest2:
                DC.L __FADE_INC
                DC.L black_whiteR_fades,0
                DC.L __FADE_WAIT

                DC.L __FADE_INC
                DC.L white_normalR_fades,0
                DC.L __FADE_WAIT

                DC.L __FADE_DEC
                DC.L white_normalR_fades,0
                DC.L __FADE_WAIT

                DC.L __FADE_DEC
                DC.L black_whiteR_fades,0
                DC.L __FADE_WAIT

                DC.L GOTO,stest2


                DC.L HALT


                ENDPART
;-------------------------------------

                bsr     make_fades_colors
                bsr     script

;-------------------------------------------------------------------------------
make_fades_colors:>PART

*   DC.L $4AFC4E71

                lea     black,A0
                lea     colors_whiteR,A1
                lea     black_whiteR_fades,A2
                bsr     make_fades

                lea     colors_whiteR,A0
                lea     colors,A1
                lea     white_normalR_fades,A2
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
mfl_fades:
                move.w  (SP),D0         ; fade1
                move.w  D0,fade_d7
                moveq   #8,D6
                sub.w   D0,D6           ; fade0
                move.w  D6,fade_d6

                movem.l pal0_mf(PC),A0-A1

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

                addq.w  #1,(SP)
                cmpi.w  #8,(SP)         ; 0...8
                ble.s   mfl_fades
                addq.l  #2,SP
                rts
fade_d6:        DC.W 0
fade_d7:        DC.W 0
pal0_mf:        DC.L 0
pal1_mf:        DC.L 0
                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
colors:         DS.W 16
black:
zero:           DS.L 16

colors_whiteR:
                DC.W $0000
                DS.W 13,$00000777
                DC.W $0777      ; 14
                DC.W $0777      ; 15

black_whiteR_fades:DS.W 9*16

white_normalR_fades:DS.W 9*16
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

