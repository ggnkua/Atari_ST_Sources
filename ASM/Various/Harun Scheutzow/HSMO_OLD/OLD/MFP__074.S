;Auf der Kommandozeile wird das Symbol XX_FOR_THIS definiert mit
;einem Wert von 0, 1, 2, 3 um die Hardware festzulegen.
;Auf der Kommandozeile wird der Name des Zielfiles vorgegeben.


;Neue BIOS- und GEMDOS- Routinen fÅr eine MFP-Schnittstelle, wÑhlbar beim
;Assemblieren Åber Symbol XX_FOR_THIS:
;0: ST-MFP, MODEM1 fÅr (Mega)ST(E), TT, Stacy, STBook
;1: TT-MFP, SERIAL1 des TT oder Bastellîsung ohne HHS
;2: ST-MFP, MODEM1 im Falcon
;3: TT-MFP, Bastellîsung als SERIAL1 mit HHS


;Diese XX_FOR_THIS werden umgewandelt in interne Konfigflags, von denen
;nur genau eins <>0 ist, alle anderen sind =0.

;<>0: ST-MFP auf MODEM1 mit HHS
FOR_STMFP           = (0=XX_FOR_THIS)

;<>0: TT-MFP auf SERIAL1 ohne HHS (oder Bastellîsung ohne HHS)
FOR_TTMFP           = (1=XX_FOR_THIS)

;<>0: ST-MFP auf MODEM1 ohne HHS
FOR_FALCON          = (2=XX_FOR_THIS)

;<>0: TT-MFP auf SERIAL1 Bastellîsung mit HHS
FOR_BASTEL          = (3=XX_FOR_THIS)


;Generelle Einstellungen fÅr GEN-Assembler
	MACHINE	MC68000
	OPT	ATARI
	OPT	OW-,O1+,O2+,O3+,O4+,O5+,O8+,O9+
;folgendes wÅrde ein Warning je optimierbaren VorwÑrtssprung ergeben,
;der aber nicht optimiert wird, weil GEN es nicht kann.
;;;;;;	OPT	O6+,OW6+



;Das DRVIN*.PRG muû resident sein oder ein entsprechendes Mag!X>2.00 laufen.


          INCDIR "E:\AHSMOD\LIB\"
          INCLUDE "MISC_DEF.S"
          INCLUDE "IOREC.S"
          INCLUDE "ERRNO.S"
	INCLUDE "SER_MACS.S"


;--------------------------------------------------------


          TEXT 
start:    bra       starti
;Sprung nach hinten, damit mîglichst wenig resident bleibt

          INCLUDE "CA_FLUSH.S"

;Im Kommandozeilenbereich liegen kurzzeitig die Sende&Empfangspuffer
;PufferlÑngen nur ganz kurz bedeutsam (zusammen max. 128 Byte)
recbuflen           = 16
trabuflen           = 16
m1_rbuf   = start-(recbuflen+trabuflen)           ;Empfangspuffer
m1_tbuf   = start-trabuflen          ;Sendepuffer


;==========================================================================
;ermittle aus den FOR_* einige Werte:
          IFNE FOR_STMFP|FOR_FALCON
x_mfp     = mfp
iva_x_mfp_cts       = iva_mfp_cts
iva_x_mfp_ter       = iva_mfp_ter
iva_x_mfp_tbe       = iva_mfp_tbe
iva_x_mfp_rer       = iva_mfp_rer
iva_x_mfp_rbf       = iva_mfp_rbf
          ENDC 
          IFNE FOR_TTMFP|FOR_BASTEL
x_mfp     = mfp_tt
iva_x_mfp_cts       = $148
iva_x_mfp_ter       = iva_ttmfp_ter
iva_x_mfp_tbe       = iva_ttmfp_tbe
iva_x_mfp_rer       = iva_ttmfp_rer
iva_x_mfp_rbf       = iva_ttmfp_rbf
          ENDC 


;------------

;neue Interruptroutinen fÅr Modem1
;Sie nutzen die gleiche IOREC-Struktur wie die alten, sind aber
;eigenstÑndig, kînnen also schrittweise ausgetauscht werden.
;Es muû nur ein neues Rsconf her, daû die Interruptvektoren je nach
;Handshakemodus Ñndert.

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



;Immer erst den MFP-Status lesen, wenn man ihn lesen will,
;dann das Byte lesen oder schreiben,
;sonst killt man beim Statuslesen schon den nÑchsten Interrupt.

;Die Originalroutinen schreiben alle das RSR / TSR nach +$1c / +$1d,
;aber wozu ist das gut? Wird vom TOS nie ausgewertet. FÅr High Speed
;weglassen! Zum Lesen&RÅcksetzen einer Fehlermeldung ist es doch nur
;in den Fehlerinterrupts des MFP sinnvoll und notwendig.
;-> $SK0, Åberall dort ist obiges auskommentiert

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

;Der MFP setzt zuerst das entsprechende Bit im Statusregister
;(z.B. Sendepuffer leer), meldet einen Interrupt in IPRA bzw. IPRA an und
;aktiviert dann die Interruptleitung zur CPU. Deshalb muû eine Abfrage der
;Statusregister immer unter Interruptsperre erfolgen und wenn z.B.
;Senderegister leer, muû noch durch Schreiben einer 0 in dem Bit nach IPRx
;der Interrupt wieder deaktiviert werden, wenn man das Senderegister direkt
;nachladen will. In IPRx und ISRx kînnen Bits per CPU nur auf 0 gelîscht,
;aber nie auf 1 gesetzt werden, deshalb uninteressante Bits beim Schreiben
;eines Bytes auf 1 lassen.

;-------------------------------------------------------------------------

;4er-Zyklenangaben ohne RTE und die Interruptannahme. Das sind
;zusÑtzlich etwa 10.

;Makros fÅr die MFP-Routinen


mfp_rfx   MACRO
;Parameter: mfp_bas,ior_adr,op_hs
;Interrupt MFP-Empfangsregister voll
; fÅr kein Handshake, op_hs = 0
; fÅr RTS/CTS (HardwareHS), op_hs = 1
;4er-Zyklen normalerweise auf 68000 etwa: 44 (ohne), 54 (HardwareHS)
          movem.l   d1/a1,-(sp)
;$SK0     move.b    $2a+\1,$1c+\2          ;RSR sichern
          move.b    $2e+\1,-(sp)            ;Byte aus Empfangsregister
          moveq.l   #1,d1            ;lîsche Bit31-16, und 1 fÅr Incr.
          add.w     ioo_rwp+\2(pc),d1       ;Schreibz holen & erhîhen (in 64K durch .w)
          cmp.w     ioo_rbl+\2(pc),d1       ;im Puffer umlaufen lassen
          bcs.s     .\@nobufend
          moveq     #0,d1
.\@nobufend:        
          cmp.w     ioo_rrp+\2(pc),d1
          beq.s     .\@dende         ;Puffer voll, Byte wegwerfen
          movea.l   ioo_rba+\2(pc),a1       ;Pufferadresse
          move.b    (sp)+,$0(a1,d1.l)             ;Byte -> Puffer
          move.w    d1,ioo_rwp+\2           ;Schreibzeiger aktualisieren
          IFNE \3                 ;Teil nur fÅr Hardwarehandshake
;Anzahl belegter Byte berechnen
          sub.w     ioo_rrp+\2(pc),d1       ;minus Lesezeiger
          bcc.s     .\@inbuf         ;keine Korrektur
          add.w     ioo_rbl+\2(pc),d1       ; sonst plus Puffergrîûe
.\@inbuf: 
          cmp.w     ioo_rhw+\2(pc),d1       ;vergleiche mit High Water Mark
          bcs.s     .\@ende          ;noch kein Hochwasser, hops (wohl angebrachter als BLT)
          tst.b     ioo_re+\2
          bne.s     .\@ende          ;EmpfÑnger schon inaktiv
          st        ioo_re+\2  ;EmpfÑnger sperren
;da IPL6, sind schon alle Interrupts gesperrt
          IFNE FOR_STMFP
          move.b    #$0e,sndchp      ;RTS inaktiv (TTL-High) schalten
          moveq.l   #8,d1
          or.b      sndchp,d1
          move.b    d1,$2+sndchp
          ELSE 
          ori.b     #$08,\1    ;RTS inaktiv fÅr Bastel
          ENDC 
          ENDC    ;nur fÅr Hardwarehandshake - Ende
.\@ende:  
          move.b    #$ef,$e+\1 ;anhÑngigen Interrupt lîschen
          movem.l   (sp)+,d1/a1
          rte       
.\@dende: 
          addq.l    #2,sp
          bra       .\@ende
          ENDM


mfp_rfs   MACRO
;Parameter: mfp_bas,ior_adr,sendeint
;Interrupt MFP-Empfangsregister voll fÅr XON/XOFF (SoftwareHS)
          movem.l   d0/d1/a1,-(sp)
;$SK0     move.b    $2a+\1,$1c+\2  ;RSR sichern
          move.b    $2e+\1,d0  ;Byte aus Empfangsregister
          cmpi.b    #xoff,d0         ;XOFF?
          beq.s     .\@rexoff        ; ja
          cmpi.b    #xon,d0          ;XON ?
          beq.s     .\@rexon         ; ja
          moveq.l   #1,d1            ;lîsche Bit31-16, und 1 fÅr Incr.
          add.w     ioo_rwp+\2(pc),d1       ;Schreibz holen & erhîhen (in 64K durch .w)
          cmp.w     ioo_rbl+\2(pc),d1       ;im Puffer umlaufen lassen
          bcs.s     .\@nobufend
          moveq     #0,d1
.\@nobufend:        
          cmp.w     ioo_rrp+\2(pc),d1
          beq.s     .\@ende          ;Puffer voll, Byte wegwerfen
          movea.l   ioo_rba+\2(pc),a1       ;Pufferadresse
          move.b    d0,$0(a1,d1.l)   ;Byte -> Puffer
          move.w    d1,ioo_rwp+\2           ;Schreibzeiger aktualisieren
