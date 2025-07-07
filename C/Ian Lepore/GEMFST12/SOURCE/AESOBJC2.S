
;*========================================================================
;*
;* AESFAST Public Domain GEM bindings.
;*
;*========================================================================

        .include        "aesfast.sh"
          
;*************************************************************************
;*
;* Object Library routines 2 of 2.
;*
;*************************************************************************

;-------------------------------------------------------------------------
; objc_offset
;-------------------------------------------------------------------------

_objc_offset::
          .cargs    #8,.ptree.l,.obj,.px.l,.py.l

          link      a6,#-6              ; allocate intout[3].
          
          AControl  44,1,3,1
          
          moveq.l   #-6,d2              ;  = intout
          lea       .obj(a6),a1         ; -> intin
          lea       .ptree(a6),a0       ; -> addrin

          ACall     RET2HERE

          moveq.l   #-6,d1
          lea       .px(a6),a1
          jmp       (a0)

;-------------------------------------------------------------------------
; objc_edit
;-------------------------------------------------------------------------

_objc_edit::
          .cargs    #8,.ptree.l,.obj,.char,.idx,.kind,.pnewidx.l

          link      a6,#-4              ; allocate intout[2].

          AControl  46,4,2,1
          
          moveq.l   #-4,d2              ; -> intout
          lea       .obj(a6),a1         ; -> intin
          lea       .ptree(a6),a0       ; -> addrin

          ACall     RET2HERE

          move.w    -4(a6),d0
          move.l    .pnewidx(a6),a1
          move.w    -2(a6),(a1)
          unlk      a6
          rts

;         end of code

