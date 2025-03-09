;Hardcopy in verschiedenen Modi, monochrom, auflîsungsunabhÑngig
;Programm resident (fÅr EPSON LQ bzw. NEC)
xbios     equ 14
gemdos    equ 1
          pea       patch
          move.w    #38,-(sp)           ;Supervisor
          trap      #xbios
          addq.l    #6,sp
          clr.w     -(sp)
          move.l    #ende-start+1000,-(sp)
          move.w    #$31,-(sp)          ;keep process
          trap      #gemdos             ;Programm resident halten
patch:    movea.l   $456,a0             ;Hardcopy-Vektor
          adda.l    #28,a0              ;(vblqueue+28)
          move.l    #start,(a0)         ;auf dieses Programm umlenken
          rts       
start:    tst.w     $4ee                ;Hardcopy gewÅnscht?
          beq.s     hcopy
          rts       
hcopy:    move.w    #3,-(sp)            ;logbase
          trap      #xbios
          addq.l    #2,sp
          move.l    d0,log_base         ;Bildschirmadresse merken
          .DC.w $a000                   ;Line-A-Init
          addq.l    #2,a0               ;Bildschirmwerte ermitteln
          move.w    (a0),bytpline       ;Bytes pro Zeile (inkl. RÅcklauf)
          subq.l    #6,a0
          move.w    (a0),scanlins       ;Zeilen pro Bild
          subq.l    #8,a0
          move.w    (a0),xresolut       ;horizontale Auflîsung
          suba.l    #32,a0
          move.w    (a0),colpline       ;sichtbare Bytes pro Zeile
          movea.l   log_base,a0         ;Bildbereich retten
          lea.l     put(pc),a1
          clr.l     d4
          move.w    bytpline,d4
          subi.w    #27,d4              ;Breite von 27 Bytes abziehen
          move.l    #223,d3             ;Hîhe 224 Zeilen
pufzeile: move.l    #26,d2              ;Breite 27 Bytes
pufbytes: move.b    (a0)+,(a1)+
          dbra      d2,pufbytes
          adda.l    d4,a0
          dbra      d3,pufzeile
taste:    pea       menue               ;MenÅ ausgeben
          move.w    #$9,-(sp)
          trap      #gemdos
          addq.l    #6,sp
          move.w    #1,-(sp)            ;auf Tastendruck warten
          trap      #gemdos
          addq.l    #2,sp
          move.b    d0,format           ;Taste merken
          movea.l   log_base,a0         ;Bildbereich restaurieren
          lea.l     put(pc),a1
          clr.l     d4
          move.w    bytpline,d4
          subi.w    #27,d4
          move.l    #223,d3
scrzeile: move.l    #26,d2
scrbytes: move.b    (a1)+,(a0)+
          dbra      d2,scrbytes
          adda.l    d4,a0
          dbra      d3,scrzeile
          cmpi.b    #"0",d0             ;welche Taste?
          beq       exit
          cmpi.b    #"1",d0
          beq       klein
          cmpi.b    #"4",d0
          beq       klein
          cmpi.b    #"2",d0
          beq       normal
          cmpi.b    #"5",d0
          beq       normal
          cmpi.b    #"3",d0
          beq       quer
          cmpi.b    #"6",d0
          beq       quer
          bra       taste
exit:     move.w    #-1,$4ee            ;Hardcopy beendet
          rts       
;---------FORMATE 1 UND 4------------------------------------------------------
klein:    clr.l     d1
          clr.l     d2
          move.w    bytpline,d2
          clr.l     d3
          clr.l     d7
          movea.l   log_base,a3         ;ganz unten links beginnen
          move.w    scanlins,d3
          subq.w    #1,d3
          mulu.w    bytpline,d3
nextcol1: adda.l    d3,a3
          lea.l     put(pc),a1
          move.w    scanlins,d1         ;ZÑhler fÅr Bildzeilen
          subq.w    #1,d1
nextlin1: move.b    (a3)+,(a1)+
          move.b    (a3)+,(a1)+
          move.b    (a3)+,(a1)+
          suba.l    d2,a3               ;eine Zeile hoch
          suba.l    #3,a3
          dbra      d1,nextlin1
          bsr       druckez1
          bsr       lf1_360
          cmpi.b    #"1",format         ;bei Format 1 nur 1 x drucken
          beq.s     zeilfer1
          bsr       druckez1            ;Format 4, 2x drucken
zeilfer1: bsr       lf47_360
          subq.w    #3,colpline         ;wieder drei columns geschafft!
          bmi.s     ende1
          tst.w     $4ee                ;ist Hardcopy noch erwÅnscht?
          bne.s     ende1
          addq.l    #3,a3
          adda.l    d2,a3
          bra       nextcol1
ende1:    bsr       newline
          bra       exit
