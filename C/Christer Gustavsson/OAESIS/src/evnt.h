#ifndef	__EVNT__
#define	__EVNT__
#include	"mesagdef.h"
#include	"types.h"

#define MU_KEYBD        0x0001
#define MU_BUTTON       0x0002
#define MU_M1           0x0004
#define MU_M2           0x0008
#define MU_MESAG        0x0010
#define MU_TIMER        0x0020

typedef struct
{
	WORD events;
	WORD bclicks;
	WORD bmask;
	WORD bstate;
	WORD m1flag;
	RECT m1r;
	WORD m2flag;
	RECT m2r;
	WORD locount;
	WORD hicount;
}EVENTIN;

typedef struct
{
	WORD	events;
	WORD	mx;
	WORD	my;
	WORD	mb;
	WORD	ks;
	WORD	kc;
	WORD	mc;
}EVENTOUT;

/****************************************************************************
 * Evnt_waitclicks                                                          *
 *  Wait for mouse button clicks.                                           *
 ****************************************************************************/
WORD             /* Number of clicks that were counted.                     */
Evnt_waitclicks( /*                                                         */
WORD eventpipe,  /* Event message pipe.                                     */
WORD bstate,     /* Button state to wait for.                               */
WORD bmask,      /* Button mask.                                            */
WORD clicks,     /* Maximum number of clicks.                               */
WORD laststate); /* Previous mouse button state.                            */
/****************************************************************************/

/****************************************************************************
 * Evnt_do_button                                                           *
 *  Implementation of evnt_button.                                          *
 ****************************************************************************/
WORD            /* Number of mouse clicks.                                  */
Evnt_do_button( /*                                                          */
WORD apid,      /* Application id.                                          */
WORD eventpipe, /* Event message pipe.                                      */
WORD clicks,    /* Mouse clicks to wait for.                                */
WORD mask,      /* Mouse buttons to wait for.                               */
WORD state,     /* Button state to wait for.                                */
WORD *mx,       /* X position of mouse pointer.                             */
WORD *my,       /* Y position of mouse pointer.                             */
WORD *button,   /* Mouse button state.                                      */
WORD *kstate);  /* Shift key state.                                         */
/****************************************************************************/

/****************************************************************************
 * Evnt_do_multi                                                            *
 *  Implementation of evnt_multi.                                           *
 ****************************************************************************/
void                 /*                                                     */
Evnt_do_multi(       /*                                                     */
WORD     apid,       /* Application id.                                     */
WORD     eventpipe,  /* Event message pipe.                                 */
WORD     msgpipe,    /* AES message pipe.                                   */
EVENTIN  *ei,        /* Input parameters.                                   */
COMMSG   *buf,       /* Message buffer.                                     */
EVENTOUT *eo,        /* Output parameters.                                  */
WORD     level);     /* Number of times the function has been called by     */
                     /* itself.                                             */
/****************************************************************************/

void	Evnt_keybd(AES_PB *apb);	/*0x0014*/
void	Evnt_button(AES_PB *apb);	/*0x0015*/
void	Evnt_mouse(AES_PB *apb);  /*0x0016*/
void	Evnt_mesag(AES_PB *apb);	/*0x0017*/
void	Evnt_timer(AES_PB *apb);	/*0x0018*/
void	Evnt_multi(AES_PB *apb);	/*0x0019*/
void	Evnt_dclick(AES_PB *apb);	/*0x001a*/

#endif
