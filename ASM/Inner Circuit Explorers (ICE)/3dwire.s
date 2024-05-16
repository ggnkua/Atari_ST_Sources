**********************************************************************
* 3D wire vector-graphics!                                           *
* By Tobias Nilsson, "Techwave"                                      *
**********************************************************************
* v1.02
* new lineroute
* wire only

* This route is help from me to Busk:as & Mattis:en! No Fuck Else!
* It shows the tech you can use...

* Use the blitter or the nice CPU to make the lines on Amiga!

* Good luck!   Techwave rules the tea-cup!   Ciao!


* some ST/E code:

              opt O+

* super
                pea       $00.w
                move.w    #$20,-(sp)
                trap      #1
                addq.w    #6,sp

* low
                move.w    #0,-(sp)
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

                jsr       make_xy_tab             ; precalculate x, y tab!


                lea       screen,a0               ; save work-address
                move.l    a0,screen1
                lea       32000(a0),a0
                move.l    a0,screen2


                moveq     #0,d1
                lea       object_points(pc),a0
obj_loop:       cmpa.l    #object_end,a0
                beq.s     ready_now
                move.w    (a0),d0

                lsl.w     #7,d0                   ; enlarge object!

                move.w    d0,(a0)+
                addq.w    #1,d1
                bra.s     obj_loop
ready_now:
                divu      #3,d1
                subq.w    #1,d1
                move.w    d1,num_points           ; number of points -1


**********************************************************************
* interrupt init

i_init:         move.l    $70.w,oldvbl
                move.l    #vbl,$70.w


**********************************************************************
* check keys

wait_vbl:       sf        vbl_cnt
wait_lp:        tst.b     vbl_cnt
                beq.s     wait_lp


                move.w    #$ff,-(sp)
                move.w    #6,-(sp)
                trap      #1
                addq.l    #4,sp

                cmp.b     #"1",d0
                bne.s     no1
                not.b     x_rotate_flg
                bra       key_ready
no1:
                cmp.b     #"2",d0
                bne.s     no2
                not.b     y_rotate_flg
                bra       key_ready
no2:
                cmp.b     #"3",d0
                bne.s     no3
                not.b     z_rotate_flg
                bra       key_ready
no3:


                cmp.b     #"a",d0
                bne.s     no_auto
                not.b     auto_flg
                bra       key_ready
no_auto:

                cmp.b     #"c",d0
                bne.s     no_clr
                not.b     noclr_flg
                bra       key_ready
no_clr:

                cmp.b     #"+",d0
                bne.s     no_inc
                addq.w    #1,x1

                addq.w    #1,counter
                cmpi.w    #360,counter
                blo.s     key_ready
                move.w    #0,counter
                bra.s     key_ready

no_inc:         cmp.b     #"-",d0
                bne.s     no_dec
                subq.w    #1,x1

                subq.w    #1,counter
                bhi.s     key_ready
                move.w    #359,counter
                bra.s     key_ready
no_dec:

                cmp.b     #"(",d0
                bne.s     no_scale
                addq.w    #1,scale_factor
                cmpi.w    #89,scale_factor
                blo.s     key_ready
                move.w    #89,scale_factor
                bra.s     key_ready
no_scale:
                cmp.b     #")",d0
                bne.s     no_scale2
                subq.w    #1,scale_factor
                bhi.s     key_ready
                move.w    #0,scale_factor
                bra.s     key_ready
no_scale2:

                cmp.b     #" ",d0
                bne.s     key_ready
                jmp       back
key_ready:


                bsr.s     independent_route

                not.w     $ffff8240.w
                move.w    #0,$ffff8240.w

                bra       wait_vbl


x1:           dc.w 0

vbl_cnt:      dc.b 0
noclr_flg:    dc.b 0

auto_flg:     dc.b 0
x_rotate_flg: dc.b 0
y_rotate_flg: dc.b 0
z_rotate_flg: dc.b 0

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

;                lea       pal(pc),a0
;                lea       $ffff8242.w,a1
;              rept 8
;                move.l    (a0)+,(a1)+
;              endr


                addq.b    #1,vbl_cnt
                movem.l   (sp)+,d0-a6
                rte

