#include "global.h"
#include "comm.h"
#include "edit.h"
#include "file.h"
#include "icon.h"
#include "memory.h"
#include "options.h"
#include "rsc.h"
#include "text.h"
#include "clipbrd.h"

/* exportierte Variablen ***************************************************/
RING	clip_text;
PATH	clip_dir;

/****** DEFINES ************************************************************/

#define MAX_UNDO	5
#define END_UNDO	-1

/* loake Variablen *********************************************************/
static bool	clip_dirty;
static PATH	clip_name;

static int	undo[MAX_UNDO];
static int	undo_anz;
static RING	undo_text;
static int	undo_ptr;

static char	save_col[MAX_LINE_LEN];		/* Gerettete Zeile fÅr Undo */
static int	save_len;
static int	save_xpos;

static bool	last_was_bin = FALSE;
static long	clip_timestamp = 0;

/*******************************************************************************/

void clr_undo(void)
{
	undo_ptr = -1;
	undo_anz = 0;
}

bool any_undo(void)
{
	if (undo_anz && undo[undo_anz-1]==END_UNDO)
		return TRUE;
	return FALSE;
}

bool test_col_anders(void)
{
	int i;

	if (undo_anz == 0)
		return FALSE;
	if (undo[undo_anz-1] == COL_ANDERS)
		return TRUE;
	if (undo[undo_anz-1] != END_UNDO)
		return FALSE;
	for (i = 0; i < undo_anz; i++)
		if (undo[i]==END_UNDO)
			break;
	if (i > 0 && i < undo_anz)
		return (undo[i-1] == COL_ANDERS);
	return FALSE;
}

void end_undo_seq(void)
{
	int	i;

	undo_ptr = -1;
	if (undo_anz==0 || undo[undo_anz-1]==END_UNDO)
		return;
	for (i=0; i<undo_anz; i++)
		if (undo[i]==END_UNDO)
		{
			i++;
			undo_anz -= i;
			memcpy(undo, undo+i, (int) sizeof(int) * undo_anz);
			break;
		}
	add_undo(END_UNDO);
}

void add_undo(int undo_op)
{
	if (undo_anz<MAX_UNDO && (undo_anz==0 || undo[undo_anz-1]!=undo_op))
		undo[undo_anz++] = undo_op;
}

int get_undo(void)
{
	int i;

	if (undo_anz==0)
		return NO_UNDO;
	if (undo_ptr<0)
	{
		for (i=0; i<undo_anz; i++)
			if (undo[i]==END_UNDO) break;
		if (i==undo_anz) return NO_UNDO;
		undo_ptr = i;
	}
	undo_ptr--;
	if (undo_ptr<0)
		return NO_UNDO;
	return undo[undo_ptr];
}

void undo_takes_text(RINGP r)
{
	kill_textring(&undo_text);
	undo_text = *r;
	FIRST(r)->vorg = &undo_text.head;
	LAST(r)->nachf = &undo_text.tail;
}

RINGP get_undo_text(void)
{
	return &undo_text;
}

/*
 * UNDO fÅr eine Zeile
*/
void get_undo_col(TEXTP t_ptr)
{
	if (!test_col_anders() || t_ptr->ypos!=undo_y)
	{
		undo_y = t_ptr->ypos;
		save_len = t_ptr->cursor_line->len;
		memcpy(save_col, TEXT(t_ptr->cursor_line), save_len);
		save_xpos = t_ptr->xpos;
	}
	add_undo(COL_ANDERS);
}

void do_undo_col(TEXTP t_ptr, int undo)
{
	ZEILEP	undo_col;
	char		help[MAX_LINE_LEN];
	char	 	*str;
	int		length;

	if (undo == COL_ANDERS)
	{
		undo_col = get_line(&t_ptr->text,undo_y);
		length = undo_col->len;
		memcpy(help, TEXT(undo_col), length);

		str = REALLOC(&undo_col,0,save_len-length);
		memcpy(str, save_col, save_len);

		memcpy(save_col, help, length);
		save_len = length;

		t_ptr->moved++;
		make_chg(t_ptr->link,LINE_CHANGE,undo_y);
		make_chg(t_ptr->link,POS_CHANGE,0); 			/* wg. moved */
		t_ptr->xpos = save_xpos;
		t_ptr->cursor_line = undo_col;
		add_undo(COL_ANDERS);
	}
}


