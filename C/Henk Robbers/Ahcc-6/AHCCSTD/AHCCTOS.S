*	Created by TT-Digger V8
*	Mon May 21 12:57:38 2012

*	TEXT	4064 bytes, segment starts at L0
*	DATA	0 bytes
*	BSS	24 bytes, segment starts at U4064
*	FIXUPS	1232 bytes
*	NAMES	2128 bytes
*	names	285
*	External names not listed

#ifndef __AHCC__
#error Only AHCC can compile this file
#else

	XDEF	xbios,Xbtimer,DMAwrite,Vsync,DMAread,Talarm,Setprt,Super,Scrdmp,Ssbrk
	XDEF	Syield,Setexc,Rwabs,setbuffer,Random,setmontracks,settracks,Setcolor
	XDEF	setmode,Rsconf,setinterrupt,Sysconf,soundcmd,Settime,Supexec,unlocksnd
	XDEF	Setscreen,Setpalette,Vsetmode,Pwait,Pterm,Pkill,Prtblk,Pumask,Pvfork
	XDEF	Pfork,Pmsg,Pause,Pnice,VgetSize,Pexec,Tgettime,Tsettime,Physbase
	XDEF	VsetSync,VsetMask,Pusrval,VgetRGB,VsetRGB,Tgetdate,Tsetdate,Sversion
	XDEF	sndstatus,Prusage,Tickcal,Protobt,Mfpint,Midiws,Pdomain,Mfree,Puntaes
	XDEF	Pwait3,Malloc,Psigsetmask,Psigreturn,Pterm0,Psigpause,Psigpending
	XDEF	Psignal,Metainit,Psigaction,Psetuid,Pgetuid,Psigblock,Psetpgrp,Pgetpgrp
	XDEF	Pgetppid,Keytbl,Pgetpid,Psetlimit,Ptermres,mon_type,Kbrate,Prenice
	XDEF	Psetgid,Pgetgid,Pgetegid,Pgeteuid,Pwaitpid,Psemaphore,Offgibit,Ongibit
	XDEF	Ikbdws,Kbshift,Iorec,Mshrink,Getrez,gemdos,gpio,Maddalt,Mediach,Mxalloc
	XDEF	locksnd,Logbase,Jenabint,Fsnext,Flopwr,Fxattr,Getbpb,Getmpb,Fdup,Fchown
	XDEF	Fopen,Fcntl,Flink,Flock,Fseek,Fsymlink,Jdisint,Fclose,Fforce,Fwrite
	XDEF	Fpipe,Floprd,Fchmod,Fread,Gettime,Foutstat,Kbdvbase,Initmous,Fattrib
	XDEF	Drvmap,Fputchar,Flopver,Dcntl,Dlock,Floprate,Finstat,Dfree,Cconws
	XDEF	Cauxis,Cauxos,Cconis,Cconos,Cconrs,Cprnos,devconnect,Fcreate,Crawio
	XDEF	Cauxin,Cconin,Cnecin,Flopfmt,Dosound,bios,Cauxout,Bconin,dsptristate
	XDEF	Dopendir,Fmidipipe,Fsfirst,Cprnout,Dcreate,Dclosedir,Cconout,Cursconf
	XDEF	Fselect,Giaccess,Freadlink,Fdelete,Fgetdta,Fsetdta,Dsp_SetVectors
	XDEF	Dsp_Unlock,Fgetchar,Dsp_Reserve,Dsp_RequestUniqueAbility,Dsp_TriggerHC
	XDEF	Frename,Dsp_RunSubroutine,Dsp_RemoveInterrupts,Bcostat,Dsp_OutStream
	XDEF	Dsp_MultBlocks,Bconout,Bconstat,Fdatime,Dsp_InqSubrAbility,Bioskeys
	XDEF	Dsp_LodToBinary,Dsp_HStat,Bconmap,Dsp_Lock,Dsp_LoadProg
	XDEF	Dsp_LoadSubroutine,Dsp_GetProgAbility,Dsp_GetWordSize
	XDEF	Dsp_FlushSubroutines,Dgetpath,Dsetpath,Dsp_ExecBoot,Dsp_ExecProg
	XDEF	Dsp_IOStream,Dsp_InStream,Dsp_BlkBytes,Dsp_BlkWords,Dsp_BlkUnpacked
	XDEF	Dsp_BlkHandShake,Dsp_Available,Drewinddir,Dgetdrv,Dsetdrv,Dsp_Hf3
	XDEF	Dsp_Hf2,Dsp_DoBlock,Dsp_Hf1,Dsp_Hf0,Dreaddir,Ddelete,EgetShift
	XDEF	EsetShift,EsetSmear,EgetPalette,EsetPalette,Blitmode,Dpathconf,buffptr
	XDEF	EsetGray,EsetColor,EsetBank,buffoper,Crawcin

	BSS

module U4064

	ds.b	4
endmod
module U4068

	ds.b	4
endmod
module U4072

	ds.b	4
endmod
module U4076

	ds.b	4
endmod
module U4080

	ds.b	4
endmod
module U4084

	ds.b	4
U4088:
endmod
	TEXT

/*
module dontuse
	xsave.l	d0/a0/a2
	xrest.l d0/a0/a2
	movem.l d0/a0/a2, -(sp)
	movem.l (sp)+, d0/a0/a2
endmod
*/

module gemdos
	move.l	(a7)+,U4064.l
	move.l	a2,U4068.l
	trap	#1		; Gemdos
	movea.l	U4068.l,a2
	movea.l	U4064.l,a1
	jmp	(a1)

endmod
module bios

	move.l	(a7)+,U4072.l
	move.l	a2,U4076.l
	trap	#13		; Bios
	movea.l	U4076.l,a2
	movea.l	U4072.l,a1
	jmp	(a1)

endmod
module xbios

	move.l	(a7)+,U4080.l
	move.l	a2,U4084.l
	trap	#14		; Xbios
	movea.l	U4084.l,a2
	movea.l	U4080.l,a1
	jmp	(a1)

