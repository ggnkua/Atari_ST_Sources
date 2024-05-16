**********************************************************************
* Hi... this source is for Turbo-Ass (!!!)....
* (Men det g†r n„stan lika bra med Deve-Devpakken...)
* The source is old, but it shows what ya' can do with hardware-scrolling....
* The source is -NOT- completed or optimized in any way... it's up to YOU!!
* (Det „r ej n†gra tecken-avst†nd...osv...osv...)
* Du f†r dissekera koden hur fasen du vill... bye!
**********************************************************************
* Hardware text-scroll (using no blitter) by Techwave of I.C.E.!     *
* (4 planes) 32*32                                                   *
**********************************************************************
                clr.l     -(sp)
                move.w    #$20,-(sp)
                trap      #1
                addq.l    #6,sp

                move.w    #0,-(sp)
                move.l    #-1,-(sp)
                move.l    #-1,-(sp)
                move.w    #5,-(sp)
                trap      #14
                lea       12(sp),sp


                lea       fontpic+4(pc),a0
                lea       $ffff8240.w,a1
              rept 8
                move.l    (a0)+,(a1)+
              endr


i_init:         move.l    $70.w,oldvbl
                move.l    #vbl,$70.w

                move.w    #7,-(sp)
                trap      #1
                addq.l    #2,sp
                rts

**********************************************************************
**********************************************************************
vbl:
              rept 5000                       ; wait, so U can see the time!
                nop
              endr

                move.w    #$0300,$ffff8240.w
                movem.l   d0-a6,-(sp)

                bsr.s     hard_txtscrl

                movem.l   (sp)+,d0-a6
                move.w    #$00,$ffff8240.w
                rte

**********************************************************************
**********************************************************************
hard_txtscrl:
                move.w    scroll(pc),d1
                add.w     #16+16,d1

                move.w    d1,d2
                and.b     #$0f,d1
                move.b    d1,$ffff8265.w
                bne.s     fix_line
                move.b    #80+8+4,$ffff820f.w     ; x-words
                bra.s     scrn_poi
fix_line:       move.b    #80-4+8+4,$ffff820f.w
scrn_poi:
                lsr.w     #4,d2
                lsl.w     #3,d2
                move.l    #screen,d0
                add.l     d2,d0

                move.b    d0,$ffff8209.w
                lsr.w     #8,d0
                move.b    d0,$ffff8207.w
                swap      d0
                move.b    d0,$ffff8205.w


                cmpi.b    #4,word_corr
                bne.s     no_gfx_move
                move.b    #0,word_corr
                bsr.s     b_charout
no_gfx_move:    addq.b    #1,word_corr


                cmpi.w    #320+32-4,scroll
                blo.s     inc_poi
                move.w    #0,scroll
                rts
inc_poi:        addi.w    #4,scroll
                rts

**********************************************************************
scroll:       dc.w 0
word_corr:    dc.b 4
              even

**********************************************************************
b_charout:      lea       fontpic+128(pc),a0
                move.w    offset(pc),d0
                adda.w    d0,a0
                movea.l   a0,a2

                lea       screen+8,a1
                move.w    scroll(pc),d0
                and.b     #$f0,d0
                lsr.w     #1,d0
                adda.w    d0,a1

              rept 31
                move.w    (a0)+,(a1)+
                move.w    (a0)+,(a1)+
                move.w    (a0)+,(a1)+
                move.w    (a0)+,(a1)+
                lea       160-8(a0),a0
                lea       336+8-8(a1),a1
              endr
                move.w    (a0)+,(a1)+
                move.w    (a0)+,(a1)+
                move.w    (a0)+,(a1)+
                move.w    (a0)+,(a1)+



                movea.l   a2,a0
                lea       screen+160+8+8+8,a1
                adda.w    d0,a1

              rept 31
                move.w    (a0)+,(a1)+
                move.w    (a0)+,(a1)+
                move.w    (a0)+,(a1)+
                move.w    (a0)+,(a1)+
                lea       160-8(a0),a0
                lea       336+8-8(a1),a1
              endr
                move.w    (a0)+,(a1)+
                move.w    (a0)+,(a1)+
                move.w    (a0)+,(a1)+
                move.w    (a0)+,(a1)+


                tst.b     second_flg              ; for x 32
                bne.s     ready
                addq.w    #8,offset
                st        second_flg
                rts

ready:          sf        second_flg
                move.w    #0,offset

read:           moveq     #0,d0
                lea       txt(pc),a0
                adda.w    txt_pointer(pc),a0
                move.b    (a0),d0
                bne.s     ascii
                move.w    #0,txt_pointer
                bra.s     read

ascii:          sub.b     #32,d0
                add.w     d0,d0
                lea       char_offs(pc),a0
                move.w    0(a0,d0.w),offset
                addq.w    #1,txt_pointer
                rts

**********************************************************************
second_flg:   dc.b 0
txt_pointer:  dc.w 0
offset:       dc.w 0

**********************************************************************
* --------------------------------------------------------------- restore

back:           move.l    oldvbl,$70.w
                move.b    #0,$ffff8264.w
                move.w    #1,-(sp)
                move.l    #-1,-(sp)
                move.l    #-1,-(sp)
                move.w    #5,-(sp)
                trap      #14
                lea       12(sp),sp
                rts

**********************************************************************
* --------------------------------------------------------------- data
* starts with "space", 32
char_offs:    dc.w $00,$10,$20
              dc.w $30,$40,$50
              dc.w $60,$70,$80
              dc.w $90
              dc.w $1400,$1410,$1420
              dc.w $1430,$1440,$1450
              dc.w $1460,$1470,$1480
              dc.w $1490
              dc.w $2800,$2810,$2820
              dc.w $2830,$2840,$2850
              dc.w $2860,$2870,$2880
              dc.w $2890
              dc.w $3c00,$3c10,$3c20
              dc.w $3c30,$3c40,$3c50
              dc.w $3c60,$3c70,$3c80
              dc.w $3c90
              dc.w $5000,$5010,$5020
              dc.w $5030,$5040,$5050
              dc.w $5060,$5070,$5080
              dc.w $5090
              dc.w $6400,$6410,$6420
              dc.w $6430,$6440,$6450
              dc.w $6460,$6470,$6480
              dc.w $6490

* --------------------------------------------------------------------
txt:
              dc.b "INNER CIRCUIT EXPLORERS... - WE BURN YOUR CIRCUITS TO ASHES -      "
              dc.b "0123456789 ABCDEFGHIJKLMNOPQRSTUVWXYZ !#$%&/()=?'    "
              dc.b 0

              even

* --------------------------------------------------------------------

oldvbl:       dc.l 0


fontpic:      ibytes 'DRAGFONT.NEO'
screen:       ds.b 32000
              end
