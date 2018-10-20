
#ifndef __EPX__
#define __EPX__

#include <e_gem.h>
#include <setjmp.h>

#if !defined(__PUREC__) && !defined(cdecl)
#ifdef LATTICE
#define cdecl	__stdargs
#else
#define cdecl
#endif
#endif

#define MAX_FILENAME	128

#define ExtCPX			'eCPX'
#define ExtCTRL			"Space\xbf"
#define	ExtNAME			"SPACE   "
#define ExtVERS			0x0200
#define ExtVersion		"2.00"
#define ExtREV			0x0001

/* Fehlermeldungen bei XGen_Alert */
enum {SAVE_DEFAULTS=0,MEM_ERR,FILE_ERR,FILE_NOT_FOUND,CPX_OVERFLOW,RELOAD_CPX,KILL_CPX,
	  RES_ERR,SAVE_CONFIG,NO_CPX_FILE,NO_ST_SOUND,CONTROL_OFF,WIN_ERR,TIMER_ERR,SHARED_ERR,FNTSEL_ERR};

/* Modi fÅr MFSave */
enum {MFRESTORE=0,MFSAVE};

/* LÑnderkennungen bei Country_code */
enum {USA=0,FRG,FRA,UK,SPA,ITA,SWE,SWF,SWG,TUR,FIN,NOR,DEN,SAU,HOL};

/* laufendes CPX wurde nochmals aktiviert:
	msg[0]	 = EPX_OPEN
	msg[1]	 = ap_id
	msg[2]	 = 0
	msg[3/4] = 0 (reserviert)
	msg[5/6] = Zeiger auf Argumente (char *) oder NULL
			   (Auswertung mit ParseArgs)
	msg[7]	 = Art der CPX-Aktivierung (s. CPX_CALL-Konstanten) */
#define EPX_OPEN		CPX_RES1

/* interne Nachricht:
	msg[0]	 = EPX_START
	msg[1]	 = ap_id
	msg[2]   = 0
	msg[3/4] = Zeiger auf Dateiname
	msg[5/6] = Zeiger auf Argumente
	msg[7]   = 0 (reserviert) */
#define EPX_START		CPX_RES2

/* Offset der 'Applikations-IDs' fÅr CPXe */
#define EPX_MSG_OFFSET	1024

/* Nachricht bei Tastendruck an Form-CPXe */
#define CT_KEY			53

typedef struct
{
	int flag,x,y,w,h;
} MEVENT;

typedef struct
{
	int		ph_branch;
	long	ph_tlen,ph_dlen,ph_blen,ph_slen,ph_res1,ph_prgflags;
	int		ph_absflag;
} PRGHEADER;

typedef struct cpx_header
{
	unsigned	magic;

	struct
	{
		unsigned rsrc_obfix		: 1;
		unsigned reserved		: 12;
		unsigned ram_resident	: 1;
		unsigned boot_init		: 1;
		unsigned set_only		: 1;
	} flags;

	long		cpx_id;
	unsigned	cpx_version;

	char		icon_text[14];
	int			icon[48];
	struct
	{
		unsigned i_color	: 4;
		unsigned reserved	: 4;
		unsigned i_char		: 8;
	} icon_info;

	char		text[18];
	struct
	{
		unsigned c_board	: 4;
		unsigned c_text		: 4;
		unsigned pattern	: 4;
		unsigned c_back		: 4;
	} text_info;

	char		buffer[64];
	unsigned	state,scan_ascii;
	char		reserved[302];
} CPXHEADER;

enum
{
 CPX_CALL_USER=0,	/* durch Benutzer aktiviert */
 CPX_CALL_INIT,		/* Initialisierung */
 CPX_CALL_BOOT,     /* Boot-Initialisierung */
 CPX_CALL_AUTO,		/* Auto-Start */
 CPX_CALL_MSG,		/* Nachricht an CPX */
 CPX_CALL_SHARED,	/* SharedCPX wurde von anderem CPX nachgeladen */
 CPX_CALL_DD,		/* Dateien wurde per D&D (AV-Protokoll,Pipe-D&D,
                       VA_START,AV_OPENWIND,AV_XWIND) an das CPX Åbergeben */
 CPX_CALL_BY_CPX,	/* durch anderes CPX gestartet */
 CPX_CALL_BY_APP	/* durch andere Anwendung gestartet */
};

