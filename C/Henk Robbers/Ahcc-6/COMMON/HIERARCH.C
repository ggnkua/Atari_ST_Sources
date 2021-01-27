/* Copyright (c) 2006 - present by H. Robbers Amsterdam.
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

/* hierarch.c			path manipulation suite */

#define __MINT__

#include <prelude.h>
#include <string.h>
#include <stdio.h>
#include <ctype.h>
#include <ext.h>		/* for getcwd */

#include "mallocs.h"
#include "aaaa_lib.h"
#include "hierarch.h"
#include "ahcm.h"

global
short   drive;

global
S_path ipath, setfn, buffn;

#if CC_PATH
global
S_path CC_path;
#endif

global
S_path idir = {""},
       fsel = {"\0_______.___"};

global
char prg_name[24];

void send_msg(char *text, ...);

global
void possibleslash(char *s)
{
	char *l = s+strlen(s);
	if (*(l-1) ne '\\')
		*l++ = '\\', *l = 0;
}


/* secure handling of MAX_dir strings
   l is the true length of the string (so w/o the null character) */

global
void strmaxcpy(char *d, Cstr s, short l)
{
	while (l-- and *s) *d++ = *s++;
	*d = 0;
}

global
void DIRcpy(S_path *dst, Cstr src)
{
	size_t l = strlen(src);

	if (l > DIR_MAX)
		l = DIR_MAX;

	strmaxcpy(dst->s, src, l);
}

global
void DIRcat(S_path *dst, Cstr src)
{
	size_t m, l;
	char *d = dst->s;

	l = strlen(  d);
	m = strlen(src);

	if (m + l > DIR_MAX)
		m = l - DIR_MAX;

	d += l;
	strmaxcpy(d, src, m);
}

static
long  xfsc,xfst;

global
bool inq_xfs(Cstr p, char *dsep)	/* Returns true if Dreaddir can be used. */
{
	long c = 0, t = 0;

	if (dsep)
		*dsep = bslash, *(dsep+1) = 0;

	xfsc = 0;
	xfst = -1;
	c = Dpathconf(p, DP_CASE);
	xfsc = c;

	if (c eq -32)		/* Dpathconf not present: TOS (all upper case 8+3) */
		return false;
	elif (c eq -33)		/* path doesnt exist */
		return true;	/* leave case as is */
	elif (c eq -34)
		return true;	/* no directory: leave case as is */

	t = Dpathconf(p, DP_TRUNC);
	xfst = t;
	return (c >= 0 and !(c eq DP_NOSENSITIVE and t eq DP_DOSTRUNC));
}

static
bool hn_issep(Cstr s, char sep)
{
	return
	   ((    (sep eq bslash or sep eq fslash)
		 and (*s  eq bslash or *s  eq fslash)
		)
		 or *s eq sep
	   );
}

static
Cstr hn_strsep(Cstr s, char sep)
{
	while (*s)
		if (hn_issep(s, sep))
			return s;
		else
			s++;
	return nil;
}

static
bool hn_drive(Cstr s, char vsep)
{
	if (*(s + 1) eq vsep)
	{
		char c = *s;
		return
			   (c >= 'A' and c <= 'Z')
			or (c >= 'a' and c <= 'z')
			or (c >= '0' and c <= '6');
	}
	return false;
}

static
void icat(char *s, char c)
{
	short l = strlen(s);
	if (l + 1 < DIR_MAX)
	{
		*(s + l) = c;
		*(s + l + 1) = 0;
	}
}

static
bool dotdot(char *f)
{
	return     *f++ eq '.'
	       and *f++ eq '.'
	       and *f   eq 0;
}

