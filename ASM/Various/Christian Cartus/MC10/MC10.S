;********************************
;* Multicontrol 10-Softwarepart *
;********************************
;*  Software: Christian Cartus  *
;*  Hardware: Christoph Bîhme   *
;********************************
;************ V1.3 **************
;**** TOS-unabhÑnige Version ****
;********************************
;******* (c) 1989-1990 **********
;********************************
;*Diese Version sollte mit allen*
;* TOS-Versionen funktionieren. *
;*  Getestet mit TOS 1.0/1.2!!  *
;********************************
;* Programm nicht im FAST-Modus *
;*   (ab TOS 1.4) speichern.    *
;********************************


  TEXT

  MOVEA.L $04(SP),A5          ;Base-Page-Adresse 
                              ;holen
  MOVE.L  $0C(A5),D0          ;LÑnge des TEXT-
                              ;Segmentes holen
  ADD.W   $16(A5),D0          ;LÑnge des DATA-
                              ;Segment addieren
  ADD.W   $1E(A5),D0          ;LÑnge des BSS-
                              ;Segment addieren
  ADD.W   #256,D0             ;+LÑnge der Base-
                              ;Page
  MOVE.W  D0,memuse+4         ;Benît. Speicher-
                              ;platz retten
  MOVE.L  D0,-(SP)
  PEA     (A5)
  CLR.W   -(SP)
  MOVE.W  #$4A,-(SP)
  TRAP    #1                  ;MSHRINK
  LEA     12(SP),SP
  TST.W   D0                  ;Fehler 
                              ;aufgetreten? 
  BNE     mallocerror

  PEA     svprg(PC)           ;Progamm im SV-
                              ;Modus starten
  MOVE.W  #38,-(SP)
  TRAP    #14

svprg:
  DC.W $A00A                  ;Maus abschalten

  MOVEA.L $0472.w,A0          ;Adresse des GETBPB
                              ;Vektors holen
xbrasearch:
  LEA     -12(A0),A0          ;Zeiger auf XBRA-
                              ;Protokoll
  CMPI.L  #"XBRA",(A0)+       ;XBRA-Protokoll?
  BNE.S   xbraend
  CMPI.L  #"MC10",(A0)+       ;MC10 installiert?
  BEQ.S   mc10ai
  MOVEA.L (A0),A0             ;Neuer GETBPB-
                              ;Vektor holen
  BRA.S   xbrasearch

xbraend:
  CLR.W   -(SP)
  PEA     finame(PC)
  MOVE.W  #$3D,-(SP)
  TRAP    #1                  ;FOPEN
  ADDQ.W  #8,SP
  TST.W   D0                  ;Fehler beim 
                              ;ôffnen?
  BMI.S   nofiload
  MOVE.W  D0,-(SP)            ;File-Handle retten
  PEA     devbuf(PC)
  MOVE.L  #9,-(SP)            ;9 Bytes laden
  MOVE.W  D0,-(SP)
  MOVE.W  #$3F,-(SP)
  TRAP    #1                  ;FREAD >>FI-Datei 
                              ;laden
  LEA     12(SP),SP
  TST.W   D0                  ;Fehler beim Lesen?
  BMI.S   fileerror
  MOVE.W  #$3E,-(SP)
  TRAP    #1                  ;FCLOSE
  ADDQ.W  #4,SP
  TST.W   D0                  ;Fehler beim 
                              ;Schlieûen?
  BMI.S   fileerror
  MOVEQ.L #-33,D0             ;Fehler vorein-
                              ;stellen
nofiload:
  CMP.W   #-33,D0             ;Datei nicht ge-
                              ;funden?
  BNE.S   fileerror
  LEA     title(PC),A0        ;Erîffnungstext
  BSR     print
  BSR     getkey              ;Taste holen
  CMP.B   #"I",D0             ;I gedrÅckt?
  BEQ.S   driveinstall
  CMP.B   #"i",D0             ;i gedrÅckt?
  BEQ.S   driveinstall
prgfailend:
  DC.W $A009                  ;Maus anschalten
  CLR.W   -(SP)               ;Programm
  TRAP    #1                  ;verlassen

drverror:
  LEA     drferror(PC),A0     ;UngÅltige Lauf-
                              ;werksbezeichnung
  BRA.S   prgfailend1

mallocerror:
  LEA     malerror(PC),A0     ;Speicherplatz-
                              ;probleme!
  BRA.S   prgfailend1

fileerror:
  LEA     filerror(PC),A0     ;FI-File-Error!
  BRA.S   prgfailend1

mc10ai:
  LEA     allrinst(PC),A0     ;MC10 schon 
                              ;installiert
prgfailend1:
  BSR     print               
  BSR     getkey              ;auf Taste warten
  BRA.S   prgfailend


;************************************************
;Test, wieviel Laufwerke angeschlossen sind     *
;************************************************

driveinstall:
  ST      $043E.w             ;Floppyzugriff 
                              ;sperren
  BSR     portinstall         ;Hardware-Reset 
                              ;auslîsen
  MOVEQ   #0,D1               ;Seite 0 vorein-
                              ;stellen
  MOVEQ   #0,D3               ;mit Laufwerks-
                              ;adresse 0 beginnen
  LEA     ddsb(PC),A1         ;Basisadresse der 
                              ;Trackinformationen
  LEA     devclock(PC),A2     ;Basisadresse der 
                              ;Laufwerksadressen
  MOVE.L  #$10101010,(A2)     ;Laufwerksadressen 
                              ;auf nicht
  MOVE.L  #$10101010,4(A2)    ;angeschlossen 
                              ;setzen
  LEA     $FFFF8606.w,A6      ;DMA-Basisregister
  MOVEQ   #8-1,D2             ;8 Laufwerke testen
drinstloop:
  LEA     indrives(PC),A0     ;Meldung welches
  BSR     print               ;Laufwerk geprÅft 
                              ;wird
  MOVE.W  $0440.w,2(A1)       ;Seek-Rate kopieren
  MOVE.B  D3,D0               ;Laufwerksadresse 
                              ;eintragen
  BSR     portselect          ;externes Laufwerk 
                              ;selektieren
  BSR     restore             ;Track 0 anfahren
  BEQ.S   drfound             ;erfolgreich?
  MOVEQ   #10,D7              ;Track 10
  BSR     hseek1              ;anfahren
  BNE.S   drnfound            ;nicht erfolgreich?
  BSR     restore             ;Track 0 anfahren
  BNE.S   drnfound            ;nicht erfolgreich?
drfound:
  MOVE.B  D3,(A2)+            ;Laufwerksadresse 
                              ;eintragen
  ADDQ.W  #4,A1               ;ddsb-Adresse 
                              ;erhîhen
  ADDQ.B  #1,drcount2         ;Text Ñndern
drnfound:
  ADDQ.B  #1,drcount1         ;Anzahl im Text 
                              ;erhîhen
  ADDQ.W  #2,D3               ;Laufwerksadresse 
                              ;erhîhen
  DBRA    D2,drinstloop
  CLR.W   $043E.w             ;Floppyzugriff 
                              ;erlauben

  CMPI.B  #"0",drcount2       ;Åberhaupt Lauf-
                              ;werke angeschlos-
                              ;sen?
  BNE.S   extdrinst
  LEA     nodractive(PC),A0   ;Meldung, daû kein 
                              ;Laufwerk
                              ;angeschlossen ist
  BRA     prgfailend1         ;Programmende

extdrinst:

  MOVE.B  drcount2(PC),D0     ;Anzahl der aktiven
  SUB.B   #"1",D0             ;Laufwerke er-
                              ;rechnen
  EXT.W   D0
  LEA     devbase(PC),A1      ;Basisadresse der 
                              ;aktiven Laufwerks-
                              ;bezeichnungen
  LEA     devbuf(PC),A0       ;Basisadr. der 
                              ;Laufwerks-
                              ;bezeichnungen
  MOVEQ   #-1,D1
  MOVE.L  D1,(A1)             ;Devbase mit 
                              ;ungÅltigen Dev-
  MOVE.L  D1,4(A1)            ;Nummern belegen
  MOVE.L  $04C2.w,D1          ;drvbits holen
