/* EC_GEM */
/* Funktionen zur vereinfachten GEM-Steuerung */

#if !defined( __EC_GEM )
#define __EC_GEM


#if     !defined( __STDLIB )
#include <stdlib.h>
#endif

#if     !defined( __STDIO )
#include <stdio.h>
#endif

#if     !defined( __STRING )
#include <string.h>
#endif

#if 		!defined( __TOS )
#include <tos.h>
#endif

#if     !defined( __AES__ )
#include <aes.h>
#endif

#if     !defined( __VDI__ )
#include <vdi.h>
#endif

#if			!defined( __VT52 )
#include <screen.h>
#endif

#if			!defined( __MATH )
#include <math.h>
#endif

#if			!defined( __EXT )
#include <ext.h>
#endif

#if			!defined(__LTMFLIB__)
#include <ltmf_lib.h>
#endif

#include <magx.h>

/*  */
/* Standard-Definitionen */
/*  */

/* AV-Protokoll */
#define ACC_ID		0x400
#define ACC_OPEN	0x401
#define ACC_CLOSE	0x402
#define ACC_ACC		0x403
#define AV_PROTOKOLL		0x4700
#define VA_PROTOSTATUS		0x4701
#define AV_GETSTATUS		0x4703
#define AV_STATUS			0x4704
#define VA_SETSTATUS		0x4705
#define	AV_SENDKEY			0x4710
#define VA_START			0x4711
#define AV_ASKFILEFONT		0x4712
#define VA_FILEFONT			0x4713
#define AV_ASKCONFONT		0x4714
#define VA_CONFONT			0x4715
#define AV_ASKOBJECT	0x4716
#define VA_OBJECT		0x4717
#define AV_OPENCONSOLE	0x4718
#define VA_CONSOLEOPEN	0x4719
#define AV_OPENWIND		0x4720
#define AV_XWIND 0x4740
#define VA_XOPEN 0x4741
#define VA_WINDOPEN		0x4721
#define AV_STARTPROG	0x4722
#define VA_PROGSTART	0x4723
#define AV_ACCWINDOPEN	0x4724
#define VA_DRAGACCWIND	0x4725
#define AV_ACCWINDCLOSED	0x4726
#define AV_COPY_DRAGGED		0x4728
#define VA_COPY_COMPLETE	0x4729
#define AV_PATH_UPDATE		0x4730
#define AV_WHAT_IZIT		0x4732
#define	VA_OB_UNKNOWN	0		
#define VA_OB_TRASHCAN  1
#define VA_OB_SHREDDER  2
#define VA_OB_CLIPBOARD 3
#define VA_OB_FILE      4
#define VA_OB_FOLDER	5
#define VA_OB_DRIVE		6
#define VA_OB_WINDOW    7
#define VA_THAT_IZIT		0x4733
#define AV_DRAG_ON_WINDOW	0x4734
#define VA_DRAG_COMPLETE	0x4735
#define AV_EXIT				0x4736
#define AV_STARTED 0x4738

/* MagiX */
#define SHW_IMMED 0
#define SHW_CHAIN 1
#define SHW_DOS 2
#define SHW_PARALLEL 100
#define SHW_SINGLE 101

/*  */
/* Standard-Strukturen */
/*  */

/* AES-Zusatz */

typedef struct
{
	TEDINFO	ti;
	long		magic;	/* Muû 'XTED' sein */
	char		*te_ptext;	/* Pointer auf String */
	int			ascii_low;	/* Nur Zeichen mit ascii > low kînnen eingegeben werden */
	char		secret;		/* Eingabezeichen statt Original oder 0 */
	int			maxlen;	/* Maximale LÑnge (String muû eins lÑnger sein, wg. 0-Zeichen) */
	int			offset;	/* Aktueller Offset im Editobjekt */
}XTEDINFO;

#define xted(a, b) (*((XTEDINFO**)&(a[b].ob_spec.tedinfo)))

/* Tedinfo-Farbe */
typedef struct
{
	frame_col : 4;
	text_col	: 4;
	text_type : 1;
	plane_pat : 3;
	plane_col	:	4;
}TEDINFO_COL;
/* Das gleiche in grÅn */
typedef struct
{
	frame_color	: 4;
	text_color	:	4;
	opaque			:	1;
	pattern			:	3;
	pat_color		:	4;
}TED_COLOR;


