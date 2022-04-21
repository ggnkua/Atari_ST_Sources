/*****************************************************************************/
/*                                                                           */
/* Modul: MGLOBAL.H                                                           */
/* Datum: 15/05/91                                                           */
/*                                                                           */
/*****************************************************************************/

#ifndef __MGLOBAL__
#define __MGLOBAL__

/****** DEFINES **************************************************************/

#define DESK          0                   /* Window-Handle/classe du bureau comme objet */
#define RC            2                   /* Coordonn‚es graphiques */

#define FONT_SYSTEM   1                   /* GEM System Font */
#define FONT_SWISS    2                   /* Swiss Font */
#define FONT_DUTCH   14                   /* Dutch Font */

#ifndef max
#define max(a,b)    (((a) > (b)) ? (a) : (b)) /* Maximum-Funktion */
#define min(a,b)    (((a) < (b)) ? (a) : (b)) /* Minimum Funktion */
#endif

/****** TYPES ****************************************************************/

typedef struct
{
  WORD    mox;                            /* souris-X-Position */
  WORD    moy;                            /* souris-Y-Position */
  WORD    momask;                         /* Masque souris */
  WORD    mobutton;                       /* bouton souris lev‚/cliqu‚ */
  WORD    kstate;                         /* Status de la touche Shift */
  UWORD   kreturn;                        /* Keycode of Event-Keyboard */
  WORD    breturn;                        /* nombre de clics */
  WORD    ascii_code;                     /* ASCII-Code from Keypress */
  WORD    scan_code;                      /* Scan-Code from keypress */
  BOOLEAN shift;                          /* avez-vous appuy‚ sur shift ? */
  BOOLEAN ctrl;                           /* avez-vous appuy‚ sur Cntrl ? */
  BOOLEAN alt;                            /* avez-vous appuy‚ sur Altrn ? */
} MKINFO;                                 /* Mouse-Key-Info */

typedef struct
{
  WORD x;                                 /* X-coordonn‚es */
  WORD y;                                 /* Y-coordonn‚es */
  WORD w;                                 /* Largeur */
  WORD h;                                 /* Hauteur */
} RECT;

/****** VARIABLES ************************************************************/

extern WORD    vdi_myhandle;              /* Virtual Workstation Handle */

extern WORD    *my_mousnumber;            /* actual Mausnumber */
extern MFORM   **my_mousform;			  /* pointeur de la forme de la souris */
extern BOOLEAN *Grow;                     /* Grow/Shrink activ‚e ? */

/****** FUNCTIONS ************************************************************/

VOID    myxywh2rect    _((WORD x, WORD y, WORD w, WORD h, RECT *rect));
BOOLEAN myrc_equal     _((CONST RECT *p1, CONST RECT *p2));
VOID    myrc_copy      _((CONST RECT *ps, RECT *pd));
BOOLEAN myrc_intersect _((CONST RECT *p1, RECT *p2));
VOID    myrc_union     _((CONST REG RECT *p1, REG RECT *p2));
VOID    rect2array   _((CONST RECT *rect, WORD *array));
VOID    xywh2array   _((WORD x, WORD y, WORD w, WORD h, WORD *array));
VOID    obj_rand     _((OBJECT *tree, WORD obj, RECT *r));

VOID    objc_rect    _((OBJECT *tree, WORD obj, RECT *rect, BOOLEAN calc_border));
VOID    set_ptext    _((OBJECT *tree, WORD obj, BYTE *s));
VOID    get_ptext    _((OBJECT *tree, WORD obj, BYTE *s));

VOID    line_default _((WORD vdi_myhandle));

VOID    mybeep         _((VOID));

VOID    do_state     _((OBJECT *tree, WORD obj, UWORD state));
VOID    undo_state   _((OBJECT *tree, WORD obj, UWORD state));
VOID    do_flags     _((OBJECT *tree, WORD obj, UWORD flags));
VOID    undo_flags   _((OBJECT *tree, WORD obj, UWORD flags));

VOID    mygrowbox      _((CONST RECT *st, CONST RECT *fin));
VOID    myshrinkbox    _((CONST RECT *fin, CONST RECT *st));

VOID    set_mouse    _((WORD number, MFORM *addr));
VOID    last_mouse   _((VOID));
VOID    hide_mouse   _((VOID));
VOID    show_mouse   _((VOID));
VOID    busy_mouse   _((VOID));
VOID    arrow_mouse  _((VOID));

#endif /* __MGLOBAL__ */
