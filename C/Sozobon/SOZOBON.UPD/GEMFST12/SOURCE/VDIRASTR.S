
;*========================================================================
;*
;* VDIFAST Public Domain VDI bindings.
;*
;*========================================================================

          .iif      !(^^macdef VContrl),.include  "vdimacro.s"
          
;*************************************************************************
;*
;* Raster functions. 
;*
;*************************************************************************

;*------------------------------------------------------------------------
;* Copy raster transparent.
;* Copy raster opaque.
;*  These functions are pretty similar, so they're kludged together here.
;*------------------------------------------------------------------------

_vrt_cpyfm::
          .cargs    #8,.handle.w,.wrmode.w,.pxy.l,.psource.l,.pdest.l,.color.l
          link      a6,#0
          
          moveq.l   #121,d0             ;* Function code = copy transparent
          moveq.l   #3,d1               ;* Number of intin words = 3. 
          move.l    .color(a6),a0       ;* Get the pointer to the 2-word
          move.l    (a0),-(sp)          ;* color array, copy values to the
          move.w    .wrmode(a6),-(sp)   ;* stack, add the writing mode.
          move.l    sp,a0               ;* Save a pointer to intin.
          bra.s     vr_cpyfm            ;* Continue at common point below.
          
_vro_cpyfm::

          .cargs    #8,.handle.w,.wrmode.w,.pxy.l,.psource.l,.pdest.l
          link      a6,#0
          
          moveq.l   #109,d0             ;* Function code = copy opaque.
          moveq.l   #1,d1               ;* Number of intin words = 1.
          lea       .wrmode(a6),a0      ;* Save a pointer to intin.
vr_cpyfm:
          .cargs    #8,.handle.w,.wrmode.w,.pxy.l,.psource.l,.pdest.l ;* This is dup'd here due to local symbol scope being trashed by the vr_cpyfm label.

          move.l    .pdest(a6),-(sp)    ;* contrl[9-10] -> dest mfdb.
          move.l    .psource(a6),-(sp)  ;* contrl[7-8]  -> source mfdb.

          VContrl   d0,,#4,d1           ;* Setup the rest of the contrl stuff.
          
          subq.l    #8,sp               ;* intout/ptsout
          move.l    .pxy(a6),-(sp)      ;* -> ptsin
          move.l    a0,-(sp)            ;* -> intin
          pea       16(sp)              ;* -> contrl

          jmp       vdicall
          
;*------------------------------------------------------------------------
;* Get pixel.
;*------------------------------------------------------------------------

_v_get_pixel::
          .cargs    #8,.handle.w,.x.w,.y.w,.pel.l,.index.l
          link      a6,#-4              ;* Allocate intout[2].
          
          VContrl   #105,,#1
          
          subq.l    #4,sp               ;* -> ptsout
          pea       -4(a6)              ;* -> intout
          pea       .x(a6)              ;* -> ptsin
          subq.l    #4,sp               ;* -> intin
          pea       16(sp)              ;* -> contrl

          moveq.l   #$73,d0
          move.l    sp,d1
          trap      #2

          move.l    .pel(a6),a0         ;* Return pixel value
          move.w    -4(a6),(a0)         ;* from intout[0].
          move.l    .index(a6),a0       ;* Return index value
          move.w    -2(a6),(a0)         ;* from intout[1].
 
          unlk      a6
          rts

;*         end of code.                     
