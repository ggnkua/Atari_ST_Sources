/*
 * (c) copyright 1988 by the Vrije Universiteit, Amsterdam, The Netherlands.
 * See the copyright notice in the file "../Copyright".
 */
/*	Driver for Minix compilers.
	Written june 1987 by Ceriel J.H. Jacobs, partly derived from old
	cc-driver, written by Erik Baalbergen.
	This driver is mostly table-driven, the table being in the form of
	some global initialized structures.
*/
	
#include <sys/types.h>
#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>

/*
 * For all program paths (so not the other files, like libraries) that
 * start with "/usr/" and are executable according to access(..., 1),
 * the leading "/usr" is stripped off.
 */

#define SHELL		"/bin/sh"

#define AS		"/usr/bin/as"
#define CEM		"/usr/lib/cem"
#define CG		"/usr/lib/cg"
#define PP		"/usr/lib/cpp"
#define CRT		"/usr/lib/crtso.o"
#define CV		"/usr/lib/cv"
#define PC		"/usr/lib/em_pc"
#define END		"/usr/lib/end.o"
#define LD		"/usr/lib/ld"
#define LIBC		"/usr/lib/libc.a"
#define LIBP		"/usr/lib/libp.a"
#define OPT		"/usr/lib/opt"
#define PRT		"/usr/lib/prtso.o"
#define LIBPREFIX	"/usr/lib/lib"

#define PEM		"-R/usr/lib/pem"
#define PC_ERR		"-r/usr/lib/pc_errors"

/*	every pass that this program knows about has associated with it
	a structure, containing such information as its name, where it
	resides, the flags it accepts, and the like.
*/
struct passinfo {
	char *p_name;		/* name of this pass */
	char *p_path;		/* where is it */
	char *p_from;		/* suffix of source (comma-separated list) */
	char *p_to;		/* suffix of destination */
	char *p_acceptflags;	/* comma separated list; format:
			   		flag
			   		flag*
			   		flag=xxx
					flag*=xxx[*]
				   where a star matches a, possibly empty, 
				   string
				*/
	int  p_flags;
#define INPUT	01		/* needs input file as argument */
#define OUTPUT	02		/* needs output file as argument */
#define LOADER	04		/* this pass is the loader */
#define STDIN	010		/* reads from standard input */
#define STDOUT	020		/* writes on standard output */
#define SOURCE	040		/* give source file name as last argument
				   (hack for pc)
				*/
#define O_OUTPUT 0100		/* -o outputfile, hack for as */
#define PREPALWAYS	0200	/* always to be preprocessed */
#define PREPCOND	0400	/* preprocessed when starting with '#' */
};

#define MAXHEAD	7
#define MAXTAIL	4
#define MAXPASS	7

/*	Every language handled by this program has a "compile" structure
	associated with it, describing the start-suffix, how the driver for
	this language is called, which passes must be called, which flags
	and arguments must be passed to these passes, etc.
	The language is determined by the suffix of the argument program.
	However, if this suffix does not determine a language (DEFLANG),
	the callname is used.
	Notice that the 's' suffix does not determine a language, because
	the input file could have been derived from f.i. a C-program.
	So, if you use "cc x.s", the C-runtime system will be used, but if
	you use "as x.s", it will not.
*/
struct compile {
	char *c_suffix;		/* starting suffix of this list of passes */
	char *c_callname;	/* affects runtime system loaded with program */
	struct pass {
		char *pp_name;		/* name of the pass */
		char *pp_head[MAXHEAD];	/* args in front of filename */
		char *pp_tail[MAXTAIL];	/* args after filename */
	} c_passes[MAXPASS];
	int  c_flags;
#define DEFLANG		010	/* this suffix determines a language */
};

