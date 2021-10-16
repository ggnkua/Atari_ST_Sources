************************************
********  INTRO FOR PLŽTZE  ********
                PATH 'E:'
* MIKE OF STAX IN 1993

* intro  V.1.0

************** no a5-a6/d7 !!!!! *************

                TEXT

                pea     0
                move.w  #$20,-(SP)
                trap    #1
                addq.l  #6,SP
                move.l  D0,save_stack

                move.l  #sync_vbl,$70.w

                bsr     install_system

                lea     module,A0
                bsr     depack_mod

                lea     module,A0
                move.l  #16000,D0
                moveq   #1,D1
                moveq   #0,D2
                bsr     mod_player
                bsr     mod_player+4

                bsr     vsync
                move.l  #my_vbl,$70.w

                bsr     scan_leisten

                >PART 'part 0'
                move.l  #line_pal,main_pal
part_0:         bsr     vsync
                bsr     colored_line
                tst.w   D6
                bmi.s   part_1
                cmpi.b  #$39,key
                beq     out
                bra.s   part_0
                ENDPART
                >PART 'part 1'
part_1:         bsr     vsync
                move.l  #black_pal,main_pal
                bsr     copy_logo
                bsr     fade_white
                bsr     fade_right
                ENDPART
                PART 'part 2'
part_2:

                move.w  #160*160,line_offset
                lea     text_0,A2
                bsr     spray_action
                lea     text_1,A2
                bsr     spray_action
                lea     text_2,A2
                bsr     spray_action

                bsr     fade_out
                bsr     clear_work

                move.l  #black_pal,main_pal
                bsr     copy_seats
                bsr     wait_raster
                move.b  #125,next_distance
                move.b  #27+25,last_distance
                move.l  #seat_pal_0,main_pal
                bsr     fade_it_in2

                move.w  #160*135,line_offset
                lea     text_x0,A2
                bsr     spray_only
                lea     text_x1,A2
                bsr     spray_only

                bsr     sleep

                move.w  #160*135,line_offset
                lea     text_x0,A2
                bsr     c_only
                lea     text_x1,A2
                bsr     c_only

                bsr     fade_out
                bsr     clear_work

                bsr     wait_raster
                move.b  #150,next_distance
                move.b  #27,last_distance
                move.l  #font_pal,main_pal

                move.w  #160*65,line_offset
                lea     text_3,A2
                bsr     spray_only
                lea     text_4,A2
                bsr     spray_only
                lea     text_5,A2
                bsr     spray_only
                lea     text_6,A2
                bsr     spray_only

                bsr     sleep

                move.w  #160*65,line_offset
                lea     text_3,A2
                bsr     c_only
                lea     text_4,A2
                bsr     c_only
                lea     text_5,A2
                bsr     c_only
                lea     text_6,A2
                bsr     c_only

                move.l  #black_pal,main_pal
                bsr     copy_insel
                bsr     wait_raster

                move.l  #insel_pal_0,main_pal
                move.l  #insel_time_1,next_raster
                move.b  #94-1,next_distance

                bsr     fade_it_in

                move.w  #160*160,line_offset
                lea     text_7,A2
                bsr     spray_action
                lea     text_8,A2
                bsr     spray_action

                bsr     fade_more
                bsr     clear_work

                bsr     wait_raster
                move.l  #font_pal,main_pal
                move.l  #set_font,next_raster
                move.b  #150,next_distance

                move.w  #160*65,line_offset
                lea     text_9,A2
                bsr     spray_only
                lea     text_10,A2
                bsr     spray_only
                lea     text_11,A2
                bsr     spray_only
                lea     text_12,A2
                bsr     spray_only

                bsr     sleep

                move.w  #160*65,line_offset
                lea     text_9,A2
                bsr     c_only
                lea     text_10,A2
                bsr     c_only
                lea     text_11,A2
                bsr     c_only
                lea     text_12,A2
                bsr     c_only

                move.w  #160*20,line_offset
                lea     text_13,A2
                bsr     spray_only
                lea     text_14,A2
                bsr     spray_only
                lea     text_15,A2
                bsr     spray_only
                lea     text_16,A2
                bsr     spray_only
                lea     text_17,A2
                bsr     spray_only
                lea     text_18,A2
                bsr     spray_only
                lea     text_19,A2
                bsr     spray_only
                lea     text_20,A2
                bsr     spray_only

                move.w  #160*20,line_offset
                lea     text_13,A2
                bsr     c_only
                lea     text_14,A2
                bsr     c_only
                lea     text_15,A2
                bsr     c_only
                lea     text_16,A2
                bsr     c_only
                lea     text_17,A2
                bsr     c_only
                lea     text_18,A2
                bsr     c_only
                lea     text_19,A2
                bsr     c_only
                lea     text_20,A2
                bsr     c_only

                move.w  #160*45,line_offset
                lea     text_21,A2
                bsr     spray_only
                lea     text_22,A2
                bsr     spray_only
                lea     text_23,A2
                bsr     spray_only
                lea     text_24,A2
                bsr     spray_only
                lea     text_25,A2
                bsr     spray_only

                move.w  #160*45,line_offset
                lea     text_21,A2
                bsr     c_only
                lea     text_22,A2
                bsr     c_only
                lea     text_23,A2
                bsr     c_only
                lea     text_24,A2
                bsr     c_only
                lea     text_25,A2
                bsr     c_only

                move.w  #160*55,line_offset
                lea     text_26,A2
                bsr     spray_only
                lea     text_26a,A2
                bsr     spray_only
                addi.w  #20*160,line_offset
                lea     text_27,A2
                bsr     spray_only

                move.w  #160*55,line_offset
                lea     text_26,A2
                bsr     c_only
                lea     text_26a,A2
                bsr     c_only
                addi.w  #20*160,line_offset
                lea     text_27,A2
                bsr     c_only

                move.w  #160*30,line_offset
                lea     text_28,A2
                bsr     spray_only
                addi.w  #160*20,line_offset
                lea     text_29,A2
                bsr     spray_only
                lea     text_30,A2
                bsr     spray_only
                lea     text_31,A2
                bsr     spray_only
                lea     text_32,A2
                bsr     spray_only
                lea     text_33,A2
                bsr     spray_only

                move.w  #160*30,line_offset
                lea     text_28,A2
                bsr     c_only
                addi.w  #160*20,line_offset
                lea     text_29,A2
                bsr     c_only
                lea     text_30,A2
                bsr     c_only
                lea     text_31,A2
                bsr     c_only
                lea     text_32,A2
                bsr     c_only
                lea     text_33,A2
                bsr     c_only


                move.w  #160*90,line_offset
                lea     text_34,A2
                bsr     spray_only

space:          cmpi.b  #$39,key
                bne.s   space

                move.w  #160*90,line_offset
                lea     text_34,A2
                bsr     c_only

                ENDPART
                >PART 'PART 3'

                bsr     wait_raster
                move.l  #leisten_pal+2,main_pal
                bsr     fade_out

                move.l  #25,D0
                bsr     sync

                bsr     fill_plane
                bsr     wait_raster
                move.l  #last_vbl,$70.w
                bsr     fade_plane
                bsr.s   clear_org


                ENDPART
out:
                move.w  #3,mod_player+28 ; Abblenden
wait_silence:   tst.w   mod_player+30
                bne.s   wait_silence

                bsr     mod_player+8

                bsr     restore_system

                move.l  save_stack,-(SP)
                move.w  #$20,-(SP)
                trap    #1
                addq.l  #6,SP

                clr.w   -(SP)
                trap    #1

sync_vbl:       addq.l  #1,vbl_timer
                rte

vbl_timer:      DS.L 1

*********************************

                >PART 'stuff'

clear_org:      moveq   #0,D2
                move.w  #160*197,D3
                moveq   #24,D5
repeat_that:    bsr     vsync
                move.w  D2,D4
                bsr.s   clear_line
                move.w  D3,D4
                bsr.s   clear_line
                addi.w  #640,D2
                subi.w  #640,D3
                dbra    D5,repeat_that

                moveq   #9,D5
                move.w  #0+160*100,D2
                move.w  #152+160*100,D3
repeat_you:     bsr     vsync
                move.w  D2,D4
                bsr.s   clear_word
                move.w  D3,D4
                bsr.s   clear_word
                addq.w  #8,D2
                subq.w  #8,D3
                dbra    D5,repeat_you

                rts

clear_word:     movea.l screen,A0
                clr.w   0(A0,D4.w)
                rts

clear_line:                             * d4=offset
                movea.l screen,A0
                adda.w  D4,A0
                moveq   #0,D0
                moveq   #79,D1
rep_cls:        move.w  D0,(A0)
                addq.l  #8,A0
                dbra    D1,rep_cls
                rts


fill_plane:
                movea.l screen,A0
                move.l  #$FFFF0000,D0
                moveq   #0,D1
                move.w  #3999,D2
fill_screen:    move.l  D0,(A0)+
                move.l  D1,(A0)+
                dbra    D2,fill_screen
                rts

wait_raster:    lea     raster_wait,A0
rasty:          move.b  (A0),D0
                bmi.s   rasty
                rts

clear_work:
                movea.l screen,A0
                lea     6*160(A0),A0
                moveq   #0,D0
                move.w  #187,D1
k:              moveq   #39,D2
j:              move.l  D0,(A0)+
                dbra    D2,j
                dbra    D1,k
                rts

sleep:          moveq   #50,D2
asso:           bsr     vsync
                dbra    D2,asso
                rts

copy_insel:     movea.l screen,A0
                lea     160*10+24(A0),A0
                lea     insel_dat,A1
                move.w  #143,D0
lupi_0:         moveq   #14,D1
lupi_2:         move.l  (A1)+,(A0)+
                move.l  (A1)+,(A0)+
                dbra    D1,lupi_2
                lea     40(A0),A0
                dbra    D0,lupi_0
                rts

copy_seats:
                movea.l screen,A0
                lea     160*30+24(A0),A0
                lea     seat_dat,A1
                move.w  #87,D0
lupi_0a:        moveq   #12,D1
lupi_2a:        move.l  (A1)+,(A0)+
                move.l  (A1)+,(A0)+
                dbra    D1,lupi_2a
                lea     56(A0),A0
                dbra    D0,lupi_0a
                rts

copy_logo:
                movea.l screen,A0
                lea     25*160+24(A0),A0
                lea     logo,A1

                moveq   #7,D6

                moveq   #115,D0
lops:           moveq   #12,D5
lopps:          moveq   #0,D1
                moveq   #0,D2
                moveq   #0,D3
                moveq   #0,D4
                move.w  (A1)+,D1
                move.w  (A1)+,D2
                move.w  (A1)+,D3
                move.w  (A1)+,D4
                ror.l   D6,D1
                ror.l   D6,D2
                ror.l   D6,D3
                ror.l   D6,D4
                or.w    D1,(A0)+
                or.w    D2,(A0)+
                or.w    D3,(A0)+
                or.w    D4,(A0)+
                swap    D1
                swap    D2
                swap    D3
                swap    D4
                move.w  D1,(A0)
                move.w  D2,2(A0)
                move.w  D3,4(A0)
                move.w  D4,6(A0)
                dbra    D5,lopps
                lea     7*8(A0),A0
                dbra    D0,lops
                rts

scan_leisten:
                movea.l screen,A0
                lea     leisten,A1
                bsr.s   copy_it

                lea     188*160(A0),A0
                bsr.s   copy_it

                rts

copy_it:        moveq   #5,D0
cop_0:          moveq   #39,D1
cop_1:          move.l  (A1)+,(A0)+
                dbra    D1,cop_1
                dbra    D0,cop_0
                rts

                ENDPART
                >PART 'Depack MOD'
depack_mod:     bsr     analyse_module  ; find sample start/end

                bsr     init_depack

                movea.l sample_start,A0 ; packed sample
                move.l  sample_end,D0
                sub.l   A0,D0           ; unpacked length

                move.l  D0,-(SP)
                bsr     depack_sample   ; depack over source
                move.l  (SP)+,D0
                rts

; a0=module address

analyse_module: move.l  A0,-(SP)

                lea     $03B8(A0),A1

                moveq   #$7F,D0
                moveq   #0,D4
mt_loop:        move.l  D4,D2
                subq.w  #1,D0
mt_lop2:        move.b  (A1)+,D4
                cmp.b   D2,D4
                bgt.s   mt_loop
                dbra    D0,mt_lop2
                addq.b  #1,D2

                asl.l   #8,D2
                asl.l   #2,D2
                add.l   #$043C,D2
                move.l  D2,D1
                add.l   A0,D2
                movea.l D2,A2

                move.l  A2,sample_start

                moveq   #$1E,D0
mt_lop3:
                moveq   #0,D4
                move.w  42(A0),D4
                add.l   D4,D4
                adda.l  D4,A2
                adda.l  #$1E,A0
                dbra    D0,mt_lop3

                move.l  A2,sample_end

                movea.l (SP)+,A0

                rts

; a0=packed sample (also destination)
; d0=unpacked length

depack_sample:
                lea     depack_hi,A2
                lea     depack_lo,A3

                addq.l  #1,D0
                and.b   #-2,D0          ; round length up
                move.l  D0,D7
                lsr.l   #1,D7           ; sample length in words

                lea     0(A0,D0.l),A1   ; destination end
                adda.l  D7,A0           ; source end

                move.w  #128,D0         ; last byte
                moveq   #0,D1           ; clear temp

depack_loop:    move.b  -(A0),D1        ; get 2 distances
                add.b   0(A2,D1.w),D0
                move.b  D0,-(A1)
                add.b   0(A3,D1.w),D0
                move.b  D0,-(A1)

                subq.l  #1,D7
                bne.s   depack_loop

                rts

init_depack:    lea     depack_lo,A1
                move.w  #15,D7
init1:          lea     power_bytes(PC),A0
                move.w  #15,D6
init2:          move.b  (A0)+,(A1)+
                dbra    D6,init2
                dbra    D7,init1

                lea     power_bytes(PC),A0
                lea     depack_hi,A1
                move.w  #15,D7
init3:          move.w  #15,D6
                move.b  (A0)+,D0
init4:          move.b  D0,(A1)+
                dbra    D6,init4
                dbra    D7,init3
                rts

power_bytes:    DC.B -128,-64,-32,-16,-8,-4,-2,-1,0,1,2,4,8,16,32,64
sample_start:   DC.L 0
sample_end:     DC.L 0
                ENDPART

*********** spraying *********

                >PART

spray_only:     bsr     prep_message
                movem.l spray_start,D0-D2
                movem.l D0-D2,spray_offsets
                bsr.s   do_spray_in
                addi.w  #20*160,line_offset
                rts
c_only:
                movem.l spray_start,D0-D2
                movem.l D0-D2,spray_offsets
                bsr.s   do_spray_out
                addi.w  #160*20,line_offset
                rts

spray_action:   bsr     prep_message
                movem.l spray_start,D0-D2
                movem.l D0-D2,spray_offsets
                bsr.s   do_spray_in

                bsr     sleep

                movem.l spray_start,D0-D2
                movem.l D0-D2,spray_offsets
                bsr.s   do_spray_out

                rts


do_spray_in:    bsr     vsync
                bsr     vsync
                bsr     spray_me_in
                cmp.w   #6,D6
                beq.s   aus1
                cmpi.b  #$39,key
                bne.s   do_spray_in
                addq.l  #8,SP
                bra     out
aus1:           rts

do_spray_out:   bsr     vsync
                bsr     vsync
                bsr.s   spray_me_out
                cmp.w   #6,D6
                beq.s   aus2
                cmpi.b  #$39,key
                bne.s   do_spray_out
                addq.l  #8,SP
                bra     out
aus2:           rts

spray_me_out:
                lea     spray_offsets,A0
                movea.l screen,A2
                adda.w  line_offset,A2
                lea     builder_mask,A3

                moveq   #0,D6           * ready counter
                moveq   #5,D0           * spray counteb
repeat_alla:
                move.w  (A0)+,D1
                bpl.s   drina
                addq.w  #8,-2(A0)
                dbra    D0,repeat_alla
                rts
drina:          cmp.w   #160,D1
                blt.s   drin_2a
                addq.w  #1,D6
                lea     16*2(A3),A3
                dbra    D0,repeat_alla
                rts
drin_2a:
                addq.w  #8,-2(A0)

                move.l  A2,-(SP)

                adda.w  D1,A2           * screen off


                moveq   #15,D1
spray_ita:      movem.w (A2),D2-D4
                move.w  (A3)+,D5
                not.w   D5
                and.w   D5,D2
                and.w   D5,D3
                and.w   D5,D4
                movem.w D2-D4,(A2)

                lea     160(A2),A2

                dbra    D1,spray_ita

                movea.l (SP)+,A2

                dbra    D0,repeat_alla

                rts


spray_me_in:
                lea     spray_offsets,A0
                movea.l screen,A2
                adda.w  line_offset,A2
                lea     builder_mask,A3

                lea     font_buffer,A4

                moveq   #0,D6           * ready counter
                moveq   #5,D0           * spray counter
repeat_all:
                move.w  (A0)+,D1
                bpl.s   drin
                addq.w  #8,-2(A0)
                dbra    D0,repeat_all
                rts
drin:           cmp.w   #160,D1
                blt.s   drin_2
                addq.w  #1,D6
                lea     16*2(A3),A3
                dbra    D0,repeat_all
                rts
drin_2:
                addq.w  #8,-2(A0)

                movem.l A2/A4,-(SP)

                adda.w  D1,A2           * screen off

                asr.w   #3,D1
                add.w   D1,D1
                move.w  D1,D2
                add.w   D1,D1
                add.w   D2,D1
                adda.w  D1,A4           * font buffer off

                moveq   #15,D1
spray_it:       movem.w (A4),D2-D4
                move.w  (A3)+,D5
                and.w   D5,D2
                and.w   D5,D3
                and.w   D5,D4
                movem.w D2-D4,(A2)

                lea     160(A2),A2
                lea     120(A4),A4

                dbra    D1,spray_it

                movem.l (SP)+,A2/A4

                dbra    D0,repeat_all

                rts

                ENDPART

********* colored lines **********

colored_line:   >PART

                moveq   #0,D6

                move.w  D6,-(SP)

                lea     color_tab_0,A0
                adda.w  the_offset_d,A0
                movea.l screen,A1
                lea     160*25+64(A1),A1
                bsr     dia_line_2

                lea     color_tab_0,A0
                adda.w  the_offset_d,A0
                movea.l screen,A1
                lea     160*25+72(A1),A1
                bsr     dia_line_1

                lea     color_tab_1,A0
                adda.w  the_offset_h,A0

                cmpa.l  #ende,A0
                blt.s   okk

                move.w  (SP)+,D6
                move.w  #-1,D6
                move.w  D6,-(SP)

okk:            movea.l screen,A1

                lea     160*121+24(A1),A1
                bsr.s   hori_line

                addq.w  #3,the_offset_d
                addq.w  #5,the_offset_h

                move.w  (SP)+,D6

                rts
                ENDPART
hori_line:      >PART
                lea     point_tab,A2

                moveq   #11,D0

                moveq   #0,D2
                moveq   #15,D1

do_it_0:        movea.w D0,A4

                moveq   #0,D0
                moveq   #0,D4
                moveq   #0,D5
                moveq   #0,D6

do_it_1:        movea.l A2,A3

                move.b  (A0)+,D3
                ext.w   D3
                asl.w   #3,D3
                adda.w  D3,A3

                move.w  (A3)+,D3
                ror.w   D2,D3
                or.w    D3,D0

                move.w  (A3)+,D3
                ror.w   D2,D3
                or.w    D3,D4

                move.w  (A3)+,D3
                ror.w   D2,D3
                or.w    D3,D5

                move.w  (A3)+,D3
                ror.w   D2,D3
                or.w    D3,D6

                addq.w  #1,D2

                dbra    D1,do_it_1

                movem.w D0/D4-D6,(A1)

                addq.l  #8,A1

                move.w  A4,D0

                moveq   #0,D2
                moveq   #15,D1

                dbra    D0,do_it_0

                rts
                ENDPART
dia_line_1:     >PART
                lea     point_tab,A2

                moveq   #5,D0

                moveq   #15,D1
                moveq   #0,D2

do_it_0a:       movea.w D0,A4

do_it_1a:       move.b  (A0)+,D3
                ext.w   D3
                asl.w   #3,D3

                movem.w 0(A2,D3.w),D0/D4-D6

                ror.w   D2,D0
                ror.w   D2,D4
                ror.w   D2,D5
                ror.w   D2,D6

                movem.w D0/D4-D6,(A1)

                addq.w  #1,D2

                lea     160(A1),A1

                dbra    D1,do_it_1a

                addq.l  #8,A1

                moveq   #15,D1
                moveq   #0,D2

                move.w  A4,D0

                dbra    D0,do_it_0a

                rts
                ENDPART
dia_line_2:     >PART
                lea     point_tab,A2

                moveq   #5,D0

                moveq   #15,D1

do_it_0b:       movea.w D0,A4

do_it_1b:       move.b  (A0)+,D3
                ext.w   D3
                asl.w   #3,D3

                movem.w 0(A2,D3.w),D0/D4-D6

                ror.w   D1,D0
                ror.w   D1,D4
                ror.w   D1,D5
                ror.w   D1,D6

                movem.w D0/D4-D6,(A1)

                lea     160(A1),A1

                dbra    D1,do_it_1b

                subq.l  #8,A1

                moveq   #15,D1

                move.w  A4,D0

                dbra    D0,do_it_0b

                rts
                ENDPART

********** fades **********

fade_plane:     >PART
                moveq   #6,D0
mercy_1cs:      move.w  D0,-(SP)
                moveq   #2,D0
                bsr     sync
                addi.w  #$0111,leisten_pal+2
                move.w  (SP)+,D0
                dbra    D0,mercy_1cs
                rts
                ENDPART
fade_it_in:     >PART
                moveq   #6,D0
mercy_1c:       move.w  D0,-(SP)
                moveq   #3,D0
                bsr     sync
                lea     insel_0,A1
                lea     insel_pal_0,A0
                bsr     fade_it_right
                lea     insel_1,A1
                lea     insel_pal_1,A0
                bsr     fade_it_right
                lea     insel_2,A1
                lea     insel_pal_2,A0
                bsr     fade_it_right
                move.w  (SP)+,D0
                dbra    D0,mercy_1c
                rts
                ENDPART
fade_it_in2:    >PART
                moveq   #6,D0
mercy_1ca:      move.w  D0,-(SP)
                moveq   #4,D0
                bsr     sync
                lea     seat_pal,A1
                lea     seat_pal_0,A0
                bsr     fade_it_right
                move.w  (SP)+,D0
                dbra    D0,mercy_1ca
                rts
                ENDPART
