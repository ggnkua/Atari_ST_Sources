* Ladi V1.1:
* L„d ein bel. Prg. in den Speicher und ermittelt die Bereichsadressen
* und die Bereichsl„ngen.
* Man kann jetzt den Templemon aufrufen, denn man hat die Adressangaben.
*
* Von Martin Rastetter im Januar 1989.

cnecin          .equ    $8
cconws          .equ    $9
cconrs          .equ    $a
dsetdrv         .equ    $e
dsetpath        .equ    $3b
mshrink         .equ    $4a
pexec           .equ    $4b

gemdos          .equ    $1


text
        move.l  4(a7),a6        * Basepage-Adr -> a6
        move.l  $c(a6),d0       * TEXT-L„nge -> d0
        add.l   $14(a6),d0      * + DATA-L„nge
        add.l   $1c(a6),d0      * + BSS-L„nge
        addi.l  #$100,d0        * + 256 Bytes Basep.-L„nge

        lea     0(a6,d0.l),a7   *Stack ans Ende des (sp„ter) reservierten
*                                Speicherbereichs (Ende des BSS)

        move.l  d0,-(a7)        * Summe -> Stack
        pea     (a6)            * Basep.-Adr. -> Stack
        clr.w   -(a7)           * 0-word -> Stack
        move.w  #mshrink,-(a7)
        trap    #gemdos
        adda.l  #12,a7          * Stack zurcksetzen
main:
        lea     intro,a5        * Zeiger auf Ausgabetext -> a5
        bsr     ausgabe         * Text ausgeben
wiederh:
        lea     frage4,a5
        bsr     ausgabe
        lea     bereich,a6
        bsr     eingabe         * Liest Path+Filename ein
        movea.l a6,a4
        lea     frage5,a5
        bsr     ausgabe
        lea     bereich_2,a6
        bsr     eingabe

        lea     sicher,a5       * Ausg.-Text-Adr. -> a5
        bsr     ausgabe         * Text ausg.
        bsr     press_key       * Auf Taste warten
        cmpi.b  #$d,d0          * Mit "Return" vergleichen
        beq     start           * ==: laden
ende:
        lea     frage3,a5
        bsr     ausgabe
        bsr     press_key
        cmpi.b  #$d,d0
        beq     wiederh

        clr.w   -(a7)           * Pterm0
        trap    #gemdos
start:
* Pfad setzen, damit auch RSC-File korrekt nachgeladen wird.
        move.w  (a4),d0         * Laufwerksbuchstaben
        andi.l  #$ff00,d0       * hiword+lobyte.loword ausblenden
        asr.w   #8,d0           * hibyte nach lobyte schieben (im loword)
        subi.b  #'a',d0         * Es werden kl. Buchst. eingegeben !
        bmi     lwrk_f          * darf nicht <0 sein !
        cmpi.b  #$f,d0          * max. 15 Laufw. (A ... P)
        bpl     lwrk_f
        move.w  d0,-(a7)        * l.werk.
        move.w  #dsetdrv,-(a7)
        trap    #gemdos
        addq.l  #4,a7

        move.w  (bereich),d0    * loword.hibyte: max. char; low.lob: act. char
        andi.w  #$00ff,d0       * loword.hibyte ausblenden
        beq     ber_f           * bleibt nichts mehr brig ...
        ror.b   #1,d0
        bcc     vorloop
        rol.b   #1,d0
        addq.b  #1,d0
        bra     loop
vorloop:
        rol.b   #1,d0

loop:
        move.w  0(a4,d0.w),d1   * Zeiger auf Programmaufruf-Text
        andi.w  #$ff,d1
        cmpi.b  #'\',d1
        beq     weg_nam
        move.w  0(a4,d0.w),d1   * Zeiger auf Programmaufruf-Text
        andi.w  #$ff00,d1
        asr.w   #8,d1
        cmpi.b  #'\',d1
        beq     weg_nam
        subq.b  #2,d0
        bge     loop
        bra     ber_f           * Fehler mit falschem Pfad oder Filename ...

weg_nam:
        movea.l a4,a0           * Zeiger auf Programmaufruf-Text
        movea.l #path,a1
loop_2:
        move.w  (a0)+,(a1)+
        subq.b  #2,d0
        bge     loop_2          * Bei ungerader Pfadlen ist ein Byte zuviel
        move.l  #0,(a1)         * zur Sicherheit nochmals mit 0L abschliežen
* das Byte das zuviel sein kann ausnullen :
        subq.l  #2,a1           * a1 auf letztes bertragenes word setzen
        move.w  (a1),d0         * letztes word nach d0
        andi.l  #$ff,d0         * bis auf unterstes Byte l”schen
        cmpi.b  #'\',d0         * mit Pfadtrennzeichen vgl.
        beq     go_weiter       * wenn letztes Zeichen = \ dann ok
        move.w  (a1),d0         * ansonsten
        andi.b  #0,d0           * unterstes Byte ausnullen
        move.w  d0,(a1)         * und zurckschreiben