;Anzahl belegter Byte errechnen
          sub.w     ioo_rrp+\2(pc),d1       ;minus Lesezeiger
          bcc.s     .\@inbuf         ;keine Korrektur
          add.w     ioo_rbl+\2(pc),d1       ; sonst plus Puffergrîûe
.\@inbuf: 
          cmp.w     ioo_rhw+\2(pc),d1       ;vergleiche mit High Water Mark
          bcs.s     .\@ende          ;noch kein Hochwasser, hops
          tst.b     ioo_re+\2
          bne.s     .\@ende          ;EmpfÑnger schon inaktiv
          st        ioo_re+\2  ;EmpfÑnger sperren und XOFF senden
          moveq.l   #xoff,d0         ;XOFF
;da IPL6, ist schon totale Interruptsperre
          bclr.b    #7,ioo_tsr+\2
          beq.s     .\@trfull        ;Senderegister voll, XOFF spÑter senden
          move.b    d0,$2e+\1  ;XOFF sofort senden
          clr.b     d0               ;lîschen, da schon gesendet
.\@trfull:          
          move.b    d0,ioo_tci+\2
.\@ende:  
          move.b    #$ef,$e+\1 ;anhÑngigen Interrupt lîschen
          movem.l   (sp)+,d0/d1/a1
          rte       
.\@rexoff:          
          st        ioo_te+\2  ;XOFF empfangen, Sender sperren
          bra       .\@ende
.\@rexon: 
          sf        ioo_te+\2  ;XON empfangen, Sender freigeben
;da IPL6, ist schon totale Interruptsperre
          bclr.b    #7,ioo_tsr+\2
          beq.s     .\@ende          ;Senderegister noch voll, keine Aktion
          move.b    #$ef,$e+\1 ;anhÑngigen Interrupt lîschen
          movem.l   (sp)+,d0/d1/a1
          bra       \3        ;Sprung zum Sendeinterrupt
          ENDM 


mfp_tes   MACRO
;Parameter: mfp_bas,ior_adr
;Interrupt MFP-Senderegister leer XON/XOFF (SoftwareHS)
;(hierher springt auch i_mfp_rfs, wenn es senden will)
          move.l    d1,-(sp)
          moveq.l   #0,d1            ;lîsche vor allem Bit31-16, die mÅssen 0 bleiben!
;$SK0     move.b    $2c+\1,$1d+\2  ;TSR sichern
          move.b    ioo_tci+\2(pc),d1       ;wenn hier <>0, das sofort ungeachtet Sperre senden
          beq.s     .\@norm
          sf        ioo_tci+\2 ;lîschen
          move.b    d1,$2e+\1  ;-> Senderegister
          bra.s     .\@ende
.\@norm:  
          move.w    ioo_trp+\2(pc),d1       ;Lesezeiger
          cmp.w     ioo_twp+\2(pc),d1
          beq.s     .\@lend          ;Puffer leider leer
          tst.b     ioo_te+\2
          bne.s     .\@lend          ;darf leider nicht da Sender gesperrt
          addq.w    #1,d1            ;erhîhen, durch .w auf 64KByte beschrÑnkt
          cmp.w     ioo_tbl+\2(pc),d1       ;im Puffer umlaufen lassen
          bcs.s     .\@nobufend
          moveq     #0,d1
.\@nobufend:        
          move.w    d1,ioo_trp+\2           ;akt. Lesez, geht wegen IPL6
          add.l     ioo_tba+\2(pc),d1       ;Pufferadresse dazu
          exg.l     d1,a1            ;genial!
          move.b    (a1),$2e+\1             ;Puffer -> Senderegister
          movea.l   d1,a1            ;nur A1 muû zurÅck
.\@ende:  
          move.b    #$fb,$e+\1 ;anhÑngigen Interrupt lîschen
          move.l    (sp)+,d1
          rte       
.\@lend:  
          st        ioo_tsr+\2 ;setze Bit7: Sendepuffer ist leer
          bra.s     .\@ende
          ENDM 


mfp_ter   MACRO
;Parameter: mfp_bas,ior_adr
;Interrupt MFP-Sendefehler, z.B. wÑhrend BREAK-Sendens
          tst.b     $2c+\1     ;lesen -> lîscht Fehlerstatus
          move.b    #$fd,$e+\1 ;Interrupt lîschen
          rte       
          ENDM 


mfp_rer   MACRO
;Parameter: mfp_bas,ior_adr
;Interrupt MFP-Empfangsfehler
;Overrun, Framing Error, Parity Error, Break Begin, Break End
;(FÅr break end wird dieser Interrupt mit gelîschtem B-Bit aufgerufen.)
;Dummes Verhalten des MFP:
;Ein gesetzter PE oder FE wird nur zurÅckgesetzt, wenn ein neues korrektes
;Zeichen empfangen wird oder man den EmpfÑnger aus und an schaltet.
;Wird dieser Int aufgerufen, weil ein PE oder FE vorliegt, so befindet sich
;das fehlerhafte Zeichen im UDR und muû unbedingt abgeholt werden. Das BF-Bit
;ist deshalb auch gesetzt.
;Im Gegensatz zur MFP-Doku wird beim Break-Begin kein Zeichen ins UDR gelegt,
;d.h. BF wird nicht gesetzt und PE und FE bleiben wie bisher gewesen!
;Wird dieser Int mit OE aufgerufen, so sollte wegen der hîheren PrioritÑt
;der Empfangsint schon kurz vorher das letzte korrekte Zeichen geholt haben und
;es muû BF=0 sein, da angeblich das UDR nicht neu beschrieben wird,
;solange OE=1 ist.
          move.w    d0,-(sp)
          move.b    $2a+\1,d0  ;lesen ->
;lîscht OE-Fehlerstatus, bereitet Break-Lîschen vor,
;fÅr PE und FE wird nur die Interruptanmeldung befriedigt
          bmi.s     .ech             ;Empfangszeichen da
;kein Zeichen: PE und FE nicht auswerten, da alt
          andi.b    #$cf,d0
          bra.s     .nch
.ech:     
;Zeichen da: alle Bits gÅltig zum dazuodern und Zeichen lesen
          tst.b     $2e+\1     ;defektes Z. wegwerfen
.nch:     
          or.b      d0,ioo_rsr+\2           ;aktive Bits sammeln
          move.b    #$f7,$e+\1 ;Interrupt lîschen
          move.w    (sp)+,d0
          rte       
          ENDM 



;Codeerzeugung fÅr die Interruptroutinen fÅr MODEM1 (MFP)

;MFP-Empfangsregister voll, Vektor auf $130 (iva_mfp_rbf)
          IFNE FOR_STMFP|FOR_BASTEL
i_mfp_rfh:          mfp_rfx          x_mfp,m1_iorec,1
          ENDC 
i_mfp_rfs:          mfp_rfs          x_mfp,m1_iorec,i_mfp_tes
i_mfp_rfo:          mfp_rfx          x_mfp,m1_iorec,0

;MFP-Senderegister leer, Vektor auf $128 (iva_mfp_tbe)

i_mfp_teh:          
;Einsprungpunkt RTS/CTS-Handshake (4er Zyklen auf 68000: 43)
;(hierher springt auch i_mfp_cts, wenn es senden will)
          btst      #2,x_mfp         ;teste CTS-Eingang
          bne.s     trin_ncts        ;leider darf ich nicht da CTS inaktiv
i_mfp_teo:          
;Einsprungpunkt kein Handshake (4er Zyklen auf 68000: 38)
          move.l    d1,-(sp)
          moveq.l   #0,d1            ;lîsche vor allem Bit31-16, die mÅssen 0 bleiben!
;$SK0       move.b    $2c+x_mfp,$1d+m1_iorec          ;TSR sichern
          move.w    ioo_trp+m1_iorec(pc),d1       ;Lesezeiger
          cmp.w     ioo_twp+m1_iorec(pc),d1
          beq.s     trin_lend        ;Puffer leider leer
          addq.w    #1,d1            ;erhîhen, durch .w automatisch auf 64KByte beschrÑnkt
          cmp.w     ioo_tbl+m1_iorec(pc),d1       ;im Puffer umlaufen lassen
          bcs.s     trin_nbe
          moveq     #0,d1
trin_nbe: 
          move.w    d1,ioo_trp+m1_iorec           ;akt. Lesez, geht wegen IPL6
          add.l     ioo_tba+m1_iorec(pc),d1       ;plus Pufferadresse
          exg.l     d1,a1            ;genial! (6 Takte)
          move.b    (a1),$2e+x_mfp   ;Puffer -> Senderegister
          movea.l   d1,a1            ;A1 zurÅck, D1 egal (4 Takte)
          move.l    (sp)+,d1
trin_end: 
          move.b    #$fb,$e+x_mfp    ;anhÑngigen Interrupt lîschen
          rte       
trin_lend:          
          move.l    (sp)+,d1
trin_ncts:          
          st        ioo_tsr+m1_iorec ;setze Bit7: Sendepuffer ist leer
          bra.s     trin_end

i_mfp_tes:          mfp_tes          x_mfp,m1_iorec

;Fehlerinterrupts
i_mfp_ter:          mfp_ter          x_mfp,m1_iorec
i_mfp_rer:          mfp_rer          x_mfp,m1_iorec

          IFNE FOR_STMFP|FOR_BASTEL
;Interrupt MFP-IO-Pin CTS Ñndert Pegel, Vektor auf $108 (iva_mfp_cts)
;Int. wirkt nur bei RTS/CTS-Handshake. Wird nur auf H/L-Flanke (die CTS
;wird aktiv Flanke) angesetzt. Ist das Senderegister leer
;und der Puffer nicht, so wird ein Byte gesendet.
i_mfp_cts:          
          bclr      #2,$2+x_mfp      ;nochmal auf H/L-Flanke ansetzen
          move.b    #$fb,$10+x_mfp   ;anhÑngigen Interrupt lîschen
          btst      #1,ioo_hsm+m1_iorec           ;RTS/CTS-Handshake aktiv?
          beq.s     .ende            ;nein
