/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

#include "jove.h"
#include "jctype.h"
#include "chars.h"
#include "disp.h"
#include "fp.h"
#include "scandir.h"
#include "screen.h"	/* for Placur */
#include "ask.h"
#include "delete.h"
#include "insert.h"
#include "extend.h"
#include "fmt.h"
#include "marks.h"
#include "move.h"

#ifdef MAC
# include "mac.h"
#else /* !MAC */
# ifdef F_COMPLETION
#  include <sys/stat.h>
# endif
#endif /* !MAC */

ZXchar	AbortChar = CTL('G');	/* VAR: cancels command input */

bool	Asking = NO;
int	AskingWidth;

char	Minibuf[LBSIZE];
private LinePtr	CurAskPtr = NULL;	/* points at some line in mini-buffer */
private Buffer	*AskBuffer = NULL;	/* Askbuffer points to actual structure */

/* The way the mini-buffer works is this:  The first line of the mini-buffer
   is where the user does his stuff.  The rest of the buffer contains
   strings that the user often wants to use, for instance, file names, or
   common search strings, etc.  If he types ^N or ^P while in ask(), we
   bump the point up or down a line and extract the contents (we make sure
   is somewhere in the mini-buffer). */

private Buffer *
get_minibuf()
{
	if (AskBuffer) {		/* make sure ut still exists */
		register Buffer	*b;

		for (b = world; b != NULL; b = b->b_next)
			if (b == AskBuffer)
				return b;
	}
	AskBuffer = do_select((Window *)NULL, "*minibuf*");
	AskBuffer->b_type = B_SCRATCH;
	return AskBuffer;
}

/* Add a string to the mini-buffer. */

void
minib_add(str, movedown)
char	*str;
bool	movedown;
{
	register Buffer	*saveb = curbuf;

	SetBuf(get_minibuf());
	LineInsert(1);
	ins_str(str);
	if (movedown)
		CurAskPtr = curline;
	SetBuf(saveb);
}

bool	InRealAsk = NO;

private char *
real_ask(delim, d_proc, def, prompt)
const char	*delim,
	*def,
	*prompt;
bool	(*d_proc) ptrproto((ZXchar));
{
	jmp_buf	savejmp;
	ZXchar	c;
	int	prompt_len;
	Buffer	*saveb = curbuf;
	volatile bool	aborted = NO;
	bool	no_typed = NO;
	data_obj	*push_cmd = LastCmd;
	int	saved_as, saved_ac;

#ifdef MAC
	menus_off();
#endif
	if (InRealAsk)
		complain((char *) NULL);
	save_arg(saved_as, saved_ac);
	push_env(savejmp);
	InRealAsk = YES;
	SetBuf(get_minibuf());
	if (!inlist(AskBuffer->b_first, CurAskPtr))
		CurAskPtr = curline;
	prompt_len = strlen(prompt);
	ToFirst();	/* Beginning of buffer. */
	linebuf[0] = '\0';
	modify();
	makedirty(curline);

	if (setjmp(mainjmp)) {
		if (InJoverc) {		/* this is a kludge */
			aborted = YES;
			goto cleanup;
		}
	}

	this_cmd = OTHER_CMD;	/* probably redundant */
	for (;;) {
		cmd_sync();
		s_mess("%s%s", prompt, linebuf);
		Asking = YES;
		AskingWidth = curchar + prompt_len;
		c = getch();
		if (c != '\0' && strchr(delim, c) != NULL) {
			if (d_proc == NULL_ASK_EXT || !(*d_proc)(c))
				break;
		} else if (c == AbortChar) {
			message("[Aborted]");
			aborted = YES;
			break;
		} else switch (c) {
		case CTL('N'):
		case CTL('P'):
			if (CurAskPtr != NULL) {
				int	n = (c == CTL('P') ? -arg_value() : arg_value());

				CurAskPtr = next_line(CurAskPtr, n);
				if (CurAskPtr == curbuf->b_first && CurAskPtr->l_next != NULL)
					CurAskPtr = CurAskPtr->l_next;
				(void) ltobuf(CurAskPtr, linebuf);
				modify();
				makedirty(curline);
				Eol();
				this_cmd = OTHER_CMD;
			}
			break;

		case CTL('R'):
			if (def != NULL)
				ins_str(def);
			else
				rbell();
			break;

		default:
			dispatch(c);
			break;
		}
		if (curbuf != AskBuffer)
			SetBuf(AskBuffer);
		if (curline != curbuf->b_first) {
			CurAskPtr = curline;
			curline = curbuf->b_first;	/* with whatever is in linebuf */
		}
	}
cleanup:
	pop_env(savejmp);

	LastCmd = push_cmd;
	restore_arg(saved_as, saved_ac);
	no_typed = (linebuf[0] == '\0');
	strcpy(Minibuf, linebuf);
	SetBuf(saveb);
	InRealAsk = Asking = Interactive = NO;
	if (!aborted) {
		if (!PreEmptOutput()) {
			Placur(ILI, 0);
			flushscreen();
		}
		if (no_typed)
			return NULL;
	} else
		complain((char *)NULL);
	return Minibuf;
}

