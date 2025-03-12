******************************************************************************
* The Kryos demo by Techwave of Inner Circuit Explorers.                     *
* After #x fucking crashes 'dis is version 1.0!                              *
*                                                                            *
******************************************************************************
******************************************************************************
* STE Fullscreen-tracker (v1.0) by Techwave.                                 *
******************************************************************************
* Noisetracker replay using no fucking timer!   (v1.0)                       *
* Code by M.K. Extended by Wizzcat. Modified (for vbl) & speeded by Techwave.*
******************************************************************************
* 4 channels, 25 KHz stereo sound in nice FULLscreen.                        *
******************************************************************************

* 0=6.259, 1=12.517, 2=25.036

FREQUENCY     equ 2
LEN           equ 250*2
INC           equ $011df98a/2

MVOL          equ $80
PARTS         equ 1

* --------------------------------------------------------------------

                clr.l     -(sp)
                move.w    #$20,-(sp)
                trap      #1
                addq.w    #6,sp

                move.w    #37,-(sp)
                trap      #14
                addq.l    #2,sp

                lea       $ffff8240.w,a0
                moveq     #0,d0
                moveq     #16-1,d7
black:          move.w    d0,(a0)+
                dbra      d7,black


                move.b    #$02,$0484.w

low:            move.w    #0,-(sp)
                move.l    #-1,-(sp)
                move.l    #-1,-(sp)
                move.w    #5,-(sp)
                trap      #14
                lea       12(sp),sp

fix_ind_img:
                movea.l   screen1,a0
                adda.w    #4+8,a0
                lea       ind_pic+34,a1
                lea       ind_pic+34+(160*14),a2


                moveq     #14-1,d7
img_lp:
              rept 12
                move.w    (a1)+,(a0)+
                move.w    (a1)+,(a0)+
                move.w    (a1)+,(a0)+
                move.w    (a1)+,(a0)+
              endr

              rept 12
                move.w    (a2)+,(a0)+
                move.w    (a2)+,(a0)+
                move.w    (a2)+,(a0)+
                move.w    (a2)+,(a0)+
              endr

                lea       230-(8*24)(a0),a0
                lea       160-(8*12)(a1),a1
                lea       160-(8*12)(a2),a2
                dbra      d7,img_lp

                bra       no_st

                movea.l   screen1,a0
                adda.w    #4+8+(14*230),a0
                movea.l   a0,a1
                adda.w    #8*6,a1
                movea.l   a1,a2
                adda.w    #8*6,a2
                movea.l   a2,a3
                adda.w    #8*6,a3

                move.w    #$3f,d0
                move.w    #$ffff,d1
                move.w    #$e000,d2

* make stapel 1
              rept 211-2
                move.w    d0,(a0)
                move.w    d1,8(a0)
                move.w    d1,16(a0)
                move.w    d1,24(a0)
                move.w    d1,32(a0)
                move.w    d2,40(a0)
                lea       230(a0),a0
              endr

* make stapel 2
              rept 211-2
                move.w    d0,2(a1)
                move.w    d1,8+2(a1)
                move.w    d1,16+2(a1)
                move.w    d1,24+2(a1)
                move.w    d1,32+2(a1)
                move.w    d2,40+2(a1)
                lea       230(a1),a1
              endr

* make stapel 3
              rept 211-2
                move.w    d0,(a2)
                move.w    d0,2(a2)
                move.w    d1,8(a2)
                move.w    d1,8+2(a2)
                move.w    d1,16(a2)
                move.w    d1,16+2(a2)
                move.w    d1,24(a2)
                move.w    d1,24+2(a2)
                move.w    d1,32(a2)
                move.w    d1,32+2(a2)
                move.w    d2,40(a2)
                move.w    d2,40+2(a2)
                lea       230(a2),a2
              endr

* make stapel 4
              rept 211-2
                move.w    d0,4(a3)
                move.w    d1,8+4(a3)
                move.w    d1,16+4(a3)
                move.w    d1,24+4(a3)
                move.w    d1,32+4(a3)
                move.w    d2,40+4(a3)
                lea       230(a3),a3
              endr


no_st:
                move.l    txt_scroll,d0
                and.b     #$00,d0
                add.l     #$0100,d0
                move.l    d0,txt_scroll

;                bra.s     i_init

                cmpi.l    #"M.K.",data+$0438
                beq.s     yez_right

                move.w    #$0700,$ffff8240.w

                move.w    #7,-(sp)
                trap      #1
                addq.w    #2,sp

                clr.w     -(sp)
                trap      #1                      ; Terminate
**********************************************************************
yez_right:
                jsr       noise_vol               ; Calculate volume tables
                jsr       noise_incrcal           ; Calculate tonetables

                jsr       noise_init              ; Initialize music
                jsr       noise_prepare           ; Prepare samples


                move.b    #FREQUENCY,$ffff8921.w
                jsr       set_mw
                jsr       noise_rout
* --------------------------------------------------------------------
* --------------------------------------------------------------------
                bsr       fade_make

;---------------------------------------------

i_init:
                move.b    #0,$fffffa09.w          ; timer fuck
;                move.l    $70.w,oldvbl
                move.l    #vbl_pic,$70.w

* fade_out
                lea       fading+14*2(pc),a0

                moveq     #15-1,d6
v_sync:         tst.b     vbl_flg
                beq.s     v_sync
                sf        vbl_flg
v_sync2:        tst.b     vbl_flg
                beq.s     v_sync2
                sf        vbl_flg
v_sync3:        tst.b     vbl_flg
                beq.s     v_sync3

                lea       $ffff8240.w,a1
                moveq     #16-1,d7
f_out:          move.w    (a0),(a1)+
                adda.w    #15*2,a0
                dbra      d7,f_out

                suba.w    #15*2*16+2,a0
                sf        vbl_flg
                dbra      d6,v_sync

* --------------------------------------------------------------------
                move.w    #-(50*5),d0
loop_it:        tst.b     vbl_flg
                beq.s     loop_it
                sf        vbl_flg
                addq.w    #1,d0
                bne.s     loop_it

* --------------------------------------------------------------------
                lea       fading(pc),a0

                moveq     #15-1,d6
v_sync_2:       tst.b     vbl_flg
                beq.s     v_sync_2
                sf        vbl_flg
v_sync2_2:      tst.b     vbl_flg
                beq.s     v_sync2_2
                sf        vbl_flg
v_sync3_2:      tst.b     vbl_flg
                beq.s     v_sync3_2

                lea       $ffff8240.w,a1
                moveq     #16-1,d7
f_out_2:        move.w    (a0),(a1)+
                adda.w    #15*2,a0
                dbra      d7,f_out_2

                suba.w    #15*2*16-2,a0
                sf        vbl_flg
                dbra      d6,v_sync_2

                jmp       go_yeah

* --------------------------------------------------------------------
* --------------------------------------------------------------------


vbl_pic:        move.l    d0,-(sp)
                st        vbl_flg

                move.l    #intro_pic+34,d0
                move.b    d0,$ffff8209.w
                lsr.w     #8,d0
                move.b    d0,$ffff8207.w
                swap      d0
                move.b    d0,$ffff8205.w

                move.l    (sp)+,d0
                rte

vbl_flg:      dc.b 0
              even
fading:       ds.w 16*16

* --------------------------------------------------------------------
* --------------------------------------------------------------------
fade_make:      lea       intro_pic+2(pc),a0
                lea       fading(pc),a3

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

                adda.w    #15*2,a3
                dbra      d7,fade_pal
                rts
; --------------
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
; --------------
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
; --------------
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

* --------------------------------------------------------------------
fade:         dc.w $0f,$07,$0e,$06,$0d,$05,$0c,$04,$0b,$03,$0a,$02,$09,$01,$08,$00

;dc.w            $0,$8,$1,$9,$2,$a,$3,$b,$4,$c,$5,$d,$6,$e,$7,$f


intro_pic:    ibytes 'ICE.PI1'
              even


go_yeah:
;                move.l    $70.w,oldvbl


                move.l    #vbl,$70.w


;key:
;                cmpi.b    #185,$fffffc02.w
;                bne.s     key

noend:          bra.s     noend

back:           move.l    oldvbl,$70.w
                move.w    #1,-(sp)
                move.l    #-1,-(sp)
                move.l    #-1,-(sp)
                move.w    #5,-(sp)
                trap      #14
                lea       12(sp),sp

                clr.w     -(sp)                   ; Terminate
                trap      #1

oldvbl:       dc.l 0


**********************************************************************
**********************************************************************
**********************************************************************
vbl:
                movem.l   d0-a6,-(sp)

                bsr       rast_tab_make           ; 18

                bsr       equ_cols_out

              rept 1+15
                nop
              endr


                bclr      #1,$ffff820a.w

              rept 12
                nop
              endr

                bset      #1,$ffff820a.w

                move.w    #$00,$ffff8240.w
                move.w    #$0112,$ffff8242.w
                move.w    #$0223,$ffff8244.w
                move.w    #$0334,$ffff8246.w


                bsr       fulltrack_rout

                jsr       noise_rout


                moveq     #0,d7
                move.b    voice1+2,d0
                cmp.w     d7,d0
                beq.s     no_new_fade
                bsr       fade_put
