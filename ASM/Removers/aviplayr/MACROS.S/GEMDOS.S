*****************
* Macros GEMDOS *
*****************
		IFND	__DEBUG_MFREE
__DEBUG_MFREE	equ	0
		ENDC
		IFND	__DEBUG_MALLOC
__DEBUG_MALLOC	equ	0
		ENDC
			IFND	__DEBUG_MALLOC_CANARIES
__DEBUG_MALLOC_CANARIES	equ	0
			ENDC

********************************
* Structures

BASEPAGE	rsstruct
p_lowtpa	rs.l	1	; pointer to	bottom of Transient Program Area
				;	(TPA) (void *)
p_hitpa		rs.l	1	; pointer to	top of TPA + 1	(void *)
p_tbase		rs.l	1	; base of text segment		(void *)
p_tlen		rs.l	1	; length of text segment	(LONG)
p_dbase		rs.l	1	; base of data segment		(void *)
p_dlen		rs.l	1	; length of data segment	(LONG)
p_bbase		rs.l	1	; base of BSS segment		(void *)
p_blen		rs.l	1	; length of BSS segment		(LONG)
p_dta		rs.l	1	; pointer to	current DTA	(void *)
p_parent	rs.l	1	; pointer to	parent's basepage (BASEPAGE *)
p_reserved	rs.l	1	; 				(void *)
p_env		rs.l	1	; pointer to	environment strings (char *)
p_undef		rs.l	20	; 				(LONG[20])
p_cmdlin	rs.b	128	; command line image		(char[128])
sizeof		rs	0
		rsend

DTA		rsstruct
reserved	rs.b	21
attrib		rs.b	1
time		rs.w	1
date		rs.w	1
length		rs.l	1
fname		rs.b	14
sizeof		rs	0
		rsend


* Super

SUP_SET		equ	0
SUP_INQUIRE	equ	1

* Fseek

FSEEK_BEGIN	equ	0
SEEK_SET	equ	0
FSEEK_REL	equ	1
SEEK_CUR	equ	1
FSEEK_END	equ	2
SEEK_END	equ	2

* Fsfirst

FA_READONLY	equ	$01
FA_HIDDEN	equ	$02
FA_SYSTEM	equ	$04
FA_VOLUME	equ	$08
FA_DIR		equ	$10
FA_ARCHIVE	equ	$20

* GEMDOS Standard Handles
GSH_CONIN	equ	0
GSH_CONOUT	equ	1
GSH_AUX		equ	2
GSH_PRN		equ	3
GSH_BIOSCON	equ	-1
GSH_BIOSAUX	equ	-2
GSH_BIOSPRN	equ	-3
GSH_BIOSMIDIIN	equ	-4
GSH_BIOSMIDIOUT	equ	-5

********************************
* Macros

Pterm0	macro
	clr.w	-(sp)
	trap	#1
	addq.l	#2,sp
	endm
	
Cconin	macro
	move.w	#1,-(sp)
	trap	#1
	addq.l	#2,sp
	endm
	
Cconout	macro
	move.w	\1,-(sp)
	move.w	#2,-(sp)
	trap	#1
	addq.l	#4,sp
	endm
	
Cauxin	macro
	move.w	#3,-(sp)
	trap	#1
	addq.l	#2,sp
	endm
	
Cauxout	macro
	move.w	\1,-(sp)
	move.w	#4,-(sp)
	trap	#1
	addq.l	#4,sp
	endm
	
Cprnout	macro
	move.w	\1,-(sp)
	move.w	#5,-(sp)
	trap	#1
	addq.l	#4,sp
	endm
	
Crawio	macro
	move.w	\1,-(sp)
	move.w	#6,-(sp)
	trap	#1
	addq.l	#4,sp
	endm
	
Crawcin	macro
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	endm

Cnecin	macro
	move.w	#8,-(sp)
	trap	#1
	addq.l	#2,sp
	endm
	
