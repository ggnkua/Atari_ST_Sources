/* gemutil.c	miscellaneous GEM utility routines
 *=======================================================================
 * 920601 kbad from various sources
 */

#include <stdlib.h>
#include <string.h>
#include <portab.h>
#include <aes.h>

#ifdef LATTICE
# include <tos.h>
#else
# define FNSIZE 13	/* maximum file node size */
# define FMSIZE 128	/* maximum file name size */
long	Supexec(long (*)(void));
int 	Dgetdrv(void);
int 	Dgetpath(int, char *);
GLOBAL WORD 	_tos; /* built in to LC5 */
#endif

#include "gemutil.h"

/* Library functions not in all compilers
 *=======================================================================
 */
#ifdef NEED_MINMAX
int min(a,b) { return (a < b) ? a : b; }
int max(a,b) { return (a > b) ? a : b; }
#endif


/* Blit functions
 *=======================================================================
 */

MLOCAL WORD bb_xy[8];

/*-----------------------------------------------------------------------
 * Scroll a rectangle within itself by dx, dy.
 * Return rectangles to redraw in r1, r2.
 * If dx or dy is 0, r2 may be NULL.
 */
void
bb_scroll(wsid, r, dx, dy, r1, r2)
	int		wsid;
const GRECT *r;
	int		dx, dy;
	GRECT	*r1, *r2;
{
static MFDB	fd_screen;
	GRECT	rbb;
	WORD	*xy = bb_xy;

/* Validate args */
	if (rc_dirty(r, dx, dy, r1, r2))
	{
	/* Get points & do blit */
		rbb.g_x = r->g_x + dx;
		rbb.g_y = r->g_y + dy;
		rbb.g_w = r->g_w;
		rbb.g_h = r->g_h;
		rc_intersect(r, &rbb);
		rc_getpts(&rbb, &xy[4]);

		rbb.g_x -= dx;
		rbb.g_y -= dy;
		rc_getpts(&rbb, xy);

		vro_cpyfm(wsid, S_ONLY, xy, &fd_screen, &fd_screen);
	}
}


/* File selector
 *=======================================================================
 */
GLOBAL BYTE 	bootdev = -1;

/*-----------------------------------------------------------------------
 * Return a drive letter's logical drive #.
 */
MLOCAL int
pn_driveno(int ch)
{
	if (ch >= 'A' && ch <= 'Z') return ch - '@';
	if (ch >= 'a' && ch <= 'z') return ch - '`';
	return 0;
}

/*-----------------------------------------------------------------------
 * Convert a relative pathname to a fully qualified one.
 * Return a pointer to the output string, or NULL on error.
 *
 * NOTES:
 * - Input and output pointers may point to the same string.
 * - No trailing backslashes are returned, so the path returned
 *   is always valid for Fsfirst() (unless it's the root directory).
 */
char *
pn_full(const char *path, char *fullpath)
{
	int		drive;
	char	*s, pathspec[FMSIZE];

/* Validate arguments */
	if (fullpath == NULL || (path != NULL && strlen(path) >= FMSIZE))
		return NULL;

	strcpy(pathspec, (path) ? path : "");

	if (pathspec[0] && pathspec[1] == ':')
	{
		if (pathspec[2] == '\\')
		{
		/* X:\<blah> is already set up, so just copy it */
			strcpy(fullpath, pathspec);
		}
		else
		{
		/* X:<blah>, get default directory on specified drive. */
			drive = pn_driveno(fullpath[0] = pathspec[0]);
			fullpath[1] = pathspec[1];
			if (Dgetpath(&fullpath[2], drive))
				return NULL;
			strcat(strcat(fullpath,"\\"), &pathspec[2] );
		}
	}

	else if (pathspec[0] == '\\')
	{
	/* \<blah>, filespec is relative to root of current drive. */
		drive = (int)Dgetdrv();
		if (drive < 0)
			return NULL;
		fullpath[0] = (char)(drive + 'A');
		fullpath[1] = ':';
		strcpy(&fullpath[2], pathspec);
	}

	else
	{
	/* filespec is relative to current directory. */
		drive = (int)Dgetdrv();
		if (drive < 0)
			return NULL;
		fullpath[0] = (char)(drive + 'A');
		fullpath[1] = ':';
		if (Dgetpath(&fullpath[2], 0))
			return NULL;
		strcat(strcat(fullpath,"\\"), pathspec);
	}

/* Nuke parent (..) and current directory (.) pieces. */
	s = fullpath;
	while (s = strchr(s, '\\'))
	{
		register char *p = s+1;
		if (*p++ == '.')
		{
			char *ps = NULL;

			if (*p == '\\' || *p == '\0')
			/* Current directory */
				ps = s;

			else if (*p++ == '.' && (*p == '\\' || *p == '\0'))
			{
			/* Parent directory.
			 * Don't gag on parent directory entries anchored at the root,
			 * even though they are thoroughly bogus.
			 */
				*s = '\0';
				ps = strrchr(fullpath, '\\');
				if (!ps) ps = s;
				else s = ps;
			}
			if (ps) --s, memmove(ps, p, strlen(p)+1);
		}
		++s;
	}

/* Whack off any trailing backslash */
	if (fullpath[strlen(fullpath)-1] == '\\')
		fullpath[strlen(fullpath)-1] = '\0';

	return fullpath;
}


