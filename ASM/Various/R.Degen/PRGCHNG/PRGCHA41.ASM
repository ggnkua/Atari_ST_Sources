;***************************************************************************
;*                                                                         *
;*                         MIDI-PROGRAMM-CHANGER                           *
;*                                                                         *
;*                  (C) R.Degen  26.07.92  Version 4.1                     *
;*                                                                         *
;*                                                                         *
;*  Neue Funktionen: 3stellige Prg.-Anzeige u. Prg.-UP/DOWN-Taste          *
;*                                                                         *
;***************************************************************************
;
;
;-------------------------
;BENUTZTE FLAGS
;-------------------------

KEYBIT:             set       00h       ;Flag 1=Taste gedrÅckt
sfrei:              set       01h       ;Flag 1=Sbuf gesperrt
stchange:           set       02h       ;Flag 1=Midi-Status geÑndert
prgchange:          set       03h       ;Flag 1=Prg.Change senden
CHANALPRG:          set       04h       ;Flag 1=verzweigt zur Tastenabfrage
BLINK:              SET       05H       ;FLAG 1=ANZEIGE BLINKT EINMAL
RELEASE:            SET       06H       ;FLAG 1=TASTE GEDRöCKT
ERROR:              SET       07H       ;FLAG 1=FALSCHE TASTENEINGABE
MIDI_REC:           SET       08H       ;FLAG 1=MIDI-DATEN EMPFANGEN


;------------------------
;BENUTZTE REGISTER
;------------------------
key1:               set       7fh       ;1.Tastenwert
key2:               set       7eh       ;2.Tastenwert
key3:               set       7dh       ;3.Tastenwert
prgstat:            set       7ch       ;Prg.Status u. Kanal fÅr Prg.Change
oldstat:            set       7bh       ;alter Prg.Status
prgnr:              set       7ah       ;Prg.Nummer
CHANAL:             set       78h       ;MIDI-KANAL
SEG:                SET       77H
SEG1:               SET       76H
SEG2:               SET       75H
SEG3:               SET       74H
PRELL:              SET       73H       ;ENTPRELLZEIT FöR TASTENABFRAGE
KEY:                SET       72H       ;ALTER TASTENCODE
OFF_TIME:           SET       71H       ;BLINK-OFF-TIME
OLDSEG1:            SET       70H
OLDSEG2:            SET       6FH
OLDSEG3:            SET       6EH
OLDKEY1:            SET       6DH
OLDKEY2:            SET       6CH
OLDKEY3:            SET       6BH
HEXWERT:            SET       6AH       ;ZWISCHENSPEICHER HEXDEZ-WANDLUNG
REPEAT1:            SET       69H       ;PRELLZEIT UP/DOWN-TASTE
REPEAT2:            SET       68H       ;
OLD_DIP:            SET       67H       ;VORLETZTE DIP-SCHALTERSTELLUNG
LAMPE:              SET       66H       ;MIDI-REC-LAMPE EINSCHALTZEIT


;r0 = Input-Zeiger Midi-Puffer (Ram-Adr. 40h-6Dh)
;r1 = Output-Zeiger Midi-Puffer
;r2 = Zwischenspeicher fÅr Mididaten
;r3 = Zwischenspeicher fÅr letzter Tastencode
;r4 = EntprellzÑhler
;r5 = Adr.Zeiger Dezimal-Zahl



          SJMP      start
;-------------------------
; serial IRQ Routine
;-------------------------
irq:      ORG       23h                 ;IRQ-Einsprungadr.
          JBC       RI,recive           ;prÅfe IRQ-Art
          CLR       TI
          CLR       sfrei
          RETI
recive:   PUSH      PSW                 ;Register retten
          PUSH      ACC
          MOV       A,SBUF
          SETB      MIDI_REC
          CJNE      A,#0f8H,rec4        ;Echtzeitbyte?,
rec1:     JNB       sfrei,rec3          ;dann sofort senden
rec2:     JNB       TI,rec1
rec3:     CLR       TI
          SETB      sfrei
          MOV       SBUF,A
          SJMP      rec5
