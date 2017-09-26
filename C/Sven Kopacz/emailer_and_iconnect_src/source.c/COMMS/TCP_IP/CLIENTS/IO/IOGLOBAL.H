#if !defined( __UTYPES__ )
#define __UTYPES__
typedef	unsigned char uchar;
typedef	uchar					byte;
typedef	unsigned int	uint;
typedef	unsigned long ulong;
#endif

#define set_ext_type(tree,ob,val)	{tree[ob].ob_type &=255; tree[ob].ob_type |= (((char)val)<<8);}
#define obj_type(a, b) ((int)(a[b].ob_type & 0xff))
#define ext_type(a, b) ((int)(a[b].ob_type >> 8))


#define X 0
#define Y 1

/* Linker Rand im Nachrichtenfenster */
#define MESSAGE_OFFSET 4

/* Tabulator Einheit in Pixeln */
#define P_TABWIDTH 8

/* Eigen-Format Replacements */
#define RP_CR	0
#define RP_CRLF 1
#define RP_SPC 2
#define RP_MIN 3
#define RP_TAB 4

#define FIRST_FAT 5

/* Setup */

#define SETUP_VERSION 4

typedef struct
{
	long	magic;			/* 'IOSU' */

	int		version;		/* Setup-version (4) */
	long	set_size;		/* Setup-Grîûe */	
	
	int	wx,wy,ww,wh;	/* Fensterpos */
	int	ewx,ewy,eww,ewh;	/* Fensterpos-Editor */

	int	hide_list;		/* Volle Nachrichtengrîûe */
	int	hide_msg;			/* Volle Listengrîûe */
	int	from_len;			/* AnzeigenlÑnge Absender */
	int	subj_len;			/* AnzeigenlÑnge Betreff */

	int	view_mask;		/* Alle/eigene... wie MenÅ */

	int	sort_by;			/* ABS/BTR/DAT */
	int	s_up_down;		/* auf/absteigend */

	int	list;					/* Angezeigt: 0=Pers, 1=ôff, 2=Ord, 3=Del */
	/* 1 und 2 bleiben auch dann erhalten, wenn Ordner/Gruppe
		geîffnet wird und die Nachrichten angezeigt werden.
		Unterscheidung der Liste:
		Wenn ((fld!=NULL) && (fld[0].ftype==FLD_BAK)) dann Nachrichten
		else öbersicht
	*/

	char	atx_save_path[256];	/* Speicherpfad fÅr Anhang */
	char	atx_load_path[256];	/* Ladepfad fÅr Anhang (Editor) */
	char	file_open_path[256];	/* MenÅ: Datei/ôffnen */
	char	file_merge_path[256];	/* MenÅ: Datei/Hinzuladen */
	char	file_save_as_path[256]; /* MenÅ: Datei Sichern/unter */

	long	list_off;		/* Aktueller Offset in Index-Liste */
	long	list_sel;		/* Selektierte Nachricht */
	int		teiler;			/* x-Pos. */

	char		autotausch;	/* Beim Start automatisch Tauschen */
	char		autoicon;		/* Falls nîtig IConnect starten */
	char		autodial;		/* ...und einwÑhlen */
	
	char		pllrequest;	/* PM-Length-Limit Nachfragen */
	int			pllsize;		/* PM-Length-Limit in KB */
	char		server_del;	/* PMs auf dem Server lîschen */

	
	int			newslist_days;	/* Alle x Tage nach neuen Groups fragen */
	char		news_head;			/* Nur Header laden */
	char		news_new;				/* Nur neue laden: */
	int			news_num;				/* und zwar so viele */

	char		headinfo[130];	/* Header-Felder in Nachricht anzeigen, ","-getrennt */
	
	char		sig1[1024];
	char		sig2[1024];
	char		sig3[1024];
	
	int		lfid;				/* Listen Font */
	int		lfsiz;			/* Grîûe in Punkt */
	int		lfhi;				/* Zeilenhîhe in Pixeln */
	int		lcol;				/* Hintergrundfarbe */
	int		lsndcol;		/* Farbe fÅr Versand */
	int		lsntcol;		/* Farbe fÅr versendet */
	int		lnewcol;		/* Farbe fÅr neue Nachrichten */
	int		lredcol;		/* Farbe fÅr gelesene */
	int		lubkcol;		/* Farbe fÅr unbekannt/Ordner & Gruppen */

	int		mfid;				/* Message-Font */
	int		mfsiz;
	int		mfhi;
	int		mcol;				/* Hintergrundfarbe */
	int		mtextcol;		/* Schriftfarbe */
	int		mcwidth[256];	/* Pixelbreite der Zeichen des aktuellen Fonts */
	int		m_tabspc;	/* Space-Breite eines Tabs */
	
	int		efid;				/* Editor-Font */
	int		efsiz;
	int		efhi;
	int		eqwi;				/* Quote-Zeichen Breite */
	int		ecol;				/* Hintergrundfarbe */
	int		etextcol;		/* Schriftfarbe */
	int		ecwidth[256];	/* Pixelbreite der Zeichen des aktuellen Fonts */
	
	int		ed_qcopy;		/* Quote-Zeichen (">") bei Bearbeiten/Kopieren mitkopieren */
	int		ed_tabspc;	/* Space-Breite eines Tabs */

	int		quotecol;		/* Quote-Farbe */
	int		urlcol;			/* URL-Farbe */
	
	/* Ab Version 2 */

	int		eyes_on;		/* Umbruch-Augen im Editor an(1)/aus(0) */
	int		sigeyes_on;	/* Umbruch-Augen im Signatur-Editor an(1)/aus(0) */
	
	/* FÅr Austausch-Start-Fenster: */
	int		om_exchange;	/* ôffentliche austauschen 0/!0 */
	int		pm_exchange;	/* Persînliche austauschen 0/!0 */
	int		show_pm_list;	/* Liste aller persînlichen anzeigen 0/!0*/
	
	int		cut_pers;			/* ZeilenlÑnge persînliche eingrenzen 0/1 */
	int		cut_pnum;			/* auf num Zeichen */
	int		cut_oeff;			/* ZeilenlÑnge îffentliche eingrenzen 0/1 */
	int		cut_onum;			/* auf num Zeichen */
	
	/* Ab Version 3 */
	char	msg_img_path[256];	/* Pfad fÅr Message-Pattern */
	char	lst_img_path[256];	/* Pfad fÅr List-Pattern */
	char	ed_img_path[256];		/* Pfad fÅr Editor-Pattern */
	
	int		ignore_crlf;				/* Original-Umbruch ignorieren 0/1 */
	
	int		anh_wx, anh_wy;			/* Koordinaten Anhang-Fenster, nur gÅltig, wenn anh_wy > -1 */
	int		anh_ww, anh_wh;			/* Arbeitsbereich Anhang-Fenster */
	int		anh_open;						/* Ist geîffnet j/n */
	
	int		mf2id;				/* Alternativer Message-Font */
	int		mf2siz;
	
	int		ef2id;				/* Alternativer Editor-Font */
	int		ef2siz;
	
	int		tausch_info;	/* Nach Tausch Info-Dialog zeigen 0/1 */
	
	int		auto_import;	/* Beim Starten Importieren 0/1 */
	
	int		real_smile;		/* Echte Smileys benutzten (1) oder Text (0) */
	
	int		all_text;			/* Jeden Text-Eintrag als Nachricht anzeigen, auch RTF etc.. */
	
	int		no_grp_msg_id;	/* Keine MSG-ID in Newsgroups */
	
	
	/* Ab Version 4 */
	
	int		permanent_reply;			/* Permanenten Reply-To setzen 0/1 */
	char	perm_reply_adr[66];		/* Reply-Adresse */
	int		perm_reply_in_groups;	/* auch in Newsgroups verwenden 0/1 */
	
	int		fake_news_from;				/* In Gruppen anderen Absender verwenden 0/1 */
	char	fake_news_adr[66];		/* Adresse dazu */
	
	int		show_sig_warning;			/* Warnung ab V2.1, daû andere Default-Signatur in Newsgroups, anzeigen 0/1 */
}IO_SETUP;

