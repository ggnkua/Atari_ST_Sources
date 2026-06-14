****************************************************
* Dieses Programm produziert eine Text-Hardcopy    *
* d.h. Buchstaben werden vom Schirm gelesen und    *
* im ASCII-Format an den Drucker gesandt!          *
* Geht nur mit 80 Zeichen/Zeile-Modus d. Druckers! *
* Start durch DrÅcken v. Alt/Help (wie gewîhnlich) *
* (C)1988 Stefan Becker. Rechner: Atari ST         *
****************************************************

***************
* Trap-Equals *
***************
Cconws          Equ     9
Gemdos          equ     1
Bios            equ     13
Xbios           equ     14
Ptermres        Equ     $31
Bconin          Equ     2
Getrez          Equ     4
Supexec         Equ     38

**************
* Konstanten *
**************

stacksize       equ             1000

basepag         equ             4
text_sg         equ             12
data_sg         equ             20
bss_sg          equ             28

version         equ             6               * Version 1.[6]
font3           equ             8               * Offset f. Font 3 (16X8)
fontdata        equ             76              * Offset f. Font-Daten

vblqueue        equ             $456
ahflag          equ             $4EE            * Alt/Help-Flagge
vchiph          equ             $FF8201         * Videochipadresse
vchipl          equ             $FF8203         * Videochipadresse


printstr:       macro
                move.l          #\1,-(a7)
                move.w          #Cconws,-(a7)
                trap            #Gemdos
                addq.l          #6,a7
                endm
*
* Hauptprogramm
*
                move.l          basepag(a7),a0      * Startadresse des Programms nach a0
                move.l          #$100,d0            * ProgrammlÑnge: 256 Bytes Base-Page
                add.l           text_sg(a0),d0      * + LÑnge des Text-Segments
                add.l           data_sg(a0),d0      * + LÑnge des Data-Segments
                add.l           bss_sg(a0),d0       * + LÑnge des BSS-Segments
                lea             stop(pc),a7         * Stack setzen
                clr.w           -(a7)               * Return-Code 0
                move.l          d0,-(a7)            * Speicherbedarf
                move.w          #Ptermres,-(a7)
                bsr.s           inithcpy            * Hardcopy einklinken
                trap            #Gemdos             * ausfÅhren => Programmende
*
* Hardcopy initialisieren
*
inithcpy:       move.w          #Getrez,-(a7)   * Hires?
                trap            #Xbios
                addq.l          #2,a7
                cmp.w           #2,d0
                beq.s           highres         * Ja => O.K.
                printstr        reserr          * Fehlermeldung ausgeben
                move.w          #2,-(a7)
                move.w          #Bconin,-(a7)
                trap            #Bios
                addq.l          #4,a7
                clr.w           -(a7)               * Pterm
                trap            #Gemdos
                
highres:        dc.w            $a000                   * Line-A-Init
                move.l          font3(a1),a1            * 16X8-Font
                move.l          fontdata(a1),fontadr    * Daten
                pea             setdump         * Setdump im
                move.w          #Supexec,-(a7)  * S-Mode starten
                trap            #Xbios
                addq.l          #6,a7
                printstr        hello
                bsr.s           fillbuf
                bsr.s           wait
                rts

wait:           move.l          #$50000,d0      * kurz warten
wloop:          subq.l          #1,d0
                bne.s           wloop
                rts

fillbuf:        lea             txtbuffer,a0
                move.w          #1999,d0
fl1:            move.b          #' ',(a0)+
                dbf             d0,fl1
                rts

setdump:        move.l          #vblrout,d0     * VBL-Routine
                move.l          vblqueue,a0     * einhÑngen
                move.l          (a0),oldrout    * (Brutalo-
                move.l          d0,(a0)         * Methode)
                cmp.l           #0,oldrout      * War hier schon was?
                bne.s           dawarwas        * Ja
                move.l          #dawarwas,oldrout       * Nee => auf RTS
dawarwas:       rts

vblrout:        bra.s           hinueber

                dc.b            "HDTX"          * Hier Hardcopytxt
                dc.l            txtbuffer       * Adresse des Puffers

hinueber:       tst.w           ahflag          * VBL-Routine
                bne.s           nixlos          * kein Alt/Help
                bsr.s           printscr        * Drucken...
                move.w          #-1,ahflag      * Flagge zurÅck
                rts
nixlos:         move.l          oldrout,a0      * alte Routine
                jmp             (a0)            * starten

