; Macros for calling kernel from within a device driver

kdos	macro	func
	move.l	KERNEL,a0
	move.l	kerinfo.dos_tab(a0),a0
	move.l	\1*4(a0),a0
	jsr	(a0)
	endm
	
kbios	macro	func
	move.l	KERNEL,a0
	move.l	kerinfo.bios_tab(a0),a0
	move.l	\1*4(a0),a0
	jsr	(a0)
	endm

; Example of the macro usage

datestamp	macro
	kdos	T_getdate
	endm

timestamp	macro
	kdos	T_gettime
	endm

changedrive	macro
	move.l	KERNEL,a0
	move.l	kerinfo.drvchng(a0),a0
	jsr	(a0)
	endm

TRACE	macro
	move.l	KERNEL,a0
	move.l	kerinfo.trace(a0),a0
	jsr	(a0)
	endm

DEBUG	macro
	move.l	KERNEL,a0
	move.l	kerinfo.debug(a0),a0
	jsr	(a0)
	endm

ALERT	macro
	move.l	KERNEL,a0
	move.l	kerinfo.alert(a0),a0
	jsr	(a0)
	endm

FATAL	macro
	move.l	KERNEL,a0
	move.l	kerinfo.alert(a0),a0
	jsr	(a0)
	endm

; kmalloc() allocates the kernel memory, supervisor accessible. This memory
; must be explicitly freed later by kfree(). WARNING: using kfree() on a memory
; area not allocated by kmalloc() is fatal.

kmalloc	macro
	move.l	KERNEL,a0
	move.l	kerinfo.kmalloc(a0),a0
	jsr	(a0)
	endm

kfree	macro
	move.l	KERNEL,a0
	move.l	kerinfo.kfree(a0),a0
	jsr	(a0)
	endm

; umalloc() and ufree() are similar to kmalloc() with except that the allocated
; memory area gets attached to the user process.

umalloc	macro
	move.l	KERNEL,a0
	move.l	kerinfo.umalloc(a0),a0
	jsr	(a0)
	endm

ufree	macro
	move.l	KERNEL,a0
	move.l	kerinfo.ufree(a0),a0
	jsr	(a0)
	endm

strnicmp	macro
	move.l	KERNEL,a0
	move.l	kerinfo.strnicmp(a0),a0
	jsr	(a0)
	endm

stricmp	macro
	move.l	KERNEL,a0
	move.l	kerinfo.stricmp(a0),a0
	jsr	(a0)
	endm

strlwr	macro
	move.l	KERNEL,a0
	move.l	kerinfo.strlwr(a0),a0
	jsr	(a0)
	endm

strupr	macro
	move.l	KERNEL,a0
	move.l	kerinfo.strupr(a0),a0
	jsr	(a0)
	endm

ksprintf	macro
	move.l	KERNEL,a0
	move.l	kerinfo.sprintf(a0),a0
	jsr	(a0)
	endm

ms_time	macro
	move.l	KERNEL,a0
	move.l	kerinfo.ms_time(a0),a0
	jsr	(a0)
	endm

unixtime	macro
	move.l	KERNEL,a0
	move.l	kerinfo.unixtime(a0),a0
	jsr	(a0)
	endm

dostime	macro
	move.l	KERNEL,a0
	move.l	kerinfo.dostime(a0),a0
	jsr	(a0)
	endm

nap	macro
	move.l	KERNEL,a0
	move.l	kerinfo.nap(a0),a0
	jsr	(a0)
	endm

sleep	macro
	move.l	KERNEL,a0
	move.l	kerinfo.sleep(a0),a0
	jsr	(a0)
	endm

wake	macro
	move.l	KERNEL,a0
	move.l	kerinfo.wake(a0),a0
	jsr	(a0)
	endm

wakeselect	macro
	move.l	KERNEL,a0
	move.l	kerinfo.wakeselect(a0),a0
	jsr	(a0)
	endm

denyshare	macro
	move.l	KERNEL,a0
	move.l	kerinfo.denyshare(a0),a0
	jsr	(a0)
	endm

denylock	macro
	move.l	KERNEL,a0
	move.l	kerinfo.denylock(a0),a0
	jsr	(a0)
	endm

addtimeout	macro
	move.l	KERNEL,a0
	move.l	kerinfo.addtimeout(a0),a0
	jsr	(a0)
	endm

canceltimeout	macro
	move.l	KERNEL,a0
	move.l	kerinfo.canceltimeout(a0),a0
	jsr	(a0)
	endm

addroottimeout	macro
	move.l	KERNEL,a0
	move.l	kerinfo.addroottimeout(a0),a0
	jsr	(a0)
	endm

cancelroottimeout	macro
	move.l	KERNEL,a0
	move.l	kerinfo.cancelroottimeout(a0),a0
	jsr	(a0)
	endm

ikill	macro
	move.l	KERNEL,a0
	move.l	kerinfo.ikill(a0),a0
	jsr	(a0)
	endm

iwake	macro
	move.l	KERNEL,a0
	move.l	kerinfo.iwake(a0),a0
	jsr	(a0)
	endm

bio	macro
	move.l	KERNEL,a0
	move.l	kerinfo.bio(a0),a0
	endm

utc	macro
	move.l	KERNEL,a0
	move.l	kerinfo.xtime(a0),a0
	endm

; for sleep

CURPROC_Q	equ	0
READY_Q	equ	1
WAIT_Q	equ	2
IO_Q	equ	3
ZOMBIE_Q	equ	4
TSR_Q	equ	5
STOP_Q	equ	6
SELECT_Q	equ	7