struct passinfo passinfo[] = {
	{ "cpp", PP, 0, "i", "I*,D*,U*", INPUT|STDOUT },
	{ "cem", CEM, "i,c", "k", "R,p,w,T*,I*,D*,U*", INPUT|OUTPUT },
	{ "pc", PC, "i,p", "k", "L,p,w,e,E,T*,{*", INPUT|OUTPUT|SOURCE|PREPCOND },
	{ "opt", OPT, "k", "m", "LIB=L", STDIN|STDOUT },
	{ "cg", CG, "m", "s", "O=p4", INPUT|OUTPUT },
	{ "as", AS, "i,s", "o", "T*", INPUT|O_OUTPUT|PREPCOND },
	{ "ld", LD, "o", "out", "r,s", INPUT|LOADER },
	{ "cv", CV, "out", 0, "", INPUT|OUTPUT },	/* must come after loader */
	{ 0}
};

struct compile passes[] = {
{	"c", "cc", 
	{	{ "cem", {"-L"}, {0} },
		{ "opt", {0}, {0} },
		{ "cg", {0}, {0} },
		{ "as", {"-"}, {0} },
		{ "ld", {"-c", "-a0:2", "-a1:2", "-a2:2", "-a3:2", CRT}, 
			  {LIBC, END}},
		{ "cv", {0}, {0} }
	},
	DEFLANG
},
{	"p", "pc",
	{	{ "pc", { PEM, PC_ERR, "-Vw2i2j2p2f8l4" }, {0} },
		{ "opt", {0}, {0} },
		{ "cg", {0}, {0} },
		{ "as", {"-"}, {0} },
		{ "ld", {"-c", "-a0:2", "-a1:2", "-a2:2", "-a3:2", PRT}, 
			  {LIBP, LIBC,
			   END}},
		{ "cv", {0}, {0} }
	},
	DEFLANG
},
{	"s", "as",
	{	{ "as", {0}, {0}}}, 0 },
{	0}
};

#define MAXARGC	128	/* maximum number of arguments allowed in a list */
#define USTR_SIZE	64	/* maximum length of string variable */

typedef char USTRING[USTR_SIZE];

struct arglist {
	int al_argc;
	char *al_argv[MAXARGC];
};

struct arglist CALLVEC[2];

int kids[] = {-1, -1};

char *o_FILE = "a.out"; /* default name for executable file */

#define init(a)		((a)->al_argc = 1)
#define cleanup(str)		{if ((char *)str != (char *)NULL) remove(str);}
#define library(nm) \
	mkstr(alloc((unsigned int)strlen(nm) + strlen(LIBPREFIX) + 7), \
		LIBPREFIX, nm, ".a")

char *ProgCall = 0;

int RET_CODE = 0;

char *stopsuffix;
int v_flag = 0;
int t_flag = 0;
int noexec = 0;

USTRING curfil;
USTRING newfil;
struct arglist SRCFILES;
struct arglist LDFILES;
struct arglist GEN_LDFILES;
struct arglist FLAGS;

char *tmpdir = "/tmp";
char tmpname[64];

struct compile *compbase;
struct pass *loader;
struct passinfo *loaderinfo;
char *source;

_PROTOTYPE(void trapcc, (int sig));
_PROTOTYPE(int main, (int argc, char *argv []));
_PROTOTYPE(void remove, (char *str));
_PROTOTYPE(char *alloc, (unsigned u));
_PROTOTYPE(void append, (struct arglist *al, char *arg));
_PROTOTYPE(void concat, (struct arglist *al1, struct arglist *al2));
_PROTOTYPE(char *mkstr, (char *dst, char *arg1, char *arg2, char *arg3));
_PROTOTYPE(void basename, (char *str, char *dst));
_PROTOTYPE(char *extension, (char *fln));
_PROTOTYPE(int runvec, (struct arglist *vec, struct passinfo *pass, char *in, char *out));
_PROTOTYPE(void prs, (char *str));
_PROTOTYPE(void panic, (char *str));
_PROTOTYPE(void pr_vec, (struct arglist *vec));
_PROTOTYPE(void ex_vec, (struct arglist *vec));
_PROTOTYPE(void mktempname, (char *nm));
_PROTOTYPE(void mkbase, (void));
_PROTOTYPE(void mkloader, (void));
_PROTOTYPE(int needsprep, (char *name));
_PROTOTYPE(char *apply, (struct passinfo *pinf, struct compile *cp, char *name, int passindex, int noremove, int first, char *resultname));
_PROTOTYPE(int applicable, (struct passinfo *pinf, char *suffix));
_PROTOTYPE(char *process, (char *name, int noremove));
_PROTOTYPE(void mkvec, (struct arglist *call, char *in, char *out, struct pass *pass, struct passinfo *pinf));
_PROTOTYPE(void callld, (struct arglist *in, char *out, struct pass *pass, struct passinfo *pinf));
_PROTOTYPE(void clean, (struct arglist *c));
_PROTOTYPE(void scanflags, (struct arglist *call, struct passinfo *pinf));

