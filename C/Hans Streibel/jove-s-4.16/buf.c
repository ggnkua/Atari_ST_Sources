/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

/* Contains commands that deal with creating, selecting, killing and
   listing buffers, and buffer modes, and find-file, etc. */

#include "jove.h"
#include "jctype.h"
#include "disp.h"
#include "ask.h"
#include "extend.h"
#include "fmt.h"
#include "insert.h"
#include "macros.h"	/* only for mac_getc(), used by do_find fudge */
#include "marks.h"
#include "move.h"
#include "sysprocs.h"
#include "proc.h"
#include "wind.h"

#ifdef IPROCS
# include "fp.h"
# include "iproc.h"
#endif

#ifdef MAC
# include "mac.h"
#else
# include <sys/stat.h>
#endif

#ifdef AUTO_BUFS
char
	*iobuff,
	*genbuf,
	*linebuf;
#else
char
	iobuff[LBSIZE],
	genbuf[LBSIZE],
	linebuf[LBSIZE];
#endif

private void
	setbname proto((Buffer *, char *));

private char	*Mainbuf = "Main",
	*NoName = "Sans un nom!";

Buffer
	*world = NULL,		/* First in the list */
	*curbuf = NULL,		/* pointer into world for current buffer */
	*lastbuf = NULL,	/* Last buffer we were in so we have a default
				   buffer during a select buffer. */
	*perr_buf = NULL;	/* Buffer with error messages */

/* Toggle BIT in the current buffer's minor mode flags.  If argument is
   supplied, a positive one always turns on the mode and zero argument
   always turns it off. */

void
TogMinor(bit)
int	bit;
{
	if (is_an_arg()) {
		if (arg_value() == 0)
			curbuf->b_minor &= ~bit;
		else
			curbuf->b_minor |= bit;
	} else
		curbuf->b_minor ^= bit;
	UpdModLine = YES;
}

/* Creates a new buffer, links it at the end of the buffer chain, and
   returns it. */

private Buffer	*free_bufs = NULL;

private Buffer *
buf_alloc()
{
	register Buffer	*b,
			*lastbp;

	lastbp = NULL;
	for (b = world; b != NULL; b = b->b_next)
		lastbp = b;

	if (free_bufs != NULL) {
		b = free_bufs;
		free_bufs = b->b_next;
	} else {
		b = (Buffer *) emalloc(sizeof (Buffer));
	}
	if (lastbp)
		lastbp->b_next = b;
	else
		world = b;
	b->b_first = NULL;
	b->b_next = NULL;
#ifdef MAC
	b->Type = BUFFER;	/* kludge, but simplifies menu handlers */
	b->Name = NULL;
#endif
	return b;
}

/* Make a buffer and initialize it. */

private Buffer *
mak_buf()
{
	register Buffer	*newb;
	register int	i;

	newb = buf_alloc();
	newb->b_fname = NULL;
	newb->b_name = NoName;
	newb->b_marks = NULL;
	newb->b_themark = 0;		/* Index into markring */
	/* No marks yet */
	for (i = 0; i < NMARKS; i++)
		newb->b_markring[i] = NULL;
	newb->b_modified = newb->b_diverged = NO;
	newb->b_type = B_FILE;  /* File until proven SCRATCH */
	newb->b_minor = 0;
	newb->b_major = TEXTMODE;
	newb->b_first = NULL;
	newb->b_map = NULL;
#ifdef IPROCS
	newb->b_process = NULL;
#endif
	buf_clear(newb);
#ifdef MAC
	Bufchange = YES;
#endif
	return newb;
}

void
ReNamBuf()
{
	setbname(curbuf, ask_buf((Buffer *)NULL, ALLOW_NEW));
}

void
FindFile()
{
	char	fnamebuf[FILESIZE];

	(void) ask_file((char *)NULL, curbuf->b_fname, fnamebuf);
	SetABuf(curbuf);
	SetBuf(do_find(curwind, fnamebuf, YES, NO));
	if (curbuf->b_diverged)
		rbell();	/* slight hint of divergence */
}

