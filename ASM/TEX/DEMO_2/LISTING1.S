;
; Anzeigen eines Bildes, welches den kompletten Bildschirm inclusive Rand
; mit Pseudographik belegt.
; WÑhrend der ZeilenaustastlÅcke wird digitaler Sound gespielt.
; Die Bildauflîsung betrÑgt in diesem Falle scheinbar 384*312 Pixels in
; geringer Auflîsung
;

color1:   equ       $000
color2:   equ       $400
color3:   equ       $500
color4:   equ       $700
color5:   equ       $007
anzahl:   equ       42661               ; Laenge des Soundfiles in Bytes

x:
          clr.l     -(sp)               ; schalte auf Supervisormodus
          move.w    #$20,-(sp)          ;
          trap      #1                  ;
          addq.l    #6,sp               ;
          move.l    d0,oldstack         ; sichere alten Stack

          bsr       mausaus             ; schlalte die Maus ab
          bsr       cur_clear           ; Bildschirm lîschen
          bsr       vsync               ; warte auf VBL

          move.b    $ffff8260.w,oldrez  ; hole alte Aufloesung
          clr.b     $ffff8260.w         ; stelle geringe Auflîsung ein
          move.b    $ffff820a,oldsync   ; sichere alte Bildfrequenz
          move.b    #2,$ffff820a.w      ; 50 Hz

          movem.l   $ffff8240.w,d0-d7   ; hole alte Farbpalette
          movem.l   d0-d7,oldpal        ; und sichere sie
          movem.l   nulpal(pc),d0-d7    ; hole Leerpalette
          movem.l   d0-d7,$ffff8240.w   ; und stelle sie ein

          bsr       pic_init            ; Bild im Speicher aufbereiten

          lea       bildanz,a0
          bsr       supexec
ende:
          bsr       vsync               ; warte auf VBL

          move.b    oldsync,$ffff820a.w ; alte Bildfrequenz
          move.b    oldrez,$ffff8260.w  ; alte Auflîsung
          movem.l   oldpal,d0-d7        ; hole alte Farbpalette
          movem.l   d0-d7,$ffff8240.w   ; und setze sie wieder

          bsr       mausein

          move.l    oldstack,-(sp)      ; schalte auf Usermodus
          move.w    #$20,-(sp)          ;
          trap      #1                  ;
          addq.l    #6,sp               ;

;          illegal
          clr.w     -(sp)
          trap      #1
;
; Bildschirm loeschen
;
cur_clear:
          movem.l   d0-d2/a0-a2,-(sp)

          pea       ccdat
          move.w    #9,-(sp)
          trap      #1
          addq.l    #6,sp

          movem.l   (sp)+,d0-d2/a0-a2
          rts
;
; supexec - a0 ist Routinenadresse
;
supexec:
          movem.l   d0-d2/a0-a2,-(sp)

          move.l    a0,-(sp)
          move.w    #38,-(sp)
          trap      #14
          addq.l    #6,sp

          movem.l   (sp)+,d0-d2/a0-a2
          rts
;
; getbase - bildschirmbasisadresse nach a0
;
getbase:
          movem.l   d0-d2/a1-a2,-(sp)

          move.w    #2,-(sp)
          trap      #14
          addq.l    #2,sp

          move.l    d0,a0
          movem.l   (sp)+,d0-d2/a1-a2
          rts
;
; mausein - Mausmeldungen einschalten, Maus wieder anzeigen
;
mausein:
          pea       on                  ; Code fÅr relative Maus
          clr       -(sp)               ; 1 Zeichen
          move.w    #25,-(sp)           ; IKBDWS
          trap      #14                 ;
          addq.w    #8,sp               ; Stack korrigieren

          dc.w      $a000,$a009
          rts
;
; warte auf VBL-Interrupt
;
vsync:
          movem.l   d0-d2/a0-a2,-(sp)   ; sichere Arbeitsregister

          move.w    #37,-(sp)           ; Code fuer Vsync
          trap      #14                 ;
          addq.l    #2,sp               ;

          movem.l   (sp)+,d0-d2/a0-a2   ; hole Arbeitsregister wieder
          rts
