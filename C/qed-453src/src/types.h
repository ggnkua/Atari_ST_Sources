#ifndef _qed_types_h_
#define _qed_types_h_


#define SETSIZE	32							/* Grîûe eines Sets in Longs */
#define SETMAX		(SETSIZE*32 - 1)		/* Maximale Elemente eines Sets */

typedef unsigned long	SET[SETSIZE];			/* Menge */

/*
 * Dateinamen, Pfade, Dateiauswahl 
*/
#define MAX_PATH_LEN	256
typedef char PATH[MAX_PATH_LEN];

#define MAX_NAME_LEN	64
typedef char FILENAME[MAX_NAME_LEN];

/* AufzÑhlnungtypen */
typedef enum {tos, unix, apple, binmode} LINEENDING;

typedef enum {Atari, Latin, Mac, PC, LaTeX, HTML, ASCII} UMLAUTENCODING;

typedef enum {POS_CHANGE, LINE_CHANGE, TOTAL_CHANGE, NOP_CHANGE, SCROLL_UP,
				  SCROLL_DOWN, MOVE_UP, MOVE_DOWN, BLK_CHANGE, WT_CHANGE} CHANGE;

typedef enum {FALSE, TRUE} bool;

typedef struct                                                                
{                                                                             
	long	x;                                                              
	long	y;                                                              
	long	w;                                                              
	long	h;                                                              
} LRECT;                                                                      

#define MUSTER_LEN	7

typedef struct
{
	char			muster[MUSTER_LEN + 1];	/* Datei-Maske */
	bool			tab;
	int			tabsize;
	bool			einruecken;
	bool			umbrechen;
	bool			format_by_load;
	bool  		format_by_paste;
	int			lineal_len;
	char			umbruch_str[35];
	SET			umbruch_set;
	bool			backup;
	char			backup_ext[4];
	PATH			kurzel;
	char			wort_str[34];
	SET			wort_set;
	bool			show_end;
} LOCOPT, *LOCOPTP;


typedef struct _zeile
{
	struct _zeile 	*vorg;
	struct _zeile 	*nachf;
	char				info;
	int				len;					/* LÑnge in Bytes */
	bool				is_longest;
	int				exp_len;				/* expandierte LÑnge */
} ZEILE, *ZEILEP;


typedef struct
{
	ZEILE				head;
	ZEILE				tail;
	long  			lines;
	LINEENDING		ending;				/* Zeilenende */
	unsigned short	max_line_len;		/* Maximale ZeilenlÑnge */
} RING, *RINGP;


typedef struct _text
{
	struct _text 	*next;
	int				link;					/* Fensterhandle */
	RING				text;					/* Der Text */
	long				file_date_time;	/* Datei-Datum und Zeit */
	ZEILEP			cursor_line;      /* zeigt auf aktuellen Textzeile */
	int				xpos;            	/* x-Position des Cursors im Text */
	long				ypos;					/* y-Position des Cursors im Text */
	long				moved;				/* Text wurde seit letztem Sichern verÑndert */
	ZEILEP			p1,p2;				/* Zeiger fÅr Block */
	long				z1,z2;				/* ZeilenNr. fÅr p1 und p2 */
	int				x1,x2;				/* X-Pos fÅr Block-Anfang und Ende */
	bool				cursor;				/* Cursor anzeigen */
	bool				block;				/* Es gibt einen Block */
	bool				blink;				/* Cursor ist gerade wg. Blinken aus */
	bool				block_dir;			/* Blockrichtung laut Eingabe */
	bool				up_down;				/* War letzte Operation Up oder Down */
	bool				blk_mark_mode;		/* Block wird durch Cursor aufgezogen */
	bool				readonly;			/* Datei auf Disk schreibgeschÅtzt */
	int				desire_x;			/* FÅr UP und DOWN in [TASTEN] */
	char				info_str[256];		/* Text, der im Fenster-Info ausgegeben wird */
	PATH				filename;			/* Name der Datei */
	int				filesys;				/* Ergebnis von fs_case_sens(filename) */
	bool				namenlos;			/* Datei hat noch keinen Name */
	LOCOPTP			loc_opt;				/* Zeiger auf lokalen Optionen */
	long				asave;				/* letzter Autosave (min) */
	ZEILEP			max_line;			/* lÑngeste Zeile */
} TEXT, *TEXTP;

typedef void (*TEXT_DOFUNC)(TEXTP t_ptr);

#define WINSTRLEN	128
typedef struct _window
{
	struct _window	*next;
	int				class;				/* Klasse des Fensters */
	int				init;					/* Nummer des Fensters fÅr die Konfig */
	int				handle;				/* Handle fÅr Fenster */
	int				kind;					/* Art des Fensters */
	int				flags;				/* Flags des Fensters */
	LRECT				doc;					/* Position und Grîûe des Dokumentes */
	int				xfac;					/* X-Factor des Dokumentes */
	int				yfac;					/* Y-Factor des Dokumentes */
	int				w_width;				/* Fensterbreite in Einheiten */
	int				w_height;			/* Fensterhîhe in Einheiten */
	GRECT				work;					/* Arbeitsbereich */
	char				title[WINSTRLEN];	/* Titel des Fensters (mit ' ' und '*') */
	char				info[WINSTRLEN];	/* Infozeile des Fensters */
	int				icon_x, icon_y;	/* Position des Icons */
	GRECT				old_size;			/* Absolute Grîûe vor dem Iconify */

	void				(*draw)			(struct _window *window, GRECT *d);
	void				(*snap)			(struct _window *window, GRECT *new, int mode);
	void				(*click)			(struct _window *window, int m_x, int m_y, int bstate, int kstate, int breturn);
	void				(*unclick)		(struct _window *window);
	bool				(*key)			(struct _window *window, int kstate, int kreturn);
	void				(*top)			(struct _window *window);
	void				(*ontop)			(struct _window *window);
	void				(*untop)			(struct _window *window);
	void				(*bottom)		(struct _window *window);
	void				(*close)			(struct _window *window);
	void				(*iconify)		(struct _window *window);
	void				(*uniconify)	(struct _window *window);
} WINDOW, *WINDOWP;

typedef void (*WIN_DOFUNC)(WINDOWP w);
typedef void (*WIN_CRTFUNC)(WINDOWP w);

typedef struct 
{
	char	name[9];		/* GEM-Name der Shell */
	PATH	makefile;
} SHELLENTRY;


typedef struct _posentry
{
	struct _posentry	*next;
	PATH					filename;
	long					zeile;
	int					spalte;
} POSENTRY;

#endif
