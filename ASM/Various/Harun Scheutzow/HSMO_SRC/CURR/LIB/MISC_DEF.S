;Alle mîglichen Definitionen fÅr die seriellen Treiber
;Sollte man endlich mal ordnen!

	IFNE 1	;1= Original Atari
mfp       = $fffffa01                ;Adresse des ST-MFP
mfp_tt    = $fffffa81                ;Adresse des TT-MFP
sndchp    = $ffff8800                ;Adresse des Soundchips
ikbdacia  = $fffffc00                ;Adr. IKBD-ACIA
midiacia  = $fffffc04                ;Adr. MIDI-ACIA
	ELSE
;vorlÑufige Version fÅr PowerPC-Macs
mfp       = $e000fa01                ;Adresse des ST-MFP
mfp_tt    = $e000fa81                ;Adresse des TT-MFP
sndchp    = $e0008800                ;Adresse des Soundchips
ikbdacia  = $e000fc00                ;Adr. IKBD-ACIA
midiacia  = $e000fc04                ;Adr. MIDI-ACIA
	ENDC


;MFP-register-offsets to MFP base address
;define mfp_offs before including this file if an offset !=2 is needed
	IFND mfp_offs
mfp_offs	= 2	;offset between MFP registers
	ENDC
mfp_gpdr	= 0
mfp_aer	= 1*mfp_offs
mfp_ddr	= 2*mfp_offs
mfp_iera	= 3*mfp_offs
mfp_ierb	= 4*mfp_offs
mfp_ipra	= 5*mfp_offs
mfp_iprb	= 6*mfp_offs
mfp_isra	= 7*mfp_offs
mfp_isrb	= 8*mfp_offs
mfp_imra	= 9*mfp_offs
mfp_imrb	= 10*mfp_offs
mfp_vr	= 11*mfp_offs
mfp_tacr	= 12*mfp_offs
mfp_tbcr	= 13*mfp_offs
mfp_tcdcr	= 14*mfp_offs
mfp_tadr	= 15*mfp_offs
mfp_tbdr	= 16*mfp_offs
mfp_tcdr	= 17*mfp_offs
mfp_tddr	= 18*mfp_offs
mfp_scr	= 19*mfp_offs
mfp_ucr	= 20*mfp_offs
mfp_rsr	= 21*mfp_offs
mfp_tsr	= 22*mfp_offs
mfp_udr	= 23*mfp_offs



va_gemdos           = $84            ;long
va_bios   = $b4     ;long
va_xbios  = $b8     ;long

;MFP-Interrupts
iva_mfp_cts         = $108           ;CTS-Interrupt
iva_mfp_tic         = $114           ;TimerC (200Hz)
iva_mfp_acia        = $118           ;beide ACIA Åber I4
iva_mfp_ter         = $124           ;Transmitter Error
iva_mfp_tbe         = $128           ;Transmitter Buffer Empty
iva_mfp_rer         = $12c           ;Receiver Error
iva_mfp_rbf         = $130           ;Receiver Buffer Full

;TT-MFP-Interrupts
iva_ttmfp_ter       = $164           ;Transmitter Error
iva_ttmfp_tbe       = $168           ;Transmitter Buffer Empty
iva_ttmfp_rer       = $16c           ;Receiver Error
iva_ttmfp_rbf       = $170           ;Receiver Buffer Full

etv_timer           = $400           ;GEMDOS-Timervektor
_hz_200   = $4ba    ;long, 200Hz-ZÑhler
_sysbase  = $4f2    ;long
_longframe          = $59e           ;word

iorec_len           = $24            ;LÑnge einer _MODEM1_ IOREC-Struktur in Byte

;ASCII-Zeichen-Namen
bell      = $7
lf        = $a
cr        = $d
xon       = $11     ;ASCII-Code fÅr XON
xoff      = $13     ;ASCII-Code XOFF

;------------- fÅr MinT-kompatiblen Teil -----------------
;Nummern der Funktionen
;GEMDOS
n_fopen   = $3d
n_fclose  = $3e
n_fread   = $3f
n_fwrite  = $40
;MinT GEMDOS
n_fcntl   = $104
n_dcntl   = $130

;Mag!X Dcntl-Spezialfunktion
KER_GETINFO         = $100
KER_INSTXFS         = $200
KER_SETWBACK        = $300
DFS_GETINFO         = $1100
DFS_INSTDFS         = $1200
DEV_M_INSTALL       = $cd00


