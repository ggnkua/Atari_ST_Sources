#include <mt_gemx.h>

#define POPUP            0   /* Formular/Dialog */
#define COWHITE          17  /* STRING in Baum POPUP */
#define COBLACK          18  /* STRING in Baum POPUP */
#define CORED            19  /* STRING in Baum POPUP */
#define COGREEN          20  /* STRING in Baum POPUP */
#define COBLUE           21  /* STRING in Baum POPUP */
#define COCYAN           22  /* STRING in Baum POPUP */
#define COYELLOW         23  /* STRING in Baum POPUP */
#define COMAGENT         24  /* STRING in Baum POPUP */
#define COLGREY          25  /* STRING in Baum POPUP */
#define CODGREY          26  /* STRING in Baum POPUP */
#define CODRED           27  /* STRING in Baum POPUP */
#define CODGREEN         28  /* STRING in Baum POPUP */
#define CODBLUE          29  /* STRING in Baum POPUP */
#define CODCYAN          30  /* STRING in Baum POPUP */
#define CODYELLO         31  /* STRING in Baum POPUP */
#define CODMAGEN         32  /* STRING in Baum POPUP */

#define INFO_OK          12  /* BUTTON in Baum TITLE */
#define INFO_URL         13  /* TEXT in Baum TITLE */
#define INFO_GEMLIB    	 14  /* TEXT in Baum TITLE */
#define TIINFO_GEMLIB		 12  /* Tekst w tedinfo		*/


#define START_BUTTON			1
#define TIME_SEPARATOR		2
#define TIME_OBJECT				3
#define SEPARATOR_1				4
#define SEPARATOR_2				5
#define SEPARATOR_3				6
#define SPECIAL_1					7
#define MYTASK_HIDE				8

#define APPLICATION_1			9
#define APPLICATION_LAST	50
#define APP_ICON_1				51
#define APP_ICON_LAST			70
#define SYS_ICON_1				71
#define SYS_ICON_LAST			90

#define APP_TRAY		0
#define SYS_TRAY		1

#define DEF_BUTT_MENU				1
#define DEF_BUTT_SHOW				2
#define DEF_BUTT_ICON				3
#define DEF_BUTT_ICON_ALL		4
#define DEF_BUTT_DEICON			5
#define DEF_BUTT_FREEZY			6
#define DEF_BUTT_KILL				7
#define DEF_BUTT_NIX				8
#define DEF_BUTT_UNFREEZY		9
#define DEF_BUTT_SHOW_ALL		10
#define DEF_BUTT_HIDE				11
#define DEF_BUTT_HIDE_OTHER	12
#define DEF_BUTT_QUIT				13
#define DEF_BUTT_TERMINATE	14
#define DEF_BUTT_VER_VOR		15
#define DEF_BUTT_VER_DAU		16
#define DEF_BUTT_PRIORITY		17
#define DEF_BUTT_TOP				18

#define ICON_SMALL	16
#define ICON_BIG		32
#define ICON_HUGE		64
#define ICON_DISTANCE	2
#define ICON_FULL_WIDTH	(ICON_SMALL+ICON_DISTANCE)

#define  MSG_OPEN_MAIN        0
#define  MSG_AUTO_ERROR       1
#define  MSG_QUIT             2
#define  MSG_CNF_ERROR        3
#define  MSG_CNFMEM_ERROR     4
#define  MSG_NEST_ERROR       5
#define  MSG_ERROR_LINE       6
#define  MSG_MAGX_ERROR       7
#define  MSG_MAGX_VERSION     7
#define  MSG_XMEN_ERROR       8
#define  MSG_INIT_SHUTDOWN    9
#define  MSG_FINISH_SHUTDOWN	10
#define  MSG_THING_GROUP			11
#define  MSG_NOT_EXECUTABLE		12
#define  MSG_SYSTEM_TRAY			13
#define  MSG_ALT_KONF					14
#define	 MSG_FILE_PROBLEMS		15
#define	 MSG_FILE_RENAME			16
/*
#define APP_SYS		1
#define APP_APP		2
#define APP_ACC		4
#define APP_SHELL	8
*/