;durch IPL6 sind schon alle Ints gesperrt
          bclr.b    #7,ioo_tsr+m1_iorec
          beq.s     .ende            ;Senderegister nicht leer
          bra       i_mfp_teh        ;Senderegister leer, Sprung in Sendeint.
.ende:    
          rte       
          ENDC 


;Die BIOS-Routinen bconout, bcostat, bconin, bconstat fÅr Modem1

;Benutzte Register: d0, d1, d2, a0, a1 (a2 nicht, obwohl erlaubt)
;Diese Register kînnen auch ohne vorherige Sicherung immer benutzt werden,
;auch wenn sie der BIOS-Dispatcher nicht gesichert hat.


;Modem1, bconout, Zeichenausgabe
;fÅr alle drei Fluûkontrollarten
;Aufruf auch bei anfang+4 mîglich, mit Parameter bei WORD (A0)
xm1_bconout   MACRO
;Parameter: ior_adr,mfp_bas,fwrite_eintrittspunkt
          lea       6(sp),a0         ;Mag!X-gleich, muû sein
          move.w    (a0),d0
          lea       \1,a0
          moveq     #0,d1            ;Bit31-16 muû 0 bleiben!
          move.w    ioo_twp(a0),d1   ;Schreibzeiger holen
          addq.w    #1,d1            ;erhîhen, auf 64KByte beschrÑnkt durch .w
          cmp.w     ioo_tbl(a0),d1	;im Puffer umlaufen lassen
          bcs.s     .\@conbx
          moveq     #0,d1
.\@conbx: movea.l   ioo_tba(a0),a1
          move.b    d0,0(a1,d1.l)    ;Byte -> Puffer
          move.w    d1,ioo_twp(a0)   ;Schreibzeiger aktualisieren
;Eintrittspunkt fÅr fwrite (= * damit es lokale Labels nicht unterbricht)
;A0 muû auf IOREC zeigen, D1.Bit31..16 =0 sein
\3	= *
	movea.l   ioo_tba(a0),a1   ;Pufferadresse, fÅr spÑter

.\@cobfu: move.w    sr,d0            ;damit kein Interrupt zwischendurch
          ori.w     #$700,sr         ; das Senderegister fÅllt
;########## wegen ioo_tsr-Nutzung anstelle MFP-Register braucht man doch
;keine Interruptsperre mehr, oder?
;dann darf die XON/XOFF-Empfangsroutine aber auch nur noch ioo_tsr nutzen
;und nicht mehr das MFP-Register selbst...######
;wegen XON- und CTS-Interrupts nachdenken!!!
          tst.b     ioo_tsr(a0)      ;MFP-Senderegister leer ?
          bpl.s     .\@condl         ;nicht leer
          cmpi.b    #1,ioo_hsm(a0)   ;leer, welcher Handshake ?
          IFNE FOR_STMFP|FOR_BASTEL
          bls.s     .\@conhh         ;nicht RTS/CTS
          btst      #2,\2      ;teste CTS-Eingang
          bne.s     .\@condl         ;leider CTS inaktiv
          ELSE 
          beq.s     .\@costh         ;XON/XOFF
          ENDC 
;kein Handshake, sofort senden
.\@coscd: 
;Wenn Senden erlaubt und Senderegister leer dann selbst senden.
          move.w    ioo_trp(a0),d1   ;Lesezeiger holen
          cmp.w     ioo_twp(a0),d1   ;gleich Schreibzeiger?
          beq.s     .\@coend         ;ja, ein Interrupt war schneller
          addq.w    #1,d1            ;erhîhen, auf 64KByte beschrÑnkt durch .w
          cmp.w     ioo_tbl(a0),d1   ;im Puffer umlaufen lassen
          bcs.s     .\@conbc
          moveq     #0,d1
.\@conbc: 
;$SK0     move.b    $2c+\2,$1d(a0)  ;TSR sichern
          move.b    $0(a1,d1.l),$2e+\2      ;Puffer -> Senderegister
          move.w    d1,ioo_trp(a0)   ;Lesezeiger aktualisieren
          sf        ioo_tsr(a0)      ;Senderegister nicht mehr leer
;################### Knackpunkt, wenn man Interrupts hier zulÑût:
;das "sf" muû vor dem "Puffer -> Senderegister" stehen
;auûerdem muû man Lesezeiger davor aktualisieren########
.\@coend: move.w    d0,sr
          rts                        ;Ende (1)

          IFNE FOR_STMFP|FOR_BASTEL
.\@conhh: bcs.s     .\@coscd         ;kein Handshake, sofort senden
          ENDC 
.\@costh: tst.b     ioo_te(a0)	;XON/XOFF, teste ob Sender freigegeben
          beq.s     .\@coscd         ;Sender frei, Zeichen senden
.\@condl: move.w    d0,sr            ;Interrupts wieder frei
;Freigabe extrem wichtig, sonst lÑuft die Schleife komplett mit IPL 7.
;Anzahl noch freier PlÑtze im Puffer ermitteln
          move.w    ioo_trp(a0),d1	;Lesezeiger
          sub.w     ioo_twp(a0),d1	;minus Schreibzeiger
          bhi.s     .\@coxnx         ;keine Korrektur
          add.w     ioo_tbl(a0),d1   ;plus PufferlÑnge
.\@coxnx: subq.w    #1,d1            ;minus 1 statt cmp #1
          beq.s     .\@cobfu         ;voll, warten auf Leerung(smîglichkeit)
          rts                        ;Ende (2)
          ENDM 


;Modem1, bconin, Zeicheneingabe
;FÅr alle drei Fluûkontrollarten
xm1_bconin           MACRO
;Parameter: ior_adr,mfp_bas,fread_eintrittspunkt
          lea       \1,a0
          moveq     #0,d1            ;Bit31-16 muû 0 bleiben!
          moveq     #0,d0		;beim Returncharacter Bit31-8 =0
          move.w    ioo_rrp(a0),d1	;Lesezeiger holen
.\@cibem: cmp.w     ioo_rwp(a0),d1	;Vergleich mit Schreibzeiger
          beq.s     .\@cibem		;Puffer leer, warten
          addq.w    #1,d1		;Lesezeiger +1 im Puffer umlaufend
          cmp.w     ioo_rbl(a0),d1
          bcs.s     .\@cinbt
          moveq     #0,d1
.\@cinbt: movea.l   (a0),a1		;Pufferadresse
          move.b    $0(a1,d1.l),d0	;Puffer -> Byte
          move.w    d1,ioo_rrp(a0)	;Lesezeiger aktualisieren
;Eintrittspunkt fÅr fread (= * damit es lokale Labels nicht unterbricht)
;A0 muû auf IOREC zeigen
\3	= *
          move.b	ioo_hsm(a0),d2	;Handshakemode holen
          beq.s     .\@ciend		;kein Handshake
;Wenn EmpfÑnger freigegeben, ist lange Wassermarkenrechnung unnîtig.
          tst.b     ioo_re(a0)
          beq.s     .\@ciend		;EmpfÑnger ist freigegeben
;Anzahl belegter Byte berechnen
          move.w    ioo_rwp(a0),d1	;Schreibzeiger
          sub.w     ioo_rrp(a0),d1	;minus Lesezeiger
          bcc.s     .\@cincd		;keine Korrektur
          add.w     ioo_rbl(a0),d1	;sonst LÑnge dazu
.\@cincd: cmp.w     ioo_rlw(a0),d1	;untere Wassermarke
          bhi.s     .\@ciend		;untere W. noch nicht unterschritten
          sf        ioo_re(a0)	;EmpfÑnger freigeben
;FÅr Schnittstellen mit Hardwarehandshake nun Unterscheidung Hard/Soft,
;ohne Hardwarehandshake bedeutet Handshake immer Soft
          IFNE FOR_STMFP|FOR_BASTEL
          btst.l	#1,d2		;welcher Handshake?
          beq.s     .\@cish		;XON/XOFF (kein RTS/CTS)
          IFNE FOR_STMFP
          move.w    sr,d2
          ori.w     #$0700,sr		;INTERRUPTSPERRE
          move.b    #$0e,sndchp	;RTS aktiv (TTL-Low) schalten
          moveq.l   #$f7,d1
          and.b     sndchp,d1
          move.b    d1,$2+sndchp
          move.w    d2,sr		;Interrupts frei
	ENDC
          IFNE FOR_BASTEL
          andi.b    #$f7,\2		;RTS aktiv (TTL-Low) schalten
          ENDC
          rts			;Ende (1)
          ENDC 
.\@cish:  
          move.w    sr,d2
          ori.w     #$0700,sr		;INTERRUPTSPERRE
          moveq.l   #xon,d1          ;XON bei XON/XOFF-Handshake
          bclr.b    #7,ioo_tsr(a0)
          beq.s     .\@citf          ;Senderegister voll, XON spÑter senden
          move.b    d1,$2e+\2		;XON sofort senden
          move.w    d2,sr            ;Interruptlevel wieder herstellen
          rts                        ;Ende (2)
.\@citf:  
          move.b    d1,ioo_tci(a0)	;XON vormerken
          move.w    d2,sr            ;Interruptlevel wieder herstellen
.\@ciend: rts                        ;Ende (3)
          ENDM 



;Erzeugung der MODEM1-BIOS-Routinen
m1_bconstat:
	usm_bconstat	m1_iorec(pc)
	rts
m1_bconin:
	xm1_bconin	m1_iorec,x_mfp,act_in_hs
m1_bcostat:
	usm_bcostat	m1_iorec(pc)
	rts
m1_bconout:
	xm1_bconout	m1_iorec,x_mfp,sendeversuch




;Das neue MODEM1 Rsconf.

ubd_ofs   = 2*16    ;Abstand der Klartextraten vom Beginn der Tabelle

