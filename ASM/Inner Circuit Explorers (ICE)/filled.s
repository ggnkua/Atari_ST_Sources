**********************************************************************
* Polygon fill-route!                                                *
* By Tobias Nilsson, "Techwave"                                      *
**********************************************************************
* v0.01
* new lineroute
* Convex surfaces only!


super:          pea       $00.w
                move.w    #$20,-(sp)
                trap      #1
                addq.w    #6,sp

low:            move.w    #0,-(sp)
                move.l    #-1,-(sp)
                move.l    #-1,-(sp)
                move.w    #5,-(sp)
                trap      #14
                lea       12(sp),sp

                move.w    #0,$ffff8264.w          ; fuck hscroll

                move.w    #$ffff,$ffff8a28.w      ; blitt shit
                move.w    #$ffff,$ffff8a2a.w
                move.w    #$ffff,$ffff8a2c.w

                lea       $ffff8a00.w,a0
                moveq     #0,d0
              rept 8
                move.l    d0,(a0)+
              endr

                bsr       make_xy_tab             ; precalculate x, y tab!


                lea       screen(pc),a0           ; save work-address
                move.l    a0,screen1
                lea       32000(a0),a0
                move.l    a0,screen2

* --------------------------------------------------------------------
i_init:         move.l    $70.w,oldvbl
                move.l    #vbl,$70.w


wait_vbl:       sf        vbl_cnt
wait_lp:        tst.b     vbl_cnt
                beq.s     wait_lp


                move.w    #$ff,-(sp)
                move.w    #6,-(sp)
                trap      #1
                addq.l    #4,sp


                cmp.b     #" ",d0
                beq       back


                move.w    #$0300,$ffff8240.w
                bsr       independent_route
                move.w    #$00,$ffff8240.w

;                not.w     $ffff8240.w
;                not.w     $ffff8240.w

                bra       wait_vbl



vbl_cnt:      dc.b 0
noclr_flg:    dc.b 0
              even

**********************************************************************
**********************************************************************
**********************************************************************
vbl:
                movem.l   d0-a6,-(sp)

                lea       screen2+1(pc),a0
                move.b    (a0)+,$ffff8205.w
                move.b    (a0)+,$ffff8207.w
                move.b    (a0)+,$ffff8209.w

                move.w    #$00,$ffff8240.w
                move.w    #$0700,$ffff8242.w
                move.w    #$0500,$ffff8244.w
                move.w    #$0700,$ffff8246.w

                movea.l   screen1,a0
                move.w    #$8000,(a0)
                move.w    #$01,152(a0)
                move.w    #$8000,160*199(a0)
                move.w    #$01,160*199+152(a0)
                move.w    #$8000,160*99(a0)
                move.w    #$01,160*99+152(a0)


                addq.b    #1,vbl_cnt
                movem.l   (sp)+,d0-a6
                rte

**********************************************************************
**********************************************************************
**********************************************************************
* start of main

independent_route:


                tst.b     noclr_flg
                bne.s     fuck_clr
                movea.l   screen1(pc),a1
                bsr       clr_screen              ; dest addr in a1!
fuck_clr:

                move.w    #$00,$ffff8240.w
                jsr       fill


                move.l    screen1(pc),d0
                move.l    screen2(pc),d1
                move.l    d0,screen2
                move.l    d1,screen1


                rts

* end of main!
**********************************************************************
**********************************************************************
**********************************************************************
* dest address in a1!

clr_screen:

                move.w    #8,$ffff8a2e.w          ; des xinc
                move.w    #0,$ffff8a30.w          ; des yinc
                move.l    a1,$ffff8a32.w          ; des addr

                move.b    #1,$ffff8a3a.w          ; hop
                move.b    #0,$ffff8a3b.w          ; op

                move.w    #20*200-1,$ffff8a36.w   ; x cnt
                move.w    #1,$ffff8a38.w          ; y cnt
                move.b    #%11000000,$ffff8a3c.w  ; busy
                rts

**********************************************************************
**********************************************************************
**********************************************************************

**********************************************************************
**********************************************************************

make_xy_tab:
                lea       x_add_tab,a0

                moveq     #0,d0
                move.w    #$8000,d1
                moveq     #20-1,d7
