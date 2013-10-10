#include <support.h>

#include "global.h"
#include "clipbrd.h"
#include "edit.h"
#include "memory.h"
#include "options.h"
#include "rsc.h"
#include "set.h"
#include "block.h"

/* lokale Prototypen *******************************************************/
static void	block_demark	(TEXTP t_ptr);
static bool	tab_ok			(ZEILEP a, bool tab, int tabsize);
static void	block_setzen	(TEXTP t_ptr);
static bool	block_delete	(TEXTP t_ptr, RINGP t);
static bool	block_einsetzen(TEXTP t_ptr, RINGP t);

/* lokale Variablen ********************************************************/

static int	undo_anf_x, undo_end_x;
static long	undo_anf_y, undo_end_y;
static RING	trash_text;
static bool	trash_init = FALSE;

/*
 * Trash: Puffer fÅr selektierte Blîcke, die Åberschrieben wurden. 
*/
static void trash_takes_text(RINGP r)
{
	if (!trash_init)
	{
		init_textring(&trash_text);
		trash_init = TRUE;
	}

	kill_textring(&trash_text);
	trash_text = *r;
	FIRST(r)->vorg = &trash_text.head;
	LAST(r)->nachf = &trash_text.tail;
}

/***************************************************************************/

void blk_mark_all(TEXTP t_ptr)
{
	ZEILEP col;

	if (t_ptr->block)
		block_demark(t_ptr);
	col = FIRST(&t_ptr->text);
	t_ptr->x1 = 0;
	t_ptr->p1 = col;
	t_ptr->z1 = 0;
	col = LAST(&t_ptr->text);
	t_ptr->x2 = col->len;
	t_ptr->p2 = col;
	t_ptr->z2 = t_ptr->text.lines-1;
	t_ptr->block_dir = FALSE;			/* Anfang und Ende nicht vertauscht */
	block_setzen(t_ptr);
	make_chg(t_ptr->link,BLK_CHANGE,0);
	make_chg(t_ptr->link,BLK_CHANGE,t_ptr->z2);
}


void blk_mark_word(TEXTP t_ptr)		/* Wort unter dem Cursor markieren */
{
	int	pos,len;
	char	*str;

	pos = t_ptr->xpos;
	len = t_ptr->cursor_line->len;
	if (pos < len)
	{
		str = TEXT(t_ptr->cursor_line)+pos;
		while(pos >= 0 && setin(t_ptr->loc_opt->wort_set, *str))
		{
			pos--;
			str--;
		}
		if (pos != t_ptr->xpos)
		{
			str++; 
			pos++;
			t_ptr->xpos = pos;
		}
		blk_mark(t_ptr, 0);
		while(pos <= len && setin(t_ptr->loc_opt->wort_set, *str))
		{
			pos++;
			str++;
		}
		t_ptr->xpos = pos;
		blk_mark(t_ptr, 1);
		restore_edit();
	}
}


static void search_forw(TEXTP t_ptr, char b_1, char b_2)	/* Klammersuche vorwÑrts */
{
	ZEILEP	lauf;
	int		x, level = 0, i;
	long		y;
	bool	found = FALSE;
	
	lauf = t_ptr->cursor_line;
	x = t_ptr->xpos;
	y = t_ptr->ypos;

	/* Trick fÅr identische b1/b2 (z.B. ") */
	if (b_1 == b_2)
	{
		level = 2;
		b_1 = '\0';
	}
	do
	{
		for (i = x; i < lauf->len; i++)
		{
			if (TEXT(lauf)[i] == b_1)
				level++;
			else if (TEXT(lauf)[i] == b_2)
				level--;
			if (level == 0)
			{
				x = i + 1;
				found = TRUE;
				break;
			}
		}
		if (!found)
		{
			NEXT(lauf);
			y++;
			x = 0;
		}
	}
	while (!found && !IS_TAIL(lauf));
	if (found)
	{
		t_ptr->cursor_line = lauf;
		t_ptr->xpos = x;
		t_ptr->ypos = y;
	}
	else
		Bconout(2, 7);
}

