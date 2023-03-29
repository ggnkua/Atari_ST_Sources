/*****************************************************************************/
/*                                                                           */
/* Modul: EVENT.H                                                            */
/* Datum: 21/05/90                                                           */
/*                                                                           */
/* History:																																	 */
/* 26.01.04: hndl_mesag um MKINFO *mk erweitert															 */
/*****************************************************************************/

#ifndef __EVENT__
#define __EVENT__

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

GLOBAL UWORD events;                    /* Auf zu wartende Ereignisse */
GLOBAL LONG  millisecs;                 /* Zu verstreichende Millisekunden */
GLOBAL WORD  bclicks;                   /* Maus-Knopf-Klicks */
GLOBAL WORD  bmask;                     /* Maus-Knopf-Maske */
GLOBAL WORD  bstate;                    /* Maus-Knopf-Status */

/****** FUNCTIONS ************************************************************/

GLOBAL VOID    hndl_events _((VOID));
GLOBAL VOID    hndl_keybd  _((MKINFO *mk));
GLOBAL VOID    hndl_button _((MKINFO *mk));
/* [GS] 5.1d Start */
GLOBAL VOID    hndl_mesag  _((WORD *msgbuff, MKINFO *mk ));
/* Ende; alt:
GLOBAL VOID    hndl_mesag  _((WORD *msgbuff));
*/
GLOBAL VOID    hndl_timer  _((LONG millisecs));

GLOBAL BOOLEAN init_event  _((VOID));
GLOBAL BOOLEAN term_event  _((VOID));

#endif /* __EVENT__ */

