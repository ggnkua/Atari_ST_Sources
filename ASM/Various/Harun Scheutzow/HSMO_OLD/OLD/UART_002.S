;Neue BIOS- und GEMDOS- Routinen fÅr eine
;16550-UART-Schnittstelle
;### momentan Versuch fÅr Milan ###
;####### siehe momentan ##KKZZCTS

;Auf der Kommandozeile wird das Symbol XX_FOR_THIS definiert
;um die Hardware festzulegen.
;Auf der Kommandozeile wird der Name des Zielfiles vorgegeben.



;Generelle Einstellungen fÅr GEN-Assembler
	MACHINE	MC68000
	OPT	ATARI
	OPT	OW-,O1+,O2+,O3+,O4+,O5+,O8+,O9+
;folgendes wÅrde ein Warning je optimierbaren VorwÑrtssprung ergeben,
;der aber nicht optimiert wird, weil GEN es nicht kann.
;;;;;;	OPT	O6+,OW6+



;Das DRVIN*.PRG muû resident sein oder ein entsprechendes Mag!X>2.00 laufen.

;--------------------------------------------------------
;          INCDIR "E:\AHSMOD\CURR\LIB\"	;-I used on command line
          INCLUDE "MISC_DEF.S"
          INCLUDE "IOREC.S"
          INCLUDE "ERRNO.S"
	INCLUDE "SER_MACS.S"

;--------------------------------------------------------

;####### HACK
UA_BASIS	= $800002f8
UA_INTER	= 3

;UART register offsets
 IFNE 0
;lane-swapped Intel (byte adressing works as expected)
UA_RBR	= 0	;receiver buffer r., read only, DLAB =0
UA_THR	= 0	;transmitter holding r., write only, DLAB =0
UA_DLL	= 0	;divisor latch LSB, DLAB =1
UA_IER	= 1	;interrupt enable r., DLAB =0
UA_DLM	= 1	;divisor latch MSB, DLAB =1
UA_IIR	= 2	;interrupt identification r., read only
UA_FCR	= 2	;FIFO control r., write only
UA_LCR	= 3	;line control r.
UA_MCR	= 4	;modem control r.
UA_LSR	= 5	;line status r.
UA_MSR	= 6	;modem status r.
UA_SCR	= 7	;scratch r.
 ELSE
;adress-swapped Intel (XOR 16-bit-acc. with 2, XOR 8-bit-acc. with 3)
UA_RBR	= 3	;receiver buffer r., read only, DLAB =0
UA_THR	= 3	;transmitter holding r., write only, DLAB =0
UA_DLL	= 3	;divisor latch LSB, DLAB =1
UA_IER	= 2	;interrupt enable r., DLAB =0
UA_DLM	= 2	;divisor latch MSB, DLAB =1
UA_IIR	= 1	;interrupt identification r., read only
UA_FCR	= 1	;FIFO control r., write only
UA_LCR	= 0	;line control r.
UA_MCR	= 7	;modem control r.
UA_LSR	= 6	;line status r.
UA_MSR	= 5	;modem status r.
UA_SCR	= 4	;scratch r.
 ENDC


;additional data at negative IOREC offset (before IOREC)
eoo_adr	= -4	;base address of UART
;########

align32bit	MACRO
	CNOP	0,4	;32 bit alignment
	ENDM
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
;Level7-Interrupts keine anderen bearbeitet.

;68000 CPU:
;CLR.L Dx braucht 6 Takte, MOVEQ.L #0,Dx nur 4 Takte.
;auûerdem liest CLR zuerst den Operand, auch aus Speicher!



;Immer erst den MFP-Status lesen, wenn man ihn lesen will,
;dann das Byte lesen oder schreiben,
;sonst killt man beim Statuslesen schon den nÑchsten Interrupt.

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


 IFNE 0 ;####
mfp_rfs   MACRO
;Parameter: mfp_bas,ior_adr,sendeint
;Interrupt MFP-Empfangsregister voll fÅr XON/XOFF (SoftwareHS)
          movem.l   d0/d1/a1,-(sp)
          move.b    mfp_udr+\1,d0  ;Byte aus Empfangsregister
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
          move.b    d0,mfp_udr+\1  ;XOFF sofort senden
          clr.b     d0               ;lîschen, da schon gesendet
.\@trfull:          
          move.b    d0,ioo_tci+\2
.\@ende:  
          move.b    #$ef,mfp_isra+\1 ;anhÑngigen Interrupt lîschen
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
          move.b    #$ef,mfp_isra+\1 ;anhÑngigen Interrupt lîschen
          movem.l   (sp)+,d0/d1/a1
          bra       \3        ;Sprung zum Sendeinterrupt
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
          move.b    mfp_rsr+\1,d0  ;lesen ->
;lîscht OE-Fehlerstatus, bereitet Break-Lîschen vor,
;fÅr PE und FE wird nur die Interruptanmeldung befriedigt
          bmi.s     .ech             ;Empfangszeichen da
;kein Zeichen: PE und FE nicht auswerten, da alt
          andi.b    #$cf,d0
          bra.s     .nch
.ech:     
;Zeichen da: alle Bits gÅltig zum dazuodern und Zeichen lesen
          tst.b     mfp_udr+\1     ;defektes Z. wegwerfen
.nch:     
          or.b      d0,ioo_rsr+\2           ;aktive Bits sammeln
          move.b    #$f7,mfp_isra+\1 ;Interrupt lîschen
          move.w    (sp)+,d0
          rte       
          ENDM 



;Codeerzeugung fÅr die Interruptroutinen fÅr MODEM1 (MFP)

;MFP-Empfangsregister voll, Vektor auf iva_mfp_rbf
          IFNE FOR_STMFP|FOR_BASTEL|FOR_MILAN
i_mfp_rfh:          mfp_rfx          x_mfp,m1_iorec,1
          ENDC 
i_mfp_rfs:          mfp_rfs          x_mfp,m1_iorec,i_mfp_tes
i_mfp_rfo:          mfp_rfx          x_mfp,m1_iorec,0





;Fehlerinterrupts
i_mfp_ter:          mfp_ter          x_mfp,m1_iorec
i_mfp_rer:          mfp_rer          x_mfp,m1_iorec

          IFNE FOR_STMFP|FOR_BASTEL|FOR_MILAN
