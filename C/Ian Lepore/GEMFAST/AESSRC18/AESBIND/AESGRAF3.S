
;*========================================================================
;*
;* AESFAST Public Domain GEM bindings.
;*
;*========================================================================

          .include  "aesfast.sh"
          
;*************************************************************************
;*
;* Graphics Library routines 3 of 5.
;*
;*************************************************************************

;-------------------------------------------------------------------------
; graf_movebox  (book lists this as 'movebox', Alcyon bindings have 'mbox').
; graf_growbox
; graf_shrinkbox
;-------------------------------------------------------------------------

_graf_mbox::
          AControl  72,6,1,0
          bra.s     graf_gbox
_graf_growbox::
          AControl  73,8,1,0
          bra.s     graf_gbox
_graf_shrinkbox::
          AControl  74,8,1,0
graf_gbox:
          .cargs    #4,.intin
          lea       .intin(sp),a1
          ACall     RET2USER

;         end of code

