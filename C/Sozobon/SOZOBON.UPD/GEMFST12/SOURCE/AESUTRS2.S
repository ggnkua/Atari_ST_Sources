
;*========================================================================
;*
;* AESFAST Public Domain GEM bindings.
;*
;*========================================================================
 
;*************************************************************************
;*
;* AESUTRS2.S - Resource-related Utilities 2 of n.
;*  Non-standard utility functions.
;*
;*************************************************************************

          .include  "gemfast.sh"

;-------------------------------------------------------------------------
; rsc_gstrings - Get pointers to strings within a tree.
;
;               This function gets one or more string pointers from within
;               a resource tree.  It knows the difference between strings
;               and buttons and text objects, and gets the ob_spec or
;               te_ptext pointer as appropriate. It accepts a variable
;               number of object/pointer pairs, with a negative object
;               index indicating the end of the list.
;
;               In this function, ptr1, ptr2, etc are the addresses of
;               the pointers you want to initialize...
;  void rsc_sstrings(tree, obj1,ptr1 [,obj2,ptr2,...,objn,ptrn], -1);
;-------------------------------------------------------------------------

_rsc_gstrings::

          .cargs    #12,.ptree.l,.parms

          movem.l    a2-a3,-(sp)            ; Save Laser C register.
          move.l    .ptree(sp),a3
          lea       .parms(sp),a2
.loop:
          move.w    (a2)+,d2
          bmi.s     .done
          move.l    (a2)+,a0
          muls      #OBJ_SIZ,d2
          move.w    ob_type(a3,d2.l),d1
          and.w     #$00FF,d1           ; remove extended object type data
          cmp.w     #G_STRING,d1
          beq.s     .string
          cmp.w     #G_BUTTON,d1
          beq.s     .string
.text:    
          move.l    ob_spec(a3,d2.l),a1
          move.l    (a1),(a0)
          bra.s     .loop
.string:
          move.l    ob_spec(a3,d2.l),(a0)
          bra.s     .loop
.done:
          movem.l    (sp)+,a2-a3            ; Restore Laser C register.
          rts

          
;         end of code
 
