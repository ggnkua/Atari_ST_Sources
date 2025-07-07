
;*========================================================================
;*
;* AESFAST Public Domain GEM bindings.
;*
;*========================================================================

          .include  "aesfast.sh"
          
;*************************************************************************
;*
;* Graphics Library routines 5 of 5.
;*
;*************************************************************************

;-------------------------------------------------------------------------
; graf_watchbox
;-------------------------------------------------------------------------

_graf_watchbox::
          .cargs    #8,.ptree.l,.obj,.instate,.outstate
          link      a6,#-2
          
          move.w    .outstate(a6),-(sp) ; D*mn AES defines a reserved parm
          move.w    .instate(a6),-(sp)  ; for this call, as intin[0], so we
          move.w    .obj(a6),-(sp)      ; have to build a new intin instead
          clr.w     -(sp)               ; of pointing to parms on entry.

          AControl  75,4,1,1
          moveq.l   #-2,d2              ;  = intout
          move.l    sp,a1               ; -> intin (we just built it)
          lea       .ptree(a6),a0       ; -> addrin
          ACall     RET2HERE

          move.w    -2(a6),d0
          unlk      a6
          rts

;         end of code