printscr:       clr.w           txtoffset
                move.w          #-1,prflag      * Drucker-Default= Da
                btst            #0,$fffa01      * Drucker bereit?
                beq.s           prready         * Ja!
                clr.w           prflag          * Kein Drucker da.
prready:        move.b          vchiph,scradr+1 * Videoadresse lesen
                move.b          vchipl,scradr+2
                move.b          #13,d0          * Neue Zeile aufn Drucker
                bsr.s           printer         * + Puffer leeren
                move.b          #10,d0          * (CR/LF)
                bsr.s           printer
                clr.w           cury            * Curx=0
yloop:          clr.w           curx            * Cury=0
xloop:          bsr             charnr          * Char. dort vorh.?
                cmp.b           #32,d0
                blt.s           tospace
                cmp.w           #-1,d0          * Ja/Nein?
                bne.s           skip            * Ja => weiter
tospace:        move.w          #' ',d0         * auf SPACE setzen
skip:           move.w          curx,d1
                lea             puffer+1,a0     * Zeichen in Puffer rein
                move.b          d0,0(a0,d1.w)   * schreiben
                addq.w          #1,curx         * Curx++
                cmp.w           #80,curx        * Curx=80?
                bne.s           xloop           * Nein => Nochmal
                bsr             prbuffer        * Puffer drucken
                bsr             insbuffer       * Puffer in Textseite
                addq.w          #1,cury         * Cury++
                cmp.w           #25,cury        * Cury=25?
                bne.s           yloop           * Nein => Nochmal
                move.b          #10,d0          * (LF ist noch fÑllig)
                bsr.s           printer
                rts                             * Das war's!

**********************************************************
* Hardwaredruckerausgaberoutine, Zeichen in d0 Åbergeben *
* Aus dem VBL kann ein Aufruf von Cprnout nicht sicher   *
* erfolgen!                                              *
**********************************************************
printer:        cmp.w           #-1,prflag      * Drucken?
                bne.s           noprinting      * Nein!
                btst            #0,$fffa01      * Drucker bereit?
                bne.s           printer         * Nein => warten
                move.w          sr,status       * 68000-Status retten
                or              #$0700,sr       * Interrupts aus
                lea             $ff8800,a1      * Soundchip
                move.b          #$07,(a1)       * Register 7
                move.b          (a1),d1
                or.b            #$80,d1         * Port B
                move.b          d1,2(a1)
                move.b          #$0f,(a1)
                move.b          d0,2(a1)        * Zeichen ausgeben
                move.b          #$0e,(a1)
                move.b          (a1),d1
                and.b           #$df,d1         * STROBE low
                move.b          d1,2(a1)
                or.b            #$20,d1         * STROBE high
                move.b          d1,2(a1)
                move.w          status,sr       * Interrupts freigeben
noprinting:     rts

*******************************************************
* Sucht einen Buchstaben an den Koordinaten curx,cury *
* Nummer danach in d0.w. d0.w=-1 => nix gefunden.     *
*******************************************************
charnr:         bsr             tiptest
                cmp.w           #-1,d0
                beq             dannicht
                rts
dannicht:       move.w          cury,d0         * Screenadresse:
                mulu            #1280,d0        * cury*1280+curx+scradr
                move.l          scradr,a0
                adda.w          d0,a0
                move.w          curx,d0
                adda.w          d0,a0           * Screenadresse -> a0
                move.w          #15,d4
tstversch:      move.l          fontadr,a1      * Fontptr -> a1
                clr.w           d0              * BuchstzÑhler -> d0
tstnchar:       move.l          a0,a2           * Normale Buchstaben
                move.l          a1,a3           * suchen...
                move.w          #15,d1          * 16 mal
testnlp:        cmpm.b          (a2)+,(a3)+     * Screen=Font?
                bne.s           tstichar        * Nein
                adda.l          #79,a2          * Screenadresse+=80
                adda.w          #255,a3         * Fontadresse+=256
                dbf             d1,testnlp
                move.w          d4,tip
                rts                             * Norm. gefunden! Nr. in d0
tstichar:       move.l          a0,a2           * Inverse Buchstaben
                move.l          a1,a3           * suchen...
                move.w          #15,d1
testilp:        move.b          (a2),d2
                not.b           d2
                cmp.b           (a3),d2
                bne.s           falscher
                adda.l          #80,a2
                adda.w          #256,a3
                dbf             d1,testilp
                move.w          d4,tip
                rts                             * Inv. gefunden! Nr. in d0
