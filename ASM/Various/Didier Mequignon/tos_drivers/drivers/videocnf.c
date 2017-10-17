/* TOS4.04 Video Modes for the Radeon board
 * Didier Mequignon 2009-2010, e-mail: aniplay@wanadoo.fr
 *
 * This file is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include "config.h"
#include <mint/osbind.h>
#include <mint/falcon.h>
#include <mint/sysvars.h>
#include <string.h>
#define MFDB MFDBX
#include "fb.h"
#include "radeon/radeonfb.h"
#include "lynx/smi.h"
#undef MFDB
#include "gemform.h"
#include "ct60.h"

#ifndef Vsetscreen
#ifdef VsetScreen
#define Vsetscreen VsetScreen
#else
#warning Bad falcon.h
#endif
#endif

#ifndef Vsetmode
#ifdef VsetMode
#define Vsetmode VsetMode
#else
#warning Bad falcon.h
#endif
#endif

#ifndef Validmode
#define Validmode(mode) (short)trap_14_ww((short)95,(short)(mode))
#endif

/* objects */
#define VIDEOBOX 0
#define VIDEOTEXT 1
#define VIDEOBCOUL 2
#define VIDEOBOXS 3
#define VIDEOCHOIX1 4
#define VIDEOCHOIX2 5
#define VIDEOCHOIX3 6
#define VIDEOCHOIX4 7
#define VIDEOCHOIX5 8
#define VIDEOCHOIX6 9
#define VIDEOBHAUT 10
#define VIDEOBOXSLIDER 11
#define VIDEOSLIDER 12
#define VIDEOBBAS 13
#define VIDEOLOGO 14
#define VIDEOINFO 15
#define VIDEOBCHANGE 16
#define VIDEOBANNULE 17
#define VIDEOBTEST 18
#define VIDEOBMODE 19

#define VIDBASE 0
#define VID2 1
#define VID4 2
#define VID16 3
#define VID256 4
#define VID65K 5
#define VID16M 6

#define MODBASE 0
#define MODXBIOS 1
#define MODVESA 2
#define MODRADEON 3
#define MODMON1 4

char *rs_strings_fr[] = {
	" LARGEUR HAUTEUR INFO             COULEURS","","",
	"65536",
	"AAAAAAAAAAAAAAAAAAAAAA","","",
	"BBBBBBBBBBBBBBBBBBBBBB","","",
	"CCCCCCCCCCCCCCCCCCCCCC","","",
	"DDDDDDDDDDDDDDDDDDDDDD","","",
	"EEEEEEEEEEEEEEEEEEEEEE","","",
	"FFFFFFFFFFFFFFFFFFFFFF","","",    
	"00000000 octets 000 Hz 000 MHz",
	"Change",
	"Annule",
	"Test",
	"XBIOS"
};
	
char *rs_strings_en[] = {
	" WIDTH   HIGHT   INFO             COLORS","","",
	"65536",
	"AAAAAAAAAAAAAAAAAAAAAA","","",
	"BBBBBBBBBBBBBBBBBBBBBB","","",
	"CCCCCCCCCCCCCCCCCCCCCC","","",
	"DDDDDDDDDDDDDDDDDDDDDD","","",
	"EEEEEEEEEEEEEEEEEEEEEE","","",
	"FFFFFFFFFFFFFFFFFFFFFF","","",    
	"00000000 bytes  000 Hz 000 MHz",
	"Change",
	"Cancel",
	"Test",
	"XBIOS"
};
	
char *rs_strings_colors[] = { "  2   ","  4   ","  16  ","  256 ","  65K ","  16M  " };
char *rs_strings_modes[] = { "  XBIOS  ","  VESA   ","  DRIVER ","  MON.1  " };
char *strings_modes[] = { "XBIOS","VESA","DRIVER","MON.1" };
	
unsigned short image_logo[] = 
{
	0x0000,0x0000,
	0x1fff,0xfff0,
	0x2000,0x0008,
	0x2fff,0xffe8,
	0x2800,0x0028,
	0x2801,0x0028,	
	0x2803,0x8028,
	0x2807,0xc028,
	0x2881,0x0228,
	0x2981,0x0328,
	0x2bff,0xffa8,
	0x2981,0x0328,
	0x2881,0x0228,
	0x2807,0xc028,
	0x2803,0x8028,
	0x2801,0x0028,
	0x2800,0x0028,
	0x2fff,0xffe8,
	0x2000,0x0008,
	0x2000,0x0008,
	0x1ff0,0x1ff0,
	0x001f,0xf000,
	0x03ff,0xff80,
	0x07ff,0xffc0
};

BITBLK rs_bitblk[] =
{
	{ (short*)image_logo,4,24,0,0,4 }
};

TEDINFO rs_tedinfo_rom[] =
{
	{ (char *)0L,(char *)1L,(char *)2L,SMALL,0,2,0x1100,0,0,43,1 },
	{ (char *)4L,(char *)5L,(char *)6L,IBM,0,0,0x1180,0,0,23,1 },
	{ (char *)7L,(char *)8L,(char *)9L,IBM,0,0,0x1180,0,0,23,1 },
	{ (char *)10L,(char *)11L,(char *)12L,IBM,0,0,0x1180,0,0,23,1 },
	{ (char *)13L,(char *)14L,(char *)15L,IBM,0,0,0x1180,0,0,23,1 },
	{ (char *)16L,(char *)17L,(char *)18L,IBM,0,0,0x1180,0,0,23,1 },
	{ (char *)19L,(char *)20L,(char *)21L,IBM,0,0,0x1180,0,0,23,1 }
};

