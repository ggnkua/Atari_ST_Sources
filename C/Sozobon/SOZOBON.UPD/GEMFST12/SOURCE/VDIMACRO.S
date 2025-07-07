
;*========================================================================
;*
;* VDIFAST Public Domain VDI bindings.
;*
;*========================================================================

          .extern   vdicall   ; Let everyone see this routine's name.
          
;*************************************************************************
;*
;* VContrl macro.
;*  Setup the 'contrl' parm block.
;*  'opcode' is mandatory.  
;*  Subfunction and intin/ptsin counts are optional, and will be zeroed
;*  if they are not specified.
;*
;*************************************************************************

.macro    VContrl   opc,sub,pti,ini,hnd

          .if       \?hnd
          move.w    \hnd,-(sp)
          .else
          move.w    .handle(a6),-(sp)
          .endif
          
          .if       \?sub
          move.w    \sub,-(sp)
          subq.w    #2,sp
          .else
          clr.l     -(sp)
          .endif
          
          .if       \?ini
          move.w    \ini,-(sp)
          subq.w    #2,sp
          .else
          clr.l     -(sp)
          .endif
          
          .if       \?pti    
          move.w    \pti,-(sp)
          .else
          clr.w     -(sp)
          .endif
          
          move.w    \opc,-(sp)
.endm