private void
mkbuflist(bnamp, ebnamp)
register char	**bnamp;
char		**ebnamp;
{
	register Buffer	*b;

	for (b = world; b != NULL; b = b->b_next) {
		if (b->b_name != NULL) {
			*bnamp++ = b->b_name;
			if (bnamp >= ebnamp)
				complain("too many buffers to list");
		}
	}
	*bnamp = NULL;
}

char *
ask_buf(def, flags)
Buffer	*def;
int	flags;
{
	char	*defname = def != NULL? def->b_name : (char *)NULL;
	char	*bnames[200];
	register char	*bname;
	register int	offset;
	char	prompt[100];

	/* The test for % in the next definition is a kludge to prevent
	 * the default buffer name in the prompt string from provoking
	 * unintended formatting.  Ugh!  The name will still be the default.
	 */
	if (defname != NULL && strchr(defname, '%') == NULL)
		swritef(prompt, sizeof(prompt), ": %%f (default %s) ", defname);
	else
		strcpy(prompt, ProcFmt);
	mkbuflist(bnames, &bnames[elemsof(bnames)]);
	/* Secret bonus: if there is no default, ^R will insert curbuf's name. */
	offset = complete(bnames, defname==NULL? curbuf->b_name : defname, prompt,
		flags | (defname == NULL? 0 : ALLOW_EMPTY));
	if (offset < 0)
		bname = *Minibuf == '\0' && defname != NULL? defname : Minibuf;
	else
		bname = bnames[offset];
	return bname;
}

void
BufSelect()
{
	register char	*bname;

	bname = ask_buf(lastbuf, ALLOW_OLD | ALLOW_INDEX | ALLOW_NEW);
	SetABuf(curbuf);
	SetBuf(do_select(curwind, bname));
}

private void
BufNSelect(n)
int	n;
{
	register Buffer	*b;

	for (b = world; b != NULL; b = b->b_next) {
		if (b->b_name != NULL) {
			n -= 1;
			if (n == 0) {
				SetABuf(curbuf);
				SetBuf(do_select(curwind, b->b_name));
				return;
			}
		}
	}
	complain("[No such buffer]");
}

void Buf1Select() { BufNSelect(1); }
void Buf2Select() { BufNSelect(2); }
void Buf3Select() { BufNSelect(3); }
void Buf4Select() { BufNSelect(4); }
void Buf5Select() { BufNSelect(5); }
void Buf6Select() { BufNSelect(6); }
void Buf7Select() { BufNSelect(7); }
void Buf8Select() { BufNSelect(8); }
void Buf9Select() { BufNSelect(9); }
void Buf10Select() { BufNSelect(10); }

private void
delb_wind(b)
register Buffer *b;
{
	register Window	*w = fwind;
	char	*alt = lastbuf != NULL && lastbuf != b? lastbuf->b_name
		: b->b_next != NULL? b->b_next->b_name
		: Mainbuf;

	do {
		Window	*next = w->w_next;

		if (w->w_bufp == b) {
			if (one_windp() || alt != Mainbuf)
				(void) do_select(w, alt);
			else
				del_wind(w);
		}
		w = next;
	} while (w != fwind || w->w_bufp == b);
}

private Buffer *
getNMbuf()
{
	register Buffer	*delbuf = buf_exists(ask_buf(curbuf,
		ALLOW_OLD | ALLOW_INDEX));

	if (delbuf->b_modified)
		confirm("%s modified, are you sure? ", delbuf->b_name);
	return delbuf;
}

void
BufErase()
{
	register Buffer	*delbuf = getNMbuf();

	buf_clear(delbuf);
}

/* Free a buffer structure.
 * The actual struct is preserved to reduce the damage
 * from dangling references to it.  They seem to be pervasive.
 * We try to reset enough that a dangling reference will be useless.
 */

