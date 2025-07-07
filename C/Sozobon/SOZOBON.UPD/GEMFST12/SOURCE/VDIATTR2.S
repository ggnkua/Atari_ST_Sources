
;*========================================================================
;*
;* VDIFAST VDI bindings.
;* Copyright (c) Nov 1988, by Ian Lepore.
;* See full copyright statement in file VDI@NOTE.S for details.
;*
;*========================================================================

          .iif      !(^^macdef VContrl),.include  "vdimacro.s"
                    
;*************************************************************************
;*
;* Attribute functions 2.
;*  Polyline- and polymarker-related stuff.
;*
;*  _vsl_width        - Set polyline width.
;*  _vsl_ends         - Set polyline end types.  
;*  _vsm_height       - Set polymarker height.  
;*
;*************************************************************************

;*------------------------------------------------------------------------
;* Set polyline width.
;*------------------------------------------------------------------------

_vsl_width::
          .cargs    #8,.handle.w,.width.w
          link      a6,#-4              ;* Allocate ptsout[2].
          
          clr.w     -(sp)               ;* ptsin[1] = 0
          move.w    .width(a6),-(sp)    ;* ptsin[0] = width
          move.l    sp,a0               ;* Save a pointer to ptsin.

          VContrl   #16,,#1

          pea       -4(a6)              ;* -> ptsout
          subq.l    #4,sp               ;* -> intout
          move.l    a0,-(sp)            ;* -> ptsin
          subq.l    #4,sp               ;* -> intin
          pea       16(sp)              ;* -> contrl

          moveq.l   #$73,d0
          move.l    sp,d1
          trap      #2
          move.w    -4(a6),d0           ;* Return ptsout[0].
          unlk      a6
          rts

;*------------------------------------------------------------------------
;* Set polyline end styles.
;*------------------------------------------------------------------------

_vsl_ends::
          .cargs    #8,.handle.w,.begstyle.w,.endstyle.w
          link      a6,#0
          
          VContrl   #108,,,#2
          
          lea       -12(sp),sp          ;* -> ptsin
          pea       .begstyle(a6)       ;* -> intin
          pea       16(sp)              ;* -> contrl

          jmp       vdicall
          
;*------------------------------------------------------------------------
;* Set polymarker height.
;*------------------------------------------------------------------------

_vsm_height::
          .cargs    #8,.handle.w,.height.w
          link      a6,#-4              ;* Allocate ptsout[2].
          
          move.w    .height(a6),-(sp)   ;* ptsin[1] = height.
          clr.w     -(sp)               ;* ptsin[0] = 0.
          move.l    sp,a0

          VContrl   #16,,#1

          pea       -4(a6)              ;* -> ptsout
          subq.l    #4,sp               ;* -> intout
          move.l    a0,-(sp)            ;* -> ptsin
          subq.l    #4,sp               ;* -> intin
          pea       16(sp)              ;* -> contrl

          jmp       vdicall             ;* Do it, return ptsout[1].
          
;*         end of code
