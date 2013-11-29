/***************************************
 * MyTask                              *
 *              written by Thomas Much *
 ***************************************
 *   Dieses Programm ist Freeware!     *
 ***************************************
 *    Thomas Much, Gerwigstraže 46,    *
 * 76131 Karlsruhe, Fax (0721) 622821  *
 *         Thomas Much @ KA2           *
 *        thomas@snailshell.de         *
 ***************************************
 *    erstellt am:        16.02.1996   *
 *    letztes Update am:  02.10.1998   *
 ***************************************/

#include "start.h"

/*#include <aes.h>
#include <vdi.h>*/
#include <tos.h>
#include <av.h>
#include <portab.h>
#include <string.h>
#include <stddef.h>
#include <stdlib.h>
#include <ctype.h>
#include <stdio.h>
#include <time.h>
#include "sounds.h"
#include "global.h"
#include "option.h"
#include "przycisk.h"
#include "memdebug.h"

#define v_ftext	v_gtext


struct _redraw _redraw_;

extern GRECT       desk;

extern int prev_app_on_top, prev_win_on_top, prev_menu_on_top;
extern struct _calendar_ _calendar;



static struct 
	{
	OBJECT *icon;
	int pos_x, pos_y;
	}_icons_to_draw[100];
int how_many_icons_to_draw;
int how_many_buttons_to_draw;



extern STARTINF    startinf;
char text_time_line1[50], text_time_line2[50];


void mouse_on(void)
	{
  mt_graf_mouse(M_ON,NULL, (short*)&_GemParBlk.global[0]);
	}


void mouse_off(void)
	{
  mt_graf_mouse(M_OFF,NULL, (short*)&_GemParBlk.global[0]);
	}

/*
int rc_intersect(GRECT *r1, GRECT *r2)
	{
  int x,y,w,h;

  x = max(r2->g_x,r1->g_x);
  y = max(r2->g_y,r1->g_y);
  w = min(r2->g_x+r2->g_w,r1->g_x+r1->g_w);
  h = min(r2->g_y+r2->g_h,r1->g_y+r1->g_h);

  r2->g_x = x;
  r2->g_y = y;
  r2->g_w = w-x;
  r2->g_h = h-y;

  return (((w>x)&&(h>y)));
	}

void rc_copy (struct RECT *ps, struct RECT *pd)
{
  pd->x = ps->x;
  pd->y = ps->y;
  pd->w = ps->w;
  pd->h = ps->h;
} /* rc_copy */
*/

void xywh2rect (int x, int y, int w, int h, struct RECT *rect)
{
  rect->x = x;
  rect->y = y;
  rect->w = w;
  rect->h = h;
} /* xywh2rect */

void xywh2array  (int x, int y, int w, int h, int *array)
{
  *array++ = x;
  *array++ = y;
  *array++ = x + w - 1;
  *array   = y + h - 1;
} /* xywh2array */

void rect2array (struct RECT *rect, int *array)
{
  *array++ = rect->x;
  *array++ = rect->y;
  *array++ = rect->x + rect->w - 1;
  *array   = rect->y + rect->h - 1;
} /* rect2array */

void set_clip (int clipflag, struct RECT *size, struct RECT *size2)
	{
  struct RECT r;
  short xy [4];

  rc_copy ((GRECT*)size, (GRECT*)&r);                 /* Benutze definierte Gr”že */

  if (rc_intersect ((GRECT*)size2, (GRECT*)&r))         /* Nur auf Desktop zeichnen */
    rect2array (&r, (int*)xy);
  else
    xywh2array (0 ,0 ,0 ,0, (int*)xy);        /* Nichts zeichnen */

  vs_clip (MyTask.v_handle, (short)clipflag, xy);   /* Setze Rechteckausschnitt */
	}


short cdecl draw_menu_rect(PARMBLK *parmblock)
	{
	short xy[4];

	xy[0] = parmblock->pb_x;
	xy[3] = parmblock->pb_y + (parmblock->pb_h >> 1);
	xy[2] = xy[0] + parmblock->pb_w - 1;
	
	if (extmagxmenu)
		{
		xy[1] = xy[3];
		vsl_color(MyTask.v_handle, G_BLACK);
		v_pline(MyTask.v_handle,2,xy);
		}
	else
		{
		xy[1] = xy[3] - 1;
		vsf_color(MyTask.v_handle, G_BLACK);
		vr_recfl(MyTask.v_handle,xy);
		}
	return(OS_NORMAL);
	}


