**********************************
* Constantes & structures GEMDOS *
**********************************
DTA	RSSTRUCT
reserved	rs.b	21
attrib		rs.b	1
time		rs.w	1
date		rs.w	1
length		rs.l	1
fname		rs.b	14
sizeof		rs	0
	RSEND

*****************
* Macros GEMDOS *
*****************

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
		IFC	'\1','#1'
		pea	1.w
		ELSE
		move.l	\1,-(sp)
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
	
FSEEK_BEGIN	equ	0
FSEEK_REL	equ	1
FSEEK_END	equ	2
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
	move.w	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#68,-(sp)
	trap	#1
	addq.l	#8,sp
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
	move.l	\1,-(sp)
	move.w	#72,-(sp)
	trap	#1
	addq.l	#6,sp
	endm
	
Mfree	macro
	move.l	\1,-(sp)
	move.w	#73,-(sp)
	trap	#1
	addq.l	#6,sp
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
	