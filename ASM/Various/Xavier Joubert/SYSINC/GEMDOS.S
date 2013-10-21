;	Gemdos

EINVFN	equ	-32
EFILNF	equ	-33
EPTHNF	equ	-34
ENHNDL	equ	-35
EACCDN	equ	-36
EIHNDL	equ	-37
ENSMEM	equ	-39
EIMBA	equ	-40
EDRIVE	equ	-46
ENSAME	equ	-48
ENMFIL	equ	-49
ELOCKED	equ	-58
ENSLOCK	equ	-59
ERANGE	equ	-64
EINTRN	equ	-65
EPLFMT	equ	-66
EGSBF	equ	-67
ELOOP	equ	-80
EMOUNT	equ	-200

S_READ	=	0
S_WRITE	=	1
S_READWRITE	=	2

SEEK_SET	=	0
SEEK_CUR	=	1
SEEK_END	=	2

MX_STRAM	=	0
MX_TTRAM	=	1
MX_PREFSTRAM	=	2
MX_PREFTTRAM	=	3

MX_HEADER	=	0<<4
MX_PRIVATE	=	1<<4
MX_GLOBAL	=	2<<4
MX_SUPERVISOR	=	3<<4
MX_READABLE	=	4<<4

	TEXT

SETBLOCK	MACRO
	move.l	4(sp),a6
	move.l	\1,sp
	move.l	12(a6),d7	;   taille TEXT
	add.l	20(a6),d7	; + taille DATA
	add.l	28(a6),d7	; + taille BSS
	add.l	#256,d7	; + taille basepage
	MSHRINK	a6,d7
	ENDM

PTERM0	MACRO
	clr	-(sp)
	trap	#1
	ENDM

CCONIN	MACRO
	move	#1,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM

CCONOUT	MACRO	caractere
	move	\1,-(sp)
	move	#2,-(sp)
	trap	#1
	addq.l	#4,sp
	ENDM

CAUXIN	MACRO
	move	#3,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM

CAUXOUT	MACRO	caractere
	move	\1,-(sp)
	move	#4,-(sp)
	trap	#1
	addq.l	#4,sp
	ENDM

CPRNOUT	MACRO	caractere
	move	\1,-(sp)
	move	#5,-(sp)
	trap	#1
	addq.l	#4,sp
	ENDM

CRAWIO	MACRO	wrd
	move	\1,-(sp)
	move	#6,-(sp)
	trap	#1
	addq.l	#4,sp
	ENDM

CRAWCIN	MACRO
	move	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM

CNECIN	MACRO
	move	#8,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM

CCONWS	MACRO	chaine
	move.l	\1,-(sp)
	move	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM
	
CCONRS	MACRO	buffer
	move.l	\1,-(sp)
	move	#10,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM

CCONIS	MACRO
	move	#11,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM

DSETDRV	MACRO	drive
	move	\1,-(sp)
	move	#14,-(sp)
	trap	#1
	addq.l	#4,sp
	ENDM

CCONOS	MACRO
	move	#16,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM

CPRNOS	MACRO
	move	#17,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM

CAUXIS	MACRO
	move	#18,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM

CAUXOS	MACRO
	move	#19,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM

MADDALT	MACRO	start,size
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move	#20,-(sp)
	trap	#1
	lea	10(sp),sp
	ENDM

SCREALLOC	MACRO	
	move.l	\1,-(sp)
	move	#21,-(sp)
	trap	#1
	addq	#6,sp
	ENDM

DGETDRV	MACRO
	move	#25,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM

FSETDTA	MACRO	buf
	move.l	\1,-(sp)
	move	#26,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM

SUPER	MACRO	mode
	move.l	\1,-(sp)
	move	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM

TGETDATE	MACRO
	move	#42,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM

TSETDATE	MACRO	date
	move	\1,-(sp)
	move	#43,-(sp)
	trap	#1
	addq.l	#4,sp
	ENDM

TGETTIME	MACRO
	move	#44,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM

TSETTIME	MACRO	heure
	move	\1,-(sp)
	move	#45,-(sp)
	trap	#1
	addq.l	#4,sp
	ENDM

FGETDTA	MACRO
	move	#47,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM

SVERSION	MACRO
	move	#48,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM

PTERMRES	MACRO	keepcnt,retcode
	move	\2,-(sp)
	move.l	\1,-(sp)
	move	#49,-(sp)
	trap	#1
	addq.l	#8,sp
	ENDM

DFREE	MACRO	buffer,drive
	move	\2,-(sp)
	move.l	\1,-(sp)
	move	#54,-(sp)
	trap	#1
	addq.l	#8,sp
	ENDM

DCREATE	MACRO	path
	move.l	\1,-(sp)
	move	#57,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM

