
;*========================================================================
;*
;* AESFAST Public Domain GEM bindings.
;*
;*  04/06/89 v1.2
;*           Added line to objcl_calc() to mask off the upper byte of
;*           of the object type before going into the 'switch' block.
;*           This insures that extended object types won't screw up the
;*           clipping calcs.
;*
;*========================================================================
 
;*************************************************************************
;*
;* AESUTOB3.S - Object-related utilities 3 of n.
;*  Non-standard utility functions.
;*
;*************************************************************************
         
          .extern   _objc_offset        ; 
          .include  "gemfast.sh"        ; Pull in header file.

;-------------------------------------------------------------------------
;       
; objclX_adjust - Adjust a clipping rectangle.
;                These functions will expand or contract a clipping 
;                rectangle (GRECT=objclg_adjust or VRECT=objclv_adjust) 
;                by a given size.  
;                
;                A positive adjustment expands the area, and a negative
;                adjustment shrinks it.
;
;  void obclX_adjust(&rect, horiz_adjust, vert_adjust);
;-------------------------------------------------------------------------

_objclg_adjust::
          moveq.l   #1,d2
          bra.s     objadjust
          
_objcl_adjust::               ; old name retained for compatibility
_objclv_adjust::

          moveq.l   #0,d2
objadjust:
          .cargs    #4,.prect.l,.hadj,.vadj
          
          move.l    .prect(sp),a0
          move.w    .hadj(sp),d0
          move.w    .vadj(sp),d1
          sub.w     d0,(a0)+
          sub.w     d1,(a0)+
          tst.w     d2
          beq.s     .no_double
          add.w     d0,d0
          add.w     d1,d1
.no_double:
          add.w     d0,(a0)+
          add.w     d1,(a0)
          rts
                
;-------------------------------------------------------------------------
; objcl_calc - Return clipping rectangle(s) (x,y,w,h & x1,y1,x2,y2) 
;              from object's coordinates. 
;
;  This routine simultaneously calculates the GRECT and VRECT clipping
;  rectangles that describe an object.   
;
;  If object has outside borders or is OUTLINED and/or SHADOWED,
;  clipping sizes are calc'd accordingly.
;
;  (This routine started out short and gracefull...)
;
;   void objcl_calc (tree, object, {&grect|NULL},{&vrect|NULL});
;-------------------------------------------------------------------------

_objcl_calc::

          .cargs    #-20,.off_x,.off_y,.gx,.gy,.gw,.gh,.vx1,.vy1,.vx2,.vy2
          .cargs    #8,.ptree.l,.obj.w,.pgrect.l,.pvrect.l

          link      a6,#-20
          move.l    a2,-(sp)            ; This keeps Laser C happy.
          
          pea       .off_y(a6)          ; First get the screen offsets
          pea       .off_x(a6)          ; of the object via objc_offset.
          move.w    .obj(a6),-(sp)
          move.l    .ptree(a6),-(sp)
          jsr       _objc_offset
          lea       14(sp),sp

          move.l    .ptree(a6),a0       ; build a pointer to the object.
          move.w    .obj(a6),d0
          muls      #OBJ_SIZ,d0
          add.l     d0,a0

          moveq.l   #0,d1               ; Init adjust val for all sides and
          moveq.l   #0,d2               ; extra adjust for right & bottom.

          move.w    ob_type(a0),d0      ; switch (ob_type) 
          and.w     #$00FF,d0           ; mask out any extended object type
          cmp.w     #G_BOX,d0
          beq.s     .box
          cmp.w     #G_IBOX,d0
          beq.s     .box
          cmp.w     #G_BOXCHAR,d0
          beq.s     .box
          cmp.w     #G_BOXTEXT,d0
          beq.s     .text
          cmp.w     #G_FBOXTEXT,d0      ; If the object is not one of these
          beq.s     .text               ; types, it won't have any outer
          cmp.w     #G_BUTTON,d0        ; width, but could still be 
          bne.s     .outline            ; OUTLINED or SHADOWED.