static void search_backw(TEXTP t_ptr, char b_1, char b_2)	/* Klammersuche rÅckw. */
{
	ZEILEP	lauf;
	int		x, level = 0, i;
	long		y;
	bool	found = FALSE;
	
	lauf = t_ptr->cursor_line;
	x = t_ptr->xpos;
	y = t_ptr->ypos;
	do
	{
		for (i = x; i >= 0; i--)		
		{
			if (TEXT(lauf)[i] == b_1)
				level++;
			else if (TEXT(lauf)[i] == b_2)
				level--;
			if (level == 0)
			{
				x = i;
				found = TRUE;
				break;
			}
		}
		if (!found)
		{
			VORG(lauf);
			y--;
			x = lauf->len-1;
		}
	}
	while (!found && !IS_HEAD(lauf));
	if (found)
	{
		t_ptr->cursor_line = lauf;
		t_ptr->xpos = x;
		t_ptr->ypos = y;
	}
	else
		Bconout(2, 7);
}

bool blk_mark_brace(TEXTP t_ptr)
{
	bool	found = FALSE;
	char		c, *p;
	int		index;
		
	if (t_ptr->xpos < t_ptr->cursor_line->len)
	{
		c = TEXT(t_ptr->cursor_line)[t_ptr->xpos];
		p = strchr(klammer_auf, c);
		if (p)
		{
			index = (int)(p - klammer_auf);
			blk_mark(t_ptr, 0);
			search_forw(t_ptr, klammer_auf[index], klammer_zu[index]);
			blk_mark(t_ptr, 1);
			found = TRUE;
		}
		p = strchr(klammer_zu, c);
		if (!found && p)
		{
			index = (int)(p - klammer_zu);
			/*
			 * der Cursor steht auf der Klammer, muû aber dahinter stehen, damit 
			 * sie auch selektiert wird!
			 */
			t_ptr->xpos += 1;			
			blk_mark(t_ptr, 0);     
			t_ptr->xpos -= 1;
			search_backw(t_ptr, klammer_auf[index], klammer_zu[index]);
			blk_mark(t_ptr, 1);
			found = TRUE;
		}
	}
	return found;
}


void get_blk_mark(TEXTP t_ptr, long *y, int *x)
{
	if (t_ptr->block_dir)	/* nach links */
	{
		*y = t_ptr->z2;
		*x = t_ptr->x2;
	}
	else							/* nach rechts */
	{
		*y = t_ptr->z1;
		*x = t_ptr->x1;
	}
}

void blk_mark(TEXTP t_ptr, int marke)
/* Blockstart und -ende setzen	*/
/* marke : 0 und 1					*/
{
	if (marke == 0)	/* Anfang setzten */
	{
		blk_demark(t_ptr);
		t_ptr->p2 = t_ptr->p1 = t_ptr->cursor_line;
		t_ptr->z2 = t_ptr->z1 = t_ptr->ypos;
		t_ptr->x2 = t_ptr->x1 = t_ptr->xpos;
		t_ptr->block_dir = FALSE;
	}
	else				/* Block aufziehen */
	{
		if (t_ptr->block_dir)
		{
			if (t_ptr->p1 == t_ptr->cursor_line && t_ptr->x1 == t_ptr->xpos)
				return;								/* Keine énderung */
			if (t_ptr->block)
			{
				block_demark(t_ptr);
				make_chg(t_ptr->link,BLK_CHANGE,t_ptr->z1);
				make_chg(t_ptr->link,BLK_CHANGE,t_ptr->ypos);
			}
			else
			{
				make_chg(t_ptr->link,BLK_CHANGE,t_ptr->ypos);
				make_chg(t_ptr->link,BLK_CHANGE,t_ptr->z2);
			}
			t_ptr->p1 = t_ptr->cursor_line;
			t_ptr->x1 = t_ptr->xpos;
			t_ptr->z1 = t_ptr->ypos;
		}
		else
		{
			if (t_ptr->p2==t_ptr->cursor_line && t_ptr->x2==t_ptr->xpos)
				return;								/* Keine énderung */
			if (t_ptr->block)
			{
				block_demark(t_ptr);
				make_chg(t_ptr->link,BLK_CHANGE,t_ptr->z2);
				make_chg(t_ptr->link,BLK_CHANGE,t_ptr->ypos);
			}
			else
			{
				make_chg(t_ptr->link,BLK_CHANGE,t_ptr->z1);
				make_chg(t_ptr->link,BLK_CHANGE,t_ptr->ypos);
			}
			t_ptr->p2 = t_ptr->cursor_line;
			t_ptr->x2 = t_ptr->xpos;
			t_ptr->z2 = t_ptr->ypos;
		}
		block_setzen(t_ptr);
	}
}


