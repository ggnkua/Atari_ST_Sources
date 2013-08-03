; *************************************************
; * Accessory-GrundgerÅst                         *
; *************************************************
start:       move.w    #0,app
             lea       start-$100(pc),a0          ; Basepageadresse berechnen
             lea       new_stack,sp     ; neuer Stack
             tst.l     $24(a0)          ; Gibt's einen parent process ???
             beq.s     init             ; nein, dann ist's ein Acc
             move.w    #-1,app          ; bei PRG = ist app-1
             pea       ende-start+$100  ; ProgrammlÑnge
             move.l    a0,-(sp)         ; Basepageadr
             move.l    #$4a0000,-(sp)
             trap      #1
             lea       12(sp),sp
init:        move.l    #$0a000100,d0    ; Applikation beim AES anmelden
             bsr       aes              ; als RÅckgabewert gibt's ap_id

             tst.w     app              ; Nochmal testen ob PRG
             bne.s     haupt_rout       ; wenn ja, dann direkt in Hauptroutine

             move.w    d0,int_in        ; appl_id ins int_in-Feld
             move.l    #acc_title,addr_in         ; Accessoryname Åbergeben
             move.l    #$23010101,d0    ; in MenÅleiste eintragen
             bsr       aes

; Hauptschleife des ACC

main_loop:   move.l    #evnt_buff,addr_in         ; Ereignispuffer Åbergeben
             move.l    #$17000101,d0    ; auf Ereignis warten
             bsr       aes
             moveq     #40,d0           ; 40 = Wert fÅr Acc_open
             cmp.w     evnt_buff,d0     ; "ACC angeklickt" ?
             bne.s     main_loop        ; wenn nicht, dann weiter warten
haupt_rout:            ; Ab hier kommt die Hauptroutine

             bra.s     desktop          ; wieder raus
desktop:     tst.w     app              ; war es ein PRG
             beq.s     main_loop        ; wenn ACC, dann wieder in Hauptschleife

             clr.w     -(sp)            ; sonst ENDE
             trap      #1
aes:         movem.l   d1-d7/a0-a6,-(sp)
             lea       contrl(pc),a0    ; Control-Array
             clr.l     (a0)
             clr.l     4(a0)            ; int_in-Array lîschen
             movep.l   d0,1(a0)
             move.l    #aes_para_blk,d1 ; Parameterblock Åbergeben
             move.w    #$c8,d0          ; Wer fÅr AES-Routinen
             trap      #2               ; AES aufrufen
             move.w    int_out(pc),d0   ; RÅckgabewert nach d0
             movem.l   (sp)+,d1-d7/a0-a6
             rts       

aes_para_blk:          
             .DC.l contrl
             .DC.l global
             .DC.l int_in
             .DC.l int_out
             .DC.l addr_in
             .DC.l addr_out
acc_title:   .DC.b "   NAME   ",0
             .BSS 
global:      .DS.w 15
contrl:      .DS.w 5
int_in:      .DS.w 16
int_out:     .DS.w 7
addr_in:     .DS.l 2
addr_out:    .DS.l 1
evnt_buff:   .DS.w 8
app:         .DS.w 1
             .DS.l 64  ; jedem Programm seinen eigenen Stack
new_stack:   .DS.l 1

ende:        
