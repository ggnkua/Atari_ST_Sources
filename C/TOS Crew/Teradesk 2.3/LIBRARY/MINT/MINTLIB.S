;*
;* Teradesk. Copyright (c) 1993, 2002, W. Klaren.
;*
;* This file is part of Teradesk.
;*
;* Teradesk is free software; you can redistribute it and/or modify
;* it under the terms of the GNU General Public License as published by
;* the Free Software Foundation; either version 2 of the License, or
;* (at your option) any later version.
;*
;* Teradesk is distributed in the hope that it will be useful,
;* but WITHOUT ANY WARRANTY; without even the implied warranty of
;* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;* GNU General Public License for more details.
;*
;* You should have received a copy of the GNU General Public License
;* along with Teradesk; if not, write to the Free Software
;* Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
;*

			XDEF	Dsetdrv, Dgetdrv, Tgetdate, Tgettime, Dfree
			XDEF	Fforce, Pexec, Fdatime, Fcntl, Pgetpid, Pgetppid
			XDEF	Pgetpgrp, Psetpgrp, Pgetuid, Psetuid, Pkill
			XDEF	Psignal, Pvfork, Pgetgid, Psetgid, Psigblock
			XDEF	Psigsetmask, Pdomain, Psigreturn, Pfork, Talarm
			XDEF	Pause, Dlock, Pwaitpid
			XDEF	Fselect, Finstat, Pwait3, Foutstat, Fgetchar
			XDEF	Fputchar,Ssystem

* long Dsetdrv(short drv);

			MODULE	Dsetdrv

			move.l	a2,-(a7)
			move	d0,-(a7)
			move	#14,-(a7)
			trap	#1
			addq.l	#4,a7
			move.l	(a7)+,a2
			rts

			ENDMOD

* short Dgetdrv(void);

			MODULE	Dgetdrv

			move.l	a2,-(a7)
			move	#25,-(a7)
			trap	#1
			addq.l	#2,a7
			move.l	(a7)+,a2
			rts

			ENDMOD

* unsigned short Tgetdate(void);

			MODULE	Tgetdate

			move.l	a2,-(a7)
			move	#42,-(a7)
			trap	#1
			addq.l	#2,a7
			move.l	(a7)+,a2
			rts

			ENDMOD

* unsigned short Tgettime(void);

			MODULE	Tgettime

			move.l	a2,-(a7)
			move	#44,-(a7)
			trap	#1
			addq.l	#2,a7
			move.l	(a7)+,a2
			rts

			ENDMOD

* short Dfree(long *data, short drv);

			MODULE Dfree

			move.l	a2,-(a7)

			move	d0,-(a7)
			move.l	a0,-(a7)
			move	#54,-(a7)
			trap	#1
			addq.l	#8,a7

			move.l	(a7)+,a2
			rts

			ENDMOD

* short Fforce(short stdh, short nonstdh);

			MODULE	Fforce

			move.l	a2,-(a7)

			move	d1,-(a7)
			move	d0,-(a7)
			move	#$46,-(a7)
			trap	#1
			addq.l	#6,a7

			move.l	(a7)+,a2
			rts

			ENDMOD

* long Pexec(short mode, void *ptr1, void *ptr2, void *ptr3);

			MODULE	Pexec

			move.l	a2,-(a7)

			move.l	8(a7),-(a7)
			move.l	a1,-(a7)
			move.l	a0,-(a7)
			move	d0,-(a7)
			move	#75,-(a7)
			trap	#1
			lea		16(a7),a7

			move.l	(a7)+,a2
			rts

			ENDMOD

* short Fdatime(DOSTIME *time,short handle,short wflag);

			MODULE	Fdatime

			move.l	a2,-(a7)

			move	d1,-(a7)
			move	d0,-(a7)
			move.l	a0,-(a7)
			move	#87,-(a7)
			trap	#1
			lea		10(a7),a7

			move.l	(a7)+,a2
			rts

			ENDMOD

* long Fcntl(short fh, long arg, short cmd);

			MODULE	Fcntl

			move.l	a2,-(a7)

			move	d2,-(a7)
			move.l	d1,-(a7)
			move	d0,-(a7)
			move	#$104,-(a7)
			trap	#1
			lea		10(a7),a7

			move.l	(a7)+,a2
			rts

			ENDMOD

