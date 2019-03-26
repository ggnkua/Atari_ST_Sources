
Pterm0	MACRO
	clr.w	-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM	

Cconin	MACRO
	move.w	#1,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM	

Cconout	MACRO
	move.w	\1,-(sp)
	move.w	#2,-(sp)
	trap	#1
	addq.l	#4,sp
	ENDM	

Cauxin	MACRO
	move.w	#3,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM	

Cauxout	MACRO
	move.w	\1,-(sp)
	move.w	#4,-(sp)
	trap	#1
	addq.l	#4,sp
	ENDM	

Cprnout	MACRO
	move.w	\1,-(sp)
	move.w	#5,-(sp)
	trap	#1
	addq.l	#4,sp
	ENDM	

Crawio	MACRO
	move.w	\1,-(sp)
	move.w	#6,-(sp)
	trap	#1
	addq.l	#4,sp
	ENDM	

Crawcin	MACRO
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM	

Cnecin	MACRO
	move.w	#8,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM	

Cconws	MACRO
	move.l	\1,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM	

Cconrs	MACRO
	move.l	\1,-(sp)
	move.w	#10,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM	

Cconis	MACRO
	move.w	#11,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM	

Dsetdrv	MACRO
	move.w	\1,-(sp)
	move.w	#14,-(sp)
	trap	#1
	addq.l	#4,sp
	ENDM	

Cconos	MACRO
	move.w	#16,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM	

Cprnos	MACRO
	move.w	#17,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM	

Cauxis	MACRO
	move.w	#18,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM	

Cauxos	MACRO
	move.w	#19,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM	

Dgetdrv	MACRO
	move.w	#25,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM	

Fsetdta	MACRO
	move.l	\1,-(sp)
	move.w	#26,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM	

Super	MACRO
	move.l	\1,-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM	

Tgetdate	MACRO
	move.w	#42,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM	

Tsetdate	MACRO
	move.w	\1,-(sp)
	move.w	#43,-(sp)
	trap	#1
	addq.l	#4,sp
	ENDM	

Tgettime	MACRO
	move.w	#44,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM	

Tsettime	MACRO
	move.w	\1,-(sp)
	move.w	#45,-(sp)
	trap	#1
	addq.l	#4,sp
	ENDM	

Fgetdta	MACRO
	move.w	#47,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM	

Sversion	MACRO
	move.w	#48,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM	

Ptermres	MACRO
	move.w	\1,-(sp)
	move.l	\2,-(sp)
	move.w	#49,-(sp)
	trap	#1
	addq.l	#8,sp
	ENDM

Dfree	MACRO
	move.w	\1,-(sp)
	move.l	\2,-(sp)
	move.w	#54,-(sp)
	trap	#1
	addq.l	#8,sp
	ENDM

Dcreate	MACRO
	move.w	#57,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM

Ddelete	MACRO
	move.l	\1,-(sp)
	move.w	#58,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM

Dsetpath	MACRO
	move.l	#\1,-(sp)
	move.w	#59,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM

Fcreate	MACRO
	move.w	\1,-(sp)
	move.l	\2,-(sp)
	move.w	#60,-(sp)
	trap	#1
	addq.l	#8,sp
	ENDM

Fopen	MACRO
	move.w	\1,-(sp)
	move.l	\2,-(sp)
	move.w	#61,-(sp)
	trap	#1
	addq.l	#8,sp
	ENDM

Fclose	MACRO
	move.w	\1,-(sp)
	move.w	#62,-(sp)
	trap	#1
	addq.l	#4,sp
	ENDM

Fread	MACRO
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	move.w	\3,-(sp)
	move.w	#63,-(sp)
	trap	#1
	lea	12(sp),sp
	ENDM

Fwrite	MACRO
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	move.w	\3,-(sp)
	move.w	#64,-(sp)
	trap	#1
	lea	12(sp),sp
	ENDM

Fdelete	MACRO
	move.l	\1,-(sp)
	move.w	#65,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM

Fseek	MACRO
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.l	\3,-(sp)
	move.w	#66,-(sp)
	trap	#1
	lea	10(sp),sp
	ENDM

Fattrib	MACRO
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.l	\3,-(sp)
	move.w	#67,-(sp)
	trap	#1
	lea	10(sp),sp
	ENDM

Fdup	MACRO
	move.w	\1,-(sp)
	move.w	#69,-(sp)
	trap	#1
	addq.l	#4,sp
	ENDM

Fforce	MACRO
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.w	#70,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM

Dgetpath	MACRO
	move.w	\1,-(sp)
	move.l	\2,-(sp)
	move.w	#71,-(sp)
	trap	#1
	addq.l	#8,sp
	ENDM

Malloc	MACRO
	move.l	\1,-(sp)
	move.w	#72,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM

Mfree	MACRO
	move.l	\1,-(sp)
	move.w	#73,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM

Mshrink	MACRO
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	clr.w	-(sp)
	move.w	#74,-(sp)
	trap	#1
	lea	12(sp),sp
	ENDM

Pexec	MACRO
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	move.l	\3,-(sp)
	move.w	\4,-(sp)
	move.w	#75,-(sp)
	trap	#1
	lea	16(sp),sp
	ENDM

Pterm	MACRO
	move.w	\1,-(sp)
	move.w	#76,-(sp)
	trap	#1
	ENDM

Fsfirst	MACRO
	move.w	\1,-(sp)
	move.l	\2,-(sp)
	move.w	#78,-(sp)
	trap	#1
	addq.l	#8,sp
	ENDM

Fsnext	MACRO
	move.w	#79,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM

Frename	MACRO
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	move.w	#0,-(sp)
	move.w	#86,-(sp)
	trap	#1
	lea	12(sp),sp
	ENDM

Fdatime	MACRO
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.l	\3,-(sp)
	move.w	#87,-(sp)
	trap	#1
	lea	10(sp),sp
	ENDM