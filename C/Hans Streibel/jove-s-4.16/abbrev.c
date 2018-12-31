/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

#include "jove.h"

#ifdef ABBREV	/* the body is the rest of this file */

#include "fp.h"
#include "jctype.h"
#include "abbrev.h"
#include "ask.h"
#include "commands.h"	/* for ExecCmd() */
#include "delete.h"
#include "insert.h"
#include "disp.h"
#include "fmt.h"
#include "move.h"
#include "wind.h"

#ifdef MSFILESYSTEM
# include <io.h>
#endif
#define HASHSIZE	20

struct abbrev {
	unsigned int	a_hash;
	char	*a_abbrev,
		*a_phrase;
	struct abbrev	*a_next;
	data_obj	*a_cmdhook;
};

private	void
	define proto((struct abbrev **, char *, char *));

#define GLOBAL	NMAJORS
private struct abbrev	*A_tables[NMAJORS + 1][HASHSIZE];	/* Must be zeroed! */

bool AutoCaseAbbrev = YES;	/* VAR: automatically do case on abbreviations */

private unsigned int
hash(a)
register char	*a;
{
	register unsigned int	hashval = 0;
	register char	c;

	while ((c = *a++) != '\0')
		hashval = (hashval << 2) + c;

	return hashval;
}

private void
def_abbrev(table)
struct abbrev	*table[HASHSIZE];
{
	char	abbrev[100],
		phrase[100];

	null_ncpy(abbrev, ask((char *)NULL, "abbrev: "), sizeof(abbrev)-1);
	null_ncpy(phrase, ask((char *)NULL, "abbrev: %s phrase: ", abbrev),
		sizeof(phrase)-1);
	define(table, abbrev, phrase);
}

private struct abbrev *
lookup_abbrev(table, abbrev)
register struct abbrev	*table[HASHSIZE];
register char	*abbrev;
{
	register struct abbrev	*ap;
	unsigned int	h;

	h = hash(abbrev);
	for (ap = table[h % HASHSIZE]; ap; ap = ap->a_next)
		if (ap->a_hash == h && strcmp(ap->a_abbrev, abbrev) == 0)
			break;
	return ap;
}

private void
define(table, abbrev, phrase)
register struct abbrev	*table[HASHSIZE];
char	*abbrev,
	*phrase;
{
	register struct abbrev	*ap;

	ap = lookup_abbrev(table, abbrev);
	if (ap == NULL) {
		register unsigned int	h = hash(abbrev);

		ap = (struct abbrev *) emalloc(sizeof *ap);
		ap->a_hash = h;
		ap->a_abbrev = copystr(abbrev);
		h %= HASHSIZE;
		ap->a_next = table[h];
		ap->a_cmdhook = NULL;
		table[h] = ap;
	} else
		free((UnivPtr) ap->a_phrase);
	ap->a_phrase = copystr(phrase);
}

void
AbbrevExpand()
{
	char	wordbuf[100];
	register char
		*wp = wordbuf,
		*cp;
	int	col;
	register char	c;
	int	UC_count = 0;
	struct abbrev	*ap;

	col = curchar;
	while (col != 0 && jisident(linebuf[col - 1]))
		col -= 1;
	if (curchar-col >= (int)sizeof(wordbuf))
		return;	/* too long for us -- ignore it */

	while (col < curchar) {
		c = linebuf[col];
		if (AutoCaseAbbrev && jisupper(c)) {
			UC_count += 1;
			c = CharDowncase(c);
		}
		*wp++ = c;
		col += 1;
	}
	*wp = '\0';

	if ((ap = lookup_abbrev(A_tables[curbuf->b_major], wordbuf)) != NULL
	|| (ap = lookup_abbrev(A_tables[GLOBAL], wordbuf)) != NULL)
	{
		del_char(BACKWARD, (wp - wordbuf), NO);

		for (cp = ap->a_phrase; (c = *cp) != '\0'; ) {
			if (UC_count > 0 && jislower(c)
			&& (cp == ap->a_phrase
			   || (UC_count > 1 && (jiswhite(cp[-1]) || cp[-1] == '-'))))
				c = CharUpcase(c);
			insert_c(c, 1);
			cp += 1;
		}
		if (ap->a_cmdhook != NULL)
			ExecCmd(ap->a_cmdhook);
	}
}