#define WF_ICONIFY		26
#define WF_UNICONIFY	27
#define WM_ICONIFY		34
#define WM_UNICONIFY	35
#define WM_ALLICONIFY	36

/* StIc	*/
#define STIC_DEVICE 0
#define STIC_BIG 1
#define STIC_SMALL 2

#define DEFAULT_APP 0x0100
#define DEFAULT_ACC 0x0200


#define RED_BUILD	-1
#define RED_TIMER	-2
#define RED_INFO_APP	-3
#define RED_DEL_ICON	-4
#define RED_NEW_ICON	-5
#define RED_NEW_NAME	-6
#define	RED_FONT			-7
#define RED_ICON			-8
#define RED_ICON_INFO			-9
#define RED_CHANGE_OPT		-10
#define RED_CALENDAR		-11

/*----------------------------------------------------------------------------*/
/* GEMScript support added
 * Matthias Jaap  December 21, 2001
 */

#define GS_REQUEST    0x1350
#define GS_REPLY      0x1351
#define GS_COMMAND    0x1352
#define GS_ACK        0x1353
#define GS_QUIT       0x1354
#define GS_OPENMACRO  0x1355
#define GS_MACRO      0x1356
#define GS_WRITE      0x1357
#define GS_CLOSEMACRO 0x1358

#define GSM_COMMAND   0x0001
#define GSM_MACRO     0x0002
#define GSM_WRITE     0x0004
#define GSM_HEXCODING 0x0008

#define GSACK_OK      0
#define GSACK_UNKNOWN 1
#define GSACK_ERROR   2


#define SYS_MINT	0
#define SYS_MAGIC	1
#define SYS_TOS		2

#ifndef NULL
	#define NULL	0UL
#endif
#ifndef LONG
	#define LONG	long
#endif

/*#define DESK      0*/
#define INFVER    0x0002
#ifndef GLOBAL
	#define GLOBAL    0x0020
#endif
#define ALLOCMODE 3|0x0020
#define WHITEBAK  0x0040
#define FL3DIND   0x0200
#define FL3DBAK   0x0400
#define FL3DACT   FL3DIND|FL3DBAK
#define AVMSG     0x0006  /* AV_STARTED, VA_START */
#define VAMSG     0x2421  /* AV_STARTED, AV_EXIT, AV_STARTPROG, AV_SENDKEY */
#if !defined(WHITEBAK)
#define WHITEBAK    0x0040
#endif
#if !defined(DRAW3D)
#define DRAW3D      0x0080
#endif

#define extrsc	(strlen(options.rsc)>1)

typedef enum
{
    false   = 0,
    true    = !false
}BOOLEAN;

#define REDR_TIME	1
#define REDR_MEMORY	2
#define REDR_BUTTON	4
#define REDR_ICON_APP	8
#define REDR_ICON_SYS	16

struct _aes_avail
	{
	char lange_namen;
	char get_window_owner;
	char get_window_name;
	};
extern struct _aes_avail aes_avail;


typedef struct
{
    int    contrl[15];
    int    global[80];
    int    intin[128];
    int    intout[45];
    int    ptsout[128];
    void   *addrin[128];
    void   *addrout[6];
    int    ptsin[128];
} GEMPARBLK;
extern  GEMPARBLK _GemParBlk;
extern	AESPB	aespb;



struct _calendar_
	{
	int act_m, act_d;						/* Aktualny miesiac i dzien						*/
	int cal_m, cal_d, cal_y;		/* Miesiac, dzien i rok do pokazania	*/
	int size_w, size_h;					/* Rozmiary kalendarza								*/
	int change_month;						/* Zmienna pomocnicza									*/
	char today[20];
	};
extern struct _calendar_ _calendar;
struct _acc
	{
	int app_no;				/* Nr _applications_	*/
	OBJECT *icon;
	};
extern struct _acc acc[10];
extern int no_acc, how_many_acc;

#define MAX_BENUTZER_POPUP	25
struct _popup_menu
	{
	char *text;				/* Tekst do wyswietlenia w popup	*/
	int aktion;				/* Nr akcji do przeprowadzenia:
											-1 - nazwa
											-2 - ilosc pamieci
											-3 - spis okien
											-4 - separator		*/
	};
