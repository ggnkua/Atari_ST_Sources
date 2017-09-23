/* 
 * simple make program 
 *
 *	make [options] [targets]
 *
 *	options are
 *		-i		ignore non-zero program returns
 *		-f file		makefile name (default is "makefile")
 *		-n		don't execute any commands
 *		-t		just touch the targets, don't build 
 *		-r		ignore built-in rules
 *		-d		debug flag (noisy output)
 *		-h		hold the screen
 *
 * this program reads a makefile to build the named targets
 * a makefile contains rules, macro definitions, or dependencies
 * an example makefile might be:
 *
 * 	# this is a sample makefile for a spreadsheet
 * 	OBJ = main.s io.s calc.s
 * 	ss: $(OBJ) ss.h
 *		d:as.ttp d:ttp.s $(OBJ) -L d:lib.a
 *
 * there are built-in rules to convert .c to .s, .c to .ttp, and .c to .prg
 */

#include <stdio.h>

#define MAXLINE	160
#define MAXSYM	100
#define MAXRULE	30
#define MAXARG	75

#define TIME	0x2C
#define DATE	0x2A
#define EXEC	0x4B
#define RENAME	0x56
#define GSDTOF	0x57
#define SETDRV	0x0E
#define GETDRV	0x19
#define GETDSK	0x36
#define MALLOC	0x48

typedef struct x0 {		/* structure for command lists		*/
	char *cmd;		/*	pointer to the command line	*/
	struct x0 *next;	/*	pointer to the next one		*/
} Command;

typedef struct x1 {		/* structure for dependencies		*/
	int	dep;		/*	name of a parent		*/
	struct x1 *next;	/*	pointer to next parent		*/
} Depend;

typedef struct {		/* structure for rules			*/
	int 	from;		/*	the extension of the parent	*/
	int	to;		/*	the extension of the child	*/
	Command	*cmd;		/* 	the commands to make the child	*/
} Rule;

FILE	*in;			/* makefile input file handle		*/
int	eof;			/* eof flag for makefile input stream	*/
int	no_exec = 0;		/* don't execute the commands		*/
int	debug = 0;		/* debug output flag			*/
int	ignore = 0;		/* ignore non-zero returns		*/
int	norules = 0;		/* no built-in rules			*/
int	hold = 1;		/* hold the screen (for GEM users	*/
char 	line[MAXLINE];		/* buffer containing current input line	*/
char	extra[MAXLINE];		/* extra buffer for macro expansion	*/
char	name[MAXLINE];		/* space for making up names		*/
char 	*macro[MAXSYM];		/* pointer to the macros		*/
char 	*sym[MAXSYM];		/* pointer to the symbol names		*/
Depend	*depend[MAXSYM];	/* pointer to dependencies		*/
Command	*command[MAXSYM];	/* index into commands			*/
Rule	rules[MAXRULE];		/* rules				*/
int	lrule = 0;		/* last rule used			*/
int	firstsym = -1;		/* what's first dependency declared	*/
char	base[MAXLINE];		/* buffer for '*' macro			*/
char	target[MAXLINE];	/* buffer for '@' macro			*/

char 	*save();		/* save a string			*/
char	*alloc();		/* allocate space			*/
Command	*cmdlist();		/* make up a command list		*/
Command *add_cmd();		/* add a command to a command list	*/
long	date();			/* get the date of a file		*/

char	*av[MAXARG];		/* argv for built-in's			*/
int	ac;			/* argc for built-in's			*/
FILE	*xin;			/* stdin for built-in commands		*/
FILE	*xout;			/* stdout for built-in commands		*/

main(argc, argv) char *argv[]; {
	int i, err, tch;
	char *name;
	i = 1;
	name = "makefile";
	tch = err = 0;
	for (i = 1; i < argc && *argv[i] == '-'; i++) {
		switch (argv[i][1]) {
		case 'f': case 'F':
			i++;
			name = argv[i];
			break;
		case 'i': case 'I':
			ignore = 1;
			break;
		case 'd': case 'D':
			debug = 1;
			break;
		case 't': case 'T':
			tch = 1;
			break;
		case 'n': case 'N':
			no_exec = 1;
			break;
		case 'r': case 'R':
			norules = 1;
			break;
		case 'h': case 'H':
			hold = !hold;
			break;
		default:
			printf("unknown option: %s\n", argv[i]);
			err = 1;
			break;
		}
	}
	if (err) error("usage: make [-i -n -t -r -d -h -f file] [targets]\n");
	if (tch) {
		while (i < argc)
			touch(argv[i++]);
	}
	else	{
		init();
		input(name);
		if (i == argc && firstsym >= 0)
			make(firstsym);
		else	{
			for ( ; i < argc; i++)
				if (!assign(argv[i]))
					make(lookup(argv[i]));
		}
	}
	bye(0);
}