void blk_demark(TEXTP t_ptr)
{
	if (t_ptr->block)
	{
		block_demark(t_ptr);
		make_chg(t_ptr->link,BLK_CHANGE,t_ptr->z1);
		make_chg(t_ptr->link,BLK_CHANGE,t_ptr->z2);
		t_ptr->p1 = t_ptr->p2 = NULL;
		t_ptr->z1 = t_ptr->z2 = -1;
	}
}


void blk_copy(TEXTP t_ptr)
/* Kopiert Block aus einem Text auf das Clipbrd */
{
	RING t;

	if (!t_ptr->block)
		return;
	if (!ist_mem_frei())
		return;
	block_copy(t_ptr,&t);
	if (shift_pressed())
		clip_add_text(&t);
	else
		clip_takes_text(&t);
}

void line_copy(TEXTP t_ptr)
/* Kopiert aktuelle Zeile auf das Clipboard */
{
	ZEILEP	col = t_ptr->cursor_line;
	int	old_x;

	old_x = t_ptr->xpos;
	t_ptr->xpos = 0;
	blk_mark(t_ptr,0);
	if (IS_LAST(col))
	{
		t_ptr->xpos = col->len;
		blk_mark(t_ptr,1);
		t_ptr->xpos = old_x;
	}
	else
	{
		NEXT(col);
		t_ptr->cursor_line = col;
		blk_mark(t_ptr,1);
		VORG(col);
		t_ptr->cursor_line = col;
		t_ptr->xpos = old_x;
	}
	blk_copy(t_ptr);
	blk_demark(t_ptr);
}

void blk_paste(TEXTP t_ptr, RINGP t)
/* Setzt den Text t im Text an Cursorposition ein */
/* Der Cursor steht anschlieûend dahinter */
/* Ist ein Block da, wird er gelîscht */
{
	if (!ist_mem_frei())
		return;
	blk_delete(t_ptr);
	block_einsetzen(t_ptr, t);
	t_ptr->moved++;
	add_undo(BLK_PASTE);
}

void blk_delete(TEXTP t_ptr)
{
	RING t;

	if(!t_ptr->block)
		return;
	if (!ist_mem_frei())
		return;
	if (!block_delete(t_ptr, &t))
		return;
	trash_takes_text(&t);
	t_ptr->moved++;
	add_undo(BLK_DEL);
}

void blk_cut(TEXTP t_ptr)
{
	RING t, t2;

	if (!t_ptr->block)
		return;
	if (!ist_mem_frei())
		return;
	if (!block_delete(t_ptr, &t))
		return;
	init_textring(&t2);
	if (doppeln(&t,&t2))
	{
		if (shift_pressed())
			clip_add_text(&t2);
		else
			clip_takes_text(&t2);
	}
	undo_takes_text(&t);
	t_ptr->moved++;
	add_undo(BLK_CUT);
}

void blk_undo(TEXTP t_ptr, int undo)
{
	RING	t;

	if (!ist_mem_frei())
		return;
	if (undo==BLK_PASTE || undo==BLK_PASTE_TRASH)
	/* Block muû wieder gelîscht werden */
	{
		blk_demark(t_ptr);
		t_ptr->p1 = get_line(&t_ptr->text,undo_anf_y);
		t_ptr->z1 = undo_anf_y;
		t_ptr->x1 = undo_anf_x;
		t_ptr->p2 = get_line(&t_ptr->text,undo_end_y);
		t_ptr->z2 = undo_end_y;
		t_ptr->x2 = undo_end_x;
		block_setzen(t_ptr);
		block_delete(t_ptr, &t);				/* Block ausschneiden und als Undotext */
		if (undo==BLK_PASTE)
		{
			undo_takes_text(&t);
			add_undo(BLK_CUT);
		}
		else
		{
			trash_takes_text(&t);
			add_undo(BLK_DEL);
		}
		t_ptr->moved++;
	}
	if (undo == BLK_CUT)							/* Block muû wieder eingefÅgt werden */
	{
		RINGP tp;

		t_ptr->xpos = undo_anf_x;
		tp = get_undo_text();
		block_einsetzen(t_ptr, tp);
		add_undo(BLK_PASTE);
	}
	if (undo==BLK_DEL)							/* Text aus Papierkorb wieder einsetzten */
	{

		t_ptr->xpos = undo_anf_x;
		block_einsetzen(t_ptr, &trash_text);
		add_undo(BLK_PASTE_TRASH);
	}
}