no_new_fade:
                move.b    voice2+2,d0
                cmp.w     d7,d0
                beq.s     no_new_fade2
                bsr       fade_put
no_new_fade2:
                move.b    voice3+2,d0
                cmp.w     d7,d0
                beq.s     no_new_fade3
                bsr       fade_put
no_new_fade3:
                move.b    voice4+2,d0
                cmp.w     d7,d0
                beq.s     no_new_fade4
                bsr       fade_put
no_new_fade4:


* --------------------------------------------------------------------
                lea       pile_1,a0
                lea       pile_2,a1
                lea       pile_3,a2
                lea       pile_4,a3
                move.w    #140*2,d0

tst_p1:         tst.w     (a0)
                beq.s     tst_p2
                subq.w    #8,(a0)

tst_p2:         tst.w     (a1)
                beq.s     tst_p3
                subq.w    #8,(a1)

tst_p3:         tst.w     (a2)
                beq.s     tst_p4
                subq.w    #8,(a2)

tst_p4:         tst.w     (a3)
                beq.s     tst_v1
                subq.w    #8,(a3)


tst_v1:         tst.w     voice1
                beq.s     tst_v2
                move.w    d0,(a0)

tst_v2:         tst.w     voice2
                beq.s     tst_v3
                move.w    d0,(a1)

tst_v3:         tst.w     voice3
                beq.s     tst_v4
                move.w    d0,(a2)

tst_v4:         tst.w     voice4
                beq.s     tst_ready
                move.w    d0,(a3)

tst_ready:

* --------------------------------------------------------------------
* Fix the parallax rasters...

                lea       para_rast,a0

                cmpi.w    #2*(28),(a0)
                bne.s     no_wrap
                move.w    #0,(a0)
                bra.s     rast_ready
no_wrap:        addq.w    #4,(a0)

rast_ready:

                jsr       hard_txtscrl

* --------------------------------------------------------------------
;                bra       h
                lea       screen2,a0

                cmpi.w    #8-1,anim_cnt
                bne.s     inc_anim
                move.w    #0,anim_cnt
                move.l    a0,(a0)
                bra.s     ready_anim

inc_anim:       movea.l   (a0),a1
                adda.l    #230*(207+7),a1
                move.l    a1,(a0)
                addq.w    #1,anim_cnt
ready_anim:
h:

                movem.l   (sp)+,d0-a6
                rte

**********************************************************************
anim_cnt:     dc.w 0


**********************************************************************
**********************************************************************
fade_put:
                lsr.w     #3,d0
                and.w     #$0f,d0
                bne.s     go_put
                rts
go_put:
                cmp.w     #11,d0
                ble.s     go_put_now
                rts

go_put_now:     add.w     d0,d0
                subq.w    #2,d0
                lea       col_dec(pc),a0
                adda.w    d0,a0
                move.w    #15*2+16,(a0)
                rts


col_fade:     dc.w $00,$08,$01,$09,$02,$0a,$03,$0b
              dc.w $04,$84,$1c,$9c,$25,$a5,$3d,$bd,$46,$c6,$5e,$de,$67,$e7,$7f,$ff

col_dec:
              rept 11
              dc.w 0
              endr

**********************************************************************
**********************************************************************
* 207 (208-1) lines used for the raster colors... Synched code...

rast_tab_make:
                lea       raster_table,a0         ; dest (12 cycles)
                lea       raster_cols,a1
                lea       rastpile_cols,a2
                lea       rastpile_cols,a3
                lea       rastpile_cols,a4
                lea       rastpile_cols,a5
                adda.w    para_rast,a1
                adda.w    pile_1,a2
                adda.w    pile_2,a3
                adda.w    pile_3,a4
                adda.w    pile_4,a5

              rept 71+8+4+2-1
                move.w    (a1),(a0)+              ; 12
                move.w    (a1),(a0)+
                move.w    (a1),(a0)+
                move.w    (a1),(a0)+
                move.w    (a1)+,(a0)+             ; 60
              endr

              rept 140-3-8-4-2
                tst.w     (a1)                    ; 10
                beq.s     *+12                    ; 10, 8

                move.w    (a1),(a0)+              ; 12
                move.w    (a1),(a0)+
                move.w    (a1),(a0)+
                move.w    (a1),(a0)+
                move.w    (a1)+,(a0)+             ; 60
                bra.s     *+14                    ; 10 ... 88

                move.w    (a2)+,(a0)+             ; 12
                move.w    (a3)+,(a0)+
                move.w    (a4)+,(a0)+
                move.w    (a5)+,(a0)+
                move.w    (a1)+,(a0)+             ; 12..60
                nop
                nop                               ; 88 cycles

              endr

              rept 14
                rts                               ; 16 (8800+16+72)..8888
              endr

para_rast:    dc.w 0
pile_1:       dc.w 0
pile_2:       dc.w 0
pile_3:       dc.w 0
pile_4:       dc.w 0

**********************************************************************
equ_cols_out:
                lea       col_dec(pc),a0          ; 12
                lea       $ffff8240+10.w,a1       ; 12

                lea       col_fade(pc),a3
              rept 11

                movea.l   a3,a2                   ; 4
                adda.w    (a0),a2                 ; 12
                tst.w     (a0)                    ; 8
                beq.s     *+4                     ; 10, 8
                subq.w    #2,(a0)                 ;
                bra.s     *+10                    ;
                nop                               ; 4
                nop
                nop
                nop
                nop
                nop
                move.w    (a2),(a1)+              ; 16
                addq.w    #2,a0                   ; 8....

              endr

; 8xx cycles
                rts

**********************************************************************
**********************************************************************
**********************************************************************
fulltrack_rout:
                lea       $ffff8209.w,a0          ; screen-lo

video_sync:     move.b    (a0),d0
                beq.s     video_sync
                neg.w     d0
                lsl.w     d0,d0


              rept 66-15+5
                nop
              endr

                lea       screen1+1,a0
                move.b    (a0)+,$ffff8205.w
                move.b    (a0)+,$ffff8207.w
                move.b    (a0)+,$ffff8209.w

**********************************************************************
**********************************************************************
**********************************************************************
* The destiny for the left channel!
line_ter:

                move.b    #2,$ffff8260.w          ; mono  (kill linker border!)
                move.b    #0,$ffff8260.w          ; low

* 86*4 cycles                                     ; observe: No (pc)!
                lea       itab,a5
                lea       vtab,a3
                moveq     #0,d0
                moveq     #0,d4

* voice 2
                movea.l   pro_2lc,a0
                move.w    pro_2pos,d0
                move.w    pro_2frc,d1

                move.w    aud_2per,d7
                add.w     d7,d7
                add.w     d7,d7
                move.w    0(a5,d7.w),d2

                movea.w   2(a5,d7.w),a4

                move.w    aud_2vol,d7
                asl.w     #8,d7
                lea       0(a3,d7.w),a2

* voice 3
                movea.l   pro_3lc,a1
                move.w    pro_3pos,d4
                move.w    pro_3frc,d5

                move.w    aud_3per,d7
                add.w     d7,d7
                add.w     d7,d7
                move.w    0(a5,d7.w),d6
                movea.w   2(a5,d7.w),a5

                move.w    aud_3vol,d7
                asl.w     #8,d7

                nop

                move.b    #0,$ffff820a.w          ; 60/50 Hz for right border
                move.b    #2,$ffff820a.w

* 18*4 cycles

                lea       0(a3,d7.w),a3           ; 16 cycles
                movea.l   samp1,a6                ; buffer 1  (20 cycles)
                moveq     #0,d3

              rept 16-5-3
                nop
              endr

                move.l    sp,old_a7               ; ATTENTION!!!
                lea       para_pal,sp

**********************************************************************
**********************************************************************

              rept 13
* line_ter_x

                move.b    #2,$ffff8260.w          ; mono  (kill linker border!)
                move.b    #0,$ffff8260.w          ; low

