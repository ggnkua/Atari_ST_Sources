
;*========================================================================
;*
;* VDIFAST Public Domain VDI bindings.
;*
;*========================================================================
          
          .iif      !(^^macdef VContrl),.include  "vdimacro.s"
          
;*************************************************************************
;*
;* Commonly-used output functions.
;*
;*************************************************************************

;*------------------------------------------------------------------------
;*-----------------------------------------------------------------------
;* vout_pxy.
;*  For VDI output calls that use only count and/or pxyarray.
;*  Entry: d0.w = function number.
;*         d1.w = subfunction number.
;*         d2.w = number of points in ptsin.
;*         a0.l-> ptsin array
;*-----------------------------------------------------------------------
;*------------------------------------------------------------------------

vout_pxy:

          .cargs    #8,.handle.w
          link      a6,#0

          VContrl   d0,d1,d2

          subq.l    #8,sp               ;* -> ptsout
          move.l    a0,-(sp)            ;* -> ptsin
          subq.l    #4,sp               ;* -> intin
          pea       16(sp)              ;* -> contrl

          jmp       vdicall
          
;*------------------------------------------------------------------------
;* Polyline.
;*------------------------------------------------------------------------

_v_pline::
          .cargs    #4,.handle.w,.count.w,.pxy.l
          
          moveq.l   #6,d0
          moveq.l   #0,d1
          move.w    .count(sp),d2
          move.l    .pxy(sp),a0
          bra       vout_pxy

;*------------------------------------------------------------------------
;* Polymarker. 
;*------------------------------------------------------------------------

_v_pmarker::
          .cargs    #4,.handle.w,.count.w,.pxy.l

          moveq.l   #7,d0
          moveq.l   #0,d1
          move.w    .count(sp),d2
          move.l    .pxy(sp),a0
          bra       vout_pxy
          
;*------------------------------------------------------------------------
;* Filled area. 
;*------------------------------------------------------------------------

_v_fillarea::
          .cargs    #4,.handle.w,.count.w,.pxy.l
          
          moveq.l   #9,d0
          moveq.l   #0,d1
          move.w    .count(sp),d2
          move.l    .pxy(sp),a0
          bra       vout_pxy
          
;*------------------------------------------------------------------------
;* Bar.
;*------------------------------------------------------------------------

_v_bar::
          .cargs    #4,.handle.w,.pxy.l
          moveq.l   #11,d0
          moveq.l   #1,d1
          moveq.l   #2,d2
          move.l    .pxy(sp),a0
          bra       vout_pxy

;*------------------------------------------------------------------------
;* Rounded and filled rounded rectangle.
;*------------------------------------------------------------------------

_v_rbox::
          .cargs    #4,.handle.w,.pxy.l
          moveq.l   #11,d0
          moveq.l   #8,d1
          moveq.l   #2,d2
          move.l    .pxy(sp),a0
          bra       vout_pxy
_v_rfbox::
          .cargs    #4,.handle.w,.pxy.l
          moveq.l   #11,d0
          moveq.l   #9,d1
          moveq.l   #2,d2
          move.l    .pxy(sp),a0
          bra       vout_pxy

;*------------------------------------------------------------------------
;* Filled rectangle.
;*------------------------------------------------------------------------

_vr_recfl::
          .cargs    #4,.handle.w,.pxy.l
          moveq.l   #114,d0
          moveq.l   #0,d1
          moveq.l   #2,d2
          move.l    .pxy(sp),a0
          bra       vout_pxy

;*------------------------------------------------------------------------
;* Circle.
;*------------------------------------------------------------------------

_v_circle::
          .cargs    #8,.handle.w,.x.w,.y.w,.radius.w
          link      a6,#0
          
          clr.w     -(sp)               ;* There are some holes in the
          move.w    .radius(a6),-(sp)   ;* pstin definitions for circle,
          clr.l     -(sp)               ;* so build a temporary ptsin on
          move.l    .x(a6),-(sp)        ;* the stack.
          move.l    sp,a0               ;* Save a pointer to ptsin.

          VContrl   #11,#4,#3

          subq.l    #8,sp               ;* -> ptsout
          move.l    a0,-(sp)            ;* -> ptsin
          subq.l    #4,sp               ;* -> intin
          pea       16(sp)              ;* -> contrl

          jmp       vdicall

;         end of code

