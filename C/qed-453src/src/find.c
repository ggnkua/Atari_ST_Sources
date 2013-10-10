#include "global.h"
#include "aktion.h"
#include "ausgabe.h"
#include "block.h"
#include "clipbrd.h"
#include "comm.h"
#include "edit.h"
#include "event.h"
#include "file.h"
#include "icon.h"
#include "memory.h"
#include "rsc.h"
#include "set.h"
#include "tasten.h"
#include "text.h"
#include "umbruch.h"
#include "window.h"
#include "find.h"

extern void	menu_help(int title, int item);

/* exportierte Variablen ***************************************************/

bool					s_grkl, s_quant, s_wort, s_vorw, s_global, s_round,
						ff_rekursiv;
int					r_modus, rp_box_x, rp_box_y;
char					r_str[HIST_LEN+1], s_str[HIST_LEN+1],
						s_history[HIST_ANZ][HIST_LEN+1],
						r_history[HIST_ANZ][HIST_LEN+1],
						ff_mask[15+1];

UMLAUTENCODING 	umlaut_from, umlaut_to;

/*****************************************************************************/

#define SETANZ 		5

#define M_CURSOR		0		/* Werte fÅr modus von start_suche */
#define M_TSTART		1
#define M_TENDE		2

static ZEILEP 	start;
static int		text_len, text_x,
					last_op = -1;
static long		text_y;
static SET		wort_set;

/* Variablen, die Åber set_suchmode gesetzt werden */
/* !!! muessen bei match gesichet werden !!! */
static bool		quantor, vorw, grkl, wort, modus, round, line_start;
static int		muster_len;
static char 	muster_txt[HIST_LEN+1];
static char 	replace_txt[HIST_LEN+1];
static SET		group[SETANZ];
static int		setanz;
static int		delta[256];

/* lokale Prototypen *****************************************************/
static bool	build_popup (char h[HIST_ANZ][HIST_LEN+1], POPUP *pop);
static int	hist_popup	(char h[HIST_ANZ][HIST_LEN+1], OBJECT *tree, int obj_pos, int obj_text);

/*=======================================================================*/

static void init_suche(TEXTP t_ptr, int modus)
{
	if (modus == M_CURSOR)
	{
		start = t_ptr->cursor_line;
		text_y = t_ptr->ypos;
		if (vorw)
		{
			text_x = t_ptr->xpos;
			text_len = start->len-t_ptr->xpos;
			if (text_len>0)
			{
/*
	Muû das sein? Dann findet ^G nÑmlich nichts, wenn der Cursor auf dem
	gesuchten steht!?
				text_x++;
				text_len--;
*/
			}
			else if (!IS_LAST(start))
			{
				NEXT(start);
				text_y++;
				text_x = 0;
				text_len = start->len;
			}
		}
		else
		{
			text_x = 0;
			text_len = t_ptr->xpos;
			if (text_len>0)
			{
/*
	Diese Zeile mÅûte eigentlich auch raus, damit das gefunden wird (rÅckwÑrts)
	wo der Cursor 'draufsteht. Dann klappt aber der ^G nicht, da dann der
	Cursor (Blockmarkierung!) wieder hinter dem gefundenen steht und so immer
	wieder das gleiche findet!
*/
				text_len--;
			}
			else if (!IS_FIRST(start))
			{
				VORG(start);
				text_y--;
				text_len = start->len;
			}
		}
	}
	else if (modus==M_TSTART)
	{
		start = FIRST(&t_ptr->text);
		text_x = 0;
		text_len = start->len;
		text_y = 0;
	}
	else
	{
		start = LAST(&t_ptr->text);
		text_x = 0;
		text_len = start->len;
		text_y = t_ptr->text.lines-1;
	}
	setcpy(wort_set,t_ptr->loc_opt->wort_set);
}

static int suche1(ZEILEP col, int x, int str_len, int *such_len,
						char*(*call)(char*,int,char*,int*))
/* vorw */
{
	char *ptr, *str, *str2;

	if (quantor)
	{
		if (x>0 && line_start)									/* Muster am Anfang finden */
			return -1;
		if (x+str_len<col->len && muster_len>=2 &&
			 muster_txt[muster_len-2]=='[' && muster_txt[muster_len-1]==0xFC)
			return -1;
	}
	ptr = TEXT(col);
	str = ptr+x;
	str2 = (*call)(str, str_len, muster_txt, such_len);
	if (str2==NULL) return -1;
	if (wort)
	{
		while (!(str2==ptr || !setin(wort_set,str2[-1])) ||
				 !(str2[*such_len]==EOS || !setin(wort_set,str2[*such_len])))
		{
			str2++;
			str_len -= (int)(str2 - str);
			str = str2;
			str2 = (*call)(str, str_len, muster_txt, such_len);
			if (str2==NULL) return -1;
		}
	}
	return (int)(str2 - ptr);
}

static int suche2(ZEILEP col, int x, int str_len, int *such_len,
						char*(*call)(char*,int,char*,int*))
