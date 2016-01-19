;Das DRVIN*.PRG muû resident sein oder ein entsprechendes Mag!X>2.00 laufen.
;Neue BIOS- und GEMDOS- Routinen fÅr die MIDI-Schnittstelle

;Generelle Einstellungen fÅr GEN-Assembler
	MACHINE	MC68000
	OPT	ATARI
	OPT	OW-,O1+,O2+,O3+,O4+,O5+,O8+,O9+
;folgendes wÅrde ein Warning je optimierbaren VorwÑrtssprung ergeben,
;der aber nicht optimiert wird, weil GEN es nicht kann.
;;;;;	OPT	O6+,OW6+


          INCDIR  "E:\AHSMOD\LIB\"
          INCLUDE "ERRNO.S"
          INCLUDE "MISC_DEF.S"
          INCLUDE "IOREC.S"
	INCLUDE "SER_MACS.S"


macia_c   = midiacia                 ;Adr. des Steuer/Statusregisters
macia_d   = 2+midiacia               ;Adr. des Datenregisters

;ca_flush liegt im Nichtresidenten, d.h. nur beim Init benutzen.

;Eine Wertzuweisung mit "label = *" unterbricht im Gegensatz zu "label:"
;den lokalen Labelbereich nicht!

;--------------------------------------------------------


          TEXT 
start:    bra       starti
;Sprung nach hinten, damit mîglichst wenig resident bleibt


;Im Kommandozeilenbereich liegen kurzzeitig die Sende&Empfangspuffer
;PufferlÑngen nur ganz kurz bedeutsam (zusammen max. 128 Byte)
recbuflen           = 16
trabuflen           = 16
m1_rbuf   = start-(recbuflen+trabuflen)           ;Empfangspuffer
m1_tbuf   = start-trabuflen          ;Sendepuffer


;==========================================================================


;Mit "long -> word" Adreûoptimierung Åbersetzen
;dann bringt ein lea a2,mfp ... move.b $2(a2),... keine Vorteile
;gegenÅber dem benutzten move.b $2+mfp,...
;bei letzterem ist eher noch a2 frei geblieben

;IPL6 und IPL7 haben die gleiche Auswirkung auf die CPU: Es werden auûer
;Level7-Interrupts keine anderen bearbeitet. IPL6 wird bei der MFP-
;Interruptannahme automatisch gesetzt und erst bei RTE automatisch zurÅck-
;gesetzt. Deshalb in den MFP-I.routinen kein IPL7 bei Soundchipzugriffen.

;CLR.L Dx braucht 6 Takte, MOVEQ.L #0,Dx nur 4 Takte !
;auûerdem liest CLR bei 68000 immer zuerst den Operand, auch aus Speicher!!!



;Nur bei XON/XOFF-Handshake und RTS/CTS-Empfang wird
;m1_iorec +$1e / +$1f benutzt. Bei RTS/CTS-Senden nicht!

;Da es sich um Ringpuffer handelt, ist folgende exakte Definition fÅr Puffer
;voll und Puffer leer notwendig:
;- Puffer leer: Schreibzeiger = Lesezeiger
;- Puffer voll: ((Schreibzeiger + 1) modulo PufferlÑnge) = Lesezeiger

;Ein Zeiger wird erst benutzt (an dieser Position gelesen / geschrieben)
;und dann erhîht. Wird beim Erhîhen das Pufferende erreicht
;(Zeiger = PufferlÑnge), so wird der Zeiger sofort auf 0 gesetzt.

;Lese minus Schreibzeiger
;BHI Åberspringe nÑchstes
;plus LÑnge
;ergibt Anzahl freier PlÑtze

;Schreib minus Lesezeiger
;BCC Åberspringe nÑchstes
;plus LÑnge
;ergibt Anzahl belegter PlÑtze

;-------------------------------------------------------------------------

;---------
;<KRIT?> als Kommentar: Dieser Befehl durfte nur wegen Interruptsperre
;an dieser Stelle etwas vorgezogen werden und mÅûte normalerweise ?
;Befehle weiter hinten stehen, wobei die dazwischenliegenden dann
;eventuell nicht so optimiert werden dÅrfen, wie sie es sind.
;---------

;Entweder man belegt den $118-Vektor, hÑngt also ganz schnell direkt im
;I4-Interrupt des MFP, oder man hÑngt langsamer im midisys-Vektor. FÅr midisys
;wird meine $118-Routine an einer Stelle modifiziert und nicht am
;Anfang, mittendrin aufgerufen durch den folgenden midisys-Routinenanfang.

m_midisys:          
;A0-A3/D0-D3 darf man ungesichert nutzen
          move.b    macia_c,d2
          bpl.s     .ende            ;kein MIDI-Interrupt
          btst.l    #0,d2
          beq       I_MA_no_rec      ;keine Empfangsdaten
          move.b    macia_d,d0       ;empf. Byte in D0.b
;kînnte aber noch fehlerbehaftet sein
          lea       m1_iorec(pc),a0
          moveq.l   #$70,d1          ;3 Fehlerbits in Maske
;und lîsche Bit31..16, die mÅssen 0 bleiben
          and.b     d2,d1
          bra.s     I_MA_rein
.ende:    
          rts       


my_ikbdsys:         
          DC.l 32  ;(nach Ini.) Adresse von KBDVECS.ikbdsys, erst Offset


;Codeerzeugung fÅr den I4-Interrupt des MFP, der beide ACIA bedient
;Vektor auf $118 (iva_mfp_acia)
i_mfp_acia:         
.nochmal: 
          move.b    macia_c,-(sp)    ;MIDI-Status, WORD auf Stack
;(BYTE liegt im Highbyte des WORD, also bei (sp))
          bpl       .no_midi         ;Bit7 ist netterweise im Sign-Flag
;MIDI-ACIA meldete Interrupt
          btst.b    #0,(sp)          ;vor movem gezogen wird offset gespart
          movem.l   d0/d1/a0,-(sp)   ;benîtigte Register (Flags ungeÑndert)
mistsofs  = 3*4
          beq       .no_rec          ;keine Empfangsdaten

          move.b    macia_d,d0       ;empf. Byte in D0.b
;kînnte aber noch fehlerbehaftet sein
          lea       m1_iorec(pc),a0
          moveq.l   #$70,d1          ;3 Fehlerbits in Maske
;und lîsche Bit31..16, die mÅssen 0 bleiben
          and.b     mistsofs(sp),d1
I_MA_rein           = *              ;Einsprung, A0/D0/D1/Flags gesetzt
          bne       .rec_err         ;irgendein Empfangsfehler
;D0.b fehlerfrei, verarbeiten
          tst.b     ioo_hsm(a0)      ;Handshake?
          beq.s     .re_nhs          ;nein
;Handshake bedeutet immer XON/XOFF
          cmpi.b    #xon,d0
          beq.s     .re_xon
          cmpi.b    #xoff,d0
          beq.s     .re_xoff
;normales Byte ablegen
          move.w    ioo_rwp(a0),d1   ;Schreibzeiger holen
          addq.w    #1,d1            ;erhîhen, durch .w automatisch auf 64KByte beschrÑnkt
          cmp.w     ioo_rbl(a0),d1   ;im Puffer umlaufen lassen
          bcs.s     .re_xbe
          moveq     #0,d1
.re_xbe:  
          cmp.w     ioo_rrp(a0),d1
          beq.s     .re_end          ;Puffer voll, Byte wegwerfen
          move.w    d1,ioo_rwp(a0)   ;<KRIT2> Schreibzeiger aktualisieren
          movea.l   (a0),a0          ;Pufferadresse (killt altes A0!!!)
          move.b    d0,0(a0,d1.l)    ;Byte -> Puffer
;Anzahl belegter Byte errechnen
          lea       m1_iorec(pc),a0
          sub.w     ioo_rrp(a0),d1   ;minus Lesezeiger
          bcc.s     .re_ib           ;keine Korrektur
          add.w     ioo_rbl(a0),d1   ; sonst plus Puffergrîûe
.re_ib:   
          cmp.w     ioo_rhw(a0),d1   ;vergleiche mit High Water Mark
          bcs.s     .re_end          ;noch kein Hochwasser, hops
          bset.b    #7,ioo_re(a0)    ;teste und setze
          bne.s     .re_end          ;EmpfÑnger schon inaktiv
          move.b    #xoff,ioo_tci(a0)             ;XOFF
          bra.s     .re_fti          ;Sendeint freigeben...
