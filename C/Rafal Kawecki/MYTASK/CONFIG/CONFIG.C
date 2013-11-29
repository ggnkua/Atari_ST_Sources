	/* Petit exemple de Xgem avec quelques fenˆtres: */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <x_gem.h>
#include <mytask.h>
#include "options.rh"
#include "options.rsh"
#include "../option.h"

#define MX_HEADER				((1 << 3)									/*	Refer to Program Header			*/
#define MX_PRIVATE			((1 << 3) | (1 << 4))			/*	Private											*/
#define MX_GLOBAL				((1 << 3) | (2 << 4))			/*	Global											*/
#define MX_SUPERVISOR		((1 << 3) | (3 << 4))			/*	Supervisor Mode Only Access	*/
#define MX_READABLE			((1 << 3) | (4 << 4))			/*	Read Only Access						*/


struct _donotshow
	{
	int how_many;
	char name[8];				/* Nazwa aplikacji, ktora ma byc nie pokazana - zapisywane w opcjach	*/
	int ap_id;					/* ID tej aplikacji - nowe za kazdym razem														*/
	}*DoNotShow;

void init_gem (void);
void exit_gem (void);
void gere_messages (void);
void gere_fenetres (void);
void close_form (short window);
void close_icon (short window);
void SendAV(int to_id, int p1, int p2, int p3, int p4, int p5, int p6, int p7, int p8);

#define WINDS	10				/* nb de fenˆtres ouvrables par l'appli */

char buff[256], buff2[256];		/* buffers pour des manipulations de chaŒnes diverses */
short quit = 0;					/* flag pour sortir */
short wind_form = -1;	/* num‚ros des 3 diff‚rentes fenˆtres (ferm‚es au d‚part) */
short wind_icon = -1;
short options_draw = 4;			/* style de trame de la fenˆtre de dessin */
short options_text = 7;			/* options d'affichage pour la fenˆtre texte */
short pos_sl1;
OBJECT *adr_dial, *popup_kat, *popup_maus, *popup_farben, *popup_texture, *popup_lang, *popup_appl, *popup_appl_ver;
OBJECT *popup_kontext;
X_GEM_INFO *x_gem;				/* structure de dialogue entre l'appli et x_gem */
WIND_LIST window[WINDS];		/* tableau avec indication du nombre maximal de fenˆtres */

static char ext_rsc[128];
static int start_rsc_no, app_rsc_no;
static char def_klicks[4][4], def_doppel_klicks[4][4];
static char c_def_klicks[4][4], c_def_doppel_klicks[4][4];
static int lang;
static int c_la;
static int col_app, col_acc, col_sys, col_shell;
static int col_b_app, col_b_acc, col_b_sys, col_b_shell;
static int col_caps_on, col_caps_off;
static int col_t_caps_on, col_t_caps_off;
static int col_freezy, col_b_freezy;
static int col_hidden, col_b_hidden;
static int tex_app, tex_acc, tex_sys, tex_shell;
static int tex_caps_on, tex_caps_off;
static int tex_freezy;
static int tex_hidden;
static int c_col_app, c_col_acc, c_col_sys, c_col_shell;
static int c_col_b_app, c_col_b_acc, c_col_b_sys, c_col_b_shell;
static int c_tex_app, c_tex_acc, c_tex_sys, c_tex_shell;
static int c_tex_caps_on, c_tex_caps_off;
static int c_col_caps_on, c_col_caps_off;
static int c_col_t_caps_on, c_col_t_caps_off;
static int c_col_freezy, c_tex_freezy;
static int c_col_b_freezy, c_tex_b_freezy;
static int c_col_hidden, c_tex_hidden;
static int c_col_b_hidden, c_tex_b_hidden;
struct _popup_menu popup_app_menu[MAX_BENUTZER_POPUP];
int pos_schritt;
int event_loop;
int mytask_id;
int *pipe;
int donotshow_txt[] = {OPT_NOTSHOW_TXT1, OPT_NOTSHOW_TXT2, OPT_NOTSHOW_TXT3, OPT_NOTSHOW_TXT4, OPT_NOTSHOW_TXT5, OPT_NOTSHOW_TXT6, OPT_NOTSHOW_TXT7, OPT_NOTSHOW_TXT8, -1};
unsigned long DoNotShow_adr;
int version;
int app_kat;				/* Kategoria wyswietlanych aplikacji	*/

typedef struct
{
	int version;
	int workxabs;
	int workyabs;
	int font_height;
	int default_font_id;
	int timer_font_id;
} STARTINF;

struct _options options;
struct _options *org_options;
STARTINF    si;


struct
	{
	int nr_def;
	int nr_rsc;
	}kontext_wandeln[]=
	{	DEF_NAME,							1,
		DEF_MEMORY,						2,
		DEF_FENSTER,					3,
		DEF_SEPARATOR,				4,
		DEF_BUTT_SHOW,				5,
		DEF_BUTT_ICON,				7,
		DEF_BUTT_ICON_ALL,		8,
		DEF_BUTT_DEICON,			9,
		DEF_BUTT_FREEZY,			16,
		DEF_BUTT_UNFREEZY,		17,
		DEF_BUTT_KILL,				18,
		DEF_BUTT_SHOW_ALL,		6,
		DEF_BUTT_HIDE,				10,
		DEF_BUTT_HIDE_OTHER,	11,
		DEF_BUTT_QUIT,				19,
		DEF_BUTT_TERMINATE,		18,
		DEF_BUTT_VER_VOR,			13,
		DEF_BUTT_VER_DAU,			14,
		DEF_BUTT_PRIORITY,		15,
		DEF_BUTT_TOP,					12,
		-1, -1};


void Set_colors_text(OBJECT *adr)
	{
	adr[OPT_COL_APP_COL].ob_spec.index = popup_farben[col_app+1].ob_spec.index;
	adr[OPT_COL_ACC_COL].ob_spec.index = popup_farben[col_acc+1].ob_spec.index;
	adr[OPT_COL_SYS_COL].ob_spec.index = popup_farben[col_sys+1].ob_spec.index;
	adr[OPT_COL_SHE_COL].ob_spec.index = popup_farben[col_shell+1].ob_spec.index;
	adr[OPT_COL_CAPSONCO].ob_spec.index = popup_farben[col_t_caps_on+1].ob_spec.index;
	adr[OPT_COL_CAPSOFCO].ob_spec.index = popup_farben[col_t_caps_off+1].ob_spec.index;
	adr[OPT_COL_FREEZYCO].ob_spec.index = popup_farben[col_freezy+1].ob_spec.index;
	adr[OPT_COL_HIDDENCO].ob_spec.index = popup_farben[col_hidden+1].ob_spec.index;

	x_set_ob_text(adr, OPT_COL_APP_TXT, x_get_ob_text(popup_farben, COWHITE+col_app));
	x_set_ob_text(adr, OPT_COL_ACC_TXT, x_get_ob_text(popup_farben, COWHITE+col_acc));
	x_set_ob_text(adr, OPT_COL_SYS_TXT, x_get_ob_text(popup_farben, COWHITE+col_sys));
	x_set_ob_text(adr, OPT_COL_SHE_TXT, x_get_ob_text(popup_farben, COWHITE+col_shell));
	x_set_ob_text(adr, OPT_COL_CAPSONBU, x_get_ob_text(popup_farben, COWHITE+col_t_caps_on));
	x_set_ob_text(adr, OPT_COL_CAPSOFBU, x_get_ob_text(popup_farben, COWHITE+col_t_caps_off));
	x_set_ob_text(adr, OPT_COL_FREEZYBU, x_get_ob_text(popup_farben, COWHITE+col_freezy));
	x_set_ob_text(adr, OPT_COL_HIDDENBU, x_get_ob_text(popup_farben, COWHITE+col_hidden));

	adr[OPT_TEX_APP_BACK].ob_flags |= HIDETREE;				adr[OPT_TEX_APP_CYC].ob_flags |= HIDETREE;
	adr[OPT_TEX_ACC_BACK].ob_flags |= HIDETREE;				adr[OPT_TEX_ACC_CYC].ob_flags |= HIDETREE;
	adr[OPT_TEX_SYS_BACK].ob_flags |= HIDETREE;				adr[OPT_TEX_SYS_CYC].ob_flags |= HIDETREE;
	adr[OPT_TEX_SHE_BACK].ob_flags |= HIDETREE;				adr[OPT_TEX_SHE_CYC].ob_flags |= HIDETREE;
	adr[OPT_TEX_CON_BACK].ob_flags |= HIDETREE;				adr[OPT_TEX_CON_CYC].ob_flags |= HIDETREE;
	adr[OPT_TEX_COFF_BAC].ob_flags |= HIDETREE;				adr[OPT_TEX_COFF_CYC].ob_flags |= HIDETREE;
	adr[OPT_TEX_FREE_BAC].ob_flags |= HIDETREE;				adr[OPT_TEX_FREE_CYC].ob_flags |= HIDETREE;
	adr[OPT_TEX_HIDD_BAC].ob_flags |= HIDETREE;				adr[OPT_TEX_HIDD_CYC].ob_flags |= HIDETREE;
	}


void Set_colors_back(OBJECT *adr)
	{
	adr[OPT_COL_APP_COL].ob_spec.index = popup_farben[col_b_app+1].ob_spec.index;
	adr[OPT_COL_ACC_COL].ob_spec.index = popup_farben[col_b_acc+1].ob_spec.index;
	adr[OPT_COL_SYS_COL].ob_spec.index = popup_farben[col_b_sys+1].ob_spec.index;
	adr[OPT_COL_SHE_COL].ob_spec.index = popup_farben[col_b_shell+1].ob_spec.index;

	adr[OPT_COL_CAPSOFCO].ob_spec.index = popup_farben[col_caps_off+1].ob_spec.index;
	adr[OPT_COL_CAPSONCO].ob_spec.index = popup_farben[col_caps_on+1].ob_spec.index;
	adr[OPT_COL_FREEZYCO].ob_spec.index = popup_farben[col_b_freezy+1].ob_spec.index;
	adr[OPT_COL_HIDDENCO].ob_spec.index = popup_farben[col_b_hidden+1].ob_spec.index;

	x_set_ob_text(adr, OPT_COL_APP_TXT, x_get_ob_text(popup_farben, COWHITE+col_b_app));
	x_set_ob_text(adr, OPT_COL_ACC_TXT, x_get_ob_text(popup_farben, COWHITE+col_b_acc));
	x_set_ob_text(adr, OPT_COL_SYS_TXT, x_get_ob_text(popup_farben, COWHITE+col_b_sys));
	x_set_ob_text(adr, OPT_COL_SHE_TXT, x_get_ob_text(popup_farben, COWHITE+col_b_shell));
	x_set_ob_text(adr, OPT_COL_CAPSONBU, x_get_ob_text(popup_farben, COWHITE+col_caps_on));
	x_set_ob_text(adr, OPT_COL_CAPSOFBU, x_get_ob_text(popup_farben, COWHITE+col_caps_off));
	x_set_ob_text(adr, OPT_COL_FREEZYBU, x_get_ob_text(popup_farben, COWHITE+col_b_freezy));
	x_set_ob_text(adr, OPT_COL_HIDDENBU, x_get_ob_text(popup_farben, COWHITE+col_b_hidden));

	adr[OPT_TEX_APP_BACK].ob_flags &= ~HIDETREE;				adr[OPT_TEX_APP_CYC].ob_flags &= ~HIDETREE;
	adr[OPT_TEX_ACC_BACK].ob_flags &= ~HIDETREE;				adr[OPT_TEX_ACC_CYC].ob_flags &= ~HIDETREE;
	adr[OPT_TEX_SYS_BACK].ob_flags &= ~HIDETREE;				adr[OPT_TEX_SYS_CYC].ob_flags &= ~HIDETREE;
	adr[OPT_TEX_SHE_BACK].ob_flags &= ~HIDETREE;				adr[OPT_TEX_SHE_CYC].ob_flags &= ~HIDETREE;
	adr[OPT_TEX_CON_BACK].ob_flags &= ~HIDETREE;				adr[OPT_TEX_CON_CYC].ob_flags &= ~HIDETREE;
	adr[OPT_TEX_COFF_BAC].ob_flags &= ~HIDETREE;				adr[OPT_TEX_COFF_CYC].ob_flags &= ~HIDETREE;
	adr[OPT_COL_CAPSONBU].ob_flags &= ~HIDETREE;				adr[OPT_COL_CAPSONCY].ob_flags &= ~HIDETREE;
	adr[OPT_COL_CAPSOFBU].ob_flags &= ~HIDETREE;				adr[OPT_COL_CAPSOFCY].ob_flags &= ~HIDETREE;
	adr[OPT_TEX_FREE_BAC].ob_flags &= ~HIDETREE;				adr[OPT_TEX_FREE_CYC].ob_flags &= ~HIDETREE;
	adr[OPT_TEX_HIDD_BAC].ob_flags &= ~HIDETREE;				adr[OPT_TEX_HIDD_CYC].ob_flags &= ~HIDETREE;
	}

