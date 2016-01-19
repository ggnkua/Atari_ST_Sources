;Auf der Kommandozeile wird das Symbol XX_FOR_THIS definiert mit
;einem Wert von 0, 1, 2, 3 um die Hardware festzulegen.
;Auf der Kommandozeile wird der Name des Zielfiles vorgegeben.

;Neue BIOS- und GEMDOS- Routinen fÅr einen (E)SCC, also zwei Schnittstellen,
;wÑhlbar beim Assemblieren Åber Symbol XX_FOR_THIS:
;0: SCC fÅr MegaSTE, TT, Falcon, usw Clones
;1: ESCC fÅr MegaSTE, TT, Falcon, usw Clones
;2: unbenutzt: SCC fÅr ST_ESCC
;3: ESCC fÅr ST_ESCC


;Diese XX_FOR_THIS werden umgewandelt in interne Konfigflags.
;FOR_ESCC: =1 wenn Code fÅr ESCC Z85230/Am85C230, =0 fÅr SCC 8530/85C30
;FOR_ST_ESCC: = 1 wenn Code fÅr ST_ESCC, =0 Code fÅr MegaSTE/TT/Falcon
FOR_ESCC = ((1=XX_FOR_THIS)|(3=XX_FOR_THIS))
FOR_ST_ESCC = ((2=XX_FOR_THIS)|(3=XX_FOR_THIS))


;Generelle Einstellungen fÅr GEN-Assembler
	MACHINE	MC68000
	OPT	ATARI
	OPT	OW-,O1+,O2+,O3+,O4+,O5+,O8+,O9+
;folgendes wÅrde ein Warning je optimierbaren VorwÑrtssprung ergeben,
;der aber nicht optimiert wird, weil GEN es nicht kann.
;;;;;	OPT	O6+,OW6+


;Kommentar "MODICODE" bedeutet: WÑhrend Installation modifizierter Code.

;PROBLEME: ###################################
;wÑhrend fifo2buf kînnte Interrupt entstehen und wieder verschwinden
;(das kann hier aber generell an einigen Stellen passieren und
;geht auf	echten Ataris ja auch problemlos)

;Es wird generell beim Empfang kein Fehlercheck durchgefÅhrt, d.h. im
;Gegensatz zum MFP-Treiber verschwinden Zeichen mit Parity-	&| Frame-Error
;nicht, sondern werden mit bereitgestellt. Siehe dazu auch meine persînliche
;ESCC-Doku. Selbst ein Sammeln aller	Fehler wÑre etwas aufwendig und wird
;deshalb nicht durchgefÅhrt.


;Neue BIOS-Routinen	fÅr den SCC (MODEM2/SERIAL2) bei MegaSTE, TT, Falcon
;und fÅr den ESCC des ST_ESCC-Projekts

;Das DRVIN*.PRG muû	resident sein.

	INCDIR "E:\AHSMOD\LIB\"
	INCLUDE "MISC_DEF.S"	;alle mîglichen Definitionen
	INCLUDE "ERRNO.S"
	INCLUDE "IOREC.S"
	INCLUDE "SER_MACS.S"

;--------------------------------------------------------


	TEXT
start:	bra	starti
;Sprung nach hinten, damit mîglichst wenig resident bleibt

	INCLUDE "CA_FLUSH.S"

;Im Kommandozeilenbereich liegen kurzzeitig die Sende&Empfangspuffer
;PufferlÑngen nur ganz kurz bedeutsam (zusammen max. 128 Byte)
recbuflen		= 16
trabuflen		= 16
s2_rbuf	= start-(recbuflen+recbuflen+trabuflen+trabuflen)
s2_tbuf	= start-(recbuflen+trabuflen+trabuflen)
m2_rbuf	= start-(recbuflen+trabuflen)	;Empfangspuffer
m2_tbuf	= start-trabuflen	;Sendepuffer



;----------------------------------------------------------


;Die Routinen fÅr den ESCC des Projekts ST_ESCC

;Basisadressen der InterruptvektorplÑtze der ESCC-KanÑle
iva_esccB		= $00000180
iva_esccA		= $000001a0

	IFNE FOR_ST_ESCC
esccB_ct	= $fffffa31	;ESCC ControlRegister Kanal B
esccA_ct	= $fffffa35	;ESCC ControlRegister Kanal A
	ELSE
;MegaSTE,	TT, Falcon: A wirklich adreûmÑûig vor B
esccB_ct	= $ffff8c85	;SCC ControlRegister Kanal B
esccA_ct	= $ffff8c81	;SCC ControlRegister Kanal A
	ENDC

;Zusatzport nur bei	ST_ESCC:
esccX_port	= $fffffa39

;Es wird von folgenden Annahmen ausgegangen, die sowohl fÅr	ST_ESCC wie auch
;fÅr MegaSTE/TT/Falcon zutreffen:
;- Das DataRegister	eines SCC-Kanals	liegt 2 Byte	hinter dem ControlRegister
;des Kanals.
;- Der Platz des Empfangszeichen-verfÅgbar-Interruptvektors	ist $10 Byte
;hinter dem des Sendepuffer-leer-Interruptvektors.
;- Die High-Water-Mark liegt mindestens 10 Byte unter dem Pufferende.	Sonst
;kann es durch die schnelle Schleifenstruktur besonders bei	RTS/CTS dazu
;kommen, daû RTS nie inaktiviert wird. ####WICHTIG!!!!

;Wegen des FIFOs ist es nicht erforderlich, als erstes das Byte zu holen.
;Es vereinfacht aber die Bearbeitung	wesentlich.

;Die Interrupts gehen davon aus, daû sie nicht von jemandem unterbrochen
;werden, der am SCC	oder IOREC fummelt (bei IPL6 im ST_ESCC	100% sicher).
;(also wer in einem	IPL7-(NMI)-Int hantiert ist fÅr alles verantwortlich)
;### bei IPL5 im MegaSTE/TT/Falcon etwas fraglich

;Tausche Speicher gegen Geschwindigkeit, deshalb alles als Makro und somit
;fÅr jeden Kanal jede Routine extra.



;Die Empfangsregister voll Routinen werden ebenfalls fÅr Special Condition
;Interrupts benutzt, da auch dort mindestens ein Zeichen abzuholen ist.
;Siehe dazu auch den Anfang dieses Quelltextes.


escc_rfx	MACRO
;Parameter: ct_adr,ior_adr,op_hs,op_dtr
;Interrupt SCC-Empfangsregister voll fÅr
; kein Handshake, op_hs = 0
; HardwareHS (RTS oder DTR), op_hs =	1
;(Adr. ControlRegister, Adr. IOREC, siehe oben, 0= DTR-Hs Code nicht einfÅgen)
	movem.l	d0/d1/a1,-(sp)
	moveq.l	#0,d1	;lîsche vor allem Bit31-16, die mÅssen 0 bleiben!
	movea.l	\2(pc),a1	;Pufferadresse
	move.w	ioo_rwp+\2(pc),d1	;Schreibzeiger holen
.\@next:  
	addq.w	#1,d1		;erhîhen, durch .w modulo 64KByte
	cmp.w	ioo_rbl+\2(pc),d1	;im Puffer umlaufen	lassen
	bcs.s	.\@nobufend
	moveq	#0,d1
.\@nobufend:        
	move.b	\1+2,d0		;Byte aus Empfangsregister
	and.b	ioo_and+\2(pc),d0	;fÅr 5 bis 7 Bit notwendig
	cmp.w	ioo_rrp+\2(pc),d1
	beq.s	.\@flush		;Puffer voll, Byte wegwerfen
	move.b	d0,$0(a1,d1.l)	;Byte -> Puffer
	btst	#0,\1		;noch Zeichen da?
	bne.s	.\@next		;ja
.\@kon:   
	move.w	d1,ioo_rwp+\2	;Schreibzeiger aktualisieren
;fÅr alle	in diesem	Interrupt gelesenen Zeichen gemeinsam:
;###(genau genommen	sollte man das vor dem Lesen des letzten Zeichens	machen,
;sonst kînnte Fehlerstatus eines folgenden Zeichens hops gehen, da der
;Fehlerstatus aber uninteressant, ist es egal)
	move.b	#$30,\1		;Error Reset
	IFNE \3			;nur falls Codeerzeugung fÅr Handshake
;Anzahl belegter Byte berechnen
	sub.w	ioo_rrp+\2(pc),d1	;Schreibzeiger minus Lesezeiger
	bcc.s	.\@inbuf		;keine Korrektur
	add.w	ioo_rbl+\2(pc),d1	; sonst plus Puffergrîûe
.\@inbuf: 
	cmp.w	ioo_rhw+\2(pc),d1	;vergleiche mit High Water Mark
	bcs.s	.\@ende		;noch kein Hochwasser, hops
	bset.b	#7,ioo_re+\2	;teste und inaktiviere
	bne.s	.\@ende		;EmpfÑnger schon inaktiv gewesen
;Hardwarehandshake inaktiv schalten. Da selten, nicht ganz schnell.
	moveq.l	#$fd,d0		;RTS inaktivieren (TTL-High)
	IFNE \4
	btst.b	#1,3+ioo_iol+\2	;TIOCM_DTR = 2
	bne.s	.\@rtshs		;DTR ist I/O und nicht Hwhs
	moveq.l	#$7f,d0		;DTR inaktivieren (TTL-High)
.\@rtshs: 
	ENDC
	and.b	ioo_wr5+\2(pc),d0	;dazu Bit1/7 von WR5 auf 0,
	move.b	d0,ioo_wr5+\2	;ist negiertes RTS/DTR
	move.b	#$05,\1		;WR5
	move.b	d0,\1
	ENDC			;(Ende nur fÅr Handshake-Code)
.\@ende:
	move.b	#$38,\1		;anhÑngigen Interrupt lîschen
	movem.l	(sp)+,d0/d1/a1
	rte

;Puffer voll, restliche Zeichen aus FIFO vergessen
.\@nflu:  
	move.b	\1+2,d0	;Byte aus Empfangsregister
.\@flush: 
	btst	#0,\1	;noch Zeichen da?
	bne.s	.\@nflu	;ja
;da eventuell vor dem Vollwerden schon Zeichen Åbertragen wurden, den
;Schreibzeiger noch	korrekt updaten, d.h. ohne das letzte Increment
	subq.w	#1,d1
	bcc.s	.\@nonu
;ist -1
	add.w	ioo_rbl+\2(pc),d1	;korrigiere
.\@nonu:  
	bra.s	.\@kon

	ENDM


escc_rfs	MACRO
;Parameter: ct_adr,ior_adr,itbe_adr
;Interrupt MFP-Empfangsregister voll fÅr XON/XOFF (SoftwareHS)
;(Adr. ControlRegister, Adr. IOREC,
;Adr. des	XON/XOFF-Sendepuffer-leer Interrupts)
	movem.l	d0/d1/a1,-(sp)
	moveq.l	#0,d1	;lîsche vor allem Bit31-16, die mÅssen 0 bleiben!
	movea.l	ioo_rba+\2(pc),a1	;Pufferadresse
.\@next:  
;hier sauberes, langsames Verfahren:	Error Reset vor jedem Zeichenlesen
;falls Fehler interessiert, sollte man hier vor noch RR1 lesen
	move.b	#$30,\1	;Error Reset
	move.b	\1+2,d0	;Byte aus Empfangsregister
	and.b	ioo_and+\2(pc),d0	;fÅr 5 bis 7 Bit notwendig
	cmpi.b	#xoff,d0	;XOFF?
	beq.s	.\@rexoff	; ja
	cmpi.b	#xon,d0	;XON ?
	beq.s	.\@rexon	; ja
	move.w	ioo_rwp+\2(pc),d1	;Schreibzeiger holen
	addq.w	#1,d1	;erhîhen, durch .w automatisch auf 64KByte beschrÑnkt
	cmp.w	ioo_rbl+\2(pc),d1	;im Puffer umlaufen	lassen
	bcs.s	.\@nobufend
	moveq	#0,d1
.\@nobufend:        
	cmp.w	ioo_rrp+\2(pc),d1
	beq.s	.\@ende	;Puffer voll, Byte wegwerfen
	move.b	d0,$0(a1,d1.l)	;Byte -> Puffer
	move.w	d1,ioo_rwp+\2	;Schreibzeiger aktualisieren
;Anzahl belegter Byte errechnen
	sub.w	ioo_rrp+\2(pc),d1	;minus Lesezeiger
	bcc.s	.\@inbuf	;keine Korrektur
	add.w	ioo_rbl+\2(pc),d1	; sonst plus Puffergrîûe
.\@inbuf: 
	cmp.w	ioo_rhw+\2(pc),d1	;vergleiche mit High Water Mark
	bcs.s	.\@ende	;noch kein Hochwasser,	hops
	bset.b	#7,ioo_re+\2	;teste und inaktiviere
	bne.s	.\@ende	;EmpfÑnger schon inaktiv
	moveq.l	#xoff,d0	;XOFF
;da IPL6,	ist schon	totale Interruptsperre
	btst	#2,\1	;Senderegister leer?
	beq.s	.\@trfull	;Senderegister voll, XOFF spÑter senden
	move.b	d0,\1+2	;XOFF sofort senden
	clr.b	d0	;lîschen, da schon gesendet
.\@trfull:          
	move.b	d0,ioo_tci+\2
.\@ende:  
	btst	#0,\1	;noch Zeichen da?
	bne.s	.\@next
	move.b	#$38,\1	;anhÑngigen Interrupt lîschen
	movem.l	(sp)+,d0/d1/a1
	rte
.\@rexoff:          
	st	ioo_te+\2	;XOFF empfangen, Sender sperren
	bra.s	.\@ende
.\@rexon: 
	sf	ioo_te+\2	;XON empfangen, Sender	freigeben
;da IPL6,	ist schon	totale Interruptsperre
	btst	#2,\1
	beq.s	.\@ende	;Senderegister noch voll, keine Aktion weiter
	movem.l	(sp)+,d0/d1/a1
	bra	\3	;Sprung zum Sendeinterrupt
;Der Sendeinterrupt	lîscht den hîchsten anhÑngigen Interrupt selbst am Ende.
;!!!wenn XON empfangen wurde, wird nur ein Zeichen aus dem Empfangspuffer
;geholt und nicht alle!!!
	ENDM


;Reset Tx	Pending muû durchgefÅhrt werden, falls kein Zeichen in das
;Senderegister nachgeladen wurde. Es kann generell vor dem Nachladen
;durchgefÅhrt werden (ist aber nicht zeitoptimal), da ein neuer
;Tx-Int erst nach dem Nachladen angemeldet wird.
;Es darf nach dem Nachladen nur durchgefÅhrt werden, wenn klar ist, daû
;der eventuell schon wieder angemeldete Tx-Int nicht befriedigt werden
;kann. Dies ist der	Fall bei leerem Puffer (wenn der Puffer	gefÅllt
;wird, wird automatisch direkt in den Sender geschrieben, was neue Tx-Int
;auslîst)	und bei gesperrtem Handshake (Freigabe des Handshake lîst
;ebenfalls Schreiben in Sender aus -> neue Tx-Int).


escc_tex	MACRO
;Parameter: ct_adr,ior_adr
;Interrupt ESCC-x-Senderegister leer fÅr kein Handshake
;(auch benutzt fÅr HardwareHS nach dessen Test)
;(Adr. ControlRegister, Adr. IOREC)
	movem.l	d1/a1,-(sp)
	moveq.l	#0,d1	;lîsche vor allem Bit31-16, die mÅssen 0 bleiben!
	move.w	ioo_trp+\2(pc),d1	;Lesezeiger
	movea.l	ioo_tba+\2(pc),a1	;Pufferadresse
.\@next:  
	cmp.w	ioo_twp+\2(pc),d1
	beq.s	.\@enpe	;Puffer leider leer
	addq.w	#1,d1	;erhîhen, durch .w automatisch auf 64KByte	beschrÑnkt
	cmp.w	ioo_tbl+\2(pc),d1	;im Puffer umlaufen	lassen
	bcs.s	.\@nbe
	moveq	#0,d1
.\@nbe:   
	move.b	$0(a1,d1.l),\1+2	;Puffer -> Senderegister
	btst	#2,\1
	bne.s	.\@next	;noch Platz im ESCC
.\@enem:  
	move.w	d1,ioo_trp+\2	;Lesezeiger aktualisieren
	movem.l	(sp)+,d1/a1
	move.b	#$38,\1	;anhÑngigen Interrupt lîschen
	rte
.\@enpe:  
	move.b	#$28,\1	;Reset TX Pending wenn	nichts (mehr) nachgeladen
	bra.s	.\@enem
	ENDM


escc_tes	MACRO
;Parameter: ct_adr,ior_adr
;Interrupt ESCC-x-Senderegister leer	XON/XOFF (SoftwareHS)
;(hierher	springt auch (Makro) escc_rfs, wenn es senden will)
;(Adr. ControlRegister, Adr. IOREC)
	movem.l	d0/d1/a1,-(sp)
	moveq.l	#0,d1	;lîsche vor allem Bit31-16, die mÅssen 0 bleiben!
	move.w	ioo_trp+\2(pc),d1	;Lesezeiger
	movea.l	ioo_tba+\2(pc),a1	;Pufferadresse
	move.b	ioo_tci+\2(pc),d0	;wenn hier <>0, das	sofort ungeachtet Sperre senden
	clr.b	ioo_tci+\2	;lîschen, clr und auch	sf Ñndert	Flags
	tst.b	d0	;deshalb nochmal setzen
	bne.s	.\@sendim