;Interrupt MFP-IO-Pin CTS Ñndert Pegel, Vektor auf $108 (iva_mfp_cts)
;Int. wirkt nur bei RTS/CTS-Handshake. Wird nur auf H/L-Flanke (die CTS
;wird aktiv Flanke) angesetzt. Ist das Senderegister leer
;und der Puffer nicht, so wird ein Byte gesendet.
i_mfp_cts:          
	bclr.b	#myCTSbit,mfp_aer+x_mfp	;nochmal auf H/L-Flanke ansetzen
          move.b    #$fb,mfp_isrb+x_mfp   ;anhÑngigen Interrupt lîschen
          btst      #1,ioo_hsm+m1_iorec           ;RTS/CTS-Handshake aktiv?
          beq.s     .ende            ;nein
;durch IPL6 sind schon alle Ints gesperrt
          bclr.b    #7,ioo_tsr+m1_iorec
          beq.s     .ende            ;Senderegister war nicht leer
          bra       i_mfp_teo        ;Senderegister leer, Sprung in Sendeint.
;Springe _nicht_ nach i_mfp_teh, weil der dortige CTS-Test "inaktiv"
;inzwischen feststellen kînnte und dann ioo_tsr.Bit7 falsch =0 wÑre!
.ende:
          rte       
          ENDC
 ENDC ;####



;UART-Interrupt, the only one entry point
i_uart:
	movem.l	a0/a3/d0-d1,-(sp)
	lea	UA_BASIS,a3	;##########
.irep:
	moveq.l	#7,d0		;only Bit2..0 (don't need Bit3)
	and.b	UA_IIR(a3),d0
	lsr.b	#1,d0		;
	bcs.s	.iend		;001 no interrupt pending
	beq	.imsi		;00 Modem Status interrupt pending
	subq.b	#2,d0
	beq	.irec		;10 Receive data available
	bcs	.itra		;01 Transmitter holding register empty
;11 Receiver Line Status i.p. (overrun-, parity-, framing-error or break)
;read LSR to clear int.
	move.b	UA_LSR(a3),d0	;just HACK ######
	bra.s	.irep
.iend:
	movem.l	(sp)+,a0/a3/d0-d1
	rte


.irec:
;Receive data available, read RBR to clear int.
;###
	movea.l	ioo_rba+m1_iorec(pc),a0	;buffer address
          moveq.l   #0,d1			;lîsche Bit31-16
          move.w	ioo_rwp+m1_iorec(pc),d1	;Schreibz holen
.rec_re0:
	move.b	UA_LSR(a3),d0		;
	lsr.b	#1,d0
	bcc	.rec_no		;no (more) chars available
.rec_re1:
;could use the receiver error conditions ########
	move.b	UA_RBR(a3),d0	;FIFO -> x
	addq.w	#1,d1			;Schreibz erhîhen (in 64K durch .w)
          cmp.w     ioo_rbl+m1_iorec(pc),d1       ;im Puffer umlaufen lassen
          bcs.s     .rec_nbe
          moveq     #0,d1
.rec_nbe:
          cmp.w     ioo_rrp+m1_iorec(pc),d1
          beq.s     .rec_re0		;Puffer voll, Byte wegwerfen
          move.b    d0,$0(a0,d1.l)	;x -> buffer

          move.w    d1,ioo_rwp+m1_iorec           ;Schreibz aktualisieren
	move.b	UA_LSR(a3),d0		;
	lsr.b	#1,d0
	bcs.s	.rec_re1			;more chars available
.rec_no:
;no more characters in receiver register
;the current writepointer is expected in D1.W
;if any handshake, take action on buffer reaching watermark
	move.b	ioo_hsm+m1_iorec(pc),d0	;handshake mode
	beq.s	.rec_end		;no handshake
;######### assume Handshake =RTS/CTS for tonight
;Anzahl belegter Byte berechnen
          sub.w     ioo_rrp+m1_iorec(pc),d1	;minus Lesezeiger
          bcc.s     .rec_nbi		;keine Korrektur
          add.w     ioo_rbl+m1_iorec(pc),d1	; sonst plus Puffergrîûe
.rec_nbi:
          cmp.w     ioo_rhw+m1_iorec(pc),d1       ;vergleiche mit High Water Mark
          bcs.s     .rec_end		;noch kein Hochwasser, hops (wohl angebrachter als BLT)
          tst.b     ioo_re+m1_iorec
          bne.s     .rec_end		;EmpfÑnger schon inaktiv
          st        ioo_re+m1_iorec	;EmpfÑnger sperren
	andi.b	#$fd,UA_MCR(a3)	;RTS inactive (bit1 =0)
.rec_end:
	bra	.irep


.imsi:
;Modem Status Interrupt (CTS, DSR, RI, DCD), read MSR to clear int.
	move.b	UA_MSR(a3),d0	;just HACK #####
;###
	bra	.irep


.itra:
;Transmitter holding register empty, int. already cleared by IIR read
;Int. occurs if FIFO completely empty
;
;Attention: 550-UARTs provide no way to check whether
;there is room in the transmission FIFO. LSR.Bit5 is already
;cleared if there is at least one character in the FIFO. LSR.Bit6
;is 1 if the transmitter is completely empty.
;This means you have to know and to count how much you write into
;the transmission FIFO.
;
;The handshake state is checked only once before filling the FIFO.
;
	moveq	#(16-1),d0	;####FIFO-size, for dbf
	move.b	ioo_hsm+m1_iorec(pc),d1
	subq.b	#1,d1			;what handshake?
	bcs.s	.tra_teo			; 0: none
	bne.s	.tra_teh			; 2: hardware (RTS/CTS)
; 1: software (XON/XOFF)
          move.b    ioo_tci+m1_iorec(pc),d1       ;wenn hier <>0, das sofort ungeachtet Sperre senden
          bne.s     .tra_xon
          tst.b     ioo_te+m1_iorec
          beq.s	.tra_teo		;transmission allowed
;the THR/FIFO is empty
	bne	.tra_lend		;transmission stopped (by XOFF)
