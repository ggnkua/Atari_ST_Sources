; MINI_ACC.Q       (GFA-Assembler 1.3)
; -----------------------------------------
; Ein kÅrzeres Accessory (LÑnge: 264 Bytes)
; zur Anzeige des freien Speichers.  
 
; 30.09.89 von:    Harald GÅnterberg 
;                  Friedrich-Karl-Str. 36
;                  5000 Kîln 60
;        (c) MAXON Computer GmbH 1990


; FÅr andere Assembler lediglich die Direktiven (.ds.w, .TEXT, etc.) 
; anpassen.

; vorwiegende Adressierungsart: indirekt mit symbol. Displacement
; Konstantendeklaration: symbolische Offsets ab Speicher-Basis 'contrl' 

con       = 0
glob      = con+2*12
apid      = glob+4
int       = glob+2*15
iout      = int+2*2
addr      = iout+2*2
aout      = addr+1*4
evnt      = aout+1*4

          .TEXT 

          lea.l     stack(pc),sp        ; FÅr ein Accessory nîtig
          lea.l     contrl(pc),a5       ; BASIS-Register laden
          moveq.l   #10,d0              ; appl_init
          move.l    #$00010000,d1       ; wird per 'movep.l' transportiert
                                        ; noch kÅrzer: moveq.l #1,d1
                                        ;              swap    d1
          bsr       aes                 ; GEM setzt ap_id in Global autom.
          moveq.l   #35,d0              ; menu_register
          move.l    #$01010100,d1
          move.w    apid(a5),int(a5)    ; global[2] = unsere ID
          lea.l     name(pc),a0         ; A0 wird nach Addrin Åbertragen
          bsr.s     aes                 ; ACC-Nummer wird nicht benîtigt

doacc:    moveq.l   #23,d0              ; evnt_mesag
          move.l    #$00010100,d1
          lea.l     evnt(a5),a0         ; Nachrichtenpuffer
          bsr.s     aes
          cmpi.w    #40,evnt(a5)        ; AC_OPEN?
          bne.s     doacc               ; mehr braucht's nicht!

          moveq.l   #-1,d0              ; jetzt starten wir den Job
          move.l    d0,-(sp)            ; freien Speicher erfragen
          move.w    #$48,-(sp)          ; MALLOC
          trap      #1                  ; RÅckgabewert in D0
          addq.l    #6,sp               

          lea.l     mem(pc),a0          ; D0 dezimal in String eintragen:
          moveq.l   #6,d3               ; 7 Stellen brauchen wir
          moveq.l   #0,d4               ; Flag fÅr fÅhrende Spaces
          move.l    #1000000,d2         ; Startwert (fÅr die 7te Stelle)
loop:     moveq.l   #-1,d1              ; ZÑhler
dec:      addq.w    #1,d1               ; (D1-#1) mal ...
          sub.l     d2,d0               ; ... subtrahiert
          bpl.s     dec                 ; noch positiv, weitermachen
          add.l     d2,d0               ; D0 wieder positiv machen
          or.w      d1,d4               ; ZÑhler und Flag...
          bne.s     digit               ; Ziffer ausgeben
          moveq.l   #(' '-'0'),d1       ; sonst Leerzeichen
digit:    addi.b    #'0',d1
          move.b    d1,(a0)+            ; Space oder Ascii-Ziffer schreiben
          divu.w    #10,d2              ; nÑchste Stelle
          bvc.s     div_ok              ; bei der ersten Division ensteht ein
          move.l    #100000,d2          ; öberlauf, bei folgenden kein Rest!!
div_ok:   dbra      d3,loop             ; 7mal

          moveq.l   #52,d0              ; Ergebnis per Alert ausgeben
          move.l    #$01010100,d1
          move.w    #1,int(a5)          ; Defaultbutton
          lea.l     alert(pc),a0
          bsr.s     aes
          bra.s     doacc               ; zur ACC-Warteschleife zurÅck

aes:      move.l    a0,addr(a5)         ; Addrin besetzen...
          move.w    d0,(a5)             ; Funktionsnummer
          movep.l   d1,3(a5)            ; ...und die Parameterliste
          lea.l     aespb(pc),a0        ; spart Relozierbyte
          move.l    a0,d1               ; Parameterblock in D1
          move.w    #$c8,d0             ; und AES-Call in D0
          trap      #2
          rts       

          .DATA 
          
aespb:    .DC.l contrl,global,intin,intout,addrin,addrout


name:     .DC.b '  Mem',0

alert:    .DC.b "[0][ "
mem:      .DC.b "          ][Byte]",0

          .BSS 

contrl:   .DS.w 12  
global:   .DS.w 15  
intin:    .DS.w 2   ; Diese Sparmaûnahmen sind nur fÅr Demozwecke -
intout:   .DS.w 2   ; sonst immer richtig dimensionieren (128 Words)!
addrin:   .DS.l 1
addrout:  .DS.l 1
evntmsg:  .DS.w 8   ; Messagepuffer
          .DS.l 10  ; auch lieber grîûer dimensionieren
stack:    
          .END 