;pal:
;              dc.w $0,$04,$0c,$05,$0d,$06,$0e,$07,$0f,$088f,$011f,$099f,$022f,$0aaf,$033f,$0bbf

**********************************************************************
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

                move.w    #$0300,$ffff8240.w
                bsr       calc3d_main
                move.w    #$30,$ffff8240.w
                bsr       drawline_main

                not.w     $ffff8240.w
                not.w     $ffff8240.w



                movea.l   screen1(pc),a0
                move.w    #$8000,(a0)
                move.w    #$01,152(a0)
                move.w    #$8000,160*199(a0)
                move.w    #$01,160*199+152(a0)
                move.w    #$8000,160*99(a0)
                move.w    #$01,160*99+152(a0)

                tst.b     x_rotate_flg
                beq.s     shit1
                move.w    counter(pc),x_rotate_angle
shit1:
                tst.b     y_rotate_flg
                beq.s     shit2
                move.w    counter(pc),y_rotate_angle
shit2:
                tst.b     z_rotate_flg
                beq.s     shit3
                move.w    counter(pc),z_rotate_angle
shit3:

                tst.b     auto_flg
                beq.s     fuck
                addq.w    #1,counter
                cmpi.w    #360,counter
                blo.s     fuck
                move.w    #0,counter
fuck:

                move.l    screen1(pc),d0          ; switch screens
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
                move.w    #$ffff,$ffff8a28.w      ; msk1
                move.w    #$ffff,$ffff8a2c.w      ; msk3


                move.w    #8,$ffff8a2e.w          ; des xinc
                move.w    #0,$ffff8a30.w          ; des yinc
                move.l    a1,$ffff8a32.w          ; des addr

                move.b    #1,$ffff8a3a.w          ; hop
                move.b    #0,$ffff8a3b.w          ; op

                move.w    #20*200-1,$ffff8a36.w   ; x cnt
                move.w    #1,$ffff8a38.w          ; y cnt
                move.b    #%11000000,$ffff8a3c.w  ; busy


                addq.w    #2,a1
                move.l    a1,$ffff8a32.w          ; des addr
                move.w    #20*200-1,$ffff8a36.w   ; x cnt
                move.w    #1,$ffff8a38.w          ; y cnt
                move.b    #%11000000,$ffff8a3c.w  ; busy

                rts

**********************************************************************
**********************************************************************
**********************************************************************
**********************************************************************
* (radians = 180/grader...)

calc3d_main:

                lea       object_points(pc),a0    ; src
                lea       points_buffer(pc),a1    ; dest

                lea       sin_tab(pc),a2          ; sin
                lea       180(a2),a3              ; cos

                movea.w   x_rotate_angle(pc),a4
                adda.w    a4,a4                   ; * 2 (for sin_tab)
                movea.w   y_rotate_angle(pc),a5
                adda.w    a5,a5                   ; * 2 (for sin_tab)
                movea.w   z_rotate_angle(pc),a6
                adda.w    a6,a6                   ; * 2 (for sin_tab)

                bsr       zxy_rotate
                bsr       projection
                bsr       scaling

                rts


* --------------------------------------------------------------------
drawline_main:

                lea       points_buffer(pc),a0
                lea       con_points(pc),a1
                move.w    #160,d4                 ; for centration...
                moveq     #100,d5
line_loop:

                move.w    (a1)+,d6
                bmi.s     end_of_lines

                mulu      #6,d6                   ; so many bytes...
                move.w    0(a0,d6.w),d0
                move.w    2(a0,d6.w),d1


;                cmpi.w    #0,4(a0,d6.w)
;                bpl.s     bit_pl
;                move.w    #2,bitplane
;                bra.s     next
;bit_pl:         move.w    #0,bitplane

next:
                move.w    (a1)+,d6
                mulu      #6,d6                   ; so many bytes...
                move.w    0(a0,d6.w),d2
                move.w    2(a0,d6.w),d3
;                cmpi.w    #0,4(a0,d6.w)
;                bpl.s     lines_out
;                move.w    #2,bitplane
;lines_out:

                add.w     d4,d0
                add.w     d5,d1
                add.w     d4,d2
                add.w     d5,d3

                movem.l   d0-a6,-(sp)

                movea.w   d0,a2
                movea.w   d1,a3
                bsr       clip_and_draw           ; 2 bpls used! (bitplane!)

                movem.l   (sp)+,d0-a6
                bra.s     line_loop

