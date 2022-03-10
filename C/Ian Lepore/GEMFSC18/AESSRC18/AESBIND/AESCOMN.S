
;*========================================================================
;*
;* AESFAST Public Domain GEM bindings.
;*
;*  04/06/89    v1.2
;*              Added TST.W just before RTS in aes_return routine.  This
;*              hack keeps Laser C happy.  Laser has an optimization such
;*              that source code such as:
;*                 if (!rsrc_load(filename))
;*                      form_error(errno);
;*              Will generate assembler code like:
;*                 jsr   _rsrc_load
;*                 bne   ...
;*              So we have to make sure the CCR flags match the values in
;*              d0 upon return.  Returns through aes_do were working fine,
;*              but the extra tst instruction was needed in aes_return.
;*========================================================================

;*************************************************************************
;*
;* AESCOMN - Common routines (takes the place of CRYSTAL).
;*
;*************************************************************************

AES_ALLOCBSS = 1                        ; Set flag to alloc BSS in sh file.

          .include  "aesfast.sh"

          .text

;-------------------------------------------------------------------------
; aes_do - Set up AESBLOCK, call trap 2, return directly to caller in
;          program (do not go back to binding routine).
;
;          This routine is entered via 'jmp'.
;-------------------------------------------------------------------------

aes_do:  
          subq.l    #2,sp               ; Allocate intout[1].
          move.l    a0,d1               ; save adrin pointer
          lea       aesblock,a0         ; Load pointer to AES block, 
          movep.l   d0,control+1(a0)    ; fill in the control array (!),
          move.l    a1,pintin(a0)       ; store the intin ptr into aespb
          move.l    d1,padrin(a0)       ; store the adrin ptr into aespb
          move.l    sp,pintout(a0)      ; store the intout ptr into aespb
          move.l    a0,d1               ; move the aespb pointer to the
          move.w    #$C8,d0             ; interface register, also the AES
          trap      #2                  ; function code, call AES.
          move.w    (sp)+,d0            ; Return to caller with value from
          rts                           ; intout[0] in d0 (& CCR matches d0).
          
;-------------------------------------------------------------------------
; aes_return - Return values from the intout array (on the stack) to
;              the variables the caller gaves us pointers to, then 
;              return directly to the caller of the binding.
;
;              This routine is entered via 'jmp'.
;-------------------------------------------------------------------------

aes_return:
          move.w    0(a6,d1.w),d0       ; 1st...intout[0] always goes to d0.
.ret_loop:
          addq.w    #2,d1               ; Increment intout offset,
          beq.s     .alldone            ; if zero, all return values done.
          move.l    (a1)+,a0            ; Get pointer to return variable,
          move.w    0(a6,d1.w),(a0)     ; move value from intout[n] to
          bra.s     .ret_loop           ; variable pointed to by call parms.
.alldone:
          unlk      a6                  ; Undo the stack, & return intout[0]
          tst.w     d0                  ; (insure CCR matches intout[0]) to
          rts                           ; caller of the original binding.

;-------------------------------------------------------------------------
; AES call - Set up AESBLOCK, call trap 2, return to binding routine that
;            called us.  That binding routine will probably do some little
;            cleanup or something, then want to exit via aes_return, above.
;            On exit from this routine, we will return a pointer to the
;            aes_return routine in a0, allowing the binding to do its thing
;            then get out via 'jmp (a0)', saving the need for a relocatable
;            reference to aes_return in the bindings.
;
;            This routine is entered via 'jsr'.
;-------------------------------------------------------------------------

aes_call:
          move.l    a0,d1               ; save adrin pointer
          lea       aesblock,a0         ; Load pointer to AES block, 
          movep.l   d0,control+1(a0)    ; fill in the control array (!),
          move.l    a1,pintin(a0)       ; store the intin ptr into aespb
          move.l    d1,padrin(a0)       ; store the adrin ptr into aespb
          add.l     a6,d2               ; build the intout ptr
          move.l    d2,pintout(a0)      ; store it into aespb
          move.l    a0,d1               ; move the aespb pointer to the
          move.w    #$C8,d0             ; interface register, also the AES
          trap      #2                  ; function code, call AES, return
          lea       aes_return(pc),a0   ; a pointer to the return routine
          rts                           ; to the calling binding routine.


;         end of code

