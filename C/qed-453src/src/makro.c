#include <support.h>

#include "global.h"
#include "clipbrd.h"
#include "icon.h"
#include "memory.h"
#include "menu.h"
#include "rsc.h"
#include "text.h"
#include "window.h"
#include "makro.h"

extern bool f_to_desk;

/* exportierte Variablen *******************************************************/
bool	makro_play, makro_rec;
bool	makro_shift;


/*******************************************************************************/
#define MAKRO_PLAY_LEN 100				/* Makrolen expanded */
#define MAKRO_DEF_LEN  100				/* einzelne MakrolÑnge */

#define UNUSED	0							/* Werte fÅr mode */
#define TASTEN	1
#define BLOCK	2

/*******************************************************************************/
typedef struct 
{
	int		mode;
	int		len;
	int		key;			/* F1 .. F20 */
	char		name[10];
	union
	{
		unsigned int	tasten[MAKRO_DEF_LEN];
		RING				text;
	} daten;
} MAKRO;

/* lokale Variablen ************************************************************/
static unsigned int	makro_puffer[MAKRO_PLAY_LEN],
							*makro_ptr, *makro_end;
static MAKRO			makro_list[MAKRO_ANZ],
							*makro_rec_ptr,
							*makro_play_ptr;
static int				makro_play_counter;


bool from_makro(int *kstate, int *kreturn)
{
	if (makro_play)								/* Macro abspielen */
	{
retry:
		if (makro_ptr < makro_end)
		{
			norm_to_gem(*makro_ptr, kstate, kreturn);
			makro_ptr++;
			makro_shift = *kstate;
			return TRUE;
		}
		else											/* Abspielen beenden */
		{
			if (makro_play_counter > 1)
			{
				makro_play = FALSE;
				start_play(makro_play_ptr->key, makro_play_counter-1);
				goto retry;
			}
			else
				end_play();
		}
	}
	return FALSE;
}

void to_makro(int kstate, int kreturn)
{
	if (makro_rec && !makro_play)				/* Zeichen erfassen */
														/* wenn echtes Zeichen */
	{
		int pos = makro_rec_ptr->len;
		
		if (pos < MAKRO_DEF_LEN)
		{
			makro_rec_ptr->daten.tasten[pos] = gem_to_norm(kstate, kreturn);
			makro_rec_ptr->len++;
		}
		else
			Bconout(2, 7);
	}
}

void start_blk_rec(char *name, int key, RINGP r)
{
	int	new, i;
	MAKRO	*m;

	new = -1;
	m = makro_list;
	for (i=0; i<MAKRO_ANZ; i++,m++)			/* Eintrag suchen */
	{
		if (m->mode==UNUSED)						/* Leerer Eintrag */
			new = i;
		else if (m->key == key)					/* Alten Eintrag Åberschreiben */
		{
			new = i;
			break;
		}
	}
	if (new >- 1)
	{
		m = makro_list+new;
		if (m->mode == BLOCK)
			free_textring(&m->daten.text);
		else
			init_textring(&m->daten.text);
		m->len = 0;								/* leeren */
		m->mode = BLOCK;
		m->key = key;
		doppeln(r,&m->daten.text);
		strcpy(m->name,name);
	}
}


void start_rec(void)
{
	int	new, i;
	MAKRO	*m;

	if (makro_rec_ptr!=NULL)
	{
		m = makro_rec_ptr;
		if (m->key == -1)
			m->key = UNUSED;
		makro_rec_ptr = NULL;
	}
	new = -1;
	m = makro_list;
	for (i = 0; i < MAKRO_ANZ; i++,m++)			/* leeren Eintrag suchen */
	{
		if (m->mode == UNUSED)
		{
			new = i;
			break;
		}
	}
	if (new > -1)									/* Gefunden */
	{
		m = &makro_list[new];
		makro_rec = TRUE;							/* Zeichen erfassen */
		makro_rec_ptr = m;
		m->len = 0;									/* leeren */
		m->key = -1;
		m->name[0] = EOS;
		print_headline("Makro-Rec");
		menu_text(menu, MSRECORD, rsc_string(MSTOPSTR));
	}
}


void end_rec(bool one_more)
{
	int len = makro_rec_ptr->len;

	makro_rec = FALSE;
	if (len>1)
	{
		if (one_more)
			makro_rec_ptr->len--;					/* letztes ^M raus */
		makro_rec_ptr->mode = TASTEN;				/* Makro ist O.K. */
	}
	else
		makro_rec_ptr = NULL;
	print_headline("");
	menu_text(menu, MSRECORD, rsc_string(MRECSTR));
}