Cconws	macro
	IFC	'\1','d0'
	move.l	d0,-(sp)
	ELSE
		IFC	'\1','d1'
		move.l	d1,-(sp)
		ELSE
			IFC	'\1','d2'
			move.l	d2,-(sp)
			ELSE
				IFC	'\1','d3'
				move.l	d3,-(sp)
				ELSE
					IFC	'\1','d4'
					move.l	d4,-(sp)
					ELSE
						IFC	'\1','d5'
						move.l	d5,-(sp)
						ELSE
							IFC	'\1','d6'
							move.l	d6,-(sp)
							ELSE
								IFC	'\1','d7'
								move.l	d7,-(sp)
								ELSE
								pea	\1
								ENDC
							ENDC
						ENDC
					ENDC
				ENDC
			ENDC
		ENDC
	ENDC
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	endm

Cconrs	macro
	pea	\1
	move.w	#10,-(sp)
	trap	#1
	addq.l	#6,sp
	endm
	
Cconis	macro
	move.w	#11,-(sp)
	trap	#1
	addq.l	#2,sp
	endm
	
Dsetdrv	macro
	move.w	\1,-(sp)
	move.w	#14,-(sp)
	trap	#1
	addq.l	#4,sp
	endm
	
Cconos	macro
	move.w	#16,-(sp)
	trap	#1
	addq.l	#2,sp
	endm
	
Cprnos	macro
	move.w	#17,-(sp)
	trap	#1
	addq.l	#2,sp
	endm
	
Cauxis	macro
	move.w	#18,-(sp)
	trap	#1
	addq.l	#2,sp
	endm
	
Cauxos	macro
	move.w	#19,-(sp)
	trap	#1
	addq.l	#2,sp
	
Maddalt	macro
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#20,-(sp)
	trap	#1
	lea	10(sp),sp
	endm
	
Screalloc	macro
	move.l	\1,-(sp)
	move.w	#21,-(sp)
	trap	#1
	addq.l	#6,sp
	endm
	
Dgetdrv	macro
	move.w	#25,-(sp)
	trap	#1
	addq.l	#2,sp
	endm
	
Fsetdta	macro
	pea	\1
	move.w	#26,-(sp)
	trap	#1
	addq.l	#6,sp
	endm
	
Supers	macro
	IFC	'\1','#0'
	clr.l	-(sp)
	ELSE
	IFC	'\1','#SUP_SET'
	clr.l	-(sp)
	ELSE
		IFC	'\1','#1'
		pea	1.w
		ELSE
		IFC	'\1','#SUP_INQUIRE'
		pea	1.w
		ELSE
		move.l	\1,-(sp)
		ENDC
		ENDC
	ENDC
	ENDC
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	endm

Tgetdate	macro
	move.w	#42,-(sp)
	trap	#1
	addq.l	#2,sp
	endm
	
Tsetdate	macro
	move.w	\1,-(sp)
	move.w	#43,-(sp)
	trap	#1
	addq.l	#4,sp
	endm
	
Tgettime	macro
	move.w	#44,-(sp)
	trap	#1
	addq.l	#2,sp
	endm
	
Tsettime	macro
	move.w	\1,-(sp)
	move.w	#45,-(sp)
	trap	#1
	addq.l	#4,sp
	endm
	
Fgetdta	macro
	move.w	#47,-(sp)
	trap	#1
	addq.l	#2,sp
	endm

Sversion	macro
	move.w	#48,-(sp)
	trap	#1
	addq.l	#2,sp
	endm
	
Ptermres	macro
	move.w	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#49,-(sp)
	trap	#1
	addq.l	#8,sp
	endm

Dfree	macro
	move.w	\2,-(sp)
	pea	\1
	move.w	#54,-(sp)
	trap	#1
	addq.l	#8,sp
	endm
	
Dcreate	macro
	pea	\1
	move.w	#57,-(sp)
	trap	#1
	addq.l	#6,sp
	endm
	
Ddelete	macro
	pea	\1
	move.w	#58,-(sp)
	trap	#1
	addq.l	#6,sp
	endm
	
Dsetpath	macro
	pea	\1
	move.w	#59,-(sp)
	trap	#1
	addq.l	#6,sp
	endm
	