rec4:     JNC       rec1
          MOV       @R0,A               ;Midi-Byte in Ringpuffer
          DEC       R0                  ;Pufferzeiger -1
          CJNE      R0,#40H,rec5        ;bei Unterlauf:Zeiger auf 70h
          MOV       R0,#60H
rec5:     POP       ACC
          POP       PSW
          RETI



;-------------------------
; Programmstart
;-------------------------
;Register init
start:

          MOV       R0,#60h             ;Input-Zeiger auf Start
          MOV       R1,#60h             ;Output-Zeiger auf Start
          MOV       PCON,#00h           ;einfache Baudrate
          MOV       TMOD,#20h           ;Timer1 :autoreload
          MOV       TH1,#0ffh           ;Timer1 31250 Baud
          SETB      TR1                 ;Timer1 starten
          MOV       SCON,#50h           ;8Bit-UART/enable
          CLR       sfrei
          SETB      IE.4                ;Freigabe serieller Interrupt
          SETB      IE.7                ;generelle Interruptfreigabe
          MOV       SP,#28h             ;Stackpointer Åber bitadr. Ram
          CLR       KEYBIT              ;Flags lîschen
          CLR       stchange
          CLR       prgchange
          CLR       BLINK
          CLR       ERROR
          CLR       MIDI_REC
          MOV       prgnr,#00H          ;PRG.-NUMMER = 1
          MOV       90h,#0ffh           ;init. Tastenports
          MOV       0b0h,#0ffh
          CLR       CHANALPRG
          MOV       R5,#7FH             ;Adr.Zeiger Deziemal-Zahl
          MOV       key1,#01h           ;Ziffern-Speicher lîschen
          MOV       key2,#00h
          MOV       key3,#00h
          MOV       SEG,#3              ;ANZAHL DER ANZ.-SEGMENTE
          MOV       SEG1,#0C0H          ;ANZEIGE AUF "001"
          MOV       SEG2,#0C0H
          MOV       SEG3,#0F9H
          MOV       LAMPE,#00H          
          LCALL     TIMER0              ;INIT MULTIPLEX-TIMER
;---------------------------------
;MIDI-KANAL öBER DIP-SCHALTER 
;---------------------------------
          CLR       P3.7                ;TASTEN SPERREN
          MOV       90H,#0FFH
          MOV       A,90H               ;Portbits lesen u. in ACC
          CPL       A
          ANL       A,#00001111B        ;BIT 4-7 LôSCHEN
          MOV       CHANAL,A            ;NEUER MIDI-KANAL öBER DIP-SCHALTER
          MOV       OLD_DIP,A           ;NEUER MIDI-KANAL MERKEN
          ORL       A,#0C0H             ;Midi-Kanal u. Prg.Nr. berechnen
          MOV       prgstat,A           ;und merken.
          SETB      P3.7
;--------------------------------------
;DATEN AUS MIDI-BUFFER LESEN UND SENDEN
;--------------------------------------
MIDI_BUF: MOV       A,R0                ;Midi-Puffer leer?
          CJNE      A,01h,midiout       ;nein,Sprung nach Midiout
          JNB       TF0,P_CHANGE        ;MULTIPLEX-TIMER ABGELAUFEN?
          LCALL     GET_KEY             ;TASTEN ABFRAGEN
          LCALL     DISPLAY             ;ANZEIGE
P_CHANGE: JNB       prgchange,MIDI_BUF  ;Prg.Change senden?
          MOV       A,prgstat           ;ja, Prg.Status in ACC
          LCALL     transmit            ;und Åber Midi senden.
          MOV       A,prgnr             ;Prg.Nummer in ACC
          LCALL     transmit            ;und Åber Midi senden
          CLR       prgchange           ;Flag lîschen
          SETB      stchange            ;Midi-StatusÑnderung merken
          SJMP      MIDI_BUF