typedef struct
{
	/* Neue Parameter:
		para:  Zeiger auf Argumente (Auswertung mit ParseArgs)
		flags: Art der CPX-Aktivierung (s. CPX_CALL-Konstanten)
	   Hinweis:
	    Bei SharedCPX-Modulen (s. EPX-Header 'shared_cpx') muû diese Funk-
	    tion nicht implementiert sein.
	*/
	int	 cdecl (*cpx_call)(GRECT *work,char *para,int flags);

	void cdecl (*cpx_draw)(GRECT *clip);
	void cdecl (*cpx_wmove)(GRECT *work);

	/* Neue Parameter:
		mrets: Mausposition und Zustand der Maus- sowie Sondertasten
	   Hinweis:
		I.A. sollten bei neuen CPXen die Timer-Funktionen (NewTimer,
		WinTimer,EnableTimer,KillTimer) aus GeschwindigkeitsgrÅnden
		anstatt 'cpx_timer' genutzt werden.
	*/
	void cdecl (*cpx_timer)(int *event,MKSTATE *mrets);

	/* Neu:
		dialog: Zeiger auf DIAINFO-Struktur des zugehîrigen Dialogs
		        oder NULL
		win:    Zeiger auf WIN-Struktur des zugehîrigen Fensters
		        (oder Fensterdialoges) oder NULL
		=> bei Fenster/Dialog-spezifischen TastendrÅcken sollten obige
		   Parameter unbedingt berÅcksichtigt werden
		RÅckgabewert: !=0 -> Tastendruck ausgewertet
					  ==0 ->  -"- nicht ausgewertet
		=> wird nur bei eCPXen beachtet!
	*/
	int cdecl (*cpx_key)(int kstate,int key,int *event,DIAINFO *dialog,WIN *win);

	/* Neu:
		dialog: Zeiger auf DIAINFO-Struktur des zugehîrigen Dialogs
		        oder NULL
		win:    Zeiger auf WIN-Struktur des zugehîrigen Fensters
		        (oder Fensterdialoges) oder NULL
		=> obige Parameter sollten i.A. unbedingt berÅcksichtigt werden
	*/
	void cdecl (*cpx_button)(MKSTATE *mrets,int nclicks,int *event,DIAINFO *dialog,WIN *win);

	void cdecl (*cpx_m1)(MKSTATE *mrets,int *event);
	void cdecl (*cpx_m2)(MKSTATE *mrets,int *event);

	/* Neue Parameter:
		stop:	  Auf Wert ungleich Null setzen, wenn CPX beendet werden soll
		cpx_only: Nachrichten-Ereignis (MU_MESAG) ist CPX-spezifisch
	*/
	int cdecl  (*cpx_hook)(int event,int *msg,MKSTATE *mrets,int *key,int *nclicks,int *stop,int cpx_only);

	/* Hinweis:
		Funktion wird nicht aufgerufen, wenn sich das CPX selber beendet
		oder wenn das CPX nur initialisiert (cpx_init), aber nicht aufge-
		rufen (cpx_call) wurde. Ebenso wird die Funktion nicht bei der
		Nachricht AC_CLOSE aufgerufen, wenn das CPX AC_CLOSE-resident
		ist! */
	void cdecl (*cpx_close)(int flag);

/**** optionale (!) eCPX-Erweiterungen ****/

	long		id;	/* eCPX-Erkennung (ExtCPX) */

	/* cpx_term: Funktion wird aufgerufen, wenn ein eCPX terminiert wird
		Parameter 'etv_term':
			FALSE: eCPX wurde normal terminiert, wobei 'cpx_term' nach (!)
				   'cpx_close' aufgerufen wird (s.a. Hinweis zu 'cpx_close')
			TRUE:  eCPX wurde nicht terminiert, d.h. es wird nur 'cpx_term'
				   aufgerufen. Dies ist der Fall, wenn Space abgestÅrzt ist
				   oder zwangsterminiert wurde (z.B. im Taskmanager oder
				   im U:\PROC-Verzeichnis gelîscht oder per Signal)
				   und im 'etv_term'-Vektor Deinitialisierungsaufgaben
				   erledigt. In diesem Fall sind i.A. GEMDOS/VDI/AES/XCPB-
				   Calls nicht mîglich und es sollten nur Vektoren/Cookies
				   usw. zurÅckgesetzt/deinitialisiert werden. Dazu sollte
				   natÅrlich i.A. XBRA unterstÅtzt werden.
			FAIL:  eCPX wurde nicht terminiert, d.h. es wird nur 'cpx_term'
				   aufgrund eines Auflîsungswechsels unter SingleTOS aufge-
				   rufen. Zu diesem Zeitpunkt sind AES/VDI/GEMDOS bereits
				   de-/reinitialisiert, so dass nur BIOS/XBIOS-Calls mîg-
				   lich sind. U.a. sollten unbedingt OS-Variablen (<$800,
				   u.a. Cookies u. Vektoren) zurÅckgesetzt werden. */
	void cdecl (*cpx_term)(int etv_term);
} CPXINFO;