OBJECT rs_object_rom[] =
{
	{ -1,1,19,G_BOX,FL3DBAK,OUTLINED,{0x21100L},0,0,34,13 },
	{ 2,-1,-1,G_TEXT,FL3DBAK,NORMAL,{0L},1,1,32,1 },
	{ 3,-1,-1,G_BUTTON,TOUCHEXIT,SHADOWED,{3L},27,2,5,1 },										/* popup colors */
	{ 4,-1,-1,G_BOX,NONE,NORMAL,{0xff1100L},2,2,22,6 },
	{ 5,-1,-1,G_TEXT,NONE,NORMAL,{1L},2,2,22,1 },
	{ 6,-1,-1,G_TEXT,NONE,NORMAL,{2L},2,3,22,1 },
	{ 7,-1,-1,G_TEXT,NONE,NORMAL,{3L},2,4,22,1 },
	{ 8,-1,-1,G_TEXT,NONE,NORMAL,{4L},2,5,22,1 },
	{ 9,-1,-1,G_TEXT,NONE,NORMAL,{5L},2,6,22,1 },
	{ 10,-1,-1,G_TEXT,NONE,NORMAL,{6L},2,7,22,1 },
	{ 11,-1,-1,G_BOXCHAR,TOUCHEXIT,NORMAL,{0x1ff1100L},24,2,2,1 },								/*  */
	{ 13,12,12,G_BOX,TOUCHEXIT,NORMAL,{0xff1111L},24,3,2,4 },
	{ 11,-1,-1,G_BOX,TOUCHEXIT,NORMAL,{0xff1100L},0,0,2,1 },
	{ 14,-1,-1,G_BOXCHAR,TOUCHEXIT,NORMAL,{0x2ff1100L},24,7,2,1 },								/*  */
	{ 15,-1,-1,G_IMAGE,TOUCHEXIT,NORMAL,{0L},28,4,4,3 },											/* logo */
	{ 16,-1,-1,G_STRING,NONE,NORMAL,{22L},1,8,31,1 },												/* mesures frequency  */
	{ 17,-1,-1,G_BUTTON,SELECTABLE|DEFAULT|EXIT|FL3DACT,NORMAL,{23L},3,11,8,1 },					/* Change */
	{ 18,-1,-1,G_BUTTON,SELECTABLE|EXIT|FL3DACT,NORMAL,{24L},23,11,8,1 },			/* Cancel */
	{ 19,-1,-1,G_BUTTON,SELECTABLE|EXIT|FL3DACT,NORMAL,{25L},13,11,8,1 },			/* Test */
	{ 0,-1,-1,G_BUTTON,LASTOB|TOUCHEXIT,SHADOWED,{26L},27,7,6,1 },										/* popup modes */
};

OBJECT rs_object_menu_rom[] =
{
	{ -1,1,6,G_BOX,NONE,SHADOWED,{0xFF1100L},0,0,6,6 },
	{ 2,-1,-1,G_STRING,NONE,NORMAL,{0L},0,0,6,1 },
	{ 3,-1,-1,G_STRING,NONE,NORMAL,{1L},0,1,6,1 },
	{ 4,-1,-1,G_STRING,NONE,NORMAL,{2L},0,2,6,1 },
	{ 5,-1,-1,G_STRING,NONE,NORMAL,{3L},0,3,6,1 },
	{ 6,-1,-1,G_STRING,NONE,NORMAL,{4L},0,4,6,1 },
	{ 0,-1,-1,G_STRING,LASTOB,NORMAL,{5L},0,5,6,1 }
};

OBJECT rs_object_menu2_rom[] =
{
	{ -1,1,4,G_BOX,NONE,SHADOWED,{0xFF1100L},0,0,9,4 },
	{ 2,-1,-1,G_STRING,NONE,NORMAL,{0L},0,0,9,1 },
	{ 3,-1,-1,G_STRING,NONE,NORMAL,{1L},0,1,9,1 },
	{ 4,-1,-1,G_STRING,NONE,NORMAL,{2L},0,2,9,1 },
	{ 0,-1,-1,G_STRING,LASTOB,NORMAL,{3L},0,3,9,1 }
};

#define USA 0
#define FRG 1
#define FRA 2
#define UK 3
#define SPA 4
#define ITA 5
#define SWE 6
#define SWF 7
#define SWG 8

#define MAX_RES 300

#define MODES_XBIOS 0
#define MODES_VESA 1
#define MODES_RADEON 2
#define MODES_MON1 3

typedef struct
{
	long ident;
	union
	{
		long l;
		int i[2];
		char c[4];
	} v;
} COOKIE;

typedef struct
{
	int state;			/* selected or not */
	int modecode;
	int width_screen;
	int height_screen;
	int vert_freq;
	int pixel_clock;
	char name[24];
} LISTE_RES;

/* prototypes */

int init_rsc(void);
void free_rsc(void);
void ob_change(OBJECT *tree, short object, short res, GRECT *g, short new_state, short redraw);
void wait_up(void);
void display_slider(GRECT *work);
void init_slider(void);
void select_normal_rez(GRECT *work);
void display_rez(GRECT *work);
void change_string_colors(int choice_color);
void init_list_rez(int choice_color);
int current_rez(int modecode, int *vert_freq, int *pixel_clock);
long tempo_5S(void);
void my_ltoa(char *buf, long n, int digits);
extern COOKIE *get_cookie(long id);