midiout:  MOV       A,@R1               ;Midi-Byte in ACC
          DEC       R1                  ;Puffer-Output-Zeig. -1
          CJNE      R1,#40H,out2        ;Unterlauf Zeiger auf 70h
          MOV       R1,#60H
out2:     JB        ACC.7,status        ;Status-Byte?,ja Sprung
          JNB       stchange,data       ;alter Midi-Status?,ja Sprung
          MOV       R2,A                ;Midi-Data merken
          MOV       A,oldstat           ;alten Status widerherstellen
          LCALL     transmit
          CLR       stchange            ;Status-Flag lîschen
          MOV       A,R2                ;hole Midi-Data
data:     LCALL     transmit            ;Midi-Data senden
          SJMP      MIDI_BUF
status:   MOV       oldstat,A           ;alter Midi-Status merken
          LCALL     transmit
          CLR       stchange
          SJMP      MIDI_BUF



;******************************
;
;        UNTERPROGRAMME
;
;******************************

;--------------------------------
;TASTEN ABFRAGEN
;--------------------------------
GET_KEY:  MOV       P1.0,#0FFH          ;INIT PORT1 FöR TASTENABFRAGE
          SETB      P3.7                ;TASTENABFRAGE FREIGEBEN
          JB        P1.0,z1             ;Ziffern 0-9 abfragen,
          MOV       A,#00h              ;wenn gedrÅckt,merken und Sprung.
          SJMP      key
z1:       JB        P1.1,z2
          MOV       A,#01h
          SJMP      key
z2:       JB        P1.2,z3
          MOV       A,#02h
          SJMP      key
z3:       JB        P1.3,z4
          MOV       A,#03h
          SJMP      key
z4:       JB        P1.4,z5
          MOV       A,#04h
          SJMP      key
z5:       JB        P1.5,z6
          MOV       A,#05h
          SJMP      key
z6:       JB        P1.6,z7
          MOV       A,#06h
          SJMP      key
z7:       JB        P1.7,z8
          MOV       A,#07h
          SJMP      key
z8:       JB        P3.2,z9
          MOV       A,#08h
          SJMP      key
z9:       JB        P3.3,ENT
          MOV       A,#09h
          SJMP      key
ENT:      JB        P3.5,CLR
          MOV       A,#0BH
          SJMP      key
CLR:      JB        P3.4,UP
          MOV       A,#0AH
          SJMP      key
UP:       CLR       P3.7                ;SONDERTASTEN FREIGEBEN
          JB        P1.7,DOWN           ;"UP"-TASTE GEDRöCKT?
          MOV       A,#0CH
          JB        CHANALPRG,UP_CHA
          LCALL     PRG_UP
          RET
UP_CHA:   LCALL     CHA_UP
          RET
DOWN:     JB        P3.2,KEY_END        ;"DOWN"-TASTE GEDRöCKT
          MOV       A,#0DH
          JB        CHANALPRG,DOWN_CHA
          LCALL     PRG_DOWN
          RET
DOWN_CHA: LCALL     CHA_DOWN
          RET
KEY_END:  MOV       PRELL,#10H          ;ENTPRELL-ZEIT SETZEN
          MOV       KEY,#00H            ;ALTEN TASTENCODE LôSCHEN
          CLR       P3.7                ;TASTENABFRAGE SPERREN
          CLR       RELEASE             ;KEINE TASTE GEDRöCKT
          LCALL     DIP
          RET

;-----------------------------------
;TASTEN ENTPRELLEN
;-----------------------------------
key:      CJNE      A,#0BH,KEY_2        ;MIDI-KANAL PROGRAMMIEREN?
          JB        P3.4,KEY_2
          LCALL     MIDI_CHA
          SJMP      PRELL1
KEY_2:    CJNE      A,KEY,ENTPRELL      ;NEUE TASTE GEDRöCKT?
          DJNZ      PRELL,PRELL1        ;TASTE ENTPRELLEN
          JNB       RELEASE,CLR_KEY     ;TASTE LOSGELASSEN?
          CLR       P3.7
          RET
