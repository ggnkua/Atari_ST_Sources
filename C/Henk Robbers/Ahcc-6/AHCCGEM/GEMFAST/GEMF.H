/* tab expansion/compression should be set to 4 */
/**************************************************************************
 * GEMF.H - Header file for GEM programming.
 *
 *  This header file contains items compatible with both GEMDEFS and OBDEFS
 *  from the Alcyon system.  Note that there are no 'extern' definitions
 *  for the GEM functions, because they all return a signed int and work
 *  fine as autodefined functions.
 *
 * Maintenance:
 *  12/09/08 - > Henk Robbers.
 *               Use standard AES of the compiler.
 *               Every duplication in gemfast.h removed.
 *               Renamed to GEMF.
 *               Ported to Pure C & AHCC.
 *  02/29/92 - v1.8
 *             > Added new options for new utility functions.
 *             > Added extern declarations for all global vars.
 *             > Added macro to map frm_dsdial() to frm_dsdialog() with
 *               parms in the new order.
 *             > Added macros mapping appl_init/exit to apl_xinit/xexit,
 *               so that all aps automatically get new extended init that
 *               fills in the new global vars.  New utils REQUIRE that
 *               these vars be init'd; think twice before changing this!
 *             > Changed FDADDR datatype from char* to void*.
 *  05/26/90 - v1.4
 *             > Added RSHDR structure for imbedded resource support.
 *             > Fixed all structures which defined pointers as 'long'...
 *               - ICONBLK ib_pmask, ib_pdata, ib_ptext
 *               - BITBLK  bi_pdata
 *               - USERBLK ub_code
 *               - PARMBLK pb_tree
 *               All of these structure elements now define the proper ptr.
 *             > Added AESUTIL_A, AESFAST_A and VDIFAST_A symbols.  This
 *               allows specific indication of the presence or abscence of
 *               the bindings libraries, allowing a programmer to use the
 *               GEMFAST.H header without using the rest of GemFast.  This
 *               also allows conditional compilation code to be more
 *               specific:  it can now test for the presence of the header
 *               file (and handle the differences in the structure defs),
 *               and it can separately test for the presence of the libs,
 *               and the extended functions available therein.
 *  12/03/89 - v1.3
 *             > Renamed a lot of functions, a name compatibility block was
 *               added at the end of this file to smooth the transition.
 *             > Added NO_OBJECT, MU_MENTRY, MU_MEXIT to defines.
 *             > Added XMULTI struct, even though it really belongs to v2.0
 *************************************************************************/

#include <tos.h>
#include <stdarg.h>
#include <stddef.h>
#include <string.h>
#include <aes.h>
#include <vdi.h>

#include "frmtypes.h"

#ifndef GEMFAST_H               /* Prevent multiple inclusion */

#define GEMFAST_H       1       /* Tell the world GEMFAST header is used */
#define GEMF_VERSION    0x0180  /* Tell the world we are v1.80           */

#define AESUTIL_A       1       /* Tell the world AESFAST utils  available */
#define AESFAST_A       1       /* Tell the world AESFAST lib is available */
#define VDIFAST_A       1       /* Tell the world VDIFAST lib is available */

                                /* VDI inside fill styles  */
#define IS_HOLLOW   0
#define IS_SOLID    1
#define IS_PATTERN  2
#define IS_HATCH    3
#define IS_UDPTRN   4
                                    /* evnt_mouse options */
#define MU_MENTRY   0x0000
#define MU_MEXIT    0x0001
                                    /* rsrc_gaddr structure types */
#define ROOT        0               /* this name used by MWC */

#define BUSY_BEE    2
#define BEE         2
                                /* value returned by objc_find(), et. al. */
#define NO_OBJECT   -1
                                /* editable text field definitions */
#define EDSTART     0
#define EDINIT      1
#define EDCHAR      2
#define EDEND       3

/*-------------------------------------------------------------------------
 * a few miscellanious GemFast-defined constants...
 *-----------------------------------------------------------------------*/

#define GRF_MSALTARROW    200   /* alternate value of ARROW for grf_mouse() */
#define GRF_MSINQUIRE    (-1)   /* inquire current shape for grf_mouse()    */
#define OBJ_BMINQUIRE    (-1)   /* get w/o change from obj_bmbuttons()      */
#define FRM_GETDEFAULTS (-1L)   /* get w/o change from frm_defaults()       */
#define FRM_MOVER      0x4000   /* special ob_flags value for moveable forms*/