.tra_xon:
          sf        ioo_tci+m1_iorec	;lîschen
          move.b    d1,UA_THR(a3)	;-> Senderegister
	subq.w	#1,d0		;1 character transfered to FIFO
          tst.b     ioo_te+m1_iorec
          beq.s	.tra_teo		;transmission allowed
;wrote 1 char into THR/FIFO
	bne	.tra_end		;transmission stopped (by XOFF)
.tra_teh:
;RTS/CTS-Handshake
;(hierher springt auch i_mfp_cts, wenn es senden will) ????
 IFNE 0 ;##KKZZCTS
          btst.b	#4,UA_MSR(a3)	;CTS active (allows transmit)?
	beq.s	.tra_lend		;leider darf ich nicht da CTS inaktiv
 ENDC
.tra_teo:
          moveq.l   #0,d1            ;lîsche vor allem Bit31-16, die mÅssen 0 bleiben!
          move.w    ioo_trp+m1_iorec(pc),d1       ;Lesezeiger
          cmp.w     ioo_twp+m1_iorec(pc),d1
          beq.s     .tra_lend		;Puffer leider leer
	movea.l	ioo_tba+m1_iorec(pc),a0	;buffer address
.tra_rep:
          addq.w    #1,d1		;erhîhen, durch .w automatisch auf 64KByte beschrÑnkt
          cmp.w     ioo_tbl+m1_iorec(pc),d1       ;im Puffer umlaufen lassen
          bcs.s	.tra_nbe
          moveq     #0,d1
.tra_nbe:
          move.b    0(a0,d1.l),UA_THR(a3)	;buffer -> transmitter
	cmp.w	ioo_twp+m1_iorec(pc),d1	;buffer empty?
	dbeq	d0,.tra_rep		; no and FIFO not full
          move.w    d1,ioo_trp+m1_iorec           ;update Lesez
.tra_end:
	bra	.irep
.tra_lend:
;Set ioo_tsr.Bit7 only if the THR/FIFO is completely empty, that means
;there will no THR-empty-int. follow.
	st	ioo_tsr+m1_iorec
          bra	.irep

;-----------------------------------------------------------------

;Die BIOS-Routinen bconout, bcostat, bconin, bconstat

;Benutzte Register: d0, d1, d2, a0, a1 (a2 nicht, obwohl erlaubt)
;Diese Register kînnen auch ohne vorherige Sicherung immer benutzt werden,
;auch wenn sie der BIOS-Dispatcher nicht gesichert hat.


;UART, bconout, Zeichenausgabe
;fÅr alle drei Fluûkontrollarten
;Aufruf auch bei anfang+4 mîglich, mit Parameter bei WORD (A0)
m1_bconout:
          lea       6(sp),a0         ;Mag!X-gleich, muû sein
          move.w    (a0),d0
          lea       m1_iorec,a0
          moveq     #0,d1            ;Bit31-16 muû 0 bleiben!
          move.w    ioo_twp(a0),d1   ;Schreibzeiger holen
          addq.w    #1,d1            ;erhîhen, auf 64KByte beschrÑnkt durch .w
          cmp.w     ioo_tbl(a0),d1	;im Puffer umlaufen lassen
          bcs.s     .conbx
          moveq     #0,d1
.conbx: movea.l   ioo_tba(a0),a1
          move.b    d0,0(a1,d1.l)    ;Byte -> Puffer
          move.w    d1,ioo_twp(a0)   ;Schreibzeiger aktualisieren
;Eintrittspunkt fÅr fwrite (= * damit es lokale Labels nicht unterbricht)
;A0 muû auf IOREC zeigen, D1.Bit31..16 =0 sein
sendeversuch	= *

.cobfu: move.w    sr,d0            ;damit kein Interrupt zwischendurch
          ori.w     #$700,sr         ; das Senderegister fÅllt
;########## wegen ioo_tsr-Nutzung anstelle MFP-Register braucht man doch
;keine Interruptsperre mehr, oder?
;dann darf die XON/XOFF-Empfangsroutine aber auch nur noch ioo_tsr nutzen
;und nicht mehr das MFP-Register selbst...######
;wegen XON- und CTS-Interrupts nachdenken!!!
          tst.b     ioo_tsr(a0)      ;MFP-Senderegister leer ?
          bpl.s     .condl         ;nicht leer
          cmpi.b    #1,ioo_hsm(a0)   ;leer, welcher Handshake ?
          bls.s     .conhh         ;nicht RTS/CTS
	movea.l	eoo_adr(a0),a1
 IFNE 0 ;##KKZZCTS
	btst.b	#4,UA_MSR(a1)	;teste CTS-Eingang
          beq.s	.condl		;leider CTS inaktiv
 ENDC
;kein Handshake, sofort senden
.coscd: 
;Wenn Senden erlaubt und Senderegister leer dann selbst senden.
          move.w    ioo_trp(a0),d1   ;Lesezeiger holen
          cmp.w     ioo_twp(a0),d1   ;gleich Schreibzeiger?
          beq.s     .coend         ;ja, ein Interrupt war schneller
          addq.w    #1,d1            ;erhîhen, auf 64KByte beschrÑnkt durch .w
          cmp.w     ioo_tbl(a0),d1   ;im Puffer umlaufen lassen
          bcs.s     .conbc
          moveq     #0,d1
.conbc: 
	movea.l   ioo_tba(a0),a1   ;Pufferadresse
	move.b	$0(a1,d1.l),d2	;buffer -> x
          move.w    d1,ioo_trp(a0)   ;Lesezeiger aktualisieren
	movea.l	eoo_adr(a0),a1
          sf        ioo_tsr(a0)      ;Senderegister (gleich) nicht mehr leer
          move.b	d2,UA_THR(a1)	;x -> transmitter
.coend:
	move.w	d0,sr
          rts                        ;Ende (1)

.conhh: bcs.s     .coscd         ;kein Handshake, sofort senden
.costh: tst.b     ioo_te(a0)	;XON/XOFF, teste ob Sender freigegeben
          beq.s     .coscd         ;Sender frei, Zeichen senden
