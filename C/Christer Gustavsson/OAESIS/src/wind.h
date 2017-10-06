#ifndef	__WIND__
#define	__WIND__

#include "rdwrs.h"
#include "rlist.h"
#include "types.h"

/*window status codes*/

#define	WIN_OPEN       0x0001
#define	WIN_UNTOPPABLE 0x0002
#define	WIN_DESKTOP    0x0004
#define	WIN_TOPPED     0x0008
#define	WIN_DIALOG     0x0010
#define	WIN_MENU       0x0020
#define WIN_ICONIFIED  0x0040

void	Wind_init_module(void);
void	Wind_exit_module(void);

/****************************************************************************
 * Wind_do_create                                                           *
 *  Implementation of wind_create().                                        *
 ****************************************************************************/
WORD             /* 0 if error or 1 if ok.                                  */
Wind_do_create(  /*                                                         */
WORD owner,      /* Owner of window.                                        */
WORD elems,      /* Elements of window.                                     */
RECT *maxsize,   /* Maximum size allowed.                                   */
WORD status);    /* Status of window.                                       */
/****************************************************************************/

/****************************************************************************
 * Wind_do_get                                                              *
 *  Implementation of wind_get().                                           *
 ****************************************************************************/
WORD           /* 0 if error or 1 if ok.                                    */
Wind_do_get(   /*                                                           */
WORD handle,   /* Identification number of window.                          */
WORD mode,     /* Tells what to return.                                     */
WORD *parm1,   /* Parameter 1.                                              */
WORD *parm2,   /* Parameter 2.                                              */
WORD *parm3,   /* Parameter 3.                                              */
WORD *parm4);  /* Parameter 4.                                              */
/****************************************************************************/

/****************************************************************************
 * Wind_do_open                                                             *
 *  Implementation of wind_open().                                          *
 ****************************************************************************/
WORD           /* 0 if error or 1 if ok.                                    */
Wind_do_open(  /*                                                           */
WORD vid,      /* VDI workstation id.                                       */
WORD id,       /* Identification number of window to open.                  */
RECT *size);   /* Initial size of window.                                   */
/****************************************************************************/

/****************************************************************************
 * Wind_do_close                                                            *
 *  Implementation of wind_close().                                         *
 ****************************************************************************/
WORD           /* 0 if error or 1 if ok.                                    */
Wind_do_close( /*                                                           */
WORD vid,      /* VDI workstation id.                                       */
WORD wid);     /* Identification number of window to close.                 */
/****************************************************************************/

/****************************************************************************
 * Wind_do_delete                                                           *
 *  Implementation of wind_delete().                                        *
 ****************************************************************************/
WORD            /* 0 if error or 1 if ok.                                   */
Wind_do_delete( /*                                                          */
WORD vid,       /* VDI workstation id.                                      */
WORD id);       /* Identification number of window to delete.               */
/****************************************************************************/

/****************************************************************************
 * Wind_do_new                                                              *
 *  Implementation of wind_new().                                           *
 ****************************************************************************/
WORD           /* 0 if error or 1 if ok.                                    */
Wind_do_new(   /*                                                           */
WORD vid,      /* VDI workstation id.                                       */
WORD apid);    /* Application whose windows should be erased.               */
/****************************************************************************/

/****************************************************************************
 * Wind_appl_top                                                            *
 *  Top the top window of an application.                                   *
 ****************************************************************************/
WORD            /* 0 if error or 1 if ok.                                   */
Wind_appl_top(  /*                                                          */
WORD vid,       /* VDI workstation id.                                      */
WORD apid);     /* Application id.                                          */
/****************************************************************************/

/****************************************************************************
 * Wind_draw_elemfast                                                       *
 *  Draw the elements of the window win that intersects with the rectangle  *
 *  r.                                                                      *
 ****************************************************************************/
void                 /*                                                     */
Wind_draw_elemfast(  /*                                                     */
WORD vid,            /* VDI workstation id.                                 */
WINSTRUCT *win,      /* Window description.                                 */
RECT *r,             /* Clipping rectangle.                                 */
WORD start);         /* Start object.                                       */
/****************************************************************************/

/****************************************************************************
 * Wind_draw_elements                                                       *
 *  Draw the elements of the window win that intersects with the rectangle  *
 *  r.                                                                      *
 ****************************************************************************/
void                 /*                                                     */
Wind_draw_elements(  /*                                                     */
WORD vid,            /* VDI workstation id.                                 */
WINSTRUCT *win,      /* Window description.                                 */
RECT *r,             /* Clipping rectangle.                                 */
WORD start);         /* Start object.                                       */
/****************************************************************************/


/****************************************************************************
 * Wind_find_description                                                    *
 *  Find the window structure of the window with identification number id.  *
 ****************************************************************************/
WINSTRUCT	*             /* Found description or NULL.                       */
Wind_find_description(  /*                                                  */
WORD id);               /* Identification number of window.                 */
/****************************************************************************/

/****************************************************************************
 * Wind_update_deskbg                                                       *
 *  Update all of the desk background.                                      *
 ****************************************************************************/
void                     /*                                                 */
Wind_update_deskbg(      /*                                                 */
WORD vid);               /* VDI workstation id.                             */
/****************************************************************************/

/****************************************************************************
 * Wind_on_coord                                                            *
 *  Find window on known coordinates.                                       *
 ****************************************************************************/
WINSTRUCT *    /* Window description or NULL.                               */
Wind_on_coord( /*                                                           */
WORD x,        /* X coordinate.                                             */
WORD y);       /* Y coordinate.                                             */
/****************************************************************************/

/****************************************************************************
 * Wind_beg_update                                                          *
 *  Begin to update screen.                                                 *
 ****************************************************************************/
WORD                   /* 1 if ok or 0.                                     */
Wind_beg_update(void); /*                                                   */
/****************************************************************************/

/****************************************************************************
 * Wind_end_update                                                          *
 *  End update of screen.                                                   *
 ****************************************************************************/
WORD                   /* 1 if ok or 0.                                     */
Wind_end_update(void); /*                                                   */
/****************************************************************************/

void Wind_create(AES_PB *apb); /*0x0064*/
void Wind_open(AES_PB *apb);   /*0x0065*/
void Wind_close(AES_PB *apb);  /*0x0066*/
void Wind_delete(AES_PB *apb); /*0x0067*/
void Wind_get(AES_PB *apb);    /*0x0068*/
void Wind_set(AES_PB *apb);    /*0x0069*/
void Wind_find(AES_PB *apb);   /*0x006a*/
void Wind_update(AES_PB *apb); /*0x006b*/
void Wind_calc(AES_PB *apb);   /*0x006c*/

/****************************************************************************
 * Wind_new                                                                 *
 *  0x006d wind_new().                                                      *
 ****************************************************************************/
void              /*                                                        */
Wind_new(         /*                                                        */
AES_PB *apb);     /* AES parameter block.                                   */
/****************************************************************************/

#endif
