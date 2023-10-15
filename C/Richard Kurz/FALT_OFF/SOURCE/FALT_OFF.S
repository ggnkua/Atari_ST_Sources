; Listing 1: FALT_OFF.S
; Version 1.1
; Dieses kleine Machwerk kÑmpft gegen das 
; Bildschirm-Falten auf dem (MEGA) STE.
; Erstellt mit PURE ASSEMBLER
; (c)1992 by Richard Kurz
; TOS Magazin

shftmd      equ $ff8260    ;Aktuelle Auflîsung.
hscroll     equ $ff8265    ;Der bîse Bube.
nvbls       equ $454       ;Wieviel Slots.
vblslots    equ $456       ;VBL Slots.

start:      bra init       ;Gehe Åber Los ...
vbl_flag:                  ;Hscroll im VBL     
        dc.b 0             ;Ñndern oder nicht.
xbi_flag:                  ;Setscreen abfangen     
        dc.b 1             ;oder nicht.
        dc.b 'XBRA'        ;XBRA 
        dc.b 'FALT'        ;Angelegenheiten.
old_xbi:                   ;Alter XBIOS-     
        dc.l 0             ;TRAP.
new_xbi:                   ;Neuer XBIOS-
        move.l  sp,a0      ;TRAP.
        btst    #5,(a0)    ;Super oder nicht?
        beq     user       ;Man weiû ja nie.
        addq.l  #6,a0      ;Stack anpassen.
        bra     do_it
user:   move.l  usp,a0
do_it:  tst.b   xbi_flag   ;Darf ich?
        beq     end_xbi    ;Njet.
        cmpi.w  #5,(a0)    ;Bin ich gemeint?
        bne     end_xbi    ;Nî.
        clr.w   d0
        move.b  shftmd,d0  ;Aktuelle Auflîsung
        and.b   #3,d0      ;holen.
        cmp.w   10(a0),d0  ;ist der Parameter  
                           ;fasch?
        bne     end_xbi    ;Nî.
        move.w  #-1,10(a0) ;Parameter ersetzen. 
end_xbi:
        move.l  old_xbi(pc),-(sp)
        rts                ;Und zum Orginal.

        dc.b 'XBRA'        ;XBRA 
        dc.b 'FALT'        ;Angelegenheiten.
        dc.l 0             ;Nur Show.
new_vbl:                   ;VBL Routine.
        tst.b   vbl_flag   ;Darf ich?
        beq     end_vbl    ;Nein.
        move.b  hscroll,hscroll
                           ;Sieht zwar unsinnig
                           ;aus, hilft aber.
end_vbl: 
        rts                ;VBL EnTe.

init:   move.l  #-1,-(sp)  ;Wir richten
        move.w  #46,-(sp)  ;uns ein.
        move.w  #5,-(sp)   
        trap    #13        ;XBIOS-Vektor holen.
        addq.l  #8,sp
        move.l  d0,a0
is_XBRA:                   ;XBRA gewurstel.
        cmp.l   #'XBRA',-12(a0) 
        bne     install    ;Noch nicht da.
        cmp.l   #'FALT',-8(a0)
        beq     schon_da
        move.l  -4(a0),a0  ;Der NÑchste bitte.
        bra     is_XBRA                 
schon_da:
        clr.w   -(sp)      ;Bin schon da!
        trap    #1         ;Kommentarloses Ende.
install:                   
        pea.l   new_xbi    ;Vektor-Biegerei.
        move.w  #46,-(sp)  ;Neuen XBIOS-TRAP
        move.w  #5,-(sp)   ;installieren.
        trap    #13
        addq.l  #8,sp
        move.l  d0,old_xbi
            
        pea     init_vbl   ;VBL-Installation
        move.w  #38,-(sp)  ;wird im Super-
        trap    #14        ;Mode durchgefÅhrt.
        addq.l  #6,sp
        
        pea     info       ;Ein wenig labern.
        move    #9,-(sp)
        trap    #1
        addq.l  #6,sp
        
        clr.w   -(sp)      ;und TschÅû ....
        move.l  #init-start+256,-(sp)
        move.w  #$31,-(sp)
        trap    #1         ;GAME OVER.

init_vbl:                  ;VBL-Routine
        move.w  nvbls,d0   ;in einem leeren
        lsl.w   #2,d0      ;Slot installieren.
        move.l  vblslots,a0
        moveq   #4,d1
s_slot: tst.l   (a0,d1)    ;Slot leer?
        beq     slot_gef   ;Juchu.
        addq    #4,d1      ;Nein, der NÑchste.
        cmp.w   d0,d1      ;Alle Slots voll?
        bne     s_slot     ;No.
        move.b  #99,vbl_flag
        rts                ;Kein freier Slot!
slot_gef:                  ;EinhÑngen.
        move.l  #new_vbl,0(a0,d1)
        rts                ;Bye Bye.

info:   dc.b 13,10,'FALT_OFF V1.1'
        dc.b 13,10,'(c)1992 by Richard Kurz'
        dc.b 13,10,'TOS Magazin',13,10,0

