/*
 ***************************************
 *    Thomas Much, Gerwigstraže 46,    *
 * 76131 Karlsruhe, Fax (0721) 622821  *
 *         Thomas Much @ KA2           *
 *        thomas@snailshell.de         *
 ***************************************
 *          Dr. R. Kawecki             *
 * Franconvillestr. 16                 *
 * 68519 Viernheim                     *
 * rafalkawecki@web.de                 *
 ***************************************
 *    erstellt am:        16.02.1996   *
 *    letztes Update am:  02.10.1998   *
 *		by Thomas Much									 *
 ***************************************
 *    letztes Update am:  16.02.2004   *
 *		by Dr. R. Kawecki								 *
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
#include <ext.h>
#include <mytask.h>
#include "sounds.h"
#include "global.h"
#include "option.h"
#include "memdebug.h"



/* *****************************************	*/
/* *****************************************	*/
/* New variables added by Dr. Rafael Kawecki	*/
/* *****************************************	*/



void Change_time(int, int);
int mouse_over_app(int mx, int my);
int find_app_by_id(int id);
void change_calendar(void);
void open_calendar(void);
void objc_redraw(int obj);
void build_applications(int mode);
void change_button_widths(void);
int find_icon(struct _applications *app, int icon_nr);
int replace_icon(struct _applications *app, int obj_nr, int icon_nr, char *mono_data, char *mono_mask, char  *col_data, char *col_mask);
void hide_mytask_KDE(void);
void unhide_mytask_KDE(void);
void hide_mytask(void);
void show_mytask(void);
void SendAV(int to_id, int p1, int p2, int p3, int p4, int p5, int p6, int p7, int p8);
int objc_find_mytask(int mx, int my);
int objc_find_calendar(int mx, int my);
int find_app_by_icon_no(int icon);
int find_icon_no_by_app(int icon, int app);
int find_app_by_button(int obj, int mx);
int find_app_by_button_no(int button);
void Add_app_font(int app, int font_id, int font_col, int font_eff, int font_height);
int find_app_font(char *name);

int Psetpriority(int pid, int priority);
int Pgetpriority(int pid);

int sended_gsc_ln;
int prev_appl;				/* How many applications was when last checked	*/
int desktop_w, desktop_h;
int screen_manager_id;
int last_added_obj;
int last_added_button, last_added_app, last_added_tray;
char *current_directory;

struct _aes_avail aes_avail;
struct _calendar_ _calendar;

char *miesiac[]={"???", "Januar       ", 
												"Februar      ",
												"M„rz         ",
												"April        ",
												"Mai          ",
												"Juni         ",
												"Juli         ",
												"August       ",
												"September    ",
												"Oktober      ",
												"November     ",
												"Dezember     ", "???", "???", "???"};
char *dni[]={"???", "Sonntag", "Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag", "???", "???", "???"};


char *bubble_calendar[]={NULL, "W„hle ein Monat", "Ein Monat vorher", "Ein Monat sp„ter"};
char *bubble_mytask[]={"Wenn Sie diesen Bereich des SMU-Buttons mit der linken Maustaste anklicken und diese gedrckt halten, k”nnen Sie den SMU-Button auf dem Desktop verschieben.   ", "START Knopf", "Nix besonders", "Zeituhr", "Nix besonders", "Nix besonders", "Nix besonders",
												"Spezial1", "(Un)Hide MyTask"};


signed int *pipe;


struct _donotshow *DoNotShow;
struct _font_id_app *FontsID;
struct _MyTask MyTask;


struct _applications *_applications_;

/* *****************************************	*/
/* *****************************************	*/
/* *****************************************	*/

typedef struct
	{
	char *appname,
	     *apppath,
	     *docname,
	     *docpath;
	} DHSTINFO;


typedef struct n_dhst
{
	struct n_dhst *next;
	DHSTINFO info;
} DHST;

/* DHST oddzielnie dla kazdej aplikacji	*/
typedef struct n_dhst2
{
	struct n_dhst2 *next;
	char *appname;
	DHST *dhst;
} DHST2;

typedef struct n_alias
{
	struct n_alias *next;
	char old[128],new[256];
} ALIAS;


typedef struct
{
	char name[32],path[256];
} LINK;


typedef struct n_timer
{
	struct n_timer *next;
	char *file,*fcmd;
	long time;
} TIMER;



typedef struct
{
	long  magic;
	void *membot;
	void *aes_start;
	long  magic2;
	long  date;
	void (*chgres)(int res, int txt);
	long (**shel_vector)(void);
	char *aes_bootdrv;
	int  *vdi_device;
  void *reservd1;
  void *reservd2;
  void *reservd3;
  int   version;
  int   release;
} AESVARS;


typedef struct
{
	long    config_status;
	void    *dosvars;
	AESVARS *aesvars;
} MAGX_COOKIE;



char    *message[] = {"[1][ |Das \"MyTask!\"-Fenster kann |nicht ge”ffnet werden. ][Abbruch]",
                      "\"MyTask!\" kann nicht im AUTO-Ordner gestartet werden.\n",
                      "[2][ |\"MyTask!\" beenden? ][  Ja  | Nein ]",
                      "[1][ |Die Datei \"MyTask.set\" ist |defekt (Zeile ",
                      "[1][\"MyTask.set\" konnte wegen Speicher- |mangel nicht geladen werden. ][Abbruch]",
                      "[1][ |Die Datei \"MyTask.set\" ist zu tief |verschachtelt (Zeile ",
                      "). ][Abbruch]",
                      "[1][ |Ihre MagiC!-Version ist zu alt. |Sie ben”tigen mindestens MagiC!4. ][Abbruch]",
                      "[1][ |MyTask! ben”tigt XMEN_MGR.|Bitte installieren Sie das Programm |im MagiC-APPS-Ordner.][Abbruch]",
                      "[1][ |Shutdown konnte nicht |gestartet werden.][  OK  ]",
                      "[1][ |Shutdown konnte nicht |durchgefhrt werden.][  OK  ]",
                      "[1][ |Fehler beim Einlesen der THING- |Gruppendatei (Zeile ",
                      "[1][ |Die Datei ist kein aus- |fhrbares Programm. ][  OK  ]",
                      "[1][ |Es gibt unbekannte Probleme mit|Icons fuer System-Tray ][ Ich melde das ]",
                      "[1][ |Konfigurationsdatei ist zu alt.|MyTask wird Defaultwerte benutzen.][ Ok ]",
                      "[1][ |Die Datei kann nicht ge”ffnet|(l”schen, lesen, schreiben) werden. ][ Ok ]",
                      "[1][ |Fehler beim Umbennenen von|%s in|%s.][ Ich prfe es ]",
                      };



OBJECT startdesk[] = {
	{-1,-1,-1,G_BOX,OF_LASTOB,OS_NORMAL,(long)0x0000004cL,0,0,20,10}};

#define RM_START 6
OBJECT deskmenu[] =
{
	{-1,1,4,G_IBOX,NONE,OS_NORMAL,(long)0x00000000L,0x0000,0x0000,0x0050,0x0019},
	{4,2,2,G_BOX,NONE,OS_NORMAL,(long)0x00001100L,0x0000,0x0000,0x0050,0x0201},
	{1,3,3,G_IBOX,NONE,OS_NORMAL,(long)0x00000000L,0x0002,0x0000,0x0007,0x0301},
	{2,-1,-1,G_TITLE,NONE,OS_NORMAL,(long)" START",0x0000,0x0000,0x0007,0x0301},
	{0,5,5,G_IBOX,NONE,OS_NORMAL,(long)0x00000000L,0x0000,0x0301,0x0050,0x0017},
	{4,RM_START,13,G_BOX,NONE,OS_NORMAL,(long)0x00ff1100L,0x0002,0x0000,0x0013,0x0008},
#ifdef GERMAN
	{7,-1,-1,G_STRING,NONE,OS_NORMAL,(long)"  Programm...      ",0x0000,0x0000,0x0013,0x0001},
#else
#ifdef NORWEGIAN
	{7,-1,-1,G_STRING,NONE,OS_NORMAL,(long)"  Programm...      ",0x0000,0x0000,0x0013,0x0001},
#else
#ifdef SWEDISH
	{7,-1,-1,G_STRING,NONE,OS_NORMAL,(long)"  Program...       ",0x0000,0x0000,0x0013,0x0001},
#else
	{7,-1,-1,G_STRING,NONE,OS_NORMAL,(long)"  Program...       ",0x0000,0x0000,0x0013,0x0001},
#endif
#endif
#endif
	{8,-1,-1,G_STRING,NONE,OS_DISABLED,(long)"-------------------",0x0000,0x0001,0x0013,0x0001},
	{9,-1,-1,G_STRING,NONE,OS_NORMAL,(long)"  Desk Accessory 1 ",0x0000,0x0002,0x0013,0x0001},
	{10,-1,-1,G_STRING,NONE,OS_NORMAL,(long)"  Desk Accessory 2 ",0x0000,0x0003,0x0013,0x0001},
	{11,-1,-1,G_STRING,NONE,OS_NORMAL,(long)"  Desk Accessory 3 ",0x0000,0x0004,0x0013,0x0001},
	{12,-1,-1,G_STRING,NONE,OS_NORMAL,(long)"  Desk Accessory 4 ",0x0000,0x0005,0x0013,0x0001},
	{13,-1,-1,G_STRING,NONE,OS_NORMAL,(long)"  Desk Accessory 5 ",0x0000,0x0006,0x0013,0x0001},
	{5,-1,-1,G_STRING,OF_LASTOB,OS_NORMAL,(long)"  Desk Accessory 6 ",0x0000,0x0007,0x0013,0x0001}
};



extern int  _app;

extern long Dreadlabel(const char *path, char *label, int length);


char       *helpbuf = NULL,
           *accname = NULL,
           *xaccname = NULL,
           *gslongname = NULL,
           *avfile,
           *avextall,
           *avextusr = NULL,
           *defcmd,
           *cs_fname,
           *sampleboot = NULL,
           *sampleopen = NULL,
           *sampleclose = NULL,
           *samplestart = NULL,
           *sampleavfail = NULL,
           *sampletimer = NULL,
           *sampleterm = NULL,
           *bubblehelp = NULL,
           	menuentry[] =   "  MyTask       ",
            htmlentry[] = 	"  HTML             ",
#ifdef GERMAN
            drventry[]  = "  Laufwerke        ",
            docentry[] = 	"  Dokumente        ",
            appentry[] = 	"  Programme        ",
            fseltitle[] = "Programm starten   ",
            xaccusr[] = 	"1Win95 Startknopf  ",
            bubbleinfo[] = "Wenn Sie diesen Bereich des SMU-Buttons mit der linken Maustaste anklicken und diese gedrckt halten, k”nnen Sie den SMU-Button auf dem Desktop verschieben.   ",
            options_text[] = "Optionen",
/*            bubbleinfo2[] = "Verschiebt den Button bei gedrckter Maustaste", */
#else
#ifdef NORWEGIAN
            drventry[]  = "  Drev",
            docentry[] = "  Dokumenter",
            appentry[] = "  Applications",
            fseltitle[] = "Start applikasjon",
            xaccusr[] = "1Win95 start-knapp",
            bubbleinfo[] = "Hvis du klikker her med venstre musknapp og holder knappen nede, kan du flytte SMU-knappen rundt om p† desktopen.",
#else
#ifdef SWEDISH
            drventry[]  = "  Enheter",
            docentry[] = "  Dokument",
            appentry[] = "  Applications",
            fseltitle[] = "Starta program",
            xaccusr[] = "1Win95 Start knapp",
            bubbleinfo[] = "Om du trycker med v„sterknappen i denna area av SMU, och h†ller mus-knappen nedtryckt, s† kan du flytta SMU till n†gon annan plats p† skrivbordet.",
#else
            drventry[]  = "  Drives",
            docentry[] = "  Documents",
            appentry[] = "  Applications",
            fseltitle[] = "Start application",
            xaccusr[] = "1Win95 start button",
            bubbleinfo[] = "If you click in this area of the SMU button with the left mouse button and keep the mouse button pressed you can move the SMU button on the desktop.",
#endif
#endif
#endif
/*            startpath[128], */
            shutdown[128],
            logfile[128],
            nolabel[30],
            servername[16],
            home[128],
            tmp[128],
           *labels[26];
extern GRECT       desk;
long        mxdate = 0;
GRECT       desk;
KEYTAB     *kt = NULL;
AESPB       aespb;
STARTINF    startinf;
STARTMENU  *menus = NULL;
OBJECT *mini_icons;
/*OBJECT     *startbutton = bigbutton;*/
C_SOUNDS   *cs;
MN_SET      mnset;
ALIAS      *alias = NULL;
TIMER      *timer = NULL;
DHST       *dhst  = NULL;
DHST2			 *dhst2 = NULL;
struct STIC       *stic;
USERBLK     usrdef;
USERBLK     usrdef_spec1;
USERBLK     usrdef_spec2;
USERBLK     usrdef_separator;
USERBLK			usrdef_timer;
USERBLK			usrdef_bigbutton;
USERBLK			usrdef_calendar_titel;
USERBLK			usrdef_calendar;
USERBLK			usrdef_hide;
USERBLK			*usrdef_button;
USERBLK			*usrdef_options;
GS_INFO    *gsi = NULL;

GEMPARBLK _GemParBlk;
AESPB	aespb;

char *_sccs_id(void);
COOKIE *get_cookie_jar(void);
int  get_cookie(long id, long *value);
int  new_cookie(long id, long value);
int  remove_cookie(long id);
int  appl_xgetinfo(int type, int *out1, int *out2, int *out3, int *out4);
int  is_top(int handle);
/*int  rc_intersect(GRECT *r1, GRECT *r2);*/
void call_aes(void);
void mouse_on(void);
void mouse_off(void);
WORD MapKey(WORD keystate, WORD key);
void fix_child(OBJECT *tree, int obj, int parent);
void fix_tree(OBJECT *tree);
int  dialog(OBJECT *tree, int mode);
long call_hsn(void);
void play_sound(char *fname);
void init_vdi(void);
void exit_vdi(void);

void create_links(void);
void store_links(void);
void cleanup(int broadcast);
void findstic(void);
void final_init(void);
int  find_avserver(int avprot);
void cdecl sig_handler(long sig);
int  Fgets(char *str,int n,int handle);
void get_alias(char **dummy);
int read_group(char *grpfile, STARTMENU *curr);
int  get_system_parameter(char *startset, BOOLEAN options);
void cnf_error(int err, int line);
OBJECT *build_popup(STARTMENU *curr, int drv, int docs, int apps);
void attach_popups(STARTMENU *curr, int drv, int docs, int apps);
void free_dhst(DHST *d);
int add_dhst(DHSTINFO *dhstinfo);
void load_dhst(void);
void save_inf(void);
int  find_help(void);
void call_help(void);
void clip_startinf(void);
void open_main_window(void);
void about(void);
STARTMENU *find_menu(STARTMENU *curr, OBJECT *tree);
void start_by_sel(void);
void folder_state(STARTMENU *curr, int drv, int docs, int apps, int enable);
void start_popup(char *dcmd, int dx, int dy, int dflags, int what, char *mname);
void init_shutdown(void);
void info_popup(int mx, int my);
void move_button(void);
void show_bubblehelp(int mx, int my, int ap_id, int cal);
char *nextToken(char *pcmd);
int  doGSCommand(int app_no, int pipe[8]);
void open_over_mouse(char *p, int what, char *mname);
int  handle_keyboard(int kstate, int key);
int  handle_message(int pipe[8]);
void handle_button(int mx, int my, int bstate, int kstate, int clicks);
int  print_two(int handle, int value);
void start_timer(TIMER *dtimer);
void event_loop(void);



#define MOVE_WINDOW(a,b,c) { 	short x1, y1, wx, wy, ww, wh;		\
				mt_graf_mouse(4, NULL, (short*)&_GemParBlk.global[0]);		\
				mt_wind_calc(WC_WORK,WINDOWSTYLE,pipe[4],pipe[5],pipe[6],pipe[7],&wx,&wy,&ww,&wh, (short*)&_GemParBlk.global[0]);		\
				mt_graf_dragbox(ww, wh, wx, wy, 0, 0, desk.g_w, desk.g_h, &x1, &y1, (short*)&_GemParBlk.global[0]);		\
				mt_wind_set(a,WF_CURRXYWH,x1,y1, b, c, (short*)&_GemParBlk.global[0]);		\
				mt_wind_calc(WC_WORK,WINDOWSTYLE,pipe[4],pipe[5],pipe[6],pipe[7],&wx,&wy,&ww,&wh, (short*)&_GemParBlk.global[0]);		\
				mt_wind_get(a,WF_WORKXYWH, &wx, &wy, &ww, &wh, (short*)&_GemParBlk.global[0]);		\
				mt_graf_mouse(0, NULL, (short*)&_GemParBlk.global[0]);		}


char *_sccs_id(void)
	{
	return "@(#)MyTask 1.00 (02.02.2004) by Dr. R. Kawecki."; /**/
	}


int appl_xgetinfo(int type, int *out1, int *out2, int *out3, int *out4)
	{
	short dummy,has_agi = 0, ap1,ap2,ap3,ap4;

  has_agi = ((_GemParBlk.global[0] == 0x399 && get_cookie('MagX',NULL))
            || (_GemParBlk.global[0] >= 0x400)
            || (mt_appl_find("?AGI", (short*)&_GemParBlk.global[0]) >= 0))
            || (mt_wind_get(0,WF_WINX,&dummy,&dummy,&dummy,&dummy, (short*)&_GemParBlk.global[0]) == WF_WINX);

	mt_appl_getinfo(64, &ap1, &ap2, &ap3, &ap4, (short*)&_GemParBlk.global[0]);
	aes_avail.lange_namen = ap3;

/*	appl_getinfo(20, &ap1, &ap2, &ap3, &ap4);
	aes_avail.get_window_owner = ap3;
*/
aes_avail.get_window_owner = 1;
	if (has_agi)
		return(mt_appl_getinfo((short)type,(short*)out1,(short*)out2,(short*)out3,(short*)out4, (short*)&_GemParBlk.global[0]));
	else
		return(0);
	}


int is_top(int handle)
	{
	short wid,i;
	
	mt_wind_get(DESK,WF_TOP,&wid,&i,&i,&i, (short*)&_GemParBlk.global[0]);
	return((wid) && (wid == handle));
	}



WORD MapKey(WORD keystate, WORD key)
{
	WORD scancode,ret;
	
	if (!kt)
		kt=(KEYTAB *)Keytbl((VOID *)-1L,(VOID *)-1L,(VOID *)-1L);
	
	scancode = (key >> 8) & 0xff;
	
	if ((keystate & KsALT) && (scancode >= 0x78) && (scancode <= 0x83))
		scancode -= 0x76;
	
	if (keystate & KsCAPS)
		ret = kt->capslock[scancode];
	else
	{
		if (keystate & KsSHIFT)
			ret = kt->shift[((scancode>=KbF11) && (scancode<=KbF20))?scancode-0x19:scancode];
		else
			ret = kt->unshift[scancode];
	}

	if (!ret)
		ret = scancode|KbSCAN;
	else
		if ((scancode == 0x4a) || (scancode == 0x4e) || ((scancode >= 0x63) && (scancode <= 0x72)))
			ret |= KbNUM;

	return(ret|(keystate << 8));
}


void fix_child(OBJECT *tree, int obj, int parent)
{
	do
	{
		mt_rsrc_obfix(tree,obj, (short*)&_GemParBlk.global[0]);
		
		if (tree[obj].ob_head>=0)
			fix_child(tree,tree[obj].ob_head,obj);
		
		obj = tree[obj].ob_next;
	}
	while (obj != parent);
}


void fix_tree(OBJECT *tree)
	{
	fix_child(tree,ROOT,-1);
	}


int dialog(OBJECT *tree, int mode)
	{
	short   cx,cy,cw,ch,ret,dummy,x,y,w,h, xx=tree->ob_x, yy=tree->ob_y;
	void *flyinf = calloc(1, 1000UL);

	mt_wind_update(BEG_UPDATE, (short*)&_GemParBlk.global[0]);
	mt_wind_update(BEG_MCTRL, (short*)&_GemParBlk.global[0]);

	if (MyTask.whandle>0)
		mt_wind_get(MyTask.whandle,WF_CURRXYWH,&x,&y,&w,&h, (short*)&_GemParBlk.global[0]);
	else
		x=y=w=h=0;

	mt_form_center(tree,&cx,&cy,&cw,&ch, (short*)&_GemParBlk.global[0]);
	if(mode==0)
		{
		tree->ob_x = cx = xx;
		tree->ob_y = cy = yy;
		}
  mt_graf_growbox(x,y,w,h,cx,cy,cw,ch, (short*)&_GemParBlk.global[0]);
	if(mode==0)
		{
	  mt_form_xdial(FMD_START,cx,cy,cw,ch,cx,cy,cw,ch,NULL, (short*)&_GemParBlk.global[0]);
	  mt_objc_draw(tree,ROOT,MAX_DEPTH,cx,cy,cw,ch, (short*)&_GemParBlk.global[0]);
  	ret = mt_form_xdo(tree,0,&dummy,NULL,NULL, (short*)&_GemParBlk.global[0]) & 0x7fff;

		mt_form_xdial(FMD_FINISH,cx,cy,cw,ch,cx,cy,cw,ch,NULL, (short*)&_GemParBlk.global[0]);
		}
	else
		{
	  mt_form_xdial(FMD_START,cx,cy,cw,ch,cx,cy,cw,ch,&flyinf, (short*)&_GemParBlk.global[0]);
	  mt_objc_draw(tree,ROOT,MAX_DEPTH,cx,cy,cw,ch, (short*)&_GemParBlk.global[0]);
  	ret = mt_form_xdo(tree, 0, &dummy, NULL, flyinf, (short*)&_GemParBlk.global[0]) & 0x7fff;

		mt_form_xdial(FMD_FINISH,cx,cy,cw,ch,cx,cy,cw,ch,&flyinf, (short*)&_GemParBlk.global[0]);
		}

	mt_graf_shrinkbox(x,y,w,h,cx,cy,cw,ch, (short*)&_GemParBlk.global[0]);

  mt_wind_update(END_MCTRL, (short*)&_GemParBlk.global[0]);
  mt_wind_update(END_UPDATE, (short*)&_GemParBlk.global[0]);

	tree[ret].ob_state &= ~OS_SELECTED;
	if(flyinf)
		free(flyinf);

	return(ret);
	}


long call_hsn(void)
{
	if (cs->load_sound(cs_fname)) cs->play_it(&cs->lbuf,1,0);
	return(0);
}


void play_sound(char *fname)
	{
	if (!fname) return;
	if (!strlen(fname)) return;

	if (!get_cookie('HSnd',(long *)&cs)) return;
	if (cs->version < SOUND_VERSION)
		return;
	if (cs->ruhe) return;

	cs_fname = fname;
	Supexec(call_hsn);
	}



void save_inf(void)
	{
	char inf[128];
	int  handle;
	long ret;
	
	strcpy(inf,home);
	strcat(inf,"defaults\\MyTask.hst");
	ret=Fcreate(inf,0);
	
	if (ret<0L)
		{
		strcpy(inf,home);
		strcat(inf,"MyTask.hst");
		ret=Fcreate(inf,0);
		}

	if (ret>=0L)
		{
		DHST *d = dhst;
		long  slen;
		int   danz = 0;
		Fattrib(inf, 1, 0);
			
		handle = (int)ret;
			
		while (d)
			{
			danz++;
			d = d->next;
			}
			
		Fwrite(handle,2,&danz);
			
		while (danz)
			{
			int dd = danz-1;
				
			d = dhst;
			while (dd)
				{
				dd--;
				d = d->next;
				}
				
			slen = (d->info.appname) ? (strlen(d->info.appname) + 1L) : 0L;
			Fwrite(handle,4,&slen);
			if (slen) Fwrite(handle,slen,d->info.appname);

			slen = (d->info.apppath) ? (strlen(d->info.apppath) + 1L) : 0L;
			Fwrite(handle,4,&slen);
			if (slen) Fwrite(handle,slen,d->info.apppath);

			slen = (d->info.docname) ? (strlen(d->info.docname) + 1L) : 0L;
			Fwrite(handle,4,&slen);
			if (slen) Fwrite(handle,slen,d->info.docname);

			slen = (d->info.docpath) ? (strlen(&(d->info.docpath[1])) + 1L) : 0L;
			Fwrite(handle,4,&slen);
			if (slen) Fwrite(handle,slen,&(d->info.docpath[1]));
				
			danz--;
			}

		Fclose(handle);
		}

	Save_options();
	}


void load_dhst(void)
{
	char inf[1024];
	long ret;
	int  handle;

	strcpy(inf,home);
	strcat(inf,"defaults\\MyTask.hst");
	ret=Fopen(inf,FO_READ);

	if (ret<0L)
	{
		strcpy(inf,home);
		strcat(inf,"MyTask.hst");
		ret=Fopen(inf,FO_READ);
	}	
	
	if (ret>=0L)
	{
		int      danz;
		long     slen;
		DHSTINFO dinfo;
		Fattrib(inf, 1, 0);
		
		handle = (int)ret;
		
		dinfo.appname = &(inf[0]);
		dinfo.docname = &(inf[100]);
		dinfo.apppath = &(inf[200]);
		dinfo.docpath = &(inf[600]);
		
		Fread(handle,2,&danz);
		
		while (danz)
		{
			Fread(handle,4,&slen);
			if (slen) Fread(handle,slen,dinfo.appname);
			else
				strcpy(dinfo.appname,"");

			Fread(handle,4,&slen);
			if (slen)
				Fread(handle,slen,dinfo.apppath);
			else
				strcpy(dinfo.apppath,"");

			Fread(handle,4,&slen);
			if (slen) Fread(handle,slen,dinfo.docname);
			else
				strcpy(dinfo.docname,"");

			Fread(handle,4,&slen);
			if (slen) Fread(handle,slen,dinfo.docpath);
			else
				strcpy(dinfo.docpath,"");
			
			add_dhst(&dinfo);
			
			danz--;
		}

		Fclose(handle);
	}
}