typedef struct
{
	long	offset;	/* In DBASE.DAT */
	long	size;		/* LÑnge in Bytes incl. INDEXER-Header */
	int		flags;	/* Anhang/Beantwortet etc., s. INDEXER.H */
}F_INFO;

typedef union
{
	char		fname[14];
	F_INFO	finfo;
}FILE_SPEC;

typedef struct
{
	FILE_SPEC	fspec;
	uint	ftime;			/* GEMDOS-Dateizeit */
	uint	fdate;			/* GEMDOS-Dateidatum */
	int		ftype;			/* Filetype, 0=Zu versenden (SND), 
																	1=Versandt (SNT), 
																	2=Neu (NEW), 
																	3=Gelesen (RED)
																	4=Unbekannt
																	5=".."
																	6=Folder
																	7=Group
										 */
	char	from[66];	/* Absender (auf 64 Zeichen mit Space gefÅllt) */
	char	subj[66];	/* Betreff (auf 64 Zeichen mit Space gefÅllt) */
	char	date[20];		/* Datum als TT.MM.JJJJ HH:MM*/

	long	idx;			/* Position (Index) in IDX-Datei oder -1, falls einzel-Datei */
	char	msg_id[66];
	char	in_reply_to[66];
	char	references[66];
	
	int		loc_flags;	/* local flags:
											Bit 0: Group containing new news 0/1 
											Bit 1: Message delayed 0/1
											Bit 2: Message is OM
											*/
	long	root_index;	/* Wird in eingeschrÑnkter Liste benutzt */
}FLD; /* File List Descriptor */

