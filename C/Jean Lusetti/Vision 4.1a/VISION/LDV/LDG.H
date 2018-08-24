/*
 *	Librairies Dynamiques GEM	(LDG)
 *	definitions for clients and servers
 *	portable version for Gcc, Pure C and Sozobon C
 *
 *	Copyright 97/98/99/2000
 *  by Olivier Landemarre and Dominique B‚r‚ziat
 *
 *	Current version : 2.00
 *	This file should be included _after_ the AES definitions.
 */

#ifndef __LDG__
#define __LDG__

#include <portab.h>
#ifdef __SOZOBONX__
	#include <stddef.h>
	#include <types.h>
	#define CDECL
	#define EXTERN	extern
#endif

#ifdef _GEMLIB_H_
	#define ldg_global	aes_global
#else
	#ifdef __PUREC__
	#define ldg_global	_GemParBlk.global
	#else
	#define ldg_global	global
	#endif
#endif

#define LDG_QUIT       	0x4C4A 		/* ldg->client : a lib should term */
#define LDG_COOKIE     	0x4C44474DL	/* 'LDGM' */
#define PATHLEN			128

/*
 * Data structures
 */

typedef struct entrie {
	char *name;  	/* Function name */
	char *info;  	/* Describe the prototype of the function */
	void *func;  	/* Function address*/
} PROC;

/* 
 * The LDG-library descriptor (private)
 */

typedef struct ldg {
	LONG magic;				/* magic number ('LDGM')   */
	WORD vers;				/* library version 	*/
	WORD id;				/* AES-id of launcher */
	WORD num;				/* count of avalaible functions */
	PROC *list;				/* pointer to the functions list */
	char *infos;			/* describe the library */
	void *baspag;			/* basepage of library */
/* from version 0.99 */
	UWORD flags;			/* librarys flag ( shared, resident, locked) */
/* from version 0.99c */
	void (*close)(void);	/* fonction launched by ldg_term() */
/* from version 1.00 */
	WORD vers_ldg;			/* LDG-protocol version */
	char path[PATHLEN];		/* real path of the lib */
	LONG user_ext;			/* own library extension */
	LONG addr_ext;			/* for future extension */
} LDG;

/*
 * The LDG cookie
 */

typedef struct {

	WORD version;			/* The cookie number version */
	char path[PATHLEN];		/* Path of LDG-libraries */
	WORD garbage;			/* The garbage collector time */
	WORD idle;				/* Obsolet : for backward compatibility */
	
	LDG*  CDECL (*ldg_open)	  ( char *lib, WORD *gl); 
							/* Open a library */
	WORD  CDECL (*ldg_close)  ( LDG *ldg, WORD *gl);  
							/* Close a library */
	VOID* CDECL (*ldg_find)	  ( char *fnc, LDG *ldg);
							/* Find a function in a library */
	LDG*  CDECL (*ldg_open_ev)( char *lib, WORD *gl, VOID (*)(WORD*));
							/* Obsolet : for backward compatibility */
	WORD  error;			/* Last error occuring */
	VOID  CDECL (*ldg_garbage)( WORD *gl);
							/* Release unused libs */
	VOID  CDECL	(*ldg_reset)( WORD *gl);
							/* Release all libs */
	VOID* internal;			/* Reserved */
	WORD  CDECL (*ldg_libpath)( char *, WORD *global);
							/* Find the path of a library */
} LDG_INFOS;

/*
 * This structure is used by ldg_init() to initiate the
 * the LDG-protocol inside a LDG-library.
 */

typedef struct ldglib {
	WORD vers;   			/* library version */
	WORD num;    			/* count of avalaible functions */
	PROC *list;  			/* pointer to the functions list */
	char *infos; 			/* description of the lib */
	UWORD flags;			/* library flag (shared, locked, resident) */
	void (*close)(void);	/* function executed by ldg_term()*/
	LONG user_ext;			/* own library extension */
} LDGLIB;

/* value of the 'flag' field */
#define LDG_NOT_SHARED	0x1	/* the library is unshareable */
#define LDG_LOCKED		0x2	/* the library is locked */
#define LDG_RESIDENT	0x4 /* zhe library is memory resident */

/* Errors returned by ldg_error() */
#define LDG_LIB_FULLED	-1
#define LDG_APP_FULLED	-2
#define LDG_ERR_EXEC	-3
#define LDG_BAD_FORMAT	-4
#define LDG_LIB_LOCKED	-6
#define LDG_NO_MANAGER	-7
#define LDG_NOT_FOUND	-8
#define LDG_BAD_LIB		LDG_BAD_FORMAT
#define LDG_NO_MEMORY	-9
#define LDG_TIME_IDLE	-10
#define LDG_NO_TSR		-11
#define LDG_BAD_TSR		-12

/* Client functions */
LDG*	ldg_open	( char *name, WORD *gl);
WORD	ldg_close	( LDG *lib, WORD *gl);
WORD	ldg_error	( void);
void*	ldg_find	( char *name, LDG *ldg);
WORD 	ldg_libpath	( char *path, WORD *gl);

/* Server functions */
int		ldg_init	( LDGLIB *libldg);
char   *ldg_getpath	( void);

/* Diverses functions */
int 	ldg_cookie	( long, long *);
void 	ldg_debug	( char *, ...);
void*	ldg_Xalloc	( long size);
void*	ldg_Calloc	( long count,long size);
int 	ldg_Free	( void *memory);
void*	ldg_Realloc	( void *oldblk, long oldsize, long newsize);

/* For backward compatibility */
#define ldg_exec(a,b)	ldg_open( b, ldg_global)
#define ldg_exec_evnt(a,b,c)	ldg_open( b, ldg_global)
#define ldg_term(a,b)	ldg_close( b, ldg_global)
#define ldg_libexec_evnt(a,b,c)	ldg_open( a, b)
#define ldg_libexec(a,b)	ldg_open( a, b)
#define ldg_libterm(a,b)	ldg_close( a,b)

/* C-library version (currently 1.20) */
struct version {
	char *name;
	WORD  num;
};

extern struct version  ldg_version;

#endif __LDG__
