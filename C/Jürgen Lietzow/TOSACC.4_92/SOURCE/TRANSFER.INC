;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;																		;;
;;																		;;
;;		>>>>>>>>>>>  TOS - Magazin   Ausgabe 3/91  <<<<<<<<<<<<<		;;
;;																		;;
;;																		;;
;;		P R O J E C T	:	TOS ACCESSORY Spezial						;;
;;							AUTOTACC.PRG								;;
;;																		;;
;;		M O D U L E		:	TRANSFER.INC								;;
;;																		;;
;;																		;;
;;		Author			:	Jrgen Lietzow fr TOS-Magazin				;;
;;																		;;
;;		System/Compiler	:	Atari ST/TT, TOS 1.4, Pure C				;;
;;																		;;
;;		Last Update		:	16.12.91 (JL)								;;
;;																		;;
;;																		;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Defines
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	AES				equ		200			; AES magic
	_AES			equ		200

	_objc_draw		equ		42
	_objc_edit		equ		46
	_objc_change	equ		47
	_form_do		equ		50
	_form_dial		equ		51
	_form_alert		equ		52
	_form_center	equ		54
	_form_keybd		equ		55
	_form_button	equ		56


	colorptr		equ		$45a		; Farbregister fr n„chsten Vsync
	colregs			equ		$ffff8240	; aktuelle Farbregister

	_p_cookies	 	equ		$5a0		; Cookie Zeiger
	_nflops			equ		$4a6		; Anzahl der angemeldeten Laufwerke
	_drvbits		equ		$4c2		; Laufwerke-Bitmap

	_memvalid		equ		$420		; gltige Speicherkonfiguration ?
	_resvalid		equ		$426		; gltiger Resetvektor ?
	_resvector		equ		$42a		; n„chster Resetvektor !
	_resmagic		equ		$31415926	; gltige Speicherkonfiguration !

	_pagemagic		equ		$12123456	; gltige Speicherseite Nr.1 !
	_pagemagsum		equ		$5678		; gltige Speicherseite Nr.2 !
	
	_memtop			equ		$436		; OS-Speicherende
	_phystop		equ		$42e		; physikalisches Speicherende
	_longframe		equ		$59e		; Interrupt-Parameter-Offset
	_hz_200			equ		$4ba		; Timer 200 HZ Z„hler

	SysGEM			equ		$88			; VDI/GEM-Trap
	SysGEMDOS		equ		$84			; GEMDOS-Trap
	SysBIOS			equ		$B4			; BIOS-Trap
	SysXBIOS		equ		$B8			; XBIOS-Trap
	Sys200HZ		equ		$114		; 200 Hz Timer-Vektor
	SysVSYNC		equ		$70			; Vsync-Vektor
	SysKEYBD		equ		$118		; Keyboard-Interrupt-Vektor

	SysGetbpb		equ		$472	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Struktur der Base page
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		.OFFSET 0

TpaStart:
		ds.l 1
TpaEnd:
		ds.l 1
TextSegStart:
		ds.l 1
TextSegSize:
		ds.l 1
DataSegStart:
		ds.l 1
DataSegSize:
		ds.l 1
BssSegStart:
		ds.l 1
BssSegSize:
		ds.l 1
DtaPtr:
		ds.l 1
PntPrcPtr:
		ds.l 1
Reserved0:
		ds.l 1
EnvStrPtr:
		ds.l 1
Reserved1:
		ds.b 7
CurDrv:
		ds.b 1
Reserved2:
		ds.l 18
CmdLine:
		ds.b 128
BasePageSize:
		ds	 0



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	GEMPARBLK-Struktur
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	.OFFSET		0
								; Aufbau des GemParBlk
control:	ds.l	1
global:		ds.l	1
intin:		ds.l	1
intout:		ds.l	1
adrin:		ds.l	1
adrout:		ds.l	1


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	BPB-Struktur
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		.OFFSET 0

b_recsiz:			ds.w	1
b_clsiz:			ds.w	1
b_clsizb:			ds.w	1
b_rdlen:			ds.w	1
b_fsiz:				ds.w	1
b_fatrec:			ds.w	1
b_datrec:			ds.w	1
b_numcl:			ds.w	1
b_bflags:			ds.w	1
b_bpb_size:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Header oberhalb _phystop
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		.OFFSET 0