words:
              rept 16
                move.w    d0,(a0)+
                move.w    d1,(a0)+
                ror.w     #1,d1
              endr

                addq.w    #8,d0
                dbra      d7,words

* make_y_tab
                lea       y_add_tab,a0

                moveq     #0,d0
                move.w    #160,d1
                move.w    #200-1,d7
lines:
                move.w    d0,(a0)+

                add.w     d1,d0
                dbra      d7,lines
                rts

**********************************************************************
**********************************************************************
**********************************************************************
* Superfast line-draw by Tobias Nilsson...
* Using d0-d6/a0-a3
* d0=x1  d1=y1 , d2=x2  d3=y2

calc_line:

                cmp.w     d1,d3
                bge.s     no_exg
                exg       d0,d2
                exg       d1,d3

no_exg:

                cmp.w     d0,d2                   ; chk if neg x
                bge.s     no_neg_x

                move.w    d0,d4
                sub.w     d2,d4
                move.w    d0,d2
                add.w     d4,d2

                st        neg_x_flg
                bra       h
no_neg_x:
                sf        neg_x_flg
h:
                addq.w    #1,d2
* --------------------------------------------------------------------

                move.w    d2,d4
                sub.w     d0,d4                   ; x2-x1 > x


;                cmp.w     d1,d3
;                blo.s     st_neg_y_flg
;                sf        neg_y_flg

                addq.w    #1,d3
                move.w    d3,d5
                sub.w     d1,d5                   ; y2-y1 > y

                bra.s     go


;st_neg_y_flg:
;                exg       d1,d3
;                exg       d0,d2
;                st        neg_y_flg

;               subq.w    #1,d3
; ,               move.w    d1,d5
;                sub.w     d3,d5                   ; y1-y2 > y (second)

* --------------------------------------------------------------------
* d6 will be holy (sacred)!
go:

                cmp.w     d4,d5
                bge.s     yes_low

                st        y_high_flg              ; !

                move.w    d5,d6
                lsr.w     #1,d6
                neg.w     d6
                add.w     d4,d6                   ; E + x

                move.w    d4,d2                   ; x  ...times
                add.w     d5,d2                   ; y

                move.w    d4,d3
                sub.w     d5,d3

                add.w     d3,d2
                bra.s     go_calc

yes_low:
                sf        y_high_flg              ; !

                move.w    d4,d6
                lsr.w     #1,d6

                move.w    d4,d2                   ; x  ...times
                add.w     d5,d2                   ; y

                move.w    d5,d3
                sub.w     d4,d3

                add.w     d3,d2

* --------------------------------------------------------------------
* d4 = x  d5 = y  d6 = holy
* a1 = x coordinates list!
go_calc:


                lsr.w     #1,d2

                mulu      #10,d2                  ; 10 bytes
                subq.w    #2,d2                   ; <<<<

                tst.b     neg_x_flg
                bne.s     neg_x


* --------------------------------------------------------------------

                tst.b     y_high_flg
                beq.s     high_y

;                move.w    d1,(a1)+                ; save y!
                lea       end_of_draw(pc),a0
                suba.w    d2,a0
                jmp       (a0)
high_y:
;                move.w    d1,(a1)+
                lea       end_of_draw_2(pc),a0
                suba.w    d2,a0
                jmp       (a0)
* --------------------------------------------------------------------
neg_x:

                tst.b     y_high_flg
                beq.s     high_y_2

;                move.w    d1,(a1)+                ; save y!
                lea       end_of_draw_3(pc),a0
                suba.w    d2,a0
                jmp       (a0)

high_y_2:
;                move.w    d1,(a1)+
                lea       end_of_draw_4(pc),a0
                suba.w    d2,a0
                jmp       (a0)

**********************************************************************
**********************************************************************
              rept 320
* step x
                addq.w    #1,d0
                sub.w     d5,d6
                bpl.s     *+4

* step y
                move.w    d0,(a1)+                ; save x!
                add.w     d4,d6
              endr

end_of_draw:
              rept 4
                rts
              endr

**********************************************************************
              rept 200

