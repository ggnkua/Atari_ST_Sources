/*----------------------------------------------------------------------------------------
	gemdos.cp, part of TOS Linker for CodeWarrior

	Gemdos system calls for TOS
	CodeWarrior version
	
	21.10.1998 by Manfred Lippert

	last change: 30.11.2000

	Don't edit this file.

	If you have to make any changes on this file, please contact:
	mani@mani.de
----------------------------------------------------------------------------------------*/

#include <gemdos.h>

#ifndef __MWERKS__
	#error This Source (gemdos.cp) is for Metrowerks CodeWarrior only
#endif


#define GEMDOS_0(nr)	pea (a2); \
						move.w %nr,-(sp); \
						trap %1; \
						addq.l %2,sp; \
						move.l (sp)+,a2

#define GEMDOS_2(nr)	pea (a2); \
						move.w 8(sp),-(sp); \
						move.w %nr,-(sp); \
						trap %1; \
						addq.l %4,sp; \
						move.l (sp)+,a2
						
#define GEMDOS_4(nr)	pea (a2); \
						move.l 8(sp),-(sp); \
						move.w %nr,-(sp); \
						trap %1; \
						addq.l %6,sp; \
						move.l (sp)+,a2

#define GEMDOS_6(nr)	pea (a2); \
						move.l 10(sp),-(sp); \
						move.w 12(sp),-(sp); \
						move.w %nr,-(sp); \
						trap %1; \
						addq.l %8,sp; \
						move.l (sp)+,a2

#define GEMDOS_8(nr)	pea (a2); \
						move.l 12(sp),-(sp); \
						move.l 12(sp),-(sp); \
						move.w %nr,-(sp); \
						trap %1; \
						lea 10(sp),sp; \
						move.l (sp)+,a2

#define GEMDOS_10(nr)	pea (a2); \
						move.l 14(sp),-(sp); \
						move.l 14(sp),-(sp); \
						move.w 16(sp),-(sp); \
						move.w %nr,-(sp); \
						trap %1; \
						lea 12(sp),sp; \
						move.l (sp)+,a2

#define GEMDOS_12(nr)	pea (a2); \
						move.l 16(sp),-(sp); \
						move.l 16(sp),-(sp); \
						move.l 16(sp),-(sp); \
						move.w %nr,-(sp); \
						trap %1; \
						lea 14(sp),sp; \
						move.l (sp)+,a2

#define GEMDOS_14(nr)	pea (a2); \
						move.l 18(sp),-(sp); \
						move.l 18(sp),-(sp); \
						move.l 18(sp),-(sp); \
						move.w 20(sp),-(sp); \
						move.w %nr,-(sp); \
						trap %1; \
						lea 16(sp),sp; \
						move.l (sp)+,a2

#define GEMDOS_18(nr)	pea (a2); \
						move.l 22(sp),-(sp); \
						move.l 22(sp),-(sp); \
						move.l 22(sp),-(sp); \
						move.l 22(sp),-(sp); \
						move.w 24(sp),-(sp); \
						move.w %nr,-(sp); \
						trap %1; \
						lea 20(sp),sp; \
						move.l (sp)+,a2

#define GEMDOS_20(nr)	pea (a2); \
						move.l 24(sp),-(sp); \
						move.l 24(sp),-(sp); \
						move.l 24(sp),-(sp); \
						move.l 24(sp),-(sp); \
						move.l 24(sp),-(sp); \
						move.w %nr,-(sp); \
						trap %1; \
						lea 22(sp),sp; \
						move.l (sp)+,a2

#define GEMDOS_24(nr)	pea (a2); \
						move.l 28(sp),-(sp); \
						move.l 28(sp),-(sp); \
						move.l 28(sp),-(sp); \
						move.l 28(sp),-(sp); \
						move.l 28(sp),-(sp); \
						move.l 28(sp),-(sp); \
						move.w %nr,-(sp); \
						trap %1; \
						lea 26(sp),sp; \
						move.l (sp)+,a2