* 86*4 cycles
* 3 complete shit routines
                add.w     a4,d1                   ; 4
                addx.w    d2,d0                   ; 4
                add.w     a5,d5                   ; 4
                addx.w    d6,d4                   ; 4
                move.b    0(a0,d0.l),d3           ; 16
                move.b    0(a2,d3.w),d7           ; 16  (d7)
                move.b    0(a1,d4.l),d3           ; 16
                add.b     0(a3,d3.w),d7           ; 16  (d7)
                move.w    d7,(a6)+                ; 8   (88 cycles)

                add.w     a4,d1                   ; 4
                addx.w    d2,d0                   ; 4
                add.w     a5,d5                   ; 4
                addx.w    d6,d4                   ; 4
                move.b    0(a0,d0.l),d3           ; 16
                move.b    0(a2,d3.w),d7           ; 16  (d7)
                move.b    0(a1,d4.l),d3           ; 16
                add.b     0(a3,d3.w),d7           ; 16  (d7)
                move.w    d7,(a6)+                ; 8   (88 cycles)

                add.w     a4,d1                   ; 4
                addx.w    d2,d0                   ; 4
                add.w     a5,d5                   ; 4
                addx.w    d6,d4                   ; 4
                move.b    0(a0,d0.l),d3           ; 16
                move.b    0(a2,d3.w),d7           ; 16  (d7)
                move.b    0(a1,d4.l),d3           ; 16
                add.b     0(a3,d3.w),d7           ; 16  (d7)
                move.w    d7,(a6)+                ; 8   (88 cycles)

                add.w     a4,d1                   ; 4
                addx.w    d2,d0                   ; 4
                add.w     a5,d5                   ; 4
                addx.w    d6,d4                   ; 4
                move.b    0(a0,d0.l),d3           ; 16
                move.b    0(a2,d3.w),d7           ; 16  (d7)
                move.b    0(a1,d4.l),d3           ; 16
                add.b     0(a3,d3.w),d7           ; 16  (d7)

                move.b    #0,$ffff820a.w          ; 60/50 Hz for right border
                move.b    #2,$ffff820a.w

                move.w    d7,(a6)+                ; 8 (+)

* 96 (24*4) cycles left


                add.w     a4,d1                   ; 4
                addx.w    d2,d0                   ; 4
                add.w     a5,d5                   ; 4
                addx.w    d6,d4                   ; 4
                move.b    0(a0,d0.l),d3           ; 16
                move.b    0(a2,d3.w),d7           ; 16  (d7)
                move.b    0(a1,d4.l),d3           ; 16
                add.b     0(a3,d3.w),d7           ; 16  (d7)
                move.w    d7,(a6)+                ; 8   (88 cycles)

                nop
                nop

              endr
**********************************************************************
* for pal

                move.b    #2,$ffff8260.w          ; mono  (kill linker border!)
                move.b    #0,$ffff8260.w          ; low

* 86*4 cycles
              rept 86-44-3-24+4+4
                nop
              endr

                move.w    (sp)+,$ffff824a.w
                move.w    (sp)+,$ffff824c.w
                move.w    (sp)+,$ffff824e.w
                move.w    (sp)+,$ffff8250.w

                move.w    (sp)+,$ffff8252.w
                move.w    (sp)+,$ffff8254.w
                move.w    (sp)+,$ffff8256.w
                move.w    (sp)+,$ffff8258.w

                move.w    (sp)+,$ffff825a.w
                move.w    (sp)+,$ffff825c.w
                move.w    (sp)+,$ffff825e.w       ; 16 cycles

                lea       raster_table,sp         ; 12

                move.w    (sp)+,$ffff8242.w
                move.w    (sp)+,$ffff8244.w
                move.w    (sp)+,$ffff8246.w
                move.w    (sp)+,$ffff8248.w

                move.b    #0,$ffff820a.w          ; 60/50 Hz for right border
                move.b    #2,$ffff820a.w


* 104 (26*4) cycles left

              rept 6
                nop
              endr

;                move.w    (sp)+,$ffff8240.w       ; 16 cycles


                lea       screen2+1,a0            ; 12
                move.b    (a0)+,$ffff8205.w       ; 16
                move.b    (a0)+,$ffff8207.w
                move.b    (a0)+,$ffff8209.w

                movea.l   pro_2lc,a0              ; 20


**********************************************************************
* line_ter_x

                move.b    #2,$ffff8260.w          ; mono  (kill linker border!)
                move.b    #0,$ffff8260.w          ; low

* 86*4 cycles
* 3 complete shit routines


                move.w    (sp)+,$ffff8240.w       ; 16 cycles


                add.w     a4,d1                   ; 4
                addx.w    d2,d0                   ; 4
                add.w     a5,d5                   ; 4
                addx.w    d6,d4                   ; 4
                move.b    0(a0,d0.l),d3           ; 16
                move.b    0(a2,d3.w),d7           ; 16  (d7)
                move.b    0(a1,d4.l),d3           ; 16
                add.b     0(a3,d3.w),d7           ; 16  (d7)
                move.w    d7,(a6)+                ; 8   (88 cycles)

                add.w     a4,d1                   ; 4
                addx.w    d2,d0                   ; 4
                add.w     a5,d5                   ; 4
                addx.w    d6,d4                   ; 4
                move.b    0(a0,d0.l),d3           ; 16
                move.b    0(a2,d3.w),d7           ; 16  (d7)
                move.b    0(a1,d4.l),d3           ; 16
                add.b     0(a3,d3.w),d7           ; 16  (d7)
                move.w    d7,(a6)+                ; 8   (88 cycles)

                add.w     a4,d1                   ; 4
                addx.w    d2,d0                   ; 4
                add.w     a5,d5                   ; 4
                addx.w    d6,d4                   ; 4
                move.b    0(a0,d0.l),d3           ; 16
                move.b    0(a2,d3.w),d7           ; 16  (d7)
                move.b    0(a1,d4.l),d3           ; 16
                add.b     0(a3,d3.w),d7           ; 16  (d7)
                move.w    d7,(a6)+                ; 8   (88 cycles)

                add.w     a4,d1                   ; 4
                addx.w    d2,d0                   ; 4
                add.w     a5,d5                   ; 4
                addx.w    d6,d4                   ; 4
                move.b    0(a0,d0.l),d3           ; 16
                move.b    0(a2,d3.w),d7           ; 16  (d7)
                move.b    0(a1,d4.l),d3           ; 16

                move.b    #0,$ffff820a.w          ; 60/50 Hz for right border
                move.b    #2,$ffff820a.w

                add.b     0(a3,d3.w),d7           ; 16  (d7)
                move.w    d7,(a6)+                ; 8 (+)

* 96 (24*4) cycles left

                move.w    (sp)+,$ffff8242.w
                move.w    (sp)+,$ffff8244.w
                move.w    (sp)+,$ffff8246.w
                move.w    (sp)+,$ffff8248.w
                move.w    (sp)+,$ffff8240.w       ; 16 cycles


* --------------------------------------------------------------------
              rept 125-13-4-1
* line_ter_x

                move.b    #2,$ffff8260.w          ; mono  (kill linker border!)
                move.b    #0,$ffff8260.w          ; low

* 86*4 cycles
* 3 complete shit routines

                add.w     a4,d1                   ; 4
                addx.w    d2,d0                   ; 4
                add.w     a5,d5                   ; 4
                addx.w    d6,d4                   ; 4
                move.b    0(a0,d0.l),d3           ; 16
                move.b    0(a2,d3.w),d7           ; 16  (d7)
                move.b    0(a1,d4.l),d3           ; 16
                add.b     0(a3,d3.w),d7           ; 16  (d7)
                move.w    d7,(a6)+                ; 8   (88 cycles)

                add.w     a4,d1                   ; 4
                addx.w    d2,d0                   ; 4
                add.w     a5,d5                   ; 4
                addx.w    d6,d4                   ; 4
                move.b    0(a0,d0.l),d3           ; 16
                move.b    0(a2,d3.w),d7           ; 16  (d7)
                move.b    0(a1,d4.l),d3           ; 16
                add.b     0(a3,d3.w),d7           ; 16  (d7)
                move.w    d7,(a6)+                ; 8   (88 cycles)

                add.w     a4,d1                   ; 4
                addx.w    d2,d0                   ; 4
                add.w     a5,d5                   ; 4
                addx.w    d6,d4                   ; 4
                move.b    0(a0,d0.l),d3           ; 16
                move.b    0(a2,d3.w),d7           ; 16  (d7)
                move.b    0(a1,d4.l),d3           ; 16
                add.b     0(a3,d3.w),d7           ; 16  (d7)
                move.w    d7,(a6)+                ; 8   (88 cycles)

                add.w     a4,d1                   ; 4
                addx.w    d2,d0                   ; 4
                add.w     a5,d5                   ; 4
                addx.w    d6,d4                   ; 4
                move.b    0(a0,d0.l),d3           ; 16
                move.b    0(a2,d3.w),d7           ; 16  (d7)
                move.b    0(a1,d4.l),d3           ; 16
                add.b     0(a3,d3.w),d7           ; 16  (d7)

                move.b    #0,$ffff820a.w          ; 60/50 Hz for right border
                move.b    #2,$ffff820a.w

                move.w    d7,(a6)+                ; 8 (+)