go_weiter:
        pea     (path)
        move.w  #dsetpath,-(a7)
        trap    #gemdos
        addq.l  #6,a7
        cmpi.l  #-34,d0         * Pfad nicht gef.
        beq     p_n_f
        cmpi.b  #0,d0           * <0 ?
        bmi     allg_err

* Programm in Speicher und analysieren:
        clr.l   -(a7)           * Environment (Nullpointer)

        subq.l  #1,a6           * weiž der Teufel warum ??!

        pea     (a6)            * Kommandozeile
        pea     (a4)            * Zeiger auf Path+Filename
        move.w  #3,-(a7)        * Modus 3 zum Laden und ermitteln der St.adr.
        move.w  #pexec,-(a7)
        trap    #gemdos
        adda.l  #$10,a7         * Stack zurcksetzen

* Fehlercode steht in d0.
        cmpi.l  #-33,d0         * Datei nicht gefunden
        beq     dat_n_f
        cmpi.l  #-39,d0         * Kein Speicher
        beq     not_e_mem
        cmpi.l  #0,d0           * <0 ?
        bmi     allg_err

* Startadr. des geladenen Programms steht in d0.
        move.l  d0,-(a7)        * Diese Adr. fr sp„ter merken
* Diese wird, sowie Programml„nge und Sectionl„ngen ausgegeben:
        lea     txt1,a5         * Ergebnisse bekanntgeben
        bsr     ausgabe
        move.l  (a7),a0         * Holt Basepageadr. v. Stack
* Damit man auf die Basep. nachher zugreifen kann ! -> Adressregister relativ
        move.l  a0,d7           * Adresse ausgeben
        bsr     reggiv32        * Gibt Adresse in d7 auf Bildschirm
        move.l  (a7),d7         * Basep.adr. v. stack
        addi.l  #$100,d7        * Text Startadresse
        move.l  d7,d6           * merken ...
        lea     txt2,a5
        bsr     ausgabe
        bsr     reggiv32
        move.l  d6,d7           * ... und wieder holen
        move.l  (a7),a0         * Basep.adr. v. stack
        add.l   $c(a0),d7       * + Text len = Data start
        move.l  d7,d5
        add.l   $14(a0),d7      * + Data len = Bss start
        move.l  d7,d4
        add.l   $1c(a0),d7      * + Bss len = Prg.-Ende
        lea     txt2b,a5
        bsr     ausgabe
        bsr     reggiv32
        move.l  d6,d7           * Text start
        lea     txt3,a5
        bsr     ausgabe
        bsr     reggiv32
        move.l  (a7),a0         * Basep.adr. v. stack
        move.l  $c(a0),d7       * Text Len
        lea     txt4,a5
        bsr     ausgabe
        bsr     reggiv32
        move.l  d5,d7           * Data Start
        lea     txt5,a5
        bsr     ausgabe
        bsr     reggiv32
        move.l  (a7),a0         * Basep.adr. v. stack
        move.l  $14(a0),d7      * Data len
        lea     txt6,a5
        bsr     ausgabe
        bsr     reggiv32
        move.l  d4,d7           * Bss Start
        lea     txt7,a5
        bsr     ausgabe
        bsr     reggiv32
        move.l  (a7),a0         * Basep.adr. v. stack
        move.l  $1c(a0),d7      * Bss len
        lea     txt8,a5
        bsr     ausgabe
        bsr     reggiv32
        lea     frage1,a5
        bsr     ausgabe
        bsr     press_key       * Auf Taste warten
        illegal                 * Tempelmon aufrufen
        lea     frage2,a5       * Frage ob run || ende
        bsr     ausgabe
        bsr     press_key
        cmpi.b  #$d,d0          * Mit "Return" vergleichen
        beq     weiter
        jmp     ende
weiter:
        move.l  (a7)+,d0        * gemerkte Startadresse vom Stack holen
        clr.l   -(a7)           * Environment (dummy)
        move.l  d0,-(a7)        * Startadresse der Basepage
        clr.l   -(a7)           * Kommandozeile (dummy)
        move.w  #4,-(a7)        * Modus 4 zum Starten
        move.w  #pexec,-(a7)
        trap    #gemdos
        adda.l  #$10,a7         * Stack zurcksetzen
* Hier l„uft das Programm nach Beendung des geladenen Programms weiter
* Man kann noch was einbauen, wenn man will ...
        bra     ende

dat_n_f:
        lea     dat_f,a5
        bsr     ausgabe
        bra     ende
p_n_f:
        lea     pat_f,a5
        bsr     ausgabe
        bra     ende
not_e_mem:
        lea     nem_f,a5
        bsr     ausgabe
        bra     ende
allg_err:
        lea     all_f,a5
        bsr     ausgabe
        bra     ende
lwrk_f:
        lea     laufw,a5
        bsr     ausgabe
        bra     ende
ber_f:
        lea     bere_f,a5
        bsr     ausgabe
        bra     ende

* Unterroutinen:
eingabe:
        pea     (a6)
        move.w  #cconrs,-(a7)
        trap    #gemdos
        addq.l  #6,a7
        addq.l  #2,a6
        rts