;
; mausaus - Maus lîschen, Mausmeldungen abschalten
;
mausaus:
          dc.w      $a000,$a00a

          pea       off                 ; Code fÅr Mausmeldungen abschalten
          clr       -(sp)               ; 1 Zeichen
          move.w    #25,-(sp)           ; IKBDWS
          trap      #14                 ;
          addq.w    #8,sp               ; Stack korrigieren

          rts
;
; Programm zu Anzeigen des Bildes im Speicher aufbauen.
;
;         Es werden 312 Zeilen anstelle von 625/2 Zeilen gezeichnet
;         Dadurch ergibt sich ein nach oben gerichtetes Scrolling
;
; Registerbelegung:
;
; A0:     Quelle fÅr MOVEUP, MODIFY
; A1:     Ziel fÅr MOVEUP, MODIFY
; A2:     Adresse im zu programmierenden Bild
; A3:     Startadresse der aktuellen Bildzeile im Programmbild 1
; A4:     Startadresse der aktuellen Bildzeile im Programmbild 2
;
; D0:     Anzahl fÅr MOVEUP, MODIFY
; D1:     ZÑhler fÅr die 39 Zeilenblîcke
; D2:     ZÑhler fÅr die 8 Zeilen innerhalb des Zeilenblocks
;
pic_init:
          movem.l   a0-a4/d0-d2,-(sp)

          lea       init,a0             ; adressiere Initialisierungsroutine
          lea       picinit,a1          ; kopiere nach PICINIT
          move.w    #initend-init,d0    ; bestimme LÑnge
          bsr       moveup              ;
;
; erstelle nun das Programm, welches das Bild anzeigt. Das Bild besteht aus
; 312 Zeilen, welche in 39 Blîcke zu je 8 Zeilen unterteilt sind.
; Pro Zeile kînnen 48 'Pixels' dargestellt werden
;
          lea       picanz,a4           ; Zeilenadresse Bildroutinen

          lea       bild,a2             ; adressiere das zu programmierende Bild
          moveq     #39-1,d1            ; 39 Blîcke werden dargestellt
pic_i1:
          move.w    #8-1,d2             ; je acht Zeilen werden zusammengefaût
pic_i2:
          lea       loop,a0             ; Kopiere Code fÅr Bild2 in Puffer
          lea       (a4),a1             ;
          move.w    #endloop-loop,d0    ;
          bsr       moveup              ;

          lea       (a2),a0             ; hole Adresse der Farbtabelle
          lea       move-loop(a4),a1    ; adressiere MOVE.W Befehle in PICANZ
          bsr       modify              ; modifiziere das programm

                                        ; weiter mit der nÑchsten programmierten
          add.w     #endloop-loop,a4    ; Bildzeile

          dbf       d2,pic_i2           ; bearbeite den Block aus 8 Zeilen

          add.w     #48,a2              ; nÑchste Zeile in der Farbtabelle
          dbf       d1,pic_i1           ;

          move.w    #$4ed5,-2(a4)       ; 'jmp (a5)' scrolle rechts hoch
;          move.w    #$4ed5,-4(a4)       ; 'jmp (a5)' scrolle hoch
;          move.w    #$4ed5,-6(a4)       ; 'jmp (a5)' scrolle links hoch

          movem.l   (sp)+,d0-d2/a0-a4   ; hole Arbeitsregister wieder
          rts
;
; Modifiziere das Programm entsprechend der Farbtabelle
;
modify:
          movem.l   d0-d1/a0-a1,-(sp)   ; sichere Arbeitsregister

          moveq     #48-1,d0            ; 48 Spalten
modify1:
          move.b    (a0)+,d1            ; hole Farbcode
          subi.b    #'0'-3,d1           ; wandle in Bytecode um
          or.b      d1,1(a1)            ; modifiziere Programm
          addq.w    #2,a1               ; korrigiere Zeiger im Programm

          dbf       d0,modify1          ; bearbeite alle 48 MOVE.W's

          movem.l   (sp)+,d0-d1/a0-a1   ; hole Arbeitsregister wieder
          rts