void blk_right(TEXTP t_ptr)
{
	ZEILEP 	lauf;
	long		y, ende;
	bool	t = t_ptr->loc_opt->tab;

	if (!t_ptr->block)
		return;
	lauf = t_ptr->p1;
	y = t_ptr->z1;
	ende = t_ptr->z2;
	if (y < ende)
	{
		int  anz, i;
		char	c, *str;

		if (shift_pressed())		/* mit Shift: nur ein ' ' */
		{
			anz = 1;
			c = ' ';
		}
		else
		{	
			if (t)
			{
				anz = 1;
				c = '\t';
			}
			else
			{
				anz = t_ptr->loc_opt->tabsize;
				c = ' ';
			}
		}
		t_ptr->moved++;
		clr_undo();
		if (t_ptr->x1>0) t_ptr->x1 += anz;
		while (y<ende || t_ptr->x2>0)
		{
			if (lauf->len+anz>MAX_LINE_LEN)
			{
				inote(1, 0, TOOLONG, MAX_LINE_LEN);
				break;
			}
			str = REALLOC(&lauf,0,anz);
			for (i=anz; (--i)>=0; )
				*str++ = c;
			if (y==t_ptr->z1)
				t_ptr->p1 = lauf;
			if (y==ende)
			{
				t_ptr->p2 = lauf;
				break;
			}
			NEXT(lauf);
			y++;
		}
		if (t_ptr->x2>0) t_ptr->x2 += anz;
		t_ptr->cursor_line = get_line(&t_ptr->text,t_ptr->ypos);
		make_chg(t_ptr->link,TOTAL_CHANGE,t_ptr->z1);
	}
}

void blk_left(TEXTP t_ptr)
{
	ZEILEP 	lauf;
	long		y, ende;
	bool	t = t_ptr->loc_opt->tab;
	int		ts = t_ptr->loc_opt->tabsize;

	if (!t_ptr->block)
		return;
	lauf = t_ptr->p1;
	y = t_ptr->z1;
	ende = t_ptr->z2;
	if (y < ende)
	{
		int anz;

		if (shift_pressed())
		{
			anz = ts = 1;
			t = FALSE;
		}
		else
		{
			if (t)
				anz = 1;
			else
				anz = ts;
		}		
		t_ptr->moved++;
		clr_undo();
		if (tab_ok(lauf,t,ts))
		{
			if (t_ptr->x1 <= anz)
				t_ptr->x1 = 0;
			else
				t_ptr->x1 -= anz;
		}
		while (y < ende || t_ptr->x2 > 0)
		{
			if (tab_ok(lauf,t,ts))
			{
				REALLOC(&lauf, 0, -anz);
				if (y == t_ptr->z1)
					t_ptr->p1 = lauf;
				if (y == ende)
					t_ptr->p2 = lauf;
			}
			if (y == ende)
				break;
			NEXT(lauf);
			y++;
		}
		if (tab_ok(lauf,t,ts))
		{
			if (t_ptr->x2 <= anz)
				t_ptr->x2 = 0;
			else
				t_ptr->x2 -= anz;
		}
		t_ptr->cursor_line = get_line(&t_ptr->text, t_ptr->ypos);
		make_chg(t_ptr->link, POS_CHANGE, 0);
		make_chg(t_ptr->link, TOTAL_CHANGE, t_ptr->z1);
	}
}

/*-------------------------------------------------------------------*/