.condl: move.w    d0,sr            ;Interrupts wieder frei
;Freigabe extrem wichtig, sonst lÑuft die Schleife komplett mit IPL 7.
;Anzahl noch freier PlÑtze im Puffer ermitteln
          move.w    ioo_trp(a0),d1	;Lesezeiger
          sub.w     ioo_twp(a0),d1	;minus Schreibzeiger
          bhi.s     .coxnx         ;keine Korrektur
          add.w     ioo_tbl(a0),d1   ;plus PufferlÑnge
.coxnx: subq.w    #1,d1            ;minus 1 statt cmp #1
          beq.s     .cobfu         ;voll, warten auf Leerung(smîglichkeit)
          rts                        ;Ende (2)


;UART, bconin, Zeicheneingabe
;FÅr alle drei Fluûkontrollarten
m1_bconin:
          lea	m1_iorec,a0
          moveq     #0,d1            ;Bit31-16 muû 0 bleiben!
          moveq     #0,d0		;beim Returncharacter Bit31-8 =0
          move.w    ioo_rrp(a0),d1	;Lesezeiger holen
.cibem:
	cmp.w     ioo_rwp(a0),d1	;Vergleich mit Schreibzeiger
          beq.s     .cibem		;Puffer leer, warten
          addq.w    #1,d1		;Lesezeiger +1 im Puffer umlaufend
          cmp.w     ioo_rbl(a0),d1
          bcs.s     .cinbt
          moveq     #0,d1
.cinbt:
	movea.l   (a0),a1		;Pufferadresse
          move.b    $0(a1,d1.l),d0	;Puffer -> Byte
          move.w    d1,ioo_rrp(a0)	;Lesezeiger aktualisieren
;Eintrittspunkt fÅr fread (= * damit es lokale Labels nicht unterbricht)
;A0 muû auf IOREC zeigen
act_in_hs	= *
          move.b	ioo_hsm(a0),d2	;Handshakemode holen
          beq.s     .ciend		;kein Handshake
;Wenn EmpfÑnger freigegeben, ist lange Wassermarkenrechnung unnîtig.
          tst.b     ioo_re(a0)
          beq.s     .ciend		;EmpfÑnger ist freigegeben
;Anzahl belegter Byte berechnen
          move.w    ioo_rwp(a0),d1	;Schreibzeiger
          sub.w     ioo_rrp(a0),d1	;minus Lesezeiger
          bcc.s     .cincd		;keine Korrektur
          add.w     ioo_rbl(a0),d1	;sonst LÑnge dazu
.cincd: cmp.w     ioo_rlw(a0),d1	;untere Wassermarke
          bhi.s     .ciend		;untere W. noch nicht unterschritten
          sf        ioo_re(a0)	;EmpfÑnger freigeben
          btst.l	#1,d2		;welcher Handshake?
          beq.s     .cish		;XON/XOFF (kein RTS/CTS)
	movea.l	eoo_adr(a0),a1
	ori.b	#$02,UA_MCR(a1)	;set RTS active (bit1 =1)
          rts			;Ende (1)
.cish:  
          move.w    sr,d2
          ori.w     #$0700,sr		;INTERRUPTSPERRE
          moveq.l   #xon,d1          ;XON bei XON/XOFF-Handshake
          bclr.b    #7,ioo_tsr(a0)
          beq.s     .citf          ;Senderegister voll, XON spÑter senden
	movea.l	eoo_adr(a0),a1
	move.b    d1,UA_THR(a1)	;XON sofort senden
          move.w    d2,sr            ;Interruptlevel wieder herstellen
          rts                        ;Ende (2)
.citf:  
          move.b    d1,ioo_tci(a0)	;XON vormerken
          move.w    d2,sr            ;Interruptlevel wieder herstellen
.ciend: rts                        ;Ende (3)



;create the remaining BIOS-routines
m1_bconstat:
	usm_bconstat	m1_iorec(pc)
	rts
m1_bcostat:
	usm_bcostat	m1_iorec(pc)
	rts




m1_rsconf:          
;Rsconf fÅr Modem1
;kill: D0-D2/A0/A1
	move.l	a3,-(sp)		;regsave
rsco_po	= 4	;extra stack offset
	lea	UA_BASIS,a3	;#######
          cmpi.w    #SETUSPEED,rsco_po+4(sp)
          bne.s     rsm1uno          ;nicht die erweiterte Funktion
          move.l    ioo_ubd+m1_iorec,d0	;aktuelle uspeed
          move.l    rsco_po+2+4(sp),d1	;Parameter uspeed
          bmi       rsm1ende		;nur abfragen
          move.l    d1,d0
          lea       m1baudtab,a1       ;Baudratentabelle
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
          cmpi.w    #$fffe,rsco_po+4(sp)	;Parameter speed
          bne.s     rsm1nob
          move.b    ioo_bd+m1_iorec,d0	;bei speed = -2 nur die eingestellte
          bra	rsm1ende		;Baudrate zurÅckgeben
rsm1nob:  
          move.w    sr,d1
          swap.w    d1               ;sichern, Highword nicht nutzen!
          ori.w     #$0700,sr        ;Interruptsperre

;build MFP ucr,rsr,tsr,udr-like return value in D0.L (Bit31..0 in this order)
	move.b	UA_LCR(a3),d1
	moveq.l	#$1d,d0		;important (start with D0.L >> (24+3))
	moveq.l	#3,d2		;convert bit/char
	and.b	d1,d2		;d2 will be used for stopbit too
	lsl.b	#2,d2
	eor.b	d2,d0
	btst.l	#2,d1		;convert number of stopbit
	beq.s	.rstop1
	tst.b	d2		;is 0 for 5 bit/char -> 1.5 stopbit
	seq	d2		;0 (2) or $ff (1.5)
	addq.b	#2,d2		;2 (for 2 stopbit) or 1 (for 1.5)
	lsl.b	#3,d2		;bit1..0 -> 1..0 (ucr.bit4..3)
	add.b	d2,d0		;D0.bit1..0 was (%2)01