/* variables globales */

extern struct pci_device_id radeonfb_pci_table[]; /* radeon_base */
extern unsigned short d_rezword;
extern long fix_modecode; /* xbios.c */
extern struct fb_info *info_fvdi;
extern long total_modedb;
OBJECT *rs_object, *rs_object_menu, *rs_object_menu2;
TEDINFO *rs_tedinfo;
char **rs_strings;
LISTE_RES liste_rez[MAX_RES];
int offset_select, nb_res, sel_color, type_modes;
#if defined(COLDFIRE) && defined(MCF547X) /* FIREBEE */
extern unsigned long videl_modedb_len;
#endif

/* global variables VDI & AES */

short vdi_handle, work_in[11] = {1,1,1,1,1,1,1,1,1,1,2}, work_out[57], work_extend[57];
short gr_hwchar, gr_hhchar, gr_hwbox, gr_hhbox;
int start_lang;
extern short video_found;

short set_video(void)
{
	short xy[8];
	char *p;
	MFDB source, target;
	GRECT menu, box, rect, r;
	MENU Menu, MData;
	EVNTDATA mouse;
	void *screen = NULL;
	long temp;
	int i, double_clic, end, redraw;
	short ret, chg_res = 0;
	unsigned short modecode, new_mode, cur_mode;
	int choice_color, choice_rez, vert_freq, pixel_clock;
	offset_select = nb_res = 0;
	rs_object = rs_object_menu = rs_object_menu2 = NULL;
	rs_tedinfo = NULL;
	rs_strings = NULL;
	if(get_cookie('_PCI') == NULL)
		return(-1);
	if(!video_found && (Physbase() < (void *)0x01000000))
		return(-1);
	vdi_handle = graf_handle(&gr_hwchar, &gr_hhchar, &gr_hwbox, &gr_hhbox);
	if(!init_rsc())
		return(0);
	v_opnvwk(work_in, &vdi_handle, work_out);
	if(vdi_handle <= 0)
	{
		free_rsc();
		return(0);
	}
	vq_extnd(vdi_handle, 1, work_extend);
	modecode = Vsetmode(-1);
	if(!(modecode & DEVID))
		type_modes = MODES_XBIOS;
	else
	{
		struct radeonfb_info *rinfo = info_fvdi->par;
		struct smifb_info *smiinfo = info_fvdi->par;
		if(GET_DEVID(modecode) < 34)
			type_modes = MODES_VESA;
		else if(GET_DEVID(modecode) < (34 + total_modedb))
			type_modes = MODES_RADEON;
#if defined(COLDFIRE) && defined(MCF547X) /* FIREBEE */
		else if(!video_found && videl_modedb_len)
			type_modes = MODES_MON1;
#endif
		else if((video_found == 1) && rinfo->mon1_dbsize)
			type_modes = MODES_MON1;
		else if((video_found == 2) && smiinfo->mon1_dbsize)
			type_modes = MODES_MON1;
		else
			type_modes = MODES_XBIOS;
	}
	rs_object[VIDEOBCOUL].ob_flags |= TOUCHEXIT;
	rs_object[VIDEOBCOUL].ob_state &= ~DISABLED;
	choice_color = (int)modecode & NUMCOLS;
	init_list_rez(choice_color);
	choice_rez = current_rez(modecode, &vert_freq, &pixel_clock);	/* search curent rez inside the list */
	for(i = VIDEOCHOIX1; i <= VIDEOCHOIX6; i++)
	{
		if((choice_rez + VIDEOCHOIX1) == i)
			rs_object[i].ob_state |= SELECTED;
		else
			rs_object[i].ob_state &= ~SELECTED;
	}
	display_rez(NULL); /* init tedinfos without display */
	change_string_colors(choice_color);
	rs_object[VIDEOBMODE].ob_spec.free_string = strings_modes[type_modes];
	p = rs_object[VIDEOINFO].ob_spec.free_string;
	my_ltoa(&p[0], VgetSize(modecode), 8);
	p[8] = ' ';
	my_ltoa(&p[16], (long)vert_freq, 3);
	p[19] = ' ';
	my_ltoa(&p[23], (long)pixel_clock, 3);
	p[26] = ' ';
	if(choice_rez >= 0)
	{
		rs_object[VIDEOBCHANGE].ob_flags |= (SELECTABLE|EXIT);
		rs_object[VIDEOBCHANGE].ob_state &= ~DISABLED;
	}
	else
	{
		rs_object[VIDEOBCHANGE].ob_flags &= ~(SELECTABLE|EXIT);
		rs_object[VIDEOBCHANGE].ob_state |= DISABLED;
	}
	end = 0;
//	redraw = 1;
	redraw = 2;
	while(!end)
	{
		if(redraw)
		{
			wind_update(BEG_UPDATE);	
			form_center(rs_object, &box.g_x, &box.g_y, &box.g_w, &box.g_h);
			form_dial(FMD_START, box.g_x, box.g_y, box.g_w, box.g_h, box.g_x, box.g_y, box.g_w, box.g_h);
			objc_draw(rs_object, VIDEOBOX, MAX_DEPTH, box.g_x, box.g_y, box.g_w, box.g_h);
			if(redraw == 2)
				display_rez(&box); // bug when box opened (1st line) ???
			redraw = 0;
		}
		double_clic = 0;
		ret = form_do(rs_object, 0);
		if(ret != -1 && (ret & 0x8000))
		{
			ret &= 0x7fff;
			double_clic = 1;
		}
		switch(ret)
		{
			case VIDEOBCOUL:
				objc_offset(rs_object, VIDEOBCOUL, &menu.g_x, &menu.g_y);
				menu.g_w = rs_object[VIDEOBCOUL].ob_width;
				menu.g_h = rs_object[VIDEOBCOUL].ob_height;
				Menu.mn_tree = rs_object_menu;
				Menu.mn_menu = VIDBASE;
				Menu.mn_item = (short)choice_color + VID2;
				Menu.mn_scroll = FALSE;
				if(menu_popup(&Menu, menu.g_x, menu.g_y, &MData))
				{
					offset_select = 0;
					choice_color = (int)MData.mn_item - VID2;
					change_string_colors(choice_color);
					objc_draw(rs_object, VIDEOBCOUL, MAX_DEPTH, box.g_x, box.g_y, box.g_w, box.g_h);
					if(choice_rez >= 0)
					{
						cur_mode = liste_rez[choice_rez].modecode & ~NUMCOLS;
						init_list_rez(choice_color);
						choice_rez = -1;
						for(i = 0; i < nb_res; i++)	/* search rez with previous selected colors choice */
						{
							if((liste_rez[i].modecode & ~NUMCOLS) == cur_mode)
							{
								choice_rez = i;
								liste_rez[i].state = SELECTED;
								break;
							}
						}
					}
					else
					{
						init_list_rez(choice_color);
						if((ret = current_rez(modecode, &vert_freq, &pixel_clock))>=0)
							choice_rez = ret;
					}
					goto display_res;
				}	
				break;
			case VIDEOCHOIX1:
			case VIDEOCHOIX2:
			case VIDEOCHOIX3:
			case VIDEOCHOIX4:
			case VIDEOCHOIX5:
			case VIDEOCHOIX6:
				if(nb_res >= 0)
				{
					if(choice_rez >= 0)
						liste_rez[choice_rez].state = NORMAL;
					select_normal_rez(&box);
					ob_change(rs_object, ret, 0, &box, SELECTED, 1);
					wait_up();
					ret -= VIDEOCHOIX1;
					choice_rez = ret + offset_select;
					liste_rez[choice_rez].state = SELECTED;
					rs_object[VIDEOBCHANGE].ob_flags |= (SELECTABLE|EXIT);
					if(double_clic)
					{
						ob_change(rs_object, VIDEOBCHANGE, 0, &box, SELECTED, 1);
						goto change;
					}
					else
						ob_change(rs_object, VIDEOBCHANGE, 0, &box, NORMAL, 1);
				}
				break;
			case VIDEOBHAUT:
				if(offset_select)
				{
					ob_change(rs_object, VIDEOBHAUT, 0, &box, SELECTED, 1);
					offset_select--;
					if(offset_select < 0)
						offset_select = 0;
					display_rez(&box);
					ob_change(rs_object, VIDEOBHAUT, 0, &box, NORMAL, 1);
 				}
				break;
			case VIDEOBOXSLIDER:
				graf_mkstate(&mouse.x, &mouse.y, &mouse.bstate, &mouse.kstate);
				objc_offset(rs_object, VIDEOSLIDER, &mouse.x, &ret);
				if(mouse.y > ret)
					offset_select += 6;
 				else
					offset_select -= 6;
				if(offset_select < 0)
					offset_select = 0;
				if((i = nb_res - 6) < 0)
					i = 0;
				if(offset_select > i)
					offset_select = i;
				display_rez(&box);
				break;
			case VIDEOSLIDER:
				wind_update(BEG_MCTRL);
				ret = graf_slidebox(rs_object, VIDEOBOXSLIDER, VIDEOSLIDER, 1);
				wind_update(END_MCTRL);
				if((i = nb_res - 6) < 0)
					i = 0;
				temp = (long)i * (long)ret;
				temp /= 1001L;
				if(temp % 1001L)
					temp++;
				offset_select = (int)temp;
				display_rez(&box);
				break;
			case VIDEOBBAS:
				if((i = nb_res - 6) < 0)
					i = 0;
				if(offset_select != i)
				{
					ob_change(rs_object, VIDEOBBAS, 0, &box, SELECTED, 1);
					offset_select++;
					if(offset_select > i)
						offset_select = i;
					display_rez(&box);
					ob_change(rs_object, VIDEOBBAS, 0, &box, NORMAL, 1);
				}
				break;
			case VIDEOLOGO:
				wait_up();
				choice_color = modecode & NUMCOLS;
				change_string_colors(choice_color);
				objc_draw(rs_object, VIDEOBCOUL, MAX_DEPTH, box.g_x, box.g_y, box.g_w, box.g_h);
				init_list_rez(choice_color);
				choice_rez = current_rez(modecode, &vert_freq, &pixel_clock);	/* search current rez inside the list */
display_res:
				if(choice_rez >= 0)
				{
					for(i = VIDEOCHOIX1; i <= VIDEOCHOIX6; i++)
					{
						if((choice_rez + VIDEOCHOIX1 - offset_select) == i)
							rs_object[i].ob_state |= SELECTED;
						else
							rs_object[i].ob_state &= ~SELECTED;
					}
					rs_object[VIDEOBCHANGE].ob_flags |= (SELECTABLE|EXIT);
				}
				else
					rs_object[VIDEOBCHANGE].ob_flags &= ~(SELECTABLE|EXIT);
				display_rez(&box);
				ob_change(rs_object, VIDEOBCHANGE, 0, &box, (choice_rez >= 0) ? NORMAL : DISABLED, 1);
				break;
			case VIDEOBCHANGE:
change:		
				rs_object[VIDEOBCHANGE].ob_state &= ~SELECTED;
				if(choice_rez >= 0)
				{
					new_mode = liste_rez[choice_rez].modecode;
					if(new_mode != modecode)
					{
						fix_modecode = 1; /* do not patch Validmode, xbios.c */	
						d_rezword = Validmode(new_mode);
						chg_res = 1;
					}
				}
				end = 1;
				break;
			case VIDEOBANNULE:
				rs_object[VIDEOBANNULE].ob_state &= ~SELECTED;
				end = 1;
				break;
			case VIDEOBTEST:
				form_dial(FMD_FINISH, box.g_x, box.g_y, box.g_w, box.g_h, box.g_x, box.g_y, box.g_w, box.g_h);
				wind_update(END_UPDATE);
				wind_update(BEG_UPDATE);
				redraw = 1;
				rect.g_x = rect.g_y = 0;            /* screen size */
				rect.g_w = work_out[0];
				rect.g_h = work_out[1];
				graf_mouse(M_OFF, (MFORM *)0);
				form_dial(FMD_START, rect.g_x, rect.g_y, rect.g_w, rect.g_h, rect.g_x, rect.g_y, rect.g_w, rect.g_h);
				screen = (void *)Mxalloc((work_out[0] + 1) * (work_out[1] + 1) * (work_extend[4] >> 3), 3);
				target.fd_addr = 0;                 /* screen */
				if(screen == NULL)                  /* save menu */
				{
					wind_get(0, WF_WORKXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h); /* desktop */	
					wind_get(0, WF_SCREEN, &xy[0], &xy[1], &xy[2], &xy[3]);
					source.fd_addr = (void *)(((long)xy[0] << 16) + (long)((unsigned)xy[1]));	/* AES buffer */
				}
				else                                /* save screen */
					source.fd_addr = screen;
				source.fd_w = work_out[0] + 1;      /* width screen */
				source.fd_h = work_out[1] + 1;      /* height screen */
				source.fd_wdwidth = source.fd_w >> 4;
				if(source.fd_w % 16)
					source.fd_wdwidth++;
				source.fd_stand = 0;
				source.fd_nplanes = work_extend[4]; /* nb planes */
				xy[0] = xy[1] = xy[4] = xy[5] = 0;  /* x1,y1 */
				if(screen == NULL)                  /* save menu */
				{
					xy[2] = xy[6] = r.g_w - 1;        /* x2 */
					xy[3] = xy[7] = r.g_y - 1;        /* y2 */
				}
				else                                /* save screen */
				{
					xy[2] = xy[6] = work_out[0];      /* x2 */
					xy[3] = xy[7] = work_out[1];      /* y2 */	
				}
				vro_cpyfm(vdi_handle, S_ONLY, xy, &target, &source); /* save menu */
				cur_mode = Vsetmode(-1);            /* save curent video mode */
				temp = Vsetscreen(-1, choice_rez >= 0 ? (liste_rez[choice_rez].modecode & ~VIRTUAL_SCREEN) : (modecode & ~VIRTUAL_SCREEN), 'VN', CMD_TESTMODE);
				Supexec(tempo_5S);                  /* delay */
				ret = Vsetmode(cur_mode);           /* restore video mode */
				vro_cpyfm(vdi_handle, S_ONLY, xy, &source, &target);	/* redraw menu */
				if(screen != NULL)
					Mfree(screen);
				rect.g_x = rect.g_y = 0;            /* redraw screen */
				rect.g_w = work_out[0];   
				rect.g_h = work_out[1];
				form_dial(FMD_FINISH, rect.g_x, rect.g_y, rect.g_w, rect.g_h, rect.g_x, rect.g_y, rect.g_w, rect.g_h);
				graf_mouse(M_ON, (MFORM *)0);
				graf_mouse(ARROW, (MFORM *)0);
				wind_update(END_UPDATE);
				rs_object[VIDEOBTEST].ob_state &= ~SELECTED;
				if(screen == NULL)
					end = 1; /* redraw by desktop => must quit box form */
				break;
			case VIDEOBMODE:
				objc_offset(rs_object, VIDEOBMODE, &menu.g_x, &menu.g_y);
				menu.g_w = rs_object[VIDEOBMODE].ob_width;
				menu.g_h = rs_object[VIDEOBMODE].ob_height;
				Menu.mn_tree = rs_object_menu2;
				Menu.mn_menu = MODBASE;
				Menu.mn_item = (short)type_modes + MODXBIOS;
				Menu.mn_scroll = FALSE;
				if(menu_popup(&Menu, menu.g_x, menu.g_y, &MData))
				{
					offset_select = 0;
					type_modes = (int)MData.mn_item - MODXBIOS;
					rs_object[VIDEOBMODE].ob_spec.free_string = strings_modes[type_modes];
					objc_draw(rs_object, VIDEOBMODE, MAX_DEPTH, box.g_x, box.g_y, box.g_w, box.g_h);
					if(choice_rez >= 0)
					{
						cur_mode = liste_rez[choice_rez].modecode & ~NUMCOLS;
						init_list_rez(choice_color);
						choice_rez = -1;
						for(i = 0; i < nb_res; i++)	/* search rez with previous selected colors choice */
						{
							if((liste_rez[i].modecode & ~NUMCOLS) == cur_mode)
							{
								choice_rez = i;
								liste_rez[i].state = SELECTED;
								break;
							}
						}
					}
					else
					{
						init_list_rez(choice_color);
						if((ret = current_rez(modecode, &vert_freq, &pixel_clock)) >= 0)
							choice_rez = ret;
					}
					goto display_res;
				}	
				break;
		}
	}
	form_dial(FMD_FINISH, box.g_x, box.g_y, box.g_w, box.g_h, box.g_x, box.g_y, box.g_w, box.g_h);
	wind_update(END_UPDATE);
	v_clsvwk(vdi_handle);
	free_rsc();
	return(chg_res);
}

