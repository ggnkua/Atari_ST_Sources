
;*========================================================================
;*
;* VDIFAST Public Domain VDI bindings.
;*
;*========================================================================

          .iif      !(^^macdef VContrl),.include  "vdimacro.s"
          
;*************************************************************************
;*
;* Rarely-used input functions. 
;*  Functions which change vectors.
;*
;*  My interpretation of the exchange-vector function parms is that you
;*  pass a pointer to the new routine, and a pointer to a longword into
;*  which the address of the old routine is stored. DRI docs are not clear.
;*************************************************************************

;*------------------------------------------------------------------------
;* Exchange timer interupt vector.
;*------------------------------------------------------------------------

_vex_timv::
          .cargs    #8,.handle.w,.newtim.l,.oldtim.l,.cnvtim.l
          link      a6,#0

          clr.l     -(sp)               ;* Old vector here; contrl[9-10].
          move.l    .newtim(a6),-(sp)   ;* New vector in contrl[7-8].

          VContrl   #118
          
          subq.l    #4,sp               ;* -> ptsout
          move.l    .cnvtim(a6),-(sp)   ;* -> intout
          subq.l    #8,sp               ;* -> intin
          pea       16(sp)              ;* -> contrl

          moveq.l   #$73,d0
          move.l    sp,d1
          trap      #2
          
          move.l    .oldtim(a6),a0      ;* Return old vector 
          move.l    -4(a6),(a0)         ;* from contrl[9-10].
          
          unlk      a6
          rts

;*------------------------------------------------------------------------
;* Exchange button change vector.
;* Exchange mouse movement vector.
;* Exchange cursor change vector.
;*------------------------------------------------------------------------

_vex_butv::
          moveq.l   #125,d0             ;* Exchange button vector function.
          bra.s     vex
_vex_motv::                             
          moveq.l   #126,d0             ;* Exchange movement vector function.
          bra.s     vex
_vex_curv::
          moveq.l   #127,d0             ;* Exchange cursor change vector func.
vex:
          .cargs    #8,.handle.w,.newvec.l,.oldvec.l
          link      a6,#0
          
          clr.l     -(sp)               ;* contrl[9-10], old vector.
          move.l    .newvec(a6),-(sp)   ;* contrl[8-8],  new vector.
          
          VContrl   d0
          
          pea       (sp)                ;* -> contrl

          moveq.l   #$73,d0
          move.l    sp,d1
          trap      #2
          
          move.l    .oldvec(a6),a0      ;* Return old vector 
          move.l    -4(a6),(a0)         ;* from contrl[9-10].

          unlk      a6
          rts
          
;*         end of code

