#include <stdio.h>
#include "awele.h"

#ifdef __GEM__
#include <string.h>
#include <stdlib.h>
#endif

char switch_player( char pl )
{
    if (pl==PLAYER1) return PLAYER2;
    else return PLAYER1;
}

/* realise out=inp */
void awele_equal( AWELE * inp , AWELE * out )
{
    memcpy( out , inp , sizeof(AWELE) ) ;
}

/* creation / destruction d'une structure d'awele */
AWELE * create_awele()
{
    AWELE * a ;

    a = (AWELE *) malloc( sizeof(AWELE) ) ;
    if ( a == NULL ) {
	fprintf(stderr,"create_awele failed\n");
	exit(0) ;
    }

    return a ;

}

void destroy_awele( AWELE ** a ) 
{
    free( *a ) ;

    (*a) = NULL ;
}

/* creation d'une feuille de l'arbre */
TREE * create_tree( char prof , char player , AWELE * aw )
{
    TREE *t ;
    int i ;

    t = (TREE *) malloc( sizeof(TREE) ) ;
    if ( t== NULL ) {
	fprintf(stderr,"create tree failed\n");
	exit(0) ;
    }
    t->aw = create_awele() ;
    awele_equal( aw , t->aw ) ;
    t->prof = prof ;
    t->player = player ;
    t->note = t->best = 0 ;
    for ( i=0;i<HALF_SIZE;i++) t->son[i] = NULL ;
    return t ;
}

/* destroy arbre */
void destroy_tree( TREE ** t )
{
    int i ;

    for ( i=0 ; i<HALF_SIZE ; i++ ) {
	if ( (*t)->son[i] != NULL )  
	    destroy_tree( &( (*t)->son[i] ) ) ;
    }

    destroy_awele( &((*t)->aw) ) ;

    free (*t) ;
    *t = NULL ;
}

/* niveau prof <-> niveau qualif */
void str2level( char *str , int *nc ) 
{
    int nbcoup ;

    if ( !strcmp( str , "BEGINNER" ) ) nbcoup=2 ;
    else if ( !strcmp( str , "NOVICE" ) ) nbcoup=4 ;
    else if ( !strcmp( str , "REGULAR" ) ) nbcoup=6 ;
    else if ( !strcmp( str , "FAIR" ) ) nbcoup=8 ;
    else if ( !strcmp( str , "GOOD" ) ) nbcoup=10 ;
    else if ( !strcmp( str , "EXPERT" ) ) nbcoup=12 ;
    else {
	fprintf(stderr,"Illegal level name\n");
	exit(1) ;
    }
    (*nc) = nbcoup ;
}

void level2str( char *str , int nc )
{
    switch (nc) {
    case 2:
	sprintf(str,"BEGINNER");
	break;
    case 4:
	sprintf(str,"NOVICE");
	break;
    case 6:
	sprintf(str,"REGULAR");
	break;
    case 8:
	sprintf(str,"FAIR");
	break;
    case 10:
	sprintf(str,"GOOD");
	break;
    case 12:
	sprintf(str,"EXPERT");
	break;
    default:
	sprintf(str,"UNKNOWN");
	break;
    }
}

/* 
   2 routines de conversion AWELE * <-> char * pour communication 
   la string contient a qui de jouer, niveau , p1 , p2 et echiquer 
   tous codes sur 2 chiffres
*/
void awele2str( AWELE * a , int lev , int cp , char *str ) 
{
    int i,j ;

    sprintf(str,"%02d%02d%02d%02d",cp,lev,a->p1,a->p2);
    for (i=0,j=8;i<TOTAL_SIZE;i++,j+=2) { 
	str[j] = 48+ a->board[i] / 10 ;
	str[j+1] = 48+ a->board[i] % 10 ;
    }
    str[j] = 0 ;
}

void str2awele( char *str , AWELE * a , int *lev , int *cp )
{
    int i , j ;

    (*cp) = (int)(10*(str[0]-48) + str[1]-48) ;
    (*lev) = (int)(10*(str[2]-48) + str[3]-48) ;
    a->p1 = 10*(str[4]-48) + str[5]-48 ;
    a->p2 = 10*(str[6]-48) + str[7]-48 ;
    for (i=0,j=8 ; i<TOTAL_SIZE ; i++,j+=2 )
	a->board[i] = 10*(str[j]-48) + str[j+1]-48 ;
}