falscher:       addq.w          #1,a1           * NÑchsten Buchstaben
                addq.w          #1,d0
                cmp.w           #256,d0         * =Chr(256)?
                bne.s           tstnchar        * Nein => Weiter
                cmp.w           #24,cury        * Letzte Zeile?
                beq.s           nixmehr         * Ja => Das war's
                adda.w          #80,a0          * Auf Verschiebung testen
                dbf             d4,tstversch
nixmehr:        move.w          #-1,d0
                rts                             * Nix gefunden => d0=-1


***************************************************************
* Sucht einen Buchstaben an den Koordinaten curx,cury         *
* mit dem Vertikaloffset "Tip" (letzter erfolgreicher Offset) *
* Nummer danach in d0.w. d0.w=-1 => nix gefunden.             *
***************************************************************
tiptest:        move.w          cury,d0         * Screenadresse:
                mulu            #1280,d0        * cury*1280+curx+scradr
                move.l          scradr,a0
                adda.w          d0,a0
                move.w          curx,d0
                adda.w          d0,a0           * Screenadresse -> a0
                move.w          #15,d1
                move.w          tip,d0
                sub.w           d0,d1
                mulu            #80,d1
                adda.w          d1,a0           * + Tip*80
stversch:       move.l          fontadr,a1      * Fontptr -> a1
                clr.w           d0              * BuchstzÑhler -> d0
stnchar:        move.l          a0,a2           * Normale Buchstaben
                move.l          a1,a3           * suchen...
                move.w          #15,d1          * 16 mal
estnlp:         cmpm.b          (a2)+,(a3)+     * Screen=Font?
                bne.s           stichar         * Nein
                adda.l          #79,a2          * Screenadresse+=80
                adda.w          #255,a3         * Fontadresse+=256
                dbf             d1,estnlp
                rts                             * Norm. gefunden! Nr. in d0
stichar:        move.l          a0,a2           * Inverse Buchstaben
                move.l          a1,a3           * suchen...
                move.w          #15,d1
estilp:         move.b          (a2),d2
                not.b           d2
                cmp.b           (a3),d2
                bne.s           alscher
                adda.l          #80,a2
                adda.w          #256,a3
                dbf             d1,estilp
                rts                             * Inv. gefunden! Nr. in d0
alscher:        addq.w          #1,a1           * NÑchsten Buchstaben
                addq.w          #1,d0
                cmp.w           #256,d0         * =Chr(256)?
                bne             stnchar         * Nein => Weiter
ixmehr:         move.w          #-1,d0
                rts                             * Nix gefunden => d0=-1

prbuffer:       cmp.w           #-1,prflag      * Drucken?
                bne             bufend          * Nein!
                lea             puffer,a0       * Puffer drucken
prbufl:         move.b          (a0)+,d0
                beq             bufend          * Pufferende? Ja!
                bsr             printer         * drucken
                bra.s           prbufl          * nÑchstes Zeichen
bufend:         rts

insbuffer:      lea             puffer+1,a0     * Puffer in Textseite
                lea             txtbuffer,a1    * Åbernehmen
                adda.w          txtoffset,a1
                move.w          #79,d0
icl1:           move.b          (a0)+,(a1)+
                dbf             d0,icl1
                add.w           #80,txtoffset   * Offset+=80
                rts

txtoffset:      dc.w            0               * Offset f. Textseite
prflag:         dc.w            0               * -1=Printer war bereit
tip:            dc.w            0               * letzter Vertikaloffset
curx:           dc.w            0               * aktuelle X-Position
cury:           dc.w            0               * aktuelle Y-Position
status:         dc.w            0               * 68000-Status
oldrout:        dc.l            0               * Adresse d. alten VBL-Rout.
scradr:         dc.l            0               * aktuelle Bildschirmadr.
fontadr:        dc.l            0               * Fontadresse

hello:          dc.b            13,10
                dc.b            "Text-Hardcopy 1.","0"+version
                dc.b            " resident! (C)1988 Stefan Becker"
                dc.b            " & Ulrich Lemke. ",13,10,0

reserr:         dc.b            13,10
                dc.b            "Text-Hardcopy lÑuft leider nur in High"
                dc.b            "-Res!!!",13,10
                dc.b            "Bitte Taste drÅcken!",13,10,0

puffer:         dc.b            10
                dc.b            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                dc.b            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                dc.b            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                dc.b            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                dc.b            13,0

                even
stack:          dsbss.b         stacksize
stop:
txtbuffer:      dsbss.b         2000
* This is the end...

