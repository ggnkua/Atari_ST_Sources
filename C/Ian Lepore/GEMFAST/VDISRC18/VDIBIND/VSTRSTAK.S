;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

          .include  "vdimacro.s"

;*------------------------------------------------------------------------
;*-----------------------------------------------------------------------
;* vstr_stack.
;*
;*  For VDI text functions that need the string stacked into intin in
;*  ADE format.
;*
;*  This function is not exported to C, it is to be used only by vdi
;*  bindings routines.
;*
;*  Entry:  a0.l -> string
;*  Exit:   a0.l -> stacked integerized (ADE) string
;*          d0.w  = stack words used (intin count)
;*      d1,d2,a1  = Trashed by this routine.
;*-----------------------------------------------------------------------
;*------------------------------------------------------------------------

vstr_stack::

          move.l    (sp)+,a1            ;* Save return address.
          moveq.l   #0,d0               ;* Zero out string length counter.
.strcnt:                                ;* Count up length of string...
          tst.b     (a0)+               ;* Found end yet?
          beq.s     .strend             ;* Yep, go integerize it.
          addq.w    #1,d0               ;* Nope, add 1 to counter,
          bra.s     .strcnt             ;* and keep looking.
.strend:
          move.w    d0,d1               ;* Prime loop counter.
          moveq.l   #0,d2               ;* Nice clean register.
.strcpy:                                ;* Copy the string to the stack,
          move.b    -(a0),d2            ;* with each string byte in the
          move.w    d2,-(sp)            ;* low byte of each stack word,
          dbra      d1,.strcpy          ;* which is how VDI likes to see it.

          move.l    sp,a0               ;* Save pointer to stacked string.
          jmp       (a1)                ;* Return to caller.

          end