private char	*mode_names[NMAJORS + 1] = {
	"Fundamental Mode",
	"Text Mode",
	"C Mode",
#ifdef LISP
	"Lisp Mode",
#endif
	"Global"
};

private void
save_abbrevs(file)
char	*file;
{
	File	*fp;
	struct abbrev	*ap,
			**tp;
	char	buf[LBSIZE];
	int	i,
		count = 0;

	fp = open_file(file, buf, F_WRITE, YES);
	for (i = 0; i <= GLOBAL; i++) {
		fwritef(fp, "------%s abbrevs------\n", mode_names[i]);
		for (tp = A_tables[i]; tp < &A_tables[i][HASHSIZE]; tp++)
			for (ap = *tp; ap; ap = ap->a_next) {
				fwritef(fp, "%s:%s\n",
					ap->a_abbrev,
					ap->a_phrase);
				count += 1;
			}
	}
	f_close(fp);
	add_mess(" %d written.", count);
}

private void
rest_abbrevs(file)
char	*file;
{
	int
		mode = -1,	/* Should be ++'d immediately */
		lnum = 0;
	char	*phrase_p;
	File	*fp;
	char	buf[LBSIZE];

	fp = open_file(file, buf, F_READ, YES);
	while (mode<=GLOBAL && !f_gets(fp, genbuf, (size_t) LBSIZE)
		&& !genbuf[0] == '\0')
	{
		static const char	sep[] = "------";

		lnum += 1;
		if (strncmp(genbuf, sep, sizeof(sep)-1) == 0) {
			mode += 1;
		} else if (mode == -1 || (phrase_p = strchr(genbuf, ':')) == NULL) {
			complain("Abbrev. format error, line %d.", file, lnum);
			/* NOTREACHED */
		} else {
			*phrase_p++ = '\0';	/* Null terminate the abbrev. */
			define(A_tables[mode], genbuf, phrase_p);
		}
	}
	f_close(fp);
	message(NullStr);
}

void
DefGAbbrev()
{
	def_abbrev(A_tables[GLOBAL]);
}

void
DefMAbbrev()
{
	def_abbrev(A_tables[curbuf->b_major]);
}

void
SaveAbbrevs()
{
	char	filebuf[FILESIZE];

	save_abbrevs(ask_file((char *)NULL, (char *)NULL, filebuf));
}

void
RestAbbrevs()
{
	char	filebuf[FILESIZE];

	rest_abbrevs(ask_file((char *)NULL, (char *)NULL, filebuf));
}

void
EditAbbrevs()
{
	char	tname[128],
		*EditName = "Abbreviation Edit";
	Buffer	*obuf = curbuf,
		*ebuf;

	if ((ebuf = buf_exists(EditName)) != NULL) {
		if (ebuf->b_type != B_SCRATCH)
			confirm("Over-write buffer %b? ", ebuf);
	}
	SetBuf(ebuf = do_select(curwind, EditName));
	ebuf->b_type = B_SCRATCH;
	buf_clear(ebuf);
	/* Empty buffer.  Save the definitions to a tmp file
	   and read them into this buffer so we can edit them. */
	swritef(tname, sizeof(tname), "%s/%s", TmpDir,
#ifdef MAC
		".jabbXXX"	/* must match string in mac.c:Ffilter() */
#else
		"jabbXXXXXX"
#endif
		);
	(void) mktemp(tname);
	save_abbrevs(tname);
	setfname(ebuf, tname);
	read_file(tname, NO);
	message("[Edit definitions and then type ^X ^C]");
	Recur();		/* We edit them ... now */
	if (IsModified(ebuf)) {
		file_write(tname, NO);
		rest_abbrevs(tname);
	}
	(void) unlink(tname);
	if (valid_bp(obuf))
		SetBuf(do_select(curwind, obuf->b_name));
}

void
BindMtoW()
{
	struct abbrev	*ap;
	char	*word = ask((char *)NULL, "Word: ");

	if ((ap = lookup_abbrev(A_tables[curbuf->b_major], word)) == NULL
	&& (ap = lookup_abbrev(A_tables[GLOBAL], word)) == NULL)
		complain("%s: unknown abbrev.", word);

	ap->a_cmdhook = findmac("Macro: ");
}

#endif /* ABBREV */
