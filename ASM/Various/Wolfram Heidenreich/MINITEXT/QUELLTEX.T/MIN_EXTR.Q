exflos       move.l #44,baumnr
             clr erstobj
             move #8,editobj
             bsr draw
             moveq #1,d5
             move #1,stellen
             move #6,inindex
ef0          bsr binin
             move #6,erstobj
             bsr drawt
             moveq #8,d2
             move d5,d0
             subq #1,d0
             mulu #66,d0
             lea floskeln,a1
             lea (a1,d0.l),a1
             pea (a1)
             bsr txtin
             move d2,erstobj
             bsr drawt
             bsr formdo
             move.l (a7)+,a1
             move d2,d7             ;Exittaste retten
ef3          moveq #8,d2
             bsr lies
             cmp #4,d7
             bhi.s ef1              ; 
             blt etrt               ; OK
             subq #1,d5             ; 
             beq.s ef2
             bra.s ef0
ef1          cmp #10,d5
             beq.s ef0
ef2          addq #1,d5
             bra.s ef0

extast       move.l #48,baumnr
             clr.l erstobj
             bsr rettsch
             bsr baumadress
             move #1,58(a0)
             clr 82(a0)
             lea tastbel,a5
             moveq #1,d7
et0          moveq #14,d2
             bsr txtadr
             move.b (a5,d7.l),(a0)    ;normal
             moveq #15,d2
             bsr txtadr
             add #153,d7
             move.b (a5,d7.l),(a0)   ;alternate
             moveq #16,d2
             bsr txtadr
             move.b 76(a5,d7.l),(a0) ;shift alternate
             sub #153,d7
             bsr drawt               ;zeigen
             bsr formdo
             move d2,-(a7)
             moveq #15,d2
             bsr txtadr
             move.b (a0),d6
             moveq #16,d2
             bsr txtadr
             move.b (a0),d5         ;sh. altern
             move (a7)+,d2
             cmp #10,d2
             blt.s et3              ;'Fertig' oder 'Taste'
             moveq #1,d0
             btst #0,d2             ;'' ?
             bne.s et1              ;ja
             moveq #-1,d0
et1          cmp #12,d2
             blt.s et2              ;alternate
             move d5,d1
             bsr nxtlett
             move d1,d5
             bra.s et3
et2          move d6,d1
             bsr nxtlett
             move d1,d6
et3          add #153,d7
             move.b d6,(a5,d7.l)
             move.b d5,76(a5,d7.l)
             sub #153,d7
             move #4,erstobj
             cmp #1,d2
             beq.s etrt
             cmp #9,d2
             bgt et0
             beq.s et4
             moveq #-1,d1
             bra.s et5
et4          moveq #1,d1
et5          bsr nxttast
             bra et0
etrt         bra holsch

nxttast      lea notast,a0
ntt          add d1,d7
             beq.s ntt1
             cmp #75,d7
             beq.s ntt1
             move.b d7,d0
             bsr suchbyt
             beq.s ntt
             cmp #60,d7
             blt.s ntt0
             moveq #2,d2
             bsr obchange0
             moveq #1,d1
             moveq #3,d2
             bra obchange

ntt0         moveq #3,d2
             bsr obchange0
             moveq #1,d1
             moveq #2,d2
             bra obchange

ntt1         sub d1,d7
             rts

nxtlett      add d0,d1
             cmp.b #27,d1
             bge.s nlt1
             rts
nlt1         cmp.b #31,d1
             ble.s nxtlett
             rts

exbrief      eori #1,autodat
             beq.s eb0
             tst verwnam
             bne mencheck1
             bsr holdat             ;Datei holen
             beq mencheck1          ;Datei ist geladen
ebaus        eori #1,autodat
ebret        rts
eb0          bra mencheck0

exaufn       tst verwnam
             bne.s ea
             bsr holdat
             bne.s ebret
ea           moveq #0,d7            ;Objekte freigeben
             bra.s ess

exsuch       tst verwnam
             bne.s es
             bsr holdat
             bne.s ebret
es           moveq #8,d7
ess          bsr datform
             moveq #0,d6
             bsr rettsch
