
;*========================================================================
;*
;* AESFAST Public Domain GEM bindings.
;*
;*  04/05/89 -  v1.2
;*              Finally received confirmation for the proper definitions 
;*              of shel_get/shel_put.  The (incorrect) definition of
;*              shel_get() was removed from aesshel1.s and defined 
;*              properly here.
;*========================================================================

          .include  "aesfast.sh"
          
;*************************************************************************
;*
;* Shell library routines 2 of 2.
;*  These two routines are mostly likely to be used by a desk accessory
;*  functioning as a replacement for the control panel, so they are
;*  isolated from the other shell functions.
;*************************************************************************

;-------------------------------------------------------------------------
; shel_get
; shel_put
;-------------------------------------------------------------------------

_shel_get::
          AControl  122,1,1,1
          bra.s     shel_getput
_shel_put::
          AControl  123,1,1,1
shel_getput:
          .cargs    #4,.bufptr.l,.buflen.w
          lea       .bufptr(sp),a0    ; -> addrin
          lea       .buflen(sp),a1    ; -> intin
          ACall     RET2USER
          
;         end of code