void Get_color(OBJECT *adr, int obj, int item)
	{
	switch(obj)
		{
		case OPT_COL_ACC_COL:
		case OPT_COL_ACC_TXT:
			if(adr[OPT_COL_TEXT].ob_state&SELECTED)
				{
				col_acc = item;
				if(item>16)
					col_acc = item-COWHITE;
				c_col_acc=1;
				Set_colors_text(adr);
				}
			else
				{
				col_b_acc = item;
				if(item>16)
					col_b_acc = item-COWHITE;
				c_col_b_acc=1;
				Set_colors_back(adr);
				}
			break;

		case OPT_COL_APP_COL:
		case OPT_COL_APP_TXT:
			if(adr[OPT_COL_TEXT].ob_state&SELECTED)
				{
				col_app = item;
				if(item>16)
					col_app = item-COWHITE;
				c_col_app=1;
				Set_colors_text(adr);
				}
			else
				{
				col_b_app = item;
				if(item>16)
					col_b_app = item-COWHITE;
				c_col_b_app=1;
				Set_colors_back(adr);
				}
			break;

		case OPT_COL_SYS_COL:
		case OPT_COL_SYS_TXT:
			if(adr[OPT_COL_TEXT].ob_state&SELECTED)
				{
				col_sys = item;
				if(item>16)
					col_sys = item-COWHITE;
				c_col_sys=1;
				Set_colors_text(adr);
				}
			else
				{
				col_b_sys = item;
				if(item>16)
					col_b_sys = item-COWHITE;
				c_col_b_sys=1;
				Set_colors_back(adr);
				}
			break;

		case OPT_COL_CAPSONBU:
		case OPT_COL_CAPSONCO:
			if(adr[OPT_COL_TEXT].ob_state&SELECTED)
				{
				col_t_caps_on = item;
				if(item>16)
					col_t_caps_on = item-COWHITE;
				c_col_t_caps_on=1;
				Set_colors_text(adr);
				}
			else
				{
				col_caps_on = item;
				if(item>16)
					col_caps_on = item-COWHITE;
				c_col_caps_on=1;
				Set_colors_back(adr);
				}
			break;

		case OPT_COL_CAPSONCY:
			if(adr[OPT_COL_TEXT].ob_state&SELECTED)
				{
				col_t_caps_on = item;
				if(item>16)
					col_t_caps_on = item-COWHITE;
				c_col_t_caps_on=1;
				Set_colors_text(adr);
				}
			else
				{
				col_caps_on = item;
				if(item>16)
					col_caps_on = item-COWHITE;
				c_col_caps_on=1;
				Set_colors_back(adr);
				}
			break;

		case OPT_COL_CAPSOFBU:
		case OPT_COL_CAPSOFCO:
			if(adr[OPT_COL_TEXT].ob_state&SELECTED)
				{
				col_t_caps_off = item;
				if(item>16)
					col_t_caps_off = item-COWHITE;
				c_col_t_caps_off=1;
				Set_colors_text(adr);
				}
			else
				{
				col_caps_off = item;
				if(item>16)
					col_caps_off = item-COWHITE;
				c_col_caps_off=1;
				Set_colors_back(adr);
				}
			break;

		case OPT_COL_CAPSOFCY:
			if(adr[OPT_COL_TEXT].ob_state&SELECTED)
				{
				col_t_caps_off = item;
				if(item>16)
					col_t_caps_off = item-COWHITE;
				c_col_t_caps_off=1;
				Set_colors_text(adr);
				}
			else
				{
				col_caps_off = item;
				if(item>16)
					col_caps_off = item-COWHITE;
				c_col_caps_off=1;
				Set_colors_back(adr);
				}
			break;

		case OPT_COL_FREEZYBU:
		case OPT_COL_FREEZYCO:
			if(adr[OPT_COL_TEXT].ob_state&SELECTED)
				{
				col_freezy = item;
				if(item>16)
					col_freezy = item-COWHITE;
				c_col_freezy=1;
				Set_colors_text(adr);
				}
			else
				{
				col_b_freezy = item;
				if(item>16)
					col_b_freezy = item-COWHITE;
				c_col_b_freezy=1;
				Set_colors_back(adr);
				}
			break;

		case OPT_COL_FREEZYCY:
			if(adr[OPT_COL_TEXT].ob_state&SELECTED)
				{
				col_freezy = item;
				if(item>16)
					col_freezy = item-COWHITE;
				c_col_freezy=1;
				Set_colors_text(adr);
				}
			else
				{
				col_b_freezy = item;
				if(item>16)
					col_b_freezy = item-COWHITE;
				c_col_b_freezy=1;
				Set_colors_back(adr);
				}
			break;

		case OPT_COL_HIDDENBU:
		case OPT_COL_HIDDENCO:
			if(adr[OPT_COL_TEXT].ob_state&SELECTED)
				{
				col_hidden = item;
				if(item>16)
					col_hidden = item-COWHITE;
				c_col_hidden=1;
				Set_colors_text(adr);
				}
			else
				{
				col_b_hidden = item;
				if(item>16)
					col_b_hidden = item-COWHITE;
				c_col_b_hidden=1;
				Set_colors_back(adr);
				}
			break;

		case OPT_COL_HIDDENCY:
			if(adr[OPT_COL_TEXT].ob_state&SELECTED)
				{
				col_hidden = item;
				if(item>16)
					col_hidden = item-COWHITE;
				c_col_hidden=1;
				Set_colors_text(adr);
				}
			else
				{
				col_b_hidden = item;
				if(item>16)
					col_b_hidden = item-COWHITE;
				c_col_b_hidden=1;
				Set_colors_back(adr);
				}
			break;
		}
	}


void Get_color_cyc(OBJECT *adr, int *col_txt, int *col_back, int *c_col, int *c_b_col)
	{
	if(adr[OPT_COL_TEXT].ob_state&SELECTED)
		{
		(*col_txt)++;
		if((*col_txt)>(CODMAGEN-COWHITE))
			(*col_txt) = 0;
		(*c_col) = 1;
		Set_colors_text(adr);
		}
	else
		{
		(*col_back)++;
		if((*col_back)>(CODMAGEN-COWHITE))
			(*col_back) = 0;
		(*c_b_col) = 1;
		Set_colors_back(adr);
		}
	}





void Lade_optionen(char *name)
	{
	char version[4]={0};
	int h=open(name, O_RDONLY);

	if(h>0)
		{
		Fread(h, 4, &version[0]);
		if(atoi(version)==atoi(INF_VERSION))
			{
			Fread(h,sizeof(STARTINF),&si);

			if (Fread(h,sizeof(struct _options),&options)!=sizeof(struct _options))
				form_alert(1, "[1][Wrong options...][Ok]");
			}
		Fclose(h);
		}

	lang = options.language;
	col_app = options.col_app;
	col_acc = options.col_acc;
	col_sys = options.col_sys;
	col_shell = options.col_shell;
	}

void Save_options(void)
	{
	}




void Get_options(OBJECT *adr)
	{
	if(adr[OPT_SAVELINKS].ob_state&SELECTED)
		options.savelinks = 1;
	else options.savelinks = 0;
	if(adr[OPT_NOQUITALERT].ob_state&SELECTED)
		options.noquitalert = 1;
	else options.noquitalert = 0;
	if(adr[OPT_DHSTCOOKIE].ob_state&SELECTED)
		options.dhstcookie = 1;
	else options.dhstcookie = 0;
	if(adr[OPT_HTML_SEPARAT].ob_state&SELECTED)
		options.html_separat = 1;
	else options.html_separat = 0;
	if(adr[OPT_AUTOHIDE].ob_state&SELECTED)
		options.autohide = 1;
	else options.autohide = 0;
	if(adr[OPT_AVNOACC].ob_state&SELECTED)
		options.avnoacc = 1;
	else options.avnoacc = 0;
	if(adr[OPT_DRIVES].ob_state&SELECTED)
		options.drives = 1;
	else options.drives = 0;
	if(adr[OPT_DOCUMENTS].ob_state&SELECTED)
		options.documents = 1;
	else options.documents = 0;
	if(adr[OPT_TOSMULTISTAR].ob_state&SELECTED)
		options.tosmultistart = 1;
	else options.tosmultistart = 0;
	if(adr[OPT_MAGXFADEOUT].ob_state&SELECTED)
		options.magxfadeout = 1;
	else options.magxfadeout = 0;
	if(adr[OPT_AVIGNORE].ob_state&SELECTED)
		options.avignore = 1;
	else options.avignore = 0;
	if(adr[OPT_AVNOTOS].ob_state&SELECTED)
		options.avnotos = 1;
	else options.avnotos = 0;
	if(adr[OPT_VAPROTOSTAT].ob_state&SELECTED)
		options.vaprotostatus = 1;
	else options.vaprotostatus = 0;

	if(adr[OPT_ACCSYSTRAY].ob_state&SELECTED)
		options.acc_in_system_tray = 1;
	else options.acc_in_system_tray = 0;

	if(adr[OPT_FENSTERNUMME].ob_state&SELECTED)
		options.fenster_name_mit_handler = 1;
	else options.fenster_name_mit_handler = 0;

	if(adr[OPT_STIC_POPUP].ob_state&SELECTED)
		options.stic_popup = 1;
	else options.stic_popup = 0;
	if(adr[OPT_STIC_APPTRAY].ob_state&SELECTED)
		options.stic = 1;
	else options.stic = 0;
		options.stic_app_button = 0;
	if(adr[OPT_STIC_TXTBUTT].ob_state&SELECTED)
		options.stic_app_button = 1;
	if(adr[OPT_STIC_BUTT].ob_state&SELECTED)
		options.stic_app_button = 2;
	if(adr[OPT_TEXT_BUTT].ob_state&SELECTED)
		options.stic_app_button = 0;

	if(adr[OPT_AUTOTOP].ob_state&SELECTED)
		{
		if(adr[OPT_AUTOTOPSMART].ob_state&SELECTED)
			options.autotop = 2;		/* Smart autotop	*/
		else
			options.autotop = 1;		/* Normal autotop	*/
		}
	strcpy(options.time_mode_1, x_get_ob_text(adr, OPT_FORMAT_TIME1));
	strcpy(options.time_mode_2, x_get_ob_text(adr, OPT_FORMAT_TIME2));

	strcpy(options.name, x_get_ob_text(adr, OPT_NAME));
	if(adr[OPT_EXT_RSC_BUTT].ob_state&SELECTED)
		{
		strcpy(options.rsc, ext_rsc);
		start_rsc_no = atoi(x_get_ob_text(adr, OPT_EXT_RSC_NR));
		options.start_rsc_obj = start_rsc_no;
		app_rsc_no = atoi(x_get_ob_text(adr, OPT_EXT_RSC_NR));
		options.app_rsc_obj = app_rsc_no;
		}
	else
		{
		strcpy(options.rsc, "");
		options.start_rsc_obj = -1;
		options.app_rsc_obj = -1;
		}

	if(adr[OPT_ICONTEXT_ST].ob_state&SELECTED)
		options.start_icon_text = 1;
	else
		options.start_icon_text = 0;

	if(c_la==1)			options.language = lang;
	if(c_col_app==1)	options.col_app = col_app;
	if(c_col_acc==1)	options.col_acc = col_acc;
	if(c_col_sys==1)	options.col_sys = col_sys;
	if(c_col_shell==1)	options.col_shell = col_shell;
	if(c_col_b_app==1)	options.col_b_app = col_b_app;
	if(c_col_b_acc==1)	options.col_b_acc = col_b_acc;
	if(c_col_b_sys==1)	options.col_b_sys = col_b_sys;
	if(c_col_b_shell==1)	options.col_b_shell = col_b_shell;
	if(c_col_caps_on==1)	options.col_caps_on = col_caps_on;
	if(c_col_caps_off==1)	options.col_caps_off = col_caps_off;
	if(c_col_t_caps_on==1)	options.col_t_caps_on = col_t_caps_on;
	if(c_col_t_caps_off==1)	options.col_t_caps_off = col_t_caps_off;
	if(c_col_freezy==1)	options.frezzy_txt_color = col_freezy;
	if(c_col_hidden==1)	options.hidden_txt_color = col_hidden;

	if(c_tex_app==1)	options.tex_app = tex_app;
	if(c_tex_acc==1)	options.tex_acc = tex_acc;
	if(c_tex_sys==1)	options.tex_sys = tex_sys;
	if(c_tex_shell==1)	options.tex_shell = tex_shell;
	if(c_tex_caps_on==1)	options.tex_caps_on = tex_caps_on;
	if(c_tex_caps_off==1)	options.tex_caps_off = tex_caps_off;
	if(c_col_b_freezy==1)	options.frezzy_back_color = col_b_freezy;
	if(c_tex_freezy==1)	options.frezzy_effect = tex_freezy;
	if(c_col_b_hidden==1)	options.hidden_back_color = col_b_hidden;
	if(c_tex_hidden==1)	options.hidden_effect = tex_hidden;

	options.loop_time = event_loop;

	memcpy(options.popup_app_menu, popup_app_menu, MAX_BENUTZER_POPUP*sizeof(struct _popup_menu));

	{
	int i;
	for(i=0; i<4; i++)
		{
		if(c_def_klicks[i][1]==1)											/* Lewy przycisk	*/
			options.klicks[i][1] = def_klicks[i][1];
		if(c_def_klicks[i][2]==1)											/* Prawy przycisk	*/
			options.klicks[i][2] = def_klicks[i][2];

		if(c_def_doppel_klicks[i][1]==1)											/* Lewy przycisk	*/
			options.doppel_klicks[i][1] = def_doppel_klicks[i][1];
		if(c_def_doppel_klicks[i][2]==1)											/* Prawy przycisk	*/
			options.doppel_klicks[i][2] = def_doppel_klicks[i][2];
		}
	}


	if(adr[OPT_DOPPEL_TIME].ob_state&SELECTED)
		options.doppelklick_time = 1;
	else options.doppelklick_time = 0;

	SendAV(mytask_id, MYTASK_CHANGED_OPTIONS, x_gem->ap_id, 0, 0, 0, 0, 0, 0);
	if(org_options)
		memcpy(org_options, &options, sizeof(struct _options));
	}


