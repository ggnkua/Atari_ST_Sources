
;*========================================================================
;*
;* VDIFAST Public Domain VDI bindings.
;*
;*========================================================================

          .iif      !(^^macdef VContrl),.include  "vdimacro.s"
          
;*************************************************************************
;*
;* Rarely-used input functions. 
;*  All those functions which have a 'request mode' and 'sample mode'. 
;* 
;*  I don't understand this stuff at all...
;*   That implies that this stuff is totally untested.
;*
;*************************************************************************
          
;*------------------------------------------------------------------------
;* Set input mode.
;*------------------------------------------------------------------------

_vsin_mode::
          .cargs    #8,.handle.w,.devtyp.w,.mode.w
          link      a6,#-2

          VContrl   #33,,,#2
          
          subq.l    #4,sp               ;* -> ptsout
          pea       -2(a6)              ;* -> intout
          subq.l    #4,sp               ;* -> ptsin
          pea       .devtyp(a6)         ;* -> intin
          pea       16(sp)              ;* -> contrl

          jmp       vdicall

;*------------------------------------------------------------------------
;* Input locator.
;*------------------------------------------------------------------------

_vsm_locator::
_vrq_locator::
          .cargs    #8,.handle.w,.x.w,.y.w,.xout.l,.yout.l,.term.l
          link      a6,#-4              ;* Allocate ptsout[2].          

          VContrl   #28,,#1
                    
          pea       -4(a6)              ;* -> ptsout
          move.l    .term(a6),-(sp)     ;* -> intout
          pea       .x(a6)              ;* -> ptsin
          subq.l    #4,sp               ;* -> intin
          pea       16(sp)              ;* -> contrl

          moveq.l   #$73,d0
          move.l    sp,d1
          trap      #2
          
          move.l    .xout(a6),a0        ;* Return x
          move.w    -4(a6),(a0)         ;* from ptsout[0].
          move.l    .yout(a6),a0        ;* Return y
          move.w    -2(a6),(a0)         ;* from ptsout[1].
          
          move.w    28(sp),d0           ;* Contrl[4] (number of intout's)
          lsl.w     #1,d0               ;* Shifted by one, per specs, OR
          or.w      24(sp),d0           ;* in Contrl[2] (number of ptsout's).

          unlk      a6
          rts

;*------------------------------------------------------------------------
;* Input valuator.
;*------------------------------------------------------------------------

_vsm_valuator::
          link      a6,#-6
          st        -6(a6)
          bra.s     v_valuator
_vrq_valuator::
          link      a6,#-6
          clr.b     -6(a6)
v_valuator:
          .cargs    #8,.handle.w,.valin.w,.valout.l,.term.l,.status.l
          
          VContrl   #29,,,#1
          
          subq.l    #4,sp               ;* -> ptsout
          pea       -4(a6)              ;* -> intout
          subq.l    #4,sp               ;* -> ptsin
          pea       .valin(a6)          ;* -> intin
          pea       16(sp)              ;* -> contrl

          moveq.l   #$73,d0
          move.l    sp,d1
          trap      #2
          
          move.l    .valout(a6),a0      ;* Return value      
          move.w    -4(a6),(a0)         ;* from intout[0].
          move.l    .term(a6),a0        ;* Return terminator
          move.w    -2(a6),(a0)         ;* from intout[1].
          
          tst.b     -6(a6)              ;* Check sample-mode flag, if 
          beq.s     .skip               ;* not sample mode, skip status.

          move.l    .status(a6),a0      ;* In sample mode, we have to return
          move.w    28(sp),(a0)         ;* status from contrl[4].
.skip:
          unlk      a6
          rts

;*------------------------------------------------------------------------
;* Input choice, request mode.
;*------------------------------------------------------------------------

_vrq_choice::
          .cargs    #8,.handle.w,.chin.w,.chout.l
          link      a6,#0

          VContrl   #30,,,#1
          
          subq.l    #4,sp               ;* -> ptsout
          move.l    .chout(a6),-(sp)    ;* -> intout
          subq.l    #4,sp               ;* -> ptsin
          pea       .chin(a6)           ;* -> intin
          pea       16(sp)              ;* -> contrl

          jmp       vdicall
          
;*------------------------------------------------------------------------
;* Input choice, sample mode.
;*------------------------------------------------------------------------

_vsm_choice::
          .cargs    #8,.handle.w,.choice.l
          link      a6,#0
          
          VContrl   #30
          
          subq.l    #4,sp               ;* -> ptsout
          pea       .choice(a6)         ;* -> intout
          subq.l    #8,sp               ;* -> intin
          pea       16(sp)              ;* -> contrl

          moveq.l   #$73,d0
          move.l    sp,d1
          trap      #2
          move.w    28(sp),d0           ;* Return status from contrl[4].
          unlk      a6
          rts

;*------------------------------------------------------------------------
;* Input string.  
;*------------------------------------------------------------------------

_vsm_string::
_vrq_string::
          .cargs    #8,.handle.w,.maxlen.w,.echoflag.w,.echoxy.l,.string.l
          link      a6,#-4

          move.w    .maxlen(a6),d0      ;* We have to allocate 'maxlen'
          bpl.s     .notneg             ;* words of stack space to hold
          neg.w     d0                  ;* the ADE-type string that VDI
.notneg:                                ;* will return to us.  The maxlen
          add.w     d0,d0               ;* value may be negative (flag for
          sub.w     d0,sp               ;* VDI to return scancodes), so we
          move.l    sp,-4(a6)           ;* use the abs value in that case.
          
          VContrl  #31,,#1,#2

          subq.l    #4,sp               ;* -> ptsout
          move.l    -4(a6),-(sp)        ;* -> intout
          move.l    .echoxy(a6),-(sp)   ;* -> ptsin
          pea       .maxlen(a6)         ;* -> intin
          pea       16(sp)              ;* -> contrl

          moveq.l   #$73,d0
          move.l    sp,d1
          trap      #2
          
          moveq.l   #0,d0               ;* Zero string length for return.
          move.l    -4(a6),a0           ;* Pointer to ADE string on stack.
          move.l    .string(a6),a1      ;* Pointer to caller's string area.
.copyloop:
          addq.w    #1,d0               ;* Count string byte.
          move.w    (a0)+,d1            ;* Get a word from the ADE string,
          move.b    d1,(a1)+            ;* store the low byte in the caller's
          bne.s     .copyloop           ;* string, loop till NULL byte copied.
          
          subq.w    #1,d0               ;* Don't count nullterm byte.
          
          unlk      a6                  ;* Dealloc all stack space.
          rts

;*         end of code