es0a         bsr kileintr
es0          bsr drawt
             bsr formdo
             move #2,erstobj
             cmp #14,d2
             beq esret
             cmp #20,d2
             bne es3
             moveq #0,d4            ;offset
             moveq #5,d2            ;Objektnr.
             bsr welche
             beq.s es1
             moveq #13,d4
             moveq #6,d2
             bsr welche
             beq.s es1
             moveq #35,d4
             moveq #8,d2
             bsr welche
             beq.s es1
             moveq #43,d4
             moveq #9,d2
             bsr welche
             bne esret
es1          move d4,zeile
             move d2,zeinr
             bsr vergleich
             beq.s es2              ;gefunden
es1a         lea nichtda,a2
             bsr formalert
             bsr kileintr
             clr.l nxtstart
             bra.s es0
es2          move.l a4,nxtstart
             bsr zeigeintr
             move d5,d6
             moveq #0,d7
             bsr datform
             bsr baumadress
             move.l #512,d0
             move.l #$50000,(a0,d0.l)
             bra es0
es3          cmp #19,d2
             bne.s es4
             bsr aufnahme
             bra es0
es4          cmp #22,d2
             bne es6
             moveq #0,d4            ;offset
             moveq #5,d2            ;Objektnr.
             bsr welche
             bne esret
             bsr vergleich
             beq.s es5              ;gefunden
             lea nichtda,a2
             bsr formalert
es4a         bsr kileintr
             bra es0
es5          move.l a4,a0
             move.l memtop,a1
             move.l #-300,d0
             add.l d0,memtop
             sub.l d0,a0
             bsr transfer1
             move d5,d6
             bra.s es4a
es6          cmp #15,d2
             blt esdisk
             bne.s es7
             moveq #0,d6
             bra.s es10
es7          cmp #17,d2
             blt.s es8
             bne.s es9
             subq #1,d6
             bpl.s es10
             moveq #0,d6
             bra.s es10
es8          addq #1,d6
             bra es10
es9          cmp #18,d2
             bne.s es11
             move.l memtop,d6
             sub.l datstart,d6
             divu #300,d6
             beq.s es10
             subq #1,d6
es10         move d6,d0
             mulu #300,d0
             add.l datstart,d0
             cmp.l memtop,d0
             blt.s es10a
             move.l memtop,d0
             sub.l #302,d0
             cmp.l datstart,d0
             blt es0a
es10a        move.l d0,a4
             bsr zeigeintr
             bra es0
es11         cmp #23,d2
             bne.s es12
             bsr savedat
             bra es0
es12         move d6,d5
             move d6,d0
             addq #1,d0
             mulu #300,d0
             add.l datstart,d0
             cmp.l memtop,d0
             bgt es1a
             move zeile,d4
             move zeinr,d2
             bsr welche
             bne es1a
             bsr vg
             bne es1a
             bra es2
esdisk       bsr holsch
             bsr openverw
             bne.s esret
             lea neuverw,a2
             bsr suchfile
             cmp #2,d0
             beq.s esret
             move d0,-(a7)
             move.l a5,a0
             lea verwnam,a1
             bsr copy
             move (a7)+,d0
             bra liesdat
esret        bsr baumadress
             move.l #512,d0
             move.l #8,(a0,d0.l)
             bra holsch

statprg      pea (a6)
             bsr rettsch
             move.l #56,baumnr
             clr.l erstobj
             moveq #3,d2
             moveq #11,d7
             bsr namin
             move #6,stellen
             moveq #20,d2
             bsr txtadr
             move.l a0,a5           ;Adresse und
stp          clr d0
             move.b (a5),d0
             move d0,d6             ;Disk Merken
             sub #64,d0
           getdfree d0,puffer
             lea puffer,a0
             move.l (a0)+,d5        ;Freie Cluster
             move 6(a0),d0          ;Bytes/Sektor
             mulu 10(a0),d0         ; * Sektoren/Cluster
             mulu d0,d5
             move #14,inindex
             bsr binin
             move.l free,d5
             move #15,inindex
             bsr binin