* 96 (24*4) cycles left

                move.w    (sp)+,$ffff8242.w
                move.w    (sp)+,$ffff8244.w
                move.w    (sp)+,$ffff8246.w
                move.w    (sp)+,$ffff8248.w
                move.w    (sp)+,$ffff8240.w       ; 16 cycles

                nop
                nop
                nop
                nop

              endr

**********************************************************************
* --------------------------------------------------------------------

                move.b    #2,$ffff8260.w          ; mono  (kill linker border!)
                move.b    #0,$ffff8260.w          ; low

* 86*4 cycles
* 3 complete shit routines
                add.w     a4,d1                   ; 4
                addx.w    d2,d0                   ; 4
                add.w     a5,d5                   ; 4
                addx.w    d6,d4                   ; 4
                move.b    0(a0,d0.l),d3           ; 16
                move.b    0(a2,d3.w),d7           ; 16  (d7)
                move.b    0(a1,d4.l),d3           ; 16
                add.b     0(a3,d3.w),d7           ; 16  (d7)
                move.w    d7,(a6)+                ; 8   (88 cycles)

                add.w     a4,d1                   ; 4
                addx.w    d2,d0                   ; 4
                add.w     a5,d5                   ; 4
                addx.w    d6,d4                   ; 4
                move.b    0(a0,d0.l),d3           ; 16
                move.b    0(a2,d3.w),d7           ; 16  (d7)
                move.b    0(a1,d4.l),d3           ; 16
                add.b     0(a3,d3.w),d7           ; 16  (d7)
                move.w    d7,(a6)+                ; 8   (88 cycles)

                add.w     a4,d1                   ; 4
                addx.w    d2,d0                   ; 4
                add.w     a5,d5                   ; 4
                addx.w    d6,d4                   ; 4
                move.b    0(a0,d0.l),d3           ; 16
                move.b    0(a2,d3.w),d7           ; 16  (d7)
                move.b    0(a1,d4.l),d3           ; 16
                add.b     0(a3,d3.w),d7           ; 16  (d7)
                move.w    d7,(a6)+                ; 8   (88 cycles)


              rept 20
                nop
              endr


                move.b    #0,$ffff820a.w          ; 60/50 Hz for right border
                move.b    #2,$ffff820a.w

                nop
                nop

* 96 (24*4) cycles left

                move.w    (sp)+,$ffff8242.w
                move.w    (sp)+,$ffff8244.w
                move.w    (sp)+,$ffff8246.w
                move.w    (sp)+,$ffff8248.w
                move.w    (sp)+,$ffff8240.w       ; 16 cycles

                nop
                nop
                nop
                nop



**********************************************************************
**********************************************************************

                move.b    #2,$ffff8260.w          ; mono  (kill linker border!)
                move.b    #0,$ffff8260.w          ; low

* 86*4 cycles                                     ; observe: No (pc)!

                cmp.l     pro_2len,d0
                blt.s     .ok2
                sub.w     pro_2rpt,d0
                bra.s     bss_sync2
.ok2:
              rept 7
                nop
              endr

bss_sync2:      move.w    d0,pro_2pos
                move.w    d1,pro_2frc


                cmp.l     pro_3len,d4
                blt.s     .ok3
                sub.w     pro_3rpt,d4
                bra.s     bss_sync3

.ok3:
              rept 7
                nop
              endr
bss_sync3:      move.w    d4,pro_3pos
                move.w    d5,pro_3frc

              rept 40-8-5
                nop
              endr

* --------------------------------------------------------------------
* 40*4 cycles
* ATTENTION! This code is for the RIGHT channel!
                lea       itab,a5                 ; 12
                lea       vtab,a3                 ; 12
                moveq     #0,d0                   ; 4
                moveq     #0,d4                   ; 4
                movea.l   pro_1lc,a0              ; 20

* --------------------------------------------------------------------


                move.b    #0,$ffff820a.w          ; 60/50 Hz for right border
                move.b    #2,$ffff820a.w

*  84 cycles

                move.w    (sp)+,$ffff8242.w
                move.w    (sp)+,$ffff8244.w
                move.w    (sp)+,$ffff8246.w
                move.w    (sp)+,$ffff8248.w
                move.w    (sp)+,$ffff8240.w       ; 16 cycles

                nop

**********************************************************************
**********************************************************************
**********************************************************************
* And now it's time for the right channel, man!

                nop
                nop
                nop
                nop
                nop
                move.b    #2,$ffff8260.w          ; mono  (kill linker border!)
                move.b    #0,$ffff8260.w          ; low

* 86*4 cycles                                     ; observe: No (pc)!


* voice 1
* Continued code...

                move.w    pro_1pos,d0
                move.w    pro_1frc,d1

                move.w    aud_1per,d7
                add.w     d7,d7
                add.w     d7,d7
                move.w    0(a5,d7.w),d2
                movea.w   2(a5,d7.w),a4

                move.w    aud_1vol,d7
                asl.w     #8,d7
                lea       0(a3,d7.w),a2

* voice 4
                movea.l   pro_4lc,a1
                move.w    pro_4pos,d4
                move.w    pro_4frc,d5

                move.w    aud_4per,d7
                add.w     d7,d7
                add.w     d7,d7
                move.w    0(a5,d7.w),d6
                movea.w   2(a5,d7.w),a5

                move.w    aud_4vol,d7
                asl.w     #8,d7


                movea.l   samp1,a6                ; buffer 1 (20 cycles)
                moveq     #0,d3


                nop
                nop
                nop
                nop
                nop
                nop
                nop

                nop

                move.b    #0,$ffff820a.w          ; 60/50 Hz for right border
                move.b    #2,$ffff820a.w

* 18*4 cycles

                lea       0(a3,d7.w),a3           ; 16


              rept 2
                nop
              endr

                move.w    (sp)+,$ffff8242.w
                move.w    (sp)+,$ffff8244.w
                move.w    (sp)+,$ffff8246.w
                move.w    (sp)+,$ffff8248.w
                move.w    (sp)+,$ffff8240.w       ; 16 cycles



**********************************************************************

              rept 100/2-1-1-1                ; * dec for pal (7 s. routs)
* line_ter_x2

                move.b    #2,$ffff8260.w          ; mono  (kill linker border!)
                move.b    #0,$ffff8260.w          ; low

* 86*4 cycles
* 3 complete shit routines

                add.w     a4,d1
                addx.w    d2,d0
                add.w     a5,d5
                addx.w    d6,d4
                move.b    0(a0,d0.l),d3
                move.b    0(a2,d3.w),d7
                move.b    0(a1,d4.l),d3
                add.b     0(a3,d3.w),d7
                move.b    d7,(a6)                 ; .b
                addq.w    #2,a6                   ; 88+8 cycles

                add.w     a4,d1
                addx.w    d2,d0
                add.w     a5,d5
                addx.w    d6,d4
                move.b    0(a0,d0.l),d3
                move.b    0(a2,d3.w),d7
                move.b    0(a1,d4.l),d3
                add.b     0(a3,d3.w),d7
                move.b    d7,(a6)                 ; .b
                addq.w    #2,a6                   ; 88+8 cycles

                add.w     a4,d1
                addx.w    d2,d0
                add.w     a5,d5
                addx.w    d6,d4
                move.b    0(a0,d0.l),d3
                move.b    0(a2,d3.w),d7
                move.b    0(a1,d4.l),d3
                add.b     0(a3,d3.w),d7
                move.b    d7,(a6)                 ; .b
                addq.w    #2,a6                   ; 88+8 cycles

                add.w     a4,d1
                addx.w    d2,d0
                add.w     a5,d5
                addx.w    d6,d4
                move.b    0(a0,d0.l),d3
                move.b    0(a2,d3.w),d7

                nop
                nop

                move.b    #0,$ffff820a.w          ; 60/50 Hz for right border
                move.b    #2,$ffff820a.w
* --------------------------------------------------------------------

* 80 cycles for colors
                move.w    (sp)+,$ffff8242.w
                move.w    (sp)+,$ffff8244.w
                move.w    (sp)+,$ffff8246.w
                move.w    (sp)+,$ffff8248.w
                move.w    (sp)+,$ffff8240.w       ; 16 cycles


                nop
                nop
                nop
                nop

                nop
                nop

* --------------------------------------------------------------------

* line_ter_x2

                move.b    #2,$ffff8260.w          ; mono  (kill linker border!)
                move.b    #0,$ffff8260.w          ; low