* long Finstat( int f );

			MODULE	Finstat

			move.l	a2,-(a7)

			move	d0,-(a7)
			move	#$105,-(a7)
			trap	#1
			addq.l	#4,a7

			move.l	(a7)+,a2
			rts

			ENDMOD

* long Foutstat( int f );

			MODULE	Foutstat

			move.l	a2,-(a7)

			move	d0,-(a7)
			move	#$106,-(a7)
			trap	#1
			addq.l	#4,a7

			move.l	(a7)+,a2
			rts

			ENDMOD

* long Fgetchar( int f, int mode );

			MODULE	Fgetchar

			move.l	a2,-(a7)

			move	d1,-(a7)
			move	d0,-(a7)
			move	#$107,-(a7)
			trap	#1
			addq.l	#6,a7

			move.l	(a7)+,a2
			rts

			ENDMOD

* long Fputchar( int f, long c, int mode );

			MODULE	Fputchar

			move.l	a2,-(a7)

			move	d2,-(a7)
			move.l	d1,-(a7)
			move	d0,-(a7)
			move	#$108,-(a7)
			trap	#1
			lea		10(a7),a7

			move.l	(a7)+,a2
			rts

			ENDMOD

* short Pgetpid(void);

			MODULE	Pgetpid

			move.l	a2,-(a7)

			move	#$10B,-(a7)
			trap	#1
			addq.l	#2,a7

			move.l	(a7)+,a2
			rts

			ENDMOD

* short Pgetppid(void);

			MODULE	Pgetppid

			move.l	a2,-(a7)

			move	#$10c,-(a7)
			trap	#1
			addq.l	#2,a7

			move.l	(a7)+,a2
			rts

			ENDMOD

* short Pgetpgrp(void);

			MODULE	Pgetpgrp

			move.l	a2,-(a7)

			move	#$10d,-(a7)
			trap	#1
			addq.l	#2,a7

			move.l	(a7)+,a2
			rts

			ENDMOD


* short Psetpgrp(short pid, short grp);

			MODULE	Psetpgrp

			move.l	a2,-(a7)

			move	d1,-(a7)
			move	d0,-(a7)
			move	#$10e,-(a7)
			trap	#1
			addq.l	#6,a7

			move.l	(a7)+,a2
			rts

			ENDMOD

* short Pgetuid(void);

			MODULE	Pgetuid

			move.l	a2,-(a7)

			move	#$10f,-(a7)
			trap	#1
			addq.l	#2,a7

			move.l	(a7)+,a2
			rts

			ENDMOD

* short Psetuid(short id);

			MODULE	Psetuid

			move.l	a2,-(a7)

			move	d0,-(a7)
			move	#$110,-(a7)
			trap	#1
			addq.l	#4,a7

			move.l	(a7)+,a2
			rts

			ENDMOD

* short Pkill(short pid, short sig);

			MODULE	Pkill

			move.l	a2,-(a7)

			move	d1,-(a7)
			move	d0,-(a7)
			move	#$111,-(a7)
			trap	#1
			addq.l	#6,a7

			move.l	(a7)+,a2
			rts

			ENDMOD

* void *Psignal(short sig, void *handler);

			MODULE	Psignal

			move.l	a2,-(a7)

			move.l	a0,-(a7)		; HR
			move	d0,-(a7)
			move	#$112,-(a7)
			trap	#1
			addq.l	#8,a7
			move.l	d0, a0			; HR
			move.l	(a7)+,a2
			rts

			ENDMOD


* short Pvfork(void);
*
* Only use with vfork, it saves a part of the stack.

			MODULE	Pvfork

			move.l	a2,save_a2
			move.l	(a7),save_r1
			move.l	4(a7),save_d3
			move.l	8(a7),save_a22
			move.l	12(a7),save_a3
			move.l	16(a7),save_r2

			move	#$113,-(a7)
			trap	#1
			addq.l	#2,a7

			move.l	save_r2,16(a7)
			move.l	save_a3,12(a7)
			move.l	save_a22,8(a7)
			move.l	save_d3,4(a7)
			move.l	save_r1,(a7)
			move.l	save_a2,a2
			rts

save_a2:	ds.l	1
save_r1:	ds.l	1
save_d3:	ds.l	1
save_a22:	ds.l	1
save_a3:	ds.l	1
save_r2:	ds.l	1

			ENDMOD

