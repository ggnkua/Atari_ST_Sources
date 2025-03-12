**********************************************************************
* Blitter text-scroll by Techwave
* 1 plane 32*32 >10 scanlines
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

                move.l    #screen,screen1

b_init:         move.b    #2,$ffff8a3a.w          ; hop
                move.b    #3,$ffff8a3b.w          ; op
                move.w    #$ffff,$ffff8a2a.w      ; endmask 2
                move.w    #$ffff,$ffff8a2c.w      ; endmask 3
                move.w    #8,$ffff8a20.w          ; src x inc
                move.w    #8,$ffff8a2e.w          ; des x inc

i_init:         move.l    $70.w,oldvbl
                move.l    #vbl,$70.w

                move.w    #7,-(sp)
                trap      #1
                addq.l    #2,sp
                rts

**********************************************************************
vbl:            not.w     $ffff8240.w
                movem.l   d0-a6,-(sp)

                lea       screen1+1(pc),a0
                move.b    (a0)+,$ffff8205.w
                move.b    (a0)+,$ffff8207.w
                move.b    (a0)+,$ffff8209.w

                bsr       b_scrl
                bsr       b_charout

                movem.l   (sp)+,d0-a6
                not.w     $ffff8240.w
                rte
**********************************************************************

b_scrl:
                move.w    #$ffff,$ffff8a28.w      ; endmask 1
                move.w    #8,$ffff8a22.w          ; src y inc
                move.w    #8,$ffff8a30.w          ; des y inc


                move.l    #screen,$ffff8a24.w     ; src addr
                move.l    #screen-8,$ffff8a32.w   ; des addr
                move.w    #21,$ffff8a36.w         ; x-cnt
                move.w    #31,$ffff8a38.w         ; y-cnt

                move.b    #%1100,$ffff8a3d.w      ; skew
                move.b    #%11000000,$ffff8a3c.w
                rts

* --------------------------------------------------------------------
b_charout:      lea       fontpic+128(pc),a0
                move.w    offset,d0
                adda.w    d0,a0
                move.l    a0,$ffff8a24.w          ; src addr

                lea       screen+152,a1
                move.l    a1,$ffff8a32.w          ; des addr

                move.w    #$0f,$ffff8a28.w        ; endmask 1
                move.w    #160,$ffff8a22.w        ; src y inc
                move.w    #160,$ffff8a30.w        ; des y inc

                move.w    #1,$ffff8a36.w          ; x cnt
                move.w    #32,$ffff8a38.w         ; y cnt

                move.b    to_skew(pc),$ffff8a3d.w
                move.b    #%11000000,$ffff8a3c.w

                btst      #0,space_flg
                beq.s     not_space
                bclr      #0,space_flg
                bra.s     read

not_space:      cmpi.b    #0,to_skew
                bne.s     notend

                move.b    #12,to_skew
                tst.b     second_flg
                bne.s     ready
                addq.w    #8,offset
                st        second_flg
                rts

ready:          sf        second_flg
                st        space_flg
                move.w    #0,offset
                rts

notend:         subq.b    #4,to_skew
                rts


read:           move.w    #0,d0
                lea       txt,a0
                adda.w    txt_pointer,a0
                move.b    (a0),d0
                tst.b     d0
                bne.s     ascii
                move.w    #0,txt_pointer
                bra.s     read

ascii:          sub.b     #32,d0
                add.w     d0,d0
                lea       char_off,a0
                move.w    0(a0,d0.w),offset
                addq.w    #1,txt_pointer
                rts

* --------------------------------------------------------------- restore

back:           move.l    oldvbl,$70.w
                rts


* --------------------------------------------------------------- data
* starts with "space", 32
char_off:     dc.w $00,$10,$20
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
              dc.b " 0123456789 ABCDEFGHIJKLMNOPQRSTUVWXYZ   "
              dc.b 0

              even

* --------------------------------------------------------------------

oldvbl:       dc.l 0

to_skew:      dc.b 12
space_flg:    dc.b 0
second_flg:   dc.b 0
              even

txt_pointer:  dc.w 0
offset:       dc.w 0
screen1:      dc.l 0

fontpic:      ibytes 'DRAGFONT.NEO'
screen:       ds.b 32000
              end
