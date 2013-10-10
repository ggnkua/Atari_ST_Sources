#include <support.h>

#include "global.h"
#include "ausgabe.h"
#include "memory.h"
#include "options.h"
#include "rsc.h"
#include "window.h"

#define BLKANF		1
#define BLKEND		2
#define BLKFULL	4

/* lokale Variablen ********************************************************/
static char	*text = NULL;
static int	text_len = 0;
#define MIN_TEXT_LEN	((MAX_LINE_LEN+1) / 4)	/* StartlÑnge: 256 Bytes */

/*!! Muessen am Anfang jeder Routine gesetzt werden !!*/
static bool	tab;
static int	tab_size;
static bool	umbrechen;
static bool	show_end;
static int	draw_mode;
static bool	opt_draw;


void set_drawmode(void)
{
	if (bg_color == WHITE)
	{
		/*
		 * Schnellere Ausgabe, da durch MD_REPLACE das Lîschen der Zeile
		 * vor Ausgabe des Textes entfallen kann.
		 * Nur mîglich, wenn als Hintergrundfarbe weiû gewÑhlt ist!
		*/
		opt_draw = TRUE;
		draw_mode = MD_REPLACE;
	}
	else
	{
		/* 'langsame' Ausgabe bei nicht-weiûem Hintergrund */
		opt_draw = FALSE;
		draw_mode = MD_TRANS;
	}
	vswr_mode(vdi_handle, draw_mode);
}


static void set_fill_color(int new)
{
	if (new != fill_color)
	{
		vsf_color(vdi_handle, new);
		fill_color = new;
	}
}

/*
 * Dynamischer Zeilenpuffer fÅr die expandierte Zeile. MAX_LINE_LEN reicht
 * nicht aus, wenn eine Zeile echte TABs enthÑlt!
 * Der angeforderte Puffer wird von line_to_str() benutzt.
*/
static void adjust_text(TEXTP t_ptr)
{
	int	need;
	
	if (t_ptr->max_line == NULL)
		need = -1;
	else
		need = t_ptr->max_line->exp_len;
	if (text == NULL || need > text_len)
	{
		text_len = max(need, MIN_TEXT_LEN);
		text = realloc(text, text_len + 1);
	}
}

/*
 * Expandiert eine ganze Zeile zu einem String fÅr die 
 * Ausgabe mit v_gtext().
 * Tab-Zeichen werden ggf. in mehrere CHR(32) gewandelt
 * Die StringlÑnge wird zurÅckgegeben.
*/
int line_to_str(char *str, int anz)
{
	int	len, i, end;
	char	c, *t;

	t = text;
/*	str = TEXT(a);
	if (anz == -1)
		end = a->len;
	else */
		end = anz;
	if (tab)
	{
		int	tabH;

		tabH = tab_size;
		for (i = end, len = text_len; (--i)>=0; )
		{
			c = *str++;
			if (c == '\t')
			{
				len -= tabH;
				if (len < 0)
				{
					tabH += len;
					len = 0;
				}
				while (TRUE)
				{
					*t++ = ' ';	
					if ((--tabH) == 0) 
						break;
				}
				if (len == 0) 
					break;			/* Puffer voll */
				tabH = tab_size;
			}
			else if (c < min_ascii || c > max_ascii)
			{
				*t++ = ' ';
				if ((--tabH) == 0) 
					tabH = tab_size;
				if ((--len) == 0) 
					break;		/* Puffer voll */
			}
			else
			{
				*t++ = c;
				if ((--tabH) == 0)
					tabH = tab_size;
				if ((--len) == 0) 
					break;		/* Puffer voll */
			}
		}
		len = text_len - len;
		*t = EOS;
	}
	else
	{
		for (i = end, len = 0; (--i) >= 0 && (len < text_len); len++)
		{
			c = *str++;
			if (c < min_ascii || c > max_ascii)
				*t++ = ' ';
			else
				*t++ = c;
		}
		*t = EOS;
	}
	return(len);
}

/* Liefert die interne Position */
int inter_pos(int x, ZEILEP a, bool tab, int tab_size)
{
	int	len  = 0,
			tabH = tab_size,
		 	i    = 0;
	char *str;

	if (!tab)
		return min(x,a->len);
	str = TEXT(a);
	while(len < x && i < a->len)
	{
		if ((*str++) == '\t')
		{
			len += tabH;
			tabH = tab_size;
		}
		else
		{
			len++;
			if ((--tabH)==0)
				tabH = tab_size;
		}
		i++;
	}
	if (len > x)
		i--;
	return i;
}

