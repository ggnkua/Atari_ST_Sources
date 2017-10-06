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

/* default column width */

#define DEFWIDTH 10
#define DEFPREC   2

#define RESCOL 4  /* columns reserved for row numbers */
#define RESROW 3  /* rows reserved for prompt, error, and column numbers */

char curfile[1024];

int showme = 1;  /* 1 to display the current cell in the top line */
int batch = 0;

error (fmt,a,b,c,d,e) {
    if (batch) fprintf(stderr,fmt,a,b,c,d,e);
    else {
	move (1,0);
	clrtoeol ();
	printw (fmt,a,b,c,d,e);
    }
}

int seenerr;

yyerror (err)
char *err; {
    if (seenerr) return;
    seenerr++;
    move (1,0);
    clrtoeol ();
#ifdef TOS
    {
    	char format[20];
    	sprintf(format,"%%s: %%.%ds <= %%s",linelim);
    	printw(format,err,line,line+linelim);
    }
#else
    printw ("%s: %.*s <= %s",err,linelim,line,line+linelim);
#endif
}

struct ent *
lookat(row,col){
    register struct ent **p;
    if (row < 0)
	row = 0;
    else if (row > MAXROWS-1) 
	row = MAXROWS-1;
    if (col < 0) 
	col = 0;
    else if (col > MAXCOLS-1)
	col = MAXCOLS-1;
    p = &tbl[row][col];
    if (*p==0) {
	*p = (struct ent *) malloc (sizeof (struct ent));
	if (row>maxrow) maxrow = row;
	if (col>maxcol) maxcol = col;
	(*p)->label = 0;
	(*p)->flags = 0;
	(*p)->row = row;
	(*p)->col = col;
	(*p)->expr = 0;
	(*p)->v = (double) 0.0;
    } else if ((*p)->flags & is_deleted) 
	debug("But %s%d has been deleted!", coltoa(col), row);
    return *p;
}

/*
 * This structure is used to keep ent structs around before they
 * are deleted to allow the sync_refs routine a chance to fix the
 * variable references.
 * We also use it as a last-deleted buffer for the 'p' command.
 */

free_ent(p)
register struct ent *p;
{
    p->next = to_fix;
    to_fix = p;
    p->flags |= is_deleted;
}

flush_saved()
{
    register struct ent *p;
    register struct ent *q;

    if (!(p = to_fix))
	return;
    while (p) {
	clearent(p);
	q = p->next;
	free(p);
	p = q;
    }
    to_fix = 0;
}

