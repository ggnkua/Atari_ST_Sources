* Diskettenutilities von S. Wachter
*
* Dateiname: DISKUTIL.S
*
* Momentan implementierte Funktionen:
*
* - Disketten ≈berpr≈fen

* Aus FDC.S importierte Routinen:

         xref     initdisk          * Diskettenzugriff vorbereiten
         xref     exitdisk          * Zugriffe beenden
         xref     readsect          * Einen Sektor lesen
         xref     writsect          * Einen Sektor schreiben

         .text

         move.l   4(sp),a0          * Basepage-Adresse holen
         move.l   12(a0),d0         * Programml—nge ermitteln
         add.l    20(a0),d0
         add.l    28(a0),d0
         lea      stack+4*100,sp    * Neuen Stack einrichten
         move.l   d0,-(sp)          * Programmspeicher reservieren
         move.l   a0,-(sp)
         clr.w    -(sp)
         move.w   #$4a,-(sp)
         trap     #1
         add.l    #12,sp
         bsr      strout            * Folgende Zeichenkette ausgeben
         dc.b     27,'E'
         dc.b     'Diskettenutilities von S. Wachter',13,10,10
         dc.b     'programmiert f≈rs ATARI magazin',13,10,10,0
         .even
         bsr      initdisk          * Diskettenzugriff vorbereiten
         bsr      main              * Hauptprogramm aufrufen
         bsr      exitdisk          * Zugriffe beenden
         clr.w    -(sp)             * Programm verlassen
         trap     #1

clrexit  and.b    #$fe,ccr          * Carry lÓschen und zur≈ck
         rts
setexit  or.b     #$01,ccr          * Carry setzen und zur≈ck
return   rts                        * R≈cksprung

main     bsr      strout            * Hauptmen≈
         dc.b     13,10
         dc.b     '1) Diskette ≈berpr≈fen/reparieren',13,10
         dc.b     10,'Ihre Wahl? ',0
         .even
main1    bsr      getkey
         cmp.b    #27,d0            * Programm mit <ESC> verlassen
         beq      return
         cmp.b    #'1',d0           * Nur Taste <1>-<x> zulassen
         bcs      main1
         cmp.b    #'1'+1,d0         * Diese Zeile wird sp—ter noch ge—ndert
         bcc      main1
         bsr      echo              * Gedr≈ckte Taste ausgeben
         cmp.b    #'1',d0
         beq      disktest

disktest clr.w    seite             * Seite 0
         clr.w    spur              * Spur 0
         move.w   #1,sektor         * Sektor 1
         bsr      readsekt          * Bootsektor einlesen
         move.w   d0,-(sp)          * Status merken
         bsr      service1          * Evtl. Fehler zeigen und reparieren
         move.w   (sp)+,d0
         btst     #4,d0             * RNF oder Timeout aufgetreten?
         bne      main              * Ja! Dann ist nichts zu machen.
         move.w   #255,d1
         clr.w    d0                * Alle Worte des Bootsektors zusammen-
         lea      sekpuff,a0        *  z—hlen
dsktest0 add.w    (a0)+,d0
         dbf      d1,dsktest0
         cmp.w    #$1234,d0         * Pr≈fsumme = $1234?
         bne      dsktest2          * Nein! Er enth—lt kein Bootprogramm
         bsr      strout
         dc.b     'Ausf≈hrbarer Bootsektor entdeckt! Pr≈fsumme ab—ndern? ',0
         .even
         bsr      getkey
         cmp.b    #'J',d0
         bne      dsktest1
         bsr      echo
         subq.w   #1,sekpuff+$1fe   * Ausgleichwort f≈r Pr≈fsumme ab—ndern
         bsr      writsekt          *  und Bootsektor zur≈ckschreiben
         tst.w    d0
         beq      dsktest2          * Kein Fehler aufgetreten
         bsr      errout            * FDC-Status zeigen
dsktest1 bsr      newline
dsktest2 move.w   sekpuff+$18,d0    * Informationen aus Bootsektor holen
         rol.w    #8,d0
         move.w   d0,anzsekto       * Sektoren pro Spur (z.B 9)
         move.w   sekpuff+$1a,d0
         rol.w    #8,d0
         move.w   d0,anzseite       * Anzahl der Seiten (1/2)
         clr.l    d0
         move.b   sekpuff+$14,d0    * Anzahl der Sektoren
         rol.w    #8,d0
         move.b   sekpuff+$13,d0
         move.w   anzseite,d1
         divu     d1,d0             * Geteilt durch die Seitenanzahl
         move.w   anzsekto,d1
         divu     d1,d0             * Geteilt durch die Sektoren pro Spur
         move.w   d0,anzspure       *  ergibt Anzahl der Spuren (z.B. 80)
         move.w   #2,sektor         * ˆberpr≈fung geht mit Sektor 2 weiter
dsktest3 bsr      escape            * Wurde <ESC> gedr≈ckt?
         bcs      main              * Ja! ˆberpr≈fung abbrechen
         bsr      readsekt          * Momentanen Sektor einlesen
         bsr      service1          * Evtl. Fehler zeigen und reparieren
         bcc      dsktest2          * Reparierten Sektor nochmals pr≈fen
         addq.w   #1,sektor         * N—chster Sektor
         move.w   anzsekto,d0
         cmp.w    sektor,d0
         bcc      dsktest3          * Bis inclusive anzsekto
         move.w   #1,sektor
         addq.w   #1,seite          * N—chste Seite
         move.w   seite,d0
         cmp.w    anzseite,d0
         bcs      dsktest3          * Bis exclusive anzseite
         clr.w    seite
         addq.w   #1,spur           * N—chste Spur
         move.w   spur,d0
         cmp.w    anzspure,d0
         bcs      dsktest3          * Bis exclusive anzspure
         bsr      strout
         dc.b     'ˆberpr≈fung beendet',13,10,0
         .even
         bra      main