.rstop1:
	lsr.b	#4,d1		;parity enable: LCR.bit3 -> X
	roxl.b	#1,d0		;  X -> ucr.bit2
	lsr.b	#1,d1		;parity even: LCR.bit4 -> X -> ucr.bit1
	moveq.l	#(2+24-12),d2
	roxl.l	d2,d0
	lsr.b	#2,d1		;UART LCR.bit6 (now D1.bit1) -> X
	moveq.l	#(8+4),d2		; X -> tsr.bit3 (final D0.bit11)
	roxl.l	d2,d0		;return value ready in D0.L

          move.w    rsco_po+4(sp),d1	;Parameter speed
          cmpi.w    #$000f,d1
          bhi.s     rsm1nosp         ;hops bei speed zu groû (bzw. negativ)
          move.w    d1,d2            ;Klartexttab mit LONGs
          lsl.w     #2,d2
          lea       m1baudtab,a1       ;Baudratentabelle
          move.l    0(a1,d2.w),ioo_ubd+m1_iorec       ;merke auch als Klartext
          bsr       rsm1_setbd       ;einstellen
rsm1nosp: 
          move.w    rsco_po+$8(sp),d1	;Parameter ucr
          bmi.s     rsm1fcu0         ;Sprung fÅr nicht Ñndern
;use only bit/char, stopbit and parity from ucr
;1.5 or 2 stopbit will be converted to 1.5 or 2 as bit/char allows.
;clear stick parity bit
	moveq.l	#$60,d2		;convert bit/char
	and.b	d1,d2
	lsl.b	#1,d2
	eori.b	#$c0,d2		;LCR.bit1..0 (now in bit7..6)
	lsl.b	#4,d1		;ucr.bit4 =1 means 1.5 or 2 stopbit
	roxr.b	#1,d2		;LCR.bit2 =1 means 1.5 or 2 stopbit (Bit7..5 filled)
	lsl.b	#2,d1		;convert parity: ucr.bit2 -> X
	roxr.b	#1,d2		;X (parity enable) -> LCR(.bit3)
	lsl.b	#1,d1		;ucr.bit1 -> X
	roxr.b	#4,d2		;X (parity even) -> LCR.bit4

	move.b	UA_LCR(a3),d1
	andi.b	#$c0,d1		;clear bit5..0, stick parity off
	or.b	d2,d1
	move.b	d1,UA_LCR(a3)
rsm1fcu0: 
;ignore MFP rsr parameter, present at rsco_po+$a(sp),d2
rsm1fcr0: 
          move.w    rsco_po+$c(sp),d2	;Parameter tsr
          bmi.s	rsm1fct0         ;Sprung fÅr nicht Ñndern
;use only bit3 (=1 break, =0 normal) as bit6 of LCR in UART
	move.b	UA_LCR(a3),d1
	roxl.b	#2,d1		;bit6 -> X-flag (throw away)
	lsr.b	#4,d2		;bit3 -> X-flag
	roxr.b	#2,d1
	move.b	d1,UA_LCR(a3)
rsm1fct0: 
;ignore MFP scr parameter, present at rsco_po+$e(sp)
rsm1fcs0: 

          move.w    rsco_po+6(sp),d2         ;Parameter flowctl
          cmpi.w    #3,d2
          bhi       rsm1fcbi         ;flowctl ist zu groû
          bne.s     rsm1fcnb         ;flowctl nicht XON/XOFF & RTS/CTS
          moveq.l   #1,d2            ;"beides" Ñndere auf XON/XOFF
rsm1fcnb: 
          cmp.b     ioo_hsm+m1_iorec,d2  ;vergleiche mit altem
          beq       rsm1nosh         ;neues = altes, keine Sonderaktion, aber
; Int.vekt. setzen und Int.s freigeben
;Das bedeutet, die erste RTS-Aktivierung nach Reset muû ein anderer machen.
          move.b    d2,ioo_hsm+m1_iorec  ;flowctl speichern (noch in d2 gebraucht)

          clr.w     ioo_re+m1_iorec     ;EmpfÑnger und Sender (ioo_te) freigeben
;Wenn der Empfangspuffer voll ist, gehen evtl. gleich nach dieser
;Umschaltung ein paar Zeichen verloren. Das ist aber TOS-kompatibel.
;Ansonsten muû man umstÑndlich prÅfen, ob der EmpfÑnger freigegeben werden
;darf.

	ori.b	#$02,UA_MCR(a3)	;RTS aktiv (TTL-Low) schalten

          cmpi.b    #1,d2            ;welcher Handshake?
          bne.s     rsm1nosh         ;kein XON/XOFF
;Bei XON/XOFF-HS ein XON senden, und zwar mit den neuen
;Einstellungen, deshalb erst hier. Hinweis: hier ist IPL7
          bclr.b    #7,ioo_tsr+m1_iorec           ;MFP-Senderegister leer ?
          beq.s     rsm1tbne         ;nicht leer
;####          move.b    #xon,mfp_udr+x_mfp   ;XON -> Senderegister
          bra.s     rsm1nosh
rsm1tbne: 
          move.b    #xon,ioo_tci+m1_iorec         ;XON vormerken
rsm1nosh: 
          lsl.w     #3,d2            ;Handshakemode * 8, je 2 longs
          lea       rsm1tiad,a0
 IFNE 0 ;####
          move.l    0(a0,d2.w),iva_x_mfp_tbe      ;Sendepuffer leer Int.
          move.l    4(a0,d2.w),iva_x_mfp_rbf      ;Empfangspuffer voll Int.
          move.l    #i_mfp_ter,iva_x_mfp_ter      ;Fehlerint.vek. setzen
          move.l    #i_mfp_rer,iva_x_mfp_rer
          IFNE FOR_STMFP|FOR_BASTEL|FOR_MILAN
          move.l    #i_mfp_cts,iva_x_mfp_cts	;CTS-Int.vek. setzen
          bclr.b    #myCTSbit,mfp_aer+x_mfp	;CTS-Int. bei High-Low-Flanke (->aktiv)
          ori.b     #$4,mfp_ierb+x_mfp      ;CTS-Int. in IERx und IMRx freigeben
          ori.b     #$4,mfp_imrb+x_mfp
          ENDC 
