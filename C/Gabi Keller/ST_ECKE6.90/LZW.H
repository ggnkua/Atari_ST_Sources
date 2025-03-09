/*	Lempel - Ziv - Welsch - Komprimierung
 *
 *	Header-Datei mit fÅr Komprimierung und Dekomprimierung
 *	gemeinsam geltenden Definitionen
 *
 *	Autoren: Gabi Keller und Manuel Chakravarty fÅr die ST-Computer
 *	System : LaserC von Application Systems Heidelberg
 */ 

#include <stdio.h>
#include <osbind.h>

#define	BITS_PER_CHAR	8
#define	TRUE		(-1)
#define	FALSE		0 
#define NO_PREFIX	((unsigned) -1)	/*  Alle Bits auf 1  */        
#define TABLESIZE 	1024
#define HASHSIZE	2509  /*  Sollte prim sein  */
#define HASHSTEP	23    /*  Sollte prim sein  */
#define STRSIZE  	80
#define INCREASE_WIDTH  256   /*  Spezialcode um dem Decodierer mitzu-
		               *  teilen, daû ab dem nÑchsten Codewort
		               *  die Bitbreite um eins vergrîûert wird */
#define NEW_TABLE       257   /*  ..., daû er seine Tabelle lîschen soll */
#define FIRST_FREE      258   /*  Erster Code fuer neue EintrÑge        */

typedef	int	bool;
typedef char    string[STRSIZE];
