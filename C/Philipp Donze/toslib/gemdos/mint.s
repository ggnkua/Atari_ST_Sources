;; 
;; $Id: mint.s pdonze Exp $
;; 
;; TOS.LIB - (c) 1998 - 2006 Philipp Donze
;; 
;; A replacement for PureC PCTOSLIB.LIB
;; 
;; This file is part of TOS.LIB and contains MiNT specific GEMDOS calls
;; 
;; TOS.LIB is free software; you can redistribute it and/or
;; modify it under the terms of the GNU Library General Public License as
;; published by the Free Software Foundation; either version 2 of the
;; License, or (at your option) any later version.
;;
;; TOS.LIB is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; Library General Public License for more details.
;;
;; You should have received a copy of the GNU Library General Public
;; License along with the GNU C Library; see the file COPYING.LIB.  If not,
;; write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.
;; 

; All bindings use Pure C's parameter passing convention:
;   The first three (3) scalar arguments ( char, int, long) use D0-D2.
;   The first two (2) address parameters (pointers) use A0-A1.
;   The first three (3) floatingpoint args use FP0-FP2. (NOT USED HERE)
;
;   Scalar return values ( char, int, long) are expected in D0
;   Address return values (pointer) are expected in A0
;   Floating point return values are expected in FP0. (NOT USED HERE)
;
; => Registers D0-D2/A0-A1/FP0-FP2 are free for use in assembly code.
; Other registers have to be saved and restored.

; GEMDOS saves and restores automatically D3-D7 and A3-A7, other
; registers can be destroyed by a trap.
; Return value (data or address) is always in D0.

; --------------------------------------------------------------------
; tabsize = 4
; 	<asm>	<params>		; <comment>


_STC	EQU		4				; stack offset caused by macro REGSave

MACRO REGSave					; macro for saving registers before trap
		pea		(A2)
ENDM

MACRO REGLoad					; macro for restoring registers after trap
		movea.l	(SP)+,A2
ENDM






; --------------------------------------------------------------------
; extensions for MiNT
; --------------------------------------------------------------------

export Syield
MODULE Syield
; long	Syield( void );
		REGSave
		move.w	#255,-(sp)
		trap	#1				; Gemdos(255)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Fpipe
MODULE Fpipe
; long	Fpipe( short *usrh );
		REGSave
		pea		(A0)
		move.w	#256,-(sp)
		trap	#1				; Gemdos(256)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Ffchown
MODULE Ffchown
; long	Ffchown( short fh, short uid, short gid );
		REGSave
		move.w	D2,-(sp)
		move.w	D1,-(sp)
		move.w	D0,-(sp)
		move.w	#257,-(sp)
		trap	#1				; Gemdos(257)
		addq.l	#8,sp
		REGLoad
		rts
ENDMOD

export Ffchmod
MODULE Ffchmod
; long	Ffchmod( short fh, short mode );
		REGSave
		move.w	D1,-(sp)
		move.w	D0,-(sp)
		move.w	#258,-(sp)
		trap	#1				; Gemdos(258)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Fsync
MODULE Fsync
; long	Fsync( short fh );
		REGSave
		move.w	D0,-(sp)
		move.w	#259,-(sp)
		trap	#1				; Gemdos(259)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export Fcntl
MODULE Fcntl
; long	Fcntl( short fh, long arg, short cmd );
		REGSave
		move.w	D2,-(sp)
		move.l	D1,-(sp)
		move.w	D0,-(sp)
		move.w	#260,-(sp)
		trap	#1				; Gemdos(260)
		lea		10(sp),sp
		REGLoad
		rts
ENDMOD

export Finstat
MODULE Finstat
; long	Finstat( short fh );
		REGSave
		move.w	D0,-(sp)
		move.w	#261,-(sp)
		trap	#1				; Gemdos(261)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export Foutstat
MODULE Foutstat
; long	Foutstat( short fh );
		REGSave
		move.w	D0,-(sp)
		move.w	#262,-(sp)
		trap	#1				; Gemdos(262)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export Fgetchar
MODULE Fgetchar
; long	Fgetchar( short fh, short mode );
		REGSave
		move.w	D1,-(sp)
		move.w	D0,-(sp)
		move.w	#263,-(sp)
		trap	#1				; Gemdos(263)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Fputchar
MODULE Fputchar
; long	Fputchar( short fh, long c, short mode );
		REGSave
		move.w	D2,-(sp)
		move.l	D1,-(sp)
		move.w	D0,-(sp)
		move.w	#264,-(sp)
		trap	#1				; Gemdos(264)
		lea		10(sp),sp
		REGLoad
		rts
ENDMOD

export Pwait
MODULE Pwait
; long	Pwait( void );
		REGSave
		move.w	#265,-(sp)
		trap	#1				; Gemdos(265)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Pnice
MODULE Pnice
; long	Pnice( short increment );
		REGSave
		move.w	D0,-(sp)
		move.w	#266,-(sp)
		trap	#1				; Gemdos(266)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export Pgetpid
MODULE Pgetpid
; long	Pgetpid( void );
		REGSave
		move.w	#267,-(sp)
		trap	#1				; Gemdos(267)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Pgetppid