;die MFP-Interrupts freigeben (auch wenn es zum 100. Mal ist)
          ori.b     #$1e,mfp_iera+x_mfp     ;Sende-, Sendefehler-, Empfangs-,
          ori.b     #$1e,mfp_imra+x_mfp   ;Empf.fehler- Int. in IERx und IMRx freigeben
 ENDC ;####
	move.b	#$0f,UA_IER(a3)	;enable all UART interrupts
;#######
	move.b	#$81,UA_FCR(a3)	;enable FIFOs, receiver trigger at 8
rsm1fcbi: 
;RÅckgabewert in d0: ucr,rsr,tsr,udr in Bit31-0
          swap.w    d1
          move.w    d1,sr            ;alte Interruptmaske
rsm1ende: 
	movea.l	(sp)+,a3		;regrestore
          rts


rsm1_suchbaud:      
;aufgerufen durch m1_rsconf
;in:   D0.l: zu suchende Klartext-Baudrate
;      A1:   Zeiger auf Baudratentabelle (Klartexttab.)
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
          cmp.l     0(a1,d1.w),d5           ;suche nebenbei kleinste
          bls.s     .nogsm           ; Baudrate der ganzen Tabelle
          move.l    0(a1,d1.w),d5           ;in D5.l
.nogsm:   
          sub.l     0(a1,d1.w),d2           ;ermittle Differenz
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
          move.l    0(a1,d4.w),d0           ; ja, nÑchstniedrigere Bdrate
          move.w    d4,d1            ;Indexwert dazu
.lowest:  
          bset.l    #31,d0
.ende:    
          lsr.w     #2,d1            ;ermittle aus Index die Rsconf-Nummer
          movem.l   (sp)+,d2-d5
          rts       


rsm1_setbd:         
;set bps-rate in UART
;in:   D1.w valid Rsconf-index
;out:  /
;kill: D2.w
	move.l	a0,-(sp)		;regsave
	lea	UA_BASIS,a0
          move.b    d1,ioo_bd+m1_iorec  ;Parameter speed speichern
;disable and re-enable receiver and transmitter?####
	add.w	d1,d1
	move.w	rsm1divi(pc,d1.w),d1
	move.w	sr,-(sp)
	ori.w	#$700,sr		;INTERRUPTSPERRE
	nop
	ori.b	#$80,UA_LCR(a0)	;set DLAB =1
	move.b	d1,UA_DLL(a0)
	lsr.w	#8,d1
	move.b	d1,UA_DLM(a0)
	andi.b	#$7f,UA_LCR(a0)	;DLAB =0
	nop
	move.w	(sp)+,sr		;INTERRUPTS FREI
	movea.l	(sp)+,a0		;regrestore
          rts


;BaudratenÅbersetzungstabelle:
rsm1divi:
;16-bit-value for divider
	dc.w 6,12,24,32
	dc.w 48,58,64,96
	dc.w 192,384,576,768
	dc.w 856,1047,1536,2304

m1baudtab:                           ;die angehÑngte Klartexttabelle
          DC.l 19200,9600,4800,3600
          DC.l 2400,2000,1800,1200
          DC.l 600,300,200,150
          DC.l 134,110,75,50


;Interruptroutinenadresstabelle (Send/Empf fÅr OHNE, XON/XOFF, RTS/CTS)
rsm1tiad: ;#####DC.l i_mfp_teo,i_mfp_rfo
          ;#####DC.l i_mfp_tes,i_mfp_rfs
          ;#####DC.l i_mfp_teh,i_mfp_rfh

	align32bit
	
;extension to negative IOREC-offsets:
	DC.l UA_BASIS
;IOREC
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


m1_fclose:
	moveq.l	#0,d0		;OK
          rts       

m1_stat:
;##### ist das eigentlich richtig so? hat jedenfalls noch nicht
;gestîrt
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
wgna_1:   DC.b "MODEM2",0,0,0,0,0,0,0,0
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
;in:   A0: Zeiger auf Filedeskriptor (MagiC) oder 0 (TOS), nicht genutzt
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
;in:   A0: Zeiger auf Filedeskriptor (MagiC) oder 0 (TOS), nicht genutzt
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
;in:   A0: Zeiger auf Filedeskriptor (MagiC) oder 0 (TOS), nicht genutzt
;      A1: LONG argument (meist ein Zeiger)
;      D0: WORD command
;out:  D0: Fehlercode
;kill: D0-D2/A0-A2
	move.l	a3,-(sp)		;regsave
	lea	UA_BASIS,a3	;####
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
	movea.l	(sp)+,a3		;regrestore
          rts       

.m000:    
;FIONREAD
;Anzahl der ohne Warten lesbaren Byte auf der Adresse hinterlassen
          moveq.l   #0,d1
          move.w    ioo_rwp+m1_iorec,d1   ;Schreibz
          sub.w     ioo_rrp+m1_iorec,d1   ;Lesez
          bcc       .m000a
          add.w     ioo_rbl+m1_iorec,d1
.m000a:   move.l    d1,(a1)          ;Anzahl belegter PlÑtze = vorhandene Byte
          bra       .ok_ende

.m001:    
;FIONWRITE:
;Anzahl der ohne Warten schreibbaren Byte auf der Adresse hinterlassen
          moveq.l   #0,d1
          move.w    ioo_trp+m1_iorec,d1             ;Lesez
          sub.w     ioo_twp+m1_iorec,d1             ;Schreibz
          bhi       .m001a
          add.w     ioo_tbl+m1_iorec,d1
.m001a:   subq.l    #2,d1
          bpl       .m001b
          moveq.l   #0,d1            ;nur zur Sicherheit, dÅrfte nie - werden
.m001b:   move.l    d1,(a1)          ;Anzahl freier PlÑtze
          bra       .ok_ende

.m002:    
;TIOCCBRK
;Break inaktivieren
	andi.b	#$bf,UA_LCR(a3)	;bit6 =0, no break
          bra       .ok_ende

.m003:    
;TIOCSBRK
;Break aktivieren
	ori.b	#$40,UA_LCR(a3)	;bit6 =1, break
          bra       .ok_ende
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
	andi.b	#$fe,UA_MCR(a3)	;DTR inactiv (bit0 =0)
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
	ori.b	#$01,UA_MCR(a3)	;DTR active (bit0 =1)
          bra       .ok_ende


