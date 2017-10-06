
;*========================================================================
;*
;* AESFAST Public Domain GEM bindings.
;*
;*========================================================================

          .include  "aesfast.sh"
          
;*************************************************************************
;*
;* Application manager functions 2 of 2.
;*
;*************************************************************************

;-------------------------------------------------------------------------
; appl_read
; appl_write
;-------------------------------------------------------------------------

_appl_read::
          AControl  11,2,1,1
          bra.s     appl_rw
_appl_write::
          AControl  12,2,1,1
appl_rw:
          .cargs    #4,.id.w,.len.w,.pbuf.l
          lea       .id(sp),a1          ; -> intin
          lea       .pbuf(sp),a0        ; -> adrin
          ACall     RET2USER
           
;-------------------------------------------------------------------------
; appl_find
;-------------------------------------------------------------------------

_appl_find::
          .cargs    #4,.pname.l
          AControl  13,0,1,1
          lea       .pname(sp),a0       ; -> addrin
          ACall     RET2USER
          
;-------------------------------------------------------------------------
; appl_tplay
; appl_trecord
;-------------------------------------------------------------------------

_appl_tplay::
          AControl  14,2,1,1
          bra.s     appl_pr
_appl_trecord::
          AControl  15,1,1,1
appl_pr:
          .cargs    #4,.pbuf.l,.count.w,.speed.w
          lea       .count(sp),a1       ; -> intin
          lea       .pbuf(sp),a0        ; -> adrin
          ACall     RET2USER
          
;         end of code


