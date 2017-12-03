;	MACROs pour les appels GEMDOS
;	ecris par G.Audoly
;	je ne prends aucunement la responsabilite de degats pouvant etres
;	causes par ces MACROs

;	IFND gemdos
;gemdos

spc=32

;	IFNE 1
;
;ALIGN:	MACRO
;	ds.w	(\1-(*-ref)+((*-ref)/\1*\1))/2
;	ENDM
;ALIGN2:	MACRO
;	ds.b	\1-(*-ref)+((*-ref)/\1*\1)
;	ENDM
;	ENDC
	
Cconin:	MACRO
	move.w	#1,-(sp)
	trap	#1
	addq.w	#2,sp
	ENDM
		
Cconis:	MACRO
	move.w	#$b,-(sp)
	trap	#1
	addq.w	#2,sp
	ENDM
		
Cconout:	MACRO
	move.w	\1,-(sp)
	move.w	#2,-(sp)
	trap	#1
	addq.w	#4,sp
	ENDM

Cconrs:	MACRO
	move.l	\1,-(sp)
	move.w	#$a,-(sp)
	trap	#1
	addq.w	#6,sp
	ENDM

Cconrs2:	MACRO
	pea.l	\1
	move.w	#$a,-(sp)
	trap	#1
	addq.w	#6,sp
	ENDM

Cconws:	MACRO
	move.l	\1,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.w	#6,sp
	ENDM

Cconws2:	MACRO
	pea.l	\1
	move.w	#9,-(sp)
	trap	#1
	addq.w	#6,sp
	ENDM

Cnecin:	MACRO
	move.w	#8,-(sp)
	trap	#1
	addq.w	#2,sp
	ENDM

Cprnout:	MACRO
	move.w	\1,-(sp)
	move.w	#5,-(sp)
	trap	#1
	addq.w	#4,sp
	ENDM

Crawcin:	MACRO
	move.w	#7,-(sp)
	trap	#1
	addq.w	#2,sp
	ENDM

Dcreate:	MACRO		;#path.L
	move.l	\1,-(sp)
	move.w	#$39,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM
	
Dcreate2:	MACRO		;path.L
	pea.l	\1
	move.w	#$39,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM
	
Ddelete:	MACRO		;#dname.L
	move.l	\1,-(sp)
	move.w	#$3a,-(sp)
	trap	#1
	addq.w	#6,sp
	ENDM		error.L

Ddelete2:	MACRO		;dname.L
	pea.l	\1
	move.w	#$3a,-(sp)
	trap	#1
	addq.w	#6,sp
	ENDM		error.L

Dgetdrive:	MACRO
	move.w	#$19,-(sp)
	trap	#1
	addq.w	#2,sp
	ENDM

Dgetdrv:	MACRO
	Dgetdrive
	ENDM

Dgetpath:	MACRO		;#*buffer.L, #drive.W
	move.w	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#$47,-(sp)
	trap	#1
	addq.w	#8,sp
	ENDM
	
Dgetpath2:	MACRO		;*buffer.L, #drive.W
	move.w	\2,-(sp)
	pea.l	\1
	move.w	#$47,-(sp)
	trap	#1
	addq.w	#8,sp
	ENDM
	
Dsetdrive:	MACRO
	move.w	\1,-(sp)
	move.w	#$e,-(sp)
	trap	#1
	addq.w	#4,sp
	ENDM

Dsetdrv:	MACRO
	Dsetdrive	\1
	ENDM

Dsetpath:	MACRO		;#*path.L
	move.l	\1,-(sp)
	move.w	#$3b,-(sp)
	trap	#1
	addq.w	#6,sp
	ENDM
	
Dsetpath2:	MACRO		;*path.L
	pea.l	\1
	move.w	#$3b,-(sp)
	trap	#1
	addq.w	#6,sp
	ENDM
	
Fcreate:	MACRO		;#*fname.L,#attr.W
	move.w	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#$3c,-(sp)
	trap	#1
	addq.w	#8,sp
	ENDM		;error.L / handle.W

Fcreate2:	MACRO		;*fname.L,#attr.W
	move.w	\2,-(sp)
	pea.l	\1
	move.w	#$3c,-(sp)
	trap	#1
	addq.w	#8,sp
	ENDM		;error.L / handle.W
	
Fclose:	MACRO		;#handle.W
	move.w	\1,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.w	#4,sp
	ENDM		;error.L
	
Fdatime:	MACRO		;#timeptr.L,#handle.W,#wflag.W
	move.w	\3,-(sp)
	move.w	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#$57,-(sp)
	trap	#1
	lea.l	10(sp),sp
	ENDM
	
Fdatime2:	MACRO		;timeptr.L,#handle.W,#wflag.W
	move.w	\3,-(sp)
	move.w	\2,-(sp)
	pea.l	\1
	move.w	#$57,-(sp)
	trap	#1
	lea.l	10(sp),sp
	ENDM
	
Fdelete:	MACRO		;#fname.L
	move.l	\1,-(sp)
	move.w	#$41,-(sp)
	trap	#1
	addq.w	#6,sp
	ENDM		;error.L

Fdelete2:	MACRO		;fname.L
	pea.l	\1
	move.w	#$41,-(sp)
	trap	#1
	addq.w	#6,sp
	ENDM		;error.L

