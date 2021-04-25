/*
 * spread sheet program
 *	commands are copy, read, write, print, blank, format, quit
 *	labels begin with ' and are limited in length
 *	numbers are stored fixed point (2 decimal places) in longs
 */

#include "stdio.h"

/* sizes */

#define MAXROW	100
#define MAXCOL	25
#define MAXLINE	100
#define MAXNODE 5000
#define MAXSTR	16

/* screen locations */

#define FRAMEW	5
#define FRAMEH	1
#define CURCELL	22
#define MSG	23

/* default values for width, format,  and justify */

#define DEFWID	10
#define DEFFMT	2
#define DEFJST	'l'

/* screen and keyboard defines */

#define ESC	27
#define DEL	127
#define HELP	0x6200
#define UNDO	0x6100
#define INS	0x5200
#define CLR	0x4700
#define UP	0x4800
#define DOWN	0x5000
#define LEFT	0x4B00
#define RIGHT	0x4D00
#define BACKSP	8

#define LJUST	'l'
#define RJUST	'r'

/* cell types */

#define FREE	0
#define STRING	1
#define VALUE	2
#define CELL	3
#define ERR	4
#define ADD	'+'
#define SUB	'-'
#define MUL	'*'
#define DIV	'/'
#define NEG	'_'
#define SUM	'@'

/* cell structures */

typedef struct { int type; long a, b, c, d; } 	Node;
typedef struct { int type; char s[MAXSTR]; } 	String;
typedef union  { Node n; String s; } 		Cell;

Cell 	*cell[MAXROW][MAXCOL];		/* cell pointers		*/
Cell 	space[MAXNODE];			/* Cell space			*/
Cell 	*nextfree;			/* free list of nodes		*/
Cell 	extra;				/* an extra one when empty	*/
int	freecnt;			/* count of free nodes		*/

char 	linebuf[MAXLINE];		/* keyboard input buffer	*/
char	showbuf[MAXLINE];		/* buffer for show routine	*/

char	filename[MAXLINE];		/* load/save file name		*/
char	prname[MAXLINE];		/* print file name		*/
char	prwin[MAXLINE];			/* print window			*/

int	crow, ccol;			/* current cursor row and col	*/

int	frow, lrow;			/* first and last displayed row */
int	fcol, lcol;			/* first and last displayed col	*/

char	width[MAXCOL];			/* width of the columns		*/
char	format[MAXCOL];			/* format of the columns	*/
char	justify[MAXCOL];		/* justification of the cols	*/
int	loc[MAXCOL];			/* screen location of the cols	*/

char	*parstr;			/* string for expr parser	*/
char	tokstr[MAXLINE];		/* string for next token	*/

int	reframe;			/* need to reframe		*/
int	redisp;				/* need to recalc the display	*/

main(argc, argv) char *argv[]; {
	int c;
	init();
	if (argc > 1)
		loadss(argv[1]);
	while (1) {
		display();
		switch (c = get()) {
		case 'b': blank(); break;
		case 'c': copy(); break;
		case 'd': delete(); break;
		case 'e': edit(); break;
		case 'f': setformat(); break;
		case 'g': go(); break;
		case 'i': insert(); break;
		case 'l': load(); break;
		case 'p': print(); break;
		case 'q': quit(); break;
		case 's': save(); break;
		case '0': case '1': case '2': case '3': case '4':
		case '5': case '6': case '7': case '8': case '9': 
		case '\'': case '(': case '=':
			enter(c); 
			break;
		case UP: case DOWN: case LEFT: case RIGHT:
			movecur(c);
			break;
		default:
			help();
			break;
		}
	}
}

/* initialize the spreadsheet */

init() {
	int r, c;
	for (r = 0; r < MAXROW; r++)
		for (c = 0; c < MAXCOL; c++)
			cell[r][c] = NULL;
	crow = ccol = 0;
	frow = fcol = 0;
	reframe = redisp = 1;
	for (c = 0; c < MAXCOL; c++) {
		width[c] = DEFWID;
		format[c] = DEFFMT;
		justify[c] = DEFJST;
	}
	nextfree = NULL;
	freecnt = 0;
	for (r = 0; r < MAXNODE; r++)
		free(&space[r]);
	extra.n.type = ERR;
	erase();
}

/* draw a frame on the screen displaying current window rows and cols */