#define MAX_WILD	40
#define MAX_MSG		24

typedef struct
{
	int			branch;			/* Sprung zum CPX-Anfang */
	long		id;				/* eCPX-Erkennung (ExtCPX) */
	unsigned	version;		/* minimal benîtigte Versionsnummer des
	                               Kontrollfelds (>=0x0200) */
	unsigned    revision;       /* Bitmap der unterstÅtzten Revisionen
	                               der Schnittstelle (bisher 0x0001) */
	char		*xacc_name;		/* Kennungen fÅr den erweiterten XAcc-2-
								   Programmnamen (XDSC) */
	char wild_cards[MAX_WILD];	/* Wildcards fÅr CPX-spezifische Dateien */
	int			stack_size;		/* Stackgrîûe (>0), sofern mehr (oder
	                               weniger) als 2 KB benîtigt werden */
	struct
	{
		/* reserviert (0) */
		unsigned					: 10;

		/* CPX erweitert Schnittstelle um neue Funktionen */
		unsigned shared_cpx         : 1;

        /* Auto-Start-Mîglichkeit ist konfigurierbar */
        unsigned auto_start_cnf		: 1;

        /* Mehrfach-Start-Mîglichkeit ist konfigurierbar */
        unsigned multi_start_cnf	: 1;

		/* CPX wird bei AC_CLOSE nicht beendet und Åber die Schnitt-
		   stelle angeforderter Speicher wird NICHT freigegeben
		   (Dialoge/Fenster/Timer sowie Workstations oder beim OS ange-
		    forderter Speicher werden natÅrlich geschlossen bzw. mÅssen
		    geschlossen/freigegeben werden!) */
		unsigned ac_close_res		: 1;

		/* CPX wird automatisch beim ersten Laden gestartet, also nicht nur
		   initialisiert */
		unsigned auto_start			: 1;

		/* Mehrfach-Start mîglich */
		unsigned multi_start 		: 1;
	} flags;

	int			extension;		/* Bitmap der Schnittstellenerweiterungen,
								   falls es sich um ein "SharedCPX" handelt */
	long		res1,res2,res3;	/* reserviert (0l) */
	int			msg[MAX_MSG];	/* Liste von maximal MAX_MSG Nachrichten,
	                               bei deren Eintreffen in Space (!) das
	                               eCPX evtl. geladen und gestartet wird;
	                               Ende der Liste mit Wert<=0 */
} EPX_HEADER;

typedef struct
{
	SLINFO	slider;
	OBJECT	*tree;
	int		min,max,*num_var;
	void	(*foo)(void);
} SLIDER;

typedef	struct
{
	void *text_seg;
	long len_text;
	void *data_seg;
	long len_data;
	void *bss_seg;
	long len_bss;
} SEGMENT;

typedef struct __cpxlist
{
	char 		f_name[14];
	int 		head_ok,segm_ok;
	SEGMENT 	*segm;
	struct __cpxlist *next;

	CPXHEADER	header;

/* eCPX-Erweiterungen (nicht garantiert und nur fÅr interne Zwecke!) */

	PRGHEADER	prg;
	EPX_HEADER	epx;

	SEGMENT		segment;
	long		len;
	void		*list;
	DIAINFO		*settings;
	char		SkipRshFix,ExtendedCPX,set_only,form_cpx;
	int			id;
	char		path[MAX_FILENAME],wild[MAX_WILD],name[10];
	jmp_buf		last_jump;

	void		*mem,*stack;
	DIAINFO		*dialog;
	WIN			*window;
	OBJECT		iconified;
	ICONBLK		icon;

	CPXINFO		*info;
	SLIDER		*sl;
	GRECT		rect,output;
	char		init,form_do,frozen,update,rc_list,form_stop,term_done;
	char		*dd_args,*dd_buffer;
	int			get_window_next,find_app_next;
	int			stop,mask,*msg,shared_needed,shared_auto,events;
	long		time,timer_id;
	MEVENT		m1,m2;

	jmp_buf		xform;
} CPXLIST;