MODULE Pgetppid
; long	Pgetppid( void );
		REGSave
		move.w	#268,-(sp)
		trap	#1				; Gemdos(268)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Pgetpgrp
MODULE Pgetpgrp
; long	Pgetpgrp( void );
		REGSave
		move.w	#269,-(sp)
		trap	#1				; Gemdos(269)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Psetpgrp
MODULE Psetpgrp
; long	Psetpgrp( short pid, short newgrp );
		REGSave
		move.w	D1,-(sp)
		move.w	D0,-(sp)
		move.w	#270,-(sp)
		trap	#1				; Gemdos(270)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Pgetuid
MODULE Pgetuid
; long	Pgetuid( void );
		REGSave
		move.w	#271,-(sp)
		trap	#1				; Gemdos(271)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Psetuid
MODULE Psetuid
; long	Psetuid( short id );
		REGSave
		move.w	D0,-(sp)
		move.w	#272,-(sp)
		trap	#1				; Gemdos(272)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export Pkill
MODULE Pkill
; long	Pkill( short pid, short sig );
		REGSave
		move.w	D1,-(sp)
		move.w	D0,-(sp)
		move.w	#273,-(sp)
		trap	#1				; Gemdos(273)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Psignal
MODULE Psignal
; long	Psignal( short sig, void *handler );
		REGSave
		pea		(A0)
		move.w	D0,-(sp)
		move.w	#274,-(sp)
		trap	#1				; Gemdos(274)
		addq.l	#8,sp
		REGLoad
		rts
ENDMOD

export Pvfork
MODULE Pvfork
; long	Pvfork( void );
		REGSave
		move.w	#275,-(sp)
		trap	#1				; Gemdos(275)		

		tst.l	D0
		beq		.child			; if return value == 0: child executes

; Execution of father process
		addq.l	#2,sp			; stack correction
		REGLoad
		rts

.child:
; Execution of child process
		movea.l	2(SP),A2		; restore register A2
		movea.l	6(sp),A0		; copy return adress of father process
		jmp		(A0)
ENDMOD

export Pgetgid
MODULE Pgetgid
; long	Pgetgid( void );
		REGSave
		move.w	#276,-(sp)
		trap	#1				; Gemdos(276)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Psetgid
MODULE Psetgid
; long	Psetgid( short id );
		REGSave
		move.w	D0,-(sp)
		move.w	#277,-(sp)
		trap	#1				; Gemdos(277)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export Psigblock
MODULE Psigblock
; long	Psigblock( long mask );
		REGSave
		move.l	D0,-(sp)
		move.w	#278,-(sp)
		trap	#1				; Gemdos(278)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Psigsetmask
MODULE Psigsetmask
; long	Psigsetmask( long mask );
		REGSave
		move.l	D0,-(sp)
		move.w	#279,-(sp)
		trap	#1				; Gemdos(279)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Pusrval
MODULE Pusrval
; long	Pusrval( long arg );
		REGSave
		move.l	D0,-(sp)
		move.w	#280,-(sp)
		trap	#1				; Gemdos(280)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Pdomain
MODULE Pdomain
; long	Pdomain( short newdom );
		REGSave
		move.w	D0,-(sp)
		move.w	#281,-(sp)
		trap	#1				; Gemdos(281)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export Psigreturn
MODULE Psigreturn
; long	Psigreturn( void );
		REGSave
		move.w	#282,-(sp)
		trap	#1				; Gemdos(282)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Pfork
MODULE Pfork
; long	Pfork( void );
		REGSave
		move.w	#283,-(sp)
		trap	#1				; Gemdos(283)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Pwait3
MODULE Pwait3
; long	Pwait3( short flag, long *rusage );
		REGSave
		pea		(A0)
		move.w	D0,-(sp)
		move.w	#284,-(sp)
		trap	#1				; Gemdos(284)
		addq.l	#8,sp
		REGLoad
		rts
ENDMOD

export Fselect
MODULE Fselect
; long	Fselect( short timeout, long *rfd, long *wfd, long *xfd );
		REGSave
		move.l	_STC+4(sp),-(sp)
		pea		(A1)
		pea		(A0)
		move.w	D0,-(sp)
		move.w	#285,-(sp)
		trap	#1				; Gemdos(285)
		lea		16(sp),sp
		REGLoad
		rts
ENDMOD

export Prusage
MODULE Prusage
; long	Prusage( long *rsp );
		REGSave
		pea		(A0)
		move.w	#286,-(sp)
		trap	#1				; Gemdos(286)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Psetlimit
MODULE Psetlimit
; long	Psetlimit( short i, long val );
		REGSave
		move.l	D1,-(sp)
		move.w	D0,-(sp)
		move.w	#287,-(sp)
		trap	#1				; Gemdos(287)
		addq.l	#8,sp
		REGLoad
		rts
ENDMOD

export Talarm
MODULE Talarm
; long	Talarm( long sec );
		REGSave
		move.l	D0,-(sp)
		move.w	#288,-(sp)
		trap	#1				; Gemdos(288)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Pause
MODULE Pause
; long	Pause( void );
		REGSave
		move.w	#289,-(sp)
		trap	#1				; Gemdos(289)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Sysconf
