         globl ob_dostate
         globl ob_undostate
         globl ob_isstate
         globl ob_doflag
         globl ob_undoflag
         globl ob_isflag
         globl ob_xywh
         globl ob_get_text
         globl ob_set_text
         globl ob_draw_dialog
         globl ob_undraw_dialog

         globl form_center
         globl form_dial
         globl objc_draw


G_TEXT   = 21
G_BOXTEXT= 22
G_BUTTON = 26
G_STRING = 28
G_FTEXT  = 29
G_FBOXTEXT= 30
G_TITLE  = 32


ob_dostate:
         mulu #24,d0
         or d1,10(a0,d0)   ;Statusbit setzen
         rts


ob_undostate:
         not d1
         mulu #24,d0       ;Statusbit zurÅcksetzen
         and d1,10(a0,d0)
         rts


ob_isstate:
         mulu #24,d0
         and 10(a0,d0),d1  ;Statusbit testen
         bne sset
         clr d0
         rts
sset:    moveq #1,d0
         rts


ob_doflag:
         mulu #24,d0
         or d1,8(a0,d0)    ;Objekflag setzen
         rts


ob_undoflag:
         not d1
         mulu #24,d0
         and d1,8(a0,d0)   ;Objektflag setzen
         rts


ob_isflag:
         mulu #24,d0
         and 8(a0,d0),d1   ;Objektflag testen
         bne fset
         clr d0
         rts
fset:    moveq #1,d0
         rts


ob_xywh:
         mulu #24,d0
         move.l 16(a0),(a1)+
         move.l 20(a0),(a1)
         rts


ob_get_text:
         bsr typetest      ;auf Objekttyp testen
         move.l (a0),a0
         tst d1            ;String initialisieren?
         beq noinit        ;nein-
         clr.b (a0)
noinit:  rts


ob_set_text:
         bsr typetest
         move.l a1,(a0)    ;neuen Stringpointer setzen
         rts


typetest:
         mulu #24,d0
         move.b 7(a0,d0),d2         ;Objekttyp
         cmp.b #G_TEXT,d2
         beq text
         cmp.b #G_FTEXT,d2
         beq text
         cmp.b #G_FBOXTEXT,d2
         beq text
         cmp.b #G_BOXTEXT,d2
         beq string
         cmp.b #G_STRING,d2
         beq string
         cmp.b #G_BUTTON,d2
         beq string
         cmp.b #G_TITLE,d2
         beq string
         sub.l a0,a0
         addq.l #4,sp               ;Abbruch, falls kein Textobjekt
         rts
text:    move.l 12(a0,d0),a0
         rts
string:  lea 12(a0,d0),a0
         rts


ob_draw_dialog:
         link a6,#-16
         bsr center
         clr -2(a6)        ;FMD_START
         bsr dial
         move -4(a6),d0    ;x
         or -6(a6),d0      ;y
         or -8(a6),d0      ;w
         or 8(a6),d0       ;h
         beq nogrow        ;keine growbox zeichnen-
         move #1,-2(a6)    ;FMD_GROW
         bsr dial
nogrow:  lea -16(a6),a1    ;Pointer auf zentrierte Koordinaten
         move (a1)+,-(sp)  ;h
         move (a1)+,-(sp)  ;w
         move (a1)+,-(sp)  ;y
         move (a1),d2      ;x
         moveq #127,d1     ;alle Ebenen (127 sollten reichen)
         clr d0            ;ab Ebene 0
         bsr objc_draw
         addq.l #6,sp
         unlk a6
         rts


ob_undraw_dialog:
         link a6,#-16
         bsr center
         move -4(a6),d0    ;x
         or -6(a6),d0      ;y
         or -8(a6),d0      ;w
         or 8(a6),d0       ;h
         beq noshrink      ;keine shrinkbox zeichnen-
         move #2,-2(a6)    ;FMD_SHRINK
         bsr dial
noshrink:move #3,-2(a6)    ;FMD_FINISH
         bsr dial
         unlk a6
         rts


center:
         move d2,-8(a6)    ;fo_dilittlw
         move d1,-6(a6)    ;fo_dilittly
         move d0,-4(a6)    ;fo_dilittlx
         move.l a0,-(sp)
         lea -10(a6),a1
         pea -16(a6)
         pea -14(a6)
         pea -12(a6)
         bsr form_center
         lea 12(sp),sp
         move.l (sp)+,a0
         rts

dial:
         move.l a0,-(sp)   ;Objektadresse merken
         lea -16(a6),a1    ;Pointer auf zentrierte Koordinaten
         move (a1)+,-(sp)  ;fo_dibigh
         move (a1)+,-(sp)  ;fo_dibigw
         move (a1)+,-(sp)  ;fo_dibigy
         move (a1),-(sp)   ;fo_dibigx
         move 8(a6),-(sp)  ;fo_dilittlh
         move -8(a6),-(sp) ;fo_dilittlw
         move -6(a6),d2    ;fo_dilittly
         move -4(a6),d1    ;fo_dilittlx
         move -2(a6),d0    ;fo_diflag
         bsr form_dial
         lea 12(sp),sp
         move.l (sp)+,a0
         rts
