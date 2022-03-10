
;*========================================================================
;*
;* AESFAST Public Domain GEM bindings.
;*  Maintenance:
;*   12/17/89 v1.4: This source file is new with this version.
;*                  Yet another variation on the fsel_exinput function.
;*                  This version, fsel_14input is the most vanilla access
;*                  to fsel_exinput.  We check the AES version, and call
;*                  either fsel_input or fsel_exinput; no emulation modes
;*                  are available.
;*========================================================================

          .include  "aesfast.sh"
          .include  "gemfast.sh"
          .extern   _gl_apversion
          .extern   aesblock

;*************************************************************************
;*
;* Extended fsel manager routine.
;*
;*************************************************************************

;-------------------------------------------------------------------------
; fsel_14input
;  This function is new with TOS 1.4, but this binding supports it in all
;  TOS/AES versions by calling the old fsel_input routine if running on
;  a pre-1.4 system.
;-------------------------------------------------------------------------

_fsel_14input::

          .cargs    #8,.pinpath.l,.pinsel.l,.pbutton.l,.plabel.l
          link      a6,#-4

          move.l    .plabel(a6),d0           ; Swap the button and prompt
          move.l    .pbutton(a6),.plabel(a6) ; string pointers to make the
          move.l    d0,.pbutton(a6)          ; addrin stuff contiguous.

          AControl  90,0,2,2                 ; Assume we'll call fsel_input.
          move.w    _gl_apversion,d1         ; Check the AES version.  If
          cmp.w     #$0104,d1                ; it's $0104, we're running
          beq.s     .newaes                  ; on the RAM-based TOS 1.4
          cmp.w     #$0130,d1                ; Else, if it's less than $0130
          blt       .doit                    ; we have to use fsel_input.
.newaes:
          AControl  91,0,2,3                 ; AES v1.3 & up: fsel_exinput
.doit:
          moveq.l   #-4,d2                   ; is a legal function, do it.
          lea       .pinpath(a6),a0          ; a0 -> addrin
          ACall     RET2HERE                 ; Call AES.

          move.l    .plabel(a6),d0           ; Swap the prompt string and
          move.l    .pbutton(a6),.plabel(a6) ; button pointers back to how
          move.l    d0,.pbutton(a6)          ; they were on entry.

          moveq.l   #-4,d1                   ; Return values from
          lea       .pbutton(a6),a1          ; intout[] array to caller
          jmp       (a0)                     ; via aes_return routine.

;         end of code

