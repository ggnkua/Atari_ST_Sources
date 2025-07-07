
;*========================================================================
;*
;* VDIFAST Public Domain VDI bindings.
;*
;*========================================================================

          .iif      !(^^macdef VContrl),.include  "vdimacro.s"

;*************************************************************************
;*
;* Attribute functions 1.
;*  This random collection is all in one module because if you use any
;*  one of these functions the overhead of having them all linked in is
;*  only about 50 bytes.
;*  
;* vatt_1i1r        - Internal routine.
;* _vswr_mode       - Set writing mode.
;* _vsl_type        - Set polyline type.
;* _vsl_udsty       - Set polyline user-defined style.
;* _vsl_color       - Set polyline color.
;* _vsm_type        - Set polymarker type.
;* _vsm_color       - Set polymarker color.
;* _vst_rotation    - Set text baseline angle.
;* _vst_font        - Set text font/face.
;* _vst_color       - Set text color.
;* _vst_effects     - Set text special effects.
;* _vsf_interior    - Set fill interior type.
;* _vsf_style       - Set fill interior style.
;* _vsf_color       - Set fill interior color.
;* _vsf_perimeter   - Set fill perimeter visibility.
;*
;*************************************************************************

;*------------------------------------------------------------------------
;*-----------------------------------------------------------------------
;* vatt_1i1r
;*  For VDI attribute calls that use 1 intin, 1 intout (most of them).
;*  Entry:  d0.w = VDI function number.
;*-----------------------------------------------------------------------
;*------------------------------------------------------------------------

vatt_1i1r:
          .cargs    #8,.handle.w,.integer.w
          link      a6,#-2

          VContrl   d0,,,#1
          
          subq.l    #4,sp               ;* -> ptsout
          pea       -2(a6)              ;* -> intout
          subq.l    #4,sp               ;* -> ptsin
          pea       .integer(a6)        ;* -> intin
          pea       16(sp)              ;* -> contrl

          jmp       vdicall

;*------------------------------------------------------------------------
;* Attribute stuff that uses 1 intin, 1 intout...
;*------------------------------------------------------------------------

_vswr_mode::                            ;* Set writing mode.
          moveq.l   #32,d0
          bra       vatt_1i1r
_vsl_type::                             ;* Set polyline type.
          moveq.l   #15,d0
          bra       vatt_1i1r
_vsl_udsty::                            ;* Set polyline user-defined style.
          moveq.l   #113,d0
          bra       vatt_1i1r
_vsl_color::                            ;* Set polyline color.
          moveq.l   #17,d0
          bra       vatt_1i1r
_vsm_type::                             ;* Set polymarker type.
          moveq.l   #18,d0
          bra       vatt_1i1r
_vsm_color::                            ;* Set polymarker color.
          moveq.l   #20,d0
          bra       vatt_1i1r
_vst_rotation::                         ;* Set text baseline angle.
          moveq.l   #13,d0
          bra.s     vatt_1i1r
_vst_font::                             ;* Set text font/face.
          moveq.l   #21,d0
          bra       vatt_1i1r
_vst_color::                            ;* Set text color.
          moveq.l   #22,d0
          bra.s     vatt_1i1r
_vst_effects::                          ;* Set text special effects.
          moveq.l   #106,d0
          bra.s     vatt_1i1r
_vsf_interior::                         ;* Set fill interior type.
          moveq.l   #23,d0
          bra.s     vatt_1i1r
_vsf_style::                            ;* Set fill interior style.
          moveq.l   #24,d0
          bra.s     vatt_1i1r
_vsf_color::                            ;* Set fill interior color.
          moveq.l   #25,d0
          bra.s     vatt_1i1r
_vsf_perimeter::                        ;* Set fill perimeter visibility.
          moveq.l   #104,d0
          bra.s     vatt_1i1r

