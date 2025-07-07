
;*========================================================================
;*
;* VDIFAST Public Domain VDI bindings.
;*
;*========================================================================

          .iif      !(^^macdef VContrl),.include  "vdimacro.s"
          
;*************************************************************************
;*
;* Inquiry functions.
;*  Text- and character-related functions.
;*
;*************************************************************************

;*------------------------------------------------------------------------
;* Inquire text attributes.
;*------------------------------------------------------------------------
          
_vqt_attributes::
          .cargs    #8,.handle.w,.attrib.l
          link      a6,#0

          VContrl   #38
          
          move.l    .attrib(a6),a0
          pea       12(a0)              ;* -> ptsout
          move.l    a0,-(sp)            ;* -> ptsout
          subq.l    #8,sp               ;* -> ptsout
          pea       16(sp)              ;* -> contrl

          jmp       vdicall
          
;*------------------------------------------------------------------------
;* Inquire text extent.
;*------------------------------------------------------------------------
          
_vqt_extent::
          .cargs    #8,.handle.w,.string.l,.extent.l
          link      a6,#0

          move.l    .string(a6),a0      ;* Get pointer to string.
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
          
          VContrl   #116,,,d0
          
          move.l    .extent(a6),-(sp)   ;* -> ptsout
          subq.l    #8,sp               ;* -> intout
          move.l    a0,-(sp)            ;* -> intin
          pea       16(sp)              ;* -> contrl

          jmp       vdicall
          
;*------------------------------------------------------------------------
;* Inquire character cell width.
;*------------------------------------------------------------------------
          
vqt_width::
          .cargs    #8,.handle.w,.character.w,.cellw.l,.left.l,.right.l
          link      a6,#-14             ;* Allocate intout[1], ptsout[6].
          
          VContrl   #117,,,#1
          
          pea       -12(a6)             ;* -> ptsout
          pea       -14(a6)             ;* -> intout
          subq.l    #4,sp               ;* -> ptsin
          pea       .character(a6)      ;* -> intin
          pea       16(sp)              ;* -> contrl

          moveq.l   #$73,d0
          move.l    sp,d1
          trap      #2
          
          move.l    .cellw(a6),a0       ;* Return cell width
          move.w    -12(a6),(a0)        ;* from ptsout[0].
          move.l    .right(a6),a0       ;* Return cell right delta
          move.w    -8(a6),(a0)         ;* from ptsout[2].
          move.l    .left(a6),a0        ;* Return cell left delta
          move.w    -4(a6),(a0)         ;* from ptsout[4].
          move.w    -14(a6),d0          ;* Return status from intout[0].

          unlk      a6
          rts

;*------------------------------------------------------------------------
;* Inquire font face name and index.
;*------------------------------------------------------------------------
          
_vqt_name::
          .cargs    #8,.handle.w,.element.w,.namestr.l
          link      a6,#-66             ;* Allocate intout[33].
          
          VContrl   #130,,,#1
          
          subq.l    #4,sp               ;* -> ptsout
          pea       -66(a6)             ;* -> intout
          subq.l    #4,sp               ;* -> ptsin
          pea       .element(a6)        ;* -> intin
          pea       16(sp)              ;* -> contrl

          moveq.l   #$73,d0
          move.l    sp,d1
          trap      #2

          lea       -66(a6),a0          ;* Pointer to intout.
          move.l    .namestr(a6),a1     ;* Pointer to caller's string.
          move.w    (a0)+,d0            ;* Return status from intout[0].
.strloop:
          move.w    (a0)+,d1            ;* Return normal string from
          move.b    d1,(a1)+            ;* intout[1-32].  Copy low byte of
          bne.s     .strloop            ;* each word to string byte.
          
          unlk      a6
          rts

;*------------------------------------------------------------------------
;* Inquire font information.
;*------------------------------------------------------------------------

_v_qt_fontinfo::
          .cargs    #8,.handle.w,.minade.l,.maxade.l,.dist.l,.maxw.l,.effects.l
          link      a6,#-24             ;* Allocate intout[2], ptsout[5].

          VContrl   #131
          
          pea       -20(a6)             ;* -> ptsout
          pea       -24(a6)             ;* -> intout
          subq.l    #8,sp               ;* -> ptsin
          pea       16(sp)              ;* -> contrl

          moveq.l   #$73,d0
          move.l    sp,d1
          trap      #2
          
          lea       -24(a6),a0          ;* Point to intout.
          move.l    .minade(a6),a1      ;* Return minADE
          move.w    (a0)+,(a1)          ;* from intout[0].
          move.l    .maxade(a6),a1      ;* Return maxADE
          move.w    (a0)+,(a1)          ;* from, intout[1].

          move.l    .maxw(a6),a1        ;* Return maxwidth
          move.w    (a0)+,(a1)          ;* from ptsout[0].
          
          move.l    a2,d2               ;* Save a2 for Laser C compatibility.
          move.l    .dist(a6),a1        ;* Pointer to distance
          move.l    .effects(a6),a2     ;* Pointer to effects
          
          move.w    (a0)+,(a1)+         ;* dist[0] = ptsout[1]
          move.w    (a0)+,(a2)+         ;* eff[0]  = ptsout[2]
          move.w    (a0)+,(a1)+         ;* dist[1] = ptsout[3]
          move.w    (a0)+,(a2)+         ;* eff[1]  = ptsout[4]
          move.w    (a0)+,(a1)+         ;* dist[2] = ptsout[5]
          move.w    (a0)+,(a2)+         ;* eff[2]  = ptsout[6]
          move.w    (a0)+,(a1)+         ;* dist[3] = ptsout[7]
          tst.w     (a0)+               ;* notused - pstout[8] 
          move.w    (a0),(a1)           ;* dist[4] = ptsout[9]
          
          move.l    d2,a2               ;* Restore a2.
          unlk      a6
          rts

;       end of code
