/* vi.c */

/* Author:
 *	Steve Kirkendall
 *	16820 SW Tallac Way
 *	Beaverton, OR 97006
 *	kirkenda@jove.cs.pdx.edu, or ...uunet!tektronix!psueea!jove!kirkenda
 */


#include <ctype.h>
#include "vi.h"



/* This array describes what each key does */
#define NO_FUNC		(MARK (*)())0
#define NO_ARGS		0
#define CURSOR_COUNT	1
#define CURSOR		2
#define CURSOR_CNT_KEY	3
#define CURSOR_MOVED	4
#define CURSOR_EOL	5
#define ZERO		6
#define DIGIT		7
#define CURSOR_TEXT	8
#define CURSOR_CNT_CMD	9
#define KEYWORD		10
#define NO_FLAGS	0x00
#define	MVMT		0x01	/* this is a movement command */
#define PTMV		0x02	/* this can be *part* of a movement command */
#define FRNT		0x04	/* after move, go to front of line */
#define INCL		0x08	/* include last char when used with c/d/y */
#define LNMD		0x10	/* use line mode of c/d/y */
#define NCOL		0x20	/* this command can't change the column# */
#define NREL		0x40	/* this is "non-relative" -- set the '' mark */
#define SDOT		0x80	/* set the "dot" variables, for the "." cmd */
static struct keystru
{
	MARK	(*func)();	/* the function to run */
	char	args;		/* description of the args needed */
	char	flags;		/* other stuff */
}
	vikeys[] =
{
/* NUL not defined	*/	{NO_FUNC,	NO_ARGS,	NO_FLAGS},
/* ^A  not defined	*/	{NO_FUNC,	NO_ARGS,	NO_FLAGS},
/* ^B  page backward	*/	{movescroll,	CURSOR_CNT_CMD,	FRNT},
/* ^C  not defined	*/	{NO_FUNC,	NO_ARGS,	NO_FLAGS},
/* ^D  scroll dn 1/2page*/	{movescroll,	CURSOR_CNT_CMD,	NCOL},
/* ^E  scroll up	*/	{movescroll,	CURSOR_CNT_CMD,	NCOL},
/* ^F  page forward	*/	{movescroll,	CURSOR_CNT_CMD,	FRNT},
/* ^G  show file status	*/	{v_status,	NO_ARGS, 	NO_FLAGS},
/* ^H  move left, like h*/	{moveleft,	CURSOR_COUNT,	MVMT},
/* ^I  not defined	*/	{NO_FUNC,	NO_ARGS,	NO_FLAGS},
/* ^J  move down	*/	{movedown,	CURSOR_COUNT,	MVMT|LNMD},
/* ^K  not defined	*/	{NO_FUNC,	NO_ARGS,	NO_FLAGS},
/* ^L  redraw screen	*/	{v_redraw,	NO_ARGS,	NO_FLAGS},
/* ^M  mv front next ln */	{movedown,	CURSOR_COUNT,	MVMT|FRNT|LNMD},
/* ^N  move down	*/	{movedown,	CURSOR_COUNT,	MVMT|LNMD},
/* ^O  not defined	*/	{NO_FUNC,	NO_ARGS,	NO_FLAGS},
/* ^P  not defined	*/	{moveup,	CURSOR_COUNT,	MVMT|LNMD},
/* ^Q  not defined	*/	{NO_FUNC,	NO_ARGS,	NO_FLAGS},
/* ^R  redraw screen	*/	{v_redraw,	NO_ARGS,	NO_FLAGS},
/* ^S  not defined	*/	{NO_FUNC,	NO_ARGS,	NO_FLAGS},
/* ^T  not defined	*/	{NO_FUNC,	NO_ARGS,	NO_FLAGS},
/* ^U  scroll up 1/2page*/	{movescroll,	CURSOR_CNT_CMD,	NCOL},
/* ^V  not defined	*/	{NO_FUNC,	NO_ARGS,	NO_FLAGS},
/* ^W  not defined	*/	{NO_FUNC,	NO_ARGS,	NO_FLAGS},
/* ^X  not defined	*/	{NO_FUNC,	NO_ARGS,	NO_FLAGS},
/* ^Y  scroll down	*/	{movescroll,	CURSOR_CNT_CMD,	NCOL},
/* ^Z  not defined	*/	{NO_FUNC,	NO_ARGS,	NO_FLAGS},
/* ESC not defined	*/	{NO_FUNC,	NO_ARGS,	NO_FLAGS},
/* ^\  not defined	*/	{NO_FUNC,	NO_ARGS,	NO_FLAGS},
/* ^]  keyword is tag	*/	{v_tag,		KEYWORD,	NO_FLAGS},
/* ^^  not defined	*/	{NO_FUNC,	NO_ARGS,	NO_FLAGS},
/* ^_  not defined	*/	{NO_FUNC,	NO_ARGS,	NO_FLAGS},
/* SPC move right,like l*/	{moveright,	CURSOR_COUNT,	MVMT},
/*  !  run thru filter	*/	{v_filter,	CURSOR_MOVED,	NO_FLAGS},
/*  "  select cut buffer*/	{v_selcut,	CURSOR_CNT_KEY,	PTMV},
#ifndef NO_EXTENSIONS
/*  #  increment number	*/	{v_increment,	KEYWORD,	SDOT},
#else
/*  #  not defined	*/	{NO_FUNC,	NO_ARGS,	NO_FLAGS},
#endif
/*  $  move to rear	*/	{moverear,	CURSOR,		MVMT|INCL},
/*  %  move to match	*/	{movematch,	CURSOR,		MVMT|INCL},
/*  &  not defined	*/	{NO_FUNC,	NO_ARGS,	NO_FLAGS},
/*  '  move to a mark	*/	{movetomark,	CURSOR_CNT_KEY,	MVMT|FRNT|NREL|LNMD},
#ifndef NO_SENTENCE
/*  (  mv back sentence	*/	{movebsentence,	CURSOR_COUNT,	MVMT},
/*  )  mv fwd sentence	*/	{movefsentence,	CURSOR_COUNT,	MVMT},
#else
/*  (  not defined	*/	{NO_FUNC,	NO_ARGS,	NO_FLAGS},
/*  )  not defined	*/	{NO_FUNC,	NO_ARGS,	NO_FLAGS},
#endif
/*  *  not defined	*/	{NO_FUNC,	NO_ARGS,	NO_FLAGS},
/*  +  mv front next ln */	{movedown,	CURSOR_COUNT,	MVMT|FRNT|LNMD},
#ifndef NO_CHARSEARCH
/*  ,  reverse [fFtT] cmd*/	{move_ch,	CURSOR_CNT_CMD,	MVMT|INCL},
#else
/*  ,  not defined	*/	{NO_FUNC,	NO_ARGS,	NO_FLAGS},
#endif
/*  -  mv front prev ln	*/	{moveup,	CURSOR_COUNT,	MVMT|FRNT|LNMD},
/*  .  special...	*/	{NO_FUNC,	NO_ARGS,	NO_FLAGS},
/*  /  forward search	*/	{movefsrch,	CURSOR_TEXT,	MVMT|NREL},
/*  0  part of count?	*/	{NO_FUNC,	ZERO,		MVMT|PTMV},
/*  1  part of count	*/	{NO_FUNC,	DIGIT,		PTMV},
/*  2  part of count	*/	{NO_FUNC,	DIGIT,		PTMV},
/*  3  part of count	*/	{NO_FUNC,	DIGIT,		PTMV},
/*  4  part of count	*/	{NO_FUNC,	DIGIT,		PTMV},
/*  5  part of count	*/	{NO_FUNC,	DIGIT,		PTMV},
/*  6  part of count	*/	{NO_FUNC,	DIGIT,		PTMV},
/*  7  part of count	*/	{NO_FUNC,	DIGIT,		PTMV},
/*  8  part of count	*/	{NO_FUNC,	DIGIT,		PTMV},
/*  9  part of count	*/	{NO_FUNC,	DIGIT,		PTMV},
/*  :  run single EX cmd*/	{v_1ex,		CURSOR_TEXT,	NO_FLAGS},
#ifndef NO_CHARSEARCH
/*  ;  repeat [fFtT] cmd*/	{move_ch,	CURSOR_CNT_CMD,	MVMT|INCL},
#else
/*  ;  not defined	*/	{NO_FUNC,	NO_ARGS,	NO_FLAGS},
#endif
/*  <  shift text left	*/	{v_shiftl,	CURSOR_MOVED,	SDOT|FRNT},
/*  =  not defined	*/	{NO_FUNC,	NO_ARGS,	NO_FLAGS},
/*  >  shift text right	*/	{v_shiftr,	CURSOR_MOVED,	SDOT|FRNT},
/*  ?  backward search	*/	{movebsrch,	CURSOR_TEXT,	MVMT|NREL},
/*  @  not defined	*/	{NO_FUNC,	NO_ARGS,	NO_FLAGS},
/*  A  append at EOL	*/	{v_insert,	CURSOR_CNT_CMD,	SDOT},
/*  B  move back Word	*/	{movebWord,	CURSOR_COUNT,	MVMT},
/*  C  change to EOL	*/	{v_change,	CURSOR_EOL,	SDOT},
/*  D  delete to EOL	*/	{v_delete,	CURSOR_EOL,	SDOT},
/*  E  move end of Word	*/	{moveeWord,	CURSOR_COUNT,	MVMT|INCL},
#ifndef NO_CHARSEARCH
/*  F  move bk to char	*/	{moveFch,	CURSOR_CNT_KEY,	MVMT|INCL},
#else
/*  F  not defined	*/	{NO_FUNC,	NO_ARGS,	NO_FLAGS},
#endif
/*  G  move to line #	*/	{movetoline,	CURSOR_COUNT,	MVMT|NREL|LNMD},
/*  H  move to row	*/	{moverow,	CURSOR_CNT_CMD,	FRNT},
/*  I  insert at front	*/	{v_insert,	CURSOR_CNT_CMD,	SDOT},
/*  J  join lines	*/	{v_join,	CURSOR_COUNT,	SDOT},
#ifndef NO_EXTENSIONS
/*  K  look up keyword	*/	{v_keyword,	KEYWORD,	NO_FLAGS},
#else
/*  K  not defined	*/	{NO_FUNC,	NO_ARGS,	NO_FLAGS},
#endif
/*  L  move to last row	*/	{moverow,	CURSOR_CNT_CMD,	FRNT},
/*  M  move to mid row	*/	{moverow,	CURSOR_CNT_CMD,	FRNT},
/*  N  reverse prev srch*/	{moveNsrch,	CURSOR,		MVMT},
/*  O  insert above line*/	{v_insert,	CURSOR_CNT_CMD,	SDOT},
/*  P  paste before	*/	{v_paste,	CURSOR_CNT_CMD,	NO_FLAGS},
/*  Q  quit to EX mode	*/	{v_quit,	NO_ARGS,	NO_FLAGS},
/*  R  overtype		*/	{v_overtype,	CURSOR,		SDOT},
/*  S  change line	*/	{v_change,	CURSOR_MOVED,	SDOT},
#ifndef NO_CHARSEARCH
/*  T  move bk to char	*/	{moveTch,	CURSOR_CNT_KEY,	MVMT|INCL},
#else
/*  T  not defined	*/	{NO_FUNC,	NO_ARGS,	NO_FLAGS},
#endif
/*  U  undo whole line	*/	{v_undoline,	CURSOR,		FRNT},
/*  V  not defined	*/	{NO_FUNC,	NO_ARGS,	NO_FLAGS},
/*  W  move forward Word*/	{movefWord,	CURSOR_COUNT,	MVMT},
/*  X  delete to left	*/	{v_Xchar,	CURSOR_COUNT,	SDOT},
/*  Y  yank text	*/	{v_yank,	CURSOR_MOVED,	NO_FLAGS},
/*  Z  save file & exit	*/	{v_xit,		CURSOR_CNT_KEY,	NO_FLAGS},
/*  [  move back section*/	{movebsection,	CURSOR_CNT_KEY,	MVMT|LNMD|NREL},
/*  \  not defined	*/	{NO_FUNC,	NO_ARGS,	NO_FLAGS},
/*  ]  move fwd section */	{movefsection,	CURSOR_CNT_KEY,	MVMT|LNMD|NREL},
/*  ^  move to front	*/	{movefront,	CURSOR,		MVMT},
/*  _  not defined	*/	{NO_FUNC,	NO_ARGS,	NO_FLAGS},
/*  `  move to mark	*/	{movetomark,	CURSOR_CNT_KEY,	MVMT|NREL},
/*  a  append at cursor	*/	{v_insert,	CURSOR_CNT_CMD,	SDOT},
/*  b  move back word	*/	{movebword,	CURSOR_COUNT,	MVMT},
/*  c  change text	*/	{v_change,	CURSOR_MOVED,	SDOT},
/*  d  delete op	*/	{v_delete,	CURSOR_MOVED,	SDOT},
/*  e  move end word	*/	{moveeword,	CURSOR_COUNT,	MVMT|INCL},
#ifndef NO_CHARSEARCH
/*  f  move fwd for char*/	{movefch,	CURSOR_CNT_KEY,	MVMT|INCL},
#else
/*  f  not defined	*/	{NO_FUNC,	NO_ARGS,	NO_FLAGS},
#endif
/*  g  not defined	*/	{NO_FUNC,	NO_ARGS,	NO_FLAGS},
/*  h  move left	*/	{moveleft,	CURSOR_COUNT,	MVMT},
/*  i  insert at cursor	*/	{v_insert,	CURSOR_CNT_CMD,	SDOT},
/*  j  move down	*/	{movedown,	CURSOR_COUNT,	MVMT|NCOL|LNMD},
/*  k  move up		*/	{moveup,	CURSOR_COUNT,	MVMT|NCOL|LNMD},
/*  l  move right	*/	{moveright,	CURSOR_COUNT,	MVMT},
/*  m  define a mark	*/	{v_mark,	CURSOR_CNT_KEY,	NO_FLAGS},
/*  n  repeat prev srch	*/	{movensrch,	CURSOR, 	MVMT},
/*  o  insert below line*/	{v_insert,	CURSOR_CNT_CMD,	SDOT},
/*  p  paste after	*/	{v_paste,	CURSOR_CNT_CMD,	NO_FLAGS},
/*  q  not defined	*/	{NO_FUNC,	NO_ARGS,	NO_FLAGS},
/*  r  replace chars	*/	{v_replace,	CURSOR_CNT_KEY,	SDOT},
/*  s  subst N chars	*/	{v_subst,	CURSOR_COUNT,	SDOT},
#ifndef NO_CHARSEARCH
/*  t  move fwd to char	*/	{movetch,	CURSOR_CNT_KEY,	MVMT|INCL},
#else
/*  t  not defined	*/	{NO_FUNC,	NO_ARGS,	NO_FLAGS},
#endif
/*  u  undo		*/	{v_undo,	CURSOR,		NO_FLAGS},
/*  v  not defined	*/	{NO_FUNC,	NO_ARGS,	NO_FLAGS},
/*  w  move fwd word	*/	{movefword,	CURSOR_COUNT,	MVMT},
/*  x  delete character	*/	{v_xchar,	CURSOR_COUNT,	SDOT},
/*  y  yank text	*/	{v_yank,	CURSOR_MOVED,	NO_FLAGS},
/*  z  adjust scrn row	*/	{movez, 	CURSOR_CNT_KEY,	NCOL},
/*  {  back paragraph	*/	{movebparagraph,CURSOR_COUNT,	MVMT|LNMD},
/*  |  move to column	*/	{movetocol,	CURSOR_COUNT,	NREL},
/*  }  fwd paragraph	*/	{movefparagraph,CURSOR_COUNT,	MVMT|LNMD},
/*  ~  upper/lowercase	*/	{v_ulcase,	CURSOR,		SDOT},
/* DEL not defined	*/	{NO_FUNC,	NO_ARGS,	NO_FLAGS},
};



