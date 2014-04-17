/* textwind.c	text window handler
 *=======================================================================
 * 920601 kbad
 */

#include <stdlib.h>
#include <string.h>
#include <osbind.h>

#include "gemutil.h"
#include "textwind.h"

#undef MLOCAL
#define MLOCAL /**/

#define MIN_WH	7 /* minimum w & h of a window in char boxes */


/* Functions
 *=======================================================================
 */
/* Text window functions */
WORD	tw_new __PROTO((int kind, int wsid, int font, int pts,
						char *buf, long bufsize, int tabsize));
void	tw_free __PROTO((WIND w));

/* Text window support functions */
MLOCAL void	build_lines(char *buf, long bufsize, char **lines);
MLOCAL void count_lines(char *buf, long bufsize, int tabsize,
						WORD *pw, WORD *ph);
MLOCAL WORD dir_align(int val, int align, int prefer_inc,
						int baseval, int minval, int maxval);
MLOCAL void	tw_draw(WIND w, GRECT *rclip);
MLOCAL void	tw_drawcalc(WIND w);
MLOCAL WORD	tw_sizecalc(WIND w, const GRECT *rnew);

void tw_db(void) {}

/* Text window functions
 *=======================================================================
 */


/*-----------------------------------------------------------------------
 * Allocate & fill in a textwind struct for a text window.
 * Return the window's AES window id.
 * NOTE: if the file doesn't end in a newline, bufsize must be 1 bigger
 *		 than the actual file size so that the last line can be terminated.
 */
GLOBAL WORD
tw_new(kind, wsid, font, pts, buf, bufsize, tabsize)
	char	*buf;
	long	bufsize;
{
	TEXTWIND tw;
	WORD	i, vw, vh, wc, hc;
	char	**lines;

	/*
	 * Get file size for virtual window coordinates,
	 * allocate line starts array, and create window.
	 */
	count_lines(buf, bufsize, tabsize, &vw, &vh);
	if ( !(lines = calloc(1, (vh + 1) * sizeof(char *))) )
		return -33;

	vst_font(wsid, font);
	vst_point(wsid, pts, &i, &i, &wc, &hc);
	i = w_new(kind, NULL, wsid, wc, hc, vw, vh,
			  tw_sizecalc, sizeof(struct textwind));
	if (i < 0)
	{
		free(lines);
		return i;
	}

	/* Fill in data structure */
	tw = (TEXTWIND)w_lookup(i);
	tw->w.draw = tw_draw;
	tw->w.free = tw_free;
	tw->lines = lines;
	tw->tabsize = tabsize;
	tw->font = font;
	tw->pts = pts;
	build_lines(buf, bufsize, lines);

	return tw->w.id;
}

/*-----------------------------------------------------------------------
 * Delete a text window, unlink it from the window list, and free it.
 */
GLOBAL void
tw_free(WIND w)
{
	TEXTWIND tw = (TEXTWIND)w;

	free(tw->lines[0]); /* free text buffer. should this happen here? */
	free(tw->lines);
	w_free(w);
}


/* Text window support functions
 *=======================================================================
 */

/*-----------------------------------------------------------------------
 * Build line starts array.
 */
MLOCAL void
build_lines(REG char *buf, long bufsize, REG char **lines)
{
REG	WORD	c, nl;
REG	char	*bufend = buf + bufsize;

	while (buf < bufend)
	{
		*lines++ = buf;
		for (nl = 0; !nl && buf < bufend; )
		{
			c = *buf++;
			if ( ((nl = (c == '\r')) && *buf == '\n')
			||	 ((nl = (c == '\n')) && *buf == '\r') )
				buf++;
		}
	}
}

/*-----------------------------------------------------------------------
 * Count the # of lines in a text buffer.
 * Return width of widest line in *pw and # of lines in *ph.
 * Used by tw_new().
 */
MLOCAL void
count_lines(REG char *buf, long bufsize, int tabsize, WORD *pw, WORD *ph)
{
REG WORD	len, maxlen, nlines;
	char	*bufend = buf + bufsize;

	len = maxlen = nlines = 0;
	while (buf < bufend)
		switch (*buf++)
		{
			case '\t':
				len = min(TW_MAXLEN, len + tabsize - (len % tabsize));
			break;
			case '\r':
				if (*buf == '\n') buf++;
				goto nl;
			case '\n':
				if (*buf == '\r') buf++;
nl:				nlines++;
				maxlen = max(len, maxlen);
				len = 0;
			break;
			default:
				if (len < TW_MAXLEN) len++;
			}

	if (len)
	{
	/* EOF w/o newline.
	 * Zap the character immediately after the file image.
	 */
		*buf = 0;
		++nlines;
		maxlen = max(len, maxlen);
	}

	*pw = min(TW_MAXLEN, maxlen+1);
	*ph = nlines;
}

/*-----------------------------------------------------------------------
 * Directionally align a value.
 * Used by tw_sizecalc() to byte-align window draw area.
 */
MLOCAL WORD
dir_align(int val, int align, int prefer_inc,
		  int baseval, int minval, int maxval)
{
	WORD	inc, dec;

	dec = -(val % align);
	if (dec)
	{
		inc = dec + align;
		if (prefer_inc)
			return (inc <= align/2 && baseval + inc <= maxval) ? inc : dec;
		else
			return (dec >= -align/2 && baseval + dec >= minval) ? dec : inc;
	}
	return 0;
}

/*-----------------------------------------------------------------------
 * Compute window's rwork & rdraw given window's rwind.
 */