void trapcc(sig)
	int sig;
{
	signal(sig, SIG_IGN);
	if (kids[0] != -1) kill(kids[0], sig);
	if (kids[1] != -1) kill(kids[1], sig);
	cleanup(newfil);
	cleanup(curfil);
	exit(1);
}

int main(argc, argv)
int argc;
char *argv[];
{
	char *str;
	char **argvec;
	int count;
	char *file;

	ProgCall = *argv++;

	mkbase();

	signal(SIGHUP, trapcc);
	signal(SIGINT, trapcc);
	signal(SIGQUIT, trapcc);
	while (--argc > 0) {
		if (*(str = *argv++) != '-') {
			append(&SRCFILES, str);
			continue;
		}

		switch (str[1]) {

		case 'c':
			stopsuffix = "o";
			break;
		case 'F':
			break;
		case 'l':
			append(&SRCFILES, library(&str[2]));
			break;
		case 'o':
			if (argc-- >= 0)
				o_FILE = *argv++;
			break;
		case 'S':
			stopsuffix = "s";
			break;
		case 'v':
			v_flag++;
			if (str[2] == 'n')
				noexec = 1;
			break;
		case 't':
			/* save temporaries */
			t_flag++;
			break;
		case 'T':
			tmpdir = &str[2];
			/*FALLTHROUGH*/
		default:
			append(&FLAGS, str);

		}
	}

	mktempname(tmpname);

	count = SRCFILES.al_argc;
	argvec = &(SRCFILES.al_argv[0]);

	while (count-- > 0) {

		file = *argvec++;
		source = file;

		if (SRCFILES.al_argc > 1) {
			write(1, file, strlen(file));
			write(1, ":\n", 2);
		}

		file = process(file, 1);
	
		if (file && ! stopsuffix) append(&LDFILES, file);
	}

	clean(&SRCFILES);

	/* loader ... */
	if (RET_CODE == 0 && LDFILES.al_argc > 0) {
		register struct passinfo *pp = passinfo;

		while (!(pp->p_flags & LOADER)) pp++;
		mkstr(newfil, tmpname, pp->p_to, "");
		callld(&LDFILES, !((pp+1)->p_name) ? o_FILE : newfil, loader, pp);
		if (RET_CODE == 0) {
			register int i = GEN_LDFILES.al_argc;

			while (i-- > 0) {
				remove(GEN_LDFILES.al_argv[i]);
				free(GEN_LDFILES.al_argv[i]);
			}
			if ((++pp)->p_name) {
				process(newfil, 0);
			}
		}
	}
	return(RET_CODE);
}

void remove(str)
	char *str;
{
	if (t_flag)
		return;
	if (v_flag) {
		prs("rm ");
		prs(str);
		prs("\n");
	}
	if (noexec)
		return;
	unlink(str);
}

char *
alloc(u)
	unsigned u;
{
	register char *p = (char *)malloc(u);

	if (p == 0) panic("no space\n");
	return p;
}

void append(al, arg)
	struct arglist *al;
	char *arg;
{
	char *a = alloc((unsigned) (strlen(arg) + 1));

	strcpy(a, arg);
	if (al->al_argc >= MAXARGC)
		panic("argument list overflow\n");
	al->al_argv[(al->al_argc)++] = a;
}

void concat(al1, al2)
	struct arglist *al1, *al2;
{
	register i = al2->al_argc;
	register char **p = &(al1->al_argv[al1->al_argc]);
	register char **q = &(al2->al_argv[0]);

	if ((al1->al_argc += i) >= MAXARGC)
		panic("argument list overflow\n");
	while (i-- > 0)
		*p++ = *q++;
}

