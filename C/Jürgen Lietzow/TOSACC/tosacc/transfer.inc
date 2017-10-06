;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;																		;;
;;																		;;
;;		>>>>>>>>>>>  TOS - Magazin   Ausgabe 6/92  <<<<<<<<<<<<<		;;
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
;;		Last Update		:	27.04.92 (JL)								;;
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

rwReturn:		ds.l		1
rwFlag:			ds.w		1
rwBuf:			ds.l		1
rwCount:		ds.w		1
rwRecno:		ds.w		1
rwDrv:			ds.w		1
rwLrecno:		ds.l		1

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
;;	RECINF-Struktur
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		.OFFSET	0

riNext:			ds.l	1
riRecno:		ds.l	1
riLast:			ds.l	1
riDirty:		ds.w	1
riCheckSum:		ds.w	1
riNewer:		ds.l	1
riOlder:		ds.l	1
riDrv:			ds.w	1
ri_length:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	DRIVEINF-Struktur
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		.OFFSET	0

diFirst:		ds.b	ri_length
diLast:			ds.b	ri_length
diKnown:		ds.w	1
diValid:		ds.w	1
diRead:			ds.w	1
diWrite:		ds.w	1
diFirstWrt:		ds.w	1
diDirty:		ds.w	1
diLocked:		ds.w	1
diRecSiz:		ds.w	1
diRecNum:		ds.l	1
diBpb:			ds.l	1
diReserved:		ds.b	128-76
di_length:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	TACCINF- und SYS-Struktur
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		.OFFSET	0
SYS:
version:		ds.b	10

; Memory

nxtKbSiz:		ds.w	1
nxtRecSiz:		ds.w	1


; RAM-Disk

rdNxtOn:		ds.w	1
rdNxtDrv:		ds.w	1
rdFname:		ds.b	128
rdParams:		ds.b	40
rdExecFlag:		ds.w	1

; save screen

scSwitch:		ds.w	1
scTime:			ds.w	1

; mouse speeder

smSwitch:		ds.w	1
smKeep:			ds.w	1
				ds.b	9
xList:			ds.b	1
				ds.b	9
				ds.b	9
yList:			ds.b	1
				ds.b	9

; printer spooler

spRate:			ds.l	1
spOn:			ds.w	1
spQuick:		ds.w	1

; timer

tiTime:			ds.l	1
tiFlag:			ds.w	1

; disk cache info

ciOn:			ds.w	1
ciDelay:		ds.l	1
ciDrvTypes:		ds.w	16

; SYS

saveFile:		ds.b	16

confInstalled:	ds.w	1

confActiv:		ds.w	1


resMem:			ds.l	1
OSVers:			ds.w	1
subprFlag:		ds.w	1
secTenth:		ds.w	1
tsecCount:		ds.l	1

hz200Flag:		ds.w	1
ahdiFlag:		ds.w	1
kbSiz:			ds.w	1
blkSiz:			ds.w	1
recSiz:			ds.w	1
absRecSiz:		ds.w	1

copyBlk:		ds.l	1
blkArray:		ds.l	1
blkNum:			ds.w	1
blkFrees:		ds.l	1


blkFreeNum:		ds.w	1
ciBlkNum:		ds.w	1
rdBlkNum:		ds.w	1
spBlkNum:		ds.w	1

; screen saver

colsav:			ds.w	16
scOutTime:		ds.l	1
scIsOn:			ds.w	1
scFlag:			ds.w	1

_InvertScreen:	ds.l	1

; mouse speeder

x:				ds.w	1
y:				ds.w	1
		
; RAM-Disk

rdOn:			ds.w	1
rdDrv:			ds.w	1
rdMaxRec:		ds.l	1
rdBpb:			ds.b	b_bpb_size
rdRecPtrs:		ds.l	1
rdDirty:		ds.w	1

; printer spooler

spNChars:		ds.l	1
spTChars:		ds.l	1

spRun:			ds.w	1
spInPos:		ds.w	1
spOutPos:		ds.w	1
spInBlk:		ds.l	1
spOutBlk:		ds.l	1

_ResetSpooler:	ds.l	1

; Cache

ciDirty:		ds.w	1
ciDelayOff:		ds.w	1
ciTimeOut:		ds.l	1
ciNewest:		ds.b	ri_length


ciOldest:		ds.b	ri_length
ciPuninfo:		ds.l	1

ciLogrd:		ds.l	1

ciPhrd:			ds.l	1
ciLogwrt:		ds.l	1
ciPhwrt:		ds.l	1

ciFixederr:		ds.l	1

ciFatalerr:		ds.l	1

ciRetSav:		ds.l	1
di:				ds.b	16*di_length


_ciState:		ds.l	1







_ciFlush:		ds.l	1
_ciClear:		ds.l	1

_ciDrState:		ds.l	1
_ciDrSet:		ds.l	1


; system vectors



_OldMediach:	ds.l	1
_NewMediach:	ds.l	1

_OldRW:			ds.l	1
_NewRW:			ds.l	1

_OldBPB:		ds.l	1
_NewBPB:		ds.l	1

_OldGEMDOS:		ds.l	1
_NewGEMDOS:		ds.l	1

_OldBIOS:		ds.l	1
_NewBIOS:		ds.l	1

_OldXBIOS:		ds.l	1
_NewXBIOS:		ds.l	1

_OldBcostat0:	ds.l	1
_NewBcostat0:	ds.l	1

_OldBconout0:	ds.l	1
_NewBconout0:	ds.l	1

_Old200HZ:		ds.l	1
_New200HZ:		ds.l	1

; set in TOSACC

_OldKEYBD:		ds.l	1
_NewKEYBD:		ds.l	1

_OldMOUSE:		ds.l	1
_NewMOUSE:		ds.l	1

SYS_length:

	.TEXT