stp1         move #16,inindex
             moveq #82,d1
             bsr selindex           ;welcher Text ist gewÑhlt
             lsl.l #2,d0
             move.l d0,d7           ;Index sichern
             lea txtstart,a0
             lea (a0,d0.l),a0
             move.l (a0)+,a6
             cmp.l (a0),a6
             bne.s stp2             ;Datei ist im Speicher
             moveq #0,d5
             bsr binin
             addq #1,inindex
             bsr binin
             addq #1,inindex
             bsr binin
             bra.s stp7
stp2         move.l aktend,d5
             cmp.l sel,d7
             beq.s stp3             ;aktueller Text
             move.l (a0),d5
stp3         sub.l a6,d5
             bsr binin
             addq #1,inindex
             move 44(a6),d5
             ext.l d5
             subq #1,d5
             bsr binin
             move.l a6,a0
             move.l (a0)+,d4        ;SeitenlÑnge
             sub.l (a0)+,d4         ;minus RÑnder
             sub.l (a0)+,d4
             sub.l (a0)+,d4
             sub.l (a0),d4
             add.l d4,d4            ;*2=SeitenlÑnge
             lea 68(a6),a6
             bsr suchseite
stp6         addq #1,inindex
             bsr binin
stp7         bsr drawt
             bsr formdo0
             move #13,erstobj
             cmp #3,d2
             blt.s change           ;OK
             cmp #10,d2
             bhi.s change           ; oder 
             bra stp1
change       bsr obchange0
             cmp #1,d2
             beq stprt
             cmp #19,d2
             bne.s stp8
             cmp #80,d6
             beq stp
             addq #2,d6
stp8         cmp #65,d6
             beq stp
             subq #1,d6
             move.b d6,(a5)
             bra stp
stprt        move.l (a7)+,a6
             bra holsch

suchseite    moveq #1,d1
             bsr txtort1
             moveq #0,d5
             move -24(a6),d1        ;letzte Zeile
             subq #1,d1
stp4         addq #1,d5             ;Seitenzahl
             move d4,d3
stp5         add.l d0,a0
             move (a0)+,d0
             subq #1,d1
             bne.s stp5a
             rts
stp5a        sub 2(a0),d3
             bgt.s stp5
             bra.s stp4

namin        clr.l idfl
             lea txtstart,a3
             lea name+60,a4
nm           lea name+480,a1
             move.l (a3)+,d0
             cmp.l (a3),d0
             beq.s nm1
             addq #1,idfl
             move allfl,grkl
             move.l a4,a1
nm0          cmp.b #92,-(a1)
             bne.s nm0
             addq.l #1,a1
nm1          bsr txtin
             adda.l #60,a4
             addq #1,allfl
             addq.l #1,d2
             cmp d7,d2
             bne.s nm
             rts

datform      move.l #60,baumnr
             clr erstobj
             move #5,editobj
             bsr baumadress
             lea verwkn,a2
df           move (a2)+,d2
             mulu #24,d2
             move d7,10(a0,d2.l)
             cmp #552,d2
             bne.s df
             lea vdatnam,a1
             moveq #3,d2
             bra formtxt

closedat     bsr savedat            ;Datei speichern
             clr verwnam            ;anmerken keine Datei
             move.l memend,memtop
             tst sel                ;Text aktiv ?
             bmi ok
             move.l #$10000,d0
             lea txtstart+4,a2
             add.l sel,a2
             move.l (a2),a0
             add.l d0,free
             bra transfer           ;Speicher wieder freigeben

holdat       bsr openverw
             bne fehler
             cmp.l #$10400,free
             ble fehler             ;zu wenig Speicher
             lea neuverw,a2
             bsr suchfile           ;Datei auf Disk ?
             cmp #2,d0
             beq fehler             ;Abbruch
             move d0,-(a7)          ;Flag fÅr Datei auf disk
             move.l #$10000,d0
             sub.l d0,free
             tst sel                ;Text aktiv ?
             bmi.s eb1
             lea txtstart+4,a2
             add.l sel,a2
             move.l (a2),a0
             neg.l d0
             bsr transfer           ;Platz schaffen
