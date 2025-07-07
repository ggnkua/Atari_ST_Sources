
;*========================================================================
;*
;* VDIFAST Public Domain VDI bindings.
;*
;*========================================================================

          .iif      !(^^macdef VContrl),.include  "vdimacro.s"
                    
;*************************************************************************
;*
;* Escape functions 2.
;*  The rest of the escape functions.
;*************************************************************************

;*-----------------------------------------------------------------------
;* Inquire addressable alpha character cells.  Right.
;*-----------------------------------------------------------------------

_vq_chcells::
          .cargs    #8,.handle.w,.rows.l,.columns.l
          link      a6,#-4

          VContrl   #5,#1
          
          subq.l    #4,sp               ;* -> ptsout
          pea       -4(a6)              ;* -> intout 
          subq.l    #8,sp               ;* -> intin
          pea       16(sp)              ;* -> contrl

          moveq.l   #$73,d0
          move.l    sp,d1
          trap      #2

          move.l    .rows(a6),a0
          move.w    -4(a6),(a0)         ;* Return rows.
          move.l    .columns(a6),a0
          move.w    -2(a6),(a0)         ;* Return columns.

          unlk      a6
          rts

;*-----------------------------------------------------------------------
;* Direct alpha cursor address.
;*-----------------------------------------------------------------------

_vs_curaddress::
          .cargs    #8,.handle.w,.row.w,.col.w
          link      a6,#0

          VContrl   #5,#1,,#2
          
          lea       -12(sp),sp
          pea       .row(a6)            ;* -> intin
          pea       16(sp)              ;* -> contrl

          jmp       vdicall
          
;*-----------------------------------------------------------------------
;* Inquire current alpha cursor address.
;*-----------------------------------------------------------------------

_vq_curaddress::

          .cargs    #8,.handle.w,.row.l,.col.l
          link      a6,#-4

          VContrl   #5,#15
          
          subq.l    #4,sp               ;* -> ptsout
          pea       -4(a6)              ;* -> intout 
          subq.l    #8,sp               ;* -> intin
          pea       16(sp)              ;* -> contrl

          moveq.l   #$73,d0
          move.l    sp,d1
          trap      #2

          move.l    .row(a6),a0
          move.w    -4(a6),(a0)         ;* Return row.
          move.l    .col(a6),a0
          move.w    -2(a6),(a0)         ;* Return column.

          unlk      a6
          rts
          
;*-----------------------------------------------------------------------
;* Place graphic cursor at location.
;*-----------------------------------------------------------------------

_v_dspcur::
          .cargs    #8,.handle.w,.x.w,.y.w
          link      a6,#0
          
          VContrl   #5,#15,#1
          
          subq.l    #8,sp               ;* -> intout 
          pea       .x(a6)              ;* -> ptsin
          pea       16(sp)              ;* -> contrl

          jmp       vdicall

;*-----------------------------------------------------------------------
;* Output window contents to printer. (Or something like that).
;*-----------------------------------------------------------------------

_v_output_window::
          .cargs    #8,.handle.w,.pxy.l
          link      a6,#0
          
          VContrl   #5,#21,#2
          
          subq.l    #8,sp
          move.l    .pxy(a6),-(sp)      ;* -> ptsin
          subq.l    #4,sp               ;* -> intin
          pea       16(sp)              ;* -> contrl

          jmp       vdicall

;*-----------------------------------------------------------------------
;* Output bit image file.  Not supported in this release.
;*-----------------------------------------------------------------------

;*-----------------------------------------------------------------------
;* Select pallete.  This has something to do with IBMPC screens...
;*-----------------------------------------------------------------------

_vs_palette::
          .cargs    #8,.handle.w,.palette.w
          link      a6,#0
          VContrl   #5,#60,,#1
          
          lea       -12(sp),sp
          pea       .palette(a6)        ;* -> intin
          pea       16(sp)              ;* -> contrl

          jmp       vdicall
          
;*-----------------------------------------------------------------------
;* NOTE:
;*  You can stop looking here.  The Poloroid Palette Driver and Metafile
;*  escape calls are not supported in this release.
;*-----------------------------------------------------------------------

;*        end of code

