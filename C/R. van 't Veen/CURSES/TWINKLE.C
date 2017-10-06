/* sample application using curses calls, this takes about 25 seconds on the */
/* Atari and over 6 minutes on a mainframe, using a vt100 on a 4800 baud     */
/* line. Even on the mainframe it uses 24 seconds of computation time.       */

#include "portab.h"
#include "curses.h"

#define NCOLS 80
#define NLINES 24
#define MAXPATT 4

struct locs {
	char y,x ;
	} ;

typedef struct locs LOCS ;

LOCS Layout[NCOLS*NLINES] ;

int	pat ;
int	nstar ;

main()
{
	int i ;

	initscr() ;
	leaveok(stdscr,1) ;
	for ( i = 0 ; i < 10 ; i++ )
		{
		makeboard() ;
		puton('*') ;
		puton(' ') ;
		} ;
	endwin() ;
}

makeboard()
{
	int y,x ;
	LOCS *lp ;
	
	pat = rand() % MAXPATT ;
	lp = Layout ;
	for ( y = 0 ; y < NLINES ; y++ )
		for ( x = 0 ; x < NCOLS ; x++ )
			if ( ison(y,x) )
				{
				lp->y = y ;
				lp->x = x ;
				lp++ ;
				} ;
	nstar = lp - Layout ;
}

ison(y,x)
int y,x ;
{
	switch ( pat )
		{
		case 0:
			return(!(y & 0x01)) ;
		case 1:
			if ( x >= NLINES && y >= NCOLS )
				return(0) ;
			if ( y < 3 || y >= NLINES - 3 )
				return(1) ;
			return((x < 3 || x >= NCOLS - 3 )) ;
		case 2:
			return(((x+y) & 0x01)) ;
		case 3:
			return(( y>= 9 && y <= 15 )) ;
		} ;
}

puton(ch)
char ch ;
{
	LOCS  *lp, *end, temp ;
	int r ;
	
	end = &(Layout[nstar]) ;
	for ( lp = Layout ; lp < end ; lp++ )
		{
		r = ((unsigned int) rand()) % nstar ;
		temp = *lp ;
		*lp = Layout[r] ;
		Layout[r] = temp ;
		} ;
	for ( lp = Layout ; lp < end ; lp++ )
		{
		mvaddch(lp->y,lp->x,ch) ;
		refresh() ;
		} ;
}