drvbitsset:
  MOVE.B  (A0)+,D2            ;1 Laufwerksbe-
                              ;zeichnung holen
  CMP.B   #"P",D2             ;grîûer P?
  BGT     drverror
  SUB.B   #"A",D2             ;- ASCII-Wert von A
  BMI     drverror            ;Wert kleiner A?
  BSET    D2,D1               ;Bit setzen
  BNE     drverror            ;Bit schon belegt?
  MOVE.B  D2,(A1)+            ;in Devbase ein-
                              ;tragen
  DBRA    D0,drvbitsset
  MOVE.L  D1,$04C2.w          ;drvbits eintragen

  MOVE    #$2700,SR
  MOVE.L  $70.w,vblold+2      ;VBL-Vektor retten
  MOVE.L  $70.w,flopvbl-4     ;in XBRA-Protokoll 
                              ;eintragen
  MOVE.L  $0472.w,getbpbold+2 ;GETBPB-Vektor 
                              ;retten
  MOVE.L  $0472.w,getbpb-4    ;in XBRA-Protokoll 
                              ;eintragen
  MOVE.L  $0476.w,rwabsold+2  ;RWABS-Vektor 
                              ;retten
  MOVE.L  $0476.w,rwabs-4     ;in XBRA-Protokoll 
                              ;eintragen
  MOVE.L  $047E.w,mediachold+2 ;MEDIACH-Vektor 
                              ;retten
  MOVE.L  $047E.w,mediach-4   ;in XBRA-Protokoll 
                              ;eintragen
  MOVE.L  #flopvbl,$70.w      ;neuer VBL-Vektor
  MOVE.L  #getbpb,$0472.w     ;neuer GETBPB-
                              ;Vektor
  MOVE.L  #rwabs,$0476.w      ;neuer RWABS-Vektor
  MOVE.L  #mediach,$047E.w    ;neuer MEDIACH-
                              ;Vektor
  MOVE    #$2300,SR
  LEA     dractive(PC),A0     ;Meldung, wieviel 
                              ;Laufwerke ange-
                              ;schlossen sind
  BSR.S   print
  BSR.S   getkey              ;auf Taste warten
  DC.W $A009                  ;Maus anschalten
  CLR.W   -(SP)
memuse:
  MOVE.L  #0,-(SP)            ;Porgramm resident
  MOVE.W  #$31,-(SP)          ;im Speicher
  TRAP    #1                  ;halten

print:
  MOVEM.L D0-D2/A1-A2,-(SP)
  PEA     (A0)
  MOVE.W  #$09,-(SP)
  TRAP    #1                  ;CCONWS
  ADDQ.W  #6,SP
  MOVEM.L (SP)+,D0-D2/A1-A2
  RTS

getkey:
  MOVE.W  #$07,-(SP)
  TRAP    #1                  ;CRAWCIN
  ADDQ.W  #2,SP
  RTS


;************************************************
;die Verwaltungsroutinen (RWABS,GETBPB,MEDIACH) *
;************************************************

  DC.B "XBRA"                 ;XBRA-Kennung
  DC.B "MC10"                 ;ID-Name
  DC.L 0                      ;alter GETBPB-
                              ;Vektor

getbpb:
  LINK    A6,#-12
  MOVEM.L D5-D7/A4-A5,-(SP)
  MOVEQ   #7,D0               ;8 Dev-EintrÑge 
                              ;ÅbnerprÅfen
  MOVE.W  8(A6),D5            ;verlangte Dev-
                              ;Nummer holen
  LEA     devbase(PC),A4      ;Startadr. der ex-
                              ;ternen Dev-Ein-
                              ;trÑge
devsearch1:
  CMP.B   (A4)+,D5            ;verlangte Dev-
                              ;Nummer gefunden?
  BEQ.S   devfound1
  DBRA    D0,devsearch1
  MOVEM.L (SP)+,D5-D7/A4-A5   ;Register zurÅck-
                              ;werfen
  UNLK    A6
  BSR     portdeselect        ;alle externen 
                              ;Laufwerke ab-
                              ;schalten
getbpbold:
  JMP     $12345678           ;ins TOS springen
devfound1:
  EORI.W  #$07,D0             ;Dev-Nummer er-
                              ;rechnen
  MOVE.W  D0,aktdev           ;Dev-Nummer 
                              ;zwischenspeichern
  ASL.W   #5,D0               ;*32
  LEA     bpbbase(PC),A5      ;Basisadr. des BPB-
                              ;Blocks
  ADDA.W  D0,A5               ;errechneter Dis-
                              ;tanzwert addieren
bpbbootread:
  MOVE.L  #$01,-(SP)          ;1 Sektor lesen/
                              ;Seite 0
  MOVE.L  #$010000,-(SP)      ;Track 0/Sektor 1
  MOVE.W  aktdev(PC),-(SP)    ;Dev-Nummer ein-
                              ;tragen
  CLR.L   -(SP)               ;Dummy
  MOVE.L  $04C6.w,-(SP)       ;Pufferadr. ein-
                              ;tragen
  BSR     floprd              ;Bootsektor lesen
  LEA     18(SP),SP
  TST.L   D0                  ;Fehler?
  BEQ.S   bpbnrerror
  MOVE.W  aktdev(PC),-(SP)    ;Dev-Nummer
  MOVE.W  D0,-(SP)            ;Fehlernummer
  BSR     critical            ;Critical-Handle-
                              ;Error auslîsen
  ADDQ.W  #4,SP
bpbnrerror:
  CMP.L   #$010000,D0         ;Retry?
  BEQ.S   bpbbootread
  TST.L   D0                  ;Fehler?
  BEQ.S   bpbnrerror1
bpberror:
  MOVEQ   #0,D0               ;Null aus Ergebnis
  BRA     getbpbend           ;rausspringen
bpbnrerror1:
  MOVEA.L $04C6.w,A4          ;Pufferadresse
  LEA     11(A4),A0           ;Bytes pro Sektor
                              ;holen
  BSR     convert
  MOVE.W  D0,D7               ;d0 nach d7 ko-
                              ;pieren
  BLE.S   bpberror            ;bei 0 oder negativ
                              ;>> Fehler
  MOVEQ   #0,D6               ;d6 lîschen
  MOVE.B  13(A4),D6           ;Sektoren pro 
                              ;Cluster holen
  BLE.S   bpberror            ;bei 0 oder negativ
                              ;>> Fehler
  MOVE.W  D7,(A5)             ;eintragen
  MOVE.W  D6,2(A5)            ;eintragen
  LEA     22(A4),A0           ;Sektor pro FAT 
                              ;holen
  BSR     convert             ;Intel >> 68000
  MOVE.W  D0,8(A5)            ;eintragen
  ADDQ.W  #1,D0               ;1 addieren
  MOVE.W  D0,10(A5)           ;eintragen
  MOVE.W  (A5),D0             ;recsize holen
  MULS    2(A5),D0            ;* clsize
  MOVE.W  D0,4(A5)            ;eintragen
  LEA     17(A4),A0           ;Anzahl der 
                              ;DirectoryeintrÑge 
                              ;holen
  BSR     convert             ;Intel >> 68000
  ASL.W   #5,D0               ;*32
  EXT.L   D0
  DIVS    (A5),D0             ;/ recsize
  MOVE.W  D0,6(A5)            ;eintragen
  MOVE.W  10(A5),D0           ;fatrec holen
  ADD.W   8(A5),D0            ;+ fsize
  ADD.W   6(A5),D0            ;+ rdlen
  MOVE.W  D0,12(A5)           ;eintragen
  LEA     19(A4),A0           ;Anzahl Sektoren 
                              ;holen
  BSR     convert             ;Intel >> 68000
  SUB.W   12(A5),D0           ;- datrec
  EXT.L   D0
  DIVS    2(A5),D0            ;/ clsize
  MOVE.W  D0,14(A5)           ;eintragen

  LEA     26(A4),A0           ;Anzahl Seiten 
                              ;holen
  BSR     convert             ;Intel >> 68000
  MOVE.W  D0,20(A5)           ;eintragen
  LEA     24(A4),A0           ;Sektor pro Track 
                              ;holen
  BSR     convert             ;Intel >> 68000
  MOVE.W  D0,24(A5)           ;eintragen
  MOVE.W  20(A5),D0           ;dnsides holen
  MULS    24(A5),D0           ;* dspt
  MOVE.W  D0,22(A5)           ;eintragen
  LEA     28(A4),A0           ;Anzahl verst. 
                              ;Sektoren holen
  BSR     convert             ;Intel >> 68000
  MOVE.W  D0,26(A5)           ;eintragen
  LEA     19(A4),A0           ;Anzahl Sektoren 
                              ;auf Diskette holen
  BSR     convert             ;Intel >> 68000
  EXT.L   D0
  DIVS    22(A5),D0           ;/ spt
  MOVE.W  D0,18(A5)           ;eintragen
  MOVE.W  8(A4),28(A5)        ;Seriennummer
  MOVE.B  10(A4),30(A5)       ;eintragen
  CLR.B   31(A5)              ;12-Bit FAT

  LEA     cdev(PC),A0         ;CDEV-Adresse
  MOVE.W  aktdev(PC),D7       ;aktuelle Dev-
                              ;Nummer holen
  LEA     wpstatus(PC),A1     ;WPSTATUS-Adresse
  MOVEQ   #0,D0               ;Disk wurde nicht 
                              ;gewechselt
  MOVE.B  0(A1,D7.w),0(A0,D7.w) ;WPSTATUS in CDEV
  BEQ.S   nodchange1          ;bei 0 >> kein 
                              ;Diskwechsel
  MOVEQ   #1,D0               ;Diskstatus un-
                              ;sicher