CLR_KEY:  SETB      RELEASE             ;NEUE TASTE GEDRöCKT
          CJNE      A,#0AH,ENT_KEY      ;TASTE "CLR" GEDRöCKT?
          LCALL     CLEAR
          CLR       P3.7
          RET
ENT_KEY:  CJNE      A,#0BH,SET_KEY      ;TASTE "ENTER" GEDRöCKT?
          LCALL     ENTER1
          CLR       P3.7
          RET
ENTPRELL: MOV       KEY,A               ;TASTENCODE MERKEN
          MOV       PRELL,#03H          ;ENTPRELL-ZEIT SETZEN
PRELL1:   CLR       P3.7                ;TASTENABFRAGE SPERREN
          RET

;-----------------------------------
;TASTENCODE SPEICHERN UND ANZEIGEN
;-----------------------------------
SET_KEY:  JNB       CHANALPRG,SEG_X
          LJMP      M_CHANAL
SEG_X:    CJNE      R5,#7FH,SEGM2
SEGM1:    MOV       key1,A              ;1.Tastencode merken
          LCALL     DEZ_SEG
          MOV       SEG3,A              ;1.ZIFFER ANZEIGEN
          MOV       SEG1,#0C0H          ;1+2 SEGMENT OFF
          MOV       SEG2,#0C0H
          MOV       key2,#00H
          MOV       key3,#00H
          DEC       R5
          SJMP      SEG_END
SEGM2:    CJNE      R5,#7Eh,SEGM3
          MOV       key2,key1
          MOV       key1,A              ;2.Tastencode merken
          LCALL     DEZ_SEG
          MOV       SEG2,SEG3           ;1.ZIFFER NACH 2.ZIFFER
          MOV       SEG3,A              ;1+2 ZIFFER ANZEIGEN
          MOV       SEG1,#0C0H          ;1.SEGMENT OFF
          MOV       key3,#00H
          DEC       R5
          SJMP      SEG_END
SEGM3:    CJNE      R5,#7Dh,SEG_END
          MOV       key3,key2
          MOV       key2,key1
          MOV       key1,A              ;3.Tastencode merken
          LCALL     DEZ_SEG
          MOV       SEG1,SEG2           ;2.ZIFFER NACH 3.ZIFFER
          MOV       SEG2,SEG3           ;1.ZIFFER NACH 2.ZIFFER
          MOV       SEG3,A              ;1.ZIFFER ANZEIGEN
          MOV       R5,#7FH             ;SEG.-ZEIGER AUF 1.SEG.-ADR.
SEG_END:  LCALL     ENTER
          CLR       P3.7                ;TASTENABFRAGE SPERREN
          RET

;-------------------------------
;MIDI-KANAL PROGRAMMIEREN
;-------------------------------
MIDI_CHA: 
          MOV       HEXWERT,CHANAL      ;ALTEN MIDI-KANAL ANZEIGEN
          INC       HEXWERT
          LCALL     HEXDEZ 
          LCALL     DEZ_SEG
          MOV       SEG1,#0C6H          ;ANZEIGE "CXX"
          SETB      CHANALPRG           ;FLAG FöR MIDI-KANAL PROG. SETZEN
          CLR       P3.7                 
          RET

;------------------------------------
;MIDI-KANAL EINGEBEN UND ANZEIGEN
;------------------------------------
M_CHANAL: CJNE      R5,#7FH,SEGME2
          JZ        JMP_ERR             ;1.TASTE "0"?,JA "ERROR"
          MOV       key1,A              ;NEIN,Tastencode merken.
          MOV       CHANAL,A
          DEC       CHANAL
          LCALL     DEZ_SEG
          MOV       SEG3,A              ;1.ZIFFER ANZEIGEN
          MOV       SEG1,#0C6H          ;ANZEIGE "C0X"
          MOV       SEG2,#0C0H
          MOV       key2,#00H
          MOV       key3,#00H
          DEC       R5
          MOV       A,CHANAL
          ORL       A,#0C0H
          MOV       prgstat,A
          CLR       P3.7
          RET