#define G_THERMO          200   /* ob_type for a thermometer display object */

#define OBJ_NODRAW          0   /* obj_XXchange(): no draw after change     */
#define OBJ_WITHDRAW        1   /* obj_XXchange(): do draw after change     */
#define OBJ_CLIPDRAW        2   /* obj_XXchange(): draw with optional clip  */

#define OBJ_TINQUIRE  (-32000)  /* inquire current G_THERMO position        */
#define OBJ_TINCREMENT    (-1)  /* increment current G_THERMO position by 1 */

#define FRM_DSMAXBUTTONS    5   /* max dynamic button strings               */
#define FRM_DSMAXSTRINGS   20   /* max dynamic dialog display strings       */

/*-------------------------------------------------------------------------
 * options for apl_whatever() functions...
 *-----------------------------------------------------------------------*/

#define APL_RTRANSIENT      0x0001  /* cleanup transient resources */
#define APL_RPERMENANT      0x0002  /* cleanup permenant resources */

/*-------------------------------------------------------------------------
 * actions for frm_desktop()...
 *-----------------------------------------------------------------------*/

#define FRM_DTINSTALL   0x00000000L  /* install form as system desktop      */
#define FRM_DTREMOVE    0x10000000L  /* remove form, revert to sys desktop  */

/*-------------------------------------------------------------------------
 * actions for frm_dialog()...
 *-----------------------------------------------------------------------*/

#define FRM_DSTART      0x10000000L  /* do FMD_START                        */
#define FRM_DDRAW       0x20000000L  /* do objc_draw()                      */
#define FRM_DDO         0x40000000L  /* do form_do()                        */
#define FRM_DFINISH     0x80000000L  /* do FMD_FINISH                       */
#define FRM_DCOMPLETE   0xF0000000L  /* do all the steps above in one call  */

/*-------------------------------------------------------------------------
 * actions for frm_progress()...
 *-----------------------------------------------------------------------*/

#define FRM_PSTART      0x10000000L  /* set up and display progress dialog  */
#define FRM_PUPDATE     0x40000000L  /* update progress thermometer         */
#define FRM_PFINISH     0x80000000L  /* close and cleanup progress dialog   */

/*-------------------------------------------------------------------------
 * options for all frm_whatever() functions...
 *   0xauddbbbb
 *     ||| |______ Basic options for all dialog handling.
 *     |||________ Dynamic dialog options.
 *     ||_________ User options; never touched by GemFast.
 *     |__________ Actions.
 *-----------------------------------------------------------------------*/

#define FRM_NORMAL          0x00000000L /* placeholder when you want none   */
#define FRM_EXPLODE         0x00000001L /* exploding box graphics in dialog */
#define FRM_CENTER          0x00000002L /* center dialog in screen          */
#define FRM_NEARMOUSE       0x00000004L /* center dialog over mouse         */
#define FRM_MOUSEARROW      0x00000008L /* force mouse ARROW during dialog  */
#define FRM_USEBLIT         0x00000010L /* use blits instead of redraw msgs */
#define FRM_MOVEABLE        0x00000020L /* dialog is moveable               */
#define FRM_NODEFAULTS      0x00008000L /* these options override defaults  */

#define FRM_DMUSTSELECT     0x00010000L /* dsdialog/dsmenu: no default exit */
#define FRM_DSHADOWED       0x00020000L /* dsdialog/dsmenu: shadowed parent */

#define FRM_DSL1TITLE       0x00100000L /* 1st line is title, higher y pos  */

#define FRM_MEXITPARENT     0x00100000L /* exit if mouse leaves parent      */
#define FRM_MEXITVICINITY   0x00200000L /* exit if mouse leaves vicinity    */

#define FRM_OPTIONBITS      0x0FFFFFFFL /* mask for dialog options          */
#define FRM_BOPTIONBITS     0x0000FFFFL /* mask for basic options           */
#define FRM_DOPTIONBITS     0x00FF0000L /* mask for dynamic options         */
#define FRM_UOPTIONBITS     0x0F000000L /* mask for user options            */
#define FRM_ACTIONBITS      0xF0000000L /* mask for dialog actions          */

/*-------------------------------------------------------------------------
 * option for fsl_dialog()...
 *-----------------------------------------------------------------------*/

#define FSL_NORMAL          0x0000
#define FSL_FNOPTIONAL      0x0001
#define FSL_PATHONLY        0x0002

/*-------------------------------------------------------------------------
 * options for grf_blit() and grf_memblit()...
 *-----------------------------------------------------------------------*/