void Get_klicks(OBJECT *adr, int obj, int item, char *def_e, char *c_def_e, char *def_d, char *c_def_d)
	{
	if(item<=0)
		return;
	if(adr[OPT_KLICK].ob_state&SELECTED)
		{
		if(item!=0)
			*def_e = item;
		else
			{
			(*def_e)++;
			if(*def_e>DEF_BUTT_NIX)
				*def_e = DEF_BUTT_MENU;
			}
		*c_def_e = 1;
		x_set_ob_text(adr, obj, x_get_ob_text(popup_maus, *def_e));
		}
	else
		{
		if(item!=0)
			*def_d = item;
		else
			{
			(*def_d)++;
			if(*def_d>DEF_BUTT_NIX)
				*def_d = DEF_BUTT_MENU;
			}
		*c_def_d = 1;
		x_set_ob_text(adr, obj, x_get_ob_text(popup_maus, *def_d));
		}
	}

void Set_klicks(OBJECT *adr)
	{
	int i;
	for(i=0; i<4; i++)
	{
	if(def_klicks[i][1]<=0)
		def_klicks[i][1] = 1;
	if(def_klicks[i][2]<=0)
		def_klicks[i][2] = 1;
	if(def_doppel_klicks[i][1]<=0)
		def_doppel_klicks[i][1] = 1;
	if(def_doppel_klicks[i][2]<=0)
		def_doppel_klicks[i][2] = 1;
	}
	if(adr[OPT_KLICK].ob_state&SELECTED)
		{
		x_set_ob_text(adr, OPT_E_R_B, x_get_ob_text(popup_maus, def_klicks[0][1]));
		x_set_ob_text(adr, OPT_E_L_B, x_get_ob_text(popup_maus, def_klicks[0][2]));
		x_set_ob_text(adr, OPT_S_R_B, x_get_ob_text(popup_maus, def_klicks[1][1]));
		x_set_ob_text(adr, OPT_S_L_B, x_get_ob_text(popup_maus, def_klicks[1][2]));
		x_set_ob_text(adr, OPT_A_R_B, x_get_ob_text(popup_maus, def_klicks[2][1]));
		x_set_ob_text(adr, OPT_A_L_B, x_get_ob_text(popup_maus, def_klicks[2][2]));
		x_set_ob_text(adr, OPT_C_R_B, x_get_ob_text(popup_maus, def_klicks[3][1]));
		x_set_ob_text(adr, OPT_C_L_B, x_get_ob_text(popup_maus, def_klicks[3][2]));
		}
	else
		{
		x_set_ob_text(adr, OPT_E_R_B, x_get_ob_text(popup_maus, def_doppel_klicks[0][1]));
		x_set_ob_text(adr, OPT_E_L_B, x_get_ob_text(popup_maus, def_doppel_klicks[0][2]));
		x_set_ob_text(adr, OPT_S_R_B, x_get_ob_text(popup_maus, def_doppel_klicks[1][1]));
		x_set_ob_text(adr, OPT_S_L_B, x_get_ob_text(popup_maus, def_doppel_klicks[1][2]));
		x_set_ob_text(adr, OPT_A_R_B, x_get_ob_text(popup_maus, def_doppel_klicks[2][1]));
		x_set_ob_text(adr, OPT_A_L_B, x_get_ob_text(popup_maus, def_doppel_klicks[2][2]));
		x_set_ob_text(adr, OPT_C_R_B, x_get_ob_text(popup_maus, def_doppel_klicks[3][1]));
		x_set_ob_text(adr, OPT_C_L_B, x_get_ob_text(popup_maus, def_doppel_klicks[3][2]));
		}
	}


void Set_options(void)
	{
	if(options.savelinks!=0)
		adr_dial[OPT_SAVELINKS].ob_state |= SELECTED;
	if(options.noquitalert!=0)
		adr_dial[OPT_NOQUITALERT].ob_state |= SELECTED;
	if(options.dhstcookie!=0)
		adr_dial[OPT_DHSTCOOKIE].ob_state |= SELECTED;
	if(options.html_separat!=0)
		adr_dial[OPT_HTML_SEPARAT].ob_state |= SELECTED;
	if(options.autohide!=0)
		adr_dial[OPT_AUTOHIDE].ob_state |= SELECTED;
	if(options.avnoacc!=0)
		adr_dial[OPT_AVNOACC].ob_state |= SELECTED;
	if(options.drives!=0)
		adr_dial[OPT_DRIVES].ob_state |= SELECTED;
	if(options.documents!=0)
		adr_dial[OPT_DOCUMENTS].ob_state |= SELECTED;
	if(options.tosmultistart!=0)
		adr_dial[OPT_TOSMULTISTAR].ob_state |= SELECTED;
	if(options.magxfadeout!=0)
		adr_dial[OPT_MAGXFADEOUT].ob_state |= SELECTED;
	if(options.avignore!=0)
		adr_dial[OPT_AVIGNORE].ob_state |= SELECTED;
	if(options.avnotos!=0)
		adr_dial[OPT_AVNOTOS].ob_state |= SELECTED;
	if(options.vaprotostatus!=0)
		adr_dial[OPT_VAPROTOSTAT].ob_state |= SELECTED;
	if(options.stic!=0)
		adr_dial[OPT_STIC_BUTT].ob_state |= SELECTED;
	if(options.acc_in_system_tray!=0)
		adr_dial[OPT_ACCSYSTRAY].ob_state |= SELECTED;

	if(options.stic_popup==1)
		adr_dial[OPT_STIC_POPUP].ob_state |= SELECTED;
	if(options.stic==1)
		adr_dial[OPT_STIC_APPTRAY].ob_state |= SELECTED;

	if(options.fenster_name_mit_handler==1)
		adr_dial[OPT_FENSTERNUMME].ob_state |= SELECTED;
	else adr_dial[OPT_FENSTERNUMME].ob_state &= ~SELECTED;

	adr_dial[OPT_TEXT_BUTT].ob_state &= ~SELECTED;
	adr_dial[OPT_STIC_TXTBUTT].ob_state &= ~SELECTED;
	adr_dial[OPT_STIC_BUTT].ob_state &= ~SELECTED;
	if(options.stic_app_button==0)
		adr_dial[OPT_TEXT_BUTT].ob_state |= SELECTED;
	else if(options.stic_app_button==1)
		adr_dial[OPT_STIC_TXTBUTT].ob_state |= SELECTED;
	else if(options.stic_app_button==2)
		adr_dial[OPT_STIC_BUTT].ob_state |= SELECTED;

	if(options.autotop!=0)
		{
		adr_dial[OPT_AUTOTOP].ob_state |= SELECTED;
		adr_dial[OPT_AUTOTOP_BACK].ob_flags &= ~HIDETREE;
		if(options.autotop==2)
			{
			adr_dial[OPT_AUTOTOPSMART].ob_state |= SELECTED;
			adr_dial[OPT_AUTOTOPNORMA].ob_state &= ~SELECTED;
			}
		else
			{
			adr_dial[OPT_AUTOTOPSMART].ob_state &= ~SELECTED;
			adr_dial[OPT_AUTOTOPNORMA].ob_state |= SELECTED;
			}
		}
	else
		adr_dial[OPT_AUTOTOP_BACK].ob_flags |= HIDETREE;

	memcpy(&def_klicks, options.klicks, 16);
	memcpy(&def_doppel_klicks, options.doppel_klicks, 16);
	Set_klicks(adr_dial);

	x_set_ob_text(adr_dial, OPT_FORMAT_TIME1, options.time_mode_1);
	x_set_ob_text(adr_dial, OPT_FORMAT_TIME2, options.time_mode_2);

	if(options.loop_time!=0)
		event_loop = options.loop_time;
	else
		event_loop = 1000;
	pos_schritt = 1 + (3000/event_loop);
	x_init_slider (adr_dial, -1, -1, OPT_SCHRITT_CUR, OPT_SCHRITT_BAR, 0, 1, 9, pos_schritt, 0);
	sprintf(x_get_ob_text(adr_dial, OPT_SCHRITT), " %.4d ", event_loop);


	if(options.name)
		x_set_ob_text(adr_dial, OPT_NAME, options.name);

	if(options.rsc)
		{
		x_set_ob_text(adr_dial, OPT_EXT_RSC, options.rsc);
		strcpy(ext_rsc, options.rsc);
		}
	start_rsc_no = options.start_rsc_obj;
	itoa(start_rsc_no, x_get_ob_text(adr_dial, OPT_EXT_RSC_NR), 10);

	app_rsc_no = options.app_rsc_obj;
	itoa(app_rsc_no, x_get_ob_text(adr_dial, OPT_EXT_RSC_NRAP), 10);

	if(options.start_icon_text==1)
		adr_dial[OPT_ICONTEXT_ST].ob_state |= SELECTED;
	else adr_dial[OPT_ICONTEXT_ST].ob_state &= ~SELECTED;


	if(options.doppelklick_time==1)
		adr_dial[OPT_DOPPEL_TIME].ob_state |= SELECTED;
	x_set_ob_text(adr_dial, OPT_DOPPEL_TXT, options.doppelklick_time_path);
	if(adr_dial[OPT_DOPPEL_TIME].ob_state&SELECTED)
		adr_dial[OPT_DOPPEL_BACK].ob_flags &= ~HIDETREE;
	else
		adr_dial[OPT_DOPPEL_BACK].ob_flags |= HIDETREE;

	col_app = options.col_app;						col_b_app = options.col_b_app;
	col_acc = options.col_acc;						col_b_acc = options.col_b_acc;
	col_sys = options.col_sys;						col_b_sys = options.col_b_sys;
	col_shell = options.col_shell;				col_b_shell = options.col_b_shell;
	col_caps_on = options.col_caps_on;
	col_caps_off = options.col_caps_off;
	col_t_caps_on = options.col_t_caps_on;
	col_t_caps_off = options.col_t_caps_off;
	col_freezy  = options.frezzy_txt_color;
	col_b_freezy  = options.frezzy_back_color;
	col_hidden  = options.hidden_txt_color;
	col_b_hidden  = options.hidden_back_color;

	tex_app = options.tex_app;
	tex_acc = options.tex_acc;
	tex_sys = options.tex_sys;
	tex_shell = options.tex_shell;
	tex_caps_on = options.tex_caps_on;
	tex_caps_off = options.tex_caps_off;
	tex_freezy = options.frezzy_effect;
	tex_hidden = options.hidden_effect;


	lang = options.language;
	x_set_ob_text(adr_dial, OPT_LANGUAGE_BUT, x_get_ob_text(popup_lang, lang));

	Set_colors_text(adr_dial);

	adr_dial[OPT_COL_APP_COL].ob_x += 3;	adr_dial[OPT_COL_APP_COL].ob_y += 3;
	adr_dial[OPT_COL_ACC_COL].ob_x += 3;	adr_dial[OPT_COL_ACC_COL].ob_y += 3;
	adr_dial[OPT_COL_SYS_COL].ob_x += 3;	adr_dial[OPT_COL_SYS_COL].ob_y += 3;
	adr_dial[OPT_COL_SHE_COL].ob_x += 3;	adr_dial[OPT_COL_SHE_COL].ob_y += 3;

	adr_dial[OPT_COL_CAPSONCO].ob_x += 3;	adr_dial[OPT_COL_CAPSONCO].ob_y += 3;
	adr_dial[OPT_COL_CAPSOFCO].ob_x += 3;	adr_dial[OPT_COL_CAPSOFCO].ob_y += 3;

	adr_dial[OPT_COL_FREEZYCO].ob_x += 3;	adr_dial[OPT_COL_FREEZYCO].ob_y += 3;
	adr_dial[OPT_COL_HIDDENCO].ob_x += 3;	adr_dial[OPT_COL_HIDDENCO].ob_y += 3;

/*****/
	adr_dial[OPT_TEX_APP_COL].ob_spec.index = popup_texture[tex_app].ob_spec.index;
	adr_dial[OPT_TEX_ACC_COL].ob_spec.index = popup_texture[tex_acc].ob_spec.index;
	adr_dial[OPT_TEX_SYS_COL].ob_spec.index = popup_texture[tex_sys].ob_spec.index;
	adr_dial[OPT_TEX_SHE_COL].ob_spec.index = popup_texture[tex_shell].ob_spec.index;

	adr_dial[OPT_TEX_CON_COL].ob_spec.index = popup_texture[tex_caps_on].ob_spec.index;
	adr_dial[OPT_TEX_COFF_COL].ob_spec.index = popup_texture[tex_caps_off].ob_spec.index;

	adr_dial[OPT_TEX_APP_COL].ob_x += 3;	adr_dial[OPT_TEX_APP_COL].ob_y += 3;
	adr_dial[OPT_TEX_ACC_COL].ob_x += 3;	adr_dial[OPT_TEX_ACC_COL].ob_y += 3;
	adr_dial[OPT_TEX_SYS_COL].ob_x += 3;	adr_dial[OPT_TEX_SYS_COL].ob_y += 3;
	adr_dial[OPT_TEX_SHE_COL].ob_x += 3;	adr_dial[OPT_TEX_SHE_COL].ob_y += 3;

	adr_dial[OPT_TEX_CON_COL].ob_x += 3;	adr_dial[OPT_TEX_CON_COL].ob_y += 3;
	adr_dial[OPT_TEX_COFF_COL].ob_x += 3;	adr_dial[OPT_TEX_COFF_COL].ob_y += 3;
	adr_dial[OPT_TEX_FREE_COL].ob_x += 3;	adr_dial[OPT_TEX_FREE_COL].ob_y += 3;
	adr_dial[OPT_TEX_HIDD_COL].ob_x += 3;	adr_dial[OPT_TEX_HIDD_COL].ob_y += 3;

	adr_dial[OPT_TEX_APP_COL].ob_height++;	adr_dial[OPT_TEX_APP_COL].ob_width-=2;
	adr_dial[OPT_TEX_ACC_COL].ob_height++;	adr_dial[OPT_TEX_ACC_COL].ob_width-=2;
	adr_dial[OPT_TEX_SYS_COL].ob_height++;	adr_dial[OPT_TEX_SYS_COL].ob_width-=2;
	adr_dial[OPT_TEX_SHE_COL].ob_height++;	adr_dial[OPT_TEX_SHE_COL].ob_width-=2;

	adr_dial[OPT_TEX_CON_COL].ob_height++;	adr_dial[OPT_TEX_CON_COL].ob_width-=2;
	adr_dial[OPT_TEX_COFF_COL].ob_height++;	adr_dial[OPT_TEX_COFF_COL].ob_width-=2;

	adr_dial[OPT_TEX_FREE_COL].ob_height++;	adr_dial[OPT_TEX_FREE_COL].ob_width-=2;
	adr_dial[OPT_TEX_HIDD_COL].ob_height++;	adr_dial[OPT_TEX_HIDD_COL].ob_width-=2;
	}



