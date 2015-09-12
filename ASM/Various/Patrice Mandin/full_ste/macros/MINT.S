;	Fonctions de MiNT

	TEXT

FLOCK	macro	handle,mode,start,length
	move.l	\4,-(sp)
	move.l	\3,-(sp)
	move	\2,-(sp)
	move	\1,-(sp)
	move	#92,-(sp)
	trap	#1
	lea	14(sp),sp
	endm
	
SYIELD	macro
	move	#255,-(sp)
	trap	#1
	addq	#2,sp
	endm
	
FPIPE	macro	fhandle
	move.l	\1,-(sp)
	move	#256,-(sp)
	trap	#1
	addq	#6,sp
	endm
	
FCNTL	macro	handle,arg,cmd
	move	\3,-(sp)
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#260,-(sp)
	trap	#1
	lea	10(sp),sp
	endm

FINSTAT	macro	handle
	move	\1,-(sp)
	move	#261,-(sp)
	trap	#1
	addq	#4,sp
	endm

FOUTSTAT	macro	handle
	move	\1,-(sp)
	move	#262,-(sp)
	trap	#1
	addq	#4,sp
	endm

FGETCHAR	macro	handle,mode
	move	\2,-(sp)
	move	\1,-(sp)
	move	#263,-(sp)
	trap	#1
	addq	#6,sp
	endm

FPUTCHAR	macro	handle,lchar,mode
	move	\3,-(sp)
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#264,-(sp)
	trap	#1
	lea	10(sp),sp
	endm

PWAIT	macro
	move	#265,-(sp)
	trap	#1
	addq	#2,sp
	endm

PNICE	macro	delta
	move	\1,-(sp)
	move	#266,-(sp)
	trap	#1
	addq	#4,sp
	endm

PGETPID	macro
	move	#267,-(sp)
	trap	#1
	addq	#2,sp
	endm

PGETPPID	macro
	move	#268,-(sp)
	trap	#1
	addq	#2,sp
	endm

PGETPGRP	macro
	move	#269,-(sp)
	trap	#1
	addq	#2,sp
	endm

PSETPGRP	macro
	move	#270,-(sp)
	trap	#1
	addq	#2,sp
	endm

PGETUID	macro
	move	#271,-(sp)
	trap	#1
	addq	#2,sp
	endm

PSETUID	macro
	move	#272,-(sp)
	trap	#1
	addq	#2,sp
	endm

PKILL	macro	pid,sig
	move	\2,-(sp)
	move	\1,-(sp)
	move	#273,-(sp)
	trap	#1
	addq	#6,sp
	endm

PSIGNAL	macro	sig,handler
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#274,-(sp)
	trap	#1
	addq	#8,sp
	endm

PVFORK	macro
	move	#275,-(sp)
	trap	#1
	addq	#2,sp
	endm

PGETGID	macro
	move	#276,-(sp)
	trap	#1
	addq	#2,sp
	endm

PSETGID	macro
	move	#277,-(sp)
	trap	#1
	addq	#2,sp
	endm

PSIGBLOCK	macro	mask
	move.l	\1,-(sp)
	move	#278,-(sp)
	trap	#1
	addq	#6,sp

	endm

PSIGSETMASK	macro	mask
	move.l	\1,-(sp)
	move	#279,-(sp)
	trap	#1
	addq	#6,sp
	endm

PUSRVAL	macro	val
	move.l	\1,-(sp)
	move	#280,-(sp)
	trap	#1
	addq	#6,sp
	endm

PDOMAIN	macro	domain
	move	\1,-(sp)
	move	#281,-(sp)
	trap	#1
	addq	#4,sp
	endm

PSIGRETURN	macro
	move	#282,-(sp)
	trap	#1
	addq	#2,sp
	endm

PFORK	macro
	move	#283,-(sp)
	trap	#1
	addq	#2,sp
	endm

PWAIT3	macro	flag,rusage
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#284,-(sp)
	trap	#1
	addq	#8,sp
	endm

FSELECT	macro	timeout,rfds,wfds,reserved
	move.l	\4,-(sp)
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#285,-(sp)
	trap	#1
	lea	12(sp),sp
	endm

PRUSAGE	macro	rusg
	move.l	\1,-(sp)
	move	#286,-(sp)
	trap	#1
	addq	#6,sp
	endm

PSETLIMIT	macro	limit,value
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#287,-(sp)
	trap	#1
	addq	#8,sp
	endm

