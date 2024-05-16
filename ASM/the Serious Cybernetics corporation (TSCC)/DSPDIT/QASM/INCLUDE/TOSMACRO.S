;---Tos Macro
*** Fonctions GEMDOS
Pterm0	macro
	clr.w	-(a7)
	trap	#1
	endm
Cconin	macro
	move.w	#1,-(a7)
	trap	#1
	addq.l	#2,a7
	endm
Cconout	macro
	move.w	\1,-(a7)
	move.w	#2,-(a7)
	trap	#1
	addq.l	#4,a7
	endm
Cauxin	macro
	move.w	#3,-(a7)
	trap	#1
	addq.l	#2,a7
	endm
Cauxout	macro
	move.w	\1,-(a7)
	move.w	#4,-(a7)
	trap	#1
	addq.l	#4,a7
	endm
Cprnout	macro
	move.w	\1,-(a7)
	move.w	#5,-(a7)
	trap	#1
	addq.l	#4,a7
	endm
Crawio	macro
	move.w	\1,-(a7)
	move.w	#6,-(a7)
	trap	#1
	addq.l	#4,a7
	endm
Crawcin	macro
	move.w	#7,-(a7)
	trap	#1
	addq.l	#2,a7
	endm
Cnecin	macro
	move.w	#8,-(a7)
	trap	#1
	addq.l	#2,a7
	endm
Cconws	macro
	move.l	\1,-(a7)
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	endm
Cconrs	macro
	move.l	\1,-(a7)
	move.w	#$a,-(a7)
	trap	#1
	addq.l	#6,a7
	endm
Cconis	macro
	move.w	#$b,-(a7)
	trap	#1
	addq.l	#2,a7
	endm
Dsetdrv	macro
	move.w	\1,-(a7)
	move.w	#$e,-(a7)
	trap	#1
	addq.l	#4,a7
	endm
Cconos	macro
	move.w	#10,-(a7)
	trap	#1
	addq.l	#2,a7
	endm
Cprnos	macro
	move.w	#$11,-(a7)
	trap	#1
	addq.l	#2,a7
	endm
Cauxis	macro
	move.w	#$12,-(a7)
	trap	#1
	addq.l	#2,a7
	endm
Cauxos	macro
	move.w	#$13,-(a7)
	trap	#1
	addq.l	#2,a7
	endm
Dgetdrv	macro
	move.w	#$19,-(a7)
	trap	#1
	addq.l	#2,a7
	endm
Fsetdta	macro
	move.l	\1,-(a7)
	move.w	#$1a,-(a7)
	trap	#1
	addq.l	#6,a7
	endm
Super0	macro
	move.l	\1,-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	endm
Tgetdate	macro
	move.w	#$2a,-(a7)
	trap	#1
	addq.l	#2,a7
	endm
Tsetdate	macro
	move.w	\1,-(a7)
	move.w	#$2a,-(a7)
	trap	#1
	addq.l	#4,a7
	endm
Tgettime	macro
	move.w	#$2c,-(a7)
	trap	#1
	addq.l	#2,a7
	endm
Tsettime	macro
	move.w	\1,-(a7)
	move.w	#$2d,-(a7)
	trap	#1
	addq.l	#4,a7
	endm
Fgetdta	macro
	move.w	#$2f,-(a7)
	trap	#1
	addq.l	#2,a7
	endm
Sversion	macro
	move.w	#$30,-(a7)
	trap	#1
	addq.l	#2,a7
	endm
Ptermres	macro
	move.w	\1,-(a7)
	move.l	\2,-(a7)
	move.w	#$31,-(a7)
	trap	#1
	endm
Dfree	macro
	move.w	\1,-(a7)
	move.l	\2,-(a7)
	move.w	#$36,-(a7)
	trap	#1
	addq.l	#8,a7
	endm
Dcreate	macro
	move.l	\1,-(a7)
	move.w	#$39,-(a7)
	trap	#1
	addq.l	#6,a7
	endm
Ddelete	macro
	move.l	\1,-(a7)
	move.w	#$3a,-(a7)
	trap	#1
	addq.l	#6,a7
	endm
Dsetpath	macro
	move.l	\1,-(a7)
	move.w	#$3b,-(a7)
	trap	#1
	addq.l	#6,a7
	endm
Fcreate	macro
	move.w	\1,-(a7)
	move.l	\2,-(a7)
	move.w	#$3c,-(a7)
	trap	#1
	addq.l	#8,a7
	endm
Fopen	macro
	move.w	\1,-(a7)
	move.l	\2,-(a7)
	move.w	#$3d,-(a7)
	trap	#1
	addq.l	#8,a7
	endm
Fclose	macro
	move.w	\1,-(a7)
	move.w	#$3e,-(a7)
	trap	#1
	addq.l	#4,a7
	endm
Fread	macro
	move.l	\1,-(a7)
	move.l	\2,-(a7)
	move.w	\3,-(a7)
	move.w	#$3f,-(a7)
	trap	#1
	lea	12(a7),a7
	endm
