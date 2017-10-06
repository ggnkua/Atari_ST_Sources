/*	SC	A Spreadsheet Calculator
 *		Expression interpreter and assorted support routines.
 *
 *		original by James Gosling, September 1982
 *		modified by Mark Weiser and Bruce Israel, 
 *			University of Maryland
 *
 *              More mods Robert Bond, 12/86
 *		Major mods to run on VMS and AMIGA, 1/17/87
 */

#include "sc.h"
#define DEFCOLDELIM ':'

char *malloc();

double dosum(minr, minc, maxr, maxc)
int minr, minc, maxr, maxc;
{
    double v;
    register r,c;
    register struct ent *p;

    v = 0;
    for (r = minr; r<=maxr; r++)
	for (c = minc; c<=maxc; c++)
	    if ((p = tbl[r][c]) && p->flags&is_valid)
		v += p->v;
    return v;
}

double doprod(minr, minc, maxr, maxc)
int minr, minc, maxr, maxc;
{
    double v;
    register r,c;
    register struct ent *p;

    v = 1;
    for (r = minr; r<=maxr; r++)
	for (c = minc; c<=maxc; c++)
	    if ((p = tbl[r][c]) && p->flags&is_valid)
		v *= p->v;
    return v;
}

double doavg(minr, minc, maxr, maxc)
int minr, minc, maxr, maxc;
{
    double v;
    register r,c,count;
    register struct ent *p;

    v = 0;
    count = 0;
    for (r = minr; r<=maxr; r++)
	for (c = minc; c<=maxc; c++)
	    if ((p = tbl[r][c]) && p->flags&is_valid) {
		v += p->v;
		count++;
	    }

    return (v / (double)count);
}

double eval(e)
register struct enode *e; {
    if (e==0) return 0;
    switch (e->op) {
	case '+':	return (eval(e->e.o.left) + eval(e->e.o.right));
	case '-':	return (eval(e->e.o.left) - eval(e->e.o.right));
	case '*':	return (eval(e->e.o.left) * eval(e->e.o.right));
	case '/':     {	double denom = eval (e->e.o.right);
			return denom ? eval(e->e.o.left) / denom : 0; }
	case '<':	return (eval(e->e.o.left) < eval(e->e.o.right));
	case '=':	return (eval(e->e.o.left) == eval(e->e.o.right));
	case '>':	return (eval(e->e.o.left) > eval(e->e.o.right));
	case '&':	return (eval(e->e.o.left) != 0.0 &&
			       eval(e->e.o.right) != 0.0) ? 1.0 : 0.0;
	case '|':	return (eval(e->e.o.left) != 0.0 ||
			       eval(e->e.o.right) != 0.0) ? 1.0 : 0.0;
	case '?':	return eval(e->e.o.left) ? eval(e->e.o.right->e.o.left)
						 : eval(e->e.o.right->e.o.right);
	case 'm':	return (-eval(e->e.o.right));
	case 'f':	return (eval(e->e.o.right));
	case '~':	return (!eval(e->e.o.right));
	case 'k':	return (e->e.k);
	case 'v':	return (e->e.v->v);
	case O_REDUCE('+'):
 	case O_REDUCE('*'):
 	case O_REDUCE('a'):
	    {
#ifdef TOS
	    	register r,c;
		int maxr, maxc;
		int minr, minc;
#else
	    	register r,c;
		register maxr, maxc;
		register minr, minc;
#endif
		maxr = ((struct ent *) e->e.o.right) -> row;
		maxc = ((struct ent *) e->e.o.right) -> col;
		minr = ((struct ent *) e->e.o.left) -> row;
		minc = ((struct ent *) e->e.o.left) -> col;
		if (minr>maxr) r = maxr, maxr = minr, minr = r;
		if (minc>maxc) c = maxc, maxc = minc, minc = c;
	        switch (e->op) {
	            case O_REDUCE('+'): return dosum(minr, minc, maxr, maxc);
 	            case O_REDUCE('*'): return doprod(minr, minc, maxr, maxc);
 	            case O_REDUCE('a'): return doavg(minr, minc, maxr, maxc);
		}
	    }
    }
}

#define MAXPROP 7

EvalAll () {
    int lastct,repct = 0;

    while ((lastct = RealEvalAll()) && (repct++ <= MAXPROP));

    repct--;
}

int RealEvalAll () {
    register i,j;
    int chgct = 0;
    register struct ent *p;
    for (i=0; i<=maxrow; i++)
	for (j=0; j<=maxcol; j++)
	    if ((p=tbl[i][j]) && p->expr) {
		double v = eval (p->expr);
		if (v != p->v) {
		    p->v = v; chgct++;
		    p->flags |= (is_changed|is_valid);
		}
	    }
    return(chgct);
}

