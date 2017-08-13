;-------------------------------------------------------------------------------
TEST            EQU 1
;-------------------------------------------------------------------------------
; Scroller      (w)defjam/checkpoint
;-------------------------------------------------------------------------------

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

                ENDPART

                movem.l colors,D0-D7
                movem.l D0-D7,$FFFF8240.w


*      bsr     set_char

                bsr     init_scroller

;-------------------------------------------------------------------------------
loop:
                bsr     swap_screens
                bsr     wait_vbl
                clr.w   $FFFF8240.w

                bsr     do_scroller

fchk:           move.l  $00000466.w,D0
                cmp.l   #4,D0
                blt.s   fchk

*     move.w  #$0007,$FFFF8240.w

                move.b  $FFFFFC02.w,D0
                cmp.b   #$39,D0
                bne     loop
                DC.L $4AFC4E71
                bra     loop

rte:            rte
rts:            rts

set_char:       >PART
                DC.L $4AFC4E71

                lea     font_gfx,A0
                lea     font_ftb,A1
                movea.l screen1,A6

                moveq   #'C',D0
                move.b  0(A1,D0.w),D0
                lsl.w   #3,D0
                lea     (A0),A2
                adda.w  D0,A2
o               SET 0
                REPT 8
                move.b  (A2)+,o(A6)
o               SET o+160
                ENDR
                rts
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


;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
do_scroller:    >PART
                bsr.s   output_scrollbuffer
                bsr     insert_new_scroller
                addq.w  #1,scroll_line
                rts
scroll_line:    DC.W 0
                ENDPART
output_scrollbuffer:>PART
                lea     sb_list,A0
                movea.l screen1,A6

                move.w  scroll_line,D0
                lsl.w   #2,D0
                move.w  #255*4,D1

                move.w  #200-1,D7
os_y:
                and.w   D1,D0
                movea.l 0(A0,D0.w),A1
                move.w  (A1)+,(A6)
o               SET 8
                REPT 19
                move.w  (A1)+,o(A6)
o               SET o+8
                ENDR
                addq.w  #4,D0
                lea     160(A6),A6
                dbra    D7,os_y
                rts
                ENDPART
insert_new_scroller:>PART
                move.w  scroll_line(PC),D0
                add.w   #200,D0
                lsl.w   #2,D0
                and.w   #255*4,D0
                lea     sb_list(PC),A6
                movea.l 0(A6,D0.w),A6

                movea.l text_pos(PC),A0
                lea     font_gfx(PC),A1
                lea     font_ftb(PC),A2

                move.w  text_y(PC),D7

                REPT 40
                moveq   #0,D0
                move.b  (A0)+,D0
                move.b  0(A2,D0.w),D0   ;  font_ftb
                lsl.w   #3,D0
                add.w   D7,D0
                move.b  0(A1,D0.w),(A6)+ ; font_gfx
                ENDR

                addq.w  #1,D7           ; text_y++
                cmp.w   #8-1,D7
                ble.s   nychr
                moveq   #0,D7
                tst.b   (A0)
                bne.s   nte
                lea     text_restart(PC),A0
nte:
                move.l  A0,text_pos
nychr:
                move.w  D7,text_y
                rts

text_y:         DC.W 0

text_pos:       DC.L text
                ENDPART
init_scroller:  >PART

                lea     font_ftb,A0
                move.b  #80,'&'(A0)     ; und char

                lea     scrollbuffer,A0
                lea     sb_list(PC),A1
                move.w  #256-1,D7
is0:
                move.l  A0,(A1)+
                lea     40(A0),A0
                dbra    D7,is0
                rts

sb_list:        DS.L 256
                ENDPART
font_gfx:       IBYTES '88.GFX'
und_char:       IBYTES 'UND.GFX' ; MUSS DIREKT HIER!!!!!!!!!!!!11111111
font_ftb:       IBYTES '88.FTB'

