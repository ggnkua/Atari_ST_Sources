#include <ctype.h>
#include <support.h>

#include "global.h"
#include "edit.h"
#include "icon.h"
#include "memory.h"
#include "rsc.h"
#include "set.h"
#include "text.h"
#include "window.h"
#include "error.h"

extern void	menu_help(int title, int item);

/*
 * Exportierte Variablen:
*/
char	error[FEHLERANZ][40];
TEXTP	last_errtext = NULL;

/*
 * lokales
*/
typedef enum {nil, read_text, read_name, read_zeile, read_spalte, read_fehler} TOKEN;

#define MAX_TOKEN		10				/* Anzahl der Token */
#define MAX_ERRLEN	120			/* LÑnge der Fehlerzeile */

typedef struct
{
	TOKEN	token;
	char	text[30];
} TOKENELEM, *TEP;

static TOKENELEM	token_list[MAX_TOKEN];
static int			token_anzahl;
static PATH			error_name;					/* Dateiname des Errorfiles */

/* das Ergebnis */
static PATH	dateiname;
static char	fehlertext[MAX_ERRLEN];
static long	fehlerzeile;
static int	fehlerspalte;
static int	err_anz = 0;



static void init_parser(char *muster)
{
	char	tmp[2] = " ";
	int	i;
	TOKEN last_token;

	strcpy(dateiname, "");
	fehlerzeile = -1;
	fehlerspalte = -1;
	strcpy(fehlertext, "");

	token_anzahl = 0;
	last_token = nil;
	for (i = 0; i < MAX_TOKEN; i++)
	{
		token_list[i].token = nil;
		strcpy(token_list[i].text, "");
	}

	for (i = 0; i < (int)strlen(muster); i++)
	{
		switch (muster[i])
		{
			case '%' :
				i++;
				if (last_token == read_text)
					token_anzahl++;
				switch (muster[i])
				{
					case 'f' :
						token_list[token_anzahl].token = read_name;
						last_token = read_name;
						break;
					case 'z' :
						token_list[token_anzahl].token = read_zeile;
						last_token = read_zeile;
						break;
					case 's' :
						token_list[token_anzahl].token = read_spalte;
						last_token = read_spalte;
						break;
					case 't' :
						token_list[token_anzahl].token = read_fehler;
						last_token = read_fehler;
						break;
				}
				break;
			default:
				if (last_token > read_text)
					token_anzahl++;
				token_list[token_anzahl].token = read_text;
				tmp[0] = muster[i];
				strcat(token_list[token_anzahl].text, tmp);
				last_token = read_text;
				break;
		}
	}
}


static bool	readin_text(char *zeile, int *pos, char *text)
{
	int	len = (int)strlen(text),
			i;
	char	tmp[10];

	i = *pos;
	while ( (i < (int)strlen(zeile)) && (i < (len + *pos)))
	{
		tmp[i - *pos] = zeile[i];
		i++;
	}
	if (i > *pos)
	{
		tmp[i - *pos] = EOS;
		*pos = i;
		return (strcmp(tmp, text) == 0);
	}
	else
		return FALSE;
}

static bool	readin_name(char *zeile, int *pos)
{
	SET	valid_char;
	PATH	tmp;
	int	i;

	strcpy(tmp,"-+._~\\/A-Za-z0-9");				/* ZulÑssige Zeichen fÅr Dateinamen */
	str2set(tmp, valid_char);
	i = *pos;
	while ( 	(i < (int)strlen(zeile)) && 	/* Sonderbehandlung fÅr ':', nur im Pfad erlaubt! */
				((setin(valid_char, zeile[i])) ||
				 (zeile[i] == ':' && (zeile[i+1] == '\\') || zeile[i+1] == '/')))
	{
		tmp[i - *pos] = zeile[i];
		i++;
	}
	if (i > *pos)
	{
		tmp[i - *pos] = EOS;
		*pos = i;

		if (strchr(tmp, '/') != NULL)				/* UNIX-Pfad -> nach TOS wandeln */
		{
			unx2dos(tmp, dateiname);
		}
		else if (tmp[1] != ':')						/* Kein Laufwerk -> Name ohne Pfad! */
		{

			split_filename(error_name, dateiname, NULL);
			strcat(dateiname, tmp);
		}
		else
			strcpy(dateiname, tmp);
		return (file_exists(dateiname));
	}
	else
		return FALSE;
}

static bool	readin_zeile(char *zeile, int *pos)
{
	int	i;
	char	tmp[10];

	i= *pos;
	while ( (i < (int)strlen(zeile)) && (isdigit(zeile[i])) )
	{
		tmp[i - *pos] = zeile[i];
		i++;
	}
	if (i > *pos)
	{
		tmp[i - *pos] = EOS;
		fehlerzeile = atol(tmp);
		*pos = i;
		return TRUE;
	}
	else
		return FALSE;
}

