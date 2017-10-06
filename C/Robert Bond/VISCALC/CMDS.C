/*	SC	A Spreadsheet Calculator
 *		Main driver
 *
 *		original by James Gosling, September 1982
 *		modifications by Mark Weiser and Bruce Israel,
 *			University of Maryland
 *
 *              More mods Robert Bond, 12/86
 *		Major mods to run on VMS and AMIGA, 1/17/87
 *
 */

#include "sc.h"

extern char *malloc();

duprow()
{
    if (currow >= MAXROWS - 1 || maxrow >= MAXROWS - 1) {
	error ("The table can't be any bigger");
	return;
    }
    modflg++;
    currow++;
    openrow (currow);
    for (curcol = 0; curcol <= maxcol; curcol++) {
	register struct ent *p = tbl[currow - 1][curcol];
	if (p) {
	    register struct ent *n;
	    n = lookat (currow, curcol);
	    n -> v = p -> v;
	    n -> flags = p -> flags;
	    n -> expr = copye (p -> expr, 1, 0);
	    n -> label = 0;
	    if (p -> label) {
		n -> label = (char *)
			     malloc (strlen (p -> label) + 1);
		strcpy (n -> label, p -> label);
	    }
	}
    }
    for (curcol = 0; curcol <= maxcol; curcol++) {
	register struct ent *p = tbl[currow][curcol];
	if (p && (p -> flags & is_valid) && !p -> expr)
	    break;
    }
    if (curcol > maxcol)
	curcol = 0;
}

dupcol() 
{
    if (curcol >= MAXCOLS - 1 || maxcol >= MAXCOLS - 1) {
	error ("The table can't be any wider");
	return;
    }
    modflg++;
    curcol++;
    opencol (curcol);
    for (currow = 0; currow <= maxrow; currow++) {
	register struct ent *p = tbl[currow][curcol - 1];
	if (p) {
	    register struct ent *n;
	    n = lookat (currow, curcol);
	    n -> v = p -> v;
	    n -> flags = p -> flags;
	    n -> expr = copye (p -> expr, 0, 1);
	    n -> label = 0;
	    if (p -> label) {
		n -> label = (char *)
			     malloc (strlen (p -> label) + 1);
		strcpy (n -> label, p -> label);
	    }
	}
    }
    for (currow = 0; currow <= maxrow; currow++) {
	register struct ent *p = tbl[currow][curcol];
	if (p && (p -> flags & is_valid) && !p -> expr)
	    break;
    }
    if (currow > maxrow)
	currow = 0;
}

insertrow(arg)
{
    while (--arg>=0) openrow (currow);
}

deleterow(arg)
{
    flush_saved();
    erase_area(currow, 0, currow + arg - 1, maxcol);
    currow += arg;
    while (--arg>=0) closerow (--currow);
    sync_refs();
}

insertcol(arg)
{
    while (--arg>=0) opencol(curcol);
}

deletecol(arg)
{
    flush_saved();
    erase_area(0, curcol, maxrow, curcol + arg - 1);
    curcol += arg;
    while (--arg>=0) closecol (--curcol);
    sync_refs();
}

valueizerow(arg)
{
    valueize_area(currow, 0, currow + arg - 1, maxcol);
}

valueizecol(arg)
{
    valueize_area(0, curcol, maxrow, curcol + arg - 1);
}

erase_area(sr, sc, er, ec)
int sr, sc, er, ec;
{
    register int r, c;
    register struct ent **p;

    if (sr > er) {
	r = sr; sr = er; er= r;	
    }

    if (sc > ec) {
	c = sc; sc = ec; ec= c;	
    }

    if (sr < 0)
	sr = 0; 
    if (sc < 0)
	sc = 0;
    if (er >= MAXROWS)
	er = MAXROWS-1;
    if (ec >= MAXCOLS)
	ec = MAXCOLS-1;

    for (r = sr; r <= er; r++) {
	for (c = sc; c <= ec; c++) {
	    p = &tbl[r][c];
	    if (*p) {
		free_ent(*p);
		*p = 0;
	    }
	}
    }

}

valueize_area(sr, sc, er, ec)
int sr, sc, er, ec;
{
    register int r, c;
    register struct ent *p;

    if (sr > er) {
	r = sr; sr = er; er= r;	
    }

    if (sc > ec) {
	c = sc; sc = ec; ec= c;	
    }

    if (sr < 0)
	sr = 0; 
    if (sc < 0)
	sc = 0;
    if (er >= MAXROWS)
	er = MAXROWS-1;
    if (ec >= MAXCOLS)
	ec = MAXCOLS-1;

    for (r = sr; r <= er; r++) {
	for (c = sc; c <= ec; c++) {
	    p = tbl[r][c];
	    if (p && p->expr) {
		efree(p->expr);
		p->expr = 0;
	    }
	}
    }

}