bool start_play(int key, int anz)
{
	int	i;
	MAKRO	*m;
	bool	ret = FALSE;

	if (key == -1)				/* aktuelles Makro */
	{
		m = makro_rec_ptr;
		if (m == NULL)
		{
			Bconout(2, 7);
			return FALSE;
		}
	}
	else							/* Funktionstaste */
	{
		m = makro_list;
		for (i=0; i<MAKRO_ANZ; i++,m++)			/* Eintrag suchen */
			if (m->mode!=UNUSED && m->key==key)
				break;
		if (i == MAKRO_ANZ)
		{
			if (!f_to_desk)						/* Ping nur, wenn nicht an AV-Server */
				Bconout(2, 7);
			return FALSE;
		}
	}
	if (m->mode == TASTEN)						/* Eintrag gefunden */
	{
		if (!makro_play)							/* Neues M. starten */
		{
			memcpy(makro_puffer, m->daten.tasten, m->len * (int) sizeof(unsigned int));
			makro_end = makro_puffer+m->len;
			makro_ptr = makro_puffer;
			makro_play = TRUE;
			makro_play_ptr = m;
			makro_play_counter = max(1,anz);
			print_headline("Makro-Play");
			ret = TRUE;
		}
		else											/* Makro ruft Makro auf */
		{
			int len_old = (int) (makro_end - makro_ptr);
			int len_new = m->len;
			if (len_old+len_new < MAKRO_PLAY_LEN)
			{
				/* Alten Rest nach hinten verschieben */
				memmove(&makro_puffer[len_new],makro_ptr, len_old * (int) sizeof(unsigned int));
				/* Neues Makro einfÅgen */
				memcpy(makro_puffer,m->daten.tasten,m->len * (int) sizeof(unsigned int));
				makro_end = makro_puffer+(len_old+len_new);
				makro_ptr = makro_puffer;
				ret = TRUE;
			}
			else
				Bconout(2, 7);
		}
	}
	else if(m->mode==BLOCK && !makro_rec && !makro_play)
	{
		RING t;

		init_textring(&t);
		doppeln(&m->daten.text,&t);
		clip_takes_text(&t);
		do_action(DO_PASTE);
		ret = TRUE;
	}
	else												/* Kein Eintrag gefunden */
		Bconout(2, 7);
	return ret;
}

void end_play(void)
{
	if (makro_play)
	{
		makro_play = FALSE;
		makro_play_ptr = NULL;
		print_headline("");
	}
}

void del_makro(int key)
{
	MAKRO	*m;
	int	i;

	m = makro_list;
	for (i = 0; i < MAKRO_ANZ; i++,m++)
	{
		if (m->mode != UNUSED && m->key == key)
		{
			if (makro_rec_ptr != NULL && makro_rec_ptr == m)
				m->key = -1;
			else
			{
				if (m->mode == BLOCK)
					kill_textring(&m->daten.text);
				m->mode = UNUSED;
			}
			break;
		}
	}
}


/*
 * Makro-String aus CFG in Puffer wandeln.
*/
void set_makro_str(char *ptr)
{
	char		*p;
	int		i, l;
		
	if (*ptr == '"')
	{
		for (i = 0; i < MAKRO_ANZ; i++)		/* leeren Eintrag suchen */
			if (makro_list[i].mode == UNUSED)
				break;

		if (i >= 0)
		{
			ptr += 1;						/* " Åberspringen */
			p = strchr(ptr, '"');
			*p = EOS;
			strcpy(makro_list[i].name, ptr);
			ptr = p + 2;					/* ", Åberspringen */
			
			p = strchr(ptr, ',');
			*p = EOS;
			makro_list[i].key = (int)strtol(ptr, NULL, 16);
			makro_list[i].mode = TASTEN;
	
			ptr = p + 1;
			l = 0;
			while (ptr)
			{
				p = strchr(ptr, ',');
				if (p)
					*p = EOS;
				makro_list[i].daten.tasten[l] = (int)strtol(ptr, NULL, 16);
				l++;
				if (p == NULL)
					ptr = NULL;
				else
					ptr = p + 1;
			}
			makro_list[i].len = l;
		}
	}
}