vi()
{
	register int		key;	/* keystroke from user */
	long			count;	/* numeric argument to some functions */
	register struct keystru	*keyptr;/* pointer to vikeys[] element */
	MARK			tcurs;	/* temporary cursor */
	int			prevkey;/* previous key, if d/c/y/</>/! */
	MARK			range;	/* start of range for d/c/y/</>/! */
	char			text[100];
	int			dotkey;	/* last "key" of a change */
	int			dotpkey;/* last "prevkey" of a change */
	int			dotkey2;/* last extra "getkey()" of a change */
	int			dotcnt;	/* last "count" of a change */
	register int		i;

	/* tell the redraw() function to start from scratch */
	redraw(MARK_UNSET, FALSE);
	msg((char *)0);

#ifdef lint
	/* lint says that "range" might be used before it is set.  This
	 * can't really happen due to the way "range" and "prevkey" are used,
	 * but lint doesn't know that.  This line is here ONLY to keep lint
	 * happy.
	 */
	range = 0L;
#endif

	/* safeguard against '.' with no previous command */
	dotkey = 0;

	/* Repeatedly handle VI commands */
	for (count = 0, prevkey = '\0'; mode == MODE_VI; )
	{
		/* if we've moved off the undoable line, then we can't undo it at all */
		if (markline(cursor) != U_line)
		{
			U_line = 0L;
		}

		/* report any changes from the previous command */
		if (rptlines >= *o_report)
		{
			redraw(cursor, FALSE);
			msg("%ld lines %s", rptlines, rptlabel);
		}
		rptlines = 0L;

		/* get the next command key.  It must be ASCII */
		do
		{
			key = getkey(WHEN_VICMD);
		} while (key < 0 || key > 127);

		/* change cw and cW commands to ce and cE, respectively */
		/* (Why?  because the real vi does it that way!) */
		if (prevkey == 'c')
		{
			if (key == 'w')
				key = 'e';
			else if (key == 'W')
				key = 'E';

			/* wouldn't work right at the end of a word unless we
			 * backspace one character before doing the move.  This
			 * will fix most cases.
			 */
			if (markidx(cursor) > 0 && (key == 'e' || key == 'E'))
			{
				cursor--;
			}
		}

		/* look up the structure describing this command */
		keyptr = &vikeys[key];

		/* if we're in the middle of a d/c/y/</>/! command, reject
		 * anything but movement or a doubled version like "dd".
		 */
		if (prevkey && key != prevkey && !(keyptr->flags & (MVMT|PTMV)))
		{
			beep();
			prevkey = 0;
			count = 0;
			continue;
		}

		/* set the "dot" variables, if we're supposed to */
		if ((keyptr->flags & SDOT)
		 || (prevkey && vikeys[prevkey].flags & SDOT))
		{
			dotkey = key;
			dotpkey = prevkey;
			dotkey2 = '\0';
			dotcnt = count;

			/* remember the line before any changes are made */
			if (U_line != markline(cursor))
			{
				U_line = markline(cursor);
				strcpy(U_text, fetchline(U_line));
			}
		}

		/* if this is "." then set other vars from the "dot" vars */
		if (key == '.')
		{
			key = dotkey;
			keyptr = &vikeys[key];
			prevkey = dotpkey;
			if (prevkey)
			{
				range = cursor;
			}
			if (count == 0)
			{
				count = dotcnt;
			}
			doingdot = TRUE;

			/* remember the line before any changes are made */
			if (U_line != markline(cursor))
			{
				U_line = markline(cursor);
				strcpy(U_text, fetchline(U_line));
			}
		}
		else
		{
			doingdot = FALSE;
		}

		/* process the key as a command */
		tcurs = cursor;
		switch (keyptr->args)
		{
		  case ZERO:
			if (count == 0)
			{
				tcurs = cursor & ~(BLKSIZE - 1);
				break;
			}
			/* else fall through & treat like other digits... */

		  case DIGIT:
			count = count * 10 + key - '0';
			break;

		  case KEYWORD:
			/* if not on a keyword, fail */
			pfetch(markline(cursor));
			key = markidx(cursor);
			if (!isalnum(ptext[key]) && ptext[key] != '_')
			{
				tcurs = MARK_UNSET;
				break;
			}

			/* find the start of the keyword */
			while (key > 0 && (isalnum(ptext[key - 1]) || ptext[key - 1] == '_'))
			{
				key--;
			}
			tcurs = (cursor & ~(BLKSIZE - 1)) + key;

			/* copy it into a buffer, and NUL-terminate it */
			i = 0;
			do
			{
				text[i++] = ptext[key++];
			} while (isalnum(ptext[key]) || ptext[key] == '_');
			text[i] = '\0';

			/* call the function */
			tcurs = (*keyptr->func)(text, tcurs, count);
			count = 0L;
			break;

		  case NO_ARGS:
			if (keyptr->func)
			{
				(*keyptr->func)();
			}
			else
			{
				beep();
			}
			count = 0L;
			break;
	
		  case CURSOR_COUNT:
			tcurs = (*keyptr->func)(cursor, count);
			count = 0L;
			break;
	
		  case CURSOR:
			tcurs = (*keyptr->func)(cursor);
			count = 0L;
			break;

		  case CURSOR_CNT_KEY:
			if (doingdot)
			{
				tcurs = (*keyptr->func)(cursor, count, dotkey2);
			}
			else if (keyptr->flags & SDOT
			 || (prevkey && vikeys[prevkey].flags & SDOT))
			{
				dotkey2 = getkey(0);
				tcurs = (*keyptr->func)(cursor, count, dotkey2);
			}
			else
			{
				tcurs = (*keyptr->func)(cursor, count, getkey(0));
			}
			count = 0L;
			break;
	
		  case CURSOR_MOVED:
			/* uppercase keys always act like doubled */
			if (isupper(key))
			{
				prevkey = key;
				range = cursor;
			}

			if (prevkey)
			{
				/* doubling up a command, use complete lines */
				range &= ~(BLKSIZE - 1);
				if (count)
				{
					tcurs = range + MARK_AT_LINE(count);
					count = 0;
				}
				else
				{
					tcurs = range + BLKSIZE;
				}
			}
			else
			{
				prevkey = key;
				range = cursor;
				key = -1; /* so we don't think we doubled yet */
			}
			break;

		  case CURSOR_EOL:
			/* act like CURSOR_MOVED with '$' movement */
			range = cursor;
			tcurs = moverear(cursor, 1L);
			count = 0L;
			prevkey = key;
			key = '$';
			keyptr = &vikeys['$'];
			break;

		  case CURSOR_TEXT:
			if (vgets(key, text, sizeof text) >= 0)
			{
				/* reassure user that <CR> was hit */
				qaddch('\r');
				refresh();

				/* call the function with the text */
				tcurs = (*keyptr->func)(cursor, text);
			}
			count = 0L;
			break;

		  case CURSOR_CNT_CMD:
			tcurs = (*keyptr->func)(cursor, count, key);
			count = 0L;
			break;
		}

		/* if that command took us out of vi mode, then exit the loop
		 * NOW, without tweaking the cursor or anything.  This is very
		 * important when mode == MODE_QUIT.
		 */
		if (mode != MODE_VI)
		{
			break;
		}

		/* now move the cursor, as appropriate */
		if (prevkey && markline(tcurs) > nlines)
		{
			/* destination for operator may be nlines + 1 */
			cursor = MARK_AT_LINE(nlines + 1);
		}
		else if (keyptr->args == CURSOR_MOVED)
		{
			/* the < and > keys have FRNT,
			 * but it shouldn't be applied yet
			 */
			cursor = adjmove(cursor, tcurs, 0);
		}
		else
		{
			cursor = adjmove(cursor, tcurs, keyptr->flags);
		}

		/* was that the end of a d/c/y/</>/! command? */
		if (prevkey && (prevkey == key || (keyptr->flags & MVMT)))
		{
			/* if the movement command failed, cancel operation */
			if (tcurs == MARK_UNSET)
			{
				prevkey = 0;
				count = 0;
				continue;
			}

			/* make sure range=front and tcurs=rear */
			if (cursor < range)
			{
				tcurs = range;
				range = cursor;
			}
			else
			{
				tcurs = cursor;
			}

			/* adjust for line mode */
			if (keyptr->flags & LNMD)
			{
				range &= ~(BLKSIZE - 1);
				tcurs &= ~(BLKSIZE - 1);
				tcurs += BLKSIZE;
			}

			/* adjust for inclusion of last char */
			if (keyptr->flags & INCL)
			{
				tcurs++;
			}

			/* temporarily move the cursor to "range" so that
			 * beforedo() remembers the cursor's real location.
			 * This is important if the user later does undo()
			 */
			cursor = range;

			/* run the function */
			tcurs = (*vikeys[prevkey].func)(range, tcurs);
			cursor = adjmove(cursor, tcurs, vikeys[prevkey].flags);

			/* cleanup */
			prevkey = 0;
		}
	}
}

