/* #[curses: simple-minded implementation of the curses package				*/
/* #[intro: introduction													*/
/* 																			*/
/* This source and resulting object may be modified, used or distributed by */
/* anyone who so desires under the following conditions :                   */
/*																			*/
/*		1) This notice and the copyright notice shall not be removed or     */
/*		   changed.															*/
/*		2) No credit shall be taken for this source and resulting objects   */
/*		3) This source or resulting objects is not to be traded, sold or    */
/*		   used for personal gain or profit.								*/
/*		4) Inclusion of this source or resulting objects in commercially    */
/*		   available packages is forbidden without written consent of the   */
/*		   author of this source.											*/
/*                                                                          */
/* #]intro:																	*/
/* #[include: include files													*/
#include "portab.h"
#include "osbind.h"
#include "curses.h"
/* #]include:																*/
/* define supervisor mode entry forgotten in osbind.h						*/
#define Supexec(a)	xbios(38,a)
/* terminal states : cooked, cbreak and raw									*/
#define COOKED 0
#define CBREAK 1
#define RAW    2
/* define address of system-variable _conterm for kbshift return value		*/
#define CONTERM		(*((char *)0x484))
/* #[globals: definition of global variables								*/
/* #[curglob: define the following variables as external in curses.h		*/
WINDOW *curscr ;
WINDOW *stdscr ;
char	*Def_term = "AtariST" ;
bool	My_term = FALSE ;
char	*ttytype = "Atari ST-series computer, VT52/CURSES mode" ;
int		LINES = 25 ;
int		COLS = 80 ;
int		ERR = 0 ;
int		OK = 1 ;
/* #]curglob:																*/
bool   _doecho = FALSE ;
bool   _nlmap = FALSE ;
bool   _curini = FALSE ;
BYTE	_modinp = 0 ; /* set input to Un*x compatability, i.e only char's	*/
BYTE	_csry = 0 ;
BYTE	_csrx = 0 ;
char *cpyrid = "Copyright, R. van't Veen. All rights reserved. 1987" ;

overlay "curses"	/* put in separate segment */

