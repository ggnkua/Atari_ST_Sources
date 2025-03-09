;------------------------------------;
;                                    ;
;   Software-T-Switch fÅr RS232      ;
;   von Armin Krieglmeier            ;
;       & GFA-Assembler 1.3          ;
;   (c) MAXON Verlag, 1990           ;
;                                    ;
;   XBRA-Kennung: COM2               ;
;                                    ;
;------------------------------------;

bios      = 13      ; TRAP's
xbios     = 14

constat   = 1       ; BIOS-Funktionen
conin     = 2
conout    = 3

setexec   = 5

iorec     = 14

rs232     = 1       ; Devices
midi      = 3

appl_init           = $0a000100         ; AES-Funktionsnummern
form_alert          = $34010101
menu_register       = $23010101
evnt_mesag          = $17000101

          .TEXT 
          lea.l     new_stack,sp        ; Stack einrichten
init:     
          move.l    #appl_init,d0       ; Anmeldung beim AES
          bsr       aes       ;           ap_id ist jetzt in int_out
          lea.l     addr_in,a6
          lea.l     int_in,a5

          move.w    int_out,(a5)
          move.l    #my_name,(a6)       ; in der Menuleiste eintragen
          move.l    #menu_register,d0
          jsr       aes

          move.w    int_out,my_id       ; ac_id in my_id ablegen

          pea       new_bios            ; neuen Dispatcher
          move.w    #45,-(sp)           ; installieren
          move.w    #setexec,-(sp)
          trap      #bios
          addq.l    #8,sp
          move.l    d0,old_vector       ; den alten sichern

          move.w    #2,-(sp)            ; Iorec(2)
          move.w    #iorec,-(sp)        ; liefert die Adresse der
          trap      #xbios              ; MIDI-IOREC-Struktur
          adda.l    #4,sp

          movea.l   d0,a0               ; neue Pufferadresse in der
          move.l    #midi_buf,(a0)      ; Struktur eintragen

          move.l    #midi_end,d0        ; PufferlÑnge ausrechnen
          subi.l    #midi_buf,d0
          move.w    d0,4(a0)            ; und auch eintragen

loop:     
          move.l    #evnt_mesag,d0
          move.l    #msg_buf,(a6)
          jsr       aes                 ; auf Message warten

          cmpi.w    #40,msg_buf         ; Accessory angewÑhlt?
          bne       loop                ; nein! Schade

          move.w    msg_buf+8,d0
          cmp.w     my_id,d0            ; meint er mich?
          bne       loop

          jsr       main      ; ja! Ab in die Hauptroutine...
          bra       loop      ; und wieder auf warten

main:     lea.l     alrt_txt(pc),a0     ; Adresse des Alert-Textes
          move.l    a0,(a6)             ; nach addr_in

          move.w    device,d0
          cmpi.w    #rs232,d0           ; Wenn device = rs232 ist,
          bne       weiter
          move.w    #2,(a5)             ; ist der Midi-Button default,
          bra       alert
weiter:   move.w    #1,(a5)             ; ansonsten der RS232-Button.

alert:    move.l    #form_alert,d0      ; Alerbox hinpinseln
          bsr       aes

          move.w    int_out,d0          ; gedrÅckter Button nach d0

          cmpi.w    #1,d0               ; War's RS232?
          bne       midi?               ; nein, also vielleicht Midi.
          move.w    #rs232,device       ; Device Ñndern
midi?:    cmpi.w    #2,d0               ; wenn's Midi nicht war,
          bne       abbr?               ; passiert gar nix
          move.w    #midi,device
abbr?:    
          rts                           ; und zurÅck ins Desktop

          .EVEN                         ; Anfang der XBRA-Kennung
xbra:     .DC.l 'XBRA'
          .DC.l 'COM2'
old_vector: .DC.l $ffffffff             ; Platz fÅr den alten
                                        ; Trap-Vektor
                                        
device:   .DC.w rs232                   ; Standardeinstellung ist RS232

new_bios: 
          movea.l   sp,a0
          btst      #5,(sp)   ; sind wir im Supervisor-Mode?
          bne.s     label     ; - ja, dann weiter...
          move.l    usp,a0    ; - wenn nicht, dann tun wir eben
          subq.l    #6,a0     ;   so, als ob

label:    cmpi.w    #conout,6(a0)       ; wurde Conout,
          beq.s     change
          cmpi.w    #conin,6(a0)        ; Conin, oder
          beq       change
          cmpi.w    #constat,6(a0)      ; Constat aufgerufen?
          bne       call_bios           ; nein! Dann zum alten Dispatcher
change:   cmpi.w    #rs232,8(a0)        ; Meint er die RS232?
          bne.s     call_bios ;
                                        ; Wenn ja, dann
          move.w    device,8(a0)        ; Parameter im Stack Ñndern.

call_bios:          
          movea.l   old_vector,a1       ; und ab ins BIOS
          jmp       (a1)
          rte       

; Unterroutine fÅr AES-Aufrufe
aes:      
          movem.l   d1-d7/a0-a6,-(sp)  ;Register retten
          lea.l     contrl,a0          ;Control-Array initialisieren
          clr.l     (a0)
          clr.l     4(a0)              ; int_in-Array lîschen
          movep.l   d0,1(a0)           ; neue Daten eintragen
          lea.l     aes_para_blk,a0
          move.l    a0,d1              ; Parameterblock nach d1
          move.w    #$c8,d0            ; Kennung fÅr AES
          trap      #2
          move.w    int_out,d0         ; Ergebnis nach d0
          movem.l   (sp)+,d1-d7/a0-a6  ; Register restaurieren
          rts       

;-------------------------------
          .DATA 
aes_para_blk:                          ; AES-Parameter-Block-
          .DC.l contrl                 ; Struktur
          .DC.l global
          .DC.l int_in
          .DC.l int_out
          .DC.l addr_in
          .DC.l addr_out

my_name:  .DC.b "  RS232-Switch",0     ; Accessory-Menueintrag

                                       ; Text fÅr die Alertbox
alrt_txt: .DC.b "[1]"
          .DC.b "[ RS232 Switch by A.Krieglmeier","| "
          .DC.b "|    Bitte wÑhlen Sie Ihr     "
          .DC.b "|    Standard AUX-Device      ]"
          .DC.b "[RS232|MIDI|Abbruch]",0

;    Man kînnte die Buttons natÅrlich auch
;    COM1: und COM2: nennen.

;-------------------------------------
          .BSS 

my_id:    .DS.w 1      ; Accessory_Id
msg_buf:  .DS.w 8      ; Nachrichten-Puffer

global:   .DS.w 15     ; Aes-Datenfelder
contrl:   .DS.w 5
int_in:   .DS.w 16
int_out:  .DS.w 7
          .EVEN 
addr_in:  .DS.l 2
addr_out: .DS.l 65

midi_buf: .DS.l 1024   ; neuer Midi-Puffer (4 KB)
midi_end: 

new_stack: .DS.l $100  ; eigener Stack
;-------------------------------------
          .END 