int bild_len(ZEILEP a, bool tab, int tab_size)
{
	return bild_pos(a->len,a,tab,tab_size);
}

int bild_pos(int x, ZEILEP a, bool tab, int tab_size)
{
	int	len  = 0,
			tabH = tab_size;
	char	*str;

	if (!tab)
		return min(x, a->len);
	str = TEXT(a);
	while ((--x)>=0)
	{
		if ((*str++) == '\t')
		{
			len += tabH;
			tabH = tab_size;
		}
		else
		{
			len++;
			if ((--tabH)==0)
				tabH = tab_size;
		}
	}
	return len;
}

/*----------------------------------------------------------------------------
 * Cursor-Handling
*/
int cursor_xpos(TEXTP t_ptr, int pos)
{
	int	len;
	
	if (font_prop)
	{
		int	pxy[8];
		
		tab = t_ptr->loc_opt->tab;
		tab_size = t_ptr->loc_opt->tabsize;
		adjust_text(t_ptr);
		line_to_str(TEXT(t_ptr->cursor_line), pos);
		vqt_extent(vdi_handle, text, pxy);
		len = pxy[2] - pxy[0];
	}
	else
		len = bild_pos(pos, t_ptr->cursor_line, t_ptr->loc_opt->tab, t_ptr->loc_opt->tabsize) * font_wcell;

	return len;
}

static void _cursor(GRECT *r)
{
	int 	pxy[4];

	pxy[0] = r->g_x;
	pxy[1] = r->g_y;
	pxy[2] = r->g_x + r->g_w - 1;
	pxy[3] = r->g_y + r->g_h - 1;
	set_fill_color(fg_color);
	vswr_mode(vdi_handle, MD_XOR);
	vr_recfl (vdi_handle, pxy);
	vswr_mode(vdi_handle, draw_mode);
}

void cursor(WINDOWP w, TEXTP t_ptr)
{
	int		pxy[8];
	char		c[2];
	GRECT		curs_rect, clip;
	long		zeile;
	bool		hidden;

	/* Position ermitteln */	
	curs_rect.g_x = cursor_xpos(t_ptr, t_ptr->xpos) - ((int) w->doc.x * font_wcell) + w->work.g_x;

	zeile = t_ptr->ypos - w->doc.y;
	curs_rect.g_y = (int) zeile * font_hcell + w->work.g_y;

	/* Cursor Åberhaupt sichtbar? */
	if (curs_rect.g_x < w->work.g_x || curs_rect.g_x > (w->work.g_x + w->work.g_w - 1) ||
		 curs_rect.g_y < w->work.g_y || curs_rect.g_y > (w->work.g_y + w->work.g_h - 1) ||
		 (w->flags & WI_ICONIFIED))
		return;

	/* Breite und Hîhe ermitteln */	
	if (overwrite)
	{
		if (font_prop)
		{
			c[0] = TEXT(t_ptr->cursor_line)[t_ptr->xpos];
			c[1] = EOS;
			vqt_extent(vdi_handle, c, pxy);
			curs_rect.g_w = pxy[2] - pxy[0];
			if (curs_rect.g_w == 0)
				curs_rect.g_w = 1;
			curs_rect.g_h = pxy[7] - pxy[1];
		}
		else
		{
			curs_rect.g_w = font_wcell;
			curs_rect.g_h = font_hcell;
		}
	}
	else
	{
		curs_rect.g_w = 3;
		curs_rect.g_h = font_hcell;
	}

	/*
	 * Am Rand (oben/unten) darf der Cursor nicht Åberstehen, ansonsten
	 * 2 Pixel oben/unten.
	 */
	if (zeile > 0)
	{
		curs_rect.g_y -= 2;
		curs_rect.g_h += 2;
	}
	if (zeile < w->w_height-1)
		curs_rect.g_h += 2;

	wind_update(BEG_UPDATE);
	hidden = hide_mouse_if_needed(&curs_rect);

	if (rc_first(w->handle, &curs_rect, &clip))
	{
		do
		{
			set_clip(TRUE, &clip);
			_cursor(&curs_rect);
		}
		while(rc_next(w->handle, &clip));
	}
	if (hidden)
		show_mouse();
	wind_update(END_UPDATE);
}