MLOCAL void
tw_drawcalc(WIND w)
{
	wind_calc(WC_WORK, w->kind,
			  w->rwind.g_x, w->rwind.g_y, w->rwind.g_w, w->rwind.g_h,
			  &w->rwork.g_x, &w->rwork.g_y, &w->rwork.g_w, &w->rwork.g_h);
	w->rdraw.g_x = w->rwork.g_x + w->wchar/2;
	w->rdraw.g_y = w->rwork.g_y;
	w->rdraw.g_w = w->rwork.g_w - w->wchar/2;
	w->rdraw.g_h = w->rwork.g_h;
}

/*-----------------------------------------------------------------------
 * Compute new window & work rects for a change in window size or position.
 * Return TRUE if the window rect changed.
 */
MLOCAL WORD
tw_sizecalc(WIND w, const GRECT *rnew)
{
	WORD	off;
	GRECT	rcurr;
	GRECT	*rdraw = &w->rdraw;
	GRECT	*rwind = &w->rwind;

/* Get the draw area of the window (may be subset of work area) */
	rcurr = *rwind;
	rwind->g_x = rnew->g_x;
	rwind->g_y = rnew->g_y;
	rwind->g_w = max(MIN_WH * w_wbox, rnew->g_w);
	rwind->g_h = max(MIN_WH * w_hbox, rnew->g_h);
	tw_drawcalc(w);

/* Adjust the window position so that the draw area is byte-aligned */
	rwind->g_x += dir_align(rdraw->g_x, 8, (rcurr.g_x < rwind->g_x),
							rwind->g_x, w_rmax.g_x,
							w_rmax.g_x + w_rmax.g_w - 1);
	rwind->g_y += dir_align(rdraw->g_y, 8, (rcurr.g_y < rwind->g_y),
							rwind->g_y, w_rmax.g_y,
							w_rmax.g_y + w_rmax.g_h - 1);

/* Align window size & limit it based on window contents */
	off = dir_align(rdraw->g_w, w->wchar, (rcurr.g_w < rwind->g_w), 
					rwind->g_w, MIN_WH * w_wbox,
					w_rmax.g_w + w_wbox/2 + 1);
	rwind->g_w += off;
	off = (rdraw->g_w + off) / w->wchar - w->vw;
	if (off > 0)
		rwind->g_w = max(rwind->g_w - w->wchar*off, MIN_WH * w_wbox);

	off = dir_align(rdraw->g_h, w->hchar, (rcurr.g_h < rwind->g_h),
					rwind->g_h, MIN_WH * w_hbox,
					w_rmax.g_h + w_hbox/2 + 1);
	rwind->g_h += off;
	off = (rdraw->g_h + off) / w->hchar - w->vh;
	if (off > 0)
		rwind->g_h = max(rwind->g_h - w->hchar*off, MIN_WH * w_hbox);

/* Recalculate the work & draw rects */
	tw_drawcalc(w);
	return !rc_equal(rwind, &rcurr);
}

/*-----------------------------------------------------------------------
 * Redraw part of a text window.
 */
MLOCAL void
tw_draw(WIND w, GRECT *rclip)
{
	WORD	x0, wc, hc, loff, choff, chmax, chpos;
	GRECT	rch, r;
	char	c, *lp;
	WORD	*bp;
	WORD	*xy = ptsin;
	TEXTWIND tw = (TEXTWIND)w;

	w_erase(w, rclip);

/* Set text parameters */
	vswr_mode(w->wsid, MD_TRANS);
	vst_alignment(w->wsid, 0, 5, &x0, &x0); /* left, top */
	vst_font(w->wsid, tw->font);
	vst_point(w->wsid, tw->pts, &x0, &x0, &wc, &hc);

/*
 * Calculate drawing parameters.
 * If drawing the full window, don't clip text.
 * Unclipped text draws are *MUCH* faster.
 */
	r = *rclip;
	rc_intersect(&w->rdraw, &r);
	vs_clip(w->wsid, !rc_equal(&w->rdraw, &r), rc_getpts(&r, xy));

	rc_chrect(&r, w->rdraw.g_x, w->rdraw.g_y, w->wchar, w->hchar, &rch);
	x0 = w->rdraw.g_x + rch.g_x * w->wchar;
	xy[1] = w->rdraw.g_y + rch.g_y * w->hchar + (w->hchar - hc) / 2;
	loff = w->vy + rch.g_y;
	choff = w->vx + rch.g_x;
	chmax = choff + rch.g_w;


	/*
	 * For each line, skip to the character offset of the clip rect,
	 * then build an output line, expanding tabs to spaces.
	 */
	while (loff < w->vh && rch.g_h--)
	{
		lp = tw->lines[loff++];
		if (!lp) /* end of lines array may occur before end of window */
			break;

		/* Skip to char offset, expanding tabs */
		for (chpos = 0; chpos < choff && chpos < chmax; )
		{
			switch (c = *lp++)
			{
				case '\r':	case '\n':	case '\0':
					chpos = chmax;
				break;
				case '\t':
					chpos += tw->tabsize - chpos % tw->tabsize;
				break;
				default:
					chpos++;
			}
		}

		/* Draw what's left: skip tabs, stuff chars to intin, splat text */
		while (chpos < chmax)
		{
			xy[0] = x0 + (chpos - choff) * w->wchar;
			bp = intin;
			c = 1;
			while (c && chpos < chmax)
				switch (c = (*lp++) & 0x00ff)
				{
					case '\r':	case '\n':	case '\0':
						chpos = chmax;
					break;
					case '\t':
						c = '\0';
						chpos += tw->tabsize - (chpos % tw->tabsize);
					break;
					default:
						chpos++;
						*bp++ = c;
				}

			if( bp > intin )
			{
			    *bp = 0;
			    v_wtext( w->wsid, (int)(bp - intin));
			}
		}
		xy[1] += w->hchar;
	}
}
