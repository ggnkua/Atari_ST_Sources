 ;**********************************************************************
 ;  68000er Date- and Timesetter  for ATARI ST    Version 0.21  S.Hensel
 ;
 ; Dieses Programm kann wahlweise im AUTO-Ordner oder beim ROM-TOS im
 ; Bootsektor Ihrer Boot-Diskette abgelegt werden, wo es nach jedem
 ; Reset aktiviert wird und die Zeit aus dem Tastaturprozessor holt.
 ; Wurde seit dem Einschalten des Rechners die Zeit noch nicht gesetzt,
 ; so steht die Keyboard-Uhr auf 00:00 Uhr, und der Benutzer wird zur
 ; Eingabe des aktuellen Datums und der Uhrzeit aufgefordert, welche
 ; dann im Tastaturprozessor fÅr alle nachfolgenden Resets abgelegt wird.
 ; Die vom Tastaturprozessor vîllig unabhÑngige Gemdos-Uhr kann nun vom
 ; Date- and Timesetter nach jedem weiteren Reset richtig eingestellt
 ; werden, ohne weitere AktivitÑten des Benutzers zu erfordern; es
 ; sollte lediglich eine Bootdisk mit dem Date- and Timesetter in
 ; Laufwerk A: eingelegt sein. Wird kurz nach dem Reset die ALTERNATE-
 ; TASTE gedrÅckt gehalten, so fÅhrt dieses Programm einen Ramdisk-
 ; zerstîrenden Kaltstart aus; die RECHTE SHIFT-TASTE erlaubt die
 ; Neueingabe von Datum und Uhrzeit.
 ;**********************************************************************

gemdos    =    1
bios      =    13
xbios     =    14
Cconws    =    $9   ; gemdos
Cconrs    =    $a   ; gemdos
Tsetdate  =    $2b  ; gemdos
Tsettime  =    $2d  ; gemdos
Pterm     =    $4C  ; gemdos
Bconout   =    3    ; bios
Kbshift   =    11   ; bios
Settime   =    22   ; xbios
Gettime   =    23   ; xbios
Dosound   =    32   ; xbios
Supexec   =    38   ; xbios

buffersize =   10   ; Anzahl der Eingabezeichen fÅr Cconrs (Buffer=10+2)
 ;----------------------------------------------------------------------
 ; Die auskommentierten Zeilen sind nur fÅr die Version im Bootsektor:
 ;branch:   bra.s   anfang                 short Branch auf Bootprogramm
 ;
 ; Im Folgenden stehen die $ff's als Platzhalter fÅr die Formatangaben
 ; im jeweiligen Bootsektor, welche nicht Åberschrieben werden sollten.
 ; Formatspezifikationen im INTEL-Format: erst Low-Byte, dann High-Byte:
 ;
 ;filler    dc.b    $ff,$ff,$ff,$ff,$ff,$ff   z.B.'Loader' oder '3.3IBM'
 ;serial    dc.b    $ff,$ff,$ff  24-Bit Seriennummer der jeweiligen Disk
 ;recsiz    dc.b    $ff,$ff         Bytes per Sector, z.B. 512 = $00,$02
 ;clsiz     dc.b    $ff                      Sectors per Cluster, z.B. 2
 ;reserv    dc.b    $ff,$ff    Anz.d.reservierten Sektoren am Diskanfang
 ;anzfat    dc.b    $ff          Anzahl der File Allocation Tables (FAT)
 ;n_dirs    dc.b    $ff,$ff     max.Anz.d.Directory-EintrÑge im Root-Dir
 ;nsects    dc.b    $ff,$ff      Gesamtzahl der Sektoren dieser Diskette
 ;mediad    dc.b    $ff          Media-Descriptor-Byte (bei Gemdos egal)
 ;fsiz      dc.b    $ff,$ff                  Anzahl der Sektoren pro FAT
 ;scptrk    dc.b    $ff,$ff                Anzahl der Sektoren pro Track
 ;nsides    dc.b    $ff,$ff              Anzahl der OberflÑchen der Disk
 ;nhidde    dc.b    $ff,$ff      Anz.d.versteckten Sektoren auf der Disk

anfang:                     ; hier Programmstart...
  pea     enterdate(pc)     ; Rufe enterdate im Supervisormodus auf...
  move.w  #Supexec,-(sp)
  trap    #xbios
  addq.l  #6,sp

 ;rts                         Der Bootsektor wird mit Return verlassen.
  clr.w   -(sp)             ; Nur fÅr die Version im AUTO-Ordner erfolgt
  move.w  #Pterm,-(sp)      ;           ein normaler Programmabschluû...
  trap    #gemdos           ; "This Is The Point Of No Return..."
 ;----------------------------------------------------------------------