* 86*4 cycles

                move.b    0(a1,d4.l),d3           ; 16
                add.b     0(a3,d3.w),d7           ; 16
                move.b    d7,(a6)                 ; 8
                addq.w    #2,a6                   ; 8


                add.w     a4,d1
                addx.w    d2,d0
                add.w     a5,d5
                addx.w    d6,d4
                move.b    0(a0,d0.l),d3
                move.b    0(a2,d3.w),d7
                move.b    0(a1,d4.l),d3
                add.b     0(a3,d3.w),d7
                move.b    d7,(a6)                 ; .b
                addq.w    #2,a6                   ; 88+8 cycles

                add.w     a4,d1
                addx.w    d2,d0
                add.w     a5,d5
                addx.w    d6,d4
                move.b    0(a0,d0.l),d3
                move.b    0(a2,d3.w),d7
                move.b    0(a1,d4.l),d3
                add.b     0(a3,d3.w),d7
                move.b    d7,(a6)                 ; .b
                addq.w    #2,a6                   ; 88+8 cycles

                add.w     a4,d1                   ; 4
                addx.w    d2,d0                   ; 4
                add.w     a5,d5                   ; 4
                addx.w    d6,d4                   ; 4
                move.b    0(a0,d0.l),d3           ; 16
                move.b    0(a2,d3.w),d7           ; 16
                move.b    0(a1,d4.l),d3           ; 16
                add.b     0(a3,d3.w),d7           ; 16
                move.b    d7,(a6)                 ; 8 (.b)
                addq.w    #2,a6                   ; 8, 88+8 cycles

                nop
                nop

                move.b    #0,$ffff820a.w          ; 60/50 Hz for right border
                move.b    #2,$ffff820a.w
* --------------------------------------------------------------------

* 80 cycles for colors
                move.w    (sp)+,$ffff8242.w
                move.w    (sp)+,$ffff8244.w
                move.w    (sp)+,$ffff8246.w
                move.w    (sp)+,$ffff8248.w
                move.w    (sp)+,$ffff8240.w       ; 16 cycles

                nop
                nop
                nop
                nop

                nop
                nop

              endr
**********************************************************************





**********************************************************************
* This is to change palette...
* line_ter_x2

                move.b    #2,$ffff8260.w          ; mono  (kill linker border!)
                move.b    #0,$ffff8260.w          ; low

* 86*4 cycles
* 3 complete shit routines

                add.w     a4,d1
                addx.w    d2,d0
                add.w     a5,d5
                addx.w    d6,d4
                move.b    0(a0,d0.l),d3
                move.b    0(a2,d3.w),d7
                move.b    0(a1,d4.l),d3
                add.b     0(a3,d3.w),d7
                move.b    d7,(a6)                 ; .b
                addq.w    #2,a6                   ; 88+8 cycles

                add.w     a4,d1
                addx.w    d2,d0
                add.w     a5,d5
                addx.w    d6,d4
                move.b    0(a0,d0.l),d3
                move.b    0(a2,d3.w),d7
                move.b    0(a1,d4.l),d3
                add.b     0(a3,d3.w),d7
                move.b    d7,(a6)                 ; .b
                addq.w    #2,a6                   ; 88+8 cycles

                add.w     a4,d1
                addx.w    d2,d0
                add.w     a5,d5
                addx.w    d6,d4
                move.b    0(a0,d0.l),d3
                move.b    0(a2,d3.w),d7
                move.b    0(a1,d4.l),d3
                add.b     0(a3,d3.w),d7
                move.b    d7,(a6)                 ; .b
                addq.w    #2,a6                   ; 88+8 cycles

                add.w     a4,d1
                addx.w    d2,d0
                add.w     a5,d5
                addx.w    d6,d4
                move.b    0(a0,d0.l),d3
                move.b    0(a2,d3.w),d7

                nop
                nop

                move.b    #0,$ffff820a.w          ; 60/50 Hz for right border
                move.b    #2,$ffff820a.w
* --------------------------------------------------------------------

* 80 cycles for colors
                move.w    (sp)+,$ffff8242.w
                move.w    (sp)+,$ffff8244.w
                move.w    (sp)+,$ffff8246.w
                move.w    (sp)+,$ffff8248.w
                move.w    (sp)+,$ffff8240.w       ; 16 cycles


                nop
                nop
                nop
                nop

                nop
                nop

* --------------------------------------------------------------------

* line_ter_x2

                move.b    #2,$ffff8260.w          ; mono  (kill linker border!)
                move.b    #0,$ffff8260.w          ; low

* 86*4 cycles

                move.b    0(a1,d4.l),d3           ; 16
                add.b     0(a3,d3.w),d7           ; 16
                move.b    d7,(a6)                 ; 8
                addq.w    #2,a6                   ; 8


                add.w     a4,d1
                addx.w    d2,d0
                add.w     a5,d5
                addx.w    d6,d4
                move.b    0(a0,d0.l),d3
                move.b    0(a2,d3.w),d7
                move.b    0(a1,d4.l),d3
                add.b     0(a3,d3.w),d7
                move.b    d7,(a6)                 ; .b
                addq.w    #2,a6                   ; 88+8 cycles

                add.w     a4,d1
                addx.w    d2,d0
                add.w     a5,d5
                addx.w    d6,d4
                move.b    0(a0,d0.l),d3
                move.b    0(a2,d3.w),d7
                move.b    0(a1,d4.l),d3
                add.b     0(a3,d3.w),d7
                move.b    d7,(a6)                 ; .b
                addq.w    #2,a6                   ; 88+8 cycles

                add.w     a4,d1                   ; 4
                addx.w    d2,d0                   ; 4
                add.w     a5,d5                   ; 4
                addx.w    d6,d4                   ; 4
                move.b    0(a0,d0.l),d3           ; 16
                move.b    0(a2,d3.w),d7           ; 16
                move.b    0(a1,d4.l),d3           ; 16
                add.b     0(a3,d3.w),d7           ; 16
                move.b    d7,(a6)                 ; 8 (.b)
                addq.w    #2,a6                   ; 8, 88+8 cycles

                nop
                nop

                move.b    #0,$ffff820a.w          ; 60/50 Hz for right border
                move.b    #2,$ffff820a.w
* --------------------------------------------------------------------


* 80 cycles for colors
                lea       little_pal,sp

                move.w    #$0223,$ffff8242.w
                move.w    #$0334,$ffff8244.w
                move.w    #$0445,$ffff8246.w
                move.w    #$00,$ffff8248.w        ; 16 cycles

                move.w    (sp)+,$ffff8240.w

;                nop
;                nop
;                nop
                nop

                nop
                nop




**********************************************************************
              rept 4+1                        ; * inc for pal
                move.b    #2,$ffff8260.w          ; mono  (kill linker border!)
                move.b    #0,$ffff8260.w          ; low

* 86*4 cycles
* 3 complete shit routines

                add.w     a4,d1
                addx.w    d2,d0
                add.w     a5,d5
                addx.w    d6,d4
                move.b    0(a0,d0.l),d3
                move.b    0(a2,d3.w),d7
                move.b    0(a1,d4.l),d3
                add.b     0(a3,d3.w),d7
                move.b    d7,(a6)                 ; .b
                addq.w    #2,a6                   ; 88+8 cycles

                add.w     a4,d1
                addx.w    d2,d0
                add.w     a5,d5
                addx.w    d6,d4
                move.b    0(a0,d0.l),d3
                move.b    0(a2,d3.w),d7
                move.b    0(a1,d4.l),d3
                add.b     0(a3,d3.w),d7
                move.b    d7,(a6)                 ; .b
                addq.w    #2,a6                   ; 88+8 cycles

                add.w     a4,d1
                addx.w    d2,d0
                add.w     a5,d5
                addx.w    d6,d4
                move.b    0(a0,d0.l),d3
                move.b    0(a2,d3.w),d7
                move.b    0(a1,d4.l),d3
                add.b     0(a3,d3.w),d7
                move.b    d7,(a6)                 ; .b
                addq.w    #2,a6                   ; 88+8 cycles

                add.w     a4,d1
                addx.w    d2,d0
                add.w     a5,d5
                addx.w    d6,d4
                move.b    0(a0,d0.l),d3
                move.b    0(a2,d3.w),d7

                nop
                nop

                move.b    #0,$ffff820a.w          ; 60/50 Hz for right border
                move.b    #2,$ffff820a.w

                move.b    0(a1,d4.l),d3           ; 16
                add.b     0(a3,d3.w),d7           ; 16
                move.b    d7,(a6)                 ; 8
                addq.w    #2,a6                   ; 8


                nop
                nop
                nop
                nop

                nop
                nop
                nop
                nop

                nop
                nop
;                nop
;                nop

;                nop
;                nop

                move.w    (sp)+,$ffff8240.w

              endr

* --------------------------------------------------------------------

                move.b    #2,$ffff8260.w          ; mono  (kill linker border!)
                move.b    #0,$ffff8260.w          ; low