MODULE Sysconf
; long	Sysconf( short which );
		REGSave
		move.w	D0,-(sp)
		move.w	#290,-(sp)
		trap	#1				; Gemdos(290)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export Psigpending
MODULE Psigpending
; long	Psigpending( void );
		REGSave
		move.w	#291,-(sp)
		trap	#1				; Gemdos(291)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Dpathconf
MODULE Dpathconf
; long	Dpathconf( const char *name, short which );
		REGSave
		move.w	D0,-(sp)
		pea		(A0)
		move.w	#292,-(sp)
		trap	#1				; Gemdos(292)
		addq.l	#8,sp
		REGLoad
		rts
ENDMOD

export Pmsg
MODULE Pmsg
; long	Pmsg( short mode, long mbox, MSG *msg );
		REGSave
		pea		(A0)
		move.l	D1,-(sp)
		move.w	D0,-(sp)
		move.w	#293,-(sp)
		trap	#1				; Gemdos(293)
		lea		12(sp),sp
		REGLoad
		rts
ENDMOD

export Fmidipipe
MODULE Fmidipipe
; long	Fmidipipe( short mode, short in, short out );
		REGSave
		move.w	D2,-(sp)
		move.w	D1,-(sp)
		move.w	D0,-(sp)
		move.w	#294,-(sp)
		trap	#1				; Gemdos(294)
		addq.l	#8,sp
		REGLoad
		rts
ENDMOD

export Prenice
MODULE Prenice
; long	Prenice( short pid, short delta );
		REGSave
		move.w	D1,-(sp)
		move.w	D0,-(sp)
		move.w	#295,-(sp)
		trap	#1				; Gemdos(295)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Dopendir
MODULE Dopendir
; long	Dopendir( const char *name, short flags );
		REGSave
		move.w	D0,-(sp)
		pea		(A0)
		move.w	#296,-(sp)
		trap	#1				; Gemdos(296)
		addq.l	#8,sp
		REGLoad
		rts
ENDMOD

export Dreaddir
MODULE Dreaddir
; long	Dreaddir( short buflen, long dirh, char *buf );
		REGSave
		pea		(A0)
		move.l	D1,-(sp)
		move.w	D0,-(sp)
		move.w	#297,-(sp)
		trap	#1				; Gemdos(297)
		lea		12(sp),sp
		REGLoad
		rts
ENDMOD

export Drewinddir
MODULE Drewinddir
; long	Drewinddir( long dirh );
		REGSave
		move.l	D0,-(sp)
		move.w	#298,-(sp)
		trap	#1				; Gemdos(298)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Dclosedir
MODULE Dclosedir
; long	Dclosedir( long dirh );
		REGSave
		move.l	D0,-(sp)
		move.w	#299,-(sp)
		trap	#1				; Gemdos(299)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Fxattr
MODULE Fxattr
; long	Fxattr( short flag, const char *name, XATTR *buf );
		REGSave
		pea		(A1)
		pea		(A0)
		move.w	D0,-(sp)
		move.w	#300,-(sp)
		trap	#1				; Gemdos(300)
		lea		12(sp),sp
		REGLoad
		rts
ENDMOD

export Flink
MODULE Flink
; long	Flink( const char *oldname, const char *newname );
		REGSave
		pea		(A1)
		pea		(A0)
		move.w	#301,-(sp)
		trap	#1				; Gemdos(301)
		lea		10(sp),sp
		REGLoad
		rts
ENDMOD

export Fsymlink
MODULE Fsymlink
; long	Fsymlink( const char *oldname, const char *newname );
		REGSave
		pea		(A1)
		pea		(A0)
		move.w	#302,-(sp)
		trap	#1				; Gemdos(302)
		lea		10(sp),sp
		REGLoad
		rts
ENDMOD

export Freadlink
MODULE Freadlink
; long	Freadlink( short buflen, char *buf, const char *linkfile );
		REGSave
		pea		(A1)
		pea		(A0)
		move.w	D0,-(sp)
		move.w	#303,-(sp)
		trap	#1				; Gemdos(303)
		lea		12(sp),sp
		REGLoad
		rts
ENDMOD

export Dcntl
MODULE Dcntl
; long	Dcntl( short cmd, const char *name, long arg );
		REGSave
		move.l	D1,-(sp)
		pea		(A0)
		move.w	D0,-(sp)
		move.w	#304,-(sp)
		trap	#1				; Gemdos(304)
		lea		12(sp),sp
		REGLoad
		rts
ENDMOD

export Fchown
MODULE Fchown
; long	Fchown( const char *name, short uid, short gid );
		REGSave
		move.w	D1,-(sp)
		move.w	D0,-(sp)
		pea		(A0)
		move.w	#305,-(sp)
		trap	#1				; Gemdos(305)
		lea		10(sp),sp
		REGLoad
		rts
ENDMOD

export Fchmod
MODULE Fchmod
; long	Fchmod( const char *name, short mode );
		REGSave
		move.w	D0,-(sp)
		pea		(A0)
		move.w	#306,-(sp)
		trap	#1				; Gemdos(306)
		lea		8(sp),sp
		REGLoad
		rts
ENDMOD