static ZEILEP get_wline(TEXTP t_ptr, long y)
{
	ZEILEP	lauf;
	long 		i;

	if (y < 0 || y >= t_ptr->text.lines)
		return NULL;
	i = t_ptr->ypos;
	lauf = t_ptr->cursor_line;
	if (i > y)
	{
		i -= y;
		while (TRUE)
		{
			VORG(lauf);
			if ((--i)==0)
				break;
		}
	}
	else if (i < y)
	{
		y -= i;
		while (TRUE)
		{
			NEXT(lauf);
			if ((--y)==0)
				break;
		}
	}
	return (lauf);
}

/*-----------------------------------------------------------------------------
 * FlÑche fÅllen.
 *
 * x ist Pixel-Koordinate
 * y ist Pixel-Koordinate
 * w ist die Breite in Pixel, die abgedeckt werden soll
*/
void fill_area(int x, int y, int w, int h, int color)
{
	int	pxy[4];

	if (w <= 0) 
		return;
	pxy[0] = x;
	pxy[1] = y;
	pxy[2] = x + w - 1;
	pxy[3] = y + h - 1;
	set_fill_color(color);
	vswr_mode(vdi_handle, MD_REPLACE);
	vr_recfl(vdi_handle, pxy);
	vswr_mode(vdi_handle, draw_mode);
}

/*
 * String mit v_gtext() ausgeben.
 *
 * x ist Pixel-Koordinate
 * y ist Pixel-Koordinate
 * w ist die Breite in Pixel, die abgedeckt werden soll
 * return ende der Textausgabe
*/
int out_s(int x, int y, int w, char *str)
{
	int	pxy[8], len;

	if (w <= 0)
		return x;

	if (!opt_draw)
		fill_area(x, y, w, font_hcell, bg_color);

	v_gtext(vdi_handle, x, y, str);
	if (font_prop)
	{
		vqt_extent(vdi_handle, str, pxy);
		len = pxy[2]-pxy[0];
	}
	else
		len = (int) strlen(str) * font_wcell;

	if (len < w)
	{
		/* Text kÅrzer als Fenster breit: Rest lîschen */
		if (opt_draw)
			fill_area(x + len, y, w, font_hcell, bg_color);
		return x + len;
	}
	return x + w;
}

/*
 * String invers mit v_gtext ausgeben.
 *
 * x ist Pixel-Koordinate
 * y ist Pixel-Koordinate
 * w ist die Breite in Pixel, die abgedeckt werden soll
 * return ende der Textausgabe
*/
int out_sb(int x, int y, int w, char *str)
{
	int	pxy[8], len;

	if (w <= 0)
		return x;

#if 0
	/* Hintergrund fÅllen, da mit XOR drÅbergemalt wird */
	fill_area(x, y, w, font_hcell, fg_color);

	vswr_mode(vdi_handle, MD_XOR);
	v_gtext(vdi_handle, x, y, str);
	vswr_mode(vdi_handle, draw_mode);
#endif

	/* Hintergrund mit fg_color fÅllen und Text mit bg_color drÅbermalen */
	fill_area(x, y, w, font_hcell, fg_color);

	vst_color(vdi_handle, bg_color);
	if (opt_draw)
		vswr_mode(vdi_handle, MD_TRANS);
	v_gtext(vdi_handle, x, y, str);
	if (opt_draw)
		vswr_mode(vdi_handle, draw_mode);
	vst_color(vdi_handle, fg_color);

	if (font_prop)
	{
		vqt_extent(vdi_handle, str, pxy);
		len = pxy[2] - pxy[0];
	}
	else
		len = (int) strlen(str) * font_wcell;
	if (len > w)
		return x + w;
	return x + len;
}

/*
 * Absatzmarke zeichnen.
*/
static void draw_cr(int x, int y, bool inv)
{
	int pxy[6], h, b;

	if (inv)
		vsl_color (vdi_handle, bg_color);
	else
		vsl_color (vdi_handle, fg_color);
	b = min(font_wcell, font_hcell);
	h = b >> 1;
	y += (font_hcell >> 1);
	pxy[0] = x + b - 1;			/* oben rechts */
	pxy[1] = y - h;
	pxy[2] = x + b - 1;			/* mitte rechst */
	pxy[3] = y;
	pxy[4] = x;						/* mitte links */
	pxy[5] = y;
	v_pline (vdi_handle, 3, pxy);
	h = h >> 1;
	pxy[0] = x + h;				/* schrÑg oben */
	pxy[1] = y - h;
	pxy[2] = x;						/* mitte links */
	pxy[3] = y;
	pxy[4] = x + h;				/* schrÑg unten */
	pxy[5] = y + h;
	v_pline (vdi_handle, 3, pxy);
	if (inv)
		vsl_color(vdi_handle, fg_color);
	else
		vsl_color(vdi_handle, bg_color);
}

