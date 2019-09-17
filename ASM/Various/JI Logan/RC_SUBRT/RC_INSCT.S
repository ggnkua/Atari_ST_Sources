* Clips one AES rectangle ("variable") against another ("fixed")
* ENTRY  a0 contains address of array of variable rectangle
*        a1 contains address of array of fixed rectangle
*        (can use the macro rc_insct to load a0 and a1)
* EXIT   If the rectangles overlapped, d0.w = 0 and the a0 rectangle array
*          contains the overlap coordinates. Rectangle array a1 is unchanged
*        If the rectangles did not overlap, d0.w = -1 and a0 rectangle array
*          and a1 rectangle array are unchanged


rc_insct    macro       variable array,fixed array
            lea         \1,a0
            lea         \2,a1
            bsr         rc_insct.sr
            endm

* example of array of 4 words describing AES rectangle
clp_x       ds.w       1       * clip rectangle
clp_y       ds.w       1       *
clp_w       ds.w       1       *
clp_h       ds.w       1       *

rc_insct.sr movem.w     d1-3,-(a7)
rc_int_x    move.w      (a0),d0       var_x
            move.w      (a1),d1       fix_x
            cmp.w       d1,d0         var_x - fix_x
            bge         rc_int_y      bra if var_x >= fix_x
            move.w      d1,d0         fix_x -> d0
rc_int_y    move.w      2(a0),d1      var_y
            move.w      2(a1),d2      fix_y
            cmp.w       d2,d1         var_y - fix_y
            bge         rc_int_xw     bra if var_y >= fix_y
            move.w      d2,d1         fix_y -> d1
rc_int_xw   move.w      (a0),d2       var_x
            add.w       4(a0),d2      var_x + var_w
            move.w      (a1),d3       fix_x
            add.w       4(a1),d3      fix_x + fix_w
            cmp.w       d3,d2         var_xw - fix_xw
            ble         rc_int_yh     bra if var_xw <= fix_xw
            move.w      d3,d2         fix_xw -> d2
rc_int_yh   move.w      2(a0),d3      var_y
            add.w       6(a0),d3      var_y + var_h
            move.w      2(a1),d4      fix_y
            add.w       6(a1),d4      fix_y + fix_h
            cmp.w       d4,d3         var_yh - fix_yh
            ble         rc_tst_int    bra if var-yh <= fix_yh
            move.w      d4,d3         fix_yh -> d3
rc_tst_int  sub.w       d0,d2         clipped_w in d2
            ble         rc_no_int     bra if clipped_w <= zero
            sub.w       d1,d3         clipped_h in d3
            ble         rc_no_int     bra if clipped_h <= zero
            movem.w     d0-3,(a0)     store result
            movem.w     (a7)+,d1-3
            move.w      #0,d0         flag intersect clipped
            rts
rc_no_int   movem.w     (a7)+,d1-3
            move.w      #-1,d0     flag no intersect
            rts

