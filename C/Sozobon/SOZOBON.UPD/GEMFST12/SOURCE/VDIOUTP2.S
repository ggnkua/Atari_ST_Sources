
;*========================================================================
;*
;* VDIFAST Public Domain VDI bindings.
;*
;*  Maintenance:
;*   04/26/89 v1.2 - Changed "VContrl 103" to "VCntrl #103" for 
;*                   v_contourfill() function.
;*
;*========================================================================

          .iif      !(^^macdef VContrl),.include  "vdimacro.s"
          
;*************************************************************************
;*
;* Less commonly-used output functions.
;*
;*************************************************************************

;*------------------------------------------------------------------------
;* Contour fill.
;*------------------------------------------------------------------------

_v_contourfill::
          .cargs    #8,.handle.w,.x.w,.y.w,.index.w
          link      a6,#0

          VContrl   #103,,#1,#1

          subq.l    #8,sp               ;* -> ptsout
          pea       .x(a6)              ;* -> ptsin
          pea       .index(a6)          ;* -> intin
          pea       16(sp)              ;* -> contrl

          jmp       vdicall
          
;*------------------------------------------------------------------------
;* Arc and Pie.
;*------------------------------------------------------------------------

_v_arc::
          moveq.l   #2,d1
          bra.s     varcpie
_v_pieslice::
          moveq.l   #3,d1
varcpie:
          .cargs    #8,.handle.w,.x.w,.y.w,.radius.w,.begang.w,.endang.w
          link      a6,#0
          
          clr.w     -(sp)               ;* There are some unused words
          move.w    .radius(a6),-(sp)   ;* (which must be zeroed) in the
          clr.l     -(sp)               ;* ptsin definition for arc & pie,
          clr.l     -(sp)               ;* so build a temporary ptsin
          move.l    .x(a6),-(sp)        ;* array on the stack.
          move.l    sp,a0               ;* Save pointer to ptsin.

          VContrl   #11,d1,#4,#2
          
          subq.l    #8,sp               ;* -> ptsout
          move.l    a0,-(sp)            ;* -> ptsin
          pea       .begang(a6)         ;* -> intin
          pea       16(sp)              ;* -> contrl

          jmp       vdicall

;*------------------------------------------------------------------------
;* Eliptical arc and pie.
;*------------------------------------------------------------------------

_v_ellarc::
          moveq.l   #6,d1
          bra.s     ellarcpie
_v_ellpie::
          moveq.l   #7,d1
ellarcpie:
          .cargs    #8,.handle.w,.x.w,.y.w,.xradius.w,.yradius.w,.begang.w,.endang.w
          link      a6,#0
          
          VContrl   #11,d1,#2,#2
          
          subq.l    #8,sp               ;* -> ptsout
          pea       .x(a6)              ;* -> ptsin
          pea       .begang(a6)         ;* -> intin
          pea       16(sp)              ;* -> contrl

          jmp       vdicall

;*------------------------------------------------------------------------
;* Ellipse.
;*------------------------------------------------------------------------

_v_ellipse::

          .cargs    #8,.handle.w,.x.w,.y.w,.xradius.w,.yradius.w
          link      a6,#0
          
          VContrl   #11,#5,#2
          
          subq.l    #8,sp               ;* -> ptsout
          pea       .x(a6)              ;* -> ptsin
          subq.l    #4,sp               ;* -> intin
          pea       16(sp)              ;* -> contrl

          jmp       vdicall
          
;*------------------------------------------------------------------------
;* Cell array.  What a weird function.
;*------------------------------------------------------------------------

_v_cellarray::
          .cargs    #8,.handle.w,.pxy.l,.rowlen.w,.elused.w,.numrows.w,.wrmode.w,.colarray.l
          link      a6,#0
          
          move.w    .numrows(a6),d0     ;* Save numrows and number of
          move.w    .elused(a6),d1      ;* elements used for intin count
          move.w    .wrmode(a6),-(sp)   ;* calculation later.  Stack the
          move.w    d0,-(sp)            ;* extra contrl parms first.
          move.w    d1,-(sp)
          move.w    .rowlen(a6),-(sp)
          
          mulu      d1,d0               ;* Calc intin count=numrows*elused.
          
          VContrl   #10,,#2,d0          
          
          subq.l    #8,sp               ;* -> ptsout
          move.l    .pxy(a6),-(sp)      ;* -> ptsin
          move.l    .colarray(a6),-(sp) ;* -> intin
          pea        16(sp)             ;* -> contrl

          jmp       vdicall

;         end of code