typedef struct
{
	long id, val;
}COOKIE;

typedef struct
{
	char	xb_magic[4];										/* Kennung */
	char	xb_id[4];												/* ID des PRGs */
	long	xb_oldvec;											/* Alter Vektor */
}XBRA;

typedef struct
{
   long		id;      	/* ID des Schoners */
   int	  version; 	/* Version des XSSI-Protokolls (0x100) */
   int  	save_stat; /* Mitteilung, ob gerade geschont wird. 0=nein */
   int	  prg_stat;  /* Status des Programms:
                              0= normal schonen,
                              1= niemals schonen bzw sofort aufhîren,
                             -1= sofort schonen.                          */
} INFOXSSI;

typedef struct
{
	void	(*gunknown)(int *pbuf); /* Unbekannte Messages */
	void	(*menu)(int title, int ob);				/* MN_SELECTED */
}AP_INFO;

/*  */
/* Fenster-Strukturen */
/*  */

typedef struct
{
	char	**text;		/* Zeiger auf Stringpointerfeld */
	int		lines;		/* Anzahl der Zeilen */
	int		longest;	/* Anzahl der Zeichen der lÑngsten Zeile */

	int		fontid;		/* Id des Zeichensatzes */
	int		hchar;		/* Zeichenhîhe */
	int		wchar;		/* Zeichenbreite */
	int		col;			/* Zeichenfarbe */
}TINFO;

typedef struct
{
	OBJECT	*tree;		/* Zeiger auf Objecttree */
	int			support;	/* Zu unterstÅtzende Erweiterungen */
	
	int			winok;		/* 1=Dialog ist im Fenster */
	
	int			xdif;     /* Differenz zw. Object x/y und Winwork x/y */
	int			ydif;
	
  int     dedit;  /* Objectnummer des editierbaren Default-Objects */
	int			curon;	/* 1=Cursor ist an 0=aus */
	int			cpos;		/* Cursorposition im Editfeld */
	
	int			ostart; /* Objectnummer des ersten zu zeichnenden */
	int			odepth; /* Zeichentiefe (fÅr Redraw)*/
	
	int			osmax;	/* Niedrigstes Object (i.d.R. 0) */
	int			odmax;	/* Maximale Tiefe (fÅr gesamt-Draw)*/
	
  void    (*dservice)(int object);/* Routine, die Auswertung Åbernimmt */
  
  /* Folgende Routinen werden automatisch von w_dinit auf
  		NULL gesetzt und mÅssen bei Bedarf HINTERHER
  		eingetragen werden! */
  /* Routine, die Auswertung Åbernimmt, wie dservice aber
  		optional mit *win des Parentfensters. Ist dieser Pointer
  		nicht NULL, wird dservice garnicht aufgerufen! */
  void    (*dwservice)(struct _WINDOW *win, int object);

  	/* zusÑtzliche Routine fÅr _vor_ Mausklick */
  void		(*dbutton)(int mx, int my);
  	/* zusÑtzliche Routine fÅr _vor_ Tastatur */
  void		(*dkeybd)(int key, int swt);
  	/* zusÑtzliche Routine fÅr _nach_ Mausklick */
  void		(*dabutton)(int mx, int my);
  	/* zusÑtzliche Routine fÅr _nach_ Tastatur */
  void		(*dakeybd)(int key, int swt);
  	/* zusÑtzliche Routine, falls sich Edit-Objekt Ñndert */
  void		(*dwfocus)(struct _WINDOW *win, int old_ob, int new_ob);
  
  	/* zusÑtzliche Routine fÅr _vor_ Tastatur. Falls
  		 1 zurÅckgeliefert wird, wird die interne Bearbeitung
  		 nicht fortgesetzt! */
  int			(*dwkeydispatch)(struct _WINDOW *win, int key, int swt);
}DINFO;

typedef struct
{
	size_t	wist;					/* anzuzeigender Wert */
	size_t	wsoll;				/* maximal Wert */
	char		*saction;			/* Aktions Name */
}SINFO;

