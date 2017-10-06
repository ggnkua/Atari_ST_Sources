/* GFGLOBAL.H zur GEM-Force-Library */

#ifndef __GFGLOBAL__
# define __GFGLOBAL__

# include <aes.h>

/************************* defines ***********************************/

# define NIL (-1)
# define DESK 0
# define RC  2					/* Raster-Koordinaten */
# define NDC 0					/* normalisierte Koordinaten */
# define FSMGDOS  0x5F46534D
# define FONTGDOS 0x5F464E54
# define TEDINFO(tree,ind) tree[ind].ob_spec.tedinfo
# define TE_PTEXT(tree,ind) tree[ind].ob_spec.tedinfo->te_ptext

# define SQUARED          0 /* line ends */
# define ARROWED          1
# define ROUNDED          2

# define FONT_SYSTEM   1                   /* GEM System Font */
# define FONT_SWISS    2                   /* Swiss Font */
# define FONT_DUTCH   14                   /* Dutch Font */

# define TXT_NORMAL       0x0000 /* text effects */
# define TXT_THICKENED    0x0001
# define TXT_LIGHT        0x0002
# define TXT_SKEWED       0x0004
# define TXT_UNDERLINED   0x0008
# define TXT_OUTLINED     0x0010
# define TXT_SHADOWED     0x0020

# define ALI_LEFT         0 /* horizontal text alignment */
# define ALI_CENTER       1
# define ALI_RIGHT        2

# define ALI_BASE         0 /* vertical text alignment */
# define ALI_HALF         1
# define ALI_ASCENT       2
# define ALI_BOTTOM       3
# define ALI_DESCENT      4
# define ALI_TOP          5

/************************* types ***********************************/

typedef struct
{
	int x, y, w, h;
} RECT;

typedef struct
{
	long x, y, w, h;
} LRECT;

typedef struct
{
	int     ascii_code;
	int     scan_code;
	BOOLEAN shift;
	BOOLEAN ctrl;
	BOOLEAN alt;
	int     kreturn;
	int     kstate;
} KEYINFO;

/************************* globals ***********************************/

GLOBAL RECT desk, clip;
GLOBAL int vdi_handle, phys_handle, tos, colors;
GLOBAL int gl_wbox, gl_hbox;			/* Zeichenbox */
GLOBAL int gl_wchar, gl_hchar;		/* Zeichen */
GLOBAL int gl_wattr, gl_hattr;		/* Fensterelemente */
GLOBAL int appl_id;
GLOBAL int blinkrate;
GLOBAL long gdos;
GLOBAL BOOLEAN grow_shrink, save_bg;
GLOBAL int mousenumber;               /* Aktuelle Mausform-Nummer */
GLOBAL MFORM *mouseform;                /* Aktuelle Mausform */

/************************* functions *********************************/

GLOBAL BOOLEAN init_gem ( void );
GLOBAL void exit_gem ( void );
GLOBAL BOOLEAN rsc_load ( char *, char * );
GLOBAL BOOLEAN init_tree ( int , OBJECT **, BOOLEAN );

GLOBAL void call_mortimer ( char * );

GLOBAL BOOLEAN select_file ( char *, char *, char *, char *, char * );
GLOBAL void divide_filename ( char *, char *, char * );

GLOBAL void dialog_on ( OBJECT * );
GLOBAL int do_dialog ( OBJECT *, int );
GLOBAL int form_dialog ( OBJECT *, int );
GLOBAL void dialog_off ( OBJECT * );

GLOBAL void set_mouse ( int, MFORM * );
GLOBAL void last_mouse ( void );
GLOBAL void hide_mouse ( void );
GLOBAL void show_mouse ( void );
GLOBAL void busy_mouse ( void );
GLOBAL void arrow_mouse ( void );

GLOBAL void do_state (OBJECT *, int, unsigned int );
GLOBAL void undo_state (OBJECT *, int, unsigned int );
GLOBAL void flip_state (OBJECT *, int, unsigned int  );
GLOBAL int find_state (OBJECT *, int, unsigned int );
GLOBAL BOOLEAN is_state (OBJECT *, int, unsigned int );

GLOBAL void do_flags (OBJECT *, int, unsigned int );
GLOBAL void undo_flags (OBJECT *, int, unsigned int );
GLOBAL void flip_flags (OBJECT *, int, unsigned int );
GLOBAL int find_flags (OBJECT *, int, unsigned int );
GLOBAL BOOLEAN is_flags (OBJECT *, int, unsigned int );

GLOBAL int find_type (OBJECT *, int, unsigned int );
GLOBAL void set_rbutton  (OBJECT *, int, int, int ); 
GLOBAL int get_rbutton  (OBJECT *, int ); 

GLOBAL void text_default ( void );
GLOBAL void line_default ( void );

GLOBAL void objc_rect ( OBJECT *, int, RECT *, BOOLEAN );

GLOBAL void bell( void );

GLOBAL void rect2array ( const RECT *, int * );
GLOBAL void array2rect ( const int *, RECT * );
GLOBAL void xywh2array  ( int, int, int, int, int *);
GLOBAL void array2xywh  ( const int *, int *, int *, int *, int *);
GLOBAL void xywh2rect ( int, int, int, int, RECT * );
GLOBAL void rect2xywh ( const RECT *, int *, int *, int *, int *);
GLOBAL BOOLEAN rc_intersect (const RECT *, RECT * );
GLOBAL BOOLEAN rc_equal ( const RECT *, const RECT * );
GLOBAL void rc_union ( const RECT *, RECT * );
GLOBAL BOOLEAN inside ( int, int, const RECT * );

GLOBAL void set_clip ( BOOLEAN, const RECT * );

GLOBAL BOOLEAN find_menu_item ( OBJECT *, KEYINFO *, int *, int * );
GLOBAL void get_keyinfo ( int, int, KEYINFO * );

GLOBAL void store_dial ( OBJECT * );
GLOBAL void restore_dial ( OBJECT * );

GLOBAL void set_te_ptext ( OBJECT *obj, int ind, const char *str );
GLOBAL void deselect_obj ( OBJECT *, int );

GLOBAL void draw_grow_shrink ( RECT *, int );

GLOBAL int popup_menu ( OBJECT *, int, int, int, int, BOOLEAN, int );

#endif /* __GFGLOBAL__ */