export Pumask
MODULE Pumask
; long	Pumask( short mode );
		REGSave
		move.w	D0,-(sp)
		move.w	#307,-(sp)
		trap	#1				; Gemdos(307)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export Psemaphore
MODULE Psemaphore
; long	Psemaphore( short mode, long id, long timeout );
		REGSave
		move.l	D2,-(sp)
		move.l	D1,-(sp)
		move.w	D0,-(sp)
		move.w	#308,-(sp)
		trap	#1				; Gemdos(308)
		lea		12(sp),sp
		REGLoad
		rts
ENDMOD

export Dlock
MODULE Dlock
; long	Dlock( short mode, short drive );
		REGSave
		move.w	D1,-(sp)
		move.w	D0,-(sp)
		move.w	#309,-(sp)
		trap	#1				; Gemdos(309)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Psigpause
MODULE Psigpause
; long	Psigpause( long sigmask );
		REGSave
		move.l	D0,-(sp)
		move.w	#310,-(sp)
		trap	#1				; Gemdos(310)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Psigaction
MODULE Psigaction
; long	Psigaction( short sig, const SIGACTION *act, SIGACTION *oact );
		REGSave
		pea		(a1)
		pea		(a0)
		move.w	D0,-(sp)
		move.w	#311,-(sp)
		trap	#1				; Gemdos(311)
		lea		12(sp),sp
		REGLoad
		rts
ENDMOD

export Pgeteuid
MODULE Pgeteuid
; long	Pgeteuid( void );
		REGSave
		move.w	#312,-(sp)
		trap	#1				; Gemdos(312)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Pgetegid
MODULE Pgetegid
; long	Pgetegid( void );
		REGSave
		move.w	#313,-(sp)
		trap	#1				; Gemdos(313)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Pwaitpid
MODULE Pwaitpid
; long	Pwaitpid( short pid, short flag, long *rusage );
		REGSave
		pea		(A0)
		move.w	D1,-(sp)
		move.w	D0,-(sp)
		move.w	#314,-(sp)
		trap	#1				; Gemdos(314)
		lea		10(sp),sp
		REGLoad
		rts
ENDMOD

export Dgetcwd
MODULE Dgetcwd
; long	Dgetcwd( char *path, short drive, short size );
		REGSave
		move.w	D1,-(sp)
		move.w	D0,-(sp)
		pea		(A0)
		move.w	#315,-(sp)
		trap	#1				; Gemdos(315)
		lea		10(sp),sp
		REGLoad
		rts
ENDMOD

export Salert
MODULE Salert
; long	Salert( char *msg );
		REGSave
		pea		(A0)
		move.w	#316,-(sp)
		trap	#1				; Gemdos(316)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Tmalarm
MODULE Tmalarm
; long	Tmalarm( long time );
		REGSave
		move.l	D0,-(sp)
		move.w	#317,-(sp)
		trap	#1				; Gemdos(317)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Psigintr
MODULE Psigintr
; long	Psigintr( short vec, short sig );
		REGSave
		move.w	D1,-(sp)
		move.w	D0,-(sp)
		move.w	#318,-(sp)
		trap	#1				; Gemdos(318)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Suptime
MODULE Suptime
; long	Suptime( long *uptime, long loadaverage[3] );
		REGSave
		pea		(a1)
		pea		(a0)
		move.w	#319,-(sp)
		trap	#1				; Gemdos(319)
		lea		10(sp),sp
		REGLoad
		rts
ENDMOD

export Ptrace
MODULE Ptrace
; long	Ptrace( short request, short pid, void *addr, long data );
		REGSave
		move.l	D2,-(sp)
		pea		(a0)
		move.w	D1,-(sp)
		move.w	D0,-(sp)
		move.w	#320,-(sp)
		trap	#1				; Gemdos(320)
		lea		14(sp),sp
		REGLoad
		rts
ENDMOD

export Mvalidate
MODULE Mvalidate
; long	Mvalidate( short pid, void *addr, long size, long *flags );
		REGSave
		pea		(a1)
		move.l	D1,-(sp)
		pea		(a0)
		move.w	D0,-(sp)
		move.w	#321,-(sp)
		trap	#1				; Gemdos(321)
		lea		16(sp),sp
		REGLoad
		rts
ENDMOD

export Dxreaddir
MODULE Dxreaddir
; long	Dxreaddir( short len, long dirh, char *buf, XATTR *xattr,
;					long *xret );
		REGSave
		move.l	_STC+$4(sp),-(sp)
		pea		(A1)
		pea		(A0)
		move.l	D1,-(sp)
		move.w	D0,-(sp)
		move.w	#322,-(sp)
		trap	#1				; Gemdos(322)
		lea		20(sp),sp
		REGLoad
		rts
ENDMOD

export Pseteuid
MODULE Pseteuid
; long	Pseteuid( short id );
		REGSave
		move.w	D0,-(sp)
		move.w	#323,-(sp)
		trap	#1				; Gemdos(323)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export Psetegid
MODULE Psetegid
; long	Psetegid( short id );
		REGSave
		move.w	D0,-(sp)
		move.w	#324,-(sp)
		trap	#1				; Gemdos(324)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export Psetauid
