;----------------------------------------------------------------------------------------
;	gemdos.s, part of TOS Linker for CodeWarrier
;
;	Gemdos system calls for TOS
;	Pure Asm version
;
;	16.11.1998 by Daniel Hšpfl, Manfred Lippert
;   based on CodeWarrior-Version by Manfred Lippert
;
;	last change: 26.11.1998
;
;	Don't edit this file.
;
;	If you have to make any changes on this file, please contact:
;	mani@mani.de
;----------------------------------------------------------------------------------------

.export Cauxin, Cauxis, Cauxos, Cauxout, Cconin
.export Cconis, Cconos, Cconout, Cconrs, Cconws
.export Cnecin, Cprnos, Cprnout, Crawcin, Crawio

.export Dclosedir, Dcntl, Dcreate, Ddelete, Dfree
.export Dgetcwd, Dgetdrv, Dgetpath, Dlock, Dopendir
.export Dpathconf, Dreaddir, Dreadlabel, Drewinddir, Dsetdrv
.export Dsetpath, Dwritelabel, Dxreaddir

.export Fattrib, Fchmod, Fchown, Fclose, Fcntl
.export Fcreate, Fdatime, Fdelete, Fdup, Fforce
.export Fgetchar, Fgetdta, Finstat, Flink, Flock
.export Fmidipipe, Fopen, Foutstat, Fpipe, Fputchar
.export Fread, Freadlink, Frename, Fseek, Fselect
.export Fsetdta, Fsfirst, Fsnext, Fsymlink, Fwrite
.export Fxattr

.export Maddalt, Malloc, Mfree, Mshrink, Mxalloc

.export Pause, Pdomain, Pexec, Pfork, Pgetauid
.export Pgetegid, Pgeteuid, Pgetgid, Pgetpgrp, Pgetpid
.export Pgetppid, Pgetuid, Pkill, Pmsg, Pnice
.export Prenice, Prusage, Psemaphore, Psetauid, Psetgid
.export Psetlimit, Psetpgrp, Psetuid, Psigaction, Psigblock
.export Psignal, Psigpause, Psigpending, Psigreturn, Psigsetmask
.export Pterm, Pterm0, Ptermres, Pumask, Pusrval
.export Pvfork, Pwait, Pwait3, Pwaitpid

.export Salert, Slbopen, Slbclose, Sconfig, Srealloc
.export Super, Ssystem, Sversion, Syield, Sysconf

.export Talarm, Tgetdate, Tgettime, Tsetdate, Tsetitimer
.export Tsettime

MACRO GEMDOS_0 nr
		pea (a2)
		move.w #nr,-(sp)
		trap #1
		addq.l #2,sp
		move.l (sp)+,a2
ENDM

MACRO GEMDOS_2 nr
		pea (a2)
		move.w 8(sp),-(sp)
		move.w #nr,-(sp)
		trap #1
		addq.l #4,sp
		move.l (sp)+,a2
ENDM

MACRO GEMDOS_4 nr
		pea (a2)
		move.l 8(sp),-(sp)
		move.w #nr,-(sp)
		trap #1
		addq.l #6,sp
		move.l (sp)+,a2
ENDM

MACRO GEMDOS_6 nr
		pea (a2)
		move.l 10(sp),-(sp)
		move.w 12(sp),-(sp)
		move.w #nr,-(sp)
		trap #1
		addq.l #8,sp
		move.l (sp)+,a2
ENDM

MACRO GEMDOS_8 nr
		pea (a2)
		move.l 12(sp),-(sp)
		move.l 12(sp),-(sp)
		move.w #nr,-(sp)
		trap #1
		lea 10(sp),sp
		move.l (sp)+,a2
ENDM

MACRO GEMDOS_10 nr
		pea (a2)
		move.l 14(sp),-(sp)
		move.l 14(sp),-(sp)
		move.w 16(sp),-(sp)
		move.w #nr,-(sp)
		trap #1
		lea 12(sp),sp
		move.l (sp)+,a2
ENDM

MACRO GEMDOS_12 nr
		pea (a2)
		move.l 16(sp),-(sp)
		move.l 16(sp),-(sp)
		move.l 16(sp),-(sp)
		move.w #nr,-(sp)
		trap #1
		lea 14(sp),sp
		move.l (sp)+,a2
ENDM

MACRO GEMDOS_14 nr
		pea (a2)
		move.l 18(sp),-(sp)
		move.l 18(sp),-(sp)
		move.l 18(sp),-(sp)
		move.w 20(sp),-(sp)
		move.w #nr,-(sp)
		trap #1
		lea 16(sp),sp
		move.l (sp)+,a2
ENDM

MACRO GEMDOS_18 nr
		pea (a2)
		move.l 22(sp),-(sp)
		move.l 22(sp),-(sp)
		move.l 22(sp),-(sp)
		move.l 22(sp),-(sp)
		move.w 24(sp),-(sp)
		move.w #nr,-(sp)
		trap #1
		lea 20(sp),sp
		move.l (sp)+,a2
