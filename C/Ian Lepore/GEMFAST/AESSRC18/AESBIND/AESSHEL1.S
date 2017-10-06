
;*========================================================================
;*
;* AESFAST Public Domain GEM bindings.
;*
;*  04/05/89 -  v1.2
;*              Finally received confirmation for the proper definitions 
;*              of shel_get/shel_put.  The (incorrect) definition of
;*              shel_get() was removed from this module and built properly
;*              in aesshel2.s.
;*========================================================================

          .include  "aesfast.sh"
          
;*************************************************************************
;*
;* Shell library routines 1 of 2.
;*
;*************************************************************************

;-------------------------------------------------------------------------
; shel_read
;-------------------------------------------------------------------------

_shel_read::
          .cargs    #4,.pcmd.l,.ptail.l
          AControl  120,0,1,2
          lea       .pcmd(sp),a0    ; -> addrin
          ACall     RET2USER
          
;-------------------------------------------------------------------------
; shel_write
;-------------------------------------------------------------------------

_shel_write::
          .cargs    #4,.doex,.wisgr,.wiscr,.pcmd.l,.ptail.l
          AControl  121,3,1,2
          lea       .doex(sp),a1        ; -> intin
          lea       .pcmd(sp),a0        ; -> addrin
          ACall     RET2USER
          

;-------------------------------------------------------------------------
; shel_find
;-------------------------------------------------------------------------

_shel_find::

          .cargs    #4,.pbuf.l
          AControl  124,0,1,1
          lea       .pbuf(sp),a0    ; -> addrin
          ACall     RET2USER
          
;-------------------------------------------------------------------------
; shel_envrn
;-------------------------------------------------------------------------

_shel_envrn::
          .cargs    #4,.pvalue.l,pparm.l
          AControl  125,0,1,3
          lea       .pvalue(sp),a0    ; -> addrin
          ACall     RET2USER
          
;         end of code
          