frame() {
	int sz, i;
	lrow = frow + 20;
	if (lrow > MAXROW) lrow = MAXROW;
	sz = FRAMEW;
	for (lcol = fcol; lcol < MAXCOL && sz + width[lcol] < 80; lcol++) {
		loc[lcol] = sz;
		sz += width[lcol];
	}
	move(0, FRAMEW);
	reverse(1);
	for (i = fcol; i < lcol; i++) {
		sprintf(linebuf, "%c..............................", 'a'+i);
		outstr(stdout, width[i], LJUST, linebuf);
	}
	for (i = frow; i < lrow; i++) {
		move(FRAMEH + i - frow, 0);
		clrline();
		sprintf(linebuf, "%d.....", i);
		outstr(stdout, FRAMEW, LJUST, linebuf);
	}
	reverse(0);
	clrbelow();
	redisp = 1;
}

/* refresh the contents of the current display window */

display() {
	int r, c, n;
	Cell *p;
	char *content();
	if (reframe) frame();
	if (redisp) {
		for (r = frow; r < lrow; r++) {
			for (c = fcol; c < lcol; c++) {
				if (p = cell[r][c]) {
					move(FRAMEH+r-frow, loc[c]);
					value(stdout, c, p);
				}
			}
		}
	}
	move(0, 0); /* how much free space left */
	n = ((long)freecnt * 100L) / (long)MAXNODE;
	sprintf(linebuf, "%d%%", n);
	outstr(stdout, FRAMEW, LJUST, linebuf);
	move(CURCELL, 0); /* what is the content of current cell */
	clrbelow();
	printf("%c%d: %s", ccol+'a', crow, content(cell[crow][ccol], 0));
	move(FRAMEH+crow-frow, loc[ccol]); /* place cursor */
	reframe = redisp = 0;
}

/* output the value of the cell */

value(fp, c, p) FILE *fp; Cell *p; {
	int i, wid, fmt, jst;
	char *s, *ntoa();
	long n, eval();
	wid = width[c];
	fmt = format[c];
	jst = justify[c];
	if (p == NULL)
		outstr(fp, wid, jst, "");
	else if (p->s.type == STRING)
		outstr(fp, wid, jst, p->s.s);
	else	{
		n = eval(p);
		outstr(fp, wid, jst, ntoa(n, fmt));
	}
}

/* get a line from a file */

rdline(fp, bp) FILE *fp; char *bp; {
	int i, c;
	for (i = 0; (c = getc(fp)) != '\n' && c != EOF; i++)
		if (c >= ' ')
			*bp++ = c;
	*bp = 0;
	return i;
}

/* get a line from the keyboard */

char *
getline(prompt, start) char *prompt, *start; {
	int i, j, n, c, plen, change;
	move(MSG, 0);
	clrline();
	for (plen = 2; *prompt; plen++)
		put(*prompt++);
	ps("? ");
	i = 0;
	if (start) {
		while (linebuf[i] = start[i])
			put(linebuf[i++]);
	}
	n = i;
	while ((c = get()) != '\r') {
		change = 0;
		switch (c) {
		case LEFT:
			if (i) i--;
			break;
		case RIGHT:
			if (i < n) i++;
			break;
		case BACKSP:
			if (i == 0) break;
			i--;
		case DEL:
			if (i == n) break;
			n--;
			for (j = i; j < n; j++)
				linebuf[j] = linebuf[j+1];
			change++;
			break;
		case ESC:
			return NULL;
			break;
		case INS:
			c = ' ';
		default:
			if (c < ' ' || c > DEL) 
				break;
			for (j = n; j > i; j--)
				linebuf[j] = linebuf[j-1];
			n++;
			linebuf[i++] = c;
			change++;
			break;
		}
		if (change) {
			j = (i ? i-1 : 0);
			move(MSG, plen+j);
			while (j < n)
				put(linebuf[j++]);
			put(' ');
		}
		move(MSG, plen+i);
	}
	linebuf[n] = 0;
	return (n ? linebuf : NULL);
}

/* move the cursor, if move goes outside the window, adjust frame */

movecur(c) {
	switch (c) {
	case UP: 
		if (crow) crow--;
		if (crow < frow) {
			frow--;
			reframe++;
		}
		break;
	case DOWN:
		if (crow < MAXROW-1) crow++;
		if (crow >= lrow) {
			frow++;
			reframe++;
		}
		break;
	case LEFT:
		if (ccol) ccol--;
		if (ccol < fcol) {
			fcol--;
			reframe++;
		}
		break;
	case RIGHT:
		if (ccol < MAXCOL-1) ccol++;
		if (ccol >= lcol) {
			fcol++;
			reframe++;
		}
		break;
	}
}

