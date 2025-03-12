**********************************************************************
* Digital World -3-                                                  *
* (C) Copyright Tobias Nilsson (Techwave of ICE)... -1992-           *
**********************************************************************
* I think ya' need 2 meg to assemble...
* Check so all files are included...


                bsr       init_everything

                jsr       set_mw                  ; init mw!
                jsr       start_part_1

                lea       pic2+34(pc),a0
                lea       pic+34,a1
                move.w    #(20*4*200)/2-1,d7
copy_lp:        move.l    (a0)+,(a1)+
                dbra      d7,copy_lp

* remember clr!

                lea       pic2+34(pc),a0
                lea       pic+34,a1
                moveq     #0,d0
                move.w    #20*4*16-1,d7
c_p2:           move.w    d0,(a0)+
                move.w    d0,(a1)+
                dbra      d7,c_p2

                lea       pic2+34+(160*168)(pc),a0
                lea       pic+34+(160*168),a1
                move.w    #20*4*29-1,d7
c_p2_2:         move.w    d0,(a0)+
                move.w    d0,(a1)+
                dbra      d7,c_p2_2

* --------------------------------------------------------------------
                jsr       play_dma

wait_dma:       tst.b     $ffff8901.w
                bne.s     wait_dma

                jsr       start_part_2
* --------------------------------------------------------------------

                bsr.s     clr_work
                jsr       start_part_3

* --------------------------------------------------------------------
                bsr.s     clr_work
                move      #$2300,sr
                jsr       start_part_2_2


                clr.l     -(sp)
                move.w    #$20,-(sp)
                trap      #1
                addq.l    #6,sp

                move.w    #1,-(sp)
                move.l    #-1,-(sp)
                move.l    #-1,-(sp)
                move.w    #5,-(sp)
                trap      #14
                lea       12(sp),sp


                clr.w     -(sp)
                trap      #1


clr_work:
                lea       pic2+34(pc),a0
                moveq     #0,d0
                move.w    #(20*4*400)/2-1,d7
clr_shit_lp:    move.l    d0,(a0)+
                dbra      d7,clr_shit_lp
                rts

**********************************************************************
**********************************************************************
**********************************************************************
init_everything:

* super
                pea       $00.w
                move.w    #$20,-(sp)
                trap      #1
                addq.w    #6,sp

                move.b    #2,$0484.w

                move.l    #$31415926,$0426.w
                move.l    #reset_route,$042a.w

* low
                move.w    #0,-(sp)
                move.l    #-1,-(sp)
                move.l    #-1,-(sp)
                move.w    #5,-(sp)
                trap      #14
                lea       12(sp),sp

                move.w    #0,$ffff8264.w          ; fuck hscroll
                move      #$2300,sr
                rts

reset_route:
                moveq     #0,d0
                move.b    d0,$ffff8901.w
                lea       $ffff8240.w,a0

              rept 8
                move.l    d0,(a0)+
              endr
no_end:         bra.s     no_end


**********************************************************************
* Intro!!!!!!!!!   Digital World 3... by ICE                         *
**********************************************************************
* Pushimg v0.1   By TEchwave.... Go Fade!                            *
**********************************************************************

start_part_1:

                lea       $ffff8240.w,a0
                bsr       init_fade_make

                lea       fading,a0
                lea       $ffff8240.w,a1

                moveq     #15-1,d7
pal_lp:
                move.w    #0,$0468.w
vsync_i:        cmpi.w    #0,$0468.w
                beq.s     vsync_i

              rept 16
                move.w    (a0),(a1)+
                lea       32(a0),a0
              endr

                lea       -32*16+2(a0),a0
                lea       -32(a1),a1

                move.w    #0,$0468.w
vsync_i2:       cmpi.w    #0,$0468.w
                beq.s     vsync_i2
                dbra      d7,pal_lp


                lea       fading(pc),a0
                moveq     #0,d0
                move.w    #16*16-1,d7
clr_lp_part_i1: move.w    d0,(a0)+
                dbra      d7,clr_lp_part_i1


* --------------------------------------------------------------------
                bsr       fade_make

i_init_part_1:
                move.l    $70.w,oldvbl_part_1
                move.l    $0120.w,oldhbl
                move.b    $fffffa07.w,oldmfp07    ; iera   (timer a & b)
                move.b    $fffffa09.w,oldmfp09    ; ierb   (timer c & d)
                move.b    $fffffa13.w,oldmfp13    ; imra

                move.b    #0,$fffffa09.w          ; ierb    c & d obliterate
;                bclr      #5,$fffffa09.w
;                bclr      #4,$fffffa09.w

                move.l    #vbl_part_1,$70.w
                move.l    #hbl,$0120.w
                bset      #0,$fffffa07.w          ; b enable
                bset      #0,$fffffa13.w          ; b mask
                move.b    #0,$fffffa1b.w          ; tbcr
                move.b    #255,$fffffa21.w        ; tbdr
                move.b    #8,$fffffa1b.w          ; even count mode

sync_vbl:       tst.b     vbl_flg_part_1
                beq.s     sync_vbl

                move.b    $fffffc02.w,d0
                cmpi.b    #185,d0                 ; f1 = $3b
                beq       back_part_1

                tst.b     pic_flg
                beq.s     not_yet_fuck

                sf        vbl_flg_part_1
sync_reg:       tst.b     vbl_flg_part_1
                beq.s     sync_reg

                lea       pic2(pc),a0
                lea       pic,a1

                move.w    #32034/2-1,d7
pic_lp:         move.w    (a0),d0
                move.w    (a1),d1
                move.w    d0,(a1)+
                move.w    d1,(a0)+
                dbra      d7,pic_lp

                lea       fading(pc),a0
                moveq     #0,d0
                move.w    #16*16-1,d7
clr_lp_part_1:  move.w    d0,(a0)+
                dbra      d7,clr_lp_part_1
                move.w    #0,fade_poi
                bsr       fade_make
                tst.b     prepare_exit_flg
                bne       back_part_1
                st        prepare_exit_flg
                sf        pic_flg

not_yet_fuck:
                sf        vbl_flg_part_1
                bra       sync_vbl

pic_flg:      dc.b 0
prepare_exit_flg:dc.b 0
              even

**********************************************************************
**********************************************************************
**********************************************************************
vbl_part_1:
                movem.l   d0-d1/d7-a1,-(sp)
                move.l    #hbl_special_init,$0120

                move.l    #nothing,d0
                move.b    d0,$ffff8209.w
                lsr.w     #8,d0
                move.b    d0,$ffff8207.w
                swap      d0
                move.b    d0,$ffff8205.w


                tst.b     pic_flg
                beq.s     fuck_it

                move.b    #0,$fffffa1b.w          ; fuck hbl!

                movem.l   (sp)+,d0-d1/d7-a1
                st        vbl_flg_part_1
                rte

fuck_it:
**********************************************************************

                tst.b     fade_up_flg
                beq       tst_fade_down

                addq.w    #1,wait_fade
                bmi       ready_fade
                move.w    #-3,wait_fade


                lea       fading+(15*2)(pc),a0
                suba.w    fade_poi(pc),a0

                lea       $ffff8240.w,a1
              rept 16
                move.w    (a0),(a1)+
                lea       16*2(a0),a0
              endr

                cmpi.w    #15*2,fade_poi
                bge.s     ready_fade_up
                addq.w    #2,fade_poi
                bra       ready_fade
ready_fade_up:  sf        fade_up_flg
                bra       ready_fade
* --------------------------------------------------------------------

tst_fade_down:
                tst.b     fade_down_flg
                beq       ready_fade

                addq.w    #1,wait_fade
                bmi       ready_fade
                move.w    #-2,wait_fade


                lea       fading+(15*2)(pc),a0
                suba.w    fade_poi(pc),a0

                lea       $ffff8240.w,a1
              rept 16
                move.w    (a0),(a1)+
                lea       16*2(a0),a0
              endr

                cmpi.w    #0,fade_poi
                beq.s     ready_fade_down
                subq.w    #2,fade_poi
                bra.s     ready_fade
ready_fade_down:sf        fade_down_flg
                st        pic_flg                 ; !!!!!!!!!

**********************************************************************
ready_fade:


                moveq     #0,d0
                moveq     #0,d1
                move.w    cut_cnt(pc),d2
                move.w    #199,d3
                bsr       calc_line               ; d4, d5, d6 return


                move.l    #pic+34,img_addr
                move.l    #160,d3

                move.w    cut_cnt(pc),d0
                lsr.w     #1,d0
                move.w    #100,d1
                sub.w     d0,d1

                move.b    #0,$fffffa1b.w
                move.b    d1,$fffffa21.w
                move.b    #8,$fffffa1b.w

**********************************************************************
                tst.b     dec_flg_part_1
                bne.s     dec_now

                cmpi.w    #200-2,cut_cnt
                bge.s     now_top
                addq.w    #2,cut_cnt
                bra.s     ready_cnt
now_top:
                addq.w    #1,wait_ice
                bmi.s     ready_cnt
                move.w    #-200,wait_ice
                st        dec_flg_part_1
                st        fade_down_flg
                move.w    #-50,wait_fade
                bra.s     ready_cnt

* --------------------------------------------------------------------

dec_now:
                cmpi.w    #13-1,cut_cnt
                ble.s     now_down
                subq.w    #2,cut_cnt
                bra.s     ready_cnt
now_down:       sf        dec_flg_part_1
                st        fade_up_flg
ready_cnt:

                movem.l   (sp)+,d0-d1/d7-a1
                st        vbl_flg_part_1
                rte

**********************************************************************
**********************************************************************
**********************************************************************
img_addr:     dc.l 0
cut_cnt:      dc.w 20
fade_poi:     dc.w 0
wait_fade:    dc.w -3
wait_ice:     dc.w -200

fade_up_flg:  dc.b $ff
fade_down_flg:dc.b 0
dec_flg_part_1:dc.b 0


vbl_flg_part_1:dc.b 0
              even



**********************************************************************
**********************************************************************
hbl_special_init:

                move.l    #hbl,$0120

                move.b    #0,$fffffa1b.w
                move.b    #1,$fffffa21.w
                move.b    #8,$fffffa1b.w

                bclr      #0,$fffffa0f.w          ; isra
                rte


hbl:
                lea       img_addr+1(pc),a0
                move.b    (a0)+,$ffff8205.w
                move.b    (a0)+,$ffff8207.w
                move.b    (a0)+,$ffff8209.w
                add.l     d3,img_addr

                add.w     d5,d6
                bmi.s     end_hbl

                moveq     #0,d2
              rept 16
                sub.w     d4,d6                   ; d5 = y
                bmi.s     ready
                add.w     d3,d2
              endr

ready:          add.l     d2,img_addr

end_hbl:
                cmpi.l    #end_img,img_addr
                bhi.s     end_shit
                bclr      #0,$fffffa0f.w          ; isra
                rte

end_shit:
                move.b    #0,$fffffa1b.w
                move.b    #-1,$fffffa21.w
                move.b    #8,$fffffa1b.w

                bclr      #0,$fffffa0f.w          ; isra
                rte


**********************************************************************
**********************************************************************
* d0=x1  d1=y1 , d2=x2  d3=y2

calc_line:

                cmp.w     d0,d2                   ; chk if neg x
                bhi.s     no_exg
                exg       d0,d2
                exg       d1,d3
no_exg:
                addq.w    #1,d2
* --------------------------------------------------------------------

                move.w    d2,d4
                sub.w     d0,d4                   ; x2-x1 > x

                cmp.w     d1,d3
                blo.s     st_yline_flg
                addq.w    #1,d3

                move.w    d3,d5
                sub.w     d1,d5                   ; y2-y1 > y
                bra.s     go_part_1

st_yline_flg:                                     ; don't exits!
                subq.w    #1,d3

                move.w    d1,d5
                sub.w     d3,d5                   ; y1-y2 > y (second)

* --------------------------------------------------------------------
* d6 is holy (sacred)!
go_part_1:
                cmp.w     d4,d5
                bge.s     yes_low

                move.w    d5,d6
                lsr.w     #1,d6
                neg.w     d6
                add.w     d4,d6                   ; E + x

                move.w    d4,d2                   ; x  ...times
                add.w     d5,d2                   ; y

                move.w    d4,d3
                sub.w     d5,d3

                add.w     d3,d2
                rts                               ; END!
* --------------------------------------------------------------------
yes_low:
                move.w    d4,d6
                lsr.w     #1,d6

                move.w    d4,d2                   ; x  ...times
                add.w     d5,d2                   ; y

                move.w    d5,d3
                sub.w     d4,d3

                add.w     d3,d2
* --------------------------------------------------------------------
* d4 = x  d5 = y  d6 = holy
ready_line:
                rts
**********************************************************************
**********************************************************************
fade_make:      lea       pic+2,a0
                lea       fading(pc),a3
              rept 16
                move.w    (a0)+,(a3)              ; copy pal
                lea       16*2(a3),a3
              endr

                lea       pic+2,a0
init_fade_make:
                lea       fading+2(pc),a3

                moveq     #16-1,d7
fade_pal:       movea.l   a3,a1
                move.w    (a0)+,d0

                move.w    d0,d1
                and.w     #$0f,d1
                bsr.s     fade_subr

                movea.l   a3,a1
                move.w    d0,d1
                and.w     #$f0,d1
                lsr.w     #4,d1
                bsr.s     fade_subr_2

                movea.l   a3,a1
                move.w    d0,d1
                and.w     #$0f00,d1
                lsr.w     #8,d1
                bsr.s     fade_subr_3

                lea       16*2(a3),a3
                dbra      d7,fade_pal
                rts

fade_subr:      cmp.w     #$08,d1
                beq.s     end_subr
                cmp.w     #$00,d1
                beq.s     end_subr

                lea       fade(pc),a2
no:             cmp.w     (a2)+,d1
                bne.s     no
wrt_fade:       move.w    (a2),(a1)+
                cmpi.w    #$00,(a2)+
                bne.s     wrt_fade
end_subr:       rts

fade_subr_2:    cmp.w     #$08,d1
                beq.s     end_subr_2
                cmp.w     #$00,d1
                beq.s     end_subr_2

                lea       fade(pc),a2
no_2:           cmp.w     (a2)+,d1
                bne.s     no_2
wrt_fade_2:     move.w    (a2),d2
                lsl.w     #4,d2
                or.w      d2,(a1)+
                cmpi.w    #$00,(a2)+
                bne.s     wrt_fade_2
end_subr_2:     rts

fade_subr_3:    cmp.w     #$08,d1
                beq.s     end_subr_3
                cmp.w     #$00,d1
                beq.s     end_subr_3

                lea       fade(pc),a2
no_3:           cmp.w     (a2)+,d1
                bne.s     no_3
wrt_fade_3:     move.w    (a2),d2
                lsl.w     #8,d2
                or.w      d2,(a1)+
                cmpi.w    #$00,(a2)+
                bne.s     wrt_fade_3
end_subr_3:     rts

**********************************************************************
fade:         dc.w $0f,$07,$0e,$06,$0d,$05,$0c,$04,$0b,$03,$0a,$02,$09,$01,$08,$00
fading:       ds.w 16*16


**********************************************************************
**********************************************************************
oldvbl_part_1:dc.l 0
oldhbl:       dc.l 0
oldmfp07:     dc.b 0
oldmfp09:     dc.b 0
oldmfp13:     dc.b 0
              even

back_part_1:
                move      #$2700,sr
                move.l    oldvbl_part_1(pc),$70.w
                move.l    oldhbl(pc),$0120.w
                move.b    oldmfp07(pc),$fffffa07.w
                move.b    oldmfp09(pc),$fffffa09.w
                move.b    oldmfp13(pc),$fffffa13.w

                move      #$2300,sr

                sf        pic_flg
                sf        prepare_exit_flg

                rts

**********************************************************************
**********************************************************************
              even
pic2:         ibytes 'DEMON.PI1'              ; workarea for p1, p2, p3!
pic:          ibytes 'BLODLOGO.PI1'
end_img:
nothing:      ds.b 16000

**********************************************************************
**********************************************************************
screen        equ pic2+34
zoom_buff:    ds.b 160*16




**********************************************************************
**********************************************************************
**********************************************************************
**********************************************************************
**********************************************************************
**********************************************************************
**********************************************************************
**********************************************************************
**********************************************************************
**********************************************************************
**********************************************************************
              even

**********************************************************************
* Zoomer... (bitmapped grafixx)... v0.8                              *
* By Tobias Nilsson, "Techwave"                                      *
**********************************************************************

start_part_2:


start_part_2_2:
                subi.w    #26,mw_settings
                bsr       set_mw
                bsr       play_dma2


b_init:
                move.w    #$ffff,$ffff8a28.w
                move.w    #$ffff,$ffff8a2a.w
                move.w    #$ffff,$ffff8a2c.w
                move.b    #0,$ffff8a3d.w          ; halftone

                move.w    #8,$ffff8a20.w          ; src x inc
                move.w    #0,$ffff8a22.w          ; src y inc
                move.w    #8,$ffff8a2e.w          ; des x inc
                move.w    #0,$ffff8a30.w          ; des y inc

                lea       screen,a0
                move.l    a0,screen1
                lea       32000+34(a0),a0
                move.l    a0,screen2



i_init:         move.l    $70.w,oldvbl
                move.l    #vbl,$70.w

;key:            move.w    #7,-(sp)
;                trap      #1
;                addq.l    #2,sp
;                bra       back

**********************************************************************
wait_vbl:       sf        vbl_flg
wait_lp:        tst.b     vbl_flg
                beq.s     wait_lp


                cmpi.w    #0,scrltxt_pointer
                beq.s     not_yee

                tst.b     exit_flg
                beq.s     ignore
                move.b    #0,$ffff8901.w
                bra.s     ignore
not_yee:
                tst.b     exit_flg
                bne       back
ignore:


;                move.w    #$0300,$ffff8240.w

;                move.w    #$ff,-(sp)              ; test keyboard...
;                move.w    #6,-(sp)
;                trap      #1
;                addq.l    #4,sp

;                cmp.b     #" ",d0
;                beq       back


                bsr.s     sin_zoom

                move.w    #0,d0
                move.w    #0,d1
                move.w    #319,d2
                move.w    zoom_factor(pc),d3

                bsr       line_route
                bsr       x_zoom


                move.w    #0,d0
                move.w    #0,d1
                move.w    #(256+160),d2
                move.w    zoom_factor(pc),d3

                bsr       line_route
                bsr       y_zoom

                move.w    #$00,$ffff8240.w
                bra       wait_vbl

* --------------------------------------------------------------------
sin_zoom:

                tst.b     sin_zoom2_flg
                bne       sin_zoom2


                lea       sin_tab(pc),a0
                adda.w    sin_add(pc),a0
                move.w    (a0),d0
                add.w     #16384,d0
                move.w    #2600,d1
                mulu      d0,d1
                swap      d1
                rol.l     #2,d1
                move.w    d1,zoom_factor


                lea       sin_tab(pc),a0
                adda.w    sin_add2(pc),a0
                move.w    (a0),d0
                add.w     #16384,d0
                move.w    #90/2,d1
                mulu      d0,d1
                swap      d1
                rol.l     #2,d1
                move.w    d1,line_scrl


                tst.b     dec_flg
                bne.s     dec_pix
                addq.w    #2,pix_scrl
                cmpi.w    #104,pix_scrl
                blo.s     no_dec
                st        dec_flg
                bra.s     no_dec
