#ifndef __MANILIBS_DYNBLOCK_H__
#define __MANILIBS_DYNBLOCK_H__

#ifndef __PORTAB__
#include <portab.h>
#endif
#include <i:\c\fremde\manitor\manilibs\alloc\alloc.h>
#include <i:\c\fremde\manitor\manilibs\sysinfo\sysinfo.h>

typedef struct {
	void *adr;
	int32 len;
	int32 alloclen;
	int16 xmode;			/* Modus fÅr xalloc */
	SYSINFO *info;
} DYN_BLOCK;


#define DYN_VORAUS 1024


	#define dyn_init(dyn) xdyn_init(dyn, ALLOC_ATARI, 0L);
	void xdyn_init(DYN_BLOCK *dyn, int16 mode, SYSINFO *info);

void dyn_free(DYN_BLOCK *dyn);

boolean dyn_add_len(DYN_BLOCK *dyn, int32 len);
boolean dyn_add_block(DYN_BLOCK *dyn, void *adr, int32 len);
boolean dyn_add_string(DYN_BLOCK *dyn, char *adr);		/* Nullbyte wird NICHT angehaengt!!! */
boolean dyn_add_string0(DYN_BLOCK *dyn, char *adr);		/* mit Nullbyte! */
boolean dyn_add_string00(DYN_BLOCK *dyn, char *adr);	/* mit zwei Nullbytes! */
boolean dyn_add_null(DYN_BLOCK *dyn);	/* Haengt Nullbyte an */
boolean dyn_add_crlf(DYN_BLOCK *dyn);	/* HÑngt CR/LF an */
boolean dyn_add_line(DYN_BLOCK *dyn, char *adr);	/* HÑngt String+CRLF an */
boolean dyn_add_string_evtl_quoted(DYN_BLOCK *dyn, char *s, boolean *leer_flag);
boolean dyn_kill_last(DYN_BLOCK *dyn);	/* letzten (durch 0 getrennten) Parameter lîschen und 00-Abschluû erzeugen */

#endif
