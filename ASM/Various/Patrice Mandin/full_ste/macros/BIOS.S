; -------------	Bios

;	Codes d'erreur

E_OK	equ	0
ERROR	equ	-1
EDRVNR	equ	-2
EUNCMD	equ	-3
E_CRC	equ	-4
EBADRQ	equ	-5
E_SEEK	equ	-6
EMEDIA	equ	-7
ESECNF	equ	-8
EPAPER	equ	-9
EWRITF	equ	-10
EREADF	equ	-11
EWRPRO	equ	-12
E_CHNG	equ	-14
EUNDEV	equ	-15
EBADSF	equ	-16
EOTHER	equ	-17

;	Structure BOOT SECTEUR

BPS	equ	$0b	; octets par secteur
SPC	equ	$0d	; secteurs par cluster
RES	equ	$0e	; secteurs r‚serv‚s
NFATS	equ	$10	; fats
NDIRS	equ	$11	; fichiers par r‚pertoire racine
NSECTS	equ	$13	; secteurs par unit‚
MEDIA	equ	$15	; type du support
SPF	equ	$16	; secteurs par fat
SPT	equ	$18	; faces de l'unit‚
NSIDES	equ	$1a	; faces de l'unit‚
NHID	equ	$1c	; nombre de secteurs cach‚s

	TEXT

M_LINK	equ	0
M_START	equ	4
M_LENGTH	equ	8
M_OWN	equ	12

MP_MFL	equ	0
MP_MAL	equ	4
MP_ROVER	equ	8

GETMPB	MACRO
	move.l	\1,-(sp)
	clr	-(sp)
	trap	#13
	addq.l	#6,sp
	ENDM
		
BCONSTAT	MACRO
	move	\1,-(sp)
	move	#1,-(sp)
	trap	#13
	addq.l	#4,sp
	ENDM
		
DEV_PRINTER	equ	0
DEV_AUX	equ	1
DEV_CONSOLE	equ	2
DEV_MIDI	equ	3
DEV_IKBD	equ	4
DEV_RAW	equ	5

BCONIN	MACRO
	move	\1,-(sp)
	move	#2,-(sp)
	trap	#13
	addq.l	#4,sp
	ENDM

BCONOUT	MACRO
	move	\2,-(sp)
	move	#\1,-(sp)
	move	#3,-(sp)
	trap	#13
	addq.l	#6,sp
	ENDM

RW_READ	equ	0
RW_WRITE	equ	1
RW_NOMEDIACH	equ	2
RW_NORETRIES	equ	4
RW_NOTRANSLATE	equ	8

RWABS	MACRO
	IFEQ	NARG-6
	move.l	\6,-(sp)
	ENDC
	move	\5,-(sp)
	move	\4,-(sp)
	move	\3,-(sp)
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#4,-(sp)
	trap	#13
	lea	14(sp),sp
	ENDM

VEC_BUSERROR	equ	2
VEC_ADRESSERROR	equ	3
VEC_ILLEGAL	equ	4
VEC_GEMDOS	equ	32+1
VEC_GEM	equ	32+2
VEC_BIOS	equ	32+13
VEC_XBIOS	equ	32+14
VEC_TIMER	equ	256+0
VEC_CRITICALERR	equ	256+1
VEC_TERMINATE	equ	256+2

SETEXEC	MACRO
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#5,-(sp)
	trap	#13
	addq.l	#8,sp
	ENDM

TICKCAL	MACRO
	move	#6,-(sp)
	trap	#13
	addq.l	#2,sp
	ENDM

RECSIZ	equ	0
CLSIZ	equ	2
CLSIZB	equ	4
RDLEN	equ	6
FSIZ	equ	8
FATREC	equ	10
DATREC	equ	12
NUMCL	equ	14
BFLAGS	equ	16

GETBPB	MACRO
	move	\1,-(sp)
	move	#7,-(sp)
	trap	#13
	addq.l	#4,sp
	ENDM

BCOSTAT	MACRO
	move	\1,-(sp)
	move	#8,-(sp)
	trap	#13
	addq.l	#4,sp
	ENDM

MED_NOCHANGE	equ	0
MED_UNKNOWN	equ	1
MED_CHANGED	equ	2

MEDIACH	MACRO
	move	\1,-(sp)
	move	#9,-(sp)
	trap	#13
	addq.l	#4,sp
	ENDM

DRVMAP	MACRO
	move	#10,-(sp)
	trap	#13
	addq.l	#2,sp
	ENDM

;K_RSHIFT	equ	1
;K_LSHIFT	equ	2
;K_CTRL	equ	4
;K_ALT	equ	8
;K_CAPSLOCK	equ	16
;K_CLRHOME	equ	32
;K_INSERT	equ	64

KBSHIFT	MACRO
	move	\1,-(sp)
	move	#11,-(sp)
	trap	#13
	addq.l	#4,sp
	ENDM
	
INVERSE_MOT	MACRO
	move.b	\1(a0),d0
	move.b	\1+1(a0),\1(a0)
	move.b	d0,\1+1(a0)
	ENDM

INVERSE_BOOT	MACRO
	move.l	\1,a0
	INVERSE_MOT	BPS
	INVERSE_MOT	RES
	INVERSE_MOT	NDIRS
	INVERSE_MOT	NSECTS
	INVERSE_MOT	SPF
	INVERSE_MOT	SPT
	INVERSE_MOT	NSIDES
	INVERSE_MOT	NHID
	ENDM