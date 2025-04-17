/*
 * system(): execute a command, passed as a string
 *
 * Written by Eric R. Smith and placed in the public domain.
 *
 * Modified by Allan Pratt to call _unx2dos on redirect file names
 * and to call spawnvp() without calling fork() -- why bother?
 *
 */

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include <process.h>
#include <errno.h>
#include <file.h>
#include <osbind.h>

#ifdef DEBUG
#define MSG(x) Cconws(x "\r\n")
#define MSG2(x,y) printf(x,y);
#else
#define MSG(x)
#define MSG2(x,y)
#endif

#define isquote(c) ((c) == '\"' || (c) == '\'' || (c) == '`')
#define ARG_ERR	   ( (Argentry *) -1 )

/* struct. used to build a list of arguments for the command */

typedef struct argentry {
	struct argentry *next;
	char	string[1];
} Argentry;


/* allocate an Argentry that will hold the string "s" */

static Argentry *_argalloc(s)
	const char *s;
{
	Argentry *x;

	x = (Argentry *) malloc((size_t)(sizeof(Argentry) + strlen(s) + 1));
	if (!x)
		return ARG_ERR;
	x->next = (Argentry *) 0;
	strcpy(x->string, s);
	return x;
}

/* free a list of Argentries */

static void _argfree(p)
	Argentry *p;
{
	Argentry *oldp;

	while (p) {
		oldp = p;
		p = p->next;
		free(oldp);
	}
}

/* parse a string into a list of Argentries. Words are defined to be
 * (1) any sequence of non-blank characters
 * (2) any sequence of characters starting with a ', ", or ` and ending
 *     with the same character. These quotes are stripped off.
 * (3) any spaces after an unquoted > or < are skipped, so
 *     "ls > junk" is parsed as 'ls' '>junk'.
 */

static Argentry *_parseargs(s)
	const char *s;
{
	Argentry *cur, *res;
	char buf[FILENAME_MAX];
	char *t, quote;

	res = cur = _argalloc("");

	for(;;) {
		t = buf;
again:
		while (isspace(*s)) s++;
		if (!*s) break;
		if (isquote(*s)) {
			quote = *s++;
			while (*s && *s != quote)
				*t++ = *s++;
			if (*s) s++;	/* skip final quote */
		}
		else {
			while (*s && !isspace(*s))
				*t++ = *s++;
			if (*s && ( *(s-1) == '>' || *(s-1) == '<' ))
				goto again;
		}
		*t = 0;
		cur->next = _argalloc(buf);
		if (!(cur = cur->next))	  /* couldn't alloc() */
			return ARG_ERR;
	}
	cur->next = (Argentry *) 0;
	cur = res; res = res->next; free(cur);
	return res;
}


/* Here is system() itself.
 * FIXME: we probably should do I/O redirection and wildcard expansion.
 * also, should errno get set here??
 */

static int retval;

int system(s)
	const char *s;
{
	Argentry *al, *cur;
	char **argv, *p;
	int  argc, i;
	char *infile, *outfile;
	int  infd, outfd, append = 0;
	int oldin, oldout;	/* hold the Fdup'd in, out */
	char path[FILENAME_MAX];

	if (!s)		/* check for system() supported ?? */
		return 1;
	al = _parseargs(s);		/* get a list of args */
	if (al == ARG_ERR)		/* not enough memory */
		return (errno = ENOMEM);

	infile = outfile = "";
MSG("in system");

/* convert the list returned by _parseargs to the normal char *argv[] */
	argc = i = 0;
	for (cur = al; cur; cur = cur->next)
		argc++;
	if (!(argv = (char **) malloc((size_t)(argc * sizeof(char *)))))
		return (errno = ENOMEM);
	for (cur = al; cur; cur = cur->next) {
		p = cur->string;
		if (*p == '>') {
MSG("redirecting output");
			outfile = p+1;
			if (*outfile == '>') {
				outfile++;
				append = 1;
			}
			else
			append = 0;
		}
		else if (*p == '<') {
MSG("redirecting input");
			infile = p+1;
		}
		else
			argv[i++] = p;
	}
 	argv[i] = (char *)0;
 
/* now actually run the program */
	/* there was a "vfork" call here, but why bother? */
	if (*infile) {
		_unx2dos(infile,path);
		infd = Fopen(path, 0);
		if (infd < __SMALLEST_VALID_HANDLE) {
			perror(infile);
			_exit(2);
		}
		oldin = Fdup(0);
		Fforce(0, infd);
	}
	if (*outfile) {
		_unx2dos(outfile,path);
		if (append) {
			outfd = Fopen(path, 2);
			if (outfd < __SMALLEST_VALID_HANDLE)
				outfd = Fcreate(path, 0);
			else
				Fseek(0L, outfd, 2);
		}
		else
			outfd = Fcreate(path, 0);
		if (outfd < __SMALLEST_VALID_HANDLE) {
			perror(outfile);
			_exit(2);
		}
		oldout = Fdup(1);
		Fforce(1, outfd);
	}
MSG("Calling spawnvp");
	retval = spawnvp(P_WAIT, argv[0], argv);
MSG("Exiting");
	if (*infile) Fforce(0,oldin), Fclose(oldin), Fclose(infd);
	if (*outfile) Fforce(1,oldout), Fclose(oldout), Fclose(outfd);
	free(argv);
	_argfree(al);
	return retval;
}