eb1          move.l a5,a0
             lea verwnam,a1
             bsr copy               ;Pfad + Namen Åbertragen
             move (a7)+,d0
liesdat      beq.s eb2              ;Datei wird geladen
             move.l datstart,a1
             bra.s eb3
eb2          bsr openin             ;Datei holen
             bsr closedisk
             move.l diskpuff,a0
             move.l bytes,d0
             move.l datstart,a1
             bsr copy1              ;Kopieren
eb3          clr (a1)+
             move.l a1,memtop       ;Zeiger auf Ende setzen
             lea verwnam,a0
             bsr nam_pfad           ;Pfadende markieren
             move.l a1,a0
             lea vdatnam,a1
             bsr copy               ;eigentlichen Namen isolieren
             bra ok

openverw     lea filesel+147,a1
             lea name+480,a5
             moveq #4,d6
             bra diskopen

savedat      lea verwnam,a0
             bsr setpfad
             lea vdatnam,a0
             bsr createfile
             move.l memtop,d2
             move.l datstart,a2
             sub.l a2,d2
             sub.l #2,d2
             bsr writefile
             bsr closedisk
           setdrv aktdisk
           chdir pfad
             rts

filenam      bsr txtadr
             move d1,d0
fin0         bsr copy1
             move.b #13,(a1)+
             move.b #10,(a1)+
             rts

uebernehme   move.l a4,a1
             lea verwlist,a3
ea2          move (a3)+,d2          ;Objektnummer
             bne.s uebn
             rts
uebn         move (a3)+,d1          ;Bytezahl
             bsr filenam            ;Eingabe öbertragen
             bra.s ea2

kileintr     lea verwlist,a3
ea4          move (a3)+,d2
             bne.s ke
             rts
ke           addq.l #2,a3
             bsr txtadr
             move.b #64,(a0)        ;EintrÑge lîschen
             bra ea4

zeigeintr    lea verwlist,a3
ze           move (a3)+,d2
             bne.s ze1
             rts
ze1          bsr txtadr
             move (a3)+,d0
             move.l a4,a1
             exg.l a1,a0
             bsr copy1
             addq.l #2,a0
             move.l a0,a4
             bra.s ze

aufnahme     moveq #5,d2            ;Aufnehmen
             bsr welche
             beq.s aun
             rts                    ;kein Textname
aun          move.l a0,a3
             bsr sort               ;Platz in Datei suchen
             move d5,d6
             bsr uebernehme
             move #2,erstobj
             bra kileintr

vergleich    move.l datstart,a4
             moveq #0,d5
vg           tst (a4)
             beq fehler
             lea (a4,d4.l),a1       ;Adresse in Tabelle
             move.l a0,a2           ;Eingabe
vg0          move.b (a2)+,d0
             beq ok                 ;gefunden
             cmp.b #63,d0
             bne.s vg1
             addq.l #1,(a1)
             bra.s vg0
vg1          cmp.b (a1)+,d0
             beq.s vg0
             lea 300(a4),a4
             addq #1,d5
             bra.s vg               ;nÑchster Datensatz

alphvor      move.l datstart,a4
             moveq #0,d5
av           tst (a4)
             beq fehler             ;Tabelle durchsucht
             lea (a4,d4.l),a1       ;Tabellenwort
             move.l a3,a0           ;Vergleichswort
             move d3,d1
             subq #1,d1
av0          move.b (a0)+,d0
             cmp.b (a1)+,d0
             dbne d1,av0
             bmi fehler
             beq ok                 ;öberschreiben
             lea 300(a4),a4         ;nÑchster Eintrag
             addq #1,d5             ;Nummer des Eintrages
             bra.s av               ;PrÅfen

sort         moveq #11,d3
             moveq #0,d4
             bsr alphvor
             beq.s srt              ;éndern
             move.l a4,a0
             move.l memtop,a1
             move.l #300,d0
             add.l d0,memtop
             bsr transfer1          ;Platz schaffen
srt          rts

welche       bsr txtadr
             cmp.b #0,(a0)
             beq fehler
             cmp.b #64,(a0)
             beq fehler
             bra ok

 end
 