DDELETE	MACRO	path
	move.l	\1,-(sp)
	move	#58,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM

DSETPATH	MACRO	path
	move.l	\1,-(sp)
	move	#59,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM

FCREATE	MACRO	fname,attr
	move	\2,-(sp)
	move.l	\1,-(sp)
	move	#60,-(sp)
	trap	#1
	addq.l	#8,sp
	ENDM

FOPEN	MACRO	fname,mode
	move	\2,-(sp)
	move.l	\1,-(sp)
	move	#61,-(sp)
	trap	#1
	addq.l	#8,sp
	ENDM

FCLOSE	MACRO	fhandle
	move	\1,-(sp)
	move	#62,-(sp)
	trap	#1
	addq.l	#4,sp
	ENDM

FREAD	MACRO	handle,count,buff
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#63,-(sp)
	trap	#1
	lea	12(sp),sp
	ENDM

FWRITE	MACRO	handle,count,buff
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#64,-(sp)
	trap	#1
	lea	12(sp),sp
	ENDM

FDELETE	MACRO	fname
	move.l	\1,-(sp)
	move	#65,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM

FSEEK	MACRO	offset,handle,seekmode
	move	\3,-(sp)
	move	\2,-(sp)
	move.l	\1,-(sp)
	move	#66,-(sp)
	trap	#1
	lea	10(sp),sp
	ENDM

FATTRIB	MACRO	fname,flag,attrib
	move	\3,-(sp)
	move	\2,-(sp)
	move.l	\1,-(sp)
	move	#67,-(sp)
	trap	#1
	lea	10(sp),sp
	ENDM

MXALLOC	MACRO	amount,mode
	move	\2,-(sp)
	move.l	\1,-(sp)
	move	#68,-(sp)
	trap	#1
	addq	#8,sp
	ENDM

FDUP	MACRO	handle
	move	\1,-(sp)
	move	#69,-(sp)
	trap	#1
	addq.l	#4,sp
	ENDM

FFORCE	MACRO	stdh,nonstdh
	move	\2,-(sp)
	move	\1,-(sp)
	move	#70,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM

DGETPATH	MACRO	buf,drive
	move	\2,-(sp)
	move.l	\1,-(sp)
	move	#71,-(sp)
	trap	#1
	addq.l	#8,sp
	ENDM

MALLOC	MACRO	nombre
	move.l	\1,-(sp)
	move	#72,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM

MFREE	MACRO	addr
	move.l	\1,-(sp)
	move	#73,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM

MSHRINK	MACRO	dummy_0,block,newsize
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	clr	-(sp)
	move	#74,-(sp)
	trap	#1
	lea	12(sp),sp
	ENDM

PEXEC	MACRO	mode,prg,cmdl,envp
	move.l	\4,-(sp)
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#75,-(sp)
	trap	#1
	lea	16(sp),sp
	ENDM

PTERM	MACRO	retcode
	move	\1,-(sp)
	move	#76,-(sp)
	trap	#1
	addq.l	#4,sp
	ENDM

FSFIRST	MACRO	fnam,attr
	move	\2,-(sp)
	move.l	\1,-(sp)
	move	#78,-(sp)
	trap	#1
	addq.l	#8,sp
	ENDM

FSNEXT	MACRO
	move	#79,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM

FRENAME	MACRO	dummy_0,oldname,newname
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	clr	-(sp)
	move	#86,-(sp)
	trap	#1
	lea	12(sp),sp
	ENDM

FDATIME	MACRO	timeptr,handle,wflag
	move	\3,-(sp)
	move	\2,-(sp)
	move.l	\1,-(sp)
	move	#87,-(sp)
	trap	#1
	lea	10(sp),sp
	ENDM

FLOAD	MACRO	handle,nom,adresse,longueur,offset
	FOPEN	\2,#S_READ
	ext.l	d0
	tst.l	d0
	bmi.s	_fload_error\@
	move	d0,\1
	IFEQ	NARG-5
	FSEEK	\5,\1,#SEEK_SET
	tst.l	d0
	bmi.s	_fload_error\@
	ENDC
	FREAD	\1,\4,\3
	tst.l	d0
	bmi.s	_fload_error\@
	FCLOSE	\1
	ext.l	d0
_fload_error\@
	ENDM
	
FLSAVE	MACRO	handle,nom,adresse,longueur
	FCREATE	\2,#0
	ext.l	d0
	tst.l	d0
	bmi	_fsave_error\@
	move	d0,\1
	FWRITE	\1,\4,\3
	tst.l	d0
	bmi	_fsave_error\@
	FCLOSE	\1
	ext.l	d0
_fsave_error\@
	ENDM

MTFREE	MACRO	addr
	tst.l	\1
	beq.s	mtfree_nz\@
	MFREE	\1
mtfree_nz\@
	ENDM