typedef struct _WINDOW
{
	int		whandle;				/* AES-Handle */
	void	*user;					/* Frei */

	TINFO	*tinfo;					/* Zeiger fÅr Textfenster */
	int		text;						/* 1=Fenster ist Textfenster */

	DINFO	*dinfo;					/* Zeiger auf Dialoginfo */
	int		dialog;					/* 1=Fenster ist Dialogfenster */
	
	SINFO	*sinfo;					/* Zeiger auf Balkenfenster */
	int		show;						/* 1=Fenster ist Balken-Fenster */
	
	int		kind;						/* Attribute */
	int		open;						/* 1=offen, 0=zu */
	int		full;						/* 1=fulled, 0=normal */
	int		fx, fy, fw, fh;	/* gespeicherte Koordinaten vor fulled */	
	int		wx, wy, ww, wh; /* Fensterpos. und Ausmaûe */
	int		ax, ay, aw, ah;	/* Arbeitsbereich (wird bei Redraw gesetzt)*/
	int		mx, my, mw, mh;	/* Max. Ausmaûe */
	int		nw, nh;					/* Min. Ausmaûe */
	int		do_align;				/* Wann soll aligned werden? (MOVE|SIZE) */
	int		xa, xo, xp;			/* X-Align & Offset & Add */
	int		ya, yo, yp;			/* Y-Align & Offset & Add */
	int		uhpos;					/* Pos. des User-H-Sliders */
	int		uhstep, uhpage;	/* User-Schrittweiten */
	int		uhmin, uhmax;		/* Maximal-Werte */
	int		uvpos;					/* Pos. des User-V-Sliders */
	int		uvstep, uvpage;	/* User-Schrittweiten */
	int		uvmin, uvmax;		/* Maximal-Werte */
	int		amode;					/* Arrow-Mode: */
												/* Bit 1 - Userwerte werden bearbeitet */
												/* Bit 2 - Arrowwerte werden bearbeitet */
												/* Bit 3 - usercalc() nach size & full */
	char	*name;					/* Zeiger auf Titelzeile */
	char	*info;					/* Zeiger auf Infozeile */
	int		hpos;						/* Position des H-Sliders */
	int		hsiz;						/* Grîûe des H-Sliders */
	int		vpos;						/* Position des V-Sliders */
	int		vsiz;						/* Grîûe des V-Sliders */
	int		hstep;					/* Schrittweite ARROW */
	int		vstep;
	int		hpage;					/* Schrittweite PAGE */
	int		vpage;
	
	int		rmode;		/* Modus fÅr Redraw */
									/* Bit 0=Redraw nach Slider+Arrow auslîsen */
									/* Bit 1=Redraw nach down-size auslîsen */
									/* Bit 2=Special-Redraw nach Arrow */
									/*			 falls Window oberstes ist */
									/* Bit 3=Full-Win Redraw nach up-size */
									
	void	(*usercalc)(struct _WINDOW *win);	
		/* User kann uarrow anpassen */
	void	(*userdraw)(struct _WINDOW *win, int x, int y, int w, int h);
		/* Normale Redraw-Routine */
	void	(*suserdraw)(struct _WINDOW *win, int x, int y, int w, int h, int dir);
		/* Spezial-Redraw-Routine */

	void	(*redraw)(struct _WINDOW *win, int *pbuf);	/*WM_REDRAW Fn */
	void	(*topped)(struct _WINDOW *win);	/*WM_TOPPED Fn */
	void	(*closed)(struct _WINDOW *win);	/*WM_CLOSED Fn */
	void	(*fulled)(struct _WINDOW *win);	/*WM_FULLED Fn */
	void	(*arrowed)(struct _WINDOW *win, int *pbuf);	/*WM_ARROWED Fn */
	void	(*hslid)(struct _WINDOW *win, int *pbuf);		/*WM_HSLID Fn */
	void	(*vslid)(struct _WINDOW *win, int *pbuf);		/*WM_VSLID Fn */
	void	(*sized)(struct _WINDOW *win, int *pbuf);		/*WM_SIZED Fn */
	void	(*moved)(struct _WINDOW *win, int *pbuf);		/*WM_MOVED Fn */
	void	(*untopped)(struct _WINDOW *win);/*WM_UNTOPPED Fn */
	void	(*ontop)(struct _WINDOW *win); /* WM_ONTOP Fn */
	void	(*backdrop)(struct _WINDOW *win); /* WM_BOTTOMED Fn */
}WINDOW;