#define GRF_NORMAL         0x0000  /* a placeholder value                */
#define GRF_BFROMSCREEN    0x1000  /* blit from screen to buffer         */
#define GRF_BTOSCREEN      0x2000  /* blit from buffer to screen         */
#define GRF_BMEMCALC       0x4000  /* calc mem requirements, don't blit  */
#define GRF_BOBJTREE       0x0001  /* rectparm OBJECT* instead of GRECT* */

/**************************************************************************
 * data structures and types...
 *************************************************************************/

/*-------------------------------------------------------------------------
 * FDB/MFDB structure (describes memory area for VDI blit)...
 *-----------------------------------------------------------------------*/

#ifndef FDADDR                  /* v1.3:  this define has been added to  */
  #define FDADDR void*          /* help provide compatibility between    */
#endif                          /* bindings systems.                     */

typedef MFDB FDB;

/*-------------------------------------------------------------------------
 * VRECT structure (a VDI-style rectangle, describes opposite corners)...
 *-----------------------------------------------------------------------*/

typedef struct vrect
{
    int v_x1;
    int v_y1;
    int v_x2;
    int v_y2;
} VRECT;

#define appl_blk user_blk

/*-------------------------------------------------------------------------
 * XUSERBLK (our internal extension to a standard USERBLK)...
 *-----------------------------------------------------------------------*/

typedef struct xuser_blk
{
	long cdecl		(*ub_code)(); /* the 1st two fields are USERBLK std, */
	struct xuser_blk *ub_self;    /* but ub_parm always points to self.  */
	void			 *reserved;   /* this will be used in v1.9  		 */
	long			  ub_size;    /* size of this XUSERBLK structure	 */
	long			  ob_spec;    /* ob_spec and ob_type are from the    */
	short   		  ob_type;    /* original object before we xformed   */
} XUSERBLK;

/*-------------------------------------------------------------------------
 * XPARMBLK structure (our renaming of a standard PARMBLK)...
 *-----------------------------------------------------------------------*/

typedef struct xparm_blk
{
	OBJECT   *ptree;
	int 	  obj;
	int 	  prevstate;
	int 	  currstate;
	GRECT     drawrect;
	GRECT     cliprect;
	XUSERBLK *pub;
} XPARMBLK;

typedef struct
{
	XUSERBLK xub;
	int 	 tick_limit;
	int 	 tick_count;
	int 	 tick_width;
	int 	 curr_width;
	int 	 full_width;
	int 	 fill_style;
	int 	 xoffset;
} ThermoInfo;

#define RSHDR_DEFINED 1 /* signal to other header files that RSHDR is done */

/*-------------------------------------------------------------------------
 * XMOUSE structure...
 *-----------------------------------------------------------------------*/

typedef struct xmouse
{
	int retval;
	int bclicks;
	int mask;
	int state;
	int status;
	int mousex;
	int mousey;
	int mouseb;
	int keystate;
} XMOUSE;

/*-------------------------------------------------------------------------
 * XMULTI structure...
 *-----------------------------------------------------------------------*/

typedef struct xmulti
{
	int msgbuf[8];
	int mflags,
	    mbclicks,
	    mbmask,
	    mbstate,
	    mm1flags;
	GRECT mm1rect;
	int  mm2flags;
	GRECT mm2rect;
	int mtlocount,
	    mthicount;
	int mwhich,
	    mmox,
	    mmoy,
	    mmobutton,
	    mmokstate,
	    mkreturn,
	    mbreturn;
} XMULTI;

/**************************************************************************
 * declarations for functions.
 *************************************************************************/

typedef void *(VPFUNC)(size_t size);
typedef void  (VFUNC)(void *block);

int 	apl_xinit		(void);
void *	apl_malloc		(size_t size);
void	apl_free		(void * block);
int 	apl_vshared		(void);
void	apl_mmvectors	(VPFUNC *newalloc, VFUNC *newrelease);
int 	apl_vopen		(void);
void	apl_vclose		(int vdi_handle);
void	apl_xexit		(void);

typedef struct parms
{
    short idx;
    OBJECT **pptree;
} Parms;

int 	rsc_cubuttons	(OBJECT *ptree);
int 	rsc_rrbuttons	(OBJECT *ptree);
void	rsc_sxtypes		(OBJECT *thetree, ...);
void	rsc_gstrings	(OBJECT *thetree, ...);
void	rsc_sstrings	(OBJECT *thetree, ...);
void cdecl rsc_gtrees		(int firstparm, ...);
void	rsc_treefix		(OBJECT *ptree);

