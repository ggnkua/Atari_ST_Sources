/* <<<< Start of (converted) code of ST nr 19 dd may/june 1989 */

#define DBGC 0

#define n_scan 1

static void pr(char *in, STMNR l, STMC *s)
{
	send_msg("%sL%ld:<<%s>>\n", in, l, s->xtx);
}

static void select_2(IT *w1, IT *w2, STMC *s1, STMC *s2)
{
	STMNR l1, l2;

	l1 = s1 ? s1->xn : w1->view.sz.h;
	l2 = s2 ? s2->xn : w2->view.sz.h;
	select_line(w1,l1-1);
	select_line(w2,l2-1);
}

static void next_2(IT *wl, IT *wr, STMC **pls, STMC **prs, STMNR *pli, STMNR *pri)
{
	STMC *ls, *rs;
	ls = stmfinext(wl->base);
	rs = stmfinext(wr->base);
	*pli = ls->xn;
	*pri = rs->xn;
	*pls = ls;
	*prs = rs;
}

short tel;

global
short line_compare(char *s, STMC *s1, STMC *s2, bool vs)
{
	short ceq = 0;	/* 2 empty lines are equal */

	if (s1 and s2)
	{
		if (vs)
		{
			short l1, l2;
			char t1[MAXL+1], t2[MAXL+1];
			l1 = handle_space(t1, s1->xtx);
			l2 = handle_space(t2, s2->xtx);
			
			if (l1 ne l2)
				ceq = 2;
			if (l1)
				ceq =  strcmp(t1, t2);
#if DBGC
			alert_text("%s %ld %s %ld | '%s' | '%s'", s, s1->xn, ceq ? "!=" : "==", s2->xn, t1, t2);
#endif
		othw
			if (s1->xl ne s2->xl)
				ceq = 2;
			if (s1->xl)
				ceq = strncmp(s1->xtx,s2->xtx,s1->xl);
		}
	}

	return ceq;
}

void show_lines(char *s, IT *w1, IT *w2)
{
	STMC *s1 = stmficur(w1->base);
	STMC *s2 = stmficur(w2->base);

	if (s1 and s2)
	 	console("-= %s =- L1:%ld L2:%ld\n", s, s1->xn, s2->xn);
}
static void disp_diff(IT *wl, IT *wr, STMNR li, STMNR lj, STMNR ri, STMNR rj)
{
	STMNR i;
	if (lj >= li)
	{
		i = li;
		while (i <= lj)
		{
			STMC *s = find_line(wl, i-1);
			pr("-", s->xn, s);
			i++;
		}
	}

	if (rj >= ri)
	{
		i = ri;
		while (i <= rj)
		{
			STMC *s = find_line(wr, i-1);
			pr("+", s->xn, s);
			i++;
		}		
	}

	send_msg("\n");
}

/* Taken from Dutch ST magazine issue 19 dd may 1989. */
/* Originally li,lm,ri,rm were indices in a array, so they were [0..n-1], now they are [1..n] */
static bool line_eq(IT *wl, IT *wr, STMNR li, STMNR ri, bool zpm)
{
	STMC *ls = find_line(wl, li-1);
	STMC *rs = find_line(wr, ri-1);
	
	if (ls and rs)
		return line_compare("line_eq:", ls, rs, zpm) eq 0;

	return false;
}

static void still_diff(IT* wl, IT *wr, STMNR li, STMNR lm, STMNR ri, STMNR rm, short n, bool min1, STMNR *lj, STMNR *rj, bool zpm)
{
	STMNR ljmin, ljmax, rjmin, rjmax;
	short i;
	bool leob, reob, match;

	*lj = li;				/* lopende tellers */
	*rj = ri + 1;			/* NB 1 hoger,  */

	ljmin = li;
	rjmin = ri;
	ljmax = li + 1;
	rjmax = ri + 1;
	match = false;
	leob = false;
	reob = false;

	while (*lj <= lm and *rj <= rm)
	{
		match = line_eq(wl, wr, *lj, *rj, zpm);		/* Match%=L$(Li%)=R$(Li%) */
		i = 1;

		while (match and i < n)
		{
			STMNR lx = *lj + i, rx = *rj + i;
			if (lx > lm or rx > rm) break;				/* Exit If (Lj%+I%) > Lm% Exit If (Rj%+I%) > Rm% */
			match = line_eq(wl, wr, lx, rx, zpm);
			i++;
		}	

		if (match)
			break;

		if (*lj < ljmax or *rj < rjmax)
		{
			if (*lj < ljmax)
			{
				*lj += 1;
				if (*lj eq ljmax)
					*rj = rjmin;
			}
			else
				*rj += 1;
		othw			/* lj = ljmax and rj = rjmax */
			ljmax++;
			if (ljmax > lm)
			{
				leob = true;
				ljmax = lm;
				rjmin = *rj + 1;
			}
			rjmax++;
			if (rjmax > rm)
			{
				reob = true;
				rjmax = rm;
				ljmin = *lj + 1;
				
			}

			*rj += 1;
			if (*rj > rm)
				*rj = rjmin;
			
			*lj = ljmin;
		}
		if (leob and reob)
			break;
	}

	if (min1)
	{
		*rj -= 1;		/* geef de nummers van de laatste verschil regels */
		*lj -= 1;
	}
}

