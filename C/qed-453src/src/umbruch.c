#include "global.h"
#include "ausgabe.h"
#include "block.h"
#include "clipbrd.h"
#include "edit.h"
#include "memory.h"
#include "set.h"
#include "tasten.h"
#include "text.h"
#include "window.h"
#include "umbruch.h"

/* Muessen am Anfang jeden Umbruchs gesetzt werden */
static bool	tab;
static int		tab_size, lineal_len;
static SET		umbruch_set;

static bool Absatz		(ZEILEP col);
static bool too_short	(TEXTP t_ptr, ZEILEP col, long y);
static bool too_long 	(TEXTP t_ptr, ZEILEP col, long y);

void save_absatz(TEXTP t_ptr)
/* Es werden LZ und TABs am Absatzende gel”scht */
/* und im Absatz hinzugefgt							*/
{
	bool		action = FALSE;
	int		i;
	char		c;
	ZEILEP	lauf;

	setcpy(umbruch_set,t_ptr->loc_opt->umbruch_set);/* !! Muž gesetzt werden !! */
	setincl(umbruch_set,' ');								/* wenigstens das */
	lauf = FIRST(&t_ptr->text);
	while (!IS_TAIL(lauf))
	{
		if (IS_ABSATZ(lauf))					/* Absatz => LZ und TAB l”schen */
		{
			for (i=lauf->len; (--i)>=0 ; )
			{
				c = TEXT(lauf)[i];
				if (c!=' ' && c!='\t') break;
			}
			i++;
			if (i<lauf->len)		/* Zeile verkrzen */
			{
				REALLOC(&lauf,i,i-lauf->len);
				action = TRUE;
			}
		}
		else								/* Nicht Absatz => LZ anh„ngen */
		{
			c = TEXT(lauf)[lauf->len-1];
			if (!setin(umbruch_set,c) && lauf->len < MAX_LINE_LEN)
			{
				*REALLOC(&lauf,lauf->len,1) = ' ';
				action = TRUE;
			}
		}
		NEXT(lauf);
	}
	if (action)		/* Es wurde etwas ver„ndert */
	{
		make_chg(t_ptr->link,TOTAL_CHANGE,0);
		t_ptr->moved++;
		lauf = t_ptr->cursor_line = get_line(&t_ptr->text,t_ptr->ypos);
		if (t_ptr->xpos>lauf->len)
		{
			t_ptr->xpos = lauf->len;
			make_chg(t_ptr->link,POS_CHANGE,0);
		}
	}
}

static bool Absatz(ZEILEP col)
/* TRUE : Die Zeile ist die letzte Zeile eines Absatz */
/* FALSE : sonst													*/
{
	int	col_len = col->len;
	char	c = TEXT(col)[col_len-1];

	return (col_len==0 || IS_LAST(col) || !setin(umbruch_set,c));
}

void make_absatz(TEXTP t_ptr)
/* Absatzmarkierungen anbringen oder l”schen */
{
	ZEILEP lauf;

	setcpy(umbruch_set,t_ptr->loc_opt->umbruch_set);/* !! Muž gesetzt werden !! */
	setincl(umbruch_set,' ');								/* wenigstens das */
	lauf = FIRST(&t_ptr->text);
	if (t_ptr->loc_opt->umbrechen)
		while (!IS_TAIL(lauf))
		{
			if (Absatz(lauf))
				lauf->info |= ABSATZ;
			else
				lauf->info &= (~ABSATZ);		/* z.B. CR setzt immer Bit */
			NEXT(lauf);
		}
	else
		while (!IS_TAIL(lauf))
		{
			lauf->info &= (~ABSATZ);
			NEXT(lauf);
		}
}

static int long_brk(ZEILEP col)
/* Zeile ist zu lang. Wo soll sie abgebrochen werden (mind. ein Wort) */
{
	int	off, pos;
	char	c, *str;

	off = col_offset(col);
	pos = inter_pos(lineal_len,col,tab,tab_size);
	str = TEXT(col)+pos;
	pos--;
	c = *(--str);
   if (!setin(umbruch_set,c))
		while (pos>off && setin(umbruch_set,c))					/* Wortende suchen */
		{
			pos--;
			c = *(--str);
		}
	while (pos>off && !setin(umbruch_set,c))						/* Wortanfang suchen */
	{
		pos--;
		c = *(--str);
	}
	if (pos<=off)															/* nach rechts */
	{
		pos = inter_pos(lineal_len,col,tab,tab_size);
		str = TEXT(col)+pos;
		c = *str++;
		while (pos<=col->len && setin(umbruch_set,c))			/* Wortanf suchen */
		{
			pos++;
			c = *str++;
		}
		while (pos<=col->len && !setin(umbruch_set,c))			/* Wortende suchen */
		{
			pos++;
			c = *str++;
		}
		while (pos<=col->len && setin(umbruch_set,c))			/* Wortanf suchen */
		{
			pos++;
			c = *str++;
		}
		if (pos>=col->len)
			return 0;														/* nichts machen */
	}
	else
		pos++;
	return pos;
}

