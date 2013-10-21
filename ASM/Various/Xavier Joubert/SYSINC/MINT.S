;	Fonctions de MiNT

F_DUPFD	=	0
F_GETFD	=	1
F_SETFD	=	2
F_GETFL	=	3
F_SETFL	=	4
F_GETLK	=	5
F_SETLK	=	6
F_SETLKW	=	7

FSTAT	=	"F"<<8+0
FIONREAD	=	"F"<<8+1
FIONWRITE	=	"F"<<8+2

SHMGETBLK	=	"M"<<8+0
SHMSETBLK	=	"M"<<8+1

PPROCADDR	=	"P"<<8+1
PBASEADDR	=	"P"<<8+2
PCTXTSIZE	=	"P"<<8+3
PSETFLAGS	=	"P"<<8+4
PGETFLAGS	=	"P"<<8+5
PTRACEGFLAGS	=	"P"<<8+6
PTRACESFLAGS	=	"P"<<8+7
PTRACEGO	=	"P"<<8+8
PTRACEFLOW	=	"P"<<8+9
PTRACESTEP	=	"P"<<8+10
PLOADINFO	=	"P"<<8+12

TIOCGETP	=	"T"<<8+0
TIOCSETP	=	"T"<<8+1
TIOCGETC	=	"T"<<8+2
TIOCSETC	=	"T"<<8+3
TIOCGLTC	=	"T"<<8+4
TIOCSLTC	=	"T"<<8+5
TIOCGPGRP	=	"T"<<8+6
TIOCSPGRP	=	"T"<<8+7
TIOCSTOP	=	"T"<<8+9
TIOCSTART	=	"T"<<8+10
TIOCGWINSZ	=	"T"<<8+11
TIOCSWINSZ	=	"T"<<8+12
TIOCGXKEY	=	"T"<<8+13
TIOCSXKEY	=	"T"<<8+14
TIOCIBAUD	=	"T"<<8+18
TIOCOBAUD	=	"T"<<8+19
TIOCCBRK	=	"T"<<8+20
TIOCSBRK	=	"T"<<8+21
TIOCGFLAGS	=	"T"<<8+22
TIOCSFLAGS	=	"T"<<8+23

TCURSOFF	=	"c"<<8+0
TCURSON	=	"c"<<8+1
TCURSBLINK	=	"c"<<8+2
TCURSSTEADY	=	"c"<<8+3
TCURSSRATE	=	"c"<<8+4
TCURSGRATE	=	"c"<<8+5

DOMAIN_TOS	=	0
DOMAIN_MINT	=	1

	TEXT

FLOCK	MACRO	handle,mode,start,length
	move.l	\4,-(sp)
	move.l	\3,-(sp)
	move	\2,-(sp)
	move	\1,-(sp)
	move	#92,-(sp)
	trap	#1
	lea	14(sp),sp
	ENDM
	
SYIELD	MACRO
	move	#255,-(sp)
	trap	#1
	addq	#2,sp
	ENDM
	
FPIPE	MACRO	fhandle
	move.l	\1,-(sp)
	move	#256,-(sp)
	trap	#1
	addq	#6,sp
	ENDM
	
FCNTL	MACRO	handle,arg,cmd
	move	\3,-(sp)
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#260,-(sp)
	trap	#1
	lea	10(sp),sp
	ENDM

FINSTAT	MACRO	handle
	move	\1,-(sp)
	move	#261,-(sp)
	trap	#1
	addq	#4,sp
	ENDM

FOUTSTAT	MACRO	handle
	move	\1,-(sp)
	move	#262,-(sp)
	trap	#1
	addq	#4,sp
	ENDM

FGETCHAR	MACRO	handle,mode
	move	\2,-(sp)
	move	\1,-(sp)
	move	#263,-(sp)
	trap	#1
	addq	#6,sp
	ENDM

FPUTCHAR	MACRO	handle,lchar,mode
	move	\3,-(sp)
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#264,-(sp)
	trap	#1
	lea	10(sp),sp
	ENDM