* 86*4 cycles
* 3 complete shit routines

                add.w     a4,d1
                addx.w    d2,d0
                add.w     a5,d5
                addx.w    d6,d4
                move.b    0(a0,d0.l),d3
                move.b    0(a2,d3.w),d7
                move.b    0(a1,d4.l),d3
                add.b     0(a3,d3.w),d7
                move.b    d7,(a6)                 ; .b
                addq.w    #2,a6                   ; 88+8 cycles

                add.w     a4,d1
                addx.w    d2,d0
                add.w     a5,d5
                addx.w    d6,d4
                move.b    0(a0,d0.l),d3
                move.b    0(a2,d3.w),d7
                move.b    0(a1,d4.l),d3
                add.b     0(a3,d3.w),d7
                move.b    d7,(a6)                 ; .b
                addq.w    #2,a6                   ; 88+8 cycles

                add.w     a4,d1
                addx.w    d2,d0
                add.w     a5,d5
                addx.w    d6,d4
                move.b    0(a0,d0.l),d3
                move.b    0(a2,d3.w),d7
                move.b    0(a1,d4.l),d3
                add.b     0(a3,d3.w),d7
                move.b    d7,(a6)                 ; .b
                addq.w    #2,a6                   ; 88+8 cycles

                add.w     a4,d1
                addx.w    d2,d0
                add.w     a5,d5
                addx.w    d6,d4
                move.b    0(a0,d0.l),d3
                move.b    0(a2,d3.w),d7

                nop
                nop

                move.b    #0,$ffff820a.w          ; 60/50 Hz for right border
                move.b    #2,$ffff820a.w

                move.b    0(a1,d4.l),d3           ; 16
                add.b     0(a3,d3.w),d7           ; 16
                move.b    d7,(a6)                 ; 8
                addq.w    #2,a6                   ; 8


                nop


                move.w    #$00,$ffff8248.w        ; 16
                move.w    #$00,$ffff824a.w


* ATTENTION: 49 routs left to reach 400!
**********************************************************************
**********************************************************************
* kill the low fucking border!
                nop

                move.b    #0,$ffff820a.w          ; 60 Hz
                move.b    #2,$ffff8260.w          ; mono
                move.b    #0,$ffff8260.w          ; low
                move.b    #2,$ffff820a.w          ; 50 Hz

* 82*4 cycles

              rept 82-24-2-48+8-4
                nop
              endr


                move.w    #$00,$ffff824c.w        ; 16
                move.w    #$00,$ffff824e.w
                move.w    #$00,$ffff8250.w
                move.w    #$00,$ffff8252.w
                move.w    #$00,$ffff8254.w
                move.w    #$00,$ffff8256.w
                move.w    #$00,$ffff8258.w
                move.w    #$00,$ffff825a.w
                move.w    #$00,$ffff825c.w
                move.w    #$00,$ffff825e.w

                add.w     a4,d1                   ; 49-1 routs left
                addx.w    d2,d0
                add.w     a5,d5
                addx.w    d6,d4
                move.b    0(a0,d0.l),d3
                move.b    0(a2,d3.w),d7
                move.b    0(a1,d4.l),d3
                add.b     0(a3,d3.w),d7
                move.b    d7,(a6)                 ; .b
                addq.w    #2,a6                   ; 88+8 cycles



                move.b    #$00,$ffff8209.w



                lea       precalc_820f(pc),a0


                move.b    #0,$ffff820a.w          ; 60/50 Hz for right border
                move.b    #2,$ffff820a.w

* 24*4 cycles

                nop
                nop

                move.b    (a0)+,$ffff820f.w
                move.b    (a0)+,$ffff8205.w       ; 16
                move.b    (a0)+,$ffff8207.w
                move.b    (a0)+,$ffff8209.w
                move.b    (a0)+,$ffff8265.w

                nop
                nop
                nop
                nop

**********************************************************************
* go on with left & right termination... and right channel!

* line_ter_x3

                move.b    #2,$ffff8260.w          ; mono  (kill linker border!)
                move.b    #0,$ffff8260.w          ; low

* 86*4 cycles
* 3 complete shit routines

                movea.l   pro_1lc(pc),a0          ; 16 (pc)


                add.w     a4,d1
                addx.w    d2,d0
                add.w     a5,d5
                addx.w    d6,d4
                move.b    0(a0,d0.l),d3
                move.b    0(a2,d3.w),d7
                move.b    0(a1,d4.l),d3
                add.b     0(a3,d3.w),d7
                move.b    d7,(a6)                 ; .b
                addq.w    #2,a6                   ; 88+8 cycles

                add.w     a4,d1
                addx.w    d2,d0
                add.w     a5,d5
                addx.w    d6,d4
                move.b    0(a0,d0.l),d3
                move.b    0(a2,d3.w),d7
                move.b    0(a1,d4.l),d3
                add.b     0(a3,d3.w),d7
                move.b    d7,(a6)                 ; .b
                addq.w    #2,a6                   ; 88+8 cycles

                add.w     a4,d1
                addx.w    d2,d0
                add.w     a5,d5
                addx.w    d6,d4
                move.b    0(a0,d0.l),d3
                move.b    0(a2,d3.w),d7
                move.b    0(a1,d4.l),d3
                add.b     0(a3,d3.w),d7
                move.b    d7,(a6)                 ; .b
                addq.w    #2,a6                   ; 88+8 cycles

                add.w     a4,d1
                addx.w    d2,d0
                add.w     a5,d5
                addx.w    d6,d4
                move.b    0(a0,d0.l),d3

;                nop
;                nop
;                nop
;                nop

                nop
                nop

                move.b    #0,$ffff820a.w          ; 60/50 Hz for right border
                move.b    #2,$ffff820a.w

* x cycles

                move.b    0(a2,d3.w),d7           ; 16


                move.b    0(a1,d4.l),d3           ; 16
                add.b     0(a3,d3.w),d7           ; 16
                move.b    d7,(a6)                 ; 8
                addq.w    #2,a6                   ; 8


;                nop
;                nop
;                nop
;                nop

                nop
                nop
                nop
                nop

                nop
                nop
                nop
                nop

                nop
                nop

* --------------------------------------------------------------------
              rept 24-1
* line_ter_x3

                move.b    #2,$ffff8260.w          ; mono  (kill linker border!)
                move.b    #0,$ffff8260.w          ; low

* 86*4 cycles
* 3 complete shit routines
                add.w     a4,d1
                addx.w    d2,d0
                add.w     a5,d5
                addx.w    d6,d4
                move.b    0(a0,d0.l),d3
                move.b    0(a2,d3.w),d7
                move.b    0(a1,d4.l),d3
                add.b     0(a3,d3.w),d7
                move.b    d7,(a6)                 ; .b
                addq.w    #2,a6                   ; 88+8 cycles

                add.w     a4,d1
                addx.w    d2,d0
                add.w     a5,d5
                addx.w    d6,d4
                move.b    0(a0,d0.l),d3
                move.b    0(a2,d3.w),d7
                move.b    0(a1,d4.l),d3
                add.b     0(a3,d3.w),d7
                move.b    d7,(a6)                 ; .b
                addq.w    #2,a6                   ; 88+8 cycles

                add.w     a4,d1
                addx.w    d2,d0
                add.w     a5,d5
                addx.w    d6,d4
                move.b    0(a0,d0.l),d3
                move.b    0(a2,d3.w),d7
                move.b    0(a1,d4.l),d3
                add.b     0(a3,d3.w),d7
                move.b    d7,(a6)                 ; .b
                addq.w    #2,a6                   ; 88+8 cycles

                add.w     a4,d1
                addx.w    d2,d0
                add.w     a5,d5
                addx.w    d6,d4
                move.b    0(a0,d0.l),d3
                move.b    0(a2,d3.w),d7

                nop
                nop

                move.b    #0,$ffff820a.w          ; 60/50 Hz for right border
                move.b    #2,$ffff820a.w

* x cycles

                move.b    0(a1,d4.l),d3           ; 16
                add.b     0(a3,d3.w),d7           ; 16
                move.b    d7,(a6)                 ; 8
                addq.w    #2,a6                   ; 8


                nop
                nop
                nop
                nop

                nop
                nop
                nop
                nop

                nop
                nop
                nop
                nop

                nop
                nop
              endr

**********************************************************************
                move.b    #0,$ffff820f.w          ; back!!!
                move.b    #0,$ffff8265.w          ; back!!!


              rept 48-12+4+(7-4)              ; * inc for pal
                add.w     a4,d1
                addx.w    d2,d0
                add.w     a5,d5
                addx.w    d6,d4
                move.b    0(a0,d0.l),d3
                move.b    0(a2,d3.w),d7
                move.b    0(a1,d4.l),d3
                add.b     0(a3,d3.w),d7
                move.b    d7,(a6)                 ; .b
                addq.w    #2,a6                   ; 88+8 cycles
              endr

                cmp.l     pro_1len(pc),d0
                blt.s     .ok1
                sub.w     pro_1rpt(pc),d0
.ok1:
                move.w    d0,pro_1pos
                move.w    d1,pro_1frc

                cmp.l     pro_4len,d4
                blt.s     .ok4
                sub.w     pro_4rpt(pc),d4
.ok4:
                move.w    d4,pro_4pos
                move.w    d5,pro_4frc

                movea.l   old_a7(pc),sp           ; ATTENTION!!!
                rts