m1_rsconf:          
;Rsconf fÅr Modem1
;kill: D0-D2/A0/A1
          cmpi.w    #SETUSPEED,4(sp)
          bne.s     rsm1uno          ;nicht die erweiterte Funktion
          move.l    ioo_ubd+m1_iorec,d0           ;aktuelle uspeed
          move.l    2+4(sp),d1       ;Parameter uspeed
          bmi       rsm1ende         ;nur abfragen
          move.l    d1,d0
          lea       rsm1tps,a1       ;Baudratentabelle
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
          move.w    sr,d1
          swap.w    d1               ;sichern, Highword nicht nutzen!
          ori.w     #$0700,sr        ;Interruptsperre
          lea       x_mfp,a0         ;notwendig, da movep nur d(ax) erlaubt
          movep.l   $28(a0),d0       ;ucr,rsr,tsr,udr lesen als Returnwert

          move.w    4(sp),d1         ;Parameter speed
          cmpi.w    #$000f,d1
          bhi.s     rsm1nosp         ;hops bei speed zu groû (bzw. negativ)
          move.w    d1,d2            ;Klartexttab mit LONGs
          lsl.w     #2,d2
          lea       rsm1tps,a1       ;Baudratentabelle
          move.l    ubd_ofs(a1,d2.w),ioo_ubd+m1_iorec       ;merke auch als Klartext
          bsr       rsm1_setbd       ;einstellen
rsm1nosp: 
          move.w    $8(sp),d2        ;Parameter ucr
          bmi.s     rsm1fcu0         ;Sprung fÅr nicht Ñndern
          lsl.b     #1,d2            ;Bit7 wegwerfen
          move.b    $28+x_mfp,d1     ;énderungen von ucr.Bit7 nicht zulassen
          lsl.b     #1,d1            ;Bit7 ins X-Flag
          roxr.b    #1,d2            ;altes ucr.Bit7 einfÅgen
          move.b    d2,$28+x_mfp     ;Byte ins ucr-Register des MFP
rsm1fcu0: 
          move.w    $a(sp),d2        ;Parameter rsr
          bmi.s     rsm1fcr0         ;Sprung fÅr nicht Ñndern
          move.b    d2,$2a+x_mfp     ;Byte ins rsr-Register des MFP
rsm1fcr0: 
          move.w    $c(sp),d2        ;Parameter tsr
          bmi.s     rsm1fct0         ;Sprung fÅr nicht Ñndern
          move.b    d2,$2c+x_mfp     ;Byte ins tsr-Register des MFP
rsm1fct0: 
          move.w    $e(sp),d2        ;Parameter scr
          bmi.s     rsm1fcs0         ;Sprung fÅr nicht Ñndern
          move.b    d2,$26+x_mfp     ;Byte ins scr-Register des MFP
rsm1fcs0: 

          move.w    6(sp),d2         ;Parameter flowctl
          cmpi.w    #3,d2
          bhi       rsm1fcbi         ;flowctl ist zu groû
          bne.s     rsm1fcnb         ;flowctl nicht XON/XOFF & RTS/CTS
          moveq.l   #1,d2            ;"beides" Ñndere auf XON/XOFF
rsm1fcnb: 
          IFNE FOR_TTMFP|FOR_FALCON
          cmpi.w    #2,d2
          bne       rss1fcnr
          moveq.l   #0,d2            ;"RTS/CTS" Ñndere auf "OHNE"
rss1fcnr: 
          ENDC 
          cmp.b     $20+m1_iorec,d2  ;vergleiche mit altem
          beq       rsm1nosh         ;neues = altes, keine Sonderaktion, aber
; Int.vekt. setzen und Int.s freigeben
;Das bedeutet, die erste RTS-Aktivierung nach Reset muû ein anderer machen.
          move.b    d2,$20+m1_iorec  ;flowctl speichern (noch in d2 gebraucht)

          clr.w     $1e+m1_iorec     ;EmpfÑnger und Sender (+$1f) freigeben
;Wenn der Empfangspuffer voll ist, gehen evtl. gleich nach dieser
;Umschaltung ein paar Zeichen verloren. Das ist aber TOS-kompatibel.
;Ansonsten muû man umstÑndlich prÅfen, ob der EmpfÑnger freigegeben werden
;darf.

          IFNE FOR_STMFP
          move.b    #$0e,sndchp      ;RTS aktiv (TTL-Low) schalten
          move.b    #$f7,d1
          and.b     sndchp,d1
          move.b    d1,$2+sndchp
          ENDC 
          IFNE FOR_BASTEL
          andi.b    #$f7,x_mfp       ;RTS aktiv (TTL-Low) schalten
          ENDC 

          cmpi.b    #1,d2            ;welcher Handshake?
          bne.s     rsm1nosh         ;kein XON/XOFF
;Bei XON/XOFF-HS ein XON senden, und zwar mit den neuen
;Einstellungen, deshalb erst hier. Hinweis: hier ist IPL7
          bclr.b    #7,ioo_tsr+m1_iorec           ;MFP-Senderegister leer ?
          beq.s     rsm1tbne         ;nicht leer
;$SK0     move.b    $2c+x_mfp,$1d+m1_iorec  ;TSR sichern
          move.b    #xon,$2e+x_mfp   ;XON -> Senderegister
          bra.s     rsm1nosh
rsm1tbne: 
          move.b    #xon,ioo_tci+m1_iorec         ;XON vormerken
rsm1nosh: 
          lsl.w     #3,d2            ;Handshakemode * 8, je 2 longs
          lea       rsm1tiad,a0
          move.l    0(a0,d2.w),iva_x_mfp_tbe      ;Sendepuffer leer Int.
          move.l    4(a0,d2.w),iva_x_mfp_rbf      ;Empfangspuffer voll Int.
          move.l    #i_mfp_ter,iva_x_mfp_ter      ;Fehlerint.vek. setzen
          move.l    #i_mfp_rer,iva_x_mfp_rer
          IFNE FOR_STMFP|FOR_BASTEL
          move.l    #i_mfp_cts,iva_x_mfp_cts      ;CTS-Int.vek. setzen
          bclr.b    #2,2+x_mfp       ;CTS-Int. bei High-Low-Flanke (->aktiv)
          ori.b     #$4,8+x_mfp      ;CTS-Int. in IERx und IMRx freigeben
          ori.b     #$4,$14+x_mfp
          ENDC 
;die MFP-Interrupts freigeben (auch wenn es zum 100. Mal ist)
          ori.b     #$1e,6+x_mfp     ;Sende-, Sendefehler-, Empfangs-,
          ori.b     #$1e,$12+x_mfp   ;Empf.fehler- Int. in IERx und IMRx freigeben
rsm1fcbi: 
;RÅckgabewert in d0: ucr,rsr,tsr,udr in Bit31-0
          swap.w    d1
          move.w    d1,sr            ;alte Interruptmaske
rsm1ende: 
          rts       


rsm1_suchbaud:      
;aufgerufen durch m1_rsconf
;in:   D0.l: zu suchende Klartext-Baudrate
;      A1:   Zeiger auf Baudratentabelle (Teilertab, Klartexttab davor)
;out:  D0.l: mîgliche Klartextspeed
;      D0.bit31: 0= Rate vorhanden
;                1= andere Rate in D0(bit30..0) vorgeschlagen
;      D1.w: wenn Rate vorhanden: Indexnummer zur Klartextspeed
;kill: D0/D1
;Suche neue Baudrate. So kompliziert, damit die Tabelle unsortiert sein kann.
          movem.l   d2-d5,-(sp)
          moveq.l   #-1,d3           ;maximaler Differenzwert (unsigned)
          moveq.l   #-1,d4           ;noch keine kleinere Rate gefunden, Index
          moveq.l   #-1,d5           ;fÅr allerkleinste Rate aus Tabelle
          move.w    #(4*(16-1)),d1   ;index in D1.W, count down, Faktor 4 long
;D1-Highword soll 0 bleiben
.sea:     
          move.l    d0,d2            ;speed
          cmp.l     ubd_ofs(a1,d1.w),d5           ;suche nebenbei kleinste
          bls.s     .nogsm           ; Baudrate der ganzen Tabelle
          move.l    ubd_ofs(a1,d1.w),d5           ;in D5.l
.nogsm:   
          sub.l     ubd_ofs(a1,d1.w),d2           ;ermittle Differenz
          beq.s     .ende            ;Rate genau gefunden
          bcs.s     .nex             ;grîûere Rate
;eine kleinere Rate gefunden
          cmp.l     d3,d2            ;kleinere Rate, mit geringerer Differenz?
          bcc.s     .nex             ; nein
          move.l    d2,d3            ;merke neues Minimum der Differenz
          move.w    d1,d4            ;merke Indexwert dazu
.nex:     subq.w    #4,d1            ;Index weiter
          bcc.s     .sea             ;weiter suchen
;keine genaue Rate gefunden
          move.l    d5,d0            ;niedrigste Bdrate aus ganzer Tab.
          tst.w     d4               ;Index fÅr kleinere Rate gefunden?
          bmi       .lowest          ; nein, niedrigstmîgliche liefern
          move.l    ubd_ofs(a1,d4.w),d0           ; ja, nÑchstniedrigere Bdrate
          move.w    d4,d1            ;Indexwert dazu
.lowest:  
          bset.l    #31,d0
.ende:    
          lsr.w     #2,d1            ;ermittle aus Index die Rsconf-Nummer
          movem.l   (sp)+,d2-d5
          rts       