int 	frmx_center		(OBJECT *ptree, GRECT *prect);
void	frm_cleanup		(FormControl *ctl);
void *	frm_init		(long options, OBJECT *ptree, GRECT *pboundrect);
void	frm_start		(FormControl *ctl);
void	frm_draw		(FormControl *ctl, int obj);
void	frm_finish		(FormControl *ctl);
void	frm_move		(FormControl *ctl);
int 	frm_do			(FormControl *ctl, int editobj);
int 	frm_mdo			(FormControl *ctl);
int 	frm_dialog		(long options, OBJECT *ptree, int object);
long	frm_defaults	(long options);
void *	frm_dovector	(void *newfunc);
void	frm_confine		(OBJECT *ptree, GRECT *boundrect);
int 	frm_mkmoveable	(OBJECT *ptree, int object);
int 	frmx_dial		(int flag, GRECT *plittle, GRECT *pbig);
int 	frm_dsdialog	(long options, char *pbuttons[], char *pstrings[]);
int 	frm_progress	(long options, int increments, char *buttons, char *fmt, ...);
int 	frm_qchoice		(char *buttons, char *fmt, ...);
int 	frm_printf		(long options, char *buttons, char *fmt, ...);
int 	frm_vprintf		(long options, char *buttons, char *fmt, va_list args);
int 	frm_qerror		(int err, char *fmt, ...);
int 	frm_verror		(int err, char *buttons, char *fmt, va_list args);
int 	frm_menu		(long options, OBJECT *ptree, int select_state);
int 	frm_nlmenu		(long options, char *title, char *strings);
int 	frm_qmenu		(char *title,char *strings);
int 	frm_dsmenu		(long options, char *title, char **strings);
void	frm_qtext		(char *fmt, ...);
int 	frm_question	(char *fmt, ...);
int 	frm_error		(int err, char *buttons, char *fmt, ...);
int 	frm_nldialog	(long options, char *buttons, char *strings);
int 	frm_eflag		(OBJECT *ptree, int obj, char *fmt, ...);
void	frm_desktop		(long options, OBJECT *ptree);
int 	fsl_dialog		(int options, char *pfullname, char *ppath, char *pwild, char *pprompt);

void	obj_mxuserdef	(XUSERBLK *pblk, OBJECT *pobj, void *pcode);
char **	obj_ppstring	(OBJECT *pobj);
int 	obj_clcalc		(OBJECT *ptree, int object, GRECT *pgrect, VRECT *pvrect);
void	obj_flchange	(OBJECT *ptree, int object, int newflags, int drawflag, GRECT *optional_clip);
void	obj_stchange	(OBJECT *ptree, int object, int newstate, int drawflag, GRECT *optional_clip);
void	obj_xywh		(OBJECT *ptree, int object, GRECT *prect);
void	obj_offxywh		(OBJECT *ptree, int object, GRECT *prect);
int 	obj_mkthermo	(OBJECT *ptree, int object, int nincr);
int 	obj_udthermo	(OBJECT *ptree, int object, int newpos, GRECT *pclip);
void	obj_mxuserdef	(XUSERBLK *pblk, OBJECT *pobj, void *pcode);
int 	obj_rbfind		(OBJECT *tree, int parent, int rbstate);
int 	obj_parent		(OBJECT *tree, int curobj);
int 	obj_rbselect	(OBJECT *ptree, int selobj, int state);
int 	obj_xtfind		(OBJECT *ptree, int parent, char xtype);
int 	obj_bmbuttons	(OBJECT *ptree, int parent, int selstate, int newbits);

int 	grf_mouse		(int shape, void *pform);
int 	grfx_dragbox	(GRECT *startrect, GRECT *boundrect, GRECT *endrect);
void *	grf_memblit		(int options, void *buffer, void *prect);
BLITFU	grf_blit;

GRECT *	rc_gadjust		(GRECT *prect, int xadjust, int yadjust);
VRECT *	rc_vadjust		(VRECT *prect, int xadjust, int yadjust);
void *	rc_copy			(void *psrce, void *pdest);
GRECT *	rc_vtog			(VRECT *pvrect, GRECT *pgrect);
VRECT *	rc_gtov			(GRECT *pgrect, VRECT *pvrect);
GRECT *	rc_union		(GRECT *prect1, GRECT *prect2);
GRECT *	rc_confine		(GRECT *pbound, GRECT *pdest);
int 	rc_intersect	(GRECT *prect1, GRECT *prect2);
int 	rc_ptinrect		(GRECT *prect, int x, int y);
GRECT *	rc_scale		(GRECT *psource, GRECT *pdest, int percentage);

