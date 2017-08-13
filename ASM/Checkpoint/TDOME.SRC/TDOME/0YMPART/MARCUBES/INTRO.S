;-------------------------------------------------------------------------------
TEST            EQU 1
;-------------------------------------------------------------------------------

                RSSET $000004CE
vbl_slot_first: RS.L 1

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

                clr.l   vbl_slot_first.w

                move.l  #vbl_test,$00000070.w
                move    #$2300,SR
                bsr     wait_vbl

                clr.b   $FFFF8260.w
                move.b  #2,$FFFF820A.w

                ENDPART
                ENDC

                move.l  #screen_ram,D0
                clr.b   D0
                move.l  D0,screen1


                bsr     wait_vbl

                lea     white,A0
                movem.l (A0),D0-D7
                movem.l D0-D7,$FFFF8240.w

                bsr     init_marching_intro



;-------------------------------------------------------------------------------
loop:
                bsr     wait_vbl

*     DC.L $4AFC4E71


                move.b  $FFFFFC02.w,D0
                cmp.b   #$39,D0
                bne.s   loop
                DC.L $4AFC4E71
                bra.s   loop

vbl_test:       >PART

                movem.l D0-A6,-(SP)

                move.l  vbl_slot_first.w,D0
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

rte:            rte

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
heightIntrotxt  EQU 24
;-------------------------------------------------------------------------------
TEXT0           EQU 20
TEXT1           EQU 20+64
TEXT2           EQU 20+64+64
;------------------------------------
TB0             SET TEXT1-1
TB1             SET TEXT2-TEXT1-1
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
init_timer_b:
                bsr     wait_vbl
                move    #$2700,SR
                move.l  #rte,$00000120.w
                clr.b   $FFFFFA1B.w
                bset    #0,$FFFFFA07.w  ;Timer B
                bset    #0,$FFFFFA13.w  ;Timer B

                move.l  #vbl_tb_1st,vbl_slot_first.w
                move    #$2300,SR
                bsr     wait_vbl

                move.l  screen1(PC),D0
                lsr.w   #8,D0
                move.l  D0,$FFFF8200.w

                bsr     wait_vbl

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

make_fades_colors:>PART

                lea     white,A0
                lea     pi1+2,A1
                lea     white_normal_fades,A2
                bsr     make_fades

                rts
                ENDPART
white:          DS.W 16,$00000777
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
colors0_ptr:    DC.L white
colors1_ptr:    DC.L white
colors2_ptr:    DC.L white
;----------------------------------
vbl_tb_1st:     >PART

                move.b  #0,$FFFFFA1B.w
                move.b  #TB0,$FFFFFA21.w
                move.b  #8,$FFFFFA1B.w
                move.l  #timer_b_start,$00000120.w

                bsr     script_rout

                movea.l colors0_ptr(PC),A0
                movem.l (A0),D0-D7
                movem.l D0-D7,$FFFF8240.w

                rts

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
;-------------------------------------------------------------------------------
white_normal_fades:DS.W 9*16
pi1:
                PATH 'C:\0NEW\TDOME\0YMPART\'
                PATH 'MARCUBES\'
                IBYTES 'TEXT5.PI1',11554
;-------------------------------------------------------------------------------
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
                move.l  (A0)+,destfadePtr
                move.w  D0,fade_speed
                clr.w   fade_scounter
                clr.w   fade_num
                move.w  #1,fade_num_inc
                move.l  A0,script_pos
                move.l  #fade_do_subI,script_sub_fade
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
                move.w  fade_speed(PC),fade_scounter

                move.w  fade_num(PC),D0
                mulu    #16*2,D0
                add.l   fade_color_ptr(PC),D0
                move.l  D0,fade_current_colorsP

                movea.l destfadePtr(PC),A1
                move.l  D0,(A1)

*     movea.l D0,A1
*     movem.l (A1)+,D0-D6/A3
*     movem.l D0-D6/A3,$FFFF8240.w

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

destfadePtr:    DC.L 0

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

                DC.L HALT
;-----------------------------------------------------

                ENDPART
;-------------------------------------
;-------------------------------------------------------------------------------
;----------------------------------------------------------------------------------

                DATA
screen1:        DC.L 0

black:
zero:           DS.L 16

;-------------------------------------------------------------------------------
                BSS



                IFNE TEST
s_top:
                DS.B 1024
stack:          DS.B 2

                DS.B 256
screen_ram:
                DS.B 32000


                ENDC

                END