**********************************************************************
**********************************************************************
old_a7:       dc.l 0


para_pal:     dc.w $0992,$022a,$0aa3,$0bb4,$0cc5,$0dd6,$0ee7,$0335
              dc.w $0bbd,$0446,$0cce

;dc.w            $0,$8,$1,$9,$2,$a,$3,$b,$4,$c,$5,$d,$6,$e,$7,$f
little_pal:   dc.w $0cc5,$0bb4,$0aa3,$0992,$0881,$00

raster_table: ds.w 207*5

raster_cols:
              rept 10
              dc.w $00,$00,$00,$00,$00,$00,$00,$00
              dc.w $00,$00,$00,$00,$00,$00,$00,$00

              dc.w $01,$0112,$0223
              dc.w $0334,$0445,$0556,$0667
              dc.w $0556,$0445,$0334
              dc.w $0223,$0112,$01,$00
              endr

rastpile_cols:
              rept 140
              dc.w 0
              endr

;              dc.w $00,$80,$10,$90,$20,$a0,$30,$b0,$40
              dc.w $0100,$0200,$0300,$0400,$0500,$0600

              rept 10
              dc.w $0700,$0608,$0501,$0409,$0302,$020a,$0103,$0b,$04
              dc.w $04,$010b,$0203,$030a,$0402,$0509,$0601,$0708,$0700
              endr



**********************************************************************
**********************************************************************
**********************************************************************
* Hardware text-scroll (using no blitter) by Techwave.               *
* 48*24                                                              *
**********************************************************************
**********************************************************************
**********************************************************************
hard_txtscrl:
                moveq     #0,d2

                move.w    scroll(pc),d1
                add.w     #16+16,d1

                move.w    d1,d2
                and.w     #$0f,d1
                move.b    d1,precalc_8265
                bne.s     fix_line
                move.b    #115+1+16,precalc_820f  ; x-words    80+8+4(-4)
                sub.w     #$10,d2
                bra.s     scrn_poi
fix_line:       move.b    #115+16,precalc_820f
scrn_poi:
                and.w     #$fff0,d2               ; x scroll-counter
                lsr.w     #1,d2
                move.l    txt_scroll,d0

                add.l     d2,d0

                move.b    d0,precalc_8209
                lsr.w     #8,d0
                move.b    d0,precalc_8207
                swap      d0
                move.b    d0,precalc_8205


                cmpi.b    #4,word_corr
                bne.s     no_gfx_move
                move.b    #0,word_corr

                bsr.s     charout

no_gfx_move:    addq.b    #1,word_corr


                cmpi.w    #460-24-8,scroll        ; 320+32-4
                blo.s     inc_poi
                move.w    #0,scroll
                rts
inc_poi:        addq.w    #4,scroll
                rts

**********************************************************************
scroll:       dc.w 0
word_corr:    dc.b 4
              even

precalc_820f: dc.b 0

precalc_8205: dc.b 0
precalc_8207: dc.b 0
precalc_8209: dc.b 0
precalc_8265: dc.b 0

              even
**********************************************************************
charout:        lea       fontpic+34,a0
                move.w    offset(pc),d0
                adda.w    d0,a0
                movea.l   a0,a2

                movea.l   txt_scroll,a1           ; Warning! Reloc..?
                adda.w    #230+54+12-24,a1        ; It will freak, man!

                move.w    scroll(pc),d0
                and.w     #$fff0,d0
                lsr.w     #1,d0
                adda.w    d0,a1

              rept 23
                move.w    (a0)+,(a1)+             ; 12 cycles
                move.w    (a0),(a1)
                lea       160-2(a0),a0
                lea       460+32-2+2(a1),a1
              endr
                move.w    (a0)+,(a1)+             ; 12
                move.w    (a0),(a1)



* --------------------------------------------------------------------

                movea.l   a2,a0
                movea.l   txt_scroll,a1
                adda.w    #230+54+200+12-24+16,a1

                adda.w    d0,a1

              rept 23
                move.w    (a0)+,(a1)+
                move.w    (a0),(a1)
                lea       160-2(a0),a0
                lea       460+32-2+2(a1),a1
              endr
                move.w    (a0)+,(a1)+
                move.w    (a0),(a1)

                cmpi.b    #2,word_x               ; for x 48
                beq.s     ready
                addq.w    #8,offset
                addq.b    #1,word_x
                rts

ready:          subq.b    #2,word_x               ; ...jag „lskar er
                move.w    #0,offset

* --------------------------------------------------------------------
read:           moveq     #0,d0
                lea       txt,a0
                adda.w    txt_pointer(pc),a0
                move.b    (a0),d0
                bne.s     ascii
                move.w    #0,txt_pointer
                bra.s     read

ascii:          cmp.b     #32,d0
                ble.s     space
                cmp.b     #33,d0
                beq.s     special_1
                cmp.b     #40,d0
                beq.s     special_2
                cmp.b     #41,d0
                beq.s     special_3
                cmp.b     #46,d0
                beq.s     special_4
                cmp.b     #",",d0
                beq.s     special_5
                cmp.b     #"?",d0
                beq.s     special_6
                cmp.b     #"'",d0
                beq.s     special_7
                cmp.b     #":",d0
                beq.s     special_8

                sub.b     #32+15,d0
                add.w     d0,d0
mv_offset:      lea       char_offs(pc),a0
                move.w    0(a0,d0.w),offset
                addq.w    #1,txt_pointer
                rts

space:          moveq     #0,d0
                bra.s     mv_offset
special_1:      move.w    #(14)*2,d0
                bra.s     mv_offset
special_2:      move.w    #(12)*2,d0
                bra.s     mv_offset
special_3:      move.w    #(13)*2,d0
                bra.s     mv_offset
special_4:      move.w    #(15)*2,d0
                bra.s     mv_offset
special_5:      move.w    #(16)*2,d0
                bra.s     mv_offset
special_6:      move.w    #(17)*2,d0
                bra.s     mv_offset
special_7:      move.w    #(11)*2,d0
                bra.s     mv_offset
special_8:      move.w    #(44)*2,d0
                bra.s     mv_offset



**********************************************************************

word_x:       dc.b 0
              even
txt_pointer:  dc.w 0
offset:       dc.w 0

**********************************************************************
* --------------------------------------------------------------- data
* starts with ASCII #32+15 (empty)... 24 lines + 1 xtraline
char_offs:
              dc.w 0,24,48,72,96,120
              dc.w 0+4000,24+4000,48+4000,72+4000,96+4000,120+4000
              dc.w 0+8000,24+8000,48+8000,72+8000,96+8000,120+8000
              dc.w 0+12000,24+12000,48+12000,72+12000,96+12000,120+12000
              dc.w 0+16000,24+16000,48+16000,72+16000,96+16000,120+16000
              dc.w 0+20000,24+20000,48+20000,72+20000,96+20000,120+20000
              dc.w 0+24000,24+24000,48+24000,72+24000,96+24000,120+24000
              dc.w 0+28000,24+28000,48+28000,72+28000,96+28000,120+28000



* --------------------------------------------------------------------

* --------------------------------------------------------------------


**********************************************************************
**********************************************************************
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
                beq.s     yez_now
                rts
yez_now:        move.w    #PARTS,count

                jsr       music                   ; branch subrout
                rts

**********************************************************************

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
                lea       data(pc),a1             ; Module
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
noise_init:     lea       data(pc),a0
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
music:          lea       data(pc),a0             ; <---- music subrout
                addq.w    #$01,counter
                move.w    counter(pc),d0
                cmp.w     speed(pc),d0
                blt.s     nonew
                clr.w     counter
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
                move.w    counter(pc),d0
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

getnew:         lea       data+$043c(pc),a0
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
                cmp.b     data+$03b6(pc),d1
                bne.s     endr
                move.b    data+$03b7(pc),songpos
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
                clr.w     counter
rts2:           rts

sin:          dc.b $00,$18,$31,$4a,$61,$78,$8d,$a1,$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
              dc.b $ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5,$b4,$a1,$8d,$78,$61,$4a,$31,$18

periods:      dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c,$023a,$021a,$01fc,$01e0
              dc.w $01c5,$01ac,$0194,$017d,$0168,$0153,$0140,$012e,$011d,$010d,$fe
              dc.w $f0,$e2,$d6,$ca,$be,$b4,$aa,$a0,$97,$8f,$87
              dc.w $7f,$78,$71,$00,$00

speed:        dc.w $06
counter:      dc.w $00
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

mw_settings:  dc.w %10011000000+40            ; master    0-40
              dc.w %10101000000+20            ; left      0-20
              dc.w %10100000000+20            ; right     0-20
              dc.w %10010000000+6+1           ; treble    0-12 (6=0dB)
              dc.w %10001000000+6+3           ; bass      0-12 (6=0dB)
              dc.w %10000000000+2             ; mix       0-03
