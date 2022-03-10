;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

          .include  "vdimacro.s"

;*------------------------------------------------------------------------
;* Cursor addressable alpha text (VDI escape function 12).
;*------------------------------------------------------------------------

_v_curtext::

          .cargs    #8,.handle.w,.p_str.l
          link      a6,#0

          move.l    .p_str(a6),a0       ;* Get the string pointer.
          jsr       vstr_stack          ;* Go integerize and stack string.
          move.l    sp,a0               ;* Save pointer to intin.

          VContrl   #5,#12,,d0

          lea       -12(sp),sp          ;* -> ptsout, intout, ptsin
          move.l    a0,-(sp)            ;* -> intin
          pea       16(sp)              ;* -> contrl

          jmp       vdicall

          end
