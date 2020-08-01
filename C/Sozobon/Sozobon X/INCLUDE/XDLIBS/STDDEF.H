/*
 * @(#)stddef.h, XdLibs, SozobonX
 *
 * standard definitions
 * 
 * you won't have to include this file explicitly, cause it is included by
 * stdlib.h/stdio.h. and via types.h
 * -jerry-
 * last change:
 *  -VS: 1995/08/28
 */

#ifndef _STDDEF_H
#define _STDDEF_H

#if 0
#define const
#define volatile
#define cdecl
#endif

#define	dLibs		(0x1200)
					/* dLibs identifier (also vsn #) */

#define _XDLIBS		0x113
					/* XDLIBS identifier, there is an
				   variable _xdlibs in library with the same value	*/ 
#define	_XDLIBSVERSION "1.13"	
					/* same as string	*/

extern	int	_xdlibs;

/* 
 *  These
 *  Patchlevel Ident strings are linked
 *  by request of startup code
 */
extern char __Ident_lib[];
extern char __Ident_libx[];

		/* void pointer	*/
#ifndef	NULL
#define	NULL	(void *)0L
#endif

#ifndef	FALSE
#define	FALSE	0
#endif

#ifndef TRUE
#define	TRUE	1
#endif

#ifndef NIL
#define	NIL	-1
#endif

	/* end of string	*/
#ifndef EOS
#define	EOS	'\000'
#endif

#ifdef	size_t
/* #error "you shouldn't redefine this type 'size_t'" */
#pragma echo you shouldn't redefine this type 'size_t'
#else
# ifdef __SIZE_T_LONG__
typedef	unsigned long	size_t;		/* sizeof() value type */
# else
typedef	unsigned int	size_t;		/* sizeof() value type */
# endif /* SIZE_T_LONG */
#endif /* size_t */

#ifdef	ptrdiff_t
#pragma echo you shouldn't redefine this type 'ptrdiff_t'
#else
typedef	long		ptrdiff_t;	/* pointer subtraction result type */
#endif /* prtdiff_t */

#ifdef wchar_t
#pragma echo you shouldn't redefine this type 'wchar_t'
#else
typedef char		wchar_t;
#endif

/* offset in bytes of 'membr' in structure 'Typ' */
#define offsetof(T,m) \
	((size_t) (((char *) &(((T *) 256)->m)) - ((char *) ((T *) 256))))
 /* #define offsetof(TYPE, MEMBER) ((size_t) &((TYPE *)0)->MEMBER) */

#endif 	/* _STDDEF_H */