int init_rsc(void)
{
	struct radeonfb_info *rinfo = info_fvdi->par;
	struct smifb_info *smiinfo = info_fvdi->par; 
	COOKIE *p;
	int i;
	rs_object = (OBJECT *)Mxalloc(sizeof(rs_object_rom), 3);
	if(rs_object == NULL)
		return(0);
	memcpy(rs_object, rs_object_rom, sizeof(rs_object_rom));
	rs_tedinfo = (TEDINFO *)Mxalloc(sizeof(rs_tedinfo_rom), 3);
	if(rs_tedinfo == NULL)
	{
		free_rsc();
		return(0);
	}
	memcpy(rs_tedinfo, rs_tedinfo_rom, sizeof(rs_tedinfo_rom));
	if(((p = get_cookie('_AKP')) != NULL)
	 && (((p->v.l >> 8) == FRA) || ((p->v.l >> 8) == SWF)))
	{
		start_lang = 0;
		rs_strings = (char **)Mxalloc(sizeof(rs_strings_fr), 3);
		if(rs_strings == NULL)
		{
			free_rsc();
			return(0);
		}
		memset(rs_strings, 0, sizeof(rs_strings_fr));
		for(i = 0; i < sizeof(rs_strings_fr) / sizeof(char *); i++)
		{
			if((rs_strings[i] = (char *)Mxalloc(strlen(rs_strings_fr[i])+1, 3)) == NULL)
			{
				free_rsc();
				return(0);
			}
			strcpy(rs_strings[i], rs_strings_fr[i]);
		}
	}
	else
	{
		start_lang = 1;
		rs_strings = (char **)Mxalloc(sizeof(rs_strings_en), 3);
		if(rs_strings == NULL)
		{
			free_rsc();
			return(0);
		}
		memset(rs_strings, 0, sizeof(rs_strings_en));
		for(i = 0; i < sizeof(rs_strings_en) / sizeof(char *); i++)
		{
			if((rs_strings[i] = (char *)Mxalloc(strlen(rs_strings_en[i])+1, 3)) == NULL)
			{
				free_rsc();
				return(0);
			}
			strcpy(rs_strings[i], rs_strings_en[i]);
		}
	}
	for(i = 0; i < sizeof(rs_tedinfo_rom)/sizeof(TEDINFO); i++)
	{
		rs_tedinfo[i].te_ptext = rs_strings[(int)rs_tedinfo[i].te_ptext];
		rs_tedinfo[i].te_ptmplt = rs_strings[(int)rs_tedinfo[i].te_ptmplt];
		rs_tedinfo[i].te_pvalid = rs_strings[(int)rs_tedinfo[i].te_pvalid];
	}
	i = 0;
	do
	{
		switch(rs_object[i].ob_type)
		{
			case G_STRING:
			case G_BUTTON:
				rs_object[i].ob_spec.free_string = rs_strings[rs_object[i].ob_spec.index];
				break;
			case G_TEXT:
			case G_BOXTEXT:
			case G_FTEXT:
			case G_FBOXTEXT:
				rs_object[i].ob_spec.tedinfo = &rs_tedinfo[rs_object[i].ob_spec.index];
				break;
			case G_IMAGE:
				rs_object[i].ob_spec.bitblk = &rs_bitblk[rs_object[i].ob_spec.index];
				break;
		}
		rs_object[i].ob_x *= gr_hwchar;
		rs_object[i].ob_y *= gr_hhchar;	
		rs_object[i].ob_width *= gr_hwchar;		
		rs_object[i].ob_height *= gr_hhchar;
	}
	while(!(rs_object[i++].ob_flags & LASTOB));
	rs_object[VIDEOTEXT].ob_y += 2;
	rs_object[VIDEOBHAUT].ob_x++;
	rs_object[VIDEOBOXSLIDER].ob_x++;
	rs_object[VIDEOBOXSLIDER].ob_y++;
	rs_object[VIDEOBOXSLIDER].ob_height -= 2;
	rs_object[VIDEOBBAS].ob_x++;
	rs_object[VIDEOLOGO].ob_y -= 4;
	rs_object[VIDEOLOGO].ob_spec.bitblk = rs_bitblk;
	rs_object[VIDEOINFO].ob_y += 4;
	rs_object[VIDEOBMODE].ob_y -= 4;
	rs_object_menu = (OBJECT *)Mxalloc(sizeof(rs_object_menu_rom), 3);
	if(rs_object_menu == NULL)
	{
		free_rsc();
		return(0);
	}
	memcpy(rs_object_menu, rs_object_menu_rom, sizeof(rs_object_menu_rom));
	i = 0;
	do
	{
		switch(rs_object_menu[i].ob_type)
		{
			case G_STRING:
				rs_object_menu[i].ob_spec.free_string = rs_strings_colors[rs_object_menu[i].ob_spec.index];
				break;
		}
		rs_object_menu[i].ob_x *= gr_hwchar;
		rs_object_menu[i].ob_y *= gr_hhchar;	
		rs_object_menu[i].ob_width *= gr_hwchar;		
		rs_object_menu[i].ob_height *= gr_hhchar;
	}
	while(!(rs_object_menu[i++].ob_flags & LASTOB));
	rs_object_menu2 = (OBJECT *)Mxalloc(sizeof(rs_object_menu2_rom), 3);
	if(rs_object_menu2 == NULL)
	{
		free_rsc();
		return(0);
	}
	memcpy(rs_object_menu2, rs_object_menu2_rom, sizeof(rs_object_menu2_rom));
	i = 0;
	do
	{
		switch(rs_object_menu2[i].ob_type)
		{
			case G_STRING:
				rs_object_menu2[i].ob_spec.free_string = rs_strings_modes[rs_object_menu2[i].ob_spec.index];
				break;
		}
		rs_object_menu2[i].ob_x *= gr_hwchar;
		rs_object_menu2[i].ob_y *= gr_hhchar;	
		rs_object_menu2[i].ob_width *= gr_hwchar;		
		rs_object_menu2[i].ob_height *= gr_hhchar;
	}
	while(!(rs_object_menu2[i++].ob_flags & LASTOB));
	switch(video_found)
	{
		case 1:
		 	if(!rinfo->mon1_dbsize)
		 		rs_object_menu2[MODMON1].ob_state |= DISABLED;
		 	break;	
		case 2:
		 	if(!smiinfo->mon1_dbsize)
		 		rs_object_menu2[MODMON1].ob_state |= DISABLED;
		 	break;
		default:
#if defined(COLDFIRE) && defined(MCF547X) /* FIREBEE */
			if(!videl_modedb_len)
#endif
				rs_object_menu2[MODMON1].ob_state |= DISABLED;
			break;
	}		
	return(1);
}