SEGME2:   CJNE      R5,#7Eh,CHA_END  
          MOV       key2,key1
          MOV       key1,A              ;2.Tastencode merken
          LCALL     DEZ_SEG
          MOV       SEG2,SEG3           ;1.ZIFFER NACH 2.ZIFFER
          MOV       SEG3,A              ;1+2 ZIFFER ANZEIGEN
          MOV       SEG1,#0C6H          ;1.SEGMENT OFF
          MOV       key3,#00H
          MOV       R5,#7FH
;--------------------------------
;MIDI-KANAL BERECHNEN
;--------------------------------
ENT_CHA:  MOV       CHANAL,#00H         ;CLR MIDI-CHANAL
ZEHN:     MOV       A,7EH
          JZ        EIN
          CJNE      A,#01H,JMP_ERR
          SJMP      ZEHN_X
JMP_ERR:  MOV       OLDSEG2,#0BFH
          MOV       OLDSEG3,#0BFH
          LJMP      ERR                 ;FALSCHE EINGABE,DANN "ERROR"
ZEHN_X:   MOV       B,#0AH
          MUL       AB
          ADD       A,CHANAL
          MOV       CHANAL,A
EIN:      MOV       A,7FH
          ADD       A,CHANAL
          DEC       A
          MOV       CHANAL,A
          JB        ACC.4,JMP_ERR       ;PRG.-NR. OVERFLOW
          MOV       R5,#7FH
          CLR       P3.7
          MOV       A,CHANAL
          JB        ACC.4,CHA_END       
          ORL       A,#0C0H
          MOV       prgstat,A    
CHA_END:  CLR       P3.7
          RET



;------------------------------------
;DIP-SCHALTER FöR MIDI-KANAL ABFRAGEN
;------------------------------------
DIP:      CLR       P3.7                ;TASTEN SPERREN
          MOV       90H,#0FFH
          MOV       A,90H               ;Portbits lesen u. in ACC
          CPL       A
          ANL       A,#00001111B        ;BIT 4-7 LôSCHEN
          CJNE      A,OLD_DIP,NEW_DIP   ;DIP-SCHALTER VERéNDERT? NEIN,
          SETB      P3.7
          RET
NEW_DIP:  MOV       CHANAL,A            ;NEUER MIDI-KANAL öBER DIP-SCHALTER
          MOV       OLD_DIP,A           ;NEUER MIDI-KANAL MERKEN
          ORL       A,#0C0H             ;Midi-Kanal u. Prg.Nr. berechnen
          MOV       prgstat,A           ;und merken.
          SETB      P3.7
          RET



;------------------------------------
;PROGRAMM-NUMMER INKREMENTIEREN (+1)
;------------------------------------
PRG_UP:   MOV       A,prgnr
          CJNE      A,#7FH,PRELL_UP     ;PRG.-NR. >128 ?
          RET
PRELL_UP: JNB       RELEASE,SET_REP1    ;1.TASTENDRUCK ?
          DJNZ      REPEAT1,UP_END      ;CA. 30MSEC PAUSE
          MOV       REPEAT1,#010H
          DJNZ      REPEAT2,UP_END
          MOV       REPEAT2,#002H
INC_PRG:  SETB      RELEASE             ;TASTENFLAG SETZEN
          INC       prgnr
          MOV       HEXWERT,prgnr
          INC       HEXWERT
          LCALL     HEXDEZ
UP_END:   RET

SET_REP1: MOV       REPEAT1,#050H       ;2SEC-PAUSE NACH 1.TASTENDRUCK
          MOV       REPEAT2,#010H
          SJMP      INC_PRG

;------------------------------------
;PROGRAMM-NUMMER DEKREMENTIEREN (-1)
;------------------------------------
PRG_DOWN: MOV       A,prgnr
          CJNE      A,#00,P_DOWN
          RET
