#include	"global.h"

void	Graf_init_module(void);

/****************************************************************************
 * Graf_do_dragbox                                                          *
 *  Implementation of graf_dragbox().                                       *
 ****************************************************************************/
WORD              /* 1 if ok or 0.                                          */
Graf_do_dragbox(  /*                                                        */
WORD   vid,       /* VDI workstation id.                                    */
WORD   eventpipe, /* Event message pipe handle.                             */
WORD   w,         /* Width of box.                                          */
WORD   h,         /* Height of box.                                         */
WORD   sx,        /* Starting x.                                            */
WORD   sy,        /* Starting y.                                            */
RECT   *bound,    /* Bounding rectangle.                                    */
WORD   *endx,     /* Ending x.                                              */
WORD   *endy);    /* Ending y.                                              */
/****************************************************************************/

/****************************************************************************
 * Graf_do_rubberbox                                                        *
 *  Implementation of graf_rubberbox().                                     *
 ****************************************************************************/
WORD                /* 1 if ok or 0.                                        */
Graf_do_rubberbox(  /*                                                      */
WORD   vid,         /* VDI workstation id.                                  */
WORD   eventpipe,   /* Event message pipe handle.                           */
WORD   bx,          /* Top left corner x.                                   */
WORD   by,          /* Top left corner y.                                   */
WORD   minw,        /* Minimum width.                                       */
WORD   minh,        /* Minimum height.                                      */
WORD   *endw,       /* Final width.                                         */
WORD   *endh);      /* Final height.                                        */
/****************************************************************************/

void Graf_do_handle(WORD *cwidth,WORD *cheight,WORD *width,WORD *height);

/****************************************************************************
 * Graf_do_grmobox                                                          *
 *  Implementation of graf_growbox() and graf_movebox().                    *
 ****************************************************************************/
WORD              /*                                                        */
Graf_do_grmobox(  /*                                                        */
WORD vid,         /* VDI workstation id.                                    */
RECT *r1,         /* Start rectangle.                                       */
RECT *r2);        /* End rectangle.                                         */
/****************************************************************************/

WORD Graf_do_mouse(WORD vid,WORD mode,MFORM *formptr);

/****************************************************************************
 * Graf_do_watchbox                                                         *
 *  Implementation of graf_watchbox().                                      *
 ****************************************************************************/
WORD              /* 1 if inside object when button was released or 0.      */
Graf_do_watchbox( /*                                                        */
WORD   apid,      /* Application id.                                        */
WORD   vid,       /* VDI workstation id.                                    */
WORD   eventpipe, /* Event message pipe.                                    */
OBJECT *tree,     /* Resource tree.                                         */
WORD   obj,       /* Object to watch.                                       */
WORD   instate,   /* State when inside object.                              */
WORD   outstate); /* State when outside object.                             */
/****************************************************************************/

/****************************************************************************
 * Graf_do_slidebox                                                         *
 *  Implementation of graf_slidebox().                                      *
 ****************************************************************************/
WORD              /* Relative offset.                                       */
Graf_do_slidebox( /*                                                        */
WORD   apid,      /* Application id.                                        */
WORD   vid,       /* VDI workstation id.                                    */
WORD   eventpipe, /* Event message pipe.                                    */
OBJECT *tree,     /* Resource tree.                                         */
WORD   parent,    /* Parent object.                                         */
WORD   obj,       /* Slider object.                                         */
WORD   orient);   /* Orientation. 0 => horizontal, 1 => vertical.           */
/****************************************************************************/

/****************************************************************************
 * Graf_rubberbox                                                           *
 *  0x0046 graf_rubberbox().                                                *
 ****************************************************************************/
void              /*                                                        */
Graf_rubberbox(   /*                                                        */
AES_PB *apb);     /* AES parameter block.                                   */
/****************************************************************************/

/****************************************************************************
 * Graf_dragbox                                                             *
 *  0x0047 graf_dragbox().                                                  *
 ****************************************************************************/
void              /*                                                        */
Graf_dragbox(     /*                                                        */
AES_PB *apb);     /* AES parameter block.                                   */
/****************************************************************************/

/****************************************************************************
 * Graf_movebox                                                             *
 *  0x0048 graf_movebox().                                                  *
 ****************************************************************************/
void              /*                                                        */
Graf_movebox(     /*                                                        */
AES_PB *apb);     /* AES parameter block.                                   */
/****************************************************************************/

/****************************************************************************
 * Graf_growbox                                                             *
 *  0x0049 graf_growbox().                                                  *
 ****************************************************************************/
void              /*                                                        */
Graf_growbox(     /*                                                        */
AES_PB *apb);     /* AES parameter block.                                   */
/****************************************************************************/

/****************************************************************************
 * Graf_shrinkbox                                                           *
 *  0x004a graf_shrinkbox().                                                *
 ****************************************************************************/
void              /*                                                        */
Graf_shrinkbox(   /*                                                        */
AES_PB *apb);     /* AES parameter block.                                   */
/****************************************************************************/

/****************************************************************************
 * Graf_watchbox                                                            *
 *  0x004b graf_watchbox().                                                 *
 ****************************************************************************/
void              /*                                                        */
Graf_watchbox(    /*                                                        */
AES_PB *apb);     /* AES parameter block.                                   */
/****************************************************************************/

/****************************************************************************
 * Graf_slidebox                                                            *
 *  0x004c graf_slidebox().                                                 *
 ****************************************************************************/
void              /*                                                        */
Graf_slidebox(    /*                                                        */
AES_PB *apb);     /* AES parameter block.                                   */
/****************************************************************************/

void	Graf_handle(AES_PB *apb);	/*0x004d*/
void	Graf_mouse(AES_PB *apb);	/*0x004e*/
void	Graf_mkstate(AES_PB *apb);	/*0x004f*/