nodchange1:
  LEA     dsb(PC),A1          ;DSB-Adresse
  MOVE.B  D0,0(A1,D7.w)       ;Status speichern
  MOVE.L  A5,D0               ;BPB-Adresse nach  
                              ;d0 kopieren
getbpbend:
  MOVEM.L (SP)+,D5-D7/A4-A5   ;Register zurÅck-
                              ;werfen
  UNLK    A6
  RTS

;************************************************

mediachin:
  LINK    A6,#0
  MOVEM.L D6-D7/A5,-(SP)
  MOVE.W  8(A6),D7            ;Dev-Nummer holen
  BRA.S   mediach1            ;Zur Hauptroutine 
                              ;springen

  DC.B "XBRA"                 ;XBRA-Kennung
  DC.B "MC10"                 ;ID-Name
  DC.L 0                      ;alter MEDIACH-
                              ;Vektor

mediach:
  LINK    A6,#0
  MOVEM.L D6-D7/A5,-(SP)
  MOVEQ   #7,D7               ;8 Dev-EintrÑge 
                              ;ÅberprÅfen
  MOVE.W  8(A6),D6            ;verlangte Dev-
                              ;Nummer holen
  LEA     devbase(PC),A5      ;Startadr. der ex-
                              ;ternen Dev-Ein-
                              ;trÑge
devsearch2:
  CMP.B   (A5)+,D6            ;verlangte Dev-
                              ;Nummer gefunden?
  BEQ.S   devfound2
  DBRA    D7,devsearch2
  MOVEM.L (SP)+,D6-D7/A5      ;Register zurÅck-
                              ;werfen
  UNLK    A6
mediachold:
  JMP     $12345678           ;ins TOS springen
devfound2:
  EORI.W  #$07,D7             ;Dev-Nummer er-
                              ;rechnen
mediach1:
  LEA     dsb(PC),A5          ;DSB-Adresse
  ADDA.W  D7,A5               ;+ Dev-Nummer
  CMPI.B  #2,(A5)             ;media changed?
  BNE.S   nomchange1
  MOVEQ   #2,D0               ;Disk wurde ge-
                              ;wechselt
  BRA.S   mediaend            ;rausspringen
nomchange1:
  LEA     cdev(PC),A0         ;CDEV-Adresse
  TST.B   0(A0,D7.w)          ;Dev testen
  BEQ.S   nomchange2          ;Status ok?
  MOVE.B  #1,(A5)             ;Status unsicher
nomchange2:
  MOVE.L  $04BA.w,D0          ;Timer C-ZÑhler 
                              ;holen
  ASL.W   #2,D7               ;*4
  LEA     acctim(PC),A1       ;ACCTIM-Adresse
  SUB.L   0(A1,D7.w),D0       ;von letzte Zu-
                              ;griffszeit subtr.
  CMP.L   #300,D0             ;noch kleiner als 
                              ;1.5 Sec. ?
  BGE.S   nomchange3
  MOVEQ   #0,D0               ;Disk wurde nicht 
                              ;gewechselt
  BRA.S   mediaend
nomchange3:
  MOVE.B  (A5),D0             ;Cdev holen
mediaend:
  EXT.W   D0
  MOVEM.L (SP)+,D6-D7/A5      ;Register zurÅck-
                              ;werfen
  UNLK    A6
  RTS

;************************************************

tadw:
  LINK    A6,#0
  MOVEM.L D4-D7/A5,-(SP)
  MOVE.W  8(A6),D6            ;Dev-Nummer holen
  MOVE.W  D6,D0               ;d6 nach d0 ko-
                              ;pieren
  ASL.W   #5,D0               ;*32
  LEA     bpbbase(PC),A5      ;BPB-Basisadresse
  ADDA.W  D0,A5               ;d0 dazuaddieren
  MOVE.W  D6,(SP)             ;Dev-Nummer Åber-
                              ;geben
  BSR     mediachin           ;Mediach-Routine 
                              ;ausfÅhren
  CMP.W   #2,D0               ;Diskette ge-
                              ;wechselt?
  BEQ.S   tadwend             ;mit Ergebnis raus-
                              ;springen
  CMP.W   #1,D0               ;Diskstatus un-
                              ;sicher?
  BNE.S   tadwok              ;rauspringen
tadwbootread:
  MOVE.L  #$01,-(SP)          ;1 Sektor lesen/
                              ;Seite 0
  MOVE.L  #$010000,-(SP)      ;Track 0/Sektor 1
  MOVE.W  D6,-(SP)            ;Dev-Nummer ein-
                              ;tragen
  CLR.L   -(SP)               ;Dummy
  MOVE.L  $04C6.w,-(SP)       ;Pufferadr. ein-
                              ;tragen
  BSR     floprd              ;Bootsektor lesen
  LEA     18(SP),SP
  TST.L   D0                  ;Fehler?
  BEQ.S   tadwnerror
  MOVE.W  D6,-(SP)            ;Dev-Nummer
  MOVE.W  D0,-(SP)            ;Fehlernummer
  BSR     critical            ;Critical-Handle-
                              ;Error auslîsen
  ADDQ.L  #4,SP
tadwnerror:
  CMP.L   #$010000,D0         ;Retry?
  BEQ.S   tadwbootread
  TST.L   D0                  ;Fehler?
  BNE.S   tadwend

  MOVEQ   #2,D0               ;Disk gewechselt 
                              ;als Default
  MOVEA.L $04C6.w,A0          ;Bootsektorpuffer 
                              ;holen
  MOVE.W  8(A0),D7            ;1 Wort der Serien-
                              ;nummer holen
  CMP.W   28(A5),D7           ;mit BPB-Eintrag 
                              ;vergleichen
  BNE.S   tadwend             ;ungleich?
  MOVE.B  10(A0),D7           ;letztes Byte der 
                              ;Seriennummer holen
  CMP.B   30(A5),D7           ;mit BPB-Eintrag 
                              ;vergleichen
  BNE.S   tadwend             ;ungleich?
  LEA     cdev(PC),A0         ;CDEV-Adresse
  LEA     wpstatus(PC),A1     ;WPSTATUS-Adresse
  MOVE.B  0(A1,D6.w),0(A0,D6.w) ;WPSTATUS in CDEV
  BNE.S   tadwok
  LEA     dsb(PC),A0          ;DSB-Adresse
  CLR.B   0(A0,D6.w)          ;Media-change-Ein-
                              ;trag lîschen
tadwok:
  MOVEQ   #0,D0               ;alles ok
tadwend:
  MOVEM.L (SP)+,D4-D7/A5      ;Register zurÅck-
                              ;werfen
  UNLK    A6
  RTS

;************************************************
  DC.B "XBRA"                 ;XBRA-Kennung
  DC.B "MC10"                 ;ID-Name
  DC.L 0                      ;alter RWABS-Vektor

rwabs:
  LINK    A6,#0
  MOVEM.L D5-D7,-(SP)
  MOVEQ   #7,D7               ;8 Dev-EintrÑge 
                              ;ÅberprÅfen
  MOVE.W  18(A6),D6           ;verlangte Dev-
                              ;Nummer holen
  LEA     devbase(PC),A0      ;Startadr. der ex-
                              ;ternen Dev-Ein-
                              ;trÑge
devsearch3:
  CMP.B   (A0)+,D6            ;verlangte Dev-
                              ;Nummer gefunden?
  BEQ.S   devfound3
  DBRA    D7,devsearch3
  MOVEM.L (SP)+,D5-D7         ;Register zurÅck-
                              ;werfen
  UNLK    A6
  BSR     portdeselect        ;alle externen 
                              ;Laufwerke ab-
                              ;schalten
rwabsold:
  JMP     $12345678           ;ins TOS springen
devfound3:
  EORI.W  #$07,D7             ;Dev-Nummer er-
                              ;rechnen
  MOVE.W  D7,aktdev           ;Dev-Nummer 
                              ;zwischenspeichern
  TST.L   10(A6)              ;Puffer=0?
  BNE.S   rwabsbufferok
  MOVE.W  14(A6),D0           ;Anzahl der Sek-
                              ;toren holen
  LEA     dsb(PC),A1          ;DSB-Adresse
  ADDA.W  aktdev(PC),A1       ;Dev-Nummer dazu-
                              ;addieren
  MOVE.B  D0,(A1)             ;in DSB speichern
  MOVEQ   #0,D0               ;Ergebnis auf OK
  BRA.S   rwabsend            ;rausspringen