static bool	readin_spalte(char *zeile, int *pos)
{
	int	i;
	char	tmp[10];

	i= *pos;
	while ( (i < (int)strlen(zeile)) && (isdigit(zeile[i])) )
	{
		tmp[i - *pos] = zeile[i];
		i++;
	}
	if (i > *pos)
	{
		tmp[i - *pos] = EOS;
		fehlerspalte = atoi(tmp);
		*pos = i;
		return TRUE;
	}
	else
		return FALSE;
}

static bool	readin_fehler(char *zeile, int *pos)
{
	int	i, j;
	char	tmp[MAX_ERRLEN];

	i = *pos;
	j = 0;
	while ( (i < (int)strlen(zeile)) && (j < sizeof(tmp)) )
	{
		tmp[i - *pos] = zeile[i];
		i++;
		j++;
	}
	if (i > *pos)
	{
		tmp[i - *pos] = EOS;
		*pos = i;
		strcpy(fehlertext, tmp);
		return TRUE;
	}
	else
		return FALSE;
}

static bool	parse_line(char *zeile)
{
	int	i, z_pos = 0;
	bool	ok = FALSE;

	for (i = 0; i <= token_anzahl; i++)
	{
		switch (token_list[i].token)
		{
			case read_text :
				ok = readin_text(zeile, &z_pos, token_list[i].text);
				break;
			case read_name :
				ok = readin_name(zeile, &z_pos);
				break;
			case read_zeile :
				ok = readin_zeile(zeile, &z_pos);
				break;
			case read_spalte :
				ok = readin_spalte(zeile, &z_pos);
				break;
			case read_fehler :
				ok = readin_fehler(zeile, &z_pos);
				break;
		}
		if (!ok)
			break;
	}
	return ok;;
}


void	handle_error(TEXTP t_ptr)
{
	int	icon, i;
	char	str[256];

	if (last_errtext != NULL && t_ptr != last_errtext)
	{
		ZEILEP lauf = t_ptr->cursor_line;
	
		t_ptr = last_errtext;
		lauf = t_ptr->cursor_line;
		/* nÑchste Zeile setzen */		
		if (!IS_LAST(t_ptr->cursor_line))
		{
			NEXT(lauf);
			t_ptr->cursor_line = lauf;
			t_ptr->xpos = 0;
			t_ptr->ypos++;
			make_chg(t_ptr->link, POS_CHANGE, 0);
		}
	}
	for (i = 0; i < err_anz; i++)
	{
		init_parser(error[i]);
		strcpy(error_name, t_ptr->filename);
		if (parse_line(TEXT(t_ptr->cursor_line)))
		{
			last_errtext = t_ptr;

			icon = load_edit(dateiname, FALSE);			/* Laden als Text und îffnen */
			if (icon > 0)
			{
				if (fehlerspalte > 0)
					desire_x = fehlerspalte - 1;				/* wir fange bei 0 an! */
				else
					desire_x = 0;
				if (fehlerzeile > 0)
					desire_y = fehlerzeile - 1;
				else
					desire_y = 0;

				if (strlen(fehlertext) > 0)
				{
					strcpy(str, rsc_string(ERRORSTR));
					strcat(str, fehlertext);
					set_info(get_text(icon), str);
				}
				icon_edit(icon, DO_GOTO);
				return;
			}
		}
	}
	if (last_errtext != NULL)
		last_errtext = NULL;
	Bconout(2, 7);
}

/*
 * Die Dialogbox fÅr die Fehlerzeile
 */
void	fehler_box(void)
{
	int	antw, i;
	char	str[40];
	MDIAL	*dial;
	bool	close = FALSE;
	
	for (i = 0; i < FEHLERANZ; i++)
		set_string(fehler, FEHLTEXT1 + i, error[i]);
	
	dial = open_mdial(fehler, 0);
	if (dial != NULL)
	{
		while (!close)
		{
			antw = do_mdial(dial) & 0x7fff;
			switch (antw)
			{
				case FEHLHELP :
					menu_help(TSPEZIAL, MFEHLER);
					set_state(fehler, antw, SELECTED, FALSE);
					redraw_mdobj(dial, antw);
					break;
				default:
					close = TRUE;
					break;
			}
		}
		close_mdial(dial);
		set_state(fehler, antw, SELECTED, FALSE);
		if (antw == FEHLOK)
		{
			err_anz = 0;
			for (i = 0; i < FEHLERANZ; i++)
			{
				strcpy(error[i], "");								/* leeren */
				get_string(fehler, FEHLTEXT1 + i, str);
				set_errorline(str);
			}
		}
	}
}

/*
 * Zeilen aus Parameterdatei eintragen.
*/
void set_errorline(char *zeile)
{
	if ((err_anz < FEHLERANZ) && (zeile[0] != EOS))
	{
		strcpy(error[err_anz], zeile);
		err_anz++;
	}
}