short main (int argc, const char *argv[])
{
	if(argc>1)
		{
		if(*(argv[1]) == 'm')
			{
			int n;
			org_options = (void*)atol(argv[2]);
			
			if(org_options!=NULL)
				memcpy(&options, (void*)org_options, sizeof(struct _options));
			n = atoi(argv[3]);
			DoNotShow_adr = atol(argv[4]);
			DoNotShow = (void*)DoNotShow_adr;
			version = atoi(argv[5]);
			if(version<atoi((const char*)INF_VERSION))
				{
				if(x_gem_alert("[1][Das Modul ist zu alt, um|diese Optionen zu bearbeiten!|Trotztdem starten?][Ja][Nein]", 0L)==2)
					exit(0);
				}
			mytask_id = atoi(argv[6]);
 			}
		else if(*(argv[1]) == 'f')
			{
			int i;
			Lade_optionen((char*)argv[2]);
			DoNotShow = malloc(11*sizeof(struct _donotshow));
			DoNotShow->how_many = 11;
			for(i=0; i<11; i++)
				sprintf(DoNotShow[i].name, "        ");
			}
		}
	else
		{
		int i;
		Lade_optionen("mytask.inf");
		DoNotShow = malloc(11*sizeof(struct _donotshow));
		DoNotShow->how_many = 11;
		for(i=0; i<11; i++)
			sprintf(DoNotShow[i].name, "%dpp%d", 11-i, i);
		}


	init_gem ();
	Set_options();
	if (wind_form < 0)
		wind_form = x_open_wind (-1, -1, adr_dial->ob_width - 1, adr_dial->ob_height - 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, CLOSER|NAME|MOVER, "Optionen:", "", 0L, adr_dial, 0L, 0L, 0L, 0L, (FNCP1)close_form, 0L);
	else
		wind_set (x_gem->wind[wind_form].w_hand, WF_TOP, 0, 0, 0, 0);

	do
	{
		x_form_do (0L);

		if (x_gem->event & MU_MESAG)			/* Komunikaty GEM i XGEM...		*/
			gere_messages ();

		if (x_gem->event & MU_BUTTON)			/* Uzycie przycisku myszki...	*/
			gere_fenetres ();
	} while (! quit);

	exit_gem ();

	return (0);
}


void init_gem (void)
{
	x_gem = x_gem_init ("  MyTask Optionen", window, WINDS);	/* initialisation de Xgem */
	if (! x_gem)
		exit (-1);								/* en cas de problŠme on quitte */

	x_rsrc_init (rs_trindex, rs_object, NUM_TREE, NUM_OBS, NUM_CIB);	/* initialiser le ressource de l'application */

	adr_dial = rs_trindex[G_MAIN];
	popup_kat = rs_trindex[G_POPUP_KAT];
	popup_maus= rs_trindex[G_POPUP_MOUSE];
	popup_farben= rs_trindex[G_POPUP_FARBEN];
	popup_texture = rs_trindex[G_POPUP_TEXTU];
	popup_lang = rs_trindex[G_POPUP_LANGUAGE];
	popup_appl = rs_trindex[G_POPUP_APPL];
	popup_appl_ver = rs_trindex[G_POPUP_APPL_VER];
	popup_kontext = rs_trindex[G_POPUP_KONTEXT];

	adr_dial[OPT_BACK_STIC].ob_flags |= HIDETREE;
	adr_dial[OPT_BACK_BEDINUN].ob_flags |= HIDETREE;
	adr_dial[OPT_BACK_MAUS].ob_flags |= HIDETREE;
	adr_dial[OPT_BACK_COLORS].ob_flags |= HIDETREE;
	adr_dial[OPT_BACK_DONOTSH].ob_flags |= HIDETREE;
	adr_dial[OPT_BACK_KONTEXT].ob_flags |= HIDETREE;
	adr_dial[OPT_BACK_SKINS].ob_flags |= HIDETREE;
	x_set_ob_text(adr_dial, OPT_KAT_BUT, x_get_ob_text(popup_kat, 1));

	app_kat = APP_VERSTECKTE;
	if(DoNotShow)
		{
		int i, n;
		for(i=0; donotshow_txt[i]!=-1 ; i++)
			memset(x_get_ob_text(adr_dial, donotshow_txt[i]), ' ', strlen(x_get_ob_text(adr_dial, donotshow_txt[i])));

		for(i=0, n=0; n<DoNotShow->how_many ; n++, i++)
			{
			if(donotshow_txt[i]==-1)
				break;
			x_set_ob_text(adr_dial, donotshow_txt[i], DoNotShow[n].name);
			}
		if(DoNotShow->how_many > (OPT_NOTSHOW_TXT8-OPT_NOTSHOW_TXT1))
			{
			pos_sl1 = 0;
			if(DoNotShow==NULL)
				x_init_slider(adr_dial, OPT_NOTSHOW_UP, OPT_NOTSHOW_DOWN, OPT_NOTSHOW_SLID, OPT_NOTSHOW_BAR,
										0, 8, 30, pos_sl1, 0);
			else
				x_init_slider(adr_dial, OPT_NOTSHOW_UP, OPT_NOTSHOW_DOWN, OPT_NOTSHOW_SLID, OPT_NOTSHOW_BAR,
										0, 8, DoNotShow->how_many, pos_sl1, 0);
			}
		}
	else
		{
		int i;
		for(i=0; donotshow_txt[i]!=-1 ; i++)
			memset(x_get_ob_text(adr_dial, donotshow_txt[i]), ' ', strlen(x_get_ob_text(adr_dial, donotshow_txt[i])));
		}

	{
	int i;
	memcpy(popup_app_menu, options.popup_app_menu, MAX_BENUTZER_POPUP*sizeof(struct _popup_menu));
	for(i=OPT_KONT_L1; i<(OPT_KONT_LAST+1); i++)
		{
		int j;
		for(j=0; kontext_wandeln[j].nr_rsc!=-1; j++)
			{
			if(kontext_wandeln[j].nr_def == popup_app_menu[i-OPT_KONT_L1].aktion)
				break;
			}
		x_set_ob_text(adr_dial, i, x_get_ob_text(popup_kontext, kontext_wandeln[j].nr_rsc));
		}
	}

	graf_mouse (ARROW, 0L);						/* pointeur en forme de flŠche */
}


void exit_gem (void)
{
	x_close_all_winds ();						/* on ferme les fenˆtres ‚ventuellement ouvertes */
	x_rsrc_free (NUM_TREE, NUM_CIB);			/* lib‚rer le ressource int‚gr‚ */
	x_gem_exit ();
	if(pipe)
		free(pipe);
}


	/* g‚rer les ‚v‚nements: */
