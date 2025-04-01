*************************************************
* Link-Virus-Finder V1.5                        *
* und Fast-File-Finder V1.5                     *
* (c)1989 by Maxon Computer                     *
* von ‰-soft, Markus Fritze                     *
* entwickelt mit Turbo-Ass V1.4                 *
*************************************************
;Schalter:
virus EQU 0
;0:Fast-File-Finder, <>0:Link-Virus-Finder

  IF virus
  OUTPUT 'LVF.TTP' ;Link-Virus-Finder
  ELSE
  OUTPUT 'FFF.TTP' ;Fast-File-Finder
  ENDC
  OPT F+,W+     ;Warnungen an,Fast-Load an

max_prgs EQU 1000 ;max.1000 Programme im LVF
max_sektorsize EQU 8192 ;max.Sektorgrîûe

;A6-Register zeigt auf das BSS-Segment
  BASE A6,BSS

;Struktur des BIOS-Parameter-Blocks definieren
  PART 'BPB-Struktur'
  RSRESET
recsiz:RS.W 1   ;Bytes pro Sektor
clsiz: RS.W 1   ;Sektoren pro Cluster
clsizb:RS.W 1   ;Bytes pro Cluster
rdlen: RS.W 1   ;LÑnge des Root-Directories
fsiz:  RS.W 1   ;LÑnge einer FAT
fatrec:RS.W 1   ;Startsektor der 2.FAT
datrec:RS.W 1   ;Starts. des 1.freien Sektors
numcl: RS.W 1   ;Gesamtanzahl der Cluster
bflags:RS.W 1   ;Bit0=1 bei 16-bit-FAT
  ENDPART

_drvbits EQU $04C2 ;Die Bitmaske der Laufwerke

  PART 'main'
anfang:
  movea.l 4(SP),A0      ;Ptr auf die Basepage
  movea.l $18(A0),A6    ;Ptr auf den BSS-Bereich
  lea     own_stack(PC),SP

  pea     init_text(PC)
  bsr     print_line    ;Startup-Meldung

  IF virus
  lea     data_buff(A6),A0
  move.l  A0,data_base(A6)

  clr.w   -(SP)
  pea     fname(A6)
  move.w  #$3D,-(SP)
  trap    #1            ;Fopen()
  addq.l  #8,SP
  move.l  D0,D7
  bmi.s   anfang1 ;Fehler
  move.l  data_base(A6),-(SP)
  move.l  #max_prgs*32,-(SP)
  move.w  D7,-(SP)
  move.w  #$3F,-(SP)
  trap    #1       ;Fread() - Datenblock einlesen
  lea     12(SP),SP
  move.w  D7,-(SP)
  move.w  #$3E,-(SP)
  trap    #1            ;Fclose()
  addq.l  #4,SP
anfang1:
  ENDC

  bsr     convert       ;Commandline auswerten

  clr.l   -(SP)
  move.w  #$20,-(SP)
  trap    #1            ;Supervisormode an
  move.l  D0,2(SP)
  move.l  _drvbits.w,D7 ;Variable auslesen
  trap    #1            ;Usermode wieder an
  addq.l  #6,SP
  move.w  D7,D1         ;_drvbits nach D1

  IF !virus
  lea     search_mask(A6),A1 ;Suchmaske
  lea     search_chars(A6),A2 ;Suchdaten
  ENDC
  moveq   #$18,D7 ;Ordner & Vol-Label ignorieren
  moveq   #0,D5   ;Bytes der gefundenen Dateien
  moveq   #0,D4   ;Anzahl der gefundenen Dateien
  moveq   #0,D3   ;Anzahl der Ordner

  moveq   #2,D2   ;mit Drive C geht es los
  tst.w   D6      ;keine Laufwerksangabe?
  bmi.s   loop    ;Genau! =>
  move.w  D6,D2   ;das spezielle Laufwerk testen
loop:
  btst    D2,D1   ;Laufwerk vorhanden?
  beq.s   loop1   ;Nein! =>
  movea.l #heap,A0
  adda.l  A6,A0
  move.l  A0,heap_pnt(A6) ;Heap zurÅcksetzen
  move.w  D2,D0
  bsr     set_drive ;Laufwerk anmelden, FAT lesen
  movem.l D1-D3,-(SP)
  move.l  D0,D1
  pea     drive_text(PC)
  bsr     print_line
  moveq   #'A',D0
  add.b   D2,D0
  bsr     chrout  ;aktuelles Drive ausgeben
  pea     drive_text2(PC)
  bsr     print_line
  moveq   #7,D2   ;max.8 Stellen ausgeben
  bsr     dez_out ;freien Speicher ausgeben
  pea     drive_text3(PC)
  bsr     print_line    ;"Bytes frei"
  movem.l (SP)+,D1-D3

  bsr     read_dir      ;Kompletten Baum einlesen

  lea     pfad(A6),A3
  move.b  #'A',(A3)
  add.b   D2,(A3)+   ;Laufwerkskennung
  move.b  #':',(A3)+
  move.b  #'\',(A3)+ ;Root-Pfad festlegen

  move.w  D1,-(SP)
  bsr     hunt_dir  ;Baum durchsuchen
  move.w  (SP)+,D1
loop1:
  tst.w   D6      ;Laufwerksangabe?
  bpl.s   loop2   ;Ja! => Fertig
  addq.w  #1,D2
  cmp.w   #32,D2  ;bis Bit 32 wird hochgezÑhlt
  bne.s   loop    ;noch nicht alle? Stimmt! =>