dec_pix:        subq.w    #1,pix_scrl
                bne.s     no_dec
                sf        dec_flg
no_dec:




                cmpi.w    #270*2-2,sin_add
                bne.s     no_st_txt
                st        txt_flg
no_st_txt:
                addq.w    #2,sin_add
                cmpi.w    #360*2-2,sin_add
                blo.s     no_warp
                move.w    #0,sin_add
no_warp:
                addq.w    #4,sin_add2
                cmpi.w    #360*2-2,sin_add2
                blo.s     no_warp2
                move.w    #0,sin_add2
no_warp2:
                rts
* --------------------------------------------------------------------
sin_zoom2:
                lea       sin_tab(pc),a0
                adda.w    sin_add(pc),a0
                move.w    (a0),d0
                add.w     #16384,d0
                move.w    #1900,d1
                mulu      d0,d1
                swap      d1
                rol.l     #2,d1
                add.w     #1400,d1                ; BIG!!
                move.w    d1,zoom_factor


                lea       sin_tab(pc),a0
                adda.w    sin_add2(pc),a0
                move.w    (a0),d0
                add.w     #16384,d0
                move.w    #90/2,d1
                mulu      d0,d1
                swap      d1
                rol.l     #2,d1
                move.w    d1,line_scrl


                move.w    #48,pix_scrl


                addq.w    #4,sin_add
                cmpi.w    #360*2-2,sin_add
                blo.s     no_warp_2
                move.w    #0,sin_add
no_warp_2:
                addq.w    #6,sin_add2
                cmpi.w    #360*2-2,sin_add2
                blo.s     no_warp2_2
                move.w    #0,sin_add2
no_warp2_2:
                rts
**********************************************************************
sin_zoom2_flg:dc.b 0                          ; SPECIAL!!!!!!
dec_flg:      dc.b 0
              even
sin_add:      dc.w 180                        ;270*2+2
sin_add2:     dc.w 0

sin_tab:      dc.w 0,286,572,857,1143,1428,1713,1997,2280
              dc.w 2563,2845,3126,3406,3686,3964,4240,4516
              dc.w 4790,5063,5334,5604,5872,6138,6402,6664
              dc.w 6924,7182,7438,7692,7943,8192,8438,8682
              dc.w 8923,9162,9397,9630,9860,10087,10311,10531
              dc.w 10749,10963,11174,11381,11585,11786,11982,12176
              dc.w 12365,12551,12733,12911,13085,13255,13421,13583
              dc.w 13741,13894,14044,14189,14330,14466,14598,14726
              dc.w 14849,14962,15082,15191,15296,15396,15491,15582
              dc.w 15668,15749,15826,15897,15964,16026,16083,16135
              dc.w 16182,16225,16262,16294,16322,16344,16362,16374
              dc.w 16382
; 90

cos_tab:      dc.w 16384
              dc.w 16382,16374,16362,16344,16322,16294,16262,16225
              dc.w 16182
              dc.w 16135,16083,16026,15964,15897,15826,15749,15668
              dc.w 15582,15449,15396,15296,15191,15082,14962,14849
              dc.w 14726,14598,14466,14330,14189,14044,13894,13741
              dc.w 13583,13421,13255,13085,12911,12733,12551,12365
              dc.w 12176,11982,11786,11585,11381,11174,10963,10749
              dc.w 10531,10311,10087,9860,9630,9397,9162,8923
              dc.w 8682,8438,8192,7943,7692,7438,7182,6924
              dc.w 6664,6402,6138,5872,5604,5334,5063,4790
              dc.w 4516,4240,3964,3686,3406,3126,2845,2563
              dc.w 2280,1997,1713,1428,1143,857,572,286,0

neg_sin_tab:
              dc.w -286,-572,-857,-1143,-1428,-1713,-1997,-2280
              dc.w -2563,-2845,-3126,-3406,-3686,-3964,-4240,-4516
              dc.w -4790,-5063,-5334,-5604,-5872,-6138,-6402,-6664
              dc.w -6924,-7182,-7438,-7692,-7943,-8192,-8438,-8682
              dc.w -8923,-9162,-9397,-9630,-9860,-10087,-10311,-10531
              dc.w -10749,-10963,-11174,-11381,-11585,-11786,-11982,-12176
              dc.w -12365,-12551,-12733,-12911,-13085,-13255,-13421,-13583
              dc.w -13741,-13894,-14044,-14189,-14330,-14466,-14598,-14726
              dc.w -14849,-14962,-15082,-15191,-15296,-15396,-15491,-15582
              dc.w -15668,-15749,-15826,-15897,-15964,-16026,-16083,-16135
              dc.w -16182,-16225,-16262,-16294,-16322,-16344,-16362,-16374
              dc.w -16382,-16384

              dc.w -16382,-16374,-16362,-16344,-16322,-16294,-16262,-16225
              dc.w -16182
              dc.w -16135,-16083,-16026,-15964,-15897,-15826,-15749,-15668
              dc.w -15582,-15449,-15396,-15296,-15191,-15082,-14962,-14849
              dc.w -14726,-14598,-14466,-14330,-14189,-14044,-13894,-13741
              dc.w -13583,-13421,-13255,-13085,-12911,-12733,-12551,-12365
              dc.w -12176,-11982,-11786,-11585,-11381,-11174,-10963,-10749
              dc.w -10531,-10311,-10087,-9860,-9630,-9397,-9162,-8923
              dc.w -8682,-8438,-8192,-7943,-7692,-7438,-7182,-6924
              dc.w -6664,-6402,-6138,-5872,-5604,-5334,-5063,-4790
              dc.w -4516,-4240,-3964,-3686,-3406,-3126,-2845,-2563
              dc.w -2280,-1997,-1713,-1428,-1143,-857,-572,-286,0

              dc.w 286,572,857,1143,1428,1713,1997,2280
              dc.w 2563,2845,3126,3406,3686,3964,4240,4516
              dc.w 4790,5063,5334,5604,5872,6138,6402,6664
              dc.w 6924,7182,7438,7692,7943,8192,8438,8682
              dc.w 8923,9162,9397,9630,9860,10087,10311,10531
              dc.w 10749,10963,11174,11381,11585,11786,11982,12176
              dc.w 12365,12551,12733,12911,13085,13255,13421,13583
              dc.w 13741,13894,14044,14189,14330,14466,14598,14726
              dc.w 14849,14962,15082,15191,15296,15396,15491,15582
              dc.w 15668,15749,15826,15897,15964,16026,16083,16135
              dc.w 16182,16225,16262,16294,16322,16344,16362,16374
              dc.w 16382,16384,16382



hey:          dc.w 1
auto_flg:     dc.b 0
              even

**********************************************************************
**********************************************************************
**********************************************************************

vbl:
                movem.l   d0-a6,-(sp)

;                move.l    #zoom_buff,d0
;                move.b    d0,$ffff8209.w
;                lsr.w     #8,d0
;                move.b    d0,$ffff8207.w
;                swap      d0
;                move.b    d0,$ffff8205.w


                lea       screen1+1(pc),a0
                move.b    (a0)+,$ffff8205.w
                move.b    (a0)+,$ffff8207.w
                move.b    (a0)+,$ffff8209.w
                move.l    screen1(pc),d0
                move.l    screen2(pc),d1
                move.l    d0,screen2
                move.l    d1,screen1


                move.l    screen1(pc),d0
                bsr       clr_screen              ; de-set if out of time!

                tst.b     sin_zoom2_flg
                beq.s     no_such_thing

* --------------------------------------------------------------------
;                move.w    #$33,$ffff8240.w
                bsr       text_scroller
;                move.w    #$0300,$ffff8240.w

                lea       zoom_buff+160-(8*4)-(8*9),a0
                moveq     #$01,d0
                move.w    #$8000,d1

              rept 8
                or.w      d0,(a0)
                or.w      d1,8*5(a0)
                lea       160(a0),a0
              endr
                subi.w    #1000,zoom_factor

                bra.s     no_new_txt

no_such_thing:

;                cmpi.w    #0,zoom_factor
;                bne.s     no_st
;                st        txt_flg
;no_st:
                tst.b     txt_flg
                beq.s     no_new_txt
                sf        txt_flg

;                move.w    #$30,$ffff8240.w
                bsr       text_writter
;                move.w    #$0300,$ffff8240.w

no_new_txt:
* --------------------------------------------------------------------
                cmpi.w    #1400,zoom_factor
                bhi.s     no_zfade
                move.w    zoom_factor(pc),d0
                lsr.w     #4,d0
                bclr      #0,d0
                lea       zfade_pal(pc),a0
                adda.w    d0,a0
                move.w    (a0),$ffff8242.w
                bra.s     ready_zfade
no_zfade:       move.w    #$0fff,$ffff8242.w
ready_zfade:
* --------------------------------------------------------------------

                tst.b     slide_vol_flg
                beq.s     no_slide

                addq.w    #1,wait_slide
                bmi.s     ready_vol_dma
                move.w    #-6,wait_slide

                cmpi.w    #%10011000000+16,mw_settings ; master 0-40
                beq.s     st_exit
                subq.w    #1,mw_settings
                bsr       set_mw
                bra.s     ready_vol_dma

st_exit:
                st        exit_flg
                bra.s     ready_vol_dma

no_slide:
                cmpi.w    #%10011000000+32,mw_settings ; master 0-40
                beq.s     ready_vol_dma
                addq.w    #1,mw_settings
                bsr       set_mw
ready_vol_dma:


                st        vbl_flg
                movem.l   (sp)+,d0-a6
                move.w    #$00,$ffff8240.w
                rte

**********************************************************************
**********************************************************************
**********************************************************************
wait_slide:   dc.w -3

vbl_flg:      dc.b 0
txt_flg:      dc.b $ff
slide_vol_flg:dc.b 0
exit_flg:     dc.b 0
              even

screen1:      dc.l 0
screen2:      dc.l 0

zoom_factor:  dc.w 0

zfade_pal:
              dc.w 0
              dc.w $08,$08,$01,$01,$09,$09,2,$02,$0a,$0a,$03,$03,$0b,$0b
              dc.w $0884,$0884,$011c,$011c,$0995,$0995,$022d,$022d,$0aa6,$0aa6
              dc.w $033e,$033e,$0bb7,$0bb7,$044f,$044f
              dc.w $0ccf,$0ccf,$055f,$055f,$066f,$066f,$0eef,$0eef,$077f,$077f
              dc.w $0fff


end_zfade:    ds.w 1000,$0fff


**********************************************************************
**********************************************************************
* Superfast line-route included for zoom, by Tobias Nilsson...
* Not 100% used, sucker!
* Using d0-d6/a0-a3
* d0=x1  d1=y1 , d2=x2  d3=y2

line_route:
;                addq.w    #1,d2

* --------------------------------------------------------------------
                move.w    d2,d4
                sub.w     d0,d4                   ; x2-x1 > x


                cmp.w     d1,d3
                blo.s     yline
                addq.w    #1,d3

                move.w    d3,d5
                sub.w     d1,d5                   ; y2-y1 > y
                bra.s     go

yline:
                subq.w    #1,d3

                move.w    d1,d5
                sub.w     d3,d5                   ; y1-y2 > y (second)

* --------------------------------------------------------------------
* d6 is holy (sacred)!
go:

                cmp.w     d4,d5
                bge.s     yes_low_p2

                move.w    d5,d6
                lsr.w     #1,d6
                neg.w     d6
                add.w     d4,d6                   ; E + x
                rts

* --------------------------------------------------------------------
yes_low_p2:

                move.w    d4,d6
                lsr.w     #1,d6

;                move.w    #$30,$ffff8240.w       ; <<<
                rts

* returned data:
* d4 = x  d5 = y  d6 = holy
**********************************************************************
**********************************************************************

scroll_xright:

;                move.w    zoom_x,d0
;                lsr.w     #4,d0

                move.w    pix_scrl,d0



                move.w    d0,scrl_xstep
                andi.w    #$0f,scrl_xstep

                cmp.w     #16,d0
                blo.s     no_more
                and.w     #$fff0,d0
                lsr.w     #1,d0
                move.w    d0,scrl_x
                rts

no_more:        clr.w     scrl_x
                rts


pix_scrl:     dc.w 0
scrl_xstep:   dc.w 0
scrl_x:       dc.w 0
**********************************************************************
**********************************************************************
x_zoom:

                bsr.s     scroll_xright

                lea       zoom_buff+152-8,a5      ; src xzoom
                lea       zoom_buff+152+(160*8),a6 ; des xzoom


              rept 7
                movem.w   d4-d6,-(sp)             ; save the holy shit

                movea.l   a5,a0
                suba.w    scrl_x(pc),a0
                lea       -32(a0),a0              ; <<<<<<<<<<<<

                movea.l   a6,a1

                bsr       zoom_xline
                lea       160(a5),a5
                lea       160(a6),a6

                movem.w   (sp)+,d4-d6             ; get the holy shit
              endr

                movea.l   a5,a0
                suba.w    scrl_x(pc),a0
                lea       -32(a0),a0              ; <<<<<<<<<<<<

                movea.l   a6,a1

                bsr.s     zoom_xline

                rts
* --------------------------------------------------------------------

zoom_xline:
                move.w    (a0),d0                 ; get data
                subq.w    #8,a0

                move.w    scrl_xstep(pc),d1
                ror.w     d1,d0

                moveq     #-16,d2
                add.w     d1,d2

                moveq     #-16,d3
                moveq     #-20,d7
                move.w    #-9,end_get_data        ; -20    x*16 pixels

* --------------------------------------------------------------------
rotate_it:
                roxr.w    #1,d0                   ; to carry & x
                roxr.w    #1,d1                   ; dest

                addq.w    #1,d2                   ; inc get word...
                beq.s     get_data
cont_1:         addq.w    #1,d3                   ; inc save word...
                beq.s     save_new_data
cont_2:

                sub.w     d5,d6
                bpl.s     rotate_it


* --------------------------------------------------------------------

zoom_it:
                asr.w     #1,d1                   ; aritm

                addq.w    #1,d3                   ; inc word save...
                beq.s     save_new_data2
cont_3:

                add.w     d4,d6
                bmi.s     zoom_it

                bra.s     rotate_it

* --------------------------------------------------------------------
* --------------------------------------------------------------------

get_data:
                move.w    (a0),d0
                subq.w    #8,a0
                moveq     #-16,d2

                addq.w    #1,end_get_data
                bne.s     cont_1
                rts

save_new_data:  move.w    d1,(a1)
                subq.w    #8,a1
                moveq     #-16,d3
                addq.w    #1,d7
                bne.s     cont_2
                rts

save_new_data2: move.w    d1,(a1)
                subq.w    #8,a1
                moveq     #-16,d3
                addq.w    #1,d7
                bne.s     cont_3
                rts
* --------------------------------------------------------------------
end_get_data: dc.w 0


**********************************************************************
**********************************************************************
scroll_y:

;                move.w    zoom_x,d0
;                lsr.w     #4,d0

                move.w    line_scrl(pc),d0
                mulu      #160,d0
                move.w    d0,scrl_y
                rts


line_scrl:    dc.w 0
scrl_y:       dc.w 0

**********************************************************************
**********************************************************************
* make duplicates' of lines...  using blitter...
y_zoom:

                bsr.s     scroll_y

                move.w    #%1000000011,$ffff8a3a.w ; hop & log... src only!

go_on_y:

                lea       zoom_buff+(160*7),a0    ; -160.... src
                movea.l   screen1(pc),a1          ; log screen

                movea.l   a1,a2
                lea       32000(a2),a2
                move.l    a2,d7                   ; end of screen
                cmpi.w    #32000,scrl_y
                bhi.s     end_y_zoom
                adda.w    scrl_y(pc),a1

                cmpa.l    a2,a1
                bge.s     end_y_zoom


                lea       $ffff8a24.w,a2          ; src addr
                lea       $ffff8a32.w,a3          ; des addr

                lea       $ffff8a36.w,a4          ; x-cnt
                lea       $ffff8a38.w,a5          ; y-cnt
                lea       $ffff8a3c.w,a6          ; busy


                moveq     #20,d1
                moveq     #1,d2
                move.w    #%1100000000000000,d3


                moveq     #-9,d0                  ; lines of source +1 (neg)

* --------------------------------------------------------------------
line_out:

                addq.w    #1,d0
                beq.s     end_y_zoom


                lea       160(a0),a0

                move.l    a0,(a2)                 ; des
                move.l    a1,(a3)                 ; src
                move.w    d1,(a4)                 ; x cnt
                move.w    d2,(a5)                 ; y cnt
                move.w    d3,(a6)                 ; busy

                lea       160(a1),a1

                cmpa.l    d7,a1
                beq.s     end_y_zoom

                sub.w     d5,d6
                bpl       line_out

* --------------------------------------------------------------------

y_zoom_it:

                move.l    a0,(a2)                 ; des
                move.l    a1,(a3)                 ; src
                move.w    d1,(a4)                 ; x cnt
                move.w    d2,(a5)                 ; y cnt
                move.w    d3,(a6)                 ; busy

                lea       160(a1),a1

                cmpa.l    d7,a1
                beq.s     end_y_zoom

                add.w     d4,d6
                bmi.s     y_zoom_it
                bra.s     line_out

end_y_zoom:     rts


**********************************************************************
**********************************************************************
* d0 = screen

clr_screen:

                move.w    #$ffff,$ffff8a28.w
                move.w    #$ffff,$ffff8a2a.w
                move.w    #$ffff,$ffff8a2c.w
                move.b    #0,$ffff8a3d.w          ; halftone

                move.w    #8,$ffff8a20.w          ; src x inc
                move.w    #0,$ffff8a22.w          ; src y inc
                move.w    #8,$ffff8a2e.w          ; des x inc
                move.w    #0,$ffff8a30.w          ; des y inc


                lea       $ffff8a2e+4.w,a0

;                move.w    #8,(a0)+                ; des xinc
;                move.w    #0,(a0)+                ; des yinc
                move.l    d0,(a0)+                ; des addr

                move.w    #20*200,(a0)+           ; x cnt
                move.w    #1,(a0)+                ; y cnt
                move.w    #%100000000,(a0)+       ; hop & log...halftone & 0!
                move.w    #%1100000000000000,(a0)+ ;busy
                rts


**********************************************************************
**********************************************************************

text_writter:

                move.w    #16,t_xorient

fuck_me:
                lea       text(pc),a2
                adda.w    txt_pointer(pc),a2
                cmpi.b    #-1,(a2)
                bne.s     no_wrap
;                subq.w    #8,txt_pointer
                addq.w    #1,txt_pointer
                st        slide_vol_flg
                bra.s     fuck_me

