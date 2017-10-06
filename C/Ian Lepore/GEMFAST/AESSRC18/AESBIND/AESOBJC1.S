
;*========================================================================
;*
;* AESFAST Public Domain GEM bindings.
;*
;*========================================================================

        .include        "aesfast.sh"
          
;*************************************************************************
;*
;* Object Library routines 1 of 2.
;*
;*************************************************************************

;-------------------------------------------------------------------------
; objc_add
; objc_delete
; objc_draw
; objc_find
; objc_order
; objc_change
;-------------------------------------------------------------------------

_objc_add::
          AControl  40,2,1,1
          bra.s     objc_do
_objc_delete::
          AControl  41,1,1,1
          bra.s     objc_do
_objc_draw::
          AControl  42,6,1,1
          bra.s     objc_do
_objc_find::
          AControl  43,4,1,1
          bra.s     objc_do
_objc_order::
          AControl  45,2,1,1
          bra.s     objc_do
_objc_change::
          AControl  47,8,1,1
objc_do:
          .cargs    #4,.ptree.l,.intin
          lea       .intin(sp),a1       ; -> intin
          lea       .ptree(sp),a0       ; -> addrin
          ACall     RET2USER

;         end of source