/* rauf */
{
	int	x2, merk;

	merk = 0;
	while (TRUE)
	{
		x2 = suche1(col, x, str_len, such_len, call);
		if (x2==-1) break;
		x2++; 								/* Weiter suchen */
		str_len -= x2-x;					/* RestlÑnge */
		merk = x = x2;
	}
	return merk-1;
}

static char *STRSTR(char *str_anf, int str_len, char *mstr_anf, int *found_len)
/* Suche ohne Quantoren */
{
	char *mstr, *str;
	int	i, mstr_len = muster_len;

	*found_len = mstr_len;
	str_anf += mstr_len;
	str_len -= mstr_len;
	mstr_anf += mstr_len;
	while (str_len>=0)
	{
		str = str_anf;
		mstr = mstr_anf;
		i = mstr_len;
		while(TRUE)
		{
			if (*(--mstr)!=*(--str)) break;		/* Match fehlgeschlagen */
			if ((--i)<=0) return(str); 			/* gefunden */
			if (*(--mstr)!=*(--str)) break;		/* Match fehlgeschlagen */
			if ((--i)<=0) return(str);				/* gefunden */
			if (*(--mstr)!=*(--str)) break;		/* Match fehlgeschlagen */
			if ((--i)<=0) return(str); 			/* gefunden */
			if (*(--mstr)!=*(--str)) break;		/* Match fehlgeschlagen */
			if ((--i)<=0) return(str); 			/* gefunden */
		}
		i = delta[str_anf[-1]];
		str_anf += i;										/* weiterrÅcken */
		str_len -= i;
	}
	return(NULL);
}

static char *STRSTR1(char *str_anf, int str_len, char *mstr_anf, int *found_len)
/* Suche ohne Quantoren (Gross/Klein) */
{
	char *mstr, *str, s;
	int	i, mstr_len = muster_len;

	*found_len = mstr_len;
	str_anf += mstr_len;
	str_len -= mstr_len;
	mstr_anf += mstr_len;
	while (str_len>=0)
	{
		str = str_anf;
		mstr = mstr_anf;
		i = mstr_len;
		while (TRUE)
		{
			s = *(--str);
/*
			if (s>='a' && s<='z') s-=32;
			else if (s=='î') s = 'ô';
			else if (s=='Å') s = 'ö';
			else if (s=='Ñ') s = 'é';
*/
			s = nkc_toupper(s);
			if (*(--mstr)!=s) 
				break;					/* Match fehlgeschlagen */
			if ((--i)<=0) 
				return (str);			/* gefunden */
		}
		s = str_anf[-1];
/*
		if (s>='a' && s<='z') s-=32;
		else if (s=='î') s = 'ô';
		else if (s=='Å') s = 'ö';
		else if (s=='Ñ') s = 'é';
*/
		s = nkc_toupper(s);
		i = delta[s];
		str_anf += i;										/* weiterrÅcken */
		str_len -= i;
	}
	return(NULL);
}

static char *STRSTR2(char *str_anf, int str_len, char *mstr_anf, int *found_len)
/* Suche mit Quantoren (rekursiv) */
{
	char *str, *mstr, m, s;
	int	len, anz;

	if (line_start)										/* Muster am Anfang finden */
		anz = 1;
	else
		anz = str_len+1;									/* Anzahl der Tests */
	while ((--anz)>=0)									/* auch len=0 kann Treffer sein */
	{
		mstr = mstr_anf;									/* Muster reset */
		str = str_anf; 									/* String reset */
		len = str_len;
		while (TRUE)
		{
			m = *mstr++;									/* neue Zeichen holen */
			s = *str;
			if (m==EOS) 									/* Muster komplett gefunden */
			{
				*found_len = (int)(str - str_anf);
				return str_anf;
			}
			if (len==0)
				s = EOS;

			if (m=='*')
			{
				bool	save = line_start;

				line_start = FALSE;
				str = STRSTR2(str, len, mstr, found_len);
				line_start = save;
				if (str==NULL)
					return NULL;
				*found_len += (int)(str - str_anf);
				return str_anf;
			}
			if (!grkl)
			{
/*
				if (s>='a' && s<='z') s-=32;
				else if (s=='î') s = 'ô';
				else if (s=='Å') s = 'ö';
				else if (s=='Ñ') s = 'é';
*/
				s = nkc_toupper(s);
			}
			if (m=='[')
			{
				m = *mstr++;								/* nach '[' folgt ein Infozeichen */
				if (m==0xFF)							/* echtes '[' */
				{
					if (s!='[') break;
				}
				else if (m==0xFE) 							/* Wortende (letztes in Muster) */
				{
					if (len==0 || !setin(wort_set,s))
					{
						*found_len = (int)(str - str_anf);
						return str_anf;
					}
					break;
				}
				else if (m==0xFC) 						/* Zeilenende */
				{
					if (len==0)
					{
						*found_len = (int)(str - str_anf);
						return str_anf;
					}
					break;
				}
				else											/* Wildcard */
				{
					if (!setin(group[m-1],s)) break;
				}
			}
			else												/* normale Zeichen und '?' */
				if (m!=s && m!='?') break;

			if (len==0) break;
			str++; len--;									/* nÑchstes Zeichen */
		}
		str_anf++;											/* String ein Zeichen weiter */
		str_len--;
	}
	return NULL;
}

