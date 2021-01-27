/*  Copyright (c) 1990 - present by Henk Robbers Amsterdam.
 *
 * This file is part of AHCC.
 *
 * AHCC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * AHCC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with AHCC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#ifndef AAAA_LIB_H
#define AAAA_LIB_H

#ifndef PRELUDE_H
#include <prelude.h>
#endif

#ifndef STDIO_H
#include <stdio.h>
#endif

#ifndef TOS_GEM_H
#include <tos_gem.h>
#endif

#ifndef __NKCC
#include "common/aaaankcc.h"
#endif

#ifndef SCR_INST_H
#include "common/scr_inst.h"
#endif

#ifndef HIERARCH_H
#include "common/hierarch.h"
#endif

void nop(void) 047161;

typedef struct
{
	union
	{
		char str[10];
		struct
		{
			char optn[4];
			char vul [2];
			char srt;
			char nl;
			char nul[2];
		} o;
	} s;
	short max;				/* negative: accept input; dont write */
	void *	const a;
	short 	ob;
	short 	ty;
	short 	menuob;
	short 	menuty;
} OpEntry;

bool	loadconfig	(FILE *f,OpEntry *tab, short lvl);
void	saveconfig	(FILE *f,OpEntry *tab, short lvl);

typedef void CFGNEST(FILE *fp, OpEntry **tab, short lvl, short io);

#define fslash '/'
#define sfslash "/"
#define bslash '\\'
#define sbslash "\\"

#define bold 1
#define light 2
#define italic 4
#define ulined 8
#define white 16

#define tx16 13
#define tx8 6

#define min(a,b) ((a) < (b) ? (a) : (b))
#define max(a,b) ((a) > (b) ? (a) : (b))

#ifndef max
short max(short a, short b);
#endif
#ifndef min
short min(short a, short b);
#endif

/* directory name length */
#define DIRL 130

#define via(v) if (v)(*v)
#define strpar(x) #x

#define hidem graf_mouse(256, 0x0L)
#define showm graf_mouse(257, 0x0L)

#define mouse(x, y, k, s) graf_mkstate(&x, &y, &k, &s)
#define mpijl marrow()
#define mbumble graf_mouse(2,0x0L)
#define openkruis graf_mouse(7,0x0L)
#define wrijfhand graf_mouse(4,0x0L)
#define draadkruis graf_mouse(5,0x0L)
#define wacht(a,b)
#define break_in (Kbshift(-1)==3)

#define loop(i,a) for(i = 0; i < a; i++)
#define ping Cconout(7);
#define keus(b) (b.state & SELECTED)
#define keusaf(b) b.state&=~SELECTED
#define keusop(b) b.state|=SELECTED
#define enable(b) b.state&=~DISABLED
#define disable(b) b.state|=DISABLED
#define unhide(b) b.flags&=~HIDETREE
#define hide(b) b.flags|=HIDETREE

#define LETTERS ('z' - 'a' + 1)

typedef enum
{
	RSHIFT   = NKF_RSH,
	LSHIFT   = NKF_LSH,
	CONTRL   = NKF_CTRL,
	ALTERNATE= NKF_ALT,
	DRAG     = 16,
	NO_DRAG  = 32
} KSTATE;

typedef enum {CLICK, HOLD} MOVE_MODE;
extern
MOVE_MODE move_mode;		/*        "         "   */

typedef void VpIIIII (short, short, short, short, short);
typedef void VpIR    (short, RECT);


short 	aform_do	(OBJECT *db,
                    short start, short *cured, short movob, short undoob);
short 	aform_move	(OBJECT *db, short hl, void *area, bool snap,
                    short edob, short *cured, short moveob, short undoob,
                    RECT *vrijheid);
							/* form_move/form_do met teruggave cursor pos */
void	copy_gform	(short hl, DRBVN pxy, MFDB *schrm, MFDB *dump);

void	movebox		(short hl, RECT *d, PRB *p, short init, void (*rat)(void) );
void	draw_ob		(OBJECT *ob,short item,RECT cl,short which);
short 	mousek		(void);
void	mv_rat		(RECT *ps, PRB *p);			/* absolute minimum (denk aan clipping) */
void	mv_scrrat	(RECT *ps,PRB *p);		/* check against screen without sticking */
void	mv_snaprat	(short ol,bool snap,bool stick,RECT *ps,PRB *p,RECT o);	/* snap box op inline & check outline op bounds */

short 	init_field	(OBJECT *o, short sf);
short 	first_edob	(OBJECT *o);
short 	last_edob	(OBJECT *o);
short 	prev_edob	(OBJECT *o, short i);
short 	next_edob	(OBJECT *o, short i);
short 	find_def	(OBJECT *o);
void	s_to_xstr	(OBJECT *ob, short item1, short item2, Cstr s);
void	xstr_to_s	(OBJECT *ob, short item1, short item2, S_path *p);