end_of_lines:   rts


bitplane:     dc.w 0
              even


**********************************************************************
**********************************************************************
**********************************************************************
* a4-a6 = x-z rotate
rot_lp_cnt:   dc.w 0

zxy_rotate:
                move.w    num_points(pc),rot_lp_cnt
rotate_lp:
* d4, d5, d6
                movem.w   (a0)+,d4-d6             ; get x, y, z


                move.w    d4,d0                   ; get x
                move.w    d0,d1
                move.w    0(a2,a6.w),d7           ; get sin value
                muls      d7,d0                   ; x * sin

                move.w    d5,d2                   ; get y
                move.w    d2,d3
                muls      d7,d2                   ; y * sin

                move.w    0(a3,a6.w),d7           ; get cos value
                muls      d7,d1                   ; x * cos
                muls      d7,d3                   ; y * cos

; d0= x sin  d1= x cos | d2= y sin  d3= y cos

                sub.l     d2,d1                   ; xr = x cos - y sin
                add.l     d0,d3                   ; yr = y cos + x sin

                swap      d1                      ; going to /16384
                rol.l     #2,d1
                swap      d3
                rol.l     #2,d3

                move.w    d1,d4                   ; save x

**********************************************************************
* (d1=x  d3=y)
* d4=x rotate

                move.w    d3,d0                   ; y
                move.w    d0,d1
                move.w    0(a2,a4.w),d7           ; get sin value
                muls      d7,d0                   ; y * sin

                move.w    d6,d2                   ; get z
                move.w    d2,d3
                muls      d7,d2                   ; z * sin

                move.w    0(a3,a4.w),d7           ; get cos value
                muls      d7,d1                   ; y * cos
                muls      d7,d3                   ; z * cos

; d0= y sin  d1= y cos | d2= z sin  d3= z cos

                add.l     d2,d1                   ; yr = y cos + z sin
                sub.l     d0,d3                   ; zr = z cos - y sin

                swap      d1                      ; going to /16384
                rol.l     #2,d1
                swap      d3
                rol.l     #2,d3

                move.w    d1,d5                   ; save y

**********************************************************************
* (d1=y  d3=z)
* d5=y rotate

                move.w    d4,d0                   ; get x
                move.w    d0,d1
                move.w    0(a2,a5.w),d7           ; get sin value
                muls      d7,d0                   ; x * sin

                move.w    d3,d2                   ; get z
                muls      d7,d2                   ; z * sin

                move.w    0(a3,a5.w),d7           ; get cos value
                muls      d7,d1                   ; x * cos
                muls      d7,d3                   ; z * cos

; d0= x sin  d1= x cos | d2= z sin  d3= z cos

                sub.l     d2,d1                   ; xr = x cos - z sin
                add.l     d0,d3                   ; zr = z cos + x sin

                swap      d1                      ; going to /16384
                rol.l     #2,d1
                swap      d3
                rol.l     #2,d3

* --------------------------------------------------------------------
                move.w    d1,(a1)+                ; save x
                move.w    d5,(a1)+                ; save y
                move.w    d3,(a1)+                ; save z

                subq.w    #1,rot_lp_cnt
                bpl.s     rotate_lp
                rts

**********************************************************************
**********************************************************************
**********************************************************************
* not finished!

projection:
                lea       points_buffer(pc),a0
                movea.l   a0,a1
                lea       projection_tab(pc),a2
;                lea       sin_tab(pc),a2

                move.w    num_points(pc),d6
proj_it:
                move.w    (a0)+,d0                ; x
                move.w    (a0)+,d1                ; y
                move.w    (a0)+,d2                ; z

;                asr.w     #1,d0
;                asr.w     #1,d1
;                asr.w     #1,d2


                asr.w     #7,d2                   ; !
                add.w     #90,d2                  ; no minus...

                bclr      #0,d2
                move.w    0(a2,d2.w),d7           ; get sin value

                sub.w     #16384*1,d7
                lsr.w     #1,d7


                muls      d7,d0
                muls      d7,d1

                swap      d0                      ; going to /16384
                rol.l     #2,d0                   ; check it!!!!!! Nice!
                swap      d1
                rol.l     #2,d1

                move.w    d0,(a1)+
                move.w    d1,(a1)+
                addq.w    #2,a1

                dbra      d6,proj_it
                rts

