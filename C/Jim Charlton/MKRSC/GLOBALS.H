
#ifndef TRUE
#define TRUE		1
#define FALSE		0
#define WI_KIND		(CLOSER|NAME)
#define MIN_WIDTH  100
#define MIN_HEIGHT  100
#define MAXONUM		100
#endif 
  
#ifndef __GNUC__	/* see aes/vdi bind.h */
extern int contrl[12];
extern int intin[256],  ptsin[256];
extern int intout[256], ptsout[256];
extern int gl_apid;
#endif
  
extern int	xdesk,ydesk,hdesk,wdesk;
extern int	xold,yold,hold,wold;
extern int	xwork,ywork,hwork,wwork;	/* desktop and work areas */

extern int	gl_hchar;
extern int	gl_wchar;
extern int	gl_wbox;
extern int	gl_hbox;	/* system sizes */

extern MFDB source;

extern OBJECT *mkrscmnu;       /* objects from resource file */
extern OBJECT *buttont;
extern OBJECT *oldtree;
extern OBJECT *tist;
extern OBJECT *boxct;
extern OBJECT *treicont;
extern OBJECT *obicont;
extern OBJECT *mnuicont;
extern OBJECT *namobjt;
extern OBJECT *dummnu;
extern OBJECT *mtbox1;
extern OBJECT *newtree;
extern OBJECT *boxt;
extern OBJECT *aboutt;
extern OBJECT *sortd;
extern OBJECT *newtop;


typedef struct _objtree {
	int				kind[MAXONUM];		/* kind of maintree icon	*/
	char			name[MAXONUM][30];	/* name of objects in tree	*/
	char		strings[MAXONUM][60];	/* obj strings				*/
	char		template[MAXONUM][60];	/* obj strings				*/
	char		valid[MAXONUM][60];		/* obj strings				*/
	ICONBLK			icblk[MAXONUM];		/* icon block array			*/
	TEDINFO			ti[MAXONUM];		/* tedinfo array			*/
	int				count;				/* number of objects in tree*/
	int				mbox;				/* active drop menu if any	*/
	OBJECT			objt[MAXONUM];		/* max number obj = 100     */
	struct _objtree	*treelink[MAXONUM]; /* links to subtrees		*/
} objtree;
typedef objtree *objtreeptr;

typedef struct _oneobj {
	int				okind;		/* kind of maintree icon	*/
	char			oname[30];	/* name of object			*/
	char		ostrings[60];	/* obj string				*/
	char		otemplate[60];	/* obj string				*/
	char		ovalid[60];		/* obj string				*/
	ICONBLK			oicblk;		/* icon block array			*/
	TEDINFO			oti;		/* tedinfo array			*/
	OBJECT			oobjt;
	struct objtree	*otreelink; /* links to subtree		*/
} oneobj;
typedef oneobj *oneobjptr;

/*
	Window definition.
*/
typedef struct _windowrec {
	struct _windowrec	*next;		/*  Window link						*/
	int					wihandle;	/* Window Handle					*/
	int					vslidepos;	/* vertical slider position			*/
	char				title[30];	/* Title of window					*/
	GRECT				box;		/* Window Box dimensions			*/
	GRECT				work;		/* Window content region dimensions	*/
/************************************************************************/
	objtree				maintree;	/* menu, dialog, etc icons			*/
	objtreeptr			inwindow; 	/*  active window tree struct   	*/
	int					saved;		/*  has been saved to file?			*/				
} windowrec;
typedef windowrec *windowptr;

extern OBJECT	*onleft; /*  active object on left   */
extern OBJECT	tredesk[20];	/* new desktop	*/
extern OBJECT	mnudesk[20];	/* new desktop	*/
extern OBJECT	obdesk[20];		/* new desktop	*/
extern	int			hightreadr;
extern	int			lowtreadr;
extern	int			highmnuadr;
extern	int			lowmnuadr;
extern	int			highobadr;
extern	int			lowobadr;

#ifdef extern
long _stksize = 0x6000L;
int	windowcount = 0;
char newtitle[80] = {NULL};
windowptr	firstwindow = NULL;       /* in MAIN.C these lines used  */
windowptr	thefrontwin = NULL;
char		fs_insel[40];
char		fs_inpath[40];
int 		iconum = 0;
objtreeptr	tempm = NULL;
objtreeptr	temps = NULL;
int			spaste = FALSE;
int 		snap = 0;
int			cout = 0;
#else
extern	long	_stksize;
extern	int		windowcount;
extern	char	newtitle[80];
extern	windowptr	firstwindow;
extern	windowptr	thefrontwin;
extern	char	fs_insel[];
extern	char	fs_inpath[];
extern	int			iconum;
extern	objtreeptr	tempm;
extern	objtreeptr	temps;
extern	int			spaste;
extern	int			snap;
extern	int			cout;
#endif

extern	oneobj	tempo;

extern int handle, rez; /* work station handle and resolution */
  
#ifndef __STDC__
extern char *malloc();
#endif
extern windowptr new_window();
extern windowptr findwindowptr();
extern objtreeptr	copy_tree();

  typedef union
  		{
  	struct 	{
#ifndef __GNUC__
  		unsigned bgcolor	: 4;
  		unsigned fillmode	: 3;
  		unsigned wrmode		: 1;
  		unsigned tcolor		: 4;
  		unsigned bdcolor	: 4;
#else
		unsigned bdcolor	: 4;
		unsigned tcolor		: 4;
		unsigned wrmode		: 1;
		unsigned fillmode	: 3;
		unsigned bgcolor	: 4;
#endif
  			} 	part;
  				int whole;
  		}	COLORINT;