.button:
          subq.w    #1,d1                         ; Any button has an outer
          btst.b    #BEXIT,ob_flags+1(a0)          ; width of at least 1.
          beq.s     .outline                      ; An EXIT button has a
          subq.w    #1,d1                         ; width of 2, and 
          btst.b    #BDEFAULT,ob_flags+1(a0)       ; a DEFAULT EXIT button
          beq.s     .outline                      ; has a width of 3.
          subq.w    #1,d1
          bra.s     .outline
.box:
          move.b    ob_spec+1(a0),d1              ; A box's width is
          ext.w     d1                            ; contained in ob_spec,
          bra.s     .outline                      ; in byte $00nn0000.
.text:
          move.l    ob_spec(a0),a1                ; Width of a text object
          move.w    te_thickness(a1),d1           ; is in the TEDINFO.
.outline:
          move.w    d1,d0                         ; Save true width for
          btst.b    #BOUTLINED,ob_state+1(a0)      ; shadow calcs. If object
          beq.s     .not_outlined                 ; is outlined, the new
          cmp.w     #-3,d1                        ; outer width is -3 unless
          blt.s     .not_outlined                 ; the true width was
          moveq.l   #-3,d1                        ; already bigger.
.not_outlined:
          btst.b    #BSHADOWED,ob_state+1(a0)      ; If object is shadowed
          beq.s     .notshadowed                  ; we need to adjust right
          tst.w     d0                            ; and bottom sides. Rule
          bpl.s     .notnegshadow                 ; for shadow's width is
          neg.w     d0                            ; that the shadow is twice
.notnegshadow:                                    ; the absolute value of
          move.w    d0,d2                         ; the object's width (not
          add.w     d2,d2                         ; counting OUTLINE width).
.notshadowed:
          tst.w     d1                            ; Check accumulated width.
          bmi.s     .outsidewidth                 ; If positive, the object
          moveq.l   #0,d1                         ; has inner width, ignore.
.outsidewidth:
          lea       .gx(a6),a1          ; Get ready to do output.  Get
          move.l    .pgrect(a6),d0      ; pointer to user's GRECT, if null
          beq.s     .nogrect            ; build GRECT into dummy area.
          move.l    d0,a1
.nogrect:
          lea       .vx1(a6),a2         ; Get pointer to user's VRECT,
          move.l    .pvrect(a6),d0      ; if null, build VRECT into dummy
          beq.s     .novrect            ; area.
          move.l    d0,a2
.novrect:
          move.l    .off_x(a6),d0       ; Load the screen x/y we got earlier,
          move.l    d0,(a1)             ; store it all over the place...
          move.l    d0,(a2)
          move.l    d0,4(a2)
          move.w    ob_w(a0),d0
          move.w    d0,4(a1)
          add.w     d0,4(a2)
          move.w    ob_h(a0),d0
          move.w    d0,6(a1)
          add.w     d0,6(a2)

          subq.w    #1,d1               ; Subtract one from calc'd size
          add.w     d1,(a1)             ; for clipping, add sizes to
          add.w     d1,(a2)             ; x/y/w/h values in rectangles...
          add.w     d1,2(a1)
          add.w     d1,2(a2)
          addq.w    #1,d1               ; Add the one back in.
          neg.w     d1
          add.w     d1,4(a2)
          add.w     d1,6(a2)
          lsl.w     #1,d1
          addq.w    #1,d1
          add.w     d1,4(a1)
          add.w     d1,6(a1)

          add.w     d2,4(a1)            ; Add in shadow sizes to right
          add.w     d2,6(a1)            ; and bottom numbers.
          add.w     d2,4(a2)
          add.w     d2,6(a2)
          
          move.l    (sp)+,a2            ; Restore Laser C register.
          unlk      a6
          rts

;         end of code