/*  */
/* Globale Variablen */
/*  */
#define	MAX_WIN 64

extern	_app;

extern	char	*ap_name;

extern	AP_INFO	ap_info;

extern	int		magix, multitos, geneva, letfly, avs_id;
extern	long	magixval, multitosval, genevaval, letflyval;
extern	int		letflykeys; /* RÅckgabewert von Let'm'fly */

extern	int		pwchar, phchar, pwbox, phbox;
extern	int		ap_id, me_id, ap_type, handle, phys_handle;
extern	int		work_in[11], work_out[57], pbuf[64];

extern	COOKIE	*jar_addres;


/* VDI-Elemente fÅr Fenster-Workstation */

extern	int		wpwchar, wphchar, wpwbox, wphbox;
extern	int		whandle, wwork_in[11], wwork_out[57];

extern	int		globalmodal, globalhandle; /* Semaphore fÅr Dialoge */

extern	int		show_ww, show_wh;		/* Breite & Hîhe Show-Fenster */
extern	int		show_bw, show_bh;		/* Breite & Hîhe des Balkens */

extern	WINDOW	*winpoint[MAX_WIN];	/* Zeiger auf die Fenster */

/*  */
/* EC-GEM Funktionen und Definitionen*/
/*  */

/* Start-up Funktionen */
#define	AUTO	1
#define	ACC		2
#define	PRG		4
#define	TOS		8
#define	ANY	 15

void		e_start_as(int	how, char	*ap_nam);
void		uses_vdi(void);		 /* ôffnet normale VDI-VWork */
void		uses_txwin(void);	/* ôffnet zusÑztliche VWork */
void		e_quit(void);

/* Cookie-Funktionen */
#define	C_NEVER	0
#define	C_ALWAYS 1
#define	C_FULL 2
#define	C_LAST 3

long		jadadres(void);
long		inst_cjar(long n);
int			make_cookie(long cid, long cval, int jarmode, long n);
int			find_cookie(long cid, long *cval);
int			search_cookie(long n, long *cid, long *cval);
int			kill_cookie(long cid);

/* XBRA-Funktionen */
int		vector(int offset, long xbid, int del);

/* Ausgabe-Funktionen */
void show(int zahl);
void showl(long zahl);
void showlxy(int x, int y, long zahl);
#define showxyl showlxy
void showf(double zahl);
void showxy(int x, int y, int zahl);

/* Screen saver Funktionen */
int		scrsvr(void);

/* String Funktionen */
char *strocpy(char *dest, char *src, long offset);
char *strmid(char *dest, char *src, long offset, long len);

/*  */
/* Fenster Funktionen */
/*  */

#define NOFN (void(*)())0l
#define	CURR 0x2000

#define	RDARROW		1	/* Bit 0=Redraw nach Slider+Arrow auslîsen */
#define RDDNSIZED	2	/* Bit 1=Redraw nach down-size auslîsen */
#define RDSPECL 	4	/* Bit 2=Special-Redraw nach Arrow */
										/*			 falls Window oberstes ist */
#define RDUPSIZED 8	/* Bit 3=Full-Win Redraw nach up-size */

#define ARUSER 1  /* Bit 0=User-Slider werden bearbeitet */
#define ARSYS 2   /* Bit 1=Systemslider werden bearbeitet */
#define ARCALC 4  /* Bit 2=usercalc nach fulled+sized */

#define D_CUROFF 0 /* Cursor im Dialogfenster ausschalten */
#define D_CURON 1  /* anschalten */

#define	MODAL_ON 1
#define MODAL_OFF 0

#define	D_CENTER 1
#define	D_MOUSE	2

#define T_HFIT 1
#define	T_VFIT 2

#define	LetEmFly	1
#define	MagiX	2
#define	MagiC	2
#define	MTos	4
#define	Geneva	8

int	rc_intersect(GRECT *p1, GRECT *p2);
int min(int a, int b);
int max(int a, int b);
long lmin(long a, long b);
long lmax(long a, long b);

WINDOW *w_find(int whandle); /* Liefert Zeiger, falls Fenster */
														/* verwaltet, sonst NULL */
WINDOW *w_list(int cont);		/* Liefert alle verwalteten */