/* rein : start, text_x, text_len, text_y */
/* raus : start, text_x, text_len, text_y */
/* -1:Abbruch, 0:nichts gefunden 1:gefunden */

static int suchen2(int *such_len)
{
	char*	(*call)	(char*,int,char*,int*);
	long	y;
	ZEILEP lauf;
	int	step, x;

	x = text_x;
	y = text_y;
	lauf = start;
	if (muster_len==0) return 0;
	step = 70;
	if (quantor)
		call = STRSTR2;
	else if (grkl)
		call = STRSTR;
	else
		call = STRSTR1;
	if (vorw)
	{
		while (TRUE)
		{
			if ((text_x=suche1(lauf,x,text_len,such_len,call))>=0)
			{
				text_y = y;
				start = lauf;
				return 1;
			}
			NEXT(lauf); y++; x = 0; text_len = lauf->len;
			if (IS_TAIL(lauf)) return 0;
			if ((--step)==0)
			{
/*
				if (check_for_abbruch() && note(1, 2, BREAK) == 1) 
					return -1;
*/
				step = 70;
			}
		}
	}
	else
	{
		while (TRUE)
		{
			if ((text_x=suche2(lauf,x,text_len,such_len,call))>=0)
			{
				text_y = y;
				start = lauf;
				return 1;
			}
			VORG(lauf);
			if (IS_HEAD(lauf)) return 0;
			y--;
			x = 0;
			text_len = lauf->len;
			if ((--step)==0)
			{
/*
				if (check_for_abbruch() && note(1, 2, BREAK) == 1) 
					return -1;
*/
				step = 70;
			}
		}
	}
}

/* rein : start, text_x, text_len, text_y */
/* raus : start, text_x, text_len, text_y */
/* -1:Abbruch, 0:nichts gefunden 1:gefunden */

static int suchen(TEXTP t_ptr, int *such_len)
{
	int	erg;

	erg = suchen2(such_len);
	if (erg==0 && round)
	{
		int	m;

		Bconout(2, 7);
		if (vorw)
			m = M_TSTART;
		else
			m = M_TENDE;
		init_suche(t_ptr,m);
		erg = suchen2(such_len);
	}
	return erg;
}

/* ====================================================================== */

static void set_suchmode(char *Muster, char *Replace, bool Grkl, bool Quantor, 
								 bool Vorw, bool Wort, bool Global, bool Round)
{
	char	*ptr, *d, help[HIST_LEN+1];
	bool	invers;

	/* Spezial fÅr '@' am Editfeld-Anfang! */
	if (Muster[0] == '\\' && Muster[1] == '@' && Quantor)
		strcpy((char *)muster_txt, Muster+1);		/* \ Åberspringen */
	else
		strcpy((char *)muster_txt, Muster);

	if (Replace[0] == '\\' && Replace[1] == '@' && Quantor)
		strcpy(replace_txt, Replace+1);
	else
		strcpy(replace_txt, Replace);
	
	grkl = Grkl;
	quantor = Quantor;
	vorw = Vorw;
	wort = Wort;
	round = Round;
	setanz = 0;
	if (!grkl) 
		str_toupper((char *)muster_txt);
	if (quantor)
	{
		d = help;
		ptr = muster_txt;
		if (*ptr=='^')
		{
			line_start = TRUE;
			ptr++;
		}
		else
			line_start = FALSE;

		for (; *ptr; ptr++)
		{
			*d++ = *ptr;
			if (*ptr=='$' && ptr[1]==EOS)
			{
				d[-1] = '[';
				*d++ = 0xFC;
			}
			else if (*ptr=='[' && setanz<SETANZ)
			{
				char *merk = ptr;

				ptr++;
				invers = FALSE;
				if (*ptr=='^')
				{
					invers = TRUE;
					ptr++;
				}
				setclr(group[setanz]);
				while(*ptr && *ptr!=']')
				{
					if (ptr[0]=='-' && ptr[-1]!='[' && ptr[1]!=']')
					{
						char i;

						ptr++;
						for (i=ptr[-2]; i<*ptr; i++)
							setincl(group[setanz],i);
					}
					else
						setincl(group[setanz],*ptr++);
				}
				if (*ptr)							/* Keine ']' gefunden */
				{
					if (invers)
						setnot(group[setanz]);
					setanz++;
					*d++ = setanz; 				/* immer einen grîûer (weil nie Null) */
				}
				else
				{
					*d++ = 0xFF;					/* Echtes '[' */
					ptr = merk; 					/* Neu Scannen */
				}
			}
		}
		if (wort && d>help)						/* nur Worte und Åberhaupt ein Muster */
		{
			*d++ = '[';
			*d++ = 0xFE;							/* Wortende */
		}
		*d = EOS;
		strcpy((char *)muster_txt, help);
		muster_len = (int) strlen(muster_txt);
	}
	else
	{
		int i,j;

		muster_len = (int) strlen(muster_txt);
		for (i=0; i<256; i++) 
			delta[i] = muster_len;
		j = muster_len-1;
		for (i=0; i<j; i++) 
			delta[muster_txt[i]] = j-i;
	}
	if (Global)
	{
		if (vorw)
			modus = M_TSTART;
		else
			modus = M_TENDE;
	}
	else
			modus = M_CURSOR;
}