#ifdef STDARGS
char *
ask(char *def, char *fmt, ...)
#else
/*VARARGS2*/ char *
ask(def, fmt, va_alist)
	char	*def,
		*fmt;
	va_dcl
#endif
{
	char	prompt[128];
	char	*ans;
	va_list	ap;

	va_init(ap, fmt);
	format(prompt, sizeof prompt, fmt, ap);
	va_end(ap);
	ans = real_ask("\r\n", NULL_ASK_EXT, def, prompt);
	if (ans == NULL) {		/* Typed nothing. */
		if (def == NULL)
			complain("[No default]");
		ans = def;
	}
	return ans;
}

#ifdef STDARGS
char *
do_ask(const char *delim, bool (*d_proc) ptrproto((ZXchar)), const char *def, const char *fmt, ...)
#else
/*VARARGS4*/ char *
do_ask(delim, d_proc, def, fmt, va_alist)
	const char	*delim;
	bool	(*d_proc) ptrproto((ZXchar));
	const char	*def;
	const char	*fmt;
	va_dcl
#endif
{
	char	prompt[128];
	va_list	ap;

	va_init(ap, fmt);
	format(prompt, sizeof prompt, fmt, ap);
	va_end(ap);
	return real_ask(delim, d_proc, def, prompt);
}

bool	OneKeyConfirmation = NO;	/* VAR: single y or n keystroke sufficient? */

#ifdef STDARGS
bool
yes_or_no_p(char *fmt, ...)
#else
/*VARARGS1*/ bool
yes_or_no_p(fmt, va_alist)
	char	*fmt;
	va_dcl
#endif
{
	char	prompt[128];
	va_list	ap;

	va_init(ap, fmt);
	format(prompt, sizeof prompt, fmt, ap);
	va_end(ap);

	for (;;) {
		if (OneKeyConfirmation) {
			ZXchar	c;

			message(prompt);
			Asking = YES;	/* so redisplay works */
			AskingWidth = strlen(prompt);
			c = getch();
			Asking = NO;
			if (c == AbortChar)
				complain("[Aborted]");
			switch (CharUpcase(c)) {
			    case 'Y':
				return YES;

			    case 'N':
				return NO;

			    default:
				add_mess("[Type Y or N]");
				Asking = YES;	/* so cursor sits on question */
				SitFor(10);
			}
		} else {
			char *ans = ask((char *) NULL, prompt);

			if (caseeqn(ans, "yes", strlen(ans)))
				return YES;
			if (caseeqn(ans, "no", strlen(ans)))
				return NO;
			rbell();
		}
	}
	/* NOTREACHED */
}

#ifdef F_COMPLETION

/* look for any substrings of the form $foo in linebuf, and expand
   them according to their value in the environment (if possible) -
   this munges all over curchar and linebuf without giving it a second
   thought (I must be getting lazy in my old age) */

# ifndef MAC	/* no environment in MacOS */

bool	DoEVexpand = YES;	/* VAR: should we expand evironment variables? */

private void
EVexpand()
{
	register char	c;
	register char	*lp = linebuf,
			*ep;
	char	varname[128],
		*vp,
		*lp_start;
	Mark	*m = MakeMark(curline, curchar);

	while ((c = *lp++) != '\0') {
		if (c == '$') {
			lp_start = lp - 1;	/* the $ */
			vp = varname;
			/* Pick up env. variable name ([a-zA-Z0-9_]*) */
			while (('a' <= (c = *lp++) && c <= 'z')
			|| ('A' <= c && c <= 'Z')
			|| ('0' <= c && c <= '9')
			|| c == '_')
				*vp++ = c;
			*vp = '\0';
			/* if we find an env. variable with the right
			   name, we insert it in linebuf, and then delete
			   the variable name that we're replacing - and
			   then we continue in case there are others ... */
			if ((ep = getenv(varname)) != NULL) {
				curchar = lp_start - linebuf;
				ins_str(ep);
				del_char(FORWARD, (int)strlen(varname) + 1, NO);
				lp = linebuf + curchar;
			}
		}
	}
	ToMark(m);
	DelMark(m);
}