void free_rsc(void)
{
	int i, len;
	if(rs_object)
		Mfree(rs_object);
	if(rs_tedinfo)
		Mfree(rs_tedinfo);
	if(rs_strings)
	{
		if(!start_lang)
			len = sizeof(rs_strings_fr) / sizeof(char *);
		else
			len = sizeof(rs_strings_en) / sizeof(char *);
		for(i = 0; i < len; i++)
		{
			if(rs_strings[i] != NULL)
				Mfree(rs_strings[i]);
		}
		Mfree(rs_strings);
	}
	if(rs_object_menu)
		Mfree(rs_object_menu);
	if(rs_object_menu2)
		Mfree(rs_object_menu2);
}

void ob_change(OBJECT *tree, short index, short res, GRECT *g, short new_state, short redraw)
{
	if(res);
	if(new_state & SELECTED)
		tree[index].ob_state |= SELECTED;	
	else
		tree[index].ob_state &= ~SELECTED;
	if(new_state & DISABLED)
		tree[index].ob_state |= DISABLED;	
	else
		tree[index].ob_state &= ~DISABLED;
	if(redraw)		
		objc_draw(tree, index, MAX_DEPTH, g->g_x, g->g_y, g->g_w, g->g_h);
}

void wait_up(void)
{
	EVNTDATA mouse;
	do
		graf_mkstate(&mouse.x, &mouse.y, &mouse.bstate, &mouse.kstate);
	while(mouse.bstate);	
}