.re_xon:  
          clr.b     ioo_te(a0)       ;Sender freigeben
.re_fti:  
;Sendeinterrupt freigeben. Sofort schlÑgt der Int. zu, falls er vorher
;gesperrt war.
          ori.b     #$20,ioo_acc(a0) ;Bit6 war&bleibt =0, Bit5 =1
          move.b    ioo_acc(a0),macia_c
          bra.s     .re_end          ;Senden falls mîglich
.re_xoff: 
          st        ioo_te(a0)       ;Sender sperren
          bra.s     .re_end          ;falls Sendeint., muû der gesperrt werden

.re_nhs:  
          lea       m1_iorec(pc),a0
          move.w    ioo_rwp(a0),d1   ;Schreibzeiger holen
          addq.w    #1,d1            ;erhîhen, durch .w automatisch auf 64KByte beschrÑnkt
          cmp.w     ioo_rbl(a0),d1   ;im Puffer umlaufen lassen
          bcs.s     .re_nbe
          moveq     #0,d1
.re_nbe:  
          cmp.w     ioo_rrp(a0),d1
          beq.s     .re_end          ;Puffer voll, Byte wegwerfen
          move.w    d1,ioo_rwp(a0)   ;<KRIT2> Schreibzeiger aktualisieren
          movea.l   (a0),a0          ;Pufferadresse (killt altes A0!!!)
          move.b    d0,0(a0,d1.l)    ;Byte -> Puffer
.re_end:  
;Empfangsteil beendet
;Nicht einfach in Sendeteil reinlaufen, denn Sender kînnte leer sein, ohne
;daû er Åberhaupt Interrupt melden konnte (Sendeint gesperrt), und die
;Puffer-leer-Prozedur dauert. Erst testen, ob Sendeint freigegeben,
;falls ja, reinlaufen, sonst zum MIDI-Ende.
          btst.b    #5,ioo_acc+m1_iorec
          beq.s     .no_tra          ;Sendeint ist gesperrt, Ende


.no_rec:  
I_MA_no_rec         = *              ;Einsprung
          btst.b    #1,macia_c       ;teste ob _jetzt_ Sender leer
;######## das kînnte doch schon wieder neu angemeldete Empfangsfehler
;######## lîschen ????
          beq.s     .no_tra          ; nein

;Senderegister leer
          moveq.l   #0,d1            ;lîsche vor allem Bit31-16, die mÅssen 0 bleiben!
          lea       m1_iorec(pc),a0
          tst.b     ioo_hsm(a0)      ;Handshake?
          beq.s     .tr_nhs          ;nein
;Handshake bedeutet immer XON/XOFF
          move.b    ioo_tci(a0),d0
          beq.s     .tr_nci
          move.b    d1,ioo_tci(a0)   ;D1 ist 0
          move.b    d0,macia_d       ;Zeichen senden
          bra.s     .tr_end
.tr_nci:  
          tst.b     ioo_te(a0)       ;Sender freigegeben?
          bne.s     .tr_ns           ;nein, nichts senden
;nachdem Handshake abgefragt, benutze den "ohne Handshake" Teil mit

.tr_nhs:  
          move.w    ioo_trp(a0),d1   ;Lesezeiger
          cmp.w     ioo_twp(a0),d1   ;Schreibzeiger
          bne.s     .tr_pne          ;Puffer nicht leer
.tr_ns:   
;Puffer leer oder aus anderen GrÅnden nichts senden
          andi.b    #$9f,ioo_acc(a0) ;Sendeinterrupt sperren,
          move.b    ioo_acc(a0),macia_c           ; da sonst Dauerinterrupt
          bra.s     .tr_end
.tr_pne:  
          addq.w    #1,d1            ;erhîhen, durch .w automatisch auf 64KByte beschrÑnkt
          cmp.w     ioo_tbl(a0),d1   ;im Puffer umlaufen lassen
          bcs.s     .tr_nbe
          moveq     #0,d1
.tr_nbe:  
          move.w    d1,ioo_trp(a0)   ;<KRIT2>Lesezeiger aktualisieren
          movea.l   ioo_tba(a0),a0   ;Pufferadresse
          move.b    $0(a0,d1.l),macia_d           ;Puffer -> Senderegister
.tr_end:  
;Sendeteil beendet

.no_tra:  
INIPA_I0  = *       ;hierhin RTS bei midisys-Nutzung
          movem.l   (sp)+,d0/d1/a0
          addq.l    #2,sp            ;MIDI-Status vom Stack
          btst      #4,mfp           ;noch immer ACIA-Interrupt?
          beq       .nochmal         ;ja, dÅrfte aber selten sein
          move.b    #$bf,$10+mfp     ;Interrupt in ISRB lîschen
          rte                        ;Ende

.no_midi: 
          addq.l    #2,sp            ;MIDI-Status vom Stack
;dann muû wohl IKBD-ACIA Interrupt melden
          movem.l   d0-d3/a0-a3/a5,-(sp)
          lea       0,a5             ;!!! fÅr TOS<2 (A5=0 relative Adr.)
          movea.l   my_ikbdsys,a2    ;Adresse KBDVECS.ikbdsys
          movea.l   (a2),a2          ;Routinenzeiger
          jsr       (a2)             ;IKBD-Int. aufrufen
          movem.l   (sp)+,d0-d3/a0-a3/a5
          btst      #4,mfp           ;liegt noch Interrupt-aktiv Pegel an?
          beq       .nochmal         ;ja, nochmal, dÅrfte sehr selten sein
          move.b    #$bf,$10+mfp     ;Interrupt in ISRB lîschen
          rte       

.rec_err: 
;Empfangsfehler, momentan keine Bearbeitung, nur Zeichen vergessen
;und weiter ###########
          or.b      d1,ioo_rsr(a0)   ;OR-Sammlung Fehlerbits 6..4
          bra       .no_rec

;Geschwindigkeitsnachteil wegen kleinerer movem.l d0-d3/a0-a3 Klammerung nur,
;wenn im IKBD-Teil eine "nochmal"-Bedingung auftritt. Sonst ist es schneller.







;Die BIOS-Routinen bconout, bcostat, bconin, bconstat
;fÅr den _zusÑtzlichen_ MIDI-Kanal

;Benutzte Register: d0, d1, d2, a0, a1 (a2 nicht, obwohl erlaubt)
;Diese Register kînnen auch ohne vorherige Sicherung immer benutzt werden,
;auch wenn sie der BIOS-Dispatcher nicht gesichert hat.


;MIDI, bconout, Zeichenausgabe
;FÅr den Handshake ist nur der Interrupt verantwortlich.
;Aufruf auch bei anfang+4 mîglich, mit Parameter in D0.b
m1_bconout:         
          lea       6(sp),a0         ;Mag!X-gleich, muû sein
          move.w    (a0),d0
          lea       m1_iorec,a0
          moveq     #0,d1            ;Bit31-16 muû 0 bleiben!
          move.w    ioo_twp(a0),d1   ;Schreibzeiger holen
          move.w    ioo_tbl(a0),d2   ;Puffergrîûe holen
          addq.w    #1,d1            ;erhîhen, auf 64KByte beschrÑnkt durch .w
          cmp.w     d2,d1            ;im Puffer umlaufen lassen
          bcs.s     .conbx
          moveq     #0,d1
.conbx:   movea.l   ioo_tba(a0),a1   ;Pufferadresse, auch fÅr spÑter
          move.b    d0,0(a1,d1.l)    ;Byte -> Puffer
          move.w    d1,ioo_twp(a0)   ;Schreibzeiger aktualisieren
;Sendeinterrupt freigeben. Sofort schlÑgt der Int. zu, falls er vorher
;gesperrt war, und holt sich das Zeichen.
          ori.b     #$20,ioo_acc(a0) ;Bit6 war&bleibt =0, Bit5 =1
          move.b    ioo_acc(a0),macia_c
