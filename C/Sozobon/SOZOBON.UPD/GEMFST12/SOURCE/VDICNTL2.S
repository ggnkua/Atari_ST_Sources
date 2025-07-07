
;*========================================================================
;*
;* VDIFAST Public Domain VDI bindings.
;*
;*========================================================================

          .iif      !(^^macdef VContrl),.include  "vdimacro.s"
          
;*************************************************************************
;*
;* Rarely-used control functions.
;*
;*************************************************************************

;*------------------------------------------------------------------------
;* Load fonts.
;*------------------------------------------------------------------------

_vst_load_fonts::
          .cargs    #8,.handle.w,.select.w
          link      a6,#-2
          
          VContrl   #119,,,#1
          
          clr.l     -(sp)               ;* -> ptsout
          pea       -2(a6)              ;* -> intout
          clr.l     -(sp)               ;* -> ptsin
          pea       .select(a6)         ;* -> intin
          pea       16(sp)              ;* -> contrl

          jmp       vdicall
          
;*------------------------------------------------------------------------
;* Unload fonts.
;*------------------------------------------------------------------------

_vst_unload_fonts::
          .cargs    #8,.handle.w,.select.w
          link      a6,#-2

          VContrl   #120,,,#1
          
          clr.l     -(sp)               ;* -> ptsout
          pea       -2(a6)              ;* -> intout
          clr.l     -(sp)               ;* -> ptsin
          pea       .select(a6)         ;* -> intin
          pea       16(sp)              ;* -> intin
          
          jmp       vdicall
                    
;*         end of code