extern struct _popup_menu popup_app_menu[MAX_BENUTZER_POPUP];


typedef struct
	{
	long id;
	long value;
	} COOKIE;


typedef struct s_entry
{
	char *name,*file,*fcmd;
	struct s_entry *next;
	int flags;
} STARTENTRY;


typedef struct s_menu
{
	OBJECT     *tree;
	STARTENTRY *entries;
	struct s_menu *children,
	              *next,
	              *parent;
} STARTMENU;

#define RED_TIME			1
#define RED_APP				2
#define RED_ICON_SYS	4
#define RED_ICON_APP	8
#define RED_ALL				16
#define RED_BUTTONS		32

struct _redraw
	{
	int type;						/*	1 - czas
													2 - aplikacja
													4 - ikonka system tray
													8 - ikonka app tray
													16 - calosc
											*/
	int x,y,w,h;
	};

struct    _tm
{
      int    tm_sec;     /* Sekunden                            */
      int    tm_min;     /* Minuten                             */
      int    tm_hour;    /* Stunden (0..23)                     */
      int    tm_mday;    /* Tag im Monat (1..31)                */
      int    tm_mon;     /* Monat (0..11)                       */
      int    tm_year;    /* Jahr                                */
      int    tm_wday;    /* Wochentag (0..6) -> (So..Sa)        */
      int    tm_yday;    /* Tag im Jahr (0..365)                */
      int    tm_isdst;   /* ungleich Null entspricht Sommerzeit */
};

struct _icons_spec_app
	{
	short no;						/* Ile ikonek				*/
	short icon_no;			/* Nr ikonki				*/
	short obj_no;				/* Nr obiektu				*/
	short rsc_no;				/* Nr ikonki zewn.	*/
	short pos_x;				/* Pozycja ikonki		*/
	char *name;					/* Full path				*/
	};
extern struct _icons_spec_app *icons_spec_app;
extern struct _icons icons_sys, icons_app;

struct _alias
	{
	int no;
	char *name;
	char *alias;
	};
extern struct _alias *alias_name;

struct RECT
	{
	short x,y,w,h;
	};

typedef struct _MyTask
	{
	short whandle, wh_calendar;
	short v_handle;
	short org_x, org_y, org_w, org_h;
	short cur_x, cur_y, cur_w, cur_h;
	short new_x, new_y, new_w, new_h;
	short prev_x, prev_y, prev_w, prev_h;				/* Poprzednie wymiary i polozenie MyTask (np. do chowania w stylu KDE)	*/
	short lines;
	short actual_app_on_top, prev_app_on_top;
	short actual_menu_on_top, prev_menu_on_top;
	short actual_win_on_top, prev_win_on_top;
	short prev_on_top;														/* Nr aplikacji	*/
	unsigned long actual_memory, prev_memory;
	};
extern struct _MyTask MyTask;


typedef struct _donotshow
	{
	int how_many;
	char name[8];				/* Nazwa aplikacji, ktora ma byc nie pokazana - zapisywane w opcjach	*/
	int ap_id;					/* ID tej aplikacji - nowe za kazdym razem														*/
	};
extern struct _donotshow *DoNotShow;


typedef struct _font_id_app
	{
	int how_many;
	char name[8];
	int ap_id;					/* Ustawiane przez MyTask!!	*/
	int id, color, effect, height;
	};
extern struct _font_id_app *FontsID;

typedef struct
{
	int version;
	int workxabs;
	int workyabs;
	int font_height;
	int default_font_id;
	int timer_font_id;
} STARTINF;
extern STARTINF    startinf;

typedef struct
{
	long len;
	int version;
	int msgs;
	long ext;
} GS_INFO;

extern GS_INFO    *gsi;


#define FLAGS9  0x0200
#define FLAGS10 0x0400
#define FLAGS11 0x0800
#define FLAGS12 0x1000
#define FLAGS13 0x2000
#define FLAGS14 0x4000
#define FLAGS15 0x8000

#define POLISH		1
#define GERMAN		2
#define ENGLISH		3
#define FRENCH		4
#define SWEDISH		5
#define NORWEGIAN	6


