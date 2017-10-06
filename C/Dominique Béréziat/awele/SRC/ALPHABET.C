/*
 *	Algorithme Alpha-beta pour Awele
 *	code: Jean-Paul B‚rroir
 *	modifi‚ par D. B‚r‚ziat pour la version Atari-GEM
 *		(suivre les directives #ifdef __GEM__ )
 */

#ifdef __GEM__
#include <windom.h>
#include <stdlib.h>
#include <awelersc.h>
#define lrand48() rand()

struct config {
	LONG head;
	WORD flag;
	WORD x,y;
	};
	
extern WINDOW *WinAwele;
extern char Info[];
extern struct config conf;
extern int quit;

#endif


#include <stdio.h>
#include "awele.h"

char maxprof ;

static void alphabeta( TREE * , char , char ) ;


void randplay( AWELE *a , int *cp , int *note ) 
{
    int i;
    do {
	i = 6 + lrand48()%6 ;
    } while ( a->board[i] == 0 ) ;
    (*cp) = i ;
    (*note) = 0 ;
}
/*
   remontee max ( … la becane de jouer ) 
*/
static void alphabeta( TREE * t , char alpha , char beta )
{
    int i,n,is,ie ;
    char m,note,prune=FALSE ;
#ifdef __GEM__
	/* Permet la gestion en tache de fond des fenetres d'Awele */
	
	if( quit)
		return ;
	if( conf.flag & 0x0001)
	{
		evnt.lo_timer=evnt.lo_timer=0;
		if( EvntWindom(MU_MESAG|MU_TIMER|MU_KEYBD) & MU_MESAG)
		{
			if( evnt.buff[0] == WM_MNSELECTED && evnt.buff[4] == MENU_QUIT)
				snd_msg( NULL, AP_TERM, 0, 0, 0, 0);
			if( evnt.buff[0] == AP_TERM)
				quit = 1;
		}
		
		if( conf.flag & 0x0002 && WinAwele)
		{
			sprintf( Info, "Awele: niv=%d  note=%d(a=%d,b=%d)", (int)t->prof, (int)t->note,
						(int)alpha, (int)beta);
			WindSet( WinAwele, WF_INFO, Info);
		}
	}
#endif

    /* si noeud terminal calcul note */
    if ( t->prof == maxprof || t->aw->p1+t->aw->p2 == ALLPIECES ) {
	t->note = t->aw->p2 - t->aw->p1 ; /* note vue du computer */
	if ( t->player == PLAYER1 ) t->note = -t->note ; /* note vue de l'humain */
	return ;	
    } 

    /* indices des fils */
    switch ( t->player ) {
    case PLAYER1:
	is = START1 , ie = END1 ;
	break ;
    case PLAYER2:
	is = START2 , ie = END2 ;
	break ;
    }

    /* remontee note des fils */
    m = alpha ;
    for ( n=0,i=is ; i<ie && !prune ; n++,i++ ) if ( t->aw->board[i]) {
	t->son[n] = create_tree( t->prof+1 , switch_player(t->player) , t->aw  ) ; 
	(void) play( i , t->son[n]->aw , t->player ) ;
	alphabeta( t->son[n] , -beta , -m ) ;
	note = -t->son[n]->note ;
	if ( note > m ) {
	    m = note ;
	    t->best = (char)i ;
	}
	if ( m >= beta ) prune=TRUE ;
	destroy_tree( &(t->son[n]) ) ;
    }
    t->note = m ;
}

/*
   routine renvoyant le meilleur coup au sens du minmax
*/
void think( char player , AWELE *a , int nbcoup , int *coup , int * note )
{
    TREE * t ;
    char npris ;

    maxprof = (char)nbcoup ;

    /* augmente la profondeur quand le nombre de pieces diminue */
    npris = a->p1 + a->p2 ;
    if ( npris > 20 ) maxprof ++ ;
    if ( npris > 25 ) maxprof ++ ;
    if ( npris > 30 ) maxprof ++ ;
    if ( npris > 35 ) maxprof ++ ;
    if ( npris > 40 ) maxprof ++ ;

    /* initialisation de l'arbre */
    t = create_tree( 0 , player , a ) ;

    /* recherche meilleur coup */
    alphabeta( t , -INFINI , INFINI ) ;

    (*coup) = (int)(t->best) ;
    (*note) = -(int)(t->note) ;
    destroy_tree( &t ) ;
}