private void
kill_buf(delbuf)
register Buffer	*delbuf;
{
#ifdef IPROCS
	untieDeadProcess(delbuf);	/* check for lingering processes */
#endif

	/* Clean up windows associated with this buffer
	 * before it becomes invalid.
	 */
	delb_wind(delbuf);

	/* Resetting curbuf must be done after delb_wind since it can
	 * have a side-effect of setting curbuf to delbuf.  For the same
	 * reason, delbuf must not be unlinked until after delb_wind.
	 */
	if (curbuf == delbuf)
		curbuf = NULL;
	if (lastbuf == delbuf)
		lastbuf = curbuf;	/* even if NULL */
	if (curbuf == NULL)
		SetBuf(curwind->w_bufp);

	/* unlink the buffer */
	if (world == delbuf) {
		world = delbuf->b_next;
	} else {
		register Buffer	*b;

		for (b = world; b->b_next != delbuf; b = b->b_next)
			;
		b->b_next = delbuf->b_next;
	}

	if (perr_buf == delbuf) {
		ErrFree();
		perr_buf = NULL;
	}

	lfreelist(delbuf->b_first);
	delbuf->b_first = delbuf->b_dot = delbuf->b_last = NULL;
	if (delbuf->b_name != NULL) {
		free((UnivPtr) delbuf->b_name);
		delbuf->b_name = NULL;
	}
	if (delbuf->b_fname != NULL) {
		free((UnivPtr) delbuf->b_fname);
		delbuf->b_fname = NULL;
	}
	flush_marks(delbuf);
	delbuf->b_marks = NULL;
	DelObjRef((data_obj *)delbuf->b_map);
	delbuf->b_map = NULL;

	delbuf->b_next = free_bufs;
	free_bufs = delbuf;
#ifdef MAC
	Bufchange = YES;
	delbuf->Name = NULL;	/* ??? this cannot legitimately matter */
#endif
}

/* offer to kill some buffers */

void
KillSome()
{
	register Buffer	*b,
			*next;

	for (b = world; b != NULL; b = next) {
		next = b->b_next;
		if (!yes_or_no_p(IsModified(b)? "Kill %s [modified]? " : "Kill %s? ", b->b_name))
			continue;
		if (IsModified(b)
		&& yes_or_no_p("%s modified; should I save it? ", b->b_name))
		{
			Buffer	*oldb = curbuf;

			SetBuf(b);
			SaveFile();
			SetBuf(oldb);
		}
		kill_buf(b);
	}
}

void
BufKill()
{
	kill_buf(getNMbuf());
}

private const char	*const TypeNames[] = {
	NULL,
	"Scratch",
	"File",
	"Process",
};

void
BufList()
{
	register char	*fmt = "%2s %5s %-8s %-1s%-1s %-*s  %-s";
	register Buffer	*b;
	int	bcount = 1,		/* To give each buffer a number */
		buf_width = 11;
	bool
		any_modified = NO,
		any_ntbf = NO,
		any_diverged = NO;

	for (b = world; b != NULL; b = b->b_next) {
		buf_width = max(buf_width, (int)strlen(b->b_name));
		any_modified |= IsModified(b);
		any_ntbf |= b->b_ntbf;
		any_diverged |= b->b_diverged;
	}

	TOstart("Buffer list");

	if (any_modified)
		Typeout("(* means buffer needs saving)");
	if (any_ntbf)
		Typeout("(+ means file hasn't been read yet)");
	if (any_diverged)
		Typeout("(# means file has been changed since buffer was read or written)");
	if (any_modified | any_ntbf | any_diverged)
		Typeout(NullStr);
	Typeout(fmt, "NO", "Lines", "Type", NullStr, NullStr, buf_width, "Name", "File");
	Typeout(fmt, "--", "-----", "----", NullStr, NullStr, buf_width, "----", "----");
	for (b = world; b != NULL; b = b->b_next) {
		char
			bnostr[10],
			linestr[10];

		swritef(bnostr, sizeof(bnostr), "%d", bcount++);
		if (b->b_ntbf)
			strcpy(linestr, "?");
		else
			swritef(linestr, sizeof(linestr), "%d",
				LinesTo(b->b_first, (LinePtr)NULL));
		Typeout(fmt, bnostr, linestr, TypeNames[b->b_type],
				b->b_diverged ? "#" : NullStr,
				IsModified(b) ? "*" :
					 b->b_ntbf ? "+" : NullStr,
				buf_width,	/* For the * (variable length field) */
				b->b_name,
				filename(b));

		if (TOabort)
			break;
	}
	TOstop();
}

