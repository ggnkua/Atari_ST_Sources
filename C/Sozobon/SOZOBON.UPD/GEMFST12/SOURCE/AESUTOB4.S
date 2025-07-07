
;*========================================================================
;*
;* AESFAST Public Domain GEM bindings.
;*  
;*========================================================================
 
;*************************************************************************
;*
;* AESUTOB4.S - Object-related utilities 4 of n.
;*  Non-standard utility functions.
;*
;*************************************************************************
         
          .include  "gemfast.sh"        ; Pull in header file.

;-------------------------------------------------------------------------
; objrb_which - Return index of selected radio button, -1 if none selected.
;         
;               More generally speaking, this returns the index of the first 
;               child of the specified parent which has a SELECTED bit set. 
;
;  int objrb_which(tree, parentobj);
;-------------------------------------------------------------------------

_objrb_which::
          .cargs    #4,.ptree.l,.obj
          move.l    .ptree(sp),a0
          move.w    .obj(sp),d2
          move.w    d2,d0
          muls      #OBJ_SIZ,d0
          move.w    ob_head(a0,d0.l),d0
          bmi.s     .notfound
.loop:
          move.w    d0,d1
          muls      #OBJ_SIZ,d1
          btst.b    #BSELECTED,ob_state+1(a0,d1.l)
          bne.s     .done
          move.w    ob_next(a0,d1.l),d0
          cmp.w     d0,d2
          bne.s     .loop
.notfound:
          moveq.l   #-1,d0
.done:
          tst.w     d0                  ; insure CCR return matches d0
          rts
          
;-------------------------------------------------------------------------
; obj_parent - Find the parent of a given object.
;              By definition, the root object has no parent, 0 is returned.
;              An unusual object tree could throw this routine into a loop,
;              but in a standard tree, all the next/tail pointers should
;              be in good shape, and a parent will be found.
;
;             
;  int obj_parent(tree, cur_object);
;-------------------------------------------------------------------------

_obj_parent::
          .cargs    #4,.ptree.l,.obj.w
          
          move.l    .ptree(sp),a0
          move.w    .obj(sp),d0
          beq.s     .done
.loop:
          move.w    d0,d2
          muls      #OBJ_SIZ,d0
          move.w    ob_next(a0,d0.l),d1
          move.w    d1,d0
          muls      #OBJ_SIZ,d1
          cmp.w     ob_tail(a0,d1.l),d2
          bne.s     .loop
.done:
          tst.w    d0
          rts
          