Fgetdta:	MACRO
	move.w	#$2f,-(sp)
	trap	#1
	addq.w	#2,sp
	ENDM		;adresse.L
	
Fopen:	MACRO		;#*fich.L,#type.W
	move.w	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#$3d,-(sp)
	trap	#1
	addq.w	#8,sp
	ENDM		;error.L / handle.W

Fopen2:	MACRO		;*fich.L,#type.W
	move.w	\2,-(sp)
	pea.l	\1
	move.w	#$3d,-(sp)
	trap	#1
	addq.w	#8,sp
	ENDM		;error.L / handle.W

Fread:	MACRO		;#handle.W, #count.L, #*buffer.L
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	lea.l	12(sp),sp
	ENDM		;error.L / nb.L

Fread2:	MACRO		;#handle.W, #count.L, *buffer.L
	pea.l	\3
	move.l	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	lea.l	12(sp),sp
	ENDM		;error.L / nb.L
	
Frename:	MACRO		;#old_name.L,#new_name.L
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	clr.w	-(sp)
	move.w	#$56,-(sp)
	trap	#1
	lea.l	12(sp),sp
	ENDM
	
Frename2:	MACRO		;#old_name.L,#new_name.L
	pea.l	\2
	pea.l	\1
	clr.w	-(sp)
	move.w	#$56,-(sp)
	trap	#1
	lea.l	12(sp),sp
	ENDM
	
Fseek:	MACRO		;#offset.L, #handle.W, #seekmode.W
	move.w	\3,-(sp)
	move.w	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#$42,-(sp)
	trap	#1
	lea.l	10(sp),sp
	ENDM		;error.L

Fsetdta:	MACRO		;#*fdta.L
	move.l	\1,-(sp)
	move.w	#$1a,-(sp)
	trap	#1
	addq.w	#6,sp
	ENDM

Fsetdta2:	MACRO		;*fdta.L
	pea.l	\1
	move.w	#$1a,-(sp)
	trap	#1
	addq.w	#6,sp
	ENDM

Fsfirst:	MACRO		;#*fname.L,#attr.W
	move.w	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#$4e,-(sp)
	trap	#1
	addq.w	#8,sp
	ENDM		;err.W

Fsfirst2:	MACRO		;*fname.L,#attr.W
	move.w	\2,-(sp)
	pea.l	\1
	move.w	#$4e,-(sp)
	trap	#1
	addq.w	#8,sp
	ENDM		;err.W

Fsnext:	MACRO
	move.w	#$4f,-(sp)
	trap	#1
	addq.w	#2,sp
	ENDM

Fwrite:	MACRO		;#handle.W,#count.L,#*buffer.L
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	lea.l	12(sp),sp
	ENDM		;error.L / nb.L
	
Fwrite2:	MACRO		;#handle.W,#count.L,*buffer.L
	pea.l	\3
	move.l	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	lea.l	12(sp),sp
	ENDM		;error.L / nb.L

Malloc:	MACRO
	move.l	\1,-(sp)
	move.w	#$48,-(sp)
	trap	#1
	addq.w	#6,sp
	ENDM
	
Mfree:	MACRO
	move.l	\1,-(sp)
	move.w	#$49,-(sp)
	trap	#1
	addq.w	#6,sp
	ENDM

Mfree2:	MACRO
	pea.l	\1
	move.w	#$49,-(sp)
	trap	#1
	addq.w	#6,sp
	ENDM

Mshrink:	MACRO
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	lea.l	12(sp),sp
	ENDM

Pexec:	MACRO
	move.l	\4,-(sp)
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	lea.l	16(sp),sp
	ENDM

Pexec2:	MACRO
	pea.l	\4
	pea.l	\3
	pea.l	\2
	move.w	\1,-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	lea.l	16(sp),sp
	ENDM

Printline:	MACRO
	Cconws	\1
	ENDM
		
Printline2: MACRO
	Cconws2	\1
	ENDM
		
Pterm:	MACRO
	move.w	\1,-(sp)
	move.w	#$4c,-(sp)
	trap	#1
	ENDM	
	
Ptermres:	MACRO		;#taille.L,#err.W
	move.w	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#$31,-(sp)
	trap	#1
	ENDM

Readline:	MACRO
	Cconrs	\1
	ENDM
		
Readline2: MACRO
	Cconrs2	\1
	ENDM
		
Super1:	MACRO
	move.l	\1,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.w	#6,sp
	ENDM
	
Super0:	MACRO
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.w	#6,sp
	ENDM

Super2:	MACRO
	pea.l	\1
	move.w	#$20,-(sp)
	trap	#1
	addq.w	#6,sp
	ENDM
	
Term:	MACRO
	clr.l	-(sp)
	trap	#1
	ENDM
	
Tgetdate:	MACRO
	move.w	#$2a,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM		;d0=date.W

Tsetdate:	MACRO		;#date.W
	move.w	\1,-(sp)
	move.w	#$2b,-(sp)
	trap	#1
	addq.l	#4,sp
	ENDM

Tgettime:	MACRO
	move.w	#$2c,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM		;d0=time.W

Tsettime:	MACRO		;#time.W
	move.w	\1,-(sp)
	move.w	#$2d,-(sp)
	trap	#1
	addq.l	#4,sp
	ENDM



;	ENDC
	