.\@next:  
	cmp.w	ioo_twp+\2(pc),d1
	beq.s	.\@endpe	;Puffer leider leer
	tst.b	ioo_te+\2
	bne.s	.\@endpe	;darf leider nicht da Sender gesperrt
	addq.w	#1,d1	;erhîhen, durch .w automatisch auf 64KByte beschrÑnkt
	cmp.w	ioo_tbl+\2(pc),d1	;im Puffer umlaufen	lassen
	bcs.s	.\@nobufend
	moveq	#0,d1
.\@nobufend:        
	move.b	$0(a1,d1.l),d0	;Puffer ->
	move.w	d1,ioo_trp+\2	;Lesezeiger aktualisieren
.\@sendim:          
	move.b	d0,\1+2	;-> Senderegister
	btst	#2,\1
	bne.s	.\@next	;noch Platz im ESCC
.\@ende:  
	move.b	#$38,\1	;anhÑngigen Interrupt lîschen
	movem.l	(sp)+,d0/d1/a1
	rte
.\@endpe: 
	move.b	#$28,\1	;Reset TX Pending wenn nichts (mehr) nachgeladen
	bra.s	.\@ende
	ENDM



escc_ext	MACRO
;Parameter: ct_adr,ior_adr,it_rs,op_dtr
;Interrupt ESCC-x-Ext/Status
;(CTS-Pin, DCD-Pin,	SYNC-Pin, Transmitter underrun, Baudratengenerator = 0,
;Break) jeweils nur	falls enabled
;##### momentan nur	CTS erlaubt #####
;(Adr. ControlRegister, Adr. IOREC, Adr. Sendeint. Hwhs,
; 0= kein	Code fÅr LAN-Handshake)
;### war es Åberhaupt das CTS-Signal? Dazu mÅûte man RR0 speichern
;### und das vorige	RR0 mit auswerten, momentan aber nur CTS erlaubt
	cmpi.b	#2,ioo_hsm+\2	;Hardwarehandshake aktiv?
	bne	.\@ende	;nein
;durch IPL6 sind schon alle Ints gesperrt
	IFNE \4
	btst.b	#1,3+ioo_iol+\2	;TIOCM_DTR = 2
	bne.s	.\@rtshs	;DTR ist I/O, kein Hwhs
	btst.b	#5,\1	;CTS-LAN aktiv?
	bne.s	.\@ende	;nein
	btst.b	#2,\1
	beq.s	.\@ende	;kein Platz im Senderegister
	move.b	#$10,\1	;Reset Ext/Status
	bra	\3	;Platz im Senderegister
;Sprung in LAN-Hwhs-Sendeinterrupt. Highest IUS lîscht er selbst.
.\@rtshs: 
	ENDC
	btst	#5,\1	;CTS-RS232 aktiv?
	beq.s	.\@ende	;nein
	btst.b	#2,\1
	beq.s	.\@ende	;kein Platz im Senderegister
	move.b	#$10,\1	;Reset Ext/Status
	bra	\3	;Platz im Senderegister
;Sprung in RS232-Hwhs-Sendeinterrupt. Highest IUS	lîscht er	selbst.
.\@ende:  
	move.b	#$10,\1	;Reset Ext/Status
	move.b	#$38,\1	;Highest IUS	lîschen
	rte
	ENDM



escc_fifo2buf	MACRO
;Parameter: ct_adr,ior_adr
;Routine transportiert eventuell im EmpfangsFIFO vorhandene	Zeichen in den
;Puffer, notwendig falls Interrupt_nach_4_empfangenen_Zeichen. Bei
;Softwarehandshake ist immer Interrupt bei jedem Zeichen, und die Routine tut
;nichts.
;(Adr. ControlRegister, Adr. IOREC)
;éndert kein Register
	cmpi.b	#1,ioo_hsm+\2	;XON/XOFF?
	beq	.\@uende	; ja, nichts tun (geht nicht als .s bra)
.\@buftst:          
	movem.l	d0-d3/a1,-(sp)
	moveq.l	#0,d1	;lîsche vor allem Bit31-16, die mÅssen 0 bleiben!
	movea.l	ioo_rba+\2(pc),a1	;Pufferadresse
	moveq.l	#3,d3	;max. 4 Byte	hiermit holen
	move.w	sr,d2
	ori.w	#$700,sr	;INTERRUPTSPERRE
	btst.b	#0,\1	;Zeichen im FIFO?
	beq	.\@ende	; nein (geht nicht als .s bra)

	move.w	ioo_rwp+\2(pc),d1	;Schreibzeiger holen
.\@next:  
	addq.w	#1,d1	;erhîhen, durch .w automatisch auf 64KByte beschrÑnkt
	cmp.w	ioo_rbl+\2(pc),d1	;im Puffer umlaufen	lassen
	bcs.s	.\@nobufend
	moveq	#0,d1
.\@nobufend:        
	cmp.w	ioo_rrp+\2(pc),d1
	beq.s	.\@ende	;Puffer ist voll

;hier sauberes, langsames Verfahren:	Error Reset vor jedem Zeichenlesen
;falls Fehler interessiert, sollte man hier vor noch RR1 lesen
	move.b	#$30,\1	;Error Reset
	move.b	2+\1,d0
	and.b	ioo_and+\2(pc),d0	;fÅr 5 bis 7 Bit notwendig
	move.b	d0,$0(a1,d1.l)	;Zeichen -> Puffer
	move.w	d1,ioo_rwp+\2	;Schreibzeiger aktualisieren
	btst.b	#0,\1	;noch ein Zeichen im FIFO (bne)?
	dbeq	d3,.\@next	;hops wenn Zeichen und	nicht max.Anzahl
;kein Zeichen mehr da oder max.Anzahl erreicht:
	cmpi.b	#2,ioo_hsm+\2	;RTS/CTS?
	bne.s	.\@ende	; nein

;Anzahl belegter Byte berechnen
	sub.w	ioo_rrp+\2(pc),d1	;Schreibzeiger minus Lesezeiger
	bcc.s	.\@inbuf	;keine Korrektur
	add.w	ioo_rbl+\2(pc),d1	; sonst plus Puffergrîûe
.\@inbuf: 
	cmp.w	ioo_rhw+\2(pc),d1	;vergleiche mit High Water Mark
	bcs.s	.\@ende	;noch kein Hochwasser,	hops
	tst.b	ioo_re+\2
	bne.s	.\@ende	;EmpfÑnger schon inaktiv
	st	ioo_re+\2	;EmpfÑnger sperren
	moveq.l	#$fd,d0	;RTS inaktivieren (TTL-High)
	btst.b	#1,3+ioo_iol+\2	;TIOCM_DTR = 2
	bne.s	.\@rtshs	;DTR ist I/O	und nicht	Hwhs
	moveq.l	#$7f,d0	;DTR inaktivieren (TTL-High)
.\@rtshs: 
	and.b	ioo_wr5+\2(pc),d0	;dazu Bit1/7 von WR5 auf 0,
	move.b	d0,ioo_wr5+\2	;ist negiertes RTS/DTR
	move.b	#$05,\1	;WR5
	move.b	d0,\1
.\@ende:  
	move.w	d2,sr	;INTERRUPTS FREI
	movem.l	(sp)+,d0-d3/a1
.\@uende: 
	rts
	ENDM



;Die Codeerzeugung fÅr die Interruptroutinen:

;ESCC-B, Modem2
	CNOP 0,4
i_esccB_rfh:	escc_rfx	esccB_ct,m2_iorec,1,0
	CNOP 0,4
i_esccB_rfs:	escc_rfs	esccB_ct,m2_iorec,i_esccB_tes
	CNOP 0,4
i_esccB_rfo:	escc_rfx	esccB_ct,m2_iorec,0,0

i_linB:   
	move.b	#$28,esccB_ct	;Reset TX Pending da nichts nachgeladen
	move.b	#$38,esccB_ct	;anhÑngigen Interrupt lîschen
	rte
	CNOP 0,4
i_esccB_teh:        
;Sendeinterrupt Hardwarehandshake
;Da FIFO-FÅllen schnell geht, erfolgt nur einmal vorher Handshaketest.
	btst	#5,esccB_ct	;teste CTS-Eingang
i_B_MOD:  
;fÅr CTS-LAN wird "beq" auf "bne" modifiziert zur	Laufzeit
	beq	i_linB	;darf nicht da CTS-RS232 inaktiv
i_esccB_teo:        
;Sendeinterrupt ohne Handshake
	escc_tex	esccB_ct,m2_iorec

	CNOP 0,4
i_esccB_tes:	escc_tes	esccB_ct,m2_iorec
	CNOP 0,4
i_esccB_ext:	escc_ext	esccB_ct,m2_iorec,i_esccB_teh,0

;ESCC-A, Serial2
	CNOP 0,4
i_esccA_rfh:	escc_rfx	esccA_ct,s2_iorec,1,1
	CNOP 0,4
i_esccA_rfs:	escc_rfs	esccA_ct,s2_iorec,i_esccA_tes
	CNOP 0,4
i_esccA_rfo:	escc_rfx	esccA_ct,s2_iorec,0,0

i_linA:   
	move.b	#$28,esccA_ct	;Reset TX Pending da nichts nachgeladen
	move.b	#$38,esccA_ct	;anhÑngigen Interrupt lîschen
	rte
	CNOP 0,4
i_esccA_teh:        
;Sendeinterrupt Hardwarehandshake
;Da FIFO-FÅllen schnell geht, erfolgt nur einmal vorher Handshaketest.
	btst	#5,esccA_ct	;teste CTS-Eingang
i_A_MOD:  
;fÅr CTS-LAN wird "beq" auf "bne" modifiziert zur	Laufzeit
	beq	i_linA	;darf nicht da CTS-RS232 inaktiv
i_esccA_teo:        
;Sendeinterrupt ohne Handshake
	escc_tex	esccA_ct,s2_iorec

	CNOP 0,4
i_esccA_tes:	escc_tes	esccA_ct,s2_iorec
	CNOP 0,4
i_esccA_ext:	escc_ext	esccA_ct,s2_iorec,i_esccA_teh,1


	IFNE FOR_ESCC
;Codeerzeugung fÅr fifo2buf
m2_fifo2buf:	escc_fifo2buf	esccB_ct,m2_iorec
s2_fifo2buf:	escc_fifo2buf	esccA_ct,s2_iorec
	ELSE
;Marken wenigstens definieren
m2_fifo2buf:        
s2_fifo2buf:        
	rts
;#### das	RTS kann Programmierfehler (umstÑndlichkeiten) verdecken, naja
	ENDC




xes_bconout	MACRO
;Parameter: ct_adr,ior_adr,op_dtr
;ESCC, bconout, Zeichenausgabe
;fÅr alle	drei Fluûkontrollarten
;Kann auch bei anfang+4 aufgerufen werden, mit Parameter bei WORD(a0)
;op_dtr: 0= kein DTR-Hwhs-Code, 1= DTR-Hwhs-Code einfÅgen
	lea	6(sp),a0	;Mag!X-gleich, muû sein
	move.w	(a0),d0
	lea	\2,a0
	moveq.l	#1,d1	;Bit31-16 muû 0 bleiben, 1 fÅr Schreibz
	add.w	ioo_twp(a0),d1	;Schreibzeiger holen &	erhîhen in 64K (.w)
	move.w	ioo_tbl(a0),d2	;Puffergrîûe	holen
	cmp.w	d2,d1	;im Puffer umlaufen lassen
	bcs	.\@conbx
	moveq	#0,d1
.\@conbx:	movea.l	ioo_tba(a0),a1	;Pufferadresse, auch fÅr spÑter
	move.b	d0,0(a1,d1.l)	;Byte -> Puffer
	move.w	d1,ioo_twp(a0)	;Schreibzeiger aktualisieren
.\@cobfu:	move.w	sr,d0	;damit kein Interrupt zwischendurch
	ori.w	#$700,sr	; das Senderegister fÅllt
	btst.b	#2,\1	;Platz im Senderegister?
	beq	.\@condl	;kein Platz
	cmpi.b	#1,ioo_hsm(a0)	;leer, welcher Handshake ?
	bls	.\@conhh	;kein Hardwarehs

	IFNE \3
	btst.b	#1,3+ioo_iol(a0)	;TIOCM_DTR =	2
	beq	.\@dtrhs	;DTR ist kein I/O, also Hwhs
	ENDC

	btst.b	#5,\1	;teste CTS-Eingang fÅr	RS232
	beq	.\@condl	;leider CTS inaktiv
;Wenn Senden erlaubt und Senderegister leer dann selbst senden.
.\@coscd:	move.w	ioo_trp(a0),d1	;Lesezeiger holen
	cmp.w	ioo_twp(a0),d1	;gleich Schreibzeiger?
	beq	.\@coend	;ja, ein Interrupt war	schneller
	addq.w	#1,d1	;erhîhen, auf 64KByte beschrÑnkt	durch .w
	cmp.w	d2,d1	;im Puffer umlaufen lassen
	bcs	.\@conbc
	moveq	#0,d1
.\@conbc: 
	move.b	$0(a1,d1.l),\1+2	;Puffer -> Senderegister
	move.w	d1,ioo_trp(a0)	;Lesezeiger aktualisieren
;Zweimal Wartezugriffe. Sonst fÅhrt der TT von Siegfried Hartmann @B die
;Interrupterlaubnis	durch, bevor die	Interrupt_ab_meldung des SCC durch
;die ganze Logik zur CPU kommt -> Spurios Interrupt = 24 Bomben
	tst.b	$fffffa01
	tst.b	$fffffa01
.\@coend:	move.w	d0,sr
	rts		;Ende (erstes)

	IFNE \3
.\@dtrhs: 
	btst.b	#5,\1	;teste CTS-Eingang fÅr LAN
	beq	.\@coscd	;CTS-LAN aktiv
	bra	.\@condl	;CTS-LAN inaktiv
	ENDC

.\@conhh:	bcs	.\@coscd	;kein Handshake, sofort senden
	tst.b	ioo_te(a0)	;XON/XOFF, teste ob Sender freigegeben
	beq	.\@coscd	;Sender frei, Zeichen senden
.\@condl:	move.w	d0,sr	;Interrupts wieder frei
;Freigabe	extrem wichtig, sonst lÑuft die Schleife komplett	mit IPL 7.
;Anzahl noch freier	PlÑtze im Puffer	ermitteln
	move.w	ioo_trp(a0),d1	;Lesezeiger
	sub.w	ioo_twp(a0),d1	;minus Schreibzeiger
	bhi	.\@coxnx	;keine Korrektur
	add.w	d2,d1	;plus PufferlÑnge
.\@coxnx:	subq.w	#1,d1	;minus 1 statt cmp #1
	beq	.\@cobfu	;voll, warten auf Leerung(smîglichkeit)
	rts		;Ende (zweites)
	ENDM


xes_bcostat	MACRO
;Parameter: ct_adr,ior_adr
;ESCC, bcostat, Ausgabestatus
;Da bconout immer mindestens einen freien Platz im Puffer braucht,
;sagt bcostat schon	voll, wenn nur noch ein Platz	frei ist.
;Wird bconout dann doch aufgerufen, verhÑlt es sich wie bei	vollem Puffer:
;Es wartet bis das Zeichen raus ist.
	move.w	ioo_trp+\2(pc),d1	;freien Platz berechnen, Lesezeiger
	sub.w	ioo_twp+\2(pc),d1	;minus Schreibzeiger
	bhi.s	.\@noco	;keine Korrektur
	add.w	ioo_tbl+\2(pc),d1	;PufferlÑnge dazu
.\@noco:	subq.w	#3,d1	;Differenz muû >=3 sein fÅr frei
	scc	d0	;ja, noch mind. 2 PlÑtze frei
	ext.w	d0
	ext.l	d0
	rts
	ENDM


xes_bconin	MACRO
;Parameter: ct_adr,ior_adr,f2b_adr,op_dtr
;ESCC, bconin, Zeicheneingabe
;FÅr alle	drei Fluûkontrollarten
	lea	\2,a0
	moveq	#0,d1	;Bit31-16 muû 0 bleiben!
	moveq	#0,d0	;beim Returncharacter Bit31-8 =0
	move.w	ioo_rrp(a0),d1	;Lesezeiger holen
.\@bem:	cmp.w	ioo_rwp(a0),d1	;Vergleich mit Schreibzeiger
	bne	.\@cfb	;Zeichen aus	Puffer holen
	IFNE FOR_ESCC
	bsr	\3	;evtl. aus ESCC in Puffer
	ENDC
	bra	.\@bem
.\@cfb:   
	addq.w	#1,d1
	cmp.w	ioo_rbl(a0),d1
	bcs	.\@cinbt
	moveq	#0,d1