static int short_brk(ZEILEP col, int len)
/* Einer Zeile fehlen Zeichen, sie ist jetzt im Bild len lang */
/* Wo soll der Nachfolger (col) hochgezogen werden (mind. ein Wort) */
{
	char	*str, c;
	int	pos, merk_pos;

	pos = col_offset(col);
	str = TEXT(col)+pos;
	merk_pos = -1;
	if (!tab)
	{
		while (TRUE)
		{
			if (pos>=col->len) return col->len;					/* ganze Zeile */
			c = *str++;
			pos++;
			len++;
			if (len>lineal_len) break;								/* jetzt reichts */
			if (setin(umbruch_set,c))
				merk_pos = pos;
		}
	}
	else
	{
		int tabH;

		tabH = tab_size-(len%tab_size);
		while (TRUE)
		{
			if (pos>=col->len) return col->len;					/* ganze Zeile */
			c = *str++;
			pos++;
			if (c=='\t')
			{
				len += tabH;
				tabH = tab_size;
			}
			else
			{
				len++;
				if ((--tabH)==0) tabH = tab_size;
			}
			if (len>lineal_len) break;								/* jetzt reichts */
			if (setin(umbruch_set,c))
				merk_pos = pos;
		}
	}
	if (merk_pos>0) pos = merk_pos;
	else pos = 0;														/* nichts zu machen */
	return(pos);
}

/* !!! cursor_line muž hinterher entsprechend ypos gesetzt werden !!! */
static bool too_long(TEXTP t_ptr, ZEILEP col, long y)
{
	int	i, len, off;
	bool	absatz, weiter, changed;

	changed = FALSE;
	weiter = FALSE;
	while (bild_len(col,t_ptr->loc_opt->tab,t_ptr->loc_opt->tabsize)>lineal_len)							/* Zeile zu lang */
	{
		i = long_brk(col);										/* wo abbrechen */
		if (i==0)
		{
			weiter = FALSE;
			break;
		}
		absatz = IS_ABSATZ(col);
		len = col->len-i;											/* soviel abschneiden */
		if (absatz || col->nachf->len + len >= MAX_LINE_LEN)	/* col_split */
		{
			ZEILEP help;

			col_split(&col,i);
			t_ptr->text.lines++;
			if (t_ptr->ypos>y) t_ptr->ypos++;
			help = col->nachf;
			off = col_einrucken(&help);
			if (t_ptr->ypos==y && t_ptr->xpos>i)			/* Cursor umbrechen */
			{
				t_ptr->ypos++;
				t_ptr->xpos -= (i-off);
			}
			weiter = TRUE;
		}
		else															/* Text rumschieben */
		{
			ZEILEP help = col->nachf;

			off = col_offset(help);
			INSERT(&help,off,len,TEXT(col)+i);				/* Next verl„ngern */
			REALLOC(&col,i,-len);								/* Zeile krzen */
			if (t_ptr->ypos==y+1 && t_ptr->xpos>off)		/* Cursor verschieben */
			{
				t_ptr->xpos += len;
			}
			if (t_ptr->ypos==y && t_ptr->xpos>i)			/* Cursor umbrechen */
			{
				t_ptr->ypos++;
				t_ptr->xpos -= (i-off);
			}
			weiter = FALSE;
		}
		NEXT(col);													/* n„chste Zeile zu lang? */
		y++;
		changed = TRUE;
	}
	if (weiter) too_short(t_ptr,col,y);						/* n„chste Zeile zu kurz? */
	return (changed);
}

/* !!! cursor_line muž hinterher entsprechend ypos gesetzt werden !!! */
static bool too_short(TEXTP t_ptr, ZEILEP col, long y)
{
	int	len, off;
	ZEILEP	next_col;
	bool	changed;

	changed = FALSE;
	tab = t_ptr->loc_opt->tab;
	tab_size = t_ptr->loc_opt->tabsize;
	while (bild_len(col,t_ptr->loc_opt->tab,t_ptr->loc_opt->tabsize)<lineal_len && !(IS_ABSATZ(col)) && col->nachf->len > 0)
	{
		next_col = col->nachf;
		len = short_brk(next_col,bild_len(col,t_ptr->loc_opt->tab,t_ptr->loc_opt->tabsize));
		if (len==0) break;										/* nichts zu machen */
		off = col_offset(next_col);
		if (len==next_col->len)									/* ganze Zeile hochziehen */
		{
			if (t_ptr->ypos==y+1)								/* Cursor hochziehen */
			{
				t_ptr->ypos--;
				t_ptr->xpos += (col->len-off);
			}
			if (t_ptr->ypos>y+1) t_ptr->ypos--;
			REALLOC(&next_col,0,-off);
			col_concate(&col);
			t_ptr->text.lines--;									/* gleiche Zeile nochmal */
		}
		else															/* teilweise hochziehen */
		{
			len -= off;
			if (t_ptr->ypos==y+1 && t_ptr->xpos>=off)
			{
				if (t_ptr->xpos<off+len)
				{
					t_ptr->ypos--;
					t_ptr->xpos += (col->len-off);
				}
				else
					t_ptr->xpos -= len;
			}
			INSERT(&col,col->len,len,TEXT(next_col)+off);/* Zeile verl„ngern */
			REALLOC(&next_col,off,-len);						/* Zeile verkrzen */
			col = next_col;										/* n„chste Zeile weiter */
			y++;
		}
		changed = TRUE;
	}
	return(changed);
}

