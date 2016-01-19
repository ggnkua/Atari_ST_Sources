;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; PROCEDURE:    INVERT
; DESCRIPTION:  draws a filled rectangular area (at pixel positions)
; AUTHOR:       russ
;
; This routine is used by the Armaments display to erase the
; backgrounds in the number boxes!
;
;  NB: this routine uses the ST A-LINE graphics routines and will be
;      a problem for the Amiga version.
;
; ENTER WITH:
;               D0 = colour
;               D1 = x1
;               D2 = y1
;               D3 = x2
;               D4 = y2
;
; EXIT WITH:
;               cleared rectangle
;
; CORRUPTS:
;               nothing
;
;-----------------------------------------------------------------------------
INVERT          movem.l d0-d7/a0-a6,-(a7)
                dc.w    $a000
*                move.l  aline,a0
                move.w  #4,(A0)	; 4 bitplanes in full colour
                move.w  d1,38(a0)
                move.w  d2,40(a0)
                move.w  d3,42(a0)
                move.w  d4,44(a0)
                move.w  #1,24(a0)
                move.w  #1,26(a0)
                move.w  #1,28(a0)
                move.w  #1,30(a0)
                move.w  #2,36(a0)
                move.l  #fill,46(a0)
                move.w  #0,50(a0)
                move.w  #0,54(a0)
                dc.w    $a005
                movem.l (a7)+,d0-d7/a0-a6
                rts

fill:           dc.w    $FFFF,$FFFF,$FFFF,$FFFF
