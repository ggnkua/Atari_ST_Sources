;  WRAP Mouse
;  Joystick-Teil
;
;  (c)1992 by Richard Kurz
;  Vogelherdbogen 62
;  7992 Tettnang
;  Fido 2:241/7232
;
;  FÅr's TOS-Magazin
;

export old_joy,new_joy,init_vbl
import chk_joy,do_vbljoy,rs_vbl

**********************************************************************

; die neue Joystickroutine!

    dc.b 'XBRA'        ;XBRA 
    dc.b 'WrAp'        ;Angelegenheiten.
old_joy:
    dc.l    1
new_joy:
    movem.l d0-A6,-(SP)
    bsr     chk_joy;
    movem.l (SP)+,d0-A6
    rts

**********************************************************************
; Routine fÅr den VBL-Slot

    dc.b 'XBRA'        ;XBRA 
    dc.b 'WrAp'        ;Angelegenheiten.
    dc.l 0             ;Nur Show.
new_vbl:               ;VBL Routine.
    movem.l d0-A6,-(SP)
    move.w  sr,-(sp)
    move.w  #$2700,sr
    bsr     do_vbljoy
    bsr     rs_vbl
end_vbl: 
    move.w  (sp)+,sr
    movem.l (SP)+,d0-A6
    rts                ;VBL EnTe.

**********************************************************************
; sucht einen leeren VBL-Slot und richtet ihn ein

nvbls       equ $454        ;Wieviel Slots.
vblslots    equ $456        ;VBL Slots.

init_vbl:                   ;VBL-Routine
    move.w  nvbls,d0        ;in einem leeren
    lsl.w   #2,d0           ;Slot installieren.
    move.l  vblslots,a0
    moveq   #4,d1
s_slot:
    tst.l   (a0,d1)         ;Slot leer?
    beq     slot_gef        ;Juchu.
    addq    #4,d1           ;Nein, der NÑchste.
    cmp.w   d0,d1           ;Alle Slots voll?
    bne     s_slot          ;No.
    moveq   #0,d0
    rts                     ;Kein freier Slot!

slot_gef:                   ;EinhÑngen.
    move.l  #new_vbl,0(a0,d1)
    moveq   #1,d0
    rts                     ;Bye Bye.
