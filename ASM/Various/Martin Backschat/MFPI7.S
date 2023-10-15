;
; Interruptroutine fÅr >>setinterrupt()<<
;
; (C) 1993 ICP-Verlag, TOS-Magazin
;

.export i7_disable, setupi7, i7_occur

AER  equ  $fffa03   ; Aktive-Edge-Register
DDR  equ  $fffa05   ; Data-Direction-Register
IERA equ  $fffa07   ; Interrupt-Enable-Register
IPRA equ  $fffa0b   ; Interrupt-Pending-Register
ISRA equ  $fffa0f   ; Interrupt-in-Service-Register
IMRA equ  $fffa13   ; Interrupt-Mask-Register

; Interrupt ausschalten und 
; alte MFPi7-Routine restaurieren

i7_disable:

movem.l d0-d2/a0-a2,-(sp)    ; Register retten

clr.l   -(sp)                ; Supervisor einschalten
move.w  #32,-(sp)            ; SUPER()
trap    #1                   ; GEMDOS
addq.l  #06,sp               ; Stack aufrÑumen
move.l  d0,old_ssp           ; Stackpointer retten

bclr    #7,IERA              ; Interrupt ausschalten
bclr    #7,IMRA              ; Interrupt ausmaskieren
bclr    #7,IPRA              ; Keine "schwebenden" I.
bclr    #7,ISRA              ; Keine "In-Service" I.

move.l  old_mfpi7,$13c       ; alte Routine restaurieren

move.b  old_iera,IERA        ; Register auf alte
move.b  old_imra,IMRA        ; Werte setzen
move.b  old_ipra,IPRA        ;
move.b  old_isra,ISRA        ;
move.b  old_ddr,DDR          ;
move.b  old_aer,AER          ;

move.l  old_ssp,-(sp)        ; in User-Modus zurÅck
move.w  #32,-(sp)            ; SUPER()
trap    #1                   ; GEMDOS
addq.l  #06,sp               ; Stack aufrÑumen

movem.l (sp)+,d0-d2/a0-a2    ; Register restaurieren
rts                          ; zurÅck ins Hauptprogramm

; Interrupt-Routine installieren

setupi7:

movem.l d0-d2/a0-a2,-(sp)    ; Register retten

clr.l   -(sp)                ; Supervisor einschalten
move.w  #32,-(sp)            ; SUPER()
trap    #1                   ; GEMDOS
addq.l  #06,sp               ; Stack aufrÑumen
move.l  d0,old_ssp           ; Stackpointer retten

move.b  IERA,old_iera        ; alte Werte
move.b  IMRA,old_imra        ; sichern
move.b  IPRA,old_ipra        ;
move.b  ISRA,old_isra        ;
move.b  DDR,old_ddr          ;
move.b  AER,old_aer          ;

bclr    #7,IERA              ; MFPi7 ausschalten
bclr    #7,IMRA              ; ausmasieren
bclr    #7,IPRA              ; keine "schwebenden" I.
bclr    #7,ISRA              ; keine "In-Service" I.
bclr    #7,DDR               ; Port 7 ist Ausgang

movea.l #$13c,a0             ; MFPi7-Vektor
move.l  (a0),old_mfpi7       ; alte Routine retten
move.l  #i7_int,(a0)         ; Interrupt installieren

bset    #7,AER               ; Interrupt bei Low->High
bset    #7,IMRA              ; MFPi7 setzen
bset    #7,IERA              ; und einschalten

move.l  old_ssp,-(sp)        ; in User-Modus zurÅck
move.w  #32,-(sp)            ; SUPER()
trap    #1                   ; GEMDOS
addq.l  #06,sp               ; Stack aufrÑumen

movem.l (sp)+,d0-d2/a0-a2    ; Register restaurieren

rts                          ; ZurÅck ins Hauptprogramm

i7_int:

move.w  #1,i7_occur

bclr    #7,IPRA              ; keine "schwebenden" I.
bclr    #7,ISRA              ; keine "In-Service" I.
bset    #7,IMRA              ; MFPi7 setzen

rte                          ; "return from Interrupt"
        
     .bss

old_ssp:   ds.l 1            ; alter Stackpointer
old_mfpi7: ds.l 1            ; alte MFPi7-Routine
i7_occur:  ds.l 1            ; Flag fÅr Interrupt

old_iera:  ds.b 1            ; alte MFP-Register
old_imra:  ds.b 1            ;
old_ipra:  ds.b 1            ;
old_isra:  ds.b 1            ;
old_ddr:   ds.b 1            ;
old_aer:   ds.b 1            ;

     .end