.\@cinbt:	movea.l	(a0),a1	;Pufferadresse
	move.b	$0(a1,d1.l),d0	;Puffer -> Byte
	move.w	d1,ioo_rrp(a0)	;Lesezeiger aktualisieren
	tst.b	ioo_hsm(a0)	;Handshake ?
	beq	.\@ciend	;kein Handshake
;Teste zuerst, ob der EmpfÑnger freigegeben ist. Das ist schneller, als
;wenn erst auf untere Wassermarke getestet wird.
	tst.b	ioo_re(a0)
	beq	.\@ciend	;EmpfÑnger ist freigegeben
;Anzahl belegter Byte berechnen
	move.w	ioo_rwp(a0),d1	;Schreibzeiger
	sub.w	ioo_rrp(a0),d1	;minus Lesezeiger
	bcc	.\@cincd	;keine Korrektur
	add.w	ioo_rbl(a0),d1	;sonst LÑnge	dazu
.\@cincd:	cmp.w	ioo_rlw(a0),d1	;untere Wassermarke
	bhi	.\@ciend	;untere W. noch nicht unterschritten
	sf	ioo_re(a0)	;EmpfÑnger freigeben
	move.w	sr,d2
	ori.w	#$0700,sr	;sonst kînnten noch Interrupts erfolgen
	btst	#1,ioo_hsm(a0)	;welcher Handshake?
	beq	.\@cish	;XON/XOFF (kein RTS/CTS)
;Hardwarehandshake aktiv (1 im SCC, TTL-Low auûen) schalten
	moveq.l	#2,d1	;OR-Maske fÅr RTS
	IFNE \4
	btst.b	#1,3+ioo_iol(a0)	;TIOCM_DTR =	2
	bne	.\@rtshs	;DTR ist I/O, kein Hwhs
	moveq.l	#$80,d1	;OR-Maske fÅr DTR
.\@rtshs: 
	ENDC
	or.b	ioo_wr5(a0),d1	;WR5-Schatten holen
	move.b	d1,ioo_wr5(a0)
	move.b	#$05,\1
	move.b	d1,\1
	move.w	d2,sr	;Interruptlevel wieder	herstellen
.\@ciend:	rts		;Ende (1)
.\@cish:  
	moveq.l	#xon,d1	;XON bei XON/XOFF-Handshake
	btst.b	#2,\1	;Interrupts sind schon	gesperrt
	beq	.\@citf	;Senderegister voll, XON spÑter senden
	move.b	d1,\1+2	;XON sofort senden
	move.w	d2,sr	;Interruptlevel wieder	herstellen
	rts		;Ende (2)
.\@citf:  
	move.w	d2,sr	;Interruptlevel wieder	herstellen
	move.b	d1,ioo_tci(a0)	;XON vormerken
	rts		;Ende (3)
	ENDM


;ESCC, bconstat, Eingabestatus
xes_bconstat	MACRO
;Parameter: ct_adr,ior_adr,f2b_adr
	moveq.l	#$ff,d0
	move.w	ioo_rrp+\2(pc),d1
	cmp.w	ioo_rwp+\2(pc),d1
	bne.s	.\@ende	;Puffer nicht leer
;Puffer leer
	IFNE FOR_ESCC
	bsr	\3
	cmp.w	ioo_rwp+\2(pc),d1
	bne.s	.\@ende	;Puffer nicht leer
	ENDC
	moveq.l	#0,d0	;kein Zeichen da
.\@ende:  
	rts
	ENDM




;Die Codeerzeugung fÅr die Routinen in den xco*-Vektoren
;Modem2
m2_bconout:	xes_bconout	esccB_ct,m2_iorec,0
m2_bcostat:	xes_bcostat	esccB_ct,m2_iorec
m2_bconin:	xes_bconin	esccB_ct,m2_iorec,m2_fifo2buf,0
m2_bconstat:	xes_bconstat	esccB_ct,m2_iorec,m2_fifo2buf
;Serial2
s2_bconout:	xes_bconout	esccA_ct,s2_iorec,1
s2_bcostat:	xes_bcostat	esccA_ct,s2_iorec
s2_bconin:	xes_bconin	esccA_ct,s2_iorec,s2_fifo2buf,1
s2_bconstat:	xes_bconstat	esccA_ct,s2_iorec,s2_fifo2buf




;Das Zeug	mit den BAUDRATEN FöR MegaSTE/TT/Falcon:

;Falls Computer mit	14745600Hz-Quarzoszi umgebaut	(Vorschlag von Franz Sirl),
;dann wie	bei ST_ESCC.

;Falls unmodifizierter Computer:
;bis 19200Bd mit PCLK von 8MHz Åber Baudratengenerator als Source
;Åber 19200Bd
;
;Kanal B (MODEM2) nimmt /TRxCB als Quelle (siehe WR11)
; mit 2457600Hz (ohne Baudratengenerator), ergibt	mit Taktmodus
; /16 153600Bd, /32	76800Bd, /64 38400Bd
;
;Kanal B (MODEM2) kann beim MegaSTE und Falcon mit /RTxCB als
; Quelle mit 3672000Hz (ohne Baudratengenerator)
; /16 230400Bd, /32	115200Bd, /64 57600Bd
; Beim TT	ist das nicht mîglich, dort liegt an /RTxCB der Ausgang vom
; MFP-Timer D, der nichts sinnvolles	bringt.
;
;Kanal A (SERIAL2) nimmt /RTxCA als Quelle (siehe	WR11)
; mit 3672000Hz (ohne Baudratengenerator)
; /16 230400Bd, /32	115200Bd, /64 57600Bd,
; (mit Baudratengenerator an /RTxCA,	siehe WR14 bit1)
;  mit Konstante=1 38400Bd, mit Konstante=0 57600Bd (Taktmodus /16)
;
;REALISIERUNG:
;Taucht in der Bd-Generatortabelle ein $Fxyy-Eintrag auf (xyy beliebig),
;so wird in WR14 das Bit1 auf 0 (/RTxC-pin als Bd-Generatorquelle) statt
;sonst 1 (PCLK als Bd-Gen.quelle) gebracht.
;x sind 4	Bit (bezeichnet als Bit3..0), die im Eintrag auf Bit11..8 standen.
;Bit3..2 wird als Bit7..6 von WR4 verwendet:
; 00: Takt = 1*Datenrate (wird nie benutzt)
; 01:   =	16*rate (Normalzustand)
; 10:   =	32*rate
; 11:   =	64*rate
;Bit1..0 werden als	Bit6..5 und Bit4..3 von WR11 benutzt:
; 00: Sende/Empfangstakt vom /RTxC-pin
; 01:    -"- vom /TRxC-pin
; 10:    -"- vom Baudratengenerator (Normalzustand)
; 11:	   von DPLL (wird nie benutzt)
;yy sind 8Bit und werden wie normal als Bit7..0 des Bd-Gen.	benutzt, wobei
;Bit15..8	des Bd-Gen auf 0 gebracht werden.

;Hinter jeder Tabelle (16*WORD) mit den Rsconf-Baudratenteilerwerten
;fÅr die Hardware steht eine Tabelle	mit den zugehîrigen Klartextbaudraten
;(16*LONG).
;Beide ?2_bgtab werden bei Init. fÅr	14MHz Åberschrieben

;Die beiden Tabellen liegen direkt vor dem jeweiligen IOREC



;wichtige	Abstandsdefinitionen (relativ (vor) zu IOREC-Beginn)
ubd_ofs	= -(4*16)	;Klartextraten
bdt_ofs	= ubd_ofs-(2*16)	;Teilerwerte
esi_ofs	= bdt_ofs-(4*7)	;Interruptadr.tab.


s2_rsconf:          
;Rsconf fÅr Serial2, ESCC-A
	lea	s2_iorec,a0
	lea	esccA_ct,a2
	bra	escc_rsconf

m2_rsconf:          
;Rsconf fÅr Modem2,	ESCC-B
	lea	m2_iorec,a0
	lea	esccB_ct,a2

stof	set 4+12	;Stackoffset in rsconf, Ñnderbare Wertzuweisung

escc_rsconf:        
;Rsconf fÅr ESCC/SCC, wird angesprungen
;in:   A0: Zeiger auf IOREC
;      A1: kein input-Parameter mehr
;      A2: Zeiger auf Control-Register des SCC-Kanals
;out:  D0: xxx
;kill: D0-D2/A0-A2
	movem.l	d3/d4/a3,-(sp)
	moveq	#0,d0
	cmpi.w	#SETUSPEED,stof(sp)
	bne	rsesuno	;nicht die erweiterte Funktion
	move.l	ioo_ubd(a0),d0	;aktuelle uspeed
	move.l	2+stof(sp),d1	;Parameter uspeed
	bmi	rsesende	;nur abfragen
	move.l	d1,d0
	bsr	rses_suchbaud
	tst.l	d0	;gefunden?
	bmi	rsesende	; nein
	move.l	ioo_ubd(a0),d2	;alte uspeed
	move.l	d0,ioo_ubd(a0)	;neue uspeed	vermerken
	move.l	d2,d0	;alte uspeed	als Returnwert
	bsr	rses_setbd	;Baudrate anhand Index	(D1.w) einstellen
	bra	rsesende

rsesuno:  
	cmpi.w	#$fffe,stof(sp)
	bne	rsesnob
	move.b	ioo_bd(a0),d0	;nur Baudrate erfragen
	bra	rsesende
rsesnob:  
	move.b	ioo_ucr(a0),d0	;altes ucr, nach Bit31..24
	asl.w	#8,d0
	swap.w	d0
	move.b	ioo_wr5(a0),d0	;WR5-Schatten holen
	lsr.b	#1,d0	;und das Breakbit
	andi.b	#$08,d0	;als altes tsr(Bit15..8)
	asl.w	#8,d0	;RÅckgabewert von Rsconf

	move.w	stof(sp),d1	;Parameter speed
	cmpi.w	#$000f,d1
	bhi.s	rsesnosp	;hops bei speed zu groû (bzw. negativ)
	move.w	d1,d2	;Klartexttab	mit LONGs
	lsl.w	#2,d2
	move.l	ubd_ofs(a0,d2.w),ioo_ubd(a0)	;merke auch als Klartext
	bsr	rses_setbd	;Baudrate einstellen
rsesnosp: 
	move.w	sr,d4	;SR sichern
	move.w	2+stof(sp),d2	;Parameter flowctl
	cmpi.w	#3,d2
	bhi	rsesfcbi	;hops fÅr zu	groû (bzw. negativ)
	bne	rsesfcnb
	moveq.l	#1,d2	;mache aus RTS/CTS&XON/XOFF nur XON/XOFF
rsesfcnb: 
;immer die entsprechenden Interruptvektoren eintragen
	move.w	d2,d3
	lsl.w	#3,d3	;Handshakemode * 8, je	2 longs
	movea.l	esi_ofs(a0),a3
	move.l	4+esi_ofs(a0,d3.w),(a3)	;Sendepuffer leer Int.
	move.l	8+esi_ofs(a0,d3.w),$10(a3)	;Empfangspuffer voll Int.
	move.l	8+esi_ofs(a0,d3.w),$18(a3)	;Empfangsfehler Int.

	IFNE FOR_ESCC
;fÅr ESCC	die Behandlung des Empfangsinterruptmodus
	ori.w	#$700,sr	;INTERRUPTSPERRE
	move.b	#15,(a2)	;WR7' einschalten
	moveq.l	#1,d1
	or.b	(a2),d1
	move.b	#15,(a2)
	move.b	d1,(a2)
	moveq.l	#$28,d3	;fÅr WR7': Int. bei 4 empf.Zeichen
	tst.w	enag_4zi	;Åberhaupt erlaubt?
	beq	rsesn4zi	;verboten!
	cmpi.b	#1,d2	;welcher Handshake?
	bne	rsesnsh0	;kein XON/XOFF
rsesn4zi: 
	moveq.l	#$20,d3	;fÅr WR7': Int. bei jedem empf.Zeichen
rsesnsh0: 
	move.b	#7,(a2)
	move.b	d3,(a2)	;WR7' beschreiben
	andi.b	#$fe,d1	;WR7' ausschalten
	move.b	#15,(a2)
	move.b	d1,(a2)
	move.w	d4,sr	;INTERRUPTS FREI
	ENDC

	cmp.b	ioo_hsm(a0),d2
	beq	rsesfcbi	;hops fÅr Handshakemode unverÑndert
;Das bedeutet, die erste RTS-Aktivierung nach Reset muû ein	anderer machen.
	move.b	d2,ioo_hsm(a0)	;flowctl speichern (noch in d2 gebraucht)

	clr.w	ioo_re(a0)	;EmpfÑnger und Sender (ioo_te) freigeben
;Wenn der	Empfangspuffer voll ist, gehen evtl. gleich nach dieser
;Umschaltung ein paar Zeichen verloren. Das ist aber TOS-kompatibel.
;Ansonsten muû man umstÑndlich prÅfen, ob der EmpfÑnger freigegeben werden
;darf.

	ori.w	#$700,sr	;INTERRUPTSPERRE
;#### Eventuell sollte man bei LAN das RTS nicht immer aktivieren,
;da es ja	automatisch den Sendetreiber aktiviert????
	move.b	ioo_wr5(a0),d1
;Hardwarehandshakeleitung aktivieren
	ori.b	#$02,d1	;RTS aktiv (TTL-Low) schalten
	btst.b	#1,3+ioo_iol(a0)	;TIOCM_DTR =	2
	bne	rsesndtr	;DTR ist I/O, kein Handshake
	ori.b	#$80,d1	;DTR aktiv (TTL-Low) schalten
rsesndtr: 
	move.b	d1,ioo_wr5(a0)
	move.b	#$05,(a2)
	move.b	d1,(a2)

	cmpi.b	#1,d2	;welcher Handshake?
	bne	rsesnsh1	;kein XON/XOFF
;Bei XON/XOFF-HS ein XON senden, und	zwar mit den	neuen
;Einstellungen, deshalb erst hier. Hinweis: hier ist IPL7
	btst.b	#2,(a2)	;Platz im ESCC-Senderegister ?
	beq	rsestbne	;kein Platz
	move.b	#xon,2(a2)	;XON -> Senderegister
	bra	rsesnsh1
rsestbne: 
	move.b	#xon,ioo_tci(a0)	;XON vormerken
rsesnsh1: 
	move.w	d4,sr	;INTERRUPTS FREI
rsesfcbi: 
	move.w	4+stof(sp),d1	;Parameter ucr (Bit/Zeichen, Stoppbits, Parity)
	bmi	rsesfcu0	;hops fÅr nicht Ñndern
	move.b	d1,ioo_ucr(a0)	;sichern
	andi.w	#$60,d1	;Bit/Zeichen	herausholen
	lsr.b	#5,d1	;nach Bit1..0
	moveq.l	#$ff,d2	;Bitmaske fÅr AND-VerknÅpfung mit
	lsr.b	d1,d2	;Empfangszeichen erstellen
	move.b	d2,ioo_and(a0)	;und in IOREC+$23 speichern
;Bit/Zeichen wird aus der MFP- in die SCC-Darstellung umgewandelt
	moveq.l	#$9f,d2	;Bit/Zeichen	in den WR5-Schatten	einfÅgen
	and.b	ioo_wr5(a0),d2	;als Bit/Zeichen fÅr Sender
	or.b	rsesw5cl(pc,d1.w),d2
	move.b	d2,ioo_wr5(a0)
	ori.w	#$700,sr	;INTsperre
	move.b	#$05,(a2)	;SCC-WR5 beschreiben
	move.b	d2,(a2)
;Bit/Zeichen fÅr EmpfÑnger in WR3 einsetzen, Rest	von WR3 ist immer $01
	move.b	#$03,(a2)	;SCC-WR3 beschreiben
	move.b	rsesw3cl(pc,d1.w),(a2)
;ParitÑt und Stoppbits nach WR4
;Stoppbits nur verschieben, Paritybits schieben und vertauschen
	moveq.l	#$1e,d2
	and.w	4+stof(sp),d2
	lsr.b	#2,d2	;schiebe um 1 und Even//Odd-Bit raus ins X-Flag
	ror.b	#1,d2	;ParityEnable rum nach	Bit7 (X unbeeinfluût!)
	roxl.b	#2,d2	;Even/Odd aus X nach Bit1, ParityEnable nach Bit0
	move.b	ioo_wr4(a0),d1	;bit7..4 aus	dem Schatten
	andi.b	#$f0,d1
	or.b	d1,d2
	move.b	d2,ioo_wr4(a0)	;in Schatten
	move.b	#4,(a2)	;SCC-WR4 beschreiben
	move.b	d2,(a2)
rsesfcu0: 
	move.w	8+stof(sp),d1	;Parameter tsr
	bmi	rsesfct0	;hops fÅr nicht Ñndern
	moveq.l	#$ef,d2	;erstmal Break-Bit auf	0 (inaktiv)
	and.b	ioo_wr5(a0),d2	;Schatten
	btst	#3,d1	;Break-Bit im Parameter testen
	beq	rsesfcu1	;kein Break
	ori.b	#$10,d2	;Break
rsesfcu1: 
	move.b	d2,ioo_wr5(a0)
	move.b	#$05,(a2)	;SCC-WR5 beschreiben
	move.b	d2,(a2)
rsesfct0: 
	move.w	d4,sr	;INTsperre Ende