/* #]globals:																*/
/* #[miscel: miscellaneous curses functions									*/
/* #[initscr: initialize the curses package									*/
initscr()
{
	WORD i,j ;
	WINDOW *newwin() ;

	if ( _curini )
		{
		wrefresh(curscr) ;
		if ( cpyrid == NULL )
			Pterm(-12L) ;
		ERR = 1 ;
		OK = 0 ;
		return ;
		} ;
	_curini = 1 ;
	curscr = newwin(0,0,0,0) ;
	if ( curscr == NULL )
		{
		ERR = 1 ;
		OK = 0 ;
		return ;
		} ;
	stdscr = newwin(0,0,0,0) ;
	if ( stdscr == NULL )
		{
		ERR = 1 ;
		OK = 0 ;
		return ;
		} ;
	Bconout(2,'\033') ;
	Bconout(2,'E') ;
	Bconout(2,'\033') ;
	Bconout(2,'w') ;
	Bconout(2,'\033') ;
	Bconout(2,'f') ;
	_csry = 0 ;
	_csrx = 0 ;
	ERR = 0 ;
	OK = 1 ;
}
/* #]initscr:																*/
/* #[endwin: end of curses package											*/
endwin()
{
	if ( !_curini )
		{
		ERR = 1 ;
		OK = 0 ;
		return ;
		} ;
	_curini = 0 ;
	delwin(stdscr) ;
	delwin(curscr) ;
	_movcur(LINES,0) ;
	Bconout(2,'\033') ;
	Bconout(2,'e') ;
	ERR = 1 ;
	OK = 0 ;
}
/* #]endwin:																*/
/* #[newwin: create a new window for the user								*/
WINDOW *newwin(l,c,by,bx)
int l,c,bx,by ;
{
	WINDOW *tmp ;
	WORD   i, j, nl, nc ;
	char	*malloc() ;
	
	tmp = ( WINDOW * ) malloc(sizeof(WINDOW)) ;
	if ( tmp == NULL )
		{
		ERR = 1 ;
		OK = 0 ;
		return(NULL) ;
		} ;
	tmp->_curx = 0 ;
	tmp->_cury = 0 ;
	tmp->_clear = 0 ;
	tmp->_leave = 0 ;
	tmp->_scroll = 0 ;
	if ( l == 0 )
		nl = LINES - by ;
	else
		nl = l ;
	if ( c == 0 )
		nc = COLS - bx ;
	else
		nc = c ;
	if ( nl < 1 || nl > LINES || nc < 1 || nc > COLS )
		{
		free(tmp) ;
		ERR = 1 ;
		OK = 0 ;
		return(NULL) ;
		} ;
	tmp->_maxy = nl - 1 ;
	tmp->_maxx = nc - 1 ;
	if ( nl == LINES && nc == COLS )
		tmp->_flags = _FULLWIN ;
	else
		tmp->_flags = 0 ;
	if ( by < 0 || by >= LINES || bx < 0 || bx >= COLS )
		{
		free(tmp) ;
		ERR = 1 ;
		OK = 0 ;
		return(NULL) ;
		} ;
	tmp->_begy = by ;
	tmp->_begx = bx ;
	tmp->_y = ( WORD ** ) malloc(sizeof(WORD *)*(tmp->_maxy+1)) ;
	if ( tmp->_y == NULL )
		{
		free(tmp) ;
		ERR = 1 ;
		OK = 0 ;
		return(NULL) ;
		} ;
	tmp->_y[0] = ( WORD * ) malloc(sizeof(WORD)*(tmp->_maxy+1)*(tmp->_maxx+1)) ;
	if ( tmp->_y[0] == NULL )
		{
		free(tmp->_y) ;
		free(tmp) ;
		ERR = 1 ;
		OK = 0 ;
		return(NULL) ;
		} ;
	for ( i = 1 ; i <= tmp->_maxy ; i++ )
		tmp->_y[i] = tmp->_y[0] + i * ( tmp->_maxx + 1 ) ;
	for ( i = 0 ; i <= tmp->_maxy ; i++ )
		{
		for ( j = 0 ; j <= tmp->_maxx ; j++ )
			tmp->_y[i][j] = ' ' ;
		} ;
/* make everything changed on first update of tmp							*/
	touchwin(tmp) ;
	ERR = 0 ;
	OK = 1 ;
	return(tmp) ;
}
/* #]newwin:																*/
/* #[delwin: delete a window												*/
delwin(w)
WINDOW *w ;
{
	if ( w == NULL )
		{
		ERR = 1 ;
		OK = 0 ;
		return ;
		} ;
	if ( w->_flags & _SUBWIN )
		free(w->_y) ;
	else
		{
		free(w->_y[0]) ;
		free(w->_y) ;
		} ;
	free(w) ;
	ERR = 0 ;
	OK = 1 ;
}
/* #]delwin:																*/
/* #[mvwin: move window														*/
mvwin(w,y,x)
WINDOW *w ;
int y,x ;
{
	if ( y < 0 || x < 0 || ( y + w->_maxy + 1 ) > LINES || ( x + w->_maxx + 1 ) > COLS )
		{
		ERR = 1 ;
		OK = 0 ;
		return ;
		} ;
	w->_begy = y ;
	w->_begx = x ;
	touchwin(w) ;
	ERR = 0 ;
	OK = 1 ;
}
/* #]mvwin:																	*/
/* #[touchwin: touch a window												*/
touchwin(w)
WINDOW *w ;
{
	WORD i,j ;
	w->_firstch = w->_y[0] ;
	w->_lastch = &(w->_y[w->_maxy][w->_maxx]) ;
	for ( i = 0 ; i <= w->_maxy ; i++ )
		for ( j = 0 ; j <= w->_maxx ; j++ )
			w->_y[i][j] = w->_y[i][j] | TOUCHED ;
	ERR = 0 ;
	OK = 1 ;
}
/* #]touchwin:																*/
/* #[subwin: create a sub-window											*/
WINDOW *subwin(w,l,c,by,bx)
WINDOW *w ;
int l,c,by,bx ;
{
	WINDOW *tmp ;
	WORD   i, nl, nc ;
	char	*malloc() ;
	
/* cannot take subwindows of curscr											*/
	if ( w == curscr )
		{
		ERR = 1 ;
		OK = 0 ;
		return(NULL) ;
		} ;
	tmp = ( WINDOW * ) malloc(sizeof(WINDOW)) ;
	if ( tmp == NULL )
		{
		ERR = 1 ;
		OK = 0 ;
		return(NULL) ;
		} ;
	tmp->_curx = 0 ;
	tmp->_cury = 0 ;
	tmp->_clear = 0 ;
	tmp->_leave = 0 ;
	tmp->_scroll = 0 ;
	if ( l == 0 )
		nl = LINES - by ;
	else
		nl = l ;
	if ( c == 0 )
		nc = COLS - bx ;
	else
		nc = c ;
	if ( l < 1 || l > (w->_maxy+1) || c < 1 || c > (w->_maxx+1) )
		{
		free(tmp) ;
		ERR = 1 ;
		OK = 0 ;
		return(NULL) ;
		} ;
	tmp->_maxy = nl - 1 ;
	tmp->_maxx = nc - 1 ;
	if ( nl == LINES && nc == COLS )
		tmp->_flags = _FULLWIN | _SUBWIN ;
	else
		tmp->_flags = _SUBWIN ;
	if ( by < w->_begy || by >= (w->_maxy+w->_begy) ||
		 bx < w->_begx || bx >= (w->_maxx+w->_begx) )
		{
		free(tmp) ;
		ERR = 1 ;
		OK = 0 ;
		return(NULL) ;
		} ;
	tmp->_begy = by ;
	tmp->_begx = bx ;
	tmp->_y = ( WORD ** ) malloc(sizeof(WORD *)*(tmp->_maxy+1)) ;
	if ( tmp->_y == NULL )
		{
		free(tmp) ;
		ERR = 1 ;
		OK = 0 ;
		return(NULL) ;
		} ;
	tmp->_y[0] = w->_y[0] + ( tmp->_begy - w->_begy ) * ( w->_maxx + 2 ) + ( tmp->_maxx - w->_maxx ) ;
	for ( i = 1 ; i <= tmp->_maxy ; i++ )
		tmp->_y[i] = tmp->_y[0] + i * ( w->_maxx + 2 ) ;
/* make everything changed on first update of tmp							*/
	touchwin(tmp) ;
	ERR = 0 ;
	OK = 1 ;
	return(tmp) ;
}
/* #]subwin:																*/
/* #[leaveok: tell curses where to leave the cursor after updating			*/
leaveok(w,f)
WINDOW *w ;
bool f ;
{
	w->_leave = f ;
	ERR = 0 ;
	OK = 1 ;
}
/* #]leaveok:																*/
/* #[scrollok: tell curses it is ok to scroll the window					*/
scrollok(w,f)
WINDOW *w ;
bool f ;
{
	w->_scroll = f ;
	ERR = 0 ;
	OK = 1 ;
}
/* #]scrollok:																*/
/* #[nl: tell curses to map CR to CR,LF										*/
nl()
{
	_nlmap = 1 ;
	ERR = 0 ;
	OK = 1 ;
}
/* #]nl:																	*/
/* #[nonl: tell curses not to map CR to CR,LF								*/
nonl()
{
	_nlmap = 0 ;
	ERR = 0 ;
	OK = 1 ;
}
/* #]nonl:																	*/
/* #[longname: return the full name of the terminal                         */
/* always returns the contents of ttytype in name							*/
longname(termbuf,name)
char *termbuf, *name ;
{
	int i ;
	
	for ( i = 0 ; ttytype[i] != '\0' ; i++ )
		name[i] = ttytype[i] ;
	name[i] = '\0' ;
}
/* #]longname:																*/
/* #]miscel:																*/
/* #[output: output functions												*/
/* #[waddch: add a character to a window									*/
waddch(w,c)
WINDOW *w ;
char   c ;
{
	WORD i, tpos ;

	ERR = 0 ;
	OK = 1 ;
	if ( c >= 0x20 )
		{
		if ( w == curscr )
			{
			if ( ( w->_flags & _STANDOUT ))
				{
				w->_y[w->_cury][w->_curx] = c | STANDOUT | TOUCHED ;
				Bconout(2,'\033') ;
				Bconout(2,'p') ;
				Bconout(5,c) ;
				Bconout(2,'\033') ;
				Bconout(2,'q') ;
				}
			else
				{
				w->_y[w->_cury][w->_curx] = c | TOUCHED ;
				Bconout(5,c) ;
				} ;
			_csrx++ ;
			}
		else
			{
			if ( (w->_flags & _STANDOUT ))
				w->_y[w->_cury][w->_curx] = c | STANDOUT | TOUCHED ;
			else
				w->_y[w->_cury][w->_curx] = c | TOUCHED ;
			if ( w->_firstch == 0 )
				{
				w->_firstch = &(w->_y[w->_cury][w->_curx]) ;
				w->_lastch = w->_firstch ;
				}
			else
				{
				if ( w->_firstch > &(w->_y[w->_cury][w->_curx]) )
					w->_firstch = &(w->_y[w->_cury][w->_curx]) ;
				else
					{
					if ( w->_lastch < &(w->_y[w->_cury][w->_curx]) )
						w->_lastch = &(w->_y[w->_cury][w->_curx]) ;
					} ;
				} ;
			} ;
		wmove(w,w->_cury,w->_curx+1) ;
		}
	else if ( c == '\n' )
		{
		wclrtoeol(w) ;
		if ( _nlmap )
			wmove(w,w->_cury+1,0) ;
		else
			wmove(w,w->_cury+1,w->_curx) ;
		}
	else if ( c == '\r' )
		{
		wmove(w,w->_cury,0) ;
		}
	else if ( c == '\t' )
		{
		tpos = ( w->_curx + w->_begx ) % 8 ;
		tpos = ( tpos == 0 ) ? 8 : tpos ;
		for ( i = 0 ; i < tpos ; i++ )
			waddch(w,' ') ;
		}
	else
		{
		if ( w == curscr )
			{
			if ( ( w->_flags & _STANDOUT ))
				{
				w->_y[w->_cury][w->_curx] = c | STANDOUT | TOUCHED ;
				Bconout(2,'\033') ;
				Bconout(2,'p') ;
				Bconout(5,c) ;
				Bconout(2,'\033') ;
				Bconout(2,'q') ;
				}
			else
				{
				w->_y[w->_cury][w->_curx] = c | TOUCHED ;
				Bconout(5,c) ;
				} ;
			_csrx++ ;
			}
		else
			{
			if ( (w->_flags & _STANDOUT ))
				w->_y[w->_cury][w->_curx] = c | STANDOUT | TOUCHED ;
			else
				w->_y[w->_cury][w->_curx] = c | TOUCHED ;
			if ( w->_firstch == 0 )
				{
				w->_firstch = &(w->_y[w->_cury][w->_curx]) ;
				w->_lastch = w->_firstch ;
				}
			else
				{
				if ( w->_firstch > &(w->_y[w->_cury][w->_curx]) )
					w->_firstch = &(w->_y[w->_cury][w->_curx]) ;
				else
					{
					if ( w->_lastch < &(w->_y[w->_cury][w->_curx]) )
						w->_lastch = &(w->_y[w->_cury][w->_curx]) ;
					} ;
				} ;
			} ;
		wmove(w,w->_cury,w->_curx+1) ;
		} ;
}
/* #]waddch:																*/
/* #[waddstr: add a string of characters to a window						*/
waddstr(w,s)
WINDOW *w ;
char   *s ;
{
	WORD  i ;
	
	ERR = 0 ;
	OK = 1 ;
	for ( i = 0 ; s[i] != '\0' ; i++ )
		waddch(w,s[i]) ;
}
/* #]waddstr:																*/
/* #[box: draw a box around a window										*/
box(w,v,h)
WINDOW *w ;
char v,h ;
{
	WORD i ;
	
	ERR = 0 ;
	OK = 1 ;
	for ( i = 0 ; i <= w->_maxy ; i++ )
		{
		mvwaddch(w,i,0,v) ;
		mvwaddch(w,i,w->_maxx,v) ;
		} ;
	for ( i = 1 ; i < w->_maxx ; i++ )
		{
		mvwaddch(w,0,i,h) ;
		mvwaddch(w,w->_maxy,i,h) ;
		} ;
}
/* #]box:																	*/
/* #[wclear: clear a window													*/
wclear(w)
WINDOW *w ;
{
	ERR = 0 ;
	OK = 1 ;
	werase(w) ;
	clearok(w,TRUE) ;
	w->_curx = 0 ;
	w->_cury = 0 ;
}
/* #]wclear:																*/
/* #[wclrtobo: clear a window to the bottom									*/
wclrtobot(w)
WINDOW *w ;
{
	WORD i,j ;

	ERR = 0 ;
	OK = 1 ;
	for ( i = w->_curx ; i <= w->_maxx ; i++ )
		w->_y[w->_cury][i] = ' ' | TOUCHED ;
	for ( i = w->_cury + 1 ; i <= w->_maxy ; i++ )
		{
		for ( j = 0 ; j <= w->_maxx ; j++ )
			w->_y[i][j] = ' ' | TOUCHED ;
		} ;
	if ( w == curscr )
		{
		Bconout(2,'\033') ;
		Bconout(2,'J') ;
		}
	else
		{
		if ( w->_firstch == 0 )
			{
			w->_firstch = &(w->_y[w->_cury][w->_curx]) ;
			w->_lastch = &(w->_y[w->_maxy][w->_maxx]) ;
			}
		else
			{
			if ( w->_firstch > &(w->_y[w->_cury][w->_curx]) )
				w->_firstch = &(w->_y[w->_cury][w->_curx]) ;
			w->_lastch = &(w->_y[w->_maxy][w->_maxx]) ;
			} ;
		} ;
}
/* #]wclrtobo:																*/
/* #[wclrtoeo: clear a window to the end of the line						*/
wclrtoeol(w)
WINDOW *w ;
{
	WORD i ;

	ERR = 0 ;
	OK = 1 ;
	for ( i = w->_curx ; i <= w->_maxx ; i++ )
		w->_y[w->_cury][i] = ' ' | TOUCHED ;
	if ( w == curscr )
		{
		Bconout(2,'\033') ;
		Bconout(2,'K') ;
		}
	else
		{
		if ( w->_firstch == 0 )
			{
			w->_firstch = &(w->_y[w->_cury][w->_curx]) ;
			w->_lastch = &(w->_y[w->_cury][w->_maxx]) ;
			}
		else
			{
			if ( w->_firstch > &(w->_y[w->_cury][w->_curx]) )
				w->_firstch = &(w->_y[w->_cury][w->_curx]) ;
			if ( w->_lastch < &(w->_y[w->_cury][w->_maxx]) )
				w->_lastch = &(w->_y[w->_cury][w->_maxx]) ;
			} ;
		} ;
}
/* #]wclrtoeo:																*/
/* #[wdelch: delete a character on a window									*/
wdelch(w)
WINDOW *w ;
{
	WORD ox, oy, i ;
	
	ERR = 0 ;
	OK = 1 ;
	ox = w->_curx ;
	oy = w->_cury ;
	for ( i = ox + 1 ; i <= w->_maxx ; i++ )
		{
		w->_y[oy][i-1] = w->_y[oy][i] | TOUCHED ;
		} ;
	w->_y[oy][w->_maxx] = ' ' | TOUCHED ;
	w->_curx = ox ;
	w->_cury = oy ;
	if ( w == curscr )
		{
		Bconout(2,'\033') ;
		Bconout(2,'K') ;
		for ( i = w->_curx ; i <= w->_maxx ; i++ )
			{
			Bconout(5,(w->_y[w->_cury][i] & 0xff )) ;
			_csrx++ ;
			} ;
		_movcur(w->_cury,w->_curx) ;
		}
	else
		{
		if ( w->_firstch == 0 )
			{
			w->_firstch = &(w->_y[w->_cury][w->_curx]) ;
			w->_lastch = &(w->_y[w->_cury][w->_maxx]) ;
			}
		else
			{
			if ( w->_firstch > &(w->_y[w->_cury][w->_curx]) )
				w->_firstch = w->_y[w->_cury] ;
			if ( w->_lastch < &(w->_y[w->_cury][w->_maxx]) )
				w->_lastch = &(w->_y[w->_cury][w->_maxx]) ;
			} ;
		} ;
}
/* #]wdelch:																*/
/* #[wdeletel: delete a line from a window									*/
wdeleteln(w)
WINDOW *w ;
{
	WORD i,j ;
	
	ERR = 0 ;
	OK = 1 ;
	for ( i = w->_cury + 1 ; i <= w->_maxy ; i++ )
		{
		for ( j = 0 ; j <= w->_maxx ; j++ )
			w->_y[i-1][j] = w->_y[i][j] | TOUCHED ;
		} ;
	for ( j = 0 ; j <= w->_maxx ; j++ )
		w->_y[w->_maxy][j] = ' ' | TOUCHED ;
	if ( w == curscr )
		{
		Bconout(2,'\033') ;
		Bconout(2,'M') ;
		_csrx = 0 ;
		_movcur(w->_cury,w->_curx) ;
		}
	else
		{
		if ( w->_firstch == 0 )
			{
			w->_firstch = w->_y[w->_cury] ;
			w->_lastch = &(w->_y[w->_maxy][w->_maxx]) ;
			}
		else
			{
			if ( w->_firstch > w->_y[w->_cury] )
				w->_firstch = w->_y[w->_cury] ;
			w->_lastch = &(w->_y[w->_maxy][w->_maxx]) ;
			} ;
		} ;
}
/* #]wdeletel:	 															*/
/* #[werase: erase a window													*/
werase(w)
WINDOW *w ;
{
	WORD i,j ;
	
	ERR = 0 ;
	OK = 1 ;
	for ( i = 0 ; i <= w->_maxy ; i++ )
		{
		for ( j = 0 ; j <= w->_maxx ; j++ )
			w->_y[i][j] = ' ' | TOUCHED ;
		} ;
	if ( w == curscr )
		{
		Bconout(2,'\033') ;
		Bconout(2,'E') ;
		_csry = 0 ;
		_csrx = 0 ;
		_movcur(curscr->_cury,curscr->_curx) ;
		}
	else
		{
		w->_firstch = w->_y[0] ;
		w->_lastch = &(w->_y[w->_maxy][w->_maxx]) ;
		} ;
}
/* #]werase:																*/
/* #[winsch: insert a character												*/
winsch(w,c)
WINDOW *w ;
char c ;
{
	WORD ox,oy,i ;
	BYTE tstr[2] ;
	
	ERR = 0 ;
	OK = 1 ;
	ox = w->_curx ;
	oy = w->_cury ;
	for ( i = w->_maxx - 1 ; i >= ox ; --i )
		{
		w->_y[oy][i+1] = w->_y[oy][i] | TOUCHED ;
		} ;
	if ( w == curscr )
		{
		Bconout(2,'\033') ;
		Bconout(2,'K') ;
		for ( i = w->_curx ; i <= w->_maxx ; i++ )
			{
			Bconout(5,(w->_y[w->_cury][i] & 0xff )) ;
			_csrx++ ;
			} ;
		_movcur(w->_cury,w->_curx) ;
		}		
	else
		{
		if ( w->_firstch == 0 )
			{
			w->_firstch = &(w->_y[w->_cury][w->_curx]) ;
			w->_lastch = &(w->_y[w->_cury][w->_maxx]) ;
			}
		else
			{
			if ( w->_firstch > &(w->_y[w->_cury][w->_curx]) )
				w->_firstch = &(w->_y[w->_cury][w->_curx]) ;
			if ( w->_lastch < &(w->_y[w->_cury][w->_maxx]) )
				w->_lastch = &(w->_y[w->_cury][w->_maxx]) ;
			} ;
		} ;
	mvwaddch(w,oy,ox,c) ;
}
/* #]winsch:																*/
/* #[winsertl: insert a line in a window									*/
winsertln(w)
WINDOW *w ;
{
	WORD ox,oy,i,j ;
	
	ERR = 0 ;
	OK = 1 ;
	for ( i = w->_maxy - 1 ; i >= w->_cury ; --i )
		{
		for ( j = 0 ; j <= w->_maxx ; j++ )
			w->_y[i+1][j] = w->_y[i][j] | TOUCHED ;
		} ;
	for ( j = 0 ; j <= w->_maxx ; j++ )
		w->_y[w->_cury][j] = ' ' | TOUCHED ;
	if ( w == curscr )
		{
		Bconout(2,'\033') ;
		Bconout(2,'L') ;
		_csrx = 0 ;
		_movcur(w->_cury,w->_curx) ;
		}
	else
		{
		if ( w->_firstch == 0 )
			w->_firstch = w->_y[w->_cury] ;
		else
			{
			if ( w->_firstch > w->_y[w->_cury] )
				w->_firstch = w->_y[w->_cury] ;
			} ;
		w->_lastch = &(w->_y[w->_maxy][w->_maxx]) ;
		} ;
}
/* #]winsertl:																*/
/* #[wmove: move the cursor of the window to a location						*/
wmove(w,y,x)
WINDOW *w ;
int y,x ;
{
	WORD i ;

	ERR = 0 ;
	OK = 1 ;
	if ( x < 0 )
		{
		w->_curx = 0 ;
		ERR = 1 ;
		OK = 0 ;
		}
	else
		{
		if ( x > w->_maxx )
			{
			w->_curx = w->_maxx ;
			ERR = 1 ;
			OK = 0 ;
			}
		else
			w->_curx = x ;
		} ;
	if ( y < 0 )
		{
		w->_cury = 0 ;
		ERR = 1 ;
		OK = 0 ;
		}
	else
		{
		if ( y > w->_maxy )
			{
			if ( w->_scroll )
				{
				for ( i = w->_maxy ; i < y ; i++ )
					scroll(w) ;
				} ;
			w->_cury = w->_maxy ;
			ERR = 1 ;
			OK = 0 ;
			}
		else
			w->_cury = y ;
		} ;
	if ( w == curscr )
		{
		_movcur(curscr->_cury,curscr->_curx) ;
		} ;
}
/* #]wmove:																	*/	
/* #[woverlay: overlay two windows.											*/
woverlay(v,w)
WINDOW *v, *w ;
{
	WORD i, j ;
	
	for ( i = 0 ; i <= w->_maxy && i <= v->_maxy ; i++ )
		{
		for ( j = 0 ; j <= w->_maxx && j <= v->_maxx ; j++ )
			{
			if ( ( v->_y[i][j] & 0xff ) == 0x20 )
				w->_y[i][j] = v->_y[i][j] | TOUCHED ;
			} ;
		} ;
	if ( w == curscr )
		wrefresh(curscr) ;
	else
		{
		w->_firstch = w->_y[0] ;
		w->_lastch = &(w->_y[w->_maxy][w->_maxx]) ;
		} ;
}
/* #]woverlay:																*/
/* #[overwrit: overwrite two windows.										*/
overwrite(v,w)
WINDOW *v, *w ;
{
	WORD i, j ;
	
	for ( i = 0 ; i <= w->_maxy && i <= v->_maxy ; i++ )
		{
		for ( j = 0 ; j <= w->_maxx && j <= v->_maxx ; j++ )
			{
			w->_y[i][j] = v->_y[i][j] | TOUCHED ;
			} ;
		} ;
	if ( w == curscr )
		wrefresh(curscr) ;
	else
		{
		w->_firstch = w->_y[0] ;
		w->_lastch = &(w->_y[w->_maxy][w->_maxx]) ;
		} ;
}
/* #]overwrit:																*/
/* #[wstandou: set the standout flag for a window							*/
wstandout(w)
WINDOW *w ;
{
	w->_flags = w->_flags | _STANDOUT ;
	ERR = 0 ;
	OK = 1 ;
}
/* #]wstandou:																*/
/* #[wstanden: end standout mode											*/
wstandend(w)
WINDOW *w ;
{
	w->_flags = w->_flags & ( ~_STANDOUT) ;
	ERR = 0 ;
	OK = 1 ;
}
/* #]wstanden:																*/
/* #]output:																*/
/* #[input:	input functions													*/
/* #[raw: set terminal in raw mode											*/
raw()
{
/*
 * raw mode means : 
 * when getting a character from the keyboard, return everything
 * including keyboard shift state.
 */
  int	__sshft() ;
  
  if ( _modinp == RAW )
  	return ;
  Supexec(__sshft) ;
  _modinp = RAW ;
}
/* #]raw:																	*/
/* #[noraw: reset terminal from raw mode into cooked mode					*/
noraw()
{
	int __ushft() ;
	if ( _modinp != RAW )
		return ;
	Supexec(__ushft) ;
	_modinp = COOKED ;
}
/* #]noraw:																	*/
/* #[__sshft: set terminal to return keyboard shift state					*/
/* execute in supervisor mode only											*/
__sshft()
{
	int ov, nv ;
	
	ov = CONTERM ;
	nv = ov | 0x08 ;
	CONTERM = nv ;
}
/* #]__sshft:																*/
/* #[__ushft: set terminal to not return keyboard shift state				*/
/* execute in supervisor mode only											*/
__ushft()
{
	int ov, nv ;
	
	ov = CONTERM ;
	nv = ov & ~0x08 ;
	CONTERM = nv ;
}
/* #]__ushft:																*/
/* #[crmode: set terminal in cbreak mode									*/
/*
 * cbreak mode means for the atari ;
 * return both keyboard scan code as well as the character value.
 * kill the process with a process terminate -1 as soons as a control C is met
 * control D is also recognized to be the EOF.
 */