void gere_messages (void)
{
	switch (x_gem->event_buffer[0])				/* quel type d'‚v‚nement s'est produit ? */
	{
		case AP_TERM:
			quit = 1;
			break;
		case MN_SELECTED:						/* ‚v‚nement de menu */
		break;
		case WM_CLOSED:							/* fermeture de fenˆtre */
			x_close_wind (x_gem->event_wind);	/* les fenˆtres ne se ferment pas automatiquement: c'est mieux pour sauver avant, par exemple ! */
			quit = 1;
		break;

		case MYTASK_SEND_OPTIONS:
			{
			char *data = *(char **)&pipe[3];
			memcpy(&options, data, sizeof(struct _options));
			memcpy(&def_klicks, &options.klicks, 16);
			lang = options.language;
			col_app = options.col_app;
			col_acc = options.col_acc;
			col_sys = options.col_sys;
			col_shell = options.col_shell;
			Set_options();
			break;
			}
	}
}


	/* g‚rer le menu: */
void gere_menu (void)
{
}


void SwapDoNotShow(struct _donotshow *in, struct _donotshow *out)
	{
	struct _donotshow tmp;
	memcpy(&tmp, in, sizeof(struct _donotshow));
	memcpy(in, out, sizeof(struct _donotshow));
	memcpy(out, &tmp, sizeof(struct _donotshow));
	}

void sort_donotshow(void)
	{
	struct _donotshow *tmp;
	int min=256,i;
	int last=0;
	int h = DoNotShow->how_many;

	tmp = malloc(DoNotShow->how_many*sizeof(struct _donotshow));

	for(i=1; i<DoNotShow->how_many; i++)
		{
		if(stricmp(DoNotShow[i-1].name, DoNotShow[i].name)>0)
			{
			SwapDoNotShow(&DoNotShow[i-1], &DoNotShow[i]);
			DoNotShow->how_many = h;
			i=1;
			}
		}
	for(i=1; i<DoNotShow->how_many; i++)
		{
		if(stricmp(DoNotShow[i-1].name, DoNotShow[i].name)>0)
			{
			SwapDoNotShow(&DoNotShow[i-1], &DoNotShow[i]);
			DoNotShow->how_many = h;
			i=1;
			}
		}
	}


void draw_applications(void)
	{
	int i,n;
	OBJECT *adr;
	WIND_LIST *wind;
	wind = &x_gem->wind[wind_form];
	adr = wind->w_dial.d_addr;				/* r‚cup‚rer l'adresse du formulaire */
	for(i=0, n=pos_sl1; donotshow_txt[i]!=-1 ; n++, i++)
		{
		if(donotshow_txt[i]==-1)
			break;
		x_set_ob_text(adr, donotshow_txt[i], DoNotShow[n].name);
		}
	x_objc_draw (wind_form, adr, OPT_APP_BACK_1, MAX_DEPTH, &x_gem->desk_size);
	}




	/* g‚rer les clics dans les fenˆtres: */
