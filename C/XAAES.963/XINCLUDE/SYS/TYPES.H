#ifndef _SYS_TYPES_H
#define _SYS_TYPES_H 1

#ifndef _COMPILER_H
#include <compiler.h>
#endif

begin_decls

#ifndef _SIZE_T
#define _SIZE_T __SIZE_TYPEDEF__
typedef _SIZE_T size_t;
#endif

#ifdef __MSHORT__
typedef long		ssize_t;
#else
typedef int		ssize_t;
#endif

#ifndef _TIME_T
#define _TIME_T long
typedef _TIME_T time_t;
#endif

#ifndef _SYS_TIME_H
# ifndef __need_struct_timeval
#  define __need_struct_timeval
# endif
#  include <sys/time.h>
# undef __need_struct_timeval
#endif

typedef unsigned short	dev_t;		/* holds a device type */
typedef _GID_T		gid_t;		/* group id type */
typedef unsigned long	ino_t;		/* holds an inode (fake under GEMDOS) */
typedef unsigned short	mode_t;		/* file mode */
typedef short		nlink_t;
typedef long		off_t;
typedef _PID_T		pid_t;		/* process id type */
typedef _UID_T		uid_t;		/* user id type */
#define gid_t		gid_t
#define pid_t		pid_t
#define uid_t           uid_t

#ifdef __USE_BSD
typedef unsigned char	u_char;
typedef unsigned short	u_short;
typedef unsigned int 	u_int;
typedef unsigned long	u_long;
#endif

#ifdef __USE_SVID
typedef unsigned char	unchar;
typedef unsigned short	ushort;
typedef unsigned int	uint;
typedef unsigned long	ulong;
#endif

typedef void *		caddr_t;

#define major(dev)	(((dev) >> 8) & 0xff)
#define minor(dev)	((dev) & 0x00ff)
#define makedev(x,y)	((dev_t) ((((x) & 0xff) << 8) | ((y) & 0xff)))

/* These size-specific names are used by some of the inet code.  */

#if !defined (__GNUC__) || __GNUC__ < 2 || __GNUC_MINOR__ < 7

typedef	char int8_t;
typedef	unsigned char u_int8_t;
typedef	short int int16_t;
typedef	unsigned short int u_int16_t;
typedef	long int32_t;
typedef	unsigned long u_int32_t;
typedef long long int int64_t;
typedef unsigned long long int u_int64_t;
typedef long register_t;

#else

/* For GCC 2.7 and later, we can use specific type-size attributes.  */
#define __intN_t(N, MODE) \
  typedef int int##N##_t __attribute__ ((__mode__ (MODE)))
#define __u_intN_t(N, MODE) \
  typedef unsigned int u_int##N##_t __attribute__ ((__mode__ (MODE)))

__intN_t (8, __QI__);
__u_intN_t (8, __QI__);
__intN_t (16, __HI__);
__u_intN_t (16, __HI__);
__intN_t (32, __SI__);
__u_intN_t (32, __SI__);
__intN_t (64, __DI__);
__u_intN_t (64, __DI__);

typedef int register_t __attribute__ ((__mode__ (__word__)));
#endif

/* Some code from BIND tests this macro to see if the types above are
   defined.  */
#define __BIT_TYPES_DEFINED__	1

#ifdef	__USE_BSD
/* In BSD <sys/types.h> is expected to define BYTE_ORDER.  */
#include <endian.h>

#if 0
/* It also defines `fd_set' and the FD_* macros for `select'.  
   This should be done in future versions of the MiNTLib.  */
#include <sys/select.h>
#endif
#endif /* Use BSD.  */

#ifndef _FD_SET_T
#define _FD_SET_T unsigned long
typedef _FD_SET_T fd_set;
#endif

#define FD_ZERO(set)		(*(set) = 0L)
#define FD_CLR(fd, set)		(*(set) &= ~(1L << (fd)))
#define FD_SET(fd, set)		(*(set) |= (1L << (fd)))
#define FD_ISSET(fd, set)	(*(set) & (1L << (fd)))
#define FD_SETSIZE		32

int truncate	(const char *_filename, off_t length);
int __truncate	(const char *_filename, off_t length);
int ftruncate	(int fd, off_t length);
int __ftruncate	(int fd, off_t length);

#include <utime.h>	/* sigh! */

end_decls

#endif /* _TYPES_H */
