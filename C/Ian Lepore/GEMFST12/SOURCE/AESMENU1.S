
;*========================================================================
;*
;* AESFAST Public Domain GEM bindings.
;*
;*========================================================================

          .include  "aesfast.sh"
          
;*************************************************************************
;*
;* Menu Manager routines 1 of 2.
;*
;*************************************************************************

;-------------------------------------------------------------------------
; menu_bar
; menu_icheck
; menu_ienable
; menu_tnormal
;-------------------------------------------------------------------------

_menu_bar::
          AControl  30,1,1,1
          bra.s     menu_do
_menu_icheck::
          AControl  31,2,1,1
          bra.s     menu_do
_menu_ienable::
          AControl  32,2,1,1
          bra.s     menu_do
_menu_tnormal::
          AControl  33,2,1,1
menu_do:
          .cargs    #4,.ptree.l,.intin
          lea       .intin(sp),a1       ; -> intin
          lea       .ptree(sp),a0       ; -> addrin
          ACall     RET2USER
          
;-------------------------------------------------------------------------
; menu_text
;-------------------------------------------------------------------------

_menu_text::
          .cargs    #8,.ptree.l,.item,.ptext.l
          link      a6,#-2
          AControl  34,1,1,2
          move.l    .ptext(a6),-(sp)    ; The 2 pointers are not contiguous
          move.l    .ptree(a6),-(sp)    ; on entry call stack, make them so.
          moveq.l   #-2,d2              ;  = intout
          move.l    sp,a0               ; -> addrin (we just built it)
          lea       .item(a6),a1        ; -> intin
          ACall     RET2HERE

          move.w    -2(a6),d0
          unlk      a6
          rts
          
;         end of code