int get_system_parameter(char *startset, BOOLEAN opt)
{
	char       *dummy,inf[128],buf[512],entryname[40],smp[128];		/*,rsc[128];*/
	int         handle,state,level,cnfline,agi1,agi2,agi3,agi4,
	            rscobj = -1, i;
	long        ret,deskcol = 0x0000004cL;
	STARTMENU  *curr;
	STARTENTRY *lastfile;
	ALIAS      *dalias;

	mt_wind_get(DESK,WF_WORKXYWH,&desk.g_x,&desk.g_y,&desk.g_w,&desk.g_h, (short*)&_GemParBlk.global[0]);

	mt_menu_settings(0,&mnset, (short*)&_GemParBlk.global[0]);
	findstic();

	for (i=0;i<26;i++) labels[i]=NULL;

	if(avfile==NULL)
		avfile = (char *)calloc(1, 256L);
	if(avextall==NULL)
		avextall = (char *)calloc(1, 128L);

	if (avextall)
	{
		avextusr = avextall + 8L;
		strcpy(avextall,"*");
	}
	
	defcmd = (char *)calloc(1, 128L);
	if (defcmd)
	{
		defcmd[0]=0;
		defcmd[1]=0;
	}

	shutdown[0] = 0;
	nolabel[0]  = 0;
	logfile[0]  = 0;


/*	strcpy(startpath,home);
	strcat(startpath,"MyTask\\"); */
	
	startinf.version  = INFVER;
	startinf.workxabs = -2000;
	startinf.workyabs = 30000;
	
	if(opt)
		Load_options();

	if(alias_name==NULL)
		importiere_longname("MltiStrp.inf");

	if (startset)
	{
		strcpy(inf,startset);
		ret=Fopen(inf,FO_READ);
	}
	else
	{
		strcpy(inf,home);
		strcat(inf,"defaults\\MyTask.set");
		ret=Fopen(inf,FO_READ);
	
		if (ret<0L)
		{
			strcpy(inf,home);
			strcat(inf,"MyTask.set");
			ret=Fopen(inf,FO_READ);
		}	
	
		if (ret<0L)
		{
			strcpy(inf,"MyTask.set");
			ret=Fopen(inf,FO_READ);
		}
	}
	
	if (ret>=0L)
	{
		handle  = (int)ret;
		level   = 0;
		cnfline = 0;
		
		menus = (STARTMENU *)calloc(1, sizeof(STARTMENU));
		if (!menus)
			{
			mt_form_alert(1,message[MSG_CNFMEM_ERROR], (short*)&_GemParBlk.global[0]);
			return(0);
			}

		menus->tree     = NULL;
		menus->entries  = NULL;
		menus->children = NULL;
		menus->next     = NULL;
		menus->parent   = NULL;
		
		curr = menus;

		_nextline:
		while (Fgets(buf,511,handle))
		{
			cnfline++;
			
			dummy=strrchr(buf,13);
			if (dummy) *dummy=0;
			dummy=strrchr(buf,10);
			if (dummy) *dummy=0;
			
			if (strlen(buf))
			{
				state = 0;
				dummy = strtok(buf,"\x09");

				while (dummy)
				{
					if (strlen(dummy))
					{
						switch(state)
						{
							case 0:
								if (dummy[0]=='#') goto _nextline;
								else if (!stricmp(dummy,"/files")) state=13;
								else if (!stricmp(dummy,"/file")) state=10;
								else if (!stricmp(dummy,"/menu")) state=20;
								else if (!stricmp(dummy,"/end"))
								{
									level--;
									
									if (level<0)
									{
										cnf_error(MSG_CNF_ERROR,cnfline);
										return(0);
									}
									
									curr = curr->parent;

									goto _nextline;
								}
								else if (!stricmp(dummy,"/separator"))
								{
									STARTENTRY *se     = curr->entries,
									           *selast = NULL;
									           
									while (se)
									{
										selast = se;
										se = se->next;
									}
									
									se = (STARTENTRY *)calloc(1, sizeof(STARTENTRY));
									if (!se)
									{
										mt_form_alert(1,message[MSG_CNFMEM_ERROR], (short*)&_GemParBlk.global[0]);
										return(0);
									}
									
									se->name  = NULL;
									se->file  = NULL;
									se->fcmd  = NULL;
									se->next  = NULL;
									se->flags = 0;

									if (!selast)
										curr->entries = se;
									else
										selast->next = se;

									goto _nextline;
								}
								else if (!stricmp(dummy,"/group")) state=25;
								else if (!stricmp(dummy,"/folder")) state=50;
								else if (!stricmp(dummy,"/alias")) state=100;
								else if (!stricmp(dummy,"/timer")) state=110;
								else if (!stricmp(dummy,"/label")) state=120;
								else if (!stricmp(dummy,"/shutdown")) state=30;
								else if (!stricmp(dummy,"/shutdown_timeout")) state=32;
								else if (!stricmp(dummy,"/documents_max")) state=33;
								else if (!stricmp(dummy,"/documents_maxperapp")) state=34;
								else if (!stricmp(dummy,"/logfile")) state=35;
								else if (!stricmp(dummy,"/name")) state=200;
								else if (!stricmp(dummy,"/applications_max")) state=36;
								else if (!stricmp(dummy,"/hide")) state=37;
								else if (!stricmp(dummy,"/applications"))
								{
									applications=1;
									goto _nextline;
								}
								else if (!stricmp(dummy,"/desktop"))
								{
									desktop=1;
									state=80;
									break;
								}
								else if (!strnicmp(dummy,"/sample_",8))
								{
									strcpy(smp,dummy+8);
									state=40;
									break;
								}
								else if (!strnicmp(dummy,"/pop_",5))
								{
									strcpy(smp,dummy+5);
									state=60;
									break;
								}
								else if (!stricmp(dummy,"/backwind"))
								{
									untop=1;
									goto _nextline;
								}
/*								else if (!stricmp(dummy,"/resource")) state=70;	*/
								else if (!stricmp(dummy,"/nolabel")) state=90;
								else if (!stricmp(dummy,"/appline"))
								{
									applinepos=1;
									goto _nextline;
								}
								else if (!stricmp(dummy,"/wmclosed"))
								{
									wmclosed=1;
									goto _nextline;
								}
								else if (!stricmp(dummy,"/nowindow"))
								{
									nowindow=1;
									goto _nextline;
								}
								else {
									cnf_error(MSG_CNF_ERROR,cnfline);
									return(0);
								}
								break;
							
							case 10:								/* "/file"		*/
							case 50:								/* "/folder"	*/
								strncpy(entryname,dummy,40);
								state++;
								break;

							case 13:								/* "/files"		*/
									{
									int i=(int)strlen(dummy);
									DTA *mydta=NULL;
									mydta = Fgetdta();
									
									strncpy(entryname,dummy,40);
									
									while(dummy[i]!='\\')
										dummy[i--]=0;
									if(Fsfirst(entryname, 0)==0)
										{
										do
											{
											STARTENTRY *se     = curr->entries,
											           *selast = NULL;

											strcpy(entryname, mydta->d_fname);
											while (se)
											{
												selast = se;
												se = se->next;
											}
									
											se = (STARTENTRY *)calloc(1, sizeof(STARTENTRY));
											if (!se)
											{
												mt_form_alert(1,message[MSG_CNFMEM_ERROR], (short*)&_GemParBlk.global[0]);
												return(0);
											}
									
											get_alias(&dummy);
									
											se->name  = (char *)calloc(1, strlen(entryname)+1L);
											se->file  = (char *)calloc(1, strlen(dummy)+1L+strlen(entryname));
											se->fcmd  = NULL;
											se->next  = NULL;
											se->flags = SE_FILE;
									
											if ((!se->name) || (!se->file))
											{
												mt_form_alert(1,message[MSG_CNFMEM_ERROR], (short*)&_GemParBlk.global[0]);
												return(0);
											}
									
											strcpy(se->name, entryname);
											sprintf(se->file,"%s%s", dummy, entryname);
									
											lastfile = se;

											if (!selast)
												curr->entries = se;
											else
												selast->next = se;
										}
									while(Fsnext()==0);
									}
								break;
								}
							
							case 11:								/* "/file"		*/
							case 51:								/* "/folder"	*/
								{
									STARTENTRY *se     = curr->entries,
									           *selast = NULL;

									while (se)
									{
										selast = se;
										se = se->next;
									}
									
									se = (STARTENTRY *)calloc(1, sizeof(STARTENTRY));
									if (!se)
									{
										mt_form_alert(1,message[MSG_CNFMEM_ERROR], (short*)&_GemParBlk.global[0]);
										return(0);
									}
									
									get_alias(&dummy);
									
									se->name  = (char *)calloc(1, strlen(entryname)+1L);
									se->file  = (char *)calloc(1, strlen(dummy)+1L);
									se->fcmd  = NULL;
									se->next  = NULL;
									se->flags = (state==11)?SE_FILE:SE_FOLDER;
									
									if ((!se->name) || (!se->file))
									{
										mt_form_alert(1,message[MSG_CNFMEM_ERROR], (short*)&_GemParBlk.global[0]);
										return(0);
									}
									
									strcpy(se->name,entryname);
									strcpy(se->file,dummy);
									
									lastfile = se;

									if (!selast) curr->entries = se;
									else
										selast->next = se;
								}
								
								if (state==51) goto _nextline;
								state++;
								break;
							
							case 12:
								if (lastfile)
								{
									get_alias(&dummy);

									lastfile->fcmd = (char *)calloc(1, strlen(dummy)+2L);

									if (lastfile->fcmd)
									{
										strcpy(&(lastfile->fcmd[1]),dummy);
										lastfile->fcmd[0]=min(strlen(dummy),125);
									}
								}
								goto _nextline;
							
							case 20:
								{
									STARTENTRY *se     = curr->entries,
									           *selast = NULL;
									STARTMENU  *sm     = curr->children,
									           *smlast = NULL;

									while (se)
									{
										selast = se;
										se = se->next;
									}

									while (sm)
									{
										smlast = sm;
										sm = sm->next;
									}
									
									se = (STARTENTRY *)calloc(1, sizeof(STARTENTRY));
									sm = (STARTMENU *)calloc(1, sizeof(STARTMENU));
									
									if ((!se) || (!sm))
									{
										mt_form_alert(1,message[MSG_CNFMEM_ERROR], (short*)&_GemParBlk.global[0]);
										return(0);
									}
									
									se->name  = (char *)calloc(1, strlen(dummy)+1L);
									se->file  = NULL;
									se->fcmd  = NULL;
									se->next  = NULL;
									se->flags = 0;
									
									if (!se->name)
									{
										mt_form_alert(1,message[MSG_CNFMEM_ERROR], (short*)&_GemParBlk.global[0]);
										return(0);
									}
									
									strcpy(se->name,dummy);

									if (!selast)
										curr->entries = se;
									else
										selast->next = se;

									if (!smlast)
										curr->children = sm;
									else
										smlast->next = sm;
									
									sm->tree     = NULL;
									sm->entries  = NULL;
									sm->children = NULL;
									sm->next     = NULL;
									sm->parent   = curr;
									
									curr = sm;
									level++;
									
									if (level>3)
									{
										cnf_error(MSG_NEST_ERROR,cnfline);
										return(0);
									}
								}
								goto _nextline;
							
							case 25:
								if (level>=3)
								{
									cnf_error(MSG_NEST_ERROR,cnfline);
									return(0);
								}
								
								if (!(read_group(dummy,curr)))
								{
									cnf_error(MSG_THING_GROUP,cnfline);
									return(0);
								}
								goto _nextline;
							
							case 30:
								strncpy(shutdown,dummy,127);
								goto _nextline;
							
							case 32:
								shuttimeout=(int)atol(dummy);
								goto _nextline;

							case 33:
								docmax=max(3,(int)atol(dummy));
								goto _nextline;

							case 34:
								docmaxperapp=max(1,(int)atol(dummy));
								goto _nextline;

							case 35:
								strncpy(logfile,dummy,127);
								goto _nextline;
							
							case 36:
								appmax=max(3,(int)atol(dummy));
								goto _nextline;

							case 37:
								Add_app_to_not_show(-1, dummy);
								goto _nextline;

							case 40:
								{
									char *fle;
									
									get_alias(&dummy);
									fle = (char *)calloc(1, strlen(dummy)+1L);
									
									if (fle)
									{
										strcpy(fle,dummy);
										
										if (!stricmp(smp,"boot")) sampleboot=fle;
										else if (!stricmp(smp,"open")) sampleopen=fle;
										else if (!stricmp(smp,"start")) samplestart=fle;
										else if (!stricmp(smp,"avfail")) sampleavfail=fle;
										else if (!stricmp(smp,"term")) sampleterm=fle;
										else if (!stricmp(smp,"close")) sampleclose=fle;
										else if (!stricmp(smp,"timer")) sampletimer=fle;
									}
								}	
								goto _nextline;
							
							case 60:
								{
									long value = atol(dummy);
									
									if (!stricmp(smp,"display"))
										mnset.display=value;
									else
									{
										if (!stricmp(smp,"drag"))
											mnset.drag=value;
									}
								}
								goto _nextline;
							
/*							case 70:
								strcpy(rsc, dummy);
								state++;
								break;
*/
							case 71:
								rscobj=(int)atol(dummy);
								goto _nextline;
							
							case 80:
								deskcol=atol(dummy);
								goto _nextline;
							
							case 90:
								strncpy(nolabel,dummy,27);
								goto _nextline;

							case 100:
								strncpy(smp,dummy,127);
								state++;
								break;
							
							case 101:
								{
									dalias = (ALIAS *)calloc(1, sizeof(ALIAS));
									
									if (dalias)
									{
										dalias->next = alias;
										alias = dalias;
									
										strcpy(dalias->old,"$");
										strcat(dalias->old,smp);
										strcpy(dalias->new,dummy);
									}
								}
								goto _nextline;
							
							case 110:
								strcpy(smp,dummy);
								state++;
								break;
							
							case 111:
								{
									int    h = -1,m = -1;
									char  *mc = strchr(smp,':');
									TIMER *ti;
									
									if (mc)
									{
										*mc=0;
										h = (int)atol(smp);
										m = (int)atol(++mc);
									}
									
									if (!between(h,0,23) || !between(m,0,59))
									{
										cnf_error(MSG_CNF_ERROR,cnfline);
										return(0);
									}

									ti = (TIMER *)calloc(1, sizeof(TIMER));
									if (!ti)
									{
										mt_form_alert(1,message[MSG_CNFMEM_ERROR], (short*)&_GemParBlk.global[0]);
										return(0);
									}

									get_alias(&dummy);
									
									ti->file = (char *)calloc(1, strlen(dummy)+1L);
									ti->fcmd = NULL;
									ti->next = timer;
									ti->time = (((long)h << 11) | ((long)m << 5)) & 0x0000ffe0;
									
									if (!ti->file)
									{
										mt_form_alert(1,message[MSG_CNFMEM_ERROR], (short*)&_GemParBlk.global[0]);
										return(0);
									}
									
									strcpy(ti->file,dummy);
									
									timer = ti;
								}
								state++;
								break;
							
							case 112:
								if (timer)
								{
									get_alias(&dummy);

									timer->fcmd = (char *)calloc(1, strlen(dummy)+2L);

									if (timer->fcmd)
									{
										strcpy(&(timer->fcmd[1]),dummy);
										timer->fcmd[0]=min(strlen(dummy),125);
									}
								}
								goto _nextline;
							
							case 120:
								{
									strcpy(smp,dummy);

									if ((strlen(smp)>1) || (smp[0]<'A') || (smp[0]>'Z'))
									{
										cnf_error(MSG_CNF_ERROR,cnfline);
										return(0);
									}
								}
								state++;
								break;
							
							case 121:
								{
									char *dname = (char *)calloc(1, strlen(dummy)+1L);

									if (!dname)
									{
										mt_form_alert(1,message[MSG_CNFMEM_ERROR], (short*)&_GemParBlk.global[0]);
										return(0);
									}
									
									strcpy(dname,dummy);
									labels[smp[0]-'A'] = dname;
								}
								goto _nextline;

							case 200:			/* name			*/
								if(!extrsc)
									{
									if(strcmp(options.name, "MyTask")==0)
										{
										free((char*)bigbutton[START_BUTTON].ob_spec.free_string);
										bigbutton[START_BUTTON].ob_spec.free_string = calloc(1, strlen(dummy)+1L);
										memset((char*)bigbutton[START_BUTTON].ob_spec.free_string, ' ', strlen(dummy)+1);
										strcpy((char*)bigbutton[START_BUTTON].ob_spec.free_string, dummy);
										bigbutton[START_BUTTON].ob_width = (int)strlen((char*)bigbutton[START_BUTTON].ob_spec.free_string) + 2;
										strcpy(options.name, dummy);
										}
									else
										{
										bigbutton[START_BUTTON].ob_spec.free_string = calloc(1, strlen(options.name)+1L);
										memset((char*)bigbutton[START_BUTTON].ob_spec.free_string, ' ', strlen(options.name)+1);
										strcpy((char*)bigbutton[START_BUTTON].ob_spec.free_string, options.name);
										bigbutton[START_BUTTON].ob_width = (int)strlen((char*)bigbutton[START_BUTTON].ob_spec.free_string) + 2;
										}
									}
								goto _nextline;

						}
					}

					dummy = strtok(NULL,"\x09");
				}
			}
		}

		Fclose(handle);
	}

/*	if (!options.magxignore)
	{
		MAGX_COOKIE *cv;
		
		if (get_cookie('MagX',(long *)&cv))
		{
			if (cv->aesvars)
			{
				if (cv->aesvars->version<0x0400)
				{
					mt_form_alert(1,message[MSG_MAGX_VERSION], (short*)&_GemParBlk.global[0]);
					return(0);
				}
			}
			else
			{
				mt_form_alert(1,message[MSG_MAGX_ERROR], (short*)&_GemParBlk.global[0]);
				return(0);
			}
		}
		else
		{
			mt_form_alert(1,message[MSG_MAGX_ERROR], (short*)&_GemParBlk.global[0]);
			return(0);
		}
	}
	else	*/
	{
		MAGX_COOKIE *cv;

		if (get_cookie('MagX',(long *)&cv))
		{
			if (cv->aesvars)
			{
				if (cv->aesvars->version<0x0400) dobroadcast=0;
			}
		}
	}
	
	if (appl_xgetinfo(9,&agi1,&agi2,&agi3,&agi4))
	{
		if ((!agi1) || (!agi2))
		{
			mt_form_alert(1,message[MSG_XMEN_ERROR], (short*)&_GemParBlk.global[0]);
			return(0);
		}
	}
	else
	{
		mt_form_alert(1,message[MSG_XMEN_ERROR], (short*)&_GemParBlk.global[0]);
		return(0);
	}
	
	if (extrsc)
		{
		if (mt_rsrc_load(options.rsc, (short*)&_GemParBlk.global[0]))
			{
			OBJECT *adres = NULL;
			mt_rsrc_gaddr(R_TREE, 0, &adres, (short*)&_GemParBlk.global[0]);
			adres[options.start_rsc_obj].ob_y = 0;
			memcpy(&bigbutton[START_BUTTON], &adres[options.start_rsc_obj], sizeof(OBJECT));
			bigbutton[START_BUTTON].ob_next = 2;
			bigbutton[START_BUTTON].ob_head = -1;
			bigbutton[START_BUTTON].ob_tail = -1;
			if(options.start_icon_text==0)
				{
				if(strlen(bigbutton[START_BUTTON].ob_spec.iconblk->ib_ptext)>1)
					bigbutton[START_BUTTON].ob_width = bigbutton[START_BUTTON].ob_spec.iconblk->ib_wicon;
				bigbutton[START_BUTTON].ob_spec.iconblk->ib_wtext = 0;
				bigbutton[START_BUTTON].ob_spec.iconblk->ib_htext = 0;
				bigbutton[START_BUTTON].ob_spec.iconblk->ib_ytext = 0;
				bigbutton[START_BUTTON].ob_spec.iconblk->ib_xchar = 0;
				bigbutton[START_BUTTON].ob_spec.iconblk->ib_ychar = 0;
				}
			bigbutton[START_BUTTON].ob_spec.iconblk->ib_xtext = 0;
			bigbutton[START_BUTTON].ob_width /= 8;
			bigbutton[START_BUTTON].ob_height /= 8;
/*			btnidx=rscobj;	*/
			}
		}

	if (menus)
		{
		menus->tree = build_popup(menus, options.drives, options.documents, applications);

		if (menus->tree)
			{
			bigbutton[START_BUTTON].ob_state &= ~OS_DISABLED;
			attach_popups(menus, options.drives, options.documents, applications);
			}
		}
	
	startdesk[ROOT].ob_spec.index = deskcol;

	while (alias)
		{
		dalias = alias->next;
		if(alias)
			free(alias);
		alias=dalias;
		}

	return(1);
}

void init_vdi(void)
	{
	short i,work_in[12],work_out[57];
	
	MyTask.v_handle = mt_graf_handle(&i,&i,&i,&i, (short*)&_GemParBlk.global[0]);
	
	for (i=0; i<10; work_in[i++]=1);
	work_in[10]=2;
	
	v_opnvwk(work_in,&MyTask.v_handle,work_out);
	desktop_w = work_out[0];
	desktop_h = work_out[1];

	if (MyTask.v_handle)
		{
		colors = work_out[13];

		vsf_interior(MyTask.v_handle,FIS_PATTERN);
		vsf_style(MyTask.v_handle,4);
		vswr_mode(MyTask.v_handle,MD_TRANS);
		}
	}


void exit_vdi(void)
	{
	if (MyTask.v_handle)
		v_clsvwk(MyTask.v_handle);
	}


#define CUR_HOME   "\33H"
#define Cur_home() Cconws( CUR_HOME )

void free_tree(OBJECT *pop)
	{
	int i;
	if(!pop)
		return;
	for(i=0; i<pop->ob_tail; i++)
		{
		if(pop[i].ob_type==G_FTEXT || pop[i].ob_type==G_TEXT || pop[i].ob_type==G_BOXTEXT || pop[i].ob_type==G_STRING || pop[i].ob_type==G_FBOXTEXT)
			{
			if(pop[i].ob_spec.free_string)				/* POPRAWIC - sprawdzic czy obiekt to tekst czy moze cos innego	*/
				free(pop[i].ob_spec.free_string);
			}
		}
	free(pop);
	}

void free_child(STARTMENU  *child)
	{
	STARTMENU  *curr = child;
	while(curr)
		{
		if(curr->tree)
			free_tree(curr->tree);
		if(curr->children)
			free_child(curr->children);
		curr = curr->next;
		}
	}

void free_menus(void)
	{
	STARTMENU  *curr = menus;

	while(curr)
		{
		free_child(curr->children);
		curr = curr->next;
		}
	free(menus);
	}

extern int debug_handle;

void main(int argc, const char *argv[])
	{
	#ifdef MEMDEBUG
		char *f_Erre = "MEM_ERR.DAT";
		char *f_Stat = "MEM_OUT.DAT";

		Fattrib(f_Erre, 1, 0);
		Fattrib(f_Stat, 1, 0);
		#define SLONG_MAX	1048576UL*64UL	/* 64 MB max */

		Fdelete (f_Erre);
		Fdelete (f_Stat);

		set_MemdebugOptions (c_Yes, c_Yes, c_Yes, c_No, c_Yes, c_Yes, c_Yes, 0, SLONG_MAX, f_Stat, f_Erre);
	#endif

#ifdef _DEBUG
	debug_handle = -1;
#endif

	_GemParBlk.global[0] = 0;
  ap_id = mt_appl_init((short*)&_GemParBlk.global[0]);
  sended_gsc_ln = 0;
	get_paths();

DEBUG

  if (!_GemParBlk.global[0])
  	{
  	Cconws(message[MSG_AUTO_ERROR]);
	  exit(0);
	  }

DEBUG

	Cur_home();

  if (ap_id>=0)
  	{
		MAGX_COOKIE *cv;

DEBUG

		Psignal(SIGTERM,sig_handler);
		Psignal(SIGQUIT,sig_handler);
  	Pdomain(1);


DEBUG

    mt_graf_mouse(BUSYBEE,NULL, (short*)&_GemParBlk.global[0]);

		mt_shel_write(9,1,0,NULL,NULL, (short*)&_GemParBlk.global[0]);
		
		init_vdi();

DEBUG

		Default_options();

DEBUG

		if (!get_system_parameter((argc==2)?(char *)argv[1]:NULL,TRUE))
			goto _raus;

		if (!get_cookie('DHST',NULL) && options.dhstcookie==1)
			new_cookie('DHST',ap_id);

		menu_id = mt_menu_register(ap_id,menuentry, (short*)&_GemParBlk.global[0]);
		mt_menu_register(-1,"MyTask  ", (short*)&_GemParBlk.global[0]);

		load_dhst();
		if (options.savelinks)
			create_links();

		play_sound(sampleboot);
		init_app_menu();
DEBUG

		prepare_time_object();
/*		prepare_applications_list();	*/

		fix_tree(bigbutton);
		fix_tree(startpopup);
		fix_tree(apppopup);
		fix_tree(monthspopup);
		fix_tree(object_info);
		fix_tree(startdesk);
		fix_tree(deskmenu);
		fix_tree(calender);
		fix_tree(popup_app_icon);
		fix_width();											/* Korekcja polozenia i wielkosci "nowych" obiektow	*/

		if (MyTask.v_handle)
			{
			startpopup[2].ob_type = G_USERDEF;
			startpopup[2].ob_spec.userblk = &usrdef;

			startpopup[6].ob_type = G_USERDEF;
			startpopup[6].ob_spec.userblk = &usrdef;

			startpopup[10].ob_type = G_USERDEF;
			startpopup[10].ob_spec.userblk = &usrdef;

			apppopup_magic[3].ob_type = G_USERDEF;
			apppopup_magic[3].ob_spec.userblk = &usrdef;

			apppopup_magic[12].ob_type = G_USERDEF;
			apppopup_magic[12].ob_spec.userblk = &usrdef;

			apppopup_magic[15].ob_type = G_USERDEF;
			apppopup_magic[15].ob_spec.userblk = &usrdef;

			if(transparent)
				{
				bigbutton[0].ob_type = 0;
				bigbutton[0].ob_flags = 0;
				usrdef_bigbutton.ub_parm = 0;
				usrdef_bigbutton.ub_code = draw_bigbutton;
				bigbutton[0].ob_type = G_USERDEF;
				bigbutton[0].ob_spec.userblk = &usrdef_bigbutton;
				}
			}

		sprintf(tedinfo_info[TIINFO_GEMLIB].te_ptext, "GEMLib version: %d.%d.%d", (int)__GEMLIB_MAJOR__, (int)__GEMLIB_MINOR__, (int)__GEMLIB_REVISION__);

DEBUG

		if (get_cookie('MagX',(long *)&cv))
			{
			if (cv->aesvars)
				{
				if ((cv->aesvars->version >= 0x0514) && (colors >= 9))
					{
					extmagxmenu = 1;
					vsl_color(MyTask.v_handle,9);
					}

				mxdate = (cv->aesvars->date << 16) | (cv->aesvars->date >> 24) | ((cv->aesvars->date >> 8) & 0x0000ff00L);

				if (mxdate >= 0x19971030L)
					{
					startpopup[1].ob_type = G_SHORTCUT;
					startpopup[3].ob_type = G_SHORTCUT;
					startpopup[4].ob_type = G_SHORTCUT;
					startpopup[7].ob_type = G_SHORTCUT;
					startpopup[8].ob_type = G_SHORTCUT;
					startpopup[11].ob_type = G_SHORTCUT;
					}
				}
			}
/*
		fuelle_applikationen();
		fuelle_knoepfe();
*/

    open_main_window();
    if (MyTask.whandle>0)
    	mt_wind_set(MyTask.whandle,WF_BOTTOM,0,0,0,0, (short*)&_GemParBlk.global[0]);

		final_init();
    mt_graf_mouse(ARROW,NULL, (short*)&_GemParBlk.global[0]);

		MyTask.org_x = bigbutton->ob_x;
		MyTask.org_y = bigbutton->ob_y;
		MyTask.org_w = bigbutton->ob_width;
		MyTask.org_h = bigbutton->ob_height;
		mt_wind_get(MyTask.whandle,WF_CURRXYWH,&MyTask.cur_x,&MyTask.cur_y,&MyTask.cur_w,&MyTask.cur_h, (short*)&_GemParBlk.global[0]);

DEBUG

		make_appl_list();			/* Robimy pierwszy raz liste wszystkich obecnie dzialajacych aplikacji	*/
DEBUG
		if ((MyTask.whandle>0) || (nowindow) || (!_app))
			{
DEBUG
	    event_loop();

	    save_inf();
			if (options.savelinks)
				store_links();
	    
	    play_sound(sampleterm);
			}

    cleanup(1);

_raus:
		if (options.dhstcookie==1 || get_cookie('DHST',NULL))
			remove_cookie('DHST');
		if(_applications_)
			free(_applications_);
		if(DoNotShow);
			free(DoNotShow);
		if(FontsID);
			free(FontsID);
		if(pipe)
			free(pipe);
		if(usrdef_button)
			free(usrdef_button);
		if(usrdef_options)
			free(usrdef_options);
		if(alias)
			free(alias);
		if(bubblehelp)
			free(bubblehelp);
		if(menus)
			free_menus();
		reset_texts();
		free_alias();
		exit_vdi();
    mt_appl_exit((short*)&_GemParBlk.global[0]);
	  }
  exit(0);
	}


void create_links(void)
{
	long ret;
	int  handle;
	LINK link;
	char inf[128];

	strcpy(inf,home);
	strcat(inf,"defaults\\MyTask.lnk");
	ret=Fopen(inf,FO_READ);

	if (ret<0L)
	{
		strcpy(inf,home);
		strcat(inf,"MyTask.lnk");
		ret=Fopen(inf,FO_READ);
	}	
	
	if (ret>=0L)
	{
		int pipe[8];
		Fattrib(inf, 1, 0);
		
		handle = (int)ret;
		
		while (Fread(handle,sizeof(LINK),&link) == sizeof(LINK)) Fsymlink(link.path,link.name);

		Fclose(handle);
		
		pipe[0] = SH_WDRAW;
		pipe[1] = ap_id;
		pipe[2] = 0;
		pipe[3] = 'U'-'A';
		pipe[4] = 0;
		pipe[5] = 0;
		pipe[6] = 0;
		pipe[7] = 0;
		
		mt_appl_write(DESK,16,&pipe, (short*)&_GemParBlk.global[0]);
	}
}