rsm1_setbd:         
;Baudrate im MFP einstellen
;in:   D1.w gÅltiger Rsconf-Index
;out:  /
;kill: D2.w
          move.b    d1,$22+m1_iorec  ;Parameter speed speichern
          bclr      #0,$2a+x_mfp     ;RS232-EmpfÑnger aus
          bclr      #0,$2c+x_mfp     ;RS232-Sender aus
          andi.b    #$f0,$1c+x_mfp   ;MFP-Timer D Reset
          move.b    rsm1tct(pc,d1.w),$24+x_mfp    ;TDDR (ZÑhler) setzen
          move.b    rsm1tps(pc,d1.w),d2
          lsl.w     #1,d2            ;Bit7 aus Byte raus und merken
          lsr.b     #1,d2            ;Bit7 =0
          or.b      d2,$1c+x_mfp     ;MFP-Timer D Vorteiler setzen
          move.b    $28+x_mfp,d2     ;/16-Bit im UCR beeinflussen
          lsl.b     #1,d2            ;altes Bit7 wegwerfen
          lsr.w     #1,d2            ;neues Bit7 rein
          move.b    d2,$28+x_mfp     ;UCR setzen
          bset      #0,$2a+x_mfp     ;RS232-EmpfÑnger ein
          bset      #0,$2c+x_mfp     ;RS232-Sender ein
          rts       


;BaudratenÅbersetzungstabelle:
rsm1tps:  
;Bit7: Bit7 UCR (=1 fÅr /16, =0 fÅr /1)
;Bit6..4: =0 immer
;Bit3..0: Bit3..0 fÅr Timer-D-Control (Vorteiler)
          DC.b $81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$83,$83
rsm1tct:            ;ZÑhler TDDR
          DC.b 1,2,4,5,8,$a,$b,$10,$20,$40,$60,$80,$8f,$af,$40,$60
;75 und 50 Bd sind nun echte 75 und 50, TOS-Fehler korrigiert.

m1baudtab:                           ;die angehÑngte Klartexttabelle
          DC.l 19200,9600,4800,3600
          DC.l 2400,2000,1800,1200
          DC.l 600,300,200,150
          DC.l 134,110,75,50


;Interruptroutinenadresstabelle (Send/Empf fÅr OHNE, XON/XOFF, RTS/CTS)
rsm1tiad: DC.l i_mfp_teo,i_mfp_rfo
          DC.l i_mfp_tes,i_mfp_rfs
          IFNE FOR_STMFP|FOR_BASTEL
          DC.l i_mfp_teh,i_mfp_rfh
          ENDC 


;IOREC fÅr MODEM1
;Initialisierungswerte: 19200Bd, 8N1, kein Handshake
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
          DC.b 0,$ff                ;RSR-or, Sendereg-leer-Flag (bit7)
          DC.b 0,0 ;ioo_re,ioo_te
          DC.b 0,0 ;kein Handshake, x
          DC.b 0   ;Baudrate
          DC.b $ff ;unbenutzt
          DC.l 19200                ;Klartextrate


;----------------------------------------------------------------------

m1_lseek: moveq.l   #0,d0            ;Position 0 nach seek
          rts                        ;immer so fÅr U:\DEV\-Treiber

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

;!!XX!! #### QUICKIE-Definitionen fÅr einiges ####

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
;delete myself
	pea	rsvflist		;my RSVF entry
	moveq.l	#0,d0
	move.b	rsvf_binr,d0
	move.w	d0,-(sp)		;my BIOS #
	move.w	#MAPT_DEL,-(sp)
	move.w	#44,-(sp)
	trap	#14		;XBIOS Bconmap MAPT_DEL
	lea	10(sp),sp
	move.l	d0,d1
          moveq.l   #EINVFN,d0
          subq.l	#1,d1
	bne.s	.ende		;Error
;##### still primitive delete, because MFP-Interrupts not disabled
;##### and under MagiC my memory not freed
	moveq.l	#0,d0	;OK
.ende:
          rts


;Dcntl kopiert nicht, also Name und Zeiger resident halten
m1_iname: 
          DC.b "U:\DEV\"
          IFNE FOR_STMFP|FOR_FALCON
          DC.b "MODEM1",0
          ENDC 
          IFNE FOR_TTMFP|FOR_BASTEL
          DC.b "SERIAL1",0
          ENDC 
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
;Behandlung rein muû, wird die von bconin/bconout per Reinruf benutzt.


for_fread	MACRO
	movea.l	a2,a0
	bsr	act_in_hs
	ENDM


m1_fread: 
;Fread fÅr MODEM1
;Mag!X-mÑûig
;in:   A0: Zeiger auf Filedeskriptor, ### derzeit Null
;      A1: LONG buffer
;      D0: LONG len
;out:  D0: Anzahl wirklich gelesener Byte oder Fehlercode
;kill: D0-D2/A0-A2
          lea       m1_iorec(pc),a2	;Adr. IOREC
	usm_fread	for_fread		;Macro nutzen
          rts       


buffer_transmit	MACRO
	movea.l	a2,a0
	moveq.l	#0,d1
	bsr	sendeversuch
	ENDM


m1_fwrite:          
;Fwrite fÅr MODEM1
;Mag!X-mÑûig
;in:   A0: Zeiger auf Filedeskriptor oder Null
;      A1: LONG buffer
;      D0: LONG len
;out:  D0: Anzahl wirklich gelesener Byte oder Fehlercode
;kill: D0-D2/A0-A2
	lea	m1_iorec(pc),a2		;Adr. IOREC
	usm_fwrite	buffer_transmit	;Macro nutzen
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
;TIOCCBRK
;Break inaktivieren
          bclr      #3,$2c+x_mfp     ;Break-Bit im TSR rÅcksetzen
          bra       .ok_ende

.m003:    
;TIOCSBRK
;Break aktivieren
          bset      #3,$2c+x_mfp     ;Break-Bit im TSR setzen
          bra       .ok_ende
;Wenn Break gesetzt, gibt es an jeder "Zeichengrenze" einen Sendefehler-
;Interrupt. (wirklich???) Evtl. zur Systementlastung diesen Interrupt hier sperren?
;Auûerdem sollte Break von irgendwem zwangsweise rÅckgesetzt werden,
;weil das setzende Prg z.B. abstÅrzen kînnte. Entweder Fopen oder Rsconf
;sollte Break zurÅcksetzen?


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
          moveq.l   #$10,d0          ;DTR ist Bit4, L-aktiv
          bsr       .dtrrts_or	;DTR inaktiv
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
          moveq.l   #$ef,d0          ;DTR ist Bit4, L-aktiv
          bsr       .dtrrts_and      ;DTR aktiv
          bra       .ok_ende


.m006:    
;TIOCGFLAGS
;Lesen der öbertragungsprotokollparameter
;da Rsconf den Handshakemodus nicht liefert, wird alles direkt zugegriffen
          moveq.l   #$f,d1           ;bit7-0 als AND-Maske
          move.b    $28+x_mfp,d0     ;UCR
          btst.l    #2,d0
          beq       .m006np          ;keine ParitÑt
          bset.l    #15,d1           ;set odd
          btst.l    #1,d0
          beq       .m006np          ;really odd parity
          bclr.l    #15,d1           ;clear odd parity flag
          bset.l    #14,d1           ;even parity
.m006np:  lsr.b     #3,d0            ;Bit/Char & Stoppbits nach Bit3-0
          and.b     d0,d1
          moveq.l   #3,d0            ;mask
          and.b     $20+m1_iorec,d0  ;get direct: handshake mode
          moveq.l   #12,d2
          lsl.w     d2,d0            ;XON/XOFF & RTS/CTS
          or.w      d0,d1
          move.w    d1,(a1)          ;Wert ablegen
          bra       .ok_ende


.m007:    
;TIOCSFLAGS
;Setzen der öbertragungsprotokollparameter
;Rsconf ist umstÑndlich, aber der einzige Weg, den Handshake zu initialisieren
          move.w    (a1),d2          ;Wert holen
          moveq.l   #ERANGE,d0       ;vorsorglich Fehler
          moveq.l   #3,d1            ;teste Stoppbitanzahl
          and.w     d2,d1
          beq       .ende            ;Synchronmode nicht unterstÅtzt!
          moveq.l   #-1,d0
          move.l    d0,-(sp)         ;SCR und TSR nicht Ñndern
          move.w    d0,-(sp)         ;RSR nicht Ñndern
          moveq.l   #$f,d1           ;mask
          and.w     d2,d1
          lsl.b     #3,d1            ;Bit3-0 -> 6-3, Stopps & Bit/Char
          btst.l    #15,d2           ;odd parity?
          beq       .m007no          ;no
          bset.l    #2,d1            ;parity used, odd
.m007no:  btst.l    #14,d2           ;even parity?
          beq       .m007ne          ;no
          ori.b     #$06,d1          ;parity used, even
.m007ne:  bset.l    #7,d1            ;divide by 16, always in async mode
          move.w    d1,-(sp)         ;fÅr das UCR
          moveq.l   #12,d1
          lsr.w     d1,d2            ;Handshakebits nach Bit1-0
          andi.w    #3,d2
          move.w    d2,-(sp)         ;fÅr flowctl (wird in D2 noch gebraucht)
          move.w    d0,-(sp)         ;-1 fÅr speed nicht Ñndern
          IFNE FOR_TTMFP|FOR_FALCON
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
          IFNE FOR_STMFP|FOR_BASTEL
          move.l    #(TIOCM_DTR|TIOCM_RTS|TIOCM_CAR|TIOCM_RNG|TIOCM_CTS|TIOCM_BRK|TIOCM_RER),(a1)+
          ENDC 
          IFNE FOR_FALCON|FOR_TTMFP
          move.l    #(TIOCM_BRK|TIOCM_RER),(a1)+  ;erstmal nichts
          ENDC 
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
          IFNE FOR_STMFP|FOR_BASTEL
;EingÑnge aus MFP
          move.b    x_mfp,d1
          lsr.b     #2,d1            ;Bit1: DCD, 0-aktiv
          bcs       .m009a
          ori.w     #TIOCM_CAR,d0
.m009a:   
          lsr.b     #1,d1            ;Bit2: CTS, 0-aktiv
          bcs       .m009b
          ori.w     #TIOCM_CTS,d0