extern int prev_appl;

#define min(a,b)        ((a) < (b) ? (a) : (b))
#define min0(a,b)       ((a)==0 ? (b) : ((a) < (b) ? (a) : (b)));
#define max(a,b)        ((a) > (b) ? (a) : (b))
#define between(x,a,b)  ((x >= a) && (x <= b))

int handle_message(int pipe[8]);
int delete_icon(struct _applications *app, int icon_nr);
int add_icon_app(char *name, int save);
void redraw_obj(OBJECT *obj, int x, int y, int w, int h);
void redraw(int obj, int x, int y, int w, int h, char *wer);
void redraw_cal(int obj, int x, int y, int w, int h);
void redraw_opt(int obj, int x, int y, int w, int h);
void redraw_dial(OBJECT *tree, int wh, int obj, int x, int y, int w, int h);
void hide_mytask(void);
void show_mytask(void);
int fix_width(void);
void SendAV(int to_id, int p1, int p2, int p3, int p4, int p5, int p6, int p7, int p8);
void find_applications(void);
void make_appl_list(void);
void prepare_applications_list(void);
int find_app_by_id(int id);
int find_app_by_window(int wh);
int find_appicon_by_objc(int objc);
int add_window_to_app(int app, int wh, char *name);
int delete_window_to_app(int app, int wh);
void trim_start(char *name);
void trim_end(char *name);
void read_texts(void);
void reset_texts(void);
void build_applications(int mode);
void hide_button(int app, int button);
void show_button(int app, int button);
void move_applications(signed int);
void Default_options(void);
void Set_options(int mx, int my);
void Save_options(void);
void Load_options(void);
void clip_startinf(void);
void close_window(int w);
short cdecl draw_bigbutton(PARMBLK *parmblock);
short cdecl draw_menu_rect(PARMBLK *parmblock);
short cdecl draw_button(PARMBLK *parmblock);
short cdecl draw_checkbox(PARMBLK *parmblock);
short cdecl draw_radiobox_parent(PARMBLK *parmblock);
short cdecl draw_radiobox(PARMBLK *parmblock);
short cdecl draw_opt_background(PARMBLK *parmblock);
short cdecl draw_spec1(PARMBLK *parmblock);
short cdecl draw_timer(PARMBLK *parmblock);
short cdecl draw_hide_mytask(PARMBLK *parmblock);
short cdecl draw_calendar(PARMBLK *parmblock);
short cdecl draw_calendar_titel(PARMBLK *parmblock);
short cdecl draw_separator(PARMBLK *parmblock);
void set_clip (int clipflag, struct RECT *size, struct RECT *size2);
void xywh2rect (int x, int y, int w, int h, struct RECT *rect);
void fix_tree(OBJECT *tree);
void build_lang_popup(void);
int add_icon(void *tmp, int mode, int icon_nr, char *mono_data, char *mono_mask, char  *col_data, char *col_mask);
void load_app_icon(void);
void save_app_icon(void);
int dialog(OBJECT *tree, int mode);
void info_app_icon(int objc, int button, int mx, int my);
void move_icon(int icon_no);
signed int info_app(int obj, int kstate, int button, int clicks, int mx, int my);
void delete_app_icon(int objc);
void open_window(OBJECT *tree, int *handler, int mx, int my, char *title, int *w, int *h);
void start_app(int force, int how, char *name, char *file, char *cmd);
void findstic(void);
void importiere_longname(char *name);
void free_lang_pop(void);
void free_alias(void);
void find_alias(char *in, char *out);
void Add_app_to_not_show(int app, char *name);
int Set_font(int font_id, int *font_height, int font_effects);
int get_text_width(char *text, int app_no, int font_id, int *font_h);
void SendACCIcon(void);
void DeleteACCicon(void);
void SendHTML(char *url, char *name);
void zeige_ordner_popup(char *path, int mx, int my);
void init_app_menu(void);
void get_paths(void);
int new_cookie(long id, long value);
COOKIE *get_cookie_jar(void);
int remove_cookie(long id);
int get_cookie(long id, long *value);
void app_popup_vorbereiten(OBJECT *popup, int app_no);
void build_app_menu(void);
OBJECT *build_popup_thing(STARTMENU *menu);
void Reload_set(void);
int get_system_parameter(char *startset, BOOLEAN opt);