loop2:
  IF virus
  moveq   #0,D1
  move.w  virus_count(A6),D1 ;Viren gefunden?
  beq.s   loop3   ;Nein! =>
  moveq   #4,D2   ;max.5 Stellen ausgeben
  bsr     dez_out
  pea     viren_text(A6)
  bsr     print_line ;verseuchte Dateien gefunden
loop3:
  ENDC
  moveq   #0,D1
  move.w  D4,D1   ;Anzahl der 'Hits'
  moveq   #5,D2   ;max.6 Stellen ausgeben
  bsr     dez_out
  pea     files_text(A6)
  bsr     print_line
  move.l  D5,D1   ;LÑnge aller Dateien zusammen
  moveq   #7,D2   ;max.8 Stellen ausgeben
  bsr     dez_out
  pea     files_text2(A6)
  bsr     print_line

  moveq   #0,D1
  move.w  D3,D1   ;Anzahl der Ordner
  moveq   #4,D2   ;max.5 Stellen ausgeben
  bsr     dez_out
  pea     folders_text(A6)
  bsr.s   print_line

  move.w  #7,-(SP)
  trap    #1      ;auf Taste warten
  addq.l  #2,SP
  IF virus
  bclr    #5,D0
  cmp.b   #'J',D0 ;Schreiben?
  bne.s   _exit   ;Nein! =>

  movea.l data_base(A6),A4
  movea.l A4,A3   ;Datenbasis merken
code:
  tst.l   (A4)   ;Ende der Liste?
  beq.s   code2   ;Ja! =>
  lea     24(A4),A4
  bra.s   code
code2:
  suba.l  A3,A4 ;LÑnge aller Daten

  clr.w   -(SP)
  pea     fname(A6)
  move.w  #$3C,-(SP)
  trap    #1      ;Fcreate()
  addq.l  #8,SP
  move.l  D0,D7
  bmi.s   _exit   ;Fehler
  move.l  A3,-(SP) ;Basisadresse der Daten
  move.l  A4,-(SP) ;LÑnge
  move.w  D7,-(SP)
  move.w  #$40,-(SP)
  trap    #1       ;Fwrite()
  lea     12(SP),SP
  move.w  D7,-(SP)
  move.w  #$3E,-(SP)
  trap    #1       ;Fclose()
  addq.l  #4,SP
  ENDC

_exit:
  pea     exit_text(A6)
  bsr.s   print_line ;Cursor wieder aus, etc.

  clr.w   -(SP)
  trap    #1       ;Programmende
  ENDPART

*************************************************
* String auf dem Stack ausgeben                 *
*************************************************
  PART 'print_line'
print_line:
  movem.l D0-D2/A0-A2,-(SP)
  move.l  4+6*4(SP),-(SP)
  move.w  #$09,-(SP)
  trap    #1            ;Cconws()
  addq.l  #6,SP
  movem.l (SP)+,D0-D2/A0-A2
  move.l  (SP)+,(SP)    ;Stack korrigieren
  rts
  ENDPART
*************************************************
* Zeichen in D0 ausgeben                        *
*************************************************
  PART 'chrout'
chrout:
  movem.l D0-D2/A0-A2,-(SP)
  move.w  D0,-(SP)
  move.w  #$02,-(SP)
  trap    #1            ;Cconout()
  addq.l  #4,SP
  movem.l (SP)+,D0-D2/A0-A2
  rts
  ENDPART
**********************************************
* positive Dezimal-Zahl in D1                *
* ohne FÅhrungsnullen ausgeben               *
* max.Anzahl der Stellen minus 1 in D2       *
**********************************************
  PART 'dez_out'