int start_find(TEXTP t_ptr, bool quiet)
{
	int	len, erg;

	last_op = 1;
	graf_mouse(HOURGLASS, NULL);
	init_suche(t_ptr, modus);			/* Suchzeiger an den Start bringen */
	erg = suchen(t_ptr,&len);
	graf_mouse(ARROW, NULL);
	if (erg == 1 && !quiet)
	{
		blk_demark(t_ptr);
		t_ptr->cursor_line = start;
		t_ptr->xpos = text_x;
		t_ptr->ypos = text_y;
		make_chg(t_ptr->link,POS_CHANGE,0);
		blk_mark(t_ptr,0);
		t_ptr->xpos = text_x+len;
		blk_mark(t_ptr,1);
		restore_edit();
	}
	return erg;
}

int start_replace(TEXTP t_ptr)
{
	char 	*ptr;
	int	delta, erg, loc_r_modus, d,
			such_len, rpl_len;
	long	anz;

	last_op = 2;
	graf_mouse(HOURGLASS, NULL);
	rpl_len	= (int) strlen(replace_txt);
	anz = 0L;
	init_suche(t_ptr, modus);

	/* Nur zentrieren, wenn kein andere Pos bekannt. */
	if (rp_box_x == 0 && rp_box_y == 0)
		form_center(repask, &d, &d, &d, &d);
	else
	{
		repask[0].ob_x = rp_box_x;
		repask[0].ob_y = rp_box_y;
	}
	loc_r_modus = r_modus;
	
	while((erg=suchen(t_ptr, &such_len))==1)
	{
		delta = rpl_len-such_len;
		if (start->len + delta > MAX_LINE_LEN)
		{
			inote(1, 0, TOOLONG, MAX_LINE_LEN);
			erg = -1;
			break;
		}
		text_len = start->len-text_x;
		t_ptr->cursor_line = start;
		t_ptr->xpos = text_x;
		t_ptr->ypos = text_y;
		if (loc_r_modus != RP_ALL) 			/* Optional oder einzeln */
		{
			blk_demark(t_ptr);
			make_chg(t_ptr->link,POS_CHANGE,0);
			restore_edit();
			if (loc_r_modus == RP_OPT)
			{
				int antw;

				blk_mark(t_ptr,0);
				t_ptr->xpos = text_x+such_len;
				blk_mark(t_ptr,1);
				restore_edit();

				antw = simple_mdial(repask, 0) & 0x7fff;

				/* die Pos des Dialogs merken */
				rp_box_x = repask[0].ob_x;
				rp_box_y = repask[0].ob_y;

				if (antw == RAALL)					/* ab jetzt nicht mehr fragen */
					loc_r_modus = RP_ALL;
				else if (antw ==  RANEIN)			/* Nicht ersetzen */
				{
					if (vorw)
					{
						text_x++;
						text_len--;
					}
					else
					{
						text_len = text_x+such_len-1;
						text_x = 0;
					}
					continue;
				}
				else if (antw == RAENDE)			/* aufhîren */
				{
					erg = -1;
					break;
				}
				blk_demark(t_ptr);
			}
		}
		anz ++;
		get_undo_col(t_ptr);
		ptr = REALLOC(&start, text_x, delta);
		memcpy(ptr, replace_txt, rpl_len);
		t_ptr->cursor_line = start;
		if (loc_r_modus != RP_ALL)
		{
			make_chg(t_ptr->link,LINE_CHANGE,t_ptr->ypos);
			restore_edit();
			if (loc_r_modus == RP_FIRST) 
				break;
		}
		if (vorw)
		{
			text_x += rpl_len;
			text_len += delta;
			text_len -= rpl_len;
		}
		else
		{
			text_len = text_x;
			text_x = 0;
		}
	}
	graf_mouse(ARROW, NULL);
	if (anz > 0L)
	{
		t_ptr->moved++;
		make_chg(t_ptr->link,POS_CHANGE,0); 		/* wg. `*'	*/
		if (loc_r_modus == RP_ALL)
		{
			if (t_ptr->block)
			{
				t_ptr->p1 = get_line(&t_ptr->text,t_ptr->z1);
				t_ptr->p2 = get_line(&t_ptr->text,t_ptr->z2);
				blk_demark(t_ptr);
			}
			make_chg(t_ptr->link,TOTAL_CHANGE,0);
		}
		if (loc_r_modus != RP_FIRST)
		{
			char	info[30];

			sprintf(info, rsc_string(REPLACESTR), anz);
			set_info(t_ptr, info);
		}
		if (erg!=-1)
			erg = 1;
	}
	else
		if (erg != -1) 
			erg = 0;
	restore_edit();
	return erg;
}