void store_links(void)
{
	long  ret,handle;
	int   fhdl;
	LINK  link;
	XATTR attr;
	char  inf[128],name[36];

	strcpy(inf,home);
	strcat(inf,"defaults\\MyTask.lnk");
	ret=Fcreate(inf,0);

	if (ret<0L)
	{
		strcpy(inf,home);
		strcat(inf,"MyTask.lnk");
		ret=Fcreate(inf,0);
	}

	if (ret>=0L)
	{
		fhdl = (int)ret;
		Fattrib(inf, 1, 0);
		
		handle = Dopendir("U:\\",0);
		
		if ((handle & 0xff000000L) != 0xff000000L)
		{
			while (!Dreaddir(36,handle,name))
			{
				strcpy(link.name,"U:\\");
				strcat(link.name,&name[4]);
				
				if (!Fxattr(1,link.name,&attr))
				{
					if (((attr.mode >> 12) & 0x000f) == 14)
					{
						if (!Freadlink(256,link.path,link.name)) Fwrite(fhdl,sizeof(LINK),&link);
					}
				}
			}
			
			Dclosedir(handle);
		}

		Fclose(fhdl);
	}
}


void cleanup(int broadcast)
	{
	int pipe[8];
	
	if (apterm)
		return;

	if (MyTask.whandle>0)
		{
		mt_wind_close(MyTask.whandle, (short*)&_GemParBlk.global[0]);
		mt_wind_delete(MyTask.whandle, (short*)&_GemParBlk.global[0]);
		MyTask.whandle=-1;
		}
	if (MyTask.wh_calendar>0)
		{
		mt_wind_close(MyTask.wh_calendar, (short*)&_GemParBlk.global[0]);
		mt_wind_delete(MyTask.wh_calendar, (short*)&_GemParBlk.global[0]);
		MyTask.wh_calendar=-1;
		}
	
	if ((!options.avignore) && (broadcast) && (dobroadcast))
		{
		pipe[0]=AV_EXIT;
		pipe[1]=ap_id;
		pipe[2]=0;
		pipe[3]=ap_id;
		pipe[4]=0;
		pipe[5]=0;
		pipe[6]=0;
		pipe[7]=0;
	
		mt_shel_write(SHW_BROADCAST,0,0,(char *)pipe,NULL, (short*)&_GemParBlk.global[0]);
		}

	if ((broadcast) && (dobroadcast))
		{
		pipe[0]=ACC_EXIT;
		pipe[1]=ap_id;
		pipe[2]=0;
		pipe[3]=0;
		pipe[4]=0;
		pipe[5]=0;
		pipe[6]=0;
		pipe[7]=0;
	
		mt_shel_write(SHW_BROADCAST,0,0,(char *)pipe,NULL, (short*)&_GemParBlk.global[0]);
		}
	
	if (desktop)
		{
		mt_menu_bar(deskmenu,0, (short*)&_GemParBlk.global[0]);
		mt_wind_set(DESK,WF_NEWDESK,0,0,0,0, (short*)&_GemParBlk.global[0]);
		}
	
	if (extrsc || mini_icons!=NULL)
		mt_rsrc_free((short*)&_GemParBlk.global[0]);
	}


void findstic(void)
	{
	stic = NULL;

	if (get_cookie('StIc',(long *)&stic))
		{
		if (stic)
			{			/* Werja byla 0x0110, ale takiego wysokiego nr dla StIc nie ma wogole!!
							dlatego sprawdzamy obecnosc ostatniej wypuszczonej wersji 1.0!	*/
			if ((stic->version<0x0100) || (stic->magic !='StIc'))
				stic=NULL;
			}
		}
	else
		{
		start_app(0,SHW_PARALLEL,"STIC","stic.app",NULL);
/*		start_app(0,SHW_PARALLEL,"c:\\gemsys\\magic\\start\\stic.app",NULL);	*/
		mt_evnt_timer(1000, (short*)&_GemParBlk.global[0]);
		if(get_cookie('StIc',(long *)&stic))
			{
			if ((stic->version<0x0100) || (stic->magic !='StIc'))
				stic=NULL;
			}
		}
	}


void final_init(void)
{
	int   pipe[8];
	
	usrdef.ub_code = draw_menu_rect;
	usrdef.ub_parm = 0L;

	mt_menu_settings(1,&mnset, (short*)&_GemParBlk.global[0]);

	if (desktop)
		{
		startdesk[ROOT].ob_x = desk.g_x;
		startdesk[ROOT].ob_y = desk.g_y;
		startdesk[ROOT].ob_width = desk.g_w;
		startdesk[ROOT].ob_height = desk.g_h;

		mt_wind_set(DESK,WF_NEWDESK,(int)(((long)&startdesk >> 16) & 0x0000ffffL),(int)((long)&startdesk & 0x0000ffffL),ROOT,0, (short*)&_GemParBlk.global[0]);
		mt_form_dial(FMD_FINISH,desk.g_x,desk.g_y,desk.g_w,desk.g_h,desk.g_x,desk.g_y,desk.g_w,desk.g_h, (short*)&_GemParBlk.global[0]);
		
		mt_menu_bar(deskmenu,1, (short*)&_GemParBlk.global[0]);
		}

	xaccname = (char *)calloc(1, 96L);
	if (xaccname)
	{
		strncpy(xaccname,"MyTask",95);
		strcpy(xaccname+13,"XDSC");
		strcpy(xaccname+18,"2DT");
		strcpy(xaccname+22,"NSTART");
		strcpy(xaccname+29,xaccusr);
		
		gslongname = xaccname+64;
		strcpy(gslongname,"MyTask");
	}
/*
	if (dobroadcast)
	{
		pipe[0]=ACC_ID;
		pipe[1]=ap_id;
		pipe[2]=0;
		pipe[3]=0;
		pipe[4]=(int)(((long)xaccname >> 16) & 0x0000ffffL);
		pipe[5]=(int)((long)xaccname & 0x0000ffffL);
		pipe[6]=menu_id;
		pipe[7]=0;

		mt_shel_write(SHW_BROADCAST,0,0,(char *)pipe,NULL, (short*)&_GemParBlk.global[0]);
	}
*/
	if (!options.avignore)
	{
		accname = (char *)calloc(1, 16L);
		if (accname) strcpy(accname,"MyTask  ");

		if (dobroadcast)
		{
			pipe[0]=AV_PROTOKOLL;
			pipe[1]=ap_id;
			pipe[2]=0;
			pipe[3]=AVMSG;
			pipe[4]=0;
			pipe[5]=0;
			pipe[6]=(int)(((long)accname >> 16) & 0x0000ffffL);
			pipe[7]=(int)((long)accname & 0x0000ffffL);
	
			mt_shel_write(SHW_BROADCAST,0,0,(char *)pipe,NULL, (short*)&_GemParBlk.global[0]);
		}

		find_avserver(0);
	}
/*
	if(rsrc_load("mytask.rsc")!=0)				/* RSC z malymi ikonkami zaladowany?	*/
		rsrc_gaddr(R_TREE, 0, &mini_icons);
*/
}


int find_avserver(int avprot)
{
	char *dummy;
	int   pipe[8];

	if (options.avignore) return(0);

	if (avserver>=0)
	{
		if (avserver==mt_appl_find(servername, (short*)&_GemParBlk.global[0])) return(1);
	}

	dummy = getenv("AVSERVER");
	if (dummy)
	{
		int i;

		strncpy(servername,dummy,9);
		servername[8]=0;
		while (strlen(servername)<8) strcat(servername," ");
		for (i=0;i<8;i++) servername[i]=toupper(servername[i]);
		
		avserver=mt_appl_find(servername, (short*)&_GemParBlk.global[0]);
		if (avserver>=0) goto _success;
	}

	avserver=mt_appl_find("THING   ", (short*)&_GemParBlk.global[0]);
	if (avserver>=0)
	{
		strcpy(servername,"THING   ");
		goto _success;
	}

	avserver=mt_appl_find("GEMINI  ", (short*)&_GemParBlk.global[0]);
	if (avserver>=0)
	{
		strcpy(servername,"GEMINI  ");
		goto _success;
	}

	avserver=mt_appl_find("EASE    ", (short*)&_GemParBlk.global[0]);
	if (avserver>=0)
	{
		strcpy(servername,"EASE    ");
		goto _success;
	}

	avserver=mt_appl_find("MAGXDESK", (short*)&_GemParBlk.global[0]);
	if (avserver>=0)
	{
		strcpy(servername,"MAGXDESK");
		goto _success;
	}

	avserver=mt_appl_find("JINNEE  ", (short*)&_GemParBlk.global[0]);
	if (avserver>=0)
	{
		strcpy(servername,"JINNEE  ");
		goto _success;
	}
	
	return(0);
	
	_success:
	if (avprot)
	{
		pipe[0]=AV_PROTOKOLL;
		pipe[1]=ap_id;
		pipe[2]=0;
		pipe[3]=AVMSG;
		pipe[4]=0;
		pipe[5]=0;
		pipe[6]=(int)(((long)accname >> 16) & 0x0000ffffL);
		pipe[7]=(int)((long)accname & 0x0000ffffL);
		
		mt_appl_write(avserver,16,pipe, (short*)&_GemParBlk.global[0]);
	}

	if (MyTask.whandle>0)
	{
		pipe[0]=AV_ACCWINDOPEN;
		pipe[1]=ap_id;
		pipe[2]=0;
		pipe[3]=MyTask.whandle;
		pipe[4]=0;
		pipe[5]=0;
		pipe[6]=0;
		pipe[7]=0;

		mt_appl_write(avserver,16,pipe, (short*)&_GemParBlk.global[0]);
	}

	return(1);
}


void cdecl sig_handler(long sig)
	{
	if ((sig==SIGTERM) || (sig==SIGQUIT))
		quit=1;
	}


int Fgets(char *str,int n,int handle)
{
	int  count=0,succ=0;
	char c;

	while (Fread(handle,1,&c)==1)
	{
		if (c==13)
		{
			succ=1;
			break;
		}
		else
		{
			if (c!=10)
			{
				str[count++]=c;
				if (count>=n) break;
			}
		}
	}

	str[count]=0;

	return((count) || (succ));
}


void get_alias(char **dummy)
{
	ALIAS *dalias = alias;
	char  *env;

	if (*dummy[0] != '$') return;

	while (dalias)
	{
		if (!strcmp(dalias->old,*dummy))
		{
			*dummy=dalias->new;
			return;
		}

		dalias=dalias->next;
	}
	
	env=getenv((*dummy)+1L);
	if (env) *dummy=env;
}


int read_group(char *grpfile, STARTMENU *curr)
{
	char       *dummy,*tok,*wildcmd,*entryname,filename[256],buf[512];
	long        ret;
	int         handle;
	STARTENTRY *se     = curr->entries,*se2,
	           *selast = NULL,*selast2;
	STARTMENU  *sm     = curr->children,
	           *smlast = NULL;

	ret=Fopen(grpfile,FO_READ);
	if (ret<0L) return(0);

	handle  = (int)ret;

	while (se)
	{
		selast = se;
		se = se->next;
	}
	
	while (sm)
	{
		smlast = sm;
		sm = sm->next;
	}

	se = NULL;
	sm = NULL;
	
	_nextline:
	while (Fgets(buf,511,handle))
	{
		dummy=strrchr(buf,13);
		if (dummy) *dummy=0;
		dummy=strrchr(buf,10);
		if (dummy) *dummy=0;
		
		if (strlen(buf))
		{
			if (buf[0]=='#') goto _nextline;
			
			if (!strncmp(buf,"OFIL",4))
			{
				if ((!se) || (!sm)) return(0);

				entryname=strchr(buf,'"');
				if (!entryname) return(0);
				entryname++;
				
				tok=strchr(entryname,'"');
				if (!tok) return(0);
				*tok=0;
				do
				{
					tok++;
				} while (*tok==' ');
				
				wildcmd=strchr(tok,' ');
				if (!wildcmd) return(0);
				*wildcmd=0;
				do
				{
					wildcmd++;
				} while (*wildcmd!='"');
				wildcmd++;

				if ((*tok=='\\') || (*(tok+1L)==':')) strcpy(filename,tok);
				else
				{
					strcpy(filename,grpfile);
					dummy=strrchr(filename,'\\');
					
					if (!dummy) strcpy(filename,tok);
					else
						strcpy(dummy+1L,tok);
				}

				se2     = sm->entries;
				selast2 = NULL;

				while (se2)
				{
					selast2 = se2;
					se2 = se2->next;
				}

				se2 = (STARTENTRY *)calloc(1, sizeof(STARTENTRY));
				if (!se2)
				{
					mt_form_alert(1,message[MSG_CNFMEM_ERROR], (short*)&_GemParBlk.global[0]);
					return(0);
				}
									
				se2->name  = (char *)calloc(1,strlen(entryname)+1L);
				se2->file  = (char *)calloc(1,strlen(filename)+1L);
				se2->fcmd  = NULL;
				se2->next  = NULL;
				se2->flags = SE_FILE;
				
				if ((!se2->name) || (!se2->file))
				{
					mt_form_alert(1,message[MSG_CNFMEM_ERROR], (short*)&_GemParBlk.global[0]);
					return(0);
				}
				
				strcpy(se2->name,entryname);
				strcpy(se2->file,filename);
				
				if (*wildcmd!='"')
				{
					dummy=strchr(wildcmd,'"');
					if (dummy)
					{
						*dummy=0;

						se2->fcmd = (char *)calloc(1,strlen(wildcmd)+2L);

						if (se2->fcmd)
						{
							strcpy(&(se2->fcmd[1]),wildcmd);
							se2->fcmd[0]=min(strlen(wildcmd),125);
						}
					}
				}
				
				if (!selast2) sm->entries = se2;
				else
					selast2->next = se2;
			}
			else if (!strncmp(buf,"OFLD",4))
			{
				if ((!se) || (!sm)) return(0);

				entryname=strchr(buf,'"');
				if (!entryname) return(0);
				entryname++;
				
				tok=strchr(entryname,'"');
				if (!tok) return(0);
				*tok=0;
				do
				{
					tok++;
				} while (*tok==' ');

				wildcmd=strchr(tok,' ');
				if (!wildcmd) return(0);
				*wildcmd=0;
				do
				{
					wildcmd++;
				} while (*wildcmd!='"');
				wildcmd++;

				if ((*tok=='\\') || (*(tok+1L)==':')) strcpy(filename,tok);
				else
				{
					strcpy(filename,grpfile);
					dummy=strrchr(filename,'\\');
					
					if (!dummy) strcpy(filename,tok);
					else
						strcpy(dummy+1L,tok);
				}
				
				if (*wildcmd!='"')
				{
					dummy=strchr(wildcmd,'"');
					if (dummy)
					{
						*dummy=0;
						strcat(filename,wildcmd);
					}
				}
				
				se2     = sm->entries;
				selast2 = NULL;

				while (se2)
				{
					selast2 = se2;
					se2 = se2->next;
				}

				se2 = (STARTENTRY *)calloc(1,sizeof(STARTENTRY));
				if (!se2)
				{
					mt_form_alert(1,message[MSG_CNFMEM_ERROR], (short*)&_GemParBlk.global[0]);
					return(0);
				}
									
				se2->name  = (char *)calloc(1,strlen(entryname)+1L);
				se2->file  = (char *)calloc(1,strlen(filename)+1L);
				se2->fcmd  = NULL;
				se2->next  = NULL;
				se2->flags = SE_FOLDER;
				
				if ((!se2->name) || (!se2->file))
				{
					mt_form_alert(1,message[MSG_CNFMEM_ERROR], (short*)&_GemParBlk.global[0]);
					return(0);
				}
				
				strcpy(se2->name,entryname);
				strcpy(se2->file,filename);

				if (!selast2) sm->entries = se2;
				else
					selast2->next = se2;
			}
			else if (!strncmp(buf,"INFO",4))
			{
				if ((se) || (sm)) return(0);

				se = (STARTENTRY *)calloc(1,sizeof(STARTENTRY));
				sm = (STARTMENU *)calloc(1,sizeof(STARTMENU));
				
				if ((!se) || (!sm))
				{
					mt_form_alert(1,message[MSG_CNFMEM_ERROR], (short*)&_GemParBlk.global[0]);
					return(0);
				}
				
				dummy=strchr(buf,'"');
				if (!dummy) return(0);
				dummy++;
				
				tok=strchr(dummy,'"');
				if (!tok) return(0);
				*tok=0;

				se->name  = (char *)calloc(1,strlen(dummy)+1L);
				se->file  = NULL;
				se->fcmd  = NULL;
				se->next  = NULL;
				se->flags = 0;
				
				if (!se->name)
				{
					mt_form_alert(1,message[MSG_CNFMEM_ERROR], (short*)&_GemParBlk.global[0]);
					return(0);
				}
				
				strcpy(se->name,dummy);
				
				if (!selast) curr->entries = se;
				else
					selast->next = se;
				
				if (!smlast) curr->children = sm;
				else
					smlast->next = sm;
				
				sm->tree     = NULL;
				sm->entries  = NULL;
				sm->children = NULL;
				sm->next     = NULL;
				sm->parent   = curr;
			}
		}
	}
	
	Fclose(handle);
	
	return(1);
}



void cnf_error(int err,int line)
	{
	char buf[112], num[16];
	
	strcpy(buf, message[err]);
	itoa(line, num, 10);
	strcat(buf, num);
	strcat(buf, message[MSG_ERROR_LINE]);

	mt_form_alert(1, buf, (short*)&_GemParBlk.global[0]);
	}


OBJECT *build_popup(STARTMENU *curr, int drv, int docs, int apps)
	{
	int         c,sticurr, count = drv+docs+apps, sticons = 0,
	            maxw = (drv)?((int)strlen(drventry)-2):0;

	STARTENTRY *ce = curr->entries;
	STARTMENU  *cm = curr->children;
	OBJECT     *pop = NULL, *sticob;

	if (docs)
		{
		if (((int)strlen(docentry)-2) > maxw)
			maxw = (int)strlen(docentry)-2;
		}
	
	if (apps)
		{
		if (((int)strlen(appentry)-2) > maxw)
			maxw = (int)strlen(appentry)-2;
		}

	if (options.html_separat)
		{
		count++;
		if (((int)strlen(htmlentry)-2) > maxw)
			maxw = (int)strlen(htmlentry)-2;
		}

	while (ce)
	{
		count++;
		
		if (ce->name)
		{
			if ((int)strlen(ce->name)>maxw) maxw=(int)strlen(ce->name);
			
			if (stic && options.stic_popup)
			{
				if (ce->file)
				{
					if (stic->str_icon(ce->file,STIC_SMALL)) sticons++;
				}
			}
		}
		
		ce = ce->next;
	}
	
	if (count>0)
	{
		pop = (OBJECT *)calloc(1,sizeof(OBJECT)*(long)(count+sticons+1L));					/* UWAGA! To nalezy zwolnic z pamieci!!	*/
		sticurr = count+1;
		maxw   += 5;

		if (pop)
		{
			pop[ROOT].ob_next   = -1;
			pop[ROOT].ob_head   =  1;
			pop[ROOT].ob_tail   = count;
			pop[ROOT].ob_type   = G_BOX;
			pop[ROOT].ob_flags  = FL3DBAK;
			pop[ROOT].ob_state  = OS_NORMAL;
			pop[ROOT].ob_spec.index = 0x00ff1100L;
			pop[ROOT].ob_x      =  0;
			pop[ROOT].ob_y      =  0;
			pop[ROOT].ob_width  = maxw;
			pop[ROOT].ob_height = count;

			c=0;
			
			if (drv)
				{
				c++;
				
				pop[c].ob_next   = c+1;
				pop[c].ob_head   = -1;
				pop[c].ob_tail   = -1;
				pop[c].ob_type   = G_STRING;
				pop[c].ob_flags  = FL3DBAK|OF_SELECTABLE;
				pop[c].ob_state  = OS_NORMAL;
				pop[c].ob_spec.free_string = (char *)calloc(1,(long)maxw+1L);
				pop[c].ob_x      =  0;
				pop[c].ob_y      = c-1;
				pop[c].ob_width  = maxw;
				pop[c].ob_height = 1;
				
				if (pop[c].ob_spec.free_string)
					{
					strcpy(pop[c].ob_spec.free_string,drventry);
					while (strlen(pop[c].ob_spec.free_string)<maxw) strcat(pop[c].ob_spec.free_string," ");
					}
				}
			
			if (docs)
				{
				c++;
				
				pop[c].ob_next   = c+1;
				pop[c].ob_head   = -1;
				pop[c].ob_tail   = -1;
				pop[c].ob_type   = G_STRING;
				pop[c].ob_flags  = FL3DBAK|OF_SELECTABLE;
				pop[c].ob_state  = OS_NORMAL;
				pop[c].ob_spec.free_string = (char *)calloc(1,(long)maxw+1L);
				pop[c].ob_x      =  0;
				pop[c].ob_y      = c-1;
				pop[c].ob_width  = maxw;
				pop[c].ob_height = 1;
				
				if (pop[c].ob_spec.free_string)
					{
					strcpy(pop[c].ob_spec.free_string,docentry);
					while (strlen(pop[c].ob_spec.free_string)<maxw) strcat(pop[c].ob_spec.free_string," ");
					}
				}

			if (options.html_separat)
				{
				c++;
				
				pop[c].ob_next   = c+1;
				pop[c].ob_head   = -1;
				pop[c].ob_tail   = -1;
				pop[c].ob_type   = G_STRING;
				pop[c].ob_flags  = FL3DBAK|OF_SELECTABLE;
				pop[c].ob_state  = OS_NORMAL;
				pop[c].ob_spec.free_string = (char *)calloc(1,(long)maxw+1L);
				pop[c].ob_x      =  0;
				pop[c].ob_y      = c-1;
				pop[c].ob_width  = maxw;
				pop[c].ob_height = 1;
				
				if (pop[c].ob_spec.free_string)
					{
					strcpy(pop[c].ob_spec.free_string,htmlentry);
					while (strlen(pop[c].ob_spec.free_string)<maxw) strcat(pop[c].ob_spec.free_string," ");
					}
				}
			
			
			if (apps)
				{
				c++;
				
				pop[c].ob_next   = c+1;
				pop[c].ob_head   = -1;
				pop[c].ob_tail   = -1;
				pop[c].ob_type   = G_STRING;
				pop[c].ob_flags  = FL3DBAK|OF_SELECTABLE;
				pop[c].ob_state  = OS_NORMAL;
				pop[c].ob_spec.free_string = (char *)calloc(1,(long)maxw+1L);
				pop[c].ob_x      =  0;
				pop[c].ob_y      = c-1;
				pop[c].ob_width  = maxw;
				pop[c].ob_height = 1;
				
				if (pop[c].ob_spec.free_string)
					{
					strcpy(pop[c].ob_spec.free_string,appentry);
					while (strlen(pop[c].ob_spec.free_string)<maxw) strcat(pop[c].ob_spec.free_string," ");
					}
				}

		
			ce = curr->entries;
			while (ce)
			{
				c++;

				pop[c].ob_next   = c+1;
				pop[c].ob_head   = -1;
				pop[c].ob_tail   = -1;
				pop[c].ob_type   = G_STRING;
				pop[c].ob_flags  = FL3DBAK|OF_SELECTABLE;
				pop[c].ob_state  = OS_NORMAL;
				pop[c].ob_spec.free_string = (char *)calloc(1,(long)maxw+1L);
				pop[c].ob_x      =  0;
				pop[c].ob_y      = c-1;
				pop[c].ob_width  = maxw;
				pop[c].ob_height = 1;

				if (!pop[c].ob_spec.free_string) pop[c].ob_spec.free_string = ce->name;
				else
				{
					if (ce->name)
					{
						strcpy(pop[c].ob_spec.free_string,"  ");
						strcat(pop[c].ob_spec.free_string,ce->name);
						
						if (stic && options.stic_popup)
							{
							if (ce->file)
								{
								sticob = stic->str_icon(ce->file,STIC_SMALL);

								if (sticob)
									{
									CICONBLK *cicnblk=calloc(1,sizeof(CICONBLK)), *tmp;
									memset(cicnblk, 0, sizeof(CICONBLK));

									pop[c].ob_head   = sticurr;
									pop[c].ob_tail   = sticurr;

									pop[sticurr].ob_next   =  c;
									pop[sticurr].ob_head   = -1;
									pop[sticurr].ob_tail   = -1;
									pop[sticurr].ob_type   = G_CICON;	/* sticob->ob_type;*/
									pop[sticurr].ob_flags  = FL3DBAK;			/*|OF_SELECTABLE;*/
									pop[sticurr].ob_state  = OS_NORMAL;
							
									tmp = sticob->ob_spec.ciconblk;

									cicnblk->monoblk.ib_pmask = tmp->monoblk.ib_pmask;
									cicnblk->monoblk.ib_pdata = tmp->monoblk.ib_pdata;
									cicnblk->monoblk.ib_ptext = "";
									cicnblk->monoblk.ib_char = tmp->monoblk.ib_char;
									cicnblk->monoblk.ib_wicon = cicnblk->monoblk.ib_hicon = 16;

									cicnblk->mainlist = calloc(1,sizeof(CICON));
									cicnblk->mainlist->num_planes = 4;
									cicnblk->mainlist->col_data = tmp->mainlist->col_data;
									cicnblk->mainlist->col_mask = tmp->mainlist->col_mask;
									cicnblk->mainlist->sel_data = tmp->mainlist->sel_data;
									cicnblk->mainlist->sel_mask = tmp->mainlist->sel_mask;
									cicnblk->mainlist->next_res = NULL;

									pop[sticurr].ob_spec.ciconblk   = cicnblk;			/*sticob->ob_spec;*/
									pop[sticurr].ob_x      =  0;
									pop[sticurr].ob_y      =  0;
									pop[sticurr].ob_width  =  2;
									pop[sticurr].ob_height =  1;
									
									/* Text nicht zeichnen, Position korrekt */
									
									sticurr++;
									}
								}
							}
						
						while (strlen(pop[c].ob_spec.free_string)<maxw) strcat(pop[c].ob_spec.free_string," ");
					}
					else
					{
						if (MyTask.v_handle)
							{
							if(pop[c].ob_spec.free_string)
								free(pop[c].ob_spec.free_string);

							pop[c].ob_type = G_USERDEF;
							pop[c].ob_spec.userblk = &usrdef;
							}
						else
							{
							memset(pop[c].ob_spec.free_string,'-',maxw);
							pop[c].ob_spec.free_string[maxw] = 0;
							}

						pop[c].ob_state |= OS_DISABLED;
					}
				}

				if ((!ce->file) && (ce->name))
				{
					cm->tree = build_popup(cm,0,0,0);
					if (!cm->tree)
					{
						pop[c].ob_state |= OS_DISABLED;
						pop[c].ob_spec.free_string[strlen(pop[c].ob_spec.free_string)-2]=3;
					}
					
					cm = cm->next;
				}
				
				ce = ce->next;
			}

			pop[count].ob_next = 0;
			pop[count+sticons].ob_flags |= OF_LASTOB;
			
			fix_tree(pop);
		}
	}
	
	return(pop);
}


void attach_popups(STARTMENU *curr, int drv, int docs, int apps)
	{
	STARTENTRY *ce = curr->entries;
	STARTMENU  *cm = curr->children;
	MENU        menu;
	int         c = drv+docs+apps;

	if(options.html_separat)
		c++;

	while (ce)
		{
		c++;

		if ((!ce->file) && (ce->name))
			{
			if (cm->tree)
				{
				menu.mn_tree     = cm->tree;
				menu.mn_menu     = ROOT;
				menu.mn_item     = 1;
				menu.mn_scroll   = 0;
				menu.mn_keystate = 0;

/*				if (stic)
					stic->menu_attach(ME_ATTACH,curr->tree,c,&menu);
				else	*/
					mt_menu_attach(ME_ATTACH,curr->tree,c,&menu, (short*)&_GemParBlk.global[0]);
				}
			
			attach_popups(cm,0,0,0);
			
			cm = cm->next;
			}
		
		ce = ce->next;
		}
	}