void	w_init(WINDOW *win);		/* Setzt die Standardwerte */
void	w_dinit(WINDOW *win);		/* Ebenso, aber fÅr Dialogwindow */
int		w_make(WINDOW *win);		/* Erzeugt Fenster und setzt AES */
int		w_open(WINDOW *win);		/* ôffnet Fenster mit wx,wy,ww,wh */
void	w_top(WINDOW *win);			/* Topped das Fenster */
int		w_istop(WINDOW *win);		/* PrÅft, ob das Fenster oberstes ist*/
int		w_close(WINDOW *win);		/* Schlieût das Fenster */
int		w_timer(int lo, int hi);/* Wird von kill zum evnt-queue leeren*/
int		w_kill(WINDOW *win);		/* Lîscht Fenster */
void	w_redraw(WINDOW *win, int x, int y, int w, int h, int mode);
			/* Liest Rechteck-Liste aus, clipped mit xywh und Screen */
			/* setzt CLIP und ruft userdraw oder suserdraw*/
void	w_clear(int x, int y, int w, int h);/*Lîscht den Fensterinhalt*/
void	w_set(WINDOW *win, int atrib);	/* éndert die in 'atrib' (=kind)*/
																	/* gesetzten werte per wind_set */
																	/* zusÑtzlich zu den kinds			*/
																	/* gibts CURR (Ñndert POS & SIZ)*/
void	w_get(WINDOW *win);		/* Setz wx,wy,ww,wh hpos,vpos,hsiz,vsiz*/
void	w_calc(WINDOW *win);	/* Berechnet den Arbeitsbereich */
void	w_wcalc(WINDOW *win);	/* Berechnet den Fensterbereich */
void	w_align(WINDOW *win);	/* Setzt wx,wy,ww,wh auf align */

int		w_dispatch(int *pbuf);	/* Ruft evtl. eine der folgenden Fn */
void	s_redraw(WINDOW *win);	/* Sendet Redraw fÅr win */
void	redraw(WINDOW *win, int *pbuf);		/*WM_REDRAW Fn */
void	topped(WINDOW *win);							/*WM_TOPPED Fn */
void	closed(WINDOW *win);							/*WM_CLOSED Fn */
void	fulled(WINDOW *win);							/*WM_FULLED Fn */
void	arrowed(WINDOW *win, int *pbuf);	/*WM_ARROWED Fn */
void	hslid(WINDOW *win, int *pbuf);		/*WM_HSLID Fn */
void	vslid(WINDOW *win, int *pbuf);		/*WM_VSLID Fn */
void	sized(WINDOW *win, int *pbuf);		/*WM_SIZED Fn */
void	moved(WINDOW *win, int *pbuf);		/*WM_MOVED Fn */
void	untopped(WINDOW *win);						/*WM_UNTOPPED Fn */
void	ontop(WINDOW *win);								/*WM_ONTOP Fn */
void	backdrop(WINDOW *win);						/*WM_BOTTOMED Fn */
void	nofunction(WINDOW *win);
void	noredraw(WINDOW *win, int x, int y, int w, int h);
void	nosredraw(WINDOW *win, int x, int y, int w, int h, int dir);

/* Textfenster */
int		w_text(WINDOW *win);		/* Erzeugt ein Textfenster */
void	w_txchange(WINDOW *win);/* Updatet bei TextÑnderung */
void	w_txlinechange(WINDOW *win, int line); /* Update einer Zeile */
void	w_txhome(WINDOW *win); /* Stellt Textposition auf 0,0 */
void	w_txgoto(WINDOW *win, int x, int y); /* dto. auf x,y */
void	w_txfit(WINDOW *win, int mode); /* Passt Fenster an Text an */
void	w_txmove(WINDOW *win);	/* Bewegt das Textfenster */

void	t_redraw(WINDOW *win, int x, int y, int w, int h);
														/* Redraw-Routine fÅr TEXT */
void	t_sredraw(WINDOW *win, int x, int y, int w, int h, int dir);
														/* Smart-Redraw */
void	t_calc(WINDOW *win);		/* Berechnungs-Routine */
int		lcount(char **text, int *longest); /* Text-ZÑhler */

/* Dialogfenster */
int		w_do_dial(OBJECT *tree);
int		w_do_opt_dial(OBJECT *tree, void (*w_do_obj)(WINDOW *win, int ob));


