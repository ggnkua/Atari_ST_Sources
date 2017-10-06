;*************************************************************************
;* RCADJUST.S - Adjust a VRECT or GRECT rectangle to a new size.
;*************************************************************************

_rc_gadjust::

          moveq.l   #1,d2               ; Set GRECT-flag.
          bra.s     adjust              ; Continue below.
          
_rc_vadjust::

          moveq.l   #0,d2               ; Clear GRECT-flag.

adjust:                                 ; Common code...

          .cargs    #4,.prect.l,.hadj,.vadj
          
          move.l    .prect(sp),a0       ; Get rectangle pointer.
          move.l    a0,a1               ; save for return value
          move.w    .hadj(sp),d0        ; Get x-axis adjustment.
          move.w    .vadj(sp),d1        ; Get y-axis adjustment.

          sub.w     d0,(a0)             ; Adjust g_x (or v_x1).
          bpl.s     .notneg1            ; If adjusted value is negative,
          clr.w     (a0)                ; force it back to zero.
.notneg1:
          addq.l    #2,a0
          sub.w     d1,(a0)             ; Adjust g_y (or v_y1).
          bpl.s     .notneg2            ; If adjusted value is negative,
          clr.w     (a0)                ; force it back to zero.
.notneg2:
          addq.l    #2,a0
          
          tst.w     d2                  ; Test GRECT flag.
          beq.s     .no_double          ; Skip doubling if VRECT.

          add.w     d0,d0               ; For GRECTs we have to double the
          add.w     d1,d1               ; adjustment to width & height.
.no_double:
          add.w     d0,(a0)             ; Adjust g_w (or v_x2).
          bgt.s     .notneg3            ; If adjusted value is <= 0,
          move.w    #1,(a0)             ; force it back to one.
.notneg3:
          addq.l    #2,a0
          add.w     d1,(a0)             ; Adjust g_h (or v_y2).
          bgt.s     .notneg4            ; If adjusted value is <= 0,
          move.w   #1,(a0)              ; force it back to one.
.notneg4:
          move.l    a1,d0               ; return prect
          rts                           ; Return.
                
;         end of code