TALARM	macro	time
	move.l	\1,-(sp)
	move	#288,-(sp)
	trap	#1
	addq	#6,sp
	endm

PAUSE	macro
	move	#289,-(sp)
	trap	#1
	addq	#2,sp
	endm

SYSCONF	macro	inq
	move	\1,-(sp)
	move	#290,-(sp)
	trap	#1
	addq	#4,sp
	endm

PSIGPENDING	macro
	move	#291,-(sp)
	trap	#1
	addq	#2,sp
	endm

DPATHCONF	macro	name,mode
	move	\2,-(sp)
	move.l	\1,-(sp)
	move	#292,-(sp)
	trap	#1
	addq	#8,sp
	endm

PMSG	macro	mode,mboxid,msgptr
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#293,-(sp)
	trap	#1
	lea	12(sp),sp
	endm

FMIDIPIPE	macro	pid,in,out
	move	\3,-(sp)
	move	\2,-(sp)
	move	\1,-(sp)
	move	#294,-(sp)
	trap	#1
	addq	#8,sp
	endm

PRENICE	macro	pid,delta
	move	\2,-(sp)
	move	\1,-(sp)
	move	#295,-(sp)
	trap	#1
	addq	#6,sp
	endm

DOPENDIR	macro	name,flag
	move	\2,-(sp)
	move.l	\1,-(sp)
	move	#296,-(sp)
	trap	#1
	addq	#8,sp
	endm

DREADDIR	macro	len,dirhandle,buf
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#297,-(sp)
	trap	#1
	lea	12(sp),sp
	endm

DREWINDDIR	macro	handle
	move.l	\1,-(sp)
	move	#298,-(sp)
	trap	#1
	addq	#6,sp
	endm

DCLOSEDIR	macro	dirhandle
	move.l	\1,-(sp)
	move	#299,-(sp)
	trap	#1
	addq	#6,sp
	endm

FXATTR	macro	flag,name,xattr
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#300,-(sp)
	trap	#1
	lea	12(sp),sp
	endm

FLINK	macro	oldname,newname
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move	#301,-(sp)
	trap	#1
	lea	10(sp),sp
	endm

FSYMLINK	macro	oldname,newname
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move	#302,-(sp)
	trap	#1
	lea	10(sp),sp
	endm

FREADLINK	macro	bufsiz,buf,name
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#303,-(sp)
	trap	#1
	lea	12(sp),sp
	endm

DCNTL	macro	cmd,name,arg
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#304,-(sp)
	trap	#1
	lea	12(sp),sp
	endm

FCHOWN	macro	name,uid,gid
	move	\3,-(sp)
	move	\2,-(sp)
	move.l	\1,-(sp)
	move	#305,-(sp)
	trap	#1
	lea	10(sp),sp
	endm

FCHMOD	macro	name,mode
	move	\2,-(sp)
	move.l	\1,-(sp)
	move	#306,-(sp)
	trap	#1
	addq	#8,sp
	endm

PUMASK	macro	mode
	move	\1,-(sp)
	move	#307,-(sp)
	trap	#1
	addq	#4,sp
	endm

PSEMAPHORE	macro	mode,id,timeout
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#308,-(sp)
	trap	#1
	lea	12(sp),sp
	endm

DLOCK	macro	mode,drv
	move	\2,-(sp)
	move	\1,-(sp)
	move	#309,-(sp)
	trap	#1
	addq	#6,sp
	endm

PSIGPAUSE	macro	mask
	move.l	\1,-(sp)
	move	#310,-(sp)
	trap	#1
	addq	#6,sp
	endm

PSIGACTION	macro	sig,act,oact
	move	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move	#311,-(sp)
	trap	#1
	lea	12(sp),sp
	endm

PGETEUID	macro
	move	#312,-(sp)
	trap	#1
	addq	#2,sp
	endm

PGETEGID	macro
	move	#313,-(sp)
	trap	#1
	addq	#2,sp
	endm

PWAITPID	macro	pid,flag,rusage
	move.l	\3,-(sp)
	move	\2,-(sp)
	move	\1,-(sp)
	move	#314,-(sp)
	trap	#1
	lea	10(sp),sp
	endm

DGETCWD	macro	path,drv,size
	move.l	\3,-(sp)
	move	\2,-(sp)
	move	\1,-(sp)
	move	#315,-(sp)
	trap	#1
	lea	10(sp),sp
	endm

SALERT	macro	str
	move.l	\1,-(sp)
	move	#316,-(sp)
	trap	#1
	addq	#6,sp
	endm