/*-----------------------------------------------------------------------
 * Initialize fsel_name() globals.
 */
MLOCAL long
fsel_init(void)
{
#ifndef LATTICE
	_tos = *(unsigned int *)(*(long *)(0x4f2) + 2);
#endif
	bootdev = (signed char)(*(unsigned int *)0x446) + 'A';
	return 0;
}

/*-----------------------------------------------------------------------
 * fsel_name(): Get a file name using the file selector.
 * `label' and `filemask' may be NULL; name must address 128 bytes.
 *
 * The path used in the file selector is taken from `name'.
 * If name[0] == '\0', the current directory is used.
 *
 * If name contains a file name, it appears as the initial file name
 * in the file selector.
 *
 * If filemask == NULL, fsel_name() will create a search mask using
 * the extender of the file name if possible.
 *
 * Returns:
 * < 0	AES error code (return string is empty).
 *	0	Cancel selected (return string is empty), or
 *		OK selected with no file name (return string contains a path
 *		with a trailing backslash, possibly containing relative components).
 *	1	OK selected with a file name (return string contains the fully
 *		qualified file name).
 */
WORD
fsel_name(const char *label, const char *filemask, char *name)
{
	char	path[FMSIZE], file[FNSIZE], mask[FNSIZE+1];
	char	*pathp, *namep;
	WORD	button, ret;

	if (bootdev == -1)
		Supexec(fsel_init);

/*
 * Split input pathname between path & file name,
 * then fill in path & file names.
 */
	pathp = name;
	namep = strrchr(name, '\\');
	if (namep)
		*namep++ = '\0';
	else
		namep = pathp, pathp = NULL;

	if (pathp)
		strcpy(path, pathp);
	else
		path[0] = '\0';

	if (!pn_full(path, path))
	/* Couldn't get fully qualified path name; just use cwd */
		strcpy(path, ".");

	strcpy(file, namep);

/*
 * Append the search mask for fsel_input().
 * If a file is passed in, use its extender, otherwise use ".*"
 */
	pathp = mask;
	*pathp++ = '\\';
	if (filemask)
	{
		strcpy(pathp, filemask);
	}
	else
	{
		*pathp++ = '*';
		namep = strchr(file, '.');
		strcpy(pathp, (namep) ? namep : ".*");
	}
	strcat(path, mask);

/*
 * Finally... make the fsel_input call.  The TOS version check
 * is not needed for Lattice, because their binding for
 * fsel_exinput works on all TOS versions.
 */
#ifdef LATTICE
	if (label == NULL)
#else
	if (label == NULL || _tos < 0x0104)
#endif
		ret = fsel_input(path, file, &button);
	else
		ret = fsel_exinput(path, file, &button, label);

	if (ret <= 0 || (ret = button) == 0)
	{
		name[0] = 0;
	}
	else
	{
	/*
	 * Copy the path\filename into the output string,
	 * auto-append the filemask extender if appropriate,
	 * and qualify the file name.
	 */
		pathp = strrchr(path, '\\'); /* "can't fail" */
		namep = name + (pathp - path);
		*pathp++ = 0;
		strcpy(name, path);
		*namep++ = '\\';
		strcpy(namep, file);

		if (file[0])
		{
		/* If mask didn't change, and filename has no extender,
		 * and mask has an extender, and it isn't wildcarded,
		 * add the mask extender to the filename.
		 */
			if (strcmp(pathp, &mask[1]) == 0
			&&	(namep = strchr(namep, '.')) == NULL
			&&	(pathp = strchr(pathp, '.')) != NULL
			&&	strpbrk(pathp, "*?") == NULL)
				strcat(name, pathp);

			if (pn_full(name, path))
				strcpy(name, path);
		}
		else
		{
		/* no file, return CANCEL (so path can be returned) */
			ret = 0;
		}
	}
	return ret;
}