ENDM

MACRO GEMDOS_20 nr
		pea (a2)
		move.l 24(sp),-(sp)
		move.l 24(sp),-(sp)
		move.l 24(sp),-(sp)
		move.l 24(sp),-(sp)
		move.l 24(sp),-(sp)
		move.w #nr,-(sp)
		trap #1
		lea 22(sp),sp
		move.l (sp)+,a2
ENDM

MACRO GEMDOS_24 nr
		pea (a2)
		move.l 28(sp),-(sp)
		move.l 28(sp),-(sp)
		move.l 28(sp),-(sp)
		move.l 28(sp),-(sp)
		move.l 28(sp),-(sp)
		move.l 28(sp),-(sp)
		move.w #nr,-(sp)
		trap #1
		lea 26(sp),sp
		move.l (sp)+,a2
ENDM

.MODULE Cauxin
	GEMDOS_0(3)
	rts

.MODULE Cauxis
	GEMDOS_0(18)
	rts

.MODULE Cauxos
	GEMDOS_0(19)
	rts

.MODULE Cauxout
	GEMDOS_2(4)
	rts

.MODULE Cconin
	GEMDOS_0(1)
	rts

.MODULE Cconis
	GEMDOS_0(11)
	rts

.MODULE Cconos
	GEMDOS_0(16)
	rts

.MODULE Cconout
	GEMDOS_2(2)
	rts

.MODULE Cconrs
	GEMDOS_4(10)
	rts

.MODULE Cconws
	GEMDOS_4(9)
	rts

.MODULE Cnecin
	GEMDOS_0(8)
	rts

.MODULE Cprnos
	GEMDOS_0(17)
	rts

.MODULE Cprnout
	GEMDOS_2(5)
	rts

.MODULE Crawcin
	GEMDOS_0(7)
	rts

.MODULE Crawio
	GEMDOS_2(6)
	rts

.MODULE Dclosedir
	GEMDOS_4(299)
	rts

.MODULE Dcntl
	GEMDOS_10(304)
	rts

.MODULE Dcreate
	GEMDOS_4(57)
	rts

.MODULE Ddelete
	GEMDOS_4(58)
	rts

.MODULE Dfree
	GEMDOS_6(54)
	rts

.MODULE Dgetcwd
	GEMDOS_8(316)
	rts

.MODULE Dgetdrv
	GEMDOS_0(25)
	rts

.MODULE Dgetpath
	GEMDOS_6(71)
	rts

.MODULE Dlock
	GEMDOS_4(309)
	rts

.MODULE Dopendir
	GEMDOS_6(296)
	rts

.MODULE Dpathconf
	GEMDOS_6(292)
	rts

.MODULE Dreaddir
	GEMDOS_10(297)
	rts

.MODULE Dreadlabel
	GEMDOS_10(338)
	rts

.MODULE Drewinddir
	GEMDOS_4(298)
	rts

.MODULE Dsetdrv
	GEMDOS_2(14)
	rts

.MODULE Dsetpath
	GEMDOS_4(59)
	rts

.MODULE Dwritelabel
	GEMDOS_8(339)
	rts

.MODULE Dxreaddir
	GEMDOS_18(322)
	rts

.MODULE Fattrib
	GEMDOS_8(67)
	rts

.MODULE Fchmod
	GEMDOS_6(306)
	rts

.MODULE Fchown
	GEMDOS_8(305)
	rts

.MODULE Fclose
	GEMDOS_2(62)
	rts

.MODULE Fcntl
	GEMDOS_8(260)
	rts

.MODULE Fcreate
	GEMDOS_6(60)
	rts

.MODULE Fdatime
	GEMDOS_8(87)
	rts

.MODULE Fdelete
	GEMDOS_4(65)
	rts

.MODULE Fdup
	GEMDOS_2(69)
	rts

.MODULE Fforce
	GEMDOS_4(70)
	rts

.MODULE Fgetchar
	GEMDOS_4(263)
	rts

.MODULE Fgetdta
	GEMDOS_0(47)
	movea.l d0,a0
	rts

.MODULE Finstat
	GEMDOS_2(261)
	rts

.MODULE Flink
	GEMDOS_8(301)
	rts

.MODULE Flock
	GEMDOS_12(92)
	rts

.MODULE Fmidipipe
	GEMDOS_6(294)
	rts

.MODULE Fopen
	GEMDOS_6(61)
	rts

.MODULE Foutstat
	GEMDOS_2(262)
	rts

.MODULE Fpipe
	GEMDOS_4(256)
	rts

.MODULE Fputchar
	GEMDOS_8(264)
	rts

.MODULE Fread
	GEMDOS_10(63)
	rts

.MODULE Freadlink
	GEMDOS_10(303)
	rts