rwabsbufferok:
  CMPI.W  #2,8(A6)            ;media-changed 
                              ;ignorieren?
  BGE.S   gofloprw
  MOVE.W  D7,(SP)             ;Dev-Nummer Åber-
                              ;geben
  BSR     tadw                ;Test ob Disk 
                              ;gewechselt?
  EXT.L   D0
  TST.L   D0                  ;Disk nicht ge-
                              ;wechselt?
  BEQ.S   gofloprw
  CMP.L   #2,D0               ;Disk gewechselt?
  BNE.S   rwabsunsure
  MOVEQ   #-14,D0             ;Disk wurde ge-
                              ;wechselt
rwabsunsure:
  BRA.S   rwabsend            ;rausspringen
gofloprw:
  MOVE.W  14(A6),-(SP)        ;Anzahl der Sek-
                              ;toren
  MOVE.W  D7,-(SP)            ;Dev-Nummer
  MOVE.W  16(A6),-(SP)        ;erste Sektornummer
  MOVE.L  10(A6),-(SP)        ;Pufferadresse
  MOVE.W  8(A6),-(SP)         ;rwflag
  BSR.S   floprw              ;Sektoren be-
                              ;arbeiten
  LEA     12(SP),SP
rwabsend:
  MOVEM.L (SP)+,D5-D7         ;Register zurÅck-
                              ;werfen
  UNLK    A6
  RTS

;************************************************

floprw:
  LINK    A6,#-6
  MOVEM.L D2-D7/A5,-(SP)
  MOVE.W  16(A6),D0           ;Dev-Nummer holen
  ASL.W   #5,D0               ;*32
  LEA     bpbbase(PC),A5      ;BPB-Basisadresse
  ADDA.W  D0,A5               ;Dev-Nummer*32 dazu
addieren
  MOVEQ   #1,D0               ;ODD-Flag setzen
  BTST    #0,13(A6)           ;Pufferadresse 
                              ;ungerade?
  BNE.S   floprwodd
  MOVEQ   #0,D0               ;ODD-Flag lîschen
floprwodd:
  MOVE.W  D0,-2(A6)           ;ODD-Flag speichern
  TST.W   22(A5)              ;dspc <>0?
  BNE.S   floprww1
  MOVEQ   #9,D0               ;9 Sektoren vorein-
                              ;stellen
  MOVE.W  D0,22(A5)           ;und
  MOVE.W  D0,24(A5)           ;eintragen
floprww1:
  BRA     floprwloop          ;zum Schleifenende 
springen
floprwb:
  MOVE.L  10(A6),D0           ;Pufferadresse 
                              ;in d0
  TST.W   -2(A6)              ;ODD-Flag gesetzt?
  BEQ.S   floprwnoodd
  MOVE.L  $04C6.w,D0          ;GFX-Puffer in d0
floprwnoodd:
  MOVE.L  D0,-6(A6)           ;Adresse zwischen-
                              ;speichern
  MOVE.W  14(A6),D6           ;logische Sektor-
                              ;nummer holen
  EXT.L   D6
  DIVS    22(A5),D6           ;/dspc >> Start-
                              ;track
  MOVE.L  D6,D4               ;Trackwert nach d4
  SWAP    D4                  ;Rest holen >> 
                              ;Startsektor
  CMP.W   24(A5),D4           ;dspt grîûer?
  BGE.S   floprww2
  MOVEQ   #0,D5               ;Seite 0
  BRA.S   floprww3
floprww2:
  MOVEQ   #1,D5               ;Seite 1
  SUB.W   24(A5),D4           ;dspt abziehen
floprww3:
  TST.W   -2(A6)              ;ODD-Flag gesetzt?
  BEQ.S   floprwodd1
  MOVEQ   #1,D3               ;Sektorenanzahl 
                              ;auf 1 
  BRA.S   floprww4
floprwodd1:
  MOVE.W  24(A5),D0           ;dspt holen
  SUB.W   D4,D0               ;- Sektornummer
  MOVE.W  18(A6),D3           ;Anzahl Sektoren 
                              ;holen
  CMP.W   D3,D0               ;mit Anzahl der 
                              ;Sektoren ver-
                              ;gleichen
  BGE.S   floprww4
  MOVE.W  24(A5),D3           ;dspt holen
  SUB.W   D4,D3               ;- Sektornummer
floprww4:
  ADDQ.W  #1,D4               ;Sektornummer er-
                              ;hîhen
floprwrw:
  BTST    #0,9(A6)            ;rwflag testen
  BEQ.S   secread
  MOVE.L  -6(A6),D0           ;Pufferadresse 
                              ;holen
  CMP.L   10(A6),D0           ;gleich angegebener
                              ;Zieladresse?
  BEQ.S   nofcopy1
  MOVEA.L D0,A0               ;Quelladresse
  MOVEA.L 10(A6),A1           ;Zieladresse
  BSR     fcopy               ;512 Bytes kopieren
nofcopy1:
  MOVE.W  D3,-(SP)            ;Anzahl Sektoren
  MOVE.W  D5,-(SP)            ;Seite
  MOVE.W  D6,-(SP)            ;Track
  MOVE.W  D4,-(SP)            ;Sektoranfang
  MOVE.W  16(A6),-(SP)        ;Dev-Nummer
  CLR.L   -(SP)               ;Dummy
  MOVE.L  -6(A6),-(SP)        ;Startadresse
  BSR     flopwr              ;Sektoren schreiben
  LEA     18(SP),SP
  MOVE.L  D0,D7               ;Fehlercode nach d7
  TST.L   D0                  ;Fehler?
  BNE.S   floprwerror
  TST.W   $0444.w             ;verifizieren?
  BEQ.S   floprwerror
  MOVE.W  D3,-(SP)            ;Anzahl Sektoren
  MOVE.W  D5,-(SP)            ;Seite
  MOVE.W  D6,-(SP)            ;Track
  MOVE.W  D4,-(SP)            ;Sektoranfang
  MOVE.W  16(A6),-(SP)        ;Dev-Nummer
  CLR.L   -(SP)               ;Dummy
  MOVE.L  $04C6.w,-(SP)       ;GFX-Puffer
  BSR     flopver             ;Sektoren veri-
                              ;fizieren
  LEA     18(SP),SP
  MOVE.L  D0,D7               ;Fehlercode nach d7
  TST.L   D0                  ;Fehler?
  BNE.S   floprwerror
  MOVEA.L $04C6.w,A0          ;GFX-Puffer-Adresse
                              ;holen
  TST.W   (A0)                ;Fehler beim Veri-
                              ;fizieren
  BEQ.S   floprwerror
  MOVEQ   #-16,D7             ;>> Bad Sectors
  BRA.S   floprwerror
secread:
  MOVE.W  D3,-(SP)            ;Anzahl Sektoren
  MOVE.W  D5,-(SP)            ;Seite
  MOVE.W  D6,-(SP)            ;Track
  MOVE.W  D4,-(SP)            ;Sektoranfang
  MOVE.W  16(A6),-(SP)        ;Dev-Nummer
  CLR.L   -(SP)               ;Dummy
  MOVE.L  -6(A6),-(SP)        ;Startadresse
  BSR     floprd              ;Sektoren lesen
  LEA     18(SP),SP
  MOVE.L  D0,D7               ;Fehlercode nach d7
  MOVE.L  -6(A6),D0           ;Pufferadresse 
                              ;holen
  CMP.L   10(A6),D0           ;gleich angegebener
                              ;Zieladresse?
  BEQ.S   nofcopy2
  MOVEA.L 10(A6),A0           ;Quelladresse
  MOVEA.L D0,A1               ;Zieladresse
  BSR     fcopy               ;512 Bytes kopieren
nofcopy2:
floprwerror:
  TST.L   D7                  ;Fehler?
  BEQ.S   floprwnerror
  MOVE.W  16(A6),-(SP)        ;Dev-Nummer
  MOVE.W  D7,-(SP)            ;Fehlernummer
  BSR.S   critical            ;Critical-Handle-
                              ;Error auslîsen
  ADDQ.L  #4,SP
  MOVE.L  D0,D7               ;RÅckgabewert nach 
                              ;d7
  CMPI.W  #2,8(A6)            ;Media change ig-
                              ;norieren?
  BGE.S   floprwnerror
  CMP.L   #$010000,D7         ;Retry?
  BNE.S   floprwnerror
  MOVE.W  16(A6),(SP)         ;Dev-Nummer
  BSR     tadw                ;Test auf Disk-
                              ;wechsel
  CMP.W   #2,D0               ;Disk gewechselt?
  BNE.S   floprwnerror
  MOVEQ   #-14,D7             ;Disk wurde ge-
                              ;wechselt