/* Rectangle functions
 *======================================================================
 */

/*-----------------------------------------------------------------------
 * Convert a GRECT to a 5 point box line:
 *
 * [4,5]---[6,7]	Oriented this way so that the result can be
 *   |       |		used by gr_3dbox for polymarker points.
 *   |       |		NOTE: subtract 1 from xy[9] to use the array
 * [2,3]---[0,1]9		  for an XOR line.
 *          8
 * If xy is NULL, put 'em in ptsin.
 * Return a pointer to the xy array.
 */
WORD *
rc_boxpts(const GRECT *r, WORD *xy)
{
	if (!xy) xy = ptsin;
	if (r)
	{
		xy[2] = xy[4] = r->g_x;
		xy[5] = xy[7] = r->g_y;

		xy[0] = xy[6] = xy[8] = r->g_x + max(0, r->g_w - 1);
		xy[1] = xy[3] = xy[9] = r->g_y + max(0, r->g_h - 1);
	}
	return xy;
}

/*-----------------------------------------------------------------------
 * Convert a pixel-coordinate rect (r) to character coordinates (chrect).
 * x0, y0 is the upper left corner of the window containing r,
 * wch and hch are the width and height of a "character".
 */
void
rc_chrect(r, x0, y0, wch, hch, chrect)
const GRECT *r;
	int		x0, y0, wch, hch;
	GRECT	*chrect;
{
	WORD	off;

/*
 * Character align x, add fractional x offset to width,
 * compute character-aligned width, then do the same for y & h.
 */
	off = max(0, r->g_x - x0);
	chrect->g_x = off / wch;
	off = off % wch + r->g_w;
	chrect->g_w = off / wch + (off % wch != 0);

	off = max(0, r->g_y - y0);
	chrect->g_y = off / hch;
	off = off % hch + r->g_h;
	chrect->g_h = off / hch + (off % hch != 0);
}

/*-----------------------------------------------------------------------
 * Find the dirty rectangles which result when scrolling r by dx, dy.
 * If dx or dy is 0, r2 may be NULL.
 * If the move is a no-op or a complete redraw, return FALSE,
 * otherwise return TRUE.
 */
BOOLEAN
rc_dirty(r, dx, dy, r1, r2)
const GRECT	*r;
	int		dx, dy;
	GRECT	*r1, *r2;
{
	WORD	xoff, yoff;
	GRECT	*rp;

/* Validate arguments */
	if (!dx && !dy)
	{
	/* no-op */
		r1->g_w = r1->g_h = 0;
		if (r2) r2->g_w = r2->g_h = 0;
		return FALSE;
	}

	xoff = abs(dx);
	yoff = abs(dy);
	if (xoff >= r->g_w || yoff >= r->g_h)
	{
	/* full redraw */
		*r1 = *r;
		if (r2) r2->g_w = r2->g_h = 0;
		return FALSE;
	}

/* Compute dirty rectangles */
	rp = r1;
	if (dy)
	{
	/* Set horizontal rectangle to top (dy > 0) or bottom (dy < 0).
	 * Make it as wide as the box.
	 */
		rp->g_y = (dy > 0) ? r->g_y : r->g_y + r->g_h - yoff;
		rp->g_h = yoff;

		rp->g_x = r->g_x;
		rp->g_w = r->g_w;
	}

	if (dx)
	{
	/* Set vertical rectangle to left (dx > 0) or right (dx < 0).
	 * Prevent overlap with horizontal rectangle.
	 */
		if (dy) /* r1 used */
			rp = r2;

		if (rp)
		{
			rp->g_x = (dx > 0) ? r->g_x : r->g_x + r->g_w - xoff;
			rp->g_w = xoff;

			rp->g_y = (dy > 0) ? r->g_y + yoff : r->g_y;
			rp->g_h = r->g_h;
			if (dy) rp->g_h -= yoff;
		}
	}

	if (r2 && rp == r1) /* r2 unused */
		r2->g_w = r2->g_h = 0;

	return TRUE;
}