P_DOWN:   JNB       RELEASE,SET_REP2
          DJNZ      REPEAT1,DOWN_END
          MOV       REPEAT1,#010H
          DJNZ      REPEAT2,DOWN_END
          MOV       REPEAT2,#002H
DEC_PRG:  SETB      RELEASE             ;TASTENFLAG SETZEN
          DEC       prgnr
          MOV       HEXWERT,prgnr
          INC       HEXWERT
          LCALL     HEXDEZ
DOWN_END: RET

SET_REP2: MOV       REPEAT1,#050H
          MOV       REPEAT2,#010H
          SJMP      DEC_PRG

;------------------------------------
;MIDI-KANAL INKREMENTIEREN (+1)
;------------------------------------
CHA_UP:   MOV       A,CHANAL
          CJNE      A,#0FH,CHA_PREL     ;PRG.-NR. >16 ? 
          RET
CHA_PREL: JNB       RELEASE,CHA_REP1    ;1.TASTENDRUCK ?
          DJNZ      REPEAT1,CH_END      ;CA. 30MSEC PAUSE
          MOV       REPEAT1,#010H
          DJNZ      REPEAT2,CH_END
          MOV       REPEAT2,#002H
INC_CHA:  SETB      RELEASE             ;TASTENFLAG SETZEN
          INC       CHANAL
          MOV       A,CHANAL
          ORL       A,#0C0H
          MOV       prgstat,A    
          MOV       HEXWERT,CHANAL
          INC       HEXWERT
          LCALL     HEXDEZ
CH_END:   RET

CHA_REP1: MOV       REPEAT1,#050H       ;2SEC-PAUSE NACH 1.TASTENDRUCK
          MOV       REPEAT2,#010H
          SJMP      INC_CHA

;------------------------------------
;MIDI-KANAL DEKREMENTIEREN (-1)
;------------------------------------
CHA_DOWN: MOV       A,CHANAL
          CJNE      A,#00,C_DOWN
          RET
C_DOWN:   JNB       RELEASE,CHA_REP2
          DJNZ      REPEAT1,CHAN_END
          MOV       REPEAT1,#010H
          DJNZ      REPEAT2,CHAN_END
          MOV       REPEAT2,#002H
DEC_CHA:  SETB      RELEASE             ;TASTENFLAG SETZEN
          DEC       CHANAL
          MOV       A,CHANAL
          ORL       A,#0C0H
          MOV       prgstat,A    
          MOV       HEXWERT,CHANAL
          INC       HEXWERT
          LCALL     HEXDEZ
CHAN_END: RET

CHA_REP2: MOV       REPEAT1,#050H
          MOV       REPEAT2,#010H
          SJMP      DEC_CHA

;-------------------------------------
; HEXWERT (8BIT) IN DEZIMAL WANDELN
;-------------------------------------
HEXDEZ:   CLR       0D2H                ;clr öbertrag(OV)
          MOV       B,#100
          MOV       A,HEXWERT           ;HEXWERT div 100
          DIV       AB
          JNB       0D2H,ZEHN_1         ;Summe negativ,Sprung
          MOV       SEG1,#0C0H          ;SEG1="0"
          MOV       key1,#00H
          SJMP      ZEHN_2
ZEHN_1:   MOV       key1,#00H
          LCALL     DEZ_SEG             ;Hunderter in SIEBEN-SEG.-CODE
          MOV       SEG1,A
          MOV       HEXWERT,B           ;RESTSUMME SICHERN
ZEHN_2:   CLR       0D2H                ;clr öbertrag(OV)
          MOV       B,#10
          MOV       A,HEXWERT           ;Rest aus Vorsumme in ACC
          DIV       AB                  ;div 10
          JNB       0D2H,EIN_1          ;Summe negativ,Sprung
          MOV       SEG2,#0C0H          ;SEG2="0"
          MOV       key2,#00H
          SJMP      EIN_2
EIN_1:    MOV       key2,A
          LCALL     DEZ_SEG             ;Zehner in SIEBEN-SEG.-CODE
          MOV       SEG2,A
          MOV       HEXWERT,B           ;Rest aus Vorsumme in ADC
