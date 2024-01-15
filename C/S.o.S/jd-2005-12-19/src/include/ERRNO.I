; errno.h (c) Guido Flohr gufl0000@stud.uni-sb.de

E_OK	equ	0
EERROR	equ	-1	; generic error
EBUSY	equ	-2	; a system resource that can't be shared is already in use
EUKCMD	equ	-3	; unknown command
ECRC	equ	-4	; CRC error
EBADR	equ	-5	; bad request
ESPIPE	equ	-6	; invalid seek (e.g. on a pipe)
EMEDIUMTYPE	equ	-7	; wrong media type
ESECTOR	equ	-8	; sector not found
EPAPER	equ	-9	; no paper

EWRITE	equ	-10	; write fault
EREAD	equ	-11	; read fault
EGENERIC	equ	-12	; another generic error
EROFS	equ	-13	; read-only file system
ECHMEDIA	equ	-14	; inexpected media change
ENODEV	equ	-15	; wrong device specified
EBADSEC	equ	-16	; bad sector
ENOMEDIUM	equ	-17	; no media inserted
EINSERT	equ	-18	; insert media request
EDRVNRSP	equ	-19	; drive not responding

ESRCH	equ	-20	; no such process
ECHILD	equ	-21	; no child processes
EDEADLK	equ	-22	; deadlock avoided
ENOTBLK	equ	-23	; block device required
EISDIR	equ	-24	; file specified is a directory
EINVAL	equ	-25	; invalid argument to system call
EFTYPE	equ	-26	; inapproproate file type or format
EILSEQ	equ	-27	; illegal byte sequence

ENOSYS	equ	-32	; function not implemented
ENOENT	equ	-33	; file not found
ENOTDIR	equ	-34	; not a directory
EMFILE	equ	-35	; too many open files
EACCES	equ	-36	; operation not permitted
EBADF	equ	-37	; bad file descriptor
EPERM	equ	-38	; insufficient privileges to take the operation
ENOMEM	equ	-39	; not enough memory

EFAULT	equ	-40	; bad address
ENXIO	equ	-46	; no such device or address
EXDEV	equ	-48	; cross device rename
ENMFILES	equ	-49	; no more matching file names (Fsnext())

ENFILE	equ	-50	; too many files open globally
ELOCKED	equ	-58	; locking conflict
ENSLOCK	equ	-59	; no such lock (Dlock())

EBADARG	equ	-64	; range error/context unknown
EINTERNAL	equ	-65	; internal error
ENOEXEC	equ	-66	; invalid executable format
ESBLOCK	equ	-67	; block resize failure
EBREAK	equ	-68	; terminated by user
EXCPT	equ	-69	; terminated with bombs

ETXTBSY	equ	-70	; text file busy
EFBIG	equ	-71	; file too big

ELOOP	equ	-80	; circular link
EPIPE	equ	-81	; broken pipe
EMLINK	equ	-82	; too many symbolic links
ENOEMPTY	equ	-83	; directory not empty
EEXIST	equ	-85	; file exists
ENAMETOOLONG	equ	-86	; file/host name too long
ENOTTY	equ	-87	; not a terminal device
ERANGE	equ	-88	; arithmetic overflow
EDOM	equ	-89	; domain error

EIO	equ	-90	; physical read/write error
ENOSPC	equ	-91	; disk full

EPROCLIM	equ	-100	; too many processes for user
EUSERS	equ	-101	; too many users
EDQUOT	equ	-102	; quota exceeded
ESTALE	equ	-103	; stale NFS handle
EREMOTE	equ	-104	; already mounted on remote
EBADRPC	equ	-105	; bad RPC struct
ERPCMISMATCH	equ	-106	; RPC wrong version
EPROGUNAVAIL	equ	-107	; RPC program not available
EPROGMISMATCH	equ	-108	; RPC program version wrong
EPROCUNAVAIL	equ	-109	; RPC bad procedure for a program

ENOLOCK	equ	-110	; no locks available
EAUTH	equ	-111	; authentication error
ENEEDAUTH	equ	-112	; need authentication
EBACKGROUND	equ	-113	; inappropriate background operation
EBADMSG	equ	-114	; not a data message
EIDRM	equ	-115	; identifier removed
EMULTIHOP	equ	-116	; multihop attempted
ENODATA	equ	-117	; no data available
ENOLINK	equ	-118	; link has been severed
ENOMSG	equ	-119	; no message of desired type

ENOSR	equ	-120	; out of stream resources
ENOSTR	equ	-121	; not a stream
EOVERFLOW	equ	-122	; value too large for defined data type
EPROTO	equ	-123	; protocol error
ETIME	equ	-124	; timer expired
E2BIG	equ	-125	; argument list too long
ERESTART	equ	-126	; interrupt system call should be restarted
ECHRNG	equ	-127	; channel number out of range
ESNDNOTLOCK	equ	-128	; sound system is not locked
ESNDLOCKED	equ	-129	; sound subsystem is locked

; 130-199 defined, but not here

EMOUNT	equ	-200	; crossed mount point
EOF	equ	-230	; end of file

; 201-299 reserved
; 300-325 defined for MiNT Net errors

EWOULDBLOCK	equ	-326	; operation would block
ENOBUFS	equ	-327	; no more system buffers
ETOOMANYREFS	equ	-328	; too many references

; EOF