no_wrap:        addq.w    #8,txt_pointer



              rept 8
                move.b    (a2)+,d0
                bsr.s     print_txt
                addq.w    #1,t_xorient
              endr

                rts


print_txt:      and.w     #$ff,d0
                sub.b     #32,d0                  ; sub space
                add.w     d0,d0
                lea       char_offs(pc),a0
                move.w    0(a0,d0.w),d0

                lea       font+34+2*(5*160*9),a0
                adda.w    d0,a0                   ; add offset to font
; _____________________________________________________________________

                move.w    t_xorient,d0
                sf        bitflg

                btst      #0,d0
                beq.s     even
                st        bitflg
                and.b     #$fe,d0

even:           lsl.w     #2,d0                   ; * 4 (think!!!)

                lea       zoom_buff,a1            ; destination!
                adda.w    d0,a1                   ; add x

                tst.b     bitflg
                bne.s     out2

; _____________________________________  Access to screen  _______________

out1:
              rept 7
                move.w    (a0),(a1)
                lea       160(a0),a0
                lea       160(a1),a1
              endr
                move.w    (a0),(a1)
                rts

out2:
              rept 7
                move.w    (a0),d6
                lsr.w     #8,d6
                or.w      d6,(a1)
                lea       160(a0),a0
                lea       160(a1),a1
              endr
                move.w    (a0),d6
                lsr.w     #8,d6
                or.w      d6,(a1)
                rts


txt_pointer:  dc.w 0
t_xorient:    dc.w 0
bitflg:       dc.b 0
              even


text:
              dc.b "DIGITAL "
              dc.b " WORLD  "
              dc.b "  -3-   "
              dc.b " Design "
              dc.b "   and  "
              dc.b " Coding "
              dc.b "TECHWAVE"
              dc.b -1
              dc.b "        "


              even
**********************************************************************
**********************************************************************
**********************************************************************
* Blitter text-scroll by Techwave
* 1 plane 8*8
**********************************************************************

text_scroller:
                move.b    #2,$ffff8a3a.w          ; hop
                move.b    #3,$ffff8a3b.w          ; op
                move.w    #$ffff,$ffff8a2a.w      ; endmask 2
                move.w    #$ffff,$ffff8a2c.w      ; endmask 3
                move.w    #8,$ffff8a20.w          ; src x inc
                move.w    #8,$ffff8a2e.w          ; des x inc

                bsr.s     b_scrl
                bsr.s     b_charout
                rts
**********************************************************************

b_scrl:
                move.w    #$00,$ffff8a28.w        ; endmask 1
                move.w    #160-(4*8),$ffff8a22.w  ; src y inc
                move.w    #160-(4*8),$ffff8a30.w  ; des y inc

                lea       zoom_buff+160-(8*4)-(8*8),a1
;                lea       160-(8*4)+8(a1),a1

                move.l    a1,$ffff8a24.w          ; src
                subq.l    #8,a1
                move.l    a1,$ffff8a32.w          ; des

                move.w    #5,$ffff8a36.w          ; x cnt
                move.w    #8,$ffff8a38.w          ; y cnt


                move.b    #%1111,$ffff8a3d.w      ; skew
                move.b    #%11000000,$ffff8a3c.w
                rts

* --------------------------------------------------------------------
b_charout:
                lea       font+34+(160*9*5)(pc),a0
                adda.w    offset(pc),a0
                move.l    a0,$ffff8a24.w          ; src addr

                move.l    #zoom_buff+152-(8*8),$ffff8a32.w
;                lea       152(a1),a1
;                move.l    a1,$ffff8a32.w          ; des addr

                move.w    #$01,$ffff8a28.w        ; endmask 1
                move.w    #160,$ffff8a22.w        ; src y inc
                move.w    #160,$ffff8a30.w        ; des y inc

                move.w    #1,$ffff8a36.w          ; x cnt
                move.w    #8,$ffff8a38.w          ; y cnt

                move.b    to_skew(pc),$ffff8a3d.w
                move.b    #%11000000,$ffff8a3c.w

                subq.b    #1,to_skew
                cmpi.b    #7,to_skew
                beq.s     read
                rts


read:           move.b    #15,to_skew

                moveq     #0,d0
                lea       scrltxt(pc),a0
                adda.w    scrltxt_pointer(pc),a0
                move.b    (a0),d0
                tst.b     d0
                bne.s     ascii

                subi.w    #144,scrltxt_pointer
                st        slide_vol_flg
                rts

;                move.w    #0,scrltxt_pointer
;                bra.s     read

ascii:          sub.b     #32,d0
                add.w     d0,d0
                lea       char_offs(pc),a0
                move.w    0(a0,d0.w),offset
                addq.w    #1,scrltxt_pointer
                rts

**********************************************************************

to_skew:      dc.b 12
bit_flg:      dc.b 0
              even
scrltxt_pointer:dc.w 0
offset:       dc.w 0


scrltxt:
              dc.b "             "
              dc.b "The time has reached the greetings... So here's some "
              dc.b "(In strange random-order!):     "
              dc.b "CODDAN (I got some inspiration from the great -Space Tale-, thanxx!),   "
              dc.b "ELF (Are you still that Electric Life-Form?  You can borrow some more power from us... 220 volt?  Nahh... "
              dc.b "30 000 volt or more will do... Just ask Ringhals!),   "
              dc.b "CUTTER (You have some nice talent in grafix!),   "
              dc.b "Little SURF (U keep the lame-syndrome alive! That's half a joke, man!),   "
              dc.b "Tiny TURTE (U too...),   "
              dc.b "PERRA-GUNNAREN GUSTAFZON (U're quite cool be4 shaving!),   "
              dc.b "WIZPITTEN (Why so fucking lame?),   "

              dc.b "AN Cool (M demo 3 is funky!  Nice tempo!),   "
              dc.b "IMAGINA (Hi Coincidence!  Nice Cozmic Jam! But don't get too insulted if ya' get the point!),   "
              dc.b "GRC (Hi Paranoia, Iceman & the rest!),   "
              dc.b "OMEGA (I think ya' good after ICE!),   "
              dc.b "IMPULSE (Too bad it's so little people at the party, but it's nice anyway!),   SYNC,   "
              dc.b "ELECTRA (Kasper, Now I hope U know who ICE are...),   ELECTRONIC IMAGES,   THE LOST BOYS,   DELTA FORCE,   THE RESPECTABLES,  "
              dc.b "OVERLANDERS,    and ofcourse everybody else who think they deserves greetings...    "

              dc.b "  Now...  "
              dc.b "- Let's talk about SEX baby!    Nahh, not this time...   I feel too tired...  Get start coding yourselfes now...     "
              dc.b "This demo is my last for a while...     AU REVOIR!  "
              dc.b "                             "
              dc.b "You have been watching a swedish Inner Circuit Explorers production of -1992-!     (C) Copyright I.C.E.!  "
              dc.b "You are free to spread it!    "
              dc.b 0

              even

**********************************************************************
**********************************************************************

char_offs:

* 9 lines
              dc.w 0,8,16,24,32,40,48,56,64,72,80,88,96,104,112,120,128,136,144,152
              dc.w $05a0,$05a0+8,$05a0+16,$05a0+24,$05a0+32,$05a0+40,$05a0+48,$05a0+56,$05a0+64
              dc.w $05a0+72,$05a0+80,$05a0+88,$05a0+96,$05a0+104,$05a0+112,$05a0+120,$05a0+128
              dc.w $05a0+136,$05a0+144,$05a0+152
              dc.w $0b40,$0b40+8,$0b40+16,$0b40+24,$0b40+32,$0b40+40,$0b40+48,$0b40+56,$0b40+64
              dc.w $0b40+72,$0b40+80,$0b40+88,$0b40+96,$0b40+104,$0b40+112,$0b40+120,$0b40+128
              dc.w $0b40+136,$0b40+144,$0b40+152
              dc.w $10e0,$10e0+8,$10e0+16,$10e0+24,$10e0+32,$10e0+40,$10e0+48,$10e0+56,$10e0+64
              dc.w $10e0+72,$10e0+80,$10e0+88,$10e0+96,$10e0+104,$10e0+112,$10e0+120,$10e0+128
              dc.w $10e0+136,$10e0+144,$10e0+152
              dc.w $1680,$1680+8,$1680+16,$1680+24,$1680+32,$1680+40,$1680+48,$1680+56,$1680+64
              dc.w $1680+72,$1680+80,$1680+88,$1680+96,$1680+104,$1680+112,$1680+120,$1680+128
              dc.w $1680+136,$1680+144,$1680+152

**********************************************************************
**********************************************************************
play_dma:
                move.l    #start_spl1,d0
                move.l    #end_spl1,d1

                move.b    d0,$ffff8907.w
                lsr.w     #8,d0
                move.b    d0,$ffff8905.w
                swap      d0
                move.b    d0,$ffff8903.w

                move.b    d1,$ffff8913.w
                lsr.w     #8,d1
                move.b    d1,$ffff8911.w
                swap      d1
                move.b    d1,$ffff890f.w

                move.b    #%10000001,$ffff8921.w
                move.b    #%1,$ffff8901.w
                rts
play_dma2:

                move.l    #start_spl2,d0
                move.l    #end_spl2,d1
                sub.l     #100,d1

                move.b    d0,$ffff8907.w
                lsr.w     #8,d0
                move.b    d0,$ffff8905.w
                swap      d0
                move.b    d0,$ffff8903.w

                move.b    d1,$ffff8913.w
                lsr.w     #8,d1
                move.b    d1,$ffff8911.w
                swap      d1
                move.b    d1,$ffff890f.w

                move.b    #%10000001,$ffff8921.w
                move.b    #%11,$ffff8901.w
                rts

**********************************************************************
set_mw:         move.w    #$07ff,$ffff8924.w      ; to mw mask
                lea       mw_settings,a0          ; microwire settings
                lea       $ffff8922.w,a1          ; mw data

                move.w    (a1),d7                 ; save previous
mw_loop:        move.w    (a0)+,(a1)
mw_wait:        cmp.w     (a1),d7
                bne.s     mw_wait
                cmpa.l    #mw_setend,a0
                bne.s     mw_loop
                rts

mw_settings:  dc.w %10011000000+33            ; master    0-40
              dc.w %10101000000+20            ; left      0-20
              dc.w %10100000000+20            ; right     0-20
              dc.w %10010000000+6+0           ; treble    0-12 (6=0dB)
              dc.w %10001000000+6+2           ; bass      0-12 (6=0dB)
              dc.w %10000000000+2             ; mix       0-03
mw_setend:


**********************************************************************
**********************************************************************
oldvbl:       dc.l 0

back:           move.l    oldvbl(pc),$70.w
;                move.w    #1,-(sp)
;                move.l    #-1,-(sp)
;                move.l    #-1,-(sp)
;                move.w    #5,-(sp)
;                trap      #14
;                lea       12(sp),sp
                move.b    #0,$ffff8901.w


                not.b     sin_zoom2_flg           ; SPECIAL!!!!!!
                move.w    #%10011000000+40,mw_settings
                sf        dec_flg
                sf        exit_flg
                move.w    #180,sin_add
                move.w    #0,sin_add2
                sf        slide_vol_flg

                move.w    #0,scrltxt_pointer
                rts
**********************************************************************


              even

font:         ibytes 'C88.PI1'                ; 8*8 font, word-oriented
              even

start_spl1:   ibytes 'LOVETECH.SPL'
end_spl1:
start_spl2:   ibytes 'NEWORDER.SPL'
end_spl2:
              even

**********************************************************************





**********************************************************************
**********************************************************************
**********************************************************************
**********************************************************************
**********************************************************************
**********************************************************************
**********************************************************************
**********************************************************************
**********************************************************************
**********************************************************************
* Fuckdemo!                                                          *
**********************************************************************
* Fucked 3D shit!!  v0.8                                             *
* By Tobias Nilsson, "Techwave"                                      *
**********************************************************************


start_part_3:

                move.w    #0,$0468.w
vsync_p3:       cmpi.w    #0,$0468.w
                beq.s     vsync_p3

                lea       $ffff8240,a0
                moveq     #0,d0
              rept 8
                move.l    d0,(a0)+
              endr


                move.w    #0,$ffff8264.w          ; fuck hscroll

                move.w    #$ffff,$ffff8a28.w      ; blitt shit
                move.w    #$ffff,$ffff8a2a.w
                move.w    #$ffff,$ffff8a2c.w

                lea       screen,a0               ; save work-address
                move.l    a0,screen1_p3
                adda.l    #32000+(160*45),a0
                move.l    a0,screen2_p3


                moveq     #0,d1
                lea       obj_points(pc),a0
obj_loop:       cmpa.l    #obj_end,a0
                beq.s     ready_now
                move.w    (a0),d0
                add.w     d0,d0
;                add.w     d0,d0
                move.w    d0,(a0)+
                addq.w    #1,d1
                bra.s     obj_loop
ready_now:
;                divu      #3,d1
;                subq.w    #1,d1
;                move.w    d1,num_points           ; number of points -1


                jsr       tracker_init

i_init_p3:
                move.l    $70.w,oldvbl_p3
                move.l    $0120.w,oldhbl_p3
                move.b    $fffffa07.w,oldmfp07_p3 ; iera   (timer a & b)
                move.b    $fffffa09.w,oldmfp09_p3 ; ierb   (timer c & d)
                move.b    $fffffa13.w,oldmfp13_p3 ; imra

                move.b    #0,$fffffa09.w          ; ierb    c & d obliterate
;                bclr      #5,$fffffa09.w
;                bclr      #4,$fffffa09.w

                move.l    #vbl_p3,$70.w
                move.l    #hbl_p3,$0120.w
                bset      #0,$fffffa07.w          ; b enable
                bset      #0,$fffffa13.w          ; b mask
                move.b    #0,$fffffa1b.w          ; tbcr
                move.b    #255,$fffffa21.w        ; tbdr
                move.b    #8,$fffffa1b.w          ; even count mode

sync_vbl_p3:    sf        vbl_flg
wait_lp_p3:     tst.b     vbl_flg
                beq.s     wait_lp_p3

                move.b    $fffffc02.w,d0

                cmpi.b    #$3b,d0                 ; f1 = $3b
                bne.s     no_f1
                subq.w    #1,scale_factor
                bne.s     no_f1
                move.w    #1,scale_factor
no_f1:
                cmpi.b    #$3c,d0                 ; f2
                bne.s     no_f2
                addq.w    #1,scale_factor
                cmpi.w    #89,scale_factor
                bne.s     no_f2
                move.w    #88,scale_factor
no_f2:

**********************************************************************
                bsr       independent_3d


                tst.b     exit_now_flg
                beq.s     sync_vbl_p3
                jmp       back_p3

;                move.b    $fffffc02.w,d0
;                cmpi.b    #185,d0                 ; f1 = $3b
;                bne.s     sync_vbl
;                jmp       back

exit_now_flg: dc.b 0
              even

**********************************************************************
**********************************************************************
**********************************************************************
vbl_p3:
                movem.l   d0-a6,-(sp)

                lea       screen1_p3+1(pc),a0
                move.b    (a0)+,$ffff8205.w
                move.b    (a0)+,$ffff8207.w
                move.b    (a0)+,$ffff8209.w


                move.w    #$0336,$ffff8240+16.w   ; for text-print!


                move.w    #$00,$ffff8240.w
                lea       $ffff8242.w,a0
                tst.b     glance_col_flg
                beq.s     no_glance
                lea       glance_fade,a1
                adda.w    glance_fade_poi,a1

                move.w    6(a1),(a0)+
                move.w    8(a1),(a0)+
                move.w    6(a1),(a0)+
                move.w    #$00,(a0)+
                move.w    (a1),(a0)+
                move.w    4(a1),(a0)+
                move.w    (a1),(a0)+

                bra.s     col_ready

no_glance:      move.w    color1(pc),(a0)+
                move.w    color2(pc),(a0)+
                move.w    color1(pc),(a0)+
col_ready:
* --------------------------------------------------------------------
                jsr       cool_text

* --------------------------------------------------------------------

                move.l    #hbl_p3,$0120.w
                move.b    #0,$fffffa1b.w
                move.b    #100-8+20+14,$fffffa21.w
                move.b    #8,$fffffa1b.w


* --------------------------------------------------------------------
vbl_noise:
                jsr       noise_rout

* --------------------------------------------------------------------


                cmpi.b    #$ff,disp_flg
                bne.s     ready_rastsin
                lea       sin_tab_p3(pc),a0
                adda.w    start_poi(pc),a0
                addq.w    #4,start_poi

                move.w    (a0),d0
                move.w    #160,d1
                muls      d0,d1
                swap      d1
                rol.l     #2,d1

                add.w     d1,d1
                move.w    d1,rast_offs
                cmpi.w    #160*2,d1
                bne.s     ready_rastsin
                sf        disp_flg
ready_rastsin:

* --------------------------------------------------------------------

                cmpi.b    #$80,disp_flg
                bne.s     ready_rastsin2
                lea       sin_tab_p3(pc),a0
                adda.w    start_poi(pc),a0
                subq.w    #4,start_poi

                move.w    (a0),d0
                move.w    #160,d1
                muls      d0,d1
                swap      d1
                rol.l     #2,d1

                add.w     d1,d1
                move.w    d1,rast_offs
                cmpi.w    #0,start_poi
                bne.s     ready_rastsin2
                sf        disp_flg
                st        exit_now_flg

ready_rastsin2:

* --------------------------------------------------------------------
                not.b     interlace_flg
                bne.s     go_change
                move.w    rast_offs(pc),rast_hbl
                bra.s     ready_inter
go_change:      move.w    rast_offs(pc),rast_hbl
                addq.w    #2,rast_hbl
ready_inter:
**********************************************************************




                movem.l   (sp)+,d0-a6
                st        vbl_flg
                rte

**********************************************************************
**********************************************************************
**********************************************************************
start_poi:    dc.w 0
interlace_flg:dc.b 0
disp_flg:     dc.b $ff
;vbl_flg:      dc.b 0
              even

rast_offs:    dc.w 0

**********************************************************************
* this is for the 3d shit... always try 50 frames!                   *
**********************************************************************

independent_3d:

                move.l    screen1_p3(pc),d0
                move.l    screen2_p3(pc),d1
                move.l    d0,screen2_p3
                move.l    d1,screen1_p3

                bsr       chk_y_clr

                movea.l   screen1_p3(pc),a1
                bsr       clr_screen_p3           ; dest addr in a1!


* --------------------------------------------------------------------

                tst.b     x_rotate_flg
                beq.s     skip_x
                move.w    x_rotate_angle(pc),d0
                add.w     x_rot_inc(pc),d0
                cmp.w     #360,d0
                blo.s     no_x_end
                sub.w     #360,d0
no_x_end:       move.w    d0,x_rotate_angle
skip_x:
                tst.b     y_rotate_flg
                beq.s     skip_y
                move.w    y_rotate_angle(pc),d0
                add.w     y_rot_inc(pc),d0
                cmp.w     #360,d0
                blo.s     no_y_end
                sub.w     #360,d0