update () {
    register    row,
                col;
    register struct ent **p;
    static  lastmx,
            lastmy;
    static  char *under_cursor = " ";
    int     maxcol;
    int     maxrow;
    int     rows;
    int     cols;
    register r;

    while (hidden_row[currow])   /* You can't hide the last row or col */
	currow++;
    while (hidden_col[curcol])
	curcol++;
    if (curcol < stcol)
	stcol = curcol, FullUpdate++;
    if (currow < strow)
	strow = currow, FullUpdate++;
    while (1) {
	register    i;
	for (i = stcol, cols = 0, col = RESCOL;
	     (col + fwidth[i]) < COLS-1 && i < MAXCOLS; i++) {
	    cols++;
	    if (hidden_col[i])
		continue;
	    col += fwidth[i];
	}
	if (curcol >= stcol + cols)
	    stcol++, FullUpdate++;
	else
	    break;
    }
    while (1) {
	register    i;
	for (i = strow, rows = 0, row = RESROW;
	     row < ROWS && i < MAXROWS; i++) {
	    rows++;
	    if (hidden_row[i])
		continue;
	    row++;
	}
	if (currow >= strow + rows)
	    strow++, FullUpdate++;
	else
	    break;
    }
    maxcol = stcol + cols - 1;
    maxrow = strow + rows - 1;
    if (FullUpdate) {
	register int i;
	move (2, 0);
	clrtobot ();
	standout();
	for (row=RESROW, i=strow; i <= maxrow; i++) {
	    if (hidden_row[i]) 
		continue;
	    move(row,0);
#ifdef TOS
	    {
	    	char format[10];
	    	sprintf(format,"%%-%dd",RESCOL);
	    	printw(format,i);
	    }
#else
	    printw("%-*d", RESCOL, i);
#endif
	    row++;
	}
	move (2,0);
#ifdef TOS
	{
		char format[10];
		sprintf(format,"%%%ds",RESCOL);
		printw(format," ");
	}
#else
	printw("%*s", RESCOL, " ");
#endif
	for (col=RESCOL, i = stcol; i <= maxcol; i++) {
	    if (hidden_col[i])
		continue;
	    move(2, col);
#ifdef TOS
	{
		char format[10];
		sprintf(format,"%%%ds",fwidth[i]);
		printw(format,coltoa(i));
	}
#else
	    printw("%*s", fwidth[i], coltoa(i));
#endif
	    col += fwidth[i];
	}
	standend();
    }
    for (row = strow, r = RESROW; row <= maxrow; row++) {
	register    c = RESCOL;
	if (hidden_row[row])
	    continue;
	for (p = &tbl[row][col = stcol]; col <= maxcol; col++, p++) {
	    if (hidden_col[col])
		continue;
	    if (*p && ((*p) -> flags & is_changed || FullUpdate)) {
		char   *s;
		move (r, c);
		(*p) -> flags &= ~is_changed;
		if ((*p) -> flags & is_valid)
#ifdef TOS
			{
				char format[16];
				sprintf(format,"%%%d.%df",fwidth[col],precision[col]);
				printw(format,(*p)->v);
			}
#else
		    printw ("%*.*f", fwidth[col], precision[col], (*p) -> v);
#endif
		if (s = (*p) -> label) {
		    char field[1024];

		    strncpy(field,s,fwidth[col]);
		    field[fwidth[col]] = 0;
		    move (r,(*p) -> flags & is_leftflush
			    ? c : c - strlen (field) + fwidth[col]);
		    addstr(field);
		}
	    }
	    c += fwidth[col];
	}
	r++;
    }
    
    move(lastmy, lastmx);
    if (inch() == '<')
        addstr (under_cursor);
    lastmy =  RESROW;
    for (row = strow; row < currow; row++)
	if (!hidden_row[row])
		lastmy += 1;
    lastmx = RESCOL;
    for (col = stcol; col <= curcol; col++)
	if (!hidden_col[col])
		lastmx += fwidth[col];
    move(lastmy, lastmx);
    *under_cursor = inch();
    addstr ("<");
    move (0, 0);
    clrtoeol ();
    if (linelim >= 0) {
	addstr (">> ");
	addstr (line);
    } else {
	if (showme) {
	    register struct ent *p;
	    p = tbl[currow][curcol];
	    if (p && ((p->flags & is_valid) || p->label)) {
		if (p->expr || !p->label) {
		    linelim = 0;
		    editexp(currow, curcol);
		} else {
		    sprintf(line, "%s", p->label);
		}
		addstr("[");
		addstr (line);
		addstr("]");
		linelim = -1;
	    } else {
		addstr("[]");
	    }
	}
	move (lastmy, lastmx);
    }
    FullUpdate = 0;
}

void
quit()
{
    endwin ();
    exit();
}