char *
mkstr(dst, arg1, arg2, arg3)
	char *dst, *arg1, *arg2, *arg3;
{
	register char *p;
	register char *q = dst;

	p = arg1;
	while (*q++ = *p++);
	q--;
	p = arg2;
	while (*q++ = *p++);
	q--;
	p = arg3;
	while (*q++ = *p++);
	q--;
	return dst;
}

void basename(str, dst)
	char *str;
	register char *dst;
{
	register char *p1 = str;
	register char *p2 = p1;

	while (*p1)
		if (*p1++ == '/')
			p2 = p1;
	p1--;
	if (*--p1 == '.') {
		*p1 = '\0';
		while (*dst++ = *p2++);
		*p1 = '.';
	}
	else
		while (*dst++ = *p2++);
}

char *
extension(fln)
	char *fln;
{
	register char *fn = fln;

	while (*fn) fn++;
	while (fn > fln && *fn != '.') fn--;
	if (fn != fln) return fn+1;
	return (char *)0;
}

int runvec(vec, pass, in, out)
	struct arglist *vec;
	struct passinfo *pass;
	char *in, *out;
{
	int pid, status;

	if (
		strncmp(vec->al_argv[1], "/usr/", 5) == 0
		&&
		access(vec->al_argv[1] + 4, 1) == 0
	)
		strcpy(vec->al_argv[1], vec->al_argv[1] + 4);
	if (v_flag) {
		pr_vec(vec);
		if (pass->p_flags & STDIN) {
			prs(" <");
			prs(in);
		}
		if (pass->p_flags & STDOUT) {
			prs(" >");
			prs(out);
		}
		prs("\n");
	}
	if (noexec)
		return 1;
	if ((pid = fork()) == 0) {	/* start up the process */
		if (pass->p_flags & STDIN) { /* redirect standard input */
			close(0);
			if (open(in, 0) != 0)
				panic("cannot open input file\n");
		}
		if (pass->p_flags & STDOUT) { /* redirect standard output */
			close(1);
			if (creat(out, 0666) != 1)
				panic("cannot create output file\n");
		}
		ex_vec(vec);
	}
	if (pid == -1)
		panic("no more processes\n");
	kids[0] = pid;
	clean(vec);
	wait(&status);
	kids[0] = -1;
	return status ? ((RET_CODE = 1), 0) : 1;
}

void prs(str)
	char *str;
{
	if (str && *str)
		write(2, str, strlen(str));
}

void panic(str)
	char *str;
{
	prs(str);
	trapcc(SIGINT);
}

void pr_vec(vec)
	register struct arglist *vec;
{
	register char **ap = &vec->al_argv[1];
	
	vec->al_argv[vec->al_argc] = 0;
	prs(*ap);
	while (*++ap) {
		prs(" ");
		if (strlen(*ap))
			prs(*ap);
		else
			prs("(empty)");
	}
}

void ex_vec(vec)
	register struct arglist *vec;
{
	extern int errno;

	vec->al_argv[vec->al_argc] = 0;
	execv(vec->al_argv[1], &(vec->al_argv[1]));
	if (errno == ENOEXEC) { /* not an a.out, try it with the SHELL */
		vec->al_argv[0] = SHELL;
		execv(SHELL, &(vec->al_argv[0]));
	}
	if (access(vec->al_argv[1], 1) == 0) {
		/* File is executable. */
		prs("Cannot execute ");
		prs(vec->al_argv[1]);
		prs(". Not enough memory.\n");
		prs("Use chmem to reduce its stack allocation\n");
	} else {
		prs(vec->al_argv[1]);
		prs(" is not executable\n");
	}
	exit(1);
}

void mktempname(nm)
	register char *nm;
{
	register int i;
	register int pid = getpid();

	strcpy(nm, tmpdir);
	strcat(nm, "/");
	strcat(nm, compbase->c_callname);
	while (*nm) nm++;

	for (i = 9; i > 3; i--) {
		*nm++ = (pid % 10) + '0';
		pid /= 10;
	}
	*nm++ = '.';
	*nm++ = '\0'; /* null termination */
}