no_y_end:       move.w    d0,y_rotate_angle
skip_y:
                tst.b     z_rotate_flg
                beq.s     skip_z
                move.w    z_rotate_angle(pc),d0
                add.w     z_rot_inc(pc),d0
                cmp.w     #360,d0
                blo.s     no_z_end
                sub.w     #360,d0
no_z_end:       move.w    d0,z_rotate_angle
skip_z:


* --------------------------------------------------------------------


                tst.b     clr_f_flg
                beq.s     no_clr_f

                moveq     #$00,d0
                lea       screen+4,a0
                move.w    #20*125-1,d7
img_clrlp:      move.w    d0,(a0)
                addq.w    #8,a0
                dbra      d7,img_clrlp

                lea       screen+4+(32000+(160*45)),a0
                move.w    #20*125-1,d7
img_clrlp2:     move.w    d0,(a0)
                addq.w    #8,a0
                dbra      d7,img_clrlp2
                sf        clr_f_flg
                rts
no_clr_f:
* --------------------------------------------------------------------

                tst.b     glance_col_flg
                beq.s     no_fill
                tst.b     fill_flg
                beq.s     no_fill

                move.w    #$fc00,d0
                lea       screen+4,a0
                move.w    #20*125-1,d7
img_lp:         move.w    d0,(a0)
                addq.w    #8,a0
                dbra      d7,img_lp

                lea       screen+4+(32000+(160*45)),a0
                move.w    #20*125-1,d7
img_lp2:        move.w    d0,(a0)
                addq.w    #8,a0
                dbra      d7,img_lp2
                sf        fill_flg
                rts
no_fill:
* --------------------------------------------------------------------


                cmpi.b    #$80,start_flg
                bne.s     chk_st_zoom
                not.b     sync_25
                beq.s     inc_time

                move.w    scale_factor_cmp,scale_factor

                lea       glance_fade_poi(pc),a0
                subq.w    #2,(a0)
                bne.s     inc_time
                sf        start_flg
                bra.s     inc_time

chk_st_zoom:
                cmpi.b    #$ff,start_flg
                bne.s     inc_time

                move.w    scale_factor(pc),d0
                subq.w    #1,d0
                move.w    d0,scale_factor
                cmp.w     scale_factor_cmp(pc),d0
                bhi.s     inc_time
                sf        start_flg

inc_time:

                addq.w    #1,time_cnt
                bmi       no_new_order
* --------------------------------------------------------------------

                cmpi.b    #$80,end_flg
                bne.s     chk_end_zoom
                not.b     sync_25
                beq       no_new_order

                lea       glance_fade_poi(pc),a0
                addq.w    #2,(a0)
                cmpi.w    #17*2,(a0)
                bne       no_new_order
                sf        end_flg
                bra       no_new_order

chk_end_zoom:
                cmpi.b    #$ff,end_flg
                bne.s     no_nice_end
                subq.w    #1,time_cnt

                addq.w    #1,scale_factor
                cmpi.w    #89,scale_factor
                blo       no_new_order
                sf        end_flg
                bra       no_new_order

no_nice_end:

                move.w    #0,x_rotate_angle       ; zenit
                move.w    #0,y_rotate_angle
                move.w    #0,z_rotate_angle


                lea       order_list(pc),a0
                adda.w    order_poi(pc),a0
                addi.w    #26,order_poi           ; 26 bytes each order!

                move.w    (a0)+,obj_offs
                move.w    (a0)+,line_offs
                move.w    (a0)+,y_origin
                move.w    (a0)+,scale_factor

                move.w    (a0)+,num_points
                move.w    (a0)+,x_rot_inc
                move.w    (a0)+,y_rot_inc
                move.w    (a0)+,z_rot_inc
                move.w    (a0)+,time_cnt

                move.b    (a0)+,x_rotate_flg
                move.b    (a0)+,y_rotate_flg
                move.b    (a0)+,z_rotate_flg
                move.b    (a0)+,start_flg
                move.b    (a0)+,end_flg
                move.b    (a0)+,transf_flg
                move.b    (a0)+,glance_col_flg
                move.b    (a0)+,laser_fx_flg

                cmpi.b    #-1,(a0)
                bne.s     no_warp_p3
                move.w    #0,order_poi
no_warp_p3:

                st        clr_f_flg
                tst.b     glance_col_flg
                beq.s     no_st_fill
                st        fill_flg
no_st_fill:

                tst.b     start_flg
                beq.s     no_new_order
                move.w    scale_factor(pc),scale_factor_cmp
                move.w    #89,scale_factor

* --------------------------------------------------------------------
* --------------------------------------------------------------------
no_new_order:
* VU shit & shit

                cmpi.b    #$80,laser_fx_flg
                bne       chk_laser_fx

tst_vo1:        tst.b     voice1+1
                beq.s     no_vo1
                move.w    #-40*2,vo1_point
no_vo1:         addq.w    #6,vo1_point
                cmpi.w    #-10*2,vo1_point
                blo.s     tst_vo2
                move.w    #-11*2,vo1_point


tst_vo2:        tst.b     voice2+1
                beq.s     no_vo2
                move.w    #40*2,vo2_point
no_vo2:         subq.w    #6,vo2_point
                cmpi.w    #10*2,vo2_point
                bhi.s     tst_vo3
                move.w    #11*2,vo2_point
* --------------------------------------------------------------------
tst_vo3:        tst.b     voice3+1
                beq.s     no_vo3
                move.w    #-40*2,vo3_point
no_vo3:         addq.w    #6,vo3_point
                cmpi.w    #-10*2,vo3_point
                blo.s     tst_vo4
                move.w    #-11*2,vo3_point


tst_vo4:        tst.b     voice4+1
                beq.s     no_vo4
                move.w    #40*2,vo4_point
no_vo4:         subq.w    #6,vo4_point
                cmpi.w    #10*2,vo4_point
                bhi.s     ready_vo
                move.w    #11*2,vo4_point
ready_vo:

                lea       obj_points+234+(16*6)+(4*6),a0
                move.w    vo1_point,(a0)
                move.w    vo2_point,6(a0)
                move.w    vo3_point,12+2(a0)
                move.w    vo4_point,18+2(a0)
                bra.s     no_fx

vo1_point:    dc.w -11*2
vo2_point:    dc.w 11*2
vo3_point:    dc.w -11*2
vo4_point:    dc.w 11*2

* --------------------------------------------------------------------

chk_laser_fx:
                cmpi.b    #$ff,laser_fx_flg
                bne.s     no_fx

                lea       obj_points+(6*8+6)(pc),a0
                adda.w    obj_offs,a0

                moveq     #0,d0
                move.b    voice1+1,d0
                move.w    d0,(a0)+                ; save
                move.w    d0,6(a0)
                move.w    d0,4(a0)

                moveq     #0,d0
                move.b    voice3+1,d0
                move.w    d0,(a0)+                ; save

                addq.w    #2+6,a0


                moveq     #0,d0
                move.b    voice2+1,d0
                neg.w     d0
                move.w    d0,(a0)+                ; save
                move.w    d0,6(a0)
                move.w    d0,4(a0)
                moveq     #0,d0
                move.b    voice4+1,d0
                neg.w     d0
                move.w    d0,(a0)+                ; save
;                not.b     flash
;                bne.s     no_fx
;                move.w    #$0700,color1
;                move.w    #$0600,color2
;                bra.s     no_z_fade
no_fx:
* --------------------------------------------------------------------

                tst.b     glance_col_flg
                bne.s     no_z_fade

                lea       distance_fade(pc),a0
                move.w    scale_factor(pc),d0
                lsr.w     #1,d0
                bclr      #0,d0
                move.w    0(a0,d0.w),color1
                move.w    4(a0,d0.w),color2
no_z_fade:
* --------------------------------------------------------------------

                tst.b     transf_flg
                beq.s     no_transf
                bsr       transformation
no_transf:


                bsr       calculate_shit3d
                rts


scale_factor_cmp:dc.w 0
fill_flg:     dc.b 0
clr_f_flg:    dc.b 0
;flash:        dc.b 0
sync_25:      dc.b 0
              even


obj_offs:     dc.w 0
line_offs:    dc.w 0
y_origin:     dc.w 100                        ; y location

time_cnt:     dc.w -1
x_rot_inc:    dc.w 0
y_rot_inc:    dc.w 0
z_rot_inc:    dc.w 0

x_rotate_flg: dc.b $ff
y_rotate_flg: dc.b $ff
z_rotate_flg: dc.b $ff

start_flg:    dc.b 0
end_flg:      dc.b 0

laser_fx_flg: dc.b 0
glance_col_flg:dc.b 0
transf_flg:   dc.b 0
              even

**********************************************************************
**********************************************************************

color1:       dc.w 0
color2:       dc.w 0

distance_fade:
;              rept 8
;              dc.w $0ccf
;              endr

;              dc.w $0ccf,$0447,$0bbe,$0336,$0aad,$0225,$099c,$0114
;              dc.w $088b,$03,$0a,$02,$09,$01,$08,$00

;              rept 40
;              dc.w 0
;              endr
* --------------------------------------------------------------------
              rept 8
              dc.w $055f
              endr

              dc.w $055f,$ccc7,$044e,$0bb6,$033d,$0aa5,$022c,$0994
              dc.w $011b,$0883,$0a,$02,$09,$01,$08,$00

              rept 40
              dc.w 0
              endr

glance_fade_poi:dc.w 16*2
glance_fade:
;              dc.w $0667,$0556,$0445,$0334,$0223,$0112,$01,$00

              dc.w $0667,$0dde,$0556,$0ccd,$0445,$0bbc,$0334,$0aab
              dc.w $0223,$099a,$0112,$0889,$01,$08,$00

glance_fade_end:
              ds.w 20

**********************************************************************
order_poi:    dc.w 0

* 26 bytes
order_list:

* ICE order
              dc.w 0                          ; offset for object
              dc.w 0                          ; offset for con_lines
              dc.w 75                         ; y origin
              dc.w 36                         ; scale factor

              dc.w 18-1                       ; num_points -1
              dc.w 0,2,3                      ; add to angles..x, y, z
              dc.w -50*12+25                  ; time to show

              dc.b $00,$ff,$ff                ; x, y, z  rotate flg
              dc.b $80                        ; sta flg  0=not. $ff=zoom
              dc.b $80                        ; end flg  $80=fade $ff=rezoom
              dc.b 0                          ; transform. flg
              dc.b $ff                        ; glance col flg
              dc.b 0                          ; laser-fx flg


* laser order
              dc.w 18*6                       ; offset for object
              dc.w 25*2                       ; offset for con_lines
              dc.w 100                        ; y origin
              dc.w 48                         ; scale factor

              dc.w 13-1                       ; num_points -1
              dc.w 1,2,1                      ; add to angles..x, y, z
              dc.w -50*30                     ; time to show

              dc.b $ff,$ff,$ff                ; x, y, z  rotate flg
              dc.b $ff                        ; sta flg  0=not. $ff=zoom
              dc.b $ff                        ; end flg  $80=fade $ff=rezoom
              dc.b 0                          ; transform. flg
              dc.b 0                          ; glance col flg
              dc.b $ff                        ; laser-fx flg

* transform order
              dc.w 18*6+(13*6)                ; offset for object
              dc.w 25*2+(33*2)                ; offset for con_lines
              dc.w 100                        ; y origin
              dc.w 40                         ; scale factor

              dc.w 8-1                        ; num_points -1
              dc.w 3,2,1                      ; add to angles..x, y, z
              dc.w -50*50                     ; time to show

              dc.b $ff,$ff,$ff                ; x, y, z  rotate flg
              dc.b $ff                        ; sta flg  0=not. $ff=zoom
              dc.b $ff                        ; end flg  $80=fade $ff=rezoom
              dc.b $ff                        ; transform. flg
              dc.b 0                          ; glance col flg
              dc.b 0                          ; laser-fx flg


* tea order
              dc.w 18*6+(13*6)+(8*6)          ; offset for object
              dc.w 25*2+(33*2)+(26*2)         ; offset for con_lines
              dc.w 100                        ; y origin
              dc.w 40                         ; scale factor

              dc.w 16-1                       ; num_points -1
              dc.w 4,3,1                      ; add to angles..x, y, z
              dc.w -50*13                     ; time to show

              dc.b $ff,$ff,$00                ; x, y, z  rotate flg
              dc.b $ff                        ; sta flg  0=not. $ff=zoom
              dc.b $ff                        ; end flg  $80=fade $ff=rezoom
              dc.b 0                          ; transform. flg
              dc.b 0                          ; glance col flg
              dc.b 0                          ; laser-fx flg



* plate
              dc.w 234+96+144+(30*6)          ; offset for object
              dc.w 168+50+96+(81*2)           ; offset for con_lines
              dc.w 70                         ; y origin
              dc.w 49                         ; scale factor

              dc.w 16-1                       ; num_points -1
              dc.w 1,3,2                      ; add to angles..x, y, z
              dc.w -50*20                     ; time to show

              dc.b $ff,$ff,$ff                ; x, y, z  rotate flg
              dc.b $80                        ; sta flg  0=not. $ff=zoom
              dc.b $80                        ; end flg  $80=fade $ff=rezoom
              dc.b 0                          ; transform. flg
              dc.b $ff                        ; glance col flg
              dc.b 0                          ; laser-fx flg



* Surfer
              dc.w 234+(16*6)+(8*6)           ; offset for object
              dc.w 168+(25*2)+(17*2)          ; offset for con_lines
              dc.w 140                        ; y origin
              dc.w 34                         ; scale factor

              dc.w 16-1                       ; num_points -1
              dc.w 1,2,1                      ; add to angles..x, y, z
              dc.w -50*20                     ; time to show

              dc.b $ff,$ff,$ff                ; x, y, z  rotate flg
              dc.b $ff                        ; sta flg  0=not. $ff=zoom
              dc.b $ff                        ; end flg  $80=fade $ff=rezoom
              dc.b 0                          ; transform. flg
              dc.b 0                          ; glance col flg
              dc.b 0                          ; laser-fx flg


* VU
              dc.w 234+(16*6)                 ; offset for object
              dc.w 168+(25*2)                 ; offset for con_lines
              dc.w 80                         ; y origin
              dc.w 20                         ; scale factor

              dc.w 8-1                        ; num_points -1
              dc.w 0,3,1                      ; add to angles..x, y, z
              dc.w -50*50                     ; time to show

              dc.b $00,$ff,$ff                ; x, y, z  rotate flg
              dc.b $80                        ; sta flg  0=not. $ff=zoom
              dc.b $80                        ; end flg  $80=fade $ff=rezoom
              dc.b 0                          ; transform. flg
              dc.b $ff                        ; glance col flg
              dc.b $80                        ; laser-fx flg



* transform order
              dc.w 18*6+(13*6)                ; offset for object
              dc.w 25*2+(33*2)                ; offset for con_lines
              dc.w 70                         ; y origin
              dc.w 40                         ; scale factor

              dc.w 8-1                        ; num_points -1
              dc.w 2,2,1                      ; add to angles..x, y, z
              dc.w -50*20                     ; time to show

              dc.b $ff,$ff,$ff                ; x, y, z  rotate flg
              dc.b $80                        ; sta flg  0=not. $ff=zoom
              dc.b $80                        ; end flg  $80=fade $ff=rezoom
              dc.b $ff                        ; transform. flg
              dc.b $ff                        ; glance col flg
              dc.b 0                          ; laser-fx flg


* Sword
              dc.w 234+(16*6)+((8+16)*6)      ; offset for object
              dc.w 168+(25*2)+((16+32)*2)     ; offset for con_lines
              dc.w 110                        ; y origin
              dc.w 30                         ; scale factor

              dc.w 30-1                       ; num_points -1
              dc.w 6,3,0                      ; add to angles..x, y, z
              dc.w -50*16                     ; time to show

              dc.b $ff,$ff,$00                ; x, y, z  rotate flg
              dc.b $ff                        ; sta flg  0=not. $ff=zoom
              dc.b $ff                        ; end flg  $80=fade $ff=rezoom
              dc.b 0                          ; transform. flg
              dc.b 0                          ; glance col flg
              dc.b 0                          ; laser-fx flg

* Sword
              dc.w 234+(16*6)+((8+16)*6)      ; offset for object
              dc.w 168+(25*2)+((16+32)*2)     ; offset for con_lines
              dc.w 120                        ; y origin
              dc.w 42                         ; scale factor

              dc.w 30-1                       ; num_points -1
              dc.w 6,3,2                      ; add to angles..x, y, z
              dc.w -50*20                     ; time to show

              dc.b $ff,$ff,$ff                ; x, y, z  rotate flg
              dc.b $ff                        ; sta flg  0=not. $ff=zoom
              dc.b $ff                        ; end flg  $80=fade $ff=rezoom
              dc.b 0                          ; transform. flg
              dc.b 0                          ; glance col flg
              dc.b 0                          ; laser-fx flg



* Heart
              dc.w 234+240+(30*6)+(16*6)      ; offset for object
              dc.w 168+146+(81*2)+(21*2)      ; offset for con_lines
              dc.w 60                         ; y origin
              dc.w 32                         ; scale factor

              dc.w 10-1                       ; num_points -1
              dc.w 0,2,0                      ; add to angles..x, y, z
              dc.w -50*6                      ; time to show

              dc.b $00,$ff,$00                ; x, y, z  rotate flg
              dc.b $ff                        ; sta flg  0=not. $ff=zoom
              dc.b $ff                        ; end flg  $80=fade $ff=rezoom
              dc.b 0                          ; transform. flg
              dc.b 0                          ; glance col flg
              dc.b 0                          ; laser-fx flg


* laser order
              dc.w 18*6                       ; offset for object
              dc.w 25*2                       ; offset for con_lines
              dc.w 100                        ; y origin
              dc.w 50                         ; scale factor

              dc.w 13-1                       ; num_points -1
              dc.w 2,3,4                      ; add to angles..x, y, z
              dc.w -50*79                     ; time to show

              dc.b $ff,$ff,$ff                ; x, y, z  rotate flg
              dc.b $ff                        ; sta flg  0=not. $ff=zoom
              dc.b $ff                        ; end flg  $80=fade $ff=rezoom
              dc.b 0                          ; transform. flg
              dc.b 0                          ; glance col flg
              dc.b $ff                        ; laser-fx flg

* black order
              dc.w 0                          ; offset for object
              dc.w 0                          ; offset for con_lines
              dc.w 75                         ; y origin
              dc.w 89                         ; scale factor

              dc.w 18-1                       ; num_points -1
              dc.w 2,3,1                      ; add to angles..x, y, z
              dc.w -50*100                    ; time to show

              dc.b $ff,$ff,$ff                ; x, y, z  rotate flg
              dc.b $ff                        ; sta flg  0=not. $ff=zoom
              dc.b $ff                        ; end flg  $80=fade $ff=rezoom
              dc.b 0                          ; transform. flg
              dc.b 0                          ; glance col flg
              dc.b 0                          ; laser-fx flg


              dc.b -1                         ; END!!!
              even

**********************************************************************
**********************************************************************