/* initialize the symbol table and add built-in rules */

init() {
	int i;
	Command *cp;
	rules[0].cmd = NULL;
	for (i = 0; i < MAXSYM; i++)
		sym[i] = NULL;
	if (norules) return;
    /* built-in rules */
    cp = NULL;
    cp = add_cmd(cp, " d:\\cc.ttp $*.c");
    cp = add_cmd(cp, " d:\\as.ttp -o $*.ttp d:\\ttp.s yc.out -L d:\\lib.a");
    cp = add_cmd(cp, " rm yc.out");
    add_rule(".c", ".ttp", cp);
    cp = NULL;
    cp = add_cmd(cp, " d:\\cc.ttp $*.c");
    cp = add_cmd(cp, 
	" d:\\as.ttp -o $*.prg d:\\prg.s yc.out -L d:\\gem.a d:\\lib.a");
    cp = add_cmd(cp, " rm yc.out");
    add_rule(".c", ".prg", cp);
    cp = NULL;
    cp = add_cmd(cp, " d:\\cc.ttp -o $*.s $*.c");
    add_rule(".c", ".s", cp);
}

/* read in and parse the makefile */

input(name) char *name; {
	if (!findfile(name))
		return;
	getline();
	while (!eof) {
		if (*line == '#')
			getline();
		else if (macdef())
			getline();
		else if (*line == '.')
			rule();
		else if (*line > ' ')
			dependency();
		else	getline();
	}
	fclose(in);
}

/* search high and low for a makefile */

findfile(name) char *name; {
	int i, drv, r;
	/* someday, turn a full pathname into a chdir */
	if (in = fopen(name, "r")) /* try current directory first */
		return 1;
	drv = trap(1, GETDRV);
	for (i = 0; i < 4; i++) { /* try A:, B:, C:, D: */
		r = trap(1, SETDRV, i);
		if (in = fopen(name, "r")) {
			printf("  run from %c:\n", i + 'A');
			return 1;
		}
	}
	trap(1, SETDRV, drv);
	return 0;
}

/* read in a line from the makefile */

getline() {
	int c;
	char *l;
	l = line;
	c = getch();
	while (c != EOF && c != '\n') {
		if (c == '\\') {
			if ((c = getch()) == '\n')
				c = ' ';
			else	*l++ = '\\';
		}
		*l++ = c;
		if (c <= ' ') { /* skip spaces */
			while (c != EOF && c != '\n' && c <= ' ')
				c = getch();
		}
		else	c = getch();
	}
	*l = 0;
	eof = (c == EOF);
}

/* get a character from the file, strip out '\r' */

getch() {
	int c;
	while ((c = getc(in)) == '\r')
		;
	return c;
}

/* expand all the macro's in the current line */

expand() { 
	int done;
	char *e, *l, *m;
	while (1) {
		e = extra;
		l = line;
		done = 1;
		while (*e++ = *l++)
			if (*l == '$') 
				done = 0;
		if (done) 
			break;
		e = extra;
		l = line;
		while (*e) {
			if (*e == '$') {
				e++;
				m = name;
				if (*e == '(') { /* multi letter macro */
					e++;
					while (*e != ')') 
						*m++ = *e++;
					e++;
				}
				else	*m++ = *e++; /* one letter macro */
				*m = 0;
				if (m = macro[lookup(name)]) {
					while (*m) 
						*l++ = *m++;
				}
				else	error("$(%s) not defined", name);
			}
			else	*l++ = *e++;
		}
		*l = 0;
	}
}

/* read in a rule, ".from.to:" followed by command lines */

rule() {
	int i, j;
	char to[10], from[10], *l;
	l = line;
	i = j = 0;
	if (*l != '.') 
		error("bad rule entry");
	do { from[j++] = *l++; } while (*l && *l != '.');
	from[j] = 0;
	if (*l != '.') 
		error("bad rule entry");
	j = 0;
	do { to[j++] = *l++; } while (*l && *l != ':');
	to[j] = 0;
	add_rule(from, to, cmdlist());
}