private void
bufname(b)
register Buffer	*b;
{
	char	tmp[100],
		*cp;
	int	try = 1;

	if (b->b_fname == NULL)
		complain("[No file name]");
	cp = basename(b->b_fname);
	strcpy(tmp, cp);
	while (buf_exists(tmp)) {
		swritef(tmp, sizeof(tmp), "%s.%d", cp, try);
		try += 1;
	}
	setbname(b, tmp);
}

void
buf_clear(b)
register Buffer	*b;
{
	lfreelist(b->b_first);
	b->b_first = b->b_dot = b->b_last = NULL;
	(void) listput(b, b->b_first);

	SavLine(b->b_dot, NullStr);
	b->b_char = 0;
	AllMarkReset(b, b->b_dot);
	if (b == curbuf)
		getDOT();

	diverge(b, NO);
	if (b->b_modified)
		UpdModLine = YES;
	b->b_ntbf = b->b_modified = NO;

#ifdef USE_INO
	b->b_dev = 0;
	b->b_ino = 0;
#endif
	b->b_mtime = 0;
}

/* Returns pointer to buffer with name NAME, or if NAME is a string of digits
   returns the buffer whose number equals those digits.  Otherwise, returns
   NULL. */

Buffer *
buf_exists(name)
register char	*name;
{
	register Buffer	*bp;

	if (name == NULL)
		return NULL;

	for (bp = world; bp != NULL; bp = bp->b_next)
		if (strcmp(bp->b_name, name) == 0)
			return bp;

	return NULL;
}

/* Returns buffer pointer with a file name NAME, if one is found.
 * If target is NULL, all buffers are searched; otherwise, only
 * target is examined.  Match is by inode (to catch links) or
 * canonical name.
 *
 * Divergence is diligently searched for.  In particular, all
 * buffers are examined to see if they match the specified file,
 * in name or inode.  If they do, divergence is checked (i.e. loss
 * of underlying file, change in inode number, or modification
 * time different from last visit).
 *
 * DS_REUSE can be used to avoid redundant stat calls.  Use it
 * with care!
 */

bool
	was_dir,	/* do_stat found a directory */
	was_file;	/* do_stat found a (plain) file */