;Anzahl noch freier PlÑtze im Puffer ermitteln und erst bconout verlassen,
;wenn wieder mindestens ein Zeichen Platz ist, damit nÑchstes bconout wieder
;Platz hat.
.cobfu:   
          move.w    ioo_trp(a0),d1   ;Lesezeiger
          sub.w     ioo_twp(a0),d1   ;minus Schreibzeiger
          bhi.s     .coxnx           ;keine Korrektur
          add.w     d2,d1            ;plus PufferlÑnge
.coxnx:   subq.w    #1,d1            ;minus 1 statt cmp #1
          beq       .cobfu           ;voll, warten auf Leerung
          rts                        ;Ende



;MIDI, bcostat, Ausgabestatus
m1_bcostat:         
	usm_bcostat	m1_iorec(pc)
          rts       



;Modem1, bconin, Zeicheneingabe
;FÅr alle drei Fluûkontrollarten
m1_bconin:          
          lea       m1_iorec,a0
          moveq     #0,d1            ;Bit31-16 muû 0 bleiben!
          moveq     #0,d0            ;beim Returncharacter Bit31-8 =0
          move.w    ioo_rrp(a0),d1   ;Lesezeiger holen
.cibem:   cmp.w     ioo_rwp(a0),d1   ;Vergleich mit Schreibzeiger
          beq       .cibem           ;Puffer leer, warten
          addq.w    #1,d1            ;Lesezeiger +1 im Puffer umlaufend
          cmp.w     ioo_rbl(a0),d1
          bcs.s     .cinbt
          moveq     #0,d1
.cinbt:   movea.l   (a0),a1          ;Pufferadresse
          move.b    $0(a1,d1.l),d0   ;Puffer -> Byte
          move.w    d1,ioo_rrp(a0)   ;Lesezeiger aktualisieren
          tst.b     ioo_hsm(a0)      ;Handshake ?
          beq.s     .ciend           ;kein Handshake
;Teste zuerst, ob der EmpfÑnger freigegeben ist. Das ist schneller, als
;wenn erst auf untere Wassermarke getestet wird.
          tst.b     ioo_re(a0)
          beq.s     .ciend           ;EmpfÑnger ist freigegeben
;Anzahl belegter Byte berechnen
          move.w    ioo_rwp(a0),d1   ;Schreibzeiger
          sub.w     ioo_rrp(a0),d1   ;minus Lesezeiger
          bcc.s     .cincd           ;keine Korrektur
          add.w     ioo_rbl(a0),d1   ;sonst LÑnge dazu
.cincd:   cmp.w     ioo_rlw(a0),d1   ;untere Wassermarke
          bhi.s     .ciend           ;untere W. noch nicht unterschritten
          sf        ioo_re(a0)       ;EmpfÑnger freigeben
          move.w    sr,d2
          ori.w     #$0700,sr        ;sonst kînnten noch Interrupts erfolgen
          btst      #1,ioo_hsm(a0)   ;welcher Handshake?
          beq.s     .cish            ;XON/XOFF (kein RTS/CTS)
;Hardwarehandshake #########
; ### RTS aktiv (TTL-Low) schalten
          move.w    d2,sr            ;Interruptlevel wieder herstellen
          rts                        ;Ende (1)
.cish:    
;XON/XOFF
          moveq.l   #xon,d1          ;XON bei XON/XOFF-Handshake
          btst.b    #1,macia_c       ;Interrupts sind schon gesperrt
          beq.s     .citf            ;Senderegister voll, XON spÑter senden
;zu eventuell angemeldetem Interrupt siehe bei bconout
          move.b    d1,macia_d       ;XON sofort senden
          move.w    d2,sr            ;Interruptlevel wieder herstellen
          rts                        ;Ende (2)
.citf:    
          move.w    d2,sr            ;Interruptlevel wieder herstellen
          move.b    d1,$21(a0)       ;XON vormerken
.ciend:   rts                        ;Ende (3)



;MIDI, bconstat, Eingabestatus
m1_bconstat:        
	usm_bconstat	m1_iorec(pc)
	rts



;Das neue MIDI Rsconf.

m1_rsconf:          
;Rsconf fÅr MIDI
;kill: D0-D2/A0/A1
          cmpi.w    #SETUSPEED,4(sp)
          bne.s     rsm1uno          ;nicht die erweiterte Funktion
          move.l    ioo_ubd+m1_iorec,d0           ;aktuelle uspeed
          move.l    2+4(sp),d1       ;Parameter uspeed
          bmi       rsm1ende         ;nur abfragen
          move.l    d1,d0
          bsr       rsm1_suchbaud
          tst.l     d0               ;gefunden?
          bmi       rsm1ende         ; nein
          move.l    ioo_ubd+m1_iorec,d2           ;alte uspeed
          move.l    d0,ioo_ubd+m1_iorec           ;neue uspeed vermerken
          move.l    d2,d0            ;alte uspeed als Returnwert
          bsr       rsm1_setbd       ;Baudrate anhand Index (D1.w) einstellen
          bra       rsm1ende
rsm1uno:  
          moveq     #0,d0
          cmpi.w    #$fffe,4(sp)     ;Parameter speed
          bne.s     rsm1nob
          move.b    $22+m1_iorec,d0  ;bei speed = -2 nur die eingestellte
          rts                        ;Baudrate zurÅckgeben
rsm1nob:  
;Returnwert in D0.l zusammensuchen
          moveq.l   #$1c,d0          ;Maske Bit4..2, Highword 0
          and.b     ioo_acc+m1_iorec,d0
          lsr.w     #2,d0            ;nach Bit2..0
          lea       rsm1_a2m,a0      ;Wandlungstabelle
          move.b    0(a0,d0.w),d0    ;ucr erstellt, schiebe nach Bit31..24
          lsl.w     #8,d0
          swap.w    d0
          btst.b    #6,ioo_acc+m1_iorec           ;wird Break gesendet?
          beq.s     rsm1nbr          ;kein Break momentan
          btst.b    #5,ioo_acc+m1_iorec
          beq.s     rsm1nbr          ;kein Break (Break ist Bit6=1 & Bit5=1)
          bset      #11,d0           ;tsr.Bit3 setzen fÅr Break
rsm1nbr:  
          move.w    4(sp),d1         ;Parameter speed
          move.l    #7812,d2
          cmpi.w    #$0001,d1
          bhi.s     rsm1nosp         ;hops bei speed zu groû (bzw. negativ)
          beq.s     rsm1masp
          move.l    #31250,d2
rsm1masp: 
          move.l    d2,ioo_ubd+m1_iorec           ;merke auch als Klartext
          bsr       rsm1_setbd       ;einstellen
rsm1nosp: 
          move.w    $8(sp),d2        ;Parameter ucr
          bmi.s     rsm1fcu0         ;Sprung fÅr nicht Ñndern
;ucr interpretieren, fÅr ACIA unmîgliche Werte werden zu 8n1
          bset      #7,d2            ;Anpassung an Tabellendaten:
          bclr      #0,d2            ; Leerfelder auf Standard
          moveq.l   #7,d1            ;alle 8 Tab-eintrÑge
          lea       rsm1_a2m,a0
rsm1_0b:  
          cmp.b     0(a0,d1.w),d2
          dbeq      d1,rsm1_0b
          beq.s     rsm1_0a          ;Erlaubte, Index als ACIA-Wert
          moveq.l   #5,d1            ;Unmîgliche ersetzt durch 8n1 in Bit2..0
rsm1_0a:  
          lsl.b     #2,d1            ;nach Bit4..2
          moveq.l   #$e3,d2          ;Maske
          move.w    sr,-(sp)
          ori.w     #$700,sr         ;INTERRUPTSPERRE
          and.b     ioo_acc+m1_iorec,d2           ;Schatten
          or.b      d1,d2
          move.b    d2,ioo_acc+m1_iorec
          move.b    d2,macia_c       ;Hardware
          move.w    (sp)+,sr         ;INTERRUPTS FREI

rsm1fcu0: 
;Parameter rsr bei $a(sp) ist nicht sinnvoll

          move.w    $c(sp),d2        ;Parameter tsr
          bmi.s     rsm1fct0         ;Sprung fÅr nicht Ñndern
;tsr.Bit3 als Breakbit auswerten
          btst      #3,d2
          beq.s     rsm1_1a          ;Break lîschen
