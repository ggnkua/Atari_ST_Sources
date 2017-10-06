; sound_as.s
; Assembler-Routinen
;
; aus: GEM Sound
;      TOS Magazin
;
; (c)1992 by Richard Kurz
; Vogelherdbogen 62
; 7992 Tettnang
; Fido 2:241/7232
;
; Erstellt mit Pure Assembler
;

; Wir geben bekannt
export  set_gem,set_click,start_sound
import  do_it

;********************************************************************
; Die Vektoren werden verbogen

BELL        equ $5ac    
CLICK       equ $5b0    

set_gem:                
    pea     new_gem             ; Der AES/VDI-Trap
    move.w  #34,-(sp)
    move.w  #5,-(sp)
    trap    #13
    addq.l  #8,sp
    move.l  d0,old_gem
    rts

set_click:              
    lea     BELL,a0             ; Der Vektor fÅr den System-Beep
    move.l  (a0),old_bell
    move.l  #new_bell,(a0)  

    lea     CLICK,a0            ; Der Vektor fÅr den Tastaturklick
    move.l  (a0),old_click
    move.l  #new_click,(a0) 
    rts
    
;********************************************************************
; Die neuen Routinen fÅr die Systemtîne

    dc.b    'XBRA'
    dc.b    '----'
old_bell:
    dc.l    1

new_bell:
    move.w  #-1,d0                  ; Sound-Nr. fÅr System-Beep
    bsr     do_it                   ; Beeeeepen
    tst.w   d0                      ; Soll der Originalton erschallen
    beq.s no_old_bell
    move.l  old_bell(PC),-(SP)      ; Zur Originalroutine
no_old_bell:
    rts                             ; Das war's

    dc.b    'XBRA'
    dc.b    '----'
old_click:
    dc.l    1

new_click:
    move.w  #-2,d0                  ; Sound-Nr. fÅr Tastaturklick
    bsr     do_it                   ; Klick ausgeben
    tst.w   d0                      ; Soll der Originalton erschallen
    beq.s   no_old_click
    move.l  old_click(PC),-(SP)     ; Zur Originalroutine
no_old_click:
    rts                             ; Das war's

;********************************************************************
; Der neue AES/VDI Trap
    
    dc.b    'XBRA'
    dc.b    '----'
old_gem:
    dc.l    1

new_gem:
    movem.l d0-A6,-(SP)             ; Vorsicht ist die Mutter der
                                    ; Porzellankiste
    cmp.l   #200,d0                 ; Ist's ein AES-Aufruf
    bne.s   to_gem
    movea.l d1,a0                   ; Ja
    movea.l (a0),a0                 ; Die AES-Nr. rauspfriemeln
    move.w  (a0),d0
    bsr     do_it                   ; Spiel das Lied    

to_gem:
    movem.l (SP)+,d0-A6             ; Das war's
    move.l  old_gem(PC),-(SP)       
    rts

;********************************************************************
; Ausgabe eines Sounds
; Aufruf aus C:
; start_sound(char *Start,char *Ende, int Reset)
; Diese Routine darf nur im Supervisor-Mode ausgefÅhrt werden

SDMACTL     equ $ff8900             ; DMA-Sound Controlregister
SSTART      equ $ff8903             ; Frame-Startadresse
SEND        equ $ff890f             ; Frame-Endadresse
SDMAMOD     equ $ff8920             ; DMA-Sound Moderegister

start_sound:
    tst.w d0                        ; Soll der alte Sound
    beq.s no_stop                   ; abgewÅrgt werden
    move.w  #$00,SDMACTL            ; AbwÅrgen
    
no_stop:    
    move.l  a0,-(sp)                ; Start des Frames in die
    move.b  1(sp),SSTART            ; Frame-Start-Register
    move.b  2(sp),SSTART+2          ; schreiben
    move.b  3(sp),SSTART+4
    addq.l  #4,sp

    move.l  a1,-(sp)                ; Ende des Frames in die
    move.b  1(sp),SEND              ; Frame-End-Register
    move.b  2(sp),SEND+2            ; schreiben
    move.b  3(sp),SEND+4
    addq.l  #4,sp
    
    move.w  #$81,SDMAMOD            ; Mono / 12.5 kHz einstellen
    move.w  #$01,SDMACTL            ; Sound starten
    rts                             ; et fini