/* time to go */

quit() {
	char *s;
	if (s = getline("quit", "yes")) {
		if (*s == 'y') {
			move(24, 0);
			exit(0);
		}
	}
}

/* expression entry parsing */

char *
next() {
	int c;
	char *s;
	while ((c = *parstr) && c <= ' ')
		parstr++;
	s = tokstr;
	if (alphanum(c)) {
		while (alphanum(*parstr))
			*s++ = *parstr++;
	}
	else	*s++ = *parstr++;
	*s = 0;
	return tokstr;
}

/* create a new node */

Cell *
mkcell(t, a, b, c, d) long a, b, c, d; {
	Node *p;
	if ((p = nextfree) == NULL) {
		move(MSG, 0);
		printf("out of space");
		return &extra;
	}
	else	{
		freecnt--;
		nextfree = p->a;
		p->type = t;
		p->a = a;
		p->b = b;
		p->c = c;
		p->d = d;
		return p;
	}
}

/* parse the string (pointed at by parstr) into an expression tree */

Cell *
parse() {
	char *s;
	Cell *x, *factor(), *tail();
	x = factor();
	s = next();
	x = tail(x, *s);
}

/* more parsing, here we look for operators */

Cell *
tail(x, op) Cell *x; {
	int p;
	char *s;
	Cell *y, *factor();
	while (1) {
		if (!(p = prec(op))) return x;
		y = factor();
		s = next();
		if (prec(*s) > p)
			y = tail(y, *s);
		x = mkcell(op, x, y);
		op = *s;
	}
}

/* return the precedence of the given operator */

prec(op) {
	switch (op) {
		case '+': case '-': return 1;
		case '*': case '/': return 2;
		case '@': return 3;
		default: return 0;
	}
}

/* parse a factor of an expression */

Cell *
factor() {
	char *s;
	int i, c, cr, cc;
	long aton();
	Cell *x, *y;
	if (!(s = next())) 
		return NULL;
	switch (c = *s) {
	case '\'':
		x = mkcell(STRING, 0L, 0L);
		s = x->s.s;
		for (i = 0; i < MAXSTR && (*s++ = *parstr++); i++)
			;
		return x;
	case '-':
		x = factor();
		return mkcell(NEG, x, 0L);
	case '(':
		return parse();
	default:
		if (c >= 'a' && c <= 'z') {
			y = cc = c - 'a';
			x = cr = atoi(s+1);
			return mkcell(
				check(cr, cc) ? CELL : ERR, x, y);
		}
		else if (c >= '0' && c <= '9') {
			x = aton(s);
			return mkcell(VALUE, x, 0);
		}
		else	{
			move(MSG, 0);
			printf("bad factor: %s", s);
			return NULL;
		}
	}
}

/* set the value of a cell */

setvalue(r, c, x) long x; {
	Cell *p;
	if (p = cell[r][c])
		free(p);
	cell[r][c] = x;
}

/* free up all space associated the given pointer */

free(p) Node *p; {
	switch (p->type) {
		case ADD: case SUB: case MUL: case DIV: case SUM:
			free(p->b);
		case NEG:
			free(p->a);
	}
	p->type = FREE;
	p->a = nextfree;
	nextfree = p;
	freecnt++;
}

/* get a filename from the user and load a spreadsheet */

load() {
	char *s;
	if (s = getline("load file", filename)) {
		loadss(s);
	}
}

/* load a spreadsheet file */

loadss(name) char *name; {
	FILE *fp;
	int c;
	char *s;
	strcpy(filename, name);
	if (fp = fopen(name, "r")) {
		init();
		while (rdline(fp, parstr = linebuf)) {
			s = next();
			switch (c = *s) {
			case '=':
				s = next();
				ccol = *s - 'a';
				crow = atoi(s+1);
				if (check(crow, ccol))
					setvalue(crow, ccol, parse());
				break;
			case 'f':
				if (s = next()) {
					c = atoi(s);
					if (s = next())
						width[c] = atoi(s);
					if (s = next())
						format[c] = atoi(s);
					if (s = next())
						justify[c] = *s;
				}
				break;
			}
		}
		reframe = redisp = 1;
		chkframe();
		fclose(fp);
	}
	else	{
		printf(" can't open ", name);
		get();
	}
}

/* save a spreadsheet on a file */