rsesende: 
	movem.l	(sp)+,d3/d4/a3
	rts

rsesw5cl:		;Bit/Zeichen fÅr	WR5, Index ist MFP-Wert in Bit1..0
	DC.b $60,$20,$40,$00
rsesw3cl:		;Komplettwert aus Bit/Zeichen	fÅr WR3
	DC.b $c1,$41,$81,$01



rses_suchbaud:      
;aufgerufen durch escc_rsconf
;in:   D0.l: zu suchende Klartext-Baudrate
;      A0:   Zeiger	auf IOREC (mit Baudratentabelle davor)
;out:  D0.l: mîgliche Klartextspeed
;      D0.bit31: 0=	Rate vorhanden
;	       1=	andere Rate in D0(bit30..0) vorgeschlagen
;      D1.w: wenn Rate vorhanden: Indexnummer zur	Klartextspeed
;kill: D0/D1
;Suche neue Baudrate. So kompliziert, damit die Tabelle unsortiert sein kann.
	movem.l	d2-d5,-(sp)
	moveq.l	#-1,d3	;maximaler Differenzwert (unsigned)
	moveq.l	#-1,d4	;noch keine kleinere Rate gefunden, Index
	moveq.l	#-1,d5	;fÅr allerkleinste Rate aus Tabelle
	move.w	#(4*(16-1)),d1	;index in D1.W, count down, Faktor 4 long
;D1-Highword soll 0	bleiben
.sea:     
	move.l	d0,d2	;speed
	cmp.l	ubd_ofs(a0,d1.w),d5	;suche nebenbei kleinste
	bls	.nogsm	; Baudrate der ganzen Tabelle
	move.l	ubd_ofs(a0,d1.w),d5	;in D5.l
.nogsm:   
	sub.l	ubd_ofs(a0,d1.w),d2	;ermittle	Differenz
	beq	.ende	;Rate genau gefunden
	bcs	.nex	;grîûere Rate
;eine kleinere Rate	gefunden
	cmp.l	d3,d2	;kleinere Rate, mit geringerer Differenz?
	bcc	.nex	; nein
	move.l	d2,d3	;merke neues	Minimum der Differenz
	move.w	d1,d4	;merke Indexwert dazu
.nex:	subq.w	#4,d1	;Index weiter
	bcc	.sea	;weiter suchen
;keine genaue Rate gefunden
	move.l	d5,d0	;niedrigste Bdrate aus	ganzer Tab.
	tst.w	d4	;Index fÅr kleinere Rate gefunden?
	bmi	.lowest	; nein, niedrigstmîgliche liefern
	move.l	ubd_ofs(a0,d4.w),d0	; ja, nÑchstniedrigere Bdrate
	move.w	d4,d1	;Indexwert dazu
.lowest:  
	bset.l	#31,d0
.ende:    
	lsr.w	#2,d1	;ermittle aus Index die Rsconf-Nummer
	movem.l	(sp)+,d2-d5
	rts


rses_setbd:         
;Baudrate	im ESCC einstellen
;in:   D1.w gÅltiger Rsconf-Index
; rest wie escc_rsconf
	move.b	d1,ioo_bd(a0)	;neue speed sichern
	add.w	d1,d1	;WORDs in Tabelle
	move.w	bdt_ofs(a0,d1.w),d1	;Teiler holen
	move.w	sr,d4	;SR sichern
	ori.w	#$0700,sr	;INTERRUPTSPERRE
	move.b	#12,(a2)	;aus Tab. in	SCC Kanal	schreiben
	move.b	d1,(a2)	;WR12: Bit7..0, ist immer BG-Teiler
	lsr.w	#8,d1	;Highbyte ins Lowbyte
	move.b	#13,(a2)	;WR13 WéHLEN
	cmpi.b	#$f0,d1	;$Fx ?
	bcs	.nofx	;nein, Baudrate Åber Bd.Gen und PCLK
	move.b	#0,(a2)	;WR13: Bit15..8, auf 0
	bra	.fx
.nofx:		;benutze Bd-Gen.	mit PCLK und	Takt=rate*16
	move.b	d1,(a2)	;WR13: Bit15..8, Wert aus Tabelle
	move.b	#6,d1	;Standardwert fÅr WR4,	WR11
.fx:		;D1.Bit7 wird als negiertes WR14.Bit1 benutzt
	moveq.l	#2,d2	;WR14.Bit1 =1 setzen:
	or.b	ioo_wr14(a0),d2	;Bd-Gen.Quelle ist PCLK
	tst.b	d1
	bpl	.pclk
	andi.b	#$fd,d2	;WR14.Bit1 =0: Bd-Gen Quelle ist	/RTxC
.pclk:    
	move.b	d2,ioo_wr14(a0)
	move.b	#14,(a2)
	move.b	d2,(a2)	;WR14
;D1.Bit3..2 nach WR4.Bit7..6
	moveq.l	#$c,d3
	and.b	d1,d3
	lsl.b	#4,d3
	moveq.l	#$3f,d2
	and.b	ioo_wr4(a0),d2
	or.b	d3,d2
	move.b	d2,ioo_wr4(a0)
	move.b	#4,(a2)
	move.b	d2,(a2)	;WR4
;D1.Bit1..0 nach WR11.Bit6..5 und WR11.Bit4..3
	andi.b	#3,d1
	lsl.b	#3,d1	;nach Bit4..3
	moveq.l	#2,d2	;spaûeshalber: Wenn /TRxC Ausgang wÑre, dann vom Bd-Gen.
	or.b	d1,d2
	lsl.b	#2,d1	;nach Bit6..5
	or.b	d1,d2	;zusammen, restliche Bits 0
	move.b	#11,(a2)
	move.b	d2,(a2)	;WR11: Taktauswahlen
	move.w	d4,sr	;INTERRUPTS FREI
	rts


	IFNE FOR_ESCC
enag_4zi:	DC.w -1	;erlaube Åberhaupt 4 Zeichen Interrupt
	ENDC



init_wr5	= $ea	;Initialwert ESCC-WR5


;Interruptadresstabelle Kanal B, muû	genau vor IOREC & Bdtab liegen
;Adr. des	Sendepuffer-leer-Vektors
;Adr. der	Interruptroutinen (Send/Empf fÅr OHNE, XON/XOFF, RTS/CTS)
	DC.l iva_esccB
	DC.l i_esccB_teo,i_esccB_rfo
	DC.l i_esccB_tes,i_esccB_rfs
	DC.l i_esccB_teh,i_esccB_rfh

;muû vor IOREC liegen
m2_bgtab:		;Marken sind nur	fÅr Init.routinen
;Baudraten fÅr 8MHz, SCC-PCLK im normalen MegaSTE/TT/Falcon
	DC.w $000b,$0018,$0032,$0044,$0067,$007c,$008a,$00d0
	DC.w $01a1,$0345
m2_pt_bt:		;bei MegaSTE/Falcon 230400, 115200, 57600 reinpatchen
	DC.w $04e8,$068c,$074d
;herausgenommen:
;	    DC.w	$08ee,$0d1a,$13a8  ;110Bd, 75Bd, 50Bd
;und eingesetzt:
	DC.w $fd00,$f500,$f900	;38400Bd, 153600Bd, 76800Bd
;die angehÑngte Klartexttabelle:
	DC.l 19200,9600,4800,3600
	DC.l 2400,2000,1800,1200
	DC.l 600,300
m2_pt_bk:		;bei MegaSTE/Falcon 230400, 115200, 57600 reinpatchen
	DC.l 200,150,134
	DC.l 38400,153600,76800

;Initialisierungswerte: 19200Bd, 8N1, kein Handshake
;IOREC fÅr Modem2
m2_iorec:	DC.l m2_rbuf
	DC.w recbuflen
	DC.w 0
	DC.w 0
	DC.w recbuflen/4
	DC.w (recbuflen*3)/4
	DC.l m2_tbuf
	DC.w trabuflen
	DC.w 0
	DC.w 0
	DC.w trabuflen/4	;eigentlich sinnlos
	DC.w (trabuflen*3)/4	;eigentlich sinnlos
	DC.b $84,init_wr5	;ucr, wr5
	DC.b 0,0	;ioo_re,ioo_te
	DC.b 0,0	;kein Handshake,	x
	DC.b 0	;Baudrate
	DC.b $ff	;ioo_and fÅr 8Bit
	DC.l 19200	;Klartextrate
;Maske der vorhandenen I/O-Lines
;RNG oder	DSR wird eventuell durch Initialisierungsroutine gelîscht
m2_iolines:         
	DC.l TIOCM_DTR|TIOCM_CAR|TIOCM_DSR|TIOCM_CTS|TIOCM_RNG
	DC.l m2_bconin
	DC.l m2_fifo2buf
	DC.b $44,3	;WR4, WR14


;Interruptadresstabelle Kanal A, muû	genau vor IOREC & Bdtab liegen
;Adr. des	Sendepuffer-leer-Vektors
;Adr. der	Interruptroutinen (Send/Empf fÅr OHNE, XON/XOFF, RTS/CTS)
	DC.l iva_esccA
	DC.l i_esccA_teo,i_esccA_rfo
	DC.l i_esccA_tes,i_esccA_rfs
	DC.l i_esccA_teh,i_esccA_rfh	;Voreinst. RS232

;muû genau vor IOREC liegen
s2_bgtab:		;Marke ist nur fÅr Init.routinen
;fÅr 8MHz, und 3672000Hz an /RTxCA
	DC.w $000b,$0018,$0032,$0044,$0067,$007c,$008a,$00d0
	DC.w $01a1,$0345
;herausgenommen wurden:
;	     DC.w $04e8,$068c,$074d,$08ee   ;200Bd,150Bd, 134Bd, 110Bd
;und eingesetzt (Åber Taktquellenumschaltung):
	DC.w $f400,$f800,$fc00,$f601	;230400Bd, 115200Bd, 57600Bd,	38400Bd
	DC.w $0d1a,$13a8	;beim SCC sind im TOS2.06 75Bd und 50Bd korrekt
;die angehÑngte Klartexttabelle:
	DC.l 19200,9600,4800,3600
	DC.l 2400,2000,1800,1200
	DC.l 600,300,230400,115200	;(230400 statt 200,	115200 statt 150)
	DC.l 57600,38400,75,50	;(57600 statt 134, 38400 statt 110)

;IOREC fÅr Serial2
s2_iorec:	DC.l s2_rbuf
	DC.w recbuflen
	DC.w 0
	DC.w 0
	DC.w recbuflen/4
	DC.w (recbuflen*3)/4
	DC.l s2_tbuf
	DC.w trabuflen
	DC.w 0
	DC.w 0
	DC.w recbuflen/4
	DC.w (recbuflen*3)/4
	DC.b $84,init_wr5	;ucr, wr5
	DC.b 0,0	;ioo_re,ioo_te
	DC.b 0,0	;kein Handshake,	x
	DC.b 0	;Baudrate
	DC.b $ff	;ioo_and fÅr 8Bit
	DC.l 19200	;Klartextrate
;I/O-Lines  #### noch lÑngst nicht alle mîglichen
;fÅr Original-Ataris wird entweder DSR oder RNG entfernt bei Installation
;Werte gelten nur fÅr RS232
	DC.l TIOCM_DTR|TIOCM_CAR|TIOCM_DSR|TIOCM_CTS|TIOCM_RNG
	DC.l s2_bconin
	DC.l s2_fifo2buf
	DC.b $44,3	;WR4, WR14


;-------------------------------------------------------------------------

	TEXT


s2_fcntl: 
;Fcntl fÅr SERIAL2
;Mag!X-mÑûig
;in:   A0: Zeiger auf Filedeskriptor, ### derzeit	Null
;      A1: LONG argument (meist ein Zeiger)
;      D0: WORD command
;out:  D0: Fehlercode
;kill: D0-D2/A0-A2
	cmpi.w	#FIONREAD,d0
	beq	.m000
	cmpi.w	#FIONWRITE,d0
	beq	.m001
	cmpi.w	#TIOCCBRK,d0
	beq	.m002
	cmpi.w	#TIOCSBRK,d0
	beq	.m003
	cmpi.w	#TIOCIBAUD,d0
	beq	.m004
	cmpi.w	#TIOCOBAUD,d0
	beq	.m005
	cmpi.w	#TIOCGFLAGS,d0
	beq	.m006
	cmpi.w	#TIOCSFLAGS,d0
	beq	.m007
	cmpi.w	#TIOCCTLMAP,d0
	beq	.m008
	cmpi.w	#TIOCCTLGET,d0
	beq	.m009
	cmpi.w	#TIOCCTLSET,d0
	beq	.m010
	cmpi.w	#TIONOTSEND,d0
	beq	.m011
	cmpi.w	#TIOCFLUSH,d0
	beq	.m012
	moveq.l	#EINVFN,d0	;invalid function number, ## ???	passende Meldung
	bra	.ende
.ok_ende: 
	moveq.l	#0,d0	;OK
.ende:    
	rts

.m000:    
;FIONREAD
;Anzahl der ohne Warten lesbaren Byte auf der Adresse hinterlassen
	IFNE FOR_ESCC
	bsr	s2_fifo2buf
	ENDC
	moveq.l	#0,d1
	move.w	$8+s2_iorec,d1	;Schreibz
	sub.w	$6+s2_iorec,d1	;Lesez
	bcc	.m000a
	add.w	$4+s2_iorec,d1
.m000a:	move.l	d1,(a1)	;Anzahl belegter PlÑtze = vorhandene Byte
	bra	.ok_ende

.m001:    
;FIONWRITE:
;Anzahl der ohne Warten schreibbaren	Byte auf der	Adresse hinterlassen
	moveq.l	#0,d1
	move.w	$e+$6+s2_iorec,d1	;Lesez
	sub.w	$e+$8+s2_iorec,d1	;Schreibz
	bhi	.m001a
	add.w	$e+$4+s2_iorec,d1
.m001a:	subq.l	#2,d1
	bpl	.m001b
	moveq.l	#0,d1	;nur zur Sicherheit, dÅrfte nie - werden
.m001b:	move.l	d1,(a1)	;Anzahl freier PlÑtze
	bra	.ok_ende


.m002:    
;TIOCCBRK
;Break inaktivieren
	moveq.l	#$ef,d1	;Bit4 =0: kein Break
	move.w	sr,d0
	ori.w	#$700,sr	;INTERRUPTSPERRE
	and.b	ioo_wr5+s2_iorec,d1
	move.b	d1,ioo_wr5+s2_iorec
	move.b	#5,esccA_ct
	move.b	d1,esccA_ct
	move.w	d0,sr	;INTERRUPTS FREI
	bra	.ok_ende

.m003:    
;TIOCSBRK
;Break aktivieren
	moveq.l	#$10,d1	;Bit4 =1: Break senden
	move.w	sr,d0
	ori.w	#$700,sr	;INTERRUPTSPERRE
	or.b	ioo_wr5+s2_iorec,d1
	move.b	d1,ioo_wr5+s2_iorec
	move.b	#5,esccA_ct
	move.b	d1,esccA_ct
	move.w	d0,sr	;INTERRUPTS FREI
	bra	.ok_ende


.m004:    
;TIOCIBAUD
;wie folgendes

.m005:    
;TIOCOBAUD
	move.l	(a1),d0	;speed
	bpl	.m005a
.m005ar:  
;nur erfragen
	move.l	a1,-(sp)	;sichern
	moveq.l	#-1,d0	;uspeed erfragen
	move.l	d0,-(sp)
	move.w	#SETUSPEED,-(sp)
	bsr	s2_rsconf	;Direktaufruf Spezialfunktion
	addq.l	#6,sp
	movea.l	(sp)+,a1
	move.l	d0,(a1)
	bra	.ok_ende
.m005a:   
	bne	.m005b
	bsr	.dtr_reset	;DTR inaktiv
	bra	.m005ar	;noch Speed erfragen
.m005b:   
;setzen bzw. niedrigere liefern
	move.l	a1,-(sp)	;sichern
	move.l	d0,-(sp)
	move.w	#SETUSPEED,-(sp)
	bsr	s2_rsconf
	addq.l	#6,sp
	movea.l	(sp)+,a1
	bclr.l	#31,d0	;test and clear
	beq	.m005bo	;ok, speed eingestellt
	move.l	d0,(a1)	;speed-Vorschlag sichern
	moveq.l	#ERANGE,d0	;Fehlermeldung
	bra	.ende
.m005bo:  
	move.l	d0,(a1)	;alte speed sichern
	bsr	.dtr_set	;DTR aktiv
	bra	.ok_ende


.m006:    
;TIOCGFLAGS
;Lesen der öbertragungsprotokollparameter
;da Rsconf den Handshakemodus nicht liefert, wird	alles direkt zugegriffen
	moveq.l	#$f,d1	;bit7-0 als AND-Maske
	move.b	ioo_ucr+s2_iorec,d0	;UCR
	btst.l	#2,d0
	beq	.m006np	;keine ParitÑt
	bset.l	#15,d1	;set odd
	btst.l	#1,d0
	beq	.m006np	;really odd parity
	bclr.l	#15,d1	;clear odd parity flag
	bset.l	#14,d1	;even parity
