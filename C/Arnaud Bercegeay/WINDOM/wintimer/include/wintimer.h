/*
 *	Multi Timer for WinDom
 *	(c) 2000 D.B‚r‚ziat
 */

#ifndef __WINTIMER__
#define __WINTIMER__

void TimerInit	( long slice_timer);
void TimerExit	( void);
int  TimerAttach( WINDOW *win, int timer, void *func);int  TimerDelete( WINDOW *win, int timer);
#endif	/* __WINTIMER__ */