/*
 * String mit v_gtext() ausgeben.
 *
 * x ist Pixel-Koordinate
 * y ist Pixel-Koordinate
 * w ist die Breite in Pixel, die abgedeckt werden soll
 * offset in Zeichen
*/
static void str_out(int x, int y, int w, int offset, ZEILEP a)
{
	int	len, anz;
	int	pxy[8];

	anz = line_to_str(TEXT(a), a->len);

	if (!opt_draw)
		fill_area(x, y, w, font_hcell, bg_color);

	if (font_prop)
	{
		/* auf bei prop. wird um font_wcell gescrollt! */
		offset *= font_wcell;
		x -= offset;
		w += offset;
		v_gtext(vdi_handle, x, y, text);
		vqt_extent(vdi_handle, text, pxy);
		len = pxy[2] - pxy[0];
		if (len < w)
		{
			/* Text kÅrzer als Fenster breit: Rest lîschen */
			if (opt_draw)
				fill_area(x+len, y, w-len, font_hcell, bg_color);

			if (IS_OVERLEN(a) || (umbrechen && IS_ABSATZ(a) && show_end))
				draw_cr(x+len, y, FALSE);
		}
	}
	else
	{
		if (offset >= anz)
		{
			/* kein Text, ganze Zeile lîschen */
			if (opt_draw)
				fill_area(x, y, w, font_hcell, bg_color);

			if (offset == anz && (IS_OVERLEN(a) || (umbrechen && IS_ABSATZ(a) && show_end)))
				draw_cr(x, y, FALSE);
		}
		else
		{
			anz -= offset;
			len = anz * font_wcell;
			if (w <= len)
			{
				/* Zeile bis zum rechten Fensterrand */
				text[offset+w/font_wcell] = EOS;
				v_gtext(vdi_handle, x, y, text+offset);
			}
			else
			{
				v_gtext(vdi_handle, x, y, text+offset);

				/* Text kÅrzer als Fenster breit: Rest lîschen */
				if (opt_draw)
					fill_area(x+len, y, w-len, font_hcell, bg_color);

				if (IS_OVERLEN(a) || (umbrechen && IS_ABSATZ(a) && show_end))
					draw_cr(x + len, y, FALSE);
			}
		}
	}
}