main (argc, argv)
char  **argv; {
    int     inloop = 1;
    register int   c;
    int     edistate = -1;
    int     arg = 1;
    int     narg;
    int     nedistate = -1;
    int	    running = 1;
    {
	register    i;
	for (i = 0; i < MAXCOLS; i++) {
	    fwidth[i] = DEFWIDTH;
	    precision[i] = DEFPREC;
	}
    }
    linelim = -1;
    curfile[0]=0;
    running = 1;

    if (argc > 1 && (! strcmp(argv[1],"-b"))) {
	argc--, argv++;
	batch = 1;
    }

    if (! batch) {
	initscr ();
    }
    initkbd();
    if (argc > 1) {
	strcpy(curfile,argv[1]);
	readfile (argv[1],0);
    }
    modflg = 0;
    if (batch) exit(0);
    error ("VC 2.1  Type '?' for help.");
    FullUpdate++;
    while (inloop) { running = 1;
    while (running) {
	nedistate = -1;
	narg = 1;
	if (edistate < 0 && linelim < 0 && (changed || FullUpdate))
	    EvalAll (), changed = 0;
	update ();
	refresh ();
	move (1, 0);
	clrtoeol ();
	fflush (stdout);
	seenerr = 0;
	if (((c = nmgetch ()) < ' ') || ( c == 0177 ))
	    switch (c) {
		case ctl (z):
		    quit();
		    break;
		case ctl (r):
		    FullUpdate++;
		    touchwin();
		    clear();
		    break;
		default:
		    error ("No such command  (^%c)", c + 0100);
		    break;
		case ctl (b):
		    while (--arg>=0) {
			if (curcol)
			    curcol--;
			else
			    error ("At column A");
			while(hidden_col[curcol] && curcol)
			    curcol--;
		    }
		    break;
		case ctl (c):
		    running = 0;
		    break;
		case ctl (f):
		    while (--arg>=0) {
			if (curcol < MAXCOLS - 1)
			    curcol++;
			else
			    error ("The table can't be any wider");
			while(hidden_col[curcol]&&(curcol<MAXCOLS-1))
			    curcol++;
		    }
		    break;
		case ctl (g):
		case ctl ([):
		    linelim = -1;
		    move (1, 0);
		    clrtoeol ();
		    break;
		case 0177:
		case ctl (h):
		    while (--arg>=0) if (linelim > 0)
			line[--linelim] = 0;
		    break;
		case ctl (l):
		    FullUpdate++;
		    break;
		case ctl (m):
		    if (linelim < 0)
			line[linelim = 0] = 0;
		    else {
			linelim = 0;
			yyparse ();
			linelim = -1;
		    }
		    break;
		case ctl (n):
		    while (--arg>=0) {
			if (currow < MAXROWS - 1)
			    currow++;
			else
			    error ("The table can't be any longer");
			while (hidden_row[currow] && (currow < MAXROWS - 1))
			    currow++;
		    }
		    break;
		case ctl (p):
		    while (--arg>=0) {
			if (currow)
			    currow--;
			else
			    error ("At row zero");
			while (hidden_row[currow] && currow)
			    currow--;
		    }
		    break;
		case ctl (q):
		    break;	/* ignore flow control */
		case ctl (s):
		    break;	/* ignore flow control */
		case ctl (t):
		    showme ^= 1;
		    break;
		case ctl (u):
		    narg = arg * 4;
		    nedistate = 1;
		    break;
		case ctl (v):	/* insert variable name */
		    if (linelim > 0) {
			sprintf (line+linelim,"%s%d", coltoa(curcol), currow);
			linelim = strlen (line);
		    }
		    break;
		case ctl (e):	/* insert variable expression */
		    if (linelim > 0) editexp(currow,curcol);
		    break;
		case ctl (a):	/* insert variable value */
		    if (linelim > 0) {
			struct ent *p = tbl[currow][curcol];

			if (p && p -> flags & is_valid) {
			    sprintf (line + linelim, "%.*f",
					precision[curcol],p -> v);
			    linelim = strlen (line);
			}
		    }
		    break;
		}
	else
	    if ('0' <= c && c <= '9' && (linelim < 0 || edistate >= 0)) {
		if (edistate != 0) {
		    if (c == '0')      /* just a '0' goes to left col */
			curcol = 0;
		    else {
		        nedistate = 0;
		        narg = c - '0';
		    }
		} else {
		    nedistate = 0;
		    narg = arg * 10 + (c - '0');
		}
	    }
	    else
		if (linelim >= 0) {
		    line[linelim++] = c;
		    line[linelim] = 0;
		}
		else
		    switch (c) {
			case '.':
			    nedistate = 1;
			    break;
			case ':':
			    break;	/* Be nice to vi users */
			case '=':
			    sprintf(line,"let %s%d = ",coltoa(curcol),currow);
			    linelim = strlen (line);
			    break;
			case '/':
			    sprintf(line,"copy [to] %s%d [from] ", 
				      coltoa(curcol), currow);
			    linelim = strlen (line);
			    break;
			case '$':
			    curcol = MAXCOLS - 1;
			    while (!tbl[currow][curcol] && curcol > 0)
				curcol--;
			    break;
			case '?':
			    help ();
			    break;
			case '"':
			    sprintf (line, "label %s%d = \"",
						coltoa(curcol), currow);
			    linelim = strlen (line);
			    break;
			case '<':
			    sprintf (line, "leftstring %s%d = \"",
				    coltoa(curcol), currow);
			    linelim = strlen (line);
			    break;
			case '>':
			    sprintf (line, "rightstring %s%d = \"",
				    coltoa(curcol), currow);
			    linelim = strlen (line);
			    break;
			case 'e':
			    editv (currow, curcol);
			    break;
			case 'E':
			    edits (currow, curcol);
			    break;
			case 'f':
			    sprintf (line, "format [for column] %s [is] ",
					coltoa(curcol));
			    error("Current format is %d %d",
					fwidth[curcol],precision[curcol]);
			    linelim = strlen (line);
			    break;
			case 'P':
			    sprintf (line, "put [database into] \"");
			    if (*curfile)
			    error("default file is '%s'",curfile);
			    linelim = strlen (line);
			    break;
			case 'M':
			    sprintf (line, "merge [database from] \"");
			    linelim = strlen (line);
			    break;
			case 'G':
			    sprintf (line, "get [database from] \"");
			    if (*curfile)
			    error("default file is '%s'",curfile);
			    linelim = strlen (line);
			    break;
			case 'W':
			    sprintf (line, "write [listing to] \"");
			    linelim = strlen (line);
			    break;
			case 'T':	/* tbl output */
			    sprintf (line, "tbl [listing to] \"");
			    linelim = strlen (line);
			    break;
			case 'i':
			    switch (get_qual()) {
			    case 'r':
				insertrow(arg);
				break;
			    case 'c':
				insertcol(arg);
				break;
			    default:
				break;
			    }
			    break;
			case 'd':
			    switch (get_qual()) {
			    case 'r':
				deleterow(arg);
				break;
			    case 'c':
				deletecol(arg);
				break;
			    default:
				break;
			    }
			    break;
			case 'v':
			    switch (get_qual()) {
			    case 'r':
				valueizerow(arg);
				break;
			    case 'c':
				valueizecol(arg);
				break;
			    default:
				break;
			    }
			    break;
			case 'p':
			    {
			    register qual;
			    qual = get_qual();
			    while (arg--)
			        pullcells(qual);
			    break;
			    }
			case 'x':
			    {
			    register struct ent **p;
			    register int c;
			    flush_saved();
			    for (c = curcol; arg-- && c < MAXCOLS; c++) {
				p = &tbl[currow][c];
				if (*p) {
			            free_ent(*p);
			            *p = 0;
				}
			    }
			    sync_refs();
			    FullUpdate++;
			    }
			    break;
			case 'Q':
			case 'q':
			    running = 0;
			    break;
			case 'h':
			    while (--arg>=0) {
				if (curcol)
				    curcol--;
				else
				    error ("At column A");
				while(hidden_col[curcol] && curcol)
				    curcol--;
			    }
			    break;
			case 'j':
			    while (--arg>=0) {
				if (currow < MAXROWS - 1)
				    currow++;
				else
				    error ("The table can't be any longer");
				while (hidden_row[currow]&&(currow<MAXROWS-1))
				    currow++;
			    }
			    break;
			case 'k':
			    while (--arg>=0) {
				if (currow)
				    currow--;
				else
				    error ("At row zero");
				while (hidden_row[currow] && currow)
				    currow--;
			    }
			    break;
			case 'l':
			    while (--arg>=0) {
				if (curcol < MAXCOLS - 1)
				    curcol++;
				else
				    error ("The table can't be any wider");
				while(hidden_col[curcol]&&(curcol<MAXCOLS-1))
				    curcol++;
			    }
			    break;
			case 'm':
			    savedrow = currow;
			    savedcol = curcol;
			    break;
			case 'c': {
			    register struct ent *p = tbl[savedrow][savedcol];
			    register c;
			    register struct ent *n;
			    if (!p)
				break;
			    FullUpdate++;
			    modflg++;
			    for (c = curcol; arg-- && c < MAXCOLS; c++) {
				n = lookat (currow, c);
				clearent(n);
				n -> flags = p -> flags;
				n -> v = p -> v;
				n -> expr = copye(p->expr,
					    currow - savedrow,
					    c - savedcol);
				n -> label = 0;
				if (p -> label) {
				    n -> label = (char *)
						 malloc(strlen(p->label)+1);
				strcpy (n -> label, p -> label);
				}
			    }
			    break;
			}
			case 'z':
			    switch (get_qual()) {
			    case 'r':
				hiderow(arg);
				break;
			    case 'c':
				hidecol(arg);
				break;
			    default:
				break;
			    }
			    break;
			case 's':
			    switch (get_qual()) {
			    case 'r':
				showrow_op();
				break;
			    case 'c':
				showcol_op();
				break;
			    default:
				break;
			    }
			    break;
			case 'a':
			    switch (get_qual()) {
			    case 'r':
				while (arg--)
				    duprow();
				break;
			    case 'c':
				while (arg--)
				    dupcol();
				break;
			    default:
				break;
			    }
			    break;
			default:
			    if ((c & 0177) != c)
				error("Weird character, decimal '%d'.\n",
					(int) c);
			    else error ("No such command  (%c)", c);
			    break;
		    }
	edistate = nedistate;
	arg = narg;
    }				/* while (running) */
    inloop = modcheck(" before exiting");
    }				/*  while (inloop) */
    endwin ();
}

modcheck(endstr) char *endstr; {
    if (modflg && curfile[0]) {
	char ch, lin[100];

	move (0, 0);
	clrtoeol ();
	sprintf (lin,"File '%s' is modified, save%s? ",curfile,endstr);
	addstr (lin);
	refresh();
	ch = nmgetch();
	if (ch == 'y' || ch == 'Y') writefile(curfile);
	else if (ch == ctl (g)) return(1);
    }
    return(0);
}
    
writefile (fname)
char *fname; {
    register FILE *f;
    register struct ent **p;
    register r, c;
    char save[1024];

    if (*fname == 0) fname = &curfile[0];

    strcpy(save,fname);

    f = fopen (fname, "w");
    if (f==0) {
	error ("Can't create %s", fname);
	return;
    }

    fprintf (f, "# This data file was generated by the Spreadsheet ");
    fprintf (f, "Calculator.\n");
    fprintf (f, "# You almost certainly shouldn't edit it.\n\n");
    for (c=0; c<MAXCOLS; c++)
	if (fwidth[c] != DEFWIDTH || precision[c] != DEFPREC)
	    fprintf (f, "format %s %d %d\n",coltoa(c),fwidth[c],precision[c]);
    for (r=0; r<=maxrow; r++) {
	p = &tbl[r][0];
	for (c=0; c<=maxcol; c++, p++)
	    if (*p) {
		if ((*p)->label)
		    fprintf (f, "%sstring %s%d = \"%s\"\n",
				(*p)->flags&is_leftflush ? "left" : "right",
				coltoa(c),r,(*p)->label);
		if ((*p)->flags&is_valid) {
		    editv (r, c);
		    fprintf (f, "%s\n",line);
		}
	    }
    }
    fclose (f);
    strcpy(curfile,save);

    modflg = 0;
    error("File '%s' written.",curfile);
}

readfile (fname,eraseflg)
char *fname; int eraseflg; {
    register FILE *f;
    char save[1024];

    if (*fname == 0) fname = &curfile[0];
    strcpy(save,fname);

    if (eraseflg && strcmp(fname,curfile) && modcheck(" first")) return;

    f = fopen (save, "r");
    if (f==0) {
	error ("Can't read %s", save);
	return;
    }

    if (eraseflg) erasedb ();

    while (fgets(line,sizeof line,f)) {
	linelim = 0;
	if (line[0] != '#') yyparse ();
    }
    fclose (f);
    linelim = -1;
    modflg++;
    if (eraseflg) {
	strcpy(curfile,save);
	modflg = 0;
    }
    EvalAll();
}

erasedb () {
    register r, c;
    for (c = 0; c<=maxcol; c++) {
	fwidth[c] = DEFWIDTH;
	precision[c] = DEFPREC;
    }

    for (r = 0; r<=maxrow; r++) {
	register struct ent **p = &tbl[r][0];
	for (c=0; c++<=maxcol; p++)
	    if (*p) {
		if ((*p)->expr) efree ((*p) -> expr);
		if ((*p)->label) free ((*p) -> label);
		free (*p);
		*p = 0;
	    }
    }
    maxrow = 0;
    maxcol = 0;
    FullUpdate++;
}