extern char  home[128];

#include "stic.h"
extern struct STIC       *stic;

extern int quit;
extern char *current_directory;
extern char check_unselected8[];
extern char check_selected8[];
extern char radio_unselected8[];
extern char radio_selected8[];

extern STARTMENU  *menus;

extern struct _redraw _redraw_;
extern USERBLK     usrdef;
extern USERBLK     usrdef_spec1;
extern USERBLK     usrdef_spec2;
extern USERBLK     usrdef_separator;
extern USERBLK			usrdef_timer;
extern USERBLK			usrdef_bigbutton;
extern USERBLK			usrdef_calendar_titel;
extern USERBLK			usrdef_calendar;
extern USERBLK			*usrdef_button;

extern char text_time_line1[50], text_time_line2[50];

extern OBJECT bigbutton[];
extern TEDINFO rs_tedinfo_calender[];
extern TEDINFO rs_tedinfo_opt1[];
extern OBJECT rs_object_przycisk[];
extern OBJECT apppopup_magic[];
extern OBJECT apppopup_mint[];
extern OBJECT startpopup[];
extern OBJECT monthspopup[];
extern OBJECT popup_app_icon[];
extern OBJECT color_pop[];
extern TEDINFO rs_tedinfo;
extern TEDINFO rs_tedinfo_time;
extern TEDINFO rs_tedinfo_calender[];
extern TEDINFO rs_tedinfo_appl01;
extern CICONBLK rs_ciconblk[];
extern BITBLK rs_bitblk;
extern OBJECT bigbutton[];
extern OBJECT *apppopup;
extern OBJECT calender[];
extern OBJECT button;
extern OBJECT *lang_pop;
extern OBJECT *mini_icons;
extern int language;
extern int last_added_obj;
extern int last_added_button, last_added_app, last_added_tray;
extern int first_added_button, first_added_app, first_added_tray;
extern int sended_gsc_ln;				/* Zlicza ile bylo wyslanych komend GetAppLongName, dopiero jak wszystkie wroca mozna przerysowac MyTask	*/

extern TEDINFO tedinfo_info[];
extern OBJECT object_info[];
extern char    *message[];
extern char *miesiac[];
extern char *dni[];

extern char *bubble_calendar[];
extern char menuentry[], drventry[],
            docentry[],	appentry[],	fseltitle[],	xaccusr[],	bubbleinfo[], options_text[];
extern char *languages_text[];
extern GRECT       desk;
extern int wh_icons;
extern signed int *pipe;

typedef struct _icons
	{
	short last_pos_x;			/* Pozycja ostatniej ikonki				*/
	short first_pos_x;		/* Pozycja pierwszej ikonki				*/
	short how_many;				/* Ile jest ikonek wogole					*/
	short first_obj;			/* Nr pierwszego obiektu RSC			*/
	char type;					/* 0 - APP TRAY, 1 - SYSTEM TRAY	*/
	short w_w, w_h;
	};
extern struct _icons icons_sys, icons_app;

struct _ikonki
	{
	int no;												/* Numer ikonki - moze byc zupelnie inny niz
																		ilosc zapamietanych ikonek!!							*/
	char mask[512];
	char data[512];								/* 16x16 - speciall icon on the right side		*/
	int icon_no;									/* Nr ikonki																	*/
	int pos_x;
	int rsc_no;
	CICONBLK *icon;
	};

#define GS_SUPPORT	1
#define GS_ICONIFY	2
#define GS_UNICONIFY	4

