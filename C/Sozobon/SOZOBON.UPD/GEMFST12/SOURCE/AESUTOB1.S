
;*========================================================================
;*
;* AESFAST Public Domain GEM bindings.
;*
;*========================================================================
 
;*************************************************************************
;*
;* AESUTOB1.S - Object-related utilities 1 of n.
;*  Non-standard utility functions.
;*
;*************************************************************************
         
          .extern   _objc_draw          ; We call this standard AES func.
          .extern   _objcl_calc         ; We call this non-standard util.
          
          .include  "gemfast.sh"        ; Pull in header file.

;-------------------------------------------------------------------------
; objfl_change - Set or reset object flag, optionally update screen.
;                If high bit of new flags is set (negative) the flags
;                will be ANDed, otherwise they're ORed.  Confused?  This
;                allows the following to work as you'd expect:
;
; objfl_change(maintree, BOX3,  HIDETREE, TRUE): /* hide   box3, redraw /
; objfl_change(maintree, BOX3, ~HIDETREE, TRUE): /* unhide box3, redraw */ 
;
;  void objfl_change(tree, object, flagmask, update);
;-------------------------------------------------------------------------

_objfl_change::

          .cargs    #8,.ptree.l,.obj.w,.flag.w,.update.w
          link      a6,#0
          
          move.l    .ptree(a6),a0       ; Build a pointer to the
          move.w    .obj(a6),d0         ; desired object in
          muls      #OBJ_SIZ,d0         ; the tree.
          add.l     d0,a0
          
          move.w    .flag(a6),d0        ; Get/check the flag(s) to change.
          bmi.s     .reset              ; If neg, we need to reset flag,
          or.w      d0,ob_flags(a0)     ; else we set flag,
          bra.s     .checkupdate        ; and continue below.
.reset:
          and.w     d0,ob_flags(a0)     ; Reset the flag.
.checkupdate:
          tst.w     .update(a6)         ; Does caller want objc_draw?
          beq.s     .done               ; If not, we're done.

          clr.l     -(sp)
          clr.l     -(sp)               ; Allocate clipping rectangle then
          move.l    sp,(sp)             ; make 1st long point to itself.
          move.w    .obj(a6),-(sp)      ; Stack the tree and object index,
          move.l    .ptree(a6),-(sp)    ; and call the grect clip calc'er.
          jsr       _objcl_calc         ; It will overlay the pointer we
          addq.l    #6,sp               ; stacked with the clip info, clean
          move.w    #9,-(sp)            ; the stack up to the clip info, 
          clr.w     -(sp)               ; then stack up objc_draw parms to
          move.l    .ptree(a6),-(sp)    ; to a redraw of the whole tree,
          jsr       _objc_draw          ; clipped by the object we changed.
.done:
          unlk      a6                  ; Unstack everything, and
          rts                           ; return to caller.
          
;-------------------------------------------------------------------------
; objst_change - Set or reset object state, optionally update screen.
;                If high bit of new flags is set (negative) the flags
;                will be ANDed, otherwise they're ORed.  Confused?  This
;                allows the following to work as you'd expect:
;
; objst_change(maintree, BTN3,  SELECTED, TRUE): /* sel    btn3, redraw /
; objst_change(maintree, BTN3, ~SELECTED, TRUE): /* desel  btn3, redraw */ 
;
;  void objst_change(tree, object, flagmask, update);
;-------------------------------------------------------------------------

_objst_change::

          .cargs    #8,.ptree.l,.obj.w,.flag.w,.update.w
          link a6,#0
          
          move.l    .ptree(a6),a0       ; Build a pointer to the
          move.w    .obj(a6),d0         ; desired object in
          muls      #OBJ_SIZ,d0         ; the tree.
          add.l     d0,a0
          
          move.w    .flag(a6),d0        ; Get/check the flag(s) to change.
          bmi.s     .reset              ; If neg, we need to reset flag,
          or.w      d0,ob_state(a0)     ; else we set flag,
          bra.s     .checkupdate        ; and continue below.
.reset:
          and.w     d0,ob_state(a0)     ; Reset the flag.
.checkupdate:
          tst.w     .update(a6)         ; Does caller want objc_draw?
          beq.s     .done               ; If not, we're done.

          move.l    #$7FFF7FFF,-(sp)    ; Do objc_draw on object, with
          clr.l     -(sp)               ; a max-sized clipping rectangle.
          move.w    #9,-(sp)            ; 
          move.w    .obj(a6),-(sp)      ; Start draw at changed object.
          move.l    .ptree(a6),-(sp)    ; 
          jsr       _objc_draw          ; Go do it.
.done:
          unlk      a6                  ; Unstack everything, and
          rts                           ; return to caller.
          
