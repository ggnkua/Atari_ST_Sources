; -------------	Bios

;	Codes d'erreur

E_OK	=	0
ERROR	=	-1
EDRVNR	=	-2
EUNCMD	=	-3
E_CRC	=	-4
EBADRQ	=	-5
E_SEEK	=	-6
EMEDIA	=	-7
ESECNF	=	-8
EPAPER	=	-9
EWRITF	=	-10
EREADF	=	-11
EWRPRO	=	-12
E_CHNG	=	-14
EUNDEV	=	-15
EBADSF	=	-16
EOTHER	=	-17

;	Structure BOOT SECTEUR

BPS	=	$0b	; octets par secteur
SPC	=	$0d	; secteurs par cluster
RES	=	$0e	; secteurs r‚serv‚s
NFATS	=	$10	; fats
NDIRS	=	$11	; fichiers par r‚pertoire racine
NSECTS	=	$13	; secteurs par unit‚
MEDIA	=	$15	; type du support
SPF	=	$16	; secteurs par fat
SPT	=	$18	; faces de l'unit‚
NSIDES	=	$1a	; faces de l'unit‚
NHID	=	$1c	; nombre de secteurs cach‚s

	TEXT

M_LINK	=	0
M_START	=	4
M_LENGTH	=	8
M_OWN	=	12

MP_MFL	=	0
MP_MAL	=	4
MP_ROVER	=	8

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
		
DEV_PRINTER	=	0
DEV_AUX	=	1
DEV_CONSOLE	=	2
DEV_MIDI	=	3
DEV_IKBD	=	4
DEV_RAW	=	5

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

RW_READ	=	0
RW_WRITE	=	1
RW_NOMEDIACH	=	2
RW_NORETRIES	=	4
RW_NOTRANSLATE	=	8

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

VEC_INQUIRE	=	-1
VEC_BUSERROR	=	2
VEC_ADRESSERROR	=	3
VEC_ILLEGAL	=	4
VEC_GEMDOS	=	32+1
VEC_GEM	=	32+2
VEC_BIOS	=	32+13
VEC_XBIOS	=	32+14
VEC_TIMER	=	256+0
VEC_CRITICALERR	=	256+1
VEC_TERMINATE	=	256+2

SETEXC	MACRO
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

	RsReset
BPB_recsiz	rs.w	1
BPB_clsiz	rs.w	1
BPB_clsizb	rs.w	1
BPB_rdlen	rs.w	1
BPB_fsiz	rs.w	1
BPB_fatrec	rs.w	1
BPB_datrec	rs.w	1
BPB_numcl	rs.w	1
BPB_bflags	rs.w	1
SIZEOF_BPB	rs.w	1

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

MED_NOCHANGE	=	0
MED_UNKNOWN	=	1
MED_CHANGED	=	2

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

;K_RSHIFT	=	1
;K_LSHIFT	=	2
;K_CTRL	=	4
;K_ALT	=	8
;K_CAPSLOCK	=	16
;K_CLRHOME	=	32
;K_INSERT	=	64

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