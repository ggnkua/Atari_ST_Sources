; Structures for writing MiNT device drivers in assembler
;
; Devpac/Gen 3.10 syntax, tabulator 20 chars
;
; Actually mostly based on GNU C includes: file.h, dcntl.h
;

; struct fcookie

	RSSET	0
fcookie.fs	rs.l	1	; filesystem that knows about this cookie
fcookie.dev	rs.w	1	; device info (e.g. Rwabs() device number
fcookie.aux	rs.w	1	; extra data
fcookie.index	rs.l	1	; this + dev uniquely identifies a file
FCOOKIE	equ	__RS

; struct timeval

	RSSET	0
timeval.sec	rs.l	1	; seconds
timeval.usec	rs.l	1	; microseconds
TIMEVAL	equ	__RS

TOS_NAMELEN	equ	13
SVALID	equ	$1234fedc	; magic for a valid search
EVALID	equ	$5678ba90	; magic for an exhausted search

; struct dtabuf

	RSSET	0
dtabuf.index	rs.w	1	; index into arrays in the PROC struct
dtabuf.magic	rs.l	1
dtabuf.dta_pat	rs.b	TOS_NAMELEN+1	; pointer to pattern, if necessary
dtabuf.dta_sattrib	rs.b	1	; attributes being searched for
dtabuf.dta_attrib	rs.b	1
dtabuf.dta_time	rs.w	1
dtabuf.dta_date	rs.w	1
dtabuf.dta_size	rs.l	1
dtabuf.dta_name	rs.b	TOS_NAMELEN+1
DTABUF	equ	__RS

; structure for opendir/readdir/closedir

TOS_SEARCH	equ	1

	RSSET	0
dirstruct.fc	rs.b	FCOOKIE	; cookie for this directory
dirstruct.index	rs.w	1	; index of the current entry
dirstruct.flags	rs.w	1	; flags (e.g. tos or not)
dirstruct.fsstuff	rs.b	60	; anything else the filesystem wants
dirstruct.next	rs.l	1	; pointer to next one
DIRSTRUCT	equ	__RS

; file types

S_IFMT	equ	@170000	; file type mask
S_IFLNK	equ	@160000	; symbolic link
S_IFMEM	equ	@140000	; memory region or process
S_IFIFO	equ	@120000	; FIFO
S_IFREG 	equ	@100000	; regular file
S_IFBLK	equ	@060000	; block special file
S_IFDIR	equ	@040000	; directory file
S_IFCHR	equ	@020000	; character special file (BIOS)
S_IFSOCK	equ	@010000	; socket file

S_ISLNK	macro	mode
	move.w	\1,-(sp)
	and.w	#S_IFMT,(sp)
	cmp.w	#S_IFLNK,(sp)
	addq.l	#$02,sp
	endm

S_ISFIFO	macro	mode
	move.w	\1,-(sp)
	and.w	#S_IFMT,(sp)
	cmp.w	#S_IFIFO,(sp)
	addq.l	#$02,sp
	endm

S_ISREG	macro	mode
	move.w	\1,-(sp)
	and.w	#S_IFMT,(sp)
	cmp.w	#S_IFREG,(sp)
	addq.l	#$02,sp
	endm

S_ISBLK	macro	mode
	move.w	\1,-(sp)
	and.w	#S_IFMT,(sp)
	cmp.w	#S_IFBLK,(sp)
	addq.l	#$02,sp
	endm

S_ISDIR	macro	mode
	move.w	\1,-(sp)
	and.w	#S_IFMT,(sp)
	cmp.w	#S_IFDIR,(sp)
	addq.l	#$02,sp
	endm

S_ISCHR	macro	mode
	move.w	\1,-(sp)
	and.w	#S_IFMT,(sp)
	cmp.w	#S_ICHR,(sp)
	addq.l	#$02,sp
	endm

S_ISSOCK	macro	mode
	move.w	\1,-(sp)
	and.w	#S_IFMT,(sp)
	cmp.w	#S_IFSOCK,(sp)
	addq.l	#$02,sp
	endm

; special bits: setuid, setgid, sticky bit

S_ISUID	equ	@004000
S_ISGID	equ	@002000
S_ISVTX	equ	@001000

; file access modes for user, group, and other

S_IRWXU	equ	@000700
S_IRUSR	equ	@000400
S_IWUSR	equ	@000200
S_IXUSR	equ	@000100

S_IRWXG	equ	@000070
S_IRGRP	equ	@000040
S_IWGRP	equ	@000020
S_IXGRP	equ	@000010

S_IRWXO	equ	@000007
S_IROTH	equ	@000004
S_IWOTH	equ	@000002
S_IXOTH	equ	@000001

S_IRWXUGO	equ	S_IRWXU | S_IRWXG | S_IRWXO
S_IALLUGO	equ	S_ISUID | S_ISGID | S_ISVTX | S_IRWXUGO
S_IRUGO	equ	S_IRUSR | S_IRGRP | S_IROTH
S_IWUGO	equ	S_IWUSR | S_IWGRP | S_IWOTH
S_IXUGO	equ	S_IXUSR | S_IXGRP | S_IXOTH

; defines for TOS attribute bytes

FA_RDONLY	equ	$01
FA_HIDDEN	equ	$02
FA_SYSTEM	equ	$04
FA_LABEL	equ	$08
FA_DIR	equ	$10
FA_CHANGED	equ	$20
FA_VFAT	equ	$0f	; internal: VFAT entry
FA_SYMLINK	equ	$40	; internal: symbolic link

; struct xattr

	RSSET	0
xattr.mode	rs.w	1
xattr.index	rs.l	1
xattr.dev	rs.w	1
xattr.rdev	rs.w	1	; "real" device
xattr.nlink	rs.w	1
xattr.uid	rs.w	1
xattr.gid	rs.w	1
xattr.size	rs.l	1
xattr.blksize	rs.l	1
xattr.nblocks	rs.l	1
xattr.mtime	rs.w	1
xattr.mdate	rs.w	1
xattr.atime	rs.w	1
xattr.adate	rs.w	1
xattr.ctime	rs.w	1
xattr.cdate	rs.w	1
xattr.attr	rs.w	1
xattr.rsv2	rs.l	1
xattr.rsv3	rs.l	2
XATTR	equ	__RS

; struct time

	RSSET	0
time.high_time	rs.l	1
time.time	rs.l	1	; signed
time.microseconds	rs.l	1
TIME	equ	__RS

; structure for stat

	RSSET	0
stat.dev	rs.l	2	; inode's device (64 bit!)
stat.ino	rs.l	1	; inode's number
stat.mode	rs.l	1	; inode protection mode
stat.nlink	rs.l	1	; number of hard links
stat.uid	rs.l	1	; user ID of the owner
stat.gid	rs.l	1	; group ID of the owner
stat.rdev	rs.l	2	; device type (64 bit!)
stat.atime	rs.b	TIME	; time of last access, UTC
stat.mtime	rs.b	TIME	; time of last modification, UTC
stat.ctime	rs.b	TIME	; time of last file status change
stat.size	rs.l	2	; file size, in bytes (64 bit!)
stat.blocks	rs.l	2	; blocks allocated for file (64 bit!)
stat.blksize	rs.l	1	; optimum block size for I/O
stat.flags	rs.l	1	; user defined flags for file
stat.gen	rs.l	1	; file generation number
stat.res	rs.l	7
STAT	equ	__RS

; struct fileptr

	RSSET	0
fileptr.links	rs.w	1	; number of copies
fileptr.flags	rs.w	1	; file open mode etc.
fileptr.pos	rs.l	1	; position in file
fileptr.devinfo	rs.l	1	; device driver specific info
fileptr.fc	rs.b	FCOOKIE	; file system cookie for this file
fileptr.dev	rs.l	1	; device driver that knows how to deal with this
fileptr.next	rs.l	1	; link to next fileptr for this file
FILEPTR	equ	__RS

; struct flock

	RSSET	0
flock.l_type	rs.w	1	; type of lock
flock.l_whence	rs.w	1	; SEEK_SET, SEEK_CUR, SEEK_END
flock.l_start	rs.l	1	; start of locked region
flock.l_len	rs.l	1	; length of locked region
flock.l_pid	rs.w	1	; pid of locking process
FLOCK	equ	__RS

; structure for internal kernel locks

	RSSET	0
ilock.lock	rs.b	FLOCK	; the actual lock
ilock.next	rs.l	1	; next lock on the list
ilock.reserved	rs.l	4
ILOCK	equ	__RS

; struct devdrv

	RSSET	0
devdrv.open	rs.l	1
devdrv.write	rs.l	1
devdrv.read	rs.l	1
devdrv.lseek	rs.l	1
devdrv.ioctl	rs.l	1
devdrv.datime	rs.l	1
devdrv.close	rs.l	1
devdrv.select	rs.l	1
devdrv.unselect	rs.l	1
devdrv.writeb	rs.l	1
devdrv.readb	rs.l	1
DEVDRV	equ	__RS

; struct kerinfo
; this is the structure passed to loaded file systems to tell them
; about the kernel

	RSSET	0
kerinfo.maj_version	rs.w	1	; kernel version number
kerinfo.min_version	rs.w	1	; kernel minor version number
kerinfo.default_perm rs.w	1	; default file permissions
kerinfo.version	rs.w	1	; version number (of what?)

kerinfo.bios_tab	rs.l	1	; pointer to the BIOS entries
kerinfo.dos_tab	rs.l	1	; pointer to the GEMDOS entry points

kerinfo.drvchng	rs.l	1	; media change vector

kerinfo.trace	rs.l	1	; TRACE() pointer
kerinfo.debug	rs.l	1	; DEBUG() pointer
kerinfo.alert	rs.l	1	; ALERT() pointer
kerinfo.fatal	rs.l	1	; FATAL() pointer (never returns)

kerinfo.kmalloc	rs.l	1
kerinfo.kfree	rs.l	1
kerinfo.umalloc	rs.l	1
kerinfo.ufree	rs.l	1
	
kerinfo.strnicmp	rs.l	1
kerinfo.stricmp	rs.l	1
kerinfo.strlwr	rs.l	1
kerinfo.strupr	rs.l	1
kerinfo.sprintf	rs.l	1
	
kerinfo.millis_time	rs.l	1
kerinfo.unixtime	rs.l	1
kerinfo.dostime	rs.l	1
	
kerinfo.nap	rs.l	1
kerinfo.sleep	rs.l	1
kerinfo.wake	rs.l	1
kerinfo.wakeselect	rs.l	1
	
kerinfo.denyshare	rs.l	1
kerinfo.denylock	rs.l	1
	
kerinfo.addtimeout	rs.l	1
kerinfo.canceltimeout rs.l	1
kerinfo.addroottimeout rs.l	1
kerinfo.cancelroottimeout rs.l	1
	
kerinfo.ikill	rs.l	1
kerinfo.iwake	rs.l	1
	
kerinfo.bio	rs.l	1
kerinfo.timeval	rs.l	1
kerinfo.res	rs.l	1
KERINFO	equ	__RS	

; flags for open() modes

O_RWMODE  	equ	$03	;isolates file read/write mode
O_RDONLY	equ	$00
O_WRONLY	equ	$01
O_RDWR	equ	$02
O_EXEC	equ	$03	;execute file; used by kernel only

; $04 is for future expansion

O_APPEND	equ	$08	;all writes go to end of file

O_SHMODE	equ	$70	;isolates file sharing mode
O_COMPAT	equ	$00	;compatibility mode
O_DENYRW	equ	$10	;deny both read and write access
O_DENYW	equ	$20	;deny write access to others
O_DENYR	equ	$30	;deny read access to others
O_DENYNONE	equ	$40	;don't deny any access to others

O_NOINHERIT	equ	$80	;private file (not passed to child)

O_NDELAY	equ	$100	;don't block for I/O on this file
O_CREAT	equ	$200	;create file if it doesn't exist
O_TRUNC	equ	$400	;truncate file to 0 bytes if it does exist
O_EXCL	equ	$800	;fail open if file exists

O_USER	equ	$0fff	;isolates user-settable flag bits

O_GLOBAL	equ	$1000	;for opening a global file

;kernel mode bits -- the user can't set these!

O_TTY	equ	$2000
O_HEAD	equ	$4000
O_LOCK	equ	$8000

; macros to be applied to FILEPTRS to determine their type

is_terminal	macro	fileptr
	pea	(\1).l
	move.w	fileptr.flags(sp),-(sp)
	and.w	#O_TTY,(sp)
	addq.l	#$06,sp
	endm

; lseek() origins

SEEK_SET	equ	0	/* from beginning of file */
SEEK_CUR	equ	1	/* from current location */
SEEK_END	equ	2	/* from end of file */

; struct dev_descr

	RSSET	0
dev_descr.driver	rs.l	1
dev_descr.dinfo	rs.w	1
dev_descr.flags	rs.w	1
dev_descr.tty	rs.l	1
dev_descr.drvsize	rs.l	1
dev_descr.fmode	rs.l	1
dev_descr.reserved	rs.l	2
DEV_DESCR	equ	__RS

DEV_NEWTTY	equ	$de00
DEV_NEWBIOS	equ	$de01
DEV_INSTALL	equ	$de02

FIONREAD	equ	'F'<<8|1
FIONWRITE	equ	'F'<<8|2
FIOEXCEPT	equ	'F'<<8|5

; EOF