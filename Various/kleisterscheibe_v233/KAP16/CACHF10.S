*********************
* CACHEADD - written & Ω 1989 by Claus Brod
*
* Aus dem SCHEIBENKLEISTER, dem etwas anderen Floppy- und Harddiskbuch
*
* - erweitert den internen GEMDOS-Cachespeicher
* - Åbernimmt Anzahl der zusÑtzlichen Puffersektoren und Art der Erweiterung
*   (F: FAT-Puffer, D:Daten/Dir-Puffer, B:Beides) aus dem Dateinamen
* - im B-Modus sollte die Anzahl der Puffersektoren gerade sein,
*   da diese zwischen FAT- bzw. DIR/DATA-Puffer aufgeteilt werden
* - Achtung! Im gleichen Verzeichnis darf sich keine Datei befinden, die
*   ebenfalls dem Muster "CA*.PRG" entspricht!
* 1.10.89:
*   Holt sich Puffergrîûe nach ATARI-Richtlinien vom AHDI3.x (wenn installiert)
*   Sektorpuffergrîûe auch via Dateiname einstellbar
*   Option zum Rauswerfen der alten Pufferliste
*
* (Neues) Format des Dateinamens:
*       CACyTxxx
*         ||||||
*         |||---------Anzahl der zusÑtzlichen Puffersektoren
*         ||----------Puffertyp (D/F/B)
*         |-------------"H": Puffergrîûe = 512 Bytes bzw. von AHDI zu erfahren
*         |             Ziffer von 1..7: Puffergrîûe von Hand einstellen
*         |             (1 = 512 Bytes, 2 = 1024 B., 3 = 2048 B., 4 = 4096 B.,
*         |              5 = 8192 B., 6 = 16384 B., 7 = 32768 B.)
*         --------------"C": alte Pufferliste einbinden
*                       sonst: alte Pufferliste wegwerfen, nur neue
*                       installieren
*
**********************

machlos:
                bra     startmich
verketten:
                movea.l A0,A3           ; Pufferstart merken
                move.l  D7,D1
                subq.w  #1,D1           ; minus eins fÅr dbf
nxtbcb:
                movea.l A0,A2           ; Zeiger retten
                lea     20(A0,D2.w),A0  ; Zeiger auf nÑchsten Pufferblock
                move.l  A0,(A2)         ; in vorigen Block schreiben
                move.w  #-1,4(A2)       ; b_neg1 setzen
                clr.l   8(A2)
                clr.l   12(A2)
                lea     20(A2),A1       ; Zeiger auf Puffersektor
                move.l  A1,16(A2)       ; setzen
                dbra    D1,nxtbcb

                move.l  (A4),D0         ; alten bufl-Inhalt holen
                cmp.b   #'C',D6         ; alte Pufferliste behalten?
                beq.s   einhaengen      ; ja
                moveq   #0,D0           ; nein, Liste mit Nullzeiger abschlieûen
einhaengen:
                move.l  D0,(A2)         ; Liste abschlieûen
                move.l  A3,(A4)         ; und Pufferliste verketten

                cmp.b   #'B',D3         ; beide Pufferlisten erweitern?
                bne.s   beenden         ; nein, beenden
                moveq   #0,D3           ; Flag lîschen
                addq.l  #4,A4           ; nÑchste bufl-Variable
                bra.s   verketten

beenden:
                clr.w   -(SP)           ; kein Fehler
                move.l  D4,-(SP)        ; LÑnge des Puffers + ProgrammlÑnge
                move.w  #49,-(SP)
                trap    #1              ; Ptermres


* ab hier wird alles von Puffern Åberschrieben
bufsize:
                DC.W -1

puffer:
                DC.B 13,10,"CACHEADD - Ω 1989 Claus Brod",13,10
                DC.B "Aus dem SCHEIBENKLEISTER, dem etwas",13,10
                DC.B "anderen Floppy- und Harddiskbuch.",13,10,0

fname2:
                DC.B "\AUTO\"
filename:
                DC.B "CA*.PRG",0

sizemsg:
                DC.B "xxx",0
size2:          DC.B " neue Puffersektoren, Typ "
typ:            DC.B 0,13,10,0

fehlermsg:
                DC.B "CACHEADD: Fehler!",13,10,0
                EVEN
****************
* startmich: Hier geht's los
****************
startmich:
                movea.l 4(SP),A5        ; Basepageadr. in a5
                move.l  4(A5),D0        ; Ende des reservierten Bereichs holen
                sub.l   (A5),D0         ; minus Start
                movea.l D0,A6           ; in a6 merken
                lea     256(A6),A6      ; +256 (Basepage)

                move.w  #$C9,D0
                trap    #2
                move.w  D0,autoflag     ; sind wir im AUTO-Ordner?

                clr.l   -(SP)           ; In den Supermodus
                move.w  #32,-(SP)       ; SUPER
                trap    #1
                addq.l  #6,SP
                move.l  D0,-(SP)        ; alten SP gleich retten

                lea     puffer(PC),A0   ; Einschaltmeldung ausgeben
                bsr.s   cconout

                bsr     getparam        ; Parameter aus Dateinamen holen
                lea     sizemsg(PC),A0  ; Grîûe und Typ ausgeben
                bsr.s   cconout
                lea     size2(PC),A0
                bsr.s   cconout

                lea     puffer(PC),A0   ; Startadresse der Puffer
                lea     $04B6.w,A4      ; Zeiger auf bufl[1]
                cmp.b   #'D',D3         ; DIR/DATA-Puffer erweitern?
                beq.s   bufreserve      ; ja, weiter
                subq.l  #4,A4           ; sonst Zeiger auf bufl[0] deuten lassen