#ifdef NEED_RC_INTERSECT
BOOLEAN
rc_intersect(rs, rd)
const GRECT *rs;
	GRECT	*rd;
{
	GRECT	r;

	r.g_x = max(rd->g_x, rs->g_x);
	r.g_y = max(rd->g_y, rs->g_y);
	r.g_w = min(rd->g_x + rd->g_w, rs->g_x + rs->g_w) - r.g_x;
	if (r.g_w > 0)
	{
		r.g_h = min(rd->g_y + rd->g_h, rs->g_y + rs->g_h) - r.g_y;
		if (r.g_h > 0)
		{
			*rd = r;
			return TRUE;
		}
	}
	return FALSE;
}
#endif

/*-----------------------------------------------------------------------
 * Convert a GRECT to a 2 point xy array.
 * if `xy' is NULL, put the points in the VDI ptsin array.
 * Return a pointer to the xy array.
 */
WORD *
rc_getpts(r, xy)
const GRECT *r;
	WORD	*xy;
{
	if (!xy) xy = ptsin;
	if (r)
	{
		xy[2] = (xy[0] = r->g_x) + max(0, r->g_w - 1);
		xy[3] = (xy[1] = r->g_y) + max(0, r->g_h - 1);
	}
	return xy;
}

/*-----------------------------------------------------------------------
 * Set a GRECT from a 2 point xy array.
 * If the GRECT pointer is NULL, use a statically allocated GRECT.
 * Return a pointer to the GRECT.
 */
GRECT *
rc_setpts(xy, r)
const WORD	*xy;
	GRECT	*r;
{
static GRECT rtmp, r0;

	if (!r) r = &rtmp;
	if (xy)
	{
		if (xy[2] > xy[0])
			r->g_w = xy[2] - (r->g_x = xy[0]) + 1;
		else
			r->g_w = xy[0] - (r->g_x = xy[2]) + 1;
		if (xy[3] > xy[1])
			r->g_h = xy[3] - (r->g_y = xy[1]) + 1;
		else
			r->g_h = xy[1] - (r->g_y = xy[3]) + 1;
	}
	else *r = r0;

	return r;
}


/* Slider functions
 *=======================================================================
 */

/*-----------------------------------------------------------------------
 * Auto-accelerating time delay based on double click time.
 * Pass 0 to get initial time delay value,
 * Pass last time delay value to return next shorter time delay.
 */
WORD
sl_delay(delay)
WORD	delay;
{
static WORD dclick_rates[5] = { 450, 330, 275, 220, 165 };
static WORD mindelay, quickening;

	if (!delay)
	{
		delay = dclick_rates[evnt_dclick(0,0)];
		mindelay = delay / 4;
		quickening = (delay - mindelay) / 8;
	}
	else if (delay > mindelay)
		delay -= quickening;

	return delay;
}


/* VDI functions
 *=======================================================================
 */

/*-----------------------------------------------------------------------
 * Call v_gtext with coordinate arrays & intin already filled in.
 */
void
v_wtext(wsid, textlen)
{
	*(long *)contrl = 0x80001L;
	contrl[3] = textlen;
	contrl[6] = wsid;
	vdi(vpb);
}

/*-----------------------------------------------------------------------
 * Lattice v_gtext bug (ugh)
 */
void
v_gtext(wsid, x, y, s)
const char *s;
{
	WORD	*ip = intin;
	ptsin[0] = x;
	ptsin[1] = y;
	while (*ip++ = *s++)
	;
	v_wtext(wsid, (int)(ip - intin) - 1);
}


/* Window functions
 *=======================================================================
 */

/*-----------------------------------------------------------------------
 * Set a window slider's size or position.
 * If range < visrange, set *pval to 0,
 * If *pval > maximum value (range - visrange), set it to maximum.
 */
void
wind_slider(id, set, range, visrange, pval)
	WORD	*pval;
{
	WORD	slider, maxval;

	if (set == WF_VSLSIZE || set == WF_HSLSIZE)
	{
		slider = 1000;
		if (range && range > visrange)
			slider = umul_div(1000, visrange, range);
		wind_set(id, set, slider);
	}
	else if (set == WF_VSLIDE || set == WF_HSLIDE)
	{
		maxval = (WORD)(range - visrange);
		if (maxval <= 0)
			slider = *pval = 0;
		else if (*pval > maxval)
			slider = 1000, *pval = maxval;
		else
			slider = umul_div(1000, *pval, maxval);
		wind_set(id, set, slider);
	}
}