dez_out:
  movem.l D0-D4/A1,-(SP)
  lea     dez_tab(PC),A1 ;Zeiger auf die Tabelle
  move.w  D2,D0    ;Anzahl der Stellen-1
  add.w   D0,D0    ;mal 4
  add.w   D0,D0    ;(schneller als LSL.W #2,D0!)
  lea     4(A1,D0.w),A1 ;Ptr auf die Stellenzahl
  moveq   #0,D4    ;fÅhrende Nullen ignorieren
dez_out1:
  move.l  -(A1),D3 ;Tabellenwert
  moveq   #-'0',D0 ;wird zu -'1',-'2',-'3',...
dez_out2:
  sub.l   D3,D1    ;SUB bis zum Unterlauf
  dbcs    D0,dez_out2 ;Unterlauf? Nein! =>
  neg.w   D0       ;z.B. -'1' => '1'
  cmp.b   #'0',D0  ;eine Null?
  beq.s   dez_out4 ;Ja! =>
  moveq   #-1,D4   ;ab nun werden auch Nullen
dez_out3:
  bsr.s   chrout   ;Zeichen in D0 ausgeben
dez_out5:
  add.l   D3,D1    ;den Unterlauf zurÅck
  dbra    D2,dez_out1 ;schon alle Stellen?
  movem.l (SP)+,D0-D4/A1
  rts
dez_out4:
  tst.b   D4       ;Nullen ausgeben?
  bne.s   dez_out3 ;Ja! =>
  tst.w   D2       ;letzte Ziffer?
  bne.s   dez_out5 ;Nein! => dann ignorieren
  moveq   #'0',D0  ;wenn der gesamte Wert 0 ist,
  bra.s   dez_out3 ;zumindest eine 0 ausgeben!
dez_tab:
  DC.L 1,10,100,1000,10000,100000
  DC.L 1000000,10000000,100000000,1000000000
  ENDPART
*************************************************
* convert() - Die Commandline auswerten         *
*                                               *
* Dabei wird die Variable "flag" gesetzt,       *
* das D6-Register (Laufwerk) definiert und      *
* die Suchmaske und der Suchstring aus dem      *
* Filenamen zusammengesetzt.                    *
*************************************************
  PART 'convert'
convert:
  lea     anfang-128+1(A6),A0 ;Commandline
  clr.b   flag(A6)    ;alle Flags lîschen
  moveq   #-1,D6      ;keine Laufwerksangabe
convert1:
  cmpi.b  #' ',(A0)+  ;Spaces Åberlesen
  beq.s   convert1
  subq.l  #1,A0
  cmpi.b  #'-',(A0)   ;folgt noch was?
  bne.s   convert2    ;Nein! =>
  addq.l  #1,A0
  bset    #0,flag(A6) ;Files nur zÑhlen
convert2:
  cmpi.b  #' ',(A0)+  ;Spaces Åberlesen
  beq.s   convert2
  subq.l  #1,A0
  IF virus
  cmpi.b  #'+',(A0)   ;folgt noch was?
  bne.s   convert3    ;Nein! =>
  addq.l  #1,A0
  bset    #1,flag(A6) ;alle Files Åbernehmen
convert3:
  cmpi.b  #' ',(A0)+  ;Spaces Åberlesen
  beq.s   convert3
  subq.l  #1,A0
  cmpi.b  #':',(A0)
  bne.s   convert8
  addq.l  #1,A0       ;Doppelpunkt ignorieren
convert8:
  moveq   #0,D0
  move.b  (A0),D0
  bmi.s   convert14   ;Code>127 => kein Laufwerk
  bclr    #5,D0
  subi.b  #'A',D0
  bmi.s   convert14   ;<'A' => kein Laufwerk
  cmp.b   #32,D0
  bhs.s   convert14   ;>maxdrive => kein Laufwerk
  move.w  D0,D6       ;Laufwerksangabe merken
convert14:
  rts
  ELSE
  cmpi.b  #':',(A0)
  bne.s   convert6
  moveq   #0,D0
  move.b  1(A0),D0
  addq.l  #2,A0
  bclr    #5,D0
  cmp.b   #32,D0
  bhs.s   convert6   ;>maxdrive => kein Laufwerk
  move.w  D0,D6      ;Laufwerksangabe merken
convert6:
  cmpi.b  #' ',(A0)+ ;Spaces Åberlesen
  beq.s   convert6
  subq.l  #1,A0
  lea     search_mask(A6),A1 ;Suchmaske
  lea     search_chars(A6),A2 ;Suchdaten
  clr.l   (A1)+
  clr.l   (A1)+      ;alle Suchmasken lîschen
  clr.l   (A1)
  subq.l  #8,A1
  moveq   #0,D2      ;kein Allquantor
  moveq   #7,D1      ;max.8 Zeichen Filename
convert7:
  move.b  (A0)+,D0
  beq     convert19  ;Ende des Filenames
  cmp.b   #' ',D0    ;Space als Ende?
  beq     convert19  ;Ja! =>
  cmp.b   #13,D0     ;CR als Ende?
  beq     convert19  ;Ja! =>
  cmp.b   #'.',D0    ;Start der Extension?
  beq.s   convert12  ;Ja! =>
  cmp.b   #'?',D0    ;Existenzquantor?
  bne.s   convert8   ;Nein! =>
  tst.w   D2         ;Allquantor schon angegeben?
  bne.s   convert11  ;Ja! =>
  sf      (A1)+
  sf      (A2)+      ;Zeichen ignorieren
  bra.s   convert11  ;weiter =>
convert8:
  cmp.b   #'*',D0    ;Allquantor?
  bne.s   convert9   ;Nein! =>
  moveq   #-1,D2     ;Allquantor
  bra     convert7
convert9:
  tst.w   D2         ;Allquantor schon angegeben?
  bne.s   convert11  ;Ja! =>
  cmp.b   #'a',D0
  blo.s   convert10
  cmp.b   #'z',D0
  bhi.s   convert10
  bclr    #5,D0      ;in Groûbuchstaben wandeln
convert10:
  move.b  D0,(A2)+   ;Zeichen Åbernehmen
  st      (A1)+      ;Maske dazu setzen
convert11:
  dbra    D1,convert7 ;max.8 Zeichen
  bra     convert13
convert12:
  tst.w   D2 ;Allquantor angegeben?
  bne     convert13 ;Ja! =>
  move.b  #' ',(A2)+ ;Filenamen mit ' '
  st      (A1)+     ;auffÅllen
  dbra    D1,convert12
convert13:
  lea     search_mask+8(A6),A1 ;Suchmaske
  lea     search_chars+8(A6),A2 ;Suchdaten
  moveq   #2,D1   ;max.3 Zeichen Extension
convert14:
  move.b  (A0)+,D0
  beq.s   convert17 ;Ende des Filenames
  cmp.b   #' ',D0 ;Space als Ende?
  beq.s   convert17 ;Ja! =>
  cmp.b   #13,D0  ;CR als Ende?
  beq.s   convert17
  cmp.b   #'?',D0 ;Existenzquantor?
  bne.s   convert15 ;Nein! =>
  sf      (A1)+
  sf      (A2)+     ;Zeichen ignorieren
  bra.s   convert18 ;weiter =>
convert15:
  cmp.b   #'*',D0 ;Allquantor?
  beq     convert19 ;Nein! =>
  cmp.b   #'a',D0
  blo.s   convert16
  cmp.b   #'z',D0
  bhi.s   convert16
  bclr    #5,D0    ;in Groûbuchstaben wandeln
convert16:
  move.b  D0,(A2)+ ;Zeichen Åbernehmen
  st      (A1)+     ;Maske dazu setzen
  dbra    D1,convert14 ;schon alle max.8 Zeichen
  bra     convert19
convert17:
  move.b  #' ',(A2)+ ;Extension mit
  st      (A1)+     ;Space auffÅllen
convert18:
  dbra    D1,convert17
convert19:
  rts
  ENDC
  ENDPART
*************************************************
* hunt_dir() - Kompletten Dir-Baum ab A0        *
* durchsuchen, dabei steht die Anzahl der       *
* EintrÑge im Directory in D0.                  *
*                                               *
* Diese Routine ruft sich selbst rekursiv       *
* auf, um auch beliebig tiefe Ordnerebene zu    *
* durchsuchen.                                  *
*                                               *
* Der Baum muû durch read_dir() im Speicher     *
* liegen, d.h. bereits mit Pointern ver-        *
* kettet sein.                                  *
*************************************************
  PART 'hunt_dir'
hunt_dir:
  subq.w  #1,D0     ;fÅr DBRA
hunt_dir1:
  move.w  D7,D1     ;Illegale Fileattr-Bits
  and.b   11(A0),D1 ;Flags dazu
  bne     hunt_dir3 ;Datei nicht finden! =>
  cmpi.b  #$E5,(A0) ;gelîschte Datei?
  beq     hunt_dir2 ;Ja! =>
  IF !virus
  move.l  (A0),D1
  beq     hunt_dir4 ;Ende des Directories =>
  and.l   (A1),D1
  cmp.l   (A2),D1   ;Zeichen 1-4 des Filesnamens
  bne     hunt_dir3
  move.l  4(A0),D1
  and.l   4(A1),D1
  cmp.l   4(A2),D1  ;Zeichen 5-8 des Filenamens
  bne     hunt_dir3
  move.l  8(A0),D1
  and.l   8(A1),D1
  cmp.l   8(A2),D1  ;die Extension vergleichen
  bne     hunt_dir3
  btst    #0,flag(A6) ;Dateien nur zÑhlen?
  bne.s   print_fname4 ;Ja! =>
  bsr     print_fname ;Filenamen ausgeben
print_fname4:
  addq.w  #1,D4     ;Dateien zÑhlen
  movep.w 31(A0),D1
  move.b  30(A0),D1
  swap    D1        ;DateilÑnge
  movep.w 29(A0),D1 ;von Intel
  move.b  28(A0),D1 ;nach 68000er
  add.l   D1,D5     ;zur GesamtlÑnge
  ELSE
  tst.b   (A0)
  beq     hunt_dir4 ;Ende des Directories =>
  addq.w  #1,D4     ;eine Datei mehr gefunden
  move.w  8(A0),D1  ;Zeichen 1+2 der Ext. holen
  cmp.w   #'PR',D1  ;PRG, PRX, etc.
  beq.s   found_file
  cmp.w   #'TO',D1  ;TOS
  beq.s   found_file
  cmp.w   #'TT',D1  ;TTP
  beq.s   found_file
  cmp.w   #'AC',D1  ;ACC, ACX, etc.
  beq.s   found_file
  cmp.w   #'AP',D1  ;APP
  beq.s   found_file
  cmp.w   #'DR',D1  ;DRV (Treiber)
  beq.s   found_file
  cmp.w   #'SY',D1  ;SYS (Plattentreiber!)
  bne     hunt_dir3
found_file:
  move.l  D0,-(SP)
regs REG D1-D4/D6-A2/A4-A6
  movem.l regs,-(SP)
  movep.w 27(A0),D0
  move.b  26(A0),D0 ;Cluster ins Intel-Format
  move.w  drive(A6),-(SP) ;aktuelles Drive
  subq.w  #2,D0
  mulu    clsiz(A5),D0 ;mal Sektoren pro Cluster
  add.w   datrec(A5),D0 ;+ erster freier Sektor
  move.w  D0,-(SP)  ;= abs. Sektor
  move.w  #1,-(SP)  ;einen Sektor einlesen
  pea     sektor_buffer(A6) ;in den Buffer
  move.l  #$040000,-(SP)
  trap    #13       ;Rwabs() - Sektor einlesen
  lea     14(SP),SP
  tst.l   D0
  bmi     _exit
  lea     sektor_buffer(A6),A2
  moveq   #0,D0
  cmpi.w  #$601A,(A2) ;Programmkennung?
  bne.s   count_loop1 ;Nein! =>
  lea     28(A2),A0 ;Zeiger auf den Programmstart
  cmpi.w  #$487A,(A0)+ ;PEA
  bne.s   no_virus  ;Nein! =>
  cmpi.w  #$FFFE,(A0)+ ;*-2(PC)
  bne.s   no_virus  ;Nein! =>
  cmpi.w  #$4EF9,(A0) ;c't-Virus?
  beq     virus2    ;JA! =>>
  cmpi.l  #$207A0006,(A0)+ ;VCS-Virus?
  bne.s   no_virus  ;Nein! =>
  cmpi.l  #$4EFB8800,(A0)
  beq     virus1    ;JA! =>>
no_virus:
  moveq   #127,D2
count_loop:
  eor.w   D2,D0     ;PrÅfsumme errechnen
  sub.w   (A2)+,D0
  addq.w  #1,D0
  dbra    D2,count_loop
  tst.w   D0
  bne.s   count_loop1
  moveq   #213,D0   ;die PrÅfsumme ist NIE 0!
count_loop1:
  movem.l (SP),regs ;Chksumme in D0
  tst.l   D0        ;PrÅfsumme=0?
  beq     check_it6 ;dann kein Programm! =>

  movea.l data_base(A6),A1
  bra.s   check_it0
check_it2:
  lea     24(A4),A1 ;der nÑchste Eintrag
  movea.l A2,A0     ;auf den Filenamen zurÅck
check_it0:
  movea.l A0,A2     ;A0 retten
  movea.l A1,A4     ;A1 retten
  tst.l   (A1)      ;Tabelle ist leer, bzw. Ende
  beq.s   check_it3 ;Neuer Eintrag nîtig! =>
  moveq   #4,D1     ;nur 10(!) Buchstaben
check_it1:
  cmpm.w  (A1)+,(A0)+   ;vergleichen
  dbne    D1,check_it1
  bne.s   check_it2     ;ungleich =>

  lea     10(A4),A1     ;Zeiger auf die PrÅfsumme
  moveq   #6,D1         ;max.7 PrÅfsummen
check_it5:
  tst.w   (A1)
  beq.s   check_it4     ;PrÅfsumme nicht gefunden
  cmp.w   (A1)+,D0
  dbeq    D1,check_it5  ;weiter vergleichen =>
  lea     -12(A1),A1
  beq.s   check_it8     ;PrÅfsumme ist ok! =>
check_it4:
  movea.l A2,A0
  bsr     print_fname   ;Filenamen ausgeben
  pea     fehler_text(A6)
  bsr     print_line    ;Meldung machen!
  btst    #1,flag(A6)   ;stets Åbernehmen?
  bne.s   check_it7     ;Ja! =>
  movem.l D0/D2/A0-A2,-(SP)
  move.w  #7,-(SP)
  trap    #1            ;auf Taste warten
  addq.l  #2,SP
  bclr    #5,D0
  move.w  D0,D1
  movem.l (SP)+,D0/D2/A0-A2
  cmp.b   #'J',D1       ;öbernehmen?
  bne.s   check_it6     ;Nein! =>
check_it7:
  move.w  D0,(A1)       ;PrÅfsumme kopieren
  addq.w  #1,D5
  bra.s   check_it6

check_it3:
  move.l  (A2)+,(A4)+   ;neuen Eintrag
  move.l  (A2)+,(A4)+   ;Filenamen kopieren
  move.w  (A2)+,(A4)+   ;(nur 10 Buchstaben!)
  move.w  D0,(A4)       ;1.PrÅfsumme
  addq.w  #1,D5
  movem.l (SP),regs
  bsr     print_fname   ;Filenamen ausgeben
  pea     new_text(A6)
  bsr     print_line
  bra.s   check_it6
check_it8:
  btst    #0,flag(A6)   ;Ausgabe?
  bne.s   check_it6     ;Nein! =>
  movem.l (SP),regs
  bsr     print_fname   ;Filenamen ausgeben
  bra.s   check_it6

virus1:
  movem.l (SP),regs     ;Filenamen nach A0
  lea     virus1_text(A6),A4 ;VCS-Linkvirus
  bra.s   check_it9
virus2:
  movem.l (SP),regs     ;Filenamen nach A0
  lea     virus2_text(A6),A4 ;Milzbrand-Virus
check_it9:
  bsr.s   print_fname   ;Fname ausgeben
  pea     virus_text(A6)
  bsr     print_line    ;Meldung machen!
  move.l  A4,-(SP)
  bsr     print_line
  addq.w  #1,virus_count(A6) ;Virenanzahl
check_it6:
  movem.l (SP)+,regs
  move.l  (SP)+,D0
  ENDC
hunt_dir3:
  btst    #4,11(A0) ;ein Ordner?
  beq.s   hunt_dir2 ;Nein! =>
  cmpi.b  #$E5,(A0) ;Gelîscht?
  beq.s   hunt_dir2 ;Ja! =>
  cmpi.w  #'. ',(A0)
  beq.s   hunt_dir2 ;Dummy-EintrÑge ignorieren
  cmpi.w  #'..',(A0)
  beq.s   hunt_dir2
  movem.l D0/A0/A3,-(SP)
  REPT 8
  move.b  (A0)+,(A3)+
  ENDR
  move.b  #'.',(A3)+
  REPT 3
  move.b  (A0)+,(A3)+   ;in den Pfad kopieren
  ENDR
  addq.l  #1,A0
  move.b  #'\',(A3)+
  move.l  (A0)+,D0      ;BaumlÑnge in EintrÑgen
  movea.l (A0),A0
  bsr     hunt_dir
  addq.w  #1,D3         ;INC Anzahl der Ordner
  movem.l (SP)+,D0/A0/A3
hunt_dir2:
  lea     32(A0),A0     ;=> nÑchsten Eintrag
  dbra    D0,hunt_dir1  ;alle EintrÑge durch?
hunt_dir4:
  rts
  ENDPART
*************************************************
* Filenamen ab A0 ausgeben                      *
*************************************************
  PART 'print_fname'
print_fname:
  movem.l D0-D2/A0-A3,-(SP)
  REPT 8
  move.b  (A0)+,(A3)+   ;Filenamen
  ENDR
  move.b  #'.',(A3)+
  REPT 3
  move.b  (A0)+,(A3)+   ;an den Pfad anhÑngen
  ENDR
  btst    #4,(A0)       ;ein Ordner?
  beq.s   print_fname0
  move.b  #'\',(A3)+    ;dann auch so abschlieûen
print_fname0:
  move.b  #13,(A3)+     ;CR
  move.b  #10,(A3)+     ;LF
  clr.b   (A3)
  lea     pfad(A6),A3
print_fname1:
  moveq   #0,D0
  move.b  (A3)+,D0      ;Zeichen holen
  beq.s   print_fname2  ;Ende des Pfades =>
  cmp.b   #' ',D0       ;Spaces ignorieren
  beq.s   print_fname1  ;nÑchstes Zeichen =>
  cmp.b   #'.',D0       ;Extension erreicht?
  bne.s   print_fname3  ;Nein! =>
  cmpi.b  #' ',(A3)     ;es folgt ein " "?
  beq.s   print_fname1  ;dann den "." ignorieren
print_fname3:
  bsr     chrout        ;das Zeichen ausgeben
  bra.s   print_fname1
print_fname2:
  movem.l (SP)+,D0-D2/A0-A3
  rts
  ENDPART
*************************************************
* read_dir() - Kompletten Dir-Baum einlesen     *
*             (ab A0 liegt er, LÑnge in D0)     *
* Diese Routine liest das Root-Directory ein    *
* und ruft dann bei jedem Ordner die Routine    *
* "read_sub_dir" auf, welche sich selbst        *
* wieder rekursiv aufrufen kann.                *
*************************************************
  PART 'read_dir'
read_dir:
  movem.l D1-D7/A1-A6,-(SP)
  move.w  rdlen(A5),D0  ;LÑnge des Root-Dirs
  mulu    recsiz(A5),D0 ;mal Sektorgrîûe
  bsr     get_mem       ;Speicher anfordern
  movea.l D0,A4         ;Zeiger auf das ROOT-Dir
  movea.l D0,A3         ;Anfang des Root-Dir
  move.w  drive(A6),-(SP) ;aktuelles Drive
  move.w  fatrec(A5),D1
  add.w   fsiz(A5),D1
  move.w  D1,-(SP)      ;Startsektor des Root-Dir
  move.w  rdlen(A5),-(SP) ;LÑnge der FAT
  move.l  A4,-(SP)      ;in den Buffer
  move.l  #$040000,-(SP)
  trap    #13           ;Rwabs() - DIR einlesen
  lea     14(SP),SP
  tst.l   D0
  bmi     _exit
  move.w  rdlen(A5),D7  ;LÑnge des Root-Dir
  mulu    recsiz(A5),D7 ;mal Sektorgrîûe
  lsr.l   #5,D7    ;\32 Bytes (Eintraggrîûe)
  subq.w  #1,D7    ;Gesamtanzahl der Eintrag-1
hunt_dir_loop:
  btst    #4,11(A4)      ;ein Ordner?
  beq.s   hunt_dir_loop1 ;Nein! =>
  cmpi.b  #$E5,(A4)      ;gelîschter Ordner?
  beq.s   hunt_dir_loop1 ;Ja! =>
  bsr.s   read_sub_dir
hunt_dir_loop1:
  lea     32(A4),A4        ;nÑchster Eintrag
  dbra    D7,hunt_dir_loop ;alle EintrÑge?
  movea.l A3,A0      ;Anfangsadresse des Dirs
  move.w  rdlen(A5),D0  ;LÑnge des Dirs in Bytes
  mulu    recsiz(A5),D0 ;errechnen
  lsr.l   #5,D0      ;\32 Bytes (Eintragsgrîûe)
  movem.l (SP)+,D1-D7/A1-A6
  rts
  ENDPART
*************************************************
* read_sub_dir() - Unterverzeichnisse ab A4     *
*                  rekursiv einlesen            *
* A4 zeigt auf den Ordner, der eingelesen       *
* werden soll. Es wird die Clusternummer        *
* ermittelt, dann geht's los. Damit             *
* "hunt_dir" das alles richtig hinbekommt,      *
* werden die EintrÑge mit Langworten            *
* (Zeigern) verkettet. Dazu steht im Ordner-    *
* eintrag (der ist 32 Bytes lang) bei Offset    *
* 16 ein Langwort, welches auf den Ordner       *
* zeigt. Beim Offset 20 steht die max. Anzahl   *
* an EintrÑgen die in diesem Ordner mîglich     *
* sind. Diese Angabe wird von "hunt_dir"        *
* ebenfalls benîtig.                            *
*************************************************
  PART 'read_sub_dir'
read_sub_dir:
  movem.l D0-A6,-(SP)
  movep.w 27(A4),D3
  move.b  26(A4),D3 ;Clusternr. im Intel-Format
  movea.l A4,A3   ;Ptr auf Hauptdirectory merken
  moveq   #0,D5   ;Clusteranzahl des Sub-Dirs
read_sub_dir1:
  moveq   #0,D0
  move.w  clsizb(A5),D0 ;Bytes pro Cluster
  bsr     get_mem       ;Speicher anfordern
  movea.l D0,A4         ;Zeiger auf den Cluster
  tst.w   D5
  bne.s   read_sub_dir5
  move.l  A4,16(A3)     ;Zeiger auf Sub-Dir
read_sub_dir5:
  move.w  drive(A6),-(SP) ;akt.Drv
  move.w  D3,D0         ;akt.Clusternummer
  subq.w  #2,D0
  mulu    clsiz(A5),D0  ;mal Sektoren pro Cluster
  add.w   datrec(A5),D0 ;+ erster freier Sektor
  move.w  D0,-(SP)      ;= abs. Sektor
  move.w  clsiz(A5),-(SP) ;Cluster einlesen
  move.l  A4,-(SP)      ;in den Buffer
  move.l  #$040000,-(SP)
  trap    #13      ;Rwabs() - Cluster einlesen
  lea     14(SP),SP
  tst.l   D0
  bmi     _exit

  move.w  clsizb(A5),D7 ;Bytes pro Cluster
  lsr.w   #5,D7     ;\32 Bytes (Eintragsgrîûe)
  subq.w  #1,D7     ;fÅr DBRA
read_sub_dir2:
  btst    #4,11(A4)     ;ein Ordner?
  beq.s   read_sub_dir3 ;Nein! =>
  cmpi.b  #$E5,(A4)     ;gelîscht?
  beq.s   read_sub_dir3 ;Ja! =>
  cmpi.w  #'. ',(A4)
  beq.s   read_sub_dir3 ;ignore Dummy-EintrÑge
  cmpi.w  #'..',(A4)
  beq.s   read_sub_dir3
  bsr.s   read_sub_dir
read_sub_dir3:
  lea     32(A4),A4 ;nÑchster Eintrag
  dbra    D7,read_sub_dir2 ;alle EintrÑge?
  addq.w  #1,D5   ;Clusteranzahl des Sub-Dir
  move.w  D3,D0
  add.w   D0,D0   ;mal 2, als Zeiger auf die FAT
  movea.l fat_adr(A6),A0 ;Ptr: decodierte FAT
  move.w  0(A0,D0.w),D3  ;Nr des Folgeclusters
  bpl.s   read_sub_dir1  ;Ende? Nein! =>

  mulu    clsizb(A5),D5 ;Bytes pro Cluster
  lsr.l   #5,D5     ;Grîûe des Sub-Dir in Bytes
  move.l  D5,12(A3) ;Anzahl der mgl.EintrÑge
  movem.l (SP)+,D0-A6
  rts
  ENDPART
*************************************************
* Laufwerk D0 als akt.Laufwerk anmelden, FAT    *
* einlesen. Der freie Speicherplatz wird in     *
* D0 zurÅckgegeben                              *
* WICHTIG: A5 zeigt nach "set_drive" STETS      *
*      auf den BPB des aktuellen Laufwerkes.    *
*      Davon wird in "read_dir" ausgegangen.    *
*************************************************
  PART 'set_drive'
set_drive:
  movem.l D1-A4,-(SP)
  move.w  D0,drive(A6)  ;akt.Laufwerk setzen
  bsr.s   get_bpb ;BPB-Adresse holen

  moveq   #0,D0
  move.w  numcl(A5),D0
  add.l   D0,D0         ;Gesamtzahl der Cluster*2
  bsr     get_mem       ;Speicher anfordern
  move.l  D0,fat_adr(A6)

  move.w  fsiz(A5),D0   ;LÑnge der FAT
  mulu    recsiz(A5),D0 ;mal Bytes pro Sektor
  bsr     get_mem       ;Speicher anfordern
  move.l  D0,fat_buffer(A6)

  move.w  drive(A6),-(SP)  ;aktuelles Drive
  move.w  fatrec(A5),-(SP) ;Anfang der 2.FAT
  move.w  fsiz(A5),-(SP)   ;LÑnge der FAT
  move.l  fat_buffer(A6),-(SP)
  move.l  #$040000,-(SP)
  trap    #13           ;2.FAT komplett einlesen
  lea     14(SP),SP
  tst.l   D0
  bmi     _exit

  bsr.s   wandel_fat ;FAT ins 68000er-Format

  movea.l fat_adr(A6),A0 ;Ptr: decodierte FAT
  addq.l  #4,A0      ;erste 2 Cluster ignorieren
  move.w  numcl(A5),D1
  subq.w  #3,D1      ;2 Cluster abziehen (DBRA!)
  moveq   #0,D0      ;Anzahl der freien Cluster
set_drive1:
  tst.w   (A0)+      ;ein freier Cluster?
  bne.s   set_drive2 ;Nein! =>
  addq.w  #1,D0      ;INC freie Cluster
set_drive2:
  dbra    D1,set_drive1 ;alle gezÑhlt?
  mulu    clsizb(A5),D0 ;mal Bytes pro Cluster
  movem.l (SP)+,D1-A4
  rts
  ENDPART
*************************************************
* BPB des akt.Laufwerkes nach A5                *
*************************************************
  PART 'get_bpb'
get_bpb:
  move.w  drive(A6),-(SP)
  move.w  #7,-(SP)
  trap    #13           ;Getbpb(drive)
  addq.l  #4,SP
  move.l  D0,akt_bpb(A6)
  beq     _exit
  movea.l D0,A5         ;Zeiger auf den BPB
  rts
  ENDPART
*************************************************
* FAT vom 12-bit- bzw. 16-bit-Intel-Format      *
* ins 16-bit-68000er-Format                     *
*************************************************
  PART 'wandel_fat'
wandel_fat:
  movea.l fat_buffer(A6),A0 ;Ptr: FAT
  movea.l fat_adr(A6),A1 ;Ptr: decodierte FAT
  move.w  fsiz(A5),D0    ;LÑnge der FAT
  mulu    recsiz(A5),D0  ;mal Bytes pro Sektor
  move.w  bflags(A5),D1  ;Flags holen
  btst    #0,D1     ;12-bit-FAT?
  beq.s   wandel_fat2 ;Ja! =>
  lsr.w   #1,D0     ;Anzahl der Worte
  subq.w  #1,D0     ;fÅr DBRA
wandel_fat1:
  movep.w 1(A0),D1
  move.b  (A0),D1   ;Intel-Wandl. bei 16-bit-FAT
  addq.l  #2,A0
  move.w  D1,(A1)+
  dbra    D0,wandel_fat1
  rts
wandel_fat2:
  divu    #3,D0       ;12-bit-FAT wandeln
wandel_fat3:
  movep.w 1(A0),D1
  move.b  (A0),D1     ;Intel-Word holen
  and.w   #$0FFF,D1   ;Bit 12-15 sind unwichtig
  cmp.w   #$0FF0,D1   ;Nummer $FF0-$FFF?
  blo.s   wandel_fat4 ;Nein! =>
  or.w    #$F000,D1   ;Vorzeichen erweitern
wandel_fat4:
  move.w  D1,(A1)+    ;Cluster merken
  movep.w 2(A0),D1
  move.b  1(A0),D1    ;Intel-Word holen
  lsr.w   #4,D1       ;Bit 0-3 sind unwichtig
  cmp.w   #$0FF0,D1   ;Nummer $FF0-$FFF?
  blo.s   wandel_fat5 ;Nein! =>
  or.w    #$F000,D1   ;Vorzeichen erweitern
wandel_fat5:
  move.w  D1,(A1)+    ;Cluster merken
  addq.l  #3,A0       ;3 Bytes sind fertig
  dbra    D0,wandel_fat3 ;schon alle Tripel?
  rts
  ENDPART
*************************************************
* D0=get_mem(Byteanzahl in D0)                  *
*    Speicher vom Heap anfordern                *
*************************************************
  PART 'get_mem'
get_mem:
  move.l  A0,-(SP)
  addq.l  #1,D0           ;EVEN
  and.b   #-2,D0
  move.l  heap_pnt(A6),D1 ;alter Heap-Pointer
  exg     D0,D1
  add.l   D1,heap_pnt(A6) ;Platz auf dem Heap
  movea.l anfang-256+4(PC),A0 ;Speicherende
  cmpa.l  heap_pnt(A6),A0 ;Speicherobergrenze?
  blo     _exit           ;Ja! => raus =>
  movea.l (SP)+,A0
  rts
  ENDPART
*************************************************
* Ab hier: das DATA-Segment                     *
*************************************************
  DATA
  IF virus
files_text:
  DC.B ' Dateien, ',0
files_text2:
  DC.B ' geÑnderte bzw. neue Dateien.',13,10,0
folders_text:
  DC.B ' Ordner sind vorhanden.'
  DC.B ' Schreiben?',13,10,0
init_text:
  DC.B 27,'E',27,'e'
  DC.B 'LVF V1.5 (Link-Virus-Finder)',13,10
  DC.B 'Ω1989 by ‰-soft,'
  DC.B ' Markus Fritze',13,10,10,0
fehler_text:
  DC.B 'PrÅfsumme ist fehlerhaft'
  DC.B ' (öbernehmen?)',13,10,0
virus_text:
  DC.B 7,'Datei enthÑlt '
  DC.B ' wahrscheinlich ',0
virus1_text:
  DC.B 'einen VCS-Linkvirus!',13,10,7,0
virus2_text:
  DC.B 'den Milzbrand-Linkvirus!',13,10,7,0
viren_text:
  DC.B ' wahrscheinlich verseuchte'
  DC.B ' Dateien gefunden!',7,13,10,0
new_text:
  DC.B 'Datei wurde hinzugefÅgt.',13,10,0
fname:
  DC.B 'LVF.DAT',0
  ELSE
files_text:
  DC.B ' Dateien mit insgesamt ',0
files_text2:
  DC.B ' Bytes gefunden.',13,10,0
folders_text:
  DC.B ' Ordner sind vorhanden.'
  DC.B ' Taste drÅcken.',13,10,0
init_text:
  DC.B 27,'E',27,'e'
  DC.B 'FFF V1.5 (Fast-File-Finder)',13,10
  DC.B 'Ω1989 by ‰-soft, Markus Fritze'
  DC.B 13,10,10,0
  ENDC
exit_text:  DC.B 27,'E',27,'f',0
drive_text: DC.B 'Laufwerk ',0
drive_text2:DC.B ': (',0
drive_text3:DC.B ' Bytes frei.)',13,10,0

**********************************************
* Ab hier: das BSS-Segment                   *
**********************************************
          BSS
          DS.L 1024 ;4k Stack fÅr rekursive Suche
own_stack:DS.L 0
drive:    DS.W 1   ;aktuelles Laufwerk
akt_bpb:  DS.L 1   ;Ptr: BPB des akt.Laufwerks
fat_buffer:DS.L 1  ;Adresse der gelesenen FAT
fat_adr:  DS.L 1   ;Adresse der decodierten FAT
virus_count:DS.W 1 ;Anz. der gefundenen Viren
flag:     DS.B 1   ;Bit 0=1: keine Fileausgabe
;Bit 1=1: neue Programme Åbernehmen
          EVEN
pfad:     DS.B 256 ;Platz fÅr den Suchpfad
heap_pnt: DS.L 1
          IF virus
data_base:DS.L 1   ;Ptr: File-Daten im RAM
data_buff:DS.B 24*max_prgs ;Prg-Buffer
sektor_buffer:DS.B max_sektorsize ;Sektorbuf.
          ELSE
search_mask:DS.B 12 ;Suchmaske (Joker)
search_chars:DS.B 12 ;Suchzeichen
          ENDC
heap:     DS.L 0   ;freier Speicher ab hier
          END