floprwnerror:
  CMP.L   #$010000,D7         ;Retry?
  BEQ     floprwrw
  TST.L   D7                  ;Fehler?
  BEQ.S   floprww5
  MOVE.L  D7,D0               ;Fehlercode nach d0
  BRA.S   floprwend           ;rausspringen
floprww5:
  MOVE.W  D3,D0               ;SektorzÑhler nach 
                              ;d0
  EXT.L   D0
  SWAP    D0
  ASR.L   #7,D0               ;*512
  ADD.L   D0,10(A6)           ;Pufferadresse er-
                              ;hîhen
  ADD.W   D3,14(A6)           ;logische Sektor-
                              ;nummer erhîhen
  SUB.W   D3,18(A6)           ;Anzahl der Sek-
                              ;toren vermindern
floprwloop:
  TST.W   18(A6)              ;alle Sektoren be-
                              ;arbeitet?
  BNE     floprwb
  MOVEQ   #0,D0               ;alles ok
floprwend:
  MOVEM.L (SP)+,D2-D7/A5
  UNLK    A6
  RTS

;************************************************

critical:
  PEA     (A0)
  LEA     devbase(PC),A0      ;Startadresse der 
                              ;externen Dev-Ein-
                              ;trÑge
  MOVE.L  8(SP),D0            ;Stackwerte holen
  MOVE.B  0(A0,D0.w),D0       ;Laufwerksnummer 
                              ;aus den Dev-Ein-
                              ;trÑgen holen
  MOVE.L  D0,-(SP)            ;Werte speichern
  MOVEA.L $0404.w,A0          ;Adr. der Critical-
                              ;Handle-Error
  MOVEQ   #-1,D0              ;Default auf Error
  JSR     (A0)                ;Critical-Handle-
                              ;Error ausfÅhren
  ADDQ.W  #4,SP
  MOVEA.L (SP)+,A0
  RTS

;************************************************

convert:
  MOVEP.W 1(A0),D0            ;High-Byte holen
  MOVE.B  (A0),D0             ;Low-Byte dazu
  RTS

;************************************************

fcopy:
  MOVEQ   #128-1,D0           ;512 Bytes kopieren
copy:
  MOVE.B  (A0)+,(A1)+
  MOVE.B  (A0)+,(A1)+
  MOVE.B  (A0)+,(A1)+
  MOVE.B  (A0)+,(A1)+
  DBRA    D0,copy
  RTS

;************************************************
;Systemroutinen(FLOPRD,FLOPWR,FLOPVER)          *
;************************************************

floprd:
  MOVEQ   #-11,D0             ;Read-Error vorein-
                              ;stellen
  BSR     floplock            ;Floppyparameter 
                              ;einstellen
floprdloop:
  BSR     selectdr            ;Laufwerk selek-
                              ;tieren
  BSR     go2track            ;Track anfahren
  BNE     floprderror
floprdloop1:
  MOVE.W  #-1,derror          ;General-Error
  MOVE.W  #$90,(A6)           ;DMA-
  MOVE.W  #$0190,(A6)         ;FIFO lîschen
  MOVE.W  #$90,(A6)           ;und auf Lesen 
                              ;setzen
  MOVEQ   #1,D7               ;1 Sektor lesen
  BSR     wr7fdc              ;Sektoranzahl ein-
                              ;tragen
  MOVE.W  #$80,(A6)           ;FDC-Komandore-
                              ;gister
  MOVE.W  #$80,D7             ;Lese-Befehl
  BSR     wr7fdc              ;Befehl ausfÅhren
  MOVEQ   #$04,D7             ;Time-Out-Wert auf
  SWAP    D7                  ;$40000
floprdlp:
  BTST    #5,$FFFFFA01.w      ;fertig?
  BEQ.S   floprdfn
  SUBQ.L  #1,D7               ;Time-Out-ZÑhler 
                              ;vermindern
  BNE.S   floprdlp
  MOVE.W  #-2,derror          ;Drive-not-ready
  BSR     fdcreset            ;FDC-Reset
  BRA.S   floprderror
floprdfn:
  MOVE.W  #$90,(A6)           ;DMA-Statusregister
 anwÑhlen
  MOVE.W  (A6),D0             ;DMA-Status holen
  BTST    #0,D0               ;DMA-Error?
  BEQ.S   floprderror
  MOVE.W  #$80,(A6)           ;FDC-Statusregister
 anwÑhlen
  BSR     rd0fdc              ;Status holen
  ANDI.B  #$1C,D0             ;Fehler-Bits aus-
                              ;maskieren
  BNE.S   floprderror1
  MOVE.W  #2,dretry           ;3 Versuche
  ADDQ.W  #1,dsect            ;Sektornummer er
                              ;hîhen
  ADDI.L  #$0200,dbuf         ;DMA-Adresse er-
                              ;hîhen
  SUBQ.W  #1,dcount           ;Anzahl vermindern
  BEQ     flopok
  BSR     selectdr1           ;DMA-Adresse setzen
  BRA     floprdloop1
floprderror1:
  BSR     errbits             ;Fehler bearbeiten
floprderror:
  CMPI.W  #1,dretry           ;2. Versuch?
  BNE.S   floprdn2try
  BSR     reseek              ;Reseek
floprdn2try:
  SUBQ.W  #1,dretry           ;VersuchszÑhler 
                              ;vermindern
  BPL     floprdloop
  BRA     flopfail            ;mit Fehler raus-
                              ;springen

;************************************************

flopwr:
  MOVEQ   #-10,D0             ;Write-Error vor-
                              ;einstellen
  BSR     floplock            ;Floppyparameter 
                              ;einstellen
  MOVE.W  dsect(PC),D0        ;Sektornummer holen
  SUBQ.W  #1,D0               ;-1
  OR.W    dtrack(PC),D0       ;Tracknummer dazu-
                              ;odern
  OR.W    dside(PC),D0        ;Seite dazuodern
  BNE.S   flopwrnmc
  MOVEQ   #2,D0               ;media change
  BSR     setdmode            ;Diskstatus setzen
flopwrnmc:
  BSR     selectdr            ;Laufwerk selekt-
                              ;ieren
  BSR     go2track            ;Track anfahren
  BNE     flopwrerror
flopwrloop:
  MOVE.W  #-1,derror          ;General-Error
  MOVE.W  #$0190,(A6)         ;DMA-
  MOVE.W  #$90,(A6)           ;FIFO lîschen
  MOVE.W  #$0190,(A6)         ;und auf schreiben 
setzen
  MOVEQ   #1,D7               ;1 Sektor schreiben
  BSR     wr7fdc              ;Sektoranzahl ein-
                              ;tragen
  MOVE.W  #$0180,(A6)         ;FDC-Kommandore-
                              ;gister anwÑhlen
  MOVE.W  #$A0,D7             ;Schreib-Befehl
  BSR     wr7fdc              ;Befehl ausfÅhren
  MOVEQ   #$04,D7             ;Time-Out-ZÑhler 
                              ;auf
  SWAP    D7                  ;$40000
flopwrlp:
  BTST    #5,$FFFFFA01.w      ;fertig?
  BEQ.S   flopwrfn
  SUBQ.L  #1,D7               ;Time-Out-ZÑhler 
                              ;vermindern
  BNE.S   flopwrlp
  BSR     fdcreset            ;FDC-Reset
  BRA.S   flopwrerror1
flopwrfn:
  MOVE.W  #$0180,(A6)         ;FDC-Statusregister
 anwÑhlen
  BSR     rd0fdc              ;Status holen
  BSR     errbits             ;Fehler bearbeiten
  BTST    #6,D0               ;war Disk schreib-
                              ;geschÅtzt?
  BNE     flopfail
  ANDI.B  #$5C,D0             ;Fehlerbits aus-
                              ;maskieren
  BNE.S   flopwrerror1
  MOVE.W  #2,dretry           ;3 Versuche
  ADDQ.W  #1,dsect            ;Sektornummer er-
                              ;hîhen
  ADDI.L  #$0200,dbuf         ;DMA-Adresse er-
                              ;hîhen
  SUBQ.W  #1,dcount           ;Anzahl vermindern
  BEQ     flopok
  BSR     selectdr1           ;DMA-Adresse setzen
  BRA.S   flopwrloop
flopwrerror1:
  CMPI.W  #1,dretry           ;2. Versuch?
  BNE.S   flopwrn2try
flopwrerror:
  BSR     reseek              ;Reseek
flopwrn2try:
  SUBQ.W  #1,dretry           ;VersuchszÑhler 
                              ;vermindern
  BPL     flopwrnmc
  BRA     flopfail            ;mit Fehler raus-
                              ;springen

;************************************************