save() {
	int r, c;
	FILE *fp;
	char *name, *content();
	if (name = getline("save file", filename)) {
		strcpy(filename, name);
		fp = fopen(name, "w");
		for (r = 0; r < MAXROW; r++)
			for (c = 0; c < MAXCOL; c++)
				if (cell[r][c]) {
					fprintf(fp, "= %c%d %s\n", 
						c+'a', r, 
						content(cell[r][c], 0));
				}
		for (c = 0; c < MAXCOL; c++)
			if (width[c] != DEFWID || 
                            format[c] != DEFFMT || 
			    justify[c] != DEFJST)
				fprintf(fp, "f %d %d %d %c\n", 
					c, width[c], format[c], justify[c]);
		fclose(fp);
	}
}

/* print a report onto a file */

print() {
	char *s;
	FILE *fp;
	int r, c, trow, tcol, brow, bcol;
	if (!(s = getline("print window", prwin))) return;
	strcpy(prwin, s);
	if (!window(s, &trow, &tcol, &brow, &bcol)) return;
	if (s = getline("file name", NULL)) {
		strcpy(prname, s);
		fp = fopen(s, "w");
		for (r = trow ; r <= brow; r++) {
			for (c = tcol; c <= bcol; c++)
				value(fp, c, cell[r][c]);
			putc('\n', fp);
		}
		fclose(fp);
	}
}

/* prompt for a cell name and move the cursor to that cell */

go() {
	char *p;
	if (p = getline("go to cell", NULL)) {
		if (*p >= 'a' && *p <= 'z') {
			ccol = *p - 'a';
			crow = atoi(p+1);
			if (crow < 0) crow = 0;
			if (crow >= MAXROW) crow = MAXROW-1;
			if (ccol < 0) ccol = 0;
			if (ccol >= MAXCOL) ccol = MAXCOL-1;
			chkframe();
		}
	}
}

chkframe() {
	if (crow < frow || crow >= lrow ||
            ccol < fcol || ccol >= lcol) {
		frow = crow;
		fcol = ccol;
		reframe = 1;
	}
}

/* make a copy of a cell */

Cell *
copyx(p, sr, sc, dr, dc) Node *p; {
	int r, c;
	Cell *x, *y;
	if (p == NULL) return NULL;
	switch (p->type) {
		case ADD: case SUB: case MUL: case DIV: case SUM:
			x = copyx(p->a, sr, sc, dr, dc);
			y = copyx(p->b, sr, sc, dr, dc);
			return mkcell(p->type, x, y);
		case CELL:
			r = p->a - sr + dr;
			c = p->b - sc + dc;
			return mkcell(
				check(r, c) ? CELL : ERR, (long)r, (long)c);
		default:
			return mkcell(p->type, 
				p->a, p->b, p->c, p->d);
	}
}

/* prompt for where to copy to, and then copy it */

copy() {
	char *s;
	Cell *src;
	int r, c, trow, tcol, brow, bcol;
	if (!(s = getline("destination", NULL))) 
		return;
	if (!window(s, &trow, &tcol, &brow, &bcol)) 
		return;
	src = cell[crow][ccol];
	for (r = trow; r <= brow; r++) 
		for (c = tcol; c <= bcol; c++)
			setvalue(r, c, copyx(src, crow, ccol, r, c));
	redisp = 1;
}

/* insert a row or a column */

insert() {
	char *s;
	if (s = getline("insert (row or col)", NULL)) {
		if (*s == 'r')
			insrow();
		else if (*s == 'c')
			inscol();
		else	return;
		reframe = 1;
	}
}

insrow() {
	int r, c;
	Cell *p;
	for (r = MAXROW-2; r >= crow; r--) {
		for (c = 0; c < MAXCOL; c++) {
			p = copyx(cell[r][c], r, c, r+1, c);
			setvalue(r+1, c, p);
		}
	}
	for (c = 0; c < MAXCOL; c++)
		setvalue(crow, c, NULL);
}

inscol() {
	int r, c;
	Cell *p;
	for (c = MAXCOL-2; c >= ccol; c--) {
		width[c+1] = width[c];
		format[c+1] = format[c];
		justify[c+1] = justify[c];
		for (r = 0; r < MAXROW; r++) {
			p = copyx(cell[r][c], r, c, r, c+1);
			setvalue(r, c+1, p);
		}
	}
	width[ccol] = DEFWID;
	format[ccol] = DEFFMT;
	justify[ccol] = DEFJST;
	for (r = 0; r < MAXROW; r++)
		setvalue(r, ccol, NULL);
}

/* delete a row or a column */