hbl_p3:
                move.l    a0,-(sp)
                lea       rast_data(pc),a0
                adda.w    rast_hbl(pc),a0
                move.w    (a0),$ffff8240.w
                addq.w    #2,rast_hbl

                move.l    #hbl_go,$0120.w

                move.b    #0,$fffffa1b.w
                move.b    #1,$fffffa21.w
                move.b    #8,$fffffa1b.w
                bclr      #0,$fffffa0f.w          ; isra

                movea.l   (sp)+,a0
                rte

* --------------------------------------------------------------------
hbl_go:
                move.l    a0,-(sp)
                lea       rast_data(pc),a0
                adda.w    rast_hbl(pc),a0
                move.w    (a0),$ffff8240.w
                addq.w    #2,rast_hbl

                addq.w    #1,count_lines
                bne.s     q_hbl
                move.l    #hbl_t,$0120.w
                move.w    #-87+1+14,count_lines

q_hbl:

                movea.l   (sp)+,a0
                bclr      #0,$fffffa0f.w          ; isra
                rte

**********************************************************************
hbl_t:
                movem.l   a0-a1,-(sp)
                lea       rast_data(pc),a0
                adda.w    rast_hbl(pc),a0
                move.w    (a0),$ffff8240.w

                addq.w    #2,rast_hbl

                move.b    #0,$fffffa1b.w
                move.b    #2,$fffffa21.w
                move.b    #8,$fffffa1b.w


                lea       text_screen_addr+1,a1
hbl_sync:       cmpi.b    #1,$fffffa21.w
                bne.s     hbl_sync


                lea       rast_data(pc),a0
                move.b    #0,$ffff820a.w          ; 60 Hz
                adda.w    rast_hbl(pc),a0
                move.w    (a0),$ffff8240.w

                move.b    (a1)+,$ffff8205.w
                nop
                move.b    #2,$ffff820a.w          ; 50 Hz

                move.b    (a1)+,$ffff8207.w
                move.b    (a1)+,$ffff8209.w

                addq.w    #2,rast_hbl

                move.l    #hbl_after,$0120.w

                move.b    #0,$fffffa1b.w
                move.b    #1,$fffffa21.w
                move.b    #8,$fffffa1b.w

                movem.l   (sp)+,a0-a1
                bclr      #0,$fffffa0f.w          ; isra
                rte

* --------------------------------------------------------------------
hbl_after:
                move.l    a0,-(sp)

                lea       rast_data(pc),a0
                adda.w    rast_hbl(pc),a0
                move.w    (a0),$ffff8240.w

;                lea       mirror+4(pc),a0
;                move.b    -(a0),$ffff8209.w
;                move.b    -(a0),$ffff8207.w
;                move.b    -(a0),$ffff8205.w
;                subi.l    #320,mirror

                addq.w    #2,rast_hbl

                movea.l   (sp)+,a0
                bclr      #0,$fffffa0f.w          ; isra
                rte


;mirror:       dc.l 0
count_lines:  dc.w -87+1+14

* --------------------------------------------------------------------
rast_hbl:     dc.w 0
rast_data:
              ds.w 160

              dc.w $0800,$0800
              dc.w $0100,$0100
              dc.w $0988,$0988
              dc.w $0211,$0211
              dc.w $0a99,$0a99

              dc.w $08,$00,$08,$08,$08,$08
              dc.w $01,$08,$01,$01,$01,$01
              dc.w $09,$01,$09,$09,$09,$09
              dc.w $02,$09,$02,$02,$02,$02,$02
              dc.w $0a,$02,$0a,$0a,$0a,$0a,$0a
              dc.w $03,$0a,$03,$03,$03,$03,$03
              dc.w $0b,$03,$0b,$0b,$0b,$0b,$0b,$0b
              dc.w $04,$0b,$04,$04,$04,$04,$04,$04
              dc.w $0c,$04,$0c,$0c,$0c,$0c,$0c,$0c
              dc.w $05,$0c,$05,$05,$05,$05,$05,$05,$05
              dc.w $0d,$05,$0d,$0d,$0d,$0d,$0d,$0d,$0d
              dc.w $06,$0d,$06,$06,$06,$06,$06,$06,$06,$06
              dc.w $0e,$06,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e
              dc.w $07,$0e,$07,$07,$07,$07,$07,$07,$07,$07,$07
              dc.w $0f,$07,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f

              ds.w 20,$0f                     ; !!!!!!!!!!!!!!

**********************************************************************
**********************************************************************
**********************************************************************
**********************************************************************
**********************************************************************
transformation:


                lea       tra_list(pc),a0
                adda.w    tra_listpoi(pc),a0

                addq.w    #1,trans_time
                bmi.s     not_yet
                move.w    #-50*5,trans_time

                addi.w    #6*8,tra_listpoi
                cmpa.l    #tra_listend-(6*8),a0
                bne.s     not_yet
                move.w    #0,tra_listpoi
not_yet:

                lea       tra_buff(pc),a1
                moveq     #8*3-1,d7
points_trans:
                move.w    (a0)+,d0

                cmp.w     (a1),d0
                beq.s     do_nothing
                bge.s     inc_it
                subq.w    #1,(a1)
                bra.s     do_nothing
inc_it:         addq.w    #1,(a1)

do_nothing:     addq.w    #2,a1
                dbra      d7,points_trans



                lea       tra_buff(pc),a0
                lea       obj_points(pc),a1
                adda.w    obj_offs,a1

              rept 3*8                        ; 8 points
                move.w    (a0)+,d0
                add.w     d0,d0
                move.w    d0,(a1)+
              endr

                lea       tra_listline(pc),a0
                lea       con_points(pc),a1
                adda.w    line_offs,a1
copy_line:
                move.w    (a0),(a1)+
                cmpi.w    #-1,(a0)+
                bne.s     copy_line

                rts

* --------------------------------------------------------------------
trans_time:   dc.w -50*5

tra_listpoi:  dc.w 0
tra_list:
              dc.w -40,-40,40
              dc.w 40,-40,40
              dc.w 40,40,40
              dc.w -40,40,40

              dc.w -40,-40,-40
              dc.w 40,-40,-40
              dc.w 40,40,-40
              dc.w -40,40,-40
* --------------------------------------------------------------------
              dc.w 10,-40,-40
              dc.w 10,40,-40
              dc.w 10,40,40
              dc.w 10,-40,40

              dc.w -40,-40,-10
              dc.w -40,40,-10
              dc.w -40,40,10
              dc.w -40,-40,10
* --------------------------------------------------------------------
              dc.w 0,40,40
              dc.w 0,40,40
              dc.w 0,40,40
              dc.w 0,40,40

              dc.w -60,-40,0
              dc.w -60,40,0
              dc.w -60,40,0
              dc.w -60,-40,0
* --------------------------------------------------------------------
              dc.w 10,-20,-40
              dc.w 10,20,-40
              dc.w 10,20,40
              dc.w 10,-20,40

              dc.w -40,-60,0
              dc.w -40,40,0
              dc.w -40,40,0
              dc.w -40,-60,0
* --------------------------------------------------------------------
              dc.w -40,20,-40
              dc.w -40,20,-40
              dc.w -40,20,40
              dc.w -40,20,40

              dc.w 50,-40,0
              dc.w 50,40,0
              dc.w 50,40,0
              dc.w 50,-40,0
* --------------------------------------------------------------------
              dc.w 0,0,-40
              dc.w 0,0,-40
              dc.w 0,0,40
              dc.w 0,0,40

              dc.w -50,-40,40
              dc.w -50,40,40
              dc.w -50,40,40
              dc.w -50,-40,40
* --------------------------------------------------------------------

              dc.w -60,40,40
              dc.w 60,40,40
              dc.w 60,40,40
              dc.w -60,40,40

              dc.w -10,40,-40
              dc.w 10,40,-40
              dc.w 10,40,-40
              dc.w -10,40,-40
* --------------------------------------------------------------------

              dc.w -10,40,40
              dc.w 10,40,40
              dc.w 10,40,40
              dc.w -10,40,40

              dc.w -10,40,-40
              dc.w 10,40,-40
              dc.w 10,40,-40
              dc.w -10,40,-40
* --------------------------------------------------------------------

              dc.w -10,-40,40
              dc.w 10,-40,40
              dc.w 10,40,40
              dc.w -10,40,40

              dc.w -10,-40,-40
              dc.w 10,-40,-40
              dc.w 10,40,-40
              dc.w -10,40,-40
**********************************************************************
              dc.w -40,-40,40
              dc.w 40,-40,40
              dc.w 40,40,40
              dc.w -40,40,40

              dc.w -40,-40,-40
              dc.w 40,-40,-40
              dc.w 40,40,-40
              dc.w -40,40,-40
**********************************************************************
              dc.w -40,40,0
              dc.w 40,40,0
              dc.w 40,40,0
              dc.w -40,40,0

              dc.w -40,40,0
              dc.w 40,40,0
              dc.w 40,40,0
              dc.w -40,40,0

* --------------------------------------------------------------------

              dc.w -40,-40,40
              dc.w 0,-40,40
              dc.w 0,40,40
              dc.w -40,40,40

              dc.w -40,-40,-40
              dc.w 0,-40,-40
              dc.w 0,40,-40
              dc.w -40,40,-40

* --------------------------------------------------------------------
              dc.w 40,-40,40
              dc.w 0,-40,40
              dc.w 0,40,40
              dc.w 40,40,40

              dc.w 40,-40,-40
              dc.w 0,-40,-40
              dc.w 0,40,-40
              dc.w 40,40,-40
* --------------------------------------------------------------------
              dc.w 40,-40,0
              dc.w 0,-40,0
              dc.w 0,40,0
              dc.w 40,40,0

              dc.w 40,-40,-40
              dc.w 0,-40,-40
              dc.w 0,40,-40
              dc.w 40,40,-40
* --------------------------------------------------------------------

              dc.w 0,-40,60
              dc.w 0,-40,60
              dc.w 0,40,60
              dc.w 0,40,60

              dc.w 0,-40,-40
              dc.w 0,-40,-40
              dc.w 0,40,-40
              dc.w 0,40,-40


tra_listend:

tra_listline:
* 26*2
              dc.w 0,1,1,2,2,3,3,0
              dc.w 4,5,5,6,6,7,7,4
              dc.w 0,4,1,5,2,6,3,7
              dc.w -1

tra_buff:     ds.w 3*8

              even

**********************************************************************
**********************************************************************


chk_y_clr:
                lea       points_buffer+2(pc),a0
                move.w    (a0),d0
                move.w    d0,d1

                move.w    num_points(pc),d7
                subq.w    #1,d7
low_y:          addq.w    #6,a0

                cmp.w     (a0),d0
                bgt.s     new_low_y
                bra.s     high_y
new_low_y:      move.w    (a0),d0                 ; lower y

high_y:         cmp.w     (a0),d1
                blt.s     new_high_y
                dbra      d7,low_y
                bra.s     ready_chk
new_high_y:     move.w    (a0),d1                 ; higher y
                dbra      d7,low_y
ready_chk:
                add.w     y_origin(pc),d0
                add.w     y_origin(pc),d1


                cmp.w     #200,d0
                blo.s     chk_other
                moveq     #0,d0

chk_other:
                cmp.w     #200,d1
                blo.s     save_clr
                move.w    #199,d1
save_clr:


                lea       old_clr(pc),a0
                move.w    (a0),clr_start
                move.w    2(a0),clr_end
                move.w    d0,(a0)+
                move.w    d1,(a0)+
                rts

clr_start:    dc.w 0
clr_end:      dc.w 0
old_clr:      ds.w 2

**********************************************************************
* dest address in a1!
* ( d0 = y start )
* ( d1 = y end   )
clr_screen_p3:
                move.w    clr_start(pc),d0
                move.w    clr_end(pc),d1

                sub.w     d0,d1
                addq.w    #1,d1

                lea       yadd_tab(pc),a0
                add.w     d0,d0                   ; *2
                adda.w    0(a0,d0.w),a1           ; y conv, add to screen
                mulu      #20,d1                  ; words/line

* --------------------------------------------------------------------

                lea       $ffff8a2e.w,a0

                move.w    #8,(a0)+                ; des xinc
                move.w    #0,(a0)+                ; des yinc
                move.l    a1,(a0)+                ; des addr

                move.w    d1,(a0)+                ; x cnt
                move.w    #1,(a0)+                ; y cnt
                move.w    #%0,(a0)+               ; hop
;                move.w    #%100000000,(a0)+       ; hop
                move.w    #%1100000000000000,(a0)+ ;busy


                addq.w    #2,a1
                lea       $ffff8a2e+4.w,a0
                move.l    a1,(a0)+                ; des addr

                move.w    d1,(a0)+                ; x cnt
                move.w    #1,(a0)+                ; y cnt
                move.w    #%1100000000000000,2(a0) ;busy
                rts

**********************************************************************
**********************************************************************
**********************************************************************
**********************************************************************
**********************************************************************
z_no_rotate_flg:dc.b 0
              even
old_z_rotate_buffer:ds.w 50*2

* (radians = 180/grader...)
calculate_shit3d:

                lea       sin_tab_p3(pc),a1       ; sin
                lea       180(a1),a2              ; cos

                lea       obj_points(pc),a0
                adda.w    obj_offs,a0
                lea       points_buffer(pc),a6

                move.w    x_rotate_angle(pc),d4
                add.w     d4,d4                   ; * 2 (for sin_tab)
                move.w    y_rotate_angle(pc),d5
                add.w     d5,d5                   ; * 2 (for sin_tab)
                move.w    z_rotate_angle(pc),d6
                add.w     d6,d6                   ; * 2 (for sin_tab)




                lea       old_z_rotate_buffer,a3
                bsr       zxy_rotate
                tst.b     z_rotate_flg
                bne.s     no_st
                st        z_no_rotate_flg
                bra.s     yepp
no_st:          sf        z_no_rotate_flg
yepp:

                bsr       projection
                bsr       scaling

                lea       points_buffer(pc),a0
                lea       con_points(pc),a1
                adda.w    line_offs(pc),a1
                move.w    #160,d4                 ; for centration...
;                moveq     #100,d5
                move.w    y_origin(pc),d5

line_loop:
                move.w    (a1)+,d6
                bmi.s     end_of_lines
                mulu      #6,d6                   ; so many bytes...
                move.w    0(a0,d6.w),d0
                move.w    2(a0,d6.w),d1
                cmpi.w    #0,4(a0,d6.w)
                bpl.s     bit_pl
                moveq     #2,d7
                bra.s     next
bit_pl:         moveq     #0,d7

next:
                move.w    (a1)+,d6
                mulu      #6,d6                   ; so many bytes...
                move.w    0(a0,d6.w),d2
                move.w    2(a0,d6.w),d3
                cmpi.w    #0,4(a0,d6.w)
                bpl.s     lines_out
                moveq     #2,d7
lines_out:

                add.w     d4,d0
                add.w     d5,d1
                add.w     d4,d2
                add.w     d5,d3

                movem.l   d0-d6/a0-a3,-(sp)
                bsr       draw_line               ; d7 = bitplane offset
                movem.l   (sp)+,d0-d6/a0-a3
                bra.s     line_loop
end_of_lines:
                rts


**********************************************************************
**********************************************************************
* d6 = z rotate
zxy_rotate:
                movea.w   num_points(pc),a5
rotate_lp:

* rotate
                tst.b     z_no_rotate_flg
                beq.s     take_new_z
                move.w    (a3)+,d1
                move.w    (a3)+,d3
                addq.w    #4,a0
                bra.s     old_z_taken

take_new_z:
                move.w    (a0)+,d0                ; get x
                move.w    d0,d1
                move.w    0(a1,d6.w),d7           ; get sin value
                muls      d7,d0                   ; x * sin

                move.w    (a0)+,d2                ; get y
                move.w    d2,d3
                muls      d7,d2                   ; y * sin

                move.w    0(a2,d6.w),d7           ; get cos value
                muls      d7,d1                   ; x * cos
                muls      d7,d3                   ; y * cos

; d0 = x sin  d1 = x cos | d2 = y sin  d3 = y cos

                sub.l     d2,d1                   ; xr = x cos - y sin
                add.l     d0,d3                   ; yr = y cos + x sin

                swap      d1                      ; going to /16384
                rol.l     #2,d1
                swap      d3
                rol.l     #2,d3

                tst.b     z_rotate_flg
                bne.s     old_z_taken
                move.w    d1,(a3)+
                move.w    d3,(a3)+


old_z_taken:
                move.w    d1,(a6)+                ; save x

**********************************************************************
* d1 = x  d3 = y
* d4 = x rotate

                move.w    d3,d0                   ; y
                move.w    d0,d1
                move.w    0(a1,d4.w),d7           ; get sin value
                muls      d7,d0                   ; y * sin

                move.w    (a0)+,d2                ; get z

                move.w    d2,d3
                muls      d7,d2                   ; z * sin

                move.w    0(a2,d4.w),d7           ; get cos value
                muls      d7,d1                   ; y * cos
                muls      d7,d3                   ; z * cos

; d0 = y sin  d1 = y cos | d2 = z sin  d3 = z cos

                add.l     d2,d1                   ; yr = y cos + z sin
                sub.l     d0,d3                   ; zr = z cos - y sin

                swap      d1                      ; going to /16384
                rol.l     #2,d1
                swap      d3
                rol.l     #2,d3

                move.w    d1,(a6)+                ; save y

**********************************************************************
* d1 = y  d3 = z
* d5 = y rotate

                subq.w    #4,a6                   ; points on x

                move.w    (a6),d0                 ; get x
                move.w    d0,d1
                move.w    0(a1,d5.w),d7           ; get sin value
                muls      d7,d0                   ; x * sin

                move.w    d3,d2
                muls      d7,d2                   ; z * sin

                move.w    0(a2,d5.w),d7           ; get cos value
                muls      d7,d1                   ; x * cos
                muls      d7,d3                   ; z * cos

; d0 = x sin  d1 = x cos | d2 = z sin  d3 = z cos

                sub.l     d2,d1                   ; xr = x cos - z sin
                add.l     d0,d3                   ; zr = z cos + x sin

                swap      d1                      ; going to /16384
                rol.l     #2,d1
                swap      d3
                rol.l     #2,d3

                move.w    d1,(a6)+                ; save x
                addq.w    #2,a6
                move.w    d3,(a6)+                ; save z

                subq.w    #1,a5
                cmpa.w    #-1,a5
                bne       rotate_lp
                rts

**********************************************************************
**********************************************************************
projection:
;                move.w    #$03,$ffff8240.w

                lea       points_buffer(pc),a0
                movea.l   a0,a1
                lea       projection_tab(pc),a2

                move.w    num_points(pc),d6
proj_it:
                move.w    (a0)+,d0                ; x
                move.w    (a0)+,d1                ; y
                move.w    (a0)+,d2                ; z