flopver:
  MOVEQ   #-11,D0             ;Read-Error vorein-
                              ;stellen
  BSR     floplock            ;Floppyparameter 
                              ;einstellen
  BSR     selectdr            ;Laufwerk selekt-
                              ;ieren
  BSR     go2track            ;Track anfahren
  BNE     flopfail
  BSR.S   verify              ;Sektoren veri-
                              ;fizieren
  BRA     flopok
verify:
  MOVE.W  #-11,ddeferr
  MOVEA.L dbuf(PC),A2         ;Pufferadresse fÅr 
                              ;die BAD-List holen
  ADDI.L  #$0200,dbuf         ;Pufferadresse er-
                              ;hîhen
flopverloop:
  MOVE.W  #2,dretry           ;3 Versuche
  MOVE.W  #$84,(A6)           ;FDC-Sektorregister
 anwÑhlen
  MOVE.W  dsect(PC),D7        ;Sektornummer holen
  BSR     wr7fdc              ;und eintragen
flopverloop1:
  MOVE.B  dbuf+3(PC),$FFFF860D.w ;DMA-
  MOVE.B  dbuf+2(PC),$FFFF860B.w ;Adresse
  MOVE.B  dbuf+1(PC),$FFFF8609.w ;setzen
  MOVE.W  #$90,(A6)           ;DMA-
  MOVE.W  #$0190,(A6)         ;FIFO lîschen
  MOVE.W  #$90,(A6)           ;und auf Lesen 
                              ;setzen
  MOVEQ   #1,D7               ;1 Sektor lesen
  BSR     wr7fdc              ;eintragen
  MOVE.W  #$80,(A6)           ;FDC-Kommandore-
                              ;gister anwÑhlen
  MOVE.W  #$80,D7             ;Lese-Befehl
  BSR     wr7fdc              ;Befehl ausfÅhren
  MOVEQ   #$04,D7             ;Time-Out-ZÑhler
                              ;auf
  SWAP    D7                  ;$40000
flopverlp:
  BTST    #5,$FFFFFA01.w      ;fertig?
  BEQ.S   flopverfn
  SUBQ.L  #1,D7               ;Time-Out-ZÑhler 
                              ;vermindern
  BNE.S   flopverlp
  BSR     fdcreset            ;FDC-Reset
  BRA.S   flopvererror
flopverfn:
  MOVE.W  #$90,(A6)           ;DMA-Status-Re-
                              ;gister anwÑhlen
  MOVE.W  (A6),D0             ;DMA-Status holen
  BTST    #0,D0               ;DMA-Error?
  BEQ.S   flopvererror
  MOVE.W  #$80,(A6)           ;FDC-Statusregister
 anwÑhlen
  BSR     rd0fdc              ;Status holen
  BSR     errbits             ;Fehler bearbeiten
  ANDI.B  #$1C,D0             ;Fehlerbits aus-
                              ;maskieren
  BNE.S   flopvererror
flopverns:
  ADDQ.W  #1,dsect            ;Sektornummer er-
                              ;hîhen
  SUBQ.W  #1,dcount           ;Anzahl vermindern
  BNE     flopverloop
  SUBI.L  #$0200,dbuf         ;Pufferadresse ver-
                              ;mindern
  CLR.W   (A2)                ;Kein Verify-Error
  RTS
flopvererror:
  CMPI.W  #1,dretry           ;2. Versuch?
  BNE.S   flopvern2try
  BSR     reseek              ;Reseek
flopvern2try:
  SUBQ.W  #1,dretry           ;VersuchszÑhler 
                              ;vermindern
  BPL     flopverloop1
  MOVE.W  dsect(PC),(A2)+     ;Sektornummer in 
                              ;BAD-List
  BRA.S   flopverns

;************************************************

floplock:
  MOVEM.L D3-D7/A3-A6,dsavreg
  LEA     $FFFF8606.w,A6      ;DMA-Basisregister
  MOVE.W  D0,ddeferr          ;Default-Error
  MOVE.W  D0,derror
  ST      $043E.w             ;Floppyroutine im 
                              ;VBL sperren
  MOVE.L  8(SP),dbuf          ;Puffer
  MOVE.W  16(SP),ddrv         ;Dev-Nummer
  MOVE.W  18(SP),dsect        ;Sektornummer
  MOVE.W  20(SP),dtrack       ;Tracknummer
  MOVE.W  22(SP),dside        ;Seite
  MOVE.W  24(SP),dcount       ;Anzahl der Sek-
                              ;toren
  MOVE.W  #2,dretry           ;3 Versuche bei 
                              ;einem Fehler
  LEA     ddsb(PC),A1         ;Basisadr. der 
                              ;Trackinformationen
  MOVE.W  16(SP),D3           ;Dev-Nummer holen
  ASL.W   #2,D3               ;*4
  ADDA.W  D3,A1               ;Listenpos. be-
                              ;rechnen
  TST.W   (A1)                ;Tracknummer 
                              ;gÅltig?
  BPL.S   tracknrok
  BSR     selectdr            ;Laufwerk anselekt-
                              ;ieren
  CLR.W   (A1)                ;Tracknummer auf 0
  BSR     restore             ;Restore >> Track 0
 suchen
  BEQ.S   tracknrok           ;gefunden?
  MOVEQ   #10,D7              ;Spur 10 suchen
  BSR.S   hseek1              ;Spur suchen
  BNE.S   tracknrnf           ;gefunfen?
  BSR     restore             ;Restore >> Track 0
                              ;suchen
  BEQ.S   tracknrok           ;gefunden?
tracknrnf:
  ST      (A1)                ;Tracknummer un-
                              ;gÅltig
tracknrok:
  RTS

;************************************************

errbits:
  MOVEQ   #-13,D1             ;Write-protected 
                              ;voreinstellen
  BTST    #6,D0               ;Schreibschutz-Bit 
                              ;gesetzt?
  BNE.S   errbitsend
  MOVEQ   #-8,D1              ;Sector-not-found 
                              ;voreinstellen
  BTST    #4,D0               ;Record not found-
                              ;Bit gesetzt?
  BNE.S   errbitsend
  MOVEQ   #-4,D1              ;CRC-Error vorein-
                              ;stellen
  BTST    #3,D0               ;CRC-Bit gesetzt?
  BNE.S   errbitsend
  MOVE.W  ddeferr(PC),D1      ;Default-Error 
                              ;holen
errbitsend:
  MOVE.W  D1,derror           ;Errorcode 
                              ;speichern
  RTS

;************************************************

flopfail:
  MOVEQ   #1,D0               ;media-change auf 
                              ;unsure
  BSR     setdmode            ;Status des Lauf-
                              ;werkes setzen
  MOVE.W  derror(PC),D0       ;Fehlernummer holen
  EXT.L   D0
  BRA.S   flopend             ;rausspringen

;************************************************

flopok:
  MOVEQ   #0,D0               ;kein Fehler aufge-
                              ;treten
flopend:
  MOVE.L  D0,-(SP)            ;Fehlernummer 
                              ;merken
  MOVE.W  #$86,(A6)           ;FDC Datenregister 
                              ;anwÑhlen
  MOVE.W  (A1),D7             ;Tracknummer holen
  BSR     wr7fdc              ;Tracknummer ein-
                              ;tragen
  MOVEQ   #$10,D6             ;Seek-Befehl
  BSR     flopcmds            ;Befehl ausfÅhren
  MOVE.W  ddrv(PC),D0         ;Dev-Nummer holen
  LSL.W   #2,D0               ;*4
  LEA     acctim(PC),A0       ;ACCTIM Basis-
                              ;adresse
  MOVE.L  $04BA.w,0(A0,D0.w)  ;Timer C-ZÑhler 
                              ;eintragen
  MOVE.L  (SP)+,D0            ;Fehlernummer 
                              ;zurÅckholen
  MOVEM.L dsavreg(PC),D3-D7/A3-A6
  CLR.W   $043E.w             ;Floppyroutine im 
                              ;VBL erlauben
  RTS

;************************************************

hseek:
  MOVE.W  dtrack(PC),D7       ;Tracknummer holen
hseek1:
  MOVE.W  #-6,derror          ;Fehler: Seek-Error
  MOVE.W  #$86,(A6)           ;FDC-Datenregister 
                              ;anwÑhlen
  BSR     wr7fdc              ;Tracknummer ein-
                              ;tragen
  MOVE.W  #$10,D6             ;Seek-Befehl
  BRA.S   flopcmds            ;Befehl ausfÅhren

;************************************************

