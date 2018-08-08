/* Compatibility Defines */
#ifndef _LATTICE_H_
#define _LATTICE_H_
#ifdef LATTICE

#include <basepage.h>

#define UBYTE unsigned char
#define UWORD unsigned short
#define ULONG unsigned long
#define BYTE signed char
#define WORD signed short
#define LONG signed long
#define VOID void
#define BOOLEAN unsigned char
#define cdecl 

#define _PgmSize (_pbase->p_tlen + _pbase->p_dlen + _pbase->p_blen)

typedef struct timdat {
	unsigned time;
	unsigned date;
} DOSTIME;

typedef struct _osheaderpc {
	unsigned os_entry;
	unsigned os_version;
	void *reseth;
	struct _osheader *os_beg;
	char *os_end;
	char *os_rsv1;
	char *os_magic;
	LONG os_date;
	char **p_root;
	char **p_kbshift;
	char **_run;
	char *p_rsv2;
} OSHEADERPC;

typedef struct _osheaderpc SYSHDR;
#define BASPAG BASEPAGE
#define _BasPag _pbase

#endif
#endif