PWAIT	MACRO
	move	#265,-(sp)
	trap	#1
	addq	#2,sp
	ENDM

PNICE	MACRO	delta
	move	\1,-(sp)
	move	#266,-(sp)
	trap	#1
	addq	#4,sp
	ENDM

PGETPID	MACRO
	move	#267,-(sp)
	trap	#1
	addq	#2,sp
	ENDM

PGETPPID	MACRO
	move	#268,-(sp)
	trap	#1
	addq	#2,sp
	ENDM

PGETPGRP	MACRO
	move	#269,-(sp)
	trap	#1
	addq	#2,sp
	ENDM

PSETPGRP	MACRO
	move	#270,-(sp)
	trap	#1
	addq	#2,sp
	ENDM

PGETUID	MACRO
	move	#271,-(sp)
	trap	#1
	addq	#2,sp
	ENDM

PSETUID	MACRO
	move	#272,-(sp)
	trap	#1
	addq	#2,sp
	ENDM

PKILL	MACRO	pid,sig
	move	\2,-(sp)
	move	\1,-(sp)
	move	#273,-(sp)
	trap	#1
	addq	#6,sp
	ENDM

PSIGNAL	MACRO	sig,handler
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#274,-(sp)
	trap	#1
	addq	#8,sp
	ENDM

PVFORK	MACRO
	move	#275,-(sp)
	trap	#1
	addq	#2,sp
	ENDM

PGETGID	MACRO
	move	#276,-(sp)
	trap	#1
	addq	#2,sp
	ENDM

PSETGID	MACRO
	move	#277,-(sp)
	trap	#1
	addq	#2,sp
	ENDM

PSIGBLOCK	MACRO	mask
	move.l	\1,-(sp)
	move	#278,-(sp)
	trap	#1
	addq	#6,sp

	ENDM

PSIGSETMASK	MACRO	mask
	move.l	\1,-(sp)
	move	#279,-(sp)
	trap	#1
	addq	#6,sp
	ENDM

PUSRVAL	MACRO	val
	move.l	\1,-(sp)
	move	#280,-(sp)
	trap	#1
	addq	#6,sp
	ENDM

PDOMAIN	MACRO	domain
	move	\1,-(sp)
	move	#281,-(sp)
	trap	#1
	addq	#4,sp
	ENDM

PSIGRETURN	MACRO
	move	#282,-(sp)
	trap	#1
	addq	#2,sp
	ENDM

PFORK	MACRO
	move	#283,-(sp)
	trap	#1
	addq	#2,sp
	ENDM

PWAIT3	MACRO	flag,rusage
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#284,-(sp)
	trap	#1
	addq	#8,sp
	ENDM

FSELECT	MACRO	timeout,rfds,wfds,reserved
	move.l	\4,-(sp)
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#285,-(sp)
	trap	#1
	lea	12(sp),sp
	ENDM

PRUSAGE	MACRO	rusg
	move.l	\1,-(sp)
	move	#286,-(sp)
	trap	#1
	addq	#6,sp
	ENDM

PSETLIMIT	MACRO	limit,value
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#287,-(sp)
	trap	#1
	addq	#8,sp
	ENDM

TALARM	MACRO	time
	move.l	\1,-(sp)
	move	#288,-(sp)
	trap	#1
	addq	#6,sp
	ENDM

PAUSE	MACRO
	move	#289,-(sp)
	trap	#1
	addq	#2,sp
	ENDM

SYSCONF	MACRO	inq
	move	\1,-(sp)
	move	#290,-(sp)
	trap	#1
	addq	#4,sp
	ENDM

PSIGPENDING	MACRO
	move	#291,-(sp)
	trap	#1
	addq	#2,sp
	ENDM

DPATHCONF	MACRO	name,mode
	move	\2,-(sp)
	move.l	\1,-(sp)
	move	#292,-(sp)
	trap	#1
	addq	#8,sp
	ENDM

PMSG	MACRO	mode,mboxid,msgptr
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#293,-(sp)
	trap	#1
	lea	12(sp),sp
	ENDM