int do_next(TEXTP t_ptr)
{
	int	erg;
	bool	vorw;

	vorw = (shift_pressed()) ? (!s_vorw) : s_vorw;
	set_suchmode(s_str, r_str, s_grkl, s_quant, vorw, s_wort, FALSE, s_round);
	if (last_op == 1)
		erg = start_find(t_ptr,FALSE);
	else if (last_op == 2)
		erg = start_replace(t_ptr);
	else
		erg = -1;
	return erg;
}

void find_selection(TEXTP t_ptr)
{
	if (t_ptr->block)
	{
		RING	r;
		bool	vorw;
		
		block_copy(t_ptr, &r);
		if (strlen(TEXT(FIRST(&r))) > 0)
		{
			strncpy(s_str, TEXT(FIRST(&r)), HIST_LEN);
			kill_textring(&r);
			s_str[HIST_LEN] = EOS;
			vorw = (shift_pressed()) ? (!s_vorw) : s_vorw;
			set_suchmode(s_str, r_str, s_grkl, s_quant, vorw, s_wort, FALSE, s_round);
			if (start_find(t_ptr, FALSE) == 0)
				Bconout(2, 7);
		}
	}
}


bool filematch(char *str, char *m, int fs_typ)
{
	char 	*where, muster[HIST_LEN+1];
	int		i;
	bool	gk = FALSE, old_flg[2];

	if ((str[0] == EOS) || (m[0] == EOS))
		return FALSE;
	
	if ((m[0] == '*') && (m[1] == '.'))		/* Ist m eine Extension? */
		gk = FALSE;									/* dann Groû == klein! */
	else
	{
		if (fs_typ == -1)
			fs_typ = fs_case_sens((char *)str);
		/* Echter GRkl-Unterscheidung nur bei Minix */
		gk = (fs_typ == FULL_CASE);
	}

	old_flg[0] = (modus != M_CURSOR);
	old_flg[1] = round;

	sprintf(muster, "^%s$", m);
	set_suchmode(muster, "", gk, TRUE, TRUE, FALSE, FALSE, FALSE);
	where = STRSTR2((char*)str, (int) strlen(str), muster_txt, &i);

	/* 
	 * FÅr den Fall, das ein Projekt durchsucht wird, wird filematch() fÅr
	 * die Zuordnung der lokalen Optionen fÅr jede durchsuchte Datei einmal
	 * aufgerufen. Damit danach die eigentlichen Such-Parameter wieder stimmen,
	 * der folgende Befehl!
	*/
	set_suchmode(s_str, r_str, s_grkl, s_quant, s_vorw, s_wort, old_flg[0], old_flg[1]);

	return (where==str);
}

/* Such-Dialoge *************************************************************/

static void insert_history(char h[HIST_ANZ][HIST_LEN+1], char *str)
{
	int	i,j;
	char	old_history[HIST_ANZ][HIST_LEN+1];

	/* alte History merken */
	memcpy(old_history[0], h[0], HIST_ANZ*(HIST_LEN+1));
	strcpy(h[0], str);
	j = 1;
	/* n-1 kopieren */
	for (i = 0; i < (HIST_ANZ - 1); i++)
	{
		/* jeden Eintrag nur einmal */
		if ((old_history[i][0] != EOS) && (strcmp(old_history[i], h[0])!=0))
		{
			strcpy(h[j], old_history[i]);
			j++;
		}
	}
}


static bool build_popup(char h[HIST_ANZ][HIST_LEN+1], POPUP *pop)
{
	char	str[HIST_LEN + 1];
	int	i;

	pop->tree = NULL;			/* init */

	if (h[0][0] == EOS)
		return FALSE;
	
	strcpy(str, " ");
	strcat(str, h[0]);
	create_popup(pop, HIST_ANZ, HIST_LEN + 3, str);

	for (i = 1; i < HIST_ANZ; i++)
	{
		if (h[i][0] != EOS)
		{
			strcpy(str, " ");
			strcat(str, h[i]);
			append_popup(pop, str);
		}
	}
	return (pop->tree != NULL);
}


static int circle_popup(char h[HIST_ANZ][HIST_LEN+1], void *dial, OBJECT* tree, int text_obj, int pos)
{
	if ((pos + 1 < HIST_ANZ) && (h[pos + 1][0] != EOS))
		pos++;
	else
		pos = 0;
	set_string(tree, text_obj, h[pos]);
	redraw_mdobj(dial, text_obj);
	return pos;
}