void free_dhst(DHST *d)
	{
	if (d->info.appname)
		free(d->info.appname);
	if (d->info.apppath)
		free(d->info.apppath);
	if (d->info.docname)
		free(d->info.docname);
	if (d->info.docpath)
		Mfree(d->info.docpath);
	
	free(d);
	}


int add_dhst(DHSTINFO *dhstinfo)
{
	DHST *newdhst;
	DHST2 *newdhst2;
	
	if (!dhstinfo) return(0);
	if (!dhstinfo->appname)	return(0);
	if (!dhstinfo->apppath) return(0);
	if (!dhstinfo->docname) return(0);
	if (!dhstinfo->docpath) return(0);
	
	newdhst = (DHST *)calloc(1,sizeof(DHST));
	if (!newdhst) return(0);

	newdhst2 = (DHST2 *)calloc(1,sizeof(DHST2));
	if (!newdhst2) return(0);
	
	newdhst->next = NULL;
	newdhst2->next = NULL;
	newdhst2->dhst = NULL;
	
	newdhst->info.appname = (char *)calloc(1,strlen(dhstinfo->appname)+1L);
	if (newdhst->info.appname) strcpy(newdhst->info.appname,dhstinfo->appname);
	newdhst2->appname = (char *)calloc(1,strlen(dhstinfo->appname)+1L);
	if (newdhst2->appname) strcpy(newdhst2->appname,dhstinfo->appname);

	newdhst->info.apppath = (char *)calloc(1,strlen(dhstinfo->apppath)+1L);
	if (newdhst->info.apppath) strcpy(newdhst->info.apppath,dhstinfo->apppath);

	newdhst->info.docname = (char *)calloc(1,strlen(dhstinfo->docname)+1L);
	if (newdhst->info.docname) strcpy(newdhst->info.docname,dhstinfo->docname);

	newdhst->info.docpath = (char *)calloc(1,strlen(dhstinfo->docpath)+2L);
	if (newdhst->info.docpath)
	{
		strcpy(&(newdhst->info.docpath[1]),dhstinfo->docpath);
		newdhst->info.docpath[0]=min(strlen(dhstinfo->docpath),125);
	}

	if(!dhst2)
		dhst2 =	newdhst2;
	else
		{
		DHST2 *d2 = dhst2, *dold2;
		newdhst2->next = dhst2;
		dhst2 = newdhst2;
		dold2 = dhst2;
		while(d2)
			{
			if (!strcmp(newdhst2->appname,d2->appname))
				{
				/* printf("Ta aplikacja juz jest w pamieci %s\r\n", d2->appname);
				dhst = d2->dhst;	*/
				break;
				}
			dold2 = d2;
			d2 = d2->next;
			}
		}

/*	dhst = dhst2->dhst;	*/
	if(dhst2->dhst==NULL)
		dhst2->dhst = newdhst;
	if (!dhst)
		dhst=newdhst;
	else
	{
		DHST *d = dhst, *dold;
		int   dcnt = 0;
		
		newdhst->next = dhst;
		dhst = newdhst;
		
		dold = dhst;
		
		while (d)
		{
			if ((!strcmp(newdhst->info.appname,d->info.appname)) && (!strcmp(newdhst->info.docname,d->info.docname)))
			{
				dold->next = d->next;

				free_dhst(d);
				
				break;
			}
			
			dold = d;
			d = d->next;
		}
		
		d = dhst;
		dold = NULL;

		while (d)
		{
			if (!strcmp(newdhst->info.appname,d->info.appname))
			{
				dcnt++;
				
				if (dcnt > docmaxperapp)
				{
					dold->next = d->next;
					
					free_dhst(d);

					break;
				}
			}

			dold = d;
			d = d->next;
		}

		d = dhst;
		dold = NULL;
		dcnt = 0;
		
		while (d->next)
		{
			dold = d;
			d = d->next;
			dcnt++;
		}
		
		if (dcnt >= docmax)
		{
			dold->next = NULL;
			free_dhst(d);
		}
	}

	return(1);
}




int find_help(void)
	{
	helpid = mt_appl_find("ST-GUIDE", (short*)&_GemParBlk.global[0]);
	if (helpid<0)
		helpid = mt_appl_find("HYPVIEW ", (short*)&_GemParBlk.global[0]);
	
	if (helpid<0)
		{
		char *dummy = getenv("STGUIDE");

		if (dummy)
			{
			if (!helpbuf) helpbuf = (char *)calloc(1,16L);
			
			if (helpbuf)
				{
				strcpy(helpbuf,"*:\\MyTask.hyp");
	
				start_app(0,SHW_PARALLEL,"HyperText",dummy,helpbuf);
	
				helpid = mt_appl_find("ST-GUIDE", (short*)&_GemParBlk.global[0]);
				}
			}
		}

	return(helpid>=0);
	}


void call_help(void)
	{
	int pipe[8];

	if (!helpbuf)
		{
		helpbuf = (char *)calloc(1,16L);
		if (!helpbuf) return;
		}

	strcpy(helpbuf,"*:\\MyTask.hyp");

	pipe[0] = VA_START;
	pipe[1] = ap_id;
	pipe[2] = 0;
	pipe[3] = (int)(((long)helpbuf >> 16) & 0x0000ffff);
	pipe[4] = (int)((long)helpbuf & 0x0000ffff);
	pipe[5] = 0;
	pipe[6] = 0;
	pipe[7] = 0;

	mt_appl_write(helpid,16,pipe, (short*)&_GemParBlk.global[0]);
	}


void clip_startinf(void)
	{
	if (startinf.workxabs+bigbutton[ROOT].ob_width > desk.g_x+desk.g_w)
		startinf.workxabs = desk.g_x+desk.g_w-bigbutton[ROOT].ob_width;
	if (startinf.workxabs < desk.g_x)
		startinf.workxabs = desk.g_x;

	if (startinf.workyabs+bigbutton[ROOT].ob_height > desk.g_y+desk.g_h)
		startinf.workyabs = desk.g_y+desk.g_h-bigbutton[ROOT].ob_height;
	if (startinf.workyabs < desk.g_y)
		startinf.workyabs = desk.g_y;
	
	bigbutton[ROOT].ob_x = startinf.workxabs;
	bigbutton[ROOT].ob_y = startinf.workyabs;
	}


void open_main_window(void)
	{
	if (nowindow)
		return;

	if (MyTask.whandle<=0)
		{
		MyTask.whandle = mt_wind_create(WINDOWSTYLE, desk.g_x, desk.g_y, desk.g_w, desk.g_h, (short*)&_GemParBlk.global[0]);
	
		if (MyTask.whandle<=0)
			{
	   	mt_form_alert(1,message[MSG_OPEN_MAIN], (short*)&_GemParBlk.global[0]);
			return;
			}
		
		clip_startinf();
		
		mt_wind_calc(WC_BORDER, WINDOWSTYLE, bigbutton->ob_x, bigbutton->ob_y, bigbutton->ob_width, bigbutton->ob_height, &wx,&wy,&ww,&wh, (short*)&_GemParBlk.global[0]);

		mt_wind_open(MyTask.whandle,wx,wy,ww,wh, (short*)&_GemParBlk.global[0]);
    mt_wind_set(MyTask.whandle,WF_BEVENT,1,0,0,0, (short*)&_GemParBlk.global[0]);
		}
 	else
	 	{
 		if (!untop)
 			mt_wind_set(MyTask.whandle,WF_TOP,0,0,0,0, (short*)&_GemParBlk.global[0]);
 		}
	}



void about(void)
	{
	if(dialog(object_info, 1)==INFO_URL)
		SendHTML("http://mypdf.atari-users.net/mytask/index.html", "MyTask home");
	}


STARTMENU *find_menu(STARTMENU *curr, OBJECT *tree)
	{
	STARTMENU *child=NULL,*found=NULL;

	if (!curr)
		return(NULL);
	
	if (curr->tree == tree)
		return(curr);
	
	child = curr->children;
	while (child)
		{
		found = find_menu(child,tree);
		if (found) return(found);

		child = child->next;
		}

	return(NULL);
	}


void start_app(int force, int how, char *name1, char *file, char *cmd)
{
	char *dummy,name[128],path[128],tmp_cwd[128];
	int   i,aid,sid,tmp_drive,doex=1,gem=1,executable=1;
	long  dret;

	if (!file) return;

	if(strstr(file, "http")!=NULL || strstr(file, "HTTP")!=NULL)
		{
		SendHTML(file, name1);
		return;
		}
	if(strstr(cmd, "http")!=NULL || strstr(cmd, "HTTP")!=NULL)
		{
		SendHTML(cmd, name1);
		return;
		}

	dummy = strrchr(file,'\\');
	if (!dummy)
	{
		dummy=file;
		strcpy(path,"\\");
	}
	else
	{
		*dummy=0;
		strcpy(path,file);
		*dummy='\\';
		dummy++;
	}
	strcpy(name,dummy);
	
	dummy = strrchr(name,'.');
	if (!dummy) gem=0;
	else
	{
		if ((!stricmp(dummy,".ACC")) || (!stricmp(dummy,".ACX"))) doex=SHW_LOAD_ACC;
		else
		{
			if ((!stricmp(dummy,".TOS")) || (!stricmp(dummy,".TTP"))) gem=0;
		}
		
		*dummy=0;
		
		if ((!gem) && ((options.avnotos) || (!find_avserver(1)))) goto _vastart;
	}

	if (strlen(name)>8) name[8]=0;
	else
		while (strlen(name)<8) strcat(name," ");

	for (i=0;i<8;i++) name[i]=toupper(name[i]);

	if (!force)
	{
		if ((find_avserver(1)) && ((doex==1) || (!options.avnoacc)))
		{
			int pipe[8];
			
			strcpy(avfile,file);
			if (cmd) cmd++;
			
			pipe[0]=AV_STARTPROG;
			pipe[1]=ap_id;
			pipe[2]=0;
			pipe[3]=(int)(((long)avfile >> 16) & 0x0000ffffL);
			pipe[4]=(int)((long)avfile & 0x0000ffffL);
			pipe[5]=(int)(((long)cmd >> 16) & 0x0000ffffL);
			pipe[6]=(int)((long)cmd & 0x0000ffffL);
			pipe[7]=0;
			
			mt_appl_write(avserver,16,pipe, (short*)&_GemParBlk.global[0]);
			return;
		}
		
		_vastart:
		if ((!gem) && (options.tosmultistart)) goto _shelstart;
		
		aid = mt_appl_find(name, (short*)&_GemParBlk.global[0]);
		if (aid>=0)
		{
			SendAV(mt_appl_find("SCRENMGR", (short*)&_GemParBlk.global[0]), SM_M_SPECIAL, ap_id,0,0, 'MA', 'GX',SMC_SWITCH,aid);
			
			if (cmd) cmd++;
	
			SendAV(aid, VA_START, 0,0,(int)(((long)cmd >> 16) & 0x0000ffffL),(int)((long)cmd & 0x0000ffffL),0,0,0);
			return;
		}
	}

	_shelstart:
	dret=Dpathconf(file,-1);

	if (dret>=0L)
	{
		int xbit = 0;
		
		if (dret>=7L)
		{
			dret=Dpathconf(file,7);

			if (dret>0L)
			{
				if ((dret >> 8) & 73L) xbit=1;
				goto _xbit;
			}
		}
		
		if (!get_cookie('MagX',NULL)) xbit=1;

		_xbit:
		if (xbit)
		{
			XATTR xattr;
			
			if (!Fxattr(0,file,&xattr))
			{
				if (!(xattr.mode & 73L)) executable=0;
			}
		}
	}

	if (!executable)
	{
		mt_form_alert(1,message[MSG_NOT_EXECUTABLE], (short*)&_GemParBlk.global[0]);
		return;
	}

	tmp_drive = Dgetdrv();
	Dgetpath(tmp_cwd,tmp_drive+1);
	
	if (strlen(file)>1)
	{
		if (file[1]==':') Dsetdrv(toupper(file[0])-65);
	}

	Dsetpath(path);

	sid = mt_shel_write(doex,gem,how,file,(cmd)?cmd:defcmd, (short*)&_GemParBlk.global[0]);

	if (!sid)
	{
		Dsetdrv(tmp_drive);
		Dsetpath(tmp_cwd);
	}
	else
	{
		if (doex==SHW_LOAD_ACC)
			SendAV(sid, VA_START, 0,0,0,0,0,0,0);
	}
}




int handle_keyboard(int kstate, int key)
{
	short mx, my, d;

	if (kstate & KbSCAN)
	{
		if ((kstate & ~KbSCAN)==KbNORMAL)
		{
			if (key==KbHELP)
			{
				if (find_help())
				{
					call_help();
					return(1);
				}
			}
		}
	}
	else
	{
		if (kstate==KbCONTROL)
		{
			switch(key)
			{
				case 'i':
					about();
					return(1);
				
				case 'o':
					start_by_sel();
					return(1);

				case 'd':
					if(options.draw_obj == 0)
						options.draw_obj = 1;
					else
						options.draw_obj = 0;
					break;
			}
		}
		else if (kstate==(KbALT | KbLSHIFT))
		{
			if (key==62) open_over_mouse(NULL,WHAT_NORMAL,NULL);
		}
	}


	mt_graf_mkstate(&mx, &my, &d, &d, (short*)&_GemParBlk.global[0]);
	return(0);
}


void start_by_sel(void)
{
	int pipe[8];
	
	pipe[0]=MN_SELECTED;
	pipe[1]=ap_id;
	pipe[2]=0;
	pipe[3]=-1;
	pipe[4]=RM_START;
	
	handle_message(pipe);
}


void folder_state(STARTMENU *curr, int drv, int docs, int apps, int enable)
{
	STARTENTRY *ce = curr->entries;
	STARTMENU  *cm = curr->children;
	int         c = drv+docs+apps;

	while (ce)
	{
		c++;
		
		if (ce->flags & SE_FOLDER)
		{
			if (enable) curr->tree[c].ob_state &= ~OS_DISABLED;
			else
				curr->tree[c].ob_state |= OS_DISABLED;
		}
		else
		{
			if ((!ce->file) && (ce->name))
			{
				folder_state(cm,0,0,0,enable);
				cm = cm->next;
			}
		}
		
		ce = ce->next;
	}
}