MODULE Psetauid
; long	Psetauid( short id );
		REGSave
		move.w	D0,-(sp)
		move.w	#325,-(sp)
		trap	#1				; Gemdos(325)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export Pgetauid
MODULE Pgetauid
; long	Pgetauid( void );
		REGSave
		move.w	#326,-(sp)
		trap	#1				; Gemdos(326)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Pgetgroups
MODULE Pgetgroups
; long	Pgetgroups( short gidsetlen, short gidset[] );
		REGSave
		pea		(A0)
		move.w	D0,-(sp)
		move.w	#327,-(sp)
		trap	#1				; Gemdos(327)
		addq.l	#8,sp
		REGLoad
		rts
ENDMOD

export Psetgroups
MODULE Psetgroups
; long	Psetgroups( short ngroups, short gidset[] );
		REGSave
		pea		(A0)
		move.w	D0,-(sp)
		move.w	#328,-(sp)
		trap	#1				; Gemdos(328)
		addq.l	#8,sp
		REGLoad
		rts
ENDMOD

export Tsetitimer
MODULE Tsetitimer
; long	Tsetitimer( short which, long *interval, long *value,
;				long *ointerval, long *ovalue );
		REGSave
		move.l	_STC+8(sp),-(sp)
		move.l	_STC+8(sp),-(sp)
		pea		(a1)
		pea		(a0)
		move.w	D0,-(sp)
		move.w	#329,-(sp)
		trap	#1				; Gemdos(329)
		lea		20(sp),sp
		REGLoad
		rts
ENDMOD

export Dchroot
MODULE Dchroot
; long	Dchroot( const char *dir );
		REGSave
		pea		(a0)
		move.w	#330,-(sp)
		trap	#1				; Gemdos(330)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Fstat64
MODULE Fstat64
; long	Fstat64( short flag, const char *name, struct stat *stat );
		REGSave
		pea		(A1)
		pea		(A0)
		move.w	D0,-(sp)
		move.w	#331,-(sp)
		trap	#1				; Gemdos(331)
		lea		12(sp),sp
		REGLoad
		rts
ENDMOD

export Fseek64
MODULE Fseek64
; long	Fseek64( long high, long low, short fh, short how, void *newpos );
		REGSave
		pea		(A0)
		move.w	_STC+8(sp),-(sp)
		move.w	D2,-(sp)
		move.l	D1,-(sp)
		move.l	D0,-(sp)
		move.w	#332,-(sp)
		trap	#1				; Gemdos(332)
		lea		18(sp),sp
		REGLoad
		rts
ENDMOD

export Dsetkey
MODULE Dsetkey
; long	Dsetkey( long major, long minor, char *key, short cipher );
		REGSave
		move.w	D2,-(sp)
		pea		(a0)
		move.l	D1,-(sp)
		move.l	D0,-(sp)
		move.w	#333,-(sp)
		trap	#1				; Gemdos(333)
		lea		16(sp),sp
		REGLoad
		rts
ENDMOD

export Psetreuid
MODULE Psetreuid
; long	Psetreuid( short rid, short eid );
		REGSave
		move.w	D1,-(sp)
		move.w	D0,-(sp)
		move.w	#334,-(sp)
		trap	#1				; Gemdos(334)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Psetregid
MODULE Psetregid
; long	Psetregid( short rid, short eid );
		REGSave
		move.w	D1,-(sp)
		move.w	D0,-(sp)
		move.w	#335,-(sp)
		trap	#1				; Gemdos(335)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Sync
MODULE Sync
; long	Sync( void );
		REGSave
		move.w	#336,-(sp)
		trap	#1				; Gemdos(336)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Shutdown
MODULE Shutdown
; long	Shutdown( long restart );
		REGSave
		move.l	D0,-(SP)
		move.w	#337,-(sp)
		trap	#1				; Gemdos(337)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Dreadlabel
MODULE Dreadlabel
; long	Dreadlabel( const char *path, char *label, short maxlen );
		REGSave
		move.w	D0,-(sp)
		pea		(A1)
		pea		(A0)
		move.w	#338,-(sp)
		trap	#1				; Gemdos(338)
		lea		12(sp),sp
		REGLoad
		rts
ENDMOD

export Dwritelabel
MODULE Dwritelabel
; long	Dwritelabel( const char *path, const char *label );
		REGSave
		pea		(A1)
		pea		(A0)
		move.w	#339,-(sp)
		trap	#1				; Gemdos(339)
		lea		10(sp),sp
		REGLoad
		rts
ENDMOD

export Ssystem
MODULE Ssystem
; long	Ssystem( short mode, long arg1, long arg2 );
		REGSave
		move.l	D2,-(SP)
		move.l	D1,-(SP)
		move.w	D0,-(SP)
		move.w	#340,-(sp)
		trap	#1				; Gemdos(340)
		lea		12(SP),SP
		REGLoad
		rts
ENDMOD













































export Tgettimeofday
MODULE Tgettimeofday
; long	Tgettimeofday( struct timeval *tv, struct timezone *tz );
		REGSave
		pea		(A1)
		pea		(A0)
		move.w	#341,-(sp)
		trap	#1				; Gemdos(341)
		lea		10(sp),sp
		REGLoad
		rts
ENDMOD

