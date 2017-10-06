;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

    .include    "vdimacro.s"

;*------------------------------------------------------------------------
;* vgd_detect() - Return TRUE/FALSE, indicating GDOS is/isn't installed.
;*
;* 09/04/92 - Chris Herborth
;*            Changed to take FSM-GDOS and GDOS clones into account:
;*            Now returns a long value.  "_FSM" for FSM-GDOS, non-zero
;*            for any other GDOS, zero if no GDOS is present.
;*------------------------------------------------------------------------

          .globl  _vgd_detect
          .globl  _vq_vgdos
          
_vq_vgdos:
_vgd_detect:

          move.l   #-2,d0     ; If we pass a -2 to trap #2, and it
          trap     #2         ; comes back as -2, then GDOS is not
          addq.l   #2,d0      ; installed.  We add 2, and if that comes out
          beq.s    all_done   ; zero, no GDOS, we return the zero.  if it
          subq.l   #2,d0      ; comes back as anything else, we adjust it
all_done:                     ; back to its original value (in case it's
          rts                 ; "_FSM" to indicate FSMGDOS), and return it.
          
          end
          