/* build a list of commands, return pointer to them */

Command *
cmdlist() {
	Command *r;
	r = NULL;
	getline();
	while (*line && *line <= ' ') {
		r = add_cmd(r, save(line));
		getline();
	}
	return r;
}

/* check for a command line macro def and process if there */

assign(s) char *s; {
	char *p;
	for (p = s; *p && *p != '='; p++)
		;
	if (*p == '=') {
		*p++ = 0;
		add_mac(s, save(p));
		return 1;
	}
	else	return 0;
}

/* check for a macro def and process if there */

macdef() { 
	char *l, *b, *e;
	l = line;
	while (*l && *l <= ' ')	l++;
	b = l;
	while (*l && *l > ' ') 	l++;
	e = l;
	while (*l && *l <= ' ') l++;
	if (*l++ == '=') { /* got a macro */
		*e = 0;
		add_mac(b, save(l));
		return 1;
	}
	else	return 0;
}

/* parse a dependency, "child [children]*: [parents]*" */

dependency() {
	int i, j, target[20], depend[20];
	Command *cmd;
	expand();
	i = namelist(target, 0);
	if (line[i] != ':')
		error("bad dependency rule");
	i = namelist(depend, i+1);
	cmd = cmdlist();
	for (i = 0; target[i]; i++) {
		for (j = 0; depend[j]; j++)
			add_dep(target[i], depend[j]);
		set_cmd(target[i], cmd);
	}
	if (firstsym < 0) 
		firstsym = target[0];
}

/* gather up a list of names in the input line */

namelist(list, i) int *list; {
	int t, j;
	t = 0;
	while (line[i] && line[i] != ':') {
		while (line[i] && line[i] <= ' ') 
			i++;
		j = 0;
		if (line[i]) {
			while (line[i] && line[i] > ' ' && line[i] != ':')
				name[j++] = line[i++];
			name[j] = 0;
			list[t++] = lookup(name);
		}
	}
	list[t] = 0;
	return i;
}

/* add a new command to the end of a command list */

Command *
add_cmd(cp, cmd) Command *cp; char *cmd; {
	Command *p, *r;
	p = alloc((short)sizeof(Command));
	p->cmd = cmd;
	p->next = NULL;
	if (cp == NULL)
		r = p;
	else 	{
		r = cp;
		while (cp->next)
			cp = cp->next;
		cp->next = p;
	}
	return r;
}

/* add a parent (target) to a child (dependency) */

add_dep(target, dep) {
	Depend *p;
	if (debug) printf("add_dep(%s,%s)\n", sym[target], sym[dep]);
	p = alloc((short)sizeof(Depend));
	p->dep = dep;
	p->next = depend[target];
	depend[target] = p;
}

/* add a macro */

add_mac(name, str) char *name, *str; {
	if (debug) printf("add_mac(%s,%s)\n", name, str);
	macro[lookup(name)] = str;
}

/* add a command list to a target */

set_cmd(target, cp) Command *cp; {
	if (debug) printf("set_cmd(%s,%lx)\n", sym[target], cp);
	command[target] = cp;
}

/* add a rule */

add_rule(from, to, cp) char *from, *to; Command *cp; {
	if (debug) printf("add_rule(%s,%s,%lx)\n", from, to, cp);
	rules[lrule].from = lookup(from);
	rules[lrule].to = lookup(to);
	rules[lrule].cmd = cp;
	if (++lrule >= MAXRULE)
		error("too many rules");
	rules[lrule].cmd = NULL;
}

/* build a child by first building the parents */

make(child) {
	int mkflag;
	long chdate;
	Command *cp;
	Depend *dp;

	if (debug) printf("make(%s)\n", sym[child]);
	chdate = date(sym[child]);
	mkflag = 0;

	if (dp = depend[child]) {
		while (dp) {
			make(dp->dep);
			if (check(dp->dep, chdate))
				mkflag = 1;
			dp = dp->next;
		}
	}
	else	mkflag = 1;

	if (mkflag) {
		strcpy(target, sym[child]);
		add_mac("@", target);
		if (cp = command[child]) {
			unlink(target);
			execute(cp);
		}
		else	chkrule(child, chdate);
	}
}

