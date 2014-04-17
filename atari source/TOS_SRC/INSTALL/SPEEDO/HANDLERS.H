/* PROTOTYPES
 * ================================================================
 */
void	do_main( void );
void	CheckExit( void );

void	do_keybd( int kstate, int kreturn, int *event );
void	do_buttons( int mx, int my, int nclicks, int *event );
void 	do_window( int *msg, int *event );
void	CrossDraw( GRECT *rect );
void	SetNewDialog( OBJECT *newtree );

void	do_redraw( int *msg );
void	Do_Redraw( OBJECT *xtree, GRECT *area );

void	do_cross_draw( OBJECT *tree, int obj );
void	DoCopy( char *fname );


/* DEFINE
 * ================================================================
 */
typedef struct _pnode
{
    char name[21];
    char mname[21];
    char fname[15];
}PNODE;


/* EXTERNS
 * ================================================================
 */
EXTERN OBJECT *tree;			/* Main tree Global Variable */
EXTERN OBJECT *ad_newtree;		/* Background tree	     */
EXTERN OBJECT *ad_intro;		/* Intro dialog box	     */
EXTERN OBJECT *ad_tree;
EXTERN OBJECT *ad_path;			/* Dest Path dialog Box   */
EXTERN OBJECT *ad_driver;
EXTERN OBJECT *ad_fonts;		/* Fonts Dialog box	     */
EXTERN OBJECT *ad_apps;			/* application dialog box    */
EXTERN OBJECT *ad_submenu;
EXTERN OBJECT *ad_insert;
EXTERN OBJECT *ad_complete;
EXTERN OBJECT *ad_assign;
EXTERN OBJECT *ad_extend;
EXTERN OBJECT *ad_epath;

EXTERN int    wid;

EXTERN int    gl_gdos;
EXTERN char   gl_disk_string[][128];
EXTERN int    gl_numdisks;
EXTERN int    gl_printer;
EXTERN int    gl_num_printers;
EXTERN int    gl_assign;
EXTERN int    gl_extend;

EXTERN int    gl_meta;
EXTERN int    gl_mem;

EXTERN int    gl_scalable;
EXTERN int    gl_fonts;
EXTERN int    gl_nb15;
EXTERN int    gl_slm;
EXTERN int    gl_fx80;

EXTERN int    gl_cpx;
EXTERN int    gl_acc;
EXTERN int    gl_pageomat;
EXTERN PNODE  MenuNode[];