;---------FORMATE 2 UND 5------------------------------------------------------
normal:   movea.l   log_base,a3
          movea.l   a3,a4               ;a4 enth. maximal zulÑssige  Bildadresse
          clr.l     d2                  ;=logbase + Bytes pro Zeile x Scanlines
          move.w    bytpline,d2
          mulu.w    scanlins,d2
          adda.l    d2,a4
          move.w    bytpline,d2
          clr.l     d4
          clr.l     d6
          move.l    #12,d5
          mulu.w    bytpline,d5
nxtplin2: lea.l     put(pc),a2          ;drei fertige Bytes in den Puffer
          move.w    colpline,d6
nextcol2: moveq.l   #7,d7               ;8 Bits testen
nextrow2: moveq.l   #11,d0              ;12 Bits bearbeiten
nextbyt2: asl.l     #2,d3               ;D3 Zwischenspeicher fÅr Dotkette
          cmpa.l    a3,a4               ;Bildadresse schon Åber Endwert?
          bls.s     no1_2               ;dann keine Bits mehr ausgeben
          btst.b    d7,(a3)             ;prÅfen, ob Bit gesetzt ist (1)
          beq.s     no1_2               ;00 hinten lassen
          ori.l     #3,d3               ;11 hinten anreihen
no1_2:    adda.l    d2,a3               ;darunterliegendes Byte holen
          dbra      d0,nextbyt2
          move.b    d3,2(a2)            ;drei Bytes in den Ausgabepuffer
          lsr.l     #8,d3
          move.b    d3,1(a2)
          lsr.l     #8,d3
          move.b    d3,(a2)
          addq.l    #3,a2
          suba.l    d5,a3               ;wieder in die oberste Zeile zurÅck
          dbra      d7,nextrow2
          adda.l    #1,a3               ;nÑchste Bytekolumne rechts daneben
          dbra      d6,nextcol2
          bsr       druckez2
          bsr       lf1_360
          cmpi.b    #"2",format         ;bei Format 2 nur 1 x drucken
          beq.s     zeilfer2
          bsr       druckez2            ;Format 5, 2 x drucken
zeilfer2: bsr       lf47_360
          cmpa.l    a3,a4               ;Bildadresse schon Åber Endwert?
          bls.s     ende2               ;dann abbrechen
          tst.w     $4ee                ;Hardcopy noch gewÅnscht?
          bne.s     ende2
          adda.l    d5,a3               ;in die nÑchste 12Bit-Zeile
          clr.l     d0
          move.w    colpline,d0
          suba.l    d0,a3               ;an den Zeilenanfang zurÅckstellen
          subq.l    #1,a3
          bra       nxtplin2
ende2:    bsr       newline
          bra       exit
;---------FORMATE 3 UND 6------------------------------------------------------
quer:     clr.l     d1
          movea.l   log_base,a3
          move.w    colpline,d1
          adda.l    d1,a3               ;oben rechts beginnen
          move.w    bytpline,d1
          clr.l     d4
          clr.l     d5
          move.w    bytpline,d5         ;Zeilen mal Spalten
          mulu.w    scanlins,d5
          clr.l     d6
nextrow3: lea.l     put(pc),a2
          move.w    scanlins,d6         ;soviel Zeilen im RAM umrechnen
          subq.l    #1,d6
nxtbyte3: clr.b     d2                  ;Maske auf 1.Bit
          moveq.l   #7,d0               ;8 Bits des Bildschirmbytes testen
nextbit3: asl.l     #3,d3
          tst.w     colpline            ;schon alle sichtbaren col. fertig?
          bmi.s     no1_3               ;dann kein Bit mehr testen
          btst.b    d2,(a3)
          beq.s     no1_3               ;000 hinten lassen
          ori.l     #7,d3               ;111 hinten einfÅllen
no1_3:    addq.b    #1,d2               ;Maske auf nÑchstes Bit
          dbra      d0,nextbit3
          move.b    d3,2(a2)            ;eine Spalte 2x in Puffer (dopp.Dichte!)
          move.b    d3,5(a2)
          lsr.l     #8,d3
          move.b    d3,1(a2)
          move.b    d3,4(a2)
          lsr.l     #8,d3
          move.b    d3,(a2)
          move.b    d3,3(a2)
          addq.l    #6,a2
          adda.l    d1,a3               ;nÑchste Zeile im RAM
          dbra      d6,nxtbyte3
          bsr       druckez3
          bsr       lf1_360
          cmpi.b    #"3",format         ;bei Format 3 nur 1 x drucken
          beq.s     zeilfer3
          bsr       druckez3            ;Format 6, 2 x drucken
zeilfer3: bsr       lf47_360
          subq.w    #1,colpline         ;wieder eine column geschafft!
          bmi.s     ende3
          tst.w     $4ee                ;ist Hardcopy noch erwÅnscht?
          bne.s     ende3
          suba.l    d5,a3               ;nÑchste Reihe links daneben im RAM
          subq.l    #1,a3
          bra       nextrow3
ende3:    bsr       newline
          bra       exit
;---------UNTERPROGRAMME-------------------------------------------------------
out:      move.w    d7,-(sp)
          move.w    #5,-(sp)            ;ein Zeichen an den Drucker
          trap      #gemdos
          addq.l    #4,sp
          rts       