;Break setzen: RTS =Low, TxINT gesperrt, Break senden
          ori.b     #$60,ioo_acc+m1_iorec         ;Schatten
          move.b    ioo_acc+m1_iorec,macia_c
          bra.s     rsm1fct0
rsm1_1a:  
;Break lîschen: RTS =Low, TxINT freigegeben
;(TxINT wird erforderlichenfalls durch den Interrupt gesperrt)
          bclr.b    #6,ioo_acc+m1_iorec           ;Annahme Bit5 war 1
          move.b    ioo_acc+m1_iorec,macia_c

rsm1fct0: 
;Parameter scr bei $e(sp) ist nicht sinnvoll

          move.w    sr,d1
          swap.w    d1               ;sichern, D1-Highword nicht nutzen!
          ori.w     #$0700,sr        ;Interruptsperre

          move.w    6(sp),d2         ;Parameter flowctl
          cmpi.w    #3,d2
          bhi.s     rsm1fcbi         ;flowctl ist zu groû
          bne.s     rsm1fcnb         ;flowctl nicht XON/XOFF & RTS/CTS
          moveq.l   #1,d2            ;"beides" Ñndere auf XON/XOFF
rsm1fcnb: 
;######## momentan-A-beginn -->>
          cmpi.w    #2,d2
          bne.s     rss1fcnr
          moveq.l   #0,d2            ;"RTS/CTS" Ñndere auf "OHNE"
rss1fcnr: 
;####### <<-- mometan-A-ende
          cmp.b     ioo_hsm+m1_iorec,d2           ;vergleiche mit altem
          beq.s     rsm1nosh         ;neues = altes, keine Sonderaktion, aber
; Int.vekt. setzen und Int.s freigeben
;Das bedeutet, die erste RTS-Aktivierung nach Reset muû ein anderer machen.
          move.b    d2,ioo_hsm+m1_iorec           ;flowctl speichern (noch in d2 gebraucht)

          clr.w     $1e+m1_iorec     ;EmpfÑnger und Sender (+$1f) freigeben
;Wenn der Empfangspuffer voll ist, gehen evtl. gleich nach dieser
;Umschaltung ein paar Zeichen verloren. Das ist aber TOS-kompatibel.
;Ansonsten muû man umstÑndlich prÅfen, ob der EmpfÑnger freigegeben werden
;darf.

          IFNE 0     ;############
          move.b    #$0e,sndchp      ;RTS aktiv (TTL-Low) schalten
          move.b    #$f7,d1
          and.b     sndchp,d1
          move.b    d1,$2+sndchp
          ENDC 

          cmpi.b    #1,d2            ;welcher Handshake?
          bne.s     rsm1nosh         ;kein XON/XOFF
;Bei XON/XOFF-HS ein XON senden, und zwar mit den neuen
;Einstellungen, deshalb erst hier. Hinweis: hier ist IPL7
          btst.b    #1,macia_c       ;ACIA-Senderegister leer ?
          beq.s     rsm1tbne         ;nicht leer
;Interrupt lîschen nicht erforderlich/mîglich
          move.b    #xon,macia_d     ;XON -> Senderegister
          bra.s     rsm1nosh
rsm1tbne: 
          move.b    #xon,ioo_tci+m1_iorec         ;XON vormerken
rsm1nosh: 
;### hier wurden die Int-Vektoren zum Handshakemodus beim MFP gesetzt

;MFP-I4-Interrupt freigeben (auch wenn es zum 100. Mal ist)
          bclr.b    #4,2+mfp         ;ACIA-Int. bei High-Low-Flanke (->aktiv)
          ori.b     #$40,8+mfp       ;ACIA-Int. in IERx und IMRx freigeben
          ori.b     #$40,$14+mfp
rsm1fcbi: 
;RÅckgabewert in d0: ucr,rsr,tsr,udr in Bit31-0
          swap.w    d1
          move.w    d1,sr            ;alte Interruptmaske
rsm1ende: 
          rts       


rsm1_suchbaud:      
;aufgerufen durch m1_rsconf
;in:   D0.l: zu suchende Klartext-Baudrate
;out:  D0.l: mîgliche Klartextspeed
;      D0.bit31: 0= Rate vorhanden
;                1= andere Rate in D0(bit30..0) vorgeschlagen
;      D1.w: wenn Rate vorhanden: Indexnummer zur Klartextspeed
;kill: D0/D1
;Suche neue Baudrate.
          moveq.l   #0,d1
          cmpi.l    #31250,d0
          bcs.s     .no_max          ;kleiner
          beq.s     .end             ;Treffer
          move.l    #($80000000|31250),d0         ;neuer Vorschlag
.end:     
          rts       
.no_max:  
          moveq.l   #1,d1
          cmpi.l    #7812,d0         ;genau 7812.5 Bd
          beq       .end             ;Treffer
          move.l    #($80000000|7812),d0          ;neuer Vorschlag
          rts       



rsm1_setbd:         
;Baudrate in ACIA einstellen
;in:  D1.w gÅltiger Rsconf-Index
;kill: D2
          move.b    d1,$22+m1_iorec  ;Parameter speed speichern
          moveq.l   #$fc,d2          ;Bit1..0 fÅr Baudrate auf 0
          move.w    sr,-(sp)
          ori.w     #$700,sr         ;Sperre wegen Schattenregisterfummelei
          and.b     ioo_acc+m1_iorec,d2           ;ACIA-Control-Schatten
          bset      d1,d2            ;Bit0 oder Bit1 setzen
          move.b    d2,macia_c       ;setze Baudrate
          move.b    d2,ioo_acc+m1_iorec
          move.w    (sp)+,sr
          rts       



rsm1_a2m: 
;Umwandlung ACIA-Format fÅr Datenbits/ParitÑt/Stoppbits in MFP-Format
;(Bit7 beim MFP immer 1, Bit0 immer 0)
;Wandlung MFP->ACIA Åber Suche
          DC.b $be,$bc,$ae,$ac      ;7e2, 7o2, 7e1, 7o1
          DC.b $98,$88,$8e,$8c      ;8n2, 8n1, 8e1, 8o1



;IOREC fÅr MODEM1
;Initialisierungswerte: 31250Bd, 8N1, kein Handshake
m1_iorec: DC.l m1_rbuf
          DC.w recbuflen
          DC.w 0
          DC.w 0
          DC.w recbuflen/4
          DC.w (recbuflen*3)/4
          DC.l m1_tbuf
          DC.w trabuflen
          DC.w 0
          DC.w 0
          DC.w trabuflen/4          ;eigentlich sinnlos
          DC.w (trabuflen*3)/4      ;eigentlich sinnlos
          DC.b 0,$b5                ;egal, Controlreg.schatten (8n1, Int. frei, /16)
          DC.b 0,0 ;ioo_re,ioo_te
          DC.b 0,0 ;kein Handshake, x
          DC.b 0   ;Baudrate
          DC.b $ff ;unbenutzt
          DC.l 31250                ;Klartextrate


;----------------------------------------------------------------------

;XBIOS-Teil, wird auf Wunsch in XBIOS-Trap#14 eingehÑngt
;und fÑngt Iorec fÅr Original-MIDI und Midiws ab

          DC.b 'XBRA','MIRS'
oldxbiosv:          DC.l 0
t14_xbios:          
          move.l    usp,a0           ;da die Daten meist auf Userstack liegen
          btst      #5,(sp)          ;diese Reihenfolge
          beq.s     t14_dus          ;Daten auf Userstack, ab (a0)
t14_xP:   
          lea       8(sp),a0         ;wird beim Start evtl. auf 6 gepatcht
t14_dus:  
;teste ob abzufangende Funktion
          cmpi.l    #$000e0002,(a0)  ;Iorec fÅr 2, Original-MIDI?
          beq.s     t14_iorec        ;ja
          cmpi.w    #12,(a0)         ;Midiws?
          beq.s     t14_midiws       ;ja
          movea.l   oldxbiosv(pc),a0
          jmp       (a0)             ;altes XBIOS anspringen

t14_iorec:          
          move.l    #m1_iorec,d0
          rte       

t14_midiws:         
          movem.l   d3/d4,-(sp)
          moveq.l   #0,d3
          move.w    2(a0),d3
          addq.l    #1,d3            ;da Anzahl-1 auf Stack stand
          move.l    4(a0),d4         ;Zeiger
