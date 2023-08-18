************        FUCKIN' DENTRO        ***********
*********** HIER SIND NOCH 2 PLéDZE FREI ***********
*********** BY MIKE OF STAX  AND QUESTOR ***********

* for now and all eternity ....

* debakel v. 0.X

                OPT D-

**************** equ's ****************

gfx_wide        EQU 112
gfx_lines       EQU 17

anz_stars       EQU 80

************* code ************

                TEXT

                pea     0.w
                move.w  #$20,-(SP)
                trap    #1
                addq.w  #6,SP

                move.l  D0,save_stack
                move.l  #sync_vbl,$70.w

                bsr     install_system

*************** calc 3 d part 1 ****************

                bsr     build_routs_long

*********** music init **************

                bsr     init_music

************* rotate calc ************

                bsr     calc_offset_tabs

**************** bobo calcing **************

                bsr     calc_screen_offset_tabs
                bsr     calc_init_tabs
                bsr     calc_star_tabs
                move.l  #-1,save_all_bobs_1 * no restall
                move.l  #-1,save_all_bobs_2
                bsr     shift_bobs

************ leisten copy *************

                bsr     fill_back

                bsr     build_screens

*********** start show ****************

                bsr     vsync
                move.l  #my_vbl,$70.w   * auf in den kampf !

****************** rotate ***************

repeat_message: clr.w   winkel_rot
                move.w  #90,y_off

                bsr     prepare_rotate_gfx
                tst.w   D0
                bmi.s   popcorn2
                bsr     calc_color_table
                bsr     do_it
                bsr     do_rotate       * rotieren ...
                bsr     do_place
                addi.w  #24,line_y
                bra.s   repeat_message

popcorn2:       moveq   #99,D7
popcorn3:       bsr     vsync
                dbra    D7,popcorn3

popcorn:        bsr     fade_out
                bsr     clear_work

*************** calc 3 d part 2 ****************

                bsr     build_routs_or  *  am rand mit or-befehlen   (flexibler)

************************************************

                bsr     vsync
                move    SR,D0
                move    #$2700,SR
                move.l  #set_scroller,next_routine
                move.b  #170,next_timer
                move    D0,SR

                movem.l middle_pal2(PC),D0-D7
                movem.l D0-D7,middle_pal

**********************************************

main:           bsr     vsync
                bsr     clear_all_bobs
                bsr     scroller
                bsr     _3d_rout
                bsr     fuck_stars
                bsr     swap_screens

                addi.w  #4,dreh_x
                addi.w  #2,dreh_y
                addi.w  #6,dreh_z

                cmpi.b  #$39,key
                bne.s   main

leave:          jsr     player+4

                bsr     restore_system

                move.l  save_stack(PC),-(SP)
                move.w  #$20,-(SP)
                trap    #1
                addq.l  #6,SP

                clr.w   -(SP)
                trap    #1
sync_vbl:       addq.l  #1,vbl_timer
                rte

vbl_timer:      DS.L 1
************ some stuff *************

clear_work:     >PART
                movea.l screen_1(PC),A0
                movea.l screen_2(PC),A1
                lea     15*160(A0),A0
                lea     15*160(A1),A1
                moveq   #0,D0
                move.w  #179,D1
l_0:            moveq   #39,D2
l_1:            move.l  D0,(A0)+
                move.l  D0,(A1)+
                dbra    D2,l_1
                dbra    D1,l_0
                rts
                ENDPART
fade_out:       >PART
                moveq   #6,D0
mercy_2:        move.w  D0,-(SP)
                moveq   #3,D0
                bsr.s   sync
                bsr.s   fade_it_out
                move.w  (SP)+,D0
                dbra    D0,mercy_2
                rts

fade_it_out:
                lea     middle_pal(PC),A0
                moveq   #15,D1
line4:          move.w  (A0),D2
                beq.s   white
                move.w  D2,D3
                and.w   #%111,D3
                beq.s   blau
                subq.w  #1,D3
blau:           move.w  D2,D4
                lsr.w   #4,D4
                and.w   #%111,D4
                beq.s   gruen
                subq.w  #1,D4
gruen:          move.w  D2,D0
                lsr.w   #8,D0
                and.w   #%111,D0
                beq.s   rot
                subq.w  #1,D0
rot:            moveq   #0,D2
                move.b  D3,D2
                ror.w   #4,D2
                move.b  D4,D2
                ror.w   #4,D2
                move.b  D0,D2
                rol.w   #8,D2

white:          move.w  D2,(A0)+
                dbra    D1,line4
                rts

sync:           lea     vbl_timer,A0
                move.l  (A0),D1
                add.l   D0,D1
wait:           cmp.l   (A0),D1
                bne.s   wait
                rts

                ENDPART
fill_back:      >PART
                lea     rout_adrs2,A0
                movea.l screen_1(PC),A1
                movea.l screen_2(PC),A2
                lea     mamor,A3

                lea     15*160(A0),A0
                lea     15*160(A1),A1
                lea     15*160(A2),A2

                moveq   #8,D0
fill_0:         moveq   #9,D1
fill_1:         moveq   #19,D2
                movea.l A3,A4

                movem.l A0-A2,-(SP)

fill_2:         movem.l (A4)+,D3-D6
                movem.l D3-D6,(A0)
                movem.l D3-D6,(A1)
                movem.l D3-D6,(A2)
                lea     160(A0),A0
                lea     160(A1),A1
                lea     160(A2),A2
                dbra    D2,fill_2

                movem.l (SP)+,A0-A2

                lea     16(A0),A0
                lea     16(A1),A1
                lea     16(A2),A2

                dbra    D1,fill_1

                lea     160*19(A0),A0
                lea     160*19(A1),A1
                lea     160*19(A2),A2

                dbra    D0,fill_0
                rts
                ENDPART
init_music:     >PART
                lea     song1,A0
                lea     voice,A1
                jsr     player          ; Init the player
                rts
                ENDPART
do_rotate:      >PART
                bsr     vsync
                bsr     vec_clear
                bsr     spriting
                bsr     do_it
                bsr     swap_screens

                cmpi.b  #$39,key
                bne.s   bleiben
                addq.l  #4,SP
                bra     popcorn
bleiben:
                lea     winkel_rot(PC),A0
                addq.w  #4,(A0)
                cmpi.w  #359,(A0)
                ble.s   do_rotate
                clr.w   (A0)
                rts
                ENDPART
do_place:       >PART
                bsr     vsync
                bsr     vec_clear
                bsr     spriting
                bsr     do_it
                bsr     swap_screens
                bsr.s   adjust_y
                tst.w   D0
                bpl.s   do_place

