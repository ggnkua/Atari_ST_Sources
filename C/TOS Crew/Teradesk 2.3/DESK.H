/*
 * Teradesk. Copyright (c) 1993, 1994, 2002 W. Klaren.
 *
 * This file is part of Teradesk.
 *
 * Teradesk is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Teradesk is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Teradesk; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include <boolean.h>
#include <stddef.h>

#ifdef MEMDEBUG
#include <d:\tmp\memdebug\memdebug.h>
#endif

char *itoa(int value, char *string, int radix);
char *ltoa(long value, char *string, int radix);

#undef O_APPEND

#define min(x,y)		(((x) < (y)) ? (x) : (y))
#define max(x,y)		(((x) > (y)) ? (x) : (y))

#define MAGIC		0x87654321L

#define GLOBAL_MEM_SIZE	1024L

typedef enum
{
	PGEM = 0, PGTP, PACC, PTOS, PTTP			/* HR 101202: PACC */
} ApplType;

typedef struct
{
	int version;				/* config. file version */
	unsigned long magic;		/* fingerprint for identifying this file */
	int cprefs;					/* copy and program preferences */
	char mode;					/* text or icon mode */
	char sort;					/* sorting rule */
	int attribs;				/* attributes of visible directory items */
	int tabsize;				/* tab size */
	int bufsize;				/* copy buffer size */
	unsigned char dsk_pattern;	/* desktop pattern */
	unsigned char dsk_color;	/* desktop colour */
	unsigned int dial_mode:2;
	int resvd1:14;
	int resvd2;
	struct V2_2_Opt				/* HR 230103: Put in a struct, so it is easier to handle older cfg versions. */
	{
		int vprefs;                 /* DjV 005 251202: video preferences  */
		char fields;                /* DjV 005 251202: file data elements */
		char place1[7];				/* DjV 005 251202: placeholder for any future add-on */
		unsigned char win_pattern;  /* DjV 005 251202: window pattern   */
		unsigned char win_color;    /* DjV 005 251202: window colour    */
		int vrez;                   /* DjV 005 251202: video resolution */
		int kbshort[64];			/* DjV 005 030103: for future keyboard shortcute */
	} V2_2;
} Options;

typedef struct
{
	int item;					/* nummer van icoon */
	int m_x;					/* coordinaten middelpunt t.o.v. muis, alleen bij iconen */
	int m_y;
	int np;						/* aantal punten */
	int coords[18];				/* coordinaten van schaduw */
} ICND;

typedef struct
{
	int phy_handle;
	int vdi_handle;
	RECT dsk;
	int fnt_w;
	int fnt_h;
} SCRINFO;

typedef char SNAME[14];			/* HR 240203 */
typedef char LNAME[130];

/* Opties */

#define CF_COPY			0x0001
#define CF_DEL			0x0002
#define CF_OVERW		0x0004
#define CF_PRINT		0x0008 /* DjV 031 010203 */

#define TOS_KEY			0x0020	/* 0 = continue, 1 = wait */
#define DIALPOS_MODE	0x0040	/* 0 = mouse, 1 = center */

#define SAVE_COLORS		0x0100
#define TOS_STDERR		0x0200	/* 0 = no redirection, 1 = redirect handle 2 to 1. */
#define CF_KEEP			0x0400	/* DjV 016 050103 */

#define TEXTMODE		0
#define ICONMODE		1

#define WD_SORT_NAME	0
#define WD_SORT_EXT		1
#define WD_SORT_DATE	2
#define WD_SORT_LENGTH	3
#define WD_NOSORT		4

/* DjV 010 251202 ---vvv--- */
#define WD_SHSIZ 0x0001 /* show size */
#define WD_SHDAT 0x0002 /* show date */
#define WD_SHTIM 0x0004 /* show time */
#define WD_SHATT 0x0008 /* show attributes */
/* DjV 010 251202 ---^^^--- */

/* DjV 007 251202 ---vvv--- */
#define VO_BLITTER 0x0001 /* video option blitter  */
#define VO_OVSCAN  0x0002 /* video option overscan */
/* DjV 007 251202 ---^^^ --- */

/* DjV 019 080103 290103 ---vvv--- */

/* 
 * It is assumed that the first menu item for which a keyboard shortcut
 * can be defined is MOPEN and the last is MSAVEAS; the interval
 * is defined below by MFIRST and MLAST. 
 * Index of the fist relevant menu title is likewise defined.
 * Beware of dimensioning options.kbshort[64]; it should be larger
 * than NITEM below; dimensioning to 64 is fixed in order to avoid 
 * incompatibility of cfg files if number of menu items is changed;
 * currently, 58 out of 64 are used.
 */

#define MFIRST MOPEN			/* first item for which a shortcut can be */
#define MLAST  MSAVEAS			/* last */
#define TFIRST TLFILE			/* title under which the first item is */
#define NITEM MLAST - MFIRST	/* number of, -1 */

/* DjV 019 080103 290103 ---^^^--- */

extern Options options;
extern SCRINFO screen_info;
extern int vdi_handle, ncolors, npatterns, max_w, max_h, ap_id, nfonts;
extern boolean quit;

#if _MINT_
extern boolean mint,			/* HR 151102 */
               geneva,			/* DjV 035 080203 */
               magx;
#endif

extern int colour_icons;

extern char *global_memory;

long btst(long x, int bit);
void set_opt(OBJECT *tree, int flags, int opt, int button ); /* DjV 004 020103 */
void get_opt(OBJECT *tree, int *flags, int opt, int button ); /* DjV 004 030103 */

void digit(char *s, int x);
void cv_formtofn(char *dest, const char *source);
void cv_fntoform(OBJECT *ob, const char *source);			/* HR 240103 */
void cramped_name(const char *s, char *t, int w);
void strip_name (char *dst, const char *src); 			/* HR 151102 */
char *strsncpy(char *dst, const char *src, size_t len);	/* HR 120203: secure cpy (0 --> len-1) */

int hndlmessage(int *message);
