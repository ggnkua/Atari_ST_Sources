/*
 *	WinEdit 2
 *	Routines d'‚dition de texte en fenˆtre GEM
 *	Bas‚ sur LIBTEDIT (par D.B‚r‚ziat)
 *  D.B‚r‚ziat 1998/1999
 *
 *	Interfacage LIBTEDIT avec WinDom
 *	D‚finition g‚n‚rales
 *
 *	Cette librairie doit remplacer la vieille
 *	librairie WINEDIT. Elle possŠde une nouvelle
 *	structure en m‚moire du texte plus robuste.
 *	L'ensemble des sp‚cificit‚s de WINEDIT n'est
 *	pas encore adapt‚, un peu de patience :).
 */

#include <libtedit.h>

#define SHOWTAB 	0x01
#define READONLY	0x02
#define CHANGED		0x04
#define CURFLASH	0x08
#define BLOC		0x4000
#define CURSON		0x8000

#define FLG_ON		1
#define FLG_OFF		2
#define FLG_INV		3

#define WES_FLAGS	1
#define	WES_EDIT	2
#define WES_TXTATTR	3
#define WES_CURATTR 4
#define WES_BLCATTR	5
#define WES_EDITKEY	6
#define WES_TABSIZE	7
#define WES_CURDRAW	8
#define WES_BLCMARK	9

#define WPRTF_TOP			0x1
#define WPRTF_OPEN			0x2
#define WPRTF_UNICONIFY		0x4

WINDOW *WeditCreate		( int attrib, EDIT *edit);
int		WeditSet		( WINDOW *win, int mode, ...);
int		WeditGet		( WINDOW *win, int mode, ...);

WINDOW *wprintf_init	( int watt, int x, int y, int w, int h, int mode);
void 	wprintf_exit	( WINDOW *win);
void 	wprintf			( WINDOW *win, const char *format, ...);

/* Fonctions texte haut-niveau  
 */

EDIT*wedit_get			( WINDOW *win);

/* Edition */
void wedit_insert_char	( WINDOW *win, char c);
void wedit_newline		( WINDOW *win);
int  wedit_delete_char	( WINDOW *win);
void wedit_insert_string( WINDOW *win, char *string);
int wedit_delete_line	( WINDOW *win);
int wedit_delete_end_line( WINDOW *win);
int wedit_allowed_char	( WINDOW *win, char c);

/* Positionnement du curseur */
void wedit_curs_top		( WINDOW *win);
void wedit_curs_bottom	( WINDOW *win);
void wedit_curs_left	( WINDOW *win);
void wedit_curs_right	( WINDOW *win);
void wedit_curs_up		( WINDOW *win);
void wedit_curs_down	( WINDOW *win);
void wedit_curs_on		( WINDOW *win);
void wedit_curs_off		( WINDOW *win);
void wedit_curs_page_up	( WINDOW *win);
void wedit_curs_page_down( WINDOW *win);
void wedit_set_cursor	( WINDOW *win, int x, int y);

/* Gestion de bloc */
void wedit_selectbloc	( WINDOW *win);
void wedit_draw_bloc	( WINDOW *win, CURSOR *start, CURSOR *end);


/* Divers */
void wedit_setup_read	( WINDOW *win);

/* etc ... */