.m006np:	lsr.b	#3,d0	;Bit/Char & Stoppbits nach Bit3-0
	and.b	d0,d1
	moveq.l	#3,d0	;mask
	and.b	$20+s2_iorec,d0	;get direct:	handshake	mode
	moveq.l	#12,d2
	lsl.w	d2,d0	;XON/XOFF & RTS/CTS
	or.w	d0,d1
	move.w	d1,(a1)	;Wert ablegen
	bra	.ok_ende


.m007:    
;TIOCSFLAGS
;Setzen der öbertragungsprotokollparameter
;Rsconf ist umstÑndlich, aber der einzige Weg, den Handshake zu initialisieren
	move.w	(a1),d2	;Wert holen
	moveq.l	#ERANGE,d0	;vorsorglich	Fehler
	moveq.l	#3,d1	;teste Stoppbitanzahl
	and.w	d2,d1
	beq	.ende	;Synchronmode nicht unterstÅtzt!
	moveq.l	#-1,d0
	move.l	d0,-(sp)	;SCR und TSR	nicht Ñndern
	move.w	d0,-(sp)	;RSR nicht Ñndern
	moveq.l	#$f,d1	;mask
	and.w	d2,d1
	lsl.b	#3,d1	;Bit3-0 -> 6-3, Stopps	& Bit/Char
	btst.l	#15,d2	;odd parity?
	beq	.m007no	;no
	bset.l	#2,d1	;parity used, odd
.m007no:	btst.l	#14,d2	;even parity?
	beq	.m007ne	;no
	ori.b	#$06,d1	;parity used, even
.m007ne:	bset.l	#7,d1	;divide by 16, always in async mode
	move.w	d1,-(sp)	;fÅr das UCR
	moveq.l	#12,d1
	lsr.w	d1,d2	;Handshakebits nach Bit1-0
	andi.w	#3,d2
	move.w	d2,-(sp)	;fÅr flowctl
	move.w	d0,-(sp)	;-1 fÅr speed nicht Ñndern
;Direktaufruf wegen	gleicher Registerkillkonvention mîglich
	bsr	s2_rsconf
	lea	12(sp),sp
	bra	.ok_ende


.m008:    
;TIOCCTLMAP
;Erfrage I/O-Lines and Signals
	move.l	ioo_iol+s2_iorec,d0
	tst.b	1+a_lan_s2
	bne	.m008a	;SERIAL2
;bei LAN ausblenden: DSR(6) RI(5) RTS(2) DTR(1)
	andi.l	#$ffffff99,d0
;##### evtl DTR wieder zulassen falls nicht Hwhs aktuell ist
;##### evtl spÑter LE einblenden?
.m008a:   
	move.l	d0,(a1)+	;lines
	moveq.l	#0,d0	;zum lîschen
	move.l	d0,(a1)+	;no callback	activate
	move.l	d0,(a1)+	;no callback	inactivate
	move.l	d0,(a1)+	;no signal
	move.l	d0,(a1)+	;no signal
	move.l	d0,(a1)+	;no extension
	bra	.ok_ende


.m009:    
;TIOCCTLGET
;Abfragen	der I/O
	moveq.l	#0,d0
	move.b	esccA_ct,d1	;weiterverwendet
	btst.l	#3,d1	;DCD, 1-aktiv
	beq	.m009a
	ori.w	#TIOCM_CAR,d0
.m009a:   
	btst.l	#5,d1	;CTS, 1-aktiv
	beq	.m009b
	ori.w	#TIOCM_CTS,d0
.m009b:   
	btst.l	#4,d1	;SYNC, verschiedene Bedeutungen,	1-aktiv
	beq	.m009c	;inaktiv
;MODICODE
;geÑndert	auf "#TIOCM_DSR" bei Original-Ataris mit ausgeschalteter
;DSR->RING-Umlage
MOCs2ri	= *
	ori.w	#TIOCM_RNG,d0	;RING bei ST_ESCC (oder Umlage),	aktiv
.m009c:   
	IFNE FOR_ST_ESCC
	btst.b	#3,esccX_port	;DSR bei ST_ESCC, 0-aktiv
	bne	.m009d	;inaktiv
	ori.w	#TIOCM_DSR,d0	;aktiv
	ENDC
.m009d:   
	move.b	ioo_wr5+s2_iorec,d1	;DTR (Bit7, 1-aktiv), D1.b fÅr RTS
	bpl	.m009f	;inaktiv
	ori.w	#TIOCM_DTR,d0
.m009f:   
	btst.l	#1,d1	;RTS (Bit1, 1-aktiv)
	beq	.m009g	;inaktiv
	ori.w	#TIOCM_RTS,d0
.m009g:   
	move.l	d0,(a1)	;Bitsammlung	ablegen
	bra	.ok_ende


.m010:    
;TIOCCTLSET
;Setzen der I/O-Lines
	move.l	(a1),d0
	andi.w	#TIOCM_DTR,d0
	beq	.m010a
	move.l	4(a1),d0
	lea	.dtr_set,a2
	andi.w	#TIOCM_DTR,d0
	bne	.m010aa	;aktivieren
	lea	.dtr_reset,a2	;inaktivieren
.m010aa:  
	jsr	(a2)
.m010a:   
	bra	.ok_ende