typedef struct {
	char	mkstr[8];
	int		num;
} defstruct1;

typedef struct {
	int 	totree;
	int 	index;
	int 	type;
	char 	namestr[10];
} defstruct2;


/* debugging variables   */
  
extern char		*dumpadr;

#ifdef __STDC__
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include <memory.h>
#include <unixlib.h>
#include <aesbind.h>
#include <vdibind.h>
#endif

#ifdef __STDC__
# define	__P(s) s
#else
# define __P(s) ()
#endif


/* addsub.c */
int add_tosub __P((OBJECT *objptr , int nindex , int oindex , int x , int y ));
int hand_subtree __P((int clicks , int result , int mousex , int mousey ));
int dbl_clsub __P((int result ));

/* box.c */
int do_boxt __P((int result ));
int do_boxct __P((int result ));

/* button.c */
int do_button __P((int mousex , int mousey , int clicks ));
int find_parent __P((OBJECT *objptr , int result ));
int hand_maintree __P((int clicks , int result ));
int drag_left __P((int index ));
int add_lefticon __P((OBJECT *iconptr , int oindex , int rflag ));
int dbl_click __P((int index ));
 
/* def.c */
int make_def __P((char dname []));
int read_def __P((char dname []));

/* dialogs.c */
int do_buttont __P((int result ));
int do_tist __P((int result ));
 
/* drag.c */
int drag_right __P((int index , int mx , int my ));
int good_parent __P((OBJECT *objtree, int x, int y, int w, int h, int index));
int drag_menu __P((int index , int mx , int my ));

/* edit.c */
int erase_obj __P((void ));
int erase_tree __P((void ));
objtreeptr copy_tree __P((int deselect ));
int paste_tree __P((objtreeptr tempmain ));
int copy_obj __P((int deselect ));
int paste_obj __P((void ));

/* event.c */
int TaskMaster __P((void ));

/* header.c */
int save_file __P((long size , char *start ));
int make_hdr __P((char hname []));
int save_rsc __P((char rname [], long size , char *start ));
int getfile __P((windowptr thewin ));

/* init.c */
int init __P((void ));
int open_workstation __P((MFDB *form ));
int shutdown __P((int code ));
int cleanup __P((void ));
int init_path __P((void ));
int create_newtops __P((void ));

/* keys.c */
int do_update __P((int keycode , int keymod ));
int dump __P((char *addr , int count ));

/* main.c */
int main __P((void ));
int clear __P((void ));
int cursor __P((int x , int y ));

/* menu.c */
int do_menu __P((int *message ));
int handle_rot __P((void ));
int handle_desk __P((int itemid ));
int handle_file __P((int itemid ));
int handle_edit __P((int itemid ));
int handle_choose __P((int itemid ));
int do_sort __P((void ));
int sort_x __P((void ));
int sort_y __P((void ));
int sort_boxes __P((void ));

/* objutil.c */
int obj_changepos __P((OBJECT *obj , int x , int y ));
int obj_changewh __P((OBJECT *obj , int w , int h ));
int init_maintree __P((windowptr thewin ));
int draw_inwind __P((windowptr thewin, int blank ));
int do_dialog __P((OBJECT *dialog , int start_obj ));
int draw_obj __P((OBJECT *obj ));
int undraw_dial __P((OBJECT *dialog ));

/* prep.c */
int make_rsc __P((void ));
long calc_size __P((void ));
char *copy_strings __P((char *next , char *start , RSHDR *rsc_struct_ptr ));
char *copy_tis __P((char *next , char *start , RSHDR *rsc_struct_ptr ));
char *copy_obs __P((char *next , char *start , RSHDR *rsc_struct_ptr , long rs_trindex []));
char *copy_trindex __P((char *next , long rs_trindex []));
int fill_rsc_struct __P((RSHDR *rsc_struct_ptr ));
int fix_ptrs __P((RSHDR *rsc_struct_ptr , char *start ));

/* retrv.c */
int ret_rsc __P((void ));

/* tree.c */
int trav_tree __P((OBJECT *tree , int order [MAXONUM ]));
int not_already __P((int *order , int index , int head ));
int ord_tree __P((void ));
int newpos __P((int index , int numobjs , int order [MAXONUM ]));
int in_ttl __P((int x , int y , int paste ));
int tidy_m __P((void ));
int mv_ttl __P((int index , int x , int y ));
int name_obj __P((void ));
int check_name __P((char *str ));

/* wind.c */
int do_redraw __P((int message[]));
int set_clip __P((int x , int y , int w , int h ));
windowptr new_window __P((void ));
int open_window __P((windowptr thewin ));
int dispose_window __P((windowptr thewin ));
int dispose_win_resources __P((windowptr thewin ));
windowptr findwindowptr __P((int wihandle ));
int whiterect __P((windowptr thewin ));
int make_frontwin __P((windowptr thewin ));
int rot_wind __P((void ));
int update_win __P((int cx, int cy, int cw, int ch));

/* cout.c */
int make_cout __P((char cname []));
int wr_it __P((int fildes , char *str ));

#ifdef __GNUC__
void rect_set __P(( GRECT *r, int x, int y, int w, int h));
int max __P((int x, int y));
int min __P((int x, int y));
char *xtrcpy __P((char *dest, char *src));
#endif

#undef __P

#ifdef __GNUC__
static inline int max(int x, int y)
{
    return (x < y)? y : x;
}

static inline int min(int x, int y)
{
    return (x > y)? y : x;
}
#endif
