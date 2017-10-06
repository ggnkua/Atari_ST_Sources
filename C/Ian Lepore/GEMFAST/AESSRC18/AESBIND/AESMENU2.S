
;*========================================================================
;*
;* AESFAST Public Domain GEM bindings.
;*
;*========================================================================

          .include  "aesfast.sh"

;*************************************************************************
;*
;* Menu Manager routines 2 of 2.
;*  (This call is isolated because an accessory would use this, but none
;*   of the other menu calls).
;*
;*************************************************************************

;-------------------------------------------------------------------------
; menu_register
;-------------------------------------------------------------------------

_menu_register::
 
          .cargs    #4,.apid,.ptext.l
          AControl  35,1,1,1
          lea       .apid(sp),a1        ; -> intin
          lea       .ptext(sp),a0       ; -> addrin
          ACall     RET2USER

;         end of code