short cdecl draw_calendar_titel(PARMBLK *parmblock)
	{
	short xy[10], i,chw,chh,cw,ch;
	char *wochentagen = rs_tedinfo_calender[1].te_ptext;
	char name[4]={0};
	
	xy[0] = parmblock->pb_x;		xy[1] = parmblock->pb_y;
	xy[2] = parmblock->pb_x + parmblock->pb_w;		xy[3] = parmblock->pb_y + parmblock->pb_h;
	vs_clip(MyTask.v_handle, 1, xy);
	vst_font(MyTask.v_handle, 1);
	vst_height(MyTask.v_handle, 13, &chw, &chh, &cw, &ch);

	for(i=0; i<7; i++)
		{
		if(i==5)			/* Sobota?					*/
			vst_color(MyTask.v_handle, G_BLUE);
		else if(i==6)	/* Niedziela?				*/
			vst_color(MyTask.v_handle, G_RED);
		else					/* Kazdy inny dzien	*/
			vst_color(MyTask.v_handle, G_BLACK);
		strncpy(name, &wochentagen[4*i], 3);
		v_ftext(MyTask.v_handle, xy[0], xy[1]+14, name);
		xy[0] += 8*4;
		}
	vst_color(MyTask.v_handle, G_BLACK);

	vs_clip(MyTask.v_handle, 0, xy);
	return(OS_NORMAL);
	}



short cdecl draw_calendar(PARMBLK *parmblock)
	{
	short xy[10], i,j,chw,chh,cw,ch,xx;
	char *wochentagen;
	char name[4]={0};
	struct RECT    r, r2;

	xy[0] = parmblock->pb_x;		xy[1] = parmblock->pb_y;
	xy[2] = parmblock->pb_x + parmblock->pb_w;		xy[3] = parmblock->pb_y + parmblock->pb_h;
	xywh2rect (parmblock->pb_xc, parmblock->pb_yc, parmblock->pb_wc, parmblock->pb_hc, &r);
	xywh2rect (parmblock->pb_x, parmblock->pb_y, parmblock->pb_w, parmblock->pb_h, &r2);
	set_clip (1, &r, (struct RECT*)&desk);

	vst_font(MyTask.v_handle, 1);
	vst_height(MyTask.v_handle, 12, &chw, &chh, &cw, &ch);

	for(xx=0,j=0; j<5; j++)
		{
		wochentagen = rs_tedinfo_calender[j+2].te_ptext;
		for(i=0; i<7; i++)
			{
			strncpy(name, &wochentagen[4*i], 3);
			if(name[1]!=' ')					/* Jezeli jest puste pole, to nie liczyc kolejnego dnia	*/
				xx++;										/* Istotne tylko do momentu pokazania 1. dnia miesiaca.	*/

			if(i==5)			/* Sobota?		*/
				vst_color(MyTask.v_handle, G_BLUE);
			else if(i==6)	/* Niedziela?	*/
				vst_color(MyTask.v_handle, G_RED);
			else if(_calendar.cal_m==_calendar.act_m && xx==_calendar.act_d)		/* Dzisiaj?	*/
				{
				xy[0] += 8;
				xy[2] = xy[0] + 2*8;
				xy[3] = xy[1] + 16;
				v_bar(MyTask.v_handle, xy);
				xy[0] -= 8;
				vst_color(MyTask.v_handle, G_GREEN);
				}
			else					/* Kazdy inny dzien	*/
				vst_color(MyTask.v_handle, G_BLACK);

			v_ftext(MyTask.v_handle, xy[0], xy[1]+14, name);
			xy[0] += (8*4);
			}
		xy[1] += 16;
		xy[0] = parmblock->pb_x;
		}
	vst_color(MyTask.v_handle, G_BLACK);

	set_clip (0, &r, (struct RECT*)&desk);
	return(OS_NORMAL);
	}



short cdecl draw_spec1(PARMBLK *parmblock)
	{
	short xy[10];
	
	xy[0] = parmblock->pb_x;		xy[1] = parmblock->pb_y;
	xy[2] = parmblock->pb_x + parmblock->pb_w;		xy[3] = parmblock->pb_y + parmblock->pb_h;
	vs_clip(MyTask.v_handle, 1, xy);

	vs_clip(MyTask.v_handle, 0, xy);
	return(OS_NORMAL);
	}


short cdecl draw_bigbutton(PARMBLK *parmblock)
	{
	parmblock = parmblock;
	return(OS_NORMAL);
	}




LOCAL WORD xadd_cicon (CICONBLK *cicnblk, OBJECT *obj, WORD nub);
LOCAL VOID xfix_cicon (int handle, UWORD *col_data, LONG len, WORD old_planes, WORD new_planes, MFDB *s);
WORD draw_icon (int handle, OBJECT *icon);

