
;*========================================================================
;*
;* VDIFAST Public Domain VDI bindings.
;*
;*========================================================================
        
          .iif      !(^^macdef VContrl),.include  "vdimacro.s"
          
;*************************************************************************
;*
;* Inquiry functions.
;*  Polyline- and polymarker-related functions.
;*
;*************************************************************************
          
;*------------------------------------------------------------------------
;* Inquire polyline attributes.  
;*------------------------------------------------------------------------
          
_vql_attributes::
          .cargs    #8,.handle.w,.attrib.l
          link      a6,#-14             ;* Allocate intout[5], ptsout[2].

          VContrl   #35
          
          pea       -14(a6)             ;* -> ptsout
          pea       -10(a6)             ;* -> intout
          subq.l    #8,sp               ;* -> ptsin
          pea       16(sp)              ;* -> contrl

          moveq.l   #$73,d0
          move.l    sp,d1
          trap      #2

          move.l    .attrib(a6),a0      ;* Return values in attrib array...
          move.l    -10(a6),(a0)+       ;* attr[0]=intout[0],attr[1]=intout[1]
          move.w    -6(a6),(a0)+        ;* attr[2]=intout[2]
          move.w    -14(a6),(a0)        ;* attr[3]=ptsout[0]

          unlk      a6
          rts

;*------------------------------------------------------------------------
;* Inquire polymarker attributes.
;*------------------------------------------------------------------------

_vqm_attributes::
          .cargs    #8,.handle.w,.attrib.l
          link      a6,#-10

          VContrl   #36
          
          pea       -10(a6)             ;* -> ptsout
          pea       -6(a6)              ;* -> intout
          subq.l    #8,sp               ;* -> ptsin
          pea       16(sp)              ;* -> contrl

          moveq.l   #$73,d0
          move.l    sp,d1
          trap      #2

          move.l    .attrib(a6),a0      ;* Return values in attrib array...
          move.l    -6(a6),(a0)+        ;* attr[0]=intout[0],attr[1]=intout[1]
          move.w    -2(a6),(a0)+        ;* attr[2]=intout[2]
          move.w    -8(a6),(a0)         ;* attr[3]=ptsout[1]

          unlk      a6
          rts

;*------------------------------------------------------------------------
;* Inquire fill area attributes.
;*------------------------------------------------------------------------
          
_vqf_attributes::
          .cargs    #8,.handle.w,.attrib.l
          link      a6,#-10             ;* Allocate intout[5].

          VContrl   #36

          subq.l    #4,sp               ;* -> ptsout
          pea       -10(a6)             ;* -> intout
          subq.l    #8,sp               ;* -> intin
          pea       16(sp)              ;* -> contrl

          moveq.l   #$73,d0
          move.l    sp,d1
          trap      #2
          
          move.l    .attrib(a6),a0      ;* Return values in attrib array
          lea       -10(a6),a1          ;* from 1st 4 elements of intout.
          move.l    (a1)+,(a0)+         ;* attr[0]=intout[0],attr[1]=intout[1]
          move.l    (a1)+,(a0)+         ;* attr[2]=intout[2],attr[3]=intout[3]

          unlk      a6
          rts

;       end of code