void display_slider(GRECT *work)
{
	int i;
	if((i = nb_res - 6) <= 0)		
		i = 1;
	/* vectical position of the slider */
	rs_object[VIDEOSLIDER].ob_y = (offset_select * (rs_object[VIDEOBOXSLIDER].ob_height - rs_object[VIDEOSLIDER].ob_height))/i;
	objc_draw(rs_object, VIDEOBOXSLIDER, MAX_DEPTH, work->g_x, work->g_y, work->g_w, work->g_h);
}

void init_slider(void)
{
	int i;
	if((i = nb_res) < 6)		
		i = 6;
	i = (rs_object[VIDEOBOXSLIDER].ob_height) * 6 / i;
	if(i < 8)
		i = 8;
	rs_object[VIDEOSLIDER].ob_height = i;
	if((i = nb_res - 6) <= 0)		
		i = 1;
	/* vertical position of the slider */
	rs_object[VIDEOSLIDER].ob_y = (offset_select * (rs_object[VIDEOBOXSLIDER].ob_height - rs_object[VIDEOSLIDER].ob_height))/i;
}

void select_normal_rez(GRECT *work)
{
	int i;
	for(i = VIDEOCHOIX1; i <= VIDEOCHOIX6; i++)
	{
		if(rs_object[i].ob_state & SELECTED)
			ob_change(rs_object, i, 0, work, NORMAL, 1);
	}
}