text_restart:
text:           >PART
*               DC.B "0123456789012345678901234567890123456789"
*               DC.B "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!-+*"

                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "             THUNDERDOME                "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "              THE  DEMO                 "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "    A CHECKPOINT PRODUCTION IN 2014     "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "        RELEASED AT SILLYVENTURE        "
                DC.B "           IN GDANSK/POLAND             "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "              CAST                      "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "IDEA          LSL/CHECKPOINT            "
                DC.B "CODE                                    "
                DC.B "DESIGN                                  "
                DC.B "SCRIPT                                  "
                DC.B "COORDINATION                            "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "ADDITIONAL    DEFJAM/CHECKPOINT         "
                DC.B "PROGRAMMING                             "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "PACKER        M.F.X.J.OBERHUMER         "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "GREENSCREEN   SU                        "
                DC.B "DANCER                                  "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "MUSIC         BERO/FARBRAUSCH           "
                DC.B "DIGITAL PART                            "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "MUSIC         ULTRASYD                  "
                DC.B "CHIP PART                               "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "ORIGINAL      VICTOR FEENSTRA           "
                DC.B "GRAPHICS      M-DESIGN WORMERVEER       "
                DC.B "DESIGN        ID&T                      "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "GRAPHICS      ST SURVIVOR               "
                DC.B "DESIGN        MODMATE/CHECKPOINT        "
                DC.B "              EXOCET/CHECKPOINT         "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "3D DESIGN     EXOCET/CHECKPOINT         "
                DC.B "TEXTURING                               "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "SPECTRUM512   ALIEN/ST-cONNEXION        "
                DC.B "DISPLAY                                 "
                DC.B "TECHNIQUE                               "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "TRUECOLOR     CYG/BLABLA                "
                DC.B "SPECTRUM512                             "
                DC.B "CONVERTER                               "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "VQ AUDIO      ALGORITHM/ONSLAUGHT       "
                DC.B "AND VIDEO                               "
                DC.B "IDEAS                                   "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "GREENSCREEN   KRAUTMOVIES               "
                DC.B "SHOOTING                                "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "VIDEO FOOTAGE THUNDERDOMEVIDEO          "
                DC.B "              ID&T ENTERTAINMENT        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "GREENSCREEN   BRAINHEADSINTERACTIVE     "
                DC.B "AND                                     "
                DC.B "VECTORIZATION                           "
                DC.B "SOFTWARE                                "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "   THIS DEMO IS NOT ENDORSED BY ID&T.   "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "  ALL EFFECTS IN THIS DEMO CAN RUN ON   "
                DC.B "              HALF MEG STF.             "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "             SEE YOU AT THE             "
                DC.B "         ST NEWS INTERNATIONAL          "
                DC.B "    CHRISTMAS CODING CONFERENCE 2015    "
                DC.B "     FOR A NEW LESSON IN ATARI STF      "
                DC.B "              EXPLORATION               "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "             THUNDERDOME                "
                DC.B "                                        "
                DC.B "        TRADITIONS MUST GO ON           "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
                DC.B "                                        "
;------------------------------------------------------------------
;-- END OF TEXT ---------------------------------------------------
;------------------------------------------------------------------
                DC.B 0
                EVEN
                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------


                DATA

c0              SET $0777
c1              SET $0700
c2              SET $0070
c3              SET $0007
colors:         >PART
                DC.W $0000      ;            0 ;

                DC.W c0         ;    0       1 ;

                DC.W c1         ;   1        2 ;
                DC.W c1         ;   10       3 ;

                DC.W c2         ;  2         4 ;
                DC.W c2         ;  2 0       5 ;
                DC.W c2         ;  21        6 ;
                DC.W c2         ;  210       7 ;

                DC.W c3         ; 3          8 ;
                DC.W c3         ; 3  0       0 ;
                DC.W c3         ; 3 1       10 ;
                DC.W c3         ; 3 10      11 ;
                DC.W c3         ; 32        12 ;
                DC.W c3         ; 32 0      13 ;
                DC.W c3         ; 321       14 ;
                DC.W c3         ; 3210      15 ;

                ENDPART


;-------------------------------------------------------------------------------
                BSS

scrollbuffer:   DS.B 256*40

                DS.B 512
stack:          DS.B 2

                DS.B 256
screen_ram:
                DS.B 32000
                DS.B 32000

                END
