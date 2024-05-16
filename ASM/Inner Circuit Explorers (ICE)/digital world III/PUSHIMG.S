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
                move      #$2300,sr

**********************************************************************
* Intro!!!!!!!!!   Digital World 3... by ICE                         *
**********************************************************************
* Pushimg v0.1   By TEchwave                                         *
**********************************************************************

start_part_1:

                move.w    #0,$0468.w
vsync:          cmpi.w    #0,$0468.w
                beq.s     vsync

                lea       $ffff8240.w,a0
                moveq     #0,d0
              rept 8
                move.l    d0,(a0)+
              endr

                bsr       fade_make

;                lea       pic+2(pc),a0
;                lea       $ffff8240.w,a1
;              rept 8
;                move.l    (a0)+,(a1)+
;              endr

i_init_part_1:
                move.l    $70.w,oldvbl
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
                tst.b     dec_flg
                bne.s     dec_now

                cmpi.w    #200-2,cut_cnt
                bge.s     now_top
                addq.w    #2,cut_cnt
                bra.s     ready_cnt
now_top:
                addq.w    #1,wait_ice
                bmi.s     ready_cnt
                move.w    #-200,wait_ice
                st        dec_flg
                st        fade_down_flg
                move.w    #-50,wait_fade
                bra.s     ready_cnt

* --------------------------------------------------------------------

dec_now:
                cmpi.w    #13-1,cut_cnt
                ble.s     now_down
                subq.w    #2,cut_cnt
                bra.s     ready_cnt
now_down:       sf        dec_flg
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
dec_flg:      dc.b 0


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
                bra.s     go

st_yline_flg:                                     ; don't exits!
                subq.w    #1,d3

                move.w    d1,d5
                sub.w     d3,d5                   ; y1-y2 > y (second)

* --------------------------------------------------------------------
* d6 is holy (sacred)!
go:
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
oldvbl:       dc.l 0
oldhbl:       dc.l 0
oldmfp07:     dc.b 0
oldmfp09:     dc.b 0
oldmfp13:     dc.b 0
              even

back_part_1:
                move      #$2700,sr
                move.l    oldvbl(pc),$70.w
                move.l    oldhbl(pc),$0120.w
                move.b    oldmfp07(pc),$fffffa07.w
                move.b    oldmfp09(pc),$fffffa09.w
                move.b    oldmfp13(pc),$fffffa13.w

                move      #$2300,sr

                sf        pic_flg
                sf        prepare_exit_flg

                jmp       start_part_1

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

**********************************************************************
              even
pic2:         ibytes 'DEMON.PI1'
pic:          ibytes 'BLODLOGO.PI1'
end_img:
nothing:      ds.w 16000

**********************************************************************
**********************************************************************
**********************************************************************
**********************************************************************
**********************************************************************
**********************************************************************