endmod
module  Tickcal
	pea	(a2)
	move	#6,-(a7)	; Tickcal
	trap	#13		; Bios
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Setexc

	xsave.l	d0/a0/a2
	move	#5,(a7)		; Setexc
	trap	#13		; Bios
	addq	#8,a7
	movea.l	d0,a0
	movea.l	(a7)+,a2
	rts

endmod
module Rwabs

	pea	(a2)
	move.l	10(a7),-(a7)
	move	12(a7),-(a7)
	move	d2,-(a7)
	move	d1,-(a7)
	pea	(a0)
	move	d0,-(a7)
	move	#4,-(a7)	; Rwabs
	trap	#13		; Bios
	lea 	18(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Mediach

	pea	(a2)
	move	d0,-(a7)
	move	#9,-(a7)	; Mediach
	trap	#13		; Bios
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module Kbshift

	pea	(a2)
	move	d0,-(a7)
	move	#11,-(a7)	; Kbshift
	trap	#13		; Bios
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module Getmpb

	pea	(a2)
	pea	(a0)
	clr	-(a7)
	trap	#13		; Bios
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module Getbpb

	pea	(a2)
	move	d0,-(a7)
	move	#7,-(a7)	; Getbpb
	trap	#13		; Bios
	addq	#4,a7
	movea.l	d0,a0
	movea.l	(a7)+,a2
	rts

endmod
module Drvmap

	pea	(a2)
	move	#10,-(a7)	; Drvmap
	trap	#13		; Bios
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Bcostat

	pea	(a2)
	move	d0,-(a7)
	move	#8,-(a7)	; Bcostat
	trap	#13		; Bios
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module Bconstat

	pea	(a2)
	move	d0,-(a7)
	move	#1,-(a7)	; Bconstat
	trap	#13		; Bios
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module Bconout

	pea	(a2)
	move	d1,-(a7)
	move	d0,-(a7)
	move	#3,-(a7)	; Bconout
	trap	#13		; Bios
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module Bconin

	pea	(a2)
	move	d0,-(a7)
	move	#2,-(a7)	; Bconin
	trap	#13		; Bios
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module Tsettime
	pea	(a2)
	move	d0,-(a7)
	move	#45,-(a7)	; Tsettime
	trap	#1		; Gemdos
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module Tsetdate

	pea	(a2)
	move	d0,-(a7)
	move	#43,-(a7)	; Tsetdate
	trap	#1		; Gemdos
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module Tgettime

	pea	(a2)
	move	#44,-(a7)	; Tgettime
	trap	#1		; Gemdos
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Tgetdate

	pea	(a2)
	move	#42,-(a7)	; Tgetdate
	trap	#1		; Gemdos
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Sversion

	pea	(a2)
	move	#48,-(a7)	; Sversion
	trap	#1		; Gemdos
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Super

	pea	(a2)
	pea	(a0)
	move	#32,-(a7)	; Super
	trap	#1		; Gemdos
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module Ptermres

	move	d1,-(a7)
	move.l	d0,-(a7)
	move	#49,-(a7)	; Ptermres
	trap	#1		; Gemdos
endmod
module Pterm0

	clr	-(a7)
	trap	#1		; Gemdos
endmod
module Pterm

	move	d0,-(a7)
	move	#76,-(a7)	; Pterm
	trap	#1		; Gemdos
endmod
module Mxalloc

	pea	(a2)
	move	d1,-(a7)
	move.l	d0,-(a7)
	move	#68,-(a7)	; MxAlloc
	trap	#1		; Gemdos
	addq	#8,a7
	movea.l	d0,a0
	movea.l	(a7)+,a2
	rts

endmod
module Mshrink

	pea	(a2)
	move.l	d1,-(a7)
	pea	(a0)
	move	d0,-(a7)
	move	#74,-(a7)	; Mshrink
	trap	#1		; Gemdos
	lea 	12(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Mfree

	pea	(a2)
	pea	(a0)
	move	#73,-(a7)	; Mfree
	trap	#1		; Gemdos
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module Malloc

	pea	(a2)
	move.l	d0,-(a7)
	move	#72,-(a7)	; Malloc
	trap	#1		; Gemdos
	addq	#6,a7
	movea.l	d0,a0
	movea.l	(a7)+,a2
	rts

endmod
module Maddalt

	pea	(a2)
	move.l	d0,-(a7)
	pea	(a0)
	move	#20,-(a7)	; MaddAlt
	trap	#1		; Gemdos
	lea 	10(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Fwrite

;	movem.l	d0-d1/a0/a2,-(a7)
	xsave.l	d0-d1/a0/a2
	move	#64,(a7)	; Fwrite
	trap	#1		; Gemdos
	lea 	12(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Fsetdta

	pea	(a2)
	pea	(a0)
	move	#26,-(a7)	; Fsetdta
	trap	#1		; Gemdos
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module Fseek

	pea	(a2)
	move	d2,-(a7)
	move	d1,-(a7)
	move.l	d0,-(a7)
	move	#66,-(a7)	; Fseek
	trap	#1		; Gemdos
	lea 	10(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Fread

;	movem.l	d0-d1/a0/a2,-(a7)
	xsave.l	d0-d1/a0/a2
	move	#63,(a7)	; Fread
	trap	#1		; Gemdos
	lea 	12(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Flock

	pea	(a2)
	move.l	8(a7),-(a7)
	move.l	d2,-(a7)
	move	d1,-(a7)
	move	d0,-(a7)
	move	#92,-(a7)	; Flock
	trap	#1		; Gemdos
	lea 	14(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Fgetdta

	pea	(a2)
	move	#47,-(a7)	; Fgetdta
	trap	#1		; Gemdos
	addq	#2,a7
	movea.l	d0,a0
	movea.l	(a7)+,a2
	rts

endmod
module Fforce

	pea	(a2)
	move	d1,-(a7)
	move	d0,-(a7)
	move	#70,-(a7)	; Fforce
	trap	#1		; Gemdos
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module Fdup

	pea	(a2)
	move	d0,-(a7)
	move	#69,-(a7)	; Fdup
	trap	#1		; Gemdos
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module Fdatime

	pea	(a2)
	move	d1,-(a7)
	move	d0,-(a7)
	pea	(a0)
	move	#87,-(a7)	; Fdatime
	trap	#1		; Gemdos
	lea 	10(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Fclose

	pea	(a2)
	move	d0,-(a7)
	move	#62,-(a7)	; Fclose
	trap	#1		; Gemdos
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module Dsetdrv

	pea	(a2)
	move	d0,-(a7)
	move	#14,-(a7)	; Dsetdrv
	trap	#1		; Gemdos
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module Dgetdrv

	pea	(a2)
	move	#25,-(a7)	; Dgetdrv
	trap	#1		; Gemdos
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Dfree

	pea	(a2)
	move	d0,-(a7)
	pea	(a0)
	move	#54,-(a7)	; Dfree
	trap	#1		; Gemdos
	addq	#8,a7
	movea.l	(a7)+,a2
	rts

endmod
module Crawio

	pea	(a2)
	move	d0,-(a7)
	move	#6,-(a7)	; Crawio
	trap	#1		; Gemdos
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module Crawcin

	pea	(a2)
	move	#7,-(a7)	; Crawcin
	trap	#1		; Gemdos
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Cprnout

	pea	(a2)
	move	d0,-(a7)
	move	#5,-(a7)	; Cprnout
	trap	#1		; Gemdos
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module Cprnos

	pea	(a2)
	move	#17,-(a7)	; Cprnos
	trap	#1		; Gemdos
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Cnecin

	pea	(a2)
	move	#8,-(a7)	; Cnecin
	trap	#1		; Gemdos
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Cconrs

	pea	(a2)
	pea	(a0)
	move	#10,-(a7)	; Cconrs
	trap	#1		; Gemdos
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module Cconout

	pea	(a2)
	move	d0,-(a7)
	move	#2,-(a7)	; Cconout
	trap	#1		; Gemdos
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module Cconos

	pea	(a2)
	move	#16,-(a7)	; Cconos
	trap	#1		; Gemdos
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Cconis

	pea	(a2)
	move	#11,-(a7)	; Cconis
	trap	#1		; Gemdos
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Cconin

	pea	(a2)
	move	#1,-(a7)	; Cconin
	trap	#1		; Gemdos
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Cauxout

	pea	(a2)
	move	d0,-(a7)
	move	#4,-(a7)	; Cauxout
	trap	#1		; Gemdos
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module Cauxos

	pea	(a2)
	move	#19,-(a7)	; Cauxos
	trap	#1		; Gemdos
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Cauxis

	pea	(a2)
	move	#18,-(a7)	; Cauxis
	trap	#1		; Gemdos
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Cauxin

	pea	(a2)
	move	#3,-(a7)	; Cauxin
	trap	#1		; Gemdos
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Syield

	pea	(a2)
	move	#255,-(a7)	; Syield
	trap	#1		; Gemdos
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Fpipe

	pea	(a2)
	pea	(a0)
	move	#256,-(a7)	; Fpipe
	trap	#1		; Gemdos
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module Fcntl

	pea	(a2)
	move	d2,-(a7)
	move.l	d1,-(a7)
	move	d0,-(a7)
	move	#260,-(a7)	; Fcntl
	trap	#1		; Gemdos
	lea 	10(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Finstat

	pea	(a2)
	move.l	d0,-(a7)
	move	#261,-(a7)	; FinStat
	trap	#1		; Gemdos
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module Foutstat

	pea	(a2)
	move.l	d0,-(a7)
	move	#262,-(a7)	; FoutStat
	trap	#1		; Gemdos
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module Fgetchar

	pea	(a2)
	move	d1,-(a7)
	move	d0,-(a7)
	move	#263,-(a7)	; FgetChar
	trap	#1		; Gemdos
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module Fputchar

	pea	(a2)
	move	d2,-(a7)
	move.l	d1,-(a7)
	move	d0,-(a7)
	move	#264,-(a7)	; FputChar
	trap	#1		; Gemdos
	lea 	10(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Pwait

	pea	(a2)
	move	#265,-(a7)	; Pwait
	trap	#1		; Gemdos
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Pnice

	pea	(a2)
	move	d0,-(a7)
	move	#266,-(a7)	; Pnice
	trap	#1		; Gemdos
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module Pgetpid

	pea	(a2)
	move	#267,-(a7)	; PgetPid
	trap	#1		; Gemdos
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Pgetppid

	pea	(a2)
	move	#268,-(a7)	; PgetPpid
	trap	#1		; Gemdos
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Pgetpgrp

	pea	(a2)
	move	#269,-(a7)	; PgetPgrp
	trap	#1		; Gemdos
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Psetpgrp

	pea	(a2)
	move	d1,-(a7)
	move	d0,-(a7)
	move	#270,-(a7)	; PsetPgrp
	trap	#1		; Gemdos
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module Pgetuid

	pea	(a2)
	move	#271,-(a7)	; PgetUid
	trap	#1		; Gemdos
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Psetuid

	pea	(a2)
	move	d0,-(a7)
	move	#272,-(a7)	; PsetUid
	trap	#1		; Gemdos
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module Pkill

	pea	(a2)
	move	d1,-(a7)
	move	d0,-(a7)
	move	#273,-(a7)	; Pkill
	trap	#1		; Gemdos
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module Psignal

	pea	(a2)
	pea	(a0)
	move	d0,-(a7)
	move	#274,-(a7)	; Psignal
	trap	#1		; Gemdos
	addq	#8,a7
	movea.l	d0,a0
	movea.l	(a7)+,a2
	rts

endmod
module Pvfork

	pea	(a2)
	move	#275,-(a7)	; PvFork
	trap	#1		; Gemdos
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Pgetgid

	pea	(a2)
	move	#276,-(a7)	; PgetGid
	trap	#1		; Gemdos
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Psetgid

	pea	(a2)
	move	d0,-(a7)
	move	#277,-(a7)	; PsetGid
	trap	#1		; Gemdos
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module Psigblock

	pea	(a2)
	move.l	d0,-(a7)
	move	#278,-(a7)	; PsigBlock
	trap	#1		; Gemdos
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module Psigsetmask

	pea	(a2)
	move.l	d0,-(a7)
	move	#279,-(a7)	; PsigSetMask
	trap	#1		; Gemdos
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module Pusrval

	pea	(a2)
	move.l	d0,-(a7)
	move	#280,-(a7)	; PusrVal
	trap	#1		; Gemdos
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module Pdomain

	pea	(a2)
	move	d0,-(a7)
	move	#281,-(a7)	; Pdomain
	trap	#1		; Gemdos
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module Psigreturn

	pea	(a2)
	move	#282,-(a7)	; PsigReturn
	trap	#1		; Gemdos
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Pfork

	pea	(a2)
	move	#283,-(a7)	; PFork
	trap	#1		; Gemdos
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Pwait3

	pea	(a2)
	pea	(a0)
	move	d0,-(a7)
	move	#284,-(a7)	; Pwait3
	trap	#1		; Gemdos
	addq	#8,a7
	movea.l	(a7)+,a2
	rts

endmod
module Fselect

	pea	(a2)
	pea	8(a7)
	pea	(a1)
	pea	(a0)
	move	d0,-(a7)
	move	#285,-(a7)	; Fselect
	trap	#1		; Gemdos
	lea 	16(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Prusage

	pea	(a2)
	pea	(a0)
	move	#286,-(a7)	; PrUsage
	trap	#1		; Gemdos
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module Psetlimit

	pea	(a2)
	move.l	d1,-(a7)
	move	d0,-(a7)
	move	#287,-(a7)	; PsetLimit
	trap	#1		; Gemdos
	addq	#8,a7
	movea.l	(a7)+,a2
	rts

endmod
module Talarm

	pea	(a2)
	move.l	d0,-(a7)
	move	#288,-(a7)	; Talarm
	trap	#1		; Gemdos
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module Pause

	pea	(a2)
	move	#289,-(a7)	; Pause
	trap	#1		; Gemdos
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Sysconf

	pea	(a2)
	move	d0,-(a7)
	move	#290,-(a7)	; SysConf
	trap	#1		; Gemdos
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module Psigpending

	pea	(a2)
	move	#291,-(a7)	; PsigPending
	trap	#1		; Gemdos
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Pmsg

;	movem.l	d0-d1/a0/a2,-(a7)
	xsave.l	d0-d1/a0/a2
	move	#293,(a7)	; Pmsg
	trap	#1		; Gemdos
	lea 	12(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Fmidipipe

	pea	(a2)
;	movem	d0-d2,-(a7)
	move	d2,-(a7)
	move	d1,-(a7)
	move	d0,-(a7)
	move	#294,(a7)	; FmidiPipe
	trap	#1		; Gemdos
	addq	#8,a7
	movea.l	(a7)+,a2
	rts

endmod
module Prenice

	pea	(a2)
	move	d1,-(a7)
	move	d0,-(a7)
	move	#295,(a7)	; Prenice
	trap	#1		; Gemdos
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module Drewinddir

	pea	(a2)
	move.l	d0,-(a7)
	move	#298,-(a7)	; DrewindDir
	trap	#1		; Gemdos
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module Dclosedir

	pea	(a2)
	move.l	d0,-(a7)
	move	#299,-(a7)	; DcloseDir
	trap	#1		; Gemdos
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module Pumask

	pea	(a2)
	move	d0,-(a7)
	move	#307,-(a7)	; Pumask
	trap	#1		; Gemdos
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module Psemaphore

;	movem.l	d0-d2/a2,-(a7)
	xsave.l	d0-d2/a2
	move	#308,(a7)	; Psemaphore
	trap	#1		; Gemdos
	lea 	12(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Dlock

	pea	(a2)
	move	d1,-(a7)
	move	d0,-(a7)
	move	#309,-(a7)	; Dlock
	trap	#1		; Gemdos
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module Psigpause

;	movem.l	d0/a2,-(a7)
	xsave.l	d0/a2
	move	#310,-(a7)	; PsigPause
	trap	#1		; Gemdos
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module Psigaction

;	movem.l	d0/a0-a2,-(a7)
	xsave.l	d0/a0-a2,-(a7)
	move	#311,(a7)	; PsigAction
	trap	#1		; Gemdos
	lea 	12(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Pgeteuid

	pea	(a2)
	move	#312,-(a7)	; PgeteUid
	trap	#1		; Gemdos
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Pgetegid

	pea	(a2)
	move	#313,-(a7)	; PgeteGid
	trap	#1		; Gemdos
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Pwaitpid

;	movem.l	d1/a0/a2,-(a7)
	xsave.l	d1/a0/a2
	move	d0,(a7)
	move	#314,-(a7)	; PwaitPid
	trap	#1		; Gemdos
	lea 	10(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module L1718

Pexec:
	pea	(a2)
	move.l	8(a7),-(a7)
	pea	(a1)
	pea	(a0)
	move	d0,-(a7)
	move	#75,-(a7)	; Pexec
	trap	#1		; Gemdos
	lea 	16(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Fsnext

	pea	(a2)
	move	#79,-(a7)	; Fsnext
	trap	#1		; Gemdos
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Fsfirst

	pea	(a2)
	move	d0,-(a7)
	pea	(a0)
	move	#78,-(a7)	; Fsfirst
	trap	#1		; Gemdos
	addq	#8,a7
	movea.l	(a7)+,a2
	rts

endmod
module Frename

;	movem.l	a0-a2,-(a7)
	xsave.l	a0-a2
	clr	-(a7)
	move	#86,-(a7)	; Frename
	trap	#1		; Gemdos
	lea 	12(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Fopen

	pea	(a2)
	move	d0,-(a7)
	pea	(a0)
	move	#61,-(a7)	; Fopen
	trap	#1		; Gemdos
	addq	#8,a7
	movea.l	(a7)+,a2
	rts

endmod
module Fdelete

	pea	(a2)
	pea	(a0)
	move	#65,-(a7)	; Fdelete
	trap	#1		; Gemdos
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module Fcreate

	pea	(a2)
	move	d0,-(a7)
	pea	(a0)
	move	#60,-(a7)	; Fcreate
	trap	#1		; Gemdos
	addq	#8,a7
	movea.l	(a7)+,a2
	rts

endmod
module Fattrib

	pea	(a2)
	move	d1,-(a7)
	move	d0,-(a7)
	pea	(a0)
	move	#67,-(a7)	; Fattrib
	trap	#1		; Gemdos
	lea 	10(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Dsetpath

	pea	(a2)
	pea	(a0)
	move	#59,-(a7)	; Dsetpath
	trap	#1		; Gemdos
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module Dgetpath

	pea	(a2)
	move	d0,-(a7)
	pea	(a0)
	move	#71,-(a7)	; Dgetpath
	trap	#1		; Gemdos
	addq	#8,a7
	movea.l	(a7)+,a2
	rts

endmod
module Ddelete

	pea	(a2)
	pea	(a0)
	move	#58,-(a7)	; Ddelete
	trap	#1		; Gemdos
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module Dcreate

	pea	(a2)
	pea	(a0)
	move	#57,-(a7)	; Dcreate
	trap	#1		; Gemdos
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module Cconws

	pea	(a2)
	pea	(a0)
	move	#9,-(a7)	; Cconws
	trap	#1		; Gemdos
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module Dpathconf

	pea	(a2)
	move	d0,-(a7)
	pea	(a0)
	move	#292,-(a7)	; DpathConf
	trap	#1		; Gemdos
	addq	#8,a7
	movea.l	(a7)+,a2
	rts

endmod
module Dopendir

	pea	(a2)
	move	d0,-(a7)
	pea	(a0)
	move	#296,-(a7)	; DopenDir
	trap	#1		; Gemdos
	addq	#8,a7
	movea.l	(a7)+,a2
	rts

endmod
module Dreaddir

;	movem.l	d0-d1/a0/a2,-(a7)
	xsave.l	d0-d1/a0/a2
	move	#297,(a7)	; DreadDir
	trap	#1		; Gemdos
	lea 	12(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Fxattr

;	movem.l	d0/a0-a2,-(a7)
	xsave.l	d0/a0-a2
	move	#300,(a7)	; FxAttr
	trap	#1		; Gemdos
	lea 	12(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Flink

;	movem.l	a0-a2,-(a7)
	xsave.l	a0-a2
	move	#301,-(a7)	; Flink
	trap	#1		; Gemdos
	lea 	10(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Fsymlink

;	movem.l	a0-a2,-(a7)
	xsave.l	a0-a2
	move	#302,-(a7)	; FsymLink
	trap	#1		; Gemdos
	lea 	10(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Freadlink

;	movem.l	d0/a0-a2,-(a7)
	xsave.l	d0/a0-a2,
	move	#303,(a7)	; FreadLink
	trap	#1		; Gemdos
	lea 	12(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Dcntl

	pea	(a2)
	move.l	d1,-(a7)
	pea	(a0)
	move	d0,-(a7)
	move	#304,-(a7)	; Dcntl
	trap	#1		; Gemdos
	lea 	12(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Fchown

	pea	(a2)
	move	d1,-(a7)
	move	d0,-(a7)
	pea	(a0)
	move	#305,-(a7)	; FchOwn
	trap	#1		; Gemdos
	lea 	10(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Fchmod

	pea	(a2)
	move	d0,-(a7)
	pea	(a0)
	move	#306,-(a7)	; FchMod
	trap	#1		; Gemdos
	addq	#8,a7
	movea.l	(a7)+,a2
	rts

endmod
module Xbtimer
	pea	(a2)
	pea	(a0)
;	movem	d0-d2,-(a7)
	move	d2,-(a7)
	move	d1,-(a7)
	move	d0,-(a7)
	move	#31,-(a7)	; Xbtimer
	trap	#14		; Xbios
	lea 	12(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Vsync

	pea	(a2)
	move	#37,-(a7)	; Vsync
	trap	#14		; Xbios
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Supexec

	pea	(a2)
	pea	(a0)
	move	#38,-(a7)	; Supexec
	trap	#14		; Xbios
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module Ssbrk

	pea	(a2)
	move	d0,-(a7)
	move	#1,-(a7)	; Ssbrk
	trap	#14		; Xbios
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module Settime

	pea	(a2)
	move.l	d0,-(a7)
	move	#22,-(a7)	; Settime
	trap	#14		; Xbios
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module Setscreen

	pea	(a2)
	move	d0,-(a7)
	pea	(a1)
	pea	(a0)
	move	#5,-(a7)	; Setscreen
	trap	#14		; Xbios
	lea 	12(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Setprt

	pea	(a2)
	move	d0,-(a7)
	move	#33,-(a7)	; Setprt
	trap	#14		; Xbios
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module Setpalette

	pea	(a2)
	pea	(a0)
	move	#6,-(a7)	; Setpalette
	trap	#14		; Xbios
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module Setcolor

	pea	(a2)
	move	d1,-(a7)
	move	d0,-(a7)
	move	#7,-(a7)	; Setcolor
	trap	#14		; Xbios
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module Scrdmp

	pea	(a2)
	move	#20,-(a7)	; Scrdmp
	trap	#14		; Xbios
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Rsconf

	pea	(a2)
	move	12(a7),-(a7)
	move.l	10(a7),-(a7)
;	movem	d0-d2,-(a7)
	move	d2,-(a7)
	move	d1,-(a7)
	move	d0,-(a7)
	move	#15,-(a7)	; Rsconf
	trap	#14		; Xbios
	lea 	14(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Random

	pea	(a2)
	move	#17,-(a7)	; Random
	trap	#14		; Xbios
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Puntaes

	pea	(a2)
	move	#39,-(a7)	; Puntaes
	trap	#14		; Xbios
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Prtblk

	pea	(a2)
	pea	(a0)
	move	#36,-(a7)	; Prtblk
	trap	#14		; Xbios
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module Protobt

	pea	(a2)
	move	d2,-(a7)
	move	d1,-(a7)
	move.l	d0,-(a7)
	pea	(a0)
	move	#18,-(a7)	; Protobt
	trap	#14		; Xbios
	lea 	14(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Physbase

	pea	(a2)
	move	#2,-(a7)	; Physbase
	trap	#14		; Xbios
	addq	#2,a7
	movea.l	d0,a0
	movea.l	(a7)+,a2
	rts

endmod
module Ongibit

	pea	(a2)
	move	d0,-(a7)
	move	#30,-(a7)	; Ongibit
	trap	#14		; Xbios
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module Offgibit

	pea	(a2)
	move	d0,-(a7)
	move	#29,-(a7)	; Offgibit
	trap	#14		; Xbios
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module Midiws

;	movem.l	d0/a0/a2,-(a7)
	xsave.l	d0/a0/a2
	move	#12,(a7)	; Midiws
	trap	#14		; Xbios
	addq	#8,a7
	movea.l	(a7)+,a2
	rts

endmod
module Mfpint

;	movem.l	d0/a0/a2,-(a7)
	xsave.l	d0/a0/a2
	move	#13,(a7)	; Mfpint
	trap	#14		; Xbios
	addq	#8,a7
	movea.l	(a7)+,a2
	rts

endmod
module Metainit

	pea	(a2)
	pea	(a0)
	move	#48,-(a7)	; Metainit
	trap	#14		; Xbios
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module Logbase

	pea	(a2)
	move	#3,-(a7)	; Logbase
	trap	#14		; Xbios
	addq	#2,a7
	movea.l	d0,a0
	movea.l	(a7)+,a2
	rts

endmod
module Keytbl

	pea	(a2)
	move.l	8(a7),-(a7)
	pea	(a1)
	pea	(a0)
	move	#16,-(a7)	; Keytbl
	trap	#14		; Xbios
	lea 	14(a7),a7
	movea.l	d0,a0
	movea.l	(a7)+,a2
	rts

endmod
module Kbrate

	pea	(a2)
	move	d1,-(a7)
	move	d0,-(a7)
	move	#35,-(a7)	; Kbrate
	trap	#14		; Xbios
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module Kbdvbase

	pea	(a2)
	move	#34,-(a7)	; Kbdvbase
	trap	#14		; Xbios
	addq	#2,a7
	movea.l	d0,a0
	movea.l	(a7)+,a2
	rts

endmod
module Jenabint

	pea	(a2)
	move	d0,-(a7)
	move	#27,-(a7)	; Jenabint
	trap	#14		; Xbios
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module Jdisint

	pea	(a2)
	move	d0,-(a7)
	move	#26,-(a7)	; Jdisint
	trap	#14		; Xbios
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module Iorec

	pea	(a2)
	move	d0,-(a7)
	move	#14,-(a7)	; Iorec
	trap	#14		; Xbios
	addq	#4,a7
	movea.l	d0,a0
	movea.l	(a7)+,a2
	rts

endmod
module Initmous

;	movem.l	d0/a0-a2,-(a7)
	xsave.l	d0/a0-a2
	clr	(a7)		; Initmous
	trap	#14		; Xbios
	lea 	12(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Ikbdws

;	movem.l	d0/a0/a2,-(a7)
	xsave.l	d0/a0/a2
	move	#25,(a7)	; Ikbdws
	trap	#14		; Xbios
	addq	#8,a7
	movea.l	(a7)+,a2
	rts

endmod
module Giaccess

	pea	(a2)
	move	d1,-(a7)
	move	d0,-(a7)
	move	#28,-(a7)	; Giaccess
	trap	#14		; Xbios
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module Gettime

	pea	(a2)
	move	#23,-(a7)	; Gettime
	trap	#14		; Xbios
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Getrez

	pea	(a2)
	move	#4,-(a7)	; Getrez
	trap	#14		; Xbios
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Flopwr

	pea	(a2)
	move.l	8(a7),-(a7)
;	movem	d0-d2,-(a7)
	move	d2,-(a7)
	move	d1,-(a7)
	move	d0,-(a7)
	pea	(a1)
	pea	(a0)
	move	#9,-(a7)	; Flopwr
	trap	#14		; Xbios
	lea 	20(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Flopver

	pea	(a2)
	move.l	8(a7),-(a7)
;	movem	d0-d2,-(a7)
	move	d2,-(a7)
	move	d1,-(a7)
	move	d0,-(a7)
	pea	(a1)
	pea	(a0)
	move	#19,-(a7)	; Flopver
	trap	#14		; Xbios
	lea 	20(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Floprd

	pea	(a2)
	move.l	8(a7),-(a7)
;	movem	d0-d2,-(a7)
	move	d2,-(a7)
	move	d1,-(a7)
	move	d0,-(a7)
	pea	(a1)
	pea	(a0)
	move	#8,-(a7)	; Floprd
	trap	#14		; Xbios
	lea 	20(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Floprate

	pea	(a2)
	move	d1,-(a7)
	move	d0,-(a7)
	move	#41,-(a7)	; Floprate
	trap	#14		; Xbios
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module Flopfmt

	pea	(a2)
	move	16(a7),-(a7)
	move.l	14(a7),-(a7)
	move.l	14(a7),-(a7)
;	movem	d0-d2,-(a7)
	move	d2,-(a7)
	move	d1,-(a7)
	move	d0,-(a7)
	pea	(a1)
	pea	(a0)
	move	#10,-(a7)	; Flopfmt
	trap	#14		; Xbios
	lea 	26(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module EsetSmear

	pea	(a2)
	move	d0,-(a7)
	move	#87,-(a7)	; EsetSmear
	trap	#14		; Xbios
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module EsetShift

	pea	(a2)
	move	d0,-(a7)
	move	#80,-(a7)	; Esetshift
	trap	#14		; Xbios
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module EsetPalette

	pea	(a2)
	pea	(a0)
	move	d1,-(a7)
	move	d0,-(a7)
	move	#84,-(a7)	; EsetPalette
	trap	#14		; Xbios
	lea 	10(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module EsetGray

	pea	(a2)
	move	d0,-(a7)
	move	#86,-(a7)	; EsetGray
	trap	#14		; Xbios
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module EsetColor

	pea	(a2)
	move	d1,-(a7)
	move	d0,-(a7)
	move	#83,-(a7)	; EsetColor
	trap	#14		; Xbios
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module EsetBank

	pea	(a2)
	move	d0,-(a7)
	move	#82,-(a7)	; EsetBank
	trap	#14		; Xbios
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module EgetShift

	pea	(a2)
	move	#81,-(a7)	; EgetShift
	trap	#14		; Xbios
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module EgetPalette

	pea	(a2)
	pea	(a0)
	move	d1,-(a7)
	move	d0,-(a7)
	move	#85,-(a7)	; EgetPalette
	trap	#14		; Xbios
	lea 	10(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Dosound

	pea	(a2)
	pea	(a0)
	move	#32,-(a7)	; Dosound
	trap	#14		; Xbios
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module DMAwrite

	pea	(a2)
	move	d2,-(a7)
	pea	(a0)
	move	d1,-(a7)
	move.l	d0,-(a7)
	move	#43,-(a7)	; DMAwrite
	trap	#14		; Xbios
	lea 	14(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module DMAread

	pea	(a2)
	move	d2,-(a7)
	pea	(a0)
	move	d1,-(a7)
	move.l	d0,-(a7)
	move	#42,-(a7)	; DMAread
	trap	#14		; Xbios
	lea 	14(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Cursconf

	pea	(a2)
	move	d1,-(a7)
	move	d0,-(a7)
	move	#21,-(a7)	; Cursconf
	trap	#14		; Xbios
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module Blitmode

	pea	(a2)
	move	d0,-(a7)
	move	#64,-(a7)	; Blitmode
	trap	#14		; Xbios
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module Bioskeys

	pea	(a2)
	move	#24,-(a7)	; Bioskeys
	trap	#14		; Xbios
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Bconmap

	pea	(a2)
	move	d0,-(a7)
	move	#44,-(a7)	; Bconmap
	trap	#14		; Xbios
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module Dsp_DoBlock

	pea	(a2)
	move.l	d1,-(a7)
	pea	(a1)
	move.l	d0,-(a7)
	pea	(a0)
	move	#96,-(a7)	; Dsp_DoBlock
	trap	#14		; Xbios
	lea 	18(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Dsp_BlkHandShake

	pea	(a2)
	move.l	d1,-(a7)
	pea	(a1)
	move.l	d0,-(a7)
	pea	(a0)
	move	#97,-(a7)	; Dsp_BlkHandShake
	trap	#14		; Xbios
	lea 	18(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Dsp_BlkUnpacked

	pea	(a2)
	move.l	d1,-(a7)
	pea	(a1)
	move.l	d0,-(a7)
	pea	(a0)
	move	#98,-(a7)	; Dsp_BlkUnpacked
	trap	#14		; Xbios
	lea 	18(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Dsp_InStream

;	movem.l	d0-d1/a1-a2,-(a7)
	xsave.l	d0-d1/a1-a2
	pea	(a0)
	move	#99,-(a7)	; Dsp_InStream
	trap	#14		; Xbios
	lea 	18(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Dsp_OutStream

;	movem.l	d0-d1/a1-a2,-(a7)
	xsave.l	d0-d1/a1-a2
	pea	(a0)
	move	#100,-(a7)	; Dsp_OutStream
	trap	#14		; Xbios
	lea 	18(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Dsp_IOStream

	pea	(a2)
	move.l	8(a7),-(a7)
;	movem.l	d0-d2,-(a7)
	xsave.l	d0-d2
	pea	(a1)
	pea	(a0)
	move	#101,-(a7)	; Dsp_IoStream
	trap	#14		; Xbios
	lea 	22(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Dsp_RemoveInterrupts

	pea	(a2)
	move	d0,-(a7)
	move	#102,-(a7)	; Dsp_RemoveInterrupts
	trap	#14		; Xbios
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module Dsp_GetWordSize

	pea	(a2)
	move	#103,-(a7)	; Dsp_GetWordSize
	trap	#14		; Xbios
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Dsp_Lock

	pea	(a2)
	move	#104,-(a7)	; Dsp_Lock
	trap	#14		; Xbios
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Dsp_Unlock

	pea	(a2)
	move	#105,-(a7)	; Dsp_Unlock
	trap	#14		; Xbios
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Dsp_Available

;	movem.l	a0-a2,-(a7)
	xsave.l	a0-a2
	move	#106,-(a7)	; Dsp_Available
	trap	#14		; Xbios
	lea 	10(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Dsp_Reserve

;	movem.l	d0-d1/a2,-(a7)
	xsave.l	d0-d1/a2
	move	#107,-(a7)	; Dsp_Reserve
	trap	#14		; Xbios
	lea 	10(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Dsp_ExecProg

	pea	(a2)
	move	d1,-(a7)
	move.l	d0,-(a7)
	pea	(a0)
	move	#109,-(a7)	; Dsp_ExecProg
	trap	#14		; Xbios
	lea 	12(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Dsp_ExecBoot

	pea	(a2)
	move	d1,-(a7)
	move.l	d0,-(a7)
	pea	(a0)
	move	#110,-(a7)	; Dsp_ExecBoot
	trap	#14		; Xbios
	lea 	12(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Dsp_TriggerHC

	pea	(a2)
	move	d0,-(a7)
	move	#112,-(a7)	; Dsp_TriggerHC
	trap	#14		; Xbios
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module Dsp_RequestUniqueAbility

	pea	(a2)
	move	#113,-(a7)	; Dsp_RequestUniqueAbality
	trap	#14		; Xbios
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Dsp_GetProgAbility

	pea	(a2)
	move	#114,-(a7)	; Dsp_GetProgAbility
	trap	#14		; Xbios
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Dsp_FlushSubroutines

	pea	(a2)
	move	#115,-(a7)	; Dsp_FlushSubroutines
	trap	#14		; Xbios
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Dsp_LoadSubroutine

	pea	(a2)
	move	d1,-(a7)
	move.l	d0,-(a7)
	pea	(a0)
	move	#116,-(a7)	; Dsp_LoadSubroutines
	trap	#14		; Xbios
	lea 	12(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Dsp_InqSubrAbility

	pea	(a2)
	move	d0,-(a7)
	move	#117,-(a7)	; Dsp_InqSubrAbility
	trap	#14		; Xbios
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module Dsp_RunSubroutine

	pea	(a2)
	move	d0,-(a7)
	move	#118,-(a7)	; Dsp_RunSubroutine
	trap	#14		; Xbios
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module Dsp_Hf0

	pea	(a2)
	move	d0,-(a7)
	move	#119,-(a7)	; Dsp_Hf0
	trap	#14		; Xbios
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module Dsp_Hf1

	pea	(a2)
	move	d0,-(a7)
	move	#120,-(a7)	; Dsp_Hf1
	trap	#14		; Xbios
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module Dsp_Hf2

	pea	(a2)
	move	#121,-(a7)	; Dsp_Hf2
	trap	#14		; Xbios
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Dsp_Hf3

	pea	(a2)
	move	#122,-(a7)	; Dsp_Hf3
	trap	#14		; Xbios
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Dsp_BlkWords

	pea	(a2)
	move.l	d1,-(a7)
	pea	(a1)
	move.l	d0,-(a7)
	pea	(a0)
	move	#123,-(a7)	; Dsp_BlkWords
	trap	#14		; Xbios
	lea 	18(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Dsp_BlkBytes

	pea	(a2)
	move.l	d1,-(a7)
	pea	(a1)
	move.l	d0,-(a7)
	pea	(a0)
	move	#124,-(a7)	; Dsp_BlkBytes
	trap	#14		; Xbios
	lea 	18(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Dsp_HStat

	pea	(a2)
	move	#125,-(a7)	; Dsp_Hstat
	trap	#14		; Xbios
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module Dsp_SetVectors

;	movem.l	a0-a2,-(a7)
	xsave.l	a0-a2
	move	#126,-(a7)	; Dsp_SetVectors
	trap	#14		; Xbios
	lea 	10(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Dsp_MultBlocks

;	movem.l	d0-d1/a0-a2,-(a7)
	xsave.l	d0-d1/a0-a2
	move	#127,-(a7)	; Dsp_MultBlocks
	trap	#14		; Xbios
	lea 	18(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Vsetmode

	pea	(a2)
	move	d0,-(a7)
	move	#88,-(a7)	; Vsetmode
	trap	#14		; Xbios
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module mon_type

	pea	(a2)
	move	#89,-(a7)	; montype
	trap	#14		; Xbios
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module VgetSize

	pea	(a2)
	move	d0,-(a7)
	move	#91,-(a7)	; VgetSize
	trap	#14		; Xbios
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module VsetSync

	pea	(a2)
	move	d0,-(a7)
	move	#90,-(a7)	; VsetSync
	trap	#14		; Xbios
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module VsetRGB

	pea	(a2)
	pea	(a0)
	move	d1,-(a7)
	move	d0,-(a7)
	move	#93,-(a7)	; VsetRGB
	trap	#14		; Xbios
	lea 	10(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module VgetRGB

	pea	(a2)
	pea	(a0)
	move	d1,-(a7)
	move	d0,-(a7)
	move	#94,-(a7)	; VgetRGB
	trap	#14		; Xbios
	lea 	10(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module VsetMask

	pea	(a2)
;	movem	d0-d2,-(a7)
	move	d2,-(a7)
	move	d1,-(a7)
	move	d0,-(a7)
	move	#150,-(a7)	; Vsetmask
	trap	#14		; Xbios
	addq	#8,a7
	movea.l	(a7)+,a2
	rts

endmod
module locksnd

	pea	(a2)
	move	#128,-(a7)	; locksound
	trap	#14		; Xbios
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module unlocksnd

	pea	(a2)
	move	#129,-(a7)	; unlocksound
	trap	#14		; Xbios
	addq	#2,a7
	movea.l	(a7)+,a2
	rts

endmod
module soundcmd

	pea	(a2)
	move	d1,-(a7)
	move	d0,-(a7)
	move	#130,-(a7)	; soundcmd
	trap	#14		; Xbios
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module setbuffer

;	movem.l	d0/a0-a2,-(a7)
	xsave.l	d0/a0-a2
	move	#131,(a7)	; setbuffer
	trap	#14		; Xbios
	lea 	12(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module setmode

	pea	(a2)
	move	d0,-(a7)
	move	#132,-(a7)	; setmode
	trap	#14		; Xbios
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module settracks

	pea	(a2)
	move	d1,-(a7)
	move	d0,-(a7)
	move	#133,-(a7)	; settracks
	trap	#14		; Xbios
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module setmontracks

	pea	(a2)
	move	d0,-(a7)
	move	#134,-(a7)	; setmontracks
	trap	#14		; Xbios
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module setinterrupt

	pea	(a2)
	move	d1,-(a7)
	move	d0,-(a7)
	move	#135,-(a7)	; setinterrupt
	trap	#14		; Xbios
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module buffoper

	pea	(a2)
	move	d0,-(a7)
	move	#136,-(a7)	; buffoper
	trap	#14		; Xbios
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module dsptristate

	pea	(a2)
	move	d1,-(a7)
	move	d0,-(a7)
	move	#137,-(a7)	; dsptristate
	trap	#14		; Xbios
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module gpio

	pea	(a2)
	move	d1,-(a7)
	move	d0,-(a7)
	move	#138,-(a7)	; gpio
	trap	#14		; Xbios
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module devconnect

	pea	(a2)
	move.l	8(a7),-(a7)
;	movem	d0-d2,-(a7)
	move	d2,-(a7)
	move	d1,-(a7)
	move	d0,-(a7)
	move	#139,-(a7)	; devconnect
	trap	#14		; Xbios
	lea 	12(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module sndstatus

	pea	(a2)
	move	d0,-(a7)
	move	#140,-(a7)	; sndstatus
	trap	#14		; Xbios
	addq	#4,a7
	movea.l	(a7)+,a2
	rts

endmod
module buffptr

	pea	(a2)
	pea	(a0)
	move	#141,-(a7)	; buffptr
	trap	#14		; Xbios
	addq	#6,a7
	movea.l	(a7)+,a2
	rts

endmod
module L4024

Dsp_LoadProg:
	pea	(a2)
	pea	(a1)
	move	d0,-(a7)
	pea	(a0)
	move	#108,-(a7)	; Dsp_LoadProg
	trap	#14		; Xbios
	lea 	12(a7),a7
	movea.l	(a7)+,a2
	rts

endmod
module Dsp_LodToBinary

;	movem.l	a0-a2,-(a7)
	xsave.l	a0-a2
	move	#111,-(a7)	; DspLODtoBinary
	trap	#14		; Xbios
	lea 	10(a7),a7
	movea.l	(a7)+,a2
	rts
endmod

	end
#endif