;                asr.w     #1,d0
;                asr.w     #1,d1
;                asr.w     #1,d2

                asr.w     #1,d2
                add.w     #100,d2

                bclr      #0,d2
                move.w    0(a2,d2.w),d7           ; get sin value
                sub.w     #16384,d7
                lsr.w     #1,d7

                muls      d7,d0
                muls      d7,d1

                swap      d0                      ; going to /16384
                rol.l     #3,d0                   ; check it!!!!!! Nice!
                swap      d1
                rol.l     #3,d1

                move.w    d0,(a1)+
                move.w    d1,(a1)+
                addq.w    #2,a1

                dbra      d6,proj_it

;                move.w    #$0300,$ffff8240.w
                rts

**********************************************************************
**********************************************************************
scaling:
;                move.w    #$0330,$ffff8240.w

                lea       points_buffer(pc),a0
                movea.l   a0,a1
                lea       neg_sin_tab_p3(pc),a2

                move.w    scale_factor(pc),d3
                add.w     d3,d3

                move.w    num_points(pc),d6
scale_it:
                move.w    (a0)+,d0                ; x
                move.w    (a0)+,d1                ; y
                addq.w    #2,a0

                move.w    0(a2,d3.w),d7           ; get sin value
                add.w     #16384,d7
                lsr.w     #1,d7

                muls      d7,d0
                muls      d7,d1

                swap      d0                      ; going to /16384
                rol.l     #2,d0
                swap      d1
                rol.l     #2,d1

                move.w    d0,(a1)+
                move.w    d1,(a1)+
                addq.w    #2,a1

                dbra      d6,scale_it

;                move.w    #$0300,$ffff8240.w
                rts

scale_factor: dc.w 25+10+6+2

**********************************************************************
**********************************************************************
**********************************************************************
**********************************************************************
num_points:   dc.w 0


counter:      dc.w 0

points_buffer:ds.w 50*3

x_rotate_angle:dc.w 0
y_rotate_angle:dc.w 0
z_rotate_angle:dc.w 0

**********************************************************************
* 0 = love making point...
* x, y, z


obj_points:
* ICE 18*6
              dc.w -60+10,-30,0
              dc.w -40+10,-30,0
              dc.w -50+10,-30,0
              dc.w -50+10,30,0
              dc.w -60+10,30,0
              dc.w -40+10,30,0

              dc.w -40+20,-20,0
              dc.w -40+20,20,0
              dc.w -30+20,-30,0
              dc.w -10+20,-30,0
              dc.w -30+20,30,0
              dc.w -10+20,30,0

              dc.w 0+20,-30,0
              dc.w 30+20,-30,0
              dc.w 0+26,-4,0
              dc.w 20+20,-4,0
              dc.w 0+20,30,0
              dc.w 30+20,30,0

* --------------------------------------------------------------------
* laser 13*6
              dc.w -30,-30,30
              dc.w 30,-30,30
              dc.w 30,30,30
              dc.w -30,30,30

              dc.w -30,-30,-30
              dc.w 30,-30,-30
              dc.w 30,30,-30
              dc.w -30,30,-30

              dc.w 0,0,0

              dc.w 0,0,0
              dc.w 0,0,0
              dc.w 0,0,0
              dc.w 0,0,0
* --------------------------------------------------------------------
* transform 8*6

              dc.w 0,0,0
              dc.w 0,0,0
              dc.w 0,0,0
              dc.w 0,0,0

              dc.w 0,0,0
              dc.w 0,0,0
              dc.w 0,0,0
              dc.w 0,0,0
* --------------------------------------------------------------------
* tea 16*6
              dc.w -60,-60,0
              dc.w -17,-60,0
              dc.w -40,-60,0
              dc.w -40,60,0

              dc.w -17,-60,0
              dc.w 20,-60,0
              dc.w -17+6,-4,0
              dc.w 16,-4,0
              dc.w -17,60,0
              dc.w 20,60,0

              dc.w 23,60,0
              dc.w 23,-20,0
              dc.w 23+10,-60,0
              dc.w 23+30,-60,0
              dc.w 23+40,4,0
              dc.w 23+40,60,0

* VU 8*6
              dc.w -5,-5,0
              dc.w 5,-5,0
              dc.w 5,5,0
              dc.w -5,5,0

              dc.w 0,0,0                      ; x change
              dc.w 0,0,0
              dc.w 0,0,0                      ; y change
              dc.w 0,0,0

;              dc.w 0,0,-20
;              dc.w 0,0,20

* --------------------------------------------------------------------
* Surfer 16*6
              dc.w -30,0,-7
              dc.w 40,0,-7
              dc.w 40,0,7
              dc.w -30,0,7
              dc.w -40,0,3
              dc.w -40,0,-3

              dc.w 25,0,0
              dc.w 35,0,0
              dc.w 35,7,0


              dc.w -15,0,0
              dc.w -15,-80,0
              dc.w 30,-20+3,0
              dc.w -15,-20+3,0

              dc.w -15,-24+3,0
              dc.w -12,-23+3,-4
              dc.w -12,-23+3,4
* --------------------------------------------------------------------
* Sword 30*6
              dc.w -50*2,0,0
              dc.w -30*2,-5*2,0
              dc.w -8*2,-3*2,0
              dc.w -8*2,3*2,0
              dc.w -30*2,5*2,0
              dc.w -8*2,0,0

***
              dc.w -7*2,-12*2,3*2
              dc.w -6*2,-9*2,3*2
              dc.w -6*2,9*2,3*2
              dc.w -7*2,12*2,3*2
              dc.w -8*2,9*2,3*2
              dc.w -8*2,-9*2,3*2
*

              dc.w -7*2,-12*2,-3*2
              dc.w -6*2,-9*2,-3*2
              dc.w -6*2,9*2,-3*2
              dc.w -7*2,12*2,-3*2
              dc.w -8*2,9*2,-3*2
              dc.w -8*2,-9*2,-3*2


***
              dc.w -6*2,-3*2,0
              dc.w 12*2,-3*2,0
              dc.w 12*2,3*2,0
              dc.w -6*2,3*2,0

              dc.w -6*2,0,2*2
              dc.w 12*2,0,2*2
              dc.w 12*2,0,-2*2
              dc.w -6*2,0,-2*2

***
              dc.w 12*2,-6*2,-3*2
              dc.w 12*2,6*2,-3*2
              dc.w 12*2,6*2,3*2
              dc.w 12*2,-6*2,3*2
* --------------------------------------------------------------------
* plate 16*6

              dc.w -60,-60,0
              dc.w -30,-60,0
              dc.w 0,-60,0
              dc.w 30,-60,0
              dc.w 60,-60,0

              dc.w -60,-30,0
              dc.w -60,0,0
              dc.w -60,30,0
              dc.w -60,60,0


              dc.w -30,60,0
              dc.w 0,60,0
              dc.w 30,60,0
              dc.w 60,60,0

              dc.w 60,-30,0
              dc.w 60,0,0
              dc.w 60,30,0


* Heart 10*6
              dc.w 0,30*4,0
              dc.w -20*4,10*4,0
              dc.w -20*4,0,0
              dc.w -10*4,-10*4,0
              dc.w -5*4,-10*4,0
              dc.w 0,-2*4,0

              dc.w 20*4,10*4,0
              dc.w 20*4,0,0
              dc.w 10*4,-10*4,0
              dc.w 5*4,-10*4,0

obj_end:


**********************************************************************

con_points:
* ICE 25*2
              dc.w 0,1,2,3,4,5
              dc.w 6,7,6,8,8,9,7,10,10,11
              dc.w 12,13,14,15,16,17,12,16
              dc.w -1

* --------------------------------------------------------------------
* laser 33*2
              dc.w 0,1,1,2,2,3,3,0
              dc.w 4,5,5,6,6,7,7,4
              dc.w 0,4,1,5,2,6,3,7
              dc.w 8,9,8,10
              dc.w 8,11,8,12
              dc.w -1

* --------------------------------------------------------------------
* transf. 26*2
              ds.b 26*2

* --------------------------------------------------------------------
* tea 25*2

              dc.w 0,1,2,3
              dc.w 4,5,6,7,8,9,4,8
              dc.w 10,11,11,12,12,13,13,14,14,15,11,14
              dc.w -1
* --------------------------------------------------------------------
* VU 16*2
              dc.w 4,0,4,3,5,1,5,2,6,0,6,1,7,2,7,3 ; x -+  y -+
;              dc.w 8,9
              dc.w -1

* --------------------------------------------------------------------
* Surfer 31*2

              dc.w 0,1,1,2,2,3,3,4,4,5,5,0
              dc.w 6,8,8,7
              dc.w 9,10,10,11,11,12
              dc.w 13,14,14,11,11,15,15,13
              dc.w -1
* --------------------------------------------------------------------
* Sword 81*2

              dc.w 0,1,1,2,2,3,3,4,4,0,0,5

              dc.w 6,7,7,8,8,9,9,10,10,11,11,6
              dc.w 6+6,7+6,7+6,8+6,8+6,9+6,9+6,10+6,10+6,11+6,11+6,6+6
              dc.w 6,12,7,13,8,14,9,15,10,16,11,17

              dc.w 0+18,1+18,2+18,3+18
              dc.w 4+18,5+18,6+18,7+18

              dc.w 0+26,1+26,1+26,2+26,2+26,3+26,3+26,0+26

              dc.w 19,23,23,20,20,24,24,19
              dc.w 18,22,22,21,21,25,25,18

              dc.w -1

* --------------------------------------------------------------------
* Plate 21*2
              dc.w 0,8,1,9,2,10,3,11,4,12
              dc.w 0,4,5,13,6,14,7,15,8,12
              dc.w -1

* --------------------------------------------------------------------
* Heart
              dc.w 0,1,1,2,2,3,3,4,4,5
              dc.w 0,6,6,7,7,8,8,9,9,5

              dc.w -1

**********************************************************************
**********************************************************************

sin_tab_p3:

              dc.w 0,286,572,857,1143,1428,1713,1997,2280
              dc.w 2563,2845,3126,3406,3686,3964,4240,4516
              dc.w 4790,5063,5334,5604,5872,6138,6402,6664
              dc.w 6924,7182,7438,7692,7943,8192,8438,8682
              dc.w 8923,9162,9397,9630,9860,10087,10311,10531
              dc.w 10749,10963,11174,11381,11585,11786,11982,12176
              dc.w 12365,12551,12733,12911,13085,13255,13421,13583
              dc.w 13741,13894,14044,14189,14330,14466,14598,14726
              dc.w 14849,14962,15082,15191,15296,15396,15491,15582
              dc.w 15668,15749,15826,15897,15964,16026,16083,16135
              dc.w 16182,16225,16262,16294,16322,16344,16362,16374
              dc.w 16382
; 90

cos_tab_p3:   dc.w 16384
              dc.w 16382,16374,16362,16344,16322,16294,16262,16225
              dc.w 16182
              dc.w 16135,16083,16026,15964,15897,15826,15749,15668
              dc.w 15582,15449,15396,15296,15191,15082,14962,14849
              dc.w 14726,14598,14466,14330,14189,14044,13894,13741
              dc.w 13583,13421,13255,13085,12911,12733,12551,12365
              dc.w 12176,11982,11786,11585,11381,11174,10963,10749
              dc.w 10531,10311,10087,9860,9630,9397,9162,8923
              dc.w 8682,8438,8192,7943,7692,7438,7182,6924
              dc.w 6664,6402,6138,5872,5604,5334,5063,4790
              dc.w 4516,4240,3964,3686,3406,3126,2845,2563
              dc.w 2280,1997,1713,1428,1143,857,572,286,0

neg_sin_tab_p3:
              dc.w -286,-572,-857,-1143,-1428,-1713,-1997,-2280
              dc.w -2563,-2845,-3126,-3406,-3686,-3964,-4240,-4516
              dc.w -4790,-5063,-5334,-5604,-5872,-6138,-6402,-6664
              dc.w -6924,-7182,-7438,-7692,-7943,-8192,-8438,-8682
              dc.w -8923,-9162,-9397,-9630,-9860,-10087,-10311,-10531
              dc.w -10749,-10963,-11174,-11381,-11585,-11786,-11982,-12176
              dc.w -12365,-12551,-12733,-12911,-13085,-13255,-13421,-13583
              dc.w -13741,-13894,-14044,-14189,-14330,-14466,-14598,-14726
              dc.w -14849,-14962,-15082,-15191,-15296,-15396,-15491,-15582
              dc.w -15668,-15749,-15826,-15897,-15964,-16026,-16083,-16135
              dc.w -16182,-16225,-16262,-16294,-16322,-16344,-16362,-16374
              dc.w -16382,-16384

              dc.w -16382,-16374,-16362,-16344,-16322,-16294,-16262,-16225
              dc.w -16182
              dc.w -16135,-16083,-16026,-15964,-15897,-15826,-15749,-15668
              dc.w -15582,-15449,-15396,-15296,-15191,-15082,-14962,-14849
              dc.w -14726,-14598,-14466,-14330,-14189,-14044,-13894,-13741
              dc.w -13583,-13421,-13255,-13085,-12911,-12733,-12551,-12365
              dc.w -12176,-11982,-11786,-11585,-11381,-11174,-10963,-10749
              dc.w -10531,-10311,-10087,-9860,-9630,-9397,-9162,-8923
              dc.w -8682,-8438,-8192,-7943,-7692,-7438,-7182,-6924
              dc.w -6664,-6402,-6138,-5872,-5604,-5334,-5063,-4790
              dc.w -4516,-4240,-3964,-3686,-3406,-3126,-2845,-2563
              dc.w -2280,-1997,-1713,-1428,-1143,-857,-572,-286,0

* extend
              dc.w 0,286,572,857,1143,1428,1713,1997,2280
              dc.w 2563,2845,3126,3406,3686,3964,4240,4516
              dc.w 4790,5063,5334,5604,5872,6138,6402,6664
              dc.w 6924,7182,7438,7692,7943,8192,8438,8682
              dc.w 8923,9162,9397,9630,9860,10087,10311,10531
              dc.w 10749,10963,11174,11381,11585,11786,11982,12176
              dc.w 12365,12551,12733,12911,13085,13255,13421,13583
              dc.w 13741,13894,14044,14189,14330,14466,14598,14726
              dc.w 14849,14962,15082,15191,15296,15396,15491,15582
              dc.w 15668,15749,15826,15897,15964,16026,16083,16135
              dc.w 16182,16225,16262,16294,16322,16344,16362,16374
              dc.w 16382

* --------------------------------------------------------------------

projection_tab:
              dc.w -16382,-16374,-16362,-16344,-16322,-16294,-16262,-16225
              dc.w -16182
              dc.w -16135,-16083,-16026,-15964,-15897,-15826,-15749,-15668
              dc.w -15582,-15449,-15396,-15296,-15191,-15082,-14962,-14849
              dc.w -14726,-14598,-14466,-14330,-14189,-14044,-13894,-13741
              dc.w -13583,-13421,-13255,-13085,-12911,-12733,-12551,-12365
              dc.w -12176,-11982,-11786,-11585,-11381,-11174,-10963,-10749
              dc.w -10531,-10311,-10087,-9860,-9630,-9397,-9162,-8923
              dc.w -8682,-8438,-8192,-7943,-7692,-7438,-7182,-6924
              dc.w -6664,-6402,-6138,-5872,-5604,-5334,-5063,-4790
              dc.w -4516,-4240,-3964,-3686,-3406,-3126,-2845,-2563
              dc.w -2280,-1997,-1713,-1428,-1143,-857,-572,-286,0

              ds.w 10

              even
**********************************************************************
**********************************************************************
* Superfast line-draw...  v1.06                                      *
* By Tobias Nilsson, "Techwave"                                      *
* Using d0-d6/a0-a3
* d0=x1  d1=y1 , d2=x2  d3=y2

end:
                move.w    #$0f00,$ffff8240.w
                rts
draw_line:
                cmp.w     #0,d0
                blo.s     end
                cmp.w     #319,d0
                bhi.s     end
                cmp.w     #0,d1
                blo.s     end
                cmp.w     #199,d1
                bhi.s     end
                cmp.w     #0,d2
                blo.s     end
                cmp.w     #319,d2
                bhi.s     end
                cmp.w     #0,d3
                blo.s     end
                cmp.w     #199,d3
                bhi.s     end

                cmp.w     d0,d2                   ; chk if neg x
                bhi.s     no_exg_p3
                exg       d0,d2
                exg       d1,d3
no_exg_p3:
                addq.w    #1,d2
* --------------------------------------------------------------------

                move.w    d2,d4
                sub.w     d0,d4                   ; x2-x1 > x

                cmp.w     d1,d3
                blo.s     st_yline_flg_p3
                sf        yline_flg
                addq.w    #1,d3

                move.w    d3,d5
                sub.w     d1,d5                   ; y2-y1 > y
                bra.s     go_p3

st_yline_flg_p3:
                st        yline_flg
                subq.w    #1,d3

                move.w    d1,d5
                sub.w     d3,d5                   ; y1-y2 > y (second)

* --------------------------------------------------------------------
* d6 is holy (sacred)!
go_p3:
                cmp.w     d4,d5
                bge.s     yes_low_p3

                move.w    d5,d6
                lsr.w     #1,d6
                neg.w     d6
                add.w     d4,d6                   ; E + x

                move.w    d4,d2                   ; x  ...times
                add.w     d5,d2                   ; y

                move.w    d4,d3
                sub.w     d5,d3

                add.w     d3,d2
                bra.s     go_draw
* --------------------------------------------------------------------
yes_low_p3:
                move.w    d4,d6
                lsr.w     #1,d6

                move.w    d4,d2                   ; x  ...times
                add.w     d5,d2                   ; y

                move.w    d5,d3
                sub.w     d4,d3

                add.w     d3,d2
* --------------------------------------------------------------------
* d4 = x  d5 = y  d6 = holy
go_draw:
                lea       xadd_tab(pc),a0
                lea       yadd_tab(pc),a1
                lea       xadd_rel(pc),a2
                movea.l   screen1_p3(pc),a3       ; a3 = workscreen
                adda.w    d7,a3                   ; bitplane!!!!!!!!!

                add.w     d0,d0                   ; *2
                adda.w    d0,a2                   ; 0 or 8
                add.w     d0,d0                   ; *2
                add.w     d1,d1                   ; *2

                adda.w    0(a1,d1.w),a3           ; y conv, add to screen
                adda.w    0(a0,d0.w),a3           ; x conv, add to screen
                move.w    2(a0,d0.w),d1           ; pixel
                moveq     #1,d0                   ; for rotate

                mulu      #10,d2                  ; bytes
                subq.w    #4,d2

                tst.b     yline_flg
                bne.s     yez_up

                lea       end_of_draw(pc),a0
                suba.w    d2,a0
                jmp       (a0)
yez_up:
                lea       end_of_draw_2(pc),a0
                suba.w    d2,a0
                jmp       (a0)

**********************************************************************
              rept 320

                adda.w    (a2)+,a3                ; step x
                ror.w     d0,d1
                or.w      d1,(a3)
                sub.w     d5,d6
                bpl.s     *+10

                or.w      d1,(a3)                 ; step y
                lea       160(a3),a3
                add.w     d4,d6
                bmi.s     *+10

              endr