static
void scolor(IT *wl, IT *wr, short c)
{
	wl->color = c;
	wr->color = c;
}

/* Skip equal lines (goto first unequal) */
static void lines_eq(
	IT *wl,
	IT *wr,
	STMC *sl,
	STMC *sr,
	STMC **tl,
	STMC **tr,
	bool zpm)
{
	short c = 0;
	while (sl and sr)
	{
		if (line_compare("lines_eq:", sl, sr, zpm) ne 0)
			break;
		sl = stmfinext(wl->base);
		sr = stmfinext(wr->base);
		c++;
	}

	if (tl) *tl = sl;
	if (tr) *tr = sr;
}

static STMNR last_n(IT *w)
{
	STMC *e = stmfilast(w->base);
	return e ? e->xn : 1;
}

static void lines_ne(IT *wl, IT *wr, STMNR li, STMNR lm, STMNR ri, STMNR rm, STMNR *plj, STMNR *prj, short lvl, bool zpm)
{
	STMNR lj, rj;

	if (li <= lm and ri <= rm)
	{
		still_diff (wl, wr, li, lm, ri, rm, lvl?1:n_scan, false, &lj, &rj, zpm);	/* Initializes lj & rj */

		li = lj + 1, ri = rj + 1;
	}
	*plj = lj, *prj = rj;
}

static STMNR prepare(IT *w, STMC **s, STMNR *high)
{
	STMC *sl, *cur; STMNR i;
	
	sl = stmfilast(w->base);
	if (high)
		*high = sl ? sl->xn : 1;
	via (w->deselect)(w, LOW);	/* if already found unequal, will find next */	
	cur = find_line(w, w->cu.pos.y);	/* start on current cursor positions */
	i = cur ? cur->xn : 1;
	
	if (sl)
		if (i >= sl->xn)
		{
			i = 1;
			cur = find_line(w, 0);
		}
	*s = cur;
	return i;
}
global
void sync_lines(IT *wl)	/* Interactive 'diff' */
{
	STMNR li, ri, lm, rm, lj, rj;
	IT *wr = get_second(wl, is_srce);

	if (wr)
	{
		STMC   *s1, *s2, *e1, *e2;
		bool v = wl->loc.vistab eq ' ' and wr->loc.vistab eq ' ';
		scolor(wl, wr, BLACK);

		li = prepare(wl, &s1, &lm);
		ri = prepare(wr, &s2, &rm);

		if (line_compare("sync:", s1, s2, v) eq 0)
		{
			/* if current lines are equal, go to next unequal line (skip equal lines) */
			lines_eq(wl, wr, s1, s2, &e1, &e2, v);	/* skip equal lines */
			scolor(wl, wr, RED);
		othw
			/* if current lines are unequal, go to next equal line (skip sets of unequal lines) */
			lines_ne(wl, wr, li, lm, ri, rm, &lj, &rj, 0, v);	/* skip unequal lines */
			e1 = find_line(wl, lj-1);
			e2 = find_line(wr, rj-1);
			scolor(wl, wr, GREEN);
		}

		select_2(wl,wr, e1, e2);
		disp_2  (wl,wr);
	}
	else
		send_msg("Compare needs 2 open file windows\n");
}

/* iterative 'diff' */
global void differ(IT *wl, IT *wr, STMNR li, STMNR lm, STMNR ri, STMNR rm, short lvl, bool min1, bool zpm)
{
	while (li <= lm and ri <= rm)
	{
		if (line_eq(wl, wr, li, ri, zpm))
			li++, ri++;				/* That's easy :-) */
		else
		{
			STMNR lj, rj;

			still_diff (wl, wr, li, lm, ri, rm, lvl?1:n_scan, min1, &lj, &rj, zpm);	/* Initializes lj & rj */

			if (lvl)
				disp_diff(wl, wr, li, lj, ri, rj);
			else
				differ   (wl, wr, li, lj, ri, rj, 1, min1, zpm);

			li = lj + 1, ri = rj + 1;
		}
	}

	disp_diff(wl, wr, li, lm, ri, rm);
}

global void diff_2(IT *wl)
{
	IT *wr = get_second(wl, is_srce);

	if (wr)
	{
		bool v = wl->loc.vistab eq ' ' and wr->loc.vistab eq ' ';
		differ(wl, wr, 1, last_n(wl), 1, last_n(wr), 0, true, v);
	}
	else
		send_msg("Diff 2 needs 2 open file windows\n");
}
/* >>>> End of (converted) code of ST nr 19 dd may/june 1989 */