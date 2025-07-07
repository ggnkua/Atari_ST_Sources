
;*========================================================================
;*
;* VDIFAST Public Domain VDI bindings.
;*
;*========================================================================

          .iif      !(^^macdef VContrl),.include  "vdimacro.s"
          
;*************************************************************************
;*
;* Commonly-used control functions.
;*
;*************************************************************************

;*------------------------------------------------------------------------
;* Open workstation.
;* Open virtual workstation.
;*------------------------------------------------------------------------

_v_opnvwk::
          moveq.l   #100,d0             ;* Open vwork function = 100.
          bra.s     opnwk               ;* Continue below.
_v_opnwk::
          moveq.l   #1,d0               ;* Open work function = 1.
opnwk:
          .cargs   #8,.workin.l,.handle.l,.workout.l

          link      a6,#0
          
          move.l    .handle(a6),a0      ;* Handle parm is input and output,
          VContrl   d0,,,#11,(a0)       ;* and is indirect.  
          
          move.l    .workout(a6),a0
          
          pea       90(a0)              ;* -> ptsout
          move.l    a0,-(sp)            ;* -> intout
          subq.l    #4,sp               ;* -> ptsin
          move.l    .workin(a6),-(sp)   ;* -> intin
          pea       16(sp)              ;* -> contrl
          
          moveq.l   #$73,d0
          move.l    sp,d1
          trap      #2
          
          move.l    .handle(a6),a0      ;* VDI handle must be returned
          move.w    -2(a6),(a0)         ;* indirect thru user-supplied ptr.
          
          unlk      a6
          rts
          
;*------------------------------------------------------------------------
;*-----------------------------------------------------------------------
;* vwk_honly 
;*  For VDI workstation calls that uses a handle only, no input or output.
;*   Entry:  d0.w = VDI function number.
;*-----------------------------------------------------------------------
;*------------------------------------------------------------------------

vwk_honly:
          .cargs    #8,.handle.w
          link      a6,#0
          VContrl   d0                  ;* Function is passed in d0.
          pea       (sp)                ;* -> contrl
          
          jmp       vdicall
          
;*------------------------------------------------------------------------
;* Close workstation.
;* Close virtual workstation.
;*------------------------------------------------------------------------

_v_clsvwk::
          moveq.l   #101,d0             ;* Close vwork function = 101.
          bra       vwk_honly
_v_clswk::
          moveq.l   #2,d0               ;* Close work function = 2.
          bra       vwk_honly
          
;*------------------------------------------------------------------------
;* Clear workstation.
;*------------------------------------------------------------------------

_v_clrwk::
          moveq.l   #3,d0               ;* Clear workstation code = 3.
          bra       vwk_honly
          
;*------------------------------------------------------------------------
;* Update workstation.
;*------------------------------------------------------------------------

_v_updwk::
          moveq.l   #4,d0               ;* Update workstation code = 4.
          bra       vwk_honly

;*------------------------------------------------------------------------
;* Set clipping rectangle.
;*------------------------------------------------------------------------

_vs_clip::
          .cargs    #8,.handle.w,.clipflag.w,.pxy.l
          link      a6,#0
          
          VContrl   #129,,#2,#1

          subq.l    #8,sp
          move.l    .pxy(a6),-(sp)      ;* -> ptsin
          pea       .clipflag(a6)       ;* -> intin 
          pea       16(sp)              ;* -> contrl

          jmp       vdicall
          
;*         end of code