pullcells(to_insert)
{
    register struct ent *p, *n;
    register int deltar, deltac;
    int minrow, mincol;
    int maxrow, maxcol;
    int numrows, numcols;

    if (!to_fix)
	return;

    switch (to_insert) {
    case 'm':
    case 'r':
    case 'c':
	break;
    default:
	return;
    }

    minrow = MAXROWS; 
    mincol = MAXCOLS;
    maxrow = 0;
    maxcol = 0;

    for (p = to_fix; p; p = p->next) {
	if (p->row < minrow)
	    minrow = p->row;
	if (p->row > maxrow)
	    maxrow = p->row;
	if (p->col < mincol)
	    mincol = p->col;
	if (p->col > maxcol)
	    maxcol = p->col;
    }

    numrows = maxrow - minrow + 1;
    numcols = maxcol - mincol + 1;
    deltar = currow - minrow;
    deltac = curcol - mincol;

    if (to_insert == 'r') {
	insertrow(numrows);
	deltac = 0;
    } else if (to_insert == 'c') {
	insertcol(numcols);
	deltar = 0;
    }

    FullUpdate++;
    modflg++;

    for (p = to_fix; p; p = p->next) {
	n = lookat (p->row + deltar, p->col + deltac);
	clearent(n);
	n -> flags = p -> flags & ~is_deleted;
	n -> v = p -> v;
	n -> expr = copye(p->expr, deltar, deltac);
	n -> label = 0;
	if (p -> label) {
	    n -> label = (char *)
			 malloc(strlen(p->label)+1);
	    strcpy (n -> label, p -> label);
	}
    }
}

showcol_op()
{
    register int i,j;
    for (i=0; i<MAXCOLS; i++)
	if (hidden_col[i]) 
	    break;
    for(j=i; j<MAXCOLS; j++)
	if (!hidden_col[j])
	    break;
    j--;
    if (i<MAXCOLS) {
	sprintf(line,"show %s:", coltoa(i));
	sprintf(line + strlen(line),"%s",coltoa(j));
	linelim = strlen (line);
    }
}

showrow_op()
{
    register int i,j;
    for (i=0; i<MAXROWS; i++)
	if (hidden_row[i]) 
	    break;
    for(j=i; j<MAXROWS; j++)
	if (!hidden_row[j]) {
	    break;
	}
    j--;
    if (i<MAXROWS) {
	sprintf(line,"show %d:%d", i, j);
        linelim = strlen (line);
    }
}

get_qual()
{
    register int c;

    c = nmgetch();
    switch (c) {
    case 'c':
    case 'j':
    case 'k':
    case ctl(p):
    case ctl(n):
	return('c');
	break;
    case 'r':
    case 'l':
    case 'h':
    case ctl(f):
    case ctl(b):
	return('r');
	break;
    default:
	return(c);
    	break;
    }
}

openrow (rs) {
    register    r;
    register struct ent **p;
    register    c;
    register	i;

    if (rs > maxrow) maxrow = rs;
    if (maxrow >= MAXROWS - 1 || rs > MAXROWS - 1) {
	error ("The table can't be any longer");
	return;
    }
    for (i = maxrow+1; i > rs; i--) {
	hidden_row[i] = hidden_row[i-1];
    }
    for (r = ++maxrow; r > rs; r--)
	for (c = maxcol + 1, p = &tbl[r][0]; --c >= 0; p++)
	    if (p[0] = p[-MAXCOLS])
		p[0] -> row++;
    p = &tbl[rs][0];
    for (c = maxcol + 1; --c >= 0;)
	*p++ = 0;
    FullUpdate++;
    modflg++;
}

closerow (r)
register r; {
    register struct ent **p;
    register c;
    register int i;

    if (r > maxrow) return;

    p = &tbl[r][0];
    for (c=maxcol+1; --c>=0; ) {
	if (*p)
	    free_ent(*p);
	*p++ = 0;
    }

    for (i = r; i < MAXROWS - 1; i++) {
	hidden_row[i] = hidden_row[i+1];
    }

    while (r<maxrow) {
	for (c = maxcol+1, p = &tbl[r][0]; --c>=0; p++)
	    if (p[0] = p[MAXCOLS])
		p[0]->row--;
	r++;
    }

    p = &tbl[maxrow][0];
    for (c=maxcol+1; --c>=0; ) *p++ = 0;
    maxrow--;
    FullUpdate++;
    modflg++;
}

opencol (cs) {
    register r;
    register struct ent **p;
    register c;
    register lim = maxcol-cs+1;
    int i;

    if (cs > maxcol) maxcol = cs;
    if (maxcol >= MAXCOLS - 1 || cs > MAXCOLS - 1) {
	error ("The table can't be any wider");
	return;
    }
    for (i = maxcol+1; i > cs; i--) {
	fwidth[i] = fwidth[i-1];
	precision[i] = precision[i-1];
	hidden_col[i] = hidden_col[i-1];
    }
    /* fwidth[cs] = DEFWIDTH;
    precision[i] =  DEFPREC;  */

    for (r=0; r<=maxrow; r++) {
	p = &tbl[r][maxcol+1];
	for (c=lim; --c>=0; p--)
	    if (p[0] = p[-1])
		p[0]->col++;
	p[0] = 0;
    }
    maxcol++;
    FullUpdate++;
    modflg++;
}

closecol (cs) {
    register r;
    register struct ent **p;
    register struct ent *q;
    register c;
    register lim = maxcol-cs;
    int i;

    if (lim < 0) return;

    for (r=0; r<=maxrow; r++)
	if (q = tbl[r][cs]) {
	    free_ent(q);
	}

    for (r=0; r<=maxrow; r++) {
	p = &tbl[r][cs];
	for (c=lim; --c>=0; p++)
	    if (p[0] = p[1])
		p[0]->col--;
	p[0] = 0;
    }

    for (i = cs; i < MAXCOLS - 1; i++) {
	fwidth[i] = fwidth[i+1];
	precision[i] = precision[i+1];
	hidden_col[i] = hidden_col[i+1];
    }

    maxcol--;
    FullUpdate++;
    modflg++;
}

