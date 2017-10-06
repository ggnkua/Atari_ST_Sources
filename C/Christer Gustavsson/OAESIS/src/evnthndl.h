#ifndef __EVHD__
#define __EVHD__

#include "types.h"

typedef struct {
	WORD	apid;
	BYTE	flag1;
	RECT	r1;
	BYTE	flag2;
	RECT	r2;
}RECTEVENT;

typedef struct reventlist {
	RECTEVENT	event;
	
	struct reventlist	*next;	
}REVENTLIST;

/****************************************************************************
 * Evhd_make_rectevent                                                      *
 *  Start reporting of mouse events.                                        *
 ****************************************************************************/
void                   /*                                                   */
Evhd_make_rectevent(   /*                                                   */
RECTEVENT *re);        /* Description of events that should be reported.    */
/****************************************************************************/

/****************************************************************************
 * Evhd_kill_rectevent                                                      *
 *  End reporting of mouse events.                                          *
 ****************************************************************************/
void                   /*                                                   */
Evhd_kill_rectevent(   /*                                                   */
WORD apid);            /* Application id to end reporting to.               */
/****************************************************************************/

/****************************************************************************
 * Evhd_init_module                                                         *
 *  Initiate event processing module.                                       *
 ****************************************************************************/
void                    /*                                                  */
Evhd_init_module(void); /*                                                  */
/****************************************************************************/

/****************************************************************************
 * Evhd_exit_module                                                         *
 *  Shutdown event processing module.                                       *
 ****************************************************************************/
void                    /*                                                  */
Evhd_exit_module(void); /*                                                  */
/****************************************************************************/

/****************************************************************************
 * Evhd_gain_mctrl                                                          *
 *  Gain exclusive right to mouse events.                                   *
 ****************************************************************************/
WORD              /*                                                        */
Evhd_gain_mctrl(  /*                                                        */
WORD apid,        /* Application to gain exclusive right.                   */
WORD send_coord); /* 1 => movement packets will be sent, 0 => no movement.  */
/****************************************************************************/

/****************************************************************************
 * Evhd_release_mctrl                                                       *
 *  Release right to mouse events.                                          *
 ****************************************************************************/
WORD                      /*                                                */
Evhd_release_mctrl(void); /*                                                */
/****************************************************************************/

/****************************************************************************
 * Evhd_click_owner                                                         *
 *  Find out which application that "owns" mouse clicks.                    *
 ****************************************************************************/
WORD                    /*                                                  */
Evhd_click_owner(void); /*                                                  */
/****************************************************************************/

#endif