#include <stdio.h>
#include "awele.h"

static int next_case( int i)
{
    return (i+1)%TOTAL_SIZE ;
}

/* 
   realise un mouvement, pas de prise de prisoniers, quelque soit le joueur
   retour l'indice du trou final
*/
int awele_move_hole( AWELE * a , int cp ) 
{
    register int nb , i , ind ;

    nb = a->board[cp] ;
    a->board[cp]=0;

    for (i=0,ind=cp;i<nb;i++) {
	ind = next_case(ind);
	if (ind==cp) ind = next_case(ind) ;
	a->board[ind] ++ ;
    }
    return  ind ;

}

/*
   coup du joueur 1, suppose possible
*/
static void play1( int cp , AWELE *a )
{
    register int  i , last ;

    last = awele_move_hole(a,cp);
    if (last<START2) return ;
    for (i=last;i>=START2;i--) 
	if (a->board[i]==2||a->board[i]==3){
	    a->p1 += a->board[i] ;
	    a->board[i] = 0 ;
	}
	else return ;
}

/*
   coup du joueur 2, suppose possible
*/
static void play2( int cp , AWELE *a )
{
    register int  i , last ;

    last = awele_move_hole(a,cp);
    if (last>=END1) return ;
    for (i=last;i>=START1;i--) 
	if (a->board[i]==2||a->board[i]==3){
	    a->p2 += a->board[i] ;
	    a->board[i] = 0 ;
	}
	else return ;
}

/* awele de depart */
void init_awele( AWELE * a )
{
    register int i ;

    for (i=0;i<TOTAL_SIZE;i++) a->board[i] = 4;
    a->p1 = a->p2 = 0 ;
}

/*
   verifie que le coup cp est possible pour le joueur player
*/
int check_possible_move( AWELE *a , int cp , char player )
{
    if ( a->board[cp] == 0 ) return FALSE ;
    switch ( player ) {
    case PLAYER1:
	if ( cp < START1 || cp >= END1 ) return FALSE;
	break;
    case PLAYER2:
	if ( cp < START2 || cp >= END2 ) return FALSE;
	break;
    }
    return TRUE ;
}

/*
   coup global avec check si fin ou non 
*/
int play( int cp , AWELE *a , char player )
{
    register int i;
    char n;

    switch (player) {
    case PLAYER1:
	play1(cp,a);
	for (i=START2,n=0;i<END2;i++) n+= a->board[i] ;
	if ( !n ) {
	    for (i=START1;i<END1;i++) {
		a->p2 += a->board[i] ;
		a->board[i] = 0 ;
	    }
	    return FALSE ;
	}
	return TRUE ;
    case PLAYER2:
	play2(cp,a);
	for (i=START1,n=0;i<END1;i++) n+= a->board[i] ;
	if ( !n ) {
	    for (i=START2;i<END2;i++) {
		a->p1 += a->board[i] ;
		a->board[i] = 0 ;
	    }
	    return FALSE ;
	}
	return TRUE ;
    }
    return -1;
}