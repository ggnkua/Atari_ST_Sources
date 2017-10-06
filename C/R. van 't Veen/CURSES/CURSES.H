/* ************************************************************************ */
/*                                                                          */
/*   CURSES.H                      include file for programs using CURSES   */
/*                                                                          */
/* ************************************************************************ */
/* 									    */
/* This source and resulting object may be modified, used or distributed by */
/* anyone who so desires under the following conditions :                   */
/*									    */
/*	1) This notice and the copyright notice shall not be removed or     */
/*	   changed.							    */
/*	2) No credit shall be taken for this source and resulting objects   */
/*	3) This source or resulting objects is not to be traded, sold or    */
/*	   used for personal gain or profit.				    */
/*	4) Inclusion of this source or resulting objects in commercially    */
/*	   available packages is forbidden without written consent of the   */
/*	   author of this source.					    */
/*                                                                          */
/* ************************************************************************ */

#include "portab.h"
#include "stdio.h"

#define reg			register
#define bool		BYTE
#define TRUE		1
#define FALSE       	0

#define _SUBWIN		01
#define _ENDLINE	02
#define _FULLWIN	04
#define	_SCROLLWIN	010
#define	_STANDOUT	0200
#define	WINDOW		struct _win_st

#define TOUCHED		0x0200
#define STANDOUT	0x0100

#define addch(c)			waddch(stdscr, c)
#define mvaddch(y,x,c)		{ wmove(stdscr,y,x) ; waddch(stdscr,c) ; }
#define mvwaddch(w,y,x,c)	{ wmove(w,y,x) ; waddch(w,c) ; }
#define addstr(s)			waddstr(stdscr,s)
#define mvaddstr(y,x,s)		{ wmove(stdscr,y,x) ; waddstr(stdscr,s) ; }
#define mvwaddstr(w,y,x,s)	{ wmove(w,y,x) ; waddstr(w,s) ; }
#define clear()				wclear(stdscr)
#define clearok(w,f)		{ w->_clear = (w->_flags & _FULLWIN) ? f : w->_clear ; }
#define clrtobot()			wclrtobot(stdscr)
#define clrtoeol()			wclrtoeol(stdscr)
#define delch()				wdelch(stdscr)
#define mvdelch(y,x)		{ wmove(stdscr,y,x) ; wdelch(stdscr) ; }
#define mvwdelch(w,y,x)		{ wmove(w,y,x) ; wdelch(w) ; }
#define deleteln()			wdeleteln(stdscr)
#define mvdeleteln(y,x)		{ wmove(stdscr,y,x) ; wdeleteln(stdscr) ; }
#define mvwdeleteln(w,y,x)	{ wmove(w,y,x) ; wdeleteln(w) ; }
#define erase()				werase(stdscr)
#define insch(c)			winsch(stdscr,c)
#define mvinsch(y,x,c)		{ wmove(stdscr,y,x) ; winsch(stdscr,c) ; }
#define mvwinsch(w,y,x,c)	{ wmove(w,y,x) ; winsch(w,c) ; }
#define insertln()			winsertln(stdscr)
#define mvinsertln(y,x)		{ wmove(stdscr,y,x) ; winsertln(stdscr) ; }
#define mvwinsertln(w,y,x)	{ wmove(w,y,x) ; winsertln(w) ; }
#define move(y,x)			wmove(stdscr,y,x)
#define refresh()			wrefresh(stdscr)
#define standout()			wstandout(stdscr)
#define standend()			wstandend(stdscr)
#define getch()				wgetch(stdscr)
#define mvgetch(y,x)		( wmove(stdscr,y,x) , wgetch(stdscr) )
#define mvwgetch(w,y,x)		( wmove(w,y,x) , wgetch(w) )
#define getstr(s)			wgetstr(stdscr,s)
#define mvgetstr(y,x,s)		{ wmove(stdscr,y,x) ; wgetstr(stdscr,s) ; }
#define mvwgetstr(w,y,x,s)	{ wmove(w,y,x) ; wgetstr(w,s) ; }
#define getyx(w,y,x)		{ y = w->_cury ; x = w->_curx ; }
#define inch()				(stdscr->_y[stdscr->_cury][stdscr->_curx])
#define mvinch(y,x)			( wmove(stdscr,y,x) , stdscr->_y[stdscr->_cury][stdscr->_curx])
#define mvwinch(w,y,x)		( wmove(w,y,x) , w4->_y[w->_cury][w->_curx])
#define winch(w)			(w->_y[w->_cury][w->_curx])

struct _win_st {
	WORD	_cury, _curx ;
	WORD	_maxy, _maxx ;
	WORD	_begy, _begx ;
	WORD	_flags ;
	BYTE	_clear ;
	BYTE	_leave ;
	BYTE	_scroll ;
	WORD	**_y ;
	WORD	*_firstch ;
	WORD	*_lastch ;
} ;

extern WINDOW *curscr ;
extern WINDOW *stdscr ;
extern char	*Def_term ;
extern bool	My_term ;
extern char	*ttytype ;
extern int	LINES ;
extern int	COLS ;
extern int	ERR ;
extern int	OK ;