end_of_draw:
              rept 5
                rts
              endr

**********************************************************************
              rept 320

                adda.w    (a2)+,a3                ; step x
                ror.w     d0,d1
                or.w      d1,(a3)
                sub.w     d5,d6
                bpl.s     *+10

                or.w      d1,(a3)                 ; step y
                lea       -160(a3),a3
                add.w     d4,d6
                bmi.s     *+10

              endr

end_of_draw_2:
              rept 5
                rts
              endr

**********************************************************************
yline_flg:    dc.b 0
              even
xadd_rel:
              dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
              rept 19
              dc.w 8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
              endr

* x-add with rotated pixel!
* .l (scrnoff, pixel)
xadd_tab:
              ibytes 'X_ADD.IMG'

* .w (lineoffset)
yadd_tab:
              ibytes 'Y_ADD.IMG'

screen1_p3:   dc.l 0
screen2_p3:   dc.l 0

              even
**********************************************************************
**********************************************************************
**********************************************************************
******************************************************************************
* Noisetracker replay using no fucking timer!   (v1.0)                       *
* Code by M.K. Extended by Wizzcat. Modified (for vbl) & speeded by Techwave *
******************************************************************************

* 0=6.259, 1=12.517, 2=25.036

FREQUENCY     equ 1
LEN           equ 250*1
INC           equ $011df98a/1

MVOL          equ $80
PARTS         equ 1-1

* --------------------------------------------------------------------
tracker_init:
                cmpi.l    #"M.K.",module+$0438
                beq.s     yez_right

                move.w    #$0700,$ffff8240.w

                move.w    #7,-(sp)
                trap      #1
                addq.w    #2,sp

                clr.w     -(sp)
                trap      #1                      ; Terminate

* --------------------------------------------------------------------
yez_right:
                bsr       noise_vol               ; Calculate volume tables
                bsr       noise_incrcal           ; Calculate tonetables

                jsr       noise_init              ; Initialize music
                jsr       noise_prepare           ; Prepare samples

                move.b    #FREQUENCY,$ffff8921.w


                move.w    #%10011000000+20,mw_settings ; master... test!
                jsr       set_mw
                move.w    #%10011000000+40,mw_settings ; master    0-40
                jsr       set_mw


                rts
**********************************************************************
**********************************************************************
**********************************************************************
**********************************************************************

* --------------------------------------------------------- Volume table

noise_vol:      moveq     #64,d0
                lea       vtabend(pc),a0

.ploop:         move.w    #255,d1
.mloop:         move.w    d1,d2
                ext.w     d2
                muls      d0,d2
                divs      #MVOL,d2
                move.b    d2,-(a0)
                dbra      d1,.mloop
                dbra      d0,.ploop
                rts

vtab:         ds.b 65*256
vtabend:

* ------------------------------------------------------ Increment-table
noise_incrcal:  lea       stab(pc),a0
                move.w    #$30,d1                 ; $30
                move.w    #$039f-$30,d0
                move.l    #INC,d2                 ; <----- INC

recalc:         swap      d2
                moveq     #0,d3
                move.w    d2,d3
                divu      d1,d3
                move.w    d3,d4
                swap      d4

                swap      d2
                move.w    d2,d3
                divu      d1,d3
                move.w    d3,d4

                move.l    d4,(a0)+

                addq.w    #1,d1
                dbra      d0,recalc
                rts


itab:         ds.l $30
stab:         ds.l $03a0-$30

**********************************************************************
noise_rout:

                move.l    samp1,d0                ; exg buff 1 <> buff 2
                move.l    samp2,samp1
                move.l    d0,samp2
                lea       $ffff8907.w,a0          ; dma address
                move.b    d0,(a0)                 ; start low
                lsr.w     #8,d0
                move.l    d0,-5(a0)               ; start mid, high
                move.l    samp2,d0
                add.l     #LEN*2,d0               ; end sample (200 bytes)
                move.b    d0,12(a0)               ; end low
                lsr.w     #8,d0
                move.l    d0,7(a0)                ; end mid, high
                move.b    #0,$ffff8901.w          ; Stop  DMA
                move.b    #1,$ffff8901.w          ; Start DMA

                subq.w    #1,count
                bpl.s     .nomus

                move.w    #PARTS,count
                jsr       music                   ; branch subrout

**********************************************************************

.nomus:         lea       itab(pc),a5
                lea       vtab(pc),a3
                moveq     #0,d0
                moveq     #0,d4

* voice 2
                movea.l   pro_2lc(pc),a0
                move.w    pro_2pos(pc),d0
                move.w    pro_2frc(pc),d1

                move.w    aud_2per(pc),d7
                add.w     d7,d7
                add.w     d7,d7
                move.w    0(a5,d7.w),d2

                movea.w   2(a5,d7.w),a4

                move.w    aud_2vol(pc),d7
                asl.w     #8,d7
                lea       0(a3,d7.w),a2

* voice 3
                movea.l   pro_3lc(pc),a1
                move.w    pro_3pos(pc),d4
                move.w    pro_3frc(pc),d5

                move.w    aud_3per(pc),d7
                add.w     d7,d7
                add.w     d7,d7
                move.w    0(a5,d7.w),d6
                movea.w   2(a5,d7.w),a5

                move.w    aud_3vol(pc),d7
                asl.w     #8,d7
                lea       0(a3,d7.w),a3


                movea.l   samp1(pc),a6            ; buffer 1
                moveq     #0,d3

              rept LEN                        ; some times
                add.w     a4,d1
                addx.w    d2,d0
                add.w     a5,d5
                addx.w    d6,d4
                move.b    0(a0,d0.l),d3
                move.b    0(a2,d3.w),d7
                move.b    0(a1,d4.l),d3
                add.b     0(a3,d3.w),d7
                move.w    d7,(a6)+                ; .w
              endr

                cmp.l     pro_2len(pc),d0
                blt.s     .ok2
                sub.w     pro_2rpt(pc),d0

.ok2:           move.w    d0,pro_2pos
                move.w    d1,pro_2frc

                cmp.l     pro_3len(pc),d4
                blt.s     .ok3
                sub.w     pro_3rpt(pc),d4

.ok3:           move.w    d4,pro_3pos
                move.w    d5,pro_3frc

**********************************************************************

                lea       itab(pc),a5
                lea       vtab,a3                 ; (pc)
                moveq     #0,d0
                moveq     #0,d4
* voice 1
                movea.l   pro_1lc(pc),a0

                move.w    pro_1pos(pc),d0
                move.w    pro_1frc(pc),d1

                move.w    aud_1per(pc),d7
                add.w     d7,d7
                add.w     d7,d7
                move.w    0(a5,d7.w),d2
                movea.w   2(a5,d7.w),a4

                move.w    aud_1vol(pc),d7
                asl.w     #8,d7
                lea       0(a3,d7.w),a2

* voice 4
                movea.l   pro_4lc(pc),a1
                move.w    pro_4pos(pc),d4
                move.w    pro_4frc(pc),d5

                move.w    aud_4per(pc),d7
                add.w     d7,d7
                add.w     d7,d7
                move.w    0(a5,d7.w),d6
                movea.w   2(a5,d7.w),a5

                move.w    aud_4vol(pc),d7
                asl.w     #8,d7
                lea       0(a3,d7.w),a3

                movea.l   samp1(pc),a6            ; buffer 1
                moveq     #0,d3

              rept LEN                        ; some times
                add.w     a4,d1
                addx.w    d2,d0
                add.w     a5,d5
                addx.w    d6,d4
                move.b    0(a0,d0.l),d3
                move.b    0(a2,d3.w),d7
                move.b    0(a1,d4.l),d3
                add.b     0(a3,d3.w),d7
                move.b    d7,(a6)                 ; .b
                addq.w    #2,a6                   ; stereo
              endr

                cmp.l     pro_1len(pc),d0
                blt.s     .ok1
                sub.w     pro_1rpt(pc),d0

.ok1:           move.w    d0,pro_1pos
                move.w    d1,pro_1frc

                cmp.l     pro_4len(pc),d4
                blt.s     .ok4
                sub.w     pro_4rpt(pc),d4

.ok4:           move.w    d4,pro_4pos
                move.w    d5,pro_4frc

                rts
**********************************************************************
* --------------------------------------------------------------- data
count:        dc.w PARTS

pro_1lc:      dc.l sample1
pro_1len:     dc.l 0
pro_1rpt:     dc.w 0
pro_1pos:     dc.w 0
pro_1frc:     dc.w 0

pro_2lc:      dc.l sample1
pro_2len:     dc.l 0
pro_2rpt:     dc.w 0
pro_2pos:     dc.w 0
pro_2frc:     dc.w 0

pro_3lc:      dc.l sample1
pro_3len:     dc.l 0
pro_3rpt:     dc.w 0
pro_3pos:     dc.w 0
pro_3frc:     dc.w 0

pro_4lc:      dc.l sample1
pro_4len:     dc.l 0
pro_4rpt:     dc.w 0
pro_4pos:     dc.w 0
pro_4frc:     dc.w 0

aud_1lc:      dc.l dummy
aud_1len:     dc.w 0
aud_1per:     dc.w 0
aud_1vol:     dc.w 0
              ds.w 3

aud_2lc:      dc.l dummy
aud_2len:     dc.w 0
aud_2per:     dc.w 0
aud_2vol:     dc.w 0
              ds.w 3

aud_3lc:      dc.l dummy
aud_3len:     dc.w 0
aud_3per:     dc.w 0
aud_3vol:     dc.w 0
              ds.w 3

aud_4lc:      dc.l dummy
aud_4len:     dc.w 0
aud_4per:     dc.w 0
aud_4vol:     dc.w 0

dmactrl:      dc.w 0
dummy:        dc.l 0

samp1:        dc.l sample1
samp2:        dc.l sample2

sample1:      ds.w LEN                        ; sample buffer 1 (500*2 bytes)
sample2:      ds.w LEN                        ; sample buffer 2

**********************************************************************

noise_prepare:  lea       workspc,a6
                movea.l   samplestarts(pc),a0
                movea.l   end_of_samples(pc),a1

tostack:        move.w    -(a1),-(a6)
                cmpa.l    a0,a1                   ; Move all samples to stack
                bgt.s     tostack

                lea       samplestarts(pc),a2
                lea       module(pc),a1           ; Module
                movea.l   (a2),a0                 ; Start of samples
                movea.l   a0,a5                   ; Save samplestart in a5

                moveq     #30,d7

roop:           move.l    a0,(a2)+                ; Sampleposition

                tst.w     $2a(a1)
                beq.s     sample_ok               ; Len=0 -> no sample

                tst.w     $2e(a1)                 ; Test repstrt
                bne.s     repne                   ; Jump if not zero


repeq:          move.w    $2a(a1),d0              ; Length of sample
                move.w    d0,d4
                subq.w    #1,d0

                movea.l   a0,a4
fromstk:        move.w    (a6)+,(a0)+             ; Move all samples back from stack
                dbra      d0,fromstk
                bra.s     rep


repne:          move.w    $2e(a1),d0
                move.w    d0,d4
                subq.w    #1,d0

                movea.l   a6,a4
get1st:         move.w    (a4)+,(a0)+             ; Fetch first part
                dbra      d0,get1st

                adda.w    $2a(a1),a6              ; Move a6 to next sample
                adda.w    $2a(a1),a6



rep:            movea.l   a0,a5
                moveq     #0,d1
toosmal:        movea.l   a4,a3
                move.w    $30(a1),d0
                subq.w    #1,d0
moverep:        move.w    (a3)+,(a0)+             ; Repeatsample
                addq.w    #2,d1
                dbra      d0,moverep
                cmp.w     #320*2,d1               ; (Must be > 320) (arghh!)
                blt.s     toosmal

                move.w    #320*2/2-1,d2
move_lp:        move.w    (a5)+,(a0)+             ; (Safety 320 bytes)
                dbra      d2,move_lp

done:           add.w     d4,d4

                move.w    d4,$2a(a1)              ; length
                move.w    d1,$30(a1)              ; Replen
                clr.w     $2e(a1)

sample_ok:      lea       $1e(a1),a1
                dbra      d7,roop

                cmpa.l    #workspc,a0
                bgt.s     .nospace
                rts


.nospace:       illegal

end_of_samples:dc.l 0

* ------------------------------------------------------ Main replayrout
noise_init:     lea       module(pc),a0
                lea       $03b8(a0),a1

                moveq     #$7f,d0
                moveq     #0,d1
loop:           move.l    d1,d2
                subq.w    #1,d0
lop2:           move.b    (a1)+,d1
                cmp.b     d2,d1
                bgt.s     loop
                dbra      d0,lop2
                addq.b    #1,d2

                lea       samplestarts(pc),a1
                asl.l     #8,d2
                asl.l     #2,d2
                add.l     #$043c,d2
                add.l     a0,d2
                movea.l   d2,a2

                moveq     #$1e,d0
lop3:           clr.l     (a2)
                move.l    a2,(a1)+
                moveq     #0,d1
                move.w    42(a0),d1
                add.l     d1,d1
                adda.l    d1,a2
                adda.l    #$1e,a0
                dbra      d0,lop3

                move.l    a2,end_of_samples
                rts
* --------------------------------------------------------------------
music:          lea       module(pc),a0           ; <---- music subrout
                addq.w    #$01,pro_counter
                move.w    pro_counter(pc),d0
                cmp.w     speed(pc),d0
                blt.s     nonew
                clr.w     pro_counter
                bra       getnew

nonew:          lea       voice1(pc),a4
                lea       aud_1lc(pc),a3
                bsr       checkcom
                lea       voice2(pc),a4
                lea       aud_2lc(pc),a3
                bsr       checkcom
                lea       voice3(pc),a4
                lea       aud_3lc(pc),a3
                bsr       checkcom
                lea       voice4(pc),a4
                lea       aud_4lc(pc),a3
                bsr       checkcom
                bra       endr

arpeggio:
                moveq     #0,d0
                move.w    pro_counter(pc),d0
                divs      #$03,d0
                swap      d0
                tst.w     d0
                beq.s     arp2
                cmp.w     #$02,d0
                beq.s     arp1

                moveq     #0,d0
                move.b    $03(a4),d0
                lsr.b     #4,d0
                bra.s     arp3

arp1:           moveq     #0,d0
                move.b    $03(a4),d0
                and.b     #$0f,d0
                bra.s     arp3

arp2:           move.w    $10(a4),d2
                bra.s     arp4

arp3:           add.w     d0,d0
                moveq     #0,d1
                move.w    $10(a4),d1
                lea       periods(pc),a0
                moveq     #$24,d4
arploop:        move.w    0(a0,d0.w),d2
                cmp.w     (a0),d1
                bge.s     arp4
                addq.l    #2,a0
                dbra      d4,arploop
                rts

arp4:           move.w    d2,$06(a3)
                rts

getnew:         lea       module+$043c(pc),a0
                lea       -$043c+$0c(a0),a2
                lea       -$043c+$03b8(a0),a1

                moveq     #0,d0
                move.l    d0,d1
                move.b    songpos(pc),d0
                move.b    0(a1,d0.w),d1
                asl.l     #8,d1
                asl.l     #2,d1
                add.w     pattpos(pc),d1
                clr.w     dmacon

                lea       aud_1lc(pc),a3
                lea       voice1(pc),a4
                bsr.s     playvoice
                lea       aud_2lc(pc),a3
                lea       voice2(pc),a4
                bsr.s     playvoice
                lea       aud_3lc(pc),a3
                lea       voice3(pc),a4
                bsr.s     playvoice
                lea       aud_4lc(pc),a3
                lea       voice4(pc),a4
                bsr.s     playvoice
                bra       setdma


playvoice:
                move.l    0(a0,d1.l),(a4)
                addq.l    #4,d1
                moveq     #0,d2
                move.b    $02(a4),d2
                and.b     #$f0,d2
                lsr.b     #4,d2
                move.b    (a4),d0
                and.b     #$f0,d0
                or.b      d0,d2
                tst.b     d2
                beq.s     setregs
                moveq     #0,d3
                lea       samplestarts(pc),a1
                move.l    d2,d4
                subq.l    #$01,d2
                asl.l     #2,d2
                mulu      #$1e,d4
                move.l    0(a1,d2.l),$04(a4)
                move.w    0(a2,d4.l),$08(a4)
                move.w    $02(a2,d4.l),$12(a4)
                move.w    $04(a2,d4.l),d3
                tst.w     d3
                beq.s     noloop
                move.l    $04(a4),d2
                add.w     d3,d3
                add.l     d3,d2
                move.l    d2,$0a(a4)
                move.w    $04(a2,d4.l),d0
                add.w     $06(a2,d4.l),d0
                move.w    d0,8(a4)
                move.w    $06(a2,d4.l),$0e(a4)
                move.w    $12(a4),$08(a3)
                bra.s     setregs

noloop:         move.l    $04(a4),d2
                add.l     d3,d2
                move.l    d2,$0a(a4)
                move.w    $06(a2,d4.l),$0e(a4)
                move.w    $12(a4),$08(a3)
setregs:        move.w    (a4),d0
                and.w     #$0fff,d0
                beq       checkcom2
                move.b    $02(a4),d0
                and.b     #$0f,d0
                cmp.b     #$03,d0
                bne.s     setperiod
                bsr       setmyport
                bra       checkcom2

setperiod:
                move.w    (a4),$10(a4)
                andi.w    #$0fff,$10(a4)
                move.w    $14(a4),d0
                move.w    d0,dmactrl
                clr.b     $1b(a4)

                move.l    $04(a4),(a3)
                move.w    $08(a4),$04(a3)
                move.w    $10(a4),d0
                and.w     #$0fff,d0
                move.w    d0,$06(a3)
                move.w    $14(a4),d0
                or.w      d0,dmacon
                bra       checkcom2

setdma:         move.w    dmacon(pc),d0

                btst      #0,d0
                beq.s     pro_nch1
                move.l    aud_1lc(pc),pro_1lc
                moveq     #0,d1
                moveq     #0,d2
                move.w    aud_1len(pc),d1
                move.w    voice1+$0e(pc),d2
                add.l     d2,d1
                move.l    d1,pro_1len
                move.w    d2,pro_1rpt
                clr.w     pro_1pos

pro_nch1:       btst      #1,d0
                beq.s     pro_nch2
                move.l    aud_2lc(pc),pro_2lc
                moveq     #0,d1
                moveq     #0,d2
                move.w    aud_2len(pc),d1
                move.w    voice2+$0e(pc),d2
                add.l     d2,d1
                move.l    d1,pro_2len
                move.w    d2,pro_2rpt
                clr.w     pro_2pos

pro_nch2:       btst      #2,d0
                beq.s     pro_nch3
                move.l    aud_3lc(pc),pro_3lc
                moveq     #0,d1
                moveq     #0,d2
                move.w    aud_3len(pc),d1
                move.w    voice3+$0e(pc),d2
                add.l     d2,d1
                move.l    d1,pro_3len
                move.w    d2,pro_3rpt
                clr.w     pro_3pos

