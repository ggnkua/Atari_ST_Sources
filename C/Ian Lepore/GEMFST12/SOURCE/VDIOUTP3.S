
;*========================================================================
;*
;* VDIFAST Public Domain VDI bindings.
;*
;*========================================================================
          
          .iif      !(^^macdef VContrl),.include  "vdimacro.s"
          
;*************************************************************************
;*
;* Text output functions.
;*
;*************************************************************************

;*------------------------------------------------------------------------
;*-----------------------------------------------------------------------
;* vstr_stack.
;*  For VDI text functions that need the string stacked into intin.
;*  Entry:  a0.l -> string
;*  Exit:   a0.l -> stacked integerized (ADE) string
;*          d0.w  = stack words used (intin count)
;*      d1,d2,a1  = Trashed by this routine.
;*-----------------------------------------------------------------------
;*------------------------------------------------------------------------

vstr_stack:
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
          
;*------------------------------------------------------------------------
;* Text.
;*------------------------------------------------------------------------

_v_gtext::

          .cargs    #8,.handle.w,.x.w,.y.w,.p_str.l
          link      a6,#0
          
          move.l    .p_str(a6),a0       ;* Get the string pointer.
          bsr       vstr_stack          ;* Go integerize and stack string.
          
          VContrl   #8,,#1,d0
          
          subq.l    #8,sp               ;* -> ptsout
          pea       .x(a6)              ;* -> ptsin
          move.l    a0,-(sp)            ;* -> intin
          pea       16(sp)              ;* -> contrl

          jmp       vdicall
          
;*------------------------------------------------------------------------
;* Justified text. 
;*------------------------------------------------------------------------

_v_justified::

          .cargs    #8,.handle.w,.x.w,.y.w,.p_str.l,.length.w,.wspace.w,.cspace.w
          link      a6,#0
          
          move.l    .p_str(a6),a0       ;* Get the string pointer.
          bsr       vstr_stack          ;* Go integerize and stack string.
          
          move.w    .cspace(a6),-(sp)   ;* The character and word spacing
          move.w    .wspace(a6),-(sp)   ;* flags are the 1st 2 intin words.
          addq.w    #2,d0               ;* Count the 2 extra words in length.
          move.l    sp,a0               ;* Save pointer to intin.
          
          clr.w     -(sp)               ;* Build the ptsin array on the stack,
          move.w    .length(a6),-(sp)   ;* because it has an extra null word
          move.l    .x(a6),-(sp)        ;* after the x/y/length.
          move.l    sp,a1               ;* Save pointer to ptsin.
          
          VContrl   #11,#10,#2,d0
          
          subq.l    #8,sp               ;* -> ptsout
          move.l    a1,-(sp)            ;* -> ptsin
          move.l    a0,-(sp)            ;* -> intin
          pea       16(sp)              ;* -> contrl

          jmp       vdicall

;*------------------------------------------------------------------------
;* Cursor addressable alpha text (VDI escape function 12).
;*------------------------------------------------------------------------

_v_curtext:

          .cargs    #8,.handle.w,.p_str.l
          link      a6,#0
          
          move.l    .p_str(a6),a0       ;* Get the string pointer.
          bsr       vstr_stack          ;* Go integerize and stack string.
          move.l    sp,a0               ;* Save pointer to intin.
          
          VContrl   #5,#12,,d0
          
          lea       -12(sp),sp
          move.l    a0,-(sp)            ;* -> intin
          pea       16(sp)              ;* -> contrl

          jmp       vdicall
          
;         end of code.


