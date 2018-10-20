#if !defined ( __SFCNTL_ )
#define __SFCNTL__

/* NOTE:
   The only supported fcntl-calls are
   fcntl(s, F_GETFL, <ignored>) and
   fcntl(s, F_SETFL, <flags>)
   The only supported flags are O_NONBLOCK and O_NDELAY, other
   flags are stored with F_SETFL and returned with F_GETFL but ignored
*/

/* Values for cmd used by fcntl() */

#define F_DUPFD		0		/* Duplicate fildes */
#define F_GETFD		1		/* Get file descriptor flags */
#define F_SETFD		2		/* Set file descriptor flags */
#define F_GETFL		3		/* Get file status flags */
#define F_SETFL		4		/* Set file status flags */
#define F_GETLK		5		/* Get file lock */
#define F_SETLK		6		/* Set file lock */
#define F_SETLKW	7		/* Set file lock and wait */

/* File descriptor flags used with fcntl() */
#define FD_CLOEXEC 1

/* Values for l_type used for record locking with fcntl() */
#define F_RDLCK 01
#define F_WRLCK 02
#define F_UNLCK 03

/* File access modes used with open() and fcntl() */

/* 
#define O_RDONLY	0000000 /* Open for reading only */
#define O_WRONLY	0000001 /* Open for writing only */
#define O_RDWR		0000002 /* Open for reading and writing */
*/
#define O_ACCMODE 0000003 /* Mask for file access modes */
/* With PureC, these are allready definded in stdio.h like this: */
#define O_RDONLY    0x00
#define O_WRONLY    0x01
#define O_RDWR      0x02


/* File status flags used with open() and fcntl() */
/*
#define O_APPEND 		0000010	/* Append (all writes happen at end of file) */
*/
/* PureC: */
#define O_APPEND    0x08

#define O_NONBLOCK	0200000l	/* Non-blocking open and/or I/O; POSIX-style */

#define O_SYNC			0100000 /* Synchronous writes */

#define O_NDELAY		0000004 /* Non-blocking open and/or I/O */
#define O_SYNCIO		O_SYNC	/* Do write through caching */
#define FSYNCIO			O_SYNC	/* Do write through caching */

extern long cdecl sfcntl(int FileDescriptor, long Command, long Argument);

#endif