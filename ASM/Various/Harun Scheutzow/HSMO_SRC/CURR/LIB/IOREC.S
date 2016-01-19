;Die Offsets im normalen IOREC-Teil:
;  der Empfangsteil:
ioo_rba   = 0       ;.l Receiver Buffer Address
ioo_rbl   = 4       ;.w Receiver Buffer Length
ioo_rrp   = 6       ;.w Receiver Read Pointer, auf zuletzt gelesenes
ioo_rwp   = 8       ;.w Receiver Write Pointer, zeigt auf zuletzt geschriebenes
ioo_rlw   = $a      ;.w Low Water Mark
ioo_rhw   = $c      ;.w High Water Mark
;  der identische Sendeteil:
ioo_tba   = $e+0    ;.l Transmitter Buffer Address
ioo_tbl   = $e+4    ;.w Transmitter Buffer Length
ioo_trp   = $e+6    ;.w Transmitter Read Pointer, auf zuletzt gelesenes
ioo_twp   = $e+8    ;.w Transmitter Write Pointer, zeigt auf zuletzt geschriebenes
ioo_tlw   = $e+$a   ;.w Low Water Mark, nie benutzt, sinnlos
ioo_thw   = $e+$c   ;.w High Water Mark, nie benutzt, sinnlos
;  die allgemeinen Zellen:
ioo_rsr   = $1c     ;.b MFP: Oder-Kopie des RSR (Fehlersammlung)
ioo_ucr   = $1c     ;.b SCC: Kopie des Rsconf-Parameters ucr (TOS-komatibel)
ioo_tsr   = $1d     ;.b MFP: MFP-Sender-leer-Flag (Medusa-Anpassung)
ioo_wr5   = $1d     ;.b SCC: Schatten fÅr SCC-Register WR5 (TOS-kompatibel)
ioo_acc   = $1d     ;.b ACIA: Schatten des Steuerregisters
ioo_re    = $1e     ;.b Receive Enabled, nur bei Handshakemodi:
;                       $00= EmpfÑnger aktiv, zuletzt RTS aktiviert / XON gesendet
;                       $FF= EmpfÑnger hat zuletzt RTS inaktiviert / XOFF gesendet
ioo_te    = $1f     ;.b Transmitter Enabled, nur bei Softwarehandshake:
;                       $00= Sender aktiv, zuletzt XON empfangen
;                       $FF= Sender gesperrt, zuletzt XOFF empfangen
ioo_hsm   = $20     ;.b Handshakemodus
;                       $00= kein Handshake, $01= XON/XOFF, $02= RTS/CTS
ioo_tci   = $21     ;.b Transmit Character immediately
;                       meist $00, nur kurz XON/XOFF, wenn das mit Vorrang gesendet werden soll
ioo_bd    = $22     ;.b aktuelle Baudrate so wie bei Rsconf Åbergeben
ioo_xx0   = $23     ;.b MFP: unbenutzt im TOS2.06
ioo_and   = $23     ;.b SCC: AND-Maske fÅr Empfangszeichen (TOS-kompatibel)
;Meine Erweiterungen:
ioo_ubd   = $24     ;.l aktuelle Klartextbaudrate
ioo_iol   = $28     ;.l Bitmaske IO-Lines (TIOCCTLMAP)
ioo_bci   = $2c     ;.l SCC: Adresse der Bconin-Routine
ioo_f2b   = $30     ;.l ESCC: Adresse der fifo2buf-Routine
ioo_wr4   = $34     ;.b SCC: Schatten fÅr SCC-Register WR4
ioo_wr14  = $35     ;.b SCC: Schatten fÅr SCC-Register WR14
;ab $36 ist ganz frei

;ioo_re ist immer noch schneller testbar als der Schatten von WR5 (RTS-bit)