.m009b:   
          lsr.b     #4,d1            ;Bit6: RING, 0-aktiv
          bcs       .m009c
          ori.w     #TIOCM_RNG,d0
.m009c:   
          ENDC 
          IFNE FOR_STMFP
;AusgÑnge aus Soundchip
          move.w    sr,d2
          ori.w     #$700,sr         ;INTERRUPTSPERRE
          move.b    #$0e,sndchp      ;Registerauswahl
          move.b    sndchp,d1
          move.w    d2,sr            ;Interruptsperre Ende
          ENDC 
          IFNE FOR_BASTEL
;AusgÑnge aus MFP
          move.b    x_mfp,d1
          ENDC 
          IFNE FOR_STMFP|FOR_BASTEL
          lsr.b     #4,d1            ;Bit3: RTS, 0-aktiv
          bcs       .m009d
          ori.w     #TIOCM_RTS,d0
.m009d:   
          lsr.b     #1,d1            ;Bit4: DTR, 0-aktiv
          bcs       .m009e
          ori.w     #TIOCM_DTR,d0
.m009e:   
          ENDC 
;"Fehlerbits" dÅrfen nur zurÅckgesetzt werden, wenn sie erfragt wurden
;(also nicht beim freiwilligen ungefragten Mitliefern)
          lea       m1_iorec,a2
          move.w    #TIOCM_BRK,d1
          and.w     2(a1),d1         ;nur Lowword des LONG
          beq       .m009f
          bclr.b    #3,ioo_rsr(a2)   ;test&reset break
          beq       .m009f           ;kein Break
          or.w      d1,d0            ;TIOCM_BRK steht noch in D1
.m009f:   
          move.w    #TIOCM_RER,d1
          and.w     2(a1),d1         ;nur Lowword des LONG
          beq       .m009g
          moveq.l   #$70,d2          ;6:overrun 5:parity 4:frame  error
          and.b     ioo_rsr(a2),d2
          beq       .m009g           ;kein error
          eor.b     d2,ioo_rsr(a2)   ;lîsche(negiere) nur gelesene Fehler
          or.w      d1,d0            ;TIOCM_RER steht noch in D1
.m009g:   
          move.l    d0,(a1)          ;Bitsammlung ablegen
          bra       .ok_ende


.m010:    
;TIOCCTLSET
;Setzen der I/O-Lines
	movem.l	d3/d4,-(sp)
          move.l    (a1),d3		;D3: ctlmaske
          move.l    4(a1),d4		;D4: ctlvalues
          IFNE FOR_STMFP|FOR_BASTEL
	btst.l	#BITNR_TIOCM_DTR,d3
          beq       .m010a
          btst.l    #BITNR_TIOCM_DTR,d4
          bne       .m010aa		;aktivieren
          moveq.l	#$10,d0		;inaktivieren
          bsr	.dtrrts_or
          bra	.m010a
.m010aa:  moveq.l	#$ef,d0
          bsr	.dtrrts_and
.m010a:   
	btst.l	#BITNR_TIOCM_RTS,d3
          beq       .m010b
          btst.l    #BITNR_TIOCM_RTS,d4
          bne       .m010ba		;aktivieren
          moveq.l	#$08,d0		;inaktivieren
          bsr	.dtrrts_or
          bra	.m010b
.m010ba:  moveq.l	#$f7,d0
	bsr	.dtrrts_and
.m010b:
          ENDC 
	movem.l	(sp)+,d3/d4
          bra       .ok_ende


.dtrrts_and:
;DTR oder RTS aktivieren (L-active)
;in:   D0.B AND-mask (DTR is Bit4, RTS is Bit3)
;kill: D0.B/D1.W
          IFNE FOR_STMFP              ;hat DTR und RTS
          move.w    sr,d1
          ori.w     #$700,sr         ;INTERRUPTSPERRE
          move.b    #$0e,sndchp      ;Registerauswahl
          and.b     sndchp,d0
          move.b    d0,2+sndchp      ;schreiben
          move.w    d1,sr            ;Interruptsperre Ende
          ENDC 
          IFNE FOR_BASTEL             ;hat DTR und RTS
          and.b    d0,x_mfp
          ENDC 
          rts       

.dtrrts_or:
;DTR oder RTS deaktivieren (L-active)
;in:   D0.B OR-mask (DTR is Bit4, RTS is Bit3)
;kill: D0.B/D1.W
          IFNE FOR_STMFP              ;hat DTR und RTS
          move.w    sr,d1
          ori.w     #$700,sr         ;INTERRUPTSPERRE
          move.b    #$0e,sndchp      ;Registerauswahl
          or.b      sndchp,d0
          move.b    d0,2+sndchp      ;schreiben
          move.w    d1,sr            ;Interruptsperre Ende
          ENDC 
          IFNE FOR_BASTEL             ;hat DTR und RTS
          or.b	d0,x_mfp
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
          move.w    ioo_rrp+m1_iorec,d1
          cmp.w     ioo_rwp+m1_iorec,d1
          beq       .m012c6          ;already clear -> no action
          move.l    #1,ioo_rrp+m1_iorec           ;pos. r+w pointer "1 char"
;following kills D0
          bsr       m1_bconin        ;read last char, it actualizes handshake
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
          tst.b     $2c+x_mfp
;teste buffer empty, da der relevante Wert "underrun" nicht stehen bleibt,
;sondern durch Fehlerinterrupt/TSR-Lesen gelîscht wird
          bmi       .ns1             ;Hardware-Puffer ist frei
          addq.l    #1,d0            ;(mind.) 1 Zeichen im MFP
.ns1:     
          rts       

;----------------------------------------------------------------------

c_hog_conf:	dc.w 0	;<>0 fÅr Mehrfachîffnen erlaubt

;----------------------------------------------------------------------

;Datenstruktur des RSVF-Cookies
          EVEN 
          DC.l m1_drvr              ;Zeiger auf Routinentabelle
m1_name:  
          IFNE FOR_STMFP|FOR_FALCON
          DC.b 'MODEM1',0           ;Name zum Objekt
          ENDC 
          IFNE FOR_TTMFP|FOR_BASTEL
          DC.b 'SERIAL1',0
          ENDC 

          EVEN 

rsvflist: 
          DC.l m1_name              ;Zeiger auf Namen
          DC.b $e1,0
rsvf_binr:          DC.b 6          ;Bios-GerÑte-Nummer wird eingetragen
          DC.b 0
rsvf_next:          
          DC.l 0   ;erstmal NIL-Zeiger, Ende der Liste
          DC.b 0,0,0,0

;Adr. des ersten nichtresidenten Byte, fÅr zus. Speichervergabe
first_unresi:       DC.l prg_ende   ;Anfangswert

;----------------------------------------------------------------------
          DC.l 0
prg_ende:           ;muû hinter dem Letzten resident zu haltenden stehen



test_set_tid:       
;Timer D Einstellroutine fÅr Routine sum1test
;in:   D0.B TDDR Wert
;out:  /
;kill: D0/D1
          andi.b    #$f0,$1c+x_mfp   ;Timer D Reset
          move.b    d0,$24+x_mfp     ;Timer D Data (TDDR)
          ori.b     #1,$1c+x_mfp     ;Timer D los, Vorteiler /4

;warte mind. 6 Timer D AblÑufe ab, damit RSVE einrasten kann
;Ich ignoriere, daû Analog-PLLs nicht so schnell einrasten.
          moveq.l   #6,d1            ;Anzahl AblÑufe
.w_tid:   
          move.b    #$ef,$c+x_mfp    ;clear pending Timer D interrupts
          subq.l    #1,d1
          bcs       .w_ende
.w_ntid:  
          btst.b    #4,$c+x_mfp      ;Timer D abgelaufen?
          bne       .w_tid           ; ja
          bra       .w_ntid          ; nein
.w_ende:  
          rts       


sum1test: 
;Supervisorteil MODEM1-Test auf Baudratenwandler
;in:   /
;out:  D0 Info Åber Speeder
;       =0: da ist wohl etwas defekt (langsamer bei 1200 bps)
;       =1: kein Speeder, 1200 stimmt und 110 ist nicht >= 38400
;       =2: Primitiv-Speeder, 1200 ist schneller
;       =3: RSVE o.Ñ., 1200 stimmt, 110 ist viel schneller
;       =4: RSFI (ex RSVEChip), 1200 stimmt, 110 ist schneller
;kill: D0-D2
          move.w    sr,d2
          ori.w     #$700,sr         ;INTERRUPTSPERRE
          andi.b    #$e1,6+x_mfp     ;Sende-, Sendefehler-, Empfangs-,
          andi.b    #$e1,$12+x_mfp   ;Empf.fehler- Int. in IERx und IMRx sperren
          andi.b    #$ef,$14+x_mfp   ;Timer D Int im IMRB sperren aber
          ori.b     #$10,$8+x_mfp    ; im IERB freigeben (damit IPRB setzbar)
          tst.b     x_mfp            ;Zeit verbraten
          tst.b     x_mfp            ;Zeit verbraten
          move.w    d2,sr            ;INTERRUPTS frei

          move.b    #0,$2a+x_mfp     ;rsr, EmpfÑnger aus
          move.b    #4,$2c+x_mfp     ;tsr, Sender aus und H-Pegel
          move.b    #$ff,$26+x_mfp   ;scr, Synchronzeichen wie Ruhepegel
          move.b    #0,$28+x_mfp     ;ucr, 8 Bit synchron, kein P., /1
          move.b    #7,$2c+x_mfp     ;tsr, Sender an, Schleife

;Die Timer D Interruptfrequenz ist doppelt so hoch wie die Frequenz
;am Timer D Ausgang!