EIN_2:    CLR       0D2H                ;clr öbertrag(OV)
          MOV       A,HEXWERT           ;Rest aus Vorsumme in ACC
          MOV       key3,A
          LCALL     DEZ_SEG             ;Einer in ASCII anzeigen
          MOV       SEG3,A
          JNB       CHANALPRG,EIN_END
          MOV       SEG1,#0C6H          ;"CXX" ANZEIGE
EIN_END:  RET

;-------------------------------------
;DEZIEMAL IN SIEBENSEGMENTCODE WANDELN
;-------------------------------------
DEZ_SEG:  MOV       DPTR,#SEGTAB
          MOVC      A,@A+DPTR
          RET

;-------------------------------
;CLEAR-FUNKTION
;-------------------------------
CLEAR:    JB        CHANALPRG,CLR_CHAX
          MOV       OLDSEG1,SEG1        ;ALTE ANZEIGE RETTEN
          MOV       OLDSEG2,SEG2
          MOV       OLDSEG3,SEG3
          MOV       SEG1,#0BFH          ;ANZEIGE "---"
          MOV       SEG2,#0BFH
          MOV       SEG3,#0BFH
          MOV       R5,#7FH             ;SEG.-ZEIGER AUF 1.SEG.-ADR.
          MOV       OLDKEY1,key1        ;ALTE PRG.-NR. RETTEN
          MOV       OLDKEY2,key2
          MOV       OLDKEY3,key3
          MOV       key1,#01H           ;TASTEN-REGISTER LôSCHEN
          MOV       key2,#00H
          MOV       key3,#00H
          CLR       P3.7                ;TASTENABFRAGE SPERREN
          RET

CLR_CHAX: MOV       SEG1,#0C6H          ;ANZEIGE "C--"
          MOV       SEG2,#0BFH
          MOV       SEG3,#0BFH
          MOV       key1,#01H
          MOV       key2,#00H
          MOV       key3,#00H
          MOV       R5,#7FH
          CLR       P3.7
          RET

;-------------------------------
;PRG.-NR. BERECHNEN
;-------------------------------
ENTER:    MOV       prgnr,#00H
          MOV       A,7DH
          JZ        ZEHNER
HUNDERT:  CJNE      A,#01H,ERR
          MOV       prgnr,#64H
ZEHNER:   MOV       A,7EH
          JZ        EINER
          MOV       B,#0AH
          MUL       AB
          ADD       A,prgnr
          MOV       prgnr,A
EINER:    MOV       A,7FH
          ADD       A,prgnr
          DEC       A
          MOV       prgnr,A
          JB        ACC.7,ERR           ;PRG.-NR. OVERFLOW
          CLR       ERROR
          RET

;-------------------------------
;TASTE "ENTER" GEDRöCKT,
;PRG.-CHANGE SENDEN UND DISPLAY
;EINMAL AUFBLINKEN LASSEN.
;-------------------------------
ENTER1:   JB        ERROR,ENTER2        ;WENN ERROR,ABRUCH
          MOV       HEXWERT,prgnr
          INC       HEXWERT
          LCALL     HEXDEZ
          JB        CHANALPRG,ENTER3
          SETB      prgchange
          SJMP      ENTER4
ENTER3:   CLR       CHANALPRG
          MOV       SEG1,OLDSEG1
ENTER4:   SETB      BLINK
          MOV       OFF_TIME,#025H      ;DISPLAY-OFF-TIME
          MOV       R5,#7FH
ENTER2:   CLR       P3.7
          LCALL     DIP
          CLR       CHANALPRG
          RET

;-------------------------------
;ERROR-ANZEIGE
;-------------------------------
ERR:      SETB      ERROR
          MOV       SEG1,#086H          ;ANZEIGE "ERR"
          MOV       SEG2,#0AFH
          MOV       SEG3,#0AFH
          MOV       R5,#7FH             ;SEG.-ZEIGER AUF 1.SEG.-ADR.
          CLR       prgchange
          CLR       P3.7                ;TASTENABFRAGE SPERREN
          JNB       CHANALPRG,ERR_END
          CLR       ERROR