short cdecl draw_button(PARMBLK *parmblock)
	{
	char *name;
	short xy[16], font_id, offset_x=0, effects=0;
	struct RECT    r, r2;
	OBJECT *tmp=NULL;

	if(stic && options.stic_app_button)
		{
		if((tmp = _applications_[parmblock->pb_parm].icon)!=NULL)
			offset_x = 14;
		}

	xy[0] = parmblock->pb_x;		xy[1] = parmblock->pb_y;
	xy[2] = parmblock->pb_x + parmblock->pb_w;		xy[3] = parmblock->pb_y + parmblock->pb_h;
	xywh2rect (parmblock->pb_xc, parmblock->pb_yc, parmblock->pb_wc, parmblock->pb_hc, &r);
	xywh2rect (parmblock->pb_x, parmblock->pb_y, parmblock->pb_w, parmblock->pb_h, &r2);
	set_clip (1, &r, (struct RECT*)&desk);

	if(strlen(_applications_[parmblock->pb_parm].name)>1)
		{
		xy[0] = xy[0];		xy[1] = xy[1];
		xy[2] = xy[0];		xy[3] = xy[1] + parmblock->pb_h-4;
		xy[4] = xy[0] + 4;	xy[5] = xy[3] + 4;
		xy[6] = xy[0] + parmblock->pb_w;	xy[7] = xy[5];
		xy[8] = xy[6];		xy[9] = xy[1]+4;
		xy[10] = xy[6]-4;		xy[11] = xy[1];
		xy[12] = xy[0];		xy[13] = xy[1];
		vsl_color(MyTask.v_handle, G_BLACK);
		vsf_color(MyTask.v_handle, G_BLACK);
		if(_applications_[parmblock->pb_parm].active==1)
			vsf_color(MyTask.v_handle, G_WHITE);
		if(_applications_[parmblock->pb_parm].check==2)
			vsf_color(MyTask.v_handle, options.frezzy_back_color);
		if(_applications_[parmblock->pb_parm].check==3)
			vsf_color(MyTask.v_handle, options.hidden_back_color);

		vsf_interior(MyTask.v_handle, FIS_PATTERN);
		vsf_style(MyTask.v_handle, 8);
		{
		int tex, col;
		if(_applications_[parmblock->pb_parm].type&APP_SYSTEM)																/* Zmiana koloru  przycisku	*/
			{
			tex = options.tex_sys;
			col = options.col_b_sys;
			}
		if(_applications_[parmblock->pb_parm].type&APP_APPLICATION)
			{
			tex = options.tex_app;
			col = options.col_b_app;
			}
		if(_applications_[parmblock->pb_parm].type&APP_ACCESSORY)
			{
			tex = options.tex_acc;
			col = options.col_b_acc;
			}
		if(_applications_[parmblock->pb_parm].type&APP_SHELL)
			{
			tex = options.tex_shell;
			col = options.col_b_shell;
			}
		if(tex==1 && _applications_[parmblock->pb_parm].active!=1)
			{
			vsf_color(MyTask.v_handle, G_LWHITE);
			vsf_interior(MyTask.v_handle, FIS_SOLID);
			}	
		else if(_applications_[parmblock->pb_parm].active!=1)
			{
			vsf_style(MyTask.v_handle, tex);
			vsf_color(MyTask.v_handle, col);
			}
		if(_applications_[parmblock->pb_parm].check==2)
			vsf_color(MyTask.v_handle, options.frezzy_back_color);
		if(_applications_[parmblock->pb_parm].check==3)
			vsf_color(MyTask.v_handle, options.hidden_back_color);
		}
		v_fillarea(MyTask.v_handle, 7, xy);
		v_pline(MyTask.v_handle, 7, xy);
		vsf_interior(MyTask.v_handle, FIS_SOLID);

		xy[2]++;
		xy[5]--;
		xy[6]--;	xy[7]--;
		xy[8]--;
		if(bigbutton[parmblock->pb_obj].ob_state&OS_SELECTED || _applications_[parmblock->pb_parm].active==1)
			vsl_color(MyTask.v_handle, G_WHITE);
		else
			vsl_color(MyTask.v_handle, G_LBLACK);
		v_pline(MyTask.v_handle, 4, &xy[2]);
		xy[11]++;
		xy[12]++; xy[13]++;
		xy[14] = xy[2];	xy[15]=xy[3];
		if(bigbutton[parmblock->pb_obj].ob_state&OS_SELECTED || _applications_[parmblock->pb_parm].active==1)
			vsl_color(MyTask.v_handle, G_LBLACK);
		else
			vsl_color(MyTask.v_handle, G_WHITE);
		v_pline(MyTask.v_handle, 4, &xy[8]);

		vsl_color(MyTask.v_handle, G_BLACK);
		vsf_color(MyTask.v_handle, G_BLACK);

		if(_applications_[parmblock->pb_parm].check==2)
			effects = options.frezzy_effect;
		if(_applications_[parmblock->pb_parm].check==3)
			effects = options.hidden_effect;

		if(_applications_[parmblock->pb_parm].type&1)																/* Zmiana koloru  przycisku	*/
			vst_color(MyTask.v_handle, options.col_sys);
		if(_applications_[parmblock->pb_parm].type&2)
			vst_color(MyTask.v_handle, options.col_app);
		if(_applications_[parmblock->pb_parm].type&4)
			vst_color(MyTask.v_handle, options.col_acc);
		if(_applications_[parmblock->pb_parm].type&8)
			vst_color(MyTask.v_handle, options.col_shell);
		if(_applications_[parmblock->pb_parm].button_color!=-1)
			vst_color(MyTask.v_handle, _applications_[parmblock->pb_parm].button_color);
		if(_applications_[parmblock->pb_parm].check==2)
			vst_color(MyTask.v_handle, options.frezzy_txt_color);
		if(_applications_[parmblock->pb_parm].check==3)
			vst_color(MyTask.v_handle, options.hidden_txt_color);

		if(strlen(_applications_[parmblock->pb_parm].alias))
			name = _applications_[parmblock->pb_parm].alias;
		else
			name = _applications_[parmblock->pb_parm].name;
		name = &name[strspn(name, " ")];
		trim_end(name);
		if(_applications_[parmblock->pb_parm].name_len!=0)
			name[_applications_[parmblock->pb_parm].name_len] = 0;
		vst_load_fonts(MyTask.v_handle, 0);
		if(startinf.default_font_id!=0 && _applications_[parmblock->pb_parm].font_id<=0)
			font_id = startinf.default_font_id;
		else if(_applications_[parmblock->pb_parm].font_id!=0)
			font_id = _applications_[parmblock->pb_parm].font_id;
		else
			font_id = 1;

		if(_applications_[parmblock->pb_parm].font_height > startinf.font_height)
			_applications_[parmblock->pb_parm].font_height = startinf.font_height;
		if(_applications_[parmblock->pb_parm].font_height < 4)
			_applications_[parmblock->pb_parm].font_height = startinf.font_height;

		if(options.stic_app_button<2 || !tmp)
			{
			int *h = &startinf.font_height;
			if(_applications_[parmblock->pb_parm].font_height!=0)
				h = &_applications_[parmblock->pb_parm].font_height;
			Set_font(font_id, h, effects);
			v_ftext(MyTask.v_handle, xy[0]+8+offset_x, xy[1]+16, name);
			vst_font(MyTask.v_handle, 1);
			}

		vst_color(MyTask.v_handle, G_BLACK);
		vst_effects(MyTask.v_handle, 0);

		if(stic && options.stic_app_button)
			{
			_icons_to_draw[how_many_icons_to_draw].icon = tmp;
			_icons_to_draw[how_many_icons_to_draw].pos_x = xy[0];
			_icons_to_draw[how_many_icons_to_draw].pos_y = xy[1]; 
			how_many_icons_to_draw++;
			}
		}

	set_clip (0, &r, (struct RECT*)&desk);

	vst_unload_fonts(MyTask.v_handle, 0);
	return(OS_NORMAL);
	}