reseek:
  MOVE.W  #-6,derror          ;Fehler:  Seek-
                              ;Error
  BSR.S   restore             ;Track 0 suchen
  BNE.S   reseekok            ;gefunden?
  CLR.W   (A1)                ;Track 0 merken
  MOVE.W  #$82,(A6)           ;FDC-Trackregister 
                              ;anwÑhlen
  MOVEQ   #0,D7               ;Track 0 eintragen
  BSR     wr7fdc              ;Tracknummer ein-
                              ;tragen
  MOVE.W  #$86,(A6)           ;FDC-Datenregister 
                              ;anwÑhlen
  MOVEQ   #5,D7               ;Track 5
  BSR     wr7fdc              ;Tracknummer ein-
                              ;tragen
  MOVE.W  #$10,D6             ;Seek-Befehl
  BSR.S   flopcmds            ;Befehl ausfÅhren
  BNE.S   reseekok
  MOVE.W  #5,(A1)             ;Track 5 merken
go2track:
  MOVE.W  #-6,derror          ;Fehler: Seek-Error
  MOVE.W  #$86,(A6)           ;FDC-Datenregister 
anwÑhlen
  MOVE.W  dtrack(PC),D7       ;Tracknummer holen
  BSR     wr7fdc              ;Tracknummer ein-
                              ;tragen
  MOVE.B  seecver(PC),D6      ;Flag fÅr Verify 
                              ;holen
  ANDI.W  #$01,D6             ;nur Bit 0 zulassen
  ASL.W   #2,D6               ;*4
  ORI.B   #$10,D6             ;Seek-Befehl dazu-
                              ;odern
  BSR.S   flopcmds            ;Befehl ausfÅhren
  BNE.S   reseekok
  MOVE.W  dtrack(PC),(A1)     ;Tracknummer merken
  ANDI.B  #$18,D7             ;Fehlerbits vom 
                              ;Status ausmas-
                              ;kieren
reseekok:
  RTS

;************************************************

restore:
  MOVEQ   #0,D6               ;Restore-Befehl
  BSR.S   flopcmds            ;Befehl ausfÅhren
  BNE.S   restorefail
  BTST    #2,D7               ;Track 0 erreicht 
                              ;>> Z-Flag=1
  EORI    #4,CCR              ;Z-Flag invertieren
  BNE.S   restorefail
  CLR.W   (A1)                ;Track 0 merken
restorefail:
  RTS

;************************************************

flopcmds:
  MOVE.W  2(A1),D0            ;Seek-Rate holen
  ANDI.B  #$03,D0             ;nur die Bits 0 und
                              ;1 zulassen
  OR.B    D0,D6               ;Befehlswort dazu-
                              ;odern
  MOVEQ   #$04,D7             ;Time-Out-Wert auf 
                              ;$40000
  MOVE.W  #$80,(A6)           ;FDC-Statusregister
                              ;anwÑhlen
  BSR     rd0fdc              ;Status holen
  BTST    #7,D0               ;Motor an?
  BNE.S   flopcmdsmo
  MOVEQ   #$06,D7             ;Time-Out-Wert auf 
                              ;$60000
flopcmdsmo:
  SWAP    D7
  BSR     wr6fdc              ;Befehl ausfÅhren
flopcmdstl:
  SUBQ.L  #1,D7               ;Time-Out-Wert ver-
                              ;mindern
  BEQ.S   flopcmdste
  BTST    #5,$FFFFFA01.w      ;fertig?
  BNE.S   flopcmdstl
  BSR     rd7fdc              ;Status lesen
  MOVEQ   #0,D6               ;alles ok
  RTS
flopcmdste:
  BSR.S   fdcreset            ;FDC-Reset
  MOVEQ   #1,D6               ;Fehler ist aufge-
                              ;treten
  RTS

;************************************************

fdcreset:
  MOVE.W  #$80,(A6)           ;FDC-Befehlsre-
                              ;gister anwÑhlen
  MOVE.W  #$D0,D7             ;Force-IRQ
  BSR     wr7fdc              ;Befehl eintragen
  MOVEQ   #15,D7              ;Warte-
fdcresloop:
  DBRA    D7,fdcresloop       ;Schleife
  BSR     rd7fdc              ;Status lesen
  RTS

;************************************************

selectdr:
  MOVE.W  ddrv(PC),D0         ;Dev-Nummer holen
  MOVE.W  dside(PC),D1        ;Seite holen
  LEA     devclock(PC),A5     ;Basisadresse der 
                              ;Dev-Adressen
  MOVE.B  0(A5,D0.w),D0       ;Dev-Adresse holen
  EXT.W   D0
  MOVE.W  D0,driveint         ;angerspr. Lauf-
                              ;werksadresse 
                              ;speichern
  BSR.S   portselect          ;externes Laufwerk 
                              ;selektieren
  MOVE.W  #$82,(A6)           ;FDC-Trackregister 
                              ;anwÑhlen
  MOVE.W  (A1),D7             ;Tracknummer holen
  BSR     wr7fdc              ;und eintragen
selectdr1:
  MOVE.W  #$84,(A6)           ;FDC-Sektorregister
                              ;anwÑhlen
  MOVE.W  dsect(PC),D7        ;Sektornummer holen
  BSR     wr7fdc              ;und eintragen
  MOVE.B  dbuf+3(PC),$FFFF860D.w ;DMA-
  MOVE.B  dbuf+2(PC),$FFFF860B.w ;Adresse
  MOVE.B  dbuf+1(PC),$FFFF8609.w ;setzen
  RTS

;************************************************

portselect:
  MOVEM.W D0-D2/D7,-(SP)
  PEA     (A4)
  LEA     $FFFF8800.w,A5      ;PSG-Basisadresse
  MOVE    SR,-(SP)
  MOVE    #$2700,SR           ;Alle IRQs sperren
  MOVE.B  #$0E,(A5)           ;Port A selektieren
  MOVE.B  (A5),D7             ;Inhalt holen
  ANDI.B  #$F8,D7             ;untere 3 Bits aus-
                              ;maskieren
  MOVE.W  #$02,D2             ;Laufwerk B
  OR.B    D7,D2               ;restliche Bits 
                              ;dazuodern
  ANDI.W  #$01,D1             ;nur Bit 0 zulassen
  EORI.W  #$01,D1             ;Seite invertieren
  OR.B    D1,D2               ;Seite dazuodern
  MOVE.B  D2,2(A5)            ;in Port A ein-
                              ;tragen
                              ;Hardware-Register
                              ;îffnen
  EORI.W  #$04,D2             ;Laufwerk B auf 
                              ;deselektieren
  SUB.W   D1,D1               ;d1 lîschen
  LEA     romadress(PC),A4    ;Basisadr. der ROM-
                              ;Port-Adressen
  LEA     $FA0000,A5          ;Basisadresse der 
                              ;Hardware
  MOVE.B  0(A4,D0.w),D1       ;1. ROM-Portadresse
                              ;holen
  MOVE.W  0(A5,D1.w),D7       ;Hardware-Register 
                              ;einstellen 
                              ;(obere 4 Bit)
  MOVE.B  1(A4,D0.w),D1       ;2. ROM-Portadresse
                              ;holen
  MOVE.W  0(A5,D1.w),D7       ;Hardware-Register 
                              ;einstellen 
                              ;(untere 4 Bit)
  MOVE.B  D2,$FFFF8802.w      ;Hardware-Register 
                              ;schlieûen
                              ;Laufwerk ist nun
                              ;selektiert
  MOVE    (SP)+,SR
  MOVEA.L (SP)+,A4
  MOVEM.W (SP)+,D0-D2/D7
  RTS

;************************************************

portdeselect:
  CMPI.W  #16,driveint        ;war kein externes 
                              ;Laufwerk an?
  BEQ.S   portdeselectend
portinstall:
  MOVEM.W D0-D2/D7,-(SP)
  PEA     (A5)
  MOVE    SR,-(SP)
  MOVE    #$2700,SR           ;Alle IRQs sperren
  LEA     $FFFF8800.w,A5      ;PSG-Basisadresse
  MOVE.B  #$0E,(A5)           ;Port A selektieren
  MOVE.B  (A5),D7             ;Inhalt holen
  ANDI.B  #$F8,D7             ;untere 3 Bits aus-
                              ;maskieren
  MOVE.W  #$02,D2             ;Laufwerk B
  OR.B    D7,D2               ;restliche Bits 
                              ;dazuodern
  MOVE.B  D2,2(A5)            ;in Port A ein-
                              ;tragen
                              ;Harware-Register
                              ;îffnen
  EORI.W  #$04,D2             ;Laufwerk B auf 
                              ;deselektieren
  MOVE.W  $FA001E,D7          ;Hardware-Register 
                              ;einstellen
                              ;(obere 4 Bit)
  MOVE.W  $FA001E,D7          ;Hardware-Register 
                              ;einstellen
                              ;(untere 4 Bit)
  MOVE.B  D2,$FFFF8802.w      ;Hardware-Register 
                              ;schlieûen
                              ;alle Laufwerke 
                              ;sind nun 
                              ;deselektiert
  MOVE.W  #16,driveint        ;externe Laufwerke 
                              ;sind nun 
                              ;deselektiert
  MOVE    (SP)+,SR
  MOVEA.L (SP)+,A5
  MOVEM.W (SP)+,D0-D2/D7