short 	form_move	(OBJECT *db,short hl,void *area,bool snap, short edob,short moveob,short undoob,RECT *vrijheid);
							/* move moveable dialogebox save screenarea */
void *	form_save	(OBJECT *db,short startob,short hl);
							/* save diologeboxes screenarea: return dumparea */
void	form_rest	(OBJECT *db,short startob,short hl,void *area);
							/* restore screenarea                   */
void	form_align	(OBJECT *dial,bool snap,short x,short y, RECT *vrijheid);
							/* align dialoguebox with menu title's x
							   and given x and y or around mouse if x < 0
							   fac snap h/w ch against bound */
short cdecl form_choice(short hl, char *title, char *mt, ...);
bool  cdecl form_edit  (short hl, char *title, short fs, ...);

short 	get_parent  (OBJECT *tree, short obj);	/* common/parent.s */

bool	new_cookie	(long cook_id, long cook_val);
bool	get_cookie	(long cookie,  long *value);
void	strsncpy	(Wstr dest, Cstr src, long len);	/* secure string copy */
bool	match_pattern	(Cstr t, Cstr pat);

/* gebruikt TOS fsel_exinput */
char *select_file(		/* return: complete hierarchische naam tbv Open  */
     S_path *directory,	/* in:  directory pad met wildcards      */
     S_path *pad,		/* uit: selectiepad tbv bv Fsfirst       */
     S_path *fkeus,		/*  "   kale filenaam met ev extension   */
	 char *opm,			/* in:  tekst in box					 */
     short*drive);		/* uit: drive nummer tbv bv Dsetdrv      */

/* gebruikt TOS fsel_input (werkelijk heel,heel oud) */
char *oselect_file(
	 char *diry,
	 char *pad,
	 char *fkeus,
	 short *drive);

int denotation_space(long big, int root);

char *	cb	 (unsigned long  getal,short l,short zerosuppress,short radix);
char *	cbr  (unsigned long  getal,short l,short zerosuppress,short radix);
char *	cbx  (unsigned long  getal,short l,short zerosuppress);
char *	cbdu (unsigned short getal,short l,short zerosuppress);
char *	cbd  (         short getal,short l,short zerosuppress);
char *	cbdlu(unsigned long  getal,short l,short zerosuppress);
char *	cbdl (         long  getal,short l,short zerosuppress);
short 	cdbv(Cstr);
short 	cxbv(Cstr);
long	cldbv(Cstr);
long	crbv(Cstr s, short radix);

char *	Fload		(Cstr name, short *fh, long *l, short);
long	Fdump		(char *fn, short *rfl, long l, void *map);
char *	ttijd		(void),
	 *	gtijd		(void);
short 	exotic		(short hl, RECT *inside);
const char * pluralis(short);
void	pause		(short);
bool	isfile		(char *f);
char *	crlf		(char *f);

void decompress(uchar *s,	/* screen buffer, must be long enough	*/
			    uchar *f,	/* filebuffer cq picture				*/
			    long l,		/* lengte significante informatie		*/
			    long maxb,	/* output buffer size */
			    bool sta);	/* standard pixals or Atari interleaved planes */
long compress(uchar *f,		/* Puts screen into						*/
              uchar *s,		/* buffer								*/
			  long l,		/* screen size */
			  bool sta);	/* returns no of bytes in compressed format	*/

#define MTX 79
#define MTUP 0x8000

typedef struct
{
	short ty;
	bool state;		/* SELECTED */
	char text[MTX+1];
} BT;

size_t	rc_count		(OBJECT *tree);
BT *	rc_get			(OBJECT *tree, size_t *size);
void	rc_put			(OBJECT *tree, BT *t);
void	rc_free			(BT **t);
char *	rc_type			(short ty);

short 	rc_intersect	(RECT *r1, RECT *r2);
bool	intersects		(RECT i, RECT o);
RECT 	fit_inside		(RECT in, RECT out);
char *	xcpy			(char *d, char *s);
char *	xcat			(char *d, char *s);
VpIR	gsbox,gspbox;
VpIIIII	deftext,box,gbox,pbox,gpbox,line,deffill;
void	clips		(short,short,short,short,short,short);
void	gsclip		(short,short,GRECT r);
void	gline		(short, RECT);
short	alert_text	(char *t, ... );
char *	alert_secure(short max, char *s);
char *	strtra		(short max, char *d, char *s, char *f);
void	strrep		(short max, char *s, char *f);
char *	delimited_copy(short max, char *fro, char *to, uchar delim);
#endif