ERR_END:  RET





;--------------------------------
; Multiplexsteuerung der Anzeige
;--------------------------------
DISPLAY:  JB        BLINK,BLINKEN
          CLR       P3.7
          MOV       A,SEG               ;Segment-Nr. in Akku
          CJNE      A,#2,ZIF2           ;Seg3 einschalten?
          MOV       A,SEG1              ;wenn ja, Seg1-2 aus.
          SETB      P1.4
          SETB      P1.5
          SETB      P1.6
          MOVX      @DPTR,A
          CLR       P1.4
          SJMP      DECSEG
ZIF2:     CJNE      A,#1,ZIF3           ;Seg2 einschalten?
          MOV       A,SEG2              ;wenn ja, Seg1 und
          SETB      P1.4                ;Seg3 aus.
          SETB      P1.5
          SETB      P1.6
          MOVX      @DPTR,A
          CLR       P1.5
          SJMP      DECSEG
ZIF3:     MOV       A,SEG3              ;Seg1 einschalten.
          SETB      P1.4                ;Seg2-3 aus.
          SETB      P1.5
          SETB      P1.6
          MOVX      @DPTR,A
;-----------------------------------
;Midi-Rec-Lampe ON/OFF
;-----------------------------------
          JNB       MIDI_REC,NON        ;MIDI-DATEN EMPFANGEN ?
          INC       LAMPE
          INC       LAMPE
          MOV       A,LAMPE
          JNB       ACC.7,LAMP_ON
          CJNE      A,#0FEH,NON
          CLR       MIDI_REC
          MOV       LAMPE,#00H
          SJMP      NON
LAMP_ON:  MOV       A,SEG3
          CLR       ACC.7
          MOVX      @DPTR,A
NON:      CLR       P1.6
          MOV       SEG,#3
DECSEG:   DEC       SEG                 ;nÑchstes Segment
          CLR       TF0                 ;bestimmen.
          CLR       TR0                 ;Multiplex-Timer neu
          LCALL     TIMER0              ;setzen und starten.
          RET
;-----------------------------------
;Anzeige einmal blinken lassen
;-----------------------------------
BLINKEN:  DJNZ      OFF_TIME,ANZ_OFF
          CLR       BLINK
          RET
ANZ_OFF:  SETB      P1.4
          SETB      P1.5
          SETB      P1.6
          CLR       TF0
          CLR       TR0                 ;Multiplex-Timer neu
          LCALL     TIMER0              ;setzen und starten.
          RET


;-------------------------------
;init. TIMER0
;Multiplex-Frequenz (100Hz)
;fÅr 7-Segment-Anzeige
;-------------------------------

TIMER0:   ORL       TMOD,#00000001B     ;TIMER0 16BIT
          MOV       TH0,#0F8H           ;Timerwert:10msec
          MOV       TL0,#0FFH
          SETB      TR0                 ;TIMER0 starten
          RET

;------------------------------------
;MIDI-BYTE SENDEN
;------------------------------------
transmit: JB        sfrei,transmit      ;warte bis SBuf leer
          MOV       SBUF,A              ;Midi-Data senden
          SETB      sfrei               ;SBuf sperren
          RET

;---------------------------------------
;Ziffer-Codes (0-9) fÅr 7Segment-Anzeige
;---------------------------------------
SEGTAB:   DB   0C0H,0F9H,0A4H           ;0-9
          DB   0B0H,099H,092H
          DB   082H,0F8H,080H
          DB   090H

;------------------------------------
;COPYRIGHT (C) ROLF DEGEN 1992
;------------------------------------
          DB        " MIDI-PROGRAMM-CHANGER"
          DB        " Version 4.1 vom 26.07.92"
          DB        " (C) ROLF DEGEN"
          DB        " ESPENSTR.26"
          DB        " 5600 WUPPERTAL-1"
          DB        " TEL:0202/436505"