#define LF_UNREAD 1
#define LF_DELAYED 2
#define LF_OM 4

typedef struct _mail_atx
{
	char	mime_type[64];
	char	file_name[64];
	int		encoding;			/* 0=unknown/none, 1=7Bit,2=8Bit,3=Base64,4=Binary,5=quoted-printable */
	char	*atx;
	long	atx_len;

	struct	_mail_atx	*next;
}MAIL_ATX;	/* Mail Attachment */

typedef struct
{
	char	*header;
	long	head_len;

	char	*body;		/* ="loaded" (globale Variable) */
	long	body_len;	/* ="llen" */
	
	MAIL_ATX	*first;	/* Mail Attachments */
}LOADED_MAIL;

/* File types */
#define FLD_SND	0
#define	FLD_SNT	1
#define FLD_NEW	2
#define FLD_RED	3
#define FLD_NON	4
#define FLD_BAK	5
#define FLD_FLD	6
#define	FLD_GRP	7
#define FLD_GSD 8

typedef struct _ed_lin
{
	struct	_ed_lin	*next;
	int			quoted;	/* 0 oder 1 */
	char		*line;
}ED_LIN;

typedef struct _edit_ob
{/* Structur fÅr ein Editor-Fenster */
	struct _edit_ob	*undo;
	ED_LIN	*first;
	char		buf_line[1026];
	char		file[256];
	int			pm_om;	/* 0=PM, 1=News */
	char		references[256];
	char		reply_to[64];
	
	int	head_height;	/* Objekt-Hîhe des Adress-Headers */
	
	int	changed;
	
	long	max_x;	/* Merkt sich die Ñuûere X-Position bei reiner Cursor-Bewegung */
	long	cur_x;
	long	cur_y;
	long	offset;
	
	long	sel_sx, sel_sy, sel_ex, sel_ey;	/* Selektierter Bereich */
	
	int		cur_only;	/* FÅr Userdef: 1=Nur Cursor XOR zeichnen */
	
	int		edob;		/* Objektnummer des Edit-obs im Tree */
	int		crvis;	/* Formatzeichen sichtbar 0/1 */

	MAIL_ATX	*atx_first;	/* Mail Attachments */
}EDIT_OB;

typedef struct
{
	long	sel;
	long	offset;
	FLD		*flds;
	long	flds_c;
}FOLDER_DIAL;