Fwrite	macro
	move.l	\1,-(a7)
	move.l	\2,-(a7)
	move.w	\3,-(a7)
	move.w	#$40,-(a7)
	trap	#1
	lea	12(a7),a7
	endm
Fdelete	macro
	move.l	\1,-(a7)
	move.w	#$41,-(a7)
	trap	#1
	addq.l	#6,a7
	endm
Fseek	macro
	move.w	\1,-(a7)
	move.w	\2,-(a7)
	move.l	\3,-(a7)
	move.w	#$42,-(a7)
	trap	#1
	lea	10(a7),a7
	endm
Fattrib	macro
	move.w	\1,-(a7)
	move.w	\2,-(a7)
	move.l	\3,-(a7)
	move.w	#$43,-(a7)
	trap	#1
	lea	10(a7),a7
	endm
Fdup	macro
	move.w	\1,-(a7)
	move.w	#$45,-(a7)
	trap	#1
	addq.l	#4,a7
	endm
Fforce	macro
	move.w	\1,-(a7)
	move.w	\2,-(a7)
	move.w	#$46,-(a7)
	trap	#1
	addq.l	#6,a7
	endm
Dgetpath	macro
	move.w	\1,-(a7)
	move.l	\2,-(a7)
	move.w	#$47,-(a7)
	trap	#1
	addq.l	#8,a7
	endm
Malloc	macro
	move.l	\1,-(a7)
	move.w	#$48,-(a7)
	trap	#1
	addq.l	#6,a7
	endm
Mfree	macro
	move.l	\1,-(a7)
	move.w	#$49,-(a7)
	trap	#1
	addq.l	#6,a7
	endm
Mshrink	macro
	move.l	\1,-(a7)
	move.l	\2,-(a7)
	move.w	\3,-(a7)
	move.w	#$4a,-(sp)
	trap	#1
	lea	12(sp),sp
	endm
Mshrink2	macro
	move.l	4(a7),a3
	move.l	$c(a3),d0
	add.l	$14(a3),d0
	add.l	$1c(a3),d0
	add.l	#$200,d0
	move.l	d0,d1
	add.l	a3,d1
	and.l	#$fffffffe,d1
	move.l	d1,a7
	move.l	d0,-(sp)
	move.l	a3,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	lea	12(sp),sp
	endm
Pexec	macro
	move.l	\1,-(a7)
	move.l	\2,-(a7)
	move.l	\3,-(a7)
	move.w	\4,-(a7)
	move.w	#$4b,-(a7)
	trap	#1
	lea	16(a7),a7
	endm
Pterm	macro
	move.w	\1,-(a7)
	move.w	#$4c,-(a7)
	trap	#1
	endm
Fsfirst	macro
	move.w	\1,-(a7)
	move.l	\2,-(a7)
	move.w	#$4e,-(a7)
	trap	#1
	addq.l	#8,a7
	endm
Fsnext	macro
	move.w	#$4f,-(a7)
	trap	#1
	addq.l	#2,a7
	endm
Frename	macro
	move.l	\1,-(a7)
	move.l	\2,-(a7)
	clr.w	-(a7)
	move.w	#$56,-(a7)
	trap	#1
	lea	12(a7),a7
	endm
Fdatime	macro
	move.w	\1,-(a7)
	move.w	\2,-(a7)
	move.l	\3,-(a7)
	move.w	#$57,-(a7)
	trap	#1
	lea	10(a7),a7
	endm

*** fonctions XBIOS
Getrez	macro
	move.w	#4,-(a7)
	trap	#14
	addq.l	#2,a7
	endm
Physbase	macro
	move.w	#2,-(a7)
	trap	#14
	addq.l	#2,a7
	endm
Logbase	macro
	move.w	#3,-(a7)
	trap	#14
	addq.l	#2,a7
	endm
Setscreen	macro
	move.w	\1,-(a7)
	move.l	\2,-(a7)
	move.l	\3,-(a7)
	move.w	#5,-(a7)
	trap	#14
	lea	12(a7),a7
	endm
Setpalette	macro
	move.l	\1,-(a7)
	move.w	#6,-(a7)
	trap	#14
	addq.l	#6,a7
	endm
Vsync	macro
	move.w	#$25,-(a7)
	trap	#14
	addq.l	#2,a7
	endm
*** Fontions XBIOS Etendu du Falcon 030
Setscreen2	macro
	move.w	\1,-(a7)
	move.w	\2,-(a7)
	move.l	\3,-(a7)
	move.l	\4,-(a7)
	move.w	#5,-(a7)
	trap	#14
	lea	14(a7),a7
	endm
Vsetmode	macro
	move.w	\1,-(a7)
	move.w	#88,-(a7)
	trap	#14
	addq.l	#4,a7
	endm
Vgetsize	macro
	move.w	\1,-(a7)
	move.w	#91,-(a7)
	trap	#14
	addq.l	#4,a7
	endm
VsetRGB	macro
	move.l	\1,-(a7)
	move.w	\2,-(a7)
	move.w	\3,-(a7)
	move.w	#93,-(a7)
	trap	#14
	lea	10(a7),a7
	endm	