void str_ch_uprlwr (char *line)
{
	char stra[2],strb[2];

	stra[1] = strb[1] = EOS;

	while (*line != EOS)
	{
		stra[0] = *line;
		strb[0] = *line;
		str_toupper(stra);
		str_tolower(strb);
		if (stra[0] == *line)
			*line = strb[0];
		else
			*line = stra[0];

		line++;
	}
}

void strcap (char *line, SET wort_set)
{
	char stra[2],strb[2];

	stra[1] = strb[1] = EOS;
	stra[0] = *line;
	if (setin(wort_set,stra[0]))
	{
		str_toupper(stra);
		*line=stra[0];
	}
	line++;
	while (*line != EOS)
	{
		strb[0] = *(line-1);
		if (!setin(wort_set,strb[0]))
		{
			stra[0] = *line;
			if (setin(wort_set,stra[0]))
			{
				str_toupper(stra);
				*line=stra[0];
			}
		}
		line++;
	}
}

void blk_upplow(TEXTP t_ptr, int type)
{
	ZEILEP	lauf;
	long	y, ende;

	if (!t_ptr->block)
		return;

	lauf = t_ptr->p1;
	y = t_ptr->z1;
	ende = t_ptr->z2;
	if (y <= ende)
	{
		char *Tline, c;

		t_ptr->moved++;
		clr_undo();
		while (y < ende || t_ptr->x2 > 0)
		{
			if (y == t_ptr->z1)
				Tline = TEXT(lauf)+t_ptr->x1;
			else
				Tline = TEXT(lauf);
			if (y == ende)
			{
				c = *(TEXT(lauf)+t_ptr->x2);
				*(TEXT(lauf)+t_ptr->x2) = EOS; /* Zeile unterbrechen */
			}
			switch (type)
			{
				case BLK_UPPER:
					str_toupper (Tline);
					break;
				case BLK_LOWER :
					str_tolower (Tline);
					break;
				case BLK_CH_UPLO :
					str_ch_uprlwr (Tline);
					break;
				case BLK_CAPS :
					str_tolower (Tline);
					strcap (Tline,t_ptr->loc_opt->wort_set);
					break;
			}
			if (y == ende)
			{
				*(TEXT(lauf)+t_ptr->x2) = c; /* Zeile restaurieren */
				break;
			}
			NEXT(lauf);
			y++;
		}
		t_ptr->moved++;
		make_chg(t_ptr->link, POS_CHANGE, 0);
		make_chg(t_ptr->link, TOTAL_CHANGE, t_ptr->z1);
	}
}

/*----------------------------------------------------------------*/

static void block_demark(TEXTP t_ptr)
{
	t_ptr->block = FALSE;
	t_ptr->cursor = TRUE;
}

static bool tab_ok(ZEILEP a, bool tab, int tabsize)
{
	int 	anz;
	char *str;

	if (tab)
	{
		if (a->len==0) return(FALSE);
		str = TEXT(a);
		if (*str!='\t') return(FALSE);
	}
	else
	{
		anz = tabsize;
		if (a->len<anz) return(FALSE);
		str = TEXT(a);
		while ((--anz)>=0)
		{
			if (*str++!=' ') return(FALSE);
		}
	}
	return(TRUE);
}

static void block_setzen(TEXTP t_ptr)
{
	if (t_ptr->p1 == t_ptr->p2 && t_ptr->x1 == t_ptr->x2)
		return;

	if (t_ptr->z1 > t_ptr->z2)			/* Richtung falsch => tauschen */
	{
		ZEILEP col;
		long	l;
		int	i;

		t_ptr->block_dir ^= TRUE;
		i = t_ptr->x1;
		t_ptr->x1 = t_ptr->x2;
		t_ptr->x2 = i;
		col = t_ptr->p1;
		t_ptr->p1 = t_ptr->p2;
		t_ptr->p2 = col;
		l = t_ptr->z1;
		t_ptr->z1 = t_ptr->z2;
		t_ptr->z2 = l;
	}
	else if (t_ptr->z1 == t_ptr->z2 && t_ptr->x1 > t_ptr->x2)
	{
		int xw;

		t_ptr->block_dir ^= TRUE;
		xw = t_ptr->x1;
		t_ptr->x1 = t_ptr->x2;
		t_ptr->x2 = xw;
	}
	t_ptr->block = TRUE;
	t_ptr->cursor = FALSE;
}