Fcreate	macro
	IFC	'\2','#0'
	clr.w	-(sp)
	ELSE
	move.w	\2,-(sp)
	ENDC
	pea	\1
	move.w	#60,-(sp)
	trap	#1
	addq.l	#8,sp
	endm
	
Fopen	macro
	IFC	'\2','#0'
	clr.w	-(sp)
	ELSE
	move.w	\2,-(sp)
	ENDC
	pea	\1
	move.w	#61,-(sp)
	trap	#1
	addq.l	#8,sp
	endm
	
Fclose	macro
	move.w	\1,-(sp)
	move.w	#62,-(sp)
	trap	#1
	addq.l	#4,sp
	endm
	
Fread	macro
	pea	\3
	move.l	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#63,-(sp)
	trap	#1
	lea	12(sp),sp
	endm
	
Fwrite	macro
	pea	\3
	move.l	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#64,-(sp)
	trap	#1
	lea	12(sp),sp
	endm
		
Fdelete	macro
	pea	\1
	move.w	#65,-(sp)
	trap	#1
	addq.l	#6,sp
	endm
	
Fseek	macro
	IFC	'\3','#0'
	clr.w	-(sp)
	ELSE
	move.w	\3,-(sp)
	ENDC
	move.w	\2,-(sp)
	IFC	'\1','#0'
	clr.l	-(sp)
	ELSE
	move.l	\1,-(sp)
	ENDC
	move.w	#66,-(sp)
	trap	#1
	lea	10(sp),sp
	endm
	
Fattrib	macro
	move.w	\3,-(sp)
	move.w	\2,-(sp)
	pea	\1
	move.w	#67,-(sp)
	trap	#1
	lea	10(sp),sp
	endm

Mxalloc	macro
	IFNC	'\1','#-1'
	IF	__DEBUG_MALLOC_CANARIES
	move.l	\1,-(sp)	; remember original size
	ENDC	; __DEBUG_MALLOC_CANARIES
	ENDC	; \1 = "#-1"
	IFC	'\2','#0'
	clr.w	-(sp)
	ELSE
	move.w	\2,-(sp)
	ENDC
	move.l	\1,-(sp)
	IFNC	'\1','#-1'
	IF	__DEBUG_MALLOC_CANARIES
	add.l	#32,(sp)	 ; allocate size+32
	ENDC	; __DEBUG_MALLOC_CANARIES
	ENDC	; \1 = "#-1"
	move.w	#68,-(sp)
	trap	#1
	addq.l	#8,sp
	IFNC	'\1','#-1'
	IF	__DEBUG_MALLOC
	tst.l	d0
	bne.s	*+4
	illegal
	ENDC	; __DEBUG_MALLOC
	IF	__DEBUG_MALLOC_CANARIES
	tst.l	d0
	bne.s	*+6
	addq.l	#4,sp
	bra.s	.\@
	move.l	d0,a0		; put canaries at the begining
	move.l	#'CANA',(a0)+
	move.l	#'RY1'<<8,(a0)+
	move.l	(sp),(a0)+	; including original size
	move.l	#'RY2!',(a0)+
	add.l	(sp),a0		; put canaries at the end
	move.l	#'CANA',(a0)+
	move.l	#'RY3'<<8,(a0)+
	move.l	(sp)+,(a0)+	; including original size
	move.l	#'RY4!',(a0)+
	add.l	#16,d0		; fake the real adress of bloc
.\@
	ENDC	; __DEBUG_MALLOC_CANARIES
	ENDC	; \1 = "#-1"
	endm
	
Fdup	macro
	move.w	\1,-(sp)
	move.w	#69,-(sp)
	trap	#1
	addq.l	#4,sp
	endm
	
Fforce	macro
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#70,-(sp)
	trap	#1
	addq.l	#6,sp
	endm
	
Dgetpath	macro
	IFC	'\2','#0'
	clr.w	-(sp)
	ELSE
	move.w	\2,-(sp)
	ENDC
	pea	\1
	move.w	#71,-(sp)
	trap	#1
	addq.l	#8,sp
	endm
	