.noch:    
          suba.l    a0,a0
          movea.l   d4,a1
          move.l    d3,d0
          bsr       m1_fwrite
          add.l     d0,d4            ;Zeiger auf nÑchstes
          sub.l     d0,d3            ;Anzahl verringern
          bne       .noch            ;immer wieder, bis alles gesendet
          movem.l   (sp)+,d3/d4
          rte       

;----------------------------------------------------------------------

m1_lseek: moveq.l   #0,d0            ;Position 0 nach seek
          rts                        ;immer so fÅr U:\DEV\-Treiber

;!!XX!! #### QUICKIE-Definitionen fÅr das noch nicht vorhandene
m1_fopen: 
	tst.w	c_hog_conf	;Schwein sein?
	beq	.no_fd		; nein
	move.l	a0,d0
	beq	.no_fd		;DRVIN unterstÅtzt momentan keinen FD
	ori.w	#$0040,6(a0)	;aktiv das OM_NOCHECK-Bit setzen
;Dann wird jeder (folgende) Fopen an den Treiber weitergeleitet und der muû
;selbst entscheiden, ob er sich so îffnen lassen will oder nicht.
.no_fd:
          moveq.l   #0,d0            ;OK
          rts       

m1_fclose:          moveq.l          #0,d0        ;OK
          rts       

m1_stat:  
          moveq.l   #1,d0            ;beim Pollen immer bereit
          tst.l     d1               ;=0 bedeutet Polling
          beq.s     .poll_ok
          moveq.l   #0,d0            ;Meldung: kann nur Polling
.poll_ok: 
          move.l    a1,d1            ;(kein tst.l aX auf 68000)
          beq.s     .no_ptr
          move.l    d0,(a1)          ;Returnwert auch in Struktur
.no_ptr:  
          rts       

m1_delete:          
;####### macht mein Device nicht lîschbar
          moveq.l   #EINVFN,d0
          rts       


;#######
m1_iname: 
          DC.b 'U:\DEV\MIDI',0
          EVEN 
m1_drvr:  
          DC.l m1_fopen,m1_fclose,m1_fread,m1_fwrite
          DC.l m1_stat,m1_lseek
          DC.l 0   ;datime, darf Nullzeiger sein
          DC.l m1_fcntl,m1_delete   ;(ioctl)
          DC.l 0,0,0                ;getc, getline, putc

;----------------------------------------------------------------------

          TEXT 

;Die Block-I/O-Routinen fÅr die serielle öbertragung
;Sie arbeiten nichtblockierend und lesen/schreiben nie mehr Byte, als
;im Puffer sind / in den Puffer passen. Damit hier keine Handshake-
;Behandlung rein muû, wird das jeweils letzte Byte nicht direkt Åber den
;Puffer sondern mit bconin/bconout transportiert.


m1_fread: 
;Fread fÅr MODEM1
;Mag!X-mÑûig
;in:   A0: Zeiger auf Filedeskriptor, ### derzeit Null
;      A1: LONG buffer
;      D0: LONG len
;out:  D0: Anzahl wirklich gelesener Byte oder Fehlercode
;kill: D0-D2/A0-A2
          moveq.l   #0,d1            ;Bit31-16 muû 0 bleiben
          lea       m1_iorec,a2      ;Adr. IOREC
          move.w    $4(a2),d2        ;PufferlÑnge
          move.w    $8(a2),d1        ;Schreibz
          sub.w     $6(a2),d1        ;Lesez
          bcc.s     .fr0
          add.w     d2,d1            ;LÑnge
.fr0:               ;Anzahl vorhandener Byte in D1
          cmp.l     d0,d1
          bcc.s     .fr1             ;Minimum bilden
          move.l    d1,d0
.fr1:     tst.l     d0               ;Anzahl Åbertragbarer Bytes in D0
          beq.s     .frend           ;nichts Åbertragen

          move.l    d0,-(sp)         ;Byteanzahl sichern
          movea.l   (a2),a0          ;Interruptpufferadresse
          move.w    $6(a2),d1        ;Lesez

          bra.s     .frbeg           ;letztes/einziges Byte per Bconin holen!
.frcop:   addq.w    #1,d1            ;Lesez umlaufend
          cmp.w     d2,d1            ;D2: PufferlÑnge
          bcs.s     .frbt
          moveq     #0,d1
.frbt:    move.b    0(a0,d1.l),(a1)+ ;Byte kopieren
.frbeg:   subq.l    #1,d0
          bne       .frcop
.frlst:   
          move.w    d1,$6(a2)        ;Lesez update
          move.l    a1,-(sp)         ;Zeiger sichern
          bsr       m1_bconin        ;Byte holen, aktualisiert Handshake
          movea.l   (sp)+,a1         ;Pufferzeiger wieder holen
          move.b    d0,(a1)          ;letztes Byte in Userpuffer
          move.l    (sp)+,d0         ;Byteanz. holen
.frend:   
          rts       


m1_fwrite:          
;Fwrite fÅr MODEM1
;Mag!X-mÑûig
;in:   A0: Zeiger auf Filedeskriptor, ### derzeit Null
;      A1: LONG buffer
;      D0: LONG len
;out:  D0: Anzahl wirklich gelesener Byte oder Fehlercode
;kill: D0-D2/A0-A2
          moveq.l   #0,d1            ;Bit31-16 muû 0 bleiben
          lea       m1_iorec,a2      ;Adr. IOREC
          move.w    $e+$4(a2),d2     ;PufferlÑnge
;freier Platz gilt fÅr nichtblockierenden bconout-Aufruf
          move.w    $e+$6(a2),d1     ;freien Platz berechnen, Lesezeiger
          sub.w     $e+$8(a2),d1     ;minus Schreibzeiger
          bhi.s     .fw0             ;keine Korrektur
          add.w     d2,d1            ;PufferlÑnge dazu
.fw0:     subq.l    #2,d1
          bpl.s     .fwxx
          moveq.l   #0,d1            ;Sicherheit, sollte nie negativ werden
.fwxx:              ;Anzahl freier PlÑtze in D1
          cmp.l     d0,d1
          bcc.s     .fw1             ;Minimum bilden
          move.l    d1,d0
.fw1:     tst.l     d0               ;Anzahl Åbertragbarer Bytes in D0
          beq.s     .fwend           ;nichts Åbertragen

          move.l    d0,-(sp)         ;Byteanzahl sichern
          movea.l   $e(a2),a0        ;Interruptpufferadresse
          move.w    $e+$8(a2),d1     ;Schreibz

          bra.s     .fwbeg           ;letztes/einziges Byte per Bconout!
.fwcop:   addq.w    #1,d1            ;Schreibz umlaufend
          cmp.w     d2,d1            ;D2: PufferlÑnge
          bcs.s     .fwbt
          moveq     #0,d1
.fwbt:    move.b    (a1)+,0(a0,d1.l) ;Byte kopieren
.fwbeg:   subq.l    #1,d0
          bne       .fwcop
.fwlst:   
          move.w    d1,$e+$8(a2)     ;Schreibz update
          move.b    (a1),d0          ;letztes Byte
          move.l    d0,-(sp)         ;LONG! wegen Dummy
          bsr       m1_bconout       ;Byte schreiben, aktualisiert Handshake
          addq.l    #4,sp
          move.l    (sp)+,d0         ;Byteanz. holen
.fwend:   
          rts       


m1_fcntl: 
;Fcntl = ioctl fÅr MODEM1
;Mag!X-mÑûig
;in:   A0: Zeiger auf Filedeskriptor, ### derzeit Null
;      A1: LONG argument (meist ein Zeiger)
;      D0: WORD command
;out:  D0: Fehlercode
;kill: D0-D2/A0-A2
          cmpi.w    #FIONREAD,d0
          beq       .m000
          cmpi.w    #FIONWRITE,d0
          beq       .m001
          cmpi.w    #TIOCCBRK,d0
          beq       .m002
          cmpi.w    #TIOCSBRK,d0
          beq       .m003
          cmpi.w    #TIOCIBAUD,d0
          beq       .m004
          cmpi.w    #TIOCOBAUD,d0
          beq       .m005
          cmpi.w    #TIOCGFLAGS,d0
          beq       .m006
          cmpi.w    #TIOCSFLAGS,d0
          beq       .m007
          cmpi.w    #TIOCCTLMAP,d0
          beq       .m008
          cmpi.w    #TIOCCTLGET,d0
          beq       .m009
          cmpi.w    #TIOCCTLSET,d0
          beq       .m010
          cmpi.w    #TIONOTSEND,d0
          beq       .m011
          cmpi.w    #TIOCFLUSH,d0
          beq       .m012
          moveq.l   #EINVFN,d0       ;invalid function number, ## ??? passende Meldung
          bra       .ende