static
HN_PART *hn_new_part(HI_NAME *hn, Cstr fro, char *to)
{
	short l = (Cstr )to-fro;
	/* Always allocate room for maximum sized extension */
	HN_PART *new = xcalloc(1, sizeof(*new) + l + hn->xmax + 1, AH_NEW_PART);
	if (new)
	{
		strncpy(new->n, fro, l);
		if (!hn->csens)
			strupr(new->n);
		if (dotdot(new->n))
		{
			new->dd = true;
			new->ext = new->n + l;		/* points \0 name */
		othw
			new->ext = strrchr(new->n, hn->esep);
			if (new->ext and strlen(new->ext) <= hn->xmax + 2)	/* two for the sep's */
				new->ext++;
			else
				new->ext = new->n + l;
		}
	}

	return new;
}

static
void ins_part(HN_PART *new, HN_PART **first, HN_PART **last)
{
	new->prior = *last;
	if (*first eq nil)
		*first = new;
	if (*last)
		(*last)->next = new;
	*last = new;
}

static
void remove_part(HI_NAME *hn, HN_PART *hp)
{
	if (hp->prior)
		hp->prior->next = hp->next;
	else
		hn->first = hp->next;
	if (hp->next)
		hp->next->prior = hp->prior;
	else
		hn->last = hp->prior;
	xfree(hp);
}

static
void separators(HI_NAME *hn, Cstr sep)
{
	if (sep)
	{
		hn->vsep  = *sep++;
		hn->sep   = *sep++;
		hn->esep  = *sep++;
		hn->sepe  = *sep++;
	othw
		hn->vsep  = ':';
		hn->sep   = '\\';
		hn->esep  = '.';
		hn->sepe  = 0;
	}
}

global
HI_NAME *hn_make(Cstr f, Cstr sep, short xmax)
{
	HI_NAME *new = xcalloc(1, sizeof(*new), AH_NEW_HN);
	if (new)
	{
		char *p;
		new->csens = inq_xfs(f, nil);
		separators(new, sep);
		new->xmax  = xmax;

		p = strchr(f, new->vsep);
		if (p)
		{
			if (is_alpha(*f) and p eq f+1)
				new->drive = tolower(*f) - 'a';
			else
				new->drive = -1;
			new->volume = hn_new_part(new, f, p);
			f = ++p;
		}

		if (hn_issep(f, new->sep))
			f++;
		while (((Cstr)p = hn_strsep(f, new->sep)) ne nil)
		{
			HN_PART *nh = hn_new_part(new, f, p);
			if (nh)
				ins_part(nh, &new->first, &new->last);

			f = ++p;
		}
		new->fn = hn_new_part(new, f, (char*)f + strlen(f));
	}

	return new;
}

global
void hn_show(HI_NAME *hn)
{
	if (hn eq nil)
		send_msg("nil hn\n");
	else
	{
		short lvl = 1;
		HN_PART *hp;
		send_msg("drive %d, csens %d, sep %c, vsep %c, esep %c\n",
				hn->drive, hn->csens, hn->sep, hn->vsep, hn->esep);
		if (hn->volume)
			send_msg("%d>volume '%s'\n", lvl++, hn->volume->n);
		hp = hn->first;
		while (hp)
		{
			send_msg("%d> %shp: '%s' ext: '%s'\n", lvl++,
						hp->dd ? "DD " : "", hp->n, hp->ext);
			hp = hp->next;
		}
		if (hn->fn)
			send_msg("%d>fn: '%s' ext: '%s'\n", lvl, hn->fn->n, hn->fn->ext);
	}
}

static
long count(HI_NAME *hn)
{
	if (hn)
	{
		HN_PART *hp;
		long l = 0;
		if (hn->volume)
			l += strlen(hn->volume->n) + 1;
		hp = hn->first;
		while (hp)
		{
			l += strlen(hp->n) + 1;
			hp = hp->next;
		}
		if (hn->fn)
			l += strlen(hn->fn->n) + 1;
		return l;
	}
	return -1;
}

static
void do_dd(HI_NAME *hn, HN_PART *hp)
{
	if (hp)
	{
		do_dd(hn, hp->next);
		if (hp->next)
			if (!hp->dd and hp->next->dd)
			{
				remove_part(hn, hp->next);
				remove_part(hn, hp);
			}
	}
}