service1 tst.w    d0                * Fehler beim Lesen aufgetreten?
         beq      setexit           * Nein! Dann Carry setzen und zur≈ck.
         move.w   d0,-(sp)          * Status merken
         bsr      errout            * Status ausgeben
         bsr      strout
         dc.b     '  Seite $',0
         .even
         move.w   seite,d0
         bsr      byteout           * Seiten-, Spur- und Sektornummer
         bsr      strout            *  des defekten Sektors ausgeben
         dc.b     ' Spur $',0
         .even
         move.w   spur,d0
         bsr      byteout
         bsr      strout
         dc.b     ' Sektor $',0
         .even
         move.w   sektor,d0
         bsr      byteout
         move.w   (sp)+,d0          * Status zur≈ckholen
         btst     #4,d0             * RNF oder Timeout aufgetreten?
         bne      servic11          * Ja! Dann ist nichts zu machen.
         bsr      strout
         dc.b     '  Reparieren? ',0
         .even
         bsr      getkey            * CRC + DDM Fehler kÓnnen behoben werden
         cmp.b    #'J',d0
         bne      servic11
         bsr      echo
         bsr      writsekt          * Sektor zur≈ckschreiben
         tst.w    d0                * Fehler aufgetreten?
         beq      clrexit           * Nein! Dann Carry lÓschen und zur≈ck.
         bsr      errout            * Status ausgeben
         bsr      newline
         bra      clrexit           * Carry lÓschen und zur≈ck
servic11 bsr      newline
         bra      setexit           * Carry setzen und zur≈ck

readsekt move.w   seite,d0          * Einen Sektor lesen
         move.w   spur,d1
         move.w   sektor,d2
         lea      sekpuff,a0        * Pufferadresse
         bra      readsect

writsekt move.w   seite,d0          * Einen Sektor schreiben
         move.w   spur,d1
         move.w   sektor,d2
         lea      sekpuff,a0        * Pufferadresse
         bra      writsect

errout   move.w   d0,-(sp)          * Status merken
         bsr      strout
         dc.b     'FDC-Fehler $',0
         .even
         move.w   (sp)+,d0          * Status zur≈ckholen
         bra      byteout           *  und ausgeben

strout   move.l   (sp)+,a3          * Sprungadresse vom Stack holen
strout1  move.b   (a3)+,d0          * Ein Zeichen aus Programmtext holen
         beq      strout2           * Letztes Zeichen erreicht!
         bsr      charout           * Zeichen ausgeben
         bra      strout1           * Stringende wurde noch nicht erreicht
strout2  move.l   a3,d0             * Endadresse des Strings plus eins
         btst     #0,d0             * Endet String auf ungerader Adresse?
         beq      strout3           * Nein! Dann ist dies die Returnadresse
         addq.l   #1,d0             * Ja! Auf n—chste gerade Adr. vorr≈cken
strout3  move.l   d0,-(sp)          * Returnadresse auf Stack legen
         rts                        *  und zur≈ck

echo     move.w   d0,-(sp)          * Zeichen merken
         bsr      charout           * Zeichen ausgeben
         bsr      newline           * Neue Zeile
         move.w   (sp)+,d0          * Zeichen zur≈ckholen
         rts

wordout  ror.w    #8,d0             * Wort in d0 hexadezimal ausgeben
         bsr      byteout
         ror.w    #8,d0
byteout  ror.b    #4,d0             * Byte in d0 hexadezimal ausgeben
         bsr      nibblout
         ror.b    #4,d0
nibblout move.w   d0,-(sp)
         and.b    #$0f,d0
         cmp.b    #10,d0
         bcs      nibble1
         addq.b   #7,d0
nibble1  add.b    #'0',d0
         bsr      charout
         move.w   (sp)+,d0
         rts

newline  move.b   #10,d0            * Neue Zeile
         bsr      charout
         move.b   #13,d0
         bra      charout
charout  move.w   d0,-(sp)          * Ein Zeichen ausgeben
         move.w   #2,-(sp)
         trap     #1
         addq.l   #4,sp
         rts
getkey   move.w   #7,-(sp)          * Ein Zeichen von Tastatur holen
         trap     #1
         addq.l   #2,sp
         cmp.b    #'a',d0           * Kleinbuchstaben in Gro˚buchstaben
         bcs      return            *  umwandeln
         cmp.b    #'z'+1,d0
         bcc      return
         sub.w    #32,d0
         rts
escape   movem.l  d0-d2/a0-a2,-(sp)
         move.w   #$0b,-(sp)        * Wurde <ESC> gedr≈ckt?
         trap     #1
         addq.l   #2,sp
         tst.w    d0
         beq.s    escape1           * Es wurde keine Taste gedr≈ckt
         bsr      getkey
         cmp.b    #27,d0
         bne.s    escape1
         movem.l  (sp)+,d0-d2/a0-a2 * Es wurde <ESC> gedr≈ckt!
         bra      setexit           * Carry setzen und zur≈ck
escape1  movem.l  (sp)+,d0-d2/a0-a2
         bra      clrexit           * Carry lÓschen und zur≈ck

         .bss

seite    ds.w     1
spur     ds.w     1
sektor   ds.w     1
anzseite ds.w     1
anzspure ds.w     1
anzsekto ds.w     1

sekpuff  ds.b     1024              * Puffer f≈r einen Sektor
stack    ds.l     100               * Platz f≈r neuen Stack

         .end

