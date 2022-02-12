/* The <sys/types.h> header contains important data type definitions.
 * It is considered good programming practice to use these definitions, 
 * instead of the underlying base type.  By convention, all type names end 
 * with _t.
 */

#ifndef _TYPES_H
#define _TYPES_H

/* _ANSI is somehow used to determine whether or not the compiler is a
 * 16 bit compiler
 */
#ifndef _ANSI
#include <ansi.h>
#endif

/* The type size_t holds all results of the sizeof operator.  At first glance,
 * it seems obvious that it should be an unsigned int, but this is not always 
 * the case. For example, MINIX-ST (68000) has 32-bit pointers and 16-bit
 * integers. When one asks for the size of a 70K struct or array, the result 
 * requires 17 bits to express, so size_t must be a long type.  The type 
 * ssize_t is the signed version of size_t.
 */
#ifndef _SIZE_T
#define _SIZE_T
typedef unsigned int size_t;
#endif

#ifndef _SSIZE_T
#define _SSIZE_T
typedef int ssize_t;
#endif

#ifndef _TIME_T
#define _TIME_T
typedef long time_t;		   /* time in sec since 1 Jan 1970 0000 GMT */
#endif

#ifndef _CLOCK_T
#define _CLOCK_T
typedef long clock_t;		   /* unit for system accounting */
#endif

#ifndef _SIGSET_T
#define _SIGSET_T
typedef unsigned long sigset_t;
#endif

/* Types used in disk, inode, etc. data structures. */
typedef short          dev_t;	   /* holds (major|minor) device pair */
typedef char           gid_t;	   /* group id */
typedef unsigned short ino_t; 	   /* i-node number */
typedef unsigned short mode_t;	   /* file type and permissions bits */
typedef char         nlink_t;	   /* number of links to a file */
typedef unsigned long  off_t;	   /* offset within a file */
#ifdef __MLONG__		   /* shared between kernel and user */
typedef short          pid_t;	   /* process id (must be signed) */
#else
typedef int            pid_t;	   /* process id (must be signed) */
#endif /* __MLONG__ */
typedef short          uid_t;	   /* user id */
typedef unsigned long zone_t;	   /* zone number */
typedef unsigned long block_t;	   /* block number */
typedef unsigned long  bit_t;	   /* bit number in a bit map */
typedef unsigned short zone1_t;	   /* zone number for V1 file systems */
typedef unsigned short bitchunk_t; /* collection of bits in a bitmap */

typedef unsigned char   u8_t;	   /* 8 bit type */
typedef unsigned short u16_t;	   /* 16 bit type */
typedef unsigned long  u32_t;	   /* 32 bit type */

typedef char            i8_t;      /* 8 bit signed type */
typedef short          i16_t;      /* 16 bit signed type */
typedef long           i32_t;      /* 32 bit signed type */

/* The following types are needed because MINIX uses K&R style function
 * definitions (for maximum portability).  When a short, such as dev_t, is
 * passed to a function with a K&R definition, the compiler automatically
 * promotes it to an int.  The prototype must contain an int as the parameter,
 * not a short, because an int is what an old-style function definition
 * expects.  Thus using dev_t in a prototype would be incorrect.  It would be
 * sufficient to just use int instead of dev_t in the prototypes, but Dev_t
 * is clearer.
 */
typedef int            Dev_t;
typedef int 	       Gid_t;
typedef int 	     Nlink_t;
typedef int 	       Uid_t;
typedef int             U8_t;
typedef unsigned long  U32_t;
typedef int             I8_t;
typedef int            I16_t;
typedef long            I32_t;
typedef int		Pid_t;

/* ANSI C makes writing down the promotion of unsigned types very messy.  When
 * sizeof(short) == sizeof(int), there is no promotion, so the type stays
 * unsigned.  When the compiler is not ANSI, there is usually no loss of
 * unsignedness, and there are usually no prototypes so the promoted type
 * doesn't matter.  The use of types like Ino_t is an attempt to use ints
 * (which are not promoted) while providing information to the reader.
 */

#ifndef _ANSI_H
#include <ansi.h>
#endif

#if _EM_WSIZE == 2 || !defined(_ANSI)
typedef unsigned int      Ino_t;
typedef unsigned int    Zone1_t;
typedef unsigned int Bitchunk_t;
typedef unsigned int      U16_t;
typedef unsigned int  Mode_t;

#else /* _EM_WSIZE == 4, or _EM_WSIZE undefined, or _ANSI defined */
typedef int	          Ino_t;
typedef int 	        Zone1_t;
typedef int	     Bitchunk_t;
typedef int	          U16_t;
typedef int           Mode_t;

#endif /* _EM_WSIZE == 2, etc */
 
/* Signal handler type, e.g. SIG_IGN */
#if defined(_ANSI)
typedef void (*sighandler_t) (int);
#else
typedef void (*sighandler_t)();
#endif

#endif /* _TYPES_H */