void gere_fenetres (void)
{
	OBJECT *adr ,*adr1;
	WIND_LIST *wind;
	int item, obj, of_x, of_y;

	wind = &x_gem->wind[wind_form];

	if (x_gem->event_wind < 0)					/* pas en fenˆtre ? on sort ! */
		return;

	if (x_gem->event_wind == wind_form)			/* seul cette fenˆtre nous int‚resse */
	{
		adr = wind->w_dial.d_addr;				/* r‚cup‚rer l'adresse du formulaire */
		obj = *x_gem->object;

		of_x = adr->ob_x + adr[obj].ob_x + adr[OPT_APP_BACK_1].ob_x;
		of_y = adr->ob_y + adr[obj].ob_y + adr[OPT_APP_BACK_1].ob_y - adr[obj].ob_height;

		if(obj>=OPT_NOTSHOW_TXT1 && obj<=OPT_NOTSHOW_TXT8)
			{
			int how = DoNotShow->how_many-1;
			of_y += adr[OPT_APP_BACK_1].ob_y;
			x_pop_up (of_x, of_y, popup_appl_ver, (void*)&adr1, (short*)&item);
			if(item==1)				/* Wywalic z tej listy	*/
				{
				int i,j;
				obj -= OPT_NOTSHOW_TXT1;
				for(i=0,j=0; i<DoNotShow->how_many; i++)
					{
					if(i!=obj)
						{			
						memcpy(&DoNotShow[j], &DoNotShow[i+pos_sl1], sizeof(struct _donotshow));
						j++;
						}
					else
						printf("Kasuje aplikacje: %s\n", DoNotShow[i+pos_sl1].name);
					}
				}
			DoNotShow->how_many = how;
			x_init_slider(adr_dial, OPT_NOTSHOW_UP, OPT_NOTSHOW_DOWN, OPT_NOTSHOW_SLID, OPT_NOTSHOW_BAR, 0, 8, DoNotShow->how_many, pos_sl1, 0);
			x_init_slider(adr, OPT_NOTSHOW_UP, OPT_NOTSHOW_DOWN, OPT_NOTSHOW_SLID, OPT_NOTSHOW_BAR, 0, 8, DoNotShow->how_many, pos_sl1, 0);
			draw_applications();
			}

		if(obj>=OPT_KONT_L1 && obj<=OPT_KONT_LAST)
			{
			int i;
			x_pop_up (of_x, of_y, popup_kontext, (void*)&adr1, (short*)&item);
			x_set_ob_text(adr, obj, x_get_ob_text(popup_kontext, item));
			adr[obj].ob_state &= ~SELECTED;
			x_objc_draw (wind_form, adr, OPT_KONT_BACK, MAX_DEPTH, &x_gem->desk_size);
			for(i=0; kontext_wandeln[i].nr_rsc!=-1; i++)
				{
				if(kontext_wandeln[i].nr_rsc==item)
					{
					strncpy(popup_app_menu[obj-OPT_KONT_L1].text, x_get_ob_text(popup_kontext,obj), min(strlen(x_get_ob_text(popup_kontext,obj)),strlen(popup_app_menu[obj-OPT_KONT_L1].text)));
					popup_app_menu[obj-OPT_KONT_L1].aktion = kontext_wandeln[i].nr_def;
					}
				}
			}

		switch (obj)
		{
		case OPT_SCHRITT_CUR:
		case OPT_SCHRITT_BAR:
			x_use_slider (adr, obj, -1, -1, OPT_SCHRITT_CUR, OPT_SCHRITT_BAR, 0, 1, 9, &pos_schritt, 0L, 0L);
			pos_schritt++;
			event_loop = 3000 / (10-pos_schritt);
			sprintf(x_get_ob_text(adr, OPT_SCHRITT), " %.4d ", event_loop);
			x_objc_draw (wind_form, adr, 0, MAX_DEPTH, &x_gem->desk_size);
			break;

		case OPT_COL_BACK:
		case OPT_COL_TEXT:
			if(obj==OPT_COL_BACK)
				{
				adr[OPT_COL_TEXT].ob_state &= ~SELECTED;
				Set_colors_back(adr);
				}
			else
				{
				adr[OPT_COL_BACK].ob_state &= ~SELECTED;
				Set_colors_text(adr);
				}
			x_objc_draw (wind_form, adr, OPT_BACK_COLORS, MAX_DEPTH, &x_gem->desk_size);
			break;


		case OPT_VER_SORT:
			adr[obj].ob_state &= ~SELECTED;
			sort_donotshow();
			draw_applications();
			x_objc_draw (wind_form, adr, obj, MAX_DEPTH, &x_gem->desk_size);
			break;

		case OPT_KAT_APP_BUT:
			adr[obj].ob_state &= ~SELECTED;
			x_pop_up (of_x, of_y, popup_appl, (void*)&adr1, (short*)&app_kat);
			if(app_kat>0)
				{
				if(app_kat==APP_VERSTECKTE)				/* Versteckte	*/
					{
					adr[OPT_APP_BACK_2].ob_flags |= HIDETREE;
					}
				else if(app_kat==APP_ALIASES)
					{
					adr[OPT_APP_BACK_2].ob_flags &= ~HIDETREE;
					}
				x_objc_draw (wind_form, adr, OPT_BACK_DONOTSH, MAX_DEPTH, &x_gem->desk_size);
				}
			break;
		case OPT_NOTSHOW_UP:
		case OPT_NOTSHOW_DOWN:
		case OPT_NOTSHOW_BAR:
		case OPT_NOTSHOW_SLID:
			if(DoNotShow)
				x_use_slider (adr, obj, OPT_NOTSHOW_UP, OPT_NOTSHOW_DOWN, OPT_NOTSHOW_SLID, OPT_NOTSHOW_BAR, 1, 8, DoNotShow->how_many, &pos_sl1, 0L, draw_applications);
			else
				x_use_slider (adr, obj, OPT_NOTSHOW_UP, OPT_NOTSHOW_DOWN, OPT_NOTSHOW_SLID, OPT_NOTSHOW_BAR, 1, 8, 30, &pos_sl1, 0L, draw_applications);
			break;
		case OPT_OK:
		case OPT_SETZE:
			Get_options(adr);
			if(*x_gem->object==OPT_OK)
				quit = 1;
/*			if(*x_gem->object==OPT_SAVE)
				Save_options();	*/
			adr[*x_gem->object].ob_state &= ~SELECTED;
			evnt_timer(100);
			x_objc_draw (wind_form, adr, obj, MAX_DEPTH, &x_gem->desk_size);
			break;

		case OPT_DOPPEL_TIME:
			{
			GRECT rd;
				rd.g_x = adr->ob_x + adr[OPT_BACK_BEDINUN].ob_x + adr[OPT_DOPPEL_BACK].ob_x-4;
				rd.g_y = adr->ob_y + adr[OPT_BACK_BEDINUN].ob_y + adr[OPT_DOPPEL_BACK].ob_y-4;
				rd.g_w = adr[OPT_DOPPEL_BACK].ob_width+6;
				rd.g_h = adr[OPT_DOPPEL_BACK].ob_height+6;
			if(adr[OPT_DOPPEL_TIME].ob_state&SELECTED)
				adr[OPT_DOPPEL_BACK].ob_flags &= ~HIDETREE;
			else
				adr[OPT_DOPPEL_BACK].ob_flags |= HIDETREE;
			x_objc_draw (wind_form, adr, OPT_BACK_BEDINUN, MAX_DEPTH, &rd);
			break;
			}
		case OPT_DOPPEL_TXT:
			{
			char cos[1000];
			memset(cos, ' ', 1000);
			if(x_file_select(1 ,"Was soll ich starten", "*.*", "", cos)==1)
				strcpy(options.doppelklick_time_path, cos);

			if(strlen(cos)>30)
				sprintf(cos, "%.17s...%s", options.doppelklick_time_path, &options.doppelklick_time_path[strlen(options.doppelklick_time_path)-10]);
			x_set_ob_text(adr, OPT_DOPPEL_TXT, cos);
			x_objc_draw (wind_form, adr, OPT_DOPPEL_BACK, MAX_DEPTH, &x_gem->desk_size);
			}
			break;

		case OPT_AUTOTOP:
			if(adr[OPT_AUTOTOP].ob_state&SELECTED)
				{
				adr[OPT_AUTOTOP_BACK].ob_flags &= ~HIDETREE;
				x_objc_draw (wind_form, adr, OPT_AUTOTOP_BACK, MAX_DEPTH, &x_gem->desk_size);
				}
			else
				{
				GRECT rd;
				rd.g_x = adr->ob_x + adr[OPT_BACK_BEDINUN].ob_x + adr[OPT_AUTOTOP_BACK].ob_x;
				rd.g_y = adr->ob_y + adr[OPT_BACK_BEDINUN].ob_y + adr[OPT_AUTOTOP_BACK].ob_y;
				rd.g_w = adr[OPT_AUTOTOP_BACK].ob_width;
				rd.g_h = adr[OPT_AUTOTOP_BACK].ob_height;
				adr[OPT_AUTOTOP_BACK].ob_flags |= HIDETREE;
				x_objc_draw (wind_form, adr, 0, MAX_DEPTH, &rd);
				}

			break;

		case OPT_KAT_BUT:
			x_pop_up (adr->ob_x + adr[OPT_KAT_BUT].ob_x + 2, adr->ob_y + adr[OPT_KAT_BUT].ob_y + 2, popup_kat, (void*)&adr1, (short*)&item);
			if(item>0)
				{
				adr[OPT_BACK_ALLGEM].ob_flags |= HIDETREE;
				adr[OPT_BACK_STIC].ob_flags |= HIDETREE;
				adr[OPT_BACK_BEDINUN].ob_flags |= HIDETREE;
				adr[OPT_BACK_MAUS].ob_flags |= HIDETREE;
				adr[OPT_BACK_COLORS].ob_flags |= HIDETREE;
				adr[OPT_BACK_DONOTSH].ob_flags |= HIDETREE;
				adr[OPT_BACK_KONTEXT].ob_flags |= HIDETREE;
				adr[OPT_BACK_SKINS].ob_flags |= HIDETREE;
				switch(item)
					{
					case 1:
						adr[OPT_BACK_ALLGEM].ob_flags &= ~HIDETREE;
						break;
					case 2:
						adr[OPT_BACK_BEDINUN].ob_flags &= ~HIDETREE;
						break;
					case 3:
						adr[OPT_BACK_MAUS].ob_flags &= ~HIDETREE;
						break;
					case 4:
						adr[OPT_BACK_COLORS].ob_flags &= ~HIDETREE;
						break;
					case 5:
						adr[OPT_BACK_STIC].ob_flags &= ~HIDETREE;
						break;
					case 6:
						adr[OPT_BACK_DONOTSH].ob_flags &= ~HIDETREE;
						break;
					case 7:
						adr[OPT_BACK_KONTEXT].ob_flags &= ~HIDETREE;
						break;
					case 8:
						adr[OPT_BACK_SKINS].ob_flags &= ~HIDETREE;
						break;
					}
				x_set_ob_text(adr, OPT_KAT_BUT, x_get_ob_text(popup_kat, item));
				}
			adr[OPT_KAT_BUT].ob_state &= ~SELECTED;
			x_objc_draw (wind_form, adr, 0, MAX_DEPTH, &x_gem->desk_size);
			break;

		case OPT_KAT_CYC:
			if(!(adr[OPT_BACK_ALLGEM].ob_flags&HIDETREE))
				{
				adr[OPT_BACK_ALLGEM].ob_flags |= HIDETREE;
				adr[OPT_BACK_BEDINUN].ob_flags &= ~HIDETREE;
				x_set_ob_text(adr, OPT_KAT_BUT, x_get_ob_text(popup_kat, 2));
				}
			else if(!(adr[OPT_BACK_BEDINUN].ob_flags&HIDETREE))
				{
				adr[OPT_BACK_BEDINUN].ob_flags |= HIDETREE;
				adr[OPT_BACK_MAUS].ob_flags &= ~HIDETREE;
				x_set_ob_text(adr, OPT_KAT_BUT, x_get_ob_text(popup_kat, 3));
				}
			else if(!(adr[OPT_BACK_MAUS].ob_flags&HIDETREE))
				{
				adr[OPT_BACK_MAUS].ob_flags |= HIDETREE;
				adr[OPT_BACK_COLORS].ob_flags &= ~HIDETREE;
				x_set_ob_text(adr, OPT_KAT_BUT, x_get_ob_text(popup_kat, 4));
				}
			else if(!(adr[OPT_BACK_COLORS].ob_flags&HIDETREE))
				{
				adr[OPT_BACK_COLORS].ob_flags |= HIDETREE;
				adr[OPT_BACK_STIC].ob_flags &= ~HIDETREE;
				x_set_ob_text(adr, OPT_KAT_BUT, x_get_ob_text(popup_kat, 5));
				}
			else if(!(adr[OPT_BACK_STIC].ob_flags&HIDETREE))
				{
				adr[OPT_BACK_STIC].ob_flags |= HIDETREE;
				adr[OPT_BACK_DONOTSH].ob_flags &= ~HIDETREE;
				x_set_ob_text(adr, OPT_KAT_BUT, x_get_ob_text(popup_kat, 6));
				}
			else if(!(adr[OPT_BACK_DONOTSH].ob_flags&HIDETREE))
				{
				adr[OPT_BACK_DONOTSH].ob_flags |= HIDETREE;
				adr[OPT_BACK_KONTEXT].ob_flags &= ~HIDETREE;
				x_set_ob_text(adr, OPT_KAT_BUT, x_get_ob_text(popup_kat, 7));
				}
			else if(!(adr[OPT_BACK_KONTEXT].ob_flags&HIDETREE))
				{
				adr[OPT_BACK_KONTEXT].ob_flags |= HIDETREE;
				adr[OPT_BACK_SKINS].ob_flags &= ~HIDETREE;
				x_set_ob_text(adr, OPT_KAT_BUT, x_get_ob_text(popup_kat, 8));
				}
			else if(!(adr[OPT_BACK_SKINS].ob_flags&HIDETREE))
				{
				adr[OPT_BACK_SKINS].ob_flags |= HIDETREE;
				adr[OPT_BACK_ALLGEM].ob_flags &= ~HIDETREE;
				x_set_ob_text(adr, OPT_KAT_BUT, x_get_ob_text(popup_kat, 1));
				}
			adr[OPT_KAT_CYC].ob_state &= ~SELECTED;
			x_objc_draw (wind_form, adr, 0, MAX_DEPTH, &x_gem->desk_size);
			break;


		case OPT_COL_APP_TXT:
		case OPT_COL_APP_COL:
			x_pop_up (of_x, of_y, popup_farben, (void*)&adr1, (short*)&item);
			adr[obj].ob_state &= ~SELECTED;
			if(item>0)
				Get_color(adr, obj, item);
			x_objc_draw (wind_form, adr, obj, MAX_DEPTH, &x_gem->desk_size);
			break;
		case OPT_COL_APP_CYC:
			adr[obj].ob_state &= ~SELECTED;
			Get_color_cyc(adr, &col_app, &col_b_app, &c_col_app, &c_col_b_app);
			x_objc_draw (wind_form, adr, obj, MAX_DEPTH, &x_gem->desk_size);
			x_objc_draw (wind_form, adr, OPT_COL_APP_TXT, MAX_DEPTH, &x_gem->desk_size);
			break;

		case OPT_COL_ACC_TXT:
		case OPT_COL_ACC_COL:
			x_pop_up (of_x, of_y, popup_farben, (void*)&adr1, (short*)&item);
			adr[obj].ob_state &= ~SELECTED;
			if(item>0)
				Get_color(adr, obj, item);
			x_objc_draw (wind_form, adr, obj, MAX_DEPTH, &x_gem->desk_size);
			break;
		case OPT_COL_ACC_CYC:
			adr[obj].ob_state &= ~SELECTED;
			Get_color_cyc(adr, &col_acc, &col_b_acc, &c_col_acc, &c_col_b_acc);
			x_objc_draw (wind_form, adr, obj, MAX_DEPTH, &x_gem->desk_size);
			x_objc_draw (wind_form, adr, OPT_COL_ACC_TXT, MAX_DEPTH, &x_gem->desk_size);
			break;
		
		case OPT_COL_SYS_TXT:
		case OPT_COL_SYS_COL:
			x_pop_up (of_x, of_y, popup_farben, (void*)&adr1, (short*)&item);
			adr[obj].ob_state &= ~SELECTED;
			if(item>0)
				Get_color(adr, obj, item);
			x_objc_draw (wind_form, adr, obj, MAX_DEPTH, &x_gem->desk_size);
			break;
		case OPT_COL_SYS_CYC:
			adr[obj].ob_state &= ~SELECTED;
			Get_color_cyc(adr, &col_sys, &col_b_sys, &c_col_sys, &c_col_b_sys);
			x_objc_draw (wind_form, adr, obj, MAX_DEPTH, &x_gem->desk_size);
			x_objc_draw (wind_form, adr, OPT_COL_SYS_TXT, MAX_DEPTH, &x_gem->desk_size);
			break;

		case OPT_COL_SHE_TXT:
		case OPT_COL_SHE_COL:
			x_pop_up (of_x, of_y, popup_farben, (void*)&adr1, (short*)&item);
			adr[obj].ob_state &= ~SELECTED;
			if(item>0)
				Get_color(adr, obj, item);
			x_objc_draw (wind_form, adr, obj, MAX_DEPTH, &x_gem->desk_size);
			break;
		case OPT_COL_SHE_CYC:
			adr[obj].ob_state &= ~SELECTED;
			Get_color_cyc(adr, &col_shell, &col_b_shell, &c_col_shell, &c_col_b_shell);
			x_objc_draw (wind_form, adr, obj, MAX_DEPTH, &x_gem->desk_size);
			x_objc_draw (wind_form, adr, OPT_COL_SHE_TXT, MAX_DEPTH, &x_gem->desk_size);
			break;


		case OPT_COL_CAPSONCO:
		case OPT_COL_CAPSONBU:
			x_pop_up (of_x, of_y, popup_farben, (void*)&adr1, (short*)&item);
			adr[obj].ob_state &= ~SELECTED;
			if(item>0)
				Get_color(adr, obj, item);
			x_objc_draw (wind_form, adr, obj, MAX_DEPTH, &x_gem->desk_size);
			break;
		case OPT_COL_CAPSONCY:
			adr[obj].ob_state &= ~SELECTED;
			Get_color_cyc(adr, &col_t_caps_on, &col_caps_on, &c_col_t_caps_on, &c_col_caps_on);
			x_objc_draw (wind_form, adr, obj, MAX_DEPTH, &x_gem->desk_size);
			x_objc_draw (wind_form, adr, OPT_COL_CAPSONBU, MAX_DEPTH, &x_gem->desk_size);
			break;


		case OPT_COL_CAPSOFCO:
		case OPT_COL_CAPSOFBU:
			x_pop_up (of_x, of_y, popup_farben, (void*)&adr1, (short*)&item);
			adr[obj].ob_state &= ~SELECTED;
			if(item>0)
				Get_color(adr, obj, item);
			x_objc_draw (wind_form, adr, obj, MAX_DEPTH, &x_gem->desk_size);
			break;
		case OPT_COL_CAPSOFCY:
			adr[obj].ob_state &= ~SELECTED;
			Get_color_cyc(adr, &col_t_caps_off, &col_caps_off, &c_col_t_caps_off, &c_col_caps_off);
			x_objc_draw (wind_form, adr, obj, MAX_DEPTH, &x_gem->desk_size);
			x_objc_draw (wind_form, adr, OPT_COL_CAPSOFBU, MAX_DEPTH, &x_gem->desk_size);
			break;

		case OPT_COL_FREEZYCO:
		case OPT_COL_FREEZYBU:
			x_pop_up (of_x, of_y, popup_farben, (void*)&adr1, (short*)&item);
			adr[obj].ob_state &= ~SELECTED;
			if(item>0)
				Get_color(adr, obj, item);
			x_objc_draw (wind_form, adr, obj, MAX_DEPTH, &x_gem->desk_size);
			break;
		case OPT_COL_FREEZYCY:
			adr[obj].ob_state &= ~SELECTED;
			Get_color_cyc(adr, &col_freezy, &col_b_freezy, &c_col_freezy, &c_col_b_freezy);
			x_objc_draw (wind_form, adr, obj, MAX_DEPTH, &x_gem->desk_size);
			x_objc_draw (wind_form, adr, OPT_COL_FREEZYBU, MAX_DEPTH, &x_gem->desk_size);
			break;

		case OPT_COL_HIDDENCO:
		case OPT_COL_HIDDENBU:
			x_pop_up (of_x, of_y, popup_farben, (void*)&adr1, (short*)&item);
			adr[obj].ob_state &= ~SELECTED;
			if(item>0)
				Get_color(adr, obj, item);
			x_objc_draw (wind_form, adr, obj, MAX_DEPTH, &x_gem->desk_size);
			break;
		case OPT_COL_HIDDENCY:
			adr[obj].ob_state &= ~SELECTED;
			Get_color_cyc(adr, &col_hidden, &col_b_hidden, &c_col_hidden, &c_col_b_hidden);
			x_objc_draw (wind_form, adr, obj, MAX_DEPTH, &x_gem->desk_size);
			x_objc_draw (wind_form, adr, OPT_COL_FREEZYBU, MAX_DEPTH, &x_gem->desk_size);
			break;


/* TEXTURE */
		case OPT_TEX_APP_COL:
			of_x += adr[OPT_TEX_APP_BACK].ob_x;
			of_y += adr[OPT_TEX_APP_BACK].ob_y;
			x_pop_up (of_x, of_y, popup_texture, (void*)&adr1, (short*)&item);
			adr[obj].ob_state &= ~SELECTED;
			if(item>0)
				{
				tex_app = item;
				c_tex_app=1;
				}
			adr[OPT_TEX_APP_COL].ob_spec.index = popup_texture[tex_app].ob_spec.index;
			x_objc_draw (wind_form, adr, OPT_TEX_APP_BACK, MAX_DEPTH, &x_gem->desk_size);
			break;
		case OPT_TEX_APP_CYC:
			adr[obj].ob_state &= ~SELECTED;
			tex_app++;
			if(tex_app>8)
				tex_app = 1;
			c_tex_app=1;
			adr[OPT_TEX_APP_COL].ob_spec.index = popup_texture[tex_app].ob_spec.index;
			x_objc_draw (wind_form, adr, OPT_TEX_APP_BACK, MAX_DEPTH, &x_gem->desk_size);
			x_objc_draw (wind_form, adr, OPT_TEX_APP_CYC, MAX_DEPTH, &x_gem->desk_size);
			break;

		case OPT_TEX_ACC_COL:
			of_x += adr[OPT_TEX_ACC_BACK].ob_x;
			of_y += adr[OPT_TEX_ACC_BACK].ob_y;
			x_pop_up (of_x, of_y, popup_texture, (void*)&adr1, (short*)&item);
			adr[obj].ob_state &= ~SELECTED;
			if(item>0)
				{
				tex_acc = item;
				c_tex_acc=1;
				}
			adr[OPT_TEX_ACC_COL].ob_spec.index = popup_texture[tex_acc].ob_spec.index;
			x_objc_draw (wind_form, adr, OPT_TEX_ACC_BACK, MAX_DEPTH, &x_gem->desk_size);
			break;
		case OPT_TEX_ACC_CYC:
			adr[obj].ob_state &= ~SELECTED;
			tex_acc++;
			if(tex_acc>8)
				tex_acc = 1;
			c_tex_acc=1;
			adr[OPT_TEX_ACC_COL].ob_spec.index = popup_texture[tex_acc].ob_spec.index;
			x_objc_draw (wind_form, adr, OPT_TEX_ACC_BACK, MAX_DEPTH, &x_gem->desk_size);
			x_objc_draw (wind_form, adr, OPT_TEX_ACC_CYC, MAX_DEPTH, &x_gem->desk_size);
			break;

		case OPT_TEX_SYS_COL:
			of_x += adr[OPT_TEX_SYS_BACK].ob_x;
			of_y += adr[OPT_TEX_SYS_BACK].ob_y;
			x_pop_up (of_x, of_y, popup_texture, (void*)&adr1, (short*)&item);
			adr[obj].ob_state &= ~SELECTED;
			if(item>0)
				{
				tex_sys = item;
				c_tex_sys=1;
				}
			adr[OPT_TEX_SYS_COL].ob_spec.index = popup_texture[tex_sys].ob_spec.index;
			x_objc_draw (wind_form, adr, OPT_TEX_SYS_BACK, MAX_DEPTH, &x_gem->desk_size);
			break;
		case OPT_TEX_SYS_CYC:
			adr[obj].ob_state &= ~SELECTED;
			tex_sys++;
			if(tex_sys>8)
				tex_sys = 1;
			c_tex_sys=1;
			adr[OPT_TEX_SYS_COL].ob_spec.index = popup_texture[tex_sys].ob_spec.index;
			x_objc_draw (wind_form, adr, OPT_TEX_SYS_BACK, MAX_DEPTH, &x_gem->desk_size);
			x_objc_draw (wind_form, adr, OPT_TEX_SYS_CYC, MAX_DEPTH, &x_gem->desk_size);
			break;

		case OPT_TEX_SHE_COL:
			of_x += adr[OPT_TEX_SHE_BACK].ob_x;
			of_y += adr[OPT_TEX_SHE_BACK].ob_y;
			x_pop_up (of_x, of_y, popup_texture, (void*)&adr1, (short*)&item);
			adr[obj].ob_state &= ~SELECTED;
			if(item>0)
				{
				tex_shell = item;
				c_tex_shell=1;
				}
			adr[OPT_TEX_SHE_COL].ob_spec.index = popup_texture[tex_shell].ob_spec.index;
			x_objc_draw (wind_form, adr, OPT_TEX_SHE_BACK, MAX_DEPTH, &x_gem->desk_size);
			break;
		case OPT_TEX_SHE_CYC:
			adr[obj].ob_state &= ~SELECTED;
			tex_shell++;
			if(tex_shell>8)
				tex_shell = 1;
			c_tex_shell=1;
			adr[OPT_TEX_SHE_COL].ob_spec.index = popup_texture[tex_shell].ob_spec.index;
			x_objc_draw (wind_form, adr, OPT_TEX_SHE_BACK, MAX_DEPTH, &x_gem->desk_size);
			x_objc_draw (wind_form, adr, OPT_TEX_SHE_CYC, MAX_DEPTH, &x_gem->desk_size);
			break;

		case OPT_TEX_CON_COL:
			of_x += adr[OPT_TEX_CON_BACK].ob_x;
			of_y += adr[OPT_TEX_CON_BACK].ob_y;
			x_pop_up (of_x, of_y, popup_texture, (void*)&adr1, (short*)&item);
			adr[obj].ob_state &= ~SELECTED;
			if(item>0)
				{
				tex_caps_on = item;
				c_tex_caps_on=1;
				}
			adr[OPT_TEX_CON_COL].ob_spec.index = popup_texture[tex_caps_on].ob_spec.index;
			x_objc_draw (wind_form, adr, OPT_TEX_CON_BACK, MAX_DEPTH, &x_gem->desk_size);
			break;
		case OPT_TEX_CON_CYC:
			adr[obj].ob_state &= ~SELECTED;
			tex_caps_on++;
			if(tex_caps_on>8)
				tex_caps_on = 1;
			c_tex_caps_on=1;
			adr[OPT_TEX_CON_COL].ob_spec.index = popup_texture[tex_caps_on].ob_spec.index;
			x_objc_draw (wind_form, adr, OPT_TEX_CON_BACK, MAX_DEPTH, &x_gem->desk_size);
			x_objc_draw (wind_form, adr, OPT_TEX_CON_CYC, MAX_DEPTH, &x_gem->desk_size);
			break;

		case OPT_TEX_COFF_COL:
			of_x += adr[OPT_TEX_COFF_BAC].ob_x;
			of_y += adr[OPT_TEX_COFF_BAC].ob_y;
			x_pop_up (of_x, of_y, popup_texture, (void*)&adr1, (short*)&item);
			adr[obj].ob_state &= ~SELECTED;
			if(item>0)
				{
				tex_caps_off = item;
				c_tex_caps_off=1;
				}
			adr[OPT_TEX_COFF_COL].ob_spec.index = popup_texture[tex_caps_off].ob_spec.index;
			x_objc_draw (wind_form, adr, OPT_TEX_COFF_BAC, MAX_DEPTH, &x_gem->desk_size);
			break;
		case OPT_TEX_COFF_CYC:
			adr[obj].ob_state &= ~SELECTED;
			tex_caps_off++;
			if(tex_caps_off>8)
				tex_caps_off = 1;
			c_tex_caps_off=1;
			adr[OPT_TEX_COFF_COL].ob_spec.index = popup_texture[tex_caps_off].ob_spec.index;
			x_objc_draw (wind_form, adr, OPT_TEX_COFF_BAC, MAX_DEPTH, &x_gem->desk_size);
			x_objc_draw (wind_form, adr, OPT_TEX_COFF_CYC, MAX_DEPTH, &x_gem->desk_size);
			break;

		case OPT_TEX_FREE_COL:
			of_x += adr[OPT_TEX_FREE_BAC].ob_x;
			of_y += adr[OPT_TEX_FREE_BAC].ob_y;
			x_pop_up (of_x, of_y, popup_texture, (void*)&adr1, (short*)&item);
			adr[obj].ob_state &= ~SELECTED;
			if(item>0)
				{
				tex_freezy = item;
				c_tex_b_freezy=1;
				}
			adr[OPT_TEX_FREE_COL].ob_spec.index = popup_texture[tex_freezy].ob_spec.index;
			x_objc_draw (wind_form, adr, OPT_TEX_FREE_BAC, MAX_DEPTH, &x_gem->desk_size);
			break;
		case OPT_TEX_FREE_CYC:
			adr[obj].ob_state &= ~SELECTED;
			tex_freezy++;
			if(tex_freezy>8)
				tex_freezy = 1;
			c_tex_b_freezy=1;
			adr[OPT_TEX_FREE_COL].ob_spec.index = popup_texture[tex_freezy].ob_spec.index;
			x_objc_draw (wind_form, adr, OPT_TEX_FREE_BAC, MAX_DEPTH, &x_gem->desk_size);
			x_objc_draw (wind_form, adr, OPT_TEX_FREE_CYC, MAX_DEPTH, &x_gem->desk_size);
			break;

		case OPT_TEX_HIDD_COL:
			of_x += adr[OPT_TEX_HIDD_BAC].ob_x;
			of_y += adr[OPT_TEX_HIDD_BAC].ob_y;
			x_pop_up (of_x, of_y, popup_texture, (void*)&adr1, (short*)&item);
			adr[obj].ob_state &= ~SELECTED;
			if(item>0)
				{
				tex_hidden = item;
				c_tex_b_hidden=1;
				}
			adr[OPT_TEX_HIDD_COL].ob_spec.index = popup_texture[tex_hidden].ob_spec.index;
			x_objc_draw (wind_form, adr, OPT_TEX_HIDD_BAC, MAX_DEPTH, &x_gem->desk_size);
			break;
		case OPT_TEX_HIDD_CYC:
			adr[obj].ob_state &= ~SELECTED;
			tex_hidden++;
			if(tex_hidden>8)
				tex_hidden = 1;
			c_tex_b_hidden=1;
			adr[OPT_TEX_HIDD_COL].ob_spec.index = popup_texture[tex_hidden].ob_spec.index;
			x_objc_draw (wind_form, adr, OPT_TEX_HIDD_BAC, MAX_DEPTH, &x_gem->desk_size);
			x_objc_draw (wind_form, adr, OPT_TEX_HIDD_CYC, MAX_DEPTH, &x_gem->desk_size);
			break;

/* END TEXTURE	*/


		case OPT_LANGUAGE_BUT:
			x_pop_up (of_x, of_y, popup_lang, (void*)&adr1, (short*)&item);
			if(item>0)
				{
				lang = item;
				c_la = 1;
				x_set_ob_text(adr, OPT_LANGUAGE_BUT, x_get_ob_text(popup_lang, lang));
				}
			adr[obj].ob_state &= ~SELECTED;
			x_objc_draw (wind_form, adr, obj, MAX_DEPTH, &x_gem->desk_size);
			break;
		case OPT_LANGUAGE_CYC:
			lang++;
			if(lang>6)
				lang=0;
			c_la = 1;
			adr[obj].ob_state &= ~SELECTED;
			x_set_ob_text(adr, OPT_LANGUAGE_BUT, x_get_ob_text(popup_lang, lang));
			x_objc_draw (wind_form, adr, obj, MAX_DEPTH, &x_gem->desk_size);
			x_objc_draw (wind_form, adr, OPT_LANGUAGE_BUT, MAX_DEPTH, &x_gem->desk_size);
			break;


/* Einfach	*/
		case OPT_KLICK:
		case OPT_DOPPELKLICK:
			adr[OPT_KLICK].ob_state &= ~SELECTED;
			adr[OPT_DOPPELKLICK].ob_state &= ~SELECTED;
			adr[obj].ob_state |= SELECTED;
			Set_klicks(adr);
			x_objc_draw (wind_form, adr, OPT_BACK_MAUS, MAX_DEPTH, &x_gem->desk_size);
			break;


		case OPT_E_R_B:
			x_pop_up (of_x, of_y, popup_maus, (void*)&adr1, (short*)&item);
			Get_klicks(adr, OPT_E_R_B, item, &def_klicks[0][1], &c_def_klicks[0][1], &def_doppel_klicks[0][1], &c_def_doppel_klicks[0][1]);
			adr[OPT_E_R_B].ob_state &= ~SELECTED;
			x_objc_draw (wind_form, adr, OPT_E_R_B, MAX_DEPTH, &x_gem->desk_size);
			break;
		case OPT_E_R_C:
			Get_klicks(adr, OPT_E_R_B, 0, &def_klicks[0][1], &c_def_klicks[0][1], &def_doppel_klicks[0][1], &c_def_doppel_klicks[0][1]);

			adr[OPT_E_R_C].ob_state &= ~SELECTED;
			evnt_timer(200UL);
			x_objc_draw (wind_form, adr, OPT_E_R_B, MAX_DEPTH, &x_gem->desk_size);
			x_objc_draw (wind_form, adr, OPT_E_R_C, MAX_DEPTH, &x_gem->desk_size);
			break;
		case OPT_E_L_B:
			x_pop_up (of_x, of_y, popup_maus, (void*)&adr1, (short*)&item);
			Get_klicks(adr, OPT_E_L_B, item, &def_klicks[0][2], &c_def_klicks[0][2], &def_doppel_klicks[0][2], &c_def_doppel_klicks[0][2]);

			adr[OPT_E_L_B].ob_state &= ~SELECTED;
			x_objc_draw (wind_form, adr, OPT_E_L_B, MAX_DEPTH, &x_gem->desk_size);
			break;
		case OPT_E_L_C:
			Get_klicks(adr, OPT_E_L_B, 0, &def_klicks[0][2], &c_def_klicks[0][2], &def_doppel_klicks[0][2], &c_def_doppel_klicks[0][2]);

			adr[OPT_E_L_C].ob_state &= ~SELECTED;
			evnt_timer(200UL);
			x_objc_draw (wind_form, adr, OPT_E_L_B, MAX_DEPTH, &x_gem->desk_size);
			x_objc_draw (wind_form, adr, OPT_E_L_C, MAX_DEPTH, &x_gem->desk_size);
			break;
/* End Einfach	*/

/* Shift */
		case OPT_S_R_B:
			x_pop_up (of_x, of_y, popup_maus, (void*)&adr1, (short*)&item);
			Get_klicks(adr, OPT_S_R_B, item, &def_klicks[1][1], &c_def_klicks[1][1], &def_doppel_klicks[1][1], &c_def_doppel_klicks[1][1]);

			adr[OPT_S_R_B].ob_state &= ~SELECTED;
			x_objc_draw (wind_form, adr, OPT_S_R_B, MAX_DEPTH, &x_gem->desk_size);
			break;
		case OPT_S_R_C:
			Get_klicks(adr, OPT_S_R_B, 0, &def_klicks[1][1], &c_def_klicks[1][1], &def_doppel_klicks[1][1], &c_def_doppel_klicks[1][1]);

			adr[OPT_S_R_C].ob_state &= ~SELECTED;
			evnt_timer(200UL);
			x_objc_draw (wind_form, adr, OPT_S_R_B, MAX_DEPTH, &x_gem->desk_size);
			x_objc_draw (wind_form, adr, OPT_S_R_C, MAX_DEPTH, &x_gem->desk_size);
			break;
		case OPT_S_L_B:
			x_pop_up (of_x, of_y, popup_maus, (void*)&adr1, (short*)&item);
			Get_klicks(adr, OPT_S_L_B, item, &def_klicks[1][2], &c_def_klicks[1][2], &def_doppel_klicks[1][2], &c_def_doppel_klicks[1][2]);

			adr[OPT_S_L_B].ob_state &= ~SELECTED;
			x_objc_draw (wind_form, adr, OPT_S_L_B, MAX_DEPTH, &x_gem->desk_size);
			break;
		case OPT_S_L_C:
			Get_klicks(adr, OPT_S_L_B, 0, &def_klicks[1][2], &c_def_klicks[1][2], &def_doppel_klicks[1][2], &c_def_doppel_klicks[1][2]);

			adr[OPT_S_L_C].ob_state &= ~SELECTED;
			evnt_timer(200UL);
			x_objc_draw (wind_form, adr, OPT_S_L_B, MAX_DEPTH, &x_gem->desk_size);
			x_objc_draw (wind_form, adr, OPT_S_L_C, MAX_DEPTH, &x_gem->desk_size);
			break;
/* End shift */

/* Alt	*/
		case OPT_A_R_B:
			x_pop_up (of_x, of_y, popup_maus, (void*)&adr1, (short*)&item);
			Get_klicks(adr, OPT_A_R_B, item, &def_klicks[2][1], &c_def_klicks[2][1], &def_doppel_klicks[2][1], &c_def_doppel_klicks[2][1]);

			adr[OPT_A_R_B].ob_state &= ~SELECTED;
			x_objc_draw (wind_form, adr, OPT_A_R_B, MAX_DEPTH, &x_gem->desk_size);
			break;
		case OPT_A_R_C:
			Get_klicks(adr, OPT_A_R_B, 0, &def_klicks[2][1], &c_def_klicks[2][1], &def_doppel_klicks[2][1], &c_def_doppel_klicks[2][1]);

			adr[OPT_A_R_C].ob_state &= ~SELECTED;
			evnt_timer(200UL);
			x_objc_draw (wind_form, adr, OPT_A_R_B, MAX_DEPTH, &x_gem->desk_size);
			x_objc_draw (wind_form, adr, OPT_A_R_C, MAX_DEPTH, &x_gem->desk_size);
			break;
		case OPT_A_L_B:
			x_pop_up (of_x, of_y, popup_maus, (void*)&adr1, (short*)&item);
			Get_klicks(adr, OPT_A_L_B, item, &def_klicks[2][2], &c_def_klicks[2][2], &def_doppel_klicks[2][2], &c_def_doppel_klicks[2][2]);

			adr[OPT_A_L_B].ob_state &= ~SELECTED;
			x_objc_draw (wind_form, adr, OPT_A_L_B, MAX_DEPTH, &x_gem->desk_size);
			break;
		case OPT_A_L_C:
			Get_klicks(adr, OPT_A_L_B, 0, &def_klicks[2][2], &c_def_klicks[2][2], &def_doppel_klicks[2][2], &c_def_doppel_klicks[2][2]);

			adr[OPT_A_L_C].ob_state &= ~SELECTED;
			evnt_timer(200UL);
			x_objc_draw (wind_form, adr, OPT_A_L_B, MAX_DEPTH, &x_gem->desk_size);
			x_objc_draw (wind_form, adr, OPT_A_L_C, MAX_DEPTH, &x_gem->desk_size);
			break;
/* End alt */

/* Control	*/
		case OPT_C_R_B:
			x_pop_up (of_x, of_y, popup_maus, (void*)&adr1, (short*)&item);
			Get_klicks(adr, OPT_C_R_B, item, &def_klicks[3][1], &c_def_klicks[3][1], &def_doppel_klicks[3][1], &c_def_doppel_klicks[3][1]);

			adr[OPT_C_R_B].ob_state &= ~SELECTED;
			x_objc_draw (wind_form, adr, OPT_C_R_B, MAX_DEPTH, &x_gem->desk_size);
			break;
		case OPT_C_R_C:
			Get_klicks(adr, OPT_C_R_B, 0, &def_klicks[3][1], &c_def_klicks[3][1], &def_doppel_klicks[3][1], &c_def_doppel_klicks[3][1]);

			adr[OPT_C_R_C].ob_state &= ~SELECTED;
			evnt_timer(200UL);
			x_objc_draw (wind_form, adr, OPT_C_R_B, MAX_DEPTH, &x_gem->desk_size);
			x_objc_draw (wind_form, adr, OPT_C_R_C, MAX_DEPTH, &x_gem->desk_size);
			break;
		case OPT_C_L_B:
			x_pop_up (of_x, of_y, popup_maus, (void*)&adr1, (short*)&item);
			Get_klicks(adr, OPT_C_L_B, item, &def_klicks[3][2], &c_def_klicks[3][2], &def_doppel_klicks[3][2], &c_def_doppel_klicks[3][2]);

			adr[OPT_C_L_B].ob_state &= ~SELECTED;
			x_objc_draw (wind_form, adr, OPT_C_L_B, MAX_DEPTH, &x_gem->desk_size);
			break;
		case OPT_C_L_C:
			Get_klicks(adr, OPT_C_L_B, 0, &def_klicks[3][2], &c_def_klicks[3][2], &def_doppel_klicks[3][2], &c_def_doppel_klicks[3][2]);

			adr[OPT_C_L_C].ob_state &= ~SELECTED;
			evnt_timer(200UL);
			x_objc_draw (wind_form, adr, OPT_C_L_B, MAX_DEPTH, &x_gem->desk_size);
			x_objc_draw (wind_form, adr, OPT_C_L_C, MAX_DEPTH, &x_gem->desk_size);
			break;
/* End control	*/

		case OPT_EXT_RSC:				/* Zewnetrzne RSC	*/
			{
			if(x_file_select(1, "Externe RSC Datei", "*.rsc", "", ext_rsc)==1)
				{
				if(strlen(ext_rsc)>strlen(adr[OPT_EXT_RSC].ob_spec.tedinfo->te_pvalid))
					sprintf(adr[OPT_EXT_RSC].ob_spec.tedinfo->te_ptext, "...%s", &ext_rsc[strlen(ext_rsc)-strlen(adr[OPT_EXT_RSC].ob_spec.tedinfo->te_pvalid)+3]);
				else
					x_set_ob_text(adr, OPT_EXT_RSC, ext_rsc);
				x_objc_draw (wind_form, adr, OPT_EXT_RSC, MAX_DEPTH, &x_gem->desk_size);
				if(rsrc_load(ext_rsc))				/* Pokaz zaladowane RSC	*/
					{
					OBJECT *rsc;
					int obj=1;
					rsrc_gaddr(R_TREE,0,&rsc);
					while(obj!=0)								/* Ikonki musza byc wybieralne!!		*/
						{
						rsc[obj].ob_flags |= (SELECTABLE|EXIT|TOUCHEXIT);
						obj = rsc[obj].ob_next;
						}

					wind_icon = x_open_wind (-1, -1, rsc->ob_width - 1, rsc->ob_height - 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, CLOSER|NAME|MOVER, "Start Button:", "", 0L, rsc, 0L, 0L, 0L, 0L, (FNCP1)close_icon, 0L);
					}
				}
			break;
			}
		}
	}
	else if(x_gem->event_wind == wind_icon)			/* seul cette fenˆtre nous int‚resse */
		{
		int rsc_no = *x_gem->object;
		adr = wind->w_dial.d_addr;				/* r‚cup‚rer l'adresse du formulaire */

		itoa(rsc_no, x_get_ob_text(adr, OPT_EXT_RSC_NR), 10);														/* Zmienic tekst		*/
		x_objc_draw (wind_form, adr, OPT_BACK_RSC_NR, MAX_DEPTH, &x_gem->desk_size);		/* Przerysowanie	*/

/* xxx
	Ktory przycisk jest dla START a ktory dla APP???
*/
		}
}


	/* redessiner le contenu de la fenˆtre de dessin: */