export Tsettimeofday
MODULE Tsettimeofday
; long	Tsettimeofday( struct timeval *tv, struct timezone *tz );
		REGSave
		pea		(A1)
		pea		(A0)
		move.w	#342,-(sp)
		trap	#1				; Gemdos(342)
		lea		10(sp),sp
		REGLoad
		rts
ENDMOD

export Tadjtime
MODULE Tadjtime
; long	Tadjtime( const struct timeval *delta, struct timeval *olddelta )
		REGSave
		pea		(A1)
		pea		(A0)
		move.w	#343,-(sp)
		trap	#1				; Gemdos(343)
		lea		10(sp),sp
		REGLoad
		rts
ENDMOD

export Pgetpriority
MODULE Pgetpriority
; long	Pgetpriority( short which, short who )
		REGSave
		move.w	D1,-(SP)
		move.w	D0,-(SP)
		move.w	#344,-(sp)
		trap	#1				; Gemdos(344)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Psetpriority
MODULE Psetpriority
; long	Psetpriority( short which, short who, short prio )
		REGSave
		move.w	D2,-(SP)
		move.w	D1,-(SP)
		move.w	D0,-(SP)
		move.w	#345,-(sp)
		trap	#1				; Gemdos(345)
		addq.l	#8,sp
		REGLoad
		rts
ENDMOD

export Fpoll
MODULE Fpoll
; long	Fpoll( struct pollfd *fds, long nfds, long timeout )
		REGSave
		move.l	D1,-(SP)
		move.l	D0,-(SP)
		pea		(A0)
		move.w	#346,-(sp)
		trap	#1				; Gemdos(346)
		lea		14(sp),sp
		REGLoad
		rts
ENDMOD

export Fwritev
MODULE Fwritev
; long	Fwritev( short fh, const struct iovec *iov, long iovcnt )
		REGSave
		move.l	D1,-(SP)
		pea		(A0)
		move.w	D0,-(SP)
		move.w	#347,-(sp)
		trap	#1				; Gemdos(347)
		lea		12(sp),sp
		REGLoad
		rts
ENDMOD

export Freadv
MODULE Freadv
; long	Freadv( short fh, const struct iovec *iov, long iovcnt )
		REGSave
		move.l	D1,-(SP)
		pea		(A0)
		move.w	D0,-(SP)
		move.w	#348,-(sp)
		trap	#1				; Gemdos(348)
		lea		12(sp),sp
		REGLoad
		rts
ENDMOD

export Ffstat64
MODULE Ffstat64
; long	Ffstat64( short fh, struct stat *stat )
		REGSave
		pea		(A0)
		move.w	D0,-(SP)
		move.w	#349,-(sp)
		trap	#1				; Gemdos(349)
		addq.l	#8,sp
		REGLoad
		rts
ENDMOD

export Psysctl
MODULE Psysctl
; long	Psysctl( long *name, long namelen, void *old, long *oldlenp,
;				const void *new, long newlen )
		REGSave
		move.l	D1,-(SP)
		move.l	_STC+12(sp),-(sp)
		move.l	_STC+12(sp),-(sp)
		pea		(A1)
		move.l	D0,-(SP)
		pea		(A0)
		move.w	#350,-(sp)
		trap	#1				; Gemdos(350)
		lea		26(SP),SP
		REGLoad
		rts
ENDMOD

export Pemulation
MODULE Pemulation
; long	Pemulation( short which, short op, long a1, long a2, long a3,
;				long a4, long a5, long a6, long a7 )
		REGSave
		move.l	_STC+24(sp),-(sp)
		move.l	_STC+24(sp),-(sp)
		move.l	_STC+24(sp),-(sp)
		move.l	_STC+24(sp),-(sp)
		move.l	_STC+24(sp),-(sp)
		move.l	_STC+24(sp),-(sp)
		move.l	D2,-(SP)
		move.w	D1,-(SP)
		move.w	D0,-(SP)
		move.w	#351,-(sp)
		trap	#1				; Gemdos(351)
		lea		34(SP),SP
		REGLoad
		rts
ENDMOD

export Fsocket
MODULE Fsocket
; long	Fsocket( long domain, long type, long protocol )
		REGSave
		move.l	D2,-(SP)
		move.l	D1,-(SP)
		move.l	D0,-(SP)
		move.w	#352,-(sp)
		trap	#1				; Gemdos(352)
		lea		14(SP),SP
		REGLoad
		rts
ENDMOD

export Fsocketpair
MODULE Fsocketpair
; long	Fsocketpair( long domain, long type, long protocol, short fds[2] )
		REGSave
		pea		(A0)
		move.l	D2,-(SP)
		move.l	D1,-(SP)
		move.l	D0,-(SP)
		move.w	#353,-(sp)
		trap	#1				; Gemdos(353)
		lea		18(SP),SP
		REGLoad
		rts
ENDMOD

export Faccept
MODULE Faccept
; long	Faccept( short fh, struct sockaddr *name, long *namelen )
		REGSave
		pea		(A1)
		pea		(A0)
		move.w	D0,-(SP)
		move.w	#354,-(sp)
		trap	#1				; Gemdos(354)
		lea		12(SP),SP
		REGLoad
		rts
