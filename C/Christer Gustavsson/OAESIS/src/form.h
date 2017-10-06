#ifndef	__FORM__
#define	__FORM__

#include	"types.h"

/****************************************************************************
 * Form_do_button                                                           *
 *  Implementation of form_button.                                          *
 ****************************************************************************/
WORD            /* 0 if exit object was found or 1.                         */
Form_do_button( /*                                                          */
WORD apid,      /* Application id.                                          */
WORD vid,       /* VDI workstation id.                                      */
WORD eventpipe, /* Event message pipe.                                      */
OBJECT *tree,   /* Resource tree.                                           */
WORD obj,       /* Object to try the clicks on.                             */
WORD clicks,    /* Number of clicks.                                        */
WORD *newobj);  /* Next object to gain edit focus, or 0.                    */
/****************************************************************************/

void	Form_do_center(OBJECT *tree,RECT *clip);
WORD	Form_do_dial(WORD apid,WORD vid,WORD mode,RECT *r1,RECT *r2);

/****************************************************************************
 * Form_do_do                                                               *
 *  Implementation of form_do.                                              *
 ****************************************************************************/
WORD           /* Object that was selected.                                 */
Form_do_do(    /*                                                           */
WORD apid,     /* Application id.                                           */
WORD vid,      /* VDI workstation id.                                       */
WORD eventpipe,/* Event message pipe.                                       */
OBJECT *tree,  /* Resource tree.                                            */
WORD editobj); /* Position of edit cursor.                                  */
/****************************************************************************/

/****************************************************************************
 *  Form_do_error                                                           *
 *   Display pre-defined error alert box.                                   *
 ****************************************************************************/
WORD              /* Exit button.                                           */
Form_do_error(    /*                                                        */
WORD   apid,      /* Application id number.                                 */
WORD   vid,       /* VDI workstation id.                                    */
WORD   eventpipe, /* Event message pipe.                                    */
WORD   error);    /* Error code.                                            */
/****************************************************************************/

/****************************************************************************
 *  Form_do_keybd                                                           *
 *   Process key input to form.                                             *
 ****************************************************************************/
WORD              /* 0 if an exit object was selected, or 1.                */
Form_do_keybd(    /*                                                        */
WORD   vid,       /* VDI workstation handle.                                */
OBJECT *tree,     /* Resource tree of form.                                 */
WORD   obj,       /* Object with edit focus (0 => none).                    */
WORD   kc,        /* Keypress to process.                                   */
WORD   *newobj,   /* New object with edit focus.                            */
WORD   *keyout);  /* Keypress that couldn't be processed.                   */
/****************************************************************************/


void	Form_do(AES_PB *apb);		/*0x0032*/
void	Form_dial(AES_PB *apb);		/*0x0033*/
void	Form_alert(AES_PB *apb);	/*0x0034*/
void	Form_error(AES_PB *apb);	/*0x0035*/
void	Form_center(AES_PB *apb);	/*0x0036*/

/****************************************************************************
 *  Form_keybd                                                              *
 *   0x0037 form_keybd()                                                    *
 ****************************************************************************/
void              /*                                                        */
Form_keybd(       /*                                                        */
AES_PB *apb);     /* AES parameter block.                                   */
/****************************************************************************/

void	Form_button(AES_PB *apb);	/*0x0038*/

#endif