pro_nch3:       btst      #3,d0
                beq.s     pro_nch4
                move.l    aud_4lc(pc),pro_4lc
                moveq     #0,d1
                moveq     #0,d2
                move.w    aud_4len(pc),d1
                move.w    voice4+$0e(pc),d2
                add.l     d2,d1
                move.l    d1,pro_4len
                move.w    d2,pro_4rpt
                clr.w     pro_4pos

pro_nch4:       addi.w    #$10,pattpos
                cmpi.w    #$0400,pattpos
                bne.s     endr
nex:            clr.w     pattpos
                clr.b     break
                addq.b    #1,songpos
                andi.b    #$7f,songpos
                move.b    songpos(pc),d1
                cmp.b     module+$03b6(pc),d1
                bne.s     endr
                move.b    module+$03b7(pc),songpos
endr:           tst.b     break
                bne.s     nex
                rts

setmyport:
                move.w    (a4),d2
                and.w     #$0fff,d2
                move.w    d2,$18(a4)
                move.w    $10(a4),d0
                clr.b     $16(a4)
                cmp.w     d0,d2
                beq.s     clrport
                bge.s     rt
                move.b    #$01,$16(a4)
                rts

clrport:        clr.w     $18(a4)
rt:             rts

myport:         move.b    $03(a4),d0
                beq.s     myslide
                move.b    d0,$17(a4)
                clr.b     $03(a4)
myslide:        tst.w     $18(a4)
                beq.s     rt
                moveq     #0,d0
                move.b    $17(a4),d0
                tst.b     $16(a4)
                bne.s     mysub
                add.w     d0,$10(a4)
                move.w    $18(a4),d0
                cmp.w     $10(a4),d0
                bgt.s     myok
                move.w    $18(a4),$10(a4)
                clr.w     $18(a4)

myok:           move.w    $10(a4),$06(a3)
                rts

mysub:          sub.w     d0,$10(a4)
                move.w    $18(a4),d0
                cmp.w     $10(a4),d0
                blt.s     myok
                move.w    $18(a4),$10(a4)
                clr.w     $18(a4)
                move.w    $10(a4),$06(a3)
                rts

vib:            move.b    $03(a4),d0
                beq.s     vi
                move.b    d0,$1a(a4)

vi:             move.b    $1b(a4),d0
                lea       sin(pc),a1
                lsr.w     #$02,d0
                and.w     #$1f,d0
                moveq     #0,d2
                move.b    0(a1,d0.w),d2
                move.b    $1a(a4),d0
                and.w     #$0f,d0
                mulu      d0,d2
                lsr.w     #$06,d2
                move.w    $10(a4),d0
                tst.b     $1b(a4)
                bmi.s     vibmin
                add.w     d2,d0
                bra.s     vib2

vibmin:         sub.w     d2,d0
vib2:           move.w    d0,$06(a3)
                move.b    $1a(a4),d0
                lsr.w     #$02,d0
                and.w     #$3c,d0
                add.b     d0,$1b(a4)
                rts

nop:            move.w    $10(a4),$06(a3)
                rts

checkcom:
                move.w    $02(a4),d0
                and.w     #$0fff,d0
                beq.s     nop
                move.b    $02(a4),d0
                and.b     #$0f,d0
                tst.b     d0
                beq       arpeggio
                cmp.b     #$01,d0
                beq.s     portup
                cmp.b     #$02,d0
                beq       portdown
                cmp.b     #$03,d0
                beq       myport
                cmp.b     #$04,d0
                beq       vib
                cmp.b     #$05,d0
                beq       port_toneslide
                cmp.b     #$06,d0
                beq       vib_toneslide
                move.w    $10(a4),$06(a3)
                cmp.b     #$0a,d0
                beq.s     volslide
                rts

volslide:
                moveq     #0,d0
                move.b    $03(a4),d0
                lsr.b     #4,d0
                tst.b     d0
                beq.s     voldown
                add.w     d0,$12(a4)
                cmpi.w    #$40,$12(a4)
                bmi.s     vol2
                move.w    #$40,$12(a4)
vol2:           move.w    $12(a4),$08(a3)
                rts

voldown:        moveq     #0,d0
                move.b    $03(a4),d0
                and.b     #$0f,d0
                sub.w     d0,$12(a4)

                bpl.s     vol3
                clr.w     $12(a4)
vol3:           move.w    $12(a4),$08(a3)
                rts

portup:         moveq     #0,d0
                move.b    $03(a4),d0
                sub.w     d0,$10(a4)
                move.w    $10(a4),d0
                and.w     #$0fff,d0
                cmp.w     #$71,d0
                bpl.s     por2
                andi.w    #$f000,$10(a4)
                ori.w     #$71,$10(a4)
por2:           move.w    $10(a4),d0
                and.w     #$0fff,d0
                move.w    d0,$06(a3)
                rts

port_toneslide:
                bsr       myslide
                bra.s     volslide

vib_toneslide:
                bsr       vi
                bra.s     volslide

portdown:
                clr.w     d0
                move.b    $03(a4),d0
                add.w     d0,$10(a4)
                move.w    $10(a4),d0
                and.w     #$0fff,d0
                cmp.w     #$0358,d0
                bmi.s     por3
                andi.w    #$f000,$10(a4)
                ori.w     #$0358,$10(a4)
por3:           move.w    $10(a4),d0
                and.w     #$0fff,d0
                move.w    d0,$06(a3)
                rts

checkcom2:
                move.b    $02(a4),d0
                and.b     #$0f,d0
                cmp.b     #$0d,d0
                beq.s     pattbreak
                cmp.b     #$0b,d0
                beq.s     posjmp
                cmp.b     #$0c,d0
                beq.s     setvol
                cmp.b     #$0f,d0
                beq.s     setspeed
                rts

pattbreak:
                st        break
                rts

posjmp:         move.b    $03(a4),d0
                subq.b    #$01,d0
                move.b    d0,songpos
                st        break
                rts

setvol:         moveq     #0,d0
                move.b    $03(a4),d0
                cmp.w     #$40,d0
                ble.s     vol4
                move.b    #$40,$03(a4)
vol4:           move.b    $03(a4),$09(a3)
                move.b    $03(a4),$13(a4)
                rts

setspeed:
                cmpi.b    #$1f,$03(a4)
                ble.s     sets
                move.b    #$1f,$03(a4)
sets:           move.b    $03(a4),d0
                beq.s     rts2
                move.w    d0,speed
                clr.w     pro_counter
rts2:           rts

sin:          dc.b $00,$18,$31,$4a,$61,$78,$8d,$a1,$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
              dc.b $ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5,$b4,$a1,$8d,$78,$61,$4a,$31,$18

periods:      dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c,$023a,$021a,$01fc,$01e0
              dc.w $01c5,$01ac,$0194,$017d,$0168,$0153,$0140,$012e,$011d,$010d,$fe
              dc.w $f0,$e2,$d6,$ca,$be,$b4,$aa,$a0,$97,$8f,$87
              dc.w $7f,$78,$71,$00,$00

speed:        dc.w $06
pro_counter:  dc.w $00
songpos:      dc.b $00
break:        dc.b $00
pattpos:      dc.w $00

dmacon:       dc.w $00
samplestarts: ds.l $1f

voice1:       ds.w 10
              dc.w $01
              ds.w 3
voice2:       ds.w 10
              dc.w $02
              ds.w 3
voice3:       ds.w 10
              dc.w $04
              ds.w 3
voice4:       ds.w 10
              dc.w $08
              ds.w 3

* --------------------------------------------------------------------
**********************************************************************
module:       ibytes 'A:\G*.MOD'

              ds.b 16384+320+5000             ; Workspace
workspc:      ds.w 1

              even
**********************************************************************
**********************************************************************

cool_text:
                addq.w    #1,pause
                bpl.s     yah
                rts
yah:
                tst.b     clr_text_flg
                beq.s     no_text_clr
                lea       text_screen+6,a0
                adda.w    clr_text_poi(pc),a0
                addi.w    #8*5,clr_text_poi

                moveq     #0,d0
                move.w    d0,(a0)
              rept 4
                addq.w    #8,a0
                move.w    d0,(a0)
              endr

                cmpi.w    #160*40,clr_text_poi
                bhi.s     yez_ready_p3
                rts
yez_ready_p3:   sf        clr_text_flg
                move.w    #0,clr_text_poi
                rts
* --------------------------------------------------------------------

no_text_clr:
                tst.b     erase_flg
                bne       erase_sub

                lea       text_list(pc),a0
                adda.w    text_list_poi(pc),a0
                cmpi.b    #-1,(a0)
                bne.s     chk_it
                move.b    #$80,disp_flg
                rts
;                move.w    #0,text_list_poi
;                move.w    #0,x_orient
;                move.w    #0,y_orient
;                bra       cool_text

chk_it:         addq.w    #1,text_list_poi
go_on_sub:      move.b    (a0),d0

                cmp.b     #1,d0
                bne.s     checking2
                move.w    #0,x_orient
                move.w    #0,y_orient
                rts
checking2:
                cmp.b     #2,d0
                bne.s     checking3
                move.w    #0,x_orient
                addq.w    #1,y_orient
                rts
checking3:
                cmp.b     #3,d0
                bne.s     checking4
                st        clr_text_flg
                move.w    #0,x_orient
                move.w    #0,y_orient
                rts
checking4:
                cmp.b     #4,d0
                bne.s     checking5
                move.w    #-50*2,pause
                rts

checking5:
                cmp.b     #5,d0
                bne.s     print_it
                st        erase_flg
                move.w    #0,x_orient
                move.w    #0,y_orient
                rts


print_it:
                bsr.s     print_ASCII
                addq.w    #1,x_orient
                rts
**********************************************************************
erase_sub:
                lea       text_erase(pc),a0
                adda.w    text_erase_poi(pc),a0
                cmpi.b    #-1,(a0)
                bne.s     ja_ja
                sf        erase_flg
                move.w    #0,text_erase_poi
                move.w    #0,x_orient
                move.w    #0,y_orient
                rts

ja_ja:          addq.w    #1,text_erase_poi
                bra       go_on_sub

**********************************************************************
print_ASCII:    and.w     #$ff,d0
                sub.b     #32,d0                  ; sub space
                add.w     d0,d0
                lea       char_offs,a0
                move.w    0(a0,d0.w),d0

                lea       font+34+(160*9*5),a0
                adda.w    d0,a0                   ; add offset to font
* --------------------------------------------------------------------

                lea       text_screen+6,a1
                move.w    y_orient(pc),d0
                mulu      #160*10,d0
                adda.w    d0,a1                   ; add y

                move.w    x_orient(pc),d0
                btst      #0,d0
                bne.s     out2_p3

* --------------------------------------------------------------------
out1_p3:
                lsl.w     #2,d0                   ; * 4 (think... word!!)
                adda.w    d0,a1                   ; add x

              rept 7
                move.w    (a0),(a1)
                lea       160(a0),a0
                lea       160(a1),a1
              endr
                move.w    (a0),(a1)
                rts

out2_p3:
                and.b     #$fe,d0
                lsl.w     #2,d0                   ; * 4 (think...word!)
                adda.w    d0,a1                   ; add x

              rept 7
                move.w    (a0),d0
                and.w     #$ff00,d0
                lsr.w     #8,d0
                or.w      d0,(a1)
                lea       160(a0),a0
                lea       160(a1),a1
              endr
                move.w    (a0),d0
                and.w     #$ff00,d0
                lsr.w     #8,d0
                or.w      d0,(a1)
                rts

* --------------------------------------------------------------------
clr_text_flg: dc.b 0
              even
clr_text_poi: dc.w 0

x_orient:     dc.w 0
y_orient:     dc.w 0
              even

;char_offs:

;* 9 lines
;              dc.w 0,8,16,24,32,40,48,56,64,72,80,88,96,104,112,120,128,136,144,152
;              dc.w $05a0,$05a0+8,$05a0+16,$05a0+24,$05a0+32,$05a0+40,$05a0+48,$05a0+56,$05a0+64
;              dc.w $05a0+72,$05a0+80,$05a0+88,$05a0+96,$05a0+104,$05a0+112,$05a0+120,$05a0+128
;              dc.w $05a0+136,$05a0+144,$05a0+152
;              dc.w $0b40,$0b40+8,$0b40+16,$0b40+24,$0b40+32,$0b40+40,$0b40+48,$0b40+56,$0b40+64
;              dc.w $0b40+72,$0b40+80,$0b40+88,$0b40+96,$0b40+104,$0b40+112,$0b40+120,$0b40+128
;              dc.w $0b40+136,$0b40+144,$0b40+152
;              dc.w $10e0,$10e0+8,$10e0+16,$10e0+24,$10e0+32,$10e0+40,$10e0+48,$10e0+56,$10e0+64
;              dc.w $10e0+72,$10e0+80,$10e0+88,$10e0+96,$10e0+104,$10e0+112,$10e0+120,$10e0+128
;              dc.w $10e0+136,$10e0+144,$10e0+152
;              dc.w $1680,$1680+8,$1680+16,$1680+24,$1680+32,$1680+40,$1680+48,$1680+56,$1680+64
;              dc.w $1680+72,$1680+80,$1680+88,$1680+96,$1680+104,$1680+112,$1680+120,$1680+128
;              dc.w $1680+136,$1680+144,$1680+152


* 1= clr x,y    2= clr x, inc y   3= clr textarea    4= pause (2 sec)
pause:        dc.w 0

erase_flg:    dc.b 0
              even
text_erase_poi:dc.w 0
text_erase:
              dc.b "0101010101010101010101010101010101010101",2 ; MAX!
              dc.b "1010101010101010101010101010101010101010",2 ; MAX!
              dc.b "0101010101010101010101010101010101010101",1 ; MAX!
              dc.b "                                        ",2 ; MAX!
              dc.b "                                        ",2 ; MAX!
              dc.b "                                        ",-1 ; MAX!

              even

text_list_poi:dc.w 0
text_list:
              dc.b 4,4
              dc.b "      - Inner Circuit Explorers -       ",2,4
              dc.b "     We are the Eternal Wizcoders!!     ",4,4,4,4,1


              dc.b "         - Digital World 3 -            ",2
              dc.b "The Final Preparation for Judgement Day!",2,4,4,4
              dc.b " It's The End of the Fuckin' Trilogy... ",1,4,4,4,5


              dc.b "101...     Coding 4 Pleasure!     ...101",2,4
              dc.b "No Mental Efforts required...           ",2,4
              dc.b "Just use a nice random-generator...     ",1,4,4,4,3

              dc.b "1 2 3 - Techno -     Gosh!  Va' tufft!  ",2,4,4
              dc.b "Burned circuits smells like heaven...   ",2,4
              dc.b "Check it out yourself...                ",1,4,4,4,3

              dc.b "High level processing in progress...    ",2
              dc.b "                                        ",2
              dc.b "Please stand by...                      ",4,4,3


              dc.b "Hi!  I'm your personal computer!        ",2,2,4
              dc.b "You can call me HAL9000...              ",4,5,4,4

              dc.b "Something wonderful is on the way...    ",2,4,4
              dc.b "Ahh... I just love it...                ",2,4,4
              dc.b "I once even dipped the mouse in it...   ",4,3


              dc.b "What 'da like my lame 3D shit?          ",2,4
              dc.b "I just had to do some vector to show a  ",2
              dc.b "few pals (Hi Cod!) how real 3D will act!",1,4,4,3

              dc.b "I know it's possible to have much bigger",2
              dc.b "objects in one vbl but this nice trackz-",2
              dc.b "routine takes quite a lot shitty-time!  ",4,4,3

              dc.b "But maybe next time it's solid too...   ",2,4
              dc.b "Opps... What's that thing going round,  ",2
              dc.b "round, Smurffe Surf and Turtle Spet??   ",4,4,4,4,4,3

              dc.b 4,4,4,4,4,4,4,4,4,4
              dc.b "The incredibly -Zoomer- in this demo is ",2
              dc.b "working with a quite fast technique:    ",2,4
              dc.b "   - The famous shift instructions! -   ",1,4,3

              dc.b 4,4,4,4,4,4

              dc.b "Hi again Codfish-en... Keep on fishing! ",2
              dc.b "You will maybe get something sometime!  ",4,4,3

              dc.b 4,4,4,4,4,4,4,4
              dc.b "     Credits for whole production:      ",4,4,3
              dc.b "Design & Coding by Techwave...          ",2,4
              dc.b "Nice intro bitmapped GFX by Cutter...   ",2,4
              dc.b "Great Technogoing muzak by Turtle (Yo!).",1,4,4,3,4

              dc.b "You can buy the sourcetext of this demo!",2,4
              dc.b "I will send it on a disk, together with ",2
              dc.b "info & comments, for about 70:- SEK!!   ",4,4,3

              dc.b "Ya' can contact me for almost any reason",2
              dc.b "(buy src, give donations, swap demos...)",2
              dc.b "on this soon coming address:            ",2,4,4,3

              dc.b "    Tobias Nilsson (Techwave of ICE)       ",2
              dc.b "    Konvalescentv. 39                   ",2
              dc.b "    439 33  Onsala... Sweden            ",4,4,4,4,5


              dc.b 4,4,4,4,4,4,4,4,4,4,4,4
              dc.b "SPREAD LOVE, NOT WAR!                   ",2,4
              dc.b "That's sweet... isn't it?               ",2,4,4,3


              dc.b 4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4
              dc.b "The end is near...                      ",2,4
              dc.b "Take care & enjoy...                    ",2,4
              dc.b "There's only some nice greetings left...",4,4,4,5


              dc.b 4,4,4,4,4,4,4,4,4,4,4,4,4,4,4

              dc.b -1
              dc.b "                                        ",1 ; MAX!
              even



**********************************************************************
**********************************************************************
* --------------------------------------------------------------- restore
oldvbl_p3:    dc.l 0
oldhbl_p3:    dc.l 0
oldmfp07_p3:  dc.b 0
oldmfp09_p3:  dc.b 0
oldmfp13_p3:  dc.b 0
              even

back_p3:
                move      #$2700,sr
                move.l    oldvbl_p3(pc),$70.w
                move.l    oldhbl_p3(pc),$0120.w
                move.b    oldmfp07_p3(pc),$fffffa07.w
                move.b    oldmfp09_p3(pc),$fffffa09.w
                move.b    oldmfp13_p3(pc),$fffffa13.w

                rts                               ; !!! back !!!

;                move      #$2300,sr
;                clr.l     -(sp)
;                move.w    #$20,-(sp)
;                trap      #1
;                addq.l    #6,sp

;                move.w    #1,-(sp)
;                move.l    #-1,-(sp)
;                move.l    #-1,-(sp)
;                move.w    #5,-(sp)
;                trap      #14
;                lea       12(sp),sp

;                clr.w     -(sp)
;                trap      #1

**********************************************************************

;font:         ibytes 'B:\C88.PI1'             ; 8*8 font, word-oriented
text_screen:  ds.b 160*50
text_screen_addr:dc.l text_screen

;screen:       ds.w (32000/2+(160*45/2))*2
              end