struct enode *new(op,a1,a2)
struct enode *a1, *a2; {
    register struct enode *p = (struct enode *) malloc (sizeof (struct enode));
    p->op = op;
    switch (op) {
    case O_VAR: p->e.v = (struct ent *) a1; break;
    case O_CONST: p->e.k = *(double *)&a1; break;
    default: p->e.o.left = a1; p->e.o.right = a2;
    }
    return p;
}

copy (dv, v1, v2)
struct ent *dv, *v1, *v2;
{
    register r,c;
    register struct ent *p;
    register struct ent *n;
    register deltar, deltac;
    int maxr, maxc;
    int minr, minc;
    int dr, dc;

    dr = dv->row;
    dc = dv->col;
    maxr = v2->row;
    maxc = v2->col;
    minr = v1->row;
    minc = v1->col;
    if (minr>maxr) r = maxr, maxr = minr, minr = r;
    if (minc>maxc) c = maxc, maxc = minc, minc = c;
    if (dr+maxr-minr >= MAXROWS  || 
           dc+maxc-minc >= MAXCOLS) {
	error ("The table can't be any bigger");
	return;
    }
    deltar = dr-minr;
    deltac = dc-minc;
    FullUpdate++;
    for (r = minr; r<=maxr; r++)
	for (c = minc; c<=maxc; c++) {
	    n = lookat (r+deltar, c+deltac);
	    clearent(n);
	    if (p = tbl[r][c]) {
		n -> v = p -> v;
		n -> flags = p -> flags;
		n -> expr = copye(p->expr, deltar, deltac);
		n -> label = 0;
		if (p -> label) {
		    n -> label = (char *)
				 malloc (strlen (p -> label) + 1);
		    strcpy (n -> label, p -> label);
		}
	    }
	}
}

let (v, e)
struct ent *v;
struct enode *e; {
    efree (v->expr);
    if (constant(e)) {
	v->v = eval(e);
	v->expr = 0;
	efree(e);
    } else
	v->expr = e;
    v->flags |= (is_changed|is_valid);
    changed++;
    modflg++;
}

clearent (v)
struct ent *v; {
    if (!v)
	return;
    label(v,"",-1);
    v->v = 0;
    if (v->expr)
	efree(v->expr);
    v->expr = 0;
    v->flags |= (is_changed);
    v->flags &= ~(is_valid);
    changed++;
    modflg++;
}

constant(e)
register struct enode *e; {
    return e==0 || e->op == O_CONST 
	|| (e->op != O_VAR
	 && (e->op&~0177) != O_REDUCE(0)
	 && constant (e->e.o.left)
	 && constant(e->e.o.right));
}

efree (e)
register struct enode *e; {
    if (e) {
	if (e->op != O_VAR && e->op !=O_CONST && (e->op&~0177) != O_REDUCE(0)) {
	    efree (e->e.o.left);
	    efree (e->e.o.right);
	}
	free (e);
    }
}

label (v, s, flushdir)
register struct ent *v;
register char *s; {
    if (v) {
	if (flushdir==0 && v->flags&is_valid) {
	    register struct ent *tv;
	    if (v->col>0 && ((tv=lookat(v->row,v->col-1))->flags&is_valid)==0)
		v = tv, flushdir = 1;
	    else if (((tv=lookat (v->row,v->col+1))->flags&is_valid)==0)
		v = tv, flushdir = -1;
	    else flushdir = -1;
	}
	if (v->label) free(v->label);
	if (s && s[0]) {
	    v->label = (char *) malloc (strlen(s)+1);
	    strcpy (v->label, s);
	} else v->label = 0;
	v->flags |= is_lchanged;
	if (flushdir<0) v->flags |= is_leftflush;
	else v->flags &= ~is_leftflush;
	FullUpdate++;
	modflg++;
    }
}

decodev (v)
register struct ent *v; {
	if (v) sprintf (line+linelim, "%s%d", coltoa(v->col), v->row);
	else sprintf (line+linelim,"VAR?");
	linelim += strlen (line+linelim);
}

char *
coltoa(col)
int col;
{
    static char rname[3];
    register char *p = rname;

    if (col < 0 || col > 25*26) 
	debug("coltoa: invalid col: %d", col);

    if (col > 25) {
	*p++ = col/26 + 'A' - 1;
	col %= 26;
    }
    *p++ = col+'A';
    *p = 0;
    return(rname);
}