short cdecl draw_hide_mytask(PARMBLK *parmblock)
	{
	short xy[12];
	int chh=8;
	struct RECT    r, r2;

	xy[0] = parmblock->pb_x;											xy[1] = parmblock->pb_y;
	xy[2] = parmblock->pb_x + parmblock->pb_w;		xy[3] = parmblock->pb_y + parmblock->pb_h;
	xywh2rect (parmblock->pb_xc, parmblock->pb_yc, parmblock->pb_wc, parmblock->pb_hc, &r);
	xywh2rect (parmblock->pb_x, parmblock->pb_y, parmblock->pb_w, parmblock->pb_h, &r2);
	set_clip (1, &r, (struct RECT*)&desk);

	if(!(bigbutton[parmblock->pb_obj].ob_state & OS_SELECTED))
		{
		xy[0] = parmblock->pb_x;						xy[1] = parmblock->pb_y+1;
		xy[2] = xy[0] + parmblock->pb_w;		xy[3] = xy[1] + 1 + parmblock->pb_h/2;
		xy[4] = xy[0];											xy[5] = xy[1] + parmblock->pb_h+1;
		xy[6] = xy[0];											xy[7] = xy[1];
		vsf_color(MyTask.v_handle, G_LBLACK);
		v_fillarea(MyTask.v_handle, 4, xy);

		xy[0] = parmblock->pb_x;						xy[1] = parmblock->pb_y;
		xy[2] = xy[0] + parmblock->pb_w;		xy[3] = xy[1] + parmblock->pb_h/2;
		xy[4] = xy[0];											xy[5] = xy[1] + parmblock->pb_h;
		vsl_color(MyTask.v_handle, G_BLACK);
		v_pline(MyTask.v_handle, 3, xy);
		}
	else
		{
/* "Przycisk"	*/
		xy[0] = xy[0];		xy[1] = xy[1];
		xy[2] = xy[0];		xy[3] = xy[1] + parmblock->pb_h;
		xy[4] = xy[0] + parmblock->pb_w;	xy[5] = xy[3];
		xy[6] = xy[4];		xy[7] = xy[1];
		xy[8] = xy[0];		xy[9] = xy[1];
		xy[10] = xy[2];		xy[11] = xy[3];
		vsl_color(MyTask.v_handle, G_LBLACK);
		vsf_interior(MyTask.v_handle, FIS_PATTERN);
		vsf_perimeter(MyTask.v_handle, 1);

		vsf_color(MyTask.v_handle, G_LWHITE);
		v_fillarea(MyTask.v_handle, 5, xy);
		vsl_color(MyTask.v_handle, G_LBLACK);
		v_pline(MyTask.v_handle, 5, xy);
		xy[2]++;	xy[3]--;
		xy[4]--;	xy[5]--;
		xy[6]--;	xy[7]++;
		vsl_color(MyTask.v_handle, G_WHITE);
		v_pline(MyTask.v_handle, 3, &xy[2]);
		xy[6]--;
		xy[8]++;	xy[9]++;
		xy[10]++;	xy[11]--;
		vsl_color(MyTask.v_handle, G_BLACK);
		v_pline(MyTask.v_handle, 3, &xy[6]);
		vsl_color(MyTask.v_handle, G_BLACK);

/* Strzalka	*/
		xy[0] = parmblock->pb_x + parmblock->pb_w-2;		xy[1] = parmblock->pb_y;
		xy[2] = xy[0] - parmblock->pb_w + 2;					xy[3] = xy[1] + parmblock->pb_h/2;
		xy[4] = xy[0];																xy[5] = xy[1] + parmblock->pb_h;
		xy[6] = xy[0];																xy[7] = xy[1];
		vsf_color(MyTask.v_handle, G_LBLACK);
		v_fillarea(MyTask.v_handle, 4, xy);

		xy[0] = parmblock->pb_x + parmblock->pb_w-2;		xy[1] = parmblock->pb_y;
		xy[2] = parmblock->pb_x + 2;									xy[3] = xy[1] + parmblock->pb_h/2;
		xy[4] = xy[0];																xy[5] = xy[1] + parmblock->pb_h;
		vsl_color(MyTask.v_handle, G_BLACK);
		v_pline(MyTask.v_handle, 3, xy);
		}

	set_clip (0, &r, (struct RECT*)&desk);
	return(OS_NORMAL);
	}