void mkbase()
{
	register struct compile *p = passes;
	USTRING callname;

	basename(ProgCall, callname);
	while (p->c_suffix) {
		if (strcmp(p->c_callname, callname) == 0) {
			compbase = p;
			mkloader();
			return;
		}
		p++;
	}
	/* we should not get here */
	panic("internal error\n");
}

void mkloader()
{
	register struct passinfo *p = passinfo;
	register struct pass *pass;

	while (!(p->p_flags & LOADER)) p++;
	loaderinfo = p;
	pass = &(compbase->c_passes[0]);
	while (strcmp(pass->pp_name, p->p_name)) pass++;
	loader = pass;
}

int needsprep(name)
	char *name;
{
	int file;
	char fc;

	file = open(name,0);
	if (file <0) return 0;
	if (read(file, &fc, 1) != 1) fc = 0;
	close(file);
	return fc == '#';
}

char *
apply(pinf, cp, name, passindex, noremove, first, resultname)
	register struct passinfo *pinf;
	register struct compile *cp;
	char *name, *resultname;
	int passindex, noremove, first;
{
	/*	Apply a pass, indicated by "pinf", with args in 
		cp->c_passes[passindex], to name "name", leaving the result
		in a file with name "resultname", concatenated with result
		suffix.
		When neccessary, the preprocessor is run first.
		If "noremove" is NOT set, the file "name" is removed.
	*/

	struct arglist *call = &CALLVEC[0];
	struct pass *pass = &(cp->c_passes[passindex]);
	char *outname;

	if ( /* this pass is the first pass */
	     first
	   &&
	     ( /* preprocessor always needed */
	       (pinf->p_flags & PREPALWAYS)
	     ||/* or only when "needsprep" says so */
	       ( (pinf->p_flags & PREPCOND) && needsprep(name))
	     )
	   ) {
		mkstr(newfil, tmpname, passinfo[0].p_to, "");
		mkvec(call, name, newfil, (struct pass *) 0, &passinfo[0]);
		if (! runvec(call, &passinfo[0], name, newfil)) {
			cleanup(newfil);
			return 0;
		}
		strcpy(curfil, newfil);
		newfil[0] = '\0';
		name = curfil;
		noremove = 0;
	}
	if (pinf->p_to) outname = mkstr(newfil, resultname, pinf->p_to, "");
	else outname = o_FILE;
	mkvec(call, name, outname, pass, pinf);
	if (! runvec(call, pinf, name, outname)) {
		cleanup(outname);
		if (! noremove) cleanup(name);
		return 0;
	}
	if (! noremove) cleanup(name);
	strcpy(curfil, newfil);
	newfil[0] = '\0';
	return curfil;
}

int
applicable(pinf, suffix)
	struct passinfo *pinf;
	char *suffix;
{
	/*	Return one if the pass indicated by "pinfo" is applicable to
		a file with suffix "suffix".
	*/
	register char *sfx = pinf->p_from;

	if (! suffix) return 0;
	while (*sfx) {
		char c;
		register char *p = sfx;

		while (*p && *p != ',') p++;
		c = *p; *p = 0;
		if (strcmp(sfx, suffix) == 0) {
			*p = c;
			return 1;
		}
		*p = c;
		if (*p == ',') sfx = p+1;
		else sfx = p;
	}
	return 0;
}
		
char *
process(name, noremove)
	char *name;
	int noremove;
{
	register struct compile *cp = passes;
	char *suffix = extension(name);
	USTRING base;
	register struct pass *pass;
	register struct passinfo *pinf;

	if (! suffix) return name;

	basename(name, base);

	while (cp->c_suffix) {
		if ((cp->c_flags & DEFLANG) &&
		    strcmp(cp->c_suffix, suffix) == 0)
			break;
		cp++;
	}
	if (! cp->c_suffix) cp = compbase;
	pass = cp->c_passes;
	while (pass->pp_name) {
		int first = 1;

		for (pinf=passinfo; strcmp(pass->pp_name,pinf->p_name);pinf++)
			;
		if (! (pinf->p_flags & LOADER) && applicable(pinf, suffix)) {
			int cont = ! stopsuffix || ! pinf->p_to ||
					strcmp(stopsuffix, pinf->p_to) != 0;
			name = apply(pinf,
				     cp,
				     name,
				     (int)(pass - cp->c_passes),
				     noremove,
				     first,
				     applicable(loaderinfo, pinf->p_to) ||
				      !cont ?
					strcat(base, ".") :
					tmpname);
			first = noremove = 0;
			suffix = pinf->p_to;
			if (!cont || !name) break;
		}
		pass++;
	}
	if (!noremove && name)
		append(&GEN_LDFILES, name);
	return name;
}