;Bei .dtr_(re)set wird DTR nur bedient, falls SERIAL2 aktiv	ist
;(und nicht LAN######)

.dtr_reset:         
;FÅr TIOCCTLSET und	TIOC?BAUD
	tst.b	1+a_lan_s2	;TIOCM_DTR =	2
	beq	.dtr_nox	;LAN aktiv, DTR ist kein I/O####
	andi.b	#$7f,ioo_wr5+s2_iorec
	bra	.dtr_x

.dtr_set: 
;FÅr TIOCCTLSET und	TIOC?BAUD
	tst.b	1+a_lan_s2	;TIOCM_DTR =	2
	beq	.dtr_nox	;LAN aktiv, DTR ist kein I/O####
	ori.b	#$80,ioo_wr5+s2_iorec
.dtr_x:   
	move.w	sr,-(sp)
	ori.w	#$700,sr	;INTERRUPTSPERRE
	move.b	#5,esccA_ct
	move.b	ioo_wr5+s2_iorec,esccA_ct
	move.w	(sp)+,sr	;INTERRUPTS frei
.dtr_nox: 
	rts


.m011:    
;TIONOTSEND
	lea	esccA_ct,a0
	lea	s2_iorec,a2
	bsr	escc_tionotsend
	move.l	d0,(a1)	;Anzahl ungesendeter Byte
	bra	.ok_ende


.m012:    
;TIOCFLUSH
;verschiedene Arten	des Pufferlîschens
	lea	esccA_ct,a0
	lea	s2_iorec,a2
	bsr	escc_tiocflush
	bra	.ende



escc_tiocflush:     
;verschiedene Arten	des Pufferlîschens
;in:   A0: Zeiger auf ESCC-Control-Register
;      A1: Parameter (special)
;      A2: Zeiger auf IOREC
;out:  D0: Returnwert
	move.l	a1,d0	;D0: flush-Parameter
	bmi	.m012a	;send all with user defined timeout
	beq	.m012b	;send all with system timeout
	cmpi.l	#4,d0
	bcs	.m012c	;1..3: clear	buffers
	moveq.l	#EINVFN,d0	;error: subsubfunction	not supported
	bra	.ende

.m012a:   
;send all	with user	defined timeout
	moveq.l	#0,d2
	sub.l	d0,d2	;(sub because -tout)
.m012ax:  
;send all	with timeout in D2.l
	add.l	_hz_200,d2	;wait max. until D2.l
.m012a0:  
	bsr	escc_tionotsend
	tst.l	d0
	beq	.ok_ende
;### simple wait loop in this implementation
	cmp.l	_hz_200,d2
	bcc	.m012a0	;continue waiting
	moveq.l	#EDRVNR,d0
	bra	.ende	;error: timeout

.m012b:   
;send all	with system timeout
	move.l	#4000,d2	;#### fest auf 20 Sekunden,
;#### spÑter baudraten- und DatenmengenabhÑngig
	bra	.m012ax

.m012c:   
;1..3: clear buffers
	btst.l	#1,d0
	beq	.m012c1
;Bit1 =1:	clear transmitter buffer (2, 3)
	clr.l	ioo_trp(a2)	;simply reset r+w pointer
.m012c1:  
	btst.l	#0,d0
	beq	.m012c6
;Bit0 =1:	clear receiver buffer (1, 3)
	IFNE FOR_ESCC
	movea.l	ioo_f2b(a2),a1
	jsr	(a1)	;empty ESCC rec.FIFO (if below int. level)
	ENDC
	move.w	ioo_rrp(a2),d2
	cmp.w	ioo_rwp(a2),d2
	beq	.m012c6	;buffer empty -> no action
	move.l	#1,ioo_rrp(a2)	;set r+w ptr	to "1 char"
;following kills D0-D2/A0-A2
	movea.l	ioo_bci(a2),a1
	jsr	(a1)	;read last char, actualize handshake
.m012c6:  
.ok_ende: 
	moveq.l	#0,d0
.ende:    
	rts


escc_tionotsend:    
;Anzahl der noch nicht gesendeten Byte ermitteln
;in:   A0: Zeiger auf ESCC-Control-Register
;      A2: Zeiger auf IOREC
;out:  D0: Anzahl nichtgesendeter Byte
	moveq.l	#0,d0	;Anzahl der Byte im Puffer
	move.w	ioo_twp(a2),d0	;Schreibz
	sub.w	ioo_trp(a2),d0	;Lesez
	bcc	.ns0
	add.w	ioo_tbl(a2),d0
.ns0:		;und dazu Zeichen in Hardware
	btst.b	#6,(a0)
;Der relevante Wert	"underrun" wird durch Fehlerinterrupt nicht gelîscht.
	bne	.ns1	;Puffer ist frei
	addq.l	#1,d0	;(mind.) 1 Zeichen im SCC
.ns1:		;D0.l: Anzahl ungesendeter Byte
	rts




;Die Block-I/O-Routinen fÅr die serielle öbertragung
;Sie arbeiten nichtblockierend und lesen/schreiben nie mehr	Byte, als
;im Puffer sind / in den Puffer passen. Damit hier keine Handshake-
;Behandlung rein muû, wird das jeweils letzte Byte nicht direkt Åber den
;Puffer sondern mit	bconin/bconout transportiert.


m2_fread: 
;Fread fÅr MODEM2
;Mag!X-mÑûig
;in:   A0: Zeiger auf Filedeskriptor, ### derzeit	Null
;      A1: LONG buffer
;      D0: LONG len
;out:  D0: Anzahl wirklich gelesener	Byte oder Fehlercode
;kill: D0-D2/A0-A2
	lea	m2_iorec,a2	;Adr. IOREC
	bra	escc_fread

s2_fread: 
;Fread fÅr SERIAL2
;Mag!X-mÑûig
;in:   A0: Zeiger auf Filedeskriptor, ### derzeit	Null
;      A1: LONG buffer
;      D0: LONG len
;out:  D0: Anzahl wirklich gelesener	Byte oder Fehlercode
;kill: D0-D2/A0-A2
	lea	s2_iorec,a2	;Adr. IOREC

escc_fread:         
;Fread fÅr irgendeinen ESCC-Kanal
	moveq.l	#0,d1	;Bit31-16 muû 0 bleiben
	move.w	ioo_rbl(a2),d2	;PufferlÑnge
	move.w	ioo_rwp(a2),d1	;Schreibz
	sub.w	ioo_rrp(a2),d1	;Lesez
	bcc	.fr0
	add.w	d2,d1	;LÑnge
.fr0:		;Anzahl vorhandener Byte in D1
	cmp.l	d0,d1
	bcc	.fr1	;Minimum bilden
;weniger Byte im Puffer als User fordert
	IFNE FOR_ESCC
	movea.l	ioo_f2b(a2),a0
	jsr	(a0)	;fifo2buf, LÑnge neu berechnen:
	move.w	ioo_rwp(a2),d1	;Schreibz
	sub.w	ioo_rrp(a2),d1	;Lesez
	bcc	.fres0
	add.w	d2,d1	;LÑnge
.fres0:		;Anzahl vorhandener Byte in D1
	cmp.l	d0,d1
	bcc	.fr1	;Minimum bilden
	ENDC
	move.l	d1,d0
.fr1:     
	move.l	d0,-(sp)	;Anzahl Åbertragbarer Bytes in D0 & sichern
	beq	.frend	;nichts Åbertragen
	subq.l	#2,d0	;-1 wegen letztem Byte, -1 wegen	dbra
	bcs	.frby	;einziges Byte extra
	movea.l	(a2),a0	;Interruptpufferadresse
	move.w	ioo_rrp(a2),d1	;Lesez
.frcop:	addq.w	#1,d1	;Lesez umlaufend
	cmp.w	d2,d1	;D2: PufferlÑnge
	bcs	.frbt
	moveq	#0,d1
.frbt:	move.b	0(a0,d1.l),(a1)+	;Byte kopieren
	dbra	d0,.frcop
	move.w	d1,ioo_rrp(a2)	;Lesez update
.frby:    
	move.l	a1,-(sp)	;Zeiger sichern
	movea.l	ioo_bci(a2),a0
	jsr	(a0)	;Bconin, hole Byte, aktualisiert	Handshake
	movea.l	(sp)+,a1	;Pufferzeiger wieder holen
	move.b	d0,(a1)	;letztes Byte in Userpuffer
.frend:   
	move.l	(sp)+,d0	;Byteanz. holen
	rts


m2_fwrite:          
;Fwrite fÅr MODEM2
;Mag!X-mÑûig
;in:   A0: Zeiger auf Filedeskriptor, ### derzeit	Null
;      A1: LONG buffer
;      D0: LONG len
;out:  D0: Anzahl wirklich gelesener	Byte oder Fehlercode
;kill: D0-D2/A0-A2
	move.l	a3,-(sp)
	lea	m2_iorec,a2	;Adr. IOREC
	lea	m2_bconout,a3	;Routine
	bra	escc_fwrite

s2_fwrite:          
;Fwrite fÅr SERIAL2
;Mag!X-mÑûig
;in:   A0: Zeiger auf Filedeskriptor, ### derzeit	Null
;      A1: LONG buffer
;      D0: LONG len
;out:  D0: Anzahl wirklich gelesener	Byte oder Fehlercode
;kill: D0-D2/A0-A2
	move.l	a3,-(sp)
	lea	s2_iorec,a2	;Adr. IOREC
	lea	s2_bconout,a3	;Routine

escc_fwrite:        
;Fwrite fÅr beliebigen ESCC-Kanal
	moveq.l	#0,d1	;Bit31-16 muû 0 bleiben
	move.w	ioo_tbl(a2),d2	;PufferlÑnge
;freier Platz gilt fÅr nichtblockierenden bconout-Aufruf
	move.w	ioo_trp(a2),d1	;freien Platz berechnen, Lesezeiger
	sub.w	ioo_twp(a2),d1	;minus Schreibzeiger
	bhi	.fw0	;keine Korrektur
	add.w	d2,d1	;PufferlÑnge	dazu
.fw0:	subq.l	#2,d1
	bpl	.fwxx
	moveq.l	#0,d1	;Sicherheit,	sollte nie negativ werden
.fwxx:		;Anzahl freier PlÑtze in D1
	cmp.l	d0,d1
	bcc	.fw1	;Minimum bilden
	move.l	d1,d0
.fw1:     
	move.l	d0,-(sp)	;sichern als	returnvalue, setzt Flags!!!
	beq	.fwend	;nichts Åbertragen
;D0: Anzahl Bytes fÅr Transfer (>=1), D0-1 fÅr Blocktransfer
	subq.l	#2,d0	;-1 wegen dbra, -1 wegen letztem	Byte
	bcs	.fwby	;letztes / einziges Byte per Bconin
	movea.l	ioo_tba(a2),a0	;Interruptpufferadresse
	move.w	ioo_twp(a2),d1
.fwcop:	addq.w	#1,d1	;Schreibz umlaufend
	cmp.w	d2,d1	;D2: PufferlÑnge
	bcs	.fwbt
	moveq	#0,d1
.fwbt:	move.b	(a1)+,0(a0,d1.l)	;Byte kopieren
	dbra	d0,.fwcop
	move.w	d1,ioo_twp(a2)	;Schreibz update
.fwby:    
	move.b	(a1),d0	;letztes Byte
	move.l	d0,-(sp)	;LONG! (wegen Dummy)
	jsr	(a3)	;Byte schreiben, aktualisiert Handshake
	addq.l	#4,sp
.fwend:   
	move.l	(sp)+,d0	;Byteanz. holen
	movea.l	(sp)+,a3
	rts


m2_fcntl: 
;Fcntl = ioctl fÅr MODEM2
;Mag!X-mÑûig
;in:   A0: Zeiger auf Filedeskriptor, ### derzeit	Null
;      A1: LONG argument (meist ein Zeiger)
;      D0: WORD command
;out:  D0: Fehlercode
;kill: D0-D2/A0-A2
	cmpi.w	#FIONREAD,d0
	beq	.m000
	cmpi.w	#FIONWRITE,d0
	beq	.m001
	cmpi.w	#TIOCCBRK,d0
	beq	.m002
	cmpi.w	#TIOCSBRK,d0
	beq	.m003
	cmpi.w	#TIOCIBAUD,d0
	beq	.m004
	cmpi.w	#TIOCOBAUD,d0
	beq	.m005
	cmpi.w	#TIOCGFLAGS,d0
	beq	.m006
	cmpi.w	#TIOCSFLAGS,d0
	beq	.m007
	cmpi.w	#TIOCCTLMAP,d0
	beq	.m008
	cmpi.w	#TIOCCTLGET,d0
	beq	.m009
	cmpi.w	#TIOCCTLSET,d0
	beq	.m010
	cmpi.w	#TIONOTSEND,d0
	beq	.m011
	cmpi.w	#TIOCFLUSH,d0
	beq	.m012
	moveq.l	#EINVFN,d0	;invalid function number, ## ???	passende Meldung
	bra	.ende
.ok_ende: 
	moveq.l	#0,d0	;OK
.ende:    
	rts

.m000:    
;FIONREAD
;Anzahl der ohne Warten lesbaren Byte auf der Adresse hinterlassen
	IFNE FOR_ESCC
	bsr	m2_fifo2buf
	ENDC
	moveq.l	#0,d1
	move.w	$8+m2_iorec,d1	;Schreibz
	sub.w	$6+m2_iorec,d1	;Lesez
	bcc	.m000a
	add.w	$4+m2_iorec,d1
.m000a:	move.l	d1,(a1)	;Anzahl belegter PlÑtze = vorhandene Byte
	bra	.ok_ende

.m001:    
;FIONWRITE:
;Anzahl der ohne Warten schreibbaren	Byte auf der	Adresse hinterlassen
	moveq.l	#0,d1
	move.w	$e+$6+m2_iorec,d1	;Lesez
	sub.w	$e+$8+m2_iorec,d1	;Schreibz
	bhi	.m001a
	add.w	$e+$4+m2_iorec,d1
.m001a:	subq.l	#2,d1
	bpl	.m001b
	moveq.l	#0,d1	;nur zur Sicherheit, dÅrfte nie - werden
.m001b:	move.l	d1,(a1)	;Anzahl freier PlÑtze
	bra	.ok_ende

.m002:    
;TIOCCBRK
;Break inaktivieren
	moveq.l	#$ef,d1	;Bit4 =0: kein Break
	move.w	sr,d0
	ori.w	#$700,sr	;INTERRUPTSPERRE
	and.b	ioo_wr5+m2_iorec,d1
	move.b	d1,ioo_wr5+m2_iorec
	move.b	#5,esccB_ct
	move.b	d1,esccB_ct
	move.w	d0,sr	;INTERRUPTS FREI
	bra	.ok_ende

.m003:    
;TIOCSBRK
;Break aktivieren
	moveq.l	#$10,d1	;Bit4 =1: Break senden
	move.w	sr,d0
	ori.w	#$700,sr	;INTERRUPTSPERRE
	or.b	ioo_wr5+m2_iorec,d1
	move.b	d1,ioo_wr5+m2_iorec
	move.b	#5,esccB_ct
	move.b	d1,esccB_ct
	move.w	d0,sr	;INTERRUPTS FREI
	bra	.ok_ende


.m004:    
;TIOCIBAUD
;wie folgendes

.m005:    
;TIOCOBAUD
	move.l	(a1),d0	;speed
	bpl	.m005a
.m005ar:  
;nur erfragen
	move.l	a1,-(sp)	;sichern
	moveq.l	#-1,d0	;uspeed erfragen
	move.l	d0,-(sp)
	move.w	#SETUSPEED,-(sp)
	bsr	m2_rsconf	;Direktaufruf Spezialfunktion
	addq.l	#6,sp
	movea.l	(sp)+,a1
	move.l	d0,(a1)
	bra	.ok_ende
.m005a:   
	bne	.m005b
	bsr	.dtr_reset	;DTR inaktiv
	bra	.m005ar	;noch Speed erfragen
.m005b:   
;setzen bzw. niedrigere liefern
	move.l	a1,-(sp)	;sichern
	move.l	d0,-(sp)
	move.w	#SETUSPEED,-(sp)
	bsr	m2_rsconf
	addq.l	#6,sp
	movea.l	(sp)+,a1
	bclr.l	#31,d0	;test and clear
	beq	.m005bo	;ok, speed eingestellt
	move.l	d0,(a1)	;speed-Vorschlag sichern
	moveq.l	#ERANGE,d0	;Fehlermeldung
	bra	.ende
.m005bo:  
	move.l	d0,(a1)	;alte speed sichern
	bsr	.dtr_set	;DTR aktiv
	bra	.ok_ende


.m006:    
;TIOCGFLAGS
;Lesen der öbertragungsprotokollparameter
;da Rsconf den Handshakemodus nicht liefert, wird	alles direkt zugegriffen
	moveq.l	#$f,d1	;bit7-0 als AND-Maske
	move.b	ioo_ucr+m2_iorec,d0	;UCR
	btst.l	#2,d0
	beq	.m006np	;keine ParitÑt
	bset.l	#15,d1	;set odd
	btst.l	#1,d0
	beq	.m006np	;really odd parity
	bclr.l	#15,d1	;clear odd parity flag
	bset.l	#14,d1	;even parity
.m006np:	lsr.b	#3,d0	;Bit/Char & Stoppbits nach Bit3-0
	and.b	d0,d1
	moveq.l	#3,d0	;mask
	and.b	$20+m2_iorec,d0	;get direct:	handshake	mode
	moveq.l	#12,d2
	lsl.w	d2,d0	;XON/XOFF & RTS/CTS
	or.w	d0,d1
	move.w	d1,(a1)	;Wert ablegen
	bra	.ok_ende


.m007:    
;TIOCSFLAGS
;Setzen der öbertragungsprotokollparameter
;Rsconf ist umstÑndlich, aber der einzige Weg, den Handshake zu initialisieren
	move.w	(a1),d2	;Wert holen
	moveq.l	#ERANGE,d0	;vorsorglich	Fehler
	moveq.l	#3,d1	;teste Stoppbitanzahl
	and.w	d2,d1
	beq	.ende	;Synchronmode nicht unterstÅtzt!
	moveq.l	#-1,d0
	move.l	d0,-(sp)	;SCR und TSR	nicht Ñndern
	move.w	d0,-(sp)	;RSR nicht Ñndern
	moveq.l	#$f,d1	;mask
	and.w	d2,d1
	lsl.b	#3,d1	;Bit3-0 -> 6-3, Stopps	& Bit/Char
	btst.l	#15,d2	;odd parity?
	beq	.m007no	;no
	bset.l	#2,d1	;parity used, odd
.m007no:	btst.l	#14,d2	;even parity?
	beq	.m007ne	;no
	ori.b	#$06,d1	;parity used, even
.m007ne:	bset.l	#7,d1	;divide by 16, always in async mode
	move.w	d1,-(sp)	;fÅr das UCR
	moveq.l	#12,d1
	lsr.w	d1,d2	;Handshakebits nach Bit1-0
	andi.w	#3,d2
	move.w	d2,-(sp)	;fÅr flowctl
	move.w	d0,-(sp)	;-1 fÅr speed nicht Ñndern
;Direktaufruf wegen	gleicher Registerkillkonvention mîglich
	bsr	m2_rsconf
	lea	12(sp),sp
	bra	.ok_ende


.m008:    
;TIOCCTLMAP
;Erfrage I/O-Lines and Signals
	move.l	ioo_iol+m2_iorec,(a1)+
	moveq.l	#0,d0	;zum lîschen
	move.l	d0,(a1)+	;no callback	activate
	move.l	d0,(a1)+	;no callback	inactivate
	move.l	d0,(a1)+	;no signal
	move.l	d0,(a1)+	;no signal
	move.l	d0,(a1)+	;no extension
	bra	.ok_ende


.m009:    
;TIOCCTLGET
;Abfragen	der I/O
	moveq.l	#0,d0
	move.b	esccB_ct,d1	;D1.b weiterverwendet
	btst.l	#3,d1	;DCD, 1-aktiv
	beq	.m009a
	ori.w	#TIOCM_CAR,d0
.m009a:   
	btst.l	#5,d1	;CTS, 1-aktiv
	beq	.m009b
	ori.w	#TIOCM_CTS,d0
.m009b:   
	btst.l	#4,d1	;SYNC, verschiedene Bedeutungen,	1-aktiv
	beq	.m009c	;inaktiv
;MODICODE
;geÑndert	auf "#TIOCM_DSR" bei Original-Ataris auûer
;MegaSTE mit angeschalteter DSR->RING-Umlage
MOCm2ri	= *
	ori.w	#TIOCM_RNG,d0	;RING bei ST_ESCC (oder Umlage),	aktiv
.m009c:   
	IFNE FOR_ST_ESCC
	btst.b	#2,esccX_port	;DSR bei ST_ESCC, 0-aktiv
	bne	.m009e	;inaktiv
	ori.w	#TIOCM_DSR,d0	;aktiv
	ELSE
;fÅr TT und Falcon noch ein RING erfragen
;MODICODE
;bei TT (RING ist Bit3 im TT-MFP): btst.b #3,mfp_tt
;bei MegaSTE:	               Åberschreibe die 3 Befehle mit nop
MOCm2s0	= *
	btst.b	#6,mfp	;Falcon: RING ist Bit6	im ST-MFP
	bne	.m009e	;inaktiv
	ori.w	#TIOCM_RNG,d0
MOCm2e0	= *
	ENDC
.m009e:   
	move.b	ioo_wr5+m2_iorec,d1	;DTR (Bit7, 1-aktiv), D1.b fÅr RTS
	bpl	.m009f	;inaktiv
	ori.w	#TIOCM_DTR,d0
.m009f:   
	btst.l	#1,d1	;RTS (Bit1, 1-aktiv)
	beq	.m009g	;inaktiv
	ori.w	#TIOCM_RTS,d0
.m009g:   
	move.l	d0,(a1)	;Bitsammlung	ablegen
	bra	.ok_ende


.m010:    
;TIOCCTLSET
;Setzen der I/O-Lines
	move.l	(a1),d0
	andi.w	#TIOCM_DTR,d0
	beq	.m010a
	move.l	4(a1),d0
	lea	.dtr_set,a2
	andi.w	#TIOCM_DTR,d0
	bne	.m010aa	;aktivieren
	lea	.dtr_reset,a2	;inaktivieren
.m010aa:  
	jsr	(a2)
.m010a:   
	bra	.ok_ende


;Bei .dtr_(re)set wird DTR nur bedient, falls in ioo_iol als
;I/O-Line	gesetzt

.dtr_reset:         
;FÅr TIOCCTLSET und	TIOC?BAUD
	btst.b	#1,3+ioo_iol+m2_iorec	;TIOCM_DTR = 2
	beq	.dtr_nox	;DTR ist kein I/O
	andi.b	#$7f,ioo_wr5+m2_iorec
	bra	.dtr_x

.dtr_set: 
;FÅr TIOCCTLSET und	TIOC?BAUD
	btst.b	#1,3+ioo_iol+m2_iorec	;TIOCM_DTR = 2
	beq	.dtr_nox	;DTR ist kein I/O
	ori.b	#$80,ioo_wr5+m2_iorec
.dtr_x:   
	move.w	sr,-(sp)
	ori.w	#$700,sr	;INTERRUPTSPERRE
	move.b	#5,esccB_ct
	move.b	ioo_wr5+m2_iorec,esccB_ct
	move.w	(sp)+,sr	;INTERRUPTS frei
.dtr_nox: 
	rts


.m011:    
;TIONOTSEND
;Anzahl der noch nicht gesendeten Byte ermitteln
	lea	esccB_ct,a0
	lea	m2_iorec,a2
	bsr	escc_tionotsend
	move.l	d0,(a1)	;Anzahl ungesendeter Byte
	bra	.ok_ende


.m012:    
;TIOCFLUSH
;verschiedene Arten	des Pufferlîschens
	lea	esccB_ct,a0
	lea	m2_iorec,a2
	bsr	escc_tiocflush
	bra	.ende




s2_fclose:          
	andi.w	#$00ff,a_lan_s2	;weder SERIAL2 noch LAN offen
	moveq.l	#0,d0	;OK
	rts


a_snd_set:          
;Setze entsprechend	a_lan_s2:
;Soundchipbit, falls Setzen erlaubt
;Maschinenbefehl im	Hardwarehandshakesendeinterrupt
;kill: A0,D0,D1,D2
	moveq.l	#1,d0	;nur Bit0
	and.w	a_lan_s2,d0
	move.w	d0,d2
	tst.w	en_lanbit
	beq	.no_sb	;PA7-Zugriff	verboten
	ror.b	#1,d0	;Bit0 -> Bit7
	moveq.l	#$7f,d1
	move.w	sr,-(sp)
	ori.w	#$700,sr
	move.b	#14,sndchp
	and.b	sndchp,d1
	or.b	d0,d1
	move.b	d1,2+sndchp
	move.w	(sp)+,sr
.no_sb:   
	tst.w	d2
	beq	.lan
;RTS dÅrfte schon aktiv sein, DTR wird ohnehin vom Userprogramm gesetzt
	move.b	#$67,i_A_MOD	;RS232: "beq"
	bsr	ca_flush
	bra	.end
.lan:     
;RTS sollte man aktivieren (Sender an), DTR auch
;### Falls spÑter mal DTR in den I/O-lines auftaucht solange er kein
;Hardwarehs ist, dann hier nur setzen wenn Hwhs
	move.b	#$66,i_A_MOD	;LAN: "bne"
	bsr	ca_flush
	ori.b	#$82,ioo_wr5+s2_iorec	;aktiviere DTR und RTS
	move.w	sr,d1
	ori.w	#$700,sr
	move.b	#5,esccA_ct
	move.b	ioo_wr5+s2_iorec,esccA_ct
	move.w	d1,sr
.end:     
	rts


s2_fopen:
	move.w	#$8001,d1	;Kennung "offen,SERIAL2"
	bra.s	lan_iopen

lan_fopen:
	move.w	#$8000,d1	;Kennung "offen,LAN"
lan_iopen:
	moveq.l	#EACCDN,d0	;Zugriff verweigern, falls
;der SCC-Kanal gerade entgegengesetzt offen ist
	tst.b	a_lan_s2
	beq	.ok		;hops: Kanal zu!
	cmp.b	1+a_lan_s2,d1	;offen, auf richtigem Kanal?
	bne	.end		;hops: falscher Kanal!
.ok:
	move.w	d1,a_lan_s2	;gewÅnschter Kanal jetzt offen
	bsr	a_snd_set		;evtl Interface umschalten
	tst.w	s2c_hog_conf	;Schwein sein?
	beq	.no_fd		; nein
	move.l	a0,d0
	beq	.no_fd		;DRVIN unterstÅtzt momentan keinen FD
	ori.w	#$0040,6(a0)	;aktiv das OM_NOCHECK-Bit setzen
;Dann wird jeder (folgende) Fopen an den Treiber weitergeleitet und der muû
;selbst entscheiden, ob er sich so îffnen lassen will oder nicht.
.no_fd:
	moveq.l	#0,d0	;OK
.end:     
	rts


m2_lseek: 
s2_lseek:	moveq.l	#0,d0	;Position 0 nach seek, immer bei Devices
	rts


m2_fopen:
	tst.w	m2c_hog_conf	;Schwein sein?
	beq	.no_fd		; nein
	move.l	a0,d0
	beq	.no_fd		;DRVIN unterstÅtzt momentan keinen FD
	ori.w	#$0040,6(a0)	;aktiv das OM_NOCHECK-Bit setzen
;Dann wird jeder (folgende) Fopen an den Treiber weitergeleitet und der muû
;selbst entscheiden, ob er sich so îffnen lassen will oder nicht.
.no_fd:
	moveq.l	#0,d0	;OK
	rts


m2_fclose:          
	moveq.l	#0,d0	;OK
	rts


m2_stat:  
s2_stat:	moveq.l	#1,d0	;beim Pollen	immer bereit
	tst.l	d1	;=0 bedeutet	Polling
	beq	.poll_ok
	moveq.l	#0,d0	;Meldung: kann nur Polling
.poll_ok: 
	move.l	a1,d1	;(kein tst.l	aX auf 68000)
	beq	.no_ptr
	move.l	d0,(a1)	;Returnwert auch in Struktur
.no_ptr:  
	rts


m2_delete:          
s2_delete:	moveq.l	#EINVFN,d0
;dadurch ist mein Device nicht lîschbar ####################
	rts


;Gemerktes Highword	des _MCH Maschinenkekses
my__mch:	DC.w 0
;Festlegung ob Soundchip PA7 beeinflussen (0 = nein)
en_lanbit:	DC.w 0
;merke ob	LAN (Bit0	=0), SERIAL2 (Bit0 =1) eingestellt
;merke in	Bit15..8 ob Kanal offen (!=0) oder nicht (=0)
a_lan_s2:	DC.w 1


;Initialisierungsfelder fÅr MODEM2 und SERIAL2
;mÅssen resident bleiben! (auch wenn	es in MagiC-Doku nicht	steht)
m2_iname:	DC.b "U:\DEV\MODEM2",0
	EVEN
m2_drvr:  
	DC.l m2_fopen,m2_fclose,m2_fread,m2_fwrite
	DC.l m2_stat,m2_lseek
	DC.l 0	;datime, darf Nullzeiger sein
	DC.l m2_fcntl,m2_delete	;(ioctl)
	DC.l 0,0,0	;getc, getline, putc, dÅrfen 0 sein

s2_iname:	DC.b "U:\DEV\SERIAL2",0
	EVEN
s2_drvr:  
	DC.l s2_fopen,s2_fclose,s2_fread,s2_fwrite
	DC.l s2_stat,s2_lseek
	DC.l 0	;datime, darf Nullzeiger sein
	DC.l s2_fcntl,s2_delete	;(ioctl)
	DC.l 0,0,0	;getc, getline, putc, dÅrfen 0 sein

;Initialisierungsfeld LAN, resident
;fast alles (bis auf fopen) identisch mit SERIAL2)
lan_iname:	DC.b "u:\dev\lan",0
	EVEN
