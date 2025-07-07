
;*========================================================================
;*
;* VDIFAST Public Domain VDI bindings.
;*
;*========================================================================

;*************************************************************************
;*
;* Common module to call VDI then return to user-program.
;*  This routine is entered via 'jmp' and does NOT return to the binding
;*  routine that calls it.
;*
;*  This is used by all bindings which return a single int from intout[0]
;*  (more specifically, from -2(a6), or which return no value.  In the
;*  latter case, we still return the word from -2(a6), but the user 
;*  shouldn't care what it is.
;* 
;*************************************************************************

          .globl    vdicall        ; The whole world sees us.

vdicall:
          moveq.l   #$73,d0
          move.l    sp,d1
          trap      #2
          move.w    -2(a6),d0
          unlk      a6
          rts