* short Pgetgid(void);

			MODULE	Pgetgid

			move.l	a2,-(a7)

			move	#$114,-(a7)
			trap	#1
			addq.l	#2,a7

			move.l	(a7)+,a2
			rts

			ENDMOD

* short Psetgid(short id);

			MODULE	Psetgid

			move.l	a2,-(a7)

			move	d0,-(a7)
			move	#$115,-(a7)
			trap	#1
			addq.l	#4,a7

			move.l	(a7)+,a2
			rts

			ENDMOD

* unsigned long Psigblock(unsigned long mask)

			MODULE	Psigblock

			move.l	a2,-(a7)

			move.l	d0,-(a7)
			move	#$116,-(a7)
			trap	#1
			addq.l	#6,a7

			move.l	(a7)+,a2
			rts

			ENDMOD

* unsigned long Psigsetmask(unsigned long mask)

			MODULE	Psigsetmask

			move.l	a2,-(a7)

			move.l	d0,-(a7)
			move	#$117,-(a7)
			trap	#1
			addq.l	#6,a7

			move.l	(a7)+,a2
			rts

			ENDMOD

* short Pdomain(short newdomain);

			MODULE	Pdomain

			move.l	a2,-(a7)

			move	d0,-(a7)
			move	#$119,-(a7)
			trap	#1
			addq.l	#4,a7

			move.l	(a7)+,a2
			rts

			ENDMOD

* void Psigreturn(void);

			MODULE	Psigreturn

			move.l	a2,-(a7)
			move	#$11A,-(a7)
			trap	#1
			addq.l	#2,a7
			move.l	(a7)+,a2
			rts

			ENDMOD

* short Pfork(void);

			MODULE	Pfork

			move.l	a2,-(a7)

			move	#$11B,-(a7)
			trap	#1
			addq.l	#2,a7

			move.l	(a7)+,a2
			rts

			ENDMOD

* long Pwait3(int flag, long *rusage);

			MODULE	Pwait3

			move.l	a2,-(a7)

			move.l	a0,-(a7)
			move	d0,-(a7)
			move	#$11C,-(a7)
			trap	#1
			addq.l	#8,a7

			move.l	(a7)+,a2
			rts

			ENDMOD

* int Fselect(unsigned int timeout, long *rfds, long *wfds, long *xfds);

			MODULE	Fselect

			move.l	a2,-(a7)

			move.l	8(a7),-(a7)
			move.l	a1,-(a7)
			move.l	a0,-(a7)
			move	d0,-(a7)
			move	#$11D,-(a7)
			trap	#1
			lea		16(a7),a7

			move.l	(a7)+,a2
			rts

			ENDMOD

* long Talarm(long seconds);

			MODULE	Talarm

			move.l	a2,-(a7)
			move.l	d0,-(a7)
			move	#$120,-(a7)
			trap	#1
			addq.l	#6,a7
			move.l	(a7)+,a2
			rts

			ENDMOD

* void Pause(void);

			MODULE	Pause

			move.l	a2,-(a7)
			move	#$121,-(a7)
			trap	#1
			addq.l	#2,a7
			move.l	(a7)+,a2
			rts

			ENDMOD

* int Dlock(int mode, int drive);

			MODULE	Dlock

			move.l	a2,-(a7)

			move	d1,-(a7)
			move	d0,-(a7)
			move	#$135,-(a7)
			trap	#1
			addq.l	#6,a7

			move.l	(a7)+,a2
			rts


			ENDMOD

* long Pwaitpid(short pid, short nohang, long *rusage);

			MODULE	Pwaitpid

			move.l	a2,-(a7)

			move.l	a0,-(a7)
			move	d1,-(a7)
			move	d0,-(a7)
			move	#$13a,-(a7)
			trap	#1
			lea		10(a7),a7

			move.l	(a7)+,a2
			rts

			ENDMOD

* long Ssystem(short mode, long arg1, long arg2);

			MODULE	Ssystem

			move.l	a2,-(a7)

			move.l	d2,-(a7)
			move.l	d1,-(a7)
			move	d0,-(a7)
			move	#$154,-(a7)
			trap	#1
			lea		12(a7),a7

			move.l	(a7)+,a2
			rts

			ENDMOD			