lan_drvr: 
	DC.l lan_fopen,s2_fclose,s2_fread,s2_fwrite
	DC.l s2_stat,s2_lseek
	DC.l 0	;datime, darf Nullzeiger sein
	DC.l s2_fcntl,s2_delete	;(ioctl)
	DC.l 0,0,0	;getc, getline, putc, dÅrfen 0 sein


;----------------------------------------------------------------------

m2c_hog_conf:	dc.w 0	;<>0 fÅr MODEM2-Mehrfachîffnen erlaubt
s2c_hog_conf:	dc.w 0	;<>0 fÅr SERIAL2-Mehrfachîffnen erlaubt

;----------------------------------------------------------------------

;Datenstruktur des RSVF-Cookies
;Namen zu	den Objekten
	EVEN
	DC.l m2_drvr
m2_name:	DC.b 'MODEM2',0
	EVEN
	DC.l s2_drvr
s2_name:	DC.b 'SERIAL2',0
	EVEN
	DC.l lan_drvr
lan_name:	DC.b 'LAN',0
	EVEN

rsvflist: 
	DC.l m2_name	;MODEM2
	DC.b $e1,0
ini_m2_nr:	DC.b 7,0
ini_s2_np:          
	DC.l s2_name	;SERIAL2
	DC.b $e1,0
ini_s2_nr:	DC.b 8,0	;fÅr TT wird	hier 9 eingesetzt bei Inst.
ini_lan_np:         
	DC.l lan_name	;LAN
	DC.b $e1,0
ini_lan_nr:	DC.b 9,0	;wird geÑndert bei Inst.

	DC.l 0	;erstmal NIL-Zeiger, Ende der	Liste
	DC.b 0,0,0,0

;Adr. des	ersten nichtresidenten Byte, fÅr zus. Speichervergabe
first_unresi:	DC.l prg_ende	;Anfangswert

;----------------------------------------------------------------------
	DC.l 0
prg_ende:		;muû hinter dem Letzten resident zu haltenden stehen


su__mch:  
;Supervisorteil: _MCH-Cookie holen, PCLK ermitteln
	move.l	#'_MCH',-(sp)
	bsr	cookie_find
	addq.l	#4,sp
	tst.l	d0
	beq	.mch_no	;kein _MCH-Cookie
	movea.l	d0,a0
	move.w	4(a0),my__mch	;merke Highword des Maschinenkekses
.mch_no:  
	rts


su_pclk:  
;Supervisorteil: PCLK des SCC ermitteln
;Maximalzeitkonstante 65535 teilt PCLK durch 65537
;messe die Zeit fÅr	40 Bdgen-NulldurchgÑnge (anhand Interruptanmeldung)
;mit dem _hz_200-SoftwarezÑhler
;bei 8MHz	sollten es 65.5 und bei 14.7456MHz 35.5	sein, als	Grenze 50
;out:  D0	0 bei 8 MHz, <>0 bei 14,7456 MHz
	lea	esccA_ct,a0
	lea	su_e_pt,a1
	move.w	sr,d2
	ori.w	#$700,sr	;INTERRUPTSPERRE
	tst.b	(a0)	;Lesen fÅr def. Zustand
.ilp:     
	move.b	(a1)+,d0
	beq	.ile
	move.b	d0,(a0)
	move.b	(a1)+,(a0)
	bra	.ilp
.ile:     
	move.w	d2,sr	;INTERRUPTS FREI
;durch Programmierung erfÅllte Bedingung: nur Ext/Status bei Bdgen=0
;kann angemeldet werden
	moveq.l	#39,d1	;40 Zyklen Åber dbra
	move.l	_hz_200,d3	;Zeitpunkt merken
.clp:     
	move.w	sr,d2	;INTERRUPTSPERRE (sicherheitsfanatisch)
	ori.w	#$700,sr
	move.b	#3,(a0)
	move.b	(a0),d0
	move.w	d2,sr	;INTERRUPTS FREI
	andi.b	#$08,d0
	beq	.clp	;noch kein Int
	move.w	sr,d2	;INTERRUPTSPERRE (sicherheitsfanatisch)
	ori.w	#$700,sr
	move.b	#2,(a0)	;Intack ausfÅhren
	tst.b	(a0)
	move.w	d2,sr	;INTERRUPTS FREI
	move.b	#$10,(a0)	;Reset Ext/Status
	move.b	#$38,(a0)	;Reset Highest IUS
	dbra	d1,.clp	;40 mal
	move.l	_hz_200,d4	;aktuelle Zeit
	sub.l	d3,d4	;abgelaufene	Zeit in 1/200 s
	moveq.l	#0,d0
	cmpi.l	#50,d4
	scs	d0	;D0 != 0 bei	14745600 Hz
	rts
su_e_pt:  
;Tabelle mit Byte-Paaren fÅr esccA_ct zur PCLK-Messung
	DC.b 9,$c0	;Hardware-Reset (A und	B)
	DC.b 12,$ff,13,$ff	;Teiler Lowbyte, Highbyte
	DC.b 14,3	;Bdgen frei mit PCLK-Quelle
	DC.b 15,2	;Int bei Bdgen =0
	DC.b 1,1	;Ext/Status Int erlauben
	DC.b 9,$20	;Intack per Soft, aber	MIE gesperrt
	DC.b 0,0	;Ende
	EVEN


bgtab_14m:          
;Baudraten fÅr 14.7456MHz: alles wird von PCLK abgeleitet
	DC.w 22,46,94,126,190,228,254,382
	DC.w 766,1534
;herausgenommen:
;	    DC.w	2302,3070,3437  ;200Bd, 150Bd, 134Bd
;	    DC.w	4187,6142,9214  ;110Bd, 75Bd,	50Bd
;und eingesetzt:
	DC.w 0,2,6	;230400Bd, 115200Bd, 57600Bd
	DC.w 10,1,4	;38400Bd, 153600Bd, 76800Bd
;angehÑngte Klartextbaudraten
	DC.l 19200,9600,4800,3600
	DC.l 2400,2000,1800,1200
	DC.l 600,300
	DC.l 230400,115200,57600
	DC.l 38400,153600,76800
bgt_14me:		;hinter Ende


;Installationssubroutinen erzeugen
	usmc_gd_drv_del
	usmc_gd_drv_ins


su_rsvf:  
;Supervisorteil Cookie-Wuselei
	move.l	#'RSVF',-(sp)
	bsr	cookie_find
	addq.l	#4,sp
	move.l	d0,hilfs
	beq	.no	;RSVF fehlt
	movea.l	d0,a0	;(keine FlagÑnderung)
	movea.l	4(a0),a1	;Zeiger auf erstes RSVF-Objekt
;eigenes Listenende	(0) suchen, da evtl. geÑndert
	lea	rsvflist,a2
.search:  
	tst.l	(a2)
	beq	.found
	addq.l	#8,a2
	bra	.search
.found:   
	move.l	a1,(a2)	;hÑnge alte Obj. an mich (evtl NIL-ptr)
	move.l	#rsvflist,4(a0)	;und meine Adr. in Cookie
.no:      
	rts



starti:   
;Beginn der Installation
	pea	su__mch	;_MCH-Cookie	holen
	move.w	#$26,-(sp)
	trap	#14
	addq.l	#6,sp

	bsr	prints
	DC.b $1b,'p',' Fast routines for '
	IFNE FOR_ST_ESCC
	DC.b 'ST_ESCC'
	ELSE
	IFNE FOR_ESCC
	DC.b 'ESCC-M2/S2'
	ELSE
	DC.b 'SCC-M2/S2'
	ENDC
	ENDC
	DC.b ' ',$1b,'q',cr,lf
	DC.b '(C) SWB Harun Scheutzow 1997-11-01',cr,lf,0
	EVEN

          move.w	m2hog_conf,m2c_hog_conf
          move.w	s2hog_conf,s2c_hog_conf

	IFNE (0=FOR_ST_ESCC)
	move.w	my__mch,d7	;fÅr diesen "IFNE"-Block in D7

;Auf SERIAL2
; (MegaSTE/TT) eventuell DSR/RING-Umlage und DSR raus dafÅr
	tst.w	s2dri_conf
	beq	.s2eds	;SYNC als DSR, kein RING, wie Standard
	andi.l	#(~TIOCM_DSR),ioo_iol+s2_iorec	;SYNC = RING, kein DSR
	bra	.s2eri	;Konstante fÅr RING steht schon im Programm
.s2eds:   
	andi.l	#(~TIOCM_RNG),ioo_iol+s2_iorec	;SYNC = DSR, kein RING
	move.w	#TIOCM_DSR,2+MOCs2ri	;SYNC des	SCC als DSR
.s2eri:   

;Auf MODEM2
; den Falcon-RING-Eingang Ñndern falls nicht Falcon
; MegaSTE: eventuell DSR/RING-Umlage	und DSR raus, sonst RNG raus
	cmpi.w	#2,d7
	beq	.i_tt	;TT: Befehl Ñndern
	cmpi.w	#3,d7
	beq	.odsr	;Falcon: nur	1 Patch
	lea	MOCm2s0,a0
	moveq.l	#(MOCm2e0-MOCm2s0-2)>>1,d0
.nopc:    
	move.w	#$4e71,(a0)+	;"NOP"s bei MegaSTE z.B.
	dbra	d0,.nopc
	tst.w	m2dri_conf
	beq	.meds	;SYNC als DSR, kein RING
	andi.l	#(~TIOCM_DSR),ioo_iol+m2_iorec	;SYNC = RING, kein DSR
	bra	ini_m2re
.meds:    
	andi.l	#(~TIOCM_RNG),ioo_iol+m2_iorec	;SYNC = DSR, kein RING
	bra	.odsr
.pas:     
	btst.b	#3,mfp_tt	;dieser Befehl wird kopiert
.pae:     
.i_tt:    
	lea	.pas(pc),a0
	moveq.l	#.pae-.pas-1,d0
	lea	MOCm2s0,a1
.btc:     
	move.b	(a0)+,(a1)+
	dbra	d0,.btc
.odsr:    
	move.w	#TIOCM_DSR,2+MOCm2ri	;SYNC des	SCC als DSR
ini_m2re: 

;falls konfiguriert	fÅr MegaSTE/Falcon, auf MODEM2 auch 115200 und 57600
;erlauben	durch Patch
	tst.l	for_tt
	beq	ini_ntt	;kein TT
	bpl	ini_ytt	;TT
	cmpi.w	#2,d7	;for_tt negativ: Autodetect (aus	_MCH)
	beq	ini_ytt	;TT, TimerD-TTMFP an /RTxCB statt 3.672MHz
ini_ntt:  
	lea	m2_pt_bt,a0
	move.w	#$f400,(a0)+	;ein "Teilerwert"
	move.l	#$f800fc00,(a0)+	;beide "Teilerwerte"
	lea	m2_pt_bk,a0
	move.l	#230400,(a0)+
	move.l	#115200,(a0)+
	move.l	#57600,(a0)+
ini_ytt:  
	ENDC

	IFNE FOR_ESCC
;kopiere 4 Zeichen Interrupt Erlaubnis fÅr ESCC
	move.w	konf_4zi,enag_4zi
	ENDC

	move.w	lanbit_conf,en_lanbit	;LANBIT-Konf merken
;SERIAL2 ist Grundstellung
	tst.l	lan_s2_conf
	beq	.lan	;immer LAN
	bpl	.se2	;immer SERIAL2
;Autodetect auf Falcon, nur dort LAN
	cmpi.w	#3,my__mch
	bne	.se2	;kein Falcon
.lan:     
;neue Grundstellung	wird LAN
	clr.w	a_lan_s2	;Merkzelle
	pea	a_snd_set	;ist Supervisorroutine
	move.w	#$26,-(sp)
	trap	#14	;XBIOS Supexec
	addq.l	#6,sp
;und falls nur ein Eintrag im RSVF, wird der #8 bzw #9 auf LAN unbenannt
	tst.w	lanext_conf
	bne	.se2	;zwei EintrÑge
	move.l	#lan_name,ini_s2_np	;neuer Namenszeiger	im RSVF
.se2:     
	tst.w	lanext_conf
	bne	.zwei	;zwei EintrÑge
	lea	ini_lan_np,a0
	clr.l	(a0)+	;RSVF-Ende vor, zusÑtzliches Objekt killen
	clr.l	(a0)
;anhand 4+ini_lan_np (.l) erkennt die weitere Installation,	ob ein oder zwei
;EintrÑge	in Maptab	und GEMDOS
.zwei:    


;DTR-Signale von MODEM2 und SERIAL2 beeinflussen - Åber WR5-Schatten
;WR5 steht in IORECs mit DTR=aktiv, WR5 wird von rsconf bald gesetzt
	tst.w	dtrm2_conf
	bne	.dtrm2a
	andi.b	#$7f,ioo_wr5+m2_iorec	;DTR (Schatten) inaktivieren
.dtrm2a:	tst.w	dtrs2_conf
	bne	.dtrs2a
	andi.b	#$7f,ioo_wr5+s2_iorec
.dtrs2a:  

;Da der Code im eigentlichen Devicedriver modifiziert wurde:
	user_cache_flush


;1.) GEMDOS-Devices	lîschen, damit sich eventuell	vorhandene alte
;Treiber sauber lîschen kînnen.
	moveq.l	#0,d7	;Fehler wenn	am Ende <>0
	lea	m2_iname,a0	;MODEM2
	bsr	gd_drv_del
	or.l	d0,d7
	lea	s2_iname,a0	;SERIAL2
	bsr	gd_drv_del
	or.l	d0,d7
	pea	lan_iname	;LAN
	bsr	gd_drv_del
	or.l	d0,d7
	beq	.gd_ok

	bsr	prints
          DC.b "*** Error: Fdelete failed",bell,bell,cr,lf,0
	EVEN
	bra	.ins_xerr	;Fehler
.gd_ok:   


;2.) Die Hardware Åbernehmen und initialisieren.
	pea	su_pclk	;PCLK ermitteln
	move.w	#$26,-(sp)
	trap	#14
	addq.l	#6,sp

	tst.l	d0
	bne	.pclk14	;auf 14745600 Hz umschalten
	bsr	prints
	DC.b 'PCLK: 8 MHz',cr,lf,0
	EVEN
	bra	.pclk_e
.pclk14:  
	bsr	prints
	DC.b 'PCLK: 14745600 Hz',cr,lf,0
	EVEN
;Åberschreibe die beiden verschiedenen 8MHz-Tabellen mit den 14er Werten
	lea	bgtab_14m,a0
	lea	s2_bgtab,a1
	lea	m2_bgtab,a2
	lea	bgt_14me,a3	;Zeiger hinter Ende
.pclk_l:  
	move.w	(a0),(a1)+
	move.w	(a0)+,(a2)+
	cmpa.l	a3,a0
	bcs	.pclk_l
.pclk_e:  

	pea	init_escc	;eigentliche SCC-Initialisierung
	move.w	#38,-(sp)
	trap	#14	;XBIOS Supexec
	addq.l	#6,sp


;3.) GEMDOS-Treiber	eintragen.
;############ hier fehlen noch die Fehlerchecks!!!!!######
;sollte aber keine Dcntl-Fehler geben, oder?
	lea	m2_drvr,a0	;MODEM2
	lea	m2_iname,a1
	bsr	gd_drv_ins

	tst.l	4+ini_lan_np	;SERIAL2 und/oder LAN?
	bne	.ig_s2	;beide anmelden
	moveq.l	#1,d0	;nur einen anmelden, teste Voreinstellung
	and.w	a_lan_s2,d0
	beq	.ig_lan	;nur LAN
.ig_s2:   
	lea	s2_drvr,a0
	lea	s2_iname,a1	;SERIAL2
	bsr	gd_drv_ins
	tst.l	4+ini_lan_np
	beq	.ig_end	;nur einen anmelden
.ig_lan:  
	lea	lan_drvr,a0
	lea	lan_iname,a1	;LAN
	bsr	gd_drv_ins
.ig_end:  


;4.) Die Schnittstellen im BIOS/XBIOS eintragen.

;Bei ST_ESCC werden	die EintrÑge immer mit MAPT_APP hinzugefÅgt.
;Die zurÅckgegebenen BIOS-Nummern werden in RSVF eingesetzt.

