; Testet Systemressourcen und gibt sie in einer Struktur zurÅck.
; Auswertung nur Cookiejar.
; Es werden nur die Cookies ausgewertet, die Relevanz bei hardwarenaher Pro-
; grammierung haben, also auch "MiNT", da der Speicherschutz ausgeschalten
; bzw. umgangen werden muû.

; Future:	Speicher (Fast-Ram) 

; 2.8.1994 Jochen Knaus, BDCannibal/AURA.

BUF_SIZE	EQU	16
PMOD	EQU	0

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
_MON	EQU	11	; Monitortyp

	MC68030

       IFEQ	PMOD
	MODUL	"F:\LIB\SYSTEST.INC"
	ORG	0
	OPT	O+,D-

	bra.w	get_system
	bra.w	get_buffersize
	bra.w	falcon_hardware

	DC.B	'PMOD'
	DC.B	'Systemtest.    ',0
	DC.B	'BDCannibal/AURA',0
	DC.B	'08940894','0100'
	DC.B	'20-------------'
       ENDIF

; Gibt Grîûe des Buffers zurÅck. Wahrscheinlich unnîtig.
get_buffersize:
	moveq	#BUF_SIZE,d0
	rts

; a0.l - Pointer auf Struktur.
get_system:	movem.l	d0-a6,-(sp)

	move.l	$5a0.w,d0	; Cookiebase
	bne.s	tos_1_6	; das waren noch Tage...

	moveq	#-1,d0	; Z-Bit lîschen
	movem.l	(sp)+,d0-a6
	rts

tos_1_6:	move.l	d0,a1

	move.l	a0,a2
	moveq	#BUF_SIZE-1,d7
clr_buf:	clr.b	(a2)+
	dbra	d7,clr_buf

search_cook:	movem.l	(a1)+,d0/d6
	tst.l	d0
	beq	ende_liste

	lea	ref_liste(pc),a5
	move.w	(a5)+,d7	; Anzahl Referenzcookies.
chk_entry:	move.l	(a5)+,d1	; Name
	move.w	(a5)+,d2	; relativer Sprungoffset
	cmp.l	d1,d0
	dbeq	d7,chk_entry

	tst.w	d7		; Referenz gefunden ?
	bmi.s	search_cook
				; Data in d6.l
	jsr	(base.w,pc,d2.w)	; Entsprechende Rou. anspringen.
	bra.s	search_cook	; NÑchsten Keks

ende_liste:	bfextu	$ffff8006.w{0:2},d0	; Monitortyp (Intel-Format:
	move.b	d0,_MON(a0)	; 0: Offset auf Motorola MSB)

	moveq	#0,d0	; Z-Bit setzen
	movem.l	(sp)+,d0-a6
	rts

ref_liste:	DC.W	7-1		; 7 untersuchte EintrÑge.

	DC.L	'_CPU'	; Prozessor
	DC.W	__cpu-base
	DC.L	'_VDO'	; Videosystem
	DC.W	__vdo-base
	DC.L	'_FDC'	; Floppy
	DC.W	__fdc-base
	DC.L	'_SND'	; Sound
	DC.W	__snd-base
	DC.L	'_MCH'	; Kiste
	DC.W	__mch-base
	DC.L	'_FPU'	; Coproz
	DC.W	__fpu-base
	DC.L	'MiNT'	; MiNT
	DC.W	__mint-base

base:
__cpu:	move.b	d6,_CPU(a0)	; CPU-Typ Åbernehmen.
	rts
__vdo:	swap	d6		; Bit 16/17 nach unten.
	move.b	d6,_VDO(a0)
	rts
__fdc:	move.l	d0,-(sp)
	move.l	d6,d0
	andi.l	#$ffffff,d0
	swap	d6
	lsr.b	#4,d6	; Diskettenformat
	cmpi.l	#'ATC',d0	; Kompatibler Controller ?
	bne.s	no_com_fdc
	bset	#7,d6	; Bit 7 setzen.
no_com_fdc:	move.b	d6,_FDC(a0)
	move.l	(sp)+,d0
	rts
__snd:	btst	#4,d6
	sne	_COD(a0)	; Codec ?
	btst	#3,d6
	sne	_DSP(a0)	; DSP ?
	btst	#2,d6
	sne	_16D(a0)	; 16 Bit DMA ?
	btst	#0,d6
	sne	_YAM(a0)	; Yamaha ?
	rts
__mch:	swap	d6		; Maschine: STE kompat. werden ignor.
	move.b	d6,_MCH(a0)
	rts
__fpu:	swap	d6
	move.b	d6,_FPU(a0)
	rts
__mint:	st	MINT(a0)
	rts

; Untersucht, ob es sich um Falcon-taugliche-Hardware handelt.
; Kein GewÑhr fÅr Grafikkarten.
; a0.l - Pointer auf Hardwareliste.
; d0.w = 0: kein Falcon
; d0.w = 1: Falcon
falcon_hardware:
	cmp.b	#3,_MCH(a0)	; Ist es ein Falcon ?
	beq.s	falcon

	cmp.b	#30,_CPU(a0)	; Mindestens 030 (oder 020
	blt.s	no_com	; mit MMU)

	move.b	_VDO(a0),d0	; Falconvideosystem
	cmpi.b	#$03,d0	; Alles grîûere sollte Falcon-
	blt.s	no_com	; kompatibel sein...

	and.b	_YAM(a0),d0	; komplettes Soundsystem !
	and.b	_16D(a0),d0
	and.b	_DSP(a0),d0
	and.b	_COD(a0),d0

falcon:	rts
no_com:	moveq	#0,d0
	rts