.MODULE Frename
	GEMDOS_10(86)
	rts

.MODULE Fseek
	GEMDOS_8(66)
	rts

.MODULE Fselect
	GEMDOS_14(285)
	rts

.MODULE Fsetdta
	GEMDOS_4(26)
	rts

.MODULE Fsfirst
	GEMDOS_6(78)
	rts

.MODULE Fsnext
	GEMDOS_0(79)
	rts

.MODULE Fsymlink
	GEMDOS_8(302)
	rts

.MODULE Fwrite
	GEMDOS_10(64)
	rts

.MODULE Fxattr
	GEMDOS_10(300)
	rts

.MODULE Maddalt
	GEMDOS_8(20)
	rts

.MODULE Malloc
	GEMDOS_4(72)
	movea.l d0,a0
	rts

.MODULE Mfree
	GEMDOS_4(73)
	rts

.MODULE Mshrink
	GEMDOS_10(74)
	rts

.MODULE Mxalloc
	GEMDOS_6(68)
	movea.l d0,a0
	rts

.MODULE Pause
	GEMDOS_0(289)
	rts

.MODULE Pdomain
	GEMDOS_2(281)
	rts

.MODULE Pexec
	GEMDOS_14(75)
	rts

.MODULE Pfork
	GEMDOS_0(283)
	rts

.MODULE Pgetauid
	GEMDOS_0(326)
	rts

.MODULE Pgetegid
	GEMDOS_0(313)
	rts

.MODULE Pgeteuid
	GEMDOS_0(312)
	rts

.MODULE Pgetgid
	GEMDOS_0(276)
	rts

.MODULE Pgetpgrp
	GEMDOS_0(269)
	rts

.MODULE Pgetpid
	GEMDOS_0(267)
	rts

.MODULE Pgetppid
	GEMDOS_0(268)
	rts

.MODULE Pgetuid
	GEMDOS_0(271)
	rts

.MODULE Pkill
	GEMDOS_4(273)
	rts

.MODULE Pmsg
	GEMDOS_10(293)
	rts

.MODULE Pnice
	GEMDOS_2(266)
	rts

.MODULE Prenice
	GEMDOS_4(295)
	rts

.MODULE Prusage
	GEMDOS_4(286)
	rts

.MODULE Psemaphore
	GEMDOS_10(308)
	rts

.MODULE Psetauid
	GEMDOS_2(325)
	rts

.MODULE Psetgid
	GEMDOS_2(277)
	rts

.MODULE Psetlimit
	GEMDOS_6(287)
	rts

.MODULE Psetpgrp
	GEMDOS_4(270)
	rts

.MODULE Psetuid
	GEMDOS_2(272)
	rts

.MODULE Psigaction
	GEMDOS_10(311)
	rts

.MODULE Psigblock
	GEMDOS_4(278)
	rts

.MODULE Psignal
	GEMDOS_6(274)
	rts

.MODULE Psigpause
	GEMDOS_4(310)
	rts

.MODULE Psigpending
	GEMDOS_0(291)
	rts

.MODULE Psigreturn
	GEMDOS_0(282)
	rts

.MODULE Psigsetmask
	GEMDOS_4(279)
	rts

.MODULE Pterm
	GEMDOS_2(76)
	rts

.MODULE Pterm0
	GEMDOS_0(0)
	rts

.MODULE Ptermres
	GEMDOS_6(49)
	rts

.MODULE Pumask
	GEMDOS_2(307)
	rts

.MODULE Pusrval
	GEMDOS_4(280)
	rts

.MODULE Pvfork
	GEMDOS_0(275)
	rts

.MODULE Pwait
	GEMDOS_0(265)
	rts

.MODULE Pwait3
	GEMDOS_6(284)
	rts

.MODULE Pwaitpid
	GEMDOS_8(314)
	rts

.MODULE Salert
	GEMDOS_4(316)
	rts

.MODULE Slbopen
	GEMDOS_24(22)
	rts

.MODULE Slbclose
	GEMDOS_4(23)
	rts

.MODULE Sconfig
	GEMDOS_6(51)
	rts

.MODULE Srealloc
	GEMDOS_4(316)
	rts

.MODULE Super
	GEMDOS_4(32)
	rts

.MODULE Ssystem
	GEMDOS_10(340)
	rts

.MODULE Sversion
	GEMDOS_0(48)
	rts

.MODULE Syield
	GEMDOS_0(255)
	rts

.MODULE Sysconf
	GEMDOS_2(290)
	rts

.MODULE Talarm
	GEMDOS_4(288)
	rts

.MODULE Tgetdate
	GEMDOS_0(42)
	rts

.MODULE Tgettime
	GEMDOS_0(44)
	rts

.MODULE Tsetdate
	GEMDOS_2(43)
	rts

.MODULE Tsetitimer
	GEMDOS_20(329)
	rts

.MODULE Tsettime
	GEMDOS_2(45)
	rts