ENDMOD

export Fconnect
MODULE Fconnect
; long	Fconnect( short fh, const struct sockaddr *name, long namelen )
		REGSave
		move.l	D1,-(SP)
		pea		(A0)
		move.w	D0,-(SP)
		move.w	#355,-(sp)
		trap	#1				; Gemdos(355)
		lea		12(SP),SP
		REGLoad
		rts
ENDMOD

export Fbind
MODULE Fbind
; long	Fbind( short fh, const struct sockaddr *name, long namelen )
		REGSave
		move.l	D1,-(SP)
		pea		(A0)
		move.w	D0,-(SP)
		move.w	#356,-(sp)
		trap	#1				; Gemdos(356)
		lea		12(SP),SP
		REGLoad
		rts
ENDMOD

export Flisten
MODULE Flisten
; long	Flisten( short fh, long backlog )
		REGSave
		move.l	D1,-(SP)
		move.w	D0,-(SP)
		move.w	#357,-(sp)
		trap	#1				; Gemdos(357)
		addq.l	#8,SP
		REGLoad
		rts
ENDMOD

export Frecvmsg
MODULE Frecvmsg
; long	Frecvmsg( short fh, struct msghdr *msg, long flags )
		REGSave
		move.l	D1,-(SP)
		pea		(A0)
		move.w	D0,-(SP)
		move.w	#358,-(sp)
		trap	#1				; Gemdos(358)
		lea		12(SP),SP
		REGLoad
		rts
ENDMOD

export Fsendmsg
MODULE Fsendmsg
; long	Fsendmsg( short fh, const struct msghdr *msg, long flags )
		REGSave
		move.l	D1,-(SP)
		pea		(A0)
		move.w	D0,-(SP)
		move.w	#359,-(sp)
		trap	#1				; Gemdos(359)
		lea		12(SP),SP
		REGLoad
		rts
ENDMOD

export Frecvfrom
MODULE Frecvfrom
; long	Frecvfrom( short fh, void *buf, long len, long flags,
;				struct sockaddr *from, long *fromlen )
		REGSave
		move.l	_STC+4(sp),-(sp)
		pea		(A1)
		move.l	D2,-(SP)
		move.l	D1,-(SP)
		pea		(A0)
		move.w	D0,-(SP)
		move.w	#360,-(sp)
		trap	#1				; Gemdos(360)
		lea		24(SP),SP
		REGLoad
		rts
ENDMOD

export Fsendto
MODULE Fsendto
; long	Fsendto( short fh, const void *buf, long len, long flags,
;				const struct sockaddr *to, long tolen )
		REGSave
		move.l	_STC+4(sp),-(sp)
		pea		(A1)
		move.l	D2,-(SP)
		move.l	D1,-(SP)
		pea		(A0)
		move.w	D0,-(SP)
		move.w	#361,-(sp)
		trap	#1				; Gemdos(361)
		lea		24(SP),SP
		REGLoad
		rts
ENDMOD

export Fsetsockopt
MODULE Fsetsockopt
; long	Fsetsockopt( short fh, long level, long name, const void *val,
;				long valsize )
		REGSave
		move.l	_STC+4(sp),-(sp)
		pea		(A0)
		move.l	D2,-(SP)
		move.l	D1,-(SP)
		move.w	D0,-(SP)
		move.w	#362,-(sp)
		trap	#1				; Gemdos(362)
		lea		20(SP),SP
		REGLoad
		rts
ENDMOD

export Fgetsockopt
MODULE Fgetsockopt
; long	Fgetsockopt( short fh, long level, long name, void *val,
;				long *avalsize )
		REGSave
		pea		(A1)
		pea		(A0)
		move.l	D2,-(SP)
		move.l	D1,-(SP)
		move.w	D0,-(SP)
		move.w	#363,-(sp)
		trap	#1				; Gemdos(363)
		lea		20(SP),SP
		REGLoad
		rts
ENDMOD

export Fgetpeername
MODULE Fgetpeername
; long	Fgetpeername( short fh, struct sockaddr *addr, long addrlen )
		REGSave
		move.l	D1,-(SP)
		pea		(A0)
		move.w	D0,-(SP)
		move.w	#364,-(sp)
		trap	#1				; Gemdos(364)
		lea		12(SP),SP
		REGLoad
		rts
ENDMOD

export Fgetsockname
MODULE Fgetsockname
; long	Fgetsockname( short fh, struct sockaddr *addr, long addrlen )
		REGSave
		move.l	D1,-(SP)
		pea		(A0)
		move.w	D0,-(SP)
		move.w	#365,-(sp)
		trap	#1				; Gemdos(365)
		lea		12(SP),SP
		REGLoad
		rts
ENDMOD

export Fshutdown
MODULE Fshutdown
; long	Fshutdown( short fh, long how )
		REGSave
		move.l	D1,-(SP)
		move.w	D0,-(SP)
		move.w	#366,-(sp)
		trap	#1				; Gemdos(366)
		addq.l	#8,SP
		REGLoad
		rts
ENDMOD