/* Adressbuch.
	Aufbau: Normaler Text, endet mit 0.
	Jede Zeile enthÑlt:
	Name des Eintrags, Tab ($9) als Trennzeichen,
	alle eMail-Adressen fÅr diesen Eintrag mit Komma getrennt,
	beliebig viele CR/LF in beliebiger Kombination als Zeilentrenner.
	addr_cnt enthÑlt die Anzahl der EintrÑge.
 */
typedef struct
{
	long	sel;
	long	offset;
	char	*addr;
	long	addr_c;
	
	int		changes;
}ADDRESS_DIAL;
/*
	Gruppenliste:
	Jede Zeile enthÑlt einen Gruppennamen und {CR|LF}.
	Ist der erste Buchstabe groû, ist die Gruppe abonniert, sonst nicht.
	Die gesamte Liste ist in oaddr gespeichert, Teile ohne o enthalten
	die lokal eingeschrÑnkte Kopie.
*/
typedef struct
{
	long	offset;
	char	*addr;
	long	addr_c;

	char	*oaddr;
	long	oaddr_c;	
	int		changes;

	FLD		*flds;		/* Lokal eingerichtete Gruppen */
	long	flds_c;
}GROUP_DIAL;

typedef struct
{
	int		field;	/* 1=Absender, 2=EmpfÑnger, 3=Betreff */
	char	is[22];	/* Feld enthÑlt... */
	int		action;	/*  1=Nicht abholen, 
										2=abholen und einordnen (online)
										3=abholen und einordnen (offline)*/
	long	subact;	/* fÅr action=1: 1=auf Server lîschen, 2=nicht lîschen
									 fÅr action=2/3: Nummer des Ordners (=Filename!)*/
	char	fname[66];	/* fÅr action=2/3: Name des Ordners (=Alias) */
}S_FILTER;

typedef struct
{
	long		sel;
	long		offset;
	S_FILTER	*addr;
	long		addr_c;
	long		pop3ex;
	
	int			changes;	
}FILTER_DIAL;
/* -------------------------------------- */
/* Globals */

/* Screengrîûe */
extern int	sx,sy,sw,sh;

/* Hauptfenster */
extern WINDOW	wdial, wfolder, waddress, wgroup, wfilter;
extern DINFO		ddial, dfolder, daddress, dgroup, dfilter;
extern OBJECT	*odial, *omenu, *ovorl, *ofolder, *oaddress, *ogroup, *ofilter;

/* Pattern MFDBs */
extern MFDB msg_img, lst_img, ed_img;

/* MFDB auf CR-Imageblock */
extern MFDB	crmfdb;
/* MFDB auf TAB-Imageblock */
extern MFDB tabmfdb;

/* Datenbankpfad im Format X:\BLABLA\LALALA\DATABASE */
/* (also ohne abschlieûenden Backslash */
extern char		db_path[256];
/* Ordner-Name der aktuell angezeigten Mail-Liste */
/* z.B. "1", falls die Gruppe im Ordner 1 angezeigt wird */
extern char		act_fold[16];

/* Zeiger auf Array mit fld_c EintrÑgen, das die aktuell */
/* angezeigte Liste beschreibt (oder NULL) */
/* _bak enthÑlt die volle Liste, falls aktuell Teile */
/* ausgeblendet werden */
extern FLD			*fld, *fld_bak;
extern long			fld_c, fld_c_bak;

/* Selektion im Mail-Anzeige-Fenster
lines fangen bei 0 an, Zeichen bei 1. Wenn sel_sl=-1, dann keine Selektion.
Zeichen 0 bedeutet: Kein Zeichen in Endzeile selektiert. 
FÅr Startzeile sind c 0 und 1 das gleiche */
extern long			sel_sl, sel_sc, sel_el, sel_ec; 

/* Geladene Nachricht: */
extern LOADED_MAIL	loadm;
extern char			*loaded;	/* Zeiger auf Speicherbereich */
/* LÑnge in Bytes, Anzahl Zeilen und Offset der Anzeige */
extern long			llen, llines, lloff;

