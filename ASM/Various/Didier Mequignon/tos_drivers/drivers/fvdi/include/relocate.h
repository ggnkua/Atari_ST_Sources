#ifndef RELOCATE_H
#define RELOCATE_H
/*
 * fVDI driver->engine interface declarations, by Johan Klockars.
 *
 * Since it would be difficult to do without this file when
 * writing new device drivers, and to make it possible for
 * some such drivers to be commercial, this file is put in
 * the public domain. It's not copyrighted or under any sort
 * of license.
 */

#include "fvdi.h"

/*
 * Structure definitions
 */
typedef struct _Prgheader {
   short magic;
   long  tsize;
   long  dsize;
   long  bsize;
   long  ssize;
   long  reserved;
   long  flags;
   short relocflag;
} Prgheader;

typedef struct _Funcs {
	void CDECL (*copymem)(const void *s, void *d, long n);
	const char* CDECL (*next_line)(const char *ptr);
	const char* CDECL (*skip_space)(const char *ptr);
	const char* CDECL (*get_token)(const char *ptr, char *buf, long n);
	long  CDECL (*equal)(const char *str1, const char *str2);
	long  CDECL (*length)(const char *text);
	void CDECL (*copy)(const char *src, char *dest);
	void CDECL (*cat)(const char *src, char *dest);
	long  CDECL (*numeric)(long ch);
	long CDECL (*atol)(const char *text);
	void CDECL (*error)(const char *text1, const char *text2);
	void* CDECL (*malloc)(long size, long type);			/* Uses Mxalloc if possible */
	long CDECL (*free)(void *addr);
	int CDECL (*puts)(const char *text);
	void CDECL (*ltoa)(char *buf, long n, unsigned long base);
	long CDECL (*get_cookie)(const unsigned char *cname, long super);
	long CDECL (*set_cookie)(const unsigned char *cname, long value);
	long CDECL (*fixup_font)(Fontheader *font, char *buffer, long flip);
	long CDECL (*unpack_font)(Fontheader *header, long format);
	long CDECL (*insert_font)(Fontheader **first_font, Fontheader *new_font);
	long CDECL (*get_size)(const char *name);
	char* CDECL (*allocate_block)(long size);
	void CDECL (*free_block)(void *address);
	void CDECL (*cache_flush)(void);
	long CDECL (*misc)(long func, long par, const char *token);
	long CDECL (*event)(long id_type, long data);
} Funcs;

typedef struct _Vars {
	long	*version;
	char	*name;
} Vars;

typedef struct _Access {
	Funcs	funcs;
	Vars	vars;	
} Access;

typedef struct _Locator {
	char 	magic[10];
	short	version;
	long  CDECL (*init)(Access *, Driver *, Virtual *, char *);
} Locator;

#endif