asm int16 CDECL	Cauxin(void)
{
	GEMDOS_0(3)
	rts
}
asm int16 CDECL	Cauxis(void)
{
	GEMDOS_0(18)
	rts
}
asm int16 CDECL	Cauxos(void)
{
	GEMDOS_0(19)
	rts
}
asm void CDECL	Cauxout(int16 c)
{
	GEMDOS_2(4)
	rts
}
asm int32 CDECL	Cconin(void)
{
	GEMDOS_0(1)
	rts
}
asm int16 CDECL	Cconis(void)
{
	GEMDOS_0(11)
	rts
}
asm int16 CDECL	Cconos(void)
{
	GEMDOS_0(16)
	rts
}
asm void CDECL	Cconout(int16 c)
{
	GEMDOS_2(2)
	rts
}
asm int32 CDECL	Cconrs(LINE *buf)
{
	GEMDOS_4(10)
	rts
}
asm int16 CDECL	Cconws(const char *buf)
{
	GEMDOS_4(9)
	rts
}
asm int32 CDECL	Cnecin(void)
{
	GEMDOS_0(8)
	rts
}
asm int16 CDECL	Cprnos(void)
{
	GEMDOS_0(17)
	rts
}
asm int16 CDECL	Cprnout(int16 c)
{
	GEMDOS_2(5)
	rts
}
asm int32 CDECL	Crawcin(void)
{
	GEMDOS_0(7)
	rts
}
asm int32 CDECL	Crawio(int16 w)
{
	GEMDOS_2(6)
	rts
}
asm int32 CDECL	Dclosedir(int32 handle)
{
	GEMDOS_4(299)
	rts
}
asm int32 CDECL	Dcntl(int16 cmd, char *name, int32 arg)
{
	GEMDOS_10(304)
	rts
}
asm int32 CDECL	Dcreate(const char *path)
{
	GEMDOS_4(57)
	rts
}
asm int32 CDECL	Ddelete(const char *path)
{
	GEMDOS_4(58)
	rts
}
asm int16 CDECL	Dfree(DISKINFO *buf, int16 driveno)
{
	GEMDOS_6(54)
	rts
}
asm int16 CDECL	Dgetcwd(char *path, int16 drv, int16 size)
{
	GEMDOS_8(316)
	rts
}
asm int16 CDECL	Dgetdrv(void)
{
	GEMDOS_0(25)
	rts
}
asm int16 CDECL	Dgetpath(char *path, int16 driveno)
{
	GEMDOS_6(71)
	rts
}
asm int32 CDECL	Dlock(int16 mode, int16 drv)
{
	GEMDOS_4(309)
	rts
}
asm int32 CDECL	Dopendir(char *path, int16 flag)
{
	GEMDOS_6(296)
	rts
}
asm int32 CDECL	Dpathconf(char *path, int16 mode)
{
	GEMDOS_6(292)
	rts
}
asm int32 CDECL	Dreaddir(int16 len, int32 handle, char *buf)
{
	GEMDOS_10(297)
	rts
}
asm int32 CDECL	Dreadlabel(const char *path, char *label, int16 len)
{
	GEMDOS_10(338)
	rts
}
asm int32 CDECL	Drewinddir(int32 handle)
{
	GEMDOS_4(298)
	rts
}
asm int32 CDECL	Dsetdrv(int16 drv)
{
	GEMDOS_2(14)
	rts
}
asm int16 CDECL	Dsetpath(const char *path)
{
	GEMDOS_4(59)
	rts
}
asm int32 CDECL	Dwritelabel(const char *path, const char *label)
{
	GEMDOS_8(339)
	rts
}
asm int32 CDECL	Dxreaddir(int16 len, int32 handle, char *buf, XATTR *xattr, int32 *xret)
{
	GEMDOS_18(322)
	rts
}
asm int16 CDECL	Fattrib(const char *filename, int16 wflag, int16 attrib)
{
	GEMDOS_8(67)
	rts
}
asm int32 CDECL	Fchmod(char *filename, int16 mode)
{
	GEMDOS_6(306)
	rts
}
asm int32 CDECL	Fchown(char *filename, int16 uid, int16 gid)
{
	GEMDOS_8(305)
	rts
}
asm int16 CDECL	Fclose(int16 handle)
{
	GEMDOS_2(62)
	rts
}
asm int32 CDECL	Fcntl(int16 handle, int32 arg, int16 cmd)
{
	GEMDOS_8(260)
	rts
}
asm int32 CDECL	Fcreate(const char *filename, int16 attr)
{
	GEMDOS_6(60)
	rts
}
asm int16 CDECL	Fdatime(DOSTIME *timeptr, int16 handle, int16 wflag)
{
	GEMDOS_8(87)
	rts
}
asm int32 CDECL	Fdelete(const char *filename)
{
	GEMDOS_4(65)
	rts
}
asm int32 CDECL	Fdup(int16 handle)
{
	GEMDOS_2(69)
	rts
}
asm int16 CDECL	Fforce(int16 stch, int16 nonstdh)
{
	GEMDOS_4(70)
	rts
}
asm int32 CDECL	Fgetchar(int16 handle, int16 mode)
{
	GEMDOS_4(263)
	rts
}
asm DTA* CDECL	Fgetdta(void)
{
	GEMDOS_0(47)
	movea.l d0,a0
	rts
}
asm int32 CDECL	Finstat(int16 handle)
{
	GEMDOS_2(261)
	rts
}
asm int32 CDECL	Flink(char *oldname, char *newname)
{
	GEMDOS_8(301)
	rts
}
asm int32 CDECL	Flock(int16 handle, int16 mode, int32 start, int32 size)
{
	GEMDOS_12(92)
	rts
}
asm int32 CDECL	Fmidipipe(int16 pid, int16 in, int16 out)
{
	GEMDOS_6(294)
	rts
}
asm int32 CDECL	Fopen(const char *filename, int16 mode)
{
	GEMDOS_6(61)
	rts
}
asm int32 CDECL	Foutstat(int16 handle)
{
	GEMDOS_2(262)
	rts
}
asm int32 CDECL	Fpipe(int16 usrh[2])
{
	GEMDOS_4(256)
	rts
}
asm int32 CDECL	Fputchar(int16 handle, int32 c, int16 mode)
{
	GEMDOS_8(264)
	rts
}
asm int32 CDECL	Fread(int16 handle, int32 count, void *buf)
{
	GEMDOS_10(63)
	rts
}
asm int32 CDECL	Freadlink(int16 len, char *buf, char *name)
{
	GEMDOS_10(303)
	rts
}
asm int16 CDECL	Frename(int16 zero, const char *oldname, const char *newname)
{
	GEMDOS_10(86)
	rts
}
asm int32 CDECL	Fseek(int32 offset, int16 handle, int16 seekmode)
{
	GEMDOS_8(66)
	rts
}
asm int32 CDECL	Fselect(int16 timeout, int32 *rfds, int32 *wfds, int32 zero)
{
	GEMDOS_14(285)
	rts
}
asm void CDECL	Fsetdta(DTA *buf)
{
	GEMDOS_4(26)
	rts
}
asm int16 CDECL	Fsfirst(const char *filename, int16 attr)
{
	GEMDOS_6(78)
	rts
}
asm int16 CDECL	Fsnext(void)
{
	GEMDOS_0(79)
	rts
}
asm int32 CDECL	Fsymlink(char *oldname, char *newname)
{
	GEMDOS_8(302)
	rts
}
asm int32 CDECL	Fwrite(int16 handle, int32 count, const void *buf)
{
	GEMDOS_10(64)
	rts
}
asm int32 CDECL	Fxattr(int16 flag, char *filename, XATTR *xattr)
{
	GEMDOS_10(300)
	rts
}
asm int32 CDECL	Maddalt(void *start, int32 size)
{
	GEMDOS_8(20)
	rts
}
asm void* CDECL	Malloc(int32 number)
{
	GEMDOS_4(72)
	movea.l d0,a0
	rts
}
asm int16 CDECL	Mfree(void *block)
{
	GEMDOS_4(73)
	rts
}
asm int32 CDECL	Mshrink(int16 zero, void *block, int32 newsiz)
{
	GEMDOS_10(74)
	rts
}
asm void* CDECL	Mxalloc(int32 number, int16 mode)
{
	GEMDOS_6(68)
	movea.l d0,a0
	rts
}
asm int32 CDECL	Pause(void)
{
	GEMDOS_0(289)
	rts
}
asm int32 CDECL	Pdomain(int16 mode)
{
	GEMDOS_2(281)
	rts
}
asm int32 CDECL	Pexec(int16 mode, void *ptr1, void *ptr2, void *ptr3)
{
	GEMDOS_14(75)
	rts
}
asm int32 CDECL	Pfork(void)
{
	GEMDOS_0(283)
	rts
}
asm int32 CDECL	Pgetauid(void)
{
	GEMDOS_0(326)
	rts
}
asm int32 CDECL	Pgetegid(void)
{
	GEMDOS_0(313)
	rts
}
asm int32 CDECL	Pgeteuid(void)
{
	GEMDOS_0(312)
	rts
}
asm int32 CDECL	Pgetgid(void)
{
	GEMDOS_0(276)
	rts
}
asm int32 CDECL	Pgetpgrp(void)
{
	GEMDOS_0(269)
	rts
}
asm int32 CDECL	Pgetpid(void)
{
	GEMDOS_0(267)
	rts
}
asm int32 CDECL	Pgetppid(void)
{
	GEMDOS_0(268)
	rts
}
asm int32 CDECL	Pgetuid(void)
{
	GEMDOS_0(271)
	rts
}
asm int32 CDECL	Pkill(int16 pid, int16 sig)
{
	GEMDOS_4(273)
	rts
}
asm int32 CDECL	Pmsg(int16 mode, int32 mbox, MSG *msg)
{
	GEMDOS_10(293)
	rts
}
asm int32 CDECL	Pnice(int16 delta)
{
	GEMDOS_2(266)
	rts
}
asm int32 CDECL	Prenice(int16 pid, int16 delta)
{
	GEMDOS_4(295)
	rts
}
asm int32 CDECL	Prusage(int32 *r)
{
	GEMDOS_4(286)
	rts
}
asm int32 CDECL	Psemaphore(int16 mode, int32 id, int32 timeout)
{
	GEMDOS_10(308)
	rts
}
asm int32 CDECL	Psetauid(int16 id)
{
	GEMDOS_2(325)
	rts
}
asm int32 CDECL	Psetgid(int16 id)
{
	GEMDOS_2(277)
	rts
}
asm int32 CDECL	Psetlimit(int16 lim, int32 value)
{
	GEMDOS_6(287)
	rts
}
asm int32 CDECL	Psetpgrp(int16 id, int16 newgrp)
{
	GEMDOS_4(270)
	rts
}
asm int32 CDECL	Psetuid(int16 id)
{
	GEMDOS_2(272)
	rts
}
asm int32 CDECL	Psigaction(int16 sig, SIGACTION *act, SIGACTION *ocat)
{
	GEMDOS_10(311)
	rts
}
asm int32 CDECL	Psigblock(int32 mask)
{
	GEMDOS_4(278)
	rts
}
asm int32 CDECL	Psignal(int16 sig, int32 handler)
{
	GEMDOS_6(274)
	rts
}
asm int32 CDECL	Psigpause(int32 mask)
{
	GEMDOS_4(310)
	rts
}
asm int32 CDECL	Psigpending(void)
{
	GEMDOS_0(291)
	rts
}
asm int32 CDECL	Psigreturn(void)
{
	GEMDOS_0(282)
	rts
}
asm int32 CDECL	Psigsetmask(int32 mask)
{
	GEMDOS_4(279)
	rts
}
asm void CDECL	Pterm(int16 retcode)
{
	GEMDOS_2(76)
	rts
}
asm void CDECL	Pterm0(void)
{
	GEMDOS_0(0)
	rts
}
asm void CDECL	Ptermres(int32 keepcnt, int16 retcode)
{
	GEMDOS_6(49)
	rts
}
asm int32 CDECL	Pumask(int16 mode)
{
	GEMDOS_2(307)
	rts
}
asm int32 CDECL	Pusrval(int32 val)
{
	GEMDOS_4(280)
	rts
}
asm int32 CDECL	Pvfork(void)
{
	GEMDOS_0(275)
	rts
}
asm int32 CDECL	Pwait(void)
{
	GEMDOS_0(265)
	rts
}
asm int32 CDECL	Pwait3(int16 flag, int32 *rusage)
{
	GEMDOS_6(284)
	rts
}
asm int32 CDECL	Pwaitpid(int16 pid, int16 flag, int32 *rusage)
{
	GEMDOS_8(314)
	rts
}
asm int32 CDECL	Salert(char *msg)
{
	GEMDOS_4(316)
	rts
}
asm int32 CDECL	Slbopen(char *name, char *path, int32 min_ver, SHARED_LIB *sl, SLB_EXEC *fn, int32 para)
{
	GEMDOS_24(22)
	rts
}
asm int32 CDECL	Slbclose(SHARED_LIB *sl)
{
	GEMDOS_4(23)
	rts
}
asm int32 CDECL	Sconfig(int16 mode, int32 flags)
{
	GEMDOS_6(51)
	rts
}
asm int32 CDECL	Srealloc(int32 len)
{
	GEMDOS_4(316)
	rts
}
asm int32 CDECL	Super(void *stack)
{
	GEMDOS_4(32)
	rts
}
asm int32 CDECL	Ssystem(int16 mode, int32 arg1, int32 arg2)
{
	GEMDOS_10(340)
	rts
}
asm int16 CDECL	Sversion(void)
{
	GEMDOS_0(48)
	rts
}
asm int32 CDECL	Syield(void)
{
	GEMDOS_0(255)
	rts
}
asm int32 CDECL	Sysconf(int16 n)
{
	GEMDOS_2(290)
	rts
}
asm int32 CDECL	Talarm(int32 time)
{
	GEMDOS_4(288)
	rts
}
asm uint16 CDECL	Tgetdate(void)
{
	GEMDOS_0(42)
	rts
}
asm uint16 CDECL	Tgettime(void)
{
	GEMDOS_0(44)
	rts
}
asm uint16 CDECL	Tsetdate(uint16 date)
{
	GEMDOS_2(43)
	rts
}
asm int32 CDECL	Tsetitimer(int32 which, int32 interval, int32 value, int32 ointerval, int32 ovalue)
{
	GEMDOS_20(329)
	rts
}
asm uint16 CDECL	Tsettime(uint16 time)
{
	GEMDOS_2(45)
	rts
}