********** co`y on all screens **********

                moveq   #2,D0
last_loop_1:    move.w  D0,-(SP)
                bsr     vsync
                bsr     vec_clear
                bsr     spriting
                bsr     do_it
                bsr     swap_screens
                move.w  (SP)+,D0
                dbra    D0,last_loop_1

                moveq   #1,D0
last_loop_2:    move.w  D0,-(SP)
                bsr     vsync
                bsr     do_it
                bsr     swap_screens
                move.w  (SP)+,D0
                dbra    D0,last_loop_2

                bsr     vsync
                lea     rout_adrs2,A0
                move.l  A0,screen_adr
                bsr     do_it
                bsr     swap_screens
                rts

adjust_y:       lea     y_off(PC),A0
                move.w  line_y(PC),D0
                cmp.w   (A0),D0
                bgt.s   add_was
                blt.s   sub_was
                move.w  #-1,D0
                rts
sub_was:        subq.w  #2,(A0)
                moveq   #0,D0
                rts
add_was:        addq.w  #2,(A0)
                moveq   #0,D0
                rts
                ENDPART

********** Scroller   ****************

scroller:       >PART
                subq.w  #1,scroll_phase
                bne.s   no_new_char
                move.w  #8,scroll_phase
                movea.l scroll_pointer(PC),A0
                moveq   #0,D0
                move.b  (A0)+,D0
                tst.b   (A0)
                bpl.s   no_new_text
                lea     text_(PC),A0
no_new_text:    move.l  A0,scroll_pointer
                lea     charset(PC),A0
                sub.w   #" ",D0
                lsl.w   #3,D0
                lea     0(A0,D0.w),A0
                lea     char(PC),A1
                move.l  (A0)+,(A1)+
                move.l  (A0),(A1)

no_new_char:    movea.l screen_1(PC),A0
                lea     189*160+4(A0),A0
                lea     char(PC),A1
                REPT 8
                move    #0,CCR
                move.b  (A1),D0
                asl.b   #1,D0
                move.b  D0,(A1)+
                roxl.w  19*8(A0)
                roxl.w  18*8(A0)
                roxl.w  17*8(A0)
                roxl.w  16*8(A0)
                roxl.w  15*8(A0)
                roxl.w  14*8(A0)
                roxl.w  13*8(A0)
                roxl.w  12*8(A0)
                roxl.w  11*8(A0)
                roxl.w  10*8(A0)
                roxl.w  9*8(A0)
                roxl.w  8*8(A0)
                roxl.w  7*8(A0)
                roxl.w  6*8(A0)
                roxl.w  5*8(A0)
                roxl.w  4*8(A0)
                roxl.w  3*8(A0)
                roxl.w  2*8(A0)
                roxl.w  8(A0)
                roxl.w  (A0)
                lea     160(A0),A0
                ENDR

                movea.l screen_1(PC),A0
                lea     189*160+4(A0),A0
                movea.l screen_2(PC),A1
                lea     189*160+4(A1),A1
                move.w  (A0),(A1)
.off            SET 8
                REPT 19*8-1
                move.w  .off(A0),.off(A1)
.off            SET .off+8
                ENDR

                rts
                ENDPART

*******************************
********** star bobs **********
*******************************

calc_screen_offset_tabs:>PART
                lea     screen160add1(PC),A0
                lea     screen160add2(PC),A1
                move.l  screen_1(PC),D0
                move.l  screen_2(PC),D1
                move.w  #200-1,D2
fill1:          add.l   D0,(A0)+
                add.l   D1,(A1)+
                dbra    D2,fill1
                rts
                ENDPART
calc_init_tabs: >PART
l0009:          lea     init_tab,A0
                moveq   #0,D1
l000a:          move.w  #-128,D0
l000b:          move.w  D0,D2
                muls    #50,D2
                move.l  D2,D3
                tst.w   D1
                beq.s   l000c
                divs    D1,D3
l000c:          add.w   #160,D3
                cmp.w   #320-10,D3      ; wenn X-Koo > 320
                blt.s   l001522         ; dann nicht zeichnen
                moveq   #-1,D3
l001522:        move.w  D3,(A0)+
                addq.w  #1,D0
                cmp.w   #128,D0
                bne.s   l000b
                addq.w  #1,D1
                cmp.w   #128,D1
                bne.s   l000a
                rts
                ENDPART
calc_star_tabs: >PART
                move.w  #anz_stars-1,D0
                lea     star_tab,A0     ; Sterne mit Zufallswerten init.
                move.l  #-$0808080C,D1
                move.l  #-$0DE0AC07,D2
l000d:          bsr.s   zufall
                move.w  D1,D3
                andi.w  #$01FE,D3       ; begrenzen
                move.w  D3,(A0)+        ; und speichern
                bsr.s   zufall
                move.w  D1,D3
                andi.w  #$01FE,D3
                move.w  D3,(A0)+
                bsr.s   zufall
                move.w  D1,D3
                andi.w  #$FE,D3
                move.w  D3,(A0)+
                dbra    D0,l000d
                rts
zufall:         add.l   D1,D2
                addi.l  #$FF8201,D2
                eor.l   D2,D1
                swap    D1
                rol.l   D0,D1
                rol.l   #1,D2
                add.l   D2,D1
                rts

                ENDPART
clear_all_bobs: >PART

                lea     save_all_bobs_1,A0
                tst.w   swap_index
                bpl.s   first2
                lea     save_all_bobs_2,A0
first2:
                lea     save_routs_table(PC),A2
                moveq   #0,D1

loop_in:        move.l  (A0)+,D0
                bpl.s   cls_me
                rts
cls_me:         movea.l D0,A1
                move.w  (A0)+,D0
                movea.l 0(A2,D0.w),A3
                jmp     (A3)

                ENDPART

save_routs_table:
                DC.L restall_8_0
                DC.L restall_8_1
                DC.L restall_5_0
                DC.L restall_5_1
                DC.L restall_2_0
                DC.L restall_2_1
                DC.L restall_star * 24
                DC.L restall_7_0
                DC.L restall_7_1
                DC.L restall_6_0
                DC.L restall_6_1
                DC.L restall_4_0
                DC.L restall_4_1
                DC.L restall_3_0
                DC.L restall_3_1

                >PART

restall_star:
                move.l  D1,(A1)
                bra.s   loop_in

restall_8_0:
                movep.w D1,1(A1)
                movep.w D1,8(A1)
                movep.w D1,1+160(A1)
                movep.w D1,8+160(A1)
                movep.w D1,1+160*2(A1)
                movep.w D1,8+160*2(A1)
                movep.w D1,1+160*3(A1)
                movep.w D1,8+160*3(A1)
                movep.w D1,1+160*4(A1)
                movep.w D1,8+160*4(A1)
                movep.w D1,1+160*5(A1)
                movep.w D1,8+160*5(A1)
                movep.w D1,1+160*6(A1)
                movep.w D1,8+160*6(A1)
                movep.w D1,1+160*7(A1)
                movep.w D1,8+160*7(A1)

                bra     loop_in

restall_8_1:
                move.l  D1,(A1)
                move.l  D1,160(A1)
                move.l  D1,160*2(A1)
                move.l  D1,160*3(A1)
                move.l  D1,160*4(A1)
                move.l  D1,160*5(A1)
                move.l  D1,160*6(A1)
                move.l  D1,160*7(A1)

                bra     loop_in

restall_7_0:
                movep.w D1,1(A1)
                movep.w D1,8(A1)
                movep.w D1,1+160(A1)
                movep.w D1,8+160(A1)
                movep.w D1,1+160*2(A1)
                movep.w D1,8+160*2(A1)
                movep.w D1,1+160*3(A1)
                movep.w D1,8+160*3(A1)
                movep.w D1,1+160*4(A1)
                movep.w D1,8+160*4(A1)
                movep.w D1,1+160*5(A1)
                movep.w D1,8+160*5(A1)
                movep.w D1,1+160*6(A1)
                movep.w D1,8+160*6(A1)
                movep.w D1,1+160*7(A1)

                bra     loop_in

restall_7_1:
                move.l  D1,(A1)
                move.l  D1,160(A1)
                move.l  D1,160*2(A1)
                move.l  D1,160*3(A1)
                move.l  D1,160*4(A1)
                move.l  D1,160*5(A1)
                move.l  D1,160*6(A1)

                bra     loop_in
restall_6_0:
                movep.w D1,1(A1)
                movep.w D1,8(A1)
                movep.w D1,1+160(A1)
                movep.w D1,8+160(A1)
                movep.w D1,1+160*2(A1)
                movep.w D1,8+160*2(A1)
                movep.w D1,1+160*3(A1)
                movep.w D1,8+160*3(A1)
                movep.w D1,1+160*4(A1)
                movep.w D1,8+160*4(A1)
                movep.w D1,1+160*5(A1)
                movep.w D1,8+160*5(A1)

                bra     loop_in

restall_6_1:
                move.l  D1,(A1)
                move.l  D1,160(A1)
                move.l  D1,160*2(A1)
                move.l  D1,160*3(A1)
                move.l  D1,160*4(A1)
                move.l  D1,160*5(A1)

                bra     loop_in

restall_5_0:
                movep.w D1,1(A1)
                movep.w D1,8(A1)
                movep.w D1,1+160(A1)
                movep.w D1,8+160(A1)
                movep.w D1,1+160*2(A1)
                movep.w D1,8+160*2(A1)
                movep.w D1,1+160*3(A1)
                movep.w D1,8+160*3(A1)
                movep.w D1,1+160*4(A1)
                movep.w D1,8+160*4(A1)

                bra     loop_in

restall_5_1:
                move.l  D1,(A1)
                move.l  D1,160(A1)
                move.l  D1,160*2(A1)
                move.l  D1,160*3(A1)
                move.l  D1,160*4(A1)

                bra     loop_in

restall_4_0:
                movep.w D1,1(A1)
                movep.w D1,8(A1)
                movep.w D1,1+160(A1)
                movep.w D1,8+160(A1)
                movep.w D1,1+160*2(A1)
                movep.w D1,8+160*2(A1)
                movep.w D1,1+160*3(A1)
                movep.w D1,8+160*3(A1)

                bra     loop_in

restall_4_1:
                move.l  D1,(A1)
                move.l  D1,160(A1)
                move.l  D1,160*2(A1)
                move.l  D1,160*3(A1)

                bra     loop_in
restall_3_0:
                movep.w D1,1(A1)
                movep.w D1,8(A1)
                movep.w D1,1+160(A1)
                movep.w D1,8+160(A1)
                movep.w D1,1+160*2(A1)
                movep.w D1,8+160*2(A1)

                bra     loop_in

restall_3_1:
                move.l  D1,(A1)
                move.l  D1,160(A1)
                move.l  D1,160*2(A1)

                bra     loop_in

restall_2_0:
                movep.w D1,1(A1)
                movep.w D1,8(A1)
                movep.w D1,1+160(A1)
                movep.w D1,8+160(A1)

                bra     loop_in

restall_2_1:
                move.l  D1,(A1)
                move.l  D1,160(A1)

                bra     loop_in

                ENDPART

fuck_stars:     >PART

                lea     init_tab,A0
                lea     star_tab,A1

                lea     save_all_bobs_1,A4
                lea     screen160add1(PC),A5

                lea     which_table(PC),A6

                tst.w   swap_index
                bpl.s   first
                lea     save_all_bobs_2,A4
                lea     screen160add2(PC),A5

first:

* a0= init tab
* a1= star_tab
* a4= save buff
* a5= offset screeny

* d0= star counter
* d1,d2,d3  winkel
* d4,d5,d6  x,y,z

* d7 = konst ?


weiter_nach_screen:
                move.w  #anz_stars-1,D0
                movem.w winkel(PC),D1-D3

                move.w  #$01FE,D7

star_loop:      movem.w (A1)+,D4-D6     ; Koo holen
                add.w   D1,D4           ; und Bewegung ausfuehren
                add.w   D2,D5
                add.w   D3,D6

                and.w   D7,D4           ; begrenzen und nur gerade Werte
                and.w   D7,D5
                andi.w  #254,D6

                lsl.w   #8,D6           ; Z-Koo*256
                add.w   D6,D4           ; X-Koo + (Z-Koo*256)
                add.w   D6,D5           ; Y-Koo + (Z-Koo*256)
                move.w  0(A0,D4.l),D4   ; und Wert aus Tabelle holen
                blt.s   nix_draw        * x-koo < 0 dann nicht zeichnen
                move.w  0(A0,D5.l),D5
                cmp.w   #12,D5
                blt.s   nix_draw        ; Y-Koo < 0 dann nicht zeichnen

                cmp.w   #199-10,D5      ; ****
                bgt.s   nix_draw        ; ****

********** d4= x / d5= y ******************

                add.w   D5,D5
                add.w   D5,D5
                movea.l 0(A5,D5.w),A3

                movea.w D7,A2
                move.w  #40*256,D7
                moveq   #0,D5

                REPT 5
                sub.w   D7,D6
                bcs.s   jump
                addq.w  #4,D5
                ENDR

* free here : a2,a6 / d4,d5,d6 , d7 ?

* d4= x   a3=screen+y-off  a4= save buffer d6= z !!!!!!

jump:           move.w  A2,D7
                movea.l 0(A6,D5.w),A2   * z-depending bob routine
                jmp     (A2)

nix_draw:       dbra    D0,star_loop

                move.l  #-1,(A4)        * ende

                movem.w offs(PC),D0-D2

                add.w   D0,winkel       ; Bewegung X
                add.w   D1,winkel+2     ; Bewegung Y
                add.w   D2,winkel+4     ; Bewegung Z

                andi.w  #510,winkel
                andi.w  #510,winkel+2
                andi.w  #254,winkel+4
                rts
                ENDPART
                >PART 'scan big one *8'

table_8_8_1:    DS.L 16

scan_big_bob_8:                         ;d4=x  d6=z    a3=screen  a4=save
                move.w  D4,D5
                and.w   #15,D4
                cmpi.w  #8,D4
                blt     first_part

                add.w   D4,D4
                add.w   D4,D4
                movea.l table_8_8_1(PC,D4.w),A2 * data

                and.w   #$FFF0,D5
                lsr.w   #1,D5
                adda.w  D5,A3

                move.l  A3,(A4)+        * save adr
                clr.w   (A4)+           * cls routine

                movep.w 1(A3),D4
                movep.w 8(A3),D5
                and.w   (A2)+,D4
                and.w   (A2)+,D5
                or.w    (A2)+,D4
                or.w    (A2)+,D5
                movep.w D4,1(A3)
                movep.w D5,8(A3)

                movep.w 1+160(A3),D4
                movep.w 8+160(A3),D5
                and.w   (A2)+,D4
                and.w   (A2)+,D5
                or.w    (A2)+,D4
                or.w    (A2)+,D5
                movep.w D4,1+160(A3)
                movep.w D5,8+160(A3)

                movep.w 1+160*2(A3),D4
                movep.w 8+160*2(A3),D5
                and.w   (A2)+,D4
                and.w   (A2)+,D5
                or.w    (A2)+,D4
                or.w    (A2)+,D5
                movep.w D4,1+160*2(A3)
                movep.w D5,8+160*2(A3)

                movep.w 1+160*3(A3),D4
                movep.w 8+160*3(A3),D5
                and.w   (A2)+,D4
                and.w   (A2)+,D5
                or.w    (A2)+,D4
                or.w    (A2)+,D5
                movep.w D4,1+160*3(A3)
                movep.w D5,8+160*3(A3)

                movep.w 1+160*4(A3),D4
                movep.w 8+160*4(A3),D5
                and.w   (A2)+,D4
                and.w   (A2)+,D5
                or.w    (A2)+,D4
                or.w    (A2)+,D5
                movep.w D4,1+160*4(A3)
                movep.w D5,8+160*4(A3)

                movep.w 1+160*5(A3),D4
                movep.w 8+160*5(A3),D5
                and.w   (A2)+,D4
                and.w   (A2)+,D5
                or.w    (A2)+,D4
                or.w    (A2)+,D5
                movep.w D4,1+160*5(A3)
                movep.w D5,8+160*5(A3)

                movep.w 1+160*6(A3),D4
                movep.w 8+160*6(A3),D5
                and.w   (A2)+,D4
                and.w   (A2)+,D5
                or.w    (A2)+,D4
                or.w    (A2)+,D5
                movep.w D4,1+160*6(A3)
                movep.w D5,8+160*6(A3)

                movep.w 1+160*7(A3),D4
                movep.w 8+160*7(A3),D5
                and.w   (A2)+,D4
                and.w   (A2)+,D5
                or.w    (A2)+,D4
                or.w    (A2)+,D5
                movep.w D4,1+160*7(A3)
                movep.w D5,8+160*7(A3)

                bra     nix_draw


table_8_8_2:    DS.L 16

first_part:     add.w   D4,D4
                add.w   D4,D4
                movea.l table_8_8_2(PC,D4.w),A2

                and.w   #$FFF0,D5
                lsr.w   #1,D5
                adda.w  D5,A3

                move.l  A3,(A4)+        ;save adr
                move.w  #4,(A4)+        * restall bout *4

                REPT 8
                move.l  (A2)+,D4
                move.l  (A2)+,D5
                and.l   D4,(A3)
                or.l    D5,(A3)
                lea     160(A3),A3
                ENDR
                bra     nix_draw


                ENDPART
                >PART 'scan big one *7'

table_8_8_1c:   DS.L 16

scan_big_bob_7:                         ;d4=x  d6=z    a3=screen  a4=save
                move.w  D4,D5
                and.w   #15,D4
                cmpi.w  #8,D4
                blt     first_partc

                add.w   D4,D4
                add.w   D4,D4
                movea.l table_8_8_1c(PC,D4.w),A2 * data

                and.w   #$FFF0,D5
                lsr.w   #1,D5
                adda.w  D5,A3

                move.l  A3,(A4)+        * save adr
                move.w  #28,(A4)+       * cls routine


offy            SET 0
                REPT 7
                movep.w 1+offy(A3),D4
                movep.w 8+offy(A3),D5
                and.w   (A2)+,D4
                and.w   (A2)+,D5
                or.w    (A2)+,D4
                or.w    (A2)+,D5
                movep.w D4,1+offy(A3)
                movep.w D5,8+offy(A3)
offy            SET offy+160
                ENDR
                bra     nix_draw


table_8_8_2c:   DS.L 16

first_partc:    add.w   D4,D4
                add.w   D4,D4
                movea.l table_8_8_2c(PC,D4.w),A2

                and.w   #$FFF0,D5
                lsr.w   #1,D5
                adda.w  D5,A3

                move.l  A3,(A4)+        ;save adr
                move.w  #32,(A4)+       * restall rout *4

                REPT 7
                move.l  (A2)+,D4
                move.l  (A2)+,D5
                and.l   D4,(A3)
                or.l    D5,(A3)
                lea     160(A3),A3
                ENDR
                bra     nix_draw


                ENDPART
                >PART 'scan big one *6'

table_8_8_1d:   DS.L 16

scan_big_bob_6:                         ;d4=x  d6=z    a3=screen  a4=save
                move.w  D4,D5
                and.w   #15,D4
                cmpi.w  #8,D4
                blt     first_partd

                add.w   D4,D4
                add.w   D4,D4
                movea.l table_8_8_1d(PC,D4.w),A2 * data

                and.w   #$FFF0,D5
                lsr.w   #1,D5
                adda.w  D5,A3

                move.l  A3,(A4)+        * save adr
                move.w  #36,(A4)+       * cls routine


offy            SET 0
                REPT 6
                movep.w 1+offy(A3),D4
                movep.w 8+offy(A3),D5
                and.w   (A2)+,D4
                and.w   (A2)+,D5
                or.w    (A2)+,D4
                or.w    (A2)+,D5
                movep.w D4,1+offy(A3)
                movep.w D5,8+offy(A3)
offy            SET offy+160
                ENDR
                bra     nix_draw


table_8_8_2d:   DS.L 16

first_partd:    add.w   D4,D4
                add.w   D4,D4
                movea.l table_8_8_2d(PC,D4.w),A2

                and.w   #$FFF0,D5
                lsr.w   #1,D5
                adda.w  D5,A3

                move.l  A3,(A4)+        +save adr
                move.w  #40,(A4)+       * restall rout *4

                REPT 6
                move.l  (A2)+,D4
                move.l  (A2)+,D5
                and.l   D4,(A3)
                or.l    D5,(A3)
                lea     160(A3),A3
                ENDR
                bra     nix_draw


                ENDPART
                >PART 'scan big one *5'

table_8_8_1a:   DS.L 16

scan_big_bob_5:                         ;d4=h  d&=z    a3=screen  a4=save
                move.w  D4,D5
                and.w   #15,D4
                cmpi.w  #8,D4
                blt     first_parta

                add.w   D4,D4
                add.w   D4,D4
                movea.l table_8_8_1a(PC,D4.w),A2 * data

                and.w   #$FFF0,D5
                lsr.w   #1,D5
                adda.w  D5,A3

                move.l  A3,(A4)+        * safe adr
                move.w  #8,(A4)+        * cls roetine

                movep.w 1(A3),D4
                movep.w 8(A3),D5
                and.w   (A2)+,D4
                and.w   (A2)+,D5
                or.w    (A2)+,D4
                or.w    (A2)+,D5
                movep.w D4,1(A3)
                movep.w D5,8(A3)

                movep.w 1+160(A3),D4
                movep.w 8+160(A3),D5
                and.w   (A2)+,D4
                and.w   (A2)+,D5
                or.w    (A2)+,D4
                or.w    (A2)+,D5
                movep.w D4,1+160(A3)
                movep.w D5,8+160(A3)

                movep.w 1+160*2(A3),D4
                movep.w 8+160*2(A3),D5
                and.w   (A2)+,D4
                and.w   (A2)+,D5
                or.w    (A2)+,D4
                or.w    (A2)+,D5
                movep.w D4,1+160*2(A3)
                movep.w D5,8+160*2(A3)

                movep.w 1+160*3(A3),D4
                movep.w 8+160*3(A3),D5
                and.w   (A2)+,D4
                and.w   (A2)+,D5
                or.w    (A2)+,D4
                or.w    (A2)+,D5
                movep.w D4,1+160*3(A3)
                movep.w D5,8+160*3(A3)

                movep.w 1+160*4(A3),D4
                movep.w 8+160*4(A3),D5
                and.w   (A2)+,D4
                and.w   (A2)+,D5
                or.w    (A2)+,D4
                or.w    (A2)+,D5
                movep.w D4,1+160*4(A3)
                movep.w D5,8+160*4(A3)

                bra     nix_draw


table_8_8_2a:   DS.L 16

first_parta:    add.w   D4,D4
                add.w   D4,D4
                movea.l table_8_8_2a(PC,D4.w),A2

                and.w   #$FFF0,D5
                lsr.w   #1,D5
                adda.w  D5,A3

                move.l  A3,(A4)+        +save adr
                move.w  #12,(A4)+       * restall rout *4

                REPT 5
                move.l  (A2)+,D4
                move.l  (A2)+,D5
                and.l   D4,(A3)
                or.l    D5,(A3)
                lea     160(A3),A3
                ENDR
                bra     nix_draw


                ENDPART
                >PART 'scan big one *4'

table_8_8_1e:   DS.L 16

scan_big_bob_4:                         ;d4=x  d6=z    a3=screen  a4=save
                move.w  D4,D5
                and.w   #15,D4
                cmpi.w  #8,D4
                blt     first_parte

                add.w   D4,D4
                add.w   D4,D4
                movea.l table_8_8_1e(PC,D4.w),A2 * data

                and.w   #$FFF0,D5
                lsr.w   #1,D5
                adda.w  D5,A3

                move.l  A3,(A4)+        * save adr
                move.w  #44,(A4)+       * cls routine

                movep.w 1(A3),D4
                movep.w 8(A3),D5
                and.w   (A2)+,D4
                and.w   (A2)+,D5
                or.w    (A2)+,D4
                or.w    (A2)+,D5
                movep.w D4,1(A3)
                movep.w D5,8(A3)

                movep.w 1+160(A3),D4
                movep.w 8+160(A3),D5
                and.w   (A2)+,D4
                and.w   (A2)+,D5
                or.w    (A2)+,D4
                or.w    (A2)+,D5
                movep.w D4,1+160(A3)
                movep.w D5,8+160(A3)

                movep.w 1+160*2(A3),D4
                movep.w 8+160*2(A3),D5
                and.w   (A2)+,D4
                and.w   (A2)+,D5
                or.w    (A2)+,D4
                or.w    (A2)+,D5
                movep.w D4,1+160*2(A3)
                movep.w D5,8+160*2(A3)

                movep.w 1+160*3(A3),D4
                movep.w 8+160*3(A3),D5
                and.w   (A2)+,D4
                and.w   (A2)+,D5
                or.w    (A2)+,D4
                or.w    (A2)+,D5
                movep.w D4,1+160*3(A3)
                movep.w D5,8+160*3(A3)

                bra     nix_draw


table_8_8_2e:   DS.L 16

first_parte:    add.w   D4,D4
                add.w   D4,D4
                movea.l table_8_8_2e(PC,D4.w),A2

                and.w   #$FFF0,D5
                lsr.w   #1,D5
                adda.w  D5,A3

                move.l  A3,(A4)+        ;save adr
                move.w  #48,(A4)+       * restall rout *4

                REPT 4
                move.l  (A2)+,D4
                move.l  (A2)+,D5
                and.l   D4,(A3)
                or.l    D5,(A3)
                lea     160(A3),A3
                ENDR
                bra     nix_draw


                ENDPART
                >PART 'scan big one *3'

table_8_8_1f:   DS.L 16

scan_big_bob_3:                         ;d4=x  d6=z    a3=screen  a4=save
                move.w  D4,D5
                and.w   #15,D4
                cmpi.w  #8,D4
                blt     first_partf

                add.w   D4,D4
                add.w   D4,D4
                movea.l table_8_8_1f(PC,D4.w),A2 * data

                and.w   #$FFF0,D5
                lsr.w   #1,D5
                adda.w  D5,A3

                move.l  A3,(A4)+        * save adr
                move.w  #52,(A4)+       * cls routine

                movep.w 1(A3),D4
                movep.w 8(A3),D5
                and.w   (A2)+,D4
                and.w   (A2)+,D5
                or.w    (A2)+,D4
                or.w    (A2)+,D5
                movep.w D4,1(A3)
                movep.w D5,8(A3)

                movep.w 1+160(A3),D4
                movep.w 8+160(A3),D5
                and.w   (A2)+,D4
                and.w   (A2)+,D5
                or.w    (A2)+,D4
                or.w    (A2)+,D5
                movep.w D4,1+160(A3)
                movep.w D5,8+160(A3)

                movep.w 1+160*2(A3),D4
                movep.w 8+160*2(A3),D5
                and.w   (A2)+,D4
                and.w   (A2)+,D5
                or.w    (A2)+,D4
                or.w    (A2)+,D5
                movep.w D4,1+160*2(A3)
                movep.w D5,8+160*2(A3)

                bra     nix_draw

table_8_8_2f:   DS.L 16

first_partf:    add.w   D4,D4
                add.w   D4,D4
                movea.l table_8_8_2f(PC,D4.w),A2

                and.w   #$FFF0,D5
                lsr.w   #1,D5
                adda.w  D5,A3

                move.l  A3,(A4)+        ;save adr
                move.w  #56,(A4)+       * restall rout *4

                REPT 3
                move.l  (A2)+,D4
                move.l  (A2)+,D5
                and.l   D4,(A3)
                or.l    D5,(A3)
                lea     160(A3),A3
                ENDR
                bra     nix_draw


                ENDPART

****************************************
*********** rotate 4 planes ************
****************************************

spriting:       PART

                movea.l screen_1(PC),A0
                lea     four_points(PC),A1
                lea     sprit_tab(PC),A2

************ d x **********

                move.w  (A1)+,D1
                move.w  (A1)+,D2

                and.w   #$FFF0,D1
                and.w   #$FFF0,D2
                lsr.w   #1,D1
                lsr.w   #1,D2
                move.w  D1,D3           * save start
                sub.w   D1,D2

                move.w  #160,D4
                sub.w   D2,D4
                subq.w  #8,D4

                asr.w   #1,D2
                movea.l 0(A2,D2.w),A2   * routine

************ dy *************

                move.w  (A1)+,D1
                move.w  (A1)+,D2
                sub.w   D1,D2
                subq.w  #1,D2
                move.w  D2,D0           * line counter

                lea     y_mulu_table(PC),A3
                add.w   D1,D1
                neg.w   D1
                add.w   0(A3,D1.w),D3

                lea     rout_adrs2,A1

                adda.w  D3,A0           * screen off ready
                adda.w  D3,A1

                move.w  D4,D1

* d0= loop
* d1= line off
* a0= screen
* a2= sprit rout

repeat_fill:    jmp     (A2)
ready:          adda.w  D1,A1
                dbra    D0,repeat_fill

                rts
                ENDPART
                PART 'sprit'
sprit_tab:      DC.L f1,f2,f3,f4,f5,f6,f7,f8,f9,f10
                DC.L f11,f12,f13,f14,f15,f16,f17,f18,f19,f20

f1:             REPT 1
                move.l  (A1)+,(A0)+
                move.l  (A1)+,(A0)+
                ENDR
                adda.w  D1,A0
                bra.s   ready
f2:             REPT 2
                move.l  (A1)+,(A0)+
                move.l  (A1)+,(A0)+
                ENDR
                adda.w  D1,A0
                bra.s   ready
f3:             movem.l (A1)+,D2-D7
                movem.l D2-D7,(A0)
                lea     160(A0),A0
                bra.s   ready
f4:             movem.l (A1)+,D2-D7/A3-A4
                movem.l D2-D7/A3-A4,(A0)
                lea     160(A0),A0
                bra     ready
f5:             movem.l (A1)+,D2-D7/A3-A6
                movem.l D2-D7/A3-A6,(A0)
                lea     160(A0),A0
                bra     ready
f6:             movem.l (A1)+,D2-D7
                movem.l D2-D7,(A0)
                movem.l (A1)+,D2-D7
                movem.l D2-D7,24(A0)
                lea     160(A0),A0
                bra     ready
f7:             movem.l (A1)+,D2-D7
                movem.l D2-D7,(A0)
                movem.l (A1)+,D2-D7/A3-A4
                movem.l D2-D7/A3-A4,24(A0)
                lea     160(A0),A0
                bra     ready
f8:             movem.l (A1)+,D2-D7
                movem.l D2-D7,(A0)
                movem.l (A1)+,D2-D7/A3-A6
                movem.l D2-D7/A3-A6,24(A0)
                lea     160(A0),A0
                bra     ready
f9:             movem.l (A1)+,D2-D7/A3-A4
                movem.l D2-D7/A3-A4,(A0)
                movem.l (A1)+,D2-D7/A3-A6
                movem.l D2-D7/A3-A6,32(A0)
                lea     160(A0),A0
                bra     ready
f10:            movem.l (A1)+,D2-D7/A3-A6
                movem.l D2-D7/A3-A6,(A0)
                movem.l (A1)+,D2-D7/A3-A6
                movem.l D2-D7/A3-A6,40(A0)
                lea     160(A0),A0
                bra     ready
f11:            movem.l (A1)+,D2-D7
                movem.l D2-D7,(A0)
                movem.l (A1)+,D2-D7
                movem.l D2-D7,24(A0)
                movem.l (A1)+,D2-D7/A3-A6
                movem.l D2-D7/A3-A6,48(A0)
                lea     160(A0),A0
                bra     ready
f12:            movem.l (A1)+,D2-D7
                movem.l D2-D7,(A0)
                movem.l (A1)+,D2-D7/A3-A4
                movem.l D2-D7/A3-A4,24(A0)
                movem.l (A1)+,D2-D7/A3-A6
                movem.l D2-D7/A3-A6,56(A0)
                lea     160(A0),A0
                bra     ready
f13:            movem.l (A1)+,D2-D7
                movem.l D2-D7,(A0)
                movem.l (A1)+,D2-D7/A3-A6
                movem.l D2-D7/A3-A6,24(A0)
                movem.l (A1)+,D2-D7/A3-A6
                movem.l D2-D7/A3-A6,64(A0)
                lea     160(A0),A0
                bra     ready
f14:            movem.l (A1)+,D2-D7/A3-A4
                movem.l D2-D7/A3-A4,(A0)
                movem.l (A1)+,D2-D7/A3-A6
                movem.l D2-D7/A3-A6,32(A0)
                movem.l (A1)+,D2-D7/A3-A6
                movem.l D2-D7/A3-A6,72(A0)
                lea     160(A0),A0
                bra     ready
f15:            movem.l (A1)+,D2-D7/A3-A6
                movem.l D2-D7/A3-A6,(A0)
                movem.l (A1)+,D2-D7/A3-A6
                movem.l D2-D7/A3-A6,40(A0)
                movem.l (A1)+,D2-D7/A3-A6
                movem.l D2-D7/A3-A6,80(A0)
                lea     160(A0),A0
                bra     ready
f16:            movem.l (A1)+,D2-D7/A3-A6
                movem.l D2-D7,(A0)
                movem.l (A1)+,D2-D7/A3-A6
                movem.l D2-D7,40(A0)
                movem.l (A1)+,D2-D7
                movem.l D2-D7,80(A0)
                movem.l (A1)+,D2-D7
                movem.l D2-D7,104(A0)
                lea     160(A0),A0
                bra     ready
f17:            movem.l (A1)+,D2-D7/A3-A6
                movem.l D2-D7,(A0)
                movem.l (A1)+,D2-D7/A3-A6
                movem.l D2-D7,40(A0)
                movem.l (A1)+,D2-D7/A3-A4
                movem.l D2-D7/A3-A4,80(A0)
                movem.l (A1)+,D2-D7
                movem.l D2-D7,112(A0)
                lea     160(A0),A0
                bra     ready
f18:            movem.l (A1)+,D2-D7/A3-A6
                movem.l D2-D7,(A0)
                movem.l (A1)+,D2-D7/A3-A6
                movem.l D2-D7,40(A0)
                movem.l (A1)+,D2-D7/A3-A6
                movem.l D2-D7/A3-A6,80(A0)
                movem.l (A1)+,D2-D7
                movem.l D2-D7,120(A0)
                lea     160(A0),A0
                bra     ready
f19:            movem.l (A1)+,D2-D7/A3-A6
                movem.l D2-D7,(A0)
                movem.l (A1)+,D2-D7/A3-A6
                movem.l D2-D7,40(A0)
                movem.l (A1)+,D2-D7/A3-A6
                movem.l D2-D7/A3-A6,80(A0)
                movem.l (A1)+,D2-D7/A3-A4
                movem.l D2-D7/A3-A4,120(A0)
                lea     160(A0),A0
                bra     ready
f20:            movem.l (A1)+,D2-D7/A3-A6
                movem.l D2-D7,(A0)
                movem.l (A1)+,D2-D7/A3-A6
                movem.l D2-D7,40(A0)
                movem.l (A1)+,D2-D7/A3-A6
                movem.l D2-D7/A3-A6,80(A0)
                movem.l (A1)+,D2-D7/A3-A6
                movem.l D2-D7/A3-A6,120(A0)
                lea     160(A0),A0
                bra     ready
                ENDPART
vec_clear:      >PART

                lea     four_points(PC),A2
                lea     new_line_x_y(PC),A0
                lea     (gfx_lines-1)*8(A0),A1

********** mini x ***************

                move.w  (A0),D0
                move.w  4(A0),D1
                move.w  (A1),D2
                move.w  4(A1),D3

                bsr.s   minimum
                subi.w  #16,D0
                add.w   x_off(PC),D0
                move.w  D0,(A2)+

********** maxi x **************

                move.w  (A0),D0
                move.w  4(A0),D1
                move.w  (A1),D2
                move.w  4(A1),D3

                bsr.s   maximum
                addi.w  #16,D0
                add.w   x_off(PC),D0
                move.w  D0,(A2)+

********** mini y ***************

                move.w  2(A0),D0
                move.w  6(A0),D1
                move.w  2(A1),D2
                move.w  6(A1),D3

                bsr.s   minimum
                subq.w  #4,D0
                add.w   y_off(PC),D0
                move.w  D0,(A2)+

********** maxi y **************

                move.w  2(A0),D0
                move.w  6(A0),D1
                move.w  2(A1),D2
                move.w  6(A1),D3

                bsr.s   maximum
                addq.w  #6,D0
                add.w   y_off(PC),D0
                move.w  D0,(A2)+

                rts


minimum:        cmp.w   D0,D1
                bge.s   bell_0
                move.w  D1,D0
bell_0:         cmp.w   D0,D2
                bge.s   bell_1
                move.w  D2,D0
bell_1:         cmp.w   D0,D3
                bge.s   bell_2
                move.w  D3,D0
bell_2:         rts

maximum:        cmp.w   D0,D1
                ble.s   bell_0a
                move.w  D1,D0
bell_0a:        cmp.w   D0,D2
                ble.s   bell_1a
                move.w  D2,D0
bell_1a:        cmp.w   D0,D3
                ble.s   bell_2a
                move.w  D3,D0
bell_2a:        rts

                ENDPART
prepare_rotate_gfx:>PART

                lea     text_pointer(PC),A1
                movea.l (A1),A0
                addq.l  #7,(A1)         * next text line
                tst.b   (A0)
                bpl.s   valley
                move.w  #-1,D0
                rts

valley:         lea     new_font,A1
                lea     rotate_frame,A3

                moveq   #7,D0
repeat_char:    move.b  (A0)+,D1
                ext.w   D1
                cmp.w   #' ',D1
                bne.s   no_space
                moveq   #0,D1
                bra.s   ach_nee
no_space:       subi.w  #$40,D1
ach_nee:
                mulu    #17*6,D1

                movea.l A1,A2
                movea.l A3,A4

                adda.w  D1,A2

                moveq   #16,D1
lopp:           move.l  (A2)+,(A4)
                move.w  (A2)+,4(A4)
                lea     96(A4),A4
                dbra    D1,lopp

                addq.l  #8,A3

                dbra    D0,repeat_char

                moveq   #0,D0

                rts
                ENDPART

***************************************
********* rotation itself *************
***************************************

do_it:          >PART
                bsr     calc_rotating_point
                bsr     rotate_a_line

                lea     new_line_x_y(PC),A6

*********** richdung ??? *****************

                lea     color_hash_table_1,A5
                move.w  (A6),D0
                move.w  4(A6),D1
                cmp.w   D0,D1
                bgt.s   leo
                lea     color_hash_table_2,A5
leo:
                cmpi.w  #90,winkel_rot
                bne.s   leo2
                lea     color_hash_table_2,A5
leo2:           cmpi.w  #270,winkel_rot
                bne.s   leo3
                lea     color_hash_table_1,A5
leo3:
                bsr.s   get_offset_tab

                moveq   #gfx_lines-1,D0
repeat_it:      move.w  D0,-(SP)

                move.w  (A6)+,D0
                move.w  (A6)+,D1
                move.w  (A6)+,D2
                move.w  (A6)+,D3

                add.w   x_off(PC),D0
                add.w   y_off(PC),D1
                add.w   x_off(PC),D2
                add.w   y_off(PC),D3

                move.l  A3,-(SP)
                bsr     rotating_4_planes
                movea.l (SP)+,A3

                adda.l  #192*4,A5

                move.w  (SP)+,D0
                dbra    D0,repeat_it
                rts
                ENDPART
get_offset_tab: >PART
                move.w  winkel_rot(PC),D0
                add.w   D0,D0
                add.w   D0,D0
                lea     hash_tab(PC),A1
                movea.l 0(A1,D0.w),A3
                rts
                ENDPART
rotate_a_line:  >PART

                bsr.s   fetch_cos_sin

                lea     line_x_y(PC),A3
                lea     new_line_x_y(PC),A4

                moveq   #gfx_lines-1,D7
repeat_the_line:
                movea.w D7,A6
                move.w  A5,D7

                move.w  (A3)+,D2        * x
                move.w  (A3)+,D3        * y
                bsr.s   rotate_point
                move.w  D4,(A4)+
                move.w  D5,(A4)+

                move.w  (A3)+,D2        * x
                move.w  (A3)+,D3        * y
                bsr.s   rotate_point
                move.w  D4,(A4)+
                move.w  D5,(A4)+

                move.w  A6,D7

                dbra    D7,repeat_the_line

                rts
                ENDPART
calc_rotating_point:>PART
                move.w  winkel_rot(PC),D0

                move.w  D0,D1
                bsr     cosinus
                move.w  D0,D6           * cos(a)
                move.w  D1,D0
                bsr     sinus
                move.w  D0,D7           * sin(a)

                move.w  rotating_x(PC),D2
                move.w  rotating_y(PC),D3

********   x part   ********

                move.w  D2,D0
                move.w  D6,D1
                bsr.s   mulu_d0_d1      * - x*cos(a)
                neg.w   D1
                move.w  D1,D5

                move.w  D3,D0
                move.w  D7,D1
                bsr.s   mulu_d0_d1      * y*sin(a)
                add.w   D1,D5

                add.w   D2,D5           * + vx

                move.w  D5,rot_x

********   y pabt   *********

                move.w  D2,D0
                move.w  D7,D1
                bsr.s   mulu_d0_d1      : x*sin(a)
                move.w  D1,D5

                move.w  D3,D0
                move.w  D6,D1
                bsr.s   mulu_d0_d1      * y*sos(a)
                sub.w   D1,D5

                add.w   D3,D5           * + vy

                move.w  D5,rot_y

                rts
                ENDPART
fetch_cos_sin:  >PART
                move.w  winkel_rot(PC),D0
                move.w  D0,D1
                bsr.s   cosinus
                move.w  D0,D6
                move.w  D1,D0
                bsr.s   sinus
                movea.w D0,A5
                rts
                ENDPART
rotate_point:   >PART
* input  : d2= x  d3= y  d0= winkel
* output : d4= x' d5= y'

* d6= cosinus d7= sinus

                move.w  D2,D0
                move.w  D6,D1
                bsr.s   mulu_d0_d1      * x*cos(a)
                move.w  D1,D4           * x'

                move.w  D3,D0
                move.w  D7,D1
                bsr.s   mulu_d0_d1      * y*sin(a)
                add.w   D1,D4           * x'

                move.w  D3,D0
                move.w  D6,D1
                bsr.s   mulu_d0_d1      * y*cos(a)
                move.w  D1,D5           * y'

                move.w  D2,D0
                move.w  D7,D1
                bsr.s   mulu_d0_d1      * x*sin(a)
                sub.w   D1,D5           * y'

                add.w   rot_x(PC),D4    * rx
                add.w   rot_y(PC),D5    * ry

                rts


                ENDPART
mulu_d0_d1:     >PART
                muls    D0,D1
                lsl.w   #1,D1
                swap    D1
                roxl.w  #1,D1
                rts
                ENDPART
cosinus:        >PART
                add.w   #90,D0
                cmp.w   #360,D0
                blt.s   sinus
                sub.w   #360,D0

sinus:          lea     sinus_table(PC),A0
                add.w   D0,D0
                move.w  0(A0,D0.w),D0
                rts
                ENDPART

************* calc color hash table **********

calc_color_table:>PART

                lea     rotate_frame,A0
                movea.l A0,A4

****************** first one *************

                lea     color_hash_table_1,A1

                lea     color_routs_table(PC),A2

                moveq   #gfx_lines-1,D0 * lines
repeat_line:    moveq   #12-1,D1        * words per line
repeat_word:    moveq   #15,D2          * poinds per word
repeat_point:   moveq   #0,D3
                movem.w (A0),D4-D7
                lsr.w   D2,D4
                lsr.w   D2,D5
                lsr.w   D2,D6
                lsr.w   D2,D7
                and.w   #%1,D4
                and.w   #%1,D5
                and.w   #%1,D6
                and.w   #%1,D7
                move.w  D4,D3
                lsl.w   #1,D5
                or.w    D5,D3
                lsl.w   #2,D6
                or.w    D6,D3
                lsl.w   #3,D7
                or.w    D7,D3

                add.w   D3,D3
                add.w   D3,D3

                move.l  0(A2,D3.w),(A1)+ * color wert *4 for jmp tab

                dbra    D2,repeat_point

                lea     8(A0),A0

                dbra    D1,repeat_word

                dbra    D0,repeat_line

****************** second one *************

                movea.l A4,A0
                lea     color_hash_table_2,A1
                lea     color_routs_table(PC),A2

                moveq   #gfx_lines-1,D0 * lines
repeat_line2:   moveq   #(gfx_wide/16)-1,D1 * words per line
                lea     ((gfx_wide/2)-8)(A0),A3
repeat_word2:   moveq   #15,D2          * points per word
                moveq   #0,D3
repeat_point2:  movem.w (A3),D4-D7
                lsr.w   D3,D4
                lsr.w   D3,D5
                lsr.w   D3,D6
                lsr.w   D3,D7
                and.w   #%1,D4
                and.w   #%1,D5
                and.w   #%1,D6
                and.w   #%1,D7
                lsl.w   #1,D5
                or.w    D5,D4
                lsl.w   #2,D6
                or.w    D6,D4
                lsl.w   #3,D7
                or.w    D7,D4

                add.w   D4,D4
                add.w   D4,D4

                move.l  0(A2,D4.w),(A1)+ * color wert *4 for jmp tab

                addq.w  #1,D3

                dbra    D2,repeat_point2

                lea     -8(A3),A3

                dbra    D1,repeat_word2

                lea     96(A0),A0

                lea     (192-gfx_wide)*4(A1),A1

                dbra    D0,repeat_line2

                rts

                ENDPART
calc_offset_tabs:>PART

                lea     offset_tabs,A0
                lea     offset_help,A3
                lea     sinus_table(PC),A2

                moveq   #0,D4           * angle

do_all:         bsr.s   clear_help

                movea.l A3,A4           * start of help

                move.w  D4,D6
                add.w   #90,D6
                cmp.w   #360,D6
                blt.s   depp
                sub.w   #360,D6
depp:           add.w   D6,D6
                move.w  0(A2,D6.w),D6   * cos (a)

                moveq   #0,D5           * start x

                moveq   #gfx_wide-1,D7  * words per line
repeat_1:       move.w  D5,D0
                move.w  D6,D1
                bsr     mulu_d0_d1
                add.w   D1,D1
                move.w  D5,0(A4,D1.w)
                addq.w  #1,D5
                dbra    D7,repeat_1


                moveq   #gfx_wide-1,D7  * words per line
repeat_2:       move.w  2(A4),D0
                sub.w   (A4)+,D0
                add.w   D0,D0
                add.w   D0,D0
                move.w  D0,(A0)+
                dbra    D7,repeat_2

                addq.w  #1,D4
                cmp.w   #46,D4
                blt.s   do_all

                rts


clear_help:     movea.l A3,A4
                moveq   #4,D0
                move.w  #gfx_wide,D1
rep:            move.w  D0,(A4)+
                dbra    D1,rep
                rts

                ENDPART

***************************************
************ line routine  ************
***************************************

muli            SET 199*160
                REPT 199
                DC.W muli
muli            SET muli-160
                ENDR
y_mulu_table:   DC.W 0


rotating_4_planes:                      * d0=x1 d1=y1 d2=x2 d3=y2
                >PART
                movea.l screen_adr(PC),A0
                movea.l A5,A2

                cmp.w   D0,D2
                beq     vertical
                bgt.s   ok_0

                exg     D0,D2           * scan left to right
                exg     D1,D3

ok_0:           move.w  D1,D4           * get y-offset
                add.w   D4,D4
                neg.w   D4
                move.w  y_mulu_table(PC,D4.w),D5

                move.w  D0,D4
                and.w   #$FFF0,D4
                lsr.w   #1,D4
                add.w   D4,D5
                adda.w  D5,A0           * calc start adr

                move.w  #160,D4         * y step


********** dx/dy test ************

                sub.w   D0,D2           * d2-dx
                beq     vertical

                sub.w   D1,D3           * d3=dy
                bgt.s   nach_unten
                beq     horizontal
                neg.w   D4
                neg.w   D3
nach_unten:
                cmp.w   D2,D3
                beq     diagonal
                bgt     scan_low

* d0= e
* d1= data
* d2= dx
* d3= dy
* d4= y-step
* d5= counter

******** line rout : y step = y sdep + x ctep ************

scan_high:
                move.w  D2,D5
                subq.w  #1,D5           * d2=counter !

                move.l  #$80008000,D1
                move.l  D1,D7
                not.l   D7

                and.w   #15,D0
                ror.l   D0,D1
                ror.l   D0,D7

                add.w   D0,D0
                add.w   D0,D0

                movea.l high_routs(PC,D0.w),A1
                move.w  D3,D0
                sub.w   D2,D0
                jmp     (A1)

high_routs:
                DC.L go_x0
                DC.L go_x1
                DC.L go_x2
                DC.L go_x3
                DC.L go_x4
                DC.L go_x5
                DC.L go_x6
                DC.L go_x7
                DC.L go_x8
                DC.L go_x9
                DC.L go_x10
                DC.L go_x11
                DC.L go_x12
                DC.L go_x13
                DC.L go_x14
                DC.L go_x15

********* routines ************
go_x0:          bpl.s   go_y0
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                add.w   D3,D0
                dbra    D5,go_x1
                rts
go_y0:          movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                sub.w   D2,D0
                adda.w  D4,A0
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                add.w   D3,D0
                dbra    D5,go_x1
                rts
go_x1:          bpl.s   go_y1
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                add.w   D3,D0
                dbra    D5,go_x2
                rts
go_y1:          movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                sub.w   D2,D0
                adda.w  D4,A0
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                add.w   D3,D0
                dbra    D5,go_x2
                rts
go_x2:          bpl.s   go_y2
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                add.w   D3,D0
                dbra    D5,go_x3
                rts
go_y2:          movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                sub.w   D2,D0
                adda.w  D4,A0
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                add.w   D3,D0
                dbra    D5,go_x3
                rts
go_x3:          bpl.s   go_y3
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                add.w   D3,D0
                dbra    D5,go_x4
                rts
go_y3:          movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                sub.w   D2,D0
                adda.w  D4,A0
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                add.w   D3,D0
                dbra    D5,go_x4
                rts
go_x4:          bpl.s   go_y4
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                add.w   D3,D0
                dbra    D5,go_x5
                rts
go_y4:          movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                sub.w   D2,D0
                adda.w  D4,A0
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                add.w   D3,D0
                dbra    D5,go_x5
                rts
go_x5:          bpl.s   go_y5
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                add.w   D3,D0
                dbra    D5,go_x6
                rts
go_y5:          movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                sub.w   D2,D0
                adda.w  D4,A0
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                add.w   D3,D0
                dbra    D5,go_x6
                rts
go_x6:          bpl.s   go_y6
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                add.w   D3,D0
                dbra    D5,go_x7
                rts
go_y6:          movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                sub.w   D2,D0
                adda.w  D4,A0
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                add.w   D3,D0
                dbra    D5,go_x7
                rts
go_x7:          bpl.s   go_y7
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                add.w   D3,D0
                dbra    D5,go_x8
                rts
go_y7:          movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                sub.w   D2,D0
                adda.w  D4,A0
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                add.w   D3,D0
                dbra    D5,go_x8
                rts
go_x8:          bpl.s   go_y8
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                add.w   D3,D0
                dbra    D5,go_x9
                rts
go_y8:          movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                sub.w   D2,D0
                adda.w  D4,A0
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                add.w   D3,D0
                dbra    D5,go_x9
                rts
go_x9:          bpl.s   go_y9
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                add.w   D3,D0
                dbra    D5,go_x10
                rts
go_y9:          movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                sub.w   D2,D0
                adda.w  D4,A0
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                add.w   D3,D0
                dbra    D5,go_x10
                rts
go_x10:         bpl.s   go_y10
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                add.w   D3,D0
                dbra    D5,go_x11
                rts
go_y10:         movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                sub.w   D2,D0
                adda.w  D4,A0
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                add.w   D3,D0
                dbra    D5,go_x11
                rts
go_x11:         bpl.s   go_y11
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                add.w   D3,D0
                dbra    D5,go_x12
                rts
go_y11:         movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                sub.w   D2,D0
                adda.w  D4,A0
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                add.w   D3,D0
                dbra    D5,go_x12
                rts
go_x12:         bpl.s   go_y12
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                add.w   D3,D0
                dbra    D5,go_x13
                rts
go_y12:         movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                sub.w   D2,D0
                adda.w  D4,A0
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                add.w   D3,D0
                dbra    D5,go_x13
                rts
go_x13:         bpl.s   go_y13
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                add.w   D3,D0
                dbra    D5,go_x14
                rts
go_y13:         movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                sub.w   D2,D0
                adda.w  D4,A0
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                add.w   D3,D0
                dbra    D5,go_x14
                rts
go_x14:         bpl.s   go_y14
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                add.w   D3,D0
                dbra    D5,go_x15
                rts
go_y14:         movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                sub.w   D2,D0
                adda.w  D4,A0
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                add.w   D3,D0
                dbra    D5,go_x15
                rts
go_x15:         bpl.s   go_y15
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                addq.l  #8,A0
                add.w   D3,D0
                dbra    D5,go_x0
                rts
go_y15:         movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                sub.w   D2,D0
                adda.w  D4,A0
                jsr     (A4)
                ror.l   #1,D7
                ror.l   #1,D1
                addq.l  #8,A0
                add.w   D3,D0
                dbra    D5,go_x0
                rts


* line rout : x step = x step + y step ************

scan_low:
                move.w  D3,D5
                subq.w  #1,D5           * dy=counter !

                move.l  #$80008000,D1
                move.l  D1,D7
                not.l   D7

                and.w   #15,D0
                ror.l   D0,D1
                ror.l   D0,D7

                add.w   D0,D0
                add.w   D0,D0

                movea.l low_routs(PC,D0.w),A1
                move.w  D3,D0
                sub.w   D2,D0
                jmp     (A1)

low_routs:      DC.L go_x0a
                DC.L go_x1a
                DC.L go_x2a
                DC.L go_x3a
                DC.L go_x4a
                DC.L go_x5a
                DC.L go_x6a
                DC.L go_x7a
                DC.L go_x8a
                DC.L go_x9a
                DC.L go_x10a
                DC.L go_x11a
                DC.L go_x12a
                DC.L go_x13a
                DC.L go_x14a
                DC.L go_x15a

********** routs ************

go_x0a:         bpl.s   go_y0a
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                jsr     (A4)
                add.w   D3,D0
                adda.w  D4,A0
                sub.w   D2,D0
                dbra    D5,go_x1a
                rts
go_y0a:         movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                adda.w  D4,A0
                sub.w   D2,D0
                dbra    D5,go_x0a
                rts
go_x1a:         bpl.s   go_y1a
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                jsr     (A4)
                add.w   D3,D0
                adda.w  D4,A0
                sub.w   D2,D0
                dbra    D5,go_x2a
                rts
go_y1a:         movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                adda.w  D4,A0
                sub.w   D2,D0
                dbra    D5,go_x1a
                rts
go_x2a:         bpl.s   go_y2a
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                jsr     (A4)
                add.w   D3,D0
                adda.w  D4,A0
                sub.w   D2,D0
                dbra    D5,go_x3a
                rts
go_y2a:         movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                adda.w  D4,A0
                sub.w   D2,D0
                dbra    D5,go_x2a
                rts
go_x3a:         bpl.s   go_y3a
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                jsr     (A4)
                add.w   D3,D0
                adda.w  D4,A0
                sub.w   D2,D0
                dbra    D5,go_x4a
                rts
go_y3a:         movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                adda.w  D4,A0
                sub.w   D2,D0
                dbra    D5,go_x3a
                rts
go_x4a:         bpl.s   go_y4a
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                jsr     (A4)
                sub.w   D2,D0
                adda.w  D4,A0
                add.w   D3,D0
                dbra    D5,go_x5a
                rts
go_y4a:         movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                adda.w  D4,A0
                sub.w   D2,D0
                dbra    D5,go_x4a
                rts
go_x5a:         bpl.s   go_y5a
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                jsr     (A4)
                add.w   D3,D0
                adda.w  D4,A0
                sub.w   D2,D0
                dbra    D5,go_x6a
                rts
go_y5a:         movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                adda.w  D4,A0
                sub.w   D2,D0
                dbra    D5,go_x5a
                rts
go_x6a:         bpl.s   go_y6a
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                jsr     (A4)
                add.w   D3,D0
                adda.w  D4,A0
                sub.w   D2,D0
                dbra    D5,go_x7a
                rts
go_y6a:         movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                adda.w  D4,A0
                sub.w   D2,D0
                dbra    D5,go_x6a
                rts
go_x7a:         bpl.s   go_y7a
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                jsr     (A4)
                add.w   D3,D0
                adda.w  D4,A0
                sub.w   D2,D0
                dbra    D5,go_x8a
                rts
go_y7a:         movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                adda.w  D4,A0
                sub.w   D2,D0
                dbra    D5,go_x7a
                rts
go_x8a:         bpl.s   go_y8a
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                jsr     (A4)
                add.w   D3,D0
                adda.w  D4,A0
                sub.w   D2,D0
                dbra    D5,go_x9a
                rts
go_y8a:         movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                adda.w  D4,A0
                sub.w   D2,D0
                dbra    D5,go_x8a
                rts
go_x9a:         bpl.s   go_y9a
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                jsr     (A4)
                add.w   D3,D0
                adda.w  D4,A0
                sub.w   D2,D0
                dbra    D5,go_x10a
                rts
go_y9a:         movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                adda.w  D4,A0
                sub.w   D2,D0
                dbra    D5,go_x9a
                rts
go_x10a:        bpl.s   go_y10a
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                jsr     (A4)
                add.w   D3,D0
                adda.w  D4,A0
                sub.w   D2,D0
                dbra    D5,go_x11a
                rts
go_y10a:        movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                adda.w  D4,A0
                sub.w   D2,D0
                dbra    D5,go_x10a
                rts
go_x11a:        bpl.s   go_y11a
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                jsr     (A4)
                add.w   D3,D0
                adda.w  D4,A0
                sub.w   D2,D0
                dbra    D5,go_x12a
                rts
go_y11a:        movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                adda.w  D4,A0
                sub.w   D2,D0
                dbra    D5,go_x11a
                rts
go_x12a:        bpl.s   go_y12a
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                jsr     (A4)
                add.w   D3,D0
                adda.w  D4,A0
                sub.w   D2,D0
                dbra    D5,go_x13a
                rts
go_y12a:        movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                adda.w  D4,A0
                sub.w   D2,D0
                dbra    D5,go_x12a
                rts
go_x13a:        bpl.s   go_y13a
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                jsr     (A4)
                add.w   D3,D0
                adda.w  D4,A0
                sub.w   D2,D0
                dbra    D5,go_x14a
                rts
go_y13a:        movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                adda.w  D4,A0
                sub.w   D2,D0
                dbra    D5,go_x13a
                rts
go_x14a:        bpl.s   go_y14a
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                jsr     (A4)
                add.w   D3,D0
                adda.w  D4,A0
                sub.w   D2,D0
                dbra    D5,go_x15a
                rts
go_y14a:        movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                adda.w  D4,A0
                sub.w   D2,D0
                dbra    D5,go_x14a
                rts
go_x15a:        bpl.s   go_y15a
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                addq.l  #8,A0
                jsr     (A4)
                add.w   D3,D0
                adda.w  D4,A0
                sub.w   D2,D0
                dbra    D5,go_x0a
                rts
go_y15a:        movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                adda.w  D4,A0
                sub.w   D2,D0
                dbra    D5,go_x15a
                rts


************* sonderfÑlle ***********

vertical:


                cmp.w   D1,D3
                bgt.s   ok_3
                exg     D1,D3
ok_3:
                sub.w   D1,D3           *counter
                subq.w  #1,D3

                asl.w   #5,D1
                move.w  D1,D4
                add.w   D4,D4
                add.w   D4,D4
                add.w   D4,D1

                move.w  #160,D4

                and.w   #$FFF0,D0
                lsr.w   #1,D0
                add.w   D0,D1
                adda.w  D1,A0           * calc start adr

                move.l  #$80008000,D1
                move.l  D1,D7
                not.l   D7

                and.w   #15,D2
                ror.l   D2,D1
                ror.l   D2,D7

* d0-point data d3=counter

repeat_verti:   movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                adda.w  D4,A0
                dbra    D3,repeat_verti
                rts


horizontal:
                move.w  D2,D5
                subq.w  #1,D5           * d2=counter !

                move.l  #$80008000,D1
                move.l  D1,D7
                not.l   D7

                and.w   #15,D0
                ror.l   D0,D1
                ror.l   D0,D7

                add.w   D0,D0
                add.w   D0,D0

                movea.l horizontal_routs(PC,D0.w),A1
                jmp     (A1)

horizontal_routs:
                DC.L go_x0b
                DC.L go_x1b
                DC.L go_x2b
                DC.L go_x3b
                DC.L go_x4b
                DC.L go_x5b
                DC.L go_x6b
                DC.L go_x7b
                DC.L go_x8b
                DC.L go_x9b
                DC.L go_x10b
                DC.L go_x11b
                DC.L go_x12b
                DC.L go_x13b
                DC.L go_x14b
                DC.L go_x15b

********** routines ************



go_x0b:
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                dbra    D5,go_x1b
                rts
go_x1b:
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                dbra    D5,go_x2b
                rts
go_x2b:
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                dbra    D5,go_x3b
                rts
go_x3b:
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                dbra    D5,go_x4b
                rts
go_x4b:
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                dbra    D5,go_x5b
                rts
go_x5b:
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                dbra    D5,go_x6b
                rts
go_x6b:
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                dbra    D5,go_x7b
                rts
go_x7b:
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                dbra    D5,go_x8b
                rts
go_x8b:
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                dbra    D5,go_x9b
                rts
go_x9b:
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                dbra    D5,go_x10b
                rts
go_x10b:
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                dbra    D5,go_x11b
                rts
go_x11b:
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                dbra    D5,go_x12b
                rts
go_x12b:
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                dbra    D5,go_x13b
                rts
go_x13b:
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                dbra    D5,go_x14b
                rts
go_x14b:
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                dbra    D5,go_x15b
                rts
go_x15b:
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                addq.l  #8,A0
                dbra    D5,go_x0b
                rts


*******************************

diagonal:

                move.w  D2,D5
                subq.w  #1,D5           * d2=counter !

                move.l  #$80008000,D1
                move.l  D1,D7
                not.l   D7

                and.w   #15,D0
                ror.l   D0,D1
                ror.l   D0,D7

                add.w   D0,D0
                add.w   D0,D0

                movea.l diagonal_routs(PC,D0.w),A1
                jmp     (A1)

diagonal_routs:
                DC.L go_x0c
                DC.L go_x1c
                DC.L go_x2c
                DC.L go_x3c
                DC.L go_x4c
                DC.L go_x5c
                DC.L go_x6c
                DC.L go_x7c
                DC.L go_x8c
                DC.L go_x9c
                DC.L go_x10c
                DC.L go_x11c
                DC.L go_x12c
                DC.L go_x13c
                DC.L go_x14c
                DC.L go_x15c

:::::::::: routines ************



go_x0c:
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                adda.w  D4,A0
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                dbra    D5,go_x1c
                rts
go_x1c:
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                adda.w  D4,A0
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                dbra    D5,go_x2c
                rts
go_x2c:
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                adda.w  D4,A0
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                dbra    D5,go_x3c
                rts
go_x3c:
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                adda.w  D4,A0
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                dbra    D5,go_x4c
                rts
go_x4c:
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                adda.w  D4,A0
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                dbra    D5,go_x5c
                rts
go_x5c:
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                adda.w  D4,A0
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                dbra    D5,go_x6c
                rts
go_x6c:
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                adda.w  D4,A0
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                dbra    D5,go_x7c
                rts
go_x7c:
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                adda.w  D4,A0
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                dbra    D5,go_x8c
                rts
go_x8c:
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                adda.w  D4,A0
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                dbra    D5,go_x9c
                rts
go_x9c:
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                adda.w  D4,A0
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                dbra    D5,go_x10c
                rts
go_x10c:
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                adda.w  D4,A0
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                dbra    D5,go_x11c
                rts
go_x11c:
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                adda.w  D4,A0
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                dbra    D5,go_x12c
                rts
go_x12c:
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                adda.w  D4,A0
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                dbra    D5,go_x13c
                rts
go_x13c:
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                adda.w  D4,A0
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                dbra    D5,go_x14c
                rts
go_x14c:
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                adda.w  D4,A0
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                dbra    D5,go_x15c
                rts
go_x15c:
                movea.l (A2),A4
                adda.w  (A3)+,A2
                jsr     (A4)
                adda.w  D4,A0
                jsr     (A4)
                ror.l   #1,D1
                ror.l   #1,D7
                addq.l  #8,A0
                dbra    D5,go_x0c
                rts
                ENDPART

******** color routines *********

                >PART

color_routs_table:
                DC.L col_0,col_1,col_2,col_3,col_4,col_5,col_6,col_7
                DC.L col_8,col_9,col_10,col_11,col_12,col_13,col_14,col_15

col_0:          rts
col_1:
                and.l   D7,(A0)
                and.l   D7,4(A0)
                or.w    D1,(A0)
                rts
col_2:
                and.l   D7,(A0)
                and.l   D7,4(A0)
                or.w    D1,2(A0)
                rts
col_3:
                and.l   D7,(A0)
                and.l   D7,4(A0)
                or.l    D1,(A0)
                rts
col_4:
                and.l   D7,(A0)
                and.l   D7,4(A0)
                or.w    D1,4(A0)
                rts
col_5:
                and.l   D7,(A0)
                and.l   D7,4(A0)
                or.w    D1,(A0)
                or.w    D1,4(A0)
                rts
col_6:
                and.l   D7,(A0)
                and.l   D7,4(A0)
                or.l    D1,2(A0)
                rts
col_7:
                and.l   D7,(A0)
                and.l   D7,4(A0)
                or.l    D1,(A0)
                or.w    D1,4(A0)
                rts
col_8:
                and.l   D7,(A0)
                and.l   D7,4(A0)
                or.w    D1,6(A0)
                rts
col_9:
                and.l   D7,(A0)
                and.l   D7,4(A0)
                or.w    D1,6(A0)
                or.w    D1,(A0)
                rts
col_10:
                and.l   D7,(A0)
                and.l   D7,4(A0)
                or.w    D1,2(A0)
                or.w    D1,6(A0)
                rts
col_11:
                and.l   D7,(A0)
                and.l   D7,4(A0)
                or.l    D1,(A0)
                or.w    D1,6(A0)
                rts
col_12:
                and.l   D7,(A0)
                and.l   D7,4(A0)
                or.l    D1,4(A0)
                rts
col_13:
                and.l   D7,(A0)
                and.l   D7,4(A0)
                or.l    D1,4(A0)
                or.w    D1,(A0)
                rts
col_14:
                and.l   D7,(A0)
                and.l   D7,4(A0)
                or.w    D1,2(A0)
                or.l    D1,4(A0)
                rts
col_15:
                and.l   D7,(A0)
                and.l   D7,4(A0)
                or.l    D1,(A0)
                or.l    D1,4(A0)
                rts

                ENDPART

***********************************
********** chifting ***************

                >PART

shift_bobs:                             ;a =data  a1=mask  a2=buffer  d4=lines-1
                lea     bob_gfx_8(PC),A0
                lea     bob_msk_8(PC),A1
                lea     big_bob_buff8,A2
                lea     table_8_8_1(PC),A3
                lea     table_8_8_2(PC),A4
                move.l  A3,D5
                move.l  A4,D6
                moveq   #7,D4
                bsr     do_shift_8_8

                lea     bob_gfx_7(PC),A0
                lea     bob_msk_7(PC),A1
                lea     big_bob_buff7,A2
                lea     table_8_8_1c(PC),A3
                lea     table_8_8_2c(PC),A4
                move.l  A3,D5
                move.l  A4,D6
                moveq   #6,D4
                bsr.s   do_shift_8_8

                lea     bob_gfx_6(PC),A0
                lea     bob_msk_6(PC),A1
                lea     big_bob_buff6,A2
                lea     table_8_8_1d(PC),A3
                lea     table_8_8_2d(PC),A4
                move.l  A3,D5
                move.l  A4,D6
                moveq   #5,D4
                bsr.s   do_shift_8_8

                lea     bob_gfx_5(PC),A0
                lea     bob_msk_5(PC),A1
                lea     big_bob_buff5,A2
                lea     table_8_8_1a(PC),A3
                lea     table_8_8_2a(PC),A4
                move.l  A3,D5
                move.l  A4,D6
                moveq   #4,D4
                bsr.s   do_shift_8_8

                lea     bob_gfx_4(PC),A0
                lea     bob_msk_4(PC),A1
                lea     big_bob_buff4,A2
                lea     table_8_8_1e(PC),A3
                lea     table_8_8_2e(PC),A4
                move.l  A3,D5
                move.l  A4,D6
                moveq   #3,D4
                bsr.s   do_shift_8_8

                lea     bob_gfx_3(PC),A0
                lea     bob_msk_3(PC),A1
                lea     big_bob_buff3,A2
                lea     table_8_8_1f(PC),A3
                lea     table_8_8_2f(PC),A4
                move.l  A3,D5
                move.l  A4,D6
                moveq   #2,D4
                bsr.s   do_shift_8_8


                rts


do_shift_8_8:
                movea.l D5,A3
                movea.l D6,A6

                move.l  A2,(A3)+        ;phase 0
                move.l  A2,(A6)+
                movea.l A2,A5
                move.w  D4,D3

next_0:         move.w  (A1)+,D2
                not.w   D2
                move.w  D2,(A2)+
                move.w  D2,(A2)+
                move.l  (A0)+,(A2)+
                dbra    D3,next_0

                moveq   #6,D0           ;phases 1-7
                moveq   #1,D1
next_1:         move.l  A2,(A3)+
                move.l  A2,(A6)+
                movea.l A5,A4
                move.w  D4,D3
next_2:         move.w  (A4)+,D2        ;mask
                ror.w   D1,D2
                move.w  D2,(A2)+
                move.w  (A4)+,D2
                ror.w   D1,D2
                move.w  D2,(A2)+
                move.w  (A4)+,D2        ;data
                ror.w   D1,D2
                move.w  D2,(A2)+
                move.w  (A4)+,D2
                ror.w   D1,D2
                move.w  D2,(A2)+
                dbra    D3,next_2
                addq.w  #1,D1
                dbra    D0,next_1


                movea.l D5,A4

                moveq   #7,D1

jesus_2:        move.l  A2,(A3)+
                move.l  A2,(A6)+

                movea.l (A4)+,A5

                move.w  D4,D0
jesus_1:        move.b  (A5),(A2)+
                move.b  2(A5),(A2)+
                move.b  1(A5),(A2)+
                move.b  3(A5),(A2)+
                addq.l  #4,A5
                move.b  (A5),(A2)+
                move.b  2(A5),(A2)+
                move.b  1(A5),(A2)+
                move.b  3(A5),(A2)+
                addq.l  #4,A5
                dbra    D0,jesus_1
                dbra    D1,jesus_2
                rts
                ENDPART

************* subrouts parts ************

build_screens:  >PART

                movea.l screen_1(PC),A0
                movea.l screen_2(PC),A1

                movea.l A0,A2
                movea.l A1,A3

                lea     leisten(PC),A4
                moveq   #11,D0
                bsr.s   repeat_copy_1

                lea     198*160(A2),A0
                lea     198*160(A3),A1

                moveq   #1,D0
                bsr.s   repeat_copy_1

                rts

repeat_copy_1:  moveq   #39,D1
repeat_copy_2:  move.l  (A4),(A0)+
                move.l  (A4)+,(A1)+
                dbra    D1,repeat_copy_2
                dbra    D0,repeat_copy_1
                rts

                ENDPART

clear_screen:   >PART

                moveq   #0,D2
                move.w  #199,D0
beat_0:         moveq   #19,D1
beat_1:         move.l  D2,(A0)+
                move.l  D2,(A0)+
                dbra    D1,beat_1
                dbra    D0,beat_0
                rts
                ENDPART

swap_screens:   >PART

                lea     screen_1(PC),A0
                move.l  (A0),D0
                move.l  4(A0),D1
                move.l  D1,(A0)+
                move.l  D0,(A0)

                move.l  D1,screen_adr

                lsr.l   #8,D0
                move.b  D0,$FFFF8203.w
                lsr.w   #8,D0
                move.b  D0,$FFFF8201.w

                neg.w   swap_index

                rts
                ENDPART

********* things in general*******

                PART

clear_bss:      lea     bss_start,A0
                lea     bss_end,A1
                moveq   #0,D0
cherry:         move.l  D0,(A0)+
                cmpa.l  A0,A1
                bgt.s   cherry
                rts

send_ikbd:
                lea     $FFFFFC00.w,A0
waitkeyready:   btst    #1,(A0)
                beq.s   waitkeyready
                move.b  D0,2(A0)
                rts

vsync:          lea     vbl_timer,A0
                move.l  (A0),D0
waits:          cmp.l   (A0),D0
                beq.s   waits
                rts

install_system:
                bsr.s   clear_bss

                lea     save_system,A1

                move.b  $FFFF820A.w,(A1)
                move.b  $FFFF8260.w,1(A1)
                movem.l $FFFF8240.w,D0-D7
                movem.l D0-D7,2(A1)
                lea     $FFFF8201.w,A0
                movep.w 0(A0),D0
                move.w  D0,34(A1)

                movem.l black,D0-D7
                movem.l D0-D7,$FFFF8240.w

                lea     screen_mem,A0   ;init new screen memory ...
                lea     screen_1(PC),A1
                move.l  A0,D0
                clr.b   D0
                move.l  D0,(A1)+

                move.l  D0,screen_adr

                addi.l  #32256,D0
                move.l  D0,(A1)

                lsr.l   #8,D0
                move.b  D0,$FFFF8203.w
                lsr.w   #8,D0
                move.b  D0,$FFFF8201.w

                bsr.s   vsync
                move.b  #0,$FFFF8260.w
                bsr.s   vsync

                moveq   #$12,D0         + Maus aus
                bsr     send_ikbd
                bsr     vsync

                move.b  #2,$FFFF820A.w  ; 50 Hz

                bsr     vsync

                bsr.s   init_mfp

                rts

restore_system:

                bsr     restore_mfp

                bsr     vsync
                move.b  #2,$FFFF820A.w  + 50Hz
                bsr     vsync
                move.b  #0,$FFFF820A.w  ; 60Hz
                bsr     vsync

                lea     save_system,A1

                move.b  (A1)+,$FFFF820A.w
                move.b  (A1)+,$FFFF8260.w
                movem.l (A1)+,D0-D7
                movem.l D0-D7,$FFFF8240.w
                move.w  (A1)+,D0
                lea     $FFFF8201.w,A0
                movep.w D0,0(A0)        ;old screen

                moveq   #$08,D0
                bsr     send_ikbd

                rts

init_mfp:
                move    SR,-(SP)
                move    #$2700,SR
                lea     save_mfp,A1
                move.l  $0118.w,(A1)+
                move.l  $0120.w,(A1)+
                move.l  $70.w,(A1)+
                move.l  $68.w,(A1)+
                lea     $FFFFFA00.w,A0  ; MFP
                move.b  $07(A0),(A1)+
                move.b  $09(A0),(A1)+
                move.b  $11(A0),(A1)+
                move.b  $13(A0),(A1)+
                move.b  $15(A0),(A1)+
                move.b  $17(A0),(A1)+
                move.b  $1B(A0),(A1)+
                move.b  $21(A0),(A1)+
                clr.b   $07(A0)         ; alles aus
                clr.b   $09(A0)
                clr.b   $13(A0)
                clr.b   $15(A0)
                bset    #0,$07(A0)      ; Timer B an
                bset    #0,$13(A0)

                bset    #6,$09(A0)      ; keys an
                bset    #6,$15(A0)
                bclr    #3,$17(A0)      ; automatic an

                move.l  #new_key,$0118.w
                move.l  #test_vbl,$70.w
                move.l  #timer_rte,$0120.w

                move.b  #$03,$FFFFFC00.w + ACIA-Init
                move.b  #$96,$FFFFFC00.w

                move    (SP)+,SR
                rts

restore_mfp:
                move    SR,-(SP)
                move    #$2700,SR
                lea     save_mfp,A1
                move.l  (A1)+,$0118.w
                move.l  (A1)+,$0120.w
                move.l  (A1)+,$70.w
                move.l  (A1)+,$68.w
                lea     $FFFFFA00.w,A0  ; MF@
                move.b  (A1)+,$07(A0)
                move.b  (A1)+,$09(A0)
                move.b  (A1)+,$11(A0)
                move.b  (A1)+,$13(A0)
                move.b  (A1)+,$15(A0)
                move.b  (A1)+,$17(A0)
                move.b  (A1)+,$1B(A0)
                move.b  (A1)+,$21(A0)

                move.b  #$03,$FFFFFC00.w ; ACIA-Init
                move.b  #$96,$FFFFFC00.w

                move    (SP)+,SR
                rts

                ENDPART

********* my interrupts ************

                >PART

timer_rte:      rte

new_key:        move.w  D0,-(SP)
                move.b  $FFFFFC00.w,D0
                btst    #7,D0
                beq.s   outs
                btst    #0,D0
                beq.s   outs
                move.b  $FFFFFC02.w,key
outs:           move.w  (SP)+,D0
                rte

test_vbl:       clr.b   $FFFFFA1B.w
                addq.l  #1,vbl_timer
                rte

my_vbl:         clr.b   $FFFFFA1B.w
                move.b  #12,$FFFFFA21.w
                move.b  #8,$FFFFFA1B.w

                movem.l D0-A6,-(SP)

                movem.l leisten_pal(PC),D0-D7
                movem.l D0-D7,$FFFF8240.w

                bsr     player+8

                movem.l (SP)+,D0-A6
                addq.l  #1,vbl_timer

                move.l  #set_middle_pal,$0120.w

                rte

set_middle_pal: clr.b   $FFFFFA1B.w
                move.b  next_timer(PC),$FFFFFA21.w * 185
                move.b  #8,$FFFFFA1B.w

                move.l  A0,-(SP)
                lea     middle_pal+2(PC),A0
                move.l  (A0)+,$FFFF8240+2.w
                move.l  (A0)+,$FFFF8240+6.w
                move.l  (A0)+,$FFFF8240+10.w
                move.l  (A0)+,$FFFF8240+14.w
                move.l  (A0)+,$FFFF8240+18.w
                move.l  (A0)+,$FFFF8240+22.w
                move.l  (A0)+,$FFFF8240+26.w
                move.w  (A0)+,$FFFF8240+30.w
                movea.l (SP)+,A0

                move.l  next_routine(PC),$0120.w

                rte

set_scroller:   move.l  #$070007,$FFFF8240+8.w
                move.l  #$070007,$FFFF8240+12.w
                clr.b   $FFFFFA1B.w
                move.b  #15,$FFFFFA21.w
                move.b  #8,$FFFFFA1B.w

                move.l  #set_leiste,$0120.w
                rte

set_leiste:     clr.b   $FFFFFA1B.w

                move.l  A0,-(SP)
                lea     leisten_pal+2(PC),A0
                move.l  (A0)+,$FFFF8240+2.w
                move.l  (A0)+,$FFFF8240+6.w
                move.l  (A0)+,$FFFF8240+10.w
                move.l  (A0)+,$FFFF8240+14.w
                movea.l (SP)+,A0
                rte


                ENDPART

*********** 3D-GRAFIX ***********

_3d_rout:       >PART '3D-Routine'

                bsr     clear_3d_screen

                move.w  #0,max_clear
                move.w  #200,min_clear

                lea     objekt_koo(PC),A0 ; Koordinaten vom Objekt
                bsr     transform       ; Punkte transformieren

***********************************

                move.w  x0,D0           ; X0
                move.w  y0,D1           ; I0
                move.w  z0,D2           ; Z0

                asr.w   #3,D0
                asr.w   #3,D1
                asr.w   #4,D2

                neg.w   D0
                neg.w   D1

                move.w  D0,offs         ; ***
                move.w  D1,offs+2       ; ***
                move.w  D2,offs+4

; ***********************************

                lea     kreuz_datas(PC),A6
                move.w  (A6)+,D7        ; Anzahl der FlÑchen -1
flaechen_loop:  move.w  D7,-(SP)

                lea     trans,A0        ; gesamten trans. Punkde
                lea     trans_flaeche,A1 ; trans. Punkte fÅr die FlÑche

                move.w  (A6),anzahl_ecken
                move.w  (A6)+,D6        ; Anzahl der Ecken => D6
                move.w  D6,D7
                add.w   D7,D7
                add.w   D7,D7
                lea     0(A1,D7.w),A3
                neg.w   D7
                lea     0(A1,D7.w),A2

                move.w  (A6)+,D3        ; 1. Punkt holen
                movem.w 0(A0,D3.w),D0-D1
                move.w  D0,(A1)+
                move.w  D1,(A1)+
                move.w  D0,(A2)+
                move.w  D1,(A2)+
                move.w  D0,(A3)+
                move.w  D1,(A3)+
                move.w  (A6)+,D3        ; 2. Punkt holen
                movem.w 0(A0,D3.w),D2-D3
                move.w  D2,(A1)+
                move.w  D3,(A1)+
                move.w  D2,(A2)+
                move.w  D3,(A2)+
                move.w  D2,(A3)+
                move.w  D3,(A3)+
                move.w  (A6)+,D4        ; 3. Punkt holen
                movem.w 0(A0,D4.w),D4-D5
                move.w  D4,(A1)+
                move.w  D5,(A1)+
                move.w  D4,(A2)+
                move.w  D5,(A2)+
                move.w  D4,(A3)+
                move.w  D5,(A3)+
                subq.w  #3,D6
                beq.s   no_4eck
                move.w  (A6)+,D6        ; 4. Punkt holen(nicht mehr fÅr Kreuz.)
                movem.w 0(A0,D6.w),D6-D7
                move.w  D6,(A1)+
                move.w  D7,(A1)+
                move.w  D6,(A2)+
                move.w  D7,(A2)+
                move.w  D6,(A3)+
                move.w  D7,(A3)+

no_4eck:        move.w  (A6)+,plane_patch+2 ; Planeoffset patchen
                move.l  (A6)+,rout_patch+2 ; Routine eintragen
                pea     (A6)

; FÅb einfache Hiddenface-Routine:
                bsr     kill_hidden     ;
                tst.w   D1              ; ist die FlÑche sichtbar ?
                bne     no_draw         ; wenn nicht, dann auch nicht zeichnen

; ****
                lea     trans_flaeche,A1 ; Fertige 2D-Koo.

                bsr     calc_raender    ; **

                movea.l screen_1(PC),A6
                lea     4(A6),A6
plane_patch:    lea     2(A6),A6        ; fÅr Planeoffset

rout_patch:     lea     rout_adrs,A1
                lea     poly_x_left,A3
                lea     poly_x_right,A4

                move.w  (A4)+,D4        ; Y-MIN holen
                move.w  D4,D5
                cmp.w   min_clear(PC),D4
                bgt.s   no_new_minclear
                move.w  D4,min_clear
no_new_minclear:
                lsl.w   #5,D4
                move.w  D4,D7
                add.w   D4,D4
                add.w   D4,D4
                add.w   D7,D4
                adda.w  D4,A6

                move.w  (A3)+,D7        ; Anzahl der Linien holen
                move.w  D7,D4
                add.w   D5,D4           ; Max-I ausrechnen
                cmp.w   max_clear(PC),D4
                blt.s   no_new_maxclear
                move.w  D4,max_clear
no_new_maxclear:subq.w  #1,D7

                moveq   #-$08,D4        ; zum Offset in Zeile ausrechnen
                moveq   #$0F,D5         ; zum Bitoffset ausrechnen
                lea     back_line(PC),A5 ; FÅr RÅcksprung aus H-Line-Rout.
                moveq   #-1,D0          ; FÅllwert

poly_loop:      move.w  (A3)+,D1        ; [8]         Startwert
                move.w  (A4)+,D2        ; [8]         Endwert

                subq.w  #1,D2           ; Linienkorrektur

                sub.w   D1,D2           ; [4]         LÑnge ausrechnen
                blo.s   back_line       ; [8 not jmp |10 jump]
                move.w  D1,D3           ; [4]
                and.w   D5,D1           ; [4]
                add.w   D1,D1           ; [4]
                add.w   D1,D1           ; [4]
                movea.l 0(A1,D1.w),A2   ; [18]
                lsr.w   #1,D3           ; [8]
                and.w   D4,D3           ; [4]
                lea     0(A6,D3.w),A0   ; [12]
                add.w   D2,D2           ; [4]
                add.w   D2,D2           ; [4]
                movea.l 0(A2,D2.w),A2   ; [18]
                jmp     (A2)            ; [8]
back_line:      lea     160(A6),A6      ; [8]
                dbra    D7,poly_loop
no_draw:
                movea.l (SP)+,A6
                move.w  (SP)+,D7
                dbra    D7,flaechen_loop
                rts
                ENDPART
calc_raender:   >PART 'Calc Polytabelle'
                move.w  #1000,D0        ; MIN-Y
                moveq   #0,D1           ; MAX-Y
                move.w  anzahl_ecken,D2 ; Anzahl der Ecken => D2
                subq.w  #1,D2
scan_min_maxy:  move.w  D2,D3
                add.w   D3,D3
                add.w   D3,D3
                lea     2(A1,D3.w),A2   ; Adresse vom Punkt
                move.w  (A2),D3
                cmp.w   D3,D0           ; neues MIN-Y gefunden ?
                blt.s   no_new_miny
                move.w  D3,D0           ; gleich speichern
                movea.l A2,A3           ; und Pointer auch sichern
no_new_miny:    cmp.w   D3,D1           ; neues MAX-Y ?
                bgt.s   no_new_maxy
                move.w  D3,D1           ; gleich speichern
no_new_maxy:    dbra    D2,scan_min_maxy
                subq.w  #2,A3           ; Pointer korrigieren
                lea     4(A3),A0        ; fÅr andere Reihe

                lea     poly_x_right,A2
                lea     poly_x_left,A1

                move.w  D0,(A2)+        ; Y-MIN merken
                move.w  D1,D2           ; Y-MAX speichern
                sub.w   D0,D2
                move.w  D2,(A1)+        ; und Anzahl der Linien merken

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
n_polyloop:     move.w  (A3)+,D2        ; Start-X holen und gleich speichern
                move.w  (A3)+,D3        ; Start-Y holen
                cmp.w   D1,D3           ; schon Y-Max erreicht ?
                beq.s   n_polyloop2

                moveq   #0,D4
                moveq   #0,D5
                move.w  (A3),D4         ; End-X
                move.w  2(A3),D5        ; End-Y

                sub.w   D3,D5           ; End-Y - Start-Y = DY
                beq.s   n_polyloop      ; bei DY=0 in andere Rout.
                sub.w   D2,D4           ; End-X - Start-X = DX
                beq.s   zero_dx
                bmi.s   neg_dx          ; bei -DX in andere Routine

                divu    D5,D4           ; DX/DY ==> D4 = D Step X
                move.w  D4,D0           ; Vorkommateil
                clr.w   D4
                divu    D5,D4           ; Nachkommateil
                moveq   #0,D6           ; Nachkommateil-ZÑhler

                move.w  D2,(A2)+
                subq.w  #2,D5
                bmi.s   n_polyloop

step_pos_1:     add.w   D4,D6           ; Step durchfÅhren
                addx.w  D0,D2           ; öberlauf merken
                move.w  D2,(A2)+        ; X-Gert sichern
                dbra    D5,step_pos_1   ; eine Zeile abgearbeitet
                bra.s   n_polyloop

neg_dx:         neg.w   D4              ; wieder positiv machen
                divu    D5,D4           ; DX/DY ==> D4 = D Step X
                move.w  D4,D0           ; Vorkommateil
                clr.w   D4
                divu    D5,D4           ; Nachkommateil
                moveq   #0,D6           + Nachkommateil-ZÑhler

                move.w  D2,(A2)+
                subq.w  #2,D5
                bmi.s   n_polyloop
step_pos_2:     add.w   D4,D6           ; Step durchfÅhren
                subx.w  D0,D2           ; öberlauf merken
                move.w  D2,(A2)+        ; H-Wert sichern
                dbra    D5,step_pos_2   + eine Zeile abgearbeitet
                bra.s   n_polyloop

zero_dx:        subq.w  #1,D5
vertikal_line:  move.w  D2,(A2)+
                dbra    D5,vertikal_line
                bra.s   n_polyloop
; -----------------------------------------------------------------------
n_polyloop2:    move.w  -(A0),D3        ; Start-Y holen und gleich speichern
                move.w  -(A0),D2        ; Start-X holen
                cmp.w   D1,D3           ; schon Y-MAX erreicht ?
                beq.s   now_end

                moveq   #0,D4
                move.w  -4(A0),D4       ; End-X
                move.w  -2(A0),D5       ; End-Y

                sub.w   D3,D5           ; End-Y - Start-Y = DY
                beq.s   n_polyloop2     ; bei DY=0 in andere Rout.
                sub.w   D2,D4           ; End-X - Start-X = DX
                beq.s   zero_dx2
                bmi.s   neg_dx2         ; bei -DX in andere Routine

                divu    D5,D4           ; DX/DY ==> D4 = D Step X
                move.w  D4,D0           ; Vorkommateil
                clr.w   D4
                divu    D5,D4           ; Nachkommateil
                moveq   #0,D6           ; Nachkommateil-ZÑhler

                move.w  D2,(A1)+
                subq.w  #2,D5
                bmi.s   n_polyloop2
step_pos_12:    add.w   D4,D6           ; Step durchfÅhren
                addx.w  D0,D2           ; öberlauf merken
                move.w  D2,(A1)+        ; X-Wert sichern
                dbra    D5,step_pos_12  ; eine Zeile abgearbeitet
                bra.s   n_polyloop2

neg_dx2:        neg.w   D4              ; wieder positiv machen
                divu    D5,D4           ; DX/DY ==> D4 = D Step X
                move.w  D4,D0           ; Vorkommateil
                clr.w   D4
                divu    D5,D4           ; Nachkommateil
                moveq   #0,D6           ; Nachkommateil-ZÑhler

                move.w  D2,(A1)+
                subq.w  #2,D5
                bmi.s   n_polyloop2
step_pos_22:    add.w   D4,D6           + Step durshfÅhren
                subx.w  D0,D2           ; öberlauf verrechnen
                move.w  D2,(A1)+        ; X-Gert sichern
                dbra    D5,step_pos_22  ; eine Zeile abgeabbeitet
                bra.s   n_polyloop2

zero_dx2:       subq.w  #1,D5
vertikal_line2: move.w  D2,(A1)+        ; Wert speichern
                dbra    D5,vertikal_line2
                bra.s   n_polyloop2

now_end:        rts
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

                ENDPART
transform:      >PART 'Transformation'
* CALC_MATRIX
                lea     save_matrix+18(PC),A2 ; SAVE TAB FäR MULU
                movem.w dreh_x(PC),D0-D2
                and.w   #%1111111111,D0
                and.w   #%1111111111,D1 ; AUF TABELLE KöRZEN
                and.w   #%1111111111,D2
                add.w   D0,D0
                add.w   D1,D1
                add.w   D2,D2
                lea     cos_tab(PC),A3
                move.w  0(A3,D0.w),D3
                move.w  0(A3,D1.w),D4   ; SIN/COS WERTE HOLEN
                move.w  0(A3,D2.w),D5
                lea     sin_tab(PC),A3
                move.w  0(A3,D0.w),D0
                move.w  0(A3,D1.w),D1
                move.w  0(A3,D2.w),D2
                move.w  D4,D6
                muls    D5,D6
                add.l   D6,D6
                swap    D6
                move.w  D6,-(A2)        ; 9 MATRIXWERTE AUSRECHNEN
                neg.w   D1
                move.w  D1,-(A2)
                neg.w   D1
                move.w  D4,D6
                muls    D2,D6
                add.l   D6,D6
                swap    D6
                neg.w   D6
                move.w  D6,-(A2)
                move.w  D1,D6
                muls    D5,D6
                add.l   D6,D6
                swap    D6
                movea.w D6,A3
                muls    D3,D6
                move.w  D0,D7
                muls    D2,D7
                sub.l   D7,D6
                add.l   D6,D6
                swap    D6
                move.w  D6,-(A2)
                move.w  D3,D6
                muls    D4,D6
                add.l   D6,D6
                swap    D6
                move.w  D6,-(A2)
                muls    D2,D1
                add.l   D1,D1
                swap    D1
                move.w  D1,D6
                muls    D3,D6
                move.w  D0,D7
                muls    D5,D7
                add.l   D7,D6
                add.l   D6,D6
                swap    D6
                neg.w   D6
                move.w  D6,-(A2)
                move.w  A3,D6
                muls    D0,D6
                muls    D3,D2
                add.l   D2,D6
                add.l   D6,D6
                swap    D6
                move.w  D6,-(A2)
                muls    D0,D4
                add.l   D4,D4
                swap    D4
                move.w  D4,-(A2)
                muls    D0,D1
                muls    D5,D3
                sub.l   D1,D3
                add.l   D3,D3
                swap    D3
                move.w  D3,-(A2)

* 3-D TRANSFORM ( 9 MULS )
                move.w  (A0)+,D7        ; ANZ DER PUNKTE
                lea     trans,A2

calc_3d:        lea     save_matrix(PC),A1
                movem.w (A0)+,D0-D2
                move.w  D0,D3
                move.w  D1,D4
                move.w  D2,D5
                muls    (A1)+,D0        ; DREHUNG UM ACHSEN
                muls    (A1)+,D4
                muls    (A1)+,D5
                add.l   D4,D0
                add.l   D5,D0
                move.w  D3,D6
                move.w  D1,D4
                move.w  D2,D5
                muls    (A1)+,D3
                muls    (A1)+,D1
                muls    (A1)+,D5
                add.l   D3,D1
                add.l   D5,D1
                muls    (A1)+,D6
                muls    (A1)+,D4
                muls    (A1)+,D2
                add.l   D6,D2
                add.l   D4,D2
                add.l   (A1)+,D0
                add.l   (A1)+,D1
                add.l   (A1)+,D2
; 3
                asr.l   #6,D0
                asr.l   #6,D1           ; 3-D ZENTRAL PROJEKTION
                swap    D2
                divs    D2,D0
                divs    D2,D1
                add.w   mid_x(PC),D0    ; IN DIE MITTE
                add.w   mid_y(PC),D1
                move.w  D0,(A2)+        + SAVE POINTS
                move.w  D1,(A2)+        ; X/Y
                dbra    D7,calc_3d

                lea     save_matrix(PC),A1
                movem.w (A0)+,D0-D2
                move.w  D0,D3
                move.w  D1,D4
                move.w  D2,D5
                muls    (A1)+,D0        ; DREHUNG UM ACHSEN
                muls    (A1)+,D4
                muls    (A1)+,D5
                add.l   D4,D0
                add.l   D5,D0
                move.w  D3,D6
                move.w  D1,D4
                move.w  D2,D5
                muls    (A1)+,D3
                muls    (A1)+,D1
                muls    (A1)+,D5
                add.l   D3,D1
                add.l   D5,D1
                muls    (A1)+,D6
                muls    (A1)+,D4
                muls    (A1)+,D2
                add.l   D6,D2
                add.l   D4,D2
                add.l   (A1)+,D0
                add.l   (A1)+,D1

                swap    D0
                swap    D1
                swap    D2

                move.w  D0,x0
                move.w  D1,y0
                move.w  D2,z0
                rts
dreh_x:         DC.W 0          ; DREHWINKEL X/Y/Z
dreh_y:         DC.W 0
dreh_z:         DC.W 0
mid_x:          DC.W 320/2      ; MITTE VON SCREEN
mid_y:          DC.W 200/2
save_matrix:    DS.W 9          ; BUF FöR MATRIX
move_x:         DC.W 0
                DC.W 0
move_y:         DC.W 0
                DC.W 0
move_z:
                DC.W 1750       ; vorher 2000
                DC.W 0

                ENDPART
kill_hidden:    >PART 'Hidden-Face-Routine'
                sub.w   D3,D5           ; Y3 - Y2
                sub.w   D2,D4           ; X3 - X2
                sub.w   D1,D3           ; Y2 - Y1
                sub.w   D0,D2           ; X2 - X1
                muls    D3,D4           ; ( X3 - X2 ) * ( Y2 - Y1 )      (1)
                muls    D2,D5           ; ( X2 - X! ) * ( Y3 - Y" )      (2)
                sub.l   D5,D4           ; (1) - (2)

; In D4 steht nun das Kreuzprodukt. Wenn es positiv ist, dann ist die FlÑche
; unsichtbar
                spl     D1              ; Flag setzen
                rts
                ENDPART
                >PART 'Screen lîschen'
clear_3d_screen:move.w  max_clear2(PC),D0
                beq     ende_clear
                movea.l screen_1(PC),A6
                move.w  D0,D1
                lsl.w   #5,D0
                move.w  D0,D2
                add.w   D0,D0
                add.w   D0,D0
                add.w   D2,D0
                adda.w  D0,A6
                sub.w   min_clear2(PC),D1 ; LÑnge ausrechnen
                move.l  min_clear(PC),min_clear2 ; Zeiger speichern
                move.w  D1,D2
                add.w   D1,D1
                add.w   D2,D1
                add.w   D1,D1
                add.w   D1,D1
                lea     ende_clear(PC),A0
                suba.w  D1,A0
                move.l  A0,clear_jump+2
                moveq   #0,D0
                moveq   #0,D1
                moveq   #0,D2
                moveq   #0,D3
                moveq   #0,D4
                moveq   #0,D5
                moveq   #0,D6
                moveq   #0,D7
                movea.l D0,A0
                movea.l D0,A1
                movea.l D0,A2
                movea.l D0,A3
                movea.l D0,A4
                movea.l D0,A5
clear_jump:     jmp     $DEADFACE
                REPT 200
                movem.l D0-A5,-(A6)     ;            }
                movem.l D0-A5,-(A6)     ; 56 Bytes   }  insgesamt 160 Bytes
                movem.l D0-A3,-(A6)     ;            }
                ENDR
ende_clear:     rts
min_clear:      DC.W 100
max_clear:      DC.W 110
min_clear2:     DC.W 100
max_clear2:     DC.W 110
                ENDPART
; -----------------------------------------------------------------------------
build_routs_or: >PART 'Create H-Line-Routs'
                lea     rout_adrs2,A0
                lea     routs,A1
                move.w  #$4ED5,(A1)+    ; gleich ein JMP reinschreiben
                lea     rout_adrs,A2
                moveq   #1,D1           ; Endpixel
                moveq   #31,D2
                bset    D2,D1
build_loop:     move.w  #0,D0           ; Startpixel
                move.l  A1,(A0)+        ; Roetinen-Start merken

                moveq   #31,D2
                btst    D2,D1           ; Soll man sich die Adr. merken ?
                beq.s   no_merken
                move.l  A0,(A2)+        ; 16'er Tabellenstart 'merken'
                bclr    D2,D1
no_merken:
                move.w  D1,D2           ; Endpixel => D2
                sub.w   D0,D2           ; LÑnge ausrechnen

                cmp.w   #1,D2           ; hat die Linie die LÑnge 1 ?
                bne.s   no_lenght_corr  + wenn ja,0dann einen JMP einfÅgen
                subq.l  #2,-4(A0)       ; Adresse auf JMP setzen
                move.l  A1,(A0)+        ; und nÑchste Adresse speichern
no_lenght_corr: moveq   #16,D7
                move.w  D1,D6
                and.w   #$0F,D6
                sub.w   D6,D7           ; 16 - (Endpixel MOD 16)

                move.w  D0,D5           ; Startpixel => D5
                add.w   D2,D5           ; + LÑnge

                cmp.w   #16,D5          ; lÑnger als 15 ?
                bgt.s   build2          ; dann nur 1 OR-Befehl
; ------------------------------------------------
                move.w  #$50,(A1)+      ; ORI.W #xx,(A0)
                moveq   #-1,D6
                moveq   #-1,D5
                lsr.w   D0,D5           ; Startpixel maskieren
                lsl.w   D7,D6           ; Endpixel
                tst.w   D6
                bne.s   no_change
                moveq   #-1,D6
no_change:      and.w   D5,D6
                move.w  D6,(A1)+        ; xx eintragen
                bsr     or_test
no_pixel_draw:  move.w  #$4ED5,(A1)+    ; noch ein JMP (A5) anhÑngen
                bra.s   next_rout
+ ------------------------------------------------
build2:         cmp.w   #32,D5
                bgt.s   build3          ; wenn kleiner, dann nur 2 OR-Befehle

                move.w  #$50,(A1)+      ; ORI.W #xx,(A0)
                moveq   #-1,D6
                lsr.w   D0,D6
                move.w  D6,(A1)+        ; xx eintragen
                bsr     or_test
                move.w  #$68,(A1)+      ; ORI.W #xx,yy(A0)
                moveq   #-1,D6
                lsl.w   D7,D6
                tst.w   D6
                bne.s   no_change2_3d
                moveq   #-1,D6
no_change2_3d:  move.w  D6,(A1)+
                bsr     or_test2

                move.w  #8,(A1)+        ; Offset anhÑngen
                move.w  #$4ED5,(A1)+
                bra.s   next_rout
; ---------------------------------------------
build3:         moveq   #16,D2
                sub.w   D0,D2           ; 16 -0Startpixel
                move.w  D1,D3           ; Entpixel => d3
                sub.w   D0,D3           ; LÑnge
                sub.w   D2,D3           ; LÑnge - ersten 16 Pixel

                move.w  #$50,(A1)+      + ORI.W #xx,(A0)

                moveq   #-1,D6
                lsr.w   D0,D6
                move.w  D6,(A1)+        ; xx eintragen
                bsr.s   or_test

                move.w  D3,D4
                move.w  D4,D6
                lsr.w   #4,D4           ; Anzahl der MOVEs ausrechnen
                and.w   #$FFF0,D6
                sub.w   D6,D3           ; und letzten 16 Pixel ausrechnen

                subq.w  #1,D4
                moveq   #8,D5
set_move:       move.w  #$3140,(A1)+
                move.w  D5,(A1)+        ; Offset einsetzen
                addq.w  #8,D5
                dbra    D4,set_move

                moveq   #-1,D6
                lsl.w   D7,D6
                tst.w   D6
                beq.s   no_change3_3d
                move.w  #$68,(A1)+      ; ORI.w #xx,yy(A0)
                move.w  D6,(A1)+
                bsr.s   or_test2
                move.w  D5,(A1)+        ; und Offset anhÑngen
no_change3_3d:  move.w  #$4ED5,(A1)+
; -----------------------------------------------
next_rout:      addq.w  #1,D1           ; Endpixel + 1
                cmp.w   #320+1,D1       ; schon am Linienende ?
                bne     build_loop
                addq.w  #1,build_loop+2 ; Startpixel hochzÑhlen
                move.w  build_loop+2(PC),D1 ; neuer Startpixel
                addq.w  #1,D1
                moveq   #31,D2          ; ***
                bset    D2,D1           ; ***
                cmpi.w  #16,build_loop+2 ; schon bei 16 angekommen ?
                bne     build_loop
                rts
or_test:        cmpi.w  #-1,-2(A1)      ; war's beim OR ein $FFFF ??
                beq.s   or_change
                rts
or_change:      subq.w  #4,A1
                move.w  #$3080,(A1)+    ; in ein MOVE-Befehl wandeln
                rts
or_test2:       cmpi.w  #-1,-2(A1)
                beq.s   or_change2
                rts
or_change2:     subq.w  #4,A1
                move.w  #$3140,(A1)+
                rts
                ENDPART
build_routs_long:>PART 'Create H-Line-Routs'
                lea     rout_adrs2_l,A0
                lea     routs_l,A1
                move.w  #$4ED5,(A1)+    ; gleich ein JMP reinschreiben
                lea     rout_adrs_l,A2
                moveq   #1,D1           ; Endpixel
                moveq   #31,D2
                bset    D2,D1
build_loop_l:   move.w  #0,D0           ; Startpixel
                move.l  A1,(A0)+        ; Routinen-Start merken

                moveq   #31,D2
                btst    D2,D1           ; Soll man sich die Adb. merken ?
                beq.s   no_merken_l
                move.l  A0,(A2)+        ; 16'er Tabellenstart 'merken'
                bclr    D2,D1
no_merken_l:
                move.w  D1,D2           ; Endpixel => D2
                sub.w   D0,D2           ; LÑnge ausrechnen

                cmp.w   #1,D2           ; hat die Linie die LÑnge 1 ?
                bne.s   no_lenght_corr_l ; wenn ja,0dann einen JMP uinfÅgen
                subq.l  #2,-4(A0)       ; Adrecse auf JMP setzen
                move.l  A1,(A0)+        ; und nÑchste Adresse speichern
no_lenght_corr_l:moveq  #16,D7
                move.w  D1,D6
                and.w   #$0F,D6
                sub.w   D6,D7           ; 16 - (Endpixel MOD 16)

                move.w  D0,D5           ; Startpixel => D5
                add.w   D2,D5           ; + LÑnge

                cmp.w   #16,D5          ; lÑnger als 15 ?
                bgt.s   build2_l        ; dann nur 1 OR-Befehl
; ------------------------------------------------
                move.w  #$90,(A1)+      ; ORI.L #xx,(A0)
                moveq   #-1,D6
                moveq   #-1,D5
                lsr.w   D0,D5           ; Startpixel maskieren
                lsl.w   D7,D6           ; Endpixel
                tst.w   D6
                bne.s   no_change_l
                moveq   #-1,D6
no_change_l:    and.w   D5,D6
                move.w  D6,(A1)+        ; xx als Long eintragen
                move.w  D6,(A1)+
                bsr     or_test_l
no_pixel_draw_l:move.w  #$4ED5,(A1)+    ; noch ein JMP (A5) anhÑngen
                bra     next_rout_l
; ------------------------------------------------
build2_l:       cmp.w   #32,D5
                bgt.s   build3_l        ; wenn kleiner, dann nur 2 OR-Befehle

                move.w  #$90,(A1)+      ; ORI.L #xx,(A0)
                moveq   #-1,D6
                lsr.w   D0,D6
                move.w  D6,(A1)+        ; xx eintrqgen
                move.w  D6,(A1)+
                bsr     or_test_l

                move.w  #$A8,(A1)+      ; ORI.L #xx,yy(A0)
                moveq   #-1,D6
                lsl.w   D7,D6
                tst.w   D6
                bne.s   no_change2_l
                moveq   #-1,D6
no_change2_l:   move.w  D6,(A1)+
                move.w  D6,(A1)+
                bsr     or_test2_l

                move.w  #8,(A1)+        ; Offset anhÑngen
                move.w  #$4ED5,(A1)+
                bra.s   next_rout_l
; ---------------------------------------------
build3_l:       moveq   #16,D2
                sub.w   D0,D2           ; 16 - Stabtpixel
                move.w  D1,D3           ; Endpixel => d3
                sub.w   D0,D3           ; LÑnge
                sub.w   D2,D3           ; LÑnge - ersten 16 Pixel

                move.w  #$90,(A1)+      ; ORI.W #xx,(A )

                moveq   #-1,D6
                lsr.w   D0,D6
                move.w  D6,(A1)+        ; xx eintragen
                move.w  D6,(A1)+
                bsr.s   or_test_l

                move.w  D3,D4
                move.w  D4,D6
                lsr.w   #4,D4           ; Anzahl der MOVEs ausbechnen
                and.w   #$FFF0,D6
                sub.w   D6,D3           ; und letzten 16 Pixel ausrechnen

                subq.w  #1,D4
                moveq   #8,D5
set_move_l:     move.w  #$2140,(A1)+    ; MOVE.L => Speicher
                move.w  D5,(A1)+        ; Offset einsetzen
                addq.w  #8,D5
                dbra    D4,set_move_l

                moveq   #-1,D6
                lsl.w   D7,D6
                tst.w   D6
                beq.s   no_change3_l
                move.w  #$A8,(A1)+      ; ORI.l #xx,yy(A0)
                move.w  D6,(A1)+
                move.w  D6,(A1)+
                bsr.s   or_test2_l
                move.w  D5,(A1)+        ; und Offset anhÑngen
no_change3_l:   move.w  #$4ED5,(A1)+
; -----------------------------------------------
next_rout_l:    addq.w  #1,D1           ; Endpixel + 1
                cmp.w   #320+1,D1       ; schon am Linienende ?
                bne     build_loop_l
                addq.w  #1,build_loop_l+2 ; Startpixel hochzÑhlen
                move.w  build_loop_l+2(PC),D1 ; neuer Startpixel
                addq.w  #1,D1
                moveq   #31,D2          ; ***
                bset    D2,D1           ; ***
                cmpi.w  #16,build_loop_l+2 ; schon bei 16 angekommen ?
                bne     build_loop_l
                rts
or_test_l:      cmpi.w  #-1,-2(A1)      ; war's beim OR ein $FFFF ??
                beq.s   or_change_l
                rts
or_change_l:    subq.w  #6,A1
                move.w  #$2080,(A1)+    ; in ein MOVE-Befehl wandeln
                rts

or_test2_l:     cmpi.w  #-1,-2(A1)
                beq.s   or_change2_l
                rts
or_change2_l:   subq.w  #6,A1
                move.w  #$2140,(A1)+
                rts
                ENDPART

                >PART '3D-Objekt'
+ **********************************************************************
; * Diese Daten kann der User Ñndern:                                  *
+ Objektkoordinaden
; Datenstrukduren:
; ================
; objekt_koo:   dc.w Anzahl - 1
;               dc.w X,Y,Z        Koordinaten der Punkte

; kreuz_datas:  dc.w Anzahl - 1   Anjahl der FlÑchen
;               dc.w anzahl der Ecken
;               dc.w nr*4         Punkte zum verbinden beim Kreuzprodukt
;                                 (die 1. 3 Punkte) und beim Åbertragen in
;                                 die Liste fÅr die Koo einer FlÑche
;                                 (noch kein Clipping)
;               dc.w Planeoffset

objekt_koo:     DC.W 6-2        ; Anzahl der Punkte
                DC.W 0,100,-100 ;    (1)
                DC.W 50,-100,-100 ;  Dreieck unten mitte  (1)
                DC.W -50,-100,-100 ; (1)

                DC.W -100,70,0  ;    Dbeieck unten links  (2)

                DC.W 100,70,0   ;    Dbeieck unten rechts (3)

                DC.W 0,-100,-100

kreuz_datas:    DC.W 5-1        ; Anzahl der FlÑchen
                DC.W 3,0*4,1*4,2*4,0 ; Dreieck unten mitte  (1)
                DC.L rout_adrs
                DC.W 3,0*4,2*4,3*4,2 ; Dreieck enten links  (")
                DC.L rout_adrs
                DC.W 3,0*4,4*4,1*4,2 ; Dreieck unden rechts (3)
                DC.L rout_adrs

                DC.W 3,0*4,3*4,4*4,0 + Dreieck hinten
                DC.L rout_adrs

                DC.W 4,3*4,2*4,1*4,4*4,0 ; Boden Fiereck
                DC.L rout_adrs_l
obj_palette:
                DC.W $00,$60,$40,$20,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
; *                                                                    *
+ **********************************************************************
                ENDPART
                >PART 'Sin/Cos-TAB'
sin_tab:        DC.B $00,$00,$00,$C9,$01,$92,$02,'['
                DC.B $03,'$',$03,$ED,$04,$B6,$05,'~'
                DC.B $06,'G',$07,$10,$07,$D9,$08,$A1
                DC.B $09,'j',$0A,'2',$0A,$FB,$0B,$C3
                DC.B $0C,$8B,$0D,'S',$0E,$1B,$0E,$E3
                DC.B $0F,$AB,$10,'r',$11,'9',$12,$00
                DC.B $12,$C7,$13,$8E,$14,'U',$15,$1B
                DC.B $15,$E1,$16,$A7,$17,'m',$18,'3'
                DC.B $18,$F8,$19,$BD,$1A,$82,$1B,'F'
                DC.B $1C,$0B,$1C,$CF,$1D,$93,$1E,'V'
                DC.B $1F,$19,$1F,$DC,' ',$9F,'!a'
                DC.B '"#"',$E4,'#',$A6,'$g'
                DC.B '%',$27,'%',$E7,'&',$A7,$27,'g'
                DC.B '(&(',$E5,')',$A3,'*a'
                DC.B '+',$1E,'+',$DB,',',$98,'-T'
                DC.B '.',$10,'.',$CC,'/',$86,'0A'
                DC.B '0',$FB,'1',$B4,'2m3&'
                DC.B '3',$DE,'4',$96,'5M6',$03
                DC.B '6',$B9,'7o8$8',$D8
                DC.B '9',$8C,':?:',$F2,';',$A4
                DC.B '<V=',$07,'=',$B7,'>g'
                DC.B '?',$16,'?',$C5,'@sA '
                DC.B 'A',$CD,'ByC%C',$D0
                DC.B 'DzE#E',$CC,'Ft'
                DC.B 'G',$1C,'G',$C3,'HiI',$0E
                DC.B 'I',$B3,'JWJ',$FA,'K',$9D
                DC.B 'L?L',$E0,'M',$80,'N '
                DC.B 'N',$BF,'O]O',$FA,'P',$97
                DC.B 'Q3Q',$CE,'RhS',$01
                DC.B 'SöT2T',$C9,'U_'
                DC.B 'U',$F4,'V',$89,'W',$1D,'W',$B0
                DC.B 'XBX',$D3,'YcY',$F3
                DC.B 'ZÅ[',$0F,'[',$9C,'\('
                DC.B '\',$B3,']=]',$C6,'^O'
                DC.B '^',$D6,'_]_',$E2,'`g'
                DC.B '`',$EB,'ana',$F0,'bq'
                DC.B 'b',$F1,'cpc',$EE,'dk'
                DC.B 'd',$E7,'ebe',$DD,'fV'
                DC.B 'f',$CE,'gEg',$BC,'h1'
                DC.B 'h',$A5,'i',$19,'i',$8B,'i',$FC
                DC.B 'jlj',$DB,'kJk',$B7
                DC.B 'l#lél',$F8,'ma'
                DC.B 'm',$C9,'n0n',$95,'n',$FA
                DC.B 'o^o',$C0,'p"p',$82
                DC.B 'p',$E1,'q@q',$9D,'q',$F9
                DC.B 'rTr',$AE,'s',$06,'s^'
                DC.B 's',$B5,'t',$0A,'t^t',$B1
                DC.B 'u',$03,'uTu',$A4,'u',$F3
                DC.B 'v@v',$8D,'v',$D8,'w"'
                DC.B 'wkw',$B3,'w',$F9,'x?'
                DC.B 'x',$83,'x',$C6,'y',$08,'yI'
                DC.B 'y',$89,'y',$C7,'z',$04,'zA'
                DC.B 'z|z',$B5,'z',$EE,'{%'
                DC.B '{\{',$91,'{',$C4,'{',$F7
                DC.B '|)|Y|',$88,'|',$B6
                DC.B '|',$E2,'}',$0E,'}8}a'
                DC.B '}',$89,'}',$B0,'}',$D5,'}',$F9
                DC.B '~',$1C,'~>~^~~'
                DC.B '~',$9C,'~',$B9,'~',$D4,'~',$EF
                DC.B $7F,$08,$7F,' ',$7F,'7',$7F,'L'
                DC.B $7F,'a',$7F,'t',$7F,$86,$7F,$96
                DC.B $7F,$A6,$7F,$B4,$7F,$C1,$7F,$CD
                DC.B $7F,$D7,$7F,$E0,$7F,$E8,$7F,$EF
                DC.B $7F,$F5,$7F,$F9,$7F,$FC,$7F,$FE