short cdecl draw_timer(PARMBLK *parmblock)
	{
	short xy[12], key;
	int chh=8;
	struct RECT    r, r2;
	
	xy[0] = parmblock->pb_x;		xy[1] = parmblock->pb_y;
	xy[2] = parmblock->pb_x + parmblock->pb_w;		xy[3] = parmblock->pb_y + parmblock->pb_h;
	xywh2rect (parmblock->pb_xc, parmblock->pb_yc, parmblock->pb_wc, parmblock->pb_hc, &r);
	xywh2rect (parmblock->pb_x, parmblock->pb_y, parmblock->pb_w, parmblock->pb_h, &r2);
	set_clip (1, &r, (struct RECT*)&desk);
	key = (int)Kbshift(-1);

	xy[0] = xy[0];		xy[1] = xy[1];
	xy[2] = xy[0];		xy[3] = xy[1] + parmblock->pb_h;
	xy[4] = xy[0] + parmblock->pb_w;	xy[5] = xy[3];
	xy[6] = xy[4];		xy[7] = xy[1];
	xy[8] = xy[0];		xy[9] = xy[1];
	xy[10] = xy[2];		xy[11] = xy[3];
	vsl_color(MyTask.v_handle, G_BLACK);
	vsf_interior(MyTask.v_handle, FIS_PATTERN);
	vsf_perimeter(MyTask.v_handle, 1);

	if(key&16)
		{
		vsf_style(MyTask.v_handle, options.tex_caps_on);
		vsf_color(MyTask.v_handle, options.col_caps_on);
		vst_color(MyTask.v_handle, options.col_t_caps_on);
		}
	else
		{
		vsf_style(MyTask.v_handle, options.tex_caps_off);
		vsf_color(MyTask.v_handle, options.col_caps_off);
		vst_color(MyTask.v_handle, options.col_t_caps_off);
		}
	v_fillarea(MyTask.v_handle, 5, xy);
	vsl_color(MyTask.v_handle, G_LBLACK);
	v_pline(MyTask.v_handle, 5, xy);
	xy[2]++;	xy[3]--;
	xy[4]--;	xy[5]--;
	xy[6]--;	xy[7]++;
	vsl_color(MyTask.v_handle, G_WHITE);
	v_pline(MyTask.v_handle, 3, &xy[2]);
	xy[6]--;
	xy[8]++;	xy[9]++;
	xy[10]++;	xy[11]--;
	vsl_color(MyTask.v_handle, G_BLACK);
	v_pline(MyTask.v_handle, 3, &xy[6]);
	vsl_color(MyTask.v_handle, G_BLACK);
	vsf_interior(MyTask.v_handle, FIS_SOLID);

	Set_font(startinf.timer_font_id, &chh, 0);
	v_ftext(MyTask.v_handle, xy[0]+8, xy[1]+19, text_time_line2);
	v_ftext(MyTask.v_handle, xy[0]+8, xy[1]+10, text_time_line1);
	vst_font(MyTask.v_handle, 1);
	vst_color(MyTask.v_handle, G_BLACK);
	vsf_color(MyTask.v_handle, G_BLACK);

	vst_unload_fonts(MyTask.v_handle, 0);
	set_clip (0, &r, (struct RECT*)&desk);
	return(OS_NORMAL);
	}