FMIDIPIPE	MACRO	pid,in,out
	move	\3,-(sp)
	move	\2,-(sp)
	move	\1,-(sp)
	move	#294,-(sp)
	trap	#1
	addq	#8,sp
	ENDM

PRENICE	MACRO	pid,delta
	move	\2,-(sp)
	move	\1,-(sp)
	move	#295,-(sp)
	trap	#1
	addq	#6,sp
	ENDM

DOPENDIR	MACRO	name,flag
	move	\2,-(sp)
	move.l	\1,-(sp)
	move	#296,-(sp)
	trap	#1
	addq	#8,sp
	ENDM

DREADDIR	MACRO	len,dirhandle,buf
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#297,-(sp)
	trap	#1
	lea	12(sp),sp
	ENDM

DREWINDDIR	MACRO	handle
	move.l	\1,-(sp)
	move	#298,-(sp)
	trap	#1
	addq	#6,sp
	ENDM

DCLOSEDIR	MACRO	dirhandle
	move.l	\1,-(sp)
	move	#299,-(sp)
	trap	#1
	addq	#6,sp
	ENDM

FXATTR	MACRO	flag,name,xattr
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#300,-(sp)
	trap	#1
	lea	12(sp),sp
	ENDM

FLINK	MACRO	oldname,newname
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move	#301,-(sp)
	trap	#1
	lea	10(sp),sp
	ENDM

FSYMLINK	MACRO	oldname,newname
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move	#302,-(sp)
	trap	#1
	lea	10(sp),sp
	ENDM

FREADLINK	MACRO	bufsiz,buf,name
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#303,-(sp)
	trap	#1
	lea	12(sp),sp
	ENDM

DCNTL	MACRO	cmd,name,arg
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#304,-(sp)
	trap	#1
	lea	12(sp),sp
	ENDM

FCHOWN	MACRO	name,uid,gid
	move	\3,-(sp)
	move	\2,-(sp)
	move.l	\1,-(sp)
	move	#305,-(sp)
	trap	#1
	lea	10(sp),sp
	ENDM

FCHMOD	MACRO	name,mode
	move	\2,-(sp)
	move.l	\1,-(sp)
	move	#306,-(sp)
	trap	#1
	addq	#8,sp
	ENDM

PUMASK	MACRO	mode
	move	\1,-(sp)
	move	#307,-(sp)
	trap	#1
	addq	#4,sp
	ENDM

PSEMAPHORE	MACRO	mode,id,timeout
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#308,-(sp)
	trap	#1
	lea	12(sp),sp
	ENDM

DLOCK	MACRO	mode,drv
	move	\2,-(sp)
	move	\1,-(sp)
	move	#309,-(sp)
	trap	#1
	addq	#6,sp
	ENDM

PSIGPAUSE	MACRO	mask
	move.l	\1,-(sp)
	move	#310,-(sp)
	trap	#1
	addq	#6,sp
	ENDM

PSIGACTION	MACRO	sig,act,oact
	move	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move	#311,-(sp)
	trap	#1
	lea	12(sp),sp
	ENDM

PGETEUID	MACRO
	move	#312,-(sp)
	trap	#1
	addq	#2,sp
	ENDM

PGETEGID	MACRO
	move	#313,-(sp)
	trap	#1
	addq	#2,sp
	ENDM

PWAITPID	MACRO	pid,flag,rusage
	move.l	\3,-(sp)
	move	\2,-(sp)
	move	\1,-(sp)
	move	#314,-(sp)
	trap	#1
	lea	10(sp),sp
	ENDM

DGETCWD	MACRO	path,drv,size
	move.l	\3,-(sp)
	move	\2,-(sp)
	move	\1,-(sp)
	move	#315,-(sp)
	trap	#1
	lea	10(sp),sp
	ENDM

SALERT	MACRO	str
	move.l	\1,-(sp)
	move	#316,-(sp)
	trap	#1
	addq	#6,sp
	ENDM
