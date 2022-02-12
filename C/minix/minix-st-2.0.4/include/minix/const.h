/* Copyright (C) 2001 by Prentice-Hall, Inc.  See the copyright notice in
 * the file /usr/src/LICENSE.
 */

#ifndef CHIP
#error CHIP is not defined
#endif

#define EXTERN        extern	/* used in *.h files */
#define PRIVATE       static	/* PRIVATE x limits the scope of x */
#define PUBLIC			/* PUBLIC is the opposite of PRIVATE */
#define FORWARD       static	/* some compilers require this to be 'static'*/

#define TRUE               1	/* used for turning integers into Booleans */
#define FALSE              0	/* used for turning integers into Booleans */

#define HZ	          60	/* clock freq (software settable on IBM-PC) */
#define BLOCK_SIZE      1024	/* # bytes in a disk block */
#define SUPER_USER (uid_t) 0	/* uid_t of superuser */

#define MAJOR	           8	/* major device = (dev>>MAJOR) & 0377 */
#define MINOR	           0	/* minor device = (dev>>MINOR) & 0377 */

#define NULL     ((void *)0)	/* null pointer */
#define CPVEC_NR          16	/* max # of entries in a SYS_VCOPY request */
#define NR_IOREQS	MIN(NR_BUFS, 64)
				/* maximum number of entries in an iorequest */

#define NR_SEGS            3	/* # segments per process */
#define T                  0	/* proc[i].mem_map[T] is for text */
#define D                  1	/* proc[i].mem_map[D] is for data */
#define S                  2	/* proc[i].mem_map[S] is for stack */

/* Process numbers of some important processes. */
#define MM_PROC_NR         0	/* process number of memory manager */
#define FS_PROC_NR         1	/* process number of file system */
#define INIT_PROC_NR	   2	/* init -- the process that goes multiuser */
#define LOW_USER  INIT_PROC_NR	/* first user not part of operating system */

/* Miscellaneous */
#define BYTE            0377	/* mask for 8 bits */
#define READING            0	/* copy data to user */
#define WRITING            1	/* copy data from user */
#define NO_NUM        0x8000	/* used as numerical argument to panic() */
#define NIL_PTR   (char *) 0	/* generally useful expression */
#define HAVE_SCATTERED_IO  1	/* scattered I/O is now standard */

/* Macros. */
#define MAX(a, b)   ((a) > (b) ? (a) : (b))
#define MIN(a, b)   ((a) < (b) ? (a) : (b))

/* Number of tasks. */
#define NR_TASKS	(8 + NR_CTRLRS + ENABLE_DP8390 + ENABLE_RTL8139 \
				+ ENABLE_PRINTER + 2 * ENABLE_SB16)

/* Memory is allocated in clicks. */
#if (CHIP == INTEL)
#define CLICK_SIZE      1024	/* unit in which memory is allocated */
#define CLICK_SHIFT       10	/* log2 of CLICK_SIZE */
#endif

#if (CHIP == SPARC) || (CHIP == M68000)
#if (SHADOWING == 0)
#define CLICK_SIZE	4096	/* unit in which memory is alocated */
#define CLICK_SHIFT	  12	/* 2log of CLICK_SIZE */
#else
#define CLICK_SIZE	 256	/* unit in which memory is alocated */
#define CLICK_SHIFT	   8	/* 2log of CLICK_SIZE */
#endif /* SHADOWING == 0 */
#endif

#define ABS             -999	/* this process means absolute memory */

/* Flag bits for i_mode in the inode. */
#define I_TYPE          0170000	/* this field gives inode type */
#define I_REGULAR       0100000	/* regular file, not dir or special */
#define I_BLOCK_SPECIAL 0060000	/* block special file */
#define I_DIRECTORY     0040000	/* file is a directory */
#define I_CHAR_SPECIAL  0020000	/* character special file */
#define I_NAMED_PIPE	0010000 /* named pipe (FIFO) */
#define I_SET_UID_BIT   0004000	/* set effective uid_t on exec */
#define I_SET_GID_BIT   0002000	/* set effective gid_t on exec */
#if (ENABLE_SYMLINKS == 1)
#define	I_SYMBOLIC_LINK	0120000	/* symbolic link */
#endif /* ENABLE_SYMLINKS */
#define ALL_MODES       0006777	/* all bits for user, group and others */
#define RWX_MODES       0000777	/* mode bits for RWX only */
#define R_BIT           0000004	/* Rwx protection bit */
#define W_BIT           0000002	/* rWx protection bit */
#define X_BIT           0000001	/* rwX protection bit */
#define I_NOT_ALLOC     0000000	/* this inode is free */

/* Some limits. */
#define MAX_BLOCK_NR  ((block_t) 077777777)	/* largest block number */
#define HIGHEST_ZONE   ((zone_t) 077777777)	/* largest zone number */
#define MAX_INODE_NR      ((ino_t) 0177777)	/* largest inode number */
#define MAX_FILE_POS ((off_t) 037777777777)	/* largest legal file offset */

#define NO_BLOCK              ((block_t) 0)	/* absence of a block number */
#define NO_ENTRY                ((ino_t) 0)	/* absence of a dir entry */
#define NO_ZONE                ((zone_t) 0)	/* absence of a zone number */
#define NO_DEV                  ((dev_t) 0)	/* absence of a device numb */

/* Used for stackframe of old (Minix-1.5) signal system call */
/* How many bytes are pushed by a signal. */
#define	SIG_PUSH_BYTES (sizeof(int)+sizeof(u16_t)+sizeof(u32_t))