.ok_ende: 
          moveq.l   #0,d0            ;OK
.ende:    
          rts       

.m000:    
;FIONREAD
;Anzahl der ohne Warten lesbaren Byte auf der Adresse hinterlassen
          moveq.l   #0,d1
          move.w    $8+m1_iorec,d1   ;Schreibz
          sub.w     $6+m1_iorec,d1   ;Lesez
          bcc       .m000a
          add.w     $4+m1_iorec,d1
.m000a:   move.l    d1,(a1)          ;Anzahl belegter PlÑtze = vorhandene Byte
          bra       .ok_ende

.m001:    
;FIONWRITE:
;Anzahl der ohne Warten schreibbaren Byte auf der Adresse hinterlassen
          moveq.l   #0,d1
          move.w    $e+$6+m1_iorec,d1             ;Lesez
          sub.w     $e+$8+m1_iorec,d1             ;Schreibz
          bhi       .m001a
          add.w     $e+$4+m1_iorec,d1
.m001a:   subq.l    #2,d1
          bpl       .m001b
          moveq.l   #0,d1            ;nur zur Sicherheit, dÅrfte nie - werden
.m001b:   move.l    d1,(a1)          ;Anzahl freier PlÑtze
          bra       .ok_ende

.m002:    
;TIOCCBRK: Break inaktivieren
;Break lîschen: RTS =Low, TxINT freigegeben
;(TxINT wird erforderlichenfalls durch den Interrupt gesperrt)
          bclr.b    #6,ioo_acc+m1_iorec           ;Annahme Bit5 war 1
          move.b    ioo_acc+m1_iorec,macia_c
          bra       .ok_ende

.m003:    
;TIOCSBRK: Break aktivieren
;Break setzen: RTS =Low, TxINT gesperrt, Break senden
          ori.b     #$60,ioo_acc+m1_iorec         ;Schatten
          move.b    ioo_acc+m1_iorec,macia_c
          bra       .ok_ende

;Break wird nie automatisch zurÅckgesetzt, auch nicht bei Programmabsturz


.m004:    
;TIOCIBAUD, genau wie TIOCOBAUD
.m005:    
;TIOCOBAUD
;Baudrate erfragen/setzen, DTR beeinflussen
          move.l    (a1),d0          ;speed
          bpl       .m005a
.m005ar:  
;nur erfragen
          move.l    a1,-(sp)         ;sichern
          moveq.l   #-1,d0           ;uspeed erfragen
          move.l    d0,-(sp)
          move.w    #SETUSPEED,-(sp)
          bsr       m1_rsconf        ;Direktaufruf Spezialfunktion
          addq.l    #6,sp
          movea.l   (sp)+,a1
          move.l    d0,(a1)
          bra       .ok_ende
.m005a:   
          bne       .m005b
          bsr       .dtr_reset       ;DTR inaktiv
          bra       .m005ar          ;noch Speed erfragen
.m005b:   
;setzen bzw. niedrigere liefern
          move.l    a1,-(sp)         ;sichern
          move.l    d0,-(sp)
          move.w    #SETUSPEED,-(sp)
          bsr       m1_rsconf
          addq.l    #6,sp
          movea.l   (sp)+,a1
          bclr.l    #31,d0           ;test and clear
          beq       .m005bo          ;ok, speed eingestellt
          move.l    d0,(a1)          ;speed-Vorschlag sichern
          moveq.l   #ERANGE,d0       ;Fehlermeldung
          bra       .ende
.m005bo:  
          move.l    d0,(a1)          ;alte speed sichern
          bsr       .dtr_set         ;DTR aktiv
          bra       .ok_ende


.m006:    
;TIOCGFLAGS
;Lesen der öbertragungsprotokollparameter
;da Rsconf den Handshakemodus nicht liefert, wird alles direkt zugegriffen
          moveq.l   #$1c,d2
          and.b     ioo_acc+m1_iorec,d2
          lsr.w     #1,d2            ;Bit3..1 wegen WORD-Zugriff
          move.w    .m006tab(pc,d2.w),d1          ;LÑnge, Parity, Stoppbits
          moveq.l   #3,d0            ;mask
          and.b     ioo_hsm+m1_iorec,d0           ;get direct: handshake mode
          moveq.l   #12,d2
          lsl.w     d2,d0            ;XON/XOFF & RTS/CTS
          or.w      d0,d1
          move.w    d1,(a1)          ;Wert ablegen
          bra       .ok_ende
.m006tab: 
;ACIA-Control Bit4..2 in Bit3..1 als Index, out: "flags"
          DC.w $4007,$8007,$4005,$8005
          DC.w $0003,$0001,$4001,$8001


.m007:    
;TIOCSFLAGS: Setzen der öbertragungsprotokollparameter
;setze LÑnge&ParitÑt&Stoppbits direkt
          move.w    (a1),d2          ;Wert holen
          andi.w    #$cfff,d2        ;Handshake erstmal raus
          moveq.l   #2*7,d1
.m007se:  
          cmp.w     .m006tab(pc,d1.w),d2
          beq       .m007f           ;gefunden
          subq.w    #2,d1
          bpl       .m007se
          moveq.l   #ERANGE,d0       ;Fehler: LÑnge&ParitÑt&Stoppbit unmîglich
          bra       .ende
.m007f:   
          lsl.b     #1,d1            ;nach Bit4..2
          moveq.l   #$e3,d2          ;Maske
          move.w    sr,-(sp)
          ori.w     #$700,sr         ;INTERRUPTSPERRE
          and.b     ioo_acc+m1_iorec,d2           ;Schatten
          or.b      d1,d2
          move.b    d2,ioo_acc+m1_iorec
          move.b    d2,macia_c       ;Hardware
          move.w    (sp)+,sr         ;INTERRUPTS FREI

;Rsconf ist einfachster Weg, den Handshake zu initialisieren
          moveq.l   #-1,d0
          move.l    d0,-(sp)         ;SCR und TSR nicht Ñndern
          move.l    d0,-(sp)         ;RSR und UCR nicht Ñndern
          move.w    (a1),d2          ;Wert holen
          moveq.l   #12,d1
          lsr.w     d1,d2            ;Handshakebits nach Bit1-0
          andi.w    #3,d2
          move.w    d2,-(sp)         ;fÅr flowctl (wird in D2 noch gebraucht)
          move.w    d0,-(sp)         ;-1 fÅr speed nicht Ñndern
          IFNE 1     ;#############################
;bei obigen Schnittstellen ist RTS/CTS unmîglich:
          moveq.l   #ERANGE,d0
          subq.w    #2,d2            ;statt cmp
          beq       .m007er          ;RTS/CTS-Versuch -> Fehler
          ENDC 
;Direktaufruf wegen gleicher Registerkillkonvention mîglich
          bsr       m1_rsconf
          moveq.l   #0,d0            ;OK
.m007er:  
          lea       12(sp),sp
          bra       .ende


.m008:    
;TIOCCTLMAP
;Erfrage I/O-Lines and Signals
          move.l    #TIOCM_RER,(a1)+ ;erstmal nichts
          moveq.l   #0,d0            ;zum lîschen
          move.l    d0,(a1)+         ;no callback activate
          move.l    d0,(a1)+         ;no callback inactivate
          move.l    d0,(a1)+         ;no signal
          move.l    d0,(a1)+         ;no signal
          move.l    d0,(a1)+         ;no extension
          bra       .ok_ende


.m009:    
;TIOCCTLGET
;Abfragen der I/O
          moveq.l   #0,d0
