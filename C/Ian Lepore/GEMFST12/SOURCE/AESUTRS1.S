
;*========================================================================
;*
;* AESFAST Public Domain GEM bindings.
;*
;*========================================================================
 
;*************************************************************************
;*
;* AESUTRS1.S - Resource-related Utilities 1 of 3.
;*  Non-standard utility functions.
;*
;*************************************************************************

          .include  "gemfast.sh"

;-------------------------------------------------------------------------
; rsc_strings - Set pointers to strings within a tree.
; rsc_sstrings  (New name).
;               This function sets one or more string pointers within a 
;               resource tree.  It knows the difference between strings
;               and buttons and text objects, and sets the ob_spec or
;               te_ptext pointer as appropriate. It accepts a variable
;               number of object/pointer pairs, with a negative object
;               index indicating the end of the list.
;
;  void rsc_sstrings(tree, obj1,ptr1 [,obj2,ptr2,...,objn,ptrn], -1);
;-------------------------------------------------------------------------

_rsc_sstrings::
_rsc_strings::                ; old name retained for compatibility

          .cargs    #8,.ptree.l,.parms

          move.l    a2,-(sp)            ; Save Laser C register.
          move.l    .ptree(sp),a2
          lea       .parms(sp),a1
.loop:
          move.w    (a1)+,d2
          bmi.s     .done
          move.l    (a1)+,d0
          muls      #OBJ_SIZ,d2
          move.w    ob_type(a2,d2.l),d1
          and.w     #$00FF,d1           ; remove extended object type data
          cmp.w     #G_STRING,d1
          beq.s     .string
          cmp.w     #G_BUTTON,d1
          beq.s     .string
.text:    
          move.l    ob_spec(a2,d2.l),a0
          move.l    d0,(a0)
          bra.s     .loop
.string:
          move.l    d0,ob_spec(a2,d2.l)
          bra.s     .loop
.done:
          move.l    (sp)+,a2            ; Restore Laser C register.
          rts
          
;         end of code