/*
 * String mit v_gtext() invers ausgeben.
 *
 * x ist Pixel-Koordinate
 * y ist Pixel-Koordinate
 * w ist die Breite in Pixel, die abgedeckt werden soll
 * offset in Zeichen
 * mode (BLKANF, BLKEND, BLKFULL)
*/
static void str_out_b(int x, int y, int w, int offset, ZEILEP a, int mode, int x1, int x2)
{
	int	anz, anz1, anz2, len, len2, pxy[8], end;
	char	h;

	anz = line_to_str(TEXT(a), a->len);
	if (anz <= offset)		/* ganze Zeile ohne Text */
	{
		if (font_prop)
		{
			vqt_extent(vdi_handle,text,pxy);
			end = x - (offset * font_wcell) + (pxy[2] - pxy[0]);
		}
		else
			end = x - (offset * font_wcell) + anz * font_wcell;
		if (mode == BLKFULL || mode == BLKANF)
		{
			fill_area(x, y, w, font_hcell, fg_color);
			if (end >= x && end < x + w && (IS_OVERLEN(a) || (umbrechen && IS_ABSATZ(a) && show_end)))
				draw_cr(end, y, TRUE);
		}
		else
		{
			fill_area(x, y, w, font_hcell, bg_color);
			if (end >= x && end < x + w && (IS_OVERLEN(a) || (umbrechen && IS_ABSATZ(a) && show_end)))
				draw_cr(end, y, FALSE);
		}
		return;
	}
	if (font_prop)
	{
		offset *= font_wcell;
		x -= offset;
		w += offset;
		if (mode==BLKFULL)
		/* Ganze Zeile einheitlich invers */
		{
			end = out_sb(x,y,w,text);
			if (end < x + w && (IS_OVERLEN(a) || (umbrechen && IS_ABSATZ(a) && show_end)))
				draw_cr(end, y, TRUE);
		}
		else
		/* Blockanfang oder -ende oder beides */
		{
			if (mode==BLKANF)
			{
				anz1 = bild_pos(x1,a,tab,tab_size);
				h = text[anz1]; text[anz1] = EOS;
				vqt_extent(vdi_handle,text,pxy);
				len = pxy[2]-pxy[0];
				end = out_s(x,y,len,text);
				text[anz1] = h;
				end = out_sb(end,y,w-len,text+anz1);
				if (end < x + w && (IS_OVERLEN(a) || (umbrechen && IS_ABSATZ(a) && show_end)))
					draw_cr(end, y, TRUE);
			}
			else if (mode==BLKEND)
			{
				anz1 = bild_pos(x2,a,tab,tab_size);
				h = text[anz1]; text[anz1] = EOS;
				vqt_extent(vdi_handle,text,pxy);
				len = pxy[2]-pxy[0];
				end = out_sb(x,y,len,text);
				text[anz1] = h;
				end = out_s(end,y,w-len,text+anz1);
				if (end < x + w && (IS_OVERLEN(a) || (umbrechen && IS_ABSATZ(a) && show_end)))
					draw_cr(end, y, FALSE);
			}
			else /* (mode==(BLKANF+BLKEND) */
			{
				anz1 = bild_pos(x1,a,tab,tab_size);
				h = text[anz1]; text[anz1] = EOS;
				vqt_extent(vdi_handle,text,pxy);
				len = pxy[2]-pxy[0];
				end = out_s(x,y,len,text);
				text[anz1] = h;

				anz2 = bild_pos(x2,a,tab,tab_size);
				h = text[anz2]; text[anz2] = EOS;
				vqt_extent(vdi_handle,text+anz1,pxy);
				len2 = pxy[2]-pxy[0];
				end = out_sb(end,y,len2,text+anz1);
				text[anz2] = h;

				end = out_s(end,y,w-len-len2,text+anz2);
				if (end < x + w && (IS_OVERLEN(a) || (umbrechen && IS_ABSATZ(a) && show_end)))
					draw_cr(end, y, FALSE);
			}
		}
	}
	else
	{
		char *ptr = text+offset;

		anz -= offset;
		if (anz * font_wcell > w)
		{
			anz = w/font_wcell;
			ptr[anz] = EOS;
		}
		if (mode == BLKFULL)
		/* Ganze Zeile einheitlich invers */
		{
			end = out_sb(x,y,w,ptr);
			if (end < x + w && (IS_OVERLEN(a) || (umbrechen && IS_ABSATZ(a) && show_end)))
				draw_cr(end, y, TRUE);
		}
		else
		/* Blockanfang oder -ende oder beides */
		{
			if (mode==BLKANF)
			{
				anz1 = bild_pos(x1,a,tab,tab_size)-offset;
				if (anz1<0) anz1 = 0;
				if (anz1>anz) anz1 = anz;
				h = ptr[anz1]; ptr[anz1] = EOS;
				len = anz1*font_wcell;
				end = out_s(x,y,len,ptr);
				ptr[anz1] = h;
				end = out_sb(end,y,w-len,ptr+anz1);

				if (end < x + w && (IS_OVERLEN(a) || (umbrechen && IS_ABSATZ(a) && show_end)))
					draw_cr(end,y, TRUE);
			}
			else if (mode==BLKEND)
			{
				anz1 = bild_pos(x2,a,tab,tab_size)-offset;
				if (anz1<0) anz1 = 0;
				if (anz1>anz) anz1 = anz;
				h = ptr[anz1]; ptr[anz1] = EOS;
				len = anz1*font_wcell;
				end = out_sb(x,y,len,ptr);
				ptr[anz1] = h;
				end = out_s(end,y,w-len,ptr+anz1);
				if (end < x + w && (IS_OVERLEN(a) || (umbrechen && IS_ABSATZ(a) && show_end)))
					draw_cr(end, y, FALSE);
			}
			else /* (mode==(BLKANF+BLKEND) */
			{
				anz1 = bild_pos(x1,a,tab,tab_size)-offset;
				if (anz1<0) anz1 = 0;
				if (anz1>anz) anz1 = anz;
				h = ptr[anz1]; ptr[anz1] = EOS;
				len = anz1*font_wcell;
				end = out_s(x,y,len,ptr);
				ptr[anz1] = h;

				anz2 = bild_pos(x2,a,tab,tab_size)-offset;
				if (anz2<0) anz2 = 0;
				if (anz2>anz) anz2 = anz;
				h = ptr[anz2]; ptr[anz2] = EOS;
				len2  = anz2*font_wcell - len;
				end = out_sb(end,y,len2,ptr+anz1);
				ptr[anz2] = h;

				end = out_s(end,y,w-len-len2,ptr+anz2);
				if (end < x + w && (IS_OVERLEN(a) || (umbrechen && IS_ABSATZ(a) && show_end)))
					draw_cr(end, y, FALSE);
			}
		}
	}
}