/*******************************************************************************/

void save_clip(void)		/* nur wegschreiben */
{
	if (clip_on_disk && clip_dirty)
	{
		scrap_clear();
		save_datei(clip_name, &clip_text, FALSE);
		clip_timestamp = file_time(clip_name, NULL, NULL);
		send_clip_change();
		clip_dirty = FALSE;
	}
}

void load_clip(void)		/* nur laden */
{
	long	timestamp;
	
	/*
	 * Nur neu laden, wenn letzter Copy von qed bereits weggeschrieben wurde,
	 * ansonsten sind die aktuellen Klembrett-Daten noch in clip_text.
	*/
	if (clip_on_disk && !clip_dirty)
	{
		timestamp = file_time(clip_name, NULL, NULL);
		if (timestamp != clip_timestamp)
		{
			free_textring(&clip_text);
			if (last_was_bin)
				clip_text.ending = binmode;
			if (load_datei(clip_name, &clip_text, FALSE, NULL) != 0)
				free_textring(&clip_text);
			clip_timestamp = timestamp;
		}
	}
}


void clip_takes_text(RINGP r)
{
	kill_textring(&clip_text);
	clip_text = *r;
	last_was_bin = (r->ending == binmode);
	FIRST(r)->vorg = &clip_text.head;
	LAST(r)->nachf = &clip_text.tail;
	clip_dirty = TRUE;
}

void clip_add_text(RINGP r)
{
	ZEILEP	col;

	col = LAST(&clip_text);			/* letzte Zeile */
	col->nachf = FIRST(r);
	FIRST(r)->vorg = col;
	LAST(r)->nachf = &clip_text.tail;
	LAST(&clip_text) = LAST(r);
	clip_text.lines += r->lines;
	col_concate(&col);
	clip_text.lines--;
	clip_dirty = TRUE;
}

static int get_first_drive(void)
{
	unsigned long	drives;
	int				drive;

	drives = Dsetdrv(Dgetdrv());					/* Alle Laufwerke */
	if (drives == 0)
		drive = -1;
	else if (drives <= 3)
		drive = 0;										/* Benutze Laufwerk A */
	else
	{
		drives >>= 2;
		drive = 2;										/* Beginne bei Laufwerk C */
		while (!(drives & 1) && drive < 32)    /* Laufwerk gefunden */
		{
			drive++;
			drives >>= 1;
		}
	}
	return drive;
}

void init_clipbrd(void)
{
	PATH		s;
	char		*str;

	scrp_read (clip_dir);									/* Scrap-Directory lesen */
	if (clip_dir[0] == EOS)									/* Noch keines gesetzt */
	{
		if ((str=getenv("SCRAPDIR"))!=NULL && *str!=EOS)
			strcpy(clip_dir, str);
		else if ((str=getenv("CLIPBRD"))!=NULL && *str!=EOS)
			strcpy(clip_dir, str);

		else
		{
			int drive;

			strcpy (clip_dir, "A:\\CLIPBRD\\");
			drive = get_first_drive();
			if (drive > 0)
				clip_dir[0] = 'A' + (char) drive;
		}
		scrp_write (clip_dir);								/* Scrap-Directory setzen */
	}
	if (!make_normalpath(clip_dir))
	{
		if (clip_dir[0]=='A' || clip_dir[0]=='B' ||
		    clip_dir[0]=='a' || clip_dir[0]=='b')
			clip_dir[0] = EOS;						/* Kein Klemmbrett auf Disketten! */
		else
		{
			strcpy (s, clip_dir);
			s[strlen(s)-1] = EOS;					/* Backslash lîschen */
			if (Dcreate(s) != 0)
			{
				note(1, 0, NOSCRAP);
				clip_dir[0] = EOS;					/* Kein Klemmbrett */
			}
		}
	}
	init_textring(&clip_text);
	clip_dirty = FALSE;

	if (clip_dir[0] == EOS)
		clip_on_disk = FALSE;
	else
	{
		strcpy(clip_name, clip_dir);
		strcat(clip_name, "scrap.txt");
	}

	init_textring(&undo_text);
	clr_undo();
}