void display_rez(GRECT *work)
{
	TEDINFO *t_edinfo;
	int i, j = offset_select;
	if(work != NULL)
	{
		display_slider(work);
		select_normal_rez(work);
	}
	for(i = VIDEOCHOIX1; i <= VIDEOCHOIX6; i++)
	{
		t_edinfo = rs_object[i].ob_spec.tedinfo;
		if(j < nb_res)
		{
			strcpy(t_edinfo->te_ptext, liste_rez[j].name);
			rs_object[i].ob_flags |= TOUCHEXIT;
			rs_object[i].ob_state = liste_rez[j].state;
		}
		else
		{ 
			strcpy(t_edinfo->te_ptext, "                      ");
			rs_object[i].ob_flags &= ~TOUCHEXIT;
			rs_object[i].ob_state = NORMAL;
		}
		if(work != NULL)
			objc_draw(rs_object, (short)i, MAX_DEPTH, work->g_x, work->g_y, work->g_w, work->g_h);
		j++;
	}
}

void change_string_colors(int choice_color)
{
	char *p = rs_object[VIDEOBCOUL].ob_spec.free_string;
	switch(choice_color)
	{
		case 0: strcpy(p,"2"); break;
		case 1: strcpy(p,"4"); break;
		case 2: strcpy(p,"16"); break;
		case 3: strcpy(p,"256"); break;
		case 4: strcpy(p,"65536"); break;
		default: strcpy(p,"16M"); break;
	}
}