/* =========================================================== */

void line_out(WINDOWP window, TEXTP t_ptr, int wy)
{
	int		y;
	ZEILEP	col;

	adjust_text(t_ptr);					/* Zeilenpuffer an exp_len anpassen */
	tab = t_ptr->loc_opt->tab;
	tab_size = t_ptr->loc_opt->tabsize;
	umbrechen = t_ptr->loc_opt->umbrechen;
	show_end = t_ptr->loc_opt->show_end;
	y = window->work.g_y+wy*font_hcell;
	col = get_wline(t_ptr, window->doc.y+wy);
	if (col != NULL)												/* Kommt vor */
	{
		if (t_ptr->block)
		{
			wy += (int) window->doc.y;
			if (wy<t_ptr->z1 || wy>t_ptr->z2)
				str_out(window->work.g_x, y, window->work.g_w, (int)window->doc.x, col);
			else
			{
				int	mode = 0;

				if (wy == t_ptr->z1)
					mode |= BLKANF;
				if (wy == t_ptr->z2)
					mode |= BLKEND;
				if (!mode)
					mode = BLKFULL;
				str_out_b(window->work.g_x, y, window->work.g_w,
				         (int) window->doc.x, col, mode, t_ptr->x1, t_ptr->x2);
			}
		}
		else
			str_out(window->work.g_x, y, window->work.g_w, (int) window->doc.x, col);
	}
	else
		fill_area(window->work.g_x, y, window->work.g_w, font_hcell, bg_color);
}

void bild_out(WINDOWP window, TEXTP t_ptr)
{
	int		x, y, w;
	ZEILEP	lauf;
	int		min_col, max_col, max_y;
	GRECT		c;

	adjust_text(t_ptr);					/* Zeilenpuffer an exp_len anpassen */
	tab = t_ptr->loc_opt->tab;
	tab_size = t_ptr->loc_opt->tabsize;
	umbrechen = t_ptr->loc_opt->umbrechen;
	show_end = t_ptr->loc_opt->show_end;
	x = window->work.g_x;
	y = window->work.g_y;
	w = window->work.g_w;

	if (window->class == CLASS_EDIT)						/* Kopf ausgeben */
		head_out(window, t_ptr);

	min_col = 0;
	max_col = (int) min(window->w_height - 1, t_ptr->text.lines - window->doc.y-1);
	max_y   = y + window->work.g_h-1;
	if (get_clip(&c))					/* nicht alles malen */
	{
		int y2 = c.g_y - y;

		min_col = max(min_col, y2/font_hcell);
		max_col = min(max_col, (c.g_y + c.g_h - 1) / font_hcell);
		max_y = min(max_y, c.g_y + c.g_h - 1);
	}
	y += (min_col * font_hcell);
	lauf = get_wline(t_ptr, window->doc.y + min_col);
	if (lauf != NULL)
	{
		int	xoffset, i;

		xoffset = (int) window->doc.x;
		if (t_ptr->block)
		{
			long	y_r;

			y_r = window->doc.y+min_col;
			for (i=min_col ; i<=max_col; y_r++,y+=font_hcell,NEXT(lauf),i++)
			{
				/* Block nicht sichtbar */
				if (y_r < t_ptr->z1 || y_r > t_ptr->z2)
					str_out(x, y, w, xoffset, lauf);
				else
				{
					int mode = 0;

					if (y_r == t_ptr->z1)
						mode |= BLKANF;
					if (y_r == t_ptr->z2)
						mode |= BLKEND;
					if (!mode)
						mode = BLKFULL;
					str_out_b(x, y, w, xoffset, lauf, mode, t_ptr->x1, t_ptr->x2);
				}
			}
		}
		else
		{
			for (i=min_col ; i<=max_col; y+=font_hcell,NEXT(lauf),i++)
				str_out(x,y,w,xoffset,lauf);
		}
	}

	/* Fenster hîher als Text lang ist -> Rest lîschen */
	if (y < max_y)
		fill_area(x, y, w, (max_y - y + 1), bg_color);
}