/* Globales Setup */
extern IO_SETUP	ios;

extern int sw_mode;	/* In S/W gestartet */

extern int db_mode;	/* Einzeldatei(0)- oder Datenbank(1)-Modus */
/* Infos fÅr Verwalten-Dialoge */
extern FOLDER_DIAL	fld_inf;
extern ADDRESS_DIAL	adr_inf;
extern GROUP_DIAL		grp_inf;
extern FILTER_DIAL	fil_inf;
/* -------------------------------------- */
/* Protos */

/* Main */
char *gettext(int ob);
int		getlen(int ob);
void	set_abs_btr_dat(void);
void	list_slide_set(void);
void	mail_slide_set(void);
void	switch_list(int res);
void	double_click(int x, int y);
int		actize_mail(char *path);
void	actize_om_sndlst(void);

/* Editor */
WINDOW	*open_editor(void);
void	do_editor(WINDOW *win, int ob);
void	ed_do_double(WINDOW *win);
void	objc_xted255cpy(OBJECT *tree, int ob, char *c);
void	set_file(EDIT_OB *edob, int pm_om);
void	edit_nachricht(void);
void	nachricht_an(char *to, char *cc, char *bcc, char *subj);
void	beantworten(void);
void	beitrag(void);
void	eclosed(WINDOW *win);
void	w_edit_input(WINDOW *win, int swt, int key);
void	w_ed_paste(WINDOW *win);
void	w_ed_copy(WINDOW *win);
void	w_ed_cut(WINDOW *win);
void	w_ed_selall(WINDOW *win);
void	w_ed_merge(WINDOW *win);
void	umbrechen(WINDOW *win);
void	editor_slide_set(WINDOW *win);
ED_LIN *get_ed_lin(EDIT_OB *eo);
void	quote(void);
void	ed_extent(char *c, int *ex);
void	ed_adr_compress(char *buf);
void	edit_search(WINDOW *win);
int		ed_save_mail(WINDOW *win);
void	ed_save_as(WINDOW *win);
void	ed_open_file(void);
int		ed_check_open(void);
void	ed_new_file(void);

/* Textutil */
void	format_loaded(int n);
long	lstrlen(char *c);
int		lstrcpy(char *dst, char *src);
void	lv_gtext(int vhandle, int *clipxy, int x, int y, char *c, int fcolor);
void	url_v_gtext(int vhandle, int *clipxy, int px, int py, char *c, int fcolor, void (*extend)(char *c, int *xy));
void	clip_url(void);
void	mail_copy(void);
void	mail_selall(void);
void	mail_extent(char *c, int *ex);
char	*stristr(char *src, char *search);
int		strmnicmp(char *src, char *dst);
char *lstristr(char *src, char *search);
char *lstrstr(char *src, char *search);
char *itoa2(int a, char *t);

void	main_search(void);
void	asuchen(void);
void	suchen(void);

void	date_popup(WINDOW *win, int dst_ob);

/* Loaders */
void load_act_list(void);
void reload_act_list(void);
int	 load_folders(int check_unread);
int	 load_groups(void);
void load_mail(void);
int	 load_mail_to(LOADED_MAIL *loads);
void load_new_list(void);
void free_loaded_mail(void);
void free_mail(LOADED_MAIL *loadm);
int  split_loaded(char *loaded, long llen, LOADED_MAIL *loadm, int cr2zero);
void extract_head(int ftype, char *c, char *from, char *subj);
void make_ascii_fdate(char *text, uint date, uint time);
void make_list_adr(char *dst, char *src);

/* Fileutil */
char	*suffix(char *filename);
int		get_folders(FLD **fl, long *flc);
int		get_groups(FLD **fl, long *flc);
int		fld_popup(FLD *fl, long flc);
int		group_popup(char *grp, long grp_c);
void	reload_actual(void);
void	zurueckhalten(void);
void 	interessant(void);
void	loeschen(void);
void	verschieben(void);
char *get_free_file(char *path);
void	dbsearch(void);
void	weiterleiten(void);
void	aufraeumen(void);
void	add_to_fld(char *fname, uint time, uint date, char *from, char *subj);
void	remove_from_fld(char *fname);
void	remove_file_from_list(char *path);
void	remove_sel_from_list(void);
void	ord_act_mail(int fold_ix);