Buffer *
do_stat(name, target, flags)
register char	*name;
Buffer	*target;
int	flags;
{
	register Buffer	*b = NULL;
	Buffer	*result = NULL;
	char	fnamebuf[FILESIZE];
	static struct stat	stbuf;

	PathParse(name, fnamebuf);

	if ((flags & DS_REUSE) == 0) {
		stbuf.st_mode = S_IFREG;	/* default if stat fails */
#ifdef USE_INO
		stbuf.st_ino = 0;	/* impossible number */
		stbuf.st_dev = 0;
#endif
		stbuf.st_mtime = 0;
		(void) stat(fnamebuf, &stbuf);
		was_dir = (stbuf.st_mode & S_IFMT) == S_IFDIR;
		was_file = stbuf.st_ino != 0 && (stbuf.st_mode & S_IFMT) == S_IFREG;
	}
	if ((flags & DS_DIR) == 0 && was_dir)
		complain("[%s is a directory]", fnamebuf);
	if (flags & DS_SET) {
		if ((stbuf.st_mode & S_IFMT) == S_IFREG) {
#ifdef USE_INO
			target->b_dev = stbuf.st_dev;
			target->b_ino = stbuf.st_ino;
#endif
			target->b_mtime = stbuf.st_mtime;
		} else {
#ifdef USE_INO
			target->b_dev = 0;
			target->b_ino = 0;
#endif
			target->b_mtime = 0;
		}
		diverge(target, NO);
	}

	for (b = world; b != NULL; b = b->b_next) {
#ifdef USE_INO
		if(b->b_ino != 0 && b->b_ino == stbuf.st_ino
		&& b->b_dev != 0 && b->b_dev == stbuf.st_dev)
		{
			/* A buffer's inode got a match; check divergence:
			 * - name is different & can't stat buffer's fname
			 * - name is different & stat yields a different inode
			 * - inode now refers to a non-file
			 */
			struct stat	stbchk;

			if ((strcmp(b->b_fname, fnamebuf) != 0
			   && (stat(b->b_fname, &stbchk) == -1
			      || b->b_ino != stbchk.st_ino || b->b_dev != stbchk.st_dev))
			|| (stbuf.st_mode & S_IFMT) != S_IFREG)
			{
				/* false match: buffer's file has lost its inode */
				b->b_ino = 0;
				b->b_dev = 0;
				diverge(b, YES);
				continue;	/* try again */
			}
			/* true match -- check times */
			if (b->b_mtime != stbuf.st_mtime)
				diverge(b, YES);
			if (target == NULL || target == b)
				result = b;
		} else if (b->b_fname != NULL && strcmp(b->b_fname, fnamebuf) == 0) {
			/* a name (but not inode) match */
			if (b->b_ino != stbuf.st_ino
			|| (stbuf.st_mode & S_IFMT) != S_IFREG)
			{
				/* one or the other has an inode */
				b->b_ino = 0;
				b->b_dev = 0;
				diverge(b, YES);
			}
			if (target == NULL || target == b)
				result = b;
		}
#else
		if (b->b_fname != NULL && strcmp(b->b_fname, fnamebuf) == 0) {
			/* a name match -- check times */
			if (stbuf.st_mtime != b->b_mtime)
				diverge(b, YES);
			if (target == NULL || target == b)
				result = b;
		}
#endif
	}
	return result;
}

private void
setbname(b, name)
register Buffer	*b;
register char	*name;
{
	UpdModLine = YES;	/* Kludge ... but speeds things up considerably */
	if (name != NULL) {
		if (b->b_name == NoName)
			b->b_name = NULL;
		b->b_name = freealloc((UnivPtr) b->b_name, strlen(name) + 1);
		strcpy(b->b_name, name);
	} else {
		b->b_name = NULL;
	}
#ifdef MAC
	Bufchange = YES;
#endif
}

void
setfname(b, name)
register Buffer	*b;
register char	*name;
{
	char	wholename[FILESIZE],
		oldname[FILESIZE],
		*oldptr = NULL;
	Buffer	*save = curbuf;

	SetBuf(b);
	UpdModLine = YES;	/* Kludge ... but speeds things up considerably */
	if (b->b_fname != NULL) {
		oldptr = strcpy(oldname, b->b_fname);
		free((UnivPtr) b->b_fname);
		b->b_fname = NULL;
	}
	if (name != NULL) {
		PathParse(name, wholename);
		curbuf->b_fname = strcpy(
			(char *)emalloc(strlen(wholename) + 1), wholename);
	}
	DoAutoExec(curbuf->b_fname, oldptr);

	/* until they're known, zero these */
#ifdef USE_INO
	curbuf->b_dev = 0;
	curbuf->b_ino = 0;
#endif
	curbuf->b_mtime = 0;
	diverge(curbuf, NO);

	SetBuf(save);
#ifdef MAC
	Bufchange = YES;
#endif
}

/* Find the file `fname' into buf and put in in window `w' */