void bild_blkout(WINDOWP window, TEXTP t_ptr, long z1, long z2)
/* Alle Textzeilen zwischen z1 und z2 werden neu ausgegeben */
{
	int		i, x, y, w, xoffset;
	ZEILEP	lauf;
	int		max_col;
	long		lines, y_r;

	adjust_text(t_ptr);					/* Zeilenpuffer an exp_len anpassen */
	tab = t_ptr->loc_opt->tab;
	tab_size = t_ptr->loc_opt->tabsize;
	umbrechen = t_ptr->loc_opt->umbrechen;
	show_end = t_ptr->loc_opt->show_end;
	if (z1>z2)
	{
		lines = z1;
		z1 = z2;
		z2 = lines;
	}
	x		  = window->work.g_x;
	y 		  = window->work.g_y;
	w		  = window->work.g_w;
	xoffset = (int) window->doc.x;
	max_col = (int) min(window->w_height-1, t_ptr->text.lines-window->doc.y-1);
	y_r	  = window->doc.y;
	lauf = get_wline(t_ptr, y_r);

	if (t_ptr->block)
		for (i=0; i<=max_col; i++,y+=font_hcell,y_r++)
		{
			if (y_r>=z1 && y_r<=z2)
			{
				if (y_r<t_ptr->z1 || y_r>t_ptr->z2)
					str_out(x,y,w,xoffset,lauf);
				else
				{
					int mode = 0;

					if (y_r==t_ptr->z1) mode |= BLKANF;
					if (y_r==t_ptr->z2) mode |= BLKEND;
					if (!mode) mode = BLKFULL;
					str_out_b(x,y,w,xoffset,lauf,mode,t_ptr->x1,t_ptr->x2);
				}
			}
			NEXT(lauf);
		}
	else
		for (i=0; i<=max_col; i++,y+=font_hcell,y_r++)
		{
			if (y_r>=z1 && y_r<=z2)
				str_out(x,y,w,xoffset,lauf);
			NEXT(lauf);
		}
}


/***************************************************************************/

void head_out(WINDOWP window, TEXTP t_ptr)
{
	char	head_str[WINSTRLEN];
	int	len, head_len;

	if (t_ptr->info_str[0] != EOS)
	{
		strncpy(head_str, t_ptr->info_str, WINSTRLEN);
		head_str[WINSTRLEN] = EOS;
		head_len = (int) strlen(head_str);
	}
	else 
	{
		if (t_ptr->text.ending != binmode)
		{
			head_len = (int) strlen(rsc_string(HEADSTR));
			strcpy(head_str, rsc_string(HEADSTR));
			if (t_ptr->readonly)
				head_str[1] = '\x7F';
	
			switch (t_ptr->text.ending)
			{
				case tos :
					break;
				case unix :
					head_str[2] = 'U';
					break;
				case apple :
					head_str[2] = 'A';
					break;
				default:
					head_str[2] = '?';
			}

			ltoa(t_ptr->ypos+1, head_str + 8, 10);
			head_str[strlen(head_str)] = ' ';
			itoa(bild_pos(t_ptr->xpos,t_ptr->cursor_line,tab,tab_size)+1,head_str+18,10);
			head_str[strlen(head_str)] = ' ';
		}
		else
		{
			long	p;
			
			head_len = (int) strlen(rsc_string(BHEADSTR));
			strcpy(head_str, rsc_string(BHEADSTR));
			if (t_ptr->readonly)
				head_str[1] = '\x7F';
			p = t_ptr->ypos * t_ptr->text.max_line_len + t_ptr->xpos + 1;
			ltoa(p, head_str + 24, 10);
		}
	}
	len = window->work.g_w / gl_wchar;
	if (len < head_len)
		head_str[len] = EOS;
	set_winfo(window, head_str);
}

/***************************************************************************/