mw_setend:
* --------------------------------------------------------------------

data:         ibytes 'B:\LILL*.MOD'

              ds.b 16384+320+5000             ; Workspace
workspc:      ds.w 1
ind_pic:      ibytes 'A:\IND_FUCK.PI1',4514
fontpic:      ibytes 'DRAGF_D2.PI1'

              even
txt_scroll:   dc.l txt_scroll
* txt-space
              ds.b 230*2*50

txt:
              dc.b "                                   "
              dc.b "THE MEGAFROZEN INNER CIRCUIT EXPLORERS ARE JUST COOLER (LIKE A 0,33L COKE...)!  "
              dc.b "HERE U SEE THE KRYOS SCREEN (THAT'S GREEK FOR COLDNESS...)!   "
              dc.b "IT CONTAINS, AS YOU SEE, A NICE FULLSCREEN WITH TRACKERMUZAK AT 25 KHZ IN HIGH QUALITY STEREO SOUND, PARALLAX VISION "
              dc.b "AND SOME OTHER NICE STUFF!   "
              dc.b "ANYWAY, TRY TO BEAT THIS U FOOL!!!    IN FACT, THIS FULLSCREEN (IT MAY BE SOME PROBLEMS WITH DIFFERENT SHIFTERS, SORRY!) "
              dc.b "WILL NEVER BE BEATEN BY OTHER THAN MYSELF! (THAT SHOULD MAKE U START CODING!)...        "
              dc.b "CREDITS:  CODE (68000 CYCLES FREAKCOUNT, THIS NEARLY MADE ME BURN THE SHIT UP!) AND NASTY GFX BY TECHWAVE OF ICE, "
              dc.b "TINYHEAVY AND SARAMIX MODULE BY SURF OF ICE, INTROLOGO BY CUTTER OF ICE! "

              dc.b "  SOME UPPSALA PARTY GREETZ FROM TECHWAVE TO:     "
              dc.b "ELECTRA (GREAT PARTY BUT U CAN FUCK YOUR UPPSALA PIZZAS!),    "
              dc.b "UNIT 17 (WHEN IS IT GOING TO EXPLODE?! WET DYNAMITE?),    "
              dc.b "IMAGINA (A REAL XPLOTION, NICE!  TO BAD WE DIDN'T FIND U!),    "
              dc.b "AND GREETINGS TO ALL THE PERSONS I RESPECT IN MY LIFE...    BYE FROM TECHWAVE AND KEEP THE TEA!     "

              dc.b "NOW SOME OTHER MEMBERS WILL WRITE SOME... KEEP CALM FOR THE ENGLISH!  "

              dc.b "        NOW IT'S CUTTER, HI I AM ONE OF THE NEW MEMBERS OF "
              dc.b "THE GROUP CALLED INNER CIRCUIT EXPLORERS... "
              dc.b "LET'S BEGIN WITH A IMPORTANT MESSAGE TO ALL "
              dc.b "PEOPLE WHO IS TRAVELLING TO UPPSALA:  "
              dc.b "DON'T BUY ANY OF THE SO CALLED PIZZAS... "
              dc.b "BECAUSE THEY TASTE LIKE SHIT... AND NOW SOME "
              dc.b "PERSONAL GREETINGS AND THEY GO TO:    H TOWN "
              dc.b "(HELLO JEROBI AND ANDERS),  NO CREW (HELLO EVERYBODY "
              dc.b "LOOKING FORWARD TO SEE YOUR MEGADEMO I THINK.),  "
              dc.b "DEMOGRAFICA (HELLO BIG BOSS MAN.. KEEP ON CODING.)    "
              dc.b "THAT'S ALL... THERE WILL BE MORE GREETINGS LATER.   "
              dc.b "AND JUST ONE MORE THING:  I'VE GOT THE IDEA "
              dc.b "TO THE INTRO LOGO BY MY VERY GOOD FRIEND JEROBI "
              dc.b "OF H TOWN.. AND NOW I AM LEAVING...  "
              dc.b "             NOW IS THE CRAZY MEGABRAIN HIMSELF (CODFI) "
              dc.b "WRITING SOME FUCK HERE. BUT DON'T TURN YOUR "
              dc.b "DAMN MACHINE OFF, 'COZ IT WILL ONLY BE A COUPLE OF "
              dc.b "SHORT WORDS.    I WILL USE THIS OPPORTUNITY TO "
              dc.b "THANK NOCOOL AND ZALLIN FOR FOLLOWING ME TO THE "
              dc.b "MEGALEIF CONVENTION. (KEEP MUDDING.)       "
              dc.b "MY OWN CONTRIBUTION TO THE DEMOCOMPETITION ISN'T "
              dc.b "READY YET, SO I MUST LEAVE YOU NOW.  (I WROTE THIS "
              dc.b "IN A ASSEMBLE-PAUSE. MY DEMO TAKES FUCKING 5 MINUTES "
              dc.b "TO ASSEMBLE!!  ON THE OTHER HAND,THE DEMO IS 30 "
              dc.b "MINUTES LONG!!  SO IF YOU DON'T HAVE THE SPACE TALE "
              dc.b "YOU MUST GET IT SOMEHOW. IT IS MUCH COOLER THAN THIS "
              dc.b "SHI... (CENSURED BY TECHWAVE... EAT SHIT CODFI!)  EHHHHH!  (ARF ARF!)       GOODBYE!           "
              dc.b "SURF'S TIME:        THE FUCKING PIZZA TASTED LIKE HELL! "
              dc.b " VISIT KUNGSBACKA SOME DAY AND EAT REALLY GREAT PIZZAS. "
              dc.b " NOW I'VE BEEN WAKEN FOR ABOUT 2 HOURS SO U HAVE TO"
              dc.b " FIGURE OUT HOW FUCKING TIRED I AM. "
              dc.b " ONE THING'S FOR SURE AND THAT'S THAT TECHWAVE IS A"
              dc.b " TIRED AND CRAZY CODER FROM NOW ON.  (THANK U SURF!) "
              dc.b " THIS MESSAGE IS FOR ALL THE PEOPLE IN T.C.A. "
              dc.b " STOP EAT THAT FUCKING CHEESE, ZAK TRY TO SLEEP AND WIZPIT"
              dc.b " (SORRY WIZ THAT WAS EVERYONE IN I.C.E AGAINST ME?)!"
              dc.b " THE GREETZ GOES LIKE THIS:    "
              dc.b " DELTA FORCE, RESPECTABLES, TLB, TCB, ELECTRA, EPA, TEX, ULM,"
              dc.b " OMEGA, SYNC, ELECTRONIC IMAGES (MORE SPX PICS GIZMO),"
              dc.b " SYNERGY, UNIT SEVENTEEN (MAKE MORE DEMOS LIKE DYNAMITE),"
              dc.b " IMAGINA (X-PLOTION IS FUCKING GOOD), ORION, SOTE..."
              dc.b " I ALSO WANT TO GREET A SMALL GROUP CALLED"
              dc.b " ELECTRONICA (YOU SIMON FIX THE LICENSE AND TOM READ THE BOOK).  "
              dc.b "NOW I HAVE TO TAKE A LONG SLEEP BACK TO KUNGSBACKA"
              dc.b "  BYE FROM SURF "
              dc.b "OF THE GREAT I.C.E.!     "
              dc.b " BUY:   MAMBO, HOT TUNA, MAUI, BILLABONG, QUICKSILVER  "
              dc.b "  SORRY BUT I'M ALREADY SLEEPING.        "
              dc.b "BYE FROM A NICE AND ELECTRIC UPPSALA PARTY...       "
              dc.b "          "

              dc.b 0
              even

* 207 lines = 1 gfx-screen...
screen1:      dc.l screen1
              ds.b 230*14+230+(1234)

screen2:      dc.l screen2
              ds.b 8
              ibytes 'A:\SHIT1.IMG'
              ds.b 230*7
              ibytes 'A:\SHIT2.IMG'
              ds.b 230*7
              ibytes 'A:\SHIT3.IMG'
              ds.b 230*7
              ibytes 'A:\SHIT4.IMG'
              ds.b 230*7
              ibytes 'A:\SHIT5.IMG'
              ds.b 230*7
              ibytes 'A:\SHIT6.IMG'
              ds.b 230*7
              ibytes 'A:\SHIT7.IMG'
              ds.b 230*7
              ibytes 'A:\SHIT8.IMG'
              ds.b 230*7
              dc.b " >>>   DEAR CLEVER HACKER... CONTACT ME ON THIS ADDRESS: "
              dc.b "TOBIAS NILSSON 'TECHWAVE OF ICE',   "
              dc.b "KONVALESCENTV. 39,   S-439 33  ONSALA,   SWEDEN!   "
              dc.b "THE DIGITAL WORLD WILL NEVER DIE...   <<< "
              end