;1. Messung bei Timer D wie fÅr 1200 bps, da mit /1 sind es hier
; 19200 bps, ergibt 38400 Hz Interruptfrequenz,
; ergibt 208 CPU-Zyklen (8 MHz) fÅr einen Timer D Ablauf,
; was gerade gut ausreichen dÅrfte fÅr dieses Polling

          move.b    #$10,d0          ;Timer D einstellen wie fÅr 1200
          bsr       test_set_tid

          move.w    sr,d2
          ori.w     #$700,sr         ;INTERRUPTSPERRE

          move.b    #1,$2a+x_mfp     ;rsr, EmpfÑnger an

          moveq.l   #-1,d1           ;ZÑhler fÅr Timer D Interrupts

.tid_int: 
          addq.l    #1,d1            ;zÑhle Timer D AblÑufe
          move.b    #$ef,$c+x_mfp    ;clear pending Timer D interrupts
.no_sync: 
          btst.b    #4,$c+x_mfp      ;Timer D abgelaufen?
          bne       .tid_int         ; ja
          btst.b    #3,$2a+x_mfp     ;Sync-Zeichen gefunden?
          bne       .sync            ; ja
          cmpi.w    #22,d1           ;ab 11 Bitzeiten aufwÑrts: Defekt-Ende
          bcs       .no_sync         ; noch kein Defekt

          move.w    d2,sr            ;INTERRUPTS FREI

          moveq.l   #0,d0            ;D0 =0: da ist etwas defekt
          bra       .r_ende

.sync:    
          move.w    d2,sr            ;INTERRUPTS FREI

;rsr.Bit3 =1, sollte normalerweise nach 8 Bitzeiten passieren
          moveq.l   #2,d0            ;D0 =2: Primitivspeeder
          cmpi.w    #10,d1           ;wenn unter 5 Bitzeiten: stÑndig schnell
          bcs       .r_ende          ; wirklich Primitivspeeder
;(und genauer will ich es nicht wissen)

;1200 bps funktioniert. Damit sind einfache Speeder ausgeschlossen,
;die eine feste Rate oder Analog-PLL bps*X machen.

;2. Messung bei Timer D wie fÅr 110 bps, ergibt mit /1
; "ohne" 1760 bps. "Ohne" also 16 Timer D AblÑufe bis zum Sync.
; Mit RSVE wÑren es etwa 22 Syncs pro Timer D Ablauf,
;  arg zeitkritisch, da nur 104 CPU-Takte pro Sync.
; Mit RSVEChip etwa 1,367 Syncs pro Timer D Ablauf.
;PrÅfe einfach, ob 0, 1 bis 4 oder mehr Syncs pro Timer D Ablauf
;auftreten.

          move.b    #$af,d0          ;Timer D einstellen wie fÅr 110
          bsr       test_set_tid

          move.w    sr,d2
          ori.w     #$700,sr         ;INTERRUPTSPERRE

          moveq.l   #-1,d1           ;ZÑhler fÅr Syncs
          move.b    #$ef,$c+x_mfp    ;clear pending Timer D interrupts
.c0_ntid: 
          btst.b    #4,$c+x_mfp      ;Timer D abgelaufen?
          beq       .c0_ntid         ; nein
          move.b    #$ef,$c+x_mfp    ;clear pending Timer D interrupts
.c_sync:  
          move.b    #0,$2a+x_mfp     ;rsr, EmpfÑnger Reset
          addq.w    #1,d1            ;nÑchster Sync
;####### KRZE war der EmpfÑnger-Reset eventuell zu kurz? Jetzt mit 1x Lesen
;verlÑngert:
	tst.b	x_mfp		;Verzîgerung
          move.b    #1,$2a+x_mfp     ;rsr, EmpfÑnger los
;####### KRZE: oder sollte man hier ein NOP rein fÅr 68030 / 68040?:
	nop			;fÅr 68030/68040???
.c_ntid:  
          btst.b    #3,$2a+x_mfp     ;Sync gefunden?
          bne       .c_sync          ; ja
          btst.b    #4,$c+x_mfp      ;Timer D abgelaufen?
          beq       .c_ntid          ; nein

          move.w    d2,sr            ;INTERRUPTS FREI

;D1 sollte nun 0, 1 bis 4, oder noch mehr enthalten.
          moveq.l   #1,d0            ;D0 =1: kein Speeder
          tst.w     d1
          beq       .r_ende          ;kein Speeder
          moveq.l   #4,d0            ;D0 =4: RSVEChip
          cmpi.w    #5,d1
          bcs       .r_ende          ;RSVEChip
          moveq.l   #3,d0            ;D0 =3: RSVE oder kompatibel

.r_ende:  
;alles aufrÑumen ########
;eigentlich so dringend aufzurÑumen ist da nichts. Naja, MFP steht
;im Synchronmodus etc, aber das macht ja Rsconf spÑter.

          rts       



sum1ini:  
;Supervisorteil MODEM1-Ini
          move.l    #$0085ffff,-(sp) ;scr nicht Ñndern, tsr =$85(Sender an, kein Break)
          move.l    #$008a0001,-(sp) ;ucr =$8A(8N1, no parity), rsr =$01
          move.l    #$00000000,-(sp) ;kein Handshake, 19200Bd
          bsr       m1_rsconf        ;Direktaufruf
;initialisiert MFP und Int.zeug selbst, bis auf RTS-Line
          lea       12(sp),sp

          IFNE FOR_STMFP|FOR_BASTEL
          move.w    sr,d2
          ori.w     #$700,sr         ;INTERRUPTSPERRE
          IFNE FOR_STMFP
          move.b    #$0e,sndchp
          move.b    sndchp,d1
          ELSE     ;FOR_BASTEL
          move.b    x_mfp,d1
          ENDC 
          andi.b    #$f7,d1          ;RTS aktiv (TTL-Low)
;DTR-Beeinflussung
          ori.b     #$10,d1          ;DTR inaktiv (TTL-High)
          tst.w     dtr_conf         ;wie setzen?
          beq       .dtr_set
          andi.b    #$ef,d1          ;DTR aktiv (TTL-Low)
.dtr_set: 
          IFNE FOR_STMFP
          move.b    d1,2+sndchp
          ELSE     ;FOR_BASTEL
          move.b    d1,x_mfp
          ENDC 
          move.w    d2,sr            ;Interrupts frei
          ENDC 

          IFNE FOR_BASTEL
;DDR und VR setzen, da es noch niemand gemacht hat
          andi.b    #$b9,4+x_mfp     ;DDR, Bit6/2/1 Eingang
          ori.b     #$18,4+x_mfp     ;DDR, Bit4/3 Ausgang
          move.b    #$58,$16+x_mfp   ;VR, Vektoren ab $140
          ENDC 

          rts       


sursini:  
;Supervisorteil RSVF-Ini
;EinhÑngen in RSVF: hÑnge mich vor die Kette davor.
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



such_baud:          
;suche die Baudrate in der Tabelle, wenn sie bekannt ist, liefere
;den Tabellenplatz (0, 1, 2, ...)
;in:   D0 Baudrate
;      D2 Anzahl TabelleneintrÑge
;      A1 zeigt auf Tabelle
;out:  D1 Tabellenplatz oder -1 fÅr unbekannt
;kill: A1
          moveq.l   #0,d1
.lookfor: cmp.l     (a1)+,d0
          beq       .found           ;gefunden
          addq.l    #1,d1
          cmp.w     d2,d1            ;schon Ende?
          bcs       .lookfor
          moveq.l   #-1,d1           ;nicht gefunden, Pech
.found:   rts       


m1_routtab:         
;Initialwerte fÅr Modem1 MAPTAB zum Kopieren in MAPTAB
          DC.l m1_bconstat
          DC.l m1_bconin
          DC.l m1_bcostat
          DC.l m1_bconout
          DC.l m1_rsconf
          DC.l m1_iorec             ;IOREC-Struktur Adresse


;Ausgabetexte fÅr die Speeder-Erkennung
spdtxt:             ;die Zeiger auf die Texte
          DC.l .spe_0,.spe_1,.spe_2,.spe_3,.spe_4
.spe_0:   DC.b "MFP-UART defective???",cr,lf,0
.spe_1:   DC.b "MFP without additions.",cr,lf,0
.spe_2:   DC.b "Fixed speedup or Analog PLL.",cr,lf,0
.spe_3:   DC.b "RSVE or compatible found.",cr,lf,0
.spe_4:   DC.b "RSFI found.",cr,lf,0
          EVEN 



;Installation
starti:   
          bsr       prints
          DC.b $1b,'p',' Fast routines for '
          IFNE FOR_STMFP
          DC.b 'ST'
          ENDC 
          IFNE FOR_FALCON
          DC.b 'Falcon'
          ENDC 
          IFNE FOR_TTMFP
          DC.b 'TT'
          ENDC 
          IFNE FOR_BASTEL
          DC.b 'Bastel-TT'
          ENDC 
          DC.b '-MFP ',$1b,'q',cr,lf
          DC.b '(C) SWB Harun Scheutzow 1998-07-25',cr,lf,0
          EVEN 

          move.w	hog_conf,c_hog_conf

;1.) GEMDOS-Devices lîschen, damit sich eventuell vorhandene alte
;Treiber sauber lîschen kînnen.
          moveq.l   #0,d7            ;Fehler wenn am Ende <>0
          lea       m1_iname,a0
          bsr       gd_drv_del
          tst.l     d0
          beq       .gd_ok
          bsr       prints
          DC.b "*** Error: Fdelete failed",bell,bell,cr,lf,0
          EVEN
          bra       init_end        ;Fehler
.gd_ok:   


;2.) Die Hardware Åbernehmen und initialisieren.
          pea       sum1test         ;Test auf Speeder am MFP
          move.w    #38,-(sp)
          trap      #14              ;XBIOS Supexec
          addq.l    #6,sp
          move.l    d0,d7            ;Wert in D7 sichern

          lea       spdtxt,a0        ;Text zum Speeder ausgeben
          lsl.w     #2,d0
          move.l    0(a0,d0.w),-(sp) ;Zeiger auf Text
          move.w    #9,-(sp)
          trap      #1               ;GEMDOS Cconws
          addq.l    #6,sp


          cmpi.w    #4,d7
          bne       .no_rsvechip