global
char *hn_full(HI_NAME *hn, char *out, Cstr sep, bool dd)
{
	char *new;
	long l;

	if (sep)			/* else dont change */
		separators(hn, sep);

	if (dd)
		do_dd(hn, hn->first);

	l = count(hn);
	if (l > 0)
	{
		if (out)
			new = out;
		else
			new = xmalloc(l + 1, AH_HN_FULL);
		if (new)
		{
			HN_PART *hp;
			*new = 0;
			if (hn->volume)
			{
				strcat(new, hn->volume->n);
				icat  (new, hn->vsep);
				icat  (new, hn->sep);		/* 02'09: only if volume */
			}

			hp = hn->first;
			while (hp)
			{
				strcat(new, hp->n);
				icat  (new, hn->sep);
				hp = hp->next;
			}

			if (hn->fn)
				strcat(new, hn->fn->n);

			return new;
		}
	}

	return "";
}

global
char *hn_dir(HI_NAME *hn, char *out, Cstr sep, bool dd)
{
	HN_PART *fn = hn->fn;
	char *dir;
	hn->fn = nil;
	dir = hn_full(hn, out, sep, dd);
	hn->fn = fn;
	return dir;
}

global
void hn_dotdot(char *out, Cstr sep, short xmax)
{
	HI_NAME *hn = hn_make(out, sep, xmax);
	if (hn)
	{
		hn_full(hn, out, nil, true);
		hn_free(hn);
	}
}

global
HI_NAME *hn_copy(HI_NAME *hn)
{
	char s[1024];
	return hn_make(hn_full(hn, s, nil, false), &hn->vsep, hn->xmax);
}

global
bool hn_chext(HI_NAME *hn, char *newx)
{
	if (hn->fn and strlen(newx) <= hn->xmax)
	{
		if (*(hn->fn->ext - 1) ne hn->esep)
			*hn->fn->ext++ = hn->esep;
		strcpy(hn->fn->ext, newx);
		icat(hn->fn->ext, hn->sepe);
		if (!hn->csens)
			strupr(hn->fn->ext);
		return true;
	}
	return false;
}

global
void hn_free(HI_NAME *hn)
{
	if (hn)
	{
		HN_PART *hp;
		if (hn->volume)
			xfree(hn->volume);
		hp = hn->first;
		while (hp)
		{
			HN_PART *nx = hp->next;
			xfree(hp);
			hp = nx;
		}
		if (hn->fn)
			xfree(hn->fn);
		xfree(hn);
	}
}

global
bool hn_samedrive(HI_NAME *h1, HI_NAME *h2)
{
	if (!(h1->volume and h2->volume))
		return false;
	return SCMP(30,h1->volume->n, h2->volume->n) eq 0;
}

global
bool hn_samepath(HI_NAME *h1, HI_NAME *h2)
{
	HN_PART *p1, *p2;
	if (!hn_samedrive(h1, h2))
		return false;
	p1 = h1->first;
	p2 = h2->first;
	while (p1 and p2)
	{
		if (SCMP(31,p1->n, p2->n) ne 0)
			return false;
		p1 = p1->next;
		p2 = p2->next;
	}

	return p1 eq nil and p2 eq nil;
}

global
bool same_path(Cstr p1, Cstr p2)
{
	HI_NAME *h1, *h2;
	bool b = false;

	h1 = hn_make(p1, nil, 4);
	if (h1)
	{
		h2 = hn_make(p2, nil, 4);
		if (h2)
		{
			b = hn_samepath(h1, h2);
			hn_free(h2);
		}
		hn_free(h1);
	}
	return b;
}

global
S_path dir_plus_name(S_path *path, Cstr f)
{
	static S_path sel_pad;
	short i = 0;
	char *p = path->s;

	DIRcpy(&sel_pad, path->s);

	while (  p[i] ne '\0')
		i++;						/* zoek eind */

	if (i > DIR_MAX)
		i = DIR_MAX;

	while (  i > 0
		 and p[i-1] ne bslash
		 and p[i-1] ne fslash
	     and p[i-1] ne ':' )
		i--;						/* zoek beginpos voor filenaam */

	p[i]=0;		/* geef schoon selectiepad terug tbv ev Dsetpath */
	sel_pad.s[i] = 0;

	DIRcat(&sel_pad, f);
	return sel_pad;
}