/* Foldutil */
int		fld_check_ignore(long fld_nr);
void	refresh_folders(void);
int		load_inf_folders(void);
void	folder_dial(void);
void	dial_folder(int ob);
int 	delete_folder(FLD *fl, long fld_len, long sel);
void	fld_set_dial(void);


/* Viewmode */
void	sort_by_date(void);
void	sort_by_from(void);
void	sort_by_subj(void);
void	sort_by_sel(void);
int		view_own(void);
int		view_snd(void);
int		view_snt(void);
int		view_rcv(void);
int		view_red(void);
int		view_new(void);
void	view_by_sel(void);
void	fold_view(void);
void	list_view(void);
void	pm_list_view(void);
void	om_list_view(void);
void	snd_list_view(void);
void	rcv_list_view(void);
void	act_mail_list_view(void);
void	mem_list_sel(void);
void	unmem_list_sel(void);

/* inits */
void	init_setup(void);
void	init_info_rsrc(void);
int		init_dbase(void);
void	rsrc_init(void);
void	win_init(void);
int		check_reg(void);

/* userdef */
int		wind_gtop(void);

int		cdecl user_ob(PARMBLK	*pblk);

int		cdecl usr_liste(PARMBLK *pblk);
int		cdecl usr_mail(PARMBLK *pblk);
int		cdecl usr_editor(PARMBLK *pblk);
int		cdecl col_field(PARMBLK *pblk);

int		w_ibut_sel(int ob);
void	w_ibut_unsel(int ob);
void	w_wo_ibut_unsel(WINDOW *wdial, int ob);
int		w_wo_ibut_sel(WINDOW *wdial, int ob);

/* Obutil */
char	 *gettext(int ob);
int			getlen(int ob);
OBJECT *getob(int ob);
void		clear_sort_obs(void);
void		clear_view_obs(void);

/* Mailutil */
char	*get_head_field(char *f);
void	decode_quoted_printable(char *c);
long	decode_base_64(char *s);
void	decode_iso_8859_1(char *d);
void	atx_select(void);
int		count_atx(MAIL_ATX *atx);
long	atx_maxlen(MAIL_ATX	*atx);
int		save_mail(WINDOW *win);
int		save_mail_as(char *path, WINDOW *win);
void	show_orgfile(void);
void	show_original(void);
void	save_original_as(void);

/* Addrbook */
int		load_addrbook(void);
void	address_dial(WINDOW *caller);
void	dial_address(int ob);
void	do_adr_double(int ob);
char	*get_adrname(long a);
char	*get_adradr(long a);
long	get_index(char *name);
int		adr_resolve(char *adr, char **res);
char	*adr_match(char *adr);
void	put_abs_to_adrbook(void);

/* Grputil */
int		load_grouplist(void);
void	group_dial(void);
void	dial_group(int ob);
char *get_group_name(long ix);
long	make_group(char *name);

/* Filtutil */
int		load_filters(void);
void	filter_dial(void);
void	dial_filter(int ob);
void	reload_filter_folders(void);
void	add_to_fld(char *fname, uint time, uint date, char *from, char *subj);
void	ord_by_filter(void);

/* Set-Dials */
void redraw_edit_wins(void);
void set_internet(void);
void set_farbe(void);
void set_anzeige(void);
void set_sig(void);
void set_dbase(void);
void set_adresses(void);

/* Fsel */
int		f_input(char *spruch, char *path, char *name);
int		f_sinput(char *spruch, char *path, char *name);
void	make_path(char *com, char *path, char *name);

/* Formpop */
int	form_popup(OBJECT *poproot, int x, int y);


/* online */
void online(void);
void send_now(char *file);

/* ls_setup */
int load_setup(void);
int save_setup(void);