.m006:    
;TIOCGFLAGS
;Lesen der öbertragungsprotokollparameter
;da Rsconf den Handshakemodus nicht liefert, wird alles direkt zugegriffen
	moveq.l	#$d,d1		;important init value
	move.b	UA_LCR(a3),d0
          btst.l    #3,d0
          beq.s	.m006np          ;no parity
          bset.l    #15,d1           ;set odd
          btst.l    #4,d0
          beq.s	.m006np          ;really odd parity
	eori.w	#$c000,d1		;clear odd, set even parity flag
.m006np:
	moveq.l	#3,d2		;0,1,2,3 for 5,6,7,8 bit/char
	and.b	d0,d2		;in UART -> c,8,4,0 in SERSOFST.TXT
	lsl.b	#2,d2
	eor.b	d2,d1		;D2 will be used again for stopbits
	btst.l	#2,d0		;bit2 =0 in UART -> 1 stopbit
	beq.s	.m006s1
	tst.b	d2		;is 0 for 5 bit/char -> 1.5 stopbit
	seq	d2		;0 (2) or $ff (1.5)
	addq.b	#2,d2		;2 (for 2 stopbit) or 1 (for 1.5)
	add.b	d2,d1		;D1.bit1..0 was (%2)01
.m006s1:
          moveq.l   #3,d0            ;mask
          and.b     ioo_hsm+m1_iorec,d0  ;get direct: handshake mode
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
;#### extend check: 1 stopbit always possible, 1.5 only for 5 bit/char
;2 only for 6,7,8 bit/char
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
;Direktaufruf wegen gleicher Registerkillkonvention mîglich
          bsr       m1_rsconf
          moveq.l   #0,d0            ;OK
.m007er:  
          lea       12(sp),sp
          bra       .ende


.m008:    
;TIOCCTLMAP
;Erfrage I/O-Lines and Signals
          move.l    #(TIOCM_DTR|TIOCM_RTS|TIOCM_CAR|TIOCM_RNG|TIOCM_CTS|TIOCM_DSR|TIOCM_BRK|TIOCM_RER),(a1)+
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
;inputs
	move.b	UA_MSR(a3),d1
          btst.l	#7,d1		;DCD, 1-active
          beq.s	.m009a
          ori.w     #TIOCM_CAR,d0
.m009a:
          btst.l	#4,d1		;CTS, 1-active
          beq.s	.m009b
          ori.w     #TIOCM_CTS,d0
.m009b:
          btst.l	#6,d1		;RING, 1-active
          beq.s	.m009c
          ori.w     #TIOCM_RNG,d0
.m009c:   
	btst.l	#5,d1		;DSR, 1-active
	beq.s	.m009c1
          ori.w     #TIOCM_DSR,d0
.m009c1:
;outputs
	move.b	UA_MCR(a3),d1
          btst.l	#1,d1		;RTS, 1-active
          beq.s	.m009d
          ori.w     #TIOCM_RTS,d0
.m009d:
          btst.l	#0,d1		;DTR, 1-active
          beq.s	.m009e
          ori.w     #TIOCM_DTR,d0
.m009e:
;"Fehlerbits" dÅrfen nur zurÅckgesetzt werden, wenn sie erfragt wurden
;(also nicht beim freiwilligen ungefragten Mitliefern)
;#### still MFP stuff ####
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
	btst.l	#BITNR_TIOCM_DTR,d3
          beq       .m010a
          btst.l    #BITNR_TIOCM_DTR,d4
          bne       .m010aa		;aktivieren
          andi.b	#$fe,UA_MCR(a3)	;DTR inactive (bit0 =0)
          bra	.m010a
.m010aa:
	ori.b	#$01,UA_MCR(a3)	;DTR active (bit0 =1)
.m010a:   
	btst.l	#BITNR_TIOCM_RTS,d3
          beq       .m010b
          btst.l    #BITNR_TIOCM_RTS,d4
          bne       .m010ba		;aktivieren
          andi.b	#$fd,UA_MCR(a3)	;RTS inactive (bit1 =0)
          bra	.m010b
.m010ba:
	ori.b	#$02,UA_MCR(a3)	;RTS active (bit1 =1)
.m010b:
	movem.l	(sp)+,d3/d4
          bra       .ok_ende


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
	btst.b	#6,UA_LSR(a3)	;bit6 =1 means transmitter empty
	beq.s	.ns1		;no character in UART
          addq.l    #1,d0		;(at least) 1 char in UART
.ns1:     
          rts       

;----------------------------------------------------------------------

c_hog_conf:	dc.w 0	;<>0 fÅr Mehrfachîffnen erlaubt

;----------------------------------------------------------------------

;Datenstruktur des RSVF-Cookies
          EVEN 
          DC.l m1_drvr              ;Zeiger auf Routinentabelle
m1_name:
wgna_0:
          DC.b 'MODEM2',0,0,0,0,0,0,0,0	;Name zum Objekt

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






sum1ini:  
;Supervisorteil MODEM1-Ini

          move.l    #$0085ffff,-(sp) ;scr nicht Ñndern, tsr =$85(Sender an, kein Break)
          move.l    #$008a0001,-(sp) ;ucr =$8A(8N1, no parity), rsr =$01
          move.l    #$00000000,-(sp) ;kein Handshake, 19200Bd
          bsr       m1_rsconf        ;Direktaufruf
;initialisiert MFP und Int.zeug selbst, bis auf RTS-Line
          lea       12(sp),sp

          IFNE 0 ;#######FOR_STMFP|FOR_BASTEL|FOR_MILAN
          move.w    sr,d2
          ori.w     #$700,sr         ;INTERRUPTSPERRE
          move.b    mfp_gpdr+x_mfp,d1
          andi.b    #myRTSm0,d1	;RTS aktiv (TTL-Low)
;DTR-Beeinflussung
          ori.b     #myDTRm1,d1	;DTR inaktiv (TTL-High)
          tst.w     dtr_conf         ;wie setzen?
          beq       .dtr_set
          andi.b    #myDTRm0,d1	;DTR aktiv (TTL-Low)
.dtr_set: 
          move.b    d1,mfp_gpdr+x_mfp
          move.w    d2,sr            ;Interrupts frei
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



