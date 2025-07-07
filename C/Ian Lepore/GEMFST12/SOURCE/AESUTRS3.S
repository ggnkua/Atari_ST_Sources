
;*========================================================================
;*
;* AESFAST Public Domain GEM bindings.
;*
;*========================================================================
 
;*************************************************************************
;*
;* AESUTRS3.S - Resource-related Utilities 3 of n.
;*  Non-standard utility functions.
;*
;*************************************************************************

          .extern   _rsrc_obfix
          .include  "gemfast.sh"

;-------------------------------------------------------------------------
; rsc_treefix - Do rsrc_obfix for an entire tree.
;
;  void rsc_treefix(tree);
;-------------------------------------------------------------------------

_rsc_treefix::
          .cargs    #4,.ptree.l
          move.l    .ptree(sp),a0
          movem.l   d3/a3,-(sp)
          move.l    a0,a3
          moveq.l   #-1,d3
.loop:
          addq.w    #1,d3
          move.w    d3,-(sp)
          move.l    a3,-(sp)
          jsr       _rsrc_obfix
          addq.l    #6,sp
          move.w    d3,d0
          muls      #OBJ_SIZ,d0
          btst.b    #BLASTOB,ob_flags+1(a3,d0.l)
          beq.s     .loop
          movem.l   (sp)+,d3/a3
          rts
          
;         end of code