moveup:
          movem.l   a0-a1/d0,-(sp)      ; Arbeitsregister sichern

          bra       moveup2             ; falls LÑnge=0
moveup1:
          move.b    (a0)+,(a1)+         ; Åbertrage Programm in Puffer
moveup2:
          dbf       d0,moveup1          ; bis alles Åbertrage ist

          movem.l   (sp)+,a0-a1/d0      ; hole Arbeitsregister wieder
          rts
;
; D2:     ===FREI===
; D3:     Farbwert 0
; D4:     Farbwert 1
; D5:     Farbwert 2
; D6:     Farbwert 3
; D7:     Farbwert 4
; A5:     Zeiger auf Programmcode erste Bildzeile
; A6:     Farbregister 0 (Hintergrund)
; A7:     Stack fÅr Start durch Timer B
;
bildanz:
          move.l    a7,spsave           ; sichere Stack wegen des Interrupts
          move.l    #stack,a7           ; neuen Stack laden
;
; Initialisierung der Farbwerte
;
          move.w    #color1,d3          ; Farbwert 1
          move.w    #color2,d4          ; Farbwert 2
          move.w    #color3,d5          ; Farbwert 3
          move.w    #color4,d6          ; Farbwert 4
          move.w    #color5,d7          ; Farbwert 5

          sub.l     a1,a1
          move.b    #$48,$fffffa17(a1)  ; setze Vektorregister
;
; sichere MFP-Inhalt und schalte alles ab
;
          move.b    $fffffa07(a1),sav_07; sichere alte MFP-Inhalte
          move.b    $fffffa09(a1),sav_09;

          clr.b     $fffffa07(a1)       ; erst einmal alles im MFP abschalten
          clr.b     $fffffa09(a1)       ;
;
; schalte Abbruch durch Taste ein
;
          move.l    $118,sav118         ; sichere alten Tastatur-Interrupt
          move.l    #keyboard,$118      ; trage neuen Interrupt ein

          bset      #6,$fffffa09(a1)    ; erlaube Tastatur Interrupt
          bset      #6,$fffffa15(a1)    ; maskieren
;
;         Initialisiere Timer B
;
          move.l    $120,sav120         ; alten Vektor sichern
          move.l    #picinit,$120       ; initialisiere Timer B
          move.w    #$ffff8240,a6       ; Farbregister Hintergrund

          move.b    #0,$fffffa1b(a1)    ; Timer B stop
          move.b    #4,$fffffa21(a1)    ; erlaube ein paar Zeilen
          move.b    #8,$fffffa1b(a1)    ; Timer B ein

          bset      #0,$fffffa07(a1)    ; Timer B Interrupt erlauben
          bset      #0,$fffffa13(a1)    ; Timer B Interrupt maskieren
          stop      #$2500              ; warte auf Interrupt
;
; Abbruch bei Tastatur-Interrupt
;
keyboard:
          sub.l     a1,a1               ; Adressregister fÅr SHORT initialisierne
;
; schlalte Timer B ab
;
          move.l    sav120,$120(a1)     ; alten Vektor wiederherstellen
          bclr      #0,$fffffa13(a1)    ; Interrupt demaskieren
;
; Keyboard-Interrupt wiederherstellen
;
          move.l    sav118,$118         ; stelle alten Interrupt wieder her
;
; erlaube auch alle anderen MFP-Interrupts wieder
;
          move.b    sav_07,$fffffa07(a1); IERA
          move.b    sav_09,$fffffa09(a1); IERB
;
; bearbeite Tastatur-Eingabe
;
          move.l    #keyb_exit,2(sp)    ; Ñendere RÅcksprung fÅr Interrupt
          move.l    $118,-(sp)          ; springe in System-Interruptroutine
          rts
;
; hier geht's danach weiter
;
keyb_exit:
          move      #$2000,sr           ; alle Interrupts wieder an
          move.l    spsave,a7           ; hole alten Stack wieder
          rts