/*
 * Suchen/Ersetzen in Texten
 * RÅckgabe: 	0: Abbruch
 *					1: Suchen
 *					2: Ersetzen
*/
int replace_dial(void)
{
	int	antw, d, r_cycle, s_cycle;
	bool	im_kreis, s_p_v, r_p_v;			/* *_popup_valid */
	bool	close = FALSE;
	MDIAL	*dial;
	POPUP	s_pop, r_pop;
	char	s[HIST_LEN+1];
			
	/* Klemmbrett sichern, damit die Dialog das aktuelle haben */
	save_clip();

	set_state(replace, RPGLOBAL, SELECTED, s_global);
	set_state(replace, RPCURSOR, SELECTED, !s_global);
	set_state(replace, RPROUND, SELECTED, s_round);

	set_string(replace, RPTEXT1, s_str);
	set_string(replace, RPTEXT2, r_str);
	set_state(replace, RPGRKL, SELECTED, s_grkl);
	set_state(replace, RPWILD, SELECTED, s_quant);
	set_state(replace, RPWORT, SELECTED, s_wort);
	set_state(replace, RPVORW, SELECTED, s_vorw);
	set_state(replace, RPRUCKW, SELECTED, !s_vorw);
	set_state(replace, RPFIRST, SELECTED, r_modus==RP_FIRST);
	set_state(replace, RPALL, SELECTED, r_modus==RP_ALL);
	set_state(replace, RPOPTION, SELECTED, r_modus==RP_OPT);

	s_p_v = build_popup(s_history, &s_pop);
	r_p_v = build_popup(r_history, &r_pop);

	/* Popups ggf. abschalten */
	set_state(replace, RPSHIST, DISABLED, !s_p_v);
	set_state(replace, RPEHIST, DISABLED, !r_p_v);

	s_cycle = 0;
	r_cycle = 0;
	dial = open_mdial(replace, RPTEXT1);
	if (dial != NULL)
	{
		while (!close)
		{
			antw = do_mdial(dial) & 0x7fff;
			switch (antw)
			{
				case RPSSTR :
					if (s_p_v)
						s_cycle = circle_popup(s_history, dial, replace, RPTEXT1, s_cycle);
					break;
				case RPSHIST :
					if (s_p_v)
					{
						d = handle_popup(replace, RPSHIST, s_pop.tree, 0, POP_OPEN);
						if (d > 0)
						{
							s_cycle = d;
							get_string(s_pop.tree, s_cycle, s);
							set_string(replace, RPTEXT1, s+1);
							redraw_mdobj(dial, RPTEXT1);
						}
					}
					break;
		
				case RPESTR :
					if (r_p_v)
						r_cycle = circle_popup(r_history, dial, replace, RPTEXT2, r_cycle);
					break;
				case RPEHIST :
					if (r_p_v)
					{
						d = handle_popup(replace, RPEHIST, r_pop.tree, 0, POP_OPEN);
						if (d > 0)
						{
							r_cycle = d;
							get_string(r_pop.tree, r_cycle, s);
							set_string(replace, RPTEXT2, s+1);
							redraw_mdobj(dial, RPTEXT2);
						}
					}
					break;
		
				case RPHELP :
					menu_help(TSEARCH, MFIND);
					set_state(replace, antw, SELECTED, FALSE);
					redraw_mdobj(dial, antw);
					break;
		
				default:
					close = TRUE;
					break;
			}
		}
		close_mdial(dial);
		set_state(replace, antw, SELECTED, FALSE);
		if (antw == RPOK || antw == RPERSATZ)
		{
			get_string(replace, RPTEXT1, s_str);
			get_string(replace, RPTEXT2, r_str);
			if ((strcmp(s_str, r_str) == 0) && (antw == RPERSATZ))
			{
				note(1, 0, RPSAME);
				return 0;
			}
			s_grkl	= get_state(replace,RPGRKL, SELECTED);
			s_quant	= get_state(replace,RPWILD, SELECTED);
			s_wort	= get_state(replace,RPWORT, SELECTED);
			s_vorw = get_state(replace,RPVORW, SELECTED);
			s_global = get_state(replace,RPGLOBAL, SELECTED);
			s_round	= get_state(replace,RPROUND, SELECTED);
	
			if (get_state(replace, RPFIRST, SELECTED))
				r_modus = RP_FIRST;
			else if (get_state(replace, RPALL, SELECTED))
				r_modus = RP_ALL;
			else
				r_modus = RP_OPT;
	
			if (s_str[0] != EOS)
				insert_history(s_history, s_str);
			if (r_str[0] != EOS)
				insert_history(r_history, r_str);
	
			im_kreis = s_round && (antw == RPOK);	/* 'im Kreis' nur bei Suchen, nicht beim Ersetzen */
			set_suchmode(s_str, r_str, s_grkl, s_quant, s_vorw, s_wort, s_global, im_kreis);
			return ((antw == RPOK) ? 1 : 2);
		}
	}
	if (s_p_v)
		free_popup(&s_pop);
	if (r_p_v)
		free_popup(&r_pop);
	return 0;
}