void umbruch(TEXTP t_ptr)
{
	long y = t_ptr->ypos;

	setcpy(umbruch_set,t_ptr->loc_opt->umbruch_set);/* !! Muž gesetzt werden !! */
	setincl(umbruch_set,' ');								/* wenigstens das */
	tab = t_ptr->loc_opt->tab;
	tab_size = t_ptr->loc_opt->tabsize;
	lineal_len = t_ptr->loc_opt->lineal_len;
	if (too_long(t_ptr, t_ptr->cursor_line, t_ptr->ypos))
	{
		t_ptr->cursor_line = get_line(&t_ptr->text,t_ptr->ypos);
		t_ptr->moved++;
		make_chg(t_ptr->link,POS_CHANGE,0);
		make_chg(t_ptr->link,TOTAL_CHANGE,y);
		clr_undo();
	}
	else if (too_short(t_ptr, t_ptr->cursor_line, t_ptr->ypos))
	{
		t_ptr->cursor_line = get_line(&t_ptr->text,t_ptr->ypos);
		t_ptr->moved++;
		make_chg(t_ptr->link,POS_CHANGE,0);
		make_chg(t_ptr->link,TOTAL_CHANGE,y);
		clr_undo();
	}
}

void format(TEXTP t_ptr)
{
	ZEILEP	lauf;
	long	y, start_y;
	bool	change;

	setcpy(umbruch_set,t_ptr->loc_opt->umbruch_set);/* !! Muž gesetzt werden !! */
	setincl(umbruch_set,' ');								/* wenigstens das */
	tab = t_ptr->loc_opt->tab;
	tab_size = t_ptr->loc_opt->tabsize;
	lineal_len = t_ptr->loc_opt->lineal_len;
	change = FALSE;
	lauf = t_ptr->cursor_line;
	y = t_ptr->ypos;
	if (y)
	{
		y--;
		VORG(lauf);
		while ((y > 0) && !(IS_ABSATZ(lauf)))
		{
			y--;
			VORG(lauf);
		}
		if (y)
		{
			y++;
			NEXT(lauf);
		}
	}
	/* lauf zeigt jetzt auf die erste Zeile des Absatz */
	start_y = y;
	lauf = lauf->vorg;	/* Einen davor, weil akt. Zeile ge„ndert wird */
	while(TRUE)
	{
		if (!too_long(t_ptr, lauf->nachf,y))
		{
			if (too_short(t_ptr, lauf->nachf,y))
				change = TRUE;
		}
		else
			change = TRUE;

		y++;
		NEXT(lauf);
		if (IS_ABSATZ(lauf))
			break;
	}
	if (change)
	{
		t_ptr->cursor_line = get_line(&t_ptr->text,t_ptr->ypos);
		t_ptr->moved++;
		make_chg(t_ptr->link,POS_CHANGE,0);
		make_chg(t_ptr->link,TOTAL_CHANGE,start_y);
		clr_undo();
	}
}

void total_format(TEXTP t_ptr)
{
	ZEILEP	lauf;
	long	y;
	bool	change;

	setcpy(umbruch_set,t_ptr->loc_opt->umbruch_set);/* !! Muž gesetzt werden !! */
	setincl(umbruch_set,' ');								/* wenigstens das */
	tab = t_ptr->loc_opt->tab;
	tab_size = t_ptr->loc_opt->tabsize;
	lineal_len = t_ptr->loc_opt->lineal_len;
	change = FALSE;
	graf_mouse(HOURGLASS, NULL);
	lauf = FIRST(&t_ptr->text);
	y = 0;
	while (!IS_TAIL(lauf))
	{
		/* lauf zeigt jetzt auf die erste Zeile des Absatz */
		lauf = lauf->vorg;	/* Einen davor, weil akt. Zeile ge„ndert wird */
		while(TRUE)
		{
			if (!too_long(t_ptr, lauf->nachf,y))
			{
				if (too_short(t_ptr, lauf->nachf,y))
					change = TRUE;
			}
			else
				change = TRUE;
			y++;
			NEXT(lauf);
			if (IS_ABSATZ(lauf))
				break;
		}
		NEXT(lauf);
	}
	if (change)
	{
		t_ptr->cursor_line = get_line(&t_ptr->text,t_ptr->ypos);
		t_ptr->moved++;
		make_chg(t_ptr->link,POS_CHANGE,0);
		make_chg(t_ptr->link,TOTAL_CHANGE,0);
		clr_undo();
	}
	graf_mouse(ARROW, NULL);
}
