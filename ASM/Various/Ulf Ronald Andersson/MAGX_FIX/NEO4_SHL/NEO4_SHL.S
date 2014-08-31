;----------------------------------------------------------------------------
; File name:	NEO4_SHL.S			Revision date:	1994.10.12
; Created by:	Ulf Ronald Andersson		Creation date:	1994.10.12
;----------------------------------------------------------------------------
;Remarks:
;
;	This program is needed to allow NeoDesk 4 to start from within the
;	normal 'NEODESK4' folder, instead of starting from 'current dir'.
;
;	When MagiX starts a program as replacement shell (#_SHL command)
;	the default path is not (as it should) set to be that of the shell.
;	Instead the latest path remains default, which will be the #_APP
;	path or, if no #_APP path is used, the root directory of boot drive.
;
;	NEO4_SHL.PRG simply alters the default path to \NEODESK4\ on the
;	boot drive, so that all NeoDesk files can remain in that folder.
;
;	NEO4_SHL.PRG should be installed last in the #_APP folder or, if no
;	#_APP folder is used, it should instead be last in the AUTO folder.
;
;----------------------------------------------------------------------------
;
	INCLUDE	URAn_SYS.S
	INCLUDE	URAn_DOS.S
;
;----------------------------------------------------------------------------
;
start:
	move.l	4(sp),a5
	lea	stack_end(pc),sp
	move.l	a5,basepage_p
	lea	bss_end(pc),a4
	sub.l	a5,a4
	gemdos	Mshrink,!,(a5),a4
	gemdos	Super,!
	move.l	d0,-(sp)
	move	(_bootdev).w,boot_dev
	gemdos	Super,()
	move	boot_dev(pc),d0
	add.b	d0,neo4_path_s
	gemdos	Dsetdrv,d0
	gemdos	Dsetpath,neo4_path_s(pc)
	gemdos	Pterm0
;
;----------------------------------------------------------------------------
;
	section	data	;resident during init only
;
;----------------------------------------------------------------------------
;
neo4_path_s:
	dc.b	'A:\NEODESK4'
	dc.b	NUL
	even
;
;----------------------------------------------------------------------------
;
	section	bss	;resident during init only
;
;----------------------------------------------------------------------------
;
boot_dev:	ds.w	1
basepage_p:	ds.l	1
stackbase:	ds.l	128
stack_end:	ds.l	1
bss_end:
;
;----------------------------------------------------------------------------
	end
;----------------------------------------------------------------------------
;END of file:	NEO4_SHL.S
;----------------------------------------------------------------------------