/*
 * Suchen auf Disk / in Projekt
*/
bool findfile_dial(char *ff_path, bool in_prj)
{
	PATH	new_path = "", str = "";
	char 	s[HIST_LEN+1];
	int	antw, cycle, d;
	bool	close = FALSE, p_v;
	MDIAL	*dial;
	POPUP	pop;
		
	save_clip();

	if (in_prj)							/* Suche im Projekt */
	{
		set_string(find_obj, FFTITLE, rsc_string(FFSTR2));
		set_state(find_obj, FFSELP, DISABLED, TRUE);
		set_state(find_obj, FFREK, DISABLED, TRUE);
		set_state(find_obj, FFREK, SELECTED, FALSE);
		make_shortpath(ff_path, str, 50);
	}	
	else									/* Suche nach Dateien */
	{
		set_string(find_obj, FFTITLE, rsc_string(FFSTR1));
		set_state(find_obj, FFSELP, DISABLED, FALSE);
		set_state(find_obj, FFREK, DISABLED, FALSE);
		set_state(find_obj, FFREK, SELECTED, ff_rekursiv);
		strcpy(new_path, ff_path);
		if (ff_path[0] != EOS)
			make_shortpath(ff_path, str, 50);
	}
	set_string(find_obj, FFPATH, str);
	set_string(find_obj, FFMASK, ff_mask);
	set_string(find_obj, FFTEXT, s_str);
	set_state(find_obj, FFGRKL, SELECTED, s_grkl);
	set_state(find_obj, FFWILD, SELECTED, s_quant);
	set_state(find_obj, FFWORT, SELECTED, s_wort);

	p_v =	build_popup(s_history, &pop);

	/* Popup ggf. abschalten */
	set_state(find_obj, FFHIST, DISABLED, !p_v);

	cycle = 0;

	dial = open_mdial(find_obj, in_prj ? FFTEXT : FFMASK);
	if (dial != NULL)
	{
		while (!close)
		{
			antw = do_mdial(dial) & 0x7fff;

			switch (antw)
			{
				case FFSTR :
					if (p_v)
						cycle = circle_popup(s_history, dial, find_obj, FFTEXT, cycle);
					break;
				case FFHIST:
					if (p_v)
					{
						d = handle_popup(find_obj, FFHIST, pop.tree, 0, POP_OPEN);
						if (d > 0)
						{
							cycle = d;
							get_string(pop.tree, cycle, s);
							set_string(find_obj, FFTEXT, s+1);
							redraw_mdobj(dial, FFTEXT);
						}
					}
					break;

				case FFSELP:
					if (select_path(new_path, rsc_string(SELPATHSTR)))
						set_string(find_obj, FFPATH, new_path);
					break;
	
				case FFHELP :
					menu_help(TSEARCH, MFIND);
					break;
	
				default:
					close = TRUE;
					break;
			}
			if (!close)
			{
				set_state(find_obj, antw, SELECTED, FALSE);
				redraw_mdobj(dial, antw);
			}
		}
		close_mdial(dial);
		set_state(find_obj, antw, SELECTED, FALSE);
		if (antw == FFOK)
		{
			get_string(find_obj, FFTEXT, s_str);
			get_string(find_obj, FFMASK, ff_mask);
			ff_rekursiv = get_state(find_obj, FFREK, SELECTED);
			s_grkl	= get_state(find_obj, FFGRKL, SELECTED);
			s_quant	= get_state(find_obj, FFWILD, SELECTED);
			s_wort	= get_state(find_obj, FFWORT, SELECTED);
			if (!in_prj)
				strcpy(ff_path, new_path);
			if (s_str[0] != EOS)
				insert_history(s_history, s_str);
			set_suchmode(s_str, "", s_grkl, s_quant, TRUE, s_wort, TRUE, FALSE);
			if (in_prj && s_str[0] == EOS)
				return FALSE;
			else
				return TRUE;
		}
	}
	return FALSE;
}


	
/*****************************************************************************/
/*
 * Umlaute konvertieren
*/

static char umlaute[8][7] =
{	/* Ñ	  é	  î	  ô	  Å	  ö	  û	*/
	{ 0x84, 0x8E, 0x94, 0x99, 0x81, 0x9A, 0x9E},	/* Atari */
	{ 0xE4, 0xC4, 0xF6, 0xD6, 0xFC, 0xDC, 0xDF},	/* Latin */
	{ 0x8A, 0x80, 0x9A, 0x85, 0x9F, 0x86, 0xA7},	/* Mac */
	{ 0x84, 0x8E, 0x94, 0x99, 0x81, 0x9A, 0xE1},	/* PC */
	{  'a',  'A',  'o',  'O',  'u',  'U',  's'},	/* LaTeX */
	{  'a',  'A',  'o',  'O',  'u',  'U',  's'},	/* HTML */
	{  'a',  'A',  'o',  'O',  'u',  'U',  's'},	/* ASCII */
};