/*
   Hinweise:
   - In eCPX-Modulen sollten/dÅrfen alle Slider- (Sl_...), Resource-
     (rsh_...), Rechteck (GetFirst/NextRect) und FormDo-Funktionen
     (Xform_do) nicht verwendet werden!
   - HÑngt sich ein eCPX-Modul in einen Vektor in der XCPB-Struktur, so
     muû beim Aufruf der alten XCPB-Funktion i.A. die RÅcksprungadresse
     unverÑndert sein (auûer bei Funktionen, die offensichtlich nicht CPX-
     spezifisch sind (z.B. DebugOut() oder getcookie()). Auûerdem muû eine
     XBRA-Verkettung unterstÅtzt werden.
*/

typedef struct _cpx_params
{
	/* Erweiterte Bedeutung von 'booting':
		FALSE -> CPX-Aufruf
		TRUE  -> allg. Initialisierung
		FAIL  -> Boot-Initialisierung */
	int			handle,booting,reserved,SkipRshFix;

	CPXLIST *cdecl	(*get_cpx_list)(void);

	int cdecl		(*save_header)(CPXLIST *header);
	void cdecl		(*rsh_fix)(int num_obs,int num_frstr,int num_frimg,int num_tree,OBJECT *rs_object,TEDINFO *rs_tedinfo,char *rs_strings[],ICONBLK *rs_iconblk,BITBLK *rs_bitblk,long *rs_frstr,long *rs_frimg,long *rs_trindex,struct foobar *rs_imdope);
	void cdecl		(*rsh_obfix)(OBJECT *tree,int curob);
	int cdecl		(*popup)(char *items[],int num_items,int default_item,int font_size,GRECT *button,GRECT *world);
	void cdecl		(*Sl_size)(OBJECT *tree,int base,int slider,int num_items,int visible,int direction,int min_size);
	void cdecl		(*Sl_x)(OBJECT *tree,int base,int slider,int value,int num_min,int num_max,void(*foo)(void));
	void cdecl		(*Sl_y)(OBJECT *tree,int base,int slider,int value,int num_min,int num_max,void(*foo)(void));
	void cdecl		(*Sl_arrow)(OBJECT *tree,int base,int slider,int obj,int inc,int min,int max,int *numvar,int direction,void(*foo)(void));
	void cdecl		(*Sl_dragx)(OBJECT *tree,int base,int slider,int min,int max,int *numvar,void(*foo)(void));
	void cdecl		(*Sl_dragy)(OBJECT *tree,int base,int slider,int min,int max,int *numvar,void(*foo)(void));
	int cdecl		(*Xform_do)(OBJECT *tree,int start_field,int *puntmsg);
	GRECT *cdecl	(*GetFirstRect)(GRECT *prect);
	GRECT *cdecl	(*GetNextRect)(void);
	void cdecl		(*Set_Evnt_Mask)(int mask,MEVENT *m1,MEVENT *m2,long time);
	int cdecl		(*XGen_Alert)(int id);
	int cdecl		(*CPX_Save)(void *ptr,long num);
	void *cdecl		(*Get_Buffer)(void);
	int cdecl		(*getcookie)(long cookie,long *p_value);

	int	Country_Code;

	void cdecl		(*MFsave)(int saveit,MFORM *mf);

/* eCPX-Erweiterungen, Revision 1 */

	long 		id;				/* eCPX-Erkennung (ExtCPX) (bei nicht
								   vorhandener Kennung ist nur die
								   normale Kontrollfeld-Schnittstelle
								   vorhanden!) */
	unsigned	version;		/* Versionsnummer (>=0x0200) */
	unsigned	revision;		/* Bitmap der vorhandenen Revisionen
								   der neuen Schnittstelle (eCPXe
								   werden nur geladen, wenn mindestens
								   eine benîtigte Revision vorhanden ist) */
	unsigned 	extension;		/* Bitmap der vorhandenen Schnittstellen-
								   erweiterungen */
	void		*ext_block[16];	/* Zeiger auf Strukturen der Schnittstellen-
								   erweiterungen, sofern entsprechendes
								   Bit gesetzt ist (s.o) */

	int			ap_id,vdi_handle,menu_id,has_3d,bottom,bevent,owner;
	int			gr_cw,gr_ch,gr_bw,gr_bh,gr_sw,gr_sh;
	int			max_w,max_h,planes,colors,colors_available;
	int			multi,aes_version,winx,magx,wincom,mtos,mint;
	int		 	small_font,small_font_id,ibm_font,ibm_font_id,fonts_loaded,speedo;
	int 		search,boot_drive;
	unsigned	gemdos_version,tos_version,tos_date;

	GRECT		desk;
	VRECT		clip;

	BASPAG		*BasePage;

	int cdecl		(*appl_xgetinfo)(int type,int *out1,int *out2,int *out3,int *out4);
	int	cdecl		(*objc_xsysvar)(int ob_smode,int ob_swhich,int ob_sival1,int ob_sival2,int *ob_soval1,int *ob_soval2);
	int cdecl		(*appl_getfontinfo)(int ap_gtype,int *height,int *id,int *type);
	int	cdecl		(*wind_xget)(int w_handle,int w_field,int *w1,int *w2,int *w3,int *w4);

	char *cdecl		(*getenv)(const char *name);

	int cdecl		(*SendDragDrop)(int msx,int msy,int kstate,char *text,char *name,char *sp_ext,long size,char *data);
	int cdecl		(*AppDragDrop)(int sendto,int win_id,int msx,int msy,int kstate,char *text,char *name,char *sp_ext,long size,char *data);
	char *cdecl		(*ParseArgs)(char *orig);

	XAcc *cdecl		(*XAccFindXDSC)(int id,char *dsc);
	XAcc *cdecl		(*XAccFindId)(int id);
	XAcc *cdecl		(*XAccFindApp)(int first);

	int cdecl		(*XAccSendAck)(int sendto,int answer);
	int	cdecl		(*XAccSendKey)(int sendto,int scan,int state);
	int cdecl		(*XAccSendText)(int sendto,char *text);
	int cdecl		(*XAccSendMeta)(int sendto,int last,char *data,long len);
	int cdecl		(*XAccSendImg)(int sendto,int last,char *data,long len);
	void cdecl		(*XAccBroadCast)(int *msg);

	int	cdecl		(*GetAvServer)(void);
	int cdecl		(*VaStart)(int sendto,char *args);
	int cdecl		(*AvSendMsg)(int sendto,int msg_id,int *msg);

	int	cdecl		(*AppName)(int app,char *prog_name,char *xacc_name);
	int cdecl		(*AppLoaded)(char *app);

	void cdecl		(*scrp_clr)(int all);
	long cdecl		(*scrp_length)(void);
	int cdecl		(*scrp_find)(char *extension,char *filename);
	int cdecl		(*scrp_path)(char *path,char *file);
	void cdecl		(*scrp_changed)(int format,long best_ext);

	void cdecl		(*drive_changed)(int drive);

	int cdecl		(*mouse)(int *x,int *y,int *state);
	int cdecl		(*MouseForm)(int index,MFORM *user);
	void cdecl		(*MouseBusy)(void);
	void cdecl		(*MouseOn)(void);
	void cdecl		(*MouseOff)(void);
	int cdecl		(*MouseUpdate)(int flag);
	int cdecl		(*ButtonUpdate)(int flag);
	int cdecl 		(*KeyUpdate)(int flag);

	int	cdecl		(*scan_2_ascii)(int scan,int state);

	char *cdecl		(*DgetFullpath)(char *path);
	char *cdecl		(*GetFilename)(char *path);
	char *cdecl		(*GetExtension)(char *path);
	char *cdecl		(*GetPath)(char *fname);
	int cdecl		(*GetDrive)(char *path);
	char *cdecl		(*MakeFullpath)(char *dest,char *path,char *file);
	char *cdecl		(*QuoteFname)(int quote,char *dest,char *source);
	int cdecl		(*CheckWildcard)(char *match,char *wildcards,char *out,int insens);
	int	cdecl		(*sprintf)(char *buffer,const char *format,...);

	int	cdecl	 	(*beg_ctrl)(int test,int out,int ms);
	void cdecl		(*end_ctrl)(int out,int ms);
	int	cdecl		(*beg_update)(int test,int mouse);
	void cdecl		(*end_update)(int mouse);
	int	cdecl		(*is_ctrl)(void);
	int cdecl		(*is_update)(void);

	int	cdecl		(*rc_intersect)(GRECT *r1,GRECT *r2);
	int cdecl		(*rc_inside)(int x,int y,GRECT *rec);
	int cdecl		(*rc_equal)(GRECT *r1,GRECT *r2);
	void cdecl		(*rc_sc_copy)(GRECT *source,int dx,int dy,int mode);
	void cdecl		(*rc_sc_clear)(GRECT *dest);
	void cdecl		(*rc_sc_set)(GRECT *dest);
	void cdecl		(*rc_sc_invert)(GRECT *dest);
	int cdecl		(*rc_sc_scroll)(GRECT *work,int dist_h,int dist_v,GRECT *work2);

	FONTINFO *cdecl	(*FontInfo)(int id);
	FONTINFO *cdecl	(*FastFontInfo)(int id);
	int cdecl		(*FontAvailable)(int id,char *name);
	int cdecl		(*FontList)(int type,int min_size,int max_size,int max_fonts,FONTINFO *fonts[]);
	int cdecl		(*FontSizes)(int id,int fsm,int min_size,int max_size,int max_cnt,int *sizes);
	int cdecl		(*Height2Point)(int font,int height);

	int cdecl		(*CallFontSelector)(int win,int fnt_id,int size,int color,int effect);
	int cdecl		(*FontAck)(int id,int ack);

	DIAINFO *cdecl	(*open_dialog)(OBJECT *tree,char *win_name,char *icon_name,OBJECT *icon,int center,long mode,int edit,SCROLL *scroll,int cdecl (*foo)(DIAINFO *info,int obj,int clicks),void *para,SLINFO **sl_list,XPOPUP **po_list,XLISTBOX **lb_list);
	int cdecl		(*close_dialog)(DIAINFO *info);
	void cdecl 		(*dialog_mouse)(DIAINFO *info,int cdecl (*mouse)(DIAINFO *info,OBJECT *tree,int obj,int last_obj,int x,int y,GRECT *out));
	int cdecl		(*get_dialog_info)(int *fly_dials,int *win_dials,DIAINFO **top);

	int	cdecl		(*ListBox)(LISTBOX *lb,int mode,int x,int y);
	int cdecl		(*Popup)(POPUP *popup,int mode,int center,int x,int y,int *index,int select);
	void cdecl      (*ClosePopup)(void);
	int	cdecl		(*FileSelect)(char *title,char *path,char *fname,char *sel,int no_insel,int out,char *outptr[],int id,int modal);

	ALERT *cdecl	(*MakeAlert)(int def,int undo,int icn,BITBLK *usr_icn,int modal,int center,int width,char *title,char *txt,char *btns);
	int	cdecl		(*ExitAlert)(ALERT *al,int exit);
	int cdecl		(*xalert)(int def,int undo,int icn,BITBLK *usr_icn,int modal,int center,int width,char *title,char *txt,char *btns);

	OBJECT *cdecl	(*MakeAscii)(void);
	char cdecl		(*ExitAscii)(OBJECT *tree,int exit);
	char cdecl		(*ascii_box)(DIAINFO *edit,char *title);

	WIN *cdecl		(*open_window)(char *title,char *icon_title,char *info,OBJECT *icon,int typ,GRECT *max_curr,GRECT *curr,SCROLL *scroll,void cdecl (*redraw)(int first,WIN *win,GRECT *area),void *para,int msgs);
	void cdecl		(*window_reinit)(WIN *win,char *title,char *icon_title,char *info,int home,int draw);
	int cdecl		(*close_window)(WIN *window);

	int cdecl		(*window_output)(void);
	int cdecl		(*windows_opened)(void);
	int cdecl		(*window_work)(WIN *win,GRECT *out);
	WIN *cdecl		(*get_window)(int handle);
	WIN *cdecl		(*get_window_list)(int first);
	int	cdecl		(*GetTop)(void);
	int cdecl		(*GetOwner)(int handle,int fuzzy,int epx);
	int cdecl		(*window_first)(WIN *win,GRECT *rect);
	int cdecl		(*window_next)(WIN *win, GRECT *rect);

	int cdecl		(*WindowHandler)(int mode,WIN *window);
	void cdecl		(*WindowItems)(WIN *win,int cnt,MITEM *items);

	int cdecl		(*window_top)(WIN *win);
	int cdecl		(*window_bottom)(WIN *win);
	void cdecl		(*window_size)(WIN *win,GRECT *size);
	void cdecl		(*window_name)(WIN *win,char *name,char *icon_name);
	void cdecl		(*window_info)(WIN *win,char *info);
	void cdecl		(*window_set_mouse)(WIN *window,int in,int work,int out,int icon,MFORM *in_form,MFORM *work_form,MFORM *out_form,MFORM *icon_form);

	void cdecl		(*draw_window)(WIN *win,GRECT *area,void *para,int m_off,void cdecl (*redraw)(int first,WIN *win,GRECT *area,GRECT *work,void *para));
	void cdecl		(*redraw_window)(WIN *win,GRECT *area);
	void cdecl		(*scroll_window)(WIN *win,int mode,GRECT *rect);

	void cdecl		(*rsrc_calc)(OBJECT *tree,int scaling,int orig_cw,int orig_ch);
	void cdecl		(*rsrc_init)(int n_tree,int n_obs,int n_frstr,int n_frimg,int scaling,char **rs_strings,long *rs_frstr,BITBLK *rs_bitblk,long *rs_frimg,ICONBLK *rs_iconblk,TEDINFO *rs_tedinfo,OBJECT *rs_object,OBJECT **rs_trindex,RS_IMDOPE *rs_imdope,
								 int orig_cw,int orig_ch,int obfix);
	void cdecl		(*fix_objects)(OBJECT *tree,int scaling,int orig_cw,int orig_ch);

	void cdecl		(*graf_set_slider)(SLINFO *sl,OBJECT *tree,int show);
	void cdecl		(*graf_rt_slidebox)(SLINFO *sl,int obj,int double_click,int new_pos,int new_cursor);
	void cdecl		(*graf_rt_slidecursor)(SLINFO *sl,int dc);

	int cdecl		(*graf_rt_rubberbox)(int desk_clip,int s_x,int s_y,int min_w,int min_h,GRECT *bound,int *r_w,int *r_h,void cdecl (*call_func )(int draw,int *array,MKSTATE *mk));
	int cdecl		(*graf_rt_dragbox)(int desk_clip,GRECT *start,GRECT *bound,int *r_x,int *r_y,void cdecl (*call_func )(int draw,int *array,MKSTATE *mk));
	int cdecl		(*graf_rt_dragobjects)(int desk_clip,int *objects,GRECT *bound,void cdecl (*call_func )(int draw,int *array,MKSTATE *mk));

	OBJECT *cdecl	(*ob_copy_tree)(OBJECT *tree);

	int cdecl		(*ob_draw_chg)(DIAINFO *info,int obj,GRECT *area,int new_state);
	int cdecl		(*ob_draw_list)(DIAINFO *info,int *ob_lst,GRECT *area);
	int cdecl		(*ob_radio)(DIAINFO *info,OBJECT *tree,int parent,int object);
	int cdecl       (*ob_state)(DIAINFO *info,OBJECT *tree,int obj,int masc,int set,int draw);
	int cdecl		(*ob_select)(DIAINFO *info,OBJECT *tree,int obj,int select,int draw);
	int cdecl		(*ob_disable)(DIAINFO *info,OBJECT *tree,int obj,int disable,int draw);

	char *cdecl		(*ob_get_text)(OBJECT *tree,int obj,int clear);
	void cdecl		(*ob_set_text)(OBJECT *tree,int object,char *text);
	char cdecl		(*ob_get_hotkey)(OBJECT *tree,int button);
	int cdecl		(*ob_set_hotkey)(OBJECT *tree,int button,char hot);
	int cdecl		(*ob_set_cursor)(DIAINFO *info,int obj,int index,int insert,int scroll);

	void cdecl		(*ob_dial_init)(DIAINFO *info,int edit);
	void cdecl		(*ob_edit_init)(DIAINFO *info,int edit);
	void cdecl		(*ob_edit_handler)(DIAINFO *info,int cdecl (*handler)(DIAINFO *info,char valid,char c,char *new));

	int	cdecl		(*init_edit)(OBJECT *tree,int obj,char *text,int len);
	int cdecl		(*set_edit)(DIAINFO *info,OBJECT *tree,int obj,char *text);
	char *cdecl		(*get_edit)(DIAINFO *info,int obj);
	int cdecl		(*update_edit)(DIAINFO *info,int obj);

	void cdecl		(*vs_attr)(void);
	int cdecl		(*v_set_font)(int font);
	int cdecl		(*v_set_point)(int all,int height);
	void cdecl		(*v_set_text)(int font,int height,int color,int effect,int rotate,int *out);
	void cdecl		(*v_set_mode)(int mode);
	void cdecl		(*v_set_line)(int color,int width,int type,int start,int end);
	void cdecl		(*v_set_fill)(int color,int inter,int style,int peri);
	void cdecl		(*v_set_clipping)(GRECT *clip);
	void cdecl		(*v_get_clipping)(GRECT *clip);

	long cdecl		(*NewTimer)(long count,long para,long cdecl (*foo)(long para,long time,MKSTATE *mk,int *stop));
	long cdecl		(*WinTimer)(WIN *win,int disable,long count,long para,long cdecl (*foo)(long para,long time,MKSTATE *mk,int *stop));
	int	cdecl		(*EnableTimer)(long id,int para);
	int	cdecl		(*KillTimer)(long id);

	int cdecl		(*Event_Multi)(XEVENT *event);
	void cdecl		(*Event_Timer)(int locount,int hicount,int no_key);
	void cdecl		(*DispatchEvents)(void);
	void cdecl		(*ClrKeybd)(void);
	void cdecl		(*NoClick)(void);

	CPXLIST	*cdecl	(*cpx_find)(char *name);
	CPXLIST *cdecl	(*cpx_ident)(int id);

	CPXLIST	*cdecl	(*cpx_load)(char *name);
	int	cdecl		(*cpx_run)(CPXLIST *cpx,char *para);
	int	cdecl		(*cpx_stop)(CPXLIST *cpx);
	int	cdecl		(*cpx_kill)(CPXLIST *cpx);
	int	cdecl		(*cpx_write)(CPXLIST *cpx,int *msg);

	void cdecl		(*cpx_dir)(char *home,char *directory);
	int cdecl		(*cpx_info)(char *path,char *fname);
	int cdecl		(*cpx_dialogs)(CPXLIST *cpx,int *fly,int *win);
	int cdecl		(*cpx_windows)(CPXLIST *cpx);

	int cdecl		(*xcpb_extension)(int which);

	int cdecl		(*TestXBRA)(void *vector,void *code);
	void *cdecl		(*RemoveXBRA)(void *vector,void *code);

	void *cdecl		(*malloc)(long size,int global,int fast_ram);
	void *cdecl		(*realloc)(void *block,long newsize,int global,int fast_ram);
	int cdecl		(*shrink)(void *block,long newsize);
	void cdecl		(*free)(void *ptr);
	void *cdecl		(*memmove)(void *dest,const void *src,long size);
	void cdecl		(*memset)(void *mem,int val,long size);
	int	cdecl		(*memcmp)(const void *s1,const void *s2,long len);

	void cdecl		(*DebugOut)(const char *format,...);

	void 			(*col_res1)(int d_pattern,int d_color,int d_frame,int hotkey,int alert,int popup,int check,int radio,int arrow,int popup_bgrnd,int check_bgrnd,int radio_bgrnd,int arrow_bgrnd,int edit_ddd,int draw_ddd,int icon_bg_color);

	void 			(*opt_res1)(boolean round,boolean niceline,boolean xobjs_norm,boolean ret,boolean back,boolean nonsel,boolean keys,boolean mouse, boolean clipboard,int hz);
	void 			(*opt_res2)(boolean set,boolean center,boolean frame,boolean small,boolean transp,int tcolor,int fcolor,int bcolor,int bpattern);
	void 			(*opt_res3)(boolean title,int color,int size);

	void 			(*img_res1)(int index,BUTTON *radio);
	void 			(*img_res2)(int index,BUTTON *check);
	void 			(*img_res3)(int index,BUTTON *down,BUTTON *up,BUTTON *left,BUTTON *right);
	void 			(*img_res4)(int index,BUTTON *cycle,char c);

	void			(*av_res1)(int nokey);
	void			(*space_res1)(int boxes);
} XCPB;

#endif