enterdate:                  ; wird im Supervisormodus ausgefÅhrt
  clr.b   $ffff820a         ; schalte auf 60 Hertz (Bild wird ruhiger!)
  bclr    #0,$484           ; Tastaturklick aus (aaaaaaaahhhh.....)

  pea     hellomsg(pc)      ; erst mal "Hallo - mein Name ist Hase..."
  move.w  #Cconws,-(sp)     ;                                  sagen
  trap    #gemdos
  addq.l  #6,sp

  move    #Gettime,-(sp)    ; hole Zeit und Datum von Tastaturprozessor
  trap    #xbios
  addq.l  #2,sp
  move.l  d0,d4             ; Date & Time merken in d4 ...
  move.l  d0,d7             ;                   ... und d7

  move.w  #-1,-(sp)         ; hole Shift-Status der Tastatur
  move.w  #Kbshift,-(sp)
  trap    #bios
  addq.l  #4,sp
  btst    #3,d0             ; (Bit 3)  ALTERNATE-Taste...
  bne     kaltstart         ;             gedrÅckt --> KALTSTART
  btst    #0,d0             ; (Bit 0)  RECHTE SHIFT-Taste...
  bne.s   tippdatum         ;             gedrÅckt --> DATUM EINGEBEN

  tst.w   d4                ; Keyboard-Clock inaktiv ?   00h 00' 00"
  bne.s   raus              ; nein, Uhr lÑuft bereits: Eingabe unnîtig

tippdatum:                  ; UHR STEHT: Date & Time EINGEBEN LASSEN
  pea     bello(pc)         ; User-Aktion verlangt:  Gib Laut, damit
  move.w  #Dosound,-(sp)    ;     man die Eingabe nicht verschlÑft...
  trap    #xbios            ; man hîrt nur hochfrequente Interferenzen
  addq.l  #6,sp             ; von einzeln nicht mehr hîrbaren Frequenzen

  pea     datemsg(pc)       ; JJMMTTSSMM anzeigen, zur Eingabe von
  move.w  #Cconws,-(sp)     ; Datum und Uhrzeit auffordern und
  trap    #gemdos           ; den Cursor einschalten.
  addq.l  #6,sp

  lea     buffer(pc),a4     ; Vorbereitungen fÅr Cconrs (read string)
  move.b  #buffersize,(a4)  ; buffersize ist maximale LÑnge der Eingabe
  move.l  a4,-(sp)          ; der Buffer selbst ist 2 Bytes lÑnger
  move.w  #Cconrs,-(sp)     ; Gib dem User Mîglichkeit zur Datumseingabe
  trap    #gemdos
  addq.l  #6,sp

  pea     cursor_aus(pc)    ; Cursor wieder ausschalten und CR/LF
  move.w  #Cconws,-(sp)       
  trap    #gemdos
  addq.l  #6,sp

  addq.l  #1,a4             ; a4 zeigt nun auf zurÅckgelieferte LÑnge
  cmpi.b  #10,(a4)+         ; LÑnge der Eingabe muû genau 10 sein
  bne.s   bellraus          ; isses nich, so schlag ich Krach und tu nix

  bsr.s   fissel_datime     ; codiert date & time bitweise nach d4
  tst.l   d4                ; falls d4 == 0 ist fehler aufgetreten
  beq.s   bellraus          ; Fehler! Abbruch und Alarmton

  move.l  d4,-(sp)          ; eingegebenes neues Datum auf Stack
  move.w  #Settime,-(sp)    ; stelle Uhr im Tastaturprozessor
  trap    #xbios            ; fÅr spÑtere Resets
  addq.l  #6,sp

raus:                       ; Setze GEMDOS-UHR mit DateTime aus d4
  move.l  d4,-(sp)          ; Push Date & Time 32bit
  move.w  #Tsetdate,-(sp)   ; benutze Date 16bit
  trap    #gemdos
  addq.l  #4,sp             ; 16bit Time bleibt auf Stack
  move.w  #Tsettime,-(sp)   ; benutze Time
  trap    #gemdos
  addq.l  #4,sp             ; GEMDOS-UHR IST JETZT GESETZT
ganzraus:
  rts                       ; bye-bye
 ;--------------------------
bellraus:                   ; Mit Eingabestring war nichts anzufangen...
  pea     brumm(pc)         ; brummige Verabschiedung wg. Fehleingabe
  move.w  #Dosound,-(sp)
  trap    #xbios
  addq.l  #6,sp
  tst.w   d7                ; hat wenigstens der Tastaturprozessor Zeit?
  beq.s   ganzraus          ; nein...
  move.l  d7,d4             ; doch: Åbertrage Zeit in GEMDOS-Uhr
  bra.s   raus              ;
 ;--------------------------------------------------------------------