decompile(e, priority)
register struct enode *e; {
    register char *s;
    if (e) {
	int mypriority;
	switch (e->op) {
	default: mypriority = 99; break;
	case '?': mypriority = 1; break;
	case ':': mypriority = 2; break;
	case '|': mypriority = 3; break;
	case '&': mypriority = 4; break;
	case '<': case '=': case '>': mypriority = 6; break;
	case '+': case '-': mypriority = 8; break;
	case '*': case '/': mypriority = 10; break;
	}
	if (mypriority<priority) line[linelim++] = '(';
	switch (e->op) {
	case 'f':	{ 
			    for (s="fixed "; line[linelim++] = *s++;);
			    linelim--;
			    decompile (e->e.o.right, 30);
			    break;
			}
	case 'm':	line[linelim++] = '-';
			decompile (e->e.o.right, 30);
			break;
	case '~':	line[linelim++] = '~';
			decompile (e->e.o.right, 30);
			break;
	case 'v':	decodev (e->e.v);
			break;
	case 'k':	sprintf (line+linelim,"%.8g",e->e.k);
			linelim += strlen (line+linelim);
			break;
	case O_REDUCE('+'):
			for (s="@sum("; line[linelim++] = *s++;);
			goto more;
	case O_REDUCE('*'):
			for (s="@prod("; line[linelim++] = *s++;);
			goto more;
	case O_REDUCE('a'):
			for (s="@avg("; line[linelim++] = *s++;);
	more:		linelim--;
			decodev (e->e.o.left);
			line[linelim++] = ':';
			decodev (e->e.o.right);
			line[linelim++] = ')';
			break;

	default:	decompile (e->e.o.left, mypriority);
			line[linelim++] = e->op;
			decompile (e->e.o.right, mypriority+1);
			break;
	}
	if (mypriority<priority) line[linelim++] = ')';
    } else line[linelim++] = '?';
}

editv (row, col) {
    sprintf (line, "let %s%d = ", coltoa(col), row);
    linelim = strlen(line);
    editexp(row,col);
}

editexp(row,col) {
    register struct ent *p;
    p = lookat (row, col);
    if (p->flags&is_valid)
	if (p->expr) {
	    decompile (p->expr);
	    line[linelim] = 0;
	} else {
	    sprintf (line+linelim, "%.8g", p->v);
	    linelim += strlen (line+linelim);
	}
}

edits (row, col) {
    register struct ent *p = lookat (row, col);
    sprintf (line, "%sstring %s%d = \"",
			((p->flags&is_leftflush) ? "left" : "right"),
			coltoa(col), row);
    linelim = strlen(line);
    sprintf (line+linelim, "%s", p->label);
    linelim += strlen (line+linelim);
}

printfile (fname) {
    FILE *f = fopen(fname, "w");
    char pline[1000];
    int plinelim;
    register row, col;
    register struct ent **p;
    if (f==0) {
	error ("Can't create %s", fname);
	return;
    }
    for (row=0;row<=maxrow; row++) {
	register c = 0;
	plinelim = 0;
	for (p = &tbl[row][col=0]; col<=maxcol; col++, p++) {
	    if (*p) {
		char *s;
		while (plinelim<c) pline[plinelim++] = ' ';
		plinelim = c;
		if ((*p)->flags&is_valid) {
		    sprintf (pline+plinelim,"%*.*f",fwidth[col],precision[col],
				(*p)->v);
		    plinelim += strlen (pline+plinelim);
		}
		if (s = (*p)->label) {
		    register char *d;
		    d = pline+((*p)->flags&is_leftflush
			? c : c-strlen(s)+fwidth[col]);
		    while (d>pline+plinelim) pline[plinelim++] = ' ';
		    if (d<pline) d = pline;
		    while (*s) *d++ = *s++;
		    if (d-pline>plinelim) plinelim = d-pline;
		}
	    }
	    c += fwidth [col];
	}
	fprintf (f,"%.*s\n",plinelim,pline);
    }
    fclose (f);
}

tblprintfile (fname) {
    FILE *f = fopen(fname, "w");
    char pline[1000];
    int plinelim;
    register row, col;
    register struct ent **p;
    char coldelim = DEFCOLDELIM;

    if (f==0) {
	error ("Can't create %s", fname);
	return;
    }
    for (row=0;row<=maxrow; row++) {
	register c = 0;
	plinelim = 0;
	for (p = &tbl[row][col=0]; col<=maxcol; col++, p++) {
	    if (*p) {
		char *s;
		if ((*p)->flags&is_valid) {
		    fprintf (f,"%.*f",precision[col],
				(*p)->v);
		}
		if (s = (*p)->label) {
	            fprintf (f,"%s",s);
		}
	    }
	    fprintf(f,"%c",coldelim);
	}
	fprintf (f,"\n",pline);
    }
    fclose (f);
}