/* set the date/time of the named file to the present */

touch(name) char *name; {
	int fd, r;
	long dt;
	if ((fd = open(name, 2)) >= 0) {
		dt = (trap(1, DATE) && 0xFFFF) | (trap(1, TIME) << 16);
		if (r = trap(1, GSDTOF, &dt, fd, 1))
			perror(r, name);
		close(fd);
	}
	else	error("cannot open %s (%d)\n", name, fd);
}

/* get the date/time of the named file */

long
date(name) char *name; {
	int fd;
	unsigned long dt;
	if ((fd = open(name, 0)) >= 0) {
		trap(1, GSDTOF, &dt, fd, 0);
		dt = ((dt >> 16) & 0xFFFFL) | (dt << 16); /* swap words */
		close(fd);
	}
	else	dt = 0L;
	if (debug) printf("date of %s is %lx\n", name, dt);
	return dt;
}

/* compare the date/time of the named file against the child date */

check(parent, chdt) long chdt; {
	long pardt;
	pardt = date(sym[parent]);
	return (pardt > chdt);
}

/* see if there are any rules that we can use to build the child */

chkrule(child, chdate) long chdate; {
	Rule *r;
	char *s, *e;
	int i, j, ext, parent, parbase;
	s = sym[child];
	for (j = i = 0; base[i] = s[i]; i++)
		if (s[i] == '.') 
			j = i;
	if (j == 0) 
		return 0;
	e = &s[j];
	base[j] = 0;
	parbase = lookup(base);
	ext = lookup(e);
	for (i = lrule; --i >= 0; ) {
		r = &rules[i];
		if (r->to == ext) {
			strcpy(extra, base);
			strcat(extra, sym[r->from]);
			parent = lookup(extra);
			make(parent);
			add_mac("*", sym[parbase]); 
			if (check(parent, chdate)) {
				unlink(sym[child]);
				execute(r->cmd);
				return;
			}
		}
	}
}

/* execute a list of commands */

execute(cp) Command *cp; {
	int r;
	while (cp) {
		strcpy(line, cp->cmd);
		expand();
		printf("  %s\n", line);
		if (!no_exec && (r = system(line)) && !ignore)
			perror(r, "command failed");
		cp = cp->next;
	}
}

/* do something, either built-in (rm, mv) or exec a program */

args(s) char *s; { /* built and argc, argv for the built-in's */
	char *strtok();
	ac = 1;
	s = strtok(s, " \t");
	xin = stdin;
	xout = stdout;
	while (ac < MAXARG && s != NULL) {
		if (*s == '>') {
			if (s[1] == '>')
				xout = fopen(s+2, "a");
			else	xout = fopen(s+1, "w");
		}
		else if (*s == '<')
			xin = fopen(s+1, "r");
		else	av[ac++] = s;
		s = strtok(NULL, " \t");
	}
	av[ac] = NULL;
}

rm() { /* remove a file */
	int i, r, rr;
	rr = 0;
	for (i = 1; i < ac; i++) {
		if ((r = unlink(av[i])) != 0 && r != -33) {
			/* not deleted but was found */
			perror(r, av[i]);
			rr = r;
		}
	}
	return rr;
}

mv() { /* rename a file */
	int r;
	if (ac == 3) {
		unlink(av[2]);
		if (r = trap(1, RENAME, 0, av[1], av[2])) {
			printf("rename didn't work (%d), try copy\n", r);
			if ((r = cp()) == 0)
				unlink(av[1]);
		}
	}
	return r;
}

cp() { /* copy a file */
	int r;
	FILE *in, *out;
	r = 1;
	if (ac == 3) {
		if (in = fopen(av[1], "rb")) {
			if (out = fopen(av[2], "wb")) {
				xcat(in, out);
				r = 0;
				fclose(in);
				fclose(out);
			}
			else	error("cannot create %s\n", av[2]);
			fclose(in);
		}
		else	error("cannot copy %s\n", av[1]);
	}
	return r;
}

cat() { /* cat a file */
	int i, r;
	FILE *in;
	r = 0;
	for (i = 1; i < ac; i++) {
		if ((in = fopen(av[i], "r")) == NULL) {
			r = 1;
			error("cannot cat %s", av[i]);
		}
		else	xcat(in, xout);
	}
	return r;
}

