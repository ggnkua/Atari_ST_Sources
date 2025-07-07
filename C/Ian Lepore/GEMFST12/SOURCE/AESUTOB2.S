
;*========================================================================
;*
;* AESFAST Public Domain GEM bindings.
;*
;*========================================================================
 
;*************************************************************************
;*
;* AESUTOB2.S - Object-related utilities 2 of n.
;*  Non-standard utility functions.
;*
;*************************************************************************
         
          .include  "gemfast.sh"        ; Pull in header file.

;-------------------------------------------------------------------------
; objc_xywh - Return object's xywh into GRECT structure.
;
;  void objc_xywh(tree, object, &grect);
;-------------------------------------------------------------------------

_obj_xywh::
_objc_xywh::
          .cargs    #4,.ptree.l,.obj.w,.prect.l
          
          move.l    .prect(sp),a1
          move.l    .ptree(sp),a0
          move.w    .obj(sp),d0
          muls      #OBJ_SIZ,d0
          lea       ob_x(a0,d0.l),a0
          move.l    (a0)+,(a1)+
          move.l    (a0),(a1)
          rts

;         end of code

