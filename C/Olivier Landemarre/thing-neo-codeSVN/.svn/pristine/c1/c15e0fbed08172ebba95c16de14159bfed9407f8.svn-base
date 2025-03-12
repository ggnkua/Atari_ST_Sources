#ifndef _PWD_H
#define _PWD_H
/* file to describe password file fields */
/*
Revised 29/01/93 by Hildo Biersma (boender@dutiws.twi.tudelft.nl):
- include aging info
- support System V routines
*/

#ifndef _COMPILER_H
#include <compiler.h>
#endif

#ifndef _POSIX_SOURCE
#ifndef _STDIO_H
#include <stdio.h>
#endif
#endif /* _POSIX_SOURCE */

#ifdef __cplusplus
extern "C" {
#endif

struct passwd
{
        char    *pw_name;    /* login name                  */
        char    *pw_passwd;  /* encrypted password          */
        _UID_T  pw_uid;      /* numerical user ID           */
        _GID_T  pw_gid;      /* numerical group ID          */
        char    *pw_age;     /* password aging information  */
        char    *pw_comment; /* same string as pw_gecos     */
        char    *pw_gecos;   /* gecos (comment) field       */
        char    *pw_dir;     /* initial working directory   */
        char    *pw_shell;   /* program to use as a shell   */
};

__EXTERN struct passwd	*getpwnam __PROTO((const char *));
__EXTERN struct passwd	*getpwuid __PROTO((_UID_T));

#ifndef _POSIX_SOURCE
__EXTERN void		endpwent	__PROTO((void));
__EXTERN struct passwd	*fgetpwent	__PROTO((FILE *));
__EXTERN int		getpw		__PROTO((int, char *));
__EXTERN struct passwd	*getpwent	__PROTO((void));
__EXTERN int		putpwent __PROTO((const struct passwd *, FILE *));
__EXTERN void		setpwent	__PROTO((void));
__EXTERN void		setpwfile	__PROTO((char *));
#endif /* _POSIX_SOURCE */

#ifdef __cplusplus
}
#endif

#endif /* _PWD_H */