void mkvec(call, in, out, pass, pinf)
	struct arglist *call;
	char *in, *out;
	struct pass *pass;
	register struct passinfo *pinf;
{
	register int i;

	init(call);
	append(call, pinf->p_path);
	scanflags(call, pinf);
	if (pass) for (i = 0; i < MAXHEAD; i++)
		if (pass->pp_head[i])
			append(call, pass->pp_head[i]);
		else	break;
	if (pinf->p_flags & INPUT)
		append(call, in);
	if (pinf->p_flags & OUTPUT)
		append(call, out);
	if (pinf->p_flags & O_OUTPUT) {
		append(call, "-o");
		append(call, out);
	}
	if (pass) for (i = 0; i < MAXTAIL; i++)
		if (pass->pp_tail[i])
			append(call, pass->pp_tail[i]);
		else	break;
	if (pinf->p_flags & SOURCE)
		append(call, source);
}

void callld(in, out, pass, pinf)
	struct arglist *in;
	char *out;
	struct pass *pass;
	register struct passinfo *pinf;
{
	struct arglist *call = &CALLVEC[0];
	register int i;

	init(call);
	append(call, pinf->p_path);
	scanflags(call, pinf);
	append(call, "-o");
	append(call, out);
	for (i = 0; i < MAXHEAD; i++)
		if (pass->pp_head[i])
			append(call, pass->pp_head[i]);
		else	break;
	if (pinf->p_flags & INPUT)
		concat(call, in);
	if (pinf->p_flags & OUTPUT)
		append(call, out);
	for (i = 0; i < MAXTAIL; i++)
		if (pass->pp_tail[i])
			append(call, pass->pp_tail[i]);
		else	break;
	if (! runvec(call, pinf, (char *) 0, out)) {
		cleanup(out);
		RET_CODE = 1;
	}
	clean(call);
}

void clean(c)
	register struct arglist *c;
{
	register int i;

	for (i = 1; i < c->al_argc; i++) {
		free(c->al_argv[i]);
		c->al_argv[i] = 0;
	}
	c->al_argc = 0;
}

void scanflags(call, pinf)
	struct arglist *call;
	struct passinfo *pinf;
{
	/*	Find out which flags from FLAGS must be passed to pass "pinf",
		and how. 
		Append them to "call"
	*/
	register int i;
	USTRING flg;

	for (i = 0; i < FLAGS.al_argc; i++) {
		register char *q = pinf->p_acceptflags;

		while (*q)  {
			register char *p = FLAGS.al_argv[i] + 1;

			while ((*q == *p) && *q) {
				q++; p++;
			}
			if (*q == ',' || !*q) {
				if (! *p) {
					/* append literally */
					append(call, FLAGS.al_argv[i]);
				}
				break;
			}
			if (*q == '*') {
				register char *s = flg;

				if (*++q != '=') {
					/* append literally */
					append(call, FLAGS.al_argv[i]);
					break;
				}
				*s++ = '-';
				if (*q) q++;	/* skip ',' */
				while (*q && *q != ',' && *q != '*') {
					/* copy replacement flag */
					*s++ = *q++;
				}
				if (*q == '*') {
					/* copy rest */
					while (*p) *s++ = *p++;
				}
				*s = 0;
				append(call, flg);
				break;
			}
			if (*q == '=') {
				/* copy replacement */
				register char *s = flg;

				*s++ = '-';
				q++;
				while (*q && *q != ',') *s++ = *q++;
				*s = 0;
				append(call, flg);
				break;
			}
			while (*q && *q++ != ',')
				;
		}
	}
}