global
Wstr strslash(Cstr s)
{
	while (*s)
		if (*s eq bslash or *s eq fslash)
			return (Wstr)s;
		else
			s++;
	return nil;
}

global
Wstr strrslash(Cstr f)
{
	Cstr s = f + strlen(f) - 1;
	while (s >= f)
		if (*s eq bslash or *s eq fslash)
			return (Wstr)s;
		else
			s--;
	return nil;
}

global
char *getsuf(char *f)
{
	char *p;

	if ((p = strrchr(f, '.')) != nil)
		if (strslash(p) == nil)
			return p+1;	/* gelijk return pointer */
	return nil;					/* geen  */
}

global
short findsuf(Cstr f, Cstr s)	/* s incl '.' */
{
	Wstr p;

	if ((p = strrchr(f, '.')) ne nil)
	{
		if (strslash(p) eq nil)
			if ( stricmp(p,s) )	/* er is een suffix */
				return 0;	/* ongelijk fout */
			else
				return tolower(*(p+1));	/* gelijk return eerste letter */
	}
	return ' ';					/* geen  */
}

global
char *getfn(char *fn)
{
	char *p;
		p = strrslash(fn);
	if (!p)
		p = strchr(fn, ':');
	if (!p)
		return fn;
	return p + 1;
}

global
S_path change_suffix(S_path *f, char *suf)		/* suf incl '.' */
{
	static S_path pn;
	char *pt;

	DIRcpy(&pn, f->s);

	if ((pt = strrchr(pn.s, '.')) != nil)
		if (strslash(pt) == nil)
			*pt = 0;

	DIRcat(&pn, suf);
	if (inq_xfs(pn.s, nil) eq 0)
		strupr(pn.s);
	return pn;
}

global
S_path DIR_suffix(MAX_dir p, char *suf)
{
	P_path pn;
	pn.s = p;
	return change_suffix(pn.t, suf);
}

global
S_path inspad(S_path *fn, char *p)
{
	HI_NAME *hn;
	static S_path mp;
	short l;
	char *f = fn->s, *q = p;

	if (*(f+1) eq ':')				/* drive nr: dus reeds een pad */
		 return *fn;
	if (*(p+1) eq ':') q += 2;		/* laat ev drivenr in pad even weg */
	if (strstr(f, q) eq f)			/* pad reeds aan begin van filenaam */
		return *fn;
	DIRcpy(&mp, p);					/* anders insert pad */
	l = strlen(mp.s)-1;
	if (    (mp.s[l] eq bslash or mp.s[l] eq fslash)
	    and (   f[0] eq bslash or    f[0] eq fslash)	/* vermijd twee slashes */
	   )
		mp.s[l] = 0;
	DIRcat(&mp, f);
	hn = hn_make(mp.s, ":\\.", 4);
	if (hn)
	{
		hn_full(hn, mp.s, nil, true);	/* true: with collapse of \..\ */
		hn_free(hn);
	}
	return mp;
}

global
char *delpad(char *f, char *p)
{
	char *q;
	char *watnu = "????";

	if (*p eq 0 ) return f;
	q = strstr(f, p);

	if ( q ne f) return f; 				/* p not at start of f */

	q = f+strlen(p);

	if (strslash(q) ne nil)
	{
		q -= 1;							/* als rest een slash bevat hou dan een slash aan het begin */
		if (*q ne bslash and *q ne fslash) return watnu;	/* iets niet goed intern */
	}
	return q;
}

global
char *delhelepad(char *f)
{
	char *s = f;
	while(*s++);
	do --s;
	while(*s ne bslash and *s ne fslash and *s ne ':' and s ne f);
	return s;
}

