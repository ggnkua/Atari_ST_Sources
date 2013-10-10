; Systemtest, Komponenten anhand Cookiejar abchecken, nur Relevante Be-
; standteile fÅr hardwarenahe Programmierung testen.

; SYSTEST muû im Supervisormode aufgerufen werden.

	IFND	_SYSTEST
_SYSTEST	EQU		$0100

; Bufferoffsets.
_CPU	EQU	0	; Prozessor
_VDO	EQU	1	; Videosystem
_FDC	EQU	2	; Floppycontroler
_SND	EQU	3	; Soundsystem
_MCH	EQU	4	; Machine
_FPU	EQU	5	; Floating Point Unit
MINT	EQU	6	; Mint
_COD	EQU	7	; Codec
_DSP	EQU	8	; DSP
_16D	EQU	9	; 16-Bit Samplesound
_YAM	EQU	10	; Yamaha
_MON	EQU	11	; Monitortyp (Belegung $ffff8006: 0 - Mono / 1 - RGB /
				;								  2 - VGA /  3 - TV )

_sysbase:	INLINE	"SYSTEST.INC"

; Registerdefinitionen.
SYS_PARAS	EQUR	a0
BUF_SIZE	EQUR	d0
FALCONE		EQUR	d0

; Einsprungadressen.
SYSTEST			EQU		_sysbase+0	; Systemtest
GET_BUF_SIZE	EQU		_sysbase+4	; Grîûe des Buffers holen
FALCON_TEST		EQU		_sysbase+8	; Falconhardware ?
	ENDIF