short cdecl draw_separator(PARMBLK *parmblock)
	{
	short xy[10];
	struct RECT r, r2;

	if((parmblock->pb_obj==SEPARATOR_3 || parmblock->pb_obj==TIME_SEPARATOR) && icons_sys.how_many==0)
		return(OS_NORMAL);					/* Dwa separatory od SYSTEM TRAY sa rysowane jezeli istnieja jakies ikonki. W przeciwnym razie nic nie jest rysowane	*/
	if((parmblock->pb_obj==SEPARATOR_1 || parmblock->pb_obj==SEPARATOR_2) && icons_app.how_many==0)
		return(OS_NORMAL);					/* Dwa separatory od APP TRAY sa rysowane jezeli istnieja jakies ikonki. W przeciwnym razie nic nie jest rysowane	*/

	xy[0] = parmblock->pb_x;		xy[1] = parmblock->pb_y;
	xy[2] = parmblock->pb_x + parmblock->pb_w;		xy[3] = parmblock->pb_y + parmblock->pb_h;
	xywh2rect (parmblock->pb_xc, parmblock->pb_yc, parmblock->pb_wc, parmblock->pb_hc, &r);
	xywh2rect (parmblock->pb_x, parmblock->pb_y, parmblock->pb_w, parmblock->pb_h, &r2);
	set_clip (1, &r, (struct RECT*)&desk);
	
	xy[0] = parmblock->pb_x + 1;		xy[1] = parmblock->pb_y + 1;
	xy[2] = parmblock->pb_x + 2;		xy[3] = parmblock->pb_y + 1 + parmblock->pb_h;
	vsf_color(MyTask.v_handle, G_LBLACK);
	v_bar(MyTask.v_handle, xy);

	xy[0] = parmblock->pb_x;				xy[1] = parmblock->pb_y - 1;
	xy[2] = parmblock->pb_x+1;			xy[3] = parmblock->pb_y + parmblock->pb_h - 1;
	vsf_color(MyTask.v_handle, G_WHITE);
	v_bar(MyTask.v_handle, xy);
	vsf_color(MyTask.v_handle, G_BLACK);

	set_clip (0, &r, (struct RECT*)&desk);

	return(OS_NORMAL);
	}


extern OBJECT icon[];
extern CICON rs_cicon[];

short cdecl draw_spec2(PARMBLK *parmblock)
	{
	int xy[4];
	int i, j, of_x=0;
	
	xy[0] = parmblock->pb_x;		xy[1] = parmblock->pb_y;
	xy[2] = parmblock->pb_x + parmblock->pb_w;		xy[3] = parmblock->pb_y + parmblock->pb_h;

	for(i=0; i<_applications_->no; i++)
		{
		if(_applications_[i].il_ikonek>0)
			{
			for(j=0; j<_applications_[i].il_ikonek; j++)
				{
				memcpy(rs_cicon->col_data, _applications_[i].ikonki[j].data, 128);
				memcpy(rs_cicon->col_mask, _applications_[i].ikonki[j].mask, 32);
				icon[1].ob_x = of_x + xy[0];		icon[1].ob_y = xy[1];
				redraw_obj(&icon[1], icon[1].ob_x, icon[1].ob_y, icon[1].ob_width, icon[1].ob_height);
				_applications_[i].ikonki[j].pos_x = of_x + parmblock->pb_x;
				of_x += 18;
				}
			}
		}
	vsl_color(MyTask.v_handle, G_BLACK);
	return(OS_NORMAL);
	}