struct _applications
	{
	int no;												/* Ile jest aplikacji w pamieci/nr aplikacji	*/
	char check;										/* W find_applications:
																		0 - dana aplikacja nie istnieje
																		1 - dana aplikacja dziala
																	  2 - aplikacja jest zamrozona							*/
	int has_menu;									/* 0 - aplikacja nie posiada listwy menu
																	 1 - aplikacja posiada listwe menu					*/
	OBJECT *icon;									/* Adres ikonki albo pobrany od StIc
																	 albo z wewn. zbioru ikon										*/
	char active;									/* Czy dana aplikacja jest aktywna czy nie		*/
	char name[24];								/* Nazwa aplikacji wg appl_search							*/
	char alias[24];								/* Inna nazwa: GSC, AV, LANGNAME							*/
	char bubble[256];							/* Tekst dla BubbleGEM												*/
	int name_len;									/* Jezeli trzeba skrocic nazwa na przycisku		*/
	int il_ikonek;								/* Ile jest ikonek danej appl w pamieci				*/
	char acc_icon;
	struct _ikonki *ikonki;				/* Podejscie do ikonek umozliwiajace
																	 uzywanie wiecej niz jednej ikonki!					*/
	char mytask_send;							/* Czy komenda MYTASK_START juz byla wyslana?	*/
	char show_button;							/* Czy pokazywac przycisk na listwie?					*/
	int gs;												/* Co jest obslugiwane w GEM-Script						*/
	char gs_id;										/* ID dla GEMScriptu													*/
/*	char gs_support;							/* Tryb wspolpracy GEMScript									*/
	char gs_iconify;							/* Czy obslugiwana jest komenda "WinIconify"?	*/
	char gs_uniconify;						/* Czy obslugiwana jest komenda "WinUnIconify"?	*/	*/
	char new_name;								/* Czy aplikacja zmienila nazwe przycisku?		*/
	int used_memory;							/* Uzywana pamiec w kB												*/
	int button_no;								/* Nr przycisku																*/
	int button_color;							/* Kolor przycisku na listwie MYTASK_NEW_COLOR	*/
	int type, id, pid;						/* Typ i ID (AES) aplikacji + PID	(MiNT)			*/
	int pos_x, width;							/* Pozycja i szerokosc przycisku aplikacji		*/
	int font_id;									/* ID fontu jaki ma byc uzyty do wypisania nazwy aplikacji	*/
	int font_color;
	int font_effect;
	int font_height;
	int notify;										/* Komendy "Notify" GEMScriptu. Jezeli notify=1 to przy
																	 kliknieciu na przycisk danej aplikacji MyTask
																	 wysyla "Notified" do danej aplikacji.			*/
	int no_windows;								/* Ile jest okienek danej aplikacji						*/
	int last_choosen_window;			/* Ktore okienko z tabeli bylo ostatnio wybrane?	*/
	int window_handlers[128];			/* Handle okienek danej aplikacji.
																		Max. ilosc to 100 okienek									*/
	char window_name[128][128];
	char *path;										/* Sciezka dostepu do aplikacji. TODO!				*/
	};

extern struct _applications *_applications_;
int modify_time_format(char *in, char *out, struct _tm *tim);
void prepare_time_object(void);


/* Komendy AV/VA dla fontow	*/
#define FONT_CHANGED	0x7a18
#define XFONT_CHANGED	0x7a1b
#define FONT_SELECT		0x7a19
#define	FONT_ACK			0x7a1a


#define MX_HEADER				((1 << 3)									/*	Refer to Program Header			*/
#define MX_PRIVATE			((1 << 3) | (1 << 4))			/*	Private											*/
#define MX_GLOBAL				((1 << 3) | (2 << 4))			/*	Global											*/
#define MX_SUPERVISOR		((1 << 3) | (3 << 4))			/*	Supervisor Mode Only Access	*/
#define MX_READABLE			((1 << 3) | (4 << 4))			/*	Read Only Access						*/

#define	PROC_RUN				0x00
#define	PROC_READY			0x01
#define	PROC_TRS				0x02
#define	PROC_WAITEVENT	0x20
#define	PROC_WAITIO			0x21
#define	PROC_EXITED			0x22
#define	PROC_STOPPED		0x24


#define DHST_ADD 0xdadd
#define DHST_ACK 0xdade

#define BUBBLEGEM_REQUEST 0xbaba
#define BUBBLEGEM_SHOW    0xbabb

#define BGS7_2STRINGS     0x0008

#define GSM_COMMAND 0x0001

#define GSACK_OK      0
#define GSACK_UNKNOWN 1
#define GSACK_ERROR   2