;Fehlerbits nur liefern und lîschen, wenn danach gefragt
          lea       m1_iorec,a2
          move.w    #TIOCM_RER,d1
          and.w     2(a1),d1         ;Lowword des LONG
          beq       .m009g
          moveq.l   #$70,d2
          and.b     ioo_rsr(a2),d2   ;6:parity 5:overrun 4:frame  error
          beq       .m009g           ;kein Fehler
          eor.b     d2,ioo_rsr(a2)   ;nur eben gelesene Fehler lîschen
          or.w      d1,d0            ;D1 enthÑlt noch TIOCM_RER
.m009g:   
          move.l    d0,(a1)          ;Bitsammlung ablegen
          bra       .ok_ende


.m010:    
;TIOCCTLSET
;Setzen der I/O-Lines
          move.l    (a1),d0
          bra       .ok_ende


.dtr_set: 
;DTR aktivieren
          IFNE 0     ;########### nur dieser hat DTR
          moveq.l   #$ef,d2          ;DTR ist Bit4, L-aktiv
          move.w    sr,d1
          ori.w     #$700,sr         ;INTERRUPTSPERRE
          move.b    #$0e,sndchp      ;Registerauswahl
          and.b     sndchp,d2
          move.b    d2,2+sndchp      ;DTR schreiben
          move.w    d1,sr            ;Interruptsperre Ende
          ENDC 
          rts       

.dtr_reset:         
;DTR deaktivieren
          IFNE 0     ;############ nur dieser hat DTR
          moveq.l   #$10,d2          ;DTR ist Bit4, L-aktiv
          move.w    sr,d1
          ori.w     #$700,sr         ;INTERRUPTSPERRE
          move.b    #$0e,sndchp      ;Registerauswahl
          or.b      sndchp,d2
          move.b    d2,2+sndchp      ;DTR schreiben
          move.w    d1,sr            ;Interruptsperre Ende
          ENDC 
          rts       


.m011:    
;TIONOTSEND
          bsr       m1_tionotsend
          move.l    d0,(a1)          ;Anzahl ungesendeter Byte
          bra       .ok_ende


.m012:    
;TIOCFLUSH
;verschiedene Arten des Pufferlîschens
          move.l    a1,d0            ;Parameter (hier kein Zeiger)
          bmi       .m012a           ;send all with user defined timeout
          beq       .m012b           ;send all with system timeout
          cmpi.l    #4,d0
          bcs       .m012c           ;1..3: clear buffers
          moveq.l   #EINVFN,d0       ;error: subsubfunction not supported
          bra       .ende

.m012a:   
;send all with user defined timeout
          moveq.l   #0,d2
          sub.l     d0,d2            ;(sub because -tout)
.m012ax:  
;send all with timeout in D2.l
          add.l     _hz_200,d2       ;wait max. until D2.l
.m012a0:  
          bsr       m1_tionotsend
          tst.l     d0
          beq       .ok_ende
;### simple wait loop in this implementation
          cmp.l     _hz_200,d2
          bcc       .m012a0          ;continue waiting
          moveq.l   #EDRVNR,d0
          bra       .ende            ;error: timeout

.m012b:   
;send all with system timeout
          move.l    #4000,d2         ;#### fest auf 20 Sekunden,
;#### spÑter baudraten- und DatenmengenabhÑngig
          bra       .m012ax

.m012c:   
;1..3: clear buffers
          btst.l    #1,d0
          beq       .m012c1
;Bit1 =1: clear transmitter buffer (2, 3)
          clr.l     ioo_trp+m1_iorec ;simply reset r+w pointer
.m012c1:  
          btst.l    #0,d0
          beq       .m012c6
;Bit0 =1: clear receiver buffer (1, 3)
          clr.l     ioo_rrp+m1_iorec ;reset r+w pointer
          move.b    ioo_hsm+m1_iorec,d1           ;handshake?
          beq       .m012c6          ;no handshake
;handshake
          sf        ioo_re+m1_iorec  ;EmpfÑnger freigeben
          move.w    sr,d2
          ori.w     #$0700,sr        ;sonst kînnten noch Interrupts erfolgen
          btst      #1,d1            ;welcher Handshake?
          beq       .m012c2          ;XON/XOFF (kein RTS/CTS)
;########## RTS aktiv (TTL-Low) schalten
          bra       .m012c3
;XON/XOFF
.m012c2:  
          moveq.l   #xon,d1          ;XON bei XON/XOFF-Handshake
          btst.b    #1,macia_c       ;Interrupts sind schon gesperrt
          beq       .m012c4          ;Senderegister voll, XON spÑter senden
;Interrupt lîschen bei ACIA nicht erforderlich/mîglich
          move.b    d1,macia_d       ;XON sofort senden
          moveq.l   #0,d1            ;nichts spÑter senden
.m012c4:  
          move.b    d1,ioo_tci+m1_iorec
.m012c3:  
          move.w    d2,sr            ;INTERRUPTS FREI
.m012c6:  
          bra       .ok_ende


m1_tionotsend:      
;Anzahl der noch nicht gesendeten Byte ermitteln, z.B. fÅr TIONOTSEND
          moveq.l   #0,d0            ;Anzahl der Byte im Puffer
          move.w    ioo_twp+m1_iorec,d0           ;Schreibz
          sub.w     ioo_trp+m1_iorec,d0           ;Lesez
          bcc       .ns0
          add.w     ioo_tbl+m1_iorec,d0
.ns0:               ;und dazu Zeichen in Hardware
          btst.b    #1,macia_c
          bne       .ns1             ;Hardware-Puffer ist frei
          addq.l    #1,d0            ;(mind.) 1 Zeichen im ACIA
.ns1:     
          rts       

;----------------------------------------------------------------------

c_hog_conf:	dc.w 0	;<>0 fÅr Mehrfachîffnen erlaubt

;----------------------------------------------------------------------

;Datenstruktur des RSVF-Cookies
;Name zum Objekt
          EVEN 
m1_name:  
          DC.b 'MIDI',0
          EVEN 

rsvflist: 
          DC.l m1_name              ;Zeiger auf Namen
          DC.b $e0,0
rsvf_binr:          DC.b 6,0        ;Bios-GerÑte-Nummer wird eingetragen
rsvf_next:          
          DC.l 0   ;erstmal NIL-Zeiger, Ende der Liste
          DC.b 0,0,0,0

;Adr. des ersten nichtresidenten Byte, fÅr zus. Speichervergabe
first_unresi:       DC.l prg_ende   ;Anfangswert

;----------------------------------------------------------------------
          DC.l 0
prg_ende:           ;muû hinter dem Letzten resident zu haltenden stehen


          INCLUDE "CA_FLUSH.S"


sum1ini:  
;Supervisorteil MIDI-Ini
          move.b    #$03,macia_c     ;ACIA-Reset
;Der Reset ist unbedingt nîtig, sonst wollen manche ACIA nach Einschalten nicht
;TOS macht den Reset bereits, aber MagiCMac nicht
          tst.w     sy_conf
          beq       .vi4             ;direkt im MFP-I4-Int hÑngen
          move.w    #$4e75,INIPA_I0  ;RTS reinpatchen
          bsr       ca_flush         ;Code gÅltig machen
          movea.l   my_ikbdsys,a0    ;midisys-Vektor ist 4 Byte davor
          move.l    #m_midisys,-4(a0)
          bra       .mii
.vi4:     
          move.l    #i_mfp_acia,iva_mfp_acia      ;Interruptvektor
.mii:     
          move.l    #$0085ffff,-(sp) ;scr nicht Ñndern, tsr =$85(Sender an, kein Break)
          move.l    #$008a0001,-(sp) ;ucr =$8A(8N1, no parity), rsr =$01
          move.l    #$00000000,-(sp) ;kein Handshake, 31250 Bd
          bsr       m1_rsconf        ;Direktaufruf
;Rsconf initialisiert ACIA und Int.zeug selbst
          lea       12(sp),sp

;Wenn TOS >=1.02, auch die xco*-Vektoren fÅr Original-MIDI belegen
          movea.l   _sysbase,a0
          cmpi.w    #$0102,2(a0)
          bcs       .n_xc            ;<1.02 hat kein xco*
          lea       m1_routtab(pc),a0
          move.l    (a0)+,12+$51e    ;3
          move.l    (a0)+,12+$53e    ;3
          move.l    (a0)+,16+$55e    ;MIDI=4 bei Bcostat
          move.l    (a0)+,12+$57e    ;3