;
; Initialisierung der Anzeige das Bildes, dient der Syncronisation mit dem
; Zeilenanfang
;
init:
          move.b    #0,$fffa1b          ; Timer B stop                     024
          bclr      #0,$fffa0f          ; Interrupt beenden                032
          move      #$2500,sr           ; alle MFP-Interrupts an           016

          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
initend:
loop:
          lea       picanz,a5          ; neues Bild anzeigen              012

          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
move:
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)
          move.w    d0,(a6)

          nop
jmpadr:   nop                           ; alternativ jmp loop
          nop
          nop
endloop:
nulpal:   dc.w      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
bild:
          dc.b      '011111111111111111111111111111111111111111111110'
          dc.b      '000000000000000000000000000000000000000000000000'
          dc.b      '011100001111100110011011111001110000011101111110'
          dc.b      '011100001111100110011011111001110000011101100000'
          dc.b      '011110001100000110011011000001111000011101111110'
          dc.b      '022220002220000220022022200002222000022202222220'
          dc.b      '022220002200000220022022000002222000022202200220'
          dc.b      '033333303333330333333033333303333330033303333330'
          dc.b      '033333303333330333330033333303333330033303333330'
          dc.b      '000000000000000000000000000000000000000000000000'
          dc.b      '033333333333333333333333333333333333333333333330'
          dc.b      '000000000000000000000000000000000000000000000000'
          dc.b      '000444044404040444000000000000000000000000000000'
          dc.b      '000400040404440400004000000000000000000000000000'
          dc.b      '000040044400040040000000000000000000000000000000'
          dc.b      '000444040404440444004000000000000000000000000000'
          dc.b      '000000000000000000000000000000000000000000000000'
          dc.b      '000000000000000000000000000000000000000000000000'
          dc.b      '000000000000000000011111111100000000000000000000'
          dc.b      '000000000000000000100000000010000001001000100000'
          dc.b      '000000000000000001004000004001000000101011000000'
          dc.b      '000000000000000001020000000201000000011100000000'
          dc.b      '000000000000000010002222222000100000001000000000'
          dc.b      '000000000000000100000000000000010000001000000000'
          dc.b      '000000000000000011111111111111100000011000000000'
          dc.b      '000000000000000000000012210000000000110000000000'
          dc.b      '000000000000000000001122221100000001100000000000'
          dc.b      '000000000000000000112224222211001111000000000000'
          dc.b      '000000000000000001222222222222111000000000000000'
          dc.b      '000000000000000012222224222222210000000000000000'
          dc.b      '000000000000000012222222222222210000000000000000'
          dc.b      '000000000000000011111111111111110000000000000000'
          dc.b      '000000000000000002222222222222200000000000000000'
          dc.b      '000000000000000000222222222222000000000000000000'
          dc.b      '000000000000000000003300000330000000000000000000'
          dc.b      '000000000000000000003300000330000000000000000000'
          dc.b      '000000000000000000003300000330000000000000000000'
          dc.b      '000000000000000003333000000033330000000000000000'
          dc.b      '000000000000000000000000000000000000000000000000'
init_tab:
          dc.b      000,255,001,255,002,255,003,255,004,255,005,255
          dc.b      006,000,007,063,008,000,009,000,010,000

on:       dc.b      8                   ; Maus relativer Modus
off:      dc.b      $12                 ; Mausmeldung abschalten
ccdat:    dc.b      27,'E',0
          even

          data
sav118:   blk.l      1                   ; alten Keyboard-Vektor
sav120:   blk.l      1                   ; alter Vektor fÅr Timer B
oldstack: blk.l      1                   ; GEMDOS-Stack
spsave:   blk.l      1                   ; alter Stackpointer
          blk.l      100                 ; neuer Stack
stack:
oldpal:   blk.w      16                  ; alte Hintergrundfarbe
oldrez:   blk.b      1                   ; alte Bildschirmauflîsung
oldsync:  blk.b      1                   ; alte Bildfrequenz
sav_07:   blk.b      1                   ; alter Wert IERA
sav_09:   blk.b      1                   ; alter Wert IERB
          even
picinit:  blk.b      initend-init
picanz:   blk.b      endloop-loop*312    ; Platz fuer generiertes Programm
          even