static bool block_delete(TEXTP t_ptr, RINGP t)
{
	ZEILEP b_anf_col, b_end_col;
	long	lines;

	b_anf_col = t_ptr->p1;
	b_end_col = t_ptr->p2;
	if (b_end_col->len-t_ptr->x2+t_ptr->x1>MAX_LINE_LEN)
	{
		inote(1, 0, TOOLONG, MAX_LINE_LEN);
		return(FALSE);
	}

	/* Cursor an den Blockanfang bringen */
	t_ptr->ypos = t_ptr->z1;
	t_ptr->xpos = t_ptr->x1;

	undo_anf_y = t_ptr->z1;
	undo_anf_x = t_ptr->x1;
	undo_y = t_ptr->ypos;				/* globale Merkvariable */

	lines = t_ptr->z2-t_ptr->z1+1;
	if (lines==1)							/* ganz ohne Zeilenumbruch */
	{
		int len = t_ptr->x2-t_ptr->x1;
		ZEILEP	b;

		init_textring(t);
		b = FIRST(t);
		INSERT(&b, 0, len, TEXT(b_anf_col)+t_ptr->x1);
		REALLOC(&b_anf_col, t_ptr->x1, -len);
		t_ptr->cursor_line = b_anf_col;
	}
	else
	{
		col_split(&b_end_col,t_ptr->x2);
		NEXT(b_end_col);
		col_split(&b_anf_col,t_ptr->x1);

		/* Block ausschneiden */
		FIRST(t) = b_anf_col->nachf;
		b_anf_col->nachf->vorg = &t->head;
		LAST(t) = b_end_col->vorg;
		b_end_col->vorg->nachf = &t->tail;
		t->lines = lines;

		/* Kette wieder schlieûen */
		b_anf_col->nachf = b_end_col;
		b_end_col->vorg = b_anf_col;
		col_concate(&b_anf_col);
		t_ptr->cursor_line = b_anf_col;
	}
#if 0
Problem: Wenn ein Block markiert war, muû eventuell gescrollt werden
         und es kommt zu Redraw-Fehlern, da doch mehr Zeilen betroffen sind!

	if (lines==1)
	{
		make_chg(t_ptr->link,POS_CHANGE, 0);
		make_chg(t_ptr->link,LINE_CHANGE, undo_y);
	}
	else if (lines==2)
	{
		make_chg(t_ptr->link,POS_CHANGE, 0);
		make_chg(t_ptr->link,LINE_CHANGE, undo_y);
		make_chg(t_ptr->link,SCROLL_UP, undo_y+1);
	}
	else
#endif
	{
		make_chg(t_ptr->link,POS_CHANGE, 0);
		make_chg(t_ptr->link,TOTAL_CHANGE,t_ptr->z1);
	}
	t_ptr->block = FALSE;
	t_ptr->cursor = TRUE;
	t_ptr->text.lines -= (lines-1);
	t->ending = t_ptr->text.ending;
	t->max_line_len = t_ptr->text.max_line_len;
	t_ptr->max_line = NULL;
	return TRUE;
}

void block_copy(TEXTP t_ptr, RINGP t)
{
	ZEILEP a, lauf;

	init_textring(t);
	a = FIRST(t);									/* erste Zeile */
	lauf = t_ptr->p1;								/* Blockstart */
	if (lauf == t_ptr->p2)						/* nur eine Zeile */
	{
		INSERT(&a, 0, t_ptr->x2-t_ptr->x1, TEXT(lauf)+t_ptr->x1);
		a->info |= ABSATZ;
	}
	else
	{
		ZEILEP new, ende;

		/* erste Zeile teilweise */
		INSERT(&a, 0, lauf->len-t_ptr->x1, TEXT(lauf)+t_ptr->x1);
		if (IS_ABSATZ(lauf)) 
			a->info |= ABSATZ;
		else 
			a->info &= (~ABSATZ);
		ende = t_ptr->p2;
		NEXT(lauf);
		NEXT(a);													/* TAIL im neuen Text */
		while (lauf != ende)
		{
			new = new_col(TEXT(lauf), lauf->len);
			if (IS_ABSATZ(lauf)) 
				new->info |= ABSATZ;
			col_insert(a->vorg,new);
			t->lines++;
			NEXT(lauf);
		}
		new = new_col(TEXT(lauf),t_ptr->x2);			/* letzte Zeile teilweise */
		new->info |= ABSATZ;
		col_insert(a->vorg,new);
		t->lines++;
	}
	t->ending = t_ptr->text.ending;
	t->max_line_len = t_ptr->text.max_line_len;
}