/*
 * Puffer in Makro-String fÅr CFG wandeln.
*/
bool get_makro_str(int nr, char *ptr)
{
	char	s[5];
	int	j;

	if (makro_list[nr].mode == TASTEN)
	{
		sprintf(ptr, "\"%s\",%X", makro_list[nr].name, makro_list[nr].key);
		for (j = 0; j < makro_list[nr].len; j++)
		{
			sprintf(s, ",%X", makro_list[nr].daten.tasten[j]);
			strcat(ptr, s);
		}
		return TRUE;
	}
	return FALSE;
}


void init_makro(void)
{
	int	i;

	makro_play = makro_rec = FALSE;
	for (i = 0; i < MAKRO_ANZ; i++)
		makro_list[i].mode = UNUSED;
	makro_rec_ptr = NULL;
	makro_play_ptr = NULL;
}


/***************************************************************************/
/* Dialog ******************************************************************/
/***************************************************************************/

static void makro_on_key(char *name, int key)
{
	MAKRO	*m;

	if (makro_rec_ptr!=NULL)
	{
		del_makro(key);
		m = makro_rec_ptr;
		makro_rec_ptr = NULL;
		m->key = key;
		strcpy(m->name, name);
	}
}


static void get_makro_name(int scan, char *name)
{
	int	i;
	MAKRO	*m;

	*name = EOS;
	m = makro_list;
	for (i = MAKRO_ANZ; (--i) >= 0; m++)
		if (m->mode != UNUSED && m->key == scan)
		{
			strcpy(name, m->name);
			break;
		}
}


static void show_makro(int nr, MDIAL *mdial)
{
	char	name[9];

	if (nr < 10)
		get_makro_name(0x3B00 + (nr * 0x100), name);
	else
		get_makro_name(0x5400 + ((nr - 10) * 0x100), name);

	set_string(funktionstasten, FNNAME, name);
	set_state(funktionstasten, FNDELETE, DISABLED, (name[0] == EOS));
	if (mdial != NULL)
	{
		redraw_mdobj(mdial, FNNAME);
		redraw_mdobj(mdial, FNDELETE);
	}
}

void makro_dial(void)
{
	int	antw;
	char	name[9];
	MDIAL	*dial;
	bool	close = FALSE;
	int	y, makro_nr = 0;
		
	save_clip();

	set_state(funktionstasten, FNBLOCK, DISABLED, ist_leer(&clip_text));
	set_string(funktionstasten, FNKEY, " F1");
	show_makro(makro_nr, NULL);

	dial = open_mdial(funktionstasten, FNNAME);
	if (dial != NULL)
	{
		while (!close)
		{
			antw = do_mdial(dial) & 0x7fff;
			switch (antw)
			{
				case FNSTR :
				case FNKEY :
					if (antw == FNKEY)
						y = handle_popup(funktionstasten, FNKEY, popups, FUNCPOP, POP_OPEN);
					else
						y = handle_popup(funktionstasten, FNKEY, popups, FUNCPOP, POP_CYCLE);
					if (y > 0)
					{
						makro_nr = y - POPF1;
						show_makro(makro_nr, dial);
					}
					break;
		
				case FNDELETE:
					if (makro_nr < 10)
						del_makro(0x3B00 + (makro_nr * 0x100));
					else
						del_makro(0x5400 + ((makro_nr - 10) * 0x100));
					set_state(funktionstasten, antw, SELECTED, FALSE);
					show_makro(makro_nr, dial);
					break;
		
				case FNRECORD:
				case FNBLOCK:
					get_string(funktionstasten, FNNAME, name);
					if (*name == EOS)
					{
						set_state(funktionstasten, antw, SELECTED, FALSE);
						note(1, 0, MKNAME);
						redraw_mdobj(dial, 0);
					}
					else
						close = TRUE;
					break;
		
				default:
					close = TRUE;
					break;
			}
		}
		close_mdial(dial);
		set_state(funktionstasten, antw, SELECTED, FALSE);
		if (antw == FNRECORD)
		{
			if (makro_nr < 10)
				makro_on_key(name, 0x3B00 + (makro_nr * 0x100));
			else
				makro_on_key(name, 0x5400 + ((makro_nr - 10) * 0x100) );
		}
		if (antw == FNBLOCK)
		{
			if (makro_nr < 10)
				start_blk_rec(name, 0x3B00 + (makro_nr * 0x100), &clip_text);
			else
				start_blk_rec(name, 0x5400 + ((makro_nr - 10) * 0x100), &clip_text);
		}
	}
}