# endif /* !MAC */

private char	*fc_filebase;
bool	DispBadFs = YES;	/* VAR: display filenames with bad extensions? */

char	BadExtensions[sizeof(BadExtensions)] =	/* VAR: extensions to ignore */
# ifdef MINT
".lzh .tgz .au .wav .taz .o .Z .gz .tar .zip .zoo .gif .jpg .jpeg .mpg .mpeg .tif .tiff .rgb .dvi .elc";
# else
# ifndef MSFILESYSTEM
/* .o: object code format
 * .Z .gz: compressed formats
 * .tar .zip .zoo: archive formats
 * .gif .jpg .jpeg .mpg .mpeg .tif .tiff .rgb: graphics formats
 * .dvi: TeX or ditroff output
 * .elc: compiled GNU EMACS code
 */
".o .Z .gz .tar .zip .zoo .gif .jpg .jpeg .mpg .mpeg .tif .tiff .rgb .dvi .elc";
# else /* MSFILESYSTEM */
/* .obj .lib .exe .com .dll: object code files
 * .arc .zip .zoo: archive formats
 * .bmp .gif .jpg .mpg .tif .pcx: graphics formats
 * .wks .wk1 .xls: spreadsheet formats
 */
".obj .lib .exe .com .dll .arc .zip .zoo .bmp .gif .jpg .mpg .tif .pcx .wks .wk1 .xls";
# endif /* MSFILESYSTEM */
# endif

private bool
bad_extension(name)
char	*name;
{
	char	*ip,
		*bads;
	size_t	namelen = strlen(name),
		ext_len;

# if defined(UNIX) || defined(MSFILESYSTEM)
#  ifdef DIRECTORY_ADD_SLASH
	if (strcmp(name, "./")==0 || strcmp(name, "../")==0)
		return YES;
#  else
	if (strcmp(name, ".")==0 || strcmp(name, "..")==0)
		return YES;
#  endif /* DIRECTORY_ADD_SLASH */
# endif /* UNIX || MSFILESYSTEM */
	for (ip=bads=BadExtensions; *ip!='\0'; bads = ip+1) {
		if ((ip = strchr(bads, ' ')) == NULL)
			ip = bads + strlen(bads);
		ext_len = ip - bads;
		if (ext_len != 0 && ext_len < namelen
# ifdef FILENAME_CASEINSENSITIVE
		&& caseeqn(&name[namelen - ext_len], bads, ext_len))
# else
		&& strncmp(&name[namelen - ext_len], bads, ext_len) == 0)
# endif
			return YES;
	}
	return NO;
}

private bool f_match proto((char* file));	/* needed to comfort dumb MS Visual C */

private bool
f_match(file)
char	*file;
{
	size_t	len = strlen(fc_filebase);

	if (!DispBadFs && bad_extension(file))
		return NO;

	return len == 0
# ifdef FILENAME_CASEINSENSITIVE
		|| caseeqn(file, fc_filebase, len);
# else
		|| strncmp(file, fc_filebase, len) == 0;
# endif
}

# ifndef DIRECTORY_ADD_SLASH
private bool
isdir(name)
char	*name;
{
	(void) do_stat(name, (Buffer *) NULL, DS_DIR);
	return was_dir;
}
# endif /* !DIRECTORY_ADD_SLASH */

private void
fill_in(dir_vec, n)
register char	**dir_vec;
int	n;
{
	bool	filter;

	for (filter = DispBadFs; ; filter = NO) {
		int
			minmatch = 0,
			numfound = 0,
			lastmatch = -1,
			i;

		for (i = 0; i < n; i++) {
			/* If filter is NO, we accept all entries
			   (either DispBadFs is NO, in which case filtering
			   was done when dir_vec was built, or DispBadFs
			   is YES, but we are trying again, after finding
			   no files passed the filter. */
			if (!filter || !bad_extension(dir_vec[i])) {
				minmatch = numfound == 0
					? (int)strlen(dir_vec[i])
#ifdef FILENAME_CASEINSENSITIVE
					: min(minmatch, numcompcase(dir_vec[lastmatch], dir_vec[i]));
#else
					: min(minmatch, numcomp(dir_vec[lastmatch], dir_vec[i]));
#endif
				lastmatch = i;
				numfound += 1;
			}
		}
		if (numfound == 0) {
			if (!filter) {
				/* hopeless: complain and give up */
				rbell();
				break;
			}
		} else {
			bool
				the_same = YES; /* After filling in, are we the same
							as when we were called? */

			if (minmatch > (int)strlen(fc_filebase)) {
				if (minmatch >= LBSIZE - (fc_filebase - linebuf))
					len_error(JMP_COMPLAIN);
				the_same = NO;
				null_ncpy(fc_filebase, dir_vec[lastmatch], (size_t) minmatch);
				makedirty(curline);
			}
			Eol();
# ifndef DIRECTORY_ADD_SLASH
			if (numfound == 1 && fc_filebase[0] != '\0' && isdir(linebuf)) {
				the_same = NO;
				insert_c('/', 1);
			}
# endif
			if (the_same) {
				add_mess(" [%s%s]",
					!filter && DispBadFs? "!" : NullStr,
					numfound == 1? "Unique" : "Ambiguous");
				SitFor(7);
			}
			break;	/* we're done */
		}
	}
}

