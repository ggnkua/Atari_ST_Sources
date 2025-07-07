
;*========================================================================
;*
;* VDIFAST Public Domain VDI bindings.
;*
;* Maintenance:
;*  02/06/89    v1.1 - Changed misspelling of vq_extnd (was vq_extend).
;*                     Changed handle.l to handle.w in vq_extnd
;*========================================================================

          .iif      !(^^macdef VContrl),.include  "vdimacro.s"
          
;*************************************************************************
;*
;* Inquiry functions.
;*  Some random ones.
;*************************************************************************
          
;*------------------------------------------------------------------------
;* Extended inquire.
;*------------------------------------------------------------------------

_vq_extnd::
          .cargs    #8,.handle.w,.owflag.w,.workout.l
          link      a6,#0
          
          VContrl   #102,,,#1
          
          move.l    .workout(a6),a0
          
          pea       90(a0)              ;* -> ptsout
          move.l    a0,-(sp)            ;* -> intout
          subq.l    #4,sp               ;* -> ptsin
          pea       .owflag(a6)         ;* -> intin
          pea       16(sp)              ;* -> contrl
          
          jmp       vdicall
          
;*------------------------------------------------------------------------
;* Inquire color representation.
;*------------------------------------------------------------------------
          
_vq_color::
          .cargs    #8,.handle.w,.color.w,.setflag.w,.rgb.l
          link      a6,#-8              ;* Allocate intout[4].

          VContrl   #26,,,#2

          subq.l    #4,sp               ;* -> ptsout
          pea       -8(a6)              ;* -> intout
          subq.l    #4,sp               ;* -> ptsin
          pea       .color(a6)          ;* -> intin
          pea       16(sp)              ;* -> contrl

          moveq.l   #$73,d0
          move.l    sp,d1
          trap      #2

          move.l    .rgb(a6),a0         ;* Return rgb array...
          move.l    -6(a6),(a0)+        ;* rgb[0]=intout[1], rgb[1]=intout[2]
          move.w    -2(a6),(a0)         ;* rgb[2]=intout[3]

          unlk      a6
          rts
        
;*------------------------------------------------------------------------
;* Inquire cell array - not supported.
;*------------------------------------------------------------------------

;*------------------------------------------------------------------------
;* Inquire input mode.
;*------------------------------------------------------------------------

_vqin_mode::
          .cargs    #8,.handle.w,.devtyp.w,.inmode.l
          link      a6,#0

          VContrl   #115,,,#1
          
          subq.l    #4,sp               ;* -> ptsout
          move.l    .inmode(a6),-(sp)   ;* -> intout
          subq.l    #4,sp               ;* -> ptsin
          pea       .devtyp(a6)         ;* -> intin
          pea       16(sp)              ;* -> contrl

          jmp       vdicall 

;         end of code