**********************************************************************
**********************************************************************
scaling:
                lea       points_buffer(pc),a0
                movea.l   a0,a1
                lea       neg_sin_tab(pc),a2

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
                rts

scale_factor: dc.w 89-10

**********************************************************************
**********************************************************************
**********************************************************************
**********************************************************************
num_points:   dc.w 0


counter:      dc.w 0

points_buffer:ds.w 40*3

x_rotate_angle:dc.w 0
y_rotate_angle:dc.w 0
z_rotate_angle:dc.w 0

**********************************************************************
* 0 = love making point...
* x, y, z

object_points:

;              dc.w -80,-80,0
;              dc.w 80,-80,0
;              dc.w 80,80,0
;              dc.w -80,80,0


              dc.w -80,-60,0
              dc.w -80,-40,0
              dc.w -80,-20,0
              dc.w -80,0,0
              dc.w -80,20,0
              dc.w -80,40,0
              dc.w -80,60,0

              dc.w 80,-60,0
              dc.w 80,-40,0
              dc.w 80,-20,0
              dc.w 80,0,0
              dc.w 80,20,0
              dc.w 80,40,0
              dc.w 80,60,0



              dc.w -60,-80,0
              dc.w -40,-80,0
              dc.w -20,-80,0
              dc.w 0,-80,0
              dc.w 20,-80,0
              dc.w 40,-80,0
              dc.w 60,-80,0

              dc.w -60,80,0
              dc.w -40,80,0
              dc.w -20,80,0
              dc.w 0,80,0
              dc.w 20,80,0
              dc.w 40,80,0
              dc.w 60,80,0

object_end:

con_points:
;              dc.w 0,1,1,2,2,3,3,0

              dc.w 4,4+7
              dc.w 5,5+7
              dc.w 6,6+7
              dc.w 7,7+7
              dc.w 8,8+7
              dc.w 9,9+7
              dc.w 10,10+7

              dc.w 4+14,4+14+7
              dc.w 5+14,5+14+7
              dc.w 6+14,6+14+7
              dc.w 7+14,7+14+7
              dc.w 8+14,8+14+7
              dc.w 9+14,9+14+7
              dc.w 10+14,10+14+7

              dc.w -1


**********************************************************************

sin_tab:

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

              ds.w 1000                       ; <<<<<<<<<<

**********************************************************************
**********************************************************************
* Cohen-Sutherland clipping...
**********************************************************************
* d2,d3  a2,a3


clip_and_draw:

                move.w    d2,d6
                move.w    d3,d7
                bsr       rel_pos
                move.w    d1,code1
                move.w    a2,d6
                move.w    a3,d7
                bsr       rel_pos
                move.w    d1,code2
                tst.w     d1
                bne.s     test_win1
                tst.w     code1
;                beq.s     draw_it
                bne.s     test_win1               ; <<<<<<<

                move.w    d2,leftx
                move.w    d3,lefty
                move.w    a2,rightx
                move.w    a3,righty
                bra       draw_it

test_win1:

                move.w    d1,d0
                and.w     code1(pc),d0
                bne       no_draw
                movea.w   d2,a0
                movea.w   d3,a1
                movea.w   a2,a4
                movea.w   a3,a5

                tst.w     code2
                bne.s     test_win2
                move.w    a2,rightx
                move.w    a3,righty
                bra.s     test_win3


test_win2:      move.w    code1(pc),p1code
                move.w    code2(pc),p2code
                bsr       fnd_point
                tst.w     p1code
                bne.s     no_draw

                move.w    d2,rightx
                move.w    d3,righty

test_win3:      move.w    a4,d2
                move.w    a5,d3
                movea.w   a0,a2
                movea.w   a1,a3
                move.w    code2(pc),p1code
                move.w    code1(pc),p2code

                tst.w     p2code
                bne.s     test_win4
                move.w    a2,leftx
                move.w    a3,lefty
                bra.s     draw_it

test_win4:      bsr.s     fnd_point
                move.w    d2,leftx
                move.w    d3,lefty