;Installation
starti:   
          bsr       prints
          DC.b $1b,'p',' Routines for '
	dc.b 'Milan'
          DC.b ' 16550 UART ## under development ',$1b,'q',cr,lf
          DC.b '(C) Harun Scheutzow 1998-12-24',cr,lf,0
          EVEN 

;kopiere GEMDOS-Namen aus Konfig an zwei Stellen
          lea       cfg_gnam(pc),a0
          lea       wgna_0(pc),a1
          lea       wgna_1(pc),a2
.cop_gn:	move.b    (a0)+,d0
          move.b    d0,(a1)+
          move.b    d0,(a2)+
          bne       .cop_gn

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
 IFNE 0 ;#######
          pea       sum1test         ;Test auf Speeder am MFP
          move.w    #38,-(sp)
          trap      #14              ;XBIOS Supexec
          addq.l    #6,sp
          move.l    d0,d7            ;Wert in D7 sichern
 ENDC ;######

;may replace 110/134/150 by 38400/57600/115200
          move.w    cfg_hisp,d0      ;change rates?
          beq	.no_hibd         ; no
          lea       (11*4)+m1baudtab,a0
          move.l    #115200,(a0)+    ;cleartext rates
          move.l    #57600,(a0)+
          move.l    #38400,(a0)+
	lea	(11*2)+rsm1divi,a0	;dividers
	move.w	#1,(a0)+
	move.w	#2,(a0)+
	move.w	#3,(a0)+
.no_hibd:

;lege eventuell Baudraten um
;darf erst nach der Speeder-abhÑngigen Modifikation der Tabelle
;erfolgen, deshalb hier.
          move.w    #2,d6            ;max. 3 Raten umlegen
          lea       cfg_bdr,a5
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
          lea       rsm1divi,a2
          lsl.l	#1,d1
          move.w    0(a2,d1.l),d7    ;Teiler
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
          lea       rsm1divi,a2
          lsl.w	#1,d1
          move.b    d0,0(a2,d1.w)    ;Teiler
          addq.w    #1,d6            ;quasi umgedrehte dbra-Schleife
          bra       .um_el
.um_ee:   

 IFNE 0 ;####
          pea       sum1ini          ;fÅr Rsconf direkt
          move.w    #38,-(sp)
          trap      #14              ;XBIOS Supexec
          addq.l    #6,sp
 ENDC ;#####

;install interrupt handler
	pea	i_uart(pc)
	move.w	#UA_INTER,d0
	addi.w	#($140/4),d0
	move.w	d0,-(sp)
	move.w	#5,-(sp)
	trap	#13		;BIOS Setexc
	addq.l	#8,sp


;3.) GEMDOS-Treiber eintragen.
;############ hier fehlen noch die Fehlerchecks!!!!!######
;sollte aber keine Dcntl-Fehler geben, oder?
          lea       m1_drvr,a0       ;Datenblock
          lea       m1_iname,a1      ;Name
          bsr       gd_drv_ins


;4.) Die Schnittstellen im BIOS/XBIOS eintragen.
          pea       m1_routtab       ;Routinenzeigerblock
          move.w	cfg_binr,d0	;overwrite Maptab at given position?
          bne	.maov		; yes
          move.w    #MAPT_APP,-(sp)	; no, append (use free space)
          move.w    #44,-(sp)
          trap      #14              ;XBIOS Bconmap (ext: MAPT_APP)
          addq.l    #8,sp
	bra	.maen
.maov:
          move.w    d0,-(sp)		;channel number
          move.w    #MAPT_OVE,-(sp)
          move.w    #44,-(sp)
          trap      #14              ;XBIOS Bconmap (ext: MAPT_OVE)
          lea       10(sp),sp
.maen:
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

;Konfigurationszeug
          EVEN     ;wichtig!!!
magisch:  DC.b "hAruNs cONfigER",0  ;Magischer String
          DC.l magisch              ;Sicherheitszeiger
          DC.b "BIOS-Nummer (ab 7), oder 0 fÅr freien Platz suchen:",cr,lf,0
          EVEN 
          DC.w $0101	;Cmd LONG-Liste, 1
cfg_binr: DC.l 0	;0: look for a free BIOS entry

          DC.b "GNAME: GEMDOS-Name des Treibers (max. 12 Zeichen),",cr,lf
          DC.b "z.B. MODEM2",cr,lf,0
          EVEN 
          DC.w $020e                ;C-String insgesamt 14 Zeichen
cfg_gnam:	DC.b "MODEM2",0,0,0,0,0,0,0,0

          DC.b "HISP: 38400/57600/115200 bps anstelle 110/134/150? (J/N)",cr,lf,0
          EVEN 
          DC.w 0   ;Cmd Entscheidung
cfg_hisp: DC.w -1  ;-1 fÅr ja

          DC.b "REPL: Falls Sie fÅr ein altes Programm die Rsconf-Baudraten",cr,lf
          DC.b "umbelegen wollen, so geben Sie jeweils zuerst die alte,",cr,lf
          DC.b "dann die neue Rate ein. 3 Umbelegungen sind mîglich.",cr,lf,0
          EVEN 
          DC.w $0106                ;Cmd LONG-Liste, 6 StÅck
cfg_bdr:  DC.l $80000000,$80000000
          DC.l $80000000,$80000000
          DC.l $80000000,$80000000

          DC.b "DTR: Einstellung des DTR-Signals beim Treiberstart",cr,lf
          DC.b "Ja   = aktiv (wie bei TOS)",cr,lf
          DC.b "Nein = inaktiv",cr,lf,0
          EVEN 
          DC.w 0   ;Cmd Entscheidung
dtr_conf: DC.w -1  ;-1 fÅr aktiv

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
;1998-08-26 i_mfp_cts springt nun nach i_mfp_teo anstelle i_mfp_teh, das
;beseitigt potentielle Sender-Blockiermîglichkeit
;1998-08-09 cleanup
;1998-08-08 FOR_BASTEL MFP-DDR and VR is now set before rsconf is
;called directly (and not after, which is too late for VR), RSVE-cookie
;no longer installed by default
;1998-08-07 symbolic MFP register offsets, movep replaced, Milan-
;adaption started
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