;Fcntl
FIONREAD  = (('F'<<8)|1)
FIONWRITE           = (('F'<<8)|2)
TIOCCBRK  = (('T'<<8)|20)            ;Break inaktivieren
TIOCSBRK  = (('T'<<8)|21)            ;Break aktivieren
TIOCIBAUD           = (('T'<<8)|18)  ;Input-Baudrate
TIOCOBAUD           = (('T'<<8)|19)  ;Output-Baudrate
TIOCGFLAGS          = (('T'<<8)|22)  ;lies öbertragungsprotokoll
TIOCSFLAGS          = (('T'<<8)|23)  ;setze öbertragungsprotokoll

;die neuen Fcntls
TIOCCTLMAP          = (('T'<<8)|129)
TIOCCTLGET          = (('T'<<8)|130)
TIOCCTLSET          = (('T'<<8)|131)
TIONOTSEND          = (('T'<<8)|134)
TIOCFLUSH           = (('T'<<8)|8)
;Fcntl hat ((short)(handle), (long)(argument), (short)(command))
; als Parameter

;Bitnummern fÅr die I/O-Lines und Signals
BITNR_TIOCM_LE  = 0       ;line enable output, Ausgang
BITNR_TIOCM_DTR           = 1              ;data terminal ready, Ausgang
BITNR_TIOCM_RTS           = 2              ;ready to send, hat heute andere Bedeutung, Ausgang
BITNR_TIOCM_CTS           = 3              ;clear to send, hat heute andere Bedeutung, Eingang
BITNR_TIOCM_CAR           = 4            ;data carrier detect, Eingang
BITNR_TIOCM_CD  = BITNR_TIOCM_CAR                ;alternativer Name
BITNR_TIOCM_RNG           = 5            ;ring indicator, Eingang
BITNR_TIOCM_RI  = BITNR_TIOCM_RNG                ;alternativer Name
BITNR_TIOCM_DSR           = 6            ;data set ready, Eingang
BITNR_TIOCM_LEI           = 7            ;line enable input, Eingang
BITNR_TIOCM_TXD           = 8           ;Sendedatenleitung, Ausgang
BITNR_TIOCM_RXD           = 9           ;Empfangsdatenleitung, Eingang
BITNR_TIOCM_BRK           = 10           ;Break erkannt, Pseudo-Eingang
BITNR_TIOCM_TER           = 11           ;Sendefehler, Pseudo-Eingang
BITNR_TIOCM_RER           = 12          ;Empfangsfehler, Pseudo-Eingang
BITNR_TIOCM_TBE           = 13          ;Hardware-Sendepuffer leer, Pseudo-Eingang
BITNR_TIOCM_RBF           = 14          ;Hardware-Empfangspuffer voll, Pseudo-Eingang

;Bitmasken fÅr die I/O-Lines und Signals
TIOCM_LE  = 1       ;line enable output, Ausgang
TIOCM_DTR           = 2              ;data terminal ready, Ausgang
TIOCM_RTS           = 4              ;ready to send, hat heute andere Bedeutung, Ausgang
TIOCM_CTS           = 8              ;clear to send, hat heute andere Bedeutung, Eingang
TIOCM_CAR           = $10            ;data carrier detect, Eingang
TIOCM_CD  = TIOCM_CAR                ;alternativer Name
TIOCM_RNG           = $20            ;ring indicator, Eingang
TIOCM_RI  = TIOCM_RNG                ;alternativer Name
TIOCM_DSR           = $40            ;data set ready, Eingang
TIOCM_LEI           = $80            ;line enable input, Eingang
TIOCM_TXD           = $100           ;Sendedatenleitung, Ausgang
TIOCM_RXD           = $200           ;Empfangsdatenleitung, Eingang
TIOCM_BRK           = $400           ;Break erkannt, Pseudo-Eingang
TIOCM_TER           = $800           ;Sendefehler, Pseudo-Eingang
TIOCM_RER           = $1000          ;Empfangsfehler, Pseudo-Eingang
TIOCM_TBE           = $2000          ;Hardware-Sendepuffer leer, Pseudo-Eingang
TIOCM_RBF           = $4000          ;Hardware-Empfangspuffer voll, Pseudo-Eingang


;Neue XBIOS Bconmap Funktionsnummern:
MAPT_OVE  = -400    ;ausgewÑhlten Eintrag Åberschreiben
MAPT_APP  = -401    ;Eintrag anhÑngen
MAPT_DEL	= -402	;device / RSVF-list remove

;Neue XBIOS Rsconf Funktionsnummer:
SETUSPEED           = -300           ;Klartext-Baudraten-Nutzung


;changes
;1998-08-07 MFP register offsets added
;1998-07-25 MAPT_DEL
;1997-07-08 the BITNR_TIOCM_ constants defined