lf47_360: move.w    #27,d7              ;1 x Linefeed 47/360 inch ausgeben
;         ;NEC: move.w #28,d7
          bsr.s     out
          move.w    #43,d7
;         ;NEC: move.w #51,d7
          bsr.s     out
          move.w    #47,d7
          bsr.s     out
          bra.s     newline
lf1_360:  move.w    #27,d7              ;1 x Linefeed 1/360 inch ausgeben
;         ;NEC: move.w #28,d7
          bsr.s     out
          move.w    #43,d7
;         ;NEC: move.w #51,d7
          bsr.s     out
          move.w    #1,d7
          bsr.s     out
newline:  move.w    #13,d7
          bsr.s     out
          move.w    #10,d7
          bsr.s     out
          rts       
druckez1: move.w    scanlins,d1         ;Ausgeben einer Druckzeile im Kleinformat
          move.l    d1,d5
          subq.l    #1,d1
          lea.l     put(pc),a2
          move.w    #27,d7
          bsr       out
          move.w    #42,d7
          bsr       out
          move.w    #39,d7
          bsr       out
          move.b    d5,d7               ;Drucker auf Anzahl Bytes vorbereiten
          bsr       out                 ;lobyte
          ror.l     #8,d5
          move.b    d5,d7
          bsr       out                 ;hibyte
nextdrl1: move.b    (a2)+,d7            ;Daten senden
          bsr       out
          move.b    (a2)+,d7
          cmpi.w    #1,colpline         ;wenn 2 col. öberhang, diese lîschen
          bge.s     drucke11
          clr.l     d7
drucke11: bsr       out
          move.b    (a2)+,d7
          cmpi.w    #1,colpline         ;wenn 1 col. öberhang, diese lîschen
          bgt.s     drucke21
          clr.l     d7
drucke21: bsr       out
          dbra      d1,nextdrl1
          rts       
druckez2: move.w    xresolut,d1         ;Ausgeben einer Druckzeile im Normalformat
          move.l    d1,d4
          subq.l    #1,d1
          lea.l     put(pc),a2
          move.l    #27,d7              ;Drucker vorber.
          bsr       out
          move.l    #42,d7
          bsr       out
          move.l    #38,d7
          bsr       out
          move.b    d4,d7               ;lobyte
          bsr       out
          ror.l     #8,d4               ;hibyte
          move.b    d4,d7
          bsr       out
nextdrl2: move.b    (a2)+,d7
          bsr       out
          move.b    (a2)+,d7
          bsr       out
          move.b    (a2)+,d7
          bsr       out
          dbra      d1,nextdrl2
          rts       
druckez3: move.w    scanlins,d6         ;Ausgeben einer Druckzeile im Querformat
          move.w    d6,d4
          mulu.w    #2,d4               ;es werden 2 x Anzahl Scanlines ausgeg.
          subq.l    #1,d6
          lea.l     put(pc),a2          ;aus Puffer
          move.l    #27,d7              ;Drucker auf Anzahl Bytes vorbereiten
          bsr       out
          move.l    #42,d7
          bsr       out
          move.l    #33,d7
          bsr       out
          move.b    d4,d7
          bsr       out                 ;lobyte
          ror.l     #8,d4
          move.b    d4,d7               ;hibyte
          bsr       out
nextdrl3: move.b    (a2)+,d7
          bsr       out
          move.b    (a2)+,d7
          bsr       out
          move.b    (a2)+,d7
          bsr       out
          move.b    (a2)+,d7
          bsr       out
          move.b    (a2)+,d7
          bsr       out
          move.b    (a2)+,d7
          bsr       out
          dbra      d6,nextdrl3
          rts       
;---------DATENBEREICH---------------------------------------------------------
log_base: .DS.l 1
bytpline: .DS.w 1
scanlins: .DS.w 1
xresolut: .DS.w 1
colpline: .DS.w 1
format:   .DS.b 1
          .EVEN 
menue:    .DC.b 27,"H"
          .DC.b "###########################",13,10
          .DC.b "#  HARDCOPY AUF EPSON LQ  #",13,10
          .DC.b "#    Ω Heinrich Emmerl    #",13,10
          .DC.b "#                         #",13,10
          .DC.b "# Kleinformat  180 dpi: 1 #",13,10
          .DC.b "# Normalformat 180 dpi: 2 #",13,10
          .DC.b "# Querformat   180 dpi: 3 #",13,10
          .DC.b "# Kleinformat  360 dpi: 4 #",13,10
          .DC.b "# Normalformat 360 dpi: 5 #",13,10
          .DC.b "# Querformat   360 dpi: 6 #",13,10
          .DC.b "# Abbruch             : 0 #",13,10
          .DC.b "#                         #",13,10
          .DC.b "# -Bitte Ziffer drÅcken!- #",13,10
          .DC.b "###########################",27,"H",0
          .EVEN 
put:      .DS.l 1512                    ;Puffer fÅr Bildschirmbereich (MenÅ!)
ende:     .EVEN 