int 	winx_get		(int whandle, int wfield, GRECT *prect);
int 	wnd_update		(int flag);
int 	wnd_top			(void);
int 	winx_calc		(int type, int kind, GRECT inrect, GRECT *poutrect);

int 	evnx_multi		(XMULTI *xm);

int 	mnu_bar			(void *menutree, int flag, long reserved);
void	mnu_disable		(void);
void	mnu_enable		(void);

/**************************************************************************
 * declarations of all global vars defined by gemfast...
 *************************************************************************/

/*
 * these are valid after appl_init()
 */

extern void   *aespb[6];        /* the AES parmblk, an array of 6 ptrs    */
extern int     aescontrol[5];   /* the AES control structure, 5 ints      */
extern int     global[];        /* global[] is aliased by following names */
extern int     gl_apversion;    /* the AES version number                 */
extern int     gl_apcount;      /* max # of concurrent AES applications   */
extern int     gl_apid;         /* id of the current application          */
extern long    gl_apprivate;    /* anything the applicaton wants to store */
extern void   *gl_apptree;      /* pointer to array of object tree ptrs   */
extern long    gl_ap1resv;      /* old name for pointer to rsc data       */
extern RSHDR  *gl_aprshdr;      /* pointer to head of rsc data            */
extern int     gl_ap2resv[6];   /* unused entries in global array         */

/*
 * these are valid after apl_xinit()
 */

extern int     gl_grfhandle;   /* global physical VDI handle (graf_handle)*/
extern int     gl_wchar;       /* width of a character                    */
extern int     gl_hchar;       /* height of a character                   */
extern int     gl_wbox;        /* width of a boxchar                      */
extern int     gl_hbox;        /* height of a boxchar                     */
extern GRECT   gl_rwdesk;      /* coordinates of work area of the desktop */
extern GRECT   gl_rfscrn;      /* coordinates of the full screen          */

/*
 * these are valid after apl_vopen()
 */

extern int     gl_vwout[57];   /* work_out from v_opnvwk()                */
extern int     gl_vxout[57];   /* work_out from vq_extnd(,1,)             */

/**************************************************************************
 * automatically use extended binding routines....
 *   if you undo these macros, all the builtin utilities will break!
 *   the normal low-level bindings will still work, though.
 *************************************************************************/

#define appl_init   apl_xinit   /* extended init fills in new gl_ vars    */
#define appl_exit   apl_xexit   /* extended exit closes shared vdi, etc   */
#define wind_update wnd_update  /* stack-like wind_update routine         */
#define graf_mouse  grf_mouse   /* use save/restore mouse shape system    */
#define objc_xywh   obj_xywh    /* this one's just plain faster           */

#define menu_bar(a,b)   mnu_bar((a),(b),0L) /* popable menu system        */

/**************************************************************************
 * Name compatibility stuff.
 *
 *  02/29/92 - v1.8
 *              Added mapping of frm_dsdial to frm_dsdialog.
 *  05/26/90 - v1.4
 *              Added mapping of find_exttype to obj_xtfind.
 *  08/28/89 - v1.3
 *              In v1.3, a big push has been made to make a consistant
 *              naming standard for the AES utilities.  To avoid breaking
 *              a lot of existing code, the following block will direct
 *              the old names to the new routines.
 *************************************************************************/

#define objclg_adjust           rc_gadjust
#define objclv_adjust           rc_vadjust
#define objcl_calc              obj_clcalc

#define objrb_which(a,b)        obj_rbfind((a),(b),SELECTED)
#define obj_rbwhich(a,b)        obj_rbfind((a),(b),SELECTED)
#define objxrb_which            obj_rbfind

#define find_exttype            obj_xtfind

#define objst_change            obj_stchange
#define objfl_change            obj_flchange

#define graqon_mouse            gra_qonmouse
#define graqof_mouse            gra_qofmouse
#define graq_mstate             gra_qmstate

#define frm_dsdial(str,btn, options) frm_dsdialog((options)|FRM_DSL1TITLE,(btn),(str))
#define frm_sizes(tree, rect)      obj_clcalc((tree), ROOT, (rect), NULL)

#endif

/*  end of GEMFAST.H */