kaltstart:                  ; Zerstîre residente RAM-Disks etc.
  clr.l   $420              ; memvalid  lîschen (Speicher ungÅltig)
  clr.l   $426              ; res_valid    "    (Resetvektor ungÅltig)
  move.l  4,a0              ; ROM-Reset-Adresse holen
  jmp     (a0)              ; jump to ROM-Reset-Vector   (Kaltstart)
 ;--------------------------------------------------------------------
fissel_datime:              ; rechne 10-char-string um in 32bit Datum
  bsr.s   calc_pair         ; berechne Jahr
  subi.b  #80,d0
  bcs.s   fissel_error      ; Jahr nicht in 1980..1999
  move.b  d0,d4
  lsl.l   #4,d4             ; schaffe Platz fÅr 4 bit Monat
  bsr.s   calc_pair         ; berechne Monat
  cmpi.b  #12,d0
  bhi.s   fissel_error      ; Monat > 12
  or.b    d0,d4
  lsl.l   #5,d4             ; schaffe Platz fÅr 5 bit Tag
  bsr.s   calc_pair         ; berechne Tag
  cmpi.b  #31,d0
  bhi.s   fissel_error      ; Tag > 31
  or.b    d0,d4
  lsl.l   #5,d4             ; schaffe Platz fÅr 5 bit Stunde
  bsr.s   calc_pair         ; berechne Stunde
  cmpi.b  #23,d0
  bhi.s   fissel_error      ; Stunde > 23
  or.b    d0,d4
  lsl.l   #6,d4             ; schaffe Platz fÅr 6 bit Minute
  bsr.s   calc_pair         ; berechne Minute
  cmpi.b  #59,d0
  bhi.s   fissel_error      ; Minute > 59
  or.b    d0,d4
  lsl.l   #5,d4             ; setze Sekunden auf 0
  rts
 ;--------------------------
fissel_error:               ; Fehlerfall:  liefere 0 in d4 zurÅck
  clr.l   d4
  rts
 ;---------------------------------------------------------------------
calc_pair:                  ; berechne aus 2 Zeichen Dezimalzahl -> d0.b
  bsr.s   ziffer
  tst.w   d0
  bmi.s   calc_error        ; illegales 1. Zeichen: keine Ziffer
  moveq   #10,d1
  mulu    d0,d1             ; d1  =  10 * ziffer1
  bsr.s   ziffer
  tst.w   d0
  bmi.s   calc_error        ; illegales 2. Zeichen: keine Ziffer
  add.w   d1,d0             ; d0  =  d1 + d0     (10*ziffer1 + ziffer2)
  rts

calc_error:                 ; wird auch von ziffer benutzt (!)
  moveq   #-1,d0            ; setze Fehler-Flag:  d0.b > 59  illegal
  rts
 ;---------------------------------------------------------------------
ziffer:                     ; wandelt Ascii-Ziffer um in dezimal 0..9
  clr.w   d0
  move.b  (a4)+,d0          ; A4 zeigt nun auf das nÑchste Zeichen
  subi.w  #$30,d0           ; teste, ob d0.b in '0'..'9' enthalten ist
  bcs.s   calc_error        ; d0 < '0'
  cmpi.w  #9,d0
  bhi.s   calc_error        ; d0 > ( '9' - '0' )
  rts
 ;---------------------------------------------------------------------

hellomsg:                   ; genau 40 Zeichen wg. Low-Res Farbmodus:
  dc.b    $d,"+ 68000er Datum Kaltstart Noklick 60Hz +"
cursor_aus:
  dc.b    27,'f'
crlf:
  dc.b    $d,$a,0
datemsg:                    ; hier auch genau 40 Zeichen von + bis +
  dc.b    "+ JJMMTTSSMM  (Jahr Monat Tag Std Min) +",$d,$a,"= "
cursor_ein:
  dc.b    27,'e',0
brumm:    ;  Dosound - Daten zur Verabschiedung bei Eingabefehler
  dc.b    0,$ff,1,$0d,2,$ff,3,$0e,4,$ff,5,$0f,7,$f8
  dc.b    8,$10,9,$10,10,$10,11,$ff,12,$ff,13,$09
  dc.b    $ff,$00
buffer:   ;  12 Bytes Eingabepuffer (Eingabe Åberschreibt Bello-Sound)
bello:    ;  Dosound - Daten zur BegrÅûung
  dc.b    0,$7,1,$0,2,$8,3,$0,4,$9,5,$0,7,$f8
  dc.b    8,$10,9,$10,10,$10,11,$ff,12,$ff,13,$09
  dc.b    $ff,$00

  end