* step x
                addq.w    #1,d0
                sub.w     d5,d6

* step y
                move.w    d0,(a1)+                ; save x!
                add.w     d4,d6
                bmi.s     *+4

              endr

end_of_draw_2:
              rept 4
                rts
              endr
**********************************************************************
**********************************************************************
* this is for negative y lines...

              rept 320
* step x
                subq.w    #1,d0
                sub.w     d5,d6
                bpl.s     *+4

* step y (-1)
                move.w    d0,(a1)+                ; save x!
                add.w     d4,d6

              endr

end_of_draw_3:
              rept 4
                rts
              endr

**********************************************************************
              rept 200
* step x
                subq.w    #1,d0
                sub.w     d5,d6

* step y (-1)
                move.w    d0,(a1)+                ; save x!
                add.w     d4,d6
                bmi.s     *+4

              endr

end_of_draw_4:
              rept 4
                rts
              endr


**********************************************************************
**********************************************************************
y_high_flg:   dc.b 0
neg_x_flg:    dc.b 0
              even

x_add_rel:
              dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
              rept 19
              dc.w 8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
              endr

* .l (scrnoff, pixel)
x_add_tab:
              ds.b 1280

* .w (lineoffset)
y_add_tab:
              ds.b 400


x1:           dc.w 0
y1:           dc.w 0
x2:           dc.w 100
y2:           dc.w 100

screen1:      dc.l 0
screen2:      dc.l 0
**********************************************************************
**********************************************************************
fill:
                lea       left_coords,a1

                move.w    #100,d0
                move.w    #60,d1
                move.w    #100,d2
                move.w    #140,d3

                move.w    d1,(a1)+                ; save solo y!
                jsr       calc_line               ; a1 = buffer
;                move.w    #-1,(a1)+

                move.w    #100,d0
                move.w    #140,d1
                move.w    #200,d2
                move.w    #140,d3
                jsr       calc_line               ; a1 = buffer
;                move.w    #-1,(a1)+

                move.w    #-2,(a1)+


                lea       right_coords,a1

                move.w    #100,d0
                move.w    #60,d1
                move.w    #200,d2
                move.w    #80,d3
                jsr       calc_line               ; a1 = buffer
;                move.w    #-1,(a1)+

                move.w    #200,d0
                move.w    #80,d1
                move.w    #200,d2
                move.w    #140,d3
                jsr       calc_line               ; a1 = buffer
;                move.w    #-1,(a1)+

                move.w    #-2,(a1)+

**********************************************************************
                lea       left_coords,a0
                lea       right_coords,a1

                move.w    (a0)+,d2                ; get top y
                bmi.s     end_l
;                move.w    (a1)+,d3                ; right y
;                bmi.s     end_r

draw_loop:
                move.w    (a0)+,d0                ; lx
                move.w    (a1)+,d1                ; rx
                bsr       horiz_line
                addq.w    #1,d2                   ; next line


                cmpi.w    #-2,(a0)
                beq.s     end_l
                cmpi.w    #-2,(a1)
                beq.s     end_r

                bra       draw_loop


end_l:          rts
end_r:          rts


**********************************************************************
* d2 = y
horiz_line:
                movem.l   d0-d3/a0-a3,-(sp)

                move.w    d2,d3
                sub.w     d0,d1


                lea       x_add_tab(pc),a0
                lea       y_add_tab(pc),a1
                lea       x_add_rel(pc),a2
                movea.l   screen1(pc),a3          ; a3 = workscreen

                add.w     d0,d0                   ; *2
                adda.w    d0,a2                   ; 0 or 8
                add.w     d0,d0                   ; *2

                add.w     d3,d3                   ; *2

                adda.w    0(a1,d3.w),a3           ; y conv, add to screen
                adda.w    0(a0,d0.w),a3           ; x conv, add to screen
                move.w    2(a0,d0.w),d0           ; pixel

pix_lp:
                or.w      d0,(a3)
                adda.w    (a2)+,a3                ; 0 or 8...
                ror.w     #1,d0
                dbra      d1,pix_lp

                movem.l   (sp)+,d0-d3/a0-a3
                rts