fade_right:     >PART
                moveq   #6,D0
mercy_1:        move.w  D0,-(SP)
                moveq   #3,D0
                bsr     sync
                lea     logo_pal,A1
                movea.l main_pal,A0
                bsr     fade_it_right
                move.w  (SP)+,D0
                dbra    D0,mercy_1
                rts
                ENDPART
fade_white:     >PART
                moveq   #6,D0
mercy_1a:       move.w  D0,-(SP)
                moveq   #3,D0
                bsr     sync
                lea     logo_pal,A1
                bsr.s   fade_it_white
                move.w  (SP)+,D0
                dbra    D0,mercy_1a
                rts
                ENDPART
fade_it_white:  >PART
                movea.l main_pal,A0
                moveq   #14,D1
lepo:           moveq   #0,D6
                moveq   #0,D2
                move.w  (A0),D2
                move.w  (A1)+,D6
                cmp.w   D2,D6
                beq.s   rias

                move.w  D6,D0
                move.w  D2,D3
                and.w   #%111,D0
                and.w   #%111,D3
                cmp.w   D3,D0
                beq.s   holle1
                subq.w  #1,D3
holle1:         move.w  D6,D0
                move.w  D2,D4
                lsr.w   #4,D0
                lsr.w   #4,D4
                and.w   #%111,D0
                and.w   #%111,D4
                cmp.w   D4,D0
                beq.s   holle2
                subq.w  #1,D4
holle2:         move.w  D6,D0
                move.w  D2,D5
                lsr.w   #8,D0
                lsr.w   #8,D5
                and.w   #%111,D0
                and.w   #%111,D5
                cmp.w   D5,D0
                beq.s   holle3
                subq.w  #1,D5
holle3:
                moveq   #0,D2
                move.b  D3,D2
                ror.w   #4,D2
                move.b  D4,D2
                ror.w   #4,D2
                move.b  D5,D2
                rol.w   #8,D2

rias:           move.w  D2,(A0)+
                dbra    D1,lepo
                rts

                ENDPART
fade_it_right:  >PART
                moveq   #14,D1
lepoa:          moveq   #0,D6
                moveq   #0,D2
                move.w  (A0),D2
                move.w  (A1)+,D6
                cmp.w   D2,D6
                beq.s   rias1a

                move.w  D6,D0
                move.w  D2,D3
                and.w   #%111,D0
                and.w   #%111,D3
                cmp.w   D3,D0
                beq.s   holle1a
                addq.w  #1,D3
holle1a:        move.w  D6,D0
                move.w  D2,D4
                lsr.w   #4,D0
                lsr.w   #4,D4
                and.w   #%111,D0
                and.w   #%111,D4
                cmp.w   D4,D0
                beq.s   holle2a
                addq.w  #1,D4
holle2a:        move.w  D6,D0
                move.w  D2,D5
                lsr.w   #8,D0
                lsr.w   #8,D5
                and.w   #%111,D0
                and.w   #%111,D5
                cmp.w   D5,D0
                beq.s   holle3a
                addq.w  #1,D5
holle3a:
                moveq   #0,D2
                move.b  D3,D2
                ror.w   #4,D2
                move.b  D4,D2
                ror.w   #4,D2
                move.b  D5,D2
                rol.w   #8,D2

rias1a:         move.w  D2,(A0)+
                dbra    D1,lepoa
                rts

                ENDPART

                >PART 'out'

fade_more:      moveq   #6,D0
mercy_2x:       move.w  D0,-(SP)
                moveq   #2,D0
                bsr.s   sync
                lea     insel_pal_0,A0
                bsr.s   fade_it_out
                lea     insel_pal_1,A0
                bsr.s   fade_it_out
                lea     insel_pal_2,A0
                bsr.s   fade_it_out
                move.w  (SP)+,D0
                dbra    D0,mercy_2x
                rts

fade_out:       moveq   #6,D0
mercy_2:        move.w  D0,-(SP)
                moveq   #3,D0
                bsr.s   sync
                movea.l main_pal,A0
                bsr.s   fade_it_out
                move.w  (SP)+,D0
                dbra    D0,mercy_2
                rts


fade_it_out:                            * a0= pal
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
wwait:          cmp.l   (A0),D1
                bne.s   wwait
                rts

                ENDPART

********* font *************

                >PART
prep_message:                           * a2= text
                lea     font_buffer,A0
                lea     font,A3

                moveq   #19,D2
repeat_char:
                move.b  (A2)+,D0
                ext.w   D0
                cmp.w   #' ',D0
                bne.s   no_space
                moveq   #0,D0
                bra.s   fertig

no_space:       subi.w  #$40,D0

fertig:         asl.w   #5,D0
                move.w  D0,D1
                add.w   D0,D0
                add.w   D1,D0

                movea.l A3,A1
                adda.w  D0,A1

                bsr.s   copy_char

                addq.l  #6,A0

                dbra    D2,repeat_char

                rts

copy_char:                              * a0=screen a1=data
                movea.l A0,A4
                moveq   #15,D0
copy:           move.l  (A1)+,(A4)
                move.w  (A1)+,4(A4)
                lea     120(A4),A4
                dbra    D0,copy
                rts

                ENDPART

********* things in general*******

                >PART

clear_bss:      lea     bss_start,A0
                lea     bss_end,A1
cherry:         clr.b   (A0)+
                cmpa.l  A0,A1
                bne.s   cherry
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

*                bsr.s   clear_bss

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
                lea     screen,A1
                move.l  A0,D0
                clr.b   D0
                move.l  D0,(A1)+

                lsr.l   #8,D0
                move.b  D0,$FFFF8203.w
                lsr.w   #8,D0
                move.b  D0,$FFFF8201.w
                bsr.s   vsync
                move.b  #0,$FFFF8260.w

                bsr.s   vsync

                moveq   #$12,D0         + Maus aus
                bsr.s   send_ikbd
                bsr.s   vsync

                move.b  #2,$FFFF820A.w  ; 50 Hz

                bsr.s   vsync

                bsr.s   init_mfp

                rts

restore_system:

                bsr     restore_mfp
                move.l  #sync_vbl,$70.w ; zum synchronisieren

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
                movep.w D0,0(A0)        +old screen

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
                move.l  #start_vbl,$70.w
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

                PART
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


************* vbl's *************

start_vbl:      clr.b   $FFFFFA1B.w
                addq.l  #1,vbl_timer
                rte

my_vbl:         clr.b   $FFFFFA1B.w
                move.b  #6,$FFFFFA21.w
                move.b  #8,$FFFFFA1B.w
                move.l  #set_main,$0120.w
                move.b  #-1,raster_wait
                movem.l D0-D6/A0-A4,-(SP)

                bsr     mod_player+12

                movem.l (SP)+,D0-D6/A0-A4
                addq.l  #1,vbl_timer
                rte

last_vbl:       clr.b   $FFFFFA1B.w
                movem.l D0-D6/A0-A4,-(SP)

                movem.l leisten_pal,D0-D6/A0
                movem.l D0-D6/A0,$FFFF8240.w

*               bsr     mod_player+12

                movem.l (SP)+,D0-D6/A0-A4
                addq.l  #1,vbl_timer
                rte

*********** raster ***********

set_main:
                clr.b   $FFFFFA1B.w
                move.b  next_distance,$FFFFFA21.w
                move.b  #8,$FFFFFA1B.w

                move.l  A0,-(SP)
                movea.l main_pal,A0
                move.l  (A0)+,$FFFF8242.w
                move.l  (A0)+,$FFFF8242+4.w
                move.l  (A0)+,$FFFF8242+8.w
                move.l  (A0)+,$FFFF8242+12.w
                move.l  (A0)+,$FFFF8242+16.w
                move.l  (A0)+,$FFFF8242+20.w
                move.l  (A0)+,$FFFF8242+24.w
                move.w  (A0)+,$FFFF8242+28.w
                movea.l (SP)+,A0
                move.l  next_raster,$0120.w

                rte

insel_time_1:   clr.b   $FFFFFA1B.w
                move.b  #20,$FFFFFA21.w
                move.b  #8,$FFFFFA1B.w
                pea     (A0)
                move.w  D0,-(SP)
                lea     $FFFFFA21.w,A0
                move.b  (A0),D0
wait_insel_1:   cmp.b   (A0),D0
                beq.s   wait_insel_1
                move    #$2700,SR
                move.w  (SP)+,D0

                lea     insel_pal_1,A0
                move.l  (A0)+,$FFFF8242.w
                move.l  (A0)+,$FFFF8242+4.w
                move.l  (A0)+,$FFFF8242+8.w
                move.l  (A0)+,$FFFF8242+12.w
                move.l  (A0)+,$FFFF8242+16.w
                move.l  (A0)+,$FFFF8242+20.w
                move.l  (A0)+,$FFFF8242+24.w
                move.w  (A0)+,$FFFF8242+28.w
                movea.l (SP)+,A0
                move.l  #insel_time_2,$0120.w
                rte

insel_time_2:   clr.b   $FFFFFA1B.w
                move.b  #36,$FFFFFA21.w
                move.b  #8,$FFFFFA1B.w
                pea     (A0)
                move.w  D0,-(SP)
                lea     $FFFFFA21.w,A0
                move.b  (A0),D0
wait_insel_2:   cmp.b   (A0),D0
                beq.s   wait_insel_2
                move    #$2700,SR
                move.w  (SP)+,D0

                lea     insel_pal_2,A0
                move.l  (A0)+,$FFFF8242.w
                move.l  (A0)+,$FFFF8242+4.w
                move.l  (A0)+,$FFFF8242+8.w
                move.l  (A0)+,$FFFF8242+12.w
                move.l  (A0)+,$FFFF8242+16.w
                move.l  (A0)+,$FFFF8242+20.w
                move.l  (A0)+,$FFFF8242+24.w
                move.w  (A0)+,$FFFF8242+28.w
                movea.l (SP)+,A0
                move.l  #set_font,$0120.w
                rte

set_font:       clr.b   $FFFFFA1B.w
                move.b  last_distance,$FFFFFA21.w
                move.b  #8,$FFFFFA1B.w

                move.l  A0,-(SP)
                lea     font_pal,A0
                move.l  (A0)+,$FFFF8242.w
                move.l  (A0)+,$FFFF8242+4.w
                move.l  (A0)+,$FFFF8242+8.w
                move.w  (A0)+,$FFFF8242+12.w
                movea.l (SP)+,A0

                move.l  #set_leiste,$0120.w

                rte

set_leiste:
                clr.b   $FFFFFA1B.w

                clr.w   $FFFF8240.w

                move.l  A0,-(SP)
                lea     leisten_pal+2,A0
                move.l  (A0)+,$FFFF8242.w
                move.l  (A0)+,$FFFF8242+4.w
                move.l  (A0)+,$FFFF8242+8.w
                move.l  (A0)+,$FFFF8242+12.w
                move.l  (A0)+,$FFFF8242+16.w
                move.l  (A0)+,$FFFF8242+20.w
                move.l  (A0)+,$FFFF8242+24.w
                move.w  (A0)+,$FFFF8242+28.w
                movea.l (SP)+,A0

                clr.b   raster_wait

                rte


                ENDPART

***************** NINJA III MOD-REPLAYER SYSTEM ****************

                >PART 'Tracker Erkl„rungen'
;************************************
; MOD_PLAYER INIT :
;bsr MOD_PLAYER
;ben”tigte Werte
;a0 = Adresse dec Moduls (unkompaktet!)

