/*
	initargcv() sets up the global variables _argc and _argcv which are
	passed to main() by _main() in init.c.  If main() has no parameters
	then the compiler puts out a dummy initargcv() procedure which over-
	rides this definition thereby saving code space.
*/

#include <stdio.h>
#include <ctype.h>
#include <osbind.h>

#define MAXARGS		100		/* maximum nuber of command line arguments */

extern int _argc;
extern char **_argv;

_initargcv(comlin)
char *comlin;	/* points to byte length encoded image of command line */
{
	register int i;
	int len;
	int inword = 0;		/* 1=currently in a word */
	int quote = 0;		/* 1=currently in a double quote, 2=single quote */
	register char *p, *q;
	char *new_stdin = 0, *new_stdout = 0;  /* redirection file names */
	int append;			/* 1=append to stdout */
	char *v[MAXARGS];	/* temporary argv[] array */

	_argc = 1;	/* always have at least program name */
	len = (*comlin++ & 255);	/* first byte is length of command line */

	q = p = comlin;
	for (i=0; i<len; p++, i++) {
		if (isspace(*p)) {
			if (!quote) {
				if (inword)
					inword = 0;
				*q++ = 0;	/* convert spaces to nulls */
			}
			else
				*q++ = ' ';
		}
		else if (*p == '"') {
			if (quote == 1)
				quote = 0;
			else if (!inword && !quote) {
				quote = 1;
				v[_argc++] = q;
			}
			else
				*q++ = '"';
		}
		else if (*p == '\'') {
			if (quote == 2)
				quote = 0;
			else if (!inword && !quote) {
				quote = 2;
				v[_argc++] = q;
			}
			else
				*q++ = '\'';
		}
		else {
			if (!inword && !quote) {
				inword = 1;
				if (*p == '<') 	/* redirect stdin */
					new_stdin = q+1;
				else
					if (*p == '>')
						if (*(p+1) == '>') {
							new_stdout = q+2;	/* redirect and append stdout */
							append = 1;
						}
						else {
							new_stdout = q+1; /* redirect stdout */
							append = 0;
						}
					else
						v[_argc++] = q;		/* not redirection, add to argv[] */
			}
			*q++ = *p;
		}
	}
	*q = 0;	/* make sure last string is null terminated */

	/* Open redirection files now */
	if (new_stdin) {
		stdin->_flag = _READ;	/* big buffering */
		stdin->_bufsize = _BUFSIZE;
		freopen(new_stdin, "r", stdin);
	}
	if (new_stdout) {
		stdout->_flag = _WRITE;
		freopen(new_stdout, append ? "a" : "w", stdout);
	}

	_argv = (char **)Malloc((long)((_argc+1) * sizeof(char *)));
	for (i=1; i < _argc; i++)
		_argv[i] = v[i];		/* copy temporary argv[] to real argv[] */
	_argv[0] = q;				/* no program name */
	_argv[_argc] = NULL;		/* execv assumes null ptr after last argv[] */
}