void redraw_draw (short wind)
{
	register short hand;
	short *pxy;
	register WIND_LIST *window;

	hand = x_gem->handle;						/* handle vdi de l'application */
	window = &x_gem->wind[wind];				/* structure d'info sur la fenˆtre */

	pxy = window->w_redraw_pxy;					/* coordonn‚es de la zone … redessiner */

	vswr_mode (hand, MD_REPLACE);				/* un fond color‚ */
	vsf_perimeter (hand, 0);
	vsf_color (hand, GREEN);
	vsf_interior (hand, FIS_PATTERN);
	vsf_style (hand, options_draw);

	v_bar (hand, pxy);
}



	/* en cas de fermeture du formulaire... */
void close_form (short window)
{
	window = window;							/* ce paramŠtre ne nous est pas utile cette fois-ci ! */
	wind_form = -1;								/* indiquer que la fenˆtre est ferm‚e … l'aide du flag */
}


	/* en cas de fermeture de dessin... */
void close_icon (short window)
{
	window = window;							/* ce paramŠtre ne nous est pas utile cette fois-ci ! */
	wind_icon = -1;								/* indiquer que la fenˆtre est ferm‚e … l'aide du flag */
}



void SendAV(int to_id, int p1, int p2, int p3, int p4, int p5, int p6, int p7, int p8)
	{
	if(!pipe)
		pipe=Mxalloc(16, MX_READABLE|3);
	pipe[0]=p1;
	pipe[1]=p2;
	pipe[2]=p3;
	pipe[3]=p4;
	pipe[4]=p5;
	pipe[5]=p6;
	pipe[6]=p7;
	pipe[7]=p8;
				
	appl_write(to_id,16,pipe);
	}