void start_popup(char *dcmd, int dx, int dy, int dflags, int what, char *mname)
{
	MENU    menu,msel;
	OBJECT *drvpop=NULL, *docpop=NULL, *htmlpop=NULL, *whatmenu=NULL, *apppop=NULL;
	int     ret,mnx,mny,playclose;
	int keyboard;

	if (bigbutton[btnidx].ob_state & OS_DISABLED) return;
	
	if (MyTask.whandle>0)
		mt_wind_set(MyTask.whandle,WF_TOP,0,0,0,0, (short*)&_GemParBlk.global[0]);
	bigbutton[btnidx].ob_state |= OS_SELECTED;
	redraw(0, bigbutton->ob_x+bigbutton[btnidx].ob_x-3, bigbutton->ob_y+bigbutton[btnidx].ob_y-3, bigbutton[btnidx].ob_width+6, bigbutton[btnidx].ob_height+6, "start popup");
	
	findstic();
	
	if (options.drives)
	{
		long    b,drvmap = Dsetdrv(Dgetdrv()),lmax=0;
		int     c,drvanz=1;
		char    drv[4],labl[34];
		
		for (c=0,b=1;c<32;c++)
		{
			if (drvmap & b)
			{
				drvanz++;
				
				if (labels[c])
				{
					if (strlen(labels[c])>lmax) lmax=strlen(labels[c]);
				}
				else if (!strchr(nolabel,c+65))
				{
					strcpy(drv,"?:");
					drv[0]=c+65;
				
					if (!Dreadlabel(drv,labl,32))
					{
						if (strlen(labl)>lmax) lmax=strlen(labl);
					}
				}
			}

			b <<= 1;
		}
		
		drvpop = (OBJECT *)calloc(1,sizeof(OBJECT)*(long)drvanz);
		
		if (drvpop)
		{
			int cnt = 1;
			
			if (lmax) lmax += 3L;
			lmax += 6L;
			
			drvpop[ROOT].ob_next   = -1;
			drvpop[ROOT].ob_head   =  1;
			drvpop[ROOT].ob_tail   = drvanz-1;
			drvpop[ROOT].ob_type   = G_BOX;
			drvpop[ROOT].ob_flags  = FL3DBAK;
			drvpop[ROOT].ob_state  = OS_NORMAL;
			drvpop[ROOT].ob_spec.index = 0x00ff1100L;
			drvpop[ROOT].ob_x      =  0;
			drvpop[ROOT].ob_y      =  0;
			drvpop[ROOT].ob_width  = (int)lmax-1;
			drvpop[ROOT].ob_height = drvanz-1;

			for (c=0,b=1;c<32;c++)
			{
				if (drvmap & b)
				{
					drvpop[cnt].ob_next   = cnt+1;
					drvpop[cnt].ob_head   = -1;
					drvpop[cnt].ob_tail   = -1;
					drvpop[cnt].ob_type   = G_STRING;
					drvpop[cnt].ob_flags  = FL3DBAK|OF_SELECTABLE;
					drvpop[cnt].ob_state  = OS_NORMAL;
					drvpop[cnt].ob_spec.free_string = (char *)calloc(1,lmax);
					drvpop[cnt].ob_x      =  0;
					drvpop[cnt].ob_y      = cnt-1;
					drvpop[cnt].ob_width  = (int)lmax-1;
					drvpop[cnt].ob_height =  1;
					
					if (drvpop[cnt].ob_spec.free_string)
					{
						strcpy(drvpop[cnt].ob_spec.free_string,"    ");
						drvpop[cnt].ob_spec.free_string[2]=c+65;
						
						if (labels[c])
						{
							strcat(drvpop[cnt].ob_spec.free_string,"(");
							strcat(drvpop[cnt].ob_spec.free_string,labels[c]);
							strcat(drvpop[cnt].ob_spec.free_string,")");
						}
						else if (!strchr(nolabel,c+65))
						{
							strcpy(drv,"?:");
							drv[0]=c+65;

							if (!Dreadlabel(drv,labl,32))
							{
								strcat(drvpop[cnt].ob_spec.free_string,"(");
								strcat(drvpop[cnt].ob_spec.free_string,labl);
								strcat(drvpop[cnt].ob_spec.free_string,")");
							}
						}
						
						while (strlen(drvpop[cnt].ob_spec.free_string)<lmax-1) strcat(drvpop[cnt].ob_spec.free_string," ");
					}

					cnt++;
				}
				
				b <<= 1;
			}
			
			drvpop[drvanz-1].ob_next = 0;
			drvpop[drvanz-1].ob_flags |= OF_LASTOB;

			fix_tree(drvpop);
			
			menu.mn_tree     = drvpop;
			menu.mn_menu     = ROOT;
			menu.mn_item     = 1;
			menu.mn_scroll   = 0;
			menu.mn_keystate = 0;

			mt_menu_attach(ME_ATTACH,menus->tree,1,&menu, (short*)&_GemParBlk.global[0]);
		}

		if ((!find_avserver(1)) || (!drvpop))
			menus->tree[1].ob_state |= OS_DISABLED;
		else
			menus->tree[1].ob_state &= ~OS_DISABLED;
	}



	if (options.documents)				/* Dokumenty DHST	*/
	{
		int docidx = 1+options.drives, docanz = 0;
		long lmax = 0, lcmp;
		DHST *d = dhst;
		
		while (d)
			{
			if(options.html_separat==0 || (options.html_separat==1 && strstr(d->info.docpath, "http")==NULL))
				{
				lcmp = (d->info.appname) ? strlen(d->info.appname) : 0L;
				if (d->info.docname) lcmp += strlen(d->info.docname);
				if (lcmp > lmax) lmax = lcmp;
			
				docanz++;
				}
			d = d->next;
			}

		if (docanz)
		{
			docanz++;
			
			docpop = (OBJECT *)calloc(1,sizeof(OBJECT)*(long)docanz);
		
			if (docpop)
			{
				int cnt = 1;
				
				lmax += 7;
			
				docpop[ROOT].ob_next   = -1;
				docpop[ROOT].ob_head   =  1;
				docpop[ROOT].ob_tail   = docanz-1;
				docpop[ROOT].ob_type   = G_BOX;
				docpop[ROOT].ob_flags  = FL3DBAK;
				docpop[ROOT].ob_state  = OS_NORMAL;
				docpop[ROOT].ob_spec.index = 0x00ff1100L;
				docpop[ROOT].ob_x      =  0;
				docpop[ROOT].ob_y      =  0;
				docpop[ROOT].ob_width  = (int)lmax-1;
				docpop[ROOT].ob_height = docanz-1;
				
				d = dhst;
				
				while (d)
				{
					if(options.html_separat==0 || (options.html_separat==1 && strstr(d->info.docpath, "http")==NULL))
						{
						docpop[cnt].ob_next   = cnt+1;
						docpop[cnt].ob_head   = -1;
						docpop[cnt].ob_tail   = -1;
						docpop[cnt].ob_type   = G_STRING;
						docpop[cnt].ob_flags  = FL3DBAK|OF_SELECTABLE;
						docpop[cnt].ob_state  = OS_NORMAL;
						docpop[cnt].ob_spec.free_string = (char *)calloc(1,lmax);
						docpop[cnt].ob_x      =  0;
						docpop[cnt].ob_y      = cnt-1;
						docpop[cnt].ob_width  = (int)lmax-1;
						docpop[cnt].ob_height =  1;

						if (docpop[cnt].ob_spec.free_string)
							{
							strcpy(docpop[cnt].ob_spec.free_string,"  [");
							if (d->info.appname) strcat(docpop[cnt].ob_spec.free_string,d->info.appname);
							strcat(docpop[cnt].ob_spec.free_string,"] ");
							if (d->info.docname) strcat(docpop[cnt].ob_spec.free_string,d->info.docname);

							while (strlen(docpop[cnt].ob_spec.free_string)<lmax-1) strcat(docpop[cnt].ob_spec.free_string," ");
							}
					
						cnt++;
						}
					d = d->next;
					}

				docpop[docanz-1].ob_next = 0;
				docpop[docanz-1].ob_flags |= OF_LASTOB;
	
				fix_tree(docpop);
				
				menu.mn_tree     = docpop;
				menu.mn_menu     = ROOT;
				menu.mn_item     = 1;
				menu.mn_scroll   = 0;
				menu.mn_keystate = 0;
	
				mt_menu_attach(ME_ATTACH,menus->tree,docidx,&menu, (short*)&_GemParBlk.global[0]);
			}
		}
		
		if (!docpop)
			menus->tree[docidx].ob_state |= OS_DISABLED;
		else
			menus->tree[docidx].ob_state &= ~OS_DISABLED;
	}
	

	if (options.html_separat)				/* Strony HTML jako oddzielny POPUP	*/
	{
		int htmlidx = 1+options.drives+options.documents, docanz = 0;
		long lmax = 0, lcmp;
		DHST *d = dhst;

		while (d)
		{
			if(strstr(d->info.docpath, "http")!=NULL)
				{
				lcmp = (d->info.appname) ? strlen(d->info.appname) : 0L;
				if (d->info.docname) lcmp += strlen(d->info.docname);
				if (lcmp > lmax) lmax = lcmp;
			
				docanz++;
				}
			d = d->next;
		}
		
		if (docanz)
		{
			docanz++;
			
			htmlpop = (OBJECT *)calloc(1,sizeof(OBJECT)*(long)docanz);
		
			if (htmlpop)
			{
				int cnt = 1;
				
				lmax += 7;
			
				htmlpop[ROOT].ob_next   = -1;
				htmlpop[ROOT].ob_head   =  1;
				htmlpop[ROOT].ob_tail   = docanz-1;
				htmlpop[ROOT].ob_type   = G_BOX;
				htmlpop[ROOT].ob_flags  = FL3DBAK;
				htmlpop[ROOT].ob_state  = OS_NORMAL;
				htmlpop[ROOT].ob_spec.index = 0x00ff1100L;
				htmlpop[ROOT].ob_x      =  0;
				htmlpop[ROOT].ob_y      =  0;
				htmlpop[ROOT].ob_width  = (int)lmax-1;
				htmlpop[ROOT].ob_height = docanz-1;

				d = dhst;

				while (d)
					{
					if(strstr(d->info.docpath, "http")!=NULL)
						{
						htmlpop[cnt].ob_next   = cnt+1;
						htmlpop[cnt].ob_head   = -1;
						htmlpop[cnt].ob_tail   = -1;
						htmlpop[cnt].ob_type   = G_STRING;
						htmlpop[cnt].ob_flags  = FL3DBAK|OF_SELECTABLE;
						htmlpop[cnt].ob_state  = OS_NORMAL;
						htmlpop[cnt].ob_spec.free_string = (char *)calloc(1,lmax);
						htmlpop[cnt].ob_x      =  0;
						htmlpop[cnt].ob_y      = cnt-1;
						htmlpop[cnt].ob_width  = (int)lmax-1;
						htmlpop[cnt].ob_height =  1;

						if (htmlpop[cnt].ob_spec.free_string)
						{
							strcpy(htmlpop[cnt].ob_spec.free_string,"  [WWW] ");
/*							if (d->info.appname) strcat(htmlpop[cnt].ob_spec.free_string,d->info.appname);
							strcat(htmlpop[cnt].ob_spec.free_string,"] ");	*/
							if (d->info.docname) strcat(htmlpop[cnt].ob_spec.free_string,d->info.docname);

							while (strlen(htmlpop[cnt].ob_spec.free_string)<lmax-1) strcat(htmlpop[cnt].ob_spec.free_string," ");
						}
					
						cnt++;
						}
						d = d->next;
					}

					htmlpop[docanz-1].ob_next = 0;
					htmlpop[docanz-1].ob_flags |= OF_LASTOB;
	
					fix_tree(htmlpop);
				
					menu.mn_tree     = htmlpop;
					menu.mn_menu     = ROOT;
					menu.mn_item     = 1;
					menu.mn_scroll   = 0;
					menu.mn_keystate = 0;
	
					mt_menu_attach(ME_ATTACH, menus->tree, htmlidx, &menu, (short*)&_GemParBlk.global[0]);
			}
		}
		
		if (!htmlpop)
			menus->tree[htmlidx].ob_state |= OS_DISABLED;
		else
			menus->tree[htmlidx].ob_state &= ~OS_DISABLED;
	}
	

	if (applications)
		{
		int appidx = 1+options.drives+options.documents+options.html_separat;

		if (!apppop)
			menus->tree[appidx].ob_state |= OS_DISABLED;
		else
			menus->tree[appidx].ob_state &= ~OS_DISABLED;
		}

	menu.mn_tree     = menus->tree;
	menu.mn_menu     = ROOT;
	menu.mn_item     = 1;
	menu.mn_scroll   = 0;
	menu.mn_keystate = 0;
	
	switch (what)
	{
	case WHAT_HISTORY:
		menu.mn_tree = docpop;
		break;
	case WHAT_HTML:
		menu.mn_tree = htmlpop;
		break;
	case WHAT_DRIVES:
		menu.mn_tree = drvpop;
		break;
	case WHAT_MENU:
		{
			STARTENTRY *entr = menus->entries;
			STARTMENU  *mnu  = menus->children;
			
			while (entr)
			{
				if ((!entr->file) && (entr->name))
				{
					if (!strcmp(entr->name,mname))
					{
						whatmenu = mnu->tree;
						break;
					}
					
					mnu = mnu->next;
				}
				
				entr = entr->next;
			}
			
			if (whatmenu)
			{
				menu.mn_tree = whatmenu;
			}
			else
			{
				mname = NULL;
				what  = WHAT_NORMAL;
			}
		}
	}

	if (dflags==DF_NONE)
	{
		mnx = bigbutton[ROOT].ob_x+bigbutton[btnidx].ob_x-2;
		mny = bigbutton[ROOT].ob_y-menus->tree[ROOT].ob_height-2;
	}
	else
	{
		mnx=dx;
		mny=dy;
		
		if (dflags == DF_LEFT)
		{
			switch(what)
			{
			case WHAT_HISTORY:
				mnx -= (docpop[ROOT].ob_width >> 1);
				mny -= (docpop[ROOT].ob_height >> 1);
				break;
			case WHAT_HTML:
				mnx -= (htmlpop[ROOT].ob_width >> 1);
				mny -= (htmlpop[ROOT].ob_height >> 1);
				break;
			case WHAT_DRIVES:
				mnx -= (drvpop[ROOT].ob_width >> 1);
				mny -= (drvpop[ROOT].ob_height >> 1);
				break;
			case WHAT_MENU:
				mnx -= (whatmenu[ROOT].ob_width >> 1);
				mny -= (whatmenu[ROOT].ob_height >> 1);
				break;
			case WHAT_NORMAL:
				mnx -= (menus->tree[ROOT].ob_width >> 1);
				mny -= (menus->tree[ROOT].ob_height >> 1);
			}
		}
	}

	switch (what)
	{
	case WHAT_HISTORY:
		if (mnx+docpop[ROOT].ob_width > desk.g_x+desk.g_w) mnx = desk.g_x+desk.g_w-docpop[ROOT].ob_width;
		break;
	case WHAT_HTML:
		if (mnx+htmlpop[ROOT].ob_width > desk.g_x+desk.g_w) mnx = desk.g_x+desk.g_w-htmlpop[ROOT].ob_width;
		break;
	case WHAT_DRIVES:
		if (mnx+drvpop[ROOT].ob_width > desk.g_x+desk.g_w) mnx = desk.g_x+desk.g_w-drvpop[ROOT].ob_width;
		break;
	case WHAT_MENU:
		if (mnx+whatmenu[ROOT].ob_width > desk.g_x+desk.g_w) mnx = desk.g_x+desk.g_w-whatmenu[ROOT].ob_width;
		break;
	default:
		if (mnx+menus->tree[ROOT].ob_width > desk.g_x+desk.g_w) mnx = desk.g_x+desk.g_w-menus->tree[ROOT].ob_width;
	}

	if (mnx < desk.g_x)
		mnx = desk.g_x;
	
	folder_state(menus, options.drives, options.documents, applications, find_avserver(1));

	play_sound(sampleopen);
	playclose = 1;

/*	if (stic)
		ret=stic->menu_popup(&menu,mnx,mny,&msel);
	else	*/
		ret=mt_menu_popup(&menu,mnx,mny,&msel, (short*)&_GemParBlk.global[0]);

	keyboard = (int)Kbshift(-1);

	if (ret)
	{
		STARTMENU *start;
		
		if (msel.mn_tree==drvpop)
		{
			int pipe[8];
			
			strcpy(avfile,"*:\\");
			avfile[0]=drvpop[msel.mn_item].ob_spec.free_string[2];

			if (keyboard & KsSHIFT)
			{
				Dcntl(CDROMEJECT,avfile,0);
				goto _drvend;
			}
			
			if (dcmd)
				{
				char *ccmd = dcmd+1L;

				pipe[0]=AV_COPYFILE;
				pipe[1]=ap_id;
				pipe[2]=0;
				pipe[3]=(int)(((long)ccmd >> 16) & 0x0000ffffL);
				pipe[4]=(int)((long)ccmd & 0x0000ffffL);
				pipe[5]=(int)(((long)avfile >> 16) & 0x0000ffffL);
				pipe[6]=(int)((long)avfile & 0x0000ffffL);

				if (keyboard & KsCONTROL) pipe[7] = 1;
				else
					pipe[7]=0;

				if (keyboard & KsALT) pipe[7] |= 2;
				}
			else if(strstr(avfile, "http")!=NULL || strstr(avfile, "HTTP")!=NULL)
				{
				SendHTML(avfile, "*");
				}
			else
				{
				pipe[0]=AV_OPENWIND;
				pipe[1]=ap_id;
				pipe[2]=0;
				pipe[3]=(int)(((long)avfile >> 16) & 0x0000ffffL);
				pipe[4]=(int)((long)avfile & 0x0000ffffL);
				pipe[5]=(int)(((long)avextall >> 16) & 0x0000ffffL);
				pipe[6]=(int)((long)avextall & 0x0000ffffL);
				pipe[7]=0;
				}
			
			if(strstr(avfile, "http")==NULL || strstr(avfile, "HTTP")==NULL)
				SendAV(avserver, pipe[0], pipe[1], pipe[2], pipe[3], pipe[4], pipe[5], pipe[6], pipe[7]);

			goto _drvend;
		}
		
		if (msel.mn_tree==docpop || msel.mn_tree==htmlpop)
		{
			DHST *d = dhst, *dold = NULL;
			int dcnt = msel.mn_item-1;
			
			while ((d) && (dcnt))
			{
				dcnt--;

				dold = d;
				d    = d->next;
			}
			
			if ((d) && (!dcnt))
			{
				if (keyboard & KsALT)
				{
					if (!dold) dhst = d->next;
					else
						dold->next = d->next;
					
					free_dhst(d);
				}
				else
				{
					start_app(0, SHW_PARALLEL, d->info.appname, d->info.apppath, d->info.docpath);
				}
			}
			
			goto _drvend;
		}

		start = find_menu(menus, msel.mn_tree);

		if (start)
		{
			STARTENTRY *se = start->entries;
			
			if (start==menus)
				msel.mn_item -= (options.drives+options.documents+applications);

			while (se)
			{
				msel.mn_item--;

				if (!msel.mn_item)
				{
					if (se->file)
					{
						if (se->flags & SE_FOLDER)
						{
							int   pipe[8];
							char *avext;
							
							strcpy(avfile,se->file);
							
							if ((strchr(avfile,'?')) || (strchr(avfile,'*')))
							{
								char *bsl = strrchr(avfile,'\\');
								
								if (bsl)
								{
									bsl++;
									strcpy(avextusr,bsl);
									*bsl = 0;
								}
								else
								{
									strcpy(avfile,"\\");
									strcpy(avextusr,se->file);
								}

								avext = avextusr;
							}
							else
							{
								if (avfile[strlen(avfile)-1] != '\\') strcat(avfile,"\\");
								avext = avextall;
							}

							if (dcmd)
							{
								char *ccmd = dcmd+1L;
				
								pipe[0]=AV_COPYFILE;
								pipe[1]=ap_id;
								pipe[2]=0;
								pipe[3]=(int)(((long)ccmd >> 16) & 0x0000ffffL);
								pipe[4]=(int)((long)ccmd & 0x0000ffffL);
								pipe[5]=(int)(((long)avfile >> 16) & 0x0000ffffL);
								pipe[6]=(int)((long)avfile & 0x0000ffffL);
				
								if (keyboard & KsCONTROL) pipe[7] = 1;
								else
									pipe[7]=0;

								if (keyboard & KsALT) pipe[7] |= 2;
							}
							else if(strstr(avfile, "http")!=NULL || strstr(avfile, "HTTP")!=NULL)
								{
								SendHTML(avfile, "*");
								}
							else
							{
								pipe[0]=AV_OPENWIND;
								pipe[1]=ap_id;
								pipe[2]=0;
								pipe[3]=(int)(((long)avfile >> 16) & 0x0000ffffL);
								pipe[4]=(int)((long)avfile & 0x0000ffffL);
								pipe[5]=(int)(((long)avext >> 16) & 0x0000ffffL);
								pipe[6]=(int)((long)avext & 0x0000ffffL);
								pipe[7]=0;
							}
							
							if(strstr(avfile, "http")==NULL || strstr(avfile, "HTTP")==NULL)
								SendAV(avserver, pipe[0], pipe[1], pipe[2], pipe[3], pipe[4], pipe[5], pipe[6], pipe[7]);
							break;
						}
						
						if (keyboard & KsALT)
						{
							if (find_avserver(1))
							{
								int   pipe[8];
								char *dummy;
								
								strcpy(avfile,se->file);
								dummy=strrchr(avfile,'\\');
								if (dummy) *(++dummy)=0;

								if (dcmd)
								{
									char *ccmd = dcmd+1L;
					
									pipe[0]=AV_COPYFILE;
									pipe[1]=ap_id;
									pipe[2]=0;
									pipe[3]=(int)(((long)ccmd >> 16) & 0x0000ffffL);
									pipe[4]=(int)((long)ccmd & 0x0000ffffL);
									pipe[5]=(int)(((long)avfile >> 16) & 0x0000ffffL);
									pipe[6]=(int)((long)avfile & 0x0000ffffL);
					
									if (keyboard & KsCONTROL) pipe[7] = 1;
									else
										pipe[7]=0;
								}
								else if(strstr(avfile, "http")!=NULL || strstr(avfile, "HTTP")!=NULL)
									{
									SendHTML(avfile, "*");
									}
								else
								{
									pipe[0]=AV_OPENWIND;
									pipe[1]=ap_id;
									pipe[2]=0;
									pipe[3]=(int)(((long)avfile >> 16) & 0x0000ffffL);
									pipe[4]=(int)((long)avfile & 0x0000ffffL);
									pipe[5]=(int)(((long)avextall >> 16) & 0x0000ffffL);
									pipe[6]=(int)((long)avextall & 0x0000ffffL);
									pipe[7]=0;
								}
								
							if(strstr(avfile, "http")==NULL || strstr(avfile, "HTTP")==NULL)
								SendAV(avserver, pipe[0], pipe[1], pipe[2], pipe[3], pipe[4], pipe[5], pipe[6], pipe[7]);
							}
						}

						if ((keyboard&KsCONTROL) && (se->flags==SE_FILE))				/* Tylko dla:
																																					CPX, ACC, PRG, APP, TOS, TTP	*/
							{
							strcpy(avfile,se->file);
							if(strstr(avfile, ".CPX")!=NULL || strstr(avfile, ".ACC")!=NULL || strstr(avfile, ".PRG")!=NULL || strstr(avfile, ".APP")!=NULL || strstr(avfile, ".TOS")!=NULL || strstr(avfile, ".TTP")!=NULL)
								{
								se->file[strlen(se->file)-1] = 'Z';
								if(Frename(0, avfile, se->file)!=0)
									{
									char message[250]={0};
									sprintf(message, "%s", message[MSG_FILE_RENAME], avfile, se->file);
									mt_form_alert(1, message, (short*)&_GemParBlk.global[0]);
									}
								}
							else if(strstr(avfile, ".CPZ")!=NULL)
								{
								se->file[strlen(se->file)-1] = 'X';
								if(Frename(0, avfile, se->file)!=0)
									{
									char message[250]={0};
									sprintf(message, "%s", message[MSG_FILE_RENAME], avfile, se->file);
									mt_form_alert(1, message, (short*)&_GemParBlk.global[0]);
									}
								}
							else if(strstr(avfile, ".PRZ")!=NULL)
								{
								se->file[strlen(se->file)-1] = 'G';
								if(Frename(0, avfile, se->file)!=0)
									{
									char message[250]={0};
									sprintf(message, "%s", message[MSG_FILE_RENAME], avfile, se->file);
									mt_form_alert(1, message, (short*)&_GemParBlk.global[0]);
									}
								}
							else if(strstr(avfile, ".ACZ")!=NULL)
								{
								se->file[strlen(se->file)-1] = 'C';
								if(Frename(0, avfile, se->file)!=0)
									{
									char message[250]={0};
									sprintf(message, "%s", message[MSG_FILE_RENAME], avfile, se->file);
									mt_form_alert(1, message, (short*)&_GemParBlk.global[0]);
									}
								}
							else if(strstr(avfile, ".APZ")!=NULL)
								{
								se->file[strlen(se->file)-1] = 'P';
								if(Frename(0, avfile, se->file)!=0)
									{
									char message[250]={0};
									sprintf(message, "%s", message[MSG_FILE_RENAME], avfile, se->file);
									mt_form_alert(1, message, (short*)&_GemParBlk.global[0]);
									}
								}
							else if(strstr(avfile, ".TTZ")!=NULL)
								{
								se->file[strlen(se->file)-1] = 'P';
								if(Frename(0, avfile, se->file)!=0)
									{
									char message[250]={0};
									sprintf(message, "%s", message[MSG_FILE_RENAME], avfile, se->file);
									mt_form_alert(1, message, (short*)&_GemParBlk.global[0]);
									}
								}
							else if(strstr(avfile, ".TOZ")!=NULL)
								{
								se->file[strlen(se->file)-1] = 'S';
								if(Frename(0, avfile, se->file)!=0)
									{
									char message[250]={0};
									sprintf(message, "%s", message[MSG_FILE_RENAME], avfile, se->file);
									mt_form_alert(1, message, (short*)&_GemParBlk.global[0]);
									}
								}

							Reload_set();
							}

						else
						{
							play_sound(samplestart);
							playclose = 0;

							if (dcmd)
							{
								char *scmd = dcmd;
								
								if (se->fcmd)
								{
									char *pbuf,buf[1024],*dummy=se->fcmd + 1L;
									int   chng = 0;

									pbuf = buf;
									
									while ((*dummy) && ((dummy - se->fcmd) <= se->fcmd[0]))
									{
										if (*dummy=='$')
										{
											if (*(dummy+1L)=='$')
											{
												*pbuf='$';
												pbuf++;
												dummy+=2L;
												chng=1;
											}
											else if (*(dummy+1L)=='1')
											{
												if (dcmd[0]!=0)
												{
													strncpy(pbuf,dcmd+1L,dcmd[0]);
													pbuf += dcmd[0];
												}
												dummy+=2L;
												chng=1;
											}
											else
											{
												*pbuf=*dummy;
												pbuf++;
												dummy++;
											}
										}
										else
										{
											*pbuf=*dummy;
											pbuf++;
											dummy++;
										}
									}
									
									*pbuf=0;
									
									if (chng)
									{
										char *ncmd = (char *)calloc(1,strlen(buf)+2L);
										
										if (ncmd)
										{
											scmd=ncmd;
											strcpy(scmd+1L,buf);
											scmd[0] = min(strlen(buf),125);
										}
									}
								}

							start_app(0, SHW_PARALLEL, se->name, se->file, scmd);

								if (scmd!=dcmd) Mfree(scmd);
							}
						else
							start_app(0,SHW_PARALLEL,se->name, se->file,se->fcmd);
						}
					}
					break;
				}

				se = se->next;
			}
		}
	}

	if (playclose) play_sound(sampleclose);

	_drvend:
	if (drvpop)
		{
		mt_menu_attach(ME_REMOVE,menus->tree,1,NULL, (short*)&_GemParBlk.global[0]);
		free(drvpop);
		}
	
	if (docpop)
		{
		mt_menu_attach(ME_REMOVE,menus->tree,1+options.drives,NULL, (short*)&_GemParBlk.global[0]);
		free(docpop);
		}

	if (htmlpop)
		{
		mt_menu_attach(ME_REMOVE,menus->tree,1+options.drives,NULL, (short*)&_GemParBlk.global[0]);
		free(htmlpop);
		}

	bigbutton[btnidx].ob_state &= ~OS_SELECTED;
/*	redraw(0, desk.g_x,desk.g_y,desk.g_w,desk.g_h);	*/
	redraw(0, bigbutton->ob_x+bigbutton[btnidx].ob_x-3, bigbutton->ob_y+bigbutton[btnidx].ob_y-3, bigbutton[btnidx].ob_width+6, bigbutton[btnidx].ob_height+6, "start popup2");
	
	if ((untop) && (MyTask.whandle>0))
		mt_wind_set(MyTask.whandle,WF_BOTTOM,0,0,0,0, (short*)&_GemParBlk.global[0]);
}


void init_shutdown(void)
{
	if (strlen(shutdown))
	{
		long ret = Fopen(shutdown,FO_READ), len=0;
		
		if (ret>=0L)
		{
			int hdl = (int)ret;
			
			len = Fseek(0,hdl,2);
			
			Fclose(hdl);
		}
		
		if (len>20000L) start_app(0,SHW_PARALLEL,"ShutDown",shutdown,NULL);
		else
		{
			cleanup(0);
			apterm=1;
			quit=1;
			start_app(1,SHW_CHAIN,"ShutDown",shutdown,NULL);
		}
	}
	else
	{
		if (!(mt_shel_write(SHW_SHUTDOWN,1,0,NULL,NULL, (short*)&_GemParBlk.global[0])))
			mt_form_alert(1,message[MSG_INIT_SHUTDOWN], (short*)&_GemParBlk.global[0]);
	}
}


void info_popup(int mx, int my)
	{
	MENU menu,msel={0};
	int  ret,mnx = mx;

	if (mnx+startpopup[ROOT].ob_width > desk.g_x+desk.g_w) mnx = desk.g_x+desk.g_w-startpopup[ROOT].ob_width;

	if(!startpopup)
		return;
	menu.mn_tree     = startpopup;
	menu.mn_menu     = ROOT;
	menu.mn_item     = 1;
	menu.mn_scroll   = 0;
	menu.mn_keystate = 0;

	ret = mt_menu_popup(&menu,mnx,my-menu.mn_tree->ob_height,&msel, (short*)&_GemParBlk.global[0]);

	if (ret)
		{
		switch(msel.mn_item)
			{
			case 1:
				about();
				break;

			case 3:
				start_by_sel();
				break;

			case 4:			/* Show all buttons	*/
				{
				int i;
				if(DoNotShow)
					free(DoNotShow);
				DoNotShow = NULL;
				show_all_app = 1;
				for(i=0; i<_applications_->no; i++)
				 _applications_[i].show_button = 1;
				build_applications(-1);
				break;
				}

			case 5:			/* Czytaj .SET od nowa	*/
				Reload_set();
				break;

			case 7:			/* Options	*/
				Set_options(mx, my);
				break;

			case 8:
				if (options.noquitalert)
					quit=1;
				else
					{
					if (mt_form_alert(1,message[MSG_QUIT], (short*)&_GemParBlk.global[0])==1)
						quit=1;
					}
				break;
			
			case 9:
				init_shutdown();
				break;

			case 10:
				if (find_help()) call_help();
				break;
			}
		}
	}


void move_button(void)
	{
	short dummy,bstate;
	
	mt_evnt_timer(10, (short*)&_GemParBlk.global[0]);
	
	mt_wind_update(BEG_UPDATE, (short*)&_GemParBlk.global[0]);
	mt_wind_update(BEG_MCTRL, (short*)&_GemParBlk.global[0]);
	mt_graf_mkstate(&dummy,&dummy,&bstate,&dummy, (short*)&_GemParBlk.global[0]);
	
	if (bstate & 1)
		{
		short cx,cy,cw,ch,fx,fy;
		
		mt_graf_mouse(FLAT_HAND,NULL, (short*)&_GemParBlk.global[0]);

		mt_wind_get(MyTask.whandle,WF_WORKXYWH,&cx,&cy,&cw,&ch, (short*)&_GemParBlk.global[0]);
		
		if (mt_graf_dragbox(cw,ch,cx,cy,desk.g_x,desk.g_y,desk.g_w,desk.g_h,&fx,&fy, (short*)&_GemParBlk.global[0]))
			{
			short pipe[8];
			
			pipe[0]=WM_MOVED;
			pipe[1]=ap_id;
			pipe[2]=0;
			pipe[3]=MyTask.whandle;

			mt_wind_calc(WC_BORDER,WINDOWSTYLE,fx,fy,cw,ch,&pipe[4],&pipe[5],&pipe[6],&pipe[7], (short*)&_GemParBlk.global[0]);

			handle_message((int*)pipe);
			}
		
		mt_graf_mouse(ARROW,NULL, (short*)&_GemParBlk.global[0]);
		}
	else
		{
		if (is_top(MyTask.whandle))
			mt_wind_set(MyTask.whandle,WF_BOTTOM,0,0,0,0, (short*)&_GemParBlk.global[0]);
		else
			{
			if (!untop)
				mt_wind_set(MyTask.whandle,WF_TOP,0,0,0,0, (short*)&_GemParBlk.global[0]);
			}
		}
	
	mt_wind_update(END_MCTRL, (short*)&_GemParBlk.global[0]);
	mt_wind_update(END_UPDATE, (short*)&_GemParBlk.global[0]);
	}


void show_bubblehelp(int mx, int my, signed int ap_id, int cal)
	{
	if (!bubblehelp)
		bubblehelp = (char *)calloc(1,256L);

	if (bubblehelp)
		{
		int bubblegem = mt_appl_find("BUBBLE  ", (short*)&_GemParBlk.global[0]);
		
		if (bubblegem>=0)
			{
			if(cal==1)					/* Kalendarz									*/
				{
				strcpy(bubblehelp, bubble_calendar[abs(ap_id)]);
				ap_id = -1;
				}
			else								/* MyTask											*/
				{
				if(cal==2)				/* Przycisk aplikacji					*/
					{
					if(strlen(_applications_[ap_id].bubble)>0)
						strcpy(bubblehelp,	_applications_[ap_id].bubble);
					else if(strlen(_applications_[ap_id].alias)>0)
						strcpy(bubblehelp,	_applications_[ap_id].alias);
					else if(strlen(_applications_[ap_id].name)>0)
						strcpy(bubblehelp,	_applications_[ap_id].name);
					}
				else if(cal==3)						/* Ikonki aplikacji	(nie system tray!!!) */
					{
					int i=0;
					memset(bubblehelp, 0, 256);
					if(icons_spec_app[ap_id].name[strlen(icons_spec_app[ap_id].name)-1]!='\\')
						{
						for(i=(int)strlen(icons_spec_app[ap_id].name); i>0; i--)
							{
							if(icons_spec_app[ap_id].name[i]=='\\')
								{
								i++;
								break;
								}
							}
						}
					strcpy(bubblehelp,	&icons_spec_app[ap_id].name[i]);
					}
				else							/* Jakis staly obiekt MyTask	*/
					{
					/* ap_id	- obiekt dla ktorego trzeba pokazac pomoc	*/
					/*	strcpy(bubblehelp,	bubbleinfo[ap_id]);	*/
					strcpy(bubblehelp,	bubble_mytask[ap_id]);
					}
				}
			if(strlen(bubblehelp)>0)
				SendAV(bubblegem, BUBBLEGEM_SHOW, ap_id, 0, mx, my, (int)(((long)bubblehelp >> 16) & 0x0000ffffL), (int)((long)bubblehelp & 0x0000ffffL), 0);
			}
		}
	}

int objc_find_mytask(int mx, int my)
	{
	int i, st_x, en_x, st_y, en_y;		/*, objc;

	objc = objc_find( bigbutton, 0, MAX_DEPTH, mx, my);	*/

	for(i=bigbutton->ob_tail; i>-1; i--)				/* Trzeba sprawdzac od konca, w przeciwnym przypadku obiekt nr 0	*/
		{																					/* bedzie zawsze pierwszym obiektem spelniajacym nasze warunki		*/
		if(i!=0)																	/* i wlasciwy wybor obiektu bedzie niemozliwy!!										*/
			{
			st_x = bigbutton->ob_x + bigbutton[i].ob_x;
			en_x = st_x + bigbutton[i].ob_width;
			st_y = bigbutton->ob_y + bigbutton[i].ob_y;
			en_y = st_y + bigbutton[i].ob_height;
			}
		else																			/* Dla obiektu nr 0 jego polozenie jest okreslanie wzgledem ekranu			*/
			{																				/* a nie wzgledem samego siebie jak to ma miejsce dla innych obiektow.	*/
			st_x = bigbutton->ob_x;
			en_x = st_x + bigbutton->ob_width;
			st_y = bigbutton->ob_y;
			en_y = st_y + bigbutton->ob_height;
			}

		if(mx>st_x && mx<en_x && my>st_y && my<en_y)
			return(i);
		}	
	return(-1);
	}


int objc_find_calendar(int mx, int my)
	{
	int i, st_x, en_x, st_y, en_y;

	for(i=1; i<(calender->ob_tail+1); i++)
		{
		st_x = calender->ob_x + calender[i].ob_x;
		en_x = st_x + calender[i].ob_width;

		st_y = calender->ob_y + calender[i].ob_y;
		en_y = st_y + calender[i].ob_height;
		if(mx>st_x && mx<en_x && my>st_y && my<en_y)
			return(i);
		}
	return(-1);
	}



void handle_button(int mx, int my, int bstate, int kstate, int clicks)
	{
	short x,y,w,h,objc, w_han;

	if (MyTask.whandle<1)
		return;

	w_han = mt_wind_find((short)mx, (short)my, (short*)&_GemParBlk.global[0]);

	mt_wind_get(MyTask.whandle,WF_WORKXYWH,&x,&y,&w,&h, (short*)&_GemParBlk.global[0]);
	if ((!between(mx,x,x+w-1)) || (!between(my,y,y+h-1)) && w_han==MyTask.whandle)
		return;

	if((objc = objc_find_mytask(mx,my))==-1 && w_han==MyTask.whandle)
		return;

	if(w_han == MyTask.wh_calendar)
		{
		objc = mt_objc_find(calender, 0, MAX_DEPTH, mx, my, (short*)&_GemParBlk.global[0]);
		if(objc>0)
			{
			if(objc==2 || objc==3)
				{
				calender[objc].ob_state |= OS_SELECTED;
				redraw_cal(0, calender[objc].ob_x, calender[objc].ob_y, calender[objc].ob_width, calender[objc].ob_height);
				mt_evnt_timer(100, (short*)&_GemParBlk.global[0]);
				}
			switch(objc)
				{
				case 1:
					{
					MENU menu,msel;

					menu.mn_tree     = monthspopup;
					menu.mn_menu     = ROOT;
					menu.mn_item     = _calendar.cal_m;				/* Najpierw wskazujemy aktualny miesiac	*/
					menu.mn_scroll   = 0;
					menu.mn_keystate = 0;

					if(mt_menu_popup(&menu, mx, my, &msel, (short*)&_GemParBlk.global[0])==1)
						_calendar.cal_m = msel.mn_item;
					break;
					}
				case 2:
					if(_calendar.cal_m>1)
						_calendar.cal_m--;
					else
						{
						_calendar.cal_y--;
						_calendar.cal_m=12;
						}
					break;
				case 3:
					if(_calendar.cal_m<12)
						_calendar.cal_m++;
					else
						{
						_calendar.cal_y++;
						_calendar.cal_m=1;
						}
					break;
				}
			if(objc>0 && objc<4)
				{
				_calendar.change_month = 1;
				change_calendar();
				_calendar.change_month = 0;
				calender[objc].ob_state &= ~OS_SELECTED;
				redraw_cal(0, calender[objc].ob_x, calender[objc].ob_y, calender[objc].ob_width, calender[objc].ob_height);
				}
			}
		return;
		}



	if (bstate == 1)				/* Lewy klawisz myszki	*/
		{
		if (kstate&KsLSHIFT && kstate&KsCONTROL)
			move_button();

		else if (objc == btnidx)
			start_popup(NULL,0,0,DF_NONE,WHAT_NORMAL,NULL);				/* "echter" Button */

		else if(clicks==2 && objc==TIME_OBJECT)
			{
			if(options.doppelklick_time!=0)
				start_app(0,SHW_PARALLEL, "Time", options.doppelklick_time_path, NULL);
			}

		else if(objc==MYTASK_HIDE)
			{
			if(bigbutton[objc].ob_state&OS_SELECTED)
				{
				unhide_mytask_KDE();
				bigbutton[objc].ob_state &= ~OS_SELECTED;
				redraw(0, bigbutton->ob_x, bigbutton->ob_y, MyTask.prev_w, bigbutton->ob_height, "Unhide");
				mt_wind_set(MyTask.whandle, WF_CURRXYWH, bigbutton->ob_x, bigbutton->ob_y, bigbutton->ob_width, bigbutton->ob_height,(short*)&_GemParBlk.global[0]);
				}
			else
				{
				hide_mytask_KDE();
				bigbutton[objc].ob_state |= OS_SELECTED;
				redraw(0, 0, bigbutton->ob_y, MyTask.prev_w, bigbutton->ob_height, "Hide");
				SendAV(avserver, WM_REDRAW, ap_id, 0, 0, -1, -1, -1, -1);
				mt_wind_set(MyTask.whandle, WF_CURRXYWH, bigbutton->ob_x-2, bigbutton->ob_y, bigbutton->ob_width, bigbutton->ob_height,(short*)&_GemParBlk.global[0]);
				}
			}


		else if(bigbutton[objc].ob_type == G_CICON)
			{
			if(objc>=APP_ICON_1 && objc<=APP_ICON_LAST)
				{
				if(icons_spec_app!=NULL)
					{
					if(icons_spec_app->no>(objc-APP_ICON_1))
						{
						if(kstate&KsCONTROL)
							move_icon(objc);
						else if(icons_spec_app[objc-APP_ICON_1].name[strlen(icons_spec_app[objc-APP_ICON_1].name)-1]!='\\')
							{
							if(kstate & KsALT)
								{
								int pxy[4]={0};
								*(char **) (pxy)  = icons_spec_app[objc-APP_ICON_1].name; 
								SendAV(avserver, AV_OPENWIND, ap_id, 0, pxy[0], pxy[1], 0, 0, 0);
								}
							else
								start_app(0,SHW_PARALLEL,icons_spec_app[objc-APP_ICON_1].name,icons_spec_app[objc-APP_ICON_1].name,NULL);
							}
						else
							{
							int pxy[4]={0};
							*(char **) (pxy)  = icons_spec_app[objc-APP_ICON_1].name; 
							if(!(kstate&KsSHIFT))
								SendAV(avserver, AV_OPENWIND, ap_id, 0, pxy[0], pxy[1], 0, 0, 0);
							else
								zeige_ordner_popup(icons_spec_app[objc-APP_ICON_1].name, mx, my);
							}
						}
					else
						mt_form_alert(1, message[14], (short*)&_GemParBlk.global[0]);
					}
				}
			else if(objc>=SYS_ICON_1 && objc<=SYS_ICON_LAST)
				{
				int i, j;
				i = find_app_by_icon_no(objc);
				j = find_icon_no_by_app(objc, i);
				if(_applications_[i].type&APP_ACCESSORY)
					SendAV(_applications_[i].id, VA_START, ap_id, 0, 0, 0, 0, 0, 0);
				if(i>=0 && j>=0)
					SendAV(_applications_[i].id, MYTASK_ICON_CLICK, ap_id, bstate, clicks, mx, my, _applications_[i].ikonki[j].no, 0);
				}
			}
		else if(mouse_over_app(mx, my)==1 && objc>=APPLICATION_1 && objc<=(APPLICATION_1+_applications_->no))
			{
			if(info_app(objc, kstate, bstate, clicks, mx,my)==-1)
				info_popup(mx,my);
			}
		else
			move_button();
		}
	else if(bigbutton[objc].ob_type == G_CICON)
		{
		if(objc>=APP_ICON_1 && objc<=APP_ICON_LAST)
			{
			if(icons_spec_app!=NULL)
				{
				if(icons_spec_app->no>(objc-APP_ICON_1) && bstate==1)
					start_app(0,SHW_PARALLEL,icons_spec_app[objc-APP_ICON_1].name,icons_spec_app[objc-APP_ICON_1].name,NULL);
				else if(icons_spec_app->no>(objc-APP_ICON_1) && bstate==2)
					info_app_icon(objc, bstate, mx, my);
				else
					mt_form_alert(1, message[14], (short*)&_GemParBlk.global[0]);
				}
			}
		else if(objc>=SYS_ICON_1 && objc<=SYS_ICON_LAST)
			{
			int i, j;
			i = find_app_by_icon_no(objc);
			j = find_icon_no_by_app(objc, i);
			if(i>=0 && j>=0)
				SendAV(_applications_[i].id, MYTASK_ICON_CLICK, ap_id, bstate, clicks, mx, my, _applications_[i].ikonki[j].no, 0);
			}
		}
	else if(mouse_over_app(mx, my)==1 && objc>=APPLICATION_1 && objc<=(APPLICATION_1+_applications_->no))
		{
		if(info_app(objc, kstate, bstate, clicks, mx, my)!=1)
			info_popup(mx,my);
		}


	else if(bstate==2)				/* Prawy klawisz myszki	*/
		{
		if (objc==btnidx || objc==ROOT)
			info_popup(mx,my);
		else if(bigbutton[objc].ob_type == G_CICON)
			{
			int i, j;
			for(i=0; i<(_applications_->no+1); i++)
				{
				for(j=0; j<_applications_[i].il_ikonek; j++)
					{
					if(_applications_[i].ikonki[j].pos_x<mx && mx<(_applications_[i].ikonki[j].pos_x+16))
						{
						SendAV(_applications_[i].id, MYTASK_ICON_CLICK, ap_id, bstate, clicks, mx, my, _applications_[i].ikonki[j].no, 0);
						break;
						}
					}
				}
			}
		else if(objc == TIME_OBJECT)
			{
			calender->ob_x = mx - calender->ob_width;
			calender->ob_y = my - calender->ob_height;
			change_calendar();
			open_calendar();
			}
		else
			{
			int ap_id;
			ap_id = find_app_by_button_no(objc);
			if(ap_id>0)
				show_bubblehelp(mx, my, ap_id, 2);
			else
				show_bubblehelp(mx, my, objc, 0);
			}
		}
	}


