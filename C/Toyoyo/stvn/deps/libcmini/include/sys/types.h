#ifndef _SYS_TYPES_H
#define _SYS_TYPES_H 1

#ifndef _FEATURES_H
# include <features.h>
#endif

typedef signed char __int8_t;
typedef unsigned char __uint8_t;
typedef signed short int __int16_t;
typedef unsigned short int __uint16_t;
#if !defined(__MSHORT__) && !defined(__PUREC__) && !defined(__AHHC__)
typedef signed int __int32_t;
typedef unsigned int __uint32_t;
#else
typedef signed long int __int32_t;
typedef unsigned long int __uint32_t;
#endif /* __MSHORT__ */
#ifdef __GNUC__
typedef signed long long int __int64_t;
typedef unsigned long long int __uint64_t;
#endif  /* GNUC */

#ifdef __GNUC__
typedef unsigned long long int __u_quad_t;
typedef long long int __quad_t;
#else
typedef struct
{
  long __val[2];
} __quad_t;
typedef struct
{
  __uint32_t __val[2];
} __u_quad_t;
#endif  /* GNUC */
typedef __quad_t __dev_t;	/* Type of device numbers.  */

typedef __uint32_t __uid_t;	/* Type of user identifications.  */
typedef __uint32_t __gid_t;	/* Type of group identifications.  */
typedef __uint32_t __ino_t;	/* Type of file serial numbers.  */
typedef __uint32_t __mode_t;	/* Type of file attribute bitmasks.  */
typedef __uint32_t __nlink_t;   /* Type of file link counts.  */
typedef signed long int __ssize_t;	/* Type of a byte count, or error.  */
typedef __int32_t __off_t;	/* Type of file sizes and offsets.  */
typedef __int32_t __clock_t;	/* Type of CPU usage counts.  */
typedef __int32_t __time_t;
typedef long int __suseconds_t;
typedef int __pid_t;		/* Type of process identifications.  */

typedef long loff_t;

#ifndef __gid_t_defined
typedef __gid_t gid_t;
# define __gid_t_defined 1
#endif

#ifndef __mode_t_defined
typedef __mode_t mode_t;
# define __mode_t_defined 1
#endif

#ifndef __uid_t_defined
typedef __uid_t uid_t;
# define __uid_t_defined 1
#endif

#ifndef __off_t_defined
typedef __off_t off_t;
# define __off_t_defined 1
#endif

#ifndef __pid_t_defined
typedef __pid_t pid_t;
# define __pid_t_defined 1
#endif

#ifndef __ssize_t_defined
typedef __ssize_t ssize_t;
# define __ssize_t_defined 1
#endif

#ifndef __time_t_defined
typedef __time_t time_t;
#define __time_t_defined 1
#endif

#ifndef __clock_t_defined
typedef __clock_t clock_t;
#define __clock_t_defined 1
#endif

#endif /* _TYPES_H */