void redraw_obj(OBJECT *obj, int x, int y, int w, int h)
	{
	GRECT work,dirty,box;

	if (MyTask.whandle<1) return;
	
	mt_wind_update(BEG_UPDATE, (short*)&_GemParBlk.global[0]);
	mt_wind_get(MyTask.whandle,WF_WORKXYWH,&work.g_x,&work.g_y,&work.g_w,&work.g_h, (short*)&_GemParBlk.global[0]);
	bigbutton[ROOT].ob_x = work.g_x;
	bigbutton[ROOT].ob_y = work.g_y;

	if (rc_intersect(&desk,&work))
		{
		dirty.g_x = x;
		dirty.g_y = y;
		dirty.g_w = w;
		dirty.g_h = h;

		if (rc_intersect(&dirty,&work))
			{
			mouse_off();

			mt_wind_get(MyTask.whandle,WF_FIRSTXYWH,&box.g_x,&box.g_y,&box.g_w,&box.g_h, (short*)&_GemParBlk.global[0]);

			while ((box.g_w>0)&&(box.g_h>0))
	      {
      	if (rc_intersect(&work,&box))
      		mt_objc_draw(obj, 0,MAX_DEPTH,box.g_x,box.g_y,box.g_w,box.g_h, (short*)&_GemParBlk.global[0]);

      	mt_wind_get(MyTask.whandle,WF_NEXTXYWH,&box.g_x,&box.g_y,&box.g_w,&box.g_h, (short*)&_GemParBlk.global[0]);
      	}
      
      mouse_on();
			}
		}

	mt_wind_update(END_UPDATE, (short*)&_GemParBlk.global[0]);
	}

void redraw_dial(OBJECT *tree, int wh, int obj, int x, int y, int w, int h)
	{
	int i;
	GRECT work,box;

	if (wh<1)
		return;
	x=x;y=y;w=w;h=h;

	mt_wind_update(BEG_UPDATE, (short*)&_GemParBlk.global[0]);
	mt_wind_get(wh,WF_WORKXYWH, &work.g_x, &work.g_y, &work.g_w, &work.g_h, (short*)&_GemParBlk.global[0]);
	tree[ROOT].ob_x = work.g_x;
	tree[ROOT].ob_y = work.g_y;

	if (rc_intersect(&desk,&work))
		{
		mouse_off();

		mt_wind_get(wh,WF_FIRSTXYWH,&box.g_x,&box.g_y,&box.g_w,&box.g_h, (short*)&_GemParBlk.global[0]);

		while ((box.g_w>0)&&(box.g_h>0))
			{
			if (rc_intersect(&work,&box))
				{
				if(obj==0)
					{
					mt_objc_draw(tree,0,0,box.g_x,box.g_y,box.g_w,box.g_h, (short*)&_GemParBlk.global[0]);
					for(i=1; i!=0;)
						{
						mt_objc_draw(tree,i,MAX_DEPTH,box.g_x,box.g_y,box.g_w,box.g_h, (short*)&_GemParBlk.global[0]);
						i = tree[i].ob_next;
						}
					}
				else
					mt_objc_draw(tree,obj,MAX_DEPTH,box.g_x,box.g_y,box.g_w,box.g_h, (short*)&_GemParBlk.global[0]);
				}
			mt_wind_get(wh,WF_NEXTXYWH,&box.g_x,&box.g_y,&box.g_w,&box.g_h, (short*)&_GemParBlk.global[0]);
     	}
      
		mouse_on();
		}

	mt_wind_update(END_UPDATE, (short*)&_GemParBlk.global[0]);
	}



void redraw_cal(int obj, int x, int y, int w, int h)
	{
	GRECT work,box;

	if (MyTask.wh_calendar<1)
		return;
	x=x;y=y;w=w;h=h;

	mt_wind_update(BEG_UPDATE, (short*)&_GemParBlk.global[0]);
	mt_wind_get(MyTask.wh_calendar,WF_WORKXYWH, &work.g_x, &work.g_y, &work.g_w, &work.g_h, (short*)&_GemParBlk.global[0]);
	calender[ROOT].ob_x = work.g_x;
	calender[ROOT].ob_y = work.g_y;

	if (rc_intersect(&desk,&work))
		{
		mouse_off();

		mt_wind_get(MyTask.wh_calendar,WF_FIRSTXYWH,&box.g_x,&box.g_y,&box.g_w,&box.g_h, (short*)&_GemParBlk.global[0]);

		while ((box.g_w>0)&&(box.g_h>0))
			{
			if (rc_intersect(&work,&box))
				mt_objc_draw(calender,obj,MAX_DEPTH,box.g_x,box.g_y,box.g_w,box.g_h, (short*)&_GemParBlk.global[0]);
			mt_wind_get(MyTask.wh_calendar,WF_NEXTXYWH,&box.g_x,&box.g_y,&box.g_w,&box.g_h, (short*)&_GemParBlk.global[0]);
     	}
      
		mouse_on();
		}

	mt_wind_update(END_UPDATE, (short*)&_GemParBlk.global[0]);
	}