void	form_mouse(OBJECT *tree, int *x, int *y, int *w, int *h);
void	w_form_dial(int mode, int x1, int y1, int w1, int h1, WINDOW *win);
void	w_objc_draw(WINDOW *win, int ostart, int odepth, int x, int y, int w, int h);
int		w_form_do(WINDOW *wind, int oedit);
void	w_objc_change(WINDOW *win, int onum, int rsv, int x, int y, int w, int h, int nstate, int redraw);

int		w_dial(WINDOW *win, int center);
int		w_kdial(WINDOW *win, int center, int kind);
int		w_devent(int *evnt, int *mx, int *my, int *swt, int *key);
int		w_ddevent(int *evnt, int *mx, int *my, int *but, int *swt, int *key, int *klicks);
int		w_ddtevent(int *evnt, int *mx, int *my, int *but, int *swt, int *key, int *klicks, int lo, int hi);
int		w_dtimevent(int *evnt, int *mx, int *my, int *swt, int *key, int lo, int hi);
void	w_unsel(WINDOW *win, int ob);
/* (intern) : */
void	w_dialdraw(WINDOW *win, int x, int y, int w, int h);
void	w_sdialdraw(WINDOW *win, int x, int y, int w, int h, int mode);
void	w_dialmoved(WINDOW *win, int *mbuf);
void	w_dialtopped(WINDOW *win);
void	w_dialontop(WINDOW *win);
void	w_dialuntopped(WINDOW *win);
int		w_dialcursor(WINDOW *win, int mode);
void	w_modal(WINDOW *win, int mode);
int		w_form_modal(WINDOW *win, int oedit);
int		w_event(void);
int		w_button(int mx, int my);
int		w_keybd(int key, int swt);

/* Balken-Fenster */
void	w_showmake(WINDOW *win, char *action);
void	w_show(WINDOW *win, size_t ist, size_t soll);
void	w_showkill(WINDOW *win);

void	w_showdraw(WINDOW *win, int x, int y, int w, int h);

/* Extra-Aes */
#define TXT_HEIGHT 16

/* Object als XTED initialisieren, len=Maximale StringlÑnge. Speicher
   fÅr den String wird von der Funktion angefordert. secret=0 fÅr
   normales ED-Ob oder ein beliebiges Zeichen fÅr Secret-Input */
void	objc_xted(OBJECT *tree, int ob, int len, char secret);
/* <text> als Stringpointer fÅr xted Åbernehmen, offset zurÅcksetzen
   und sichtbaren Bereich nach tedinfo kopieren */
void	objc_xtedset(OBJECT *tree, int ob, char *text);
/* Inhalt von <text> nach XTED kopieren, offset zurÅcksetzen
   und sichtbaren Bereich nach tedinfo kopieren */
void	objc_xtedcpy(OBJECT *tree, int ob, char *text);

void	img_fix(OBJECT *root, int ob);
void	img_free(OBJECT *root, int ob);
int		popup(OBJECT *tree, int ob, OBJECT *poproot, int pop, int entries, int def);
int		form_popup(OBJECT *poproot, int x, int y);
void	unsel(OBJECT *tree, int obnr);
int		unselect_3d(OBJECT *tree, int ob);

int		wnd_get(int w_hnd, int func, int *p1, int *p2, int *p3, int *p4);


/* AV-Protkoll */
void	va_init(char *my_name);
void	va_open(int wid);
void	va_close(int wid);
void	va_sendkey(int kbs, int key);
void	va_exit(void);

/* MenÅ-Tastatursteuerung */
int	menu_key(OBJECT *tree, int key, int swt, int *title, int *ob);
char *get_menu_key(OBJECT *tree, int ob, char *dst);
void make_menu_string(int key, int swt, char *dst);
void scan_text(int key, int *swt, char *dst);

/* MenÅ sperren/freigeben */
void lock_menu(OBJECT *tree);
void unlock_menu(OBJECT *tree);

/* Gemdos-Fehlermeldungen */
void gemdos_alert(char *text, long en);

/* Clipboard */
int		write_clipboard(char *name);
int		read_clipboard(char *name, char *dpath);
int		sread_clipboard(char *name);
void	clear_clipboard(void);
void	clip_path(char *dst);


#endif