char *nextToken(char *pcmd)
{
	if (!pcmd) return(NULL);

	pcmd += (strlen(pcmd) + 1);

	_again:

	switch(*pcmd)
	{
		case 0:
			return(NULL);

		case 1:
		case 2:
			/* Hex-Kommandos auswerten */
		case 3:
		case 4:
		case 5:
		case 6:
			pcmd += (strlen(pcmd) + 1);
			goto _again;

		default:
			return(pcmd);
	}
}


int doGSCommand(int app_no, int pipe[8])
	{
	int   answ[8], ret=0;
	char *cmd = *(char **)&pipe[3];

	answ[0]=GS_ACK;
	answ[1]=ap_id;
	answ[2]=0;
	answ[3]=pipe[3];
	answ[4]=pipe[4];
	answ[5]=0;
	answ[6]=0;
	answ[7]=GSACK_ERROR;
	
	if (cmd)
		{
		answ[7]=GSACK_UNKNOWN;

		if (!stricmp(cmd,"Quit"))
			{
			ret=1;
			answ[7]=GSACK_OK;
			}
		else if (!stricmp(cmd,"Open"))
			{
			cmd = nextToken(cmd);
			
			while (cmd)
				{
				start_app(0,SHW_PARALLEL,"GEMScript",cmd,NULL);
				mt_evnt_timer(500, (short*)&_GemParBlk.global[0]);
				cmd = nextToken(cmd);
				}

			answ[7]=GSACK_OK;
			}
		else if (!stricmp(cmd,"CheckApp"))
			{
			cmd = nextToken(cmd);

			if (cmd)
				{
				start_app(0,SHW_PARALLEL,"GEMScript",cmd,NULL);
				mt_evnt_timer(500, (short*)&_GemParBlk.global[0]);
				answ[7]=GSACK_OK;
				}
			else
				{
				answ[7]=GSACK_ERROR;
				}
			}
		else if (!stricmp(cmd,"AppGetLongName"))
			{
			if (gslongname)
				{
				answ[5]=(int)(((long)gslongname >> 16) & 0x0000ffffL);
				answ[6]=(int)((long)gslongname & 0x0000ffffL);
				answ[7]=GSACK_OK;
				}
			else
				{
				answ[7]=GSACK_ERROR;
				}
			}
		else if (!stricmp(cmd,"OpenDrives"))
			{
			open_over_mouse(NULL,WHAT_DRIVES,NULL);
			answ[7]=GSACK_OK;
			}
		else if (!stricmp(cmd,"OpenHistory"))
			{
			open_over_mouse(NULL,WHAT_HISTORY,NULL);
			answ[7]=GSACK_OK;
			}
		else if (!stricmp(cmd,"OpenApplications"))
			{
			/**/
			answ[7]=GSACK_UNKNOWN /*OK*/;
			}
		else if (!stricmp(cmd,"OpenMenu"))
			{
			cmd = nextToken(cmd);

			if (cmd) open_over_mouse(NULL,WHAT_MENU,cmd);
			else
				open_over_mouse(NULL,WHAT_NORMAL,NULL);

			answ[7]=GSACK_OK;
			}
		else if(!stricmp(cmd,"Notify"))
			_applications_[app_no].notify = 1;
		}

	SendAV(pipe[1], answ[0], answ[1], answ[2], answ[3], answ[4], answ[5], answ[6], answ[7]);

	return(ret);
	}


void open_over_mouse(char *p, int what, char *mname)
	{
	short mx,my,md;
	
	mt_graf_mkstate(&mx,&my,&md,&md, (short*)&_GemParBlk.global[0]);
	
	start_popup(p,mx,my,DF_LEFT,what,mname);
	}


int handle_message(int pipe[8])
{
	switch (pipe[0])
	{
		case FONT_CHANGED:
			{
			signed int font_id, font_height, font_col, font_eff;
			short mx,my,md,objc,appl,i;
			mt_graf_mkstate(&mx,&my,&md,&md, (short*)&_GemParBlk.global[0]);
			objc = mt_objc_find(bigbutton, 0, MAX_DEPTH, mx, my, (short*)&_GemParBlk.global[0]);
			appl = find_app_by_button(objc, mx);
			font_id = pipe[4];			font_height = pipe[5];
			font_col = pipe[6];			font_eff = pipe[7];
			if(appl>-1)
				{
				_applications_[appl].font_id = font_id;
				_applications_[appl].font_color = font_col;
				_applications_[appl].font_effect = font_eff;
				_applications_[appl].font_height = (font_height>startinf.font_height ? startinf.font_height : font_height);
				Add_app_font(appl, font_id, font_col, font_eff, _applications_[appl].font_height);
				build_applications(-1);
				SendAV(ap_id, WM_REDRAW, ap_id, RED_FONT, MyTask.whandle, bigbutton->ob_x, bigbutton->ob_y, bigbutton->ob_width, bigbutton->ob_height);
				SendAV(pipe[1], FONT_ACK, ap_id, 0, 1, 0, 0, 0, 0);
				}
			else if(objc==TIME_OBJECT)
				{
				int str_len1, str_len2;
				int h1=6;
				str_len1 = get_text_width(text_time_line1, -1, font_id, &h1);
				str_len2 = get_text_width(text_time_line2, -1, font_id, &h1);
				startinf.timer_font_id = font_id;
				bigbutton[TIME_OBJECT].ob_width = max(str_len2, str_len1);
				fix_width();
				SendAV(ap_id, WM_REDRAW, ap_id, 0, MyTask.whandle, bigbutton->ob_x+bigbutton[TIME_OBJECT].ob_x, bigbutton->ob_y+bigbutton[TIME_OBJECT].ob_y, bigbutton[TIME_OBJECT].ob_width, bigbutton[TIME_OBJECT].ob_height);
				SendAV(pipe[1], FONT_ACK, ap_id, 0, 1, 0, 0, 0, 0);
				}
			else if(objc==0)
				{
				startinf.default_font_id = font_id;
				startinf.font_height = font_height;

				for(i=0; i<_applications_->no; i++)
					{
					_applications_[i].font_id = font_id;
					_applications_[i].font_color = font_col;
					_applications_[i].font_effect = font_eff;
					_applications_[i].font_height = (font_height>startinf.font_height ? startinf.font_height : font_height);
					Add_app_font(i, font_id, font_col, font_eff, _applications_[i].font_height);
					}
				build_applications(-1);
				SendAV(ap_id, WM_REDRAW, ap_id, RED_FONT, MyTask.whandle, bigbutton->ob_x, bigbutton->ob_y, bigbutton->ob_width, bigbutton->ob_height);
				SendAV(pipe[1], FONT_ACK, ap_id, 0, 1, 0, 0, 0, 0);
				}
			break;
			}

		case MN_SELECTED:
			if (pipe[4]==RM_START)
			{
				char path[256],file[128],*c;
				short  btn;
				
				strcpy(path,"*.*");
				strcpy(file,"");

				if (mt_fsel_exinput(path,file,&btn,fseltitle, (short*)&_GemParBlk.global[0]))
				{
					if (btn==1)
					{
						if (strlen(file))
						{
							c=strrchr(path,'\\');
							if (c) *(++c) = 0;
							
							strcat(path,file);
							play_sound(samplestart);
							start_app(0,SHW_PARALLEL,"Menu",path,NULL);
						}
					}
				}
			}
			if (pipe[3] >= 0) mt_menu_tnormal(deskmenu,pipe[3],1, (short*)&_GemParBlk.global[0]);
			break;
			
		case WM_REDRAW:
			if (pipe[3]==MyTask.whandle)
				{
				if(options.draw_obj)
					{
					int aa;
					if(pipe[2]<0)
						{
						printf("%d\r\n", pipe[2]);
						pipe[2] = 0;
						}
					aa = find_app_by_id(pipe[1]);
					}

				if(pipe[2]<0)
					pipe[2]=0;
				if(bigbutton[pipe[2]].ob_type==G_CICON)
					{
					redraw(SEPARATOR_3, pipe[4],pipe[5],pipe[6],pipe[7], "WM_REDRAW1");
					redraw(TIME_SEPARATOR, pipe[4],pipe[5],pipe[6],pipe[7], "WM_REDRAW2");
					}
				else
					redraw(pipe[2], pipe[4],pipe[5],pipe[6],pipe[7], "WM_REDRAW3");
				}
			else if(pipe[3]==MyTask.wh_calendar)
				redraw_cal(pipe[2], pipe[4],pipe[5],pipe[6],pipe[7]);
			else if(pipe[3]==wh_icons)
				redraw_dial(mini_icons, wh_icons, pipe[2], pipe[4],pipe[5],pipe[6],pipe[7]);
			break;

		case WM_ONTOP:
		case WM_NEWTOP:
			if ((pipe[3]==MyTask.whandle) && (untop) && (appline<0))
				mt_wind_set(MyTask.whandle,WF_BOTTOM,0,0,0,0, (short*)&_GemParBlk.global[0]);
			break;

		case WM_TOPPED:
			if ((pipe[3]==MyTask.whandle || pipe[3]==MyTask.wh_calendar || pipe[3]==wh_icons) && (!untop) && (appline<0))
				mt_wind_set(pipe[3],WF_TOP,0,0,0,0, (short*)&_GemParBlk.global[0]);
			break;

		case WM_CLOSED:
			close_window(pipe[3]);
			if (wmclosed)
				{
				if (_app)
					return(1);
				}
			break;
		

		case WM_MOVED:
			if (pipe[3]==MyTask.whandle)
				{
				short x,y,w,h;
				
				mt_wind_calc(WC_WORK,WINDOWSTYLE,pipe[4],pipe[5],pipe[6],pipe[7],&x,&y,&w,&h, (short*)&_GemParBlk.global[0]);
				
				if (between(x,desk.g_x,desk.g_x+desk.g_w-1) && between(y,desk.g_y,desk.g_y+desk.g_h-1) || (options.magxfadeout))
					{
					startinf.workxabs = x;
					startinf.workyabs = y;
					clip_startinf();

					mt_wind_calc(WC_BORDER,WINDOWSTYLE,bigbutton[ROOT].ob_x,bigbutton[ROOT].ob_y,bigbutton[ROOT].ob_width,bigbutton[ROOT].ob_height,&x,&y,&w,&h, (short*)&_GemParBlk.global[0]);

					mt_wind_set(MyTask.whandle,WF_CURRXYWH,x,y,w,h, (short*)&_GemParBlk.global[0]);
					}
				}
			else if(pipe[3]==MyTask.wh_calendar)
				MOVE_WINDOW(MyTask.wh_calendar, _calendar.size_w, _calendar.size_h)
			else if(pipe[3]==wh_icons)
				MOVE_WINDOW(wh_icons, icons_app.w_w, icons_app.w_h)
			break;

		case WM_BOTTOMED:
		case WM_M_BDROPPED:
			if (pipe[3]==MyTask.whandle)
				mt_wind_set(MyTask.whandle,WF_BOTTOM,0,0,0,0, (short*)&_GemParBlk.global[0]);
			break;
		
		case AP_DRAGDROP:
			{
				char pname[] = "U:\\PIPE\\DRAGDROP.xx";
				long res;
				
				pname[17] = (pipe[7]>>8) & 0x00ff;
				pname[18] = pipe[7] & 0x00ff;
				
				res=Fopen(pname,FO_RW);
				if (res>=0L)
				{
					long dtype,dsize;
					int  hlen,success = 0,handle = (int)res;
					char c = DD_OK,ptypes[32],*pcmd = NULL;

					memset(ptypes,0,32);
					strcpy(ptypes,"ARGS");

	        if (Fwrite(handle,1,&c) != 1)					goto _perror;
	        if (Fwrite(handle,32,ptypes) != 32)		goto _perror;
	        if (Fread(handle,2,&hlen) != 2)				goto _perror;
	        if (Fread(handle,4,&dtype) != 4)			goto _perror;
	        if (Fread(handle,4,&dsize) != 4)			goto _perror;
	        
	        if (dsize<1) goto _perror;
	        
	        hlen -= 8;
	        while (hlen>0)
		        {
	        	if (Fread(handle,min(hlen,32),ptypes) != min(hlen,32)) goto _perror;
	        	hlen -= 32;
		        }

	        if (Fwrite(handle,1,&c) != 1) goto _perror;
	        if (dtype=='ARGS')
	    	    {
						pcmd = (char *)calloc(1,dsize+1L);
						if (!pcmd) goto _perror;

	        	if (Fread(handle,dsize,pcmd+1) != dsize) goto _perror;
						success = 1;
	  	      }

		_perror:
					Fclose(handle);

					if (success)
						{
						pcmd[0] = min(dsize-1,125);
						start_popup(pcmd,0,0,DF_NONE,WHAT_NORMAL,NULL);
						}

					if (pcmd)
						Mfree(pcmd);
				}
			}
			break;
		
		case MYTASK_CHANGED_OPTIONS:
			fix_width();
			build_applications(-1);
			SendAV(ap_id, WM_REDRAW, ap_id, RED_CHANGE_OPT, MyTask.whandle, bigbutton->ob_x, bigbutton->ob_y, bigbutton->ob_width, bigbutton->ob_height);
			Save_options();
			if(options.acc_in_system_tray==0)
				DeleteACCicon();
			build_app_menu();
			fix_tree(apppopup);
			break;

		case MYTASK_NAME:
			{
			int i;
			char *data = *(char **)&pipe[3];
			i = find_app_by_id(pipe[1]);
			if(data && i!=-1)
				{
				memset(_applications_[i].alias, 0, 24);
				strncpy(_applications_[i].alias, data, min(24, strlen(data)));
				_applications_[i].new_name = 1;
				build_applications(-1);		/* xxx	*/
				SendAV(ap_id, WM_REDRAW, ap_id, RED_NEW_NAME, MyTask.whandle, bigbutton->ob_x, bigbutton->ob_y, bigbutton->ob_width, bigbutton->ob_height);
				mt_evnt_timer(100, (short*)&_GemParBlk.global[0]);
				}
			break;
			}

		case MYTASK_NEW_COLOR:
			{
			int i, color;
			color = pipe[2];
			i = find_app_by_id(pipe[1]);
			_applications_[i].button_color = color;
			break;
			}

		case MYTASK_NEW_ICON:
			{
			int i, j, icon_nr;
			unsigned long *array;
			char *col_data, *col_mask, *mono_data, *mono_mask;

			icon_nr = pipe[2];
			i = find_app_by_id(pipe[1]);
			j = find_icon(&_applications_[i], icon_nr);
			if(j==-1)
				icons_sys.how_many++;
			array = (unsigned long*)(*(char **)&pipe[3]);
			mono_mask = (char*)*array;
			mono_data = (char*)*(array+1);
			col_mask = (char*)*(array+2);
			col_data = (char*)*(array+3);
			if((col_mask==NULL || col_data==NULL) && options.acc_in_system_tray==TRUE)
				{
				OBJECT *tmp=NULL;
				tmp = (OBJECT*)(*(char **)&pipe[3]);
				if(tmp)
					{
					CICONBLK *icon;
					icon = (CICONBLK*)(tmp->ob_spec.ciconblk);
					mono_data = (char*)icon->monoblk.ib_pdata;
					mono_mask = (char*)icon->monoblk.ib_pmask;
					col_data = (char*)icon->mainlist->col_data;
					col_mask = (char*)icon->mainlist->col_mask;
					}
				}
			if(j==-1)
				j = add_icon((void*)&_applications_[i], SYS_TRAY, icon_nr, mono_data, mono_mask, col_data, col_mask);
			else
				{
				if(replace_icon(&_applications_[i], j, icon_nr, mono_data, mono_mask, col_data, col_mask)==-1)
					SendAV(pipe[1], MYTASK_ICON_ERROR, ap_id, icon_nr, 0, 0, 0, 0, 0);
				}

			fix_width();		/* xxx */
			SendAV(ap_id, WM_REDRAW, ap_id, RED_NEW_ICON, MyTask.whandle, bigbutton->ob_x, bigbutton->ob_y, bigbutton->ob_width, bigbutton->ob_height);
			break;
			}

		case MYTASK_DELETE_ICON:
			{
			int app_id, icon_nr;
			app_id = pipe[1];
			icon_nr = pipe[2];			/* if icon_nr=0 -> delete all icons: NOT IMPLEMENTED	*/
			app_id = find_app_by_id(pipe[1]);
			if(_applications_[app_id].il_ikonek>=1)
				{
				delete_icon(&_applications_[app_id], icon_nr);
				fix_width();
				SendAV(ap_id, WM_REDRAW, ap_id, RED_DEL_ICON, MyTask.whandle, bigbutton[SEPARATOR_3].ob_x, bigbutton->ob_y, bigbutton[TIME_OBJECT].ob_x, bigbutton->ob_height);
				}
			break;
			}

		case MYTASK_BUTTON:
			{
			int app_id;
			app_id = find_app_by_id(pipe[1]);
			if(pipe[2]==0)
				_applications_[app_id].show_button = 0;
			else
				_applications_[app_id].show_button = 1;
			build_applications(-1);
			break;
			}

		case MYTASK_GET_SIZE:
			{
			SendAV(pipe[1], MYTASK_GET_SIZE, ap_id, MyTask.cur_x, MyTask.cur_y, MyTask.cur_w, MyTask.cur_h, 0, 0);
			break;
			}

		case MYTASK_BUBBLE_CHANGE:
			{
			int app_id, len;
			char *text=NULL;
			app_id = pipe[1];
			len = pipe[2];
			app_id = find_app_by_id(pipe[1]);
			if(len>0)
				{
				text = *(char **)&pipe[3];
				memset(_applications_[app_id].bubble, 0, 256);
				strncpy(_applications_[app_id].bubble, text, min(len, 256));
				}
			break;
			}

		case AP_TERM:
			cleanup(0);
			apterm=1;
			return(1);

		case AC_OPEN:
			if (pipe[4]==menu_id)
				open_main_window();
			break;

		case AC_CLOSE:
			if (pipe[3]==menu_id)
				MyTask.whandle=0;
			break;
		
		case VA_DRAGACCWIND:
			if (MyTask.whandle==pipe[3])
				{
				char *p = *(char **)&pipe[6];
				short app_no, mx, my, md;

				mt_graf_mkstate(&mx,&my,&md,&md, (short*)&_GemParBlk.global[0]);

				app_no = mt_objc_find(bigbutton, ROOT, MAX_DEPTH, mx, my, (short*)&_GemParBlk.global[0]);
				app_no = find_app_by_button(app_no, 0);
				
				if(p && app_no!=-1)
					SendAV(_applications_[app_no].id, VA_START, ap_id, 0, pipe[6], pipe[7], 0, 0, 0);
				else if (p)
					{
					char *pcmd = (char *)calloc(1,strlen(p)+2L);

					if (pcmd)
						{
						int objc=0;
						strcpy(pcmd+1L,p);
						pcmd[0] = min(strlen(p),125);
						strcpy(&pcmd[1], p);

						objc = mt_objc_find(bigbutton, 0, MAX_DEPTH, mx, my, (short*)&_GemParBlk.global[0]);

						if(objc>=APP_ICON_1 && objc<=APP_ICON_LAST)							/* Obiekt na ikonke w APP TRAY	*/
							start_app(1,SHW_PARALLEL, icons_spec_app[objc-APP_ICON_1].name, icons_spec_app[objc-APP_ICON_1].name, pcmd);
						else if(objc>=APPLICATION_1 && objc<=APPLICATION_LAST)	/* Obiekt na przycisk aplikacji	*/
							{
							int app_no, pxy[2]={0};
							app_no = find_app_by_button_no(objc);
							*(char **) (pxy) = p;
							SendAV(_applications_[app_no].id, VA_START, ap_id, pxy[0],pxy[1],0,0,0,0);
							}
						else if(objc==START_BUTTON)
							importiere_longname(p);
						else																										/* Obiekt na dowolne inne miejsce	*/
							{
							if(add_icon_app(pcmd+1L, 1)!=1)												/* Dodanie ikonki do APP TRAY?		*/
								start_popup(pcmd,0,0,DF_NONE,WHAT_NORMAL,NULL);
							}

						Mfree(pcmd);
						}

					SendAV(pipe[1], AV_STARTED, ap_id, 0, pipe[6], pipe[7], 0, 0, 0);
					}
				}
			break;

		case VA_START:
				{
				open_main_window();

				if (pipe[7]==DF_RIGHT)
					info_popup(pipe[5],pipe[6]);
				else
					{
					char *pcmd, *p = *(char **)&pipe[3];

					if(strstr(p, ".grp")==0 || strstr(p, ".GRP")==0)
						{
						STARTMENU menu;
						MENU msel, pop, pop1;
						int ret;
						memset(&menu, 0, sizeof(STARTMENU));
						printf("Grupa Thing: %s\n", p);
						read_group(p, &menu);
						pop.mn_menu=0;
						pop.mn_item = 1;
						pop.mn_scroll=0;
						pop.mn_keystate=0;
						pop.mn_tree = build_popup_thing(&menu);
						mt_menu_attach(ME_ATTACH, menu.tree, 1, &pop, (short*)&_GemParBlk.global[0]);
						ret = mt_menu_popup(&pop1,100,100,&msel, (short*)&_GemParBlk.global[0]);
						
						break;
						}
					else if (p)
						{
						if (!strcmp(p,"/smu-open"))
							{
							open_over_mouse(NULL,WHAT_NORMAL,NULL);
							break;
							}
						}
				
					pcmd = (p) ? ((strlen(p)) ? (char *)calloc(1,strlen(p)+2L) : NULL) : NULL;

					if (pcmd)
						{
						strcpy(pcmd+1L,p);
						pcmd[0] = min(strlen(p),125);
						}

					if (pipe[7]==DF_LEFT)
						start_popup(pcmd,pipe[5],pipe[6],DF_LEFT,WHAT_NORMAL,NULL);
					else
						open_over_mouse(pcmd,WHAT_NORMAL,NULL);
						
					if (pcmd) Mfree(pcmd);
					}

				SendAV(pipe[1], AV_STARTED, ap_id, 0, pipe[3], pipe[4], 0, 0, 0);
				}
			break;

		case AV_EXIT:
			if (pipe[3]==avserver) avserver=-1;
			break;
		
		case AV_PROTOKOLL:
			find_avserver(1);
			SendAV(pipe[1], VA_PROTOSTATUS, ap_id, 0, VAMSG, 0, 0, (int)(((long)accname >> 16) & 0x0000ffffL), (int)((long)accname & 0x0000ffffL));
			break;
		
		case VA_PROGSTART:
		case VA_WINDOPEN:
			if (!pipe[3]) play_sound(sampleavfail);
			break;

		case AV_STARTPROG:
			{
				char *pcmd, *p = *(char **)&pipe[5];

				pcmd = (p)?(char *)calloc(1,strlen(p)+2L):NULL;

				if (pcmd)
				{
					strcpy(pcmd+1L,p);
					pcmd[0] = min(strlen(p),125);
				}
				
				start_app(1,SHW_PARALLEL,"AV", *(char **)&pipe[3],pcmd);

				if (pcmd) Mfree(pcmd);
				
				SendAV(pipe[1], VA_PROGSTART, ap_id, 0, 1, 0, 0, 0, pipe[7]);
			}
			break;
		
		case DHST_ADD:
				SendAV(pipe[1], DHST_ACK, ap_id, 0, pipe[3], pipe[4], 0, 0, add_dhst(*(DHSTINFO **)&pipe[3]));
			break;
		
		case BUBBLEGEM_REQUEST:
			{
			int ap_id, objc, mx,my;
			mx = pipe[4];	my = pipe[5];
			objc = objc_find_mytask(mx, my);
			ap_id = find_app_by_button(objc, mx);
			if (objc != btnidx && objc!=-1 && ap_id>=0)
				show_bubblehelp(pipe[4], pipe[5], ap_id, 2);				/* BubbleGEM dla aplikacji	*/
			else if(objc!=0 && objc != btnidx)
				{
				if((ap_id=find_appicon_by_objc(objc))!=-1)							/* Ikonka aplikacji					*/
					show_bubblehelp(pipe[4], pipe[5], ap_id, 3);				/* BubbleGEM dla kalendarza	*/
				else
					{
					ap_id = -1*objc_find_calendar(mx, my);
					if(ap_id!=1)
						show_bubblehelp(pipe[4], pipe[5], ap_id, 1);				/* BubbleGEM dla kalendarza	*/
					else
						show_bubblehelp(pipe[4], pipe[5], objc, 0);						/* BubbleGEM dla MyTask	*/
					}
				}
			else if(objc == btnidx)
				show_bubblehelp(pipe[4], pipe[5], objc, 0);						/* BubbleGEM dla MyTask	*/
			break;
			}
		
		case GS_REQUEST:
				{
				int answ[8];
				
				if (!gsi)
					gsi = (GS_INFO *)calloc(1,sizeof(GS_INFO));
				
				if (gsi)
					{
					GS_INFO *sender = *(GS_INFO **)&pipe[3];

					gsi->len     = sizeof(GS_INFO);
					gsi->version = 0x0120;
					gsi->msgs    = GSM_COMMAND;
					gsi->ext     = 0L;
					
					answ[3]=(int)(((long)gsi >> 16) & 0x0000ffffL);
					answ[4]=(int)((long)gsi & 0x0000ffffL);
					
					if (sender)
						{
						if (sender->version >= 0x0070)		/* Minimalna wersja GEMScript	*/
							{
							answ[6] = 0;				/* 0-OK, 2-daj inne ID, inne to blad	*/
							gsapp = pipe[1];
							}
						}
					}
				
				SendAV(gsapp, GS_REPLY, ap_id, 0, answ[3], answ[4], 0, 1, pipe[7]);
				}
			break;

		case GS_REPLY:
			{
			int app_no, app_id=pipe[1], answ[8];
			char *command="AppGetLongName";
			app_no = find_app_by_id(app_id);

			if(pipe[6]==0)				/* Aplikacja obsluguje GEMScript i GS ID jest ok			*/
				{
				_applications_[app_no].gs_id = pipe[7];
				_applications_[app_no].gs |= GS_SUPPORT;
/*				_applications_[app_no].gs_support = pipe[6];	*/
				answ[3] = (int)(((long)command >> 16) & 0x0000ffffL);
				answ[4]=(int)((long)command & 0x0000ffffL);
				sended_gsc_ln++;
				SendAV(app_id, GS_COMMAND, ap_id, 0, answ[3], answ[4], 0, 2, pipe[7]);

				command = "CheckCommand\0x0WinIconify";
				_applications_[app_no].gs &= ~GS_ICONIFY;
				_applications_[app_no].gs &= ~GS_UNICONIFY;
				answ[3] = (int)(((long)command >> 16) & 0x0000ffffL);
				answ[4]=(int)((long)command & 0x0000ffffL);
				SendAV(app_id, GS_COMMAND, ap_id, 0, answ[3], answ[4], 0, 2, pipe[7]);

				command = "CheckCommand\0x0WinUnIconify";
				answ[3] = (int)(((long)command >> 16) & 0x0000ffffL);
				answ[4]=(int)((long)command & 0x0000ffffL);
				SendAV(app_id, GS_COMMAND, ap_id, 0, answ[3], answ[4], 0, 2, pipe[7]);
				}
			else if(pipe[6]==2)		/* GEMScript obslugiwany ale ID jest zle - zmienic ID	*/
				{
				if (!gsi)
					gsi = (GS_INFO *)calloc(1,sizeof(GS_INFO));
				if (gsi)
					{
					gsi->len     = sizeof(GS_INFO);
					gsi->version = 0x0120;
					gsi->msgs    = GSM_COMMAND;
					gsi->ext     = 0L;
					_applications_[app_no].gs_id++;
					SendAV(pipe[1], GS_REQUEST, ap_id, 0, (int)(((long)gsi >> 16) & 0x0000ffffL), (int)((long)gsi & 0x0000ffffL), 0, 0, _applications_[app_no].gs_id);
					}
				}
			else									/* Aplikacja nie obsluguje wogole GEMScriptu	*/
				_applications_[app_no].gs &= ~GS_SUPPORT;
				
			break;
			}

		case GS_ACK:
			{
			int app_no, app_id=pipe[1];
			char *p = *(char **)&pipe[5];
			char *com = *(char **)&pipe[3];

			app_no = find_app_by_id(app_id);
			if(p && strcmp(com, "AppGetLongName")==0)
				{
				memset(_applications_[app_no].alias, 0, 24);
				_applications_[app_no].new_name = 1;
				strcpy(_applications_[app_no].alias, p);
				sended_gsc_ln--;
				if(sended_gsc_ln==0)
					build_applications(-1);
				}
			else if(p && strcmp(com, "CheckCommand")==0)			/* Szukamy komend: WinIconify, WinUnIconify	*/
				{
				if(strcmp(&com[strlen("CheckCommand")+1], "WinIconify")==0 && *p=='1')
					_applications_[app_no].gs |= GS_ICONIFY;
				if(strcmp(&com[strlen("CheckCommand")+1], "WinUnIconify")==0 && *p=='1')
					_applications_[app_no].gs |= GS_UNICONIFY;
				}
			break;
			}

		case GS_COMMAND:
			{
			int app_no, app_id=pipe[1];
			app_no = find_app_by_id(app_id);
			if (doGSCommand(app_no, pipe))
				return(1);
			break;
			}

		case GS_QUIT:
			if (pipe[1]==gsapp)
				gsapp = -1;
			break;

		case AV_SENDKEY:
			{
			int mkey = MapKey(pipe[3],pipe[4]);

			handle_keyboard(mkey & 0xff00,mkey & 0x00ff);
			}
			break;

		case VA_PROTOSTATUS:
			if (!find_avserver(1))
			{
				if ((pipe[3] & 16) && (pipe[3] & 32) && (options.vaprotostatus))
				{
					avserver=pipe[1];
					strcpy(servername,*(char **)&pipe[6]);
				}
			}
			break;
/*	
		case ACC_ID:
				SendAV(pipe[1], ACC_ACC, ap_id, 0, 0, (int)(((long)xaccname >> 16) & 0x0000ffffL, (int)((long)xaccname & 0x0000ffffL), menu_id, 0);
			break;
*/
		case APPLINE_MSG:
			if ((applinepos) && (MyTask.whandle>0))
			{
				short nx,ny,nw,nh,answ[8];
				OBJECT *obj = *(OBJECT **)&pipe[4];

				mt_wind_get(MyTask.whandle,WF_CURRXYWH,&nx,&ny,&nw,&nh, (short*)&_GemParBlk.global[0]);
				
				if (pipe[6] == 0)
				{
					if (pipe[7] & 4)
					{
						nx = obj->ob_x - 1;
						ny = obj->ob_y+obj->ob_height + 2;

						if (ny+nh>desk.g_y+desk.g_h)
						{
							ny = desk.g_y+desk.g_h-nh;
							nx = obj->ob_x+obj->ob_width + 2;
						}
					}
					else
					{
						ny = obj->ob_y - 1;
						
						if (pipe[7] & 2)
						{
							nx = obj->ob_x - nw - 2;

							if (nx<0)
							{
								nx = 0;

								if (pipe[7] & 1) ny = obj->ob_y+obj->ob_height + 2;
								else
									ny = obj->ob_y - nh - 2;
							}
						}
						else
						{
							nx = obj->ob_x+obj->ob_width + 2;

							if (nx+nw>desk.g_x+desk.g_w)
							{
								nx = desk.g_x+desk.g_w-nw;

								if (pipe[7] & 1) ny = obj->ob_y+obj->ob_height + 2;
								else
									ny = obj->ob_y - nh - 2;
							}
						}
					}
				}
				else
				{
					nx = obj->ob_x - nw - 2;
					ny = obj->ob_y - 1;

					if (nx<0) nx = obj->ob_x+obj->ob_width + 2;
				}
				
				answ[0]=WM_MOVED;
				answ[1]=ap_id;
				answ[2]=0;
				answ[3]=MyTask.whandle;
				answ[4]=nx;
				answ[5]=ny;
				answ[6]=nw;
				answ[7]=nh;
				/* Resource aužerhalb des Bildschirms? */

				handle_message((int*)answ);
			}
			break;
		
		case SHUT_COMPLETED:
			if ((!(pipe[3])) && (pipe[4] == -1))
			{
				mt_evnt_timer(shuttimeout, (short*)&_GemParBlk.global[0]);
				mt_shel_write(SHW_SHUTDOWN,1,0,NULL,NULL, (short*)&_GemParBlk.global[0]);
			}

			if ((pipe[3]) || (pipe[4] == -1))
			{
				cleanup(0);
				apterm=1;
				return(1);
			}

			mt_shel_write(SHW_SHUTDOWN,0,0,NULL,NULL, (short*)&_GemParBlk.global[0]);
			mt_form_alert(1,message[MSG_FINISH_SHUTDOWN], (short*)&_GemParBlk.global[0]);
			break;
	}

	return(0);
}