delete() {
	char *s;
	if (s = getline("delete (row or col)", NULL)) {
		if (*s == 'r')
			delrow();
		else if (*s == 'c')
			delcol();
		else	return;
		reframe = 1;
	}
}

delrow() {
	int r, c;
	Cell *p;
	for (r = crow; r < MAXROW-2; r++) {
		for (c = 0; c < MAXCOL; c++) {
			p = copyx(cell[r+1][c], r+1, c, r, c);
			setvalue(r, c, p);
		}
	}
}

delcol() {
	int r, c;
	Cell *p;
	for (c = ccol; c < MAXCOL-2; c++) {
		width[c] = width[c+1];
		format[c] = format[c+1];
		justify[c] = justify[c+1];
		for (r = 0; r < MAXROW; r++) {
			p = copyx(cell[r][c+1], r, c+1, r, c);
			setvalue(r, c, p);
		}
	}
}

/* enter a new expression into the cell */

enter(c) {
	char str[2];
	if (c != '=')
		sprintf(str, "%c", c);
	else	*str = 0;
	if (parstr = getline("enter", str)) {
		setvalue(crow, ccol, parse());
		redisp = 1;
	}
}

/* fill the line buffer with the (unevaluated) contents of the cell */

char *
content(p, cp) Cell *p; {
	*linebuf = 0;
	showx(p, cp);
	return linebuf;
}

/* recursive support routine for content() */

showx(p, cp) Node *p; {
	int op, np;
	char *ntoa();
	if (p == NULL) return;
	switch (op = p->type) {
	case ERR:
		sprintf(showbuf, "ERR");
		break;
	case FREE: 
		sprintf(showbuf, "FREE");
		break;
	case STRING: 
		sprintf(showbuf, "'%s", ((String *)p)->s);
		break;
	case CELL: 
		sprintf(showbuf, "%c%d", (short) (p->b + 'a'), (short) p->a); 
		break;
	case VALUE: 
		sprintf(showbuf, "%s", ntoa(p->a, 2));
		break;
	case ADD: case SUB: case MUL: case DIV: case SUM:
		np = prec(op);
		if (np < cp)
			strcat(linebuf, "(");
		showx(p->a, np);
		sprintf(linebuf, "%s%c", linebuf, p->type);
		showx(p->b, np);
		if (np < cp)
			strcat(linebuf, ")");
		*showbuf = 0;
		break;
	case NEG: 
		strcat(linebuf, "-");
		showx(p->a, cp); 
		*showbuf = 0;
		break;
	default:
		sprintf(showbuf, "ERR%d", p->type);
		break;
	}
	strcat(linebuf, showbuf);
}

/* erase the current cell */

blank() {
	char *s;
	if (s = getline("blank this cell", "yes")) {
		if (*s == 'y') {
			setvalue(crow, ccol, NULL);
			move(FRAMEH+crow-frow, loc[ccol]);
			outstr(stdout, width[ccol], LJUST, "");
		}
	}
}

/* edit the contents of the current cell */

edit() {
	char *s;
	s = content(cell[crow][ccol], 0);
	if (parstr = getline("edit", s)) {
		setvalue(crow, ccol, parse());
		redisp = 1;
	}
}

/* prompt for new column formats and change them */

setformat() {
	char *s;
	int w;
	sprintf(linebuf, "%d", format[ccol]);
	if (s = getline("fixed decimal", linebuf)) {
		w = atoi(s);
		format[ccol] = (w > 2 ? 2 : w);
		redisp = 1;
	}
	sprintf(linebuf, "%d", width[ccol]);
	if (s = getline("column width", linebuf)) {
		w = atoi(s);
		width[ccol] = (w < 2 ? 2 : w);
		reframe = 1;
	}
	sprintf(linebuf, "%c", justify[ccol]);
	if (s = getline("left or right justify", linebuf)) {
		if (*s == 'l' || *s == 'r') {
			justify[ccol] = *s;
			reframe = 1;
		}
	}
}

/* display a help message */

help() { 
	move(MSG, 0);
  printf("cell entry: type \"= expr\" or \"'label\" ");
  	move(MSG+1, 0);
	printf(
  "commands: blank copy delete edit format goto insert load print quit save");
	get();
}

/* evaluate a cell entry */