xcat(i, o) FILE *i, *o; { /* do the real work of cat */
	int c;
	while ((c = getc(i)) != EOF)
		putc(c, o);
	fclose(i);
}

grep() {
	int i;
	char *p, *fgets();
	FILE *in, *fopen();
	strlower(p = av[1]);
	for (i = 2; i < ac; i++) {
		if (in = fopen(av[i], "r")) {
			while (fgets(extra, MAXLINE, in)) {
				strlower(extra);
				if (match(p, extra))
					printf("%s:\t%s", av[i], extra);
			}
			fclose(in);
		}
		else	printf("cannot open %s\n", av[i]);
	}
	return 0;
}

match(pat, line) char *pat, *line; {
	char *p, *l;
	while (*line) {
		p = pat;
		l = line++;
		while (*p++ == *l++)
			if (*p == 0)
				return 1;
	}
	return 0;
}

xfree() {
	long m, dsz[4];
	int c, drv;
	if (ac > 1 && (c = *av[1]) >= 'A' && c <= 'P')
		drv = c - 'A';
	else	drv = trap(1, GETDRV);
	trap(1, GETDSK, dsz, drv + 1);
	m = trap(1, MALLOC, -1L);
	printf("%ld free bytes in memory, ", m);
	printf("%ld free bytes on %c:\n", dsz[0]*dsz[2]*dsz[3], drv+'A');
	return 0;
}

struct bltin {
	char *name;
	int (*func)();
} btbl[] = {
	{ "rm", rm },
	{ "mv", mv },
	{ "cp", cp },
	{ "cat", cat },
	{ "grep", grep },
	{ "free", xfree },
	{ NULL, NULL }
};

system(s) char *s; {
	int i, r;
	char *p;
	while (*s && *s <= ' ') 
		s++;
	for (p = extra; *s && *s > ' '; )
		*p++ = *s++;
	*p = 0;
	for (i = 0; btbl[i].name != NULL; i++) {
		if (strcmp(extra, btbl[i].name) == 0) {
			args(s);
			r = (*btbl[i].func)();
			if (xin != stdin) 
				fclose(xin);
			if (xout != stdout) 
				fclose(xout);
			return r;
		}
	}
	if ((r = strlen(s+1)) >= 128)
		error("command line too long");
	else	{
		*s = r;
		r = trap(1, EXEC, 0, extra, s, "");
	}
	return r;
}

/* symbol table lookup */

lookup(s) char *s; {
	int i, start;
	upper(s); /* too bad TOS filenames are always uppercase */
	start = i = *s;
	while (sym[i]) {
		if (strcmp(s, sym[i]) == 0)
			return i;
		if (++i >= MAXSYM) 
			i = 0;
		if (i == start)
			error("too many symbols");
	}
	sym[i] = save(s);
	command[i] = macro[i] = depend[i] = 0L;
	return i;
}

/* convert a string to all uppercase in place */

upper(s) char *s; {
	register int c;
	for ( ; c = *s; s++) {
		if (c >= 'a' && c <= 'z')
			*s = c - 'a' + 'A';
	}
}

/* save a string */

char *
save(s) char *s; {
	char *r, *alloc();
	r = alloc(strlen(s)+1);
	strcpy(r, s);
	return r;
}

/* allocate some space */

char *
alloc(n) {
	char *r, *malloc();
	if ((r = malloc(n)) == NULL)
		error("out of free space");
	return r;
}

bye(n) {
	if (hold) {
		printf("(press any char)\n");
		getchar();
	}
	exit(n);
}

perror(r, s) char *s; {
	char *p;
	switch (r) {
	case -32: p = "invalid function number"; break;
	case -33: p = "file not found"; break;
	case -34: p = "pathname not found"; break;
	case -35: p = "too many open files"; break;
	case -36: p = "access not possible"; break;
	case -37: p = "invalid handle"; break;
	case -39: p = "not enough memory"; break;
	case -46: p = "invalid drive spec"; break;
	case -49: p = "no more files"; break;
	default: sprintf(p = extra, "error %d", r);
	}
	error("%s: %s", p, s);
}

/* complain and get out */

error(s, a, b, c, d) char *s; long a, b, c, d; {
	printf("** ");
	printf(s, a, b, c, d);
	printf("\n");
	bye(1);
}
