#include <gemx.h>
#include <support.h>
#include <time.h>

#include "global.h"
#include "aktion.h"
#include "block.h"
#include "memory.h"
#include "rsc.h"
#include "wp-print.h"
#include "printer.h"

/*
 * aus prn_cfg.c
*/
extern bool open_printer	(void);
extern void close_printer	(void);

/*
 * lokales 
*/
static int	prn_y, line_height;
static int	channel;

/* --------------------------------------------------------------------------- */
static bool prn_ready (void)
{
	switch (channel)
	{
		case 0 :
			return Cprnos() != 0;
		case 1 :
			return Cauxos() != 0;
		default:
			return FALSE;
	}
}

static bool prn_check (int wait_time)
{
	/* Schnittstelle nur bei !WDIALOG prfen */
	if (!prn->use_pdlg && prn->pruef_prn)
	{
		bool	ok = FALSE,
				cancel = FALSE;
		long	timer;

		while (!ok && !cancel)
		{
			timer = 200 * wait_time + clock();
			ok = prn_ready();
			while (!ok && (timer > clock()))
				ok = prn_ready();
			if (!ok)
		 		cancel = (note(1, 2, PRNOTRDY) == 2);
		}
		return (ok && !cancel);
	}
	else
		return TRUE;
}

static void plot_ff(void)
{
	if (prn->use_gdos)
	{
		prn_y = 0;
		v_updwk(prn->handle);
		v_clrwk(prn->handle);
	}
	else
		wp_formfeed();
}

static void plot_nl(void)
{
	if (prn->use_gdos)
		prn_y += line_height;
	else
		wp_write_ln();
}

static void plot_line(char *s)		/* Zeile mit Vorschub */
{
	int	l;
	
	if (prn->use_gdos)
	{
		v_gtext(prn->handle, 0, prn_y, s);
		prn_y += line_height;
	}
	else
	{
		l = (int)strlen(s);
		if (l > prn->wp_z_len)			/* Clipping */
			s[prn->wp_z_len] = EOS;
		wp_write_string(s);
		wp_write_ln();
	}
}

/* --------------------------------------------------------------------------- */
static void expand_line(char *buffer, char *line, bool tab, int tab_size)
{
	int	tabH;
	char	*p;
	
	tabH = 0;
	p = buffer + strlen(buffer);
	while	(*line != '\0')
	{
		if (!tabH)
			tabH = tab_size;
		if (tab && *line == '\t')
		{
			while (tabH > 0)
			{
				*p = ' ';
				p++;
				tabH--;
			}
			tabH = tab_size;
		}
		else
		{
			*p = *line;
			p++;
			tabH --;
		}
		line++;
	}
	*p = EOS;
}

/* --------------------------------------------------------------------------- */
static void drucken(char *name, RINGP t, TEXTP t_ptr)
{
	int		seite, lzeile, zeilen_pro_seite, update;
	char		datum[11], *buffer = NULL, str[80];
	long		zeile, buf_len;
	ZEILEP	lauf;

	/* Schnittstelle ermitteln */
	channel = ((Setprt(-1) & 16) != 0);

	if (prn->use_gdos)
	{
		int	p_xy[8], d, eff[3];

		if (!open_printer())
			return;
	
		if (!prn_check(0))
		{
			close_printer();
			return;
		}
	
		vst_font(prn->handle, prn->font_id);
		vst_point(prn->handle, prn->font_pts, &d, &d, &d, &d);
	
		vqt_fontinfo(prn->handle, &d, &d, p_xy, &d, eff);
		line_height = p_xy[0] + p_xy[4] + 1;
		vst_alignment(prn->handle, TA_LEFT , TA_ASCENT, &d, &d);
	
		if (vs_document_info(prn->handle, 0, "qed", 0))
			vs_document_info(prn->handle, 1, name, 0);

		zeilen_pro_seite = prn->height/line_height;
	}
	else
	{
		if (!prn_check(0))
			return;
	
		if (channel == 0)
			strcpy(str, "PRN:");
		else
			strcpy(str, "AUX:");
	
		if (!wp_open(str))
			return;
	
		wp_send_init(prn->wp_nlq);
		wp_set_mode(prn->wp_mode);

		zeilen_pro_seite = prn->wp_s_len;
	}
	
	get_datum(datum);
	lzeile = zeilen_pro_seite;
	seite = 1;
	zeile = 0;
	prn_y = 0;

	strcpy(str, rsc_string(PRINTSTR));
	strcat(str, name);
	start_aktion(str, TRUE, t->lines);
	if (t->lines > 200)
		update = 100;
	else
		update = 10;

	/* Puffer fr eine komplette Zeile dynamisch anfordern */
	if (t_ptr->max_line == NULL)		/* Projekt! */
		buf_len = MAX_PATH_LEN + prn->rand_len;
	else
		buf_len = t_ptr->max_line->exp_len + prn->rand_len;
	if (prn->num_zeilen)
		buf_len += 6;						/* fr Zeilennummer */
	buffer = malloc(buf_len);
	
	if (buffer == NULL)
	{
		note(1, 0, NOMEMORY);
		return;
	}
	
	graf_mouse(HOURGLASS, NULL);
	lauf = FIRST(t);
	while (TRUE)
	{
		if (!prn_check(5))
			break;

		if (lzeile == zeilen_pro_seite)
		{
			lzeile = 0;
			if (zeile != 0) 
				plot_ff();
			if (prn->num_seiten)
			{
				sprintf(str, "    %s%s    %s%d    %s%s", rsc_string(FILESTR), name,
																	  rsc_string(PAGESTR), seite,
																	  rsc_string(DATESTR), datum);
				plot_line(str);
				plot_nl();
				lzeile = 2;
				seite++;
			}
		}
		
		if ((zeile % update == 0) && !do_aktion("", zeile))
		{
			if (note(1, 2, BREAK) == 1) 
				break;
			else
				redraw_aktion();
		}

		zeile++;
		lzeile++;

		/* Zeile aufbauen: Rand, Nummer, Text */
		buffer[0] = EOS;
		if (prn->rand_len > 0)
		{
			memset(buffer, 32, prn->rand_len);
			buffer[prn->rand_len] = EOS;
		}

		if (prn->num_zeilen)
		{
			sprintf(str, "%4ld  ", zeile);
			strcat(buffer, str);
		}
		
		expand_line(buffer, TEXT(lauf), t_ptr->loc_opt->tab, t_ptr->loc_opt->tabsize);
		plot_line(buffer);

		NEXT(lauf);
		if (IS_TAIL(lauf)) 
			break;
	}
	if (prn->use_gdos)
	{
		v_updwk(prn->handle);
		if (!prn->use_pdlg && prn->vorschub)
			v_clrwk(prn->handle);
		close_printer();
	}
	else
	{
		if (prn->wp_s_len && zeile && prn->vorschub)
			plot_ff();
		wp_send_exit();
		wp_close();
	}
	end_aktion();

	free(buffer);
	graf_mouse(ARROW, NULL);
}

/* --------------------------------------------------------------------------- */
void blk_drucken(char *name, TEXTP t_ptr)
{
	RING t;

	if (prn == NULL)
		return;

	block_copy(t_ptr,&t);
	drucken(name, &t, t_ptr);
	kill_textring(&t);
}

void txt_drucken(char *name, TEXTP t_ptr)
{
	if (prn == NULL)
		return;

	drucken(name, &t_ptr->text, t_ptr);
}