struct enode *copye (e, Rdelta, Cdelta)
register struct enode *e; {
    register struct enode *ret;
    if (e==0) ret = 0;
    else {
	ret = (struct enode *) malloc (sizeof (struct enode));
	ret->op = e->op;
	switch (ret->op) {
	case 'v':
		ret->e.v = lookat (e->e.v->row+Rdelta, e->e.v->col+Cdelta);
		break;
	case 'k':
		ret->e.k = e->e.k;
		break;
	case 'f':
		ret->e.o.right = copye (e->e.o.right,0,0);
		ret->e.o.left = 0;
 		break;
 	case O_REDUCE('+'):
 	case O_REDUCE('*'):
 	case O_REDUCE('a'):
 		ret->e.o.right = (struct enode *) lookat (
 		          ((struct ent *)e->e.o.right)->row+Rdelta,
 		          ((struct ent *)e->e.o.right)->col+Cdelta
 		   );
 		ret->e.o.left = (struct enode *) lookat (
 		          ((struct ent *)e->e.o.left)->row+Rdelta,
 		          ((struct ent *)e->e.o.left)->col+Cdelta
 		   );
		break;
	default:
		ret->e.o.right = copye (e->e.o.right,Rdelta,Cdelta);
		ret->e.o.left = copye (e->e.o.left,Rdelta,Cdelta);
		break;
	}
    }
    return ret;
}

/*
 * sync_refs and sync_ref are used to remove references to
 * deleted struct ents.  Note that the deleted structure must still
 * be hanging around before the call, but not referenced by an entry
 * in tbl.  Thus the free_ent, fix_ent calls in sc.c
 */

sync_refs () {
    register i,j;
    register struct ent *p;
    for (i=0; i<=maxrow; i++)
	for (j=0; j<=maxcol; j++)
	    if ((p=tbl[i][j]) && p->expr)
		sync_ref(p->expr);
}


sync_ref(e)
register struct enode *e;
{
    if (e==0)
	return;
    else {
	switch (e->op) {
	case 'v':
		e->e.v = lookat(e->e.v->row, e->e.v->col);
		break;
	case 'k':
		break;
 	case O_REDUCE('+'):
 	case O_REDUCE('*'):
 	case O_REDUCE('a'):
 		e->e.o.right = (struct enode *) lookat (
 		          ((struct ent *)e->e.o.right)->row,
 		          ((struct ent *)e->e.o.right)->col
 		   );
 		e->e.o.left = (struct enode *) lookat (
 		          ((struct ent *)e->e.o.left)->row,
 		          ((struct ent *)e->e.o.left)->col
 		   );
		break;
	default:
		sync_ref(e->e.o.right);
		sync_ref(e->e.o.left);
		break;
	}
    }
}

hiderow(arg)
{
    register int r1;
    register int r2;

    r1 = currow;
    r2 = r1 + arg - 1;
    if (r1 < 0 || r1 > r2) {
	error("Invalid Range");
	return;
    }
    if (r2 > MAXROWS-2) {
	error("You can't hide the last row");
	return;
    }
    FullUpdate++;
    while (r1 <= r2)
	hidden_row[r1++] = 1;
}

hidecol(arg)
{
    register int c1;
    register int c2;

    c1 = curcol;
    c2 = c1 + arg - 1;
    if (c1 < 0 || c1 > c2) {
	error("Invalid Range");
	return;
    }
    if (c2 > MAXCOLS-2) {
	error("You can't hide the last col");
	return;
    }
    FullUpdate++;
    while (c1 <= c2)
	hidden_col[c1++] = 1;
}

showrow(r1, r2)
{
    if (r1 < 0 || r1 > r2) {
	error("Invalid Range");
	return;
    }
    if (r2 > MAXROWS-1) {
	r2 = MAXROWS-1;
    }
    FullUpdate++;
    while (r1 <= r2)
	hidden_row[r1++] = 0;
}

showcol(c1, c2)
{
    if (c1 < 0 || c1 > c2) {
	error("Invalid Range");
	return;
    }
    if (c2 > MAXCOLS-1) {
	c2 = MAXCOLS-1;
    }
    FullUpdate++;
    while (c1 <= c2)
	hidden_col[c1++] = 0;
}