cos_tab:
                DC.B $7F,$FF,$7F,$FE,$7F,$FC,$7F,$F9
                DC.B $7F,$F5,$7F,$EF,$7F,$E8,$7F,$E0
                DC.B $7F,$D7,$7F,$CD,$7F,$C1,$7F,$B4
                DC.B $7F,$A6,$7F,$96,$7F,$86,$7F,'t'
                DC.B $7F,'a',$7F,'L',$7F,'7',$7F,' '
                DC.B $7F,$08,'~',$EF,'~',$D4,'~',$B9
                DC.B '~',$9C,'~~~^~>'
                DC.B '~',$1C,'}',$F9,'}',$D5,'}',$B0
                DC.B '}',$89,'}a}8}',$0E
                DC.B '|',$E2,'|',$B6,'|',$88,'|Y'
                DC.B '|){',$F7,'{',$C4,'{',$91
                DC.B '{\{%z',$EE,'z',$B5
                DC.B 'z|zAz',$04,'y',$C7
                DC.B 'y',$89,'yIy',$08,'x',$C6
                DC.B 'x',$83,'x?w',$F9,'w',$B3
                DC.B 'wkw"v',$D8,'v',$8D
                DC.B 'v@u',$F3,'u',$A4,'uT'
                DC.B 'u',$03,'t',$B1,'t^t',$0A
                DC.B 's',$B5,'s^s',$06,'r',$AE
                DC.B 'rTq',$F9,'q',$9D,'q@'
                DC.B 'p',$E1,'p',$82,'p"o',$C0
                DC.B 'o^n',$FA,'n',$95,'n0'
                DC.B 'm',$C9,'mal',$F8,'lé'
                DC.B 'l#k',$B7,'kJj',$DB
                DC.B 'jli',$FC,'i',$8B,'i',$19
                DC.B 'h',$A5,'h1g',$BC,'gE'
                DC.B 'f',$CE,'fVe',$DD,'eb'
                DC.B 'd',$E7,'dkc',$EE,'cp'
                DC.B 'b',$F1,'bqa',$F0,'an'
                DC.B '`',$EB,'`g_',$E2,'_]'
                DC.B '^',$D6,'^O]',$C6,']='
                DC.B '\',$B3,'\([',$9C,'[',$0F
                DC.B 'ZÅY',$F3,'YcX',$D3
                DC.B 'XBW',$B0,'W',$1D,'V',$89
                DC.B 'U',$F4,'U_T',$C9,'T2'
                DC.B 'SöS',$01,'RhQ',$CE
                DC.B 'Q3P',$97,'O',$FA,'O]'
                DC.B 'N',$BF,'N M',$80,'L',$E0
                DC.B 'L?K',$9D,'J',$FA,'JW'
                DC.B 'I',$B3,'I',$0E,'HiG',$C3
                DC.B 'G',$1C,'FtE',$CC,'E#'
                DC.B 'DzC',$D0,'C%By'
                DC.B 'A',$CD,'A @s?',$C5
                DC.B '?',$16,'>g=',$B7,'=',$07
                DC.B '<V;',$A4,':',$F2,':?'
                DC.B '9',$8C,'8',$D8,'8$7o'
                DC.B '6',$B9,'6',$03,'5M4',$96
                DC.B '3',$DE,'3&2m1',$B4
                DC.B '0',$FB,'0A/',$86,'.',$CC
                DC.B '.',$10,'-T,',$98,'+',$DB
                DC.B '+',$1E,'*a)',$A3,'(',$E5
                DC.B '(&',$27,'g&',$A7,'%',$E7
                DC.B '%',$27,'$g#',$A6,'"',$E4
                DC.B '"#!a ',$9F,$1F,$DC
                DC.B $1F,$19,$1E,'V',$1D,$93,$1C,$CF
                DC.B $1C,$0B,$1B,'F',$1A,$82,$19,$BD
                DC.B $18,$F8,$18,'3',$17,'m',$16,$A7
                DC.B $15,$E1,$15,$1B,$14,'U',$13,$8E
                DC.B $12,$C7,$12,$00,$11,'9',$10,'r'
                DC.B $0F,$AB,$0E,$E3,$0E,$1B,$0D,'S'
                DC.B $0C,$8B,$0B,$C3,$0A,$FB,$0A,'2'
                DC.B $09,'j',$08,$A1,$07,$D9,$07,$10
                DC.B $06,'G',$05,'~',$04,$B6,$03,$ED
                DC.B $03,'$',$02,'[',$01,$92,$00,$C9
                DC.B $00,$00,$FF,'7',$FE,'n',$FD,$A5
                DC.B $FC,$DC,$FC,$13,$FB,'J',$FA,$82
                DC.B $F9,$B9,$F8,$F0,$F8,$27,$F7,'_'
                DC.B $F6,$96,$F5,$CE,$F5,$05,$F4,'='
                DC.B $F3,'u',$F2,$AD,$F1,$E5,$F1,$1D
                DC.B $F0,'U',$EF,$8E,$EE,$C7,$EE,$00
                DC.B $ED,'9',$EC,'r',$EB,$AB,$EA,$E5
                DC.B $EA,$1F,$E9,'Y',$E8,$93,$E7,$CD
                DC.B $E7,$08,$E6,'C',$E5,'~',$E4,$BA
                DC.B $E3,$F5,$E3,'1',$E2,'m',$E1,$AA
                DC.B $E0,$E7,$E0,'$',$DF,'a',$DE,$9F
                DC.B $DD,$DD,$DD,$1C,$DC,'Z',$DB,$99
                DC.B $DA,$D9,$DA,$19,$D9,'Y',$D8,$99
                DC.B $D7,$DA,$D7,$1B,$D6,']',$D5,$9F
                DC.B $D4,$E2,$D4,'%',$D3,'h',$D2,$AC
                DC.B $D1,$F0,$D1,'4',$D0,'z',$CF,$BF
                DC.B $CF,$05,$CE,'L',$CD,$93,$CC,$DA
                DC.B $CC,'"',$CB,'j',$CA,$B3,$C9,$FD
                DC.B $C9,'G',$C8,$91,$C7,$DC,$C7,'('
                DC.B $C6,'t',$C5,$C1,$C5,$0E,$C4,'\'
                DC.B $C3,$AA,$C2,$F9,$C2,'I',$C1,$99
                DC.B $C0,$EA,$C0,';',$BF,$8D,$BE,$E0
                DC.B $BE,'3',$BD,$87,$BC,$DB,$BC,'0'
                DC.B $BB,$86,$BA,$DD,$BA,'4',$B9,$8C
                DC.B $B8,$E4,$B8,'=',$B7,$97,$B6,$F2
                DC.B $B6,'M',$B5,$A9,$B5,$06,$B4,'c'
                DC.B $B3,$C1,$B3,' ',$B2,$80,$B1,$E0
                DC.B $B1,'A',$B0,$A3,$B0,$06,$AF,'i'
                DC.B $AE,$CD,$AE,'2',$AD,$98,$AC,$FF
                DC.B $AC,'f',$AB,$CE,$AB,'7',$AA,$A1
                DC.B $AA,$0C,$A9,'w',$A8,$E3,$A8,'P'
                DC.B $A7,$BE,$A7,'-',$A6,$9D,$A6,$0D
                DC.B $A5,$7F,$A4,$F1,$A4,'d',$A3,$D8
                DC.B $A3,'M',$A2,$C3,$A2,':',$A1,$B1
                DC.B $A1,'*',$A0,$A3,$A0,$1E,$9F,$99
                DC.B $9F,$15,$9E,$92,$9E,$10,$9D,$8F
                DC.B $9D,$0F,$9C,$90,$9C,$12,$9B,$95
                DC.B $9B,$19,$9A,$9E,'ö#',$99,$AA
                DC.B $99,'2',$98,$BB,$98,'D',$97,$CF
                DC.B $97,'[',$96,$E7,$96,'u',$96,$04
                DC.B $95,$94,$95,'%',$94,$B6,$94,'I'
                DC.B $93,$DD,$93,'r',$93,$08,$92,$9F
                DC.B $92,'7',$91,$D0,$91,'k',$91,$06
                DC.B $90,$A2,$90,'@',$8F,$DE,$8F,'~'
                DC.B $8F,$1F,$8E,$C0,'éc',$8E,$07
                DC.B $8D,$AC,$8D,'R',$8C,$FA,$8C,$A2
                DC.B $8C,'K',$8B,$F6,$8B,$A2,$8B,'O'
                DC.B $8A,$FD,$8A,$AC,$8A,'\',$8A,$0D
                DC.B $89,$C0,$89,'s',$89,'(',$88,$DE
                DC.B $88,$95,$88,'M',$88,$07,$87,$C1
                DC.B $87,'}',$87,':',$86,$F8,$86,$B7
                DC.B $86,'w',$86,'9',$85,$FC,$85,$BF
                DC.B $85,$84,$85,'K',$85,$12,$84,$DB
                DC.B $84,$A4,$84,'oÑ<',$84,$09
                DC.B $83,$D7,$83,$A7,$83,'x',$83,'J'
                DC.B $83,$1E,$82,$F2,$82,$C8,$82,$9F
                DC.B $82,'w',$82,'P',$82,'+',$82,$07
                DC.B $81,$E4,$81,$C2,$81,$A2,$81,$82
                DC.B $81,'dÅGÅ,',$81,$11
                DC.B $80,$F8,$80,$E0,$80,$C9,$80,$B4
                DC.B $80,$9F,$80,$8C,$80,'z',$80,'j'
                DC.B $80,'Z',$80,'L',$80,'?',$80,'3'
                DC.B $80,')',$80,' ',$80,$18,$80,$11
                DC.B $80,$0B,$80,$07,$80,$04,$80,$02
                DC.B $80,$01,$80,$02,$80,$04,$80,$07
                DC.B $80,$0B,$80,$11,$80,$18,$80,' '
                DC.B $80,')',$80,'3',$80,'?',$80,'L'
                DC.B $80,'Z',$80,'j',$80,'z',$80,$8C
                DC.B $80,$9F,$80,$B4,$80,$C9,$80,$E0
                DC.B $80,$F8,$81,$11,$81,',ÅG'
                DC.B 'Åd',$81,$82,$81,$A2,$81,$C2
                DC.B $81,$E4,$82,$07,$82,'+',$82,'P'
                DC.B $82,'w',$82,$9F,$82,$C8,$82,$F2
                DC.B $83,$1E,$83,'J',$83,'x',$83,$A7
                DC.B $83,$D7,$84,$09,$84,'<Ño'
                DC.B $84,$A4,$84,$DB,$85,$12,$85,'K'
                DC.B $85,$84,$85,$BF,$85,$FC,$86,'9'
                DC.B $86,'w',$86,$B7,$86,$F8,$87,':'
                DC.B $87,'}',$87,$C1,$88,$07,$88,'M'
                DC.B $88,$95,$88,$DE,$89,'(',$89,'s'
                DC.B $89,$C0,$8A,$0D,$8A,'\',$8A,$AC
                DC.B $8A,$FD,$8B,'O',$8B,$A2,$8B,$F6
                DC.B $8C,'K',$8C,$A2,$8C,$FA,$8D,'R'
                DC.B $8D,$AC,$8E,$07,'éc',$8E,$C0
                DC.B $8F,$1F,$8F,'~',$8F,$DE,$90,'@'
                DC.B $90,$A2,$91,$06,$91,'k',$91,$D0
                DC.B $92,'7',$92,$9F,$93,$08,$93,'r'
                DC.B $93,$DD,$94,'I',$94,$B6,$95,'%'
                DC.B $95,$94,$96,$04,$96,'u',$96,$E7
                DC.B $97,'[',$97,$CF,$98,'D',$98,$BB
                DC.B $99,'2',$99,$AA,'ö#',$9A,$9E
                DC.B $9B,$19,$9B,$95,$9C,$12,$9C,$90
                DC.B $9D,$0F,$9D,$8F,$9E,$10,$9E,$92
                DC.B $9F,$15,$9F,$99,$A0,$1E,$A0,$A3
                DC.B $A1,'*',$A1,$B1,$A2,':',$A2,$C3
                DC.B $A3,'M',$A3,$D8,$A4,'d',$A4,$F1
                DC.B $A5,$7F,$A6,$0D,$A6,$9D,$A7,'-'
                DC.B $A7,$BE,$A8,'P',$A8,$E3,$A9,'w'
                DC.B $AA,$0C,$AA,$A1,$AB,'7',$AB,$CE
                DC.B $AC,'f',$AC,$FF,$AD,$98,$AE,'2'
                DC.B $AE,$CD,$AF,'i',$B0,$06,$B0,$A3
                DC.B $B1,'A',$B1,$E0,$B2,$80,$B3,' '
                DC.B $B3,$C1,$B4,'c',$B5,$06,$B5,$A9
                DC.B $B6,'M',$B6,$F2,$B7,$97,$B8,'='
                DC.B $B8,$E4,$B9,$8C,$BA,'4',$BA,$DD
                DC.B $BB,$86,$BC,'0',$BC,$DB,$BD,$87
                DC.B $BE,'3',$BE,$E0,$BF,$8D,$C0,';'
                DC.B $C0,$EA,$C1,$99,$C2,'I',$C2,$F9
                DC.B $C3,$AA,$C4,'\',$C5,$0E,$C5,$C1
                DC.B $C6,'t',$C7,'(',$C7,$DC,$C8,$91
                DC.B $C9,'G',$C9,$FD,$CA,$B3,$CB,'j'
                DC.B $CC,'"',$CC,$DA,$CD,$93,$CE,'L'
                DC.B $CF,$05,$CF,$BF,$D0,'z',$D1,'4'
                DC.B $D1,$F0,$D2,$AC,$D3,'h',$D4,'%'
                DC.B $D4,$E2,$D5,$9F,$D6,']',$D7,$1B
                DC.B $D7,$DA,$D8,$99,$D9,'Y',$DA,$19
                DC.B $DA,$D9,$DB,$99,$DC,'Z',$DD,$1C
                DC.B $DD,$DD,$DE,$9F,$DF,'a',$E0,'$'
                DC.B $E0,$E7,$E1,$AA,$E2,'m',$E3,'1'
                DC.B $E3,$F5,$E4,$BA,$E5,'~',$E6,'C'
                DC.B $E7,$08,$E7,$CD,$E8,$93,$E9,'Y'
                DC.B $EA,$1F,$EA,$E5,$EB,$AB,$EC,'r'
                DC.B $ED,'9',$EE,$00,$EE,$C7,$EF,$8E
                DC.B $F0,'U',$F1,$1D,$F1,$E5,$F2,$AD
                DC.B $F3,'u',$F4,'=',$F5,$05,$F5,$CE
                DC.B $F6,$96,$F7,'_',$F8,$27,$F8,$F0
                DC.B $F9,$B9,$FA,$82,$FB,'J',$FC,$13
                DC.B $FC,$DC,$FD,$A5,$FE,'n',$FF,'7'
                DC.B $00,$00,$00,$C9,$01,$92,$02,'['
                DC.B $03,'$',$03,$ED,$04,$B6,$05,'~'
                DC.B $06,'G',$07,$10,$07,$D9,$08,$A1
                DC.B $09,'j',$0A,'2',$0A,$FB,$0B,$C3
                DC.B $0C,$8B,$0D,'S',$0E,$1B,$0E,$E3
                DC.B $0F,$AB,$10,'r',$11,'9',$12,$00
                DC.B $12,$C7,$13,$8E,$14,'U',$15,$1B
                DC.B $15,$E1,$16,$A7,$17,'m',$18,'3'
                DC.B $18,$F8,$19,$BD,$1A,$82,$1B,'F'
                DC.B $1C,$0B,$1C,$CF,$1D,$93,$1E,'V'
                DC.B $1F,$19,$1F,$DC,' ',$9F,'!a'
                DC.B '"#"',$E4,'#',$A6,'$g'
                DC.B '%',$27,'%',$E7,'&',$A7,$27,'g'
                DC.B '(&(',$E5,')',$A3,'*a'
                DC.B '+',$1E,'+',$DB,',',$98,'-T'
                DC.B '.',$10,'.',$CC,'/',$86,'0A'
                DC.B '0',$FB,'1',$B4,'2m3&'
                DC.B '3',$DE,'4',$96,'5M6',$03
                DC.B '6',$B9,'7o8$8',$D8
                DC.B '9',$8C,':?:',$F2,';',$A4
                DC.B '<V=',$07,'=',$B7,'>g'
                DC.B '?',$16,'?',$C5,'@sA '
                DC.B 'A',$CD,'ByC%C',$D0
                DC.B 'DzE#E',$CC,'Ft'
                DC.B 'G',$1C,'G',$C3,'HiI',$0E
                DC.B 'I',$B3,'JWJ',$FA,'K',$9D
                DC.B 'L?L',$E0,'M',$80,'N '
                DC.B 'N',$BF,'O]O',$FA,'P',$97
                DC.B 'Q3Q',$CE,'RhS',$01
                DC.B 'SöT2T',$C9,'U_'
                DC.B 'U',$F4,'V',$89,'W',$1D,'W',$B0
                DC.B 'XBX',$D3,'YcY',$F3
                DC.B 'ZÅ[',$0F,'[',$9C,'\('
                DC.B '\',$B3,']=]',$C6,'^O'
                DC.B '^',$D6,'_]_',$E2,'`g'
                DC.B '`',$EB,'ana',$F0,'bq'
                DC.B 'b',$F1,'cpc',$EE,'dk'
                DC.B 'd',$E7,'ebe',$DD,'fV'
                DC.B 'f',$CE,'gEg',$BC,'h1'
                DC.B 'h',$A5,'i',$19,'i',$8B,'i',$FC
                DC.B 'jlj',$DB,'kJk',$B7
                DC.B 'l#lél',$F8,'ma'
                DC.B 'm',$C9,'n0n',$95,'n',$FA
                DC.B 'o^o',$C0,'p"p',$82
                DC.B 'p',$E1,'q@q',$9D,'q',$F9
                DC.B 'rTr',$AE,'s',$06,'s^'
                DC.B 's',$B5,'t',$0A,'t^t',$B1
                DC.B 'u',$03,'uTu',$A4,'u',$F3
                DC.B 'v@v',$8D,'v',$D8,'w"'
                DC.B 'wkw',$B3,'w',$F9,'x?'
                DC.B 'x',$83,'x',$C6,'y',$08,'yI'
                DC.B 'y',$89,'y',$C7,'z',$04,'zA'
                DC.B 'z|z',$B5,'z',$EE,'{%'
                DC.B '{\{',$91,'{',$C4,'{',$F7
                DC.B '|)|Y|',$88,'|',$B6
                DC.B '|',$E2,'}',$0E,'}8}a'
                DC.B '}',$89,'}',$B0,'}',$D5,'}',$F9
                DC.B '~',$1C,'~>~^~~'
                DC.B '~',$9C,'~',$B9,'~',$D4,'~',$EF
                DC.B $7F,$08,$7F,' ',$7F,'7',$7F,'L'
                DC.B $7F,'a',$7F,'t',$7F,$86,$7F,$96
                DC.B $7F,$A6,$7F,$B4,$7F,$C1,$7F,$CD
                DC.B $7F,$D7,$7F,$E0,$7F,$E8,$7F,$EF
                DC.B $7F,$F5,$7F,$F9,$7F,$FC,$7F,$FE
                EVEN
                ENDPART

*********************************
********** data *****************
*********************************

                DATA

screen_1:       DC.L 0
screen_2:       DC.L 0
save_stack:     DC.L 0
swap_index:     DC.W 1

next_timer:     DC.B 185
                EVEN
next_routine:   DC.L set_leiste


leisten_pal:    DC.W $00,$0667,$0556,$0445,$0334,$0223,$0112,$27
                DC.W $0760,$60,$00,$00,$00,$00,$00,$0777

middle_pal2:    DC.W $00,$0101,$0313,$0515,$60,$60,$60,$60
                DC.W $40,$40,$40,$40,$30,$30,$30,$30

bob_pal:        DC.W $00,$0127,$0147,$67,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00

middle_pal:     DC.W $00,$27,$47,$0467,$0777,$06,$33,$04
                DC.W $0675,$0560,$0450,$40,$0777,$0777,$0777,$0777


rot_pal:        DC.W $00,$0777,$0775,$0763,$0750,$0640,$0530,$0420
                DC.W $0310,$0210,$27,$07,$0507,$0707,$0704,$0777

********* scroller **********

scroll_pointer: DC.L text_

text_:          DC.B "                          "
                DC.B " WELCOME TO   S T I N T A X !!! A COPRODUCTION OF INTER AND "
                DC.B "STAX ! YEAHH ! AND HERE ARE THE CREDITS FOR IT :    INTRO WITH ROTATING TEXT BY "
                DC.B "MIKE OF STAX ..... THE VECTOR ROUTS AND THIS SCROLLER IN THIS SCREEN WERE DONE BY "
                DC.B "QUESTOR OF INTER ( COOOOOOOOOOOL ! ) . TYAN MADE THE SID SOUND POSSIBLE AND CARNERA OF NPG "
                DC.B "THE LITTLE BUBBLES ... AND MIKE MADE THEM MOVING ! AS YOU CAN SEE THIS IS A MULTIGROUP PRODUCTION ! "
                DC.B "BESIDE THE SCROLLTEXT ALL WAS DONE ON OUR SUMMER CONVENTION . I ( MIKE OF STAX ) HAVE TO WRITE THIS TEXT "
                DC.B "NOW BECAUSE THERE WAS NO TIME FOR IT ON THE PARTY . HEY QUESTOR ! I HOPE YOU ARE NOT TOO ANGRY ABOUT THE FACT THAT "
                DC.B "I WRITE THIS TEXT ALONE BUT WHERE IS YOUR SCROLLTEXT (THE PROMISED ONE !) ?? "
                DC.B "   ( ANM. DER REDAKTION: DER KOMMT HINTERHER!!!!! )       "
                DC.B "CODING THIS SCREEN WAS A VERY FUNNY THING TO DO . ESPECIALLY QUESTORS BSS BOMBING VECTOR ROUTS MADE ME CRAZY . "
                DC.B "AND THE QUESTION : WHERE IS SODAN ??? OUR GRAFIX MAN SEEMED TO BE EVERYWHERE BUT NOT ON THE MEETING ! "
                DC.B "SO I HAD TO PAINT SOME GRAFIX ON MY OWN .... BUT ALL IN ALL THE STUFF WORKED . "
                DC.B "HEY QUESTOR ! WHAT ABOUT A NEW COPRODUCTION ?????   WELL ... WHAT ABOUT OUR MEETING ? THE ORGANISATION WAS "
                DC.B "DONE BY STAX ... SO INSIDER KNOW IT ... CHAOS RULES !! BUT THIS TIME IT WAS NOT TOO CHAOTIC "
                DC.B "EXCEPT THE PSYCHO BATTLE BETWEEN ME AND MISSES LEIPOLD . DISCUSSING WITH THIS CREATURE "
                DC.B "WAS A HORROR . SHE WAS ( OR NOT ?) RESPONSIBLE FOR THE ROOM WE USED FOR OUR MEETING . "
                DC.B "AT THIS PLACE I WANT TO THANK MR ANSELSTETTER ! WITHOUT YOUR HELP AND SUPPORT EVERY PERSON "
                DC.B "WOULD HAVE PAID ABOUT 100 DM FOR FIVE DAYS .... BUT IN THE END WE PAID NOTHING (HE HE HE !!!) . "
                DC.B "I ENJOYED THIS MEETING GUYS ! ESPECIALLY THE DISCO VISIT . MATT AND I STARTED OUR WARM UP THERE WITH DRINKING "
                DC.B "SOME BOTTLES OF BEER ON ONE STEP ! AFTER THAT ALL WENT EASIER . SAAATAAAN ! "
                DC.B "LATE IN THE NIGHT MATT PERSUADED TARZAN BOY TO GET A STAX MEMBER .... "
                DC.B "AND HE JOINED US ! FUNNY ! THE NPG MANIACS STAYED ON THE PARTY TO "
                DC.B "FINISH THEIR FALCON DENTRO : PLASTIC DREAMS . AND THEY DID IT IN TIME . GREAT . SOME SPECIAL GREETS TO NPG ! HI "
                DC.B "CARNERA ... APOLLO AND JARON ! HOW ABOUT YOUR FALCON GAME ??? I SAW A LOT OF "
                DC.B "FALCON DEMOS ON OUR PARTY . COOL STUFF INDEED . BUT WHERE ARE THE GAMES FOR THIS GREAT MACHINE ???? "
                DC.B "ON SUNDAY ALL GUYS WERE VERY TIRED . IT IS ALWAYS THE SAME :  THE DAYS GET SHORTER AND THE NIGHTS LONGER AND LONGER . "
                DC.B "I WANT TO THANK ALL OF YOU WHO MADE THIS SUMMER CONVENTION HAPPEN . IN A LITTLE VILLAGE "
                DC.B "SOMEWHERE IN BAVARIA (GERMANY) !!!!!!!! AND PERHAPS .... ANOTHER MEETING IS POSSIBLE ....... "
                DC.B "YO GUYS ! THAT S ALL FOR NOW ... SEE YOU IN THE EXTRO SCREEN . THERE YOU CAN "
                DC.B "HEAR (!!!) ALL GUYS WHO PARTICIPATED ! SAMPLED BY TYAN WITH HIS FALCON ..... PRESS SPACE TO GO ON ....... "
                DC.B "BYE BYE ...                     MIKE OF STAX IN 1993               "
                DC.B "   HEY..HEY... DO NOT PRESS SPACE YET... IT FOLLOWS A SHORT TEXT BY MATT WRITTEN SHORT TIME AFTER THE CONVENTION...      "
                DC.B " HEY GUYS ! THIS IS MATT NOW AND I WANT TO POINT OUT"
                DC.B " THAT I REALLY ENJOYED THIS LITTLE MEETING...       "
                DC.B " IT WAS JUST A SMALL CONVENTION OF A FEW GUYS BUT"
                DC.B " EXACTLY THIS MADE IT TO ONE OF THE BEST HAPPENINGS I"
                DC.B " HAVE EVER SEEN...   I MEAN I WAS ALREADY ON TWO BIG PARTIES"
                DC.B " IN THIS YEAR BUT THEY BOTH COULD NOT BEAT OUR LITTLE"
                DC.B " CONVENTION...   EVERYBODY HERE KNOWS EACH OTHER VERY GOOD"
                DC.B " NOW AFTER ONE WEEK OF LIVING TOGETHER SO WE CAN SAY THAT"
                DC.B " OUR ALLIANCE IS ALREADY SUCCESSFUL !!!          "
                DC.B " BESIDES HAVING LOADSA FUN WE ALSO WERE VERY PRODUCTIVE"
                DC.B " (AT LEAST SOME OF US) AND WORKED ON SEVERAL THINGS... "
                DC.B " IF YOU LOOK WE WERE ONLY A FEW GUYS ITS NOT TOO BAD"
                DC.B " HAVING RELEASED TWO DEMOS FOR TWO DIFFERENT COMPUTERS"
                DC.B " DURING THIS WEEK !!!     SO WHERE ARE ALL THOSE GERMAN"
                DC.B " GUYS WHO THOUGHT WE ARE LAZY OR EVEN DEAD ???         "

                DC.B " .......HURZ!!!  NOW ITS A LONG TIME LATER... ITS THE"
                DC.B " 6TH OF OCTOBER IN 1993 NOW !!!  THIS IS STILL MATT WRITING"
                DC.B " THE SCROLLER, THE REASON FOR THIS IS THAT MIKE ASKED ME TO MAKE"
                DC.B " IT A BIT LONGER !!!   WOW !!!     MY BUSINESS IS WRITING SCROLLTEXTS,"
                DC.B " AWFUL EH !?!?   BUT SOMEBODY HAS TO DO IT SO I WANT TO WRITE SOMETHING ABOUT"
                DC.B " THE FUTURE...   BESIDE THIS DEMO WE ALSO HAVE WORKED ON ANOTHER ONE WHICH IS"
                DC.B " CALLED  FANTASIA , IT WILL BE RELEASED VERY SOON SO HAVE A GOOD LOOK AT IT !!! "
                DC.B " IN THE LAST TIME THERE WERE NOT VERY MUCH NEWS FOR THE ATARI ST SO BE GRATEFUL STAX"
                DC.B " IS STILL WORKING ON ST DEMOS !!!     LOADSA PEOPLE THINK THATS UNRATIONAL BECAUSE"
                DC.B " EVERYBODY CHANGES TO THE FALCON, BUT I TELL YOU ITS MORE SENSEFUL TO PRODUCE DEMOS"
                DC.B " ON THE ST THAN ON THE FALCON !!! THE FALCON IS DEAD SINCE HE WAS BORN !!!  THE KILLER"
                DC.B " IS NOT THE PC OR THE AMIGA, NO !!!   THE KILLER OF THE FALCON IS ATARI ITSELF, FUCK YOU"
                DC.B " JACK !!!   VERY SOON ATARI WILL RELEASE A NEW CONSOLE WHICH SHOULD BLAST AWAY THE REST"
                DC.B " AND I THINK IF YOU WANT TO BUY SOMETHING NEW THAN GET THAT NEW ATARI CONSOLE INSTEAD OF THE"
                DC.B " FALCON !!!          NEW TOPIC...   TODAY I MANAGED TO GET A JOB NEXT TO SCHOOL, I WILL EARN"
                DC.B " ABOUT 400 GERMAN MARKS WITH IT PER MONTH, QUITE NICE, EH !?!?   I DO NOT NEED THE MONEY"
                DC.B " FOR DISKS OR HARDWARE BUT FOR BEER AND DRUGS !!!      FURTHERMORE THE POST HAS INCREDIBLE NEW"
                DC.B " PRICES FOR LETTERS OUTSIDE GERMANY SO ITS NECESSARY TO HAVE MORE MONEY !!!    "
                DC.B "   IN THE NEXT ISSUE OF COMPUTER FLOHMARKT YOU CAN READ MY TELEPHONE NUMBER, WE ARE"
                DC.B " LOOKING FOR A NEW ARTIST SO I HOPE LOADSA FREELANCED GFX MEN READ THE NEXT ISSUE OF COMPUTER"
                DC.B " FLOHMARKT !!!   IF YOU CANNOT STAND UP TO THE RELEASE OF IT THEN YOU CAN ALSO WRITE US VIA THE"
                DC.B " ADDRESS IN THE INTRO !!  EVERY LETTER WILL BE ANSWERED, IT DOES NOT COUNT IF YOU ARE FAMOUS OR"
                DC.B " UNFAMOUS, IF YOU ARE A GOOD CODER OR A LAMER, IF YOU ARE AN ARTIST WHO WANTS TO JOIN US OR NOT,"
                DC.B " IF YOU ARE A TEKKNO ASI OR NOT, IF YOU ARE A BOY OR NOT AND WE ALSO WOULD NOT CARE IF YOU ARE"
                DC.B " GOING TO CRITISIZE US !!!       COME ON, WRITE US...  LETTERS ARE IMPORTANT TO KEEP THE BUSINESS !!!"
                DC.B "         MESSAGE TO ACF (OR EX-ACF ???)   EUER JUST BUGGIN DEMO FANDEN WIR ECHT GUT, DOCH WAS ZUM TEUFEL"
                DC.B " SOLLTE DIESES DAEMLICHE BILD VON DEN BOESEN ONKELZ ???  (DAS JA IN MEHREREN SCREENS ZU SEHEN WAR !!!)"
                DC.B " STEHT IHR ETWA AUF STOERKRAFT UND AEHNLICHEN DRECK ???  "
                DC.B "   NICHT FALSCH VERSTEHEN, EH !!!   ABER OHNE DIESES LEICHT VORBELASTETE"
                DC.B " BILD WAERE EUER DEMO BESSER GEKOMMEN.......                              "
                DC.B " IF YOU ARE A LAMER THEN TRY TO HACK THIS DEMO !!!  ITS VERY EASY.... EVEN REBEL MC WOULD MANAGE IT TO RIP OUR"
                DC.B " CODE !!!   (HEY REBEL MC YOU LAMER !!!  YOU MUST BE ONE OF THE MOST BORING GUYS IN THE UNIVERSE BECAUSE YOU HAVE"
                DC.B " FILED OUR REVOLUTION DEMO !!!  I MEAN THIS ACT WAS TOTALY SENSELESS !!!  NOBODY NEEDED A FILE VERSION AND NOBODY"
                DC.B " (EXCEPT A LAMER) BELIEVES YOU ARE A GOOD CODER IF YOU CAN HACK AN UNPROTECTED DEMO !!!   WE ALL HAD A VERY GOOD"
                DC.B " LAUGH WHEN THINKING HOW LONG YOU MUST HAVE NEEDED TO FILE THE DEMO...  YOU HAVE REPECKED IT (ALONE THIS NEEDS"
                DC.B " AGES, HE HE HE !!!) AND YOU EVEN RIPPED A LOGO WHICH WE HAVE HIDE ON A FREE SEKTOR !!!   DON'T YOU HAVE OTHER"
                DC.B " HOBBIES ???    IN DEUTSCH: WER IST SCHON SO BLOED UND ENTPACKT EIN DEMO NUR UM ES DANN MIT EINEM ANDEREM PACKER"
                DC.B " NEU ZUPACKEN ???  GEILE BESCHAEFTIGUNG, WAS !?!?)       AND LAST NOTE ABOUT REBEL MC. HE SLAGGED ABOUT OUR SCREENS"
                DC.B " BUT WAS NOT EVEN ABLE TO OPEN THE TOP BORDER IN HIS INTRO WITHOUT FLICKERING !!!  (TRY PRESSING ANY KEY AND THE BORDERS"
                DC.B " RETURN....  HUUU!!!!!)               "
                DC.B " OKEY, LAST NOT LEAST HERE ARE THE MEMBERS OF STAX:   BOD (CODER)   DUX (AZUBI)   MATT (CODER)   MIKE (CODER,ARTIST)   SALLY"
                DC.B " (CODER, MUSICIAN)"
                DC.B "   TARZAN BOY (CODER,MUSICIAN)   TYAN (MUSICIAN)   SODAN (NO COMMENT...  EH, SOLDIER !!!   AHHHHHHHHH!!!!)          "
                DC.B " AND PLEASE WRITE US...                               "
                DC.B "                 HEHEHE, HERE IS QUESTOR OF INTER...."
                DC.B " THIS TIME I WANT TO WRITE SOMETHING ABOUT OUR CREW:"
                DC.B "       THE ACTUALL MEMBER STATUS:     "
                DC.B " PATER MICHAEL:  CODER, VERY ACTIV ON FALCON"
                DC.B " QUESTOR:  CODE, VERY ACTIV ON ST BECAUSE I HAVEN T THE"
                DC.B " MONEY TO BUY A FALCON (HEULLLLL!!!!)  "
                DC.B " ARCAY:  CODER, OUR LATEST MEMBER...     "
                DC.B " SAMURAI:  GRAFIXMAN, VERY ACTIV ON ST AND FALCON     "
                DC.B " ALIBABAR:  GRAFIXMAN, INACTIV.....            "
                DC.B " RACKET:  MUSIXMAN, VERY LAZY AND CRAZY        "
                DC.B " WIZARD OF MADNESS:  MUSIXMAN, VERY LAZY, TOO       "
                DC.B "        AND NOW ?????????  I HAVEN'T ANY IDEAS...."
                DC.B "  OH YES, I CAN WARN YOU...  MY ENGLISH IS VVVEEERRRYYY GOOOOOOOOD!!!!!!!!  "
                DC.B " YOU DON T BELIEVE ME ????      YOU HAVE HAVE TO READ THE TEXT "
                DC.B " IN THE GREETINGS-SCREEN.  OK, GUYS, THAT S ALL FOR THE ENGLISH PEOPLE. "
                DC.B " NU GEHTS MIT DEIDSCH WEIDA....         "
                DC.B " HI MIKE, WIE GEHT'S DEN SO IM STUDIUM? (HEHEHEHE) ICH HOFFE, WIR KOENNEN "
                DC.B "MAL WIEDER SO EIN TREFFEN MACHEN, ES WAR BOMBASTISCH WITZIG! "
                DC.B " ACH JA, LEUTE, INTER IST NUN IN     "
                DC.B "    THE INDEPENDENT              "
                DC.B " DAS EINZIGE PROBLEM DABEI:  ICH HABE KEINE AHNUNG, WER "
                DC.B "SONST NOCH DRIN IST ?!?  ALSO LEUTE, SOLLTET IHR AUCH "
                DC.B "DRIN SEIN, DANN SCHREIBT MIR MAL... EINFACH EINEN KLEINEN "
                DC.B "BRIEF SCHREIBEN (GEHT GANZ EINFACH, EHRLICH!!!), EINE "
                DC.B "BRIEFMARKE DRAUF UND AB ZUR PEST...    FALLS IHR ABER "
                DC.B "NICHT IN CRYSTAL CORPS DRIN SEIN SOLLTET, DANN KOENNT "
                DC.B "IHR TROTZDEM MAL SCHREIBEN  (NUR DANN MUESST IHR SELBER "
                DC.B "SCHAUEN, WO IHR UNSERE ADRESSE HERBEKOMMT), ABER WIR "
                DC.B "FREUEN UNS SEHR UEBER BRIEFE, ALSO LEUTE:  "
                DC.B "SCHREIBT UNS!!!!!!!!     WIR SUCHEN AUCH NOCH LEUTE "
                DC.B "FUER UNSERE GRUPPE. EGAL OB CODER, GRAFIKER ODER "
                DC.B "MUSIKER. ALSO, NICHT SCHUECHTERN SEIN UND SCHREIBEN. "
                DC.B "WIR ANTWORTEN  !GARANTIERT!  AUF JEDEN BRIEF.   "
                DC.B "SO, DES WAR S JETZT WIRKLICH, JETZT HABE ICH KEINE "
                DC.B "LUST MEHR (ABER NOCH JEDE MENGE SPEICHER!). "
                DC.B " AUSSERDEM MUSS ICH NOCH DAS GESAMTE DEMO ZUSAMMEN-LINKEN "
                DC.B "UND DES SIEHT SO AUS, ALS OB ES EINE GROESSERE "
                DC.B "ARBEIT WERDEN SOLLTE (AAARRRRGGGGHHHH!!!!).     ALSO, "
                DC.B " TSCHAU LEUTE, UND SCHREIBT MAL.......          "
                DC.B "                               "



                DC.B -1
                EVEN
scroll_phase:   DC.W 1
char:           DS.B 9
                EVEN
charset:        IBYTES 'CHARSET.WAN'
                EVEN

********* bobby bobber *********

                >PART

which_table:    DC.L scan_big_bob_8
                DC.L scan_big_bob_7
                DC.L scan_big_bob_6
                DC.L scan_big_bob_5
                DC.L scan_big_bob_4
                DC.L scan_big_bob_3

winkel:         DC.W 0,0,0

change:         DC.W 0
offs:           DS.W 3

screen160add1:
.zaehler        SET 0
                REPT 200
                DC.L .zaehler
.zaehler        SET .zaehler+160
                ENDR
screen160add2:
.zaehler        SET 0
                REPT 200
                DC.L .zaehler
.zaehler        SET .zaehler+160
                ENDR

                ENDPART

********** bob visual ****************

                >PART 'bob_gfx'

bob_gfx_8:      DC.W $3C00,$00,$7200,$0C00
                DC.W $B500,$4E00,$D900,$6600
                DC.W $EF00,$7000,$B700,$7800
                DC.W $5A00,$3C00,$3C00,$00
bob_msk_8:      DC.W $3C00,$7E00,$FF00,$FF00,$FF00,$FF00,$7E00,$3C00

bob_gfx_7:      DC.W $7C00,$00,$E600,$1800
                DC.W $BA00,$4C00,$DA00,$6400
                DC.W $EE00,$7000,$B600,$7800
                DC.W $7C00,$00
bob_msk_7:      DC.W $7C00,$FE00,$FE00,$FE00,$FE00,$FE00,$7C00

bob_gfx_6:      DC.W $7800,$00,$EC00,$1800
                DC.W $B400,$4800,$DC00,$6000
                DC.W $AC00,$7000,$7800,$00
bob_msk_6:      DC.W $7800,$FC00,$FC00,$FC00,$FC00,$7800


bob_gfx_5:      DC.W $7000,$00,$E800,$1000
                DC.W $B800,$4000,$D800,$6000
                DC.W $7000,$00
bob_msk_5:      DC.W $7000,$F800,$F800,$F800,$7000

bob_gfx_4:      DC.W $6000,$00,$D000,$2000
                DC.W $B000,$4000,$6000,$00
bob_msk_4:      DC.W $6000,$F000,$F000,$6000

bob_gfx_3:      DC.W $4000,$00,$E000,$00
                DC.W $00,$4000
bob_msk_3:      DC.W $4000,$E000,$4000

                ENDPART

******************************
******** rotation ************
******************************

text_pointer:   DC.L text_lines
text_lines:     DC.B "WELCOME"
                DC.B "  TO   "
                DC.B "STINTAX"
                DC.B "DONE BY"
                DC.B " INTER "
                DC.B "  AND  "
                DC.B " STAXX "
                DC.B -1
                EVEN

line_y:         DC.W 24
screen_adr:     DC.L 0
winkel_rot:     DC.W 0

********************************

hash_tab:       >PART
*********** 0 - 90 *************

off             SET 0
                REPT 46
                DC.L offset_tabs+off
off             SET off+gfx_wide*2
                ENDR

off             SET off-gfx_wide*2*2

                REPT 45
                DC.L offset_tabs+off
off             SET off-gfx_wide*2
                ENDR

off             SET gfx_wide*2

                REPT 45
                DC.L offset_tabs+off
off             SET off+gfx_wide*2
                ENDR

off             SET off-gfx_wide*2*2

                REPT 45
                DC.L offset_tabs+off
off             SET off-gfx_wide*2
                ENDR

off             SET gfx_wide*2

                REPT 45
                DC.L offset_tabs+off
off             SET off+gfx_wide*2
                ENDR

off             SET off-gfx_wide*2*2

                REPT 45
                DC.L offset_tabs+off
off             SET off-gfx_wide*2
                ENDR

off             SET gfx_wide*2

                REPT 45
                DC.L offset_tabs+off
off             SET off+gfx_wide*2
                ENDR

off             SET off-gfx_wide*2*2

                REPT 45
                DC.L offset_tabs+off
off             SET off-gfx_wide*2
                ENDR


                ENDPART

*********** rotation vars **************

                >PART

x_off:          DC.W 104
y_off:          DC.W 90

rotating_x:     DC.W gfx_wide/2 * rotating point x
rotating_y:     DC.W gfx_lines/2
rot_x:          DC.W 0          * rotating point x offset
rot_y:          DC.W 0          * rotating point y offset

four_points:    DS.L 2

line_x_y:
u               SET 0
                REPT gfx_lines
                DC.W 0,0+u,0+(gfx_wide-1),0+u
u               SET u+1
                ENDR

new_line_x_y:   DS.W 4*gfx_lines

                ENDPART

*********** sinus - table *************

sinus_table:    >PART
                DC.W $00,$023B,$0477,$06B2,$08ED
                DC.W $0B27,$0D61,$0F99,$11D0,$1406
                DC.W $163A,$186C,$1A9C,$1CCB,$1EF7
                DC.W $2120,$2348,$256C,$278D,$29AC
                DC.W $2BC7,$2DDF,$2FF3,$3203,$340F
                DC.W $3618,$381C,$3A1C,$3C17,$3E0E
                DC.W $4000,$41EC,$43D4,$45B6,$4793
                DC.W $496A,$4B3C,$4D08,$4ECD,$508D
                DC.W $5246,$53F9,$55A6,$574B,$58EA
                DC.W $5A82,$5C13,$5D9C,$5F1F,$609A
                DC.W $620D,$6379,$64DD,$6639,$678D
                DC.W $68D9,$6A1D,$6B59,$6C8C,$6DB7
                DC.W $6ED9,$6FF3,$7104,$720C,$730B
                DC.W $7401,$74EF,$75D3,$76AD,$777F
                DC.W $7847,$7906,$79BC,$7A68,$7B0A
                DC.W $7BA3,$7C32,$7CB8,$7D33,$7DA5
                DC.W $7E0E,$7E6C,$7EC1,$7F0B,$7F4C
                DC.W $7F83,$7FB0,$7FD3,$7FEC,$7FFB

                DC.W $7FFF,$7FFB,$7FEC,$7FD3,$7FB0
                DC.W $7F83,$7F4C,$7F0B,$7EC1,$7E6C
                DC.W $7E0E,$7DA5,$7D33,$7CB8,$7C32
                DC.W $7BA3,$7B0A,$7A68,$79BC,$7906
                DC.W $7847,$777F,$76AD,$75D3,$74EF
                DC.W $7401,$730B,$720C,$7104,$6FF3
                DC.W $6ED9,$6DB7,$6C8C,$6B59,$6A1D
                DC.W $68D9,$678D,$6639,$64DD,$6379
                DC.W $620D,$609A,$5F1F,$5D9C,$5C13
                DC.W $5A82,$58EA,$574B,$55A6,$53F9
                DC.W $5246,$508D,$4ECD,$4D08,$4B3C
                DC.W $496A,$4793,$45B6,$43D4,$41EC
                DC.W $4000,$3E0E,$3C17,$3A1C,$381C
                DC.W $3618,$340F,$3203,$2FF3,$2DDF
                DC.W $2BC7,$29AC,$278D,$256C,$2348
                DC.W $2120,$1EF7,$1CCB,$1A9C,$186C
                DC.W $163A,$1406,$11D0,$0F99,$0D61
                DC.W $0B27,$08ED,$06B2,$0477,$023B

                DC.W $00,$FDC5,$FB89,$F94E,$F713
                DC.W $F4D9,$F29F,$F067,$EE30,$EBFA
                DC.W $E9C6,$E794,$E564,$E335,$E109
                DC.W $DEE0,$DCB8,$DA94,$D873,$D654
                DC.W $D439,$D221,$D00D,$CDFD,$CBF1
                DC.W $C9E8,$C7E4,$C5E4,$C3E9,$C1F2
                DC.W $C001,$BE14,$BC2C,$BA4A,$B86D
                DC.W $B696,$B4C4,$B2F8,$B133,$AF73
                DC.W $ADBA,$AC07,$AA5A,$A8B5,$A716
                DC.W $A57E,$A3ED,$A264,$A0E1,$9F66
                DC.W $9DF3,$9C87,$9B23,$99C7,$9873
                DC.W $9727,$95E3,$94A7,$9374,$9249
                DC.W $9127,$900D,$8EFC,$8DF4,$8CF5
                DC.W $8BFF,$8B11,$8A2D,$8953,$8881
                DC.W $87B9,$86FA,$8644,$8598,$84F6
                DC.W $845D,$83CE,$8348,$82CD,$825B
                DC.W $81F2,$8194,$813F,$80F5,$80B4
                DC.W $807D,$8050,$802D,$8014,$8005

                DC.W $8000,$8005,$8014,$802D,$8050
                DC.W $807D,$80B4,$80F5,$813F,$8194
                DC.W $81F2,$825B,$82CD,$8348,$83CE
                DC.W $845D,$84F6,$8598,$8644,$86FA
                DC.W $87B9,$8881,$8953,$8A2D,$8B11
                DC.W $8BFF,$8CF5,$8DF4,$8EFC,$900D
                DC.W $9127,$9249,$9374,$94A7,$95E3
                DC.W $9727,$9873,$99C7,$9B23,$9C87
                DC.W $9DF3,$9F66,$A0E1,$A264,$A3ED
                DC.W $A57E,$A716,$A8B5,$AA5A,$AC07
                DC.W $ADBA,$AF73,$B133,$B2F8,$B4C4
                DC.W $B696,$B86D,$BA4A,$BC2C,$BE14
                DC.W $C001,$C1F2,$C3E9,$C5E4,$C7E4
                DC.W $C9E8,$CBF1,$CDFD,$D00D,$D221
                DC.W $D439,$D654,$D873,$DA94,$DCB8
                DC.W $DEE0,$E109,$E335,$E564,$E794
                DC.W $E9C6,$EBFA,$EE30,$F067,$F29F
                DC.W $F4D9,$F713,$F94E,$FB89,$FDC5

                ENDPART

******* leisten ************

leisten:        >PART
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $0C05,$3000,$3FFF,$00,$8A90,$00,$FFFF,$00
                DC.W $B300,$81,$FF81,$00,$8000,$6000,$E000,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $1A7F,$5A00,$65FF,$00,$F9FA,$02,$FFFD,$00
                DC.W $5E81,$4042,$BFC3,$00,$4000,$2000,$E000,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $2800,$A400,$DC00,$00,$160D,$0504,$1B0B,$00
                DC.W $A1C1,$32A5,$D366,$00,$8000,$4000,$C000,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $3000,$A800,$D800,$00,$180E,$2A05,$360B,$00
                DC.W $60C7,$315A,$51BD,$00,$00,$8000,$8000,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $2C00,$CFFF,$F000,$00,$00,$FFFF,$00,$00
                DC.W $00,$FFFF,$00,$00,$00,$FFFF,$00,$00
                DC.W $00,$FFFF,$00,$00,$00,$FFFF,$00,$00
                DC.W $00,$FFFF,$00,$00,$00,$FFFF,$00,$00
                DC.W $DD80,$91FF,$6E00,$00,$642A,$C1EB,$3E14,$00
                DC.W $686E,$AF24,$50DB,$00,$8000,$FFFF,$00,$00
                DC.W $00,$FFFF,$00,$00,$00,$FFFF,$00,$00
                DC.W $00,$FFFF,$00,$00,$00,$FFFF,$00,$00
                DC.W $00,$FFFF,$00,$00,$00,$FFFF,$00,$00
                DC.W $00,$FFFF,$00,$00,$34,$FFF3,$0F,$00
                DC.W $AFFF,$3000,$C000,$00,$FFFF,$00,$00,$00
                DC.W $FFFF,$00,$00,$00,$FFFF,$00,$00,$00
                DC.W $FFFF,$00,$00,$00,$FFFF,$00,$00,$00
                DC.W $FFFF,$00,$00,$00,$FFFE,$01,$00,$00
                DC.W $2B6F,$8870,$7780,$00,$BBC8,$522B,$2C14,$00
                DC.W $232B,$AC89,$5076,$00,$7FFF,$8000,$00,$00
                DC.W $FFFF,$00,$00,$00,$FFFF,$00,$00,$00
                DC.W $FFFF,$00,$00,$00,$FFFF,$00,$00,$00
                DC.W $FFFF,$00,$00,$00,$FFFF,$00,$00,$00
                DC.W $FFFF,$00,$00,$00,$FFF5,$0C,$03,$00
                DC.W $4000,$7FFF,$8000,$00,$00,$FFFF,$00,$00
                DC.W $00,$FFFF,$00,$00,$00,$FFFF,$00,$00
                DC.W $00,$FFFF,$00,$00,$00,$FFFF,$00,$00
                DC.W $00,$FFFF,$00,$00,$00,$FFFF,$00,$00
                DC.W $2AD8,$E21F,$1DE0,$00,$CA17,$83D0,$7C2F,$00
                DC.W $88AD,$0F89,$F076,$00,$00,$FFFF,$00,$00
                DC.W $00,$FFFF,$00,$00,$00,$FFFF,$00,$00
                DC.W $00,$FFFF,$00,$00,$00,$FFFF,$00,$00
                DC.W $00,$FFFF,$00,$00,$00,$FFFF,$00,$00
                DC.W $00,$FFFF,$00,$00,$02,$FFFE,$01,$00
                DC.W $8000,$00,$FFFF,$00,$00,$00,$FFFF,$00
                DC.W $00,$00,$FFFF,$00,$00,$00,$FFFF,$00
                DC.W $00,$00,$FFFF,$00,$00,$00,$FFFF,$00
                DC.W $00,$00,$FFFF,$00,$00,$00,$FFFF,$00
                DC.W $06A0,$80,$FF7F,$00,$7456,$2816,$DFE9,$00
                DC.W $505A,$4010,$BFEF,$00,$00,$00,$FFFF,$00
                DC.W $00,$00,$FFFF,$00,$00,$00,$FFFF,$00
                DC.W $00,$00,$FFFF,$00,$00,$00,$FFFF,$00
                DC.W $00,$00,$FFFF,$00,$00,$00,$FFFF,$00
                DC.W $00,$00,$FFFF,$00,$01,$00,$FFFF,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $0120,$0211,$03F1,$00,$9070,$08AF,$F8DF,$00
                DC.W $2037,$B0AA,$D0DD,$00,$00,$8000,$8000,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $02A0,$0491,$0771,$00,$E040,$5090,$B0F0,$00
                DC.W $2063,$3155,$51B6,$00,$00,$4000,$C000,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $83FF,$5400,$1800,$00,$FFFF,$00,$00,$00
                DC.W $FFFF,$00,$00,$00,$FFFF,$00,$00,$00
                DC.W $FFFF,$00,$00,$00,$FFFF,$00,$00,$00
                DC.W $FFFF,$00,$00,$00,$FFD7,$30,$0F,$00
                DC.W $F949,$0136,$FEE3,$00,$A4A7,$9B18,$71F0,$00
                DC.W $49,$9E36,$73E3,$00,$57FF,$1800,$E000,$00
                DC.W $FFFF,$00,$00,$00,$FFFF,$00,$00,$00
                DC.W $FFFF,$00,$00,$00,$FFFF,$00,$00,$00
                DC.W $FFFF,$00,$00,$00,$FFFF,$00,$00,$00
                DC.W $FFFF,$00,$00,$00,$FFC1,$2A,$18,$00
                DC.W $4000,$1000,$DFFF,$00,$00,$00,$FFFF,$00
                DC.W $00,$00,$FFFF,$00,$00,$00,$FFFF,$00
                DC.W $00,$00,$FFFF,$00,$00,$00,$FFFF,$00
                DC.W $00,$00,$FFFF,$00,$1E,$00,$FFFF,$00
                DC.W $0301,$C2,$FFFF,$00,$C0C0,$2120,$FFFF,$00
                DC.W $6080,$1341,$FFFF,$00,$8000,$4000,$FFFF,$00
                DC.W $00,$00,$FFFF,$00,$00,$00,$FFFF,$00
                DC.W $00,$00,$FFFF,$00,$00,$00,$FFFF,$00
                DC.W $00,$00,$FFFF,$00,$00,$00,$FFFF,$00
                DC.W $00,$00,$FFFF,$00,$02,$08,$FFFB,$00


                DC.W $83FF,$5400,$1800,$00,$FFFF,$00,$00,$00
                DC.W $FFFF,$00,$00,$00,$FFFF,$00,$00,$00
                DC.W $FFFF,$00,$00,$00,$FFFF,$00,$00,$00
                DC.W $FFFF,$00,$00,$00,$FFFF,$00,$00,$00
                DC.W $FFFF,$00,$00,$00,$FFFF,$00,$00,$00
                DC.W $FFFF,$00,$00,$00,$FFFF,$00,$00,$00
                DC.W $FFFF,$00,$00,$00,$FFFF,$00,$00,$00
                DC.W $FFFF,$00,$00,$00,$FFFF,$00,$00,$00
                DC.W $FFFF,$00,$00,$00,$FFFF,$00,$00,$00
                DC.W $FFFF,$00,$00,$00,$FFC1,$2A,$18,$00
                DC.W $4000,$1000,$DFFF,$00,$00,$00,$FFFF,$00
                DC.W $00,$00,$FFFF,$00,$00,$00,$FFFF,$00
                DC.W $00,$00,$FFFF,$00,$00,$00,$FFFF,$00
                DC.W $00,$00,$FFFF,$00,$00,$00,$FFFF,$00
                DC.W $00,$00,$FFFF,$00,$00,$00,$FFFF,$00
                DC.W $00,$00,$FFFF,$00,$00,$00,$FFFF,$00
                DC.W $00,$00,$FFFF,$00,$00,$00,$FFFF,$00
                DC.W $00,$00,$FFFF,$00,$00,$00,$FFFF,$00
                DC.W $00,$00,$FFFF,$00,$00,$00,$FFFF,$00
                DC.W $00,$00,$FFFF,$00,$02,$08,$FFFB,$00


                ENDPART

* a0.l Adress of song
* a1.l Adress of voiceset
* +0 Init
* +4 Re-Init
* +8 Player
player:         IBYTES 'REPLAYER.BIN'
song1:          IBYTES 'KANABIS.TRI'
voice:          IBYTES 'KANABIS.TVS'
                EVEN

******* a new font ***********

new_font:       IBYTES 'FONT.DAT'
                EVEN

*********** back gfx *********

mamor:          >PART
                DC.W $78FC,$8700,$00,$FFFF,$0F3C,$C0,$8000,$7FFF
                DC.W $C3D8,$3C00,$01,$FFFE,$3E1F,$01E0,$00,$FFFF
                DC.W $8E90,$7000,$00,$FFFF,$6CC1,$13FE,$00,$FFFF
                DC.W $3E01,$C000,$00,$FFFF,$C0E6,$3FFF,$00,$FFFF
                DC.W $7807,$8000,$80,$FF7F,$0CBF,$FFFF,$00,$FFFF
                DC.W $E00C,$03,$0180,$FE7F,$7F80,$FFFF,$00,$FFFF
                DC.W $8019,$07,$0600,$F9FF,$C03F,$FFC0,$00,$FFFF
                DC.W $77,$0F,$1C00,$E3FF,$03F8,$FC00,$00,$FFFF
                DC.W $EC,$1F,$C000,$3FFF,$67E0,$9800,$01,$FFFE
                DC.W $1D98,$7F,$00,$FFFF,$F3F0,$0C00,$00,$FFFF
                DC.W $D921,$20FE,$00,$FFFF,$D8FF,$0700,$00,$FFFF
                DC.W $324C,$C1F0,$00,$FFFF,$3E00,$01FF,$00,$FFFF
                DC.W $66D8,$81E0,$00,$FFFF,$07C3,$3C,$00,$FFFF
                DC.W $DCD8,$03E0,$01,$FFFE,$E1,$1E,$3000,$CFFF
                DC.W $B9D0,$07E0,$03,$FFFC,$E9,$1E,$A400,$5BFF
                DC.W $F110,$0FE0,$02,$FFFD,$01CC,$3F,$0400,$FBFF
                DC.W $83B0,$7FC0,$02,$FFFD,$31DE,$3F,$00,$FFFF
                DC.W $7E20,$FFC0,$02,$FFFD,$FF30,$FF,$00,$FFFF
                DC.W $C0E0,$FF00,$00,$FFFF,$CEEE,$31F1,$00,$FFFF
                DC.W $0FF0,$F000,$00,$FFFF,$7007,$0FF8,$00,$FFFF

                ENDPART

************************************
                BSS
************************************

bss_start:

key:            DS.W 1
save_mfp:       DS.L 6
save_system:    DS.L 9
black:          DS.L 8

********** CTAR FIELD TABS ************

anzahl_stars:   DS.W 1

star_tab:       DS.W anz_stars*3

init_tab:       DS.W 32768

******** bob stuff ***********

save_all_bobs_1:DS.W 3*anz_stars
                DS.L 1
save_all_bobs_2:DS.W 3*anz_stars
                DS.L 1

big_bob_buff8:  DS.W 4*8*16
big_bob_buff7:  DS.W 4*7*16
big_bob_buff6:  DS.W 4*6*16
big_bob_buff5:  DS.W 4*5*16
big_bob_buff4:  DS.W 4*4*16
big_bob_buff3:  DS.W 4*3*16

********** color table for rotate **********

rotate_frame:   DS.L 24*gfx_lines

color_hash_table_1:
                DS.L 192*gfx_lines
color_hash_table_2:
                DS.L 192*gfx_lines

offset_tabs:    DS.W gfx_wide*46
offset_help:    DS.W gfx_wide+1

********* SCREEN MUM ***********

                DS.W 256
screen_mem:     DS.L 8000*2
                DS.W 256

*************************************
*********** 3d stuff ****************
*************************************

clear_flag:     DS.B 1
                EVEN
anzahl_ecken:   DS.W 1

**************************************

x0:             DS.W 1
y0:             DS.W 1
z0:             DS.W 1

                DS.L 10
trans_flaeche:  DS.L 10         ; die transformierten Punkte fÅr die FlÑche
                DS.L 10
trans:          DS.L 10         ; die gesamten transformierten Punkte
poly_x_right:   DS.W 200
poly_x_left:    DS.W 200

rout_adrs:      DS.L 16
rout_adrs2:     DS.B 20000
                DS.B 10000
routs:          DS.L 234000/4

rout_adrs_l:    DS.L 16
rout_adrs2_l:   DS.B 20000
                DS.B 10000
routs_l:        DS.L 255000/4

bss_end:
                END
