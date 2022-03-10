
;*========================================================================
;*
;* VDIFAST Public Domain VDI bindings.
;*
;* 07/18/91 v1.6
;*          Added _vdicall entry point, to allow 'roll your own' access
;*          to the VDI.  This function takes pointers to the VDI interface
;*          arrays (control, intin, etc), which you must allocate within
;*          your own code, and fill in with the appropriate values before
;*          calling this function.  For any array which is not needed by a
;*          given VDI function, a NULL pointer may be supplied.  Also, if
;*          a NULL intout pointer is supplied, a local 256-byte intout
;*          array is allocated on the stack.  Whether a local or caller-
;*          supplied intout array is used, the _vdicall entry pointer 
;*          will always return intout[0] as the function return value.
;*          For VDI functions which don't return any value(s) in intout,
;*          the return value will be whatever was in intout[0] when 
;*          this function is called for caller-provided intout arrays,
;*          or consistantly zero when the internal intout array is used.
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

          .globl    vdicall         ; The whole world sees us.
          .globl    _vdicall        ; everyone sees this too.
          
vdicall:
          moveq.l   #$73,d0
          move.l    sp,d1
          trap      #2
          move.w    -2(a6),d0
          unlk      a6
          rts

;*************************************************************************
;* _vdicall - the 'roll your own' function.
;*************************************************************************

_vdicall:
          .cargs    #8,.control.l,.intin.l,.ptsin.l,.intout.l,.ptsout.l

          link      a6,#-256            ; nice big intout, 'just in case'.
          move.l    a3,-(sp)            ; save this, we use it for intout.

          move.l    .intout(a6),a3      ; get caller-supplied intout ptr.
          move.l    a3,d0               ; test it for NULLness, if it's
          bne.s     .no_local_intout    ; not NULL, continue, else set
          lea       -256(a6),a3         ; up a pointer to our local intout
          clr.w     (a3)                ; array, and blast local intout[0].

.no_local_intout:
          
          move.l    .ptsout(a6),-(sp)   ; build vdipb on the stack...
          move.l    a3,-(sp)          
          move.l    .ptsin(a6),-(sp)
          move.l    .intin(a6),-(sp)
          move.l    .control(a6),-(sp)
          move.l    sp,d1               ; load pointer to vdipb
          moveq.l   #$73,d0             ; load vdi function code
          trap      #2                  ; do it.
          move.w    (a3),d0             ; return intout[0] in d0.
          move.l    (sp)+,a3
          unlk      a6
          rts
           