int print_two(int handle, int value)
{
	char num[10];
	
	itoa(value,num,10);
	if (value<10)
	{
		if (Fwrite(handle,1L,"0") != 1L) return(1);
	}
	
	return(Fwrite(handle,strlen(num),num) != strlen(num));
}


void start_timer(TIMER *dtimer)
{
	if (strlen(logfile))
	{
		long ret;
		int  handle;

		ret=Fopen(logfile,FO_WRITE);
	
		if (ret<0L) ret=Fcreate(logfile,0);
		
		if (ret>=0L)
		{
			char         num[16];
			unsigned int t = Tgettime(),
			             d = Tgetdate();
			
			handle=(int)ret;
			if (Fseek(0,handle,2) < 0L) goto _error;
			
			if (print_two(handle,d & 0x001f)) goto _error;
			if (Fwrite(handle,1L,".") != 1L) goto _error;
			if (print_two(handle,(d >> 5) & 0x000f)) goto _error;
			if (Fwrite(handle,1L,".") != 1L) goto _error;
			itoa(((d >> 9) & 0x007f) + 1980,num,10);
			if (Fwrite(handle,strlen(num),num) != strlen(num)) goto _error;
			if (Fwrite(handle,1L," ") != 1L) goto _error;

			if (print_two(handle,(t >> 11) & 0x001f)) goto _error;
			if (Fwrite(handle,1L,":") != 1L) goto _error;
			if (print_two(handle,(t >> 5) & 0x003f)) goto _error;
			if (Fwrite(handle,1L,":") != 1L) goto _error;
			if (print_two(handle,(t & 0x001f) << 1)) goto _error;
			if (Fwrite(handle,2L,"\x0d\x0a") != 2L) goto _error;

			if (print_two(handle,(int)((dtimer->time >> 11) & 0x0000001f))) goto _error;
			if (Fwrite(handle,1L,":") != 1L) goto _error;
			if (print_two(handle,(int)((dtimer->time >> 5) & 0x0000003f))) goto _error;
			if (Fwrite(handle,2L,"  ") != 2L) goto _error;

			if (Fwrite(handle,strlen(dtimer->file),dtimer->file) != strlen(dtimer->file)) goto _error;

			if (dtimer->fcmd)
			{
				if (Fwrite(handle,2L," (") != 2L) goto _error;
				if (Fwrite(handle,strlen(dtimer->fcmd + 1L),dtimer->fcmd + 1L) != strlen(dtimer->fcmd + 1L)) goto _error;
				if (Fwrite(handle,1L,")") != 1L) goto _error;
			}
			
			Fwrite(handle,4L,"\x0d\x0a\x0d\x0a");
			_error:
			Fclose(handle);
		}
	}

	play_sound(sampletimer);

	if (!stricmp(dtimer->file, "shutdown"))
		init_shutdown();
	else
		start_app(0,SHW_PARALLEL,"timer", dtimer->file,dtimer->fcmd);
	
	mt_evnt_timer(500, (short*)&_GemParBlk.global[0]);
}


void event_loop(void)
{
	short    mx,my,
	       kstate,
	       key,
	       mkey,
	       clicks,
	       event,
	       bstate,
	       alid,
	       pipe[8];
	long   tcurr,
	       told = Tgettime() & 0x0000ffe0;
	TIMER *dtimer;


DEBUG
	Change_time(-1, -1);
DEBUG
	fix_width();
DEBUG
	alid = mt_appl_find("APPLINE ", (short*)&_GemParBlk.global[0]);
DEBUG
	load_app_icon();
DEBUG

DEBUG

	do
	{
		event = mt_evnt_multi(MU_MESAG|MU_KEYBD|MU_BUTTON|MU_TIMER,
		                   258,3,0,0,0,0,0,0,0,0,0,0,0,pipe,options.loop_time,
		                   &mx,&my,&bstate,&kstate,&key,&clicks, (short*)&_GemParBlk.global[0]);
		if (alid != appline)
			{
DEBUG
			appline = alid;
			
			if (appline>=0)
				SendAV(appline, APPLINE_MSG, ap_id, 0, -1, 0, 0, 0, 0);
			}

		if (event & MU_MESAG)
			{
DEBUG
			quit |= handle_message((int*)pipe);
			}

		if(event&MU_TIMER)
			{
			Change_time(mx, my);
DEBUG
			SendACCIcon();
DEBUG
			}


		if (event & MU_KEYBD)
			{
DEBUG
			mkey = MapKey(kstate,key);

			if (!handle_keyboard(mkey&0xff00, mkey&0x00ff))
				SendAV((find_avserver(1))?avserver:mt_menu_bar(NULL,-1, (short*)&_GemParBlk.global[0]), AV_SENDKEY, ap_id, 0, kstate, key, 0, 0, 0);
			}

		if (event & MU_BUTTON)
			{
DEBUG
			handle_button(mx,my,bstate&3, kstate, clicks);
			}

		if (timer)
		{
DEBUG
			tcurr = Tgettime() & 0x0000ffe0;

			if (tcurr != told)
			{
				if ((told>47104L) && (tcurr<2048L))
				{
					dtimer = timer;
					
					while (dtimer)
					{
						if ((dtimer->time > told) || (dtimer->time <= tcurr)) start_timer(dtimer);
						dtimer=dtimer->next;
					}
					
					told = tcurr;
				}
				else if (tcurr>told)
				{
					dtimer = timer;
					
					while (dtimer)
						{
						if ((dtimer->time > told) && (dtimer->time <= tcurr))
							start_timer(dtimer);
						dtimer = dtimer->next;
						}
					
					told = tcurr;
				}
			}
		}
	}
	while (!quit);

	{
	int r=mt_appl_find("MYCONF  ", (short*)&_GemParBlk.global[0]);
	if(r>0)
		SendAV(r, AP_TERM, ap_id, 0, 0, 0, 0, 0, 0);
	}

	if (appline >= 0)
		SendAV(appline, APPLINE_MSG, ap_id, 0, 0, 0, 0, 0, 0);

	if (gsapp >= 0)
		SendAV(gsapp, GS_QUIT, ap_id, 0, 0, 0, 0, 0, 0);
}


/* ************ */
/* NEW ROUTINES	*/

int fix_width(void)
	{
	int x_s1, x_s2, x_s3, x_t;
	x_s1 = bigbutton[SEPARATOR_1].ob_x;
	x_s2 = bigbutton[SEPARATOR_2].ob_x;
	x_s3 = bigbutton[SEPARATOR_3].ob_x;
	x_t = bigbutton[TIME_OBJECT].ob_x;
	if(bigbutton[START_BUTTON].ob_spec.free_string && !extrsc)
		free(bigbutton[START_BUTTON].ob_spec.free_string);
	if(!extrsc)
		{
		bigbutton[START_BUTTON].ob_spec.free_string = calloc(1,strlen(options.name)+1L);
		memset((char*)bigbutton[START_BUTTON].ob_spec.free_string, ' ', strlen(options.name)+1);
		strcpy((char*)bigbutton[START_BUTTON].ob_spec.free_string, options.name);
		bigbutton[START_BUTTON].ob_width = (int)(strlen((char*)bigbutton[START_BUTTON].ob_spec.free_string)+1)*8 + 2;
		}

 	if(extrsc && options.start_icon_text)
 		{
		free(bigbutton[START_BUTTON].ob_spec.iconblk->ib_ptext);
		bigbutton[START_BUTTON].ob_spec.iconblk->ib_ptext = calloc(1,strlen(options.name)+1L);
		memset((char*)bigbutton[START_BUTTON].ob_spec.iconblk->ib_ptext, ' ', strlen(options.name)+1);
		strcpy((char*)bigbutton[START_BUTTON].ob_spec.iconblk->ib_ptext, options.name);
 		}
DEBUG

	bigbutton[MYTASK_HIDE].ob_width = 8;		bigbutton[MYTASK_HIDE].ob_x = bigbutton->ob_width - bigbutton[MYTASK_HIDE].ob_width - 0;
	bigbutton[MYTASK_HIDE].ob_y = 0;				bigbutton[MYTASK_HIDE].ob_height = bigbutton->ob_height - 2;
	bigbutton[0].ob_width = desktop_w;
	bigbutton[START_BUTTON].ob_x = 4;
	bigbutton[TIME_OBJECT].ob_x = bigbutton->ob_width - bigbutton[TIME_OBJECT].ob_width  - bigbutton[MYTASK_HIDE].ob_width - 2;
	bigbutton[TIME_OBJECT].ob_y = 1;
	bigbutton[TIME_OBJECT].ob_height = 21;
	bigbutton[TIME_SEPARATOR].ob_x = bigbutton[TIME_OBJECT].ob_x - 4;
	bigbutton[TIME_SEPARATOR].ob_width = 1;
	bigbutton[SEPARATOR_1].ob_width = 1;
	bigbutton[SEPARATOR_2].ob_width = 1;
	bigbutton[SEPARATOR_3].ob_width = 1;
DEBUG

	bigbutton[SEPARATOR_1].ob_x = bigbutton[START_BUTTON].ob_x + bigbutton[START_BUTTON].ob_width + 8;

	bigbutton[SPECIAL_1].ob_width = 0;
	bigbutton[SPECIAL_1].ob_x = bigbutton[SEPARATOR_1].ob_x + bigbutton[SEPARATOR_1].ob_width + 2;

	usrdef_spec1.ub_code = draw_spec1;
	usrdef_spec1.ub_parm = 0L;
	bigbutton[SPECIAL_1].ob_type = G_USERDEF;
	bigbutton[SPECIAL_1].ob_spec.userblk = &usrdef_spec1;
DEBUG

	usrdef_separator.ub_code = draw_separator;
	usrdef_separator.ub_parm = 0L;
	bigbutton[SEPARATOR_1].ob_type = G_USERDEF;	bigbutton[SEPARATOR_1].ob_spec.userblk = &usrdef_separator;
	bigbutton[SEPARATOR_2].ob_type = G_USERDEF;	bigbutton[SEPARATOR_2].ob_spec.userblk = &usrdef_separator;
	bigbutton[SEPARATOR_3].ob_type = G_USERDEF;	bigbutton[SEPARATOR_3].ob_spec.userblk = &usrdef_separator;
	bigbutton[TIME_SEPARATOR].ob_type = G_USERDEF;	bigbutton[TIME_SEPARATOR].ob_spec.userblk = &usrdef_separator;
DEBUG


	usrdef_timer.ub_code = draw_timer;
	usrdef_timer.ub_parm = 0L;
	bigbutton[TIME_OBJECT].ob_type = G_USERDEF;
	bigbutton[TIME_OBJECT].ob_spec.userblk = &usrdef_timer;
DEBUG


	usrdef_hide.ub_code = draw_hide_mytask;
	usrdef_hide.ub_parm = 0L;
	bigbutton[MYTASK_HIDE].ob_type = G_USERDEF;
	bigbutton[MYTASK_HIDE].ob_spec.userblk = &usrdef_hide;
/*	bigbutton[MYTASK_HIDE].ob_x = bigbutton->ob_width - 4;
	bigbutton[MYTASK_HIDE].ob_y = 0;	*/
DEBUG

	bigbutton[SEPARATOR_2].ob_x = bigbutton[SEPARATOR_1].ob_x + bigbutton[SPECIAL_1].ob_width + 6;
	if(icons_sys.how_many==0)
		{
		bigbutton[SEPARATOR_3].ob_x = bigbutton[TIME_SEPARATOR].ob_x - 4;
		icons_sys.first_pos_x=0;
		icons_sys.last_pos_x=0;
		}
	if(icons_sys.first_pos_x!=0)
		bigbutton[SEPARATOR_3].ob_x = icons_sys.first_pos_x - bigbutton[SEPARATOR_3].ob_width - 4;
	else
		bigbutton[SEPARATOR_3].ob_x = bigbutton[TIME_SEPARATOR].ob_x - 4;
DEBUG

	if(icons_app.how_many==0 || icons_spec_app==NULL)
		{
		icons_app.first_pos_x=0;
		icons_app.last_pos_x=0;
		}
	if(icons_spec_app!=NULL)
		bigbutton[SEPARATOR_2].ob_x = icons_spec_app[icons_spec_app->no-1].pos_x;
DEBUG

	if(	x_s1 != bigbutton[SEPARATOR_1].ob_x || x_s2 != bigbutton[SEPARATOR_2].ob_x || x_s3 != bigbutton[SEPARATOR_3].ob_x || x_t != bigbutton[TIME_OBJECT].ob_x)
		return(1);
	else
		return(0);
	}



void change_button_widths(void)
	{
	int j=APPLICATION_1;
	int width, pos_x = bigbutton[j].ob_x, pos_y=bigbutton[START_BUTTON].ob_y;

	bigbutton->ob_height = MyTask.org_h;
	bigbutton->ob_y = MyTask.org_y;
	MyTask.lines = 0;

	mt_wind_set(MyTask.whandle,WF_CURRXYWH,MyTask.cur_x,MyTask.cur_y,MyTask.cur_w,MyTask.cur_h, (short*)&_GemParBlk.global[0]);

	while(j<(bigbutton->ob_tail+1))
		{
		if(bigbutton[j].ob_type&G_BOXTEXT)
			{
			bigbutton[j].ob_x = pos_x;
			bigbutton[j].ob_y = pos_y;
			bigbutton[j].ob_width = (int)strlen(bigbutton[j].ob_spec.tedinfo->te_ptext)*10;
			width = bigbutton[j].ob_width + 2;

			if((pos_x+width)>=bigbutton[SEPARATOR_3].ob_x)
				{																										/* Podwyzszenie MyTask	*/
				MyTask.lines++;
				bigbutton->ob_y -= (MyTask.lines*(bigbutton->ob_height+4));
				MyTask.new_y = bigbutton->ob_y;
				MyTask.new_h = bigbutton->ob_height + abs(MyTask.new_y - MyTask.org_x);
				bigbutton->ob_height = MyTask.new_h;
				pos_y += bigbutton[j].ob_height + 4;
				pos_x = bigbutton[SEPARATOR_2].ob_x + 10;
				bigbutton[j].ob_x = _applications_[find_app_by_button_no(j)].pos_x = pos_x;
				bigbutton[j].ob_y = pos_y;
				mt_wind_set(MyTask.whandle,WF_CURRXYWH,0,bigbutton->ob_y,bigbutton->ob_width,bigbutton->ob_height, (short*)&_GemParBlk.global[0]);
				}

			pos_x += width;
			}
		j++;
		}
	}



void trim_end(char *name)
	{
	while(name[strlen(name)-1]==' ')
		name[strlen(name)-1]=0;
	}

void trim_start(char *name)
	{
	while(name[0]==' ')
		memcpy(name, name+1, strlen(name));
	}


void open_calendar(void)
	{
	if (MyTask.wh_calendar<=0)
		{
		MyTask.wh_calendar = mt_wind_create(NAME|CLOSER|MOVER,desk.g_x,desk.g_y,desk.g_w,desk.g_h, (short*)&_GemParBlk.global[0]);
	
		if (MyTask.wh_calendar<=0)
			{
	   	mt_form_alert(1,message[MSG_OPEN_MAIN], (short*)&_GemParBlk.global[0]);
			return;
			}
		clip_startinf();

		usrdef_calendar_titel.ub_code = draw_calendar_titel;
		usrdef_calendar_titel.ub_parm = 0;
		calender[4].ob_type = G_USERDEF;
		calender[4].ob_spec.userblk = &usrdef_calendar_titel;

		usrdef_calendar.ub_code = draw_calendar;
		usrdef_calendar.ub_parm = 0;
		calender[5].ob_type = G_USERDEF;
		calender[5].ob_spec.userblk = &usrdef_calendar;

		mt_wind_calc(WC_BORDER, WINDOWSTYLE,(short)calender->ob_x,(short)calender->ob_y,(short)calender->ob_width,(short)calender->ob_height,&wx,&wy,&ww,&wh, (short*)&_GemParBlk.global[0]);

		_calendar.size_w = ww+8;
		_calendar.size_h = wh+22;
		mt_wind_open(MyTask.wh_calendar, wx, wy-40, _calendar.size_w, _calendar.size_h, (short*)&_GemParBlk.global[0]);
    mt_wind_set(MyTask.wh_calendar,WF_BEVENT,1,0,0,0, (short*)&_GemParBlk.global[0]);
    	{
    	short p[4]={0};
    	*(char **) (p) = _calendar.today;
  	  mt_wind_set(MyTask.wh_calendar,WF_NAME,p[0],p[1], p[2],p[3],(short*)&_GemParBlk.global[0]);
  	  }
		}
 	else
 		{
 		if (!untop)
 			mt_wind_set(MyTask.wh_calendar,WF_TOP,0,0,0,0, (short*)&_GemParBlk.global[0]);
	 	}
	}


