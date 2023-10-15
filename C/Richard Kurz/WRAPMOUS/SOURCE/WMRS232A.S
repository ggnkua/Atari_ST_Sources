;  WRAP Mouse
;  RS232-Teil
;
;  (c)1992 by Richard Kurz
;  Vogelherdbogen 62
;  7992 Tettnang
;  Fido 2:241/7232
;
;  FÅr's TOS-Magazin
;

export ini_m1,ini_m2,ini_s1,ini_s2
import chk_rs

; Vektor Verbiegereien

ini_m1:
    move.l  $130,old_rx1bfull
    move.l  #new_rx1bfull,$130
    rts
ini_m2: 
    move.l  $190,old_rx2bfull
    move.l  #new_rx2bfull,$190
    rts
ini_s1:
    move.l  #new_rx3bfull,$170
    move.l  $170,old_rx3bfull
    rts 
ini_s2: 
    move.l  $1b0,old_rx4bfull
    move.l  #new_rx4bfull,$1b0
    rts     

*********************************************************************
; Die Empfangsroutinen

; Modem 1
    dc.b 'XBRA'             ; XBRA 
    dc.b 'WrAp'             ; Angelegenheiten
old_rx1bfull:
    dc.l    1

new_rx1bfull:               ; Wenn ein Byte empfangen wurde
    movem.l d0-a6,-(sp)     ; Register retten
    move.w  sr,-(sp)        ; Alten Status retten
    move.w  #$2700,sr       ; Status neu setzen

    moveq   #0,d0           
    move.b  $fffffa2f,d0    ; Byte abholen
    bsr     chk_rs          ; Zur Auswertung
    bclr    #4,$fffffa0f    ; ISR-Bit lîschen
    move.w  (sp)+,sr        ; Alten Status restaurieren
    movem.l (sp)+,d0-a6     ; Register holen
    rte                     ; Und TschÅû

; Modem 2
    dc.b 'XBRA'
    dc.b 'WrAp'
old_rx2bfull:
    dc.l    1
new_rx2bfull:
    movem.l d0-a6,-(sp)
    move.w  sr,-(sp)
    move.w  #$2700,sr
    moveq   #0,d0
    move.b  $ffff8c87,d0
    bsr     chk_rs
    move.b  #$00,$ffff8c85; Der SCC wird wieder scharf geschaltet
    move.b  #$38,$ffff8c85;
    move.w  (sp)+,sr
    movem.l (sp)+,d0-a6
    rte

; Serial 1
    dc.b 'XBRA'
    dc.b 'WrAp'
old_rx3bfull:
    dc.l    1

new_rx3bfull:
    movem.l d0-a6,-(sp)
    move.w  sr,-(sp)
    move.w  #$2700,sr

    moveq   #0,d0           
    move.b  $fffffaaf,d0
    bsr     chk_rs

    bclr    #4,$fffffa8f
    move.w  (sp)+,sr
    movem.l (sp)+,d0-a6
    rte 

; Serial 2
    dc.b 'XBRA'
    dc.b 'WrAp'
old_rx4bfull:
    dc.l    1
new_rx4bfull:
    movem.l d0-a6,-(sp)
    move.w  sr,-(sp)
    move.w  #$2700,sr
    moveq   #0,d0
    move.b  $ffff8c83,d0
    bsr     chk_rs
    move.b  #$00,$ffff8c81;
    move.b  #$38,$ffff8c81;
    move.w  (sp)+,sr
    movem.l (sp)+,d0-a6
    rte