long
eval(p) Node *p; {
	int x, y;
	long a, b, sum();
	if (p == NULL) return 0L;
	switch (p->type) {
	case FREE: case STRING: case ERR:
		return 0L;
	case VALUE:
		return p->a;
	case CELL:
		x = p->a;
		y = p->b;
		return eval(cell[x][y]);
	case SUM:
		return sum(p->a, p->b);
		break;
	case ADD:
		a = eval(p->a);
		b = eval(p->b);
		return a+b;
	case SUB:
		a = eval(p->a);
		b = eval(p->b);
		return a-b;
	case MUL:
		a = eval(p->a);
		b = eval(p->b);
		return (a*b)/100;
	case DIV:
		a = eval(p->a);
		b = eval(p->b);
		return (a*100)/b;
	case NEG:
		a = eval(p->a);
		return -a;
	}
}

long
sum(lp, rp) Node *lp, *rp; {
	long n;
	int br, bc, er, ec, r, c;
	n = 0L;
	if (lp->type == CELL && rp->type == CELL) {
		br = lp->a;
		bc = lp->b;
		er = rp->a;
		ec = rp->b;
		for (r = br; r <= er; r++)
			for (c = bc; c <= ec; c++)
				n += eval(cell[r][c]);
	}
	return n;
}

/* parse a window definition, e.g. "a0.z99" */

window(s, tr, tc, br, bc) char *s; int *tr, *tc, *br, *bc; {
	*tc = *s - 'a';
	*tr = atoi(s+1);
	while (*s && *s++ != '.')
		;
	if (*s) {
		*bc = *s - 'a';
		*br = atoi(s+1);
	}
	else	{
		*bc = *tc;
		*br = *tr;
	}
	return check(*tr, *tc) && check(*br, *bc);
}

/* range check on a row and column */

check(r, c) { return r >= 0 && r < MAXROW && c >= 0 && c < MAXCOL; }

/* convert a string to an integer */

atoi(s) char *s; {
	int n, c;
	if (s == NULL) return 0;
	for (n = 0; isdig(c = *s++); )
		n = n * 10 + c - '0';
	return n;
}

/* convert a string to a "fixed point" number (i.e. "123.45") */

long
aton(s) char *s; {
	int c, i;
	long n;
	n = 0L;
	if (s == NULL) return 0L;
	for (n = 0; isdig(c = *s++); )
		n = n * 10 + (c - '0');
	if (c == '.') c = *s++;
	for (i = 0; i < 2; i++) {
		n = n * 10;
		if (isdig(c)) {
			n = n + (c - '0');
			c = *s++;
		}
	}
	return n;
}

/* check the types of the characters */

isdig(c) { return c >= '0' && c <= '9'; }

alphanum(c) {
	if (c >= 'a' && c <= 'z') return 1;
	if (c >= 'A' && c <= 'Z') return 1;
	if (c == '.') return 1;
	return isdig(c);
}

/* convert the fixed point number back to a string */

char *
ntoa(n, fmt) long n; {
	int i, neg;
	if (neg = n < 0)
		n = -n;
	i = 16;
	linebuf[--i] = 0;
	do	{
		linebuf[--i] = n % 10 + '0';
		n = n / 10;
		if (i == 13) linebuf[--i] = '.';
		} while (n);
	while (i > 11) {
		if (i == 13) linebuf[--i] = '.';
		else linebuf[--i] = '0';
	}
	if (fmt == 0) 
		linebuf[12] = 0;
	else if (fmt == 1) 
		linebuf[14] = 0;
	if (neg) linebuf[--i] = '-';
	return &linebuf[i];
}

/* output a string of width n to the stream fp */

outstr(fp, wid, jst, s) FILE *fp; char *s; {
	int i;
	if (jst == RJUST) {
		for (i = 0; s[i]; i++)
			;
		for ( ; i < wid; i++)
			putc(' ', fp);
	}
	for (i = 0; i < wid && *s; i++)
		putc(*s++, fp);
	if (jst == LJUST) {
		for ( ; i < wid; i++)
			putc(' ', fp);
	}
}

/*  keyboard input and screen output/control */

get() {
	long c;
	c = trap(1, 7);
	if (c & 0xFF) 
		return (short)c; /* ascii character */
	else 	return (short)(c >> 8); /* scan code */
}

move(row, col) { put(ESC); put('Y'); put(row+' '); put(col+' '); }

erase() { put(ESC); put('E'); }

clrline() { put(ESC); put('K'); }

clrbelow() { put(ESC); put('J'); }
	
reverse(on) { put(ESC); put(on ? 'p' : 'q'); }

put(c) { trap(1, 2, c); }

ps(s) char *s; { while (*s) put(*s++); }