/* Der Cursor von t_ptr steht anschlieûend hinter der EinfÅgung */
static bool block_einsetzen(TEXTP t_ptr, RINGP in)
{
	RING	t;
	ZEILEP	a,b,
			col = t_ptr->cursor_line;
	long	len;

	a = FIRST(in);
	b = LAST(in);
	if ((a!=b &&
		  (t_ptr->xpos+a->len>MAX_LINE_LEN ||
			b->len+(col->len-t_ptr->xpos)>MAX_LINE_LEN)) ||
		 (a==b &&
		  col->len+a->len>MAX_LINE_LEN))
	{
		inote(1, 0, TOOLONG, MAX_LINE_LEN);
		return(FALSE);
	}

	init_textring(&t);
	doppeln(in, &t);
	a = FIRST(&t);
	b = LAST(&t);

#if 0
Problem: Wenn ein Block markiert war, muû eventuell gescrollt werden
         und es kommt zu Redraw-Fehlern, da doch mehr Zeilen betroffen sind!
         
	if (t.lines==1)			/* Ganz ohne ZeilenverÑnderung */
		make_chg(t_ptr->link,LINE_CHANGE,t_ptr->ypos);
	else if(t.lines==2)		/* Einen Zeilenumbruch */
	{
		make_chg(t_ptr->link,SCROLL_DOWN,t_ptr->ypos+1);
		make_chg(t_ptr->link,LINE_CHANGE,t_ptr->ypos);
		make_chg(t_ptr->link,LINE_CHANGE,t_ptr->ypos+1);
	}
	else
#endif
		make_chg(t_ptr->link,TOTAL_CHANGE,t_ptr->ypos);

	len = t.lines-1;
	t_ptr->text.lines += len;

	undo_anf_y = t_ptr->ypos;
	undo_anf_x = t_ptr->xpos;
	undo_end_y = undo_anf_y+len;
	undo_end_x = b->len;
	undo_y = t_ptr->ypos;								/* globale Merkvariable */
	if (len==0)
	{
		INSERT(&col, t_ptr->xpos, a->len, TEXT(a));
		undo_end_x += t_ptr->xpos;
		kill_textring(&t);
	}
	else
	{
		col_split(&col,t_ptr->xpos);					/* Textzeile splitten   */

		col->nachf->vorg = b;							/* Block einfÅgen unten */
		b->nachf = col->nachf;
		col_concate(&b);									/* Untere letzte Zeile	*/

		col->nachf = a;									/* Block einfÅgen oben */
		a->vorg = col;
		col_concate(&col);
	}
	/* Cursor hinter EinfÅgung */
	t_ptr->cursor_line = get_line(&t_ptr->text,undo_end_y);
	t_ptr->ypos = undo_end_y;
	t_ptr->xpos = undo_end_x;
	t_ptr->moved++;
	make_chg(t_ptr->link, POS_CHANGE, 0);
	t_ptr->max_line = NULL;
	return TRUE;
}


/*
 * Dialog(e)
*/
void	block_info(TEXTP t_ptr)
{
	char	str[30];
	RING	t;

	block_copy(t_ptr,&t);
	if (t_ptr->x1 == 0 && t_ptr->x2 == 0)
		t.lines -= 1;

	make_shortpath(t_ptr->filename, str, 30);
	set_string(blockinfo, BLONAME, str);					/* Name mit Pfad */

	set_long(blockinfo, BLOBYTES, textring_bytes(&t));	/* Grîûe in Bytes */

	if (t_ptr->text.ending != binmode)
		set_long(blockinfo, BLOZEILE, t.lines);
	else
		set_string(blockinfo, BLOZEILE, "--");		/* BinÑr: keine Zeilen */

	simple_mdial(blockinfo, 0);

	kill_textring(&t);
}