void redraw(int obj, int x, int y, int w, int h, char *wer)
	{
	int i;
	GRECT work,dirty,box;

	if(options.draw_obj==1)
		{
/*		if(wer!=NULL)
			printf("Redraw von: %s\r\n", wer);
		else
			printf("Redraw von: unbekannt\r\n");
		while((Kbshift(-1)&1)==0)
			;	*/
		}

	if (MyTask.whandle<1)
		return;

	mt_wind_update(BEG_UPDATE, (short*)&_GemParBlk.global[0]);
	mt_wind_get(MyTask.whandle, WF_WORKXYWH, &work.g_x, &work.g_y, &work.g_w, &work.g_h, (short*)&_GemParBlk.global[0]);
/*	bigbutton[ROOT].ob_x = work.g_x;
	bigbutton[ROOT].ob_y = work.g_y;	*/

	if (rc_intersect(&desk,&work))
		{
		dirty.g_x = x;		dirty.g_y = y;
		dirty.g_w = w;		dirty.g_h = h;

		if (rc_intersect(&dirty,&work))
			{
			mouse_off();

			mt_wind_get(MyTask.whandle,WF_FIRSTXYWH,&box.g_x,&box.g_y,&box.g_w,&box.g_h, (short*)&_GemParBlk.global[0]);
			how_many_icons_to_draw = 0;

			while ((box.g_w>0)&&(box.g_h>0))				/* Przerysowywanie pojedynczych obiektow	*/
	      {
      	if (rc_intersect(&work,&box))
      		mt_objc_draw(bigbutton,obj,MAX_DEPTH,box.g_x,box.g_y,box.g_w,box.g_h, (short*)&_GemParBlk.global[0]);

				if(options.draw_obj==1)
					{
					short pxy[10];
					pxy[0] = box.g_x;						pxy[1] = box.g_y;
					pxy[2] = pxy[0] + box.g_w;	pxy[3] = pxy[1];
					pxy[4] = pxy[2];						pxy[5] = pxy[1] + box.g_h;
					pxy[6] = pxy[0];						pxy[7] = pxy[5];
					pxy[8] = pxy[0];						pxy[9] = pxy[1];
					vsl_color(MyTask.v_handle, G_RED);
					v_pline(MyTask.v_handle, 5, pxy);
					mt_evnt_timer(1000,(short*)&_GemParBlk.global[0]);
					vsl_color(MyTask.v_handle, G_LWHITE);
					v_pline(MyTask.v_handle, 5, pxy);
					}

      	mt_wind_get(MyTask.whandle, WF_NEXTXYWH, &box.g_x, &box.g_y, &box.g_w, &box.g_h, (short*)&_GemParBlk.global[0]);
      	}

			mt_wind_get(MyTask.whandle,WF_FIRSTXYWH,&box.g_x,&box.g_y,&box.g_w,&box.g_h, (short*)&_GemParBlk.global[0]);
			while ((box.g_w>0)&&(box.g_h>0))						/* Przerysowywanie ikonek aplikacji		*/
	      {
  	    for(i=0; i<how_many_icons_to_draw; i++)
	      	{
  	   		if(_icons_to_draw[i].icon)
	    	 		{
    	 			OBJECT *icon = _icons_to_draw[i].icon;
  	   			int o_x=icon->ob_x, o_y=icon->ob_y;
		    	 	icon->ob_x = _icons_to_draw[i].pos_x - icon->ob_spec.iconblk->ib_xicon + 4;
	    	  	icon->ob_y = _icons_to_draw[i].pos_y - icon->ob_spec.iconblk->ib_yicon + 2;
  		   		if (rc_intersect(&work,&box))
  		   			{
  		   			int tmpa=icon->ob_spec.iconblk->ib_htext, tmpb=icon->ob_spec.iconblk->ib_wtext;
  		   			icon->ob_spec.iconblk->ib_htext = 0;
  		   			icon->ob_spec.iconblk->ib_wtext = 0;
	    		  	mt_objc_draw(icon, 0, 1, box.g_x, box.g_y, box.g_w, box.g_h, (short*)&_GemParBlk.global[0]);
  		   			icon->ob_spec.iconblk->ib_htext = tmpa;
  		   			icon->ob_spec.iconblk->ib_wtext = tmpb;
	    		  	}
    		  	icon->ob_x = o_x;	icon->ob_y = o_y;
  	  	  	}
   	  		}
      	mt_wind_get(MyTask.whandle,WF_NEXTXYWH,&box.g_x,&box.g_y,&box.g_w,&box.g_h, (short*)&_GemParBlk.global[0]);
    	  }

      mouse_on();
			}
		}
	mt_wind_update(END_UPDATE, (short*)&_GemParBlk.global[0]);
	wer=wer;
	}