void change_calendar(void)
	{
	int di, pdm, dm, dt, i, j;
	int il_dni[]={0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
	char czas_[100]={0}, text[100]={0};
	struct tm *czas=0L;
	unsigned long czas1=0L;

	time((time_t*)&czas1);
	czas = localtime((time_t*)&czas1);
	if(_calendar.change_month==1)
		{
		struct date _date, _date_in;
		getdate(&_date_in);
		_date.da_mon = _calendar.cal_m;
		_date.da_year = _calendar.cal_y;
		_date.da_day = 1;
		setdate(&_date);
		time((time_t*)&czas1);
		czas = localtime((time_t*)&czas1);
		setdate(&_date_in);
		}

	strftime(czas_, 100, "%m", czas);
	if(_calendar.act_m==0)
		_calendar.act_m = atoi(czas_);
	_calendar.cal_m = atoi(czas_);
	strftime(czas_, 100, "%Y", czas);
	_calendar.cal_y = atoi(czas_);

	strftime(czas_, 100, "%w %d %j", czas);
	dm = atoi(&czas_[3]);			dt = atoi(czas_);
	if(_calendar.act_d==0)
		_calendar.act_d = dm;
	if( _calendar.cal_y % 400 == 0 || _calendar.cal_y % 100 != 0 && _calendar.cal_y % 4 == 0 )			/* Czy rok przestepny?	*/
		il_dni[2] = 29 ;

/* Teraz policzymy, w ktory dzien tygodnia byl pierwszy dzien miesiaca	*/
	for(i=dt, di=dm; di>0; di--, i--)
		{
		if(i==0)
			i=7;
		}
	pdm = ++i;

	for(i=1; i<pdm; i++)
		strcat(text, "    ");

	trim_end(miesiac[_calendar.cal_m]);
	sprintf(rs_tedinfo_calender[0].te_ptext, "%s, %d", miesiac[_calendar.cal_m], _calendar.cal_y);
	calender[1].ob_width = (int)strlen(rs_tedinfo_calender[0].te_ptext)*9;
	memset(rs_tedinfo_calender[2].te_ptext, 0, strlen(rs_tedinfo_calender[2].te_ptext));
	memcpy(rs_tedinfo_calender[2].te_ptext, text, strlen(text));
	for(j=1, i=pdm; i<8; i++, j++)
		{
		sprintf(text, "%.3d ", j);
		strcat(rs_tedinfo_calender[2].te_ptext, text);
		rs_tedinfo_calender[2].te_ptext[strlen(rs_tedinfo_calender[2].te_ptext)-4] = ' ';
		}
	rs_tedinfo_calender[2].te_ptext[27] = 0;
	rs_tedinfo_calender[3].te_ptext[0] = 0;
	for(i=1; i<8; i++, j++)
		{
		sprintf(text, "%.3d ", j);
		strcat(rs_tedinfo_calender[3].te_ptext, text);
		rs_tedinfo_calender[3].te_ptext[strlen(rs_tedinfo_calender[3].te_ptext)-4] = ' ';
		}
	rs_tedinfo_calender[3].te_ptext[27] = 0;
	rs_tedinfo_calender[4].te_ptext[0] = 0;
	for(i=1; i<8; i++, j++)
		{
		sprintf(text, "%.3d ", j);
		strcat(rs_tedinfo_calender[4].te_ptext, text);
		rs_tedinfo_calender[4].te_ptext[strlen(rs_tedinfo_calender[4].te_ptext)-4] = ' ';
		}
	rs_tedinfo_calender[4].te_ptext[27] = 0;
	rs_tedinfo_calender[5].te_ptext[0] = 0;
	for(i=1; i<8 && j<il_dni[_calendar.cal_m]; i++, j++)
		{
		sprintf(text, "%.3d ", j);
		strcat(rs_tedinfo_calender[5].te_ptext, text);
		rs_tedinfo_calender[5].te_ptext[strlen(rs_tedinfo_calender[5].te_ptext)-4] = ' ';
		}
	if(i<8)
		{
		memset(text,' ', 28);
		memcpy(text, rs_tedinfo_calender[5].te_ptext, strlen(rs_tedinfo_calender[5].te_ptext)-1);
		memcpy(rs_tedinfo_calender[5].te_ptext, text, strlen(text));
		}
	rs_tedinfo_calender[5].te_ptext[27] = 0;
	rs_tedinfo_calender[6].te_ptext[0] = 0;
	for(i=1; i<8 && j<(il_dni[_calendar.cal_m]+1); i++, j++)
		{
		sprintf(text, "%.3d ", j);
		strcat(rs_tedinfo_calender[6].te_ptext, text);
		rs_tedinfo_calender[6].te_ptext[strlen(rs_tedinfo_calender[6].te_ptext)-4] = ' ';
		}
	if(i<8)
		{
		memset(text, ' ', 28);
		memcpy(text, rs_tedinfo_calender[6].te_ptext, strlen(rs_tedinfo_calender[6].te_ptext)-1);
		memcpy(rs_tedinfo_calender[6].te_ptext, text, strlen(text));
		}
	rs_tedinfo_calender[6].te_ptext[27] = 0;
	}



int mouse_over_app(int mx, int my)
	{
	int app_x1, app_x2;

	app_x1 = bigbutton->ob_x + bigbutton[SEPARATOR_2].ob_x;
	app_x2 = bigbutton->ob_x + bigbutton[SEPARATOR_3].ob_x;

	if(my<bigbutton->ob_y)
		return(0);
	if(my>(bigbutton->ob_y + bigbutton->ob_height))
		return(0);
	if(mx>=app_x1 && mx<=app_x2)
		return(1);
	else
		return(0);
	}



void Add_app_to_not_show(int app, char *name)
	{
	if(DoNotShow==NULL)
		{
		DoNotShow = calloc(1,sizeof(struct _donotshow));
		DoNotShow->how_many = 1;
		if(app!=-1)
			{
			DoNotShow->ap_id = _applications_[app].id;
			sprintf(DoNotShow->name, "%-8s", _applications_[app].name);
			}
		else
			sprintf(DoNotShow->name, "%-8s", name);
		}
	else
		{
		struct _donotshow *tmp;
		int n;
		n = ++DoNotShow->how_many;
		tmp = calloc(1,n*sizeof(struct _donotshow));
		memcpy(tmp, DoNotShow, (n-1)*sizeof(struct _donotshow));
		if(app!=-1)
			{
			tmp[n-1].ap_id = _applications_[app].id;
			sprintf(tmp[n-1].name, "%-8s", _applications_[app].name);
			}
		else
			sprintf(tmp[n-1].name, "%-8s", name);
		if(DoNotShow)
			free(DoNotShow);
		DoNotShow = tmp;
		}
	}


void Add_app_font(int app, int font_id, int font_col, int font_eff, int font_height)
	{
	char name[50]={0};
	if(FontsID==NULL)
		{
		FontsID = calloc(1,sizeof(struct _font_id_app));
		FontsID->how_many = 1;
		FontsID->ap_id = _applications_[app].id;
		FontsID->id = font_id;
		FontsID->color = font_col;
		FontsID->effect = font_eff;
		FontsID->height = font_height;
		strcpy(name, _applications_[app].name);
		trim_end(name);
		sprintf(FontsID->name, "%s", name);
		memset(name, 0, 50);
		}
	else
		{
		struct _font_id_app *tmp;
		int n=-1, i;
		for(i=0; i<FontsID->how_many; i++)
			{
			if(strcmp(FontsID[i].name, _applications_[app].name)==0)
				{
				FontsID[i].id = font_id;
				FontsID[i].color = font_col;
				FontsID[i].effect = font_eff;
				FontsID[i].height = font_height;
				n = -2;
				break;
				}
			}
		if(n==-1)
			{
			n = ++FontsID->how_many;
			tmp = calloc(1,n*sizeof(struct _font_id_app));
			memcpy(tmp, FontsID, (n-1)*sizeof(struct _font_id_app));
			tmp[n-1].ap_id = _applications_[app].id;
			strcpy(name, _applications_[app].name);
			trim_end(name);
			sprintf(tmp[n-1].name, "%s", name);
			memset(name, 0, 50);
			tmp[n-1].id = font_id;
			tmp[n-1].color = font_col;
			tmp[n-1].effect = font_eff;
			tmp[n-1].height = font_height;
			free(FontsID);
			FontsID = tmp;
			}
		}
	}

/*
void    _aes(int dummy, long parm);

int appl_control(int ap_cid, int ap_cwhat, void *ap_cout)
	{
	_GemParBlk.intin[0]  = ap_cid;
	_GemParBlk.intin[1]  = ap_cwhat;
	_GemParBlk.addrin[0] = ap_cout;
	_aes(0, 0x81020101UL);
	return _GemParBlk.intout[0];
	}
*/

OBJECT *build_window_popup(int app_no)
	{
	OBJECT *wind_pop;
	int no_window = _applications_[app_no].no_windows;
	int c,lmax=0;

	if(no_window==0)
		return(NULL);

	wind_pop = (OBJECT *)calloc(1,sizeof(OBJECT)*(long)(no_window+1));
	memset(wind_pop, 0, sizeof(OBJECT)*(long)(no_window+1));

	for (c=0;c<no_window;c++)
		lmax = (int)max(lmax, strlen(_applications_[app_no].window_name[c]));

	if (wind_pop!=NULL)
		{
		lmax += 4;
			
		wind_pop[ROOT].ob_next   = -1;
		wind_pop[ROOT].ob_head   =  1;
		wind_pop[ROOT].ob_tail   = no_window;
		wind_pop[ROOT].ob_type   = G_BOX;
		wind_pop[ROOT].ob_flags  = FL3DBAK;
		wind_pop[ROOT].ob_state  = OS_NORMAL;
		wind_pop[ROOT].ob_spec.index = 0x00ff1100L;
		wind_pop[ROOT].ob_x      =  0;
		wind_pop[ROOT].ob_y      =  0;
		wind_pop[ROOT].ob_width  = (int)lmax-1;
		wind_pop[ROOT].ob_height = 0;

		for (c=0;c<no_window;c++)
			{
			wind_pop[c+1].ob_spec.free_string = (char *)calloc(1,lmax+2L);
			memset(wind_pop[c+1].ob_spec.free_string, 0, lmax+1);
			if (wind_pop[c+1].ob_spec.free_string)
				{
				strncpy(wind_pop[c+1].ob_spec.free_string, "                          ", lmax);
				strncpy(&wind_pop[c+1].ob_spec.free_string[1], _applications_[app_no].window_name[c], min(lmax-1, strlen(_applications_[app_no].window_name[c])));
				}
			wind_pop->ob_height++;
			wind_pop[c+1].ob_next   = c+2;
			wind_pop[c+1].ob_head   = -1;
			wind_pop[c+1].ob_tail   = -1;
			wind_pop[c+1].ob_type   = G_STRING;
			wind_pop[c+1].ob_flags  = FL3DBAK|OF_SELECTABLE;
			wind_pop[c+1].ob_state  = OS_NORMAL;
			wind_pop[c+1].ob_x      =  0;
			wind_pop[c+1].ob_y      = c;
			wind_pop[c+1].ob_width  = (int)lmax-1;
			wind_pop[c+1].ob_height =  1;
			}
				
		wind_pop[c].ob_next = 0;
		wind_pop[c].ob_flags |= OF_LASTOB;

		fix_tree(wind_pop);
		}
	return(wind_pop);
	}



signed int info_app(int obj, int spezial, int button, int clicks, int mx, int my)
	{
	MENU menu,msel,menu_window;
	OBJECT *wind_pop=NULL;
	int  ret,mnx = mx, app_no, app_id, pid, i;
	static int prev_width;
	char hide=0, pop=0;

	if (mnx+apppopup[ROOT].ob_width > desk.g_x+desk.g_w)
		mnx = desk.g_x+desk.g_w-apppopup[ROOT].ob_width;

	menu.mn_tree     = apppopup;
	menu.mn_menu     = ROOT;
	menu.mn_item     = 1;
	menu.mn_scroll   = 0;
	menu.mn_keystate = 0;

	if(obj<=0)
		obj = objc_find_mytask(mx,my);

	if((app_no = find_app_by_button(obj, mx))<0)
		return(-1);
	app_id = _applications_[app_no].id;
	pid = _applications_[app_no].pid;

	if(_applications_[app_no].show_button==0)
		return(-1);

	for(i=0; i<(apppopup->ob_tail+1); i++)
		apppopup[i].ob_width = (prev_width!=0 ? prev_width : apppopup[i].ob_width);
	prev_width = apppopup->ob_width;


	/* Wpisuje wlasciwe wartosci do popup	*/
	app_popup_vorbereiten(apppopup, app_no);

	if(system_==SYS_MINT)
		apppopup_mint[3].ob_spec.free_string[strlen(apppopup_mint[3].ob_spec.free_string)-1] = 3;

	wind_pop = build_window_popup(app_no);
	if(wind_pop!=NULL)
		{
		int ii;
		menu_window.mn_tree     = wind_pop;
		menu_window.mn_menu     = ROOT;
		menu_window.mn_item     = 1;
		menu_window.mn_scroll   = 0;
		menu_window.mn_keystate = 0;
		for(ii=0; ii<MAX_BENUTZER_POPUP; ii++)
			{
			if(popup_app_menu[ii].aktion==-3)
				{
				apppopup[ii+1].ob_width -= 1;
				mt_menu_attach(ME_ATTACH, menu.mn_tree, ii+1, &menu_window, (short*)&_GemParBlk.global[0]);
				}
			}
		}

	findstic();

	if(spezial&K_ALT)
		spezial = 2;
	else if(spezial&K_RSHIFT || spezial&K_LSHIFT)
		spezial = 1;
	else if(spezial&K_CTRL)
		spezial = 3;
	else spezial = 0;

	if(button==1)			/* Prawy przycisk	*/
		button=2;
	else
		button=1;

	if(clicks==1)
		{
		if(options.klicks[spezial][button]!=DEF_BUTT_NIX)
			msel.mn_item = options.klicks[spezial][button];
		}
	else if(clicks==2)
		{
		if(options.doppel_klicks[spezial][button]!=DEF_BUTT_NIX)
			msel.mn_item = options.doppel_klicks[spezial][button];
		}
	
	switch(msel.mn_item)
		{
		case DEF_BUTT_SHOW:			/* Show					*/
			if(system_==SYS_MAGIC)
				msel.mn_item = DEF_BUTT_SHOW;
			else
				msel.mn_item = DEF_BUTT_SHOW;
			ret = 1;
			break;
		case DEF_BUTT_MENU:			/* Kontextmenue	*/
			bigbutton[obj].ob_state |= OS_SELECTED;
			redraw(ROOT, bigbutton->ob_x+bigbutton[obj].ob_x, bigbutton->ob_y+bigbutton[obj].ob_y,	bigbutton[obj].ob_width, bigbutton[obj].ob_height, "DEF_BUTT_MENU");

			ret = mt_menu_popup(&menu,mnx,my-menu.mn_tree->ob_height,&msel, (short*)&_GemParBlk.global[0]);
			if(msel.mn_tree == menu.mn_tree)
				msel.mn_item = popup_app_menu[msel.mn_item-1].aktion;

			bigbutton[obj].ob_state &= ~OS_SELECTED;
			redraw(ROOT, bigbutton->ob_x+bigbutton[obj].ob_x, bigbutton->ob_y+bigbutton[obj].ob_y, bigbutton[obj].ob_width+1, bigbutton[obj].ob_height+1, "DEF_BUTT_MENU2");
			pop=1;
			break;
		case DEF_BUTT_KILL:			/* Terminate		*/
			if(system_==SYS_MAGIC)
				msel.mn_item = DEF_BUTT_TERMINATE;
			else
				msel.mn_item = DEF_BUTT_TERMINATE;
			ret = 1;
			break;
		case DEF_BUTT_ICON:			/* Iconify			*/
			msel.mn_tree = wind_pop;
			msel.mn_keystate |= 8;
			if(_applications_[app_no].last_choosen_window<0)
				_applications_[app_no].last_choosen_window = _applications_[app_no].no_windows - 1;
			msel.mn_item = (_applications_[app_no].last_choosen_window--);
			ret = 1;
			break;
		case DEF_BUTT_ICON_ALL:			/* Iconify all	*/
			msel.mn_tree = wind_pop;
			msel.mn_keystate |= (8|16);
			if(_applications_[app_no].last_choosen_window<0)
				_applications_[app_no].last_choosen_window = _applications_[app_no].no_windows - 1;
			msel.mn_item = (_applications_[app_no].last_choosen_window--);
			ret = 1;
			break;
		default:
			break;
		}

	mt_menu_attach(ME_REMOVE,menu.mn_tree,16,&menu_window, (short*)&_GemParBlk.global[0]);

	if(button==1 && _applications_[app_no].notify==1)
		{
		/* Wyslanie komendy "Notified"	*/
		}

	if(system_==SYS_MINT)
		apppopup_mint[3].ob_spec.free_string[strlen(apppopup_mint[3].ob_spec.free_string)-1] = ' ';

	if(msel.mn_tree == wind_pop)
		{
		if(!(msel.mn_keystate&8))
			mt_wind_set(_applications_[app_no].window_handlers[msel.mn_item-1], WF_TOP, 0, 0,0,0, (short*)&_GemParBlk.global[0]);
		else			/* MOZNA SPROBOWAC TEZ PRZEZ GEMSCRIPT	*/
			{
			if(_applications_[app_no].gs&GS_SUPPORT && _applications_[app_no].gs&GS_ICONIFY)
				{
				char *command="WinIconify";
				int answ[2];

				answ[0] = (int)(((long)command >> 16) & 0x0000ffffL);
				answ[1]=(int)((long)command & 0x0000ffffL);
				SendAV(app_id, GS_COMMAND, ap_id, 0, answ[0], answ[1], 0, 2, _applications_[app_no].gs_id);
				}
			else
				{
				if(msel.mn_keystate&16)
					SendAV(app_id, WM_ALLICONIFY, ap_id, 0, _applications_[app_no].window_handlers[msel.mn_item], -1, -1, -1, -1);
				else
					SendAV(app_id, WM_ICONIFY, ap_id, 0, _applications_[app_no].window_handlers[msel.mn_item], -1, -1, -1, -1);
				}
			}
		}

	if (ret && msel.mn_tree!=wind_pop)
		{
		if(system_ == SYS_MAGIC)
			{
			switch(msel.mn_item)
				{
				case DEF_BUTT_TERMINATE:				/* Terminate	*/
					SendAV(screen_manager_id, SM_M_SPECIAL, ap_id, 0, 0, 'MA', 'GX', SMC_TERMINATE, app_id);
					break;

				case DEF_BUTT_QUIT:				/* Quit				*/
					SendAV(app_id, AP_TERM, ap_id, 0, 0, 0, 0, 0, 0);
					find_applications();
DEBUG
					break;

				case DEF_BUTT_HIDE_OTHER:				/* Hide	all			*/
					SendAV(screen_manager_id, SM_M_SPECIAL, ap_id, 0, 0, 'MA', 'GX', SMC_HIDEOTHERS, app_id);
					break;

				case DEF_BUTT_HIDE:				/* Hide				*/
					SendAV(screen_manager_id, SM_M_SPECIAL, ap_id, 0, 0, 'MA', 'GX', SMC_SWITCH, app_id);
					SendAV(screen_manager_id, SM_M_SPECIAL, ap_id, 0, 0, 'MA', 'GX', SMC_HIDEACT, _applications_[app_no].id);
					_applications_[app_no].check = 3;				/* Versteckt	*/
					break;
			
				case DEF_BUTT_SHOW_ALL:				/* Show all				*/
					SendAV(screen_manager_id, SM_M_SPECIAL, ap_id, 0, 0, 'MA', 'GX', SMC_UNHIDEALL, app_id);
					break;

				case DEF_BUTT_SHOW:				/* Show				*/
				case -3:
					if(_applications_[app_no].type==APP_ACCESSORY)
						{
						int no;
						SendAV(app_id, VA_START, ap_id, 0, 0, 0, 0, 0, 0);
						no = _applications_[MyTask.prev_on_top].button_no;
						_applications_[MyTask.prev_on_top].active = 0;
						redraw(0, bigbutton->ob_x+bigbutton[no].ob_x, bigbutton->ob_y+bigbutton[no].ob_y, bigbutton[no].ob_width, bigbutton[no].ob_height, "DEF_BUTT_MENU");
						_applications_[app_no].active = 1;
						no = _applications_[app_no].button_no;
						MyTask.prev_on_top = MyTask.prev_app_on_top = app_id;
						redraw(0, bigbutton->ob_x+bigbutton[no].ob_x, bigbutton->ob_y+bigbutton[no].ob_y, bigbutton[no].ob_width, bigbutton[no].ob_height, "DEF_BUTT_MENU2");
						}
					else
						{
						int no;
						SendAV(screen_manager_id, SM_M_SPECIAL, ap_id, 0, 0, 'MA', 'GX', SMC_SWITCH, app_id);
						if(_applications_[app_no].last_choosen_window<0 || _applications_[app_no].last_choosen_window>_applications_[app_no].no_windows)
							_applications_[app_no].last_choosen_window = _applications_[app_no].no_windows - 1;
						if(_applications_[app_no].last_choosen_window<0)
							_applications_[app_no].last_choosen_window = 0;
						mt_wind_set(_applications_[app_no].window_handlers[_applications_[app_no].last_choosen_window--], WF_TOP, 0, 0,0,0, (short*)&_GemParBlk.global[0]);
						no = _applications_[MyTask.prev_on_top].button_no;
						_applications_[MyTask.prev_on_top].active = 0;
						redraw(0, bigbutton->ob_x+bigbutton[no].ob_x, bigbutton->ob_y+bigbutton[no].ob_y, bigbutton[no].ob_width, bigbutton[no].ob_height, "DEF_BUTT_MENU3");
						_applications_[app_no].active = 1;
						no = _applications_[app_no].button_no;
						MyTask.prev_on_top = MyTask.prev_app_on_top = app_id;
						redraw(0, bigbutton->ob_x+bigbutton[no].ob_x, bigbutton->ob_y+bigbutton[no].ob_y, bigbutton[no].ob_width, bigbutton[no].ob_height, "DEF_BUTT_MENU4");
						}
					break;

				case DEF_BUTT_FREEZY:				/* Freezy				*/
					SendAV(screen_manager_id, SM_M_SPECIAL, ap_id, 0, 0, 'MA', 'GX', SMC_FREEZE, app_id);
					if(_applications_[app_no].check != 2)
						{
						int width=0, i, pos_y=bigbutton[_applications_[app_no].button_no].ob_y, no;
						_applications_[app_no].check = 2;
						no = _applications_[MyTask.prev_on_top].button_no;
						build_applications(-1);
						for(i=app_no+0; i<APPLICATION_LAST; i++)
							{
							if(bigbutton[i].ob_y == pos_y)
								width += (bigbutton[i].ob_width+2);
							}
						redraw(0, _applications_[app_no].pos_x, bigbutton->ob_y+bigbutton[no].ob_y, width, bigbutton[no].ob_height, "DEF_BUTT_FREEZY");
						}
					break;

				case DEF_BUTT_UNFREEZY:				/* Unfreezy				*/
					SendAV(screen_manager_id, SM_M_SPECIAL, ap_id, 0, 0, 'MA', 'GX', SMC_UNFREEZE, app_id);
					if(_applications_[app_no].check==2)			/* Uwaga tutaj trzeba ewentualnie, ze wzgledu na zmiane szerokosci danego przycisku, przerysowac wszystkie nastepne przyciski!	*/
						{
						int width=0, i, pos_y=bigbutton[_applications_[app_no].button_no].ob_y;
						int no;
						for(i=app_no+0; i<APPLICATION_LAST; i++)
							{
							if(bigbutton[i].ob_y == pos_y)
								width += (bigbutton[i].ob_width+2);
							}
						build_applications(-1);
						no = _applications_[MyTask.prev_on_top].button_no;
						_applications_[app_no].check = 0;
							{
							SendAV(screen_manager_id, SM_M_SPECIAL, ap_id, 0, 0, 'MA', 'GX', SMC_SWITCH, app_id);
							if(_applications_[app_no].last_choosen_window<0)
								_applications_[app_no].last_choosen_window = _applications_[app_no].no_windows - 1;
							mt_wind_set(_applications_[app_no].window_handlers[_applications_[app_no].last_choosen_window--], WF_TOP, 0, 0,0,0, (short*)&_GemParBlk.global[0]);
							_applications_[MyTask.prev_on_top].active = 0;
							redraw(0, bigbutton->ob_x+bigbutton[no].ob_x, bigbutton->ob_y+bigbutton[no].ob_y, bigbutton[no].ob_width, bigbutton[no].ob_height, NULL);
							_applications_[app_no].active = 1;
							no = _applications_[app_no].button_no;
							MyTask.prev_on_top = MyTask.prev_app_on_top = app_id;
							}
						redraw(0, _applications_[app_no].pos_x, bigbutton->ob_y+bigbutton[no].ob_y, width, bigbutton[no].ob_height, NULL);
						}
					break;

				case DEF_BUTT_VER_VOR:				/* Do not show temporarly	*/
					_applications_[app_no].show_button = 0;
					
					build_applications(-1);
					redraw(ROOT, bigbutton->ob_x+bigbutton[obj].ob_x-2, bigbutton->ob_y+bigbutton[obj].ob_y,	bigbutton->ob_x+bigbutton[last_added_button].ob_x, bigbutton[obj].ob_height+2, "Do not show temp.");
					hide = 1;
					break;

				case DEF_BUTT_VER_DAU:				/* Do not show permanently		*/
					_applications_[app_no].show_button = 0;
					Add_app_to_not_show(app_no, NULL);
					build_applications(-1);
					hide = 1;
					break;
				}
			}
		else				/* MiNT	*/
			{
			switch(msel.mn_item)
				{
				case 3:				/* Priority	*/
					if(pid!=-1)
						{
						printf("Priority = %d\n", (int)Pgetpriority(pid));
						Psetpriority(pid, 10);
						}
					break;

				case DEF_BUTT_TERMINATE:				/* Kill				*/
					if(pid!=-1)
						Pkill(pid, SIGKILL);
					find_applications();
DEBUG
					break;

				case DEF_BUTT_QUIT:				/* Quit				*/
					if(pid!=-1)
						Pkill(pid, SIGTERM);
					find_applications();
DEBUG
					break;

				case DEF_BUTT_TOP:				/* Top						*/
					mt_appl_control(app_id, 12, NULL, (short*)&_GemParBlk.global[0]);			/* N.AES	*/
					break;

				case DEF_BUTT_HIDE_OTHER:				/* Hide	other			*/
					mt_appl_control(pid, 13, NULL, (short*)&_GemParBlk.global[0]);			/* N.AES	*/
					break;
			
				case DEF_BUTT_HIDE:				/* Hide						*/
					mt_appl_control(pid, 10, NULL, (short*)&_GemParBlk.global[0]);			/* N.AES	*/
					break;

				case DEF_BUTT_SHOW:				/* Show				*/
					mt_appl_control(pid, 11, NULL, (short*)&_GemParBlk.global[0]);			/* N.AES	*/
					break;

				case DEF_BUTT_VER_VOR:				/* Do not show temporarly	*/
					_applications_[app_no].show_button = 0;
					build_applications(-1);
					memset(&bigbutton[_applications_[app_no].button_no], 0, sizeof(OBJECT));
					hide = 1;
					break;

				case DEF_BUTT_VER_DAU:				/* Do not show permanently		*/
					_applications_[app_no].show_button = 0;
					Add_app_to_not_show(app_no, NULL);
					build_applications(-1);
					memset(&bigbutton[_applications_[app_no].button_no], 0, sizeof(OBJECT));
					hide = 1;
					break;
				}
			}
		}
	if(wind_pop!=NULL)
		{
		int i;
		for(i=1; i<(wind_pop->ob_tail+1); i++)
			free(wind_pop[i].ob_spec.free_string);
		free(wind_pop);
		}

	if(hide==1)				/* Jakis przycisk jest kasowany i trzeba przerysowac wszystkie na prawo od danego przycisku	*/
		{
		int ii, wi=bigbutton[obj].ob_width;
		for(ii=obj; ii<APPLICATION_LAST; ii++)
			{
			if(bigbutton[obj].ob_y == bigbutton[ii].ob_y)
				wi += (bigbutton[ii].ob_width+2);
			}
		redraw(ROOT, bigbutton->ob_x+bigbutton[obj].ob_x, bigbutton->ob_y+bigbutton[obj].ob_y,	wi, bigbutton[obj].ob_height+1, "info app");
		}
	return(1);
	}



void objc_redraw(int obj)
	{
	if(hidden==0 && obj!=ROOT)
		mt_objc_draw(bigbutton, ROOT, MAX_DEPTH,	bigbutton[obj].ob_x, bigbutton[obj].ob_y,	bigbutton[obj].ob_width, bigbutton[obj].ob_height, (short*)&_GemParBlk.global[0]);
	else if(hidden==0 && obj==ROOT)
		mt_objc_draw(bigbutton,ROOT, MAX_DEPTH,	bigbutton->ob_x, bigbutton->ob_y,	bigbutton[SEPARATOR_3].ob_x, bigbutton->ob_height, (short*)&_GemParBlk.global[0]);
	}

void hide_mytask_KDE(void)
	{
	int i;
	for(i=1; i<SYS_ICON_LAST; i++)
		bigbutton[i].ob_flags |= OF_HIDETREE;
	bigbutton[MYTASK_HIDE].ob_flags &= ~OF_HIDETREE;
	MyTask.prev_x = bigbutton->ob_x;
	MyTask.prev_y = bigbutton->ob_y;
	MyTask.prev_w = bigbutton->ob_width;
	MyTask.prev_h = bigbutton->ob_height;
	bigbutton->ob_x = bigbutton->ob_width - 10;
	bigbutton->ob_width = bigbutton[MYTASK_HIDE].ob_width + 4;
	bigbutton[MYTASK_HIDE].ob_x = 0;
	}

void unhide_mytask_KDE(void)
	{
	int i;
	for(i=1; i<SYS_ICON_LAST; i++)
		bigbutton[i].ob_flags &= ~OF_HIDETREE;
	bigbutton->ob_x = MyTask.prev_x;
	bigbutton->ob_y = MyTask.prev_y;
	bigbutton->ob_width = MyTask.prev_w;
	bigbutton->ob_height = MyTask.prev_h;
	bigbutton[MYTASK_HIDE].ob_x = bigbutton->ob_width - bigbutton[MYTASK_HIDE].ob_width;
	}




void hide_mytask(void)
	{
	mt_wind_close(MyTask.whandle, (short*)&_GemParBlk.global[0]);
	hidden = 1;
	}

void show_mytask(void)
	{
	mt_wind_open(MyTask.whandle,wx,wy, ww,wh, (short*)&_GemParBlk.global[0]);
	hidden = 0;
	}