/* This function adjusts the MARK value that they return; here we make sure
 * it isn't past the end of the line, and that the column hasn't been
 * *accidentally* changed.
 */
MARK adjmove(old, new, flags)
	MARK		old;	/* the cursor position before the command */
	register MARK	new;	/* the cursor position after the command */
	int		flags;	/* various flags regarding cursor mvmt */
{
	static int	colno;	/* the column number that we want */
	register char	*text;	/* used to scan through the line's text */
	register int	i;

	/* if the command failed, bag it! */
	if (new == MARK_UNSET)
	{
		beep();
		return old;
	}

	/* if this is a non-relative movement, set the '' mark */
	if (flags & NREL)
	{
		mark[26] = old;
	}

	/* make sure it isn't past the end of the file */
	if (markline(new) < 1)
	{
		new = MARK_FIRST;
	}
	else if (markline(new) > nlines)
	{
		new = MARK_LAST;
	}

	/* fetch the new line */
	pfetch(markline(new));

	/* move to the front, if we're supposed to */
	if (flags & FRNT)
	{
		new = movefront(new, 1L);
	}

	/* change the column#, or change the mark to suit the column# */
	if (!(flags & NCOL))
	{
		/* change the column# */
		i = markidx(new);
		if (i == BLKSIZE - 1)
		{
			new &= ~(BLKSIZE - 1);
			if (plen > 0)
			{
				new += plen - 1;
			}
			colno = BLKSIZE * 8; /* one heck of a big colno */
		}
		else if (plen > 0)
		{
			if (i >= plen)
			{
				new = (new & ~(BLKSIZE - 1)) + plen - 1;
			}
			colno = idx2col(new, ptext, FALSE);
		}
		else
		{
			new &= ~(BLKSIZE - 1);
			colno = 0;
		}
	}
	else
	{
		/* adjust the mark to get as close as possible to column# */
		for (i = 0, text = ptext; i <= colno && *text; text++)
		{
			if (*text == '\t' && !*o_list)
			{
				i += *o_tabstop - (i % *o_tabstop);
			}
			else if (*text > 0 && *text < ' ' || *text == 127)
			{
				i += 2;
			}
#ifndef NO_CHARATTR
			else if (*o_charattr && text[0] == '\\' && text[1] == 'f' && text[2])
			{
				text += 2; /* plus one more in "for()" stmt */
			}
#endif
			else
			{
				i++;
			}
		}
		if (text > ptext)
		{
			text--;
		}
		new = (new & ~(BLKSIZE - 1)) + (int)(text - ptext);
	}

	return new;
}