/* called from do_ask() when one of "\r\n ?" is typed.  Does the right
   thing, depending on which. */

private bool
f_complete(c)
ZXchar	c;
{
	char
		dir[FILESIZE],
		**dir_vec;
	int
		nentries;

# ifndef MAC	/* no environment in MacOS */
	if (DoEVexpand)
		EVexpand();
# endif
	if (c == CR || c == LF)
		return NO;	/* tells ask to return now */
	fc_filebase = strrchr(linebuf, '/');
# if defined(MSFILESYSTEM) || defined(MINT)
	{
		char	*p = strrchr(fc_filebase == NULL? linebuf : fc_filebase, '\\');

		if (p != NULL)
			fc_filebase = p;
		if (fc_filebase == NULL)
			fc_filebase = strrchr(linebuf, ':');
	}
# endif /* MSFILESYSTEM */
	if (fc_filebase != NULL) {
		char	tmp[FILESIZE];

		fc_filebase += 1;
		null_ncpy(tmp, linebuf, (size_t) (fc_filebase - linebuf));
		if (tmp[0] == '\0')
			strcpy(tmp, "/");
		PathParse(tmp, dir);
	} else {
		fc_filebase = linebuf;
		strcpy(dir, ".");
	}
	if ((nentries = jscandir(dir, &dir_vec, f_match, fnamecomp)) == -1) {
		add_mess(" [Unknown directory: %s]", dir);
		SitFor(7);
		return YES;
	}
	if (nentries == 0) {
		add_mess(" [No match]");
		SitFor(7);
	} else if (jiswhite(c)) {
		fill_in(dir_vec, nentries);
	} else {
		/* we're a '?' */
		int
			i,
			maxlen = 0,
			ncols,
			line,
			entriespercol;

		TOstart("Completion");
		Typeout("(! means file will not be chosen unless typed explicitly)");
		Typeout("Possible completions (in %s):", dir);

		for (i = 0; i < nentries; i++)
			maxlen = max((int)strlen(dir_vec[i]), maxlen);
		maxlen += 4;	/* pad each column with at least 4 spaces */
		ncols = min((CO - 2), MAX_TYPEOUT) / maxlen;
		entriespercol = (nentries + ncols - 1) / ncols;

		for (line = 0; line < entriespercol; line++) {
			int
				col,
				which = line,
				bufcol = 0;
			char	buf[MAX_TYPEOUT + 1];

			for (col = 0; col < ncols; col++) {
				if (which < nentries) {
					bool	isbad = DispBadFs && bad_extension(dir_vec[which]);

					swritef(buf+bufcol, sizeof(buf) - bufcol, "%s%-*s",
						isbad ? "!" : NullStr,
						maxlen - isbad, dir_vec[which]);
				}
				which += entriespercol;
				bufcol += maxlen;
			}
			Typeout("%s", buf);
		}
		TOstop();
	}
	freedir(&dir_vec, nentries);
	return YES;
}

#endif /* F_COMPLETION */

char *
ask_file(prmt, def, buf)
const char	*prmt;
char
	*def,
	*buf;
{
	char	*ans,
		prompt[128],
		*pretty_name = pr_name(def, YES);

	if (prmt == NULL)
		swritef(prompt, sizeof(prompt), ProcFmt);
	else
		strcpy(prompt, prmt);
	if (def != NULL && *def != '\0') {
		size_t	pl = strlen(prompt);

		swritef(prompt + pl, sizeof(prompt)-pl, "(default %s) ", pretty_name);
		if ((int)strlen(prompt) * 2 >= CO)
			prompt[pl] = '\0';
	}
#ifdef F_COMPLETION
	ans = real_ask("\r\n \t?", f_complete, pretty_name, prompt);
	if (ans == NULL && (ans = pretty_name) == NULL)
		complain("[No default file name]");
#else
	ans = ask(pretty_name, prompt);
#endif
	PathParse(ans, buf);

	return buf;
}