.n_xc:    

;Wenn gewÅnscht, auch Original-MIDI-Iorec und Midiws im XBIOS
          tst.w     omix_conf
          beq       .n_om
          move.l    va_xbios,oldxbiosv
          move.l    #t14_xbios,va_xbios
.n_om:    

          rts       


sursini:  
;Supervisorteil RSVF-Ini
;EinhÑngen in RSVF: hÑnge mich vor die Kette davor. WÑre das Objekt,
;auf das mein Verkettungszeiger wiese, ein End- oder Verkettungsobjekt,
;so wird es Åbersprungen(=herausgeworfen).
          move.l    #'RSVF',-(sp)
          bsr       cookie_find
          addq.l    #4,sp
          tst.l     d0
          sne       ok_rsvf          ;je nach Vorhandensein
          beq       .kein_rs
          movea.l   d0,a0            ;(keine FlagÑnderung)
          movea.l   4(a0),a1         ;Zeiger auf erstes RSVF-Objekt
          move.l    a1,rsvf_next     ;hÑnge alte Obj. an mich (evtl NIL-ptr)
          move.l    #rsvflist,4(a0)  ;und meine Adr. in Cookie
.kein_rs: 

          rts       


;Installationssubroutinen erzeugen
	usmc_gd_drv_del
	usmc_gd_drv_ins



;Beginn der Installation
starti:   
          bsr       prints
          DC.b $1b,'p',' Fast routines for MIDI ',$1b,'q',cr,lf
          DC.b '(C) SWB Harun Scheutzow 1997-11-01',cr,lf,0
          EVEN 

          move.w	hog_conf,c_hog_conf

          move.w    #$22,-(sp)
          trap      #14              ;XBIOS Kbdvbase
          addq.l    #2,sp
          add.l     d0,my_ikbdsys    ;Adr., wo der Vektor steht
;wird auch im folgenden Superteil benutzt


;1.) GEMDOS-Devices lîschen, damit sich eventuell vorhandene alte
;Treiber sauber lîschen kînnen.
          lea       m1_iname,a0      ;MODEM2
          bsr       gd_drv_del
          tst.l     d0
          beq       .gd_ok
          bsr       prints
          DC.b "*** Error: Fdelete failed",bell,bell,cr,lf,0
          EVEN
          bra       init_end        ;Fehler
.gd_ok:   


;2.) Die Hardware Åbernehmen und initialisieren.
          pea       sum1ini          ;Supervisorteil
          move.w    #38,-(sp)
          trap      #14              ;XBIOS Supexec
          addq.l    #6,sp


;3.) GEMDOS-Treiber eintragen.
;############ hier fehlen noch die Fehlerchecks!!!!!######
;sollte aber keine Dcntl-Fehler geben, oder?
          lea       m1_drvr,a0       ;Datenblock
          lea       m1_iname,a1      ;Name
          bsr       gd_drv_ins


;4.) Die Schnittstellen im BIOS/XBIOS eintragen.
          pea       m1_routtab
          move.w    #MAPT_APP,-(sp)
          move.w    #44,-(sp)
          trap      #14              ;XBIOS Bconmap (ext: MAPT_APP)
          addq.l    #8,sp
          tst.l     d0
          bne       .ib_ok
          bsr       prints
	DC.b "***	Error: Load DRVIN.PRG first!?",bell,bell,cr,lf,0
          EVEN 
          bra       init_end
.ib_ok:   
          move.b    d0,rsvf_binr     ;BIOS-Nummer in RSVF-Objekt


;5.) Die Schnittstellen per RSVF bekannt machen.
          pea       sursini          ;RSVF
          move.w    #38,-(sp)
          trap      #14              ;XBIOS Supexec
          addq.l    #6,sp
          tst.b     ok_rsvf
          bne       .rs_ok
          bsr       prints
          DC.b "*** Error: RSVF not found",bell,bell,cr,lf,0
          EVEN 
.rs_ok:   


init_end: 
          bsr       prints
          DC.b cr,lf,0              ;Leerzeile am Ende
          EVEN 


;jetzt erfolgend keine Textausgaben mehr, da die Routine durch IOREC-
;Vergrîûerung zermatscht werden kînnte

;verschiebe die Routinen nach hinten
	usm_ins_move_high	start_moveable,end_moveable,dest_move
          user_cache_flush
          jmp       dest_move

;!!! Die verschobenen Routinen und Daten mÅssen in sich verschiebbar (relativ)
;und mit absoluten BezÅgen auf die auûerhalb "start_moveable".."end_moveable"
;liegenden Dinge sein.
;Sie werden nur am Label "dest_move" angesprungen.


;------------------------------------------


          INCLUDE "PRINTS.S"

          INCLUDE "COOKIE.S"


;------------------------------------------



m1_routtab:         
;Initialwerte fÅr Modem1 MAPTAB zum Kopieren in MAPTAB
          DC.l m1_bconstat
          DC.l m1_bconin
          DC.l m1_bcostat
          DC.l m1_bconout
          DC.l m1_rsconf
          DC.l m1_iorec             ;IOREC-Struktur Adresse



;Konfigurationszeug
          EVEN     ;wichtig!!!
magisch:  DC.b "hAruNs cONfigER",0  ;Magischer String
          DC.l magisch              ;Sicherheitszeiger
          DC.b "RBL: Einstellung der Empfangspuffergrîûe in Byte.",cr,lf
          DC.b "Standard: 256,  Minimum: 16,  Maximum: 65534",cr,lf,0
          EVEN 
          DC.w $0101                ;Cmd LONG-Liste, 1 StÅck
rbl_conf: DC.l 256

          DC.b "TBL: Einstellung der Sendepuffergrîûe in Byte.",cr,lf
          DC.b "Standard: 256,  Minimum: 16,  Maximum: 65534",cr,lf,0
          EVEN 
          DC.w $0101                ;Cmd LONG-Liste, 1 StÅck
tbl_conf: DC.l 256

          DC.b "OMIX: Funktionen Iorec und Midiws des Original-MIDI im",cr,lf
          DC.b "XBIOS bereitstellen?",cr,lf,0
          EVEN 
          DC.w 0   ;Entscheidung
omix_conf:          DC.w -1         ;ja

          DC.b "MISY: KBDVECS.midisys anstelle des MFP-I4 benutzen?",cr,lf,0
          EVEN 
          DC.w 0   ;Entscheidung
sy_conf:  DC.w 0   ;Nein

	dc.b "HOG: Mehrfaches Schnittstellenîffnen generell erlauben?",cr,lf
	dc.b "Ja   = wie unter TOS",cr,lf
	dc.b "Nein = Normalzustand unter MagiC",cr,lf,0
          DC.w 0   ;Cmd Entscheidung
hog_conf: DC.w -1  ;ja

          DC.b 0   ;Nullstring als Ende-Kennung
          EVEN 



start_moveable:     
;zu verschiebende Routinen, nur absolute Referenzen auf auûerhalb Liegendes
;nur relative intern
          move.l    rbl_conf,d0      ;EmpfangspufferlÑnge
          move.l    tbl_conf,d7      ;SendepufferlÑnge
          lea       m1_iorec,a0      ;Zeiger auf EmpfangsIOREC
          bsr       make_buf
          lea       ioo_tba+m1_iorec,a0           ;Zeiger auf SendeIOREC
          move.l    d7,d0
          bsr       make_buf

          clr.w     -(sp)
          move.l    first_unresi,d0
          subi.l    #(start-$100),d0
          move.l    d0,-(sp)         ;residente LÑnge
          move.w    #$31,-(sp)
          trap      #1               ;GEMDOS Ptermres


	usmc_make_buf	;generate subroutine


end_moveable:       
;Ende des zu verschiebenden Bereiches


          BSS 
          EVEN 
          DS.b 65536*2              ;Sicherheitsabstand fÅr zwei max. Puffer
ok_rsvf:  DS.b 1
          EVEN 
dest_move:                           ;Verschiebeziel
          DS.b end_moveable-start_moveable       ;Platz fÅr Routinen

          DS.l $400                 ;Stack-Platz nur fÅr Initialisierung



;History
;1997-11-01
;einzelne RSVF-Verkettungs- oder End-Objekte werden nicht mehr beseitigt