;SpezialitÑten fÅr RSVEChip / RSFI
          lea       10+rsm1tps,a0    ;200 bis 50 bps Ñndern
          moveq.l   #$7f,d0          ;/1 anstelle /16
          and.b     d0,(a0)+         ; als MFP-UART-Teiler
          and.b     d0,(a0)+         ; in den RSVEChip-Raten
          and.b     d0,(a0)+
          and.b     d0,(a0)+
          and.b     d0,(a0)+
          and.b     d0,(a0)+
          lea       56+m1baudtab,a0  ;56 = 4*14
          move.l    #153600,(a0)+    ;Klartextraten Ñndern
          move.l    #76800,(a0)+
          move.l	#230400,-24(a0)  ;bei Offset 64-24 = 40 = 4*10
          bra       .hibd_chg        ;restliche Klartextraten Ñndern
.no_rsvechip:       

;Ñndere evtl. Klartextbaudraten
          move.w    yes_rsve,d0      ;RSVE-Cookie setzen (->Raten Ñndern)?
          bne       .hibd_chg        ; ja, Raten Ñndern
          cmpi.w    #2,d7            ;irgendein Speeder da?
          bcs       .no_hibd         ; nein, kein Highspeed
.hibd_chg:          
          lea       44+m1baudtab,a0  ;44 = 4*11
          move.l    #115200,(a0)+    ;fÅr Highspeed-Modem1
          move.l    #57600,(a0)+
          move.l    #38400,(a0)+
.no_hibd: 


;lege eventuell Baudraten um
;darf erst nach der Speeder-abhÑngigen Modifikation der Tabelle
;erfolgen, deshalb hier.
          move.w    #2,d6            ;max. 3 Raten umlegen
          lea       bd_conf,a5
.um_next: 
          move.l    (a5)+,d0         ;hole niedrige Rate
          cmpi.l    #$80000000,d0
          beq       .um_end          ;Platz ungÅltig
          lea       m1baudtab,a1     ;fÅr Ersetzung benutzte Baudrate suchen
          moveq.l   #16,d2           ;Anzahl TabelleneintrÑge
          bsr       such_baud
          tst.l     d1
          bmi       .um_err          ;niedrige Baudrate unbekannt
          move.l    d1,d7            ;Tab.platz merken

          move.l    (a5)+,d0         ;hole hohe Rate
          cmpi.l    #$80000000,d0
          beq       .um_err          ;nur hoher Platz ungÅltig
          lea       m1baudtab,a1     ;zu ersetzende Baudrate suchen
          moveq.l   #16,d2           ;Anzahl TabelleneintrÑge
          bsr       such_baud
          tst.l     d1
          bmi       .um_err          ;hohe Baudrate unbekannt

;Hole den Teilerwert aus der Tabelle und speichere ihn zusammen mit der
;neuen Position (bisher in D7.L), auf der er spÑter einzutragen ist.
          swap.w    d7               ;Positionsindex nach Bit31..16
          lea       rsm1tps,a2
          move.b    0(a2,d1.l),d7    ;Vorteiler
          lsl.w     #8,d7            ;Vorteiler nach Bit16..8
          lea       rsm1tct,a2
          move.b    0(a2,d1.l),d7    ;ZÑhler nach Bit7..0
          move.l    d7,-(sp)         ;auf Stack ablegen

          dbra      d6,.um_next

          bra       .um_end

.um_err:  
          bsr       prints
          DC.b "*** Error: Bad REPL configuration",bell,bell,cr,lf,0
          EVEN 
.um_end:  

;D6.W gibt Anzahl der Elemente auf Stack an: -1 -> 3, 0 -> 2, 1 -> 1, 2 -> 0
;Diese gespeicherten Umlegungen werden nun ausgefÅhrt.
.um_el:   
          cmpi.w    #2,d6
          bcc       .um_ee
          move.l    (sp)+,d0         ;Eintrag vom Stack holen
          move.l    d0,d1
          swap.w    d1               ;D1.W: Positionsindex
          lea       rsm1tct,a2
          move.b    d0,0(a2,d1.w)    ;ZÑhler
          lsr.w     #8,d0            ;Vorteiler nach Bit7..0
          lea       rsm1tps,a2
          move.b    d0,0(a2,d1.w)    ;Vorteiler
          addq.w    #1,d6            ;quasi umgedrehte dbra-Schleife
          bra       .um_el
.um_ee:   

          pea       sum1ini          ;fÅr Rsconf direkt
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
          IFNE FOR_STMFP|FOR_FALCON|FOR_TTMFP      ;Maptab Åberschreiben
          pea       m1_routtab       ;Routinen eintragen
          IFNE FOR_STMFP|FOR_FALCON
          move.w    #6,-(sp)         ;Kanal 6
          ENDC 
          IFNE FOR_TTMFP
          move.w    #8,-(sp)         ;Kanal 8
          ENDC 
          move.w    #MAPT_OVE,-(sp)
          move.w    #44,-(sp)
          trap      #14              ;XBIOS Bconmap (erweitert)
          lea       10(sp),sp
          ENDC 
          IFNE FOR_BASTEL             ;an Maptab anhÑngen
          pea       m1_routtab
          move.w    #MAPT_APP,-(sp)
          move.w    #44,-(sp)
          trap      #14              ;XBIOS Bconmap (ext: MAPT_APP)
          addq.l    #8,sp
          ENDC 
          tst.l     d0
          bne       .ib_ok
          bsr       prints
	DC.b "***	Error: Load DRVIN.PRG first!?",bell,bell,cr,lf,0
          EVEN 
          bra       init_end         ;Fehler
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


platz_end:          

          tst.w     yes_rsve         ;RSVE-Cookie anlegen?
          beq       init64           ; nein
          pea       su_rsve
          move.w    #38,-(sp)
          trap      #14              ;XBIOS Supexec
          addq.l    #6,sp
init64:   

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


su_rsve:  
;Supervisorteil zum RSVE-Cookie-Anlegen
          move.l    #platz_end,d0
          sub.l     first_unresi,d0
          move.l    d0,-(sp)
          move.l    first_unresi,-(sp)
          clr.l     -(sp)            ;Wert
          move.l    #'RSVE',-(sp)    ;Name
          bsr       cookie_insert
          lea       16(sp),sp
          tst.l     d0
          bmi       .coo_err
          add.l     d0,first_unresi  ;(schadet bei D0 =0 auch nicht)
.coo_err:           ;keine Reaktion auf Anlegefehler
          rts       

;------------------------------------------


          INCLUDE "PRINTS.S"

          INCLUDE "COOKIE.S"


;------------------------------------------

;Konfigurationszeug
          EVEN     ;wichtig!!!
magisch:  DC.b "hAruNs cONfigER",0  ;Magischer String
          DC.l magisch              ;Sicherheitszeiger
          DC.b "RSVE: Soll der RSVE-Cookie installiert werden?",cr,lf,0
          EVEN 
          DC.w 0   ;Cmd Entscheidung
yes_rsve: DC.w -1  ;-1 fÅr RSVE-Cookie installieren, lîst auch yes_m1hi aus

          DC.b "REPL: Falls Sie fÅr ein altes Programm die Rsconf-Baudraten",cr,lf
          DC.b "umbelegen wollen, so geben Sie jeweils zuerst die alte,",cr,lf
          DC.b "dann die neue Rate ein. 3 Umbelegungen sind mîglich.",cr,lf,0
          EVEN 
          DC.w $0106                ;Cmd LONG-Liste, 6 StÅck
bd_conf:  DC.l $80000000,$80000000
          DC.l $80000000,$80000000
          DC.l $80000000,$80000000

          IFNE FOR_STMFP|FOR_BASTEL
          DC.b "DTR: Einstellung des DTR-Signals beim Treiberstart",cr,lf
          DC.b "Ja   = aktiv (wie bei TOS)",cr,lf
          DC.b "Nein = inaktiv",cr,lf,0
          EVEN 
          DC.w 0   ;Cmd Entscheidung
dtr_conf: DC.w -1  ;-1 fÅr aktiv
          ENDC 

	dc.b "HOG: Mehrfaches Schnittstellenîffnen generell erlauben?",cr,lf
	dc.b "Ja   = wie unter TOS",cr,lf
	dc.b "Nein = Normalzustand unter MagiC",cr,lf,0
          DC.w 0   ;Cmd Entscheidung
hog_conf: DC.w -1  ;ja

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
;1998-07-25 enhanced Fdelete, needs DRVIN 1998-07-25 or later if MFP*
;shall be deleted, #### still without MFP-Int-disable and MagiC-memfree
;1997-11-01 auûer fÅr MFP_BAST ein primitives Lîschen,
;noch ohne: Lîschen aus MAPTAB, Interruptsperre, Speicherfreigabe
;einzelne RSVF-Verkettungs- oder End-Objekte werden nicht mehr beseitigt
;1997-10-28 immer noch hÑufig RSFI als RSVE erkannt auf P475 (68040)
;und einem ST mit 68030/50MHz PAK, neuer Versuch siehe "KRZE" Kommentar
;1997-10-23 test_set_tid wartete nur 2 Timer-D-AblÑufe, was genau nur eine
;Periode am Ausgang ergibt. Das kann fÅr RSVE und RSFI zu wenig sein,
;deshalb auf 6 erhîht, muû reichen.
;1997-10-12 seit der 063 (1997-03-08) lief Bconstat nach Bconin rein und
;Bcostat nach Bconout, rts vergessen bei Nutzung der usm_, also Funktionen
;unbrauchbar, korrigiert.
;1997-10-03 MFP_BAST machte ein &$0e wenn RTS-Low gefordert in Bconin-Ende,
;vîlliger Blîdsinn, muû &$f7 sein, korrigiert.
;Bconin: Interruptsperrzeit minimiert, symbolische IOREC-Namen
;Fread/Fwrite Hilfsmakros ergÑnzt, damit kÅrzere Bconin/Bconout