Malloc	macro
	IFNC	'\1','#-1'
	IF	__DEBUG_MALLOC_CANARIES
	move.l	\1,-(sp)	; remember original size
	ENDC	; __DEBUG_MALLOC_CANARIES
	ENDC	; \1 = "#-1"
	IFC	'\1','#-1'
	pea	-1.w
	ELSE
	move.l	\1,-(sp)
	ENDC
	IFNC	'\1','#-1'
	IF	__DEBUG_MALLOC_CANARIES
	add.l	#32,(sp)	 ; allocate size+32
	ENDC	; __DEBUG_MALLOC_CANARIES
	ENDC	; \1 = "#-1"
	move.w	#72,-(sp)
	trap	#1
	addq.l	#6,sp
	IFNC	'\1','#-1'
	IF	__DEBUG_MALLOC
	tst.l	d0
	bne.s	*+4
	illegal
	ENDC	; __DEBUG_MALLOC
	IF	__DEBUG_MALLOC_CANARIES
	tst.l	d0
	bne.s	*+6
	addq.l	#4,sp
	bra.s	.\@
	move.l	d0,a0		; put canaries at the begining
	move.l	#'CANA',(a0)+
	move.l	#'RY1'<<8,(a0)+
	move.l	(sp),(a0)+	; including original size
	move.l	#'RY2!',(a0)+
	add.l	(sp),a0		; put canaries at the end
	move.l	#'CANA',(a0)+
	move.l	#'RY3'<<8,(a0)+
	move.l	(sp)+,(a0)+	; including original size
	move.l	#'RY4!',(a0)+
	add.l	#16,d0		; fake the real adress of bloc
.\@
	ENDC	; __DEBUG_MALLOC_CANARIES
	ENDC	; \1 = "#-1"
	endm
	
Mfree	macro
	move.l	\1,-(sp)
	IF	__DEBUG_MALLOC_CANARIES
	sub.l	#16,(sp)	; get back the real adress of bloc
	move.l	(sp),a0
	cmp.l	#'CANA',(a0)+	; test canaries at begining of bloc
	beq.s	*+4
	illegal
	cmp.l	#'RY1'<<8,(a0)+
	beq.s	*+4
	illegal
	cmp.l	#'RY2!',4(a0)
	beq.s	*+4
	illegal
	add.l	(a0),a0		; get the size and go to the end
	addq.l	#8,a0
	cmp.l	#'CANA',(a0)+	; test canaries at end of bloc
	beq.s	*+4
	illegal
	cmp.l	#'RY3'<<8,(a0)+
	beq.s	*+4
	illegal
	cmp.l	#'RY4!',4(a0)
	beq.s	*+4
	illegal
	ENDC	; __DEBUG_MALLOC_CANARIES
	move.w	#73,-(sp)
	trap	#1
	addq.l	#6,sp
	IF	__DEBUG_MFREE
	tst.l	d0
	beq.s	.\@
	illegal
.\@
	ENDC
	endm

Mshrink	macro
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	clr.w	-(sp)
	move.w	#74,-(sp)
	trap	#1
	lea	12(sp),sp
	endm
	
Pexec	macro
	pea	\4
	pea	\3
	pea	\2
	move.w	\1,-(sp)
	move.w	#75,-(sp)
	trap	#1
	lea	16(sp),sp
	endm
	
Pterm	macro
	move.w	\1,-(sp)
	move.w	#76,-(sp)
	trap	#1
	addq.l	#4,sp
	endm
	
Fsfirst	macro
	IFC	'\2','#0'
	clr.w	-(sp)
	ELSE
	move.w	\2,-(sp)
	ENDC
	pea	\1
	move.w	#78,-(sp)
	trap	#1
	addq.l	#8,sp
	endm
	
Fsnext	macro
	move.w	#79,-(sp)
	trap	#1
	addq.l	#2,sp
	endm
		
Frename	macro
	pea	\2
	pea	\1
	clr.w	-(sp)
	move.w	#86,-(sp)
	trap	#1
	lea	12(sp),sp
	endm
	
Fdatime	macro
	move.w	\3,-(sp)
	move.w	\2,-(sp)
	pea	\1
	move.w	#87,-(sp)
	trap	#1
	lea	10(sp),sp
	endm
	