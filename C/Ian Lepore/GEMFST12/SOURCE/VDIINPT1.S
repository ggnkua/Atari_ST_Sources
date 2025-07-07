
;*========================================================================
;*
;* VDIFAST Public Domain VDI bindings.
;*
;*========================================================================

          .iif      !(^^macdef VContrl),.include  "vdimacro.s"
          
;*************************************************************************
;*
;* Commonly-used input functions. 
;*  Mouse- and keyboard-related functions.
;*
;*************************************************************************

;*------------------------------------------------------------------------
;* Set mouse form.
;*------------------------------------------------------------------------

_vsc_form::
          .cargs    #8,.handle.w,.pform.l
          link      a6,#0

          VContrl   #111,,,#37
          
          lea       -12(sp),sp
          move.l    .pform(a6),-(sp)    ;* -> intin
          pea       16(sp)              ;* -> contrl

          jmp       vdicall
          
;*------------------------------------------------------------------------
;* Show cursor.
;*------------------------------------------------------------------------

_v_show_c::
          .cargs    #8,.handle.w,.reset.w
          link      a6,#0

          VContrl   #122,,,#1
          
          lea       -12(sp),sp
          pea       .reset(a6)          ;* -> intin
          pea       16(sp)              ;* -> contrl

          jmp       vdicall
          
;*------------------------------------------------------------------------
;* Hide cursor.
;*------------------------------------------------------------------------

_v_hide_c::
          .cargs    #8,.handle.w
          link      a6,#0

          VContrl   #123
          
          pea       (sp)              ;* -> contrl

          jmp       vdicall

;*------------------------------------------------------------------------
;* Sample mouse button state.
;*------------------------------------------------------------------------

_vq_mouse::
          .cargs    #8,.handle.w,.status.l,.x.l,.y.l
          link      a6,#-4              ;* Allocate ptsout[2].

          VContrl   #124
          
          pea       -4(a6)              ;* -> ptsout
          move.l    .status(a6),-(sp)   ;* -> intout
          subq.l    #8,sp
          pea       16(sp)              ;* -> contrl

          moveq.l   #$73,d0
          move.l    sp,d1
          trap      #2

          move.l    .x(a6),a0           ;* Return mouse x
          move.w    -4(a6),(a0)         ;* from ptsout[0].
          move.l    .y(a6),a0           ;* Return mouse y
          move.w    -2(a6),(a0)         ;* from ptsout[1].

          unlk      a6
          rts
  
;*------------------------------------------------------------------------
;* Sample keyboard state.
;*------------------------------------------------------------------------

_vq_key_s::
          .cargs    #8,.handle.w,.status.l
          link      a6,#0
          
          VContrl   #128
          
          subq.l    #4,sp               ;* -> ptsout
          move.l    .status(a6),-(sp)   ;* -> intout
          subq.l    #8,sp               ;* -> ptsin
          pea       16(sp)              ;* -> contrl

          jmp       vdicall
          
;*         end of code.