dummy:			ds.l		1
magic:			ds.l		1
our_cookie:		ds.w		1
drive_on:		ds.w		1
drive:			ds.w		1
resvec_sav:		ds.l		1				; resvec_sav
resmag_sav:		ds.l		1				; resmag_sav
hd_size:		ds.w		1
hd_bpb:			ds.b		b_bpb_size
hd_maxsec:		ds.l		1
resCodeLen:		ds.l		1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Parameter auf Stack bei hdv_rw
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		.OFFSET	0				; Rwabs structure

rw_return:		ds.l		1
rw_flag:		ds.w		1
rw_buf:			ds.l		1
rw_count:		ds.w		1
rw_recno:		ds.w		1
rw_drive:		ds.w		1
rw_lrec:		ds.l		1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	DTA-Struktur
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		.OFFSET	0

d_reserved:		ds.b	21
d_attrib:		ds.b	1
d_time:			ds.w	1
d_date:			ds.w	1
d_length:		ds.l	1
d_fname:		ds.b	14
d_dta_length:


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	TOS-Accessory System Struktur
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		.OFFSET 0

SYS:
version:		ds.b	10

;	fr den Bildschirmschoner

scSwitch:		ds.w	1
scTime:			ds.w	1
OldKEYBD:		ds.l	1
Old200HZ:		ds.l	1
NewKEYBD:		ds.l	1
New200HZ:		ds.l	1
InvertScreen:	ds.l	1
colsav:			ds.w	16
secCount:		ds.w	1
scIsOn:			ds.w	1
scCount:		ds.w	1
scFlag:			ds.w	1

;	fr den Mausbeschleuniger

OldMOUSE:		ds.l	1
smSwitch:		ds.w	1
smKeep:			ds.w	1
NewMOUSE:		ds.l	1
				ds.b	9
xList:			ds.b	1
				ds.b	9
				ds.b	9
yList:			ds.b	1
				ds.b	9
	.EVEN
x:				ds.w	1
y:				ds.w	1

;	fr die RAM-Disk

OldMediach:		ds.l	1
NewMediach:		ds.l	1
OldRW:			ds.l	1
NewRW:			ds.l	1
OldBPB:			ds.l	1
NewBPB:			ds.l	1

rd_installed:	ds.w	1
rd_drive:		ds.w	1
rd_size:		ds.w	1
rd_locked:		ds.w	1
rd_maxsec:		ds.l	1
rd_data:		ds.l	1
rd_bpb:			ds.l	1

ph_head:		ds.l	1
OSVers:			ds.w	1
secTenth:		ds.w	1
in200HZ:		ds.w	1

;	Fr den Spooler

inSys_flag:		ds.w	1			; 1 == PC im Betriebssystem

spStatErr:		ds.w	1
spRate:			ds.w	1
spOn:			ds.w	1
spQuick:		ds.w	1
spNChars:		ds.l	1
spNBlocks:		ds.l	1
spLockTime:		ds.l	1
spDemand:		ds.w	1

spRun:			ds.w	1
spLocked:		ds.w	1
spLockCount:	ds.w	1
spLastType:		ds.w	1
spLast:			ds.l	1
spInPos:		ds.w	1
spOutPos:		ds.w	1
spOutFree:		ds.l	1
spFrees:		ds.l	1
spInBlk:		ds.l	1
spOutBlk:		ds.l	1
spBMap:			ds.l	1

spFile:			ds.b	40
spDTA:			ds.b	d_dta_length
		
spGEMDOSFlag:	ds.w	1
spBcostatFlag:	ds.w	1
spGDBufPos:		ds.w	1
spGDBuf:		ds.b	512

OldGEMDOS:		ds.l	1
OldBIOS:		ds.l	1
OldXBIOS:		ds.l	1
OldBcostat0:	ds.l	1
OldBconout0:	ds.l	1
	
NewGEMDOS:		ds.l	1
NewBIOS:		ds.l	1
NewXBIOS:		ds.l	1
NewBcostat0:	ds.l	1
NewBconout0:	ds.l	1
		
_ResetSpooler:	ds.l	1
_DemandBlock:	ds.l	1

SYSEND:


	.TEXT
	