bufreserve:
                tst.w   D7              ; Soll Puffer reserviert werden?
                beq.s   nixwars         ; nein, raus
                move.w  D7,D4
                ext.l   D4

                move.w  bufsize(PC),D2  ; Sektorgrîûe schon per Dateiname gesetzt?
                bpl.s   altes_ahdi      ; ja

                move.w  #512,D2         ; Standard-Sektorgrîûe
                movea.l $0516.w,A0      ; punptr holen
                lea     82(A0),A1
                cmpi.l  #"AHDI",(A1)    ; p_cookie = "AHDI"?
                bne.s   altes_ahdi      ; nein
                cmpa.l  4(A1),A1        ; stimmt auch der Zeiger?
                bne.s   altes_ahdi      ; nein
                move.w  92(A0),D2       ; maximale Sektorgrîûe holen

altes_ahdi:
                move.w  D2,D0
                add.w   #20,D0          ; Sektorgrîûe + Verwaltungsoverhead
                mulu    D0,D4           ; Puffergrîûe in Bytes
                add.l   #puffer-machlos+256,D4
                cmpa.l  D4,A6           ; haben wir Åberhaupt soviel?
                ble.s   nixwars         ; aber nein!
                lea     puffer(PC),A0   ; Zeiger auf Pufferstart
                cmp.b   #'B',D3         ; beide Puffer erweitern?
                bne     verketten       ; nein, los geht's
                lsr.w   #1,D7           ; Anzahl der Sektoren durch 2
                bra     verketten

*********************
* nixwars: Keinen Puffer reservieren
*********************
nixwars:
                lea     fehlermsg(PC),A0
                bsr.s   cconout         ; Fehlermeldung ausgeben
                clr.w   -(SP)
                trap    #1

*********************
* cconout: Gibt String aus
* IN: a0.L Stringadresse
*********************
cconout:
                move.l  A0,-(SP)
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP
                rts

*********************
* getparam: Parameter aus dem Dateinamen holen
* Routine von Lutz Preûler
*********************
getparam:
                clr.w   -(SP)           ; Prg-Datei suchen
                pea     filename(PC)    ; ->'CACH*.PRG'
                move.w  autoflag(PC),D0 ; sind wir im AUTO-Ordner?
                beq.s   noauto          ; nein, weiter
                move.l  #fname2,(SP)    ; sonst: '\AUTO\CACH*.PRG'
noauto:
                move.w  #$4E,-(SP)      ; FSFirst
                trap    #1              ; GEMDOS
                addq.l  #8,SP
                tst.w   D0              ; Datei gefunden?
                bne.s   fehler          ; nicht gefunden -> Default-Werte

                move.w  #47,-(SP)       ; Fgetdta, DTA-Adresse holen
                trap    #1              ; GEMDOS
                addq.l  #2,SP
                addi.l  #30+2,D0        ; Zeiger auf Dateiname (nach 'CA')
                movea.l D0,A0           ; in a0
analyse:
                clr.w   D3
                move.b  (A0)+,D6        ; alte Pufferliste aushÑngen oder nicht?
                move.b  (A0)+,D3        ; Kennzeichen fÅr Puffergrîûe
                cmp.b   #'H',D3         ; "H"?
                beq.s   von_alleine     ; ja
                sub.w   #'0',D3         ; ASCII -> Zahl
                move.w  #256,D0
                lsl.w   D3,D0
                move.w  D0,bufsize      ; Puffergrîûe merken
von_alleine:
                move.b  (A0)+,D3        ; Puffertyp holen
                move.b  D3,typ          ; und in String schreiben
                moveq   #3,D0           ; hîchstens drei Bytes
                moveq   #0,D7           ; Register lîschen (Grîûe)
                clr.w   D2              ; (Byteinhalt)
                lea     sizemsg(PC),A1  ; Zeiger auf String
eingloop:
                move.b  (A0),D2         ; Byte auslesen
                cmpi.b  #'0',D2         ; < '0' ?
                blt.s   keineziff
                cmpi.b  #'9',D2         ; > '9' ?
                bgt.s   keineziff
                addq.l  #1,A0           ; Adr. erhîhen
                mulu    #10,D7          ; akt. Wert * 10
                add.l   D2,D7           ; + neue Ziffer
                subi.l  #'0',D7
                cmp.b   #'0',D2
                bne.s   znicht0
                tst.w   D7              ; fÅhrende 0?
                beq.s   erste0
znicht0:
                move.b  D2,(A1)+        ; nein: Ziffer in String speichern
erste0:         dbra    D0,eingloop     ; nÑchste Ziffer
keineziff:
                clr.b   (A1)            ; Nullbyte an String anhÑngen
                rts
fehler:
                moveq   #0,D7
                rts

autoflag:
                DC.W 0
                END