Buffer *
do_find(w, fname, force, do_macros)
register Window	*w;
register char	*fname;
bool	force;
bool	do_macros;
{
	register Buffer *b;
	Buffer	*oldb = curbuf;

	b = do_stat(fname, (Buffer *)NULL, DS_NONE);
	if (b == NULL) {
		b = mak_buf();
		setfname(b, fname);
		bufname(b);
		(void) do_stat(b->b_fname, b, DS_SET | DS_REUSE);

		b->b_ntbf = force;
		SetBuf(b);	/* force => load the file */
		if (w)
			tiewind(w, b);

		/* We now execute all pending macro text, on the
		 * unwarranted presumption that it must have come
		 * from an auto-execute-macro.  If we didn't do this
		 * here, it would get delayed until the current
		 * command was finished, which may be too late in the
		 * case of UNIX_cmdline, watch_input, find_tag, or
		 * ErrParse.
		 *
		 * There are some SetBuf(b) calls within the dispatch,
		 * but they do not cause reading of the file
		 * because b->b_ntbf will be false at this point.
		 * One consequence will be that the macro will be executed
		 * on the unfilled buffer -- somewhat surprising!
		 *
		 * ??? This code is a fudge, and should be replaced
		 * by a more elegant solution.
		 */
		if (do_macros) {
			ZXchar	c;
			int	saved_tcmd = this_cmd;
			int	saved_lcmd = last_cmd;
			int	saved_as, saved_ac;

			save_arg(saved_as, saved_ac);
			last_cmd = this_cmd = OTHER_CMD;
			for (;;) {
				cmd_sync();
				if ((c = peekchar) != EOF) {
					/* double ugh! */
					peekchar = EOF;
				} else if ((c = mac_getc()) != EOF) {
					add_stroke(c);
				} else {
					break;
				}
				dispatch(LastKeyStruck=c);
			}
			last_cmd = saved_lcmd;
			this_cmd = saved_tcmd;
			restore_arg(saved_as, saved_ac);
		}
		/* ??? At this point, we make the rash assumption
		 * that buffer oldb still exists, even though
		 * the macro text could have deleted it.
		 */
		b->b_ntbf = !force;
		/*
		 * the file will be read when the user next mentions Buffer b
		 */
		SetBuf(oldb);
	} else {
		if (force) {
			SetBuf(b);	/* b->b_ntbf => load the file  */
			SetBuf(oldb);
		}
		if (w)
			tiewind(w, b);
	}
	return b;
}

/* set alternate buffer */

void
SetABuf(b)
Buffer	*b;
{
	if (b != NULL)
		lastbuf = b;
}


/* check to see if BP is a valid buffer pointer */
bool
valid_bp(bp)
register Buffer	*bp;
{
	register Buffer	*b;

	for (b = world; b != NULL; b = b->b_next)
		if (b == bp)
			return YES;
	return NO;
}

void
SetBuf(newbuf)
register Buffer	*newbuf;
{
	if (newbuf == curbuf || newbuf == NULL)
		return;

	if (!valid_bp(newbuf))
		complain("Internal error: (0x%x) is not a valid buffer pointer!", newbuf);
	lsave();
	curbuf = newbuf;
	getDOT();
	/* do the read now ... */
	if (curbuf->b_ntbf)
		read_file(curbuf->b_fname, NO);
#ifdef MAC
	Modechange = YES;
#endif
}

Buffer *
do_select(w, name)
register Window	*w;
register char	*name;
{
	register Buffer	*new;

	if ((new = buf_exists(name)) == NULL) {
		new = mak_buf();
		setfname(new, (char *)NULL);
		setbname(new, name);
	}
	if (w != NULL)
		tiewind(w, new);
	return new;
}

void
buf_init()
{
	SetBuf(do_select(curwind, Mainbuf));
}

LinePtr
lastline(lp)
register LinePtr	lp;
{
	register LinePtr	next;

	while ((next = lp->l_next) != NULL)
		lp = next;
	return lp;
}

LinePtr
next_line(line, num)
register LinePtr	line;
register int	num;
{
	if (num < 0)
		return prev_line(line, -num);
	if (line != NULL)
		while (--num >= 0 && line->l_next != NULL)
			line = line->l_next;
	return line;
}

LinePtr
prev_line(line, num)
register LinePtr	line;
register int	num;
{
	if (num < 0)
		return next_line(line, -num);
	if (line != NULL)
		while (--num >= 0 && line->l_prev != NULL)
			line = line->l_prev;
	return line;
}
