
;*========================================================================
;*
;* VDIFAST Public Domain VDI bindings.
;*
;*========================================================================

            .iif                !(^^macdef VContrl),.include  "vdimacro.s"
                        
;*************************************************************************
;*
;* Attribute functions 3.
;*  Text- and character-related stuff.
;*
;*  _vst_height     - Set text height (absolute).
;*  _vst_point      - Set text height (points).
;*  _vst_alignment  - Set text alignment.
;*
;*************************************************************************

;*------------------------------------------------------------------------
;* Set character height, absolute mode.
;*------------------------------------------------------------------------

_vst_height::
            .cargs    #8,.handle.w,.height.w,.charw.l,.charh.l,.cellw.l,.cellh.l
            link      a6,#-8            ;* Allocate ptsout[4].
            
            move.w    .height(a6),-(sp) ;* ptsin[1] = height.
            clr.w      -(sp)            ;* ptsin[0] = 0.
            move.l    sp,a0             ;* Save a pointer to ptsin.
            
            VContrl   #12,,#1
            
            pea       -8(a6)            ;* -> ptsout
            subq.l    #4,sp             ;* -> intout
            move.l    a0,-(sp)          ;* -> ptsin
            subq.l    #4,sp             ;* -> intin
            pea       16(sp)            ;* -> contrl

            moveq.l   #$73,d0
            move.l    sp,d1
            trap      #2
returnheight:            
            .cargs    #8,.handle.w,.height.w,.charw.l,.charh.l,.cellw.l,.cellh.l

            lea       -8(a6),a1         ;* a1 -> ptsout[0] on stack.
            move.l    .charw(a6),a0     ;* Return character width
            move.w    (a1)+,(a0)        ;* from ptsout[0].
            move.l    .charh(a6),a0     ;* Return character height
            move.w    (a1)+,(a0)        ;* from ptsout[1].
            move.l    .cellw(a6),a0     ;* Return cell width
            move.w    (a1)+,(a0)        ;* from ptsout[2].
            move.l    .cellh(a6),a0     ;* Return cell height
            move.w    (a1),(a0)         ;* from ptsout[3].
            
            unlk      a6
            rts

;*------------------------------------------------------------------------
;* Set character height, points mode.
;*------------------------------------------------------------------------

_vst_point::

            .cargs    #8,.handle.w,.height.w,.charw.l,.charh.l,.cellw.l,.cellh.l
            link      a6,#-10            ;* Allocate ptsout[4], intout[1].
            
            VContrl   #107,,,#1
            
            pea       -8(a6)           ;* -> ptsout
            pea       -10(a6)          ;* -> intout
            subq.l    #4,sp            ;* -> ptsin
            pea       .height(a6)      ;* -> intin
            pea       16(sp)           ;* -> contrl

            moveq.l   #$73,d0
            move.l    sp,d1
            trap      #2

            move.w    -10(a6),d0        ;* Return pt size from intout[0]
            bra       returnheight      ;* Return rest from ptsout[].

;*------------------------------------------------------------------------
;* Set text alignment.
;*------------------------------------------------------------------------

_vst_alignment::
            .cargs    #8,.handle.w,.hin.w,.vin.w,.hout.l,.vout.l
            link      a6,#-4            ;* Allocate intout[2].
            
            VContrl   #39,,,#2
            
            subq.l    #4,sp            ;* -> ptsout
            pea       -4(a6)           ;* -> intout
            subq.l    #4,sp            ;* -> ptsin
            pea       .hin(a6)         ;* -> intin
            pea       16(sp)           ;* -> contrl

            moveq.l   #$73,d0
            move.l    sp,d1
            trap      #2
            
            move.l    .hout(a6),a0      ;* Return horizontal 
            move.w    -4(a6),(a0)       ;* from intout[0].
            move.l    .vout(a6),a0      ;* Return vertical
            move.w    -2(a6),(a0)       ;* from intout[1].

            unlk      a6
            rts


;*           end of attributes code.