global
void convertslash(char *name, char *new)
{
	char slash, reslash[2];
	char *n = new;
	inq_xfs(name, reslash);
	slash = *reslash == fslash ? bslash : fslash;
	while (*name)
	{
		*n = *name == slash ? *reslash : *name;
		n++, name++;
	}
	*n = 0;
}

/*
 * shchsuf(f, suf, allocate) - change the suffix of file 'f' to 'suf'.
 *
 * Space for the new string is obtained using xmalloc().
 */

global
char *shchsuf(char *f, char *suf, short all, short key)		/* suf incl '.' */
{
	char *s, *p;
	size_t l = strlen(f)+strlen(suf);

	if (l > DIR_MAX)
		return f;

	s = all ? xmalloc(l + 1, key ) : f;
	strcpy(s, f);
	if ((p = strrchr(s, '.')) ne nil)
		if (strslash(p) eq nil)
		{
			strcpy(p, suf);		/* er is een suf */
			return s;
		}
	strcat(s, suf);
	return s;
}

global
void init_dir(short GEM, Cstr pr)
{
	drive=Dgetdrv();

#ifdef PRGNAME		/* in project file, for GEM programs only */
	if (GEM)
	{
		char *p;

		DIRcpy(&idir, pr);	/* 02'09 As we dont know the path, we cannot know the case */
		DIRcat(&idir, ".PRG");
		shel_find(idir.s);
		/* extra check on ':' needed for inconsistent behaviour of shel_find on different AES's (Aranym) */
		if (*idir.s eq 0 or *(idir.s+1) ne ':')		/* no path */
		{
			DIRcpy(&idir, pr);
			strlwr(idir.s);
			DIRcat(&idir, ".prg");
			shel_find(idir.s);
		}
		p=strrslash(idir.s);
		if (p)
			*(p+1)=0;
		else
			*idir.s=0;
	}
	else
#endif
	{
		getcwd(idir.s, DIR_MAX);
		if (*(idir.s + strlen(idir.s) - 1) ne '\\')
			DIRcat(&idir, "\\");
	}

	DIRcpy(&ipath, idir.s);		/* path only */
	DIRcat(&idir, "*.*");
#if BIP_CC && CC_PATH
		CC_path = ipath;
#endif
}

static
bool needslash(FB *fb)
{
	return *(fb->dir + strlen(fb->dir) - 1) ne *fb->slash;
}

global
long Aopendir(char *dir, FB *fb)
{
	fb->xfs = inq_xfs(dir, fb->slash);

	strcpy(fb->dir, dir);
	fb->next = false;
	fb->i = fb->xfs ? Dopendir(fb->dir,0) : 1;
	if ( (fb->i & 0xff000000L) eq 0xff000000L)
		return 0;
	return fb->i;
}

global
bool Areaddir(FB *fb)
{
	long i;
	char nm[WM];
	fb->deep = false;
	if (fb->xfs)
	{
		i = Dreaddir(WM,fb->i,nm);
		if (i eq 0)
		{
			strcpy(fb->fb.ff_name, nm+4);
			strcpy(fb->fn, fb->dir);
			if (needslash(fb))
				strcat(fb->fn, fb->slash);
			strcat(fb->fn, fb->fb.ff_name);
			fb->deep =  (Fattrib(fb->fn,0,0)&FA_DIREC) ne 0;
		}
	othw
		if (!fb->next)
		{
			strcpy(nm, fb->dir);
			if (needslash(fb))
				strcat(nm, fb->slash);
			strcat(nm, "*.*");
			i = findfirst(nm, &fb->fb, FA_DIREC);	/* for ALL directories */
			fb->next = true;
		}
		else
			i = findnext(&fb->fb);

		if (i eq 0)
		{
			fb->deep = (fb->fb.ff_attrib&FA_DIREC) ne 0;
			strcpy(fb->fn,fb->dir);
			if (needslash(fb))
				strcat(fb->fn,fb->slash);
			strcat(fb->fn,fb->fb.ff_name);
		}
	}

	return i eq 0;
}

global
void Aclosedir(FB *fb)
{
	if (fb->xfs)
		Dclosedir(fb->i);
}