crmode()
{
	if ( _modinp == CBREAK )
		return ;
	if ( _modinp == RAW )
		noraw() ;
	_modinp = CBREAK ;
}
/* #]crmode:																*/
/* #[nocrmode: reset terminal from cbreak into cooked mode					*/		
nocrmode()
{
	if ( _modinp != CBREAK )
		return ;
	_modinp = COOKED ;
}
/* #]nocrmode:																*/
/* #[echo: set curses to echo characters on input							*/
echo()
{
	_doecho = TRUE ;
	ERR = 0 ;
	OK = 1 ;
}
/* #]echo:																	*/
/* #[noecho: set curses not to echo characters on input						*/
noecho()
{
	_doecho = FALSE ;
	ERR = 0 ;
	OK = 1 ;
}
/* #]noecho:																*/
/* #[wgetch: get a character from the terminal								*/
/* WARNING : wgetch returns a 32-bit value, not a char although only		*/
/* the lowest 8 bits may actually be transmitted.							*/
wgetch(w)
WINDOW *w ;
{
	bool reset ;
	LONG	retval ;

	reset = FALSE ;
	if ( _modinp == COOKED && _doecho == TRUE )
		{
		reset = TRUE ;
		crmode() ;
		} ;
	Bconout(2,'\033') ;
	Bconout(2,'e') ;
	switch ( _modinp )
		{
		case COOKED:
			while ( !Cconis() ) ;
			retval = Cnecin() ;
			retval = retval & 0x00ff ;
/* kill process on control C												*/
			if ( retval == 0x03 )
				Pterm(-1L) ;
			break ;
		case CBREAK:
			while ( !Cconis() ) ;
			retval = Cnecin() ;
/* kill process on control C												*/
			if ( ( retval & 0x00ff ) == 0x03 )
				Pterm(-1L) ;
			break ;
		case RAW:
			while ( !Cconis() ) ;
			retval = Crawcin() ;
			break ;
		} ;
	Bconout(2,'\033') ;
	Bconout(2,'f') ;
	if ( _doecho )
		waddch(w,(char ) ( 0x00ff & retval )) ;
	if ( reset )
		nocrmode() ;
	return(retval) ;
}
/* #]wgetch:																*/
/* #[wgetstr: get a string from the terminal								*/
wgetstr(w,s)
WINDOW *w ;
char *s ;
{
	WORD ox, oy ;
	bool reset, end ;
	char c ;
	int i ;
	LONG wgetch() ;
	
	reset = FALSE ;
	getyx(w,oy,ox) ;
	if ( _modinp == COOKED && _doecho == TRUE )
		{
		reset = TRUE ;
		_doecho = FALSE ;
		} ;
	i = 0 ;
	for ( end = FALSE ; !end ; i++ )
		{ 
		wrefresh(w);
		switch ( _modinp )
			{
			case COOKED:
				c = ( char ) wgetch(w) ;
				if ( c == 0x0d || c == 0x0a || c == 0x04 || c == 0 )
					{
					s[i] = '\0' ;
					end = TRUE ;
					break ;
					} ;
/* receive a backspace */
				if ( c == 0x08 ) {
					if ( i != 0 )
						{
						--i ;
						s[i] = 0 ;
						if ( reset ) {
							int	x, y;
							getyx(w, y, x);
							mvwaddch(w,y,x-1,' ');
							wmove(w, y, x-1);
/*
							mvwaddstr(w,oy,ox,s) ;
*/
						}
					}
					i--;
					break;
				}
/* receive control U or line kill 											*/
				if ( c == 0x13 )
					{
					i = 0 ;
					if ( reset )
						wmove(w,oy,ox) ;
					break ;
					} ;
				s[i] = c ;
				if (reset)
					waddch(w,c) ;
				break ;
			case CBREAK:
				c = ( char ) wgetch(w) ;
				if ( c == 0x0d || c == 0x0a || c == 0x04 || c == 0 )
					{
					s[i] = '\0' ;
					end = TRUE ;
					break ;
					} ;
				s[i] = c ;
				break ;
			case RAW:
				c = ( char ) wgetch(w) ;
				if ( c == 0x0d || c == 0x0a || c == 0x04 || c == 0 )
					{
					s[i] = '\0' ;
					end = TRUE ;
					break ;
					} ;
				s[i] = c ;
				break ;
			} ;
		} ;
	if ( reset )
		_doecho = TRUE ;
}
/* #]wgetstr:																*/
/* #]input: 																*/
/* #[wrefresh: refresh a window on the screen								*/
wrefresh(w)
WINDOW *w ;
{
	WORD i,j,k,l ;
	WORD c, *ptr ;
	
	ERR = 0 ;
	OK = 1 ;
	if ( w != curscr && curscr->_clear )
		{
		Bconout(2,'\033') ;
		Bconout(2,'E') ;
		_csry = 0 ;
		_csrx = 0 ;
		for ( i = 0 ; i < LINES ; i++ )
			{
			for ( j = 0 ; j < COLS ; j++ )
				curscr->_y[i][j] = ' ' ;
			} ;
		curscr->_clear = 0 ;
		} ;
	if ( w->_clear )
		{
		if ( ( w->_flags & _FULLWIN ) )
			{
			Bconout(2,'\033') ;
			Bconout(2,'E') ;
			_csry = 0 ;
			_csrx = 0 ;
			for ( i = 0 ; i < LINES ; i++ )
				{
				for ( j = 0 ; j < COLS ; j++ )
					curscr->_y[i][j] = ' ' ;
				} ;
			} ;
		w->_firstch = w->_y[0] ;
		w->_lastch = &(w->_y[w->_maxy][w->_maxx]) ;
		w->_clear = 0 ;
		} ;
	if ( w != curscr )
		{
		if ( w->_firstch != 0 )
			{
			if ( w->_flags & _SUBWIN )
				{
				for ( i = 0 ; i <= w->_maxy ; i++ )
					{
					ptr = w->_y[i] ;
					if ( ptr >= w->_firstch && ptr <= w->_lastch )
						{
						for ( j = 0 ; j <= w->_maxx ; j++ )
							{
							c = ptr[j] ;
							k = i + w->_begy ;
							l = j + w->_begx ;
							if ( ( c & TOUCHED ) && ( k >= 0 && k < LINES && l >= 0 && l < COLS ) )
								{
								ptr[j] = c & ~TOUCHED ;
								if ( ( curscr->_y[k][l] & 0x01ff ) != ( c & 0x01ff ) )
									{
									curscr->_y[k][l] = c ;
									_movcur(k,l) ;
									if ( ( c & STANDOUT ) )
										{
										Bconout(2,'\033') ;
										Bconout(2,'p') ;
										Bconout(5,(c & 0xff)) ;
										Bconout(2,'\033') ;
										Bconout(2,'q') ;
										}
									else
										{
										Bconout(5,( c & 0xff )) ;
										} ;
									_csry = k ;
									_csrx = l + 1 ;
									} ;
								} ;
							} ;
						} ;
					} ;
				}
			else
				{
				for ( ptr = w->_firstch ; ptr <= w->_lastch ; ptr++ )
					{
					c = *ptr ;
					if ( c & TOUCHED )
						{
						k = ( WORD ) ( ptr - w->_y[0] ) ;
						k = k / (  w->_maxx + 1 ) ;
						l = ( WORD ) ( ptr - w->_y[k] ) + w->_begx ;
						k = k + w->_begy ;
						if ( k >= 0 && k < LINES && l >= 0 && l < COLS ) 
							{
							*ptr = c & ~TOUCHED ;
							if ( ( curscr->_y[k][l] & 0x01ff ) != ( c & 0x01ff ) )
								{
								curscr->_y[k][l] = c ;
								_movcur(k,l) ;
								if ( ( c & STANDOUT ) )
									{
									Bconout(2,'\033') ;
									Bconout(2,'p') ;
									Bconout(5,(c & 0xff)) ;
									Bconout(2,'\033') ;
									Bconout(2,'q') ;
									}
								else
									{
									Bconout(5,( c & 0xff )) ;
									} ;
								_csry = k ;
								_csrx = l + 1 ;
								} ;
							} ;
						} ;
					} ;
				} ;
			w->_firstch = 0 ;
			w->_lastch = 0 ;
			if ( w->_leave )
				{
				w->_curx = _csrx - w->_begx ;
				w->_cury = _csry - w->_begy ;
				curscr->_cury = _csry ;
				curscr->_curx = _csrx ;
				}
			else
				{
				curscr->_cury = w->_cury + w->_begy ;
				curscr->_curx = w->_curx + w->_begx ;
				_movcur(curscr->_cury, curscr->_curx) ;
				} ;
			}
		else
			{
			curscr->_cury = w->_cury + w->_begy ;
			curscr->_curx = w->_curx + w->_begx ;
			_movcur(curscr->_cury, curscr->_curx) ;
			} ;
		}
	else
		{
		Bconout(2,'\033') ;
		Bconout(2,'H') ;
		_csry = 0 ;
		_csrx = 0 ;
		for ( i = 0 ; i < LINES ; i++ )
			{
			for ( j = 0 ; j < COLS ; j++ )
				{
				c = w->_y[i][j] ;
				if ( ( c & STANDOUT ) )
					{
					Bconout(2,'\033') ;
					Bconout(2,'p') ;
					Bconout(5,(c & 0xff)) ;
					Bconout(2,'\033') ;
					Bconout(2,'q') ;
					}
				else
					{
					Bconout(5,(c & 0xff)) ;
					} ;
				_csrx++ ;
				} ;
			_movcur(i+1,0) ;
			} ;
		_movcur( curscr->_cury, curscr->_curx) ; 
		} ;
}
/* #]wrefresh:																*/
/* #[detail: detail functions of curses										*/
/* #[mvcur: move cursor in standard curses manner							*/
mvcur(ly,lx,ny,nx)
int ly,lx,ny,nx ;
{
	_movcur((WORD) ny,( WORD) nx) ;
}
/* #]mvcur:																	*/
/* #[_movcur: move cursor													*/
_movcur(y,x)
WORD y,x ;
{
	if ( _csry == y && _csrx == x )
		return ;
	Bconout(2,'\033') ;
	Bconout(2,'Y') ;
	Bconout(2,y+' ') ;
	Bconout(2,x+' ') ;
	_csry = y ;
	_csrx = x ;
}
/* #]_movcur:																*/
/* #[scroll: scroll a window upward one line								*/
scroll(w)
WINDOW *w ;
{
	WORD i,j ;
	
	ERR = 0 ;
	OK = 1 ;
	for ( i = 0 ; i < w->_maxy ; i++ )
		for ( j = 0 ; j <= w->_maxx ; j++ )
			w->_y[i][j] = w->_y[i+1][j] ;
	for ( i = 0 ; i <= w->_maxx ; i++ )
		w->_y[w->_maxy][i] = ' ' ;
	if ( w == curscr )
		wrefresh(curscr) ;
	else
		{
		w->_firstch = w->_y[0] ;
		w->_lastch = &(w->_y[w->_maxy][w->_maxx]) ;
		} ;
}
/* #]scroll:																*/
/* #]detail:																*/
/* #]curses:																*/

/*
 * Extra stuff added - tony
 */

printw(format, a1, a2, a3, a4, a5, a6, a7, a8, a9)
char	*format;
int	a1, a2, a3, a4, a5, a6, a7, a8, a9;
{
	char	lbuf[256];

	sprintf(lbuf, format, a1, a2, a3, a4, a5, a6, a7, a8, a9);
	addstr(lbuf);
}

scanw(format, a1, a2, a3, a4, a5, a6, a7, a8, a9)
char	*format;
int	a1, a2, a3, a4, a5, a6, a7, a8, a9;
{
	char	lbuf[256];

	echo();
	getstr(lbuf);
	sscanf(lbuf, format, a1, a2, a3, a4, a5, a6, a7, a8, a9);
}