void change_umlaute(TEXTP t_ptr)
{
	ZEILEP	lauf;
	int		x, update;
	long		l;
	bool		cont = TRUE;
	bool		changed = FALSE;
	
	lauf = FIRST(&t_ptr->text);
	if (lauf != NULL)
	{
		x = bild_pos(t_ptr->xpos, t_ptr->cursor_line, TRUE, t_ptr->loc_opt->tabsize);
		start_aktion(rsc_string(UMLAUTSTR), TRUE, t_ptr->text.lines);
		l = 0;
		if (t_ptr->text.lines < 200)
			update = 10;
		else
			update = 100;

		graf_mouse(HOURGLASS, NULL);

		while (cont && !IS_TAIL(lauf))
		{
			if (lauf->len > 0)
			{
				int	u, xpos, len;
				char	c;
					
				xpos = 0;
				while (xpos < lauf->len)
				{
					c = TEXT(lauf)[xpos];
					if (c > 127)
					{
						for (u = 0; u <= 7; u++)
							if (c == umlaute[umlaut_from][u])
								break;
				
						if (u < 7)
						{
							changed = TRUE;
							if (umlaut_to == LaTeX)
							{
								if (lauf->len + 1 <= MAX_LINE_LEN)
								{
									TEXT(lauf)[xpos] = '"';
									xpos++;
									*(REALLOC(&lauf, xpos, 1)) = umlaute[umlaut_to][u];
								}
								else
									inote(1, 0, TOOLONG, MAX_LINE_LEN);
							}
							else if (umlaut_to == ASCII)
							{
								if (lauf->len + 1 <= MAX_LINE_LEN)
								{
									TEXT(lauf)[xpos] = umlaute[umlaut_to][u];
									xpos++;
									if (u == 6)
										*(REALLOC(&lauf, xpos, 1)) = 's';
									else
										*(REALLOC(&lauf, xpos, 1)) = 'e';
								}
								else
									inote(1, 0, TOOLONG, MAX_LINE_LEN);
							}
							else if (umlaut_to == HTML)
							{
								/* &auml; &szlig; */
								char	new[7] = "Xuml;";

								if (u == 6)
									strcpy(new, "szlig;");
								else
									new[0] = umlaute[umlaut_to][u];
								len = (int)strlen(new);
								if (lauf->len + len <= MAX_LINE_LEN)
								{
									TEXT(lauf)[xpos] = '&';
									xpos++;
									INSERT(&lauf, xpos, len, new);
									xpos += len-1;
								}
								else
									inote(1, 0, TOOLONG, MAX_LINE_LEN);
							}
							else
								TEXT(lauf)[xpos] = umlaute[umlaut_to][u];
						}
					}
					xpos++;
				} /* while xpos */
			} /* while lauf */
			NEXT(lauf);

			l++;
			if (l % update == 0)
				cont = do_aktion("", l);
		}
		
		graf_mouse(ARROW, NULL);
		end_aktion();

		if (changed)
		{
			t_ptr->moved++;
			t_ptr->cursor_line = get_line(&t_ptr->text, t_ptr->ypos);
			t_ptr->xpos = inter_pos(x, t_ptr->cursor_line, TRUE, t_ptr->loc_opt->tabsize);
			make_chg(t_ptr->link, WT_CHANGE, 0);
			make_chg(t_ptr->link, TOTAL_CHANGE, 0);
			t_ptr->max_line = NULL;

			if (t_ptr->loc_opt->umbrechen)
				total_format(t_ptr);

			restore_edit();
		}
	}
}

bool umlaut_dial(void)
{
	bool	ret = FALSE, close = FALSE;
	int	antw, new_from, new_to, d;
	MDIAL	*dial;
	char	str[30];
		
	new_from = umlaut_from;
	new_to = umlaut_to;
	if (shift_pressed())				/* bei Shift: Quelle und Ziel vertauschen */
	{
		if (umlaut_to <= PC)			/* nur einbuchstabige kînnen umgedreht werden! */
		{
			new_from = umlaut_to;
			new_to = umlaut_from;
		}
		else
		{
			Bconout(2, 7);
			return FALSE;
		}
	}
	get_string(popups, UPFROMST + new_from, str);
	set_string(umlautkonv, UVON, str);
	get_string(popups, UPTOST + new_to, str);
	set_string(umlautkonv, UNACH, str);

	dial = open_mdial(umlautkonv, 0);
	if (dial != NULL)
	{
		while (!close)
		{
			antw = do_mdial(dial) & 0x7fff;
			switch (antw)
			{
				case UVSTR :
				case UVON :
					if (antw == UVON)
						d = handle_popup(umlautkonv, UVON, popups, UMLAUTPOP1, POP_OPEN);
					else
						d = handle_popup(umlautkonv, UVON, popups, UMLAUTPOP1, POP_CYCLE);
					if (d > 0)
						new_from = d - UPFROMST;
					break;
				case UNSTR :
				case UNACH :
					if (antw == UNACH)
						d = handle_popup(umlautkonv, UNACH, popups, UMLAUTPOP2, POP_OPEN);
					else
						d = handle_popup(umlautkonv, UNACH, popups, UMLAUTPOP2, POP_CYCLE);
					if (d > 0)
						new_to = d - UPTOST;
					break;

				default:
					close = TRUE;
					break;
			}
		}
		set_state(umlautkonv, antw, SELECTED, FALSE);
		close_mdial(dial);
		if (antw == UKSTART)
		{
			if (new_from == new_to)
			{
				note(1, 0, NOKONV);
				ret = FALSE;
			}
			else
			{
				umlaut_from = new_from;
				umlaut_to = new_to;
				ret = TRUE;
			}
		}
	}
	return ret;
}