;d0 = Frequenz in Hertz                  min.4 Khz max. je nach Rechner
;d1 = Soundmode                          (0-4)
;                                         0 = mit Volume / 7-Bit-Qualit„t
;                                         1 = mit Volume / 8-Bit-Qualit„t
;                                         2 = ohne Volume (immer 8 Bit)
;                                         3 = STE/TT/F030 mit Volume
;                                         4 = STE/TT/F030 ohne Volume
; FALCON030 nur Modus 3/4
;d2 = Nr. des wegzulassenden Tracks      (1-4 oder 0) nur bei ST-Mode
;
; Return-werte
;d0 = gesetzte Abspielfrequenz
;************************************
; MOD_PLAYER PLAY
;bsr MOD_PLAYER+4       Startet die Interrupts
;
;bsr MOD_PLAYER+12
; muž alle 1/50 Sekunde aufgerufen werden
;************************************
; MOD_PLAYER EXIT
+bsr MOD_PLAY+8
; der Modplayer rettet alle ben”tigten Hardware Register bei INIT
; und setzt alle wieder zurck bei EXIT
;************************************
; Allgemeines
; benutzte Register
; ST        a5/a6/d7
; ab STe       alle Register frei
;
; benutzte Timer und Hardware Register
; immer
;           MFP im AOI-Modus (keine L”schung des Interrupt_in_Service_A/B
;           Register n”tig. bclr #4,$fffffa11.w z.B. fr Timer D)
; ST
;           Timer D / Sound Chip

                ENDPART

                >PART 'der Tracker' ;oder was von ihm brig ist

;d0 = Frequenz in Hertz
;d1 = Soundmode (0-4)
;d2 = Nr. des wgzulassenden Tracks (1-4 oder 0)

cm_zusatz       EQU 900

mod_player:
                bra     cm_init         ;+ 0
                bra     cm_start        ;+ 4
                bra     cm_start        ;+ 8
                bra     cm_vbl_         ;+12

cm_vols:        DS.W 4          ;+16 Werte fr VU-Meter
cm_songp:       DS.W 1          ;+24 Position im Song
cm_patpos:      DS.W 1          ;+26 Position im akt. Pattern
cm_abblend:     DS.W 1          ;+28 Abblendspeed
cm_volsub:      DS.W 1          ;+30 akt. Abblendst„rke
cm_maschine:    DS.W 1          ;+32 welche Maschine wurde gefunden
;          0=ST 2= STe 4= MSTe 6=TT 8=F030
cm_lmcwerte:    DC.W 40,20,20,6,6,1 ;+34 Werte fr den LMC
;           1.Main vol 2.Left Vol 3.Right Vol. 4.Treble 5.Bass


                DS.B 256        ;Raum fr's Verschieben an Pagegrenze
cm_volume:      DS.B 16640
                ENDPART
;----------------------------------------

                >PART 'Init Allgemein'

cm_init:
                lea     cm_module_adr(PC),A6 ;Moduladresse sichern
                move.l  A0,(A6)
;------------
                cmpi.w  #3,D1           ;STe - Modus?
                blt.s   cm_i0_jp1       ;==> nein

                subq.w  #2,D1           ;jetzt auch nicht mehr
cm_i0_jp1:
                lea     cm_soundmode(PC),A6 ;Sound Modus sichern
                move.w  D1,(A6)
;------------
                lea     cm_volflag(PC),A6
                st      (A6)
                cmpi.w  #2,D1           ;Soundmode 2 und 4 sind ohne
                beq.s   cm_i0_jp2       ;Volume
                cmpi.w  #4,D1
                bne.s   cm_i0_jp3
cm_i0_jp2:
                sf      (A6)
cm_i0_jp3:
;------------
                andi.w  #$07,D2         ;Nr. des abgeschalteden Kanals in D2

                cmpi.b  #4,D2           ;keiner ?
                beq.s   cm_i0_jp4       ;==> Ja

                andi.w  #$03,D2         ;Bis jetzt nur 4 Kan„le (0..3)
cm_i0_jp4:
                lea     cm_chanflag(PC),A6 ;sichern
                move.w  D2,(A6)
;------------
                lea     cm_normalst(PC),A1
;move.w  CM_CHANFLAG(PC),D2
                moveq   #4-1,D7
cm_kapploop:
                subq.w  #1,D2
                bne.s   cm_nop

                move.w  #$6000+(cm_normalst1-cm_normalst-2),(A1) ;bra.s *+10
                bra.s   cm_loopend
cm_nop:
                move.w  #$4E71,(A1)     ;nop
cm_loopend:
                lea     cm_normalst1-cm_normalst(A1),A1
                dbra    D7,cm_kapploop
;------------
                andi.l  #$FFFF,D0       ;nur Wortbreite !
                cmp.w   #4000,D0        ;mindest Frequenz
                bcc.s   cm_freq_jp1
                move.w  #4000,D0
cm_freq_jp1:
;------------
                cmp.w   #21000,D0       ;maximal Frequenz
                bls.s   cm_freq_jp2

                move.w  #21000,D0
cm_freq_jp2:
;------------
                move.l  #614400,D5      ;2.4576MHz / 4 ( 4 = Vorteiler im MfP)
                move.l  #12288,D4       ; 614400 / 50Hz VBl
                divu    D0,D5           ; 614400 / Frequenz
                divu    D5,D4           ;frq_loop=12288/frq_data

                lea     cm_timerwert(PC),A6
                move.w  D5,(A6)
                move.w  D4,cm_anzahl-cm_timerwert(A6) ; Gr”že des Play-Buffers
                move.w  D0,cm_frequenz-cm_timerwert(A6) ;eingestellter Frequenzwert
;------------
                bsr.s   cm_calc_period_table
                bsr.s   cm_prepare_soundtab
                bsr     cm_init_module
                rts

                ENDPART
                >PART 'Kalkuliere Periodentabelle'
cm_calc_period_table:
                moveq   #0,D0           ;Periodentabelle aus Frequenz berechnen
                move.w  cm_timerwert(PC),D0
                lea     cm_frq+4(PC),A1
                lea     cm_frq1(PC),A0
                move.w  #906,D6
cm_tabloop:
                move.l  (A0)+,D1
                move.l  D1,D2
                swap    D2
                mulu    D0,D1           ;Low word
                mulu    D0,D2           ;Hi word
                move.l  D1,D3
                swap    D3
                add.w   D2,D3
                swap    D3
                lsr.l   #8,D3
                move.l  D3,(A1)+
                dbra    D6,cm_tabloop
                rts
                ENDPART
                >PART 'Prepariere Sound Tabelle'
;---------------------------------
cm_prepare_soundtab:
                lea     cm_supersound(PC),A0
                lea     cm_sound(PC),A1
                move.w  cm_chanflag(PC),D2

                move.w  #319,D3
                tst.w   D2              ;alle Kan„le ?
                beq.s   cm_alle4        ;==> Ja

                move.w  #255,D3
cm_alle4:
;-
                move.w  D3,D7
                move.w  (A0),D0
cm_l1:
                bsr.s   cm_mutier       ;Randbereiche voller Ausschlag
                dbra    D7,cm_l1
;-
                moveq   #0,D4
                move.w  #255,D7
cm_l2:          move.w  (A0)+,D0
                bsr.s   cm_mutier

                tst.w   D2              ; bei 4 Stimmen, die Soundtab
                bne.s   cm_nurdrei      ; auf 1.5-fache L„nge

                not.w   D4              ; ausdehnen.
                beq.s   cm_nurdrei      ; (klingt besser)

                bsr.s   cm_mutier
cm_nurdrei:
                dbra    D7,cm_l2
;-
                move.w  D3,D7
                move.w  -2(A0),D0
cm_l3:
                bsr.s   cm_mutier       ;Randbereiche voller Ausschlag
                dbra    D7,cm_l3
;---------------------------------------- Code frs Kanalkappen modifizieren

                rts
cm_mutier:
                move.b  #8,(A1)
                move.b  #9,2(A1)
                move.b  #10,4(A1)

                move.w  D0,D1
                andi.w  #$0F,D1
                move.b  D1,6(A1)

                move.w  D0,D1
                lsr.w   #4,D1
                andi.w  #$0F,D1
                move.b  D1,3(A1)

                move.w  D0,D1
                lsr.w   #8,D1
                andi.w  #$0F,D1
                move.b  D1,1(A1)

                addq.w  #8,A1
                rts
                ENDPART
                >PART 'Init Module'
cm_init_module:
                movea.l cm_module_adr(PC),A0
                lea     cm_offset(PC),A1
;                                         Old Soundtracker Module
                move.w  #$01D8,cm_pos(A1)
                move.w  #$0258,cm_patt(A1)
                move.w  #$0F,cm_nbr(A1)

                cmpi.l  #'FLT4',$0438(A0)
                beq.s   cm_gotem
                cmpi.l  #'M.K.',$0438(A0)
                bne.s   cm_old_one
cm_gotem:                               ;Noisetracker/Protracker Module
                move.w  #$03B8,cm_pos(A1)
                move.w  #$043C,cm_patt(A1)

                move.w  #$1F,cm_nbr(A1)
cm_old_one:
;------------                             berechne Patternanzahl
;movea.l CM_MODULE_ADR(PC),A0
;lea     CM_OFFSET(PC),A1
                adda.w  cm_pos(A1),A0
                moveq   #128-1,D0
                moveq   #0,D1
cm_loop1:
                move.l  D1,D2
                subq.w  #1,D0
cm_loop2:
                move.b  (A0)+,D1
                cmp.b   D2,D1
                bgt.s   cm_loop1
                dbra    D0,cm_loop2
;-------------
                addq.b  #1,D2
                swap    D2
                lsr.l   #6,D2           ;Patternanjahl mal Patternl„nge *1024
;-------------
                movea.l cm_module_adr(PC),A0
;lea     CM_OFFSET(PC),A1
                add.l   A0,D2
                movea.l D2,A2
                lea     20(A0),A0

                move.w  cm_nbr(A1),D7   ;Max. Anzahl Instrumente
                subq.w  #1,D7           ;-1 wegen dbf
                adda.w  cm_patt(A1),A2
                movea.l A2,A3
                movea.l A2,A4
cm_count_ins:                           ;benutzte Instrumente z„hlen
                moveq   #0,D0
                move.w  22(A0),D0       ;L„nge = 0?
                beq.s   cm_nulltrument  ;ja, dann kein neues Instrument

                cmpi.w  #1,28(A0)       ;Repeatl„nge in Words
                bne.s   cm_roger

                clr.w   28(A0)
cm_roger:
                add.l   D0,D0           ;L„nge in Bytes
                adda.l  D0,A3
                adda.l  D0,A4
                lea     cm_zusatz(A4),A4 ;plus Zusatz
cm_nulltrument:
                lea     30(A0),A0       ;n„chstes Instrument
                dbra    D7,cm_count_ins
;-----------------------------------------
                move.w  #$FEFE,D4
                move.w  #$8080,D5
                move.w  cm_soundmode(PC),D7
                bne.s   cm_do_it_2
cm_do_it:
                move.w  -(A3),D3        ;Instrumente nach hinten verschieben
                eor.w   D5,D3           ;AMIGA-->ST
                and.w   D4,D3           ;und begradigen (7 Bit)
                move.w  D3,-(A4)
                cmpa.l  A2,A3
                bne.s   cm_do_it

                bra.s   cm_fettig
cm_do_it_2:
                move.w  -(A3),D3        ;Instrumente nach hinten verschieben
                eor.w   D5,D3           ;AMIGA-->ST
                move.w  D3,-(A4)        ;(8 Bit)
                cmpa.l  A2,A3
                bne.s   cm_do_it_2
cm_fettig:
;-----------------------------------------
                movea.l cm_module_adr(PC),A0
                lea     20(A0),A0
                lea     cm_samplestarts(PC),A5
                move.w  cm_nbr(A1),D7
                move.w  D7,D6
                subq.w  #1,D7
cm_mutate_sample:
                move.l  A4,D4           ;Anfang merken
                moveq   #0,D3
                move.w  22(A0),D3       ;L„nge
                add.l   D3,D3
                bne.s   cm_weidder

                clr.l   (A5)
                clr.l   4(A5)
                clr.l   8(A5)
                clr.l   12(A5)
                bra     cm_no_sample
cm_weidder:
                moveq   #0,D1
                move.w  28(A0),D1       ;replen
                beq.s   cm_norep        ;nein, dann normales Sample
                add.l   D1,D1
                moveq   #0,D0
                move.w  26(A0),D0       ;Repeatoffset = Samplel„nge

                cmpi.w  #$0F,D6
                beq.s   cm_weidd2

                add.l   D0,D0           ;neue Tracker, dann mal 2
cm_weidd2:
                add.l   D1,D0
                bra.s   cm_fuckitnow
cm_norep:
                move.l  D3,D0           ;L„nge nach d0
cm_fuckitnow:
                move.l  A3,(A5)         ;Anf. adr.
                move.l  D0,4(A5)        ;L„nge in Bytes
                clr.b   8(A5)
                move.b  25(A0),9(A5)    ;Volume
                moveq   #0,D1
                move.w  28(A0),D1       ;L„nge des Repeat
                add.l   D1,D1
                move.l  D1,10(A5)
                move.b  24(A0),D2       ;Finetune
                andi.w  #$0F,D2
                mulu    #36*2,D2        ;mal Paketl„nge (Tabelle)
                move.w  D2,14(A5)

                tst.l   D1              ;Repeat?
                bne.s   cm_make_repeat  ;nein

                subq.l  #1,D0           ;L„nge minus 1 (dbf)
cm_sampleloop:
                move.b  (A4)+,(A3)+     ;Sample verschieben
                dbra    D0,cm_sampleloop

                move.w  #cm_zusatz-1,D2
cm_null_loop:
                move.b  #$80,(A3)+      ;Null-Level-Bytes anh„ngen
                dbra    D2,cm_null_loop

                bra.s   cm_no_sample
cm_make_repeat:
                moveq   #0,D2
                move.w  26(A0),D2       ;Repeatoffset
                cmpi.w  #$0F,D6
                beq.s   cm_weiter

                add.l   D2,D2           ;neue Tracker, dann mal 2
cm_weiter:
                move.l  A4,D5
                add.l   D2,D5           ;Repstart berechnen

                add.l   D1,D2           ;plus replen
                subq.l  #1,D2           ;dbf
cm_sampleloop2:
                move.b  (A4)+,(A3)+
                dbra    D2,cm_sampleloop2

                move.w  #cm_zusatz,D2
cm_hep1:
                movea.l D5,A2           ;Repstart setzen
                move.w  D1,D3
                subq.w  #1,D3
cm_hep2:
                move.b  (A2)+,(A3)+
                subq.w  #1,D2
                beq.s   cm_no_sample

                dbra    D3,cm_hep2
                bra.s   cm_hep1
cm_no_sample:
                movea.l D4,A4
                moveq   #0,D0
                move.w  22(A0),D0       ;Samplelen
                add.w   D0,D0
                adda.l  D0,A4
                lea     16(A5),A5
                lea     30(A0),A0
                dbra    D7,cm_mutate_sample
;------------------------------------------
                lea     cm_voltab(PC),A0
                lea     cm_voladr(PC),A2
                lea     cm_volume(PC),A1
                move.l  A1,D0
                clr.b   D0              ;Voltab auf Pagegrenze

                move.l  D0,(A2)
                movea.l D0,A1
                moveq   #64,D5          ;Voltab generieren (65*256 Bytes)

cm_vloop2:
                movem.w (A0)+,D0-D3
                move.w  #255,D6
cm_vloop1:
                move.b  D0,(A1)+
                add.w   D3,D1           ;Nachkomma
                addx.w  D2,D0           ;Vorkomma
                dbra    D6,cm_vloop1
                dbra    D5,cm_vloop2
;--------------------------------------------
                movea.l cm_voladr(PC),A0
                move.w  cm_soundmode(PC),D7
                bne.s   cm_check_ste

                move.w  #8320-1,D0
cm_prepare_volume:
                moveq   #0,D1
                move.b  (A0),D1
                lsl.w   #3,D1           ; 7-Bit-Mutation fr mehr Cpeed
                move.w  D1,(A0)+
                dbra    D0,cm_prepare_volume
cm_check_ste:
;----------------------------------------
                move.w  cm_soundmode(PC),D7
                cmpi.w  #3,D7
                blt.s   cm_modify

                move.w  #8320-1,D0
cm_prepvol2:
                move.b  (A0),D1
                eori.b  #$80,D1
                asr.b   #1,D1
                move.b  D1,(A0)+

                move.b  (A0),D1
                eori.b  #$80,D1
                asr.b   #1,D1
                move.b  D1,(A0)+

                dbra    D0,cm_prepvol2
cm_modify:
;----------------------------------------
                move.w  cm_volflag(PC),D7
                bne.s   cm_nixanpass

                lea     cm_samplestarts(PC),A5 ;Samplevolumes anpassen
                movea.l cm_voladr(PC),A4
                lea     cm_offset(PC),A1
                move.w  cm_nbr(A1),D7
                subq.w  #1,D7
cm_volumeloop:
                move.l  (A5),D0         ;anf adr
                beq.s   cm_next

                movea.l D0,A0
                move.l  4(A5),D6        ;L„nge
                addi.l  #cm_zusatz,D6   ;plus Zusatz
                move.w  8(A5),D4        ;Volume

                lsl.w   #8,D4           ;mal 256
cm_transloop:
                move.b  (A0),D4
                move.b  0(A4,D4.w),(A0)+
                subq.l  #1,D6
                bne.s   cm_transloop
cm_next:
                lea     16(A5),A5
                dbra    D7,cm_volumeloop
cm_nixanpass:
;---------------------------------------------
                lea     cm_offset(PC),A0
                move.b  #$06,cm_speed(A0)
                clr.b   cm_songpos(A0)
                clr.b   cm_counter(A0)
                clr.w   cm_pattpos(A0)

                lea     cm_swap(PC),A2

                lea     cm_digipuffer(PC),A3
                move.l  A3,4(A2)        ;Buffer 2
                lea     (cm_digipuffer1-cm_digipuffer)/2(A3),A3
                move.l  A3,(A2)         ;Buffer 1
;--------------------------------------------- Soundoptions adressieren
                lea     cm_options(PC),A5
                move.w  cm_soundmode(PC),D0
                lsl.w   #4,D0           ;*16 Bytes pro Tabelleneintrag
                lea     0(A5,D0.w),A4

                movea.l A5,A0           ;TD-Interrupt-Adr.
                adda.w  8(A4),A0        ;berechnen

                lea     cm_playadr(PC),A2 ;Abspieladresse (-1 = keine)
                move.l  A0,(A2)
;---------------------------------------------
                move.w  10(A4),D1       ;Fllwert holen
                move.w  cm_chanflag(PC),D0 ;welcher Kanal soll nicht?
                beq.s   cm_fill

                mulu    #3,D1           ;mal 3/4 , falls nur 3 Stimmen
                lsr.w   #2,D1
cm_fill:
                lea     cm_digipuffer(PC),A3
                move.w  #(cm_digipuffer1-cm_digipuffer)/(4*2)-1,D0
cm_fillbuff:
                move.w  D1,(A3)+        ;Puffer fllen
                move.w  D1,(A3)+
                move.w  D1,(A3)+
                move.w  D1,(A3)+
                dbra    D0,cm_fillbuff
;-------------------                     Mixcode erzeugen
                move.w  cm_anzahl(PC),D0 ;Bufferl„nge
                movea.l A5,A0           ;CM_OPTIONS
                adda.w  (A4),A0         ;Beginn
                movea.l A0,A2
                movea.l A5,A3
                adda.w  2(A4),A3        ;Ende

                lea     cm_codepuff1(PC),A1
                bsr.s   cm_copy         ;kopieren
;------------
                move.w  cm_anzahl(PC),D0 ;Bufferl„nge
                movea.l A5,A0           ;CM_OPTIONS
                adda.w  4(A4),A0        ;Beginn
                movea.l A0,A2
                movea.l A5,A3
                adda.w  6(A4),A3        ;Ende

                lea     cm_codepuff1(PC),A1
                lea     cm_codepuff2-cm_codepuff1(A1),A1
;lea     CM_CODEPUFF2(PC),A1
                bsr.s   cm_copy
;------------
                lea     cm_channels(PC),A0
                lea     cm_null(PC),A2
                move.w  12(A4),(A2)     ;Nullsamplewert aus Tabelle

                lea     cm_sounddatas(PC),A3
                moveq   #0,D1
                moveq   #0,D2
                moveq   #0,D3
                moveq   #0,D4

                moveq   #4-1,D0
cm_clear_channels:
                move.l  A2,(A0)
                move.l  D1,4(A0)
                move.l  A2,8(A0)
                movem.l D1-D4,12(A0)
                clr.w   28(A0)
                lea     cm_chlen(A0),A0

                movem.l D1-D3,(A3)
                lea     cm_sdatlen(A3),A3

                dbra    D0,cm_clear_channels
;------------
                lea     cm_vols(PC),A0  ;VU-Meter auf Null
                clr.l   (A0)+
                clr.l   (A0)+
                clr.l   (A0)+           ;Songpos und Patpos auf null
                clr.l   (A0)            ;Abblendspeed u. -st„rke auf null

                lea     cm_volcount(PC),A0
                clr.w   (A0)            ;Volcount auf null

                lea     cm_volsub(PC),A0
                move.w  #$40,(A0)       ;Basislautst„rke

                lea     cm_offset(PC),A0
                st      cm_lowmask(A0)
                rts
cm_copy:
                move.w  (A0)+,(A1)+     ;kopiere von Anfang bis Ende
                cmpa.l  A3,A0
                bne.s   cm_copy

                movea.l A2,A0
                dbra    D0,cm_copy      ;Anzahl mal

                move.w  #$4E75,(A1)     ;RTS
                rts
                ENDPART
;----------------------------------------
                >PART 'Start Allgemein'
cm_start:
                move    SR,-(SP)
                move    #$2700,SR

                lea     $FFFF8800.w,A5  ;Soundchip auf D/A-Betrieb
                lea     snd_tab(PC),A0
cm_clear_yamaha:
                tst.b   (A0)
                bmi.s   cm_clear_yamaha_ex

                move.b  (A0)+,(A5)      ;setze Register
                move.b  (A0)+,2(A5)     ;l”sche Eintrag
                bra.s   cm_clear_yamaha
cm_clear_yamaha_ex:
;------------
                movea.l cm_swap(PC),A6  ;This is important too!!!
                andi.b  #$F0,$FFFFFA1D.w ;Timer D stop
                ori.b   #$01,$FFFFFA1D.w ;Timer D Vorteiler auf 1:4

                move.b  cm_timerwert+1(PC),$FFFFFA25.w ;tddr
                move.l  cm_playadr(PC),$0110.w ;Timer D Vektor

                moveq   #4,D0
                bset    D0,$FFFFFA09.w  ;Timer D aktivieren (enable)
                bset    D0,$FFFFFA15.w  ;                   (mask  )
;------------
                bclr    #3,$FFFFFA17.w  ;Auto-EOI!

                move    (SP)+,SR
                rts
snd_tab:
                DC.W $0A00,$0900,$0800,$07FF
                DC.W $0600,$0500,$0400,$0300
                DC.W $0200,$0100,$00,$FFFF
                ENDPART

;----------------------------------------
                >PART 'VBL Allgemein'
cm_vbl_:
                lea     cm_swap(PC),A0
                move    SR,D0
                move    #$2700,SR

                movea.l 4(A0),A6        ;setze neue Buffer-Adresse
                move.l  (A0),4(A0)
                move.l  A6,(A0)

                move    D0,SR

                ENDPART

                >PART 'VBL Play'
cm_play:
                lea     cm_abblend(PC),A1 ;abblenden?
                move.w  (A1),D0
                beq.s   cm_nixabblend   ;nein

                lea     cm_volcount(PC),A2
                addq.w  #1,(A2)
                move.w  (A2),D0
                cmp.w   (A1),D0
                bne.s   cm_nixabblend

                clr.w   (A2)
                lea     cm_volsub(PC),A0
                subq.w  #1,(A0)
                bpl.s   cm_nixabblend

                clr.w   (A0)
cm_nixabblend:
                lea     cm_vols(PC),A0  ;VU-Meter absenken
                subq.w  #2,(A0)+
                bpl.s   cm_vu_abl0
                clr.w   -2(A0)
cm_vu_abl0:
                subq.w  #2,(A0)+
                bpl.s   cm_vu_abl1
                clr.w   -2(A0)
cm_vu_abl1:
                subq.w  #2,(A0)+
                bpl.s   cm_vu_abl2
                clr.w   -2(A0)
cm_vu_abl2:
                subq.w  #2,(A0)+
                bpl.s   cm_vu_abl3
                clr.w   -2(A0)
cm_vu_abl3:
;---------------------------
                bsr     cm_precalc_digit ;Digipuffer neu fllen
;---------------------------
                lea     cm_offset(PC),A3
                addq.b  #$01,cm_counter(A3)
                move.b  cm_counter(A3),D0
                cmp.b   cm_speed(A3),D0
                blt.s   cm_nonew

                clr.b   cm_counter(A3)
                bra.s   cm_read_pattern
cm_nonew:
                lea     cm_channels(PC),A2
                lea     cm_sounddatas(PC),A4
                bsr     cm_check_command
                REPT 3
                lea     cm_chlen(A2),A2
                lea     cm_sdatlen(A4),A4
                bsr     cm_check_command
                ENDR
                rts
;------------
cm_read_pattern:
                movea.l cm_module_adr(PC),A0
                movea.l A0,A2
                adda.w  cm_pos(A3),A2
                adda.w  cm_patt(A3),A0

                moveq   #0,D0
                moveq   #0,D1
                move.b  cm_songpos(A3),D0 ;Song pos holen

                move.b  0(A2,D0.w),D1   ;Pattern Nr.
                swap    D1              ;\
                lsr.l   #6,D1           ;/ mal Patternl„nge ($400)
                add.w   cm_pattpos(A3),D1

                lea     cm_channels(PC),A2
                lea     cm_sounddatas(PC),A4
                bsr.s   cm_playvoice
                REPT 3
                lea     cm_chlen(A2),A2
                lea     cm_sdatlen(A4),A4
                bsr.s   cm_playvoice
                ENDR
                bra     cm_end_of_calc
cm_playvoice:
                move.l  0(A0,D1.l),(A4) ;Trackzeile holen
                addq.l  #4,D1           ;n„chsten Track adressieren

                moveq   #0,D2
                move.b  2(A4),D2
                and.b   #$F0,D2
                lsr.b   #4,D2           ;  Instrument-Nummer
                move.b  (A4),D0         ;  berechnen
                and.b   #$F0,D0
                or.b    D0,D2

                tst.b   D2              ;kein Instrument?
                beq.s   cm_set_regs     ;ja, dann weiter


                cmp.w   cm_nbr(A3),D2   +Instr. Nr. zu grož?
                bhi     cm_check_command_2 ;ja, dann alles ignorieren

                lea     cm_samplestarts(PC),A1
                subq.w  #1,D2           ;Samplenummer-1
                lsl.w   #4,D2           ;mal 16
                adda.w  D2,A1
                move.l  (A1)+,D3        ;Instrument definiert?
                beq     cm_check_command_2 ;sonst alles ignorieren

                move.l  D3,(A2)         ;Act.Adr.=Startadr
                move.l  D3,8(A2)        ;Sampleadr.=Startadr

                move.l  (A1)+,D4        ;Len
                move.l  D4,12(A2)       ;Sample Length

                move.w  (A1)+,24(A2)    ;Volume
                add.l   D4,D3           ;Endadr

                move.l  (A1)+,D4        ;Replen
                sub.l   D4,D3           ;Endadr-Replen=Repadr

                move.l  D3,16(A2)       ;Repadr
                move.l  D4,20(A2)       ;Replen
                move.w  (A1)+,28(A2)    ;Finetune
cm_set_regs:
                move.w  (A4),D0         ;Periode holen
                and.w   #$0FFF,D0       ;neue Periode?
                beq     cm_check_command_2 ;nein

                move.b  2(A4),D0        ;Kommando
                and.w   #$0FF0,D0
                cmp.w   #$0E50,D0
                beq.s   cm_dosetfinetune

                move.b  2(A4),D0        ;Kommando
                and.b   #$0F,D0         ;ausmaskieren

                cmp.b   #3,D0
                beq.s   cm_chkportamento

                cmp.b   #5,D0
                beq.s   cm_chkportamento

                cmp.b   #9,D0
                bne.s   cm_setperiod

                bsr     cm_check_command_2 ;und weiter
                bra.s   cm_setperiod
cm_dosetfinetune:
                bsr     cm_setfinetune
                bra.s   cm_setperiod
cm_chkportamento:
                bsr     cm_set_portamento_tone
                bra     cm_check_command_2
cm_setperiod:
                clr.l   4(A2)           ;akt. Offset l”schen
                move.w  (A4),D0         ;Periode
                and.w   #$0FFF,D0       ;ausmaskieren

                move.w  28(A2),D3       ;Finetune?
                beq.s   cm_notune       ;nein

                lea     cm_periods(PC),A1 ;Finetune berechnen
                moveq   #36,D2
cm_findtune:
                cmp.w   (A1)+,D0
                dbcc    D2,cm_findtune

                move.w  -2(A1,D3.w),D0  ;getunte Periode holen...
cm_notune:
                move.w  D0,4(A4)        ;...und zweimal
                move.w  D0,26(A2)       ;merken

                move.w  2(A4),D0
                and.w   #$0FF0,D0
                cmp.w   #$0ED0,D0       ;Notedelay
                beq     cm_check_command_2

                btst    #2,16(A4)       ;Wavecontrol
                bne.s   cm_vibnoc
                clr.b   11(A4)
cm_vibnoc:
                btst    #6,16(A4)
                bne.s   cm_trenoc
                clr.b   15(A4)
cm_trenoc:
                bra     cm_check_command_2
;---------------------------------------------------
cm_end_of_calc:
                addi.w  #16,cm_pattpos(A3) ;n„chste Zeile im Pattern
                move.b  cm_pattdeltime(A3),D0
                beq.s   cm_dskc

                move.b  D0,cm_pattdeltime2(A3)
                clr.b   cm_pattdeltime(A3)
cm_dskc:
                tst.b   cm_pattdeltime2(A3)
                beq.s   cm_dska

                subq.b  #1,cm_pattdeltime2(A3)
                beq.s   cm_dska

                subi.w  #16,cm_pattpos(A3)
cm_dska:
                tst.b   cm_breakflag(A3)
                beq.s   cm_nnpysk

                sf      cm_breakflag(A3)

                moveq   #0,D0
                move.b  cm_breakpos(A3),D0
                clr.b   cm_breakpos(A3)
                lsl.w   #4,D0
                move.w  D0,cm_pattpos(A3)
cm_nnpysk:
                cmpi.w  #$0400,cm_pattpos(A3) ;Ende erreicht?
                blo.s   cm_end_of_player ;nein, dann Ende
cm_next_patt:
                moveq   #0,D0
                move.b  cm_breakpos(A3),D0
                lsl.w   #4,D0
                move.w  D0,cm_pattpos(A3)
                clr.b   cm_breakpos(A3)

                clr.b   cm_posjumpflag(A3) ;Break-Flag l”schen


                addq.b  #1,cm_songpos(A3) ;weiter im Song
                andi.b  #$7F,cm_songpos(A3)

                move.b  cm_songpos(A3),D1
                movea.l cm_module_adr(PC),A1
                adda.w  cm_pos(A3),A1
                cmp.b   -2(A1),D1       ;Songende erreicht??
                bne.s   cm_end_of_player ;nein

                move.b  -1(A1),D1       ;Restart vorhanden?
                cmp.b   -2(A1),D1
                bhs.s   cm_begin

                move.b  D1,cm_songpos(A3)
                bra.s   cm_end_of_player
cm_begin:
                clr.b   cm_songpos(A3)
cm_end_of_player:
                tst.b   cm_posjumpflag(A3) ;Pattern-Break?
                bne.s   cm_next_patt    ;ja
;---------------------------------------------- Songpos und Pattpos fr User
                lea     cm_songp+1(PC),A0 ;     zug„nglich machen...
                move.b  cm_songpos(A3),(A0)+
                move.w  cm_pattpos(A3),D0
                lsr.w   #4,D0           ;/16
                move.w  D0,(A0)
;---------------------------------------------- VU-Meter?
                lea     cm_vols(PC),A0
                lea     cm_sounddatas(PC),A1
                lea     cm_channels(PC),A2
                move.l  #$FFFFF000,D1
                bsr.s   cm_calc_vu
                bsr.s   cm_calc_vu
                bsr     cm_calc_vu
cm_calc_vu:
                move.l  (A1),D2
                and.l   D1,D2
                beq.s   cm_absenk

                move.w  24(A2),D0
                and.w   #$FE,D0
                move.w  D0,(A0)
cm_absenk:
                addq.w  #2,A0
                lea     cm_sdatlen(A1),A1
                lea     cm_chlen(A2),A2
                rts
                ENDPART
;----------------------------------------------------
                >PART 'CM_CHECK_COMMAND'
;Kommandos, die jede 1/50 Sek. ausgefhrt werden mssen,
;ohne daž eine neue Patternzeile gelesen wurde

cm_check_command:
                bsr     cm_updatefunk

                move.w  2(A4),D0
                and.w   #$0FFF,D0
                beq.s   cm_no           ;==> Exit

                move.b  2(A4),D0
                and.w   #$0F,D0
                add.w   D0,D0
                move.w  cm_cmds(PC,D0.w),D0
                jmp     cm_cmds(PC,D0.w)
cm_no:          rts

;Sprungtabelle fr Kommandos (pc-relativ)
                BASE DC.W,cm_cmds
cm_cmds:
                DC.W cm_arp,cm_prt_up,cm_prt_down ;          0,1,2
                DC.W cm_portamento_tone,cm_vibrato ;         3,4
                DC.W cm_toneandvolslide,cm_vibandvolslide ;  5,6
                DC.W cm_tremolo,cm_no,cm_no ;               7,8,9
                DC.W cm_volume_slide,cm_no,cm_no ;           a,b,c
                DC.W cm_no,cm_extended_cmd,cm_no ;           d,e,f
                BASE DC.W,OFF
                ENDPART
;------------
                >PART 'CM_ARP'
cm_arp:
                moveq   #0,D0
                move.b  cm_counter(A3),D0
                divu    #3,D0
                swap    D0              ;Counter modulo 3

                cmp.w   #$00,D0         ;(qw tst.w)
                beq.s   cm_arp2

                cmp.w   #$02,D0
                beq.s   cm_arp1

                moveq   #0,D0
                move.b  3(A4),D0        ;Offset 2. Note
                lsr.b   #4,D0
                bra.s   cm_arp3
cm_arp1:
                moveq   #0,D0
                move.b  3(A4),D0        ;Offset 3. Note
                and.b   #$0F,D0
                bra.s   cm_arp3
cm_arp2:
                move.w  4(A4),D2        ;Periode
                bra.s   cm_arp4
cm_arp3:
                add.w   D0,D0           ;Offset mal 2 (.W-Tabelle)
                moveq   #0,D6
                move.w  4(A4),D6
                lea     cm_periods(PC),A1 ;Periodentabelle
                adda.w  28(A2),A1       ; plus Finetune-Paketoffset
                moveq   #36,D3
cm_arp_loop:
                cmp.w   (A1)+,D6        ;Ton suchen
                dbcc    D3,cm_arp_loop
                move.w  -2(A1,D0.w),D2  ;Ton plus Offset holen
cm_arp4:
                move.w  D2,26(A2)
                rts
                ENDPART
                >PART 'CM_PRT_UP'
cm_fine_prt_up:
                tst.b   cm_counter(A3)
                bne.s   cm_return2

                move.b  #$0F,cm_lowmask(A3)
cm_prt_up:
                moveq   #0,D0
                move.b  3(A4),D0
                and.b   cm_lowmask(A3),D0
                move.b  #$FF,cm_lowmask(A3)
                sub.w   D0,4(A4)
                move.w  4(A4),D0
                cmp.w   #113,D0
                bpl.s   cm_portupskip

                move.w  #113,D0
cm_portupskip:
                move.w  D0,26(A2)
cm_return2:
                rts
                ENDPART
                >PART 'CM_PRT_DOWN'
cm_fine_prt_down:
                tst.b   cm_counter(A3)
                bne.s   cm_return2

                move.b  #$0F,cm_lowmask(A3)
cm_prt_down:
                moveq   #0,D0
                move.b  3(A4),D0
                and.b   cm_lowmask(A3),D0

                move.b  #$FF,cm_lowmask(A3)
                add.w   D0,4(A4)
                move.w  4(A4),D0

                cmp.w   #856,D0
                bmi.s   cm_portdwnskip

                move.w  #856,D0
cm_portdwnskip:
                move.w  D0,26(A2)
                rts
                ENDPART
                >PART 'CM_PORTAMENTO_TONE'
cm_set_portamento_tone:
                move.w  (A4),D2         ;Zielperiode
                and.w   #$0FFF,D2       ;ausfiltern

                move.w  28(A2),D3       ;Finetune?
                beq.s   cm_notune2      ;nein

                lea     cm_periods(PC),A1 ;Finetune berechnen
                moveq   #36,D0
cm_findtune2:
                cmp.w   (A1)+,D2
                dbcc    D0,cm_findtune2

                move.w  -2(A1,D3.w),D2  ;getunte Periode holen...
cm_notune2:
                move.w  D2,8(A4)        ;merken
                move.w  4(A4),D0        ;akt. Periode
                clr.b   6(A4)           ;Richtung = up
                cmp.w   D0,D2           ;Ziel mit akt. vergleichen
                beq.s   cm_clr_port_tone ;gleich, dann Abbruch
                bge.s   cm_ok_rts       ;gr”žer gleich, dann fertig

                move.b  #1,6(A4)        ;sonst Richtung = down
                rts
cm_clr_port_tone:

                clr.w   8(A4)           ;Zielnote l”schen
cm_ok_rts:
                rts
;----------------------------------------
cm_portamento_tone:
                move.b  3(A4),D0
                beq.s   cm_my_slide

                move.b  D0,7(A4)
                clr.b   3(A4)
cm_my_slide:
                tst.w   8(A4)
                beq.s   cm_ok_rts

                moveq   #0,D0
                move.b  7(A4),D0
                tst.b   6(A4)
                bne.s   cm_tp_up

                add.w   D0,4(A4)        ;Tone-Portamento-down
                move.w  8(A4),D0
                cmp.w   4(A4),D0
                bgt.s   cm_setper

                move.w  D0,4(A4)
;move.w  8(A4),4(A4)
                clr.w   8(A4)
                bra.s   cm_setper
cm_tp_up:
                sub.w   D0,4(A4)
                move.w  8(A4),D0
                cmp.w   4(A4),D0
                blt.s   cm_setper

                move.w  D0,4(A4)
;move.w  8(A4),4(A4)
                clr.w   8(A4)
cm_setper:
                move.w  4(A4),D2
                move.b  17(A4),D0       ;Glisserando?
                and.b   #$0F,D0
                beq.s   cm_skipgliss

                moveq   #0,D0
                move.w  28(A2),D0       ;Finetune holen
                lea     cm_periods(PC),A1
                adda.w  D0,A1           ;und addieren
                moveq   #0,D0
cm_glissloop:                           ;Glisserando
                cmp.w   0(A1,D0.w),D2
                bhs.s   cm_glissfound

                addq.w  #2,D0
                cmp.w   #36*2,D0
                blo.s   cm_glissloop

                moveq   #35*2,D0
cm_glissfound:
                move.w  0(A1,D0.w),D2
cm_skipgliss:
                move.w  D2,26(A2)       ;Periode speichern
                rts
                ENDPART
                >PART 'CM_VIBRATO'
cm_vibrato:
                move.b  3(A4),D0
                beq.s   cm_vib

                move.b  10(A4),D2
                and.b   #$0F,D0
                beq.s   cm_vibskip

                and.b   #$F0,D2
                or.b    D0,D2
cm_vibskip:
                move.b  3(A4),D0
                and.b   #$F0,D0
                beq.s   vibskip2

                and.b   #$0F,D2
                or.b    D0,D2
vibskip2:
                move.b  D2,10(A4)

cm_vib:
                move.b  11(A4),D0       ;Vibratopos
                lea     cm_sinus(PC),A1
                lsr.w   #2,D0
                and.w   #$1F,D0
                moveq   #0,D2
                move.b  16(A4),D2       ;Wavecontrol
                and.b   #$03,D2
                beq.s   cm_sinusvib

                lsl.b   #3,D0

                cmp.b   #1,D2
                beq.s   cm_rampdownvib

                move.b  #$FF,D2
                bra.s   cm_vibset
cm_rampdownvib:
                tst.b   11(A4)
                bpl.s   cm_rampdown2

                move.b  #$FF,D2
                sub.b   D0,D2
                bra.s   cm_vibset
cm_rampdown2:
                move.b  D0,D2
                bra.s   cm_vibset
cm_sinusvib:
                move.b  0(A1,D0.w),D2
cm_vibset:
                move.b  10(A4),D0
                and.w   #$0F,D0
                mulu    D0,D2
                lsr.w   #7,D2
                move.w  4(A4),D0
                tst.b   11(A4)
                bmi.s   cm_vib_min

                add.w   D2,D0
                bra.s   cm_vib2
cm_vib_min:
                sub.w   D2,D0
cm_vib2:
                move.w  D0,26(A2)       ;neue Periode
                move.b  10(A4),D0
                lsr.w   #2,D0
                and.w   #$3C,D0
                add.b   D0,11(A4)
                rts
                ENDPART
                >PART 'CM_VOLUME_SLIDE'
cm_volume_slide:
                moveq   #0,D0
                move.b  $03(A4),D0
                lsr.b   #4,D0
                tst.b   D0
                beq.s   cm_voldown
cm_up2:
                add.w   D0,24(A2)
                cmpi.w  #$40,24(A2)
                ble.s   cm_volup_ok

                move.w  #$40,24(A2)
cm_volup_ok:
                rts
cm_voldown:
                move.b  3(A4),D0
                and.b   #$0F,D0
cm_down2:
                sub.w   D0,24(A2)
                bpl.s   cm_voldwn_ok

                clr.w   24(A2)
cm_voldwn_ok:
                rts
                ENDPART
+--------------------------
cm_toneandvolslide:                     ;Slide Volume and Portamento0
                bsr     cm_my_slide
                bra.s   cm_volume_slide
;--------------------------
cm_vibandvolslide:                      ;Slide Volume and keep vibratoing
                bsr     cm_vib
                bra.s   cm_volume_slide
;--------------------------
                >PART 'CM_TREMOLO'
cm_tremolo:
                move.b  3(A4),D0
                beq.s   cm_tre

                move.b  14(A4),D2
                and.b   #$0F,D0
                beq.s   cm_treskip

                and.b   #$F0,D2
                or.b    D0,D2
cm_treskip:
                move.b  3(A4),D0
                and.b   #$F0,D0
                beq.s   treskip2

                and.b   #$0F,D2
                or.b    D0,D2
treskip2:
                move.b  D2,14(A4)
cm_tre:
                move.b  15(A4),D0       ;Tremolopos
                lea     cm_sinus(PC),A1
                lsr.w   #2,D0
                and.w   #$1F,D0
                moveq   #0,D2
                move.b  16(A4),D2       ;Wavecontrol
                lsr.b   #4,D2
                and.b   #$03,D2
                beq.s   cm_sinustre

                lsl.b   #3,D0
                cmp.b   #1,D2
                beq.s   cm_rampdowntre

                move.b  #$FF,D2
                bra.s   cm_treset
cm_rampdowntre:
                tst.b   15(A4)
                bpl.s   cm_rampdown3

                move.b  #$FF,D2
                sub.b   D0,D2
                bra.s   cm_treset
cm_rampdown3:
                move.b  D0,D2
                bra.s   cm_treset
cm_sinustre:
                move.b  0(A1,D0.w),D2
cm_treset:
                move.b  14(A4),D0
                and.w   #$0F,D0
                mulu    D0,D2
                lsr.w   #6,D2
                move.w  24(A2),D0       ;get Volume
                tst.b   15(A4)
                bmi.s   cm_tre_min

                add.w   D2,D0
                bra.s   cm_tre2
cm_tre_min:
                sub.w   D2,D0
cm_tre2:
                bpl.s   cm_tremoloskip
                clr.w   D0
cm_tremoloskip:
                cmp.w   #$40,D0
                bls.s   cm_tremolo_ok

                moveq   #$40,D0
cm_tremolo_ok:
                move.w  D0,24(A2)       ;neues Volume
                move.b  14(A4),D0
                lsr.w   #2,D0
                and.w   #$3C,D0
                add.b   D0,15(A4)

                rts
                ENDPART
;----------------------------------------
                >PART 'CM_SAMPLEOFFSET'
cm_sampleoffset:
                moveq   #0,D0
                move.b  3(A4),D0
                beq.s   cm_nonewoffset

                lsl.w   #7,D0           ;128 (qw *256)
                move.w  D0,12(A4)
cm_nonewoffset:
                move.w  12(A4),D0
                cmp.l   12(A2),D0       ;mit L„nge vergleichen
                bge.s   cm_offsetskip   ;zu grož

                move.l  D0,4(A2)        ;Offset setzen
                rts
cm_offsetskip:
                move.l  12(A2),4(A2)    ;Offset = L„nge
                rts
                ENDPART
;------------------------------
                >PART 'CM_CHECK_COMMAND_2'
cm_check_command_2:
                bsr     cm_updatefunk

                move.b  2(A4),D0
                and.b   #$0F,D0
                beq.s   cm_fuckit

                add.w   D0,D0

                lea     cm_c1(PC),A1
                adda.w  0(A1,D0.w),A1
                jmp     (A1)
cm_fuckit:
                rts

                BASE DC.W,cm_c1
cm_c1:
                REPT 9
                DC.W cm_no
                ENDR
                DC.W cm_sampleoffset,cm_no,cm_position_jump
                DC.W cm_set_volume,cm_pattern_break
                DC.W cm_extended_cmd,cm_set_speed
                BASE DC.W,OFF
                ENDPART
;------------
                >PART 'CM_EXTEND_CMD'
cm_extended_cmd:
                move.b  3(A4),D0
                and.w   #$F0,D0
                lsr.w   #3,D0           ;durch 16 mal 2
                lea     cm_c2(PC),A1
                adda.w  0(A1,D0.w),A1
                jmp     (A1)
                BASE DC.W,cm_c2
cm_c2:
                DC.W cm_set_filter,cm_fine_prt_up,cm_fine_prt_down ;        0 1 2
                DC.W cm_setglisscontrol,cm_setvibratocontrol ;              3 4
                DC.W cm_setfinetune,cm_jumploop,cm_settremolocontrol,cm_no ;5 6 7 8
                DC.W cm_retrignote,cm_volumefineup,cm_volumefinedown ;      9 a b
                DC.W cm_notecut,cm_notedelay,cm_patterndelay ;              c d e
                DC.W cm_funkit  ;                              f
                BASE DC.W,OFF
                ENDPART
                >PART 'CM_SETGLISSCONTROL'
cm_setglisscontrol:
                move.b  3(A4),D0
                and.b   #$0F,D0
                andi.b  #$F0,17(A4)
                or.b    D0,17(A4)
                rts
                ENDPART
                >PART 'CM_SETVIBRATOCONTROL'
cm_setvibratocontrol:
                move.b  3(A4),D0
                andi.b  #$0F,D0
                andi.b  #$F0,16(A4)
                or.b    D0,16(A4)
                rts
                ENDPART
                >PART 'CM_SETTREMOLOCONTROL'
cm_settremolocontrol:
                illegal
                move.b  3(A4),D0
                andi.b  #$0F,D0
                lsl.b   #4,D0
                andi.b  #$0F,16(A4)
                or.b    D0,16(A4)
                rts
                ENDPART
                >PART 'CM_SETFINETUNE'
cm_setfinetune:
                move.b  3(A4),D0
                andi.w  #$0F,D0
                move.w  D0,D2
                lsl.w   #6,D0           ;mal 64
                lsl.w   #3,D2           ;mal 8
                add.w   D2,D0           ;zusammen mal 72 (36*2)
                move.w  D0,28(A2)
                rts
                ENDPART
                >PART 'CM_POSITION_JUMP'
cm_position_jump:
                move.b  $03(A4),D0
                subq.b  #$01,D0
                move.b  D0,cm_songpos(A3)
cm_pj2:
                clr.b   cm_breakpos(A3)
                st      cm_posjumpflag(A3)
                rts
                ENDPART
                >PART 'CM_SET_VOLUME'
cm_set_volume:
                move.b  3(A4),D0
                cmpi.b  #$40,D0
                bls.s   cm_volume_ok

                moveq   #$40,D0
cm_volume_ok:
                move.b  D0,25(A2)
                rts
                ENDPART
                >PART 'CM_PATTERN_BREAK'
cm_pattern_break:
                moveq   #0,D0
                move.b  3(A4),D0
                move.w  D0,D2
                lsr.b   #4,D0           ;BCD-Zahl in bin„r umrechnen
                mulu    #10,D0
                andi.b  #$0F,D2
                add.b   D2,D0
                cmpi.b  #63,D0
                bhi.s   cm_pj2

                move.b  D0,cm_breakpos(A3) ;Position merken
                st      cm_posjumpflag(A3)
                rts
                ENDPART
                >PART 'CM_SET_FILTER'
cm_set_filter:
                rts
                ENDPART
                >PART 'CM_SET_SPEED'
cm_set_speed:
                move.b  $03(A4),D0
                andi.b  #$1F,D0         ;!
                beq.s   cm_ncs

                clr.b   cm_counter(A3)
                move.b  D0,cm_speed(A3)
cm_ncs:
                rts
                ENDPART
                >PART 'CM_NOTEDELAY'
cm_notedelay:
                move.b  3(A4),D0
                andi.w  #$0F,D0
                cmp.b   cm_counter(A3),D0
                bne.s   cm_ncs
                move.w  (A4),D0
                beq.s   cm_ncs

                clr.l   4(A2)
                rts
                ENDPART
                >PART 'CM_RETRIGNOTE'
cm_retrignote:
                moveq   #0,D0
                move.b  3(A4),D0
                andi.b  #$0F,D0
                beq.s   cm_rtend
                moveq   #0,D3
                move.b  cm_counter(A3),D3 ;Counter l„uft noch?
                bne.s   cm_rtnskip
                move.w  (A4),D3
                andi.w  #$0FFF,D3       ;neue Periode?
                bne.s   cm_rtend
                moveq   #0,D3
                move.b  cm_counter(A3),D3
cm_rtnskip:
                divu    D0,D3
                swap    D3
                tst.w   D3
                bne.s   cm_rtend

                clr.l   4(A2)
cm_rtend:
                rts
                ENDPART
                >PART 'CM_VOLUMEFINEUP'
cm_volumefineup:
                tst.b   cm_counter(A3)
                bne.s   cm_rtend

                moveq   #0,D0
                move.b  3(A4),D0
                andi.b  #$0F,D0
                bra     cm_up2
                ENDPART
                >PART 'CM_VOLUMEFINEDOWN'
cm_volumefinedown:
                tst.b   cm_counter(A3)
                bne.s   cm_rtend

                move.b  3(A4),D0
                andi.w  #$0F,D0
                bra     cm_down2
                ENDPART
                >PART 'CM_NOTECUT'
cm_notecut:
                move.b  3(A4),D0
                andi.w  #$0F,D0
                cmp.b   cm_counter(A3),D0
                bne.s   cm_rtend

                clr.w   24(A6)          ;Volume auf null
                clr.w   26(A2)          ;Periode auf null
                rts
                ENDPART

                >PART 'CM_JUMPLOOP'
cm_jumploop:
                tst.b   cm_counter(A3)
                bne.s   cm_wech

                move.b  3(A4),D0
                andi.w  #$0F,D0
                beq.s   cm_setloop      ;E60, dann Loopanfang merken

                tst.b   19(A4)          ;Loopcount
                beq.s   cm_jumpcnt

                subq.b  #1,19(A4)
                beq.s   cm_wech
cm_jmploop:
                move.b  18(A4),cm_breakpos(A3)
                st      cm_breakflag(A3)

                rts
cm_jumpcnt:
                move.b  D0,19(A4)
                bra.s   cm_jmploop
cm_setloop:

                move.w  cm_pattpos(A3),D0
                lsr.w   #4,D0
                move.b  D0,18(A4)       +Loopanfang merken
                rts
                ENDPART
                >PART 'CM_PATTERNDELAY'
cm_patterndelay:
                tst.b   cm_counter(A3)
                bne.s   cm_wech

                move.b  3(A4),D0
                andi.w  #$0F,D0
                tst.b   cm_pattdeltime2(A3)
                bne.s   cm_wech

                addq.b  #1,D0
                move.b  D0,cm_pattdeltime(A3)
cm_wech:
                rts
                ENDPART
                >PART 'CM_FUNKIT'
cm_funkit:
                tst.b   cm_counter(A3)
                bne.s   cm_funkend

                move.b  3(A4),D0
                andi.w  #$0F,D0
                lsl.b   #4,D0
                andi.b  #$0F,17(A4)     ;GlissFunk
                or.b    D0,17(A4)
                tst.b   D0
                beq.s   cm_funkend
cm_updatefunk:
                moveq   #0,D0           ;h„? was issn looos?
                move.b  17(A4),D0
                lsr.b   #4,D0
                beq.s   cm_funkend

                lea     cm_funktable(PC),A1
                move.b  0(A1,D0.w),D0

                add.b   D0,20(A4)
                btst    #7,20(A4)
                beq.s   cm_funkend

                clr.b   20(A4)          ;Funkoffset l”schen
                clr.l   4(A2)           ;Offset l”schen
                move.l  16(A2),(A2)     ;Repstart nach akt. Adr.
cm_funkend:
                rts
                ENDPART

                >PART 'Precalc DIGIT'
cm_count:       DC.W 0
cm_precalc_digit:
                moveq   #0,D6           ;!!!!!!!!!!!
                lea     cm_count(PC),A3
                sf      (A3)

                move.w  cm_soundmode(PC),D5
                cmp.w   #3,D5
                blt.s   cm_normalst
;---------
                movea.l cm_swap+4(PC),A1 ;Stimme 1 plus Stimme 4
                lea     0*cm_chlen+cm_channels(PC),A2
                bsr.s   cm_calc_voice

                movea.l cm_swap+4(PC),A1
                lea     3*cm_chlen+cm_channels(PC),A2
                bsr.s   cm_calc_voice
;---------
                sf      (A3)
                movea.l cm_swap+4(PC),A1
                addq.l  #1,A1
                lea     1*cm_chlen+cm_channels(PC),A2 ;Stimme 2 plus Stimme 3
                bsr.s   cm_calc_voice

                movea.l cm_swap+4(PC),A1
                addq.l  #1,A1
                lea     2*cm_chlen+cm_channels(PC),A2
                bsr.s   cm_calc_voice
;qw sonst gibt es nacher bei cm_feddich 'nen Buserror. Durch das addq.l #1,a1
                subq.l  #1,A1


                bra.s   cm_feddich
cm_normalst:
                nop                     ;<-- modifiziert, bei nur 3 Stimmen
                movea.l cm_swap+4(PC),A1
                lea     0*cm_chlen+cm_channels(PC),A2
                bsr.s   cm_calc_voice
cm_normalst1:
                nop                     ;<--
                movea.l cm_swap+4(PC),A1
                lea     1*cm_chlen+cm_channels(PC),A2
                bsr.s   cm_calc_voice
                nop                     ;<--
                movea.l cm_swap+4(PC),A1
                lea     2*cm_chlen+cm_channels(PC),A2
                bsr.s   cm_calc_voice
                nop                     ;<--
                movea.l cm_swap+4(PC),A1
                lea     3*cm_chlen+cm_channels(PC),A2
                bsr.s   cm_calc_voice
cm_feddich:
                move.w  -2(A1),D0
                move.w  D0,(A1)+        ;Knacken verhindern
                move.w  D0,(A1)+
                move.w  D0,(A1)+
                move.w  D0,(A1)+
                move.w  D0,(A1)+
                rts
cm_calc_voice:
                move.l  cm_voladr(PC),D4
                movea.l (A2),A0         ;Act Adr.
                move.l  4(A2),D3        ;Act Offset
                moveq   #0,D5
                move.w  24(A2),D5       ;Vol
                move.w  cm_volsub(PC),D1

                cmpi.w  #64,D1
                beq.s   cm_notsub

                mulu    D1,D5           ;mal Basislautst„rke
                lsr.w   #6,D5           ;durch 64
cm_notsub:
                lsl.w   #8,D5           ;mal 256
                add.l   D5,D4
                move.w  26(A2),D5       ;Periode
                add.w   D5,D5
                add.w   D5,D5           ;mal 4 (Tabelle)
                lea     cm_frq(PC),A4
                movem.w 0(A4,D5.w),D0/D2 ;Vorkomma/Nachkomma
                moveq   #0,D1

                move.w  cm_maschine(PC),D5
                cmp.w   #8,D5           ;F030 ?
                beq.s   cm_22           ;==> ja

                tst.b   (A3)
                bne.s   cm_2

                st      (A3)

                lea     cm_codepuff1(PC),A4
                jsr     cm_codepuff2-cm_codepuff1(A4)
                bra.s   cm_endtest
cm_2:
                bsr     cm_codepuff1
cm_endtest:
                tst.w   22(A2)          ;Repeat
                bne.s   cm_calc_rep

                cmp.w   14(A2),D3       ;Offset>=L„nge?
                blo.s   cm_noned

                move.l  12(A2),D3       ;Offset=L„nge
                clr.w   26(A2)          ;Periode=0
cm_noned:
                move.l  D3,4(A2)
                rts
cm_calc_rep:
                cmpa.l  16(A2),A0       ;schon im Repeat gewesen
                beq.s   cm_im_repeat

                cmp.w   14(A2),D3       ;Offset >=L„nge?
                blo.s   cm_noned2
cm_subloop1:
                sub.w   14(A2),D3       ;Offset=Offset-L„nge
                cmp.w   14(A2),D3
                bhs.s   cm_subloop1

                move.l  16(A2),(A2)     ;Rep.adr=Basis
cm_im_repeat:
                cmp.w   22(A2),D3       ;Offset >= Replen?
                blo.s   cm_noned2       ;nein
cm_subloop:
                sub.w   22(A2),D3       ;Offset=Offset-Replen
                cmp.w   22(A2),D3       ;solange bis Offset < Replen
                bhs.s   cm_subloop
cm_noned2:
                move.l  D3,4(A2)        ;offset merken
                rts
cm_22:
                move.w  cm_soundmode(PC),D5
                cmp.w   #3,D5           ;mit Volume ?
                bne.s   cm_221          ;==> nein

                tst.b   (A3)
                bne.s   cm_22__1

                st      (A3)
                bsr     cm_calc6_a
                bra.s   cm_endtest
cm_22__1:
                bsr     cm_calc5_a
                bra.s   cm_endtest
cm_221:
                tst.b   (A3)
                bne.s   cm_221_1

                st      (A3)
                bsr     cm_calc8_a
                bra.s   cm_endtest
cm_221_1:
                bsr     cm_calc7_a
                bra.s   cm_endtest
                ENDPART

                >PART ' CM_OPTIONS '
;----------------------------- Soundmode-Options (0-4) je 16 Bytes
; vorletztes Word = Pufferfllwert
; letztes Word = Wert fr das Nullsample

                BASE DC.W,cm_options
cm_options:
                DC.W cm_calc1,cm_calc1e,cm_calc2,cm_calc2e,cm_soundchip,$1000,$8080,0
                DC.W cm_cal11,cm_cal11e,cm_cal22,cm_cal22e,cm_soundchp2,$0200,$8080,0
                DC.W cm_calc3,cm_calc3e,cm_calc4,cm_calc4e,cm_soundchp2,$0200,$8080,0
;---STE/TT
                DC.W cm_calc5,cm_calc5e,cm_calc6,cm_calc6e,-1,$00,$8080,0
                DC.W cm_calc7,cm_calc7e,cm_calc8,cm_calc8e,-1,$00,$00,0
                BASE DC.W,OFF

;-------------------------------------------- normaler ST mit Volume (7 Bit)
cm_calc1:
                move.b  0(A0,D3.l),D4   ;16
                movea.l D4,A4           ;4
                move.w  (A4),D6         ;12           52
                add.w   D6,(A1)+        ;12
                add.w   D2,D1           ;4
                addx.w  D0,D3           ;4
cm_calc1e:
cm_calc2:
                move.b  0(A0,D3.l),D4   ;16
                movea.l D4,A4           ;4
                move.w  (A4),(A1)+      ;12           40
                add.w   D2,D1           ;4
                addx.w  D0,D3           ;4
cm_calc2e:
;------------------------------------- normaler ST mit Volume (8 Bit)
cm_cal11:
                move.b  0(A0,D3.l),D4
                movea.l D4,A4
                move.b  (A4),D6         ;hier byte oben word?
                add.w   D6,(A1)+
                add.w   D2,D1
                addx.w  D0,D3
cm_cal11e:
cm_cal22:
                move.b  0(A0,D3.l),D4
                movea.l D4,A4
                move.b  (A4),D6
                move.w  D6,(A1)+
                add.w   D2,D1
                addx.w  D0,D3
cm_cal22e:
;--------------------------------------------- normaler ST ohne Volume
cm_calc3:
                move.b  0(A0,D3.l),D6   ;16
                add.w   D6,(A1)+        ;12
                add.w   D2,D1           ;4
                addx.w  D0,D3           ;4
cm_calc3e:
cm_calc4:
                move.b  0(A0,D3.l),D6
                move.w  D6,(A1)+
                add.w   D2,D1
                addx.w  D0,D3
cm_calc4e:
;---------------------STE-Routinen (mit Volume)
cm_calc5_a:
                move.w  cm_anzahl(PC),D5 ;Bufferl„nge
cm_calc5:
                move.b  0(A0,D3.l),D4
                movea.l D4,A4
                move.b  (A4),D6
                add.b   D6,(A1)
                addq.w  #2,A1
                add.w   D2,D1
                addx.w  D0,D3
cm_calc5e:
                dbra    D5,cm_calc5
                rts
cm_calc6_a:
                move.w  cm_anzahl(PC),D5 ;Bufferl„nge
cm_calc6:
                move.b  0(A0,D3.l),D4
                movea.l D4,A4
                move.b  (A4),(A1)
                addq.w  #2,A1
                add.w   D2,D1
                addx.w  D0,D3
cm_calc6e:
                dbra    D5,cm_calc6
                rts
;----------------------------------- STE ohne Volume
cm_calc7_a:
                move.w  cm_anzahl(PC),D5 ;Bufferl„nge
cm_calc7:
                move.b  0(A0,D3.l),D6
                add.b   D6,(A1)
                addq.w  #2,A1
                add.w   D2,D1
                addx.w  D0,D3
cm_calc7e:
                dbra    D5,cm_calc7
                rts
cm_calc8_a:
                move.w  cm_anzahl(PC),D5 ;Bufferl„nge
cm_calc8:
                move.b  0(A0,D3.l),(A1)
                addq.w  #2,A1
                add.w   D2,D1
                addx.w  D0,D3
cm_calc8e:
                dbra    D5,cm_calc8
                rts
;----------------------
                ENDPART

cm_soundchip:                           ;          38
                move.w  (A6)+,D7        ;8              7-Bit
                move.l  cm_sound+4(PC,D7.w),(A5) ;28
                move.l  cm_sound(PC,D7.w),D7 ;20
                movep.l D7,0(A5)        ;24
                rte                     ;20
cm_soundchp2:
;                                        38
                move.w  (A6)+,D7        ;8              8-Bit
                lsl.w   #3,D7           ;12
                move.l  cm_sound+4(PC,D7.w),(A5) ;28
                move.l  cm_sound(PC,D7.w),D7 ;20
                movep.l D7,0(A5)        ;24
                rte                     ;20
cm_sound:
                DS.B 8192       ; Platz fr die Soundtab

                >PART 'Sound Tabellen'
cm_supersound:
                DC.W $00,$0200,$0210,$0310,$0410,$0510,$0600,$0610,$0630,$0710,$0720,$0731
                DC.W $0741,$0810,$0820,$0831,$0841,$0900,$0910,$0930,$0940,$0950,$0951,$0953
                DC.W $0962,$0963,$0A10,$0A30,$0A31,$0A50,$0A52,$0A53,$0A62,$0A70,$0A72,$0B10
                DC.W $0B30,$0B31,$0B41,$0B51,$0B53,$0B62,$0B63,$0B72,$0B74,$0B80,$0B81,$0B83
                DC.W $0B84,$0B85,$0B91,$0B93,$0B94,$0C20,$0C21,$0C41,$0C51,$0C53,$0C62,$0C70
                DC.W $0C72,$0C74,$0C75,$0C82,$0C84,$0C85,$0C90,$0C92,$0C94,$0C95,$0C96,$0C97
                DC.W $0C97,$0CA0,$0CA3,$0D20,$0D31,$0D50,$0D52,$0D61,$0D70,$0D72,$0D74,$0D75
                DC.W $0D82,$0D84,$0D90,$0D91,$0D94,$0D95,$0D96,$0D97,$0DA0,$0DA0,$0DA3,$0DA5
                DC.W $0DA6,$0DA7,$0DA8,$0DA8,$0DA8,$0DB1,$0DB4,$0DB6,$0DB7,$0DB7,$0DB8,$0DB8
                DC.W $0DB9,$0DB9,$0DB9,$0DBA,$0DBA,$0DBA,$0DBA,$0DBA,$0DC2,$0DC5,$0DC6,$0E00
                DC.W $0E31,$0E52,$0E62,$0E72,$0E75,$0E81,$0E85,$0E90,$0E93,$0E96,$0E97,$0E98
                DC.W $0E98,$0EA2,$0EA6,$0EA7,$0EA8,$0EA9,$0EA9,$0EA9,$0EB3,$0EB7,$0EB8,$0EB9
                DC.W $0EB9,$0EBA,$0EBA,$0EBA,$0EBA,$0EC0,$0EC0,$0EC0,$0EC7,$0EC7,$0EC8,$0EC8
                DC.W $0EC9,$0ECA,$0ECA,$0ECA,$0ECA,$0ECB,$0ECB,$0ECB,$0ED0,$0ED0,$0ED0,$0ED7
                DC.W $0ED7,$0ED7,$0ED9,$0ED9,$0ED9,$0EDA,$0EDA,$0EDA,$0EDB,$0EDB,$0EDB,$0F00
                DC.W $0F00,$0F00,$0F70,$0F70,$0F90,$0F90,$0F90,$0FA0,$0FA0,$0FA9,$0FB0,$0FB0
                DC.W $0FB0,$0FBA,$0FBA,$0FC0,$0FC0,$0FC9,$0FC9,$0FCA,$0FCA,$0FCA,$0FCB,$0FCB
                DC.W $0FCB,$0FCC,$0FCC,$0FCC,$0FD0,$0FD0,$0FD0,$0FD0,$0FD0,$0FD0,$0FD0,$0FDB
                DC.W $0FDB,$0FDB,$0FDB,$0FDB,$0FDB,$0FDB,$0FDC,$0FDC,$0FDC,$0FDC,$0FDC,$0FDC
                DC.W $0FDD,$0FDD,$0FDD,$0FDD,$0FDD,$0FDD,$0FE0,$0FE0,$0FE0,$0FE0,$0FE0,$0FE0
                DC.W $0FE0,$0FE0,$0FE0,$0FEC,$0FEC,$0FEC,$0FEC,$0FEC,$0FEC,$0FED,$0FED,$0FED
                DC.W $0FED,$0FED,$0FED,$0FED
;----------------
cm_funktable:
                DC.B 0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128 ;=
cm_sinus:
                DC.B $00,$18,$31,$4A,$61,$78,$8D,$A1,$B4,$C5,$D4,$E0,$EB,$F4,$FA,$FD
                DC.B $FF,$FD,$FA,$F4,$EB,$E0,$D4,$C5,$B4,$A1,$8D,$78,$61,$4A,$31,$18
cm_voltab:
                DC.B $00,$80,$00,$00,$00,$00,$00,$00,$00,$79,$B0,$CF,$00,$00,$0C,$9F
                DC.B $00,$77,$0B,$EF,$00,$00,$11,$E9,$00,$74,$80,$EE,$00,$00,$16,$FF
                DC.B $00,$71,$F5,$54,$00,$00,$1C,$16,$00,$6F,$AF,$96,$00,$00,$20,$A2
                DC.B $00,$6D,$3B,$FB,$00,$00,$25,$89,$00,$6B,$0D,$61,$00,$00,$29,$E6
                DC.B $00,$68,$9D,$D3,$00,$00,$2E,$C5,$00,$66,$6A,$15,$00,$00,$33,$2D
                DC.B $00,$64,$48,$8F,$00,$00,$37,$70,$00,$61,$F9,$99,$00,$00,$3C,$0E
                DC.B $00,$5F,$CC,$46,$00,$00,$40,$68,$00,$5D,$CE,$82,$00,$00,$44,$64
                DC.B $00,$5B,$B1,$39,$00,$00,$48,$9E,$00,$59,$72,$77,$00,$00,$4D,$1C
                DC.B $00,$57,$78,$72,$00,$00,$51,$10,$00,$55,$64,$7A,$00,$00,$55,$38
                DC.B $00,$53,$35,$3D,$00,$00,$59,$96,$00,$51,$61,$45,$00,$00,$5D,$3E
                DC.B $00,$4F,$7A,$34,$00,$00,$61,$0C,$00,$4D,$7F,$43,$00,$00,$65,$02
                DC.B $00,$4B,$6F,$A1,$00,$00,$69,$22,$00,$49,$4A,$77,$00,$00,$6D,$6C
                DC.B $00,$47,$9F,$EF,$00,$00,$70,$C1,$00,$45,$52,$F3,$00,$00,$75,$5B
                DC.B $00,$43,$89,$7E,$00,$00,$78,$EE,$00,$41,$B2,$1A,$00,$00,$7C,$9D
                DC.B $00,$3F,$CC,$5A,$00,$00,$80,$68,$00,$3D,$D7,$D0,$00,$00,$84,$51
                DC.B $00,$3B,$D4,$08,$00,$00,$88,$59,$00,$39,$C0,$8A,$00,$00,$8C,$80
                DC.B $00,$38,$55,$40,$00,$00,$8F,$56,$00,$36,$26,$82,$00,$00,$93,$B4
                DC.B $00,$33,$E6,$C0,$00,$00,$98,$33,$00,$32,$5D,$34,$00,$00,$9B,$46
                DC.B $00,$30,$CB,$B4,$00,$00,$9E,$69,$00,$2E,$62,$33,$00,$00,$A3,$3C
                DC.B $00,$2C,$BC,$1E,$00,$00,$A6,$89,$00,$2B,$0D,$82,$00,$00,$A9,$E6
                DC.B $00,$29,$56,$33,$00,$00,$AD,$54,$00,$27,$96,$04,$00,$00,$B0,$D5
                DC.B $00,$25,$CC,$C7,$00,$00,$B4,$67,$00,$23,$FA,$4E,$00,$00,$B8,$0C
                DC.B $00,$22,$1E,$68,$00,$00,$BB,$C4,$00,$20,$38,$E6,$00,$00,$BF,$8F
                DC.B $00,$1E,$49,$94,$00,$00,$C3,$6E,$00,$1C,$50,$41,$00,$00,$C7,$60
                DC.B $00,$1A,$4C,$B9,$00,$00,$CB,$67,$00,$18,$3E,$C6,$00,$00,$CF,$83
                DC.B $00,$17,$33,$D4,$00,$00,$D1,$99,$00,$15,$15,$DD,$00,$00,$D5,$D5
                DC.B $00,$12,$EC,$F3,$00,$00,$DA,$27,$00,$11,$D4,$52,$00,$00,$DC,$58
                DC.B $00,$0F,$9A,$91,$00,$00,$E0,$CC,$00,$0E,$79,$64,$00,$00,$E3,$0E
                DC.B $00,$0C,$2E,$49,$00,$00,$E7,$A4,$00,$0B,$04,$4D,$00,$00,$E9,$F8
                DC.B $00,$08,$A7,$51,$00,$00,$EE,$B2,$00,$07,$74,$42,$00,$00,$F1,$18
                DC.B $00,$05,$04,$DA,$00,$00,$F5,$F7,$00,$03,$C8,$70,$00,$00,$F8,$70
                DC.B $00,$01,$46,$0C,$00,$00,$FD,$75,$00,$00,$00,$00,$00,$01,$00,$00
                DC.B $00,$00,$00,$00,$00,$01,$00,$00
cm_periods:
                DC.W 856,808,762,720,678,640,604,570,538,508,480,453 ;=
                DC.W 428,404,381,360,339,320,302,285,269,254,240,226
                DC.W 214,202,190,180,170,160,151,143,135,127,120,113
; finetune 1
                DC.W 850,802,757,715,674,637,601,567,535,505,477,450 ;=
                DC.W 425,401,379,357,337,318,300,284,268,253,239,225
                DC.W 213,201,189,179,169,159,150,142,134,126,119,113
; finetune 2
                DC.W 844,796,752,709,670,632,597,563,532,502,474,447 ;=
                DC.W 422,398,376,355,335,316,298,282,266,251,237,224
                DC.W 211,199,188,177,167,158,149,141,133,125,118,112
; finetune 3
                DC.W 838,791,746,704,665,628,592,559,528,498,470,444 ;=
                DC.W 419,395,373,352,332,314,296,280,264,249,235,222
                DC.W 209,198,187,176,166,157,148,140,132,125,118,111
; finetune 4
                DC.W 832,785,741,699,660,623,588,555,524,495,467,441 ;=
                DC.W 416,392,370,350,330,312,294,278,262,247,233,220
                DC.W 208,196,185,175,165,156,147,139,131,124,117,110
; finetune 5
                DC.W 826,779,736,694,655,619,584,551,520,491,463,437 ;=
                DC.W 413,390,368,347,328,309,292,276,260,245,232,219
                DC.W 206,195,184,174,164,155,146,138,130,123,116,109
; finetune 6
                DC.W 820,774,730,689,651,614,580,547,516,487,460,434 ;=
                DC.W 410,387,365,345,325,307,290,274,258,244,230,217
                DC.W 205,193,183,172,163,154,145,137,129,122,115,109
; finetune 7
                DC.W 814,768,725,684,646,610,575,543,513,484,457,431 ;=
                DC.W 407,384,363,342,323,305,288,272,256,242,228,216
                DC.W 204,192,181,171,161,152,144,136,128,121,114,108
; finetune -8
                DC.W 907,856,808,762,720,678,640,604,570,538,508,480 ;=
                DC.W 453,428,404,381,360,339,320,302,285,269,254,240
                DC.W 226,214,202,190,180,170,160,151,143,135,127,120
; finetune -7
                DC.W 900,850,802,757,715,675,636,601,567,535,505,477 ;=
                DC.W 450,425,401,379,357,337,318,300,284,268,253,238
                DC.W 225,212,200,189,179,169,159,150,142,134,126,119
; finetune -6
                DC.W 894,844,796,752,709,670,632,597,563,532,502,474 ;=
                DC.W 447,422,398,376,355,335,316,298,282,266,251,237
                DC.W 223,211,199,188,177,167,158,149,141,133,125,118
; finetune -5
                DC.W 887,838,791,746,704,665,628,592,559,528,498,470 ;=
                DC.W 444,419,395,373,352,332,314,296,280,264,249,235
                DC.W 222,209,198,187,176,166,157,148,140,132,125,118
; finetune -4
                DC.W 881,832,785,741,699,660,623,588,555,524,494,467 ;=
                DC.W 441,416,392,370,350,330,312,294,278,262,247,233
                DC.W 220,208,196,185,175,165,156,147,139,131,123,117
; finetune -3
                DC.W 875,826,779,736,694,655,619,584,551,520,491,463 ;=
                DC.W 437,413,390,368,347,328,309,292,276,260,245,232
                DC.W 219,206,195,184,174,164,155,146,138,130,123,116
; finetune -2
                DC.W 868,820,774,730,689,651,614,580,547,516,487,460 ;=
                DC.W 434,410,387,365,345,325,307,290,274,258,244,230
                DC.W 217,205,193,183,172,163,154,145,137,129,122,115
; finetune -1
                DC.W 862,814,768,725,684,646,610,575,543,513,484,457 ;=
                DC.W 431,407,384,363,342,323,305,288,272,256,242,228
                DC.W 216,203,192,181,171,161,152,144,136,128,121,114
                ENDPART
;------------
                >PART 'Daten'

cm_offset:      DCB.W $09
cm_pos          EQU 0
cm_patt         EQU 2

cm_nbr          EQU 4
cm_pattpos      EQU 6
cm_counter      EQU 8
cm_posjumpflag  EQU 9
cm_songpos      EQU 10
cm_speed        EQU 11
cm_lowmask      EQU 12
cm_pattdeltime  EQU 13
cm_pattdeltime2 EQU 14
cm_breakpos     EQU 15
cm_breakflag    EQU 16
+-------------
cm_chlen        EQU 30
cm_sdatlen      EQU 28
;-------------
cm_machine:     DS.W 1
cm_module_adr:  DS.L 1
cm_frequenz:    DS.W 1          ;Ist-Frequenz der Abspielroutine
cm_timerwert:   DS.W 1
cm_anzahl:      DS.W 1
cm_frqbyte:     DS.W 1
oldmfpi7:       DS.L 1          ;Falcon030 MFP IRQ7
cm_merkvalues:  DS.B 8          ; MfP-Register
cm_soundmode:   DS.W 1
cm_volflag:     DS.W 1          ; 0=kein Volume  /   1=Volume
cm_chanflag:    DS.W 1          ; Nr. des abgezwickten Kanals (0=keiner)
cm_volcount:    DS.W 1
cm_voladr:      DS.L 1
cm_playadr:     DS.L 1
cm_null:        DC.W $8080      ;Nullsample
cm_samplestarts:DS.L 4*31       ;Platz fr die Sampledaten
cm_sounddatas:  DS.B cm_sdatlen*4
cm_channels:    DS.B cm_chlen*4
cm_swap:        DS.L 2
cm_digipuffer:  DS.L 1000       ;Puffer (2*500 Werte)
cm_digipuffer1:

cm_frq1:                                ;Ur-Steptab (c) 1991 NINJA III
i               SET 1
                REPT 907
                DC.L 97745482/i
i               SET i+1
                ENDR
cm_frq:                                 ;Puffer fr freq.angepažte Steptab
                DC.L 0
                DS.L 907
;----------------------
cm_codepuff1:                           ;Puffer fr den Endlos-Code
                DS.B (cm_calc5e-cm_calc5)*512 ;1074
cm_codepuff2:
                DS.B (cm_calc6e-cm_calc6)*512 ;1074
;----------------------
                ENDPART

                >PART 'Formate'
;
; Format der Speicherbereiche channels und sounddatas:
;
; Channels (je 30 Bytes):
;
; + 0 : Aktuelle Basisadresse  (.L)
; + 4 : Aktueller Offset       (.L)
; + 8 : Sample-Startadresse    (.L)
+ +12 : Sample-L„nge           (.L)
; +16 : Repeat-Startadresse    (.L)
; +20 : Repeat-L„nge           (.L)
; +24 : Lautst„rke ($00-$40)   (.W)
; +26 : Periode                (.W)
; +28 : Finetune *2*36         (.W)

; Sounddatas (je 28 Bytes):
;
; + 0 : letzte Trackzeile      (.L)
; + 4 : Periode                (.W)
; + 6 : Portamento             (.B)
; + 7 : Portamento             (.B)
; + 8 : kommende Periode (Por) (.W)
; +10 : Vibrato                (.B)
; +11 : Vibrato                (.B)
; +12 : Sampleoffset (in Bytes)(.W)
; +14 : Tremolocmd             (.B)
; +15 : Tremolopos             (.B)
; +16 : Wavecontrol            (.B)
; +17 : glissfunk              (.B)
; +18 : pattpos                (.B)
; +19 : loopcount              (.B)
; +20 : funkoffset             (.B)

; Samplestarts (16 Bytes je Instrument)
;
; +0  : Startadresse           (.L)
; +4  : L„nge                  (.L)
; +8  : Volume                 (.W)
; +10 : Repeatl„nge            (.L)
; +14 : Finetune*2*36          (.W)

*                OPT P-,O+
                ENDPART

************** module **************


*********************************
********** data *****************
*********************************

screen:         DC.L 0
save_stack:     DC.L 0

font_pal:       DC.W $02,$13,$0123,$0233,$0343,$0453,$0563

main_pal:       DC.L black_pal

black_pal:      DS.W 15

line_pal:       DC.W $0102,$0203,$0304,$0405,$0506,$0607,$0707
                DC.W $0717,$0727,$0737,$0747,$0757,$0767,$0777,0,0

logo_pal:       DC.W $0203,$0313,$0423,$0533,$0412,$0753,$0421
                DC.W $0532,$0643,$0754,$0310,$0512,$0623,$0734,$0777

leisten_pal:    DC.W $00,$0667,$0557,$0447,$0337,$0227,$07,$04
                DC.W $0777,$33,$0143,$0263,$0373,$0573,$0673,$0773

seat_pal:       DC.W $0760,$0650,$0540,$0430,$0320,$0210,$0100,$01,$0112
                DC.W $0223,$0334,$0445,$0556,$0667,$0777

seat_pal_0:     DS.W 16
insel_pal_0:    DS.W 16
insel_pal_1:    DS.W 16
insel_pal_2:    DS.W 16

insel_0:        DC.W $06,$37,$0640,$0420,$20,$30,$0240,$0600,$0400
                DC.W $0530,$0310,$0200,$0222,$0444,$0333,0
insel_1:        DC.W $06,$37,$0750,$0640,$27,$0763,$20,$30,$0250,$0260,$0530,$57,$47,$0222,$0777,0
insel_2:        DC.W $06,$37,$0750,$0640,$27,$0763,$0223,$0333,$0444,$0555,$0530,$57,$47,$0111,$0777,0

next_raster:    DC.L set_font
next_distance:  DC.B 150
last_distance:  DC.B 27
raster_wait:    DC.B -1
                EVEN

********** color line stuff **********

                >PART
the_offset_d:   DC.W 0
the_offset_h:   DC.W 0


color_tab_1:    DS.B 100
                DS.B 150
                DS.B 7,1
                DS.B 7,2
                DS.B 7,3
                DS.B 7,4
                DS.B 7,5
                DS.B 7,6
                DS.B 7,7
                DS.B 7,8
                DS.B 7,9
                DS.B 7,10
                DS.B 7,11
                DS.B 7,12
                DS.B 6,13
                DS.B 5,14
                DS.B 6,13
                DS.B 7,12
                DS.B 7,11
                DS.B 7,10
                DS.B 7,9
                DS.B 7,8
                DS.B 7,6
                DS.B 7,5
                DS.B 7,4
                DS.B 7,3
                DS.B 7,2
                DS.B 7,1
                DS.B 150
ende:           DS.B 200
                EVEN

color_tab_0:



                DS.B 150
                DS.B 5,1
                DS.B 5,2
                DS.B 5,3
                DS.B 5,4
                DS.B 5,5
                DS.B 5,6
                DS.B 5,7
                DS.B 5,8
                DS.B 5,9
                DS.B 5,10
                DS.B 5,11
                DS.B 5,12
                DS.B 4,13
                DS.B 3,14
                DS.B 4,13
                DS.B 5,12
                DS.B 5,11
                DS.B 5,10
                DS.B 5,9
                DS.B 5,8
                DS.B 5,6
                DS.B 5,5
                DS.B 5,4
                DS.B 5,3
                DS.B 5,2
                DS.B 5,1
                DS.B 150
                DS.B 200
                EVEN

point_tab:      DS.W 4
                DC.W $8000,0,0,0
                DC.W 0,$8000,0,0
                DC.W $8000,$8000,0,0
                DC.W 0,0,$8000,0
                DC.W $8000,0,$8000,0
                DC.W 0,$8000,$8000,0
                DC.W $8000,$8000,$8000,0
                DC.W 0,0,0,$8000
                DC.W $8000,0,0,$8000
                DC.W 0,$8000,0,$8000
                DC.W $8000,$8000,0,$8000
                DC.W 0,0,$8000,$8000
                DC.W $8000,0,$8000,$8000
                DC.W 0,$8000,$8000,$8000
                DC.W $8000,$8000,$8000,$8000


                ENDPART

************* spray stuff *************

                >PART

line_offset:    DC.W 0
spray_offsets:  DS.W 6
spray_start:    DC.W -8,-8*2,-8*3,-8*4,-8*5,-8*6

builder_mask:   DC.W $00,$10,$00,$0800,$00,$00,$4044,$00
                DC.W $0200,$80,$8000,$04,$0100,$00,$00,$00

                DC.W $0422,$10,$4100,$0804,$0120,$0200,$4844,$20
                DC.W $1200,$90,$8800,$04,$2110,$00,$0812,$0100

                DC.W $A422,$0190,$5522,$0854,$A920,$02AA,$6A56,$81A8
                DC.W $1A41,$2094,$8A51,$10A4,$A551,$1008,$4A92,$0148

                DC.W $B5AA,$6B95,$D56A,$6AD6,$AD6D,$B6AF,$6A56,$B5BA
                DC.W $5AD7,$7DBC,$AB53,$5EAE,$E555,$35AB,$DAB6,$554A

                DC.W $B7AE,$EBDF,$DF6B,$EBD6,$FFFD,$B7FF,$FEF7,$BFFB
                DC.W $FBF7,$7FFE,$BBFF,$DFBE,$FFF7,$77AB,$FAB6,$D5FA

                DC.W $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
                DC.W $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF

                ENDPART

************ text ***************

text_x0:        DC.B " HIER SIND NOCH ZWEI"
text_x1:        DC.B "    PLAETZE FREI    "

text_0:         DC.B " IS BACK TO PRESENT "
text_1:         DC.B "    A NEW DENTRO    "
text_2:         DC.B "       CALLED       "
text_3:         DC.B "THIS DENTRO WAS DONE"
text_4:         DC.B "      AT THE        "
text_5:         DC.B "   UNITED FORCES    "
text_6:         DC.B " SUMMER CONVENTION  "
text_7:         DC.B "    SOMEWHERE IN    "
text_8:         DC.B "      BAVARIA       "

text_9:         DC.B " HERE ARE THE NAMES "
text_10:        DC.B "   OF THE HEROES    "
text_11:        DC.B "   WHO MADE THIS    "
text_12:        DC.B " CONVENTION  HAPPEN "

text_13:        DC.B "  APOLLO  OF NPG    "
text_14:        DC.B "  CARNERA OF NPG    "
text_15:        DC.B "  JARON   OF NPG    "
text_16:        DC.B "  QUESTOR OF INTER  "
text_17:        DC.B "  DUX     OF STAX   "
text_18:        DC.B "  MATT    OF STAX   "
text_19:        DC.B "  MIKE    OF STAX   "
text_20:        DC.B "  TYAN    OF STAX   "

text_21:        DC.B "    TARZAN BOY      "
text_22:        DC.B "  HOLLE THE BOMBER  "
text_23:        DC.B "  SIEBI AND FULLI   "
text_24:        DC.B "  SPLASHING HOLGER  "
text_25:        DC.B "   A GREY MOUSE     "
text_26:        DC.B "  BLOCKHEAD OF THE  "
text_26a:       DC.B "        WEEK        "
text_27:        DC.B "    FRAU LEIPOLD    "


text_28:        DC.B "   INTRO CREDITS    "
text_29:        DC.B "CODE            MIKE"
text_30:        DC.B "GRAPHICS     CARNERA"
text_31:        DC.B "                MIKE"
text_32:        DC.B "               SODAN"
text_33:        DC.B "MUSIC           TYAN"

text_34:        DC.B "    PRESS SPACE     "
                EVEN

*********** font data ************

font:           DS.W 3*16
                IBYTES 'FONT.DAT'
                EVEN

********* gfx *************

leisten:        >PART

                DC.W $FFF4,$FFFF,$FFFF,$00,$BE,$FF40,$FFFF,$00
                DC.W $85D0,$05FF,$FA00,$00,$3FFF,$C000,$00,$00
                DC.W $FFFF,$00,$00,$00,$FFFF,$00,$00,$00
                DC.W $FFFF,$00,$00,$00,$D82F,$3000,$082F,$00
                DC.W $E9FB,$00,$E9FB,$00,$F7E0,$00,$F7E0,$00
                DC.W $FDFD,$00,$FDFD,$00,$FBFB,$00,$FBFB,$00
                DC.W $F7F7,$18,$F7E0,$00,$FFFF,$00,$00,$00
                DC.W $FFFF,$00,$00,$00,$FFFF,$00,$00,$00
                DC.W $FFFC,$03,$00,$00,$0BA1,$FFA0,$5F,$00
                DC.W $7D00,$02FF,$FFFF,$00,$2FFF,$FFFF,$FFFF,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$0828,$00
                DC.W $00,$00,$2902,$00,$00,$00,$0410,$00
                DC.W $00,$00,$8105,$00,$00,$00,$0A02,$00
                DC.W $00,$00,$0400,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $D0AF,$2FFF,$00,$FFFF,$E81F,$E800,$17FF,$FFFF
                DC.W $C03F,$3FFF,$FFFF,$FFFF,$F800,$FFFF,$FFFF,$FFFF
                DC.W $FC1F,$03E0,$FFFF,$FFFF,$FE05,$05,$FFFA,$FFFF
                DC.W $FD01,$FFFE,$00,$FFFF,$8828,$0828,$00,$8000
                DC.W $2902,$2902,$00,$00,$0410,$0410,$00,$00
                DC.W $8105,$8105,$00,$00,$0A02,$0A02,$00,$00
                DC.W $0400,$0400,$00,$00,$D0AF,$2FFF,$00,$FFFF
                DC.W $E81F,$E800,$17FF,$FFFF,$C03F,$3FFF,$FFFF,$FFFF
                DC.W $F800,$FFFF,$FFFF,$FFFF,$FC1F,$03E0,$FFFF,$FFFF
                DC.W $FE05,$05,$FFFA,$FFFF,$FD03,$FFFC,$00,$FFFF
                DC.W $FFFF,$8000,$8000,$7FFF,$FFFF,$00,$00,$FFFF
                DC.W $FFFF,$00,$00,$FFFF,$FFFF,$00,$00,$FFFF
                DC.W $FFFF,$00,$00,$FFFF,$FFFF,$00,$00,$FFFF
                DC.W $FFFF,$00,$00,$FFFF,$8000,$8828,$8000,$00
                DC.W $00,$2903,$00,$00,$00,$C410,$00,$00
                DC.W $00,$F105,$00,$00,$00,$7A03,$00,$00
                DC.W $00,$C7E0,$00,$00,$FFFF,$8000,$8000,$7FFF
                DC.W $FFFF,$00,$00,$FFFF,$FFFF,$00,$00,$FFFF
                DC.W $FFFF,$00,$00,$FFFF,$FFFF,$00,$00,$FFFF
                DC.W $FFFF,$00,$00,$FFFF,$FFFF,$01,$01,$FFFE
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$0828,$00,$00,$00
                DC.W $2902,$00,$00,$00,$0410,$00,$00,$00
                DC.W $8105,$00,$00,$00,$2202,$00,$00,$00
                DC.W $20,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $FFF4,$FFFF,$FFFF,$00,$BE,$FF40,$FFFF,$00
                DC.W $85D0,$05FF,$FA00,$00,$3FFF,$C000,$00,$00
                DC.W $FFFF,$00,$00,$00,$FFFF,$00,$00,$00
                DC.W $FFFF,$00,$00,$00,$F000,$00,$00,$0FE8
                DC.W $00,$00,$00,$2903,$00,$00,$00,$F7F0
                DC.W $00,$00,$00,$81FD,$00,$00,$00,$23FB
                DC.W $1F,$00,$00,$F7E0,$FFFF,$00,$00,$00
                DC.W $FFFF,$00,$00,$00,$FFFF,$00,$00,$00
                DC.W $FFFC,$03,$00,$00,$0BA1,$FFA0,$5F,$00
                DC.W $7D00,$02FF,$FFFF,$00,$2FFF,$FFFF,$FFFF,$00
                DC.W $FFF4,$FFFF,$FFFF,$00,$BE,$FF40,$FFFF,$00
                DC.W $85D0,$05FF,$FA00,$00,$3FFF,$C000,$00,$00
                DC.W $FFFF,$00,$00,$00,$FFFF,$00,$00,$00
                DC.W $FFFF,$00,$00,$00,$FFFF,$00,$00,$00
                DC.W $FFFF,$00,$00,$00,$FFFF,$00,$00,$00
                DC.W $FFFF,$00,$00,$00,$FFFF,$00,$00,$00
                DC.W $FFFF,$00,$00,$00,$FFFF,$00,$00,$00
                DC.W $FFFF,$00,$00,$00,$FFFF,$00,$00,$00
                DC.W $FFFC,$03,$00,$00,$0BA1,$FFA0,$5F,$00
                DC.W $7D00,$02FF,$FFFF,$00,$2FFF,$FFFF,$FFFF,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $D0AF,$2FFF,$00,$FFFF,$E81F,$E800,$17FF,$FFFF
                DC.W $C03F,$3FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
                DC.W $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
                DC.W $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
                DC.W $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
                DC.W $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
                DC.W $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
                DC.W $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
                DC.W $FFFF,$FFFF,$FFFF,$FFFF,$FC03,$FFFC,$FFFF,$FFFF
                DC.W $F817,$17,$FFE8,$FFFF,$F50B,$FFF4,$00,$FFFF
                DC.W $FFFF,$8000,$8000,$7FFF,$FFFF,$00,$00,$FFFF
                DC.W $FFFF,$00,$00,$FFFF,$FFFF,$00,$00,$FFFF
                DC.W $FFFF,$00,$00,$FFFF,$FFFF,$00,$00,$FFFF
                DC.W $FFFF,$00,$00,$FFFF,$FFFF,$00,$00,$FFFF
                DC.W $FFFF,$00,$00,$FFFF,$FFFF,$00,$00,$FFFF
                DC.W $FFFF,$00,$00,$FFFF,$FFFF,$00,$00,$FFFF
                DC.W $FFFF,$00,$00,$FFFF,$FFFF,$00,$00,$FFFF
                DC.W $FFFF,$00,$00,$FFFF,$FFFF,$00,$00,$FFFF
                DC.W $FFFF,$00,$00,$FFFF,$FFFF,$00,$00,$FFFF
                DC.W $FFFF,$00,$00,$FFFF,$FFFF,$01,$01,$FFFE
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $FFF4,$FFFF,$FFFF,$00,$BE,$FF40,$FFFF,$00
                DC.W $85D0,$05FF,$FA00,$00,$3FFF,$C000,$00,$00
                DC.W $FFFF,$00,$00,$00,$FFFF,$00,$00,$00
                DC.W $FFFF,$00,$00,$00,$FFFF,$00,$00,$00
                DC.W $FFFF,$00,$00,$00,$FFFF,$00,$00,$00
                DC.W $FFFF,$00,$00,$00,$FFFF,$00,$00,$00
                DC.W $FFFF,$00,$00,$00,$FFFF,$00,$00,$00
                DC.W $FFFF,$00,$00,$00,$FFFF,$00,$00,$00
                DC.W $FFFC,$03,$00,$00,$0BA1,$FFA0,$5F,$00
                DC.W $7D00,$02FF,$FFFF,$00,$2FFF,$FFFF,$FFFF,$00


                ENDPART

logo:           >PART
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $0100,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$0300,$00,$80,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $0700,$80,$C0,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$0700,$08C0,$E0,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $1720,$18C0,$D0,$20,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$3790,$3860,$68,$90
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $66D8,$79A0,$24,$58,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$6C6C,$73D0,$8012,$012C
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$01,$00
                DC.W $4A3E,$7760,$8381,$021E,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$03,$00,$D49F,$EE30,$0740,$048F
                DC.W $00,$00,$8000,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$07,$00
                DC.W $830B,$FC98,$04E4,$0B03,$00,$00,$C000,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $05,$01,$0A,$04,$8684,$FB0C,$0B73,$1680
                DC.W $8000,$00,$6000,$8000,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$0D,$01,$12,$0C
                DC.W $6152,$FE26,$3AA9,$2550,$1000,$1000,$E000,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $1B,$03,$24,$18,$CB84,$FC73,$7C78,$4B84
                DC.W $9000,$9800,$6000,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$33,$03,$4C,$30
                DC.W $30CC,$FFA1,$7FB2,$B0CC,$6000,$FC00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $75,$07,$88,$70,$D1BB,$BF43,$3F44,$51B8
                DC.W $00,$FE00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$0322,$031C,$0100,$02FF
                DC.W $E796,$DE66,$1E68,$A793,$8980,$7180,$0100,$FE80
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $1902,$18FC,$0800,$17FF,$F30E,$EEEE,$C6B6,$1B41
                DC.W $8130,$7E30,$20,$FFD0,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $01,$01,$00,$01,$9C13,$83E3,$8003,$7FFC
                DC.W $F89F,$F7DF,$E7EF,$0880,$9073,$8F83,$8002,$7FFD
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$19,$18,$08,$17
                DC.W $E1BF,$1E3F,$3F,$FFC0,$BD7B,$BBBB,$A38B,$5554
                DC.W $FB0F,$F8F0,$F800,$07FF,$3000,$3000,$2000,$D000
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $0193,$018C,$80,$017F,$DEC7,$20C3,$C3,$FF3C
                DC.W $DAB7,$D937,$D557,$2AA8,$C6F7,$8608,$8600,$79FF
                DC.W $9300,$6300,$0200,$FD00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$0B1E,$08E0,$0800,$07FF
                DC.W $B1AD,$4025,$25,$FFDA,$6D6D,$6C6D,$6AAD,$9112
                DC.W $6B1A,$4804,$4800,$B7FF,$F1B0,$0E30,$20,$FFD0
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $5071,$4F80,$4000,$3FFF,$0D96,$E492,$0492,$FB6D
                DC.W $26C8,$26C8,$2108,$DC77,$D361,$924E,$9240,$6DBF
                DC.W $1C14,$03E4,$04,$FFF8,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $01,$01,$01,$00,$86C2,$7901,$00,$FFFF
                DC.W $76D3,$86D3,$0691,$F96E,$5EF5,$56D5,$5555,$AAAA
                DC.W $96DC,$96C3,$12C0,$ED3F,$86C3,$013D,$01,$FFFE
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$05,$04,$04,$03
                DC.W $C2,$FF01,$00,$FFFF,$4FE7,$87E7,$05A5,$FA5A
                DC.W $A7CB,$A38B,$A00B,$5EF4,$CFE4,$CFC3,$4B40,$B4BF
                DC.W $8601,$01FE,$00,$FFFF,$4000,$4000,$4000,$8000
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $14,$13,$10,$0F,$6266,$8181,$00,$FFFF
                DC.W $A3FF,$43FF,$0298,$FD67,$CD67,$C107,$C006,$3FF9
                DC.W $FF8A,$FF85,$3280,$CD7F,$CC8C,$0303,$00,$FFFF
                DC.W $5000,$9000,$1000,$E000,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$53,$4C,$40,$3F
                DC.W $8EBF,$0E40,$0E00,$F1FF,$5DFF,$85FF,$0500,$FAFF
                DC.W $FFFF,$F93F,$3938,$C6C7,$FF75,$FF42,$0140,$FEBF
                DC.W $FAE3,$04E0,$E0,$FF1F,$9400,$6400,$0400,$F800
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $014E,$0130,$0100,$FF,$3FAB,$3F94,$3F80,$C07F
                DC.W $F7FF,$13FF,$1336,$ECC9,$8D63,$8103,$8002,$7FFD
                DC.W $FFDF,$FF90,$D990,$266F,$ABF8,$53F8,$03F8,$FC07
                DC.W $E500,$1900,$0100,$FE00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$049C,$0460,$0400,$03FF
                DC.W $7FCC,$7FC3,$70C0,$8F3F,$DDE4,$2DE4,$0D64,$F29B
                DC.W $B39A,$8382,$8002,$7FFD,$4F76,$4F69,$4D60,$B29F
                DC.W $67FC,$87FC,$061C,$F9E3,$7240,$0C40,$40,$FF80
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $12F1,$1101,$1001,$0FFE,$FFE6,$FFE1,$C060,$3F9F
                DC.W $33F1,$CBF0,$03B0,$FC4F,$37D9,$07C0,$0440,$FABF
                DC.W $1F98,$1FA7,$1B80,$E47F,$CFFF,$0FFF,$0C07,$F3F8
                DC.W $1E90,$0110,$10,$FFE0,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$4FC7,$4007,$4007,$3FF8
                DC.W $F5F3,$F5F0,$30,$F5CF,$0CFC,$F0FC,$EC,$FF13
                DC.W $1EF0,$1EF0,$1930,$E44F,$7E61,$7E1E,$6E00,$91FF
                DC.W $9F5F,$1F5F,$1801,$E75E,$C7E4,$C004,$C004,$3FF8
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $2D9F,$121F,$1C,$FFE3,$AAF9,$AAF8,$18,$AAE7
                DC.W $013F,$FE3F,$30,$FFCF,$FD7F,$FC7F,$0280,$F93F
                DC.W $F901,$F8FE,$1800,$E7FF,$3EAB,$3EAB,$3000,$CEAB
                DC.W $F368,$F090,$7000,$8FFE,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $02,$02,$02,$01,$BA3F,$443F,$38,$FFC7
                DC.W $57F8,$57F8,$18,$57E7,$8107,$7E07,$07,$FFF8
                DC.W $3FF9,$3C79,$3839,$C386,$C102,$C0FC,$C000,$3FFF
                DC.W $3FD5,$3FD5,$3000,$CFD5,$F8BA,$F844,$3800,$C7FF
                DC.W $8000,$8000,$8000,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$02,$01,$00,$07
                DC.W $F6FE,$08FE,$E0,$FF1E,$BFFC,$BFFC,$0C,$BFF3
                DC.W $4319,$3C19,$19,$FFE6,$77DD,$745D,$5455,$ABAA
                DC.W $3184,$3078,$3000,$CFFF,$7FFA,$7FFA,$6000,$9FFA
                DC.W $FEDE,$FE21,$0E00,$F1FF,$8000,$00,$00,$C000
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $04,$03,$00,$0F,$A9F5,$11F5,$0180,$FE75
                DC.W $7FDF,$7E3F,$03,$7E04,$3E3E,$3E,$36,$FFC9
                DC.W $F7DE,$F45E,$D016,$2BA9,$F8F9,$F801,$D801,$27FE
                DC.W $EFBD,$FFFD,$8000,$403D,$5F2A,$5F11,$0300,$5CFF
                DC.W $4000,$8000,$00,$E000,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$03,$0C,$00,$1F
                DC.W $37EB,$07EB,$0700,$F8EB,$FFA3,$F063,$1C,$F001
                DC.W $C0FF,$C0FF,$C0C3,$3F3C,$E38F,$E82F,$644D,$9392
                DC.W $FE07,$FE07,$8606,$79F9,$9437,$9C3F,$63C0,$07
                DC.W $AFD9,$AFC0,$01C0,$AE3F,$8000,$6000,$00,$F000
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $06,$18,$00,$3F,$6FD7,$0FD7,$0C00,$F3D7
                DC.W $9E62,$81DC,$1D,$8022,$FFFF,$FFFF,$3F02,$40FD
                DC.W $EBEF,$F83F,$A40A,$43C5,$FFFE,$FFFE,$81F9,$7E04
                DC.W $89E3,$0C03,$7210,$81E3,$D7EC,$D7E0,$60,$D79F
                DC.W $C000,$3000,$00,$F800,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$08,$30,$00,$7F
                DC.W $DE8E,$1E8E,$1800,$E68E,$DD,$3FBE,$3E,$5D
                DC.W $AFFF,$3FFF,$4000,$8FFF,$AFEB,$E00F,$1010,$8FE3
                DC.W $FFEB,$FFF8,$04,$FFE3,$74C8,$0630,$8930,$70C8
                DC.W $E2F6,$E2F0,$30,$E2CF,$2000,$1800,$00,$FC00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $11,$60,$00,$FF,$BD18,$3D18,$3000,$CD18
                DC.W $71BF,$7F7F,$7F,$BF,$6801,$8FFF,$9000,$6000
                DC.W $3FB2,$43,$C04C,$3FB0,$5C,$FFC0,$23,$1C
                DC.W $7E98,$077C,$805C,$78B8,$317B,$3178,$18,$3167
                DC.W $1000,$0C00,$00,$FE00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$23,$C0,$00,$01FF
                DC.W $7A30,$7A20,$6000,$9A20,$BF79,$BEFE,$40FE,$0179
                DC.W $9C01,$6000,$63FE,$9C01,$DFFE,$2000,$2001,$DFFE
                DC.W $DB,$00,$FF24,$DB,$7E5C,$06BE,$813E,$785C
                DC.W $18BD,$08BC,$0C,$08B3,$8800,$0600,$00,$FF00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $C2,$0100,$00,$03FF,$F440,$F400,$C001,$3400
                DC.W $5EF7,$5DF8,$A1F8,$02F7,$7FEF,$C010,$C010,$7FEF
                DC.W $9F79,$6080,$6086,$9F79,$FBD2,$0404,$0429,$FBD6
                DC.W $FF2E,$075F,$9F,$F82E,$045E,$5E,$06,$59
                DC.W $8600,$0100,$00,$FF80,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$0585,$0601,$0401,$03FE
                DC.W $E880,$E880,$8003,$6880,$2DF8,$2BFF,$D3FF,$05F8
                DC.W $FFFF,$8000,$8000,$FFFF,$BE78,$4180,$4187,$BE78
                DC.W $8784,$7808,$7873,$878C,$FF97,$07AF,$4F,$F817
                DC.W $022F,$822F,$8003,$022C,$4340,$C0,$40,$FF80
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $0F03,$0803,$0803,$07FC,$D102,$D000,$05,$D002
                DC.W $1B9F,$17FF,$E7FF,$0B9F,$FFBF,$40,$40,$FFBF
                DC.W $3EF8,$C100,$C107,$3EF8,$8F8D,$7010,$7062,$8F9D
                DC.W $FFCB,$07D7,$27,$F80B,$8117,$C017,$C001,$8016
                DC.W $81E0,$8020,$8020,$7FC0,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$1617,$1007,$1006,$0FF9
                DC.W $A205,$A000,$0A,$A005,$366E,$2F9F,$CF9F,$166E
                DC.W $FFFE,$01,$3C01,$E7FE,$7CFA,$8300,$8305,$7CFA
                DC.W $932B,$6410,$6CC4,$933B,$FF25,$072B,$D3,$F805
                DC.W $C08B,$E00B,$E000,$C00B,$D0D0,$C010,$C010,$3FE0
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $240F,$280F,$0C,$3FF3,$441E,$4400,$01,$441E
                DC.W $EDF7,$5E0E,$1E0E,$ADF7,$E4F8,$1307,$3F1F,$DAF4
                DC.W $FCB2,$0340,$034D,$FCB2,$9313,$6420,$6CCC,$9333
                DC.W $F7FA,$071D,$0801,$F0E2,$E045,$F045,$F000,$E045
                DC.W $E048,$E028,$6000,$9FF8,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$3C1E,$201E,$2018,$1FE6
                DC.W $883D,$8000,$02,$803D,$D7F7,$B80E,$380E,$57F7
                DC.W $D4E9,$2306,$6F1E,$FAF5,$F832,$07C0,$07CD,$F832
                DC.W $2757,$C820,$D888,$2777,$F769,$078A,$0814,$F0E1
                DC.W $3022,$F802,$F800,$3002,$F078,$F008,$3008,$CFF0
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $683D,$503D,$4038,$3FC5,$105F,$1021,$20,$105E
                DC.W $EBEA,$341F,$341F,$EBEA,$D9F1,$2206,$2E1E,$D7E9
                DC.W $F837,$07C0,$07C8,$F837,$5E17,$8040,$A1A8,$5E57
                DC.W $FA6E,$0A8D,$0510,$F0E2,$8811,$7C11,$7C00,$8811
                DC.W $782C,$7814,$3804,$47F8,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$B87E,$807E,$70,$FF8E
                DC.W $30BF,$2042,$40,$20BD,$97FB,$681F,$681F,$97FB
                DC.W $3FFB,$C004,$DC1C,$37EB,$F27A,$0D85,$0D9D,$F276
                DC.W $2EAF,$9040,$D110,$2EEF,$EBEE,$0E0E,$1011,$E5E0
                DC.W $6018,$9E08,$1E00,$6008,$FC3A,$FC02,$1C00,$E3FE
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $D0FD,$A0FD,$80E0,$7F1D,$615F,$20A4,$A0,$215B
                DC.W $7FD5,$803B,$803B,$7FD5,$ABB7,$C448,$DC78,$B7AF
                DC.W $F778,$0885,$089F,$F76C,$9E6D,$2082,$6116,$9EEB
                DC.W $E2FF,$070F,$1000,$EDF0,$380D,$4709,$8700,$3809
                DC.W $7E16,$7E0A,$0E02,$71FC,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $01,$01,$00,$01,$307A,$407A,$70,$FF8A
                DC.W $403F,$43C8,$03C0,$4037,$FFED,$33,$33,$FFED
                DC.W $7397,$8448,$9C78,$6FAF,$FFF5,$0A,$013A,$FEED
                DC.W $5D6D,$2082,$A21E,$5DEB,$FCFF,$110F,$0200,$EDF0
                DC.W $AE04,$A184,$5180,$0E04,$BC19,$BC05,$1C00,$A3FF
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$01,$01,$01,$00
                DC.W $A0FC,$40FC,$E0,$FF1C,$C27F,$C790,$0780,$C26F
                DC.W $DF9E,$2063,$2063,$DF9E,$FF2F,$C0,$38F0,$EF1F
                DC.W $FED9,$02,$017E,$FFE9,$BCF5,$4102,$420E,$BDFB
                DC.W $E6B6,$0D06,$49,$FBB0,$A3C6,$3006,$4C00,$83C6
                DC.W $7E0B,$7E05,$0E01,$71FE,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $02,$02,$00,$03,$61F9,$81F8,$01C0,$FE38
                DC.W $8467,$8FB8,$0F98,$8447,$3FB9,$C046,$C046,$3FB9
                DC.W $D7BF,$08C0,$38F0,$EF9F,$FDFF,$0200,$02FC,$FD83
                DC.W $7CF9,$8102,$820E,$7DF7,$DDB4,$0605,$204A,$DBB1
                DC.W $F0E3,$3802,$0700,$C0E2,$3F0C,$3F02,$0700,$38FF
                DC.W $8000,$8000,$00,$8000,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$03,$02,$02,$01
                DC.W $62F5,$82F5,$02E0,$FD15,$8CCE,$9F71,$1F31,$8C8E
                DC.W $FB7B,$8484,$8484,$FB7B,$A6EF,$4990,$79F7,$DEDC
                DC.W $9DE7,$6218,$E238,$FDD7,$FDFD,$02,$021E,$FDF7
                DC.W $C9B1,$1202,$044C,$FBB3,$B803,$3C03,$43F0,$8003
                DC.W $5E8D,$5E82,$0E80,$517F,$8000,$8000,$8000,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$01,$00,$03,$41FB,$81FB,$01C0,$FE3B
                DC.W $19AD,$3EF3,$3E73,$192D,$7FFF,$8000,$8000,$7FFF
                DC.W $F72D,$0990,$79F7,$DF5A,$FFE7,$18,$F378,$1DD7
                DC.W $E3EB,$0804,$FDFC,$9B17,$DF2B,$0C,$20D0,$DF27
                DC.W $DC01,$5E01,$21F8,$8001,$BF04,$BF03,$0700,$B8FF
                DC.W $00,$00,$00,$8000,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$06,$05,$00,$07
                DC.W $C3F7,$03F5,$03A0,$FC55,$3B5A,$7DE7,$7CE7,$3A5A
                DC.W $E6EE,$1911,$1911,$E6EE,$F5EF,$0B10,$7BF3,$DD9E
                DC.W $D6A7,$0918,$FF79,$6DD7,$D75B,$2004,$FBFC,$6EE7
                DC.W $F763,$04,$0898,$F767,$E60D,$470D,$18F0,$A001
                DC.W $DF86,$5F81,$0B80,$547F,$C000,$4000,$00,$C000
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $06,$05,$04,$03,$85FB,$05FB,$05C0,$FA3A
                DC.W $76B5,$FBCE,$F9CE,$74B5,$CFDD,$3022,$3022,$CFDD
                DC.W $E47F,$0B00,$7BF3,$DC9E,$32CC,$4910,$FF73,$EFBD
                DC.W $A5AB,$4844,$FBFC,$7EF7,$F777,$18,$0880,$F76F
                DC.W $1B7D,$23FE,$C400,$3800,$BF42,$BF41,$0740,$B8BF
                DC.W $C000,$4000,$4000,$8000,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$03,$00,$07
                DC.W $CBF6,$0BF6,$0B81,$F476,$ED2D,$F7DE,$F3DE,$E92D
                DC.W $BF99,$6066,$6066,$BF99,$9BE5,$4408,$7DFB,$EF5E
                DC.W $DDCB,$0210,$BE77,$EBBA,$FE73,$84,$839C,$FDEF
                DC.W $FE57,$18,$01A0,$FE4F,$FFB9,$83FE,$00,$7C00
                DC.W $DFA6,$DFA1,$03A0,$DC5F,$00,$8000,$00,$C000
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $08,$0B,$00,$0F,$87FE,$07FF,$07C1,$F83E
                DC.W $DA1B,$EFFC,$E7FC,$D21B,$1FB7,$E04C,$E04C,$1FB7
                DC.W $B6BE,$4040,$7FFF,$AF6D,$6DD1,$820C,$BE7F,$DBBE
                DC.W $7F7B,$8084,$83BC,$FDEF,$EEDF,$00,$1120,$EEDF
                DC.W $BFA1,$C39E,$40,$7C00,$FFC2,$FFC1,$07C0,$F83F
                DC.W $2000,$A000,$00,$E000,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$09,$0E,$00,$0F
                DC.W $CBF6,$0BF7,$0B81,$F474,$B436,$DFF9,$CFF9,$A436
                DC.W $FF6A,$C09D,$C09D,$FF6A,$F9B2,$8041,$9FFF,$F6ED
                DC.W $66EB,$0100,$BF7F,$5BDC,$5EFB,$2004,$E3FC,$FDCF
                DC.W $FEEF,$30,$0100,$FEDF,$7E51,$02CE,$8120,$7C80
                DC.W $DFA7,$5FA0,$03A0,$5C5F,$2000,$E000,$00,$E000
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $0C,$0B,$08,$07,$87FC,$07FD,$07C3,$F83C
                DC.W $6E6D,$BFF3,$9FF3,$4E6D,$FFD5,$803B,$803B,$FFD5
                DC.W $7F3C,$80C2,$8FDF,$79B2,$FAFC,$00,$3F3F,$E5E3
                DC.W $F7D5,$0802,$FBFE,$1E2F,$FEFE,$00,$0101,$FEFE
                DC.W $7AAB,$0324,$8450,$7980,$FFC2,$7FC1,$07C0,$783F
                DC.W $6000,$A000,$2000,$C000,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$09,$0E,$08,$07
                DC.W $CBF4,$0BF4,$0B83,$F474,$5FDB,$7FE7,$BFE7,$1FDB
                DC.W $FFBB,$7F,$7F,$FFBB,$FD7F,$0380,$0380,$FD7F
                DC.W $B7FD,$4802,$4802,$B7FD,$FAEF,$0400,$1D3E,$F6F3
                DC.W $FF9B,$21,$44,$FFBA,$EFF7,$0430,$1008,$EBC0
                DC.W $DFA7,$5FA0,$03A0,$5C5F,$2000,$E000,$2000,$C000
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $04,$03,$00,$0F,$87FF,$07FF,$07C0,$F83C
                DC.W $27B7,$BFCE,$7FCE,$27B7,$F7CE,$087F,$087F,$F7CE
                DC.W $FAFF,$0700,$0700,$FAFF,$07DF,$B800,$F820,$07DF
                DC.W $FDFF,$00,$0606,$FDFD,$FBB6,$04,$0449,$FBB2
                DC.W $FFFB,$0438,$04,$FBC0,$FFC2,$7FC1,$07C0,$783F
                DC.W $4000,$8000,$00,$E000,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$01,$06,$00,$0F
                DC.W $CBFC,$0BFF,$0BA0,$F45C,$A96F,$DF9C,$499C,$3F6F
                DC.W $FFB7,$CE,$CE,$FFB7,$F5FF,$0E00,$0EF8,$F587
                DC.W $CFB7,$1008,$3048,$CFB7,$FB71,$80,$048E,$FB71
                DC.W $FBF3,$00,$040C,$FBF3,$FBBF,$3A,$0440,$FB84
                DC.W $FFA7,$7FA0,$0BA0,$745F,$00,$C000,$00,$E000
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $04,$03,$00,$0F,$87FE,$07FD,$07C0,$F83C
                DC.W $6EDB,$133C,$933C,$6EDB,$DF6D,$219E,$219E,$DF6D
                DC.W $EF97,$1C20,$1CFC,$EF7B,$AEBF,$1100,$5140,$AEBF
                DC.W $F7F3,$00,$080C,$F7F3,$FFEF,$08,$10,$FFE7
                DC.W $DFB8,$3D,$2042,$DF84,$FFC2,$7FC1,$07C0,$783F
                DC.W $4000,$8000,$00,$E000,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$01,$06,$00,$0F
                DC.W $CBFE,$0BFD,$0BA0,$F45C,$59B7,$2678,$8278,$7DB7
                DC.W $BCEB,$431C,$431C,$BCEB,$CBFF,$3C00,$3DC8,$CB77
                DC.W $DD2F,$2210,$22D0,$DD2F,$72F5,$8502,$8908,$76F7
                DC.W $FFF3,$14,$08,$FFE7,$D7F8,$7D,$2802,$D784
                DC.W $FFA7,$7FA0,$0BA0,$745F,$00,$C000,$00,$E000
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $04,$03,$00,$0F,$85FE,$05FD,$05C0,$FA3C
                DC.W $5B4E,$24F1,$A4F1,$5B4E,$39DF,$C638,$C638,$39DF
                DC.W $D6BB,$3840,$39D4,$D77B,$D946,$2639,$26B9,$D946
                DC.W $EAF3,$0504,$1108,$EEF7,$F7D6,$10,$0829,$F7C6
                DC.W $F748,$204D,$0892,$D724,$FF42,$7F41,$0740,$78BF
                DC.W $4000,$8000,$00,$E000,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$01,$06,$00,$0F
                DC.W $CBFE,$0BFD,$0BA0,$F45C,$CF3D,$B0C3,$30C3,$4F3D
                DC.W $7FD7,$8038,$8038,$7FD7,$9F33,$7040,$71CC,$9EF3
                DC.W $F280,$0C7F,$0D7F,$F280,$C7E3,$0804,$3018,$CFE7
                DC.W $67E7,$28,$9800,$67DF,$9F6F,$4A,$6090,$9F24
                DC.W $FFA7,$7FA0,$0BA0,$745F,$00,$C000,$00,$E000
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $04,$03,$00,$0F,$85FF,$05FE,$05D0,$FA2E
                DC.W $36F8,$9907,$5907,$36F8,$F7AF,$0870,$0870,$F7AF
                DC.W $6FB7,$B040,$B3C8,$6EF7,$F530,$08CF,$0ACF,$F530
                DC.W $D5E5,$0A02,$2218,$DDE7,$6FB5,$28,$9042,$6F9D
                DC.W $FF89,$40AA,$14,$BF60,$FF42,$FF41,$1740,$E8BF
                DC.W $4000,$8000,$00,$E000,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$04,$03,$00,$0F
                DC.W $C2FF,$02FE,$02E0,$FD1E,$69F5,$DE0E,$1E0E,$29F5
                DC.W $FFDF,$60,$60,$FFDF,$DFE7,$2000,$27D8,$D827
                DC.W $EC39,$11C6,$13C6,$EC39,$8DC2,$1200,$623D,$9DC2
                DC.W $EF8D,$10,$1042,$EFBD,$F7ED,$408E,$0810,$B760
                DC.W $FE86,$FE81,$0E80,$F17F,$4000,$8000,$00,$E000
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $0C,$0B,$08,$07,$817F,$017F,$0150,$FEAF
                DC.W $9E0B,$4FFC,$2FFC,$1E0B,$FFBB,$C4,$C4,$FFBB
                DC.W $BD6F,$4000,$47D0,$BEEF,$D871,$238E,$278E,$D871
                DC.W $EBC0,$1400,$043F,$FBC0,$CFED,$50,$3002,$CFBD
                DC.W $362B,$4D,$C910,$36E1,$FD02,$FD01,$1500,$EAFF
                DC.W $6000,$A000,$2000,$C000,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$08,$0B,$08,$07
                DC.W $C2FF,$02FF,$02E8,$FD17,$B7F3,$6FFC,$0FFC,$17F3
                DC.W $7A7F,$8580,$8580,$7A7F,$3B4E,$C480,$C7BF,$3AD1
                DC.W $D9EB,$2614,$FEF7,$A59A,$9FA0,$2001,$E75E,$78A1
                DC.W $DF59,$60,$86,$FF39,$BFEB,$810D,$4010,$3EE1
                DC.W $FE86,$FE81,$2E80,$D17F,$2000,$A000,$2000,$C000
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $08,$0B,$08,$07,$817F,$017F,$0174,$FE8B
                DC.W $CBE1,$A7FE,$17FE,$8BE1,$E6E6,$1919,$1919,$E6E6
                DC.W $FD7B,$8084,$83BD,$FEEE,$E597,$0208,$FFFF,$1B6D
                DC.W $5BF3,$8000,$EF8C,$B773,$BF1B,$20,$4084,$BF7B
                DC.W $8F67,$818B,$7010,$0EE3,$FD02,$FD01,$5D00,$A2FF
                DC.W $2000,$A000,$2000,$C000,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$0A,$09,$00,$0F
                DC.W $40BF,$80BF,$BA,$FF45,$F5D1,$93EE,$0BEE,$85D1
                DC.W $D5CD,$3A33,$3A33,$D5CD,$7E97,$8008,$837B,$7DAE
                DC.W $FD52,$0229,$FFFF,$DAED,$8EF1,$3102,$FF8C,$E9F3
                DC.W $1EF2,$2080,$810D,$7E72,$EEDF,$C013,$1120,$2EC3
                DC.W $FA04,$FA03,$BA00,$45FF,$A000,$2000,$00,$E000
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $0A,$09,$00,$0F,$605F,$805F,$5D,$FFA2
                DC.W $EE37,$D9CC,$01CC,$C637,$2FBA,$F067,$F067,$2FBA
                DC.W $FFA5,$08,$037B,$FD9E,$27BC,$9841,$FDCF,$DEFB
                DC.W $ED73,$1084,$1788,$EEF7,$FEB2,$80C0,$010D,$7E72
                DC.W $86EF,$A037,$5901,$26C6,$F40C,$F403,$7400,$8BFF
                DC.W $A000,$2000,$00,$E000,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$05,$04,$04,$03
                DC.W $40AF,$80AF,$AE,$FF51,$F76A,$EC9D,$809D,$636A
                DC.W $DB75,$E4CE,$E4CE,$DB75,$FEF6,$0108,$033F,$FDDD
                DC.W $4BBE,$9441,$F5DF,$BAF3,$CD3A,$1084,$37C1,$FEBE
                DC.W $3C35,$4041,$030A,$FCF4,$D3DF,$A06F,$0C02,$738D
                DC.W $EA05,$EA02,$EA00,$15FF,$4000,$4000,$4000,$8000
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $05,$04,$04,$03,$2057,$C057,$57,$FFA8
                DC.W $FBD1,$F63F,$403F,$B1D1,$AEAD,$D9DE,$D9DE,$AEAD
                DC.W $FEEA,$0101,$033F,$FDDD,$F975,$0600,$E7FF,$B8EB
                DC.W $73E6,$8008,$9F11,$EDEE,$FCE5,$01,$031A,$FCE4
                DC.W $39BF,$40DF,$0605,$F91A,$D409,$D406,$D400,$2BFF
                DC.W $4000,$4000,$4000,$8000,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$04,$04,$00,$07
                DC.W $B02B,$402B,$2B,$FFD4,$FDD3,$FB3F,$A03F,$58D3
                DC.W $355B,$FBBC,$FBBC,$355B,$EEFE,$1101,$133F,$EDE3
                DC.W $D5EB,$2E00,$6FFF,$B51C,$DEE7,$2109,$FF10,$73EE
                DC.W $7A27,$8283,$0558,$F8A4,$B97F,$41BF,$060B,$F834
                DC.W $A81A,$A804,$A800,$57FF,$4000,$4000,$00,$C000
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $26,$06,$02,$05,$8215,$6015,$15,$FFEA
                DC.W $FEAE,$FD9F,$D05F,$2C2E,$6AFB,$F73C,$F73C,$6AFB
                DC.W $DFB9,$2006,$2046,$DFB9,$EDB7,$1E08,$1E48,$EDB7
                DC.W $AE7C,$1080,$F102,$DEFD,$7B03,$8343,$04BC,$F840
                DC.W $7AFF,$837F,$0417,$F868,$5082,$500C,$5000,$AFFF
                DC.W $C800,$C000,$8000,$4000,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$02,$22,$42,$01
                DC.W $500A,$200A,$0A,$FFF5,$FF57,$FECF,$F82F,$0617
                DC.W $D5F9,$EE7E,$EE7E,$D5F9,$BD55,$422E,$428E,$BD75
                DC.W $CB25,$3C18,$3CDA,$CB25,$FFCD,$10,$1022,$FFDD
                DC.W $F785,$07A5,$085A,$F020,$65FE,$86FE,$183E,$E0C1
                DC.W $A014,$A008,$A000,$5FFF,$8000,$8800,$8400,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $13,$23,$C1,$02,$2105,$1005,$05,$FFFA
                DC.W $7FD5,$7F33,$7C0B,$8305,$ABFC,$DCFF,$DCFF,$ABFC
                DC.W $B2AF,$CC5E,$CD1E,$B2EF,$166B,$F810,$F994,$166B
                DC.W $BCDA,$4103,$0224,$FDD9,$FDCD,$0DCD,$0232,$F000
                DC.W $97FD,$19FD,$607D,$8182,$4109,$4011,$4001,$BFFE
                DC.W $9000,$8800,$0600,$8000,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$91,$21,$0141,$80
                DC.W $1882,$02,$02,$FFFD,$AFE5,$AFDC,$AF02,$50C1
                DC.W $469F,$F9FF,$F9FF,$469F,$6A5F,$9CBF,$9D3F,$6ADF
                DC.W $BC4A,$F0B0,$F335,$BCCA,$7ADA,$8103,$0424,$FBD9
                DC.W $E9F9,$09F9,$1606,$E000,$5FEA,$67EA,$81EA,$0615
                DC.W $8231,$8001,$8001,$7FFE,$1200,$0800,$0500,$0200
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $01C9,$71,$0200,$0181,$8CC0,$8000,$8000,$7FFF
                DC.W $57F9,$57F7,$57C0,$A830,$4C5F,$33BF,$B3BF,$4C5F
                DC.W $94DE,$F93F,$FA3F,$95DE,$6CCD,$B130,$B232,$6DCD
                DC.W $79F6,$8207,$0408,$FBF1,$F2F9,$14F9,$0106,$EE00
                DC.W $7FD4,$9FD4,$07D4,$182B,$0663,$03,$02,$FFFD
                DC.W $2700,$1C00,$80,$0300,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$07C8,$70,$00,$0780
                DC.W $8460,$8000,$8000,$7FFF,$2BFE,$2BFD,$2BF0,$D40C
                DC.W $55CF,$CA3F,$2A3F,$15CF,$E1A9,$FA7E,$FC7E,$E3A9
                DC.W $DA98,$6161,$6466,$DB99,$F1B6,$0207,$0C48,$F3B1
                DC.W $DB7D,$147E,$2080,$CF00,$FFA8,$7FA8,$1FA8,$6057
                DC.W $0C42,$02,$02,$FFFC,$27C0,$1C00,$00,$03C0
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $0F14,$78,$80,$0F00,$C230,$C000,$4000,$BFFF
                DC.W $057F,$057F,$057C,$FA83,$9BF3,$780F,$040F,$03F3
                DC.W $D754,$E0E8,$E8EB,$D754,$D998,$6261,$6466,$DB99
                DC.W $F3EE,$0E,$0C11,$F3E0,$4667,$8879,$2180,$DE01
                DC.W $FD40,$FD40,$7D40,$82BF,$18A6,$06,$04,$FFFA
                DC.W $51E0,$3C00,$0200,$01E0,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$1F2C,$78,$80,$1F00
                DC.W $441C,$4000,$4000,$3FFF,$02BF,$02BF,$02BF,$FD40
                DC.W $F33E,$CF01,$C1,$C03E,$3E99,$C1C0,$C1E6,$3E99
                DC.W $B331,$C4C0,$C8CE,$B731,$6BDF,$801F,$1420,$EBC0
                DC.W $233F,$2BC7,$C401,$1806,$FA80,$FA80,$FA80,$057F
                DC.W $7044,$04,$04,$FFF8,$69F0,$3C00,$0200,$01F0
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $07DA,$387C,$3800,$0780,$620F,$6000,$2000,$5FFF
                DC.W $57,$57,$57,$FFA8,$FF33,$F8F0,$E00C,$1803
                DC.W $FCB2,$0301,$034D,$FCB2,$7E30,$81C0,$81CF,$7E30
                DC.W $6FBF,$3F,$9040,$6F80,$F1FF,$FE3F,$0F,$30
                DC.W $D401,$D400,$D400,$2BFF,$E0CC,$0C,$08,$FFF4
                DC.W $B3C0,$7A38,$0438,$01C0,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$36F6,$7974,$7808,$3780
                DC.W $2307,$2000,$00,$3FFF,$C02A,$2A,$2A,$FFD5
                DC.W $FFF1,$FF8F,$FC00,$0380,$8F06,$8001,$70F9,$0F06
                DC.W $EF30,$C0,$10CF,$EF30,$FF7E,$7F,$80,$FF00
                DC.W $1FFE,$E1FE,$7E,$0181,$A807,$A800,$A800,$57FF
                DC.W $C188,$08,$00,$FFF8,$D9D8,$5F3C,$243C,$D8
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $7529,$FA2A,$F8D4,$7700,$1142,$1080,$1000,$0FFF
                DC.W $F005,$05,$05,$FFFA,$7FFF,$7FF0,$7F80,$8070
                DC.W $C0E0,$3FE0,$1F,$00,$00,$00,$FFFF,$00
                DC.W $0383,$03FC,$FC00,$00,$FFFD,$1FFD,$03FD,$1C02
                DC.W $401E,$4000,$4000,$BFFF,$8511,$0210,$10,$FFE0
                DC.W $28DC,$AFBE,$503E,$065C,$00,$00,$00,$00
                DC.W $00,$01,$01,$00,$EDB3,$F632,$F64C,$ED80
                DC.W $19A1,$1840,$0800,$17FF,$7C00,$00,$00,$FFFF
                DC.W $AFFF,$AFFF,$AFE8,$5017,$FFE0,$1F,$00,$00
                DC.W $00,$FFFF,$00,$00,$01FF,$FE01,$00,$01
                DC.W $FFEA,$FFEA,$2FEA,$D015,$7D,$00,$00,$FFFF
                DC.W $0B31,$0430,$20,$FFD0,$9D4E,$96FF,$663F,$0D0E
                DC.W $00,$00,$00,$00,$01,$03,$03,$01
                DC.W $D924,$EE21,$EEDA,$D904,$8CC8,$0C30,$0400,$0BFF
                DC.W $5F80,$00,$00,$FFFF,$55FF,$55FF,$55FD,$AA02
                DC.W $FFFF,$FC00,$00,$FC00,$FFFF,$00,$00,$00
                DC.W $FFFF,$3F,$01,$3E,$FF54,$FF54,$7F54,$80AB
                DC.W $03F4,$00,$00,$FFFF,$2662,$1861,$40,$FFA0
                DC.W $42A7,$0D7F,$B51F,$4A87,$00,$8000,$8000,$00
                DC.W $03,$07,$07,$03,$2297,$DD11,$CD68,$3286
                DC.W $0662,$861C,$0200,$05FF,$2BF0,$00,$00,$FFFF
                DC.W $0AAF,$0AAF,$0AAF,$F550,$FFFF,$FFF8,$A800,$57F8
                DC.W $FFFF,$00,$00,$00,$FFFF,$3FFF,$2B,$3FD4
                DC.W $EAA0,$EAA0,$EAA0,$155F,$1FA8,$00,$00,$FFFF
                DC.W $8CC1,$70C3,$80,$FF40,$D151,$0E3F,$2A8F,$D541
                DC.W $8000,$C000,$C000,$8000,$04,$0F,$0F,$04
                DC.W $44B5,$BF52,$9D4A,$66A5,$C330,$830F,$0100,$02FF
                DC.W $C57E,$00,$00,$FFFF,$0155,$0155,$0155,$FEAA
                DC.W $FFFF,$FFFF,$FF50,$AF,$FFFF,$FFFF,$00,$FFFF
                DC.W $FFFF,$FFFF,$15FF,$EA00,$5500,$5500,$5500,$AAFF
                DC.W $FD42,$01,$00,$FFFF,$1987,$E182,$0100,$FE81
                DC.W $6ACC,$9C3B,$9D23,$6AC4,$4000,$E000,$E000,$4000
                DC.W $01,$1E,$1E,$01,$C868,$7F8F,$7B97,$CC60
                DC.W $2199,$4187,$8081,$017F,$30AF,$C000,$00,$FFFF
                DC.W $C00A,$0A,$0A,$FFF5,$AFFF,$AFFF,$AFFA,$5005
                DC.W $FFFF,$FFFF,$AAAA,$5555,$FFEA,$FFEA,$BFEA,$4015
                DC.W $A007,$A000,$A000,$5FFF,$EA19,$07,$01,$FFFF
                DC.W $3308,$C305,$0203,$FD00,$1497,$FB6C,$F360,$1C93
                DC.W $00,$F000,$F000,$00,$07,$38,$38,$07
                DC.W $80C7,$FF03,$AF3B,$D0C7,$10CC,$A0C3,$C040,$BF
                DC.W $4615,$F800,$4000,$FFFF,$7C01,$01,$01,$FFFE
                DC.W $555F,$555F,$555F,$AAA0,$FFFF,$FFFF,$FFFF,$00
                DC.W $F555,$F555,$F555,$0AAA,$7D,$00,$00,$FFFF
                DC.W $50C4,$3F,$04,$FFFF,$6611,$860B,$0407,$FA01
                DC.W $842B,$FFC6,$DFD0,$A429,$C000,$3800,$3800,$C000
                DC.W $7D,$01,$03,$7D,$A5BF,$FE05,$FE41,$A5BB
                DC.W $8866,$D061,$E020,$805F,$1AE0,$FF00,$1A00,$FFFF
                DC.W $ABC0,$00,$00,$FFFF,$0AAA,$0AAA,$0AAA,$F555
                DC.W $AAAA,$AAAA,$AAAA,$5555,$AAA0,$AAA0,$AAA0,$555F
                DC.W $07AA,$00,$00,$FFFF,$0EB0,$01FF,$B0,$FFFF
                DC.W $CC23,$0C17,$080F,$F403,$4051,$FF8F,$F7AC,$4850
                DC.W $7C00,$00,$8000,$7C00,$E3,$03,$1F,$E3
                DC.W $4A8B,$FD72,$7974,$CE89,$C431,$E830,$F010,$C02F
                DC.W $8F56,$7FE8,$0F40,$FFFF,$0C,$00,$00,$FFFF
                DC.W $8055,$55,$55,$FFAA,$5555,$5555,$5555,$AAAA
                DC.W $5402,$5400,$5400,$ABFF,$6001,$00,$00,$FFFF
                DC.W $D5E3,$2FFC,$05E0,$FFFF,$1846,$182F,$101F,$E806
                DC.W $92E4,$FF19,$9B1A,$F6E4,$8E00,$8000,$7000,$0E00
                DC.W $0E,$0F,$01F6,$07,$C03F,$FFC7,$FBC0,$C438
                DC.W $E218,$7418,$7808,$E017,$C5D5,$3FFE,$05D4,$FFFF
                DC.W $7500,$8000,$00,$FFFF,$00,$00,$00,$FFFF
                DC.W $00,$00,$00,$FFFF,$00,$00,$00,$FFFF
                DC.W $015D,$02,$00,$FFFF,$5746,$FFF8,$5740,$FFFF
                DC.W $308D,$305F,$203F,$D00D,$3C08,$FFF0,$3FF7,$FC08
                DC.W $6000,$E000,$1F00,$00,$37,$38,$03C0,$00
                DC.W $FFFF,$00,$00,$00,$F10C,$BA0C,$3C04,$700B
                DC.W $32FD,$0FFF,$02FD,$FFFF,$55D5,$EA00,$4000,$FFFF
                DC.W $00,$00,$00,$FFFF,$00,$00,$00,$FFFF
                DC.W $01,$00,$00,$FFFF,$5755,$AF,$05,$FFFF
                DC.W $7E98,$FFE0,$7E80,$FFFF,$611F,$60BA,$4078,$A01C
                DC.W $FFFF,$00,$00,$00,$D800,$3800,$0780,$00
                DC.W $01D9,$01E7,$0600,$00,$FFE0,$FFFF,$00,$00
                DC.W $8883,$5D03,$3E03,$0800,$1C5F,$03FF,$5F,$FFFF
                DC.W $D52B,$FFD4,$D500,$FFFF,$D555,$00,$00,$FFFF
                DC.W $5555,$00,$00,$FFFF,$5557,$00,$00,$FFFF
                DC.W $A957,$57FF,$0157,$FFFF,$F471,$FF81,$F401,$FFFE
                DC.W $8222,$8175,$80F8,$20,$0FFF,$FFFF,$00,$00
                DC.W $3700,$CF00,$C0,$00,$0F67,$0F9F,$00,$00
                DC.W $A31A,$A01F,$5CE0,$0300,$61E1,$9681,$0E01,$0100
                DC.W $872B,$80FF,$802B,$7FFF,$FEAA,$FFFF,$FEAA,$FFFF
                DC.W $055F,$FAA0,$00,$FFFF,$FFFF,$00,$00,$FFFF
                DC.W $F540,$0ABF,$00,$FFFF,$AAFF,$FFFF,$AAFF,$FFFF
                DC.W $A9C3,$FE03,$A803,$FFFC,$0F0C,$02D3,$E0,$0100
                DC.W $B18B,$F00B,$0E74,$0180,$CDE0,$F3E0,$00,$00
                DC.W $119D,$1E7D,$02,$00,$57CD,$400F,$A830,$17C0
                DC.W $1A50,$E660,$0180,$00,$E1C5,$E03F,$6005,$9FFF
                DC.W $5FFF,$FFFF,$5FFF,$FFFF,$5540,$FFFF,$5540,$FFFF
                DC.W $00,$FFFF,$00,$FFFF,$55,$FFFF,$55,$FFFF
                DC.W $FFF5,$FFFF,$FFF5,$FFFF,$470E,$F80E,$400C,$FFF2
                DC.W $14B1,$0CCF,$0300,$00,$67D5,$E005,$182A,$07D0
                DC.W $7310,$7CF0,$8000,$00,$0E6A,$31EA,$15,$00
                DC.W $2FE6,$07,$D018,$2FE0,$8A94,$F598,$60,$00
                DC.W $7070,$700F,$3000,$4FFF,$ABFF,$FFFF,$ABFF,$FFFF
                DC.W $FFEA,$FFFF,$FFEA,$FFFF,$AAAA,$FFFF,$AAAA,$FFFF
                DC.W $ABFF,$FFFF,$ABFF,$FFFF,$FFAA,$FFFF,$FFAA,$FFFF
                DC.W $1C1C,$E01C,$18,$FFE4,$52A2,$335F,$0C00,$00
                DC.W $CFE8,$C000,$3017,$0FE8,$ACE0,$AF18,$5000,$00
                DC.W $71D4,$0FD4,$2B,$00,$5FE7,$07,$A018,$5FE0
                DC.W $4595,$FA76,$08,$00,$1C1E,$1C01,$0C00,$13FF
                DC.W $157F,$FFFF,$157F,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
                DC.W $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
                DC.W $FD50,$FFFF,$FD50,$FFFF,$F071,$70,$60,$FF90
                DC.W $5345,$DCBF,$2000,$00,$CFF4,$C000,$300B,$0FF4
                DC.W $571C,$57E0,$A800,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $0E83,$0E80,$0680,$097F,$82AF,$7FFF,$02AF,$FFFF
                DC.W $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
                DC.W $FFFF,$FFFF,$FFFF,$FFFF,$EA83,$FFFC,$EA80,$FFFF
                DC.W $82E0,$02E0,$02C0,$FD20,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$03D0,$03D0,$01D0,$022F
                DC.W $7015,$0FFF,$15,$FFFF,$7FFF,$FFFF,$7FFF,$FFFF
                DC.W $FFFF,$FFFF,$FFFF,$FFFF,$FFFD,$FFFF,$FFFD,$FFFF
                DC.W $501C,$FFE0,$5000,$FFFF,$1780,$1780,$1700,$E880
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $0200,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $FC,$FC,$7C,$83,$1E42,$01BF,$02,$FFFF
                DC.W $AAFF,$FFFF,$AAFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
                DC.W $FEAA,$FFFF,$FEAA,$FFFF,$84F0,$FB00,$8000,$FFFF
                DC.W $7E00,$7E00,$7C00,$8200,$00,$00,$00,$00
                DC.W $04,$04,$00,$04,$0C00,$0400,$00,$0400
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$3E,$3E,$1E,$21
                DC.W $83E8,$8017,$8000,$7FFF,$1557,$FFFF,$1557,$FFFF
                DC.W $FFFF,$FFFF,$FFFF,$FFFF,$D550,$FFFF,$D550,$FFFF
                DC.W $2F82,$D002,$02,$FFFD,$F800,$F800,$F000,$0800
                DC.W $00,$00,$00,$00,$0E,$0A,$00,$0A
                DC.W $0C00,$0800,$00,$0800,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $0F,$0F,$03,$0C,$D075,$D00A,$D000,$2FFF
                DC.W $2A,$FFFF,$2A,$FFFF,$AAAA,$FFFF,$AAAA,$FFFF
                DC.W $A801,$FFFE,$A800,$FFFF,$5C17,$A017,$17,$FFE8
                DC.W $E000,$E000,$8000,$6000,$00,$00,$00,$00
                DC.W $19,$10,$00,$10,$1C00,$0800,$00,$0800
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$03,$01,$00,$01
                DC.W $FA0F,$FA00,$7A00,$85FF,$A805,$57FF,$05,$FFFF
                DC.W $5555,$FFFF,$5555,$FFFF,$402B,$FFD4,$4000,$FFFF
                DC.W $E0BF,$BF,$BC,$FF43,$8000,$00,$00,$00
                DC.W $00,$00,$00,$00,$1D,$08,$01,$09
                DC.W $BFE0,$DA40,$2480,$BEC0,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$7F40,$7F40,$1F40,$60BF
                DC.W $F540,$0ABF,$00,$FFFF,$00,$FFFF,$00,$FFFF
                DC.W $055E,$FAA0,$00,$FFFF,$05FE,$05FC,$05F0,$FA0C
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $07,$07,$00,$07,$6DA0,$6DA0,$00,$6DA0
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $1FE8,$0FE8,$03E8,$0C17,$07AA,$55,$00,$FFFF
                DC.W $AAAA,$5555,$00,$FFFF,$ABC0,$5400,$00,$FFFF
                DC.W $2FF0,$2FE0,$2F80,$D060,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$06,$03,$00,$02
                DC.W $FB30,$BFA0,$00,$BB20,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$03FD,$01FD,$7D,$0182
                DC.W $407F,$4000,$4000,$BFFF,$FFFF,$00,$00,$FFFF
                DC.W $FC05,$05,$05,$FFFA,$7F80,$7F00,$7C00,$8300
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $02,$0C,$00,$00,$68,$0930,$00,$20
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $7F,$3F,$0F,$30,$EA80,$EA80,$EA80,$157F
                DC.W $00,$00,$00,$FFFF,$02AF,$02AF,$02AF,$FD50
                DC.W $FC00,$F800,$E000,$1800,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$08,$10,$00,$00
                DC.W $0914,$08,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$07,$03,$00,$03
                DC.W $FFEA,$FFEA,$FFEA,$15,$AAAA,$AAAA,$AAAA,$5555
                DC.W $AFFF,$AFFF,$AFFE,$5001,$C000,$8000,$00,$8000
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$20,$00,$00,$08,$04,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$3FFF,$1FFF,$03FF,$1C00
                DC.W $FFFF,$FFFF,$FFFF,$00,$FFF8,$FFF0,$FF80,$70
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$40,$00,$00,$00
                DC.W $02,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $01FF,$3F,$00,$3F,$FFFF,$FFFF,$00,$FFFF
                DC.W $FF00,$F800,$00,$F800,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00

                ENDPART

insel_dat:      IBYTES 'INSEL.DAT'
                EVEN
seat_dat:       IBYTES 'SEAT.DAT'
                EVEN

****************************************
module:         IBYTES 'BLADERU2.MOD'
                BSS
bss_start:      DS.L 190000/4
                DS.W 20000

depack_lo:      DS.B 256
depack_hi:      DS.B 256

key:            DS.W 1
save_mfp:       DS.L 6
save_system:    DS.L 9
black:          DS.L 8

********** one font line ************

font_buffer:    DS.W 60*16

                DS.W 256
screen_mem:     DS.L 8000
                DS.W 80
                DS.W 256
bss_end:
                END
