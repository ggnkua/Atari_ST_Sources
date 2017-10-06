;*************************************************************************
;* GRFXDRAG.S - Extended graf_dragbox() binding.
;*************************************************************************

          .include  "aesfast.sh"
          .extern   _gl_rwdesk
          
_grfx_dragbox::
          .cargs    #8,.startrect.l,.boundrect.l,.endrect.l
          link      a6,#-22   ; 8 intin + 6 intout
          
          move.l    .startrect(a6),a1   ; load ptr to starting rect
          move.l    .endrect(a6),a0     ; load ptr to ending rect
          move.l    4(a1),4(a0)         ; move starting w/h to ending w/h
          
          lea       -22(a6),a0          ; load ptr to intin
          move.l    4(a1),(a0)+         ; move starting w/h to intin
          move.l    (a1),(a0)+          ; move starting x/y to intin
          
          move.l    .boundrect(a6),a1   ; load ptr to bounding rect
          move.l    a1,d0               ; test for nullness
          bne.s     .notnull            ; if not null, all set
          lea       _gl_rwdesk,a1       ; else use desktop rect
.notnull:
          move.l    (a1)+,(a0)+         ; move bounding x/y to intin
          move.l    (a1),(a0)           ; move bounding w/h to intin
          
          AControl  71,8,3,0            ; set up call
          moveq.l   #-6,d2              ;  = intout
          lea       -22(a6),a1          ; -> intin
          ACall     RET2HERE

          move.l    .endrect(a6),a0     ; load ptr to ending rectangle
          lea       -6(a6),a1           ; load ptr to intout
          move.w    (a1)+,d0            ; intout[0] to d0
          move.l    (a1),(a0)           ; intout[1-2] to endrect x/y
          
          tst.w     d0                  ; set CCR for laser C
          unlk      a6                  ; undo stack frame
          rts                           ; and return
          
;         end of code