export Pshmget
MODULE Pshmget
; long	Pshmget( long key, long size, long shmflg )
		REGSave
		move.l	D2,-(SP)
		move.l	D1,-(SP)
		move.l	D0,-(SP)
		move.w	#368,-(sp)
		trap	#1				; Gemdos(368)
		lea		14(SP),SP
		REGLoad
		rts
ENDMOD

export Pshmctl
MODULE Pshmctl
; long	Pshmctl( long shmid, long cmd, struct shmid_ds *buf )
		REGSave
		pea		(A0)
		move.l	D1,-(SP)
		move.l	D0,-(SP)
		move.w	#369,-(sp)
		trap	#1				; Gemdos(369)
		lea		14(SP),SP
		REGLoad
		rts
ENDMOD

export Pshmat
MODULE Pshmat
; long	Pshmat( long shmid, const void *shmaddr, long shmflg )
		REGSave
		move.l	D1,-(SP)
		pea		(A0)
		move.l	D0,-(SP)
		move.w	#370,-(sp)
		trap	#1				; Gemdos(370)
		lea		14(SP),SP
		REGLoad
		rts
ENDMOD

export Pshmdt
MODULE Pshmdt
; long	Pshmdt( const void *shmaddr )
		REGSave
		pea		(A0)
		move.w	#371,-(sp)
		trap	#1				; Gemdos(371)
		addq.l	#6,SP
		REGLoad
		rts
ENDMOD

export Psemget
MODULE Psemget
; long	Psemget( long key, long nsems, long semflg )
		REGSave
		move.l	D2,-(SP)
		move.l	D1,-(SP)
		move.l	D0,-(SP)
		move.w	#372,-(sp)
		trap	#1				; Gemdos(372)
		lea		14(SP),SP
		REGLoad
		rts
ENDMOD

export Psemctl
MODULE Psemctl
; long	Psemctl( long semid, long semnum, long cmd, union __semun *arg )
		REGSave
		pea		(A0)
		move.l	D2,-(SP)
		move.l	D1,-(SP)
		move.l	D0,-(SP)
		move.w	#373,-(sp)
		trap	#1				; Gemdos(373)
		lea		18(SP),SP
		REGLoad
		rts
ENDMOD

export Psemop
MODULE Psemop
; long	Psemop( long semid, struct sembuf *sops, long nsops )
		REGSave
		move.l	D1,-(SP)
		pea		(A0)
		move.l	D0,-(SP)
		move.w	#374,-(sp)
		trap	#1				; Gemdos(374)
		lea		14(SP),SP
		REGLoad
		rts
ENDMOD

export Psemconfig
MODULE Psemconfig
; long	Psemconfig( long flag )
		REGSave
		move.l	D0,-(SP)
		move.w	#375,-(sp)
		trap	#1				; Gemdos(375)
		addq.l	#6,SP
		REGLoad
		rts
ENDMOD

export Pmsgget
MODULE Pmsgget
; long	Pmsgget( long key, long msgflg )
		REGSave
		move.l	D1,-(SP)
		move.l	D0,-(SP)
		move.w	#376,-(sp)
		trap	#1				; Gemdos(376)
		lea		10(SP),SP
		REGLoad
		rts
ENDMOD

export Pmsgctl
MODULE Pmsgctl
; long	Pmsgctl( long msqid, long cmd, struct msqid_ds *buf )
		REGSave
		pea		(A0)
		move.l	D1,-(SP)
		move.l	D0,-(SP)
		move.w	#377,-(sp)
		trap	#1				; Gemdos(377)
		lea		14(SP),SP
		REGLoad
		rts
ENDMOD

export Pmsgsnd
MODULE Pmsgsnd
; long	Pmsgsnd( long msqid, const void *msgp, long msgsz, long msgflg )
		REGSave
		move.l	D2,-(SP)
		move.l	D1,-(SP)
		pea		(A0)
		move.l	D0,-(SP)
		move.w	#378,-(sp)
		trap	#1				; Gemdos(378)
		lea		18(SP),SP
		REGLoad
		rts
ENDMOD

export Pmsgrcv
MODULE Pmsgrcv
; long	Pmsgrcv( long msqid, void *msgp, long msgsz, long msgtyp,
;				long msgflg )
		REGSave
		move.l	_STC+4(sp),-(sp)
		move.l	D2,-(SP)
		move.l	D1,-(SP)
		pea		(A0)
		move.l	D0,-(SP)
		move.w	#379,-(sp)
		trap	#1				; Gemdos(379)
		lea		22(SP),SP
		REGLoad
		rts
ENDMOD

export Maccess
MODULE Maccess
; long	Maccess( void *addr, long size, short mode )
		REGSave
		move.w	D1,-(SP)
		move.l	D0,-(SP)
		pea		(A0)
		move.w	#321,-(sp)
		trap	#1				; Gemdos(321)
		lea		12(SP),SP
		REGLoad
		rts
ENDMOD

export Fchown16
MODULE Fchown16
; long	Fchown16( const char *name, short uid, short gid, 
;				short follow_links )
		REGSave
		move.w	D2,-(SP)
		move.w	D1,-(SP)
		move.w	D0,-(SP)
		pea		(A0)
		move.w	#384,-(sp)
		trap	#1				; Gemdos(384)
		lea		12(SP),SP
		REGLoad
		rts
ENDMOD