#define WHITEBAK  0x0040
#define FL3DIND   0x0200
#define FL3DBAK   0x0400
#define FL3DACT   FL3DIND|FL3DBAK
#define AVMSG     0x0006  /* AV_STARTED, VA_START */
#define VAMSG     0x2421  /* AV_STARTED, AV_EXIT, AV_STARTPROG, AV_SENDKEY */

#ifndef NONE
	#define NONE	0
#endif

#define WM_M_BDROPPED 100
#define SM_M_SPECIAL  101
#define SMC_TIDY_UP			0
#define SMC_TERMINATE		1
#define SMC_SWITCH			2
#define SMC_FREEZE			3
#define SMC_UNFREEZE		4
#define SMC_RES5				5
#define SMC_UNHIDEALL		6
#define SMC_HIDEOTHERS	7
#define SMC_HIDEACT			8
#define SHW_CHAIN       1
#define SHW_LOAD_ACC    3
#define	SHW_PARALLEL  100
#define SHW_SINGLE    101
#define ME_ATTACH       1
#define ME_REMOVE       2
#define WINDOWSTYLE     0
#define SH_WDRAW       72
#define ACC_EXIT      0x0404
#define AV_STARTED    0x4738
#define AV_COPYFILE   0x4755
#define APPLINE_MSG   0x0935
#define CDROMEJECT    0x4309
#define DD_OK           0
#define DD_NAK          1
#define SE_FILE         0
#define SE_FOLDER       1
#define DF_NONE         0
#define DF_LEFT         1
#define DF_RIGHT        2
#define WF_WINX     22360
#define G_SHORTCUT     38

#define WHAT_NORMAL  0
#define WHAT_HISTORY 1
#define WHAT_HTML    2
#define WHAT_DRIVES  3
#define WHAT_MENU    4

#define KsCAPS    0x10
#define KsALT     0x08
#define KsCONTROL 0x04
#define KsSHIFT   0x03
#define KsLSHIFT  0x02
#define KsRSHIFT  0x01
#define KsNORMAL  0x00

#define KbSCAN    0x8000
#define KbNUM     0x4000
#define KbALT     0x0800
#define KbCONTROL 0x0400
#define KbSHIFT   0x0300
#define KbLSHIFT  0x0200
#define KbRSHIFT  0x0100
#define KbNORMAL  0x0000

#define KbISO     0x37

#define KbF1      0x3b
#define KbF2      0x3c
#define KbF3      0x3d
#define KbF4      0x3e
#define KbF5      0x3f
#define KbF6      0x40
#define KbF7      0x41
#define KbF8      0x42
#define KbF9      0x43
#define KbF10     0x44
#define KbF11     0x54
#define KbF12     0x55
#define KbF13     0x56
#define KbF14     0x57
#define KbF15     0x58
#define KbF16     0x59
#define KbF17     0x5a
#define KbF18     0x5b
#define KbF19     0x5c
#define KbF20     0x5d

#define KbUNDO    0x61
#define KbHELP    0x62
#define KbINSERT  0x52
#define KbHOME    0x47
#define KbUP      0x48
#define KbDOWN    0x50
#define KbLEFT    0x4b
#define KbRIGHT   0x4d

#define KbAlt1    0x78
#define KbAlt2    0x79
#define KbAlt3    0x7a
#define KbAlt4    0x7b
#define KbAlt5    0x7c
#define KbAlt6    0x7d
#define KbAlt7    0x7e
#define KbAlt8    0x7f
#define KbAlt9    0x80
#define KbAlt0    0x81


#ifdef _DEBUG
	extern int debug_handle;
	#define DEBUG { char text[100]={0};	\
									if(debug_handle<=0) { debug_handle=open("debug.log", O_CREAT|O_WRONLY|O_TRUNC); } \
									else { debug_handle=open("debug.log", O_APPEND|O_WRONLY); } \
									if(debug_handle) { \
									sprintf(text, "%s -> %d\r\n", __FILE__, __LINE__); \
									write(debug_handle, text, strlen(text));		close(debug_handle);  } }
#else
	#define DEBUG
#endif