ausgabe:
        pea     (a5)            * a5 -> Stack
        move.w  #cconws,-(a7)
        trap    #gemdos
        addq.l  #6,a7           * Stack zurcks.
        rts

press_key:
        move.w  #cnecin,-(a7)
        trap    #gemdos
        addq.l  #2,a7
        rts

*alle 32 Bit ausgeben (8 Hex-Ziffern):
reggiv32:
     move.w    d7,-(a7)            *unteren 16 Bit merken
     swap      d7
     bsr       reggiv16            *und oberen 16 Bit ausgeben
     move.w    (a7)+,d7            *dann auch unteren 16 Bit ausgeben:
*unteren 16 Bit ausgeben (4 Hex-Ziffern):
reggiv16:
     move.w    d7,-(a7)            *unteren 8 Bit merken
     lsr.w     #8,d7
     bsr       reggiv8             *und unteren 8 Bit ausgeben
     move.w    (a7)+,d7            *dann auch unteren 8 Bit ausgeben:
*unteren 8 Bit ausgeben (2 Hex-Ziffern):
reggiv8:
     move.w    d7,-(a7)            *unteren 4 Bit merken
     lsr.b     #4,d7
     bsr       reggiv4             *und unteren 4 Bit ausgeben
     move.w    (a7)+,d7
     and.b     #$0f,d7             *dann auch unteren 4 Bit ausgeben:
*unteren 4 Bit ausgeben (1 Hex-Ziffer):
reggiv4:
     cmp.b     #10,d7
     bcs       regnochar
     add.b     #7,d7
regnochar:
     add.b     #$30,d7             *auf ASCII-Zeichen umrechnen
     move.b    d7,d1

regcharout:
     movem.l   a0-a1/d0-d2,-(a7)
     ext.w     d1
     move.w    d1,-(a7)
     move.w    #2,-(a7)
     trap      #1                  *Zeichen ausgeben (ESC-Sequenzen erkannt)
     addq.l    #4,a7
     movem.l   (a7)+,a0-a1/d0-d2
regret:
     rts

data
even
intro:
dc.b 27,'E',13,10
dc.b '**********************',13,10
dc.b '* Ladeprogramm  V1.1 *',13,10
dc.b '**********************',13,10
dc.b '1/1989 von Martin Rastetter',0
even
frage4:
dc.b 13,10,10,'Zu ladendes Programm:',13,10
dc.b '> ',0
even
frage5:
dc.b 13,10,'Zu bergebendes Kommando:',13,10
dc.b '> ',0

even
sicher:
dc.b 13,10,10,'Return zum Start, restl. Tasten fr Abbruch !'
dc.b 13,10,0

even
txt1:
dc.b 13,10,10,'   Program - Information :',13,10
dc.b ' ###########################',13,10
dc.b 'Basepage-Start: ',0
even
txt2:
dc.b 13,10,'Program-Start : ',0
even
txt2b:
dc.b '     Program-End : ',0
even
txt3:
dc.b 13,10,'TEXT-Start    : ',0
even
txt4:
dc.b '     TEXT-Length : ',0
even
txt5:
dc.b 13,10,'DATA-Start    : ',0
even
txt6:
dc.b '     DATA-Length : ',0
even
txt7:
dc.b 13,10,'BSS -Start    : ',0
even
txt8:
dc.b '     BSS -Length : ',0

even
frage1:
dc.b 13,10,10,' Taste drcken um Templemon aufzurufen !',0

even
frage2:
dc.b 13,10,10,' Zum Start des Programms bitte [RETURN] drcken !',13,10
dc.b ' Alle anderen Tasten fr Ende ...',0

even
frage3:
dc.b 13,10,10,' Zur Wiederholung des Programmes bitte [RETURN] drcken !'
dc.b 13,10,' Alle anderen Tasten fr Ende ...',0

even
dat_f:
dc.b 13,10,10,27,'p >>> Datei nicht gefunden <<< ',27,'q',0
even
pat_f:
dc.b 13,10,10,27,'p >>> Pfad nicht gefunden <<< ',27,'q',0
even
nem_f:
dc.b 13,10,10,27,'p >>> Nicht genug Speicherplatz vorhanden <<< ',27,'q',0
even
all_f:
dc.b 13,10,10,27,'p >>> Fehler beim Zugriff auf Disk <<< ',27,'q',0
even
laufw:
dc.b 13,10,10,27,'p >>> Falsche Laufwerksbezeichnung <<< ',27,'q',0
even
bere_f:
dc.b 13,10,10,27,'p >>> Fehlerhafter Datei-/Pfadname <<< ',27,'q',0

even
bereich:
dc.b 70,0       *70 Zeichen mssten als Filepfad reichen
ds.b 70
dc.b 0
even
bereich_2:
dc.b 70,0       *70 Zeichen mssten als Filepfad reichen
ds.b 70
dc.b 0

bss
even
path:
ds.b 70

even
ds.b 400       * Stackbereich 400 Bytes