;Bei Ataris, die mit SCC geliefert wurden, sind zwei EintrÑge mit
;MAPT_OVE	zu Åberschreiben. Es sind #7 und #8 bei	MegaSTE und Falcon,
;aber #7 und #9 beim TT. Wegen evtl TOS-Fehler besonders beim Falcon,
;wird nach erfolglosem MAPT_OVE Versuch noch MAPT_APP benutzt.

	IFNE (0=FOR_ST_ESCC)
	pea	init_mt_m2	;MODEM2 eintragen
	move.w	#7,-(sp)
	move.w	#MAPT_OVE,-(sp)
	move.w	#44,-(sp)
	trap	#14	;XBIOS Bconmap (erweit)
	lea	10(sp),sp
	tst.l	d0
	beq	.ib_fehler	;kein DRVIN
	bpl	.ib_m2ok	;kein "Kanal nicht da"-Fehler
	ENDC

	lea	init_mt_m2,a0	;MODEM2 eintragen
	bsr	bi_drv_app
	tst.l	d0
	ble	.ib_fehler	;kein DRVIN (=0) oder kein Platz	(<0)
	move.b	d0,ini_m2_nr
.ib_m2ok: 

	IFNE (0=FOR_ST_ESCC)
	pea	init_mt_s2	;SERIAL2 (oder LAN) eintragen
	move.w	#8,d0		;#8 beim MegaSTE, Falcon
	cmpi.w	#2,my__mch	;Atari TT?
	bne	.ib_no_tt		; nein
	move.w	#9,d0		;#9 beim TT
	move.b	d0,ini_s2_nr	;énderung im RSVF-Objekt
.ib_no_tt:          
	move.w	d0,-(sp)
	move.w	#MAPT_OVE,-(sp)
	move.w	#44,-(sp)
	trap	#14	;XBIOS Bconmap (erweit)
	lea	10(sp),sp
	tst.l	d0
	beq	.ib_fehler	;kein DRVIN oder kein #8 bzw. #9	da
	bpl	.ib_s2ok	;kein "Kanal nicht da"-Fehler
	ENDC

	lea	init_mt_s2,a0	;SERIAL2 (oder LAN) eintragen
	bsr	bi_drv_app
	tst.l	d0
	ble	.ib_fehler	;0 und negativ sind Fehler
	move.b	d0,ini_s2_nr
.ib_s2ok: 

;Der eventuelle zusÑtzliche LAN-Eintrag erfolgt immer mit MAPT_APP.
	tst.l	4+ini_lan_np	;0= kein extra Eintrag
	beq	.ib_ende
	lea	init_mt_s2,a0	;SERIAL2 nochmal als LAN eintragen
	bsr	bi_drv_app
	tst.l	d0
	ble	.ib_fehler	;kein DRVIN (=0), kein Platz mehr (<0)
	move.b	d0,ini_lan_nr	;BIOS-Kanalnummer in RSVF
	bra	.ib_ende

.ib_fehler:         
	bsr	prints
	DC.b "***	Error: Load DRVIN.PRG first!?",bell,bell,cr,lf,0
	EVEN
	bra	.ins_xerr	;Fehler

.ib_ende: 


;5.) Die Schnittstellen per RSVF bekannt machen.

	pea	su_rsvf	;RSVF-Listen ergÑnzen
	move.w	#38,-(sp)
	trap	#14	;XBIOS Supexec
	addq.l	#6,sp
	tst.l	hilfs
	bne	.rsvf_ok

	bsr	prints
          DC.b "*** Error: RSVF not found",bell,bell,cr,lf,0
	EVEN
	bra	.ins_xerr
.rsvf_ok: 


;eventuell MODEM1-Emulator einhÑngen
	lea	init_mt_s2,a0	;SERIAL2-BIOS
	move.l	m1emu_conf,d0
	cmpi.l	#2,d0		;2: MODEM1 -> SERIAL2
	beq	.yes_m1emu	; ja
	lea	init_mt_m2,a0	;MODEM2-BIOS
	tst.l	d0
	beq	.no_m1emu	;0: nie MODEM1-Emulator
	cmpi.l	#1,d0
	beq	.yes_m1emu	;1: immer MODEM1 -> MODEM2
;u (oder sonstiges): Autodetect auf Falcon, ob MODEM1 -> MODEM2
	cmpi.w	#3,my__mch
	bne	.no_m1emu	;kein Falcon, kein Emu
.yes_m1emu:         
	pea	(a0)	;andere BIOS-Routinen eintragen
	move.w	#6,-(sp)	; auf den Platz von MODEM1
	move.l	#($002c0000|(MAPT_OVE&$ffff)),-(sp)
	trap	#14	;XBIOS Bconmap (erweit)
	lea	10(sp),sp	;keine Fehlerauswertung
	move.l	#$002c0006,-(sp)	;fÅr etwas sauberere Soft
	trap	#14	; AUX auf #6	setzen, XBIOS Bconmap
	addq.l	#4,sp
.no_m1emu:          


	bsr	prints
	DC.b 'Installed.',cr,lf,0
	EVEN

.ins_xerr:          
;##################	ziemlich unintelligenter Aufschlagpunkt	fÅr alle
;mîglichen Fehler, bei denen abgebrochen wurde.
	bsr	prints
	DC.b cr,lf,0
	EVEN


;jetzt erfolgend keine Textausgaben mehr, da die Routine durch IOREC-
;Vergrîûerung zermatscht werden kînnte

;verschiebe die Routinen nach hinten, letztes Byte zuerst
	lea	start_moveable,a0
	lea	dest_move,a1
	move.l	#end_moveable-start_moveable-1,d0	;Anzahl Bytes
spacmove:	move.b	0(a0,d0.l),0(a1,d0.l)
	subq.l	#1,d0
	bpl	spacmove

;Cache muû ohnehin beachtet werden, da bei Init Code modifiziert
	user_cache_flush
	jmp	dest_move

;!!! Die verschobenen Routinen und Daten mÅssen in sich verschiebbar (relativ)
;und mit absoluten BezÅgen auf die auûerhalb "start_moveable".."end_moveable"
;liegenden Dinge sein.
;Sie werden nur am Label "dest_move" angesprungen.




;------------------------------------------

init_escc:          
;wird nur	einmal im	Supervisormode aufgerufen und	initialisiert ESCC-
;Hardware	und Interruptzeug.
;initialisiert Soundchip PA7 falls gewÅnscht
	tst.b	esccA_ct	;Lesen fÅr definierten	Zustand
	tst.b	esccB_ct
	move.b	#9,esccA_ct
	move.b	#$c0,esccA_ct	;ESCC-Hardware-Reset
;Rsconf initialisiert:
;Sendeint. Empfangsint. Empfangsfehlerint.
;und die Register (zumindest wenn man alle Parameter setzt)
;WR3, WR4, WR5, WR12, WR13, WR11, WR14(auûer Bit1	aus Schatten)

;initialisiere die beiden anderen Interruptvektoren
	move.l	#i_esccB_ext,$8+iva_esccB
	move.l	#i_esccA_ext,$8+iva_esccA

	move.b	#2,esccA_ct	;WR2: Interruptvektor auf $60
	move.b	#$60,esccA_ct

;WR7 an, Interrupt (nur) bei CTS-Flanken
	move.b	#15,esccA_ct	;WR15: Interruptsteuerung
	move.b	#$20,esccA_ct
	move.b	#15,esccB_ct	;WR15: Interruptsteuerung
	move.b	#$20,esccB_ct

;RxInt bei jedem Zeichen und Special, ParitÑtsfehler als SpecialCondition
;TxInt und Ext/StatusInt erlaubt
	move.b	#1,esccA_ct	;WR1: Interruptsteuerung, DMA
	move.b	#$17,esccA_ct
	move.b	#1,esccB_ct	;WR1: Interruptsteuerung, DMA
	move.b	#$17,esccB_ct

;KanÑle mit Rsconf Direktaufruf konfigurieren
	moveq.l	#$ff,d0
	move.l	d0,-(sp)	;scr,tsr
	move.w	d0,-(sp)	;rsr
	move.w	#$88,-(sp)	;ucr
	clr.l	-(sp)	;flowctl, speed
	bsr	m2_rsconf
	lea	12(sp),sp
	moveq.l	#$ff,d0
	move.l	d0,-(sp)	;scr,tsr
	move.w	d0,-(sp)	;rsr
	move.w	#$88,-(sp)	;ucr
	clr.l	-(sp)	;flowctl, speed
	bsr	s2_rsconf
	lea	12(sp),sp

;Interruptvektor mit Status in Bit3..1, Disable Lower Chain, IntAck durch
;Hardware, ESCC-Interrupts erlauben
	move.b	#9,esccA_ct	;WR9: nur einmal im ESCC
	move.b	#$0d,esccA_ct

	rts


;----------------------------------------------------------

bi_drv_app:         
;Ein Device ins BIOS per MATP_APP eintragen.
;in:   A0.L Zeiger auf Zeigerblock
;out:  D0.L Status und Kanalnummer
	move.l	a0,-(sp)
	move.w	#MAPT_APP,-(sp)
	move.w	#44,-(sp)
	trap	#14	;XBIOS Bconmap
	addq.l	#8,sp
	rts


;Initialwerte zum Kopieren in die MAPTAB, werden nur wÑhrend
;der Initialisierung gebraucht
init_mt_m2:         
;fÅr MODEM2 (#7)
	DC.l m2_bconstat,m2_bconin,m2_bcostat,m2_bconout
	DC.l m2_rsconf,m2_iorec
init_mt_s2:         
;fÅr SERIAL2 und LAN (#8 oder #9)
	DC.l s2_bconstat,s2_bconin,s2_bcostat,s2_bconout
	DC.l s2_rsconf,s2_iorec


;------------------------------------------
;Einige Routinen
	TEXT

	INCLUDE "PRINTS.S"	;Druckroutine

	INCLUDE "COOKIE.S"	;Cookie-Jar-Routinen


;------------------------------------------------------------------------

	EVEN
;Konfigurationszeug
magisch:	DC.b "hAruNs cONfigER",0	;Magischer String
	DC.l magisch	;Sicherheitszeiger

	IFNE FOR_ESCC
	DC.b "USE4C: Soll der Empfangsinterrupt erst nach 4 Zeichen erfolgen?",cr,lf
	DC.b "Solange Sie keine HÑngeeffekte mit unsauberer Software",cr,lf
	DC.b "feststellen, sagen Sie Ja.",cr,lf,0
	EVEN
	DC.w 0	;Cmd Entscheidung
konf_4zi:	DC.w -1	;4 Zeichen Interrupt: 0= immer aus
	ENDC

	IFNE (0=FOR_ST_ESCC)
	DC.b "M2TT: Benutzen Sie einen TT?",cr,lf
	DC.b "(TT hat normalerweise an MODEM2 keine 57600Bd/115200Bd)",cr,lf
	DC.b "0 = nein, 1 = ja, u	= Autodetect",cr,lf,0
	EVEN
	DC.w $101	;Cmd LONG-Liste, 1 StÅck
for_tt:	DC.l $80000000
	ENDC

	DC.b "M1EMU: BIOS-Routinen von MODEM1 durch MODEM2 ersetzen?",cr,lf
	DC.b "0 = nie, 1 = immer,	u = nur beim	Falcon (Autodetect)",cr,lf
	DC.b "2 = ersetze MODEM1 durch SERIAL2",cr,lf,0
	EVEN
	DC.w $0101	;Cmd LONG-Liste, 1 StÅck
m1emu_conf:	DC.l $80000000	;u fÅr nur beim Falcon

	DC.b "LANBIT: Soundchip-Bit PA7 beeinflussen?",cr,lf
	DC.b "(PA7 schaltet bei MegaSTE/TT zwischen SERIAL2 und LAN)",cr,lf,0
	EVEN
	DC.w 0	;Cmd Entscheidung
lanbit_conf:	DC.w 0	;0 fÅr nicht	beeinflussen

	DC.b "LANEXT: Sollen zwei	getrennte EintrÑge fÅr	SERIAL2 und LAN existieren?",cr,lf,0
	EVEN
	DC.w 0	;Cmd Entscheidung
lanext_conf:	DC.w 0	;0= nur ein Eintrag

	DC.b "LAN_S2: Voreinstellung LAN/SERIAL2",cr,lf
	DC.b "0 = LAN, 1 = SERIAL2, u = LAN nur beim Falcon (Autodetect)",cr,lf,0
	EVEN
	DC.w $101	;Cmd
lan_s2_conf:	DC.l $80000000

	DC.b "DTRM2: Einstellung des DTR-Signals von MODEM2 beim Treiberstart",cr,lf
	DC.b "Ja	  = aktiv (wie bei TOS)",cr,lf
	DC.b "Nein = inaktiv",cr,lf,0
	EVEN
	DC.w 0	;Cmd Entscheidung
dtrm2_conf:	DC.w -1	;-1 fÅr aktiv

	DC.b "DTRS2: Einstellung des DTR-Signals von SERIAL2 beim Treiberstart",cr,lf
	DC.b "Ja	  = aktiv (wie bei TOS)",cr,lf
	DC.b "Nein = inaktiv",cr,lf,0
	EVEN
	DC.w 0	;Cmd Entscheidung
dtrs2_conf:	DC.w -1	;-1 fÅr aktiv

	IFNE (0=FOR_ST_ESCC)

	DC.b "M2DRI: Bei MegaSTE-MODEM2 DSR-Signal als RING melden?",cr,lf
	DC.b "(erfordert Spezialkabel bzw. Modifikation)",cr,lf,0
	EVEN
	DC.w 0	;Cmd Entscheidung
m2dri_conf:	DC.w 0	;0 fÅr nein

	DC.b "S2DRI: Bei SERIAL2 DSR-Signal als RING melden?",cr,lf
	DC.b "(erfordert Spezialkabel bzw. Modifikation)",cr,lf,0
	EVEN
	DC.w 0	;Cmd Entscheidung
s2dri_conf:	DC.w 0	;0 fÅr nein

	ENDC

	dc.b "HOGM2: Mehrfaches MODEM2-ôffnen generell erlauben?",cr,lf
	dc.b "Ja   = wie unter TOS",cr,lf
	dc.b "Nein = Normalzustand unter MagiC",cr,lf,0
          DC.w 0   ;Cmd Entscheidung
m2hog_conf:	DC.w -1  ;ja

	dc.b "HOGS2: Mehrfaches SERIAL2/LAN-ôffnen generell erlauben?",cr,lf
	dc.b "Ja   = wie unter TOS",cr,lf
	dc.b "Nein = Normalzustand unter MagiC",cr,lf,0
          DC.w 0   ;Cmd Entscheidung
s2hog_conf:	DC.w -1  ;ja

	DC.b "RBLM2, TBLM2, RBLS2, TBLS2: Einstellung der Puffergrîûen in dieser",cr,lf
	DC.b "Reihenfolge: EmpfÑnger-MODEM2, Sender-MODEM2, EmpfÑnger-SERIAL2,",cr,lf
	DC.b "Sender-SERIAL2.",cr,lf
	DC.b "Standard: 256,  Minimum: 16,  Maximum: 65534",cr,lf,0
	EVEN
	DC.w $0104	;Cmd LONG-Liste, 4 StÅck
rblm2_conf:	DC.l 256
tblm2_conf:	DC.l 256
rbls2_conf:	DC.l 256
tbls2_conf:	DC.l 256

	DC.b 0	;Nullstring als Ende-Kennung

	EVEN


start_moveable:     
;zu verschiebende Routinen, nur absolute Referenzen auf auûerhalb Liegendes
;nur relative intern
	move.l	rblm2_conf,d0	;EmpfangspufferlÑnge
	move.l	tblm2_conf,d7	;SendepufferlÑnge
	move.l	rbls2_conf,d5
	move.l	tbls2_conf,d6
	lea	m2_iorec,a0	;Zeiger auf EmpfangsIOREC
	bsr	make_buf
	lea	ioo_tba+m2_iorec,a0	;Zeiger auf SendeIOREC
	move.l	d7,d0
	bsr	make_buf

	move.l	d5,d0
	lea	s2_iorec,a0	;Zeiger auf EmpfangsIOREC
	bsr	make_buf
	lea	ioo_tba+s2_iorec,a0	;Zeiger auf SendeIOREC
	move.l	d6,d0
	bsr	make_buf

	clr.w	-(sp)
	move.l	first_unresi,d0
	subi.l	#(start-$100),d0
	move.l	d0,-(sp)	;residente LÑnge
	move.w	#$31,-(sp)
	trap	#1	;GEMDOS Ptermres


	usmc_make_buf	;generate subroutine


end_moveable:       
;Ende des	zu verschiebenden Bereiches


	BSS
	EVEN
	DS.b 65536*4	;Sicherheitsabstand 4 max. Puffer
	EVEN
hilfs:	DS.l 1
dest_move:		;Ziel der Verschiebung
	DS.b end_moveable-start_moveable	;Platz

	DS.l $400	;Stack-Platz	nur fÅr Initialisierung



;History
;1997-11-01
;einzelne RSVF-Verkettungs- oder End-Objekte werden nicht mehr beseitigt