draw_it:

                move.w    leftx(pc),d0
                move.w    lefty(pc),d1
                move.w    rightx(pc),d2
                move.w    righty(pc),d3
                bra       draw_line               ; draw line...

no_draw:        rts

* --------------------------------------------------------------------
* d6=x, d7=y... make point relative to clip window...

rel_pos:
                moveq     #0,d1
                move.w    d7,d1
                sub.w     clip_y_low(pc),d1
                add.l     d1,d1                   ; .l

                move.w    d7,d1
                sub.w     clip_y_hig(pc),d1
                neg.w     d1
                add.l     d1,d1

                move.w    d6,d1
                sub.w     clip_x_hig(pc),d1
                neg.w     d1
                add.l     d1,d1

                move.w    d6,d1
                sub.w     clip_x_low(pc),d1
                add.l     d1,d1

                swap      d1
                rts


clip_x_low:   dc.w 0
clip_y_low:   dc.w 0
clip_x_hig:   dc.w 319
clip_y_hig:   dc.w 199

* --------------------------------------------------------------------
* Finds the intersect point...

fnd_point:
                move.w    d2,d4                   ; find the center point...
                add.w     a2,d4                   ; ( x1 + x2 ) / 2
                ext.l     d4
                lsr.l     #1,d4

                move.w    d3,d5
                add.w     a3,d5                   ; & other...
                ext.l     d5
                lsr.l     #1,d5

                move.w    d4,d6
                move.w    d5,d7
                bsr.s     rel_pos

                move.w    p2code(pc),d6
                and.w     d1,d6
                bne.s     f_other

                cmp.w     d4,d2
                bne.s     findw1
                cmp.w     d5,d3
                beq.s     f_endit                 ; stop?

findw1:         cmpa.w    d4,a2                   ; do middle & sec. point
                bne.s     findw2                  ; match ?
                cmpa.w    d5,a3
                beq.s     f_endit                 ; stop?

findw2:         move.w    d4,d2                   ; else exchange points
                move.w    d5,d3
                move.w    d1,p1code
                bra.s     fnd_point               ; & start again

f_other:        cmpa.w    d4,a2
                bne.s     f_other1
                cmpa.w    d5,a3
                beq.s     f_endit

f_other1:       cmp.w     d4,d2
                bne.s     f_other2
                cmp.w     d5,d3
                beq.s     f_endit

f_other2:       tst.w     p1code
                beq.s     f_other3
                move.w    d1,d7
                and.w     p1code(pc),d7
                bne.s     f_exit

f_other3:       movea.w   d4,a2
                movea.w   d5,a3
                move.w    d1,p2code
                bra.s     fnd_point

f_exit:         move.w    #1,p1code               ; inform route of terminat...
f_endit:        rts

* --------------------------------------------------------------------
code1:        dc.w 0
code2:        dc.w 0
p1code:       dc.w 0
p2code:       dc.w 0

leftx:        dc.w 0
lefty:        dc.w 0
rightx:       dc.w 0
righty:       dc.w 0


**********************************************************************
**********************************************************************
* Superfast line-draw...  v1.12... Realtime calcs!                   *
* By Tobias Nilsson, "Techwave"                                      *
**********************************************************************
**********************************************************************
* Using d0-d6/a0-a3
* d0=x1  d1=y1 , d2=x2  d3=y2

draw_line:


* haha... nothing here!

                rts




**********************************************************************
**********************************************************************
**********************************************************************
**********************************************************************
* some variables


x_add_rel:
              dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
              rept 19
              dc.w 8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
              endr


* .l (scrnoff, pixel)
x_add_tab:    ds.b 1280

* .w (lineoffset)
y_add_tab:    ds.b 400

screen1:      dc.l 0
screen2:      dc.l 0



**********************************************************************
**********************************************************************
**********************************************************************
**********************************************************************
* this is for the line-shit... erase it!

make_xy_tab:
                lea       x_add_tab(pc),a0

                moveq     #0,d0
                move.w    #$8000,d1
                moveq     #20-1,d7
words:
              rept 16
                move.w    d0,(a0)+                ; word!
                move.w    d1,(a0)+                ; rotate!
                ror.w     #1,d1
              endr

                addq.w    #8,d0
                dbra      d7,words


* make_y_tab
                lea       y_add_tab(pc),a0

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