portdeselectend:
  RTS

;************************************************

wr6fdc:
  BSR.S   delay               ;Zeitschleife
  MOVE.W  D6,$FFFF8604.w      ;d6 ins FDC-Re-
                              ;gister
  BRA.S   delay               ;Zeitschleife
wr7fdc:
  BSR.S   delay               ;Zeitschleige
  MOVE.W  D7,$FFFF8604.w      ;d7 ins FDC-Re-
                              ;gister
  BRA.S   delay               ;Zeitschleife
rd7fdc:
  BSR.S   delay               ;Zeitschleife
  MOVE.W  $FFFF8604.w,D7      ;FDC-Registerinhalt
                              ;nach d7
  BRA.S   delay               ;Zeitschleife
rd0fdc:
  BSR.S   delay               ;Zeitschleife
  MOVE.W  $FFFF8604.w,D0      ;FDC-Registerinhalt
                              ;nach d0
delay:
  MOVE    SR,-(SP)            ;Status retten
  MOVE.W  D7,-(SP)            ;d7 retten
  MOVE.W  #8,D7               ;ca. 16 us warten
delaylp:
  DBRA    D7,delaylp
  MOVE.W  (SP)+,D7            ;d7 zurÅck
  MOVE    (SP)+,SR            ;Status zurÅck-
                              ;werfen
  RTS

;************************************************

setdmode:
  LEA     dsb(PC),A0          ;DSB-Basisadresse
  MOVE.B  D0,-(SP)            ;Disk-Status retten
  MOVE.W  ddrv(PC),D0         ;Dev-Nummer holen
  MOVE.B  (SP)+,0(A0,D0.w)    ;Disk-Status  
                              ;speichern
  RTS

;************************************************

  DC.B "XBRA"                 ;XBRA-Kennung
  DC.B "MC10"                 ;ID-Name
  DC.L 0                      ;alter VBL-Vektor

flopvbl:
  MOVEM.L D0-D2/D7/A5,-(SP)
  TST.W   $043E.w             ;Floppies aktiv?
  BNE.S   flopvblend
  MOVE.B  #$0E,$FFFF8800.w    ;Port A selektieren
  MOVE.B  $FFFF8800.w,D7      ;Portwert holen
  MOVE.W  #$80,$FFFF8606.w    ;FDC-Statusregister
                              ;anwÑhlen
  MOVE.W  $0468.w,D2          ;VBL-ZÑhler holen
  BTST    #$00,D2             ;2. VBL-IRQ?
  BEQ.S   noprotest
  ASR.W   #1,D2               ;/2
  ANDI.W  #$07,D2             ;mod 8
  LEA     devclock(PC),A5     ;Basisadresse der
                              ;Dev-Adressen
  MOVE.B  0(A5,D2.w),D0       ;Dev-Adresse holen
  EXT.W   D0
  BSR     portselect          ;Laufwerk
                              ;selektieren
  MOVE.W  $FFFF8604.w,D1      ;Status holen
  LEA     wpstatus(PC),A5     ;WPSTATUS-Adresse
  BTST    #6,D1               ;Write-protect-Bit 
                              ;testen
  SNE     0(A5,D2.w)          ;Flag setzen
noprotest:
  MOVEM.L wpstatus(PC),D0-D1  ;alle WPSTATUS 
                              ;holen
  OR.L    D0,cdev             ;Wert in
  OR.L    D1,cdev+4           ;CDEV odern
  MOVE.W  D7,D0               ;Portwert nach d0
  ANDI.W  #$F8,D0             ;untere 3 Bits aus-
                              ;maskieren
  ORI.W   #$05,D0             ;Laufwerk A selekt-
                              ;ieren
  MOVE.B  D0,$FFFF8802.w      ;in Port A schrei-
                              ;ben
  MOVE.W  $FFFF8604.w,D0      ;Status holen
  BTST    #7,D0               ;Motor noch an?
  BNE.S   nodesel
  BSR     portdeselect        ;externe Laufwerke 
                              ;deselektieren
nodesel:
  MOVE.W  driveint(PC),D0     ;Laufwerksadresse 
                              ;holen
  BSR     portselect          ;externes Laufwerk 
                              ;selektieren
  MOVE.B  D7,$FFFF8802.w      ;alter Portwert 
                              ;zurÅck
flopvblend:
  MOVEM.L (SP)+,D0-D2/D7/A5
vblold:
  JMP     $12345678


;************************************************
;************************************************

  DATA

title:
  DC.B 27,"E"
  DC.B "*********************************",13,10
  DC.B "* M U L T I C O N T R O L   1 0 *",13,10
  DC.B "*********************************",13,10
  DC.B "*  Progam by Christian Cartus   *",13,10
  DC.B "*  Hardware by Christoph Bîhme  *",13,10
  DC.B "*********************************",13,10
  DC.B "*  TOS-independent Version 1.3  *",13,10
  DC.B "*     Hardware Version 1.2      *",13,10
  DC.B "*********************************",13,10
  DC.B "*         (c) 1989-1990         *",13,10
  DC.B "*********************************",13,10
  DC.B 13,10
  DC.B "Press 'I' to install drives!!"
  DC.B 0
indrives:
  DC.B 27,"Y",32+12,32,"         testing drive "
drcount1:DC.B "1 ",27,"J",0

nodractive:
  DC.B 13,10,13,10
  DC.B "        No active drives!",13,10
  DC.B "      Installation aborted!",0

drferror:
  DC.B 13,10,13,10
  DC.B "       Illegal FI-Format!!",13,10
  DC.B "      Installation aborted!",0

dractive:
  DC.B 13,10,13,10,"        "
drcount2:
  DC.B "0 active drives!!",13,10
  DC.B "     Installation completed!",0

allrinst:
  DC.B 27,"E"
  DC.B "Multicontrol 10 allready installed!",0

malerror:
  DC.B 27,"E"
  DC.B "Malloc-Error - Not enough memory!",0

filerror:
  DC.B 27,"E"
  DC.B "FI-File-Error!",0

finame:
  DC.B "MC10FI.DOC",0


  EVEN

;************************************************
;************************************************

romadress:
          DC.B $1C,$1E    ;1. externes Laufwerk
          DC.B $1E,$1C    ;2. externes Laufwerk
          DC.B $1E,$1A    ;3. externes Laufwerk
          DC.B $1A,$1E    ;4. externes Laufwerk
          DC.B $16,$1E    ;5. Externes Laufwerk
          DC.B $1E,$16    ;6. externes Laufwerk
          DC.B $0E,$1E    ;7. externes Laufwerk
          DC.B $1E,$0E    ;8. externes Laufwerk
          DC.B $1E,$1E    ;alle externe Laufwerke
                          ;aus



devbuf:   DC.B "IJKLMNOP" ;8 vordefinierte Dev-
                          ;EintrÑge
seecver:  DC.B "1"        ;Flag fÅr Seek mit 
                          ;Verify


  EVEN
  BSS

;************************************************
;Benîtigte Variablen fÅr die Verwaltungsroutinen*
;************************************************

devbase:  DS.B 8          ;8 Dev-Nummern-EintrÑge
aktdev:   DS.W 1          ;aktuelle Dev-Nummer
bpbbase:  DS.B 32*8       ;Platz fÅr die BPB-
                          ;EintrÑge
cdev:     DS.B 8          ;CDEV
wpstatus: DS.B 8          ;WPSTATUS
dsb:      DS.B 8          ;DSB
acctim:   DS.L 8          ;ACCTIM

;************************************************
;Benîtigte Variablen fÅr die Systemroutinen     *
;************************************************

driveint: DS.W 1          ;aktuelle Laufwerks-
                          ;adresse
devclock: DS.B 8          ;Platz fÅr die Lauf-
                          ;werksadressen
dsavreg:  DS.L 9          ;Platz fÅr 9 Register
ddeferr:  DS.W 1          ;Default-Error
derror:   DS.W 1          ;Error
dbuf:     DS.L 1          ;Puffer
ddrv:     DS.W 1          ;Dev-Nummer
dsect:    DS.W 1          ;Sektornummer
dtrack:   DS.W 1          ;Tracknummer
dside:    DS.W 1          ;Seite
dcount:   DS.W 1          ;Anzahl der Sektoren
dretry:   DS.W 1          ;Anzahl der Versuche
ddsb:     DS.L 8          ;akt. Trackpos. und
                          ;Steprate

  END