**********************************************************************


                lea       x_add_tab(pc),a0
                lea       y_add_tab(pc),a1
;                lea       x_add_rel(pc),a2
                movea.l   screen1(pc),a2          ; a3 = workscreen


                lea       right_coords,a4
                move.w    (a4)+,d2                ; 1st word = y

draw_lp:

                move.w    (a4)+,d0                ; get x

                move.w    d2,d1                   ; get y
                addq.w    #1,d2                   ; next line


                add.w     d0,d0                   ; *2
;                adda.w    d0,a2                   ; 0 or 8
                add.w     d0,d0                   ; *2
                add.w     d1,d1                   ; *2

                movea.l   a2,a3                   ; workscreen
                adda.w    0(a1,d1.w),a3           ; y conv, add to screen
                adda.w    0(a0,d0.w),a3           ; x conv, add to screen
                move.w    2(a0,d0.w),d1           ; pixel

                or.w      d1,(a3)

                cmpi.w    #-1,(a4)
                bne.s     draw_lp


                addq.w    #2,a4
                move.w    (a4)+,d2                ; 1st word = y

draw_lp2:

                move.w    (a4)+,d0                ; get x

                move.w    d2,d1                   ; get y
                addq.w    #1,d2                   ; next line


                add.w     d0,d0                   ; *2
;                adda.w    d0,a2                   ; 0 or 8
                add.w     d0,d0                   ; *2
                add.w     d1,d1                   ; *2

                movea.l   a2,a3                   ; workscreen
                adda.w    0(a1,d1.w),a3           ; y conv, add to screen
                adda.w    0(a0,d0.w),a3           ; x conv, add to screen
                move.w    2(a0,d0.w),d1           ; pixel

                or.w      d1,(a3)

                cmpi.w    #-1,(a4)
                bne.s     draw_lp2

* --------------------------------------------------------------------

                lea       left_coords,a4
                move.w    (a4)+,d2                ; 1st word = y

draw_lp3:

                move.w    (a4)+,d0                ; get x

                move.w    d2,d1                   ; get y
                addq.w    #1,d2                   ; next line


                add.w     d0,d0                   ; *2
;                adda.w    d0,a2                   ; 0 or 8
                add.w     d0,d0                   ; *2
                add.w     d1,d1                   ; *2

                movea.l   a2,a3                   ; workscreen
                adda.w    0(a1,d1.w),a3           ; y conv, add to screen
                adda.w    0(a0,d0.w),a3           ; x conv, add to screen
                move.w    2(a0,d0.w),d1           ; pixel

                or.w      d1,(a3)

                cmpi.w    #-1,(a4)
                bne.s     draw_lp3


                addq.w    #2,a4
                move.w    (a4)+,d2                ; 1st word = y

draw_lp4:

                move.w    (a4)+,d0                ; get x

                move.w    d2,d1                   ; get y
                addq.w    #1,d2                   ; next line


                add.w     d0,d0                   ; *2
;                adda.w    d0,a2                   ; 0 or 8
                add.w     d0,d0                   ; *2
                add.w     d1,d1                   ; *2

                movea.l   a2,a3                   ; workscreen
                adda.w    0(a1,d1.w),a3           ; y conv, add to screen
                adda.w    0(a0,d0.w),a3           ; x conv, add to screen
                move.w    2(a0,d0.w),d1           ; pixel

                or.w      d1,(a3)

                cmpi.w    #-1,(a4)
                bne.s     draw_lp4

                rts

**********************************************************************
**********************************************************************
left_coords:  ds.w 1+200
right_coords: ds.w 1+200

              ds.w 200


**********************************************************************
**********************************************************************
**********************************************************************
**********************************************************************
oldvbl:       dc.l 0

back:           move.l    oldvbl(pc),$70.w
                move.w    #1,-(sp)
                move.l    #-1,-(sp)
                move.l    #-1,-(sp)
                move.w    #5,-(sp)
                trap      #14
                lea       12(sp),sp

                move.w    #$0777,$ffff8240.w
                move.w    #$00,$ffff8246.w

                clr.w     -(sp)
                trap      #1

**********************************************************************

screen:       ds.b 32000*2
              end
