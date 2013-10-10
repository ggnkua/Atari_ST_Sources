#include "global.h"
#include "ausgabe.h"
#include "find.h"
#include "memory.h"
#include "options.h"
#include "rsc.h"
#include "set.h"
#include "text.h"

/*
 * Verwaltung der Texte als einfach verkettete Liste
*/
static TEXTP	text_list = NULL;

static void nullen(TEXTP t_ptr)
{
	t_ptr->cursor_line = FIRST(&t_ptr->text);
	t_ptr->file_date_time = -1L;
	t_ptr->xpos = 0;
	t_ptr->ypos = 0L;
	t_ptr->moved = 0;
	t_ptr->readonly = FALSE;
	t_ptr->blink = t_ptr->block = t_ptr->block_dir = t_ptr->up_down = FALSE;
	t_ptr->cursor = TRUE;
	t_ptr->namenlos = TRUE;
	t_ptr->loc_opt = &local_options[0];
	t_ptr->info_str[0] = EOS;
	t_ptr->filename[0] = EOS;
	t_ptr->filesys = NO_CASE;
	t_ptr->asave = 0;
	t_ptr->max_line = NULL;
}

void clear_text(TEXTP t_ptr)
{
	free_textring(&t_ptr->text);
	nullen(t_ptr);
}

TEXTP new_text(int link)
{
	TEXTP new, p;

	/* Nummer schon vergeben? */
	if (get_text(link) != NULL)
	{
		inote(1, 0, FATALERR, 9);
		return NULL;
	}
	new = (TEXTP)malloc(sizeof(TEXT));
	if (new != NULL)
	{
		new->next = NULL;

		/* Erster Text -> Wurzel */
		if (text_list == NULL)
			text_list = new;
		else
		{
			/* Text am Ende der Liste anh„ngen */
			p = text_list;
			while (p->next != NULL)
				p = p->next;
			p->next = new;
		}
		new->link = link;
		init_textring(&new->text);
		nullen(new);
		return new;		
	}
	else
		note(1, 0, NOMEMORY);	
	return NULL;
}

void destruct_text(TEXTP t_ptr)
{
	TEXTP p;

	/* Wurzel? */
	if (t_ptr == text_list)
		text_list = text_list->next;
	else
	{
		/* Vorg„nger suchen */
		p = text_list;
		while (p->next != t_ptr)
			p = p->next;

		/* und Aush„ngen */	
		p->next = t_ptr->next;
	}
	kill_textring(&t_ptr->text);
	free(t_ptr);
	t_ptr = NULL;
}

TEXTP get_text(int icon)
{
	TEXTP	p;

	if (icon == -1) 
		return NULL;
	p = text_list;
	while (p != NULL)
	{
		if (p->link == icon)
			return p;
		p = p->next;
	}
	return NULL;
}

void do_all_text(TEXT_DOFUNC func)
{
	TEXTP	p;
	
	p = text_list;
	while (p)
	{
		(*func)(p);
		p = p->next;
	}
}

static LOCOPTP get_locopt(char *filename, int fs)
{
	int	i;
	char	m[MUSTER_LEN + 3];
	
	for (i = 2; i < LOCAL_ANZ; i++)
	{
		if (local_options[i].muster[0] != EOS)
		{
			strcpy(m, "*.");
			strcat(m, local_options[i].muster);
			if (filematch(filename, m, fs))
				return &local_options[i];
		}
	}
	return &local_options[0];
}

void set_text_name(TEXTP t_ptr, char *filename, bool namenlos)
{
	if (!namenlos)
	{
		t_ptr->filesys = fs_case_sens(filename);
/*
		if (t_ptr->filesys == NO_CASE)
			str_toupper(filename);
*/
	}
	strcpy(t_ptr->filename, filename);	
	t_ptr->namenlos = namenlos;

	if (namenlos)
		t_ptr->loc_opt = &local_options[0];
	else if (t_ptr->text.ending == binmode)
		t_ptr->loc_opt = &local_options[1];
	else
		t_ptr->loc_opt = get_locopt(filename, t_ptr->filesys);
}

void update_loc_opt(void)
{
	TEXTP	t_ptr;
	
	t_ptr = text_list;
	while (t_ptr != NULL)	
	{
		if (t_ptr->text.ending == binmode)
			t_ptr->loc_opt = &local_options[1];
		else
		{
			if (!t_ptr->namenlos)
				t_ptr->loc_opt = get_locopt(t_ptr->filename, t_ptr->filesys);
		}
		t_ptr = t_ptr->next;
	}
}

/*
 * Leerzeichen/TABs am Zeilenden l”schen.
*/
bool strip_endings(TEXTP t_ptr)
{
	ZEILEP	lauf;
	int		i;
	char		c;

	lauf = FIRST(&t_ptr->text);
	while (!IS_TAIL(lauf))
	{
		for (i=lauf->len; (--i) >= 0; )
		{
			c = TEXT(lauf)[i];
			if (c != ' ' && c != '\t')
				break;
		}
		i++;
		if (i < lauf->len)								/* Zeile verkrzen */
		{
			REALLOC(&lauf,i,i-lauf->len);
			t_ptr->moved++;
		}
		NEXT(lauf);
	}
	return (t_ptr->moved != 0);
}

/*
 * L„ngste Zeile suchen
*/
int get_longestline(TEXTP t_ptr)
{
	ZEILEP	lauf;
	int		len;
	
	if (t_ptr->max_line != NULL)
	{
		lauf = t_ptr->cursor_line;
		lauf->exp_len = bild_pos(lauf->len, lauf, t_ptr->loc_opt->tab, t_ptr->loc_opt->tabsize) + 1;
	
		if (lauf->exp_len >= t_ptr->max_line->exp_len)	/* l„nger als die L„ngste */
		{
			t_ptr->max_line->is_longest = FALSE;	/* alte ist nicht mehr */
			t_ptr->max_line = lauf;
			lauf->is_longest = TRUE;
		}
		else									
		{
			if (lauf->is_longest)			/* wurde die L„ngste krzer */
				t_ptr->max_line = NULL;		/*	-> neue l„ngeste suchen */
		}
	}
		
	if (t_ptr->max_line == NULL)			/* neu suche */
	{
		len = 0;
		lauf = FIRST(&t_ptr->text);
		while (!IS_TAIL(lauf))
		{
			if (lauf->exp_len == -1)		/* L„nge hat sich ge„ndert */
				lauf->exp_len = bild_pos(lauf->len, lauf, t_ptr->loc_opt->tab, t_ptr->loc_opt->tabsize) + 1;
			if (lauf->exp_len > len)
			{
				t_ptr->max_line = lauf;
				len = lauf->exp_len;
			}
			lauf->is_longest = FALSE;		/* berall l”schen */
			NEXT(lauf);
		}
		t_ptr->max_line->is_longest = TRUE;
	}
	return t_ptr->max_line->exp_len;
}

int text_still_loaded(char *name)
{
	int	j, i = -1;
	TEXTP	t_ptr;

	t_ptr = text_list;
	while (t_ptr != NULL)
	{

		if (t_ptr->filesys == FULL_CASE)
			j = strcmp(t_ptr->filename, name);
		else
			j = stricmp(t_ptr->filename, name);
		if (!t_ptr->namenlos && j == 0)

/*
		if (!t_ptr->namenlos && filematch(t_ptr->filename, name, t_ptr->filesys))
*/
		{
			i = t_ptr->link;
			break;
		}
		t_ptr = t_ptr->next;
	}
	return i;
}