static long enumfunc(SCREENINFO *inf, long flag)
{
	int i;
	if(flag);
	if((nb_res < MAX_RES)
	 && ((inf->devID & NUMCOLS) == (long)sel_color)
	 && ( ((type_modes == MODES_XBIOS) && !(inf->devID & DEVID))
	  || ((type_modes == MODES_VESA) && (inf->devID & DEVID) && (GET_DEVID(inf->devID) < 34))
	  || ((type_modes == MODES_RADEON) && (inf->devID & DEVID) && (GET_DEVID(inf->devID) >= 34) && (GET_DEVID(inf->devID) < (34 + total_modedb)))
	  || ((type_modes == MODES_MON1) && (inf->devID & DEVID) && (GET_DEVID(inf->devID) >= (34 + total_modedb))) ))
	{
		liste_rez[nb_res].state = NORMAL;
		liste_rez[nb_res].modecode = (int)inf->devID;
		liste_rez[nb_res].width_screen = (int)inf->scrWidth;
		liste_rez[nb_res].height_screen = (int)inf->scrHeight;
		liste_rez[nb_res].vert_freq = (int)inf->refresh;
		if(inf->pixclock)
			liste_rez[nb_res].pixel_clock = (int)(1000000L/inf->pixclock);
		else
			liste_rez[nb_res].pixel_clock = 0;
		for(i = 0; i < 22 && inf->name[i]; liste_rez[nb_res].name[i] = inf->name[i], i++);
		for(; i < 22; liste_rez[nb_res].name[i++] = ' ');
		liste_rez[nb_res].name[i] = 0;
		nb_res++;
	}
	if(nb_res < MAX_RES)
		return(1);
	return(0);
}

void init_list_rez(int choice_color)
{
	int i, j, temp;
	long ret;
	char buf_temp[24];
	nb_res = 0;
	sel_color = (long)choice_color;
	ret = Vsetscreen(-1, &enumfunc, 'VN', CMD_ENUMMODES);
	for(i = 0; i < nb_res; i++)		/* sort */
	{
		for(j = 0; j < nb_res; j++)
		{
			if((unsigned long)liste_rez[i].height_screen * (unsigned long)liste_rez[i].width_screen + ((unsigned long)liste_rez[i].modecode & 0xFFFF)
			 < (unsigned long)liste_rez[j].height_screen * (unsigned long)liste_rez[j].width_screen + ((unsigned long)liste_rez[j].modecode & 0xFFFF))
			{
				temp = liste_rez[i].modecode;
				liste_rez[i].modecode = liste_rez[j].modecode;
				liste_rez[j].modecode = temp;		
				temp = liste_rez[i].width_screen;
				liste_rez[i].width_screen = liste_rez[j].width_screen;
				liste_rez[j].width_screen = temp;
				temp = liste_rez[i].height_screen;
				liste_rez[i].height_screen = liste_rez[j].height_screen;
				liste_rez[j].height_screen = temp;
				temp = liste_rez[i].vert_freq;
				liste_rez[i].vert_freq = liste_rez[j].vert_freq;
				liste_rez[j].vert_freq = temp;
				temp = liste_rez[i].pixel_clock;
				liste_rez[i].pixel_clock = liste_rez[j].pixel_clock;
				liste_rez[j].pixel_clock = temp;
				strcpy(buf_temp ,liste_rez[i].name);
				strcpy(liste_rez[i].name, liste_rez[j].name);
				strcpy(liste_rez[j].name, buf_temp);
			}
		}
	}
}
						
int current_rez(int modecode, int *vert_freq, int *pixel_clock)
{
	int i, choice_rez = -1;
	*vert_freq = 0;
	*pixel_clock = 0;
	for(i = 0; i < nb_res; i++)	/* search current rez inside the list */
	{
		if(liste_rez[i].modecode == modecode)
		{
			choice_rez = i;
			liste_rez[i].state = SELECTED;
			*vert_freq = liste_rez[i].vert_freq;
			*pixel_clock = liste_rez[i].pixel_clock;
		}
	}					
	return(choice_rez);
}

long tempo_5S(void)
{
	unsigned long start_time;
	start_time = *_hz_200;
	while(((*(volatile unsigned long *)_hz_200) - start_time) <= 1000);
	return(0);
}

void my_ltoa(char *buf, long n, int digits)
{
	unsigned long un = (unsigned long)n;
	char *tmp, ch;
	if(n < 0)
	{
		*buf++ = '-';
		un = (unsigned long)-n;
	}
	tmp = buf;
	do
	{
		ch = (char)(un % 10);
		un /= 10;
		if(ch <= 9)
			ch += '0';
		else
			ch += 'a' - 10;
		*tmp++ = ch;
		digits--;
	}
	while(un);
	while(--digits >= 0)
		*tmp++ = ' ';
	*tmp = '\0';
	while(tmp > buf)
	{
		ch = *buf;
		*buf++ = *--tmp;
		*tmp = ch;
	}
}

